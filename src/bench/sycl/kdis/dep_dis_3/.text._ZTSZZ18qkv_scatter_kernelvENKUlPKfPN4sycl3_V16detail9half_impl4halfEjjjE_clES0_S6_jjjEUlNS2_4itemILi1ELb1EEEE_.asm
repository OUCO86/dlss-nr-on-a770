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
(W)     mov (8|M0)               r38.0<1>:ud   r0.0<1;1,0>:ud                  
(W)     or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x4C0:uw              {A@1}
(W)     mul (1|M0)               acc0.0<1>:d   r4.3<0;1,0>:d     r38.2<0;1,0>:uw  {A@1}
(W)     mach (1|M0)              r2.0<1>:d     r4.3<0;1,0>:d     r38.1<0;1,0>:d   {$0.dst}
(W)     mul (1|M0)               acc0.0<1>:d   r5.2<0;1,0>:d     r5.6<0;1,0>:uw   {$2.dst}
(W)     mach (1|M0)              r3.0<1>:d     r5.2<0;1,0>:d     r5.3<0;1,0>:d    {$1.dst}
        add3 (16|M0)             r72.0<1>:d    r2.0<0;0>:d       r1.0<1;0>:uw      r4.0<0>:d        {I@3}
(W)     shl (1|M0)               r4.6<1>:d     r3.0<0;1,0>:d     5:w               {Compacted,I@2}
        cmp (16|M0)   (gt)f0.0   null<1>:d     r4.6<0;1,0>:ud    r72.0<1;1,0>:ud  {I@1}
(~f0.0) goto (16|M0)                         L13832                  L13832                
L408:
(W)     shl (1|M0)               r5.0<1>:d     r5.3<0;1,0>:d     5:w               {Compacted}
(W)     cmp (16|M0)   (eq)f1.1   null<1>:d     r5.0<0;1,0>:d     0:w               {I@1}
(~f1.1) goto (16|M0)                         L480                  L480                
L448:
        mov (16|M0)              r82.0<1>:d    -1:w                              
        goto (16|M0)                         L480                  L840                
L480:
        join (16|M0)                         L840                                
L496:
(W)     xor (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x30:uw              {A@1}
(W)     mov (1|M0)               r2.0<1>:f     r5.0<0;1,0>:ud                   {Compacted,A@1}
(W)     mov (1|M0)               r3.2<1>:f     0xB4C00000:f                               {Compacted}
(W)     math.inv (1|M0)          r3.1<1>:f     r2.0<0;1,0>:f                    {@2,$3}
        mov (16|M0)              r8.0<1>:f     r72.0<1;1,0>:ud                  {Compacted}
        sync.nop                             null                             {Compacted,$3.dst}
(W)     mad (1|M0)               r4.6<1>:f     r3.1<0;0>:f       r3.2<0;0>:f       r3.1<0>:f        {F@2}
(W)     mov (1|M0)               r2.1<1>:ud    r2.0<0;1,0>:f                   
        mov (16|M0)              r12.0<1>:ud   r8.0<1;1,0>:f                    {F@2}
        mul (16|M0)              r10.0<1>:f    r8.0<1;1,0>:f     r4.6<0;1,0>:f    {Compacted,F@1}
(W)     add (1|M0)               r3.0<1>:d     r5.0<0;1,0>:d     -r2.1<0;1,0>:d   {Compacted,I@2}
        add (16|M0)              r12.0<1>:d    r72.0<1;1,0>:d    -r12.0<1;1,0>:d  {Compacted,I@2}
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
(W)     mul (8|M0)               acc0.0<1>:d   r30.0<1;1,0>:d    r5.0<0;1,0>:uw   {Compacted,I@1}
        mach (8|M0)              r30.0<1>:d    r30.0<1;1,0>:d    r5.0<0;1,0>:d    {Compacted}
(W)     mul (8|M8)               acc0.0<1>:d   r31.0<1;1,0>:d    r5.0<0;1,0>:uw  
        mach (8|M8)              r31.0<1>:d    r31.0<1;1,0>:d    r5.0<0;1,0>:d    {Compacted}
        add (16|M0)              r30.0<1>:d    r72.0<1;1,0>:d    -r30.0<1;1,0>:d  {Compacted,I@1}
        cmp (16|M0)   (ge)f1.1   r8.0<1>:ud    r30.0<1;1,0>:ud   r5.0<0;1,0>:ud   {I@1}
        add3 (16|M0)             r82.0<1>:d    r28.0<1;0>:d      r14.0<1;0>:d      -r8.0<1>:d       {I@1}
L840:
        join (16|M0)                         L13832                                
L856:
(W)     mul (8|M0)               acc0.0<1>:d   r82.0<1;1,0>:d    r5.0<0;1,0>:uw   {Compacted,I@2}
        mach (8|M0)              r2.0<1>:d     r82.0<1;1,0>:d    r5.0<0;1,0>:d    {Compacted}
(W)     mul (8|M8)               acc0.0<1>:d   r83.0<1;1,0>:d    r5.0<0;1,0>:uw  
(W)     cmp (16|M0)   (eq)f1.0   null<1>:d     r5.4<0;1,0>:d     0:w              
        mach (8|M8)              r3.0<1>:d     r83.0<1;1,0>:d    r5.0<0;1,0>:d    {Compacted}
        add (16|M0)              r32.0<1>:d    r72.0<1;1,0>:d    -r2.0<1;1,0>:d   {Compacted,I@1}
        shr (16|M0)              r100.0<1>:ud  r32.0<1;1,0>:ud   5:w               {I@1}
(~f1.0) goto (16|M0)                         L984                  L984                
L952:
        mov (16|M0)              r80.0<1>:d    -1:w                              
        goto (16|M0)                         L984                  L1352                
L984:
        join (16|M0)                         L1352                                
L1000:
(W)     xor (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x30:uw              {A@1}
(W)     mov (1|M0)               r2.0<1>:f     r5.4<0;1,0>:ud                   {Compacted,A@1}
(W)     mov (1|M0)               r3.2<1>:f     0xB4C00000:f                               {Compacted}
(W)     math.inv (1|M0)          r3.1<1>:f     r2.0<0;1,0>:f                    {@2,$4}
        mov (16|M0)              r8.0<1>:f     r82.0<1;1,0>:ud                  {Compacted}
        sync.nop                             null                             {Compacted,$4.dst}
(W)     mad (1|M0)               r4.6<1>:f     r3.1<0;0>:f       r3.2<0;0>:f       r3.1<0>:f        {F@2}
(W)     mov (1|M0)               r2.1<1>:ud    r2.0<0;1,0>:f                   
        mov (16|M0)              r12.0<1>:ud   r8.0<1;1,0>:f                    {F@2}
        mul (16|M0)              r10.0<1>:f    r8.0<1;1,0>:f     r4.6<0;1,0>:f    {Compacted,F@1}
(W)     add (1|M0)               r3.0<1>:d     r5.4<0;1,0>:d     -r2.1<0;1,0>:d   {I@2}
        add (16|M0)              r12.0<1>:d    r82.0<1;1,0>:d    -r12.0<1;1,0>:d  {Compacted,I@2}
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
        add (16|M0)              r30.0<1>:d    r82.0<1;1,0>:d    -r30.0<1;1,0>:d  {Compacted,I@1}
        cmp (16|M0)   (ge)f1.0   r8.0<1>:ud    r30.0<1;1,0>:ud   r5.4<0;1,0>:ud   {I@1}
        add3 (16|M0)             r80.0<1>:d    r28.0<1;0>:d      r14.0<1;0>:d      -r8.0<1>:d       {I@1}
L1352:
        join (16|M0)                         L13832                                
L1368:
(W)     mov (1|M0)               a0.0<1>:ud    r6.2<0;1,0>:d                    {A@1}
        shl (16|M0)              r10.0<1>:d    r72.0<1;1,0>:d    2:w               {Compacted}
(W)     mul (8|M0)               acc0.0<1>:d   r80.0<1;1,0>:d    r5.8<0;1,0>:uw   {Compacted,I@4}
        send.ugm (16|M0)         r36      r10     null:0  a0.0        0x24280500           {ExBSO,A@2,$5} // wr:2+0, rd:2; load.ugm.d32.a32.ca.ca.bss[a0.0]
        mach (8|M0)              r2.0<1>:d     r80.0<1;1,0>:d    r5.4<0;1,0>:d    {Compacted}
(W)     mul (8|M8)               acc0.0<1>:d   r81.0<1;1,0>:d    r5.8<0;1,0>:uw  
        mach (8|M8)              r3.0<1>:d     r81.0<1;1,0>:d    r5.4<0;1,0>:d    {Compacted}
(W)     mul (8|M0)               acc0.0<1>:d   r80.0<1;1,0>:d    r5.6<0;1,0>:uw   {Compacted}
        mach (8|M0)              r8.0<1>:d     r80.0<1;1,0>:d    r5.3<0;1,0>:d    {Compacted}
(W)     mul (8|M8)               acc0.0<1>:d   r81.0<1;1,0>:d    r5.6<0;1,0>:uw  
        mach (8|M8)              r9.0<1>:d     r81.0<1;1,0>:d    r5.3<0;1,0>:d    {Compacted}
(W)     mov (1|M0)               r6.4<1>:f     -0.0:f                               {Compacted}
        add (16|M0)              r8.0<1>:d     r8.0<1;1,0>:d     r100.0<1;1,0>:d  {Compacted,I@1}
        and (16|M0)              r12.0<1>:d    r36.0<1;1,0>:d    2147483647:d               {$5.dst}
        sel (16|M0)   (lt)f0.0   r58.0<1>:f    r12.0<1;1,0>:f    448.0:f               {Compacted,I@1}
        shr (16|M0)              r60.0<1>:ud   r58.0<1;1,0>:ud   23:w               {F@1}
        and (16|M0)   (ne)f1.1   r92.0<1>:d    r58.0<1;1,0>:d    8388607:d              
        and (16|M0)              r84.0<1>:d    r60.0<1;1,0>:d    255:w               {Compacted,I@2}
(W)     mul (8|M0)               acc0.0<1>:d   r8.0<1;1,0>:d     r5.8<0;1,0>:uw   {Compacted}
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r84.0<1;1,0>:d    255:w               {I@2}
        mach (8|M0)              r8.0<1>:d     r8.0<1;1,0>:d     r5.4<0;1,0>:d    {Compacted}
(W)     mul (8|M8)               acc0.0<1>:d   r9.0<1;1,0>:d     r5.8<0;1,0>:uw  
        sel (16|M0)   (ge)f0.0   r14.0<1>:ud   r84.0<1;1,0>:ud   0x79:uw             
        mach (8|M8)              r9.0<1>:d     r9.0<1;1,0>:d     r5.4<0;1,0>:d    {Compacted}
(W)     mov (1|M0)               r6.3<1>:f     inf:f                               {Compacted}
(W)     mov (1|M0)               r6.2<1>:d     -1:w                              
        shl (16|M0)              r40.0<1>:d    r14.0<1;1,0>:d    23:w               {Compacted,I@3}
        add3 (16|M0)             r34.0<1>:d    r8.0<1;0>:d       r82.0<1;0>:d      -r2.0<1>:d       {I@3}
(~f1.1) goto (16|M0)                         L1736                  L1736                
L1704:
        mov (16|M0)              r78.0<1>:ud   0x7FC00000:ud                             
        goto (16|M0)                         L1736                  L7624                
L1736:
        join (16|M0)                         L7624                                
L1752:
        cmp (16|M0)   (eq)f1.0   null<1>:d     r92.0<1;1,0>:d    0:w              
        add (16|M0)              r42.0<1>:d    -r40.0<1;1,0>:d   -2139095040:d               {I@7}
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r84.0<1;1,0>:d    255:w              
        xor (16|M0)              r44.0<1>:d    r42.0<1;1,0>:d    r58.0<1;1,0>:d   {Compacted,I@2}
(f1.0)  goto (16|M0)                         L7592                  L7592                
L1824:
        or (16|M0)    (eq)f0.1   null<1>:d     r84.0<1;1,0>:d    r92.0<1;1,0>:d  
(~f0.1) goto (16|M0)                         L1888                  L1888                
L1856:
        mov (16|M0)              r78.0<1>:ud   0x0:ud                             
        goto (16|M0)                         L1888                  L7624                
L1888:
        join (16|M0)                         L7592                                
L1904:
        cmp (16|M0)   (eq)f0.1   null<1>:d     r84.0<1;1,0>:d    0:w              
        shr (16|M0)              r16.0<1>:ud   r42.0<1;1,0>:ud   23:w              
        add (16|M0)              r46.0<1>:d    r84.0<1;1,0>:d    -127:w               {Compacted}
(f0.1)  mov (16|M0)              r46.0<1>:d    -126:w                              
        add (16|M0)              r56.0<1>:d    r16.0<1;1,0>:d    r46.0<1;1,0>:d   {Compacted,I@1}
        cmp (16|M0)   (gt)f0.0   null<1>:d     r56.0<1;1,0>:d    254:w               {Compacted,I@1}
(f0.0)  goto (16|M0)                         L7528                  L7528                
L1992:
        or (16|M0)    (eq)f1.1   null<4>:b     r60.0<1;1,0>:d    r16.0<1;1,0>:d  
(f1.1)  goto (16|M0)                         L7464                  L7464                
L2024:
(W)     mov (1|M0)               r2.0<1>:hf    0.0:hf                             
(W)     mov (1|M0)               r5.4<1>:d     0:w                              
(f0.1)  sel (16|M0)              r8.0<1>:d     r2.0<0;1,0>:w     8388608:d               {F@1}
        or (16|M0)               r8.0<1>:d     r8.0<1;1,0>:d     r92.0<1;1,0>:d   {Compacted,I@1}
        shl (16|M0)              r48.0<1>:d    r8.0<1;1,0>:d     23:w               {Compacted,I@1}
        shr (16|M0)              r52.0<1>:ud   r8.0<1;1,0>:ud    9:w              
(W)     mov (1|M0)               r5.3<1>:f     -0.0:f                               {Compacted}
(W)     mov (2|M0)               r5.0<1>:d     0:w                              
L2128:
(W)     shl (1|M0)               r2.0<1>:d     r5.3<0;1,0>:d     31:w               {Compacted,F@1}
(W)     shr (1|M0)               r2.1<1>:ud    r5.4<0;1,0>:ud    1:w              
(W)     cmp (16|M0)   (gt)f1.0   null<1>:d     r5.0<0;1,0>:ud    0x3E:uw              {I@3}
(W)     or (1|M0)                r5.4<1>:d     r2.1<0;1,0>:d     r2.0<0;1,0>:d    {I@2}
        bfn.0xE0 (16|M0)         r8.0<1>:ud    r2.1<0;0>:ud      r2.0<0;0>:ud      r48.0<1>:ud      // (s0|s1)&s2
(W)     shr (1|M0)               r5.2<1>:ud    r5.3<0;1,0>:ud    1:w              
(W&f1.0) cmp (16|M0)  (eq)f1.0   null<1>:d     r5.1<0;1,0>:d     0:w              
        cmp (16|M0)   (eq)f0.0   null<1>:d     r8.0<1;1,0>:d     r5.4<0;1,0>:d    {I@3}
        and (16|M0)              r10.0<1>:d    r5.2<0;1,0>:d     r52.0<1;1,0>:d   {Compacted,I@3}
(W&~f1.0) cmp (16|M0) (gt)f1.0   null<1>:d     r5.1<0;1,0>:ud    0x0:uw             
(f0.0)  cmp (16|M0)   (eq)f0.0   null<1>:d     r10.0<1;1,0>:d    r5.2<0;1,0>:d    {I@2}
(W)     mov (1|M0)               r4.12<1>:hf   0x1:hf                             
(W)     addc (1|M0)              r13.0<1>:ud   r5.0<0;1,0>:ud    0x1:ud              {AccWrEn}
(f1.0)  sel (16|M0)              r7.0<1>:uw    r4.12<0;1,0>:uw   0x0:uw              {Compacted,F@1}
(f0.0)  sel (16|M0)              acc2.0<1>:uw  r4.12<0;1,0>:uw   0x0:uw             
(W)     mov (1|M0)               r3.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        or (16|M0)    (ne)f1.0   null<1>:uw    r7.0<1;1,0>:uw    acc2.0<1;1,0>:uw {I@3}
(W)     add (1|M0)               r5.5<1>:ud    r3.0<0;1,0>:ud    r5.1<0;1,0>:ud   {I@2}
        mov (16|M0)              r92.0<1>:f    r5.0<0;1,0>:f                    {Compacted}
        mov (16|M0)              r90.0<1>:d    r5.1<0;1,0>:d                   
        mov (16|M0)              r70.0<1>:f    r13.0<0;1,0>:f                   {Compacted}
        mov (16|M0)              r102.0<1>:d   r5.5<0;1,0>:d                    {I@2}
(f1.0)  goto (16|M0)                         L2504                  L2504                
L2448:
(W)     mov (1|M0)               r5.3<1>:d     r5.2<0;1,0>:d                   
(W)     mov (1|M0)               r5.0<1>:f     r13.0<0;1,0>:f                   {Compacted}
(W)     mov (1|M0)               r5.1<1>:d     r5.5<0;1,0>:d                   
(W)     jmpi                                 L2128                                
L2504:
        join (16|M0)                         L7464                                
L2520:
(W)     mov (1|M0)               r2.0<1>:f     8.68805e-44:f                              
(W)     mov (1|M0)               r3.0<1>:hf    0.0:hf                             
        subb (8|M0)              r58.0<1>:ud   r2.0<0;1,0>:ud    r92.0<1;1,0>:ud  {AccWrEn,Compacted,F@2}
        add3 (8|M0)              r76.0<1>:ud   -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r90.0<1>:ud     {A@1}
        subb (8|M8)              r59.0<1>:ud   r2.0<0;1,0>:ud    r93.0<1;1,0>:ud  {AccWrEn}
        add3 (16|M0)             r14.0<1>:d    r56.0<1;0>:d      r58.0<1;0>:d      -173:w               {I@1}
        cmp (16|M0)   (gt)f1.0   null<1>:d     r14.0<1;1,0>:d    127:w               {I@1}
        add3 (8|M8)              r77.0<1>:ud   -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r91.0<1>:ud    
        add3 (16|M0)             r74.0<1>:d    r16.0<1;0>:d      r46.0<1;0>:d      r58.0<1>:d      
(f1.0)  goto (16|M0)                         L7408                  L7408                
L2672:
        cmp (16|M0)   (gt)f0.1   null<1>:d     r14.0<1;1,0>:d    -127:w              
(f0.1)  goto (16|M0)                         L5104                  L5104                
L2704:
        cmp (16|M0)   (lt)f0.0   null<1>:d     r14.0<1;1,0>:ud   0xFFFFFF6B:ud             
(f0.0)  goto (16|M0)                         L4608                  L4608                
L2736:
(W)     mov (1|M0)               r2.0<1>:f     8.82818e-44:f                              
(W)     mov (1|M0)               r3.0<1>:hf    0.0:hf                              {I@7}
        subb (8|M0)              r96.0<1>:ud   r2.0<0;1,0>:ud    r92.0<1;1,0>:ud  {AccWrEn,Compacted,F@2}
        add3 (16|M0)             r120.0<1>:d   r56.0<1;0>:d      r58.0<1;0>:d      -23:w              
        add3 (8|M0)              r8.0<1>:ud    -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r90.0<1>:ud     {F@1}
        subb (8|M8)              r97.0<1>:ud   r2.0<0;1,0>:ud    r93.0<1;1,0>:ud  {AccWrEn}
        cmp (16|M0)   (gt)f1.1   null<1>:d     r96.0<1;1,0>:ud   r120.0<1;1,0>:ud {I@1}
        add3 (8|M8)              r9.0<1>:ud    -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r91.0<1>:ud    
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r8.0<1;1,0>:d     0:w               {I@1}
(~f1.1) cmp (16|M0)   (gt)f1.1   null<1>:d     r8.0<1;1,0>:ud    0x0:uw             
(f1.1)  goto (16|M0)                         L2960                  L2960                
L2904:
        add3 (16|M0)             r2.0<1>:d     r74.0<1;0>:d      -r96.0<1;0>:d     -23:w              
        mov (16|M0)              r28.0<1>:d    0:w                              
        shl (16|M0)              r30.0<1>:d    r48.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
        goto (16|M0)                         L2960                  L4544                
L2960:
        join (16|M0)                         L4544                                
L2976:
        add3 (16|M0)             r22.0<1>:d    r96.0<1;0>:d      -r74.0<1;0>:d     23:w              
        cmp (16|M0)   (lt)f1.1   null<1>:d     r22.0<1;1,0>:d    2:w               {I@1}
(f1.1)  goto (16|M0)                         L3128                  L3128                
L3024:
        cmp (16|M0)   (eq)f1.0   null<1>:d     r22.0<1;1,0>:d    2:w              
(~f1.0) goto (16|M0)                         L3128                  L3232                
L3056:
        shr (16|M0)              r74.0<1>:ud   r48.0<1;1,0>:ud   1:w              
        mov (16|M0)              r116.0<1>:d   0:w                              
        mov (16|M0)              r12.0<1>:d    0:w                              
        mov (16|M0)              r112.0<1>:f   r74.0<1;1,0>:f                   {Compacted,I@3}
        goto (16|M0)                         L3128                  L4032                
L3128:
        join (16|M0)                         L3232                                
L3144:
        cmp (16|M0)   (eq)f0.1   null<1>:d     r22.0<1;1,0>:d    1:w              
(~f0.1) goto (16|M0)                         L3232                  L3232                
L3176:
        mov (16|M0)              r116.0<1>:d   0:w                              
        mov (16|M0)              r12.0<1>:d    0:w                              
        mov (16|M0)              r112.0<1>:f   r48.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L3232                  L4032                
L3232:
        join (16|M0)                         L4032                                
L3248:
        add3 (16|M0)             r2.0<1>:d     r96.0<1;0>:d      -r120.0<1;0>:d    -1:w              
        and (16|M0)   (ne)f0.0   r114.0<1>:d   r2.0<1;1,0>:d     63:w               {Compacted,I@1}
(f0.0)  goto (16|M0)                         L3312                  L3312                
L3288:
        mov (16|M0)              r80.0<1>:f    r48.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L3312                  L3424                
L3312:
        join (16|M0)                         L3424                                
L3328:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r114.0<1;1,0>:ud  0x20:uw              {I@4}
(~f1.1) add (16|M0)              r2.0<1>:d     r114.0<1;1,0>:d   -32:w              
(~f1.1) shr (16|M0)              r74.0<1>:ud   r52.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.1)  add (16|M0)              r2.0<1>:d     -r114.0<1;1,0>:d  32:w               {Compacted}
(f1.1)  shr (16|M0)              r8.0<1>:ud    r48.0<1;1,0>:ud   r114.0<1;1,0>:d 
(f1.1)  shl (16|M0)              r2.0<1>:d     r52.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.1)  or (16|M0)               r74.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
        mov (16|M0)              r80.0<1>:f    r74.0<1;1,0>:f                   {Compacted,I@1}
L3424:
        join (16|M0)                         L4032                                
L3440:
        add3 (16|M0)             r62.0<1>:d    r96.0<1;0>:d      -r120.0<1;0>:d    -2:w              
        and (16|M0)   (ne)f1.0   r112.0<1>:d   r62.0<1;1,0>:d    63:w               {A@1}
(f1.0)  goto (16|M0)                         L3512                  L3512                
L3488:
        mov (16|M0)              r74.0<1>:f    r48.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L3512                  L3616                
L3512:
        join (16|M0)                         L3616                                
L3528:
        cmp (16|M0)   (lt)f0.1   null<1>:d     r112.0<1;1,0>:ud  0x20:uw              {I@4}
(~f0.1) add (16|M0)              r2.0<1>:d     r112.0<1;1,0>:d   -32:w              
(~f0.1) shr (16|M0)              r74.0<1>:ud   r52.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f0.1)  add (16|M0)              r2.0<1>:d     -r112.0<1;1,0>:d  32:w               {Compacted}
(f0.1)  shr (16|M0)              r8.0<1>:ud    r48.0<1;1,0>:ud   r112.0<1;1,0>:d 
(f0.1)  shl (16|M0)              r2.0<1>:d     r52.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f0.1)  or (16|M0)               r74.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
L3616:
        join (16|M0)                         L4032                                
L3632:
        and (16|M0)   (ne)f0.0   r78.0<1>:d    r62.0<1;1,0>:d    63:w               {Compacted}
        and (16|M0)              r12.0<1>:d    r74.0<1;1,0>:d    1:w               {Compacted,I@3}
(f0.0)  goto (16|M0)                         L3712                  L3712                
L3664:
        mov (16|M0)              r82.0<1>:d    -1:w                              
        mov (16|M0)              r86.0<1>:d    -1:w                              
        goto (16|M0)                         L3712                  L3896                
L3712:
        join (16|M0)                         L3896                                
L3728:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r78.0<1;1,0>:ud   0x20:uw              {I@7}
(f1.1)  goto (16|M0)                         L3832                  L3832                
L3760:
        add (16|M0)              r2.0<1>:d     r78.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r4.12<1>:hf   -qnan(0x1FF):hf                             
        mov (16|M0)              r82.0<1>:d    0:w                              
        shl (16|M0)              r86.0<1>:d    r4.12<0;1,0>:w    r2.0<1;1,0>:d    {A@1}
        goto (16|M0)                         L3832                  L3896                
L3832:
        join (16|M0)                         L3896                                
L3848:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (16|M0)              r86.0<1>:d    -1:w                              
        shl (16|M0)              r82.0<1>:d    r2.0<0;1,0>:w     r78.0<1;1,0>:d   {F@1}
L3896:
        join (16|M0)                         L4032                                
L3912:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r82.0<1;0>:ud     r6.2<0;0>:ud      r48.0<1>:ud      {I@2} // (s0^s1)&s2
        cmp (16|M0)   (ne)f0.1   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
        bfn.0x60 (16|M0)         r8.0<1>:ud    r86.0<1;0>:ud     r6.2<0;0>:ud      r52.0<1>:ud      // (s0^s1)&s2
(~f0.1) cmp (16|M0)   (ne)f0.1   null<1>:d     r8.0<1;1,0>:d     0:w               {I@1}
(W)     mov (1|M0)               r4.12<1>:hf   -qnan(0x1FF):hf                             
        mov (16|M0)              r112.0<1>:f   r80.0<1;1,0>:f                   {Compacted}
(f0.1)  sel (16|M0)              r10.0<1>:d    r4.12<0;1,0>:w    0:w               {F@2}
        mov (16|M0)              r116.0<1>:d   -r10.0<1;1,0>:d                  {I@1}
L4032:
        join (16|M0)                         L4544                                
L4048:
        and (16|M0)   (ne)f1.0   r110.0<1>:d   r22.0<1;1,0>:d    63:w              
(f1.0)  goto (16|M0)                         L4104                  L4104                
L4080:
        mov (16|M0)              r74.0<1>:f    r48.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L4104                  L4208                
L4104:
        join (16|M0)                         L4208                                
L4120:
        cmp (16|M0)   (lt)f0.1   null<1>:d     r110.0<1;1,0>:ud  0x20:uw              {I@4}
(~f0.1) add (16|M0)              r2.0<1>:d     r110.0<1;1,0>:d   -32:w              
(~f0.1) shr (16|M0)              r74.0<1>:ud   r52.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f0.1)  add (16|M0)              r2.0<1>:d     -r110.0<1;1,0>:d  32:w               {Compacted}
(f0.1)  shr (16|M0)              r8.0<1>:ud    r48.0<1;1,0>:ud   r110.0<1;1,0>:d 
(f0.1)  shl (16|M0)              r2.0<1>:d     r52.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f0.1)  or (16|M0)               r74.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
L4208:
        join (16|M0)                         L4544                                
L4224:
        shl (16|M0)              r2.0<1>:d     r112.0<1;1,0>:d   2:w               {Compacted}
        shl (16|M0)              r8.0<1>:d     r12.0<1;1,0>:d    1:w               {Compacted}
        and (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     4:w               {Compacted,I@2}
        bfn.0xFE (16|M0)         r20.0<1>:ud   r2.0<1;0>:ud      r8.0<1;0>:ud      r116.0<1>:ud     {I@1} // s0|s1|s2
        cmp (16|M0)   (eq)f0.0   null<1>:d     r20.0<1;1,0>:d    0:w               {Compacted,I@1}
(~f0.0) goto (16|M0)                         L4320                  L4320                
L4288:
        mov (16|M0)              r28.0<1>:d    0:w                              
        goto (16|M0)                         L4320                  L4472                
L4320:
        join (16|M0)                         L4472                                
L4336:
        cmp (16|M0)   (gt)f1.1   null<1>:d     r20.0<1;1,0>:ud   0x4:uw             
(~f1.1) goto (16|M0)                         L4400                  L4400                
L4368:
        mov (16|M0)              r28.0<1>:d    1:w                              
        goto (16|M0)                         L4400                  L4472                
L4400:
        join (16|M0)                         L4472                                
L4416:
        and (16|M0)   (ne)f0.0   null<1>:d     r74.0<1;1,0>:d    1:w               {Compacted}
(W)     mov (1|M0)               r2.0<1>:hf    0x1:hf                             
(f0.0)  cmp (16|M0)   (eq)f0.0   null<1>:d     r20.0<1;1,0>:d    4:w              
(f0.0)  sel (16|M0)              r28.0<1>:d    r2.0<0;1,0>:w     0:w               {F@1}
L4472:
        join (16|M0)                         L4544                                
L4488:
        add (16|M0)              r2.0<1>:d     r28.0<1;1,0>:d    r74.0<1;1,0>:d   {Compacted,I@2}
        cmp (16|M0)   (gt)f0.1   null<1>:d     r2.0<1;1,0>:ud    0x7FFFFF:ud              {I@1}
(W)     mov (1|M0)               r4.6<1>:f     0x800000:f                               {Compacted}
(~f0.1) sel (16|M0)              r30.0<1>:d    r2.0<1;1,0>:d     0:w              
(f0.1)  sel (16|M0)              r28.0<1>:d    r4.6<0;1,0>:d     0:w               {Compacted,F@1}
L4544:
        join (16|M0)                         L4608                                
L4560:
        and (16|M0)              r2.0<1>:d     r44.0<1;1,0>:d    -2147483648:d              
        bfn.0xFE (16|M0)         r78.0<1>:ud   r2.0<1;0>:ud      r28.0<1;0>:ud     r30.0<1>:ud      {I@1} // s0|s1|s2
        goto (16|M0)                         L4608                  L7624                
L4608:
        join (16|M0)                         L5104                                
L4624:
        and (16|M0)   (ne)f1.0   r56.0<1>:d    r58.0<1;1,0>:d    63:w              
(f1.0)  goto (16|M0)                         L4704                  L4704                
L4656:
        mov (16|M0)              r72.0<1>:d    -1:w                              
        mov (16|M0)              r76.0<1>:d    -1:w                              
        goto (16|M0)                         L4704                  L4888                
L4704:
        join (16|M0)                         L4888                                
L4720:
        cmp (16|M0)   (lt)f0.1   null<1>:d     r56.0<1;1,0>:ud   0x20:uw              {I@6}
(f0.1)  goto (16|M0)                         L4824                  L4824                
L4752:
        add (16|M0)              r2.0<1>:d     r56.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r4.12<1>:hf   -qnan(0x1FF):hf                             
        mov (16|M0)              r72.0<1>:d    0:w                              
        shl (16|M0)              r76.0<1>:d    r4.12<0;1,0>:w    r2.0<1;1,0>:d    {A@1}
        goto (16|M0)                         L4824                  L4888                
L4824:
        join (16|M0)                         L4888                                
L4840:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (16|M0)              r76.0<1>:d    -1:w                              
        shl (16|M0)              r72.0<1>:d    r2.0<0;1,0>:w     r56.0<1;1,0>:d   {F@1}
L4888:
        join (16|M0)                         L5104                                
L4904:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r72.0<1;0>:ud     r6.2<0;0>:ud      r48.0<1>:ud      {I@2} // (s0^s1)&s2
        cmp (16|M0)   (ne)f0.1   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
        bfn.0x60 (16|M0)         r8.0<1>:ud    r76.0<1;0>:ud     r6.2<0;0>:ud      r52.0<1>:ud      // (s0^s1)&s2
        cmp (16|M0)   (gt)f0.0   null<1>:d     r44.0<1;1,0>:d    -1:w               {Compacted}
(~f0.1) cmp (16|M0)   (ne)f0.1   null<1>:d     r8.0<1;1,0>:d     0:w               {I@2}
(f0.1)  cmp (16|M0)   (eq)f0.1   null<1>:d     r14.0<1;1,0>:d    -150:w              
(f0.0)  goto (16|M0)                         L5048                  L5048                
L5008:
(W)     mov (1|M0)               r2.0<1>:ud    0x80000001:ud                             
(f0.1)  sel (16|M0)              r78.0<1>:f    r2.0<0;1,0>:f     -0.0:f               {Compacted,I@1}
        goto (16|M0)                         L5048                  L7624                
L5048:
        join (16|M0)                         L5104                                
L5064:
(W)     mov (1|M0)               r2.0<1>:ud    0x1:ud                              {F@1}
(f0.1)  sel (16|M0)              r78.0<1>:f    r2.0<0;1,0>:f     0.0:f               {Compacted,I@1}
        goto (16|M0)                         L5104                  L7624                
L5104:
        join (16|M0)                         L7408                                
L5120:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r58.0<1;1,0>:ud   0x18:uw             
        add3 (16|M0)             r66.0<1>:d    r56.0<1;0>:d      r58.0<1;0>:d      -46:w              
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r76.0<1;1,0>:d    0:w              
(f1.1)  goto (16|M0)                         L7104                  L7104                
L5184:
        shl (16|M0)              r2.0<1>:d     r70.0<1;1,0>:d    1:w               {Compacted,F@1}
        shr (16|M0)              r8.0<1>:ud    r70.0<1;1,0>:ud   31:w              
        shl (16|M0)              r10.0<1>:d    r102.0<1;1,0>:d   1:w               {Compacted}
        cmp (16|M0)   (lt)f1.0   null<1>:d     r2.0<1;1,0>:ud    0x4E:uw              {I@3}
        or (16|M0)               r10.0<1>:d    r10.0<1;1,0>:d    r8.0<1;1,0>:d    {Compacted,I@2}
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r10.0<1;1,0>:d    0:w               {I@1}
(~f1.0) cmp (16|M0)   (lt)f1.0   null<1>:d     r10.0<1;1,0>:d    0:w              
(f1.0)  goto (16|M0)                         L5416                  L5416                
L5288:
        cmp (16|M0)   (eq)f1.0   null<1>:d     r70.0<1;1,0>:d    39:w              
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r102.0<1;1,0>:d   0:w              
(~f1.0) goto (16|M0)                         L5416                  L5480                
L5336:
        shr (16|M0)              r74.0<1>:ud   r48.0<1;1,0>:ud   1:w              
        mov (16|M0)              r126.0<1>:d   0:w                              
        mov (16|M0)              r14.0<1>:d    0:w                              
        mov (16|M0)              r10.0<1>:f    r74.0<1;1,0>:f                   {Compacted,I@3}
        mov (16|M0)              r74.0<1>:f    r48.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L5416                  L6576                
L5416:
        join (16|M0)                         L5480                                
L5432:
        cmp (16|M0)   (eq)f0.1   null<1>:d     r70.0<1;1,0>:d    38:w              
(f0.1)  cmp (16|M0)   (eq)f0.1   null<1>:d     r102.0<1;1,0>:d   0:w              
(f0.1)  goto (16|M0)                         L5480                  L6488                
L5480:
        join (16|M0)                         L6488                                
L5496:
        add (16|M0)              r2.0<1>:d     -r70.0<1;1,0>:d   39:w               {Compacted}
        and (16|M0)   (ne)f1.1   r122.0<1>:d   r2.0<1;1,0>:d     63:w               {I@1}
        add (16|M0)              r98.0<1>:d    -r70.0<1;1,0>:d   40:w               {Compacted}
(f1.1)  goto (16|M0)                         L5568                  L5568                
L5544:
        mov (16|M0)              r88.0<1>:f    r48.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L5568                  L5680                
L5568:
        join (16|M0)                         L5680                                
L5584:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r122.0<1;1,0>:ud  0x20:uw              {I@5}
(~f1.0) add (16|M0)              r2.0<1>:d     r122.0<1;1,0>:d   -32:w              
(~f1.0) shr (16|M0)              r74.0<1>:ud   r52.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.0)  add (16|M0)              r2.0<1>:d     -r122.0<1;1,0>:d  32:w               {Compacted}
(f1.0)  shr (16|M0)              r8.0<1>:ud    r48.0<1;1,0>:ud   r122.0<1;1,0>:d 
(f1.0)  shl (16|M0)              r2.0<1>:d     r52.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.0)  or (16|M0)               r74.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
        mov (16|M0)              r88.0<1>:f    r74.0<1;1,0>:f                   {Compacted,I@1}
L5680:
        join (16|M0)                         L6488                                
L5696:
        add (16|M0)              r68.0<1>:d    -r70.0<1;1,0>:d   38:w               {Compacted}
        and (16|M0)   (ne)f0.1   r126.0<1>:d   r68.0<1;1,0>:d    63:w               {I@1}
(f0.1)  goto (16|M0)                         L5760                  L5760                
L5736:
        mov (16|M0)              r74.0<1>:f    r48.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L5760                  L5864                
L5760:
        join (16|M0)                         L5864                                
L5776:
        cmp (16|M0)   (lt)f0.0   null<1>:d     r126.0<1;1,0>:ud  0x20:uw              {I@4}
(~f0.0) add (16|M0)              r2.0<1>:d     r126.0<1;1,0>:d   -32:w              
(~f0.0) shr (16|M0)              r74.0<1>:ud   r52.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f0.0)  add (16|M0)              r2.0<1>:d     -r126.0<1;1,0>:d  32:w               {Compacted}
(f0.0)  shr (16|M0)              r8.0<1>:ud    r48.0<1;1,0>:ud   r126.0<1;1,0>:d 
(f0.0)  shl (16|M0)              r2.0<1>:d     r52.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f0.0)  or (16|M0)               r74.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
L5864:
        join (16|M0)                         L6488                                
L5880:
        and (16|M0)   (ne)f1.1   r90.0<1>:d    r68.0<1;1,0>:d    63:w              
        and (16|M0)              r14.0<1>:d    r74.0<1;1,0>:d    1:w               {Compacted,I@3}
(f1.1)  goto (16|M0)                         L5968                  L5968                
L5920:
        mov (16|M0)              r102.0<1>:d   -1:w                              
        mov (16|M0)              r108.0<1>:d   -1:w                              
        goto (16|M0)                         L5968                  L6152                
L5968:
        join (16|M0)                         L6152                                
L5984:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r90.0<1;1,0>:ud   0x20:uw              {I@7}
(f1.0)  goto (16|M0)                         L6088                  L6088                
L6016:
        add (16|M0)              r2.0<1>:d     r90.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r4.12<1>:hf   -qnan(0x1FF):hf                             
        mov (16|M0)              r102.0<1>:d   0:w                              
        shl (16|M0)              r108.0<1>:d   r4.12<0;1,0>:w    r2.0<1;1,0>:d    {A@1}
        goto (16|M0)                         L6088                  L6152                
L6088:
        join (16|M0)                         L6152                                
L6104:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (16|M0)              r108.0<1>:d   -1:w                              
        shl (16|M0)              r102.0<1>:d   r2.0<0;1,0>:w     r90.0<1;1,0>:d   {F@1}
L6152:
        join (16|M0)                         L6488                                
L6168:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r102.0<1;0>:ud    r6.2<0;0>:ud      r48.0<1>:ud      {I@2} // (s0^s1)&s2
        cmp (16|M0)   (ne)f0.0   null<1>:d     r2.0<1;1,0>:d     0:w               {Compacted,I@1}
        bfn.0x60 (16|M0)         r8.0<1>:ud    r108.0<1;0>:ud    r6.2<0;0>:ud      r52.0<1>:ud      // (s0^s1)&s2
(~f0.0) cmp (16|M0)   (ne)f0.0   null<1>:d     r8.0<1;1,0>:d     0:w               {I@1}
(W)     mov (1|M0)               r4.12<1>:hf   -qnan(0x1FF):hf                             
        and (16|M0)   (ne)f0.1   r124.0<1>:d   r98.0<1;1,0>:d    63:w              
(f0.0)  sel (16|M0)              r10.0<1>:d    r4.12<0;1,0>:w    0:w               {F@1}
        mov (16|M0)              r126.0<1>:d   -r10.0<1;1,0>:d                  {I@1}
(f0.1)  goto (16|M0)                         L6328                  L6328                
L6304:
        mov (16|M0)              r74.0<1>:f    r48.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L6328                  L6432                
L6328:
        join (16|M0)                         L6432                                
L6344:
        cmp (16|M0)   (lt)f0.0   null<1>:d     r124.0<1;1,0>:ud  0x20:uw             
(~f0.0) add (16|M0)              r2.0<1>:d     r124.0<1;1,0>:d   -32:w              
(~f0.0) shr (16|M0)              r74.0<1>:ud   r52.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f0.0)  add (16|M0)              r2.0<1>:d     -r124.0<1;1,0>:d  32:w               {Compacted}
(f0.0)  shr (16|M0)              r8.0<1>:ud    r48.0<1;1,0>:ud   r124.0<1;1,0>:d 
(f0.0)  shl (16|M0)              r2.0<1>:d     r52.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f0.0)  or (16|M0)               r74.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
L6432:
        join (16|M0)                         L6488                                
L6448:
        mov (16|M0)              r10.0<1>:f    r74.0<1;1,0>:f                   {Compacted,I@2}
        mov (16|M0)              r74.0<1>:d    r88.0<1;1,0>:d                   {F@1}
        goto (16|M0)                         L6488                  L6576                
L6488:
        join (16|M0)                         L6576                                
L6504:
        shr (16|M0)              r74.0<1>:ud   r48.0<1;1,0>:ud   2:w              
        mov (16|M0)              r126.0<1>:d   0:w                              
        mov (16|M0)              r14.0<1>:d    0:w                              
        mov (16|M0)              r10.0<1>:f    r74.0<1;1,0>:f                   {Compacted,I@3}
        shr (16|M0)              r74.0<1>:ud   r48.0<1;1,0>:ud   1:w               {F@1}
L6576:
        join (16|M0)                         L7104                                
L6592:
        shl (16|M0)              r2.0<1>:d     r74.0<1;1,0>:d    2:w               {Compacted,I@2}
        shl (16|M0)              r8.0<1>:d     r14.0<1;1,0>:d    1:w               {Compacted}
        and (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     4:w               {Compacted,I@2}
        bfn.0xFE (16|M0)         r70.0<1>:ud   r2.0<1;0>:ud      r8.0<1;0>:ud      r126.0<1>:ud     {I@1} // s0|s1|s2
        cmp (16|M0)   (eq)f1.1   null<1>:d     r70.0<1;1,0>:d    0:w               {I@1}
        and (16|M0)              r92.0<1>:d    r10.0<1;1,0>:d    8388607:d              
(~f1.1) goto (16|M0)                         L6712                  L6712                
L6680:
        mov (16|M0)              r54.0<1>:d    0:w                              
        goto (16|M0)                         L6712                  L6872                
L6712:
        join (16|M0)                         L6872                                
L6728:
        cmp (16|M0)   (gt)f1.0   null<1>:d     r70.0<1;1,0>:ud   0x4:uw             
(~f1.0) goto (16|M0)                         L6792                  L6792                
L6760:
        mov (16|M0)              r54.0<1>:d    1:w                              
        goto (16|M0)                         L6792                  L6872                
L6792:
        join (16|M0)                         L6872                                
L6808:
        and (16|M0)   (ne)f1.1   null<1>:d     r10.0<1;1,0>:d    1:w              
(W)     mov (1|M0)               r2.0<1>:hf    0x1:hf                             
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r70.0<1;1,0>:d    4:w              
(f1.1)  sel (16|M0)              r54.0<1>:d    r2.0<0;1,0>:w     0:w               {F@1}
L6872:
        join (16|M0)                         L7104                                
L6888:
        add (16|M0)              r48.0<1>:d    r92.0<1;1,0>:d    r54.0<1;1,0>:d   {Compacted,I@2}
        cmp (16|M0)   (gt)f1.1   null<1>:d     r48.0<1;1,0>:ud   0x7FFFFF:ud              {I@1}
        add3 (16|M0)             r2.0<1>:d     r56.0<1;0>:d      r58.0<1;0>:d      -45:w              
(f1.1)  sel (16|M0)              r46.0<1>:d    r2.0<1;1,0>:d     r66.0<1;1,0>:d   {Compacted,I@1}
        cmp (16|M0)   (eq)f0.1   null<1>:d     r46.0<1;1,0>:d    255:w               {I@1}
(f0.1)  goto (16|M0)                         L7040                  L7040                
L6968:
(~f1.1) sel (16|M0)              r2.0<1>:d     r48.0<1;1,0>:d    0:w              
        and (16|M0)              r8.0<1>:d     r44.0<1;1,0>:d    -2147483648:d              
        shl (16|M0)              r10.0<1>:d    r46.0<1;1,0>:d    23:w               {Compacted}
        bfn.0xFE (16|M0)         r78.0<1>:ud   r8.0<1;0>:ud      r10.0<1;0>:ud     r2.0<1>:ud       {I@1} // s0|s1|s2
        goto (16|M0)                         L7040                  L7624                
L7040:
        join (16|M0)                         L7104                                
L7056:
        cmp (16|M0)   (gt)f0.1   null<1>:d     r44.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r2.0<1>:f     inf:f                               {Compacted,I@4}
(f0.1)  sel (16|M0)              r78.0<1>:f    r2.0<0;1,0>:f     -inf:f               {Compacted,F@1}
        goto (16|M0)                         L7104                  L7624                
L7104:
        join (16|M0)                         L7408                                
L7120:
        and (16|M0)   (ne)f0.0   r26.0<1>:d    r58.0<1;1,0>:d    63:w               {Compacted}
(f0.0)  goto (16|M0)                         L7176                  L7176                
L7144:
        mov (16|M0)              r42.0<1>:d    -1:w                              
        goto (16|M0)                         L7176                  L7304                
L7176:
        join (16|M0)                         L7304                                
L7192:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r26.0<1;1,0>:ud   0x20:uw              {I@5}
(f1.1)  goto (16|M0)                         L7256                  L7256                
L7224:
        mov (16|M0)              r42.0<1>:d    0:w                              
        goto (16|M0)                         L7256                  L7304                
L7256:
        join (16|M0)                         L7304                                
L7272:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                             
        shl (16|M0)              r42.0<1>:d    r2.0<0;1,0>:w     r26.0<1;1,0>:d   {F@1}
L7304:
        join (16|M0)                         L7408                                
L7320:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r42.0<1;0>:ud     r6.2<0;0>:ud      r48.0<1>:ud      {I@2} // (s0^s1)&s2
        add (16|M0)              r8.0<1>:d     -r58.0<1;1,0>:d   23:w               {Compacted}
        and (16|M0)              r10.0<1>:d    r44.0<1;1,0>:d    -2147483648:d              
        shl (16|M0)              r12.0<1>:d    r66.0<1;1,0>:d    23:w               {Compacted}
        shl (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     r8.0<1;1,0>:d    {Compacted,I@3}
        bfn.0xFE (16|M0)         r78.0<1>:ud   r10.0<1;0>:ud     r12.0<1;0>:ud     r2.0<1>:ud       {I@1} // s0|s1|s2
        goto (16|M0)                         L7408                  L7624                
L7408:
        join (16|M0)                         L7464                                
L7424:
        cmp (16|M0)   (gt)f0.0   null<1>:d     r44.0<1;1,0>:d    -1:w               {Compacted}
(W)     mov (1|M0)               r2.0<1>:f     inf:f                               {Compacted,I@4}
(f0.0)  sel (16|M0)              r78.0<1>:f    r2.0<0;1,0>:f     -inf:f               {Compacted,F@1}
        goto (16|M0)                         L7464                  L7624                
L7464:
        join (16|M0)                         L7528                                
L7480:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r44.0<1;1,0>:d    0:w              
(W)     mov (1|M0)               r2.0<1>:f     -0.0:f                               {Compacted}
(f1.1)  sel (16|M0)              r78.0<1>:f    r2.0<0;1,0>:f     0.0:f               {Compacted,F@1}
        goto (16|M0)                         L7528                  L7624                
L7528:
        join (16|M0)                         L7592                                
L7544:
        cmp (16|M0)   (gt)f1.0   null<1>:d     r44.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r2.0<1>:f     inf:f                               {Compacted}
(f1.0)  sel (16|M0)              r78.0<1>:f    r2.0<0;1,0>:f     -inf:f               {Compacted,F@1}
        goto (16|M0)                         L7592                  L7624                
L7592:
        join (16|M0)                         L7624                                
L7608:
        bfn.0xF8 (16|M0)         r78.0<1>:ud   r44.0<1;0>:ud     r6.4<0;0>:ud      r6.3<0>:ud       {F@1} // s0&s1|s2
L7624:
        join (16|M0)                         L13832                                
L7640:
        rnde (16|M0)             r68.0<1>:f    r78.0<1;1,0>:f                   {Compacted,I@2}
        shr (16|M0)              r56.0<1>:ud   r68.0<1;1,0>:ud   23:w               {F@1}
        and (16|M0)   (ne)f1.0   r100.0<1>:d   r68.0<1;1,0>:d    8388607:d              
        and (16|M0)              r98.0<1>:d    r56.0<1;1,0>:d    255:w               {Compacted,I@2}
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r98.0<1;1,0>:d    255:w               {I@1}
(~f1.0) goto (16|M0)                         L7752                  L7752                
L7720:
        mov (16|M0)              r76.0<1>:ud   0x7FC00000:ud                             
        goto (16|M0)                         L7752                  L13680                
L7752:
        join (16|M0)                         L13680                                
L7768:
        cmp (16|M0)   (eq)f0.1   null<1>:d     r100.0<1;1,0>:d   0:w              
        add (16|M0)              r2.0<1>:d     r40.0<1;1,0>:d    -25165824:d              
        shr (16|M0)              r50.0<1>:ud   r2.0<1;1,0>:ud    23:w               {I@1}
(f0.1)  cmp (16|M0)   (eq)f0.1   null<1>:d     r98.0<1;1,0>:d    255:w              
        and (16|M0)              r62.0<1>:d    r50.0<1;1,0>:d    255:w               {Compacted,I@2}
(~f0.1) cmp (16|M0)   (eq)f0.1   null<1>:d     r62.0<1;1,0>:d    255:w               {I@1}
        xor (16|M0)              r42.0<1>:d    r2.0<1;1,0>:d     r68.0<1;1,0>:d   {Compacted}
(f0.1)  goto (16|M0)                         L13648                  L13648                
L7880:
        cmp (16|M0)   (eq)f0.1   null<1>:d     r62.0<1;1,0>:d    0:w              
        or (16|M0)               r2.0<1>:d     r98.0<1;1,0>:d    r100.0<1;1,0>:d  {Compacted}
(~f0.1) cmp (16|M0)   (eq)f0.1   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
(~f0.1) goto (16|M0)                         L7968                  L7968                
L7936:
        mov (16|M0)              r76.0<1>:ud   0x0:ud                             
        goto (16|M0)                         L7968                  L13680                
L7968:
        join (16|M0)                         L13648                                
L7984:
        cmp (16|M0)   (eq)f0.0   null<1>:d     r98.0<1;1,0>:d    0:w               {Compacted}
        add (16|M0)              r44.0<1>:d    r98.0<1;1,0>:d    -127:w               {Compacted}
(f0.0)  mov (16|M0)              r44.0<1>:d    -126:w                              
        add (16|M0)              r54.0<1>:d    r62.0<1;1,0>:d    r44.0<1;1,0>:d   {Compacted,I@1}
        cmp (16|M0)   (gt)f1.0   null<1>:d     r54.0<1;1,0>:d    254:w               {I@1}
(f1.0)  goto (16|M0)                         L13584                  L13584                
L8056:
        or (16|M0)    (eq)f0.1   null<4>:b     r56.0<1;1,0>:d    r50.0<1;1,0>:d  
(f0.1)  goto (16|M0)                         L13520                  L13520                
L8088:
(W)     mov (1|M0)               r2.0<1>:hf    0.0:hf                             
(W)     mov (1|M0)               r5.4<1>:d     0:w                              
(f0.0)  sel (16|M0)              r8.0<1>:d     r2.0<0;1,0>:w     8388608:d               {F@1}
        or (16|M0)               r8.0<1>:d     r8.0<1;1,0>:d     r100.0<1;1,0>:d  {Compacted,I@1}
        shl (16|M0)              r46.0<1>:d    r8.0<1;1,0>:d     23:w               {Compacted,I@1}
        shr (16|M0)              r50.0<1>:ud   r8.0<1;1,0>:ud    9:w              
(W)     mov (1|M0)               r5.3<1>:f     -0.0:f                               {Compacted}
(W)     mov (2|M0)               r5.0<1>:d     0:w                              
L8192:
(W)     shl (1|M0)               r2.0<1>:d     r5.3<0;1,0>:d     31:w               {Compacted,F@1}
(W)     shr (1|M0)               r2.1<1>:ud    r5.4<0;1,0>:ud    1:w              
(W)     cmp (16|M0)   (gt)f0.1   null<1>:d     r5.0<0;1,0>:ud    0x3E:uw              {I@3}
(W)     or (1|M0)                r5.4<1>:d     r2.1<0;1,0>:d     r2.0<0;1,0>:d    {I@2}
        bfn.0xE0 (16|M0)         r8.0<1>:ud    r2.1<0;0>:ud      r2.0<0;0>:ud      r46.0<1>:ud      // (s0|s1)&s2
(W)     shr (1|M0)               r5.2<1>:ud    r5.3<0;1,0>:ud    1:w              
(W&f0.1) cmp (16|M0)  (eq)f0.1   null<1>:d     r5.1<0;1,0>:d     0:w              
        cmp (16|M0)   (eq)f1.1   null<1>:d     r8.0<1;1,0>:d     r5.4<0;1,0>:d    {I@3}
        and (16|M0)              r10.0<1>:d    r5.2<0;1,0>:d     r50.0<1;1,0>:d   {Compacted,I@3}
(W&~f0.1) cmp (16|M0) (gt)f0.1   null<1>:d     r5.1<0;1,0>:ud    0x0:uw             
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r10.0<1;1,0>:d    r5.2<0;1,0>:d    {I@2}
(W)     mov (1|M0)               r4.12<1>:hf   0x1:hf                             
(W)     addc (1|M0)              r13.0<1>:ud   r5.0<0;1,0>:ud    0x1:ud              {AccWrEn}
(f0.1)  sel (16|M0)              r7.0<1>:uw    r4.12<0;1,0>:uw   0x0:uw              {Compacted,F@1}
(f1.1)  sel (16|M0)              acc2.0<1>:uw  r4.12<0;1,0>:uw   0x0:uw             
(W)     mov (1|M0)               r3.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        or (16|M0)    (ne)f0.1   null<1>:uw    r7.0<1;1,0>:uw    acc2.0<1;1,0>:uw {I@3}
(W)     add (1|M0)               r5.5<1>:ud    r3.0<0;1,0>:ud    r5.1<0;1,0>:ud   {I@2}
        mov (16|M0)              r88.0<1>:f    r5.0<0;1,0>:f                    {Compacted}
        mov (16|M0)              r86.0<1>:d    r5.1<0;1,0>:d                   
        mov (16|M0)              r68.0<1>:f    r13.0<0;1,0>:f                   {Compacted}
        mov (16|M0)              r100.0<1>:d   r5.5<0;1,0>:d                    {I@2}
(f0.1)  goto (16|M0)                         L8568                  L8568                
L8512:
(W)     mov (1|M0)               r5.3<1>:d     r5.2<0;1,0>:d                   
(W)     mov (1|M0)               r5.0<1>:f     r13.0<0;1,0>:f                   {Compacted}
(W)     mov (1|M0)               r5.1<1>:d     r5.5<0;1,0>:d                   
(W)     jmpi                                 L8192                                
L8568:
        join (16|M0)                         L13520                                
L8584:
(W)     mov (1|M0)               r2.0<1>:f     8.68805e-44:f                              
(W)     mov (1|M0)               r3.0<1>:hf    0.0:hf                             
        subb (8|M0)              r60.0<1>:ud   r2.0<0;1,0>:ud    r88.0<1;1,0>:ud  {AccWrEn,Compacted,F@2}
        add3 (8|M0)              r72.0<1>:ud   -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r86.0<1>:ud     {A@1}
        subb (8|M8)              r61.0<1>:ud   r2.0<0;1,0>:ud    r89.0<1;1,0>:ud  {AccWrEn}
        add3 (16|M0)             r12.0<1>:d    r54.0<1;0>:d      r60.0<1;0>:d      -173:w               {I@1}
        cmp (16|M0)   (gt)f0.0   null<1>:d     r12.0<1;1,0>:d    127:w               {Compacted,I@1}
        add3 (8|M8)              r73.0<1>:ud   -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r87.0<1>:ud    
        add3 (16|M0)             r70.0<1>:d    r62.0<1;0>:d      r44.0<1;0>:d      r60.0<1>:d      
(f0.0)  goto (16|M0)                         L13464                  L13464                
L8728:
        cmp (16|M0)   (gt)f1.1   null<1>:d     r12.0<1;1,0>:d    -127:w              
(f1.1)  goto (16|M0)                         L11152                  L11152                
L8760:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r12.0<1;1,0>:ud   0xFFFFFF6B:ud             
(f1.0)  goto (16|M0)                         L10664                  L10664                
L8792:
(W)     mov (1|M0)               r2.0<1>:f     8.82818e-44:f                              
(W)     mov (1|M0)               r3.0<1>:hf    0.0:hf                              {I@7}
        subb (8|M0)              r94.0<1>:ud   r2.0<0;1,0>:ud    r88.0<1;1,0>:ud  {AccWrEn,Compacted,F@2}
        add3 (16|M0)             r114.0<1>:d   r54.0<1;0>:d      r60.0<1;0>:d      -23:w              
        add3 (8|M0)              r8.0<1>:ud    -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r86.0<1>:ud     {F@1}
        subb (8|M8)              r95.0<1>:ud   r2.0<0;1,0>:ud    r89.0<1;1,0>:ud  {AccWrEn}
        cmp (16|M0)   (gt)f0.0   null<1>:d     r94.0<1;1,0>:ud   r114.0<1;1,0>:ud {I@1}
        add3 (8|M8)              r9.0<1>:ud    -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r87.0<1>:ud    
(f0.0)  cmp (16|M0)   (eq)f0.0   null<1>:d     r8.0<1;1,0>:d     0:w               {I@1}
(~f0.0) cmp (16|M0)   (gt)f0.0   null<1>:d     r8.0<1;1,0>:ud    0x0:uw             
(f0.0)  goto (16|M0)                         L9016                  L9016                
L8960:
        add3 (16|M0)             r2.0<1>:d     r70.0<1;0>:d      -r94.0<1;0>:d     -23:w              
        mov (16|M0)              r20.0<1>:d    0:w                              
        shl (16|M0)              r22.0<1>:d    r46.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
        goto (16|M0)                         L9016                  L10600                
L9016:
        join (16|M0)                         L10600                                
L9032:
        add3 (16|M0)             r24.0<1>:d    r94.0<1;0>:d      -r70.0<1;0>:d     23:w              
        cmp (16|M0)   (lt)f0.1   null<1>:d     r24.0<1;1,0>:d    2:w               {I@1}
(f0.1)  goto (16|M0)                         L9176                  L9176                
L9080:
        cmp (16|M0)   (eq)f0.0   null<1>:d     r24.0<1;1,0>:d    2:w               {Compacted}
(~f0.0) goto (16|M0)                         L9176                  L9280                
L9104:
        shr (16|M0)              r64.0<1>:ud   r46.0<1;1,0>:ud   1:w              
        mov (16|M0)              r118.0<1>:d   0:w                              
        mov (16|M0)              r106.0<1>:d   0:w                              
        mov (16|M0)              r98.0<1>:f    r64.0<1;1,0>:f                   {Compacted,I@3}
        goto (16|M0)                         L9176                  L10088                
L9176:
        join (16|M0)                         L9280                                
L9192:
        cmp (16|M0)   (eq)f1.1   null<1>:d     r24.0<1;1,0>:d    1:w              
(~f1.1) goto (16|M0)                         L9280                  L9280                
L9224:
        mov (16|M0)              r118.0<1>:d   0:w                              
        mov (16|M0)              r106.0<1>:d   0:w                              
        mov (16|M0)              r98.0<1>:f    r46.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L9280                  L10088                
L9280:
        join (16|M0)                         L10088                                
L9296:
        add3 (16|M0)             r2.0<1>:d     r94.0<1;0>:d      -r114.0<1;0>:d    -1:w              
        and (16|M0)   (ne)f1.0   r108.0<1>:d   r2.0<1;1,0>:d     63:w               {I@1}
(f1.0)  goto (16|M0)                         L9368                  L9368                
L9344:
        mov (16|M0)              r82.0<1>:f    r46.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L9368                  L9480                
L9368:
        join (16|M0)                         L9480                                
L9384:
        cmp (16|M0)   (lt)f0.1   null<1>:d     r108.0<1;1,0>:ud  0x20:uw              {I@4}
(~f0.1) add (16|M0)              r2.0<1>:d     r108.0<1;1,0>:d   -32:w              
(~f0.1) shr (16|M0)              r64.0<1>:ud   r50.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f0.1)  add (16|M0)              r2.0<1>:d     -r108.0<1;1,0>:d  32:w               {Compacted}
(f0.1)  shr (16|M0)              r8.0<1>:ud    r46.0<1;1,0>:ud   r108.0<1;1,0>:d 
(f0.1)  shl (16|M0)              r2.0<1>:d     r50.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f0.1)  or (16|M0)               r64.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
        mov (16|M0)              r82.0<1>:f    r64.0<1;1,0>:f                   {Compacted,I@1}
L9480:
        join (16|M0)                         L10088                                
L9496:
        add3 (16|M0)             r52.0<1>:d    r94.0<1;0>:d      -r114.0<1;0>:d    -2:w              
        and (16|M0)   (ne)f0.0   r106.0<1>:d   r52.0<1;1,0>:d    63:w               {Compacted,I@1}
(f0.0)  goto (16|M0)                         L9560                  L9560                
L9536:
        mov (16|M0)              r64.0<1>:f    r46.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L9560                  L9664                
L9560:
        join (16|M0)                         L9664                                
L9576:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r106.0<1;1,0>:ud  0x20:uw              {I@4}
(~f1.1) add (16|M0)              r2.0<1>:d     r106.0<1;1,0>:d   -32:w              
(~f1.1) shr (16|M0)              r64.0<1>:ud   r50.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.1)  add (16|M0)              r2.0<1>:d     -r106.0<1;1,0>:d  32:w               {Compacted}
(f1.1)  shr (16|M0)              r8.0<1>:ud    r46.0<1;1,0>:ud   r106.0<1;1,0>:d 
(f1.1)  shl (16|M0)              r2.0<1>:d     r50.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.1)  or (16|M0)               r64.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
L9664:
        join (16|M0)                         L10088                                
L9680:
        and (16|M0)   (ne)f1.0   r66.0<1>:d    r52.0<1;1,0>:d    63:w              
(f1.0)  goto (16|M0)                         L9760                  L9760                
L9712:
        mov (16|M0)              r74.0<1>:d    -1:w                              
        mov (16|M0)              r80.0<1>:d    -1:w                              
        goto (16|M0)                         L9760                  L9944                
L9760:
        join (16|M0)                         L9944                                
L9776:
        cmp (16|M0)   (lt)f0.1   null<1>:d     r66.0<1;1,0>:ud   0x20:uw              {I@6}
(f0.1)  goto (16|M0)                         L9880                  L9880                
L9808:
        add (16|M0)              r2.0<1>:d     r66.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r4.12<1>:hf   -qnan(0x1FF):hf                             
        mov (16|M0)              r74.0<1>:d    0:w                              
        shl (16|M0)              r80.0<1>:d    r4.12<0;1,0>:w    r2.0<1;1,0>:d    {A@1}
        goto (16|M0)                         L9880                  L9944                
L9880:
        join (16|M0)                         L9944                                
L9896:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (16|M0)              r80.0<1>:d    -1:w                              
        shl (16|M0)              r74.0<1>:d    r2.0<0;1,0>:w     r66.0<1;1,0>:d   {F@1}
L9944:
        join (16|M0)                         L10088                                
L9960:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r74.0<1;0>:ud     r6.2<0;0>:ud      r46.0<1>:ud      {I@2} // (s0^s1)&s2
        cmp (16|M0)   (ne)f0.0   null<1>:d     r2.0<1;1,0>:d     0:w               {Compacted,I@1}
        bfn.0x60 (16|M0)         r8.0<1>:ud    r80.0<1;0>:ud     r6.2<0;0>:ud      r50.0<1>:ud      // (s0^s1)&s2
(~f0.0) cmp (16|M0)   (ne)f0.0   null<1>:d     r8.0<1;1,0>:d     0:w               {I@1}
(W)     mov (1|M0)               r4.12<1>:hf   -qnan(0x1FF):hf                             
        shl (16|M0)              r12.0<1>:d    r64.0<1;1,0>:d    1:w               {Compacted}
(f0.0)  sel (16|M0)              r10.0<1>:d    r4.12<0;1,0>:w    0:w               {F@1}
        mov (16|M0)              r98.0<1>:f    r82.0<1;1,0>:f                   {Compacted}
        and (16|M0)              r106.0<1>:d   r12.0<1;1,0>:d    2:w               {Compacted,I@2}
        mov (16|M0)              r118.0<1>:d   -r10.0<1;1,0>:d                  {I@2}
L10088:
        join (16|M0)                         L10600                                
L10104:
        and (16|M0)   (ne)f0.0   r104.0<1>:d   r24.0<1;1,0>:d    63:w               {Compacted}
(f0.0)  goto (16|M0)                         L10152                  L10152                
L10128:
        mov (16|M0)              r64.0<1>:f    r46.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L10152                  L10256                
L10152:
        join (16|M0)                         L10256                                
L10168:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r104.0<1;1,0>:ud  0x20:uw              {I@4}
(~f1.1) add (16|M0)              r2.0<1>:d     r104.0<1;1,0>:d   -32:w              
(~f1.1) shr (16|M0)              r64.0<1>:ud   r50.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.1)  add (16|M0)              r2.0<1>:d     -r104.0<1;1,0>:d  32:w               {Compacted}
(f1.1)  shr (16|M0)              r8.0<1>:ud    r46.0<1;1,0>:ud   r104.0<1;1,0>:d 
(f1.1)  shl (16|M0)              r2.0<1>:d     r50.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.1)  or (16|M0)               r64.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
L10256:
        join (16|M0)                         L10600                                
L10272:
        shl (16|M0)              r2.0<1>:d     r98.0<1;1,0>:d    2:w               {Compacted}
        and (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     4:w               {Compacted,I@1}
        bfn.0xFE (16|M0)         r16.0<1>:ud   r2.0<1;0>:ud      r106.0<1;0>:ud    r118.0<1>:ud     {I@1} // s0|s1|s2
        cmp (16|M0)   (eq)f1.0   null<1>:d     r16.0<1;1,0>:d    0:w               {I@1}
(~f1.0) goto (16|M0)                         L10368                  L10368                
L10336:
        mov (16|M0)              r18.0<1>:d    0:w                              
        goto (16|M0)                         L10368                  L10528                
L10368:
        join (16|M0)                         L10528                                
L10384:
        cmp (16|M0)   (gt)f0.1   null<1>:d     r16.0<1;1,0>:ud   0x4:uw             
(~f0.1) goto (16|M0)                         L10448                  L10448                
L10416:
        mov (16|M0)              r18.0<1>:d    1:w                              
        goto (16|M0)                         L10448                  L10528                
L10448:
        join (16|M0)                         L10528                                
L10464:
        and (16|M0)   (ne)f1.1   null<1>:d     r64.0<1;1,0>:d    1:w              
(W)     mov (1|M0)               r2.0<1>:hf    0x1:hf                             
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r16.0<1;1,0>:d    4:w              
(f1.1)  sel (16|M0)              r18.0<1>:d    r2.0<0;1,0>:w     0:w               {F@1}
L10528:
        join (16|M0)                         L10600                                
L10544:
        add (16|M0)              r2.0<1>:d     r18.0<1;1,0>:d    r64.0<1;1,0>:d   {Compacted,I@2}
        cmp (16|M0)   (gt)f0.0   null<1>:d     r2.0<1;1,0>:ud    0x7FFFFF:ud              {I@1}
(W)     mov (1|M0)               r4.6<1>:f     0x800000:f                               {Compacted}
(~f0.0) sel (16|M0)              r22.0<1>:d    r2.0<1;1,0>:d     0:w              
(f0.0)  sel (16|M0)              r20.0<1>:d    r4.6<0;1,0>:d     0:w               {Compacted,F@1}
L10600:
        join (16|M0)                         L10664                                
L10616:
        and (16|M0)              r2.0<1>:d     r42.0<1;1,0>:d    -2147483648:d              
        bfn.0xFE (16|M0)         r76.0<1>:ud   r2.0<1;0>:ud      r20.0<1;0>:ud     r22.0<1>:ud      {I@1} // s0|s1|s2
        goto (16|M0)                         L10664                  L13680                
L10664:
        join (16|M0)                         L11152                                
L10680:
        and (16|M0)   (ne)f0.0   r40.0<1>:d    r60.0<1;1,0>:d    63:w               {Compacted}
(f0.0)  goto (16|M0)                         L10752                  L10752                
L10704:
        mov (16|M0)              r52.0<1>:d    -1:w                              
        mov (16|M0)              r64.0<1>:d    -1:w                              
        goto (16|M0)                         L10752                  L10936                
L10752:
        join (16|M0)                         L10936                                
L10768:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r40.0<1;1,0>:ud   0x20:uw              {I@6}
(f1.1)  goto (16|M0)                         L10872                  L10872                
L10800:
        add (16|M0)              r2.0<1>:d     r40.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r4.12<1>:hf   -qnan(0x1FF):hf                             
        mov (16|M0)              r52.0<1>:d    0:w                              
        shl (16|M0)              r64.0<1>:d    r4.12<0;1,0>:w    r2.0<1;1,0>:d    {A@1}
        goto (16|M0)                         L10872                  L10936                
L10872:
        join (16|M0)                         L10936                                
L10888:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (16|M0)              r64.0<1>:d    -1:w                              
        shl (16|M0)              r52.0<1>:d    r2.0<0;1,0>:w     r40.0<1;1,0>:d   {F@1}
L10936:
        join (16|M0)                         L11152                                
L10952:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r52.0<1;0>:ud     r6.2<0;0>:ud      r46.0<1>:ud      {I@2} // (s0^s1)&s2
        cmp (16|M0)   (ne)f0.0   null<1>:d     r2.0<1;1,0>:d     0:w               {Compacted,I@1}
        bfn.0x60 (16|M0)         r8.0<1>:ud    r64.0<1;0>:ud     r6.2<0;0>:ud      r50.0<1>:ud      // (s0^s1)&s2
        cmp (16|M0)   (gt)f1.0   null<1>:d     r42.0<1;1,0>:d    -1:w              
(~f0.0) cmp (16|M0)   (ne)f0.0   null<1>:d     r8.0<1;1,0>:d     0:w               {I@2}
(f0.0)  cmp (16|M0)   (eq)f0.0   null<1>:d     r12.0<1;1,0>:d    -150:w              
(f1.0)  goto (16|M0)                         L11096                  L11096                
L11056:
(W)     mov (1|M0)               r2.0<1>:ud    0x80000001:ud                             
(f0.0)  sel (16|M0)              r76.0<1>:f    r2.0<0;1,0>:f     -0.0:f               {Compacted,I@1}
        goto (16|M0)                         L11096                  L13680                
L11096:
        join (16|M0)                         L11152                                
L11112:
(W)     mov (1|M0)               r2.0<1>:ud    0x1:ud                              {F@1}
(f0.0)  sel (16|M0)              r76.0<1>:f    r2.0<0;1,0>:f     0.0:f               {Compacted,I@1}
        goto (16|M0)                         L11152                  L13680                
L11152:
        join (16|M0)                         L13464                                
L11168:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r60.0<1;1,0>:ud   0x18:uw             
        add3 (16|M0)             r62.0<1>:d    r54.0<1;0>:d      r60.0<1;0>:d      -46:w              
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r72.0<1;1,0>:d    0:w              
(f1.0)  goto (16|M0)                         L13152                  L13152                
L11232:
        shl (16|M0)              r2.0<1>:d     r68.0<1;1,0>:d    1:w               {Compacted,F@1}
        shr (16|M0)              r8.0<1>:ud    r68.0<1;1,0>:ud   31:w              
        shl (16|M0)              r10.0<1>:d    r100.0<1;1,0>:d   1:w               {Compacted}
        cmp (16|M0)   (lt)f1.1   null<1>:d     r2.0<1;1,0>:ud    0x4E:uw              {I@3}
        or (16|M0)               r10.0<1>:d    r10.0<1;1,0>:d    r8.0<1;1,0>:d    {Compacted,I@2}
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r10.0<1;1,0>:d    0:w               {I@1}
(~f1.1) cmp (16|M0)   (lt)f1.1   null<1>:d     r10.0<1;1,0>:d    0:w              
(f1.1)  goto (16|M0)                         L11464                  L11464                
L11336:
        cmp (16|M0)   (eq)f0.1   null<1>:d     r68.0<1;1,0>:d    39:w              
(f0.1)  cmp (16|M0)   (eq)f0.1   null<1>:d     r100.0<1;1,0>:d   0:w              
(~f0.1) goto (16|M0)                         L11464                  L11520                
L11384:
        shr (16|M0)              r64.0<1>:ud   r46.0<1;1,0>:ud   1:w              
        mov (16|M0)              r122.0<1>:d   0:w                              
        mov (16|M0)              r96.0<1>:d    0:w                              
        mov (16|M0)              r8.0<1>:f     r64.0<1;1,0>:f                   {Compacted,I@3}
        mov (16|M0)              r64.0<1>:f    r46.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L11464                  L12632                
L11464:
        join (16|M0)                         L11520                                
L11480:
        cmp (16|M0)   (eq)f0.0   null<1>:d     r68.0<1;1,0>:d    38:w               {Compacted}
(f0.0)  cmp (16|M0)   (eq)f0.0   null<1>:d     r100.0<1;1,0>:d   0:w              
(f0.0)  goto (16|M0)                         L11520                  L12544                
L11520:
        join (16|M0)                         L12544                                
L11536:
        add (16|M0)              r2.0<1>:d     -r68.0<1;1,0>:d   39:w               {Compacted}
        and (16|M0)   (ne)f0.1   r116.0<1>:d   r2.0<1;1,0>:d     63:w               {I@1}
        add (16|M0)              r96.0<1>:d    -r68.0<1;1,0>:d   40:w               {Compacted}
(f0.1)  goto (16|M0)                         L11608                  L11608                
L11584:
        mov (16|M0)              r86.0<1>:f    r46.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L11608                  L11720                
L11608:
        join (16|M0)                         L11720                                
L11624:
        cmp (16|M0)   (lt)f0.0   null<1>:d     r116.0<1;1,0>:ud  0x20:uw              {I@5}
(~f0.0) add (16|M0)              r2.0<1>:d     r116.0<1;1,0>:d   -32:w              
(~f0.0) shr (16|M0)              r64.0<1>:ud   r50.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f0.0)  add (16|M0)              r2.0<1>:d     -r116.0<1;1,0>:d  32:w               {Compacted}
(f0.0)  shr (16|M0)              r8.0<1>:ud    r46.0<1;1,0>:ud   r116.0<1;1,0>:d 
(f0.0)  shl (16|M0)              r2.0<1>:d     r50.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f0.0)  or (16|M0)               r64.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
        mov (16|M0)              r86.0<1>:f    r64.0<1;1,0>:f                   {Compacted,I@1}
L11720:
        join (16|M0)                         L12544                                
L11736:
        add (16|M0)              r66.0<1>:d    -r68.0<1;1,0>:d   38:w               {Compacted}
        and (16|M0)   (ne)f1.1   r120.0<1>:d   r66.0<1;1,0>:d    63:w               {I@1}
(f1.1)  goto (16|M0)                         L11800                  L11800                
L11776:
        mov (16|M0)              r78.0<1>:f    r46.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L11800                  L11912                
L11800:
        join (16|M0)                         L11912                                
L11816:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r120.0<1;1,0>:ud  0x20:uw              {I@4}
(~f1.0) add (16|M0)              r2.0<1>:d     r120.0<1;1,0>:d   -32:w              
(~f1.0) shr (16|M0)              r64.0<1>:ud   r50.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.0)  add (16|M0)              r2.0<1>:d     -r120.0<1;1,0>:d  32:w               {Compacted}
(f1.0)  shr (16|M0)              r8.0<1>:ud    r46.0<1;1,0>:ud   r120.0<1;1,0>:d 
(f1.0)  shl (16|M0)              r2.0<1>:d     r50.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.0)  or (16|M0)               r64.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
        mov (16|M0)              r78.0<1>:f    r64.0<1;1,0>:f                   {Compacted,I@1}
L11912:
        join (16|M0)                         L12544                                
L11928:
        and (16|M0)   (ne)f0.1   r84.0<1>:d    r66.0<1;1,0>:d    63:w              
(f0.1)  goto (16|M0)                         L12008                  L12008                
L11960:
        mov (16|M0)              r88.0<1>:d    -1:w                              
        mov (16|M0)              r94.0<1>:d    -1:w                              
        goto (16|M0)                         L12008                  L12192                
L12008:
        join (16|M0)                         L12192                                
L12024:
        cmp (16|M0)   (lt)f0.0   null<1>:d     r84.0<1;1,0>:ud   0x20:uw              {I@6}
(f0.0)  goto (16|M0)                         L12128                  L12128                
L12056:
        add (16|M0)              r2.0<1>:d     r84.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r4.12<1>:hf   -qnan(0x1FF):hf                             
        mov (16|M0)              r88.0<1>:d    0:w                              
        shl (16|M0)              r94.0<1>:d    r4.12<0;1,0>:w    r2.0<1;1,0>:d    {A@1}
        goto (16|M0)                         L12128                  L12192                
L12128:
        join (16|M0)                         L12192                                
L12144:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (16|M0)              r94.0<1>:d    -1:w                              
        shl (16|M0)              r88.0<1>:d    r2.0<0;1,0>:w     r84.0<1;1,0>:d   {F@1}
L12192:
        join (16|M0)                         L12544                                
L12208:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r88.0<1;0>:ud     r6.2<0;0>:ud      r46.0<1>:ud      {I@2} // (s0^s1)&s2
        cmp (16|M0)   (ne)f1.1   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
        bfn.0x60 (16|M0)         r8.0<1>:ud    r94.0<1;0>:ud     r6.2<0;0>:ud      r50.0<1>:ud      // (s0^s1)&s2
(~f1.1) cmp (16|M0)   (ne)f1.1   null<1>:d     r8.0<1;1,0>:d     0:w               {I@1}
(W)     mov (1|M0)               r4.12<1>:hf   -qnan(0x1FF):hf                             
(f1.1)  sel (16|M0)              r10.0<1>:d    r4.12<0;1,0>:w    0:w               {F@1}
        and (16|M0)   (ne)f1.1   r118.0<1>:d   r96.0<1;1,0>:d    63:w              
        mov (16|M0)              r122.0<1>:d   -r10.0<1;1,0>:d                  {I@2}
(f1.1)  goto (16|M0)                         L12376                  L12376                
L12352:
        mov (16|M0)              r64.0<1>:f    r46.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L12376                  L12480                
L12376:
        join (16|M0)                         L12480                                
L12392:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r118.0<1;1,0>:ud  0x20:uw              {I@5}
(~f1.0) add (16|M0)              r2.0<1>:d     r118.0<1;1,0>:d   -32:w              
(~f1.0) shr (16|M0)              r64.0<1>:ud   r50.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.0)  add (16|M0)              r2.0<1>:d     -r118.0<1;1,0>:d  32:w               {Compacted}
(f1.0)  shr (16|M0)              r8.0<1>:ud    r46.0<1;1,0>:ud   r118.0<1;1,0>:d 
(f1.0)  shl (16|M0)              r2.0<1>:d     r50.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.0)  or (16|M0)               r64.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
L12480:
        join (16|M0)                         L12544                                
L12496:
        shl (16|M0)              r2.0<1>:d     r78.0<1;1,0>:d    1:w               {Compacted}
        mov (16|M0)              r8.0<1>:f     r64.0<1;1,0>:f                   {Compacted,I@3}
        and (16|M0)              r96.0<1>:d    r2.0<1;1,0>:d     2:w               {Compacted,I@1}
        mov (16|M0)              r64.0<1>:f    r86.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L12544                  L12632                
L12544:
        join (16|M0)                         L12632                                
L12560:
        shr (16|M0)              r64.0<1>:ud   r46.0<1;1,0>:ud   2:w               {F@1}
        mov (16|M0)              r122.0<1>:d   0:w                              
        mov (16|M0)              r96.0<1>:d    0:w                              
        mov (16|M0)              r8.0<1>:f     r64.0<1;1,0>:f                   {Compacted,I@3}
        shr (16|M0)              r64.0<1>:ud   r46.0<1;1,0>:ud   1:w               {F@1}
L12632:
        join (16|M0)                         L13152                                
L12648:
        shl (16|M0)              r2.0<1>:d     r64.0<1;1,0>:d    2:w               {Compacted,I@2}
        and (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     4:w               {Compacted,I@1}
        bfn.0xFE (16|M0)         r48.0<1>:ud   r2.0<1;0>:ud      r96.0<1;0>:ud     r122.0<1>:ud     {I@1} // s0|s1|s2
        cmp (16|M0)   (eq)f0.1   null<1>:d     r48.0<1;1,0>:d    0:w               {I@1}
        and (16|M0)              r90.0<1>:d    r8.0<1;1,0>:d     8388607:d              
(~f0.1) goto (16|M0)                         L12760                  L12760                
L12728:
        mov (16|M0)              r30.0<1>:d    0:w                              
        goto (16|M0)                         L12760                  L12920                
L12760:
        join (16|M0)                         L12920                                
L12776:
        cmp (16|M0)   (gt)f0.0   null<1>:d     r48.0<1;1,0>:ud   0x4:uw             
(~f0.0) goto (16|M0)                         L12840                  L12840                
L12808:
        mov (16|M0)              r30.0<1>:d    1:w                              
        goto (16|M0)                         L12840                  L12920                
L12840:
        join (16|M0)                         L12920                                
L12856:
        and (16|M0)   (ne)f1.0   null<1>:d     r8.0<1;1,0>:d     1:w              
(W)     mov (1|M0)               r2.0<1>:hf    0x1:hf                             
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r48.0<1;1,0>:d    4:w              
(f1.0)  sel (16|M0)              r30.0<1>:d    r2.0<0;1,0>:w     0:w               {F@1}
L12920:
        join (16|M0)                         L13152                                
L12936:
        add (16|M0)              r44.0<1>:d    r90.0<1;1,0>:d    r30.0<1;1,0>:d   {Compacted,I@2}
        cmp (16|M0)   (gt)f1.0   null<1>:d     r44.0<1;1,0>:ud   0x7FFFFF:ud              {I@1}
        add3 (16|M0)             r2.0<1>:d     r54.0<1;0>:d      r60.0<1;0>:d      -45:w              
(f1.0)  sel (16|M0)              r24.0<1>:d    r2.0<1;1,0>:d     r62.0<1;1,0>:d   {Compacted,I@1}
        cmp (16|M0)   (eq)f1.1   null<1>:d     r24.0<1;1,0>:d    255:w               {I@1}
(f1.1)  goto (16|M0)                         L13088                  L13088                
L13016:
(~f1.0) sel (16|M0)              r2.0<1>:d     r44.0<1;1,0>:d    0:w              
        and (16|M0)              r8.0<1>:d     r42.0<1;1,0>:d    -2147483648:d              
        shl (16|M0)              r10.0<1>:d    r24.0<1;1,0>:d    23:w               {Compacted}
        bfn.0xFE (16|M0)         r76.0<1>:ud   r8.0<1;0>:ud      r10.0<1;0>:ud     r2.0<1>:ud       {I@1} // s0|s1|s2
        goto (16|M0)                         L13088                  L13680                
L13088:
        join (16|M0)                         L13152                                
L13104:
        cmp (16|M0)   (gt)f0.1   null<1>:d     r42.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r2.0<1>:f     inf:f                               {Compacted,I@4}
(f0.1)  sel (16|M0)              r76.0<1>:f    r2.0<0;1,0>:f     -inf:f               {Compacted,F@1}
        goto (16|M0)                         L13152                  L13680                
L13152:
        join (16|M0)                         L13464                                
L13168:
        and (16|M0)   (ne)f1.0   r18.0<1>:d    r60.0<1;1,0>:d    63:w              
(f1.0)  goto (16|M0)                         L13232                  L13232                
L13200:
        mov (16|M0)              r26.0<1>:d    -1:w                              
        goto (16|M0)                         L13232                  L13360                
L13232:
        join (16|M0)                         L13360                                
L13248:
        cmp (16|M0)   (lt)f0.1   null<1>:d     r18.0<1;1,0>:ud   0x20:uw              {A@1}
(f0.1)  goto (16|M0)                         L13312                  L13312                
L13280:
        mov (16|M0)              r26.0<1>:d    0:w                              
        goto (16|M0)                         L13312                  L13360                
L13312:
        join (16|M0)                         L13360                                
L13328:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                             
        shl (16|M0)              r26.0<1>:d    r2.0<0;1,0>:w     r18.0<1;1,0>:d   {F@1}
L13360:
        join (16|M0)                         L13464                                
L13376:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r26.0<1;0>:ud     r6.2<0;0>:ud      r46.0<1>:ud      {I@2} // (s0^s1)&s2
        add (16|M0)              r8.0<1>:d     -r60.0<1;1,0>:d   23:w               {Compacted}
        and (16|M0)              r10.0<1>:d    r42.0<1;1,0>:d    -2147483648:d              
        shl (16|M0)              r12.0<1>:d    r62.0<1;1,0>:d    23:w               {Compacted}
        shl (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     r8.0<1;1,0>:d    {Compacted,I@3}
        bfn.0xFE (16|M0)         r76.0<1>:ud   r10.0<1;0>:ud     r12.0<1;0>:ud     r2.0<1>:ud       {I@1} // s0|s1|s2
        goto (16|M0)                         L13464                  L13680                
L13464:
        join (16|M0)                         L13520                                
L13480:
        cmp (16|M0)   (gt)f0.0   null<1>:d     r42.0<1;1,0>:d    -1:w               {Compacted}
(W)     mov (1|M0)               r2.0<1>:f     inf:f                               {Compacted,I@4}
(f0.0)  sel (16|M0)              r76.0<1>:f    r2.0<0;1,0>:f     -inf:f               {Compacted,F@1}
        goto (16|M0)                         L13520                  L13680                
L13520:
        join (16|M0)                         L13584                                
L13536:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r42.0<1;1,0>:d    0:w              
(W)     mov (1|M0)               r2.0<1>:f     -0.0:f                               {Compacted}
(f1.1)  sel (16|M0)              r76.0<1>:f    r2.0<0;1,0>:f     0.0:f               {Compacted,F@1}
        goto (16|M0)                         L13584                  L13680                
L13584:
        join (16|M0)                         L13648                                
L13600:
        cmp (16|M0)   (gt)f1.0   null<1>:d     r42.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r2.0<1>:f     inf:f                               {Compacted}
(f1.0)  sel (16|M0)              r76.0<1>:f    r2.0<0;1,0>:f     -inf:f               {Compacted,F@1}
        goto (16|M0)                         L13648                  L13680                
L13648:
        join (16|M0)                         L13680                                
L13664:
        bfn.0xF8 (16|M0)         r76.0<1>:ud   r42.0<1;0>:ud     r6.4<0;0>:ud      r6.3<0>:ud       {F@1} // s0&s1|s2
L13680:
        join (16|M0)                         L13832                                
L13696:
        cmp (16|M0)   (lt)f0.0   null<1>:f     r36.0<1;1,0>:f    0.0:f               {Compacted,I@7}
        shl (16|M0)              r10.0<1>:d    r32.0<1;1,0>:d    1:w               {Compacted}
(f0.0)  sel (16|M0)              r2.0<1>:f     -r76.0<1;1,0>:f   r76.0<1;1,0>:f   {Compacted,I@3}
        shl (16|M0)              r8.0<1>:d     r34.0<1;1,0>:d    6:w               {Compacted}
(W)     mov (1|M0)               a0.0<1>:ud    r6.1<0;1,0>:d                    {A@1}
        and (16|M0)              r10.0<1>:d    r10.0<1;1,0>:d    62:w               {Compacted,I@3}
        mov (8|M0)               r7.0<1>:hf    r2.0<1;1,0>:f                    {F@1}
        mov (8|M8)               r7.8<1>:hf    r3.0<1;1,0>:f                   
        add3 (16|M0)             r10.0<1>:d    r8.0<1;0>:d       r6.0<0;0>:d       r10.0<1>:d       {I@1}
        mov (16|M0)              r12.0<1>:ud   r7.0<1;1,0>:uw                   {A@1}
        send.ugm (16|M0)         null     r10     r12:2   a0.0        0x240E0B04           {ExBSO,A@1,$6} // wr:2+2, rd:0; store.ugm.d16u32.a32.wb.wb.bss[a0.0]
L13832:
        join (16|M0)                         L13848                                
L13848:
(W)     mov (8|M0)               r127.0<1>:f   r38.0<1;1,0>:f                   {Compacted}
(W)     send.gtwy (1|M0)         null     r127    null:0  0x0            0x02000010           {EOT,A@1} // wr:1+0, rd:0; end of thread
L13872:
        nop                    
(W)     mov (16|M0)              null<1>:ud    0x9E09665A:ud                             
(W)     mov (16|M0)              null<1>:ud    0xA6E09A48:ud                             
(W)     mov (16|M0)              null<1>:ud    0x0:ud                             
(W)     mov (16|M0)              null<1>:ud    0x79:ud                             
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
