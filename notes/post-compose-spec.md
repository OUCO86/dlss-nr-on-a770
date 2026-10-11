# 后段（合成 + 编码）搬到设备上：逐像素规格

`nr_compose_encode`（`src/ref/nr_image.c:808`）是本仓最后一块全分辨率宿主活。
这份规格把它拆到可以照抄成 GLSL 的粒度，**每一条都是 bit-identical 的凭据**，
不是大意。改任何一条之前先跑 `src/ref/test_native_image.py`。

## 0. 它站在整帧的什么位置

    head (768x448, 3 或 4 通道 fp32, 设备里)
    colour  全分辨率 RGB fp32 —— 由 `decode8` 从游戏字节解出，**只在宿主有**
    history 上一帧的合成结果（全分辨率 RGB fp32）
    previous 上一帧的游戏像素（全分辨率 RGB fp32）
    ─────────────────────────────────────────
    → 每个输出像素：合成后的 RGB，再编码成 BGRA 字节写回 answer

四个输入里 **colour / history / previous 都只在宿主有**，这是它现在留在 CPU 的全部理由。
设备化之后 colour 由 PRE_INNER 已经上传的那份 raw 字节直接解码（同一张 256 项表），
history 与 previous 则是**上一帧这一趟自己的输出**，本来就在显存。

## 1. 逐像素的链

按执行顺序，一行一行（y 是输出行，x 是输出列）：

### 1.1 head 的两轴插值（先 y 后 x，中间 fp32 落地）

与 PRE_INNER 同一套 `_axis_plan`：

    row[i*C + c] = a[low_y[y]*hy + i*hx + c*hc] * (1 - w) + b[high_y[y]*hy + ...] * w
    line[x*C + c] = ... 同理沿 x

⚠️ 顺序不能换，中间结果必须是 fp32，理由与 PRE_INNER 相同（float 不结合）。

### 1.2 本帧预测

    predicted[c] = unit(rgb[c] + half(h[c]) * 0.25f)

- `half()` = **向最近偶数舍入**到 fp16（IEEE round-to-nearest-even），GLSL 的
  `float16_t(x)` 就是它；
- `unit()` = clamp 到 [0,1]：`< 0 → 0`，`> 1 → 1`，其余原值。

### 1.3 时域门控的 alpha（有 history 时）

先算 `moved` = 三个通道上 `|rgb[c] - before[c]|` 的**最大值**；无 `previous` 时为 0。

    alpha = table[bits(half(h[3]))]        // 65536 项，宿主 gate_table 逐项算好
    if confidence != 1:  alpha *= confidence

    // release：游戏自己动过的地方，旧历史已经不对了
    if previous and release != 0:
        kept = clamp(moved * release + 1, 0, 1)
        alpha *= kept

    // floor：完全没动的地方，历史按构造就是对的
    if previous:
        floored = clamp(clamp(moved * slope + hold, 0, hold), 0, 1)
        floored *= scale
        alpha = max(alpha, floored)

`slope` / `hold` 已经由宿主折好（NumPy 乘一个常数加一个常数），
`clip(1 - moved*255/ramp, 0, 1) * hold` 代数上同值但 float32 上不同 —— 用折好的那个。

### 1.4 混合

    predicted[c] += alpha * (was[c] - predicted[c])      // was = history

⚠️ `blend = intensity`（有 mask 时 `intensity * mask`），**不 clamp** ——
厂家那道 clamp 是我们故意去掉的，好让 intensity > 1 能外插。

### 1.5 finish_pixel

    if grade or neural:
        kept[c] = truncate_half(predicted[c])
        if neural: neural[c] = kept[c]
        if grade:  style_grade(kept, grade); predicted[c] = kept[c]
    out[c] = unit(rgb[c] + blend * (predicted[c] - rgb[c]))

### 1.6 编码

    value = isnan(v) ? 0 : unit(v)
    byte  = uint8(value * 255.0f + 0.5f)
    alpha = raw[p*4 + 3]      // 原样带过来

## 2. 两个必须照抄的怪函数

### `truncate_half`（`nr_image.c:141`）—— **位操作，不是舍入**

向零截到 half 网格（厂家 RGBA16F 历史对预测保留的精度）：

    f = floatBitsToUint(x)
    kept = uintBitsToFloat(f & 0xffffe000u)                  // 正常数：砍掉低 13 位
    small = floor(|x| * 16777216.0) * 2^-24                  // 次正规：2^-24 的倍数
    small = x < 0 ? -small : small
    return (f & 0x7fffffffu) >= 0x38800000u ? kept : small

用 `floatBitsToUint` / `uintBitsToFloat` 直接翻，别用 `float16_t` 转换 ——
那是向最近偶数舍入，**不是**向零截断。

### `style_grade`（`nr_image.c:175`）—— 曝光 / 对比 / HSL 饱和度

    for i in 0..2:
        v = grade_unit(grade_unit(c[i]) * exposure)
        c[i] = grade_unit(v + contrast * (v*v*(3 - (v+v)) - v))
    high = max(r,g,b); low = min(r,g,b)
    light = (high+low) * 0.5; delta = high - low
    grey  = !(high > low)                       // 浮点相等
    spread  = grey ? 1 : delta
    by_bright = delta / (grey ? 1 : (2 - high) - low)
    by_dark   = delta / (grey ? 1 : high + low)
    chroma = light > 0.5 ? by_bright : by_dark
    hue    = grey ? 0 : (high == r ? from_r : high == g ? from_g : from_b)
    chroma = grade_unit((grey ? 0 : chroma) * saturation)
    q = light < 0.5 ? light*(chroma+1) : (light+chroma) - light*chroma
    p = light + light - q
    flat = chroma <= 0
    c[0] = flat ? grade_unit(light) : grade_unit(hue_channel(p, q, hue + 1/3))
    c[1] = flat ? grade_unit(light) : grade_unit(hue_channel(p, q, hue))
    c[2] = flat ? grade_unit(light) : grade_unit(hue_channel(p, q, hue - 1/3))

`hue_channel(p, q, t)`：t 先折回 [0,1)（`<0` 加 1，`>1` 减 1），

    rising  = p + t * ((q - p) * 6)
    falling = p + (2/3 - t) * (q - p) * 6
    t < 1/6 ? rising : t < 0.5 ? q : t < 2/3 ? falling : p

⚠️ 每一步都是**选择不是分支**：NumPy 的 `where` 两边都算（不用那一边拿替身除数），
所以 GLSL 里也必须用 `mix`/三元，不能 `if` 提前 return，否则 NaN 路径不同。

## 3. bit-identical 的三个陷阱（前两个前段已经栽过）

1. **`x / 255.0` 会被这颗驱动编译成乘倒数**，与 C 的 IEEE 除法最后一位不同。
   解码走 256 项查表（PRE_INNER 已如此，后段复用同一张表）。
2. **`a * b + c` 可能被收缩成 FMA**，与 C 的两步不同 —— §1.6 的
   `value * 255.0f + 0.5f` 正好是这形状。先量；
   真差了就把 255.0f 那一步单独取出来，或用整数运算绕开。
3. **`half()` 有两处且语义不同**：§1.2 是**向最近偶数**（`float16_t`），
   §1.5 是**向零截断**（`truncate_half` 的位操作）。别混。

## 4. 输出与副作用

- `encoded`：写进 `answer` 的 `(top + y) * frame_width + left` 处，
  **alpha 与活动区外的行/列保持 `payload` 原样** —— 所以输入就是 payload 的副本。
- `neural`：预测截断到 half 的版本，下一帧的 history。
- `change`：每 `change_rows` 行上 `|composed - colour|` 的均值（daemon 日志那个数）。
- `samples`：每 `step` 行列的插值后 head，daemon 的 gate 图读它。

## 5. 设备化后的数据流

    raw (显存, PRE_INNER 已上传) ──decode(表)──┐
    head (显存, 网络输出)          ──两轴插值──┤
    history / previous (显存, 上一帧本趟输出) ─┤
                                              ├─→ composed (显存, 留给下一帧)
                                              └─→ encoded 字节 ──→ 回宿主一次（8.3 MB，跨进程必需）

**只有 `encoded` 回宿主。** `composed` 留在显存当下一帧的 history，
顺带把现在那 2.08 ms 的 history 下采样也变成设备活。

⚠️ 反过来的顺序（先上 compose，history 仍走 CPU）是**净亏**：
history 全分辨率 fp32 是 25 MB，上传一次约 5 ms，比省下的 5.8 ms 还贵。
所以 §1 与 history 常驻必须一起做。
