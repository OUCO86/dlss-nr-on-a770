src = open('window_block_mega.hpp', 'r', encoding='utf-8').read()

# --- fix A: drop wf[64] (reload VAL in the scaling loop; same j*8+e order) ---
oldA = """                for(int r=0;r<8;++r){
                    uint qrow=q0+r;
                    float total=0.f; float wf[64];
                    for(int j=0;j<8;++j){ esimd::simd<float,8> s=esimd::slm_block_load<float,8>(VAL+r*256u+j*32u,esimd::overaligned_tag<16>{});
                        for(int e=0;e<8;++e){ float wv=s[e]; total+=wv; wf[j*8u+e]=wv; } }
                    float trh=eh_round(total);
                    float recip=eh_round(1.0f/trh);   // softmax recip = 1/half(total) (no sqrt)
                    esimd::simd<half,64> w;
                    for(int e=0;e<64;++e){ float v=eh_mul(wf[e],recip); w[e]=half(qr_e4m3_scalar(v)); }
                    esimd::slm_block_store(SCR+qrow*128u,w,esimd::overaligned_tag<16>{});
                }
"""
assert oldA in src, 'A NOT FOUND'
newA = """                // SPILL FIX round 3 (ISA ledger 2): wf[64] (256B/thread of the 2304B) removed
                // -- the scaling loop RELOADS VAL (SLM reads are the proven cheap currency);
                // sum order j*8+e unchanged -> bit-identical.
                for(int r=0;r<8;++r){
                    uint qrow=q0+r;
                    float total=0.f;
                    for(int j=0;j<8;++j){ esimd::simd<float,8> s=esimd::slm_block_load<float,8>(VAL+r*256u+j*32u,esimd::overaligned_tag<16>{});
                        for(int e=0;e<8;++e){ total+=s[e]; } }
                    float trh=eh_round(total);
                    float recip=eh_round(1.0f/trh);   // softmax recip = 1/half(total) (no sqrt)
                    esimd::simd<half,64> w;
                    for(int j=0;j<8;++j){ esimd::simd<float,8> s=esimd::slm_block_load<float,8>(VAL+r*256u+j*32u,esimd::overaligned_tag<16>{});
                        for(int e=0;e<8;++e){ float v=eh_mul(s[e],recip); w[j*8u+e]=half(qr_e4m3_scalar(v)); } }
                    esimd::slm_block_store(SCR+qrow*128u,w,esimd::overaligned_tag<16>{});
                }
"""
src = src.replace(oldA, newA, 1)

# --- fix B: halve sc8 live set: j-loop split 0..3 / 4..7, epilogue per half ---
oldB = """                esimd::simd<float,64> sc8[8];
                for(int j=0;j<8;++j) sc8[j]=esimd::simd<float,64>(0.f);
"""
assert oldB in src
newB = """                // SPILL FIX round 3: sc8[8] (8 live simd<float,64> = 2048B/thread) halved --
                // two 4-key-column passes (j=0..3 then j=4..7); the weights() epilogue runs
                // per pass straight into VAL (same per-(r,j) stores, same dpas accumulation
                // order per j). Live fragments drop 8 -> 4.
                esimd::simd<float,64> sc8[4];
                for(int j=0;j<4;++j) sc8[j]=esimd::simd<float,64>(0.f);
"""
src = src.replace(oldB, newB, 1)

oldC = """                for(int kc=0;kc<2;++kc){
                    esimd::simd<half,128> a0=esimd::slm_block_load<half,128>(AFRG+kc*256u,esimd::overaligned_tag<16>{});
                    for(int j=0;j<8;++j){
                        // K fragment: keys j*8..j*8+7, channels kc*16..kc*16+15 (col-major B)
                        esimd::simd<half,128> b0;
                        for(int kr=0;kr<8;++kr){ esimd::simd<half,16> krow=esimd::slm_block_load<half,16>(K+(j*8u+kr)*64u+kc*32u,esimd::overaligned_tag<16>{});
                            b0.template select<16,1>(kr*16u)=krow; }
                        sc8[j]=esimd::xmx::dpas<8,8,float>(sc8[j],b0,a0);
                    }
                }
                // add bias + softmax weights() per query row; store the 64 weights as HALF
                // in VAL (8 rows x 64 x 2B = 1024B, exactly the VAL region).
                for(int j=0;j<8;++j){
                    for(int r=0;r<8;++r){
                        esimd::simd<float,8> s=sc8[j].template select<8,1>(r*8);
                        uint qrow=q0+r, kcol=j*8u;
                        for(int e=0;e<8;++e){ float lg=s[e]+Bias[qrow*64u+kcol+e];
                            float a=eh_add(eh_mul(eh_round(lg),0.044921875f),1.30078125f);
                            a=a<1.03125f?1.03125f:(a>1.5693359375f?1.5693359375f:a);
                            uint16_t bb=(uint16_t)(half)a;
                            uint32_t tr=((uint32_t)bb<<5)+0x7FF88000u;
                            s[e]=(float)(half)(uint16_t)(tr&0xFFFFu); }
                        esimd::slm_block_store(VAL+r*256u+j*32u,s,esimd::overaligned_tag<16>{});
                    }
                }
"""
assert oldC in src, 'C NOT FOUND'
newC = """                for(int jj=0;jj<2;++jj){
                  for(int j=0;j<4;++j) sc8[j]=esimd::simd<float,64>(0.f);
                  for(int kc=0;kc<2;++kc){
                    esimd::simd<half,128> a0=esimd::slm_block_load<half,128>(AFRG+kc*256u,esimd::overaligned_tag<16>{});
                    for(int j=0;j<4;++j){
                        int J=jj*4+j;
                        // K fragment: keys J*8..J*8+7, channels kc*16..kc*16+15 (col-major B)
                        esimd::simd<half,128> b0;
                        for(int kr=0;kr<8;++kr){ esimd::simd<half,16> krow=esimd::slm_block_load<half,16>(K+(J*8u+kr)*64u+kc*32u,esimd::overaligned_tag<16>{});
                            b0.template select<16,1>(kr*16u)=krow; }
                        sc8[j]=esimd::xmx::dpas<8,8,float>(sc8[j],b0,a0);
                    }
                  }
                  // add bias + softmax weights() per query row; store 32 weights per pass
                  // into VAL at [r*256 + J*32] (same addresses as the 8-pass form).
                  for(int j=0;j<4;++j){
                    int J=jj*4+j;
                    for(int r=0;r<8;++r){
                        esimd::simd<float,8> s=sc8[j].template select<8,1>(r*8);
                        uint qrow=q0+r, kcol=J*8u;
                        for(int e=0;e<8;++e){ float lg=s[e]+Bias[qrow*64u+kcol+e];
                            float a=eh_add(eh_mul(eh_round(lg),0.044921875f),1.30078125f);
                            a=a<1.03125f?1.03125f:(a>1.5693359375f?1.5693359375f:a);
                            uint16_t bb=(uint16_t)(half)a;
                            uint32_t tr=((uint32_t)bb<<5)+0x7FF88000u;
                            s[e]=(float)(half)(uint16_t)(tr&0xFFFFu); }
                        esimd::slm_block_store(VAL+r*256u+J*32u,s,esimd::overaligned_tag<16>{});
                    }
                  }
                }
"""
src = src.replace(oldC, newC, 1)
open('window_block_mega.hpp', 'w', encoding='utf-8').write(src)
print('mega round3: wf removed, sc8 halved')
