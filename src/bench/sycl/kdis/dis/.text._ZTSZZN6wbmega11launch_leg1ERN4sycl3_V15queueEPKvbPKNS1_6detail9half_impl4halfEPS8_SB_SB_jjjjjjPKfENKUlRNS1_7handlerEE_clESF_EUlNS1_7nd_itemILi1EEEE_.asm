L0:
(W)     mov (8|M0)               r127.0<1>:ud  0x0:ud                              {A@1}
(W)     and (1|M0)               r127.2<1>:ud  r0.0<0;1,0>:ud    0xFFFFFFC0:ud             
(W)     and (1|M0)               r127.0<1>:uw  r0.4<0;1,0>:uw    0xFF:uw             
(W)     add (1|M0)               r127.2<1>:ud  r127.2<0;1,0>:ud  0x60:ud              {I@2}
(W)     mad (1|M0)               r127.2<1>:ud  r127.2<0;0>:ud    r127.0<0;0>:uw    0x20:uw              {I@1}
(W)     send.dc0 (8|M0)          r1       r127    null:0  0x0            0x021842FD           {A@1,$0} // wr:1h+0, rd:1; oword aligned block read x2
        nop                    
        nop                    
(W)     mov (8|M0)               r127.0<1>:ud  0x0:ud                              {$0.src}
(W)     and (1|M0)               r127.2<1>:ud  r0.0<0;1,0>:ud    0xFFFFFFC0:ud             
(W)     send.dc0 (8|M0)          r2       r127    null:0  0x0            0x022843FD           {A@1,$1} // wr:1h+0, rd:2; oword aligned block read x4
(W)     add (1|M0)               r127.2<1>:ud  r127.2<0;1,0>:ud  0x40:uw              {$1.src}
(W)     send.dc0 (8|M0)          r4       r127    null:0  0x0            0x021842FD           {A@1,$2} // wr:1h+0, rd:1; oword aligned block read x2
(W)     mov (2|M0)               r96.0<1>:ud   r3.4<1;1,0>:ud                   {$1.dst}
        and (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   -1265:w               {A@1}
        or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   1216:w               {A@1}
        mov (1|M0)               r14.6<1>:d    r0.1<0;1,0>:ud                   {A@1}
        shr (1|M0)               r1.2<1>:ud    r0.1<0;1,0>:ud    0x1D:uw              {$0.dst}
        shr (1|M0)               r14.7<1>:ud   r14.6<0;1,0>:ud   0x3:uw              {I@2}
        and (1|M0)               r14.20<2>:b   r2.28<0;1,0>:b    1:w              
        mov (1|M0)               r14.4<1>:d    r1.0<0;1,0>:uw                  
        mov (1|M0)               r14.0<1>:d    r1.0<0;1,0>:uw                  
        mov (1|M0)               r14.1<1>:d    0:w                              
        shl (1|M0)               r14.2<1>:d    r0.1<0;1,0>:d     3:w              
        mov (1|M0)               r96.6<1>:d    r2.4<0;1,0>:d                   
        and (1|M0)               r14.6<1>:ud   r14.6<0;1,0>:ud   0x7:uw             
        or (1|M0)                r14.3<1>:d    r1.2<0;1,0>:d     0:w               {I@7}
        mov (1|M0)               r96.5<1>:d    r14.7<0;1,0>:d                   {I@7}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (32|M0)             r96.2         L11624                                 {A@1}
L496:
        cmp (1|M0)    (lt)f0.0   null<1>:uw    r1.0<0;1,0>:uw    0x8:uw             
        shl (1|M0)               r1.2<1>:d     r5.0<0;1,0>:d     3:w               {Compacted}
        add3 (1|M0)              r14.6<1>:d    r14.6<0;0>:d      -r2.2<0;0>:d      r1.2<0>:d        {I@1}
(W)     mov (1|M0)               r96.4<1>:uw   f0.0<0;1,0>:uw                   {Compacted}
(W)     and (1|M0)               f0.0<1>:ud    r96.4<0;1,0>:uw   0x1:uw              {I@1}
(~f0.0.any32h) goto (32|M0)                  L2336                  L2336                
L576:
(W)     mul (1|M0)               acc0.0<1>:d   r5.0<0;1,0>:d     r2.8<0;1,0>:uw   {Compacted}
        mach (1|M0)              r5.0<1>:d     r5.0<0;1,0>:d     r2.4<0;1,0>:d    {Compacted}
        cmp (1|M0)    (lt)f0.0   null<1>:d     r14.6<0;1,0>:d    r2.5<0;1,0>:d   
        add (1|M0)               r14.7<1>:d    r14.7<0;1,0>:d    -r5.0<0;1,0>:d   {I@2}
(W)     mov (1|M0)               r1.3<1>:hf    0x1:hf                             
        shl (1|M0)               r14.7<1>:d    r14.7<0;1,0>:d    3:w               {I@1}
(f0.0)  cmp (1|M0)    (gt)f0.0   null<1>:d     r14.6<0;1,0>:d    -1:w              
        add3 (1|M0)              r14.7<1>:d    r14.7<0;0>:d      -r2.3<0;0>:d      r1.0<0>:uw       {I@2}
        cmp (1|M0)    (lt)f0.1   null<1>:d     r14.7<0;1,0>:d    r2.6<0;1,0>:d    {I@1}
(f0.0)  sel (1|M0)               r1.4<1>:uw    r1.3<0;1,0>:uw    0x0:uw              {F@1}
(f0.1)  cmp (1|M0)    (gt)f0.1   null<1>:d     r14.7<0;1,0>:d    -1:w              
(f0.1)  sel (1|M0)               r2.0<1>:uw    r1.3<0;1,0>:uw    0x0:uw             
        and (1|M0)    (ne)f0.0   null<1>:uw    r1.4<0;1,0>:uw    r2.0<0;1,0>:uw   {I@1}
(W)     and (1|M0)               f0.0<1>:ud    f0.0<0;1,0>:uw    0x1:uw             
(f0.0.any32h) goto (32|M0)                   L832                  L832                
L800:
        mov (32|M0)              r113.0<1>:uw  0x0:uw                             
        goto (32|M0)                         L832                  L2288                
L832:
        join (32|M0)                         L2288                                
L848:
        mul (1|M0)               acc0.0<1>:ud  r14.6<0;1,0>:ud   r2.12<0;1,0>:uw 
        mach (1|M0)              r6.0<1>:ud    r14.6<0;1,0>:ud   r2.6<0;1,0>:ud   {AccWrEn}
        mov (1|M0)               r96.4<2>:f    0.0:f                              
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r96.5<2>:f    0.0:f                              
        addc (1|M0)              r2.0<1>:ud    r5.0<0;1,0>:ud    r14.7<0;1,0>:ud  {AccWrEn,I@1}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        shl (1|M0)               r4.5<1>:d     r2.0<0;1,0>:d     5:w               {Compacted,I@2}
        add3 (1|M0)              r1.3<1>:d     r7.0<0;0>:d       r6.0<0;0>:d       0:w               {I@2}
        shr (1|M0)               r4.4<1>:ud    r2.0<0;1,0>:ud    0x1B:uw             
        shl (1|M0)               r8.2<1>:d     r4.5<0;1,0>:d     2:w               {I@3}
        shl (1|M0)               r2.1<1>:d     r1.3<0;1,0>:d     5:w               {I@3}
        shl (1|M0)               r1.4<1>:d     r4.5<0;1,0>:d     1:w              
        addc (1|M0)              r9.0<1>:ud    r3.0<0;1,0>:ud    r8.2<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r4.6<1>:d     r2.1<0;1,0>:d     r4.4<0;1,0>:d    {I@3}
        shr (1|M0)               r8.1<1>:ud    r4.5<0;1,0>:ud    0x1E:uw             
        shr (1|M0)               r1.3<1>:ud    r4.5<0;1,0>:ud    0x1F:uw             
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        shl (1|M0)               r8.0<1>:d     r4.6<0;1,0>:d     2:w               {Compacted,I@4}
        shl (1|M0)               r1.2<1>:d     r4.6<0;1,0>:d     1:w              
        addc (1|M0)              r2.0<1>:ud    r3.0<0;1,0>:ud    r1.4<0;1,0>:ud   {AccWrEn}
        or (1|M0)                r8.3<1>:d     r8.0<0;1,0>:d     r8.1<0;1,0>:d    {I@3}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@3}
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r14.6<1>:d    r9.0<0;1,0>:d                   
        mov (1|M0)               r4.6<1>:d     0:w                              
        mov (1|M0)               r4.4<1>:d     r2.0<0;1,0>:d                    {I@6}
        add3 (1|M0)              r14.7<1>:d    r10.0<0;0>:d      r3.1<0;0>:d       r8.3<0>:d        {I@6}
        add3 (1|M0)              r4.5<1>:d     r5.0<0;0>:d       r3.1<0;0>:d       r1.5<0>:d        {I@5}
L1264:
        cmp (1|M0)    (eq)f0.0   null<1>:w     r14.20<0;1,0>:b   0:w              
(W)     and (1|M0)               f0.0<1>:ud    f0.0<0;1,0>:uw    0x1:uw             
(f0.0.any32h) goto (32|M0)                   L1472                  L1472                
L1312:
        shl (1|M0)               r1.4<1>:d     r96.4<0;1,0>:d    1:w               {F@2}
        shl (1|M0)               r1.2<1>:d     r96.5<0;1,0>:d    1:w               {F@1}
        shr (1|M0)               r1.3<1>:ud    r96.4<0;1,0>:ud   0x1F:uw             
        addc (1|M0)              r2.0<1>:ud    r4.4<0;1,0>:ud    r1.4<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r6.0<1>:f     r2.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r6.1<1>:d     r5.0<0;0>:d       r4.5<0;0>:d       r1.5<0>:d        {I@1}
        send.ugm (1|M0)          r7       r6      null:0  0x0            0x04100B80           {A@1,$3} // wr:2+0, rd:1; load.ugm.d16u32.a64
        mov (1|M0)               r2.0<1>:f     r7.0<0;1,0>:hf                   {$3.dst}
        goto (32|M0)                         L1472                  L1616                
L1472:
        join (32|M0)                         L1616                                
L1488:
        shl (1|M0)               r1.4<1>:d     r96.4<0;1,0>:d    2:w              
        shl (1|M0)               r1.2<1>:d     r96.5<0;1,0>:d    2:w              
        shr (1|M0)               r1.3<1>:ud    r96.4<0;1,0>:ud   0x1E:uw             
        addc (1|M0)              r2.0<1>:ud    r14.6<0;1,0>:ud   r1.4<0;1,0>:ud   {AccWrEn,A@1}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r6.0<1>:f     r2.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r6.1<1>:d     r5.0<0;0>:d       r14.7<0;0>:d      r1.5<0>:d        {I@1}
        send.ugm (1|M0)          r2       r6      null:0  0x0            0x04100580           {A@1,$4} // wr:2+0, rd:1; load.ugm.d32.a64
L1616:
        join (32|M0)                         L2288                                
L1632:
        cmp (1|M0)    (lt)f1.0   null<1>:f     r2.0<0;1,0>:f     0.0:f               {$4.dst}
(f1.0)  mov (1|M0)               r2.0<1>:f     -r2.0<0;1,0>:f                  
        sel (1|M0)    (lt)f0.0   r2.0<1>:f     r2.0<0;1,0>:f     448.0:f               {F@1}
        shr (1|M0)               r96.3<1>:ud   r2.0<0;1,0>:ud    0x17:uw              {F@1}
        and (1|M0)               r96.3<1>:ud   r96.3<0;1,0>:ud   0xFF:uw              {I@1}
        sel (1|M0)    (ge)f0.0   r96.3<1>:ud   r96.3<0;1,0>:ud   0x79:uw              {I@1}
        shl (1|M0)               r96.3<1>:ud   r96.3<0;1,0>:ud   0x17:uw              {I@1}
        add (1|M0)               r1.2<1>:ud    -r96.3<0;1,0>:ud  0x80800000:ud              {I@1}
        mul (1|M0)               r1.3<1>:f     r2.0<0;1,0>:f     r1.2<0;1,0>:f    {I@1}
        mov (1|M0)               r2.1<1>:d     r1.3<0;1,0>:f                    {F@1}
        mov (1|M0)               r4.7<1>:f     r2.1<0;1,0>:d                    {I@1}
        mad (1|M0)               r2.0<1>:f     -r4.7<0;0>:f      r1.2<0;0>:f       r2.0<0>:f        {F@1}
        cmp (1|M0)    (gt)f0.0   null<1>:f     r2.0<0;1,0>:f     0.5:f               {F@1}
(W)     and (1|M0)               f0.0<1>:ud    f0.0<0;1,0>:uw    0x1:uw              {F@1}
(f0.0.any32h) goto (32|M0)                   L1960                  L1960                
L1872:
        cmp (1|M0)    (lt)f0.0   null<1>:f     r2.0<0;1,0>:f     0.5:f               {A@1}
        and (1|M0)               r2.1<1>:d     r2.1<0;1,0>:d     1:w               {Compacted}
        add (1|M0)               r1.2<1>:f     r4.7<0;1,0>:f     1.0:f              
(~f0.0) cmp (1|M0)    (eq)f0.0   null<1>:d     r2.1<0;1,0>:d     0:w               {A@1}
(~f0.0) mov (1|M0)               r4.7<1>:f     r1.2<0;1,0>:f                    {F@1}
        goto (32|M0)                         L1960                  L1992                
L1960:
        join (32|M0)                         L1992                                
L1976:
        add (1|M0)               r4.7<1>:f     r4.7<0;1,0>:f     1.0:f               {F@1}
L1992:
        join (32|M0)                         L2288                                
L2008:
        addc (1|M0)              r5.0<1>:ud    r96.4<0;1,0>:ud   0x1:ud              {AccWrEn}
        add (1|M0)               r96.3<1>:ud   r96.3<0;1,0>:ud   0xFE800000:ud             
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r1.2<1>:d     r5.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r1.3<1>:d     r6.0<0;0>:d       r96.5<0;0>:d      0:w               {I@2}
        mul (1|M0)               r4.7<1>:f     r4.7<0;1,0>:f     r96.3<0;1,0>:f   {F@1}
        cmp (1|M0)    (eq)f0.0   null<1>:d     r1.3<0;1,0>:d     0:w               {I@1}
(f1.0)  mov (1|M0)               r4.7<1>:f     -r4.7<0;1,0>:f                   {F@1}
        shl (1|M0)               r1.3<1>:w     r4.12<0;1,0>:w    1:w              
(W)     mov (1|M0)               r2.0<2>:hf    r4.7<0;1,0>:f                    {F@1}
(f0.0)  cmp (1|M0)    (eq)f0.0   null<1>:d     r1.2<0;1,0>:d     32:w              
        add (1|M0)               r4.6<1>:d     r4.6<0;1,0>:d     1:w              
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0xE20:uw              {A@1}
        mov (1|M0)               r[a0.0]<1>:hf  r2.0<0;1,0>:hf                  {F@1}
(W)     and (1|M0)               f0.0<1>:ud    f0.0<0;1,0>:uw    0x1:uw             
(f0.0.any32h) goto (32|M0)                   L2288                  L2288                
L2256:
(W)     mov (2|M0)               r96.4<1>:ud   r1.2<1;1,0>:ud                  
        goto.b (32|M0)                       L2288                  L1264                
L2288:
        join (32|M0)                         L2336                                
L2304:
        sync.nop                             null                             {Compacted,$4.dst}
        shl (1|M0)               r2.0<1>:d     r14.4<0;1,0>:d    6:w               {Compacted,F@1}
        send.slm (1|M0)          null     r2      r113:2  0x0            0x0200C704           {A@1,$5} // wr:1+2, rd:0; store.slm.d64x8t.a32
L2336:
        join (32|M0)                         L2352                                
L2352:
(W)     send.slm (1|M0)          r5       r0      null:0  0x0            0x0210001F           {$6} // wr:1+0, rd:1; fence.slm.none.group
(W)     mov (1|M0)               r6.2<1>:f     0.0:f                               {Compacted,$4.src}
(W)     mov (2|M0)               r6.10<1>:ub   r0.11<0;1,0>:ub                  {F@1}
(W)     mov (8|M0)               null<1>:ud    r5.0<1;1,0>:ud                   {$6.dst}
(W)     send.gtwy (1|M0)         null     r6      null:0  0x0            0x02000004           {A@2,$7} // wr:1+0, rd:0; signal barrier
(W)     sync.bar                             null                            
        cmp (1|M0)    (lt)f0.0   null<1>:uw    r1.0<0;1,0>:uw    0x4:uw             
(W)     and (1|M0)               f0.0<1>:ud    f0.0<0;1,0>:uw    0x1:uw             
(f0.0.any32h) goto (32|M0)                   L2520                  L2520                
L2488:
        shl (1|M0)               r14.4<1>:d    r14.4<0;1,0>:d    7:w              
        goto (32|M0)                         L2520                  L2976                
L2520:
        join (32|M0)                         L2976                                
L2536:
        shl (1|M0)               r1.2<1>:d     r14.4<0;1,0>:d    8:w               {I@3}
        cmp (1|M0)    (lt)f0.0   null<1>:uw    r1.0<0;1,0>:uw    0x2:uw             
        sync.nop                             null                             {Compacted,$4.dst}
        sync.nop                             null                             {Compacted,$5.src}
        and (1|M0)               r2.0<1>:d     r1.2<0;1,0>:d     256:w               {Compacted,I@2}
(W)     mov (1|M0)               r2.2<1>:hf    0.0:hf                             
        send.slm (1|M0)          r121     r2      null:0  0x0            0x0220C700           {A@1,$8} // wr:1+0, rd:2; load.slm.d64x8t.a32
(f0.0)  sel (1|M0)               r4.8<1>:w     r2.2<0;1,0>:w     32:w              
        or (1|M0)                r9.0<1>:ud    r2.0<0;1,0>:ud    0x40:uw             
        add (1|M0)               a0.0<1>:uw    r4.8<0;1,0>:uw    0xF20:uw              {A@1}
        send.slm (1|M0)          r119     r9      null:0  0x0            0x0220C700           {A@2,$9} // wr:1+0, rd:2; load.slm.d64x8t.a32
        or (1|M0)                r10.0<1>:ud   r2.0<0;1,0>:ud    0x80:uw             
        or (1|M0)                r11.0<1>:ud   r2.0<0;1,0>:ud    0xC0:uw             
        mov (8|M0)               r5.0<1>:uw    r[a0.0]<1;1,0>:uw                {$8.dst}
        mov (8|M0)               r5.8<1>:uw    r[a0.0,16]<1;1,0>:uw             {A@1}
        add (1|M0)               a0.0<1>:uw    r4.8<0;1,0>:uw    0xEE0:uw              {A@1}
        send.slm (1|M0)          r117     r10     null:0  0x0            0x0220C700           {A@5,$10} // wr:1+0, rd:2; load.slm.d64x8t.a32
        send.slm (1|M0)          r115     r11     null:0  0x0            0x0220C700           {A@4,$11} // wr:1+0, rd:2; load.slm.d64x8t.a32
        shl (1|M0)               r14.4<1>:d    r14.4<0;1,0>:d    7:w              
        sync.nop                             null                             {Compacted,$9.dst}
        mov (8|M0)               r6.0<1>:uw    r[a0.0]<1;1,0>:uw                {$7.src}
        mov (8|M0)               r6.8<1>:uw    r[a0.0,16]<1;1,0>:uw             {A@1}
        add (1|M0)               a0.0<1>:uw    r4.8<0;1,0>:uw    0xEA0:uw              {A@1}
        or (1|M0)                r9.0<1>:d     r14.4<0;1,0>:d    512:w               {Compacted,I@4}
        mov (8|M0)               r7.0<1>:uw    r[a0.0]<1;1,0>:uw                {$10.dst}
        mov (8|M0)               r7.8<1>:uw    r[a0.0,16]<1;1,0>:uw             {A@1}
        add (1|M0)               a0.0<1>:uw    r4.8<0;1,0>:uw    0xE60:uw              {A@1}
        mov (8|M0)               r8.0<1>:uw    r[a0.0]<1;1,0>:uw                {$11.dst}
        mov (8|M0)               r8.8<1>:uw    r[a0.0,16]<1;1,0>:uw             {A@1}
        send.slm (1|M0)          null     r9      r5:4    0x0            0x0200D704           {A@1,$12} // wr:1+4, rd:0; store.slm.d64x16t.a32
L2976:
        join (32|M0)                         L2992                                
L2992:
        sync.nop                             null                             {Compacted,$12.src}
(W)     send.slm (1|M0)          r5       r0      null:0  0x0            0x0210001F           {$13} // wr:1+0, rd:1; fence.slm.none.group
(W)     mov (1|M0)               r6.2<1>:f     0.0:f                               {Compacted,$7.src}
(W)     mov (2|M0)               r6.10<1>:ub   r0.11<0;1,0>:ub                  {F@1}
(W)     mov (8|M0)               null<1>:ud    r5.0<1;1,0>:ud                   {$13.dst}
(W)     send.gtwy (1|M0)         null     r6      null:0  0x0            0x02000004           {A@2,$14} // wr:1+0, rd:0; signal barrier
(W)     sync.bar                             null                            
        mov (2|M0)               r1.8<1>:w     0x80808080:uv                             
        mov (2|M0)               r108.0<1>:d   0x1:v                              
        sync.nop                             null                             {Compacted,$4.dst}
        sync.nop                             null                             {Compacted,$5.src}
        add (2|M0)               r2.0<1>:d     r1.8<1;1,0>:w     -8:w               {I@2}
        mov (16|M0)              r84.0<1>:f    0.0:f                               {Compacted}
        bfn.0xEA (2|M0)          r14.0<1>:ud   r14.0<1;0>:ud     r14.2<1;0>:ud     r2.0<1>:ud       {I@1} // s0|s1&s2
        mov (4|M0)               r2.0<1>:w     0x64206420:v                              
        shl (1|M0)               r4.6<1>:d     r14.0<0;1,0>:d    5:w               {Compacted,I@2}
        mov (4|M0)               r8.0<4>:uw    r2.0<1;1,0>:uw                   {I@2}
        shl (1|M0)               r4.4<1>:d     r14.1<0;1,0>:d    5:w              
        mov (4|M0)               r105.0<2>:d   r8.0<4;1,0>:w                    {I@2}
        shr (1|M0)               r4.5<1>:ud    r14.0<0;1,0>:ud   0x1B:uw             
        shl (1|M0)               r96.6<1>:d    r4.6<0;1,0>:d     1:w              
        asr (4|M0)               r105.1<2>:d   r105.0<2;1,0>:d   31:w               {I@3}
        or (1|M0)                r4.7<1>:d     r4.4<0;1,0>:d     r4.5<0;1,0>:d    {I@3}
        sync.nop                             null                             {Compacted,$14.src}
        addc (1|M0)              r6.0<1>:ud    r4.2<0;1,0>:ud    r96.6<0;1,0>:ud  {AccWrEn,I@3}
        mov (4|M0)               r9.0<2>:ud    r105.0<2;1,0>:ud                 {I@3}
        mov (4|M0)               r9.1<2>:ud    r105.1<2;1,0>:ud                
        shr (1|M0)               r5.1<1>:ud    r4.6<0;1,0>:ud    0x1F:uw             
        shl (1|M0)               r5.0<1>:d     r4.7<0;1,0>:d     1:w               {Compacted,I@5}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (4|M0)              r10.0<1>:ud   r9.0<2;1,0>:ud    0x8:ud              {AccWrEn,I@4}
        mov (1|M0)               r96.4<1>:d    r6.0<0;1,0>:d                   
        or (1|M0)                r96.7<1>:d    r5.0<0;1,0>:d     r5.1<0;1,0>:d    {I@4}
        mov (4|M0)               r5.0<1>:ud    acc0.0<1;1,0>:ud                
        addc (4|M0)              r6.0<1>:ud    r9.0<2;1,0>:ud    0x10:ud              {AccWrEn}
        add3 (1|M0)              r96.5<1>:d    r7.0<0;0>:d       r4.3<0;0>:d       r96.7<0>:d       {I@3}
        mov (4|M0)               r7.0<1>:ud    acc0.0<1;1,0>:ud                
        addc (4|M0)              r8.0<1>:ud    r9.0<2;1,0>:ud    0x18:ud              {AccWrEn}
        mov (4|M0)               r106.0<2>:d   r10.0<1;1,0>:d                  
        mov (4|M0)               r11.0<1>:ud   acc0.0<1;1,0>:ud                
        addc (4|M0)              r12.0<1>:ud   r9.0<2;1,0>:ud    0x20:ud              {AccWrEn}
        add3 (4|M0)              r106.1<2>:d   r5.0<1;0>:d       r9.1<4;2>:d       0:w               {I@7}
        mov (4|M0)               r13.0<1>:ud   acc0.0<1;1,0>:ud                
        addc (4|M0)              r5.0<1>:ud    r9.0<2;1,0>:ud    0x28:ud              {AccWrEn}
        mov (4|M0)               r103.0<2>:d   r6.0<1;1,0>:d                    {I@7}
        mov (4|M0)               r10.0<1>:ud   acc0.0<1;1,0>:ud                
        addc (4|M0)              r6.0<1>:ud    r9.0<2;1,0>:ud    0x30:ud              {AccWrEn}
        mov (4|M0)               r104.0<2>:d   r8.0<1;1,0>:d                    {I@7}
        add3 (4|M0)              r103.1<2>:d   r7.0<1;0>:d       r9.1<4;2>:d       0:w              
        mov (4|M0)               r7.0<1>:ud    acc0.0<1;1,0>:ud                
        addc (4|M0)              r8.0<1>:ud    r9.0<2;1,0>:ud    0x38:ud              {AccWrEn}
        add3 (4|M0)              r104.1<2>:d   r11.0<1;0>:d      r9.1<4;2>:d       0:w              
        mov (4|M0)               r11.0<1>:ud   acc0.0<1;1,0>:ud                
        addc (1|M0)              r2.0<1>:ud    r3.2<0;1,0>:ud    0xC00:ud              {AccWrEn}
        mov (4|M0)               r102.0<2>:d   r5.0<1;1,0>:d                    {I@7}
        mov (4|M0)               r99.0<2>:d    r6.0<1;1,0>:d                    {I@7}
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r6.0<1>:ud    r3.2<0;1,0>:ud    0xE00:ud              {AccWrEn}
        add3 (4|M0)              r99.1<2>:d    r7.0<1;0>:d       r9.1<4;2>:d       0:w               {I@7}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (16|M0)              r86.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r88.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r90.0<1>:f    0.0:f                               {Compacted}
        or (1|M0)                r107.0<1>:d   r14.4<0;1,0>:d    1024:w               {Compacted}
        mov (1|M0)               r107.2<2>:f   0.0:f                              
        mov (1|M0)               r107.3<2>:f   0.0:f                              
        mul (2|M0)               r108.0<1>:d   r108.0<1;1,0>:d   256:w              
        mov (4|M0)               r101.0<2>:d   r12.0<1;1,0>:d                  
        mov (4|M0)               r100.0<2>:d   r8.0<1;1,0>:d                   
        add3 (4|M0)              r102.1<2>:d   r10.0<1;0>:d      r9.1<4;2>:d       0:w              
        mov (1|M0)               r107.6<1>:d   r2.0<0;1,0>:d                   
        add3 (1|M0)              r107.7<1>:d   r5.0<0;0>:d       r3.3<0;0>:d       0:w               {I@7}
        mov (1|M0)               r107.4<1>:d   r6.0<0;1,0>:d                    {I@7}
        add3 (1|M0)              r107.5<1>:d   r7.0<0;0>:d       r3.3<0;0>:d       0:w               {I@7}
        add3 (4|M0)              r101.1<2>:d   r13.0<1;0>:d      r9.1<4;2>:d       0:w              
        add3 (4|M0)              r100.1<2>:d   r11.0<1;0>:d      r9.1<4;2>:d       0:w              
L4088:
        shl (1|M0)               r1.2<1>:d     r107.3<0;1,0>:d   9:w               {F@1}
        shr (1|M0)               r1.3<1>:ud    r107.2<0;1,0>:ud  0x17:uw             
        shl (1|M0)               r1.4<1>:d     r107.2<0;1,0>:d   9:w              
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        shl (1|M0)               r4.6<1>:d     r1.4<0;1,0>:d     1:w               {I@2}
        shr (1|M0)               r4.5<1>:ud    r1.4<0;1,0>:ud    0x1F:uw             
        shl (1|M0)               r4.4<1>:d     r1.5<0;1,0>:d     1:w               {I@3}
        sync.nop                             null                             {Compacted,$15.src}
        addc (1|M0)              r13.0<1>:ud   r3.2<0;1,0>:ud    r4.6<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r4.7<1>:d     r4.4<0;1,0>:d     r4.5<0;1,0>:d    {I@2}
        mov (1|M0)               r14.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r15.0<1>:f    r13.0<0;1,0>:f                   {Compacted,I@3}
        add3 (1|M0)              r15.1<1>:d    r14.0<0;0>:d      r3.3<0;0>:d       r4.7<0>:d        {I@1}
        or (2|M0)                r1.4<1>:d     r1.4<1;1,0>:d     r108.0<1;1,0>:d 
        sync.allrd                           ($1,$2,$3,$4)                
        send.ugm (1|M0)          r16      r15     null:0  0x0            0x0280E780           {A@1,$6} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        mov (1|M0)               r2.0<1>:d     512:w                              
        addc (1|M0)              r24.0<1>:ud   r15.0<0;1,0>:ud   0x100:ud              {AccWrEn}
        shl (1|M0)               r4.4<1>:d     r1.4<0;1,0>:d     1:w               {I@3}
        sync.allrd                           ($0,$5)                
        send.slm (1|M0)          r5       r2      null:0  0x0            0x0280E700           {A@3,$7} // wr:1+0, rd:8; load.slm.d64x32t.a32
        mov (1|M0)               r25.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r13.0<1>:ud   r3.2<0;1,0>:ud    r4.4<0;1,0>:ud   {AccWrEn,I@2}
        shl (1|M0)               r1.2<1>:d     r1.5<0;1,0>:d     1:w              
        shr (1|M0)               r1.3<1>:ud    r1.4<0;1,0>:ud    0x1F:uw             
        mov (1|M0)               r2.0<1>:f     r24.0<0;1,0>:f                   {Compacted,$7.src}
        add3 (1|M0)              r2.1<1>:d     r25.0<0;0>:d      r15.1<0;0>:d      0:w               {I@4}
        sync.nop                             null                             {Compacted,$6.src}
        mov (1|M0)               r15.0<1>:f    r13.0<0;1,0>:f                   {Compacted,I@4}
        send.ugm (1|M0)          r26      r2      null:0  0x0            0x0280E780           {A@1,$8} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        mov (1|M0)               r14.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        or (1|M0)                r4.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d   
        sync.nop                             null                             {Compacted,$8.src}
        addc (1|M0)              r2.0<1>:ud    r15.0<0;1,0>:ud   0x100:ud              {AccWrEn,F@1}
        add3 (1|M0)              r15.1<1>:d    r14.0<0;0>:d      r3.3<0;0>:d       r4.5<0>:d        {I@2}
        mov (1|M0)               r13.0<1>:d    768:w                              
        send.ugm (1|M0)          r50      r15     null:0  0x0            0x0280E780           {A@2,$9} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        send.slm (1|M0)          r66      r13     null:0  0x0            0x0280E700           {A@1,$10} // wr:1+0, rd:8; load.slm.d64x32t.a32
        sync.allwr                           ($6,$7)                
        dpas.8x8 (8|M0)          r34:f         null:f            r34:hf            r34.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r34:f         r84:f             r16:hf            r5.0:hf          {$6}
        mov (1|M0)               r16.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,$6.src}
        addc (1|M0)              r14.0<1>:ud   r107.6<0;1,0>:ud  r4.6<0;1,0>:ud   {AccWrEn}
        mov (1|M0)               r17.0<1>:f    r2.0<0;1,0>:f                    {Compacted}
        mov (1|M0)               r74.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        add3 (1|M0)              r17.1<1>:d    r16.0<0;0>:d      r15.1<0;0>:d      0:w               {I@3}
        mov (1|M0)               r75.0<1>:f    r14.0<0;1,0>:f                   {Compacted,I@3}
        add3 (1|M0)              r75.1<1>:d    r74.0<0;0>:d      r107.7<0;0>:d     r4.7<0>:d        {I@2}
        send.ugm (1|M0)          r18      r17     null:0  0x0            0x0280E780           {A@2,$11} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        send.ugm (1|M0)          r76      r75     null:0  0x0            0x0280E780           {A@1,$12} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        addc (1|M0)              r2.0<1>:ud    r75.0<0;1,0>:ud   0x100:ud              {AccWrEn}
        mov (1|M0)               r15.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,$9.src}
        addc (1|M0)              r13.0<1>:ud   r107.4<0;1,0>:ud  r4.6<0;1,0>:ud   {AccWrEn,$10.src}
        mov (1|M0)               r16.0<1>:f    r2.0<0;1,0>:f                    {Compacted,I@3}
        sync.nop                             null                             {Compacted,$11.src}
        mov (1|M0)               r17.0<1>:f    r13.0<0;1,0>:f                   {Compacted,I@1}
        mov (1|M0)               r14.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r2.0<1>:ud    r17.0<0;1,0>:ud   0x100:ud              {AccWrEn,F@1}
        add3 (1|M0)              r16.1<1>:d    r15.0<0;0>:d      r75.1<0;0>:d      0:w              
        add3 (1|M0)              r17.1<1>:d    r14.0<0;0>:d      r107.5<0;0>:d     r4.7<0>:d        {I@3}
        mov (1|M0)               r15.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        sync.allwr                           ($8,$9)                
        dpas.8x8 (8|M0)          r42:f         r84:f             r26:hf            r5.0:hf          {Atomic}
        dpas.8x8 (8|M0)          r26:f         r84:f             r50:hf            r5.0:hf          {$8}
        sync.nop                             null                             {Compacted,$8.src}
        mov (1|M0)               r50.0<1>:f    r2.0<0;1,0>:f                    {Compacted,I@4}
        add3 (1|M0)              r50.1<1>:d    r15.0<0;0>:d      r17.1<0;0>:d      0:w               {I@1}
        mov (1|M0)               r14.0<1>:d    1152:w                              
        mov (1|M0)               r2.0<1>:d     1088:w                               {F@1}
        mov (1|M0)               r15.0<1>:d    1216:w                              
        dpas.8x8 (8|M0)          r58:f         r84:f             r18:hf            r5.0:hf          {$11}
        sync.nop                             null                             {Compacted,$11.src}
        send.ugm (1|M0)          r5       r16     null:0  0x0            0x0280E780           {$13} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        send.ugm (1|M0)          r18      r17     null:0  0x0            0x0280E780           {$14} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        sync.allwr                           ($6,$12)                
        dpas.8x8 (8|M0)          r34:f         r34:f             r76:hf            r66.0:hf         {$10}
        sync.nop                             null                             {Compacted,$10.src}
        send.ugm (1|M0)          r74      r50     null:0  0x0            0x0280E780           {A@4,$7} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        sync.nop                             null                             {Compacted,$10.dst}
        mov (8|M0)               r16.0<1>:f    r36.0<1;1,0>:f                   {Compacted,$13.src}
        sync.allwr                           ($8,$13,$14)                
        dpas.8x8 (8|M0)          r42:f         r42:f             r5:hf             r66.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r26:f         r26:f             r18:hf            r66.0:hf         {$8}
        mov (8|M0)               r5.0<1>:f     r34.0<1;1,0>:f                   {Compacted,$8.src}
        sync.nop                             null                             {Compacted,$7.dst}
        dpas.8x8 (8|M0)          r58:f         r58:f             r74:hf            r66.0:hf         {$11}
        mov (1|M0)               r9.0<1>:d     1024:w                              
        mov (8|M0)               r10.0<1>:f    r35.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r6.0<1>:f     r42.0<1;1,0>:f                   {Compacted,$8.dst}
        mov (8|M0)               r11.0<1>:f    r43.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r7.0<1>:f     r26.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r12.0<1>:f    r27.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r8.0<1>:f     r58.0<1;1,0>:f                   {Compacted,$11.dst}
        mov (8|M0)               r13.0<1>:f    r59.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r9      r5:2    0x0            0x0200C704           {A@1,$9} // wr:1+2, rd:0; store.slm.d64x8t.a32
        send.slm (1|M0)          null     r2      r7:2    0x0            0x0200C704           {A@2,$10} // wr:1+2, rd:0; store.slm.d64x8t.a32
        send.slm (1|M0)          null     r14     r10:2   0x0            0x0200C704           {$11} // wr:1+2, rd:0; store.slm.d64x8t.a32
        send.slm (1|M0)          null     r15     r12:2   0x0            0x0200C704           {A@1,$12} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r17.0<1>:f    r44.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r5.0<1>:f     r28.0<1;1,0>:f                   {Compacted,$9.src}
        mov (8|M0)               r6.0<1>:f     r60.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r9.0<1>:f     r45.0<1;1,0>:f                   {Compacted}
        mov (1|M0)               r2.0<1>:d     1280:w                               {$10.src}
        mov (1|M0)               r7.0<1>:d     1344:w                              
        mov (8|M0)               r8.0<1>:f     r37.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r10.0<1>:f    r29.0<1;1,0>:f                   {Compacted,$11.src}
        mov (8|M0)               r11.0<1>:f    r61.0<1;1,0>:f                   {Compacted}
        mov (1|M0)               r12.0<1>:d    1408:w                               {$12.src}
        mov (1|M0)               r13.0<1>:d    1472:w                              
        send.slm (1|M0)          null     r2      r16:2   0x0            0x0200C704           {A@4,$13} // wr:1+2, rd:0; store.slm.d64x8t.a32
        send.slm (1|M0)          null     r7      r5:2    0x0            0x0200C704           {A@3,$14} // wr:1+2, rd:0; store.slm.d64x8t.a32
        send.slm (1|M0)          null     r12     r8:2    0x0            0x0200C704           {A@2,$6} // wr:1+2, rd:0; store.slm.d64x8t.a32
        send.slm (1|M0)          null     r13     r10:2   0x0            0x0200C704           {A@1,$7} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r14.0<1>:f    r38.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r15.0<1>:f    r46.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r16.0<1>:f    r30.0<1;1,0>:f                   {Compacted,$13.src}
        mov (8|M0)               r17.0<1>:f    r62.0<1;1,0>:f                   {Compacted}
        mov (1|M0)               r2.0<1>:d     1536:w                              
        mov (1|M0)               r5.0<1>:d     1600:w                               {$14.src}
        mov (8|M0)               r6.0<1>:f     r39.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r7.0<1>:f     r47.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r8.0<1>:f     r31.0<1;1,0>:f                   {Compacted,$6.src}
        mov (8|M0)               r9.0<1>:f     r63.0<1;1,0>:f                   {Compacted}
        mov (1|M0)               r10.0<1>:d    1664:w                               {$7.src}
        mov (1|M0)               r11.0<1>:d    1728:w                              
        send.slm (1|M0)          null     r2      r14:2   0x0            0x0200C704           {A@4,$8} // wr:1+2, rd:0; store.slm.d64x8t.a32
        send.slm (1|M0)          null     r5      r16:2   0x0            0x0200C704           {A@3,$9} // wr:1+2, rd:0; store.slm.d64x8t.a32
        send.slm (1|M0)          null     r10     r6:2    0x0            0x0200C704           {A@2,$10} // wr:1+2, rd:0; store.slm.d64x8t.a32
        send.slm (1|M0)          null     r11     r8:2    0x0            0x0200C704           {A@1,$11} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r12.0<1>:f    r40.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r13.0<1>:f    r48.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r14.0<1>:f    r32.0<1;1,0>:f                   {Compacted,$8.src}
        mov (8|M0)               r15.0<1>:f    r64.0<1;1,0>:f                   {Compacted}
        mov (1|M0)               r2.0<1>:d     1792:w                              
        mov (1|M0)               r5.0<1>:d     1856:w                               {$9.src}
        mov (8|M0)               r16.0<1>:f    r41.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r17.0<1>:f    r49.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r6.0<1>:f     r33.0<1;1,0>:f                   {Compacted,$10.src}
        mov (8|M0)               r7.0<1>:f     r65.0<1;1,0>:f                   {Compacted}
        mov (1|M0)               r8.0<1>:d     1920:w                               {$11.src}
        mov (1|M0)               r9.0<1>:d     1984:w                              
        send.slm (1|M0)          null     r2      r12:2   0x0            0x0200C704           {A@4,$12} // wr:1+2, rd:0; store.slm.d64x8t.a32
        send.slm (1|M0)          null     r5      r14:2   0x0            0x0200C704           {A@3,$13} // wr:1+2, rd:0; store.slm.d64x8t.a32
        send.slm (1|M0)          null     r8      r16:2   0x0            0x0200C704           {A@2,$1} // wr:1+2, rd:0; store.slm.d64x8t.a32
        send.slm (1|M0)          null     r9      r6:2    0x0            0x0200C704           {A@1,$14} // wr:1+2, rd:0; store.slm.d64x8t.a32
(W)     send.slm (1|M0)          r10      r0      null:0  0x0            0x0210001F           {$6} // wr:1+0, rd:1; fence.slm.none.group
(W)     mov (1|M0)               r11.2<1>:f    0.0:f                               {Compacted}
(W)     mov (2|M0)               r11.10<1>:ub  r0.11<0;1,0>:ub                  {F@1}
(W)     mov (8|M0)               null<1>:ud    r10.0<1;1,0>:ud                  {$6.dst}
(W)     send.gtwy (1|M0)         null     r11     null:0  0x0            0x02000004           {A@2,$0} // wr:1+0, rd:0; signal barrier
(W)     sync.bar                             null                            
(W)     and (1|M0)               f0.0<1>:ud    r96.4<0;1,0>:uw   0x1:uw             
(~f0.0.any32h) goto (32|M0)                  L11280                  L11280                
L6072:
        send.slm (1|M0)          r109     r107    null:0  0x0            0x0240D700           {$7} // wr:1+0, rd:4; load.slm.d64x16t.a32
        mov (1|M0)               r4.4<2>:f     0.0:f                              
        mov (1|M0)               r4.5<2>:f     0.0:f                              
        mov (1|M0)               r4.2<1>:d     0:w                              
L6136:
        sync.nop                             null                             {Compacted,$13.src}
        addc (1|M0)              r5.0<1>:ud    r4.4<0;1,0>:ud    0x1:ud              {AccWrEn,F@2}
        shl (1|M0)               r1.3<1>:w     r4.4<0;1,0>:w     2:w               {I@2}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$14.src}
        mov (1|M0)               r4.6<1>:d     r5.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r4.7<1>:d     r6.0<0;0>:d       r4.5<0;0>:d       0:w               {A@1}
        add (1|M0)               a0.1<1>:uw    r1.3<0;1,0>:uw    0xDA0:uw              {A@1}
        cmp (1|M0)    (eq)f0.0   null<1>:d     r4.7<0;1,0>:d     0:w               {I@2}
        shl (1|M0)               r2.0<1>:w     r4.8<0;1,0>:w     2:w               {$12.src}
        add (1|M0)               r4.2<1>:d     r4.2<0;1,0>:d     1:w              
        add (1|M0)               a0.0<1>:uw    r2.0<0;1,0>:uw    0xB80:uw              {A@1}
(f0.0)  cmp (1|M0)    (eq)f0.0   null<1>:d     r4.6<0;1,0>:d     32:w              
        mov (1|M0)               r[a0.0]<1>:f  r[a0.1]<0;1,0>:f                 {$7.dst}
(W)     and (1|M0)               f0.0<1>:ud    f0.0<0;1,0>:uw    0x1:uw              {A@1}
(f0.0.any32h) goto (32|M0)                   L6392                  L6392                
L6360:
(W)     mov (2|M0)               r4.4<1>:ud    r4.6<1;1,0>:ud                  
        goto.b (32|M0)                       L6392                  L6136                
L6392:
        join (32|M0)                         L11280                                
L6408:
        cmp (1|M0)    (eq)f0.0   null<1>:d     r107.2<0;1,0>:d   2:w              
        cmp (1|M0)    (eq)f1.0   null<1>:d     r107.3<0;1,0>:d   0:w              
(W)     mov (1|M0)               r1.3<1>:hf    0x1:hf                             
(f0.0)  sel (1|M0)               r1.4<1>:uw    r1.3<0;1,0>:uw    0x0:uw              {F@1}
(f1.0)  sel (1|M0)               r2.0<1>:uw    r1.3<0;1,0>:uw    0x0:uw             
        and (1|M0)    (ne)f0.0   null<1>:uw    r1.4<0;1,0>:uw    r2.0<0;1,0>:uw   {I@1}
(W)     and (1|M0)               f0.0<1>:ud    f0.0<0;1,0>:uw    0x1:uw             
(f0.0.any32h) goto (32|M0)                   L10040                  L10040                
L6536:
        mov (1|M0)               r4.2<2>:f     0.0:f                              
        mov (1|M0)               r4.3<2>:d     0:d                              
L6568:
        addc (1|M0)              r5.0<1>:ud    r4.2<0;1,0>:ud    0x1:ud              {AccWrEn,F@1}
        shl (1|M0)               r1.3<1>:w     r4.4<0;1,0>:w     2:w              
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r4.4<1>:d     r5.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r4.5<1>:d     r6.0<0;0>:d       r4.3<0;0>:d       0:w               {I@2}
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0xB80:uw              {A@1}
        cmp (1|M0)    (eq)f0.0   null<1>:d     r4.5<0;1,0>:d     0:w               {I@2}
        mov (1|M0)               r2.0<2>:hf    r[a0.0]<0;1,0>:f                
(f0.0)  cmp (1|M0)    (eq)f0.0   null<1>:d     r4.4<0;1,0>:d     32:w               {A@1}
        mov (1|M0)               r[a0.0]<1>:f  r2.0<0;1,0>:hf                   {F@1}
(W)     and (1|M0)               f0.0<1>:ud    f0.0<0;1,0>:uw    0x1:uw             
(f0.0.any32h) goto (32|M0)                   L6784                  L6784                
L6752:
(W)     mov (2|M0)               r4.2<1>:ud    r4.4<1;1,0>:ud                  
        goto.b (32|M0)                       L6784                  L6568                
L6784:
        join (32|M0)                         L10040                                
L6800:
        mul (1|M0)               r1.2<1>:f     r92.0<0;1,0>:f    r92.0<0;1,0>:f   {Compacted,F@1}
        mul (1|M0)               r5.1<1>:f     r94.0<0;1,0>:f    r94.0<0;1,0>:f   {Compacted}
        mov (1|M0)               r2.0<2>:hf    r1.2<0;1,0>:f                    {F@2}
        mul (1|M0)               r9.0<1>:f     r92.1<0;1,0>:f    r92.1<0;1,0>:f  
        mov (1|M0)               r4.4<1>:f     r2.0<0;1,0>:hf                   {A@2}
        mul (1|M0)               r2.1<1>:f     r94.1<0;1,0>:f    r94.1<0;1,0>:f  
        mov (1|M0)               r6.0<2>:hf    r5.1<0;1,0>:f                   
        mov (1|M0)               r10.0<2>:hf   r9.0<0;1,0>:f                    {F@4}
        mad (1|M0)               r4.4<1>:f     r4.4<0;0>:f       r93.0<0;0>:f      r93.0<0>:f       {F@4}
        mov (1|M0)               r7.0<1>:f     r6.0<0;1,0>:hf                   {F@3}
        mov (1|M0)               r1.2<1>:f     r10.0<0;1,0>:hf                  {F@3}
        mov (1|M0)               r5.0<2>:hf    r4.4<0;1,0>:f                    {F@3}
        mov (1|M0)               r4.8<2>:hf    r2.1<0;1,0>:f                   
        mad (1|M0)               r7.0<1>:f     r7.0<0;0>:f       r95.0<0;0>:f      r95.0<0>:f       {F@4}
        mad (1|M0)               r1.2<1>:f     r1.2<0;0>:f       r93.1<0;0>:f      r93.1<0>:f       {F@4}
        mov (1|M0)               r5.1<1>:f     r4.8<0;1,0>:hf                   {F@3}
        sync.nop                             null                             {Compacted,$1.src}
        mov (1|M0)               r8.0<2>:hf    r7.0<0;1,0>:f                    {F@3}
        mov (1|M0)               r2.0<2>:hf    r1.2<0;1,0>:f                    {F@3}
        mad (1|M0)               r5.1<1>:f     r5.1<0;0>:f       r95.1<0;0>:f      r95.1<0>:f       {F@3}
        mul (1|M0)               r7.0<1>:f     r92.2<0;1,0>:f    r92.2<0;1,0>:f  
        mul (1|M0)               r1.2<1>:f     r94.2<0;1,0>:f    r94.2<0;1,0>:f  
        add (1|M0)               r5.0<1>:hf    r5.0<0;1,0>:hf    r8.0<0;1,0>:hf   {F@5}
        mov (1|M0)               r6.0<2>:hf    r5.1<0;1,0>:f                    {F@4}
        mov (1|M0)               r8.0<2>:hf    r7.0<0;1,0>:f                    {F@4}
        mov (1|M0)               r10.2<2>:hf   r1.2<0;1,0>:f                    {F@4}
        mul (1|M0)               r5.1<1>:f     r92.3<0;1,0>:f    r92.3<0;1,0>:f  
        add (1|M0)               r2.0<1>:hf    r2.0<0;1,0>:hf    r6.0<0;1,0>:hf   {F@4}
        mov (1|M0)               r9.0<1>:f     r8.0<0;1,0>:hf                   {F@4}
        mov (1|M0)               r2.1<1>:f     r10.2<0;1,0>:hf                  {F@4}
        mov (1|M0)               r6.0<2>:hf    r5.1<0;1,0>:f                    {F@4}
        mad (1|M0)               r9.0<1>:f     r9.0<0;0>:f       r93.2<0;0>:f      r93.2<0>:f       {F@3}
        mad (1|M0)               r2.1<1>:f     r2.1<0;0>:f       r95.2<0;0>:f      r95.2<0>:f       {F@3}
        mov (1|M0)               r7.0<1>:f     r6.0<0;1,0>:hf                   {F@3}
        mul (1|M0)               r8.1<1>:f     r94.3<0;1,0>:f    r94.3<0;1,0>:f  
        mul (1|M0)               r6.1<1>:f     r94.4<0;1,0>:f    r94.4<0;1,0>:f  
        mov (1|M0)               r10.0<2>:hf   r9.0<0;1,0>:f                    {F@5}
        mov (1|M0)               r4.8<2>:hf    r2.1<0;1,0>:f                    {F@5}
        mad (1|M0)               r7.0<1>:f     r7.0<0;0>:f       r93.3<0;0>:f      r93.3<0>:f       {F@5}
        mul (1|M0)               r2.1<1>:f     r92.4<0;1,0>:f    r92.4<0;1,0>:f  
        mov (1|M0)               r9.0<2>:hf    r8.1<0;1,0>:f                    {F@6}
        add (1|M0)               r10.0<1>:hf   r10.0<0;1,0>:hf   r4.8<0;1,0>:hf   {F@4}
        mov (1|M0)               r8.0<2>:hf    r7.0<0;1,0>:f                    {F@4}
        mov (1|M0)               r4.8<2>:hf    r2.1<0;1,0>:f                    {F@4}
        mov (1|M0)               r7.0<2>:hf    r6.1<0;1,0>:f                   
        mov (1|M0)               r1.2<1>:f     r9.0<0;1,0>:hf                   {F@5}
        mov (1|M0)               r5.1<1>:f     r4.8<0;1,0>:hf                   {F@3}
        mov (1|M0)               r8.1<1>:f     r7.0<0;1,0>:hf                   {F@3}
        mad (1|M0)               r1.2<1>:f     r1.2<0;0>:f       r95.3<0;0>:f      r95.3<0>:f       {F@3}
        mad (1|M0)               r5.1<1>:f     r5.1<0;0>:f       r93.4<0;0>:f      r93.4<0>:f       {F@3}
        mad (1|M0)               r8.1<1>:f     r8.1<0;0>:f       r95.4<0;0>:f      r95.4<0>:f       {F@3}
        mul (1|M0)               r4.5<1>:f     r94.5<0;1,0>:f    r94.5<0;1,0>:f  
        mov (1|M0)               r10.2<2>:hf   r1.2<0;1,0>:f                    {F@4}
        mov (1|M0)               r6.0<2>:hf    r5.1<0;1,0>:f                    {F@4}
        mov (1|M0)               r9.0<2>:hf    r8.1<0;1,0>:f                    {F@4}
        mul (1|M0)               r1.2<1>:f     r92.5<0;1,0>:f    r92.5<0;1,0>:f  
        mul (1|M0)               r8.1<1>:f     r92.6<0;1,0>:f    r92.6<0;1,0>:f  
        add (1|M0)               r8.0<1>:hf    r8.0<0;1,0>:hf    r10.2<0;1,0>:hf  {F@5}
        mov (1|M0)               r5.2<2>:hf    r4.5<0;1,0>:f                   
        add (1|M0)               r6.0<1>:hf    r6.0<0;1,0>:hf    r9.0<0;1,0>:hf   {F@5}
        mov (1|M0)               r10.2<2>:hf   r1.2<0;1,0>:f                    {F@5}
        mov (1|M0)               r9.0<2>:hf    r8.1<0;1,0>:f                    {F@5}
        mov (1|M0)               r6.1<1>:f     r5.2<0;1,0>:hf                   {F@4}
        mov (1|M0)               r2.1<1>:f     r10.2<0;1,0>:hf                  {F@3}
        mov (1|M0)               r1.2<1>:f     r9.0<0;1,0>:hf                   {F@3}
        mad (1|M0)               r6.1<1>:f     r6.1<0;0>:f       r95.5<0;0>:f      r95.5<0>:f       {F@3}
        mad (1|M0)               r2.1<1>:f     r2.1<0;0>:f       r93.5<0;0>:f      r93.5<0>:f       {F@3}
        mad (1|M0)               r1.2<1>:f     r1.2<0;0>:f       r93.6<0;0>:f      r93.6<0>:f       {F@3}
        mov (1|M0)               r7.0<2>:hf    r6.1<0;1,0>:f                    {F@3}
        mov (1|M0)               r4.8<2>:hf    r2.1<0;1,0>:f                    {F@3}
        mov (1|M0)               r10.2<2>:hf   r1.2<0;1,0>:f                    {F@3}
        mul (1|M0)               r6.1<1>:f     r92.7<0;1,0>:f    r92.7<0;1,0>:f  
        mul (1|M0)               r2.1<1>:f     r94.6<0;1,0>:f    r94.6<0;1,0>:f  
        mul (1|M0)               r1.2<1>:f     r94.7<0;1,0>:f    r94.7<0;1,0>:f  
        add (1|M0)               r4.8<1>:hf    r4.8<0;1,0>:hf    r7.0<0;1,0>:hf   {F@5}
        mov (1|M0)               r10.4<2>:hf   r2.1<0;1,0>:f                    {F@3}
        mov (1|M0)               r7.0<2>:hf    r6.1<0;1,0>:f                   
        mov (1|M0)               r9.2<2>:hf    r1.2<0;1,0>:f                    {F@4}
        mov (1|M0)               r4.5<1>:f     r10.4<0;1,0>:hf                  {F@3}
        mov (1|M0)               r8.1<1>:f     r7.0<0;1,0>:hf                   {F@3}
        mov (1|M0)               r2.1<1>:f     r9.2<0;1,0>:hf                   {F@3}
        mad (1|M0)               r4.5<1>:f     r4.5<0;0>:f       r95.6<0;0>:f      r95.6<0>:f       {F@3}
        mad (1|M0)               r8.1<1>:f     r8.1<0;0>:f       r93.7<0;0>:f      r93.7<0>:f       {F@3}
        mad (1|M0)               r2.1<1>:f     r2.1<0;0>:f       r95.7<0;0>:f      r95.7<0>:f       {F@3}
        mov (1|M0)               r5.2<2>:hf    r4.5<0;1,0>:f                    {F@3}
        mov (1|M0)               r9.0<2>:hf    r8.1<0;1,0>:f                    {F@3}
        mov (1|M0)               r10.4<2>:hf   r2.1<0;1,0>:f                    {F@3}
        add (1|M0)               r10.2<1>:hf   r10.2<0;1,0>:hf   r5.2<0;1,0>:hf   {F@3}
        add (1|M0)               r9.0<1>:hf    r9.0<0;1,0>:hf    r10.4<0;1,0>:hf  {F@2}
        add (1|M0)               r5.0<1>:hf    r5.0<0;1,0>:hf    r6.0<0;1,0>:hf  
        add (1|M0)               r2.0<1>:hf    r2.0<0;1,0>:hf    r4.8<0;1,0>:hf  
        add (1|M0)               r10.0<1>:hf   r10.0<0;1,0>:hf   r10.2<0;1,0>:hf  {F@4}
        add (1|M0)               r8.0<1>:hf    r8.0<0;1,0>:hf    r9.0<0;1,0>:hf   {F@4}
        add (1|M0)               r5.0<1>:hf    r5.0<0;1,0>:hf    r10.0<0;1,0>:hf  {F@2}
        add (1|M0)               r2.0<1>:hf    r2.0<0;1,0>:hf    r8.0<0;1,0>:hf   {F@2}
        cmp (1|M0)    (eq)f0.0   null<1>:d     r107.2<0;1,0>:d   0:w              
        add (1|M0)               r5.0<1>:hf    r5.0<0;1,0>:hf    r2.0<0;1,0>:hf   {F@1}
(W)     mov (1|M0)               r4.8<1>:uw    0x1:uw                             
        mov (1|M0)               r1.2<1>:f     r5.0<0;1,0>:hf                   {F@1}
(f0.0)  sel (1|M0)               r4.9<1>:uw    r4.8<0;1,0>:uw    0x0:uw              {I@1}
        sel (1|M0)    (ge)f0.0   r1.2<1>:f     r1.2<0;1,0>:f     6.198883e-05:f               {F@1}
(f1.0)  sel (1|M0)               r6.0<1>:uw    r4.8<0;1,0>:uw    0x0:uw             
        sync.nop                             null                             {Compacted,F@1}
        math.sqt (1|M0)          r1.2<1>:f     r1.2<0;1,0>:f                    {$8}
        and (1|M0)    (ne)f1.0   null<1>:uw    r4.9<0;1,0>:uw    r6.0<0;1,0>:uw   {I@1}
        math.inv (1|M0)          r1.2<1>:f     r1.2<0;1,0>:f                    {$8}
(W)     and (1|M0)               f0.0<1>:ud    f1.0<0;1,0>:uw    0x1:uw             
        mov (1|M0)               r7.0<2>:hf    r1.2<0;1,0>:f                    {$8.dst}
        mov (1|M0)               r108.6<1>:f   r7.0<0;1,0>:hf                   {F@1}
(f0.0.any32h) goto (32|M0)                   L8552                  L8552                
L8528:
        mov (1|M0)               r108.3<1>:f   1.0:f                               {Compacted}
        goto (32|M0)                         L8552                  L8616                
L8552:
        join (32|M0)                         L8616                                
L8568:
        send.ugm (1|M0)          r2       r96     null:0  0x0            0x04100580           {$9} // wr:2+0, rd:1; load.ugm.d32.a64
        mov (1|M0)               r1.4<2>:hf    r2.0<0;1,0>:f                    {$9.dst}
        mov (1|M0)               r108.3<1>:f   r1.4<0;1,0>:hf                   {F@1}
L8616:
        join (32|M0)                         L10040                                
L8632:
        mov (1|M0)               r108.4<2>:f   0.0:f                              
        mov (1|M0)               r108.5<2>:d   0:d                              
        mov (1|M0)               r108.2<1>:d   0:w                              
L8680:
        shl (1|M0)               r1.3<1>:w     r108.8<0;1,0>:w   2:w               {F@1}
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0xB80:uw              {A@1}
        mul (1|M0)               r2.0<1>:f     r[a0.0]<0;1,0>:f  r108.6<0;1,0>:f 
        mov (1|M0)               r4.8<2>:hf    r2.0<0;1,0>:f                    {A@1}
        mov (1|M0)               r5.0<1>:f     r4.8<0;1,0>:hf                   {F@1}
        mul (1|M0)               r5.1<1>:f     r108.3<0;1,0>:f   r5.0<0;1,0>:f    {F@1}
        mov (1|M0)               r6.0<2>:hf    r5.1<0;1,0>:f                    {F@1}
        mov (1|M0)               r4.4<1>:f     r6.0<0;1,0>:hf                   {F@1}
(~f1.0) mov (1|M0)               r4.4<1>:f     r5.0<0;1,0>:f                   
        cmp (1|M0)    (lt)f1.1   null<1>:f     r4.4<0;1,0>:f     0.0:f               {F@1}
(f1.1)  mov (1|M0)               r4.4<1>:f     -r4.4<0;1,0>:f                  
        sel (1|M0)    (lt)f0.0   r4.4<1>:f     r4.4<0;1,0>:f     448.0:f               {F@1}
        shr (1|M0)               r4.3<1>:ud    r4.4<0;1,0>:ud    0x17:uw              {F@1}
        and (1|M0)               r4.3<1>:ud    r4.3<0;1,0>:ud    0xFF:uw              {I@1}
        sel (1|M0)    (ge)f0.0   r4.3<1>:ud    r4.3<0;1,0>:ud    0x79:uw              {I@1}
        shl (1|M0)               r4.3<1>:ud    r4.3<0;1,0>:ud    0x17:uw              {I@1}
        add (1|M0)               r1.2<1>:ud    -r4.3<0;1,0>:ud   0x80800000:ud              {I@1}
        mul (1|M0)               r1.3<1>:f     r4.4<0;1,0>:f     r1.2<0;1,0>:f    {I@1}
        mov (1|M0)               r4.5<1>:d     r1.3<0;1,0>:f                    {F@1}
        mov (1|M0)               r4.2<1>:f     r4.5<0;1,0>:d                    {I@1}
        mad (1|M0)               r4.4<1>:f     -r4.2<0;0>:f      r1.2<0;0>:f       r4.4<0>:f        {F@1}
        cmp (1|M0)    (gt)f0.0   null<1>:f     r4.4<0;1,0>:f     0.5:f               {F@1}
(W)     and (1|M0)               f0.0<1>:ud    f0.0<0;1,0>:uw    0x1:uw              {F@1}
(f0.0.any32h) goto (32|M0)                   L9160                  L9160                
L9064:
        cmp (1|M0)    (lt)f0.0   null<1>:f     r4.4<0;1,0>:f     0.5:f               {A@1}
        and (1|M0)               r4.5<1>:d     r4.5<0;1,0>:d     1:w              
        add (1|M0)               r1.2<1>:f     r4.2<0;1,0>:f     1.0:f              
(~f0.0) cmp (1|M0)    (eq)f0.0   null<1>:d     r4.5<0;1,0>:d     0:w               {A@1}
(~f0.0) mov (1|M0)               r4.2<1>:f     r1.2<0;1,0>:f                    {F@1}
        goto (32|M0)                         L9160                  L9192                
L9160:
        join (32|M0)                         L9192                                
L9176:
        add (1|M0)               r4.2<1>:f     r4.2<0;1,0>:f     1.0:f               {F@1}
L9192:
        join (32|M0)                         L10040                                
L9208:
        addc (1|M0)              r5.0<1>:ud    r108.4<0;1,0>:ud  0x1:ud              {AccWrEn}
        add (1|M0)               r4.3<1>:ud    r4.3<0;1,0>:ud    0xFE800000:ud             
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mul (1|M0)               r4.2<1>:f     r4.2<0;1,0>:f     r4.3<0;1,0>:f    {A@1}
        add3 (1|M0)              r4.3<1>:d     r6.0<0;0>:d       r108.5<0;0>:d     0:w               {A@1}
(f1.1)  mov (1|M0)               r4.2<1>:f     -r4.2<0;1,0>:f                  
        cmp (1|M0)    (eq)f0.0   null<1>:d     r4.3<0;1,0>:d     0:w               {I@1}
(W)     mov (1|M0)               r2.0<2>:hf    r4.2<0;1,0>:f                    {F@1}
        mov (1|M0)               r4.2<1>:d     r5.0<0;1,0>:d                    {F@1}
        shl (1|M0)               r1.3<1>:w     r108.4<0;1,0>:w   1:w              
(f0.0)  cmp (1|M0)    (eq)f0.0   null<1>:d     r4.2<0;1,0>:d     32:w               {I@2}
        add (1|M0)               r108.2<1>:d   r108.2<0;1,0>:d   1:w              
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0xC20:uw              {A@1}
        mov (1|M0)               r[a0.0]<1>:hf  r2.0<0;1,0>:hf                 
(W)     and (1|M0)               f0.0<1>:ud    f0.0<0;1,0>:uw    0x1:uw             
(~f0.0.any32h) goto (32|M0)                  L9992                  L9992                
L9456:
        mov (2|M0)               r1.2<1>:d     r4.0<1;1,0>:d                   
(f1.0)  sel (1|M0)               r1.2<1>:d     r3.6<0;1,0>:d     r4.0<0;1,0>:d   
(f1.0)  mov (1|M0)               r1.3<1>:d     r3.7<0;1,0>:d                   
        addc (1|M0)              r2.0<1>:ud    r1.2<0;1,0>:ud    r96.6<0;1,0>:ud  {AccWrEn,A@1}
        mov (8|M0)               r14.0<1>:d    r105.1<2;1,0>:d                 
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r1.4<1>:d     r2.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r1.5<1>:d     r5.0<0;0>:d       r1.3<0;0>:d       r96.7<0>:d       {I@2}
        mov (8|M0)               r6.0<2>:ud    r1.4<0;1,0>:ud                   {I@2}
        mov (8|M0)               r6.1<2>:ud    r1.5<0;1,0>:ud                   {I@2}
        mov (8|M0)               r5.0<1>:d     r103.1<2;1,0>:d                 
        addc (8|M0)              r8.0<1>:ud    r6.0<2;1,0>:ud    r105.0<2;1,0>:ud {AccWrEn,Compacted,I@2}
        mov (16|M0)              r25.0<1>:d    r98.0<1;1,0>:uw                  {$4.src}
        mov (8|M0)               r9.0<1>:ud    acc0.0<1;1,0>:ud                 {Compacted}
        addc (8|M0)              r16.0<1>:ud   r6.0<2;1,0>:ud    r103.0<2;1,0>:ud {AccWrEn,Compacted}
        add3 (8|M0)              r15.0<1>:d    r9.0<1;0>:d       r6.1<4;2>:d       r14.0<1>:d       {I@2}
        mov (8|M0)               r17.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted,$15.src}
        addc (8|M0)              r19.0<1>:ud   r6.0<2;1,0>:ud    r101.0<2;1,0>:ud {AccWrEn,Compacted}
        mov (8|M0)               r10.0<2>:d    r8.0<1;1,0>:d                    {$0.src}
        mov (8|M0)               r20.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        addc (8|M0)              r14.0<1>:ud   r6.0<2;1,0>:ud    r99.0<2;1,0>:ud  {AccWrEn,Compacted}
        add3 (8|M0)              r18.0<1>:d    r17.0<1;0>:d      r6.1<4;2>:d       r5.0<1>:d        {I@5}
        mov (8|M0)               r10.1<2>:d    r15.0<1;1,0>:d                  
        mov (8|M0)               r8.0<1>:d     r101.1<2;1,0>:d                 
        mov (8|M0)               r5.0<1>:d     r99.1<2;1,0>:d                  
        mov (8|M0)               r15.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mov (8|M0)               r12.0<2>:d    r16.0<1;1,0>:d                  
        add3 (8|M0)              r9.0<1>:d     r20.0<1;0>:d      r6.1<4;2>:d       r8.0<1>:d        {I@4}
        add3 (8|M0)              r16.0<1>:d    r15.0<1;0>:d      r6.1<4;2>:d       r5.0<1>:d        {I@3}
        mov (8|M0)               r21.0<2>:d    r19.0<1;1,0>:d                  
        mov (8|M0)               r23.0<2>:d    r14.0<1;1,0>:d                  
        mov (8|M0)               r12.1<2>:d    r18.0<1;1,0>:d                  
        mov (8|M0)               r21.1<2>:d    r9.0<1;1,0>:d                    {I@5}
        mov (8|M0)               r23.1<2>:d    r16.0<1;1,0>:d                   {I@5}
        mov (16|M0)              r17.0<1>:d    r97.0<1;1,0>:uw                 
        send.ugm (16|M0)         null     r10     r17:2   0x0            0x08000B84           {A@1,$15} // wr:4+2, rd:0; store.ugm.d16u32.a64
        send.ugm (16|M0)         null     r21     r25:2   0x0            0x08000B84           {$4} // wr:4+2, rd:0; store.ugm.d16u32.a64
        goto (32|M0)                         L9992                  L11280                
L9992:
        join (32|M0)                         L10040                                
L10008:
(W)     mov (2|M0)               r108.4<1>:ud  r4.2<1;1,0>:ud                  
        goto.b (32|M0)                       L10040                  L8680                
L10040:
        join (32|M0)                         L11280                                
L10056:
        mov (1|M0)               r108.4<2>:f   0.0:f                               {I@3}
        mov (1|M0)               r108.5<2>:d   0:d                              
        mov (1|M0)               r108.2<1>:d   0:w                              
L10104:
        shl (1|M0)               r1.3<1>:w     r108.8<0;1,0>:w   2:w               {F@1}
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0xB80:uw              {A@1}
        cmp (1|M0)    (lt)f1.0   null<1>:f     r[a0.0]<0;1,0>:f  0.0:f              
(W)     mov (1|M0)               r2.0<1>:f     -r[a0.0]<0;1,0>:f                {A@1}
(W)     mov (1|M0)               r2.1<1>:f     r[a0.0]<0;1,0>:f                 {A@1}
(f1.0)  sel (1|M0)               r108.7<1>:f   r2.0<0;1,0>:f     r2.1<0;1,0>:f    {A@1}
        sel (1|M0)    (lt)f0.0   r108.7<1>:f   r108.7<0;1,0>:f   448.0:f               {F@1}
        shr (1|M0)               r108.6<1>:ud  r108.7<0;1,0>:ud  0x17:uw              {F@1}
        and (1|M0)               r108.6<1>:ud  r108.6<0;1,0>:ud  0xFF:uw              {I@1}
        sel (1|M0)    (ge)f0.0   r108.6<1>:ud  r108.6<0;1,0>:ud  0x79:uw              {I@1}
        shl (1|M0)               r108.6<1>:ud  r108.6<0;1,0>:ud  0x17:uw              {I@1}
        add (1|M0)               r4.4<1>:ud    -r108.6<0;1,0>:ud  0x80800000:ud             {I@1}
        mul (1|M0)               r4.5<1>:f     r108.7<0;1,0>:f   r4.4<0;1,0>:f    {I@1}
        mov (1|M0)               r2.0<1>:d     r4.5<0;1,0>:f                    {Compacted,F@1}
        mov (1|M0)               r108.3<1>:f   r2.0<0;1,0>:d                    {Compacted,I@1}
        mad (1|M0)               r108.7<1>:f   -r108.3<0;0>:f    r4.4<0;0>:f       r108.7<0>:f      {F@1}
        cmp (1|M0)    (gt)f0.0   null<1>:f     r108.7<0;1,0>:f   0.5:f               {F@1}
(W)     and (1|M0)               f0.0<1>:ud    f0.0<0;1,0>:uw    0x1:uw              {F@1}
(f0.0.any32h) goto (32|M0)                   L10480                  L10480                
L10392:
        cmp (1|M0)    (lt)f0.0   null<1>:f     r108.7<0;1,0>:f   0.5:f               {A@1}
        and (1|M0)               r2.0<1>:d     r2.0<0;1,0>:d     1:w               {Compacted}
        add (1|M0)               r1.2<1>:f     r108.3<0;1,0>:f   1.0:f              
(~f0.0) cmp (1|M0)    (eq)f0.0   null<1>:d     r2.0<0;1,0>:d     0:w               {A@1}
(~f0.0) mov (1|M0)               r108.3<1>:f   r1.2<0;1,0>:f                    {F@1}
        goto (32|M0)                         L10480                  L10504                
L10480:
        join (32|M0)                         L10504                                
L10496:
        add (1|M0)               r108.3<1>:f   r108.3<0;1,0>:f   1.0:f               {Compacted,F@1}
L10504:
        join (32|M0)                         L11280                                
L10520:
        addc (1|M0)              r5.0<1>:ud    r108.4<0;1,0>:ud  0x1:ud              {AccWrEn}
        add (1|M0)               r108.6<1>:ud  r108.6<0;1,0>:ud  0xFE800000:ud             
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r4.2<1>:d     r5.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r4.3<1>:d     r6.0<0;0>:d       r108.5<0;0>:d     0:w               {I@2}
        mul (1|M0)               r108.3<1>:f   r108.3<0;1,0>:f   r108.6<0;1,0>:f  {F@1}
        cmp (1|M0)    (eq)f0.0   null<1>:d     r4.3<0;1,0>:d     0:w               {I@1}
(f1.0)  mov (1|M0)               r108.3<1>:f   -r108.3<0;1,0>:f                 {F@1}
        shl (1|M0)               r1.3<1>:w     r108.4<0;1,0>:w   1:w              
(W)     mov (1|M0)               r2.0<2>:hf    r108.3<0;1,0>:f                  {F@1}
(f0.0)  cmp (1|M0)    (eq)f0.0   null<1>:d     r4.2<0;1,0>:d     32:w              
        add (1|M0)               r108.2<1>:d   r108.2<0;1,0>:d   1:w              
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0xC20:uw              {A@1}
        mov (1|M0)               r[a0.0]<1>:hf  r2.0<0;1,0>:hf                  {F@1}
(W)     and (1|M0)               f0.0<1>:ud    f0.0<0;1,0>:uw    0x1:uw             
(~f0.0.any32h) goto (32|M0)                  L11232                  L11232                
L10768:
        mov (8|M0)               r5.0<2>:ud    r96.4<0;1,0>:ud                 
        mov (8|M0)               r5.1<2>:ud    r96.5<0;1,0>:ud                 
        mov (8|M0)               r13.0<1>:d    r105.1<2;1,0>:d                  {$15.src}
        addc (8|M0)              r7.0<1>:ud    r5.0<2;1,0>:ud    r105.0<2;1,0>:ud {AccWrEn,Compacted,I@2}
        sync.nop                             null                             {Compacted,$3.src}
        mov (8|M0)               r17.0<1>:d    r103.1<2;1,0>:d                  {$1.src}
        mov (8|M0)               r8.0<1>:ud    acc0.0<1;1,0>:ud                 {Compacted}
        addc (8|M0)              r15.0<1>:ud   r5.0<2;1,0>:ud    r103.0<2;1,0>:ud {AccWrEn,Compacted}
        add3 (8|M0)              r14.0<1>:d    r8.0<1;0>:d       r5.1<4;2>:d       r13.0<1>:d       {I@2}
        mov (8|M0)               r16.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        addc (8|M0)              r19.0<1>:ud   r5.0<2;1,0>:ud    r101.0<2;1,0>:ud {AccWrEn,Compacted}
        mov (8|M0)               r9.0<2>:d     r7.0<1;1,0>:d                   
        mov (8|M0)               r20.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        addc (8|M0)              r13.0<1>:ud   r5.0<2;1,0>:ud    r99.0<2;1,0>:ud  {AccWrEn,Compacted}
        sync.nop                             null                             {Compacted,$0.src}
        mov (8|M0)               r11.0<2>:d    r15.0<1;1,0>:d                   {I@7}
        mov (8|M0)               r9.1<2>:d     r14.0<1;1,0>:d                   {I@7}
        mov (8|M0)               r7.0<1>:d     r101.1<2;1,0>:d                 
        mov (8|M0)               r15.0<1>:d    r99.1<2;1,0>:d                  
        mov (8|M0)               r14.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        add3 (8|M0)              r18.0<1>:d    r16.0<1;0>:d      r5.1<4;2>:d       r17.0<1>:d       {I@7}
        add3 (8|M0)              r8.0<1>:d     r20.0<1;0>:d      r5.1<4;2>:d       r7.0<1>:d        {I@4}
        add3 (8|M0)              r16.0<1>:d    r14.0<1;0>:d      r5.1<4;2>:d       r15.0<1>:d       {I@3}
        sync.allrd                           ($2,$4)                
        mov (16|M0)              r25.0<1>:d    r98.0<1;1,0>:uw                  {F@1}
        mov (8|M0)               r21.0<2>:d    r19.0<1;1,0>:d                  
        mov (8|M0)               r23.0<2>:d    r13.0<1;1,0>:d                  
        mov (8|M0)               r11.1<2>:d    r18.0<1;1,0>:d                   {I@6}
        mov (8|M0)               r21.1<2>:d    r8.0<1;1,0>:d                    {I@6}
        mov (8|M0)               r23.1<2>:d    r16.0<1;1,0>:d                   {I@6}
        mov (16|M0)              r17.0<1>:d    r97.0<1;1,0>:uw                 
        send.ugm (16|M0)         null     r9      r17:2   0x0            0x08000B84           {A@1,$3} // wr:4+2, rd:0; store.ugm.d16u32.a64
        send.ugm (16|M0)         null     r21     r25:2   0x0            0x08000B84           {$2} // wr:4+2, rd:0; store.ugm.d16u32.a64
        goto (32|M0)                         L11232                  L11280                
L11232:
        join (32|M0)                         L11280                                
L11248:
(W)     mov (2|M0)               r108.4<1>:ud  r4.2<1;1,0>:ud                  
        goto.b (32|M0)                       L11280                  L10104                
L11280:
        join (32|M0)                         L11544                                
L11296:
        sync.nop                             null                             {Compacted,$13.src}
(W)     send.slm (1|M0)          r5       r0      null:0  0x0            0x0210001F           {$10} // wr:1+0, rd:1; fence.slm.none.group
(W)     mov (1|M0)               r6.2<1>:f     0.0:f                               {Compacted,$14.src}
(W)     mov (2|M0)               r6.10<1>:ub   r0.11<0;1,0>:ub                  {F@1}
(W)     mov (8|M0)               null<1>:ud    r5.0<1;1,0>:ud                   {$10.dst}
(W)     send.gtwy (1|M0)         null     r6      null:0  0x0            0x02000004           {A@2,$5} // wr:1+0, rd:0; signal barrier
(W)     sync.bar                             null                            
        addc (1|M0)              r2.0<1>:ud    r107.2<0;1,0>:ud  0x1:ud              {AccWrEn,$12.src}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r4.2<1>:d     r2.0<0;1,0>:d                    {I@2}
        add3 (1|M0)              r4.3<1>:d     r7.0<0;0>:d       r107.3<0;0>:d     0:w               {I@2}
        cmp (1|M0)    (eq)f0.0   null<1>:d     r4.3<0;1,0>:d     0:w               {I@1}
(f0.0)  cmp (1|M0)    (eq)f0.0   null<1>:d     r4.2<0;1,0>:d     3:w              
(W)     and (1|M0)               f0.0<1>:ud    f0.0<0;1,0>:uw    0x1:uw             
(f0.0.any32h) goto (32|M0)                   L11544                  L11544                
L11512:
(W)     mov (2|M0)               r107.2<1>:ud  r4.2<1;1,0>:ud                  
        goto.b (32|M0)                       L11544                  L4088                
L11544:
        join (32|M0)                         L11560                                
L11560:
(W)     mov (8|M0)               r127.0<1>:f   r0.0<1;1,0>:f                    {Compacted}
        sync.nop                             null                             {Compacted,$13.src}
(W)     send.ugm (1|M0)          r5       r0      null:0  0x0            0x0210641F           {$11} // wr:1+0, rd:1; fence invalid flush type scoped to tile
(W)     mov (8|M0)               null<1>:ud    r5.0<1;1,0>:ud                   {$11.dst}
(W)     send.gtwy (1|M0)         null     r127    null:0  0x0            0x02000010           {EOT,A@1} // wr:1+0, rd:0; end of thread
L11624:
        mov (1|M0)               r1.2<1>:d     cr0.0<0;1,0>:ud                  {A@1}
        and (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   -1265:w               {A@1}
        or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   1264:w               {A@1}
        mov (1|M0)               r1.3<1>:f     r96.6<0;1,0>:ud                  {A@1}
        mov (1|M0)               r4.4<1>:f     0xB4C00000:f                               {Compacted}
        math.inv (1|M0)          r2.1<1>:f     r1.3<0;1,0>:f                    {@2,$12}
        mov (1|M0)               r1.5<1>:f     r96.5<0;1,0>:ud                 
        sync.nop                             null                             {Compacted,$12.dst}
        mad (1|M0)               r2.1<1>:f     r2.1<0;0>:f       r4.4<0;0>:f       r2.1<0>:f        {F@2}
        mov (1|M0)               r96.4<1>:ud   r1.3<0;1,0>:f                   
        mov (1|M0)               r1.6<1>:ud    r1.5<0;1,0>:f                    {F@2}
        mul (1|M0)               r5.0<1>:f     r2.1<0;1,0>:f     r1.5<0;1,0>:f    {A@1}
        add (1|M0)               r96.4<1>:ud   r96.6<0;1,0>:ud   -r96.4<0;1,0>:ud {I@2}
        add (1|M0)               r1.6<1>:ud    r96.5<0;1,0>:ud   -r1.6<0;1,0>:ud  {I@2}
        mov (1|M0)               r6.0<1>:ud    r5.0<0;1,0>:f                    {F@1}
        mov (1|M0)               r1.4<1>:f     r96.4<0;1,0>:ud                  {I@3}
        mov (1|M0)               r2.0<1>:f     r1.6<0;1,0>:ud                   {Compacted,I@2}
        mov (1|M0)               r6.1<1>:f     r6.0<0;1,0>:ud                   {Compacted,I@1}
(W)     mov (1|M0)               r4.8<1>:hf    0x1:hf                             
        mad (1|M0)               r1.5<1>:f     r1.5<0;0>:f       r6.1<0;0>:f       -r1.3<0>:f       {F@2}
        mad (1|M0)               r6.1<1>:f     r2.0<0;0>:f       r6.1<0;0>:f       -r1.4<0>:f      
        add (1|M0)               r1.5<1>:f     r1.5<0;1,0>:f     r6.1<0;1,0>:f    {F@1}
        mul (1|M0)               r2.1<1>:f     r2.1<0;1,0>:f     r1.5<0;1,0>:f    {F@1}
        mov (1|M0)               r7.0<1>:ud    r2.1<0;1,0>:f                    {F@1}
        add (1|M0)               r6.0<1>:ud    r6.0<0;1,0>:ud    r7.0<0;1,0>:ud   {Compacted,I@1}
(W)     mul (1|M0)               acc0.0<1>:ud  r6.0<0;1,0>:ud    r96.12<0;1,0>:uw {I@1}
        mach (1|M0)              r8.0<1>:ud    r6.0<0;1,0>:ud    r96.6<0;1,0>:ud  {Compacted}
        add (1|M0)               r96.5<1>:ud   r96.5<0;1,0>:ud   -r8.0<0;1,0>:ud  {I@1}
        cmp (1|M0)    (ge)f0.0   null<1>:ud    r96.5<0;1,0>:ud   r96.6<0;1,0>:ud  {I@1}
(f0.0)  sel (1|M0)               r5.0<1>:d     r4.8<0;1,0>:w     0:w              
        add (1|M0)               r5.0<1>:ud    r6.0<0;1,0>:ud    r5.0<0;1,0>:ud   {Compacted,I@1}
        mov (1|M0)               cr0.0<1>:ud   r1.2<0;1,0>:d                    {A@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        ret (32|M0)                          r96.2                            {A@1}
L12128:
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
