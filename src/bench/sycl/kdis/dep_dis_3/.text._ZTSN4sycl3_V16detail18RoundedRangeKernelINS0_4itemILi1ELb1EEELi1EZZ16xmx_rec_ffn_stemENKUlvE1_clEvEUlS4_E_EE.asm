L0:
(W)     mov (8|M0)               r127.0<1>:ud  0x0:ud                             
(W)     and (1|M0)               r127.2<1>:ud  r0.0<0;1,0>:ud    0xFFFFFFC0:ud             
(W)     and (1|M0)               r127.0<1>:uw  r0.4<0;1,0>:uw    0xFF:uw             
(W)     add (1|M0)               r127.2<1>:ud  r127.2<0;1,0>:ud  0x40:ud              {I@2}
(W)     add (1|M0)               r127.2<1>:ud  r127.2<0;1,0>:ud  0x0:ud              {I@1}
(W)     mad (1|M0)               r127.2<1>:ud  r127.2<0;0>:ud    r127.0<0;0>:uw    0x60:uw              {I@1}
(W)     mov (8|M0)               r4.0<1>:ud    r1.0<1;1,0>:ud                  
(W)     send.dc0 (8|M0)          r1       r127    null:0  0x0            0x022843FD           {A@1,$0} // wr:1h+0, rd:2; oword aligned block read x4
(W)     add (1|M0)               r127.2<1>:ud  r127.2<0;1,0>:ud  0x40:uw              {$0.src}
(W)     send.dc0 (8|M0)          r3       r127    null:0  0x0            0x021842FD           {A@1,$1} // wr:1h+0, rd:1; oword aligned block read x2
        nop                    
        nop                    
(W)     mov (8|M0)               r127.0<1>:ud  0x0:ud                              {$1.src}
(W)     and (1|M0)               r127.2<1>:ud  r0.0<0;1,0>:ud    0xFFFFFFC0:ud             
(W)     add (1|M0)               r127.2<1>:ud  r127.2<0;1,0>:ud  0x0:ud              {I@1}
(W)     send.dc0 (8|M0)          r5       r127    null:0  0x0            0x022843FD           {A@1,$2} // wr:1h+0, rd:2; oword aligned block read x4
(W)     mov (8|M0)               r36.0<1>:ud   r0.0<1;1,0>:ud                  
(W)     or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x4C0:uw              {A@1}
(W)     mul (1|M0)               acc0.0<1>:ud  r4.3<0;1,0>:ud    r36.2<0;1,0>:uw  {A@1}
(W)     mach (1|M0)              r3.0<1>:ud    r4.3<0;1,0>:ud    r36.1<0;1,0>:ud  {AccWrEn,$1.dst}
        mov (16|M0)              r8.0<1>:d     r1.0<1;1,0>:uw                   {$0.dst}
(W)     mov (1|M0)               r2.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (8|M0)              r10.0<1>:ud   r2.0<0;1,0>:ud    r8.0<1;1,0>:ud   {AccWrEn,Compacted,I@1}
        add (8|M0)               r12.0<1>:ud   acc0.0<1;1,0>:ud  r3.0<0;1,0>:ud  
        addc (8|M8)              r11.0<1>:ud   r2.0<0;1,0>:ud    r9.0<1;1,0>:ud   {AccWrEn}
        add (8|M8)               r13.0<1>:ud   acc0.0<1;1,0>:ud  r3.0<0;1,0>:ud  
        addc (8|M0)              r26.0<1>:ud   r10.0<1;1,0>:ud   r4.0<0;1,0>:ud   {AccWrEn,Compacted,I@4}
        add (8|M0)               r24.0<1>:ud   acc0.0<1;1,0>:ud  r12.0<1;1,0>:ud  {I@4}
        addc (8|M8)              r27.0<1>:ud   r11.0<1;1,0>:ud   r4.0<0;1,0>:ud   {AccWrEn,I@4}
        cmp (16|M0)   (lt)f1.0   null<1>:d     r26.0<1;1,0>:ud   r4.6<0;1,0>:ud   {I@1}
        add (8|M8)               r25.0<1>:ud   acc0.0<1;1,0>:ud  r13.0<1;1,0>:ud 
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r24.0<1;1,0>:d    r4.7<0;1,0>:d    {I@1}
(~f1.0) cmp (16|M0)   (lt)f1.0   null<1>:d     r24.0<1;1,0>:ud   r4.7<0;1,0>:ud  
(~f1.0) goto (16|M0)                         L13336                  L13336                
L520:
        mov (16|M0)              r30.0<1>:f    r26.0<1;1,0>:f                   {Compacted}
        mov (16|M0)              r28.0<1>:f    r24.0<1;1,0>:f                   {Compacted}
(W)     mov (2|M0)               r21.0<1>:d    r5.0<1;1,0>:d                    {$2.dst}
(W)     mov (2|M0)               r6.6<1>:d     r5.2<1;1,0>:d                   
(W)     mov (1|M0)               r6.5<1>:d     -2147483648:d                              
(W)     mov (1|M0)               r6.4<1>:d     2139095040:d                              
(W)     mov (1|M0)               r6.3<1>:d     -1:w                              
L616:
        shl (16|M0)              r2.0<1>:d     r30.0<1;1,0>:d    2:w               {Compacted,F@2}
        addc (8|M0)              r12.0<1>:ud   r2.0<1;1,0>:ud    r6.6<0;1,0>:ud   {AccWrEn,Compacted,I@1}
        shr (16|M0)              r8.0<1>:ud    r30.0<1;1,0>:ud   30:w              
        shl (16|M0)              r10.0<1>:d    r28.0<1;1,0>:d    2:w               {Compacted,F@1}
        mov (8|M0)               r14.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        addc (8|M8)              r13.0<1>:ud   r3.0<1;1,0>:ud    r6.6<0;1,0>:ud   {AccWrEn}
        or (16|M0)               r10.0<1>:d    r10.0<1;1,0>:d    r8.0<1;1,0>:d    {Compacted,I@3}
        mov (8|M8)               r20.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        add3 (8|M0)              r15.1<2>:ud   r14.0<1;0>:ud     r10.0<1;0>:ud     r6.7<0>:ud       {I@2}
        add3 (8|M8)              r17.1<2>:ud   r20.0<1;0>:ud     r11.0<1;0>:ud     r6.7<0>:ud       {I@2}
        mov (8|M0)               r15.0<2>:d    r12.0<1;1,0>:d                  
        mov (8|M8)               r17.0<2>:d    r13.0<1;1,0>:d                  
        send.ugm (16|M0)         r32      r15     null:0  0x0            0x08280580           {A@1,$3} // wr:4+0, rd:2; load.ugm.d32.a64.ca.ca
        and (16|M0)              r22.0<1>:d    r32.0<1;1,0>:d    2147483647:d               {$3.dst}
        sel (16|M0)   (lt)f0.0   r70.0<1>:f    r22.0<1;1,0>:f    448.0:f               {Compacted,I@1}
        shr (16|M0)              r66.0<1>:ud   r70.0<1;1,0>:ud   23:w               {F@1}
        and (16|M0)   (ne)f1.1   r100.0<1>:d   r70.0<1;1,0>:d    8388607:d              
        and (16|M0)              r90.0<1>:d    r66.0<1;1,0>:d    255:w               {Compacted,I@2}
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r90.0<1;1,0>:d    255:w               {I@1}
        sel (16|M0)   (ge)f0.0   r8.0<1>:ud    r90.0<1;1,0>:ud   0x79:uw             
        shl (16|M0)              r34.0<1>:d    r8.0<1;1,0>:d     23:w               {Compacted,I@1}
(~f1.1) goto (16|M0)                         L928                  L928                
L896:
        mov (16|M0)              r88.0<1>:ud   0x7FC00000:ud                             
        goto (16|M0)                         L928                  L6848                
L928:
        join (16|M0)                         L6848                                
L944:
        cmp (16|M0)   (eq)f1.0   null<1>:d     r100.0<1;1,0>:d   0:w              
        add (16|M0)              r52.0<1>:d    -r34.0<1;1,0>:d   -2139095040:d               {I@6}
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r90.0<1;1,0>:d    255:w              
        xor (16|M0)              r44.0<1>:d    r52.0<1;1,0>:d    r70.0<1;1,0>:d   {Compacted,I@2}
(f1.0)  goto (16|M0)                         L6816                  L6816                
L1016:
        or (16|M0)    (eq)f0.1   null<1>:d     r90.0<1;1,0>:d    r100.0<1;1,0>:d 
(~f0.1) goto (16|M0)                         L1080                  L1080                
L1048:
        mov (16|M0)              r88.0<1>:ud   0x0:ud                             
        goto (16|M0)                         L1080                  L6848                
L1080:
        join (16|M0)                         L6816                                
L1096:
        cmp (16|M0)   (eq)f0.1   null<1>:d     r90.0<1;1,0>:d    0:w              
        shr (16|M0)              r80.0<1>:ud   r52.0<1;1,0>:ud   23:w              
        add (16|M0)              r78.0<1>:d    r90.0<1;1,0>:d    -127:w               {Compacted}
(f0.1)  mov (16|M0)              r78.0<1>:d    -126:w                              
        add (16|M0)              r52.0<1>:d    r80.0<1;1,0>:d    r78.0<1;1,0>:d   {Compacted,I@1}
        cmp (16|M0)   (gt)f0.0   null<1>:d     r52.0<1;1,0>:d    254:w               {Compacted,I@1}
(f0.0)  goto (16|M0)                         L6752                  L6752                
L1184:
        or (16|M0)    (eq)f1.1   null<4>:b     r66.0<1;1,0>:d    r80.0<1;1,0>:d  
(f1.1)  goto (16|M0)                         L6688                  L6688                
L1216:
(W)     mov (1|M0)               r2.0<1>:hf    0.0:hf                             
(W)     mov (1|M0)               r21.6<1>:d    0:w                              
(f0.1)  sel (16|M0)              r8.0<1>:d     r2.0<0;1,0>:w     8388608:d               {F@1}
        or (16|M0)               r8.0<1>:d     r8.0<1;1,0>:d     r100.0<1;1,0>:d  {Compacted,I@1}
        shl (16|M0)              r48.0<1>:d    r8.0<1;1,0>:d     23:w               {Compacted,I@1}
        shr (16|M0)              r46.0<1>:ud   r8.0<1;1,0>:ud    9:w              
(W)     mov (1|M0)               r21.3<1>:f    -0.0:f                               {Compacted}
(W)     mov (2|M0)               r21.4<1>:d    0:w                              
L1320:
(W)     shl (1|M0)               r2.0<1>:d     r21.3<0;1,0>:d    31:w               {Compacted,F@1}
(W)     shr (1|M0)               r2.1<1>:ud    r21.6<0;1,0>:ud   1:w              
(W)     cmp (16|M0)   (gt)f1.1   null<1>:d     r21.4<0;1,0>:ud   0x3E:uw              {I@3}
(W)     or (1|M0)                r21.6<1>:d    r2.1<0;1,0>:d     r2.0<0;1,0>:d    {I@2}
        bfn.0xE0 (16|M0)         r8.0<1>:ud    r2.1<0;0>:ud      r2.0<0;0>:ud      r48.0<1>:ud      // (s0|s1)&s2
(W)     shr (1|M0)               r21.2<1>:ud   r21.3<0;1,0>:ud   1:w              
(W&f1.1) cmp (16|M0)  (eq)f1.1   null<1>:d     r21.5<0;1,0>:d    0:w              
        cmp (16|M0)   (eq)f0.1   null<1>:d     r8.0<1;1,0>:d     r21.6<0;1,0>:d   {I@3}
        and (16|M0)              r10.0<1>:d    r21.2<0;1,0>:d    r46.0<1;1,0>:d   {Compacted,I@3}
(W&~f1.1) cmp (16|M0) (gt)f1.1   null<1>:d     r21.5<0;1,0>:ud   0x0:uw             
(f0.1)  cmp (16|M0)   (eq)f0.1   null<1>:d     r10.0<1;1,0>:d    r21.2<0;1,0>:d   {I@2}
(W)     mov (1|M0)               r5.8<1>:hf    0x1:hf                             
(W)     addc (1|M0)              r13.0<1>:ud   r21.4<0;1,0>:ud   0x1:ud              {AccWrEn}
(f1.1)  sel (16|M0)              r7.0<1>:uw    r5.8<0;1,0>:uw    0x0:uw              {Compacted,F@1}
(f0.1)  sel (16|M0)              acc2.0<1>:uw  r5.8<0;1,0>:uw    0x0:uw             
(W)     mov (1|M0)               r3.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        or (16|M0)    (ne)f0.0   null<1>:uw    r7.0<1;1,0>:uw    acc2.0<1;1,0>:uw {I@3}
(W)     add (1|M0)               r21.7<1>:ud   r3.0<0;1,0>:ud    r21.5<0;1,0>:ud  {I@2}
        mov (16|M0)              r84.0<1>:d    r21.4<0;1,0>:d                  
        mov (16|M0)              r82.0<1>:d    r21.5<0;1,0>:d                  
        mov (16|M0)              r62.0<1>:f    r13.0<0;1,0>:f                   {Compacted}
        mov (16|M0)              r76.0<1>:d    r21.7<0;1,0>:d                   {I@3}
(f0.0)  goto (16|M0)                         L1712                  L1712                
L1648:
(W)     mov (1|M0)               r21.3<1>:d    r21.2<0;1,0>:d                  
(W)     mov (1|M0)               r21.4<1>:d    r13.0<0;1,0>:d                  
(W)     mov (1|M0)               r21.5<1>:d    r21.7<0;1,0>:d                  
(W)     jmpi                                 L1320                                
L1712:
        join (16|M0)                         L6688                                
L1728:
(W)     mov (1|M0)               r2.0<1>:f     8.68805e-44:f                              
(W)     mov (1|M0)               r3.0<1>:hf    0.0:hf                             
        subb (8|M0)              r56.0<1>:ud   r2.0<0;1,0>:ud    r84.0<1;1,0>:ud  {AccWrEn,Compacted,A@2}
        add3 (8|M0)              r86.0<1>:ud   -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r82.0<1>:ud     {A@1}
        subb (8|M8)              r57.0<1>:ud   r2.0<0;1,0>:ud    r85.0<1;1,0>:ud  {AccWrEn}
        add3 (16|M0)             r18.0<1>:d    r52.0<1;0>:d      r56.0<1;0>:d      -173:w               {I@1}
        cmp (16|M0)   (gt)f1.0   null<1>:d     r18.0<1;1,0>:d    127:w               {I@1}
        add3 (8|M8)              r87.0<1>:ud   -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r83.0<1>:ud    
        add3 (16|M0)             r80.0<1>:d    r80.0<1;0>:d      r78.0<1;0>:d      r56.0<1>:d      
(f1.0)  goto (16|M0)                         L6632                  L6632                
L1880:
        cmp (16|M0)   (gt)f0.1   null<1>:d     r18.0<1;1,0>:d    -127:w              
(f0.1)  goto (16|M0)                         L4328                  L4328                
L1912:
        cmp (16|M0)   (lt)f0.0   null<1>:d     r18.0<1;1,0>:ud   0xFFFFFF6B:ud             
(f0.0)  goto (16|M0)                         L3832                  L3832                
L1944:
(W)     mov (1|M0)               r2.0<1>:f     8.82818e-44:f                              
(W)     mov (1|M0)               r3.0<1>:hf    0.0:hf                              {I@7}
        subb (8|M0)              r98.0<1>:ud   r2.0<0;1,0>:ud    r84.0<1;1,0>:ud  {AccWrEn,Compacted,F@2}
        add3 (16|M0)             r122.0<1>:d   r52.0<1;0>:d      r56.0<1;0>:d      -23:w              
        add3 (8|M0)              r8.0<1>:ud    -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r82.0<1>:ud     {F@1}
        subb (8|M8)              r99.0<1>:ud   r2.0<0;1,0>:ud    r85.0<1;1,0>:ud  {AccWrEn}
        cmp (16|M0)   (gt)f0.1   null<1>:d     r98.0<1;1,0>:ud   r122.0<1;1,0>:ud {I@1}
        add3 (8|M8)              r9.0<1>:ud    -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r83.0<1>:ud    
(f0.1)  cmp (16|M0)   (eq)f0.1   null<1>:d     r8.0<1;1,0>:d     0:w               {I@1}
(~f0.1) cmp (16|M0)   (gt)f0.1   null<1>:d     r8.0<1;1,0>:ud    0x0:uw             
(f0.1)  goto (16|M0)                         L2168                  L2168                
L2112:
        add3 (16|M0)             r2.0<1>:d     r80.0<1;0>:d      -r98.0<1;0>:d     -23:w              
        shl (16|M0)              r50.0<1>:d    r48.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@1}
        mov (16|M0)              r48.0<1>:d    0:w                              
        goto (16|M0)                         L2168                  L3768                
L2168:
        join (16|M0)                         L3768                                
L2184:
        add3 (16|M0)             r38.0<1>:d    r98.0<1;0>:d      -r80.0<1;0>:d     23:w              
        cmp (16|M0)   (lt)f1.1   null<1>:d     r38.0<1;1,0>:d    2:w               {I@1}
(f1.1)  goto (16|M0)                         L2336                  L2336                
L2232:
        cmp (16|M0)   (eq)f1.0   null<1>:d     r38.0<1;1,0>:d    2:w              
(~f1.0) goto (16|M0)                         L2336                  L2384                
L2264:
        shr (16|M0)              r64.0<1>:ud   r48.0<1;1,0>:ud   1:w              
        mov (16|M0)              r120.0<1>:d   0:w                              
        mov (16|M0)              r14.0<1>:d    0:w                              
        mov (16|M0)              r116.0<1>:f   r64.0<1;1,0>:f                   {Compacted,I@3}
        goto (16|M0)                         L2336                  L3256                
L2336:
        join (16|M0)                         L2384                                
L2352:
        cmp (16|M0)   (eq)f0.1   null<1>:d     r38.0<1;1,0>:d    1:w              
(f0.1)  goto (16|M0)                         L2384                  L3200                
L2384:
        join (16|M0)                         L3200                                
L2400:
        add3 (16|M0)             r2.0<1>:d     r98.0<1;0>:d      -r122.0<1;0>:d    -1:w              
        and (16|M0)   (ne)f0.0   r114.0<1>:d   r2.0<1;1,0>:d     63:w               {Compacted,I@1}
(f0.0)  goto (16|M0)                         L2464                  L2464                
L2440:
        mov (16|M0)              r92.0<1>:f    r48.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L2464                  L2576                
L2464:
        join (16|M0)                         L2576                                
L2480:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r114.0<1;1,0>:ud  0x20:uw              {I@4}
(~f1.1) add (16|M0)              r2.0<1>:d     r114.0<1;1,0>:d   -32:w              
(~f1.1) shr (16|M0)              r64.0<1>:ud   r46.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.1)  add (16|M0)              r2.0<1>:d     -r114.0<1;1,0>:d  32:w               {Compacted}
(f1.1)  shr (16|M0)              r8.0<1>:ud    r48.0<1;1,0>:ud   r114.0<1;1,0>:d 
(f1.1)  shl (16|M0)              r2.0<1>:d     r46.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.1)  or (16|M0)               r64.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
        mov (16|M0)              r92.0<1>:f    r64.0<1;1,0>:f                   {Compacted,I@1}
L2576:
        join (16|M0)                         L3200                                
L2592:
        add3 (16|M0)             r70.0<1>:d    r98.0<1;0>:d      -r122.0<1;0>:d    -2:w              
        and (16|M0)   (ne)f1.0   r112.0<1>:d   r70.0<1;1,0>:d    63:w               {I@1}
(f1.0)  goto (16|M0)                         L2664                  L2664                
L2640:
        mov (16|M0)              r64.0<1>:f    r48.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L2664                  L2768                
L2664:
        join (16|M0)                         L2768                                
L2680:
        cmp (16|M0)   (lt)f0.1   null<1>:d     r112.0<1;1,0>:ud  0x20:uw              {I@4}
(~f0.1) add (16|M0)              r2.0<1>:d     r112.0<1;1,0>:d   -32:w              
(~f0.1) shr (16|M0)              r64.0<1>:ud   r46.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f0.1)  add (16|M0)              r2.0<1>:d     -r112.0<1;1,0>:d  32:w               {Compacted}
(f0.1)  shr (16|M0)              r8.0<1>:ud    r48.0<1;1,0>:ud   r112.0<1;1,0>:d 
(f0.1)  shl (16|M0)              r2.0<1>:d     r46.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f0.1)  or (16|M0)               r64.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
L2768:
        join (16|M0)                         L3200                                
L2784:
        and (16|M0)   (ne)f0.0   r86.0<1>:d    r70.0<1;1,0>:d    63:w               {Compacted}
        and (16|M0)              r14.0<1>:d    r64.0<1;1,0>:d    1:w               {Compacted,I@3}
(f0.0)  goto (16|M0)                         L2864                  L2864                
L2816:
        mov (16|M0)              r90.0<1>:d    -1:w                              
        mov (16|M0)              r94.0<1>:d    -1:w                              
        goto (16|M0)                         L2864                  L3048                
L2864:
        join (16|M0)                         L3048                                
L2880:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r86.0<1;1,0>:ud   0x20:uw              {I@7}
(f1.1)  goto (16|M0)                         L2984                  L2984                
L2912:
        add (16|M0)              r2.0<1>:d     r86.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r5.8<1>:hf    -qnan(0x1FF):hf                             
        mov (16|M0)              r90.0<1>:d    0:w                              
        shl (16|M0)              r94.0<1>:d    r5.8<0;1,0>:w     r2.0<1;1,0>:d    {A@1}
        goto (16|M0)                         L2984                  L3048                
L2984:
        join (16|M0)                         L3048                                
L3000:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (16|M0)              r94.0<1>:d    -1:w                              
        shl (16|M0)              r90.0<1>:d    r2.0<0;1,0>:w     r86.0<1;1,0>:d   {F@1}
L3048:
        join (16|M0)                         L3200                                
L3064:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r90.0<1;0>:ud     r6.3<0;0>:ud      r48.0<1>:ud      {I@2} // (s0^s1)&s2
        cmp (16|M0)   (ne)f0.1   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
        bfn.0x60 (16|M0)         r8.0<1>:ud    r94.0<1;0>:ud     r6.3<0;0>:ud      r46.0<1>:ud      // (s0^s1)&s2
(~f0.1) cmp (16|M0)   (ne)f0.1   null<1>:d     r8.0<1;1,0>:d     0:w               {I@1}
(W)     mov (1|M0)               r5.8<1>:hf    -qnan(0x1FF):hf                             
        mov (16|M0)              r116.0<1>:f   r92.0<1;1,0>:f                   {Compacted}
(f0.1)  sel (16|M0)              r10.0<1>:d    r5.8<0;1,0>:w     0:w               {F@2}
        mov (16|M0)              r120.0<1>:d   -r10.0<1;1,0>:d                  {I@1}
        goto (16|M0)                         L3200                  L3256                
L3200:
        join (16|M0)                         L3256                                
L3216:
        mov (16|M0)              r120.0<1>:d   0:w                              
        mov (16|M0)              r14.0<1>:d    0:w                              
        mov (16|M0)              r116.0<1>:f   r48.0<1;1,0>:f                   {Compacted}
L3256:
        join (16|M0)                         L3768                                
L3272:
        and (16|M0)   (ne)f1.0   r110.0<1>:d   r38.0<1;1,0>:d    63:w              
(f1.0)  goto (16|M0)                         L3328                  L3328                
L3304:
        mov (16|M0)              r64.0<1>:f    r48.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L3328                  L3432                
L3328:
        join (16|M0)                         L3432                                
L3344:
        cmp (16|M0)   (lt)f0.1   null<1>:d     r110.0<1;1,0>:ud  0x20:uw              {I@4}
(~f0.1) add (16|M0)              r2.0<1>:d     r110.0<1;1,0>:d   -32:w              
(~f0.1) shr (16|M0)              r64.0<1>:ud   r46.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f0.1)  add (16|M0)              r2.0<1>:d     -r110.0<1;1,0>:d  32:w               {Compacted}
(f0.1)  shr (16|M0)              r8.0<1>:ud    r48.0<1;1,0>:ud   r110.0<1;1,0>:d 
(f0.1)  shl (16|M0)              r2.0<1>:d     r46.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f0.1)  or (16|M0)               r64.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
L3432:
        join (16|M0)                         L3768                                
L3448:
        shl (16|M0)              r2.0<1>:d     r116.0<1;1,0>:d   2:w               {Compacted}
        shl (16|M0)              r8.0<1>:d     r14.0<1;1,0>:d    1:w               {Compacted}
        and (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     4:w               {Compacted,I@2}
        bfn.0xFE (16|M0)         r46.0<1>:ud   r2.0<1;0>:ud      r8.0<1;0>:ud      r120.0<1>:ud     {I@1} // s0|s1|s2
        cmp (16|M0)   (eq)f0.0   null<1>:d     r46.0<1;1,0>:d    0:w               {Compacted,I@1}
(~f0.0) goto (16|M0)                         L3544                  L3544                
L3512:
        mov (16|M0)              r50.0<1>:d    0:w                              
        goto (16|M0)                         L3544                  L3696                
L3544:
        join (16|M0)                         L3696                                
L3560:
        cmp (16|M0)   (gt)f1.1   null<1>:d     r46.0<1;1,0>:ud   0x4:uw             
(~f1.1) goto (16|M0)                         L3624                  L3624                
L3592:
        mov (16|M0)              r50.0<1>:d    1:w                              
        goto (16|M0)                         L3624                  L3696                
L3624:
        join (16|M0)                         L3696                                
L3640:
        and (16|M0)   (ne)f0.0   null<1>:d     r64.0<1;1,0>:d    1:w               {Compacted}
(W)     mov (1|M0)               r2.0<1>:hf    0x1:hf                             
(f0.0)  cmp (16|M0)   (eq)f0.0   null<1>:d     r46.0<1;1,0>:d    4:w              
(f0.0)  sel (16|M0)              r50.0<1>:d    r2.0<0;1,0>:w     0:w               {F@1}
L3696:
        join (16|M0)                         L3768                                
L3712:
        add (16|M0)              r2.0<1>:d     r50.0<1;1,0>:d    r64.0<1;1,0>:d   {Compacted,I@2}
        cmp (16|M0)   (gt)f0.1   null<1>:d     r2.0<1;1,0>:ud    0x7FFFFF:ud              {I@1}
(W)     mov (1|M0)               r5.4<1>:f     0x800000:f                               {Compacted}
(~f0.1) sel (16|M0)              r50.0<1>:d    r2.0<1;1,0>:d     0:w              
(f0.1)  sel (16|M0)              r48.0<1>:d    r5.4<0;1,0>:d     0:w               {Compacted,F@1}
L3768:
        join (16|M0)                         L3832                                
L3784:
        and (16|M0)              r2.0<1>:d     r44.0<1;1,0>:d    -2147483648:d              
        bfn.0xFE (16|M0)         r88.0<1>:ud   r2.0<1;0>:ud      r48.0<1;0>:ud     r50.0<1>:ud      {I@1} // s0|s1|s2
        goto (16|M0)                         L3832                  L6848                
L3832:
        join (16|M0)                         L4328                                
L3848:
        and (16|M0)   (ne)f1.0   r68.0<1>:d    r56.0<1;1,0>:d    63:w              
(f1.0)  goto (16|M0)                         L3928                  L3928                
L3880:
        mov (16|M0)              r80.0<1>:d    -1:w                              
        mov (16|M0)              r84.0<1>:d    -1:w                              
        goto (16|M0)                         L3928                  L4112                
L3928:
        join (16|M0)                         L4112                                
L3944:
        cmp (16|M0)   (lt)f0.1   null<1>:d     r68.0<1;1,0>:ud   0x20:uw              {I@6}
(f0.1)  goto (16|M0)                         L4048                  L4048                
L3976:
        add (16|M0)              r2.0<1>:d     r68.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r5.8<1>:hf    -qnan(0x1FF):hf                             
        mov (16|M0)              r80.0<1>:d    0:w                              
        shl (16|M0)              r84.0<1>:d    r5.8<0;1,0>:w     r2.0<1;1,0>:d    {A@1}
        goto (16|M0)                         L4048                  L4112                
L4048:
        join (16|M0)                         L4112                                
L4064:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (16|M0)              r84.0<1>:d    -1:w                              
        shl (16|M0)              r80.0<1>:d    r2.0<0;1,0>:w     r68.0<1;1,0>:d   {F@1}
L4112:
        join (16|M0)                         L4328                                
L4128:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r80.0<1;0>:ud     r6.3<0;0>:ud      r48.0<1>:ud      {I@2} // (s0^s1)&s2
        cmp (16|M0)   (ne)f0.1   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
        bfn.0x60 (16|M0)         r8.0<1>:ud    r84.0<1;0>:ud     r6.3<0;0>:ud      r46.0<1>:ud      // (s0^s1)&s2
        cmp (16|M0)   (gt)f0.0   null<1>:d     r44.0<1;1,0>:d    -1:w               {Compacted}
(~f0.1) cmp (16|M0)   (ne)f0.1   null<1>:d     r8.0<1;1,0>:d     0:w               {I@2}
(f0.1)  cmp (16|M0)   (eq)f0.1   null<1>:d     r18.0<1;1,0>:d    -150:w              
(f0.0)  goto (16|M0)                         L4272                  L4272                
L4232:
(W)     mov (1|M0)               r2.0<1>:ud    0x80000001:ud                             
(f0.1)  sel (16|M0)              r88.0<1>:f    r2.0<0;1,0>:f     -0.0:f               {Compacted,I@1}
        goto (16|M0)                         L4272                  L6848                
L4272:
        join (16|M0)                         L4328                                
L4288:
(W)     mov (1|M0)               r2.0<1>:ud    0x1:ud                              {F@1}
(f0.1)  sel (16|M0)              r88.0<1>:f    r2.0<0;1,0>:f     0.0:f               {Compacted,I@1}
        goto (16|M0)                         L4328                  L6848                
L4328:
        join (16|M0)                         L6632                                
L4344:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r56.0<1;1,0>:ud   0x18:uw             
        add3 (16|M0)             r58.0<1>:d    r52.0<1;0>:d      r56.0<1;0>:d      -46:w              
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r86.0<1;1,0>:d    0:w              
(f1.1)  goto (16|M0)                         L6328                  L6328                
L4408:
        shl (16|M0)              r2.0<1>:d     r62.0<1;1,0>:d    1:w               {Compacted,F@1}
        shr (16|M0)              r8.0<1>:ud    r62.0<1;1,0>:ud   31:w              
        shl (16|M0)              r10.0<1>:d    r76.0<1;1,0>:d    1:w               {Compacted}
        cmp (16|M0)   (lt)f0.0   null<1>:d     r2.0<1;1,0>:ud    0x4E:uw              {I@3}
        or (16|M0)               r10.0<1>:d    r10.0<1;1,0>:d    r8.0<1;1,0>:d    {Compacted,I@2}
(f0.0)  cmp (16|M0)   (eq)f0.0   null<1>:d     r10.0<1;1,0>:d    0:w               {I@1}
(~f0.0) cmp (16|M0)   (lt)f0.0   null<1>:d     r10.0<1;1,0>:d    0:w              
(f0.0)  goto (16|M0)                         L4640                  L4640                
L4512:
        cmp (16|M0)   (eq)f1.0   null<1>:d     r62.0<1;1,0>:d    39:w              
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r76.0<1;1,0>:d    0:w              
(~f1.0) goto (16|M0)                         L4640                  L4704                
L4560:
        shr (16|M0)              r64.0<1>:ud   r48.0<1;1,0>:ud   1:w              
        mov (16|M0)              r126.0<1>:d   0:w                              
        mov (16|M0)              r18.0<1>:d    0:w                              
        mov (16|M0)              r12.0<1>:f    r64.0<1;1,0>:f                   {Compacted,I@3}
        mov (16|M0)              r64.0<1>:f    r48.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L4640                  L5800                
L4640:
        join (16|M0)                         L4704                                
L4656:
        cmp (16|M0)   (eq)f0.1   null<1>:d     r62.0<1;1,0>:d    38:w              
(f0.1)  cmp (16|M0)   (eq)f0.1   null<1>:d     r76.0<1;1,0>:d    0:w              
(f0.1)  goto (16|M0)                         L4704                  L5712                
L4704:
        join (16|M0)                         L5712                                
L4720:
        add (16|M0)              r2.0<1>:d     -r62.0<1;1,0>:d   39:w               {Compacted}
        and (16|M0)   (ne)f1.1   r122.0<1>:d   r2.0<1;1,0>:d     63:w               {I@1}
        add (16|M0)              r106.0<1>:d   -r62.0<1;1,0>:d   40:w               {Compacted}
(f1.1)  goto (16|M0)                         L4792                  L4792                
L4768:
        mov (16|M0)              r96.0<1>:f    r48.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L4792                  L4904                
L4792:
        join (16|M0)                         L4904                                
L4808:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r122.0<1;1,0>:ud  0x20:uw              {I@5}
(~f1.0) add (16|M0)              r2.0<1>:d     r122.0<1;1,0>:d   -32:w              
(~f1.0) shr (16|M0)              r64.0<1>:ud   r46.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.0)  add (16|M0)              r2.0<1>:d     -r122.0<1;1,0>:d  32:w               {Compacted}
(f1.0)  shr (16|M0)              r8.0<1>:ud    r48.0<1;1,0>:ud   r122.0<1;1,0>:d 
(f1.0)  shl (16|M0)              r2.0<1>:d     r46.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.0)  or (16|M0)               r64.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
        mov (16|M0)              r96.0<1>:f    r64.0<1;1,0>:f                   {Compacted,I@1}
L4904:
        join (16|M0)                         L5712                                
L4920:
        add (16|M0)              r74.0<1>:d    -r62.0<1;1,0>:d   38:w               {Compacted}
        and (16|M0)   (ne)f0.1   r126.0<1>:d   r74.0<1;1,0>:d    63:w               {I@1}
(f0.1)  goto (16|M0)                         L4984                  L4984                
L4960:
        mov (16|M0)              r64.0<1>:f    r48.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L4984                  L5088                
L4984:
        join (16|M0)                         L5088                                
L5000:
        cmp (16|M0)   (lt)f0.0   null<1>:d     r126.0<1;1,0>:ud  0x20:uw              {I@4}
(~f0.0) add (16|M0)              r2.0<1>:d     r126.0<1;1,0>:d   -32:w              
(~f0.0) shr (16|M0)              r64.0<1>:ud   r46.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f0.0)  add (16|M0)              r2.0<1>:d     -r126.0<1;1,0>:d  32:w               {Compacted}
(f0.0)  shr (16|M0)              r8.0<1>:ud    r48.0<1;1,0>:ud   r126.0<1;1,0>:d 
(f0.0)  shl (16|M0)              r2.0<1>:d     r46.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f0.0)  or (16|M0)               r64.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
L5088:
        join (16|M0)                         L5712                                
L5104:
        and (16|M0)   (ne)f1.1   r98.0<1>:d    r74.0<1;1,0>:d    63:w              
        and (16|M0)              r18.0<1>:d    r64.0<1;1,0>:d    1:w               {Compacted,I@3}
(f1.1)  goto (16|M0)                         L5192                  L5192                
L5144:
        mov (16|M0)              r110.0<1>:d   -1:w                              
        mov (16|M0)              r114.0<1>:d   -1:w                              
        goto (16|M0)                         L5192                  L5376                
L5192:
        join (16|M0)                         L5376                                
L5208:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r98.0<1;1,0>:ud   0x20:uw              {I@7}
(f1.0)  goto (16|M0)                         L5312                  L5312                
L5240:
        add (16|M0)              r2.0<1>:d     r98.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r5.8<1>:hf    -qnan(0x1FF):hf                             
        mov (16|M0)              r110.0<1>:d   0:w                              
        shl (16|M0)              r114.0<1>:d   r5.8<0;1,0>:w     r2.0<1;1,0>:d    {A@1}
        goto (16|M0)                         L5312                  L5376                
L5312:
        join (16|M0)                         L5376                                
L5328:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (16|M0)              r114.0<1>:d   -1:w                              
        shl (16|M0)              r110.0<1>:d   r2.0<0;1,0>:w     r98.0<1;1,0>:d   {F@1}
L5376:
        join (16|M0)                         L5712                                
L5392:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r110.0<1;0>:ud    r6.3<0;0>:ud      r48.0<1>:ud      {I@2} // (s0^s1)&s2
        cmp (16|M0)   (ne)f0.0   null<1>:d     r2.0<1;1,0>:d     0:w               {Compacted,I@1}
        bfn.0x60 (16|M0)         r8.0<1>:ud    r114.0<1;0>:ud    r6.3<0;0>:ud      r46.0<1>:ud      // (s0^s1)&s2
(~f0.0) cmp (16|M0)   (ne)f0.0   null<1>:d     r8.0<1;1,0>:d     0:w               {I@1}
(W)     mov (1|M0)               r5.8<1>:hf    -qnan(0x1FF):hf                             
        and (16|M0)   (ne)f0.1   r124.0<1>:d   r106.0<1;1,0>:d   63:w              
(f0.0)  sel (16|M0)              r10.0<1>:d    r5.8<0;1,0>:w     0:w               {F@1}
        mov (16|M0)              r126.0<1>:d   -r10.0<1;1,0>:d                  {I@1}
(f0.1)  goto (16|M0)                         L5552                  L5552                
L5528:
        mov (16|M0)              r64.0<1>:f    r48.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L5552                  L5656                
L5552:
        join (16|M0)                         L5656                                
L5568:
        cmp (16|M0)   (lt)f0.0   null<1>:d     r124.0<1;1,0>:ud  0x20:uw             
(~f0.0) add (16|M0)              r2.0<1>:d     r124.0<1;1,0>:d   -32:w              
(~f0.0) shr (16|M0)              r64.0<1>:ud   r46.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f0.0)  add (16|M0)              r2.0<1>:d     -r124.0<1;1,0>:d  32:w               {Compacted}
(f0.0)  shr (16|M0)              r8.0<1>:ud    r48.0<1;1,0>:ud   r124.0<1;1,0>:d 
(f0.0)  shl (16|M0)              r2.0<1>:d     r46.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f0.0)  or (16|M0)               r64.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
L5656:
        join (16|M0)                         L5712                                
L5672:
        mov (16|M0)              r12.0<1>:f    r64.0<1;1,0>:f                   {Compacted,I@2}
        mov (16|M0)              r64.0<1>:d    r96.0<1;1,0>:d                   {F@1}
        goto (16|M0)                         L5712                  L5800                
L5712:
        join (16|M0)                         L5800                                
L5728:
        shr (16|M0)              r64.0<1>:ud   r48.0<1;1,0>:ud   2:w              
        mov (16|M0)              r126.0<1>:d   0:w                              
        mov (16|M0)              r18.0<1>:d    0:w                              
        mov (16|M0)              r12.0<1>:f    r64.0<1;1,0>:f                   {Compacted,I@3}
        shr (16|M0)              r64.0<1>:ud   r48.0<1;1,0>:ud   1:w               {F@1}
L5800:
        join (16|M0)                         L6328                                
L5816:
        shl (16|M0)              r2.0<1>:d     r64.0<1;1,0>:d    2:w               {Compacted,I@2}
        shl (16|M0)              r8.0<1>:d     r18.0<1;1,0>:d    1:w               {Compacted}
        and (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     4:w               {Compacted,I@2}
        bfn.0xFE (16|M0)         r78.0<1>:ud   r2.0<1;0>:ud      r8.0<1;0>:ud      r126.0<1>:ud     {I@1} // s0|s1|s2
        cmp (16|M0)   (eq)f1.1   null<1>:d     r78.0<1;1,0>:d    0:w               {I@1}
        and (16|M0)              r100.0<1>:d   r12.0<1;1,0>:d    8388607:d              
(~f1.1) goto (16|M0)                         L5936                  L5936                
L5904:
        mov (16|M0)              r66.0<1>:d    0:w                              
        goto (16|M0)                         L5936                  L6096                
L5936:
        join (16|M0)                         L6096                                
L5952:
        cmp (16|M0)   (gt)f1.0   null<1>:d     r78.0<1;1,0>:ud   0x4:uw             
(~f1.0) goto (16|M0)                         L6016                  L6016                
L5984:
        mov (16|M0)              r66.0<1>:d    1:w                              
        goto (16|M0)                         L6016                  L6096                
L6016:
        join (16|M0)                         L6096                                
L6032:
        and (16|M0)   (ne)f1.1   null<1>:d     r12.0<1;1,0>:d    1:w              
(W)     mov (1|M0)               r2.0<1>:hf    0x1:hf                             
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r78.0<1;1,0>:d    4:w              
(f1.1)  sel (16|M0)              r66.0<1>:d    r2.0<0;1,0>:w     0:w               {F@1}
L6096:
        join (16|M0)                         L6328                                
L6112:
        add (16|M0)              r60.0<1>:d    r100.0<1;1,0>:d   r66.0<1;1,0>:d   {Compacted,I@2}
        cmp (16|M0)   (gt)f1.1   null<1>:d     r60.0<1;1,0>:ud   0x7FFFFF:ud              {I@1}
        add3 (16|M0)             r2.0<1>:d     r52.0<1;0>:d      r56.0<1;0>:d      -45:w              
(f1.1)  sel (16|M0)              r58.0<1>:d    r2.0<1;1,0>:d     r58.0<1;1,0>:d   {Compacted,I@1}
        cmp (16|M0)   (eq)f0.1   null<1>:d     r58.0<1;1,0>:d    255:w               {I@1}
(f0.1)  goto (16|M0)                         L6264                  L6264                
L6192:
(~f1.1) sel (16|M0)              r2.0<1>:d     r60.0<1;1,0>:d    0:w              
        and (16|M0)              r8.0<1>:d     r44.0<1;1,0>:d    -2147483648:d              
        shl (16|M0)              r10.0<1>:d    r58.0<1;1,0>:d    23:w               {Compacted}
        bfn.0xFE (16|M0)         r88.0<1>:ud   r8.0<1;0>:ud      r10.0<1;0>:ud     r2.0<1>:ud       {I@1} // s0|s1|s2
        goto (16|M0)                         L6264                  L6848                
L6264:
        join (16|M0)                         L6328                                
L6280:
        cmp (16|M0)   (gt)f0.1   null<1>:d     r44.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r2.0<1>:f     inf:f                               {Compacted,I@4}
(f0.1)  sel (16|M0)              r88.0<1>:f    r2.0<0;1,0>:f     -inf:f               {Compacted,F@1}
        goto (16|M0)                         L6328                  L6848                
L6328:
        join (16|M0)                         L6632                                
L6344:
        and (16|M0)   (ne)f0.0   r46.0<1>:d    r56.0<1;1,0>:d    63:w               {Compacted}
(f0.0)  goto (16|M0)                         L6400                  L6400                
L6368:
        mov (16|M0)              r60.0<1>:d    -1:w                              
        goto (16|M0)                         L6400                  L6528                
L6400:
        join (16|M0)                         L6528                                
L6416:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r46.0<1;1,0>:ud   0x20:uw              {I@5}
(f1.1)  goto (16|M0)                         L6480                  L6480                
L6448:
        mov (16|M0)              r60.0<1>:d    0:w                              
        goto (16|M0)                         L6480                  L6528                
L6480:
        join (16|M0)                         L6528                                
L6496:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                             
        shl (16|M0)              r60.0<1>:d    r2.0<0;1,0>:w     r46.0<1;1,0>:d   {F@1}
L6528:
        join (16|M0)                         L6632                                
L6544:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r60.0<1;0>:ud     r6.3<0;0>:ud      r48.0<1>:ud      {I@2} // (s0^s1)&s2
        add (16|M0)              r8.0<1>:d     -r56.0<1;1,0>:d   23:w               {Compacted}
        and (16|M0)              r10.0<1>:d    r44.0<1;1,0>:d    -2147483648:d              
        shl (16|M0)              r12.0<1>:d    r58.0<1;1,0>:d    23:w               {Compacted}
        shl (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     r8.0<1;1,0>:d    {Compacted,I@3}
        bfn.0xFE (16|M0)         r88.0<1>:ud   r10.0<1;0>:ud     r12.0<1;0>:ud     r2.0<1>:ud       {I@1} // s0|s1|s2
        goto (16|M0)                         L6632                  L6848                
L6632:
        join (16|M0)                         L6688                                
L6648:
        cmp (16|M0)   (gt)f0.0   null<1>:d     r44.0<1;1,0>:d    -1:w               {Compacted}
(W)     mov (1|M0)               r2.0<1>:f     inf:f                               {Compacted,I@4}
(f0.0)  sel (16|M0)              r88.0<1>:f    r2.0<0;1,0>:f     -inf:f               {Compacted,F@1}
        goto (16|M0)                         L6688                  L6848                
L6688:
        join (16|M0)                         L6752                                
L6704:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r44.0<1;1,0>:d    0:w              
(W)     mov (1|M0)               r2.0<1>:f     -0.0:f                               {Compacted}
(f1.1)  sel (16|M0)              r88.0<1>:f    r2.0<0;1,0>:f     0.0:f               {Compacted,F@1}
        goto (16|M0)                         L6752                  L6848                
L6752:
        join (16|M0)                         L6816                                
L6768:
        cmp (16|M0)   (gt)f1.0   null<1>:d     r44.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r2.0<1>:f     inf:f                               {Compacted}
(f1.0)  sel (16|M0)              r88.0<1>:f    r2.0<0;1,0>:f     -inf:f               {Compacted,F@1}
        goto (16|M0)                         L6816                  L6848                
L6816:
        join (16|M0)                         L6848                                
L6832:
        bfn.0xF8 (16|M0)         r88.0<1>:ud   r44.0<1;0>:ud     r6.5<0;0>:ud      r6.4<0>:ud       {F@1} // s0&s1|s2
L6848:
        join (16|M0)                         L13336                                
L6864:
        rnde (16|M0)             r76.0<1>:f    r88.0<1;1,0>:f                   {Compacted,I@2}
        shr (16|M0)              r64.0<1>:ud   r76.0<1;1,0>:ud   23:w               {F@1}
        and (16|M0)   (ne)f1.0   r108.0<1>:d   r76.0<1;1,0>:d    8388607:d              
        and (16|M0)              r100.0<1>:d   r64.0<1;1,0>:d    255:w               {Compacted,I@2}
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r100.0<1;1,0>:d   255:w               {I@1}
(~f1.0) goto (16|M0)                         L6976                  L6976                
L6944:
        mov (16|M0)              r86.0<1>:ud   0x7FC00000:ud                             
        goto (16|M0)                         L6976                  L12944                
L6976:
        join (16|M0)                         L12944                                
L6992:
        cmp (16|M0)   (eq)f1.1   null<1>:d     r108.0<1;1,0>:d   0:w              
        add (16|M0)              r2.0<1>:d     r34.0<1;1,0>:d    -25165824:d              
        shr (16|M0)              r62.0<1>:ud   r2.0<1;1,0>:ud    23:w               {I@1}
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r100.0<1;1,0>:d   255:w              
        and (16|M0)              r68.0<1>:d    r62.0<1;1,0>:d    255:w               {Compacted,I@2}
(~f1.1) cmp (16|M0)   (eq)f1.1   null<1>:d     r68.0<1;1,0>:d    255:w               {I@1}
        xor (16|M0)              r38.0<1>:d    r2.0<1;1,0>:d     r76.0<1;1,0>:d   {Compacted}
(f1.1)  goto (16|M0)                         L12912                  L12912                
L7104:
        cmp (16|M0)   (eq)f0.1   null<1>:d     r68.0<1;1,0>:d    0:w              
        or (16|M0)               r2.0<1>:d     r100.0<1;1,0>:d   r108.0<1;1,0>:d  {Compacted}
(~f0.1) cmp (16|M0)   (eq)f0.1   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
(~f0.1) goto (16|M0)                         L7192                  L7192                
L7160:
        mov (16|M0)              r86.0<1>:ud   0x0:ud                             
        goto (16|M0)                         L7192                  L12944                
L7192:
        join (16|M0)                         L12912                                
L7208:
        cmp (16|M0)   (eq)f0.0   null<1>:d     r100.0<1;1,0>:d   0:w               {Compacted}
        add (16|M0)              r72.0<1>:d    r100.0<1;1,0>:d   -127:w               {Compacted}
(f0.0)  mov (16|M0)              r72.0<1>:d    -126:w                              
        add (16|M0)              r50.0<1>:d    r68.0<1;1,0>:d    r72.0<1;1,0>:d   {Compacted,I@1}
        cmp (16|M0)   (gt)f1.0   null<1>:d     r50.0<1;1,0>:d    254:w               {I@1}
(f1.0)  goto (16|M0)                         L12848                  L12848                
L7280:
        or (16|M0)    (eq)f0.1   null<4>:b     r64.0<1;1,0>:d    r62.0<1;1,0>:d  
(f0.1)  goto (16|M0)                         L12784                  L12784                
L7312:
(W)     mov (1|M0)               r2.0<1>:hf    0.0:hf                             
(W)     mov (1|M0)               r21.6<1>:d    0:w                              
(f0.0)  sel (16|M0)              r8.0<1>:d     r2.0<0;1,0>:w     8388608:d               {F@1}
        or (16|M0)               r8.0<1>:d     r8.0<1;1,0>:d     r108.0<1;1,0>:d  {Compacted,I@1}
        shl (16|M0)              r42.0<1>:d    r8.0<1;1,0>:d     23:w               {Compacted,I@1}
        shr (16|M0)              r40.0<1>:ud   r8.0<1;1,0>:ud    9:w              
(W)     mov (1|M0)               r21.3<1>:f    -0.0:f                               {Compacted}
(W)     mov (2|M0)               r21.4<1>:d    0:w                              
L7416:
(W)     shl (1|M0)               r2.0<1>:d     r21.3<0;1,0>:d    31:w               {Compacted,F@1}
(W)     shr (1|M0)               r2.1<1>:ud    r21.6<0;1,0>:ud   1:w              
(W)     cmp (16|M0)   (gt)f1.0   null<1>:d     r21.4<0;1,0>:ud   0x3E:uw              {I@3}
(W)     or (1|M0)                r21.6<1>:d    r2.1<0;1,0>:d     r2.0<0;1,0>:d    {I@2}
        bfn.0xE0 (16|M0)         r8.0<1>:ud    r2.1<0;0>:ud      r2.0<0;0>:ud      r42.0<1>:ud      // (s0|s1)&s2
(W)     shr (1|M0)               r21.2<1>:ud   r21.3<0;1,0>:ud   1:w              
(W&f1.0) cmp (16|M0)  (eq)f1.0   null<1>:d     r21.5<0;1,0>:d    0:w              
        cmp (16|M0)   (eq)f0.0   null<1>:d     r8.0<1;1,0>:d     r21.6<0;1,0>:d   {I@3}
        and (16|M0)              r10.0<1>:d    r21.2<0;1,0>:d    r40.0<1;1,0>:d   {Compacted,I@3}
(W&~f1.0) cmp (16|M0) (gt)f1.0   null<1>:d     r21.5<0;1,0>:ud   0x0:uw             
(f0.0)  cmp (16|M0)   (eq)f0.0   null<1>:d     r10.0<1;1,0>:d    r21.2<0;1,0>:d   {I@2}
(W)     mov (1|M0)               r5.8<1>:hf    0x1:hf                             
(W)     addc (1|M0)              r13.0<1>:ud   r21.4<0;1,0>:ud   0x1:ud              {AccWrEn}
(f1.0)  sel (16|M0)              r7.0<1>:uw    r5.8<0;1,0>:uw    0x0:uw              {Compacted,F@1}
(f0.0)  sel (16|M0)              acc2.0<1>:uw  r5.8<0;1,0>:uw    0x0:uw             
(W)     mov (1|M0)               r3.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        or (16|M0)    (ne)f1.1   null<1>:uw    r7.0<1;1,0>:uw    acc2.0<1;1,0>:uw {I@3}
(W)     add (1|M0)               r21.7<1>:ud   r3.0<0;1,0>:ud    r21.5<0;1,0>:ud  {I@2}
        mov (16|M0)              r94.0<1>:d    r21.4<0;1,0>:d                  
        mov (16|M0)              r92.0<1>:d    r21.5<0;1,0>:d                  
        mov (16|M0)              r66.0<1>:f    r13.0<0;1,0>:f                   {Compacted}
        mov (16|M0)              r74.0<1>:d    r21.7<0;1,0>:d                   {I@3}
(f1.1)  goto (16|M0)                         L7808                  L7808                
L7744:
(W)     mov (1|M0)               r21.3<1>:d    r21.2<0;1,0>:d                  
(W)     mov (1|M0)               r21.4<1>:d    r13.0<0;1,0>:d                  
(W)     mov (1|M0)               r21.5<1>:d    r21.7<0;1,0>:d                  
(W)     jmpi                                 L7416                                
L7808:
        join (16|M0)                         L12784                                
L7824:
(W)     mov (1|M0)               r2.0<1>:f     8.68805e-44:f                              
(W)     mov (1|M0)               r3.0<1>:hf    0.0:hf                             
        subb (8|M0)              r54.0<1>:ud   r2.0<0;1,0>:ud    r94.0<1;1,0>:ud  {AccWrEn,Compacted,A@2}
        add3 (8|M0)              r78.0<1>:ud   -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r92.0<1>:ud     {A@1}
        subb (8|M8)              r55.0<1>:ud   r2.0<0;1,0>:ud    r95.0<1;1,0>:ud  {AccWrEn}
        add3 (16|M0)             r14.0<1>:d    r50.0<1;0>:d      r54.0<1;0>:d      -173:w               {I@1}
        cmp (16|M0)   (gt)f0.0   null<1>:d     r14.0<1;1,0>:d    127:w               {Compacted,I@1}
        add3 (8|M8)              r79.0<1>:ud   -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r93.0<1>:ud    
        add3 (16|M0)             r76.0<1>:d    r68.0<1;0>:d      r72.0<1;0>:d      r54.0<1>:d      
(f0.0)  goto (16|M0)                         L12728                  L12728                
L7968:
        cmp (16|M0)   (gt)f1.1   null<1>:d     r14.0<1;1,0>:d    -127:w              
(f1.1)  goto (16|M0)                         L10416                  L10416                
L8000:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r14.0<1;1,0>:ud   0xFFFFFF6B:ud             
(f1.0)  goto (16|M0)                         L9920                  L9920                
L8032:
(W)     mov (1|M0)               r2.0<1>:f     8.82818e-44:f                              
(W)     mov (1|M0)               r3.0<1>:hf    0.0:hf                              {I@7}
        subb (8|M0)              r96.0<1>:ud   r2.0<0;1,0>:ud    r94.0<1;1,0>:ud  {AccWrEn,Compacted,F@2}
        add3 (16|M0)             r118.0<1>:d   r50.0<1;0>:d      r54.0<1;0>:d      -23:w              
        add3 (8|M0)              r8.0<1>:ud    -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r92.0<1>:ud     {F@1}
        subb (8|M8)              r97.0<1>:ud   r2.0<0;1,0>:ud    r95.0<1;1,0>:ud  {AccWrEn}
        cmp (16|M0)   (gt)f1.0   null<1>:d     r96.0<1;1,0>:ud   r118.0<1;1,0>:ud {I@1}
        add3 (8|M8)              r9.0<1>:ud    -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r93.0<1>:ud    
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r8.0<1;1,0>:d     0:w               {I@1}
(~f1.0) cmp (16|M0)   (gt)f1.0   null<1>:d     r8.0<1;1,0>:ud    0x0:uw             
(f1.0)  goto (16|M0)                         L8256                  L8256                
L8200:
        add3 (16|M0)             r2.0<1>:d     r76.0<1;0>:d      -r96.0<1;0>:d     -23:w              
        mov (16|M0)              r34.0<1>:d    0:w                              
        shl (16|M0)              r40.0<1>:d    r42.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
        goto (16|M0)                         L8256                  L9856                
L8256:
        join (16|M0)                         L9856                                
L8272:
        add3 (16|M0)             r22.0<1>:d    r96.0<1;0>:d      -r76.0<1;0>:d     23:w              
        cmp (16|M0)   (lt)f0.1   null<1>:d     r22.0<1;1,0>:d    2:w               {I@1}
(f0.1)  goto (16|M0)                         L8416                  L8416                
L8320:
        cmp (16|M0)   (eq)f0.0   null<1>:d     r22.0<1;1,0>:d    2:w               {Compacted}
(~f0.0) goto (16|M0)                         L8416                  L8464                
L8344:
        shr (16|M0)              r70.0<1>:ud   r42.0<1;1,0>:ud   1:w              
        mov (16|M0)              r112.0<1>:d   0:w                              
        mov (16|M0)              r12.0<1>:d    0:w                              
        mov (16|M0)              r106.0<1>:f   r70.0<1;1,0>:f                   {Compacted,I@3}
        goto (16|M0)                         L8416                  L9336                
L8416:
        join (16|M0)                         L8464                                
L8432:
        cmp (16|M0)   (eq)f1.1   null<1>:d     r22.0<1;1,0>:d    1:w              
(f1.1)  goto (16|M0)                         L8464                  L9280                
L8464:
        join (16|M0)                         L9280                                
L8480:
        add3 (16|M0)             r2.0<1>:d     r96.0<1;0>:d      -r118.0<1;0>:d    -1:w              
        and (16|M0)   (ne)f1.0   r108.0<1>:d   r2.0<1;1,0>:d     63:w               {I@1}
(f1.0)  goto (16|M0)                         L8552                  L8552                
L8528:
        mov (16|M0)              r90.0<1>:f    r42.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L8552                  L8664                
L8552:
        join (16|M0)                         L8664                                
L8568:
        cmp (16|M0)   (lt)f0.1   null<1>:d     r108.0<1;1,0>:ud  0x20:uw              {I@4}
(~f0.1) add (16|M0)              r2.0<1>:d     r108.0<1;1,0>:d   -32:w              
(~f0.1) shr (16|M0)              r70.0<1>:ud   r40.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f0.1)  add (16|M0)              r2.0<1>:d     -r108.0<1;1,0>:d  32:w               {Compacted}
(f0.1)  shr (16|M0)              r8.0<1>:ud    r42.0<1;1,0>:ud   r108.0<1;1,0>:d 
(f0.1)  shl (16|M0)              r2.0<1>:d     r40.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f0.1)  or (16|M0)               r70.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
        mov (16|M0)              r90.0<1>:f    r70.0<1;1,0>:f                   {Compacted,I@1}
L8664:
        join (16|M0)                         L9280                                
L8680:
        add3 (16|M0)             r68.0<1>:d    r96.0<1;0>:d      -r118.0<1;0>:d    -2:w              
        and (16|M0)   (ne)f0.0   r106.0<1>:d   r68.0<1;1,0>:d    63:w               {Compacted,I@1}
(f0.0)  goto (16|M0)                         L8744                  L8744                
L8720:
        mov (16|M0)              r70.0<1>:f    r42.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L8744                  L8848                
L8744:
        join (16|M0)                         L8848                                
L8760:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r106.0<1;1,0>:ud  0x20:uw              {I@4}
(~f1.1) add (16|M0)              r2.0<1>:d     r106.0<1;1,0>:d   -32:w              
(~f1.1) shr (16|M0)              r70.0<1>:ud   r40.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.1)  add (16|M0)              r2.0<1>:d     -r106.0<1;1,0>:d  32:w               {Compacted}
(f1.1)  shr (16|M0)              r8.0<1>:ud    r42.0<1;1,0>:ud   r106.0<1;1,0>:d 
(f1.1)  shl (16|M0)              r2.0<1>:d     r40.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.1)  or (16|M0)               r70.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
L8848:
        join (16|M0)                         L9280                                
L8864:
        and (16|M0)   (ne)f1.0   r74.0<1>:d    r68.0<1;1,0>:d    63:w              
        and (16|M0)              r12.0<1>:d    r70.0<1;1,0>:d    1:w               {Compacted,I@3}
(f1.0)  goto (16|M0)                         L8952                  L8952                
L8904:
        mov (16|M0)              r82.0<1>:d    -1:w                              
        mov (16|M0)              r88.0<1>:d    -1:w                              
        goto (16|M0)                         L8952                  L9136                
L8952:
        join (16|M0)                         L9136                                
L8968:
        cmp (16|M0)   (lt)f0.1   null<1>:d     r74.0<1;1,0>:ud   0x20:uw              {I@7}
(f0.1)  goto (16|M0)                         L9072                  L9072                
L9000:
        add (16|M0)              r2.0<1>:d     r74.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r5.8<1>:hf    -qnan(0x1FF):hf                             
        mov (16|M0)              r82.0<1>:d    0:w                              
        shl (16|M0)              r88.0<1>:d    r5.8<0;1,0>:w     r2.0<1;1,0>:d    {A@1}
        goto (16|M0)                         L9072                  L9136                
L9072:
        join (16|M0)                         L9136                                
L9088:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (16|M0)              r88.0<1>:d    -1:w                              
        shl (16|M0)              r82.0<1>:d    r2.0<0;1,0>:w     r74.0<1;1,0>:d   {F@1}
L9136:
        join (16|M0)                         L9280                                
L9152:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r82.0<1;0>:ud     r6.3<0;0>:ud      r42.0<1>:ud      {I@2} // (s0^s1)&s2
        cmp (16|M0)   (ne)f0.0   null<1>:d     r2.0<1;1,0>:d     0:w               {Compacted,I@1}
        bfn.0x60 (16|M0)         r8.0<1>:ud    r88.0<1;0>:ud     r6.3<0;0>:ud      r40.0<1>:ud      // (s0^s1)&s2
(~f0.0) cmp (16|M0)   (ne)f0.0   null<1>:d     r8.0<1;1,0>:d     0:w               {I@1}
(W)     mov (1|M0)               r5.8<1>:hf    -qnan(0x1FF):hf                             
        mov (16|M0)              r106.0<1>:f   r90.0<1;1,0>:f                   {Compacted}
(f0.0)  sel (16|M0)              r10.0<1>:d    r5.8<0;1,0>:w     0:w               {F@2}
        mov (16|M0)              r112.0<1>:d   -r10.0<1;1,0>:d                  {I@1}
        goto (16|M0)                         L9280                  L9336                
L9280:
        join (16|M0)                         L9336                                
L9296:
        mov (16|M0)              r112.0<1>:d   0:w                              
        mov (16|M0)              r12.0<1>:d    0:w                              
        mov (16|M0)              r106.0<1>:f   r42.0<1;1,0>:f                   {Compacted}
L9336:
        join (16|M0)                         L9856                                
L9352:
        and (16|M0)   (ne)f0.0   r104.0<1>:d   r22.0<1;1,0>:d    63:w               {Compacted}
(f0.0)  goto (16|M0)                         L9400                  L9400                
L9376:
        mov (16|M0)              r70.0<1>:f    r42.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L9400                  L9504                
L9400:
        join (16|M0)                         L9504                                
L9416:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r104.0<1;1,0>:ud  0x20:uw              {I@4}
(~f1.1) add (16|M0)              r2.0<1>:d     r104.0<1;1,0>:d   -32:w              
(~f1.1) shr (16|M0)              r70.0<1>:ud   r40.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.1)  add (16|M0)              r2.0<1>:d     -r104.0<1;1,0>:d  32:w               {Compacted}
(f1.1)  shr (16|M0)              r8.0<1>:ud    r42.0<1;1,0>:ud   r104.0<1;1,0>:d 
(f1.1)  shl (16|M0)              r2.0<1>:d     r40.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.1)  or (16|M0)               r70.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
L9504:
        join (16|M0)                         L9856                                
L9520:
        shl (16|M0)              r2.0<1>:d     r106.0<1;1,0>:d   2:w               {Compacted}
        shl (16|M0)              r8.0<1>:d     r12.0<1;1,0>:d    1:w               {Compacted}
        and (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     4:w               {Compacted,I@2}
        bfn.0xFE (16|M0)         r40.0<1>:ud   r2.0<1;0>:ud      r8.0<1;0>:ud      r112.0<1>:ud     {I@1} // s0|s1|s2
        cmp (16|M0)   (eq)f1.0   null<1>:d     r40.0<1;1,0>:d    0:w               {I@1}
(~f1.0) goto (16|M0)                         L9624                  L9624                
L9592:
        mov (16|M0)              r42.0<1>:d    0:w                              
        goto (16|M0)                         L9624                  L9784                
L9624:
        join (16|M0)                         L9784                                
L9640:
        cmp (16|M0)   (gt)f0.1   null<1>:d     r40.0<1;1,0>:ud   0x4:uw             
(~f0.1) goto (16|M0)                         L9704                  L9704                
L9672:
        mov (16|M0)              r42.0<1>:d    1:w                              
        goto (16|M0)                         L9704                  L9784                
L9704:
        join (16|M0)                         L9784                                
L9720:
        and (16|M0)   (ne)f1.1   null<1>:d     r70.0<1;1,0>:d    1:w              
(W)     mov (1|M0)               r2.0<1>:hf    0x1:hf                             
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r40.0<1;1,0>:d    4:w              
(f1.1)  sel (16|M0)              r42.0<1>:d    r2.0<0;1,0>:w     0:w               {F@1}
L9784:
        join (16|M0)                         L9856                                
L9800:
        add (16|M0)              r2.0<1>:d     r42.0<1;1,0>:d    r70.0<1;1,0>:d   {Compacted,I@2}
        cmp (16|M0)   (gt)f0.0   null<1>:d     r2.0<1;1,0>:ud    0x7FFFFF:ud              {I@1}
(W)     mov (1|M0)               r5.4<1>:f     0x800000:f                               {Compacted}
(~f0.0) sel (16|M0)              r40.0<1>:d    r2.0<1;1,0>:d     0:w              
(f0.0)  sel (16|M0)              r34.0<1>:d    r5.4<0;1,0>:d     0:w               {Compacted,F@1}
L9856:
        join (16|M0)                         L9920                                
L9872:
        and (16|M0)              r2.0<1>:d     r38.0<1;1,0>:d    -2147483648:d              
        bfn.0xFE (16|M0)         r86.0<1>:ud   r2.0<1;0>:ud      r34.0<1;0>:ud     r40.0<1>:ud      {I@1} // s0|s1|s2
        goto (16|M0)                         L9920                  L12944                
L9920:
        join (16|M0)                         L10416                                
L9936:
        and (16|M0)   (ne)f0.0   r54.0<1>:d    r54.0<1;1,0>:d    63:w               {Compacted}
(f0.0)  goto (16|M0)                         L10008                  L10008                
L9960:
        mov (16|M0)              r64.0<1>:d    -1:w                              
        mov (16|M0)              r72.0<1>:d    -1:w                              
        goto (16|M0)                         L10008                  L10192                
L10008:
        join (16|M0)                         L10192                                
L10024:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r54.0<1;1,0>:ud   0x20:uw              {I@6}
(f1.1)  goto (16|M0)                         L10128                  L10128                
L10056:
        add (16|M0)              r2.0<1>:d     r54.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r5.8<1>:hf    -qnan(0x1FF):hf                             
        mov (16|M0)              r64.0<1>:d    0:w                              
        shl (16|M0)              r72.0<1>:d    r5.8<0;1,0>:w     r2.0<1;1,0>:d    {A@1}
        goto (16|M0)                         L10128                  L10192                
L10128:
        join (16|M0)                         L10192                                
L10144:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (16|M0)              r72.0<1>:d    -1:w                              
        shl (16|M0)              r64.0<1>:d    r2.0<0;1,0>:w     r54.0<1;1,0>:d   {F@1}
L10192:
        join (16|M0)                         L10416                                
L10208:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r64.0<1;0>:ud     r6.3<0;0>:ud      r42.0<1>:ud      {I@2} // (s0^s1)&s2
        cmp (16|M0)   (ne)f1.1   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
        bfn.0x60 (16|M0)         r8.0<1>:ud    r72.0<1;0>:ud     r6.3<0;0>:ud      r40.0<1>:ud      // (s0^s1)&s2
        cmp (16|M0)   (gt)f1.0   null<1>:d     r38.0<1;1,0>:d    -1:w              
(~f1.1) cmp (16|M0)   (ne)f1.1   null<1>:d     r8.0<1;1,0>:d     0:w               {I@2}
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r14.0<1;1,0>:d    -150:w              
(f1.0)  goto (16|M0)                         L10360                  L10360                
L10320:
(W)     mov (1|M0)               r2.0<1>:ud    0x80000001:ud                             
(f1.1)  sel (16|M0)              r86.0<1>:f    r2.0<0;1,0>:f     -0.0:f               {Compacted,I@1}
        goto (16|M0)                         L10360                  L12944                
L10360:
        join (16|M0)                         L10416                                
L10376:
(W)     mov (1|M0)               r2.0<1>:ud    0x1:ud                              {F@1}
(f1.1)  sel (16|M0)              r86.0<1>:f    r2.0<0;1,0>:f     0.0:f               {Compacted,I@1}
        goto (16|M0)                         L10416                  L12944                
L10416:
        join (16|M0)                         L12728                                
L10432:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r54.0<1;1,0>:ud   0x18:uw             
        add3 (16|M0)             r60.0<1>:d    r50.0<1;0>:d      r54.0<1;0>:d      -46:w              
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r78.0<1;1,0>:d    0:w              
(f1.0)  goto (16|M0)                         L12416                  L12416                
L10496:
        shl (16|M0)              r2.0<1>:d     r66.0<1;1,0>:d    1:w               {Compacted,F@1}
        shr (16|M0)              r8.0<1>:ud    r66.0<1;1,0>:ud   31:w              
        shl (16|M0)              r10.0<1>:d    r74.0<1;1,0>:d    1:w               {Compacted}
        cmp (16|M0)   (lt)f0.1   null<1>:d     r2.0<1;1,0>:ud    0x4E:uw              {I@3}
        or (16|M0)               r10.0<1>:d    r10.0<1;1,0>:d    r8.0<1;1,0>:d    {Compacted,I@2}
(f0.1)  cmp (16|M0)   (eq)f0.1   null<1>:d     r10.0<1;1,0>:d    0:w               {I@1}
(~f0.1) cmp (16|M0)   (lt)f0.1   null<1>:d     r10.0<1;1,0>:d    0:w              
(f0.1)  goto (16|M0)                         L10728                  L10728                
L10600:
        cmp (16|M0)   (eq)f0.1   null<1>:d     r66.0<1;1,0>:d    39:w              
(f0.1)  cmp (16|M0)   (eq)f0.1   null<1>:d     r74.0<1;1,0>:d    0:w              
(~f0.1) goto (16|M0)                         L10728                  L10784                
L10648:
        shr (16|M0)              r70.0<1>:ud   r42.0<1;1,0>:ud   1:w              
        mov (16|M0)              r124.0<1>:d   0:w                              
        mov (16|M0)              r16.0<1>:d    0:w                              
        mov (16|M0)              r10.0<1>:f    r70.0<1;1,0>:f                   {Compacted,I@3}
        mov (16|M0)              r70.0<1>:f    r42.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L10728                  L11888                
L10728:
        join (16|M0)                         L10784                                
L10744:
        cmp (16|M0)   (eq)f0.0   null<1>:d     r66.0<1;1,0>:d    38:w               {Compacted}
(f0.0)  cmp (16|M0)   (eq)f0.0   null<1>:d     r74.0<1;1,0>:d    0:w              
(f0.0)  goto (16|M0)                         L10784                  L11800                
L10784:
        join (16|M0)                         L11800                                
L10800:
        add (16|M0)              r2.0<1>:d     -r66.0<1;1,0>:d   39:w               {Compacted}
        and (16|M0)   (ne)f0.1   r116.0<1>:d   r2.0<1;1,0>:d     63:w               {I@1}
        add (16|M0)              r104.0<1>:d   -r66.0<1;1,0>:d   40:w               {Compacted}
(f0.1)  goto (16|M0)                         L10872                  L10872                
L10848:
        mov (16|M0)              r94.0<1>:f    r42.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L10872                  L10984                
L10872:
        join (16|M0)                         L10984                                
L10888:
        cmp (16|M0)   (lt)f0.0   null<1>:d     r116.0<1;1,0>:ud  0x20:uw              {I@5}
(~f0.0) add (16|M0)              r2.0<1>:d     r116.0<1;1,0>:d   -32:w              
(~f0.0) shr (16|M0)              r70.0<1>:ud   r40.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f0.0)  add (16|M0)              r2.0<1>:d     -r116.0<1;1,0>:d  32:w               {Compacted}
(f0.0)  shr (16|M0)              r8.0<1>:ud    r42.0<1;1,0>:ud   r116.0<1;1,0>:d 
(f0.0)  shl (16|M0)              r2.0<1>:d     r40.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f0.0)  or (16|M0)               r70.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
        mov (16|M0)              r94.0<1>:f    r70.0<1;1,0>:f                   {Compacted,I@1}
L10984:
        join (16|M0)                         L11800                                
L11000:
        add (16|M0)              r72.0<1>:d    -r66.0<1;1,0>:d   38:w               {Compacted}
        and (16|M0)   (ne)f1.1   r120.0<1>:d   r72.0<1;1,0>:d    63:w               {I@1}
(f1.1)  goto (16|M0)                         L11064                  L11064                
L11040:
        mov (16|M0)              r70.0<1>:f    r42.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L11064                  L11168                
L11064:
        join (16|M0)                         L11168                                
L11080:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r120.0<1;1,0>:ud  0x20:uw              {I@4}
(~f1.0) add (16|M0)              r2.0<1>:d     r120.0<1;1,0>:d   -32:w              
(~f1.0) shr (16|M0)              r70.0<1>:ud   r40.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.0)  add (16|M0)              r2.0<1>:d     -r120.0<1;1,0>:d  32:w               {Compacted}
(f1.0)  shr (16|M0)              r8.0<1>:ud    r42.0<1;1,0>:ud   r120.0<1;1,0>:d 
(f1.0)  shl (16|M0)              r2.0<1>:d     r40.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.0)  or (16|M0)               r70.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
L11168:
        join (16|M0)                         L11800                                
L11184:
        and (16|M0)   (ne)f0.1   r92.0<1>:d    r72.0<1;1,0>:d    63:w              
        and (16|M0)              r16.0<1>:d    r70.0<1;1,0>:d    1:w               {Compacted,I@3}
(f0.1)  goto (16|M0)                         L11272                  L11272                
L11224:
        mov (16|M0)              r96.0<1>:d    -1:w                              
        mov (16|M0)              r102.0<1>:d   -1:w                              
        goto (16|M0)                         L11272                  L11456                
L11272:
        join (16|M0)                         L11456                                
L11288:
        cmp (16|M0)   (lt)f0.0   null<1>:d     r92.0<1;1,0>:ud   0x20:uw              {I@7}
(f0.0)  goto (16|M0)                         L11392                  L11392                
L11320:
        add (16|M0)              r2.0<1>:d     r92.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r5.8<1>:hf    -qnan(0x1FF):hf                             
        mov (16|M0)              r96.0<1>:d    0:w                              
        shl (16|M0)              r102.0<1>:d   r5.8<0;1,0>:w     r2.0<1;1,0>:d    {A@1}
        goto (16|M0)                         L11392                  L11456                
L11392:
        join (16|M0)                         L11456                                
L11408:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (16|M0)              r102.0<1>:d   -1:w                              
        shl (16|M0)              r96.0<1>:d    r2.0<0;1,0>:w     r92.0<1;1,0>:d   {F@1}
L11456:
        join (16|M0)                         L11800                                
L11472:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r96.0<1;0>:ud     r6.3<0;0>:ud      r42.0<1>:ud      {I@2} // (s0^s1)&s2
        cmp (16|M0)   (ne)f1.1   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
        bfn.0x60 (16|M0)         r8.0<1>:ud    r102.0<1;0>:ud    r6.3<0;0>:ud      r40.0<1>:ud      // (s0^s1)&s2
(~f1.1) cmp (16|M0)   (ne)f1.1   null<1>:d     r8.0<1;1,0>:d     0:w               {I@1}
(W)     mov (1|M0)               r5.8<1>:hf    -qnan(0x1FF):hf                             
(f1.1)  sel (16|M0)              r10.0<1>:d    r5.8<0;1,0>:w     0:w               {F@1}
        and (16|M0)   (ne)f1.1   r118.0<1>:d   r104.0<1;1,0>:d   63:w              
        mov (16|M0)              r124.0<1>:d   -r10.0<1;1,0>:d                  {I@2}
(f1.1)  goto (16|M0)                         L11640                  L11640                
L11616:
        mov (16|M0)              r70.0<1>:f    r42.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L11640                  L11744                
L11640:
        join (16|M0)                         L11744                                
L11656:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r118.0<1;1,0>:ud  0x20:uw              {I@5}
(~f1.0) add (16|M0)              r2.0<1>:d     r118.0<1;1,0>:d   -32:w              
(~f1.0) shr (16|M0)              r70.0<1>:ud   r40.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.0)  add (16|M0)              r2.0<1>:d     -r118.0<1;1,0>:d  32:w               {Compacted}
(f1.0)  shr (16|M0)              r8.0<1>:ud    r42.0<1;1,0>:ud   r118.0<1;1,0>:d 
(f1.0)  shl (16|M0)              r2.0<1>:d     r40.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.0)  or (16|M0)               r70.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
L11744:
        join (16|M0)                         L11800                                
L11760:
        mov (16|M0)              r10.0<1>:f    r70.0<1;1,0>:f                   {Compacted,I@2}
        mov (16|M0)              r70.0<1>:d    r94.0<1;1,0>:d                   {F@1}
        goto (16|M0)                         L11800                  L11888                
L11800:
        join (16|M0)                         L11888                                
L11816:
        shr (16|M0)              r70.0<1>:ud   r42.0<1;1,0>:ud   2:w              
        mov (16|M0)              r124.0<1>:d   0:w                              
        mov (16|M0)              r16.0<1>:d    0:w                              
        mov (16|M0)              r10.0<1>:f    r70.0<1;1,0>:f                   {Compacted,I@3}
        shr (16|M0)              r70.0<1>:ud   r42.0<1;1,0>:ud   1:w               {F@1}
L11888:
        join (16|M0)                         L12416                                
L11904:
        shl (16|M0)              r2.0<1>:d     r70.0<1;1,0>:d    2:w               {Compacted,I@2}
        shl (16|M0)              r8.0<1>:d     r16.0<1;1,0>:d    1:w               {Compacted}
        and (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     4:w               {Compacted,I@2}
        bfn.0xFE (16|M0)         r62.0<1>:ud   r2.0<1;0>:ud      r8.0<1;0>:ud      r124.0<1>:ud     {I@1} // s0|s1|s2
        cmp (16|M0)   (eq)f0.1   null<1>:d     r62.0<1;1,0>:d    0:w               {I@1}
        and (16|M0)              r98.0<1>:d    r10.0<1;1,0>:d    8388607:d              
(~f0.1) goto (16|M0)                         L12024                  L12024                
L11992:
        mov (16|M0)              r52.0<1>:d    0:w                              
        goto (16|M0)                         L12024                  L12184                
L12024:
        join (16|M0)                         L12184                                
L12040:
        cmp (16|M0)   (gt)f0.0   null<1>:d     r62.0<1;1,0>:ud   0x4:uw             
(~f0.0) goto (16|M0)                         L12104                  L12104                
L12072:
        mov (16|M0)              r52.0<1>:d    1:w                              
        goto (16|M0)                         L12104                  L12184                
L12104:
        join (16|M0)                         L12184                                
L12120:
        and (16|M0)   (ne)f1.0   null<1>:d     r10.0<1;1,0>:d    1:w              
(W)     mov (1|M0)               r2.0<1>:hf    0x1:hf                             
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r62.0<1;1,0>:d    4:w              
(f1.0)  sel (16|M0)              r52.0<1>:d    r2.0<0;1,0>:w     0:w               {F@1}
L12184:
        join (16|M0)                         L12416                                
L12200:
        add (16|M0)              r56.0<1>:d    r98.0<1;1,0>:d    r52.0<1;1,0>:d   {Compacted,I@2}
        cmp (16|M0)   (gt)f1.0   null<1>:d     r56.0<1;1,0>:ud   0x7FFFFF:ud              {I@1}
        add3 (16|M0)             r2.0<1>:d     r50.0<1;0>:d      r54.0<1;0>:d      -45:w              
(f1.0)  sel (16|M0)              r42.0<1>:d    r2.0<1;1,0>:d     r60.0<1;1,0>:d   {Compacted,I@1}
        cmp (16|M0)   (eq)f1.1   null<1>:d     r42.0<1;1,0>:d    255:w               {I@1}
(f1.1)  goto (16|M0)                         L12352                  L12352                
L12280:
(~f1.0) sel (16|M0)              r2.0<1>:d     r56.0<1;1,0>:d    0:w              
        and (16|M0)              r8.0<1>:d     r38.0<1;1,0>:d    -2147483648:d              
        shl (16|M0)              r10.0<1>:d    r42.0<1;1,0>:d    23:w               {Compacted}
        bfn.0xFE (16|M0)         r86.0<1>:ud   r8.0<1;0>:ud      r10.0<1;0>:ud     r2.0<1>:ud       {I@1} // s0|s1|s2
        goto (16|M0)                         L12352                  L12944                
L12352:
        join (16|M0)                         L12416                                
L12368:
        cmp (16|M0)   (gt)f0.1   null<1>:d     r38.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r2.0<1>:f     inf:f                               {Compacted,I@4}
(f0.1)  sel (16|M0)              r86.0<1>:f    r2.0<0;1,0>:f     -inf:f               {Compacted,F@1}
        goto (16|M0)                         L12416                  L12944                
L12416:
        join (16|M0)                         L12728                                
L12432:
        and (16|M0)   (ne)f1.0   r22.0<1>:d    r54.0<1;1,0>:d    63:w              
(f1.0)  goto (16|M0)                         L12496                  L12496                
L12464:
        mov (16|M0)              r48.0<1>:d    -1:w                              
        goto (16|M0)                         L12496                  L12624                
L12496:
        join (16|M0)                         L12624                                
L12512:
        cmp (16|M0)   (lt)f0.1   null<1>:d     r22.0<1;1,0>:ud   0x20:uw              {A@1}
(f0.1)  goto (16|M0)                         L12576                  L12576                
L12544:
        mov (16|M0)              r48.0<1>:d    0:w                              
        goto (16|M0)                         L12576                  L12624                
L12576:
        join (16|M0)                         L12624                                
L12592:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                             
        shl (16|M0)              r48.0<1>:d    r2.0<0;1,0>:w     r22.0<1;1,0>:d   {F@1}
L12624:
        join (16|M0)                         L12728                                
L12640:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r48.0<1;0>:ud     r6.3<0;0>:ud      r42.0<1>:ud      {I@2} // (s0^s1)&s2
        add (16|M0)              r8.0<1>:d     -r54.0<1;1,0>:d   23:w               {Compacted}
        and (16|M0)              r10.0<1>:d    r38.0<1;1,0>:d    -2147483648:d              
        shl (16|M0)              r12.0<1>:d    r60.0<1;1,0>:d    23:w               {Compacted}
        shl (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     r8.0<1;1,0>:d    {Compacted,I@3}
        bfn.0xFE (16|M0)         r86.0<1>:ud   r10.0<1;0>:ud     r12.0<1;0>:ud     r2.0<1>:ud       {I@1} // s0|s1|s2
        goto (16|M0)                         L12728                  L12944                
L12728:
        join (16|M0)                         L12784                                
L12744:
        cmp (16|M0)   (gt)f0.0   null<1>:d     r38.0<1;1,0>:d    -1:w               {Compacted}
(W)     mov (1|M0)               r2.0<1>:f     inf:f                               {Compacted,I@4}
(f0.0)  sel (16|M0)              r86.0<1>:f    r2.0<0;1,0>:f     -inf:f               {Compacted,F@1}
        goto (16|M0)                         L12784                  L12944                
L12784:
        join (16|M0)                         L12848                                
L12800:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r38.0<1;1,0>:d    0:w              
(W)     mov (1|M0)               r2.0<1>:f     -0.0:f                               {Compacted}
(f1.1)  sel (16|M0)              r86.0<1>:f    r2.0<0;1,0>:f     0.0:f               {Compacted,F@1}
        goto (16|M0)                         L12848                  L12944                
L12848:
        join (16|M0)                         L12912                                
L12864:
        cmp (16|M0)   (gt)f1.0   null<1>:d     r38.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r2.0<1>:f     inf:f                               {Compacted}
(f1.0)  sel (16|M0)              r86.0<1>:f    r2.0<0;1,0>:f     -inf:f               {Compacted,F@1}
        goto (16|M0)                         L12912                  L12944                
L12912:
        join (16|M0)                         L12944                                
L12928:
        bfn.0xF8 (16|M0)         r86.0<1>:ud   r38.0<1;0>:ud     r6.5<0;0>:ud      r6.4<0>:ud       {F@1} // s0&s1|s2
L12944:
        join (16|M0)                         L13336                                
L12960:
        cmp (16|M0)   (lt)f0.0   null<1>:f     r32.0<1;1,0>:f    0.0:f               {Compacted,I@7}
        shl (16|M0)              r8.0<1>:d     r30.0<1;1,0>:d    1:w               {Compacted}
        addc (8|M0)              r14.0<1>:ud   r8.0<1;1,0>:ud    r21.0<0;1,0>:ud  {AccWrEn,Compacted,I@1}
        shr (16|M0)              r10.0<1>:ud   r30.0<1;1,0>:ud   31:w              
        shl (16|M0)              r12.0<1>:d    r28.0<1;1,0>:d    1:w               {Compacted}
(f0.0)  sel (16|M0)              r2.0<1>:f     -r86.0<1;1,0>:f   r86.0<1;1,0>:f   {Compacted}
        mov (8|M0)               r16.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        addc (8|M8)              r15.0<1>:ud   r9.0<1;1,0>:ud    r21.0<0;1,0>:ud  {AccWrEn}
        or (16|M0)               r12.0<1>:d    r12.0<1;1,0>:d    r10.0<1;1,0>:d   {Compacted,I@3}
        mov (8|M0)               r7.0<1>:hf    r2.0<1;1,0>:f                    {F@1}
        mov (8|M8)               r7.8<1>:hf    r3.0<1;1,0>:f                   
        mov (8|M8)               r22.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        add3 (8|M0)              r17.1<2>:ud   r16.0<1;0>:ud     r12.0<1;0>:ud     r21.1<0>:ud      {I@2}
        mov (16|M0)              r2.0<1>:ud    r7.0<1;1,0>:uw                   {A@1}
        add3 (8|M8)              r19.1<2>:ud   r22.0<1;0>:ud     r13.0<1;0>:ud     r21.1<0>:ud      {I@3}
        mov (8|M0)               r17.0<2>:d    r14.0<1;1,0>:d                  
        addc (8|M0)              r16.0<1>:ud   r30.0<1;1,0>:ud   r6.0<0;1,0>:ud   {AccWrEn,Compacted}
        mov (8|M8)               r19.0<2>:d    r15.0<1;1,0>:d                  
        add (8|M0)               r102.0<1>:ud  acc0.0<1;1,0>:ud  r28.0<1;1,0>:ud 
        send.ugm (16|M0)         null     r17     r2:2    0x0            0x080E0B84           {A@2,$4} // wr:4+2, rd:0; store.ugm.d16u32.a64.wb.wb
        addc (8|M8)              r17.0<1>:ud   r31.0<1;1,0>:ud   r6.0<0;1,0>:ud   {AccWrEn,$4.src}
        cmp (16|M0)   (lt)f1.0   null<1>:d     r16.0<1;1,0>:ud   r4.6<0;1,0>:ud   {I@1}
        add (8|M8)               r103.0<1>:ud  acc0.0<1;1,0>:ud  r29.0<1;1,0>:ud 
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r102.0<1;1,0>:d   r4.7<0;1,0>:d    {I@1}
(~f1.0) cmp (16|M0)   (lt)f1.0   null<1>:d     r102.0<1;1,0>:ud  r4.7<0;1,0>:ud  
(~f1.0) goto (16|M0)                         L13336                  L13336                
L13304:
(f1.0)  sel (16|M0)              r30.0<1>:d    r16.0<1;1,0>:d    r26.0<1;1,0>:d   {Compacted}
(f1.0)  sel (16|M0)              r28.0<1>:d    r102.0<1;1,0>:d   r24.0<1;1,0>:d   {Compacted}
(W)     jmpi                                 L616                                
L13336:
        join (16|M0)                         L13352                                
L13352:
(W)     mov (8|M0)               r127.0<1>:f   r36.0<1;1,0>:f                   {Compacted,$2.src}
(W)     send.gtwy (1|M0)         null     r127    null:0  0x0            0x02000010           {EOT,A@1} // wr:1+0, rd:0; end of thread
L13376:
        nop                    
(W)     mov (16|M0)              null<1>:ud    0x9E09665A:ud                             
(W)     mov (16|M0)              null<1>:ud    0xA6E09A48:ud                             
(W)     mov (16|M0)              null<1>:ud    0x0:ud                             
(W)     mov (16|M0)              null<1>:ud    0x35:ud                             
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
        illegal                
