// probe_spv_ze.cpp — the FIRST gate of the libxmx rewrite: can Intel's Level Zero
// driver load the SHIPPED Vulkan-flavor SPIR-V (GLCompute entry + push constants +
// buffer_reference + float16/int64 extensions)?
//
// Why this gates everything: the shipped network is 40+ .comp files compiled by
// glslangValidator --target-env vulkan1.3 into work/*.spv, loaded today via
// vkCreateShaderModule (libxmx.c:504). If L0's zeModuleCreate accepts those same
// bytes, the rewrite can keep the whole shader pipeline and only swap the C API
// surface (route A). If it rejects them (rlx-oneapi's claim: L0 wants OpenCL/SYCL
// "Kernel" flavor, not Vulkan "GLCompute"), the rewrite must ALSO recompile every
// kernel through the SYCL/ESIMD path (route B) — a much bigger, different plan.
//
// Pure load test: read a .spv, zeModuleCreate, print result + build log. No launch.
#include <level_zero/ze_api.h>
#include <cstdio>
#include <cstdlib>
#include <vector>
static std::vector<unsigned char> slurp(const char* p){
    FILE*f=fopen(p,"rb"); if(!f){printf("no such file %s\n",p);return {};}
    fseek(f,0,SEEK_END); long n=ftell(f); fseek(f,0,SEEK_SET);
    std::vector<unsigned char> b(n); fread(b.data(),1,n,f); fclose(f); return b;
}
int main(int argc,char**argv){
    setvbuf(stdout,nullptr,_IONBF,0);
    const char* path = argc>1?argv[1]:"work/quantize_row.spv";
    auto spv=slurp(path); if(spv.empty())return 1;
    printf("file %s : %zu bytes, magic=0x%08x\n",path,spv.size(),
        spv.size()>=4?*(unsigned*)spv.data():0u);
    if(zeInit(ZE_INIT_FLAG_GPU_ONLY)!=ZE_RESULT_SUCCESS){printf("zeInit fail\n");return 1;}
    uint32_t n=0; zeDriverGet(&n,nullptr);
    ze_driver_handle_t* ds=new ze_driver_handle_t[n]; zeDriverGet(&n,ds);
    ze_device_handle_t zdev=nullptr; ze_driver_handle_t zdrv=nullptr; ze_context_handle_t zctx=nullptr;
    for(uint32_t i=0;i<n && !zdev;i++){
        uint32_t m=0; zeDeviceGet(ds[i],&m,nullptr);
        ze_device_handle_t* dd=new ze_device_handle_t[m]; zeDeviceGet(ds[i],&m,dd);
        for(uint32_t j=0;j<m;j++){ ze_device_properties_t p={ZE_STRUCTURE_TYPE_DEVICE_PROPERTIES};
            zeDeviceGetProperties(dd[j],&p); if(p.type==ZE_DEVICE_TYPE_GPU&&p.vendorId==0x8086){zdev=dd[j];zdrv=ds[i];break;} }
        delete[] dd;
    }
    if(!zdev){printf("no Intel GPU\n");return 1;}
    ze_context_desc_t cd={ZE_STRUCTURE_TYPE_CONTEXT_DESC};
    ze_result_t cr=zeContextCreate(zdrv,&cd,&zctx);
    printf("zeContextCreate = 0x%x\n",(unsigned)cr);
    if(cr!=ZE_RESULT_SUCCESS) return 3;
    ze_module_desc_t md={ZE_STRUCTURE_TYPE_MODULE_DESC};
    md.format=ZE_MODULE_FORMAT_IL_SPIRV; md.inputSize=spv.size(); md.pInputModule=spv.data(); md.pBuildFlags="";
    ze_module_handle_t mod=nullptr; ze_module_build_log_handle_t log=nullptr;
    printf("calling zeModuleCreate on %zu-byte GLCompute spv ...\n",spv.size());
    ze_result_t r=zeModuleCreate(zctx,zdev,&md,&mod,&log);
    printf("zeModuleCreate(Vulkan GLCompute spv) = 0x%x %s\n",(unsigned)r, r==ZE_RESULT_SUCCESS?"LOADED":"REJECTED");
    fflush(stdout);
    if(log){ size_t sz=0;
        if(zeModuleBuildLogGetString(log,&sz,nullptr)==ZE_RESULT_SUCCESS && sz){
            std::vector<char> s(sz+1,0); zeModuleBuildLogGetString(log,&sz,s.data());
            printf("--- build log ---\n%s\n",s.data()); }
        zeModuleBuildLogDestroy(log); }
    if(mod) zeModuleDestroy(mod);
    zeContextDestroy(zctx);
    return r==ZE_RESULT_SUCCESS?0:2;
}
