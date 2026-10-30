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
(W)     cmp (16|M0)   (eq)f1.0   null<1>:d     r5.2<0;1,0>:d     0:w               {A@1}
(W)     mul (1|M0)               acc0.0<1>:d   r4.3<0;1,0>:d     r36.2<0;1,0>:uw  {I@3}
(W)     mach (1|M0)              r2.0<1>:d     r4.3<0;1,0>:d     r36.1<0;1,0>:d   {$0.dst}
        add3 (16|M0)             r32.0<1>:d    r2.0<0;0>:d       r1.0<1;0>:uw      r4.0<0>:d        {I@1}
(~f1.0) goto (16|M0)                         L416                  L416                
L384:
        mov (16|M0)              r76.0<1>:d    -1:w                              
        goto (16|M0)                         L416                  L784                
L416:
        join (16|M0)                         L784                                
L432:
(W)     xor (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x30:uw              {A@1}
(W)     mov (1|M0)               r2.0<1>:f     r5.2<0;1,0>:ud                   {Compacted,A@1}
(W)     mov (1|M0)               r3.2<1>:f     0xB4C00000:f                               {Compacted,$1.dst}
(W)     math.inv (1|M0)          r3.1<1>:f     r2.0<0;1,0>:f                    {@2,$3}
        mov (16|M0)              r8.0<1>:f     r32.0<1;1,0>:ud                  {Compacted}
        sync.nop                             null                             {Compacted,$3.dst}
(W)     mad (1|M0)               r4.6<1>:f     r3.1<0;0>:f       r3.2<0;0>:f       r3.1<0>:f        {F@2}
(W)     mov (1|M0)               r2.1<1>:ud    r2.0<0;1,0>:f                   
        mov (16|M0)              r12.0<1>:ud   r8.0<1;1,0>:f                    {F@2}
        mul (16|M0)              r10.0<1>:f    r8.0<1;1,0>:f     r4.6<0;1,0>:f    {Compacted,F@1}
(W)     add (1|M0)               r3.0<1>:d     r5.2<0;1,0>:d     -r2.1<0;1,0>:d   {I@2}
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
(W)     mul (8|M0)               acc0.0<1>:d   r30.0<1;1,0>:d    r5.4<0;1,0>:uw   {Compacted,I@1}
        mach (8|M0)              r30.0<1>:d    r30.0<1;1,0>:d    r5.2<0;1,0>:d    {Compacted}
(W)     mul (8|M8)               acc0.0<1>:d   r31.0<1;1,0>:d    r5.4<0;1,0>:uw  
        mach (8|M8)              r31.0<1>:d    r31.0<1;1,0>:d    r5.2<0;1,0>:d    {Compacted}
        add (16|M0)              r30.0<1>:d    r32.0<1;1,0>:d    -r30.0<1;1,0>:d  {Compacted,I@1}
        cmp (16|M0)   (ge)f1.0   r8.0<1>:ud    r30.0<1;1,0>:ud   r5.2<0;1,0>:ud   {I@1}
        add3 (16|M0)             r76.0<1>:d    r28.0<1;0>:d      r14.0<1;0>:d      -r8.0<1>:d       {I@1}
L784:
        join (16|M0)                         L800                                
L800:
(W)     mul (8|M0)               acc0.0<1>:d   r76.0<1;1,0>:d    r5.4<0;1,0>:uw   {Compacted,I@2}
        mach (8|M0)              r2.0<1>:d     r76.0<1;1,0>:d    r5.2<0;1,0>:d    {Compacted}
(W)     mul (8|M8)               acc0.0<1>:d   r77.0<1;1,0>:d    r5.4<0;1,0>:uw  
        shr (16|M0)              r10.0<1>:ud   r76.0<1;1,0>:ud   6:w              
        mach (8|M8)              r3.0<1>:d     r77.0<1;1,0>:d    r5.2<0;1,0>:d    {Compacted,$1.dst}
(W)     mul (8|M0)               acc0.0<1>:d   r10.0<1;1,0>:d    r5.6<0;1,0>:uw   {Compacted,I@2}
        add (16|M0)              r8.0<1>:d     r32.0<1;1,0>:d    -r2.0<1;1,0>:d   {Compacted,I@2}
        mach (8|M0)              r10.0<1>:d    r10.0<1;1,0>:d    r5.3<0;1,0>:d    {Compacted}
(W)     mul (8|M8)               acc0.0<1>:d   r11.0<1;1,0>:d    r5.6<0;1,0>:uw  
        shr (16|M0)              r12.0<1>:ud   r8.0<1;1,0>:ud    5:w               {I@3}
        mach (8|M8)              r11.0<1>:d    r11.0<1;1,0>:d    r5.3<0;1,0>:d    {Compacted}
        shl (16|M0)              r14.0<1>:d    r76.0<1;1,0>:d    7:w               {Compacted}
        add (16|M0)              r10.0<1>:d    r10.0<1;1,0>:d    r12.0<1;1,0>:d   {Compacted,I@2}
        shl (16|M0)              r2.0<1>:d     r8.0<1;1,0>:d     2:w               {Compacted}
        shl (16|M0)              r10.0<1>:d    r10.0<1;1,0>:d    13:w               {Compacted,I@2}
(W)     mov (1|M0)               a0.0<1>:ud    r6.1<0;1,0>:d                    {A@1}
        and (16|M0)              r14.0<1>:d    r14.0<1;1,0>:d    8064:w              
        and (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     124:w               {Compacted,I@4}
        add (16|M0)              r10.0<1>:d    r10.0<1;1,0>:d    r5.7<0;1,0>:d    {Compacted,I@4}
        add3 (16|M0)             r2.0<1>:d     r10.0<1;0>:d      r14.0<1;0>:d      r2.0<1>:d        {I@1}
        send.ugm (16|M0)         r34      r2      null:0  a0.0        0x24280500           {ExBSO,A@1,$4} // wr:2+0, rd:2; load.ugm.d32.a32.ca.ca.bss[a0.0]
(W)     mov (1|M0)               r5.1<1>:f     inf:f                               {Compacted}
(W)     mov (1|M0)               r5.0<1>:d     -1:w                              
(W)     mov (1|M0)               r5.2<1>:f     -0.0:f                               {Compacted}
        and (16|M0)              r16.0<1>:d    r34.0<1;1,0>:d    2147483647:d               {$4.dst}
        sel (16|M0)   (lt)f0.0   r46.0<1>:f    r16.0<1;1,0>:f    448.0:f               {Compacted,I@1}
        shr (16|M0)              r58.0<1>:ud   r46.0<1;1,0>:ud   23:w               {F@1}
        and (16|M0)   (ne)f1.1   r84.0<1>:d    r46.0<1;1,0>:d    8388607:d              
        and (16|M0)              r78.0<1>:d    r58.0<1;1,0>:d    255:w               {Compacted,I@2}
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r78.0<1;1,0>:d    255:w               {I@1}
        sel (16|M0)   (ge)f0.0   r12.0<1>:ud   r78.0<1;1,0>:ud   0x79:uw             
        shl (16|M0)              r38.0<1>:d    r12.0<1;1,0>:d    23:w               {Compacted,I@1}
(~f1.1) goto (16|M0)                         L1216                  L1216                
L1184:
        mov (16|M0)              r72.0<1>:ud   0x7FC00000:ud                             
        goto (16|M0)                         L1216                  L7112                
L1216:
        join (16|M0)                         L7112                                
L1232:
        cmp (16|M0)   (eq)f1.0   null<1>:d     r84.0<1;1,0>:d    0:w              
        add (16|M0)              r30.0<1>:d    -r38.0<1;1,0>:d   -2139095040:d               {I@6}
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r78.0<1;1,0>:d    255:w              
        xor (16|M0)              r42.0<1>:d    r30.0<1;1,0>:d    r46.0<1;1,0>:d   {Compacted,I@2}
(f1.0)  goto (16|M0)                         L7080                  L7080                
L1304:
        or (16|M0)    (eq)f0.1   null<1>:d     r78.0<1;1,0>:d    r84.0<1;1,0>:d  
(~f0.1) goto (16|M0)                         L1368                  L1368                
L1336:
        mov (16|M0)              r72.0<1>:ud   0x0:ud                             
        goto (16|M0)                         L1368                  L7112                
L1368:
        join (16|M0)                         L7080                                
L1384:
        cmp (16|M0)   (eq)f0.1   null<1>:d     r78.0<1;1,0>:d    0:w              
        shr (16|M0)              r14.0<1>:ud   r30.0<1;1,0>:ud   23:w              
        add (16|M0)              r52.0<1>:d    r78.0<1;1,0>:d    -127:w               {Compacted}
(f0.1)  mov (16|M0)              r52.0<1>:d    -126:w                              
        add (16|M0)              r54.0<1>:d    r14.0<1;1,0>:d    r52.0<1;1,0>:d   {Compacted,I@1}
        cmp (16|M0)   (gt)f0.0   null<1>:d     r54.0<1;1,0>:d    254:w               {Compacted,I@1}
(f0.0)  goto (16|M0)                         L7016                  L7016                
L1472:
        or (16|M0)    (eq)f1.1   null<4>:b     r58.0<1;1,0>:d    r14.0<1;1,0>:d  
(f1.1)  goto (16|M0)                         L6952                  L6952                
L1504:
(W)     mov (1|M0)               r2.0<1>:hf    0.0:hf                             
(W)     mov (1|M0)               r6.1<1>:d     0:w                              
(f0.1)  sel (16|M0)              r8.0<1>:d     r2.0<0;1,0>:w     8388608:d               {F@1}
        or (16|M0)               r8.0<1>:d     r8.0<1;1,0>:d     r84.0<1;1,0>:d   {Compacted,I@1}
        shl (16|M0)              r46.0<1>:d    r8.0<1;1,0>:d     23:w               {Compacted,I@1}
        shr (16|M0)              r50.0<1>:ud   r8.0<1;1,0>:ud    9:w              
(W)     mov (1|M0)               r5.7<1>:f     -0.0:f                               {Compacted}
(W)     mov (2|M0)               r5.4<1>:d     0:w                              
L1608:
(W)     shl (1|M0)               r2.0<1>:d     r5.7<0;1,0>:d     31:w               {Compacted,F@1}
(W)     shr (1|M0)               r2.1<1>:ud    r6.1<0;1,0>:ud    1:w              
(W)     cmp (16|M0)   (gt)f0.0   null<1>:d     r5.4<0;1,0>:ud    0x3E:uw              {I@3}
(W)     or (1|M0)                r6.1<1>:d     r2.1<0;1,0>:d     r2.0<0;1,0>:d    {Compacted,I@2}
        bfn.0xE0 (16|M0)         r8.0<1>:ud    r2.1<0;0>:ud      r2.0<0;0>:ud      r46.0<1>:ud      // (s0|s1)&s2
(W)     shr (1|M0)               r5.3<1>:ud    r5.7<0;1,0>:ud    1:w              
(W&f0.0) cmp (16|M0)  (eq)f0.0   null<1>:d     r5.5<0;1,0>:d     0:w              
        cmp (16|M0)   (eq)f1.0   null<1>:d     r8.0<1;1,0>:d     r6.1<0;1,0>:d    {I@3}
        and (16|M0)              r10.0<1>:d    r5.3<0;1,0>:d     r50.0<1;1,0>:d   {Compacted,I@3}
(W&~f0.0) cmp (16|M0) (gt)f0.0   null<1>:d     r5.5<0;1,0>:ud    0x0:uw             
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r10.0<1;1,0>:d    r5.3<0;1,0>:d    {I@2}
(W)     mov (1|M0)               r4.12<1>:hf   0x1:hf                             
(W)     addc (1|M0)              r13.0<1>:ud   r5.4<0;1,0>:ud    0x1:ud              {AccWrEn}
(f0.0)  sel (16|M0)              r7.0<1>:uw    r4.12<0;1,0>:uw   0x0:uw              {Compacted,F@1}
(f1.0)  sel (16|M0)              acc2.0<1>:uw  r4.12<0;1,0>:uw   0x0:uw             
(W)     mov (1|M0)               r3.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        or (16|M0)    (ne)f0.0   null<1>:uw    r7.0<1;1,0>:uw    acc2.0<1;1,0>:uw {I@3}
(W)     add (1|M0)               r6.2<1>:ud    r3.0<0;1,0>:ud    r5.5<0;1,0>:ud   {I@2}
        mov (16|M0)              r86.0<1>:d    r5.4<0;1,0>:d                   
        mov (16|M0)              r84.0<1>:d    r5.5<0;1,0>:d                   
        mov (16|M0)              r66.0<1>:f    r13.0<0;1,0>:f                   {Compacted}
        mov (16|M0)              r96.0<1>:d    r6.2<0;1,0>:d                    {I@3}
(f0.0)  goto (16|M0)                         L1992                  L1992                
L1928:
(W)     mov (1|M0)               r5.7<1>:d     r5.3<0;1,0>:d                   
(W)     mov (1|M0)               r5.4<1>:d     r13.0<0;1,0>:d                  
(W)     mov (1|M0)               r5.5<1>:d     r6.2<0;1,0>:d                   
(W)     jmpi                                 L1608                                
L1992:
        join (16|M0)                         L6952                                
L2008:
(W)     mov (1|M0)               r2.0<1>:f     8.68805e-44:f                              
(W)     mov (1|M0)               r3.0<1>:hf    0.0:hf                             
        subb (8|M0)              r56.0<1>:ud   r2.0<0;1,0>:ud    r86.0<1;1,0>:ud  {AccWrEn,Compacted,A@2}
        add3 (8|M0)              r74.0<1>:ud   -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r84.0<1>:ud     {A@1}
        subb (8|M8)              r57.0<1>:ud   r2.0<0;1,0>:ud    r87.0<1;1,0>:ud  {AccWrEn}
        add3 (16|M0)             r10.0<1>:d    r54.0<1;0>:d      r56.0<1;0>:d      -173:w               {I@1}
        cmp (16|M0)   (gt)f1.0   null<1>:d     r10.0<1;1,0>:d    127:w               {I@1}
        add3 (8|M8)              r75.0<1>:ud   -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r85.0<1>:ud    
        add3 (16|M0)             r72.0<1>:d    r14.0<1;0>:d      r52.0<1;0>:d      r56.0<1>:d      
(f1.0)  goto (16|M0)                         L6896                  L6896                
L2160:
        cmp (16|M0)   (gt)f0.1   null<1>:d     r10.0<1;1,0>:d    -127:w              
(f0.1)  goto (16|M0)                         L4592                  L4592                
L2192:
        cmp (16|M0)   (lt)f0.0   null<1>:d     r10.0<1;1,0>:ud   0xFFFFFF6B:ud             
(f0.0)  goto (16|M0)                         L4096                  L4096                
L2224:
(W)     mov (1|M0)               r2.0<1>:f     8.82818e-44:f                              
(W)     mov (1|M0)               r3.0<1>:hf    0.0:hf                              {I@7}
        subb (8|M0)              r90.0<1>:ud   r2.0<0;1,0>:ud    r86.0<1;1,0>:ud  {AccWrEn,Compacted,F@2}
        add3 (16|M0)             r114.0<1>:d   r54.0<1;0>:d      r56.0<1;0>:d      -23:w              
        add3 (8|M0)              r8.0<1>:ud    -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r84.0<1>:ud     {F@1}
        subb (8|M8)              r91.0<1>:ud   r2.0<0;1,0>:ud    r87.0<1;1,0>:ud  {AccWrEn}
        cmp (16|M0)   (gt)f0.1   null<1>:d     r90.0<1;1,0>:ud   r114.0<1;1,0>:ud {I@1}
        add3 (8|M8)              r9.0<1>:ud    -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r85.0<1>:ud    
(f0.1)  cmp (16|M0)   (eq)f0.1   null<1>:d     r8.0<1;1,0>:d     0:w               {I@1}
(~f0.1) cmp (16|M0)   (gt)f0.1   null<1>:d     r8.0<1;1,0>:ud    0x0:uw             
(f0.1)  goto (16|M0)                         L2448                  L2448                
L2392:
        add3 (16|M0)             r2.0<1>:d     r72.0<1;0>:d      -r90.0<1;0>:d     -23:w              
        mov (16|M0)              r26.0<1>:d    0:w                              
        shl (16|M0)              r28.0<1>:d    r46.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
        goto (16|M0)                         L2448                  L4032                
L2448:
        join (16|M0)                         L4032                                
L2464:
        add3 (16|M0)             r16.0<1>:d    r90.0<1;0>:d      -r72.0<1;0>:d     23:w              
        cmp (16|M0)   (lt)f1.1   null<1>:d     r16.0<1;1,0>:d    2:w               {I@1}
(f1.1)  goto (16|M0)                         L2616                  L2616                
L2512:
        cmp (16|M0)   (eq)f1.0   null<1>:d     r16.0<1;1,0>:d    2:w              
(~f1.0) goto (16|M0)                         L2616                  L2720                
L2544:
        shr (16|M0)              r68.0<1>:ud   r46.0<1;1,0>:ud   1:w              
        mov (16|M0)              r110.0<1>:d   0:w                              
        mov (16|M0)              r122.0<1>:d   0:w                              
        mov (16|M0)              r106.0<1>:f   r68.0<1;1,0>:f                   {Compacted,I@3}
        goto (16|M0)                         L2616                  L3520                
L2616:
        join (16|M0)                         L2720                                
L2632:
        cmp (16|M0)   (eq)f0.1   null<1>:d     r16.0<1;1,0>:d    1:w              
(~f0.1) goto (16|M0)                         L2720                  L2720                
L2664:
        mov (16|M0)              r110.0<1>:d   0:w                              
        mov (16|M0)              r122.0<1>:d   0:w                              
        mov (16|M0)              r106.0<1>:f   r46.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L2720                  L3520                
L2720:
        join (16|M0)                         L3520                                
L2736:
        add3 (16|M0)             r2.0<1>:d     r90.0<1;0>:d      -r114.0<1;0>:d    -1:w              
        and (16|M0)   (ne)f0.0   r108.0<1>:d   r2.0<1;1,0>:d     63:w               {Compacted,I@1}
(f0.0)  goto (16|M0)                         L2800                  L2800                
L2776:
        mov (16|M0)              r80.0<1>:f    r46.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L2800                  L2912                
L2800:
        join (16|M0)                         L2912                                
L2816:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r108.0<1;1,0>:ud  0x20:uw              {I@4}
(~f1.1) add (16|M0)              r2.0<1>:d     r108.0<1;1,0>:d   -32:w              
(~f1.1) shr (16|M0)              r68.0<1>:ud   r50.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.1)  add (16|M0)              r2.0<1>:d     -r108.0<1;1,0>:d  32:w               {Compacted}
(f1.1)  shr (16|M0)              r8.0<1>:ud    r46.0<1;1,0>:ud   r108.0<1;1,0>:d 
(f1.1)  shl (16|M0)              r2.0<1>:d     r50.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.1)  or (16|M0)               r68.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
        mov (16|M0)              r80.0<1>:f    r68.0<1;1,0>:f                   {Compacted,I@1}
L2912:
        join (16|M0)                         L3520                                
L2928:
        add3 (16|M0)             r60.0<1>:d    r90.0<1;0>:d      -r114.0<1;0>:d    -2:w              
        and (16|M0)   (ne)f1.0   r106.0<1>:d   r60.0<1;1,0>:d    63:w               {A@1}
(f1.0)  goto (16|M0)                         L3000                  L3000                
L2976:
        mov (16|M0)              r68.0<1>:f    r46.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L3000                  L3104                
L3000:
        join (16|M0)                         L3104                                
L3016:
        cmp (16|M0)   (lt)f0.1   null<1>:d     r106.0<1;1,0>:ud  0x20:uw              {I@4}
(~f0.1) add (16|M0)              r2.0<1>:d     r106.0<1;1,0>:d   -32:w              
(~f0.1) shr (16|M0)              r68.0<1>:ud   r50.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f0.1)  add (16|M0)              r2.0<1>:d     -r106.0<1;1,0>:d  32:w               {Compacted}
(f0.1)  shr (16|M0)              r8.0<1>:ud    r46.0<1;1,0>:ud   r106.0<1;1,0>:d 
(f0.1)  shl (16|M0)              r2.0<1>:d     r50.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f0.1)  or (16|M0)               r68.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
L3104:
        join (16|M0)                         L3520                                
L3120:
        and (16|M0)   (ne)f0.0   r70.0<1>:d    r60.0<1;1,0>:d    63:w               {Compacted}
        and (16|M0)              r122.0<1>:d   r68.0<1;1,0>:d    1:w               {Compacted,I@3}
(f0.0)  goto (16|M0)                         L3200                  L3200                
L3152:
        mov (16|M0)              r74.0<1>:d    -1:w                              
        mov (16|M0)              r78.0<1>:d    -1:w                              
        goto (16|M0)                         L3200                  L3384                
L3200:
        join (16|M0)                         L3384                                
L3216:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r70.0<1;1,0>:ud   0x20:uw              {I@7}
(f1.1)  goto (16|M0)                         L3320                  L3320                
L3248:
        add (16|M0)              r2.0<1>:d     r70.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r4.12<1>:hf   -qnan(0x1FF):hf                             
        mov (16|M0)              r74.0<1>:d    0:w                              
        shl (16|M0)              r78.0<1>:d    r4.12<0;1,0>:w    r2.0<1;1,0>:d    {A@1}
        goto (16|M0)                         L3320                  L3384                
L3320:
        join (16|M0)                         L3384                                
L3336:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (16|M0)              r78.0<1>:d    -1:w                              
        shl (16|M0)              r74.0<1>:d    r2.0<0;1,0>:w     r70.0<1;1,0>:d   {F@1}
L3384:
        join (16|M0)                         L3520                                
L3400:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r74.0<1;0>:ud     r5.0<0;0>:ud      r46.0<1>:ud      {I@2} // (s0^s1)&s2
        cmp (16|M0)   (ne)f0.1   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
        bfn.0x60 (16|M0)         r8.0<1>:ud    r78.0<1;0>:ud     r5.0<0;0>:ud      r50.0<1>:ud      // (s0^s1)&s2
(~f0.1) cmp (16|M0)   (ne)f0.1   null<1>:d     r8.0<1;1,0>:d     0:w               {I@1}
(W)     mov (1|M0)               r4.12<1>:hf   -qnan(0x1FF):hf                             
        mov (16|M0)              r106.0<1>:f   r80.0<1;1,0>:f                   {Compacted}
(f0.1)  sel (16|M0)              r10.0<1>:d    r4.12<0;1,0>:w    0:w               {F@2}
        mov (16|M0)              r110.0<1>:d   -r10.0<1;1,0>:d                  {I@1}
L3520:
        join (16|M0)                         L4032                                
L3536:
        and (16|M0)   (ne)f1.0   r104.0<1>:d   r16.0<1;1,0>:d    63:w              
(f1.0)  goto (16|M0)                         L3592                  L3592                
L3568:
        mov (16|M0)              r68.0<1>:f    r46.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L3592                  L3696                
L3592:
        join (16|M0)                         L3696                                
L3608:
        cmp (16|M0)   (lt)f0.1   null<1>:d     r104.0<1;1,0>:ud  0x20:uw              {I@4}
(~f0.1) add (16|M0)              r2.0<1>:d     r104.0<1;1,0>:d   -32:w              
(~f0.1) shr (16|M0)              r68.0<1>:ud   r50.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f0.1)  add (16|M0)              r2.0<1>:d     -r104.0<1;1,0>:d  32:w               {Compacted}
(f0.1)  shr (16|M0)              r8.0<1>:ud    r46.0<1;1,0>:ud   r104.0<1;1,0>:d 
(f0.1)  shl (16|M0)              r2.0<1>:d     r50.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f0.1)  or (16|M0)               r68.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
L3696:
        join (16|M0)                         L4032                                
L3712:
        shl (16|M0)              r2.0<1>:d     r106.0<1;1,0>:d   2:w               {Compacted}
        shl (16|M0)              r8.0<1>:d     r122.0<1;1,0>:d   1:w               {Compacted}
        and (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     4:w               {Compacted,I@2}
        bfn.0xFE (16|M0)         r14.0<1>:ud   r2.0<1;0>:ud      r8.0<1;0>:ud      r110.0<1>:ud     {I@1} // s0|s1|s2
        cmp (16|M0)   (eq)f0.0   null<1>:d     r14.0<1;1,0>:d    0:w               {Compacted,I@1}
(~f0.0) goto (16|M0)                         L3808                  L3808                
L3776:
        mov (16|M0)              r20.0<1>:d    0:w                              
        goto (16|M0)                         L3808                  L3960                
L3808:
        join (16|M0)                         L3960                                
L3824:
        cmp (16|M0)   (gt)f1.1   null<1>:d     r14.0<1;1,0>:ud   0x4:uw             
(~f1.1) goto (16|M0)                         L3888                  L3888                
L3856:
        mov (16|M0)              r20.0<1>:d    1:w                              
        goto (16|M0)                         L3888                  L3960                
L3888:
        join (16|M0)                         L3960                                
L3904:
        and (16|M0)   (ne)f0.0   null<1>:d     r68.0<1;1,0>:d    1:w               {Compacted}
(W)     mov (1|M0)               r2.0<1>:hf    0x1:hf                             
(f0.0)  cmp (16|M0)   (eq)f0.0   null<1>:d     r14.0<1;1,0>:d    4:w              
(f0.0)  sel (16|M0)              r20.0<1>:d    r2.0<0;1,0>:w     0:w               {F@1}
L3960:
        join (16|M0)                         L4032                                
L3976:
        add (16|M0)              r2.0<1>:d     r20.0<1;1,0>:d    r68.0<1;1,0>:d   {Compacted,I@2}
        cmp (16|M0)   (gt)f0.1   null<1>:d     r2.0<1;1,0>:ud    0x7FFFFF:ud              {I@1}
(W)     mov (1|M0)               r4.6<1>:f     0x800000:f                               {Compacted}
(~f0.1) sel (16|M0)              r28.0<1>:d    r2.0<1;1,0>:d     0:w              
(f0.1)  sel (16|M0)              r26.0<1>:d    r4.6<0;1,0>:d     0:w               {Compacted,F@1}
L4032:
        join (16|M0)                         L4096                                
L4048:
        and (16|M0)              r2.0<1>:d     r42.0<1;1,0>:d    -2147483648:d              
        bfn.0xFE (16|M0)         r72.0<1>:ud   r2.0<1;0>:ud      r26.0<1;0>:ud     r28.0<1>:ud      {I@1} // s0|s1|s2
        goto (16|M0)                         L4096                  L7112                
L4096:
        join (16|M0)                         L4592                                
L4112:
        and (16|M0)   (ne)f1.0   r44.0<1>:d    r56.0<1;1,0>:d    63:w              
(f1.0)  goto (16|M0)                         L4192                  L4192                
L4144:
        mov (16|M0)              r64.0<1>:d    -1:w                              
        mov (16|M0)              r68.0<1>:d    -1:w                              
        goto (16|M0)                         L4192                  L4376                
L4192:
        join (16|M0)                         L4376                                
L4208:
        cmp (16|M0)   (lt)f0.1   null<1>:d     r44.0<1;1,0>:ud   0x20:uw              {I@6}
(f0.1)  goto (16|M0)                         L4312                  L4312                
L4240:
        add (16|M0)              r2.0<1>:d     r44.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r4.12<1>:hf   -qnan(0x1FF):hf                             
        mov (16|M0)              r64.0<1>:d    0:w                              
        shl (16|M0)              r68.0<1>:d    r4.12<0;1,0>:w    r2.0<1;1,0>:d    {A@1}
        goto (16|M0)                         L4312                  L4376                
L4312:
        join (16|M0)                         L4376                                
L4328:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (16|M0)              r68.0<1>:d    -1:w                              
        shl (16|M0)              r64.0<1>:d    r2.0<0;1,0>:w     r44.0<1;1,0>:d   {F@1}
L4376:
        join (16|M0)                         L4592                                
L4392:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r64.0<1;0>:ud     r5.0<0;0>:ud      r46.0<1>:ud      {I@2} // (s0^s1)&s2
        cmp (16|M0)   (ne)f0.1   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
        bfn.0x60 (16|M0)         r8.0<1>:ud    r68.0<1;0>:ud     r5.0<0;0>:ud      r50.0<1>:ud      // (s0^s1)&s2
        cmp (16|M0)   (gt)f0.0   null<1>:d     r42.0<1;1,0>:d    -1:w               {Compacted}
(~f0.1) cmp (16|M0)   (ne)f0.1   null<1>:d     r8.0<1;1,0>:d     0:w               {I@2}
(f0.1)  cmp (16|M0)   (eq)f0.1   null<1>:d     r10.0<1;1,0>:d    -150:w              
(f0.0)  goto (16|M0)                         L4536                  L4536                
L4496:
(W)     mov (1|M0)               r2.0<1>:ud    0x80000001:ud                             
(f0.1)  sel (16|M0)              r72.0<1>:f    r2.0<0;1,0>:f     -0.0:f               {Compacted,I@1}
        goto (16|M0)                         L4536                  L7112                
L4536:
        join (16|M0)                         L4592                                
L4552:
(W)     mov (1|M0)               r2.0<1>:ud    0x1:ud                              {F@1}
(f0.1)  sel (16|M0)              r72.0<1>:f    r2.0<0;1,0>:f     0.0:f               {Compacted,I@1}
        goto (16|M0)                         L4592                  L7112                
L4592:
        join (16|M0)                         L6896                                
L4608:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r56.0<1;1,0>:ud   0x18:uw             
        add3 (16|M0)             r64.0<1>:d    r54.0<1;0>:d      r56.0<1;0>:d      -46:w              
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r74.0<1;1,0>:d    0:w              
(f1.1)  goto (16|M0)                         L6592                  L6592                
L4672:
        shl (16|M0)              r2.0<1>:d     r66.0<1;1,0>:d    1:w               {Compacted,F@1}
        shr (16|M0)              r8.0<1>:ud    r66.0<1;1,0>:ud   31:w              
        shl (16|M0)              r10.0<1>:d    r96.0<1;1,0>:d    1:w               {Compacted}
        cmp (16|M0)   (lt)f0.0   null<1>:d     r2.0<1;1,0>:ud    0x4E:uw              {I@3}
        or (16|M0)               r10.0<1>:d    r10.0<1;1,0>:d    r8.0<1;1,0>:d    {Compacted,I@2}
(f0.0)  cmp (16|M0)   (eq)f0.0   null<1>:d     r10.0<1;1,0>:d    0:w               {I@1}
(~f0.0) cmp (16|M0)   (lt)f0.0   null<1>:d     r10.0<1;1,0>:d    0:w              
(f0.0)  goto (16|M0)                         L4904                  L4904                
L4776:
        cmp (16|M0)   (eq)f1.0   null<1>:d     r66.0<1;1,0>:d    39:w              
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r96.0<1;1,0>:d    0:w              
(~f1.0) goto (16|M0)                         L4904                  L4968                
L4824:
        shr (16|M0)              r68.0<1>:ud   r46.0<1;1,0>:ud   1:w              
        mov (16|M0)              r120.0<1>:d   0:w                              
        mov (16|M0)              r126.0<1>:d   0:w                              
        mov (16|M0)              r124.0<1>:f   r68.0<1;1,0>:f                   {Compacted,I@3}
        mov (16|M0)              r68.0<1>:f    r46.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L4904                  L6064                
L4904:
        join (16|M0)                         L4968                                
L4920:
        cmp (16|M0)   (eq)f0.1   null<1>:d     r66.0<1;1,0>:d    38:w              
(f0.1)  cmp (16|M0)   (eq)f0.1   null<1>:d     r96.0<1;1,0>:d    0:w              
(f0.1)  goto (16|M0)                         L4968                  L5976                
L4968:
        join (16|M0)                         L5976                                
L4984:
        add (16|M0)              r2.0<1>:d     -r66.0<1;1,0>:d   39:w               {Compacted}
        and (16|M0)   (ne)f1.1   r116.0<1>:d   r2.0<1;1,0>:d     63:w               {I@1}
        add (16|M0)              r98.0<1>:d    -r66.0<1;1,0>:d   40:w               {Compacted}
(f1.1)  goto (16|M0)                         L5056                  L5056                
L5032:
        mov (16|M0)              r86.0<1>:f    r46.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L5056                  L5168                
L5056:
        join (16|M0)                         L5168                                
L5072:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r116.0<1;1,0>:ud  0x20:uw              {I@5}
(~f1.0) add (16|M0)              r2.0<1>:d     r116.0<1;1,0>:d   -32:w              
(~f1.0) shr (16|M0)              r68.0<1>:ud   r50.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.0)  add (16|M0)              r2.0<1>:d     -r116.0<1;1,0>:d  32:w               {Compacted}
(f1.0)  shr (16|M0)              r8.0<1>:ud    r46.0<1;1,0>:ud   r116.0<1;1,0>:d 
(f1.0)  shl (16|M0)              r2.0<1>:d     r50.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.0)  or (16|M0)               r68.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
        mov (16|M0)              r86.0<1>:f    r68.0<1;1,0>:f                   {Compacted,I@1}
L5168:
        join (16|M0)                         L5976                                
L5184:
        add (16|M0)              r66.0<1>:d    -r66.0<1;1,0>:d   38:w               {Compacted}
        and (16|M0)   (ne)f0.1   r120.0<1>:d   r66.0<1;1,0>:d    63:w               {I@1}
(f0.1)  goto (16|M0)                         L5248                  L5248                
L5224:
        mov (16|M0)              r68.0<1>:f    r46.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L5248                  L5352                
L5248:
        join (16|M0)                         L5352                                
L5264:
        cmp (16|M0)   (lt)f0.0   null<1>:d     r120.0<1;1,0>:ud  0x20:uw              {I@4}
(~f0.0) add (16|M0)              r2.0<1>:d     r120.0<1;1,0>:d   -32:w              
(~f0.0) shr (16|M0)              r68.0<1>:ud   r50.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f0.0)  add (16|M0)              r2.0<1>:d     -r120.0<1;1,0>:d  32:w               {Compacted}
(f0.0)  shr (16|M0)              r8.0<1>:ud    r46.0<1;1,0>:ud   r120.0<1;1,0>:d 
(f0.0)  shl (16|M0)              r2.0<1>:d     r50.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f0.0)  or (16|M0)               r68.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
L5352:
        join (16|M0)                         L5976                                
L5368:
        and (16|M0)   (ne)f1.1   r82.0<1>:d    r66.0<1;1,0>:d    63:w              
        and (16|M0)              r126.0<1>:d   r68.0<1;1,0>:d    1:w               {Compacted,I@3}
(f1.1)  goto (16|M0)                         L5456                  L5456                
L5408:
        mov (16|M0)              r96.0<1>:d    -1:w                              
        mov (16|M0)              r102.0<1>:d   -1:w                              
        goto (16|M0)                         L5456                  L5640                
L5456:
        join (16|M0)                         L5640                                
L5472:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r82.0<1;1,0>:ud   0x20:uw              {I@7}
(f1.0)  goto (16|M0)                         L5576                  L5576                
L5504:
        add (16|M0)              r2.0<1>:d     r82.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r4.12<1>:hf   -qnan(0x1FF):hf                             
        mov (16|M0)              r96.0<1>:d    0:w                              
        shl (16|M0)              r102.0<1>:d   r4.12<0;1,0>:w    r2.0<1;1,0>:d    {A@1}
        goto (16|M0)                         L5576                  L5640                
L5576:
        join (16|M0)                         L5640                                
L5592:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (16|M0)              r102.0<1>:d   -1:w                              
        shl (16|M0)              r96.0<1>:d    r2.0<0;1,0>:w     r82.0<1;1,0>:d   {F@1}
L5640:
        join (16|M0)                         L5976                                
L5656:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r96.0<1;0>:ud     r5.0<0;0>:ud      r46.0<1>:ud      {I@2} // (s0^s1)&s2
        cmp (16|M0)   (ne)f0.0   null<1>:d     r2.0<1;1,0>:d     0:w               {Compacted,I@1}
        bfn.0x60 (16|M0)         r8.0<1>:ud    r102.0<1;0>:ud    r5.0<0;0>:ud      r50.0<1>:ud      // (s0^s1)&s2
(~f0.0) cmp (16|M0)   (ne)f0.0   null<1>:d     r8.0<1;1,0>:d     0:w               {I@1}
(W)     mov (1|M0)               r4.12<1>:hf   -qnan(0x1FF):hf                             
        and (16|M0)   (ne)f0.1   r118.0<1>:d   r98.0<1;1,0>:d    63:w              
(f0.0)  sel (16|M0)              r10.0<1>:d    r4.12<0;1,0>:w    0:w               {F@1}
        mov (16|M0)              r120.0<1>:d   -r10.0<1;1,0>:d                  {I@1}
(f0.1)  goto (16|M0)                         L5816                  L5816                
L5792:
        mov (16|M0)              r68.0<1>:f    r46.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L5816                  L5920                
L5816:
        join (16|M0)                         L5920                                
L5832:
        cmp (16|M0)   (lt)f0.0   null<1>:d     r118.0<1;1,0>:ud  0x20:uw             
(~f0.0) add (16|M0)              r2.0<1>:d     r118.0<1;1,0>:d   -32:w              
(~f0.0) shr (16|M0)              r68.0<1>:ud   r50.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f0.0)  add (16|M0)              r2.0<1>:d     -r118.0<1;1,0>:d  32:w               {Compacted}
(f0.0)  shr (16|M0)              r8.0<1>:ud    r46.0<1;1,0>:ud   r118.0<1;1,0>:d 
(f0.0)  shl (16|M0)              r2.0<1>:d     r50.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f0.0)  or (16|M0)               r68.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
L5920:
        join (16|M0)                         L5976                                
L5936:
        mov (16|M0)              r124.0<1>:f   r68.0<1;1,0>:f                   {Compacted,I@2}
        mov (16|M0)              r68.0<1>:d    r86.0<1;1,0>:d                   {F@1}
        goto (16|M0)                         L5976                  L6064                
L5976:
        join (16|M0)                         L6064                                
L5992:
        shr (16|M0)              r68.0<1>:ud   r46.0<1;1,0>:ud   2:w              
        mov (16|M0)              r120.0<1>:d   0:w                              
        mov (16|M0)              r126.0<1>:d   0:w                              
        mov (16|M0)              r124.0<1>:f   r68.0<1;1,0>:f                   {Compacted,I@3}
        shr (16|M0)              r68.0<1>:ud   r46.0<1;1,0>:ud   1:w               {F@1}
L6064:
        join (16|M0)                         L6592                                
L6080:
        shl (16|M0)              r2.0<1>:d     r68.0<1;1,0>:d    2:w               {Compacted,I@2}
        shl (16|M0)              r8.0<1>:d     r126.0<1;1,0>:d   1:w               {Compacted}
        and (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     4:w               {Compacted,I@2}
        bfn.0xFE (16|M0)         r62.0<1>:ud   r2.0<1;0>:ud      r8.0<1;0>:ud      r120.0<1>:ud     {I@1} // s0|s1|s2
        cmp (16|M0)   (eq)f1.1   null<1>:d     r62.0<1;1,0>:d    0:w               {I@1}
        and (16|M0)              r92.0<1>:d    r124.0<1;1,0>:d   8388607:d              
(~f1.1) goto (16|M0)                         L6200                  L6200                
L6168:
        mov (16|M0)              r40.0<1>:d    0:w                              
        goto (16|M0)                         L6200                  L6360                
L6200:
        join (16|M0)                         L6360                                
L6216:
        cmp (16|M0)   (gt)f1.0   null<1>:d     r62.0<1;1,0>:ud   0x4:uw             
(~f1.0) goto (16|M0)                         L6280                  L6280                
L6248:
        mov (16|M0)              r40.0<1>:d    1:w                              
        goto (16|M0)                         L6280                  L6360                
L6280:
        join (16|M0)                         L6360                                
L6296:
        and (16|M0)   (ne)f1.1   null<1>:d     r124.0<1;1,0>:d   1:w              
(W)     mov (1|M0)               r2.0<1>:hf    0x1:hf                             
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r62.0<1;1,0>:d    4:w              
(f1.1)  sel (16|M0)              r40.0<1>:d    r2.0<0;1,0>:w     0:w               {F@1}
L6360:
        join (16|M0)                         L6592                                
L6376:
        add (16|M0)              r44.0<1>:d    r92.0<1;1,0>:d    r40.0<1;1,0>:d   {Compacted,I@2}
        cmp (16|M0)   (gt)f1.1   null<1>:d     r44.0<1;1,0>:ud   0x7FFFFF:ud              {I@1}
        add3 (16|M0)             r2.0<1>:d     r54.0<1;0>:d      r56.0<1;0>:d      -45:w              
(f1.1)  sel (16|M0)              r40.0<1>:d    r2.0<1;1,0>:d     r64.0<1;1,0>:d   {Compacted,I@1}
        cmp (16|M0)   (eq)f0.1   null<1>:d     r40.0<1;1,0>:d    255:w               {I@1}
(f0.1)  goto (16|M0)                         L6528                  L6528                
L6456:
(~f1.1) sel (16|M0)              r2.0<1>:d     r44.0<1;1,0>:d    0:w              
        and (16|M0)              r8.0<1>:d     r42.0<1;1,0>:d    -2147483648:d              
        shl (16|M0)              r10.0<1>:d    r40.0<1;1,0>:d    23:w               {Compacted}
        bfn.0xFE (16|M0)         r72.0<1>:ud   r8.0<1;0>:ud      r10.0<1;0>:ud     r2.0<1>:ud       {I@1} // s0|s1|s2
        goto (16|M0)                         L6528                  L7112                
L6528:
        join (16|M0)                         L6592                                
L6544:
        cmp (16|M0)   (gt)f0.1   null<1>:d     r42.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r2.0<1>:f     inf:f                               {Compacted,I@4}
(f0.1)  sel (16|M0)              r72.0<1>:f    r2.0<0;1,0>:f     -inf:f               {Compacted,F@1}
        goto (16|M0)                         L6592                  L7112                
L6592:
        join (16|M0)                         L6896                                
L6608:
        and (16|M0)   (ne)f0.0   r24.0<1>:d    r56.0<1;1,0>:d    63:w               {Compacted}
(f0.0)  goto (16|M0)                         L6664                  L6664                
L6632:
        mov (16|M0)              r28.0<1>:d    -1:w                              
        goto (16|M0)                         L6664                  L6792                
L6664:
        join (16|M0)                         L6792                                
L6680:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r24.0<1;1,0>:ud   0x20:uw              {I@5}
(f1.1)  goto (16|M0)                         L6744                  L6744                
L6712:
        mov (16|M0)              r28.0<1>:d    0:w                              
        goto (16|M0)                         L6744                  L6792                
L6744:
        join (16|M0)                         L6792                                
L6760:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                             
        shl (16|M0)              r28.0<1>:d    r2.0<0;1,0>:w     r24.0<1;1,0>:d   {F@1}
L6792:
        join (16|M0)                         L6896                                
L6808:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r28.0<1;0>:ud     r5.0<0;0>:ud      r46.0<1>:ud      {I@2} // (s0^s1)&s2
        add (16|M0)              r8.0<1>:d     -r56.0<1;1,0>:d   23:w               {Compacted}
        and (16|M0)              r10.0<1>:d    r42.0<1;1,0>:d    -2147483648:d              
        shl (16|M0)              r12.0<1>:d    r64.0<1;1,0>:d    23:w               {Compacted}
        shl (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     r8.0<1;1,0>:d    {Compacted,I@3}
        bfn.0xFE (16|M0)         r72.0<1>:ud   r10.0<1;0>:ud     r12.0<1;0>:ud     r2.0<1>:ud       {I@1} // s0|s1|s2
        goto (16|M0)                         L6896                  L7112                
L6896:
        join (16|M0)                         L6952                                
L6912:
        cmp (16|M0)   (gt)f0.0   null<1>:d     r42.0<1;1,0>:d    -1:w               {Compacted}
(W)     mov (1|M0)               r2.0<1>:f     inf:f                               {Compacted,I@4}
(f0.0)  sel (16|M0)              r72.0<1>:f    r2.0<0;1,0>:f     -inf:f               {Compacted,F@1}
        goto (16|M0)                         L6952                  L7112                
L6952:
        join (16|M0)                         L7016                                
L6968:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r42.0<1;1,0>:d    0:w              
(W)     mov (1|M0)               r2.0<1>:f     -0.0:f                               {Compacted}
(f1.1)  sel (16|M0)              r72.0<1>:f    r2.0<0;1,0>:f     0.0:f               {Compacted,F@1}
        goto (16|M0)                         L7016                  L7112                
L7016:
        join (16|M0)                         L7080                                
L7032:
        cmp (16|M0)   (gt)f1.0   null<1>:d     r42.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r2.0<1>:f     inf:f                               {Compacted}
(f1.0)  sel (16|M0)              r72.0<1>:f    r2.0<0;1,0>:f     -inf:f               {Compacted,F@1}
        goto (16|M0)                         L7080                  L7112                
L7080:
        join (16|M0)                         L7112                                
L7096:
        bfn.0xF8 (16|M0)         r72.0<1>:ud   r42.0<1;0>:ud     r5.2<0;0>:ud      r5.1<0>:ud       {F@1} // s0&s1|s2
L7112:
        join (16|M0)                         L7128                                
L7128:
        rnde (16|M0)             r60.0<1>:f    r72.0<1;1,0>:f                   {Compacted,I@2}
        shr (16|M0)              r56.0<1>:ud   r60.0<1;1,0>:ud   23:w               {F@1}
        and (16|M0)   (ne)f1.0   r94.0<1>:d    r60.0<1;1,0>:d    8388607:d              
        and (16|M0)              r92.0<1>:d    r56.0<1;1,0>:d    255:w               {Compacted,I@2}
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r92.0<1;1,0>:d    255:w               {I@1}
(~f1.0) goto (16|M0)                         L7240                  L7240                
L7208:
        mov (16|M0)              r70.0<1>:ud   0x7FC00000:ud                             
        goto (16|M0)                         L7240                  L13184                
L7240:
        join (16|M0)                         L13184                                
L7256:
        cmp (16|M0)   (eq)f1.1   null<1>:d     r94.0<1;1,0>:d    0:w              
        add (16|M0)              r2.0<1>:d     r38.0<1;1,0>:d    -25165824:d              
        shr (16|M0)              r46.0<1>:ud   r2.0<1;1,0>:ud    23:w               {I@1}
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r92.0<1;1,0>:d    255:w              
        and (16|M0)              r54.0<1>:d    r46.0<1;1,0>:d    255:w               {Compacted,I@2}
(~f1.1) cmp (16|M0)   (eq)f1.1   null<1>:d     r54.0<1;1,0>:d    255:w               {I@1}
        xor (16|M0)              r40.0<1>:d    r2.0<1;1,0>:d     r60.0<1;1,0>:d   {Compacted}
(f1.1)  goto (16|M0)                         L13152                  L13152                
L7368:
        cmp (16|M0)   (eq)f0.1   null<1>:d     r54.0<1;1,0>:d    0:w              
        or (16|M0)               r2.0<1>:d     r92.0<1;1,0>:d    r94.0<1;1,0>:d   {Compacted}
(~f0.1) cmp (16|M0)   (eq)f0.1   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
(~f0.1) goto (16|M0)                         L7456                  L7456                
L7424:
        mov (16|M0)              r70.0<1>:ud   0x0:ud                             
        goto (16|M0)                         L7456                  L13184                
L7456:
        join (16|M0)                         L13152                                
L7472:
        cmp (16|M0)   (eq)f0.0   null<1>:d     r92.0<1;1,0>:d    0:w               {Compacted}
        add (16|M0)              r50.0<1>:d    r92.0<1;1,0>:d    -127:w               {Compacted}
(f0.0)  mov (16|M0)              r50.0<1>:d    -126:w                              
        add (16|M0)              r52.0<1>:d    r54.0<1;1,0>:d    r50.0<1;1,0>:d   {Compacted,I@1}
        cmp (16|M0)   (gt)f1.0   null<1>:d     r52.0<1;1,0>:d    254:w               {I@1}
(f1.0)  goto (16|M0)                         L13088                  L13088                
L7544:
        or (16|M0)    (eq)f0.1   null<4>:b     r56.0<1;1,0>:d    r46.0<1;1,0>:d  
(f0.1)  goto (16|M0)                         L13024                  L13024                
L7576:
(W)     mov (1|M0)               r2.0<1>:hf    0.0:hf                             
(W)     mov (1|M0)               r6.1<1>:d     0:w                              
(f0.0)  sel (16|M0)              r8.0<1>:d     r2.0<0;1,0>:w     8388608:d               {F@1}
        or (16|M0)               r8.0<1>:d     r8.0<1;1,0>:d     r94.0<1;1,0>:d   {Compacted,I@1}
        shl (16|M0)              r44.0<1>:d    r8.0<1;1,0>:d     23:w               {Compacted,I@1}
        shr (16|M0)              r48.0<1>:ud   r8.0<1;1,0>:ud    9:w              
(W)     mov (1|M0)               r5.7<1>:f     -0.0:f                               {Compacted}
(W)     mov (2|M0)               r5.4<1>:d     0:w                              
L7680:
(W)     shl (1|M0)               r2.0<1>:d     r5.7<0;1,0>:d     31:w               {Compacted,F@1}
(W)     shr (1|M0)               r2.1<1>:ud    r6.1<0;1,0>:ud    1:w              
(W)     cmp (16|M0)   (gt)f1.1   null<1>:d     r5.4<0;1,0>:ud    0x3E:uw              {I@3}
(W)     or (1|M0)                r6.1<1>:d     r2.1<0;1,0>:d     r2.0<0;1,0>:d    {Compacted,I@2}
        bfn.0xE0 (16|M0)         r8.0<1>:ud    r2.1<0;0>:ud      r2.0<0;0>:ud      r44.0<1>:ud      // (s0|s1)&s2
(W)     shr (1|M0)               r5.3<1>:ud    r5.7<0;1,0>:ud    1:w              
(W&f1.1) cmp (16|M0)  (eq)f1.1   null<1>:d     r5.5<0;1,0>:d     0:w              
        cmp (16|M0)   (eq)f0.1   null<1>:d     r8.0<1;1,0>:d     r6.1<0;1,0>:d    {I@3}
        and (16|M0)              r10.0<1>:d    r5.3<0;1,0>:d     r48.0<1;1,0>:d   {Compacted,I@3}
(W&~f1.1) cmp (16|M0) (gt)f1.1   null<1>:d     r5.5<0;1,0>:ud    0x0:uw             
(f0.1)  cmp (16|M0)   (eq)f0.1   null<1>:d     r10.0<1;1,0>:d    r5.3<0;1,0>:d    {I@2}
(W)     mov (1|M0)               r4.12<1>:hf   0x1:hf                             
(W)     addc (1|M0)              r13.0<1>:ud   r5.4<0;1,0>:ud    0x1:ud              {AccWrEn}
(f1.1)  sel (16|M0)              r7.0<1>:uw    r4.12<0;1,0>:uw   0x0:uw              {Compacted,F@1}
(f0.1)  sel (16|M0)              acc2.0<1>:uw  r4.12<0;1,0>:uw   0x0:uw             
(W)     mov (1|M0)               r3.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        or (16|M0)    (ne)f1.1   null<1>:uw    r7.0<1;1,0>:uw    acc2.0<1;1,0>:uw {I@3}
(W)     add (1|M0)               r6.2<1>:ud    r3.0<0;1,0>:ud    r5.5<0;1,0>:ud   {I@2}
        mov (16|M0)              r82.0<1>:d    r5.4<0;1,0>:d                   
        mov (16|M0)              r80.0<1>:d    r5.5<0;1,0>:d                   
        mov (16|M0)              r74.0<1>:f    r13.0<0;1,0>:f                   {Compacted}
        mov (16|M0)              r94.0<1>:d    r6.2<0;1,0>:d                    {I@3}
(f1.1)  goto (16|M0)                         L8064                  L8064                
L8000:
(W)     mov (1|M0)               r5.7<1>:d     r5.3<0;1,0>:d                   
(W)     mov (1|M0)               r5.4<1>:d     r13.0<0;1,0>:d                  
(W)     mov (1|M0)               r5.5<1>:d     r6.2<0;1,0>:d                   
(W)     jmpi                                 L7680                                
L8064:
        join (16|M0)                         L13024                                
L8080:
(W)     mov (1|M0)               r2.0<1>:f     8.68805e-44:f                              
(W)     mov (1|M0)               r3.0<1>:hf    0.0:hf                             
        subb (8|M0)              r58.0<1>:ud   r2.0<0;1,0>:ud    r82.0<1;1,0>:ud  {AccWrEn,Compacted,A@2}
        add3 (8|M0)              r70.0<1>:ud   -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r80.0<1>:ud     {A@1}
        subb (8|M8)              r59.0<1>:ud   r2.0<0;1,0>:ud    r83.0<1;1,0>:ud  {AccWrEn}
        add3 (16|M0)             r126.0<1>:d   r52.0<1;0>:d      r58.0<1;0>:d      -173:w               {I@1}
        cmp (16|M0)   (gt)f0.0   null<1>:d     r126.0<1;1,0>:d   127:w               {Compacted,I@1}
        add3 (8|M8)              r71.0<1>:ud   -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r81.0<1>:ud    
        add3 (16|M0)             r68.0<1>:d    r54.0<1;0>:d      r50.0<1;0>:d      r58.0<1>:d      
(f0.0)  goto (16|M0)                         L12968                  L12968                
L8224:
        cmp (16|M0)   (gt)f1.1   null<1>:d     r126.0<1;1,0>:d   -127:w              
(f1.1)  goto (16|M0)                         L10656                  L10656                
L8256:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r126.0<1;1,0>:ud  0xFFFFFF6B:ud             
(f1.0)  goto (16|M0)                         L10160                  L10160                
L8288:
(W)     mov (1|M0)               r2.0<1>:f     8.82818e-44:f                              
(W)     mov (1|M0)               r3.0<1>:hf    0.0:hf                              {I@7}
        subb (8|M0)              r88.0<1>:ud   r2.0<0;1,0>:ud    r82.0<1;1,0>:ud  {AccWrEn,Compacted,F@2}
        add3 (16|M0)             r108.0<1>:d   r52.0<1;0>:d      r58.0<1;0>:d      -23:w              
        add3 (8|M0)              r8.0<1>:ud    -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r80.0<1>:ud     {F@1}
        subb (8|M8)              r89.0<1>:ud   r2.0<0;1,0>:ud    r83.0<1;1,0>:ud  {AccWrEn}
        cmp (16|M0)   (gt)f1.0   null<1>:d     r88.0<1;1,0>:ud   r108.0<1;1,0>:ud {I@1}
        add3 (8|M8)              r9.0<1>:ud    -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r81.0<1>:ud    
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r8.0<1;1,0>:d     0:w               {I@1}
(~f1.0) cmp (16|M0)   (gt)f1.0   null<1>:d     r8.0<1;1,0>:ud    0x0:uw             
(f1.0)  goto (16|M0)                         L8512                  L8512                
L8456:
        add3 (16|M0)             r2.0<1>:d     r68.0<1;0>:d      -r88.0<1;0>:d     -23:w              
        mov (16|M0)              r18.0<1>:d    0:w                              
        shl (16|M0)              r20.0<1>:d    r44.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
        goto (16|M0)                         L8512                  L10096                
L8512:
        join (16|M0)                         L10096                                
L8528:
        add3 (16|M0)             r22.0<1>:d    r88.0<1;0>:d      -r68.0<1;0>:d     23:w              
        cmp (16|M0)   (lt)f0.1   null<1>:d     r22.0<1;1,0>:d    2:w               {I@1}
(f0.1)  goto (16|M0)                         L8672                  L8672                
L8576:
        cmp (16|M0)   (eq)f0.0   null<1>:d     r22.0<1;1,0>:d    2:w               {Compacted}
(~f0.0) goto (16|M0)                         L8672                  L8776                
L8600:
        shr (16|M0)              r62.0<1>:ud   r44.0<1;1,0>:ud   1:w              
        mov (16|M0)              r112.0<1>:d   0:w                              
        mov (16|M0)              r100.0<1>:d   0:w                              
        mov (16|M0)              r90.0<1>:f    r62.0<1;1,0>:f                   {Compacted,I@3}
        goto (16|M0)                         L8672                  L9584                
L8672:
        join (16|M0)                         L8776                                
L8688:
        cmp (16|M0)   (eq)f1.1   null<1>:d     r22.0<1;1,0>:d    1:w              
(~f1.1) goto (16|M0)                         L8776                  L8776                
L8720:
        mov (16|M0)              r112.0<1>:d   0:w                              
        mov (16|M0)              r100.0<1>:d   0:w                              
        mov (16|M0)              r90.0<1>:f    r44.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L8776                  L9584                
L8776:
        join (16|M0)                         L9584                                
L8792:
        add3 (16|M0)             r2.0<1>:d     r88.0<1;0>:d      -r108.0<1;0>:d    -1:w              
        and (16|M0)   (ne)f1.0   r102.0<1>:d   r2.0<1;1,0>:d     63:w               {I@1}
(f1.0)  goto (16|M0)                         L8864                  L8864                
L8840:
        mov (16|M0)              r82.0<1>:f    r44.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L8864                  L8976                
L8864:
        join (16|M0)                         L8976                                
L8880:
        cmp (16|M0)   (lt)f0.1   null<1>:d     r102.0<1;1,0>:ud  0x20:uw              {I@4}
(~f0.1) add (16|M0)              r2.0<1>:d     r102.0<1;1,0>:d   -32:w              
(~f0.1) shr (16|M0)              r62.0<1>:ud   r48.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f0.1)  add (16|M0)              r2.0<1>:d     -r102.0<1;1,0>:d  32:w               {Compacted}
(f0.1)  shr (16|M0)              r8.0<1>:ud    r44.0<1;1,0>:ud   r102.0<1;1,0>:d 
(f0.1)  shl (16|M0)              r2.0<1>:d     r48.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f0.1)  or (16|M0)               r62.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
        mov (16|M0)              r82.0<1>:f    r62.0<1;1,0>:f                   {Compacted,I@1}
L8976:
        join (16|M0)                         L9584                                
L8992:
        add3 (16|M0)             r50.0<1>:d    r88.0<1;0>:d      -r108.0<1;0>:d    -2:w              
        and (16|M0)   (ne)f0.0   r100.0<1>:d   r50.0<1;1,0>:d    63:w               {Compacted,I@1}
(f0.0)  goto (16|M0)                         L9056                  L9056                
L9032:
        mov (16|M0)              r62.0<1>:f    r44.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L9056                  L9160                
L9056:
        join (16|M0)                         L9160                                
L9072:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r100.0<1;1,0>:ud  0x20:uw              {I@4}
(~f1.1) add (16|M0)              r2.0<1>:d     r100.0<1;1,0>:d   -32:w              
(~f1.1) shr (16|M0)              r62.0<1>:ud   r48.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.1)  add (16|M0)              r2.0<1>:d     -r100.0<1;1,0>:d  32:w               {Compacted}
(f1.1)  shr (16|M0)              r8.0<1>:ud    r44.0<1;1,0>:ud   r100.0<1;1,0>:d 
(f1.1)  shl (16|M0)              r2.0<1>:d     r48.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.1)  or (16|M0)               r62.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
L9160:
        join (16|M0)                         L9584                                
L9176:
        and (16|M0)   (ne)f1.0   r58.0<1>:d    r50.0<1;1,0>:d    63:w              
(f1.0)  goto (16|M0)                         L9256                  L9256                
L9208:
        mov (16|M0)              r66.0<1>:d    -1:w                              
        mov (16|M0)              r72.0<1>:d    -1:w                              
        goto (16|M0)                         L9256                  L9440                
L9256:
        join (16|M0)                         L9440                                
L9272:
        cmp (16|M0)   (lt)f0.1   null<1>:d     r58.0<1;1,0>:ud   0x20:uw              {I@6}
(f0.1)  goto (16|M0)                         L9376                  L9376                
L9304:
        add (16|M0)              r2.0<1>:d     r58.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r4.12<1>:hf   -qnan(0x1FF):hf                             
        mov (16|M0)              r66.0<1>:d    0:w                              
        shl (16|M0)              r72.0<1>:d    r4.12<0;1,0>:w    r2.0<1;1,0>:d    {A@1}
        goto (16|M0)                         L9376                  L9440                
L9376:
        join (16|M0)                         L9440                                
L9392:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (16|M0)              r72.0<1>:d    -1:w                              
        shl (16|M0)              r66.0<1>:d    r2.0<0;1,0>:w     r58.0<1;1,0>:d   {F@1}
L9440:
        join (16|M0)                         L9584                                
L9456:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r66.0<1;0>:ud     r5.0<0;0>:ud      r44.0<1>:ud      {I@2} // (s0^s1)&s2
        cmp (16|M0)   (ne)f0.0   null<1>:d     r2.0<1;1,0>:d     0:w               {Compacted,I@1}
        bfn.0x60 (16|M0)         r8.0<1>:ud    r72.0<1;0>:ud     r5.0<0;0>:ud      r48.0<1>:ud      // (s0^s1)&s2
(~f0.0) cmp (16|M0)   (ne)f0.0   null<1>:d     r8.0<1;1,0>:d     0:w               {I@1}
(W)     mov (1|M0)               r4.12<1>:hf   -qnan(0x1FF):hf                             
        shl (16|M0)              r12.0<1>:d    r62.0<1;1,0>:d    1:w               {Compacted}
(f0.0)  sel (16|M0)              r10.0<1>:d    r4.12<0;1,0>:w    0:w               {F@1}
        mov (16|M0)              r90.0<1>:f    r82.0<1;1,0>:f                   {Compacted}
        and (16|M0)              r100.0<1>:d   r12.0<1;1,0>:d    2:w               {Compacted,I@2}
        mov (16|M0)              r112.0<1>:d   -r10.0<1;1,0>:d                  {I@2}
L9584:
        join (16|M0)                         L10096                                
L9600:
        and (16|M0)   (ne)f0.0   r98.0<1>:d    r22.0<1;1,0>:d    63:w               {Compacted}
(f0.0)  goto (16|M0)                         L9648                  L9648                
L9624:
        mov (16|M0)              r62.0<1>:f    r44.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L9648                  L9752                
L9648:
        join (16|M0)                         L9752                                
L9664:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r98.0<1;1,0>:ud   0x20:uw              {I@4}
(~f1.1) add (16|M0)              r2.0<1>:d     r98.0<1;1,0>:d    -32:w              
(~f1.1) shr (16|M0)              r62.0<1>:ud   r48.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.1)  add (16|M0)              r2.0<1>:d     -r98.0<1;1,0>:d   32:w               {Compacted}
(f1.1)  shr (16|M0)              r8.0<1>:ud    r44.0<1;1,0>:ud   r98.0<1;1,0>:d  
(f1.1)  shl (16|M0)              r2.0<1>:d     r48.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.1)  or (16|M0)               r62.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
L9752:
        join (16|M0)                         L10096                                
L9768:
        shl (16|M0)              r2.0<1>:d     r90.0<1;1,0>:d    2:w               {Compacted}
        and (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     4:w               {Compacted,I@1}
        bfn.0xFE (16|M0)         r8.0<1>:ud    r2.0<1;0>:ud      r100.0<1;0>:ud    r112.0<1>:ud     {I@1} // s0|s1|s2
        cmp (16|M0)   (eq)f1.0   null<1>:d     r8.0<1;1,0>:d     0:w               {I@1}
(~f1.0) goto (16|M0)                         L9864                  L9864                
L9832:
        mov (16|M0)              r12.0<1>:d    0:w                              
        goto (16|M0)                         L9864                  L10024                
L9864:
        join (16|M0)                         L10024                                
L9880:
        cmp (16|M0)   (gt)f0.1   null<1>:d     r8.0<1;1,0>:ud    0x4:uw             
(~f0.1) goto (16|M0)                         L9944                  L9944                
L9912:
        mov (16|M0)              r12.0<1>:d    1:w                              
        goto (16|M0)                         L9944                  L10024                
L9944:
        join (16|M0)                         L10024                                
L9960:
        and (16|M0)   (ne)f1.1   null<1>:d     r62.0<1;1,0>:d    1:w              
(W)     mov (1|M0)               r2.0<1>:hf    0x1:hf                             
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r8.0<1;1,0>:d     4:w              
(f1.1)  sel (16|M0)              r12.0<1>:d    r2.0<0;1,0>:w     0:w               {F@1}
L10024:
        join (16|M0)                         L10096                                
L10040:
        add (16|M0)              r2.0<1>:d     r12.0<1;1,0>:d    r62.0<1;1,0>:d   {Compacted,I@2}
        cmp (16|M0)   (gt)f0.0   null<1>:d     r2.0<1;1,0>:ud    0x7FFFFF:ud              {I@1}
(W)     mov (1|M0)               r4.6<1>:f     0x800000:f                               {Compacted}
(~f0.0) sel (16|M0)              r20.0<1>:d    r2.0<1;1,0>:d     0:w              
(f0.0)  sel (16|M0)              r18.0<1>:d    r4.6<0;1,0>:d     0:w               {Compacted,F@1}
L10096:
        join (16|M0)                         L10160                                
L10112:
        and (16|M0)              r2.0<1>:d     r40.0<1;1,0>:d    -2147483648:d              
        bfn.0xFE (16|M0)         r70.0<1>:ud   r2.0<1;0>:ud      r18.0<1;0>:ud     r20.0<1>:ud      {I@1} // s0|s1|s2
        goto (16|M0)                         L10160                  L13184                
L10160:
        join (16|M0)                         L10656                                
L10176:
        and (16|M0)   (ne)f0.0   r26.0<1>:d    r58.0<1;1,0>:d    63:w               {Compacted}
(f0.0)  goto (16|M0)                         L10248                  L10248                
L10200:
        mov (16|M0)              r38.0<1>:d    -1:w                              
        mov (16|M0)              r56.0<1>:d    -1:w                              
        goto (16|M0)                         L10248                  L10432                
L10248:
        join (16|M0)                         L10432                                
L10264:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r26.0<1;1,0>:ud   0x20:uw              {I@6}
(f1.1)  goto (16|M0)                         L10368                  L10368                
L10296:
        add (16|M0)              r2.0<1>:d     r26.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r4.12<1>:hf   -qnan(0x1FF):hf                             
        mov (16|M0)              r38.0<1>:d    0:w                              
        shl (16|M0)              r56.0<1>:d    r4.12<0;1,0>:w    r2.0<1;1,0>:d    {A@1}
        goto (16|M0)                         L10368                  L10432                
L10368:
        join (16|M0)                         L10432                                
L10384:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (16|M0)              r56.0<1>:d    -1:w                              
        shl (16|M0)              r38.0<1>:d    r2.0<0;1,0>:w     r26.0<1;1,0>:d   {F@1}
L10432:
        join (16|M0)                         L10656                                
L10448:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r38.0<1;0>:ud     r5.0<0;0>:ud      r44.0<1>:ud      {I@2} // (s0^s1)&s2
        cmp (16|M0)   (ne)f1.1   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
        bfn.0x60 (16|M0)         r8.0<1>:ud    r56.0<1;0>:ud     r5.0<0;0>:ud      r48.0<1>:ud      // (s0^s1)&s2
        cmp (16|M0)   (gt)f1.0   null<1>:d     r40.0<1;1,0>:d    -1:w              
(~f1.1) cmp (16|M0)   (ne)f1.1   null<1>:d     r8.0<1;1,0>:d     0:w               {I@2}
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r126.0<1;1,0>:d   -150:w              
(f1.0)  goto (16|M0)                         L10600                  L10600                
L10560:
(W)     mov (1|M0)               r2.0<1>:ud    0x80000001:ud                             
(f1.1)  sel (16|M0)              r70.0<1>:f    r2.0<0;1,0>:f     -0.0:f               {Compacted,I@1}
        goto (16|M0)                         L10600                  L13184                
L10600:
        join (16|M0)                         L10656                                
L10616:
(W)     mov (1|M0)               r2.0<1>:ud    0x1:ud                              {F@1}
(f1.1)  sel (16|M0)              r70.0<1>:f    r2.0<0;1,0>:f     0.0:f               {Compacted,I@1}
        goto (16|M0)                         L10656                  L13184                
L10656:
        join (16|M0)                         L12968                                
L10672:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r58.0<1;1,0>:ud   0x18:uw             
        add3 (16|M0)             r60.0<1>:d    r52.0<1;0>:d      r58.0<1;0>:d      -46:w              
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r70.0<1;1,0>:d    0:w               {F@1}
(f1.0)  goto (16|M0)                         L12656                  L12656                
L10736:
        shl (16|M0)              r2.0<1>:d     r74.0<1;1,0>:d    1:w               {Compacted}
        shr (16|M0)              r8.0<1>:ud    r74.0<1;1,0>:ud   31:w              
        shl (16|M0)              r10.0<1>:d    r94.0<1;1,0>:d    1:w               {Compacted}
        cmp (16|M0)   (lt)f0.1   null<1>:d     r2.0<1;1,0>:ud    0x4E:uw              {I@3}
        or (16|M0)               r10.0<1>:d    r10.0<1;1,0>:d    r8.0<1;1,0>:d    {Compacted,I@2}
(f0.1)  cmp (16|M0)   (eq)f0.1   null<1>:d     r10.0<1;1,0>:d    0:w               {I@1}
(~f0.1) cmp (16|M0)   (lt)f0.1   null<1>:d     r10.0<1;1,0>:d    0:w              
(f0.1)  goto (16|M0)                         L10968                  L10968                
L10840:
        cmp (16|M0)   (eq)f0.1   null<1>:d     r74.0<1;1,0>:d    39:w              
(f0.1)  cmp (16|M0)   (eq)f0.1   null<1>:d     r94.0<1;1,0>:d    0:w              
(~f0.1) goto (16|M0)                         L10968                  L11024                
L10888:
        shr (16|M0)              r62.0<1>:ud   r44.0<1;1,0>:ud   1:w              
        mov (16|M0)              r116.0<1>:d   0:w                              
        mov (16|M0)              r88.0<1>:d    0:w                              
        mov (16|M0)              r122.0<1>:f   r62.0<1;1,0>:f                   {Compacted,I@3}
        mov (16|M0)              r62.0<1>:f    r44.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L10968                  L12136                
L10968:
        join (16|M0)                         L11024                                
L10984:
        cmp (16|M0)   (eq)f0.0   null<1>:d     r74.0<1;1,0>:d    38:w               {Compacted}
(f0.0)  cmp (16|M0)   (eq)f0.0   null<1>:d     r94.0<1;1,0>:d    0:w              
(f0.0)  goto (16|M0)                         L11024                  L12048                
L11024:
        join (16|M0)                         L12048                                
L11040:
        add (16|M0)              r2.0<1>:d     -r74.0<1;1,0>:d   39:w               {Compacted}
        and (16|M0)   (ne)f0.1   r110.0<1>:d   r2.0<1;1,0>:d     63:w               {I@1}
        add (16|M0)              r94.0<1>:d    -r74.0<1;1,0>:d   40:w               {Compacted}
(f0.1)  goto (16|M0)                         L11112                  L11112                
L11088:
        mov (16|M0)              r84.0<1>:f    r44.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L11112                  L11224                
L11112:
        join (16|M0)                         L11224                                
L11128:
        cmp (16|M0)   (lt)f0.0   null<1>:d     r110.0<1;1,0>:ud  0x20:uw              {I@5}
(~f0.0) add (16|M0)              r2.0<1>:d     r110.0<1;1,0>:d   -32:w              
(~f0.0) shr (16|M0)              r62.0<1>:ud   r48.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f0.0)  add (16|M0)              r2.0<1>:d     -r110.0<1;1,0>:d  32:w               {Compacted}
(f0.0)  shr (16|M0)              r8.0<1>:ud    r44.0<1;1,0>:ud   r110.0<1;1,0>:d 
(f0.0)  shl (16|M0)              r2.0<1>:d     r48.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f0.0)  or (16|M0)               r62.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
        mov (16|M0)              r84.0<1>:f    r62.0<1;1,0>:f                   {Compacted,I@1}
L11224:
        join (16|M0)                         L12048                                
L11240:
        add (16|M0)              r64.0<1>:d    -r74.0<1;1,0>:d   38:w               {Compacted}
        and (16|M0)   (ne)f1.1   r114.0<1>:d   r64.0<1;1,0>:d    63:w               {I@1}
(f1.1)  goto (16|M0)                         L11304                  L11304                
L11280:
        mov (16|M0)              r78.0<1>:f    r44.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L11304                  L11416                
L11304:
        join (16|M0)                         L11416                                
L11320:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r114.0<1;1,0>:ud  0x20:uw              {I@4}
(~f1.0) add (16|M0)              r2.0<1>:d     r114.0<1;1,0>:d   -32:w              
(~f1.0) shr (16|M0)              r62.0<1>:ud   r48.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.0)  add (16|M0)              r2.0<1>:d     -r114.0<1;1,0>:d  32:w               {Compacted}
(f1.0)  shr (16|M0)              r8.0<1>:ud    r44.0<1;1,0>:ud   r114.0<1;1,0>:d 
(f1.0)  shl (16|M0)              r2.0<1>:d     r48.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.0)  or (16|M0)               r62.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
        mov (16|M0)              r78.0<1>:f    r62.0<1;1,0>:f                   {Compacted,I@1}
L11416:
        join (16|M0)                         L12048                                
L11432:
        and (16|M0)   (ne)f0.1   r76.0<1>:d    r64.0<1;1,0>:d    63:w              
(f0.1)  goto (16|M0)                         L11512                  L11512                
L11464:
        mov (16|M0)              r80.0<1>:d    -1:w                              
        mov (16|M0)              r86.0<1>:d    -1:w                              
        goto (16|M0)                         L11512                  L11696                
L11512:
        join (16|M0)                         L11696                                
L11528:
        cmp (16|M0)   (lt)f0.0   null<1>:d     r76.0<1;1,0>:ud   0x20:uw              {I@6}
(f0.0)  goto (16|M0)                         L11632                  L11632                
L11560:
        add (16|M0)              r2.0<1>:d     r76.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r4.12<1>:hf   -qnan(0x1FF):hf                             
        mov (16|M0)              r80.0<1>:d    0:w                              
        shl (16|M0)              r86.0<1>:d    r4.12<0;1,0>:w    r2.0<1;1,0>:d    {A@1}
        goto (16|M0)                         L11632                  L11696                
L11632:
        join (16|M0)                         L11696                                
L11648:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (16|M0)              r86.0<1>:d    -1:w                              
        shl (16|M0)              r80.0<1>:d    r2.0<0;1,0>:w     r76.0<1;1,0>:d   {F@1}
L11696:
        join (16|M0)                         L12048                                
L11712:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r80.0<1;0>:ud     r5.0<0;0>:ud      r44.0<1>:ud      {I@2} // (s0^s1)&s2
        cmp (16|M0)   (ne)f1.1   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
        bfn.0x60 (16|M0)         r8.0<1>:ud    r86.0<1;0>:ud     r5.0<0;0>:ud      r48.0<1>:ud      // (s0^s1)&s2
(~f1.1) cmp (16|M0)   (ne)f1.1   null<1>:d     r8.0<1;1,0>:d     0:w               {I@1}
(W)     mov (1|M0)               r4.12<1>:hf   -qnan(0x1FF):hf                             
(f1.1)  sel (16|M0)              r10.0<1>:d    r4.12<0;1,0>:w    0:w               {F@1}
        and (16|M0)   (ne)f1.1   r112.0<1>:d   r94.0<1;1,0>:d    63:w              
        mov (16|M0)              r116.0<1>:d   -r10.0<1;1,0>:d                  {I@2}
(f1.1)  goto (16|M0)                         L11880                  L11880                
L11856:
        mov (16|M0)              r62.0<1>:f    r44.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L11880                  L11984                
L11880:
        join (16|M0)                         L11984                                
L11896:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r112.0<1;1,0>:ud  0x20:uw              {I@5}
(~f1.0) add (16|M0)              r2.0<1>:d     r112.0<1;1,0>:d   -32:w              
(~f1.0) shr (16|M0)              r62.0<1>:ud   r48.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.0)  add (16|M0)              r2.0<1>:d     -r112.0<1;1,0>:d  32:w               {Compacted}
(f1.0)  shr (16|M0)              r8.0<1>:ud    r44.0<1;1,0>:ud   r112.0<1;1,0>:d 
(f1.0)  shl (16|M0)              r2.0<1>:d     r48.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.0)  or (16|M0)               r62.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
L11984:
        join (16|M0)                         L12048                                
L12000:
        shl (16|M0)              r2.0<1>:d     r78.0<1;1,0>:d    1:w               {Compacted}
        mov (16|M0)              r122.0<1>:f   r62.0<1;1,0>:f                   {Compacted,I@3}
        and (16|M0)              r88.0<1>:d    r2.0<1;1,0>:d     2:w               {Compacted,I@1}
        mov (16|M0)              r62.0<1>:f    r84.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L12048                  L12136                
L12048:
        join (16|M0)                         L12136                                
L12064:
        shr (16|M0)              r62.0<1>:ud   r44.0<1;1,0>:ud   2:w               {F@1}
        mov (16|M0)              r116.0<1>:d   0:w                              
        mov (16|M0)              r88.0<1>:d    0:w                              
        mov (16|M0)              r122.0<1>:f   r62.0<1;1,0>:f                   {Compacted,I@3}
        shr (16|M0)              r62.0<1>:ud   r44.0<1;1,0>:ud   1:w               {F@1}
L12136:
        join (16|M0)                         L12656                                
L12152:
        shl (16|M0)              r2.0<1>:d     r62.0<1;1,0>:d    2:w               {Compacted,I@2}
        and (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     4:w               {Compacted,I@1}
        bfn.0xFE (16|M0)         r30.0<1>:ud   r2.0<1;0>:ud      r88.0<1;0>:ud     r116.0<1>:ud     {I@1} // s0|s1|s2
        cmp (16|M0)   (eq)f0.1   null<1>:d     r30.0<1;1,0>:d    0:w               {I@1}
        and (16|M0)              r90.0<1>:d    r122.0<1;1,0>:d   8388607:d              
(~f0.1) goto (16|M0)                         L12264                  L12264                
L12232:
        mov (16|M0)              r24.0<1>:d    0:w                              
        goto (16|M0)                         L12264                  L12424                
L12264:
        join (16|M0)                         L12424                                
L12280:
        cmp (16|M0)   (gt)f0.0   null<1>:d     r30.0<1;1,0>:ud   0x4:uw             
(~f0.0) goto (16|M0)                         L12344                  L12344                
L12312:
        mov (16|M0)              r24.0<1>:d    1:w                              
        goto (16|M0)                         L12344                  L12424                
L12344:
        join (16|M0)                         L12424                                
L12360:
        and (16|M0)   (ne)f1.0   null<1>:d     r122.0<1;1,0>:d   1:w              
(W)     mov (1|M0)               r2.0<1>:hf    0x1:hf                             
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r30.0<1;1,0>:d    4:w              
(f1.0)  sel (16|M0)              r24.0<1>:d    r2.0<0;1,0>:w     0:w               {F@1}
L12424:
        join (16|M0)                         L12656                                
L12440:
        add (16|M0)              r38.0<1>:d    r90.0<1;1,0>:d    r24.0<1;1,0>:d   {Compacted,I@2}
        cmp (16|M0)   (gt)f1.0   null<1>:d     r38.0<1;1,0>:ud   0x7FFFFF:ud              {I@1}
        add3 (16|M0)             r2.0<1>:d     r52.0<1;0>:d      r58.0<1;0>:d      -45:w              
(f1.0)  sel (16|M0)              r22.0<1>:d    r2.0<1;1,0>:d     r60.0<1;1,0>:d   {Compacted,I@1}
        cmp (16|M0)   (eq)f1.1   null<1>:d     r22.0<1;1,0>:d    255:w               {I@1}
(f1.1)  goto (16|M0)                         L12592                  L12592                
L12520:
(~f1.0) sel (16|M0)              r2.0<1>:d     r38.0<1;1,0>:d    0:w              
        and (16|M0)              r8.0<1>:d     r40.0<1;1,0>:d    -2147483648:d              
        shl (16|M0)              r10.0<1>:d    r22.0<1;1,0>:d    23:w               {Compacted}
        bfn.0xFE (16|M0)         r70.0<1>:ud   r8.0<1;0>:ud      r10.0<1;0>:ud     r2.0<1>:ud       {I@1} // s0|s1|s2
        goto (16|M0)                         L12592                  L13184                
L12592:
        join (16|M0)                         L12656                                
L12608:
        cmp (16|M0)   (gt)f0.1   null<1>:d     r40.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r2.0<1>:f     inf:f                               {Compacted,I@4}
(f0.1)  sel (16|M0)              r70.0<1>:f    r2.0<0;1,0>:f     -inf:f               {Compacted,F@1}
        goto (16|M0)                         L12656                  L13184                
L12656:
        join (16|M0)                         L12968                                
L12672:
        and (16|M0)   (ne)f1.0   r16.0<1>:d    r58.0<1;1,0>:d    63:w              
(f1.0)  goto (16|M0)                         L12736                  L12736                
L12704:
        mov (16|M0)              r18.0<1>:d    -1:w                              
        goto (16|M0)                         L12736                  L12864                
L12736:
        join (16|M0)                         L12864                                
L12752:
        cmp (16|M0)   (lt)f0.1   null<1>:d     r16.0<1;1,0>:ud   0x20:uw              {A@1}
(f0.1)  goto (16|M0)                         L12816                  L12816                
L12784:
        mov (16|M0)              r18.0<1>:d    0:w                              
        goto (16|M0)                         L12816                  L12864                
L12816:
        join (16|M0)                         L12864                                
L12832:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                             
        shl (16|M0)              r18.0<1>:d    r2.0<0;1,0>:w     r16.0<1;1,0>:d   {F@1}
L12864:
        join (16|M0)                         L12968                                
L12880:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r18.0<1;0>:ud     r5.0<0;0>:ud      r44.0<1>:ud      {I@2} // (s0^s1)&s2
        add (16|M0)              r8.0<1>:d     -r58.0<1;1,0>:d   23:w               {Compacted}
        and (16|M0)              r10.0<1>:d    r40.0<1;1,0>:d    -2147483648:d              
        shl (16|M0)              r12.0<1>:d    r60.0<1;1,0>:d    23:w               {Compacted}
        shl (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     r8.0<1;1,0>:d    {Compacted,I@3}
        bfn.0xFE (16|M0)         r70.0<1>:ud   r10.0<1;0>:ud     r12.0<1;0>:ud     r2.0<1>:ud       {I@1} // s0|s1|s2
        goto (16|M0)                         L12968                  L13184                
L12968:
        join (16|M0)                         L13024                                
L12984:
        cmp (16|M0)   (gt)f0.0   null<1>:d     r40.0<1;1,0>:d    -1:w               {Compacted}
(W)     mov (1|M0)               r2.0<1>:f     inf:f                               {Compacted,I@4}
(f0.0)  sel (16|M0)              r70.0<1>:f    r2.0<0;1,0>:f     -inf:f               {Compacted,F@1}
        goto (16|M0)                         L13024                  L13184                
L13024:
        join (16|M0)                         L13088                                
L13040:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r40.0<1;1,0>:d    0:w              
(W)     mov (1|M0)               r2.0<1>:f     -0.0:f                               {Compacted}
(f1.1)  sel (16|M0)              r70.0<1>:f    r2.0<0;1,0>:f     0.0:f               {Compacted,F@1}
        goto (16|M0)                         L13088                  L13184                
L13088:
        join (16|M0)                         L13152                                
L13104:
        cmp (16|M0)   (gt)f1.0   null<1>:d     r40.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r2.0<1>:f     inf:f                               {Compacted}
(f1.0)  sel (16|M0)              r70.0<1>:f    r2.0<0;1,0>:f     -inf:f               {Compacted,F@1}
        goto (16|M0)                         L13152                  L13184                
L13152:
        join (16|M0)                         L13184                                
L13168:
        bfn.0xF8 (16|M0)         r70.0<1>:ud   r40.0<1;0>:ud     r5.2<0;0>:ud      r5.1<0>:ud       {F@1} // s0&s1|s2
L13184:
        join (16|M0)                         L13200                                
L13200:
        cmp (16|M0)   (lt)f0.0   null<1>:f     r34.0<1;1,0>:f    0.0:f               {Compacted,I@7}
        shl (16|M0)              r8.0<1>:d     r32.0<1;1,0>:d    1:w               {Compacted}
(f0.0)  sel (16|M0)              r2.0<1>:f     -r70.0<1;1,0>:f   r70.0<1;1,0>:f   {Compacted,I@3}
(W)     mov (1|M0)               a0.0<1>:ud    r6.0<0;1,0>:d                    {A@1}
        mov (8|M0)               r7.0<1>:hf    r2.0<1;1,0>:f                    {F@1}
        mov (8|M8)               r7.8<1>:hf    r3.0<1;1,0>:f                   
        add (16|M0)              r8.0<1>:d     r8.0<1;1,0>:d     r5.6<0;1,0>:d    {Compacted,I@2}
        mov (16|M0)              r10.0<1>:ud   r7.0<1;1,0>:uw                   {A@1}
(W)     mov (8|M0)               r127.0<1>:f   r36.0<1;1,0>:f                   {Compacted}
        send.ugm (16|M0)         null     r8      r10:2   a0.0        0x240E0B04           {ExBSO,A@1,$5} // wr:2+2, rd:0; store.ugm.d16u32.a32.wb.wb.bss[a0.0]
(W)     send.gtwy (1|M0)         null     r127    null:0  0x0            0x02000010           {EOT,A@1} // wr:1+0, rd:0; end of thread
L13336:
        nop                    
(W)     mov (16|M0)              null<1>:ud    0x9E09665A:ud                             
(W)     mov (16|M0)              null<1>:ud    0xA6E09A48:ud                             
(W)     mov (16|M0)              null<1>:ud    0x0:ud                             
(W)     mov (16|M0)              null<1>:ud    0x5B:ud                             
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
