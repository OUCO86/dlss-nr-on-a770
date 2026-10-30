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
        sync.nop                             null                             {Compacted,A@1}
        sync.nop                             null                             {Compacted,$2.dst}
(W)     cmp (16|M0)   (eq)f0.1   null<1>:d     r5.4<0;1,0>:d     0:w               {A@1}
(W)     mul (1|M0)               acc0.0<1>:d   r4.3<0;1,0>:d     r36.2<0;1,0>:uw  {I@3}
(W)     mach (1|M0)              r2.0<1>:d     r4.3<0;1,0>:d     r36.1<0;1,0>:d   {$0.dst}
        add3 (16|M0)             r32.0<1>:d    r2.0<0;0>:d       r1.0<1;0>:uw      r4.0<0>:d        {I@1}
(~f0.1) goto (16|M0)                         L416                  L416                
L384:
        mov (16|M0)              r102.0<1>:d   -1:w                              
        goto (16|M0)                         L416                  L784                
L416:
        join (16|M0)                         L784                                
L432:
(W)     xor (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x30:uw              {A@1}
(W)     mov (1|M0)               r2.0<1>:f     r5.4<0;1,0>:ud                   {Compacted,A@1}
(W)     mov (1|M0)               r3.2<1>:f     0xB4C00000:f                               {Compacted,$1.dst}
(W)     math.inv (1|M0)          r3.1<1>:f     r2.0<0;1,0>:f                    {@2,$3}
        mov (16|M0)              r8.0<1>:f     r32.0<1;1,0>:ud                  {Compacted}
        sync.nop                             null                             {Compacted,$3.dst}
(W)     mad (1|M0)               r4.6<1>:f     r3.1<0;0>:f       r3.2<0;0>:f       r3.1<0>:f        {F@2}
(W)     mov (1|M0)               r2.1<1>:ud    r2.0<0;1,0>:f                   
        mov (16|M0)              r12.0<1>:ud   r8.0<1;1,0>:f                    {F@2}
        mul (16|M0)              r10.0<1>:f    r8.0<1;1,0>:f     r4.6<0;1,0>:f    {Compacted,F@1}
(W)     add (1|M0)               r3.0<1>:d     r5.4<0;1,0>:d     -r2.1<0;1,0>:d   {I@2}
        add (16|M0)              r12.0<1>:d    r32.0<1;1,0>:d    -r12.0<1;1,0>:d  {Compacted,I@2}
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
(W)     mul (8|M0)               acc0.0<1>:d   r30.0<1;1,0>:d    r5.8<0;1,0>:uw   {Compacted,I@1}
        mach (8|M0)              r30.0<1>:d    r30.0<1;1,0>:d    r5.4<0;1,0>:d    {Compacted}
(W)     mul (8|M8)               acc0.0<1>:d   r31.0<1;1,0>:d    r5.8<0;1,0>:uw  
        mach (8|M8)              r31.0<1>:d    r31.0<1;1,0>:d    r5.4<0;1,0>:d    {Compacted}
        add (16|M0)              r30.0<1>:d    r32.0<1;1,0>:d    -r30.0<1;1,0>:d  {Compacted,I@1}
        cmp (16|M0)   (ge)f1.0   r8.0<1>:ud    r30.0<1;1,0>:ud   r5.4<0;1,0>:ud   {I@1}
        add3 (16|M0)             r102.0<1>:d   r28.0<1;0>:d      r14.0<1;0>:d      -r8.0<1>:d       {I@1}
L784:
        join (16|M0)                         L800                                
L800:
(W)     mul (8|M0)               acc0.0<1>:d   r102.0<1;1,0>:d   r5.8<0;1,0>:uw   {Compacted,I@2}
        mach (8|M0)              r2.0<1>:d     r102.0<1;1,0>:d   r5.4<0;1,0>:d    {Compacted}
(W)     mul (8|M8)               acc0.0<1>:d   r103.0<1;1,0>:d   r5.8<0;1,0>:uw  
        mach (8|M8)              r3.0<1>:d     r103.0<1;1,0>:d   r5.4<0;1,0>:d    {Compacted,$1.dst}
(W)     mov (1|M0)               a0.0<1>:ud    r6.1<0;1,0>:d                    {A@1}
        add (16|M0)              r8.0<1>:d     r32.0<1;1,0>:d    -r2.0<1;1,0>:d   {Compacted,I@2}
        shr (16|M0)              r10.0<1>:ud   r8.0<1;1,0>:ud    5:w               {I@1}
        mul (8|M0)               acc0.0<1>:ud  r10.0<1;1,0>:ud   r5.10<0;1,0>:uw  {I@1}
        mach (8|M0)              r12.0<1>:ud   r10.0<1;1,0>:ud   r5.5<0;1,0>:ud   {AccWrEn,Compacted}
        shl (16|M0)              r20.0<1>:d    r8.0<1;1,0>:d     2:w               {Compacted}
        mov (8|M0)               r14.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mul (8|M8)               acc0.0<1>:ud  r11.0<1;1,0>:ud   r5.10<0;1,0>:uw 
        mach (8|M8)              r13.0<1>:ud   r11.0<1;1,0>:ud   r5.5<0;1,0>:ud   {AccWrEn}
(W)     mov (1|M0)               r2.0<1>:d     124:w                              
        mov (8|M8)               r15.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
(W)     mov (1|M0)               r6.5<1>:f     -0.0:f                               {Compacted}
        add (16|M0)              r48.0<1>:d    r14.0<1;1,0>:d    r102.0<1;1,0>:d  {Compacted,I@1}
        shl (16|M0)              r18.0<1>:d    r48.0<1;1,0>:d    7:w               {Compacted,I@1}
        bfn.0xEA (16|M0)         r18.0<1>:ud   r18.0<1;0>:ud     r20.0<1;0>:ud     r2.0<0>:ud       {I@1} // s0|s1&s2
        send.ugm (16|M0)         r22      r18     null:0  a0.0        0x24280500           {ExBSO,A@1,$4} // wr:2+0, rd:2; load.ugm.d32.a32.ca.ca.bss[a0.0]
(W)     mov (1|M0)               r6.4<1>:f     inf:f                               {Compacted}
(W)     mov (1|M0)               r6.1<1>:d     -1:w                              
        mov (16|M0)              r16.0<1>:f    r12.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r3.0<1>:hf    r22.0<1;1,0>:f                   {$4.dst}
        mov (8|M8)               r3.8<1>:hf    r23.0<1;1,0>:f                  
        mov (8|M0)               r30.0<1>:f    r3.0<1;1,0>:hf                   {F@2}
        mov (8|M8)               r31.0<1>:f    r3.8<1;1,0>:hf                   {F@2}
        shr (16|M0)              r46.0<1>:ud   r30.0<1;1,0>:ud   23:w               {A@1}
        and (16|M0)   (ne)f1.0   r102.0<1>:d   r30.0<1;1,0>:d    8388607:d              
        and (16|M0)              r124.0<1>:d   r46.0<1;1,0>:d    255:w               {Compacted,I@2}
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r124.0<1;1,0>:d   255:w               {I@1}
(~f1.0) goto (16|M0)                         L1232                  L1232                
L1200:
        mov (16|M0)              r34.0<1>:ud   0x7FC00000:ud                             
        goto (16|M0)                         L1232                  L7472                
L1232:
        join (16|M0)                         L7472                                
L1248:
(W)     mov (1|M0)               a0.0<1>:ud    r6.2<0;1,0>:d                    {A@1}
        shl (16|M0)              r2.0<1>:d     r48.0<1;1,0>:d    2:w               {Compacted}
        send.ugm (16|M0)         r112     r2      null:0  a0.0        0x24280500           {ExBSO,A@1,$5} // wr:2+0, rd:2; load.ugm.d32.a32.ca.ca.bss[a0.0]
        shr (16|M0)              r40.0<1>:ud   r112.0<1;1,0>:ud  23:w               {$5.dst}
        and (16|M0)   (ne)f0.1   r94.0<1>:d    r112.0<1;1,0>:d   8388607:d              
        and (16|M0)              r120.0<1>:d   r40.0<1;1,0>:d    255:w               {Compacted,I@2}
(f0.1)  cmp (16|M0)   (eq)f0.1   null<1>:d     r120.0<1;1,0>:d   255:w               {I@1}
(~f0.1) goto (16|M0)                         L1392                  L1392                
L1360:
        mov (16|M0)              r34.0<1>:ud   0x7FC00000:ud                             
        goto (16|M0)                         L1392                  L7472                
L1392:
        join (16|M0)                         L7472                                
L1408:
        cmp (16|M0)   (eq)f0.0   null<1>:d     r102.0<1;1,0>:d   0:w               {Compacted}
        cmp (16|M0)   (eq)f1.1   null<1>:d     r94.0<1;1,0>:d    0:w              
(f0.0)  cmp (16|M0)   (eq)f0.0   null<1>:d     r124.0<1;1,0>:d   255:w              
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r120.0<1;1,0>:d   255:w              
(W)     mov (1|M0)               r2.0<1>:hf    0x1:hf                             
        xor (16|M0)              r38.0<1>:d    r112.0<1;1,0>:d   r30.0<1;1,0>:d   {Compacted}
(f0.0)  sel (16|M0)              acc0.0<1>:uw  r2.0<0;1,0>:uw    0x0:uw              {F@1}
(f1.1)  sel (16|M0)              acc2.0<1>:uw  r2.0<0;1,0>:uw    0x0:uw             
        or (16|M0)    (ne)f0.0   null<1>:uw    acc0.0<1;1,0>:uw  acc2.0<1;1,0>:uw
(f0.0)  goto (16|M0)                         L7440                  L7440                
L1552:
        or (16|M0)    (eq)f0.0   null<1>:d     r120.0<1;1,0>:d   r94.0<1;1,0>:d  
        or (16|M0)               r2.0<1>:d     r124.0<1;1,0>:d   r102.0<1;1,0>:d  {Compacted}
(~f0.0) cmp (16|M0)   (eq)f0.0   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
(~f0.0) goto (16|M0)                         L1640                  L1640                
L1608:
        mov (16|M0)              r34.0<1>:ud   0x0:ud                             
        goto (16|M0)                         L1640                  L7472                
L1640:
        join (16|M0)                         L7440                                
L1656:
        cmp (16|M0)   (eq)f0.1   null<1>:d     r124.0<1;1,0>:d   0:w              
        cmp (16|M0)   (eq)f0.0   null<1>:d     r120.0<1;1,0>:d   0:w               {Compacted}
        add (16|M0)              r76.0<1>:d    r124.0<1;1,0>:d   -127:w               {Compacted}
        add (16|M0)              r16.0<1>:d    r120.0<1;1,0>:d   -127:w               {Compacted}
(f0.1)  mov (16|M0)              r76.0<1>:d    -126:w                              
(f0.0)  mov (16|M0)              r16.0<1>:d    -126:w                              
        add (16|M0)              r60.0<1>:d    r76.0<1;1,0>:d    r16.0<1;1,0>:d   {Compacted,I@1}
        cmp (16|M0)   (gt)f1.1   null<1>:d     r60.0<1;1,0>:d    127:w               {I@1}
(f1.1)  goto (16|M0)                         L7376                  L7376                
L1768:
        or (16|M0)    (eq)f1.0   null<4>:b     r46.0<1;1,0>:d    r40.0<1;1,0>:d  
(f1.0)  goto (16|M0)                         L7312                  L7312                
L1800:
(W)     mov (1|M0)               r2.0<1>:hf    0.0:hf                             
(W)     mov (1|M0)               r5.4<1>:d     0:w                              
(f0.1)  sel (16|M0)              r8.0<1>:d     r2.0<0;1,0>:w     8388608:d               {F@1}
(f0.0)  sel (16|M0)              r10.0<1>:d    r2.0<0;1,0>:w     8388608:d              
        or (16|M0)               r8.0<1>:d     r8.0<1;1,0>:d     r102.0<1;1,0>:d  {Compacted,I@2}
        or (16|M0)               r10.0<1>:d    r10.0<1;1,0>:d    r94.0<1;1,0>:d   {Compacted,I@2}
        mul (8|M0)               acc0.0<1>:ud  r8.0<1;1,0>:ud    r10.0<2;1,0>:uw  {I@1}
        mach (8|M0)              r12.0<1>:ud   r8.0<1;1,0>:ud    r10.0<1;1,0>:ud  {AccWrEn,Compacted}
(W)     mov (1|M0)               r5.3<1>:f     -0.0:f                               {Compacted}
        mov (8|M0)               r14.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mul (8|M8)               acc0.0<1>:ud  r9.0<1;1,0>:ud    r11.0<2;1,0>:uw 
        mach (8|M8)              r13.0<1>:ud   r9.0<1;1,0>:ud    r11.0<1;1,0>:ud  {AccWrEn}
(W)     mov (2|M0)               r5.0<1>:d     0:w                              
        mov (8|M8)               r15.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mov (16|M0)              r54.0<1>:f    r12.0<1;1,0>:f                   {Compacted,A@3}
        mov (16|M0)              r48.0<1>:f    r14.0<1;1,0>:f                   {Compacted,I@1}
L1992:
(W)     shl (1|M0)               r2.0<1>:d     r5.3<0;1,0>:d     31:w               {Compacted,F@3}
(W)     shr (1|M0)               r2.1<1>:ud    r5.4<0;1,0>:ud    1:w              
(W)     cmp (16|M0)   (gt)f0.0   null<1>:d     r5.0<0;1,0>:ud    0x3E:uw             
(W)     or (1|M0)                r5.4<1>:d     r2.1<0;1,0>:d     r2.0<0;1,0>:d    {I@2}
        bfn.0xA8 (16|M0)         r8.0<1>:ud    r48.0<1;0>:ud     r2.1<0;0>:ud      r2.0<0>:ud       {F@1} // s0&(s1|s2)
(W)     shr (1|M0)               r5.2<1>:ud    r5.3<0;1,0>:ud    1:w              
(W&f0.0) cmp (16|M0)  (eq)f0.0   null<1>:d     r5.1<0;1,0>:d     0:w              
        cmp (16|M0)   (eq)f1.1   null<1>:d     r8.0<1;1,0>:d     r5.4<0;1,0>:d    {I@3}
        and (16|M0)              r10.0<1>:d    r54.0<1;1,0>:d    r5.2<0;1,0>:d    {Compacted,I@3}
(W&~f0.0) cmp (16|M0) (gt)f0.0   null<1>:d     r5.1<0;1,0>:ud    0x0:uw             
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r10.0<1;1,0>:d    r5.2<0;1,0>:d    {I@2}
(W)     mov (1|M0)               r4.12<1>:hf   0x1:hf                             
(W)     addc (1|M0)              r13.0<1>:ud   r5.0<0;1,0>:ud    0x1:ud              {AccWrEn}
(f0.0)  sel (16|M0)              r7.0<1>:uw    r4.12<0;1,0>:uw   0x0:uw              {Compacted,F@1}
(f1.1)  sel (16|M0)              acc2.0<1>:uw  r4.12<0;1,0>:uw   0x0:uw             
(W)     mov (1|M0)               r3.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        or (16|M0)    (ne)f1.0   null<1>:uw    r7.0<1;1,0>:uw    acc2.0<1;1,0>:uw {I@3}
(W)     add (1|M0)               r5.5<1>:ud    r3.0<0;1,0>:ud    r5.1<0;1,0>:ud   {I@2}
        mov (16|M0)              r96.0<1>:f    r5.0<0;1,0>:f                    {Compacted}
        mov (16|M0)              r94.0<1>:d    r5.1<0;1,0>:d                   
        mov (16|M0)              r88.0<1>:f    r13.0<0;1,0>:f                   {Compacted}
        mov (16|M0)              r116.0<1>:d   r5.5<0;1,0>:d                    {I@2}
(f1.0)  goto (16|M0)                         L2368                  L2368                
L2312:
(W)     mov (1|M0)               r5.3<1>:d     r5.2<0;1,0>:d                   
(W)     mov (1|M0)               r5.0<1>:f     r13.0<0;1,0>:f                   {Compacted}
(W)     mov (1|M0)               r5.1<1>:d     r5.5<0;1,0>:d                   
(W)     jmpi                                 L1992                                
L2368:
        join (16|M0)                         L7312                                
L2384:
(W)     mov (1|M0)               r2.0<1>:f     8.68805e-44:f                              
(W)     mov (1|M0)               r3.0<1>:hf    0.0:hf                             
        subb (8|M0)              r68.0<1>:ud   r2.0<0;1,0>:ud    r96.0<1;1,0>:ud  {AccWrEn,Compacted,F@2}
        add3 (8|M0)              r62.0<1>:ud   -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r94.0<1>:ud     {A@1}
        subb (8|M8)              r69.0<1>:ud   r2.0<0;1,0>:ud    r97.0<1;1,0>:ud  {AccWrEn}
        add3 (16|M0)             r58.0<1>:d    r60.0<1;0>:d      r68.0<1;0>:d      -46:w               {I@1}
        cmp (16|M0)   (gt)f0.1   null<1>:d     r58.0<1;1,0>:d    127:w               {I@1}
        add3 (8|M8)              r63.0<1>:ud   -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r95.0<1>:ud    
        add3 (16|M0)             r56.0<1>:d    r76.0<1;0>:d      r16.0<1;0>:d      r68.0<1>:d      
(f0.1)  goto (16|M0)                         L7256                  L7256                
L2536:
        cmp (16|M0)   (gt)f0.0   null<1>:d     r58.0<1;1,0>:d    -127:w               {Compacted}
(f0.0)  goto (16|M0)                         L4976                  L4976                
L2560:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r58.0<1;1,0>:ud   0xFFFFFF6B:ud             
(f1.1)  goto (16|M0)                         L4472                  L4472                
L2592:
(W)     mov (1|M0)               r2.0<1>:f     8.82818e-44:f                              
(W)     mov (1|M0)               r3.0<1>:hf    0.0:hf                              {I@7}
        subb (8|M0)              r108.0<1>:ud  r2.0<0;1,0>:ud    r96.0<1;1,0>:ud  {AccWrEn,Compacted,F@2}
        add3 (16|M0)             r82.0<1>:d    r60.0<1;0>:d      r68.0<1;0>:d      104:w              
        add3 (8|M0)              r8.0<1>:ud    -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r94.0<1>:ud     {F@1}
        subb (8|M8)              r109.0<1>:ud  r2.0<0;1,0>:ud    r97.0<1;1,0>:ud  {AccWrEn}
        cmp (16|M0)   (gt)f0.1   null<1>:d     r108.0<1;1,0>:ud  r82.0<1;1,0>:ud  {I@1}
        add3 (8|M8)              r9.0<1>:ud    -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r95.0<1>:ud    
(f0.1)  cmp (16|M0)   (eq)f0.1   null<1>:d     r8.0<1;1,0>:d     0:w               {I@1}
(~f0.1) cmp (16|M0)   (gt)f0.1   null<1>:d     r8.0<1;1,0>:ud    0x0:uw             
(f0.1)  goto (16|M0)                         L2816                  L2816                
L2760:
        add3 (16|M0)             r2.0<1>:d     r56.0<1;0>:d      -r108.0<1;0>:d    104:w              
        mov (16|M0)              r114.0<1>:d   0:w                              
        shl (16|M0)              r116.0<1>:d   r48.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
        goto (16|M0)                         L2816                  L4408                
L2816:
        join (16|M0)                         L4408                                
L2832:
        add3 (16|M0)             r74.0<1>:d    r108.0<1;0>:d     -r56.0<1;0>:d     -104:w              
        cmp (16|M0)   (lt)f1.0   null<1>:d     r74.0<1;1,0>:d    2:w               {Compacted,I@1}
(f1.0)  goto (16|M0)                         L2968                  L2968                
L2872:
        cmp (16|M0)   (eq)f0.1   null<1>:d     r74.0<1;1,0>:d    2:w              
(~f0.1) goto (16|M0)                         L2968                  L3064                
L2904:
        shr (16|M0)              r80.0<1>:ud   r48.0<1;1,0>:ud   1:w              
        and (16|M0)              r100.0<1>:d   r48.0<1;1,0>:d    1:w               {Compacted}
        mov (16|M0)              r70.0<1>:d    0:w                              
        mov (16|M0)              r58.0<1>:f    r80.0<1;1,0>:f                   {Compacted,I@3}
        goto (16|M0)                         L2968                  L3880                
L2968:
        join (16|M0)                         L3064                                
L2984:
        cmp (16|M0)   (eq)f0.0   null<1>:d     r74.0<1;1,0>:d    1:w               {Compacted}
(~f0.0) goto (16|M0)                         L3064                  L3064                
L3008:
        mov (16|M0)              r70.0<1>:d    0:w                              
        mov (16|M0)              r100.0<1>:d   0:w                              
        mov (16|M0)              r58.0<1>:f    r48.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L3064                  L3880                
L3064:
        join (16|M0)                         L3880                                
L3080:
        add3 (16|M0)             r2.0<1>:d     r108.0<1;0>:d     -r82.0<1;0>:d     -1:w              
        and (16|M0)   (ne)f1.1   r8.0<1>:d     r2.0<1;1,0>:d     63:w               {I@1}
(f1.1)  goto (16|M0)                         L3152                  L3152                
L3128:
        mov (16|M0)              r76.0<1>:f    r48.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L3152                  L3264                
L3152:
        join (16|M0)                         L3264                                
L3168:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r8.0<1;1,0>:ud    0x20:uw              {I@4}
(~f1.0) add (16|M0)              r2.0<1>:d     r8.0<1;1,0>:d     -32:w              
(~f1.0) shr (16|M0)              r80.0<1>:ud   r54.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.0)  add (16|M0)              r2.0<1>:d     -r8.0<1;1,0>:d    32:w               {Compacted}
(f1.0)  shl (16|M0)              r2.0<1>:d     r54.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@1}
(f1.0)  shr (16|M0)              r8.0<1>:ud    r48.0<1;1,0>:ud   r8.0<1;1,0>:d   
(f1.0)  or (16|M0)               r80.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
        mov (16|M0)              r76.0<1>:f    r80.0<1;1,0>:f                   {Compacted,I@1}
L3264:
        join (16|M0)                         L3880                                
L3280:
        add3 (16|M0)             r30.0<1>:d    r108.0<1;0>:d     -r82.0<1;0>:d     -2:w              
        and (16|M0)   (ne)f0.1   r4.0<1>:d     r30.0<1;1,0>:d    63:w               {I@1}
(f0.1)  goto (16|M0)                         L3352                  L3352                
L3328:
        mov (16|M0)              r80.0<1>:f    r48.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L3352                  L3456                
L3352:
        join (16|M0)                         L3456                                
L3368:
        cmp (16|M0)   (lt)f0.0   null<1>:d     r4.0<1;1,0>:ud    0x20:uw              {I@4}
(~f0.0) add (16|M0)              r2.0<1>:d     r4.0<1;1,0>:d     -32:w              
(~f0.0) shr (16|M0)              r80.0<1>:ud   r54.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f0.0)  add (16|M0)              r2.0<1>:d     -r4.0<1;1,0>:d    32:w               {Compacted}
(f0.0)  shr (16|M0)              r8.0<1>:ud    r48.0<1;1,0>:ud   r4.0<1;1,0>:d   
(f0.0)  shl (16|M0)              r2.0<1>:d     r54.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f0.0)  or (16|M0)               r80.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
L3456:
        join (16|M0)                         L3880                                
L3472:
        and (16|M0)   (ne)f1.1   r110.0<1>:d   r30.0<1;1,0>:d    63:w              
        and (16|M0)              r100.0<1>:d   r80.0<1;1,0>:d    1:w               {Compacted,I@3}
(f1.1)  goto (16|M0)                         L3560                  L3560                
L3512:
        mov (16|M0)              r10.0<1>:d    -1:w                              
        mov (16|M0)              r24.0<1>:d    -1:w                              
        goto (16|M0)                         L3560                  L3744                
L3560:
        join (16|M0)                         L3744                                
L3576:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r110.0<1;1,0>:ud  0x20:uw              {I@7}
(f1.0)  goto (16|M0)                         L3680                  L3680                
L3608:
        add (16|M0)              r2.0<1>:d     r110.0<1;1,0>:d   -32:w               {Compacted}
(W)     mov (1|M0)               r4.12<1>:hf   -qnan(0x1FF):hf                             
        mov (16|M0)              r10.0<1>:d    0:w                              
        shl (16|M0)              r24.0<1>:d    r4.12<0;1,0>:w    r2.0<1;1,0>:d    {A@1}
        goto (16|M0)                         L3680                  L3744                
L3680:
        join (16|M0)                         L3744                                
L3696:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (16|M0)              r24.0<1>:d    -1:w                              
        shl (16|M0)              r10.0<1>:d    r2.0<0;1,0>:w     r110.0<1;1,0>:d  {F@1}
L3744:
        join (16|M0)                         L3880                                
L3760:
        bfn.0x28 (16|M0)         r2.0<1>:ud    r48.0<1;0>:ud     r10.0<1;0>:ud     r6.1<0>:ud       {I@2} // s0&(s1^s2)
        cmp (16|M0)   (ne)f1.1   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
        bfn.0x28 (16|M0)         r8.0<1>:ud    r54.0<1;0>:ud     r24.0<1;0>:ud     r6.1<0>:ud       // s0&(s1^s2)
(~f1.1) cmp (16|M0)   (ne)f1.1   null<1>:d     r8.0<1;1,0>:d     0:w               {I@1}
(W)     mov (1|M0)               r4.12<1>:hf   -qnan(0x1FF):hf                             
        mov (16|M0)              r58.0<1>:f    r76.0<1;1,0>:f                   {Compacted}
(f1.1)  sel (16|M0)              r10.0<1>:d    r4.12<0;1,0>:w    0:w               {F@2}
        mov (16|M0)              r70.0<1>:d    -r10.0<1;1,0>:d                  {I@1}
L3880:
        join (16|M0)                         L4408                                
L3896:
        and (16|M0)   (ne)f0.1   r126.0<1>:d   r74.0<1;1,0>:d    63:w              
(f0.1)  goto (16|M0)                         L3952                  L3952                
L3928:
        mov (16|M0)              r80.0<1>:f    r48.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L3952                  L4056                
L3952:
        join (16|M0)                         L4056                                
L3968:
        cmp (16|M0)   (lt)f0.0   null<1>:d     r126.0<1;1,0>:ud  0x20:uw              {I@4}
(~f0.0) add (16|M0)              r2.0<1>:d     r126.0<1;1,0>:d   -32:w              
(~f0.0) shr (16|M0)              r80.0<1>:ud   r54.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f0.0)  add (16|M0)              r2.0<1>:d     -r126.0<1;1,0>:d  32:w               {Compacted}
(f0.0)  shr (16|M0)              r8.0<1>:ud    r48.0<1;1,0>:ud   r126.0<1;1,0>:d 
(f0.0)  shl (16|M0)              r2.0<1>:d     r54.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f0.0)  or (16|M0)               r80.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
L4056:
        join (16|M0)                         L4408                                
L4072:
        shl (16|M0)              r2.0<1>:d     r58.0<1;1,0>:d    2:w               {Compacted}
        shl (16|M0)              r8.0<1>:d     r100.0<1;1,0>:d   1:w               {Compacted}
        and (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     4:w               {Compacted,I@2}
        bfn.0xFE (16|M0)         r54.0<1>:ud   r2.0<1;0>:ud      r8.0<1;0>:ud      r70.0<1>:ud      {I@1} // s0|s1|s2
        cmp (16|M0)   (eq)f1.1   null<1>:d     r54.0<1;1,0>:d    0:w               {I@1}
(~f1.1) goto (16|M0)                         L4176                  L4176                
L4144:
        mov (16|M0)              r64.0<1>:d    0:w                              
        goto (16|M0)                         L4176                  L4336                
L4176:
        join (16|M0)                         L4336                                
L4192:
        cmp (16|M0)   (gt)f1.0   null<1>:d     r54.0<1;1,0>:ud   0x4:uw             
(~f1.0) goto (16|M0)                         L4256                  L4256                
L4224:
        mov (16|M0)              r64.0<1>:d    1:w                              
        goto (16|M0)                         L4256                  L4336                
L4256:
        join (16|M0)                         L4336                                
L4272:
        and (16|M0)   (ne)f1.0   null<1>:d     r80.0<1;1,0>:d    1:w              
(W)     mov (1|M0)               r2.0<1>:hf    0x1:hf                             
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r54.0<1;1,0>:d    4:w              
(f1.0)  sel (16|M0)              r64.0<1>:d    r2.0<0;1,0>:w     0:w               {F@1}
L4336:
        join (16|M0)                         L4408                                
L4352:
        add (16|M0)              r2.0<1>:d     r64.0<1;1,0>:d    r80.0<1;1,0>:d   {Compacted,I@2}
        cmp (16|M0)   (gt)f1.1   null<1>:d     r2.0<1;1,0>:ud    0x7FFFFF:ud              {I@1}
(W)     mov (1|M0)               r4.6<1>:f     0x800000:f                               {Compacted}
(~f1.1) sel (16|M0)              r116.0<1>:d   r2.0<1;1,0>:d     0:w              
(f1.1)  sel (16|M0)              r114.0<1>:d   r4.6<0;1,0>:d     0:w               {Compacted,F@1}
L4408:
        join (16|M0)                         L4472                                
L4424:
        and (16|M0)              r2.0<1>:d     r38.0<1;1,0>:d    -2147483648:d              
        bfn.0xFE (16|M0)         r34.0<1>:ud   r2.0<1;0>:ud      r114.0<1;0>:ud    r116.0<1>:ud     {I@1} // s0|s1|s2
        goto (16|M0)                         L4472                  L7472                
L4472:
        join (16|M0)                         L4976                                
L4488:
        and (16|M0)   (ne)f0.1   r84.0<1>:d    r68.0<1;1,0>:d    63:w              
(f0.1)  goto (16|M0)                         L4568                  L4568                
L4520:
        mov (16|M0)              r96.0<1>:d    -1:w                              
        mov (16|M0)              r108.0<1>:d   -1:w                              
        goto (16|M0)                         L4568                  L4752                
L4568:
        join (16|M0)                         L4752                                
L4584:
        cmp (16|M0)   (lt)f0.0   null<1>:d     r84.0<1;1,0>:ud   0x20:uw              {I@6}
(f0.0)  goto (16|M0)                         L4688                  L4688                
L4616:
        add (16|M0)              r2.0<1>:d     r84.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r4.12<1>:hf   -qnan(0x1FF):hf                             
        mov (16|M0)              r96.0<1>:d    0:w                              
        shl (16|M0)              r108.0<1>:d   r4.12<0;1,0>:w    r2.0<1;1,0>:d    {A@1}
        goto (16|M0)                         L4688                  L4752                
L4688:
        join (16|M0)                         L4752                                
L4704:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (16|M0)              r108.0<1>:d   -1:w                              
        shl (16|M0)              r96.0<1>:d    r2.0<0;1,0>:w     r84.0<1;1,0>:d   {F@1}
L4752:
        join (16|M0)                         L4976                                
L4768:
        bfn.0x28 (16|M0)         r2.0<1>:ud    r48.0<1;0>:ud     r96.0<1;0>:ud     r6.1<0>:ud       {I@2} // s0&(s1^s2)
        cmp (16|M0)   (ne)f1.0   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
        bfn.0x28 (16|M0)         r8.0<1>:ud    r54.0<1;0>:ud     r108.0<1;0>:ud    r6.1<0>:ud       // s0&(s1^s2)
        cmp (16|M0)   (gt)f1.1   null<1>:d     r38.0<1;1,0>:d    -1:w              
(~f1.0) cmp (16|M0)   (ne)f1.0   null<1>:d     r8.0<1;1,0>:d     0:w               {I@2}
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r58.0<1;1,0>:d    -150:w              
(f1.1)  goto (16|M0)                         L4920                  L4920                
L4880:
(W)     mov (1|M0)               r2.0<1>:ud    0x80000001:ud                             
(f1.0)  sel (16|M0)              r34.0<1>:f    r2.0<0;1,0>:f     -0.0:f               {Compacted,I@1}
        goto (16|M0)                         L4920                  L7472                
L4920:
        join (16|M0)                         L4976                                
L4936:
(W)     mov (1|M0)               r2.0<1>:ud    0x1:ud                              {F@1}
(f1.0)  sel (16|M0)              r34.0<1>:f    r2.0<0;1,0>:f     0.0:f               {Compacted,I@1}
        goto (16|M0)                         L4976                  L7472                
L4976:
        join (16|M0)                         L7256                                
L4992:
        cmp (16|M0)   (lt)f0.1   null<1>:d     r68.0<1;1,0>:ud   0x18:uw             
        add3 (16|M0)             r90.0<1>:d    r60.0<1;0>:d      r68.0<1;0>:d      81:w              
(f0.1)  cmp (16|M0)   (eq)f0.1   null<1>:d     r62.0<1;1,0>:d    0:w              
(f0.1)  goto (16|M0)                         L6944                  L6944                
L5056:
        shl (16|M0)              r2.0<1>:d     r88.0<1;1,0>:d    1:w               {Compacted,F@1}
        shr (16|M0)              r8.0<1>:ud    r88.0<1;1,0>:ud   31:w              
        shl (16|M0)              r10.0<1>:d    r116.0<1;1,0>:d   1:w               {Compacted}
        cmp (16|M0)   (lt)f0.0   null<1>:d     r2.0<1;1,0>:ud    0x4E:uw              {I@3}
        or (16|M0)               r10.0<1>:d    r10.0<1;1,0>:d    r8.0<1;1,0>:d    {Compacted,I@2}
(f0.0)  cmp (16|M0)   (eq)f0.0   null<1>:d     r10.0<1;1,0>:d    0:w               {I@1}
(~f0.0) cmp (16|M0)   (lt)f0.0   null<1>:d     r10.0<1;1,0>:d    0:w              
(f0.0)  goto (16|M0)                         L5280                  L5280                
L5160:
        cmp (16|M0)   (eq)f0.0   null<1>:d     r88.0<1;1,0>:d    39:w               {Compacted}
(f0.0)  cmp (16|M0)   (eq)f0.0   null<1>:d     r116.0<1;1,0>:d   0:w              
(~f0.0) goto (16|M0)                         L5280                  L5344                
L5200:
        shr (16|M0)              r80.0<1>:ud   r48.0<1;1,0>:ud   1:w              
        mov (16|M0)              r92.0<1>:d    0:w                              
        mov (16|M0)              r106.0<1>:d   0:w                              
        mov (16|M0)              r52.0<1>:f    r80.0<1;1,0>:f                   {Compacted,I@3}
        mov (16|M0)              r80.0<1>:f    r48.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L5280                  L6424                
L5280:
        join (16|M0)                         L5344                                
L5296:
        cmp (16|M0)   (eq)f1.1   null<1>:d     r88.0<1;1,0>:d    38:w              
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r116.0<1;1,0>:d   0:w              
(f1.1)  goto (16|M0)                         L5344                  L6344                
L5344:
        join (16|M0)                         L6344                                
L5360:
        add (16|M0)              r2.0<1>:d     -r88.0<1;1,0>:d   39:w               {Compacted}
        and (16|M0)   (ne)f1.0   r22.0<1>:d    r2.0<1;1,0>:d     63:w               {I@1}
        add (16|M0)              r102.0<1>:d   -r88.0<1;1,0>:d   40:w               {Compacted}
(f1.0)  goto (16|M0)                         L5432                  L5432                
L5408:
        mov (16|M0)              r84.0<1>:f    r48.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L5432                  L5544                
L5432:
        join (16|M0)                         L5544                                
L5448:
        cmp (16|M0)   (lt)f0.1   null<1>:d     r22.0<1;1,0>:ud   0x20:uw              {I@5}
(~f0.1) add (16|M0)              r2.0<1>:d     r22.0<1;1,0>:d    -32:w              
(~f0.1) shr (16|M0)              r80.0<1>:ud   r54.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f0.1)  add (16|M0)              r2.0<1>:d     -r22.0<1;1,0>:d   32:w               {Compacted}
(f0.1)  shr (16|M0)              r8.0<1>:ud    r48.0<1;1,0>:ud   r22.0<1;1,0>:d  
(f0.1)  shl (16|M0)              r2.0<1>:d     r54.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f0.1)  or (16|M0)               r80.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
        mov (16|M0)              r84.0<1>:f    r80.0<1;1,0>:f                   {Compacted,I@1}
L5544:
        join (16|M0)                         L6344                                
L5560:
        add (16|M0)              r42.0<1>:d    -r88.0<1;1,0>:d   38:w               {Compacted}
        and (16|M0)   (ne)f0.0   r28.0<1>:d    r42.0<1;1,0>:d    63:w               {Compacted,I@1}
(f0.0)  goto (16|M0)                         L5616                  L5616                
L5592:
        mov (16|M0)              r80.0<1>:f    r48.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L5616                  L5720                
L5616:
        join (16|M0)                         L5720                                
L5632:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r28.0<1;1,0>:ud   0x20:uw              {I@4}
(~f1.1) add (16|M0)              r2.0<1>:d     r28.0<1;1,0>:d    -32:w              
(~f1.1) shr (16|M0)              r80.0<1>:ud   r54.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.1)  add (16|M0)              r2.0<1>:d     -r28.0<1;1,0>:d   32:w               {Compacted}
(f1.1)  shr (16|M0)              r8.0<1>:ud    r48.0<1;1,0>:ud   r28.0<1;1,0>:d  
(f1.1)  shl (16|M0)              r2.0<1>:d     r54.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.1)  or (16|M0)               r80.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
L5720:
        join (16|M0)                         L6344                                
L5736:
        and (16|M0)   (ne)f1.0   r30.0<1>:d    r42.0<1;1,0>:d    63:w              
        and (16|M0)              r106.0<1>:d   r80.0<1;1,0>:d    1:w               {Compacted,I@3}
(f1.0)  goto (16|M0)                         L5824                  L5824                
L5776:
        mov (16|M0)              r44.0<1>:d    -1:w                              
        mov (16|M0)              r56.0<1>:d    -1:w                              
        goto (16|M0)                         L5824                  L6008                
L5824:
        join (16|M0)                         L6008                                
L5840:
        cmp (16|M0)   (lt)f0.1   null<1>:d     r30.0<1;1,0>:ud   0x20:uw              {I@7}
(f0.1)  goto (16|M0)                         L5944                  L5944                
L5872:
        add (16|M0)              r2.0<1>:d     r30.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r4.12<1>:hf   -qnan(0x1FF):hf                             
        mov (16|M0)              r44.0<1>:d    0:w                              
        shl (16|M0)              r56.0<1>:d    r4.12<0;1,0>:w    r2.0<1;1,0>:d    {A@1}
        goto (16|M0)                         L5944                  L6008                
L5944:
        join (16|M0)                         L6008                                
L5960:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (16|M0)              r56.0<1>:d    -1:w                              
        shl (16|M0)              r44.0<1>:d    r2.0<0;1,0>:w     r30.0<1;1,0>:d   {F@1}
L6008:
        join (16|M0)                         L6344                                
L6024:
        bfn.0x28 (16|M0)         r2.0<1>:ud    r48.0<1;0>:ud     r44.0<1;0>:ud     r6.1<0>:ud       {I@2} // s0&(s1^s2)
        cmp (16|M0)   (ne)f1.0   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
        bfn.0x28 (16|M0)         r8.0<1>:ud    r54.0<1;0>:ud     r56.0<1;0>:ud     r6.1<0>:ud       // s0&(s1^s2)
(~f1.0) cmp (16|M0)   (ne)f1.0   null<1>:d     r8.0<1;1,0>:d     0:w               {I@1}
(W)     mov (1|M0)               r4.12<1>:hf   -qnan(0x1FF):hf                             
        and (16|M0)   (ne)f0.0   r26.0<1>:d    r102.0<1;1,0>:d   63:w               {Compacted}
(f1.0)  sel (16|M0)              r10.0<1>:d    r4.12<0;1,0>:w    0:w               {F@1}
        mov (16|M0)              r92.0<1>:d    -r10.0<1;1,0>:d                  {I@1}
(f0.0)  goto (16|M0)                         L6184                  L6184                
L6160:
        mov (16|M0)              r80.0<1>:f    r48.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L6184                  L6288                
L6184:
        join (16|M0)                         L6288                                
L6200:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r26.0<1;1,0>:ud   0x20:uw             
(~f1.1) add (16|M0)              r2.0<1>:d     r26.0<1;1,0>:d    -32:w              
(~f1.1) shr (16|M0)              r80.0<1>:ud   r54.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.1)  add (16|M0)              r2.0<1>:d     -r26.0<1;1,0>:d   32:w               {Compacted}
(f1.1)  shr (16|M0)              r8.0<1>:ud    r48.0<1;1,0>:ud   r26.0<1;1,0>:d  
(f1.1)  shl (16|M0)              r2.0<1>:d     r54.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.1)  or (16|M0)               r80.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
L6288:
        join (16|M0)                         L6344                                
L6304:
        mov (16|M0)              r52.0<1>:f    r80.0<1;1,0>:f                   {Compacted,I@2}
        mov (16|M0)              r80.0<1>:d    r84.0<1;1,0>:d                   {F@1}
        goto (16|M0)                         L6344                  L6424                
L6344:
        join (16|M0)                         L6424                                
L6360:
        shr (16|M0)              r80.0<1>:ud   r48.0<1;1,0>:ud   2:w              
        and (16|M0)              r106.0<1>:d   r48.0<1;1,0>:d    1:w               {Compacted}
        mov (16|M0)              r92.0<1>:d    0:w                              
        mov (16|M0)              r52.0<1>:f    r80.0<1;1,0>:f                   {Compacted,I@3}
        shr (16|M0)              r80.0<1>:ud   r48.0<1;1,0>:ud   1:w               {F@1}
L6424:
        join (16|M0)                         L6944                                
L6440:
        shl (16|M0)              r2.0<1>:d     r80.0<1;1,0>:d    2:w               {Compacted,I@2}
        shl (16|M0)              r8.0<1>:d     r106.0<1;1,0>:d   1:w               {Compacted}
        and (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     4:w               {Compacted,I@2}
        bfn.0xFE (16|M0)         r94.0<1>:ud   r2.0<1;0>:ud      r8.0<1;0>:ud      r92.0<1>:ud      {I@1} // s0|s1|s2
        cmp (16|M0)   (eq)f1.0   null<1>:d     r94.0<1;1,0>:d    0:w               {I@1}
        and (16|M0)              r96.0<1>:d    r52.0<1;1,0>:d    8388607:d              
(~f1.0) goto (16|M0)                         L6560                  L6560                
L6528:
        mov (16|M0)              r82.0<1>:d    0:w                              
        goto (16|M0)                         L6560                  L6720                
L6560:
        join (16|M0)                         L6720                                
L6576:
        cmp (16|M0)   (gt)f0.1   null<1>:d     r94.0<1;1,0>:ud   0x4:uw             
(~f0.1) goto (16|M0)                         L6640                  L6640                
L6608:
        mov (16|M0)              r82.0<1>:d    1:w                              
        goto (16|M0)                         L6640                  L6720                
L6640:
        join (16|M0)                         L6720                                
L6656:
        and (16|M0)   (ne)f0.1   null<1>:d     r52.0<1;1,0>:d    1:w              
(W)     mov (1|M0)               r2.0<1>:hf    0x1:hf                             
(f0.1)  cmp (16|M0)   (eq)f0.1   null<1>:d     r94.0<1;1,0>:d    4:w              
(f0.1)  sel (16|M0)              r82.0<1>:d    r2.0<0;1,0>:w     0:w               {F@1}
L6720:
        join (16|M0)                         L6944                                
L6736:
        add (16|M0)              r14.0<1>:d    r96.0<1;1,0>:d    r82.0<1;1,0>:d   {Compacted,I@2}
        cmp (16|M0)   (gt)f1.1   null<1>:d     r14.0<1;1,0>:ud   0x7FFFFF:ud              {I@1}
        add3 (16|M0)             r2.0<1>:d     r60.0<1;0>:d      r68.0<1;0>:d      82:w              
(f1.1)  sel (16|M0)              r124.0<1>:d   r2.0<1;1,0>:d     r90.0<1;1,0>:d   {Compacted,I@1}
        cmp (16|M0)   (eq)f0.0   null<1>:d     r124.0<1;1,0>:d   255:w               {Compacted,I@1}
(f0.0)  goto (16|M0)                         L6880                  L6880                
L6808:
(~f1.1) sel (16|M0)              r2.0<1>:d     r14.0<1;1,0>:d    0:w              
        and (16|M0)              r8.0<1>:d     r38.0<1;1,0>:d    -2147483648:d              
        shl (16|M0)              r10.0<1>:d    r124.0<1;1,0>:d   23:w               {Compacted}
        bfn.0xFE (16|M0)         r34.0<1>:ud   r8.0<1;0>:ud      r10.0<1;0>:ud     r2.0<1>:ud       {I@1} // s0|s1|s2
        goto (16|M0)                         L6880                  L7472                
L6880:
        join (16|M0)                         L6944                                
L6896:
        cmp (16|M0)   (gt)f0.1   null<1>:d     r38.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r2.0<1>:f     inf:f                               {Compacted,I@4}
(f0.1)  sel (16|M0)              r34.0<1>:f    r2.0<0;1,0>:f     -inf:f               {Compacted,F@1}
        goto (16|M0)                         L6944                  L7472                
L6944:
        join (16|M0)                         L7256                                
L6960:
        and (16|M0)   (ne)f1.1   r112.0<1>:d   r68.0<1;1,0>:d    63:w              
(f1.1)  goto (16|M0)                         L7024                  L7024                
L6992:
        mov (16|M0)              r72.0<1>:d    -1:w                              
        goto (16|M0)                         L7024                  L7152                
L7024:
        join (16|M0)                         L7152                                
L7040:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r112.0<1;1,0>:ud  0x20:uw              {I@5}
(f1.0)  goto (16|M0)                         L7104                  L7104                
L7072:
        mov (16|M0)              r72.0<1>:d    0:w                              
        goto (16|M0)                         L7104                  L7152                
L7104:
        join (16|M0)                         L7152                                
L7120:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                             
        shl (16|M0)              r72.0<1>:d    r2.0<0;1,0>:w     r112.0<1;1,0>:d  {F@1}
L7152:
        join (16|M0)                         L7256                                
L7168:
        bfn.0x28 (16|M0)         r2.0<1>:ud    r48.0<1;0>:ud     r72.0<1;0>:ud     r6.1<0>:ud       {I@2} // s0&(s1^s2)
        add (16|M0)              r8.0<1>:d     -r68.0<1;1,0>:d   23:w               {Compacted}
        and (16|M0)              r10.0<1>:d    r38.0<1;1,0>:d    -2147483648:d              
        shl (16|M0)              r12.0<1>:d    r90.0<1;1,0>:d    23:w               {Compacted}
        shl (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     r8.0<1;1,0>:d    {Compacted,I@3}
        bfn.0xFE (16|M0)         r34.0<1>:ud   r10.0<1;0>:ud     r12.0<1;0>:ud     r2.0<1>:ud       {I@1} // s0|s1|s2
        goto (16|M0)                         L7256                  L7472                
L7256:
        join (16|M0)                         L7312                                
L7272:
        cmp (16|M0)   (gt)f0.0   null<1>:d     r38.0<1;1,0>:d    -1:w               {Compacted}
(W)     mov (1|M0)               r2.0<1>:f     inf:f                               {Compacted,I@4}
(f0.0)  sel (16|M0)              r34.0<1>:f    r2.0<0;1,0>:f     -inf:f               {Compacted,F@1}
        goto (16|M0)                         L7312                  L7472                
L7312:
        join (16|M0)                         L7376                                
L7328:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r38.0<1;1,0>:d    0:w              
(W)     mov (1|M0)               r2.0<1>:f     -0.0:f                               {Compacted}
(f1.1)  sel (16|M0)              r34.0<1>:f    r2.0<0;1,0>:f     0.0:f               {Compacted,F@1}
        goto (16|M0)                         L7376                  L7472                
L7376:
        join (16|M0)                         L7440                                
L7392:
        cmp (16|M0)   (gt)f1.0   null<1>:d     r38.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r2.0<1>:f     inf:f                               {Compacted}
(f1.0)  sel (16|M0)              r34.0<1>:f    r2.0<0;1,0>:f     -inf:f               {Compacted,F@1}
        goto (16|M0)                         L7440                  L7472                
L7440:
        join (16|M0)                         L7472                                
L7456:
        bfn.0xF8 (16|M0)         r34.0<1>:ud   r38.0<1;0>:ud     r6.5<0;0>:ud      r6.4<0>:ud       {F@1} // s0&s1|s2
L7472:
        join (16|M0)                         L7488                                
L7488:
        mov (8|M0)               r2.0<1>:hf    r34.0<1;1,0>:f                   {I@2}
        mov (8|M8)               r2.8<1>:hf    r35.0<1;1,0>:f                  
        mov (8|M0)               r8.0<1>:f     r2.0<1;1,0>:hf                   {F@2}
        mov (8|M8)               r9.0<1>:f     r2.8<1;1,0>:hf                   {F@2}
        and (16|M0)              r10.0<1>:d    r8.0<1;1,0>:d     2147483647:d               {A@1}
        sel (16|M0)   (lt)f0.0   r106.0<1>:f   r10.0<1;1,0>:f    448.0:f               {Compacted,I@1}
        shr (16|M0)              r28.0<1>:ud   r106.0<1;1,0>:ud  23:w               {F@1}
        and (16|M0)   (ne)f0.0   r54.0<1>:d    r106.0<1;1,0>:d   8388607:d              
        and (16|M0)              r92.0<1>:d    r28.0<1;1,0>:d    255:w               {Compacted,I@2}
(f0.0)  cmp (16|M0)   (eq)f0.0   null<1>:d     r92.0<1;1,0>:d    255:w               {I@1}
        sel (16|M0)   (ge)f0.0   r12.0<1>:ud   r92.0<1;1,0>:ud   0x79:uw             
        shl (16|M0)              r40.0<1>:d    r12.0<1;1,0>:d    23:w               {Compacted,I@1}
(~f0.0) goto (16|M0)                         L7704                  L7704                
L7672:
        mov (16|M0)              r86.0<1>:ud   0x7FC00000:ud                             
        goto (16|M0)                         L7704                  L13600                
L7704:
        join (16|M0)                         L13600                                
L7720:
        cmp (16|M0)   (eq)f1.1   null<1>:d     r54.0<1;1,0>:d    0:w              
        add (16|M0)              r12.0<1>:d    -r40.0<1;1,0>:d   -2139095040:d               {I@6}
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r92.0<1;1,0>:d    255:w              
        xor (16|M0)              r44.0<1>:d    r12.0<1;1,0>:d    r106.0<1;1,0>:d  {Compacted,I@2}
(f1.1)  goto (16|M0)                         L13568                  L13568                
L7792:
        or (16|M0)    (eq)f0.1   null<1>:d     r92.0<1;1,0>:d    r54.0<1;1,0>:d  
(~f0.1) goto (16|M0)                         L7856                  L7856                
L7824:
        mov (16|M0)              r86.0<1>:ud   0x0:ud                             
        goto (16|M0)                         L7856                  L13600                
L7856:
        join (16|M0)                         L13568                                
L7872:
        cmp (16|M0)   (eq)f0.1   null<1>:d     r92.0<1;1,0>:d    0:w              
        shr (16|M0)              r110.0<1>:ud  r12.0<1;1,0>:ud   23:w              
        add (16|M0)              r118.0<1>:d   r92.0<1;1,0>:d    -127:w               {Compacted}
(f0.1)  mov (16|M0)              r118.0<1>:d   -126:w                              
        add (16|M0)              r62.0<1>:d    r110.0<1;1,0>:d   r118.0<1;1,0>:d  {Compacted,I@1}
        cmp (16|M0)   (gt)f0.0   null<1>:d     r62.0<1;1,0>:d    254:w               {Compacted,I@1}
(f0.0)  goto (16|M0)                         L13504                  L13504                
L7960:
        or (16|M0)    (eq)f1.1   null<4>:b     r28.0<1;1,0>:d    r110.0<1;1,0>:d 
(f1.1)  goto (16|M0)                         L13440                  L13440                
L7992:
(W)     mov (1|M0)               r2.0<1>:hf    0.0:hf                             
(W)     mov (1|M0)               r5.4<1>:d     0:w                              
(f0.1)  sel (16|M0)              r8.0<1>:d     r2.0<0;1,0>:w     8388608:d               {F@1}
        or (16|M0)               r8.0<1>:d     r8.0<1;1,0>:d     r54.0<1;1,0>:d   {Compacted,I@1}
        shl (16|M0)              r50.0<1>:d    r8.0<1;1,0>:d     23:w               {Compacted,I@1}
        shr (16|M0)              r56.0<1>:ud   r8.0<1;1,0>:ud    9:w              
(W)     mov (1|M0)               r5.3<1>:f     -0.0:f                               {Compacted}
(W)     mov (2|M0)               r5.0<1>:d     0:w                              
L8096:
(W)     shl (1|M0)               r2.0<1>:d     r5.3<0;1,0>:d     31:w               {Compacted,F@1}
(W)     shr (1|M0)               r2.1<1>:ud    r5.4<0;1,0>:ud    1:w              
(W)     cmp (16|M0)   (gt)f1.1   null<1>:d     r5.0<0;1,0>:ud    0x3E:uw              {I@3}
(W)     or (1|M0)                r5.4<1>:d     r2.1<0;1,0>:d     r2.0<0;1,0>:d    {I@2}
        bfn.0xE0 (16|M0)         r8.0<1>:ud    r2.1<0;0>:ud      r2.0<0;0>:ud      r50.0<1>:ud      // (s0|s1)&s2
(W)     shr (1|M0)               r5.2<1>:ud    r5.3<0;1,0>:ud    1:w              
(W&f1.1) cmp (16|M0)  (eq)f1.1   null<1>:d     r5.1<0;1,0>:d     0:w              
        cmp (16|M0)   (eq)f1.0   null<1>:d     r8.0<1;1,0>:d     r5.4<0;1,0>:d    {I@3}
        and (16|M0)              r10.0<1>:d    r5.2<0;1,0>:d     r56.0<1;1,0>:d   {Compacted,I@3}
(W&~f1.1) cmp (16|M0) (gt)f1.1   null<1>:d     r5.1<0;1,0>:ud    0x0:uw             
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r10.0<1;1,0>:d    r5.2<0;1,0>:d    {I@2}
(W)     mov (1|M0)               r4.12<1>:hf   0x1:hf                             
(W)     addc (1|M0)              r13.0<1>:ud   r5.0<0;1,0>:ud    0x1:ud              {AccWrEn}
(f1.1)  sel (16|M0)              r7.0<1>:uw    r4.12<0;1,0>:uw   0x0:uw              {Compacted,F@1}
(f1.0)  sel (16|M0)              acc2.0<1>:uw  r4.12<0;1,0>:uw   0x0:uw             
(W)     mov (1|M0)               r3.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        or (16|M0)    (ne)f0.1   null<1>:uw    r7.0<1;1,0>:uw    acc2.0<1;1,0>:uw {I@3}
(W)     add (1|M0)               r5.5<1>:ud    r3.0<0;1,0>:ud    r5.1<0;1,0>:ud   {I@2}
        mov (16|M0)              r106.0<1>:f   r5.0<0;1,0>:f                    {Compacted}
        mov (16|M0)              r104.0<1>:d   r5.1<0;1,0>:d                   
        mov (16|M0)              r78.0<1>:f    r13.0<0;1,0>:f                   {Compacted}
        mov (16|M0)              r122.0<1>:d   r5.5<0;1,0>:d                    {I@2}
(f0.1)  goto (16|M0)                         L8472                  L8472                
L8416:
(W)     mov (1|M0)               r5.3<1>:d     r5.2<0;1,0>:d                   
(W)     mov (1|M0)               r5.0<1>:f     r13.0<0;1,0>:f                   {Compacted}
(W)     mov (1|M0)               r5.1<1>:d     r5.5<0;1,0>:d                   
(W)     jmpi                                 L8096                                
L8472:
        join (16|M0)                         L13440                                
L8488:
(W)     mov (1|M0)               r2.0<1>:f     8.68805e-44:f                              
(W)     mov (1|M0)               r3.0<1>:hf    0.0:hf                             
        subb (8|M0)              r64.0<1>:ud   r2.0<0;1,0>:ud    r106.0<1;1,0>:ud {AccWrEn,Compacted,F@2}
        add3 (8|M0)              r72.0<1>:ud   -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r104.0<1>:ud    {A@1}
        subb (8|M8)              r65.0<1>:ud   r2.0<0;1,0>:ud    r107.0<1;1,0>:ud {AccWrEn}
        add3 (16|M0)             r66.0<1>:d    r62.0<1;0>:d      r64.0<1;0>:d      -173:w               {I@1}
        cmp (16|M0)   (gt)f1.0   null<1>:d     r66.0<1;1,0>:d    127:w               {I@1}
        add3 (8|M8)              r73.0<1>:ud   -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r105.0<1>:ud   
        add3 (16|M0)             r70.0<1>:d    r110.0<1;0>:d     r118.0<1;0>:d     r64.0<1>:d      
(f1.0)  goto (16|M0)                         L13384                  L13384                
L8640:
        cmp (16|M0)   (gt)f0.1   null<1>:d     r66.0<1;1,0>:d    -127:w              
(f0.1)  goto (16|M0)                         L11080                  L11080                
L8672:
        cmp (16|M0)   (lt)f0.0   null<1>:d     r66.0<1;1,0>:ud   0xFFFFFF6B:ud             
(f0.0)  goto (16|M0)                         L10584                  L10584                
L8704:
(W)     mov (1|M0)               r2.0<1>:f     8.82818e-44:f                              
(W)     mov (1|M0)               r3.0<1>:hf    0.0:hf                              {I@7}
        subb (8|M0)              r112.0<1>:ud  r2.0<0;1,0>:ud    r106.0<1;1,0>:ud {AccWrEn,Compacted,F@2}
        add3 (16|M0)             r90.0<1>:d    r62.0<1;0>:d      r64.0<1;0>:d      -23:w              
        add3 (8|M0)              r8.0<1>:ud    -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r104.0<1>:ud    {F@1}
        subb (8|M8)              r113.0<1>:ud  r2.0<0;1,0>:ud    r107.0<1;1,0>:ud {AccWrEn}
        cmp (16|M0)   (gt)f1.1   null<1>:d     r112.0<1;1,0>:ud  r90.0<1;1,0>:ud  {I@1}
        add3 (8|M8)              r9.0<1>:ud    -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r105.0<1>:ud   
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r8.0<1;1,0>:d     0:w               {I@1}
(~f1.1) cmp (16|M0)   (gt)f1.1   null<1>:d     r8.0<1;1,0>:ud    0x0:uw             
(f1.1)  goto (16|M0)                         L8928                  L8928                
L8872:
        add3 (16|M0)             r2.0<1>:d     r70.0<1;0>:d      -r112.0<1;0>:d    -23:w              
        mov (16|M0)              r8.0<1>:d     0:w                              
        shl (16|M0)              r10.0<1>:d    r50.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
        goto (16|M0)                         L8928                  L10520                
L8928:
        join (16|M0)                         L10520                                
L8944:
        add3 (16|M0)             r76.0<1>:d    r112.0<1;0>:d     -r70.0<1;0>:d     23:w              
        cmp (16|M0)   (lt)f1.1   null<1>:d     r76.0<1;1,0>:d    2:w               {I@1}
(f1.1)  goto (16|M0)                         L9096                  L9096                
L8992:
        cmp (16|M0)   (eq)f1.0   null<1>:d     r76.0<1;1,0>:d    2:w              
(~f1.0) goto (16|M0)                         L9096                  L9200                
L9024:
        shr (16|M0)              r82.0<1>:ud   r50.0<1;1,0>:ud   1:w              
        mov (16|M0)              r86.0<1>:d    0:w                              
        mov (16|M0)              r104.0<1>:d   0:w                              
        mov (16|M0)              r78.0<1>:f    r82.0<1;1,0>:f                   {Compacted,I@3}
        goto (16|M0)                         L9096                  L10000                
L9096:
        join (16|M0)                         L9200                                
L9112:
        cmp (16|M0)   (eq)f0.1   null<1>:d     r76.0<1;1,0>:d    1:w              
(~f0.1) goto (16|M0)                         L9200                  L9200                
L9144:
        mov (16|M0)              r86.0<1>:d    0:w                              
        mov (16|M0)              r104.0<1>:d   0:w                              
        mov (16|M0)              r78.0<1>:f    r50.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L9200                  L10000                
L9200:
        join (16|M0)                         L10000                                
L9216:
        add3 (16|M0)             r2.0<1>:d     r112.0<1;0>:d     -r90.0<1;0>:d     -1:w              
        and (16|M0)   (ne)f0.0   r20.0<1>:d    r2.0<1;1,0>:d     63:w               {Compacted,I@1}
(f0.0)  goto (16|M0)                         L9280                  L9280                
L9256:
        mov (16|M0)              r80.0<1>:f    r50.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L9280                  L9392                
L9280:
        join (16|M0)                         L9392                                
L9296:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r20.0<1;1,0>:ud   0x20:uw              {I@4}
(~f1.1) add (16|M0)              r2.0<1>:d     r20.0<1;1,0>:d    -32:w              
(~f1.1) shr (16|M0)              r82.0<1>:ud   r56.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.1)  add (16|M0)              r2.0<1>:d     -r20.0<1;1,0>:d   32:w               {Compacted}
(f1.1)  shr (16|M0)              r8.0<1>:ud    r50.0<1;1,0>:ud   r20.0<1;1,0>:d  
(f1.1)  shl (16|M0)              r2.0<1>:d     r56.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.1)  or (16|M0)               r82.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
        mov (16|M0)              r80.0<1>:f    r82.0<1;1,0>:f                   {Compacted,I@1}
L9392:
        join (16|M0)                         L10000                                
L9408:
        add3 (16|M0)             r38.0<1>:d    r112.0<1;0>:d     -r90.0<1;0>:d     -2:w              
        and (16|M0)   (ne)f1.0   r18.0<1>:d    r38.0<1;1,0>:d    63:w               {I@1}
(f1.0)  goto (16|M0)                         L9480                  L9480                
L9456:
        mov (16|M0)              r82.0<1>:f    r50.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L9480                  L9584                
L9480:
        join (16|M0)                         L9584                                
L9496:
        cmp (16|M0)   (lt)f0.1   null<1>:d     r18.0<1;1,0>:ud   0x20:uw              {I@4}
(~f0.1) add (16|M0)              r2.0<1>:d     r18.0<1;1,0>:d    -32:w              
(~f0.1) shr (16|M0)              r82.0<1>:ud   r56.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f0.1)  add (16|M0)              r2.0<1>:d     -r18.0<1;1,0>:d   32:w               {Compacted}
(f0.1)  shr (16|M0)              r8.0<1>:ud    r50.0<1;1,0>:ud   r18.0<1;1,0>:d  
(f0.1)  shl (16|M0)              r2.0<1>:d     r56.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f0.1)  or (16|M0)               r82.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
L9584:
        join (16|M0)                         L10000                                
L9600:
        and (16|M0)   (ne)f0.0   r22.0<1>:d    r38.0<1;1,0>:d    63:w               {Compacted}
        and (16|M0)              r104.0<1>:d   r82.0<1;1,0>:d    1:w               {Compacted,I@3}
(f0.0)  goto (16|M0)                         L9680                  L9680                
L9632:
        mov (16|M0)              r28.0<1>:d    -1:w                              
        mov (16|M0)              r42.0<1>:d    -1:w                              
        goto (16|M0)                         L9680                  L9864                
L9680:
        join (16|M0)                         L9864                                
L9696:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r22.0<1;1,0>:ud   0x20:uw              {I@7}
(f1.1)  goto (16|M0)                         L9800                  L9800                
L9728:
        add (16|M0)              r2.0<1>:d     r22.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r4.12<1>:hf   -qnan(0x1FF):hf                             
        mov (16|M0)              r28.0<1>:d    0:w                              
        shl (16|M0)              r42.0<1>:d    r4.12<0;1,0>:w    r2.0<1;1,0>:d    {A@1}
        goto (16|M0)                         L9800                  L9864                
L9800:
        join (16|M0)                         L9864                                
L9816:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (16|M0)              r42.0<1>:d    -1:w                              
        shl (16|M0)              r28.0<1>:d    r2.0<0;1,0>:w     r22.0<1;1,0>:d   {F@1}
L9864:
        join (16|M0)                         L10000                                
L9880:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r28.0<1;0>:ud     r6.1<0;0>:ud      r50.0<1>:ud      {I@2} // (s0^s1)&s2
        cmp (16|M0)   (ne)f1.0   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
        bfn.0x60 (16|M0)         r8.0<1>:ud    r42.0<1;0>:ud     r6.1<0;0>:ud      r56.0<1>:ud      // (s0^s1)&s2
(~f1.0) cmp (16|M0)   (ne)f1.0   null<1>:d     r8.0<1;1,0>:d     0:w               {I@1}
(W)     mov (1|M0)               r4.12<1>:hf   -qnan(0x1FF):hf                             
        mov (16|M0)              r78.0<1>:f    r80.0<1;1,0>:f                   {Compacted}
(f1.0)  sel (16|M0)              r10.0<1>:d    r4.12<0;1,0>:w    0:w               {F@2}
        mov (16|M0)              r86.0<1>:d    -r10.0<1;1,0>:d                  {I@1}
L10000:
        join (16|M0)                         L10520                                
L10016:
        and (16|M0)   (ne)f1.0   r16.0<1>:d    r76.0<1;1,0>:d    63:w              
(f1.0)  goto (16|M0)                         L10072                  L10072                
L10048:
        mov (16|M0)              r82.0<1>:f    r50.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L10072                  L10176                
L10072:
        join (16|M0)                         L10176                                
L10088:
        cmp (16|M0)   (lt)f0.1   null<1>:d     r16.0<1;1,0>:ud   0x20:uw              {I@4}
(~f0.1) add (16|M0)              r2.0<1>:d     r16.0<1;1,0>:d    -32:w              
(~f0.1) shr (16|M0)              r82.0<1>:ud   r56.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f0.1)  add (16|M0)              r2.0<1>:d     -r16.0<1;1,0>:d   32:w               {Compacted}
(f0.1)  shr (16|M0)              r8.0<1>:ud    r50.0<1;1,0>:ud   r16.0<1;1,0>:d  
(f0.1)  shl (16|M0)              r2.0<1>:d     r56.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f0.1)  or (16|M0)               r82.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
L10176:
        join (16|M0)                         L10520                                
L10192:
        shl (16|M0)              r2.0<1>:d     r78.0<1;1,0>:d    2:w               {Compacted}
        shl (16|M0)              r8.0<1>:d     r104.0<1;1,0>:d   1:w               {Compacted}
        and (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     4:w               {Compacted,I@2}
        bfn.0xFE (16|M0)         r70.0<1>:ud   r2.0<1;0>:ud      r8.0<1;0>:ud      r86.0<1>:ud      {I@1} // s0|s1|s2
        cmp (16|M0)   (eq)f0.0   null<1>:d     r70.0<1;1,0>:d    0:w               {Compacted,I@1}
(~f0.0) goto (16|M0)                         L10288                  L10288                
L10256:
        mov (16|M0)              r80.0<1>:d    0:w                              
        goto (16|M0)                         L10288                  L10448                
L10288:
        join (16|M0)                         L10448                                
L10304:
        cmp (16|M0)   (gt)f1.1   null<1>:d     r70.0<1;1,0>:ud   0x4:uw             
(~f1.1) goto (16|M0)                         L10368                  L10368                
L10336:
        mov (16|M0)              r80.0<1>:d    1:w                              
        goto (16|M0)                         L10368                  L10448                
L10368:
        join (16|M0)                         L10448                                
L10384:
        and (16|M0)   (ne)f0.1   null<1>:d     r82.0<1;1,0>:d    1:w              
(W)     mov (1|M0)               r2.0<1>:hf    0x1:hf                             
(f0.1)  cmp (16|M0)   (eq)f0.1   null<1>:d     r70.0<1;1,0>:d    4:w              
(f0.1)  sel (16|M0)              r80.0<1>:d    r2.0<0;1,0>:w     0:w               {F@1}
L10448:
        join (16|M0)                         L10520                                
L10464:
        add (16|M0)              r2.0<1>:d     r80.0<1;1,0>:d    r82.0<1;1,0>:d   {Compacted,I@2}
        cmp (16|M0)   (gt)f1.0   null<1>:d     r2.0<1;1,0>:ud    0x7FFFFF:ud              {I@1}
(W)     mov (1|M0)               r4.6<1>:f     0x800000:f                               {Compacted}
(~f1.0) sel (16|M0)              r10.0<1>:d    r2.0<1;1,0>:d     0:w              
(f1.0)  sel (16|M0)              r8.0<1>:d     r4.6<0;1,0>:d     0:w               {Compacted,F@1}
L10520:
        join (16|M0)                         L10584                                
L10536:
        and (16|M0)              r2.0<1>:d     r44.0<1;1,0>:d    -2147483648:d              
        bfn.0xFE (16|M0)         r86.0<1>:ud   r2.0<1;0>:ud      r8.0<1;0>:ud      r10.0<1>:ud      {I@1} // s0|s1|s2
        goto (16|M0)                         L10584                  L13600                
L10584:
        join (16|M0)                         L11080                                
L10600:
        and (16|M0)   (ne)f1.0   r104.0<1>:d   r64.0<1;1,0>:d    63:w              
(f1.0)  goto (16|M0)                         L10680                  L10680                
L10632:
        mov (16|M0)              r8.0<1>:d     -1:w                              
        mov (16|M0)              r20.0<1>:d    -1:w                              
        goto (16|M0)                         L10680                  L10864                
L10680:
        join (16|M0)                         L10864                                
L10696:
        cmp (16|M0)   (lt)f0.1   null<1>:d     r104.0<1;1,0>:ud  0x20:uw              {I@6}
(f0.1)  goto (16|M0)                         L10800                  L10800                
L10728:
        add (16|M0)              r2.0<1>:d     r104.0<1;1,0>:d   -32:w               {Compacted}
(W)     mov (1|M0)               r4.12<1>:hf   -qnan(0x1FF):hf                             
        mov (16|M0)              r8.0<1>:d     0:w                              
        shl (16|M0)              r20.0<1>:d    r4.12<0;1,0>:w    r2.0<1;1,0>:d    {A@1}
        goto (16|M0)                         L10800                  L10864                
L10800:
        join (16|M0)                         L10864                                
L10816:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (16|M0)              r20.0<1>:d    -1:w                              
        shl (16|M0)              r8.0<1>:d     r2.0<0;1,0>:w     r104.0<1;1,0>:d  {F@1}
L10864:
        join (16|M0)                         L11080                                
L10880:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r8.0<1;0>:ud      r6.1<0;0>:ud      r50.0<1>:ud      {I@2} // (s0^s1)&s2
        cmp (16|M0)   (ne)f0.1   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
        bfn.0x60 (16|M0)         r8.0<1>:ud    r20.0<1;0>:ud     r6.1<0;0>:ud      r56.0<1>:ud      // (s0^s1)&s2
        cmp (16|M0)   (gt)f0.0   null<1>:d     r44.0<1;1,0>:d    -1:w               {Compacted}
(~f0.1) cmp (16|M0)   (ne)f0.1   null<1>:d     r8.0<1;1,0>:d     0:w               {I@2}
(f0.1)  cmp (16|M0)   (eq)f0.1   null<1>:d     r66.0<1;1,0>:d    -150:w              
(f0.0)  goto (16|M0)                         L11024                  L11024                
L10984:
(W)     mov (1|M0)               r2.0<1>:ud    0x80000001:ud                             
(f0.1)  sel (16|M0)              r86.0<1>:f    r2.0<0;1,0>:f     -0.0:f               {Compacted,I@1}
        goto (16|M0)                         L11024                  L13600                
L11024:
        join (16|M0)                         L11080                                
L11040:
(W)     mov (1|M0)               r2.0<1>:ud    0x1:ud                              {F@1}
(f0.1)  sel (16|M0)              r86.0<1>:f    r2.0<0;1,0>:f     0.0:f               {Compacted,I@1}
        goto (16|M0)                         L11080                  L13600                
L11080:
        join (16|M0)                         L13384                                
L11096:
        cmp (16|M0)   (lt)f0.0   null<1>:d     r64.0<1;1,0>:ud   0x18:uw             
        add3 (16|M0)             r74.0<1>:d    r62.0<1;0>:d      r64.0<1;0>:d      -46:w              
(f0.0)  cmp (16|M0)   (eq)f0.0   null<1>:d     r72.0<1;1,0>:d    0:w              
(f0.0)  goto (16|M0)                         L13080                  L13080                
L11160:
        shl (16|M0)              r2.0<1>:d     r78.0<1;1,0>:d    1:w               {Compacted,F@1}
        shr (16|M0)              r8.0<1>:ud    r78.0<1;1,0>:ud   31:w              
        shl (16|M0)              r10.0<1>:d    r122.0<1;1,0>:d   1:w               {Compacted}
        cmp (16|M0)   (lt)f1.0   null<1>:d     r2.0<1;1,0>:ud    0x4E:uw              {I@3}
        or (16|M0)               r10.0<1>:d    r10.0<1;1,0>:d    r8.0<1;1,0>:d    {Compacted,I@2}
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r10.0<1;1,0>:d    0:w               {I@1}
(~f1.0) cmp (16|M0)   (lt)f1.0   null<1>:d     r10.0<1;1,0>:d    0:w              
(f1.0)  goto (16|M0)                         L11392                  L11392                
L11264:
        cmp (16|M0)   (eq)f1.1   null<1>:d     r78.0<1;1,0>:d    39:w              
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r122.0<1;1,0>:d   0:w              
(~f1.1) goto (16|M0)                         L11392                  L11456                
L11312:
        shr (16|M0)              r82.0<1>:ud   r50.0<1;1,0>:ud   1:w              
        mov (16|M0)              r98.0<1>:d    0:w                              
        mov (16|M0)              r108.0<1>:d   0:w                              
        mov (16|M0)              r56.0<1>:f    r82.0<1;1,0>:f                   {Compacted,I@3}
        mov (16|M0)              r82.0<1>:f    r50.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L11392                  L12560                
L11392:
        join (16|M0)                         L11456                                
L11408:
        cmp (16|M0)   (eq)f1.0   null<1>:d     r78.0<1;1,0>:d    38:w              
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r122.0<1;1,0>:d   0:w              
(f1.0)  goto (16|M0)                         L11456                  L12472                
L11456:
        join (16|M0)                         L12472                                
L11472:
        add (16|M0)              r2.0<1>:d     -r78.0<1;1,0>:d   39:w               {Compacted}
        and (16|M0)   (ne)f1.1   r42.0<1>:d    r2.0<1;1,0>:d     63:w               {I@1}
        add (16|M0)              r106.0<1>:d   -r78.0<1;1,0>:d   40:w               {Compacted}
(f1.1)  goto (16|M0)                         L11544                  L11544                
L11520:
        mov (16|M0)              r88.0<1>:f    r50.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L11544                  L11656                
L11544:
        join (16|M0)                         L11656                                
L11560:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r42.0<1;1,0>:ud   0x20:uw              {I@5}
(~f1.0) add (16|M0)              r2.0<1>:d     r42.0<1;1,0>:d    -32:w              
(~f1.0) shr (16|M0)              r82.0<1>:ud   r56.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.0)  add (16|M0)              r2.0<1>:d     -r42.0<1;1,0>:d   32:w               {Compacted}
(f1.0)  shr (16|M0)              r8.0<1>:ud    r50.0<1;1,0>:ud   r42.0<1;1,0>:d  
(f1.0)  shl (16|M0)              r2.0<1>:d     r56.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.0)  or (16|M0)               r82.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
        mov (16|M0)              r88.0<1>:f    r82.0<1;1,0>:f                   {Compacted,I@1}
L11656:
        join (16|M0)                         L12472                                
L11672:
        add (16|M0)              r52.0<1>:d    -r78.0<1;1,0>:d   38:w               {Compacted}
        and (16|M0)   (ne)f0.1   r48.0<1>:d    r52.0<1;1,0>:d    63:w               {I@1}
(f0.1)  goto (16|M0)                         L11736                  L11736                
L11712:
        mov (16|M0)              r82.0<1>:f    r50.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L11736                  L11840                
L11736:
        join (16|M0)                         L11840                                
L11752:
        cmp (16|M0)   (lt)f0.0   null<1>:d     r48.0<1;1,0>:ud   0x20:uw              {I@4}
(~f0.0) add (16|M0)              r2.0<1>:d     r48.0<1;1,0>:d    -32:w              
(~f0.0) shr (16|M0)              r82.0<1>:ud   r56.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f0.0)  add (16|M0)              r2.0<1>:d     -r48.0<1;1,0>:d   32:w               {Compacted}
(f0.0)  shr (16|M0)              r8.0<1>:ud    r50.0<1;1,0>:ud   r48.0<1;1,0>:d  
(f0.0)  shl (16|M0)              r2.0<1>:d     r56.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f0.0)  or (16|M0)               r82.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
L11840:
        join (16|M0)                         L12472                                
L11856:
        and (16|M0)   (ne)f1.1   r52.0<1>:d    r52.0<1;1,0>:d    63:w              
        and (16|M0)              r108.0<1>:d   r82.0<1;1,0>:d    1:w               {Compacted,I@3}
(f1.1)  goto (16|M0)                         L11944                  L11944                
L11896:
        mov (16|M0)              r68.0<1>:d    -1:w                              
        mov (16|M0)              r76.0<1>:d    -1:w                              
        goto (16|M0)                         L11944                  L12128                
L11944:
        join (16|M0)                         L12128                                
L11960:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r52.0<1;1,0>:ud   0x20:uw              {I@7}
(f1.0)  goto (16|M0)                         L12064                  L12064                
L11992:
        add (16|M0)              r2.0<1>:d     r52.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r4.12<1>:hf   -qnan(0x1FF):hf                             
        mov (16|M0)              r68.0<1>:d    0:w                              
        shl (16|M0)              r76.0<1>:d    r4.12<0;1,0>:w    r2.0<1;1,0>:d    {A@1}
        goto (16|M0)                         L12064                  L12128                
L12064:
        join (16|M0)                         L12128                                
L12080:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (16|M0)              r76.0<1>:d    -1:w                              
        shl (16|M0)              r68.0<1>:d    r2.0<0;1,0>:w     r52.0<1;1,0>:d   {F@1}
L12128:
        join (16|M0)                         L12472                                
L12144:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r68.0<1;0>:ud     r6.1<0;0>:ud      r50.0<1>:ud      {I@2} // (s0^s1)&s2
        cmp (16|M0)   (ne)f0.1   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
        bfn.0x60 (16|M0)         r8.0<1>:ud    r76.0<1;0>:ud     r6.1<0;0>:ud      r56.0<1>:ud      // (s0^s1)&s2
(~f0.1) cmp (16|M0)   (ne)f0.1   null<1>:d     r8.0<1;1,0>:d     0:w               {I@1}
(W)     mov (1|M0)               r4.12<1>:hf   -qnan(0x1FF):hf                             
(f0.1)  sel (16|M0)              r10.0<1>:d    r4.12<0;1,0>:w    0:w               {F@1}
        and (16|M0)   (ne)f0.1   r46.0<1>:d    r106.0<1;1,0>:d   63:w              
        mov (16|M0)              r98.0<1>:d    -r10.0<1;1,0>:d                  {I@2}
(f0.1)  goto (16|M0)                         L12312                  L12312                
L12288:
        mov (16|M0)              r82.0<1>:f    r50.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L12312                  L12416                
L12312:
        join (16|M0)                         L12416                                
L12328:
        cmp (16|M0)   (lt)f0.0   null<1>:d     r46.0<1;1,0>:ud   0x20:uw              {I@5}
(~f0.0) add (16|M0)              r2.0<1>:d     r46.0<1;1,0>:d    -32:w              
(~f0.0) shr (16|M0)              r82.0<1>:ud   r56.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f0.0)  add (16|M0)              r2.0<1>:d     -r46.0<1;1,0>:d   32:w               {Compacted}
(f0.0)  shr (16|M0)              r8.0<1>:ud    r50.0<1;1,0>:ud   r46.0<1;1,0>:d  
(f0.0)  shl (16|M0)              r2.0<1>:d     r56.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f0.0)  or (16|M0)               r82.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
L12416:
        join (16|M0)                         L12472                                
L12432:
        mov (16|M0)              r56.0<1>:f    r82.0<1;1,0>:f                   {Compacted,I@2}
        mov (16|M0)              r82.0<1>:d    r88.0<1;1,0>:d                   {F@1}
        goto (16|M0)                         L12472                  L12560                
L12472:
        join (16|M0)                         L12560                                
L12488:
        shr (16|M0)              r82.0<1>:ud   r50.0<1;1,0>:ud   2:w              
        mov (16|M0)              r98.0<1>:d    0:w                              
        mov (16|M0)              r108.0<1>:d   0:w                              
        mov (16|M0)              r56.0<1>:f    r82.0<1;1,0>:f                   {Compacted,I@3}
        shr (16|M0)              r82.0<1>:ud   r50.0<1;1,0>:ud   1:w               {F@1}
L12560:
        join (16|M0)                         L13080                                
L12576:
        shl (16|M0)              r2.0<1>:d     r82.0<1;1,0>:d    2:w               {Compacted,I@2}
        shl (16|M0)              r8.0<1>:d     r108.0<1;1,0>:d   1:w               {Compacted}
        and (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     4:w               {Compacted,I@2}
        bfn.0xFE (16|M0)         r4.0<1>:ud    r2.0<1;0>:ud      r8.0<1;0>:ud      r98.0<1>:ud      {I@1} // s0|s1|s2
        cmp (16|M0)   (eq)f1.1   null<1>:d     r4.0<1;1,0>:d     0:w               {I@1}
        and (16|M0)              r100.0<1>:d   r56.0<1;1,0>:d    8388607:d              
(~f1.1) goto (16|M0)                         L12696                  L12696                
L12664:
        mov (16|M0)              r102.0<1>:d   0:w                              
        goto (16|M0)                         L12696                  L12848                
L12696:
        join (16|M0)                         L12848                                
L12712:
        cmp (16|M0)   (gt)f1.0   null<1>:d     r4.0<1;1,0>:ud    0x4:uw             
(~f1.0) goto (16|M0)                         L12776                  L12776                
L12744:
        mov (16|M0)              r102.0<1>:d   1:w                              
        goto (16|M0)                         L12776                  L12848                
L12776:
        join (16|M0)                         L12848                                
L12792:
        and (16|M0)   (ne)f0.0   null<1>:d     r56.0<1;1,0>:d    1:w               {Compacted}
(W)     mov (1|M0)               r2.0<1>:hf    0x1:hf                             
(f0.0)  cmp (16|M0)   (eq)f0.0   null<1>:d     r4.0<1;1,0>:d     4:w              
(f0.0)  sel (16|M0)              r102.0<1>:d   r2.0<0;1,0>:w     0:w               {F@1}
L12848:
        join (16|M0)                         L13080                                
L12864:
        add (16|M0)              r20.0<1>:d    r100.0<1;1,0>:d   r102.0<1;1,0>:d  {Compacted,I@2}
        cmp (16|M0)   (gt)f1.0   null<1>:d     r20.0<1;1,0>:ud   0x7FFFFF:ud              {I@1}
        add3 (16|M0)             r2.0<1>:d     r62.0<1;0>:d      r64.0<1;0>:d      -45:w              
(f1.0)  sel (16|M0)              r18.0<1>:d    r2.0<1;1,0>:d     r74.0<1;1,0>:d   {Compacted,I@1}
        cmp (16|M0)   (eq)f0.1   null<1>:d     r18.0<1;1,0>:d    255:w               {I@1}
(f0.1)  goto (16|M0)                         L13016                  L13016                
L12944:
(~f1.0) sel (16|M0)              r2.0<1>:d     r20.0<1;1,0>:d    0:w              
        and (16|M0)              r8.0<1>:d     r44.0<1;1,0>:d    -2147483648:d              
        shl (16|M0)              r10.0<1>:d    r18.0<1;1,0>:d    23:w               {Compacted}
        bfn.0xFE (16|M0)         r86.0<1>:ud   r8.0<1;0>:ud      r10.0<1;0>:ud     r2.0<1>:ud       {I@1} // s0|s1|s2
        goto (16|M0)                         L13016                  L13600                
L13016:
        join (16|M0)                         L13080                                
L13032:
        cmp (16|M0)   (gt)f0.1   null<1>:d     r44.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r2.0<1>:f     inf:f                               {Compacted,I@4}
(f0.1)  sel (16|M0)              r86.0<1>:f    r2.0<0;1,0>:f     -inf:f               {Compacted,F@1}
        goto (16|M0)                         L13080                  L13600                
L13080:
        join (16|M0)                         L13384                                
L13096:
        and (16|M0)   (ne)f0.0   r4.0<1>:d     r64.0<1;1,0>:d    63:w               {Compacted}
(f0.0)  goto (16|M0)                         L13152                  L13152                
L13120:
        mov (16|M0)              r92.0<1>:d    -1:w                              
        goto (16|M0)                         L13152                  L13280                
L13152:
        join (16|M0)                         L13280                                
L13168:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r4.0<1;1,0>:ud    0x20:uw              {I@5}
(f1.1)  goto (16|M0)                         L13232                  L13232                
L13200:
        mov (16|M0)              r92.0<1>:d    0:w                              
        goto (16|M0)                         L13232                  L13280                
L13232:
        join (16|M0)                         L13280                                
L13248:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                             
        shl (16|M0)              r92.0<1>:d    r2.0<0;1,0>:w     r4.0<1;1,0>:d    {F@1}
L13280:
        join (16|M0)                         L13384                                
L13296:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r92.0<1;0>:ud     r6.1<0;0>:ud      r50.0<1>:ud      {I@2} // (s0^s1)&s2
        add (16|M0)              r8.0<1>:d     -r64.0<1;1,0>:d   23:w               {Compacted}
        and (16|M0)              r10.0<1>:d    r44.0<1;1,0>:d    -2147483648:d              
        shl (16|M0)              r12.0<1>:d    r74.0<1;1,0>:d    23:w               {Compacted}
        shl (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     r8.0<1;1,0>:d    {Compacted,I@3}
        bfn.0xFE (16|M0)         r86.0<1>:ud   r10.0<1;0>:ud     r12.0<1;0>:ud     r2.0<1>:ud       {I@1} // s0|s1|s2
        goto (16|M0)                         L13384                  L13600                
L13384:
        join (16|M0)                         L13440                                
L13400:
        cmp (16|M0)   (gt)f0.0   null<1>:d     r44.0<1;1,0>:d    -1:w               {Compacted}
(W)     mov (1|M0)               r2.0<1>:f     inf:f                               {Compacted,I@4}
(f0.0)  sel (16|M0)              r86.0<1>:f    r2.0<0;1,0>:f     -inf:f               {Compacted,F@1}
        goto (16|M0)                         L13440                  L13600                
L13440:
        join (16|M0)                         L13504                                
L13456:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r44.0<1;1,0>:d    0:w              
(W)     mov (1|M0)               r2.0<1>:f     -0.0:f                               {Compacted}
(f1.1)  sel (16|M0)              r86.0<1>:f    r2.0<0;1,0>:f     0.0:f               {Compacted,F@1}
        goto (16|M0)                         L13504                  L13600                
L13504:
        join (16|M0)                         L13568                                
L13520:
        cmp (16|M0)   (gt)f1.0   null<1>:d     r44.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r2.0<1>:f     inf:f                               {Compacted}
(f1.0)  sel (16|M0)              r86.0<1>:f    r2.0<0;1,0>:f     -inf:f               {Compacted,F@1}
        goto (16|M0)                         L13568                  L13600                
L13568:
        join (16|M0)                         L13600                                
L13584:
        bfn.0xF8 (16|M0)         r86.0<1>:ud   r44.0<1;0>:ud     r6.5<0;0>:ud      r6.4<0>:ud       {F@1} // s0&s1|s2
L13600:
        join (16|M0)                         L13616                                
L13616:
        rnde (16|M0)             r126.0<1>:f   r86.0<1;1,0>:f                   {Compacted,I@2}
        shr (16|M0)              r26.0<1>:ud   r126.0<1;1,0>:ud  23:w               {F@1}
        and (16|M0)   (ne)f1.1   r66.0<1>:d    r126.0<1;1,0>:d   8388607:d              
        and (16|M0)              r114.0<1>:d   r26.0<1;1,0>:d    255:w               {Compacted,I@2}
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r114.0<1;1,0>:d   255:w               {I@1}
(~f1.1) goto (16|M0)                         L13728                  L13728                
L13696:
        mov (16|M0)              r84.0<1>:ud   0x7FC00000:ud                             
        goto (16|M0)                         L13728                  L19664                
L13728:
        join (16|M0)                         L19664                                
L13744:
        cmp (16|M0)   (eq)f0.1   null<1>:d     r66.0<1;1,0>:d    0:w              
        add (16|M0)              r2.0<1>:d     r40.0<1;1,0>:d    -25165824:d              
        shr (16|M0)              r22.0<1>:ud   r2.0<1;1,0>:ud    23:w               {I@1}
(f0.1)  cmp (16|M0)   (eq)f0.1   null<1>:d     r114.0<1;1,0>:d   255:w              
        and (16|M0)              r120.0<1>:d   r22.0<1;1,0>:d    255:w               {Compacted,I@2}
(~f0.1) cmp (16|M0)   (eq)f0.1   null<1>:d     r120.0<1;1,0>:d   255:w               {I@1}
        xor (16|M0)              r42.0<1>:d    r2.0<1;1,0>:d     r126.0<1;1,0>:d  {Compacted}
(f0.1)  goto (16|M0)                         L19632                  L19632                
L13856:
        cmp (16|M0)   (eq)f1.0   null<1>:d     r120.0<1;1,0>:d   0:w              
        or (16|M0)               r2.0<1>:d     r114.0<1;1,0>:d   r66.0<1;1,0>:d   {Compacted}
(~f1.0) cmp (16|M0)   (eq)f1.0   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
(~f1.0) goto (16|M0)                         L13944                  L13944                
L13912:
        mov (16|M0)              r84.0<1>:ud   0x0:ud                             
        goto (16|M0)                         L13944                  L19664                
L13944:
        join (16|M0)                         L19632                                
L13960:
        cmp (16|M0)   (eq)f0.0   null<1>:d     r114.0<1;1,0>:d   0:w               {Compacted}
        add (16|M0)              r116.0<1>:d   r114.0<1;1,0>:d   -127:w               {Compacted}
(f0.0)  mov (16|M0)              r116.0<1>:d   -126:w                              
        add (16|M0)              r58.0<1>:d    r120.0<1;1,0>:d   r116.0<1;1,0>:d  {Compacted,I@1}
        cmp (16|M0)   (gt)f1.0   null<1>:d     r58.0<1;1,0>:d    254:w               {I@1}
(f1.0)  goto (16|M0)                         L19568                  L19568                
L14032:
        or (16|M0)    (eq)f0.1   null<4>:b     r26.0<1;1,0>:d    r22.0<1;1,0>:d  
(f0.1)  goto (16|M0)                         L19504                  L19504                
L14064:
(W)     mov (1|M0)               r2.0<1>:hf    0.0:hf                             
(W)     mov (1|M0)               r5.4<1>:d     0:w                              
(f0.0)  sel (16|M0)              r8.0<1>:d     r2.0<0;1,0>:w     8388608:d               {F@1}
        or (16|M0)               r8.0<1>:d     r8.0<1;1,0>:d     r66.0<1;1,0>:d   {Compacted,I@1}
        shl (16|M0)              r46.0<1>:d    r8.0<1;1,0>:d     23:w               {Compacted,I@1}
        shr (16|M0)              r52.0<1>:ud   r8.0<1;1,0>:ud    9:w              
(W)     mov (1|M0)               r5.3<1>:f     -0.0:f                               {Compacted}
(W)     mov (2|M0)               r5.0<1>:d     0:w                              
L14168:
(W)     shl (1|M0)               r2.0<1>:d     r5.3<0;1,0>:d     31:w               {Compacted,F@1}
(W)     shr (1|M0)               r2.1<1>:ud    r5.4<0;1,0>:ud    1:w              
(W)     cmp (16|M0)   (gt)f1.0   null<1>:d     r5.0<0;1,0>:ud    0x3E:uw              {I@3}
(W)     or (1|M0)                r5.4<1>:d     r2.1<0;1,0>:d     r2.0<0;1,0>:d    {I@2}
        bfn.0xE0 (16|M0)         r8.0<1>:ud    r2.1<0;0>:ud      r2.0<0;0>:ud      r46.0<1>:ud      // (s0|s1)&s2
(W)     shr (1|M0)               r5.2<1>:ud    r5.3<0;1,0>:ud    1:w              
(W&f1.0) cmp (16|M0)  (eq)f1.0   null<1>:d     r5.1<0;1,0>:d     0:w              
        cmp (16|M0)   (eq)f0.1   null<1>:d     r8.0<1;1,0>:d     r5.4<0;1,0>:d    {I@3}
        and (16|M0)              r10.0<1>:d    r5.2<0;1,0>:d     r52.0<1;1,0>:d   {Compacted,I@3}
(W&~f1.0) cmp (16|M0) (gt)f1.0   null<1>:d     r5.1<0;1,0>:ud    0x0:uw             
(f0.1)  cmp (16|M0)   (eq)f0.1   null<1>:d     r10.0<1;1,0>:d    r5.2<0;1,0>:d    {I@2}
(W)     mov (1|M0)               r4.12<1>:hf   0x1:hf                             
(W)     addc (1|M0)              r13.0<1>:ud   r5.0<0;1,0>:ud    0x1:ud              {AccWrEn}
(f1.0)  sel (16|M0)              r7.0<1>:uw    r4.12<0;1,0>:uw   0x0:uw              {Compacted,F@1}
(f0.1)  sel (16|M0)              acc2.0<1>:uw  r4.12<0;1,0>:uw   0x0:uw             
(W)     mov (1|M0)               r3.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        or (16|M0)    (ne)f0.0   null<1>:uw    r7.0<1;1,0>:uw    acc2.0<1;1,0>:uw {I@3}
(W)     add (1|M0)               r5.5<1>:ud    r3.0<0;1,0>:ud    r5.1<0;1,0>:ud   {I@2}
        mov (16|M0)              r100.0<1>:f   r5.0<0;1,0>:f                    {Compacted}
        mov (16|M0)              r98.0<1>:d    r5.1<0;1,0>:d                   
        mov (16|M0)              r90.0<1>:f    r13.0<0;1,0>:f                   {Compacted}
        mov (16|M0)              r118.0<1>:d   r5.5<0;1,0>:d                    {I@2}
(f0.0)  goto (16|M0)                         L14544                  L14544                
L14488:
(W)     mov (1|M0)               r5.3<1>:d     r5.2<0;1,0>:d                   
(W)     mov (1|M0)               r5.0<1>:f     r13.0<0;1,0>:f                   {Compacted}
(W)     mov (1|M0)               r5.1<1>:d     r5.5<0;1,0>:d                   
(W)     jmpi                                 L14168                                
L14544:
        join (16|M0)                         L19504                                
L14560:
(W)     mov (1|M0)               r2.0<1>:f     8.68805e-44:f                              
(W)     mov (1|M0)               r3.0<1>:hf    0.0:hf                             
        subb (8|M0)              r66.0<1>:ud   r2.0<0;1,0>:ud    r100.0<1;1,0>:ud {AccWrEn,Compacted,F@2}
        add3 (8|M0)              r68.0<1>:ud   -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r98.0<1>:ud     {A@1}
        subb (8|M8)              r67.0<1>:ud   r2.0<0;1,0>:ud    r101.0<1;1,0>:ud {AccWrEn}
        add3 (16|M0)             r60.0<1>:d    r58.0<1;0>:d      r66.0<1;0>:d      -173:w               {I@1}
        cmp (16|M0)   (gt)f0.0   null<1>:d     r60.0<1;1,0>:d    127:w               {Compacted,I@1}
        add3 (8|M8)              r69.0<1>:ud   -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r99.0<1>:ud    
        add3 (16|M0)             r64.0<1>:d    r120.0<1;0>:d     r116.0<1;0>:d     r66.0<1>:d      
(f0.0)  goto (16|M0)                         L19448                  L19448                
L14704:
        cmp (16|M0)   (gt)f1.1   null<1>:d     r60.0<1;1,0>:d    -127:w              
(f1.1)  goto (16|M0)                         L17136                  L17136                
L14736:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r60.0<1;1,0>:ud   0xFFFFFF6B:ud             
(f1.0)  goto (16|M0)                         L16640                  L16640                
L14768:
(W)     mov (1|M0)               r2.0<1>:f     8.82818e-44:f                              
(W)     mov (1|M0)               r3.0<1>:hf    0.0:hf                              {I@7}
        subb (8|M0)              r110.0<1>:ud  r2.0<0;1,0>:ud    r100.0<1;1,0>:ud {AccWrEn,Compacted,F@2}
        add3 (16|M0)             r84.0<1>:d    r58.0<1;0>:d      r66.0<1;0>:d      -23:w              
        add3 (8|M0)              r8.0<1>:ud    -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r98.0<1>:ud     {F@1}
        subb (8|M8)              r111.0<1>:ud  r2.0<0;1,0>:ud    r101.0<1;1,0>:ud {AccWrEn}
        cmp (16|M0)   (gt)f0.0   null<1>:d     r110.0<1;1,0>:ud  r84.0<1;1,0>:ud  {I@1}
        add3 (8|M8)              r9.0<1>:ud    -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r99.0<1>:ud    
(f0.0)  cmp (16|M0)   (eq)f0.0   null<1>:d     r8.0<1;1,0>:d     0:w               {I@1}
(~f0.0) cmp (16|M0)   (gt)f0.0   null<1>:d     r8.0<1;1,0>:ud    0x0:uw             
(f0.0)  goto (16|M0)                         L14992                  L14992                
L14936:
        add3 (16|M0)             r2.0<1>:d     r64.0<1;0>:d      -r110.0<1;0>:d    -23:w              
        mov (16|M0)              r120.0<1>:d   0:w                              
        shl (16|M0)              r122.0<1>:d   r46.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
        goto (16|M0)                         L14992                  L16576                
L14992:
        join (16|M0)                         L16576                                
L15008:
        add3 (16|M0)             r86.0<1>:d    r110.0<1;0>:d     -r64.0<1;0>:d     23:w              
        cmp (16|M0)   (lt)f0.1   null<1>:d     r86.0<1;1,0>:d    2:w               {I@1}
(f0.1)  goto (16|M0)                         L15152                  L15152                
L15056:
        cmp (16|M0)   (eq)f0.0   null<1>:d     r86.0<1;1,0>:d    2:w               {Compacted}
(~f0.0) goto (16|M0)                         L15152                  L15256                
L15080:
        shr (16|M0)              r72.0<1>:ud   r46.0<1;1,0>:ud   1:w              
        mov (16|M0)              r88.0<1>:d    0:w                              
        mov (16|M0)              r74.0<1>:d    0:w                              
        mov (16|M0)              r64.0<1>:f    r72.0<1;1,0>:f                   {Compacted,I@3}
        goto (16|M0)                         L15152                  L16072                
L15152:
        join (16|M0)                         L15256                                
L15168:
        cmp (16|M0)   (eq)f1.1   null<1>:d     r86.0<1;1,0>:d    1:w              
(~f1.1) goto (16|M0)                         L15256                  L15256                
L15200:
        mov (16|M0)              r88.0<1>:d    0:w                              
        mov (16|M0)              r74.0<1>:d    0:w                              
        mov (16|M0)              r64.0<1>:f    r46.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L15256                  L16072                
L15256:
        join (16|M0)                         L16072                                
L15272:
        add3 (16|M0)             r2.0<1>:d     r110.0<1;0>:d     -r84.0<1;0>:d     -1:w              
        and (16|M0)   (ne)f1.0   r14.0<1>:d    r2.0<1;1,0>:d     63:w               {I@1}
(f1.0)  goto (16|M0)                         L15344                  L15344                
L15320:
        mov (16|M0)              r82.0<1>:f    r46.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L15344                  L15456                
L15344:
        join (16|M0)                         L15456                                
L15360:
        cmp (16|M0)   (lt)f0.1   null<1>:d     r14.0<1;1,0>:ud   0x20:uw              {I@4}
(~f0.1) add (16|M0)              r2.0<1>:d     r14.0<1;1,0>:d    -32:w              
(~f0.1) shr (16|M0)              r72.0<1>:ud   r52.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f0.1)  add (16|M0)              r2.0<1>:d     -r14.0<1;1,0>:d   32:w               {Compacted}
(f0.1)  shr (16|M0)              r8.0<1>:ud    r46.0<1;1,0>:ud   r14.0<1;1,0>:d  
(f0.1)  shl (16|M0)              r2.0<1>:d     r52.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f0.1)  or (16|M0)               r72.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
        mov (16|M0)              r82.0<1>:f    r72.0<1;1,0>:f                   {Compacted,I@1}
L15456:
        join (16|M0)                         L16072                                
L15472:
        add3 (16|M0)             r24.0<1>:d    r110.0<1;0>:d     -r84.0<1;0>:d     -2:w              
        and (16|M0)   (ne)f0.0   r12.0<1>:d    r24.0<1;1,0>:d    63:w               {Compacted,I@1}
(f0.0)  goto (16|M0)                         L15536                  L15536                
L15512:
        mov (16|M0)              r72.0<1>:f    r46.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L15536                  L15640                
L15536:
        join (16|M0)                         L15640                                
L15552:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r12.0<1;1,0>:ud   0x20:uw              {I@4}
(~f1.1) add (16|M0)              r2.0<1>:d     r12.0<1;1,0>:d    -32:w              
(~f1.1) shr (16|M0)              r72.0<1>:ud   r52.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.1)  add (16|M0)              r2.0<1>:d     -r12.0<1;1,0>:d   32:w               {Compacted}
(f1.1)  shr (16|M0)              r8.0<1>:ud    r46.0<1;1,0>:ud   r12.0<1;1,0>:d  
(f1.1)  shl (16|M0)              r2.0<1>:d     r52.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.1)  or (16|M0)               r72.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
L15640:
        join (16|M0)                         L16072                                
L15656:
        and (16|M0)   (ne)f1.0   r124.0<1>:d   r24.0<1;1,0>:d    63:w              
(f1.0)  goto (16|M0)                         L15736                  L15736                
L15688:
        mov (16|M0)              r18.0<1>:d    -1:w                              
        mov (16|M0)              r26.0<1>:d    -1:w                              
        goto (16|M0)                         L15736                  L15920                
L15736:
        join (16|M0)                         L15920                                
L15752:
        cmp (16|M0)   (lt)f0.1   null<1>:d     r124.0<1;1,0>:ud  0x20:uw              {I@6}
(f0.1)  goto (16|M0)                         L15856                  L15856                
L15784:
        add (16|M0)              r2.0<1>:d     r124.0<1;1,0>:d   -32:w               {Compacted}
(W)     mov (1|M0)               r4.12<1>:hf   -qnan(0x1FF):hf                             
        mov (16|M0)              r18.0<1>:d    0:w                              
        shl (16|M0)              r26.0<1>:d    r4.12<0;1,0>:w    r2.0<1;1,0>:d    {A@1}
        goto (16|M0)                         L15856                  L15920                
L15856:
        join (16|M0)                         L15920                                
L15872:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (16|M0)              r26.0<1>:d    -1:w                              
        shl (16|M0)              r18.0<1>:d    r2.0<0;1,0>:w     r124.0<1;1,0>:d  {F@1}
L15920:
        join (16|M0)                         L16072                                
L15936:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r18.0<1;0>:ud     r6.1<0;0>:ud      r46.0<1>:ud      {I@2} // (s0^s1)&s2
        cmp (16|M0)   (ne)f0.1   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
        bfn.0x60 (16|M0)         r8.0<1>:ud    r26.0<1;0>:ud     r6.1<0;0>:ud      r52.0<1>:ud      // (s0^s1)&s2
(~f0.1) cmp (16|M0)   (ne)f0.1   null<1>:d     r8.0<1;1,0>:d     0:w               {I@1}
(W)     mov (1|M0)               r4.12<1>:hf   -qnan(0x1FF):hf                             
        shl (16|M0)              r12.0<1>:d    r72.0<1;1,0>:d    1:w               {Compacted}
(f0.1)  sel (16|M0)              r10.0<1>:d    r4.12<0;1,0>:w    0:w               {F@1}
        mov (16|M0)              r64.0<1>:f    r82.0<1;1,0>:f                   {Compacted}
        and (16|M0)              r74.0<1>:d    r12.0<1;1,0>:d    2:w               {Compacted,I@2}
        mov (16|M0)              r88.0<1>:d    -r10.0<1;1,0>:d                  {I@2}
L16072:
        join (16|M0)                         L16576                                
L16088:
        and (16|M0)   (ne)f0.0   r10.0<1>:d    r86.0<1;1,0>:d    63:w               {Compacted}
(f0.0)  goto (16|M0)                         L16136                  L16136                
L16112:
        mov (16|M0)              r72.0<1>:f    r46.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L16136                  L16240                
L16136:
        join (16|M0)                         L16240                                
L16152:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r10.0<1;1,0>:ud   0x20:uw              {I@4}
(~f1.1) add (16|M0)              r2.0<1>:d     r10.0<1;1,0>:d    -32:w              
(~f1.1) shr (16|M0)              r72.0<1>:ud   r52.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.1)  add (16|M0)              r2.0<1>:d     -r10.0<1;1,0>:d   32:w               {Compacted}
(f1.1)  shr (16|M0)              r8.0<1>:ud    r46.0<1;1,0>:ud   r10.0<1;1,0>:d  
(f1.1)  shl (16|M0)              r2.0<1>:d     r52.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.1)  or (16|M0)               r72.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
L16240:
        join (16|M0)                         L16576                                
L16256:
        shl (16|M0)              r2.0<1>:d     r64.0<1;1,0>:d    2:w               {Compacted}
        and (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     4:w               {Compacted,I@1}
        bfn.0xFE (16|M0)         r62.0<1>:ud   r2.0<1;0>:ud      r74.0<1;0>:ud     r88.0<1>:ud      {I@1} // s0|s1|s2
        cmp (16|M0)   (eq)f1.0   null<1>:d     r62.0<1;1,0>:d    0:w               {I@1}
(~f1.0) goto (16|M0)                         L16352                  L16352                
L16320:
        mov (16|M0)              r68.0<1>:d    0:w                              
        goto (16|M0)                         L16352                  L16504                
L16352:
        join (16|M0)                         L16504                                
L16368:
        cmp (16|M0)   (gt)f0.1   null<1>:d     r62.0<1;1,0>:ud   0x4:uw             
(~f0.1) goto (16|M0)                         L16432                  L16432                
L16400:
        mov (16|M0)              r68.0<1>:d    1:w                              
        goto (16|M0)                         L16432                  L16504                
L16432:
        join (16|M0)                         L16504                                
L16448:
        and (16|M0)   (ne)f0.0   null<1>:d     r72.0<1;1,0>:d    1:w               {Compacted}
(W)     mov (1|M0)               r2.0<1>:hf    0x1:hf                             
(f0.0)  cmp (16|M0)   (eq)f0.0   null<1>:d     r62.0<1;1,0>:d    4:w              
(f0.0)  sel (16|M0)              r68.0<1>:d    r2.0<0;1,0>:w     0:w               {F@1}
L16504:
        join (16|M0)                         L16576                                
L16520:
        add (16|M0)              r2.0<1>:d     r68.0<1;1,0>:d    r72.0<1;1,0>:d   {Compacted,I@2}
        cmp (16|M0)   (gt)f0.1   null<1>:d     r2.0<1;1,0>:ud    0x7FFFFF:ud              {I@1}
(W)     mov (1|M0)               r4.6<1>:f     0x800000:f                               {Compacted}
(~f0.1) sel (16|M0)              r122.0<1>:d   r2.0<1;1,0>:d     0:w              
(f0.1)  sel (16|M0)              r120.0<1>:d   r4.6<0;1,0>:d     0:w               {Compacted,F@1}
L16576:
        join (16|M0)                         L16640                                
L16592:
        and (16|M0)              r2.0<1>:d     r42.0<1;1,0>:d    -2147483648:d              
        bfn.0xFE (16|M0)         r84.0<1>:ud   r2.0<1;0>:ud      r120.0<1;0>:ud    r122.0<1>:ud     {I@1} // s0|s1|s2
        goto (16|M0)                         L16640                  L19664                
L16640:
        join (16|M0)                         L17136                                
L16656:
        and (16|M0)   (ne)f0.0   r90.0<1>:d    r66.0<1;1,0>:d    63:w               {Compacted}
(f0.0)  goto (16|M0)                         L16728                  L16728                
L16680:
        mov (16|M0)              r100.0<1>:d   -1:w                              
        mov (16|M0)              r122.0<1>:d   -1:w                              
        goto (16|M0)                         L16728                  L16912                
L16728:
        join (16|M0)                         L16912                                
L16744:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r90.0<1;1,0>:ud   0x20:uw              {I@6}
(f1.1)  goto (16|M0)                         L16848                  L16848                
L16776:
        add (16|M0)              r2.0<1>:d     r90.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r4.12<1>:hf   -qnan(0x1FF):hf                             
        mov (16|M0)              r100.0<1>:d   0:w                              
        shl (16|M0)              r122.0<1>:d   r4.12<0;1,0>:w    r2.0<1;1,0>:d    {A@1}
        goto (16|M0)                         L16848                  L16912                
L16848:
        join (16|M0)                         L16912                                
L16864:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (16|M0)              r122.0<1>:d   -1:w                              
        shl (16|M0)              r100.0<1>:d   r2.0<0;1,0>:w     r90.0<1;1,0>:d   {F@1}
L16912:
        join (16|M0)                         L17136                                
L16928:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r100.0<1;0>:ud    r6.1<0;0>:ud      r46.0<1>:ud      {I@2} // (s0^s1)&s2
        cmp (16|M0)   (ne)f1.1   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
        bfn.0x60 (16|M0)         r8.0<1>:ud    r122.0<1;0>:ud    r6.1<0;0>:ud      r52.0<1>:ud      // (s0^s1)&s2
        cmp (16|M0)   (gt)f1.0   null<1>:d     r42.0<1;1,0>:d    -1:w              
(~f1.1) cmp (16|M0)   (ne)f1.1   null<1>:d     r8.0<1;1,0>:d     0:w               {I@2}
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r60.0<1;1,0>:d    -150:w              
(f1.0)  goto (16|M0)                         L17080                  L17080                
L17040:
(W)     mov (1|M0)               r2.0<1>:ud    0x80000001:ud                             
(f1.1)  sel (16|M0)              r84.0<1>:f    r2.0<0;1,0>:f     -0.0:f               {Compacted,I@1}
        goto (16|M0)                         L17080                  L19664                
L17080:
        join (16|M0)                         L17136                                
L17096:
(W)     mov (1|M0)               r2.0<1>:ud    0x1:ud                              {F@1}
(f1.1)  sel (16|M0)              r84.0<1>:f    r2.0<0;1,0>:f     0.0:f               {Compacted,I@1}
        goto (16|M0)                         L17136                  L19664                
L17136:
        join (16|M0)                         L19448                                
L17152:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r66.0<1;1,0>:ud   0x18:uw              {F@1}
        add3 (16|M0)             r70.0<1>:d    r58.0<1;0>:d      r66.0<1;0>:d      -46:w              
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r68.0<1;1,0>:d    0:w              
(f1.1)  goto (16|M0)                         L19136                  L19136                
L17216:
        shl (16|M0)              r2.0<1>:d     r90.0<1;1,0>:d    1:w               {Compacted}
        shr (16|M0)              r8.0<1>:ud    r90.0<1;1,0>:ud   31:w              
        shl (16|M0)              r10.0<1>:d    r118.0<1;1,0>:d   1:w               {Compacted}
        cmp (16|M0)   (lt)f1.1   null<1>:d     r2.0<1;1,0>:ud    0x4E:uw              {I@3}
        or (16|M0)               r10.0<1>:d    r10.0<1;1,0>:d    r8.0<1;1,0>:d    {Compacted,I@2}
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r10.0<1;1,0>:d    0:w               {I@1}
(~f1.1) cmp (16|M0)   (lt)f1.1   null<1>:d     r10.0<1;1,0>:d    0:w              
(f1.1)  goto (16|M0)                         L17448                  L17448                
L17320:
        cmp (16|M0)   (eq)f1.0   null<1>:d     r90.0<1;1,0>:d    39:w              
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r118.0<1;1,0>:d   0:w              
(~f1.0) goto (16|M0)                         L17448                  L17512                
L17368:
        shr (16|M0)              r72.0<1>:ud   r46.0<1;1,0>:ud   1:w              
        mov (16|M0)              r96.0<1>:d    0:w                              
        mov (16|M0)              r62.0<1>:d    0:w                              
        mov (16|M0)              r50.0<1>:f    r72.0<1;1,0>:f                   {Compacted,I@3}
        mov (16|M0)              r72.0<1>:f    r46.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L17448                  L18616                
L17448:
        join (16|M0)                         L17512                                
L17464:
        cmp (16|M0)   (eq)f0.1   null<1>:d     r90.0<1;1,0>:d    38:w              
(f0.1)  cmp (16|M0)   (eq)f0.1   null<1>:d     r118.0<1;1,0>:d   0:w              
(f0.1)  goto (16|M0)                         L17512                  L18528                
L17512:
        join (16|M0)                         L18528                                
L17528:
        add (16|M0)              r2.0<1>:d     -r90.0<1;1,0>:d   39:w               {Compacted}
        and (16|M0)   (ne)f0.1   r24.0<1>:d    r2.0<1;1,0>:d     63:w               {I@1}
        add (16|M0)              r104.0<1>:d   -r90.0<1;1,0>:d   40:w               {Compacted}
(f0.1)  goto (16|M0)                         L17600                  L17600                
L17576:
        mov (16|M0)              r86.0<1>:f    r46.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L17600                  L17712                
L17600:
        join (16|M0)                         L17712                                
L17616:
        cmp (16|M0)   (lt)f0.0   null<1>:d     r24.0<1;1,0>:ud   0x20:uw              {I@5}
(~f0.0) add (16|M0)              r2.0<1>:d     r24.0<1;1,0>:d    -32:w              
(~f0.0) shr (16|M0)              r72.0<1>:ud   r52.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f0.0)  add (16|M0)              r2.0<1>:d     -r24.0<1;1,0>:d   32:w               {Compacted}
(f0.0)  shr (16|M0)              r8.0<1>:ud    r46.0<1;1,0>:ud   r24.0<1;1,0>:d  
(f0.0)  shl (16|M0)              r2.0<1>:d     r52.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f0.0)  or (16|M0)               r72.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
        mov (16|M0)              r86.0<1>:f    r72.0<1;1,0>:f                   {Compacted,I@1}
L17712:
        join (16|M0)                         L18528                                
L17728:
        add (16|M0)              r44.0<1>:d    -r90.0<1;1,0>:d   38:w               {Compacted}
        and (16|M0)   (ne)f1.1   r40.0<1>:d    r44.0<1;1,0>:d    63:w               {I@1}
(f1.1)  goto (16|M0)                         L17792                  L17792                
L17768:
        mov (16|M0)              r78.0<1>:f    r46.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L17792                  L17904                
L17792:
        join (16|M0)                         L17904                                
L17808:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r40.0<1;1,0>:ud   0x20:uw              {I@4}
(~f1.0) add (16|M0)              r2.0<1>:d     r40.0<1;1,0>:d    -32:w              
(~f1.0) shr (16|M0)              r72.0<1>:ud   r52.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.0)  add (16|M0)              r2.0<1>:d     -r40.0<1;1,0>:d   32:w               {Compacted}
(f1.0)  shr (16|M0)              r8.0<1>:ud    r46.0<1;1,0>:ud   r40.0<1;1,0>:d  
(f1.0)  shl (16|M0)              r2.0<1>:d     r52.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.0)  or (16|M0)               r72.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
        mov (16|M0)              r78.0<1>:f    r72.0<1;1,0>:f                   {Compacted,I@1}
L17904:
        join (16|M0)                         L18528                                
L17920:
        and (16|M0)   (ne)f0.1   r38.0<1>:d    r44.0<1;1,0>:d    63:w              
(f0.1)  goto (16|M0)                         L18000                  L18000                
L17952:
        mov (16|M0)              r48.0<1>:d    -1:w                              
        mov (16|M0)              r60.0<1>:d    -1:w                              
        goto (16|M0)                         L18000                  L18184                
L18000:
        join (16|M0)                         L18184                                
L18016:
        cmp (16|M0)   (lt)f0.0   null<1>:d     r38.0<1;1,0>:ud   0x20:uw              {I@6}
(f0.0)  goto (16|M0)                         L18120                  L18120                
L18048:
        add (16|M0)              r2.0<1>:d     r38.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r4.12<1>:hf   -qnan(0x1FF):hf                             
        mov (16|M0)              r48.0<1>:d    0:w                              
        shl (16|M0)              r60.0<1>:d    r4.12<0;1,0>:w    r2.0<1;1,0>:d    {A@1}
        goto (16|M0)                         L18120                  L18184                
L18120:
        join (16|M0)                         L18184                                
L18136:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (16|M0)              r60.0<1>:d    -1:w                              
        shl (16|M0)              r48.0<1>:d    r2.0<0;1,0>:w     r38.0<1;1,0>:d   {F@1}
L18184:
        join (16|M0)                         L18528                                
L18200:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r48.0<1;0>:ud     r6.1<0;0>:ud      r46.0<1>:ud      {I@2} // (s0^s1)&s2
        cmp (16|M0)   (ne)f0.0   null<1>:d     r2.0<1;1,0>:d     0:w               {Compacted,I@1}
        bfn.0x60 (16|M0)         r8.0<1>:ud    r60.0<1;0>:ud     r6.1<0;0>:ud      r52.0<1>:ud      // (s0^s1)&s2
(~f0.0) cmp (16|M0)   (ne)f0.0   null<1>:d     r8.0<1;1,0>:d     0:w               {I@1}
(W)     mov (1|M0)               r4.12<1>:hf   -qnan(0x1FF):hf                             
        and (16|M0)   (ne)f1.1   r38.0<1>:d    r104.0<1;1,0>:d   63:w              
(f0.0)  sel (16|M0)              r10.0<1>:d    r4.12<0;1,0>:w    0:w               {F@1}
        mov (16|M0)              r96.0<1>:d    -r10.0<1;1,0>:d                  {I@1}
(f1.1)  goto (16|M0)                         L18360                  L18360                
L18336:
        mov (16|M0)              r72.0<1>:f    r46.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L18360                  L18464                
L18360:
        join (16|M0)                         L18464                                
L18376:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r38.0<1;1,0>:ud   0x20:uw             
(~f1.0) add (16|M0)              r2.0<1>:d     r38.0<1;1,0>:d    -32:w              
(~f1.0) shr (16|M0)              r72.0<1>:ud   r52.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.0)  add (16|M0)              r2.0<1>:d     -r38.0<1;1,0>:d   32:w               {Compacted}
(f1.0)  shr (16|M0)              r8.0<1>:ud    r46.0<1;1,0>:ud   r38.0<1;1,0>:d  
(f1.0)  shl (16|M0)              r2.0<1>:d     r52.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.0)  or (16|M0)               r72.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
L18464:
        join (16|M0)                         L18528                                
L18480:
        shl (16|M0)              r2.0<1>:d     r78.0<1;1,0>:d    1:w               {Compacted}
        mov (16|M0)              r50.0<1>:f    r72.0<1;1,0>:f                   {Compacted,I@3}
        and (16|M0)              r62.0<1>:d    r2.0<1;1,0>:d     2:w               {Compacted,I@1}
        mov (16|M0)              r72.0<1>:f    r86.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L18528                  L18616                
L18528:
        join (16|M0)                         L18616                                
L18544:
        shr (16|M0)              r72.0<1>:ud   r46.0<1;1,0>:ud   2:w               {F@1}
        mov (16|M0)              r96.0<1>:d    0:w                              
        mov (16|M0)              r62.0<1>:d    0:w                              
        mov (16|M0)              r50.0<1>:f    r72.0<1;1,0>:f                   {Compacted,I@3}
        shr (16|M0)              r72.0<1>:ud   r46.0<1;1,0>:ud   1:w               {F@1}
L18616:
        join (16|M0)                         L19136                                
L18632:
        shl (16|M0)              r2.0<1>:d     r72.0<1;1,0>:d    2:w               {Compacted,I@2}
        and (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     4:w               {Compacted,I@1}
        bfn.0xFE (16|M0)         r98.0<1>:ud   r2.0<1;0>:ud      r62.0<1;0>:ud     r96.0<1>:ud      {I@1} // s0|s1|s2
        cmp (16|M0)   (eq)f0.1   null<1>:d     r98.0<1;1,0>:d    0:w               {I@1}
        and (16|M0)              r92.0<1>:d    r50.0<1;1,0>:d    8388607:d              
(~f0.1) goto (16|M0)                         L18744                  L18744                
L18712:
        mov (16|M0)              r88.0<1>:d    0:w                              
        goto (16|M0)                         L18744                  L18904                
L18744:
        join (16|M0)                         L18904                                
L18760:
        cmp (16|M0)   (gt)f0.0   null<1>:d     r98.0<1;1,0>:ud   0x4:uw             
(~f0.0) goto (16|M0)                         L18824                  L18824                
L18792:
        mov (16|M0)              r88.0<1>:d    1:w                              
        goto (16|M0)                         L18824                  L18904                
L18824:
        join (16|M0)                         L18904                                
L18840:
        and (16|M0)   (ne)f1.1   null<1>:d     r50.0<1;1,0>:d    1:w              
(W)     mov (1|M0)               r2.0<1>:hf    0x1:hf                             
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r98.0<1;1,0>:d    4:w              
(f1.1)  sel (16|M0)              r88.0<1>:d    r2.0<0;1,0>:w     0:w               {F@1}
L18904:
        join (16|M0)                         L19136                                
L18920:
        add (16|M0)              r16.0<1>:d    r92.0<1;1,0>:d    r88.0<1;1,0>:d   {Compacted,I@2}
        cmp (16|M0)   (gt)f0.0   null<1>:d     r16.0<1;1,0>:ud   0x7FFFFF:ud              {I@1}
        add3 (16|M0)             r2.0<1>:d     r58.0<1;0>:d      r66.0<1;0>:d      -45:w              
(f0.0)  sel (16|M0)              r126.0<1>:d   r2.0<1;1,0>:d     r70.0<1;1,0>:d   {Compacted,I@1}
        cmp (16|M0)   (eq)f1.1   null<1>:d     r126.0<1;1,0>:d   255:w               {I@1}
(f1.1)  goto (16|M0)                         L19072                  L19072                
L19000:
(~f0.0) sel (16|M0)              r2.0<1>:d     r16.0<1;1,0>:d    0:w              
        and (16|M0)              r8.0<1>:d     r42.0<1;1,0>:d    -2147483648:d              
        shl (16|M0)              r10.0<1>:d    r126.0<1;1,0>:d   23:w               {Compacted}
        bfn.0xFE (16|M0)         r84.0<1>:ud   r8.0<1;0>:ud      r10.0<1;0>:ud     r2.0<1>:ud       {I@1} // s0|s1|s2
        goto (16|M0)                         L19072                  L19664                
L19072:
        join (16|M0)                         L19136                                
L19088:
        cmp (16|M0)   (gt)f0.1   null<1>:d     r42.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r2.0<1>:f     inf:f                               {Compacted,I@4}
(f0.1)  sel (16|M0)              r84.0<1>:f    r2.0<0;1,0>:f     -inf:f               {Compacted,F@1}
        goto (16|M0)                         L19136                  L19664                
L19136:
        join (16|M0)                         L19448                                
L19152:
        and (16|M0)   (ne)f1.0   r118.0<1>:d   r66.0<1;1,0>:d    63:w              
(f1.0)  goto (16|M0)                         L19216                  L19216                
L19184:
        mov (16|M0)              r78.0<1>:d    -1:w                              
        goto (16|M0)                         L19216                  L19344                
L19216:
        join (16|M0)                         L19344                                
L19232:
        cmp (16|M0)   (lt)f0.1   null<1>:d     r118.0<1;1,0>:ud  0x20:uw              {A@1}
(f0.1)  goto (16|M0)                         L19296                  L19296                
L19264:
        mov (16|M0)              r78.0<1>:d    0:w                              
        goto (16|M0)                         L19296                  L19344                
L19296:
        join (16|M0)                         L19344                                
L19312:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                             
        shl (16|M0)              r78.0<1>:d    r2.0<0;1,0>:w     r118.0<1;1,0>:d  {F@1}
L19344:
        join (16|M0)                         L19448                                
L19360:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r78.0<1;0>:ud     r6.1<0;0>:ud      r46.0<1>:ud      {I@2} // (s0^s1)&s2
        add (16|M0)              r8.0<1>:d     -r66.0<1;1,0>:d   23:w               {Compacted}
        and (16|M0)              r10.0<1>:d    r42.0<1;1,0>:d    -2147483648:d              
        shl (16|M0)              r12.0<1>:d    r70.0<1;1,0>:d    23:w               {Compacted}
        shl (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     r8.0<1;1,0>:d    {Compacted,I@3}
        bfn.0xFE (16|M0)         r84.0<1>:ud   r10.0<1;0>:ud     r12.0<1;0>:ud     r2.0<1>:ud       {I@1} // s0|s1|s2
        goto (16|M0)                         L19448                  L19664                
L19448:
        join (16|M0)                         L19504                                
L19464:
        cmp (16|M0)   (gt)f0.0   null<1>:d     r42.0<1;1,0>:d    -1:w               {Compacted}
(W)     mov (1|M0)               r2.0<1>:f     inf:f                               {Compacted,I@4}
(f0.0)  sel (16|M0)              r84.0<1>:f    r2.0<0;1,0>:f     -inf:f               {Compacted,F@1}
        goto (16|M0)                         L19504                  L19664                
L19504:
        join (16|M0)                         L19568                                
L19520:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r42.0<1;1,0>:d    0:w              
(W)     mov (1|M0)               r2.0<1>:f     -0.0:f                               {Compacted}
(f1.1)  sel (16|M0)              r84.0<1>:f    r2.0<0;1,0>:f     0.0:f               {Compacted,F@1}
        goto (16|M0)                         L19568                  L19664                
L19568:
        join (16|M0)                         L19632                                
L19584:
        cmp (16|M0)   (gt)f1.0   null<1>:d     r42.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r2.0<1>:f     inf:f                               {Compacted}
(f1.0)  sel (16|M0)              r84.0<1>:f    r2.0<0;1,0>:f     -inf:f               {Compacted,F@1}
        goto (16|M0)                         L19632                  L19664                
L19632:
        join (16|M0)                         L19664                                
L19648:
        bfn.0xF8 (16|M0)         r84.0<1>:ud   r42.0<1;0>:ud     r6.5<0;0>:ud      r6.4<0>:ud       {F@1} // s0&s1|s2
L19664:
        join (16|M0)                         L19680                                
L19680:
        cmp (16|M0)   (lt)f0.0   null<1>:f     r34.0<1;1,0>:f    0xB3000000:f               {Compacted,I@7}
        shl (16|M0)              r8.0<1>:d     r32.0<1;1,0>:d    1:w               {Compacted}
(f0.0)  sel (16|M0)              r2.0<1>:f     -r84.0<1;1,0>:f   r84.0<1;1,0>:f   {Compacted,I@3}
(W)     mov (1|M0)               a0.0<1>:ud    r6.3<0;1,0>:d                    {A@1}
        mov (8|M0)               r7.0<1>:hf    r2.0<1;1,0>:f                    {F@1}
        mov (8|M8)               r7.8<1>:hf    r3.0<1;1,0>:f                   
        add (16|M0)              r8.0<1>:d     r8.0<1;1,0>:d     r6.0<0;1,0>:d    {Compacted,I@2}
        mov (16|M0)              r10.0<1>:ud   r7.0<1;1,0>:uw                   {A@1}
(W)     mov (8|M0)               r127.0<1>:f   r36.0<1;1,0>:f                   {Compacted}
        send.ugm (16|M0)         null     r8      r10:2   a0.0        0x240E0B04           {ExBSO,A@1,$6} // wr:2+2, rd:0; store.ugm.d16u32.a32.wb.wb.bss[a0.0]
(W)     send.gtwy (1|M0)         null     r127    null:0  0x0            0x02000010           {EOT,A@1} // wr:1+0, rd:0; end of thread
L19816:
        nop                    
(W)     mov (16|M0)              null<1>:ud    0x9E09665A:ud                             
(W)     mov (16|M0)              null<1>:ud    0xA6E09A48:ud                             
(W)     mov (16|M0)              null<1>:ud    0x0:ud                             
(W)     mov (16|M0)              null<1>:ud    0x48:ud                             
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
