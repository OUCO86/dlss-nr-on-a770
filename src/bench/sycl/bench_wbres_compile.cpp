// compile-check the resident kernel (force instantiation, no run).
#include "window_block_resident.hpp"
int main(){
  sycl::queue q;
  auto e = wbres::launch_resident(q, nullptr, true, nullptr, nullptr, nullptr,
                                  nullptr, nullptr, nullptr, 1u,8u,8u,1u,0u,0u,1u,true);
  (void)e; return 0;
}
