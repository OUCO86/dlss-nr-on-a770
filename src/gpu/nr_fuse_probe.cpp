// nr_fuse_probe.cpp -- the fused path, opened and run, without a game.
//
// Everything the slot does, on buffers of its own making: a D3D12 device on the
// Intel card, three shared buffers made the way the hand-over makes them, a shared
// D3D12 fence standing in for the game's, and then one frame -- the colour written
// on the D3D12 side, the fence signalled, the network waited on that value, the
// graph run, and the answer read back the same way it was written.
//
// It answers two questions the log could not:
//   * does the recording come up with the two fused passes in it;
//   * and does a known colour come back as something like a colour, rather than as
//     whatever the imported memory happened to hold.
//
// A frame is printed, not judged: the numbers are the answer.

#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <wrl/client.h>
#include <d3d12.h>
#include <dxgi1_4.h>
#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include <stdint.h>

using Microsoft::WRL::ComPtr;

typedef struct nr_net nr_net;
typedef void (*fuse_fn)(unsigned long long, unsigned long long, unsigned long long,
                        unsigned long long, unsigned long long, unsigned long long,
                        unsigned, unsigned, unsigned, float, float, float,
                        const void*, unsigned long long, const float*);
typedef nr_net* (*open_fn)(const char*, const char*, const char*);
typedef const char* (*error_fn)(nr_net*);
typedef int (*fused_fn)(nr_net*);
typedef int (*wait_fn)(nr_net*, unsigned long long, unsigned long long);
typedef int (*run_fn)(nr_net*);
typedef int (*idle_fn)(nr_net*);
typedef int (*exposure_fn)(nr_net*, float, int);
typedef int (*features_fn)(nr_net*, float*);
typedef int (*pre_alone_fn)(nr_net*);
typedef int (*probe_fn)(nr_net*, int which, float* out);

// libxmx itself: the same module nr_net.dll loaded, so a buffer it names can be read.
typedef int (*download_fn)(int, void*, unsigned long long, unsigned long long);

// The hand-over's own rule: never below 16 MB, and rounded up to 64 KB.
static UINT64 shared_width(UINT64 bytes)
{
    const UINT64 floor = UINT64(16) << 20;
    UINT64 w = (bytes + 65535) & ~UINT64(65535);
    return w < floor ? floor : w;
}

// A shared buffer cannot carry a format: CreateCommittedResource refuses R11G11B10 here,
// which is also why the placed footprint has to be the one carrying it.
static bool make_shared(ID3D12Device* d3d, UINT64 bytes,
                        ComPtr<ID3D12Resource>& out, HANDLE* handle)
{
    const UINT64 width = shared_width(bytes);
    D3D12_HEAP_PROPERTIES hp {};
    hp.Type = D3D12_HEAP_TYPE_DEFAULT;
    D3D12_RESOURCE_DESC rd {};
    rd.Dimension = D3D12_RESOURCE_DIMENSION_BUFFER;
    rd.Width = width;
    rd.Height = rd.DepthOrArraySize = rd.MipLevels = 1;
    rd.SampleDesc.Count = 1;
    rd.Layout = D3D12_TEXTURE_LAYOUT_ROW_MAJOR;

    if (FAILED(d3d->CreateCommittedResource(&hp, D3D12_HEAP_FLAG_SHARED, &rd,
                                            D3D12_RESOURCE_STATE_COMMON, nullptr,
                                            IID_PPV_ARGS(&out))) || !out)
    {
        printf("  could not create the shared buffer (%llu bytes)\n", (unsigned long long)width);
        return false;
    }
    HANDLE h = nullptr;
    if (FAILED(d3d->CreateSharedHandle(out.Get(), nullptr, GENERIC_ALL, nullptr, &h)) || !h)
    {
        printf("  the shared handle was refused\n");
        return false;
    }
    *handle = h;
    return true;
}

// The frame's own kind of resource: a texture the copy reads out of and writes back into.
// Everything else here was a buffer, and a buffer copy carries no footprint -- so the one
// step the game actually does (texture -> buffer -> texture, placed) was the one step this
// probe never did.
static bool make_texture(ID3D12Device* d3d, UINT w, UINT h, ComPtr<ID3D12Resource>& out)
{
    D3D12_HEAP_PROPERTIES hp {};
    hp.Type = D3D12_HEAP_TYPE_DEFAULT;
    D3D12_RESOURCE_DESC rd {};
    rd.Dimension = D3D12_RESOURCE_DIMENSION_TEXTURE2D;
    rd.Width = w;
    rd.Height = h;
    rd.DepthOrArraySize = rd.MipLevels = 1;
    rd.SampleDesc.Count = 1;
    rd.Format = DXGI_FORMAT_R11G11B10_FLOAT;
    rd.Layout = D3D12_TEXTURE_LAYOUT_UNKNOWN;
    return SUCCEEDED(d3d->CreateCommittedResource(&hp, D3D12_HEAP_FLAG_NONE, &rd,
                                                  D3D12_RESOURCE_STATE_COPY_DEST, nullptr,
                                                  IID_PPV_ARGS(&out))) && out;
}

// A buffer the CPU can fill or read, as the far end of a copy.
static bool make_host(ID3D12Device* d3d, UINT64 bytes, D3D12_HEAP_TYPE type,
                      D3D12_RESOURCE_STATES state, ComPtr<ID3D12Resource>& out)
{
    D3D12_HEAP_PROPERTIES hp {};
    hp.Type = type;
    D3D12_RESOURCE_DESC rd {};
    rd.Dimension = D3D12_RESOURCE_DIMENSION_BUFFER;
    rd.Width = bytes;
    rd.Height = rd.DepthOrArraySize = rd.MipLevels = 1;
    rd.SampleDesc.Count = 1;
    rd.Layout = D3D12_TEXTURE_LAYOUT_ROW_MAJOR;
    return SUCCEEDED(d3d->CreateCommittedResource(&hp, D3D12_HEAP_FLAG_NONE, &rd, state,
                                                  nullptr, IID_PPV_ARGS(&out))) &&
           out;
}

// One frame's worth of R11G11B10: 0.5 in every channel, which is a colour the
// network was trained on and a value easy to recognise on the way back.
// One frame's worth of R11G11B10, in the exponent that makes the value: (64 + m) *
// 2^(e - 21) for the 11-bit channels and (32 + m) * 2^(e - 20) for the 10-bit one, so
// e=14 is 0.5, e=13 is a quarter of it and e=15 twice it.
static uint32_t word_for(unsigned e)
{
    const uint32_t r = (e << 6u) | 0u;
    const uint32_t g = (e << 6u) | 0u;
    const uint32_t b = (e << 5u) | 0u;
    return r | (g << 11u) | (b << 22u);
}

static uint32_t half_word(void) { return word_for(14u); }

static float clampf(float v, float lo, float hi) { return v < lo ? lo : (v > hi ? hi : v); }

// The same three channels, from a float: frexp gives f in [0.5, 1) and the stored form
// wants (64 + m) with m in [0, 64), so the mantissa is 128f - 64 and the exponent e + 14.
static uint32_t encode11f(float v)
{
    if (!(v > 0.0f)) return 0u;
    int e = 0;
    const float f = frexpf(v, &e);
    const uint32_t m = (uint32_t)clampf(128.0f * f - 64.0f + 0.5f, 0.0f, 63.0f);
    const int biased = e + 14;
    if (biased >= 31) return 31u << 6u;
    if (biased <= 0) return 0u;
    const uint32_t r = (uint32_t(biased) << 6u) | m;
    const uint32_t g = r, b = (uint32_t(biased) << 5u) | (m >> 1);
    return r | (g << 11u) | (b << 22u);
}

static double inMean = 0.0;

// The noise, as the host builds it (NrPipeline.cpp): a hash of the pixel's place, so
// the same extent always gives the same three channels. Gaussian, rounded to a half.
// It cannot be left at zero -- the network is given these three channels and was
// trained on them being noise, which is why a frame of zeroes is not a fair test.
static uint32_t shift_mix(uint32_t v)
{
    const uint32_t s = (v >> 28) + 4u;
    return (v ^ (v >> s)) * 0x108EF2D9u;
}

static float uniform24(uint32_t v)
{
    const uint32_t m = shift_mix(v);
    return float(((m >> 30) ^ (m >> 8)) + 1u) * 5.960464477539063e-8f;
}

static float as_half(float x)
{
    uint32_t u;
    memcpy(&u, &x, sizeof u);
    u &= 0xffffe000u;
    memcpy(&x, &u, sizeof u);
    return x;
}

static void noise_channel(uint32_t seed, float* out)
{
    const uint32_t mixed = shift_mix(seed) ^ (shift_mix(seed) >> 22);
    const float ra = sqrtf(-2.0f * logf(uniform24(mixed * 0xCAA5B80Du + 0x21DD796Bu)));
    const float rb = sqrtf(-2.0f * logf(uniform24(mixed * 0x2C9277B5u + 0xAC564B05u)));
    const float aa = 6.28318548f * uniform24(mixed * 0xFA6DC5F9u + 0x4712A88Eu);
    const float ab = 6.28318548f * uniform24(mixed * 0x83232C31u + 0x3463E0ACu);
    out[0] = as_half(rb * cosf(aa));
    out[1] = as_half(rb * sinf(aa));
    out[2] = as_half(ra * cosf(ab));
}

static float decode11(uint32_t v)
{
    uint32_t e = (v >> 6u) & 0x1Fu, m = v & 0x3Fu;
    return e == 0u ? 0.0f : (float)(64u + m) * powf(2.0f, (float)e - 21.0f);
}

int main(void)
{
    const char* folder = "E:\\WorkBuddy\\2026-10-09-04-20-55\\src\\dlss-nr-on-a770\\work";
    const UINT w = 960, h = 540;
    const UINT pitch = (w * 4 + 255) & ~UINT(255);
    const UINT64 colourBytes = (UINT64)pitch * h;

    ComPtr<IDXGIFactory4> factory;
    if (FAILED(CreateDXGIFactory1(IID_PPV_ARGS(&factory)))) { printf("no DXGI factory\n"); return 1; }

    ComPtr<IDXGIAdapter1> adapter;
    for (UINT i = 0; factory->EnumAdapters1(i, &adapter) != DXGI_ERROR_NOT_FOUND; ++i)
    {
        DXGI_ADAPTER_DESC1 d {};
        adapter->GetDesc1(&d);
        if (d.VendorId == 0x8086) break;
        adapter.Reset();
    }
    if (!adapter) { printf("no Intel adapter\n"); return 1; }

    ComPtr<ID3D12Device> d3d;
    if (FAILED(D3D12CreateDevice(adapter.Get(), D3D_FEATURE_LEVEL_11_0, IID_PPV_ARGS(&d3d))))
    { printf("no D3D12 device\n"); return 1; }

    ComPtr<ID3D12CommandQueue> queue;
    D3D12_COMMAND_QUEUE_DESC qd {};
    qd.Type = D3D12_COMMAND_LIST_TYPE_DIRECT;
    if (FAILED(d3d->CreateCommandQueue(&qd, IID_PPV_ARGS(&queue)))) { printf("no queue\n"); return 1; }

    ComPtr<ID3D12CommandAllocator> alloc;
    d3d->CreateCommandAllocator(D3D12_COMMAND_LIST_TYPE_DIRECT, IID_PPV_ARGS(&alloc));
    ComPtr<ID3D12GraphicsCommandList> list;
    d3d->CreateCommandList(0, D3D12_COMMAND_LIST_TYPE_DIRECT, alloc.Get(), nullptr, IID_PPV_ARGS(&list));

    ComPtr<ID3D12Fence> done;
    d3d->CreateFence(0, D3D12_FENCE_FLAG_NONE, IID_PPV_ARGS(&done));

    // The game's fence, shared: what the network waits on instead of being waited for.
    ComPtr<ID3D12Fence> toVk;
    HANDLE toVkShared = nullptr;
    if (FAILED(d3d->CreateFence(0, D3D12_FENCE_FLAG_SHARED, IID_PPV_ARGS(&toVk))) ||
        FAILED(d3d->CreateSharedHandle(toVk.Get(), nullptr, GENERIC_ALL, nullptr, &toVkShared)) ||
        !toVkShared)
    { printf("could not share the fence\n"); return 1; }

    printf("making the shared buffers\n");
    ComPtr<ID3D12Resource> colourRes, motionRes, resultRes;
    HANDLE colour = nullptr, motion = nullptr, result = nullptr;
    if (!make_shared(d3d.Get(), colourBytes, colourRes, &colour) ||
        !make_shared(d3d.Get(), colourBytes, motionRes, &motion) ||
        !make_shared(d3d.Get(), colourBytes, resultRes, &result))
        return 1;
    printf("  colour %p motion %p result %p (each %llu bytes)\n", colour, motion, result,
           (unsigned long long)shared_width(colourBytes));

    // The plan: noise, the five controls, the mirror onto the network's extent. The
    // mirror is the identity clamped, which is what a frame with no padding wants.
    const unsigned nh = 544, nw = 960;
    const size_t floats = (size_t)nh * nw * 3 + 5 + nh + nw;
    float* plan = (float*)calloc(floats, sizeof(float));
    float* table = (float*)calloc(65536 + 4, sizeof(float));
    if (!plan || !table) { printf("out of memory\n"); return 1; }

    // The noise, first in the plan, as nr_pre.comp reads it.
    for (unsigned y = 0; y < nh; ++y)
    {
        const uint32_t row = uint32_t(y) * 0xD8163841u;
        for (unsigned x = 0; x < nw; ++x)
        {
            const uint32_t seed = row ^ (uint32_t(x) * 0x8DA6B343u) ^ 0x243F6A88u;
            noise_channel(seed, plan + ((size_t)y * nw + x) * 3);
        }
    }

    float* at = plan + (size_t)nh * nw * 3;
    const float controls[5] = { 0.0f, 1.0f, 1.0f, -1.0f, -1.0f };
    memcpy(at, controls, sizeof controls);
    at += 5;
    for (unsigned y = 0; y < nh; ++y)
    {
        int32_t row = (int32_t)(y < h ? y : h - 1);
        memcpy(at + y, &row, sizeof row);
    }
    at += nh;
    for (unsigned x = 0; x < nw; ++x)
    {
        int32_t col = (int32_t)(x < w ? x : w - 1);
        memcpy(at + x, &col, sizeof col);
    }
    // A gate of zero and no blend: the composition then answers with the colour it
    // read, unchanged, so what comes back is a measurement of the read rather than
    // of the network. Set them back to see the network's own answer.
    for (uint32_t i = 0; i < 65536u; ++i) table[i] = 0.0f;
    table[65536u] = 0.0f;   // intensity: no blend towards the prediction
    table[65537u] = 1.0f;   // confidence
    table[65538u] = 1.0f;   // exposure: 1, so nothing is divided out or back

    printf("loading nr_net.dll\n");
    HMODULE net = LoadLibraryA("E:\\WorkBuddy\\2026-10-09-04-20-55\\src\\dlss-nr-on-a770\\work\\nr_net.dll");
    if (!net) { printf("nr_net.dll would not load\n"); return 1; }
    fuse_fn fuse = (fuse_fn)GetProcAddress(net, "nr_net_fuse");
    open_fn open = (open_fn)GetProcAddress(net, "nr_net_open");
    error_fn error = (error_fn)GetProcAddress(net, "nr_net_error");
    fused_fn fused = (fused_fn)GetProcAddress(net, "nr_net_fused");
    wait_fn wait = (wait_fn)GetProcAddress(net, "nr_net_wait");
    run_fn run = (run_fn)GetProcAddress(net, "nr_net_run");
    idle_fn idle = (idle_fn)GetProcAddress(net, "nr_net_idle");
    exposure_fn exposure = (exposure_fn)GetProcAddress(net, "nr_net_exposure");
    features_fn probeFeatures = (features_fn)GetProcAddress(net, "nr_net_probe_features");
    probe_fn probe = (probe_fn)GetProcAddress(net, "nr_net_probe");
    pre_alone_fn preAlone = (pre_alone_fn)GetProcAddress(net, "nr_net_pre_alone");
    download_fn download = nullptr;
    HMODULE xmx = LoadLibraryA("libxmx.dll");   // already loaded by nr_net: the same module
    if (xmx) download = (download_fn)GetProcAddress(xmx, "xmx_buf_download");
    if (!fuse || !open || !error || !wait || !run) { printf("nr_net.dll does not have the calls\n"); return 1; }

    const UINT64 width = shared_width(colourBytes);
    // width, height, then the row in 32-bit words -- the order the signature has them.
    // The three floats are exposure, intensity and confidence. Intensity is the blend:
    // at zero the composition answers with the colour it read, unchanged, so what comes
    // back measures the read. It is the parameter, not the table's 65536th entry, that
    // decides it -- the fused open writes the parameter over that entry.
    fuse((unsigned long long)colour, (unsigned long long)motion, (unsigned long long)result,
         width, width, width, w, h, pitch / 4u, 1.0f, 1.0f, 1.0f,
         plan, (unsigned long long)floats * sizeof(float), table);

    printf("opening\n");
    nr_net* n = open("libxmx.dll", folder, nullptr);
    const char* why = error(n);
    if (why && *why) { printf("THE NETWORK DID NOT COME UP: %s\n", why); return 1; }
    printf("the network is up; nr_net_fused says %d\n\n", fused ? fused(n) : -1);

    // The colour, written on the D3D12 side the way the game writes it.
    ComPtr<ID3D12Resource> colourTex, resultTex;
    if (!make_texture(d3d.Get(), w, h, colourTex) || !make_texture(d3d.Get(), w, h, resultTex))
    { printf("no textures\n"); return 1; }
    D3D12_PLACED_SUBRESOURCE_FOOTPRINT fpIn {};
    fpIn.Footprint.RowPitch = pitch;
    fpIn.Footprint.Width = w;
    fpIn.Footprint.Height = h;

    ComPtr<ID3D12Resource> upload;
    if (!make_host(d3d.Get(), colourBytes, D3D12_HEAP_TYPE_UPLOAD,
                   D3D12_RESOURCE_STATE_GENERIC_READ, upload))
    { printf("no upload buffer\n"); return 1; }
    uint32_t* words = nullptr;
    if (FAILED(upload->Map(0, nullptr, (void**)&words))) { printf("could not map the upload\n"); return 1; }
    for (UINT i = 0; i < (UINT)(colourBytes / 4u); ++i) words[i] = half_word();
    upload->Unmap(0, nullptr);

    // The vectors, zero: no motion, so the reprojection cannot be what moves a pixel.
    ComPtr<ID3D12Resource> motionUp;
    if (!make_host(d3d.Get(), colourBytes, D3D12_HEAP_TYPE_UPLOAD,
                   D3D12_RESOURCE_STATE_GENERIC_READ, motionUp))
    { printf("no upload buffer for the vectors\n"); return 1; }
    uint16_t* zero = nullptr;

    ComPtr<ID3D12Resource> readback;
    if (!make_host(d3d.Get(), colourBytes, D3D12_HEAP_TYPE_READBACK,
                   D3D12_RESOURCE_STATE_COPY_DEST, readback))
    { printf("no readback buffer\n"); return 1; }

    auto submit_and_wait = [&](ID3D12GraphicsCommandList* l) {
        l->Close();
        ID3D12CommandList* lists[] = { l };
        queue->ExecuteCommandLists(1, lists);
        const UINT64 v = done->GetCompletedValue() + 1;
        queue->Signal(done.Get(), v);
        HANDLE ev = CreateEventA(nullptr, FALSE, FALSE, nullptr);
        done->SetEventOnCompletion(v, ev);
        WaitForSingleObject(ev, INFINITE);
        CloseHandle(ev);
        alloc->Reset();
        l->Reset(alloc.Get(), nullptr);
    };

    for (int frame = 1; frame <= 6; ++frame)
    {
        const UINT64 value = (UINT64)frame;

        // Not a flat field: a ramp across the row, so a pixel that landed in the wrong
        // place answers with the wrong value. The motion vectors are zero, which makes
        // the reprojection an identity and leaves the network the only thing that can
        // move a pixel.
        // A frame that looks like a frame, rather than a ramp: mid grey, per-pixel
        // texture and one large shape. What is measured is the mean of the whole frame
        // against the mean that went in, because a single pixel of a synthetic pattern
        // says nothing about whether the picture came back.
        const unsigned row = pitch / 4u;
        if (FAILED(upload->Map(0, nullptr, (void**)&words))) { printf("could not map\n"); return 1; }
        inMean = 0.0;
        for (UINT y = 0; y < h; ++y)
        {
            for (UINT x = 0; x < w; ++x)
            {
                // Half the frame past the top of the range, the way a game's does: this
                // game's pixels have been measured past 1500. The count of answer pixels
                // that come back at exactly one is what tells a shoulder from a clamp.
                // The picture pans: everything in it moves (frame - 1) pixels a frame,
                // which is the condition a history is for. A still frame cannot tell a
                // reprojection that works from one that does not.
                const int sx = (int(x) - (frame - 1) * 3) % (int)w;
                const float shape = (sx > (int)w / 2) ? 9.0f : 0.0f;
                const float grain = (float)(((unsigned)sx * 1103515245u + y * 12345u) % 1000u) / 1000.0f - 0.5f;
                float v = 0.12f + shape + grain * 0.10f;
                if (v < 0.02f) v = 0.02f;
                if (v > 1.0f) v = 1.0f;
                words[(size_t)y * row + x] = encode11f(v);
                inMean += v;
            }
        }
        inMean /= double(w) * double(h);
        upload->Unmap(0, nullptr);

        // R16G16, three pixels of movement a frame, in pixels, which is the unit a
        // render target's vectors come in.
        if (FAILED(motionUp->Map(0, nullptr, (void**)&zero))) { printf("could not map\n"); return 1; }
        for (UINT i = 0; i < (UINT)(colourBytes / 4u); ++i)
        {
            zero[i * 2u + 0u] = 0x5D00;   // 30.0 in a half: a fast camera's worth
            zero[i * 2u + 1u] = 0x0000;
        }
        motionUp->Unmap(0, nullptr);
        list->CopyBufferRegion(motionRes.Get(), 0, motionUp.Get(), 0, colourBytes / 2u);

        list->CopyBufferRegion(colourRes.Get(), 0, upload.Get(), 0, colourBytes);
        submit_and_wait(list.Get());
        queue->Signal(toVk.Get(), value);

        // The frame's exposure, which the game moves between frames: a quarter of it
        // here, all of it there. It has to be this frame's, not the one the open saw.
        // The exposure is held still so that only `fresh` differs between the frames:
        // if the flag reaches the shader, the first frame and the rest cannot agree.
        const float exp = 1.0f;
        // A second run keeps the history it made; only the first frame has none.
        const int fresh = frame == 1 ? 1 : 0;
        if (exposure && exposure(n, exp, fresh) != 0)
        { printf("frame %d: the exposure would not go in\n", frame); return 1; }

        if (wait(n, (unsigned long long)toVkShared, value) != 0)
        { printf("frame %d: the wait did not go: %s\n", frame, error(n) ? error(n) : ""); return 1; }
        if (run(n) != 0)
        { printf("frame %d: the graph did not run: %s\n", frame, error(n) ? error(n) : ""); return 1; }
        // The answer is only in the buffer once the queue has finished with it. A frame
        // is ordered by the hand-over's semaphore instead; a probe has no game queue to
        // wait on the other side of, so it waits here.
        if (!idle || idle(n) != 0)
        { printf("frame %d: the queue would not settle\n", frame); return 1; }

        list->CopyBufferRegion(readback.Get(), 0, resultRes.Get(), 0, colourBytes);
        submit_and_wait(list.Get());

        uint32_t* back = nullptr;
        if (FAILED(readback->Map(0, nullptr, (void**)&back))) { printf("could not map the readback\n"); return 1; }
        const uint32_t at_pixel = (UINT)(h / 2) * (pitch / 4u) + w / 2;
        const uint32_t word = back[at_pixel];
        readback->Unmap(0, nullptr);

        const unsigned e = 12u + (w / 2u) * 3u / w;
        const float wanted = powf(2.0f, (float)e - 15.0f);
        double outMean = 0.0, atTop = 0.0;
        for (UINT y = 0; y < h; ++y)
            for (UINT x = 0; x < w; ++x)
            {
                const float v = decode11(back[(size_t)y * row + x] & 0x7FFu);
                outMean += v;
                if (v >= 0.99f) atTop += 1.0;
            }
        outMean /= double(w) * double(h);
        atTop *= 100.0 / (double(w) * double(h));

        double step = 0.0;
        for (UINT y = 0; y < h; ++y)
            for (UINT x = 1; x < w; ++x)
            {
                const float a = decode11(back[(size_t)y * row + x] & 0x7FFu);
                const float b = decode11(back[(size_t)y * row + x - 1] & 0x7FFu);
                step += fabs(a - b);
            }
        step /= double(h) * double(w - 1);

        if (probeFeatures)
        {
            float channels[48] = {};
            probeFeatures(n, channels);
            printf("--- features, frame %d ---\n", frame);
            for (int c = 0; c < 16; ++c)
                printf("  ch %2d: mean %9.4f low %9.4f high %9.4f\n", c,
                       channels[c * 3], channels[c * 3 + 1], channels[c * 3 + 2]);
        }

        printf("frame %d: mean in %.4f -> mean out %.4f | at the top %.1f%% | neighbour step %.4f\n",
               frame, inMean, outMean, atTop, step);
    }

    printf("\nfirst words of the answer, as they came back:\n");
    uint32_t* back = nullptr;
    readback->Map(0, nullptr, (void**)&back);
    for (int i = 0; i < 6; ++i) printf("  [%d] 0x%08X\n", i, back[i]);
    readback->Unmap(0, nullptr);
    return 0;
}
