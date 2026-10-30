import io
m=r'C:\Users\wangz\.workbuddy\user-678f1520-e873-4a3e-83a0-45beeace675e-personal\MEMORY.md'
s=open(m,encoding='utf-8').read()
add = """

## 收益优先军规（2026-10-30 18:1x 用户明确，最高优先级之一）

**凡是参照 lmxxf 布局/方案做的改动，如果测出无收益甚至负收益——证明的不是方案错，
是我实现得有问题。不许第一动作回退完事。第一动作 = 找解决方案把收益弄到手。**

- 没有跨不过的门槛：除了硬件物理限制，其他都是实现问题；硬件限制也多半是
  "实现方式不适配 A770"，要找到适配 A770 的实现方式。
  正面教材：WQ-Cache v1 跳过被 walk 否决 → 用户的缓存+memcpy 形状 = -2.65 最大刀。
- 用户要的是**打破固化思路挖肉**，不是回炉验证已做过的东西、不是挖坟确认旧结论。
- 判决为负的实验的正确归宿：留开关留仪器 + **写下"实现错在哪、下一形状是什么"**，
  而不是把方案本身判死。ffn-5/6/8、slice1/2、B6 之前的"关门"措辞全部按此重审：
  它们全是"当前实现形状下的负"，不是"lmxxf 式布局的负"。
"""
if '收益优先军规' not in s:
    open(m,'a',encoding='utf-8',newline='\n').write(add)
    print('appended')
else:
    print('already')
