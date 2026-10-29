# generate ctree::cosine_reciprocal_32 — exact same op order as cosine_reciprocal(const float*),
# but 32 named float params + NO array inside (every h[i] becomes the param name).
def p(lane, par):
    ch = lane*2+par
    H = lambda i: f'h{i}'
    return (f'cr_hadd(cr_hfma({H(ch+8)},{H(ch+8)},cr_hmul({H(ch)},{H(ch)})),'
            f' cr_hfma({H(ch+24)},{H(ch+24)},cr_hmul({H(ch+16)},{H(ch+16)})))')

lines = []
lines.append('    // cosine_reciprocal_32 -- GENERATED (kdis/gen_cr32.py) from the exact tree of')
lines.append('    // cosine_reciprocal above: same operation ORDER, 32 named params, no array inside.')
lines.append('    // Lets the caller keep its row in SSA registers (kill hv[32] -> private/scratch spill).')
params = ', '.join(f'float h{i}' for i in range(32))
lines.append(f'    static inline float cosine_reciprocal_32({params}) {{')
lines.append(f'        float one00 = cr_hadd(cr_hadd({p(0,0)}, {p(2,0)}), cr_hadd({p(1,0)}, {p(3,0)}));')
lines.append(f'        float one01 = cr_hadd(cr_hadd({p(0,1)}, {p(2,1)}), cr_hadd({p(1,1)}, {p(3,1)}));')
lines.append('        float norm = sycl::max(cr_hadd(one00, one01), qr_half_round(COSINE_NORM_FLOOR));')
lines.append('        return qr_half_round(sycl::ext::intel::math::fdiv_rn(1.0f, sycl::sqrt(norm)));')
lines.append('    }')
out = '\n'.join(lines)
open('cr32_snippet.txt', 'w', encoding='utf-8').write(out)
print(out[:400], '...')
print('lines:', out.count(chr(10))+1)
