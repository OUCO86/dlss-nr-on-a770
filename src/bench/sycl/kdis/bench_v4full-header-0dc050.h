// This is auto-generated SYCL integration header.

#include <sycl/detail/defines_elementary.hpp>
#include <sycl/detail/kernel_desc.hpp>
#include <sycl/ext/oneapi/experimental/free_function_traits.hpp>
#include <sycl/access/access.hpp>

#ifndef SYCL_LANGUAGE_VERSION
#define SYCL_LANGUAGE_VERSION 202012L
#endif //SYCL_LANGUAGE_VERSION

// Forward declarations of templated kernel function types:

namespace sycl {
inline namespace _V1 {
namespace detail {
// names of all kernels defined in the corresponding source
static constexpr
const char* const kernel_names[] = {
  "_ZTSZZN4s8v8L4gemmERN4sycl3_V15queueEPKaS5_PiiiiENKUlRNS1_7handlerEE_clES8_EUlNS1_7nd_itemILi1EEEE_",
  "_ZTSZZN4s8v8L6gemm_bERN4sycl3_V15queueEPKaS5_PiiiiiENKUlRNS1_7handlerEE_clES8_EUlNS1_7nd_itemILi1EEEE_",
  "_ZTSZZN4s8v8L8gemm32_bERN4sycl3_V15queueEPKaS5_PiiiiiENKUlRNS1_7handlerEE_clES8_EUlNS1_7nd_itemILi1EEEE_",
  "_ZTSZZN4s8v8L6gemm32ERN4sycl3_V15queueEPKaS5_PiiiiENKUlRNS1_7handlerEE_clES8_EUlNS1_7nd_itemILi1EEEE_",
  "_ZTSZZN4s8v8L10gemm_b_pubERN4sycl3_V15queueEPKaS5_PvPKfS8_iiiiiyjjjbjENKUlRNS1_7handlerEE_clESA_EUlNS1_7nd_itemILi1EEEE_",
  "_ZTSZZN4s8v8L10gemm_b_resERN4sycl3_V15queueEPKaS5_PvPKfS8_PKvS8_iiiibbjENKUlRNS1_7handlerEE_clESC_EUlNS1_7nd_itemILi1EEEE_",
  "_ZTSZZN4s8v8L17gemm_b_res_windowERN4sycl3_V15queueEPKaS5_PvPKfS8_PKvS8_iiiibbjjjjjjENKUlRNS1_7handlerEE_clESC_EUlNS1_7nd_itemILi1EEEE_",
  "_ZTSN4sycl3_V16detail18RoundedRangeKernelINS0_4itemILi1ELb1EEELi1EZZN5f16v1L4gemmERNS0_5queueEPKNS1_9half_impl4halfESB_PfiiiENKUlRNS0_7handlerEE_clESE_EUlS4_E_EE",
  "_ZTSZZN5f16v1L4gemmERN4sycl3_V15queueEPKNS1_6detail9half_impl4halfES8_PfiiiENKUlRNS1_7handlerEE_clESB_EUlNS1_4itemILi1ELb1EEEE_",
  "_ZTSN4sycl3_V16detail18RoundedRangeKernelINS0_4itemILi1ELb1EEELi1EZZN5f16v1L6gemm_bERNS0_5queueEPKNS1_9half_impl4halfESB_PfiiiiENKUlRNS0_7handlerEE_clESE_EUlS4_E_EE",
  "_ZTSZZN5f16v1L6gemm_bERN4sycl3_V15queueEPKNS1_6detail9half_impl4halfES8_PfiiiiENKUlRNS1_7handlerEE_clESB_EUlNS1_4itemILi1ELb1EEEE_",
  "_ZTSN4sycl3_V16detail18RoundedRangeKernelINS0_4itemILi1ELb1EEELi1EZZN5f16v1L18gemm_b_merge_scaleERNS0_5queueEPKNS1_9half_impl4halfESB_PS9_PKfiiiiENKUlRNS0_7handlerEE_clESG_EUlS4_E_EE",
  "_ZTSZZN5f16v1L18gemm_b_merge_scaleERN4sycl3_V15queueEPKNS1_6detail9half_impl4halfES8_PS6_PKfiiiiENKUlRNS1_7handlerEE_clESD_EUlNS1_4itemILi1ELb1EEEE_",
  "_ZTSN4sycl3_V16detail18RoundedRangeKernelINS0_4itemILi1ELb1EEELi1EZZN5f16v1L14gemm_b_pub_f16ERNS0_5queueEPKNS1_9half_impl4halfESB_PviiiiijbyyjjENKUlRNS0_7handlerEE_clESE_EUlS4_E_EE",
  "_ZTSZZN5f16v1L14gemm_b_pub_f16ERN4sycl3_V15queueEPKNS1_6detail9half_impl4halfES8_PviiiiijbyyjjENKUlRNS1_7handlerEE_clESB_EUlNS1_4itemILi1ELb1EEEE_",
  "_ZTSN4sycl3_V16detail18RoundedRangeKernelINS0_4itemILi1ELb1EEELi1EZZN5f16v1L13gemm_dual_pubERNS0_5queueEPKNS1_9half_impl4halfESB_PfPS9_iiiiENKUlRNS0_7handlerEE_clESF_EUlS4_E_EE",
  "_ZTSZZN5f16v1L13gemm_dual_pubERN4sycl3_V15queueEPKNS1_6detail9half_impl4halfES8_PfPS6_iiiiENKUlRNS1_7handlerEE_clESC_EUlNS1_4itemILi1ELb1EEEE_",
  "_ZTSN4sycl3_V16detail18RoundedRangeKernelINS0_4itemILi1ELb1EEELi1EZZN5f16v1L8gemm_pubERNS0_5queueEPKNS1_9half_impl4halfESB_PS9_iiiijENKUlRNS0_7handlerEE_clESE_EUlS4_E_EE",
  "_ZTSZZN5f16v1L8gemm_pubERN4sycl3_V15queueEPKNS1_6detail9half_impl4halfES8_PS6_iiiijENKUlRNS1_7handlerEE_clESB_EUlNS1_4itemILi1ELb1EEEE_",
  "_ZTSN4sycl3_V16detail18RoundedRangeKernelINS0_4itemILi1ELb1EEELi1EZZN5f16v1L13gemm_pub_pa16ERNS0_5queueEPKNS1_9half_impl4halfESB_PS9_iiiijENKUlRNS0_7handlerEE_clESE_EUlS4_E_EE",
  "_ZTSZZN5f16v1L13gemm_pub_pa16ERN4sycl3_V15queueEPKNS1_6detail9half_impl4halfES8_PS6_iiiijENKUlRNS1_7handlerEE_clESB_EUlNS1_4itemILi1ELb1EEEE_",
  "_ZTSN4sycl3_V16detail18RoundedRangeKernelINS0_4itemILi1ELb1EEELi1EZZN5f16v1L8gemm_resERNS0_5queueEPKNS1_9half_impl4halfESB_PvPKfSE_iiiibjENKUlRNS0_7handlerEE_clESG_EUlS4_E_EE",
  "_ZTSZZN5f16v1L8gemm_resERN4sycl3_V15queueEPKNS1_6detail9half_impl4halfES8_PvPKfSB_iiiibjENKUlRNS1_7handlerEE_clESD_EUlNS1_4itemILi1ELb1EEEE_",
  "_ZTSZZN6wbmega11launch_leg1ERN4sycl3_V15queueEPKvbPKNS1_6detail9half_impl4halfEPS8_SB_SB_jjjjjjPKfENKUlRNS1_7handlerEE_clESF_EUlNS1_7nd_itemILi1EEEE_",
  "_ZTSZZN6wbmega15normalize_esimdERN4sycl3_V15queueEPKfPNS1_6detail9half_impl4halfES9_S9_S5_jjjENKUlRNS1_7handlerEE_clESB_EUlNS1_7nd_itemILi1EEEE_",
  "_ZTSZZN6wbmega14qkv_norm_esimdERN4sycl3_V15queueEPiPKfS6_S6_jjjjENKUlRNS1_7handlerEE_clES8_EUlNS1_7nd_itemILi1EEEE_",
  "_ZTSZZN6wbmega14launch_mega256ERN4sycl3_V15queueEPKvbPKNS1_6detail9half_impl4halfEPS8_SB_SB_jjjjjjPKfENKUlRNS1_7handlerEE_clESF_EUlNS1_7nd_itemILi1EEEE_",
  "_ZTSZZN6wbmega11launch_fullERN4sycl3_V15queueEPKvbPKNS1_6detail9half_impl4halfESA_PS8_PfPKfSE_SE_jjjjjjjbjSB_ENKUlRNS1_7handlerEE_clESG_EUlNS1_7nd_itemILi1EEEE_",
  "_ZTSZZN6wbmega22qkv_norm_scatter_esimdERN4sycl3_V15queueEPKiPNS1_6detail9half_impl4halfES9_S9_PKfSB_SB_jjjjjENKUlRNS1_7handlerEE_clESD_EUlNS1_7nd_itemILi1EEEE_",
  "_ZTSN4sycl3_V16detail18RoundedRangeKernelINS0_4itemILi1ELb1EEELi1EZN6wbmega19qkv_norm_scatter_v2ERNS0_5queueEPKiPNS1_9half_impl4halfESC_SC_PKfSE_SE_jjjjjEUlS4_E_EE",
  "_ZTSZN6wbmega19qkv_norm_scatter_v2ERN4sycl3_V15queueEPKiPNS1_6detail9half_impl4halfES9_S9_PKfSB_SB_jjjjjEUlNS1_4itemILi1ELb1EEEE_",
  "_ZTSZZN6wbmega26qkv_norm_scatter_vit_esimdERN4sycl3_V15queueEPKiPNS1_6detail9half_impl4halfES9_S9_PKfSB_SB_jjjjjSB_PfENKUlRNS1_7handlerEE_clESE_EUlNS1_7nd_itemILi1EEEE_",
  "_ZTSZZN4wbv39launch_v3ERN4sycl3_V15queueEPKvbPKNS1_6detail9half_impl4halfESA_PS8_PfPKfSE_SE_jjjjjjjbjSB_ENKUlRNS1_7handlerEE_clESG_EUlNS1_7nd_itemILi1EEEE_",
  "_ZTSZZ13launch_v4fullILi0EEN4sycl3_V15eventERNS1_5queueEPKvbPKNS1_6detail9half_impl4halfESB_PS9_PfPKfSF_SF_jjjjjjjbjSC_ENKUlRNS1_7handlerEE_clESH_EUlNS1_7nd_itemILi1EEEE_",
  "_ZTSZZ13launch_v4fullILi8EEN4sycl3_V15eventERNS1_5queueEPKvbPKNS1_6detail9half_impl4halfESB_PS9_PfPKfSF_SF_jjjjjjjbjSC_ENKUlRNS1_7handlerEE_clESH_EUlNS1_7nd_itemILi1EEEE_",
  "_ZTSZZ13launch_v4fullILi32EEN4sycl3_V15eventERNS1_5queueEPKvbPKNS1_6detail9half_impl4halfESB_PS9_PfPKfSF_SF_jjjjjjjbjSC_ENKUlRNS1_7handlerEE_clESH_EUlNS1_7nd_itemILi1EEEE_",
  "",
};

static constexpr unsigned kernel_args_sizes[] = {5, 9, 9, 5, 17, 13, 18, 2, 6, 2, 10, 2, 11, 2, 15, 2, 8, 2, 8, 2, 7, 2, 11, 12, 7, 7, 12, 18, 11, 2, 11, 13, 18, 19, 19, 19, 4294967295, 
};

// array representing signatures of all kernels defined in the
// corresponding source
static constexpr
const kernel_param_desc_t kernel_signatures[] = {
  //--- _ZTSZZN4s8v8L4gemmERN4sycl3_V15queueEPKaS5_PiiiiENKUlRNS1_7handlerEE_clES8_EUlNS1_7nd_itemILi1EEEE_
  { kernel_param_kind_t::kind_std_layout, 4, 0 },
  { kernel_param_kind_t::kind_pointer, 8, 8 },
  { kernel_param_kind_t::kind_std_layout, 4, 16 },
  { kernel_param_kind_t::kind_pointer, 8, 24 },
  { kernel_param_kind_t::kind_pointer, 8, 32 },

  //--- _ZTSZZN4s8v8L6gemm_bERN4sycl3_V15queueEPKaS5_PiiiiiENKUlRNS1_7handlerEE_clES8_EUlNS1_7nd_itemILi1EEEE_
  { kernel_param_kind_t::kind_std_layout, 4, 0 },
  { kernel_param_kind_t::kind_std_layout, 4, 4 },
  { kernel_param_kind_t::kind_pointer, 8, 8 },
  { kernel_param_kind_t::kind_std_layout, 8, 16 },
  { kernel_param_kind_t::kind_pointer, 8, 24 },
  { kernel_param_kind_t::kind_std_layout, 8, 32 },
  { kernel_param_kind_t::kind_pointer, 8, 40 },
  { kernel_param_kind_t::kind_std_layout, 8, 48 },
  { kernel_param_kind_t::kind_std_layout, 4, 56 },

  //--- _ZTSZZN4s8v8L8gemm32_bERN4sycl3_V15queueEPKaS5_PiiiiiENKUlRNS1_7handlerEE_clES8_EUlNS1_7nd_itemILi1EEEE_
  { kernel_param_kind_t::kind_std_layout, 4, 0 },
  { kernel_param_kind_t::kind_std_layout, 4, 4 },
  { kernel_param_kind_t::kind_pointer, 8, 8 },
  { kernel_param_kind_t::kind_std_layout, 8, 16 },
  { kernel_param_kind_t::kind_pointer, 8, 24 },
  { kernel_param_kind_t::kind_std_layout, 8, 32 },
  { kernel_param_kind_t::kind_pointer, 8, 40 },
  { kernel_param_kind_t::kind_std_layout, 8, 48 },
  { kernel_param_kind_t::kind_std_layout, 4, 56 },

  //--- _ZTSZZN4s8v8L6gemm32ERN4sycl3_V15queueEPKaS5_PiiiiENKUlRNS1_7handlerEE_clES8_EUlNS1_7nd_itemILi1EEEE_
  { kernel_param_kind_t::kind_std_layout, 4, 0 },
  { kernel_param_kind_t::kind_pointer, 8, 8 },
  { kernel_param_kind_t::kind_std_layout, 4, 16 },
  { kernel_param_kind_t::kind_pointer, 8, 24 },
  { kernel_param_kind_t::kind_pointer, 8, 32 },

  //--- _ZTSZZN4s8v8L10gemm_b_pubERN4sycl3_V15queueEPKaS5_PvPKfS8_iiiiiyjjjbjENKUlRNS1_7handlerEE_clESA_EUlNS1_7nd_itemILi1EEEE_
  { kernel_param_kind_t::kind_std_layout, 4, 0 },
  { kernel_param_kind_t::kind_std_layout, 4, 4 },
  { kernel_param_kind_t::kind_pointer, 8, 8 },
  { kernel_param_kind_t::kind_std_layout, 8, 16 },
  { kernel_param_kind_t::kind_pointer, 8, 24 },
  { kernel_param_kind_t::kind_std_layout, 8, 32 },
  { kernel_param_kind_t::kind_std_layout, 4, 40 },
  { kernel_param_kind_t::kind_pointer, 8, 48 },
  { kernel_param_kind_t::kind_std_layout, 4, 56 },
  { kernel_param_kind_t::kind_pointer, 8, 64 },
  { kernel_param_kind_t::kind_std_layout, 4, 72 },
  { kernel_param_kind_t::kind_std_layout, 4, 76 },
  { kernel_param_kind_t::kind_std_layout, 4, 80 },
  { kernel_param_kind_t::kind_std_layout, 8, 88 },
  { kernel_param_kind_t::kind_std_layout, 4, 96 },
  { kernel_param_kind_t::kind_std_layout, 1, 100 },
  { kernel_param_kind_t::kind_pointer, 8, 104 },

  //--- _ZTSZZN4s8v8L10gemm_b_resERN4sycl3_V15queueEPKaS5_PvPKfS8_PKvS8_iiiibbjENKUlRNS1_7handlerEE_clESC_EUlNS1_7nd_itemILi1EEEE_
  { kernel_param_kind_t::kind_std_layout, 4, 0 },
  { kernel_param_kind_t::kind_pointer, 8, 8 },
  { kernel_param_kind_t::kind_std_layout, 4, 16 },
  { kernel_param_kind_t::kind_pointer, 8, 24 },
  { kernel_param_kind_t::kind_pointer, 8, 32 },
  { kernel_param_kind_t::kind_pointer, 8, 40 },
  { kernel_param_kind_t::kind_std_layout, 4, 48 },
  { kernel_param_kind_t::kind_pointer, 8, 56 },
  { kernel_param_kind_t::kind_std_layout, 1, 64 },
  { kernel_param_kind_t::kind_pointer, 8, 72 },
  { kernel_param_kind_t::kind_std_layout, 4, 80 },
  { kernel_param_kind_t::kind_std_layout, 1, 84 },
  { kernel_param_kind_t::kind_pointer, 8, 88 },

  //--- _ZTSZZN4s8v8L17gemm_b_res_windowERN4sycl3_V15queueEPKaS5_PvPKfS8_PKvS8_iiiibbjjjjjjENKUlRNS1_7handlerEE_clESC_EUlNS1_7nd_itemILi1EEEE_
  { kernel_param_kind_t::kind_std_layout, 4, 0 },
  { kernel_param_kind_t::kind_pointer, 8, 8 },
  { kernel_param_kind_t::kind_std_layout, 4, 16 },
  { kernel_param_kind_t::kind_pointer, 8, 24 },
  { kernel_param_kind_t::kind_pointer, 8, 32 },
  { kernel_param_kind_t::kind_pointer, 8, 40 },
  { kernel_param_kind_t::kind_std_layout, 4, 48 },
  { kernel_param_kind_t::kind_std_layout, 4, 52 },
  { kernel_param_kind_t::kind_std_layout, 4, 56 },
  { kernel_param_kind_t::kind_std_layout, 4, 60 },
  { kernel_param_kind_t::kind_std_layout, 4, 64 },
  { kernel_param_kind_t::kind_std_layout, 4, 68 },
  { kernel_param_kind_t::kind_pointer, 8, 72 },
  { kernel_param_kind_t::kind_std_layout, 1, 80 },
  { kernel_param_kind_t::kind_pointer, 8, 88 },
  { kernel_param_kind_t::kind_std_layout, 4, 96 },
  { kernel_param_kind_t::kind_std_layout, 1, 100 },
  { kernel_param_kind_t::kind_pointer, 8, 104 },

  //--- _ZTSN4sycl3_V16detail18RoundedRangeKernelINS0_4itemILi1ELb1EEELi1EZZN5f16v1L4gemmERNS0_5queueEPKNS1_9half_impl4halfESB_PfiiiENKUlRNS0_7handlerEE_clESE_EUlS4_E_EE
  { kernel_param_kind_t::kind_std_layout, 8, 0 },
  { kernel_param_kind_t::kind_std_layout, 40, 8 },

  //--- _ZTSZZN5f16v1L4gemmERN4sycl3_V15queueEPKNS1_6detail9half_impl4halfES8_PfiiiENKUlRNS1_7handlerEE_clESB_EUlNS1_4itemILi1ELb1EEEE_
  { kernel_param_kind_t::kind_std_layout, 4, 0 },
  { kernel_param_kind_t::kind_std_layout, 4, 4 },
  { kernel_param_kind_t::kind_pointer, 8, 8 },
  { kernel_param_kind_t::kind_pointer, 8, 16 },
  { kernel_param_kind_t::kind_pointer, 8, 24 },
  { kernel_param_kind_t::kind_std_layout, 4, 32 },

  //--- _ZTSN4sycl3_V16detail18RoundedRangeKernelINS0_4itemILi1ELb1EEELi1EZZN5f16v1L6gemm_bERNS0_5queueEPKNS1_9half_impl4halfESB_PfiiiiENKUlRNS0_7handlerEE_clESE_EUlS4_E_EE
  { kernel_param_kind_t::kind_std_layout, 8, 0 },
  { kernel_param_kind_t::kind_std_layout, 64, 8 },

  //--- _ZTSZZN5f16v1L6gemm_bERN4sycl3_V15queueEPKNS1_6detail9half_impl4halfES8_PfiiiiENKUlRNS1_7handlerEE_clESB_EUlNS1_4itemILi1ELb1EEEE_
  { kernel_param_kind_t::kind_std_layout, 4, 0 },
  { kernel_param_kind_t::kind_std_layout, 4, 4 },
  { kernel_param_kind_t::kind_pointer, 8, 8 },
  { kernel_param_kind_t::kind_std_layout, 8, 16 },
  { kernel_param_kind_t::kind_pointer, 8, 24 },
  { kernel_param_kind_t::kind_std_layout, 8, 32 },
  { kernel_param_kind_t::kind_pointer, 8, 40 },
  { kernel_param_kind_t::kind_std_layout, 8, 48 },
  { kernel_param_kind_t::kind_std_layout, 4, 56 },
  { kernel_param_kind_t::kind_std_layout, 4, 60 },

  //--- _ZTSN4sycl3_V16detail18RoundedRangeKernelINS0_4itemILi1ELb1EEELi1EZZN5f16v1L18gemm_b_merge_scaleERNS0_5queueEPKNS1_9half_impl4halfESB_PS9_PKfiiiiENKUlRNS0_7handlerEE_clESG_EUlS4_E_EE
  { kernel_param_kind_t::kind_std_layout, 8, 0 },
  { kernel_param_kind_t::kind_std_layout, 72, 8 },

  //--- _ZTSZZN5f16v1L18gemm_b_merge_scaleERN4sycl3_V15queueEPKNS1_6detail9half_impl4halfES8_PS6_PKfiiiiENKUlRNS1_7handlerEE_clESD_EUlNS1_4itemILi1ELb1EEEE_
  { kernel_param_kind_t::kind_std_layout, 4, 0 },
  { kernel_param_kind_t::kind_std_layout, 4, 4 },
  { kernel_param_kind_t::kind_pointer, 8, 8 },
  { kernel_param_kind_t::kind_std_layout, 8, 16 },
  { kernel_param_kind_t::kind_pointer, 8, 24 },
  { kernel_param_kind_t::kind_std_layout, 8, 32 },
  { kernel_param_kind_t::kind_std_layout, 4, 40 },
  { kernel_param_kind_t::kind_pointer, 8, 48 },
  { kernel_param_kind_t::kind_std_layout, 4, 56 },
  { kernel_param_kind_t::kind_std_layout, 4, 60 },
  { kernel_param_kind_t::kind_pointer, 8, 64 },

  //--- _ZTSN4sycl3_V16detail18RoundedRangeKernelINS0_4itemILi1ELb1EEELi1EZZN5f16v1L14gemm_b_pub_f16ERNS0_5queueEPKNS1_9half_impl4halfESB_PviiiiijbyyjjENKUlRNS0_7handlerEE_clESE_EUlS4_E_EE
  { kernel_param_kind_t::kind_std_layout, 8, 0 },
  { kernel_param_kind_t::kind_std_layout, 96, 8 },

  //--- _ZTSZZN5f16v1L14gemm_b_pub_f16ERN4sycl3_V15queueEPKNS1_6detail9half_impl4halfES8_PviiiiijbyyjjENKUlRNS1_7handlerEE_clESB_EUlNS1_4itemILi1ELb1EEEE_
  { kernel_param_kind_t::kind_std_layout, 4, 0 },
  { kernel_param_kind_t::kind_std_layout, 4, 4 },
  { kernel_param_kind_t::kind_pointer, 8, 8 },
  { kernel_param_kind_t::kind_std_layout, 8, 16 },
  { kernel_param_kind_t::kind_pointer, 8, 24 },
  { kernel_param_kind_t::kind_std_layout, 8, 32 },
  { kernel_param_kind_t::kind_std_layout, 4, 40 },
  { kernel_param_kind_t::kind_std_layout, 8, 48 },
  { kernel_param_kind_t::kind_std_layout, 8, 56 },
  { kernel_param_kind_t::kind_std_layout, 4, 64 },
  { kernel_param_kind_t::kind_std_layout, 4, 68 },
  { kernel_param_kind_t::kind_std_layout, 4, 72 },
  { kernel_param_kind_t::kind_std_layout, 1, 76 },
  { kernel_param_kind_t::kind_pointer, 8, 80 },
  { kernel_param_kind_t::kind_pointer, 8, 88 },

  //--- _ZTSN4sycl3_V16detail18RoundedRangeKernelINS0_4itemILi1ELb1EEELi1EZZN5f16v1L13gemm_dual_pubERNS0_5queueEPKNS1_9half_impl4halfESB_PfPS9_iiiiENKUlRNS0_7handlerEE_clESF_EUlS4_E_EE
  { kernel_param_kind_t::kind_std_layout, 8, 0 },
  { kernel_param_kind_t::kind_std_layout, 56, 8 },

  //--- _ZTSZZN5f16v1L13gemm_dual_pubERN4sycl3_V15queueEPKNS1_6detail9half_impl4halfES8_PfPS6_iiiiENKUlRNS1_7handlerEE_clESC_EUlNS1_4itemILi1ELb1EEEE_
  { kernel_param_kind_t::kind_std_layout, 4, 0 },
  { kernel_param_kind_t::kind_std_layout, 4, 4 },
  { kernel_param_kind_t::kind_pointer, 8, 8 },
  { kernel_param_kind_t::kind_pointer, 8, 16 },
  { kernel_param_kind_t::kind_pointer, 8, 24 },
  { kernel_param_kind_t::kind_std_layout, 4, 32 },
  { kernel_param_kind_t::kind_pointer, 8, 40 },
  { kernel_param_kind_t::kind_std_layout, 4, 48 },

  //--- _ZTSN4sycl3_V16detail18RoundedRangeKernelINS0_4itemILi1ELb1EEELi1EZZN5f16v1L8gemm_pubERNS0_5queueEPKNS1_9half_impl4halfESB_PS9_iiiijENKUlRNS0_7handlerEE_clESE_EUlS4_E_EE
  { kernel_param_kind_t::kind_std_layout, 8, 0 },
  { kernel_param_kind_t::kind_std_layout, 48, 8 },

  //--- _ZTSZZN5f16v1L8gemm_pubERN4sycl3_V15queueEPKNS1_6detail9half_impl4halfES8_PS6_iiiijENKUlRNS1_7handlerEE_clESB_EUlNS1_4itemILi1ELb1EEEE_
  { kernel_param_kind_t::kind_std_layout, 4, 0 },
  { kernel_param_kind_t::kind_std_layout, 4, 4 },
  { kernel_param_kind_t::kind_pointer, 8, 8 },
  { kernel_param_kind_t::kind_pointer, 8, 16 },
  { kernel_param_kind_t::kind_pointer, 8, 24 },
  { kernel_param_kind_t::kind_std_layout, 4, 32 },
  { kernel_param_kind_t::kind_std_layout, 4, 36 },
  { kernel_param_kind_t::kind_std_layout, 4, 40 },

  //--- _ZTSN4sycl3_V16detail18RoundedRangeKernelINS0_4itemILi1ELb1EEELi1EZZN5f16v1L13gemm_pub_pa16ERNS0_5queueEPKNS1_9half_impl4halfESB_PS9_iiiijENKUlRNS0_7handlerEE_clESE_EUlS4_E_EE
  { kernel_param_kind_t::kind_std_layout, 8, 0 },
  { kernel_param_kind_t::kind_std_layout, 40, 8 },

  //--- _ZTSZZN5f16v1L13gemm_pub_pa16ERN4sycl3_V15queueEPKNS1_6detail9half_impl4halfES8_PS6_iiiijENKUlRNS1_7handlerEE_clESB_EUlNS1_4itemILi1ELb1EEEE_
  { kernel_param_kind_t::kind_std_layout, 4, 0 },
  { kernel_param_kind_t::kind_std_layout, 4, 4 },
  { kernel_param_kind_t::kind_pointer, 8, 8 },
  { kernel_param_kind_t::kind_pointer, 8, 16 },
  { kernel_param_kind_t::kind_pointer, 8, 24 },
  { kernel_param_kind_t::kind_std_layout, 4, 32 },
  { kernel_param_kind_t::kind_std_layout, 4, 36 },

  //--- _ZTSN4sycl3_V16detail18RoundedRangeKernelINS0_4itemILi1ELb1EEELi1EZZN5f16v1L8gemm_resERNS0_5queueEPKNS1_9half_impl4halfESB_PvPKfSE_iiiibjENKUlRNS0_7handlerEE_clESG_EUlS4_E_EE
  { kernel_param_kind_t::kind_std_layout, 8, 0 },
  { kernel_param_kind_t::kind_std_layout, 72, 8 },

  //--- _ZTSZZN5f16v1L8gemm_resERN4sycl3_V15queueEPKNS1_6detail9half_impl4halfES8_PvPKfSB_iiiibjENKUlRNS1_7handlerEE_clESD_EUlNS1_4itemILi1ELb1EEEE_
  { kernel_param_kind_t::kind_std_layout, 4, 0 },
  { kernel_param_kind_t::kind_std_layout, 4, 4 },
  { kernel_param_kind_t::kind_pointer, 8, 8 },
  { kernel_param_kind_t::kind_pointer, 8, 16 },
  { kernel_param_kind_t::kind_pointer, 8, 24 },
  { kernel_param_kind_t::kind_std_layout, 4, 32 },
  { kernel_param_kind_t::kind_pointer, 8, 40 },
  { kernel_param_kind_t::kind_std_layout, 4, 48 },
  { kernel_param_kind_t::kind_std_layout, 4, 52 },
  { kernel_param_kind_t::kind_std_layout, 1, 56 },
  { kernel_param_kind_t::kind_pointer, 8, 64 },

  //--- _ZTSZZN6wbmega11launch_leg1ERN4sycl3_V15queueEPKvbPKNS1_6detail9half_impl4halfEPS8_SB_SB_jjjjjjPKfENKUlRNS1_7handlerEE_clESF_EUlNS1_7nd_itemILi1EEEE_
  { kernel_param_kind_t::kind_std_layout, 4, 0 },
  { kernel_param_kind_t::kind_std_layout, 4, 4 },
  { kernel_param_kind_t::kind_std_layout, 4, 8 },
  { kernel_param_kind_t::kind_std_layout, 4, 12 },
  { kernel_param_kind_t::kind_std_layout, 4, 16 },
  { kernel_param_kind_t::kind_std_layout, 1, 20 },
  { kernel_param_kind_t::kind_pointer, 8, 24 },
  { kernel_param_kind_t::kind_pointer, 8, 32 },
  { kernel_param_kind_t::kind_pointer, 8, 40 },
  { kernel_param_kind_t::kind_pointer, 8, 48 },
  { kernel_param_kind_t::kind_pointer, 8, 56 },
  { kernel_param_kind_t::kind_pointer, 8, 64 },

  //--- _ZTSZZN6wbmega15normalize_esimdERN4sycl3_V15queueEPKfPNS1_6detail9half_impl4halfES9_S9_S5_jjjENKUlRNS1_7handlerEE_clESB_EUlNS1_7nd_itemILi1EEEE_
  { kernel_param_kind_t::kind_pointer, 8, 0 },
  { kernel_param_kind_t::kind_std_layout, 4, 8 },
  { kernel_param_kind_t::kind_std_layout, 4, 12 },
  { kernel_param_kind_t::kind_pointer, 8, 16 },
  { kernel_param_kind_t::kind_pointer, 8, 24 },
  { kernel_param_kind_t::kind_pointer, 8, 32 },
  { kernel_param_kind_t::kind_pointer, 8, 40 },

  //--- _ZTSZZN6wbmega14qkv_norm_esimdERN4sycl3_V15queueEPiPKfS6_S6_jjjjENKUlRNS1_7handlerEE_clES8_EUlNS1_7nd_itemILi1EEEE_
  { kernel_param_kind_t::kind_std_layout, 4, 0 },
  { kernel_param_kind_t::kind_std_layout, 4, 4 },
  { kernel_param_kind_t::kind_pointer, 8, 8 },
  { kernel_param_kind_t::kind_std_layout, 4, 16 },
  { kernel_param_kind_t::kind_pointer, 8, 24 },
  { kernel_param_kind_t::kind_pointer, 8, 32 },
  { kernel_param_kind_t::kind_pointer, 8, 40 },

  //--- _ZTSZZN6wbmega14launch_mega256ERN4sycl3_V15queueEPKvbPKNS1_6detail9half_impl4halfEPS8_SB_SB_jjjjjjPKfENKUlRNS1_7handlerEE_clESF_EUlNS1_7nd_itemILi1EEEE_
  { kernel_param_kind_t::kind_std_layout, 4, 0 },
  { kernel_param_kind_t::kind_std_layout, 4, 4 },
  { kernel_param_kind_t::kind_std_layout, 4, 8 },
  { kernel_param_kind_t::kind_std_layout, 4, 12 },
  { kernel_param_kind_t::kind_std_layout, 4, 16 },
  { kernel_param_kind_t::kind_std_layout, 1, 20 },
  { kernel_param_kind_t::kind_pointer, 8, 24 },
  { kernel_param_kind_t::kind_pointer, 8, 32 },
  { kernel_param_kind_t::kind_pointer, 8, 40 },
  { kernel_param_kind_t::kind_pointer, 8, 48 },
  { kernel_param_kind_t::kind_pointer, 8, 56 },
  { kernel_param_kind_t::kind_pointer, 8, 64 },

  //--- _ZTSZZN6wbmega11launch_fullERN4sycl3_V15queueEPKvbPKNS1_6detail9half_impl4halfESA_PS8_PfPKfSE_SE_jjjjjjjbjSB_ENKUlRNS1_7handlerEE_clESG_EUlNS1_7nd_itemILi1EEEE_
  { kernel_param_kind_t::kind_std_layout, 4, 0 },
  { kernel_param_kind_t::kind_std_layout, 4, 4 },
  { kernel_param_kind_t::kind_std_layout, 4, 8 },
  { kernel_param_kind_t::kind_std_layout, 4, 12 },
  { kernel_param_kind_t::kind_std_layout, 4, 16 },
  { kernel_param_kind_t::kind_std_layout, 1, 20 },
  { kernel_param_kind_t::kind_pointer, 8, 24 },
  { kernel_param_kind_t::kind_pointer, 8, 32 },
  { kernel_param_kind_t::kind_pointer, 8, 40 },
  { kernel_param_kind_t::kind_pointer, 8, 48 },
  { kernel_param_kind_t::kind_std_layout, 4, 56 },
  { kernel_param_kind_t::kind_pointer, 8, 64 },
  { kernel_param_kind_t::kind_pointer, 8, 72 },
  { kernel_param_kind_t::kind_pointer, 8, 80 },
  { kernel_param_kind_t::kind_std_layout, 4, 88 },
  { kernel_param_kind_t::kind_std_layout, 1, 92 },
  { kernel_param_kind_t::kind_pointer, 8, 96 },
  { kernel_param_kind_t::kind_pointer, 8, 104 },

  //--- _ZTSZZN6wbmega22qkv_norm_scatter_esimdERN4sycl3_V15queueEPKiPNS1_6detail9half_impl4halfES9_S9_PKfSB_SB_jjjjjENKUlRNS1_7handlerEE_clESD_EUlNS1_7nd_itemILi1EEEE_
  { kernel_param_kind_t::kind_std_layout, 4, 0 },
  { kernel_param_kind_t::kind_std_layout, 4, 4 },
  { kernel_param_kind_t::kind_pointer, 8, 8 },
  { kernel_param_kind_t::kind_std_layout, 4, 16 },
  { kernel_param_kind_t::kind_pointer, 8, 24 },
  { kernel_param_kind_t::kind_pointer, 8, 32 },
  { kernel_param_kind_t::kind_pointer, 8, 40 },
  { kernel_param_kind_t::kind_std_layout, 4, 48 },
  { kernel_param_kind_t::kind_pointer, 8, 56 },
  { kernel_param_kind_t::kind_pointer, 8, 64 },
  { kernel_param_kind_t::kind_pointer, 8, 72 },

  //--- _ZTSN4sycl3_V16detail18RoundedRangeKernelINS0_4itemILi1ELb1EEELi1EZN6wbmega19qkv_norm_scatter_v2ERNS0_5queueEPKiPNS1_9half_impl4halfESC_SC_PKfSE_SE_jjjjjEUlS4_E_EE
  { kernel_param_kind_t::kind_std_layout, 8, 0 },
  { kernel_param_kind_t::kind_std_layout, 88, 8 },

  //--- _ZTSZN6wbmega19qkv_norm_scatter_v2ERN4sycl3_V15queueEPKiPNS1_6detail9half_impl4halfES9_S9_PKfSB_SB_jjjjjEUlNS1_4itemILi1ELb1EEEE_
  { kernel_param_kind_t::kind_std_layout, 4, 0 },
  { kernel_param_kind_t::kind_pointer, 8, 8 },
  { kernel_param_kind_t::kind_std_layout, 4, 16 },
  { kernel_param_kind_t::kind_pointer, 8, 24 },
  { kernel_param_kind_t::kind_std_layout, 4, 32 },
  { kernel_param_kind_t::kind_pointer, 8, 40 },
  { kernel_param_kind_t::kind_std_layout, 4, 48 },
  { kernel_param_kind_t::kind_pointer, 8, 56 },
  { kernel_param_kind_t::kind_pointer, 8, 64 },
  { kernel_param_kind_t::kind_pointer, 8, 72 },
  { kernel_param_kind_t::kind_pointer, 8, 80 },

  //--- _ZTSZZN6wbmega26qkv_norm_scatter_vit_esimdERN4sycl3_V15queueEPKiPNS1_6detail9half_impl4halfES9_S9_PKfSB_SB_jjjjjSB_PfENKUlRNS1_7handlerEE_clESE_EUlNS1_7nd_itemILi1EEEE_
  { kernel_param_kind_t::kind_std_layout, 4, 0 },
  { kernel_param_kind_t::kind_std_layout, 4, 4 },
  { kernel_param_kind_t::kind_pointer, 8, 8 },
  { kernel_param_kind_t::kind_std_layout, 4, 16 },
  { kernel_param_kind_t::kind_pointer, 8, 24 },
  { kernel_param_kind_t::kind_pointer, 8, 32 },
  { kernel_param_kind_t::kind_pointer, 8, 40 },
  { kernel_param_kind_t::kind_pointer, 8, 48 },
  { kernel_param_kind_t::kind_pointer, 8, 56 },
  { kernel_param_kind_t::kind_std_layout, 4, 64 },
  { kernel_param_kind_t::kind_pointer, 8, 72 },
  { kernel_param_kind_t::kind_pointer, 8, 80 },
  { kernel_param_kind_t::kind_pointer, 8, 88 },

  //--- _ZTSZZN4wbv39launch_v3ERN4sycl3_V15queueEPKvbPKNS1_6detail9half_impl4halfESA_PS8_PfPKfSE_SE_jjjjjjjbjSB_ENKUlRNS1_7handlerEE_clESG_EUlNS1_7nd_itemILi1EEEE_
  { kernel_param_kind_t::kind_std_layout, 4, 0 },
  { kernel_param_kind_t::kind_std_layout, 4, 4 },
  { kernel_param_kind_t::kind_std_layout, 4, 8 },
  { kernel_param_kind_t::kind_std_layout, 4, 12 },
  { kernel_param_kind_t::kind_std_layout, 4, 16 },
  { kernel_param_kind_t::kind_std_layout, 4, 20 },
  { kernel_param_kind_t::kind_std_layout, 1, 24 },
  { kernel_param_kind_t::kind_pointer, 8, 32 },
  { kernel_param_kind_t::kind_pointer, 8, 40 },
  { kernel_param_kind_t::kind_pointer, 8, 48 },
  { kernel_param_kind_t::kind_pointer, 8, 56 },
  { kernel_param_kind_t::kind_pointer, 8, 64 },
  { kernel_param_kind_t::kind_pointer, 8, 72 },
  { kernel_param_kind_t::kind_pointer, 8, 80 },
  { kernel_param_kind_t::kind_std_layout, 4, 88 },
  { kernel_param_kind_t::kind_std_layout, 1, 92 },
  { kernel_param_kind_t::kind_pointer, 8, 96 },
  { kernel_param_kind_t::kind_pointer, 8, 104 },

  //--- _ZTSZZ13launch_v4fullILi0EEN4sycl3_V15eventERNS1_5queueEPKvbPKNS1_6detail9half_impl4halfESB_PS9_PfPKfSF_SF_jjjjjjjbjSC_ENKUlRNS1_7handlerEE_clESH_EUlNS1_7nd_itemILi1EEEE_
  { kernel_param_kind_t::kind_std_layout, 4, 0 },
  { kernel_param_kind_t::kind_std_layout, 4, 4 },
  { kernel_param_kind_t::kind_std_layout, 4, 8 },
  { kernel_param_kind_t::kind_std_layout, 4, 12 },
  { kernel_param_kind_t::kind_std_layout, 4, 16 },
  { kernel_param_kind_t::kind_std_layout, 4, 20 },
  { kernel_param_kind_t::kind_std_layout, 1, 24 },
  { kernel_param_kind_t::kind_pointer, 8, 32 },
  { kernel_param_kind_t::kind_std_layout, 4, 40 },
  { kernel_param_kind_t::kind_pointer, 8, 48 },
  { kernel_param_kind_t::kind_pointer, 8, 56 },
  { kernel_param_kind_t::kind_pointer, 8, 64 },
  { kernel_param_kind_t::kind_pointer, 8, 72 },
  { kernel_param_kind_t::kind_pointer, 8, 80 },
  { kernel_param_kind_t::kind_pointer, 8, 88 },
  { kernel_param_kind_t::kind_std_layout, 4, 96 },
  { kernel_param_kind_t::kind_std_layout, 1, 100 },
  { kernel_param_kind_t::kind_pointer, 8, 104 },
  { kernel_param_kind_t::kind_pointer, 8, 112 },

  //--- _ZTSZZ13launch_v4fullILi8EEN4sycl3_V15eventERNS1_5queueEPKvbPKNS1_6detail9half_impl4halfESB_PS9_PfPKfSF_SF_jjjjjjjbjSC_ENKUlRNS1_7handlerEE_clESH_EUlNS1_7nd_itemILi1EEEE_
  { kernel_param_kind_t::kind_std_layout, 4, 0 },
  { kernel_param_kind_t::kind_std_layout, 4, 4 },
  { kernel_param_kind_t::kind_std_layout, 4, 8 },
  { kernel_param_kind_t::kind_std_layout, 4, 12 },
  { kernel_param_kind_t::kind_std_layout, 4, 16 },
  { kernel_param_kind_t::kind_std_layout, 4, 20 },
  { kernel_param_kind_t::kind_std_layout, 1, 24 },
  { kernel_param_kind_t::kind_pointer, 8, 32 },
  { kernel_param_kind_t::kind_std_layout, 4, 40 },
  { kernel_param_kind_t::kind_pointer, 8, 48 },
  { kernel_param_kind_t::kind_pointer, 8, 56 },
  { kernel_param_kind_t::kind_pointer, 8, 64 },
  { kernel_param_kind_t::kind_pointer, 8, 72 },
  { kernel_param_kind_t::kind_pointer, 8, 80 },
  { kernel_param_kind_t::kind_pointer, 8, 88 },
  { kernel_param_kind_t::kind_std_layout, 4, 96 },
  { kernel_param_kind_t::kind_std_layout, 1, 100 },
  { kernel_param_kind_t::kind_pointer, 8, 104 },
  { kernel_param_kind_t::kind_pointer, 8, 112 },

  //--- _ZTSZZ13launch_v4fullILi32EEN4sycl3_V15eventERNS1_5queueEPKvbPKNS1_6detail9half_impl4halfESB_PS9_PfPKfSF_SF_jjjjjjjbjSC_ENKUlRNS1_7handlerEE_clESH_EUlNS1_7nd_itemILi1EEEE_
  { kernel_param_kind_t::kind_std_layout, 4, 0 },
  { kernel_param_kind_t::kind_std_layout, 4, 4 },
  { kernel_param_kind_t::kind_std_layout, 4, 8 },
  { kernel_param_kind_t::kind_std_layout, 4, 12 },
  { kernel_param_kind_t::kind_std_layout, 4, 16 },
  { kernel_param_kind_t::kind_std_layout, 4, 20 },
  { kernel_param_kind_t::kind_std_layout, 1, 24 },
  { kernel_param_kind_t::kind_pointer, 8, 32 },
  { kernel_param_kind_t::kind_std_layout, 4, 40 },
  { kernel_param_kind_t::kind_pointer, 8, 48 },
  { kernel_param_kind_t::kind_pointer, 8, 56 },
  { kernel_param_kind_t::kind_pointer, 8, 64 },
  { kernel_param_kind_t::kind_pointer, 8, 72 },
  { kernel_param_kind_t::kind_pointer, 8, 80 },
  { kernel_param_kind_t::kind_pointer, 8, 88 },
  { kernel_param_kind_t::kind_std_layout, 4, 96 },
  { kernel_param_kind_t::kind_std_layout, 1, 100 },
  { kernel_param_kind_t::kind_pointer, 8, 104 },
  { kernel_param_kind_t::kind_pointer, 8, 112 },

  { kernel_param_kind_t::kind_invalid, -987654321, -987654321 }, 
};

} // namespace detail
} // namespace _V1
} // namespace sycl
// Specializations of KernelInfo for kernel function types:
namespace sycl {
inline namespace _V1 {
namespace detail {
template <> struct KernelInfoData<'_', 'Z', 'T', 'S', 'Z', 'Z', 'N', '4', 's', '8', 'v', '8', 'L', '4', 'g', 'e', 'm', 'm', 'E', 'R', 'N', '4', 's', 'y', 'c', 'l', '3', '_', 'V', '1', '5', 'q', 'u', 'e', 'u', 'e', 'E', 'P', 'K', 'a', 'S', '5', '_', 'P', 'i', 'i', 'i', 'i', 'E', 'N', 'K', 'U', 'l', 'R', 'N', 'S', '1', '_', '7', 'h', 'a', 'n', 'd', 'l', 'e', 'r', 'E', 'E', '_', 'c', 'l', 'E', 'S', '8', '_', 'E', 'U', 'l', 'N', 'S', '1', '_', '7', 'n', 'd', '_', 'i', 't', 'e', 'm', 'I', 'L', 'i', '1', 'E', 'E', 'E', 'E', '_'> {
  __SYCL_DLL_LOCAL
  static constexpr const char* getName() { return "_ZTSZZN4s8v8L4gemmERN4sycl3_V15queueEPKaS5_PiiiiENKUlRNS1_7handlerEE_clES8_EUlNS1_7nd_itemILi1EEEE_"; }
  __SYCL_DLL_LOCAL
  static constexpr unsigned getNumParams() { return 5; }
  __SYCL_DLL_LOCAL
  static constexpr const kernel_param_desc_t& getParamDesc(unsigned i) {
    return kernel_signatures[i+0];
  }
  __SYCL_DLL_LOCAL
  static constexpr bool isESIMD() { return 1; }
  __SYCL_DLL_LOCAL
  static constexpr const char* getFileName() {
#ifndef NDEBUG
    return "gemm_s8_v8_kernel.hpp";
#else
    return "";
#endif
  }
  __SYCL_DLL_LOCAL
  static constexpr const char* getFunctionName() {
#ifndef NDEBUG
    return "s8v8::class (lambda)";
#else
    return "";
#endif
  }
  __SYCL_DLL_LOCAL
  static constexpr unsigned getLineNumber() {
#ifndef NDEBUG
    return 64;
#else
    return 0;
#endif
  }
  __SYCL_DLL_LOCAL
  static constexpr unsigned getColumnNumber() {
#ifndef NDEBUG
    return 61;
#else
    return 0;
#endif
  }
  // Returns the size of the kernel object in bytes.
  __SYCL_DLL_LOCAL
  static constexpr long long getKernelSize() { return 40; }
};
template <> struct KernelInfoData<'_', 'Z', 'T', 'S', 'Z', 'Z', 'N', '4', 's', '8', 'v', '8', 'L', '6', 'g', 'e', 'm', 'm', '_', 'b', 'E', 'R', 'N', '4', 's', 'y', 'c', 'l', '3', '_', 'V', '1', '5', 'q', 'u', 'e', 'u', 'e', 'E', 'P', 'K', 'a', 'S', '5', '_', 'P', 'i', 'i', 'i', 'i', 'i', 'E', 'N', 'K', 'U', 'l', 'R', 'N', 'S', '1', '_', '7', 'h', 'a', 'n', 'd', 'l', 'e', 'r', 'E', 'E', '_', 'c', 'l', 'E', 'S', '8', '_', 'E', 'U', 'l', 'N', 'S', '1', '_', '7', 'n', 'd', '_', 'i', 't', 'e', 'm', 'I', 'L', 'i', '1', 'E', 'E', 'E', 'E', '_'> {
  __SYCL_DLL_LOCAL
  static constexpr const char* getName() { return "_ZTSZZN4s8v8L6gemm_bERN4sycl3_V15queueEPKaS5_PiiiiiENKUlRNS1_7handlerEE_clES8_EUlNS1_7nd_itemILi1EEEE_"; }
  __SYCL_DLL_LOCAL
  static constexpr unsigned getNumParams() { return 9; }
  __SYCL_DLL_LOCAL
  static constexpr const kernel_param_desc_t& getParamDesc(unsigned i) {
    return kernel_signatures[i+5];
  }
  __SYCL_DLL_LOCAL
  static constexpr bool isESIMD() { return 1; }
  __SYCL_DLL_LOCAL
  static constexpr const char* getFileName() {
#ifndef NDEBUG
    return "gemm_s8_v8_kernel.hpp";
#else
    return "";
#endif
  }
  __SYCL_DLL_LOCAL
  static constexpr const char* getFunctionName() {
#ifndef NDEBUG
    return "s8v8::class (lambda)";
#else
    return "";
#endif
  }
  __SYCL_DLL_LOCAL
  static constexpr unsigned getLineNumber() {
#ifndef NDEBUG
    return 142;
#else
    return 0;
#endif
  }
  __SYCL_DLL_LOCAL
  static constexpr unsigned getColumnNumber() {
#ifndef NDEBUG
    return 77;
#else
    return 0;
#endif
  }
  // Returns the size of the kernel object in bytes.
  __SYCL_DLL_LOCAL
  static constexpr long long getKernelSize() { return 64; }
};
template <> struct KernelInfoData<'_', 'Z', 'T', 'S', 'Z', 'Z', 'N', '4', 's', '8', 'v', '8', 'L', '8', 'g', 'e', 'm', 'm', '3', '2', '_', 'b', 'E', 'R', 'N', '4', 's', 'y', 'c', 'l', '3', '_', 'V', '1', '5', 'q', 'u', 'e', 'u', 'e', 'E', 'P', 'K', 'a', 'S', '5', '_', 'P', 'i', 'i', 'i', 'i', 'i', 'E', 'N', 'K', 'U', 'l', 'R', 'N', 'S', '1', '_', '7', 'h', 'a', 'n', 'd', 'l', 'e', 'r', 'E', 'E', '_', 'c', 'l', 'E', 'S', '8', '_', 'E', 'U', 'l', 'N', 'S', '1', '_', '7', 'n', 'd', '_', 'i', 't', 'e', 'm', 'I', 'L', 'i', '1', 'E', 'E', 'E', 'E', '_'> {
  __SYCL_DLL_LOCAL
  static constexpr const char* getName() { return "_ZTSZZN4s8v8L8gemm32_bERN4sycl3_V15queueEPKaS5_PiiiiiENKUlRNS1_7handlerEE_clES8_EUlNS1_7nd_itemILi1EEEE_"; }
  __SYCL_DLL_LOCAL
  static constexpr unsigned getNumParams() { return 9; }
  __SYCL_DLL_LOCAL
  static constexpr const kernel_param_desc_t& getParamDesc(unsigned i) {
    return kernel_signatures[i+14];
  }
  __SYCL_DLL_LOCAL
  static constexpr bool isESIMD() { return 1; }
  __SYCL_DLL_LOCAL
  static constexpr const char* getFileName() {
#ifndef NDEBUG
    return "gemm_s8_v8_kernel.hpp";
#else
    return "";
#endif
  }
  __SYCL_DLL_LOCAL
  static constexpr const char* getFunctionName() {
#ifndef NDEBUG
    return "s8v8::class (lambda)";
#else
    return "";
#endif
  }
  __SYCL_DLL_LOCAL
  static constexpr unsigned getLineNumber() {
#ifndef NDEBUG
    return 214;
#else
    return 0;
#endif
  }
  __SYCL_DLL_LOCAL
  static constexpr unsigned getColumnNumber() {
#ifndef NDEBUG
    return 81;
#else
    return 0;
#endif
  }
  // Returns the size of the kernel object in bytes.
  __SYCL_DLL_LOCAL
  static constexpr long long getKernelSize() { return 64; }
};
template <> struct KernelInfoData<'_', 'Z', 'T', 'S', 'Z', 'Z', 'N', '4', 's', '8', 'v', '8', 'L', '6', 'g', 'e', 'm', 'm', '3', '2', 'E', 'R', 'N', '4', 's', 'y', 'c', 'l', '3', '_', 'V', '1', '5', 'q', 'u', 'e', 'u', 'e', 'E', 'P', 'K', 'a', 'S', '5', '_', 'P', 'i', 'i', 'i', 'i', 'E', 'N', 'K', 'U', 'l', 'R', 'N', 'S', '1', '_', '7', 'h', 'a', 'n', 'd', 'l', 'e', 'r', 'E', 'E', '_', 'c', 'l', 'E', 'S', '8', '_', 'E', 'U', 'l', 'N', 'S', '1', '_', '7', 'n', 'd', '_', 'i', 't', 'e', 'm', 'I', 'L', 'i', '1', 'E', 'E', 'E', 'E', '_'> {
  __SYCL_DLL_LOCAL
  static constexpr const char* getName() { return "_ZTSZZN4s8v8L6gemm32ERN4sycl3_V15queueEPKaS5_PiiiiENKUlRNS1_7handlerEE_clES8_EUlNS1_7nd_itemILi1EEEE_"; }
  __SYCL_DLL_LOCAL
  static constexpr unsigned getNumParams() { return 5; }
  __SYCL_DLL_LOCAL
  static constexpr const kernel_param_desc_t& getParamDesc(unsigned i) {
    return kernel_signatures[i+23];
  }
  __SYCL_DLL_LOCAL
  static constexpr bool isESIMD() { return 1; }
  __SYCL_DLL_LOCAL
  static constexpr const char* getFileName() {
#ifndef NDEBUG
    return "gemm_s8_v8_kernel.hpp";
#else
    return "";
#endif
  }
  __SYCL_DLL_LOCAL
  static constexpr const char* getFunctionName() {
#ifndef NDEBUG
    return "s8v8::class (lambda)";
#else
    return "";
#endif
  }
  __SYCL_DLL_LOCAL
  static constexpr unsigned getLineNumber() {
#ifndef NDEBUG
    return 282;
#else
    return 0;
#endif
  }
  __SYCL_DLL_LOCAL
  static constexpr unsigned getColumnNumber() {
#ifndef NDEBUG
    return 65;
#else
    return 0;
#endif
  }
  // Returns the size of the kernel object in bytes.
  __SYCL_DLL_LOCAL
  static constexpr long long getKernelSize() { return 40; }
};
template <> struct KernelInfoData<'_', 'Z', 'T', 'S', 'Z', 'Z', 'N', '4', 's', '8', 'v', '8', 'L', '1', '0', 'g', 'e', 'm', 'm', '_', 'b', '_', 'p', 'u', 'b', 'E', 'R', 'N', '4', 's', 'y', 'c', 'l', '3', '_', 'V', '1', '5', 'q', 'u', 'e', 'u', 'e', 'E', 'P', 'K', 'a', 'S', '5', '_', 'P', 'v', 'P', 'K', 'f', 'S', '8', '_', 'i', 'i', 'i', 'i', 'i', 'y', 'j', 'j', 'j', 'b', 'j', 'E', 'N', 'K', 'U', 'l', 'R', 'N', 'S', '1', '_', '7', 'h', 'a', 'n', 'd', 'l', 'e', 'r', 'E', 'E', '_', 'c', 'l', 'E', 'S', 'A', '_', 'E', 'U', 'l', 'N', 'S', '1', '_', '7', 'n', 'd', '_', 'i', 't', 'e', 'm', 'I', 'L', 'i', '1', 'E', 'E', 'E', 'E', '_'> {
  __SYCL_DLL_LOCAL
  static constexpr const char* getName() { return "_ZTSZZN4s8v8L10gemm_b_pubERN4sycl3_V15queueEPKaS5_PvPKfS8_iiiiiyjjjbjENKUlRNS1_7handlerEE_clESA_EUlNS1_7nd_itemILi1EEEE_"; }
  __SYCL_DLL_LOCAL
  static constexpr unsigned getNumParams() { return 17; }
  __SYCL_DLL_LOCAL
  static constexpr const kernel_param_desc_t& getParamDesc(unsigned i) {
    return kernel_signatures[i+28];
  }
  __SYCL_DLL_LOCAL
  static constexpr bool isESIMD() { return 1; }
  __SYCL_DLL_LOCAL
  static constexpr const char* getFileName() {
#ifndef NDEBUG
    return "gemm_s8_v8_kernel.hpp";
#else
    return "";
#endif
  }
  __SYCL_DLL_LOCAL
  static constexpr const char* getFunctionName() {
#ifndef NDEBUG
    return "s8v8::class (lambda)";
#else
    return "";
#endif
  }
  __SYCL_DLL_LOCAL
  static constexpr unsigned getLineNumber() {
#ifndef NDEBUG
    return 430;
#else
    return 0;
#endif
  }
  __SYCL_DLL_LOCAL
  static constexpr unsigned getColumnNumber() {
#ifndef NDEBUG
    return 77;
#else
    return 0;
#endif
  }
  // Returns the size of the kernel object in bytes.
  __SYCL_DLL_LOCAL
  static constexpr long long getKernelSize() { return 112; }
};
template <> struct KernelInfoData<'_', 'Z', 'T', 'S', 'Z', 'Z', 'N', '4', 's', '8', 'v', '8', 'L', '1', '0', 'g', 'e', 'm', 'm', '_', 'b', '_', 'r', 'e', 's', 'E', 'R', 'N', '4', 's', 'y', 'c', 'l', '3', '_', 'V', '1', '5', 'q', 'u', 'e', 'u', 'e', 'E', 'P', 'K', 'a', 'S', '5', '_', 'P', 'v', 'P', 'K', 'f', 'S', '8', '_', 'P', 'K', 'v', 'S', '8', '_', 'i', 'i', 'i', 'i', 'b', 'b', 'j', 'E', 'N', 'K', 'U', 'l', 'R', 'N', 'S', '1', '_', '7', 'h', 'a', 'n', 'd', 'l', 'e', 'r', 'E', 'E', '_', 'c', 'l', 'E', 'S', 'C', '_', 'E', 'U', 'l', 'N', 'S', '1', '_', '7', 'n', 'd', '_', 'i', 't', 'e', 'm', 'I', 'L', 'i', '1', 'E', 'E', 'E', 'E', '_'> {
  __SYCL_DLL_LOCAL
  static constexpr const char* getName() { return "_ZTSZZN4s8v8L10gemm_b_resERN4sycl3_V15queueEPKaS5_PvPKfS8_PKvS8_iiiibbjENKUlRNS1_7handlerEE_clESC_EUlNS1_7nd_itemILi1EEEE_"; }
  __SYCL_DLL_LOCAL
  static constexpr unsigned getNumParams() { return 13; }
  __SYCL_DLL_LOCAL
  static constexpr const kernel_param_desc_t& getParamDesc(unsigned i) {
    return kernel_signatures[i+45];
  }
  __SYCL_DLL_LOCAL
  static constexpr bool isESIMD() { return 1; }
  __SYCL_DLL_LOCAL
  static constexpr const char* getFileName() {
#ifndef NDEBUG
    return "gemm_s8_v8_kernel.hpp";
#else
    return "";
#endif
  }
  __SYCL_DLL_LOCAL
  static constexpr const char* getFunctionName() {
#ifndef NDEBUG
    return "s8v8::class (lambda)";
#else
    return "";
#endif
  }
  __SYCL_DLL_LOCAL
  static constexpr unsigned getLineNumber() {
#ifndef NDEBUG
    return 683;
#else
    return 0;
#endif
  }
  __SYCL_DLL_LOCAL
  static constexpr unsigned getColumnNumber() {
#ifndef NDEBUG
    return 69;
#else
    return 0;
#endif
  }
  // Returns the size of the kernel object in bytes.
  __SYCL_DLL_LOCAL
  static constexpr long long getKernelSize() { return 96; }
};
template <> struct KernelInfoData<'_', 'Z', 'T', 'S', 'Z', 'Z', 'N', '4', 's', '8', 'v', '8', 'L', '1', '7', 'g', 'e', 'm', 'm', '_', 'b', '_', 'r', 'e', 's', '_', 'w', 'i', 'n', 'd', 'o', 'w', 'E', 'R', 'N', '4', 's', 'y', 'c', 'l', '3', '_', 'V', '1', '5', 'q', 'u', 'e', 'u', 'e', 'E', 'P', 'K', 'a', 'S', '5', '_', 'P', 'v', 'P', 'K', 'f', 'S', '8', '_', 'P', 'K', 'v', 'S', '8', '_', 'i', 'i', 'i', 'i', 'b', 'b', 'j', 'j', 'j', 'j', 'j', 'j', 'E', 'N', 'K', 'U', 'l', 'R', 'N', 'S', '1', '_', '7', 'h', 'a', 'n', 'd', 'l', 'e', 'r', 'E', 'E', '_', 'c', 'l', 'E', 'S', 'C', '_', 'E', 'U', 'l', 'N', 'S', '1', '_', '7', 'n', 'd', '_', 'i', 't', 'e', 'm', 'I', 'L', 'i', '1', 'E', 'E', 'E', 'E', '_'> {
  __SYCL_DLL_LOCAL
  static constexpr const char* getName() { return "_ZTSZZN4s8v8L17gemm_b_res_windowERN4sycl3_V15queueEPKaS5_PvPKfS8_PKvS8_iiiibbjjjjjjENKUlRNS1_7handlerEE_clESC_EUlNS1_7nd_itemILi1EEEE_"; }
  __SYCL_DLL_LOCAL
  static constexpr unsigned getNumParams() { return 18; }
  __SYCL_DLL_LOCAL
  static constexpr const kernel_param_desc_t& getParamDesc(unsigned i) {
    return kernel_signatures[i+58];
  }
  __SYCL_DLL_LOCAL
  static constexpr bool isESIMD() { return 1; }
  __SYCL_DLL_LOCAL
  static constexpr const char* getFileName() {
#ifndef NDEBUG
    return "gemm_s8_v8_kernel.hpp";
#else
    return "";
#endif
  }
  __SYCL_DLL_LOCAL
  static constexpr const char* getFunctionName() {
#ifndef NDEBUG
    return "s8v8::class (lambda)";
#else
    return "";
#endif
  }
  __SYCL_DLL_LOCAL
  static constexpr unsigned getLineNumber() {
#ifndef NDEBUG
    return 790;
#else
    return 0;
#endif
  }
  __SYCL_DLL_LOCAL
  static constexpr unsigned getColumnNumber() {
#ifndef NDEBUG
    return 69;
#else
    return 0;
#endif
  }
  // Returns the size of the kernel object in bytes.
  __SYCL_DLL_LOCAL
  static constexpr long long getKernelSize() { return 112; }
};
template <> struct KernelInfoData<'_', 'Z', 'T', 'S', 'N', '4', 's', 'y', 'c', 'l', '3', '_', 'V', '1', '6', 'd', 'e', 't', 'a', 'i', 'l', '1', '8', 'R', 'o', 'u', 'n', 'd', 'e', 'd', 'R', 'a', 'n', 'g', 'e', 'K', 'e', 'r', 'n', 'e', 'l', 'I', 'N', 'S', '0', '_', '4', 'i', 't', 'e', 'm', 'I', 'L', 'i', '1', 'E', 'L', 'b', '1', 'E', 'E', 'E', 'L', 'i', '1', 'E', 'Z', 'Z', 'N', '5', 'f', '1', '6', 'v', '1', 'L', '4', 'g', 'e', 'm', 'm', 'E', 'R', 'N', 'S', '0', '_', '5', 'q', 'u', 'e', 'u', 'e', 'E', 'P', 'K', 'N', 'S', '1', '_', '9', 'h', 'a', 'l', 'f', '_', 'i', 'm', 'p', 'l', '4', 'h', 'a', 'l', 'f', 'E', 'S', 'B', '_', 'P', 'f', 'i', 'i', 'i', 'E', 'N', 'K', 'U', 'l', 'R', 'N', 'S', '0', '_', '7', 'h', 'a', 'n', 'd', 'l', 'e', 'r', 'E', 'E', '_', 'c', 'l', 'E', 'S', 'E', '_', 'E', 'U', 'l', 'S', '4', '_', 'E', '_', 'E', 'E'> {
  __SYCL_DLL_LOCAL
  static constexpr const char* getName() { return "_ZTSN4sycl3_V16detail18RoundedRangeKernelINS0_4itemILi1ELb1EEELi1EZZN5f16v1L4gemmERNS0_5queueEPKNS1_9half_impl4halfESB_PfiiiENKUlRNS0_7handlerEE_clESE_EUlS4_E_EE"; }
  __SYCL_DLL_LOCAL
  static constexpr unsigned getNumParams() { return 2; }
  __SYCL_DLL_LOCAL
  static constexpr const kernel_param_desc_t& getParamDesc(unsigned i) {
    return kernel_signatures[i+76];
  }
  __SYCL_DLL_LOCAL
  static constexpr bool isESIMD() { return 0; }
  __SYCL_DLL_LOCAL
  static constexpr const char* getFileName() {
#ifndef NDEBUG
    return "range_rounding.hpp";
#else
    return "";
#endif
  }
  __SYCL_DLL_LOCAL
  static constexpr const char* getFunctionName() {
#ifndef NDEBUG
    return "::sycl::detail::RoundedRangeKernel<::sycl::item<1, true>, 1, f16v1::(lambda)>";
#else
    return "";
#endif
  }
  __SYCL_DLL_LOCAL
  static constexpr unsigned getLineNumber() {
#ifndef NDEBUG
    return 83;
#else
    return 0;
#endif
  }
  __SYCL_DLL_LOCAL
  static constexpr unsigned getColumnNumber() {
#ifndef NDEBUG
    return 7;
#else
    return 0;
#endif
  }
  // Returns the size of the kernel object in bytes.
  __SYCL_DLL_LOCAL
  static constexpr long long getKernelSize() { return 48; }
};
template <> struct KernelInfoData<'_', 'Z', 'T', 'S', 'Z', 'Z', 'N', '5', 'f', '1', '6', 'v', '1', 'L', '4', 'g', 'e', 'm', 'm', 'E', 'R', 'N', '4', 's', 'y', 'c', 'l', '3', '_', 'V', '1', '5', 'q', 'u', 'e', 'u', 'e', 'E', 'P', 'K', 'N', 'S', '1', '_', '6', 'd', 'e', 't', 'a', 'i', 'l', '9', 'h', 'a', 'l', 'f', '_', 'i', 'm', 'p', 'l', '4', 'h', 'a', 'l', 'f', 'E', 'S', '8', '_', 'P', 'f', 'i', 'i', 'i', 'E', 'N', 'K', 'U', 'l', 'R', 'N', 'S', '1', '_', '7', 'h', 'a', 'n', 'd', 'l', 'e', 'r', 'E', 'E', '_', 'c', 'l', 'E', 'S', 'B', '_', 'E', 'U', 'l', 'N', 'S', '1', '_', '4', 'i', 't', 'e', 'm', 'I', 'L', 'i', '1', 'E', 'L', 'b', '1', 'E', 'E', 'E', 'E', '_'> {
  __SYCL_DLL_LOCAL
  static constexpr const char* getName() { return "_ZTSZZN5f16v1L4gemmERN4sycl3_V15queueEPKNS1_6detail9half_impl4halfES8_PfiiiENKUlRNS1_7handlerEE_clESB_EUlNS1_4itemILi1ELb1EEEE_"; }
  __SYCL_DLL_LOCAL
  static constexpr unsigned getNumParams() { return 6; }
  __SYCL_DLL_LOCAL
  static constexpr const kernel_param_desc_t& getParamDesc(unsigned i) {
    return kernel_signatures[i+78];
  }
  __SYCL_DLL_LOCAL
  static constexpr bool isESIMD() { return 1; }
  __SYCL_DLL_LOCAL
  static constexpr const char* getFileName() {
#ifndef NDEBUG
    return "gemm_f16_v1_kernel.hpp";
#else
    return "";
#endif
  }
  __SYCL_DLL_LOCAL
  static constexpr const char* getFunctionName() {
#ifndef NDEBUG
    return "f16v1::class (lambda)";
#else
    return "";
#endif
  }
  __SYCL_DLL_LOCAL
  static constexpr unsigned getLineNumber() {
#ifndef NDEBUG
    return 63;
#else
    return 0;
#endif
  }
  __SYCL_DLL_LOCAL
  static constexpr unsigned getColumnNumber() {
#ifndef NDEBUG
    return 55;
#else
    return 0;
#endif
  }
  // Returns the size of the kernel object in bytes.
  __SYCL_DLL_LOCAL
  static constexpr long long getKernelSize() { return 40; }
};
template <> struct KernelInfoData<'_', 'Z', 'T', 'S', 'N', '4', 's', 'y', 'c', 'l', '3', '_', 'V', '1', '6', 'd', 'e', 't', 'a', 'i', 'l', '1', '8', 'R', 'o', 'u', 'n', 'd', 'e', 'd', 'R', 'a', 'n', 'g', 'e', 'K', 'e', 'r', 'n', 'e', 'l', 'I', 'N', 'S', '0', '_', '4', 'i', 't', 'e', 'm', 'I', 'L', 'i', '1', 'E', 'L', 'b', '1', 'E', 'E', 'E', 'L', 'i', '1', 'E', 'Z', 'Z', 'N', '5', 'f', '1', '6', 'v', '1', 'L', '6', 'g', 'e', 'm', 'm', '_', 'b', 'E', 'R', 'N', 'S', '0', '_', '5', 'q', 'u', 'e', 'u', 'e', 'E', 'P', 'K', 'N', 'S', '1', '_', '9', 'h', 'a', 'l', 'f', '_', 'i', 'm', 'p', 'l', '4', 'h', 'a', 'l', 'f', 'E', 'S', 'B', '_', 'P', 'f', 'i', 'i', 'i', 'i', 'E', 'N', 'K', 'U', 'l', 'R', 'N', 'S', '0', '_', '7', 'h', 'a', 'n', 'd', 'l', 'e', 'r', 'E', 'E', '_', 'c', 'l', 'E', 'S', 'E', '_', 'E', 'U', 'l', 'S', '4', '_', 'E', '_', 'E', 'E'> {
  __SYCL_DLL_LOCAL
  static constexpr const char* getName() { return "_ZTSN4sycl3_V16detail18RoundedRangeKernelINS0_4itemILi1ELb1EEELi1EZZN5f16v1L6gemm_bERNS0_5queueEPKNS1_9half_impl4halfESB_PfiiiiENKUlRNS0_7handlerEE_clESE_EUlS4_E_EE"; }
  __SYCL_DLL_LOCAL
  static constexpr unsigned getNumParams() { return 2; }
  __SYCL_DLL_LOCAL
  static constexpr const kernel_param_desc_t& getParamDesc(unsigned i) {
    return kernel_signatures[i+84];
  }
  __SYCL_DLL_LOCAL
  static constexpr bool isESIMD() { return 0; }
  __SYCL_DLL_LOCAL
  static constexpr const char* getFileName() {
#ifndef NDEBUG
    return "range_rounding.hpp";
#else
    return "";
#endif
  }
  __SYCL_DLL_LOCAL
  static constexpr const char* getFunctionName() {
#ifndef NDEBUG
    return "::sycl::detail::RoundedRangeKernel<::sycl::item<1, true>, 1, f16v1::(lambda)>";
#else
    return "";
#endif
  }
  __SYCL_DLL_LOCAL
  static constexpr unsigned getLineNumber() {
#ifndef NDEBUG
    return 83;
#else
    return 0;
#endif
  }
  __SYCL_DLL_LOCAL
  static constexpr unsigned getColumnNumber() {
#ifndef NDEBUG
    return 7;
#else
    return 0;
#endif
  }
  // Returns the size of the kernel object in bytes.
  __SYCL_DLL_LOCAL
  static constexpr long long getKernelSize() { return 72; }
};
template <> struct KernelInfoData<'_', 'Z', 'T', 'S', 'Z', 'Z', 'N', '5', 'f', '1', '6', 'v', '1', 'L', '6', 'g', 'e', 'm', 'm', '_', 'b', 'E', 'R', 'N', '4', 's', 'y', 'c', 'l', '3', '_', 'V', '1', '5', 'q', 'u', 'e', 'u', 'e', 'E', 'P', 'K', 'N', 'S', '1', '_', '6', 'd', 'e', 't', 'a', 'i', 'l', '9', 'h', 'a', 'l', 'f', '_', 'i', 'm', 'p', 'l', '4', 'h', 'a', 'l', 'f', 'E', 'S', '8', '_', 'P', 'f', 'i', 'i', 'i', 'i', 'E', 'N', 'K', 'U', 'l', 'R', 'N', 'S', '1', '_', '7', 'h', 'a', 'n', 'd', 'l', 'e', 'r', 'E', 'E', '_', 'c', 'l', 'E', 'S', 'B', '_', 'E', 'U', 'l', 'N', 'S', '1', '_', '4', 'i', 't', 'e', 'm', 'I', 'L', 'i', '1', 'E', 'L', 'b', '1', 'E', 'E', 'E', 'E', '_'> {
  __SYCL_DLL_LOCAL
  static constexpr const char* getName() { return "_ZTSZZN5f16v1L6gemm_bERN4sycl3_V15queueEPKNS1_6detail9half_impl4halfES8_PfiiiiENKUlRNS1_7handlerEE_clESB_EUlNS1_4itemILi1ELb1EEEE_"; }
  __SYCL_DLL_LOCAL
  static constexpr unsigned getNumParams() { return 10; }
  __SYCL_DLL_LOCAL
  static constexpr const kernel_param_desc_t& getParamDesc(unsigned i) {
    return kernel_signatures[i+86];
  }
  __SYCL_DLL_LOCAL
  static constexpr bool isESIMD() { return 1; }
  __SYCL_DLL_LOCAL
  static constexpr const char* getFileName() {
#ifndef NDEBUG
    return "gemm_f16_v1_kernel.hpp";
#else
    return "";
#endif
  }
  __SYCL_DLL_LOCAL
  static constexpr const char* getFunctionName() {
#ifndef NDEBUG
    return "f16v1::class (lambda)";
#else
    return "";
#endif
  }
  __SYCL_DLL_LOCAL
  static constexpr unsigned getLineNumber() {
#ifndef NDEBUG
    return 102;
#else
    return 0;
#endif
  }
  __SYCL_DLL_LOCAL
  static constexpr unsigned getColumnNumber() {
#ifndef NDEBUG
    return 65;
#else
    return 0;
#endif
  }
  // Returns the size of the kernel object in bytes.
  __SYCL_DLL_LOCAL
  static constexpr long long getKernelSize() { return 64; }
};
template <> struct KernelInfoData<'_', 'Z', 'T', 'S', 'N', '4', 's', 'y', 'c', 'l', '3', '_', 'V', '1', '6', 'd', 'e', 't', 'a', 'i', 'l', '1', '8', 'R', 'o', 'u', 'n', 'd', 'e', 'd', 'R', 'a', 'n', 'g', 'e', 'K', 'e', 'r', 'n', 'e', 'l', 'I', 'N', 'S', '0', '_', '4', 'i', 't', 'e', 'm', 'I', 'L', 'i', '1', 'E', 'L', 'b', '1', 'E', 'E', 'E', 'L', 'i', '1', 'E', 'Z', 'Z', 'N', '5', 'f', '1', '6', 'v', '1', 'L', '1', '8', 'g', 'e', 'm', 'm', '_', 'b', '_', 'm', 'e', 'r', 'g', 'e', '_', 's', 'c', 'a', 'l', 'e', 'E', 'R', 'N', 'S', '0', '_', '5', 'q', 'u', 'e', 'u', 'e', 'E', 'P', 'K', 'N', 'S', '1', '_', '9', 'h', 'a', 'l', 'f', '_', 'i', 'm', 'p', 'l', '4', 'h', 'a', 'l', 'f', 'E', 'S', 'B', '_', 'P', 'S', '9', '_', 'P', 'K', 'f', 'i', 'i', 'i', 'i', 'E', 'N', 'K', 'U', 'l', 'R', 'N', 'S', '0', '_', '7', 'h', 'a', 'n', 'd', 'l', 'e', 'r', 'E', 'E', '_', 'c', 'l', 'E', 'S', 'G', '_', 'E', 'U', 'l', 'S', '4', '_', 'E', '_', 'E', 'E'> {
  __SYCL_DLL_LOCAL
  static constexpr const char* getName() { return "_ZTSN4sycl3_V16detail18RoundedRangeKernelINS0_4itemILi1ELb1EEELi1EZZN5f16v1L18gemm_b_merge_scaleERNS0_5queueEPKNS1_9half_impl4halfESB_PS9_PKfiiiiENKUlRNS0_7handlerEE_clESG_EUlS4_E_EE"; }
  __SYCL_DLL_LOCAL
  static constexpr unsigned getNumParams() { return 2; }
  __SYCL_DLL_LOCAL
  static constexpr const kernel_param_desc_t& getParamDesc(unsigned i) {
    return kernel_signatures[i+96];
  }
  __SYCL_DLL_LOCAL
  static constexpr bool isESIMD() { return 0; }
  __SYCL_DLL_LOCAL
  static constexpr const char* getFileName() {
#ifndef NDEBUG
    return "range_rounding.hpp";
#else
    return "";
#endif
  }
  __SYCL_DLL_LOCAL
  static constexpr const char* getFunctionName() {
#ifndef NDEBUG
    return "::sycl::detail::RoundedRangeKernel<::sycl::item<1, true>, 1, f16v1::(lambda)>";
#else
    return "";
#endif
  }
  __SYCL_DLL_LOCAL
  static constexpr unsigned getLineNumber() {
#ifndef NDEBUG
    return 83;
#else
    return 0;
#endif
  }
  __SYCL_DLL_LOCAL
  static constexpr unsigned getColumnNumber() {
#ifndef NDEBUG
    return 7;
#else
    return 0;
#endif
  }
  // Returns the size of the kernel object in bytes.
  __SYCL_DLL_LOCAL
  static constexpr long long getKernelSize() { return 80; }
};
template <> struct KernelInfoData<'_', 'Z', 'T', 'S', 'Z', 'Z', 'N', '5', 'f', '1', '6', 'v', '1', 'L', '1', '8', 'g', 'e', 'm', 'm', '_', 'b', '_', 'm', 'e', 'r', 'g', 'e', '_', 's', 'c', 'a', 'l', 'e', 'E', 'R', 'N', '4', 's', 'y', 'c', 'l', '3', '_', 'V', '1', '5', 'q', 'u', 'e', 'u', 'e', 'E', 'P', 'K', 'N', 'S', '1', '_', '6', 'd', 'e', 't', 'a', 'i', 'l', '9', 'h', 'a', 'l', 'f', '_', 'i', 'm', 'p', 'l', '4', 'h', 'a', 'l', 'f', 'E', 'S', '8', '_', 'P', 'S', '6', '_', 'P', 'K', 'f', 'i', 'i', 'i', 'i', 'E', 'N', 'K', 'U', 'l', 'R', 'N', 'S', '1', '_', '7', 'h', 'a', 'n', 'd', 'l', 'e', 'r', 'E', 'E', '_', 'c', 'l', 'E', 'S', 'D', '_', 'E', 'U', 'l', 'N', 'S', '1', '_', '4', 'i', 't', 'e', 'm', 'I', 'L', 'i', '1', 'E', 'L', 'b', '1', 'E', 'E', 'E', 'E', '_'> {
  __SYCL_DLL_LOCAL
  static constexpr const char* getName() { return "_ZTSZZN5f16v1L18gemm_b_merge_scaleERN4sycl3_V15queueEPKNS1_6detail9half_impl4halfES8_PS6_PKfiiiiENKUlRNS1_7handlerEE_clESD_EUlNS1_4itemILi1ELb1EEEE_"; }
  __SYCL_DLL_LOCAL
  static constexpr unsigned getNumParams() { return 11; }
  __SYCL_DLL_LOCAL
  static constexpr const kernel_param_desc_t& getParamDesc(unsigned i) {
    return kernel_signatures[i+98];
  }
  __SYCL_DLL_LOCAL
  static constexpr bool isESIMD() { return 1; }
  __SYCL_DLL_LOCAL
  static constexpr const char* getFileName() {
#ifndef NDEBUG
    return "gemm_f16_v1_kernel.hpp";
#else
    return "";
#endif
  }
  __SYCL_DLL_LOCAL
  static constexpr const char* getFunctionName() {
#ifndef NDEBUG
    return "f16v1::class (lambda)";
#else
    return "";
#endif
  }
  __SYCL_DLL_LOCAL
  static constexpr unsigned getLineNumber() {
#ifndef NDEBUG
    return 150;
#else
    return 0;
#endif
  }
  __SYCL_DLL_LOCAL
  static constexpr unsigned getColumnNumber() {
#ifndef NDEBUG
    return 65;
#else
    return 0;
#endif
  }
  // Returns the size of the kernel object in bytes.
  __SYCL_DLL_LOCAL
  static constexpr long long getKernelSize() { return 72; }
};
template <> struct KernelInfoData<'_', 'Z', 'T', 'S', 'N', '4', 's', 'y', 'c', 'l', '3', '_', 'V', '1', '6', 'd', 'e', 't', 'a', 'i', 'l', '1', '8', 'R', 'o', 'u', 'n', 'd', 'e', 'd', 'R', 'a', 'n', 'g', 'e', 'K', 'e', 'r', 'n', 'e', 'l', 'I', 'N', 'S', '0', '_', '4', 'i', 't', 'e', 'm', 'I', 'L', 'i', '1', 'E', 'L', 'b', '1', 'E', 'E', 'E', 'L', 'i', '1', 'E', 'Z', 'Z', 'N', '5', 'f', '1', '6', 'v', '1', 'L', '1', '4', 'g', 'e', 'm', 'm', '_', 'b', '_', 'p', 'u', 'b', '_', 'f', '1', '6', 'E', 'R', 'N', 'S', '0', '_', '5', 'q', 'u', 'e', 'u', 'e', 'E', 'P', 'K', 'N', 'S', '1', '_', '9', 'h', 'a', 'l', 'f', '_', 'i', 'm', 'p', 'l', '4', 'h', 'a', 'l', 'f', 'E', 'S', 'B', '_', 'P', 'v', 'i', 'i', 'i', 'i', 'i', 'j', 'b', 'y', 'y', 'j', 'j', 'E', 'N', 'K', 'U', 'l', 'R', 'N', 'S', '0', '_', '7', 'h', 'a', 'n', 'd', 'l', 'e', 'r', 'E', 'E', '_', 'c', 'l', 'E', 'S', 'E', '_', 'E', 'U', 'l', 'S', '4', '_', 'E', '_', 'E', 'E'> {
  __SYCL_DLL_LOCAL
  static constexpr const char* getName() { return "_ZTSN4sycl3_V16detail18RoundedRangeKernelINS0_4itemILi1ELb1EEELi1EZZN5f16v1L14gemm_b_pub_f16ERNS0_5queueEPKNS1_9half_impl4halfESB_PviiiiijbyyjjENKUlRNS0_7handlerEE_clESE_EUlS4_E_EE"; }
  __SYCL_DLL_LOCAL
  static constexpr unsigned getNumParams() { return 2; }
  __SYCL_DLL_LOCAL
  static constexpr const kernel_param_desc_t& getParamDesc(unsigned i) {
    return kernel_signatures[i+109];
  }
  __SYCL_DLL_LOCAL
  static constexpr bool isESIMD() { return 0; }
  __SYCL_DLL_LOCAL
  static constexpr const char* getFileName() {
#ifndef NDEBUG
    return "range_rounding.hpp";
#else
    return "";
#endif
  }
  __SYCL_DLL_LOCAL
  static constexpr const char* getFunctionName() {
#ifndef NDEBUG
    return "::sycl::detail::RoundedRangeKernel<::sycl::item<1, true>, 1, f16v1::(lambda)>";
#else
    return "";
#endif
  }
  __SYCL_DLL_LOCAL
  static constexpr unsigned getLineNumber() {
#ifndef NDEBUG
    return 83;
#else
    return 0;
#endif
  }
  __SYCL_DLL_LOCAL
  static constexpr unsigned getColumnNumber() {
#ifndef NDEBUG
    return 7;
#else
    return 0;
#endif
  }
  // Returns the size of the kernel object in bytes.
  __SYCL_DLL_LOCAL
  static constexpr long long getKernelSize() { return 104; }
};
template <> struct KernelInfoData<'_', 'Z', 'T', 'S', 'Z', 'Z', 'N', '5', 'f', '1', '6', 'v', '1', 'L', '1', '4', 'g', 'e', 'm', 'm', '_', 'b', '_', 'p', 'u', 'b', '_', 'f', '1', '6', 'E', 'R', 'N', '4', 's', 'y', 'c', 'l', '3', '_', 'V', '1', '5', 'q', 'u', 'e', 'u', 'e', 'E', 'P', 'K', 'N', 'S', '1', '_', '6', 'd', 'e', 't', 'a', 'i', 'l', '9', 'h', 'a', 'l', 'f', '_', 'i', 'm', 'p', 'l', '4', 'h', 'a', 'l', 'f', 'E', 'S', '8', '_', 'P', 'v', 'i', 'i', 'i', 'i', 'i', 'j', 'b', 'y', 'y', 'j', 'j', 'E', 'N', 'K', 'U', 'l', 'R', 'N', 'S', '1', '_', '7', 'h', 'a', 'n', 'd', 'l', 'e', 'r', 'E', 'E', '_', 'c', 'l', 'E', 'S', 'B', '_', 'E', 'U', 'l', 'N', 'S', '1', '_', '4', 'i', 't', 'e', 'm', 'I', 'L', 'i', '1', 'E', 'L', 'b', '1', 'E', 'E', 'E', 'E', '_'> {
  __SYCL_DLL_LOCAL
  static constexpr const char* getName() { return "_ZTSZZN5f16v1L14gemm_b_pub_f16ERN4sycl3_V15queueEPKNS1_6detail9half_impl4halfES8_PviiiiijbyyjjENKUlRNS1_7handlerEE_clESB_EUlNS1_4itemILi1ELb1EEEE_"; }
  __SYCL_DLL_LOCAL
  static constexpr unsigned getNumParams() { return 15; }
  __SYCL_DLL_LOCAL
  static constexpr const kernel_param_desc_t& getParamDesc(unsigned i) {
    return kernel_signatures[i+111];
  }
  __SYCL_DLL_LOCAL
  static constexpr bool isESIMD() { return 1; }
  __SYCL_DLL_LOCAL
  static constexpr const char* getFileName() {
#ifndef NDEBUG
    return "gemm_f16_v1_kernel.hpp";
#else
    return "";
#endif
  }
  __SYCL_DLL_LOCAL
  static constexpr const char* getFunctionName() {
#ifndef NDEBUG
    return "f16v1::class (lambda)";
#else
    return "";
#endif
  }
  __SYCL_DLL_LOCAL
  static constexpr unsigned getLineNumber() {
#ifndef NDEBUG
    return 213;
#else
    return 0;
#endif
  }
  __SYCL_DLL_LOCAL
  static constexpr unsigned getColumnNumber() {
#ifndef NDEBUG
    return 65;
#else
    return 0;
#endif
  }
  // Returns the size of the kernel object in bytes.
  __SYCL_DLL_LOCAL
  static constexpr long long getKernelSize() { return 96; }
};
template <> struct KernelInfoData<'_', 'Z', 'T', 'S', 'N', '4', 's', 'y', 'c', 'l', '3', '_', 'V', '1', '6', 'd', 'e', 't', 'a', 'i', 'l', '1', '8', 'R', 'o', 'u', 'n', 'd', 'e', 'd', 'R', 'a', 'n', 'g', 'e', 'K', 'e', 'r', 'n', 'e', 'l', 'I', 'N', 'S', '0', '_', '4', 'i', 't', 'e', 'm', 'I', 'L', 'i', '1', 'E', 'L', 'b', '1', 'E', 'E', 'E', 'L', 'i', '1', 'E', 'Z', 'Z', 'N', '5', 'f', '1', '6', 'v', '1', 'L', '1', '3', 'g', 'e', 'm', 'm', '_', 'd', 'u', 'a', 'l', '_', 'p', 'u', 'b', 'E', 'R', 'N', 'S', '0', '_', '5', 'q', 'u', 'e', 'u', 'e', 'E', 'P', 'K', 'N', 'S', '1', '_', '9', 'h', 'a', 'l', 'f', '_', 'i', 'm', 'p', 'l', '4', 'h', 'a', 'l', 'f', 'E', 'S', 'B', '_', 'P', 'f', 'P', 'S', '9', '_', 'i', 'i', 'i', 'i', 'E', 'N', 'K', 'U', 'l', 'R', 'N', 'S', '0', '_', '7', 'h', 'a', 'n', 'd', 'l', 'e', 'r', 'E', 'E', '_', 'c', 'l', 'E', 'S', 'F', '_', 'E', 'U', 'l', 'S', '4', '_', 'E', '_', 'E', 'E'> {
  __SYCL_DLL_LOCAL
  static constexpr const char* getName() { return "_ZTSN4sycl3_V16detail18RoundedRangeKernelINS0_4itemILi1ELb1EEELi1EZZN5f16v1L13gemm_dual_pubERNS0_5queueEPKNS1_9half_impl4halfESB_PfPS9_iiiiENKUlRNS0_7handlerEE_clESF_EUlS4_E_EE"; }
  __SYCL_DLL_LOCAL
  static constexpr unsigned getNumParams() { return 2; }
  __SYCL_DLL_LOCAL
  static constexpr const kernel_param_desc_t& getParamDesc(unsigned i) {
    return kernel_signatures[i+126];
  }
  __SYCL_DLL_LOCAL
  static constexpr bool isESIMD() { return 0; }
  __SYCL_DLL_LOCAL
  static constexpr const char* getFileName() {
#ifndef NDEBUG
    return "range_rounding.hpp";
#else
    return "";
#endif
  }
  __SYCL_DLL_LOCAL
  static constexpr const char* getFunctionName() {
#ifndef NDEBUG
    return "::sycl::detail::RoundedRangeKernel<::sycl::item<1, true>, 1, f16v1::(lambda)>";
#else
    return "";
#endif
  }
  __SYCL_DLL_LOCAL
  static constexpr unsigned getLineNumber() {
#ifndef NDEBUG
    return 83;
#else
    return 0;
#endif
  }
  __SYCL_DLL_LOCAL
  static constexpr unsigned getColumnNumber() {
#ifndef NDEBUG
    return 7;
#else
    return 0;
#endif
  }
  // Returns the size of the kernel object in bytes.
  __SYCL_DLL_LOCAL
  static constexpr long long getKernelSize() { return 64; }
};
template <> struct KernelInfoData<'_', 'Z', 'T', 'S', 'Z', 'Z', 'N', '5', 'f', '1', '6', 'v', '1', 'L', '1', '3', 'g', 'e', 'm', 'm', '_', 'd', 'u', 'a', 'l', '_', 'p', 'u', 'b', 'E', 'R', 'N', '4', 's', 'y', 'c', 'l', '3', '_', 'V', '1', '5', 'q', 'u', 'e', 'u', 'e', 'E', 'P', 'K', 'N', 'S', '1', '_', '6', 'd', 'e', 't', 'a', 'i', 'l', '9', 'h', 'a', 'l', 'f', '_', 'i', 'm', 'p', 'l', '4', 'h', 'a', 'l', 'f', 'E', 'S', '8', '_', 'P', 'f', 'P', 'S', '6', '_', 'i', 'i', 'i', 'i', 'E', 'N', 'K', 'U', 'l', 'R', 'N', 'S', '1', '_', '7', 'h', 'a', 'n', 'd', 'l', 'e', 'r', 'E', 'E', '_', 'c', 'l', 'E', 'S', 'C', '_', 'E', 'U', 'l', 'N', 'S', '1', '_', '4', 'i', 't', 'e', 'm', 'I', 'L', 'i', '1', 'E', 'L', 'b', '1', 'E', 'E', 'E', 'E', '_'> {
  __SYCL_DLL_LOCAL
  static constexpr const char* getName() { return "_ZTSZZN5f16v1L13gemm_dual_pubERN4sycl3_V15queueEPKNS1_6detail9half_impl4halfES8_PfPS6_iiiiENKUlRNS1_7handlerEE_clESC_EUlNS1_4itemILi1ELb1EEEE_"; }
  __SYCL_DLL_LOCAL
  static constexpr unsigned getNumParams() { return 8; }
  __SYCL_DLL_LOCAL
  static constexpr const kernel_param_desc_t& getParamDesc(unsigned i) {
    return kernel_signatures[i+128];
  }
  __SYCL_DLL_LOCAL
  static constexpr bool isESIMD() { return 1; }
  __SYCL_DLL_LOCAL
  static constexpr const char* getFileName() {
#ifndef NDEBUG
    return "gemm_f16_v1_kernel.hpp";
#else
    return "";
#endif
  }
  __SYCL_DLL_LOCAL
  static constexpr const char* getFunctionName() {
#ifndef NDEBUG
    return "f16v1::class (lambda)";
#else
    return "";
#endif
  }
  __SYCL_DLL_LOCAL
  static constexpr unsigned getLineNumber() {
#ifndef NDEBUG
    return 295;
#else
    return 0;
#endif
  }
  __SYCL_DLL_LOCAL
  static constexpr unsigned getColumnNumber() {
#ifndef NDEBUG
    return 55;
#else
    return 0;
#endif
  }
  // Returns the size of the kernel object in bytes.
  __SYCL_DLL_LOCAL
  static constexpr long long getKernelSize() { return 56; }
};
template <> struct KernelInfoData<'_', 'Z', 'T', 'S', 'N', '4', 's', 'y', 'c', 'l', '3', '_', 'V', '1', '6', 'd', 'e', 't', 'a', 'i', 'l', '1', '8', 'R', 'o', 'u', 'n', 'd', 'e', 'd', 'R', 'a', 'n', 'g', 'e', 'K', 'e', 'r', 'n', 'e', 'l', 'I', 'N', 'S', '0', '_', '4', 'i', 't', 'e', 'm', 'I', 'L', 'i', '1', 'E', 'L', 'b', '1', 'E', 'E', 'E', 'L', 'i', '1', 'E', 'Z', 'Z', 'N', '5', 'f', '1', '6', 'v', '1', 'L', '8', 'g', 'e', 'm', 'm', '_', 'p', 'u', 'b', 'E', 'R', 'N', 'S', '0', '_', '5', 'q', 'u', 'e', 'u', 'e', 'E', 'P', 'K', 'N', 'S', '1', '_', '9', 'h', 'a', 'l', 'f', '_', 'i', 'm', 'p', 'l', '4', 'h', 'a', 'l', 'f', 'E', 'S', 'B', '_', 'P', 'S', '9', '_', 'i', 'i', 'i', 'i', 'j', 'E', 'N', 'K', 'U', 'l', 'R', 'N', 'S', '0', '_', '7', 'h', 'a', 'n', 'd', 'l', 'e', 'r', 'E', 'E', '_', 'c', 'l', 'E', 'S', 'E', '_', 'E', 'U', 'l', 'S', '4', '_', 'E', '_', 'E', 'E'> {
  __SYCL_DLL_LOCAL
  static constexpr const char* getName() { return "_ZTSN4sycl3_V16detail18RoundedRangeKernelINS0_4itemILi1ELb1EEELi1EZZN5f16v1L8gemm_pubERNS0_5queueEPKNS1_9half_impl4halfESB_PS9_iiiijENKUlRNS0_7handlerEE_clESE_EUlS4_E_EE"; }
  __SYCL_DLL_LOCAL
  static constexpr unsigned getNumParams() { return 2; }
  __SYCL_DLL_LOCAL
  static constexpr const kernel_param_desc_t& getParamDesc(unsigned i) {
    return kernel_signatures[i+136];
  }
  __SYCL_DLL_LOCAL
  static constexpr bool isESIMD() { return 0; }
  __SYCL_DLL_LOCAL
  static constexpr const char* getFileName() {
#ifndef NDEBUG
    return "range_rounding.hpp";
#else
    return "";
#endif
  }
  __SYCL_DLL_LOCAL
  static constexpr const char* getFunctionName() {
#ifndef NDEBUG
    return "::sycl::detail::RoundedRangeKernel<::sycl::item<1, true>, 1, f16v1::(lambda)>";
#else
    return "";
#endif
  }
  __SYCL_DLL_LOCAL
  static constexpr unsigned getLineNumber() {
#ifndef NDEBUG
    return 83;
#else
    return 0;
#endif
  }
  __SYCL_DLL_LOCAL
  static constexpr unsigned getColumnNumber() {
#ifndef NDEBUG
    return 7;
#else
    return 0;
#endif
  }
  // Returns the size of the kernel object in bytes.
  __SYCL_DLL_LOCAL
  static constexpr long long getKernelSize() { return 56; }
};
template <> struct KernelInfoData<'_', 'Z', 'T', 'S', 'Z', 'Z', 'N', '5', 'f', '1', '6', 'v', '1', 'L', '8', 'g', 'e', 'm', 'm', '_', 'p', 'u', 'b', 'E', 'R', 'N', '4', 's', 'y', 'c', 'l', '3', '_', 'V', '1', '5', 'q', 'u', 'e', 'u', 'e', 'E', 'P', 'K', 'N', 'S', '1', '_', '6', 'd', 'e', 't', 'a', 'i', 'l', '9', 'h', 'a', 'l', 'f', '_', 'i', 'm', 'p', 'l', '4', 'h', 'a', 'l', 'f', 'E', 'S', '8', '_', 'P', 'S', '6', '_', 'i', 'i', 'i', 'i', 'j', 'E', 'N', 'K', 'U', 'l', 'R', 'N', 'S', '1', '_', '7', 'h', 'a', 'n', 'd', 'l', 'e', 'r', 'E', 'E', '_', 'c', 'l', 'E', 'S', 'B', '_', 'E', 'U', 'l', 'N', 'S', '1', '_', '4', 'i', 't', 'e', 'm', 'I', 'L', 'i', '1', 'E', 'L', 'b', '1', 'E', 'E', 'E', 'E', '_'> {
  __SYCL_DLL_LOCAL
  static constexpr const char* getName() { return "_ZTSZZN5f16v1L8gemm_pubERN4sycl3_V15queueEPKNS1_6detail9half_impl4halfES8_PS6_iiiijENKUlRNS1_7handlerEE_clESB_EUlNS1_4itemILi1ELb1EEEE_"; }
  __SYCL_DLL_LOCAL
  static constexpr unsigned getNumParams() { return 8; }
  __SYCL_DLL_LOCAL
  static constexpr const kernel_param_desc_t& getParamDesc(unsigned i) {
    return kernel_signatures[i+138];
  }
  __SYCL_DLL_LOCAL
  static constexpr bool isESIMD() { return 1; }
  __SYCL_DLL_LOCAL
  static constexpr const char* getFileName() {
#ifndef NDEBUG
    return "gemm_f16_v1_kernel.hpp";
#else
    return "";
#endif
  }
  __SYCL_DLL_LOCAL
  static constexpr const char* getFunctionName() {
#ifndef NDEBUG
    return "f16v1::class (lambda)";
#else
    return "";
#endif
  }
  __SYCL_DLL_LOCAL
  static constexpr unsigned getLineNumber() {
#ifndef NDEBUG
    return 337;
#else
    return 0;
#endif
  }
  __SYCL_DLL_LOCAL
  static constexpr unsigned getColumnNumber() {
#ifndef NDEBUG
    return 55;
#else
    return 0;
#endif
  }
  // Returns the size of the kernel object in bytes.
  __SYCL_DLL_LOCAL
  static constexpr long long getKernelSize() { return 48; }
};
template <> struct KernelInfoData<'_', 'Z', 'T', 'S', 'N', '4', 's', 'y', 'c', 'l', '3', '_', 'V', '1', '6', 'd', 'e', 't', 'a', 'i', 'l', '1', '8', 'R', 'o', 'u', 'n', 'd', 'e', 'd', 'R', 'a', 'n', 'g', 'e', 'K', 'e', 'r', 'n', 'e', 'l', 'I', 'N', 'S', '0', '_', '4', 'i', 't', 'e', 'm', 'I', 'L', 'i', '1', 'E', 'L', 'b', '1', 'E', 'E', 'E', 'L', 'i', '1', 'E', 'Z', 'Z', 'N', '5', 'f', '1', '6', 'v', '1', 'L', '1', '3', 'g', 'e', 'm', 'm', '_', 'p', 'u', 'b', '_', 'p', 'a', '1', '6', 'E', 'R', 'N', 'S', '0', '_', '5', 'q', 'u', 'e', 'u', 'e', 'E', 'P', 'K', 'N', 'S', '1', '_', '9', 'h', 'a', 'l', 'f', '_', 'i', 'm', 'p', 'l', '4', 'h', 'a', 'l', 'f', 'E', 'S', 'B', '_', 'P', 'S', '9', '_', 'i', 'i', 'i', 'i', 'j', 'E', 'N', 'K', 'U', 'l', 'R', 'N', 'S', '0', '_', '7', 'h', 'a', 'n', 'd', 'l', 'e', 'r', 'E', 'E', '_', 'c', 'l', 'E', 'S', 'E', '_', 'E', 'U', 'l', 'S', '4', '_', 'E', '_', 'E', 'E'> {
  __SYCL_DLL_LOCAL
  static constexpr const char* getName() { return "_ZTSN4sycl3_V16detail18RoundedRangeKernelINS0_4itemILi1ELb1EEELi1EZZN5f16v1L13gemm_pub_pa16ERNS0_5queueEPKNS1_9half_impl4halfESB_PS9_iiiijENKUlRNS0_7handlerEE_clESE_EUlS4_E_EE"; }
  __SYCL_DLL_LOCAL
  static constexpr unsigned getNumParams() { return 2; }
  __SYCL_DLL_LOCAL
  static constexpr const kernel_param_desc_t& getParamDesc(unsigned i) {
    return kernel_signatures[i+146];
  }
  __SYCL_DLL_LOCAL
  static constexpr bool isESIMD() { return 0; }
  __SYCL_DLL_LOCAL
  static constexpr const char* getFileName() {
#ifndef NDEBUG
    return "range_rounding.hpp";
#else
    return "";
#endif
  }
  __SYCL_DLL_LOCAL
  static constexpr const char* getFunctionName() {
#ifndef NDEBUG
    return "::sycl::detail::RoundedRangeKernel<::sycl::item<1, true>, 1, f16v1::(lambda)>";
#else
    return "";
#endif
  }
  __SYCL_DLL_LOCAL
  static constexpr unsigned getLineNumber() {
#ifndef NDEBUG
    return 83;
#else
    return 0;
#endif
  }
  __SYCL_DLL_LOCAL
  static constexpr unsigned getColumnNumber() {
#ifndef NDEBUG
    return 7;
#else
    return 0;
#endif
  }
  // Returns the size of the kernel object in bytes.
  __SYCL_DLL_LOCAL
  static constexpr long long getKernelSize() { return 48; }
};
template <> struct KernelInfoData<'_', 'Z', 'T', 'S', 'Z', 'Z', 'N', '5', 'f', '1', '6', 'v', '1', 'L', '1', '3', 'g', 'e', 'm', 'm', '_', 'p', 'u', 'b', '_', 'p', 'a', '1', '6', 'E', 'R', 'N', '4', 's', 'y', 'c', 'l', '3', '_', 'V', '1', '5', 'q', 'u', 'e', 'u', 'e', 'E', 'P', 'K', 'N', 'S', '1', '_', '6', 'd', 'e', 't', 'a', 'i', 'l', '9', 'h', 'a', 'l', 'f', '_', 'i', 'm', 'p', 'l', '4', 'h', 'a', 'l', 'f', 'E', 'S', '8', '_', 'P', 'S', '6', '_', 'i', 'i', 'i', 'i', 'j', 'E', 'N', 'K', 'U', 'l', 'R', 'N', 'S', '1', '_', '7', 'h', 'a', 'n', 'd', 'l', 'e', 'r', 'E', 'E', '_', 'c', 'l', 'E', 'S', 'B', '_', 'E', 'U', 'l', 'N', 'S', '1', '_', '4', 'i', 't', 'e', 'm', 'I', 'L', 'i', '1', 'E', 'L', 'b', '1', 'E', 'E', 'E', 'E', '_'> {
  __SYCL_DLL_LOCAL
  static constexpr const char* getName() { return "_ZTSZZN5f16v1L13gemm_pub_pa16ERN4sycl3_V15queueEPKNS1_6detail9half_impl4halfES8_PS6_iiiijENKUlRNS1_7handlerEE_clESB_EUlNS1_4itemILi1ELb1EEEE_"; }
  __SYCL_DLL_LOCAL
  static constexpr unsigned getNumParams() { return 7; }
  __SYCL_DLL_LOCAL
  static constexpr const kernel_param_desc_t& getParamDesc(unsigned i) {
    return kernel_signatures[i+148];
  }
  __SYCL_DLL_LOCAL
  static constexpr bool isESIMD() { return 1; }
  __SYCL_DLL_LOCAL
  static constexpr const char* getFileName() {
#ifndef NDEBUG
    return "gemm_f16_v1_kernel.hpp";
#else
    return "";
#endif
  }
  __SYCL_DLL_LOCAL
  static constexpr const char* getFunctionName() {
#ifndef NDEBUG
    return "f16v1::class (lambda)";
#else
    return "";
#endif
  }
  __SYCL_DLL_LOCAL
  static constexpr unsigned getLineNumber() {
#ifndef NDEBUG
    return 391;
#else
    return 0;
#endif
  }
  __SYCL_DLL_LOCAL
  static constexpr unsigned getColumnNumber() {
#ifndef NDEBUG
    return 55;
#else
    return 0;
#endif
  }
  // Returns the size of the kernel object in bytes.
  __SYCL_DLL_LOCAL
  static constexpr long long getKernelSize() { return 40; }
};
template <> struct KernelInfoData<'_', 'Z', 'T', 'S', 'N', '4', 's', 'y', 'c', 'l', '3', '_', 'V', '1', '6', 'd', 'e', 't', 'a', 'i', 'l', '1', '8', 'R', 'o', 'u', 'n', 'd', 'e', 'd', 'R', 'a', 'n', 'g', 'e', 'K', 'e', 'r', 'n', 'e', 'l', 'I', 'N', 'S', '0', '_', '4', 'i', 't', 'e', 'm', 'I', 'L', 'i', '1', 'E', 'L', 'b', '1', 'E', 'E', 'E', 'L', 'i', '1', 'E', 'Z', 'Z', 'N', '5', 'f', '1', '6', 'v', '1', 'L', '8', 'g', 'e', 'm', 'm', '_', 'r', 'e', 's', 'E', 'R', 'N', 'S', '0', '_', '5', 'q', 'u', 'e', 'u', 'e', 'E', 'P', 'K', 'N', 'S', '1', '_', '9', 'h', 'a', 'l', 'f', '_', 'i', 'm', 'p', 'l', '4', 'h', 'a', 'l', 'f', 'E', 'S', 'B', '_', 'P', 'v', 'P', 'K', 'f', 'S', 'E', '_', 'i', 'i', 'i', 'i', 'b', 'j', 'E', 'N', 'K', 'U', 'l', 'R', 'N', 'S', '0', '_', '7', 'h', 'a', 'n', 'd', 'l', 'e', 'r', 'E', 'E', '_', 'c', 'l', 'E', 'S', 'G', '_', 'E', 'U', 'l', 'S', '4', '_', 'E', '_', 'E', 'E'> {
  __SYCL_DLL_LOCAL
  static constexpr const char* getName() { return "_ZTSN4sycl3_V16detail18RoundedRangeKernelINS0_4itemILi1ELb1EEELi1EZZN5f16v1L8gemm_resERNS0_5queueEPKNS1_9half_impl4halfESB_PvPKfSE_iiiibjENKUlRNS0_7handlerEE_clESG_EUlS4_E_EE"; }
  __SYCL_DLL_LOCAL
  static constexpr unsigned getNumParams() { return 2; }
  __SYCL_DLL_LOCAL
  static constexpr const kernel_param_desc_t& getParamDesc(unsigned i) {
    return kernel_signatures[i+155];
  }
  __SYCL_DLL_LOCAL
  static constexpr bool isESIMD() { return 0; }
  __SYCL_DLL_LOCAL
  static constexpr const char* getFileName() {
#ifndef NDEBUG
    return "range_rounding.hpp";
#else
    return "";
#endif
  }
  __SYCL_DLL_LOCAL
  static constexpr const char* getFunctionName() {
#ifndef NDEBUG
    return "::sycl::detail::RoundedRangeKernel<::sycl::item<1, true>, 1, f16v1::(lambda)>";
#else
    return "";
#endif
  }
  __SYCL_DLL_LOCAL
  static constexpr unsigned getLineNumber() {
#ifndef NDEBUG
    return 83;
#else
    return 0;
#endif
  }
  __SYCL_DLL_LOCAL
  static constexpr unsigned getColumnNumber() {
#ifndef NDEBUG
    return 7;
#else
    return 0;
#endif
  }
  // Returns the size of the kernel object in bytes.
  __SYCL_DLL_LOCAL
  static constexpr long long getKernelSize() { return 80; }
};
template <> struct KernelInfoData<'_', 'Z', 'T', 'S', 'Z', 'Z', 'N', '5', 'f', '1', '6', 'v', '1', 'L', '8', 'g', 'e', 'm', 'm', '_', 'r', 'e', 's', 'E', 'R', 'N', '4', 's', 'y', 'c', 'l', '3', '_', 'V', '1', '5', 'q', 'u', 'e', 'u', 'e', 'E', 'P', 'K', 'N', 'S', '1', '_', '6', 'd', 'e', 't', 'a', 'i', 'l', '9', 'h', 'a', 'l', 'f', '_', 'i', 'm', 'p', 'l', '4', 'h', 'a', 'l', 'f', 'E', 'S', '8', '_', 'P', 'v', 'P', 'K', 'f', 'S', 'B', '_', 'i', 'i', 'i', 'i', 'b', 'j', 'E', 'N', 'K', 'U', 'l', 'R', 'N', 'S', '1', '_', '7', 'h', 'a', 'n', 'd', 'l', 'e', 'r', 'E', 'E', '_', 'c', 'l', 'E', 'S', 'D', '_', 'E', 'U', 'l', 'N', 'S', '1', '_', '4', 'i', 't', 'e', 'm', 'I', 'L', 'i', '1', 'E', 'L', 'b', '1', 'E', 'E', 'E', 'E', '_'> {
  __SYCL_DLL_LOCAL
  static constexpr const char* getName() { return "_ZTSZZN5f16v1L8gemm_resERN4sycl3_V15queueEPKNS1_6detail9half_impl4halfES8_PvPKfSB_iiiibjENKUlRNS1_7handlerEE_clESD_EUlNS1_4itemILi1ELb1EEEE_"; }
  __SYCL_DLL_LOCAL
  static constexpr unsigned getNumParams() { return 11; }
  __SYCL_DLL_LOCAL
  static constexpr const kernel_param_desc_t& getParamDesc(unsigned i) {
    return kernel_signatures[i+157];
  }
  __SYCL_DLL_LOCAL
  static constexpr bool isESIMD() { return 1; }
  __SYCL_DLL_LOCAL
  static constexpr const char* getFileName() {
#ifndef NDEBUG
    return "gemm_f16_v1_kernel.hpp";
#else
    return "";
#endif
  }
  __SYCL_DLL_LOCAL
  static constexpr const char* getFunctionName() {
#ifndef NDEBUG
    return "f16v1::class (lambda)";
#else
    return "";
#endif
  }
  __SYCL_DLL_LOCAL
  static constexpr unsigned getLineNumber() {
#ifndef NDEBUG
    return 441;
#else
    return 0;
#endif
  }
  __SYCL_DLL_LOCAL
  static constexpr unsigned getColumnNumber() {
#ifndef NDEBUG
    return 55;
#else
    return 0;
#endif
  }
  // Returns the size of the kernel object in bytes.
  __SYCL_DLL_LOCAL
  static constexpr long long getKernelSize() { return 72; }
};
template <> struct KernelInfoData<'_', 'Z', 'T', 'S', 'Z', 'Z', 'N', '6', 'w', 'b', 'm', 'e', 'g', 'a', '1', '1', 'l', 'a', 'u', 'n', 'c', 'h', '_', 'l', 'e', 'g', '1', 'E', 'R', 'N', '4', 's', 'y', 'c', 'l', '3', '_', 'V', '1', '5', 'q', 'u', 'e', 'u', 'e', 'E', 'P', 'K', 'v', 'b', 'P', 'K', 'N', 'S', '1', '_', '6', 'd', 'e', 't', 'a', 'i', 'l', '9', 'h', 'a', 'l', 'f', '_', 'i', 'm', 'p', 'l', '4', 'h', 'a', 'l', 'f', 'E', 'P', 'S', '8', '_', 'S', 'B', '_', 'S', 'B', '_', 'j', 'j', 'j', 'j', 'j', 'j', 'P', 'K', 'f', 'E', 'N', 'K', 'U', 'l', 'R', 'N', 'S', '1', '_', '7', 'h', 'a', 'n', 'd', 'l', 'e', 'r', 'E', 'E', '_', 'c', 'l', 'E', 'S', 'F', '_', 'E', 'U', 'l', 'N', 'S', '1', '_', '7', 'n', 'd', '_', 'i', 't', 'e', 'm', 'I', 'L', 'i', '1', 'E', 'E', 'E', 'E', '_'> {
  __SYCL_DLL_LOCAL
  static constexpr const char* getName() { return "_ZTSZZN6wbmega11launch_leg1ERN4sycl3_V15queueEPKvbPKNS1_6detail9half_impl4halfEPS8_SB_SB_jjjjjjPKfENKUlRNS1_7handlerEE_clESF_EUlNS1_7nd_itemILi1EEEE_"; }
  __SYCL_DLL_LOCAL
  static constexpr unsigned getNumParams() { return 12; }
  __SYCL_DLL_LOCAL
  static constexpr const kernel_param_desc_t& getParamDesc(unsigned i) {
    return kernel_signatures[i+168];
  }
  __SYCL_DLL_LOCAL
  static constexpr bool isESIMD() { return 1; }
  __SYCL_DLL_LOCAL
  static constexpr const char* getFileName() {
#ifndef NDEBUG
    return "window_block_mega.hpp";
#else
    return "";
#endif
  }
  __SYCL_DLL_LOCAL
  static constexpr const char* getFunctionName() {
#ifndef NDEBUG
    return "wbmega::class (lambda)";
#else
    return "";
#endif
  }
  __SYCL_DLL_LOCAL
  static constexpr unsigned getLineNumber() {
#ifndef NDEBUG
    return 93;
#else
    return 0;
#endif
  }
  __SYCL_DLL_LOCAL
  static constexpr unsigned getColumnNumber() {
#ifndef NDEBUG
    return 13;
#else
    return 0;
#endif
  }
  // Returns the size of the kernel object in bytes.
  __SYCL_DLL_LOCAL
  static constexpr long long getKernelSize() { return 72; }
};
template <> struct KernelInfoData<'_', 'Z', 'T', 'S', 'Z', 'Z', 'N', '6', 'w', 'b', 'm', 'e', 'g', 'a', '1', '5', 'n', 'o', 'r', 'm', 'a', 'l', 'i', 'z', 'e', '_', 'e', 's', 'i', 'm', 'd', 'E', 'R', 'N', '4', 's', 'y', 'c', 'l', '3', '_', 'V', '1', '5', 'q', 'u', 'e', 'u', 'e', 'E', 'P', 'K', 'f', 'P', 'N', 'S', '1', '_', '6', 'd', 'e', 't', 'a', 'i', 'l', '9', 'h', 'a', 'l', 'f', '_', 'i', 'm', 'p', 'l', '4', 'h', 'a', 'l', 'f', 'E', 'S', '9', '_', 'S', '9', '_', 'S', '5', '_', 'j', 'j', 'j', 'E', 'N', 'K', 'U', 'l', 'R', 'N', 'S', '1', '_', '7', 'h', 'a', 'n', 'd', 'l', 'e', 'r', 'E', 'E', '_', 'c', 'l', 'E', 'S', 'B', '_', 'E', 'U', 'l', 'N', 'S', '1', '_', '7', 'n', 'd', '_', 'i', 't', 'e', 'm', 'I', 'L', 'i', '1', 'E', 'E', 'E', 'E', '_'> {
  __SYCL_DLL_LOCAL
  static constexpr const char* getName() { return "_ZTSZZN6wbmega15normalize_esimdERN4sycl3_V15queueEPKfPNS1_6detail9half_impl4halfES9_S9_S5_jjjENKUlRNS1_7handlerEE_clESB_EUlNS1_7nd_itemILi1EEEE_"; }
  __SYCL_DLL_LOCAL
  static constexpr unsigned getNumParams() { return 7; }
  __SYCL_DLL_LOCAL
  static constexpr const kernel_param_desc_t& getParamDesc(unsigned i) {
    return kernel_signatures[i+180];
  }
  __SYCL_DLL_LOCAL
  static constexpr bool isESIMD() { return 1; }
  __SYCL_DLL_LOCAL
  static constexpr const char* getFileName() {
#ifndef NDEBUG
    return "window_block_mega.hpp";
#else
    return "";
#endif
  }
  __SYCL_DLL_LOCAL
  static constexpr const char* getFunctionName() {
#ifndef NDEBUG
    return "wbmega::class (lambda)";
#else
    return "";
#endif
  }
  __SYCL_DLL_LOCAL
  static constexpr unsigned getLineNumber() {
#ifndef NDEBUG
    return 228;
#else
    return 0;
#endif
  }
  __SYCL_DLL_LOCAL
  static constexpr unsigned getColumnNumber() {
#ifndef NDEBUG
    return 13;
#else
    return 0;
#endif
  }
  // Returns the size of the kernel object in bytes.
  __SYCL_DLL_LOCAL
  static constexpr long long getKernelSize() { return 48; }
};
template <> struct KernelInfoData<'_', 'Z', 'T', 'S', 'Z', 'Z', 'N', '6', 'w', 'b', 'm', 'e', 'g', 'a', '1', '4', 'q', 'k', 'v', '_', 'n', 'o', 'r', 'm', '_', 'e', 's', 'i', 'm', 'd', 'E', 'R', 'N', '4', 's', 'y', 'c', 'l', '3', '_', 'V', '1', '5', 'q', 'u', 'e', 'u', 'e', 'E', 'P', 'i', 'P', 'K', 'f', 'S', '6', '_', 'S', '6', '_', 'j', 'j', 'j', 'j', 'E', 'N', 'K', 'U', 'l', 'R', 'N', 'S', '1', '_', '7', 'h', 'a', 'n', 'd', 'l', 'e', 'r', 'E', 'E', '_', 'c', 'l', 'E', 'S', '8', '_', 'E', 'U', 'l', 'N', 'S', '1', '_', '7', 'n', 'd', '_', 'i', 't', 'e', 'm', 'I', 'L', 'i', '1', 'E', 'E', 'E', 'E', '_'> {
  __SYCL_DLL_LOCAL
  static constexpr const char* getName() { return "_ZTSZZN6wbmega14qkv_norm_esimdERN4sycl3_V15queueEPiPKfS6_S6_jjjjENKUlRNS1_7handlerEE_clES8_EUlNS1_7nd_itemILi1EEEE_"; }
  __SYCL_DLL_LOCAL
  static constexpr unsigned getNumParams() { return 7; }
  __SYCL_DLL_LOCAL
  static constexpr const kernel_param_desc_t& getParamDesc(unsigned i) {
    return kernel_signatures[i+187];
  }
  __SYCL_DLL_LOCAL
  static constexpr bool isESIMD() { return 1; }
  __SYCL_DLL_LOCAL
  static constexpr const char* getFileName() {
#ifndef NDEBUG
    return "window_block_mega.hpp";
#else
    return "";
#endif
  }
  __SYCL_DLL_LOCAL
  static constexpr const char* getFunctionName() {
#ifndef NDEBUG
    return "wbmega::class (lambda)";
#else
    return "";
#endif
  }
  __SYCL_DLL_LOCAL
  static constexpr unsigned getLineNumber() {
#ifndef NDEBUG
    return 303;
#else
    return 0;
#endif
  }
  __SYCL_DLL_LOCAL
  static constexpr unsigned getColumnNumber() {
#ifndef NDEBUG
    return 13;
#else
    return 0;
#endif
  }
  // Returns the size of the kernel object in bytes.
  __SYCL_DLL_LOCAL
  static constexpr long long getKernelSize() { return 48; }
};
template <> struct KernelInfoData<'_', 'Z', 'T', 'S', 'Z', 'Z', 'N', '6', 'w', 'b', 'm', 'e', 'g', 'a', '1', '4', 'l', 'a', 'u', 'n', 'c', 'h', '_', 'm', 'e', 'g', 'a', '2', '5', '6', 'E', 'R', 'N', '4', 's', 'y', 'c', 'l', '3', '_', 'V', '1', '5', 'q', 'u', 'e', 'u', 'e', 'E', 'P', 'K', 'v', 'b', 'P', 'K', 'N', 'S', '1', '_', '6', 'd', 'e', 't', 'a', 'i', 'l', '9', 'h', 'a', 'l', 'f', '_', 'i', 'm', 'p', 'l', '4', 'h', 'a', 'l', 'f', 'E', 'P', 'S', '8', '_', 'S', 'B', '_', 'S', 'B', '_', 'j', 'j', 'j', 'j', 'j', 'j', 'P', 'K', 'f', 'E', 'N', 'K', 'U', 'l', 'R', 'N', 'S', '1', '_', '7', 'h', 'a', 'n', 'd', 'l', 'e', 'r', 'E', 'E', '_', 'c', 'l', 'E', 'S', 'F', '_', 'E', 'U', 'l', 'N', 'S', '1', '_', '7', 'n', 'd', '_', 'i', 't', 'e', 'm', 'I', 'L', 'i', '1', 'E', 'E', 'E', 'E', '_'> {
  __SYCL_DLL_LOCAL
  static constexpr const char* getName() { return "_ZTSZZN6wbmega14launch_mega256ERN4sycl3_V15queueEPKvbPKNS1_6detail9half_impl4halfEPS8_SB_SB_jjjjjjPKfENKUlRNS1_7handlerEE_clESF_EUlNS1_7nd_itemILi1EEEE_"; }
  __SYCL_DLL_LOCAL
  static constexpr unsigned getNumParams() { return 12; }
  __SYCL_DLL_LOCAL
  static constexpr const kernel_param_desc_t& getParamDesc(unsigned i) {
    return kernel_signatures[i+194];
  }
  __SYCL_DLL_LOCAL
  static constexpr bool isESIMD() { return 1; }
  __SYCL_DLL_LOCAL
  static constexpr const char* getFileName() {
#ifndef NDEBUG
    return "window_block_mega.hpp";
#else
    return "";
#endif
  }
  __SYCL_DLL_LOCAL
  static constexpr const char* getFunctionName() {
#ifndef NDEBUG
    return "wbmega::class (lambda)";
#else
    return "";
#endif
  }
  __SYCL_DLL_LOCAL
  static constexpr unsigned getLineNumber() {
#ifndef NDEBUG
    return 381;
#else
    return 0;
#endif
  }
  __SYCL_DLL_LOCAL
  static constexpr unsigned getColumnNumber() {
#ifndef NDEBUG
    return 13;
#else
    return 0;
#endif
  }
  // Returns the size of the kernel object in bytes.
  __SYCL_DLL_LOCAL
  static constexpr long long getKernelSize() { return 72; }
};
template <> struct KernelInfoData<'_', 'Z', 'T', 'S', 'Z', 'Z', 'N', '6', 'w', 'b', 'm', 'e', 'g', 'a', '1', '1', 'l', 'a', 'u', 'n', 'c', 'h', '_', 'f', 'u', 'l', 'l', 'E', 'R', 'N', '4', 's', 'y', 'c', 'l', '3', '_', 'V', '1', '5', 'q', 'u', 'e', 'u', 'e', 'E', 'P', 'K', 'v', 'b', 'P', 'K', 'N', 'S', '1', '_', '6', 'd', 'e', 't', 'a', 'i', 'l', '9', 'h', 'a', 'l', 'f', '_', 'i', 'm', 'p', 'l', '4', 'h', 'a', 'l', 'f', 'E', 'S', 'A', '_', 'P', 'S', '8', '_', 'P', 'f', 'P', 'K', 'f', 'S', 'E', '_', 'S', 'E', '_', 'j', 'j', 'j', 'j', 'j', 'j', 'j', 'b', 'j', 'S', 'B', '_', 'E', 'N', 'K', 'U', 'l', 'R', 'N', 'S', '1', '_', '7', 'h', 'a', 'n', 'd', 'l', 'e', 'r', 'E', 'E', '_', 'c', 'l', 'E', 'S', 'G', '_', 'E', 'U', 'l', 'N', 'S', '1', '_', '7', 'n', 'd', '_', 'i', 't', 'e', 'm', 'I', 'L', 'i', '1', 'E', 'E', 'E', 'E', '_'> {
  __SYCL_DLL_LOCAL
  static constexpr const char* getName() { return "_ZTSZZN6wbmega11launch_fullERN4sycl3_V15queueEPKvbPKNS1_6detail9half_impl4halfESA_PS8_PfPKfSE_SE_jjjjjjjbjSB_ENKUlRNS1_7handlerEE_clESG_EUlNS1_7nd_itemILi1EEEE_"; }
  __SYCL_DLL_LOCAL
  static constexpr unsigned getNumParams() { return 18; }
  __SYCL_DLL_LOCAL
  static constexpr const kernel_param_desc_t& getParamDesc(unsigned i) {
    return kernel_signatures[i+206];
  }
  __SYCL_DLL_LOCAL
  static constexpr bool isESIMD() { return 1; }
  __SYCL_DLL_LOCAL
  static constexpr const char* getFileName() {
#ifndef NDEBUG
    return "window_block_mega.hpp";
#else
    return "";
#endif
  }
  __SYCL_DLL_LOCAL
  static constexpr const char* getFunctionName() {
#ifndef NDEBUG
    return "wbmega::class (lambda)";
#else
    return "";
#endif
  }
  __SYCL_DLL_LOCAL
  static constexpr unsigned getLineNumber() {
#ifndef NDEBUG
    return 484;
#else
    return 0;
#endif
  }
  __SYCL_DLL_LOCAL
  static constexpr unsigned getColumnNumber() {
#ifndef NDEBUG
    return 13;
#else
    return 0;
#endif
  }
  // Returns the size of the kernel object in bytes.
  __SYCL_DLL_LOCAL
  static constexpr long long getKernelSize() { return 112; }
};
template <> struct KernelInfoData<'_', 'Z', 'T', 'S', 'Z', 'Z', 'N', '6', 'w', 'b', 'm', 'e', 'g', 'a', '2', '2', 'q', 'k', 'v', '_', 'n', 'o', 'r', 'm', '_', 's', 'c', 'a', 't', 't', 'e', 'r', '_', 'e', 's', 'i', 'm', 'd', 'E', 'R', 'N', '4', 's', 'y', 'c', 'l', '3', '_', 'V', '1', '5', 'q', 'u', 'e', 'u', 'e', 'E', 'P', 'K', 'i', 'P', 'N', 'S', '1', '_', '6', 'd', 'e', 't', 'a', 'i', 'l', '9', 'h', 'a', 'l', 'f', '_', 'i', 'm', 'p', 'l', '4', 'h', 'a', 'l', 'f', 'E', 'S', '9', '_', 'S', '9', '_', 'P', 'K', 'f', 'S', 'B', '_', 'S', 'B', '_', 'j', 'j', 'j', 'j', 'j', 'E', 'N', 'K', 'U', 'l', 'R', 'N', 'S', '1', '_', '7', 'h', 'a', 'n', 'd', 'l', 'e', 'r', 'E', 'E', '_', 'c', 'l', 'E', 'S', 'D', '_', 'E', 'U', 'l', 'N', 'S', '1', '_', '7', 'n', 'd', '_', 'i', 't', 'e', 'm', 'I', 'L', 'i', '1', 'E', 'E', 'E', 'E', '_'> {
  __SYCL_DLL_LOCAL
  static constexpr const char* getName() { return "_ZTSZZN6wbmega22qkv_norm_scatter_esimdERN4sycl3_V15queueEPKiPNS1_6detail9half_impl4halfES9_S9_PKfSB_SB_jjjjjENKUlRNS1_7handlerEE_clESD_EUlNS1_7nd_itemILi1EEEE_"; }
  __SYCL_DLL_LOCAL
  static constexpr unsigned getNumParams() { return 11; }
  __SYCL_DLL_LOCAL
  static constexpr const kernel_param_desc_t& getParamDesc(unsigned i) {
    return kernel_signatures[i+224];
  }
  __SYCL_DLL_LOCAL
  static constexpr bool isESIMD() { return 1; }
  __SYCL_DLL_LOCAL
  static constexpr const char* getFileName() {
#ifndef NDEBUG
    return "window_block_mega.hpp";
#else
    return "";
#endif
  }
  __SYCL_DLL_LOCAL
  static constexpr const char* getFunctionName() {
#ifndef NDEBUG
    return "wbmega::class (lambda)";
#else
    return "";
#endif
  }
  __SYCL_DLL_LOCAL
  static constexpr unsigned getLineNumber() {
#ifndef NDEBUG
    return 702;
#else
    return 0;
#endif
  }
  __SYCL_DLL_LOCAL
  static constexpr unsigned getColumnNumber() {
#ifndef NDEBUG
    return 13;
#else
    return 0;
#endif
  }
  // Returns the size of the kernel object in bytes.
  __SYCL_DLL_LOCAL
  static constexpr long long getKernelSize() { return 80; }
};
template <> struct KernelInfoData<'_', 'Z', 'T', 'S', 'N', '4', 's', 'y', 'c', 'l', '3', '_', 'V', '1', '6', 'd', 'e', 't', 'a', 'i', 'l', '1', '8', 'R', 'o', 'u', 'n', 'd', 'e', 'd', 'R', 'a', 'n', 'g', 'e', 'K', 'e', 'r', 'n', 'e', 'l', 'I', 'N', 'S', '0', '_', '4', 'i', 't', 'e', 'm', 'I', 'L', 'i', '1', 'E', 'L', 'b', '1', 'E', 'E', 'E', 'L', 'i', '1', 'E', 'Z', 'N', '6', 'w', 'b', 'm', 'e', 'g', 'a', '1', '9', 'q', 'k', 'v', '_', 'n', 'o', 'r', 'm', '_', 's', 'c', 'a', 't', 't', 'e', 'r', '_', 'v', '2', 'E', 'R', 'N', 'S', '0', '_', '5', 'q', 'u', 'e', 'u', 'e', 'E', 'P', 'K', 'i', 'P', 'N', 'S', '1', '_', '9', 'h', 'a', 'l', 'f', '_', 'i', 'm', 'p', 'l', '4', 'h', 'a', 'l', 'f', 'E', 'S', 'C', '_', 'S', 'C', '_', 'P', 'K', 'f', 'S', 'E', '_', 'S', 'E', '_', 'j', 'j', 'j', 'j', 'j', 'E', 'U', 'l', 'S', '4', '_', 'E', '_', 'E', 'E'> {
  __SYCL_DLL_LOCAL
  static constexpr const char* getName() { return "_ZTSN4sycl3_V16detail18RoundedRangeKernelINS0_4itemILi1ELb1EEELi1EZN6wbmega19qkv_norm_scatter_v2ERNS0_5queueEPKiPNS1_9half_impl4halfESC_SC_PKfSE_SE_jjjjjEUlS4_E_EE"; }
  __SYCL_DLL_LOCAL
  static constexpr unsigned getNumParams() { return 2; }
  __SYCL_DLL_LOCAL
  static constexpr const kernel_param_desc_t& getParamDesc(unsigned i) {
    return kernel_signatures[i+235];
  }
  __SYCL_DLL_LOCAL
  static constexpr bool isESIMD() { return 0; }
  __SYCL_DLL_LOCAL
  static constexpr const char* getFileName() {
#ifndef NDEBUG
    return "range_rounding.hpp";
#else
    return "";
#endif
  }
  __SYCL_DLL_LOCAL
  static constexpr const char* getFunctionName() {
#ifndef NDEBUG
    return "::sycl::detail::RoundedRangeKernel<::sycl::item<1, true>, 1, wbmega::(lambda)>";
#else
    return "";
#endif
  }
  __SYCL_DLL_LOCAL
  static constexpr unsigned getLineNumber() {
#ifndef NDEBUG
    return 83;
#else
    return 0;
#endif
  }
  __SYCL_DLL_LOCAL
  static constexpr unsigned getColumnNumber() {
#ifndef NDEBUG
    return 7;
#else
    return 0;
#endif
  }
  // Returns the size of the kernel object in bytes.
  __SYCL_DLL_LOCAL
  static constexpr long long getKernelSize() { return 96; }
};
template <> struct KernelInfoData<'_', 'Z', 'T', 'S', 'Z', 'N', '6', 'w', 'b', 'm', 'e', 'g', 'a', '1', '9', 'q', 'k', 'v', '_', 'n', 'o', 'r', 'm', '_', 's', 'c', 'a', 't', 't', 'e', 'r', '_', 'v', '2', 'E', 'R', 'N', '4', 's', 'y', 'c', 'l', '3', '_', 'V', '1', '5', 'q', 'u', 'e', 'u', 'e', 'E', 'P', 'K', 'i', 'P', 'N', 'S', '1', '_', '6', 'd', 'e', 't', 'a', 'i', 'l', '9', 'h', 'a', 'l', 'f', '_', 'i', 'm', 'p', 'l', '4', 'h', 'a', 'l', 'f', 'E', 'S', '9', '_', 'S', '9', '_', 'P', 'K', 'f', 'S', 'B', '_', 'S', 'B', '_', 'j', 'j', 'j', 'j', 'j', 'E', 'U', 'l', 'N', 'S', '1', '_', '4', 'i', 't', 'e', 'm', 'I', 'L', 'i', '1', 'E', 'L', 'b', '1', 'E', 'E', 'E', 'E', '_'> {
  __SYCL_DLL_LOCAL
  static constexpr const char* getName() { return "_ZTSZN6wbmega19qkv_norm_scatter_v2ERN4sycl3_V15queueEPKiPNS1_6detail9half_impl4halfES9_S9_PKfSB_SB_jjjjjEUlNS1_4itemILi1ELb1EEEE_"; }
  __SYCL_DLL_LOCAL
  static constexpr unsigned getNumParams() { return 11; }
  __SYCL_DLL_LOCAL
  static constexpr const kernel_param_desc_t& getParamDesc(unsigned i) {
    return kernel_signatures[i+237];
  }
  __SYCL_DLL_LOCAL
  static constexpr bool isESIMD() { return 1; }
  __SYCL_DLL_LOCAL
  static constexpr const char* getFileName() {
#ifndef NDEBUG
    return "window_block_mega.hpp";
#else
    return "";
#endif
  }
  __SYCL_DLL_LOCAL
  static constexpr const char* getFunctionName() {
#ifndef NDEBUG
    return "wbmega::class (lambda)";
#else
    return "";
#endif
  }
  __SYCL_DLL_LOCAL
  static constexpr unsigned getLineNumber() {
#ifndef NDEBUG
    return 779;
#else
    return 0;
#endif
  }
  __SYCL_DLL_LOCAL
  static constexpr unsigned getColumnNumber() {
#ifndef NDEBUG
    return 55;
#else
    return 0;
#endif
  }
  // Returns the size of the kernel object in bytes.
  __SYCL_DLL_LOCAL
  static constexpr long long getKernelSize() { return 88; }
};
template <> struct KernelInfoData<'_', 'Z', 'T', 'S', 'Z', 'Z', 'N', '6', 'w', 'b', 'm', 'e', 'g', 'a', '2', '6', 'q', 'k', 'v', '_', 'n', 'o', 'r', 'm', '_', 's', 'c', 'a', 't', 't', 'e', 'r', '_', 'v', 'i', 't', '_', 'e', 's', 'i', 'm', 'd', 'E', 'R', 'N', '4', 's', 'y', 'c', 'l', '3', '_', 'V', '1', '5', 'q', 'u', 'e', 'u', 'e', 'E', 'P', 'K', 'i', 'P', 'N', 'S', '1', '_', '6', 'd', 'e', 't', 'a', 'i', 'l', '9', 'h', 'a', 'l', 'f', '_', 'i', 'm', 'p', 'l', '4', 'h', 'a', 'l', 'f', 'E', 'S', '9', '_', 'S', '9', '_', 'P', 'K', 'f', 'S', 'B', '_', 'S', 'B', '_', 'j', 'j', 'j', 'j', 'j', 'S', 'B', '_', 'P', 'f', 'E', 'N', 'K', 'U', 'l', 'R', 'N', 'S', '1', '_', '7', 'h', 'a', 'n', 'd', 'l', 'e', 'r', 'E', 'E', '_', 'c', 'l', 'E', 'S', 'E', '_', 'E', 'U', 'l', 'N', 'S', '1', '_', '7', 'n', 'd', '_', 'i', 't', 'e', 'm', 'I', 'L', 'i', '1', 'E', 'E', 'E', 'E', '_'> {
  __SYCL_DLL_LOCAL
  static constexpr const char* getName() { return "_ZTSZZN6wbmega26qkv_norm_scatter_vit_esimdERN4sycl3_V15queueEPKiPNS1_6detail9half_impl4halfES9_S9_PKfSB_SB_jjjjjSB_PfENKUlRNS1_7handlerEE_clESE_EUlNS1_7nd_itemILi1EEEE_"; }
  __SYCL_DLL_LOCAL
  static constexpr unsigned getNumParams() { return 13; }
  __SYCL_DLL_LOCAL
  static constexpr const kernel_param_desc_t& getParamDesc(unsigned i) {
    return kernel_signatures[i+248];
  }
  __SYCL_DLL_LOCAL
  static constexpr bool isESIMD() { return 1; }
  __SYCL_DLL_LOCAL
  static constexpr const char* getFileName() {
#ifndef NDEBUG
    return "window_block_mega.hpp";
#else
    return "";
#endif
  }
  __SYCL_DLL_LOCAL
  static constexpr const char* getFunctionName() {
#ifndef NDEBUG
    return "wbmega::class (lambda)";
#else
    return "";
#endif
  }
  __SYCL_DLL_LOCAL
  static constexpr unsigned getLineNumber() {
#ifndef NDEBUG
    return 854;
#else
    return 0;
#endif
  }
  __SYCL_DLL_LOCAL
  static constexpr unsigned getColumnNumber() {
#ifndef NDEBUG
    return 13;
#else
    return 0;
#endif
  }
  // Returns the size of the kernel object in bytes.
  __SYCL_DLL_LOCAL
  static constexpr long long getKernelSize() { return 96; }
};
template <> struct KernelInfoData<'_', 'Z', 'T', 'S', 'Z', 'Z', 'N', '4', 'w', 'b', 'v', '3', '9', 'l', 'a', 'u', 'n', 'c', 'h', '_', 'v', '3', 'E', 'R', 'N', '4', 's', 'y', 'c', 'l', '3', '_', 'V', '1', '5', 'q', 'u', 'e', 'u', 'e', 'E', 'P', 'K', 'v', 'b', 'P', 'K', 'N', 'S', '1', '_', '6', 'd', 'e', 't', 'a', 'i', 'l', '9', 'h', 'a', 'l', 'f', '_', 'i', 'm', 'p', 'l', '4', 'h', 'a', 'l', 'f', 'E', 'S', 'A', '_', 'P', 'S', '8', '_', 'P', 'f', 'P', 'K', 'f', 'S', 'E', '_', 'S', 'E', '_', 'j', 'j', 'j', 'j', 'j', 'j', 'j', 'b', 'j', 'S', 'B', '_', 'E', 'N', 'K', 'U', 'l', 'R', 'N', 'S', '1', '_', '7', 'h', 'a', 'n', 'd', 'l', 'e', 'r', 'E', 'E', '_', 'c', 'l', 'E', 'S', 'G', '_', 'E', 'U', 'l', 'N', 'S', '1', '_', '7', 'n', 'd', '_', 'i', 't', 'e', 'm', 'I', 'L', 'i', '1', 'E', 'E', 'E', 'E', '_'> {
  __SYCL_DLL_LOCAL
  static constexpr const char* getName() { return "_ZTSZZN4wbv39launch_v3ERN4sycl3_V15queueEPKvbPKNS1_6detail9half_impl4halfESA_PS8_PfPKfSE_SE_jjjjjjjbjSB_ENKUlRNS1_7handlerEE_clESG_EUlNS1_7nd_itemILi1EEEE_"; }
  __SYCL_DLL_LOCAL
  static constexpr unsigned getNumParams() { return 18; }
  __SYCL_DLL_LOCAL
  static constexpr const kernel_param_desc_t& getParamDesc(unsigned i) {
    return kernel_signatures[i+261];
  }
  __SYCL_DLL_LOCAL
  static constexpr bool isESIMD() { return 1; }
  __SYCL_DLL_LOCAL
  static constexpr const char* getFileName() {
#ifndef NDEBUG
    return "window_block_v3.hpp";
#else
    return "";
#endif
  }
  __SYCL_DLL_LOCAL
  static constexpr const char* getFunctionName() {
#ifndef NDEBUG
    return "wbv3::class (lambda)";
#else
    return "";
#endif
  }
  __SYCL_DLL_LOCAL
  static constexpr unsigned getLineNumber() {
#ifndef NDEBUG
    return 294;
#else
    return 0;
#endif
  }
  __SYCL_DLL_LOCAL
  static constexpr unsigned getColumnNumber() {
#ifndef NDEBUG
    return 13;
#else
    return 0;
#endif
  }
  // Returns the size of the kernel object in bytes.
  __SYCL_DLL_LOCAL
  static constexpr long long getKernelSize() { return 112; }
};
template <> struct KernelInfoData<'_', 'Z', 'T', 'S', 'Z', 'Z', '1', '3', 'l', 'a', 'u', 'n', 'c', 'h', '_', 'v', '4', 'f', 'u', 'l', 'l', 'I', 'L', 'i', '0', 'E', 'E', 'N', '4', 's', 'y', 'c', 'l', '3', '_', 'V', '1', '5', 'e', 'v', 'e', 'n', 't', 'E', 'R', 'N', 'S', '1', '_', '5', 'q', 'u', 'e', 'u', 'e', 'E', 'P', 'K', 'v', 'b', 'P', 'K', 'N', 'S', '1', '_', '6', 'd', 'e', 't', 'a', 'i', 'l', '9', 'h', 'a', 'l', 'f', '_', 'i', 'm', 'p', 'l', '4', 'h', 'a', 'l', 'f', 'E', 'S', 'B', '_', 'P', 'S', '9', '_', 'P', 'f', 'P', 'K', 'f', 'S', 'F', '_', 'S', 'F', '_', 'j', 'j', 'j', 'j', 'j', 'j', 'j', 'b', 'j', 'S', 'C', '_', 'E', 'N', 'K', 'U', 'l', 'R', 'N', 'S', '1', '_', '7', 'h', 'a', 'n', 'd', 'l', 'e', 'r', 'E', 'E', '_', 'c', 'l', 'E', 'S', 'H', '_', 'E', 'U', 'l', 'N', 'S', '1', '_', '7', 'n', 'd', '_', 'i', 't', 'e', 'm', 'I', 'L', 'i', '1', 'E', 'E', 'E', 'E', '_'> {
  __SYCL_DLL_LOCAL
  static constexpr const char* getName() { return "_ZTSZZ13launch_v4fullILi0EEN4sycl3_V15eventERNS1_5queueEPKvbPKNS1_6detail9half_impl4halfESB_PS9_PfPKfSF_SF_jjjjjjjbjSC_ENKUlRNS1_7handlerEE_clESH_EUlNS1_7nd_itemILi1EEEE_"; }
  __SYCL_DLL_LOCAL
  static constexpr unsigned getNumParams() { return 19; }
  __SYCL_DLL_LOCAL
  static constexpr const kernel_param_desc_t& getParamDesc(unsigned i) {
    return kernel_signatures[i+279];
  }
  __SYCL_DLL_LOCAL
  static constexpr bool isESIMD() { return 1; }
  __SYCL_DLL_LOCAL
  static constexpr const char* getFileName() {
#ifndef NDEBUG
    return "bench_v4full.cpp";
#else
    return "";
#endif
  }
  __SYCL_DLL_LOCAL
  static constexpr const char* getFunctionName() {
#ifndef NDEBUG
    return "class (lambda)";
#else
    return "";
#endif
  }
  __SYCL_DLL_LOCAL
  static constexpr unsigned getLineNumber() {
#ifndef NDEBUG
    return 51;
#else
    return 0;
#endif
  }
  __SYCL_DLL_LOCAL
  static constexpr unsigned getColumnNumber() {
#ifndef NDEBUG
    return 13;
#else
    return 0;
#endif
  }
  // Returns the size of the kernel object in bytes.
  __SYCL_DLL_LOCAL
  static constexpr long long getKernelSize() { return 120; }
};
template <> struct KernelInfoData<'_', 'Z', 'T', 'S', 'Z', 'Z', '1', '3', 'l', 'a', 'u', 'n', 'c', 'h', '_', 'v', '4', 'f', 'u', 'l', 'l', 'I', 'L', 'i', '8', 'E', 'E', 'N', '4', 's', 'y', 'c', 'l', '3', '_', 'V', '1', '5', 'e', 'v', 'e', 'n', 't', 'E', 'R', 'N', 'S', '1', '_', '5', 'q', 'u', 'e', 'u', 'e', 'E', 'P', 'K', 'v', 'b', 'P', 'K', 'N', 'S', '1', '_', '6', 'd', 'e', 't', 'a', 'i', 'l', '9', 'h', 'a', 'l', 'f', '_', 'i', 'm', 'p', 'l', '4', 'h', 'a', 'l', 'f', 'E', 'S', 'B', '_', 'P', 'S', '9', '_', 'P', 'f', 'P', 'K', 'f', 'S', 'F', '_', 'S', 'F', '_', 'j', 'j', 'j', 'j', 'j', 'j', 'j', 'b', 'j', 'S', 'C', '_', 'E', 'N', 'K', 'U', 'l', 'R', 'N', 'S', '1', '_', '7', 'h', 'a', 'n', 'd', 'l', 'e', 'r', 'E', 'E', '_', 'c', 'l', 'E', 'S', 'H', '_', 'E', 'U', 'l', 'N', 'S', '1', '_', '7', 'n', 'd', '_', 'i', 't', 'e', 'm', 'I', 'L', 'i', '1', 'E', 'E', 'E', 'E', '_'> {
  __SYCL_DLL_LOCAL
  static constexpr const char* getName() { return "_ZTSZZ13launch_v4fullILi8EEN4sycl3_V15eventERNS1_5queueEPKvbPKNS1_6detail9half_impl4halfESB_PS9_PfPKfSF_SF_jjjjjjjbjSC_ENKUlRNS1_7handlerEE_clESH_EUlNS1_7nd_itemILi1EEEE_"; }
  __SYCL_DLL_LOCAL
  static constexpr unsigned getNumParams() { return 19; }
  __SYCL_DLL_LOCAL
  static constexpr const kernel_param_desc_t& getParamDesc(unsigned i) {
    return kernel_signatures[i+298];
  }
  __SYCL_DLL_LOCAL
  static constexpr bool isESIMD() { return 1; }
  __SYCL_DLL_LOCAL
  static constexpr const char* getFileName() {
#ifndef NDEBUG
    return "bench_v4full.cpp";
#else
    return "";
#endif
  }
  __SYCL_DLL_LOCAL
  static constexpr const char* getFunctionName() {
#ifndef NDEBUG
    return "class (lambda)";
#else
    return "";
#endif
  }
  __SYCL_DLL_LOCAL
  static constexpr unsigned getLineNumber() {
#ifndef NDEBUG
    return 51;
#else
    return 0;
#endif
  }
  __SYCL_DLL_LOCAL
  static constexpr unsigned getColumnNumber() {
#ifndef NDEBUG
    return 13;
#else
    return 0;
#endif
  }
  // Returns the size of the kernel object in bytes.
  __SYCL_DLL_LOCAL
  static constexpr long long getKernelSize() { return 120; }
};
template <> struct KernelInfoData<'_', 'Z', 'T', 'S', 'Z', 'Z', '1', '3', 'l', 'a', 'u', 'n', 'c', 'h', '_', 'v', '4', 'f', 'u', 'l', 'l', 'I', 'L', 'i', '3', '2', 'E', 'E', 'N', '4', 's', 'y', 'c', 'l', '3', '_', 'V', '1', '5', 'e', 'v', 'e', 'n', 't', 'E', 'R', 'N', 'S', '1', '_', '5', 'q', 'u', 'e', 'u', 'e', 'E', 'P', 'K', 'v', 'b', 'P', 'K', 'N', 'S', '1', '_', '6', 'd', 'e', 't', 'a', 'i', 'l', '9', 'h', 'a', 'l', 'f', '_', 'i', 'm', 'p', 'l', '4', 'h', 'a', 'l', 'f', 'E', 'S', 'B', '_', 'P', 'S', '9', '_', 'P', 'f', 'P', 'K', 'f', 'S', 'F', '_', 'S', 'F', '_', 'j', 'j', 'j', 'j', 'j', 'j', 'j', 'b', 'j', 'S', 'C', '_', 'E', 'N', 'K', 'U', 'l', 'R', 'N', 'S', '1', '_', '7', 'h', 'a', 'n', 'd', 'l', 'e', 'r', 'E', 'E', '_', 'c', 'l', 'E', 'S', 'H', '_', 'E', 'U', 'l', 'N', 'S', '1', '_', '7', 'n', 'd', '_', 'i', 't', 'e', 'm', 'I', 'L', 'i', '1', 'E', 'E', 'E', 'E', '_'> {
  __SYCL_DLL_LOCAL
  static constexpr const char* getName() { return "_ZTSZZ13launch_v4fullILi32EEN4sycl3_V15eventERNS1_5queueEPKvbPKNS1_6detail9half_impl4halfESB_PS9_PfPKfSF_SF_jjjjjjjbjSC_ENKUlRNS1_7handlerEE_clESH_EUlNS1_7nd_itemILi1EEEE_"; }
  __SYCL_DLL_LOCAL
  static constexpr unsigned getNumParams() { return 19; }
  __SYCL_DLL_LOCAL
  static constexpr const kernel_param_desc_t& getParamDesc(unsigned i) {
    return kernel_signatures[i+317];
  }
  __SYCL_DLL_LOCAL
  static constexpr bool isESIMD() { return 1; }
  __SYCL_DLL_LOCAL
  static constexpr const char* getFileName() {
#ifndef NDEBUG
    return "bench_v4full.cpp";
#else
    return "";
#endif
  }
  __SYCL_DLL_LOCAL
  static constexpr const char* getFunctionName() {
#ifndef NDEBUG
    return "class (lambda)";
#else
    return "";
#endif
  }
  __SYCL_DLL_LOCAL
  static constexpr unsigned getLineNumber() {
#ifndef NDEBUG
    return 51;
#else
    return 0;
#endif
  }
  __SYCL_DLL_LOCAL
  static constexpr unsigned getColumnNumber() {
#ifndef NDEBUG
    return 13;
#else
    return 0;
#endif
  }
  // Returns the size of the kernel object in bytes.
  __SYCL_DLL_LOCAL
  static constexpr long long getKernelSize() { return 120; }
};

} // namespace detail
} // namespace _V1
} // namespace sycl
