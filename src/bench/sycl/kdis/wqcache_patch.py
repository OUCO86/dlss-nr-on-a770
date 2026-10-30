p='libxmx_sycl.cpp'
s=open(p,encoding='utf-8').read()
old="""        g_cmds.push_back([=]() {
            if (wq_static && g_graphrecording) {
                if (getenv("NR_Q_STATS")) printf("[quant-WQSKIP] M=%u K=%u src=%d pk=%d cmd=%zu\\n", M, K, source, packed, mycmd);
                return;
            }
            // B2 EXECUTION-TIME census: this lambda only runs if the launch was
            // NOT dissolved by a downstream gemm's qfuse_take. NR_Q_STATS=1.
            if (getenv("NR_Q_STATS")) printf("[quant-EXEC] M=%u K=%u src=%d pk=%d cmd=%zu gen(s=%d p=%d sc=%d)\\n", M, K, source, packed, mycmd, genof(source), genof(packed), genof(scale));
            qr_launch_esimd(*GQ, *GD, a, pk, sc, M, K);
        });"""
new="""        g_cmds.push_back([=]() {
            // WQ-CACHE (the user's 17:2x scheme, built on the census facts): the
            // 160 weight quants re-quantize frame-invariant src planes. MISS (first
            // plain execution of a (src,M,K) key): run the quant for real, then
            // snapshot pk+sc into a persistent device cache. HIT (every later
            // frame AND every capture pass): memcpy cache -> pk/sc. Correct BY
            // CONSTRUCTION (the cache content = a real executed quant's output);
            // the recorded graph carries the memcpy nodes, so pk is refilled
            // every replay regardless of pointer stability.
            if (getenv("NR_Q_STATS")) printf("[quant-EXEC] M=%u K=%u src=%d pk=%d cmd=%zu gen(s=%d p=%d sc=%d)\\n", M, K, source, packed, mycmd, genof(source), genof(packed), genof(scale));
            if (wq_static) {
                static std::unordered_map<uint64_t, std::pair<int8_t*, float*>> wqc;
                uint64_t kk = (uint64_t)(uintptr_t)a * 1000003ull + (uint64_t)M * 65536ull + K;
                auto wc = wqc.find(kk);
                if (wc != wqc.end()) {
                    GQ->memcpy(pk, wc->second.first, (size_t)M * K);
                    GQ->memcpy(sc, wc->second.second, (size_t)M * 4u);
                    return;
                }
                qr_launch_esimd(*GQ, *GD, a, pk, sc, M, K);
                if (!g_graphrecording) {   // snapshot only from REAL executions
                    int8_t* cbuf = (int8_t*)sycl::malloc_device((size_t)M * K, *GQ);
                    float* csbuf = (float*)sycl::malloc_device((size_t)M * 4u, *GQ);
                    GQ->memcpy(cbuf, pk, (size_t)M * K);
                    GQ->memcpy(csbuf, sc, (size_t)M * 4u);
                    GQ->wait();
                    wqc[kk] = { cbuf, csbuf };
                }
                return;
            }
            qr_launch_esimd(*GQ, *GD, a, pk, sc, M, K);
        });"""
assert old in s, "pattern miss"
s=s.replace(old,new)
s=s.replace("const bool wq_static = wqf && genof(source) < genof(packed) && genof(source) >= 0 && genof(packed) >= 0 && genof(scale) == genof(packed);   // the src plane was created in an EARLIER recording (init/weights uploaded once); pk+sc belong to THIS recording -- the census: pk has ZERO recorder readers in the frame graph",
"const bool wq_static = wqf && genof(source) >= 0 && genof(packed) >= 0 && genof(source) <= genof(packed);   // census: NO recorder op ever WRITES these 8 src planes (1271/1280/1282/1292/1295/1298/1303/1307 = engine-init content, frame-invariant)")
open(p,'w',encoding='utf-8').write(s)
print('WQ-CACHE wired')
