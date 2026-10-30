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
(W)     mov (8|M0)               r68.0<1>:ud   r0.0<1;1,0>:ud                  
(W)     or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x4C0:uw              {A@1}
        sync.nop                             null                             {Compacted,A@1}
        sync.nop                             null                             {Compacted,$2.dst}
(W)     cmp (16|M0)   (eq)f1.0   null<1>:d     r5.6<0;1,0>:d     0:w               {A@1}
(W)     mul (1|M0)               acc0.0<1>:d   r4.3<0;1,0>:d     r68.2<0;1,0>:uw  {I@3}
(W)     mach (1|M0)              r2.0<1>:d     r4.3<0;1,0>:d     r68.1<0;1,0>:d   {$0.dst}
        add3 (16|M0)             r32.0<1>:d    r2.0<0;0>:d       r1.0<1;0>:uw      r4.0<0>:d        {I@1}
(~f1.0) goto (16|M0)                         L448                  L448                
L416:
        mov (16|M0)              r34.0<1>:d    -1:w                              
        goto (16|M0)                         L448                  L816                
L448:
        join (16|M0)                         L816                                
L464:
(W)     xor (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x30:uw              {A@1}
(W)     mov (1|M0)               r2.0<1>:f     r5.6<0;1,0>:ud                   {Compacted,A@1}
(W)     mov (1|M0)               r3.2<1>:f     0xB4C00000:f                               {Compacted,$1.dst}
(W)     math.inv (1|M0)          r3.1<1>:f     r2.0<0;1,0>:f                    {@2,$4}
        mov (16|M0)              r8.0<1>:f     r32.0<1;1,0>:ud                  {Compacted}
        sync.nop                             null                             {Compacted,$4.dst}
(W)     mad (1|M0)               r4.6<1>:f     r3.1<0;0>:f       r3.2<0;0>:f       r3.1<0>:f        {F@2}
(W)     mov (1|M0)               r2.1<1>:ud    r2.0<0;1,0>:f                   
        mov (16|M0)              r12.0<1>:ud   r8.0<1;1,0>:f                    {F@2}
        mul (16|M0)              r10.0<1>:f    r8.0<1;1,0>:f     r4.6<0;1,0>:f    {Compacted,F@1}
(W)     add (1|M0)               r3.0<1>:d     r5.6<0;1,0>:d     -r2.1<0;1,0>:d   {I@2}
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
(W)     mul (8|M0)               acc0.0<1>:d   r30.0<1;1,0>:d    r5.12<0;1,0>:uw  {Compacted,I@1}
        mach (8|M0)              r30.0<1>:d    r30.0<1;1,0>:d    r5.6<0;1,0>:d    {Compacted}
(W)     mul (8|M8)               acc0.0<1>:d   r31.0<1;1,0>:d    r5.12<0;1,0>:uw 
        mach (8|M8)              r31.0<1>:d    r31.0<1;1,0>:d    r5.6<0;1,0>:d    {Compacted}
        add (16|M0)              r30.0<1>:d    r32.0<1;1,0>:d    -r30.0<1;1,0>:d  {Compacted,I@1}
        cmp (16|M0)   (ge)f1.1   r8.0<1>:ud    r30.0<1;1,0>:ud   r5.6<0;1,0>:ud   {I@1}
        add3 (16|M0)             r34.0<1>:d    r28.0<1;0>:d      r14.0<1;0>:d      -r8.0<1>:d       {I@1}
L816:
        join (16|M0)                         L832                                
L832:
(W)     mul (8|M0)               acc0.0<1>:d   r34.0<1;1,0>:d    r5.12<0;1,0>:uw  {Compacted,I@2}
(W)     cmp (16|M0)   (eq)f0.1   null<1>:d     r5.7<0;1,0>:d     0:w              
        mach (8|M0)              r2.0<1>:d     r34.0<1;1,0>:d    r5.6<0;1,0>:d    {Compacted}
(W)     mul (8|M8)               acc0.0<1>:d   r35.0<1;1,0>:d    r5.12<0;1,0>:uw 
        mach (8|M8)              r3.0<1>:d     r35.0<1;1,0>:d    r5.6<0;1,0>:d    {Compacted,$1.dst}
        add (16|M0)              r40.0<1>:d    r32.0<1;1,0>:d    -r2.0<1;1,0>:d   {Compacted,I@1}
(~f0.1) goto (16|M0)                         L944                  L944                
L912:
        mov (16|M0)              r38.0<1>:d    -1:w                              
        goto (16|M0)                         L944                  L1312                
L944:
        join (16|M0)                         L1312                                
L960:
(W)     xor (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x30:uw              {A@1}
(W)     mov (1|M0)               r2.0<1>:f     r5.7<0;1,0>:ud                   {Compacted,A@1}
(W)     mov (1|M0)               r3.2<1>:f     0xB4C00000:f                               {Compacted}
(W)     math.inv (1|M0)          r3.1<1>:f     r2.0<0;1,0>:f                    {@2,$5}
        mov (16|M0)              r8.0<1>:f     r40.0<1;1,0>:ud                  {Compacted}
        sync.nop                             null                             {Compacted,$5.dst}
(W)     mad (1|M0)               r4.6<1>:f     r3.1<0;0>:f       r3.2<0;0>:f       r3.1<0>:f        {F@2}
(W)     mov (1|M0)               r2.1<1>:ud    r2.0<0;1,0>:f                   
        mov (16|M0)              r12.0<1>:ud   r8.0<1;1,0>:f                    {F@2}
        mul (16|M0)              r10.0<1>:f    r8.0<1;1,0>:f     r4.6<0;1,0>:f    {Compacted,F@1}
(W)     add (1|M0)               r3.0<1>:d     r5.7<0;1,0>:d     -r2.1<0;1,0>:d   {I@2}
        add (16|M0)              r12.0<1>:d    r40.0<1;1,0>:d    -r12.0<1;1,0>:d  {Compacted,I@2}
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
(W)     mul (8|M0)               acc0.0<1>:d   r30.0<1;1,0>:d    r5.14<0;1,0>:uw  {Compacted,I@1}
        mach (8|M0)              r30.0<1>:d    r30.0<1;1,0>:d    r5.7<0;1,0>:d    {Compacted}
(W)     mul (8|M8)               acc0.0<1>:d   r31.0<1;1,0>:d    r5.14<0;1,0>:uw 
        mach (8|M8)              r31.0<1>:d    r31.0<1;1,0>:d    r5.7<0;1,0>:d    {Compacted}
        add (16|M0)              r30.0<1>:d    r40.0<1;1,0>:d    -r30.0<1;1,0>:d  {Compacted,I@1}
        cmp (16|M0)   (ge)f1.0   r8.0<1>:ud    r30.0<1;1,0>:ud   r5.7<0;1,0>:ud   {I@1}
        add3 (16|M0)             r38.0<1>:d    r28.0<1;0>:d      r14.0<1;0>:d      -r8.0<1>:d       {I@1}
L1312:
        join (16|M0)                         L1328                                
L1328:
(W)     mov (1|M0)               a0.0<1>:ud    r6.7<0;1,0>:d                    {A@1}
        shl (16|M0)              r8.0<1>:d     r32.0<1;1,0>:d    2:w               {Compacted}
(W)     mul (8|M0)               acc0.0<1>:d   r38.0<1;1,0>:d    r5.14<0;1,0>:uw  {Compacted,I@4}
        send.ugm (16|M0)         r44      r8      null:0  a0.0        0x24280500           {ExBSO,A@2,$6} // wr:2+0, rd:2; load.ugm.d32.a32.ca.ca.bss[a0.0]
        mach (8|M0)              r2.0<1>:d     r38.0<1;1,0>:d    r5.7<0;1,0>:d    {Compacted}
(W)     mul (8|M8)               acc0.0<1>:d   r39.0<1;1,0>:d    r5.14<0;1,0>:uw 
        mach (8|M8)              r3.0<1>:d     r39.0<1;1,0>:d    r5.7<0;1,0>:d    {Compacted}
(W)     mov (1|M0)               r6.3<1>:f     inf:f                               {Compacted}
        add (16|M0)              r42.0<1>:d    r40.0<1;1,0>:d    -r2.0<1;1,0>:d   {Compacted,I@1}
(W)     mov (1|M0)               r6.2<1>:d     -1:w                              
(W)     mov (1|M0)               r6.7<1>:f     -0.0:f                               {Compacted}
        shr (16|M0)              r36.0<1>:ud   r42.0<1;1,0>:ud   5:w               {I@2}
        and (16|M0)              r10.0<1>:d    r44.0<1;1,0>:d    2147483647:d               {$6.dst}
        sel (16|M0)   (lt)f0.0   r98.0<1>:f    r10.0<1;1,0>:f    448.0:f               {Compacted,I@1}
        shr (16|M0)              r92.0<1>:ud   r98.0<1;1,0>:ud   23:w               {F@1}
        and (16|M0)   (ne)f1.0   r10.0<1>:d    r98.0<1;1,0>:d    8388607:d              
        and (16|M0)              r124.0<1>:d   r92.0<1;1,0>:d    255:w               {Compacted,I@2}
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r124.0<1;1,0>:d   255:w               {I@1}
        sel (16|M0)   (ge)f0.0   r12.0<1>:ud   r124.0<1;1,0>:ud  0x79:uw             
        shl (16|M0)              r54.0<1>:d    r12.0<1;1,0>:d    23:w               {Compacted,I@1}
(~f1.0) goto (16|M0)                         L1616                  L1616                
L1584:
        mov (16|M0)              r120.0<1>:ud  0x7FC00000:ud                             
        goto (16|M0)                         L1616                  L7480                
L1616:
        join (16|M0)                         L7480                                
L1632:
        cmp (16|M0)   (eq)f0.1   null<1>:d     r10.0<1;1,0>:d    0:w              
        add (16|M0)              r78.0<1>:d    -r54.0<1;1,0>:d   -2139095040:d               {I@6}
(f0.1)  cmp (16|M0)   (eq)f0.1   null<1>:d     r124.0<1;1,0>:d   255:w              
        xor (16|M0)              r52.0<1>:d    r78.0<1;1,0>:d    r98.0<1;1,0>:d   {Compacted,I@2}
(f0.1)  goto (16|M0)                         L7448                  L7448                
L1704:
        or (16|M0)    (eq)f0.0   null<1>:d     r124.0<1;1,0>:d   r10.0<1;1,0>:d  
(~f0.0) goto (16|M0)                         L1768                  L1768                
L1736:
        mov (16|M0)              r120.0<1>:ud  0x0:ud                             
        goto (16|M0)                         L1768                  L7480                
L1768:
        join (16|M0)                         L7448                                
L1784:
        cmp (16|M0)   (eq)f0.0   null<1>:d     r124.0<1;1,0>:d   0:w               {Compacted}
        shr (16|M0)              r84.0<1>:ud   r78.0<1;1,0>:ud   23:w              
        add (16|M0)              r82.0<1>:d    r124.0<1;1,0>:d   -127:w               {Compacted}
(f0.0)  mov (16|M0)              r82.0<1>:d    -126:w                              
        add (16|M0)              r50.0<1>:d    r84.0<1;1,0>:d    r82.0<1;1,0>:d   {Compacted,I@1}
        cmp (16|M0)   (gt)f1.1   null<1>:d     r50.0<1;1,0>:d    254:w               {I@1}
(f1.1)  goto (16|M0)                         L7384                  L7384                
L1872:
        or (16|M0)    (eq)f1.0   null<4>:b     r92.0<1;1,0>:d    r84.0<1;1,0>:d  
(f1.0)  goto (16|M0)                         L7328                  L7328                
L1904:
(W)     mov (1|M0)               r2.0<1>:hf    0.0:hf                             
(W)     mov (1|M0)               r7.7<1>:d     0:w                               {$3.dst}
(f0.0)  sel (16|M0)              r8.0<1>:d     r2.0<0;1,0>:w     8388608:d               {F@1}
        or (16|M0)               r8.0<1>:d     r8.0<1;1,0>:d     r10.0<1;1,0>:d   {Compacted,I@1}
        shl (16|M0)              r48.0<1>:d    r8.0<1;1,0>:d     23:w               {Compacted,I@1}
        shr (16|M0)              r46.0<1>:ud   r8.0<1;1,0>:ud    9:w              
(W)     mov (1|M0)               r7.6<1>:f     -0.0:f                               {Compacted}
(W)     mov (2|M0)               r7.4<1>:d     0:w                              
L2008:
(W)     shl (1|M0)               r2.0<1>:d     r7.6<0;1,0>:d     31:w               {Compacted,F@1}
(W)     shr (1|M0)               r2.1<1>:ud    r7.7<0;1,0>:ud    1:w              
(W)     cmp (16|M0)   (gt)f0.0   null<1>:d     r7.4<0;1,0>:ud    0x3E:uw              {I@3}
(W)     or (1|M0)                r7.7<1>:d     r2.1<0;1,0>:d     r2.0<0;1,0>:d    {I@2}
        bfn.0xE0 (16|M0)         r8.0<1>:ud    r2.1<0;0>:ud      r2.0<0;0>:ud      r48.0<1>:ud      // (s0|s1)&s2
(W)     shr (1|M0)               r7.3<1>:ud    r7.6<0;1,0>:ud    1:w              
(W&f0.0) cmp (16|M0)  (eq)f0.0   null<1>:d     r7.5<0;1,0>:d     0:w              
        cmp (16|M0)   (eq)f1.0   null<1>:d     r8.0<1;1,0>:d     r7.7<0;1,0>:d    {I@3}
        and (16|M0)              r10.0<1>:d    r7.3<0;1,0>:d     r46.0<1;1,0>:d   {Compacted,I@3}
(W&~f0.0) cmp (16|M0) (gt)f0.0   null<1>:d     r7.5<0;1,0>:ud    0x0:uw             
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r10.0<1;1,0>:d    r7.3<0;1,0>:d    {I@2}
(W)     mov (1|M0)               r4.12<1>:hf   0x1:hf                             
(W)     addc (1|M0)              r14.0<1>:ud   r7.4<0;1,0>:ud    0x1:ud              {AccWrEn}
(f0.0)  sel (16|M0)              r12.0<1>:uw   r4.12<0;1,0>:uw   0x0:uw              {Compacted,F@1}
(f1.0)  sel (16|M0)              acc2.0<1>:uw  r4.12<0;1,0>:uw   0x0:uw             
(W)     mov (1|M0)               r3.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        or (16|M0)    (ne)f0.0   null<1>:uw    r12.0<1;1,0>:uw   acc2.0<1;1,0>:uw {I@3}
(W)     add (1|M0)               r3.0<1>:ud    r3.0<0;1,0>:ud    r7.5<0;1,0>:ud   {Compacted,I@2}
        mov (16|M0)              r116.0<1>:d   r7.4<0;1,0>:d                   
        mov (16|M0)              r114.0<1>:d   r7.5<0;1,0>:d                   
        mov (16|M0)              r66.0<1>:f    r14.0<0;1,0>:f                   {Compacted}
        mov (16|M0)              r76.0<1>:f    r3.0<0;1,0>:f                    {Compacted,I@3}
(f0.0)  goto (16|M0)                         L2384                  L2384                
L2320:
(W)     mov (1|M0)               r7.6<1>:d     r7.3<0;1,0>:d                   
(W)     mov (1|M0)               r7.4<1>:d     r14.0<0;1,0>:d                  
(W)     mov (1|M0)               r7.5<1>:d     r3.0<0;1,0>:d                   
(W)     jmpi                                 L2008                                
L2384:
        join (16|M0)                         L7328                                
L2400:
(W)     mov (1|M0)               r2.0<1>:f     8.68805e-44:f                              
(W)     mov (1|M0)               r3.0<1>:hf    0.0:hf                              {I@3}
        subb (8|M0)              r70.0<1>:ud   r2.0<0;1,0>:ud    r116.0<1;1,0>:ud {AccWrEn,Compacted,F@2}
        add3 (8|M0)              r108.0<1>:ud  -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r114.0<1>:ud    {F@1}
        subb (8|M8)              r71.0<1>:ud   r2.0<0;1,0>:ud    r117.0<1;1,0>:ud {AccWrEn}
        add3 (16|M0)             r72.0<1>:d    r50.0<1;0>:d      r70.0<1;0>:d      -173:w               {I@1}
        cmp (16|M0)   (gt)f0.1   null<1>:d     r72.0<1;1,0>:d    127:w               {I@1}
        add3 (8|M8)              r109.0<1>:ud  -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r115.0<1>:ud   
        add3 (16|M0)             r106.0<1>:d   r84.0<1;0>:d      r82.0<1;0>:d      r70.0<1>:d      
(f0.1)  goto (16|M0)                         L7264                  L7264                
L2552:
        cmp (16|M0)   (gt)f0.0   null<1>:d     r72.0<1;1,0>:d    -127:w               {Compacted}
(f0.0)  goto (16|M0)                         L4984                  L4984                
L2576:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r72.0<1;1,0>:ud   0xFFFFFF6B:ud             
(f1.1)  goto (16|M0)                         L4488                  L4488                
L2608:
(W)     mov (1|M0)               r2.0<1>:f     8.82818e-44:f                              
(W)     mov (1|M0)               r3.0<1>:hf    0.0:hf                              {I@7}
        subb (8|M0)              r10.0<1>:ud   r2.0<0;1,0>:ud    r116.0<1;1,0>:ud {AccWrEn,Compacted,F@2}
        add3 (16|M0)             r50.0<1>:d    r50.0<1;0>:d      r70.0<1;0>:d      -23:w              
        add3 (8|M0)              r8.0<1>:ud    -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r114.0<1>:ud    {F@1}
        subb (8|M8)              r11.0<1>:ud   r2.0<0;1,0>:ud    r117.0<1;1,0>:ud {AccWrEn}
        cmp (16|M0)   (gt)f0.1   null<1>:d     r10.0<1;1,0>:ud   r50.0<1;1,0>:ud  {I@1}
        add3 (8|M8)              r9.0<1>:ud    -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r115.0<1>:ud   
(f0.1)  cmp (16|M0)   (eq)f0.1   null<1>:d     r8.0<1;1,0>:d     0:w               {I@1}
(~f0.1) cmp (16|M0)   (gt)f0.1   null<1>:d     r8.0<1;1,0>:ud    0x0:uw             
(f0.1)  goto (16|M0)                         L2832                  L2832                
L2776:
        add3 (16|M0)             r2.0<1>:d     r106.0<1;0>:d     -r10.0<1;0>:d     -23:w              
        mov (16|M0)              r74.0<1>:d    0:w                              
        shl (16|M0)              r76.0<1>:d    r48.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
        goto (16|M0)                         L2832                  L4424                
L2832:
        join (16|M0)                         L4424                                
L2848:
        add3 (16|M0)             r104.0<1>:d   r10.0<1;0>:d      -r106.0<1;0>:d    23:w              
        cmp (16|M0)   (lt)f1.0   null<1>:d     r104.0<1;1,0>:d   2:w               {Compacted,I@1}
(f1.0)  goto (16|M0)                         L2992                  L2992                
L2888:
        cmp (16|M0)   (eq)f0.1   null<1>:d     r104.0<1;1,0>:d   2:w              
(~f0.1) goto (16|M0)                         L2992                  L3088                
L2920:
        shr (16|M0)              r96.0<1>:ud   r48.0<1;1,0>:ud   1:w              
        mov (16|M0)              r30.0<1>:d    0:w                              
        mov (16|M0)              r60.0<1>:d    0:w                              
        mov (16|M0)              r26.0<1>:f    r96.0<1;1,0>:f                   {Compacted,I@3}
        goto (16|M0)                         L2992                  L3896                
L2992:
        join (16|M0)                         L3088                                
L3008:
        cmp (16|M0)   (eq)f0.0   null<1>:d     r104.0<1;1,0>:d   1:w               {Compacted}
(~f0.0) goto (16|M0)                         L3088                  L3088                
L3032:
        mov (16|M0)              r30.0<1>:d    0:w                              
        mov (16|M0)              r60.0<1>:d    0:w                              
        mov (16|M0)              r26.0<1>:f    r48.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L3088                  L3896                
L3088:
        join (16|M0)                         L3896                                
L3104:
        add3 (16|M0)             r2.0<1>:d     r10.0<1;0>:d      -r50.0<1;0>:d     -1:w              
        and (16|M0)   (ne)f1.1   r24.0<1>:d    r2.0<1;1,0>:d     63:w               {I@1}
(f1.1)  goto (16|M0)                         L3176                  L3176                
L3152:
        mov (16|M0)              r112.0<1>:f   r48.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L3176                  L3288                
L3176:
        join (16|M0)                         L3288                                
L3192:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r24.0<1;1,0>:ud   0x20:uw              {I@4}
(~f1.0) add (16|M0)              r2.0<1>:d     r24.0<1;1,0>:d    -32:w              
(~f1.0) shr (16|M0)              r96.0<1>:ud   r46.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.0)  add (16|M0)              r2.0<1>:d     -r24.0<1;1,0>:d   32:w               {Compacted}
(f1.0)  shr (16|M0)              r8.0<1>:ud    r48.0<1;1,0>:ud   r24.0<1;1,0>:d  
(f1.0)  shl (16|M0)              r2.0<1>:d     r46.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.0)  or (16|M0)               r96.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
        mov (16|M0)              r112.0<1>:f   r96.0<1;1,0>:f                   {Compacted,I@1}
L3288:
        join (16|M0)                         L3896                                
L3304:
        add3 (16|M0)             r94.0<1>:d    r10.0<1;0>:d      -r50.0<1;0>:d     -2:w              
        and (16|M0)   (ne)f0.1   r22.0<1>:d    r94.0<1;1,0>:d    63:w               {I@1}
(f0.1)  goto (16|M0)                         L3376                  L3376                
L3352:
        mov (16|M0)              r96.0<1>:f    r48.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L3376                  L3480                
L3376:
        join (16|M0)                         L3480                                
L3392:
        cmp (16|M0)   (lt)f0.0   null<1>:d     r22.0<1;1,0>:ud   0x20:uw              {I@4}
(~f0.0) add (16|M0)              r2.0<1>:d     r22.0<1;1,0>:d    -32:w              
(~f0.0) shr (16|M0)              r96.0<1>:ud   r46.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f0.0)  add (16|M0)              r2.0<1>:d     -r22.0<1;1,0>:d   32:w               {Compacted}
(f0.0)  shr (16|M0)              r8.0<1>:ud    r48.0<1;1,0>:ud   r22.0<1;1,0>:d  
(f0.0)  shl (16|M0)              r2.0<1>:d     r46.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f0.0)  or (16|M0)               r96.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
L3480:
        join (16|M0)                         L3896                                
L3496:
        and (16|M0)   (ne)f1.1   r116.0<1>:d   r94.0<1;1,0>:d    63:w              
        and (16|M0)              r60.0<1>:d    r96.0<1;1,0>:d    1:w               {Compacted,I@3}
(f1.1)  goto (16|M0)                         L3584                  L3584                
L3536:
        mov (16|M0)              r120.0<1>:d   -1:w                              
        mov (16|M0)              r124.0<1>:d   -1:w                              
        goto (16|M0)                         L3584                  L3768                
L3584:
        join (16|M0)                         L3768                                
L3600:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r116.0<1;1,0>:ud  0x20:uw              {I@7}
(f1.0)  goto (16|M0)                         L3704                  L3704                
L3632:
        add (16|M0)              r2.0<1>:d     r116.0<1;1,0>:d   -32:w               {Compacted}
(W)     mov (1|M0)               r4.12<1>:hf   -qnan(0x1FF):hf                             
        mov (16|M0)              r120.0<1>:d   0:w                              
        shl (16|M0)              r124.0<1>:d   r4.12<0;1,0>:w    r2.0<1;1,0>:d    {A@1}
        goto (16|M0)                         L3704                  L3768                
L3704:
        join (16|M0)                         L3768                                
L3720:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (16|M0)              r124.0<1>:d   -1:w                              
        shl (16|M0)              r120.0<1>:d   r2.0<0;1,0>:w     r116.0<1;1,0>:d  {F@1}
L3768:
        join (16|M0)                         L3896                                
L3784:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r120.0<1;0>:ud    r6.2<0;0>:ud      r48.0<1>:ud      {I@2} // (s0^s1)&s2
        cmp (16|M0)   (ne)f0.0   null<1>:d     r2.0<1;1,0>:d     0:w               {Compacted,I@1}
        bfn.0x60 (16|M0)         r8.0<1>:ud    r124.0<1;0>:ud    r6.2<0;0>:ud      r46.0<1>:ud      // (s0^s1)&s2
(~f0.0) cmp (16|M0)   (ne)f0.0   null<1>:d     r8.0<1;1,0>:d     0:w               {I@1}
(W)     mov (1|M0)               r4.12<1>:hf   -qnan(0x1FF):hf                             
        mov (16|M0)              r26.0<1>:f    r112.0<1;1,0>:f                  {Compacted}
(f0.0)  sel (16|M0)              r10.0<1>:d    r4.12<0;1,0>:w    0:w               {F@2}
        mov (16|M0)              r30.0<1>:d    -r10.0<1;1,0>:d                  {I@1}
L3896:
        join (16|M0)                         L4424                                
L3912:
        and (16|M0)   (ne)f0.1   r20.0<1>:d    r104.0<1;1,0>:d   63:w              
(f0.1)  goto (16|M0)                         L3968                  L3968                
L3944:
        mov (16|M0)              r96.0<1>:f    r48.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L3968                  L4072                
L3968:
        join (16|M0)                         L4072                                
L3984:
        cmp (16|M0)   (lt)f0.0   null<1>:d     r20.0<1;1,0>:ud   0x20:uw              {I@4}
(~f0.0) add (16|M0)              r2.0<1>:d     r20.0<1;1,0>:d    -32:w              
(~f0.0) shr (16|M0)              r96.0<1>:ud   r46.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f0.0)  add (16|M0)              r2.0<1>:d     -r20.0<1;1,0>:d   32:w               {Compacted}
(f0.0)  shr (16|M0)              r8.0<1>:ud    r48.0<1;1,0>:ud   r20.0<1;1,0>:d  
(f0.0)  shl (16|M0)              r2.0<1>:d     r46.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f0.0)  or (16|M0)               r96.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
L4072:
        join (16|M0)                         L4424                                
L4088:
        shl (16|M0)              r2.0<1>:d     r26.0<1;1,0>:d    2:w               {Compacted}
        shl (16|M0)              r8.0<1>:d     r60.0<1;1,0>:d    1:w               {Compacted}
        and (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     4:w               {Compacted,I@2}
        bfn.0xFE (16|M0)         r78.0<1>:ud   r2.0<1;0>:ud      r8.0<1;0>:ud      r30.0<1>:ud      {I@1} // s0|s1|s2
        cmp (16|M0)   (eq)f1.1   null<1>:d     r78.0<1;1,0>:d    0:w               {I@1}
(~f1.1) goto (16|M0)                         L4192                  L4192                
L4160:
        mov (16|M0)              r82.0<1>:d    0:w                              
        goto (16|M0)                         L4192                  L4352                
L4192:
        join (16|M0)                         L4352                                
L4208:
        cmp (16|M0)   (gt)f1.0   null<1>:d     r78.0<1;1,0>:ud   0x4:uw             
(~f1.0) goto (16|M0)                         L4272                  L4272                
L4240:
        mov (16|M0)              r82.0<1>:d    1:w                              
        goto (16|M0)                         L4272                  L4352                
L4272:
        join (16|M0)                         L4352                                
L4288:
        and (16|M0)   (ne)f1.1   null<1>:d     r96.0<1;1,0>:d    1:w              
(W)     mov (1|M0)               r2.0<1>:hf    0x1:hf                             
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r78.0<1;1,0>:d    4:w              
(f1.1)  sel (16|M0)              r82.0<1>:d    r2.0<0;1,0>:w     0:w               {F@1}
L4352:
        join (16|M0)                         L4424                                
L4368:
        add (16|M0)              r2.0<1>:d     r82.0<1;1,0>:d    r96.0<1;1,0>:d   {Compacted,I@2}
        cmp (16|M0)   (gt)f0.0   null<1>:d     r2.0<1;1,0>:ud    0x7FFFFF:ud              {I@1}
(W)     mov (1|M0)               r4.6<1>:f     0x800000:f                               {Compacted}
(~f0.0) sel (16|M0)              r76.0<1>:d    r2.0<1;1,0>:d     0:w              
(f0.0)  sel (16|M0)              r74.0<1>:d    r4.6<0;1,0>:d     0:w               {Compacted,F@1}
L4424:
        join (16|M0)                         L4488                                
L4440:
        and (16|M0)              r2.0<1>:d     r52.0<1;1,0>:d    -2147483648:d              
        bfn.0xFE (16|M0)         r120.0<1>:ud  r2.0<1;0>:ud      r74.0<1;0>:ud     r76.0<1>:ud      {I@1} // s0|s1|s2
        goto (16|M0)                         L4488                  L7480                
L4488:
        join (16|M0)                         L4984                                
L4504:
        and (16|M0)   (ne)f0.1   r96.0<1>:d    r70.0<1;1,0>:d    63:w              
(f0.1)  goto (16|M0)                         L4584                  L4584                
L4536:
        mov (16|M0)              r110.0<1>:d   -1:w                              
        mov (16|M0)              r114.0<1>:d   -1:w                              
        goto (16|M0)                         L4584                  L4768                
L4584:
        join (16|M0)                         L4768                                
L4600:
        cmp (16|M0)   (lt)f0.0   null<1>:d     r96.0<1;1,0>:ud   0x20:uw              {I@6}
(f0.0)  goto (16|M0)                         L4704                  L4704                
L4632:
        add (16|M0)              r2.0<1>:d     r96.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r4.12<1>:hf   -qnan(0x1FF):hf                             
        mov (16|M0)              r110.0<1>:d   0:w                              
        shl (16|M0)              r114.0<1>:d   r4.12<0;1,0>:w    r2.0<1;1,0>:d    {A@1}
        goto (16|M0)                         L4704                  L4768                
L4704:
        join (16|M0)                         L4768                                
L4720:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (16|M0)              r114.0<1>:d   -1:w                              
        shl (16|M0)              r110.0<1>:d   r2.0<0;1,0>:w     r96.0<1;1,0>:d   {F@1}
L4768:
        join (16|M0)                         L4984                                
L4784:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r110.0<1;0>:ud    r6.2<0;0>:ud      r48.0<1>:ud      {I@2} // (s0^s1)&s2
        cmp (16|M0)   (ne)f0.0   null<1>:d     r2.0<1;1,0>:d     0:w               {Compacted,I@1}
        bfn.0x60 (16|M0)         r8.0<1>:ud    r114.0<1;0>:ud    r6.2<0;0>:ud      r46.0<1>:ud      // (s0^s1)&s2
        cmp (16|M0)   (gt)f1.1   null<1>:d     r52.0<1;1,0>:d    -1:w              
(~f0.0) cmp (16|M0)   (ne)f0.0   null<1>:d     r8.0<1;1,0>:d     0:w               {I@2}
(f0.0)  cmp (16|M0)   (eq)f0.0   null<1>:d     r72.0<1;1,0>:d    -150:w              
(f1.1)  goto (16|M0)                         L4928                  L4928                
L4888:
(W)     mov (1|M0)               r2.0<1>:ud    0x80000001:ud                             
(f0.0)  sel (16|M0)              r120.0<1>:f   r2.0<0;1,0>:f     -0.0:f               {Compacted,I@1}
        goto (16|M0)                         L4928                  L7480                
L4928:
        join (16|M0)                         L4984                                
L4944:
(W)     mov (1|M0)               r2.0<1>:ud    0x1:ud                              {F@1}
(f0.0)  sel (16|M0)              r120.0<1>:f   r2.0<0;1,0>:f     0.0:f               {Compacted,I@1}
        goto (16|M0)                         L4984                  L7480                
L4984:
        join (16|M0)                         L7264                                
L5000:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r70.0<1;1,0>:ud   0x18:uw             
        add3 (16|M0)             r74.0<1>:d    r50.0<1;0>:d      r70.0<1;0>:d      -46:w              
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r108.0<1;1,0>:d   0:w              
(f1.0)  goto (16|M0)                         L6952                  L6952                
L5064:
        shl (16|M0)              r2.0<1>:d     r66.0<1;1,0>:d    1:w               {Compacted,F@1}
        shr (16|M0)              r8.0<1>:ud    r66.0<1;1,0>:ud   31:w              
        shl (16|M0)              r10.0<1>:d    r76.0<1;1,0>:d    1:w               {Compacted}
        cmp (16|M0)   (lt)f0.0   null<1>:d     r2.0<1;1,0>:ud    0x4E:uw              {I@3}
        or (16|M0)               r10.0<1>:d    r10.0<1;1,0>:d    r8.0<1;1,0>:d    {Compacted,I@2}
(f0.0)  cmp (16|M0)   (eq)f0.0   null<1>:d     r10.0<1;1,0>:d    0:w               {I@1}
(~f0.0) cmp (16|M0)   (lt)f0.0   null<1>:d     r10.0<1;1,0>:d    0:w              
(f0.0)  goto (16|M0)                         L5296                  L5296                
L5168:
        cmp (16|M0)   (eq)f0.1   null<1>:d     r66.0<1;1,0>:d    39:w              
(f0.1)  cmp (16|M0)   (eq)f0.1   null<1>:d     r76.0<1;1,0>:d    0:w              
(~f0.1) goto (16|M0)                         L5296                  L5352                
L5216:
        shr (16|M0)              r96.0<1>:ud   r48.0<1;1,0>:ud   1:w              
        mov (16|M0)              r56.0<1>:d    0:w                              
        mov (16|M0)              r98.0<1>:d    0:w                              
        mov (16|M0)              r64.0<1>:f    r96.0<1;1,0>:f                   {Compacted,I@3}
        mov (16|M0)              r96.0<1>:f    r48.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L5296                  L6440                
L5296:
        join (16|M0)                         L5352                                
L5312:
        cmp (16|M0)   (eq)f0.0   null<1>:d     r66.0<1;1,0>:d    38:w               {Compacted}
(f0.0)  cmp (16|M0)   (eq)f0.0   null<1>:d     r76.0<1;1,0>:d    0:w              
(f0.0)  goto (16|M0)                         L5352                  L6352                
L5352:
        join (16|M0)                         L6352                                
L5368:
        add (16|M0)              r2.0<1>:d     -r66.0<1;1,0>:d   39:w               {Compacted}
        and (16|M0)   (ne)f1.0   r56.0<1>:d    r2.0<1;1,0>:d     63:w               {I@1}
        add (16|M0)              r92.0<1>:d    -r66.0<1;1,0>:d   40:w               {Compacted}
(f1.0)  goto (16|M0)                         L5440                  L5440                
L5416:
        mov (16|M0)              r90.0<1>:f    r48.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L5440                  L5552                
L5440:
        join (16|M0)                         L5552                                
L5456:
        cmp (16|M0)   (lt)f0.1   null<1>:d     r56.0<1;1,0>:ud   0x20:uw              {I@5}
(~f0.1) add (16|M0)              r2.0<1>:d     r56.0<1;1,0>:d    -32:w              
(~f0.1) shr (16|M0)              r96.0<1>:ud   r46.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f0.1)  add (16|M0)              r2.0<1>:d     -r56.0<1;1,0>:d   32:w               {Compacted}
(f0.1)  shr (16|M0)              r8.0<1>:ud    r48.0<1;1,0>:ud   r56.0<1;1,0>:d  
(f0.1)  shl (16|M0)              r2.0<1>:d     r46.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f0.1)  or (16|M0)               r96.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
        mov (16|M0)              r90.0<1>:f    r96.0<1;1,0>:f                   {Compacted,I@1}
L5552:
        join (16|M0)                         L6352                                
L5568:
        add (16|M0)              r100.0<1>:d   -r66.0<1;1,0>:d   38:w               {Compacted}
        and (16|M0)   (ne)f0.0   r60.0<1>:d    r100.0<1;1,0>:d   63:w               {Compacted,I@1}
(f0.0)  goto (16|M0)                         L5624                  L5624                
L5600:
        mov (16|M0)              r96.0<1>:f    r48.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L5624                  L5728                
L5624:
        join (16|M0)                         L5728                                
L5640:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r60.0<1;1,0>:ud   0x20:uw              {I@4}
(~f1.1) add (16|M0)              r2.0<1>:d     r60.0<1;1,0>:d    -32:w              
(~f1.1) shr (16|M0)              r96.0<1>:ud   r46.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.1)  add (16|M0)              r2.0<1>:d     -r60.0<1;1,0>:d   32:w               {Compacted}
(f1.1)  shr (16|M0)              r8.0<1>:ud    r48.0<1;1,0>:ud   r60.0<1;1,0>:d  
(f1.1)  shl (16|M0)              r2.0<1>:d     r46.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.1)  or (16|M0)               r96.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
L5728:
        join (16|M0)                         L6352                                
L5744:
        and (16|M0)   (ne)f1.0   r8.0<1>:d     r100.0<1;1,0>:d   63:w              
        and (16|M0)              r98.0<1>:d    r96.0<1;1,0>:d    1:w               {Compacted,I@3}
(f1.0)  goto (16|M0)                         L5832                  L5832                
L5784:
        mov (16|M0)              r20.0<1>:d    -1:w                              
        mov (16|M0)              r24.0<1>:d    -1:w                              
        goto (16|M0)                         L5832                  L6016                
L5832:
        join (16|M0)                         L6016                                
L5848:
        cmp (16|M0)   (lt)f0.1   null<1>:d     r8.0<1;1,0>:ud    0x20:uw              {I@7}
(f0.1)  goto (16|M0)                         L5952                  L5952                
L5880:
        add (16|M0)              r2.0<1>:d     r8.0<1;1,0>:d     -32:w               {Compacted}
(W)     mov (1|M0)               r4.12<1>:hf   -qnan(0x1FF):hf                             
        mov (16|M0)              r20.0<1>:d    0:w                              
        shl (16|M0)              r24.0<1>:d    r4.12<0;1,0>:w    r2.0<1;1,0>:d    {A@1}
        goto (16|M0)                         L5952                  L6016                
L5952:
        join (16|M0)                         L6016                                
L5968:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (16|M0)              r24.0<1>:d    -1:w                              
        shl (16|M0)              r20.0<1>:d    r2.0<0;1,0>:w     r8.0<1;1,0>:d    {F@1}
L6016:
        join (16|M0)                         L6352                                
L6032:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r20.0<1;0>:ud     r6.2<0;0>:ud      r48.0<1>:ud      {I@2} // (s0^s1)&s2
        cmp (16|M0)   (ne)f1.1   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
        bfn.0x60 (16|M0)         r8.0<1>:ud    r24.0<1;0>:ud     r6.2<0;0>:ud      r46.0<1>:ud      // (s0^s1)&s2
(~f1.1) cmp (16|M0)   (ne)f1.1   null<1>:d     r8.0<1;1,0>:d     0:w               {I@1}
(W)     mov (1|M0)               r4.12<1>:hf   -qnan(0x1FF):hf                             
        and (16|M0)   (ne)f0.0   r58.0<1>:d    r92.0<1;1,0>:d    63:w               {Compacted}
(f1.1)  sel (16|M0)              r10.0<1>:d    r4.12<0;1,0>:w    0:w               {F@1}
        mov (16|M0)              r56.0<1>:d    -r10.0<1;1,0>:d                  {I@1}
(f0.0)  goto (16|M0)                         L6192                  L6192                
L6168:
        mov (16|M0)              r96.0<1>:f    r48.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L6192                  L6296                
L6192:
        join (16|M0)                         L6296                                
L6208:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r58.0<1;1,0>:ud   0x20:uw             
(~f1.1) add (16|M0)              r2.0<1>:d     r58.0<1;1,0>:d    -32:w              
(~f1.1) shr (16|M0)              r96.0<1>:ud   r46.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.1)  add (16|M0)              r2.0<1>:d     -r58.0<1;1,0>:d   32:w               {Compacted}
(f1.1)  shr (16|M0)              r8.0<1>:ud    r48.0<1;1,0>:ud   r58.0<1;1,0>:d  
(f1.1)  shl (16|M0)              r2.0<1>:d     r46.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.1)  or (16|M0)               r96.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
L6296:
        join (16|M0)                         L6352                                
L6312:
        mov (16|M0)              r64.0<1>:f    r96.0<1;1,0>:f                   {Compacted,I@2}
        mov (16|M0)              r96.0<1>:d    r90.0<1;1,0>:d                   {F@1}
        goto (16|M0)                         L6352                  L6440                
L6352:
        join (16|M0)                         L6440                                
L6368:
        shr (16|M0)              r96.0<1>:ud   r48.0<1;1,0>:ud   2:w              
        mov (16|M0)              r56.0<1>:d    0:w                              
        mov (16|M0)              r98.0<1>:d    0:w                              
        mov (16|M0)              r64.0<1>:f    r96.0<1;1,0>:f                   {Compacted,I@3}
        shr (16|M0)              r96.0<1>:ud   r48.0<1;1,0>:ud   1:w               {F@1}
L6440:
        join (16|M0)                         L6952                                
L6456:
        shl (16|M0)              r2.0<1>:d     r96.0<1;1,0>:d    2:w               {Compacted,I@2}
        shl (16|M0)              r8.0<1>:d     r98.0<1;1,0>:d    1:w               {Compacted}
        and (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     4:w               {Compacted,I@2}
        bfn.0xFE (16|M0)         r108.0<1>:ud  r2.0<1;0>:ud      r8.0<1;0>:ud      r56.0<1>:ud      {I@1} // s0|s1|s2
        cmp (16|M0)   (eq)f1.0   null<1>:d     r108.0<1;1,0>:d   0:w               {I@1}
        and (16|M0)              r116.0<1>:d   r64.0<1;1,0>:d    8388607:d              
(~f1.0) goto (16|M0)                         L6576                  L6576                
L6544:
        mov (16|M0)              r94.0<1>:d    0:w                              
        goto (16|M0)                         L6576                  L6736                
L6576:
        join (16|M0)                         L6736                                
L6592:
        cmp (16|M0)   (gt)f0.1   null<1>:d     r108.0<1;1,0>:ud  0x4:uw             
(~f0.1) goto (16|M0)                         L6656                  L6656                
L6624:
        mov (16|M0)              r94.0<1>:d    1:w                              
        goto (16|M0)                         L6656                  L6736                
L6656:
        join (16|M0)                         L6736                                
L6672:
        and (16|M0)   (ne)f1.0   null<1>:d     r64.0<1;1,0>:d    1:w              
(W)     mov (1|M0)               r2.0<1>:hf    0x1:hf                             
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r108.0<1;1,0>:d   4:w              
(f1.0)  sel (16|M0)              r94.0<1>:d    r2.0<0;1,0>:w     0:w               {F@1}
L6736:
        join (16|M0)                         L6952                                
L6752:
        add (16|M0)              r84.0<1>:d    r116.0<1;1,0>:d   r94.0<1;1,0>:d   {Compacted,I@2}
        cmp (16|M0)   (gt)f1.0   null<1>:d     r84.0<1;1,0>:ud   0x7FFFFF:ud              {I@1}
        add3 (16|M0)             r2.0<1>:d     r50.0<1;0>:d      r70.0<1;0>:d      -45:w              
(f1.0)  sel (16|M0)              r82.0<1>:d    r2.0<1;1,0>:d     r74.0<1;1,0>:d   {Compacted,I@1}
        cmp (16|M0)   (eq)f0.0   null<1>:d     r82.0<1;1,0>:d    255:w               {Compacted,I@1}
(f0.0)  goto (16|M0)                         L6896                  L6896                
L6824:
(~f1.0) sel (16|M0)              r2.0<1>:d     r84.0<1;1,0>:d    0:w              
        and (16|M0)              r8.0<1>:d     r52.0<1;1,0>:d    -2147483648:d              
        shl (16|M0)              r10.0<1>:d    r82.0<1;1,0>:d    23:w               {Compacted}
        bfn.0xFE (16|M0)         r120.0<1>:ud  r8.0<1;0>:ud      r10.0<1;0>:ud     r2.0<1>:ud       {I@1} // s0|s1|s2
        goto (16|M0)                         L6896                  L7480                
L6896:
        join (16|M0)                         L6952                                
L6912:
        cmp (16|M0)   (gt)f0.0   null<1>:d     r52.0<1;1,0>:d    -1:w               {Compacted}
(W)     mov (1|M0)               r2.0<1>:f     inf:f                               {Compacted,I@4}
(f0.0)  sel (16|M0)              r120.0<1>:f   r2.0<0;1,0>:f     -inf:f               {Compacted,F@1}
        goto (16|M0)                         L6952                  L7480                
L6952:
        join (16|M0)                         L7264                                
L6968:
        and (16|M0)   (ne)f1.1   r72.0<1>:d    r70.0<1;1,0>:d    63:w              
(f1.1)  goto (16|M0)                         L7032                  L7032                
L7000:
        mov (16|M0)              r88.0<1>:d    -1:w                              
        goto (16|M0)                         L7032                  L7160                
L7032:
        join (16|M0)                         L7160                                
L7048:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r72.0<1;1,0>:ud   0x20:uw              {I@5}
(f1.0)  goto (16|M0)                         L7112                  L7112                
L7080:
        mov (16|M0)              r88.0<1>:d    0:w                              
        goto (16|M0)                         L7112                  L7160                
L7112:
        join (16|M0)                         L7160                                
L7128:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                             
        shl (16|M0)              r88.0<1>:d    r2.0<0;1,0>:w     r72.0<1;1,0>:d   {F@1}
L7160:
        join (16|M0)                         L7264                                
L7176:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r88.0<1;0>:ud     r6.2<0;0>:ud      r48.0<1>:ud      {I@2} // (s0^s1)&s2
        add (16|M0)              r8.0<1>:d     -r70.0<1;1,0>:d   23:w               {Compacted}
        and (16|M0)              r10.0<1>:d    r52.0<1;1,0>:d    -2147483648:d              
        shl (16|M0)              r12.0<1>:d    r74.0<1;1,0>:d    23:w               {Compacted}
        shl (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     r8.0<1;1,0>:d    {Compacted,I@3}
        bfn.0xFE (16|M0)         r120.0<1>:ud  r10.0<1;0>:ud     r12.0<1;0>:ud     r2.0<1>:ud       {I@1} // s0|s1|s2
        goto (16|M0)                         L7264                  L7480                
L7264:
        join (16|M0)                         L7328                                
L7280:
        cmp (16|M0)   (gt)f1.1   null<1>:d     r52.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r2.0<1>:f     inf:f                               {Compacted,I@4}
(f1.1)  sel (16|M0)              r120.0<1>:f   r2.0<0;1,0>:f     -inf:f               {Compacted,F@1}
        goto (16|M0)                         L7328                  L7480                
L7328:
        join (16|M0)                         L7384                                
L7344:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r52.0<1;1,0>:d    0:w               {Compacted}
(W)     mov (1|M0)               r2.0<1>:f     -0.0:f                               {Compacted}
(f1.0)  sel (16|M0)              r120.0<1>:f   r2.0<0;1,0>:f     0.0:f               {Compacted,F@1}
        goto (16|M0)                         L7384                  L7480                
L7384:
        join (16|M0)                         L7448                                
L7400:
        cmp (16|M0)   (gt)f0.1   null<1>:d     r52.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r2.0<1>:f     inf:f                               {Compacted}
(f0.1)  sel (16|M0)              r120.0<1>:f   r2.0<0;1,0>:f     -inf:f               {Compacted,F@1}
        goto (16|M0)                         L7448                  L7480                
L7448:
        join (16|M0)                         L7480                                
L7464:
        bfn.0xF8 (16|M0)         r120.0<1>:ud  r52.0<1;0>:ud     r6.7<0;0>:ud      r6.3<0>:ud       {F@1} // s0&s1|s2
L7480:
        join (16|M0)                         L7496                                
L7496:
        rnde (16|M0)             r106.0<1>:f   r120.0<1;1,0>:f                  {Compacted,I@2}
        shr (16|M0)              r90.0<1>:ud   r106.0<1;1,0>:ud  23:w               {F@1}
        and (16|M0)   (ne)f0.1   r18.0<1>:d    r106.0<1;1,0>:d   8388607:d              
        and (16|M0)              r12.0<1>:d    r90.0<1;1,0>:d    255:w               {Compacted,I@2}
(f0.1)  cmp (16|M0)   (eq)f0.1   null<1>:d     r12.0<1;1,0>:d    255:w               {I@1}
(~f0.1) goto (16|M0)                         L7608                  L7608                
L7576:
        mov (16|M0)              r118.0<1>:ud  0x7FC00000:ud                             
        goto (16|M0)                         L7608                  L13552                
L7608:
        join (16|M0)                         L13552                                
L7624:
        cmp (16|M0)   (eq)f1.1   null<1>:d     r18.0<1;1,0>:d    0:w              
        add (16|M0)              r2.0<1>:d     r54.0<1;1,0>:d    -25165824:d              
        shr (16|M0)              r86.0<1>:ud   r2.0<1;1,0>:ud    23:w               {I@1}
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r12.0<1;1,0>:d    255:w              
        and (16|M0)              r88.0<1>:d    r86.0<1;1,0>:d    255:w               {Compacted,I@2}
(~f1.1) cmp (16|M0)   (eq)f1.1   null<1>:d     r88.0<1;1,0>:d    255:w               {I@1}
        xor (16|M0)              r60.0<1>:d    r2.0<1;1,0>:d     r106.0<1;1,0>:d  {Compacted}
(f1.1)  goto (16|M0)                         L13520                  L13520                
L7736:
        cmp (16|M0)   (eq)f0.0   null<1>:d     r88.0<1;1,0>:d    0:w               {Compacted}
        or (16|M0)               r2.0<1>:d     r12.0<1;1,0>:d    r18.0<1;1,0>:d   {Compacted}
(~f0.0) cmp (16|M0)   (eq)f0.0   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
(~f0.0) goto (16|M0)                         L7816                  L7816                
L7784:
        mov (16|M0)              r118.0<1>:ud  0x0:ud                             
        goto (16|M0)                         L7816                  L13552                
L7816:
        join (16|M0)                         L13520                                
L7832:
        cmp (16|M0)   (eq)f1.1   null<1>:d     r12.0<1;1,0>:d    0:w              
        add (16|M0)              r100.0<1>:d   r12.0<1;1,0>:d    -127:w               {Compacted}
(f1.1)  mov (16|M0)              r100.0<1>:d   -126:w                              
        add (16|M0)              r64.0<1>:d    r88.0<1;1,0>:d    r100.0<1;1,0>:d  {Compacted,I@1}
        cmp (16|M0)   (gt)f0.1   null<1>:d     r64.0<1;1,0>:d    254:w               {I@1}
(f0.1)  goto (16|M0)                         L13456                  L13456                
L7912:
        or (16|M0)    (eq)f0.0   null<4>:b     r90.0<1;1,0>:d    r86.0<1;1,0>:d  
(f0.0)  goto (16|M0)                         L13400                  L13400                
L7944:
(W)     mov (1|M0)               r2.0<1>:hf    0.0:hf                             
(W)     mov (1|M0)               r7.7<1>:d     0:w                               {$3.dst}
(f1.1)  sel (16|M0)              r8.0<1>:d     r2.0<0;1,0>:w     8388608:d               {F@1}
        or (16|M0)               r8.0<1>:d     r8.0<1;1,0>:d     r18.0<1;1,0>:d   {Compacted,I@1}
        shl (16|M0)              r58.0<1>:d    r8.0<1;1,0>:d     23:w               {Compacted,I@1}
        shr (16|M0)              r56.0<1>:ud   r8.0<1;1,0>:ud    9:w              
(W)     mov (1|M0)               r7.6<1>:f     -0.0:f                               {Compacted}
(W)     mov (2|M0)               r7.4<1>:d     0:w                              
L8048:
(W)     shl (1|M0)               r2.0<1>:d     r7.6<0;1,0>:d     31:w               {Compacted,F@1}
(W)     shr (1|M0)               r2.1<1>:ud    r7.7<0;1,0>:ud    1:w              
(W)     cmp (16|M0)   (gt)f1.1   null<1>:d     r7.4<0;1,0>:ud    0x3E:uw              {I@3}
(W)     or (1|M0)                r7.7<1>:d     r2.1<0;1,0>:d     r2.0<0;1,0>:d    {I@2}
        bfn.0xE0 (16|M0)         r8.0<1>:ud    r2.1<0;0>:ud      r2.0<0;0>:ud      r58.0<1>:ud      // (s0|s1)&s2
(W)     shr (1|M0)               r7.3<1>:ud    r7.6<0;1,0>:ud    1:w              
(W&f1.1) cmp (16|M0)  (eq)f1.1   null<1>:d     r7.5<0;1,0>:d     0:w              
        cmp (16|M0)   (eq)f0.1   null<1>:d     r8.0<1;1,0>:d     r7.7<0;1,0>:d    {I@3}
        and (16|M0)              r10.0<1>:d    r7.3<0;1,0>:d     r56.0<1;1,0>:d   {Compacted,I@3}
(W&~f1.1) cmp (16|M0) (gt)f1.1   null<1>:d     r7.5<0;1,0>:ud    0x0:uw             
(f0.1)  cmp (16|M0)   (eq)f0.1   null<1>:d     r10.0<1;1,0>:d    r7.3<0;1,0>:d    {I@2}
(W)     mov (1|M0)               r4.12<1>:hf   0x1:hf                             
(W)     addc (1|M0)              r14.0<1>:ud   r7.4<0;1,0>:ud    0x1:ud              {AccWrEn}
(f1.1)  sel (16|M0)              r12.0<1>:uw   r4.12<0;1,0>:uw   0x0:uw              {Compacted,F@1}
(f0.1)  sel (16|M0)              acc2.0<1>:uw  r4.12<0;1,0>:uw   0x0:uw             
(W)     mov (1|M0)               r3.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        or (16|M0)    (ne)f1.1   null<1>:uw    r12.0<1;1,0>:uw   acc2.0<1;1,0>:uw {I@3}
(W)     add (1|M0)               r3.0<1>:ud    r3.0<0;1,0>:ud    r7.5<0;1,0>:ud   {Compacted,I@2}
        mov (16|M0)              r112.0<1>:d   r7.4<0;1,0>:d                   
        mov (16|M0)              r110.0<1>:d   r7.5<0;1,0>:d                   
        mov (16|M0)              r62.0<1>:f    r14.0<0;1,0>:f                   {Compacted}
        mov (16|M0)              r108.0<1>:f   r3.0<0;1,0>:f                    {Compacted,I@3}
(f1.1)  goto (16|M0)                         L8424                  L8424                
L8360:
(W)     mov (1|M0)               r7.6<1>:d     r7.3<0;1,0>:d                   
(W)     mov (1|M0)               r7.4<1>:d     r14.0<0;1,0>:d                  
(W)     mov (1|M0)               r7.5<1>:d     r3.0<0;1,0>:d                   
(W)     jmpi                                 L8048                                
L8424:
        join (16|M0)                         L13400                                
L8440:
(W)     mov (1|M0)               r2.0<1>:f     8.68805e-44:f                              
(W)     mov (1|M0)               r3.0<1>:hf    0.0:hf                              {I@3}
        subb (8|M0)              r72.0<1>:ud   r2.0<0;1,0>:ud    r112.0<1;1,0>:ud {AccWrEn,Compacted,F@2}
        add3 (8|M0)              r104.0<1>:ud  -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r110.0<1>:ud    {F@1}
        subb (8|M8)              r73.0<1>:ud   r2.0<0;1,0>:ud    r113.0<1;1,0>:ud {AccWrEn}
        add3 (16|M0)             r66.0<1>:d    r64.0<1;0>:d      r72.0<1;0>:d      -173:w               {I@1}
        cmp (16|M0)   (gt)f1.1   null<1>:d     r66.0<1;1,0>:d    127:w               {I@1}
        add3 (8|M8)              r105.0<1>:ud  -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r111.0<1>:ud   
        add3 (16|M0)             r102.0<1>:d   r88.0<1;0>:d      r100.0<1;0>:d     r72.0<1>:d      
(f1.1)  goto (16|M0)                         L13336                  L13336                
L8592:
        cmp (16|M0)   (gt)f1.0   null<1>:d     r66.0<1;1,0>:d    -127:w              
(f1.0)  goto (16|M0)                         L11056                  L11056                
L8624:
        cmp (16|M0)   (lt)f0.1   null<1>:d     r66.0<1;1,0>:ud   0xFFFFFF6B:ud             
(f0.1)  goto (16|M0)                         L10552                  L10552                
L8656:
(W)     mov (1|M0)               r2.0<1>:f     8.82818e-44:f                              
(W)     mov (1|M0)               r3.0<1>:hf    0.0:hf                              {I@7}
        subb (8|M0)              r126.0<1>:ud  r2.0<0;1,0>:ud    r112.0<1;1,0>:ud {AccWrEn,Compacted,F@2}
        add3 (16|M0)             r28.0<1>:d    r64.0<1;0>:d      r72.0<1;0>:d      -23:w              
        add3 (8|M0)              r8.0<1>:ud    -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r110.0<1>:ud    {F@1}
        subb (8|M8)              r127.0<1>:ud  r2.0<0;1,0>:ud    r113.0<1;1,0>:ud {AccWrEn}
        cmp (16|M0)   (gt)f1.0   null<1>:d     r126.0<1;1,0>:ud  r28.0<1;1,0>:ud  {I@1}
        add3 (8|M8)              r9.0<1>:ud    -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r111.0<1>:ud   
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r8.0<1;1,0>:d     0:w               {I@1}
(~f1.0) cmp (16|M0)   (gt)f1.0   null<1>:d     r8.0<1;1,0>:ud    0x0:uw             
(f1.0)  goto (16|M0)                         L8880                  L8880                
L8824:
        add3 (16|M0)             r2.0<1>:d     r102.0<1;0>:d     -r126.0<1;0>:d    -23:w              
        mov (16|M0)              r64.0<1>:d    0:w                              
        shl (16|M0)              r66.0<1>:d    r58.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
        goto (16|M0)                         L8880                  L10488                
L8880:
        join (16|M0)                         L10488                                
L8896:
        add3 (16|M0)             r94.0<1>:d    r126.0<1;0>:d     -r102.0<1;0>:d    23:w              
        cmp (16|M0)   (lt)f0.0   null<1>:d     r94.0<1;1,0>:d    2:w               {Compacted,I@1}
(f0.0)  goto (16|M0)                         L9040                  L9040                
L8936:
        cmp (16|M0)   (eq)f1.1   null<1>:d     r94.0<1;1,0>:d    2:w              
(~f1.1) goto (16|M0)                         L9040                  L9144                
L8968:
        shr (16|M0)              r80.0<1>:ud   r58.0<1;1,0>:ud   1:w              
        mov (16|M0)              r32.0<1>:d    0:w                              
        mov (16|M0)              r22.0<1>:d    0:w                              
        mov (16|M0)              r16.0<1>:f    r80.0<1;1,0>:f                   {Compacted,I@3}
        goto (16|M0)                         L9040                  L9968                
L9040:
        join (16|M0)                         L9144                                
L9056:
        cmp (16|M0)   (eq)f1.0   null<1>:d     r94.0<1;1,0>:d    1:w              
(~f1.0) goto (16|M0)                         L9144                  L9144                
L9088:
        mov (16|M0)              r32.0<1>:d    0:w                              
        mov (16|M0)              r22.0<1>:d    0:w                              
        mov (16|M0)              r16.0<1>:f    r58.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L9144                  L9968                
L9144:
        join (16|M0)                         L9968                                
L9160:
        add3 (16|M0)             r2.0<1>:d     r126.0<1;0>:d     -r28.0<1;0>:d     -1:w              
        and (16|M0)   (ne)f0.1   r18.0<1>:d    r2.0<1;1,0>:d     63:w               {I@1}
(f0.1)  goto (16|M0)                         L9232                  L9232                
L9208:
        mov (16|M0)              r102.0<1>:f   r58.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L9232                  L9344                
L9232:
        join (16|M0)                         L9344                                
L9248:
        cmp (16|M0)   (lt)f0.0   null<1>:d     r18.0<1;1,0>:ud   0x20:uw              {I@4}
(~f0.0) add (16|M0)              r2.0<1>:d     r18.0<1;1,0>:d    -32:w              
(~f0.0) shr (16|M0)              r80.0<1>:ud   r56.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f0.0)  add (16|M0)              r2.0<1>:d     -r18.0<1;1,0>:d   32:w               {Compacted}
(f0.0)  shr (16|M0)              r8.0<1>:ud    r58.0<1;1,0>:ud   r18.0<1;1,0>:d  
(f0.0)  shl (16|M0)              r2.0<1>:d     r56.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f0.0)  or (16|M0)               r80.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
        mov (16|M0)              r102.0<1>:f   r80.0<1;1,0>:f                   {Compacted,I@1}
L9344:
        join (16|M0)                         L9968                                
L9360:
        add3 (16|M0)             r88.0<1>:d    r126.0<1;0>:d     -r28.0<1;0>:d     -2:w              
        and (16|M0)   (ne)f1.1   r16.0<1>:d    r88.0<1;1,0>:d    63:w               {A@1}
(f1.1)  goto (16|M0)                         L9432                  L9432                
L9408:
        mov (16|M0)              r80.0<1>:f    r58.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L9432                  L9536                
L9432:
        join (16|M0)                         L9536                                
L9448:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r16.0<1;1,0>:ud   0x20:uw              {I@4}
(~f1.0) add (16|M0)              r2.0<1>:d     r16.0<1;1,0>:d    -32:w              
(~f1.0) shr (16|M0)              r80.0<1>:ud   r56.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.0)  add (16|M0)              r2.0<1>:d     -r16.0<1;1,0>:d   32:w               {Compacted}
(f1.0)  shr (16|M0)              r8.0<1>:ud    r58.0<1;1,0>:ud   r16.0<1;1,0>:d  
(f1.0)  shl (16|M0)              r2.0<1>:d     r56.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.0)  or (16|M0)               r80.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
L9536:
        join (16|M0)                         L9968                                
L9552:
        and (16|M0)   (ne)f0.1   r104.0<1>:d   r88.0<1;1,0>:d    63:w              
(f0.1)  goto (16|M0)                         L9632                  L9632                
L9584:
        mov (16|M0)              r112.0<1>:d   -1:w                              
        mov (16|M0)              r118.0<1>:d   -1:w                              
        goto (16|M0)                         L9632                  L9816                
L9632:
        join (16|M0)                         L9816                                
L9648:
        cmp (16|M0)   (lt)f0.0   null<1>:d     r104.0<1;1,0>:ud  0x20:uw              {I@6}
(f0.0)  goto (16|M0)                         L9752                  L9752                
L9680:
        add (16|M0)              r2.0<1>:d     r104.0<1;1,0>:d   -32:w               {Compacted}
(W)     mov (1|M0)               r4.12<1>:hf   -qnan(0x1FF):hf                             
        mov (16|M0)              r112.0<1>:d   0:w                              
        shl (16|M0)              r118.0<1>:d   r4.12<0;1,0>:w    r2.0<1;1,0>:d    {A@1}
        goto (16|M0)                         L9752                  L9816                
L9752:
        join (16|M0)                         L9816                                
L9768:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (16|M0)              r118.0<1>:d   -1:w                              
        shl (16|M0)              r112.0<1>:d   r2.0<0;1,0>:w     r104.0<1;1,0>:d  {F@1}
L9816:
        join (16|M0)                         L9968                                
L9832:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r112.0<1;0>:ud    r6.2<0;0>:ud      r58.0<1>:ud      {I@2} // (s0^s1)&s2
        cmp (16|M0)   (ne)f1.1   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
        bfn.0x60 (16|M0)         r8.0<1>:ud    r118.0<1;0>:ud    r6.2<0;0>:ud      r56.0<1>:ud      // (s0^s1)&s2
(~f1.1) cmp (16|M0)   (ne)f1.1   null<1>:d     r8.0<1;1,0>:d     0:w               {I@1}
(W)     mov (1|M0)               r4.12<1>:hf   -qnan(0x1FF):hf                             
        shl (16|M0)              r12.0<1>:d    r80.0<1;1,0>:d    1:w               {Compacted}
(f1.1)  sel (16|M0)              r10.0<1>:d    r4.12<0;1,0>:w    0:w               {F@1}
        mov (16|M0)              r16.0<1>:f    r102.0<1;1,0>:f                  {Compacted}
        and (16|M0)              r22.0<1>:d    r12.0<1;1,0>:d    2:w               {Compacted,I@2}
        mov (16|M0)              r32.0<1>:d    -r10.0<1;1,0>:d                  {I@2}
L9968:
        join (16|M0)                         L10488                                
L9984:
        and (16|M0)   (ne)f1.1   r14.0<1>:d    r94.0<1;1,0>:d    63:w              
(f1.1)  goto (16|M0)                         L10040                  L10040                
L10016:
        mov (16|M0)              r80.0<1>:f    r58.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L10040                  L10144                
L10040:
        join (16|M0)                         L10144                                
L10056:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r14.0<1;1,0>:ud   0x20:uw              {I@4}
(~f1.0) add (16|M0)              r2.0<1>:d     r14.0<1;1,0>:d    -32:w              
(~f1.0) shr (16|M0)              r80.0<1>:ud   r56.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.0)  add (16|M0)              r2.0<1>:d     -r14.0<1;1,0>:d   32:w               {Compacted}
(f1.0)  shr (16|M0)              r8.0<1>:ud    r58.0<1;1,0>:ud   r14.0<1;1,0>:d  
(f1.0)  shl (16|M0)              r2.0<1>:d     r56.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.0)  or (16|M0)               r80.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
L10144:
        join (16|M0)                         L10488                                
L10160:
        shl (16|M0)              r2.0<1>:d     r16.0<1;1,0>:d    2:w               {Compacted}
        and (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     4:w               {Compacted,I@1}
        bfn.0xFE (16|M0)         r74.0<1>:ud   r2.0<1;0>:ud      r22.0<1;0>:ud     r32.0<1>:ud      {I@1} // s0|s1|s2
        cmp (16|M0)   (eq)f0.1   null<1>:d     r74.0<1;1,0>:d    0:w               {I@1}
(~f0.1) goto (16|M0)                         L10256                  L10256                
L10224:
        mov (16|M0)              r76.0<1>:d    0:w                              
        goto (16|M0)                         L10256                  L10416                
L10256:
        join (16|M0)                         L10416                                
L10272:
        cmp (16|M0)   (gt)f0.0   null<1>:d     r74.0<1;1,0>:ud   0x4:uw             
(~f0.0) goto (16|M0)                         L10336                  L10336                
L10304:
        mov (16|M0)              r76.0<1>:d    1:w                              
        goto (16|M0)                         L10336                  L10416                
L10336:
        join (16|M0)                         L10416                                
L10352:
        and (16|M0)   (ne)f1.0   null<1>:d     r80.0<1;1,0>:d    1:w              
(W)     mov (1|M0)               r2.0<1>:hf    0x1:hf                             
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r74.0<1;1,0>:d    4:w              
(f1.0)  sel (16|M0)              r76.0<1>:d    r2.0<0;1,0>:w     0:w               {F@1}
L10416:
        join (16|M0)                         L10488                                
L10432:
        add (16|M0)              r2.0<1>:d     r76.0<1;1,0>:d    r80.0<1;1,0>:d   {Compacted,I@2}
        cmp (16|M0)   (gt)f1.1   null<1>:d     r2.0<1;1,0>:ud    0x7FFFFF:ud              {I@1}
(W)     mov (1|M0)               r4.6<1>:f     0x800000:f                               {Compacted}
(~f1.1) sel (16|M0)              r66.0<1>:d    r2.0<1;1,0>:d     0:w              
(f1.1)  sel (16|M0)              r64.0<1>:d    r4.6<0;1,0>:d     0:w               {Compacted,F@1}
L10488:
        join (16|M0)                         L10552                                
L10504:
        and (16|M0)              r2.0<1>:d     r60.0<1;1,0>:d    -2147483648:d              
        bfn.0xFE (16|M0)         r118.0<1>:ud  r2.0<1;0>:ud      r64.0<1;0>:ud     r66.0<1>:ud      {I@1} // s0|s1|s2
        goto (16|M0)                         L10552                  L13552                
L10552:
        join (16|M0)                         L11056                                
L10568:
        and (16|M0)   (ne)f1.1   r86.0<1>:d    r72.0<1;1,0>:d    63:w              
(f1.1)  goto (16|M0)                         L10648                  L10648                
L10600:
        mov (16|M0)              r92.0<1>:d    -1:w                              
        mov (16|M0)              r100.0<1>:d   -1:w                              
        goto (16|M0)                         L10648                  L10832                
L10648:
        join (16|M0)                         L10832                                
L10664:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r86.0<1;1,0>:ud   0x20:uw              {I@6}
(f1.0)  goto (16|M0)                         L10768                  L10768                
L10696:
        add (16|M0)              r2.0<1>:d     r86.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r4.12<1>:hf   -qnan(0x1FF):hf                             
        mov (16|M0)              r92.0<1>:d    0:w                              
        shl (16|M0)              r100.0<1>:d   r4.12<0;1,0>:w    r2.0<1;1,0>:d    {A@1}
        goto (16|M0)                         L10768                  L10832                
L10768:
        join (16|M0)                         L10832                                
L10784:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (16|M0)              r100.0<1>:d   -1:w                              
        shl (16|M0)              r92.0<1>:d    r2.0<0;1,0>:w     r86.0<1;1,0>:d   {F@1}
L10832:
        join (16|M0)                         L11056                                
L10848:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r92.0<1;0>:ud     r6.2<0;0>:ud      r58.0<1>:ud      {I@2} // (s0^s1)&s2
        cmp (16|M0)   (ne)f1.0   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
        bfn.0x60 (16|M0)         r8.0<1>:ud    r100.0<1;0>:ud    r6.2<0;0>:ud      r56.0<1>:ud      // (s0^s1)&s2
        cmp (16|M0)   (gt)f0.1   null<1>:d     r60.0<1;1,0>:d    -1:w              
(~f1.0) cmp (16|M0)   (ne)f1.0   null<1>:d     r8.0<1;1,0>:d     0:w               {I@2}
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r66.0<1;1,0>:d    -150:w              
(f0.1)  goto (16|M0)                         L11000                  L11000                
L10960:
(W)     mov (1|M0)               r2.0<1>:ud    0x80000001:ud                             
(f1.0)  sel (16|M0)              r118.0<1>:f   r2.0<0;1,0>:f     -0.0:f               {Compacted,I@1}
        goto (16|M0)                         L11000                  L13552                
L11000:
        join (16|M0)                         L11056                                
L11016:
(W)     mov (1|M0)               r2.0<1>:ud    0x1:ud                              {F@1}
(f1.0)  sel (16|M0)              r118.0<1>:f   r2.0<0;1,0>:f     0.0:f               {Compacted,I@1}
        goto (16|M0)                         L11056                  L13552                
L11056:
        join (16|M0)                         L13336                                
L11072:
        cmp (16|M0)   (lt)f0.1   null<1>:d     r72.0<1;1,0>:ud   0x18:uw             
        add3 (16|M0)             r78.0<1>:d    r64.0<1;0>:d      r72.0<1;0>:d      -46:w              
(f0.1)  cmp (16|M0)   (eq)f0.1   null<1>:d     r104.0<1;1,0>:d   0:w              
(f0.1)  goto (16|M0)                         L13024                  L13024                
L11136:
        shl (16|M0)              r2.0<1>:d     r62.0<1;1,0>:d    1:w               {Compacted,F@1}
        shr (16|M0)              r8.0<1>:ud    r62.0<1;1,0>:ud   31:w              
        shl (16|M0)              r10.0<1>:d    r108.0<1;1,0>:d   1:w               {Compacted}
        cmp (16|M0)   (lt)f0.1   null<1>:d     r2.0<1;1,0>:ud    0x4E:uw              {I@3}
        or (16|M0)               r10.0<1>:d    r10.0<1;1,0>:d    r8.0<1;1,0>:d    {Compacted,I@2}
(f0.1)  cmp (16|M0)   (eq)f0.1   null<1>:d     r10.0<1;1,0>:d    0:w               {I@1}
(~f0.1) cmp (16|M0)   (lt)f0.1   null<1>:d     r10.0<1;1,0>:d    0:w              
(f0.1)  goto (16|M0)                         L11360                  L11360                
L11240:
        cmp (16|M0)   (eq)f0.0   null<1>:d     r62.0<1;1,0>:d    39:w               {Compacted}
(f0.0)  cmp (16|M0)   (eq)f0.0   null<1>:d     r108.0<1;1,0>:d   0:w              
(~f0.0) goto (16|M0)                         L11360                  L11424                
L11280:
        shr (16|M0)              r80.0<1>:ud   r58.0<1;1,0>:ud   1:w              
        mov (16|M0)              r52.0<1>:d    0:w                              
        mov (16|M0)              r14.0<1>:d    0:w                              
        mov (16|M0)              r62.0<1>:f    r80.0<1;1,0>:f                   {Compacted,I@3}
        mov (16|M0)              r80.0<1>:f    r58.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L11360                  L12520                
L11360:
        join (16|M0)                         L11424                                
L11376:
        cmp (16|M0)   (eq)f1.1   null<1>:d     r62.0<1;1,0>:d    38:w               {F@2}
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r108.0<1;1,0>:d   0:w              
(f1.1)  goto (16|M0)                         L11424                  L12432                
L11424:
        join (16|M0)                         L12432                                
L11440:
        add (16|M0)              r2.0<1>:d     -r62.0<1;1,0>:d   39:w               {Compacted}
        and (16|M0)   (ne)f0.0   r26.0<1>:d    r2.0<1;1,0>:d     63:w               {Compacted,I@1}
        add (16|M0)              r106.0<1>:d   -r62.0<1;1,0>:d   40:w               {Compacted}
(f0.0)  goto (16|M0)                         L11504                  L11504                
L11480:
        mov (16|M0)              r86.0<1>:f    r58.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L11504                  L11616                
L11504:
        join (16|M0)                         L11616                                
L11520:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r26.0<1;1,0>:ud   0x20:uw              {I@5}
(~f1.1) add (16|M0)              r2.0<1>:d     r26.0<1;1,0>:d    -32:w              
(~f1.1) shr (16|M0)              r80.0<1>:ud   r56.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.1)  add (16|M0)              r2.0<1>:d     -r26.0<1;1,0>:d   32:w               {Compacted}
(f1.1)  shr (16|M0)              r8.0<1>:ud    r58.0<1;1,0>:ud   r26.0<1;1,0>:d  
(f1.1)  shl (16|M0)              r2.0<1>:d     r56.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.1)  or (16|M0)               r80.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
        mov (16|M0)              r86.0<1>:f    r80.0<1;1,0>:f                   {Compacted,I@1}
L11616:
        join (16|M0)                         L12432                                
L11632:
        add (16|M0)              r96.0<1>:d    -r62.0<1;1,0>:d   38:w               {Compacted}
        and (16|M0)   (ne)f1.0   r32.0<1>:d    r96.0<1;1,0>:d    63:w               {I@1}
(f1.0)  goto (16|M0)                         L11696                  L11696                
L11672:
        mov (16|M0)              r110.0<1>:f   r58.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L11696                  L11808                
L11696:
        join (16|M0)                         L11808                                
L11712:
        cmp (16|M0)   (lt)f0.1   null<1>:d     r32.0<1;1,0>:ud   0x20:uw              {I@4}
(~f0.1) add (16|M0)              r2.0<1>:d     r32.0<1;1,0>:d    -32:w              
(~f0.1) shr (16|M0)              r80.0<1>:ud   r56.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f0.1)  add (16|M0)              r2.0<1>:d     -r32.0<1;1,0>:d   32:w               {Compacted}
(f0.1)  shr (16|M0)              r8.0<1>:ud    r58.0<1;1,0>:ud   r32.0<1;1,0>:d  
(f0.1)  shl (16|M0)              r2.0<1>:d     r56.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f0.1)  or (16|M0)               r80.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
        mov (16|M0)              r110.0<1>:f   r80.0<1;1,0>:f                   {Compacted,I@1}
L11808:
        join (16|M0)                         L12432                                
L11824:
        and (16|M0)   (ne)f0.0   r122.0<1>:d   r96.0<1;1,0>:d    63:w               {Compacted}
(f0.0)  goto (16|M0)                         L11896                  L11896                
L11848:
        mov (16|M0)              r126.0<1>:d   -1:w                              
        mov (16|M0)              r12.0<1>:d    -1:w                              
        goto (16|M0)                         L11896                  L12080                
L11896:
        join (16|M0)                         L12080                                
L11912:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r122.0<1;1,0>:ud  0x20:uw              {I@6}
(f1.1)  goto (16|M0)                         L12016                  L12016                
L11944:
        add (16|M0)              r2.0<1>:d     r122.0<1;1,0>:d   -32:w               {Compacted}
(W)     mov (1|M0)               r4.12<1>:hf   -qnan(0x1FF):hf                             
        mov (16|M0)              r126.0<1>:d   0:w                              
        shl (16|M0)              r12.0<1>:d    r4.12<0;1,0>:w    r2.0<1;1,0>:d    {A@1}
        goto (16|M0)                         L12016                  L12080                
L12016:
        join (16|M0)                         L12080                                
L12032:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (16|M0)              r12.0<1>:d    -1:w                              
        shl (16|M0)              r126.0<1>:d   r2.0<0;1,0>:w     r122.0<1;1,0>:d  {F@1}
L12080:
        join (16|M0)                         L12432                                
L12096:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r126.0<1;0>:ud    r6.2<0;0>:ud      r58.0<1>:ud      {I@2} // (s0^s1)&s2
        cmp (16|M0)   (ne)f1.0   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
        bfn.0x60 (16|M0)         r8.0<1>:ud    r12.0<1;0>:ud     r6.2<0;0>:ud      r56.0<1>:ud      // (s0^s1)&s2
(~f1.0) cmp (16|M0)   (ne)f1.0   null<1>:d     r8.0<1;1,0>:d     0:w               {I@1}
(W)     mov (1|M0)               r4.12<1>:hf   -qnan(0x1FF):hf                             
(f1.0)  sel (16|M0)              r10.0<1>:d    r4.12<0;1,0>:w    0:w               {F@1}
        and (16|M0)   (ne)f1.0   r30.0<1>:d    r106.0<1;1,0>:d   63:w              
        mov (16|M0)              r52.0<1>:d    -r10.0<1;1,0>:d                  {I@2}
(f1.0)  goto (16|M0)                         L12264                  L12264                
L12240:
        mov (16|M0)              r80.0<1>:f    r58.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L12264                  L12368                
L12264:
        join (16|M0)                         L12368                                
L12280:
        cmp (16|M0)   (lt)f0.1   null<1>:d     r30.0<1;1,0>:ud   0x20:uw              {I@5}
(~f0.1) add (16|M0)              r2.0<1>:d     r30.0<1;1,0>:d    -32:w              
(~f0.1) shr (16|M0)              r80.0<1>:ud   r56.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f0.1)  add (16|M0)              r2.0<1>:d     -r30.0<1;1,0>:d   32:w               {Compacted}
(f0.1)  shr (16|M0)              r8.0<1>:ud    r58.0<1;1,0>:ud   r30.0<1;1,0>:d  
(f0.1)  shl (16|M0)              r2.0<1>:d     r56.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f0.1)  or (16|M0)               r80.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
L12368:
        join (16|M0)                         L12432                                
L12384:
        shl (16|M0)              r2.0<1>:d     r110.0<1;1,0>:d   1:w               {Compacted}
        mov (16|M0)              r62.0<1>:f    r80.0<1;1,0>:f                   {Compacted,I@3}
        and (16|M0)              r14.0<1>:d    r2.0<1;1,0>:d     2:w               {Compacted,I@1}
        mov (16|M0)              r80.0<1>:f    r86.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L12432                  L12520                
L12432:
        join (16|M0)                         L12520                                
L12448:
        shr (16|M0)              r80.0<1>:ud   r58.0<1;1,0>:ud   2:w               {F@1}
        mov (16|M0)              r52.0<1>:d    0:w                              
        mov (16|M0)              r14.0<1>:d    0:w                              
        mov (16|M0)              r62.0<1>:f    r80.0<1;1,0>:f                   {Compacted,I@3}
        shr (16|M0)              r80.0<1>:ud   r58.0<1;1,0>:ud   1:w               {F@1}
L12520:
        join (16|M0)                         L13024                                
L12536:
        shl (16|M0)              r2.0<1>:d     r80.0<1;1,0>:d    2:w               {Compacted,I@2}
        and (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     4:w               {Compacted,I@1}
        bfn.0xFE (16|M0)         r90.0<1>:ud   r2.0<1;0>:ud      r14.0<1;0>:ud     r52.0<1>:ud      {I@1} // s0|s1|s2
        cmp (16|M0)   (eq)f0.0   null<1>:d     r90.0<1;1,0>:d    0:w               {Compacted,I@1}
        and (16|M0)              r114.0<1>:d   r62.0<1;1,0>:d    8388607:d              
(~f0.0) goto (16|M0)                         L12640                  L12640                
L12608:
        mov (16|M0)              r84.0<1>:d    0:w                              
        goto (16|M0)                         L12640                  L12800                
L12640:
        join (16|M0)                         L12800                                
L12656:
        cmp (16|M0)   (gt)f1.1   null<1>:d     r90.0<1;1,0>:ud   0x4:uw             
(~f1.1) goto (16|M0)                         L12720                  L12720                
L12688:
        mov (16|M0)              r84.0<1>:d    1:w                              
        goto (16|M0)                         L12720                  L12800                
L12720:
        join (16|M0)                         L12800                                
L12736:
        and (16|M0)   (ne)f0.1   null<1>:d     r62.0<1;1,0>:d    1:w              
(W)     mov (1|M0)               r2.0<1>:hf    0x1:hf                             
(f0.1)  cmp (16|M0)   (eq)f0.1   null<1>:d     r90.0<1;1,0>:d    4:w              
(f0.1)  sel (16|M0)              r84.0<1>:d    r2.0<0;1,0>:w     0:w               {F@1}
L12800:
        join (16|M0)                         L13024                                
L12816:
        add (16|M0)              r80.0<1>:d    r114.0<1;1,0>:d   r84.0<1;1,0>:d   {Compacted,I@2}
        cmp (16|M0)   (gt)f0.1   null<1>:d     r80.0<1;1,0>:ud   0x7FFFFF:ud              {I@1}
        add3 (16|M0)             r2.0<1>:d     r64.0<1;0>:d      r72.0<1;0>:d      -45:w              
(f0.1)  sel (16|M0)              r70.0<1>:d    r2.0<1;1,0>:d     r78.0<1;1,0>:d   {Compacted,I@1}
        cmp (16|M0)   (eq)f1.0   null<1>:d     r70.0<1;1,0>:d    255:w               {I@1}
(f1.0)  goto (16|M0)                         L12968                  L12968                
L12896:
(~f0.1) sel (16|M0)              r2.0<1>:d     r80.0<1;1,0>:d    0:w              
        and (16|M0)              r8.0<1>:d     r60.0<1;1,0>:d    -2147483648:d              
        shl (16|M0)              r10.0<1>:d    r70.0<1;1,0>:d    23:w               {Compacted}
        bfn.0xFE (16|M0)         r118.0<1>:ud  r8.0<1;0>:ud      r10.0<1;0>:ud     r2.0<1>:ud       {I@1} // s0|s1|s2
        goto (16|M0)                         L12968                  L13552                
L12968:
        join (16|M0)                         L13024                                
L12984:
        cmp (16|M0)   (gt)f0.0   null<1>:d     r60.0<1;1,0>:d    -1:w               {Compacted}
(W)     mov (1|M0)               r2.0<1>:f     inf:f                               {Compacted,I@4}
(f0.0)  sel (16|M0)              r118.0<1>:f   r2.0<0;1,0>:f     -inf:f               {Compacted,F@1}
        goto (16|M0)                         L13024                  L13552                
L13024:
        join (16|M0)                         L13336                                
L13040:
        and (16|M0)   (ne)f0.1   r62.0<1>:d    r72.0<1;1,0>:d    63:w              
(f0.1)  goto (16|M0)                         L13104                  L13104                
L13072:
        mov (16|M0)              r80.0<1>:d    -1:w                              
        goto (16|M0)                         L13104                  L13232                
L13104:
        join (16|M0)                         L13232                                
L13120:
        cmp (16|M0)   (lt)f0.0   null<1>:d     r62.0<1;1,0>:ud   0x20:uw              {A@1}
(f0.0)  goto (16|M0)                         L13184                  L13184                
L13152:
        mov (16|M0)              r80.0<1>:d    0:w                              
        goto (16|M0)                         L13184                  L13232                
L13184:
        join (16|M0)                         L13232                                
L13200:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                             
        shl (16|M0)              r80.0<1>:d    r2.0<0;1,0>:w     r62.0<1;1,0>:d   {F@1}
L13232:
        join (16|M0)                         L13336                                
L13248:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r80.0<1;0>:ud     r6.2<0;0>:ud      r58.0<1>:ud      {I@2} // (s0^s1)&s2
        add (16|M0)              r8.0<1>:d     -r72.0<1;1,0>:d   23:w               {Compacted}
        and (16|M0)              r10.0<1>:d    r60.0<1;1,0>:d    -2147483648:d              
        shl (16|M0)              r12.0<1>:d    r78.0<1;1,0>:d    23:w               {Compacted}
        shl (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     r8.0<1;1,0>:d    {Compacted,I@3}
        bfn.0xFE (16|M0)         r118.0<1>:ud  r10.0<1;0>:ud     r12.0<1;0>:ud     r2.0<1>:ud       {I@1} // s0|s1|s2
        goto (16|M0)                         L13336                  L13552                
L13336:
        join (16|M0)                         L13400                                
L13352:
        cmp (16|M0)   (gt)f1.1   null<1>:d     r60.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r2.0<1>:f     inf:f                               {Compacted,I@4}
(f1.1)  sel (16|M0)              r118.0<1>:f   r2.0<0;1,0>:f     -inf:f               {Compacted,F@1}
        goto (16|M0)                         L13400                  L13552                
L13400:
        join (16|M0)                         L13456                                
L13416:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r60.0<1;1,0>:d    0:w               {Compacted}
(W)     mov (1|M0)               r2.0<1>:f     -0.0:f                               {Compacted}
(f1.0)  sel (16|M0)              r118.0<1>:f   r2.0<0;1,0>:f     0.0:f               {Compacted,F@1}
        goto (16|M0)                         L13456                  L13552                
L13456:
        join (16|M0)                         L13520                                
L13472:
        cmp (16|M0)   (gt)f0.1   null<1>:d     r60.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r2.0<1>:f     inf:f                               {Compacted}
(f0.1)  sel (16|M0)              r118.0<1>:f   r2.0<0;1,0>:f     -inf:f               {Compacted,F@1}
        goto (16|M0)                         L13520                  L13552                
L13520:
        join (16|M0)                         L13552                                
L13536:
        bfn.0xF8 (16|M0)         r118.0<1>:ud  r60.0<1;0>:ud     r6.7<0;0>:ud      r6.3<0>:ud       {F@1} // s0&s1|s2
L13552:
        join (16|M0)                         L13568                                
L13568:
        cmp (16|M0)   (lt)f1.1   null<1>:f     r44.0<1;1,0>:f    0.0:f               {I@7}
(W)     cmp (16|M0)   (eq)f1.0   null<1>:d     r6.0<0;1,0>:d     0:w              
(f1.1)  sel (16|M0)              r2.0<1>:f     -r118.0<1;1,0>:f  r118.0<1;1,0>:f  {Compacted,I@3}
        mov (8|M0)               r58.0<1>:hf   r2.0<1;1,0>:f                    {F@1}
        mov (8|M8)               r58.8<1>:hf   r3.0<1;1,0>:f                   
(~f1.0) goto (16|M0)                         L13688                  L13688                
L13656:
        mov (16|M0)              r122.0<1>:d   -1:w                              
        goto (16|M0)                         L13688                  L14048                
L13688:
        join (16|M0)                         L14048                                
L13704:
(W)     xor (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x30:uw              {A@1}
(W)     mov (1|M0)               r2.0<1>:f     r6.0<0;1,0>:ud                   {Compacted,A@1}
(W)     mov (1|M0)               r3.2<1>:f     0xB4C00000:f                               {Compacted}
(W)     math.inv (1|M0)          r3.1<1>:f     r2.0<0;1,0>:f                    {@2,$7}
        mov (16|M0)              r8.0<1>:f     r34.0<1;1,0>:ud                  {Compacted}
        sync.nop                             null                             {Compacted,$7.dst}
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
        cmp (16|M0)   (ge)f0.1   r8.0<1>:ud    r30.0<1;1,0>:ud   r6.0<0;1,0>:ud   {I@1}
        add3 (16|M0)             r122.0<1>:d   r28.0<1;0>:d      r14.0<1;0>:d      -r8.0<1>:d       {I@1}
L14048:
        join (16|M0)                         L14064                                
L14064:
(W)     mul (8|M0)               acc0.0<1>:d   r122.0<1;1,0>:d   r6.0<0;1,0>:uw   {Compacted,I@2}
        mach (8|M0)              r2.0<1>:d     r122.0<1;1,0>:d   r6.0<0;1,0>:d    {Compacted}
(W)     mul (8|M8)               acc0.0<1>:d   r123.0<1;1,0>:d   r6.0<0;1,0>:uw  
        mach (8|M8)              r3.0<1>:d     r123.0<1;1,0>:d   r6.0<0;1,0>:d    {Compacted}
        mul (8|M0)               acc0.0<1>:ud  r122.0<1;1,0>:ud  r6.2<0;1,0>:uw  
        mach (8|M0)              r10.0<1>:ud   r122.0<1;1,0>:ud  r6.1<0;1,0>:ud   {AccWrEn,Compacted}
        add (16|M0)              r8.0<1>:d     r34.0<1;1,0>:d    -r2.0<1;1,0>:d   {Compacted,I@3}
        mov (8|M0)               r12.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mul (8|M8)               acc0.0<1>:ud  r123.0<1;1,0>:ud  r6.2<0;1,0>:uw  
        mach (8|M8)              r11.0<1>:ud   r123.0<1;1,0>:ud  r6.1<0;1,0>:ud   {AccWrEn}
        cmp (16|M0)   (lt)f0.1   null<1>:d     r40.0<1;1,0>:ud   r5.7<0;1,0>:ud  
        mov (8|M8)               r13.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mov (16|M0)              r16.0<1>:f    r10.0<1;1,0>:f                   {Compacted,A@3}
        mov (16|M0)              r14.0<1>:f    r12.0<1;1,0>:f                   {Compacted,I@1}
        addc (8|M0)              r18.0<1>:ud   r14.0<1;1,0>:ud   r36.0<1;1,0>:ud  {AccWrEn,Compacted,F@1}
(W)     mov (1|M0)               r4.6<1>:d     31:w                              
        add (8|M0)               r20.0<1>:ud   acc0.0<1;1,0>:ud  r16.0<1;1,0>:ud 
        addc (8|M8)              r19.0<1>:ud   r15.0<1;1,0>:ud   r37.0<1;1,0>:ud  {AccWrEn}
        add (8|M8)               r21.0<1>:ud   acc0.0<1;1,0>:ud  r17.0<1;1,0>:ud 
        mul (8|M0)               acc0.0<1>:ud  r18.0<1;1,0>:ud   r6.0<0;1,0>:uw   {I@5}
        mach (8|M0)              r2.0<1>:ud    r18.0<1;1,0>:ud   r6.0<0;1,0>:ud   {AccWrEn,Compacted}
        mov (8|M0)               r22.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mul (8|M8)               acc0.0<1>:ud  r19.0<1;1,0>:ud   r6.0<0;1,0>:uw   {I@5}
        mach (8|M8)              r3.0<1>:ud    r19.0<1;1,0>:ud   r6.0<0;1,0>:ud   {AccWrEn}
        mov (8|M8)               r23.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
(W)     mul (8|M0)               acc0.0<1>:d   r6.0<0;1,0>:ud    r20.0<2;1,0>:uw 
        add (16|M0)              r14.0<1>:d    r22.0<1;1,0>:d    r8.0<1;1,0>:d    {Compacted,I@2}
        mach (8|M0)              r10.0<1>:d    r6.0<0;1,0>:ud    r20.0<1;1,0>:d  
(W)     mul (8|M8)               acc0.0<1>:d   r6.0<0;1,0>:ud    r21.0<2;1,0>:uw 
        shl (16|M0)              r14.0<1>:d    r14.0<1;1,0>:d    5:w               {Compacted,I@3}
        mach (8|M8)              r11.0<1>:d    r6.0<0;1,0>:ud    r21.0<1;1,0>:d  
        bfn.0xEA (16|M0)         r28.0<1>:ud   r14.0<1;0>:ud     r42.0<1;0>:ud     r4.6<0>:ud       {I@2} // s0|s1&s2
        add (16|M0)              r12.0<1>:d    r2.0<1;1,0>:d     r10.0<1;1,0>:d   {Compacted,I@2}
(f0.1)  goto (16|M0)                         L14696                  L14696                
L14480:
        cmp (16|M0)   (eq)f0.0   null<1>:d     r38.0<1;1,0>:d    1:w               {Compacted}
(f0.0)  goto (16|M0)                         L14592                  L14592                
L14504:
        shl (16|M0)              r2.0<1>:d     r28.0<1;1,0>:d    1:w               {Compacted,I@5}
        sync.nop                             null                             {Compacted,$3.dst}
(W)     mov (1|M0)               a0.0<1>:ud    r7.2<0;1,0>:d                    {A@1}
        mov (16|M0)              r8.0<1>:ud    r58.0<1;1,0>:uw                 
        add (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     r6.6<0;1,0>:d    {Compacted,I@3}
        send.ugm (16|M0)         null     r2      r8:2    a0.0        0x240E0B04           {ExBSO,A@1,$8} // wr:2+2, rd:0; store.ugm.d16u32.a32.wb.wb.bss[a0.0]
        goto (16|M0)                         L14592                  L14792                
L14592:
        join (16|M0)                         L14696                                
L14608:
        shl (16|M0)              r2.0<1>:d     r28.0<1;1,0>:d    1:w               {Compacted,$8.src}
        sync.nop                             null                             {Compacted,$3.dst}
(W)     mov (1|M0)               a0.0<1>:ud    r7.1<0;1,0>:d                    {A@1}
        mov (16|M0)              r8.0<1>:ud    r58.0<1;1,0>:uw                 
        add (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     r6.5<0;1,0>:d    {Compacted,I@3}
        send.ugm (16|M0)         null     r2      r8:2    a0.0        0x240E0B04           {ExBSO,A@1,$9} // wr:2+2, rd:0; store.ugm.d16u32.a32.wb.wb.bss[a0.0]
        goto (16|M0)                         L14696                  L14792                
L14696:
        join (16|M0)                         L14792                                
L14712:
        sync.nop                             null                             {Compacted,$9.src}
        shl (16|M0)              r2.0<1>:d     r28.0<1;1,0>:d    1:w               {Compacted,$8.src}
        sync.nop                             null                             {Compacted,$3.dst}
(W)     mov (1|M0)               a0.0<1>:ud    r7.0<0;1,0>:d                    {A@1}
        mov (16|M0)              r8.0<1>:ud    r58.0<1;1,0>:uw                 
        add (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     r6.4<0;1,0>:d    {Compacted,I@3}
        send.ugm (16|M0)         null     r2      r8:2    a0.0        0x240E0B04           {ExBSO,A@1,$10} // wr:2+2, rd:0; store.ugm.d16u32.a32.wb.wb.bss[a0.0]
L14792:
        join (16|M0)                         L14808                                
L14808:
(W)     mov (8|M0)               r127.0<1>:f   r68.0<1;1,0>:f                   {Compacted,$3.src}
(W)     send.gtwy (1|M0)         null     r127    null:0  0x0            0x02000010           {EOT,A@1} // wr:1+0, rd:0; end of thread
L14832:
        nop                    
(W)     mov (16|M0)              null<1>:ud    0x9E09665A:ud                             
(W)     mov (16|M0)              null<1>:ud    0xA6E09A48:ud                             
(W)     mov (16|M0)              null<1>:ud    0x0:ud                             
(W)     mov (16|M0)              null<1>:ud    0x42:ud                             
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
