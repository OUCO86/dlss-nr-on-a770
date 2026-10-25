#include <sycl/sycl.hpp>
#include <cstdio>
int main(){
  for(auto&d:sycl::device::get_devices(sycl::info::device_type::gpu)){
    if(d.get_backend()!=sycl::backend::ext_oneapi_level_zero) continue;
    printf("%s\n", d.get_info<sycl::info::device::name>().c_str());
    printf("  local_mem_size=%llu KB\n", d.get_info<sycl::info::device::local_mem_size>()/1024);
  }
  return 0;
}
