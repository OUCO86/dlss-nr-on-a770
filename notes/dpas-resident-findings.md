// dpas-intrinsic resident notes (section 96): bench_srcmodes A/B results on a PLAIN
// nd_range kernel (sg_size 8, group_barrier, local_accessor SLM) vs the shipped
// f16v1::gemm's own operand path.
//
//   M0 broadcast ctor        PASS (16=K)
//   M1 global block tag<16>  PASS  <-- same addressing as gemm_f16_v1_kernel.hpp:66-69
//   M2 global block tag<8>   PASS
//   M3 SLM   block tag<16>   FAIL (0)
//   M4 SLM   block padded16  FAIL (0)
//   M5 SLM   block tag<4>    FAIL (0)
//   M6 SLM   scalar a[i]=hb FAIL (0)   <-- not a block-load issue: esimd::simd cannot
//                                            source ANY value from local_accessor in a
//                                            plain kernel; joint_matrix reads local fine
//                                            (its fragment IS the storage class).
// CONCLUSION: for esimd::xmx::dpas in a plain kernel, operands MUST come from GLOBAL
// (the way the shipped split f16v1::gemm already does it: Ap/Bp are device pool buffers).
// SLM-fed dpas is silently zero. So the dpas-intrinsic resident kernel keeps the joint
// architecture's STASH idea but moves Q/K/V/weights pack tiles to GLOBAL scratch, fed to
// dpas as global block loads tag<16> (proven layout = pack_a16/pack_b16 index maps,
// 39-gate-bit-exact). Cross-subgroup tile visibility on global needs explicit fence +
// group_barrier (plain-kernel global writes are not ordered by the barrier alone).
//
// The 100% bit-exact joint resident (window_block_resident.hpp, 921ms, SLM-fed) is
// KEPT as the correctness oracle; the new dpas resident targets the 45ms shape.
// bench_srcmodes.cpp is this finding's isolation instrument.
## probes 5-7 (bench_esnd2 self-bugs fixed; bench_esnd3 D/F + bench_lanesplit P1)
- bench_esnd2's C1 "224 zeros" and C2 "64 zeros" were MY harness bugs (local-id output
  race; B-block never re-filled). Fixed in bench_esnd3:
- D: SYCL_ESIMD_KERNEL + nd_range(128/128) ONE workgroup multi-subgroup: in-kernel scalar
  writes to GLOBAL scratch + group_barrier + block-loads tag<16> + dpas -> ALL 128 lanes
  see ALL other subgroups' writes (16=128/128, zero=0). NO crash, NO staleness.
- F (two-kernel control) identical result -> the barrier handoff == launch-boundary
  handoff for this pattern.
- P1 (plain nd + esimd body, row-signature A): every lane identical c0 + sg probe "1" =>
  plain kernel runs esimd::simd ops at SIMD1 REDUNDANTLY (functionally right, no speedup);
  the ESIMD-marked kernel is where the real SIMD happens (f16v1 shapes = SIMD16).
- => V2 BLUEPRINT: SYCL_ESIMD_KERNEL nd_range, ONE workgroup per window, task per gemm
  tile, ALL stage handoff through GLOBAL per-window scratch (never esimd::slm_init),
  standard group_barrier. Proven pieces: f16v1::gemm dpas body (39 gates), pack_a16/
  pack_b16/b16_t maps (bit-exact), ctree normalize+weights_pair_u32+recip chain (joint
  100% oracle), publish/residual chains (joint 100%). Old DEVICE_LOST poison = slm_init
  only; global-scratch handoff sidesteps it (D/F prove).

## P4 softmax vectorization: REJECTED (section 97, bench_p4vec.cpp)
- Current ladder (post P2/P6 vectorization, recorded walk, warm avg): empty=75.7, +P0=81.5,
  +QKV=90.3, +norm=97.2 (norm now only +6.9, was +23), +scores=105.0, +softmax=122.1
  (softmax +17.1 = the biggest remaining single item), +attnV=122.5, +outproj=126.3, full~131.
- bench_p4vec A/B (scalar chain vs the v2 vectorized chain, same random rows): weights differ
  2111/131072 (1.6%), first at row0 col58: 0.00018692 vs 0.000183105 (1 ULP). The divergence
  is in the affine->clamp->bit-pack path BEFORE total/recip, so it is NOT the sequential-sum
  order (that was the earlier hypothesis). convert<half> is RNE (P2 uses it at 100%), so the
  1-ULP is a sub-ULP f32 difference in the affine that lands on a half tie at the bit-pack.
  Could not pin it by inspection in the time budget. DECISION: keep P4 SCALAR (proven 100%);
  softmax's +17ms is not worth risking the bit-exact gate. P7 (+4.7) has the gate-FMA trap too.
