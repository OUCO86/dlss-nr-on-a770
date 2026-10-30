L0:
(W)     mov (8|M0)               r127.0<1>:ud  0x0:ud                              {A@1}
(W)     and (1|M0)               r127.2<1>:ud  r0.0<0;1,0>:ud    0xFFFFFFC0:ud             
(W)     and (1|M0)               r127.0<1>:uw  r0.4<0;1,0>:uw    0xFF:uw             
(W)     add (1|M0)               r127.2<1>:ud  r127.2<0;1,0>:ud  0x80:ud              {I@2}
(W)     mad (1|M0)               r127.2<1>:ud  r127.2<0;0>:ud    r127.0<0;0>:uw    0x20:uw              {I@1}
(W)     send.dc0 (8|M0)          r1       r127    null:0  0x0            0x021842FD           {A@1,$0} // wr:1h+0, rd:1; oword aligned block read x2
        nop                    
        nop                    
(W)     mov (8|M0)               r127.0<1>:ud  0x0:ud                              {$0.src}
(W)     and (1|M0)               r127.2<1>:ud  r0.0<0;1,0>:ud    0xFFFFFFC0:ud             
(W)     send.dc0 (8|M0)          r2       r127    null:0  0x0            0x024844FD           {A@1,$1} // wr:1h+0, rd:4; oword aligned block read x8
(W)     and (1|M0)               r1.2<1>:ud    r0.5<0;1,0>:ud    0xFFFFFC00:ud              {$0.dst}
(W)     mov (2|M0)               r34.0<1>:ud   r3.4<1;1,0>:ud                   {$1.dst}
(W)     mov (2|M0)               r2.0<1>:ud    r4.4<1;1,0>:ud                  
        and (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   -1265:w               {A@1}
        or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   1216:w               {A@1}
        mov (1|M0)               r5.6<1>:d     r0.1<0;1,0>:ud                   {A@1}
        mov (1|M0)               r1.6<1>:d     r1.0<0;1,0>:uw                  
        mov (1|M0)               r5.7<1>:d     r2.2<0;1,0>:d                   
        mov (1|M0)               r6.5<1>:d     r5.6<0;1,0>:d                    {I@3}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (32|M0)             r1.4          L36264                                 {A@1}
L368:
(W)     mov (1|M0)               r6.0<1>:d     r1.3<0;1,0>:d                   
        shl (1|M0)               r1.4<1>:d     r1.3<0;1,0>:d     3:w              
(W)     mul (1|M0)               acc0.0<1>:d   r6.0<0;1,0>:d     r2.4<0;1,0>:uw   {Compacted,I@2}
(W)     mov (1|M0)               r6.0<1>:d     r1.3<0;1,0>:d                   
        cmp (1|M0)    (lt)f0.0   null<1>:uw    r1.0<0;1,0>:uw    0x2:uw             
        mach (1|M0)              r6.0<1>:d     r6.0<0;1,0>:d     r2.2<0;1,0>:d    {Compacted,I@2}
        shr (1|M0)               r5.7<1>:ud    r1.6<0;1,0>:ud    0x2:uw             
(W)     mov (1|M0)               r1.3<1>:d     r6.0<0;1,0>:d                    {I@2}
        shl (1|M0)               r1.5<1>:d     r1.6<0;1,0>:d     6:w              
        add (1|M0)               r1.3<1>:d     r5.6<0;1,0>:d     -r1.3<0;1,0>:d   {I@2}
        shl (1|M0)               r1.7<1>:d     r1.6<0;1,0>:d     8:w              
        shl (1|M0)               r1.3<1>:d     r1.3<0;1,0>:d     3:w               {Compacted,I@2}
(W)     mov (1|M0)               r2.15<1>:hf   0.0:hf                             
        shl (1|M0)               r34.2<1>:ud   r5.7<0;1,0>:ud    0x7:uw             
        add (1|M0)               r1.3<1>:d     r1.3<0;1,0>:d     -r2.4<0;1,0>:d   {I@2}
        mov (1|M0)               r34.4<2>:f    0.0:f                              
        mov (1|M0)               r34.5<2>:f    0.0:f                              
        add (1|M0)               r1.4<1>:d     r1.4<0;1,0>:d     -r2.3<0;1,0>:d  
        or (1|M0)                r71.0<1>:d    r1.5<0;1,0>:d     31232:w              
        or (1|M0)                r76.0<1>:d    r1.7<0;1,0>:d     31232:w              
        or (1|M0)                r75.0<1>:d    r1.7<0;1,0>:d     31296:w              
        or (1|M0)                r74.0<1>:d    r1.7<0;1,0>:d     31360:w              
        or (1|M0)                r73.0<1>:d    r1.7<0;1,0>:d     31424:w              
(f0.0)  sel (1|M0)               r1.3<1>:w     r2.15<0;1,0>:w    32:w               {F@3}
        shl (1|M0)               r5.7<1>:ud    r5.7<0;1,0>:ud    0x6:uw             
        add (1|M0)               r34.2<1>:ud   r34.2<0;1,0>:ud   0x7200:uw              {I@7}
        add (1|M0)               r2.4<1>:d     r1.3<0;1,0>:d     r1.0<0;1,0>:uw   {I@7}
        add (1|M0)               r2.2<1>:d     r1.3<0;1,0>:d     r1.0<0;1,0>:uw  
        mov (1|M0)               r2.3<1>:d     0:w                              
        shl (1|M0)               r1.5<1>:d     r1.6<0;1,0>:d     7:w              
L824:
        cmp (1|M0)    (lt)f0.0   null<1>:uw    r1.0<0;1,0>:uw    0x8:uw             
        add (1|M0)               r34.3<1>:d    r1.4<0;1,0>:d     r34.4<0;1,0>:d   {F@2}
(W)     and (1|M0)               f0.0<1>:ud    f0.0<0;1,0>:uw    0x1:uw             
(~f0.0.any32h) goto (32|M0)                  L2480                  L2480                
L888:
        cmp (1|M0)    (lt)f0.0   null<1>:d     r34.3<0;1,0>:d    r2.5<0;1,0>:d    {I@3}
(f0.0)  cmp (1|M0)    (gt)f0.0   null<1>:d     r34.3<0;1,0>:d    -1:w              
(f0.0)  cmp (1|M0)    (gt)f0.0   null<1>:d     r2.4<0;1,0>:d     -1:w              
(f0.0)  cmp (1|M0)    (lt)f0.0   null<1>:d     r2.4<0;1,0>:d     r2.6<0;1,0>:d   
(W)     and (1|M0)               f0.0<1>:ud    f0.0<0;1,0>:uw    0x1:uw             
(f0.0.any32h) goto (32|M0)                   L1016                  L1016                
L984:
        mov (32|M0)              r53.0<1>:uw   0x0:uw                             
        goto (32|M0)                         L1016                  L2440                
L1016:
        join (32|M0)                         L2440                                
L1032:
        mul (1|M0)               acc0.0<1>:ud  r34.3<0;1,0>:ud   r2.12<0;1,0>:uw 
        mach (1|M0)              r8.0<1>:ud    r34.3<0;1,0>:ud   r2.6<0;1,0>:ud   {AccWrEn}
        mov (1|M0)               r34.6<2>:f    0.0:f                              
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r6.6<1>:d     0:w                              
        addc (1|M0)              r9.0<1>:ud    r7.0<0;1,0>:ud    r2.2<0;1,0>:ud   {AccWrEn,I@2}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        shr (1|M0)               r6.2<1>:ud    r9.0<0;1,0>:ud    0x1B:uw              {I@2}
        add3 (1|M0)              r34.7<1>:d    r6.0<0;0>:d       r8.0<0;0>:d       r2.3<0>:d        {I@2}
        shl (1|M0)               r6.0<1>:d     r9.0<0;1,0>:d     5:w               {Compacted}
        shl (1|M0)               r6.3<1>:d     r34.7<0;1,0>:d    5:w               {I@2}
        shl (1|M0)               r6.4<1>:d     r6.0<0;1,0>:d     1:w               {Compacted,I@2}
        or (1|M0)                r6.1<1>:d     r6.3<0;1,0>:d     r6.2<0;1,0>:d    {I@2}
        shr (1|M0)               r6.2<1>:ud    r6.0<0;1,0>:ud    0x1F:uw             
        addc (1|M0)              r8.0<1>:ud    r3.0<0;1,0>:ud    r6.4<0;1,0>:ud   {AccWrEn,I@3}
        shl (1|M0)               r6.3<1>:d     r6.1<0;1,0>:d     1:w               {I@3}
        shr (1|M0)               r6.4<1>:ud    r6.0<0;1,0>:ud    0x1E:uw             
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        or (1|M0)                r6.5<1>:d     r6.3<0;1,0>:d     r6.2<0;1,0>:d    {I@3}
        shl (1|M0)               r6.0<1>:d     r6.0<0;1,0>:d     2:w               {Compacted}
        mov (1|M0)               r6.2<1>:d     r8.0<0;1,0>:d                   
        add3 (1|M0)              r6.3<1>:d     r7.0<0;0>:d       r3.1<0;0>:d       r6.5<0>:d        {I@3}
        addc (1|M0)              r8.0<1>:ud    r3.0<0;1,0>:ud    r6.0<0;1,0>:ud   {AccWrEn,I@3}
        shl (1|M0)               r6.5<1>:d     r6.1<0;1,0>:d     2:w              
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        or (1|M0)                r6.1<1>:d     r6.5<0;1,0>:d     r6.4<0;1,0>:d    {I@2}
        mov (1|M0)               r34.7<2>:f    0.0:f                              
        mov (1|M0)               r6.4<1>:d     r8.0<0;1,0>:d                   
        add3 (1|M0)              r6.5<1>:d     r7.0<0;0>:d       r3.1<0;0>:d       r6.1<0>:d        {I@2}
L1440:
        and (1|M0)               r2.30<2>:b    r2.28<0;1,0>:b    1:w              
        cmp (1|M0)    (eq)f0.0   null<1>:w     r2.30<0;1,0>:b    0:w               {I@1}
(W)     and (1|M0)               f0.0<1>:ud    f0.0<0;1,0>:uw    0x1:uw             
(f0.0.any32h) goto (32|M0)                   L1656                  L1656                
L1504:
        shl (1|M0)               r6.1<1>:d     r34.7<0;1,0>:d    1:w               {F@1}
        shr (1|M0)               r6.0<1>:ud    r34.6<0;1,0>:ud   0x1F:uw             
        shl (1|M0)               r71.1<1>:d    r34.6<0;1,0>:d    1:w              
        or (1|M0)                r71.2<1>:d    r6.1<0;1,0>:d     r6.0<0;1,0>:d    {I@2}
        addc (1|M0)              r6.0<1>:ud    r6.2<0;1,0>:ud    r71.1<0;1,0>:ud  {AccWrEn,I@2}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        add3 (1|M0)              r6.1<1>:d     r7.0<0;0>:d       r6.3<0;0>:d       r71.2<0>:d       {I@1}
        send.ugm (1|M0)          r6       r6      null:0  0x0            0x04100B80           {A@1,$3} // wr:2+0, rd:1; load.ugm.d16u32.a64
        mov (1|M0)               r7.0<1>:f     r6.0<0;1,0>:hf                   {$3.dst}
        goto (32|M0)                         L1656                  L1792                
L1656:
        join (32|M0)                         L1792                                
L1672:
        shl (1|M0)               r6.1<1>:d     r34.7<0;1,0>:d    2:w              
        shr (1|M0)               r6.0<1>:ud    r34.6<0;1,0>:ud   0x1E:uw              {F@1}
        shl (1|M0)               r71.1<1>:d    r34.6<0;1,0>:d    2:w              
        or (1|M0)                r71.2<1>:d    r6.1<0;1,0>:d     r6.0<0;1,0>:d    {I@2}
        addc (1|M0)              r6.0<1>:ud    r6.4<0;1,0>:ud    r71.1<0;1,0>:ud  {AccWrEn,I@2}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        add3 (1|M0)              r6.1<1>:d     r7.0<0;0>:d       r6.5<0;0>:d       r71.2<0>:d       {I@1}
        send.ugm (1|M0)          r7       r6      null:0  0x0            0x04100580           {A@1,$4} // wr:2+0, rd:1; load.ugm.d32.a64
L1792:
        join (32|M0)                         L2440                                
L1808:
        cmp (1|M0)    (lt)f1.0   null<1>:f     r7.0<0;1,0>:f     0.0:f               {$4.dst}
(f1.0)  mov (1|M0)               r7.0<1>:f     -r7.0<0;1,0>:f                  
        sel (1|M0)    (lt)f0.0   r7.0<1>:f     r7.0<0;1,0>:f     448.0:f               {F@1}
        shr (1|M0)               r6.1<1>:ud    r7.0<0;1,0>:ud    0x17:uw              {F@1}
        and (1|M0)               r6.1<1>:ud    r6.1<0;1,0>:ud    0xFF:uw              {I@1}
        sel (1|M0)    (ge)f0.0   r6.1<1>:ud    r6.1<0;1,0>:ud    0x79:uw              {I@1}
        shl (1|M0)               r6.1<1>:ud    r6.1<0;1,0>:ud    0x17:uw              {I@1}
        add (1|M0)               r7.1<1>:ud    -r6.1<0;1,0>:ud   0x80800000:ud              {I@1}
        mul (1|M0)               r34.3<1>:f    r7.0<0;1,0>:f     r7.1<0;1,0>:f    {I@1}
        mov (1|M0)               r6.7<1>:d     r34.3<0;1,0>:f                   {F@1}
        mov (1|M0)               r6.0<1>:f     r6.7<0;1,0>:d                    {Compacted,I@1}
        mad (1|M0)               r7.0<1>:f     -r6.0<0;0>:f      r7.1<0;0>:f       r7.0<0>:f        {F@1}
        cmp (1|M0)    (gt)f0.0   null<1>:f     r7.0<0;1,0>:f     0.5:f               {F@1}
(W)     and (1|M0)               f0.0<1>:ud    f0.0<0;1,0>:uw    0x1:uw              {F@1}
(f0.0.any32h) goto (32|M0)                   L2128                  L2128                
L2040:
        cmp (1|M0)    (lt)f0.0   null<1>:f     r7.0<0;1,0>:f     0.5:f               {A@1}
        and (1|M0)               r6.7<1>:d     r6.7<0;1,0>:d     1:w              
        add (1|M0)               r7.1<1>:f     r6.0<0;1,0>:f     1.0:f               {Compacted}
(~f0.0) cmp (1|M0)    (eq)f0.0   null<1>:d     r6.7<0;1,0>:d     0:w               {A@1}
(~f0.0) mov (1|M0)               r6.0<1>:f     r7.1<0;1,0>:f                    {F@1}
        goto (32|M0)                         L2128                  L2152                
L2128:
        join (32|M0)                         L2152                                
L2144:
        add (1|M0)               r6.0<1>:f     r6.0<0;1,0>:f     1.0:f               {Compacted,F@1}
L2152:
        join (32|M0)                         L2440                                
L2168:
        add (1|M0)               r6.1<1>:ud    r6.1<0;1,0>:ud    0xFE800000:ud             
        addc (1|M0)              r7.0<1>:ud    r34.6<0;1,0>:ud   0x1:ud              {AccWrEn}
        mul (1|M0)               r6.0<1>:f     r6.0<0;1,0>:f     r6.1<0;1,0>:f    {Compacted,A@1}
        mov (1|M0)               r71.2<1>:d    r7.0<0;1,0>:d                    {I@1}
(f1.0)  mov (1|M0)               r6.0<1>:f     -r6.0<0;1,0>:f                   {F@1}
        shl (1|M0)               r2.15<1>:w    r6.12<0;1,0>:w    1:w              
(W)     mov (1|M0)               r34.6<2>:hf   r6.0<0;1,0>:f                    {F@1}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,F@1}
        add (1|M0)               r6.6<1>:d     r6.6<0;1,0>:d     1:w              
        add3 (1|M0)              r71.3<1>:d    r6.0<0;0>:d       r34.7<0;0>:d      0:w               {I@2}
        add (1|M0)               a0.0<1>:uw    r2.15<0;1,0>:uw   0x6A0:uw              {A@1}
        cmp (1|M0)    (eq)f0.0   null<1>:d     r71.3<0;1,0>:d    0:w               {I@2}
        mov (1|M0)               r[a0.0]<1>:hf  r34.6<0;1,0>:hf                
(f0.0)  cmp (1|M0)    (eq)f0.0   null<1>:d     r71.2<0;1,0>:d    32:w              
(W)     and (1|M0)               f0.0<1>:ud    f0.0<0;1,0>:uw    0x1:uw             
(f0.0.any32h) goto (32|M0)                   L2440                  L2440                
L2408:
(W)     mov (2|M0)               r34.6<1>:ud   r71.2<1;1,0>:ud                 
        goto.b (32|M0)                       L2440                  L1440                
L2440:
        join (32|M0)                         L2480                                
L2456:
        sync.nop                             null                             {Compacted,F@1}
        send.slm (1|M0)          null     r71     r53:2   0x0            0x0200C704           {$5} // wr:1+2, rd:0; store.slm.d64x8t.a32
L2480:
        join (32|M0)                         L9464                                
L2496:
        sync.nop                             null                             {Compacted,$4.src}
(W)     send.slm (1|M0)          r6       r0      null:0  0x0            0x0210001F           {$6} // wr:1+0, rd:1; fence.slm.none.group
(W)     mov (8|M0)               null<1>:ud    r6.0<1;1,0>:ud                   {$6.dst}
(W)     mov (1|M0)               r6.2<1>:f     0.0:f                               {Compacted,I@1}
(W)     mov (2|M0)               r6.10<1>:ub   r0.11<0;1,0>:ub                  {F@1}
(W)     send.gtwy (1|M0)         null     r6      null:0  0x0            0x02000004           {A@1,$7} // wr:1+0, rd:0; signal barrier
(W)     sync.bar                             null                            
        cmp (1|M0)    (lt)f0.0   null<1>:uw    r1.0<0;1,0>:uw    0x4:uw             
(W)     and (1|M0)               f0.0<1>:ud    f0.0<0;1,0>:uw    0x1:uw             
(~f0.0.any32h) goto (32|M0)                  L2944                  L2944                
L2640:
        send.slm (1|M0)          r10      r76     null:0  0x0            0x0220C700           {$8} // wr:1+0, rd:2; load.slm.d64x8t.a32
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0x140:uw              {A@1}
        sync.nop                             null                             {Compacted,$8.dst}
        mov (8|M0)               r6.0<1>:uw    r[a0.0]<1;1,0>:uw                {$7.src}
        mov (8|M0)               r6.8<1>:uw    r[a0.0,16]<1;1,0>:uw             {A@1}
        send.slm (1|M0)          r10      r75     null:0  0x0            0x0220C700           {A@1,$9} // wr:1+0, rd:2; load.slm.d64x8t.a32
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0x140:uw              {A@1}
        sync.nop                             null                             {Compacted,$9.dst}
        mov (8|M0)               r7.0<1>:uw    r[a0.0]<1;1,0>:uw                {$4.dst}
        mov (8|M0)               r7.8<1>:uw    r[a0.0,16]<1;1,0>:uw             {A@1}
        send.slm (1|M0)          r10      r74     null:0  0x0            0x0220C700           {A@1,$10} // wr:1+0, rd:2; load.slm.d64x8t.a32
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0x140:uw              {A@1}
        mov (8|M0)               r8.0<1>:uw    r[a0.0]<1;1,0>:uw                {$10.dst}
        mov (8|M0)               r8.8<1>:uw    r[a0.0,16]<1;1,0>:uw             {A@1}
        send.slm (1|M0)          r10      r73     null:0  0x0            0x0220C700           {A@1,$11} // wr:1+0, rd:2; load.slm.d64x8t.a32
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0x140:uw              {A@1}
        mov (8|M0)               r9.0<1>:uw    r[a0.0]<1;1,0>:uw                {$11.dst}
        mov (8|M0)               r9.8<1>:uw    r[a0.0,16]<1;1,0>:uw             {A@1}
        or (1|M0)                r10.0<1>:d    r1.5<0;1,0>:d     28672:w               {A@1}
        send.slm (1|M0)          null     r10     r6:4    0x0            0x0200D704           {A@1,$12} // wr:1+4, rd:0; store.slm.d64x16t.a32
L2944:
        join (32|M0)                         L9464                                
L2960:
        sync.allrd                           ($7,$12)                
(W)     send.slm (1|M0)          r6       r0      null:0  0x0            0x0210001F           {$13} // wr:1+0, rd:1; fence.slm.none.group
(W)     mov (8|M0)               null<1>:ud    r6.0<1;1,0>:ud                   {$13.dst}
(W)     mov (1|M0)               r6.2<1>:f     0.0:f                               {Compacted,I@1}
(W)     mov (2|M0)               r6.10<1>:ub   r0.11<0;1,0>:ub                  {F@1}
(W)     send.gtwy (1|M0)         null     r6      null:0  0x0            0x02000004           {A@1,$14} // wr:1+0, rd:0; signal barrier
(W)     sync.bar                             null                            
        addc (1|M0)              r7.0<1>:ud    r3.2<0;1,0>:ud    0xC00:ud              {AccWrEn,$4.dst}
        mov (2|M0)               r71.4<1>:d    0x1:v                               {$5.src}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$14.src}
        mov (1|M0)               r34.6<1>:d    r7.0<0;1,0>:d                    {I@3}
        addc (1|M0)              r7.0<1>:ud    r3.2<0;1,0>:ud    0xE00:ud              {AccWrEn}
        add3 (1|M0)              r34.7<1>:d    r6.0<0;0>:d       r3.3<0;0>:d       0:w               {I@3}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (16|M0)              r94.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r96.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r98.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r100.0<1>:f   0.0:f                               {Compacted}
        shl (1|M0)               r34.3<1>:d    r34.4<0;1,0>:d    9:w              
        mov (1|M0)               r71.6<2>:f    0.0:f                              
        mov (1|M0)               r71.7<2>:f    0.0:f                              
        mul (2|M0)               r71.4<1>:d    r71.4<1;1,0>:d    256:w              
        mov (1|M0)               r71.1<1>:d    r7.0<0;1,0>:d                    {I@5}
        add3 (1|M0)              r71.2<1>:d    r6.0<0;0>:d       r3.3<0;0>:d       0:w               {I@4}
L3288:
        shl (1|M0)               r73.2<1>:d    r71.7<0;1,0>:d    9:w               {F@1}
        shr (1|M0)               r73.1<1>:ud   r71.6<0;1,0>:ud   0x17:uw             
        shl (1|M0)               r73.3<1>:d    r71.6<0;1,0>:d    9:w              
        or (1|M0)                r73.4<1>:d    r73.2<0;1,0>:d    r73.1<0;1,0>:d   {I@2}
        shl (1|M0)               r73.1<1>:d    r73.3<0;1,0>:d    1:w               {I@2}
        mov (1|M0)               r6.0<1>:d     28672:w                              
        shr (1|M0)               r73.5<1>:ud   r73.3<0;1,0>:ud   0x1F:uw             
        shl (1|M0)               r73.6<1>:d    r73.4<0;1,0>:d    1:w               {I@4}
        addc (1|M0)              r7.0<1>:ud    r3.2<0;1,0>:ud    r73.1<0;1,0>:ud  {AccWrEn,I@4}
        send.slm (1|M0)          r35      r6      null:0  0x0            0x0280E700           {A@4,$15} // wr:1+0, rd:8; load.slm.d64x32t.a32
        or (1|M0)                r73.2<1>:d    r73.6<0;1,0>:d    r73.5<0;1,0>:d   {I@2}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$15.src}
        add3 (1|M0)              r7.1<1>:d     r6.0<0;0>:d       r3.3<0;0>:d       r73.2<0>:d       {I@1}
        addc (1|M0)              r6.0<1>:ud    r7.0<0;1,0>:ud    0x100:ud              {AccWrEn}
        send.ugm (1|M0)          r18      r7      null:0  0x0            0x0280E780           {A@2,$0} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        add3 (1|M0)              r6.1<1>:d     r8.0<0;0>:d       r7.1<0;0>:d       0:w               {I@1}
        or (2|M0)                r73.3<1>:d    r73.3<1;1,0>:d    r71.4<1;1,0>:d  
        send.ugm (1|M0)          r26      r6      null:0  0x0            0x0280E780           {A@2,$1} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        sync.allwr                           ($0,$1,$15)                
        dpas.8x8 (8|M0)          r6:f          null:f            r6:hf             r6.0:hf          {Atomic}
        dpas.8x8 (8|M0)          r6:f          r94:f             r18:hf            r35.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r18:f         r94:f             r26:hf            r35.0:hf         {$15}
        sync.nop                             null                             {Compacted,$15.src}
        shl (1|M0)               r27.1<1>:d    r73.4<0;1,0>:d    1:w               {I@1}
        shr (1|M0)               r27.0<1>:ud   r73.3<0;1,0>:ud   0x1F:uw             
        shl (1|M0)               r27.2<1>:d    r73.3<0;1,0>:d    1:w              
        or (1|M0)                r27.3<1>:d    r27.1<0;1,0>:d    r27.0<0;1,0>:d   {I@2}
        addc (1|M0)              r27.0<1>:ud   r3.2<0;1,0>:ud    r27.2<0;1,0>:ud  {AccWrEn,I@2}
        mov (1|M0)               r26.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        add3 (1|M0)              r27.1<1>:d    r26.0<0;0>:d      r3.3<0;0>:d       r27.3<0>:d       {I@1}
        addc (1|M0)              r26.0<1>:ud   r27.0<0;1,0>:ud   0x100:ud              {AccWrEn}
        sync.nop                             null                             {Compacted,$2.src}
        send.ugm (1|M0)          r43      r27     null:0  0x0            0x0280E780           {A@2,$3} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        mov (1|M0)               r28.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        add3 (1|M0)              r26.1<1>:d    r28.0<0;0>:d      r27.1<0;0>:d      0:w               {I@1}
        send.ugm (1|M0)          r55      r26     null:0  0x0            0x0280E780           {A@1,$6} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        sync.nop                             null                             {Compacted,$6.src}
        dpas.8x8 (8|M0)          r26:f         r94:f             r43:hf            r35.0:hf         {$3}
        dpas.8x8 (8|M0)          r35:f         r94:f             r55:hf            r35.0:hf         {$6}
        addc (1|M0)              r56.0<1>:ud   r34.6<0;1,0>:ud   r73.1<0;1,0>:ud  {AccWrEn,$6.src}
        mov (1|M0)               r55.0<1>:d    28928:w                              
        mov (1|M0)               r63.0<1>:f    r56.0<0;1,0>:f                   {Compacted,I@2}
        sync.nop                             null                             {Compacted,I@1}
        sync.nop                             null                             {Compacted,$3.src}
        send.slm (1|M0)          r43      r55     null:0  0x0            0x0280E700           {$8} // wr:1+0, rd:8; load.slm.d64x32t.a32
        mov (1|M0)               r55.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,$8.src}
        addc (1|M0)              r65.0<1>:ud   r63.0<0;1,0>:ud   0x100:ud              {AccWrEn,F@1}
        add3 (1|M0)              r63.1<1>:d    r55.0<0;0>:d      r34.7<0;0>:d      r73.2<0>:d       {I@2}
        mov (1|M0)               r64.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        send.ugm (1|M0)          r55      r63     null:0  0x0            0x0280E780           {A@2,$9} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        mov (1|M0)               r77.0<1>:f    r65.0<0;1,0>:f                   {Compacted}
        add3 (1|M0)              r77.1<1>:d    r64.0<0;0>:d      r63.1<0;0>:d      0:w               {I@1}
        send.ugm (1|M0)          r63      r77     null:0  0x0            0x0280E780           {A@1,$10} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        sync.allwr                           ($8,$9)                
        dpas.8x8 (8|M0)          r6:f          r6:f              r55:hf            r43.0:hf         {$15}
        addc (1|M0)              r56.0<1>:ud   r71.1<0;1,0>:ud   r73.1<0;1,0>:ud  {AccWrEn,$15.src}
        mov (1|M0)               r55.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        dpas.8x8 (8|M0)          r18:f         r18:f             r63:hf            r43.0:hf         {$10}
        sync.nop                             null                             {Compacted,$10.src}
        mov (1|M0)               r63.0<1>:f    r56.0<0;1,0>:f                   {Compacted,I@2}
        add3 (1|M0)              r63.1<1>:d    r55.0<0;0>:d      r71.2<0;0>:d      r73.2<0>:d       {I@1}
        addc (1|M0)              r65.0<1>:ud   r63.0<0;1,0>:ud   0x100:ud              {AccWrEn,F@1}
        send.ugm (1|M0)          r55      r63     null:0  0x0            0x0280E780           {A@2,$11} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        mov (1|M0)               r64.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r77.0<1>:f    r65.0<0;1,0>:f                   {Compacted,I@2}
        add3 (1|M0)              r77.1<1>:d    r64.0<0;0>:d      r63.1<0;0>:d      0:w               {I@1}
        send.ugm (1|M0)          r63      r77     null:0  0x0            0x0280E780           {A@1,$13} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        sync.allwr                           ($3,$6,$11,$13)                
        dpas.8x8 (8|M0)          r26:f         r26:f             r55:hf            r43.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r35:f         r35:f             r63:hf            r43.0:hf         {$3}
        sync.nop                             null                             {Compacted,$3.src}
        mov (8|M0)               r45.0<1>:f    r6.0<1;1,0>:f                    {Compacted,$15.dst}
        mov (8|M0)               r46.0<1>:f    r18.0<1;1,0>:f                   {Compacted,$10.dst}
        mov (1|M0)               r47.0<1>:d    29184:w                              
        mov (8|M0)               r43.0<1>:f    r26.0<1;1,0>:f                   {Compacted,$3.dst}
        send.slm (1|M0)          null     r47     r45:2   0x0            0x0200C704           {A@1,$14} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (1|M0)               r45.0<1>:d    29248:w                               {$14.src}
        mov (8|M0)               r46.0<1>:f    r19.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r44.0<1>:f    r35.0<1;1,0>:f                   {Compacted}
        mov (1|M0)               r47.0<1>:d    29312:w                              
        send.slm (1|M0)          null     r45     r43:2   0x0            0x0200C704           {A@1,$15} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r45.0<1>:f    r7.0<1;1,0>:f                    {Compacted,$15.src}
        mov (8|M0)               r43.0<1>:f    r27.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r47     r45:2   0x0            0x0200C704           {A@1,$0} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r44.0<1>:f    r36.0<1;1,0>:f                   {Compacted}
        mov (1|M0)               r45.0<1>:d    29376:w                               {$0.src}
        mov (8|M0)               r46.0<1>:f    r20.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r45     r43:2   0x0            0x0200C704           {A@1,$1} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (1|M0)               r47.0<1>:d    29440:w                              
        mov (8|M0)               r45.0<1>:f    r8.0<1;1,0>:f                    {Compacted,$1.src}
        mov (8|M0)               r43.0<1>:f    r28.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r47     r45:2   0x0            0x0200C704           {A@1,$3} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r44.0<1>:f    r37.0<1;1,0>:f                   {Compacted}
        mov (1|M0)               r45.0<1>:d    29504:w                               {$3.src}
        mov (8|M0)               r46.0<1>:f    r21.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r45     r43:2   0x0            0x0200C704           {A@1,$6} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (1|M0)               r47.0<1>:d    29568:w                              
        mov (8|M0)               r45.0<1>:f    r9.0<1;1,0>:f                    {Compacted,$6.src}
        mov (8|M0)               r43.0<1>:f    r29.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r47     r45:2   0x0            0x0200C704           {A@1,$8} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r44.0<1>:f    r38.0<1;1,0>:f                   {Compacted}
        mov (1|M0)               r45.0<1>:d    29632:w                               {$8.src}
        mov (8|M0)               r46.0<1>:f    r22.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r45     r43:2   0x0            0x0200C704           {A@1,$9} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (1|M0)               r47.0<1>:d    29696:w                              
        mov (8|M0)               r45.0<1>:f    r10.0<1;1,0>:f                   {Compacted,$9.src}
        mov (8|M0)               r43.0<1>:f    r30.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r47     r45:2   0x0            0x0200C704           {A@1,$10} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r44.0<1>:f    r39.0<1;1,0>:f                   {Compacted}
        mov (1|M0)               r45.0<1>:d    29760:w                               {$10.src}
        mov (8|M0)               r46.0<1>:f    r23.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r45     r43:2   0x0            0x0200C704           {A@1,$11} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (1|M0)               r47.0<1>:d    29824:w                              
        mov (8|M0)               r45.0<1>:f    r11.0<1;1,0>:f                   {Compacted,$11.src}
        mov (8|M0)               r43.0<1>:f    r31.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r47     r45:2   0x0            0x0200C704           {A@1,$13} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r44.0<1>:f    r40.0<1;1,0>:f                   {Compacted}
        mov (1|M0)               r45.0<1>:d    29888:w                               {$13.src}
        mov (8|M0)               r46.0<1>:f    r24.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r45     r43:2   0x0            0x0200C704           {A@1,$14} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (1|M0)               r47.0<1>:d    29952:w                              
        mov (8|M0)               r45.0<1>:f    r12.0<1;1,0>:f                   {Compacted,$14.src}
        mov (8|M0)               r6.0<1>:f     r13.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r47     r45:2   0x0            0x0200C704           {A@1,$15} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r7.0<1>:f     r25.0<1;1,0>:f                   {Compacted}
        mov (1|M0)               r8.0<1>:d     30080:w                              
        mov (8|M0)               r43.0<1>:f    r32.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r44.0<1>:f    r41.0<1;1,0>:f                   {Compacted}
        mov (1|M0)               r45.0<1>:d    30016:w                               {$15.src}
        mov (8|M0)               r9.0<1>:f     r33.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r45     r43:2   0x0            0x0200C704           {A@1,$2} // wr:1+2, rd:0; store.slm.d64x8t.a32
        send.slm (1|M0)          null     r8      r6:2    0x0            0x0200C704           {$0} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r10.0<1>:f    r42.0<1;1,0>:f                   {Compacted}
        mov (1|M0)               r6.0<1>:d     30144:w                               {$0.src}
        send.slm (1|M0)          null     r6      r9:2    0x0            0x0200C704           {A@1,$1} // wr:1+2, rd:0; store.slm.d64x8t.a32
        sync.nop                             null                             {Compacted,$1.src}
(W)     send.slm (1|M0)          r6       r0      null:0  0x0            0x0210001F           {$3} // wr:1+0, rd:1; fence.slm.none.group
(W)     mov (8|M0)               null<1>:ud    r6.0<1;1,0>:ud                   {$3.dst}
(W)     mov (1|M0)               r6.2<1>:f     0.0:f                               {Compacted,I@1}
(W)     mov (2|M0)               r6.10<1>:ub   r0.11<0;1,0>:ub                  {F@1}
(W)     send.gtwy (1|M0)         null     r6      null:0  0x0            0x02000004           {A@1,$6} // wr:1+0, rd:0; signal barrier
(W)     sync.bar                             null                            
(W)     mov (1|M0)               r10.0<1>:ud   r34.2<0;1,0>:ud                 
        mov (1|M0)               r73.2<2>:f    0.0:f                              
        sync.nop                             null                             {Compacted,I@1}
        sync.nop                             null                             {Compacted,$6.src}
        send.slm (1|M0)          r6       r10     null:0  0x0            0x0240D700           {$8} // wr:1+0, rd:4; load.slm.d64x16t.a32
        mov (1|M0)               r73.3<2>:f    0.0:f                              
        mov (1|M0)               r73.1<1>:d    0:w                              
L5248:
        addc (1|M0)              r11.0<1>:ud   r73.2<0;1,0>:ud   0x1:ud              {AccWrEn,F@2}
        shl (1|M0)               r2.15<1>:w    r73.2<0;1,0>:w    2:w               {I@2}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,$8.src}
        mov (1|M0)               r10.2<1>:d    r11.0<0;1,0>:d                   {I@3}
        add3 (1|M0)              r10.3<1>:d    r10.0<0;0>:d      r73.3<0;0>:d      0:w               {A@1}
        add (1|M0)               a0.1<1>:uw    r2.15<0;1,0>:uw   0xC0:uw              {A@1}
        cmp (1|M0)    (eq)f0.0   null<1>:d     r10.3<0;1,0>:d    0:w               {I@2}
        shl (1|M0)               r2.15<1>:w    r73.4<0;1,0>:w    2:w              
        add (1|M0)               r73.1<1>:d    r73.1<0;1,0>:d    1:w               {Compacted}
        add (1|M0)               a0.0<1>:uw    r2.15<0;1,0>:uw   0x1C0:uw              {A@1}
(f0.0)  cmp (1|M0)    (eq)f0.0   null<1>:d     r10.2<0;1,0>:d    32:w              
        mov (1|M0)               r[a0.0]<1>:f  r[a0.1]<0;1,0>:f                 {$8.dst}
(W)     and (1|M0)               f0.0<1>:ud    f0.0<0;1,0>:uw    0x1:uw              {A@1}
(f0.0.any32h) goto (32|M0)                   L5488                  L5488                
L5456:
(W)     mov (2|M0)               r73.2<1>:ud   r10.2<1;1,0>:ud                 
        goto.b (32|M0)                       L5488                  L5248                
L5488:
        join (32|M0)                         L9296                                
L5504:
        cmp (1|M0)    (eq)f0.1   null<1>:d     r71.6<0;1,0>:d    2:w              
        cmp (1|M0)    (eq)f0.0   null<1>:d     r71.7<0;1,0>:d    0:w              
(W)     mov (1|M0)               r73.2<1>:hf   0x1:hf                              {I@7}
(f0.1)  sel (1|M0)               r73.3<1>:uw   r73.2<0;1,0>:uw   0x0:uw              {F@1}
(f0.0)  sel (1|M0)               r73.2<1>:uw   r73.2<0;1,0>:uw   0x0:uw             
(W)     mov (1|M0)               r2.15<1>:uw   f0.0<0;1,0>:uw                  
        and (1|M0)    (ne)f0.0   null<1>:uw    r73.3<0;1,0>:uw   r73.2<0;1,0>:uw  {I@2}
(W)     and (1|M0)               f0.0<1>:ud    f0.0<0;1,0>:uw    0x1:uw             
(f0.0.any32h) goto (32|M0)                   L8008                  L8008                
L5648:
        mov (1|M0)               r73.2<2>:f    0.0:f                              
        mov (1|M0)               r73.3<2>:d    0:d                              
L5680:
        addc (1|M0)              r7.0<1>:ud    r73.2<0;1,0>:ud   0x1:ud              {AccWrEn,F@1}
        shl (1|M0)               r73.2<1>:w    r73.4<0;1,0>:w    2:w              
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r6.2<1>:d     r7.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r6.3<1>:d     r6.0<0;0>:d       r73.3<0;0>:d      0:w               {I@2}
        add (1|M0)               a0.0<1>:uw    r73.2<0;1,0>:uw   0x1C0:uw              {A@1}
        cmp (1|M0)    (eq)f0.0   null<1>:d     r6.3<0;1,0>:d     0:w               {I@2}
        mov (1|M0)               r73.2<2>:hf   r[a0.0]<0;1,0>:f                 {I@2}
(f0.0)  cmp (1|M0)    (eq)f0.0   null<1>:d     r6.2<0;1,0>:d     32:w               {A@1}
        mov (1|M0)               r[a0.0]<1>:f  r73.2<0;1,0>:hf                  {F@1}
(W)     and (1|M0)               f0.0<1>:ud    f0.0<0;1,0>:uw    0x1:uw             
(f0.0.any32h) goto (32|M0)                   L5896                  L5896                
L5864:
(W)     mov (2|M0)               r73.2<1>:ud   r6.2<1;1,0>:ud                  
        goto.b (32|M0)                       L5896                  L5680                
L5896:
        join (32|M0)                         L8008                                
L5912:
        mov (1|M0)               r73.2<2>:f    0.0:f                               {I@3}
        mov (1|M0)               r73.3<2>:d    0:d                              
L5944:
        shl (1|M0)               r73.4<1>:d    r73.2<0;1,0>:d    1:w               {F@1}
        shl (1|M0)               r73.6<1>:d    r73.3<0;1,0>:d    1:w               {I@2}
        shl (1|M0)               r73.8<1>:w    r73.8<0;1,0>:w    2:w               {I@2}
        shr (1|M0)               r73.1<1>:ud   r73.2<0;1,0>:ud   0x1F:uw             
        add (1|M0)               a0.0<1>:uw    r73.8<0;1,0>:uw   0x1C0:uw              {A@1}
        or (1|M0)                r73.5<1>:d    r73.6<0;1,0>:d    r73.1<0;1,0>:d   {I@2}
        addc (1|M0)              r7.0<1>:ud    r73.2<0;1,0>:ud   0x1:ud              {AccWrEn}
        add (1|M0)               a0.1<1>:uw    r73.8<0;1,0>:uw   0x900:uw              {A@1}
        mul (1|M0)               r73.1<1>:f    r[a0.0]<0;1,0>:f  r[a0.0]<0;1,0>:f {I@3}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,A@1}
        mov (1|M0)               r73.2<2>:hf   r73.1<0;1,0>:f                   {F@1}
        add3 (1|M0)              r6.3<1>:d     r6.0<0;0>:d       r73.3<0;0>:d      0:w               {I@1}
        mov (1|M0)               r73.5<1>:f    r73.2<0;1,0>:hf                  {F@1}
        mul (1|M0)               r73.1<1>:f    r[a0.0,32]<0;1,0>:f  r[a0.0,32]<0;1,0>:f
        cmp (1|M0)    (eq)f0.0   null<1>:d     r6.3<0;1,0>:d     0:w               {A@1}
        add (1|M0)               r73.1<1>:f    r73.1<0;1,0>:f    r73.5<0;1,0>:f   {F@1}
        mov (1|M0)               r6.2<1>:d     r7.0<0;1,0>:d                   
        mov (1|M0)               r73.10<2>:hf  r73.1<0;1,0>:f                   {F@1}
        mul (1|M0)               r73.1<1>:f    r[a0.0,64]<0;1,0>:f  r[a0.0,64]<0;1,0>:f
(f0.0)  cmp (1|M0)    (eq)f0.0   null<1>:d     r6.2<0;1,0>:d     4:w               {A@1}
        mov (1|M0)               r73.2<2>:hf   r73.1<0;1,0>:f                   {F@1}
        mov (1|M0)               r73.6<1>:f    r73.2<0;1,0>:hf                  {F@1}
        mul (1|M0)               r73.1<1>:f    r[a0.0,96]<0;1,0>:f  r[a0.0,96]<0;1,0>:f
(W)     and (1|M0)               f0.0<1>:ud    f0.0<0;1,0>:uw    0x1:uw              {A@1}
        add (1|M0)               r73.1<1>:f    r73.1<0;1,0>:f    r73.6<0;1,0>:f   {F@1}
        mov (1|M0)               r73.2<2>:hf   r73.1<0;1,0>:f                   {F@1}
        add (1|M0)               r73.10<1>:hf  r73.10<0;1,0>:hf  r73.2<0;1,0>:hf  {F@1}
        mul (1|M0)               r73.1<1>:f    r[a0.0,4]<0;1,0>:f  r[a0.0,4]<0;1,0>:f
        mov (1|M0)               r[a0.1]<1>:f  r73.10<0;1,0>:hf                 {A@1}
        mov (1|M0)               r73.2<2>:hf   r73.1<0;1,0>:f                   {F@2}
        mov (1|M0)               r73.4<1>:f    r73.2<0;1,0>:hf                  {F@1}
        mul (1|M0)               r73.1<1>:f    r[a0.0,36]<0;1,0>:f  r[a0.0,36]<0;1,0>:f
        add (1|M0)               r73.1<1>:f    r73.1<0;1,0>:f    r73.4<0;1,0>:f   {A@1}
        mov (1|M0)               r73.8<2>:hf   r73.1<0;1,0>:f                   {F@1}
        mul (1|M0)               r73.1<1>:f    r[a0.0,68]<0;1,0>:f  r[a0.0,68]<0;1,0>:f
        mov (1|M0)               r73.2<2>:hf   r73.1<0;1,0>:f                   {A@1}
        mov (1|M0)               r73.5<1>:f    r73.2<0;1,0>:hf                  {F@1}
        mul (1|M0)               r73.1<1>:f    r[a0.0,100]<0;1,0>:f  r[a0.0,100]<0;1,0>:f
        add (1|M0)               r73.1<1>:f    r73.1<0;1,0>:f    r73.5<0;1,0>:f   {A@1}
        mov (1|M0)               r73.2<2>:hf   r73.1<0;1,0>:f                   {F@1}
        add (1|M0)               r73.8<1>:hf   r73.8<0;1,0>:hf   r73.2<0;1,0>:hf  {F@1}
        mov (1|M0)               r[a0.1,4]<1>:f  r73.8<0;1,0>:hf                {F@1}
(f0.0.any32h) goto (32|M0)                   L6656                  L6656                
L6624:
(W)     mov (2|M0)               r73.2<1>:ud   r6.2<1;1,0>:ud                  
        goto.b (32|M0)                       L6656                  L5944                
L6656:
        join (32|M0)                         L8008                                
L6672:
        add (1|M0)               r73.1<1>:f    r72.0<0;1,0>:f    r72.4<0;1,0>:f   {F@1}
        cmp (1|M0)    (eq)f0.0   null<1>:d     r71.6<0;1,0>:d    0:w              
        mov (1|M0)               r73.4<2>:hf   r73.1<0;1,0>:f                   {A@1}
        add (1|M0)               r73.1<1>:f    r72.1<0;1,0>:f    r72.5<0;1,0>:f  
(W)     mov (1|M0)               r6.1<1>:uw    0x1:uw                             
        mov (1|M0)               r73.6<2>:hf   r73.1<0;1,0>:f                   {F@1}
        add (1|M0)               r73.1<1>:f    r72.2<0;1,0>:f    r72.6<0;1,0>:f  
(f0.0)  sel (1|M0)               r6.0<1>:uw    r6.1<0;1,0>:uw    0x0:uw              {I@1}
        mov (1|M0)               r73.8<2>:hf   r73.1<0;1,0>:f                   {F@1}
        add (1|M0)               r73.1<1>:f    r72.3<0;1,0>:f    r72.7<0;1,0>:f  
        add (1|M0)               r73.4<1>:hf   r73.4<0;1,0>:hf   r73.8<0;1,0>:hf  {F@2}
        mov (1|M0)               r73.2<2>:hf   r73.1<0;1,0>:f                   {F@2}
(W)     mov (1|M0)               f0.0<1>:uw    r2.15<0;1,0>:uw                 
        add (1|M0)               r73.6<1>:hf   r73.6<0;1,0>:hf   r73.2<0;1,0>:hf  {F@1}
        add (1|M0)               r73.4<1>:hf   r73.4<0;1,0>:hf   r73.6<0;1,0>:hf  {F@1}
        mov (1|M0)               r73.1<1>:f    r73.4<0;1,0>:hf                  {F@1}
        sel (1|M0)    (ge)f0.0   r73.1<1>:f    r73.1<0;1,0>:f    6.198883e-05:f               {F@1}
        math.sqt (1|M0)          r73.1<1>:f    r73.1<0;1,0>:f                   {@1,$9}
        math.inv (1|M0)          r73.1<1>:f    r73.1<0;1,0>:f                   {$9}
        mov (1|M0)               r73.2<2>:hf   r73.1<0;1,0>:f                   {$9.dst}
        mov (1|M0)               r6.1<1>:f     r73.2<0;1,0>:hf                  {F@1}
(f0.0)  sel (1|M0)               r73.2<1>:uw   r6.1<0;1,0>:uw    0x0:uw              {F@1}
        and (1|M0)    (ne)f1.0   null<1>:uw    r6.0<0;1,0>:uw    r73.2<0;1,0>:uw  {I@1}
(W)     and (1|M0)               f0.0<1>:ud    f1.0<0;1,0>:uw    0x1:uw             
(f0.0.any32h) goto (32|M0)                   L7096                  L7096                
L7072:
        mov (1|M0)               r6.4<1>:f     1.0:f                               {Compacted}
        goto (32|M0)                         L7096                  L7160                
L7096:
        join (32|M0)                         L7160                                
L7112:
        send.ugm (1|M0)          r6       r34     null:0  0x0            0x04100580           {A@1,$10} // wr:2+0, rd:1; load.ugm.d32.a64
        mov (1|M0)               r73.2<2>:hf   r6.0<0;1,0>:f                    {$10.dst}
        mov (1|M0)               r6.4<1>:f     r73.2<0;1,0>:hf                  {F@1}
L7160:
        join (32|M0)                         L8008                                
L7176:
        mov (1|M0)               r6.2<2>:f     0.0:f                              
        mov (1|M0)               r6.3<2>:d     0:d                              
        mov (1|M0)               r6.0<1>:d     0:w                              
L7224:
        shl (1|M0)               r73.2<1>:w    r6.4<0;1,0>:w     2:w               {F@1}
        add (1|M0)               a0.0<1>:uw    r73.2<0;1,0>:uw   0x1C0:uw              {A@1}
        mul (1|M0)               r73.1<1>:f    r[a0.0]<0;1,0>:f  r6.1<0;1,0>:f    {I@1}
        mov (1|M0)               r73.2<2>:hf   r73.1<0;1,0>:f                   {A@1}
        mov (1|M0)               r6.6<1>:f     r73.2<0;1,0>:hf                  {F@1}
        mul (1|M0)               r73.1<1>:f    r6.4<0;1,0>:f     r6.6<0;1,0>:f    {F@1}
        mov (1|M0)               r73.2<2>:hf   r73.1<0;1,0>:f                   {F@1}
        mov (1|M0)               r6.5<1>:f     r73.2<0;1,0>:hf                  {F@1}
(~f1.0) mov (1|M0)               r6.5<1>:f     r6.6<0;1,0>:f                   
        cmp (1|M0)    (lt)f1.1   null<1>:f     r6.5<0;1,0>:f     0.0:f               {F@1}
(f1.1)  mov (1|M0)               r6.5<1>:f     -r6.5<0;1,0>:f                  
        sel (1|M0)    (lt)f0.0   r6.5<1>:f     r6.5<0;1,0>:f     448.0:f               {F@1}
        shr (1|M0)               r6.7<1>:ud    r6.5<0;1,0>:ud    0x17:uw              {F@1}
        and (1|M0)               r6.7<1>:ud    r6.7<0;1,0>:ud    0xFF:uw              {I@1}
        sel (1|M0)    (ge)f0.0   r6.7<1>:ud    r6.7<0;1,0>:ud    0x79:uw              {I@1}
        shl (1|M0)               r6.7<1>:ud    r6.7<0;1,0>:ud    0x17:uw              {I@1}
        add (1|M0)               r73.2<1>:ud   -r6.7<0;1,0>:ud   0x80800000:ud              {I@1}
        mul (1|M0)               r73.1<1>:f    r6.5<0;1,0>:f     r73.2<0;1,0>:f   {I@1}
        mov (1|M0)               r73.1<1>:d    r73.1<0;1,0>:f                   {Compacted,F@1}
        mov (1|M0)               r6.6<1>:f     r73.1<0;1,0>:d                   {I@1}
        mad (1|M0)               r6.5<1>:f     -r6.6<0;0>:f      r73.2<0;0>:f      r6.5<0>:f        {F@1}
        cmp (1|M0)    (gt)f0.0   null<1>:f     r6.5<0;1,0>:f     0.5:f               {F@1}
(W)     and (1|M0)               f0.0<1>:ud    f0.0<0;1,0>:uw    0x1:uw              {F@1}
(f0.0.any32h) goto (32|M0)                   L7688                  L7688                
L7600:
        cmp (1|M0)    (lt)f0.0   null<1>:f     r6.5<0;1,0>:f     0.5:f               {A@1}
        and (1|M0)               r73.1<1>:d    r73.1<0;1,0>:d    1:w               {Compacted}
        add (1|M0)               r73.2<1>:f    r6.6<0;1,0>:f     1.0:f              
(~f0.0) cmp (1|M0)    (eq)f0.0   null<1>:d     r73.1<0;1,0>:d    0:w               {A@1}
(~f0.0) mov (1|M0)               r6.6<1>:f     r73.2<0;1,0>:f                   {F@1}
        goto (32|M0)                         L7688                  L7720                
L7688:
        join (32|M0)                         L7720                                
L7704:
        add (1|M0)               r6.6<1>:f     r6.6<0;1,0>:f     1.0:f               {F@1}
L7720:
        join (32|M0)                         L8008                                
L7736:
        addc (1|M0)              r8.0<1>:ud    r6.2<0;1,0>:ud    0x1:ud              {AccWrEn}
        add (1|M0)               r6.7<1>:ud    r6.7<0;1,0>:ud    0xFE800000:ud             
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mul (1|M0)               r6.6<1>:f     r6.6<0;1,0>:f     r6.7<0;1,0>:f    {A@1}
        add3 (1|M0)              r6.7<1>:d     r7.0<0;0>:d       r6.3<0;0>:d       0:w               {A@1}
        shl (1|M0)               r73.2<1>:w    r6.0<0;1,0>:w     1:w              
(f1.1)  mov (1|M0)               r6.6<1>:f     -r6.6<0;1,0>:f                  
        cmp (1|M0)    (eq)f0.0   null<1>:d     r6.7<0;1,0>:d     0:w               {I@2}
        add (1|M0)               a0.0<1>:uw    r73.2<0;1,0>:uw   0x660:uw              {A@1}
(W)     mov (1|M0)               r73.2<2>:hf   r6.6<0;1,0>:f                    {A@1}
        mov (1|M0)               r6.6<1>:d     r8.0<0;1,0>:d                    {F@1}
        add (1|M0)               r6.0<1>:d     r6.0<0;1,0>:d     1:w               {Compacted}
(f0.0)  cmp (1|M0)    (eq)f0.0   null<1>:d     r6.6<0;1,0>:d     32:w               {I@2}
        mov (1|M0)               r[a0.0]<1>:hf  r73.2<0;1,0>:hf                
(W)     and (1|M0)               f0.0<1>:ud    f0.0<0;1,0>:uw    0x1:uw             
(f0.0.any32h) goto (32|M0)                   L8008                  L8776                
L7976:
(W)     mov (2|M0)               r6.2<1>:ud    r6.6<1;1,0>:ud                  
        goto.b (32|M0)                       L8008                  L7224                
L8008:
        join (32|M0)                         L8776                                
L8024:
        mov (1|M0)               r73.4<2>:f    0.0:f                              
        mov (1|M0)               r73.5<2>:d    0:d                              
        mov (1|M0)               r73.2<1>:d    0:w                              
L8072:
        shl (1|M0)               r73.2<1>:w    r73.8<0;1,0>:w    2:w               {F@1}
        add (1|M0)               a0.0<1>:uw    r73.2<0;1,0>:uw   0x1C0:uw              {A@1}
        cmp (1|M0)    (lt)f1.0   null<1>:f     r[a0.0]<0;1,0>:f  0.0:f              
(W)     mov (1|M0)               r73.3<1>:f    -r[a0.0]<0;1,0>:f                {A@1}
(W)     mov (1|M0)               r73.1<1>:f    r[a0.0]<0;1,0>:f                 {A@1}
(f1.0)  sel (1|M0)               r73.7<1>:f    r73.3<0;1,0>:f    r73.1<0;1,0>:f   {A@1}
        sel (1|M0)    (lt)f0.0   r73.7<1>:f    r73.7<0;1,0>:f    448.0:f               {F@1}
        shr (1|M0)               r73.6<1>:ud   r73.7<0;1,0>:ud   0x17:uw              {F@1}
        and (1|M0)               r73.6<1>:ud   r73.6<0;1,0>:ud   0xFF:uw              {I@1}
        sel (1|M0)    (ge)f0.0   r73.6<1>:ud   r73.6<0;1,0>:ud   0x79:uw              {I@1}
        shl (1|M0)               r73.6<1>:ud   r73.6<0;1,0>:ud   0x17:uw              {I@1}
        add (1|M0)               r74.2<1>:ud   -r73.6<0;1,0>:ud  0x80800000:ud              {I@1}
        mul (1|M0)               r73.1<1>:f    r73.7<0;1,0>:f    r74.2<0;1,0>:f   {I@1}
        mov (1|M0)               r74.1<1>:d    r73.1<0;1,0>:f                   {Compacted,F@1}
        mov (1|M0)               r73.3<1>:f    r74.1<0;1,0>:d                   {I@1}
        mad (1|M0)               r73.7<1>:f    -r73.3<0;0>:f     r74.2<0;0>:f      r73.7<0>:f       {F@1}
        cmp (1|M0)    (gt)f0.0   null<1>:f     r73.7<0;1,0>:f    0.5:f               {F@1}
(W)     and (1|M0)               f0.0<1>:ud    f0.0<0;1,0>:uw    0x1:uw              {F@1}
(f0.0.any32h) goto (32|M0)                   L8456                  L8456                
L8368:
        cmp (1|M0)    (lt)f0.0   null<1>:f     r73.7<0;1,0>:f    0.5:f               {A@1}
        and (1|M0)               r74.1<1>:d    r74.1<0;1,0>:d    1:w               {Compacted}
        add (1|M0)               r74.2<1>:f    r73.3<0;1,0>:f    1.0:f              
(~f0.0) cmp (1|M0)    (eq)f0.0   null<1>:d     r74.1<0;1,0>:d    0:w               {A@1}
(~f0.0) mov (1|M0)               r73.3<1>:f    r74.2<0;1,0>:f                   {F@1}
        goto (32|M0)                         L8456                  L8480                
L8456:
        join (32|M0)                         L8480                                
L8472:
        add (1|M0)               r73.3<1>:f    r73.3<0;1,0>:f    1.0:f               {Compacted,F@1}
L8480:
        join (32|M0)                         L8776                                
L8496:
        addc (1|M0)              r7.0<1>:ud    r73.4<0;1,0>:ud   0x1:ud              {AccWrEn}
        add (1|M0)               r73.6<1>:ud   r73.6<0;1,0>:ud   0xFE800000:ud             
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r6.2<1>:d     r7.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r6.3<1>:d     r6.0<0;0>:d       r73.5<0;0>:d      0:w               {I@2}
        mul (1|M0)               r73.3<1>:f    r73.3<0;1,0>:f    r73.6<0;1,0>:f   {F@1}
        cmp (1|M0)    (eq)f0.0   null<1>:d     r6.3<0;1,0>:d     0:w               {I@1}
        shl (1|M0)               r73.2<1>:w    r73.4<0;1,0>:w    1:w              
(f1.0)  mov (1|M0)               r73.3<1>:f    -r73.3<0;1,0>:f                  {F@1}
        add (1|M0)               a0.0<1>:uw    r73.2<0;1,0>:uw   0x660:uw              {A@1}
(f0.0)  cmp (1|M0)    (eq)f0.0   null<1>:d     r6.2<0;1,0>:d     32:w              
(W)     mov (1|M0)               r73.2<2>:hf   r73.3<0;1,0>:f                   {A@1}
        add (1|M0)               r73.2<1>:d    r73.2<0;1,0>:d    1:w              
        mov (1|M0)               r[a0.0]<1>:hf  r73.2<0;1,0>:hf                 {F@1}
(W)     and (1|M0)               f0.0<1>:ud    f0.0<0;1,0>:uw    0x1:uw             
(f0.0.any32h) goto (32|M0)                   L8776                  L8776                
L8744:
(W)     mov (2|M0)               r73.4<1>:ud   r6.2<1;1,0>:ud                  
        goto.b (32|M0)                       L8776                  L8072                
L8776:
        join (32|M0)                         L9296                                
L8792:
        cmp (1|M0)    (eq)f0.0   null<1>:d     r71.6<0;1,0>:d    0:w              
(W)     mov (1|M0)               r73.3<1>:hf   0x1:hf                             
(f0.0)  sel (1|M0)               r73.4<1>:uw   r73.3<0;1,0>:uw   0x0:uw              {F@1}
(W)     mov (1|M0)               f0.0<1>:uw    r2.15<0;1,0>:uw                 
(f0.0)  sel (1|M0)               r73.2<1>:uw   r73.3<0;1,0>:uw   0x0:uw             
        cmp (1|M0)    (eq)f0.0   null<1>:d     r71.6<0;1,0>:d    1:w              
        and (1|M0)    (ne)f0.1   null<1>:uw    r73.4<0;1,0>:uw   r73.2<0;1,0>:uw  {I@2}
(f0.0)  sel (1|M0)               r73.2<1>:uw   r73.3<0;1,0>:uw   0x0:uw             
(W)     mov (1|M0)               f0.0<1>:uw    r2.15<0;1,0>:uw                 
(f0.0)  sel (1|M0)               r2.15<1>:uw   r73.3<0;1,0>:uw   0x0:uw             
        and (1|M0)    (ne)f0.0   null<1>:uw    r73.2<0;1,0>:uw   r2.15<0;1,0>:uw  {I@1}
(W)     mov (1|M0)               r2.15<1>:hf   0x1000:hf                              {I@1}
(f0.0)  sel (1|M0)               r73.1<1>:d    r2.15<0;1,0>:w    8192:w               {F@1}
(f0.1)  mov (1|M0)               r73.1<1>:d    0:w                              
        add3 (1|M0)              r6.0<1>:ud    r34.3<0;0>:ud     r5.7<0;0>:ud      r73.1<0>:ud      {I@1}
        send.slm (1|M0)          null     r6      r51:2   0x0            0x0200C704           {A@1,$11} // wr:1+2, rd:0; store.slm.d64x8t.a32
        sync.nop                             null                             {Compacted,$11.src}
(W)     send.slm (1|M0)          r6       r0      null:0  0x0            0x0210001F           {$13} // wr:1+0, rd:1; fence.slm.none.group
(W)     mov (8|M0)               null<1>:ud    r6.0<1;1,0>:ud                   {$13.dst}
(W)     mov (1|M0)               r6.2<1>:f     0.0:f                               {Compacted,I@1}
(W)     mov (2|M0)               r6.10<1>:ub   r0.11<0;1,0>:ub                  {F@1}
(W)     send.gtwy (1|M0)         null     r6      null:0  0x0            0x02000004           {A@1,$14} // wr:1+0, rd:0; signal barrier
(W)     sync.bar                             null                            
        addc (1|M0)              r7.0<1>:ud    r71.6<0;1,0>:ud   0x1:ud              {AccWrEn}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$14.src}
        mov (1|M0)               r6.2<1>:d     r7.0<0;1,0>:d                    {I@2}
        add3 (1|M0)              r6.3<1>:d     r6.0<0;0>:d       r71.7<0;0>:d      0:w               {I@2}
        cmp (1|M0)    (eq)f0.0   null<1>:d     r6.3<0;1,0>:d     0:w               {I@1}
(f0.0)  cmp (1|M0)    (eq)f0.0   null<1>:d     r6.2<0;1,0>:d     3:w              
(W)     and (1|M0)               f0.0<1>:ud    f0.0<0;1,0>:uw    0x1:uw             
(f0.0.any32h) goto (32|M0)                   L9296                  L9296                
L9264:
(W)     mov (2|M0)               r71.6<1>:ud   r6.2<1;1,0>:ud                  
        goto.b (32|M0)                       L9296                  L3288                
L9296:
        join (32|M0)                         L9464                                
L9312:
        addc (1|M0)              r7.0<1>:ud    r34.4<0;1,0>:ud   0x1:ud              {AccWrEn}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r6.2<1>:d     r7.0<0;1,0>:d                    {I@2}
        add3 (1|M0)              r6.3<1>:d     r6.0<0;0>:d       r34.5<0;0>:d      0:w               {I@2}
        cmp (1|M0)    (eq)f0.0   null<1>:d     r6.3<0;1,0>:d     0:w               {I@1}
(f0.0)  cmp (1|M0)    (eq)f0.0   null<1>:d     r6.2<0;1,0>:d     8:w              
(W)     and (1|M0)               f0.0<1>:ud    f0.0<0;1,0>:uw    0x1:uw             
(f0.0.any32h) goto (32|M0)                   L9464                  L9464                
L9432:
(W)     mov (2|M0)               r34.4<1>:ud   r6.2<1;1,0>:ud                  
        goto.b (32|M0)                       L9464                  L824                
L9464:
        join (32|M0)                         L9480                                
L9480:
        cmp (1|M0)    (eq)f1.0   null<1>:d     r4.3<0;1,0>:d     0:w              
        cmp (1|M0)    (lt)f0.0   null<1>:uw    r1.0<0;1,0>:uw    0x4:uw             
        mov (1|M0)               r2.2<1>:d     r5.6<0;1,0>:d                   
        mov (1|M0)               r2.3<1>:d     0:w                              
        shl (1|M0)               r1.6<1>:ud    r1.6<0;1,0>:ud    0x2:uw             
        mov (1|M0)               r5.6<1>:d     0:w                              
(f1.0)  cmp (1|M0)    (eq)f1.0   null<1>:d     r4.2<0;1,0>:d     0:w              
(W)     mov (1|M0)               r2.8<1>:uw    f0.0<0;1,0>:uw                   {Compacted}
L9600:
(W)     and (1|M0)               f0.0<1>:ud    r2.8<0;1,0>:uw    0x1:uw              {I@1}
(~f0.0.any32h) goto (32|M0)                  L10032                  L10032                
L9632:
        bfn.0xEA (1|M0)          r5.7<1>:ud    r5.6<0;0>:ud      r1.6<0;0>:ud      0x4:uw              // s0|s1&s2
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0x140:uw              {A@1}
        shl (1|M0)               r13.0<1>:ud   r5.7<0;1,0>:ud    0x6:uw              {I@2}
        send.slm (1|M0)          r10      r13     null:0  0x0            0x0220C700           {A@1,$1} // wr:1+0, rd:2; load.slm.d64x8t.a32
        sync.nop                             null                             {Compacted,$1.dst}
        sync.allrd                           ($0,$7,$12)                
        mov (8|M0)               r6.0<1>:uw    r[a0.0]<1;1,0>:uw                {$4.src}
        mov (8|M0)               r6.8<1>:uw    r[a0.0,16]<1;1,0>:uw             {A@1}
        or (1|M0)                r10.0<1>:ud   r13.0<0;1,0>:ud   0x40:uw              {A@1}
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0x160:uw              {A@1}
        send.slm (1|M0)          r11      r10     null:0  0x0            0x0220C700           {A@2,$3} // wr:1+0, rd:2; load.slm.d64x8t.a32
        or (1|M0)                r10.0<1>:ud   r13.0<0;1,0>:ud   0x80:uw              {$3.src}
        sync.nop                             null                             {Compacted,$3.dst}
        mov (8|M0)               r7.0<1>:uw    r[a0.0]<1;1,0>:uw                {$4.dst}
        mov (8|M0)               r7.8<1>:uw    r[a0.0,16]<1;1,0>:uw             {A@1}
        send.slm (1|M0)          r11      r10     null:0  0x0            0x0220C700           {A@1,$6} // wr:1+0, rd:2; load.slm.d64x8t.a32
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0x160:uw              {A@1}
        or (1|M0)                r10.0<1>:ud   r13.0<0;1,0>:ud   0xC0:uw              {$6.src}
        mov (8|M0)               r8.0<1>:uw    r[a0.0]<1;1,0>:uw                {$6.dst}
        mov (8|M0)               r8.8<1>:uw    r[a0.0,16]<1;1,0>:uw             {A@1}
        send.slm (1|M0)          r11      r10     null:0  0x0            0x0220C700           {A@1,$8} // wr:1+0, rd:2; load.slm.d64x8t.a32
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0x160:uw              {A@1}
        or (1|M0)                r10.0<1>:d    r1.5<0;1,0>:d     28672:w               {$8.src}
        mov (8|M0)               r9.0<1>:uw    r[a0.0]<1;1,0>:uw                {$8.dst}
        mov (8|M0)               r9.8<1>:uw    r[a0.0,16]<1;1,0>:uw             {A@1}
        send.slm (1|M0)          null     r10     r6:4    0x0            0x0200D704           {A@1,$9} // wr:1+4, rd:0; store.slm.d64x16t.a32
L10032:
        join (32|M0)                         L21424                                
L10048:
        sync.allrd                           ($0,$4,$7,$9,$12)                
(W)     send.slm (1|M0)          r6       r0      null:0  0x0            0x0210001F           {$10} // wr:1+0, rd:1; fence.slm.none.group
(W)     mov (8|M0)               null<1>:ud    r6.0<1;1,0>:ud                   {$10.dst}
(W)     mov (1|M0)               r6.2<1>:f     0.0:f                               {Compacted,I@1}
(W)     mov (2|M0)               r6.10<1>:ub   r0.11<0;1,0>:ub                  {F@1}
(W)     send.gtwy (1|M0)         null     r6      null:0  0x0            0x02000004           {A@1,$11} // wr:1+0, rd:0; signal barrier
(W)     sync.bar                             null                            
        mov (1|M0)               r22.0<1>:d    4160:w                              
        mov (1|M0)               r6.0<1>:d     28672:w                               {$11.src}
        sync.nop                             null                             {Compacted,$4.dst}
        send.slm (1|M0)          r7       r22     null:0  0x0            0x0210B700           {A@2,$13} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r22.0<1>:d    4224:w                               {$13.src}
        send.slm (1|M0)          r14      r6      null:0  0x0            0x0280E700           {A@2,$14} // wr:1+0, rd:8; load.slm.d64x32t.a32
        send.slm (1|M0)          r8       r22     null:0  0x0            0x0210B700           {A@1,$1} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r22.0<1>:d    4288:w                               {$1.src}
        mov (1|M0)               r6.0<1>:d     4096:w                               {$14.src}
        send.slm (1|M0)          r9       r22     null:0  0x0            0x0210B700           {A@2,$3} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r22.0<1>:d    4352:w                               {$3.src}
        send.slm (1|M0)          r6       r6      null:0  0x0            0x0210B700           {A@2,$6} // wr:1+0, rd:1; load.slm.d64x4t.a32
        send.slm (1|M0)          r10      r22     null:0  0x0            0x0210B700           {A@1,$8} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r22.0<1>:d    4416:w                               {$8.src}
        mov (1|M0)               r2.15<1>:hf   0x29C0:hf                             
        sync.nop                             null                             {Compacted,I@1}
        send.slm (1|M0)          r11      r22     null:0  0x0            0x0210B700           {$10} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r22.0<1>:d    4480:w                               {$10.src}
        mov (1|M0)               r2.9<1>:hf    0x3D34:hf                             
        sync.nop                             null                             {Compacted,I@1}
        send.slm (1|M0)          r12      r22     null:0  0x0            0x0210B700           {$4} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r22.0<1>:d    4544:w                               {$4.src}
        send.slm (1|M0)          r13      r22     null:0  0x0            0x0210B700           {A@1,$5} // wr:1+0, rd:1; load.slm.d64x4t.a32
        sync.allwr                           ($1,$3,$4,$5,$6,$8,$10,$13,$14)                
        dpas.8x8 (8|M0)          r22:f         null:f            r7:hf             r7.0:hf          {Atomic}
        dpas.8x8 (8|M0)          r22:f         r94:f             r6:hf             r14.0:hf         {$13}
        mov (1|M0)               r6.0<1>:d     4608:w                               {$13.src}
        send.slm (1|M0)          r30      r6      null:0  0x0            0x0210B700           {A@1,$7} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r6.0<1>:d     4672:w                               {$7.src}
        send.slm (1|M0)          r31      r6      null:0  0x0            0x0210B700           {A@1,$12} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r6.0<1>:d     4736:w                               {$12.src}
        send.slm (1|M0)          r32      r6      null:0  0x0            0x0210B700           {A@1,$15} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r6.0<1>:d     4800:w                               {$15.src}
        send.slm (1|M0)          r33      r6      null:0  0x0            0x0210B700           {A@1,$2} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r6.0<1>:d     4864:w                               {$2.src}
        send.slm (1|M0)          r34      r6      null:0  0x0            0x0210B700           {A@1,$0} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r6.0<1>:d     4928:w                               {$0.src}
        send.slm (1|M0)          r35      r6      null:0  0x0            0x0210B700           {A@1,$9} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r6.0<1>:d     4992:w                               {$9.src}
        send.slm (1|M0)          r36      r6      null:0  0x0            0x0210B700           {A@1,$11} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r6.0<1>:d     5056:w                               {$11.src}
        send.slm (1|M0)          r37      r6      null:0  0x0            0x0210B700           {A@1,$14} // wr:1+0, rd:1; load.slm.d64x4t.a32
        sync.allwr                           ($0,$2,$9,$11,$12,$14,$15)                
        dpas.8x8 (8|M0)          r6:f          r94:f             r30:hf            r14.0:hf         {$7}
(W)     send.dc0 (16|M0)         null     r0      r6:8    0x0            0x020F3000           {$7} // wr:1h+8, rd:0; hword scratch block write x8
        mov (1|M0)               r6.0<1>:d     5120:w                               {$7.src}
        send.slm (1|M0)          r30      r6      null:0  0x0            0x0210B700           {A@1,$1} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r6.0<1>:d     5184:w                               {$1.src}
        send.slm (1|M0)          r31      r6      null:0  0x0            0x0210B700           {A@1,$3} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r6.0<1>:d     5248:w                               {$3.src}
        send.slm (1|M0)          r32      r6      null:0  0x0            0x0210B700           {A@1,$6} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r6.0<1>:d     5312:w                               {$6.src}
        send.slm (1|M0)          r33      r6      null:0  0x0            0x0210B700           {A@1,$8} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r6.0<1>:d     5376:w                               {$8.src}
        send.slm (1|M0)          r34      r6      null:0  0x0            0x0210B700           {A@1,$10} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r6.0<1>:d     5440:w                               {$10.src}
        send.slm (1|M0)          r35      r6      null:0  0x0            0x0210B700           {A@1,$11} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r6.0<1>:d     5504:w                               {$11.src}
        send.slm (1|M0)          r36      r6      null:0  0x0            0x0210B700           {A@1,$14} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r6.0<1>:d     5568:w                               {$14.src}
        send.slm (1|M0)          r37      r6      null:0  0x0            0x0210B700           {A@1,$4} // wr:1+0, rd:1; load.slm.d64x4t.a32
        sync.allwr                           ($3,$4,$6,$8,$10,$11,$14)                
        dpas.8x8 (8|M0)          r6:f          r94:f             r30:hf            r14.0:hf         {$1}
(W)     send.dc0 (16|M0)         null     r0      r6:8    0x0            0x020F3008           {$1} // wr:1h+8, rd:0; hword scratch block write x8
        mov (1|M0)               r6.0<1>:d     5632:w                               {$1.src}
        send.slm (1|M0)          r30      r6      null:0  0x0            0x0210B700           {A@1,$3} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r6.0<1>:d     5696:w                               {$3.src}
        send.slm (1|M0)          r31      r6      null:0  0x0            0x0210B700           {A@1,$6} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r6.0<1>:d     5760:w                               {$6.src}
        send.slm (1|M0)          r32      r6      null:0  0x0            0x0210B700           {A@1,$8} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r6.0<1>:d     5824:w                               {$8.src}
        send.slm (1|M0)          r33      r6      null:0  0x0            0x0210B700           {A@1,$10} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r6.0<1>:d     5888:w                               {$10.src}
        send.slm (1|M0)          r34      r6      null:0  0x0            0x0210B700           {A@1,$11} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r6.0<1>:d     5952:w                               {$11.src}
        send.slm (1|M0)          r35      r6      null:0  0x0            0x0210B700           {A@1,$14} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r6.0<1>:d     6016:w                               {$14.src}
        send.slm (1|M0)          r36      r6      null:0  0x0            0x0210B700           {A@1,$5} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r6.0<1>:d     6080:w                               {$5.src}
        send.slm (1|M0)          r37      r6      null:0  0x0            0x0210B700           {A@1,$13} // wr:1+0, rd:1; load.slm.d64x4t.a32
        sync.allwr                           ($5,$6,$8,$10,$11,$13,$14)                
        dpas.8x8 (8|M0)          r6:f          r94:f             r30:hf            r14.0:hf         {$3}
(W)     send.dc0 (16|M0)         null     r0      r6:8    0x0            0x020F3030           {$3} // wr:1h+8, rd:0; hword scratch block write x8
        mov (1|M0)               r6.0<1>:d     6144:w                               {$3.src}
        send.slm (1|M0)          r30      r6      null:0  0x0            0x0210B700           {A@1,$12} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r6.0<1>:d     6208:w                               {$12.src}
        send.slm (1|M0)          r31      r6      null:0  0x0            0x0210B700           {A@1,$15} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r6.0<1>:d     6272:w                               {$15.src}
        send.slm (1|M0)          r32      r6      null:0  0x0            0x0210B700           {A@1,$2} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r6.0<1>:d     6336:w                               {$2.src}
        send.slm (1|M0)          r33      r6      null:0  0x0            0x0210B700           {A@1,$0} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r6.0<1>:d     6400:w                               {$0.src}
        send.slm (1|M0)          r34      r6      null:0  0x0            0x0210B700           {A@1,$9} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r6.0<1>:d     6464:w                               {$9.src}
        send.slm (1|M0)          r35      r6      null:0  0x0            0x0210B700           {A@1,$7} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r6.0<1>:d     6528:w                               {$7.src}
        send.slm (1|M0)          r36      r6      null:0  0x0            0x0210B700           {A@1,$4} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r6.0<1>:d     6592:w                               {$4.src}
        send.slm (1|M0)          r37      r6      null:0  0x0            0x0210B700           {A@1,$1} // wr:1+0, rd:1; load.slm.d64x4t.a32
        sync.allwr                           ($0,$1,$2,$4,$7,$9,$15)                
        dpas.8x8 (8|M0)          r6:f          r94:f             r30:hf            r14.0:hf         {$12}
(W)     send.dc0 (16|M0)         null     r0      r6:8    0x0            0x020F3038           {$12} // wr:1h+8, rd:0; hword scratch block write x8
        mov (1|M0)               r6.0<1>:d     6656:w                               {$12.src}
        send.slm (1|M0)          r30      r6      null:0  0x0            0x0210B700           {A@1,$6} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r6.0<1>:d     6720:w                               {$6.src}
        send.slm (1|M0)          r31      r6      null:0  0x0            0x0210B700           {A@1,$8} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r6.0<1>:d     6784:w                               {$8.src}
        send.slm (1|M0)          r32      r6      null:0  0x0            0x0210B700           {A@1,$10} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r6.0<1>:d     6848:w                               {$10.src}
        send.slm (1|M0)          r33      r6      null:0  0x0            0x0210B700           {A@1,$11} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r6.0<1>:d     6912:w                               {$11.src}
        send.slm (1|M0)          r34      r6      null:0  0x0            0x0210B700           {A@1,$14} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r6.0<1>:d     6976:w                               {$14.src}
        send.slm (1|M0)          r35      r6      null:0  0x0            0x0210B700           {A@1,$5} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r6.0<1>:d     7040:w                               {$5.src}
        send.slm (1|M0)          r36      r6      null:0  0x0            0x0210B700           {A@1,$13} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r6.0<1>:d     7104:w                               {$13.src}
        send.slm (1|M0)          r37      r6      null:0  0x0            0x0210B700           {A@1,$3} // wr:1+0, rd:1; load.slm.d64x4t.a32
        sync.allwr                           ($3,$5,$8,$10,$11,$13,$14)                
        dpas.8x8 (8|M0)          r6:f          r94:f             r30:hf            r14.0:hf         {$6}
        mov (1|M0)               r30.0<1>:d    7232:w                               {$6.src}
(W)     send.dc0 (16|M0)         null     r0      r6:8    0x0            0x020F3040           {$6} // wr:1h+8, rd:0; hword scratch block write x8
        sync.nop                             null                             {Compacted,$6.src}
        send.slm (1|M0)          r7       r30     null:0  0x0            0x0210B700           {A@1,$1} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r30.0<1>:d    7296:w                               {$1.src}
        mov (1|M0)               r6.0<1>:d     7168:w                              
        send.slm (1|M0)          r8       r30     null:0  0x0            0x0210B700           {A@2,$3} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r30.0<1>:d    7360:w                               {$3.src}
        send.slm (1|M0)          r6       r6      null:0  0x0            0x0210B700           {A@2,$8} // wr:1+0, rd:1; load.slm.d64x4t.a32
        send.slm (1|M0)          r9       r30     null:0  0x0            0x0210B700           {A@1,$10} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r30.0<1>:d    7424:w                               {$10.src}
        send.slm (1|M0)          r10      r30     null:0  0x0            0x0210B700           {A@1,$11} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r30.0<1>:d    7488:w                               {$11.src}
        send.slm (1|M0)          r11      r30     null:0  0x0            0x0210B700           {A@1,$14} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r30.0<1>:d    7552:w                               {$14.src}
        send.slm (1|M0)          r12      r30     null:0  0x0            0x0210B700           {A@1,$15} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r30.0<1>:d    7616:w                               {$15.src}
        send.slm (1|M0)          r13      r30     null:0  0x0            0x0210B700           {A@1,$2} // wr:1+0, rd:1; load.slm.d64x4t.a32
        sync.allwr                           ($2,$3,$8,$10,$11,$14,$15)                
        dpas.8x8 (8|M0)          r114:f        r94:f             r6:hf             r14.0:hf         {$1}
        mov (1|M0)               r6.0<1>:d     7680:w                               {$1.src}
        send.slm (1|M0)          r30      r6      null:0  0x0            0x0210B700           {A@1,$0} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r6.0<1>:d     7744:w                               {$0.src}
        send.slm (1|M0)          r31      r6      null:0  0x0            0x0210B700           {A@1,$9} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r6.0<1>:d     7808:w                               {$9.src}
        send.slm (1|M0)          r32      r6      null:0  0x0            0x0210B700           {A@1,$7} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r6.0<1>:d     7872:w                               {$7.src}
        send.slm (1|M0)          r33      r6      null:0  0x0            0x0210B700           {A@1,$4} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r6.0<1>:d     7936:w                               {$4.src}
        send.slm (1|M0)          r34      r6      null:0  0x0            0x0210B700           {A@1,$12} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r6.0<1>:d     8000:w                               {$12.src}
        send.slm (1|M0)          r35      r6      null:0  0x0            0x0210B700           {A@1,$5} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r6.0<1>:d     8064:w                               {$5.src}
        send.slm (1|M0)          r36      r6      null:0  0x0            0x0210B700           {A@1,$13} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r6.0<1>:d     8128:w                               {$13.src}
        send.slm (1|M0)          r37      r6      null:0  0x0            0x0210B700           {A@1,$6} // wr:1+0, rd:1; load.slm.d64x4t.a32
        sync.allwr                           ($4,$5,$6,$7,$9,$12,$13)                
        dpas.8x8 (8|M0)          r6:f          r94:f             r30:hf            r14.0:hf         {$0}
        mov (1|M0)               r14.0<1>:d    28928:w                               {$0.src}
(W)     send.dc0 (16|M0)         null     r0      r6:8    0x0            0x020F3010           {$0} // wr:1h+8, rd:0; hword scratch block write x8
        sync.nop                             null                             {Compacted,$0.src}
        send.slm (1|M0)          r6       r14     null:0  0x0            0x0280E700           {A@1,$3} // wr:1+0, rd:8; load.slm.d64x32t.a32
(W)     send.dc0 (16|M0)         null     r0      r6:8    0x0            0x020F3018           {$3} // wr:1h+8, rd:0; hword scratch block write x8
        mov (1|M0)               r6.0<1>:d     4128:w                               {$3.src}
        send.slm (1|M0)          r6       r6      null:0  0x0            0x0210B700           {A@1,$6} // wr:1+0, rd:1; load.slm.d64x4t.a32
(W)     send.dc0 (8|M0)          null     r0      r6:1    0x0            0x020F0020           {$6} // wr:1h+1, rd:0; hword scratch block write x1
        mov (1|M0)               r6.0<1>:d     4192:w                               {$6.src}
        send.slm (1|M0)          r6       r6      null:0  0x0            0x0210B700           {A@1,$8} // wr:1+0, rd:1; load.slm.d64x4t.a32
(W)     send.dc0 (8|M0)          null     r0      r6:1    0x0            0x020F0021           {$8} // wr:1h+1, rd:0; hword scratch block write x1
        mov (1|M0)               r6.0<1>:d     4256:w                               {$8.src}
        send.slm (1|M0)          r6       r6      null:0  0x0            0x0210B700           {A@1,$10} // wr:1+0, rd:1; load.slm.d64x4t.a32
(W)     send.dc0 (8|M0)          null     r0      r6:1    0x0            0x020F0022           {$10} // wr:1h+1, rd:0; hword scratch block write x1
        mov (1|M0)               r6.0<1>:d     4320:w                               {$10.src}
        send.slm (1|M0)          r6       r6      null:0  0x0            0x0210B700           {A@1,$11} // wr:1+0, rd:1; load.slm.d64x4t.a32
(W)     send.dc0 (8|M0)          null     r0      r6:1    0x0            0x020F0023           {$11} // wr:1h+1, rd:0; hword scratch block write x1
        mov (1|M0)               r6.0<1>:d     4384:w                               {$11.src}
        send.slm (1|M0)          r6       r6      null:0  0x0            0x0210B700           {A@1,$14} // wr:1+0, rd:1; load.slm.d64x4t.a32
(W)     send.dc0 (8|M0)          null     r0      r6:1    0x0            0x020F0024           {$14} // wr:1h+1, rd:0; hword scratch block write x1
        mov (1|M0)               r6.0<1>:d     4448:w                               {$14.src}
        send.slm (1|M0)          r6       r6      null:0  0x0            0x0210B700           {A@1,$15} // wr:1+0, rd:1; load.slm.d64x4t.a32
(W)     send.dc0 (8|M0)          null     r0      r6:1    0x0            0x020F0025           {$15} // wr:1h+1, rd:0; hword scratch block write x1
        mov (1|M0)               r6.0<1>:d     4512:w                               {$15.src}
        send.slm (1|M0)          r6       r6      null:0  0x0            0x0210B700           {A@1,$2} // wr:1+0, rd:1; load.slm.d64x4t.a32
(W)     send.dc0 (8|M0)          null     r0      r6:1    0x0            0x020F0026           {$2} // wr:1h+1, rd:0; hword scratch block write x1
        mov (1|M0)               r6.0<1>:d     4576:w                               {$2.src}
        send.slm (1|M0)          r6       r6      null:0  0x0            0x0210B700           {A@1,$1} // wr:1+0, rd:1; load.slm.d64x4t.a32
(W)     send.dc0 (8|M0)          null     r0      r6:1    0x0            0x020F0027           {$1} // wr:1h+1, rd:0; hword scratch block write x1
        mov (1|M0)               r6.0<1>:d     4640:w                               {$1.src}
        send.slm (1|M0)          r6       r6      null:0  0x0            0x0210B700           {A@1,$9} // wr:1+0, rd:1; load.slm.d64x4t.a32
(W)     send.dc0 (8|M0)          null     r0      r6:1    0x0            0x020F0028           {$9} // wr:1h+1, rd:0; hword scratch block write x1
        mov (1|M0)               r6.0<1>:d     4704:w                               {$9.src}
        send.slm (1|M0)          r6       r6      null:0  0x0            0x0210B700           {A@1,$7} // wr:1+0, rd:1; load.slm.d64x4t.a32
(W)     send.dc0 (8|M0)          null     r0      r6:1    0x0            0x020F0029           {$7} // wr:1h+1, rd:0; hword scratch block write x1
        mov (1|M0)               r6.0<1>:d     4768:w                               {$7.src}
        send.slm (1|M0)          r6       r6      null:0  0x0            0x0210B700           {A@1,$4} // wr:1+0, rd:1; load.slm.d64x4t.a32
(W)     send.dc0 (8|M0)          null     r0      r6:1    0x0            0x020F002A           {$4} // wr:1h+1, rd:0; hword scratch block write x1
        mov (1|M0)               r6.0<1>:d     4832:w                               {$4.src}
        send.slm (1|M0)          r6       r6      null:0  0x0            0x0210B700           {A@1,$12} // wr:1+0, rd:1; load.slm.d64x4t.a32
(W)     send.dc0 (16|M0)         r14      r0      null:0  0x0            0x028C3020           {$5} // wr:1h+0, rd:8; hword scratch block read x8
(W)     send.dc0 (8|M0)          null     r0      r6:1    0x0            0x020F002B           {$12} // wr:1h+1, rd:0; hword scratch block write x1
        mov (1|M0)               r6.0<1>:d     4896:w                               {$12.src}
        send.slm (1|M0)          r6       r6      null:0  0x0            0x0210B700           {A@1,$13} // wr:1+0, rd:1; load.slm.d64x4t.a32
(W)     send.dc0 (8|M0)          null     r0      r6:1    0x0            0x020F002C           {$13} // wr:1h+1, rd:0; hword scratch block write x1
        mov (1|M0)               r6.0<1>:d     4960:w                               {$13.src}
        send.slm (1|M0)          r6       r6      null:0  0x0            0x0210B700           {A@1,$0} // wr:1+0, rd:1; load.slm.d64x4t.a32
(W)     send.dc0 (8|M0)          null     r0      r6:1    0x0            0x020F002D           {$0} // wr:1h+1, rd:0; hword scratch block write x1
        mov (1|M0)               r6.0<1>:d     5024:w                               {$0.src}
        send.slm (1|M0)          r6       r6      null:0  0x0            0x0210B700           {A@1,$3} // wr:1+0, rd:1; load.slm.d64x4t.a32
(W)     send.dc0 (8|M0)          null     r0      r6:1    0x0            0x020F002E           {$3} // wr:1h+1, rd:0; hword scratch block write x1
        mov (1|M0)               r6.0<1>:d     5088:w                               {$3.src}
        send.slm (1|M0)          r6       r6      null:0  0x0            0x0210B700           {A@1,$6} // wr:1+0, rd:1; load.slm.d64x4t.a32
(W)     send.dc0 (8|M0)          null     r0      r6:1    0x0            0x020F002F           {$6} // wr:1h+1, rd:0; hword scratch block write x1
        sync.nop                             null                             {Compacted,$6.src}
(W)     send.dc0 (16|M0)         r6       r0      null:0  0x0            0x028C3018           {$8} // wr:1h+0, rd:8; hword scratch block read x8
        sync.allwr                           ($8,$13)                
        dpas.8x8 (8|M0)          r30:f         r22:f             r14:hf            r6.0:hf          {$5}
        sync.nop                             null                             {Compacted,$5.src}
(W)     send.dc0 (16|M0)         r22      r0      null:0  0x0            0x028C3000           {$10} // wr:1h+0, rd:8; hword scratch block read x8
(W)     send.dc0 (16|M0)         r14      r0      null:0  0x0            0x028C3028           {$11} // wr:1h+0, rd:8; hword scratch block read x8
        sync.nop                             null                             {Compacted,$11.dst}
        sync.nop                             null                             {Compacted,$2.src}
        dpas.8x8 (8|M0)          r38:f         r22:f             r14:hf            r6.0:hf          {$10}
        mov (1|M0)               r6.0<1>:d     5152:w                               {$10.src}
(W)     send.dc0 (16|M0)         r22      r0      null:0  0x0            0x028C3008           {$14} // wr:1h+0, rd:8; hword scratch block read x8
        send.slm (1|M0)          r6       r6      null:0  0x0            0x0210B700           {A@1,$15} // wr:1+0, rd:1; load.slm.d64x4t.a32
(W)     send.dc0 (8|M0)          null     r0      r6:1    0x0            0x020F0000           {$15} // wr:1h+1, rd:0; hword scratch block write x1
        mov (1|M0)               r6.0<1>:d     5216:w                               {$15.src}
        send.slm (1|M0)          r6       r6      null:0  0x0            0x0210B700           {A@1,$2} // wr:1+0, rd:1; load.slm.d64x4t.a32
(W)     send.dc0 (8|M0)          null     r0      r6:1    0x0            0x020F0001           {$2} // wr:1h+1, rd:0; hword scratch block write x1
        mov (1|M0)               r6.0<1>:d     5280:w                               {$2.src}
        send.slm (1|M0)          r6       r6      null:0  0x0            0x0210B700           {A@1,$1} // wr:1+0, rd:1; load.slm.d64x4t.a32
(W)     send.dc0 (8|M0)          null     r0      r6:1    0x0            0x020F0002           {$1} // wr:1h+1, rd:0; hword scratch block write x1
        mov (1|M0)               r6.0<1>:d     5344:w                               {$1.src}
        send.slm (1|M0)          r6       r6      null:0  0x0            0x0210B700           {A@1,$9} // wr:1+0, rd:1; load.slm.d64x4t.a32
(W)     send.dc0 (8|M0)          null     r0      r6:1    0x0            0x020F0003           {$9} // wr:1h+1, rd:0; hword scratch block write x1
        mov (1|M0)               r6.0<1>:d     5408:w                               {$9.src}
        send.slm (1|M0)          r6       r6      null:0  0x0            0x0210B700           {A@1,$7} // wr:1+0, rd:1; load.slm.d64x4t.a32
(W)     send.dc0 (8|M0)          null     r0      r6:1    0x0            0x020F0004           {$7} // wr:1h+1, rd:0; hword scratch block write x1
        mov (1|M0)               r6.0<1>:d     5472:w                               {$7.src}
        send.slm (1|M0)          r6       r6      null:0  0x0            0x0210B700           {A@1,$4} // wr:1+0, rd:1; load.slm.d64x4t.a32
(W)     send.dc0 (8|M0)          null     r0      r6:1    0x0            0x020F0005           {$4} // wr:1h+1, rd:0; hword scratch block write x1
        mov (1|M0)               r6.0<1>:d     5536:w                               {$4.src}
        send.slm (1|M0)          r6       r6      null:0  0x0            0x0210B700           {A@1,$12} // wr:1+0, rd:1; load.slm.d64x4t.a32
(W)     send.dc0 (8|M0)          null     r0      r6:1    0x0            0x020F0006           {$12} // wr:1h+1, rd:0; hword scratch block write x1
        mov (1|M0)               r6.0<1>:d     5600:w                               {$12.src}
        send.slm (1|M0)          r6       r6      null:0  0x0            0x0210B700           {A@1,$13} // wr:1+0, rd:1; load.slm.d64x4t.a32
(W)     send.dc0 (8|M0)          null     r0      r6:1    0x0            0x020F0007           {$13} // wr:1h+1, rd:0; hword scratch block write x1
        sync.nop                             null                             {Compacted,$13.src}
(W)     send.dc0 (16|M0)         r6       r0      null:0  0x0            0x028C3018           {$0} // wr:1h+0, rd:8; hword scratch block read x8
(W)     send.dc0 (16|M0)         r14      r0      null:0  0x0            0x028C3000           {$3} // wr:1h+0, rd:8; hword scratch block read x8
        sync.allwr                           ($3,$14)                
        dpas.8x8 (8|M0)          r46:f         r22:f             r14:hf            r6.0:hf          {$0}
        mov (1|M0)               r6.0<1>:d     5664:w                               {$0.src}
(W)     send.dc0 (16|M0)         r14      r0      null:0  0x0            0x028C3018           {$6} // wr:1h+0, rd:8; hword scratch block read x8
        send.slm (1|M0)          r6       r6      null:0  0x0            0x0210B700           {A@1,$8} // wr:1+0, rd:1; load.slm.d64x4t.a32
(W)     send.dc0 (8|M0)          null     r0      r6:1    0x0            0x020F0000           {$8} // wr:1h+1, rd:0; hword scratch block write x1
        mov (1|M0)               r6.0<1>:d     5728:w                               {$8.src}
        send.slm (1|M0)          r6       r6      null:0  0x0            0x0210B700           {A@1,$11} // wr:1+0, rd:1; load.slm.d64x4t.a32
(W)     send.dc0 (8|M0)          null     r0      r6:1    0x0            0x020F0001           {$11} // wr:1h+1, rd:0; hword scratch block write x1
        mov (1|M0)               r6.0<1>:d     5792:w                               {$11.src}
        send.slm (1|M0)          r6       r6      null:0  0x0            0x0210B700           {A@1,$5} // wr:1+0, rd:1; load.slm.d64x4t.a32
(W)     send.dc0 (8|M0)          null     r0      r6:1    0x0            0x020F0002           {$5} // wr:1h+1, rd:0; hword scratch block write x1
        mov (1|M0)               r6.0<1>:d     5856:w                               {$5.src}
        send.slm (1|M0)          r6       r6      null:0  0x0            0x0210B700           {A@1,$10} // wr:1+0, rd:1; load.slm.d64x4t.a32
(W)     send.dc0 (8|M0)          null     r0      r6:1    0x0            0x020F0003           {$10} // wr:1h+1, rd:0; hword scratch block write x1
        mov (1|M0)               r6.0<1>:d     5920:w                               {$10.src}
        send.slm (1|M0)          r6       r6      null:0  0x0            0x0210B700           {A@1,$15} // wr:1+0, rd:1; load.slm.d64x4t.a32
(W)     send.dc0 (8|M0)          null     r0      r6:1    0x0            0x020F0004           {$15} // wr:1h+1, rd:0; hword scratch block write x1
        mov (1|M0)               r6.0<1>:d     5984:w                               {$15.src}
        send.slm (1|M0)          r6       r6      null:0  0x0            0x0210B700           {A@1,$2} // wr:1+0, rd:1; load.slm.d64x4t.a32
(W)     send.dc0 (8|M0)          null     r0      r6:1    0x0            0x020F0005           {$2} // wr:1h+1, rd:0; hword scratch block write x1
        mov (1|M0)               r6.0<1>:d     6048:w                               {$2.src}
        send.slm (1|M0)          r6       r6      null:0  0x0            0x0210B700           {A@1,$1} // wr:1+0, rd:1; load.slm.d64x4t.a32
(W)     send.dc0 (8|M0)          null     r0      r6:1    0x0            0x020F0006           {$1} // wr:1h+1, rd:0; hword scratch block write x1
        mov (1|M0)               r6.0<1>:d     6112:w                               {$1.src}
        send.slm (1|M0)          r6       r6      null:0  0x0            0x0210B700           {A@1,$9} // wr:1+0, rd:1; load.slm.d64x4t.a32
(W)     send.dc0 (8|M0)          null     r0      r6:1    0x0            0x020F0007           {$9} // wr:1h+1, rd:0; hword scratch block write x1
        sync.nop                             null                             {Compacted,$9.src}
(W)     send.dc0 (16|M0)         r6       r0      null:0  0x0            0x028C3030           {$14} // wr:1h+0, rd:8; hword scratch block read x8
(W)     send.dc0 (16|M0)         r22      r0      null:0  0x0            0x028C3000           {$7} // wr:1h+0, rd:8; hword scratch block read x8
        sync.allwr                           ($6,$7)                
        dpas.8x8 (8|M0)          r54:f         r6:f              r22:hf            r14.0:hf         {$14}
        mov (1|M0)               r6.0<1>:d     6176:w                               {$14.src}
        send.slm (1|M0)          r22      r6      null:0  0x0            0x0210B700           {A@1,$4} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r6.0<1>:d     6240:w                               {$4.src}
        send.slm (1|M0)          r23      r6      null:0  0x0            0x0210B700           {A@1,$12} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r6.0<1>:d     6304:w                               {$12.src}
        send.slm (1|M0)          r24      r6      null:0  0x0            0x0210B700           {A@1,$13} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r6.0<1>:d     6368:w                               {$13.src}
        send.slm (1|M0)          r25      r6      null:0  0x0            0x0210B700           {A@1,$3} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r6.0<1>:d     6432:w                               {$3.src}
        send.slm (1|M0)          r26      r6      null:0  0x0            0x0210B700           {A@1,$0} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r6.0<1>:d     6496:w                               {$0.src}
        send.slm (1|M0)          r27      r6      null:0  0x0            0x0210B700           {A@1,$8} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r6.0<1>:d     6560:w                               {$8.src}
        send.slm (1|M0)          r28      r6      null:0  0x0            0x0210B700           {A@1,$11} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r6.0<1>:d     6624:w                               {$11.src}
        send.slm (1|M0)          r29      r6      null:0  0x0            0x0210B700           {A@1,$6} // wr:1+0, rd:1; load.slm.d64x4t.a32
        sync.nop                             null                             {Compacted,$6.src}
(W)     send.dc0 (16|M0)         r6       r0      null:0  0x0            0x028C3038           {$5} // wr:1h+0, rd:8; hword scratch block read x8
        sync.allwr                           ($0,$3,$5,$6,$8,$11,$12,$13)                
        dpas.8x8 (8|M0)          r62:f         r6:f              r22:hf            r14.0:hf         {$4}
        mov (1|M0)               r6.0<1>:d     6688:w                               {$4.src}
        send.slm (1|M0)          r22      r6      null:0  0x0            0x0210B700           {A@1,$13} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r6.0<1>:d     6752:w                               {$13.src}
        send.slm (1|M0)          r23      r6      null:0  0x0            0x0210B700           {A@1,$3} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r6.0<1>:d     6816:w                               {$3.src}
        send.slm (1|M0)          r24      r6      null:0  0x0            0x0210B700           {A@1,$6} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r6.0<1>:d     6880:w                               {$6.src}
        send.slm (1|M0)          r25      r6      null:0  0x0            0x0210B700           {A@1,$8} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r6.0<1>:d     6944:w                               {$8.src}
        send.slm (1|M0)          r26      r6      null:0  0x0            0x0210B700           {A@1,$11} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r6.0<1>:d     7008:w                               {$11.src}
        send.slm (1|M0)          r27      r6      null:0  0x0            0x0210B700           {A@1,$10} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r6.0<1>:d     7072:w                               {$10.src}
        send.slm (1|M0)          r28      r6      null:0  0x0            0x0210B700           {A@1,$15} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r6.0<1>:d     7136:w                               {$15.src}
        send.slm (1|M0)          r29      r6      null:0  0x0            0x0210B700           {A@1,$2} // wr:1+0, rd:1; load.slm.d64x4t.a32
        sync.nop                             null                             {Compacted,$2.src}
(W)     send.dc0 (16|M0)         r6       r0      null:0  0x0            0x028C3040           {$1} // wr:1h+0, rd:8; hword scratch block read x8
        sync.allwr                           ($1,$2,$3,$6,$8,$10,$11,$15)                
        dpas.8x8 (8|M0)          r70:f         r6:f              r22:hf            r14.0:hf         {$13}
        mov (1|M0)               r6.0<1>:d     7200:w                               {$13.src}
        send.slm (1|M0)          r14      r6      null:0  0x0            0x0210B700           {A@1,$3} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r6.0<1>:d     7264:w                               {$3.src}
        send.slm (1|M0)          r15      r6      null:0  0x0            0x0210B700           {A@1,$6} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r6.0<1>:d     7328:w                               {$6.src}
        send.slm (1|M0)          r16      r6      null:0  0x0            0x0210B700           {A@1,$8} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r6.0<1>:d     7392:w                               {$8.src}
        send.slm (1|M0)          r17      r6      null:0  0x0            0x0210B700           {A@1,$11} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r6.0<1>:d     7456:w                               {$11.src}
        send.slm (1|M0)          r18      r6      null:0  0x0            0x0210B700           {A@1,$9} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r6.0<1>:d     7520:w                               {$9.src}
        send.slm (1|M0)          r19      r6      null:0  0x0            0x0210B700           {A@1,$14} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r6.0<1>:d     7584:w                               {$14.src}
        send.slm (1|M0)          r20      r6      null:0  0x0            0x0210B700           {A@1,$7} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r6.0<1>:d     7648:w                               {$7.src}
        send.slm (1|M0)          r21      r6      null:0  0x0            0x0210B700           {A@1,$12} // wr:1+0, rd:1; load.slm.d64x4t.a32
        sync.nop                             null                             {Compacted,$12.src}
(W)     send.dc0 (16|M0)         r6       r0      null:0  0x0            0x028C3018           {$0} // wr:1h+0, rd:8; hword scratch block read x8
        sync.allwr                           ($0,$6,$7,$8,$9,$11,$12,$14)                
        dpas.8x8 (8|M0)          r78:f         r114:f            r14:hf            r6.0:hf          {$3}
        mov (1|M0)               r6.0<1>:d     7712:w                               {$3.src}
(W)     send.dc0 (16|M0)         r14      r0      null:0  0x0            0x028C3010           {$1} // wr:1h+0, rd:8; hword scratch block read x8
        send.slm (1|M0)          r22      r6      null:0  0x0            0x0210B700           {A@1,$6} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r6.0<1>:d     7776:w                               {$6.src}
        send.slm (1|M0)          r23      r6      null:0  0x0            0x0210B700           {A@1,$8} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r6.0<1>:d     7840:w                               {$8.src}
        send.slm (1|M0)          r24      r6      null:0  0x0            0x0210B700           {A@1,$11} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r6.0<1>:d     7904:w                               {$11.src}
        send.slm (1|M0)          r25      r6      null:0  0x0            0x0210B700           {A@1,$4} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r6.0<1>:d     7968:w                               {$4.src}
        send.slm (1|M0)          r26      r6      null:0  0x0            0x0210B700           {A@1,$10} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r6.0<1>:d     8032:w                               {$10.src}
        send.slm (1|M0)          r27      r6      null:0  0x0            0x0210B700           {A@1,$15} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r6.0<1>:d     8096:w                               {$15.src}
        send.slm (1|M0)          r28      r6      null:0  0x0            0x0210B700           {A@1,$5} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r6.0<1>:d     8160:w                               {$5.src}
        send.slm (1|M0)          r29      r6      null:0  0x0            0x0210B700           {A@1,$2} // wr:1+0, rd:1; load.slm.d64x4t.a32
        sync.nop                             null                             {Compacted,$2.src}
(W)     send.dc0 (16|M0)         r6       r0      null:0  0x0            0x028C3018           {$13} // wr:1h+0, rd:8; hword scratch block read x8
        sync.allwr                           ($2,$4,$5,$6,$8,$10,$11,$13,$15)                
        dpas.8x8 (8|M0)          r86:f         r14:f             r22:hf            r6.0:hf          {$1}
        mov (1|M0)               r14.4<2>:f    0.0:f                               {$1.src}
        mov (1|M0)               r14.5<2>:f    0.0:f                              
L15872:
        shl (1|M0)               r5.7<1>:d     r14.4<0;1,0>:d    6:w               {F@2}
        shl (1|M0)               r14.3<1>:d    r14.4<0;1,0>:d    3:w              
        shl (1|M0)               r5.3<1>:w     r5.14<0;1,0>:w    2:w               {I@2}
        shl (1|M0)               r14.2<1>:d    r14.4<0;1,0>:d    5:w              
        add (1|M0)               a0.0<1>:uw    r5.3<0;1,0>:uw    0x3C0:uw              {A@1}
        mov (1|M0)               r5.7<1>:d     0:w                              
        sync.allwr                           ($0,$1,$3,$4,$10,$13,$14)                
        mov (1|M0)               r6.0<1>:f     r[a0.0]<0;1,0>:f                 {$5.dst}
        mov (1|M0)               r6.1<1>:f     r[a0.0,4]<0;1,0>:f               {A@1}
        mov (1|M0)               r6.2<1>:f     r[a0.0,8]<0;1,0>:f               {A@1}
        mov (1|M0)               r6.3<1>:f     r[a0.0,12]<0;1,0>:f              {A@1}
        mov (1|M0)               r6.4<1>:f     r[a0.0,16]<0;1,0>:f              {A@1}
        mov (1|M0)               r6.5<1>:f     r[a0.0,20]<0;1,0>:f              {A@1}
        mov (1|M0)               r6.6<1>:f     r[a0.0,24]<0;1,0>:f              {A@1}
        mov (1|M0)               r6.7<1>:f     r[a0.0,28]<0;1,0>:f              {A@1}
        mov (1|M0)               r7.0<1>:f     r[a0.0,32]<0;1,0>:f              {A@1}
        mov (1|M0)               r7.1<1>:f     r[a0.0,36]<0;1,0>:f              {A@1}
        mov (1|M0)               r7.2<1>:f     r[a0.0,40]<0;1,0>:f              {A@1}
        mov (1|M0)               r7.3<1>:f     r[a0.0,44]<0;1,0>:f              {A@1}
        mov (1|M0)               r7.4<1>:f     r[a0.0,48]<0;1,0>:f              {A@1}
        mov (1|M0)               r7.5<1>:f     r[a0.0,52]<0;1,0>:f              {A@1}
        mov (1|M0)               r7.6<1>:f     r[a0.0,56]<0;1,0>:f              {A@1}
        mov (1|M0)               r7.7<1>:f     r[a0.0,60]<0;1,0>:f              {A@1}
        mov (1|M0)               r8.0<1>:f     r[a0.0,64]<0;1,0>:f              {A@1}
        mov (1|M0)               r8.1<1>:f     r[a0.0,68]<0;1,0>:f              {A@1}
        mov (1|M0)               r8.2<1>:f     r[a0.0,72]<0;1,0>:f              {A@1}
        mov (1|M0)               r8.3<1>:f     r[a0.0,76]<0;1,0>:f              {A@1}
        mov (1|M0)               r8.4<1>:f     r[a0.0,80]<0;1,0>:f              {A@1}
        mov (1|M0)               r8.5<1>:f     r[a0.0,84]<0;1,0>:f              {A@1}
        mov (1|M0)               r8.6<1>:f     r[a0.0,88]<0;1,0>:f              {A@1}
        mov (1|M0)               r8.7<1>:f     r[a0.0,92]<0;1,0>:f              {A@1}
        mov (1|M0)               r9.0<1>:f     r[a0.0,96]<0;1,0>:f              {A@1}
        mov (1|M0)               r9.1<1>:f     r[a0.0,100]<0;1,0>:f             {A@1}
        mov (1|M0)               r9.2<1>:f     r[a0.0,104]<0;1,0>:f             {A@1}
        mov (1|M0)               r9.3<1>:f     r[a0.0,108]<0;1,0>:f             {A@1}
        mov (1|M0)               r9.4<1>:f     r[a0.0,112]<0;1,0>:f             {A@1}
        mov (1|M0)               r9.5<1>:f     r[a0.0,116]<0;1,0>:f             {A@1}
        mov (1|M0)               r9.6<1>:f     r[a0.0,120]<0;1,0>:f             {A@1}
        mov (1|M0)               r9.7<1>:f     r[a0.0,124]<0;1,0>:f             {A@1}
        mov (1|M0)               r10.0<1>:f    r[a0.0,128]<0;1,0>:f             {A@1}
        mov (1|M0)               r10.1<1>:f    r[a0.0,132]<0;1,0>:f             {A@1}
        mov (1|M0)               r10.2<1>:f    r[a0.0,136]<0;1,0>:f             {A@1}
        mov (1|M0)               r10.3<1>:f    r[a0.0,140]<0;1,0>:f             {A@1}
        mov (1|M0)               r10.4<1>:f    r[a0.0,144]<0;1,0>:f             {A@1}
        mov (1|M0)               r10.5<1>:f    r[a0.0,148]<0;1,0>:f             {A@1}
        mov (1|M0)               r10.6<1>:f    r[a0.0,152]<0;1,0>:f             {A@1}
        mov (1|M0)               r10.7<1>:f    r[a0.0,156]<0;1,0>:f             {A@1}
        mov (1|M0)               r11.0<1>:f    r[a0.0,160]<0;1,0>:f             {A@1}
        mov (1|M0)               r11.1<1>:f    r[a0.0,164]<0;1,0>:f             {A@1}
        mov (1|M0)               r11.2<1>:f    r[a0.0,168]<0;1,0>:f             {A@1}
        mov (1|M0)               r11.3<1>:f    r[a0.0,172]<0;1,0>:f             {A@1}
        mov (1|M0)               r11.4<1>:f    r[a0.0,176]<0;1,0>:f             {A@1}
        mov (1|M0)               r11.5<1>:f    r[a0.0,180]<0;1,0>:f             {A@1}
        mov (1|M0)               r11.6<1>:f    r[a0.0,184]<0;1,0>:f             {A@1}
        mov (1|M0)               r11.7<1>:f    r[a0.0,188]<0;1,0>:f             {A@1}
        mov (1|M0)               r12.0<1>:f    r[a0.0,192]<0;1,0>:f             {A@1}
        mov (1|M0)               r12.1<1>:f    r[a0.0,196]<0;1,0>:f             {A@1}
        mov (1|M0)               r12.2<1>:f    r[a0.0,200]<0;1,0>:f             {A@1}
        mov (1|M0)               r12.3<1>:f    r[a0.0,204]<0;1,0>:f             {A@1}
        mov (1|M0)               r12.4<1>:f    r[a0.0,208]<0;1,0>:f             {A@1}
        mov (1|M0)               r12.5<1>:f    r[a0.0,212]<0;1,0>:f             {A@1}
        mov (1|M0)               r12.6<1>:f    r[a0.0,216]<0;1,0>:f             {A@1}
        mov (1|M0)               r12.7<1>:f    r[a0.0,220]<0;1,0>:f             {A@1}
        mov (1|M0)               r13.0<1>:f    r[a0.0,224]<0;1,0>:f             {A@1}
        mov (1|M0)               r13.1<1>:f    r[a0.0,228]<0;1,0>:f             {A@1}
        mov (1|M0)               r13.2<1>:f    r[a0.0,232]<0;1,0>:f             {A@1}
        mov (1|M0)               r13.3<1>:f    r[a0.0,236]<0;1,0>:f             {A@1}
        mov (1|M0)               r13.4<1>:f    r[a0.0,240]<0;1,0>:f             {A@1}
        mov (1|M0)               r13.5<1>:f    r[a0.0,244]<0;1,0>:f             {A@1}
        mov (1|M0)               r13.6<1>:f    r[a0.0,248]<0;1,0>:f             {A@1}
        mov (1|M0)               r13.7<1>:f    r[a0.0,252]<0;1,0>:f             {A@1}
L17008:
        sync.nop                             null                             {Compacted,$15.src}
        shl (1|M0)               r14.0<1>:w    r5.14<0;1,0>:w    5:w               {I@1}
        add (1|M0)               a0.0<1>:uw    r14.0<0;1,0>:uw   0xC0:uw              {A@1}
        or (1|M0)                r14.0<1>:ud   r5.7<0;1,0>:ud    r5.6<0;1,0>:ud  
        shl (1|M0)               r14.0<1>:ud   r14.0<0;1,0>:ud   0x6:uw              {I@1}
        mov (8|M0)               r15.0<1>:ud   r[a0.0]<1;1,0>:ud                {A@1}
        or (1|M0)                r16.0<1>:d    r14.0<0;1,0>:d    r14.3<0;1,0>:d   {Compacted,A@1}
        or (1|M0)                r14.6<1>:d    r14.0<0;1,0>:d    r14.3<0;1,0>:d  
        shr (1|M0)               r14.0<1>:ud   r16.0<0;1,0>:ud   0x1E:uw              {I@2}
        shl (1|M0)               r16.0<1>:d    r16.0<0;1,0>:d    2:w               {Compacted}
        or (1|M0)                r16.1<1>:d    r14.0<0;1,0>:d    0:w               {Compacted,I@2}
        addc (1|M0)              r14.0<1>:ud   r3.6<0;1,0>:ud    r16.0<0;1,0>:ud  {AccWrEn,I@2}
        or (1|M0)                r16.0<1>:d    r14.6<0;1,0>:d    1:w               {Compacted}
        mov (1|M0)               r17.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        add3 (1|M0)              r14.1<1>:d    r17.0<0;0>:d      r3.7<0;0>:d       r16.1<0>:d       {I@1}
        send.ugm (1|M0)          r14      r14     null:0  0x0            0x04100580           {A@1,$6} // wr:2+0, rd:1; load.ugm.d32.a64
        add (1|M0)               r14.0<1>:f    r14.0<0;1,0>:f    r[a0.0]<0;1,0>:f {$6.dst}
        mov (1|M0)               r14.2<2>:hf   r14.0<0;1,0>:f                   {A@1}
        mad (1|M0)               r14.2<1>:hf   r2.9<0;0>:hf      r2.15<0;0>:hf     r14.2<0>:hf      {F@1}
        cmp (1|M0)    (lt)f0.0   null<1>:hf    r14.2<0;1,0>:hf   1.03125:hf              {F@1}
        sel (1|M0)    (lt)f0.0   r14.0<1>:hf   r14.2<0;1,0>:hf   0x3E47:hf             
(f0.0)  mov (1|M0)               r14.0<1>:hf   1.03125:hf                             
        mov (1|M0)               r14.0<2>:uw   r14.0<0;1,0>:hf                  {F@1}
        shl (1|M0)               r14.0<1>:uw   r14.0<0;1,0>:uw   0x5:uw              {Compacted,I@1}
        xor (1|M0)               r14.0<1>:uw   r14.0<0;1,0>:uw   0x8000:uw              {I@1}
        mov (1|M0)               r15.0<1>:f    r14.0<0;1,0>:uw                  {Compacted,I@1}
        shr (1|M0)               r14.0<1>:ud   r16.0<0;1,0>:ud   0x1E:uw              {F@1}
        shl (1|M0)               r16.0<1>:d    r16.0<0;1,0>:d    2:w               {Compacted}
        or (1|M0)                r16.1<1>:d    r14.0<0;1,0>:d    0:w               {Compacted,I@2}
        addc (1|M0)              r14.0<1>:ud   r3.6<0;1,0>:ud    r16.0<0;1,0>:ud  {AccWrEn,I@2}
        or (1|M0)                r16.0<1>:d    r14.6<0;1,0>:d    2:w               {Compacted}
        mov (1|M0)               r17.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        add3 (1|M0)              r14.1<1>:d    r17.0<0;0>:d      r3.7<0;0>:d       r16.1<0>:d       {I@1}
        send.ugm (1|M0)          r14      r14     null:0  0x0            0x04100580           {A@1,$8} // wr:2+0, rd:1; load.ugm.d32.a64
        add (1|M0)               r14.0<1>:f    r14.0<0;1,0>:f    r15.1<0;1,0>:f   {Compacted,$8.dst}
        mov (1|M0)               r14.2<2>:hf   r14.0<0;1,0>:f                   {F@1}
        mad (1|M0)               r14.2<1>:hf   r2.9<0;0>:hf      r2.15<0;0>:hf     r14.2<0>:hf      {F@1}
        cmp (1|M0)    (lt)f0.0   null<1>:hf    r14.2<0;1,0>:hf   1.03125:hf              {F@1}
        sel (1|M0)    (lt)f0.0   r14.0<1>:hf   r14.2<0;1,0>:hf   0x3E47:hf             
(f0.0)  mov (1|M0)               r14.0<1>:hf   1.03125:hf                             
        mov (1|M0)               r14.0<2>:uw   r14.0<0;1,0>:hf                  {F@1}
        shl (1|M0)               r14.0<1>:uw   r14.0<0;1,0>:uw   0x5:uw              {Compacted,I@1}
        xor (1|M0)               r14.0<1>:uw   r14.0<0;1,0>:uw   0x8000:uw              {I@1}
        mov (1|M0)               r15.1<1>:f    r14.0<0;1,0>:uw                  {Compacted,I@1}
        shr (1|M0)               r14.0<1>:ud   r16.0<0;1,0>:ud   0x1E:uw              {F@1}
        shl (1|M0)               r16.0<1>:d    r16.0<0;1,0>:d    2:w               {Compacted}
        or (1|M0)                r16.1<1>:d    r14.0<0;1,0>:d    0:w               {Compacted,I@2}
        addc (1|M0)              r14.0<1>:ud   r3.6<0;1,0>:ud    r16.0<0;1,0>:ud  {AccWrEn,I@2}
        or (1|M0)                r16.0<1>:d    r14.6<0;1,0>:d    3:w               {Compacted}
        mov (1|M0)               r17.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        add3 (1|M0)              r14.1<1>:d    r17.0<0;0>:d      r3.7<0;0>:d       r16.1<0>:d       {I@1}
        send.ugm (1|M0)          r14      r14     null:0  0x0            0x04100580           {A@1,$10} // wr:2+0, rd:1; load.ugm.d32.a64
        add (1|M0)               r14.0<1>:f    r14.0<0;1,0>:f    r15.2<0;1,0>:f   {Compacted,$10.dst}
        mov (1|M0)               r14.2<2>:hf   r14.0<0;1,0>:f                   {F@1}
        mad (1|M0)               r14.2<1>:hf   r2.9<0;0>:hf      r2.15<0;0>:hf     r14.2<0>:hf      {F@1}
        cmp (1|M0)    (lt)f0.0   null<1>:hf    r14.2<0;1,0>:hf   1.03125:hf              {F@1}
        sel (1|M0)    (lt)f0.0   r14.0<1>:hf   r14.2<0;1,0>:hf   0x3E47:hf             
(f0.0)  mov (1|M0)               r14.0<1>:hf   1.03125:hf                             
        mov (1|M0)               r14.0<2>:uw   r14.0<0;1,0>:hf                  {F@1}
        shl (1|M0)               r14.0<1>:uw   r14.0<0;1,0>:uw   0x5:uw              {Compacted,I@1}
        xor (1|M0)               r14.0<1>:uw   r14.0<0;1,0>:uw   0x8000:uw              {I@1}
        mov (1|M0)               r15.2<1>:f    r14.0<0;1,0>:uw                  {Compacted,I@1}
        shr (1|M0)               r14.0<1>:ud   r16.0<0;1,0>:ud   0x1E:uw              {F@1}
        shl (1|M0)               r16.0<1>:d    r16.0<0;1,0>:d    2:w               {Compacted}
        or (1|M0)                r16.1<1>:d    r14.0<0;1,0>:d    0:w               {Compacted,I@2}
        addc (1|M0)              r14.0<1>:ud   r3.6<0;1,0>:ud    r16.0<0;1,0>:ud  {AccWrEn,I@2}
        or (1|M0)                r16.0<1>:d    r14.6<0;1,0>:d    4:w               {Compacted}
        mov (1|M0)               r17.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        add3 (1|M0)              r14.1<1>:d    r17.0<0;0>:d      r3.7<0;0>:d       r16.1<0>:d       {I@1}
        send.ugm (1|M0)          r14      r14     null:0  0x0            0x04100580           {A@1,$11} // wr:2+0, rd:1; load.ugm.d32.a64
        add (1|M0)               r14.0<1>:f    r14.0<0;1,0>:f    r15.3<0;1,0>:f   {Compacted,$11.dst}
        mov (1|M0)               r14.2<2>:hf   r14.0<0;1,0>:f                   {F@1}
        mad (1|M0)               r14.2<1>:hf   r2.9<0;0>:hf      r2.15<0;0>:hf     r14.2<0>:hf      {F@1}
        cmp (1|M0)    (lt)f0.0   null<1>:hf    r14.2<0;1,0>:hf   1.03125:hf              {F@1}
        sel (1|M0)    (lt)f0.0   r14.0<1>:hf   r14.2<0;1,0>:hf   0x3E47:hf             
(f0.0)  mov (1|M0)               r14.0<1>:hf   1.03125:hf                             
        mov (1|M0)               r14.0<2>:uw   r14.0<0;1,0>:hf                  {F@1}
        shl (1|M0)               r14.0<1>:uw   r14.0<0;1,0>:uw   0x5:uw              {Compacted,I@1}
        xor (1|M0)               r14.0<1>:uw   r14.0<0;1,0>:uw   0x8000:uw              {I@1}
        mov (1|M0)               r15.3<1>:f    r14.0<0;1,0>:uw                  {Compacted,I@1}
        shr (1|M0)               r14.0<1>:ud   r16.0<0;1,0>:ud   0x1E:uw              {F@1}
        shl (1|M0)               r16.0<1>:d    r16.0<0;1,0>:d    2:w               {Compacted}
        or (1|M0)                r16.1<1>:d    r14.0<0;1,0>:d    0:w               {Compacted,I@2}
        addc (1|M0)              r14.0<1>:ud   r3.6<0;1,0>:ud    r16.0<0;1,0>:ud  {AccWrEn,I@2}
        or (1|M0)                r16.0<1>:d    r14.6<0;1,0>:d    5:w               {Compacted}
        mov (1|M0)               r17.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        add3 (1|M0)              r14.1<1>:d    r17.0<0;0>:d      r3.7<0;0>:d       r16.1<0>:d       {I@1}
        send.ugm (1|M0)          r14      r14     null:0  0x0            0x04100580           {A@1,$13} // wr:2+0, rd:1; load.ugm.d32.a64
        add (1|M0)               r14.0<1>:f    r14.0<0;1,0>:f    r15.4<0;1,0>:f   {Compacted,$13.dst}
        mov (1|M0)               r14.2<2>:hf   r14.0<0;1,0>:f                   {F@1}
        mad (1|M0)               r14.2<1>:hf   r2.9<0;0>:hf      r2.15<0;0>:hf     r14.2<0>:hf      {F@1}
        cmp (1|M0)    (lt)f0.0   null<1>:hf    r14.2<0;1,0>:hf   1.03125:hf              {F@1}
        sel (1|M0)    (lt)f0.0   r14.0<1>:hf   r14.2<0;1,0>:hf   0x3E47:hf             
(f0.0)  mov (1|M0)               r14.0<1>:hf   1.03125:hf                             
        mov (1|M0)               r14.0<2>:uw   r14.0<0;1,0>:hf                  {F@1}
        shl (1|M0)               r14.0<1>:uw   r14.0<0;1,0>:uw   0x5:uw              {Compacted,I@1}
        xor (1|M0)               r14.0<1>:uw   r14.0<0;1,0>:uw   0x8000:uw              {I@1}
        mov (1|M0)               r15.4<1>:f    r14.0<0;1,0>:uw                  {Compacted,I@1}
        shr (1|M0)               r14.0<1>:ud   r16.0<0;1,0>:ud   0x1E:uw              {F@1}
        shl (1|M0)               r16.0<1>:d    r16.0<0;1,0>:d    2:w               {Compacted}
        or (1|M0)                r16.1<1>:d    r14.0<0;1,0>:d    0:w               {Compacted,I@2}
        addc (1|M0)              r14.0<1>:ud   r3.6<0;1,0>:ud    r16.0<0;1,0>:ud  {AccWrEn,I@2}
        or (1|M0)                r16.0<1>:d    r14.6<0;1,0>:d    6:w               {Compacted}
        mov (1|M0)               r17.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        add3 (1|M0)              r14.1<1>:d    r17.0<0;0>:d      r3.7<0;0>:d       r16.1<0>:d       {I@1}
        send.ugm (1|M0)          r14      r14     null:0  0x0            0x04100580           {A@1,$14} // wr:2+0, rd:1; load.ugm.d32.a64
        add (1|M0)               r14.0<1>:f    r14.0<0;1,0>:f    r15.5<0;1,0>:f   {Compacted,$14.dst}
        mov (1|M0)               r14.2<2>:hf   r14.0<0;1,0>:f                   {F@1}
        mad (1|M0)               r14.2<1>:hf   r2.9<0;0>:hf      r2.15<0;0>:hf     r14.2<0>:hf      {F@1}
        cmp (1|M0)    (lt)f0.0   null<1>:hf    r14.2<0;1,0>:hf   1.03125:hf              {F@1}
        sel (1|M0)    (lt)f0.0   r14.0<1>:hf   r14.2<0;1,0>:hf   0x3E47:hf             
(f0.0)  mov (1|M0)               r14.0<1>:hf   1.03125:hf                             
        mov (1|M0)               r14.0<2>:uw   r14.0<0;1,0>:hf                  {F@1}
        shl (1|M0)               r14.0<1>:uw   r14.0<0;1,0>:uw   0x5:uw              {Compacted,I@1}
        xor (1|M0)               r14.0<1>:uw   r14.0<0;1,0>:uw   0x8000:uw              {I@1}
        mov (1|M0)               r15.5<1>:f    r14.0<0;1,0>:uw                  {Compacted,I@1}
        shr (1|M0)               r14.0<1>:ud   r16.0<0;1,0>:ud   0x1E:uw              {F@1}
        shl (1|M0)               r16.0<1>:d    r16.0<0;1,0>:d    2:w               {Compacted}
        or (1|M0)                r16.1<1>:d    r14.0<0;1,0>:d    0:w               {Compacted,I@2}
        addc (1|M0)              r14.0<1>:ud   r3.6<0;1,0>:ud    r16.0<0;1,0>:ud  {AccWrEn,I@2}
        mov (1|M0)               r17.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        add3 (1|M0)              r14.1<1>:d    r17.0<0;0>:d      r3.7<0;0>:d       r16.1<0>:d       {I@1}
        send.ugm (1|M0)          r14      r14     null:0  0x0            0x04100580           {A@1,$1} // wr:2+0, rd:1; load.ugm.d32.a64
        add (1|M0)               r14.0<1>:f    r14.0<0;1,0>:f    r15.6<0;1,0>:f   {Compacted,$1.dst}
        mov (1|M0)               r14.2<2>:hf   r14.0<0;1,0>:f                   {F@1}
        mad (1|M0)               r14.2<1>:hf   r2.9<0;0>:hf      r2.15<0;0>:hf     r14.2<0>:hf      {F@1}
        cmp (1|M0)    (lt)f0.0   null<1>:hf    r14.2<0;1,0>:hf   1.03125:hf              {F@1}
        sel (1|M0)    (lt)f0.0   r14.0<1>:hf   r14.2<0;1,0>:hf   0x3E47:hf             
(f0.0)  mov (1|M0)               r14.0<1>:hf   1.03125:hf                             
        mov (1|M0)               r14.0<2>:uw   r14.0<0;1,0>:hf                  {F@1}
        shl (1|M0)               r14.0<1>:uw   r14.0<0;1,0>:uw   0x5:uw              {Compacted,I@1}
        xor (1|M0)               r14.0<1>:uw   r14.0<0;1,0>:uw   0x8000:uw              {I@1}
        mov (1|M0)               r15.6<1>:f    r14.0<0;1,0>:uw                  {Compacted,I@1}
        or (1|M0)                r14.0<1>:d    r14.6<0;1,0>:d    7:w               {Compacted,F@1}
        shl (1|M0)               r14.6<1>:d    r14.0<0;1,0>:d    2:w               {Compacted,I@1}
        shr (1|M0)               r16.0<1>:ud   r14.0<0;1,0>:ud   0x1E:uw             
        addc (1|M0)              r17.0<1>:ud   r3.6<0;1,0>:ud    r14.6<0;1,0>:ud  {AccWrEn,I@2}
        or (1|M0)                r14.7<1>:d    r16.0<0;1,0>:d    0:w               {Compacted,I@2}
        mov (1|M0)               r16.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r14.0<1>:f    r17.0<0;1,0>:f                   {Compacted,I@3}
        add3 (1|M0)              r14.1<1>:d    r16.0<0;0>:d      r3.7<0;0>:d       r14.7<0>:d       {I@1}
        send.ugm (1|M0)          r14      r14     null:0  0x0            0x04100580           {A@1,$3} // wr:2+0, rd:1; load.ugm.d32.a64
        add (1|M0)               r14.0<1>:f    r14.0<0;1,0>:f    r15.7<0;1,0>:f   {Compacted,$3.dst}
        mov (1|M0)               r14.2<2>:hf   r14.0<0;1,0>:f                   {F@1}
        mad (1|M0)               r14.2<1>:hf   r2.9<0;0>:hf      r2.15<0;0>:hf     r14.2<0>:hf      {F@1}
        cmp (1|M0)    (lt)f0.0   null<1>:hf    r14.2<0;1,0>:hf   1.03125:hf              {F@1}
        sel (1|M0)    (lt)f0.0   r14.0<1>:hf   r14.2<0;1,0>:hf   0x3E47:hf             
(f0.0)  mov (1|M0)               r14.0<1>:hf   1.03125:hf                             
        mov (1|M0)               r14.0<2>:uw   r14.0<0;1,0>:hf                  {F@1}
        shl (1|M0)               r14.0<1>:uw   r14.0<0;1,0>:uw   0x5:uw              {Compacted,I@1}
        xor (1|M0)               r14.0<1>:uw   r14.0<0;1,0>:uw   0x8000:uw              {I@1}
        mov (1|M0)               r15.7<1>:f    r14.0<0;1,0>:uw                  {Compacted,I@1}
        shl (1|M0)               r14.0<1>:ud   r5.7<0;1,0>:ud    0x8:uw              {F@1}
        add (1|M0)               r5.7<1>:ud    r5.7<0;1,0>:ud    0x1:uw             
        add (1|M0)               r14.0<1>:ud   r14.0<0;1,0>:ud   0x7200:uw              {I@2}
        cmp (1|M0)    (eq)f0.0   null<1>:d     r5.7<0;1,0>:d     8:w               {I@2}
        or (1|M0)                r14.0<1>:d    r14.0<0;1,0>:d    r14.2<0;1,0>:d   {Compacted,I@2}
        send.slm (1|M0)          null     r14     r15:1   0x0            0x0200B704           {A@1,$15} // wr:1+1, rd:0; store.slm.d64x4t.a32
(W)     and (1|M0)               f0.0<1>:ud    f0.0<0;1,0>:uw    0x1:uw             
(~f0.0.any32h) goto.b (32|M0)                L19104                  L17008                
L19104:
        join (32|M0)                         L19272                                
L19120:
        addc (1|M0)              r6.0<1>:ud    r14.4<0;1,0>:ud   0x1:ud              {AccWrEn}
        mov (1|M0)               r14.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,$15.src}
        mov (1|M0)               r14.2<1>:d    r6.0<0;1,0>:d                    {I@2}
        add3 (1|M0)              r14.3<1>:d    r14.0<0;0>:d      r14.5<0;0>:d      0:w               {I@2}
        cmp (1|M0)    (eq)f0.0   null<1>:d     r14.3<0;1,0>:d    0:w               {I@1}
(f0.0)  cmp (1|M0)    (eq)f0.0   null<1>:d     r14.2<0;1,0>:d    8:w              
(W)     and (1|M0)               f0.0<1>:ud    f0.0<0;1,0>:uw    0x1:uw             
(f0.0.any32h) goto (32|M0)                   L19272                  L19272                
L19240:
(W)     mov (2|M0)               r14.4<1>:ud   r14.2<1;1,0>:ud                 
        goto.b (32|M0)                       L19272                  L15872                
L19272:
        join (32|M0)                         L21424                                
L19288:
(W)     send.slm (1|M0)          r6       r0      null:0  0x0            0x0210001F           {$6} // wr:1+0, rd:1; fence.slm.none.group
(W)     mov (8|M0)               null<1>:ud    r6.0<1;1,0>:ud                   {$6.dst}
(W)     mov (1|M0)               r6.2<1>:f     0.0:f                               {Compacted,I@1}
(W)     mov (2|M0)               r6.10<1>:ub   r0.11<0;1,0>:ub                  {F@1}
(W)     send.gtwy (1|M0)         null     r6      null:0  0x0            0x02000004           {A@1,$8} // wr:1+0, rd:0; signal barrier
(W)     sync.bar                             null                            
        mov (1|M0)               r6.4<1>:d     0:w                               {$8.src}
L19392:
        sync.nop                             null                             {Compacted,$10.src}
        shl (1|M0)               r6.5<1>:d     r6.4<0;1,0>:d     8:w               {I@1}
        mov (1|M0)               r6.2<2>:f     0.0:f                              
        mov (1|M0)               r6.3<2>:d     0:d                              
        mov (1|M0)               r6.1<1>:f     0.0:f                               {Compacted}
        add (1|M0)               r6.5<1>:d     r6.5<0;1,0>:d     29184:w               {I@2}
L19472:
        shl (1|M0)               r5.7<1>:d     r6.2<0;1,0>:d     5:w               {F@2}
        shl (1|M0)               r6.6<1>:d     r6.2<0;1,0>:d     3:w              
        or (1|M0)                r6.0<1>:d     r5.7<0;1,0>:d     r6.5<0;1,0>:d    {I@2}
        shl (1|M0)               r2.9<1>:w     r6.12<0;1,0>:w    2:w               {I@2}
        send.slm (1|M0)          r7       r6      null:0  0x0            0x0210B700           {A@1,$11} // wr:1+0, rd:1; load.slm.d64x4t.a32
        add (1|M0)               a0.0<1>:uw    r2.9<0;1,0>:uw    0xCC0:uw              {A@1}
        shl (1|M0)               r8.0<1>:d     r6.3<0;1,0>:d     3:w               {Compacted}
        shr (1|M0)               r5.7<1>:ud    r6.2<0;1,0>:ud    0x1D:uw             
        sync.nop                             null                             {Compacted,$11.src}
        or (1|M0)                r6.7<1>:d     r8.0<0;1,0>:d     r5.7<0;1,0>:d    {I@1}
        add (1|M0)               r6.1<1>:f     r6.1<0;1,0>:f     r7.0<0;1,0>:f    {Compacted,$11.dst}
        mov (1|M0)               r[a0.0]<1>:f  r7.0<0;1,0>:f                   
        addc (1|M0)              r7.0<1>:ud    r6.2<0;1,0>:ud    0x1:ud              {AccWrEn,F@1}
        add (1|M0)               r6.1<1>:f     r6.1<0;1,0>:f     r7.1<0;1,0>:f   
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r6.6<1>:d     r7.0<0;1,0>:d                    {I@2}
        add3 (1|M0)              r6.7<1>:d     r6.0<0;0>:d       r6.3<0;0>:d       0:w               {I@2}
        add (1|M0)               r6.1<1>:f     r6.1<0;1,0>:f     r7.2<0;1,0>:f    {F@1}
        cmp (1|M0)    (eq)f0.0   null<1>:d     r6.7<0;1,0>:d     0:w               {I@1}
        add (1|M0)               r6.1<1>:f     r6.1<0;1,0>:f     r7.3<0;1,0>:f    {F@1}
        mov (1|M0)               r[a0.0,4]<1>:f  r7.1<0;1,0>:f                 
        add (1|M0)               r6.1<1>:f     r6.1<0;1,0>:f     r7.4<0;1,0>:f    {F@2}
(f0.0)  cmp (1|M0)    (eq)f0.0   null<1>:d     r6.6<0;1,0>:d     8:w              
        add (1|M0)               r6.1<1>:f     r6.1<0;1,0>:f     r7.5<0;1,0>:f    {F@1}
        mov (1|M0)               r[a0.0,8]<1>:f  r7.2<0;1,0>:f                 
        add (1|M0)               r6.1<1>:f     r6.1<0;1,0>:f     r7.6<0;1,0>:f    {F@2}
(W)     and (1|M0)               f0.0<1>:ud    f0.0<0;1,0>:uw    0x1:uw             
        mov (1|M0)               r[a0.0,12]<1>:f  r7.3<0;1,0>:f                
        add (1|M0)               r6.1<1>:f     r6.1<0;1,0>:f     r7.7<0;1,0>:f    {F@2}
        mov (1|M0)               r[a0.0,16]<1>:f  r7.4<0;1,0>:f                
        mov (1|M0)               r[a0.0,20]<1>:f  r7.5<0;1,0>:f                
        mov (1|M0)               r[a0.0,24]<1>:f  r7.6<0;1,0>:f                
        mov (1|M0)               r[a0.0,28]<1>:f  r7.7<0;1,0>:f                
(f0.0.any32h) goto (32|M0)                   L20016                  L20016                
L19984:
(W)     mov (2|M0)               r6.2<1>:ud    r6.6<1;1,0>:ud                  
        goto.b (32|M0)                       L20016                  L19472                
L20016:
        join (32|M0)                         L21024                                
L20032:
        mov (1|M0)               r5.14<2>:hf   r6.1<0;1,0>:f                    {F@5}
        sync.nop                             null                             {Compacted,A@1}
        math.inv (8|M0)          r6.0<1>:hf    r5.14<0;1,0>:hf                  {$13}
        mov (1|M0)               r5.14<1>:hf   r6.0<0;1,0>:hf                   {$13.dst}
        mov (1|M0)               r6.2<2>:f     0.0:f                              
        mov (1|M0)               r6.3<2>:f     0.0:f                              
        mov (1|M0)               r6.0<1>:d     0:w                               {F@3}
        mov (1|M0)               r6.1<1>:f     r5.14<0;1,0>:hf                 
L20152:
        shl (1|M0)               r2.9<1>:w     r6.4<0;1,0>:w     2:w               {F@3}
        add (1|M0)               a0.0<1>:uw    r2.9<0;1,0>:uw    0xCC0:uw              {A@1}
        mul (1|M0)               r6.6<1>:f     r[a0.0]<0;1,0>:f  r6.1<0;1,0>:f    {F@1}
        mov (1|M0)               r5.14<2>:hf   r6.6<0;1,0>:f                    {A@1}
        cmp (1|M0)    (lt)f1.1   null<1>:f     r6.6<0;1,0>:f     0xB3000000:f              
        mov (1|M0)               r6.5<1>:f     r5.14<0;1,0>:hf                  {F@2}
(f1.1)  mov (1|M0)               r6.5<1>:f     -r6.5<0;1,0>:f                   {F@1}
        sel (1|M0)    (lt)f0.0   r6.5<1>:f     r6.5<0;1,0>:f     448.0:f               {F@1}
        shr (1|M0)               r6.6<1>:ud    r6.5<0;1,0>:ud    0x17:uw              {F@1}
        and (1|M0)               r6.6<1>:ud    r6.6<0;1,0>:ud    0xFF:uw              {I@1}
        sel (1|M0)    (ge)f0.0   r6.6<1>:ud    r6.6<0;1,0>:ud    0x79:uw              {I@1}
        shl (1|M0)               r6.6<1>:ud    r6.6<0;1,0>:ud    0x17:uw              {I@1}
        add (1|M0)               r7.0<1>:ud    -r6.6<0;1,0>:ud   0x80800000:ud              {I@1}
        mul (1|M0)               r5.7<1>:f     r6.5<0;1,0>:f     r7.0<0;1,0>:f    {I@1}
        mov (1|M0)               r6.7<1>:d     r5.7<0;1,0>:f                    {F@1}
        mov (1|M0)               r5.7<1>:f     r6.7<0;1,0>:d                    {I@1}
        mad (1|M0)               r6.5<1>:f     -r5.7<0;0>:f      r7.0<0;0>:f       r6.5<0>:f        {F@1}
        cmp (1|M0)    (gt)f0.0   null<1>:f     r6.5<0;1,0>:f     0.5:f               {F@1}
(W)     and (1|M0)               f0.0<1>:ud    f0.0<0;1,0>:uw    0x1:uw              {F@1}
(f0.0.any32h) goto (32|M0)                   L20560                  L20560                
L20472:
        cmp (1|M0)    (lt)f0.0   null<1>:f     r6.5<0;1,0>:f     0.5:f               {A@1}
        and (1|M0)               r6.7<1>:d     r6.7<0;1,0>:d     1:w              
        add (1|M0)               r7.0<1>:f     r5.7<0;1,0>:f     1.0:f               {Compacted}
(~f0.0) cmp (1|M0)    (eq)f0.0   null<1>:d     r6.7<0;1,0>:d     0:w               {A@1}
(~f0.0) mov (1|M0)               r5.7<1>:f     r7.0<0;1,0>:f                    {F@1}
        goto (32|M0)                         L20560                  L20592                
L20560:
        join (32|M0)                         L20592                                
L20576:
        add (1|M0)               r5.7<1>:f     r5.7<0;1,0>:f     1.0:f               {F@1}
L20592:
        join (32|M0)                         L20880                                
L20608:
        addc (1|M0)              r8.0<1>:ud    r6.2<0;1,0>:ud    0x1:ud              {AccWrEn}
        add (1|M0)               r6.6<1>:ud    r6.6<0;1,0>:ud    0xFE800000:ud             
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mul (1|M0)               r5.7<1>:f     r5.7<0;1,0>:f     r6.6<0;1,0>:f    {A@1}
        add3 (1|M0)              r6.7<1>:d     r7.0<0;0>:d       r6.3<0;0>:d       0:w               {I@1}
        mov (1|M0)               r6.6<1>:d     r8.0<0;1,0>:d                    {F@1}
        cmp (1|M0)    (eq)f0.0   null<1>:d     r6.7<0;1,0>:d     0:w               {I@2}
(f1.1)  mov (1|M0)               r5.7<1>:f     -r5.7<0;1,0>:f                  
        shl (1|M0)               r2.9<1>:w     r6.0<0;1,0>:w     1:w              
(W)     mov (1|M0)               r5.14<2>:hf   r5.7<0;1,0>:f                    {F@1}
(f0.0)  cmp (1|M0)    (eq)f0.0   null<1>:d     r6.6<0;1,0>:d     64:w               {I@3}
        add (1|M0)               r6.0<1>:d     r6.0<0;1,0>:d     1:w               {Compacted}
        add (1|M0)               a0.0<1>:uw    r2.9<0;1,0>:uw    0xDC0:uw              {A@1}
        mov (1|M0)               r[a0.0]<1>:hf  r5.14<0;1,0>:hf                 {F@1}
(W)     and (1|M0)               f0.0<1>:ud    f0.0<0;1,0>:uw    0x1:uw             
(f0.0.any32h) goto (32|M0)                   L20880                  L20880                
L20848:
(W)     mov (2|M0)               r6.2<1>:ud    r6.6<1;1,0>:ud                  
        goto.b (32|M0)                       L20880                  L20152                
L20880:
        join (32|M0)                         L21024                                
L20896:
        or (1|M0)                r5.7<1>:d     r6.4<0;1,0>:d     r5.6<0;1,0>:d    {F@1}
        add (1|M0)               r6.4<1>:d     r6.4<0;1,0>:d     1:w              
        shl (1|M0)               r5.7<1>:d     r5.7<0;1,0>:d     7:w               {I@2}
        cmp (1|M0)    (eq)f0.0   null<1>:d     r6.4<0;1,0>:d     8:w               {I@2}
        add (1|M0)               r6.0<1>:d     r5.7<0;1,0>:d     12288:w               {I@2}
        send.slm (1|M0)          null     r6      r110:4  0x0            0x0200D704           {A@1,$10} // wr:1+4, rd:0; store.slm.d64x16t.a32
(W)     and (1|M0)               f0.0<1>:ud    f0.0<0;1,0>:uw    0x1:uw             
(~f0.0.any32h) goto.b (32|M0)                L21024                  L19392                
L21024:
        join (32|M0)                         L21424                                
L21040:
        sync.nop                             null                             {Compacted,$10.src}
(W)     send.slm (1|M0)          r6       r0      null:0  0x0            0x0210001F           {$14} // wr:1+0, rd:1; fence.slm.none.group
(W)     mov (8|M0)               null<1>:ud    r6.0<1;1,0>:ud                   {$14.dst}
(W)     mov (1|M0)               r6.2<1>:f     0.0:f                               {Compacted,I@1}
(W)     mov (2|M0)               r6.10<1>:ub   r0.11<0;1,0>:ub                  {F@1}
        cmp (1|M0)    (ne)f0.0   null<1>:d     r4.0<0;1,0>:d     4:w              
(W)     send.gtwy (1|M0)         null     r6      null:0  0x0            0x02000004           {A@2,$0} // wr:1+0, rd:0; signal barrier
(W)     sync.bar                             null                            
(W)     mov (1|M0)               r2.15<1>:hf   0x1:hf                             
(f0.0)  sel (1|M0)               r2.9<1>:uw    r2.15<0;1,0>:uw   0x0:uw              {F@1}
(f1.0)  sel (1|M0)               r5.3<1>:uw    r2.15<0;1,0>:uw   0x0:uw             
        xor (1|M0)    (ne)f0.1   null<1>:uw    r2.9<0;1,0>:uw    0x1:uw              {I@2}
(f0.1)  sel (1|M0)               r2.9<1>:uw    r2.15<0;1,0>:uw   0x0:uw             
        and (1|M0)    (ne)f0.1   null<1>:uw    r5.3<0;1,0>:uw    r2.9<0;1,0>:uw   {I@1}
(f0.0)  sel (1|M0)               r5.3<1>:uw    r2.15<0;1,0>:uw   0x0:uw             
(f0.1)  sel (1|M0)               r2.9<1>:uw    r2.15<0;1,0>:uw   0x0:uw             
        or (1|M0)     (ne)f0.0   null<1>:uw    r5.3<0;1,0>:uw    r2.9<0;1,0>:uw   {I@1}
(W)     and (1|M0)               f0.0<1>:ud    f0.0<0;1,0>:uw    0x1:uw             
(~f0.0.any32h) goto (32|M0)                  L21424                  L21424                
L21328:
        cmp (1|M0)    (gt)f0.0   null<1>:ud    r5.6<0;1,0>:ud    0x37:uw             
        add (1|M0)               r5.7<1>:d     r5.6<0;1,0>:d     8:w              
(W)     and (1|M0)               f0.0<1>:ud    f0.0<0;1,0>:uw    0x1:uw             
(f0.0.any32h) goto (32|M0)                   L21424                  L23016                
L21392:
        mov (1|M0)               r5.6<1>:d     r5.7<0;1,0>:d                    {I@3}
        goto.b (32|M0)                       L21424                  L9600                
L21424:
        join (32|M0)                         L23016                                
L21440:
        shl (1|M0)               r1.4<1>:d     r2.3<0;1,0>:d     12:w              
        shr (1|M0)               r1.3<1>:ud    r2.2<0;1,0>:ud    0x14:uw             
        shl (1|M0)               r1.0<1>:d     r2.2<0;1,0>:d     12:w               {Compacted}
        or (1|M0)                r1.1<1>:d     r1.4<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        shr (1|M0)               r1.3<1>:ud    r1.0<0;1,0>:ud    0x1F:uw              {I@2}
        shl (1|M0)               r1.0<1>:d     r1.0<0;1,0>:d     1:w               {Compacted}
        shl (1|M0)               r1.4<1>:d     r1.1<0;1,0>:d     1:w               {I@3}
        addc (1|M0)              r2.0<1>:ud    r4.2<0;1,0>:ud    r1.0<0;1,0>:ud   {AccWrEn,I@2}
        or (1|M0)                r1.1<1>:d     r1.4<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        mov (1|M0)               r4.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r1.6<2>:f     0.0:f                              
        mov (1|M0)               r1.7<2>:f     0.0:f                              
        mov (1|M0)               r1.3<1>:d     r2.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r1.4<1>:d     r4.0<0;0>:d       r4.3<0;0>:d       r1.1<0>:d        {I@2}
L21640:
        shl (1|M0)               r2.3<1>:d     r1.7<0;1,0>:d     6:w               {F@1}
        shr (1|M0)               r2.2<1>:ud    r1.6<0;1,0>:ud    0x1A:uw             
        shl (1|M0)               r2.0<1>:d     r1.6<0;1,0>:d     6:w               {Compacted}
        or (1|M0)                r2.1<1>:d     r2.3<0;1,0>:d     r2.2<0;1,0>:d    {I@2}
        shl (1|M0)               r2.3<1>:d     r2.0<0;1,0>:d     1:w               {Compacted,I@2}
        shr (1|M0)               r2.2<1>:ud    r2.0<0;1,0>:ud    0x1F:uw             
        shl (1|M0)               r2.5<1>:d     r2.1<0;1,0>:d     1:w               {I@3}
        addc (1|M0)              r3.0<1>:ud    r1.3<0;1,0>:ud    r2.3<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r2.4<1>:d     r2.5<0;1,0>:d     r2.2<0;1,0>:d    {I@2}
        shl (1|M0)               r2.3<1>:d     r1.6<0;1,0>:d     8:w              
        mov (1|M0)               r2.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r2.1<1>:d     r3.0<0;1,0>:d                    {I@4}
        mov (1|M0)               r2.5<2>:f     0.0:f                               {I@4}
        add (1|M0)               r2.3<1>:d     r2.3<0;1,0>:d     29184:w               {I@3}
        add3 (1|M0)              r2.2<1>:d     r2.0<0;0>:d       r1.4<0;0>:d       r2.4<0>:d        {I@3}
        mov (1|M0)               r2.4<2>:f     0.0:f                               {I@1}
L21872:
        shl (1|M0)               r1.0<1>:d     r2.4<0;1,0>:d     5:w               {Compacted,F@1}
        shl (1|M0)               r4.1<1>:d     r2.5<0;1,0>:d     3:w              
        or (1|M0)                r1.0<1>:d     r1.0<0;1,0>:d     r2.3<0;1,0>:d    {Compacted,I@2}
        shr (1|M0)               r4.0<1>:ud    r2.4<0;1,0>:ud    0x1D:uw             
        send.slm (1|M0)          r3       r1      null:0  0x0            0x0210B700           {A@2,$1} // wr:1+0, rd:1; load.slm.d64x4t.a32
        shl (1|M0)               r2.6<1>:d     r2.4<0;1,0>:d     3:w              
        or (1|M0)                r2.7<1>:d     r4.1<0;1,0>:d     r4.0<0;1,0>:d    {I@2}
        shr (1|M0)               r4.0<1>:ud    r2.6<0;1,0>:ud    0x1F:uw              {I@2}
        shl (1|M0)               r4.1<1>:d     r2.7<0;1,0>:d     1:w               {I@2}
        shl (1|M0)               r2.6<1>:d     r2.6<0;1,0>:d     1:w              
        or (1|M0)                r2.7<1>:d     r4.1<0;1,0>:d     r4.0<0;1,0>:d    {I@2}
        addc (1|M0)              r4.0<1>:ud    r2.1<0;1,0>:ud    r2.6<0;1,0>:ud   {AccWrEn,I@2}
        mov (8|M0)               r4.8<1>:hf    r3.0<1;1,0>:f                    {$1.dst}
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r2.0<1>:d     r4.8<0;1,0>:uw                   {F@1}
        add3 (1|M0)              r4.1<1>:d     r5.0<0;0>:d       r2.2<0;0>:d       r2.7<0>:d        {I@2}
        addc (1|M0)              r3.0<1>:ud    r4.0<0;1,0>:ud    0x2:ud              {AccWrEn}
        send.ugm (1|M0)          null     r4      r2:1    0x0            0x04000B84           {A@2,$3} // wr:2+1, rd:0; store.ugm.d16u32.a64
        mov (1|M0)               r2.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$3.src}
        sync.allrd                           ($0,$4,$7,$9,$10,$12)                
        mov (1|M0)               r6.0<1>:f     r3.0<0;1,0>:f                    {Compacted,I@2}
        add3 (1|M0)              r6.1<1>:d     r2.0<0;0>:d       r4.1<0;0>:d       0:w               {I@1}
        addc (1|M0)              r3.0<1>:ud    r4.0<0;1,0>:ud    0x4:ud              {AccWrEn,F@1}
        mov (1|M0)               r2.0<1>:d     r4.9<0;1,0>:uw                  
        send.ugm (1|M0)          null     r6      r2:1    0x0            0x04000B84           {A@1,$6} // wr:2+1, rd:0; store.ugm.d16u32.a64
        mov (1|M0)               r2.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$6.src}
        mov (1|M0)               r6.0<1>:f     r3.0<0;1,0>:f                    {Compacted}
        add3 (1|M0)              r6.1<1>:d     r2.0<0;0>:d       r4.1<0;0>:d       0:w               {I@1}
        addc (1|M0)              r3.0<1>:ud    r4.0<0;1,0>:ud    0x6:ud              {AccWrEn,F@1}
        mov (1|M0)               r2.0<1>:d     r4.10<0;1,0>:uw                 
        send.ugm (1|M0)          null     r6      r2:1    0x0            0x04000B84           {A@1,$8} // wr:2+1, rd:0; store.ugm.d16u32.a64
        mov (1|M0)               r2.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$8.src}
        mov (1|M0)               r6.0<1>:f     r3.0<0;1,0>:f                    {Compacted}
        add3 (1|M0)              r6.1<1>:d     r2.0<0;0>:d       r4.1<0;0>:d       0:w               {I@1}
        addc (1|M0)              r3.0<1>:ud    r4.0<0;1,0>:ud    0x8:ud              {AccWrEn,F@1}
        mov (1|M0)               r2.0<1>:d     r4.11<0;1,0>:uw                 
        send.ugm (1|M0)          null     r6      r2:1    0x0            0x04000B84           {A@1,$11} // wr:2+1, rd:0; store.ugm.d16u32.a64
        mov (1|M0)               r2.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$11.src}
        mov (1|M0)               r6.0<1>:f     r3.0<0;1,0>:f                    {Compacted}
        add3 (1|M0)              r6.1<1>:d     r2.0<0;0>:d       r4.1<0;0>:d       0:w               {I@1}
        addc (1|M0)              r3.0<1>:ud    r4.0<0;1,0>:ud    0xA:ud              {AccWrEn,F@1}
        mov (1|M0)               r2.0<1>:d     r4.12<0;1,0>:uw                 
        send.ugm (1|M0)          null     r6      r2:1    0x0            0x04000B84           {A@1,$13} // wr:2+1, rd:0; store.ugm.d16u32.a64
        mov (1|M0)               r2.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$13.src}
        mov (1|M0)               r6.0<1>:f     r3.0<0;1,0>:f                    {Compacted}
        add3 (1|M0)              r6.1<1>:d     r2.0<0;0>:d       r4.1<0;0>:d       0:w               {I@1}
        addc (1|M0)              r3.0<1>:ud    r4.0<0;1,0>:ud    0xC:ud              {AccWrEn,F@1}
        mov (1|M0)               r2.0<1>:d     r4.13<0;1,0>:uw                 
        send.ugm (1|M0)          null     r6      r2:1    0x0            0x04000B84           {A@1,$14} // wr:2+1, rd:0; store.ugm.d16u32.a64
        mov (1|M0)               r2.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$14.src}
        mov (1|M0)               r6.0<1>:f     r3.0<0;1,0>:f                    {Compacted}
        add3 (1|M0)              r6.1<1>:d     r2.0<0;0>:d       r4.1<0;0>:d       0:w               {I@1}
        addc (1|M0)              r3.0<1>:ud    r4.0<0;1,0>:ud    0xE:ud              {AccWrEn,F@1}
        mov (1|M0)               r2.0<1>:d     r4.14<0;1,0>:uw                 
        send.ugm (1|M0)          null     r6      r2:1    0x0            0x04000B84           {A@1,$1} // wr:2+1, rd:0; store.ugm.d16u32.a64
        mov (1|M0)               r2.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$1.src}
        mov (1|M0)               r6.0<1>:f     r3.0<0;1,0>:f                    {Compacted}
        add3 (1|M0)              r6.1<1>:d     r2.0<0;0>:d       r4.1<0;0>:d       0:w               {I@1}
        addc (1|M0)              r3.0<1>:ud    r2.4<0;1,0>:ud    0x1:ud              {AccWrEn,F@1}
        mov (1|M0)               r2.0<1>:d     r4.15<0;1,0>:uw                 
        mov (1|M0)               r2.6<1>:d     r3.0<0;1,0>:d                    {I@2}
        send.ugm (1|M0)          null     r6      r2:1    0x0            0x04000B84           {A@1,$9} // wr:2+1, rd:0; store.ugm.d16u32.a64
        mov (1|M0)               r2.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$9.src}
        add3 (1|M0)              r2.7<1>:d     r2.0<0;0>:d       r2.5<0;0>:d       0:w               {I@1}
        cmp (1|M0)    (eq)f0.0   null<1>:d     r2.7<0;1,0>:d     0:w               {I@1}
(f0.0)  cmp (1|M0)    (eq)f0.0   null<1>:d     r2.6<0;1,0>:d     8:w              
(W)     and (1|M0)               f0.0<1>:ud    f0.0<0;1,0>:uw    0x1:uw             
(f0.0.any32h) goto (32|M0)                   L22848                  L22848                
L22816:
(W)     mov (2|M0)               r2.4<1>:ud    r2.6<1;1,0>:ud                  
        goto.b (32|M0)                       L22848                  L21872                
L22848:
        join (32|M0)                         L23016                                
L22864:
        addc (1|M0)              r3.0<1>:ud    r1.6<0;1,0>:ud    0x1:ud              {AccWrEn}
        mov (1|M0)               r2.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r2.2<1>:d     r3.0<0;1,0>:d                    {I@2}
        add3 (1|M0)              r2.3<1>:d     r2.0<0;0>:d       r1.7<0;0>:d       0:w               {I@2}
        cmp (1|M0)    (eq)f0.0   null<1>:d     r2.3<0;1,0>:d     0:w               {I@1}
(f0.0)  cmp (1|M0)    (eq)f0.0   null<1>:d     r2.2<0;1,0>:d     8:w              
(W)     and (1|M0)               f0.0<1>:ud    f0.0<0;1,0>:uw    0x1:uw             
(f0.0.any32h) goto (32|M0)                   L23016                  L36192                
L22984:
(W)     mov (2|M0)               r1.6<1>:ud    r2.2<1;1,0>:ud                  
        goto.b (32|M0)                       L23016                  L21640                
L23016:
        join (32|M0)                         L36192                                
L23032:
        cmp (1|M0)    (ne)f0.0   null<1>:d     r4.0<0;1,0>:d     5:w              
(W)     mov (1|M0)               r2.9<1>:hf    0x1:hf                             
        cmp (1|M0)    (lt)f1.1   null<1>:uw    r1.0<0;1,0>:uw    0x4:uw             
(f1.0)  sel (1|M0)               r2.15<1>:uw   r2.9<0;1,0>:uw    0x0:uw              {F@1}
(f0.0)  sel (1|M0)               r2.8<1>:uw    r2.9<0;1,0>:uw    0x0:uw             
        xor (1|M0)    (ne)f0.1   null<1>:uw    r2.8<0;1,0>:uw    0x1:uw              {I@1}
(f0.1)  sel (1|M0)               r2.8<1>:uw    r2.9<0;1,0>:uw    0x0:uw             
        and (1|M0)    (ne)f0.1   null<1>:uw    r2.15<0;1,0>:uw   r2.8<0;1,0>:uw   {I@1}
(f0.0)  sel (1|M0)               r2.15<1>:uw   r2.9<0;1,0>:uw    0x0:uw             
(f0.1)  sel (1|M0)               r2.8<1>:uw    r2.9<0;1,0>:uw    0x0:uw             
        or (1|M0)     (ne)f0.0   null<1>:uw    r2.15<0;1,0>:uw   r2.8<0;1,0>:uw   {I@1}
(W)     and (1|M0)               f0.0<1>:ud    f0.0<0;1,0>:uw    0x1:uw             
(f0.0.any32h) goto (32|M0)                   L24752                  L24752                
L23240:
        cmp (1|M0)    (lt)f0.0   null<1>:uw    r1.0<0;1,0>:uw    0x40:uw             
        shl (1|M0)               r1.6<1>:d     r2.3<0;1,0>:d     12:w              
        shr (1|M0)               r1.5<1>:ud    r2.2<0;1,0>:ud    0x14:uw             
        shl (1|M0)               r1.3<1>:d     r2.2<0;1,0>:d     12:w              
(W)     and (1|M0)               f0.0<1>:ud    f0.0<0;1,0>:uw    0x1:uw             
        or (1|M0)                r1.4<1>:d     r1.6<0;1,0>:d     r1.5<0;1,0>:d    {I@3}
(~f0.0.any32h) goto (32|M0)                  L24752                  L36192                
L23352:
        shl (1|M0)               r1.5<1>:d     r1.3<0;1,0>:d     1:w               {I@4}
        shl (1|M0)               r4.0<1>:d     r1.4<0;1,0>:d     1:w               {Compacted,I@3}
        shr (1|M0)               r1.7<1>:ud    r1.3<0;1,0>:ud    0x1F:uw             
        addc (1|M0)              r2.0<1>:ud    r4.2<0;1,0>:ud    r1.5<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r1.6<1>:d     r4.0<0;1,0>:d     r1.7<0;1,0>:d    {I@2}
        mov (1|M0)               r4.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r1.3<1>:d     r2.0<0;1,0>:d                    {I@3}
        mov (1|M0)               r1.7<1>:d     0:w                              
        add3 (1|M0)              r1.4<1>:d     r4.0<0;0>:d       r4.3<0;0>:d       r1.6<0>:d        {I@3}
        mov (1|M0)               r1.6<1>:d     r1.0<0;1,0>:uw                  
L23496:
        shl (1|M0)               r2.3<1>:d     r1.7<0;1,0>:d     6:w               {I@3}
        shr (1|M0)               r2.2<1>:ud    r1.6<0;1,0>:ud    0x1A:uw              {I@2}
        shl (1|M0)               r2.0<1>:d     r1.6<0;1,0>:d     6:w               {Compacted}
        or (1|M0)                r2.1<1>:d     r2.3<0;1,0>:d     r2.2<0;1,0>:d    {I@2}
        shl (1|M0)               r2.3<1>:d     r2.0<0;1,0>:d     1:w               {Compacted,I@2}
        shl (1|M0)               r1.0<1>:d     r1.6<0;1,0>:d     7:w               {Compacted}
        shr (1|M0)               r2.2<1>:ud    r2.0<0;1,0>:ud    0x1F:uw             
        shl (1|M0)               r2.5<1>:d     r2.1<0;1,0>:d     1:w               {I@4}
        addc (1|M0)              r3.0<1>:ud    r1.3<0;1,0>:ud    r2.3<0;1,0>:ud   {AccWrEn,I@4}
        add (1|M0)               r5.0<1>:d     r1.0<0;1,0>:d     12288:w               {I@4}
        or (1|M0)                r2.4<1>:d     r2.5<0;1,0>:d     r2.2<0;1,0>:d    {I@3}
        mov (1|M0)               r2.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r2.3<1>:d     0:w                              
        mov (1|M0)               r2.1<1>:d     r3.0<0;1,0>:d                    {I@5}
        send.slm (1|M0)          r3       r5      null:0  0x0            0x0220C700           {A@1,$3} // wr:1+0, rd:2; load.slm.d64x8t.a32
        mov (1|M0)               r2.5<2>:f     0.0:f                              
        add3 (1|M0)              r2.2<1>:d     r2.0<0;0>:d       r1.4<0;0>:d       r2.4<0>:d       
        mov (1|M0)               r2.4<2>:f     0.0:f                               {I@1}
L23752:
        shl (1|M0)               r1.0<1>:w     r2.6<0;1,0>:w     1:w              
        shl (1|M0)               r2.6<1>:d     r2.4<0;1,0>:d     1:w               {F@1}
        shl (1|M0)               r5.2<1>:d     r2.5<0;1,0>:d     1:w               {$3.src}
        shr (1|M0)               r5.1<1>:ud    r2.4<0;1,0>:ud    0x1F:uw             
        add (1|M0)               a0.0<1>:uw    r1.0<0;1,0>:uw    0x60:uw              {A@1}
        sync.allrd                           ($0,$4,$7,$9,$10,$12)                
        addc (1|M0)              r6.0<1>:ud    r2.1<0;1,0>:ud    r2.6<0;1,0>:ud   {AccWrEn,I@4}
        or (1|M0)                r2.7<1>:d     r5.2<0;1,0>:d     r5.1<0;1,0>:d    {I@3}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$4.dst}
        mov (1|M0)               r2.0<1>:d     r[a0.0]<0;1,0>:uw                {$3.dst}
        add3 (1|M0)              r6.1<1>:d     r7.0<0;0>:d       r2.2<0;0>:d       r2.7<0>:d        {A@1}
        add (1|M0)               r2.3<1>:d     r2.3<0;1,0>:d     1:w               {Compacted}
        send.ugm (1|M0)          null     r6      r2:1    0x0            0x04000B84           {A@1,$6} // wr:2+1, rd:0; store.ugm.d16u32.a64
        addc (1|M0)              r6.0<1>:ud    r2.4<0;1,0>:ud    0x1:ud              {AccWrEn,$6.src}
        mov (1|M0)               r2.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r2.6<1>:d     r6.0<0;1,0>:d                    {I@2}
        add3 (1|M0)              r2.7<1>:d     r2.0<0;0>:d       r2.5<0;0>:d       0:w               {I@2}
        cmp (1|M0)    (eq)f0.0   null<1>:d     r2.7<0;1,0>:d     0:w               {I@1}
(f0.0)  cmp (1|M0)    (eq)f0.0   null<1>:d     r2.6<0;1,0>:d     32:w              
(W)     and (1|M0)               f0.0<1>:ud    f0.0<0;1,0>:uw    0x1:uw             
(f0.0.any32h) goto (32|M0)                   L24096                  L24096                
L24064:
(W)     mov (2|M0)               r2.4<1>:ud    r2.6<1;1,0>:ud                  
        goto.b (32|M0)                       L24096                  L23752                
L24096:
        join (32|M0)                         L24752                                
L24112:
        or (1|M0)                r1.0<1>:ud    r5.0<0;1,0>:ud    0x40:uw             
        addc (1|M0)              r5.0<1>:ud    r2.1<0;1,0>:ud    0x40:ud              {AccWrEn}
        send.slm (1|M0)          r3       r1      null:0  0x0            0x0220C700           {A@2,$8} // wr:1+0, rd:2; load.slm.d64x8t.a32
        mov (1|M0)               r2.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r2.6<2>:f     0.0:f                              
        mov (1|M0)               r2.7<2>:f     0.0:f                              
        mov (1|M0)               r2.1<1>:d     0:w                              
        mov (1|M0)               r2.3<1>:d     r5.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r2.4<1>:d     r2.0<0;0>:d       r2.2<0;0>:d       0:w               {I@3}
L24248:
        sync.nop                             null                             {Compacted,$8.src}
        shl (1|M0)               r1.0<1>:w     r2.2<0;1,0>:w     1:w               {I@3}
        shl (1|M0)               r6.1<1>:d     r2.7<0;1,0>:d     1:w               {F@1}
        shr (1|M0)               r6.0<1>:ud    r2.6<0;1,0>:ud    0x1F:uw             
        shl (1|M0)               r6.2<1>:d     r2.6<0;1,0>:d     1:w              
        add (1|M0)               a0.0<1>:uw    r1.0<0;1,0>:uw    0x60:uw              {A@1}
        or (1|M0)                r6.3<1>:d     r6.1<0;1,0>:d     r6.0<0;1,0>:d    {I@3}
        addc (1|M0)              r6.0<1>:ud    r2.3<0;1,0>:ud    r6.2<0;1,0>:ud   {AccWrEn,I@3}
        add (1|M0)               r2.1<1>:d     r2.1<0;1,0>:d     1:w               {Compacted}
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r2.0<1>:d     r[a0.0]<0;1,0>:uw                {$8.dst}
        add3 (1|M0)              r6.1<1>:d     r5.0<0;0>:d       r2.4<0;0>:d       r6.3<0>:d        {A@1}
        send.ugm (1|M0)          null     r6      r2:1    0x0            0x04000B84           {A@1,$11} // wr:2+1, rd:0; store.ugm.d16u32.a64
        addc (1|M0)              r6.0<1>:ud    r2.6<0;1,0>:ud    0x1:ud              {AccWrEn,$11.src}
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r5.2<1>:d     r6.0<0;1,0>:d                    {I@2}
        add3 (1|M0)              r5.3<1>:d     r5.0<0;0>:d       r2.7<0;0>:d       0:w               {I@2}
        cmp (1|M0)    (eq)f0.0   null<1>:d     r5.3<0;1,0>:d     0:w               {I@1}
(f0.0)  cmp (1|M0)    (eq)f0.0   null<1>:d     r5.2<0;1,0>:d     32:w              
(W)     and (1|M0)               f0.0<1>:ud    f0.0<0;1,0>:uw    0x1:uw             
(f0.0.any32h) goto (32|M0)                   L24584                  L24584                
L24552:
(W)     mov (2|M0)               r2.6<1>:ud    r5.2<1;1,0>:ud                  
        goto.b (32|M0)                       L24584                  L24248                
L24584:
        join (32|M0)                         L24752                                
L24600:
        cmp (1|M0)    (lt)f0.0   null<1>:ud    r1.6<0;1,0>:ud    0x20:uw             
        addc (1|M0)              r3.0<1>:ud    r1.6<0;1,0>:ud    0x20:ud              {AccWrEn}
        mov (1|M0)               r2.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
(f0.0)  cmp (1|M0)    (eq)f0.0   null<1>:d     r1.7<0;1,0>:d     0:w              
        mov (1|M0)               r2.2<1>:d     r3.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r2.3<1>:d     r2.0<0;0>:d       r1.7<0;0>:d       0:w               {I@3}
(W)     and (1|M0)               f0.0<1>:ud    f0.0<0;1,0>:uw    0x1:uw             
(~f0.0.any32h) goto (32|M0)                  L24752                  L36192                
L24720:
(W)     mov (2|M0)               r1.6<1>:ud    r2.2<1;1,0>:ud                   {I@3}
        goto.b (32|M0)                       L24752                  L23496                
L24752:
        join (32|M0)                         L36192                                
L24768:
        mov (1|M0)               r2.4<1>:d     0:w                              
L24784:
(W)     and (1|M0)               f0.0<1>:ud    f1.1<0;1,0>:uw    0x1:uw             
(~f0.0.any32h) goto (32|M0)                  L25224                  L25224                
L24816:
        bfn.0xEA (1|M0)          r3.2<1>:ud    r2.4<0;0>:ud      r1.6<0;0>:ud      0x4:uw              {I@3} // s0|s1&s2
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0x140:uw              {A@1}
        shl (1|M0)               r3.2<1>:ud    r3.2<0;1,0>:ud    0x7:uw              {I@2}
        sync.allrd                           ($0,$4,$7,$9,$10,$12,$14)                
        add (1|M0)               r6.0<1>:ud    r3.2<0;1,0>:ud    0x3000:uw              {I@1}
        send.slm (1|M0)          r10      r6      null:0  0x0            0x0220C700           {A@1,$1} // wr:1+0, rd:2; load.slm.d64x8t.a32
        mov (8|M0)               r6.0<1>:uw    r[a0.0]<1;1,0>:uw                {$1.dst}
        mov (8|M0)               r6.8<1>:uw    r[a0.0,16]<1;1,0>:uw             {A@1}
        add (1|M0)               r10.0<1>:ud   r3.2<0;1,0>:ud    0x3080:uw              {A@1}
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0x160:uw              {A@1}
        send.slm (1|M0)          r11      r10     null:0  0x0            0x0220C700           {A@2,$3} // wr:1+0, rd:2; load.slm.d64x8t.a32
        add (1|M0)               r10.0<1>:ud   r3.2<0;1,0>:ud    0x3100:uw              {$3.src}
        sync.nop                             null                             {Compacted,$3.dst}
        mov (8|M0)               r7.0<1>:uw    r[a0.0]<1;1,0>:uw                {$4.dst}
        mov (8|M0)               r7.8<1>:uw    r[a0.0,16]<1;1,0>:uw             {A@1}
        send.slm (1|M0)          r11      r10     null:0  0x0            0x0220C700           {A@1,$6} // wr:1+0, rd:2; load.slm.d64x8t.a32
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0x160:uw              {A@1}
        add (1|M0)               r10.0<1>:ud   r3.2<0;1,0>:ud    0x3180:uw              {$6.src}
        mov (8|M0)               r8.0<1>:uw    r[a0.0]<1;1,0>:uw                {$6.dst}
        mov (8|M0)               r8.8<1>:uw    r[a0.0,16]<1;1,0>:uw             {A@1}
        send.slm (1|M0)          r11      r10     null:0  0x0            0x0220C700           {A@1,$8} // wr:1+0, rd:2; load.slm.d64x8t.a32
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0x160:uw              {A@1}
        or (1|M0)                r10.0<1>:d    r1.5<0;1,0>:d     28672:w               {$8.src}
        mov (8|M0)               r9.0<1>:uw    r[a0.0]<1;1,0>:uw                {$8.dst}
        mov (8|M0)               r9.8<1>:uw    r[a0.0,16]<1;1,0>:uw             {A@1}
        send.slm (1|M0)          null     r10     r6:4    0x0            0x0200D704           {A@1,$7} // wr:1+4, rd:0; store.slm.d64x16t.a32
L25224:
        join (32|M0)                         L28744                                
L25240:
        sync.allrd                           ($0,$4,$7,$9,$10,$12,$14)                
(W)     send.slm (1|M0)          r6       r0      null:0  0x0            0x0210001F           {$11} // wr:1+0, rd:1; fence.slm.none.group
(W)     mov (8|M0)               null<1>:ud    r6.0<1;1,0>:ud                   {$11.dst}
(W)     mov (1|M0)               r6.2<1>:f     0.0:f                               {Compacted,I@1}
(W)     mov (2|M0)               r6.10<1>:ub   r0.11<0;1,0>:ub                  {F@1}
(W)     send.gtwy (1|M0)         null     r6      null:0  0x0            0x02000004           {A@1,$1} // wr:1+0, rd:0; signal barrier
(W)     sync.bar                             null                            
        mov (1|M0)               r6.0<1>:d     28672:w                               {$1.src}
        mov (1|M0)               r46.0<1>:d    9280:w                              
        send.slm (1|M0)          r38      r6      null:0  0x0            0x0280E700           {A@2,$3} // wr:1+0, rd:8; load.slm.d64x32t.a32
        mov (1|M0)               r6.0<1>:d     8192:w                               {$3.src}
        mov (1|M0)               r54.0<1>:d    10816:w                               {$5.src}
        send.slm (1|M0)          r14      r6      null:0  0x0            0x0210B700           {A@2,$6} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r6.0<1>:d     8256:w                               {$6.src}
        shl (1|M0)               r3.2<1>:ud    r2.4<0;1,0>:ud    0x7:uw             
        send.slm (1|M0)          r15      r6      null:0  0x0            0x0210B700           {A@2,$8} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r6.0<1>:d     8320:w                               {$8.src}
        send.slm (1|M0)          r16      r6      null:0  0x0            0x0210B700           {A@1,$11} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r6.0<1>:d     8384:w                               {$11.src}
        send.slm (1|M0)          r17      r6      null:0  0x0            0x0210B700           {A@1,$12} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r6.0<1>:d     8448:w                               {$12.src}
        send.slm (1|M0)          r18      r6      null:0  0x0            0x0210B700           {A@1,$4} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r6.0<1>:d     8512:w                               {$4.src}
        send.slm (1|M0)          r19      r6      null:0  0x0            0x0210B700           {A@1,$5} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r6.0<1>:d     8576:w                               {$5.src}
        send.slm (1|M0)          r20      r6      null:0  0x0            0x0210B700           {A@1,$2} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r6.0<1>:d     8640:w                               {$2.src}
        send.slm (1|M0)          r21      r6      null:0  0x0            0x0210B700           {A@1,$15} // wr:1+0, rd:1; load.slm.d64x4t.a32
        sync.allwr                           ($2,$3,$4,$5,$6,$8,$11,$12,$15)                
        dpas.8x8 (8|M0)          r6:f          null:f            r6:hf             r6.0:hf          {Atomic}
        dpas.8x8 (8|M0)          r6:f          r94:f             r14:hf            r38.0:hf         {$3}
        mov (1|M0)               r14.0<1>:d    8704:w                               {$3.src}
        send.slm (1|M0)          r22      r14     null:0  0x0            0x0210B700           {A@1,$10} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r14.0<1>:d    8768:w                               {$10.src}
        send.slm (1|M0)          r23      r14     null:0  0x0            0x0210B700           {A@1,$0} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r14.0<1>:d    8832:w                               {$0.src}
        send.slm (1|M0)          r24      r14     null:0  0x0            0x0210B700           {A@1,$9} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r14.0<1>:d    8896:w                               {$9.src}
        send.slm (1|M0)          r25      r14     null:0  0x0            0x0210B700           {A@1,$14} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r14.0<1>:d    8960:w                               {$14.src}
        send.slm (1|M0)          r26      r14     null:0  0x0            0x0210B700           {A@1,$13} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r14.0<1>:d    9024:w                               {$13.src}
        send.slm (1|M0)          r27      r14     null:0  0x0            0x0210B700           {A@1,$7} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r14.0<1>:d    9088:w                               {$7.src}
        send.slm (1|M0)          r28      r14     null:0  0x0            0x0210B700           {A@1,$1} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r14.0<1>:d    9152:w                               {$1.src}
        send.slm (1|M0)          r29      r14     null:0  0x0            0x0210B700           {A@1,$6} // wr:1+0, rd:1; load.slm.d64x4t.a32
        sync.allwr                           ($0,$1,$6,$7,$9,$13,$14)                
        dpas.8x8 (8|M0)          r14:f         r94:f             r22:hf            r38.0:hf         {$10}
        sync.nop                             null                             {Compacted,$10.src}
        send.slm (1|M0)          r23      r46     null:0  0x0            0x0210B700           {$8} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r46.0<1>:d    9344:w                               {$8.src}
        mov (1|M0)               r22.0<1>:d    28928:w                              
        send.slm (1|M0)          r24      r46     null:0  0x0            0x0210B700           {A@2,$11} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r46.0<1>:d    9408:w                               {$11.src}
        send.slm (1|M0)          r30      r22     null:0  0x0            0x0280E700           {A@2,$1} // wr:1+0, rd:8; load.slm.d64x32t.a32
        send.slm (1|M0)          r25      r46     null:0  0x0            0x0210B700           {A@1,$6} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r46.0<1>:d    9472:w                               {$6.src}
        mov (1|M0)               r22.0<1>:d    9216:w                               {$1.src}
        send.slm (1|M0)          r26      r46     null:0  0x0            0x0210B700           {A@2,$12} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r46.0<1>:d    9536:w                               {$12.src}
        send.slm (1|M0)          r22      r22     null:0  0x0            0x0210B700           {A@2,$4} // wr:1+0, rd:1; load.slm.d64x4t.a32
        send.slm (1|M0)          r27      r46     null:0  0x0            0x0210B700           {A@1,$5} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r46.0<1>:d    9600:w                               {$5.src}
        send.slm (1|M0)          r28      r46     null:0  0x0            0x0210B700           {A@1,$2} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r46.0<1>:d    9664:w                               {$2.src}
        send.slm (1|M0)          r29      r46     null:0  0x0            0x0210B700           {A@1,$15} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r46.0<1>:d    9792:w                               {$15.src}
        sync.allwr                           ($1,$2,$3,$4,$5,$6,$11,$12,$15)                
        dpas.8x8 (8|M0)          r6:f          r6:f              r22:hf            r30.0:hf         {$8}
        sync.nop                             null                             {Compacted,$8.src}
        send.slm (1|M0)          r23      r46     null:0  0x0            0x0210B700           {A@1,$3} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r46.0<1>:d    9856:w                               {$3.src}
        mov (1|M0)               r22.0<1>:d    9728:w                              
        send.slm (1|M0)          r24      r46     null:0  0x0            0x0210B700           {A@2,$6} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r46.0<1>:d    9920:w                               {$6.src}
        send.slm (1|M0)          r22      r22     null:0  0x0            0x0210B700           {A@2,$11} // wr:1+0, rd:1; load.slm.d64x4t.a32
        send.slm (1|M0)          r25      r46     null:0  0x0            0x0210B700           {A@1,$1} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r46.0<1>:d    9984:w                               {$1.src}
        send.slm (1|M0)          r26      r46     null:0  0x0            0x0210B700           {A@1,$0} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r46.0<1>:d    10048:w                               {$0.src}
        send.slm (1|M0)          r27      r46     null:0  0x0            0x0210B700           {A@1,$9} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r46.0<1>:d    10112:w                               {$9.src}
        send.slm (1|M0)          r28      r46     null:0  0x0            0x0210B700           {A@1,$14} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r46.0<1>:d    10176:w                               {$14.src}
        send.slm (1|M0)          r29      r46     null:0  0x0            0x0210B700           {A@1,$13} // wr:1+0, rd:1; load.slm.d64x4t.a32
        sync.allwr                           ($0,$1,$6,$9,$10,$11,$13,$14)                
        dpas.8x8 (8|M0)          r14:f         r14:f             r22:hf            r30.0:hf         {$3}
        mov (1|M0)               r22.0<1>:d    10240:w                               {$3.src}
        send.slm (1|M0)          r46      r22     null:0  0x0            0x0210B700           {A@1,$6} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r22.0<1>:d    10304:w                               {$6.src}
        send.slm (1|M0)          r47      r22     null:0  0x0            0x0210B700           {A@1,$11} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r22.0<1>:d    10368:w                               {$11.src}
        send.slm (1|M0)          r48      r22     null:0  0x0            0x0210B700           {A@1,$1} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r22.0<1>:d    10432:w                               {$1.src}
        send.slm (1|M0)          r49      r22     null:0  0x0            0x0210B700           {A@1,$7} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r22.0<1>:d    10496:w                               {$7.src}
        send.slm (1|M0)          r50      r22     null:0  0x0            0x0210B700           {A@1,$10} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r22.0<1>:d    10560:w                               {$10.src}
        send.slm (1|M0)          r51      r22     null:0  0x0            0x0210B700           {A@1,$12} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r22.0<1>:d    10624:w                               {$12.src}
        send.slm (1|M0)          r52      r22     null:0  0x0            0x0210B700           {A@1,$4} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r22.0<1>:d    10688:w                               {$4.src}
        send.slm (1|M0)          r53      r22     null:0  0x0            0x0210B700           {A@1,$5} // wr:1+0, rd:1; load.slm.d64x4t.a32
        sync.allwr                           ($1,$4,$5,$7,$10,$11,$12)                
        dpas.8x8 (8|M0)          r22:f         r94:f             r46:hf            r38.0:hf         {$6}
        sync.nop                             null                             {Compacted,$6.src}
        send.slm (1|M0)          r47      r54     null:0  0x0            0x0210B700           {$11} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r54.0<1>:d    10880:w                               {$11.src}
        mov (1|M0)               r46.0<1>:d    10752:w                              
        send.slm (1|M0)          r48      r54     null:0  0x0            0x0210B700           {A@2,$1} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r54.0<1>:d    10944:w                               {$1.src}
        send.slm (1|M0)          r46      r46     null:0  0x0            0x0210B700           {A@2,$2} // wr:1+0, rd:1; load.slm.d64x4t.a32
        send.slm (1|M0)          r49      r54     null:0  0x0            0x0210B700           {A@1,$15} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r54.0<1>:d    11008:w                               {$15.src}
        send.slm (1|M0)          r50      r54     null:0  0x0            0x0210B700           {A@1,$8} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r54.0<1>:d    11072:w                               {$8.src}
        send.slm (1|M0)          r51      r54     null:0  0x0            0x0210B700           {A@1,$0} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r54.0<1>:d    11136:w                               {$0.src}
        send.slm (1|M0)          r52      r54     null:0  0x0            0x0210B700           {A@1,$9} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r54.0<1>:d    11200:w                               {$9.src}
        send.slm (1|M0)          r53      r54     null:0  0x0            0x0210B700           {A@1,$14} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r54.0<1>:d    11328:w                               {$14.src}
        sync.allwr                           ($0,$1,$2,$8,$9,$14,$15)                
        dpas.8x8 (8|M0)          r38:f         r94:f             r46:hf            r38.0:hf         {$11}
        sync.nop                             null                             {Compacted,$11.src}
        send.slm (1|M0)          r47      r54     null:0  0x0            0x0210B700           {A@1,$1} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r54.0<1>:d    11392:w                               {$1.src}
        mov (1|M0)               r46.0<1>:d    11264:w                              
        send.slm (1|M0)          r48      r54     null:0  0x0            0x0210B700           {A@2,$13} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r54.0<1>:d    11456:w                               {$13.src}
        send.slm (1|M0)          r46      r46     null:0  0x0            0x0210B700           {A@2,$3} // wr:1+0, rd:1; load.slm.d64x4t.a32
        send.slm (1|M0)          r49      r54     null:0  0x0            0x0210B700           {A@1,$7} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r54.0<1>:d    11520:w                               {$7.src}
        send.slm (1|M0)          r50      r54     null:0  0x0            0x0210B700           {A@1,$10} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r54.0<1>:d    11584:w                               {$10.src}
        send.slm (1|M0)          r51      r54     null:0  0x0            0x0210B700           {A@1,$12} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r54.0<1>:d    11648:w                               {$12.src}
        send.slm (1|M0)          r52      r54     null:0  0x0            0x0210B700           {A@1,$4} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r54.0<1>:d    11712:w                               {$4.src}
        send.slm (1|M0)          r53      r54     null:0  0x0            0x0210B700           {A@1,$5} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r54.0<1>:d    11840:w                               {$5.src}
        sync.allwr                           ($3,$4,$5,$6,$7,$10,$12,$13)                
        dpas.8x8 (8|M0)          r22:f         r22:f             r46:hf            r30.0:hf         {$1}
        sync.nop                             null                             {Compacted,$1.src}
        send.slm (1|M0)          r47      r54     null:0  0x0            0x0210B700           {A@1,$6} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r54.0<1>:d    11904:w                               {$6.src}
        mov (1|M0)               r46.0<1>:d    11776:w                              
        send.slm (1|M0)          r48      r54     null:0  0x0            0x0210B700           {A@2,$2} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r54.0<1>:d    11968:w                               {$2.src}
        send.slm (1|M0)          r46      r46     null:0  0x0            0x0210B700           {A@2,$15} // wr:1+0, rd:1; load.slm.d64x4t.a32
        send.slm (1|M0)          r49      r54     null:0  0x0            0x0210B700           {A@1,$8} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r54.0<1>:d    12032:w                               {$8.src}
        send.slm (1|M0)          r50      r54     null:0  0x0            0x0210B700           {A@1,$0} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r54.0<1>:d    12096:w                               {$0.src}
        send.slm (1|M0)          r51      r54     null:0  0x0            0x0210B700           {A@1,$9} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r54.0<1>:d    12160:w                               {$9.src}
        send.slm (1|M0)          r52      r54     null:0  0x0            0x0210B700           {A@1,$14} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r54.0<1>:d    12224:w                               {$14.src}
        send.slm (1|M0)          r53      r54     null:0  0x0            0x0210B700           {A@1,$13} // wr:1+0, rd:1; load.slm.d64x4t.a32
        sync.allwr                           ($0,$2,$8,$9,$11,$13,$14,$15)                
        dpas.8x8 (8|M0)          r38:f         r38:f             r46:hf            r30.0:hf         {$6}
        mov (8|M0)               r33.0<1>:f    r6.0<1;1,0>:f                    {Compacted,$6.src}
        mov (8|M0)               r34.0<1>:f    r14.0<1;1,0>:f                   {Compacted}
        add (1|M0)               r30.0<1>:ud   r3.2<0;1,0>:ud    0x5000:uw             
        mov (8|M0)               r31.0<1>:f    r22.0<1;1,0>:f                   {Compacted,$1.dst}
        send.slm (1|M0)          null     r30     r33:2   0x0            0x0200C704           {A@1,$11} // wr:1+2, rd:0; store.slm.d64x8t.a32
        add (1|M0)               r30.0<1>:ud   r3.2<0;1,0>:ud    0x5040:uw              {$11.src}
        mov (8|M0)               r33.0<1>:f    r7.0<1;1,0>:f                    {Compacted}
        mov (8|M0)               r32.0<1>:f    r38.0<1;1,0>:f                   {Compacted,$6.dst}
        mov (8|M0)               r34.0<1>:f    r15.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r30     r31:2   0x0            0x0200C704           {A@1,$1} // wr:1+2, rd:0; store.slm.d64x8t.a32
        add (1|M0)               r30.0<1>:ud   r3.2<0;1,0>:ud    0x5080:uw              {$1.src}
        mov (8|M0)               r31.0<1>:f    r23.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r30     r33:2   0x0            0x0200C704           {A@1,$3} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r32.0<1>:f    r39.0<1;1,0>:f                   {Compacted}
        add (1|M0)               r30.0<1>:ud   r3.2<0;1,0>:ud    0x50C0:uw              {$3.src}
        mov (8|M0)               r33.0<1>:f    r8.0<1;1,0>:f                    {Compacted}
        send.slm (1|M0)          null     r30     r31:2   0x0            0x0200C704           {A@1,$8} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r34.0<1>:f    r16.0<1;1,0>:f                   {Compacted}
        add (1|M0)               r30.0<1>:ud   r3.2<0;1,0>:ud    0x5100:uw              {$8.src}
        mov (8|M0)               r31.0<1>:f    r24.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r30     r33:2   0x0            0x0200C704           {A@1,$7} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r32.0<1>:f    r40.0<1;1,0>:f                   {Compacted}
        add (1|M0)               r30.0<1>:ud   r3.2<0;1,0>:ud    0x5140:uw              {$7.src}
        mov (8|M0)               r33.0<1>:f    r9.0<1;1,0>:f                    {Compacted}
        send.slm (1|M0)          null     r30     r31:2   0x0            0x0200C704           {A@1,$10} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r34.0<1>:f    r17.0<1;1,0>:f                   {Compacted}
        add (1|M0)               r30.0<1>:ud   r3.2<0;1,0>:ud    0x5180:uw              {$10.src}
        mov (8|M0)               r31.0<1>:f    r25.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r30     r33:2   0x0            0x0200C704           {A@1,$12} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r32.0<1>:f    r41.0<1;1,0>:f                   {Compacted}
        add (1|M0)               r30.0<1>:ud   r3.2<0;1,0>:ud    0x51C0:uw              {$12.src}
        mov (8|M0)               r33.0<1>:f    r10.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r30     r31:2   0x0            0x0200C704           {A@1,$11} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r34.0<1>:f    r18.0<1;1,0>:f                   {Compacted}
        add (1|M0)               r30.0<1>:ud   r3.2<0;1,0>:ud    0x5200:uw              {$11.src}
        mov (8|M0)               r31.0<1>:f    r26.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r30     r33:2   0x0            0x0200C704           {A@1,$6} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r32.0<1>:f    r42.0<1;1,0>:f                   {Compacted}
        add (1|M0)               r30.0<1>:ud   r3.2<0;1,0>:ud    0x5240:uw              {$6.src}
        mov (8|M0)               r33.0<1>:f    r11.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r30     r31:2   0x0            0x0200C704           {A@1,$1} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r34.0<1>:f    r19.0<1;1,0>:f                   {Compacted}
        add (1|M0)               r30.0<1>:ud   r3.2<0;1,0>:ud    0x5280:uw              {$1.src}
        mov (8|M0)               r31.0<1>:f    r27.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r30     r33:2   0x0            0x0200C704           {A@1,$3} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r32.0<1>:f    r43.0<1;1,0>:f                   {Compacted}
        add (1|M0)               r30.0<1>:ud   r3.2<0;1,0>:ud    0x52C0:uw              {$3.src}
        mov (8|M0)               r33.0<1>:f    r12.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r30     r31:2   0x0            0x0200C704           {A@1,$8} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r34.0<1>:f    r20.0<1;1,0>:f                   {Compacted}
        add (1|M0)               r30.0<1>:ud   r3.2<0;1,0>:ud    0x5300:uw              {$8.src}
        add (1|M0)               r6.0<1>:ud    r3.2<0;1,0>:ud    0x5380:uw             
        send.slm (1|M0)          null     r30     r33:2   0x0            0x0200C704           {A@1,$4} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r7.0<1>:f     r13.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r8.0<1>:f     r21.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r31.0<1>:f    r28.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r32.0<1>:f    r44.0<1;1,0>:f                   {Compacted}
        add (1|M0)               r30.0<1>:ud   r3.2<0;1,0>:ud    0x5340:uw              {$4.src}
        mov (8|M0)               r9.0<1>:f     r29.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r30     r31:2   0x0            0x0200C704           {A@1,$13} // wr:1+2, rd:0; store.slm.d64x8t.a32
        send.slm (1|M0)          null     r6      r7:2    0x0            0x0200C704           {$11} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r10.0<1>:f    r45.0<1;1,0>:f                   {Compacted}
        add (1|M0)               r6.0<1>:ud    r3.2<0;1,0>:ud    0x53C0:uw              {$11.src}
        send.slm (1|M0)          null     r6      r9:2    0x0            0x0200C704           {A@1,$6} // wr:1+2, rd:0; store.slm.d64x8t.a32
        sync.nop                             null                             {Compacted,$6.src}
(W)     send.slm (1|M0)          r6       r0      null:0  0x0            0x0210001F           {$5} // wr:1+0, rd:1; fence.slm.none.group
(W)     mov (8|M0)               null<1>:ud    r6.0<1;1,0>:ud                   {$5.dst}
(W)     mov (1|M0)               r6.2<1>:f     0.0:f                               {Compacted,I@1}
(W)     mov (2|M0)               r6.10<1>:ub   r0.11<0;1,0>:ub                  {F@1}
(W)     send.gtwy (1|M0)         null     r6      null:0  0x0            0x02000004           {A@1,$14} // wr:1+0, rd:0; signal barrier
(W)     sync.bar                             null                            
        cmp (1|M0)    (lt)f0.0   null<1>:ud    r2.4<0;1,0>:ud    0x38:uw             
        add (1|M0)               r3.2<1>:ud    r2.4<0;1,0>:ud    0x8:uw             
(W)     and (1|M0)               f0.0<1>:ud    f0.0<0;1,0>:uw    0x1:uw             
(~f0.0.any32h) goto (32|M0)                  L28744                  L28744                
L28712:
        mov (1|M0)               r2.4<1>:d     r3.2<0;1,0>:d                    {I@3}
        goto.b (32|M0)                       L28744                  L24784                
L28744:
        join (32|M0)                         L36192                                
L28760:
        cmp (1|M0)    (ne)f0.0   null<1>:d     r4.0<0;1,0>:d     8:w              
(W)     mov (1|M0)               r2.9<1>:hf    0x1:hf                              {I@4}
(f1.0)  sel (1|M0)               r2.15<1>:uw   r2.9<0;1,0>:uw    0x0:uw              {F@1}
(f0.0)  sel (1|M0)               r2.8<1>:uw    r2.9<0;1,0>:uw    0x0:uw             
        cmp (1|M0)    (lt)f1.0   null<1>:uw    r1.0<0;1,0>:uw    0x4:uw             
        xor (1|M0)    (ne)f0.1   null<1>:uw    r2.8<0;1,0>:uw    0x1:uw              {I@2}
(f0.1)  sel (1|M0)               r2.8<1>:uw    r2.9<0;1,0>:uw    0x0:uw             
        and (1|M0)    (ne)f0.1   null<1>:uw    r2.15<0;1,0>:uw   r2.8<0;1,0>:uw   {I@1}
(f0.0)  sel (1|M0)               r2.15<1>:uw   r2.9<0;1,0>:uw    0x0:uw             
(f0.1)  sel (1|M0)               r2.8<1>:uw    r2.9<0;1,0>:uw    0x0:uw             
        or (1|M0)     (ne)f0.1   null<1>:uw    r2.15<0;1,0>:uw   r2.8<0;1,0>:uw   {I@1}
        and (1|M0)               r2.16<2>:b    r2.28<0;1,0>:b    1:w              
        cmp (1|M0)    (eq)f0.0   null<1>:w     r2.16<0;1,0>:b    0:w               {I@1}
(W)     mov (1|M0)               r2.8<1>:uw    f0.0<0;1,0>:uw                   {Compacted}
(W)     and (1|M0)               f0.0<1>:ud    f0.1<0;1,0>:uw    0x1:uw             
(f0.0.any32h) goto (32|M0)                   L30072                  L30072                
L29008:
        cmp (1|M0)    (lt)f0.0   null<1>:uw    r1.0<0;1,0>:uw    0x40:uw             
        shl (1|M0)               r1.6<1>:d     r2.3<0;1,0>:d     12:w              
        shr (1|M0)               r1.5<1>:ud    r2.2<0;1,0>:ud    0x14:uw             
        shl (1|M0)               r1.3<1>:d     r2.2<0;1,0>:d     12:w              
(W)     and (1|M0)               f0.0<1>:ud    f0.0<0;1,0>:uw    0x1:uw             
        or (1|M0)                r1.4<1>:d     r1.6<0;1,0>:d     r1.5<0;1,0>:d    {I@3}
(~f0.0.any32h) goto (32|M0)                  L30072                  L36192                
L29120:
        shl (1|M0)               r1.5<1>:d     r1.3<0;1,0>:d     1:w               {I@4}
        shl (1|M0)               r4.0<1>:d     r1.4<0;1,0>:d     1:w               {Compacted,I@3}
        shr (1|M0)               r1.7<1>:ud    r1.3<0;1,0>:ud    0x1F:uw             
        addc (1|M0)              r2.0<1>:ud    r4.2<0;1,0>:ud    r1.5<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r1.6<1>:d     r4.0<0;1,0>:d     r1.7<0;1,0>:d    {I@2}
        mov (1|M0)               r4.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r1.3<1>:d     r2.0<0;1,0>:d                    {I@3}
        mov (1|M0)               r1.7<1>:d     0:w                              
        add3 (1|M0)              r1.4<1>:d     r4.0<0;0>:d       r4.3<0;0>:d       r1.6<0>:d        {I@3}
        mov (1|M0)               r1.6<1>:d     r1.0<0;1,0>:uw                  
L29264:
        shl (1|M0)               r2.3<1>:d     r1.7<0;1,0>:d     5:w               {I@3}
        shr (1|M0)               r2.2<1>:ud    r1.6<0;1,0>:ud    0x1B:uw              {I@2}
        shl (1|M0)               r2.0<1>:d     r1.6<0;1,0>:d     5:w               {Compacted}
        or (1|M0)                r2.1<1>:d     r2.3<0;1,0>:d     r2.2<0;1,0>:d    {I@2}
        shl (1|M0)               r2.3<1>:d     r2.0<0;1,0>:d     1:w               {Compacted,I@2}
        shl (1|M0)               r1.0<1>:d     r1.6<0;1,0>:d     7:w               {Compacted}
        shr (1|M0)               r2.2<1>:ud    r2.0<0;1,0>:ud    0x1F:uw             
        shl (1|M0)               r2.5<1>:d     r2.1<0;1,0>:d     1:w               {I@4}
        sync.nop                             null                             {Compacted,$4.dst}
        sync.allrd                           ($7,$9,$12)                
        addc (1|M0)              r7.0<1>:ud    r1.3<0;1,0>:ud    r2.3<0;1,0>:ud   {AccWrEn,I@4}
        add (1|M0)               r1.0<1>:d     r1.0<0;1,0>:d     20480:w               {I@4}
        or (1|M0)                r2.4<1>:d     r2.5<0;1,0>:d     r2.2<0;1,0>:d    {I@3}
        mov (1|M0)               r2.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        sync.allrd                           ($0,$14)                
        send.slm (1|M0)          r3       r1      null:0  0x0            0x0240D700           {A@3,$1} // wr:1+0, rd:4; load.slm.d64x16t.a32
        mov (1|M0)               r2.3<1>:d     0:w                              
        mov (1|M0)               r2.1<1>:d     r7.0<0;1,0>:d                   
        mov (1|M0)               r2.5<2>:f     0.0:f                               {I@4}
        add3 (1|M0)              r2.2<1>:d     r2.0<0;0>:d       r1.4<0;0>:d       r2.4<0>:d        {I@3}
        mov (1|M0)               r2.4<2>:f     0.0:f                               {I@1}
L29560:
        shl (1|M0)               r1.0<1>:w     r2.6<0;1,0>:w     2:w               {$1.src}
        shl (1|M0)               r2.6<1>:d     r2.4<0;1,0>:d     1:w               {F@1}
        add (1|M0)               a0.0<1>:uw    r1.0<0;1,0>:uw    0x60:uw              {A@1}
        shl (1|M0)               r7.1<1>:d     r2.5<0;1,0>:d     1:w              
        shr (1|M0)               r7.0<1>:ud    r2.4<0;1,0>:ud    0x1F:uw             
        addc (1|M0)              r8.0<1>:ud    r2.1<0;1,0>:ud    r2.6<0;1,0>:ud   {AccWrEn,I@4}
        mov (1|M0)               r2.0<2>:hf    r[a0.0]<0;1,0>:f                 {$1.dst}
        or (1|M0)                r2.7<1>:d     r7.1<0;1,0>:d     r7.0<0;1,0>:d    {A@1}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r2.0<1>:d     r2.0<0;1,0>:uw                   {F@1}
        add3 (1|M0)              r8.1<1>:d     r7.0<0;0>:d       r2.2<0;0>:d       r2.7<0>:d        {I@2}
        addc (1|M0)              r7.0<1>:ud    r2.4<0;1,0>:ud    0x1:ud              {AccWrEn}
        send.ugm (1|M0)          null     r8      r2:1    0x0            0x04000B84           {A@2,$3} // wr:2+1, rd:0; store.ugm.d16u32.a64
        mov (1|M0)               r2.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$3.src}
        mov (1|M0)               r2.6<1>:d     r7.0<0;1,0>:d                    {I@2}
        add3 (1|M0)              r2.7<1>:d     r2.0<0;0>:d       r2.5<0;0>:d       0:w               {I@2}
        add (1|M0)               r2.3<1>:d     r2.3<0;1,0>:d     1:w               {Compacted}
        cmp (1|M0)    (eq)f0.0   null<1>:d     r2.7<0;1,0>:d     0:w               {I@2}
(f0.0)  cmp (1|M0)    (eq)f0.0   null<1>:d     r2.6<0;1,0>:d     32:w              
(W)     and (1|M0)               f0.0<1>:ud    f0.0<0;1,0>:uw    0x1:uw             
(f0.0.any32h) goto (32|M0)                   L29904                  L29904                
L29872:
(W)     mov (2|M0)               r2.4<1>:ud    r2.6<1;1,0>:ud                  
        goto.b (32|M0)                       L29904                  L29560                
L29904:
        join (32|M0)                         L30072                                
L29920:
        cmp (1|M0)    (lt)f0.0   null<1>:ud    r1.6<0;1,0>:ud    0x20:uw             
        addc (1|M0)              r3.0<1>:ud    r1.6<0;1,0>:ud    0x20:ud              {AccWrEn}
        mov (1|M0)               r2.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
(f0.0)  cmp (1|M0)    (eq)f0.0   null<1>:d     r1.7<0;1,0>:d     0:w              
        mov (1|M0)               r2.2<1>:d     r3.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r2.3<1>:d     r2.0<0;0>:d       r1.7<0;0>:d       0:w               {I@3}
(W)     and (1|M0)               f0.0<1>:ud    f0.0<0;1,0>:uw    0x1:uw             
(~f0.0.any32h) goto (32|M0)                  L30072                  L36192                
L30040:
(W)     mov (2|M0)               r1.6<1>:ud    r2.2<1;1,0>:ud                   {I@3}
        goto.b (32|M0)                       L30072                  L29264                
L30072:
        join (32|M0)                         L36192                                
L30088:
        sync.allrd                           ($7,$9,$12)                
        addc (1|M0)              r7.0<1>:ud    r2.0<0;1,0>:ud    0x100:ud              {AccWrEn,$4.dst}
        and (1|M0)               r2.3<1>:d     r5.0<0;1,0>:d     -2:w               {Compacted}
        sync.allrd                           ($0,$14)                
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$10.src}
        mov (1|M0)               r67.0<1>:f    r7.0<0;1,0>:f                    {Compacted,I@3}
        addc (1|M0)              r7.0<1>:ud    r2.0<0;1,0>:ud    0x200:ud              {AccWrEn,F@1}
        add3 (1|M0)              r67.1<1>:d    r6.0<0;0>:d       r2.1<0;0>:d       0:w               {I@2}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r68.0<1>:f    r7.0<0;1,0>:f                    {Compacted,I@3}
        addc (1|M0)              r7.0<1>:ud    r2.0<0;1,0>:ud    0x300:ud              {AccWrEn,F@1}
        add3 (1|M0)              r68.1<1>:d    r6.0<0;0>:d       r2.1<0;0>:d       0:w               {I@2}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r69.0<1>:f    r7.0<0;1,0>:f                    {Compacted,I@3}
        addc (1|M0)              r7.0<1>:ud    r2.0<0;1,0>:ud    0x400:ud              {AccWrEn,F@1}
        add3 (1|M0)              r69.1<1>:d    r6.0<0;0>:d       r2.1<0;0>:d       0:w               {I@2}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r70.0<1>:f    r7.0<0;1,0>:f                    {Compacted,I@3}
        addc (1|M0)              r7.0<1>:ud    r2.0<0;1,0>:ud    0x500:ud              {AccWrEn,F@1}
        add3 (1|M0)              r70.1<1>:d    r6.0<0;0>:d       r2.1<0;0>:d       0:w               {I@2}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        sync.nop                             null                             {Compacted,$5.src}
        mov (1|M0)               r71.0<1>:f    r7.0<0;1,0>:f                    {Compacted,I@3}
        addc (1|M0)              r7.0<1>:ud    r2.0<0;1,0>:ud    0x600:ud              {AccWrEn,F@1}
        add3 (1|M0)              r71.1<1>:d    r6.0<0;0>:d       r2.1<0;0>:d       0:w               {I@2}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r72.0<1>:f    r7.0<0;1,0>:f                    {Compacted,I@3}
        addc (1|M0)              r7.0<1>:ud    r2.0<0;1,0>:ud    0x700:ud              {AccWrEn,F@1}
        add3 (1|M0)              r72.1<1>:d    r6.0<0;0>:d       r2.1<0;0>:d       0:w               {I@2}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        and (1|M0)               r2.2<1>:d     r5.0<0;1,0>:d     -3:w               {Compacted}
        or (1|M0)                r66.0<1>:d    r1.7<0;1,0>:d     29184:w              
        or (1|M0)                r65.0<1>:d    r1.7<0;1,0>:d     29248:w              
        or (1|M0)                r64.0<1>:d    r1.7<0;1,0>:d     29312:w              
        or (1|M0)                r1.0<1>:d     r1.7<0;1,0>:d     29376:w              
        mov (1|M0)               r3.2<2>:f     0.0:f                              
        mov (1|M0)               r3.3<2>:f     0.0:f                              
        mov (1|M0)               r1.6<1>:d     0:w                              
        mov (1|M0)               r73.0<1>:f    r7.0<0;1,0>:f                    {Compacted,I@7}
        add3 (1|M0)              r73.1<1>:d    r6.0<0;0>:d       r2.1<0;0>:d       0:w               {I@7}
L30592:
        mov (1|M0)               r2.7<1>:d     0:w                              
L30608:
        or (1|M0)                r1.7<1>:d     r2.7<0;1,0>:d     r3.2<0;1,0>:d    {A@1}
        mov (1|M0)               r3.4<1>:d     0:w                              
        shl (1|M0)               r1.7<1>:d     r1.7<0;1,0>:d     7:w               {I@2}
        add (1|M0)               r10.0<1>:d    r1.7<0;1,0>:d     20480:w               {I@1}
        send.slm (1|M0)          r6       r10     null:0  0x0            0x0240D700           {A@1,$14} // wr:1+0, rd:4; load.slm.d64x16t.a32
L30688:
        shl (1|M0)               r1.2<1>:w     r3.8<0;1,0>:w     2:w              
        add (1|M0)               a0.0<1>:uw    r1.2<0;1,0>:uw    0xC0:uw              {A@1}
        cmp (1|M0)    (lt)f1.1   null<1>:f     r[a0.0]<0;1,0>:f  0.0:f               {$14.dst}
(W)     mov (1|M0)               r3.5<1>:f     -r[a0.0]<0;1,0>:f                {A@1}
(W)     mov (1|M0)               r1.7<1>:f     r[a0.0]<0;1,0>:f                 {A@1}
(f1.1)  sel (1|M0)               r3.6<1>:f     r3.5<0;1,0>:f     r1.7<0;1,0>:f    {A@1}
        sel (1|M0)    (lt)f0.0   r3.6<1>:f     r3.6<0;1,0>:f     448.0:f               {F@1}
        shr (1|M0)               r3.5<1>:ud    r3.6<0;1,0>:ud    0x17:uw              {F@1}
        and (1|M0)               r3.5<1>:ud    r3.5<0;1,0>:ud    0xFF:uw              {I@1}
        sel (1|M0)    (ge)f0.0   r3.5<1>:ud    r3.5<0;1,0>:ud    0x79:uw              {I@1}
        shl (1|M0)               r3.5<1>:ud    r3.5<0;1,0>:ud    0x17:uw              {I@1}
        add (1|M0)               r5.6<1>:ud    -r3.5<0;1,0>:ud   0x80800000:ud              {I@1}
        mul (1|M0)               r1.7<1>:f     r3.6<0;1,0>:f     r5.6<0;1,0>:f    {I@1}
        mov (1|M0)               r3.7<1>:d     r1.7<0;1,0>:f                    {F@1}
        mov (1|M0)               r1.7<1>:f     r3.7<0;1,0>:d                    {I@1}
        mad (1|M0)               r3.6<1>:f     -r1.7<0;0>:f      r5.6<0;0>:f       r3.6<0>:f        {F@1}
        cmp (1|M0)    (gt)f0.0   null<1>:f     r3.6<0;1,0>:f     0.5:f               {F@1}
(W)     and (1|M0)               f0.0<1>:ud    f0.0<0;1,0>:uw    0x1:uw              {F@1}
(f0.0.any32h) goto (32|M0)                   L31088                  L31088                
L30992:
        cmp (1|M0)    (lt)f0.0   null<1>:f     r3.6<0;1,0>:f     0.5:f               {A@1}
        and (1|M0)               r3.7<1>:d     r3.7<0;1,0>:d     1:w              
        add (1|M0)               r5.6<1>:f     r1.7<0;1,0>:f     1.0:f              
(~f0.0) cmp (1|M0)    (eq)f0.0   null<1>:d     r3.7<0;1,0>:d     0:w               {A@1}
(~f0.0) mov (1|M0)               r1.7<1>:f     r5.6<0;1,0>:f                    {F@1}
        goto (32|M0)                         L31088                  L31120                
L31088:
        join (32|M0)                         L31120                                
L31104:
        add (1|M0)               r1.7<1>:f     r1.7<0;1,0>:f     1.0:f               {F@1}
L31120:
        join (32|M0)                         L31320                                
L31136:
        shl (1|M0)               r1.2<1>:w     r3.8<0;1,0>:w     1:w              
        add (1|M0)               r3.4<1>:d     r3.4<0;1,0>:d     1:w              
        add (1|M0)               r3.5<1>:ud    r3.5<0;1,0>:ud    0xFE800000:ud             
        cmp (1|M0)    (eq)f0.0   null<1>:d     r3.4<0;1,0>:d     32:w               {I@2}
        mul (1|M0)               r1.7<1>:f     r1.7<0;1,0>:f     r3.5<0;1,0>:f    {A@1}
        add (1|M0)               a0.0<1>:uw    r1.2<0;1,0>:uw    0x7C0:uw              {A@1}
(f1.1)  mov (1|M0)               r1.7<1>:f     -r1.7<0;1,0>:f                   {F@1}
(W)     and (1|M0)               f0.0<1>:ud    f0.0<0;1,0>:uw    0x1:uw             
(W)     mov (1|M0)               r1.2<2>:hf    r1.7<0;1,0>:f                    {A@1}
        sync.nop                             null                             {Compacted,$12.src}
        mov (1|M0)               r[a0.0]<1>:hf  r1.2<0;1,0>:hf                  {F@1}
(~f0.0.any32h) goto.b (32|M0)                L31320                  L30688                
L31320:
        join (32|M0)                         L31456                                
L31336:
        shl (1|M0)               r1.7<1>:d     r2.7<0;1,0>:d     6:w              
        add (1|M0)               r2.7<1>:d     r2.7<0;1,0>:d     1:w              
        sync.nop                             null                             {Compacted,$12.src}
        or (1|M0)                r6.0<1>:d     r1.7<0;1,0>:d     29184:w               {I@2}
        cmp (1|M0)    (eq)f0.0   null<1>:d     r2.7<0;1,0>:d     8:w               {I@2}
        send.slm (1|M0)          null     r6      r62:2   0x0            0x0200C704           {A@1,$12} // wr:1+2, rd:0; store.slm.d64x8t.a32
(W)     and (1|M0)               f0.0<1>:ud    f0.0<0;1,0>:uw    0x1:uw             
(~f0.0.any32h) goto.b (32|M0)                L31456                  L30608                
L31456:
        join (32|M0)                         L36192                                
L31472:
        sync.nop                             null                             {Compacted,$12.src}
(W)     send.slm (1|M0)          r6       r0      null:0  0x0            0x0210001F           {$0} // wr:1+0, rd:1; fence.slm.none.group
(W)     mov (8|M0)               null<1>:ud    r6.0<1;1,0>:ud                   {$0.dst}
(W)     mov (1|M0)               r6.2<1>:f     0.0:f                               {Compacted,I@1}
(W)     mov (2|M0)               r6.10<1>:ub   r0.11<0;1,0>:ub                  {F@1}
(W)     send.gtwy (1|M0)         null     r6      null:0  0x0            0x02000004           {A@1,$1} // wr:1+0, rd:0; signal barrier
(W)     sync.bar                             null                            
(W)     and (1|M0)               f0.0<1>:ud    f1.0<0;1,0>:uw    0x1:uw             
(~f0.0.any32h) goto (32|M0)                  L31896                  L31896                
L31600:
        send.slm (1|M0)          r10      r66     null:0  0x0            0x0220C700           {$3} // wr:1+0, rd:2; load.slm.d64x8t.a32
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0x140:uw              {A@1}
        sync.nop                             null                             {Compacted,$3.dst}
        mov (8|M0)               r6.0<1>:uw    r[a0.0]<1;1,0>:uw                {$1.src}
        mov (8|M0)               r6.8<1>:uw    r[a0.0,16]<1;1,0>:uw             {A@1}
        send.slm (1|M0)          r10      r65     null:0  0x0            0x0220C700           {A@1,$4} // wr:1+0, rd:2; load.slm.d64x8t.a32
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0x140:uw              {A@1}
        mov (8|M0)               r7.0<1>:uw    r[a0.0]<1;1,0>:uw                {$4.dst}
        mov (8|M0)               r7.8<1>:uw    r[a0.0,16]<1;1,0>:uw             {A@1}
        send.slm (1|M0)          r10      r64     null:0  0x0            0x0220C700           {A@1,$5} // wr:1+0, rd:2; load.slm.d64x8t.a32
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0x140:uw              {A@1}
        mov (8|M0)               r8.0<1>:uw    r[a0.0]<1;1,0>:uw                {$5.dst}
        mov (8|M0)               r8.8<1>:uw    r[a0.0,16]<1;1,0>:uw             {A@1}
        send.slm (1|M0)          r10      r1      null:0  0x0            0x0220C700           {A@1,$12} // wr:1+0, rd:2; load.slm.d64x8t.a32
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0x140:uw              {A@1}
        mov (8|M0)               r9.0<1>:uw    r[a0.0]<1;1,0>:uw                {$12.dst}
        mov (8|M0)               r9.8<1>:uw    r[a0.0,16]<1;1,0>:uw             {A@1}
        or (1|M0)                r10.0<1>:d    r1.5<0;1,0>:d     28672:w               {A@1}
        send.slm (1|M0)          null     r10     r6:4    0x0            0x0200D704           {A@1,$14} // wr:1+4, rd:0; store.slm.d64x16t.a32
L31896:
        join (32|M0)                         L36192                                
L31912:
        sync.allrd                           ($1,$14)                
(W)     send.slm (1|M0)          r6       r0      null:0  0x0            0x0210001F           {$0} // wr:1+0, rd:1; fence.slm.none.group
(W)     mov (8|M0)               null<1>:ud    r6.0<1;1,0>:ud                   {$0.dst}
(W)     mov (1|M0)               r6.2<1>:f     0.0:f                               {Compacted,I@1}
(W)     mov (2|M0)               r6.10<1>:ub   r0.11<0;1,0>:ub                  {F@1}
(W)     send.gtwy (1|M0)         null     r6      null:0  0x0            0x02000004           {A@1,$3} // wr:1+0, rd:0; signal barrier
(W)     sync.bar                             null                            
        sync.nop                             null                             {Compacted,$15.src}
        send.ugm (1|M0)          r14      r2      null:0  0x0            0x0280E780           {$6} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        send.ugm (1|M0)          r22      r67     null:0  0x0            0x0280E780           {$7} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        send.ugm (1|M0)          r46      r68     null:0  0x0            0x0280E780           {$4} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        sync.nop                             null                             {Compacted,$2.src}
        send.ugm (1|M0)          r38      r69     null:0  0x0            0x0280E780           {$8} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        mov (1|M0)               r6.0<1>:d     28672:w                               {$3.src}
        send.ugm (1|M0)          r54      r70     null:0  0x0            0x0280E780           {$5} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        send.slm (1|M0)          r30      r6      null:0  0x0            0x0280E700           {A@1,$12} // wr:1+0, rd:8; load.slm.d64x32t.a32
        shr (1|M0)               r1.7<1>:ud    r1.6<0;1,0>:ud    0x3:uw             
        mov (1|M0)               r3.6<2>:f     0.0:f                              
        add (1|M0)               r1.7<1>:d     r1.7<0;1,0>:d     r1.4<0;1,0>:d    {I@1}
        mov (1|M0)               r3.7<2>:f     0.0:f                              
        mul (1|M0)               acc0.0<1>:ud  r1.7<0;1,0>:ud    r2.12<0;1,0>:uw  {I@1}
        mov (1|M0)               r2.7<1>:d     0:w                               {$6.src}
        sync.allwr                           ($6,$7,$12)                
        dpas.8x8 (8|M0)          r6:f          null:f            r6:hf             r6.0:hf          {Atomic}
        dpas.8x8 (8|M0)          r6:f          r94:f             r14:hf            r30.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r14:f         r94:f             r22:hf            r30.0:hf         {$6}
        dpas.8x8 (8|M0)          r22:f         r94:f             r46:hf            r30.0:hf         {$4}
        mov (1|M0)               r46.0<1>:d    28928:w                               {$4.src}
        dpas.8x8 (8|M0)          r30:f         r94:f             r38:hf            r30.0:hf         {$8}
        sync.nop                             null                             {Compacted,$8.src}
        send.slm (1|M0)          r38      r46     null:0  0x0            0x0280E700           {A@1,$2} // wr:1+0, rd:8; load.slm.d64x32t.a32
        sync.nop                             null                             {Compacted,$2.src}
        send.ugm (1|M0)          r46      r71     null:0  0x0            0x0280E780           {$15} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        sync.allwr                           ($2,$6)                
        dpas.8x8 (8|M0)          r6:f          r6:f              r54:hf            r38.0:hf         {$5}
        sync.nop                             null                             {Compacted,$5.src}
        send.ugm (1|M0)          r54      r72     null:0  0x0            0x0280E780           {$10} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        sync.nop                             null                             {Compacted,$15.dst}
        dpas.8x8 (8|M0)          r14:f         r14:f             r46:hf            r38.0:hf         {$6}
        sync.nop                             null                             {Compacted,$6.src}
        send.ugm (1|M0)          r46      r73     null:0  0x0            0x0280E780           {$1} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        sync.allwr                           ($1,$4,$8,$10)                
        dpas.8x8 (8|M0)          r22:f         r22:f             r54:hf            r38.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r30:f         r30:f             r46:hf            r38.0:hf         {$7}
        mach (1|M0)              r39.0<1>:ud   r1.7<0;1,0>:ud    r2.6<0;1,0>:ud   {AccWrEn,$7.src}
        mov (1|M0)               r38.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r3.5<1>:d     r39.0<0;1,0>:d                   {I@2}
        mov (1|M0)               r3.4<1>:d     r38.0<0;1,0>:d                   {I@2}
L32608:
        cmp (1|M0)    (gt)f0.0   null<1>:d     r1.7<0;1,0>:d     -1:w              
        add (1|M0)               r5.7<1>:d     r1.3<0;1,0>:d     r3.6<0;1,0>:d    {F@2}
(W)     and (1|M0)               f0.0<1>:ud    f0.0<0;1,0>:uw    0x1:uw             
(~f0.0.any32h) goto (32|M0)                  L35736                  L35736                
L32672:
        cmp (1|M0)    (gt)f0.0   null<1>:d     r5.7<0;1,0>:d     -1:w               {I@3}
        cmp (1|M0)    (lt)f0.1   null<1>:d     r5.7<0;1,0>:d     r2.6<0;1,0>:d   
(W)     mov (1|M0)               r64.2<1>:hf   0x1:hf                             
(f0.0)  cmp (1|M0)    (lt)f0.0   null<1>:d     r1.7<0;1,0>:d     r2.5<0;1,0>:d   
(f0.1)  sel (1|M0)               r5.3<1>:uw    r64.2<0;1,0>:uw   0x0:uw              {F@1}
(f0.0)  sel (1|M0)               r5.12<1>:uw   r64.2<0;1,0>:uw   0x0:uw             
        and (1|M0)    (ne)f0.0   null<1>:uw    r5.12<0;1,0>:uw   r5.3<0;1,0>:uw   {I@1}
(W)     and (1|M0)               f0.0<1>:ud    f0.0<0;1,0>:uw    0x1:uw             
(~f0.0.any32h) goto (32|M0)                  L35736                  L35736                
L32816:
        sync.allrd                           ($9,$11)                
        shl (1|M0)               r42.2<1>:w    r2.14<0;1,0>:w    5:w               {$8.src}
        addc (1|M0)              r42.0<1>:ud   r3.4<0;1,0>:ud    r5.7<0;1,0>:ud   {AccWrEn}
        add (1|M0)               a0.0<1>:uw    r42.2<0;1,0>:uw   0xC0:uw              {A@1}
        mov (1|M0)               r38.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        shr (1|M0)               r5.6<1>:ud    r42.0<0;1,0>:ud   0x1B:uw              {I@3}
        add3 (1|M0)              r5.7<1>:d     r38.0<0;0>:d      r3.5<0;0>:d       0:w               {I@2}
        mov (8|M0)               r45.0<1>:ud   r[a0.0]<1;1,0>:ud                {$5.dst}
        add (1|M0)               a0.0<1>:uw    r42.2<0;1,0>:uw   0x1C0:uw              {A@1}
        shl (1|M0)               r42.2<1>:d    r42.0<0;1,0>:d    5:w               {Compacted}
        shl (1|M0)               r5.7<1>:d     r5.7<0;1,0>:d     5:w               {I@4}
        shl (1|M0)               r42.0<1>:d    r42.2<0;1,0>:d    1:w               {Compacted,I@2}
        mov (8|M0)               r44.0<1>:ud   r[a0.0]<1;1,0>:ud                {$6.dst}
        add (1|M0)               a0.0<1>:uw    r42.2<0;1,0>:uw   0x2C0:uw              {A@1}
        or (1|M0)                r42.3<1>:d    r5.7<0;1,0>:d     r5.6<0;1,0>:d    {I@4}
        shl (1|M0)               r64.1<1>:d    r42.2<0;1,0>:d    2:w              
        mov (1|M0)               r39.0<1>:f    r44.0<0;1,0>:f                   {Compacted,I@4}
        shr (1|M0)               r5.6<1>:ud    r42.2<0;1,0>:ud   0x1F:uw             
        shl (1|M0)               r5.7<1>:d     r42.3<0;1,0>:d    1:w               {I@3}
        sync.nop                             null                             {Compacted,$8.dst}
        mov (8|M0)               r43.0<1>:ud   r[a0.0]<1;1,0>:ud                {$7.dst}
        addc (1|M0)              r44.0<1>:ud   r3.0<0;1,0>:ud    r42.0<0;1,0>:ud  {AccWrEn,A@1}
        shr (1|M0)               r42.4<1>:ud   r42.2<0;1,0>:ud   0x1E:uw             
        shl (1|M0)               r42.5<1>:d    r42.3<0;1,0>:d    2:w              
        add (1|M0)               a0.0<1>:uw    r42.2<0;1,0>:uw   0x3C0:uw              {A@1}
        mov (1|M0)               r40.0<1>:f    r43.0<0;1,0>:f                   {Compacted,I@5}
        or (1|M0)                r42.1<1>:d    r5.7<0;1,0>:d     r5.6<0;1,0>:d   
        mov (1|M0)               r43.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,F@1}
        mov (1|M0)               r5.6<1>:d     r44.0<0;1,0>:d                   {I@6}
        addc (1|M0)              r44.0<1>:ud   r3.0<0;1,0>:ud    r64.1<0;1,0>:ud  {AccWrEn}
        or (1|M0)                r64.2<1>:d    r42.5<0;1,0>:d    r42.4<0;1,0>:d   {I@6}
        add3 (1|M0)              r5.7<1>:d     r43.0<0;0>:d      r3.1<0;0>:d       r42.1<0>:d       {I@4}
        mov (1|M0)               r42.4<1>:d    r44.0<0;1,0>:d                   {I@3}
        mov (1|M0)               r43.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r44.0<1>:ud   r5.2<0;1,0>:ud    r42.0<0;1,0>:ud  {AccWrEn}
        add3 (1|M0)              r42.5<1>:d    r43.0<0;0>:d      r3.1<0;0>:d       r64.2<0>:d       {I@2}
        mov (1|M0)               r43.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r42.0<1>:ud   r5.4<0;1,0>:ud    r64.1<0;1,0>:ud  {AccWrEn}
        mov (8|M0)               r46.0<1>:ud   r[a0.0]<1;1,0>:ud               
        add3 (1|M0)              r42.3<1>:d    r43.0<0;0>:d      r5.3<0;0>:d       r42.1<0>:d       {A@1}
        mov (1|M0)               r43.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r38.0<1>:f    r45.0<0;1,0>:f                   {Compacted}
        mov (1|M0)               r38.1<1>:f    r45.1<0;1,0>:f                   {Compacted}
        mov (1|M0)               r38.2<1>:f    r45.2<0;1,0>:f                  
        mov (1|M0)               r38.3<1>:f    r45.3<0;1,0>:f                   {Compacted}
        mov (1|M0)               r38.4<1>:f    r45.4<0;1,0>:f                  
        mov (1|M0)               r38.5<1>:f    r45.5<0;1,0>:f                  
        mov (1|M0)               r38.6<1>:f    r45.6<0;1,0>:f                  
        mov (1|M0)               r38.7<1>:f    r45.7<0;1,0>:f                  
        mov (1|M0)               r39.1<1>:f    r44.1<0;1,0>:f                   {Compacted}
        mov (1|M0)               r39.2<1>:f    r44.2<0;1,0>:f                  
        mov (1|M0)               r39.3<1>:f    r44.3<0;1,0>:f                   {Compacted}
        mov (1|M0)               r39.4<1>:f    r44.4<0;1,0>:f                  
        mov (1|M0)               r39.5<1>:f    r44.5<0;1,0>:f                  
        mov (1|M0)               r39.6<1>:f    r44.6<0;1,0>:f                  
        mov (1|M0)               r39.7<1>:f    r44.7<0;1,0>:f                  
        mov (1|M0)               r40.1<1>:f    r43.1<0;1,0>:f                   {Compacted}
        mov (1|M0)               r40.2<1>:f    r43.2<0;1,0>:f                  
        mov (1|M0)               r40.3<1>:f    r43.3<0;1,0>:f                   {Compacted}
        mov (1|M0)               r40.4<1>:f    r43.4<0;1,0>:f                  
        mov (1|M0)               r40.5<1>:f    r43.5<0;1,0>:f                  
        mov (1|M0)               r40.6<1>:f    r43.6<0;1,0>:f                  
        mov (1|M0)               r40.7<1>:f    r43.7<0;1,0>:f                  
        mov (1|M0)               r42.2<1>:d    r44.0<0;1,0>:d                  
        mov (1|M0)               r42.6<1>:d    r42.0<0;1,0>:d                   {I@5}
        mov (1|M0)               r41.0<1>:f    r46.0<0;1,0>:f                   {Compacted,I@5}
        mov (1|M0)               r41.1<1>:f    r46.1<0;1,0>:f                   {Compacted}
        mov (1|M0)               r41.2<1>:f    r46.2<0;1,0>:f                  
        mov (1|M0)               r41.3<1>:f    r46.3<0;1,0>:f                   {Compacted}
        mov (1|M0)               r41.4<1>:f    r46.4<0;1,0>:f                  
        mov (1|M0)               r41.5<1>:f    r46.5<0;1,0>:f                  
        mov (1|M0)               r41.6<1>:f    r46.6<0;1,0>:f                  
        mov (1|M0)               r41.7<1>:f    r46.7<0;1,0>:f                  
        add3 (1|M0)              r42.7<1>:d    r43.0<0;0>:d      r5.5<0;0>:d       r64.2<0>:d       {I@3}
        mov (1|M0)               r44.2<2>:f    0.0:f                              
        mov (1|M0)               r44.3<2>:f    0.0:f                              
L33872:
(W)     and (1|M0)               f0.0<1>:ud    r2.8<0;1,0>:uw    0x1:uw             
(f0.0.any32h) goto (32|M0)                   L34056                  L34056                
L33904:
        shl (1|M0)               r44.0<1>:d    r44.2<0;1,0>:d    1:w               {Compacted,F@2}
        shl (1|M0)               r44.5<1>:d    r44.3<0;1,0>:d    1:w               {F@1}
        shr (1|M0)               r44.4<1>:ud   r44.2<0;1,0>:ud   0x1F:uw             
        addc (1|M0)              r45.0<1>:ud   r5.6<0;1,0>:ud    r44.0<0;1,0>:ud  {AccWrEn,I@3}
        or (1|M0)                r44.1<1>:d    r44.5<0;1,0>:d    r44.4<0;1,0>:d   {I@2}
        mov (1|M0)               r43.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r42.0<1>:f    r45.0<0;1,0>:f                   {Compacted,I@3}
        add3 (1|M0)              r42.1<1>:d    r43.0<0;0>:d      r5.7<0;0>:d       r44.1<0>:d       {I@1}
        send.ugm (1|M0)          r44      r42     null:0  0x0            0x04100B80           {A@1,$14} // wr:2+0, rd:1; load.ugm.d16u32.a64
        mov (1|M0)               r43.0<1>:f    r44.0<0;1,0>:hf                  {$14.dst}
        goto (32|M0)                         L34056                  L34192                
L34056:
        join (32|M0)                         L34192                                
L34072:
        shl (1|M0)               r44.0<1>:d    r44.2<0;1,0>:d    2:w               {Compacted,F@1}
        shl (1|M0)               r44.5<1>:d    r44.3<0;1,0>:d    2:w              
        shr (1|M0)               r44.4<1>:ud   r44.2<0;1,0>:ud   0x1E:uw             
        addc (1|M0)              r45.0<1>:ud   r42.4<0;1,0>:ud   r44.0<0;1,0>:ud  {AccWrEn,I@3}
        or (1|M0)                r44.1<1>:d    r44.5<0;1,0>:d    r44.4<0;1,0>:d   {I@2}
        mov (1|M0)               r43.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r42.0<1>:f    r45.0<0;1,0>:f                   {Compacted,I@3}
        add3 (1|M0)              r42.1<1>:d    r43.0<0;0>:d      r42.5<0;0>:d      r44.1<0>:d       {I@1}
        send.ugm (1|M0)          r43      r42     null:0  0x0            0x04100580           {A@1,$8} // wr:2+0, rd:1; load.ugm.d32.a64
L34192:
        join (32|M0)                         L35736                                
L34208:
        shl (1|M0)               r44.4<1>:d    r44.2<0;1,0>:d    2:w              
        shl (1|M0)               r43.2<1>:d    r44.3<0;1,0>:d    2:w               {$8.dst}
        shr (1|M0)               r43.1<1>:ud   r44.2<0;1,0>:ud   0x1E:uw             
        addc (1|M0)              r45.0<1>:ud   r4.6<0;1,0>:ud    r44.4<0;1,0>:ud  {AccWrEn,I@3}
        or (1|M0)                r44.5<1>:d    r43.2<0;1,0>:d    r43.1<0;1,0>:d   {I@2}
        mov (1|M0)               r44.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r42.0<1>:f    r45.0<0;1,0>:f                   {Compacted,I@3}
        add3 (1|M0)              r42.1<1>:d    r44.0<0;0>:d      r4.7<0;0>:d       r44.5<0>:d       {I@1}
        cmp (1|M0)    (eq)f0.0   null<1>:d     r2.3<0;1,0>:d     2:w              
        send.ugm (1|M0)          r45      r42     null:0  0x0            0x04100580           {A@1,$15} // wr:2+0, rd:1; load.ugm.d32.a64
        shl (1|M0)               r44.0<1>:w    r44.4<0;1,0>:w    2:w              
        add (1|M0)               a0.0<1>:uw    r44.0<0;1,0>:uw   0x4C0:uw              {A@1}
(W)     and (1|M0)               f0.0<1>:ud    f0.0<0;1,0>:uw    0x1:uw             
(W)     mov (1|M0)               r44.0<1>:f    r[a0.0]<0;1,0>:f                 {I@2}
        sync.nop                             null                             {Compacted,A@1}
        sync.nop                             null                             {Compacted,$15.dst}
        mad (1|M0)               r43.0<1>:f    r44.0<0;0>:f      r45.0<0;0>:f      r43.0<0>:f       {A@1}
(~f0.0.any32h) goto (32|M0)                  L34696                  L34696                
L34464:
        mov (1|M0)               r43.2<2>:hf   r43.0<0;1,0>:f                   {F@1}
        cmp (1|M0)    (lt)f0.0   null<1>:f     r43.0<0;1,0>:f    -4.001953e+00:f               {A@1}
        mov (1|M0)               r43.2<1>:f    r43.2<0;1,0>:hf                  {F@2}
        mov (1|M0)               r44.0<1>:ud   0x3EE50000:ud                             
        sel (1|M0)    (lt)f0.0   r43.2<1>:f    r43.2<0;1,0>:f    4.0:f               {F@1}
(~f0.0) sel (1|M0)               r43.0<1>:f    r43.2<0;1,0>:f    -4.0:f               {F@1}
        mov (1|M0)               r43.2<1>:ud   0xBD650000:ud                              {F@1}
        mad (1|M0)               r43.2<1>:f    r44.0<0;0>:f      r43.2<0;0>:f      (abs)r43.0<0>:f  {A@1}
        mov (1|M0)               r44.0<2>:hf   r43.2<0;1,0>:f                   {F@1}
        mov (1|M0)               r44.0<1>:f    r44.0<0;1,0>:hf                  {F@1}
        mul (1|M0)               r43.0<1>:f    r43.0<0;1,0>:f    r44.0<0;1,0>:f   {Compacted,F@1}
        mov (1|M0)               r43.0<2>:hf   r43.0<0;1,0>:f                   {F@1}
        add (1|M0)               r43.0<1>:hf   r43.0<0;1,0>:hf   0x3B28:hf              {F@1}
        mul (1|M0)               r43.0<1>:hf   r43.0<0;1,0>:hf   r43.2<0;1,0>:hf  {F@1}
        mov (1|M0)               r43.0<1>:f    r43.0<0;1,0>:hf                  {F@1}
L34696:
        join (32|M0)                         L35736                                
L34712:
        cmp (1|M0)    (eq)f0.0   null<1>:d     r2.2<0;1,0>:d     1:w              
(W)     and (1|M0)               f0.0<1>:ud    f0.0<0;1,0>:uw    0x1:uw             
(f0.0.any32h) goto (32|M0)                   L34840                  L34840                
L34760:
        cmp (1|M0)    (eq)f0.0   null<1>:d     r5.0<0;1,0>:d     4:w              
        mov (1|M0)               r44.0<2>:hf   r43.0<0;1,0>:f                   {F@1}
        mov (1|M0)               r42.0<1>:f    r44.0<0;1,0>:hf                  {F@1}
(~f0.0) mov (1|M0)               r42.0<1>:ud   r43.0<0;1,0>:ud                  {F@1}
        goto (32|M0)                         L34840                  L35240                
L34840:
        join (32|M0)                         L35240                                
L34856:
        cmp (1|M0)    (lt)f1.1   null<1>:f     r43.0<0;1,0>:f    0.0:f              
(f1.1)  mov (1|M0)               r43.0<1>:f    -r43.0<0;1,0>:f                  {I@3}
        sel (1|M0)    (lt)f0.0   r43.0<1>:f    r43.0<0;1,0>:f    448.0:f               {F@1}
        shr (1|M0)               r43.1<1>:ud   r43.0<0;1,0>:ud   0x17:uw              {F@1}
        and (1|M0)               r43.1<1>:ud   r43.1<0;1,0>:ud   0xFF:uw              {I@1}
        sel (1|M0)    (ge)f0.0   r43.1<1>:ud   r43.1<0;1,0>:ud   0x79:uw              {I@1}
        shl (1|M0)               r43.1<1>:ud   r43.1<0;1,0>:ud   0x17:uw              {I@1}
        add (1|M0)               r43.3<1>:ud   -r43.1<0;1,0>:ud  0x80800000:ud              {I@1}
        mul (1|M0)               r44.0<1>:f    r43.0<0;1,0>:f    r43.3<0;1,0>:f   {Compacted,I@1}
        mov (1|M0)               r43.2<1>:d    r44.0<0;1,0>:f                   {Compacted,F@1}
        mov (1|M0)               r42.0<1>:f    r43.2<0;1,0>:d                   {Compacted,I@1}
        mad (1|M0)               r43.0<1>:f    -r42.0<0;0>:f     r43.3<0;0>:f      r43.0<0>:f       {F@1}
        cmp (1|M0)    (gt)f0.0   null<1>:f     r43.0<0;1,0>:f    0.5:f               {F@1}
(W)     and (1|M0)               f0.0<1>:ud    f0.0<0;1,0>:uw    0x1:uw              {F@1}
(f0.0.any32h) goto (32|M0)                   L35160                  L35160                
L35072:
        cmp (1|M0)    (lt)f0.0   null<1>:f     r43.0<0;1,0>:f    0.5:f               {A@1}
        and (1|M0)               r43.2<1>:d    r43.2<0;1,0>:d    1:w              
        add (1|M0)               r43.3<1>:f    r42.0<0;1,0>:f    1.0:f               {Compacted}
(~f0.0) cmp (1|M0)    (eq)f0.0   null<1>:d     r43.2<0;1,0>:d    0:w               {A@1}
(~f0.0) mov (1|M0)               r42.0<1>:f    r43.3<0;1,0>:f                   {F@1}
        goto (32|M0)                         L35160                  L35184                
L35160:
        join (32|M0)                         L35184                                
L35176:
        add (1|M0)               r42.0<1>:f    r42.0<0;1,0>:f    1.0:f               {Compacted,F@1}
L35184:
        join (32|M0)                         L35240                                
L35200:
        add (1|M0)               r43.1<1>:ud   r43.1<0;1,0>:ud   0xFE800000:ud             
        mul (1|M0)               r42.0<1>:f    r42.0<0;1,0>:f    r43.1<0;1,0>:f   {Compacted,A@1}
(f1.1)  mov (1|M0)               r42.0<1>:f    -r42.0<0;1,0>:f                  {F@1}
L35240:
        join (32|M0)                         L35736                                
L35256:
        and (1|M0)               r44.0<2>:b    r5.4<0;1,0>:b     1:w              
        cmp (1|M0)    (eq)f0.0   null<1>:w     r44.0<0;1,0>:b    0:w               {I@1}
(W)     and (1|M0)               f0.0<1>:ud    f0.0<0;1,0>:uw    0x1:uw             
(f0.0.any32h) goto (32|M0)                   L35488                  L35488                
L35320:
        shl (1|M0)               r44.1<1>:d    r44.3<0;1,0>:d    1:w              
        shr (1|M0)               r44.0<1>:ud   r44.2<0;1,0>:ud   0x1F:uw             
        shl (1|M0)               r44.5<1>:d    r44.2<0;1,0>:d    1:w              
        or (1|M0)                r44.6<1>:d    r44.1<0;1,0>:d    r44.0<0;1,0>:d   {I@2}
        addc (1|M0)              r44.0<1>:ud   r42.2<0;1,0>:ud   r44.5<0;1,0>:ud  {AccWrEn,I@2}
        mov (1|M0)               r44.8<2>:hf   r42.0<0;1,0>:f                   {F@1}
        mov (1|M0)               r43.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r42.0<1>:d    r44.8<0;1,0>:uw                  {F@1}
        add3 (1|M0)              r44.1<1>:d    r43.0<0;0>:d      r42.3<0;0>:d      r44.6<0>:d       {I@2}
        send.ugm (1|M0)          null     r44     r42:1   0x0            0x04000B84           {A@1,$9} // wr:2+1, rd:0; store.ugm.d16u32.a64
        goto (32|M0)                         L35488                  L35560                
L35488:
        join (32|M0)                         L35560                                
L35504:
        addc (1|M0)              r44.0<1>:ud   r42.6<0;1,0>:ud   r44.4<0;1,0>:ud  {AccWrEn,$9.src}
        mov (1|M0)               r43.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        add3 (1|M0)              r44.1<1>:d    r43.0<0;0>:d      r42.7<0;0>:d      r44.5<0>:d       {I@1}
        send.ugm (1|M0)          null     r44     r42:1   0x0            0x04000584           {A@1,$11} // wr:2+1, rd:0; store.ugm.d32.a64
L35560:
        join (32|M0)                         L35736                                
L35576:
        addc (1|M0)              r43.0<1>:ud   r44.2<0;1,0>:ud   0x1:ud              {AccWrEn}
        sync.nop                             null                             {Compacted,$11.src}
        mov (1|M0)               r44.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,$9.src}
        mov (1|M0)               r44.4<1>:d    r43.0<0;1,0>:d                   {I@2}
        add3 (1|M0)              r44.5<1>:d    r44.0<0;0>:d      r44.3<0;0>:d      0:w               {I@2}
        cmp (1|M0)    (eq)f0.0   null<1>:d     r44.5<0;1,0>:d    0:w               {I@1}
(f0.0)  cmp (1|M0)    (eq)f0.0   null<1>:d     r44.4<0;1,0>:d    32:w              
(W)     and (1|M0)               f0.0<1>:ud    f0.0<0;1,0>:uw    0x1:uw             
(f0.0.any32h) goto (32|M0)                   L35736                  L35736                
L35704:
(W)     mov (2|M0)               r44.2<1>:ud   r44.4<1;1,0>:ud                 
        goto.b (32|M0)                       L35736                  L33872                
L35736:
        join (32|M0)                         L35920                                
L35752:
        addc (1|M0)              r39.0<1>:ud   r3.6<0;1,0>:ud    0x1:ud              {AccWrEn}
        add (1|M0)               r2.7<1>:d     r2.7<0;1,0>:d     1:w              
        mov (1|M0)               r38.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r5.6<1>:d     r39.0<0;1,0>:d                   {I@3}
        add3 (1|M0)              r5.7<1>:d     r38.0<0;0>:d      r3.7<0;0>:d       0:w               {I@2}
        cmp (1|M0)    (eq)f0.0   null<1>:d     r5.7<0;1,0>:d     0:w               {I@1}
(f0.0)  cmp (1|M0)    (eq)f0.0   null<1>:d     r5.6<0;1,0>:d     8:w              
(W)     and (1|M0)               f0.0<1>:ud    f0.0<0;1,0>:uw    0x1:uw             
(f0.0.any32h) goto (32|M0)                   L35920                  L35920                
L35888:
(W)     mov (2|M0)               r3.6<1>:ud    r5.6<1;1,0>:ud                  
        goto.b (32|M0)                       L35920                  L32608                
L35920:
        join (32|M0)                         L36192                                
L35936:
(W)     send.slm (1|M0)          r6       r0      null:0  0x0            0x0210001F           {$5} // wr:1+0, rd:1; fence.slm.none.group
(W)     mov (8|M0)               null<1>:ud    r6.0<1;1,0>:ud                   {$5.dst}
(W)     mov (1|M0)               r6.2<1>:f     0.0:f                               {Compacted,I@1}
(W)     mov (2|M0)               r6.10<1>:ub   r0.11<0;1,0>:ub                  {F@1}
(W)     send.gtwy (1|M0)         null     r6      null:0  0x0            0x02000004           {A@1,$0} // wr:1+0, rd:0; signal barrier
(W)     sync.bar                             null                            
        cmp (1|M0)    (lt)f0.0   null<1>:ud    r3.2<0;1,0>:ud    0x38:uw             
        addc (1|M0)              r7.0<1>:ud    r3.2<0;1,0>:ud    0x8:ud              {AccWrEn}
        add (1|M0)               r1.6<1>:ud    r1.6<0;1,0>:ud    0x8:uw             
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$0.src}
(f0.0)  cmp (1|M0)    (eq)f0.0   null<1>:d     r3.3<0;1,0>:d     0:w              
        mov (1|M0)               r3.4<1>:d     r7.0<0;1,0>:d                    {I@4}
        add3 (1|M0)              r3.5<1>:d     r6.0<0;0>:d       r3.3<0;0>:d       0:w               {I@3}
(W)     and (1|M0)               f0.0<1>:ud    f0.0<0;1,0>:uw    0x1:uw             
(~f0.0.any32h) goto (32|M0)                  L36192                  L36192                
L36160:
(W)     mov (2|M0)               r3.2<1>:ud    r3.4<1;1,0>:ud                   {I@3}
        goto.b (32|M0)                       L36192                  L30592                
L36192:
        join (32|M0)                         L36208                                
L36208:
(W)     mov (8|M0)               r112.0<1>:f   r0.0<1;1,0>:f                    {Compacted,$10.src}
(W)     send.ugm (1|M0)          r2       r0      null:0  0x0            0x0210641F           {$1} // wr:1+0, rd:1; fence invalid flush type scoped to tile
(W)     mov (8|M0)               null<1>:ud    r2.0<1;1,0>:ud                   {$1.dst}
(W)     send.gtwy (1|M0)         null     r112    null:0  0x0            0x02000010           {EOT,A@1} // wr:1+0, rd:0; end of thread
L36264:
        mov (1|M0)               r1.7<1>:d     cr0.0<0;1,0>:ud                  {A@1}
        and (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   -1265:w               {A@1}
        or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   1264:w               {A@1}
        mov (1|M0)               r6.0<1>:f     r5.7<0;1,0>:ud                   {Compacted,A@1}
        mov (1|M0)               r34.5<1>:f    r6.5<0;1,0>:ud                  
        math.inv (1|M0)          r6.2<1>:f     r6.0<0;1,0>:f                    {@2,$2}
        mov (1|M0)               r1.3<1>:f     0xB4C00000:f                               {Compacted}
        mov (1|M0)               r6.1<1>:ud    r34.5<0;1,0>:f                   {F@2}
        sync.nop                             null                             {Compacted,$2.dst}
        mad (1|M0)               r6.2<1>:f     r6.2<0;0>:f       r1.3<0;0>:f       r6.2<0>:f        {F@1}
        mov (1|M0)               r6.4<1>:ud    r6.0<0;1,0>:f                   
        add (1|M0)               r6.1<1>:ud    r6.5<0;1,0>:ud    -r6.1<0;1,0>:ud  {I@2}
        mul (1|M0)               r1.3<1>:f     r6.2<0;1,0>:f     r34.5<0;1,0>:f   {F@1}
        add (1|M0)               r6.4<1>:ud    r5.7<0;1,0>:ud    -r6.4<0;1,0>:ud  {I@2}
        mov (1|M0)               r6.3<1>:f     r6.1<0;1,0>:ud                   {I@2}
        mov (1|M0)               r6.1<1>:ud    r1.3<0;1,0>:f                    {A@1}
        mov (1|M0)               r34.4<1>:f    r6.4<0;1,0>:ud                   {I@2}
        mov (1|M0)               r6.6<1>:f     r6.1<0;1,0>:ud                   {I@1}
(W)     mov (1|M0)               r1.3<1>:hf    0x1:hf                             
        mad (1|M0)               r34.5<1>:f    r34.5<0;0>:f      r6.6<0;0>:f       -r6.0<0>:f       {F@2}
        mad (1|M0)               r6.6<1>:f     r6.3<0;0>:f       r6.6<0;0>:f       -r34.4<0>:f     
        add (1|M0)               r34.5<1>:f    r34.5<0;1,0>:f    r6.6<0;1,0>:f    {F@1}
        mul (1|M0)               r6.2<1>:f     r6.2<0;1,0>:f     r34.5<0;1,0>:f   {F@1}
        mov (1|M0)               r1.3<1>:ud    r6.2<0;1,0>:f                    {F@1}
        add (1|M0)               r6.1<1>:ud    r6.1<0;1,0>:ud    r1.3<0;1,0>:ud   {I@1}
(W)     mul (1|M0)               acc0.0<1>:ud  r6.1<0;1,0>:ud    r5.14<0;1,0>:uw  {I@1}
        mach (1|M0)              r6.0<1>:ud    r6.1<0;1,0>:ud    r5.7<0;1,0>:ud  
        add (1|M0)               r6.5<1>:ud    r6.5<0;1,0>:ud    -r6.0<0;1,0>:ud  {I@1}
        cmp (1|M0)    (ge)f0.0   null<1>:ud    r6.5<0;1,0>:ud    r5.7<0;1,0>:ud   {I@1}
(f0.0)  sel (1|M0)               r1.3<1>:d     r1.3<0;1,0>:w     0:w              
        add (1|M0)               r1.3<1>:ud    r6.1<0;1,0>:ud    r1.3<0;1,0>:ud   {I@1}
        mov (1|M0)               cr0.0<1>:ud   r1.7<0;1,0>:d                    {A@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        ret (32|M0)                          r1.4                             {A@1}
L36800:
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
