// probe_sycl_ze.cpp — Gate ③b: the LAST piece before funding route A' (section 19).
//
// §18 proved D3D12<->L0 interop on a SELF-CREATED ze context. Route A' hosts the
// kernels in SYCL and needs the same interop on the ze handles that come OUT OF A
// SYCL QUEUE (different provenance — the UR adapter created them; the fence import
// and the immediate list must bind to the SYCL context, not a parallel one, or the
// game's fence and our kernels would live in different address spaces).
//
// Test:
//  1. SYCL queue on the L0 backend; pull ze_context/ze_device/ze_command_queue via
//     sycl::get_native<backend::ext_oneapi_level_zero> (backend_traits_level_zero.hpp:59-97).
//  2. Create an immediate command list on the SYCL-owned context/device.
//  3. Import the D3D12 shared fence on the SYCL-owned device handle (same call as §18).
//  4. Ordering: immediate-list wait(2) blocks while fence=1; cmdq->Signal(2) releases it.
//  5. Coexistence: a plain SYCL kernel on the same queue still runs and sees correct
//     results — i.e. the interop did not poison the SYCL runtime's own submissions.
// GREEN here => route A' has no remaining unknowns; report to user for the go.
#include <sycl/sycl.hpp>
#include <sycl/ext/oneapi/backend/level_zero.hpp>
#include <windows.h>
#include <d3d12.h>
#include <dxgi1_6.h>
#include <level_zero/ze_api.h>
#include <cstdio>
#include <cstdint>

static int fails=0;
#define OKAY(cond,msg,...) do{ if(!(cond)){std::printf("FAIL  " msg "\n",##__VA_ARGS__);fails++;} \
                               else {std::printf("ok    " msg "\n",##__VA_ARGS__);} }while(0)

int main(){
    setvbuf(stdout,nullptr,_IONBF,0);
    // ---- 1. SYCL queue on L0 ----
    sycl::device dev;
    for(auto&d:sycl::device::get_devices(sycl::info::device_type::gpu))
        if(d.get_info<sycl::info::device::name>().find("Arc")!=std::string::npos){dev=d;break;}
    sycl::queue q(dev);
    std::printf("sycl queue on: %s\n", dev.get_info<sycl::info::device::name>().c_str());

    auto zctx = sycl::get_native<sycl::backend::ext_oneapi_level_zero>(q.get_context());
    auto zdev = sycl::get_native<sycl::backend::ext_oneapi_level_zero>(dev);
    auto zqvar = sycl::get_native<sycl::backend::ext_oneapi_level_zero>(q);
    ze_command_queue_handle_t zq = std::get<0>(zqvar);   // queue variant: [0]=cmd_queue
    std::printf("native handles: ctx=%p dev=%p cmdq=%p\n",(void*)zctx,(void*)zdev,(void*)zq);
    OKAY(zctx && zdev && zq, "get_native<level_zero> yields non-null ze handles from SYCL objects");

    // ---- 2. immediate command list on the SYCL-owned context/device ----
    ze_command_list_handle_t zcl=nullptr;
    ze_command_queue_desc_t qd={ZE_STRUCTURE_TYPE_COMMAND_QUEUE_DESC,nullptr,0,0,0,
                                ZE_COMMAND_QUEUE_MODE_DEFAULT,ZE_COMMAND_QUEUE_PRIORITY_NORMAL};
    ze_result_t r=zeCommandListCreateImmediate(zctx,zdev,&qd,&zcl);
    OKAY(r==ZE_RESULT_SUCCESS&&zcl,"zeCommandListCreateImmediate on SYCL context (r=0x%x)",(unsigned)r);

    // ---- 3. D3D12 side: same-card adapter, shared fence + queue ----
    ID3D12Device* d3d=nullptr; ID3D12CommandQueue* cmdq=nullptr; ID3D12Fence* fence=nullptr; HANDLE fh=nullptr;
    {
        IDXGIFactory6* fac=nullptr; CreateDXGIFactory1(IID_PPV_ARGS(&fac));
        IDXGIAdapter1* ad=nullptr;
        for(UINT i=0;fac->EnumAdapters1(i,&ad)!=DXGI_ERROR_NOT_FOUND;++i){
            DXGI_ADAPTER_DESC1 dd; ad->GetDesc1(&dd);
            if(dd.VendorId==0x8086) break;
            ad->Release(); ad=nullptr;
        }
        OKAY(ad!=nullptr,"d3d12 found Intel adapter");
        if(!ad) return 1;
        OKAY(SUCCEEDED(D3D12CreateDevice(ad,D3D_FEATURE_LEVEL_12_1,IID_PPV_ARGS(&d3d))),"D3D12CreateDevice(A770)");
        ad->Release(); fac->Release();
        D3D12_COMMAND_QUEUE_DESC qd12={}; qd12.Type=D3D12_COMMAND_LIST_TYPE_DIRECT;
        OKAY(SUCCEEDED(d3d->CreateCommandQueue(&qd12,IID_PPV_ARGS(&cmdq))),"CreateCommandQueue");
        OKAY(SUCCEEDED(d3d->CreateFence(1,D3D12_FENCE_FLAG_SHARED,IID_PPV_ARGS(&fence))),"CreateFence(1,SHARED)");
        OKAY(SUCCEEDED(d3d->CreateSharedHandle(fence,nullptr,GENERIC_ALL,nullptr,&fh)),"fence CreateSharedHandle(GENERIC_ALL)");
    }
    ze_external_semaphore_win32_ext_desc_t win={ZE_STRUCTURE_TYPE_EXTERNAL_SEMAPHORE_WIN32_EXT_DESC};
    win.handle=fh; win.name=nullptr;
    ze_external_semaphore_ext_desc_t ed={ZE_STRUCTURE_TYPE_EXTERNAL_SEMAPHORE_EXT_DESC};
    ed.pNext=&win; ed.flags=ZE_EXTERNAL_SEMAPHORE_EXT_FLAG_D3D12_FENCE;
    ze_external_semaphore_ext_handle_t xsem=nullptr;
    r=zeDeviceImportExternalSemaphoreExt(zdev,&ed,&xsem);   // <-- the SYCL-owned device handle
    OKAY(r==ZE_RESULT_SUCCESS&&xsem,"import D3D12 fence on SYCL-owned ze_device (r=0x%x)",(unsigned)r);

    // ---- 4. ordering on the immediate list ----
    if(xsem && zcl){
        ze_external_semaphore_wait_params_ext_t wp={ZE_STRUCTURE_TYPE_EXTERNAL_SEMAPHORE_WAIT_PARAMS_EXT};
        wp.value=2;
        r=zeCommandListAppendWaitExternalSemaphoreExt(zcl,1,&xsem,&wp,nullptr,0,nullptr);
        OKAY(r==ZE_RESULT_SUCCESS,"append wait(2) (r=0x%x)",(unsigned)r);
        if(r==ZE_RESULT_SUCCESS){
            ze_result_t t0=zeCommandListHostSynchronize(zcl,50);
            OKAY(t0==ZE_RESULT_NOT_READY,"wait blocks while fence=1 (sync=0x%x)",(unsigned)t0);
            cmdq->Signal(fence,2);
            ze_result_t t1=zeCommandListHostSynchronize(zcl,2000000);
            OKAY(t1==ZE_RESULT_SUCCESS,"wait released by D3D12 Signal(2) (sync=0x%x)",(unsigned)t1);
        }
    }

    // ---- 5. coexistence: SYCL kernel still runs on the same queue ----
    {
        int* buf=sycl::malloc_shared<int>(64,q);
        for(int i=0;i<64;i++) buf[i]=0;
        q.parallel_for(sycl::range(64),[=](sycl::id<1> i){ buf[i[0]]=i[0]*3+1; }).wait();
        int bad=0; for(int i=0;i<64;i++) if(buf[i]!=i*3+1) bad++;
        OKAY(bad==0,"SYCL kernel after interop on same queue: %s (%d wrong)",bad?"CORRUPT":"OK",bad);
        sycl::free(buf,q);
    }

    std::printf("PROBE_SYCL_ZE %s (%d fails)\n",fails?"RED":"GREEN",fails);
    std::fflush(stdout);
    return fails?2:0;
}
