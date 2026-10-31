#include "ffn_chip_kernel.hpp"
using namespace sycl;
template event ffnc::launch_ffn_chip<16,false>(queue&, const half*, const half*, const half*, float*, int, int, const void*, const float*, bool, bool, bool, bool, int, int);
