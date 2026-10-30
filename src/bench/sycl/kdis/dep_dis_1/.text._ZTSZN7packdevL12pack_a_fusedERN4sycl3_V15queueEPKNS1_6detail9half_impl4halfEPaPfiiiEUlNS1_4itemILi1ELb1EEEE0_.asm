L0:
(W)     mov (8|M0)               r127.0<1>:ud  0x0:ud                              {A@1}
(W)     and (1|M0)               r127.2<1>:ud  r0.0<0;1,0>:ud    0xFFFFFFC0:ud             
(W)     and (1|M0)               r127.0<1>:uw  r0.4<0;1,0>:uw    0xFF:uw             
(W)     add (1|M0)               r127.2<1>:ud  r127.2<0;1,0>:ud  0x40:ud              {I@2}
(W)     mad (1|M0)               r127.2<1>:ud  r127.2<0;0>:ud    r127.0<0;0>:uw    0x20:uw              {I@1}
(W)     send.dc0 (8|M0)          r1       r127    null:0  0x0            0x021842FD           {A@1,$0} // wr:1h+0, rd:1; oword aligned block read x2
        nop                    
        nop                    
(W)     mov (8|M0)               r127.0<1>:ud  0x0:ud                              {$0.src}
(W)     and (1|M0)               r127.2<1>:ud  r0.0<0;1,0>:ud    0xFFFFFFC0:ud             
(W)     send.dc0 (8|M0)          r2       r127    null:0  0x0            0x022843FD           {A@1,$1} // wr:1h+0, rd:2; oword aligned block read x4
        and (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   -1265:w               {A@1}
        or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   1216:w               {A@1}
        sync.nop                             null                             {Compacted,A@1}
        sync.nop                             null                             {Compacted,$1.dst}
        mul (1|M0)               acc0.0<1>:ud  r2.0<0;1,0>:ud    r0.2<0;1,0>:uw   {A@1}
        mach (1|M0)              r5.0<1>:ud    r2.0<0;1,0>:ud    r0.1<0;1,0>:ud   {AccWrEn}
        mov (1|M0)               r1.2<1>:d     r1.0<0;1,0>:uw                   {$0.dst}
        mov (1|M0)               r4.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r16.5<1>:d    r2.6<0;1,0>:d                   
        addc (1|M0)              r6.0<1>:ud    r4.0<0;1,0>:ud    r1.2<0;1,0>:ud   {AccWrEn,I@2}
        mov (2|M0)               r4.0<1>:d     r16.5<1;1,0>:d                   {I@2}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r16.0<1>:f    r6.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r16.1<1>:d    r7.0<0;0>:d       r5.0<0;0>:d       0:w               {I@1}
        shr (1|M0)               r2.3<1>:ud    r16.0<0;1,0>:ud   0x7:uw              {F@1}
        shl (1|M0)               r2.4<1>:d     r16.1<0;1,0>:d    25:w               {I@2}
        cmp (1|M0)    (lt)f1.1   null<1>:d     r16.0<0;1,0>:d    r2.7<0;1,0>:d   
        or (1|M0)                r8.0<1>:d     r2.3<0;1,0>:d     r2.4<0;1,0>:d    {I@2}
        asr (1|M0)               r4.1<1>:d     r2.6<0;1,0>:d     31:w              
        mul (1|M0)               acc0.0<1>:ud  r8.0<0;1,0>:ud    r4.0<0;1,0>:uw   {I@2}
        mach (1|M0)              r6.0<1>:ud    r8.0<0;1,0>:ud    r4.0<0;1,0>:ud   {AccWrEn}
        shr (1|M0)               r8.1<1>:ud    r16.1<0;1,0>:ud   0x7:uw             
        shr (1|M0)               r3.5<1>:ud    r16.0<0;1,0>:ud   0x4:uw             
        shl (1|M0)               r8.2<1>:d     r16.1<0;1,0>:d    28:w              
(W)     and (1|M0)               f1.0<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r8.0<0;1,0>:d     r4.2<0;1,0>:uw   {Compacted,I@7}
        mach (1|M0)              r7.0<1>:d     r8.0<0;1,0>:d     r4.1<0;1,0>:d    {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r8.1<0;1,0>:d     r4.0<0;1,0>:uw   {Compacted,I@7}
        mov (2|M0)               r1.8<1>:w     0x7070707:v                              
        shr (1|M0)               r16.3<1>:ud   r16.1<0;1,0>:ud   0x4:uw             
        or (1|M0)                r16.2<1>:d    r3.5<0;1,0>:d     r8.2<0;1,0>:d    {I@7}
        mach (1|M0)              r9.0<1>:d     r8.1<0;1,0>:d     r4.0<0;1,0>:d    {Compacted}
        and (1|M0)               r16.4<1>:d    r16.0<0;1,0>:d    15:w               {Compacted}
        mov (1|M0)               r17.0<1>:f    r5.0<0;1,0>:f                    {Compacted,I@7}
        and (2|M0)               r16.2<1>:d    r16.2<1;1,0>:d    r1.8<1;1,0>:w    {I@3}
        add3 (1|M0)              r17.1<1>:d    r9.0<0;0>:d       r6.0<0;0>:d       r7.0<0>:d        {I@3}
(f1.0.any16h) goto (16|M0)                   L1312                  L1312                
L688:
        cmp (1|M0)    (gt)f1.0   null<1>:d     r2.6<0;1,0>:d     0:w              
        shl (1|M0)               r1.2<1>:d     r16.3<0;1,0>:d    9:w               {I@4}
        shr (1|M0)               r1.3<1>:ud    r16.2<0;1,0>:ud   0x17:uw             
        shl (1|M0)               r17.2<1>:d    r16.2<0;1,0>:d    9:w              
(W)     and (1|M0)               f0.1<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
        shl (1|M0)               r17.4<1>:d    r16.4<0;1,0>:d    5:w              
        mov (1|M0)               r17.5<1>:d    0:w                              
        or (1|M0)                r17.3<1>:d    r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@5}
(~f0.1.any16h) goto (16|M0)                  L1312                  L3864                
L832:
        addc (1|M0)              r4.0<1>:ud    r3.0<0;1,0>:ud    r17.2<0;1,0>:ud  {AccWrEn,I@6}
        mov (1|M0)               r16.6<1>:d    0:w                              
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,F@1}
        addc (1|M0)              r6.0<1>:ud    r4.0<0;1,0>:ud    r17.4<0;1,0>:ud  {AccWrEn,I@3}
        add3 (1|M0)              r1.3<1>:d     r5.0<0;0>:d       r3.1<0;0>:d       r17.3<0>:d       {I@2}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r18.0<2>:f    0.0:f                              
        mov (1|M0)               r18.1<2>:f    0.0:f                              
        mov (1|M0)               r17.6<1>:d    r6.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r17.7<1>:d    r7.0<0;0>:d       r1.3<0;0>:d       r17.5<0>:d       {I@2}
L976:
        addc (1|M0)              r4.0<1>:ud    r18.0<0;1,0>:ud   r17.0<0;1,0>:ud  {AccWrEn,F@2}
        mov (4|M0)               r10.0<2>:f    0.0:f                               {$2.src}
        shl (1|M0)               r6.0<1>:d     r4.0<0;1,0>:d     12:w               {Compacted,I@1}
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r7.0<1>:ud    r17.6<0;1,0>:ud   r6.0<0;1,0>:ud   {AccWrEn,I@2}
        add3 (1|M0)              r1.3<1>:d     r5.0<0;0>:d       r18.1<0;0>:d      r17.1<0>:d       {A@2}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r5.0<1>:ud    r18.0<0;1,0>:ud   0x1:ud              {AccWrEn}
        shr (1|M0)               r2.4<1>:ud    r4.0<0;1,0>:ud    0x14:uw             
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r18.2<1>:d    r5.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r18.3<1>:d    r11.0<0;0>:d      r18.1<0;0>:d      0:w               {I@2}
        shl (1|M0)               r2.3<1>:d     r1.3<0;1,0>:d     12:w               {Compacted}
        cmp (1|M0)    (eq)f0.1   null<1>:d     r18.3<0;1,0>:d    r16.6<0;1,0>:d   {I@2}
        or (1|M0)                r6.1<1>:d     r2.3<0;1,0>:d     r2.4<0;1,0>:d    {I@2}
        mov (4|M0)               r10.1<2>:f    0.0:f                              
        mov (1|M0)               r9.0<1>:f     r7.0<0;1,0>:f                    {Compacted}
(f0.1)  cmp (1|M0)    (eq)f0.1   null<1>:d     r18.2<0;1,0>:d    r16.5<0;1,0>:d  
        add3 (1|M0)              r9.1<1>:d     r8.0<0;0>:d       r17.7<0;0>:d      r6.1<0>:d        {I@2}
        send.ugm (1|M0)          null     r9      r10:1   0x0            0x0200B784           {A@1,$2} // wr:1+1, rd:0; store.ugm.d64x4t.a64
(W)     and (1|M0)               f0.0<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(f0.0.any16h) goto (16|M0)                   L1312                  L3864                
L1280:
(W)     mov (2|M0)               r18.0<1>:ud   r18.2<1;1,0>:ud                 
        goto.b (16|M0)                       L1312                  L976                
L1312:
        join (16|M0)                         L3864                                
L1328:
        cmp (1|M0)    (gt)f0.0   null<1>:d     r2.6<0;1,0>:d     0:w              
        mov (16|M0)              r20.0<1>:ud   0x0:ud                             
        mov (16|M0)              r22.0<1>:f    0.0:f                               {Compacted}
(W)     and (1|M0)               f1.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
(~f1.1.any16h) goto (16|M0)                  L2128                  L2128                
L1400:
        mov (1|M0)               r1.2<1>:d     r3.4<0;1,0>:d                   
        asr (1|M0)               r1.3<1>:d     r3.4<0;1,0>:d     31:w              
        mul (1|M0)               acc0.0<1>:ud  r16.0<0;1,0>:ud   r1.4<0;1,0>:uw   {I@2}
        mach (1|M0)              r5.0<1>:ud    r16.0<0;1,0>:ud   r1.2<0;1,0>:ud   {AccWrEn}
        mov (2|M0)               r18.6<1>:d    r16.5<1;1,0>:d                  
        mov (1|M0)               r4.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r16.0<0;1,0>:d    r1.6<0;1,0>:uw   {Compacted,I@5}
        mach (1|M0)              r6.0<1>:d     r16.0<0;1,0>:d    r1.3<0;1,0>:d    {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r16.1<0;1,0>:d    r1.4<0;1,0>:uw  
        mach (1|M0)              r7.0<1>:d     r16.1<0;1,0>:d    r1.2<0;1,0>:d   
        shl (1|M0)               r8.1<1>:d     r4.0<0;1,0>:d     1:w               {Compacted,I@5}
        add3 (1|M0)              r2.4<1>:d     r7.0<0;0>:d       r5.0<0;0>:d       r6.0<0>:d        {I@2}
        shr (1|M0)               r8.0<1>:ud    r4.0<0;1,0>:ud    0x1F:uw             
        sync.nop                             null                             {Compacted,$2.src}
        addc (1|M0)              r9.0<1>:ud    r3.2<0;1,0>:ud    r8.1<0;1,0>:ud   {AccWrEn,I@3}
        shl (1|M0)               r3.5<1>:d     r2.4<0;1,0>:d     1:w               {I@3}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        or (1|M0)                r8.2<1>:d     r3.5<0;1,0>:d     r8.0<0;1,0>:d    {I@2}
        mov (1|M0)               r19.0<2>:f    0.0:f                              
        mov (1|M0)               r19.1<2>:f    0.0:f                              
        mov (1|M0)               r18.7<1>:d    0:w                              
        mov (1|M0)               r18.4<1>:d    r9.0<0;1,0>:d                   
        add3 (1|M0)              r18.5<1>:d    r10.0<0;0>:d      r3.3<0;0>:d       r8.2<0>:d        {I@3}
L1720:
        shl (1|M0)               r1.2<1>:d     r19.1<0;1,0>:d    5:w               {F@1}
        shr (1|M0)               r1.3<1>:ud    r19.0<0;1,0>:ud   0x1B:uw             
        shl (1|M0)               r1.4<1>:d     r19.0<0;1,0>:d    5:w               {Compacted}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        shl (1|M0)               r4.0<1>:d     r1.4<0;1,0>:d     1:w               {Compacted,I@2}
        shr (1|M0)               r2.4<1>:ud    r1.4<0;1,0>:ud    0x1F:uw             
        shl (1|M0)               r2.3<1>:d     r1.5<0;1,0>:d     1:w               {I@3}
        addc (1|M0)              r5.0<1>:ud    r18.4<0;1,0>:ud   r4.0<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r4.1<1>:d     r2.3<0;1,0>:d     r2.4<0;1,0>:d    {I@2}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r7.0<1>:f     r5.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r7.1<1>:d     r6.0<0;0>:d       r18.5<0;0>:d      r4.1<0>:d        {I@1}
        addc (1|M0)              r14.0<1>:ud   r19.0<0;1,0>:ud   0x1:ud              {AccWrEn}
        send.ugm (1|M0)          r8       r7      null:0  0x0            0x0220C780           {A@1,$3} // wr:1+0, rd:2; load.ugm.d64x8t.a64
        mov (1|M0)               r15.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r19.2<1>:d    r14.0<0;1,0>:d                   {I@2}
        add3 (1|M0)              r19.3<1>:d    r15.0<0;0>:d      r19.1<0;0>:d      0:w               {I@2}
        cmp (1|M0)    (eq)f0.1   null<1>:d     r19.3<0;1,0>:d    r18.7<0;1,0>:d   {I@1}
(f0.1)  cmp (1|M0)    (eq)f0.1   null<1>:d     r19.2<0;1,0>:d    r18.6<0;1,0>:d  
(W)     and (1|M0)               f1.0<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
        mov (8|M0)               r10.0<1>:f    (abs)r8.0<1;1,0>:hf              {$3.dst}
        mov (8|M0)               r11.0<1>:f    (abs)r8.8<1;1,0>:hf             
        mov (8|M0)               r12.0<1>:f    (abs)r9.0<1;1,0>:hf             
        mov (8|M0)               r13.0<1>:f    (abs)r9.8<1;1,0>:hf             
        sel (16|M0)   (ge)f0.0   r20.0<1>:f    r20.0<1;1,0>:f    r10.0<1;1,0>:f   {Compacted,F@3}
        sel (16|M0)   (ge)f0.0   r22.0<1>:f    r22.0<1;1,0>:f    r12.0<1;1,0>:f   {Compacted,F@2}
(f1.0.any16h) goto (16|M0)                   L2128                  L2128                
L2096:
(W)     mov (2|M0)               r19.0<1>:ud   r19.2<1;1,0>:ud                 
        goto.b (16|M0)                       L2128                  L1720                
L2128:
        join (16|M0)                         L3864                                
L2144:
        sel (16|M0)   (ge)f0.0   r20.0<1>:f    r20.0<1;1,0>:f    r22.0<1;1,0>:f   {Compacted,F@1}
        sel (8|M0)    (ge)f0.0   r4.0<1>:f     r20.0<1;1,0>:f    r21.0<1;1,0>:f   {Compacted,F@1}
        mov (4|M0)               r5.0<1>:ud    r4.4<1;1,0>:ud                   {F@1}
        sel (4|M0)    (ge)f0.0   r6.0<1>:f     r4.0<1;1,0>:f     r5.0<1;1,0>:f    {I@1}
        mov (2|M0)               r7.0<1>:ud    r6.2<1;1,0>:ud                   {F@1}
        sel (2|M0)    (ge)f0.0   r8.0<1>:f     r6.0<1;1,0>:f     r7.0<1;1,0>:f    {I@1}
        sel (1|M0)    (ge)f0.0   r83.4<1>:f    r8.0<0;1,0>:f     r8.1<0;1,0>:f    {F@1}
        cmp (1|M0)    (eq)f0.1   null<1>:f     r83.4<0;1,0>:f    0.0:f               {F@1}
(W)     and (1|M0)               f0.1<1>:uw    f0.1<0;1,0>:uw    0x1:uw              {F@1}
(f0.1.any16h) goto (16|M0)                   L2368                  L2368                
L2288:
        mov (1|M0)               r83.5<1>:f    127.0:f                              
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r83.2         L7064                                 {A@1}
L2352:
        goto (16|M0)                         L2368                  L2392                
L2368:
        join (16|M0)                         L2392                                
L2384:
        mov (1|M0)               r24.0<1>:f    1.0:f                               {Compacted}
L2392:
        join (16|M0)                         L3864                                
L2408:
        shl (1|M0)               r1.4<1>:d     r16.0<0;1,0>:d    2:w               {Compacted}
        shl (1|M0)               r1.2<1>:d     r16.1<0;1,0>:d    2:w              
        shr (1|M0)               r1.3<1>:ud    r16.0<0;1,0>:ud   0x1E:uw             
        addc (1|M0)              r4.0<1>:ud    r3.6<0;1,0>:ud    r1.4<0;1,0>:ud   {AccWrEn,I@3}
(W)     and (1|M0)               f1.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@3}
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        shl (1|M0)               r2.3<1>:d     r16.3<0;1,0>:d    9:w               {Compacted}
        shr (1|M0)               r2.4<1>:ud    r16.2<0;1,0>:ud   0x17:uw             
        mov (1|M0)               r6.0<1>:f     r4.0<0;1,0>:f                    {Compacted,I@6}
        add3 (1|M0)              r6.1<1>:d     r5.0<0;0>:d       r3.7<0;0>:d       r1.5<0>:d        {I@3}
        shl (1|M0)               r19.4<1>:d    r16.2<0;1,0>:d    9:w              
        send.ugm (1|M0)          null     r6      r24:1   0x0            0x04000584           {A@1,$4} // wr:2+1, rd:0; store.ugm.d32.a64
        shl (1|M0)               r19.6<1>:d    r16.4<0;1,0>:d    5:w              
        mov (1|M0)               r19.7<1>:d    0:w                              
        or (1|M0)                r19.5<1>:d    r2.3<0;1,0>:d     r2.4<0;1,0>:d   
(~f1.1.any16h) goto (16|M0)                  L3864                  L3864                
L2648:
        mov (1|M0)               r1.2<1>:d     r3.4<0;1,0>:d                   
        asr (1|M0)               r1.3<1>:d     r3.4<0;1,0>:d     31:w              
        mul (1|M0)               acc0.0<1>:ud  r16.0<0;1,0>:ud   r1.4<0;1,0>:uw   {I@2}
        mach (1|M0)              r5.0<1>:ud    r16.0<0;1,0>:ud   r1.2<0;1,0>:ud   {AccWrEn}
        mov (16|M0)              r25.0<1>:f    r24.0<0;1,0>:f                   {Compacted}
        mov (1|M0)               r4.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r16.0<0;1,0>:d    r1.6<0;1,0>:uw   {Compacted,I@4}
        shl (1|M0)               r8.1<1>:d     r4.0<0;1,0>:d     1:w               {Compacted,I@2}
        mach (1|M0)              r6.0<1>:d     r16.0<0;1,0>:d    r1.3<0;1,0>:d    {Compacted,$4.src}
(W)     mul (1|M0)               acc0.0<1>:d   r16.1<0;1,0>:d    r1.4<0;1,0>:uw  
        mach (1|M0)              r7.0<1>:d     r16.1<0;1,0>:d    r1.2<0;1,0>:d   
        sync.nop                             null                             {Compacted,$2.src}
        addc (1|M0)              r9.0<1>:ud    r3.2<0;1,0>:ud    r8.1<0;1,0>:ud   {AccWrEn,I@4}
        add3 (1|M0)              r2.4<1>:d     r7.0<0;0>:d       r5.0<0;0>:d       r6.0<0>:d        {I@2}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r11.0<1>:ud   r3.0<0;1,0>:ud    r19.4<0;1,0>:ud  {AccWrEn}
        shr (1|M0)               r8.0<1>:ud    r4.0<0;1,0>:ud    0x1F:uw             
        shl (1|M0)               r3.5<1>:d     r2.4<0;1,0>:d     1:w               {I@4}
        mov (1|M0)               r12.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r6.0<1>:ud    r11.0<0;1,0>:ud   r19.6<0;1,0>:ud  {AccWrEn,I@4}
        or (1|M0)                r8.2<1>:d     r3.5<0;1,0>:d     r8.0<0;1,0>:d    {I@3}
        add3 (1|M0)              r1.3<1>:d     r12.0<0;0>:d      r3.1<0;0>:d       r19.5<0>:d       {I@3}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r16.6<1>:d    0:w                              
        mov (1|M0)               r24.6<2>:f    0.0:f                              
        mov (1|M0)               r24.7<2>:f    0.0:f                              
        mov (1|M0)               r24.1<1>:d    r9.0<0;1,0>:d                   
        mov (1|M0)               r24.3<1>:d    r6.0<0;1,0>:d                    {I@6}
        add3 (1|M0)              r24.2<1>:d    r10.0<0;0>:d      r3.3<0;0>:d       r8.2<0>:d        {I@6}
        add3 (1|M0)              r24.4<1>:d    r7.0<0;0>:d       r1.3<0;0>:d       r19.7<0>:d       {I@5}
L3056:
        shl (1|M0)               r1.2<1>:d     r24.7<0;1,0>:d    5:w               {F@1}
        shr (1|M0)               r1.3<1>:ud    r24.6<0;1,0>:ud   0x1B:uw             
        shl (1|M0)               r1.4<1>:d     r24.6<0;1,0>:d    5:w              
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        shl (1|M0)               r4.0<1>:d     r1.4<0;1,0>:d     1:w               {Compacted,I@2}
        shr (1|M0)               r2.4<1>:ud    r1.4<0;1,0>:ud    0x1F:uw             
        shl (1|M0)               r2.3<1>:d     r1.5<0;1,0>:d     1:w               {I@3}
        addc (1|M0)              r5.0<1>:ud    r24.1<0;1,0>:ud   r4.0<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r4.1<1>:d     r2.3<0;1,0>:d     r2.4<0;1,0>:d    {I@2}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r7.0<1>:f     r5.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r7.1<1>:d     r6.0<0;0>:d       r24.2<0;0>:d      r4.1<0>:d        {I@1}
        mov (16|M0)              r39.0<1>:f    r25.0<1;1,0>:f                   {Compacted}
        send.ugm (1|M0)          r8       r7      null:0  0x0            0x0220C780           {A@1,$6} // wr:1+0, rd:2; load.ugm.d64x8t.a64
        mov (8|M0)               r32.0<1>:f    r8.0<1;1,0>:hf                   {$6.dst}
        mov (8|M0)               r33.0<1>:f    r8.8<1;1,0>:hf                  
        mov (8|M0)               r27.0<1>:f    r9.0<1;1,0>:hf                  
        mov (8|M0)               r28.0<1>:f    r9.8<1;1,0>:hf                  
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r83.6         L3936                                 {A@1}
L3360:
        mov (16|M0)              r29.0<1>:ud   r73.0<1;1,0>:ud                 
        mov (16|M0)              r32.0<1>:f    r27.0<1;1,0>:f                   {Compacted,F@1}
        mov (16|M0)              r39.0<1>:f    r25.0<1;1,0>:f                   {Compacted}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r83.6         L3936                                 {A@1}
L3440:
        addc (1|M0)              r4.0<1>:ud    r24.6<0;1,0>:ud   r17.0<0;1,0>:ud  {AccWrEn}
        rnde (16|M0)             r29.0<1>:f    r29.0<1;1,0>:f                   {Compacted,I@3}
        shl (1|M0)               r6.0<1>:d     r4.0<0;1,0>:d     12:w               {Compacted,I@1}
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r7.0<1>:ud    r24.3<0;1,0>:ud   r6.0<0;1,0>:ud   {AccWrEn,I@2}
        add3 (1|M0)              r1.3<1>:d     r5.0<0;0>:d       r24.7<0;0>:d      r17.1<0>:d       {I@2}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r5.0<1>:ud    r24.6<0;1,0>:ud   0x1:ud              {AccWrEn}
        shr (1|M0)               r2.4<1>:ud    r4.0<0;1,0>:ud    0x14:uw             
        mov (1|M0)               r4.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        rnde (16|M0)             r73.0<1>:f    r73.0<1;1,0>:f                   {Compacted}
        add3 (1|M0)              r31.1<1>:d    r4.0<0;0>:d       r24.7<0;0>:d      0:w               {I@1}
        mov (1|M0)               r31.0<1>:f    r5.0<0;1,0>:f                    {Compacted}
        cmp (1|M0)    (eq)f0.0   null<1>:d     r31.1<0;1,0>:d    r16.6<0;1,0>:d   {I@1}
        sel (16|M0)   (ge)f0.0   r29.0<1>:f    r29.0<1;1,0>:f    -127.0:f               {F@3}
        sel (16|M0)   (ge)f0.0   r73.0<1>:f    r73.0<1;1,0>:f    -127.0:f               {F@3}
(f0.0)  cmp (1|M0)    (eq)f0.0   null<1>:d     r31.0<0;1,0>:d    r16.5<0;1,0>:d   {F@3}
        shl (1|M0)               r2.3<1>:d     r1.3<0;1,0>:d     12:w               {Compacted}
        sel (16|M0)   (lt)f0.0   r29.0<1>:f    r29.0<1;1,0>:f    127.0:f               {F@2}
        sel (16|M0)   (lt)f0.0   r73.0<1>:f    r73.0<1;1,0>:f    127.0:f               {F@2}
        or (1|M0)                r6.1<1>:d     r2.3<0;1,0>:d     r2.4<0;1,0>:d    {I@1}
        mov (16|M0)              r10.0<1>:d    r29.0<1;1,0>:f                   {Compacted,F@2}
(W)     and (1|M0)               f1.0<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
        mov (16|M0)              r12.0<1>:d    r73.0<1;1,0>:f                   {Compacted,F@1}
        mov (1|M0)               r9.0<1>:f     r7.0<0;1,0>:f                    {Compacted}
        add3 (1|M0)              r9.1<1>:d     r8.0<0;0>:d       r24.4<0;0>:d      r6.1<0>:d        {I@4}
        mov (16|M0)              r14.0<1>:b    r10.0<4;1,0>:b                   {I@4}
        mov (16|M0)              r14.16<1>:b   r12.0<4;1,0>:b                   {I@3}
        send.ugm (1|M0)          null     r9      r14:1   0x0            0x0200B784           {A@1,$5} // wr:1+1, rd:0; store.ugm.d64x4t.a64
(f1.0.any16h) goto (16|M0)                   L3864                  L3864                
L3832:
(W)     mov (2|M0)               r24.6<1>:ud   r31.0<1;1,0>:ud                 
        goto.b (16|M0)                       L3864                  L3056                
L3864:
        join (16|M0)                         L3880                                
L3880:
(W)     mov (8|M0)               r127.0<1>:f   r0.0<1;1,0>:f                    {Compacted}
(W)     send.ugm (1|M0)          r4       r0      null:0  0x0            0x0210641F           {$7} // wr:1+0, rd:1; fence invalid flush type scoped to tile
(W)     mov (8|M0)               null<1>:ud    r4.0<1;1,0>:ud                   {$7.dst}
(W)     send.gtwy (1|M0)         null     r127    null:0  0x0            0x02000010           {EOT,A@1} // wr:1+0, rd:0; end of thread
L3936:
(W)     shr (16|M0)              r4.0<1>:ud    r32.0<1;1,0>:ud   0x17:uw             
(W)     and (16|M0)              r34.0<1>:w    r4.0<2;1,0>:w     255:w               {I@1}
(W)     add (16|M0)              r8.0<1>:d     r34.0<1;1,0>:uw   -191:w               {I@1}
(W)     cmp (16|M0)   (lt)f1.1   null<1>:d     r8.0<1;1,0>:ud    0xFFFFFF82:ud              {I@1}
(W)     shr (16|M0)              r6.0<1>:ud    r39.0<1;1,0>:ud   0x17:uw             
(W)     mov (1|M0)               r82.14<1>:uw  f1.1<0;1,0>:uw                   {Compacted}
(W)     and (16|M0)              r41.0<1>:w    r6.0<2;1,0>:w     255:w               {I@2}
(W)     mov (1|M0)               f1.0<1>:uw    r82.14<0;1,0>:uw                 {I@2}
(W)     add (16|M0)              r10.0<1>:d    r41.0<1;1,0>:uw   -191:w               {I@2}
(W)     mov (16|M0)              r35.0<1>:d    r34.0<1;1,0>:uw                 
(W&~f1.0) cmp (16|M0) (lt)f1.0   null<1>:d     r10.0<1;1,0>:ud   0xFFFFFF81:ud              {I@2}
(W)     mov (16|M0)              r37.0<1>:d    r34.0<1;1,0>:uw                 
(W)     mov (1|M0)               r82.14<1>:uw  f1.0<0;1,0>:uw                   {Compacted}
(W)     mov (16|M0)              r42.0<1>:d    r41.0<1;1,0>:uw                 
(W)     mov (1|M0)               f0.1<1>:uw    r82.14<0;1,0>:uw                 {I@2}
(W)     mov (16|M0)              r44.0<1>:d    r41.0<1;1,0>:uw                 
(~f0.1.any16h) goto (16|M0)                  L6736                  L6736                
L4192:
(W)     add (16|M0)              r4.0<1>:d     r34.0<1;1,0>:uw   -255:w              
(W)     cmp (16|M0)   (lt)f1.1   null<1>:d     r4.0<1;1,0>:ud    0xFFFFFF02:ud              {I@1}
(W)     add (16|M0)              r6.0<1>:d     r41.0<1;1,0>:uw   -255:w              
(W&~f1.1) cmp (16|M0) (lt)f1.1   null<1>:d     r6.0<1;1,0>:ud    0xFFFFFF02:ud              {I@1}
(W)     mov (16|M0)              r56.0<1>:f    (abs)r32.0<1;1,0>:f              {Compacted}
(f1.1.any16h) goto (16|M0)                   L4352                  L4352                
L4280:
(W)     mov (16|M0)              r4.0<1>:f     (abs)r39.0<1;1,0>:f              {Compacted}
(W)     add (16|M0)              r56.0<1>:d    r56.0<1;1,0>:d    -r4.0<1;1,0>:d   {Compacted,A@1}
(W)     mov (4|M0)               r31.2<1>:d    0:w                              
(W)     mov (16|M0)              r68.0<1>:f    r32.0<1;1,0>:f                   {Compacted}
(W)     mov (16|M0)              r58.0<1>:f    r39.0<1;1,0>:f                   {Compacted}
(W)     asr (16|M0)              r56.0<1>:d    r56.0<1;1,0>:d    23:w               {Compacted,I@2}
        goto (16|M0)                         L4352                  L5608                
L4352:
        join (16|M0)                         L5608                                
L4368:
(W)     mov (16|M0)              r54.0<1>:f    (abs)r39.0<1;1,0>:f              {Compacted}
(W)     cmp (16|M0)   (gt)f0.1   null<1>:d     r56.0<1;1,0>:ud   0x7F800000:ud              {I@3}
(W)     cmp (16|M0)   (lt)f1.0   null<1>:d     r54.0<1;1,0>:ud   0x7F800001:ud              {F@1}
(W)     and (16|M0)              r46.0<1>:ud   r32.0<1;1,0>:ud   0x7F800000:ud             
(W)     mov (1|M0)               r1.3<1>:uw    f0.1<0;1,0>:uw                  
(W)     and (16|M0)              r48.0<1>:ud   r39.0<1;1,0>:ud   0x7F800000:ud             
(W)     mov (1|M0)               r2.6<1>:uw    f1.0<0;1,0>:uw                   {Compacted}
(W)     or (1|M0)                f0.0<1>:uw    f1.0<0;1,0>:uw    r1.3<0;1,0>:uw   {I@3}
(W)     cmp (16|M0)   (ne)f1.0   null<1>:d     r46.0<1;1,0>:d    2139095040:d              
(W)     or (1|M0)                r3.10<1>:uw   f0.1<0;1,0>:uw    ~r2.6<0;1,0>:uw  {I@3}
(W)     cmp (16|M0)   (ne)f0.1   null<1>:d     r48.0<1;1,0>:d    2139095040:d              
(W)     or (1|M0)                r3.11<1>:uw   f1.0<0;1,0>:uw    r3.10<0;1,0>:uw  {I@2}
(W)     or (1|M0)                r3.10<1>:uw   ~f1.0<0;1,0>:uw   r3.10<0;1,0>:uw 
(W)     mov (1|M0)               r2.6<1>:hf    -qnan(0x1FF):hf                             
(W)     or (1|M0)                r1.3<1>:uw    f0.1<0;1,0>:uw    r3.10<0;1,0>:uw  {I@1}
(W)     or (1|M0)                r3.10<1>:uw   ~f0.1<0;1,0>:uw   r3.10<0;1,0>:uw 
(W)     mov (1|M0)               r8.0<1>:f     -0.0:f                               {Compacted}
(W)     mov (1|M0)               f0.1<1>:uw    r3.10<0;1,0>:uw                  {I@1}
(W&f0.0) sel (16|M0)             acc0.0<1>:f   r32.0<1;1,0>:f    r39.0<1;1,0>:f  
(W)     mov (1|M0)               f0.0<1>:uw    r3.11<0;1,0>:uw                  {F@1}
(W&f0.1) sel (16|M0)             r11.0<2>:b    r2.6<0;1,0>:w     0:w              
(W)     cmp (16|M0)   (eq)f0.1   null<1>:f     r39.0<1;1,0>:f    0.0:f               {A@1}
(W)     bfn.0x6A (16|M0)         r73.0<1>:ud   r32.0<1;0>:ud     r39.0<1;0>:ud     r8.0<0>:ud       // s0^s1&s2
(W)     bfn.0x6A (16|M0)         r9.0<1>:ud    r39.0<1;0>:ud     r32.0<1;0>:ud     r8.0<0>:ud       // s0^s1&s2
(W)     add (16|M0)              r73.0<1>:f    r73.0<1;1,0>:f    -r9.0<1;1,0>:f   {Compacted,A@1}
(W&f0.0) add (16|M0)             r73.0<1>:f    acc0.0<1;1,0>:f   r39.0<1;1,0>:f  
(W)     and (1|M0)               r4.0<1>:uw    f0.1<0;1,0>:uw    ~r3.10<0;1,0>:uw
(W)     mov (1|M0)               f1.0<1>:uw    r1.3<0;1,0>:uw                  
(W)     mov (1|M0)               f0.0<1>:uw    r4.0<0;1,0>:uw                   {A@1}
(W)     and (16|M0)              r6.0<1>:ud    r39.0<1;1,0>:ud   0x80000000:ud             
(W)     and (16|M0)              r50.0<1>:ud   r32.0<1;1,0>:ud   0x80000000:ud             
(W)     mov (16|M0)              r31.8<1>:b    r11.0<2;1,0>:b                  
(W&~f1.0) mul (16|M0)            r73.0<1>:f    r6.0<1;1,0>:f     r32.0<1;1,0>:f   {I@3}
(~f0.0) goto (16|M0)                         L5000                  L5000                
L4880:
(W)     cmp (16|M0)   (eq)f1.0   null<1>:f     r32.0<1;1,0>:f    0.0:f              
(W)     mov (1|M0)               r1.2<1>:ud    0x7F800000:ud                             
(W)     mov (1|M0)               r2.12<2>:b    -1:w                              
(W&f1.0) mov (16|M0)             r50.0<1>:ud   0:w                              
(W)     bfn.0x96 (16|M0)         r50.0<1>:ud   r1.2<0;0>:ud      r50.0<1;0>:ud     r39.0<1>:ud      {I@1} // s0^s1^s2
(W&f1.0) mul (16|M0)             r50.0<1>:f    r50.0<1;1,0>:f    r32.0<1;1,0>:f   {I@1}
        mov (16|M0)              r31.8<1>:b    r2.12<0;1,0>:b                  
        mov (16|M0)              r73.0<1>:f    r50.0<1;1,0>:f                   {Compacted,F@1}
L5000:
        join (16|M0)                         L5608                                
L5016:
(W)     cmp (16|M0)   (eq)f1.0   null<1>:f     r32.0<1;1,0>:f    0.0:f              
(W&f1.0) cmp (16|M0)  (eq)f1.0   null<1>:w     r31.8<1;1,0>:ub   0x0:uw              {A@1}
(W&~f1.0) sel (16|M0)            r4.0<2>:b     r31.8<1;1,0>:b    -1:w              
(W)     mov (16|M0)              r31.8<1>:b    r4.0<2;1,0>:b                    {I@1}
(W&f1.0) mul (16|M0)             r73.0<1>:f    r32.0<1;1,0>:f    r39.0<1;1,0>:f  
(W)     cmp (16|M0)   (ne)f1.0   null<1>:w     r31.8<1;1,0>:ub   0x0:uw              {A@1}
(f1.0.all16h) goto (16|M0)                   L5608                  L6736                
L5128:
(W)     cmp (16|M0)   (eq)f0.0   null<1>:w     r31.8<1;1,0>:ub   0x0:uw             
(W)     mov (1|M0)               r1.3<1>:uw    f1.1<0;1,0>:uw                  
(W)     cmp (16|M0)   (eq)f0.1   null<1>:d     r46.0<1;1,0>:d    0:w              
(W)     and (1|M0)               f1.1<1>:uw    f0.0<0;1,0>:uw    r1.3<0;1,0>:uw   {I@2}
(W)     mov (16|M0)              r60.0<1>:d    0:w                              
(W)     mov (1|M0)               r2.6<1>:uw    f0.1<0;1,0>:uw                  
(W)     mov (16|M0)              r68.0<1>:f    r32.0<1;1,0>:f                   {Compacted}
(W)     and (1|M0)               f1.0<1>:uw    f1.1<0;1,0>:uw    r2.6<0;1,0>:uw   {I@1}
(W)     mov (16|M0)              r52.0<1>:f    r60.0<1;1,0>:f                   {Compacted}
(~f1.0) goto (16|M0)                         L5368                  L5368                
L5272:
        mul (16|M0)              r68.0<1>:f    r32.0<1;1,0>:f    0x4F800000:f               {Compacted}
(W)     shr (16|M0)              r4.0<1>:ud    r68.0<1;1,0>:ud   0x17:uw              {F@1}
(W)     and (16|M0)              r6.0<1>:w     r4.0<2;1,0>:w     255:w               {I@1}
        add (16|M0)              r37.0<1>:d    r6.0<1;1,0>:uw    -32:w               {I@1}
(W)     mov (16|M0)              r52.0<1>:d    0:w                              
(W)     mov (16|M0)              r35.0<1>:f    r37.0<1;1,0>:f                   {Compacted,I@2}
        mov (16|M0)              r52.0<1>:d    -32:w                              
L5368:
        join (16|M0)                         L5608                                
L5384:
(W)     cmp (16|M0)   (eq)f0.0   null<1>:d     r48.0<1;1,0>:d    0:w               {Compacted}
(W)     mov (16|M0)              r58.0<1>:f    r39.0<1;1,0>:f                   {Compacted}
(W)     mov (1|M0)               r1.3<1>:uw    f0.0<0;1,0>:uw                  
(W)     and (1|M0)               f0.1<1>:uw    f1.1<0;1,0>:uw    r1.3<0;1,0>:uw   {I@1}
(~f0.1) goto (16|M0)                         L5552                  L5552                
L5448:
        mul (16|M0)              r58.0<1>:f    r39.0<1;1,0>:f    0x4F800000:f               {Compacted}
(W)     shr (16|M0)              r4.0<1>:ud    r58.0<1;1,0>:ud   0x17:uw              {F@1}
(W)     and (16|M0)              r6.0<1>:w     r4.0<2;1,0>:w     255:w               {I@1}
        add (16|M0)              r44.0<1>:d    r6.0<1;1,0>:uw    -32:w               {I@1}
(W)     mov (16|M0)              r60.0<1>:d    0:w                              
(W)     mov (16|M0)              r54.0<1>:f    (abs)r58.0<1;1,0>:f              {Compacted}
(W)     mov (16|M0)              r42.0<1>:f    r44.0<1;1,0>:f                   {Compacted,I@2}
        mov (16|M0)              r60.0<1>:d    32:w                              
L5552:
        join (16|M0)                         L5608                                
L5568:
(W)     mov (16|M0)              r56.0<1>:f    (abs)r68.0<1;1,0>:f              {Compacted}
(W)     add (16|M0)              r56.0<1>:d    r56.0<1;1,0>:d    -r54.0<1;1,0>:d  {Compacted,F@1}
(W)     asr (16|M0)              r56.0<1>:d    r56.0<1;1,0>:d    23:w               {Compacted,I@1}
(W)     add3 (16|M0)             r60.0<1>:d    r60.0<1;0>:d      r52.0<1;0>:d      r56.0<1>:d       {I@1}
L5608:
        join (16|M0)                         L6736                                
L5624:
(W)     mov (1|M0)               r1.2<1>:f     1.0:f                               {Compacted}
(W)     mov (1|M0)               r4.0<1>:f     0x807FFFFF:f                              
(W&~f1.1) mov (16|M0)            r60.0<1>:f    r56.0<1;1,0>:f                   {I@2}
(W)     bfn.0xEA (16|M0)         r58.0<1>:ud   r1.2<0;0>:ud      r58.0<1;0>:ud     r4.0<0>:ud       {A@2} // s0|s1&s2
(W)     add (16|M0)              r62.0<1>:d    r60.0<1;1,0>:d    126:w               {Compacted,F@1}
(W)     add (16|M0)              r5.0<1>:d     -r60.0<1;1,0>:d   -152:w               {Compacted}
        sync.nop                             null                             {Compacted,I@3}
(W)     math.inv (16|M0)         r7.0<1>:f     r58.0<1;1,0>:f                   {$8}
(W)     cmp (16|M0)   (eq)f1.0   null<1>:w     r31.8<1;1,0>:ub   0x0:uw             
(W)     and (16|M0)              r5.0<1>:d     r5.0<1;1,0>:d     r62.0<1;1,0>:d   {Compacted,I@2}
(W)     mov (1|M0)               r2.3<1>:f     1.0:f                               {Compacted}
(W)     bfn.0xEA (16|M0)         r68.0<1>:ud   r1.2<0;0>:ud      r68.0<1;0>:ud     r4.0<0>:ud       // s0|s1&s2
(W)     asr (16|M0)              r5.0<1>:d     r5.0<1;1,0>:d     31:w               {Compacted,I@2}
        sync.nop                             null                             {Compacted,$8.dst}
(W)     mad (16|M0)              r64.0<1>:f    r2.3<0;0>:f       r7.0<1;0>:f       -r58.0<1>:f      {F@1}
(W)     mul (16|M0)              acc0.0<1>:f   r7.0<1;1,0>:f     r68.0<1;1,0>:f   {Compacted,I@2}
(W&f1.0) sel (16|M0)             r70.0<1>:w    r5.0<4;1,0>:ub    0:w               {I@1}
(W)     mad (16|M0)              r64.0<1>:f    r7.0<1;0>:f       r7.0<1;0>:f       r64.0<1>:f       {Compacted,F@2}
(W)     mad (16|M0)              r66.0<1>:f    r68.0<1;0>:f      acc0.0<1;0>:f     -r58.0<1>:f     
(W)     cmp (16|M0)   (ne)f0.1   null<1>:w     r70.0<2;1,0>:ub   0x0:uw              {I@1}
(W)     mad (16|M0)              r66.0<1>:f    acc0.0<1;0>:f     r64.0<1;0>:f      r66.0<1>:f       {F@1}
(W)     add (16|M0)              r35.0<1>:d    r35.0<1;1,0>:d    -r42.0<1;1,0>:d  {Compacted}
(W)     mad (16|M0)              r68.0<1>:f    r68.0<1;0>:f      r66.0<1;0>:f      -r58.0<1>:f      {Compacted,F@1}
(~f0.1.any16h) goto (16|M0)                  L6480                  L6480                
L5912:
(W)     mov (16|M0)              r79.0<1>:ud   r68.0<1;1,0>:ud                  {F@1}
(W)     mov (16|M0)              r75.0<1>:f    r64.0<1;1,0>:f                   {Compacted}
(W)     mov (16|M0)              r77.0<1>:f    r66.0<1;1,0>:f                   {Compacted}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r84.2         L6944                                 {A@1}
L5992:
(W)     add (16|M0)              r60.0<1>:d    r60.0<1;1,0>:d    125:w               {Compacted}
(W)     cmp (16|M0)   (lt)f0.0   null<1>:d     r60.0<1;1,0>:d    -2:w               {Compacted,I@1}
(W)     cmp (16|M0)   (eq)f1.1   null<1>:f     r68.0<1;1,0>:f    0.0:f              
(W)     mov (1|M0)               r1.3<1>:uw    f0.0<0;1,0>:uw                  
(W)     or (1|M0)                f0.0<1>:uw    f1.1<0;1,0>:uw    r1.3<0;1,0>:uw   {I@1}
(f0.0.any16h) goto (16|M0)                   L6120                  L6120                
L6072:
(W)     mov (1|M0)               r1.3<1>:hf    0x1:hf                              {I@2}
(W&f1.1) sel (16|M0)             r71.0<1>:d    r1.3<0;1,0>:w     0:w               {F@1}
        goto (16|M0)                         L6120                  L6240                
L6120:
        join (16|M0)                         L6240                                
L6136:
(W)     mov (1|M0)               r1.3<1>:hf    0x1:hf                              {I@3}
(W)     and (16|M0)              r4.0<1>:d     r79.0<1;1,0>:d    -2139095041:d              
(W)     mov (1|M0)               r6.0<1>:f     0x800000:f                               {Compacted}
(W)     shl (16|M0)              r62.0<1>:d    r62.0<1;1,0>:d    23:w               {Compacted}
(W&f1.1) sel (16|M0)             r71.0<1>:d    r1.3<0;1,0>:w     0:w               {F@2}
(W)     add (16|M0)              r62.0<1>:d    r62.0<1;1,0>:d    1065353216:d               {I@2}
(W)     bfn.0xFE (16|M0)         r4.0<1>:ud    r4.0<1;0>:ud      r71.0<1;0>:ud     r6.0<0>:ud       {A@1} // s0|s1|s2
(W)     mul (16|M0)              r62.0<1>:f    r62.0<1;1,0>:f    r4.0<1;1,0>:f    {Compacted,A@1}
L6240:
        join (16|M0)                         L6480                                
L6256:
(W)     and (16|M0)   (eq)f1.1   null<1>:ud    r79.0<1;1,0>:ud   0x400000:ud             
(W)     shl (16|M0)              r4.0<1>:d     r79.0<1;1,0>:d    1:w               {Compacted,F@1}
(W)     mov (1|M0)               r1.2<1>:f     0x800000:f                               {Compacted}
(W)     mov (1|M0)               r6.0<1>:f     -0.0:f                               {Compacted}
(W)     mov (1|M0)               r2.3<1>:f     1.469368e-38:f                               {Compacted}
(W)     and (16|M0)              r4.0<1>:d     r4.0<1;1,0>:d     8388606:d               {I@1}
(W)     bfn.0xEA (16|M0)         r7.0<1>:ud    r1.2<0;0>:ud      r79.0<1;0>:ud     r6.0<0>:ud       {A@2} // s0|s1&s2
(W&f1.1) sel (16|M0)             r9.0<1>:d     r2.3<0;1,0>:d     12582912:d               {F@1}
(W)     mov (1|M0)               r3.5<1>:f     0.25:f                               {Compacted}
(W)     bfn.0xFE (16|M0)         r71.0<1>:ud   r71.0<1;0>:ud     r7.0<1;0>:ud      r4.0<1>:ud       {I@2} // s0|s1|s2
(W)     bfn.0xEA (16|M0)         r9.0<1>:ud    r9.0<1;0>:ud      r79.0<1;0>:ud     r6.0<0>:ud       {I@2} // s0|s1&s2
(W)     mad (16|M0)              r71.0<1>:f    r9.0<1;0>:f       r71.0<1;0>:f      r3.5<0>:f        {Compacted,A@1}
(W)     add (16|M0)              r71.0<1>:f    r71.0<1;1,0>:f    -r7.0<1;1,0>:f   {Compacted,F@1}
(W)     mul (16|M0)              r7.0<1>:f     r7.0<1;1,0>:f     r7.0<1;1,0>:f    {Compacted}
(W)     bfn.0xAE (16|M0)         r71.0<1>:ud   r71.0<1;0>:ud     r7.0<1;0>:ud      0x1:uw              {A@1} // s0|s1&~s2
(W&~f0.0) mov (16|M0)            r62.0<1>:f    r71.0<1;1,0>:f                   {I@1}
(W)     and (16|M0)   (ne)f0.0   null<1>:w     r70.0<2;1,0>:ub   1:w               {F@1}
(W&f0.0) mov (16|M0)             r73.0<1>:f    r62.0<1;1,0>:f                  
L6480:
        join (16|M0)                         L6736                                
L6496:
(W)     add (16|M0)              r4.0<1>:d     r35.0<1;1,0>:d    -253:w               {Compacted}
(W)     cmp (16|M0)   (lt)f1.1   null<1>:d     r4.0<1;1,0>:ud    0xFFFFFE85:ud              {I@1}
(W)     asr (16|M0)              r6.0<1>:d     r35.0<1;1,0>:d    11:w               {Compacted}
(W)     mov (1|M0)               r1.3<1>:hf    -qnan(0x1FF):hf                             
(W)     add (16|M0)              r8.0<1>:d     r6.0<1;1,0>:d     248:w               {Compacted,I@1}
(W&f1.1.any16h) sel (1|M0)       r2.6<1>:w     r1.3<0;1,0>:w     0:w               {F@1}
(W)     mov (16|M0)              r10.0<1>:f    r35.0<1;1,0>:f                   {Compacted}
(W&f1.1) xor (16|M0)             r10.0<1>:d    r8.0<1;1,0>:d     r6.0<1;1,0>:d    {A@1}
(W)     mov (1|M0)               f1.1<1>:uw    r2.6<0;1,0>:uw                   {I@2}
(W)     mov (16|M0)              r4.0<1>:uw    r31.8<1;1,0>:ub                 
(W)     mad (16|M0)              r68.0<1>:f    r66.0<1;0>:f      r64.0<1;0>:f      r68.0<1>:f       {Compacted}
(W&~f1.1) mov (16|M0)            r10.0<1>:f    r35.0<1;1,0>:f                   {I@3}
(W)     asr (16|M0)              r12.0<1>:d    r10.0<1;1,0>:d    1:w               {Compacted,F@1}
(W)     add (16|M0)              r10.0<1>:d    r10.0<1;1,0>:d    -r12.0<1;1,0>:d  {Compacted,I@1}
(W)     or (16|M0)    (eq)f1.0   null<1>:w     r70.0<2;1,0>:ub   r4.0<1;1,0>:uw  
(W)     shl (16|M0)              r12.0<1>:d    r12.0<1;1,0>:d    23:w               {Compacted}
(W)     shl (16|M0)              r10.0<1>:d    r10.0<1;1,0>:d    23:w               {Compacted,I@3}
(W)     add (16|M0)              r12.0<1>:d    r12.0<1;1,0>:d    r68.0<1;1,0>:d   {Compacted,I@2}
(W)     add (16|M0)              r10.0<1>:d    r10.0<1;1,0>:d    1065353216:d               {I@2}
(W&f1.0) mul (16|M0)             r73.0<1>:f    r12.0<1;1,0>:f    r10.0<1;1,0>:f   {A@1}
L6736:
        join (16|M0)                         L6752                                
L6752:
(W)     math.inv (16|M0)         r4.0<1>:f     r39.0<1;1,0>:f                   {$9}
(W)     mov (1|M0)               r1.2<1>:ud    0x3F800000:ud                             
(W)     mul (16|M0)              acc0.0<1>:f   r4.0<1;1,0>:f     r32.0<1;1,0>:f   {Compacted,$9.dst}
(W)     mad (16|M0)              acc2.0<1>:f   r1.2<0;0>:f       r4.0<1;0>:f       -r39.0<1>:f      {I@1}
(W)     mad (16|M0)              r10.0<1>:f    r32.0<1;0>:f      acc0.0<1;0>:f     -r39.0<1>:f     
(W)     mad (16|M0)              acc2.0<1>:f   r4.0<1;0>:f       acc2.0<1;0>:f     r4.0<1>:f        {Compacted}
(W)     mov (1|M0)               f0.0<1>:uw    r82.14<0;1,0>:uw                
(W)     mad (16|M0)              acc0.0<1>:f   acc0.0<1;0>:f     acc2.0<1;0>:f     r10.0<1>:f       {F@2}
(W)     mad (16|M0)              r32.0<1>:f    r32.0<1;0>:f      acc0.0<1;0>:f     -r39.0<1>:f     
(W&~f0.0) mad (16|M0)            r73.0<1>:f    acc0.0<1;0>:f     acc2.0<1;0>:f     r32.0<1>:f       {F@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        ret (16|M0)                          r83.6                            {A@1}
L6944:
(W)     mov (1|M0)               r1.2<1>:d     cr0.0<0;1,0>:ud                  {A@1}
(W)     and (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   -1265:w               {A@1}
(W)     or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   1264:w               {A@1}
(W)     mad (16|M0)              r79.0<1>:f    r77.0<1;0>:f      r75.0<1;0>:f      r79.0<1>:f       {Compacted,A@1}
(W)     mov (1|M0)               cr0.0<1>:ud   r1.2<0;1,0>:d                    {A@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        ret (16|M0)                          r84.2                            {A@1}
L7064:
        shr (1|M0)               r31.6<1>:ud   r83.5<0;1,0>:ud   0x17:uw             
        shr (1|M0)               r24.5<1>:ud   r83.4<0;1,0>:ud   0x17:uw             
        and (1|M0)               r31.6<1>:ud   r31.6<0;1,0>:ud   0xFF:uw              {I@2}
        and (1|M0)               r24.5<1>:ud   r24.5<0;1,0>:ud   0xFF:uw              {I@2}
        add (1|M0)               r1.3<1>:ud    r31.6<0;1,0>:ud   0xFFFFFF41:ud              {I@2}
        add (1|M0)               r1.2<1>:ud    r24.5<0;1,0>:ud   0xFFFFFF41:ud              {I@2}
        cmp (1|M0)    (lt)f1.1   null<1>:ud    r1.3<0;1,0>:ud    0xFFFFFF81:ud              {I@2}
(W)     mov (1|M0)               r2.6<1>:hf    -qnan(0x1FF):hf                             
(~f1.1) cmp (1|M0)    (lt)f1.1   null<1>:ud    r1.2<0;1,0>:ud    0xFFFFFF82:ud              {I@2}
(f1.1)  sel (1|M0)               r16.28<2>:b   r2.6<0;1,0>:w     0:w               {F@1}
        cmp (1|M0)    (ne)f0.1   null<1>:uw    r16.28<0;1,0>:ub  0x0:uw              {I@1}
(W)     and (1|M0)               f0.1<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(~f0.1.any16h) goto (16|M0)                  L10752                  L10752                
L7272:
        add (1|M0)               r1.3<1>:ud    r31.6<0;1,0>:ud   0xFFFFFF01:ud             
        add (1|M0)               r1.2<1>:ud    r24.5<0;1,0>:ud   0xFFFFFF01:ud             
        cmp (1|M0)    (lt)f1.0   null<1>:ud    r1.3<0;1,0>:ud    0xFFFFFF02:ud              {I@2}
(W)     mov (1|M0)               r2.6<1>:hf    -qnan(0x1FF):hf                             
        mov (1|M0)               r82.2<1>:f    (abs)r83.4<0;1,0>:f             
(~f1.0) cmp (1|M0)    (lt)f1.0   null<1>:ud    r1.2<0;1,0>:ud    0xFFFFFF02:ud              {I@2}
(f1.0)  sel (1|M0)               r31.28<2>:b   r2.6<0;1,0>:w     0:w               {F@2}
        cmp (1|M0)    (ne)f1.0   null<1>:uw    r31.28<0;1,0>:ub  0x0:uw              {I@1}
(W)     and (1|M0)               f1.1<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
(f1.1.any16h) goto (16|M0)                   L7528                  L7528                
L7432:
        mov (1|M0)               r1.2<1>:f     (abs)r83.5<0;1,0>:f             
        mov (1|M0)               r81.18<2>:b   0:w                              
        add (1|M0)               r82.2<1>:d    r82.2<0;1,0>:d    -r1.2<0;1,0>:d   {A@1}
        mov (2|M0)               r83.0<1>:d    r83.4<1;1,0>:ud                 
        asr (1|M0)               r82.2<1>:d    r82.2<0;1,0>:d    23:w               {I@2}
        goto (16|M0)                         L7528                  L9216                
L7528:
        join (16|M0)                         L9216                                
L7544:
        cmp (1|M0)    (gt)f0.1   null<1>:ud    r82.2<0;1,0>:ud   0x7F800000:ud              {I@3}
(W)     mov (1|M0)               r1.3<1>:hf    0xFF:hf                             
        mov (1|M0)               r82.0<1>:f    (abs)r83.5<0;1,0>:f              {Compacted}
(W)     mov (1|M0)               r2.7<1>:hf    -qnan(0x1FF):hf                             
(f0.1)  sel (1|M0)               r2.6<1>:w     r1.3<0;1,0>:w     0:w               {F@3}
        add (1|M0)               r24.0<1>:f    r83.4<0;1,0>:f    r83.5<0;1,0>:f  
        cmp (1|M0)    (eq)f0.1   null<1>:w     r2.12<0;1,0>:b    0:w               {I@1}
(W)     mov (1|M0)               r3.10<1>:uw   r2.12<0;1,0>:ub                 
        and (1|M0)               r81.1<1>:ud   r83.4<0;1,0>:ud   0x7F800000:ud             
(W)     mov (1|M0)               r5.0<1>:f     -0.0:f                               {Compacted}
(f0.1)  cmp (1|M0)    (gt)f0.1   null<1>:ud    r82.0<0;1,0>:ud   0x7F800000:ud              {F@4}
        bfn.0x6A (1|M0)          r1.2<1>:ud    r83.4<0;0>:ud     r83.5<0;0>:ud     r5.0<0>:ud       {F@1} // s0^s1&s2
        bfn.0x6A (1|M0)          r1.3<1>:ud    r83.5<0;0>:ud     r83.4<0;0>:ud     r5.0<0>:ud       // s0^s1&s2
        and (1|M0)               r81.2<1>:ud   r83.5<0;1,0>:ud   0x7F800000:ud             
(f0.1)  sel (1|M0)               r2.16<2>:b    r2.7<0;1,0>:w     0:w              
        and (1|M0)               r4.0<1>:ud    r83.5<0;1,0>:ud   0x80000000:ud             
        and (1|M0)    (ne)f1.1   null<1>:w     r2.16<0;1,0>:ub   1:w               {I@2}
        and (1|M0)               r81.0<1>:ud   r83.4<0;1,0>:ud   0x80000000:ud             
(f1.1)  add (1|M0)               r24.0<1>:f    r83.5<0;1,0>:f    r83.5<0;1,0>:f  
        or (1|M0)     (eq)f1.1   r2.16<2>:ub   r2.16<0;1,0>:ub   r3.10<0;1,0>:uw  {F@1}
(f1.1)  cmp (1|M0)    (eq)f1.1   null<1>:d     r81.1<0;1,0>:d    2139095040:d              
(W)     mov (1|M0)               r4.2<1>:uw    r2.16<0;1,0>:ub                  {I@2}
(f1.1)  sel (1|M0)               r1.6<2>:b     r2.7<0;1,0>:w     0:w              
        and (1|M0)    (ne)f1.0   null<1>:w     r1.6<0;1,0>:ub    1:w               {I@1}
(f1.0)  add (1|M0)               r24.0<1>:f    r1.2<0;1,0>:f     -r1.3<0;1,0>:f  
        or (1|M0)     (eq)f1.0   r1.6<2>:ub    r1.6<0;1,0>:ub    r4.2<0;1,0>:uw   {F@1}
(f1.0)  cmp (1|M0)    (eq)f1.0   null<1>:d     r81.2<0;1,0>:d    2139095040:d              
(W)     mov (1|M0)               r3.10<1>:uw   r1.6<0;1,0>:ub                   {I@2}
(f1.0)  sel (1|M0)               r81.14<2>:b   r2.7<0;1,0>:w     0:w              
        and (1|M0)    (ne)f0.1   null<1>:w     r81.14<0;1,0>:ub  1:w               {I@1}
(f0.1)  mul (1|M0)               r24.0<1>:f    r4.0<0;1,0>:f     r83.4<0;1,0>:f  
        or (1|M0)     (eq)f0.1   r81.14<2>:ub  r81.14<0;1,0>:ub  r3.10<0;1,0>:uw  {F@1}
(f0.1)  cmp (1|M0)    (eq)f0.1   null<1>:f     r83.5<0;1,0>:f    0.0:f               {I@1}
(f0.1)  sel (1|M0)               r81.12<2>:b   r2.7<0;1,0>:w     0:w              
        cmp (1|M0)    (ne)f1.1   null<1>:uw    r81.12<0;1,0>:ub  0x0:uw              {I@1}
(W)     and (1|M0)               f1.0<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(f1.0.any16h) goto (16|M0)                   L8152                  L8152                
L8120:
        mov (1|M0)               r81.16<2>:b   r81.14<0;1,0>:b                 
        goto (16|M0)                         L8152                  L8336                
L8152:
        join (16|M0)                         L8336                                
L8168:
(W)     mov (1|M0)               r4.0<1>:f     inf:f                               {Compacted}
        cmp (1|M0)    (eq)f0.1   null<1>:f     r83.4<0;1,0>:f    0.0:f              
        bfn.0x96 (1|M0)          r81.0<1>:ud   r81.0<0;0>:ud     r83.5<0;0>:ud     r4.0<0>:ud       {F@2} // s0^s1^s2
        xor (1|M0)               r1.2<1>:ud    r83.5<0;1,0>:ud   0x7F800000:ud             
        and (1|M0)    (ne)f1.0   null<1>:w     r81.12<0;1,0>:ub  1:w              
(W)     mov (1|M0)               r2.6<1>:uw    r81.14<0;1,0>:ub                
(~f0.1) mov (1|M0)               r1.2<1>:f     r81.0<0;1,0>:f                   {A@3}
        or (1|M0)                r81.14<2>:ub  r81.12<0;1,0>:ub  r2.6<0;1,0>:uw   {I@1}
(f0.1)  mul (1|M0)               r81.0<1>:f    r1.2<0;1,0>:f     r83.4<0;1,0>:f   {F@1}
        mov (1|M0)               r81.16<2>:b   r81.14<0;1,0>:b                  {I@1}
(f1.0)  mov (1|M0)               r24.0<1>:f    r81.0<0;1,0>:f                   {F@1}
L8336:
        join (16|M0)                         L9216                                
L8352:
        cmp (1|M0)    (eq)f1.1   null<1>:w     r81.14<0;1,0>:b   0:w              
(W)     mov (1|M0)               r1.3<1>:hf    -qnan(0x1FF):hf                             
(W)     mov (1|M0)               r2.6<1>:uw    r81.16<0;1,0>:ub                 {I@3}
(f1.1)  cmp (1|M0)    (eq)f1.1   null<1>:f     r83.4<0;1,0>:f    0.0:f               {I@2}
(f1.1)  sel (1|M0)               r81.18<2>:b   r1.3<0;1,0>:w     0:w               {F@2}
        and (1|M0)    (ne)f0.1   null<1>:w     r81.18<0;1,0>:ub  1:w               {I@1}
        or (1|M0)     (ne)f1.1   r81.18<2>:ub  r81.18<0;1,0>:ub  r2.6<0;1,0>:uw   {F@1}
(f0.1)  mul (1|M0)               r24.0<1>:f    r83.4<0;1,0>:f    r83.5<0;1,0>:f  
(W)     and (1|M0)               f0.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw              {F@1}
(f0.1.any16h) goto (16|M0)                   L9216                  L10752                
L8512:
        cmp (1|M0)    (eq)f1.0   null<1>:uw    r81.18<0;1,0>:ub  0x0:uw              {I@3}
        cmp (1|M0)    (eq)f0.1   null<1>:d     r81.1<0;1,0>:d    0:w              
(~f1.0) mov (1|M0)               r31.28<2>:b   0:w                              
(f0.1)  sel (1|M0)               r81.5<1>:d    r31.28<0;1,0>:b   0:w               {I@1}
        cmp (1|M0)    (ne)f1.1   null<1>:d     r81.5<0;1,0>:d    0:w               {I@1}
(W)     and (1|M0)               f1.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(f1.1.any16h) goto (16|M0)                   L8664                  L8664                
L8624:
        mov (1|M0)               r81.6<1>:d    0:w                              
        mov (1|M0)               r83.0<1>:f    r83.4<0;1,0>:f                   {Compacted}
        goto (16|M0)                         L8664                  L8816                
L8664:
        join (16|M0)                         L8816                                
L8680:
        and (1|M0)    (ne)f1.0   r81.5<1>:d    r81.5<0;1,0>:d    1:w              
        mov (1|M0)               r83.0<1>:f    r83.4<0;1,0>:f                   {Compacted}
(W)     mov (1|M0)               r2.6<1>:hf    -qnan(0x1E0):hf                             
(f1.0)  mul (1|M0)               r83.0<1>:f    r83.4<0;1,0>:f    0x4F800000:f              
(f1.0)  sel (1|M0)               r81.6<1>:d    r2.6<0;1,0>:w     0:w               {F@2}
        shr (1|M0)               r1.2<1>:ud    r83.0<0;1,0>:ud   0x17:uw              {F@1}
        and (1|M0)               r1.2<1>:ud    r1.2<0;1,0>:ud    0xFF:uw              {I@1}
        add (1|M0)               r1.2<1>:ud    r1.2<0;1,0>:ud    0xFFFFFFE0:ud              {I@1}
(f1.0)  mov (1|M0)               r24.5<1>:d    r1.2<0;1,0>:d                    {I@1}
L8816:
        join (16|M0)                         L9216                                
L8832:
        cmp (1|M0)    (eq)f1.0   null<1>:d     r81.2<0;1,0>:d    0:w              
(f1.0)  sel (1|M0)               r81.7<1>:d    r31.28<0;1,0>:b   0:w              
        cmp (1|M0)    (ne)f0.1   null<1>:d     r81.7<0;1,0>:d    0:w               {I@1}
(W)     and (1|M0)               f1.0<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(f1.0.any16h) goto (16|M0)                   L8960                  L8960                
L8912:
        mov (1|M0)               r82.1<1>:d    0:w                              
        mov (1|M0)               r83.1<1>:d    r83.5<0;1,0>:ud                 
        goto (16|M0)                         L8960                  L9128                
L8960:
        join (16|M0)                         L9128                                
L8976:
        and (1|M0)    (ne)f0.1   r81.7<1>:d    r81.7<0;1,0>:d    1:w              
        mov (1|M0)               r83.1<1>:f    r83.5<0;1,0>:f                   {I@4}
(W)     mov (1|M0)               r2.6<1>:hf    0x20:hf                             
(f0.1)  mul (1|M0)               r83.1<1>:f    r83.5<0;1,0>:f    0x4F800000:f              
(f0.1)  sel (1|M0)               r82.1<1>:d    r2.6<0;1,0>:w     0:w               {F@2}
        shr (1|M0)               r1.2<1>:ud    r83.1<0;1,0>:ud   0x17:uw              {F@1}
        mov (1|M0)               r82.0<1>:f    (abs)r83.1<0;1,0>:f              {Compacted}
        and (1|M0)               r1.2<1>:ud    r1.2<0;1,0>:ud    0xFF:uw              {I@1}
        add (1|M0)               r1.2<1>:ud    r1.2<0;1,0>:ud    0xFFFFFFE0:ud              {I@1}
(f0.1)  mov (1|M0)               r31.6<1>:d    r1.2<0;1,0>:d                    {I@1}
L9128:
        join (16|M0)                         L9216                                
L9144:
        mov (1|M0)               r82.2<1>:f    (abs)r83.0<0;1,0>:f              {Compacted}
        add (1|M0)               r82.1<1>:d    r82.1<0;1,0>:d    r81.6<0;1,0>:d  
        add (1|M0)               r82.2<1>:d    r82.2<0;1,0>:d    -r82.0<0;1,0>:d  {F@1}
        asr (1|M0)               r82.2<1>:d    r82.2<0;1,0>:d    23:w               {I@1}
        add (1|M0)               r82.1<1>:d    r82.1<0;1,0>:d    r82.2<0;1,0>:d   {I@1}
L9216:
        join (16|M0)                         L10752                                
L9232:
        cmp (1|M0)    (eq)f1.1   null<1>:uw    r31.28<0;1,0>:ub  0x0:uw             
(W)     mov (1|M0)               r1.2<1>:f     1.0:f                               {Compacted}
(W)     mov (1|M0)               r4.0<1>:f     0x807FFFFF:f                              
        cmp (1|M0)    (eq)f1.0   null<1>:w     r81.18<0;1,0>:b   0:w              
(~f1.1) mov (1|M0)               r82.2<1>:d    r82.1<0;1,0>:d                   {I@4}
        bfn.0xEA (1|M0)          r83.1<1>:ud   r1.2<0;0>:ud      r83.1<0;0>:ud     r4.0<0>:ud       {A@1} // s0|s1&s2
        add (1|M0)               r82.3<1>:d    r82.2<0;1,0>:d    126:w               {I@2}
        add (1|M0)               r82.4<1>:d    -r82.2<0;1,0>:d   -152:w              
        sync.nop                             null                             {Compacted,I@3}
        math.inv (1|M0)          r2.3<1>:f     r83.1<0;1,0>:f                   {$10}
        and (1|M0)               r82.4<1>:d    r82.4<0;1,0>:d    r82.3<0;1,0>:d   {I@1}
        mov (1|M0)               r85.0<1>:f    1.0:f                               {Compacted}
        asr (1|M0)               r82.4<1>:d    r82.4<0;1,0>:d    31:w               {I@1}
(~f1.0) mov (1|M0)               r82.4<1>:d    0:w                              
        bfn.0xEA (1|M0)          r83.0<1>:ud   r1.2<0;0>:ud      r83.0<0;0>:ud     r4.0<0>:ud       // s0|s1&s2
        cmp (1|M0)    (ne)f0.1   null<1>:d     r82.4<0;1,0>:d    0:w               {I@2}
        sync.nop                             null                             {Compacted,$10.dst}
        mad (1|M0)               r85.0<1>:f    r85.0<0;0>:f      r2.3<0;0>:f       -r83.1<0>:f      {F@1}
        mul (1|M0)               r2.4<1>:f     r2.3<0;1,0>:f     r83.0<0;1,0>:f   {I@2}
        mad (1|M0)               r85.0<1>:f    r2.3<0;0>:f       r2.3<0;0>:f       r85.0<0>:f       {F@2}
        mad (1|M0)               r85.1<1>:f    r83.0<0;0>:f      r2.4<0;0>:f       -r83.1<0>:f      {F@2}
(W)     and (1|M0)               f0.1<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
        mad (1|M0)               r85.1<1>:f    r2.4<0;0>:f       r85.0<0;0>:f      r85.1<0>:f       {F@1}
        add (1|M0)               r24.5<1>:d    r24.5<0;1,0>:d    -r31.6<0;1,0>:d 
        mad (1|M0)               r83.0<1>:f    r83.0<0;0>:f      r85.1<0;0>:f      -r83.1<0>:f      {F@1}
(~f0.1.any16h) goto (16|M0)                  L10400                  L10400                
L9616:
        mov (1|M0)               r82.6<1>:f    r83.0<0;1,0>:f                   {Compacted,F@1}
        mov (2|M0)               r84.0<1>:f    r85.0<1;1,0>:f                  
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r84.4         L10984                                 {A@1}
L9688:
        cmp (1|M0)    (eq)f1.0   null<1>:f     r83.0<0;1,0>:f    0.0:f              
(W)     mov (1|M0)               r1.3<1>:hf    0x1:hf                             
        add (1|M0)               r82.2<1>:d    r82.2<0;1,0>:d    125:w              
(W)     mov (1|M0)               r3.10<1>:hf   0x1:hf                             
(f1.0)  sel (1|M0)               r2.6<1>:w     r1.3<0;1,0>:w     0:w               {F@2}
        cmp (1|M0)    (lt)f1.1   null<1>:d     r82.2<0;1,0>:d    -2:w               {I@2}
        cmp (1|M0)    (ne)f0.1   null<1>:w     r2.6<0;1,0>:w     0:w               {I@2}
(W)     mov (1|M0)               r5.0<1>:hf    -qnan(0x1FF):hf                             
(f1.1)  sel (1|M0)               r3.11<1>:uw   r3.10<0;1,0>:uw   0x0:uw              {F@2}
(f0.1)  sel (1|M0)               r4.0<1>:uw    r3.10<0;1,0>:uw   0x0:uw             
        or (1|M0)     (ne)f1.1   null<1>:uw    r3.11<0;1,0>:uw   r4.0<0;1,0>:uw   {I@1}
(f1.1)  sel (1|M0)               r82.20<2>:b   r5.0<0;1,0>:w     0:w               {F@1}
        cmp (1|M0)    (ne)f1.1   null<1>:uw    r82.20<0;1,0>:ub  0x0:uw              {I@1}
(W)     and (1|M0)               f1.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(~f1.1.any16h) goto (16|M0)                  L10040                  L10040                
L9928:
(W)     mov (1|M0)               r1.3<1>:hf    0x1:hf                             
        and (1|M0)               r1.2<1>:d     r82.6<0;1,0>:d    -2139095041:d              
(W)     mov (1|M0)               r4.0<1>:f     0x800000:f                               {Compacted}
        shl (1|M0)               r82.3<1>:d    r82.3<0;1,0>:d    23:w               {Compacted}
(f1.0)  sel (1|M0)               r2.3<1>:d     r1.3<0;1,0>:w     0:w               {F@2}
        add (1|M0)               r82.3<1>:d    r82.3<0;1,0>:d    1065353216:d               {I@2}
        bfn.0xFE (1|M0)          r1.2<1>:ud    r1.2<0;0>:ud      r2.3<0;0>:ud      r4.0<0>:ud       {A@1} // s0|s1|s2
        mul (1|M0)               r82.3<1>:f    r82.3<0;1,0>:f    r1.2<0;1,0>:f    {A@1}
L10040:
        join (16|M0)                         L10400                                
L10056:
        and (1|M0)               r1.2<1>:d     r82.6<0;1,0>:d    -2147483648:d               {F@1}
        shl (1|M0)               r82.6<1>:d    r82.6<0;1,0>:d    1:w              
(W)     mov (1|M0)               r1.3<1>:hf    0x1:hf                             
        and (1|M0)               r1.3<1>:d     r82.6<0;1,0>:d    8388606:d               {I@1}
        and (1|M0)    (eq)f1.1   r82.6<1>:d    r82.6<0;1,0>:d    8388608:d              
(W)     mov (1|M0)               r2.5<1>:f     1.469368e-38:f                               {Compacted}
(f0.1)  sel (1|M0)               r2.3<1>:d     r1.3<0;1,0>:w     0:w               {F@2}
(W)     mov (1|M0)               r4.0<1>:f     0x800000:f                               {Compacted}
        or (1|M0)                r2.3<1>:d     r1.2<0;1,0>:d     r2.3<0;1,0>:d    {I@1}
(f1.1)  sel (1|M0)               r3.5<1>:d     r2.5<0;1,0>:d     12582912:d               {F@2}
        mov (1|M0)               r5.0<1>:f     0.25:f                               {Compacted}
        bfn.0xFE (1|M0)          r2.3<1>:ud    r4.0<0;0>:ud      r2.3<0;0>:ud      r1.3<0>:ud       {A@2} // s0|s1|s2
        or (1|M0)                r3.5<1>:d     r3.5<0;1,0>:d     r1.2<0;1,0>:d    {I@2}
        or (1|M0)                r2.4<1>:d     r1.2<0;1,0>:d     8388608:d              
        mad (1|M0)               r2.3<1>:f     r3.5<0;0>:f       r5.0<0;0>:f       r2.3<0>:f        {A@1}
        cmp (1|M0)    (eq)f1.1   null<1>:uw    r82.20<0;1,0>:ub  0x0:uw             
        add (1|M0)               r2.3<1>:f     r2.3<0;1,0>:f     -r2.4<0;1,0>:f   {A@1}
        mul (1|M0)               r2.4<1>:f     r2.4<0;1,0>:f     r2.4<0;1,0>:f   
        and (1|M0)    (ne)f1.0   null<1>:d     r82.4<0;1,0>:d    1:w              
        and (1|M0)               r2.4<1>:d     r2.4<0;1,0>:d     -2:w               {F@1}
        or (1|M0)                r2.4<1>:d     r2.4<0;1,0>:d     r2.3<0;1,0>:d    {I@1}
(~f1.1) mov (1|M0)               r2.4<1>:f     r82.3<0;1,0>:f                   {I@1}
(f1.0)  mov (1|M0)               r24.0<1>:f    r2.4<0;1,0>:f                    {F@1}
L10400:
        join (16|M0)                         L10752                                
L10416:
        add (1|M0)               r2.3<1>:d     r24.5<0;1,0>:d    126:w              
(W)     mov (1|M0)               r1.3<1>:uw    r82.16<0;1,0>:ub                
        cmp (1|M0)    (gt)f1.0   null<1>:ud    r2.3<0;1,0>:ud    0x17A:uw              {A@1}
        mad (1|M0)               r83.0<1>:f    r85.1<0;0>:f      r85.0<0;0>:f      r83.0<0>:f      
        or (1|M0)                r82.11<1>:w   r81.18<0;1,0>:ub  r1.3<0;1,0>:uw   {I@2}
(W)     and (1|M0)               f0.1<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
(~f0.1.any16h) goto (16|M0)                  L10608                  L10608                
L10528:
(f1.0)  sel (1|M0)               r1.2<1>:d     r24.5<0;1,0>:d    0:w              
        asr (1|M0)               r1.2<1>:d     r1.2<0;1,0>:d     11:w               {I@1}
        add (1|M0)               r1.3<1>:d     r1.2<0;1,0>:d     248:w               {I@1}
        xor (1|M0)               r1.3<1>:d     r1.3<0;1,0>:d     r1.2<0;1,0>:d    {I@1}
(f1.0)  mov (1|M0)               r24.5<1>:d    r1.3<0;1,0>:d                    {I@1}
L10608:
        join (16|M0)                         L10752                                
L10624:
        asr (1|M0)               r1.2<1>:d     r24.5<0;1,0>:d    1:w               {I@2}
        cmp (1|M0)    (eq)f0.1   null<1>:w     r82.11<0;1,0>:w   0:w              
        add (1|M0)               r24.5<1>:d    r24.5<0;1,0>:d    -r1.2<0;1,0>:d   {I@2}
        shl (1|M0)               r1.2<1>:d     r1.2<0;1,0>:d     23:w              
        shl (1|M0)               r24.5<1>:d    r24.5<0;1,0>:d    23:w               {I@2}
        add (1|M0)               r1.2<1>:d     r1.2<0;1,0>:d     r83.0<0;1,0>:d   {A@1}
        add (1|M0)               r24.5<1>:d    r24.5<0;1,0>:d    1065353216:d               {I@2}
(f0.1)  mul (1|M0)               r24.0<1>:f    r24.5<0;1,0>:f    r1.2<0;1,0>:f    {I@1}
L10752:
        join (16|M0)                         L10768                                
L10768:
        sync.nop                             null                             {Compacted,F@1}
        math.inv (1|M0)          r1.2<1>:f     r83.5<0;1,0>:f                   {$11}
        mov (1|M0)               r1.4<1>:ud    0x3F800000:ud                             
        mul (1|M0)               r1.3<1>:f     r1.2<0;1,0>:f     r83.4<0;1,0>:f   {$11.dst}
        mad (1|M0)               r1.4<1>:f     r1.4<0;0>:f       r1.2<0;0>:f       -r83.5<0>:f      {I@1}
        mad (1|M0)               r2.3<1>:f     r83.4<0;0>:f      r1.3<0;0>:f       -r83.5<0>:f      {F@2}
        mad (1|M0)               r1.4<1>:f     r1.2<0;0>:f       r1.2<0;0>:f       r1.4<0>:f        {F@2}
        cmp (1|M0)    (eq)f1.1   null<1>:uw    r16.28<0;1,0>:ub  0x0:uw             
        mad (1|M0)               r2.3<1>:f     r1.3<0;0>:f       r1.4<0;0>:f       r2.3<0>:f        {F@1}
        mad (1|M0)               r83.4<1>:f    r83.4<0;0>:f      r2.3<0;0>:f       -r83.5<0>:f      {F@1}
(f1.1)  mad (1|M0)               r24.0<1>:f    r2.3<0;0>:f       r1.4<0;0>:f       r83.4<0>:f       {F@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        ret (16|M0)                          r83.2                            {A@1}
L10984:
        mov (1|M0)               r1.2<1>:d     cr0.0<0;1,0>:ud                  {A@1}
        and (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   -1265:w               {A@1}
        or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   1264:w               {A@1}
        mad (1|M0)               r82.6<1>:f    r84.1<0;0>:f      r84.0<0;0>:f      r82.6<0>:f       {A@1}
        mov (1|M0)               cr0.0<1>:ud   r1.2<0;1,0>:d                    {A@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        ret (16|M0)                          r84.4                            {A@1}
L11112:
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
