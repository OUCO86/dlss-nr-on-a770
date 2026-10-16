// authoritative external-memory capability query via the dedicated getter
#include <level_zero/ze_api.h>
#include <cstdio>
int main(){
    setvbuf(stdout,nullptr,_IONBF,0);
    if(zeInit(ZE_INIT_FLAG_GPU_ONLY)!=ZE_RESULT_SUCCESS){printf("zeInit fail\n");return 1;}
    uint32_t n=0; zeDriverGet(&n,nullptr);
    ze_driver_handle_t* ds=new ze_driver_handle_t[n]; zeDriverGet(&n,ds);
    for(uint32_t i=0;i<n;i++){
        uint32_t m=0; zeDeviceGet(ds[i],&m,nullptr);
        ze_device_handle_t* dd=new ze_device_handle_t[m]; zeDeviceGet(ds[i],&m,dd);
        for(uint32_t j=0;j<m;j++){
            ze_device_properties_t p={ZE_STRUCTURE_TYPE_DEVICE_PROPERTIES};
            zeDeviceGetProperties(dd[j],&p);
            if(p.type==ZE_DEVICE_TYPE_GPU && p.vendorId==0x8086){
                ze_device_external_memory_properties_t em={ZE_STRUCTURE_TYPE_DEVICE_EXTERNAL_MEMORY_PROPERTIES};
                ze_result_t r=zeDeviceGetExternalMemoryProperties(dd[j],&em);
                printf("dev %s : zeDeviceGetExternalMemoryProperties r=0x%x\n",p.name,(unsigned)r);
                printf("  memoryAllocationImportTypes=0x%x  (D3D12_HEAP=%d D3D12_RES=%d OPAQUE_WIN32=%d)\n",
                    em.memoryAllocationImportTypes,(em.memoryAllocationImportTypes>>6)&1,(em.memoryAllocationImportTypes>>7)&1,(em.memoryAllocationImportTypes>>2)&1);
                printf("  memoryAllocationExportTypes =0x%x\n",em.memoryAllocationExportTypes);
            }
            delete[] dd;
        }
    }
    return 0;
}
