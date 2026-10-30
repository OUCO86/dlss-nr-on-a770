p='libxmx_sycl.cpp'
s=open(p,encoding='utf-8').read()
# fix the broken printf from the previous -c attempt (literal newline inside the string)
import re
bad = s[s.index('[wq-verify] src=%d'):s.index('[wq-verify] src=%d')+80]
# locate the corrupted printf and rewrite the whole verify block cleanly
start = s.index('                    if (getenv("NR_WQVERIFY")) {')
end = s.index('sycl::free(refs,*GQ);', start) + len('sycl::free(refs,*GQ);\n                    }')
block = s[start:end]
newblock = '''                    if (getenv("NR_WQVERIFY")) {   // run the REAL quant into a temp, diff vs cache content
                        int8_t* ref = (int8_t*)sycl::malloc_device((size_t)M * K, *GQ);
                        float* refs = (float*)sycl::malloc_device((size_t)M * 4u, *GQ);
                        qr_launch_esimd(*GQ, *GD, a, (sycl::uint2*)ref, refs, M, K);
                        GQ->wait();
                        std::vector<int8_t> ha((size_t)M*K), hb((size_t)M*K);
                        GQ->memcpy(ha.data(), ref, (size_t)M*K); GQ->memcpy(hb.data(), wc->second.first, (size_t)M*K); GQ->wait();
                        size_t bad=0; for(size_t i=0;i<ha.size();++i) if(ha[i]!=hb[i]) ++bad;
                        printf("[wq-verify] src=%d pk=%d M=%u K=%u CACHE-DIFF %zu/%zu %s\\n", source, packed, M, K, bad, ha.size(), bad?"STALE":"ok");
                        sycl::free(ref,*GQ); sycl::free(refs,*GQ);
                    }'''
s = s.replace(block, newblock)
open(p,'w',encoding='utf-8').write(s)
print('verify block repaired')
