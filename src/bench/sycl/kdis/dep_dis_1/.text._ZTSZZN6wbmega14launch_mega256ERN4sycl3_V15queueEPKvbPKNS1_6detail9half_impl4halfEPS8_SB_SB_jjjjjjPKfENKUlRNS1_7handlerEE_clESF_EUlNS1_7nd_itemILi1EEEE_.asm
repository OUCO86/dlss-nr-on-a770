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
        sync.nop                             null                             {Compacted,A@1}
        sync.nop                             null                             {Compacted,$0.dst}
        mov (1|M0)               r95.1<1>:d    r1.0<0;1,0>:uw                   {A@1}
        mov (1|M0)               r95.7<1>:d    r0.1<0;1,0>:ud                  
        shr (1|M0)               r96.2<1>:ud   r95.1<0;1,0>:ud   0x5:uw              {I@2}
        and (1|M0)               r95.20<2>:b   r2.28<0;1,0>:b    1:w              
        mul (1|M0)               r95.6<1>:d    r96.2<0;1,0>:d    2560:w               {I@2}
        and (1|M0)               r95.4<1>:d    r1.0<0;1,0>:uw    31:w              
        mov (1|M0)               r96.3<1>:d    r2.2<0;1,0>:d                   
        mov (1|M0)               r96.5<1>:d    r95.7<0;1,0>:d                  
        add (1|M0)               r101.0<1>:d   r95.6<0;1,0>:d    512:w               {Compacted,I@4}
        add (1|M0)               r95.0<1>:d    r95.6<0;1,0>:d    1024:w               {Compacted}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (32|M0)             r95.2         L10176                                 {A@1}
L464:
        cmp (1|M0)    (lt)f0.0   null<1>:ud    r95.4<0;1,0>:ud   0x8:uw              {I@6}
        shl (1|M0)               r96.3<1>:d    r5.0<0;1,0>:d     3:w               {Compacted}
        shl (1|M0)               r95.2<1>:d    r95.7<0;1,0>:d    6:w              
        add3 (1|M0)              r96.3<1>:d    r96.3<0;0>:d      r96.2<0;0>:d      -r2.3<0>:d       {I@2}
(W)     and (1|M0)               f0.0<1>:ud    f0.0<0;1,0>:uw    0x1:uw             
        shl (1|M0)               r96.2<1>:d    r96.2<0;1,0>:d    3:w              
        add (1|M0)               r95.2<1>:d    r95.2<0;1,0>:d    r96.2<0;1,0>:d   {I@1}
(~f0.0.any32h) goto (32|M0)                  L2368                  L2368                
L584:
(W)     mul (1|M0)               acc0.0<1>:d   r5.0<0;1,0>:d     r2.4<0;1,0>:uw   {Compacted}
        mach (1|M0)              r5.0<1>:d     r5.0<0;1,0>:d     r2.2<0;1,0>:d    {Compacted}
        cmp (1|M0)    (lt)f0.0   null<1>:d     r96.3<0;1,0>:d    r2.5<0;1,0>:d   
        add (1|M0)               r95.7<1>:d    r95.7<0;1,0>:d    -r5.0<0;1,0>:d   {I@2}
(W)     mov (1|M0)               r1.3<1>:hf    0x1:hf                             
        shl (1|M0)               r95.7<1>:d    r95.7<0;1,0>:d    3:w               {I@1}
(f0.0)  cmp (1|M0)    (gt)f0.0   null<1>:d     r96.3<0;1,0>:d    -1:w              
        add3 (1|M0)              r95.7<1>:ud   r95.7<0;0>:ud     -r2.4<0;0>:ud     r95.4<0>:ud      {I@2}
        cmp (1|M0)    (lt)f0.1   null<1>:d     r95.7<0;1,0>:d    r2.6<0;1,0>:d    {I@1}
(f0.0)  sel (1|M0)               r1.4<1>:uw    r1.3<0;1,0>:uw    0x0:uw              {F@1}
(f0.1)  cmp (1|M0)    (gt)f0.1   null<1>:d     r95.7<0;1,0>:d    -1:w              
(f0.1)  sel (1|M0)               r2.0<1>:uw    r1.3<0;1,0>:uw    0x0:uw             
        and (1|M0)    (ne)f0.0   null<1>:uw    r1.4<0;1,0>:uw    r2.0<0;1,0>:uw   {I@1}
(W)     and (1|M0)               f0.0<1>:ud    f0.0<0;1,0>:uw    0x1:uw             
(f0.0.any32h) goto (32|M0)                   L840                  L840                
L808:
        mov (32|M0)              r102.0<1>:uw  0x0:uw                             
        goto (32|M0)                         L840                  L2296                
L840:
        join (32|M0)                         L2296                                
L856:
        mul (1|M0)               acc0.0<1>:ud  r96.3<0;1,0>:ud   r2.12<0;1,0>:uw 
        mach (1|M0)              r6.0<1>:ud    r96.3<0;1,0>:ud   r2.6<0;1,0>:ud   {AccWrEn}
        mov (1|M0)               r96.4<2>:f    0.0:f                              
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r96.5<2>:f    0.0:f                              
        addc (1|M0)              r2.0<1>:ud    r5.0<0;1,0>:ud    r95.7<0;1,0>:ud  {AccWrEn,I@1}
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
        mov (1|M0)               r96.2<1>:d    r9.0<0;1,0>:d                   
        mov (1|M0)               r4.6<1>:d     0:w                              
        mov (1|M0)               r4.4<1>:d     r2.0<0;1,0>:d                    {I@6}
        add3 (1|M0)              r96.3<1>:d    r10.0<0;0>:d      r3.1<0;0>:d       r8.3<0>:d        {I@6}
        add3 (1|M0)              r4.5<1>:d     r5.0<0;0>:d       r3.1<0;0>:d       r1.5<0>:d        {I@5}
L1272:
        cmp (1|M0)    (eq)f0.0   null<1>:w     r95.20<0;1,0>:b   0:w              
(W)     and (1|M0)               f0.0<1>:ud    f0.0<0;1,0>:uw    0x1:uw             
(f0.0.any32h) goto (32|M0)                   L1480                  L1480                
L1320:
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
        goto (32|M0)                         L1480                  L1624                
L1480:
        join (32|M0)                         L1624                                
L1496:
        shl (1|M0)               r1.4<1>:d     r96.4<0;1,0>:d    2:w              
        shl (1|M0)               r1.2<1>:d     r96.5<0;1,0>:d    2:w              
        shr (1|M0)               r1.3<1>:ud    r96.4<0;1,0>:ud   0x1E:uw             
        addc (1|M0)              r2.0<1>:ud    r96.2<0;1,0>:ud   r1.4<0;1,0>:ud   {AccWrEn,A@1}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r6.0<1>:f     r2.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r6.1<1>:d     r5.0<0;0>:d       r96.3<0;0>:d      r1.5<0>:d        {I@1}
        send.ugm (1|M0)          r2       r6      null:0  0x0            0x04100580           {A@1,$4} // wr:2+0, rd:1; load.ugm.d32.a64
L1624:
        join (32|M0)                         L2296                                
L1640:
        cmp (1|M0)    (lt)f1.0   null<1>:f     r2.0<0;1,0>:f     0.0:f               {$4.dst}
(f1.0)  mov (1|M0)               r2.0<1>:f     -r2.0<0;1,0>:f                  
        sel (1|M0)    (lt)f0.0   r2.0<1>:f     r2.0<0;1,0>:f     448.0:f               {F@1}
        shr (1|M0)               r95.3<1>:ud   r2.0<0;1,0>:ud    0x17:uw              {F@1}
        and (1|M0)               r95.3<1>:ud   r95.3<0;1,0>:ud   0xFF:uw              {I@1}
        sel (1|M0)    (ge)f0.0   r95.3<1>:ud   r95.3<0;1,0>:ud   0x79:uw              {I@1}
        shl (1|M0)               r95.3<1>:ud   r95.3<0;1,0>:ud   0x17:uw              {I@1}
        add (1|M0)               r1.2<1>:ud    -r95.3<0;1,0>:ud  0x80800000:ud              {I@1}
        mul (1|M0)               r1.3<1>:f     r2.0<0;1,0>:f     r1.2<0;1,0>:f    {I@1}
        mov (1|M0)               r2.1<1>:d     r1.3<0;1,0>:f                    {F@1}
        mov (1|M0)               r4.7<1>:f     r2.1<0;1,0>:d                    {I@1}
        mad (1|M0)               r2.0<1>:f     -r4.7<0;0>:f      r1.2<0;0>:f       r2.0<0>:f        {F@1}
        cmp (1|M0)    (gt)f0.0   null<1>:f     r2.0<0;1,0>:f     0.5:f               {F@1}
(W)     and (1|M0)               f0.0<1>:ud    f0.0<0;1,0>:uw    0x1:uw              {F@1}
(f0.0.any32h) goto (32|M0)                   L1968                  L1968                
L1880:
        cmp (1|M0)    (lt)f0.0   null<1>:f     r2.0<0;1,0>:f     0.5:f               {A@1}
        and (1|M0)               r2.1<1>:d     r2.1<0;1,0>:d     1:w               {Compacted}
        add (1|M0)               r1.2<1>:f     r4.7<0;1,0>:f     1.0:f              
(~f0.0) cmp (1|M0)    (eq)f0.0   null<1>:d     r2.1<0;1,0>:d     0:w               {A@1}
(~f0.0) mov (1|M0)               r4.7<1>:f     r1.2<0;1,0>:f                    {F@1}
        goto (32|M0)                         L1968                  L2000                
L1968:
        join (32|M0)                         L2000                                
L1984:
        add (1|M0)               r4.7<1>:f     r4.7<0;1,0>:f     1.0:f               {F@1}
L2000:
        join (32|M0)                         L2296                                
L2016:
        addc (1|M0)              r5.0<1>:ud    r96.4<0;1,0>:ud   0x1:ud              {AccWrEn}
        add (1|M0)               r95.3<1>:ud   r95.3<0;1,0>:ud   0xFE800000:ud             
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r1.2<1>:d     r5.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r1.3<1>:d     r6.0<0;0>:d       r96.5<0;0>:d      0:w               {I@2}
        mul (1|M0)               r4.7<1>:f     r4.7<0;1,0>:f     r95.3<0;1,0>:f   {F@1}
        cmp (1|M0)    (eq)f0.0   null<1>:d     r1.3<0;1,0>:d     0:w               {I@1}
(f1.0)  mov (1|M0)               r4.7<1>:f     -r4.7<0;1,0>:f                   {F@1}
        shl (1|M0)               r1.3<1>:w     r4.12<0;1,0>:w    1:w              
(W)     mov (1|M0)               r2.0<2>:hf    r4.7<0;1,0>:f                    {F@1}
(f0.0)  cmp (1|M0)    (eq)f0.0   null<1>:d     r1.2<0;1,0>:d     32:w              
        add (1|M0)               r4.6<1>:d     r4.6<0;1,0>:d     1:w              
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0xCC0:uw              {A@1}
        mov (1|M0)               r[a0.0]<1>:hf  r2.0<0;1,0>:hf                  {F@1}
(W)     and (1|M0)               f0.0<1>:ud    f0.0<0;1,0>:uw    0x1:uw             
(f0.0.any32h) goto (32|M0)                   L2296                  L2296                
L2264:
(W)     mov (2|M0)               r96.4<1>:ud   r1.2<1;1,0>:ud                  
        goto.b (32|M0)                       L2296                  L1272                
L2296:
        join (32|M0)                         L2368                                
L2312:
        shl (1|M0)               r1.2<1>:ud    r95.4<0;1,0>:ud   0x6:uw             
        sync.nop                             null                             {Compacted,$4.dst}
        or (1|M0)                r2.0<1>:d     r95.6<0;1,0>:d    r1.2<0;1,0>:d    {A@1}
        send.slm (1|M0)          null     r2      r102:2  0x0            0x0200C704           {A@1,$5} // wr:1+2, rd:0; store.slm.d64x8t.a32
L2368:
        join (32|M0)                         L2384                                
L2384:
(W)     send.slm (1|M0)          r5       r0      null:0  0x0            0x0210001F           {$6} // wr:1+0, rd:1; fence.slm.none.group
(W)     mov (1|M0)               r6.2<1>:f     0.0:f                               {Compacted,$4.src}
(W)     mov (2|M0)               r6.10<1>:ub   r0.11<0;1,0>:ub                  {F@1}
(W)     mov (8|M0)               null<1>:ud    r5.0<1;1,0>:ud                   {$6.dst}
(W)     send.gtwy (1|M0)         null     r6      null:0  0x0            0x02000004           {A@2,$7} // wr:1+0, rd:0; signal barrier
(W)     sync.bar                             null                            
        cmp (1|M0)    (lt)f0.0   null<1>:ud    r95.4<0;1,0>:ud   0x4:uw             
(W)     and (1|M0)               f0.0<1>:ud    f0.0<0;1,0>:uw    0x1:uw             
(~f0.0.any32h) goto (32|M0)                  L3024                  L3024                
L2520:
        and (1|M0)               r1.2<1>:d     r1.0<0;1,0>:uw    1:w              
        cmp (1|M0)    (lt)f0.0   null<1>:ud    r95.4<0;1,0>:ud   0x2:uw             
        shl (1|M0)               r1.3<1>:d     r1.2<0;1,0>:d     8:w               {I@2}
(W)     mov (1|M0)               r1.3<1>:hf    0.0:hf                             
        or (1|M0)                r5.0<1>:d     r95.6<0;1,0>:d    r1.3<0;1,0>:d    {I@1}
        sync.nop                             null                             {Compacted,$4.dst}
        sync.nop                             null                             {Compacted,$5.src}
(f0.0)  sel (1|M0)               r2.0<1>:w     r1.3<0;1,0>:w     32:w               {F@1}
        send.slm (1|M0)          r110     r5      null:0  0x0            0x0220C700           {A@2,$8} // wr:1+0, rd:2; load.slm.d64x8t.a32
        or (1|M0)                r10.0<1>:ud   r5.0<0;1,0>:ud    0x40:uw             
        add (1|M0)               a0.0<1>:uw    r2.0<0;1,0>:uw    0xDC0:uw              {A@1}
        send.slm (1|M0)          r108     r10     null:0  0x0            0x0220C700           {A@2,$9} // wr:1+0, rd:2; load.slm.d64x8t.a32
        or (1|M0)                r11.0<1>:ud   r5.0<0;1,0>:ud    0x80:uw             
        or (1|M0)                r12.0<1>:ud   r5.0<0;1,0>:ud    0xC0:uw             
        send.slm (1|M0)          r106     r11     null:0  0x0            0x0220C700           {A@2,$10} // wr:1+0, rd:2; load.slm.d64x8t.a32
        sync.nop                             null                             {Compacted,$8.dst}
        mov (8|M0)               r6.0<1>:uw    r[a0.0]<1;1,0>:uw                {$7.src}
        mov (8|M0)               r6.8<1>:uw    r[a0.0,16]<1;1,0>:uw             {A@1}
        add (1|M0)               a0.0<1>:uw    r2.0<0;1,0>:uw    0xD80:uw              {A@1}
        send.slm (1|M0)          r104     r12     null:0  0x0            0x0220C700           {A@4,$11} // wr:1+0, rd:2; load.slm.d64x8t.a32
        shl (1|M0)               r1.3<1>:ud    r95.1<0;1,0>:ud   0x7:uw             
        shl (1|M0)               r1.2<1>:d     r1.2<0;1,0>:d     7:w              
        mov (8|M0)               r7.0<1>:uw    r[a0.0]<1;1,0>:uw                {$9.dst}
        mov (8|M0)               r7.8<1>:uw    r[a0.0,16]<1;1,0>:uw             {A@1}
        add (1|M0)               a0.0<1>:uw    r2.0<0;1,0>:uw    0xD40:uw              {A@1}
        and (1|M0)               r1.3<1>:ud    r1.3<0;1,0>:ud    0xF00:uw              {I@5}
        bfn.0xFE (1|M0)          r10.0<1>:ud   r101.0<0;0>:ud    r1.3<0;0>:ud      r1.2<0>:ud       {I@1} // s0|s1|s2
        mov (8|M0)               r8.0<1>:uw    r[a0.0]<1;1,0>:uw                {$10.dst}
        mov (8|M0)               r8.8<1>:uw    r[a0.0,16]<1;1,0>:uw             {A@1}
        add (1|M0)               a0.0<1>:uw    r2.0<0;1,0>:uw    0xD00:uw              {A@1}
        mov (8|M0)               r9.0<1>:uw    r[a0.0]<1;1,0>:uw                {$11.dst}
        mov (8|M0)               r9.8<1>:uw    r[a0.0,16]<1;1,0>:uw             {A@1}
        send.slm (1|M0)          null     r10     r6:4    0x0            0x0200D704           {A@1,$12} // wr:1+4, rd:0; store.slm.d64x16t.a32
L3024:
        join (32|M0)                         L3040                                
L3040:
(W)     send.slm (1|M0)          r5       r0      null:0  0x0            0x0210001F           {$13} // wr:1+0, rd:1; fence.slm.none.group
        sync.nop                             null                             {Compacted,$12.src}
(W)     mov (1|M0)               r6.2<1>:f     0.0:f                               {Compacted,$7.src}
(W)     mov (2|M0)               r6.10<1>:ub   r0.11<0;1,0>:ub                  {F@1}
(W)     mov (8|M0)               null<1>:ud    r5.0<1;1,0>:ud                   {$13.dst}
(W)     send.gtwy (1|M0)         null     r6      null:0  0x0            0x02000004           {A@2,$14} // wr:1+0, rd:0; signal barrier
(W)     sync.bar                             null                            
        shr (1|M0)               r95.4<1>:ud   r95.4<0;1,0>:ud   0x2:uw             
        shl (1|M0)               r95.1<1>:ud   r95.1<0;1,0>:ud   0x1:uw             
        sync.nop                             null                             {Compacted,$4.dst}
        sync.nop                             null                             {Compacted,$5.src}
        or (1|M0)                r2.0<1>:d     r95.2<0;1,0>:d    r95.4<0;1,0>:d   {I@2}
        shl (1|M0)               r1.2<1>:ud    r95.4<0;1,0>:ud   0x7:uw             
        shl (1|M0)               r4.5<1>:d     r2.0<0;1,0>:d     5:w               {Compacted,I@2}
        shr (1|M0)               r4.4<1>:ud    r2.0<0;1,0>:ud    0x1B:uw             
        shl (1|M0)               r95.4<1>:d    r4.5<0;1,0>:d     1:w               {I@2}
        or (1|M0)                r4.6<1>:d     r4.4<0;1,0>:d     0:w               {I@2}
        sync.nop                             null                             {Compacted,$14.src}
        addc (1|M0)              r6.0<1>:ud    r4.2<0;1,0>:ud    r95.4<0;1,0>:ud  {AccWrEn,I@2}
        shr (1|M0)               r5.1<1>:ud    r4.5<0;1,0>:ud    0x1F:uw             
        shl (1|M0)               r5.0<1>:d     r4.6<0;1,0>:d     1:w               {Compacted,I@3}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r2.0<1>:ud    r3.2<0;1,0>:ud    0xC00:ud              {AccWrEn}
        mov (1|M0)               r95.2<1>:d    r6.0<0;1,0>:d                    {I@5}
        or (1|M0)                r95.5<1>:d    r5.0<0;1,0>:d     r5.1<0;1,0>:d    {I@4}
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r6.0<1>:ud    r3.2<0;1,0>:ud    0xE00:ud              {AccWrEn}
        add (1|M0)               r115.0<1>:d   r95.6<0;1,0>:d    1152:w               {Compacted}
        add (1|M0)               r113.0<1>:d   r95.6<0;1,0>:d    1280:w               {Compacted}
        add (1|M0)               r111.0<1>:d   r95.6<0;1,0>:d    1408:w               {Compacted}
        add (1|M0)               r109.0<1>:d   r95.6<0;1,0>:d    1536:w               {Compacted}
        add (1|M0)               r107.0<1>:d   r95.6<0;1,0>:d    1664:w               {Compacted}
        add (1|M0)               r105.0<1>:d   r95.6<0;1,0>:d    1792:w               {Compacted}
        add (1|M0)               r118.0<1>:d   r95.6<0;1,0>:d    1920:w               {Compacted}
        mov (2|M0)               r101.4<1>:d   0x1:v                              
        add3 (1|M0)              r95.3<1>:d    r7.0<0;0>:d       r4.3<0;0>:d       r95.5<0>:d       {I@7}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (16|M0)              r83.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r85.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r87.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r89.0<1>:f    0.0:f                               {Compacted}
        or (1|M0)                r117.0<1>:ud  r101.0<0;1,0>:ud  0x100:uw             
        or (1|M0)                r116.0<1>:d   r95.0<0;1,0>:d    64:w               {Compacted}
        mov (1|M0)               r95.7<2>:f    0.0:f                              
        and (1|M0)               r95.1<1>:ud   r95.1<0;1,0>:ud   0x6:uw             
        add (1|M0)               r102.0<1>:d   r95.0<0;1,0>:d    r1.2<0;1,0>:d    {Compacted}
        mov (1|M0)               r96.4<1>:d    r2.0<0;1,0>:d                   
        add3 (1|M0)              r96.5<1>:d    r5.0<0;0>:d       r3.3<0;0>:d       0:w              
        mov (1|M0)               r96.2<1>:d    r6.0<0;1,0>:d                   
        or (1|M0)                r114.0<1>:d   r115.0<0;1,0>:d   64:w               {Compacted}
        or (1|M0)                r112.0<1>:d   r113.0<0;1,0>:d   64:w               {Compacted}
        or (1|M0)                r110.0<1>:d   r111.0<0;1,0>:d   64:w               {Compacted}
        or (1|M0)                r108.0<1>:d   r109.0<0;1,0>:d   64:w               {Compacted}
        or (1|M0)                r106.0<1>:d   r107.0<0;1,0>:d   64:w               {Compacted}
        or (1|M0)                r104.0<1>:d   r105.0<0;1,0>:d   64:w               {Compacted}
        mov (1|M0)               r95.6<2>:f    0.0:f                              
        or (1|M0)                r103.0<1>:d   r118.0<0;1,0>:d   64:w               {Compacted}
        mul (2|M0)               r101.4<1>:d   r101.4<1;1,0>:d   256:w              
        add3 (1|M0)              r96.3<1>:d    r7.0<0;0>:d       r3.3<0;0>:d       0:w              
L3744:
        shl (1|M0)               r1.2<1>:d     r95.7<0;1,0>:d    9:w               {F@2}
        shr (1|M0)               r1.3<1>:ud    r95.6<0;1,0>:ud   0x17:uw              {F@1}
        shl (1|M0)               r1.4<1>:d     r95.6<0;1,0>:d    9:w              
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        shl (1|M0)               r4.4<1>:d     r1.4<0;1,0>:d     1:w               {I@2}
        shr (1|M0)               r2.1<1>:ud    r1.4<0;1,0>:ud    0x1F:uw             
        shl (1|M0)               r2.0<1>:d     r1.5<0;1,0>:d     1:w               {Compacted,I@3}
        addc (1|M0)              r13.0<1>:ud   r3.2<0;1,0>:ud    r4.4<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r4.5<1>:d     r2.0<0;1,0>:d     r2.1<0;1,0>:d    {I@2}
        mov (1|M0)               r14.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,$0.src}
        sync.nop                             null                             {Compacted,$1.src}
        mov (1|M0)               r15.0<1>:f    r13.0<0;1,0>:f                   {Compacted,I@3}
        add3 (1|M0)              r15.1<1>:d    r14.0<0;0>:d      r3.3<0;0>:d       r4.5<0>:d        {I@1}
        or (2|M0)                r1.4<1>:d     r1.4<1;1,0>:d     r101.4<1;1,0>:d 
        send.ugm (1|M0)          r16      r15     null:0  0x0            0x0280E780           {A@1,$6} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        sync.allrd                           ($4,$5,$15)                
        send.slm (1|M0)          r5       r101    null:0  0x0            0x0280E700           {$7} // wr:1+0, rd:8; load.slm.d64x32t.a32
        addc (1|M0)              r24.0<1>:ud   r15.0<0;1,0>:ud   0x100:ud              {AccWrEn}
        shl (1|M0)               r2.0<1>:d     r1.4<0;1,0>:d     1:w               {Compacted,I@2}
        mov (1|M0)               r25.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r13.0<1>:ud   r3.2<0;1,0>:ud    r2.0<0;1,0>:ud   {AccWrEn,I@2}
        shl (1|M0)               r1.2<1>:d     r1.5<0;1,0>:d     1:w              
        shr (1|M0)               r1.3<1>:ud    r1.4<0;1,0>:ud    0x1F:uw             
        sync.nop                             null                             {Compacted,$6.src}
        mov (1|M0)               r15.0<1>:f    r13.0<0;1,0>:f                   {Compacted,I@3}
        mov (1|M0)               r14.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        or (1|M0)                r2.1<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        add3 (1|M0)              r26.1<1>:d    r25.0<0;0>:d      r15.1<0;0>:d      0:w              
        add3 (1|M0)              r15.1<1>:d    r14.0<0;0>:d      r3.3<0;0>:d       r2.1<0>:d        {I@2}
        mov (1|M0)               r26.0<1>:f    r24.0<0;1,0>:f                   {Compacted}
        send.ugm (1|M0)          r51      r15     null:0  0x0            0x0280E780           {A@1,$8} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        send.ugm (1|M0)          r27      r26     null:0  0x0            0x0280E780           {A@1,$9} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        send.slm (1|M0)          r67      r117    null:0  0x0            0x0280E700           {$10} // wr:1+0, rd:8; load.slm.d64x32t.a32
        sync.allwr                           ($6,$7)                
        dpas.8x8 (8|M0)          r35:f         null:f            r35:hf            r35.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r35:f         r83:f             r16:hf            r5.0:hf          {$6}
        addc (1|M0)              r16.0<1>:ud   r15.0<0;1,0>:ud   0x100:ud              {AccWrEn,$6.src}
        mov (1|M0)               r17.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r18.0<1>:f    r16.0<0;1,0>:f                   {Compacted,I@2}
        add3 (1|M0)              r18.1<1>:d    r17.0<0;0>:d      r15.1<0;0>:d      0:w               {I@1}
        addc (1|M0)              r2.0<1>:ud    r96.4<0;1,0>:ud   r4.4<0;1,0>:ud   {AccWrEn}
        send.ugm (1|M0)          r19      r18     null:0  0x0            0x0280E780           {A@1,$11} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        mov (1|M0)               r14.0<1>:f    r2.0<0;1,0>:f                    {Compacted,I@1}
        mov (1|M0)               r13.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        sync.nop                             null                             {Compacted,$8.src}
        addc (1|M0)              r15.0<1>:ud   r14.0<0;1,0>:ud   0x100:ud              {AccWrEn,F@1}
        add3 (1|M0)              r14.1<1>:d    r13.0<0;0>:d      r96.5<0;0>:d      r4.5<0>:d        {I@2}
        mov (1|M0)               r16.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r2.0<1>:ud    r96.2<0;1,0>:ud   r4.4<0;1,0>:ud   {AccWrEn}
        mov (1|M0)               r17.0<1>:f    r15.0<0;1,0>:f                   {Compacted,I@4}
        sync.nop                             null                             {Compacted,$11.src}
        mov (1|M0)               r18.0<1>:f    r2.0<0;1,0>:f                    {Compacted,I@1}
        mov (1|M0)               r13.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r15.0<1>:ud   r18.0<0;1,0>:ud   0x100:ud              {AccWrEn,F@1}
        send.ugm (1|M0)          r75      r14     null:0  0x0            0x0280E780           {$12} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        add3 (1|M0)              r18.1<1>:d    r13.0<0;0>:d      r96.3<0;0>:d      r4.5<0>:d        {I@2}
        mov (1|M0)               r14.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,$12.src}
        add3 (1|M0)              r17.1<1>:d    r16.0<0;0>:d      r14.1<0;0>:d      0:w              
        mov (1|M0)               r16.0<1>:f    r15.0<0;1,0>:f                   {Compacted,A@1}
        add3 (1|M0)              r16.1<1>:d    r14.0<0;0>:d      r18.1<0;0>:d      0:w              
        sync.allwr                           ($8,$9)                
        dpas.8x8 (8|M0)          r43:f         r83:f             r27:hf            r5.0:hf          {Atomic}
        dpas.8x8 (8|M0)          r27:f         r83:f             r51:hf            r5.0:hf          {$8}
        sync.nop                             null                             {Compacted,$8.src}
        send.ugm (1|M0)          r51      r16     null:0  0x0            0x0280E780           {A@1,$13} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        dpas.8x8 (8|M0)          r59:f         r83:f             r19:hf            r5.0:hf          {$11}
        sync.nop                             null                             {Compacted,$11.src}
        send.ugm (1|M0)          r5       r17     null:0  0x0            0x0280E780           {$14} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        send.ugm (1|M0)          r19      r18     null:0  0x0            0x0280E780           {$7} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        sync.allwr                           ($6,$10,$11,$12,$13)                
        dpas.8x8 (8|M0)          r35:f         r35:f             r75:hf            r67.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r59:f         r59:f             r51:hf            r67.0:hf         {$10}
        mov (8|M0)               r13.0<1>:f    r37.0<1;1,0>:f                   {Compacted,$10.dst}
        mov (8|M0)               r16.0<1>:f    r61.0<1;1,0>:f                   {Compacted}
        sync.allwr                           ($7,$8,$14)                
        dpas.8x8 (8|M0)          r43:f         r43:f             r5:hf             r67.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r27:f         r27:f             r19:hf            r67.0:hf         {$8}
        mov (8|M0)               r5.0<1>:f     r35.0<1;1,0>:f                   {Compacted,$8.src}
        mov (8|M0)               r8.0<1>:f     r59.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r9.0<1>:f     r36.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r12.0<1>:f    r60.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r6.0<1>:f     r43.0<1;1,0>:f                   {Compacted,$8.dst}
        mov (8|M0)               r10.0<1>:f    r44.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r7.0<1>:f     r27.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r11.0<1>:f    r28.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r95     r5:2    0x0            0x0200C704           {A@4,$9} // wr:1+2, rd:0; store.slm.d64x8t.a32
        send.slm (1|M0)          null     r116    r7:2    0x0            0x0200C704           {A@2,$10} // wr:1+2, rd:0; store.slm.d64x8t.a32
        send.slm (1|M0)          null     r115    r9:2    0x0            0x0200C704           {$11} // wr:1+2, rd:0; store.slm.d64x8t.a32
        send.slm (1|M0)          null     r114    r11:2   0x0            0x0200C704           {A@1,$12} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r14.0<1>:f    r45.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r15.0<1>:f    r29.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r5.0<1>:f     r38.0<1;1,0>:f                   {Compacted,$9.src}
        mov (8|M0)               r6.0<1>:f     r46.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r7.0<1>:f     r30.0<1;1,0>:f                   {Compacted,$10.src}
        mov (8|M0)               r8.0<1>:f     r62.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r9.0<1>:f     r39.0<1;1,0>:f                   {Compacted,$11.src}
        mov (8|M0)               r10.0<1>:f    r47.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r11.0<1>:f    r31.0<1;1,0>:f                   {Compacted,$12.src}
        mov (8|M0)               r12.0<1>:f    r63.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r113    r13:2   0x0            0x0200C704           {A@7,$13} // wr:1+2, rd:0; store.slm.d64x8t.a32
        send.slm (1|M0)          null     r112    r15:2   0x0            0x0200C704           {A@7,$14} // wr:1+2, rd:0; store.slm.d64x8t.a32
        send.slm (1|M0)          null     r111    r5:2    0x0            0x0200C704           {A@7,$6} // wr:1+2, rd:0; store.slm.d64x8t.a32
        send.slm (1|M0)          null     r110    r7:2    0x0            0x0200C704           {A@5,$7} // wr:1+2, rd:0; store.slm.d64x8t.a32
        send.slm (1|M0)          null     r109    r9:2    0x0            0x0200C704           {A@3,$8} // wr:1+2, rd:0; store.slm.d64x8t.a32
        send.slm (1|M0)          null     r108    r11:2   0x0            0x0200C704           {A@1,$15} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r13.0<1>:f    r40.0<1;1,0>:f                   {Compacted,$13.src}
        mov (8|M0)               r14.0<1>:f    r48.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r15.0<1>:f    r32.0<1;1,0>:f                   {Compacted,$14.src}
        mov (8|M0)               r16.0<1>:f    r64.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r5.0<1>:f     r41.0<1;1,0>:f                   {Compacted,$6.src}
        mov (8|M0)               r6.0<1>:f     r49.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r7.0<1>:f     r33.0<1;1,0>:f                   {Compacted,$7.src}
        mov (8|M0)               r8.0<1>:f     r65.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r9.0<1>:f     r42.0<1;1,0>:f                   {Compacted,$8.src}
        mov (8|M0)               r10.0<1>:f    r50.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r11.0<1>:f    r34.0<1;1,0>:f                   {Compacted,$15.src}
        mov (8|M0)               r12.0<1>:f    r66.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r107    r13:2   0x0            0x0200C704           {A@7,$9} // wr:1+2, rd:0; store.slm.d64x8t.a32
        send.slm (1|M0)          null     r106    r15:2   0x0            0x0200C704           {A@7,$1} // wr:1+2, rd:0; store.slm.d64x8t.a32
        send.slm (1|M0)          null     r105    r5:2    0x0            0x0200C704           {A@7,$10} // wr:1+2, rd:0; store.slm.d64x8t.a32
        send.slm (1|M0)          null     r104    r7:2    0x0            0x0200C704           {A@5,$11} // wr:1+2, rd:0; store.slm.d64x8t.a32
        send.slm (1|M0)          null     r118    r9:2    0x0            0x0200C704           {A@3,$2} // wr:1+2, rd:0; store.slm.d64x8t.a32
        send.slm (1|M0)          null     r103    r11:2   0x0            0x0200C704           {A@1,$3} // wr:1+2, rd:0; store.slm.d64x8t.a32
        sync.nop                             null                             {Compacted,$9.src}
(W)     send.slm (1|M0)          r13      r0      null:0  0x0            0x0210001F           {$12} // wr:1+0, rd:1; fence.slm.none.group
(W)     mov (1|M0)               r14.2<1>:f    0.0:f                               {Compacted}
(W)     mov (2|M0)               r14.10<1>:ub  r0.11<0;1,0>:ub                  {F@1}
(W)     mov (8|M0)               null<1>:ud    r13.0<1;1,0>:ud                  {$12.dst}
(W)     send.gtwy (1|M0)         null     r14     null:0  0x0            0x02000004           {A@2,$0} // wr:1+0, rd:0; signal barrier
(W)     sync.bar                             null                            
        send.slm (1|M0)          r97      r102    null:0  0x0            0x0240D700           {$13} // wr:1+0, rd:4; load.slm.d64x16t.a32
        mov (1|M0)               r4.4<2>:f     0.0:f                              
        mov (1|M0)               r4.5<2>:f     0.0:f                              
        mov (1|M0)               r4.2<1>:d     0:w                              
L5424:
        sync.nop                             null                             {Compacted,$10.src}
        addc (1|M0)              r5.0<1>:ud    r4.4<0;1,0>:ud    0x1:ud              {AccWrEn,F@2}
        shl (1|M0)               r1.3<1>:w     r4.4<0;1,0>:w     2:w               {I@2}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r4.6<1>:d     r5.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r4.7<1>:d     r6.0<0;0>:d       r4.5<0;0>:d       0:w               {A@1}
        add (1|M0)               a0.1<1>:uw    r1.3<0;1,0>:uw    0xC20:uw              {A@1}
        cmp (1|M0)    (eq)f0.0   null<1>:d     r4.7<0;1,0>:d     0:w               {I@2}
        shl (1|M0)               r2.0<1>:w     r4.8<0;1,0>:w     2:w              
        add (1|M0)               r4.2<1>:d     r4.2<0;1,0>:d     1:w              
        add (1|M0)               a0.0<1>:uw    r2.0<0;1,0>:uw    0xB60:uw              {A@1}
(f0.0)  cmp (1|M0)    (eq)f0.0   null<1>:d     r4.6<0;1,0>:d     32:w              
        mov (1|M0)               r[a0.0]<1>:f  r[a0.1]<0;1,0>:f                 {$13.dst}
(W)     and (1|M0)               f0.0<1>:ud    f0.0<0;1,0>:uw    0x1:uw              {A@1}
(f0.0.any32h) goto (32|M0)                   L5680                  L5680                
L5648:
(W)     mov (2|M0)               r4.4<1>:ud    r4.6<1;1,0>:ud                  
        goto.b (32|M0)                       L5680                  L5424                
L5680:
        join (32|M0)                         L10104                                
L5696:
        cmp (1|M0)    (eq)f0.0   null<1>:d     r95.6<0;1,0>:d    2:w              
        cmp (1|M0)    (eq)f1.0   null<1>:d     r95.7<0;1,0>:d    0:w              
(W)     mov (1|M0)               r1.3<1>:hf    0x1:hf                             
(f0.0)  sel (1|M0)               r1.4<1>:uw    r1.3<0;1,0>:uw    0x0:uw              {F@1}
(f1.0)  sel (1|M0)               r2.0<1>:uw    r1.3<0;1,0>:uw    0x0:uw             
        and (1|M0)    (ne)f0.0   null<1>:uw    r1.4<0;1,0>:uw    r2.0<0;1,0>:uw   {I@1}
(W)     and (1|M0)               f0.0<1>:ud    f0.0<0;1,0>:uw    0x1:uw             
(f0.0.any32h) goto (32|M0)                   L8960                  L8960                
L5824:
        mov (1|M0)               r4.2<2>:f     0.0:f                              
        mov (1|M0)               r4.3<2>:d     0:d                              
L5856:
        addc (1|M0)              r5.0<1>:ud    r4.2<0;1,0>:ud    0x1:ud              {AccWrEn,F@1}
        shl (1|M0)               r1.3<1>:w     r4.4<0;1,0>:w     2:w              
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r4.4<1>:d     r5.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r4.5<1>:d     r6.0<0;0>:d       r4.3<0;0>:d       0:w               {I@2}
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0xB60:uw              {A@1}
        cmp (1|M0)    (eq)f0.0   null<1>:d     r4.5<0;1,0>:d     0:w               {I@2}
        mov (1|M0)               r2.0<2>:hf    r[a0.0]<0;1,0>:f                
(f0.0)  cmp (1|M0)    (eq)f0.0   null<1>:d     r4.4<0;1,0>:d     32:w               {A@1}
        mov (1|M0)               r[a0.0]<1>:f  r2.0<0;1,0>:hf                   {F@1}
(W)     and (1|M0)               f0.0<1>:ud    f0.0<0;1,0>:uw    0x1:uw             
(f0.0.any32h) goto (32|M0)                   L6072                  L6072                
L6040:
(W)     mov (2|M0)               r4.2<1>:ud    r4.4<1;1,0>:ud                  
        goto.b (32|M0)                       L6072                  L5856                
L6072:
        join (32|M0)                         L8960                                
L6088:
        mul (1|M0)               r1.2<1>:f     r91.0<0;1,0>:f    r91.0<0;1,0>:f   {Compacted,F@1}
        mul (1|M0)               r5.1<1>:f     r93.0<0;1,0>:f    r93.0<0;1,0>:f   {Compacted}
        mov (1|M0)               r2.0<2>:hf    r1.2<0;1,0>:f                    {F@2}
        mul (1|M0)               r9.0<1>:f     r91.1<0;1,0>:f    r91.1<0;1,0>:f   {$2.src}
        mov (1|M0)               r4.4<1>:f     r2.0<0;1,0>:hf                   {A@2}
        mul (1|M0)               r2.1<1>:f     r93.1<0;1,0>:f    r93.1<0;1,0>:f  
        mov (1|M0)               r6.0<2>:hf    r5.1<0;1,0>:f                   
        mov (1|M0)               r10.0<2>:hf   r9.0<0;1,0>:f                    {F@4}
        mad (1|M0)               r4.4<1>:f     r4.4<0;0>:f       r92.0<0;0>:f      r92.0<0>:f       {F@4}
        sync.nop                             null                             {Compacted,$11.src}
        mov (1|M0)               r7.0<1>:f     r6.0<0;1,0>:hf                   {F@3}
        mov (1|M0)               r1.2<1>:f     r10.0<0;1,0>:hf                  {F@3}
        mov (1|M0)               r5.0<2>:hf    r4.4<0;1,0>:f                    {F@3}
        mov (1|M0)               r4.8<2>:hf    r2.1<0;1,0>:f                   
        mad (1|M0)               r7.0<1>:f     r7.0<0;0>:f       r94.0<0;0>:f      r94.0<0>:f       {F@4}
        mad (1|M0)               r1.2<1>:f     r1.2<0;0>:f       r92.1<0;0>:f      r92.1<0>:f       {F@4}
        mov (1|M0)               r5.1<1>:f     r4.8<0;1,0>:hf                   {F@3}
        mov (1|M0)               r8.0<2>:hf    r7.0<0;1,0>:f                    {F@3}
        mov (1|M0)               r2.0<2>:hf    r1.2<0;1,0>:f                    {F@3}
        mad (1|M0)               r5.1<1>:f     r5.1<0;0>:f       r94.1<0;0>:f      r94.1<0>:f       {F@3}
        mul (1|M0)               r7.0<1>:f     r91.2<0;1,0>:f    r91.2<0;1,0>:f  
        mul (1|M0)               r1.2<1>:f     r93.2<0;1,0>:f    r93.2<0;1,0>:f  
        add (1|M0)               r5.0<1>:hf    r5.0<0;1,0>:hf    r8.0<0;1,0>:hf   {F@5}
        mov (1|M0)               r6.0<2>:hf    r5.1<0;1,0>:f                    {F@4}
        mov (1|M0)               r8.0<2>:hf    r7.0<0;1,0>:f                    {F@4}
        mov (1|M0)               r10.2<2>:hf   r1.2<0;1,0>:f                    {F@4}
        mul (1|M0)               r5.1<1>:f     r91.3<0;1,0>:f    r91.3<0;1,0>:f  
        add (1|M0)               r2.0<1>:hf    r2.0<0;1,0>:hf    r6.0<0;1,0>:hf   {F@4}
        mov (1|M0)               r9.0<1>:f     r8.0<0;1,0>:hf                   {F@4}
        mov (1|M0)               r2.1<1>:f     r10.2<0;1,0>:hf                  {F@4}
        mov (1|M0)               r6.0<2>:hf    r5.1<0;1,0>:f                    {F@4}
        mad (1|M0)               r9.0<1>:f     r9.0<0;0>:f       r92.2<0;0>:f      r92.2<0>:f       {F@3}
        mad (1|M0)               r2.1<1>:f     r2.1<0;0>:f       r94.2<0;0>:f      r94.2<0>:f       {F@3}
        mov (1|M0)               r7.0<1>:f     r6.0<0;1,0>:hf                   {F@3}
        mul (1|M0)               r8.1<1>:f     r93.3<0;1,0>:f    r93.3<0;1,0>:f  
        mul (1|M0)               r6.1<1>:f     r93.4<0;1,0>:f    r93.4<0;1,0>:f  
        mov (1|M0)               r10.0<2>:hf   r9.0<0;1,0>:f                    {F@5}
        mov (1|M0)               r4.8<2>:hf    r2.1<0;1,0>:f                    {F@5}
        mad (1|M0)               r7.0<1>:f     r7.0<0;0>:f       r92.3<0;0>:f      r92.3<0>:f       {F@5}
        mul (1|M0)               r2.1<1>:f     r91.4<0;1,0>:f    r91.4<0;1,0>:f  
        mov (1|M0)               r9.0<2>:hf    r8.1<0;1,0>:f                    {F@6}
        add (1|M0)               r10.0<1>:hf   r10.0<0;1,0>:hf   r4.8<0;1,0>:hf   {F@4}
        mov (1|M0)               r8.0<2>:hf    r7.0<0;1,0>:f                    {F@4}
        mov (1|M0)               r4.8<2>:hf    r2.1<0;1,0>:f                    {F@4}
        mov (1|M0)               r7.0<2>:hf    r6.1<0;1,0>:f                   
        mov (1|M0)               r1.2<1>:f     r9.0<0;1,0>:hf                   {F@5}
        mov (1|M0)               r5.1<1>:f     r4.8<0;1,0>:hf                   {F@3}
        mov (1|M0)               r8.1<1>:f     r7.0<0;1,0>:hf                   {F@3}
        mad (1|M0)               r1.2<1>:f     r1.2<0;0>:f       r94.3<0;0>:f      r94.3<0>:f       {F@3}
        mad (1|M0)               r5.1<1>:f     r5.1<0;0>:f       r92.4<0;0>:f      r92.4<0>:f       {F@3}
        mad (1|M0)               r8.1<1>:f     r8.1<0;0>:f       r94.4<0;0>:f      r94.4<0>:f       {F@3}
        mul (1|M0)               r4.5<1>:f     r93.5<0;1,0>:f    r93.5<0;1,0>:f  
        mov (1|M0)               r10.2<2>:hf   r1.2<0;1,0>:f                    {F@4}
        mov (1|M0)               r6.0<2>:hf    r5.1<0;1,0>:f                    {F@4}
        mov (1|M0)               r9.0<2>:hf    r8.1<0;1,0>:f                    {F@4}
        mul (1|M0)               r1.2<1>:f     r91.5<0;1,0>:f    r91.5<0;1,0>:f  
        mul (1|M0)               r8.1<1>:f     r91.6<0;1,0>:f    r91.6<0;1,0>:f  
        add (1|M0)               r8.0<1>:hf    r8.0<0;1,0>:hf    r10.2<0;1,0>:hf  {F@5}
        mov (1|M0)               r5.2<2>:hf    r4.5<0;1,0>:f                   
        add (1|M0)               r6.0<1>:hf    r6.0<0;1,0>:hf    r9.0<0;1,0>:hf   {F@5}
        mov (1|M0)               r10.2<2>:hf   r1.2<0;1,0>:f                    {F@5}
        mov (1|M0)               r9.0<2>:hf    r8.1<0;1,0>:f                    {F@5}
        mov (1|M0)               r6.1<1>:f     r5.2<0;1,0>:hf                   {F@4}
        mov (1|M0)               r2.1<1>:f     r10.2<0;1,0>:hf                  {F@3}
        mov (1|M0)               r1.2<1>:f     r9.0<0;1,0>:hf                   {F@3}
        mad (1|M0)               r6.1<1>:f     r6.1<0;0>:f       r94.5<0;0>:f      r94.5<0>:f       {F@3}
        mad (1|M0)               r2.1<1>:f     r2.1<0;0>:f       r92.5<0;0>:f      r92.5<0>:f       {F@3}
        mad (1|M0)               r1.2<1>:f     r1.2<0;0>:f       r92.6<0;0>:f      r92.6<0>:f       {F@3}
        mov (1|M0)               r7.0<2>:hf    r6.1<0;1,0>:f                    {F@3}
        mov (1|M0)               r4.8<2>:hf    r2.1<0;1,0>:f                    {F@3}
        mov (1|M0)               r10.2<2>:hf   r1.2<0;1,0>:f                    {F@3}
        mul (1|M0)               r6.1<1>:f     r91.7<0;1,0>:f    r91.7<0;1,0>:f  
        mul (1|M0)               r2.1<1>:f     r93.6<0;1,0>:f    r93.6<0;1,0>:f  
        mul (1|M0)               r1.2<1>:f     r93.7<0;1,0>:f    r93.7<0;1,0>:f  
        add (1|M0)               r4.8<1>:hf    r4.8<0;1,0>:hf    r7.0<0;1,0>:hf   {F@5}
        mov (1|M0)               r10.4<2>:hf   r2.1<0;1,0>:f                    {F@3}
        mov (1|M0)               r7.0<2>:hf    r6.1<0;1,0>:f                   
        mov (1|M0)               r9.2<2>:hf    r1.2<0;1,0>:f                    {F@4}
        mov (1|M0)               r4.5<1>:f     r10.4<0;1,0>:hf                  {F@3}
        mov (1|M0)               r8.1<1>:f     r7.0<0;1,0>:hf                   {F@3}
        mov (1|M0)               r2.1<1>:f     r9.2<0;1,0>:hf                   {F@3}
        mad (1|M0)               r4.5<1>:f     r4.5<0;0>:f       r94.6<0;0>:f      r94.6<0>:f       {F@3}
        mad (1|M0)               r8.1<1>:f     r8.1<0;0>:f       r92.7<0;0>:f      r92.7<0>:f       {F@3}
        mad (1|M0)               r2.1<1>:f     r2.1<0;0>:f       r94.7<0;0>:f      r94.7<0>:f       {F@3}
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
        cmp (1|M0)    (eq)f0.0   null<1>:d     r95.6<0;1,0>:d    0:w              
        add (1|M0)               r5.0<1>:hf    r5.0<0;1,0>:hf    r2.0<0;1,0>:hf   {F@1}
(W)     mov (1|M0)               r4.8<1>:uw    0x1:uw                             
        mov (1|M0)               r1.2<1>:f     r5.0<0;1,0>:hf                   {F@1}
(f0.0)  sel (1|M0)               r4.9<1>:uw    r4.8<0;1,0>:uw    0x0:uw              {I@1}
        sel (1|M0)    (ge)f0.0   r1.2<1>:f     r1.2<0;1,0>:f     6.198883e-05:f               {F@1}
(f1.0)  sel (1|M0)               r6.0<1>:uw    r4.8<0;1,0>:uw    0x0:uw             
        sync.nop                             null                             {Compacted,F@1}
        math.sqt (1|M0)          r1.2<1>:f     r1.2<0;1,0>:f                    {$14}
        and (1|M0)    (ne)f1.0   null<1>:uw    r4.9<0;1,0>:uw    r6.0<0;1,0>:uw   {I@1}
        math.inv (1|M0)          r1.2<1>:f     r1.2<0;1,0>:f                    {$14}
(W)     and (1|M0)               f0.0<1>:ud    f1.0<0;1,0>:uw    0x1:uw             
        mov (1|M0)               r7.0<2>:hf    r1.2<0;1,0>:f                    {$14.dst}
        mov (1|M0)               r101.2<1>:f   r7.0<0;1,0>:hf                   {F@1}
(f0.0.any32h) goto (32|M0)                   L7856                  L7856                
L7816:
        mov (1|M0)               r101.1<1>:f   1.0:f                               {Compacted}
(W)     mov (2|M0)               r4.2<1>:ud    r4.0<1;1,0>:ud                  
        goto (32|M0)                         L7856                  L7936                
L7856:
        join (32|M0)                         L7936                                
L7872:
        send.ugm (1|M0)          r2       r96     null:0  0x0            0x04100580           {$6} // wr:2+0, rd:1; load.ugm.d32.a64
(W)     mov (2|M0)               r4.2<1>:ud    r3.6<1;1,0>:ud                  
        mov (1|M0)               r1.4<2>:hf    r2.0<0;1,0>:f                    {$6.dst}
        mov (1|M0)               r101.1<1>:f   r1.4<0;1,0>:hf                   {F@1}
L7936:
        join (32|M0)                         L8960                                
L7952:
        addc (1|M0)              r2.0<1>:ud    r4.2<0;1,0>:ud    r95.4<0;1,0>:ud  {AccWrEn,I@2}
        mov (1|M0)               r101.6<2>:f   0.0:f                              
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r101.7<2>:f   0.0:f                              
        mov (1|M0)               r96.6<1>:d    r2.0<0;1,0>:d                    {I@2}
        add3 (1|M0)              r96.7<1>:d    r5.0<0;0>:d       r4.3<0;0>:d       r95.5<0>:d       {I@2}
L8040:
        shl (1|M0)               r1.3<1>:w     r101.12<0;1,0>:w  2:w               {F@2}
        shl (1|M0)               r4.5<1>:d     r101.6<0;1,0>:d   2:w              
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0xB60:uw              {A@1}
        and (1|M0)               r4.5<1>:d     r4.5<0;1,0>:d     120:w               {I@2}
        mul (1|M0)               r2.0<1>:f     r[a0.0]<0;1,0>:f  r101.2<0;1,0>:f 
        mov (1|M0)               r4.8<2>:hf    r2.0<0;1,0>:f                    {A@1}
        mov (1|M0)               r5.0<1>:f     r4.8<0;1,0>:hf                   {F@1}
        and (1|M0)               r4.4<1>:d     r101.6<0;1,0>:d   1:w               {F@1}
        mul (1|M0)               r5.1<1>:f     r101.1<0;1,0>:f   r5.0<0;1,0>:f    {Compacted}
        mov (1|M0)               r6.0<2>:hf    r5.1<0;1,0>:f                    {F@1}
        mov (1|M0)               r4.6<1>:f     r6.0<0;1,0>:hf                   {F@1}
(~f1.0) mov (1|M0)               r4.6<1>:f     r5.0<0;1,0>:f                   
        cmp (1|M0)    (lt)f1.1   null<1>:f     r4.6<0;1,0>:f     0.0:f               {F@1}
(f1.1)  mov (1|M0)               r4.6<1>:f     -r4.6<0;1,0>:f                  
        sel (1|M0)    (lt)f0.0   r4.6<1>:f     r4.6<0;1,0>:f     448.0:f               {F@1}
        shr (1|M0)               r4.3<1>:ud    r4.6<0;1,0>:ud    0x17:uw              {F@1}
        and (1|M0)               r4.3<1>:ud    r4.3<0;1,0>:ud    0xFF:uw              {I@1}
        sel (1|M0)    (ge)f0.0   r4.3<1>:ud    r4.3<0;1,0>:ud    0x79:uw              {I@1}
        shl (1|M0)               r4.3<1>:ud    r4.3<0;1,0>:ud    0x17:uw              {I@1}
        add (1|M0)               r1.2<1>:ud    -r4.3<0;1,0>:ud   0x80800000:ud              {I@1}
        mul (1|M0)               r1.3<1>:f     r4.6<0;1,0>:f     r1.2<0;1,0>:f    {I@1}
        mov (1|M0)               r4.7<1>:d     r1.3<0;1,0>:f                    {F@1}
        mov (1|M0)               r4.2<1>:f     r4.7<0;1,0>:d                    {I@1}
        mad (1|M0)               r4.6<1>:f     -r4.2<0;0>:f      r1.2<0;0>:f       r4.6<0>:f        {F@1}
        cmp (1|M0)    (gt)f0.0   null<1>:f     r4.6<0;1,0>:f     0.5:f               {F@1}
(W)     and (1|M0)               f0.0<1>:ud    f0.0<0;1,0>:uw    0x1:uw              {F@1}
(f0.0.any32h) goto (32|M0)                   L8560                  L8560                
L8464:
        cmp (1|M0)    (lt)f0.0   null<1>:f     r4.6<0;1,0>:f     0.5:f               {A@1}
        and (1|M0)               r4.7<1>:d     r4.7<0;1,0>:d     1:w              
        add (1|M0)               r1.2<1>:f     r4.2<0;1,0>:f     1.0:f              
(~f0.0) cmp (1|M0)    (eq)f0.0   null<1>:d     r4.7<0;1,0>:d     0:w               {A@1}
(~f0.0) mov (1|M0)               r4.2<1>:f     r1.2<0;1,0>:f                    {F@1}
        goto (32|M0)                         L8560                  L8592                
L8560:
        join (32|M0)                         L8592                                
L8576:
        add (1|M0)               r4.2<1>:f     r4.2<0;1,0>:f     1.0:f               {F@1}
L8592:
        join (32|M0)                         L8960                                
L8608:
        bfn.0xFE (1|M0)          r1.3<1>:ud    r4.5<0;0>:ud      r4.4<0;0>:ud      r95.1<0>:ud      // s0|s1|s2
        add (1|M0)               r4.3<1>:ud    r4.3<0;1,0>:ud    0xFE800000:ud             
        shl (1|M0)               r2.0<1>:d     r1.3<0;1,0>:d     1:w               {Compacted,I@2}
        mul (1|M0)               r4.2<1>:f     r4.2<0;1,0>:f     r4.3<0;1,0>:f    {A@1}
        addc (1|M0)              r5.0<1>:ud    r96.6<0;1,0>:ud   r2.0<0;1,0>:ud   {AccWrEn,I@1}
(f1.1)  mov (1|M0)               r4.2<1>:f     -r4.2<0;1,0>:f                   {F@1}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r7.0<1>:ud    r101.6<0;1,0>:ud  0x1:ud              {AccWrEn}
        mov (1|M0)               r1.4<2>:hf    r4.2<0;1,0>:f                    {F@1}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$4.src}
        mov (1|M0)               r4.2<1>:d     r7.0<0;1,0>:d                    {A@1}
        add3 (1|M0)              r4.3<1>:d     r9.0<0;0>:d       r101.7<0;0>:d     0:w               {I@2}
        shr (1|M0)               r1.5<1>:ud    r1.3<0;1,0>:ud    0x1F:uw             
        cmp (1|M0)    (eq)f0.0   null<1>:d     r4.3<0;1,0>:d     0:w               {I@2}
        or (1|M0)                r2.1<1>:d     r1.5<0;1,0>:d     0:w               {I@2}
        mov (1|M0)               r8.0<1>:f     r5.0<0;1,0>:f                    {Compacted}
        mov (1|M0)               r10.0<1>:d    r1.4<0;1,0>:uw                  
(f0.0)  cmp (1|M0)    (eq)f0.0   null<1>:d     r4.2<0;1,0>:d     32:w              
        add3 (1|M0)              r8.1<1>:d     r6.0<0;0>:d       r96.7<0;0>:d      r2.1<0>:d        {I@3}
        send.ugm (1|M0)          null     r8      r10:1   0x0            0x04000B84           {A@1,$4} // wr:2+1, rd:0; store.ugm.d16u32.a64
(W)     and (1|M0)               f0.0<1>:ud    f0.0<0;1,0>:uw    0x1:uw             
(f0.0.any32h) goto (32|M0)                   L8960                  L9848                
L8928:
(W)     mov (2|M0)               r101.6<1>:ud  r4.2<1;1,0>:ud                  
        goto.b (32|M0)                       L8960                  L8040                
L8960:
        join (32|M0)                         L9848                                
L8976:
        mov (1|M0)               r96.6<2>:f    0.0:f                              
        mov (1|M0)               r96.7<2>:d    0:d                              
L9008:
        shl (1|M0)               r1.3<1>:w     r96.12<0;1,0>:w   2:w               {F@1}
        shl (1|M0)               r101.6<1>:d   r96.6<0;1,0>:d    2:w              
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0xB60:uw              {A@1}
        and (1|M0)               r101.3<1>:d   r96.6<0;1,0>:d    1:w              
        and (1|M0)               r101.6<1>:d   r101.6<0;1,0>:d   120:w               {I@3}
        cmp (1|M0)    (lt)f1.0   null<1>:f     r[a0.0]<0;1,0>:f  0.0:f              
(W)     mov (1|M0)               r2.0<1>:f     -r[a0.0]<0;1,0>:f                {A@1}
(W)     mov (1|M0)               r2.1<1>:f     r[a0.0]<0;1,0>:f                 {A@1}
(f1.0)  sel (1|M0)               r101.7<1>:f   r2.0<0;1,0>:f     r2.1<0;1,0>:f    {A@1}
        sel (1|M0)    (lt)f0.0   r101.7<1>:f   r101.7<0;1,0>:f   448.0:f               {F@1}
        shr (1|M0)               r101.2<1>:ud  r101.7<0;1,0>:ud  0x17:uw              {F@1}
        and (1|M0)               r101.2<1>:ud  r101.2<0;1,0>:ud  0xFF:uw              {I@1}
        sel (1|M0)    (ge)f0.0   r101.2<1>:ud  r101.2<0;1,0>:ud  0x79:uw              {I@1}
        shl (1|M0)               r101.2<1>:ud  r101.2<0;1,0>:ud  0x17:uw              {I@1}
        add (1|M0)               r4.4<1>:ud    -r101.2<0;1,0>:ud  0x80800000:ud             {I@1}
        mul (1|M0)               r4.5<1>:f     r101.7<0;1,0>:f   r4.4<0;1,0>:f    {I@1}
        mov (1|M0)               r102.1<1>:d   r4.5<0;1,0>:f                    {F@1}
        mov (1|M0)               r101.1<1>:f   r102.1<0;1,0>:d                  {Compacted,I@1}
        mad (1|M0)               r101.7<1>:f   -r101.1<0;0>:f    r4.4<0;0>:f       r101.7<0>:f      {F@1}
        cmp (1|M0)    (gt)f0.0   null<1>:f     r101.7<0;1,0>:f   0.5:f               {F@1}
(W)     and (1|M0)               f0.0<1>:ud    f0.0<0;1,0>:uw    0x1:uw              {F@1}
(f0.0.any32h) goto (32|M0)                   L9440                  L9440                
L9352:
        cmp (1|M0)    (lt)f0.0   null<1>:f     r101.7<0;1,0>:f   0.5:f               {A@1}
        and (1|M0)               r102.1<1>:d   r102.1<0;1,0>:d   1:w               {Compacted}
        add (1|M0)               r1.2<1>:f     r101.1<0;1,0>:f   1.0:f              
(~f0.0) cmp (1|M0)    (eq)f0.0   null<1>:d     r102.1<0;1,0>:d   0:w               {A@1}
(~f0.0) mov (1|M0)               r101.1<1>:f   r1.2<0;1,0>:f                    {F@1}
        goto (32|M0)                         L9440                  L9464                
L9440:
        join (32|M0)                         L9464                                
L9456:
        add (1|M0)               r101.1<1>:f   r101.1<0;1,0>:f   1.0:f               {Compacted,F@1}
L9464:
        join (32|M0)                         L9848                                
L9480:
        bfn.0xFE (1|M0)          r1.3<1>:ud    r101.6<0;0>:ud    r101.3<0;0>:ud    r95.1<0>:ud      // s0|s1|s2
        add (1|M0)               r101.2<1>:ud  r101.2<0;1,0>:ud  0xFE800000:ud             
        shl (1|M0)               r2.0<1>:d     r1.3<0;1,0>:d     1:w               {Compacted,I@2}
        mul (1|M0)               r101.1<1>:f   r101.1<0;1,0>:f   r101.2<0;1,0>:f  {A@1}
        addc (1|M0)              r5.0<1>:ud    r95.2<0;1,0>:ud   r2.0<0;1,0>:ud   {AccWrEn,I@1}
        shr (1|M0)               r1.5<1>:ud    r1.3<0;1,0>:ud    0x1F:uw             
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r7.0<1>:ud    r96.6<0;1,0>:ud   0x1:ud              {AccWrEn,$11.src}
(f1.0)  mov (1|M0)               r101.1<1>:f   -r101.1<0;1,0>:f                 {F@1}
        sync.allrd                           ($4,$5)                
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$2.src}
        mov (1|M0)               r4.2<1>:d     r7.0<0;1,0>:d                    {I@2}
        add3 (1|M0)              r4.3<1>:d     r9.0<0;0>:d       r96.7<0;0>:d      0:w               {I@2}
        or (1|M0)                r2.1<1>:d     r1.5<0;1,0>:d     0:w              
        cmp (1|M0)    (eq)f0.0   null<1>:d     r4.3<0;1,0>:d     0:w               {I@2}
        mov (1|M0)               r1.4<2>:hf    r101.1<0;1,0>:f                  {F@1}
        mov (1|M0)               r8.0<1>:f     r5.0<0;1,0>:f                    {Compacted}
        add3 (1|M0)              r8.1<1>:d     r6.0<0;0>:d       r95.3<0;0>:d      r2.1<0>:d        {I@2}
(f0.0)  cmp (1|M0)    (eq)f0.0   null<1>:d     r4.2<0;1,0>:d     32:w              
        mov (1|M0)               r10.0<1>:d    r1.4<0;1,0>:uw                   {F@2}
        send.ugm (1|M0)          null     r8      r10:1   0x0            0x04000B84           {A@1,$5} // wr:2+1, rd:0; store.ugm.d16u32.a64
(W)     and (1|M0)               f0.0<1>:ud    f0.0<0;1,0>:uw    0x1:uw             
(f0.0.any32h) goto (32|M0)                   L9848                  L9848                
L9816:
(W)     mov (2|M0)               r96.6<1>:ud   r4.2<1;1,0>:ud                  
        goto.b (32|M0)                       L9848                  L9008                
L9848:
        join (32|M0)                         L10104                                
L9864:
(W)     send.slm (1|M0)          r5       r0      null:0  0x0            0x0210001F           {$7} // wr:1+0, rd:1; fence.slm.none.group
(W)     mov (1|M0)               r6.2<1>:f     0.0:f                               {Compacted}
(W)     mov (2|M0)               r6.10<1>:ub   r0.11<0;1,0>:ub                  {F@1}
(W)     mov (8|M0)               null<1>:ud    r5.0<1;1,0>:ud                   {$7.dst}
(W)     send.gtwy (1|M0)         null     r6      null:0  0x0            0x02000004           {A@2,$15} // wr:1+0, rd:0; signal barrier
(W)     sync.bar                             null                            
        addc (1|M0)              r2.0<1>:ud    r95.6<0;1,0>:ud   0x1:ud              {AccWrEn}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$11.src}
        mov (1|M0)               r4.2<1>:d     r2.0<0;1,0>:d                    {I@2}
        add3 (1|M0)              r4.3<1>:d     r7.0<0;0>:d       r95.7<0;0>:d      0:w               {I@2}
        cmp (1|M0)    (eq)f0.0   null<1>:d     r4.3<0;1,0>:d     0:w               {I@1}
(f0.0)  cmp (1|M0)    (eq)f0.0   null<1>:d     r4.2<0;1,0>:d     3:w              
(W)     and (1|M0)               f0.0<1>:ud    f0.0<0;1,0>:uw    0x1:uw             
(f0.0.any32h) goto (32|M0)                   L10104                  L10104                
L10072:
(W)     mov (2|M0)               r95.6<1>:ud   r4.2<1;1,0>:ud                  
        goto.b (32|M0)                       L10104                  L3744                
L10104:
        join (32|M0)                         L10120                                
L10120:
(W)     mov (8|M0)               r127.0<1>:f   r0.0<1;1,0>:f                    {Compacted}
(W)     send.ugm (1|M0)          r5       r0      null:0  0x0            0x0210641F           {$8} // wr:1+0, rd:1; fence invalid flush type scoped to tile
(W)     mov (8|M0)               null<1>:ud    r5.0<1;1,0>:ud                   {$8.dst}
(W)     send.gtwy (1|M0)         null     r127    null:0  0x0            0x02000010           {EOT,A@1} // wr:1+0, rd:0; end of thread
L10176:
        mov (1|M0)               r1.2<1>:d     cr0.0<0;1,0>:ud                  {A@1}
        and (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   -1265:w               {A@1}
        or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   1264:w               {A@1}
        mov (1|M0)               r1.3<1>:f     r96.3<0;1,0>:ud                  {Compacted,A@1}
        mov (1|M0)               r4.4<1>:f     0xB4C00000:f                               {Compacted}
        math.inv (1|M0)          r2.1<1>:f     r1.3<0;1,0>:f                    {@2,$9}
        mov (1|M0)               r1.5<1>:f     r96.5<0;1,0>:ud                 
        sync.nop                             null                             {Compacted,$9.dst}
        mad (1|M0)               r2.1<1>:f     r2.1<0;0>:f       r4.4<0;0>:f       r2.1<0>:f        {F@2}
        mov (1|M0)               r96.4<1>:ud   r1.3<0;1,0>:f                   
        mov (1|M0)               r1.6<1>:ud    r1.5<0;1,0>:f                    {F@2}
        mul (1|M0)               r5.0<1>:f     r2.1<0;1,0>:f     r1.5<0;1,0>:f    {A@1}
        add (1|M0)               r96.4<1>:ud   r96.3<0;1,0>:ud   -r96.4<0;1,0>:ud {I@2}
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
(W)     mul (1|M0)               acc0.0<1>:ud  r6.0<0;1,0>:ud    r96.6<0;1,0>:uw  {I@1}
        mach (1|M0)              r8.0<1>:ud    r6.0<0;1,0>:ud    r96.3<0;1,0>:ud  {Compacted}
        add (1|M0)               r96.5<1>:ud   r96.5<0;1,0>:ud   -r8.0<0;1,0>:ud  {I@1}
        cmp (1|M0)    (ge)f0.0   null<1>:ud    r96.5<0;1,0>:ud   r96.3<0;1,0>:ud  {I@1}
(f0.0)  sel (1|M0)               r5.0<1>:d     r4.8<0;1,0>:w     0:w              
        add (1|M0)               r5.0<1>:ud    r6.0<0;1,0>:ud    r5.0<0;1,0>:ud   {Compacted,I@1}
        mov (1|M0)               cr0.0<1>:ud   r1.2<0;1,0>:d                    {A@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        ret (32|M0)                          r95.2                            {A@1}
L10672:
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
