L0:
(W)     mov (8|M0)               r127.0<1>:ud  0x0:ud                             
(W)     and (1|M0)               r127.2<1>:ud  r0.0<0;1,0>:ud    0xFFFFFFC0:ud             
(W)     and (1|M0)               r127.0<1>:uw  r0.4<0;1,0>:uw    0xFF:uw             
(W)     add (1|M0)               r127.2<1>:ud  r127.2<0;1,0>:ud  0x60:ud              {I@2}
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
(W)     add (1|M0)               r127.2<1>:ud  r127.2<0;1,0>:ud  0x40:uw              {$2.src}
(W)     send.dc0 (8|M0)          r7       r127    null:0  0x0            0x021842FD           {A@1,$3} // wr:1h+0, rd:1; oword aligned block read x2
(W)     mov (8|M0)               r38.0<1>:ud   r0.0<1;1,0>:ud                  
(W)     or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x4C0:uw              {A@1}
(W)     mul (1|M0)               acc0.0<1>:d   r4.3<0;1,0>:d     r38.2<0;1,0>:uw  {A@1}
(W)     cmp (16|M0)   (eq)f0.1   null<1>:d     r6.0<0;1,0>:d     0:w               {$2.dst}
(W)     mach (1|M0)              r2.0<1>:d     r4.3<0;1,0>:d     r38.1<0;1,0>:d   {$0.dst}
        add3 (16|M0)             r32.0<1>:d    r2.0<0;0>:d       r1.0<1;0>:uw      r4.0<0>:d        {I@1}
        and (16|M0)              r36.0<1>:d    r32.0<1;1,0>:d    31:w               {Compacted,I@1}
        shr (16|M0)              r34.0<1>:ud   r32.0<1;1,0>:ud   5:w              
(~f0.1) goto (16|M0)                         L456                  L456                
L424:
        mov (16|M0)              r102.0<1>:d   -1:w                              
        goto (16|M0)                         L456                  L816                
L456:
        join (16|M0)                         L816                                
L472:
(W)     xor (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x30:uw              {A@1}
(W)     mov (1|M0)               r2.0<1>:f     r6.0<0;1,0>:ud                   {Compacted,A@1}
(W)     mov (1|M0)               r3.2<1>:f     0xB4C00000:f                               {Compacted,$1.dst}
(W)     math.inv (1|M0)          r3.1<1>:f     r2.0<0;1,0>:f                    {@2,$4}
        mov (16|M0)              r8.0<1>:f     r34.0<1;1,0>:ud                  {Compacted,I@6}
        sync.nop                             null                             {Compacted,$4.dst}
(W)     mad (1|M0)               r4.6<1>:f     r3.1<0;0>:f       r3.2<0;0>:f       r3.1<0>:f        {F@2}
(W)     mov (1|M0)               r2.1<1>:ud    r2.0<0;1,0>:f                   
        mov (16|M0)              r12.0<1>:ud   r8.0<1;1,0>:f                    {F@2}
        mul (16|M0)              r10.0<1>:f    r8.0<1;1,0>:f     r4.6<0;1,0>:f    {Compacted,F@1}
(W)     add (1|M0)               r3.0<1>:d     r6.0<0;1,0>:d     -r2.1<0;1,0>:d   {Compacted,I@2}
        add (16|M0)              r12.0<1>:d    r34.0<1;1,0>:d    -r12.0<1;1,0>:d  {Compacted,I@2}
        mov (16|M0)              r14.0<1>:ud   r10.0<1;1,0>:f                   {F@1}
(W)     mov (1|M0)               r4.7<1>:f     r3.0<0;1,0>:ud                   {Compacted,I@3}
        mov (16|M0)              r16.0<1>:f    r12.0<1;1,0>:ud                  {Compacted,I@2}
        mov (16|M0)              r18.0<1>:f    r14.0<1;1,0>:ud                  {Compacted,I@1}
        mad (16|M0)              acc0.0<1>:f   r8.0<1;0>:f       r18.0<1;0>:f      -r2.0<0>:f       {Compacted,F@1}
        mad (16|M0)              acc2.0<1>:f   r16.0<1;0>:f      r18.0<1;0>:f      -r4.7<0>:f       {Compacted}
        add (16|M0)              acc0.0<1>:f   acc0.0<1;1,0>:f   acc2.0<1;1,0>:f 
        mul (16|M0)              r26.0<1>:f    r4.6<0;1,0>:f     acc0.0<1;1,0>:f 
(W)     xor (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x30:uw              {A@1}
        mov (16|M0)              r28.0<1>:ud   r26.0<1;1,0>:f                   {A@1}
        add (16|M0)              r30.0<1>:d    r28.0<1;1,0>:d    r14.0<1;1,0>:d   {Compacted,I@1}
(W)     mul (8|M0)               acc0.0<1>:d   r30.0<1;1,0>:d    r6.0<0;1,0>:uw   {Compacted,I@1}
        mach (8|M0)              r30.0<1>:d    r30.0<1;1,0>:d    r6.0<0;1,0>:d    {Compacted}
(W)     mul (8|M8)               acc0.0<1>:d   r31.0<1;1,0>:d    r6.0<0;1,0>:uw  
        mach (8|M8)              r31.0<1>:d    r31.0<1;1,0>:d    r6.0<0;1,0>:d    {Compacted}
        add (16|M0)              r30.0<1>:d    r34.0<1;1,0>:d    -r30.0<1;1,0>:d  {Compacted,I@1}
        cmp (16|M0)   (ge)f1.0   r8.0<1>:ud    r30.0<1;1,0>:ud   r6.0<0;1,0>:ud   {I@1}
        add3 (16|M0)             r102.0<1>:d   r28.0<1;0>:d      r14.0<1;0>:d      -r8.0<1>:d       {I@1}
L816:
        join (16|M0)                         L832                                
L832:
(W)     mul (8|M0)               acc0.0<1>:d   r102.0<1;1,0>:d   r6.0<0;1,0>:uw   {Compacted,I@2}
        mach (8|M0)              r2.0<1>:d     r102.0<1;1,0>:d   r6.0<0;1,0>:d    {Compacted}
(W)     mul (8|M8)               acc0.0<1>:d   r103.0<1;1,0>:d   r6.0<0;1,0>:uw  
        shr (16|M0)              r8.0<1>:ud    r102.0<1;1,0>:ud  1:w              
        mach (8|M8)              r3.0<1>:d     r103.0<1;1,0>:d   r6.0<0;1,0>:d    {Compacted,$1.dst}
(W)     mul (8|M0)               acc0.0<1>:d   r8.0<1;1,0>:d     r6.2<0;1,0>:uw   {Compacted,I@2}
        add (16|M0)              r2.0<1>:d     r34.0<1;1,0>:d    -r2.0<1;1,0>:d   {Compacted,I@2}
        mach (8|M0)              r8.0<1>:d     r8.0<1;1,0>:d     r6.1<0;1,0>:d    {Compacted}
(W)     mul (8|M8)               acc0.0<1>:d   r9.0<1;1,0>:d     r6.2<0;1,0>:uw  
        shr (16|M0)              r2.0<1>:ud    r2.0<1;1,0>:ud    1:w               {I@3}
        mach (8|M8)              r9.0<1>:d     r9.0<1;1,0>:d     r6.1<0;1,0>:d    {Compacted}
        shl (16|M0)              r10.0<1>:d    r36.0<1;1,0>:d    1:w               {Compacted}
        add (16|M0)              r8.0<1>:d     r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@2}
(W)     mov (1|M0)               a0.0<1>:ud    r6.7<0;1,0>:d                    {A@1}
        shl (16|M0)              r8.0<1>:d     r8.0<1;1,0>:d     6:w               {Compacted,I@2}
        add3 (16|M0)             r10.0<1>:d    r8.0<1;0>:d       r6.4<0;0>:d       r10.0<1>:d       {I@1}
        send.ugm (16|M0)         r12      r10     null:0  a0.0        0x24280B00           {ExBSO,A@1,$5} // wr:2+0, rd:2; load.ugm.d16u32.a32.ca.ca.bss[a0.0]
        shl (16|M0)              r40.0<1>:d    r36.0<1;1,0>:d    2:w               {Compacted}
(W)     mov (1|M0)               r6.2<1>:f     -0.0:f                               {Compacted}
(W)     mov (1|M0)               r6.0<1>:d     -1:w                              
(W)     mov (1|M0)               r6.1<1>:f     inf:f                               {Compacted}
        mov (16|M0)              r5.0<1>:uw    r12.0<2;1,0>:uw                  {$5.dst}
        mov (16|M0)              r94.0<1>:f    r5.0<1;1,0>:hf                   {I@1}
        shr (16|M0)              r102.0<1>:ud  r94.0<1;1,0>:ud   23:w               {F@1}
        and (16|M0)   (ne)f1.0   r24.0<1>:d    r94.0<1;1,0>:d    8388607:d              
        and (16|M0)              r18.0<1>:d    r102.0<1;1,0>:d   255:w               {Compacted,I@2}
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r18.0<1;1,0>:d    255:w               {I@1}
(~f1.0) goto (16|M0)                         L1200                  L1200                
L1168:
        mov (16|M0)              r98.0<1>:ud   0x7FC00000:ud                             
        goto (16|M0)                         L1200                  L7456                
L1200:
        join (16|M0)                         L7456                                
L1216:
        sync.nop                             null                             {Compacted,$3.dst}
(W)     mov (1|M0)               a0.0<1>:ud    r7.0<0;1,0>:d                    {A@1}
        send.ugm (16|M0)         r78      r40     null:0  a0.0        0x24280500           {ExBSO,$6} // wr:2+0, rd:2; load.ugm.d32.a32.ca.ca.bss[a0.0]
        shr (16|M0)              r100.0<1>:ud  r78.0<1;1,0>:ud   23:w               {$6.dst}
        and (16|M0)   (ne)f0.1   r22.0<1>:d    r78.0<1;1,0>:d    8388607:d              
        and (16|M0)              r20.0<1>:d    r100.0<1;1,0>:d   255:w               {Compacted,I@2}
(f0.1)  cmp (16|M0)   (eq)f0.1   null<1>:d     r20.0<1;1,0>:d    255:w               {I@1}
(~f0.1) goto (16|M0)                         L1360                  L1360                
L1328:
        mov (16|M0)              r98.0<1>:ud   0x7FC00000:ud                             
        goto (16|M0)                         L1360                  L7456                
L1360:
        join (16|M0)                         L7456                                
L1376:
        cmp (16|M0)   (eq)f0.0   null<1>:d     r24.0<1;1,0>:d    0:w               {Compacted}
        cmp (16|M0)   (eq)f1.1   null<1>:d     r22.0<1;1,0>:d    0:w              
(f0.0)  cmp (16|M0)   (eq)f0.0   null<1>:d     r18.0<1;1,0>:d    255:w              
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r20.0<1;1,0>:d    255:w              
(W)     mov (1|M0)               r2.0<1>:hf    0x1:hf                             
        xor (16|M0)              r42.0<1>:d    r78.0<1;1,0>:d    r94.0<1;1,0>:d   {Compacted}
(f0.0)  sel (16|M0)              acc0.0<1>:uw  r2.0<0;1,0>:uw    0x0:uw              {F@1}
(f1.1)  sel (16|M0)              acc2.0<1>:uw  r2.0<0;1,0>:uw    0x0:uw             
        or (16|M0)    (ne)f0.0   null<1>:uw    acc0.0<1;1,0>:uw  acc2.0<1;1,0>:uw
(f0.0)  goto (16|M0)                         L7424                  L7424                
L1520:
        or (16|M0)    (eq)f0.0   null<1>:d     r20.0<1;1,0>:d    r22.0<1;1,0>:d  
        or (16|M0)               r2.0<1>:d     r18.0<1;1,0>:d    r24.0<1;1,0>:d   {Compacted}
(~f0.0) cmp (16|M0)   (eq)f0.0   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
(~f0.0) goto (16|M0)                         L1608                  L1608                
L1576:
        mov (16|M0)              r98.0<1>:ud   0x0:ud                             
        goto (16|M0)                         L1608                  L7456                
L1608:
        join (16|M0)                         L7424                                
L1624:
        cmp (16|M0)   (eq)f0.1   null<1>:d     r18.0<1;1,0>:d    0:w              
        cmp (16|M0)   (eq)f0.0   null<1>:d     r20.0<1;1,0>:d    0:w               {Compacted}
        add (16|M0)              r76.0<1>:d    r18.0<1;1,0>:d    -127:w               {Compacted}
        add (16|M0)              r78.0<1>:d    r20.0<1;1,0>:d    -127:w               {Compacted}
(f0.1)  mov (16|M0)              r76.0<1>:d    -126:w                              
(f0.0)  mov (16|M0)              r78.0<1>:d    -126:w                              
        add (16|M0)              r50.0<1>:d    r76.0<1;1,0>:d    r78.0<1;1,0>:d   {Compacted,I@1}
        cmp (16|M0)   (gt)f1.1   null<1>:d     r50.0<1;1,0>:d    127:w               {I@1}
(f1.1)  goto (16|M0)                         L7360                  L7360                
L1736:
        or (16|M0)    (eq)f1.0   null<4>:b     r102.0<1;1,0>:d   r100.0<1;1,0>:d 
(f1.0)  goto (16|M0)                         L7296                  L7296                
L1768:
(W)     mov (1|M0)               r2.0<1>:hf    0.0:hf                             
(W)     mov (1|M0)               r6.7<1>:d     0:w                              
(f0.1)  sel (16|M0)              r8.0<1>:d     r2.0<0;1,0>:w     8388608:d               {F@1}
(f0.0)  sel (16|M0)              r10.0<1>:d    r2.0<0;1,0>:w     8388608:d              
        or (16|M0)               r8.0<1>:d     r8.0<1;1,0>:d     r24.0<1;1,0>:d   {Compacted,I@2}
        or (16|M0)               r10.0<1>:d    r10.0<1;1,0>:d    r22.0<1;1,0>:d   {Compacted,I@2}
        mul (8|M0)               acc0.0<1>:ud  r8.0<1;1,0>:ud    r10.0<2;1,0>:uw  {I@1}
        mach (8|M0)              r12.0<1>:ud   r8.0<1;1,0>:ud    r10.0<1;1,0>:ud  {AccWrEn,Compacted}
(W)     mov (1|M0)               r6.4<1>:f     -0.0:f                               {Compacted}
        mov (8|M0)               r14.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mul (8|M8)               acc0.0<1>:ud  r9.0<1;1,0>:ud    r11.0<2;1,0>:uw 
        mach (8|M8)              r13.0<1>:ud   r9.0<1;1,0>:ud    r11.0<1;1,0>:ud  {AccWrEn}
(W)     mov (2|M0)               r7.4<1>:d     0:w                              
        mov (8|M8)               r15.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mov (16|M0)              r48.0<1>:f    r12.0<1;1,0>:f                   {Compacted,A@3}
        mov (16|M0)              r44.0<1>:f    r14.0<1;1,0>:f                   {Compacted,I@1}
L1960:
(W)     shl (1|M0)               r2.0<1>:d     r6.4<0;1,0>:d     31:w               {Compacted,F@3}
(W)     shr (1|M0)               r2.1<1>:ud    r6.7<0;1,0>:ud    1:w              
(W)     cmp (16|M0)   (gt)f0.0   null<1>:d     r7.4<0;1,0>:ud    0x3E:uw             
(W)     or (1|M0)                r6.7<1>:d     r2.1<0;1,0>:d     r2.0<0;1,0>:d    {I@2}
        bfn.0xA8 (16|M0)         r8.0<1>:ud    r44.0<1;0>:ud     r2.1<0;0>:ud      r2.0<0>:ud       {F@1} // s0&(s1|s2)
(W)     shr (1|M0)               r6.3<1>:ud    r6.4<0;1,0>:ud    1:w              
(W&f0.0) cmp (16|M0)  (eq)f0.0   null<1>:d     r7.5<0;1,0>:d     0:w              
        cmp (16|M0)   (eq)f1.1   null<1>:d     r8.0<1;1,0>:d     r6.7<0;1,0>:d    {I@3}
        and (16|M0)              r10.0<1>:d    r48.0<1;1,0>:d    r6.3<0;1,0>:d    {Compacted,I@3}
(W&~f0.0) cmp (16|M0) (gt)f0.0   null<1>:d     r7.5<0;1,0>:ud    0x0:uw             
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r10.0<1;1,0>:d    r6.3<0;1,0>:d    {I@2}
(W)     mov (1|M0)               r4.12<1>:hf   0x1:hf                             
(W)     addc (1|M0)              r13.0<1>:ud   r7.4<0;1,0>:ud    0x1:ud              {AccWrEn}
(f0.0)  sel (16|M0)              r5.0<1>:uw    r4.12<0;1,0>:uw   0x0:uw              {Compacted,F@1}
(f1.1)  sel (16|M0)              acc2.0<1>:uw  r4.12<0;1,0>:uw   0x0:uw             
(W)     mov (1|M0)               r3.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        or (16|M0)    (ne)f1.0   null<1>:uw    r5.0<1;1,0>:uw    acc2.0<1;1,0>:uw {I@3}
(W)     add (1|M0)               r7.6<1>:ud    r3.0<0;1,0>:ud    r7.5<0;1,0>:ud   {I@2}
        mov (16|M0)              r118.0<1>:d   r7.4<0;1,0>:d                   
        mov (16|M0)              r116.0<1>:d   r7.5<0;1,0>:d                   
        mov (16|M0)              r86.0<1>:f    r13.0<0;1,0>:f                   {Compacted}
        mov (16|M0)              r16.0<1>:d    r7.6<0;1,0>:d                    {I@3}
(f1.0)  goto (16|M0)                         L2352                  L2352                
L2288:
(W)     mov (1|M0)               r6.4<1>:d     r6.3<0;1,0>:d                   
(W)     mov (1|M0)               r7.4<1>:d     r13.0<0;1,0>:d                  
(W)     mov (1|M0)               r7.5<1>:d     r7.6<0;1,0>:d                   
(W)     jmpi                                 L1960                                
L2352:
        join (16|M0)                         L7296                                
L2368:
(W)     mov (1|M0)               r2.0<1>:f     8.68805e-44:f                              
(W)     mov (1|M0)               r3.0<1>:hf    0.0:hf                             
        subb (8|M0)              r66.0<1>:ud   r2.0<0;1,0>:ud    r118.0<1;1,0>:ud {AccWrEn,Compacted,A@2}
        add3 (8|M0)              r108.0<1>:ud  -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r116.0<1>:ud    {A@1}
        subb (8|M8)              r67.0<1>:ud   r2.0<0;1,0>:ud    r119.0<1;1,0>:ud {AccWrEn}
        add3 (16|M0)             r88.0<1>:d    r50.0<1;0>:d      r66.0<1;0>:d      -46:w               {I@1}
        cmp (16|M0)   (gt)f0.1   null<1>:d     r88.0<1;1,0>:d    127:w               {I@1}
        add3 (8|M8)              r109.0<1>:ud  -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r117.0<1>:ud   
        add3 (16|M0)             r106.0<1>:d   r76.0<1;0>:d      r78.0<1;0>:d      r66.0<1>:d      
(f0.1)  goto (16|M0)                         L7240                  L7240                
L2520:
        cmp (16|M0)   (gt)f0.0   null<1>:d     r88.0<1;1,0>:d    -127:w               {Compacted}
(f0.0)  goto (16|M0)                         L4960                  L4960                
L2544:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r88.0<1;1,0>:ud   0xFFFFFF6B:ud             
(f1.1)  goto (16|M0)                         L4456                  L4456                
L2576:
(W)     mov (1|M0)               r2.0<1>:f     8.82818e-44:f                              
(W)     mov (1|M0)               r3.0<1>:hf    0.0:hf                              {I@7}
        subb (8|M0)              r122.0<1>:ud  r2.0<0;1,0>:ud    r118.0<1;1,0>:ud {AccWrEn,Compacted,F@2}
        add3 (16|M0)             r16.0<1>:d    r50.0<1;0>:d      r66.0<1;0>:d      104:w              
        add3 (8|M0)              r8.0<1>:ud    -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r116.0<1>:ud    {F@1}
        subb (8|M8)              r123.0<1>:ud  r2.0<0;1,0>:ud    r119.0<1;1,0>:ud {AccWrEn}
        cmp (16|M0)   (gt)f0.1   null<1>:d     r122.0<1;1,0>:ud  r16.0<1;1,0>:ud  {I@1}
        add3 (8|M8)              r9.0<1>:ud    -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r117.0<1>:ud   
(f0.1)  cmp (16|M0)   (eq)f0.1   null<1>:d     r8.0<1;1,0>:d     0:w               {I@1}
(~f0.1) cmp (16|M0)   (gt)f0.1   null<1>:d     r8.0<1;1,0>:ud    0x0:uw             
(f0.1)  goto (16|M0)                         L2800                  L2800                
L2744:
        add3 (16|M0)             r2.0<1>:d     r106.0<1;0>:d     -r122.0<1;0>:d    104:w              
        mov (16|M0)              r66.0<1>:d    0:w                              
        shl (16|M0)              r68.0<1>:d    r44.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
        goto (16|M0)                         L2800                  L4392                
L2800:
        join (16|M0)                         L4392                                
L2816:
        add3 (16|M0)             r106.0<1>:d   r122.0<1;0>:d     -r106.0<1;0>:d    -104:w              
        cmp (16|M0)   (lt)f1.0   null<1>:d     r106.0<1;1,0>:d   2:w               {Compacted,I@1}
(f1.0)  goto (16|M0)                         L2952                  L2952                
L2856:
        cmp (16|M0)   (eq)f0.1   null<1>:d     r106.0<1;1,0>:d   2:w              
(~f0.1) goto (16|M0)                         L2952                  L3048                
L2888:
        shr (16|M0)              r92.0<1>:ud   r44.0<1;1,0>:ud   1:w              
        and (16|M0)              r26.0<1>:d    r44.0<1;1,0>:d    1:w               {Compacted}
        mov (16|M0)              r10.0<1>:d    0:w                              
        mov (16|M0)              r126.0<1>:f   r92.0<1;1,0>:f                   {Compacted,I@3}
        goto (16|M0)                         L2952                  L3864                
L2952:
        join (16|M0)                         L3048                                
L2968:
        cmp (16|M0)   (eq)f0.0   null<1>:d     r106.0<1;1,0>:d   1:w               {Compacted}
(~f0.0) goto (16|M0)                         L3048                  L3048                
L2992:
        mov (16|M0)              r10.0<1>:d    0:w                              
        mov (16|M0)              r26.0<1>:d    0:w                              
        mov (16|M0)              r126.0<1>:f   r44.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L3048                  L3864                
L3048:
        join (16|M0)                         L3864                                
L3064:
        add3 (16|M0)             r2.0<1>:d     r122.0<1;0>:d     -r16.0<1;0>:d     -1:w              
        and (16|M0)   (ne)f1.1   r58.0<1>:d    r2.0<1;1,0>:d     63:w               {I@1}
(f1.1)  goto (16|M0)                         L3136                  L3136                
L3112:
        mov (16|M0)              r118.0<1>:f   r44.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L3136                  L3248                
L3136:
        join (16|M0)                         L3248                                
L3152:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r58.0<1;1,0>:ud   0x20:uw              {I@4}
(~f1.0) add (16|M0)              r2.0<1>:d     r58.0<1;1,0>:d    -32:w              
(~f1.0) shr (16|M0)              r92.0<1>:ud   r48.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.0)  add (16|M0)              r2.0<1>:d     -r58.0<1;1,0>:d   32:w               {Compacted}
(f1.0)  shr (16|M0)              r8.0<1>:ud    r44.0<1;1,0>:ud   r58.0<1;1,0>:d  
(f1.0)  shl (16|M0)              r2.0<1>:d     r48.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.0)  or (16|M0)               r92.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
        mov (16|M0)              r118.0<1>:f   r92.0<1;1,0>:f                   {Compacted,I@1}
L3248:
        join (16|M0)                         L3864                                
L3264:
        add3 (16|M0)             r90.0<1>:d    r122.0<1;0>:d     -r16.0<1;0>:d     -2:w              
        and (16|M0)   (ne)f0.1   r56.0<1>:d    r90.0<1;1,0>:d    63:w               {I@1}
(f0.1)  goto (16|M0)                         L3336                  L3336                
L3312:
        mov (16|M0)              r92.0<1>:f    r44.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L3336                  L3440                
L3336:
        join (16|M0)                         L3440                                
L3352:
        cmp (16|M0)   (lt)f0.0   null<1>:d     r56.0<1;1,0>:ud   0x20:uw              {I@4}
(~f0.0) add (16|M0)              r2.0<1>:d     r56.0<1;1,0>:d    -32:w              
(~f0.0) shr (16|M0)              r92.0<1>:ud   r48.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f0.0)  add (16|M0)              r2.0<1>:d     -r56.0<1;1,0>:d   32:w               {Compacted}
(f0.0)  shr (16|M0)              r8.0<1>:ud    r44.0<1;1,0>:ud   r56.0<1;1,0>:d  
(f0.0)  shl (16|M0)              r2.0<1>:d     r48.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f0.0)  or (16|M0)               r92.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
L3440:
        join (16|M0)                         L3864                                
L3456:
        and (16|M0)   (ne)f1.1   r76.0<1>:d    r90.0<1;1,0>:d    63:w              
        and (16|M0)              r26.0<1>:d    r92.0<1;1,0>:d    1:w               {Compacted,I@3}
(f1.1)  goto (16|M0)                         L3544                  L3544                
L3496:
        mov (16|M0)              r92.0<1>:d    -1:w                              
        mov (16|M0)              r102.0<1>:d   -1:w                              
        goto (16|M0)                         L3544                  L3728                
L3544:
        join (16|M0)                         L3728                                
L3560:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r76.0<1;1,0>:ud   0x20:uw              {I@7}
(f1.0)  goto (16|M0)                         L3664                  L3664                
L3592:
        add (16|M0)              r2.0<1>:d     r76.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r4.12<1>:hf   -qnan(0x1FF):hf                             
        mov (16|M0)              r92.0<1>:d    0:w                              
        shl (16|M0)              r102.0<1>:d   r4.12<0;1,0>:w    r2.0<1;1,0>:d    {A@1}
        goto (16|M0)                         L3664                  L3728                
L3664:
        join (16|M0)                         L3728                                
L3680:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (16|M0)              r102.0<1>:d   -1:w                              
        shl (16|M0)              r92.0<1>:d    r2.0<0;1,0>:w     r76.0<1;1,0>:d   {F@1}
L3728:
        join (16|M0)                         L3864                                
L3744:
        bfn.0x28 (16|M0)         r2.0<1>:ud    r44.0<1;0>:ud     r92.0<1;0>:ud     r6.0<0>:ud       {I@2} // s0&(s1^s2)
        cmp (16|M0)   (ne)f1.1   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
        bfn.0x28 (16|M0)         r8.0<1>:ud    r48.0<1;0>:ud     r102.0<1;0>:ud    r6.0<0>:ud       // s0&(s1^s2)
(~f1.1) cmp (16|M0)   (ne)f1.1   null<1>:d     r8.0<1;1,0>:d     0:w               {I@1}
(W)     mov (1|M0)               r4.12<1>:hf   -qnan(0x1FF):hf                             
        mov (16|M0)              r126.0<1>:f   r118.0<1;1,0>:f                  {Compacted}
(f1.1)  sel (16|M0)              r10.0<1>:d    r4.12<0;1,0>:w    0:w               {F@2}
        mov (16|M0)              r10.0<1>:d    -r10.0<1;1,0>:d                  {I@1}
L3864:
        join (16|M0)                         L4392                                
L3880:
        and (16|M0)   (ne)f0.1   r54.0<1>:d    r106.0<1;1,0>:d   63:w              
(f0.1)  goto (16|M0)                         L3936                  L3936                
L3912:
        mov (16|M0)              r92.0<1>:f    r44.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L3936                  L4040                
L3936:
        join (16|M0)                         L4040                                
L3952:
        cmp (16|M0)   (lt)f0.0   null<1>:d     r54.0<1;1,0>:ud   0x20:uw              {I@4}
(~f0.0) add (16|M0)              r2.0<1>:d     r54.0<1;1,0>:d    -32:w              
(~f0.0) shr (16|M0)              r92.0<1>:ud   r48.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f0.0)  add (16|M0)              r2.0<1>:d     -r54.0<1;1,0>:d   32:w               {Compacted}
(f0.0)  shr (16|M0)              r8.0<1>:ud    r44.0<1;1,0>:ud   r54.0<1;1,0>:d  
(f0.0)  shl (16|M0)              r2.0<1>:d     r48.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f0.0)  or (16|M0)               r92.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
L4040:
        join (16|M0)                         L4392                                
L4056:
        shl (16|M0)              r2.0<1>:d     r126.0<1;1,0>:d   2:w               {Compacted}
        shl (16|M0)              r8.0<1>:d     r26.0<1;1,0>:d    1:w               {Compacted}
        and (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     4:w               {Compacted,I@2}
        bfn.0xFE (16|M0)         r116.0<1>:ud  r2.0<1;0>:ud      r8.0<1;0>:ud      r10.0<1>:ud      {I@1} // s0|s1|s2
        cmp (16|M0)   (eq)f1.1   null<1>:d     r116.0<1;1,0>:d   0:w               {I@1}
(~f1.1) goto (16|M0)                         L4160                  L4160                
L4128:
        mov (16|M0)              r12.0<1>:d    0:w                              
        goto (16|M0)                         L4160                  L4320                
L4160:
        join (16|M0)                         L4320                                
L4176:
        cmp (16|M0)   (gt)f1.0   null<1>:d     r116.0<1;1,0>:ud  0x4:uw             
(~f1.0) goto (16|M0)                         L4240                  L4240                
L4208:
        mov (16|M0)              r12.0<1>:d    1:w                              
        goto (16|M0)                         L4240                  L4320                
L4240:
        join (16|M0)                         L4320                                
L4256:
        and (16|M0)   (ne)f1.0   null<1>:d     r92.0<1;1,0>:d    1:w              
(W)     mov (1|M0)               r2.0<1>:hf    0x1:hf                             
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r116.0<1;1,0>:d   4:w              
(f1.0)  sel (16|M0)              r12.0<1>:d    r2.0<0;1,0>:w     0:w               {F@1}
L4320:
        join (16|M0)                         L4392                                
L4336:
        add (16|M0)              r2.0<1>:d     r12.0<1;1,0>:d    r92.0<1;1,0>:d   {Compacted,I@2}
        cmp (16|M0)   (gt)f1.1   null<1>:d     r2.0<1;1,0>:ud    0x7FFFFF:ud              {I@1}
(W)     mov (1|M0)               r4.6<1>:f     0x800000:f                               {Compacted}
(~f1.1) sel (16|M0)              r68.0<1>:d    r2.0<1;1,0>:d     0:w              
(f1.1)  sel (16|M0)              r66.0<1>:d    r4.6<0;1,0>:d     0:w               {Compacted,F@1}
L4392:
        join (16|M0)                         L4456                                
L4408:
        and (16|M0)              r2.0<1>:d     r42.0<1;1,0>:d    -2147483648:d              
        bfn.0xFE (16|M0)         r98.0<1>:ud   r2.0<1;0>:ud      r66.0<1;0>:ud     r68.0<1>:ud      {I@1} // s0|s1|s2
        goto (16|M0)                         L4456                  L7456                
L4456:
        join (16|M0)                         L4960                                
L4472:
        and (16|M0)   (ne)f0.1   r54.0<1>:d    r66.0<1;1,0>:d    63:w              
(f0.1)  goto (16|M0)                         L4552                  L4552                
L4504:
        mov (16|M0)              r66.0<1>:d    -1:w                              
        mov (16|M0)              r74.0<1>:d    -1:w                              
        goto (16|M0)                         L4552                  L4736                
L4552:
        join (16|M0)                         L4736                                
L4568:
        cmp (16|M0)   (lt)f0.0   null<1>:d     r54.0<1;1,0>:ud   0x20:uw              {I@6}
(f0.0)  goto (16|M0)                         L4672                  L4672                
L4600:
        add (16|M0)              r2.0<1>:d     r54.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r4.12<1>:hf   -qnan(0x1FF):hf                             
        mov (16|M0)              r66.0<1>:d    0:w                              
        shl (16|M0)              r74.0<1>:d    r4.12<0;1,0>:w    r2.0<1;1,0>:d    {A@1}
        goto (16|M0)                         L4672                  L4736                
L4672:
        join (16|M0)                         L4736                                
L4688:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (16|M0)              r74.0<1>:d    -1:w                              
        shl (16|M0)              r66.0<1>:d    r2.0<0;1,0>:w     r54.0<1;1,0>:d   {F@1}
L4736:
        join (16|M0)                         L4960                                
L4752:
        bfn.0x28 (16|M0)         r2.0<1>:ud    r44.0<1;0>:ud     r66.0<1;0>:ud     r6.0<0>:ud       {I@2} // s0&(s1^s2)
        cmp (16|M0)   (ne)f1.0   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
        bfn.0x28 (16|M0)         r8.0<1>:ud    r48.0<1;0>:ud     r74.0<1;0>:ud     r6.0<0>:ud       // s0&(s1^s2)
        cmp (16|M0)   (gt)f1.1   null<1>:d     r42.0<1;1,0>:d    -1:w              
(~f1.0) cmp (16|M0)   (ne)f1.0   null<1>:d     r8.0<1;1,0>:d     0:w               {I@2}
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r88.0<1;1,0>:d    -150:w              
(f1.1)  goto (16|M0)                         L4904                  L4904                
L4864:
(W)     mov (1|M0)               r2.0<1>:ud    0x80000001:ud                             
(f1.0)  sel (16|M0)              r98.0<1>:f    r2.0<0;1,0>:f     -0.0:f               {Compacted,I@1}
        goto (16|M0)                         L4904                  L7456                
L4904:
        join (16|M0)                         L4960                                
L4920:
(W)     mov (1|M0)               r2.0<1>:ud    0x1:ud                              {F@1}
(f1.0)  sel (16|M0)              r98.0<1>:f    r2.0<0;1,0>:f     0.0:f               {Compacted,I@1}
        goto (16|M0)                         L4960                  L7456                
L4960:
        join (16|M0)                         L7240                                
L4976:
        cmp (16|M0)   (lt)f0.1   null<1>:d     r66.0<1;1,0>:ud   0x18:uw             
        add3 (16|M0)             r74.0<1>:d    r50.0<1;0>:d      r66.0<1;0>:d      81:w              
(f0.1)  cmp (16|M0)   (eq)f0.1   null<1>:d     r108.0<1;1,0>:d   0:w              
(f0.1)  goto (16|M0)                         L6928                  L6928                
L5040:
        shl (16|M0)              r2.0<1>:d     r86.0<1;1,0>:d    1:w               {Compacted,F@1}
        shr (16|M0)              r8.0<1>:ud    r86.0<1;1,0>:ud   31:w              
        shl (16|M0)              r10.0<1>:d    r16.0<1;1,0>:d    1:w               {Compacted}
        cmp (16|M0)   (lt)f0.0   null<1>:d     r2.0<1;1,0>:ud    0x4E:uw              {I@3}
        or (16|M0)               r10.0<1>:d    r10.0<1;1,0>:d    r8.0<1;1,0>:d    {Compacted,I@2}
(f0.0)  cmp (16|M0)   (eq)f0.0   null<1>:d     r10.0<1;1,0>:d    0:w               {I@1}
(~f0.0) cmp (16|M0)   (lt)f0.0   null<1>:d     r10.0<1;1,0>:d    0:w              
(f0.0)  goto (16|M0)                         L5264                  L5264                
L5144:
        cmp (16|M0)   (eq)f0.0   null<1>:d     r86.0<1;1,0>:d    39:w               {Compacted}
(f0.0)  cmp (16|M0)   (eq)f0.0   null<1>:d     r16.0<1;1,0>:d    0:w              
(~f0.0) goto (16|M0)                         L5264                  L5328                
L5184:
        shr (16|M0)              r92.0<1>:ud   r44.0<1;1,0>:ud   1:w              
        mov (16|M0)              r20.0<1>:d    0:w                              
        mov (16|M0)              r30.0<1>:d    0:w                              
        mov (16|M0)              r80.0<1>:f    r92.0<1;1,0>:f                   {Compacted,I@3}
        mov (16|M0)              r92.0<1>:f    r44.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L5264                  L6408                
L5264:
        join (16|M0)                         L5328                                
L5280:
        cmp (16|M0)   (eq)f1.1   null<1>:d     r86.0<1;1,0>:d    38:w              
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r16.0<1;1,0>:d    0:w              
(f1.1)  goto (16|M0)                         L5328                  L6328                
L5328:
        join (16|M0)                         L6328                                
L5344:
        add (16|M0)              r2.0<1>:d     -r86.0<1;1,0>:d   39:w               {Compacted}
        and (16|M0)   (ne)f1.0   r62.0<1>:d    r2.0<1;1,0>:d     63:w               {I@1}
        add (16|M0)              r52.0<1>:d    -r86.0<1;1,0>:d   40:w               {Compacted}
(f1.0)  goto (16|M0)                         L5416                  L5416                
L5392:
        mov (16|M0)              r126.0<1>:f   r44.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L5416                  L5528                
L5416:
        join (16|M0)                         L5528                                
L5432:
        cmp (16|M0)   (lt)f0.1   null<1>:d     r62.0<1;1,0>:ud   0x20:uw              {I@5}
(~f0.1) add (16|M0)              r2.0<1>:d     r62.0<1;1,0>:d    -32:w              
(~f0.1) shr (16|M0)              r92.0<1>:ud   r48.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f0.1)  add (16|M0)              r2.0<1>:d     -r62.0<1;1,0>:d   32:w               {Compacted}
(f0.1)  shr (16|M0)              r8.0<1>:ud    r44.0<1;1,0>:ud   r62.0<1;1,0>:d  
(f0.1)  shl (16|M0)              r2.0<1>:d     r48.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f0.1)  or (16|M0)               r92.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
        mov (16|M0)              r126.0<1>:f   r92.0<1;1,0>:f                   {Compacted,I@1}
L5528:
        join (16|M0)                         L6328                                
L5544:
        add (16|M0)              r104.0<1>:d   -r86.0<1;1,0>:d   38:w               {Compacted}
        and (16|M0)   (ne)f0.0   r68.0<1>:d    r104.0<1;1,0>:d   63:w               {Compacted,I@1}
(f0.0)  goto (16|M0)                         L5600                  L5600                
L5576:
        mov (16|M0)              r92.0<1>:f    r44.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L5600                  L5704                
L5600:
        join (16|M0)                         L5704                                
L5616:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r68.0<1;1,0>:ud   0x20:uw              {I@4}
(~f1.1) add (16|M0)              r2.0<1>:d     r68.0<1;1,0>:d    -32:w              
(~f1.1) shr (16|M0)              r92.0<1>:ud   r48.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.1)  add (16|M0)              r2.0<1>:d     -r68.0<1;1,0>:d   32:w               {Compacted}
(f1.1)  shr (16|M0)              r8.0<1>:ud    r44.0<1;1,0>:ud   r68.0<1;1,0>:d  
(f1.1)  shl (16|M0)              r2.0<1>:d     r48.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.1)  or (16|M0)               r92.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
L5704:
        join (16|M0)                         L6328                                
L5720:
        and (16|M0)   (ne)f1.0   r112.0<1>:d   r104.0<1;1,0>:d   63:w              
        and (16|M0)              r30.0<1>:d    r92.0<1;1,0>:d    1:w               {Compacted,I@3}
(f1.0)  goto (16|M0)                         L5808                  L5808                
L5760:
        mov (16|M0)              r118.0<1>:d   -1:w                              
        mov (16|M0)              r124.0<1>:d   -1:w                              
        goto (16|M0)                         L5808                  L5992                
L5808:
        join (16|M0)                         L5992                                
L5824:
        cmp (16|M0)   (lt)f0.1   null<1>:d     r112.0<1;1,0>:ud  0x20:uw              {I@7}
(f0.1)  goto (16|M0)                         L5928                  L5928                
L5856:
        add (16|M0)              r2.0<1>:d     r112.0<1;1,0>:d   -32:w               {Compacted}
(W)     mov (1|M0)               r4.12<1>:hf   -qnan(0x1FF):hf                             
        mov (16|M0)              r118.0<1>:d   0:w                              
        shl (16|M0)              r124.0<1>:d   r4.12<0;1,0>:w    r2.0<1;1,0>:d    {A@1}
        goto (16|M0)                         L5928                  L5992                
L5928:
        join (16|M0)                         L5992                                
L5944:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (16|M0)              r124.0<1>:d   -1:w                              
        shl (16|M0)              r118.0<1>:d   r2.0<0;1,0>:w     r112.0<1;1,0>:d  {F@1}
L5992:
        join (16|M0)                         L6328                                
L6008:
        bfn.0x28 (16|M0)         r2.0<1>:ud    r44.0<1;0>:ud     r118.0<1;0>:ud    r6.0<0>:ud       {I@2} // s0&(s1^s2)
        cmp (16|M0)   (ne)f1.0   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
        bfn.0x28 (16|M0)         r8.0<1>:ud    r48.0<1;0>:ud     r124.0<1;0>:ud    r6.0<0>:ud       // s0&(s1^s2)
(~f1.0) cmp (16|M0)   (ne)f1.0   null<1>:d     r8.0<1;1,0>:d     0:w               {I@1}
(W)     mov (1|M0)               r4.12<1>:hf   -qnan(0x1FF):hf                             
        and (16|M0)   (ne)f0.0   r64.0<1>:d    r52.0<1;1,0>:d    63:w               {Compacted}
(f1.0)  sel (16|M0)              r10.0<1>:d    r4.12<0;1,0>:w    0:w               {F@1}
        mov (16|M0)              r20.0<1>:d    -r10.0<1;1,0>:d                  {I@1}
(f0.0)  goto (16|M0)                         L6168                  L6168                
L6144:
        mov (16|M0)              r92.0<1>:f    r44.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L6168                  L6272                
L6168:
        join (16|M0)                         L6272                                
L6184:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r64.0<1;1,0>:ud   0x20:uw             
(~f1.1) add (16|M0)              r2.0<1>:d     r64.0<1;1,0>:d    -32:w              
(~f1.1) shr (16|M0)              r92.0<1>:ud   r48.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.1)  add (16|M0)              r2.0<1>:d     -r64.0<1;1,0>:d   32:w               {Compacted}
(f1.1)  shr (16|M0)              r8.0<1>:ud    r44.0<1;1,0>:ud   r64.0<1;1,0>:d  
(f1.1)  shl (16|M0)              r2.0<1>:d     r48.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.1)  or (16|M0)               r92.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
L6272:
        join (16|M0)                         L6328                                
L6288:
        mov (16|M0)              r80.0<1>:f    r92.0<1;1,0>:f                   {Compacted,I@2}
        mov (16|M0)              r92.0<1>:d    r126.0<1;1,0>:d                  {F@1}
        goto (16|M0)                         L6328                  L6408                
L6328:
        join (16|M0)                         L6408                                
L6344:
        shr (16|M0)              r92.0<1>:ud   r44.0<1;1,0>:ud   2:w              
        and (16|M0)              r30.0<1>:d    r44.0<1;1,0>:d    1:w               {Compacted}
        mov (16|M0)              r20.0<1>:d    0:w                              
        mov (16|M0)              r80.0<1>:f    r92.0<1;1,0>:f                   {Compacted,I@3}
        shr (16|M0)              r92.0<1>:ud   r44.0<1;1,0>:ud   1:w               {F@1}
L6408:
        join (16|M0)                         L6928                                
L6424:
        shl (16|M0)              r2.0<1>:d     r92.0<1;1,0>:d    2:w               {Compacted,I@2}
        shl (16|M0)              r8.0<1>:d     r30.0<1;1,0>:d    1:w               {Compacted}
        and (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     4:w               {Compacted,I@2}
        bfn.0xFE (16|M0)         r64.0<1>:ud   r2.0<1;0>:ud      r8.0<1;0>:ud      r20.0<1>:ud      {I@1} // s0|s1|s2
        cmp (16|M0)   (eq)f1.0   null<1>:d     r64.0<1;1,0>:d    0:w               {I@1}
        and (16|M0)              r44.0<1>:d    r80.0<1;1,0>:d    8388607:d              
(~f1.0) goto (16|M0)                         L6544                  L6544                
L6512:
        mov (16|M0)              r52.0<1>:d    0:w                              
        goto (16|M0)                         L6544                  L6704                
L6544:
        join (16|M0)                         L6704                                
L6560:
        cmp (16|M0)   (gt)f0.1   null<1>:d     r64.0<1;1,0>:ud   0x4:uw             
(~f0.1) goto (16|M0)                         L6624                  L6624                
L6592:
        mov (16|M0)              r52.0<1>:d    1:w                              
        goto (16|M0)                         L6624                  L6704                
L6624:
        join (16|M0)                         L6704                                
L6640:
        and (16|M0)   (ne)f0.1   null<1>:d     r80.0<1;1,0>:d    1:w              
(W)     mov (1|M0)               r2.0<1>:hf    0x1:hf                             
(f0.1)  cmp (16|M0)   (eq)f0.1   null<1>:d     r64.0<1;1,0>:d    4:w              
(f0.1)  sel (16|M0)              r52.0<1>:d    r2.0<0;1,0>:w     0:w               {F@1}
L6704:
        join (16|M0)                         L6928                                
L6720:
        add (16|M0)              r78.0<1>:d    r44.0<1;1,0>:d    r52.0<1;1,0>:d   {Compacted,I@2}
        cmp (16|M0)   (gt)f1.1   null<1>:d     r78.0<1;1,0>:ud   0x7FFFFF:ud              {I@1}
        add3 (16|M0)             r2.0<1>:d     r50.0<1;0>:d      r66.0<1;0>:d      82:w              
(f1.1)  sel (16|M0)              r72.0<1>:d    r2.0<1;1,0>:d     r74.0<1;1,0>:d   {Compacted,I@1}
        cmp (16|M0)   (eq)f0.0   null<1>:d     r72.0<1;1,0>:d    255:w               {Compacted,I@1}
(f0.0)  goto (16|M0)                         L6864                  L6864                
L6792:
(~f1.1) sel (16|M0)              r2.0<1>:d     r78.0<1;1,0>:d    0:w              
        and (16|M0)              r8.0<1>:d     r42.0<1;1,0>:d    -2147483648:d              
        shl (16|M0)              r10.0<1>:d    r72.0<1;1,0>:d    23:w               {Compacted}
        bfn.0xFE (16|M0)         r98.0<1>:ud   r8.0<1;0>:ud      r10.0<1;0>:ud     r2.0<1>:ud       {I@1} // s0|s1|s2
        goto (16|M0)                         L6864                  L7456                
L6864:
        join (16|M0)                         L6928                                
L6880:
        cmp (16|M0)   (gt)f0.1   null<1>:d     r42.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r2.0<1>:f     inf:f                               {Compacted,I@4}
(f0.1)  sel (16|M0)              r98.0<1>:f    r2.0<0;1,0>:f     -inf:f               {Compacted,F@1}
        goto (16|M0)                         L6928                  L7456                
L6928:
        join (16|M0)                         L7240                                
L6944:
        and (16|M0)   (ne)f1.1   r64.0<1>:d    r66.0<1;1,0>:d    63:w              
(f1.1)  goto (16|M0)                         L7008                  L7008                
L6976:
        mov (16|M0)              r46.0<1>:d    -1:w                              
        goto (16|M0)                         L7008                  L7136                
L7008:
        join (16|M0)                         L7136                                
L7024:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r64.0<1;1,0>:ud   0x20:uw              {I@5}
(f1.0)  goto (16|M0)                         L7088                  L7088                
L7056:
        mov (16|M0)              r46.0<1>:d    0:w                              
        goto (16|M0)                         L7088                  L7136                
L7088:
        join (16|M0)                         L7136                                
L7104:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                             
        shl (16|M0)              r46.0<1>:d    r2.0<0;1,0>:w     r64.0<1;1,0>:d   {F@1}
L7136:
        join (16|M0)                         L7240                                
L7152:
        bfn.0x28 (16|M0)         r2.0<1>:ud    r44.0<1;0>:ud     r46.0<1;0>:ud     r6.0<0>:ud       {I@2} // s0&(s1^s2)
        add (16|M0)              r8.0<1>:d     -r66.0<1;1,0>:d   23:w               {Compacted}
        and (16|M0)              r10.0<1>:d    r42.0<1;1,0>:d    -2147483648:d              
        shl (16|M0)              r12.0<1>:d    r74.0<1;1,0>:d    23:w               {Compacted}
        shl (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     r8.0<1;1,0>:d    {Compacted,I@3}
        bfn.0xFE (16|M0)         r98.0<1>:ud   r10.0<1;0>:ud     r12.0<1;0>:ud     r2.0<1>:ud       {I@1} // s0|s1|s2
        goto (16|M0)                         L7240                  L7456                
L7240:
        join (16|M0)                         L7296                                
L7256:
        cmp (16|M0)   (gt)f0.0   null<1>:d     r42.0<1;1,0>:d    -1:w               {Compacted}
(W)     mov (1|M0)               r2.0<1>:f     inf:f                               {Compacted,I@4}
(f0.0)  sel (16|M0)              r98.0<1>:f    r2.0<0;1,0>:f     -inf:f               {Compacted,F@1}
        goto (16|M0)                         L7296                  L7456                
L7296:
        join (16|M0)                         L7360                                
L7312:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r42.0<1;1,0>:d    0:w              
(W)     mov (1|M0)               r2.0<1>:f     -0.0:f                               {Compacted}
(f1.1)  sel (16|M0)              r98.0<1>:f    r2.0<0;1,0>:f     0.0:f               {Compacted,F@1}
        goto (16|M0)                         L7360                  L7456                
L7360:
        join (16|M0)                         L7424                                
L7376:
        cmp (16|M0)   (gt)f1.0   null<1>:d     r42.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r2.0<1>:f     inf:f                               {Compacted}
(f1.0)  sel (16|M0)              r98.0<1>:f    r2.0<0;1,0>:f     -inf:f               {Compacted,F@1}
        goto (16|M0)                         L7424                  L7456                
L7424:
        join (16|M0)                         L7456                                
L7440:
        bfn.0xF8 (16|M0)         r98.0<1>:ud   r42.0<1;0>:ud     r6.2<0;0>:ud      r6.1<0>:ud       {F@1} // s0&s1|s2
L7456:
        join (16|M0)                         L7472                                
L7472:
        shl (16|M0)              r34.0<1>:d    r32.0<1;1,0>:d    1:w               {Compacted}
        sync.nop                             null                             {Compacted,$3.dst}
(W)     mov (1|M0)               a0.0<1>:ud    r7.1<0;1,0>:d                    {A@1}
        add (16|M0)              r2.0<1>:d     r34.0<1;1,0>:d    r6.5<0;1,0>:d    {Compacted,I@2}
        or (16|M0)               r10.0<1>:d    r40.0<1;1,0>:d    128:w               {Compacted}
        send.ugm (16|M0)         r8       r2      null:0  a0.0        0x24280B00           {ExBSO,A@2,$7} // wr:2+0, rd:2; load.ugm.d16u32.a32.ca.ca.bss[a0.0]
(W)     mov (1|M0)               a0.0<1>:ud    r7.0<0;1,0>:d                    {A@1}
        shl (16|M0)              r2.0<1>:d     r32.0<1;1,0>:d    2:w               {Compacted,$7.src}
        send.ugm (16|M0)         r12      r10     null:0  a0.0        0x24280500           {ExBSO,A@3,$8} // wr:2+0, rd:2; load.ugm.d32.a32.ca.ca.bss[a0.0]
(W)     mov (1|M0)               a0.0<1>:ud    r7.2<0;1,0>:d                    {A@1}
        mov (16|M0)              r5.0<1>:uw    r8.0<2;1,0>:uw                   {$7.dst}
        mov (16|M0)              acc0.0<1>:f   r5.0<1;1,0>:hf                   {I@1}
        mad (16|M0)              r36.0<1>:f    r98.0<1;0>:f      acc0.0<1;0>:f     r12.0<1>:f       {Compacted,$8.dst}
        and (16|M0)              r16.0<1>:d    r36.0<1;1,0>:d    2147483647:d               {F@1}
        sel (16|M0)   (lt)f0.0   r62.0<1>:f    r16.0<1;1,0>:f    448.0:f               {Compacted,I@1}
        shr (16|M0)              r86.0<1>:ud   r62.0<1;1,0>:ud   23:w               {F@1}
        and (16|M0)   (ne)f0.0   r122.0<1>:d   r62.0<1;1,0>:d    8388607:d              
        and (16|M0)              r112.0<1>:d   r86.0<1;1,0>:d    255:w               {Compacted,I@2}
(f0.0)  cmp (16|M0)   (eq)f0.0   null<1>:d     r112.0<1;1,0>:d   255:w               {I@1}
        sel (16|M0)   (ge)f0.0   r18.0<1>:ud   r112.0<1;1,0>:ud  0x79:uw             
        send.ugm (16|M0)         null     r2      r36:2   a0.0        0x240E0504           {ExBSO,$9} // wr:2+2, rd:0; store.ugm.d32.a32.wb.wb.bss[a0.0]
        shl (16|M0)              r46.0<1>:d    r18.0<1;1,0>:d    23:w               {Compacted,I@1}
(~f0.0) goto (16|M0)                         L7800                  L7800                
L7768:
        mov (16|M0)              r96.0<1>:ud   0x7FC00000:ud                             
        goto (16|M0)                         L7800                  L13704                
L7800:
        join (16|M0)                         L13704                                
L7816:
        cmp (16|M0)   (eq)f1.1   null<1>:d     r122.0<1;1,0>:d   0:w              
        add (16|M0)              r56.0<1>:d    -r46.0<1;1,0>:d   -2139095040:d               {I@6}
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r112.0<1;1,0>:d   255:w              
        xor (16|M0)              r54.0<1>:d    r56.0<1;1,0>:d    r62.0<1;1,0>:d   {Compacted,I@2}
(f1.1)  goto (16|M0)                         L13672                  L13672                
L7888:
        or (16|M0)    (eq)f0.1   null<1>:d     r112.0<1;1,0>:d   r122.0<1;1,0>:d 
(~f0.1) goto (16|M0)                         L7952                  L7952                
L7920:
        mov (16|M0)              r96.0<1>:ud   0x0:ud                             
        goto (16|M0)                         L7952                  L13704                
L7952:
        join (16|M0)                         L13672                                
L7968:
        cmp (16|M0)   (eq)f0.1   null<1>:d     r112.0<1;1,0>:d   0:w              
        shr (16|M0)              r32.0<1>:ud   r56.0<1;1,0>:ud   23:w              
        add (16|M0)              r120.0<1>:d   r112.0<1;1,0>:d   -127:w               {Compacted}
(f0.1)  mov (16|M0)              r120.0<1>:d   -126:w                              
        add (16|M0)              r68.0<1>:d    r32.0<1;1,0>:d    r120.0<1;1,0>:d  {Compacted,I@1}
        cmp (16|M0)   (gt)f0.0   null<1>:d     r68.0<1;1,0>:d    254:w               {Compacted,I@1}
(f0.0)  goto (16|M0)                         L13608                  L13608                
L8056:
        or (16|M0)    (eq)f1.1   null<4>:b     r86.0<1;1,0>:d    r32.0<1;1,0>:d  
(f1.1)  goto (16|M0)                         L13544                  L13544                
L8088:
(W)     mov (1|M0)               r2.0<1>:hf    0.0:hf                              {$9.src}
(W)     mov (1|M0)               r7.0<1>:d     0:w                              
(f0.1)  sel (16|M0)              r8.0<1>:d     r2.0<0;1,0>:w     8388608:d               {F@1}
        or (16|M0)               r8.0<1>:d     r8.0<1;1,0>:d     r122.0<1;1,0>:d  {Compacted,I@1}
        shl (16|M0)              r58.0<1>:d    r8.0<1;1,0>:d     23:w               {Compacted,I@1}
        shr (16|M0)              r62.0<1>:ud   r8.0<1;1,0>:ud    9:w              
(W)     mov (1|M0)               r6.7<1>:f     -0.0:f                               {Compacted}
(W)     mov (2|M0)               r6.4<1>:d     0:w                              
L8192:
(W)     shl (1|M0)               r2.0<1>:d     r6.7<0;1,0>:d     31:w               {Compacted,F@1}
(W)     shr (1|M0)               r2.1<1>:ud    r7.0<0;1,0>:ud    1:w              
(W)     cmp (16|M0)   (gt)f1.1   null<1>:d     r6.4<0;1,0>:ud    0x3E:uw              {I@3}
(W)     or (1|M0)                r7.0<1>:d     r2.1<0;1,0>:d     r2.0<0;1,0>:d    {Compacted,I@2}
        bfn.0xE0 (16|M0)         r8.0<1>:ud    r2.1<0;0>:ud      r2.0<0;0>:ud      r58.0<1>:ud      // (s0|s1)&s2
(W)     shr (1|M0)               r6.3<1>:ud    r6.7<0;1,0>:ud    1:w              
(W&f1.1) cmp (16|M0)  (eq)f1.1   null<1>:d     r6.5<0;1,0>:d     0:w              
        cmp (16|M0)   (eq)f1.0   null<1>:d     r8.0<1;1,0>:d     r7.0<0;1,0>:d    {I@3}
        and (16|M0)              r10.0<1>:d    r6.3<0;1,0>:d     r62.0<1;1,0>:d   {Compacted,I@3}
(W&~f1.1) cmp (16|M0) (gt)f1.1   null<1>:d     r6.5<0;1,0>:ud    0x0:uw             
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r10.0<1;1,0>:d    r6.3<0;1,0>:d    {I@2}
(W)     mov (1|M0)               r4.12<1>:hf   0x1:hf                             
(W)     addc (1|M0)              r13.0<1>:ud   r6.4<0;1,0>:ud    0x1:ud              {AccWrEn}
(f1.1)  sel (16|M0)              r5.0<1>:uw    r4.12<0;1,0>:uw   0x0:uw              {Compacted,F@1}
(f1.0)  sel (16|M0)              acc2.0<1>:uw  r4.12<0;1,0>:uw   0x0:uw             
(W)     mov (1|M0)               r3.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        or (16|M0)    (ne)f0.1   null<1>:uw    r5.0<1;1,0>:uw    acc2.0<1;1,0>:uw {I@3}
(W)     add (1|M0)               r7.1<1>:ud    r3.0<0;1,0>:ud    r6.5<0;1,0>:ud   {I@2}
        mov (16|M0)              r110.0<1>:d   r6.4<0;1,0>:d                   
        mov (16|M0)              r108.0<1>:d   r6.5<0;1,0>:d                   
        mov (16|M0)              r88.0<1>:f    r13.0<0;1,0>:f                   {Compacted}
        mov (16|M0)              r14.0<1>:d    r7.1<0;1,0>:d                    {I@3}
(f0.1)  goto (16|M0)                         L8576                  L8576                
L8512:
(W)     mov (1|M0)               r6.7<1>:d     r6.3<0;1,0>:d                   
(W)     mov (1|M0)               r6.4<1>:d     r13.0<0;1,0>:d                  
(W)     mov (1|M0)               r6.5<1>:d     r7.1<0;1,0>:d                   
(W)     jmpi                                 L8192                                
L8576:
        join (16|M0)                         L13544                                
L8592:
(W)     mov (1|M0)               r2.0<1>:f     8.68805e-44:f                              
(W)     mov (1|M0)               r3.0<1>:hf    0.0:hf                             
        subb (8|M0)              r70.0<1>:ud   r2.0<0;1,0>:ud    r110.0<1;1,0>:ud {AccWrEn,Compacted,A@2}
        add3 (8|M0)              r98.0<1>:ud   -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r108.0<1>:ud    {A@1}
        subb (8|M8)              r71.0<1>:ud   r2.0<0;1,0>:ud    r111.0<1;1,0>:ud {AccWrEn}
        add3 (16|M0)             r78.0<1>:d    r68.0<1;0>:d      r70.0<1;0>:d      -173:w               {I@1}
        cmp (16|M0)   (gt)f1.0   null<1>:d     r78.0<1;1,0>:d    127:w               {I@1}
        add3 (8|M8)              r99.0<1>:ud   -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r109.0<1>:ud   
        add3 (16|M0)             r96.0<1>:d    r32.0<1;0>:d      r120.0<1;0>:d     r70.0<1>:d      
(f1.0)  goto (16|M0)                         L13488                  L13488                
L8744:
        cmp (16|M0)   (gt)f0.1   null<1>:d     r78.0<1;1,0>:d    -127:w              
(f0.1)  goto (16|M0)                         L11184                  L11184                
L8776:
        cmp (16|M0)   (lt)f0.0   null<1>:d     r78.0<1;1,0>:ud   0xFFFFFF6B:ud             
(f0.0)  goto (16|M0)                         L10688                  L10688                
L8808:
(W)     mov (1|M0)               r2.0<1>:f     8.82818e-44:f                              
(W)     mov (1|M0)               r3.0<1>:hf    0.0:hf                              {I@7}
        subb (8|M0)              r120.0<1>:ud  r2.0<0;1,0>:ud    r110.0<1;1,0>:ud {AccWrEn,Compacted,F@2}
        add3 (16|M0)             r116.0<1>:d   r68.0<1;0>:d      r70.0<1;0>:d      -23:w              
        add3 (8|M0)              r8.0<1>:ud    -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r108.0<1>:ud    {F@1}
        subb (8|M8)              r121.0<1>:ud  r2.0<0;1,0>:ud    r111.0<1;1,0>:ud {AccWrEn}
        cmp (16|M0)   (gt)f1.1   null<1>:d     r120.0<1;1,0>:ud  r116.0<1;1,0>:ud {I@1}
        add3 (8|M8)              r9.0<1>:ud    -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r109.0<1>:ud   
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r8.0<1;1,0>:d     0:w               {I@1}
(~f1.1) cmp (16|M0)   (gt)f1.1   null<1>:d     r8.0<1;1,0>:ud    0x0:uw             
(f1.1)  goto (16|M0)                         L9032                  L9032                
L8976:
        add3 (16|M0)             r2.0<1>:d     r96.0<1;0>:d      -r120.0<1;0>:d    -23:w              
        mov (16|M0)              r50.0<1>:d    0:w                              
        shl (16|M0)              r52.0<1>:d    r58.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
        goto (16|M0)                         L9032                  L10624                
L9032:
        join (16|M0)                         L10624                                
L9048:
        add3 (16|M0)             r92.0<1>:d    r120.0<1;0>:d     -r96.0<1;0>:d     23:w              
        cmp (16|M0)   (lt)f1.1   null<1>:d     r92.0<1;1,0>:d    2:w               {I@1}
(f1.1)  goto (16|M0)                         L9200                  L9200                
L9096:
        cmp (16|M0)   (eq)f1.0   null<1>:d     r92.0<1;1,0>:d    2:w              
(~f1.0) goto (16|M0)                         L9200                  L9304                
L9128:
        shr (16|M0)              r90.0<1>:ud   r58.0<1;1,0>:ud   1:w              
        mov (16|M0)              r110.0<1>:d   0:w                              
        mov (16|M0)              r18.0<1>:d    0:w                              
        mov (16|M0)              r100.0<1>:f   r90.0<1;1,0>:f                   {Compacted,I@3}
        goto (16|M0)                         L9200                  L10104                
L9200:
        join (16|M0)                         L9304                                
L9216:
        cmp (16|M0)   (eq)f0.1   null<1>:d     r92.0<1;1,0>:d    1:w              
(~f0.1) goto (16|M0)                         L9304                  L9304                
L9248:
        mov (16|M0)              r110.0<1>:d   0:w                              
        mov (16|M0)              r18.0<1>:d    0:w                              
        mov (16|M0)              r100.0<1>:f   r58.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L9304                  L10104                
L9304:
        join (16|M0)                         L10104                                
L9320:
        add3 (16|M0)             r2.0<1>:d     r120.0<1;0>:d     -r116.0<1;0>:d    -1:w              
        and (16|M0)   (ne)f0.0   r32.0<1>:d    r2.0<1;1,0>:d     63:w               {Compacted,I@1}
(f0.0)  goto (16|M0)                         L9384                  L9384                
L9360:
        mov (16|M0)              r112.0<1>:f   r58.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L9384                  L9496                
L9384:
        join (16|M0)                         L9496                                
L9400:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r32.0<1;1,0>:ud   0x20:uw              {I@4}
(~f1.1) add (16|M0)              r2.0<1>:d     r32.0<1;1,0>:d    -32:w              
(~f1.1) shr (16|M0)              r90.0<1>:ud   r62.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.1)  add (16|M0)              r2.0<1>:d     -r32.0<1;1,0>:d   32:w               {Compacted}
(f1.1)  shr (16|M0)              r8.0<1>:ud    r58.0<1;1,0>:ud   r32.0<1;1,0>:d  
(f1.1)  shl (16|M0)              r2.0<1>:d     r62.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.1)  or (16|M0)               r90.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
        mov (16|M0)              r112.0<1>:f   r90.0<1;1,0>:f                   {Compacted,I@1}
L9496:
        join (16|M0)                         L10104                                
L9512:
        add3 (16|M0)             r80.0<1>:d    r120.0<1;0>:d     -r116.0<1;0>:d    -2:w              
        and (16|M0)   (ne)f1.0   r30.0<1>:d    r80.0<1;1,0>:d    63:w               {I@1}
(f1.0)  goto (16|M0)                         L9584                  L9584                
L9560:
        mov (16|M0)              r90.0<1>:f    r58.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L9584                  L9688                
L9584:
        join (16|M0)                         L9688                                
L9600:
        cmp (16|M0)   (lt)f0.1   null<1>:d     r30.0<1;1,0>:ud   0x20:uw              {I@4}
(~f0.1) add (16|M0)              r2.0<1>:d     r30.0<1;1,0>:d    -32:w              
(~f0.1) shr (16|M0)              r90.0<1>:ud   r62.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f0.1)  add (16|M0)              r2.0<1>:d     -r30.0<1;1,0>:d   32:w               {Compacted}
(f0.1)  shr (16|M0)              r8.0<1>:ud    r58.0<1;1,0>:ud   r30.0<1;1,0>:d  
(f0.1)  shl (16|M0)              r2.0<1>:d     r62.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f0.1)  or (16|M0)               r90.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
L9688:
        join (16|M0)                         L10104                                
L9704:
        and (16|M0)   (ne)f0.0   r44.0<1>:d    r80.0<1;1,0>:d    63:w               {Compacted}
        and (16|M0)              r18.0<1>:d    r90.0<1;1,0>:d    1:w               {Compacted,I@3}
(f0.0)  goto (16|M0)                         L9784                  L9784                
L9736:
        mov (16|M0)              r50.0<1>:d    -1:w                              
        mov (16|M0)              r60.0<1>:d    -1:w                              
        goto (16|M0)                         L9784                  L9968                
L9784:
        join (16|M0)                         L9968                                
L9800:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r44.0<1;1,0>:ud   0x20:uw              {I@7}
(f1.1)  goto (16|M0)                         L9904                  L9904                
L9832:
        add (16|M0)              r2.0<1>:d     r44.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r4.12<1>:hf   -qnan(0x1FF):hf                             
        mov (16|M0)              r50.0<1>:d    0:w                              
        shl (16|M0)              r60.0<1>:d    r4.12<0;1,0>:w    r2.0<1;1,0>:d    {A@1}
        goto (16|M0)                         L9904                  L9968                
L9904:
        join (16|M0)                         L9968                                
L9920:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (16|M0)              r60.0<1>:d    -1:w                              
        shl (16|M0)              r50.0<1>:d    r2.0<0;1,0>:w     r44.0<1;1,0>:d   {F@1}
L9968:
        join (16|M0)                         L10104                                
L9984:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r50.0<1;0>:ud     r6.0<0;0>:ud      r58.0<1>:ud      {I@2} // (s0^s1)&s2
        cmp (16|M0)   (ne)f1.0   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
        bfn.0x60 (16|M0)         r8.0<1>:ud    r60.0<1;0>:ud     r6.0<0;0>:ud      r62.0<1>:ud      // (s0^s1)&s2
(~f1.0) cmp (16|M0)   (ne)f1.0   null<1>:d     r8.0<1;1,0>:d     0:w               {I@1}
(W)     mov (1|M0)               r4.12<1>:hf   -qnan(0x1FF):hf                             
        mov (16|M0)              r100.0<1>:f   r112.0<1;1,0>:f                  {Compacted}
(f1.0)  sel (16|M0)              r10.0<1>:d    r4.12<0;1,0>:w    0:w               {F@2}
        mov (16|M0)              r110.0<1>:d   -r10.0<1;1,0>:d                  {I@1}
L10104:
        join (16|M0)                         L10624                                
L10120:
        and (16|M0)   (ne)f1.0   r28.0<1>:d    r92.0<1;1,0>:d    63:w              
(f1.0)  goto (16|M0)                         L10176                  L10176                
L10152:
        mov (16|M0)              r90.0<1>:f    r58.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L10176                  L10280                
L10176:
        join (16|M0)                         L10280                                
L10192:
        cmp (16|M0)   (lt)f0.1   null<1>:d     r28.0<1;1,0>:ud   0x20:uw              {I@4}
(~f0.1) add (16|M0)              r2.0<1>:d     r28.0<1;1,0>:d    -32:w              
(~f0.1) shr (16|M0)              r90.0<1>:ud   r62.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f0.1)  add (16|M0)              r2.0<1>:d     -r28.0<1;1,0>:d   32:w               {Compacted}
(f0.1)  shr (16|M0)              r8.0<1>:ud    r58.0<1;1,0>:ud   r28.0<1;1,0>:d  
(f0.1)  shl (16|M0)              r2.0<1>:d     r62.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f0.1)  or (16|M0)               r90.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
L10280:
        join (16|M0)                         L10624                                
L10296:
        shl (16|M0)              r2.0<1>:d     r100.0<1;1,0>:d   2:w               {Compacted}
        shl (16|M0)              r8.0<1>:d     r18.0<1;1,0>:d    1:w               {Compacted}
        and (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     4:w               {Compacted,I@2}
        bfn.0xFE (16|M0)         r86.0<1>:ud   r2.0<1;0>:ud      r8.0<1;0>:ud      r110.0<1>:ud     {I@1} // s0|s1|s2
        cmp (16|M0)   (eq)f0.0   null<1>:d     r86.0<1;1,0>:d    0:w               {Compacted,I@1}
(~f0.0) goto (16|M0)                         L10392                  L10392                
L10360:
        mov (16|M0)              r96.0<1>:d    0:w                              
        goto (16|M0)                         L10392                  L10552                
L10392:
        join (16|M0)                         L10552                                
L10408:
        cmp (16|M0)   (gt)f1.1   null<1>:d     r86.0<1;1,0>:ud   0x4:uw             
(~f1.1) goto (16|M0)                         L10472                  L10472                
L10440:
        mov (16|M0)              r96.0<1>:d    1:w                              
        goto (16|M0)                         L10472                  L10552                
L10472:
        join (16|M0)                         L10552                                
L10488:
        and (16|M0)   (ne)f0.1   null<1>:d     r90.0<1;1,0>:d    1:w              
(W)     mov (1|M0)               r2.0<1>:hf    0x1:hf                             
(f0.1)  cmp (16|M0)   (eq)f0.1   null<1>:d     r86.0<1;1,0>:d    4:w              
(f0.1)  sel (16|M0)              r96.0<1>:d    r2.0<0;1,0>:w     0:w               {F@1}
L10552:
        join (16|M0)                         L10624                                
L10568:
        add (16|M0)              r2.0<1>:d     r96.0<1;1,0>:d    r90.0<1;1,0>:d   {Compacted,I@2}
        cmp (16|M0)   (gt)f1.0   null<1>:d     r2.0<1;1,0>:ud    0x7FFFFF:ud              {I@1}
(W)     mov (1|M0)               r4.6<1>:f     0x800000:f                               {Compacted}
(~f1.0) sel (16|M0)              r52.0<1>:d    r2.0<1;1,0>:d     0:w              
(f1.0)  sel (16|M0)              r50.0<1>:d    r4.6<0;1,0>:d     0:w               {Compacted,F@1}
L10624:
        join (16|M0)                         L10688                                
L10640:
        and (16|M0)              r2.0<1>:d     r54.0<1;1,0>:d    -2147483648:d              
        bfn.0xFE (16|M0)         r96.0<1>:ud   r2.0<1;0>:ud      r50.0<1;0>:ud     r52.0<1>:ud      {I@1} // s0|s1|s2
        goto (16|M0)                         L10688                  L13704                
L10688:
        join (16|M0)                         L11184                                
L10704:
        and (16|M0)   (ne)f1.0   r114.0<1>:d   r70.0<1;1,0>:d    63:w              
(f1.0)  goto (16|M0)                         L10784                  L10784                
L10736:
        mov (16|M0)              r10.0<1>:d    -1:w                              
        mov (16|M0)              r42.0<1>:d    -1:w                              
        goto (16|M0)                         L10784                  L10968                
L10784:
        join (16|M0)                         L10968                                
L10800:
        cmp (16|M0)   (lt)f0.1   null<1>:d     r114.0<1;1,0>:ud  0x20:uw              {I@6}
(f0.1)  goto (16|M0)                         L10904                  L10904                
L10832:
        add (16|M0)              r2.0<1>:d     r114.0<1;1,0>:d   -32:w               {Compacted}
(W)     mov (1|M0)               r4.12<1>:hf   -qnan(0x1FF):hf                             
        mov (16|M0)              r10.0<1>:d    0:w                              
        shl (16|M0)              r42.0<1>:d    r4.12<0;1,0>:w    r2.0<1;1,0>:d    {A@1}
        goto (16|M0)                         L10904                  L10968                
L10904:
        join (16|M0)                         L10968                                
L10920:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (16|M0)              r42.0<1>:d    -1:w                              
        shl (16|M0)              r10.0<1>:d    r2.0<0;1,0>:w     r114.0<1;1,0>:d  {F@1}
L10968:
        join (16|M0)                         L11184                                
L10984:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r10.0<1;0>:ud     r6.0<0;0>:ud      r58.0<1>:ud      {I@2} // (s0^s1)&s2
        cmp (16|M0)   (ne)f0.1   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
        bfn.0x60 (16|M0)         r8.0<1>:ud    r42.0<1;0>:ud     r6.0<0;0>:ud      r62.0<1>:ud      // (s0^s1)&s2
        cmp (16|M0)   (gt)f0.0   null<1>:d     r54.0<1;1,0>:d    -1:w               {Compacted}
(~f0.1) cmp (16|M0)   (ne)f0.1   null<1>:d     r8.0<1;1,0>:d     0:w               {I@2}
(f0.1)  cmp (16|M0)   (eq)f0.1   null<1>:d     r78.0<1;1,0>:d    -150:w              
(f0.0)  goto (16|M0)                         L11128                  L11128                
L11088:
(W)     mov (1|M0)               r2.0<1>:ud    0x80000001:ud                             
(f0.1)  sel (16|M0)              r96.0<1>:f    r2.0<0;1,0>:f     -0.0:f               {Compacted,I@1}
        goto (16|M0)                         L11128                  L13704                
L11128:
        join (16|M0)                         L11184                                
L11144:
(W)     mov (1|M0)               r2.0<1>:ud    0x1:ud                              {F@1}
(f0.1)  sel (16|M0)              r96.0<1>:f    r2.0<0;1,0>:f     0.0:f               {Compacted,I@1}
        goto (16|M0)                         L11184                  L13704                
L11184:
        join (16|M0)                         L13488                                
L11200:
        cmp (16|M0)   (lt)f0.0   null<1>:d     r70.0<1;1,0>:ud   0x18:uw             
        add3 (16|M0)             r84.0<1>:d    r68.0<1;0>:d      r70.0<1;0>:d      -46:w              
(f0.0)  cmp (16|M0)   (eq)f0.0   null<1>:d     r98.0<1;1,0>:d    0:w              
(f0.0)  goto (16|M0)                         L13184                  L13184                
L11264:
        shl (16|M0)              r2.0<1>:d     r88.0<1;1,0>:d    1:w               {Compacted,F@1}
        shr (16|M0)              r8.0<1>:ud    r88.0<1;1,0>:ud   31:w              
        shl (16|M0)              r10.0<1>:d    r14.0<1;1,0>:d    1:w               {Compacted}
        cmp (16|M0)   (lt)f1.0   null<1>:d     r2.0<1;1,0>:ud    0x4E:uw              {I@3}
        or (16|M0)               r10.0<1>:d    r10.0<1;1,0>:d    r8.0<1;1,0>:d    {Compacted,I@2}
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r10.0<1;1,0>:d    0:w               {I@1}
(~f1.0) cmp (16|M0)   (lt)f1.0   null<1>:d     r10.0<1;1,0>:d    0:w              
(f1.0)  goto (16|M0)                         L11496                  L11496                
L11368:
        cmp (16|M0)   (eq)f1.1   null<1>:d     r88.0<1;1,0>:d    39:w              
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r14.0<1;1,0>:d    0:w              
(~f1.1) goto (16|M0)                         L11496                  L11560                
L11416:
        shr (16|M0)              r90.0<1>:ud   r58.0<1;1,0>:ud   1:w              
        mov (16|M0)              r14.0<1>:d    0:w                              
        mov (16|M0)              r28.0<1>:d    0:w                              
        mov (16|M0)              r72.0<1>:f    r90.0<1;1,0>:f                   {Compacted,I@3}
        mov (16|M0)              r90.0<1>:f    r58.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L11496                  L12664                
L11496:
        join (16|M0)                         L11560                                
L11512:
        cmp (16|M0)   (eq)f1.0   null<1>:d     r88.0<1;1,0>:d    38:w              
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r14.0<1;1,0>:d    0:w               {I@5}
(f1.0)  goto (16|M0)                         L11560                  L12576                
L11560:
        join (16|M0)                         L12576                                
L11576:
        add (16|M0)              r2.0<1>:d     -r88.0<1;1,0>:d   39:w               {Compacted}
        and (16|M0)   (ne)f1.1   r48.0<1>:d    r2.0<1;1,0>:d     63:w               {I@1}
        add (16|M0)              r50.0<1>:d    -r88.0<1;1,0>:d   40:w               {Compacted}
(f1.1)  goto (16|M0)                         L11648                  L11648                
L11624:
        mov (16|M0)              r122.0<1>:f   r58.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L11648                  L11760                
L11648:
        join (16|M0)                         L11760                                
L11664:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r48.0<1;1,0>:ud   0x20:uw              {I@5}
(~f1.0) add (16|M0)              r2.0<1>:d     r48.0<1;1,0>:d    -32:w              
(~f1.0) shr (16|M0)              r90.0<1>:ud   r62.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.0)  add (16|M0)              r2.0<1>:d     -r48.0<1;1,0>:d   32:w               {Compacted}
(f1.0)  shr (16|M0)              r8.0<1>:ud    r58.0<1;1,0>:ud   r48.0<1;1,0>:d  
(f1.0)  shl (16|M0)              r2.0<1>:d     r62.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.0)  or (16|M0)               r90.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
        mov (16|M0)              r122.0<1>:f   r90.0<1;1,0>:f                   {Compacted,I@1}
L11760:
        join (16|M0)                         L12576                                
L11776:
        add (16|M0)              r88.0<1>:d    -r88.0<1;1,0>:d   38:w               {Compacted}
        and (16|M0)   (ne)f0.1   r52.0<1>:d    r88.0<1;1,0>:d    63:w               {I@1}
(f0.1)  goto (16|M0)                         L11840                  L11840                
L11816:
        mov (16|M0)              r90.0<1>:f    r58.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L11840                  L11944                
L11840:
        join (16|M0)                         L11944                                
L11856:
        cmp (16|M0)   (lt)f0.0   null<1>:d     r52.0<1;1,0>:ud   0x20:uw              {I@4}
(~f0.0) add (16|M0)              r2.0<1>:d     r52.0<1;1,0>:d    -32:w              
(~f0.0) shr (16|M0)              r90.0<1>:ud   r62.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f0.0)  add (16|M0)              r2.0<1>:d     -r52.0<1;1,0>:d   32:w               {Compacted}
(f0.0)  shr (16|M0)              r8.0<1>:ud    r58.0<1;1,0>:ud   r52.0<1;1,0>:d  
(f0.0)  shl (16|M0)              r2.0<1>:d     r62.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f0.0)  or (16|M0)               r90.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
L11944:
        join (16|M0)                         L12576                                
L11960:
        and (16|M0)   (ne)f1.1   r72.0<1>:d    r88.0<1;1,0>:d    63:w              
        and (16|M0)              r28.0<1>:d    r90.0<1;1,0>:d    1:w               {Compacted,I@3}
(f1.1)  goto (16|M0)                         L12048                  L12048                
L12000:
        mov (16|M0)              r90.0<1>:d    -1:w                              
        mov (16|M0)              r98.0<1>:d    -1:w                              
        goto (16|M0)                         L12048                  L12232                
L12048:
        join (16|M0)                         L12232                                
L12064:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r72.0<1;1,0>:ud   0x20:uw              {I@7}
(f1.0)  goto (16|M0)                         L12168                  L12168                
L12096:
        add (16|M0)              r2.0<1>:d     r72.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r4.12<1>:hf   -qnan(0x1FF):hf                             
        mov (16|M0)              r90.0<1>:d    0:w                              
        shl (16|M0)              r98.0<1>:d    r4.12<0;1,0>:w    r2.0<1;1,0>:d    {A@1}
        goto (16|M0)                         L12168                  L12232                
L12168:
        join (16|M0)                         L12232                                
L12184:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (16|M0)              r98.0<1>:d    -1:w                              
        shl (16|M0)              r90.0<1>:d    r2.0<0;1,0>:w     r72.0<1;1,0>:d   {F@1}
L12232:
        join (16|M0)                         L12576                                
L12248:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r90.0<1;0>:ud     r6.0<0;0>:ud      r58.0<1>:ud      {I@2} // (s0^s1)&s2
        cmp (16|M0)   (ne)f0.1   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
        bfn.0x60 (16|M0)         r8.0<1>:ud    r98.0<1;0>:ud     r6.0<0;0>:ud      r62.0<1>:ud      // (s0^s1)&s2
(~f0.1) cmp (16|M0)   (ne)f0.1   null<1>:d     r8.0<1;1,0>:d     0:w               {I@1}
(W)     mov (1|M0)               r4.12<1>:hf   -qnan(0x1FF):hf                             
(f0.1)  sel (16|M0)              r10.0<1>:d    r4.12<0;1,0>:w    0:w               {F@1}
        and (16|M0)   (ne)f0.1   r50.0<1>:d    r50.0<1;1,0>:d    63:w              
        mov (16|M0)              r14.0<1>:d    -r10.0<1;1,0>:d                  {I@2}
(f0.1)  goto (16|M0)                         L12416                  L12416                
L12392:
        mov (16|M0)              r90.0<1>:f    r58.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L12416                  L12520                
L12416:
        join (16|M0)                         L12520                                
L12432:
        cmp (16|M0)   (lt)f0.0   null<1>:d     r50.0<1;1,0>:ud   0x20:uw              {I@5}
(~f0.0) add (16|M0)              r2.0<1>:d     r50.0<1;1,0>:d    -32:w              
(~f0.0) shr (16|M0)              r90.0<1>:ud   r62.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f0.0)  add (16|M0)              r2.0<1>:d     -r50.0<1;1,0>:d   32:w               {Compacted}
(f0.0)  shr (16|M0)              r8.0<1>:ud    r58.0<1;1,0>:ud   r50.0<1;1,0>:d  
(f0.0)  shl (16|M0)              r2.0<1>:d     r62.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f0.0)  or (16|M0)               r90.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
L12520:
        join (16|M0)                         L12576                                
L12536:
        mov (16|M0)              r72.0<1>:f    r90.0<1;1,0>:f                   {Compacted,I@2}
        mov (16|M0)              r90.0<1>:d    r122.0<1;1,0>:d                  {F@1}
        goto (16|M0)                         L12576                  L12664                
L12576:
        join (16|M0)                         L12664                                
L12592:
        shr (16|M0)              r90.0<1>:ud   r58.0<1;1,0>:ud   2:w              
        mov (16|M0)              r14.0<1>:d    0:w                              
        mov (16|M0)              r28.0<1>:d    0:w                              
        mov (16|M0)              r72.0<1>:f    r90.0<1;1,0>:f                   {Compacted,I@3}
        shr (16|M0)              r90.0<1>:ud   r58.0<1;1,0>:ud   1:w               {F@1}
L12664:
        join (16|M0)                         L13184                                
L12680:
        shl (16|M0)              r2.0<1>:d     r90.0<1;1,0>:d    2:w               {Compacted,I@2}
        shl (16|M0)              r8.0<1>:d     r28.0<1;1,0>:d    1:w               {Compacted}
        and (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     4:w               {Compacted,I@2}
        bfn.0xFE (16|M0)         r8.0<1>:ud    r2.0<1;0>:ud      r8.0<1;0>:ud      r14.0<1>:ud      {I@1} // s0|s1|s2
        cmp (16|M0)   (eq)f1.1   null<1>:d     r8.0<1;1,0>:d     0:w               {I@1}
        and (16|M0)              r42.0<1>:d    r72.0<1;1,0>:d    8388607:d              
(~f1.1) goto (16|M0)                         L12800                  L12800                
L12768:
        mov (16|M0)              r112.0<1>:d   0:w                              
        goto (16|M0)                         L12800                  L12952                
L12800:
        join (16|M0)                         L12952                                
L12816:
        cmp (16|M0)   (gt)f1.0   null<1>:d     r8.0<1;1,0>:ud    0x4:uw             
(~f1.0) goto (16|M0)                         L12880                  L12880                
L12848:
        mov (16|M0)              r112.0<1>:d   1:w                              
        goto (16|M0)                         L12880                  L12952                
L12880:
        join (16|M0)                         L12952                                
L12896:
        and (16|M0)   (ne)f0.0   null<1>:d     r72.0<1;1,0>:d    1:w               {Compacted}
(W)     mov (1|M0)               r2.0<1>:hf    0x1:hf                             
(f0.0)  cmp (16|M0)   (eq)f0.0   null<1>:d     r8.0<1;1,0>:d     4:w              
(f0.0)  sel (16|M0)              r112.0<1>:d   r2.0<0;1,0>:w     0:w               {F@1}
L12952:
        join (16|M0)                         L13184                                
L12968:
        add (16|M0)              r62.0<1>:d    r42.0<1;1,0>:d    r112.0<1;1,0>:d  {Compacted,I@2}
        cmp (16|M0)   (gt)f1.0   null<1>:d     r62.0<1;1,0>:ud   0x7FFFFF:ud              {I@1}
        add3 (16|M0)             r2.0<1>:d     r68.0<1;0>:d      r70.0<1;0>:d      -45:w              
(f1.0)  sel (16|M0)              r60.0<1>:d    r2.0<1;1,0>:d     r84.0<1;1,0>:d   {Compacted,I@1}
        cmp (16|M0)   (eq)f0.1   null<1>:d     r60.0<1;1,0>:d    255:w               {I@1}
(f0.1)  goto (16|M0)                         L13120                  L13120                
L13048:
(~f1.0) sel (16|M0)              r2.0<1>:d     r62.0<1;1,0>:d    0:w              
        and (16|M0)              r8.0<1>:d     r54.0<1;1,0>:d    -2147483648:d              
        shl (16|M0)              r10.0<1>:d    r60.0<1;1,0>:d    23:w               {Compacted}
        bfn.0xFE (16|M0)         r96.0<1>:ud   r8.0<1;0>:ud      r10.0<1;0>:ud     r2.0<1>:ud       {I@1} // s0|s1|s2
        goto (16|M0)                         L13120                  L13704                
L13120:
        join (16|M0)                         L13184                                
L13136:
        cmp (16|M0)   (gt)f0.1   null<1>:d     r54.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r2.0<1>:f     inf:f                               {Compacted,I@4}
(f0.1)  sel (16|M0)              r96.0<1>:f    r2.0<0;1,0>:f     -inf:f               {Compacted,F@1}
        goto (16|M0)                         L13184                  L13704                
L13184:
        join (16|M0)                         L13488                                
L13200:
        and (16|M0)   (ne)f0.0   r48.0<1>:d    r70.0<1;1,0>:d    63:w               {Compacted}
(f0.0)  goto (16|M0)                         L13256                  L13256                
L13224:
        mov (16|M0)              r104.0<1>:d   -1:w                              
        goto (16|M0)                         L13256                  L13384                
L13256:
        join (16|M0)                         L13384                                
L13272:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r48.0<1;1,0>:ud   0x20:uw              {I@5}
(f1.1)  goto (16|M0)                         L13336                  L13336                
L13304:
        mov (16|M0)              r104.0<1>:d   0:w                              
        goto (16|M0)                         L13336                  L13384                
L13336:
        join (16|M0)                         L13384                                
L13352:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                             
        shl (16|M0)              r104.0<1>:d   r2.0<0;1,0>:w     r48.0<1;1,0>:d   {F@1}
L13384:
        join (16|M0)                         L13488                                
L13400:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r104.0<1;0>:ud    r6.0<0;0>:ud      r58.0<1>:ud      {I@2} // (s0^s1)&s2
        add (16|M0)              r8.0<1>:d     -r70.0<1;1,0>:d   23:w               {Compacted}
        and (16|M0)              r10.0<1>:d    r54.0<1;1,0>:d    -2147483648:d              
        shl (16|M0)              r12.0<1>:d    r84.0<1;1,0>:d    23:w               {Compacted}
        shl (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     r8.0<1;1,0>:d    {Compacted,I@3}
        bfn.0xFE (16|M0)         r96.0<1>:ud   r10.0<1;0>:ud     r12.0<1;0>:ud     r2.0<1>:ud       {I@1} // s0|s1|s2
        goto (16|M0)                         L13488                  L13704                
L13488:
        join (16|M0)                         L13544                                
L13504:
        cmp (16|M0)   (gt)f0.0   null<1>:d     r54.0<1;1,0>:d    -1:w               {Compacted}
(W)     mov (1|M0)               r2.0<1>:f     inf:f                               {Compacted,I@4}
(f0.0)  sel (16|M0)              r96.0<1>:f    r2.0<0;1,0>:f     -inf:f               {Compacted,F@1}
        goto (16|M0)                         L13544                  L13704                
L13544:
        join (16|M0)                         L13608                                
L13560:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r54.0<1;1,0>:d    0:w              
(W)     mov (1|M0)               r2.0<1>:f     -0.0:f                               {Compacted,$9.src}
(f1.1)  sel (16|M0)              r96.0<1>:f    r2.0<0;1,0>:f     0.0:f               {Compacted,F@1}
        goto (16|M0)                         L13608                  L13704                
L13608:
        join (16|M0)                         L13672                                
L13624:
        cmp (16|M0)   (gt)f1.0   null<1>:d     r54.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r2.0<1>:f     inf:f                               {Compacted,$9.src}
(f1.0)  sel (16|M0)              r96.0<1>:f    r2.0<0;1,0>:f     -inf:f               {Compacted,F@1}
        goto (16|M0)                         L13672                  L13704                
L13672:
        join (16|M0)                         L13704                                
L13688:
        bfn.0xF8 (16|M0)         r96.0<1>:ud   r54.0<1;0>:ud     r6.2<0;0>:ud      r6.1<0>:ud       {F@1} // s0&s1|s2
L13704:
        join (16|M0)                         L13720                                
L13720:
        rnde (16|M0)             r4.0<1>:f     r96.0<1;1,0>:f                   {Compacted,I@2}
        shr (16|M0)              r76.0<1>:ud   r4.0<1;1,0>:ud    23:w               {F@1}
        and (16|M0)   (ne)f1.1   r88.0<1>:d    r4.0<1;1,0>:d     8388607:d              
        and (16|M0)              r124.0<1>:d   r76.0<1;1,0>:d    255:w               {Compacted,I@2}
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r124.0<1;1,0>:d   255:w               {I@1}
(~f1.1) goto (16|M0)                         L13832                  L13832                
L13800:
        mov (16|M0)              r94.0<1>:ud   0x7FC00000:ud                             
        goto (16|M0)                         L13832                  L19776                
L13832:
        join (16|M0)                         L19776                                
L13848:
        cmp (16|M0)   (eq)f0.1   null<1>:d     r88.0<1;1,0>:d    0:w              
        add (16|M0)              r2.0<1>:d     r46.0<1;1,0>:d    -25165824:d               {$9.src}
        shr (16|M0)              r70.0<1>:ud   r2.0<1;1,0>:ud    23:w               {I@1}
(f0.1)  cmp (16|M0)   (eq)f0.1   null<1>:d     r124.0<1;1,0>:d   255:w              
        and (16|M0)              r122.0<1>:d   r70.0<1;1,0>:d    255:w               {Compacted,I@2}
(~f0.1) cmp (16|M0)   (eq)f0.1   null<1>:d     r122.0<1;1,0>:d   255:w               {I@1}
        xor (16|M0)              r52.0<1>:d    r2.0<1;1,0>:d     r4.0<1;1,0>:d    {Compacted}
(f0.1)  goto (16|M0)                         L19744                  L19744                
L13960:
        cmp (16|M0)   (eq)f1.0   null<1>:d     r122.0<1;1,0>:d   0:w              
        or (16|M0)               r2.0<1>:d     r124.0<1;1,0>:d   r88.0<1;1,0>:d   {Compacted}
(~f1.0) cmp (16|M0)   (eq)f1.0   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
(~f1.0) goto (16|M0)                         L14048                  L14048                
L14016:
        mov (16|M0)              r94.0<1>:ud   0x0:ud                             
        goto (16|M0)                         L14048                  L19776                
L14048:
        join (16|M0)                         L19744                                
L14064:
        cmp (16|M0)   (eq)f0.0   null<1>:d     r124.0<1;1,0>:d   0:w               {Compacted}
        add (16|M0)              r118.0<1>:d   r124.0<1;1,0>:d   -127:w               {Compacted}
(f0.0)  mov (16|M0)              r118.0<1>:d   -126:w                              
        add (16|M0)              r64.0<1>:d    r122.0<1;1,0>:d   r118.0<1;1,0>:d  {Compacted,I@1}
        cmp (16|M0)   (gt)f1.0   null<1>:d     r64.0<1;1,0>:d    254:w               {I@1}
(f1.0)  goto (16|M0)                         L19680                  L19680                
L14136:
        or (16|M0)    (eq)f0.1   null<4>:b     r76.0<1;1,0>:d    r70.0<1;1,0>:d  
(f0.1)  goto (16|M0)                         L19616                  L19616                
L14168:
(W)     mov (1|M0)               r2.0<1>:hf    0.0:hf                             
(W)     mov (1|M0)               r7.0<1>:d     0:w                              
(f0.0)  sel (16|M0)              r8.0<1>:d     r2.0<0;1,0>:w     8388608:d               {F@1}
        or (16|M0)               r8.0<1>:d     r8.0<1;1,0>:d     r88.0<1;1,0>:d   {Compacted,I@1}
        shl (16|M0)              r56.0<1>:d    r8.0<1;1,0>:d     23:w               {Compacted,I@1}
        shr (16|M0)              r60.0<1>:ud   r8.0<1;1,0>:ud    9:w              
(W)     mov (1|M0)               r6.7<1>:f     -0.0:f                               {Compacted}
(W)     mov (2|M0)               r6.4<1>:d     0:w                              
L14272:
(W)     shl (1|M0)               r2.0<1>:d     r6.7<0;1,0>:d     31:w               {Compacted,F@1}
(W)     shr (1|M0)               r2.1<1>:ud    r7.0<0;1,0>:ud    1:w              
(W)     cmp (16|M0)   (gt)f1.0   null<1>:d     r6.4<0;1,0>:ud    0x3E:uw              {I@3}
(W)     or (1|M0)                r7.0<1>:d     r2.1<0;1,0>:d     r2.0<0;1,0>:d    {Compacted,I@2}
        bfn.0xE0 (16|M0)         r8.0<1>:ud    r2.1<0;0>:ud      r2.0<0;0>:ud      r56.0<1>:ud      // (s0|s1)&s2
(W)     shr (1|M0)               r6.3<1>:ud    r6.7<0;1,0>:ud    1:w              
(W&f1.0) cmp (16|M0)  (eq)f1.0   null<1>:d     r6.5<0;1,0>:d     0:w              
        cmp (16|M0)   (eq)f0.1   null<1>:d     r8.0<1;1,0>:d     r7.0<0;1,0>:d    {I@3}
        and (16|M0)              r10.0<1>:d    r6.3<0;1,0>:d     r60.0<1;1,0>:d   {Compacted,I@3}
(W&~f1.0) cmp (16|M0) (gt)f1.0   null<1>:d     r6.5<0;1,0>:ud    0x0:uw             
(f0.1)  cmp (16|M0)   (eq)f0.1   null<1>:d     r10.0<1;1,0>:d    r6.3<0;1,0>:d    {I@2}
(W)     mov (1|M0)               r4.12<1>:hf   0x1:hf                             
(W)     addc (1|M0)              r13.0<1>:ud   r6.4<0;1,0>:ud    0x1:ud              {AccWrEn}
(f1.0)  sel (16|M0)              r5.0<1>:uw    r4.12<0;1,0>:uw   0x0:uw              {Compacted,F@1}
(f0.1)  sel (16|M0)              acc2.0<1>:uw  r4.12<0;1,0>:uw   0x0:uw             
(W)     mov (1|M0)               r3.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        or (16|M0)    (ne)f0.0   null<1>:uw    r5.0<1;1,0>:uw    acc2.0<1;1,0>:uw {I@3}
(W)     add (1|M0)               r7.1<1>:ud    r3.0<0;1,0>:ud    r6.5<0;1,0>:ud   {I@2}
        mov (16|M0)              r106.0<1>:d   r6.4<0;1,0>:d                   
        mov (16|M0)              r104.0<1>:d   r6.5<0;1,0>:d                   
        mov (16|M0)              r100.0<1>:f   r13.0<0;1,0>:f                   {Compacted}
        mov (16|M0)              r126.0<1>:d   r7.1<0;1,0>:d                    {I@3}
(f0.0)  goto (16|M0)                         L14656                  L14656                
L14592:
(W)     mov (1|M0)               r6.7<1>:d     r6.3<0;1,0>:d                   
(W)     mov (1|M0)               r6.4<1>:d     r13.0<0;1,0>:d                  
(W)     mov (1|M0)               r6.5<1>:d     r7.1<0;1,0>:d                   
(W)     jmpi                                 L14272                                
L14656:
        join (16|M0)                         L19616                                
L14672:
(W)     mov (1|M0)               r2.0<1>:f     8.68805e-44:f                              
(W)     mov (1|M0)               r3.0<1>:hf    0.0:hf                             
        subb (8|M0)              r72.0<1>:ud   r2.0<0;1,0>:ud    r106.0<1;1,0>:ud {AccWrEn,Compacted,A@2}
        add3 (8|M0)              r94.0<1>:ud   -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r104.0<1>:ud    {A@1}
        subb (8|M8)              r73.0<1>:ud   r2.0<0;1,0>:ud    r107.0<1;1,0>:ud {AccWrEn}
        add3 (16|M0)             r74.0<1>:d    r64.0<1;0>:d      r72.0<1;0>:d      -173:w               {I@1}
        cmp (16|M0)   (gt)f0.0   null<1>:d     r74.0<1;1,0>:d    127:w               {Compacted,I@1}
        add3 (8|M8)              r95.0<1>:ud   -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r105.0<1>:ud   
        add3 (16|M0)             r92.0<1>:d    r122.0<1;0>:d     r118.0<1;0>:d     r72.0<1>:d      
(f0.0)  goto (16|M0)                         L19560                  L19560                
L14816:
        cmp (16|M0)   (gt)f1.1   null<1>:d     r74.0<1;1,0>:d    -127:w              
(f1.1)  goto (16|M0)                         L17248                  L17248                
L14848:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r74.0<1;1,0>:ud   0xFFFFFF6B:ud             
(f1.0)  goto (16|M0)                         L16752                  L16752                
L14880:
(W)     mov (1|M0)               r2.0<1>:f     8.82818e-44:f                              
(W)     mov (1|M0)               r3.0<1>:hf    0.0:hf                              {I@7}
        subb (8|M0)              r114.0<1>:ud  r2.0<0;1,0>:ud    r106.0<1;1,0>:ud {AccWrEn,Compacted,F@2}
        add3 (16|M0)             r108.0<1>:d   r64.0<1;0>:d      r72.0<1;0>:d      -23:w              
        add3 (8|M0)              r8.0<1>:ud    -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r104.0<1>:ud    {F@1}
        subb (8|M8)              r115.0<1>:ud  r2.0<0;1,0>:ud    r107.0<1;1,0>:ud {AccWrEn}
        cmp (16|M0)   (gt)f0.0   null<1>:d     r114.0<1;1,0>:ud  r108.0<1;1,0>:ud {I@1}
        add3 (8|M8)              r9.0<1>:ud    -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r105.0<1>:ud   
(f0.0)  cmp (16|M0)   (eq)f0.0   null<1>:d     r8.0<1;1,0>:d     0:w               {I@1}
(~f0.0) cmp (16|M0)   (gt)f0.0   null<1>:d     r8.0<1;1,0>:ud    0x0:uw             
(f0.0)  goto (16|M0)                         L15104                  L15104                
L15048:
        add3 (16|M0)             r2.0<1>:d     r92.0<1;0>:d      -r114.0<1;0>:d    -23:w              
        mov (16|M0)              r42.0<1>:d    0:w                              
        shl (16|M0)              r44.0<1>:d    r56.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
        goto (16|M0)                         L15104                  L16688                
L15104:
        join (16|M0)                         L16688                                
L15120:
        add3 (16|M0)             r98.0<1>:d    r114.0<1;0>:d     -r92.0<1;0>:d     23:w              
        cmp (16|M0)   (lt)f0.1   null<1>:d     r98.0<1;1,0>:d    2:w               {I@1}
(f0.1)  goto (16|M0)                         L15264                  L15264                
L15168:
        cmp (16|M0)   (eq)f0.0   null<1>:d     r98.0<1;1,0>:d    2:w               {Compacted}
(~f0.0) goto (16|M0)                         L15264                  L15368                
L15192:
        shr (16|M0)              r82.0<1>:ud   r56.0<1;1,0>:ud   1:w              
        mov (16|M0)              r114.0<1>:d   0:w                              
        mov (16|M0)              r96.0<1>:d    0:w                              
        mov (16|M0)              r86.0<1>:f    r82.0<1;1,0>:f                   {Compacted,I@3}
        goto (16|M0)                         L15264                  L16184                
L15264:
        join (16|M0)                         L15368                                
L15280:
        cmp (16|M0)   (eq)f1.1   null<1>:d     r98.0<1;1,0>:d    1:w              
(~f1.1) goto (16|M0)                         L15368                  L15368                
L15312:
        mov (16|M0)              r114.0<1>:d   0:w                              
        mov (16|M0)              r96.0<1>:d    0:w                              
        mov (16|M0)              r86.0<1>:f    r56.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L15368                  L16184                
L15368:
        join (16|M0)                         L16184                                
L15384:
        add3 (16|M0)             r2.0<1>:d     r114.0<1;0>:d     -r108.0<1;0>:d    -1:w               {I@4}
        and (16|M0)   (ne)f1.0   r26.0<1>:d    r2.0<1;1,0>:d     63:w               {I@1}
(f1.0)  goto (16|M0)                         L15456                  L15456                
L15432:
        mov (16|M0)              r116.0<1>:f   r56.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L15456                  L15568                
L15456:
        join (16|M0)                         L15568                                
L15472:
        cmp (16|M0)   (lt)f0.1   null<1>:d     r26.0<1;1,0>:ud   0x20:uw              {I@4}
(~f0.1) add (16|M0)              r2.0<1>:d     r26.0<1;1,0>:d    -32:w              
(~f0.1) shr (16|M0)              r82.0<1>:ud   r60.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f0.1)  add (16|M0)              r2.0<1>:d     -r26.0<1;1,0>:d   32:w               {Compacted}
(f0.1)  shr (16|M0)              r8.0<1>:ud    r56.0<1;1,0>:ud   r26.0<1;1,0>:d  
(f0.1)  shl (16|M0)              r2.0<1>:d     r60.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f0.1)  or (16|M0)               r82.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
        mov (16|M0)              r116.0<1>:f   r82.0<1;1,0>:f                   {Compacted,I@1}
L15568:
        join (16|M0)                         L16184                                
L15584:
        add3 (16|M0)             r74.0<1>:d    r114.0<1;0>:d     -r108.0<1;0>:d    -2:w              
        and (16|M0)   (ne)f0.0   r24.0<1>:d    r74.0<1;1,0>:d    63:w               {Compacted,I@1}
(f0.0)  goto (16|M0)                         L15648                  L15648                
L15624:
        mov (16|M0)              r82.0<1>:f    r56.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L15648                  L15752                
L15648:
        join (16|M0)                         L15752                                
L15664:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r24.0<1;1,0>:ud   0x20:uw              {I@4}
(~f1.1) add (16|M0)              r2.0<1>:d     r24.0<1;1,0>:d    -32:w              
(~f1.1) shr (16|M0)              r82.0<1>:ud   r60.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.1)  add (16|M0)              r2.0<1>:d     -r24.0<1;1,0>:d   32:w               {Compacted}
(f1.1)  shr (16|M0)              r8.0<1>:ud    r56.0<1;1,0>:ud   r24.0<1;1,0>:d  
(f1.1)  shl (16|M0)              r2.0<1>:d     r60.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.1)  or (16|M0)               r82.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
L15752:
        join (16|M0)                         L16184                                
L15768:
        and (16|M0)   (ne)f1.0   r126.0<1>:d   r74.0<1;1,0>:d    63:w              
(f1.0)  goto (16|M0)                         L15848                  L15848                
L15800:
        mov (16|M0)              r40.0<1>:d    -1:w                              
        mov (16|M0)              r48.0<1>:d    -1:w                              
        goto (16|M0)                         L15848                  L16032                
L15848:
        join (16|M0)                         L16032                                
L15864:
        cmp (16|M0)   (lt)f0.1   null<1>:d     r126.0<1;1,0>:ud  0x20:uw              {I@6}
(f0.1)  goto (16|M0)                         L15968                  L15968                
L15896:
        add (16|M0)              r2.0<1>:d     r126.0<1;1,0>:d   -32:w               {Compacted}
(W)     mov (1|M0)               r4.12<1>:hf   -qnan(0x1FF):hf                             
        mov (16|M0)              r40.0<1>:d    0:w                              
        shl (16|M0)              r48.0<1>:d    r4.12<0;1,0>:w    r2.0<1;1,0>:d    {A@1}
        goto (16|M0)                         L15968                  L16032                
L15968:
        join (16|M0)                         L16032                                
L15984:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (16|M0)              r48.0<1>:d    -1:w                              
        shl (16|M0)              r40.0<1>:d    r2.0<0;1,0>:w     r126.0<1;1,0>:d  {F@1}
L16032:
        join (16|M0)                         L16184                                
L16048:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r40.0<1;0>:ud     r6.0<0;0>:ud      r56.0<1>:ud      {I@2} // (s0^s1)&s2
        cmp (16|M0)   (ne)f0.1   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
        bfn.0x60 (16|M0)         r8.0<1>:ud    r48.0<1;0>:ud     r6.0<0;0>:ud      r60.0<1>:ud      // (s0^s1)&s2
(~f0.1) cmp (16|M0)   (ne)f0.1   null<1>:d     r8.0<1;1,0>:d     0:w               {I@1}
(W)     mov (1|M0)               r4.12<1>:hf   -qnan(0x1FF):hf                             
        shl (16|M0)              r12.0<1>:d    r82.0<1;1,0>:d    1:w               {Compacted}
(f0.1)  sel (16|M0)              r10.0<1>:d    r4.12<0;1,0>:w    0:w               {F@1}
        mov (16|M0)              r86.0<1>:f    r116.0<1;1,0>:f                  {Compacted}
        and (16|M0)              r96.0<1>:d    r12.0<1;1,0>:d    2:w               {Compacted,I@2}
        mov (16|M0)              r114.0<1>:d   -r10.0<1;1,0>:d                  {I@2}
L16184:
        join (16|M0)                         L16688                                
L16200:
        and (16|M0)   (ne)f0.0   r22.0<1>:d    r98.0<1;1,0>:d    63:w               {Compacted}
(f0.0)  goto (16|M0)                         L16248                  L16248                
L16224:
        mov (16|M0)              r82.0<1>:f    r56.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L16248                  L16352                
L16248:
        join (16|M0)                         L16352                                
L16264:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r22.0<1;1,0>:ud   0x20:uw              {I@4}
(~f1.1) add (16|M0)              r2.0<1>:d     r22.0<1;1,0>:d    -32:w              
(~f1.1) shr (16|M0)              r82.0<1>:ud   r60.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.1)  add (16|M0)              r2.0<1>:d     -r22.0<1;1,0>:d   32:w               {Compacted}
(f1.1)  shr (16|M0)              r8.0<1>:ud    r56.0<1;1,0>:ud   r22.0<1;1,0>:d  
(f1.1)  shl (16|M0)              r2.0<1>:d     r60.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.1)  or (16|M0)               r82.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
L16352:
        join (16|M0)                         L16688                                
L16368:
        shl (16|M0)              r2.0<1>:d     r86.0<1;1,0>:d    2:w               {Compacted}
        and (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     4:w               {Compacted,I@1}
        bfn.0xFE (16|M0)         r76.0<1>:ud   r2.0<1;0>:ud      r96.0<1;0>:ud     r114.0<1>:ud     {I@1} // s0|s1|s2
        cmp (16|M0)   (eq)f1.0   null<1>:d     r76.0<1;1,0>:d    0:w               {I@1}
(~f1.0) goto (16|M0)                         L16464                  L16464                
L16432:
        mov (16|M0)              r84.0<1>:d    0:w                              
        goto (16|M0)                         L16464                  L16616                
L16464:
        join (16|M0)                         L16616                                
L16480:
        cmp (16|M0)   (gt)f0.1   null<1>:d     r76.0<1;1,0>:ud   0x4:uw             
(~f0.1) goto (16|M0)                         L16544                  L16544                
L16512:
        mov (16|M0)              r84.0<1>:d    1:w                              
        goto (16|M0)                         L16544                  L16616                
L16544:
        join (16|M0)                         L16616                                
L16560:
        and (16|M0)   (ne)f0.0   null<1>:d     r82.0<1;1,0>:d    1:w               {Compacted}
(W)     mov (1|M0)               r2.0<1>:hf    0x1:hf                             
(f0.0)  cmp (16|M0)   (eq)f0.0   null<1>:d     r76.0<1;1,0>:d    4:w              
(f0.0)  sel (16|M0)              r84.0<1>:d    r2.0<0;1,0>:w     0:w               {F@1}
L16616:
        join (16|M0)                         L16688                                
L16632:
        add (16|M0)              r2.0<1>:d     r84.0<1;1,0>:d    r82.0<1;1,0>:d   {Compacted,I@2}
        cmp (16|M0)   (gt)f0.1   null<1>:d     r2.0<1;1,0>:ud    0x7FFFFF:ud              {I@1}
(W)     mov (1|M0)               r4.6<1>:f     0x800000:f                               {Compacted}
(~f0.1) sel (16|M0)              r44.0<1>:d    r2.0<1;1,0>:d     0:w              
(f0.1)  sel (16|M0)              r42.0<1>:d    r4.6<0;1,0>:d     0:w               {Compacted,F@1}
L16688:
        join (16|M0)                         L16752                                
L16704:
        and (16|M0)              r2.0<1>:d     r52.0<1;1,0>:d    -2147483648:d              
        bfn.0xFE (16|M0)         r94.0<1>:ud   r2.0<1;0>:ud      r42.0<1;0>:ud     r44.0<1>:ud      {I@1} // s0|s1|s2
        goto (16|M0)                         L16752                  L19776                
L16752:
        join (16|M0)                         L17248                                
L16768:
        and (16|M0)   (ne)f0.0   r102.0<1>:d   r72.0<1;1,0>:d    63:w               {Compacted}
(f0.0)  goto (16|M0)                         L16840                  L16840                
L16792:
        mov (16|M0)              r110.0<1>:d   -1:w                              
        mov (16|M0)              r124.0<1>:d   -1:w                              
        goto (16|M0)                         L16840                  L17024                
L16840:
        join (16|M0)                         L17024                                
L16856:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r102.0<1;1,0>:ud  0x20:uw              {I@6}
(f1.1)  goto (16|M0)                         L16960                  L16960                
L16888:
        add (16|M0)              r2.0<1>:d     r102.0<1;1,0>:d   -32:w               {Compacted}
(W)     mov (1|M0)               r4.12<1>:hf   -qnan(0x1FF):hf                             
        mov (16|M0)              r110.0<1>:d   0:w                              
        shl (16|M0)              r124.0<1>:d   r4.12<0;1,0>:w    r2.0<1;1,0>:d    {A@1}
        goto (16|M0)                         L16960                  L17024                
L16960:
        join (16|M0)                         L17024                                
L16976:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (16|M0)              r124.0<1>:d   -1:w                              
        shl (16|M0)              r110.0<1>:d   r2.0<0;1,0>:w     r102.0<1;1,0>:d  {F@1}
L17024:
        join (16|M0)                         L17248                                
L17040:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r110.0<1;0>:ud    r6.0<0;0>:ud      r56.0<1>:ud      {I@2} // (s0^s1)&s2
        cmp (16|M0)   (ne)f1.1   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
        bfn.0x60 (16|M0)         r8.0<1>:ud    r124.0<1;0>:ud    r6.0<0;0>:ud      r60.0<1>:ud      // (s0^s1)&s2
        cmp (16|M0)   (gt)f1.0   null<1>:d     r52.0<1;1,0>:d    -1:w              
(~f1.1) cmp (16|M0)   (ne)f1.1   null<1>:d     r8.0<1;1,0>:d     0:w               {I@2}
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r74.0<1;1,0>:d    -150:w              
(f1.0)  goto (16|M0)                         L17192                  L17192                
L17152:
(W)     mov (1|M0)               r2.0<1>:ud    0x80000001:ud                             
(f1.1)  sel (16|M0)              r94.0<1>:f    r2.0<0;1,0>:f     -0.0:f               {Compacted,I@1}
        goto (16|M0)                         L17192                  L19776                
L17192:
        join (16|M0)                         L17248                                
L17208:
(W)     mov (1|M0)               r2.0<1>:ud    0x1:ud                              {F@1}
(f1.1)  sel (16|M0)              r94.0<1>:f    r2.0<0;1,0>:f     0.0:f               {Compacted,I@1}
        goto (16|M0)                         L17248                  L19776                
L17248:
        join (16|M0)                         L19560                                
L17264:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r72.0<1;1,0>:ud   0x18:uw              {F@1}
        add3 (16|M0)             r80.0<1>:d    r64.0<1;0>:d      r72.0<1;0>:d      -46:w              
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r94.0<1;1,0>:d    0:w              
(f1.1)  goto (16|M0)                         L19248                  L19248                
L17328:
        shl (16|M0)              r2.0<1>:d     r100.0<1;1,0>:d   1:w               {Compacted}
        shr (16|M0)              r8.0<1>:ud    r100.0<1;1,0>:ud  31:w              
        shl (16|M0)              r10.0<1>:d    r126.0<1;1,0>:d   1:w               {Compacted}
        cmp (16|M0)   (lt)f1.1   null<1>:d     r2.0<1;1,0>:ud    0x4E:uw              {I@3}
        or (16|M0)               r10.0<1>:d    r10.0<1;1,0>:d    r8.0<1;1,0>:d    {Compacted,I@2}
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r10.0<1;1,0>:d    0:w               {I@1}
(~f1.1) cmp (16|M0)   (lt)f1.1   null<1>:d     r10.0<1;1,0>:d    0:w              
(f1.1)  goto (16|M0)                         L17560                  L17560                
L17432:
        cmp (16|M0)   (eq)f1.0   null<1>:d     r100.0<1;1,0>:d   39:w              
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r126.0<1;1,0>:d   0:w              
(~f1.0) goto (16|M0)                         L17560                  L17624                
L17480:
        shr (16|M0)              r82.0<1>:ud   r56.0<1;1,0>:ud   1:w              
        mov (16|M0)              r12.0<1>:d    0:w                              
        mov (16|M0)              r84.0<1>:d    0:w                              
        mov (16|M0)              r60.0<1>:f    r82.0<1;1,0>:f                   {Compacted,I@3}
        mov (16|M0)              r82.0<1>:f    r56.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L17560                  L18728                
L17560:
        join (16|M0)                         L17624                                
L17576:
        cmp (16|M0)   (eq)f0.1   null<1>:d     r100.0<1;1,0>:d   38:w              
(f0.1)  cmp (16|M0)   (eq)f0.1   null<1>:d     r126.0<1;1,0>:d   0:w              
(f0.1)  goto (16|M0)                         L17624                  L18640                
L17624:
        join (16|M0)                         L18640                                
L17640:
        add (16|M0)              r2.0<1>:d     -r100.0<1;1,0>:d  39:w               {Compacted}
        and (16|M0)   (ne)f0.1   r40.0<1>:d    r2.0<1;1,0>:d     63:w               {I@1}
        add (16|M0)              r46.0<1>:d    -r100.0<1;1,0>:d  40:w               {Compacted}
(f0.1)  goto (16|M0)                         L17712                  L17712                
L17688:
        mov (16|M0)              r120.0<1>:f   r56.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L17712                  L17824                
L17712:
        join (16|M0)                         L17824                                
L17728:
        cmp (16|M0)   (lt)f0.0   null<1>:d     r40.0<1;1,0>:ud   0x20:uw              {I@5}
(~f0.0) add (16|M0)              r2.0<1>:d     r40.0<1;1,0>:d    -32:w              
(~f0.0) shr (16|M0)              r82.0<1>:ud   r60.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f0.0)  add (16|M0)              r2.0<1>:d     -r40.0<1;1,0>:d   32:w               {Compacted}
(f0.0)  shr (16|M0)              r8.0<1>:ud    r56.0<1;1,0>:ud   r40.0<1;1,0>:d  
(f0.0)  shl (16|M0)              r2.0<1>:d     r60.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f0.0)  or (16|M0)               r82.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
        mov (16|M0)              r120.0<1>:f   r82.0<1;1,0>:f                   {Compacted,I@1}
L17824:
        join (16|M0)                         L18640                                
L17840:
        add (16|M0)              r84.0<1>:d    -r100.0<1;1,0>:d  38:w               {Compacted}
        and (16|M0)   (ne)f1.1   r44.0<1>:d    r84.0<1;1,0>:d    63:w               {I@1}
(f1.1)  goto (16|M0)                         L17904                  L17904                
L17880:
        mov (16|M0)              r110.0<1>:f   r56.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L17904                  L18016                
L17904:
        join (16|M0)                         L18016                                
L17920:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r44.0<1;1,0>:ud   0x20:uw              {I@4}
(~f1.0) add (16|M0)              r2.0<1>:d     r44.0<1;1,0>:d    -32:w              
(~f1.0) shr (16|M0)              r82.0<1>:ud   r60.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.0)  add (16|M0)              r2.0<1>:d     -r44.0<1;1,0>:d   32:w               {Compacted}
(f1.0)  shr (16|M0)              r8.0<1>:ud    r56.0<1;1,0>:ud   r44.0<1;1,0>:d  
(f1.0)  shl (16|M0)              r2.0<1>:d     r60.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.0)  or (16|M0)               r82.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
        mov (16|M0)              r110.0<1>:f   r82.0<1;1,0>:f                   {Compacted,I@1}
L18016:
        join (16|M0)                         L18640                                
L18032:
        and (16|M0)   (ne)f0.1   r58.0<1>:d    r84.0<1;1,0>:d    63:w              
(f0.1)  goto (16|M0)                         L18112                  L18112                
L18064:
        mov (16|M0)              r68.0<1>:d    -1:w                              
        mov (16|M0)              r82.0<1>:d    -1:w                               {F@1}
        goto (16|M0)                         L18112                  L18296                
L18112:
        join (16|M0)                         L18296                                
L18128:
        cmp (16|M0)   (lt)f0.0   null<1>:d     r58.0<1;1,0>:ud   0x20:uw              {I@6}
(f0.0)  goto (16|M0)                         L18232                  L18232                
L18160:
        add (16|M0)              r2.0<1>:d     r58.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r4.12<1>:hf   -qnan(0x1FF):hf                             
        mov (16|M0)              r68.0<1>:d    0:w                              
        shl (16|M0)              r82.0<1>:d    r4.12<0;1,0>:w    r2.0<1;1,0>:d    {A@1}
        goto (16|M0)                         L18232                  L18296                
L18232:
        join (16|M0)                         L18296                                
L18248:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (16|M0)              r82.0<1>:d    -1:w                              
        shl (16|M0)              r68.0<1>:d    r2.0<0;1,0>:w     r58.0<1;1,0>:d   {F@1}
L18296:
        join (16|M0)                         L18640                                
L18312:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r68.0<1;0>:ud     r6.0<0;0>:ud      r56.0<1>:ud      {I@2} // (s0^s1)&s2
        cmp (16|M0)   (ne)f0.0   null<1>:d     r2.0<1;1,0>:d     0:w               {Compacted,I@1}
        bfn.0x60 (16|M0)         r8.0<1>:ud    r82.0<1;0>:ud     r6.0<0;0>:ud      r60.0<1>:ud      // (s0^s1)&s2
(~f0.0) cmp (16|M0)   (ne)f0.0   null<1>:d     r8.0<1;1,0>:d     0:w               {I@1}
(W)     mov (1|M0)               r4.12<1>:hf   -qnan(0x1FF):hf                             
        and (16|M0)   (ne)f1.1   r42.0<1>:d    r46.0<1;1,0>:d    63:w              
(f0.0)  sel (16|M0)              r10.0<1>:d    r4.12<0;1,0>:w    0:w               {F@1}
        mov (16|M0)              r12.0<1>:d    -r10.0<1;1,0>:d                  {I@1}
(f1.1)  goto (16|M0)                         L18472                  L18472                
L18448:
        mov (16|M0)              r82.0<1>:f    r56.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L18472                  L18576                
L18472:
        join (16|M0)                         L18576                                
L18488:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r42.0<1;1,0>:ud   0x20:uw             
(~f1.0) add (16|M0)              r2.0<1>:d     r42.0<1;1,0>:d    -32:w              
(~f1.0) shr (16|M0)              r82.0<1>:ud   r60.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.0)  add (16|M0)              r2.0<1>:d     -r42.0<1;1,0>:d   32:w               {Compacted}
(f1.0)  shr (16|M0)              r8.0<1>:ud    r56.0<1;1,0>:ud   r42.0<1;1,0>:d  
(f1.0)  shl (16|M0)              r2.0<1>:d     r60.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.0)  or (16|M0)               r82.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
L18576:
        join (16|M0)                         L18640                                
L18592:
        shl (16|M0)              r2.0<1>:d     r110.0<1;1,0>:d   1:w               {Compacted}
        mov (16|M0)              r60.0<1>:f    r82.0<1;1,0>:f                   {Compacted,I@3}
        and (16|M0)              r84.0<1>:d    r2.0<1;1,0>:d     2:w               {Compacted,I@1}
        mov (16|M0)              r82.0<1>:f    r120.0<1;1,0>:f                  {Compacted}
        goto (16|M0)                         L18640                  L18728                
L18640:
        join (16|M0)                         L18728                                
L18656:
        shr (16|M0)              r82.0<1>:ud   r56.0<1;1,0>:ud   2:w               {F@1}
        mov (16|M0)              r12.0<1>:d    0:w                              
        mov (16|M0)              r84.0<1>:d    0:w                              
        mov (16|M0)              r60.0<1>:f    r82.0<1;1,0>:f                   {Compacted,I@3}
        shr (16|M0)              r82.0<1>:ud   r56.0<1;1,0>:ud   1:w               {F@1}
L18728:
        join (16|M0)                         L19248                                
L18744:
        shl (16|M0)              r2.0<1>:d     r82.0<1;1,0>:d    2:w               {Compacted,I@2}
        and (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     4:w               {Compacted,I@1}
        bfn.0xFE (16|M0)         r108.0<1>:ud  r2.0<1;0>:ud      r84.0<1;0>:ud     r12.0<1>:ud      {I@1} // s0|s1|s2
        cmp (16|M0)   (eq)f0.1   null<1>:d     r108.0<1;1,0>:d   0:w               {I@1}
        and (16|M0)              r40.0<1>:d    r60.0<1;1,0>:d    8388607:d              
(~f0.1) goto (16|M0)                         L18856                  L18856                
L18824:
        mov (16|M0)              r100.0<1>:d   0:w                              
        goto (16|M0)                         L18856                  L19016                
L18856:
        join (16|M0)                         L19016                                
L18872:
        cmp (16|M0)   (gt)f0.0   null<1>:d     r108.0<1;1,0>:ud  0x4:uw             
(~f0.0) goto (16|M0)                         L18936                  L18936                
L18904:
        mov (16|M0)              r100.0<1>:d   1:w                              
        goto (16|M0)                         L18936                  L19016                
L18936:
        join (16|M0)                         L19016                                
L18952:
        and (16|M0)   (ne)f1.1   null<1>:d     r60.0<1;1,0>:d    1:w              
(W)     mov (1|M0)               r2.0<1>:hf    0x1:hf                             
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r108.0<1;1,0>:d   4:w              
(f1.1)  sel (16|M0)              r100.0<1>:d   r2.0<0;1,0>:w     0:w               {F@1}
L19016:
        join (16|M0)                         L19248                                
L19032:
        add (16|M0)              r58.0<1>:d    r40.0<1;1,0>:d    r100.0<1;1,0>:d  {Compacted,I@2}
        cmp (16|M0)   (gt)f0.0   null<1>:d     r58.0<1;1,0>:ud   0x7FFFFF:ud              {I@1}
        add3 (16|M0)             r2.0<1>:d     r64.0<1;0>:d      r72.0<1;0>:d      -45:w              
(f0.0)  sel (16|M0)              r46.0<1>:d    r2.0<1;1,0>:d     r80.0<1;1,0>:d   {Compacted,I@1}
        cmp (16|M0)   (eq)f1.1   null<1>:d     r46.0<1;1,0>:d    255:w               {I@1}
(f1.1)  goto (16|M0)                         L19184                  L19184                
L19112:
(~f0.0) sel (16|M0)              r2.0<1>:d     r58.0<1;1,0>:d    0:w              
        and (16|M0)              r8.0<1>:d     r52.0<1;1,0>:d    -2147483648:d              
        shl (16|M0)              r10.0<1>:d    r46.0<1;1,0>:d    23:w               {Compacted}
        bfn.0xFE (16|M0)         r94.0<1>:ud   r8.0<1;0>:ud      r10.0<1;0>:ud     r2.0<1>:ud       {I@1} // s0|s1|s2
        goto (16|M0)                         L19184                  L19776                
L19184:
        join (16|M0)                         L19248                                
L19200:
        cmp (16|M0)   (gt)f0.1   null<1>:d     r52.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r2.0<1>:f     inf:f                               {Compacted,I@4}
(f0.1)  sel (16|M0)              r94.0<1>:f    r2.0<0;1,0>:f     -inf:f               {Compacted,F@1}
        goto (16|M0)                         L19248                  L19776                
L19248:
        join (16|M0)                         L19560                                
L19264:
        and (16|M0)   (ne)f1.0   r40.0<1>:d    r72.0<1;1,0>:d    63:w              
(f1.0)  goto (16|M0)                         L19328                  L19328                
L19296:
        mov (16|M0)              r94.0<1>:d    -1:w                               {F@1}
        goto (16|M0)                         L19328                  L19456                
L19328:
        join (16|M0)                         L19456                                
L19344:
        cmp (16|M0)   (lt)f0.1   null<1>:d     r40.0<1;1,0>:ud   0x20:uw              {I@5}
(f0.1)  goto (16|M0)                         L19408                  L19408                
L19376:
        mov (16|M0)              r94.0<1>:d    0:w                              
        goto (16|M0)                         L19408                  L19456                
L19408:
        join (16|M0)                         L19456                                
L19424:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                             
        shl (16|M0)              r94.0<1>:d    r2.0<0;1,0>:w     r40.0<1;1,0>:d   {F@1}
L19456:
        join (16|M0)                         L19560                                
L19472:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r94.0<1;0>:ud     r6.0<0;0>:ud      r56.0<1>:ud      {I@2} // (s0^s1)&s2
        add (16|M0)              r8.0<1>:d     -r72.0<1;1,0>:d   23:w               {Compacted}
        and (16|M0)              r10.0<1>:d    r52.0<1;1,0>:d    -2147483648:d              
        shl (16|M0)              r12.0<1>:d    r80.0<1;1,0>:d    23:w               {Compacted}
        shl (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     r8.0<1;1,0>:d    {Compacted,I@3}
        bfn.0xFE (16|M0)         r94.0<1>:ud   r10.0<1;0>:ud     r12.0<1;0>:ud     r2.0<1>:ud       {I@1} // s0|s1|s2
        goto (16|M0)                         L19560                  L19776                
L19560:
        join (16|M0)                         L19616                                
L19576:
        cmp (16|M0)   (gt)f0.0   null<1>:d     r52.0<1;1,0>:d    -1:w               {Compacted}
(W)     mov (1|M0)               r2.0<1>:f     inf:f                               {Compacted,I@4}
(f0.0)  sel (16|M0)              r94.0<1>:f    r2.0<0;1,0>:f     -inf:f               {Compacted,F@1}
        goto (16|M0)                         L19616                  L19776                
L19616:
        join (16|M0)                         L19680                                
L19632:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r52.0<1;1,0>:d    0:w              
(W)     mov (1|M0)               r2.0<1>:f     -0.0:f                               {Compacted}
(f1.1)  sel (16|M0)              r94.0<1>:f    r2.0<0;1,0>:f     0.0:f               {Compacted,F@1}
        goto (16|M0)                         L19680                  L19776                
L19680:
        join (16|M0)                         L19744                                
L19696:
        cmp (16|M0)   (gt)f1.0   null<1>:d     r52.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r2.0<1>:f     inf:f                               {Compacted}
(f1.0)  sel (16|M0)              r94.0<1>:f    r2.0<0;1,0>:f     -inf:f               {Compacted,F@1}
        goto (16|M0)                         L19744                  L19776                
L19744:
        join (16|M0)                         L19776                                
L19760:
        bfn.0xF8 (16|M0)         r94.0<1>:ud   r52.0<1;0>:ud     r6.2<0;0>:ud      r6.1<0>:ud       {F@1} // s0&s1|s2
L19776:
        join (16|M0)                         L19792                                
L19792:
        cmp (16|M0)   (lt)f0.0   null<1>:f     r36.0<1;1,0>:f    0.0:f               {Compacted,I@7}
(W)     mov (1|M0)               a0.0<1>:ud    r7.3<0;1,0>:d                    {A@1}
        add (16|M0)              r8.0<1>:d     r34.0<1;1,0>:d    r6.6<0;1,0>:d    {Compacted}
        sync.nop                             null                             {Compacted,$9.src}
(f0.0)  sel (16|M0)              r2.0<1>:f     -r94.0<1;1,0>:f   r94.0<1;1,0>:f   {Compacted,I@4}
        mov (8|M0)               r5.0<1>:hf    r2.0<1;1,0>:f                    {F@1}
        mov (8|M8)               r5.8<1>:hf    r3.0<1;1,0>:f                   
(W)     mov (8|M0)               r127.0<1>:f   r38.0<1;1,0>:f                   {Compacted}
        mov (16|M0)              r10.0<1>:ud   r5.0<1;1,0>:uw                   {A@2}
        send.ugm (16|M0)         null     r8      r10:2   a0.0        0x240E0B04           {ExBSO,A@1,$10} // wr:2+2, rd:0; store.ugm.d16u32.a32.wb.wb.bss[a0.0]
(W)     send.gtwy (1|M0)         null     r127    null:0  0x0            0x02000010           {EOT,A@1} // wr:1+0, rd:0; end of thread
L19928:
        nop                    
(W)     mov (16|M0)              null<1>:ud    0x9E09665A:ud                             
(W)     mov (16|M0)              null<1>:ud    0xA6E09A48:ud                             
(W)     mov (16|M0)              null<1>:ud    0x0:ud                             
(W)     mov (16|M0)              null<1>:ud    0x34:ud                             
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
