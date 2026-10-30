L0:
(W)     mov (8|M0)               r127.0<1>:ud  0x0:ud                             
(W)     and (1|M0)               r127.2<1>:ud  r0.0<0;1,0>:ud    0xFFFFFFC0:ud             
(W)     and (1|M0)               r127.0<1>:uw  r0.4<0;1,0>:uw    0xFF:uw             
(W)     add (1|M0)               r127.2<1>:ud  r127.2<0;1,0>:ud  0x20:ud              {I@2}
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
(W)     send.dc0 (8|M0)          r5       r127    null:0  0x0            0x021842FD           {A@1,$2} // wr:1h+0, rd:1; oword aligned block read x2
(W)     mov (8|M0)               r20.0<1>:ud   r0.0<1;1,0>:ud                  
(W)     or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x4C0:uw              {A@1}
(W)     mul (1|M0)               acc0.0<1>:d   r4.3<0;1,0>:d     r20.2<0;1,0>:uw  {A@1}
(W)     mach (1|M0)              r2.0<1>:d     r4.3<0;1,0>:d     r20.1<0;1,0>:d   {$0.dst}
        sync.nop                             null                             {Compacted,$2.dst}
(W)     mov (1|M0)               a0.0<1>:ud    r5.6<0;1,0>:d                    {A@1}
        add3 (16|M0)             r12.0<1>:d    r2.0<0;0>:d       r1.0<1;0>:uw      r4.0<0>:d        {I@2}
        shl (16|M0)              r6.0<1>:d     r12.0<1;1,0>:d    2:w               {Compacted,I@1}
        send.ugm (16|M0)         r14      r6      null:0  a0.0        0x24280500           {ExBSO,A@1,$3} // wr:2+0, rd:2; load.ugm.d32.a32.ca.ca.bss[a0.0]
(W)     mov (1|M0)               r5.2<1>:f     -0.0:f                               {Compacted}
(W)     mov (1|M0)               r5.1<1>:f     inf:f                               {Compacted}
(W)     mov (1|M0)               r5.0<1>:d     -1:w                              
        and (16|M0)              r8.0<1>:d     r14.0<1;1,0>:d    2147483647:d               {$3.dst}
        sel (16|M0)   (lt)f0.0   r24.0<1>:f    r8.0<1;1,0>:f     448.0:f               {Compacted,I@1}
        shr (16|M0)              r22.0<1>:ud   r24.0<1;1,0>:ud   23:w               {F@1}
        and (16|M0)   (ne)f0.0   r62.0<1>:d    r24.0<1;1,0>:d    8388607:d              
        and (16|M0)              r56.0<1>:d    r22.0<1;1,0>:d    255:w               {Compacted,I@2}
(f0.0)  cmp (16|M0)   (eq)f0.0   null<1>:d     r56.0<1;1,0>:d    255:w               {I@1}
        sel (16|M0)   (ge)f0.0   r10.0<1>:ud   r56.0<1;1,0>:ud   0x79:uw             
        shl (16|M0)              r16.0<1>:d    r10.0<1;1,0>:d    23:w               {Compacted,I@1}
(~f0.0) goto (16|M0)                         L568                  L568                
L536:
        mov (16|M0)              r52.0<1>:ud   0x7FC00000:ud                             
        goto (16|M0)                         L568                  L6464                
L568:
        join (16|M0)                         L6464                                
L584:
        cmp (16|M0)   (eq)f1.1   null<1>:d     r62.0<1;1,0>:d    0:w              
        add (16|M0)              r122.0<1>:d   -r16.0<1;1,0>:d   -2139095040:d               {I@6}
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r56.0<1;1,0>:d    255:w              
        xor (16|M0)              r18.0<1>:d    r122.0<1;1,0>:d   r24.0<1;1,0>:d   {Compacted,I@2}
(f1.1)  goto (16|M0)                         L6432                  L6432                
L656:
        or (16|M0)    (eq)f0.1   null<1>:d     r56.0<1;1,0>:d    r62.0<1;1,0>:d  
(~f0.1) goto (16|M0)                         L720                  L720                
L688:
        mov (16|M0)              r52.0<1>:ud   0x0:ud                             
        goto (16|M0)                         L720                  L6464                
L720:
        join (16|M0)                         L6432                                
L736:
        cmp (16|M0)   (eq)f0.1   null<1>:d     r56.0<1;1,0>:d    0:w              
        shr (16|M0)              r106.0<1>:ud  r122.0<1;1,0>:ud  23:w              
        add (16|M0)              r28.0<1>:d    r56.0<1;1,0>:d    -127:w               {Compacted}
(f0.1)  mov (16|M0)              r28.0<1>:d    -126:w                              
        add (16|M0)              r34.0<1>:d    r106.0<1;1,0>:d   r28.0<1;1,0>:d   {Compacted,I@1}
        cmp (16|M0)   (gt)f0.0   null<1>:d     r34.0<1;1,0>:d    254:w               {Compacted,I@1}
(f0.0)  goto (16|M0)                         L6368                  L6368                
L824:
        or (16|M0)    (eq)f1.1   null<4>:b     r22.0<1;1,0>:d    r106.0<1;1,0>:d 
(f1.1)  goto (16|M0)                         L6304                  L6304                
L856:
(W)     mov (1|M0)               r2.0<1>:hf    0.0:hf                             
(W)     mov (1|M0)               r5.7<1>:d     0:w                              
(f0.1)  sel (16|M0)              r6.0<1>:d     r2.0<0;1,0>:w     8388608:d               {F@1}
        or (16|M0)               r6.0<1>:d     r6.0<1;1,0>:d     r62.0<1;1,0>:d   {Compacted,I@1}
        shl (16|M0)              r26.0<1>:d    r6.0<1;1,0>:d     23:w               {Compacted,I@1}
        shr (16|M0)              r30.0<1>:ud   r6.0<1;1,0>:ud    9:w              
(W)     mov (1|M0)               r5.6<1>:f     -0.0:f                               {Compacted}
(W)     mov (2|M0)               r21.0<1>:d    0:w                              
L960:
(W)     shl (1|M0)               r2.0<1>:d     r5.6<0;1,0>:d     31:w               {Compacted,F@1}
(W)     shr (1|M0)               r2.1<1>:ud    r5.7<0;1,0>:ud    1:w              
(W)     cmp (16|M0)   (gt)f1.1   null<1>:d     r21.0<0;1,0>:ud   0x3E:uw              {I@3}
(W)     or (1|M0)                r5.7<1>:d     r2.1<0;1,0>:d     r2.0<0;1,0>:d    {I@2}
        bfn.0xE0 (16|M0)         r6.0<1>:ud    r2.1<0;0>:ud      r2.0<0;0>:ud      r26.0<1>:ud      // (s0|s1)&s2
(W)     shr (1|M0)               r5.3<1>:ud    r5.6<0;1,0>:ud    1:w              
(W&f1.1) cmp (16|M0)  (eq)f1.1   null<1>:d     r21.1<0;1,0>:d    0:w              
        cmp (16|M0)   (eq)f0.1   null<1>:d     r6.0<1;1,0>:d     r5.7<0;1,0>:d    {I@3}
        and (16|M0)              r8.0<1>:d     r5.3<0;1,0>:d     r30.0<1;1,0>:d   {Compacted,I@3}
(W&~f1.1) cmp (16|M0) (gt)f1.1   null<1>:d     r21.1<0;1,0>:ud   0x0:uw             
(f0.1)  cmp (16|M0)   (eq)f0.1   null<1>:d     r8.0<1;1,0>:d     r5.3<0;1,0>:d    {I@2}
(W)     mov (1|M0)               r4.12<1>:hf   0x1:hf                             
(W)     addc (1|M0)              r22.0<1>:ud   r21.0<0;1,0>:ud   0x1:ud              {AccWrEn}
(f1.1)  sel (16|M0)              r10.0<1>:uw   r4.12<0;1,0>:uw   0x0:uw              {Compacted,F@1}
(f0.1)  sel (16|M0)              acc2.0<1>:uw  r4.12<0;1,0>:uw   0x0:uw             
(W)     mov (1|M0)               r3.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$1.dst}
        or (16|M0)    (ne)f1.1   null<1>:uw    r10.0<1;1,0>:uw   acc2.0<1;1,0>:uw {I@3}
(W)     add (1|M0)               r21.2<1>:ud   r3.0<0;1,0>:ud    r21.1<0;1,0>:ud  {I@2}
        mov (16|M0)              r64.0<1>:f    r21.0<0;1,0>:f                   {Compacted}
        mov (16|M0)              r62.0<1>:d    r21.1<0;1,0>:d                  
        mov (16|M0)              r46.0<1>:f    r22.0<0;1,0>:f                   {Compacted}
        mov (16|M0)              r74.0<1>:d    r21.2<0;1,0>:d                   {I@2}
(f1.1)  goto (16|M0)                         L1336                  L1336                
L1280:
(W)     mov (1|M0)               r5.6<1>:d     r5.3<0;1,0>:d                   
(W)     mov (1|M0)               r21.0<1>:f    r22.0<0;1,0>:f                   {Compacted}
(W)     mov (1|M0)               r21.1<1>:d    r21.2<0;1,0>:d                  
(W)     jmpi                                 L960                                
L1336:
        join (16|M0)                         L6304                                
L1352:
(W)     mov (1|M0)               r2.0<1>:f     8.68805e-44:f                              
(W)     mov (1|M0)               r3.0<1>:hf    0.0:hf                             
        subb (8|M0)              r36.0<1>:ud   r2.0<0;1,0>:ud    r64.0<1;1,0>:ud  {AccWrEn,Compacted,F@2}
        add3 (8|M0)              r40.0<1>:ud   -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r62.0<1>:ud     {A@1}
        subb (8|M8)              r37.0<1>:ud   r2.0<0;1,0>:ud    r65.0<1;1,0>:ud  {AccWrEn}
        add3 (16|M0)             r108.0<1>:d   r34.0<1;0>:d      r36.0<1;0>:d      -173:w               {I@1}
        cmp (16|M0)   (gt)f1.0   null<1>:d     r108.0<1;1,0>:d   127:w               {I@1}
        add3 (8|M8)              r41.0<1>:ud   -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r63.0<1>:ud    
        add3 (16|M0)             r38.0<1>:d    r106.0<1;0>:d     r28.0<1;0>:d      r36.0<1>:d      
(f1.0)  goto (16|M0)                         L6248                  L6248                
L1504:
        cmp (16|M0)   (gt)f0.1   null<1>:d     r108.0<1;1,0>:d   -127:w              
(f0.1)  goto (16|M0)                         L3944                  L3944                
L1536:
        cmp (16|M0)   (lt)f0.0   null<1>:d     r108.0<1;1,0>:ud  0xFFFFFF6B:ud             
(f0.0)  goto (16|M0)                         L3448                  L3448                
L1568:
(W)     mov (1|M0)               r2.0<1>:f     8.82818e-44:f                              
(W)     mov (1|M0)               r3.0<1>:hf    0.0:hf                              {I@7}
        subb (8|M0)              r68.0<1>:ud   r2.0<0;1,0>:ud    r64.0<1;1,0>:ud  {AccWrEn,Compacted,F@2}
        add3 (16|M0)             r92.0<1>:d    r34.0<1;0>:d      r36.0<1;0>:d      -23:w              
        add3 (8|M0)              r6.0<1>:ud    -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r62.0<1>:ud     {F@1}
        subb (8|M8)              r69.0<1>:ud   r2.0<0;1,0>:ud    r65.0<1;1,0>:ud  {AccWrEn}
        cmp (16|M0)   (gt)f0.0   null<1>:d     r68.0<1;1,0>:ud   r92.0<1;1,0>:ud  {I@1}
        add3 (8|M8)              r7.0<1>:ud    -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r63.0<1>:ud    
(f0.0)  cmp (16|M0)   (eq)f0.0   null<1>:d     r6.0<1;1,0>:d     0:w               {I@1}
(~f0.0) cmp (16|M0)   (gt)f0.0   null<1>:d     r6.0<1;1,0>:ud    0x0:uw             
(f0.0)  goto (16|M0)                         L1792                  L1792                
L1736:
        add3 (16|M0)             r2.0<1>:d     r38.0<1;0>:d      -r68.0<1;0>:d     -23:w              
        mov (16|M0)              r118.0<1>:d   0:w                              
        shl (16|M0)              r120.0<1>:d   r26.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
        goto (16|M0)                         L1792                  L3384                
L1792:
        join (16|M0)                         L3384                                
L1808:
        add3 (16|M0)             r114.0<1>:d   r68.0<1;0>:d      -r38.0<1;0>:d     23:w              
        cmp (16|M0)   (lt)f1.1   null<1>:d     r114.0<1;1,0>:d   2:w               {I@1}
(f1.1)  goto (16|M0)                         L1960                  L1960                
L1856:
        cmp (16|M0)   (eq)f1.0   null<1>:d     r114.0<1;1,0>:d   2:w              
(~f1.0) goto (16|M0)                         L1960                  L2064                
L1888:
        shr (16|M0)              r48.0<1>:ud   r26.0<1;1,0>:ud   1:w              
        mov (16|M0)              r88.0<1>:d    0:w                              
        mov (16|M0)              r100.0<1>:d   0:w                              
        mov (16|M0)              r84.0<1>:f    r48.0<1;1,0>:f                   {Compacted,I@3}
        goto (16|M0)                         L1960                  L2864                
L1960:
        join (16|M0)                         L2064                                
L1976:
        cmp (16|M0)   (eq)f0.1   null<1>:d     r114.0<1;1,0>:d   1:w              
(~f0.1) goto (16|M0)                         L2064                  L2064                
L2008:
        mov (16|M0)              r88.0<1>:d    0:w                              
        mov (16|M0)              r100.0<1>:d   0:w                              
        mov (16|M0)              r84.0<1>:f    r26.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L2064                  L2864                
L2064:
        join (16|M0)                         L2864                                
L2080:
        add3 (16|M0)             r2.0<1>:d     r68.0<1;0>:d      -r92.0<1;0>:d     -1:w              
        and (16|M0)   (ne)f0.0   r86.0<1>:d    r2.0<1;1,0>:d     63:w               {Compacted,I@1}
(f0.0)  goto (16|M0)                         L2144                  L2144                
L2120:
        mov (16|M0)              r46.0<1>:f    r26.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L2144                  L2256                
L2144:
        join (16|M0)                         L2256                                
L2160:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r86.0<1;1,0>:ud   0x20:uw              {I@4}
(~f1.1) add (16|M0)              r2.0<1>:d     r86.0<1;1,0>:d    -32:w              
(~f1.1) shr (16|M0)              r48.0<1>:ud   r30.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.1)  add (16|M0)              r2.0<1>:d     -r86.0<1;1,0>:d   32:w               {Compacted}
(f1.1)  shr (16|M0)              r6.0<1>:ud    r26.0<1;1,0>:ud   r86.0<1;1,0>:d  
(f1.1)  shl (16|M0)              r2.0<1>:d     r30.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.1)  or (16|M0)               r48.0<1>:d    r6.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
        mov (16|M0)              r46.0<1>:f    r48.0<1;1,0>:f                   {Compacted,I@1}
L2256:
        join (16|M0)                         L2864                                
L2272:
        add3 (16|M0)             r24.0<1>:d    r68.0<1;0>:d      -r92.0<1;0>:d     -2:w              
        and (16|M0)   (ne)f1.0   r84.0<1>:d    r24.0<1;1,0>:d    63:w               {A@1}
(f1.0)  goto (16|M0)                         L2344                  L2344                
L2320:
        mov (16|M0)              r48.0<1>:f    r26.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L2344                  L2448                
L2344:
        join (16|M0)                         L2448                                
L2360:
        cmp (16|M0)   (lt)f0.1   null<1>:d     r84.0<1;1,0>:ud   0x20:uw              {I@4}
(~f0.1) add (16|M0)              r2.0<1>:d     r84.0<1;1,0>:d    -32:w              
(~f0.1) shr (16|M0)              r48.0<1>:ud   r30.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f0.1)  add (16|M0)              r2.0<1>:d     -r84.0<1;1,0>:d   32:w               {Compacted}
(f0.1)  shr (16|M0)              r6.0<1>:ud    r26.0<1;1,0>:ud   r84.0<1;1,0>:d  
(f0.1)  shl (16|M0)              r2.0<1>:d     r30.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f0.1)  or (16|M0)               r48.0<1>:d    r6.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
L2448:
        join (16|M0)                         L2864                                
L2464:
        and (16|M0)              r100.0<1>:d   r48.0<1;1,0>:d    1:w               {Compacted,I@2}
        and (16|M0)   (ne)f0.0   r48.0<1>:d    r24.0<1;1,0>:d    63:w               {Compacted}
(f0.0)  goto (16|M0)                         L2544                  L2544                
L2496:
        mov (16|M0)              r52.0<1>:d    -1:w                              
        mov (16|M0)              r56.0<1>:d    -1:w                              
        goto (16|M0)                         L2544                  L2728                
L2544:
        join (16|M0)                         L2728                                
L2560:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r48.0<1;1,0>:ud   0x20:uw              {I@6}
(f1.1)  goto (16|M0)                         L2664                  L2664                
L2592:
        add (16|M0)              r2.0<1>:d     r48.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r4.12<1>:hf   -qnan(0x1FF):hf                             
        mov (16|M0)              r52.0<1>:d    0:w                              
        shl (16|M0)              r56.0<1>:d    r4.12<0;1,0>:w    r2.0<1;1,0>:d    {A@1}
        goto (16|M0)                         L2664                  L2728                
L2664:
        join (16|M0)                         L2728                                
L2680:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (16|M0)              r56.0<1>:d    -1:w                              
        shl (16|M0)              r52.0<1>:d    r2.0<0;1,0>:w     r48.0<1;1,0>:d   {F@1}
L2728:
        join (16|M0)                         L2864                                
L2744:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r52.0<1;0>:ud     r5.0<0;0>:ud      r26.0<1>:ud      {I@2} // (s0^s1)&s2
        cmp (16|M0)   (ne)f1.0   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
        bfn.0x60 (16|M0)         r6.0<1>:ud    r56.0<1;0>:ud     r5.0<0;0>:ud      r30.0<1>:ud      // (s0^s1)&s2
(~f1.0) cmp (16|M0)   (ne)f1.0   null<1>:d     r6.0<1;1,0>:d     0:w               {I@1}
(W)     mov (1|M0)               r4.12<1>:hf   -qnan(0x1FF):hf                             
        mov (16|M0)              r84.0<1>:f    r46.0<1;1,0>:f                   {Compacted}
(f1.0)  sel (16|M0)              r8.0<1>:d     r4.12<0;1,0>:w    0:w               {F@2}
        mov (16|M0)              r88.0<1>:d    -r8.0<1;1,0>:d                   {I@1}
L2864:
        join (16|M0)                         L3384                                
L2880:
        and (16|M0)   (ne)f1.0   r82.0<1>:d    r114.0<1;1,0>:d   63:w              
(f1.0)  goto (16|M0)                         L2936                  L2936                
L2912:
        mov (16|M0)              r48.0<1>:f    r26.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L2936                  L3040                
L2936:
        join (16|M0)                         L3040                                
L2952:
        cmp (16|M0)   (lt)f0.1   null<1>:d     r82.0<1;1,0>:ud   0x20:uw              {I@4}
(~f0.1) add (16|M0)              r2.0<1>:d     r82.0<1;1,0>:d    -32:w              
(~f0.1) shr (16|M0)              r48.0<1>:ud   r30.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f0.1)  add (16|M0)              r2.0<1>:d     -r82.0<1;1,0>:d   32:w               {Compacted}
(f0.1)  shr (16|M0)              r6.0<1>:ud    r26.0<1;1,0>:ud   r82.0<1;1,0>:d  
(f0.1)  shl (16|M0)              r2.0<1>:d     r30.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f0.1)  or (16|M0)               r48.0<1>:d    r6.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
L3040:
        join (16|M0)                         L3384                                
L3056:
        shl (16|M0)              r2.0<1>:d     r84.0<1;1,0>:d    2:w               {Compacted}
        shl (16|M0)              r6.0<1>:d     r100.0<1;1,0>:d   1:w               {Compacted}
        and (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     4:w               {Compacted,I@2}
        bfn.0xFE (16|M0)         r112.0<1>:ud  r2.0<1;0>:ud      r6.0<1;0>:ud      r88.0<1>:ud      {I@1} // s0|s1|s2
        cmp (16|M0)   (eq)f0.0   null<1>:d     r112.0<1;1,0>:d   0:w               {Compacted,I@1}
(~f0.0) goto (16|M0)                         L3152                  L3152                
L3120:
        mov (16|M0)              r118.0<1>:d   0:w                              
        goto (16|M0)                         L3152                  L3312                
L3152:
        join (16|M0)                         L3312                                
L3168:
        cmp (16|M0)   (gt)f1.1   null<1>:d     r112.0<1;1,0>:ud  0x4:uw             
(~f1.1) goto (16|M0)                         L3232                  L3232                
L3200:
        mov (16|M0)              r118.0<1>:d   1:w                              
        goto (16|M0)                         L3232                  L3312                
L3232:
        join (16|M0)                         L3312                                
L3248:
        and (16|M0)   (ne)f0.1   null<1>:d     r48.0<1;1,0>:d    1:w              
(W)     mov (1|M0)               r2.0<1>:hf    0x1:hf                             
(f0.1)  cmp (16|M0)   (eq)f0.1   null<1>:d     r112.0<1;1,0>:d   4:w              
(f0.1)  sel (16|M0)              r118.0<1>:d   r2.0<0;1,0>:w     0:w               {F@1}
L3312:
        join (16|M0)                         L3384                                
L3328:
        add (16|M0)              r2.0<1>:d     r118.0<1;1,0>:d   r48.0<1;1,0>:d   {Compacted,I@2}
        cmp (16|M0)   (gt)f1.0   null<1>:d     r2.0<1;1,0>:ud    0x7FFFFF:ud              {I@1}
(W)     mov (1|M0)               r4.6<1>:f     0x800000:f                               {Compacted}
(~f1.0) sel (16|M0)              r120.0<1>:d   r2.0<1;1,0>:d     0:w              
(f1.0)  sel (16|M0)              r118.0<1>:d   r4.6<0;1,0>:d     0:w               {Compacted,F@1}
L3384:
        join (16|M0)                         L3448                                
L3400:
        and (16|M0)              r2.0<1>:d     r18.0<1;1,0>:d    -2147483648:d              
        bfn.0xFE (16|M0)         r52.0<1>:ud   r2.0<1;0>:ud      r118.0<1;0>:ud    r120.0<1>:ud     {I@1} // s0|s1|s2
        goto (16|M0)                         L3448                  L6464                
L3448:
        join (16|M0)                         L3944                                
L3464:
        and (16|M0)   (ne)f1.0   r22.0<1>:d    r36.0<1;1,0>:d    63:w              
(f1.0)  goto (16|M0)                         L3544                  L3544                
L3496:
        mov (16|M0)              r40.0<1>:d    -1:w                              
        mov (16|M0)              r46.0<1>:d    -1:w                              
        goto (16|M0)                         L3544                  L3728                
L3544:
        join (16|M0)                         L3728                                
L3560:
        cmp (16|M0)   (lt)f0.1   null<1>:d     r22.0<1;1,0>:ud   0x20:uw              {I@6}
(f0.1)  goto (16|M0)                         L3664                  L3664                
L3592:
        add (16|M0)              r2.0<1>:d     r22.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r4.12<1>:hf   -qnan(0x1FF):hf                             
        mov (16|M0)              r40.0<1>:d    0:w                              
        shl (16|M0)              r46.0<1>:d    r4.12<0;1,0>:w    r2.0<1;1,0>:d    {A@1}
        goto (16|M0)                         L3664                  L3728                
L3664:
        join (16|M0)                         L3728                                
L3680:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (16|M0)              r46.0<1>:d    -1:w                              
        shl (16|M0)              r40.0<1>:d    r2.0<0;1,0>:w     r22.0<1;1,0>:d   {F@1}
L3728:
        join (16|M0)                         L3944                                
L3744:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r40.0<1;0>:ud     r5.0<0;0>:ud      r26.0<1>:ud      {I@2} // (s0^s1)&s2
        cmp (16|M0)   (ne)f1.0   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
        bfn.0x60 (16|M0)         r6.0<1>:ud    r46.0<1;0>:ud     r5.0<0;0>:ud      r30.0<1>:ud      // (s0^s1)&s2
        cmp (16|M0)   (gt)f0.0   null<1>:d     r18.0<1;1,0>:d    -1:w               {Compacted}
(~f1.0) cmp (16|M0)   (ne)f1.0   null<1>:d     r6.0<1;1,0>:d     0:w               {I@2}
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r108.0<1;1,0>:d   -150:w              
(f0.0)  goto (16|M0)                         L3888                  L3888                
L3848:
(W)     mov (1|M0)               r2.0<1>:ud    0x80000001:ud                             
(f1.0)  sel (16|M0)              r52.0<1>:f    r2.0<0;1,0>:f     -0.0:f               {Compacted,I@1}
        goto (16|M0)                         L3888                  L6464                
L3888:
        join (16|M0)                         L3944                                
L3904:
(W)     mov (1|M0)               r2.0<1>:ud    0x1:ud                              {F@1}
(f1.0)  sel (16|M0)              r52.0<1>:f    r2.0<0;1,0>:f     0.0:f               {Compacted,I@1}
        goto (16|M0)                         L3944                  L6464                
L3944:
        join (16|M0)                         L6248                                
L3960:
        cmp (16|M0)   (lt)f0.0   null<1>:d     r36.0<1;1,0>:ud   0x18:uw             
        add3 (16|M0)             r44.0<1>:d    r34.0<1;0>:d      r36.0<1;0>:d      -46:w              
(f0.0)  cmp (16|M0)   (eq)f0.0   null<1>:d     r40.0<1;1,0>:d    0:w              
(f0.0)  goto (16|M0)                         L5944                  L5944                
L4024:
        shl (16|M0)              r2.0<1>:d     r46.0<1;1,0>:d    1:w               {Compacted,F@1}
        shr (16|M0)              r6.0<1>:ud    r46.0<1;1,0>:ud   31:w              
        shl (16|M0)              r8.0<1>:d     r74.0<1;1,0>:d    1:w               {Compacted}
        cmp (16|M0)   (lt)f1.1   null<1>:d     r2.0<1;1,0>:ud    0x4E:uw              {I@3}
        or (16|M0)               r8.0<1>:d     r8.0<1;1,0>:d     r6.0<1;1,0>:d    {Compacted,I@2}
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r8.0<1;1,0>:d     0:w               {I@1}
(~f1.1) cmp (16|M0)   (lt)f1.1   null<1>:d     r8.0<1;1,0>:d     0:w              
(f1.1)  goto (16|M0)                         L4256                  L4256                
L4128:
        cmp (16|M0)   (eq)f1.1   null<1>:d     r46.0<1;1,0>:d    39:w              
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r74.0<1;1,0>:d    0:w              
(~f1.1) goto (16|M0)                         L4256                  L4320                
L4176:
        shr (16|M0)              r48.0<1>:ud   r26.0<1;1,0>:ud   1:w              
        mov (16|M0)              r98.0<1>:d    0:w                              
        mov (16|M0)              r104.0<1>:d   0:w                              
        mov (16|M0)              r102.0<1>:f   r48.0<1;1,0>:f                   {Compacted,I@3}
        mov (16|M0)              r48.0<1>:f    r26.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L4256                  L5424                
L4256:
        join (16|M0)                         L4320                                
L4272:
        cmp (16|M0)   (eq)f1.0   null<1>:d     r46.0<1;1,0>:d    38:w              
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r74.0<1;1,0>:d    0:w              
(f1.0)  goto (16|M0)                         L4320                  L5336                
L4320:
        join (16|M0)                         L5336                                
L4336:
        add (16|M0)              r2.0<1>:d     -r46.0<1;1,0>:d   39:w               {Compacted}
        and (16|M0)   (ne)f1.1   r94.0<1>:d    r2.0<1;1,0>:d     63:w               {I@1}
        add (16|M0)              r62.0<1>:d    -r46.0<1;1,0>:d   40:w               {Compacted}
(f1.1)  goto (16|M0)                         L4408                  L4408                
L4384:
        mov (16|M0)              r52.0<1>:f    r26.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L4408                  L4520                
L4408:
        join (16|M0)                         L4520                                
L4424:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r94.0<1;1,0>:ud   0x20:uw              {I@5}
(~f1.0) add (16|M0)              r2.0<1>:d     r94.0<1;1,0>:d    -32:w              
(~f1.0) shr (16|M0)              r48.0<1>:ud   r30.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.0)  add (16|M0)              r2.0<1>:d     -r94.0<1;1,0>:d   32:w               {Compacted}
(f1.0)  shr (16|M0)              r6.0<1>:ud    r26.0<1;1,0>:ud   r94.0<1;1,0>:d  
(f1.0)  shl (16|M0)              r2.0<1>:d     r30.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.0)  or (16|M0)               r48.0<1>:d    r6.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
        mov (16|M0)              r52.0<1>:f    r48.0<1;1,0>:f                   {Compacted,I@1}
L4520:
        join (16|M0)                         L5336                                
L4536:
        add (16|M0)              r28.0<1>:d    -r46.0<1;1,0>:d   38:w               {Compacted}
        and (16|M0)   (ne)f0.1   r98.0<1>:d    r28.0<1;1,0>:d    63:w               {I@1}
(f0.1)  goto (16|M0)                         L4600                  L4600                
L4576:
        mov (16|M0)              r48.0<1>:f    r26.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L4600                  L4704                
L4600:
        join (16|M0)                         L4704                                
L4616:
        cmp (16|M0)   (lt)f0.0   null<1>:d     r98.0<1;1,0>:ud   0x20:uw              {I@4}
(~f0.0) add (16|M0)              r2.0<1>:d     r98.0<1;1,0>:d    -32:w              
(~f0.0) shr (16|M0)              r48.0<1>:ud   r30.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f0.0)  add (16|M0)              r2.0<1>:d     -r98.0<1;1,0>:d   32:w               {Compacted}
(f0.0)  shr (16|M0)              r6.0<1>:ud    r26.0<1;1,0>:ud   r98.0<1;1,0>:d  
(f0.0)  shl (16|M0)              r2.0<1>:d     r30.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f0.0)  or (16|M0)               r48.0<1>:d    r6.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
L4704:
        join (16|M0)                         L5336                                
L4720:
        and (16|M0)   (ne)f1.1   r60.0<1>:d    r28.0<1;1,0>:d    63:w              
        and (16|M0)              r104.0<1>:d   r48.0<1;1,0>:d    1:w               {Compacted,I@3}
(f1.1)  goto (16|M0)                         L4808                  L4808                
L4760:
        mov (16|M0)              r74.0<1>:d    -1:w                              
        mov (16|M0)              r80.0<1>:d    -1:w                              
        goto (16|M0)                         L4808                  L4992                
L4808:
        join (16|M0)                         L4992                                
L4824:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r60.0<1;1,0>:ud   0x20:uw              {I@7}
(f1.0)  goto (16|M0)                         L4928                  L4928                
L4856:
        add (16|M0)              r2.0<1>:d     r60.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r4.12<1>:hf   -qnan(0x1FF):hf                             
        mov (16|M0)              r74.0<1>:d    0:w                              
        shl (16|M0)              r80.0<1>:d    r4.12<0;1,0>:w    r2.0<1;1,0>:d    {A@1}
        goto (16|M0)                         L4928                  L4992                
L4928:
        join (16|M0)                         L4992                                
L4944:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (16|M0)              r80.0<1>:d    -1:w                              
        shl (16|M0)              r74.0<1>:d    r2.0<0;1,0>:w     r60.0<1;1,0>:d   {F@1}
L4992:
        join (16|M0)                         L5336                                
L5008:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r74.0<1;0>:ud     r5.0<0;0>:ud      r26.0<1>:ud      {I@2} // (s0^s1)&s2
        cmp (16|M0)   (ne)f0.1   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
        bfn.0x60 (16|M0)         r6.0<1>:ud    r80.0<1;0>:ud     r5.0<0;0>:ud      r30.0<1>:ud      // (s0^s1)&s2
(~f0.1) cmp (16|M0)   (ne)f0.1   null<1>:d     r6.0<1;1,0>:d     0:w               {I@1}
(W)     mov (1|M0)               r4.12<1>:hf   -qnan(0x1FF):hf                             
(f0.1)  sel (16|M0)              r8.0<1>:d     r4.12<0;1,0>:w    0:w               {F@1}
        and (16|M0)   (ne)f0.1   r96.0<1>:d    r62.0<1;1,0>:d    63:w              
        mov (16|M0)              r98.0<1>:d    -r8.0<1;1,0>:d                   {I@2}
(f0.1)  goto (16|M0)                         L5176                  L5176                
L5152:
        mov (16|M0)              r48.0<1>:f    r26.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L5176                  L5280                
L5176:
        join (16|M0)                         L5280                                
L5192:
        cmp (16|M0)   (lt)f0.0   null<1>:d     r96.0<1;1,0>:ud   0x20:uw              {I@5}
(~f0.0) add (16|M0)              r2.0<1>:d     r96.0<1;1,0>:d    -32:w              
(~f0.0) shr (16|M0)              r48.0<1>:ud   r30.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f0.0)  add (16|M0)              r2.0<1>:d     -r96.0<1;1,0>:d   32:w               {Compacted}
(f0.0)  shr (16|M0)              r6.0<1>:ud    r26.0<1;1,0>:ud   r96.0<1;1,0>:d  
(f0.0)  shl (16|M0)              r2.0<1>:d     r30.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f0.0)  or (16|M0)               r48.0<1>:d    r6.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
L5280:
        join (16|M0)                         L5336                                
L5296:
        mov (16|M0)              r102.0<1>:f   r48.0<1;1,0>:f                   {Compacted,I@2}
        mov (16|M0)              r48.0<1>:d    r52.0<1;1,0>:d                   {F@1}
        goto (16|M0)                         L5336                  L5424                
L5336:
        join (16|M0)                         L5424                                
L5352:
        shr (16|M0)              r48.0<1>:ud   r26.0<1;1,0>:ud   2:w              
        mov (16|M0)              r98.0<1>:d    0:w                              
        mov (16|M0)              r104.0<1>:d   0:w                              
        mov (16|M0)              r102.0<1>:f   r48.0<1;1,0>:f                   {Compacted,I@3}
        shr (16|M0)              r48.0<1>:ud   r26.0<1;1,0>:ud   1:w               {F@1}
L5424:
        join (16|M0)                         L5944                                
L5440:
        shl (16|M0)              r2.0<1>:d     r48.0<1;1,0>:d    2:w               {Compacted,I@2}
        shl (16|M0)              r6.0<1>:d     r104.0<1;1,0>:d   1:w               {Compacted}
        and (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     4:w               {Compacted,I@2}
        bfn.0xFE (16|M0)         r38.0<1>:ud   r2.0<1;0>:ud      r6.0<1;0>:ud      r98.0<1>:ud      {I@1} // s0|s1|s2
        cmp (16|M0)   (eq)f1.1   null<1>:d     r38.0<1;1,0>:d    0:w               {I@1}
        and (16|M0)              r56.0<1>:d    r102.0<1;1,0>:d   8388607:d              
(~f1.1) goto (16|M0)                         L5560                  L5560                
L5528:
        mov (16|M0)              r10.0<1>:d    0:w                              
        goto (16|M0)                         L5560                  L5712                
L5560:
        join (16|M0)                         L5712                                
L5576:
        cmp (16|M0)   (gt)f1.0   null<1>:d     r38.0<1;1,0>:ud   0x4:uw             
(~f1.0) goto (16|M0)                         L5640                  L5640                
L5608:
        mov (16|M0)              r10.0<1>:d    1:w                              
        goto (16|M0)                         L5640                  L5712                
L5640:
        join (16|M0)                         L5712                                
L5656:
        and (16|M0)   (ne)f0.0   null<1>:d     r102.0<1;1,0>:d   1:w               {Compacted}
(W)     mov (1|M0)               r2.0<1>:hf    0x1:hf                             
(f0.0)  cmp (16|M0)   (eq)f0.0   null<1>:d     r38.0<1;1,0>:d    4:w              
(f0.0)  sel (16|M0)              r10.0<1>:d    r2.0<0;1,0>:w     0:w               {F@1}
L5712:
        join (16|M0)                         L5944                                
L5728:
        add (16|M0)              r6.0<1>:d     r56.0<1;1,0>:d    r10.0<1;1,0>:d   {Compacted,I@2}
        cmp (16|M0)   (gt)f1.0   null<1>:d     r6.0<1;1,0>:ud    0x7FFFFF:ud              {I@1}
        add3 (16|M0)             r2.0<1>:d     r34.0<1;0>:d      r36.0<1;0>:d      -45:w              
(f1.0)  sel (16|M0)              r126.0<1>:d   r2.0<1;1,0>:d     r44.0<1;1,0>:d   {Compacted,I@1}
        cmp (16|M0)   (eq)f0.1   null<1>:d     r126.0<1;1,0>:d   255:w               {I@1}
(f0.1)  goto (16|M0)                         L5880                  L5880                
L5808:
(~f1.0) sel (16|M0)              r2.0<1>:d     r6.0<1;1,0>:d     0:w              
        shl (16|M0)              r8.0<1>:d     r126.0<1;1,0>:d   23:w               {Compacted}
        and (16|M0)              r6.0<1>:d     r18.0<1;1,0>:d    -2147483648:d              
        bfn.0xFE (16|M0)         r52.0<1>:ud   r6.0<1;0>:ud      r8.0<1;0>:ud      r2.0<1>:ud       {I@1} // s0|s1|s2
        goto (16|M0)                         L5880                  L6464                
L5880:
        join (16|M0)                         L5944                                
L5896:
        cmp (16|M0)   (gt)f0.1   null<1>:d     r18.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r2.0<1>:f     inf:f                               {Compacted,I@4}
(f0.1)  sel (16|M0)              r52.0<1>:f    r2.0<0;1,0>:f     -inf:f               {Compacted,F@1}
        goto (16|M0)                         L5944                  L6464                
L5944:
        join (16|M0)                         L6248                                
L5960:
        and (16|M0)   (ne)f0.0   r116.0<1>:d   r36.0<1;1,0>:d    63:w               {Compacted}
(f0.0)  goto (16|M0)                         L6016                  L6016                
L5984:
        mov (16|M0)              r126.0<1>:d   -1:w                              
        goto (16|M0)                         L6016                  L6144                
L6016:
        join (16|M0)                         L6144                                
L6032:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r116.0<1;1,0>:ud  0x20:uw              {I@5}
(f1.1)  goto (16|M0)                         L6096                  L6096                
L6064:
        mov (16|M0)              r126.0<1>:d   0:w                              
        goto (16|M0)                         L6096                  L6144                
L6096:
        join (16|M0)                         L6144                                
L6112:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                             
        shl (16|M0)              r126.0<1>:d   r2.0<0;1,0>:w     r116.0<1;1,0>:d  {F@1}
L6144:
        join (16|M0)                         L6248                                
L6160:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r126.0<1;0>:ud    r5.0<0;0>:ud      r26.0<1>:ud      {I@2} // (s0^s1)&s2
        add (16|M0)              r6.0<1>:d     -r36.0<1;1,0>:d   23:w               {Compacted}
        and (16|M0)              r8.0<1>:d     r18.0<1;1,0>:d    -2147483648:d              
        shl (16|M0)              r10.0<1>:d    r44.0<1;1,0>:d    23:w               {Compacted}
        shl (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     r6.0<1;1,0>:d    {Compacted,I@3}
        bfn.0xFE (16|M0)         r52.0<1>:ud   r8.0<1;0>:ud      r10.0<1;0>:ud     r2.0<1>:ud       {I@1} // s0|s1|s2
        goto (16|M0)                         L6248                  L6464                
L6248:
        join (16|M0)                         L6304                                
L6264:
        cmp (16|M0)   (gt)f0.0   null<1>:d     r18.0<1;1,0>:d    -1:w               {Compacted}
(W)     mov (1|M0)               r2.0<1>:f     inf:f                               {Compacted,I@4}
(f0.0)  sel (16|M0)              r52.0<1>:f    r2.0<0;1,0>:f     -inf:f               {Compacted,F@1}
        goto (16|M0)                         L6304                  L6464                
L6304:
        join (16|M0)                         L6368                                
L6320:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r18.0<1;1,0>:d    0:w              
(W)     mov (1|M0)               r2.0<1>:f     -0.0:f                               {Compacted}
(f1.1)  sel (16|M0)              r52.0<1>:f    r2.0<0;1,0>:f     0.0:f               {Compacted,F@1}
        goto (16|M0)                         L6368                  L6464                
L6368:
        join (16|M0)                         L6432                                
L6384:
        cmp (16|M0)   (gt)f1.0   null<1>:d     r18.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r2.0<1>:f     inf:f                               {Compacted}
(f1.0)  sel (16|M0)              r52.0<1>:f    r2.0<0;1,0>:f     -inf:f               {Compacted,F@1}
        goto (16|M0)                         L6432                  L6464                
L6432:
        join (16|M0)                         L6464                                
L6448:
        bfn.0xF8 (16|M0)         r52.0<1>:ud   r18.0<1;0>:ud     r5.2<0;0>:ud      r5.1<0>:ud       {F@1} // s0&s1|s2
L6464:
        join (16|M0)                         L6480                                
L6480:
        rnde (16|M0)             r36.0<1>:f    r52.0<1;1,0>:f                   {Compacted,I@2}
        shr (16|M0)              r18.0<1>:ud   r36.0<1;1,0>:ud   23:w               {F@1}
        and (16|M0)   (ne)f1.1   r72.0<1>:d    r36.0<1;1,0>:d    8388607:d              
        and (16|M0)              r70.0<1>:d    r18.0<1;1,0>:d    255:w               {Compacted,I@2}
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r70.0<1;1,0>:d    255:w               {I@1}
(~f1.1) goto (16|M0)                         L6592                  L6592                
L6560:
        mov (16|M0)              r50.0<1>:ud   0x7FC00000:ud                             
        goto (16|M0)                         L6592                  L12536                
L6592:
        join (16|M0)                         L12536                                
L6608:
        cmp (16|M0)   (eq)f1.0   null<1>:d     r72.0<1;1,0>:d    0:w              
        add (16|M0)              r2.0<1>:d     r16.0<1;1,0>:d    -25165824:d               {$1.dst}
        shr (16|M0)              r8.0<1>:ud    r2.0<1;1,0>:ud    23:w               {I@1}
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r70.0<1;1,0>:d    255:w              
        and (16|M0)              r30.0<1>:d    r8.0<1;1,0>:d     255:w               {Compacted,I@2}
(~f1.0) cmp (16|M0)   (eq)f1.0   null<1>:d     r30.0<1;1,0>:d    255:w               {I@1}
        xor (16|M0)              r22.0<1>:d    r2.0<1;1,0>:d     r36.0<1;1,0>:d   {Compacted}
(f1.0)  goto (16|M0)                         L12504                  L12504                
L6720:
        cmp (16|M0)   (eq)f1.0   null<1>:d     r30.0<1;1,0>:d    0:w              
        or (16|M0)               r2.0<1>:d     r70.0<1;1,0>:d    r72.0<1;1,0>:d   {Compacted}
(~f1.0) cmp (16|M0)   (eq)f1.0   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
(~f1.0) goto (16|M0)                         L6808                  L6808                
L6776:
        mov (16|M0)              r50.0<1>:ud   0x0:ud                             
        goto (16|M0)                         L6808                  L12536                
L6808:
        join (16|M0)                         L12504                                
L6824:
        cmp (16|M0)   (eq)f1.1   null<1>:d     r70.0<1;1,0>:d    0:w              
        add (16|M0)              r26.0<1>:d    r70.0<1;1,0>:d    -127:w               {Compacted}
(f1.1)  mov (16|M0)              r26.0<1>:d    -126:w                              
        add (16|M0)              r32.0<1>:d    r30.0<1;1,0>:d    r26.0<1;1,0>:d   {Compacted,I@1}
        cmp (16|M0)   (gt)f1.0   null<1>:d     r32.0<1;1,0>:d    254:w               {I@1}
(f1.0)  goto (16|M0)                         L12440                  L12440                
L6904:
        or (16|M0)    (eq)f0.1   null<4>:b     r18.0<1;1,0>:d    r8.0<1;1,0>:d   
(f0.1)  goto (16|M0)                         L12376                  L12376                
L6936:
(W)     mov (1|M0)               r2.0<1>:hf    0.0:hf                             
(W)     mov (1|M0)               r5.7<1>:d     0:w                              
(f1.1)  sel (16|M0)              r6.0<1>:d     r2.0<0;1,0>:w     8388608:d               {F@1}
        or (16|M0)               r6.0<1>:d     r6.0<1;1,0>:d     r72.0<1;1,0>:d   {Compacted,I@1}
        shl (16|M0)              r24.0<1>:d    r6.0<1;1,0>:d     23:w               {Compacted,I@1}
        shr (16|M0)              r28.0<1>:ud   r6.0<1;1,0>:ud    9:w              
(W)     mov (1|M0)               r5.6<1>:f     -0.0:f                               {Compacted}
(W)     mov (2|M0)               r16.0<1>:d    0:w                              
L7040:
(W)     shl (1|M0)               r2.0<1>:d     r5.6<0;1,0>:d     31:w               {Compacted,F@1}
(W)     shr (1|M0)               r2.1<1>:ud    r5.7<0;1,0>:ud    1:w              
(W)     cmp (16|M0)   (gt)f1.0   null<1>:d     r16.0<0;1,0>:ud   0x3E:uw              {I@3}
(W)     or (1|M0)                r5.7<1>:d     r2.1<0;1,0>:d     r2.0<0;1,0>:d    {I@2}
        bfn.0xE0 (16|M0)         r6.0<1>:ud    r2.1<0;0>:ud      r2.0<0;0>:ud      r24.0<1>:ud      // (s0|s1)&s2
(W)     shr (1|M0)               r5.3<1>:ud    r5.6<0;1,0>:ud    1:w              
(W&f1.0) cmp (16|M0)  (eq)f1.0   null<1>:d     r16.1<0;1,0>:d    0:w              
        cmp (16|M0)   (eq)f0.0   null<1>:d     r6.0<1;1,0>:d     r5.7<0;1,0>:d    {I@3}
        and (16|M0)              r8.0<1>:d     r5.3<0;1,0>:d     r28.0<1;1,0>:d   {Compacted,I@3}
(W&~f1.0) cmp (16|M0) (gt)f1.0   null<1>:d     r16.1<0;1,0>:ud   0x0:uw             
(f0.0)  cmp (16|M0)   (eq)f0.0   null<1>:d     r8.0<1;1,0>:d     r5.3<0;1,0>:d    {I@2}
(W)     mov (1|M0)               r4.12<1>:hf   0x1:hf                             
(W)     addc (1|M0)              r17.0<1>:ud   r16.0<0;1,0>:ud   0x1:ud              {AccWrEn}
(f1.0)  sel (16|M0)              r10.0<1>:uw   r4.12<0;1,0>:uw   0x0:uw              {Compacted,F@1}
(f0.0)  sel (16|M0)              acc2.0<1>:uw  r4.12<0;1,0>:uw   0x0:uw             
(W)     mov (1|M0)               r3.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        or (16|M0)    (ne)f1.0   null<1>:uw    r10.0<1;1,0>:uw   acc2.0<1;1,0>:uw {I@3}
(W)     add (1|M0)               r16.2<1>:ud   r3.0<0;1,0>:ud    r16.1<0;1,0>:ud  {I@2}
        mov (16|M0)              r60.0<1>:f    r16.0<0;1,0>:f                   {Compacted}
        mov (16|M0)              r58.0<1>:d    r16.1<0;1,0>:d                  
        mov (16|M0)              r54.0<1>:f    r17.0<0;1,0>:f                   {Compacted}
        mov (16|M0)              r72.0<1>:d    r16.2<0;1,0>:d                   {I@2}
(f1.0)  goto (16|M0)                         L7416                  L7416                
L7360:
(W)     mov (1|M0)               r5.6<1>:d     r5.3<0;1,0>:d                   
(W)     mov (1|M0)               r16.0<1>:f    r17.0<0;1,0>:f                   {Compacted}
(W)     mov (1|M0)               r16.1<1>:d    r16.2<0;1,0>:d                  
(W)     jmpi                                 L7040                                
L7416:
        join (16|M0)                         L12376                                
L7432:
(W)     mov (1|M0)               r2.0<1>:f     8.68805e-44:f                              
(W)     mov (1|M0)               r3.0<1>:hf    0.0:hf                             
        subb (8|M0)              r38.0<1>:ud   r2.0<0;1,0>:ud    r60.0<1;1,0>:ud  {AccWrEn,Compacted,F@2}
        add3 (8|M0)              r34.0<1>:ud   -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r58.0<1>:ud     {A@1}
        subb (8|M8)              r39.0<1>:ud   r2.0<0;1,0>:ud    r61.0<1;1,0>:ud  {AccWrEn}
        add3 (16|M0)             r104.0<1>:d   r32.0<1;0>:d      r38.0<1;0>:d      -173:w               {I@1}
        cmp (16|M0)   (gt)f0.0   null<1>:d     r104.0<1;1,0>:d   127:w               {Compacted,I@1}
        add3 (8|M8)              r35.0<1>:ud   -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r59.0<1>:ud    
        add3 (16|M0)             r30.0<1>:d    r30.0<1;0>:d      r26.0<1;0>:d      r38.0<1>:d      
(f0.0)  goto (16|M0)                         L12320                  L12320                
L7576:
        cmp (16|M0)   (gt)f1.1   null<1>:d     r104.0<1;1,0>:d   -127:w              
(f1.1)  goto (16|M0)                         L10008                  L10008                
L7608:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r104.0<1;1,0>:ud  0xFFFFFF6B:ud             
(f1.0)  goto (16|M0)                         L9512                  L9512                
L7640:
(W)     mov (1|M0)               r2.0<1>:f     8.82818e-44:f                              
(W)     mov (1|M0)               r3.0<1>:hf    0.0:hf                              {I@7}
        subb (8|M0)              r66.0<1>:ud   r2.0<0;1,0>:ud    r60.0<1;1,0>:ud  {AccWrEn,Compacted,F@2}
        add3 (16|M0)             r86.0<1>:d    r32.0<1;0>:d      r38.0<1;0>:d      -23:w              
        add3 (8|M0)              r6.0<1>:ud    -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r58.0<1>:ud     {F@1}
        subb (8|M8)              r67.0<1>:ud   r2.0<0;1,0>:ud    r61.0<1;1,0>:ud  {AccWrEn}
        cmp (16|M0)   (gt)f0.1   null<1>:d     r66.0<1;1,0>:ud   r86.0<1;1,0>:ud  {I@1}
        add3 (8|M8)              r7.0<1>:ud    -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r59.0<1>:ud    
(f0.1)  cmp (16|M0)   (eq)f0.1   null<1>:d     r6.0<1;1,0>:d     0:w               {I@1}
(~f0.1) cmp (16|M0)   (gt)f0.1   null<1>:d     r6.0<1;1,0>:ud    0x0:uw             
(f0.1)  goto (16|M0)                         L7864                  L7864                
L7808:
        add3 (16|M0)             r2.0<1>:d     r30.0<1;0>:d      -r66.0<1;0>:d     -23:w              
        mov (16|M0)              r110.0<1>:d   0:w                              
        shl (16|M0)              r112.0<1>:d   r24.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
        goto (16|M0)                         L7864                  L9448                
L7864:
        join (16|M0)                         L9448                                
L7880:
        add3 (16|M0)             r120.0<1>:d   r66.0<1;0>:d      -r30.0<1;0>:d     23:w              
        cmp (16|M0)   (lt)f0.1   null<1>:d     r120.0<1;1,0>:d   2:w               {I@1}
(f0.1)  goto (16|M0)                         L8024                  L8024                
L7928:
        cmp (16|M0)   (eq)f0.0   null<1>:d     r120.0<1;1,0>:d   2:w               {Compacted}
(~f0.0) goto (16|M0)                         L8024                  L8128                
L7952:
        shr (16|M0)              r42.0<1>:ud   r24.0<1;1,0>:ud   1:w              
        mov (16|M0)              r90.0<1>:d    0:w                              
        mov (16|M0)              r78.0<1>:d    0:w                              
        mov (16|M0)              r68.0<1>:f    r42.0<1;1,0>:f                   {Compacted,I@3}
        goto (16|M0)                         L8024                  L8944                
L8024:
        join (16|M0)                         L8128                                
L8040:
        cmp (16|M0)   (eq)f1.1   null<1>:d     r120.0<1;1,0>:d   1:w              
(~f1.1) goto (16|M0)                         L8128                  L8128                
L8072:
        mov (16|M0)              r90.0<1>:d    0:w                              
        mov (16|M0)              r78.0<1>:d    0:w                              
        mov (16|M0)              r68.0<1>:f    r24.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L8128                  L8944                
L8128:
        join (16|M0)                         L8944                                
L8144:
        add3 (16|M0)             r2.0<1>:d     r66.0<1;0>:d      -r86.0<1;0>:d     -1:w              
        and (16|M0)   (ne)f1.0   r80.0<1>:d    r2.0<1;1,0>:d     63:w               {I@1}
(f1.0)  goto (16|M0)                         L8216                  L8216                
L8192:
        mov (16|M0)              r48.0<1>:f    r24.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L8216                  L8328                
L8216:
        join (16|M0)                         L8328                                
L8232:
        cmp (16|M0)   (lt)f0.1   null<1>:d     r80.0<1;1,0>:ud   0x20:uw              {I@4}
(~f0.1) add (16|M0)              r2.0<1>:d     r80.0<1;1,0>:d    -32:w              
(~f0.1) shr (16|M0)              r42.0<1>:ud   r28.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f0.1)  add (16|M0)              r2.0<1>:d     -r80.0<1;1,0>:d   32:w               {Compacted}
(f0.1)  shr (16|M0)              r6.0<1>:ud    r24.0<1;1,0>:ud   r80.0<1;1,0>:d  
(f0.1)  shl (16|M0)              r2.0<1>:d     r28.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f0.1)  or (16|M0)               r42.0<1>:d    r6.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
        mov (16|M0)              r48.0<1>:f    r42.0<1;1,0>:f                   {Compacted,I@1}
L8328:
        join (16|M0)                         L8944                                
L8344:
        add3 (16|M0)             r10.0<1>:d    r66.0<1;0>:d      -r86.0<1;0>:d     -2:w              
        and (16|M0)   (ne)f0.0   r78.0<1>:d    r10.0<1;1,0>:d    63:w               {Compacted,I@1}
(f0.0)  goto (16|M0)                         L8408                  L8408                
L8384:
        mov (16|M0)              r42.0<1>:f    r24.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L8408                  L8512                
L8408:
        join (16|M0)                         L8512                                
L8424:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r78.0<1;1,0>:ud   0x20:uw              {I@4}
(~f1.1) add (16|M0)              r2.0<1>:d     r78.0<1;1,0>:d    -32:w              
(~f1.1) shr (16|M0)              r42.0<1>:ud   r28.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.1)  add (16|M0)              r2.0<1>:d     -r78.0<1;1,0>:d   32:w               {Compacted}
(f1.1)  shr (16|M0)              r6.0<1>:ud    r24.0<1;1,0>:ud   r78.0<1;1,0>:d  
(f1.1)  shl (16|M0)              r2.0<1>:d     r28.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.1)  or (16|M0)               r42.0<1>:d    r6.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
L8512:
        join (16|M0)                         L8944                                
L8528:
        and (16|M0)   (ne)f1.0   r34.0<1>:d    r10.0<1;1,0>:d    63:w              
(f1.0)  goto (16|M0)                         L8608                  L8608                
L8560:
        mov (16|M0)              r44.0<1>:d    -1:w                              
        mov (16|M0)              r50.0<1>:d    -1:w                              
        goto (16|M0)                         L8608                  L8792                
L8608:
        join (16|M0)                         L8792                                
L8624:
        cmp (16|M0)   (lt)f0.1   null<1>:d     r34.0<1;1,0>:ud   0x20:uw              {I@6}
(f0.1)  goto (16|M0)                         L8728                  L8728                
L8656:
        add (16|M0)              r2.0<1>:d     r34.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r4.12<1>:hf   -qnan(0x1FF):hf                             
        mov (16|M0)              r44.0<1>:d    0:w                              
        shl (16|M0)              r50.0<1>:d    r4.12<0;1,0>:w    r2.0<1;1,0>:d    {A@1}
        goto (16|M0)                         L8728                  L8792                
L8728:
        join (16|M0)                         L8792                                
L8744:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (16|M0)              r50.0<1>:d    -1:w                              
        shl (16|M0)              r44.0<1>:d    r2.0<0;1,0>:w     r34.0<1;1,0>:d   {F@1}
L8792:
        join (16|M0)                         L8944                                
L8808:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r44.0<1;0>:ud     r5.0<0;0>:ud      r24.0<1>:ud      {I@2} // (s0^s1)&s2
        cmp (16|M0)   (ne)f0.1   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
        bfn.0x60 (16|M0)         r6.0<1>:ud    r50.0<1;0>:ud     r5.0<0;0>:ud      r28.0<1>:ud      // (s0^s1)&s2
(~f0.1) cmp (16|M0)   (ne)f0.1   null<1>:d     r6.0<1;1,0>:d     0:w               {I@1}
(W)     mov (1|M0)               r4.12<1>:hf   -qnan(0x1FF):hf                             
        shl (16|M0)              r10.0<1>:d    r42.0<1;1,0>:d    1:w               {Compacted}
(f0.1)  sel (16|M0)              r8.0<1>:d     r4.12<0;1,0>:w    0:w               {F@1}
        mov (16|M0)              r68.0<1>:f    r48.0<1;1,0>:f                   {Compacted}
        and (16|M0)              r78.0<1>:d    r10.0<1;1,0>:d    2:w               {Compacted,I@2}
        mov (16|M0)              r90.0<1>:d    -r8.0<1;1,0>:d                   {I@2}
L8944:
        join (16|M0)                         L9448                                
L8960:
        and (16|M0)   (ne)f0.0   r76.0<1>:d    r120.0<1;1,0>:d   63:w               {Compacted}
(f0.0)  goto (16|M0)                         L9008                  L9008                
L8984:
        mov (16|M0)              r42.0<1>:f    r24.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L9008                  L9112                
L9008:
        join (16|M0)                         L9112                                
L9024:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r76.0<1;1,0>:ud   0x20:uw              {I@4}
(~f1.1) add (16|M0)              r2.0<1>:d     r76.0<1;1,0>:d    -32:w              
(~f1.1) shr (16|M0)              r42.0<1>:ud   r28.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.1)  add (16|M0)              r2.0<1>:d     -r76.0<1;1,0>:d   32:w               {Compacted}
(f1.1)  shr (16|M0)              r6.0<1>:ud    r24.0<1;1,0>:ud   r76.0<1;1,0>:d  
(f1.1)  shl (16|M0)              r2.0<1>:d     r28.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.1)  or (16|M0)               r42.0<1>:d    r6.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
L9112:
        join (16|M0)                         L9448                                
L9128:
        shl (16|M0)              r2.0<1>:d     r68.0<1;1,0>:d    2:w               {Compacted}
        and (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     4:w               {Compacted,I@1}
        bfn.0xFE (16|M0)         r106.0<1>:ud  r2.0<1;0>:ud      r78.0<1;0>:ud     r90.0<1>:ud      {I@1} // s0|s1|s2
        cmp (16|M0)   (eq)f1.0   null<1>:d     r106.0<1;1,0>:d   0:w               {I@1}
(~f1.0) goto (16|M0)                         L9224                  L9224                
L9192:
        mov (16|M0)              r110.0<1>:d   0:w                              
        goto (16|M0)                         L9224                  L9376                
L9224:
        join (16|M0)                         L9376                                
L9240:
        cmp (16|M0)   (gt)f0.1   null<1>:d     r106.0<1;1,0>:ud  0x4:uw             
(~f0.1) goto (16|M0)                         L9304                  L9304                
L9272:
        mov (16|M0)              r110.0<1>:d   1:w                              
        goto (16|M0)                         L9304                  L9376                
L9304:
        join (16|M0)                         L9376                                
L9320:
        and (16|M0)   (ne)f0.0   null<1>:d     r42.0<1;1,0>:d    1:w               {Compacted}
(W)     mov (1|M0)               r2.0<1>:hf    0x1:hf                             
(f0.0)  cmp (16|M0)   (eq)f0.0   null<1>:d     r106.0<1;1,0>:d   4:w              
(f0.0)  sel (16|M0)              r110.0<1>:d   r2.0<0;1,0>:w     0:w               {F@1}
L9376:
        join (16|M0)                         L9448                                
L9392:
        add (16|M0)              r2.0<1>:d     r110.0<1;1,0>:d   r42.0<1;1,0>:d   {Compacted,I@2}
        cmp (16|M0)   (gt)f0.1   null<1>:d     r2.0<1;1,0>:ud    0x7FFFFF:ud              {I@1}
(W)     mov (1|M0)               r4.6<1>:f     0x800000:f                               {Compacted}
(~f0.1) sel (16|M0)              r112.0<1>:d   r2.0<1;1,0>:d     0:w              
(f0.1)  sel (16|M0)              r110.0<1>:d   r4.6<0;1,0>:d     0:w               {Compacted,F@1}
L9448:
        join (16|M0)                         L9512                                
L9464:
        and (16|M0)              r2.0<1>:d     r22.0<1;1,0>:d    -2147483648:d              
        bfn.0xFE (16|M0)         r50.0<1>:ud   r2.0<1;0>:ud      r110.0<1;0>:ud    r112.0<1>:ud     {I@1} // s0|s1|s2
        goto (16|M0)                         L9512                  L12536                
L9512:
        join (16|M0)                         L10008                                
L9528:
        and (16|M0)   (ne)f0.0   r124.0<1>:d   r38.0<1;1,0>:d    63:w               {Compacted}
(f0.0)  goto (16|M0)                         L9600                  L9600                
L9552:
        mov (16|M0)              r8.0<1>:d     -1:w                              
        mov (16|M0)              r32.0<1>:d    -1:w                              
        goto (16|M0)                         L9600                  L9784                
L9600:
        join (16|M0)                         L9784                                
L9616:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r124.0<1;1,0>:ud  0x20:uw              {I@6}
(f1.1)  goto (16|M0)                         L9720                  L9720                
L9648:
        add (16|M0)              r2.0<1>:d     r124.0<1;1,0>:d   -32:w               {Compacted}
(W)     mov (1|M0)               r4.12<1>:hf   -qnan(0x1FF):hf                             
        mov (16|M0)              r8.0<1>:d     0:w                              
        shl (16|M0)              r32.0<1>:d    r4.12<0;1,0>:w    r2.0<1;1,0>:d    {A@1}
        goto (16|M0)                         L9720                  L9784                
L9720:
        join (16|M0)                         L9784                                
L9736:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (16|M0)              r32.0<1>:d    -1:w                              
        shl (16|M0)              r8.0<1>:d     r2.0<0;1,0>:w     r124.0<1;1,0>:d  {F@1}
L9784:
        join (16|M0)                         L10008                                
L9800:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r8.0<1;0>:ud      r5.0<0;0>:ud      r24.0<1>:ud      {I@2} // (s0^s1)&s2
        cmp (16|M0)   (ne)f0.1   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
        bfn.0x60 (16|M0)         r6.0<1>:ud    r32.0<1;0>:ud     r5.0<0;0>:ud      r28.0<1>:ud      // (s0^s1)&s2
        cmp (16|M0)   (gt)f1.0   null<1>:d     r22.0<1;1,0>:d    -1:w              
(~f0.1) cmp (16|M0)   (ne)f0.1   null<1>:d     r6.0<1;1,0>:d     0:w               {I@2}
(f0.1)  cmp (16|M0)   (eq)f0.1   null<1>:d     r104.0<1;1,0>:d   -150:w              
(f1.0)  goto (16|M0)                         L9952                  L9952                
L9912:
(W)     mov (1|M0)               r2.0<1>:ud    0x80000001:ud                             
(f0.1)  sel (16|M0)              r50.0<1>:f    r2.0<0;1,0>:f     -0.0:f               {Compacted,I@1}
        goto (16|M0)                         L9952                  L12536                
L9952:
        join (16|M0)                         L10008                                
L9968:
(W)     mov (1|M0)               r2.0<1>:ud    0x1:ud                              {F@1}
(f0.1)  sel (16|M0)              r50.0<1>:f    r2.0<0;1,0>:f     0.0:f               {Compacted,I@1}
        goto (16|M0)                         L10008                  L12536                
L10008:
        join (16|M0)                         L12320                                
L10024:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r38.0<1;1,0>:ud   0x18:uw             
        add3 (16|M0)             r40.0<1>:d    r32.0<1;0>:d      r38.0<1;0>:d      -46:w              
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r34.0<1;1,0>:d    0:w              
(f1.1)  goto (16|M0)                         L12008                  L12008                
L10088:
        shl (16|M0)              r2.0<1>:d     r54.0<1;1,0>:d    1:w               {Compacted,F@1}
        shr (16|M0)              r6.0<1>:ud    r54.0<1;1,0>:ud   31:w              
        shl (16|M0)              r8.0<1>:d     r72.0<1;1,0>:d    1:w               {Compacted}
        cmp (16|M0)   (lt)f0.0   null<1>:d     r2.0<1;1,0>:ud    0x4E:uw              {I@3}
        or (16|M0)               r8.0<1>:d     r8.0<1;1,0>:d     r6.0<1;1,0>:d    {Compacted,I@2}
(f0.0)  cmp (16|M0)   (eq)f0.0   null<1>:d     r8.0<1;1,0>:d     0:w               {I@1}
(~f0.0) cmp (16|M0)   (lt)f0.0   null<1>:d     r8.0<1;1,0>:d     0:w              
(f0.0)  goto (16|M0)                         L10320                  L10320                
L10192:
        cmp (16|M0)   (eq)f1.0   null<1>:d     r54.0<1;1,0>:d    39:w              
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r72.0<1;1,0>:d    0:w              
(~f1.0) goto (16|M0)                         L10320                  L10384                
L10240:
        shr (16|M0)              r42.0<1>:ud   r24.0<1;1,0>:ud   1:w              
        mov (16|M0)              r94.0<1>:d    0:w                              
        mov (16|M0)              r66.0<1>:d    0:w                              
        mov (16|M0)              r100.0<1>:f   r42.0<1;1,0>:f                   {Compacted,I@3}
        mov (16|M0)              r42.0<1>:f    r24.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L10320                  L11488                
L10320:
        join (16|M0)                         L10384                                
L10336:
        cmp (16|M0)   (eq)f0.1   null<1>:d     r54.0<1;1,0>:d    38:w              
(f0.1)  cmp (16|M0)   (eq)f0.1   null<1>:d     r72.0<1;1,0>:d    0:w              
(f0.1)  goto (16|M0)                         L10384                  L11400                
L10384:
        join (16|M0)                         L11400                                
L10400:
        add (16|M0)              r2.0<1>:d     -r54.0<1;1,0>:d   39:w               {Compacted}
        and (16|M0)   (ne)f0.1   r88.0<1>:d    r2.0<1;1,0>:d     63:w               {I@1}
        add (16|M0)              r60.0<1>:d    -r54.0<1;1,0>:d   40:w               {Compacted}
(f0.1)  goto (16|M0)                         L10472                  L10472                
L10448:
        mov (16|M0)              r50.0<1>:f    r24.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L10472                  L10584                
L10472:
        join (16|M0)                         L10584                                
L10488:
        cmp (16|M0)   (lt)f0.0   null<1>:d     r88.0<1;1,0>:ud   0x20:uw              {I@5}
(~f0.0) add (16|M0)              r2.0<1>:d     r88.0<1;1,0>:d    -32:w              
(~f0.0) shr (16|M0)              r42.0<1>:ud   r28.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f0.0)  add (16|M0)              r2.0<1>:d     -r88.0<1;1,0>:d   32:w               {Compacted}
(f0.0)  shr (16|M0)              r6.0<1>:ud    r24.0<1;1,0>:ud   r88.0<1;1,0>:d  
(f0.0)  shl (16|M0)              r2.0<1>:d     r28.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f0.0)  or (16|M0)               r42.0<1>:d    r6.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
        mov (16|M0)              r50.0<1>:f    r42.0<1;1,0>:f                   {Compacted,I@1}
L10584:
        join (16|M0)                         L11400                                
L10600:
        add (16|M0)              r26.0<1>:d    -r54.0<1;1,0>:d   38:w               {Compacted}
        and (16|M0)   (ne)f1.1   r92.0<1>:d    r26.0<1;1,0>:d    63:w               {I@1}
(f1.1)  goto (16|M0)                         L10664                  L10664                
L10640:
        mov (16|M0)              r44.0<1>:f    r24.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L10664                  L10776                
L10664:
        join (16|M0)                         L10776                                
L10680:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r92.0<1;1,0>:ud   0x20:uw              {I@4}
(~f1.0) add (16|M0)              r2.0<1>:d     r92.0<1;1,0>:d    -32:w              
(~f1.0) shr (16|M0)              r42.0<1>:ud   r28.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.0)  add (16|M0)              r2.0<1>:d     -r92.0<1;1,0>:d   32:w               {Compacted}
(f1.0)  shr (16|M0)              r6.0<1>:ud    r24.0<1;1,0>:ud   r92.0<1;1,0>:d  
(f1.0)  shl (16|M0)              r2.0<1>:d     r28.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.0)  or (16|M0)               r42.0<1>:d    r6.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
        mov (16|M0)              r44.0<1>:f    r42.0<1;1,0>:f                   {Compacted,I@1}
L10776:
        join (16|M0)                         L11400                                
L10792:
        and (16|M0)   (ne)f0.1   r54.0<1>:d    r26.0<1;1,0>:d    63:w              
(f0.1)  goto (16|M0)                         L10872                  L10872                
L10824:
        mov (16|M0)              r58.0<1>:d    -1:w                              
        mov (16|M0)              r64.0<1>:d    -1:w                              
        goto (16|M0)                         L10872                  L11056                
L10872:
        join (16|M0)                         L11056                                
L10888:
        cmp (16|M0)   (lt)f0.0   null<1>:d     r54.0<1;1,0>:ud   0x20:uw              {I@6}
(f0.0)  goto (16|M0)                         L10992                  L10992                
L10920:
        add (16|M0)              r2.0<1>:d     r54.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r4.12<1>:hf   -qnan(0x1FF):hf                             
        mov (16|M0)              r58.0<1>:d    0:w                              
        shl (16|M0)              r64.0<1>:d    r4.12<0;1,0>:w    r2.0<1;1,0>:d    {A@1}
        goto (16|M0)                         L10992                  L11056                
L10992:
        join (16|M0)                         L11056                                
L11008:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (16|M0)              r64.0<1>:d    -1:w                              
        shl (16|M0)              r58.0<1>:d    r2.0<0;1,0>:w     r54.0<1;1,0>:d   {F@1}
L11056:
        join (16|M0)                         L11400                                
L11072:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r58.0<1;0>:ud     r5.0<0;0>:ud      r24.0<1>:ud      {I@2} // (s0^s1)&s2
        cmp (16|M0)   (ne)f0.0   null<1>:d     r2.0<1;1,0>:d     0:w               {Compacted,I@1}
        bfn.0x60 (16|M0)         r6.0<1>:ud    r64.0<1;0>:ud     r5.0<0;0>:ud      r28.0<1>:ud      // (s0^s1)&s2
(~f0.0) cmp (16|M0)   (ne)f0.0   null<1>:d     r6.0<1;1,0>:d     0:w               {I@1}
(W)     mov (1|M0)               r4.12<1>:hf   -qnan(0x1FF):hf                             
        and (16|M0)   (ne)f1.1   r90.0<1>:d    r60.0<1;1,0>:d    63:w              
(f0.0)  sel (16|M0)              r8.0<1>:d     r4.12<0;1,0>:w    0:w               {F@1}
        mov (16|M0)              r94.0<1>:d    -r8.0<1;1,0>:d                   {I@1}
(f1.1)  goto (16|M0)                         L11232                  L11232                
L11208:
        mov (16|M0)              r42.0<1>:f    r24.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L11232                  L11336                
L11232:
        join (16|M0)                         L11336                                
L11248:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r90.0<1;1,0>:ud   0x20:uw             
(~f1.0) add (16|M0)              r2.0<1>:d     r90.0<1;1,0>:d    -32:w              
(~f1.0) shr (16|M0)              r42.0<1>:ud   r28.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.0)  add (16|M0)              r2.0<1>:d     -r90.0<1;1,0>:d   32:w               {Compacted}
(f1.0)  shr (16|M0)              r6.0<1>:ud    r24.0<1;1,0>:ud   r90.0<1;1,0>:d  
(f1.0)  shl (16|M0)              r2.0<1>:d     r28.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.0)  or (16|M0)               r42.0<1>:d    r6.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
L11336:
        join (16|M0)                         L11400                                
L11352:
        shl (16|M0)              r2.0<1>:d     r44.0<1;1,0>:d    1:w               {Compacted}
        mov (16|M0)              r100.0<1>:f   r42.0<1;1,0>:f                   {Compacted,I@3}
        and (16|M0)              r66.0<1>:d    r2.0<1;1,0>:d     2:w               {Compacted,I@1}
        mov (16|M0)              r42.0<1>:f    r50.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L11400                  L11488                
L11400:
        join (16|M0)                         L11488                                
L11416:
        shr (16|M0)              r42.0<1>:ud   r24.0<1;1,0>:ud   2:w               {F@1}
        mov (16|M0)              r94.0<1>:d    0:w                              
        mov (16|M0)              r66.0<1>:d    0:w                              
        mov (16|M0)              r100.0<1>:f   r42.0<1;1,0>:f                   {Compacted,I@3}
        shr (16|M0)              r42.0<1>:ud   r24.0<1;1,0>:ud   1:w               {F@1}
L11488:
        join (16|M0)                         L12008                                
L11504:
        shl (16|M0)              r2.0<1>:d     r42.0<1;1,0>:d    2:w               {Compacted,I@2}
        and (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     4:w               {Compacted,I@1}
        bfn.0xFE (16|M0)         r6.0<1>:ud    r2.0<1;0>:ud      r66.0<1;0>:ud     r94.0<1>:ud      {I@1} // s0|s1|s2
        cmp (16|M0)   (eq)f0.1   null<1>:d     r6.0<1;1,0>:d     0:w               {I@1}
        and (16|M0)              r54.0<1>:d    r100.0<1;1,0>:d   8388607:d              
(~f0.1) goto (16|M0)                         L11616                  L11616                
L11584:
        mov (16|M0)              r122.0<1>:d   0:w                              
        goto (16|M0)                         L11616                  L11776                
L11616:
        join (16|M0)                         L11776                                
L11632:
        cmp (16|M0)   (gt)f0.0   null<1>:d     r6.0<1;1,0>:ud    0x4:uw             
(~f0.0) goto (16|M0)                         L11696                  L11696                
L11664:
        mov (16|M0)              r122.0<1>:d   1:w                              
        goto (16|M0)                         L11696                  L11776                
L11696:
        join (16|M0)                         L11776                                
L11712:
        and (16|M0)   (ne)f1.1   null<1>:d     r100.0<1;1,0>:d   1:w              
(W)     mov (1|M0)               r2.0<1>:hf    0x1:hf                             
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r6.0<1;1,0>:d     4:w              
(f1.1)  sel (16|M0)              r122.0<1>:d   r2.0<0;1,0>:w     0:w               {F@1}
L11776:
        join (16|M0)                         L12008                                
L11792:
        add (16|M0)              r124.0<1>:d   r54.0<1;1,0>:d    r122.0<1;1,0>:d  {Compacted,I@2}
        cmp (16|M0)   (gt)f0.0   null<1>:d     r124.0<1;1,0>:ud  0x7FFFFF:ud              {I@1}
        add3 (16|M0)             r2.0<1>:d     r32.0<1;0>:d      r38.0<1;0>:d      -45:w              
(f0.0)  sel (16|M0)              r114.0<1>:d   r2.0<1;1,0>:d     r40.0<1;1,0>:d   {Compacted,I@1}
        cmp (16|M0)   (eq)f1.1   null<1>:d     r114.0<1;1,0>:d   255:w               {I@1}
(f1.1)  goto (16|M0)                         L11944                  L11944                
L11872:
(~f0.0) sel (16|M0)              r2.0<1>:d     r124.0<1;1,0>:d   0:w              
        and (16|M0)              r6.0<1>:d     r22.0<1;1,0>:d    -2147483648:d              
        shl (16|M0)              r8.0<1>:d     r114.0<1;1,0>:d   23:w               {Compacted}
        bfn.0xFE (16|M0)         r50.0<1>:ud   r6.0<1;0>:ud      r8.0<1;0>:ud      r2.0<1>:ud       {I@1} // s0|s1|s2
        goto (16|M0)                         L11944                  L12536                
L11944:
        join (16|M0)                         L12008                                
L11960:
        cmp (16|M0)   (gt)f0.1   null<1>:d     r22.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r2.0<1>:f     inf:f                               {Compacted,I@4}
(f0.1)  sel (16|M0)              r50.0<1>:f    r2.0<0;1,0>:f     -inf:f               {Compacted,F@1}
        goto (16|M0)                         L12008                  L12536                
L12008:
        join (16|M0)                         L12320                                
L12024:
        and (16|M0)   (ne)f1.0   r108.0<1>:d   r38.0<1;1,0>:d    63:w              
(f1.0)  goto (16|M0)                         L12088                  L12088                
L12056:
        mov (16|M0)              r116.0<1>:d   -1:w                              
        goto (16|M0)                         L12088                  L12216                
L12088:
        join (16|M0)                         L12216                                
L12104:
        cmp (16|M0)   (lt)f0.1   null<1>:d     r108.0<1;1,0>:ud  0x20:uw              {A@1}
(f0.1)  goto (16|M0)                         L12168                  L12168                
L12136:
        mov (16|M0)              r116.0<1>:d   0:w                              
        goto (16|M0)                         L12168                  L12216                
L12168:
        join (16|M0)                         L12216                                
L12184:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                             
        shl (16|M0)              r116.0<1>:d   r2.0<0;1,0>:w     r108.0<1;1,0>:d  {F@1}
L12216:
        join (16|M0)                         L12320                                
L12232:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r116.0<1;0>:ud    r5.0<0;0>:ud      r24.0<1>:ud      {I@2} // (s0^s1)&s2
        add (16|M0)              r6.0<1>:d     -r38.0<1;1,0>:d   23:w               {Compacted}
        and (16|M0)              r8.0<1>:d     r22.0<1;1,0>:d    -2147483648:d              
        shl (16|M0)              r10.0<1>:d    r40.0<1;1,0>:d    23:w               {Compacted}
        shl (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     r6.0<1;1,0>:d    {Compacted,I@3}
        bfn.0xFE (16|M0)         r50.0<1>:ud   r8.0<1;0>:ud      r10.0<1;0>:ud     r2.0<1>:ud       {I@1} // s0|s1|s2
        goto (16|M0)                         L12320                  L12536                
L12320:
        join (16|M0)                         L12376                                
L12336:
        cmp (16|M0)   (gt)f0.0   null<1>:d     r22.0<1;1,0>:d    -1:w               {Compacted}
(W)     mov (1|M0)               r2.0<1>:f     inf:f                               {Compacted,I@4}
(f0.0)  sel (16|M0)              r50.0<1>:f    r2.0<0;1,0>:f     -inf:f               {Compacted,F@1}
        goto (16|M0)                         L12376                  L12536                
L12376:
        join (16|M0)                         L12440                                
L12392:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r22.0<1;1,0>:d    0:w              
(W)     mov (1|M0)               r2.0<1>:f     -0.0:f                               {Compacted}
(f1.1)  sel (16|M0)              r50.0<1>:f    r2.0<0;1,0>:f     0.0:f               {Compacted,F@1}
        goto (16|M0)                         L12440                  L12536                
L12440:
        join (16|M0)                         L12504                                
L12456:
        cmp (16|M0)   (gt)f1.0   null<1>:d     r22.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r2.0<1>:f     inf:f                               {Compacted}
(f1.0)  sel (16|M0)              r50.0<1>:f    r2.0<0;1,0>:f     -inf:f               {Compacted,F@1}
        goto (16|M0)                         L12504                  L12536                
L12504:
        join (16|M0)                         L12536                                
L12520:
        bfn.0xF8 (16|M0)         r50.0<1>:ud   r22.0<1;0>:ud     r5.2<0;0>:ud      r5.1<0>:ud       {F@1} // s0&s1|s2
L12536:
        join (16|M0)                         L12552                                
L12552:
        cmp (16|M0)   (lt)f0.0   null<1>:f     r14.0<1;1,0>:f    0.0:f               {Compacted,I@7}
        shl (16|M0)              r8.0<1>:d     r12.0<1;1,0>:d    1:w               {Compacted}
        sync.nop                             null                             {Compacted,$1.dst}
(f0.0)  sel (16|M0)              r2.0<1>:f     -r50.0<1;1,0>:f   r50.0<1;1,0>:f   {Compacted,I@3}
(W)     mov (1|M0)               a0.0<1>:ud    r5.5<0;1,0>:d                    {A@1}
        mov (8|M0)               r6.0<1>:hf    r2.0<1;1,0>:f                    {F@1}
        mov (8|M8)               r6.8<1>:hf    r3.0<1;1,0>:f                   
        add (16|M0)              r8.0<1>:d     r8.0<1;1,0>:d     r5.4<0;1,0>:d    {Compacted,I@2}
        mov (16|M0)              r10.0<1>:ud   r6.0<1;1,0>:uw                   {A@1}
(W)     mov (8|M0)               r127.0<1>:f   r20.0<1;1,0>:f                   {Compacted}
        send.ugm (16|M0)         null     r8      r10:2   a0.0        0x240E0B04           {ExBSO,A@1,$4} // wr:2+2, rd:0; store.ugm.d16u32.a32.wb.wb.bss[a0.0]
(W)     send.gtwy (1|M0)         null     r127    null:0  0x0            0x02000010           {EOT,A@1} // wr:1+0, rd:0; end of thread
L12696:
        nop                    
(W)     mov (16|M0)              null<1>:ud    0x9E09665A:ud                             
(W)     mov (16|M0)              null<1>:ud    0xA6E09A48:ud                             
(W)     mov (16|M0)              null<1>:ud    0x0:ud                             
(W)     mov (16|M0)              null<1>:ud    0x69:ud                             
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
