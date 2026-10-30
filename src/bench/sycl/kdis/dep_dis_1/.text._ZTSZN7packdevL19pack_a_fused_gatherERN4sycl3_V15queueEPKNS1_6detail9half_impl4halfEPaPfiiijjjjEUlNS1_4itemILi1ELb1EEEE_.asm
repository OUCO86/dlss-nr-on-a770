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
        and (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   -1265:w               {A@1}
        or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   1216:w               {A@1}
        sync.nop                             null                             {Compacted,A@1}
        sync.nop                             null                             {Compacted,$1.dst}
        mul (1|M0)               acc0.0<1>:ud  r2.0<0;1,0>:ud    r0.2<0;1,0>:uw   {A@1}
        mach (1|M0)              r6.0<1>:ud    r2.0<0;1,0>:ud    r0.1<0;1,0>:ud   {AccWrEn}
        mov (1|M0)               r1.2<1>:d     r1.0<0;1,0>:uw                   {$0.dst}
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r16.2<1>:d    r2.6<0;1,0>:d                   
        addc (1|M0)              r7.0<1>:ud    r5.0<0;1,0>:ud    r1.2<0;1,0>:ud   {AccWrEn,I@2}
        mov (2|M0)               r9.0<1>:d     r16.2<1;1,0>:d                   {I@2}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r16.0<1>:f    r7.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r16.1<1>:d    r8.0<0;0>:d       r6.0<0;0>:d       0:w               {I@1}
        shr (1|M0)               r2.3<1>:ud    r16.0<0;1,0>:ud   0x7:uw              {F@1}
        shl (1|M0)               r2.4<1>:d     r16.1<0;1,0>:d    25:w               {I@2}
        asr (1|M0)               r9.1<1>:d     r2.6<0;1,0>:d     31:w              
        sync.nop                             null                             {Compacted,$2.dst}
        or (1|M0)                r4.6<1>:d     r2.3<0;1,0>:d     r2.4<0;1,0>:d    {I@2}
        shr (1|M0)               r4.7<1>:ud    r16.1<0;1,0>:ud   0x7:uw             
        mul (1|M0)               acc0.0<1>:ud  r4.6<0;1,0>:ud    r9.0<0;1,0>:uw   {I@2}
        mach (1|M0)              r11.0<1>:ud   r4.6<0;1,0>:ud    r9.0<0;1,0>:ud   {AccWrEn}
        shr (1|M0)               r16.7<1>:ud   r16.0<0;1,0>:ud   0x6:uw             
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r4.6<0;1,0>:d     r9.2<0;1,0>:uw  
        mach (1|M0)              r5.0<1>:d     r4.6<0;1,0>:d     r9.1<0;1,0>:d   
(W)     mul (1|M0)               acc0.0<1>:d   r4.7<0;1,0>:d     r9.0<0;1,0>:uw   {Compacted,I@7}
        mach (1|M0)              r6.0<1>:d     r4.7<0;1,0>:d     r9.0<0;1,0>:d    {Compacted}
        mov (1|M0)               r22.7<1>:f    r2.7<0;1,0>:f                   
        mov (1|M0)               r82.5<1>:d    r16.7<0;1,0>:d                   {I@6}
        mov (1|M0)               r16.4<1>:d    r10.0<0;1,0>:d                   {I@6}
        add3 (1|M0)              r16.5<1>:d    r6.0<0;0>:d       r11.0<0;0>:d      r5.0<0>:d        {I@3}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r82.6         L3880                                 {A@1}
L696:
        shr (1|M0)               r16.6<1>:ud   r16.0<0;1,0>:ud   0x3:uw             
(W)     mul (1|M0)               acc0.0<1>:d   r31.0<0;1,0>:d    r2.14<0;1,0>:uw  {Compacted}
        shl (1|M0)               r1.2<1>:d     r31.0<0;1,0>:d    3:w               {Compacted}
        and (1|M0)               r16.6<1>:ud   r16.6<0;1,0>:ud   0x7:uw              {I@3}
        mach (1|M0)              r31.0<1>:d    r31.0<0;1,0>:d    r2.7<0;1,0>:d    {Compacted}
        add3 (1|M0)              r16.6<1>:d    r16.6<0;0>:d      r1.2<0;0>:d       -r3.0<0>:d       {I@2}
        add (1|M0)               r16.7<1>:d    r16.7<0;1,0>:d    -r31.0<0;1,0>:d  {I@2}
        and (1|M0)               r2.3<1>:d     r16.0<0;1,0>:d    7:w               {Compacted}
        cmp (1|M0)    (gt)f1.0   null<1>:d     r16.6<0;1,0>:d    -1:w               {I@3}
        shl (1|M0)               r16.7<1>:d    r16.7<0;1,0>:d    3:w               {I@3}
(W)     mov (1|M0)               r1.3<1>:hf    0x1:hf                             
        add3 (1|M0)              r16.7<1>:d    r16.7<0;0>:d      r2.3<0;0>:d       -r3.1<0>:d       {I@1}
(f1.0)  cmp (1|M0)    (lt)f1.0   null<1>:d     r16.0<0;1,0>:d    r3.2<0;1,0>:d   
        cmp (1|M0)    (gt)f0.0   null<1>:d     r16.7<0;1,0>:d    -1:w               {I@2}
        cmp (1|M0)    (lt)f1.1   null<1>:d     r16.6<0;1,0>:d    r3.3<0;1,0>:d   
        mov (16|M0)              r20.0<1>:f    0.0:f                               {Compacted}
(f1.0)  sel (1|M0)               r1.4<1>:uw    r1.3<0;1,0>:uw    0x0:uw              {F@2}
(f0.0)  sel (1|M0)               r1.5<1>:uw    r1.3<0;1,0>:uw    0x0:uw             
(f1.1)  sel (1|M0)               r2.7<1>:uw    r1.3<0;1,0>:uw    0x0:uw             
        and (1|M0)    (ne)f1.0   null<1>:uw    r1.4<0;1,0>:uw    r1.5<0;1,0>:uw   {I@2}
        cmp (1|M0)    (lt)f0.0   null<1>:d     r16.7<0;1,0>:d    r3.4<0;1,0>:d   
        mov (16|M0)              r18.0<1>:f    0.0:f                               {Compacted}
(f1.0)  sel (1|M0)               r2.6<1>:uw    r1.3<0;1,0>:uw    0x0:uw             
(f0.0)  sel (1|M0)               r3.11<1>:uw   r1.3<0;1,0>:uw    0x0:uw             
        and (1|M0)    (ne)f0.1   null<1>:uw    r2.6<0;1,0>:uw    r2.7<0;1,0>:uw   {I@2}
(f0.1)  sel (1|M0)               r3.10<1>:uw   r1.3<0;1,0>:uw    0x0:uw             
        and (1|M0)    (ne)f0.0   null<1>:uw    r3.10<0;1,0>:uw   r3.11<0;1,0>:uw  {I@1}
(W)     mov (1|M0)               r84.12<1>:uw  f0.0<0;1,0>:uw                   {Compacted}
(W)     and (1|M0)               f0.1<1>:uw    r84.12<0;1,0>:uw  0x1:uw              {I@1}
(~f0.1.any16h) goto (16|M0)                  L2096                  L2096                
L1120:
        mul (1|M0)               acc0.0<1>:ud  r16.6<0;1,0>:ud   r3.8<0;1,0>:uw  
        mach (1|M0)              r6.0<1>:ud    r16.6<0;1,0>:ud   r3.4<0;1,0>:ud   {AccWrEn}
        mov (1|M0)               r1.4<1>:d     r4.0<0;1,0>:d                   
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        asr (1|M0)               r1.5<1>:d     r4.0<0;1,0>:d     31:w               {Compacted}
        addc (1|M0)              r7.0<1>:ud    r5.0<0;1,0>:ud    r16.7<0;1,0>:ud  {AccWrEn,I@2}
        cmp (1|M0)    (gt)f0.0   null<1>:d     r2.6<0;1,0>:d     0:w              
        mov (1|M0)               r1.2<1>:d     r7.0<0;1,0>:d                    {I@2}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mul (1|M0)               acc0.0<1>:ud  r1.2<0;1,0>:ud    r1.8<0;1,0>:uw   {I@2}
        mach (1|M0)              r10.0<1>:ud   r1.2<0;1,0>:ud    r1.4<0;1,0>:ud   {AccWrEn}
        add3 (1|M0)              r1.3<1>:d     r8.0<0;0>:d       r6.0<0;0>:d       0:w               {I@3}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r1.2<0;1,0>:d     r1.10<0;1,0>:uw 
        mach (1|M0)              r11.0<1>:d    r1.2<0;1,0>:d     r1.5<0;1,0>:d   
(W)     mul (1|M0)               acc0.0<1>:d   r1.3<0;1,0>:d     r1.8<0;1,0>:uw   {I@4}
        mach (1|M0)              r12.0<1>:d    r1.3<0;1,0>:d     r1.4<0;1,0>:d   
        shl (1|M0)               r4.6<1>:d     r9.0<0;1,0>:d     1:w               {Compacted,I@5}
        add3 (1|M0)              r2.4<1>:d     r12.0<0;0>:d      r10.0<0;0>:d      r11.0<0>:d       {I@2}
(W)     and (1|M0)               f0.0<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
        shr (1|M0)               r4.1<1>:ud    r9.0<0;1,0>:ud    0x1F:uw             
        addc (1|M0)              r5.0<1>:ud    r3.6<0;1,0>:ud    r4.6<0;1,0>:ud   {AccWrEn,I@4}
        shl (1|M0)               r3.5<1>:d     r2.4<0;1,0>:d     1:w               {I@4}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        or (1|M0)                r4.7<1>:d     r3.5<0;1,0>:d     r4.1<0;1,0>:d    {I@2}
        mov (1|M0)               r17.0<1>:f    r5.0<0;1,0>:f                    {Compacted}
        add3 (1|M0)              r17.1<1>:d    r6.0<0;0>:d       r3.7<0;0>:d       r4.7<0>:d        {I@1}
(f0.0.any16h) goto (16|M0)                   L1544                  L1544                
L1512:
(W)     mov (2|M0)               r3.6<1>:ud    r17.0<1;1,0>:ud                  {A@1}
        goto (16|M0)                         L1544                  L2096                
L1544:
        join (16|M0)                         L2096                                
L1560:
        mov (2|M0)               r17.2<1>:f    r16.2<1;1,0>:f                  
        mov (1|M0)               r17.4<2>:f    0.0:f                              
        mov (1|M0)               r17.5<2>:d    0:d                              
        mov (1|M0)               r17.3<1>:d    0:w                               {F@2}
L1624:
        shl (1|M0)               r1.2<1>:d     r17.5<0;1,0>:d    5:w               {I@2}
        shr (1|M0)               r1.3<1>:ud    r17.4<0;1,0>:ud   0x1B:uw              {F@1}
        shl (1|M0)               r1.4<1>:d     r17.4<0;1,0>:d    5:w              
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        shl (1|M0)               r4.6<1>:d     r1.4<0;1,0>:d     1:w               {I@2}
        shr (1|M0)               r2.4<1>:ud    r1.4<0;1,0>:ud    0x1F:uw             
        shl (1|M0)               r2.3<1>:d     r1.5<0;1,0>:d     1:w               {I@3}
        addc (1|M0)              r5.0<1>:ud    r17.0<0;1,0>:ud   r4.6<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r4.7<1>:d     r2.3<0;1,0>:d     r2.4<0;1,0>:d    {I@2}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r7.0<1>:f     r5.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r7.1<1>:d     r6.0<0;0>:d       r17.1<0;0>:d      r4.7<0>:d        {I@1}
        addc (1|M0)              r14.0<1>:ud   r17.4<0;1,0>:ud   0x1:ud              {AccWrEn}
        send.ugm (1|M0)          r8       r7      null:0  0x0            0x0220C780           {A@1,$3} // wr:1+0, rd:2; load.ugm.d64x8t.a64
        mov (1|M0)               r15.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r17.6<1>:d    r14.0<0;1,0>:d                   {I@2}
        add3 (1|M0)              r17.7<1>:d    r15.0<0;0>:d      r17.5<0;0>:d      0:w               {I@2}
        cmp (1|M0)    (eq)f0.0   null<1>:d     r17.7<0;1,0>:d    r17.3<0;1,0>:d   {I@1}
(f0.0)  cmp (1|M0)    (eq)f0.0   null<1>:d     r17.6<0;1,0>:d    r17.2<0;1,0>:d  
(W)     and (1|M0)               f1.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
        mov (8|M0)               r10.0<1>:f    (abs)r8.0<1;1,0>:hf              {$3.dst}
        mov (8|M0)               r11.0<1>:f    (abs)r8.8<1;1,0>:hf             
        mov (8|M0)               r12.0<1>:f    (abs)r9.0<1;1,0>:hf             
        mov (8|M0)               r13.0<1>:f    (abs)r9.8<1;1,0>:hf             
        sel (16|M0)   (ge)f0.0   r20.0<1>:f    r20.0<1;1,0>:f    r10.0<1;1,0>:f   {Compacted,F@3}
        sel (16|M0)   (ge)f0.0   r18.0<1>:f    r18.0<1;1,0>:f    r12.0<1;1,0>:f   {Compacted,F@2}
(~f1.1.any16h) goto (16|M0)                  L2048                  L2048                
L2016:
(W)     mov (2|M0)               r3.6<1>:ud    r17.0<1;1,0>:ud                 
        goto (16|M0)                         L2048                  L2096                
L2048:
        join (16|M0)                         L2096                                
L2064:
(W)     mov (2|M0)               r17.4<1>:ud   r17.6<1;1,0>:ud                 
        goto.b (16|M0)                       L2096                  L1624                
L2096:
        join (16|M0)                         L2112                                
L2112:
        sel (16|M0)   (ge)f0.0   r20.0<1>:f    r20.0<1;1,0>:f    r18.0<1;1,0>:f   {Compacted,F@1}
        sel (8|M0)    (ge)f0.0   r5.0<1>:f     r20.0<1;1,0>:f    r21.0<1;1,0>:f   {Compacted,F@1}
        mov (4|M0)               r6.0<1>:ud    r5.4<1;1,0>:ud                   {F@1}
        sel (4|M0)    (ge)f0.0   r7.0<1>:f     r5.0<1;1,0>:f     r6.0<1;1,0>:f    {I@1}
        mov (2|M0)               r8.0<1>:ud    r7.2<1;1,0>:ud                   {F@1}
        sel (2|M0)    (ge)f0.0   r9.0<1>:f     r7.0<1;1,0>:f     r8.0<1;1,0>:f    {I@1}
        sel (1|M0)    (ge)f0.0   r83.4<1>:f    r9.0<0;1,0>:f     r9.1<0;1,0>:f    {F@1}
        cmp (1|M0)    (eq)f1.1   null<1>:f     r83.4<0;1,0>:f    0.0:f               {F@1}
(W)     and (1|M0)               f1.0<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(f1.0.any16h) goto (16|M0)                   L2336                  L2336                
L2256:
        mov (1|M0)               r83.5<1>:f    127.0:f                              
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r83.2         L7552                                 {A@1}
L2320:
        goto (16|M0)                         L2336                  L2360                
L2336:
        join (16|M0)                         L2360                                
L2352:
        mov (1|M0)               r22.0<1>:f    1.0:f                               {Compacted}
L2360:
        join (16|M0)                         L2376                                
L2376:
        shl (1|M0)               r1.4<1>:d     r16.0<0;1,0>:d    2:w               {Compacted}
        cmp (1|M0)    (gt)f1.0   null<1>:d     r2.6<0;1,0>:d     0:w              
        shl (1|M0)               r1.2<1>:d     r16.1<0;1,0>:d    2:w              
        shr (1|M0)               r1.3<1>:ud    r16.0<0;1,0>:ud   0x1E:uw             
        addc (1|M0)              r5.0<1>:ud    r4.2<0;1,0>:ud    r1.4<0;1,0>:ud   {AccWrEn,I@4}
        shl (1|M0)               r2.3<1>:d     r16.1<0;1,0>:d    5:w              
        shr (1|M0)               r2.4<1>:ud    r16.0<0;1,0>:ud   0x1B:uw             
        mov (2|M0)               r7.0<1>:w     0x1010101:v                              
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@5}
(W)     and (1|M0)               f0.1<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        shl (1|M0)               r22.3<1>:d    r16.0<0;1,0>:d    5:w               {Compacted}
        mov (1|M0)               r8.0<1>:f     r5.0<0;1,0>:f                    {Compacted,I@7}
        or (1|M0)                r22.4<1>:d    r2.3<0;1,0>:d     r2.4<0;1,0>:d    {I@6}
        mul (2|M0)               r22.1<1>:d    r7.0<1;1,0>:w     3584:w               {I@6}
        mul (2|M0)               r4.6<1>:d     r7.0<1;1,0>:w     480:w              
        add3 (1|M0)              r8.1<1>:d     r6.0<0;0>:d       r4.3<0;0>:d       r1.5<0>:d        {I@5}
        and (2|M0)               r22.1<1>:d    r22.3<1;1,0>:d    r22.1<1;1,0>:d   {I@3}
        send.ugm (1|M0)          null     r8      r22:1   0x0            0x04000584           {A@1,$4} // wr:2+1, rd:0; store.ugm.d32.a64
        and (2|M0)               r22.3<1>:d    r22.3<1;1,0>:d    r4.6<1;1,0>:d    {$4.src}
(~f0.1.any16h) goto (16|M0)                  L3808                  L3808                
L2680:
        addc (1|M0)              r5.0<1>:ud    r4.4<0;1,0>:ud    r22.1<0;1,0>:ud  {AccWrEn}
        mov (1|M0)               r16.3<1>:d    0:w                              
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r7.0<1>:ud    r5.0<0;1,0>:ud    r22.3<0;1,0>:ud  {AccWrEn,I@3}
        add3 (1|M0)              r1.3<1>:d     r6.0<0;0>:d       r4.5<0;0>:d       r22.2<0>:d       {I@2}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r23.0<2>:f    0.0:f                              
        mov (1|M0)               r23.1<2>:f    0.0:f                              
        mov (1|M0)               r22.5<1>:d    r7.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r22.6<1>:d    r8.0<0;0>:d       r1.3<0;0>:d       r22.4<0>:d       {I@2}
L2824:
(W)     and (1|M0)               f0.0<1>:uw    r84.12<0;1,0>:uw  0x1:uw             
(f0.0.any16h) goto (16|M0)                   L2888                  L2888                
L2856:
        mov (8|M0)               r30.0<1>:d    0:w                               {$5.src}
        goto (16|M0)                         L2888                  L3488                
L2888:
        join (16|M0)                         L3488                                
L2904:
        mov (2|M0)               r2.8<1>:w     0x10101010:v                              
        shl (1|M0)               r1.2<1>:d     r23.1<0;1,0>:d    5:w               {F@1}
        shr (1|M0)               r1.3<1>:ud    r23.0<0;1,0>:ud   0x1B:uw             
        mul (2|M0)               r4.6<1>:d     r2.8<1;1,0>:w     32:w               {I@3}
        shl (1|M0)               r1.4<1>:d     r23.0<0;1,0>:d    5:w               {Compacted}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@3}
        add (2|M0)               r4.6<1>:d     r4.6<1;1,0>:d     -32:w               {I@3}
        mov (16|M0)              r26.0<1>:f    r22.0<0;1,0>:f                   {Compacted}
        and (2|M0)               r1.4<1>:d     r1.4<1;1,0>:d     r4.6<1;1,0>:d    {I@1}
        mov (16|M0)              r39.0<1>:f    r26.0<1;1,0>:f                   {Compacted,F@1}
        shl (1|M0)               r5.1<1>:d     r1.4<0;1,0>:d     1:w               {I@1}
        shl (1|M0)               r3.5<1>:d     r1.5<0;1,0>:d     1:w              
        shr (1|M0)               r5.0<1>:ud    r1.4<0;1,0>:ud    0x1F:uw             
        addc (1|M0)              r6.0<1>:ud    r3.6<0;1,0>:ud    r5.1<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r5.2<1>:d     r3.5<0;1,0>:d     r5.0<0;1,0>:d    {I@2}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r8.0<1>:f     r6.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r8.1<1>:d     r7.0<0;0>:d       r3.7<0;0>:d       r5.2<0>:d        {I@1}
        send.ugm (1|M0)          r9       r8      null:0  0x0            0x0220C780           {A@1,$6} // wr:1+0, rd:2; load.ugm.d64x8t.a64
        mov (8|M0)               r32.0<1>:f    r9.0<1;1,0>:hf                   {$6.dst}
        mov (8|M0)               r33.0<1>:f    r9.8<1;1,0>:hf                  
        mov (8|M0)               r24.0<1>:f    r10.0<1;1,0>:hf                 
        mov (8|M0)               r25.0<1>:f    r10.8<1;1,0>:hf                 
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r83.6         L4408                                 {A@1}
L3280:
        mov (16|M0)              r28.0<1>:ud   r73.0<1;1,0>:ud                 
        mov (16|M0)              r32.0<1>:f    r24.0<1;1,0>:f                   {Compacted,F@1}
        mov (16|M0)              r39.0<1>:f    r26.0<1;1,0>:f                   {Compacted}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r83.6         L4408                                 {A@1}
L3360:
        rnde (16|M0)             r28.0<1>:f    r28.0<1;1,0>:f                   {Compacted,I@2}
        rnde (16|M0)             r73.0<1>:f    r73.0<1;1,0>:f                   {Compacted}
        sel (16|M0)   (ge)f0.0   r28.0<1>:f    r28.0<1;1,0>:f    -127.0:f               {F@2}
        sel (16|M0)   (ge)f0.0   r73.0<1>:f    r73.0<1;1,0>:f    -127.0:f               {F@2}
        sel (16|M0)   (lt)f0.0   r28.0<1>:f    r28.0<1;1,0>:f    127.0:f               {F@2}
        sel (16|M0)   (lt)f0.0   r73.0<1>:f    r73.0<1;1,0>:f    127.0:f               {F@2}
        mov (16|M0)              r5.0<1>:d     r28.0<1;1,0>:f                   {Compacted,F@2}
        mov (16|M0)              r7.0<1>:d     r73.0<1;1,0>:f                   {Compacted,F@1}
        mov (16|M0)              r30.0<1>:b    r5.0<4;1,0>:b                    {I@2}
        mov (16|M0)              r30.16<1>:b   r7.0<4;1,0>:b                    {I@2}
L3488:
        join (16|M0)                         L3808                                
L3504:
        addc (1|M0)              r5.0<1>:ud    r23.0<0;1,0>:ud   r16.4<0;1,0>:ud  {AccWrEn}
        shl (1|M0)               r4.6<1>:d     r5.0<0;1,0>:d     12:w               {Compacted,I@1}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r7.0<1>:ud    r22.5<0;1,0>:ud   r4.6<0;1,0>:ud   {AccWrEn,I@2}
        add3 (1|M0)              r1.3<1>:d     r6.0<0;0>:d       r23.1<0;0>:d      r16.5<0>:d       {I@2}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r10.0<1>:ud   r23.0<0;1,0>:ud   0x1:ud              {AccWrEn}
        shr (1|M0)               r2.4<1>:ud    r5.0<0;1,0>:ud    0x14:uw             
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r23.2<1>:d    r10.0<0;1,0>:d                   {I@3}
        add3 (1|M0)              r23.3<1>:d    r11.0<0;0>:d      r23.1<0;0>:d      0:w               {I@2}
        shl (1|M0)               r2.3<1>:d     r1.3<0;1,0>:d     12:w               {Compacted}
        cmp (1|M0)    (eq)f1.1   null<1>:d     r23.3<0;1,0>:d    r16.3<0;1,0>:d   {I@2}
        or (1|M0)                r4.7<1>:d     r2.3<0;1,0>:d     r2.4<0;1,0>:d    {I@2}
        mov (1|M0)               r9.0<1>:f     r7.0<0;1,0>:f                    {Compacted,$5.src}
        add3 (1|M0)              r9.1<1>:d     r8.0<0;0>:d       r22.6<0;0>:d      r4.7<0>:d        {I@1}
(f1.1)  cmp (1|M0)    (eq)f1.1   null<1>:d     r23.2<0;1,0>:d    r16.2<0;1,0>:d  
        send.ugm (1|M0)          null     r9      r30:1   0x0            0x0200B784           {A@1,$5} // wr:1+1, rd:0; store.ugm.d64x4t.a64
(W)     and (1|M0)               f1.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(f1.1.any16h) goto (16|M0)                   L3808                  L3808                
L3776:
(W)     mov (2|M0)               r23.0<1>:ud   r23.2<1;1,0>:ud                 
        goto.b (16|M0)                       L3808                  L2824                
L3808:
        join (16|M0)                         L3824                                
L3824:
(W)     mov (8|M0)               r127.0<1>:f   r0.0<1;1,0>:f                    {Compacted}
(W)     send.ugm (1|M0)          r5       r0      null:0  0x0            0x0210641F           {$7} // wr:1+0, rd:1; fence invalid flush type scoped to tile
(W)     mov (8|M0)               null<1>:ud    r5.0<1;1,0>:ud                   {$7.dst}
(W)     send.gtwy (1|M0)         null     r127    null:0  0x0            0x02000010           {EOT,A@1} // wr:1+0, rd:0; end of thread
L3880:
        mov (1|M0)               r1.2<1>:d     cr0.0<0;1,0>:ud                  {A@1}
        and (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   -1265:w               {A@1}
        or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   1264:w               {A@1}
        mov (1|M0)               r1.3<1>:f     r22.7<0;1,0>:ud                  {A@1}
        mov (1|M0)               r2.5<1>:f     0xB4C00000:f                               {Compacted}
        math.inv (1|M0)          r2.4<1>:f     r1.3<0;1,0>:f                    {@2,$8}
        mov (1|M0)               r1.5<1>:f     r82.5<0;1,0>:ud                 
        sync.nop                             null                             {Compacted,$8.dst}
        mad (1|M0)               r2.4<1>:f     r2.4<0;0>:f       r2.5<0;0>:f       r2.4<0>:f        {F@2}
        mov (1|M0)               r82.4<1>:ud   r1.3<0;1,0>:f                   
        mov (1|M0)               r1.6<1>:ud    r1.5<0;1,0>:f                    {F@2}
        mul (1|M0)               r3.5<1>:f     r2.4<0;1,0>:f     r1.5<0;1,0>:f    {F@1}
        add (1|M0)               r82.4<1>:ud   r22.7<0;1,0>:ud   -r82.4<0;1,0>:ud {I@2}
        add (1|M0)               r1.6<1>:ud    r82.5<0;1,0>:ud   -r1.6<0;1,0>:ud  {I@2}
        mov (1|M0)               r4.1<1>:ud    r3.5<0;1,0>:f                    {F@1}
        mov (1|M0)               r1.4<1>:f     r82.4<0;1,0>:ud                  {I@3}
        mov (1|M0)               r2.3<1>:f     r1.6<0;1,0>:ud                   {I@2}
        mov (1|M0)               r4.6<1>:f     r4.1<0;1,0>:ud                   {I@1}
(W)     mov (1|M0)               r3.10<1>:hf   0x1:hf                             
        mad (1|M0)               r1.5<1>:f     r1.5<0;0>:f       r4.6<0;0>:f       -r1.3<0>:f       {F@2}
        mad (1|M0)               r4.6<1>:f     r2.3<0;0>:f       r4.6<0;0>:f       -r1.4<0>:f      
        add (1|M0)               r1.5<1>:f     r1.5<0;1,0>:f     r4.6<0;1,0>:f    {F@1}
        mul (1|M0)               r2.4<1>:f     r2.4<0;1,0>:f     r1.5<0;1,0>:f    {F@1}
        mov (1|M0)               r5.0<1>:ud    r2.4<0;1,0>:f                    {F@1}
        add (1|M0)               r4.1<1>:ud    r4.1<0;1,0>:ud    r5.0<0;1,0>:ud   {Compacted,I@1}
(W)     mul (1|M0)               acc0.0<1>:ud  r4.1<0;1,0>:ud    r22.14<0;1,0>:uw {I@1}
        mach (1|M0)              r6.0<1>:ud    r4.1<0;1,0>:ud    r22.7<0;1,0>:ud 
        add (1|M0)               r82.5<1>:ud   r82.5<0;1,0>:ud   -r6.0<0;1,0>:ud  {I@1}
        cmp (1|M0)    (ge)f1.1   null<1>:ud    r82.5<0;1,0>:ud   r22.7<0;1,0>:ud  {I@1}
(f1.1)  sel (1|M0)               r7.0<1>:d     r3.10<0;1,0>:w    0:w              
        add (1|M0)               r31.0<1>:ud   r4.1<0;1,0>:ud    r7.0<0;1,0>:ud   {Compacted,I@1}
        mov (1|M0)               cr0.0<1>:ud   r1.2<0;1,0>:d                    {A@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        ret (16|M0)                          r82.6                            {A@1}
L4408:
(W)     shr (16|M0)              r5.0<1>:ud    r32.0<1;1,0>:ud   0x17:uw             
(W)     and (16|M0)              r34.0<1>:w    r5.0<2;1,0>:w     255:w               {I@1}
(W)     add (16|M0)              r9.0<1>:d     r34.0<1;1,0>:uw   -191:w               {I@1}
(W)     cmp (16|M0)   (lt)f1.1   null<1>:d     r9.0<1;1,0>:ud    0xFFFFFF82:ud              {I@1}
(W)     shr (16|M0)              r7.0<1>:ud    r39.0<1;1,0>:ud   0x17:uw             
(W)     mov (1|M0)               r82.5<1>:uw   f1.1<0;1,0>:uw                  
(W)     and (16|M0)              r41.0<1>:w    r7.0<2;1,0>:w     255:w               {I@2}
(W)     mov (1|M0)               f1.0<1>:uw    r82.5<0;1,0>:uw                  {I@2}
(W)     add (16|M0)              r11.0<1>:d    r41.0<1;1,0>:uw   -191:w               {I@2}
(W)     mov (16|M0)              r35.0<1>:d    r34.0<1;1,0>:uw                 
(W&~f1.0) cmp (16|M0) (lt)f1.0   null<1>:d     r11.0<1;1,0>:ud   0xFFFFFF81:ud              {I@2}
(W)     mov (16|M0)              r37.0<1>:d    r34.0<1;1,0>:uw                 
(W)     mov (1|M0)               r82.5<1>:uw   f1.0<0;1,0>:uw                  
(W)     mov (16|M0)              r42.0<1>:d    r41.0<1;1,0>:uw                 
(W)     mov (1|M0)               f0.1<1>:uw    r82.5<0;1,0>:uw                  {I@2}
(W)     mov (16|M0)              r44.0<1>:d    r41.0<1;1,0>:uw                 
(~f0.1.any16h) goto (16|M0)                  L7224                  L7224                
L4680:
(W)     add (16|M0)              r5.0<1>:d     r34.0<1;1,0>:uw   -255:w              
(W)     cmp (16|M0)   (lt)f0.0   null<1>:d     r5.0<1;1,0>:ud    0xFFFFFF02:ud              {I@1}
(W)     add (16|M0)              r7.0<1>:d     r41.0<1;1,0>:uw   -255:w              
(W&~f0.0) cmp (16|M0) (lt)f0.0   null<1>:d     r7.0<1;1,0>:ud    0xFFFFFF02:ud              {I@1}
(W)     mov (16|M0)              r56.0<1>:f    (abs)r32.0<1;1,0>:f              {Compacted}
(f0.0.any16h) goto (16|M0)                   L4840                  L4840                
L4768:
(W)     mov (16|M0)              r5.0<1>:f     (abs)r39.0<1;1,0>:f              {Compacted}
(W)     add (16|M0)              r56.0<1>:d    r56.0<1;1,0>:d    -r5.0<1;1,0>:d   {Compacted,A@1}
(W)     mov (4|M0)               r23.4<1>:d    0:w                              
(W)     mov (16|M0)              r68.0<1>:f    r32.0<1;1,0>:f                   {Compacted}
(W)     mov (16|M0)              r58.0<1>:f    r39.0<1;1,0>:f                   {Compacted}
(W)     asr (16|M0)              r56.0<1>:d    r56.0<1;1,0>:d    23:w               {Compacted,I@2}
        goto (16|M0)                         L4840                  L6096                
L4840:
        join (16|M0)                         L6096                                
L4856:
(W)     mov (16|M0)              r54.0<1>:f    (abs)r39.0<1;1,0>:f              {Compacted}
(W)     cmp (16|M0)   (gt)f1.1   null<1>:d     r56.0<1;1,0>:ud   0x7F800000:ud              {I@3}
(W)     cmp (16|M0)   (lt)f1.0   null<1>:d     r54.0<1;1,0>:ud   0x7F800001:ud              {F@1}
(W)     and (16|M0)              r46.0<1>:ud   r32.0<1;1,0>:ud   0x7F800000:ud             
(W)     mov (1|M0)               r1.3<1>:uw    f1.1<0;1,0>:uw                  
(W)     mov (1|M0)               r2.6<1>:uw    f1.0<0;1,0>:uw                   {Compacted}
(W)     or (1|M0)                f0.1<1>:uw    f1.0<0;1,0>:uw    r1.3<0;1,0>:uw   {I@2}
(W)     cmp (16|M0)   (ne)f1.0   null<1>:d     r46.0<1;1,0>:d    2139095040:d              
(W)     or (1|M0)                r3.10<1>:uw   f1.1<0;1,0>:uw    ~r2.6<0;1,0>:uw  {I@3}
(W)     mov (1|M0)               r9.0<1>:f     -0.0:f                               {Compacted}
(W)     or (1|M0)                r3.11<1>:uw   f1.0<0;1,0>:uw    r3.10<0;1,0>:uw  {I@1}
(W&f0.1) sel (16|M0)             acc0.0<1>:f   r32.0<1;1,0>:f    r39.0<1;1,0>:f  
(W)     mov (1|M0)               f0.1<1>:uw    r3.11<0;1,0>:uw                  {A@1}
(W)     and (16|M0)              r48.0<1>:ud   r39.0<1;1,0>:ud   0x7F800000:ud             
(W)     bfn.0x6A (16|M0)         r73.0<1>:ud   r32.0<1;0>:ud     r39.0<1;0>:ud     r9.0<0>:ud       // s0^s1&s2
(W)     bfn.0x6A (16|M0)         r10.0<1>:ud   r39.0<1;0>:ud     r32.0<1;0>:ud     r9.0<0>:ud       // s0^s1&s2
(W)     add (16|M0)              r73.0<1>:f    r73.0<1;1,0>:f    -r10.0<1;1,0>:f  {Compacted,A@1}
(W&f0.1) add (16|M0)             r73.0<1>:f    acc0.0<1;1,0>:f   r39.0<1;1,0>:f  
(W)     cmp (16|M0)   (ne)f0.1   null<1>:d     r48.0<1;1,0>:d    2139095040:d               {F@1}
(W)     or (1|M0)                r3.10<1>:uw   ~f1.0<0;1,0>:uw   r3.10<0;1,0>:uw 
(W)     cmp (16|M0)   (eq)f1.0   null<1>:f     r39.0<1;1,0>:f    0.0:f               {I@1}
(W)     or (1|M0)                r1.3<1>:uw    f0.1<0;1,0>:uw    r3.10<0;1,0>:uw 
(W)     or (1|M0)                r3.10<1>:uw   ~f0.1<0;1,0>:uw   r3.10<0;1,0>:uw 
(W)     mov (1|M0)               r2.6<1>:hf    -qnan(0x1FF):hf                             
(W)     mov (1|M0)               f0.1<1>:uw    r3.10<0;1,0>:uw                  {I@1}
(W)     and (1|M0)               r4.2<1>:uw    f1.0<0;1,0>:uw    ~r3.10<0;1,0>:uw
(W)     mov (1|M0)               f1.1<1>:uw    r1.3<0;1,0>:uw                  
(W)     and (16|M0)              r7.0<1>:ud    r39.0<1;1,0>:ud   0x80000000:ud             
(W&f0.1) sel (16|M0)             r12.0<2>:b    r2.6<0;1,0>:w     0:w               {F@1}
(W)     mov (1|M0)               f0.1<1>:uw    r4.2<0;1,0>:uw                   {I@4}
(W)     and (16|M0)              r50.0<1>:ud   r32.0<1;1,0>:ud   0x80000000:ud             
(W&~f1.1) mul (16|M0)            r73.0<1>:f    r7.0<1;1,0>:f     r32.0<1;1,0>:f   {I@4}
(W)     mov (16|M0)              r23.16<1>:b   r12.0<2;1,0>:b                   {I@3}
(~f0.1) goto (16|M0)                         L5488                  L5488                
L5368:
(W)     cmp (16|M0)   (eq)f1.1   null<1>:f     r32.0<1;1,0>:f    0.0:f              
(W)     mov (1|M0)               r1.2<1>:ud    0x7F800000:ud                             
(W)     mov (1|M0)               r2.12<2>:b    -1:w                              
(W&f1.1) mov (16|M0)             r50.0<1>:ud   0:w                              
(W)     bfn.0x96 (16|M0)         r50.0<1>:ud   r1.2<0;0>:ud      r50.0<1;0>:ud     r39.0<1>:ud      {I@1} // s0^s1^s2
(W&f1.1) mul (16|M0)             r50.0<1>:f    r50.0<1;1,0>:f    r32.0<1;1,0>:f   {I@1}
        mov (16|M0)              r23.16<1>:b   r2.12<0;1,0>:b                  
        mov (16|M0)              r73.0<1>:f    r50.0<1;1,0>:f                   {Compacted,F@1}
L5488:
        join (16|M0)                         L6096                                
L5504:
(W)     cmp (16|M0)   (eq)f0.1   null<1>:f     r32.0<1;1,0>:f    0.0:f              
(W&f0.1) cmp (16|M0)  (eq)f0.1   null<1>:w     r23.16<1;1,0>:ub  0x0:uw              {A@1}
(W&~f0.1) sel (16|M0)            r5.0<2>:b     r23.16<1;1,0>:b   -1:w              
(W)     mov (16|M0)              r23.16<1>:b   r5.0<2;1,0>:b                    {I@1}
(W)     cmp (16|M0)   (ne)f1.1   null<1>:w     r23.16<1;1,0>:ub  0x0:uw              {I@1}
(W&f0.1) mul (16|M0)             r73.0<1>:f    r32.0<1;1,0>:f    r39.0<1;1,0>:f  
(f1.1.all16h) goto (16|M0)                   L6096                  L7224                
L5616:
(W)     cmp (16|M0)   (eq)f1.1   null<1>:w     r23.16<1;1,0>:ub  0x0:uw             
(W)     mov (1|M0)               r1.3<1>:uw    f0.0<0;1,0>:uw                  
(W)     cmp (16|M0)   (eq)f1.0   null<1>:d     r46.0<1;1,0>:d    0:w              
(W)     and (1|M0)               f0.0<1>:uw    f1.1<0;1,0>:uw    r1.3<0;1,0>:uw   {I@2}
(W)     mov (16|M0)              r60.0<1>:d    0:w                              
(W)     mov (1|M0)               r2.6<1>:uw    f1.0<0;1,0>:uw                   {Compacted}
(W)     mov (16|M0)              r68.0<1>:f    r32.0<1;1,0>:f                   {Compacted}
(W)     and (1|M0)               f1.0<1>:uw    f0.0<0;1,0>:uw    r2.6<0;1,0>:uw   {I@1}
(W)     mov (16|M0)              r52.0<1>:f    r60.0<1;1,0>:f                   {Compacted}
(~f1.0) goto (16|M0)                         L5848                  L5848                
L5752:
        mul (16|M0)              r68.0<1>:f    r32.0<1;1,0>:f    0x4F800000:f               {Compacted}
(W)     shr (16|M0)              r5.0<1>:ud    r68.0<1;1,0>:ud   0x17:uw              {F@1}
(W)     and (16|M0)              r7.0<1>:w     r5.0<2;1,0>:w     255:w               {I@1}
        add (16|M0)              r37.0<1>:d    r7.0<1;1,0>:uw    -32:w               {I@1}
(W)     mov (16|M0)              r52.0<1>:d    0:w                              
(W)     mov (16|M0)              r35.0<1>:f    r37.0<1;1,0>:f                   {Compacted,I@2}
        mov (16|M0)              r52.0<1>:d    -32:w                              
L5848:
        join (16|M0)                         L6096                                
L5864:
(W)     cmp (16|M0)   (eq)f0.1   null<1>:d     r48.0<1;1,0>:d    0:w              
(W)     mov (16|M0)              r58.0<1>:f    r39.0<1;1,0>:f                   {Compacted}
(W)     mov (1|M0)               r1.3<1>:uw    f0.1<0;1,0>:uw                  
(W)     and (1|M0)               f0.1<1>:uw    f0.0<0;1,0>:uw    r1.3<0;1,0>:uw   {I@1}
(~f0.1) goto (16|M0)                         L6040                  L6040                
L5936:
        mul (16|M0)              r58.0<1>:f    r39.0<1;1,0>:f    0x4F800000:f               {Compacted}
(W)     shr (16|M0)              r5.0<1>:ud    r58.0<1;1,0>:ud   0x17:uw              {F@1}
(W)     and (16|M0)              r7.0<1>:w     r5.0<2;1,0>:w     255:w               {I@1}
        add (16|M0)              r44.0<1>:d    r7.0<1;1,0>:uw    -32:w               {I@1}
(W)     mov (16|M0)              r60.0<1>:d    0:w                              
(W)     mov (16|M0)              r54.0<1>:f    (abs)r58.0<1;1,0>:f              {Compacted}
(W)     mov (16|M0)              r42.0<1>:f    r44.0<1;1,0>:f                   {Compacted,I@2}
        mov (16|M0)              r60.0<1>:d    32:w                              
L6040:
        join (16|M0)                         L6096                                
L6056:
(W)     mov (16|M0)              r56.0<1>:f    (abs)r68.0<1;1,0>:f              {Compacted}
(W)     add (16|M0)              r56.0<1>:d    r56.0<1;1,0>:d    -r54.0<1;1,0>:d  {Compacted,F@1}
(W)     asr (16|M0)              r56.0<1>:d    r56.0<1;1,0>:d    23:w               {Compacted,I@1}
(W)     add3 (16|M0)             r60.0<1>:d    r60.0<1;0>:d      r52.0<1;0>:d      r56.0<1>:d       {I@1}
L6096:
        join (16|M0)                         L7224                                
L6112:
(W)     mov (1|M0)               r1.2<1>:f     1.0:f                               {Compacted}
(W)     mov (1|M0)               r5.0<1>:f     0x807FFFFF:f                              
(W&~f0.0) mov (16|M0)            r60.0<1>:f    r56.0<1;1,0>:f                   {I@2}
(W)     bfn.0xEA (16|M0)         r58.0<1>:ud   r1.2<0;0>:ud      r58.0<1;0>:ud     r5.0<0>:ud       {A@2} // s0|s1&s2
(W)     add (16|M0)              r62.0<1>:d    r60.0<1;1,0>:d    126:w               {Compacted,F@1}
(W)     add (16|M0)              r6.0<1>:d     -r60.0<1;1,0>:d   -152:w               {Compacted}
        sync.nop                             null                             {Compacted,I@3}
(W)     math.inv (16|M0)         r8.0<1>:f     r58.0<1;1,0>:f                   {$9}
(W)     cmp (16|M0)   (eq)f0.0   null<1>:w     r23.16<1;1,0>:ub  0x0:uw             
(W)     and (16|M0)              r6.0<1>:d     r6.0<1;1,0>:d     r62.0<1;1,0>:d   {Compacted,I@2}
(W)     mov (1|M0)               r2.3<1>:f     1.0:f                               {Compacted}
(W)     bfn.0xEA (16|M0)         r68.0<1>:ud   r1.2<0;0>:ud      r68.0<1;0>:ud     r5.0<0>:ud       // s0|s1&s2
(W)     asr (16|M0)              r6.0<1>:d     r6.0<1;1,0>:d     31:w               {Compacted,I@2}
        sync.nop                             null                             {Compacted,$9.dst}
(W)     mad (16|M0)              r64.0<1>:f    r2.3<0;0>:f       r8.0<1;0>:f       -r58.0<1>:f      {F@1}
(W)     mul (16|M0)              acc0.0<1>:f   r8.0<1;1,0>:f     r68.0<1;1,0>:f   {Compacted,I@2}
(W&f0.0) sel (16|M0)             r70.0<1>:w    r6.0<4;1,0>:ub    0:w               {I@1}
(W)     mad (16|M0)              r64.0<1>:f    r8.0<1;0>:f       r8.0<1;0>:f       r64.0<1>:f       {Compacted,F@2}
(W)     mad (16|M0)              r66.0<1>:f    r68.0<1;0>:f      acc0.0<1;0>:f     -r58.0<1>:f     
(W)     cmp (16|M0)   (ne)f1.1   null<1>:w     r70.0<2;1,0>:ub   0x0:uw              {I@1}
(W)     mad (16|M0)              r66.0<1>:f    acc0.0<1;0>:f     r64.0<1;0>:f      r66.0<1>:f       {F@1}
(W)     add (16|M0)              r35.0<1>:d    r35.0<1;1,0>:d    -r42.0<1;1,0>:d  {Compacted}
(W)     mad (16|M0)              r68.0<1>:f    r68.0<1;0>:f      r66.0<1;0>:f      -r58.0<1>:f      {Compacted,F@1}
(~f1.1.any16h) goto (16|M0)                  L6968                  L6968                
L6400:
(W)     mov (16|M0)              r79.0<1>:ud   r68.0<1;1,0>:ud                  {F@1}
(W)     mov (16|M0)              r75.0<1>:f    r64.0<1;1,0>:f                   {Compacted}
(W)     mov (16|M0)              r77.0<1>:f    r66.0<1;1,0>:f                   {Compacted}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r84.2         L7432                                 {A@1}
L6480:
(W)     add (16|M0)              r60.0<1>:d    r60.0<1;1,0>:d    125:w               {Compacted}
(W)     cmp (16|M0)   (lt)f0.0   null<1>:d     r60.0<1;1,0>:d    -2:w               {Compacted,I@1}
(W)     cmp (16|M0)   (eq)f0.1   null<1>:f     r68.0<1;1,0>:f    0.0:f              
(W)     mov (1|M0)               r1.3<1>:uw    f0.0<0;1,0>:uw                  
(W)     or (1|M0)                f0.0<1>:uw    f0.1<0;1,0>:uw    r1.3<0;1,0>:uw   {I@1}
(f0.0.any16h) goto (16|M0)                   L6608                  L6608                
L6560:
(W)     mov (1|M0)               r1.3<1>:hf    0x1:hf                              {I@2}
(W&f0.1) sel (16|M0)             r71.0<1>:d    r1.3<0;1,0>:w     0:w               {F@1}
        goto (16|M0)                         L6608                  L6728                
L6608:
        join (16|M0)                         L6728                                
L6624:
(W)     mov (1|M0)               r1.3<1>:hf    0x1:hf                              {I@3}
(W)     and (16|M0)              r5.0<1>:d     r79.0<1;1,0>:d    -2139095041:d              
(W)     mov (1|M0)               r7.0<1>:f     0x800000:f                               {Compacted}
(W)     shl (16|M0)              r62.0<1>:d    r62.0<1;1,0>:d    23:w               {Compacted}
(W&f0.1) sel (16|M0)             r71.0<1>:d    r1.3<0;1,0>:w     0:w               {F@2}
(W)     add (16|M0)              r62.0<1>:d    r62.0<1;1,0>:d    1065353216:d               {I@2}
(W)     bfn.0xFE (16|M0)         r5.0<1>:ud    r5.0<1;0>:ud      r71.0<1;0>:ud     r7.0<0>:ud       {A@1} // s0|s1|s2
(W)     mul (16|M0)              r62.0<1>:f    r62.0<1;1,0>:f    r5.0<1;1,0>:f    {Compacted,A@1}
L6728:
        join (16|M0)                         L6968                                
L6744:
(W)     and (16|M0)   (eq)f1.1   null<1>:ud    r79.0<1;1,0>:ud   0x400000:ud             
(W)     shl (16|M0)              r5.0<1>:d     r79.0<1;1,0>:d    1:w               {Compacted,F@1}
(W)     mov (1|M0)               r1.2<1>:f     0x800000:f                               {Compacted}
(W)     mov (1|M0)               r7.0<1>:f     -0.0:f                               {Compacted}
(W)     mov (1|M0)               r2.3<1>:f     1.469368e-38:f                               {Compacted}
(W)     and (16|M0)              r5.0<1>:d     r5.0<1;1,0>:d     8388606:d               {I@1}
(W)     bfn.0xEA (16|M0)         r8.0<1>:ud    r1.2<0;0>:ud      r79.0<1;0>:ud     r7.0<0>:ud       {A@2} // s0|s1&s2
(W&f1.1) sel (16|M0)             r10.0<1>:d    r2.3<0;1,0>:d     12582912:d               {F@1}
(W)     mov (1|M0)               r3.5<1>:f     0.25:f                               {Compacted}
(W)     bfn.0xFE (16|M0)         r71.0<1>:ud   r71.0<1;0>:ud     r8.0<1;0>:ud      r5.0<1>:ud       {I@2} // s0|s1|s2
(W)     bfn.0xEA (16|M0)         r10.0<1>:ud   r10.0<1;0>:ud     r79.0<1;0>:ud     r7.0<0>:ud       {I@2} // s0|s1&s2
(W)     mad (16|M0)              r71.0<1>:f    r10.0<1;0>:f      r71.0<1;0>:f      r3.5<0>:f        {Compacted,A@1}
(W)     add (16|M0)              r71.0<1>:f    r71.0<1;1,0>:f    -r8.0<1;1,0>:f   {Compacted,F@1}
(W)     mul (16|M0)              r8.0<1>:f     r8.0<1;1,0>:f     r8.0<1;1,0>:f    {Compacted}
(W)     and (16|M0)   (ne)f1.0   null<1>:w     r70.0<2;1,0>:ub   1:w              
(W)     bfn.0xAE (16|M0)         r71.0<1>:ud   r71.0<1;0>:ud     r8.0<1;0>:ud      0x1:uw              {A@1} // s0|s1&~s2
(W&~f0.0) mov (16|M0)            r62.0<1>:f    r71.0<1;1,0>:f                   {I@1}
(W&f1.0) mov (16|M0)             r73.0<1>:f    r62.0<1;1,0>:f                   {F@1}
L6968:
        join (16|M0)                         L7224                                
L6984:
(W)     add (16|M0)              r5.0<1>:d     r35.0<1;1,0>:d    -253:w               {Compacted}
(W)     cmp (16|M0)   (lt)f1.1   null<1>:d     r5.0<1;1,0>:ud    0xFFFFFE85:ud              {I@1}
(W)     mov (1|M0)               r1.3<1>:hf    -qnan(0x1FF):hf                             
(W)     asr (16|M0)              r7.0<1>:d     r35.0<1;1,0>:d    11:w               {Compacted}
(W&f1.1.any16h) sel (1|M0)       r2.6<1>:w     r1.3<0;1,0>:w     0:w               {F@1}
(W)     add (16|M0)              r9.0<1>:d     r7.0<1;1,0>:d     248:w               {Compacted,I@2}
(W)     mov (1|M0)               f0.1<1>:uw    r2.6<0;1,0>:uw                   {I@2}
(W)     mov (16|M0)              r11.0<1>:f    r35.0<1;1,0>:f                   {Compacted}
(W&f1.1) xor (16|M0)             r11.0<1>:d    r9.0<1;1,0>:d     r7.0<1;1,0>:d    {A@1}
(W&~f0.1) mov (16|M0)            r11.0<1>:f    r35.0<1;1,0>:f                   {I@1}
(W)     asr (16|M0)              r13.0<1>:d    r11.0<1;1,0>:d    1:w               {Compacted,F@1}
(W)     mov (16|M0)              r5.0<1>:uw    r23.16<1;1,0>:ub                
(W)     add (16|M0)              r11.0<1>:d    r11.0<1;1,0>:d    -r13.0<1;1,0>:d  {Compacted,I@2}
(W)     mad (16|M0)              r68.0<1>:f    r66.0<1;0>:f      r64.0<1;0>:f      r68.0<1>:f       {Compacted}
(W)     or (16|M0)    (eq)f0.0   null<1>:w     r70.0<2;1,0>:ub   r5.0<1;1,0>:uw   {I@2}
(W)     shl (16|M0)              r13.0<1>:d    r13.0<1;1,0>:d    23:w               {Compacted}
(W)     shl (16|M0)              r11.0<1>:d    r11.0<1;1,0>:d    23:w               {Compacted,I@3}
(W)     add (16|M0)              r13.0<1>:d    r13.0<1;1,0>:d    r68.0<1;1,0>:d   {Compacted,A@1}
(W)     add (16|M0)              r11.0<1>:d    r11.0<1;1,0>:d    1065353216:d               {I@2}
(W&f0.0) mul (16|M0)             r73.0<1>:f    r13.0<1;1,0>:f    r11.0<1;1,0>:f   {A@1}
L7224:
        join (16|M0)                         L7240                                
L7240:
(W)     math.inv (16|M0)         r5.0<1>:f     r39.0<1;1,0>:f                   {$10}
(W)     mov (1|M0)               r1.2<1>:ud    0x3F800000:ud                             
(W)     mul (16|M0)              acc0.0<1>:f   r5.0<1;1,0>:f     r32.0<1;1,0>:f   {Compacted,$10.dst}
(W)     mad (16|M0)              acc2.0<1>:f   r1.2<0;0>:f       r5.0<1;0>:f       -r39.0<1>:f      {I@1}
(W)     mad (16|M0)              r11.0<1>:f    r32.0<1;0>:f      acc0.0<1;0>:f     -r39.0<1>:f     
(W)     mad (16|M0)              acc2.0<1>:f   r5.0<1;0>:f       acc2.0<1;0>:f     r5.0<1>:f        {Compacted}
(W)     mov (1|M0)               f0.0<1>:uw    r82.5<0;1,0>:uw                  {F@5}
(W)     mad (16|M0)              acc0.0<1>:f   acc0.0<1;0>:f     acc2.0<1;0>:f     r11.0<1>:f       {F@2}
(W)     mad (16|M0)              r32.0<1>:f    r32.0<1;0>:f      acc0.0<1;0>:f     -r39.0<1>:f     
(W&~f0.0) mad (16|M0)            r73.0<1>:f    acc0.0<1;0>:f     acc2.0<1;0>:f     r32.0<1>:f       {F@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        ret (16|M0)                          r83.6                            {A@1}
L7432:
(W)     mov (1|M0)               r1.2<1>:d     cr0.0<0;1,0>:ud                  {A@1}
(W)     and (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   -1265:w               {A@1}
(W)     or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   1264:w               {A@1}
(W)     mad (16|M0)              r79.0<1>:f    r77.0<1;0>:f      r75.0<1;0>:f      r79.0<1>:f       {Compacted,A@1}
(W)     mov (1|M0)               cr0.0<1>:ud   r1.2<0;1,0>:d                    {A@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        ret (16|M0)                          r84.2                            {A@1}
L7552:
        shr (1|M0)               r31.3<1>:ud   r83.5<0;1,0>:ud   0x17:uw             
        shr (1|M0)               r31.2<1>:ud   r83.4<0;1,0>:ud   0x17:uw             
        and (1|M0)               r31.3<1>:ud   r31.3<0;1,0>:ud   0xFF:uw              {I@2}
        and (1|M0)               r31.2<1>:ud   r31.2<0;1,0>:ud   0xFF:uw              {I@2}
        add (1|M0)               r1.3<1>:ud    r31.3<0;1,0>:ud   0xFFFFFF41:ud              {I@2}
        add (1|M0)               r1.2<1>:ud    r31.2<0;1,0>:ud   0xFFFFFF41:ud              {I@2}
        cmp (1|M0)    (lt)f1.0   null<1>:ud    r1.3<0;1,0>:ud    0xFFFFFF81:ud              {I@2}
(W)     mov (1|M0)               r2.6<1>:hf    -qnan(0x1FF):hf                             
(~f1.0) cmp (1|M0)    (lt)f1.0   null<1>:ud    r1.2<0;1,0>:ud    0xFFFFFF82:ud              {I@2}
(f1.0)  sel (1|M0)               r31.4<2>:b    r2.6<0;1,0>:w     0:w               {F@1}
        cmp (1|M0)    (ne)f1.1   null<1>:uw    r31.4<0;1,0>:ub   0x0:uw              {I@1}
(W)     and (1|M0)               f1.0<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(~f1.0.any16h) goto (16|M0)                  L11216                  L11216                
L7760:
        add (1|M0)               r1.3<1>:ud    r31.3<0;1,0>:ud   0xFFFFFF01:ud             
        add (1|M0)               r1.2<1>:ud    r31.2<0;1,0>:ud   0xFFFFFF01:ud             
        cmp (1|M0)    (lt)f0.1   null<1>:ud    r1.3<0;1,0>:ud    0xFFFFFF02:ud              {I@2}
(W)     mov (1|M0)               r2.6<1>:hf    -qnan(0x1FF):hf                             
        mov (1|M0)               r81.7<1>:f    (abs)r83.4<0;1,0>:f             
(~f0.1) cmp (1|M0)    (lt)f0.1   null<1>:ud    r1.2<0;1,0>:ud    0xFFFFFF02:ud              {I@2}
(f0.1)  sel (1|M0)               r31.6<2>:b    r2.6<0;1,0>:w     0:w               {F@2}
        cmp (1|M0)    (ne)f1.0   null<1>:uw    r31.6<0;1,0>:ub   0x0:uw              {I@1}
(W)     and (1|M0)               f0.1<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
(f0.1.any16h) goto (16|M0)                   L8016                  L8016                
L7920:
        mov (1|M0)               r1.2<1>:f     (abs)r83.5<0;1,0>:f             
        mov (1|M0)               r81.20<2>:b   0:w                              
        add (1|M0)               r81.7<1>:d    r81.7<0;1,0>:d    -r1.2<0;1,0>:d   {A@1}
        mov (2|M0)               r83.0<1>:d    r83.4<1;1,0>:ud                 
        asr (1|M0)               r81.7<1>:d    r81.7<0;1,0>:d    23:w               {I@2}
        goto (16|M0)                         L8016                  L9720                
L8016:
        join (16|M0)                         L9720                                
L8032:
        cmp (1|M0)    (gt)f0.1   null<1>:ud    r81.7<0;1,0>:ud   0x7F800000:ud              {I@3}
(W)     mov (1|M0)               r1.3<1>:hf    0xFF:hf                             
        mov (1|M0)               r81.4<1>:f    (abs)r83.5<0;1,0>:f             
(W)     mov (1|M0)               r2.7<1>:hf    -qnan(0x1FF):hf                             
(f0.1)  sel (1|M0)               r2.6<1>:w     r1.3<0;1,0>:w     0:w               {F@3}
        and (1|M0)               r31.5<1>:ud   r83.4<0;1,0>:ud   0x7F800000:ud             
        cmp (1|M0)    (eq)f0.0   null<1>:w     r2.12<0;1,0>:b    0:w               {I@2}
(W)     mov (1|M0)               r3.10<1>:uw   r2.12<0;1,0>:ub                 
        add (1|M0)               r22.0<1>:f    r83.4<0;1,0>:f    r83.5<0;1,0>:f  
        and (1|M0)               r31.6<1>:ud   r83.5<0;1,0>:ud   0x7F800000:ud             
(f0.0)  cmp (1|M0)    (gt)f0.0   null<1>:ud    r81.4<0;1,0>:ud   0x7F800000:ud              {F@3}
(W)     mov (1|M0)               r5.0<1>:f     -0.0:f                               {Compacted}
        and (1|M0)               r4.1<1>:ud    r83.5<0;1,0>:ud   0x80000000:ud             
        bfn.0x6A (1|M0)          r1.2<1>:ud    r83.4<0;0>:ud     r83.5<0;0>:ud     r5.0<0>:ud       {F@1} // s0^s1&s2
(f0.0)  sel (1|M0)               r2.16<2>:b    r2.7<0;1,0>:w     0:w              
        bfn.0x6A (1|M0)          r1.3<1>:ud    r83.5<0;0>:ud     r83.4<0;0>:ud     r5.0<0>:ud       // s0^s1&s2
        and (1|M0)    (ne)f1.0   null<1>:w     r2.16<0;1,0>:ub   1:w               {I@2}
        or (1|M0)     (eq)f1.1   r2.16<2>:ub   r2.16<0;1,0>:ub   r3.10<0;1,0>:uw 
        and (1|M0)               r31.4<1>:ud   r83.4<0;1,0>:ud   0x80000000:ud             
(f1.0)  add (1|M0)               r22.0<1>:f    r83.5<0;1,0>:f    r83.5<0;1,0>:f  
(f1.1)  cmp (1|M0)    (eq)f1.1   null<1>:d     r31.5<0;1,0>:d    2139095040:d              
(W)     mov (1|M0)               r4.12<1>:uw   r2.16<0;1,0>:ub                  {I@3}
(f1.1)  sel (1|M0)               r1.6<2>:b     r2.7<0;1,0>:w     0:w              
        and (1|M0)    (ne)f0.1   null<1>:w     r1.6<0;1,0>:ub    1:w               {I@1}
        or (1|M0)     (eq)f1.0   r1.6<2>:ub    r1.6<0;1,0>:ub    r4.12<0;1,0>:uw  {F@1}
(f0.1)  add (1|M0)               r22.0<1>:f    r1.2<0;1,0>:f     -r1.3<0;1,0>:f  
(f1.0)  cmp (1|M0)    (eq)f1.0   null<1>:d     r31.6<0;1,0>:d    2139095040:d              
(W)     mov (1|M0)               r3.10<1>:uw   r1.6<0;1,0>:ub                   {I@2}
(f1.0)  sel (1|M0)               r81.0<2>:b    r2.7<0;1,0>:w     0:w              
        and (1|M0)    (ne)f0.0   null<1>:w     r81.0<0;1,0>:ub   1:w               {I@1}
        or (1|M0)     (eq)f0.1   r81.0<2>:ub   r81.0<0;1,0>:ub   r3.10<0;1,0>:uw  {F@1}
(f0.0)  mul (1|M0)               r22.0<1>:f    r4.1<0;1,0>:f     r83.4<0;1,0>:f  
(f0.1)  cmp (1|M0)    (eq)f0.1   null<1>:f     r83.5<0;1,0>:f    0.0:f               {I@1}
(f0.1)  sel (1|M0)               r31.28<2>:b   r2.7<0;1,0>:w     0:w              
        cmp (1|M0)    (ne)f1.1   null<1>:uw    r31.28<0;1,0>:ub  0x0:uw              {I@1}
(W)     and (1|M0)               f0.0<1>:uw    f1.1<0;1,0>:uw    0x1:uw              {F@2}
(f0.0.any16h) goto (16|M0)                   L8648                  L8648                
L8616:
        mov (1|M0)               r81.2<2>:b    r81.0<0;1,0>:b                  
        goto (16|M0)                         L8648                  L8832                
L8648:
        join (16|M0)                         L8832                                
L8664:
(W)     mov (1|M0)               r5.0<1>:f     inf:f                               {Compacted}
        cmp (1|M0)    (eq)f1.0   null<1>:f     r83.4<0;1,0>:f    0.0:f              
        bfn.0x96 (1|M0)          r31.4<1>:ud   r31.4<0;0>:ud     r83.5<0;0>:ud     r5.0<0>:ud       {F@2} // s0^s1^s2
        xor (1|M0)               r1.2<1>:ud    r83.5<0;1,0>:ud   0x7F800000:ud             
(W)     mov (1|M0)               r2.6<1>:uw    r81.0<0;1,0>:ub                 
(~f1.0) mov (1|M0)               r1.2<1>:f     r31.4<0;1,0>:f                   {A@2}
        or (1|M0)                r81.0<2>:ub   r31.28<0;1,0>:ub  r2.6<0;1,0>:uw   {I@1}
(f1.0)  mul (1|M0)               r31.4<1>:f    r1.2<0;1,0>:f     r83.4<0;1,0>:f   {F@1}
        and (1|M0)    (ne)f1.0   null<1>:w     r31.28<0;1,0>:ub  1:w               {F@1}
        mov (1|M0)               r81.2<2>:b    r81.0<0;1,0>:b                   {I@2}
(f1.0)  mov (1|M0)               r22.0<1>:f    r31.4<0;1,0>:f                  
L8832:
        join (16|M0)                         L9720                                
L8848:
        cmp (1|M0)    (eq)f0.0   null<1>:w     r81.0<0;1,0>:b    0:w              
(W)     mov (1|M0)               r1.3<1>:hf    -qnan(0x1FF):hf                             
(W)     mov (1|M0)               r2.6<1>:uw    r81.2<0;1,0>:ub                  {I@3}
(f0.0)  cmp (1|M0)    (eq)f0.0   null<1>:f     r83.4<0;1,0>:f    0.0:f               {I@2}
(f0.0)  sel (1|M0)               r81.20<2>:b   r1.3<0;1,0>:w     0:w               {F@2}
        and (1|M0)    (ne)f0.1   null<1>:w     r81.20<0;1,0>:ub  1:w               {I@1}
        or (1|M0)     (ne)f0.0   r81.20<2>:ub  r81.20<0;1,0>:ub  r2.6<0;1,0>:uw   {F@1}
(f0.1)  mul (1|M0)               r22.0<1>:f    r83.4<0;1,0>:f    r83.5<0;1,0>:f  
(W)     and (1|M0)               f1.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
(f1.1.any16h) goto (16|M0)                   L9720                  L11216                
L9008:
        cmp (1|M0)    (eq)f1.1   null<1>:uw    r81.20<0;1,0>:ub  0x0:uw              {I@3}
        cmp (1|M0)    (eq)f1.0   null<1>:d     r31.5<0;1,0>:d    0:w              
(~f1.1) mov (1|M0)               r31.6<2>:b    0:w                              
(f1.0)  sel (1|M0)               r81.1<1>:d    r31.6<0;1,0>:b    0:w               {I@1}
        cmp (1|M0)    (ne)f0.1   null<1>:d     r81.1<0;1,0>:d    0:w               {A@1}
(W)     and (1|M0)               f1.0<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(f1.0.any16h) goto (16|M0)                   L9160                  L9160                
L9120:
        mov (1|M0)               r81.2<1>:d    0:w                              
        mov (1|M0)               r83.0<1>:f    r83.4<0;1,0>:f                   {Compacted}
        goto (16|M0)                         L9160                  L9312                
L9160:
        join (16|M0)                         L9312                                
L9176:
        and (1|M0)    (ne)f1.1   r81.1<1>:d    r81.1<0;1,0>:d    1:w              
        mov (1|M0)               r83.0<1>:f    r83.4<0;1,0>:f                   {Compacted}
(W)     mov (1|M0)               r2.6<1>:hf    -qnan(0x1E0):hf                             
(f1.1)  mul (1|M0)               r83.0<1>:f    r83.4<0;1,0>:f    0x4F800000:f              
(f1.1)  sel (1|M0)               r81.2<1>:d    r2.6<0;1,0>:w     0:w               {F@2}
        shr (1|M0)               r1.2<1>:ud    r83.0<0;1,0>:ud   0x17:uw              {F@1}
        and (1|M0)               r1.2<1>:ud    r1.2<0;1,0>:ud    0xFF:uw              {I@1}
        add (1|M0)               r1.2<1>:ud    r1.2<0;1,0>:ud    0xFFFFFFE0:ud              {I@1}
(f1.1)  mov (1|M0)               r31.2<1>:f    r1.2<0;1,0>:f                    {I@1}
L9312:
        join (16|M0)                         L9720                                
L9328:
        cmp (1|M0)    (eq)f0.0   null<1>:d     r31.6<0;1,0>:d    0:w              
(f0.0)  sel (1|M0)               r81.3<1>:d    r31.6<0;1,0>:b    0:w              
        cmp (1|M0)    (ne)f1.1   null<1>:d     r81.3<0;1,0>:d    0:w               {A@1}
(W)     and (1|M0)               f0.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(f0.1.any16h) goto (16|M0)                   L9456                  L9456                
L9408:
        mov (1|M0)               r81.6<1>:d    0:w                              
        mov (1|M0)               r83.1<1>:d    r83.5<0;1,0>:ud                 
        goto (16|M0)                         L9456                  L9632                
L9456:
        join (16|M0)                         L9632                                
L9472:
        and (1|M0)    (ne)f1.0   r81.3<1>:d    r81.3<0;1,0>:d    1:w              
        mov (1|M0)               r83.1<1>:f    r83.5<0;1,0>:f                   {I@4}
(W)     mov (1|M0)               r2.6<1>:hf    0x20:hf                             
(f1.0)  mul (1|M0)               r83.1<1>:f    r83.5<0;1,0>:f    0x4F800000:f              
(f1.0)  sel (1|M0)               r81.6<1>:d    r2.6<0;1,0>:w     0:w               {F@2}
        shr (1|M0)               r1.2<1>:ud    r83.1<0;1,0>:ud   0x17:uw              {F@1}
        mov (1|M0)               r81.4<1>:f    (abs)r83.1<0;1,0>:f             
        and (1|M0)               r1.2<1>:ud    r1.2<0;1,0>:ud    0xFF:uw              {I@1}
        add (1|M0)               r1.2<1>:ud    r1.2<0;1,0>:ud    0xFFFFFFE0:ud              {I@1}
(f1.0)  mov (1|M0)               r31.3<1>:d    r1.2<0;1,0>:d                    {I@1}
L9632:
        join (16|M0)                         L9720                                
L9648:
        mov (1|M0)               r81.7<1>:f    (abs)r83.0<0;1,0>:f              {Compacted}
        add (1|M0)               r81.6<1>:d    r81.6<0;1,0>:d    r81.2<0;1,0>:d  
        add (1|M0)               r81.7<1>:d    r81.7<0;1,0>:d    -r81.4<0;1,0>:d  {F@1}
        asr (1|M0)               r81.7<1>:d    r81.7<0;1,0>:d    23:w               {I@1}
        add (1|M0)               r81.6<1>:d    r81.6<0;1,0>:d    r81.7<0;1,0>:d   {I@1}
L9720:
        join (16|M0)                         L11216                                
L9736:
        cmp (1|M0)    (eq)f1.0   null<1>:uw    r31.6<0;1,0>:ub   0x0:uw             
(W)     mov (1|M0)               r1.2<1>:f     1.0:f                               {Compacted}
(W)     mov (1|M0)               r5.0<1>:f     0x807FFFFF:f                              
        cmp (1|M0)    (eq)f0.1   null<1>:w     r81.20<0;1,0>:b   0:w              
(~f1.0) mov (1|M0)               r81.7<1>:d    r81.6<0;1,0>:d                   {I@4}
        bfn.0xEA (1|M0)          r83.1<1>:ud   r1.2<0;0>:ud      r83.1<0;0>:ud     r5.0<0>:ud       {A@1} // s0|s1&s2
        add (1|M0)               r82.0<1>:d    r81.7<0;1,0>:d    126:w               {Compacted,I@2}
        add (1|M0)               r82.1<1>:d    -r81.7<0;1,0>:d   -152:w              
        sync.nop                             null                             {Compacted,I@3}
        math.inv (1|M0)          r2.3<1>:f     r83.1<0;1,0>:f                   {$11}
        and (1|M0)               r82.1<1>:d    r82.1<0;1,0>:d    r82.0<0;1,0>:d   {Compacted,I@1}
        mov (1|M0)               r85.0<1>:f    1.0:f                               {Compacted}
        asr (1|M0)               r82.1<1>:d    r82.1<0;1,0>:d    31:w               {Compacted,I@1}
(~f0.1) mov (1|M0)               r82.1<1>:d    0:w                              
        bfn.0xEA (1|M0)          r83.0<1>:ud   r1.2<0;0>:ud      r83.0<0;0>:ud     r5.0<0>:ud       // s0|s1&s2
        cmp (1|M0)    (ne)f0.0   null<1>:d     r82.1<0;1,0>:d    0:w               {I@2}
        sync.nop                             null                             {Compacted,$11.dst}
        mad (1|M0)               r85.0<1>:f    r85.0<0;0>:f      r2.3<0;0>:f       -r83.1<0>:f      {F@1}
        mul (1|M0)               r2.4<1>:f     r2.3<0;1,0>:f     r83.0<0;1,0>:f   {I@2}
        mad (1|M0)               r85.0<1>:f    r2.3<0;0>:f       r2.3<0;0>:f       r85.0<0>:f       {F@2}
        mad (1|M0)               r85.1<1>:f    r83.0<0;0>:f      r2.4<0;0>:f       -r83.1<0>:f      {F@2}
(W)     and (1|M0)               f0.0<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
        mad (1|M0)               r85.1<1>:f    r2.4<0;0>:f       r85.0<0;0>:f      r85.1<0>:f       {F@1}
        add (1|M0)               r31.2<1>:d    r31.2<0;1,0>:d    -r31.3<0;1,0>:d 
        mad (1|M0)               r83.0<1>:f    r83.0<0;0>:f      r85.1<0;0>:f      -r83.1<0>:f      {F@1}
(~f0.0.any16h) goto (16|M0)                  L10864                  L10864                
L10096:
        mov (1|M0)               r82.3<1>:f    r83.0<0;1,0>:f                   {Compacted,F@1}
        mov (2|M0)               r84.0<1>:f    r85.0<1;1,0>:f                  
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r84.4         L11448                                 {A@1}
L10168:
        cmp (1|M0)    (eq)f1.0   null<1>:f     r83.0<0;1,0>:f    0.0:f              
(W)     mov (1|M0)               r1.3<1>:hf    0x1:hf                             
        add (1|M0)               r81.7<1>:d    r81.7<0;1,0>:d    125:w              
(W)     mov (1|M0)               r3.10<1>:hf   0x1:hf                             
(f1.0)  sel (1|M0)               r2.6<1>:w     r1.3<0;1,0>:w     0:w               {F@2}
        cmp (1|M0)    (lt)f0.0   null<1>:d     r81.7<0;1,0>:d    -2:w               {I@2}
        cmp (1|M0)    (ne)f0.1   null<1>:w     r2.6<0;1,0>:w     0:w               {I@2}
(W)     mov (1|M0)               r5.0<1>:hf    -qnan(0x1FF):hf                             
(f0.0)  sel (1|M0)               r3.11<1>:uw   r3.10<0;1,0>:uw   0x0:uw              {F@2}
(f0.1)  sel (1|M0)               r4.2<1>:uw    r3.10<0;1,0>:uw   0x0:uw             
        or (1|M0)     (ne)f1.1   null<1>:uw    r3.11<0;1,0>:uw   r4.2<0;1,0>:uw   {I@1}
(f1.1)  sel (1|M0)               r81.22<2>:b   r5.0<0;1,0>:w     0:w               {F@1}
        cmp (1|M0)    (ne)f1.1   null<1>:uw    r81.22<0;1,0>:ub  0x0:uw              {I@1}
(W)     and (1|M0)               f1.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(~f1.1.any16h) goto (16|M0)                  L10512                  L10512                
L10408:
(W)     mov (1|M0)               r1.3<1>:hf    0x1:hf                             
        and (1|M0)               r1.2<1>:d     r82.3<0;1,0>:d    -2139095041:d              
(W)     mov (1|M0)               r5.0<1>:f     0x800000:f                               {Compacted}
        shl (1|M0)               r82.0<1>:d    r82.0<0;1,0>:d    23:w               {Compacted}
(f1.0)  sel (1|M0)               r2.3<1>:d     r1.3<0;1,0>:w     0:w               {F@2}
        add (1|M0)               r82.0<1>:d    r82.0<0;1,0>:d    1065353216:d               {I@2}
        bfn.0xFE (1|M0)          r1.2<1>:ud    r1.2<0;0>:ud      r2.3<0;0>:ud      r5.0<0>:ud       {A@1} // s0|s1|s2
        mul (1|M0)               r82.0<1>:f    r82.0<0;1,0>:f    r1.2<0;1,0>:f    {Compacted,A@1}
L10512:
        join (16|M0)                         L10864                                
L10528:
        and (1|M0)               r1.2<1>:d     r82.3<0;1,0>:d    -2147483648:d               {F@1}
        shl (1|M0)               r82.3<1>:d    r82.3<0;1,0>:d    1:w               {Compacted}
(W)     mov (1|M0)               r1.3<1>:hf    0x1:hf                             
        and (1|M0)               r1.3<1>:d     r82.3<0;1,0>:d    8388606:d               {I@1}
        and (1|M0)    (eq)f0.0   r82.3<1>:d    r82.3<0;1,0>:d    8388608:d              
(W)     mov (1|M0)               r2.5<1>:f     1.469368e-38:f                               {Compacted}
(f0.1)  sel (1|M0)               r2.3<1>:d     r1.3<0;1,0>:w     0:w               {F@2}
(W)     mov (1|M0)               r4.1<1>:f     0x800000:f                               {Compacted}
        or (1|M0)                r2.3<1>:d     r1.2<0;1,0>:d     r2.3<0;1,0>:d    {I@1}
(f0.0)  sel (1|M0)               r3.5<1>:d     r2.5<0;1,0>:d     12582912:d               {F@2}
        mov (1|M0)               r5.0<1>:f     0.25:f                               {Compacted}
        bfn.0xFE (1|M0)          r2.3<1>:ud    r4.1<0;0>:ud      r2.3<0;0>:ud      r1.3<0>:ud       {A@2} // s0|s1|s2
        or (1|M0)                r3.5<1>:d     r3.5<0;1,0>:d     r1.2<0;1,0>:d    {I@2}
        or (1|M0)                r2.4<1>:d     r1.2<0;1,0>:d     8388608:d              
        mad (1|M0)               r2.3<1>:f     r3.5<0;0>:f       r5.0<0;0>:f       r2.3<0>:f        {A@1}
        cmp (1|M0)    (eq)f0.1   null<1>:uw    r81.22<0;1,0>:ub  0x0:uw             
        add (1|M0)               r2.3<1>:f     r2.3<0;1,0>:f     -r2.4<0;1,0>:f   {A@1}
        mul (1|M0)               r2.4<1>:f     r2.4<0;1,0>:f     r2.4<0;1,0>:f   
        and (1|M0)    (ne)f0.0   null<1>:d     r82.1<0;1,0>:d    1:w              
        and (1|M0)               r2.4<1>:d     r2.4<0;1,0>:d     -2:w               {F@1}
        or (1|M0)                r2.4<1>:d     r2.4<0;1,0>:d     r2.3<0;1,0>:d    {I@1}
(~f0.1) mov (1|M0)               r2.4<1>:f     r82.0<0;1,0>:f                   {I@1}
(f0.0)  mov (1|M0)               r22.0<1>:f    r2.4<0;1,0>:f                    {F@1}
L10864:
        join (16|M0)                         L11216                                
L10880:
        add (1|M0)               r2.3<1>:d     r31.2<0;1,0>:d    126:w              
(W)     mov (1|M0)               r1.3<1>:uw    r82.4<0;1,0>:ub                 
        cmp (1|M0)    (gt)f0.0   null<1>:ud    r2.3<0;1,0>:ud    0x17A:uw              {A@1}
        mad (1|M0)               r83.0<1>:f    r85.1<0;0>:f      r85.0<0;0>:f      r83.0<0>:f      
        or (1|M0)                r82.4<1>:w    r81.20<0;1,0>:ub  r1.3<0;1,0>:uw   {I@2}
(W)     and (1|M0)               f0.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
(~f0.1.any16h) goto (16|M0)                  L11072                  L11072                
L10992:
(f0.0)  sel (1|M0)               r1.2<1>:d     r31.2<0;1,0>:d    0:w              
        asr (1|M0)               r1.2<1>:d     r1.2<0;1,0>:d     11:w               {I@1}
        add (1|M0)               r1.3<1>:d     r1.2<0;1,0>:d     248:w               {I@1}
        xor (1|M0)               r1.3<1>:d     r1.3<0;1,0>:d     r1.2<0;1,0>:d    {I@1}
(f0.0)  mov (1|M0)               r31.2<1>:d    r1.3<0;1,0>:d                    {I@1}
L11072:
        join (16|M0)                         L11216                                
L11088:
        asr (1|M0)               r1.2<1>:d     r31.2<0;1,0>:d    1:w               {I@2}
        cmp (1|M0)    (eq)f1.1   null<1>:w     r82.4<0;1,0>:w    0:w              
        add (1|M0)               r31.2<1>:d    r31.2<0;1,0>:d    -r1.2<0;1,0>:d   {I@2}
        shl (1|M0)               r1.2<1>:d     r1.2<0;1,0>:d     23:w              
        shl (1|M0)               r31.2<1>:d    r31.2<0;1,0>:d    23:w               {I@2}
        add (1|M0)               r1.2<1>:d     r1.2<0;1,0>:d     r83.0<0;1,0>:d   {A@1}
        add (1|M0)               r31.2<1>:d    r31.2<0;1,0>:d    1065353216:d               {I@2}
(f1.1)  mul (1|M0)               r22.0<1>:f    r31.2<0;1,0>:f    r1.2<0;1,0>:f    {I@1}
L11216:
        join (16|M0)                         L11232                                
L11232:
        sync.nop                             null                             {Compacted,F@1}
        math.inv (1|M0)          r1.2<1>:f     r83.5<0;1,0>:f                   {$12}
        mov (1|M0)               r1.4<1>:ud    0x3F800000:ud                             
        mul (1|M0)               r1.3<1>:f     r1.2<0;1,0>:f     r83.4<0;1,0>:f   {$12.dst}
        mad (1|M0)               r1.4<1>:f     r1.4<0;0>:f       r1.2<0;0>:f       -r83.5<0>:f      {I@1}
        mad (1|M0)               r2.3<1>:f     r83.4<0;0>:f      r1.3<0;0>:f       -r83.5<0>:f      {F@2}
        mad (1|M0)               r1.4<1>:f     r1.2<0;0>:f       r1.2<0;0>:f       r1.4<0>:f        {F@2}
        cmp (1|M0)    (eq)f1.0   null<1>:uw    r31.4<0;1,0>:ub   0x0:uw             
        mad (1|M0)               r2.3<1>:f     r1.3<0;0>:f       r1.4<0;0>:f       r2.3<0>:f        {F@1}
        mad (1|M0)               r83.4<1>:f    r83.4<0;0>:f      r2.3<0;0>:f       -r83.5<0>:f      {F@1}
(f1.0)  mad (1|M0)               r22.0<1>:f    r2.3<0;0>:f       r1.4<0;0>:f       r83.4<0>:f       {F@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        ret (16|M0)                          r83.2                            {A@1}
L11448:
        mov (1|M0)               r1.2<1>:d     cr0.0<0;1,0>:ud                  {A@1}
        and (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   -1265:w               {A@1}
        or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   1264:w               {A@1}
        mad (1|M0)               r82.3<1>:f    r84.1<0;0>:f      r84.0<0;0>:f      r82.3<0>:f       {A@1}
        mov (1|M0)               cr0.0<1>:ud   r1.2<0;1,0>:d                    {A@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        ret (16|M0)                          r84.4                            {A@1}
L11576:
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
