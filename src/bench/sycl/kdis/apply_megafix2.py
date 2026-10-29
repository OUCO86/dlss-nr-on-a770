src = open('window_block_mega.hpp', 'r', encoding='utf-8').read()

old = """                    float h[32]; for(int i=0;i<32;++i) h[i]=rv[i];
                    esimd::simd<half,32> out;
                    if(part<2){
                        for(int i=0;i<32;++i) h[i]=eh_round(h[i]);
                        float recip=cosine_recip_esimd(h);
                        float sc=part==0?eh_round(QkvScale[0]):1.0f;
                        for(int i=0;i<32;++i){ float v=eh_mul(h[i],recip); if(part==0) v=eh_mul(v,sc); out[i]=half(qr_e4m3_scalar(v)); }
                    } else {
                        for(int i=0;i<32;++i) out[i]=half(qr_e4m3_scalar(h[i]));
                    }
"""
assert old in src, 'launch_full stage3 block NOT FOUND'
assert src.count(old) == 1, 'not unique'

R = lambda i: f'rv{i}'
decl = '                    float ' + ', '.join(f'{R(i)} = rv[{i}]' for i in range(32)) + ';\n'
rounds = ''.join(f'                        {R(i)} = eh_round({R(i)});\n' for i in range(32))
callargs = ', '.join(R(i) for i in range(32))
recip = f'                        float recip=cosine_recip_esimd_32({callargs});\n'
puts = ''.join(
    f'                        float v{i} = eh_mul({R(i)}, recip);\n'
    f'                        if (part==0) v{i} = eh_mul(v{i}, sc);\n'
    f'                        out[{i}] = half(qr_e4m3_scalar(v{i}));\n' for i in range(32))
vputs = ''.join(f'                        out[{i}] = half(qr_e4m3_scalar({R(i)}));\n' for i in range(32))

new = ("""                    // SPILL FIX round 2 (ISA ledger 2): launch_full stage-3 h[32] ->
                    // named scalars + cosine_recip_esimd_32 (same op order, no array escape).
""" + decl +
"""                    esimd::simd<half,32> out;
                    if(part<2){
""" + rounds + recip +
"""                        float sc=part==0?eh_round(QkvScale[0]):1.0f;
""" + puts +
"""                    } else {
""" + vputs + """                    }
""")
src = src.replace(old, new, 1)
open('window_block_mega.hpp', 'w', encoding='utf-8').write(src)
print('launch_full stage3: h[32] -> named scalars')
