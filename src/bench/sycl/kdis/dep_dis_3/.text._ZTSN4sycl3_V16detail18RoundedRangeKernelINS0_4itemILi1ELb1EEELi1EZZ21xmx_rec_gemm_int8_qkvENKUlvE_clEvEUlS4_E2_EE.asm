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
(W)     mul (1|M0)               acc0.0<1>:ud  r4.3<0;1,0>:ud    r68.2<0;1,0>:uw  {A@1}
(W)     mach (1|M0)              r3.0<1>:ud    r4.3<0;1,0>:ud    r68.1<0;1,0>:ud  {AccWrEn,$1.dst}
        mov (16|M0)              r8.0<1>:d     r1.0<1;1,0>:uw                   {$0.dst}
(W)     mov (1|M0)               r2.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (8|M0)              r10.0<1>:ud   r2.0<0;1,0>:ud    r8.0<1;1,0>:ud   {AccWrEn,Compacted,I@1}
        add (8|M0)               r12.0<1>:ud   acc0.0<1;1,0>:ud  r3.0<0;1,0>:ud  
        addc (8|M8)              r11.0<1>:ud   r2.0<0;1,0>:ud    r9.0<1;1,0>:ud   {AccWrEn}
        add (8|M8)               r13.0<1>:ud   acc0.0<1;1,0>:ud  r3.0<0;1,0>:ud  
        addc (8|M0)              r34.0<1>:ud   r10.0<1;1,0>:ud   r4.0<0;1,0>:ud   {AccWrEn,Compacted,I@4}
        add (8|M0)               r32.0<1>:ud   acc0.0<1;1,0>:ud  r12.0<1;1,0>:ud  {I@4}
        addc (8|M8)              r35.0<1>:ud   r11.0<1;1,0>:ud   r4.0<0;1,0>:ud   {AccWrEn,I@4}
        cmp (16|M0)   (lt)f0.0   null<1>:d     r34.0<1;1,0>:ud   r4.6<0;1,0>:ud   {I@1}
        add (8|M8)               r33.0<1>:ud   acc0.0<1;1,0>:ud  r13.0<1;1,0>:ud 
(f0.0)  cmp (16|M0)   (eq)f0.0   null<1>:d     r32.0<1;1,0>:d    r4.7<0;1,0>:d    {I@1}
(~f0.0) cmp (16|M0)   (lt)f0.0   null<1>:d     r32.0<1;1,0>:ud   r4.7<0;1,0>:ud  
(~f0.0) goto (16|M0)                         L16000                  L16000                
L552:
(W)     cmp (16|M0)   (eq)f1.1   null<1>:d     r5.0<0;1,0>:d     0:w               {$2.dst}
(W)     cmp (16|M0)   (eq)f0.1   null<1>:d     r5.1<0;1,0>:d     0:w              
(W)     cmp (16|M0)   (eq)f0.0   null<1>:d     r5.4<0;1,0>:d     0:w               {Compacted}
        mov (16|M0)              r48.0<1>:f    r34.0<1;1,0>:f                   {Compacted}
        mov (16|M0)              r46.0<1>:f    r32.0<1;1,0>:f                   {Compacted}
(W)     mov (2|M0)               r7.3<1>:d     r5.2<1;1,0>:d                    {$3.dst}
(W)     mov (2|M0)               r69.1<1>:d    r6.2<1;1,0>:d                   
(W)     mov (1|M0)               r69.0<1>:d    31:w                              
(W)     mov (1|M0)               r7.7<1>:f     -0.0:f                               {Compacted}
(W)     mov (1|M0)               r7.6<1>:f     inf:f                               {Compacted}
(W)     mov (1|M0)               r7.5<1>:d     -1:w                              
(W)     mov (1|M0)               r69.6<1>:uw   f1.1<0;1,0>:uw                  
(W)     mov (2|M0)               r5.2<1>:d     r5.6<1;1,0>:d                   
(W)     mov (2|M0)               r5.6<1>:d     r6.0<1;1,0>:d                   
L736:
(W)     mov (1|M0)               f1.0<1>:uw    r69.6<0;1,0>:uw                  {I@3}
(~f1.0) goto (16|M0)                         L800                  L800                
L768:
        mov (16|M0)              r44.0<1>:d    -1:w                              
        goto (16|M0)                         L800                  L1176                
L800:
        join (16|M0)                         L1176                                
L816:
(W)     xor (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x30:uw              {A@1}
(W)     mov (1|M0)               r2.0<1>:f     r5.0<0;1,0>:ud                   {Compacted,A@1}
(W)     mov (1|M0)               r3.2<1>:f     0xB4C00000:f                               {Compacted}
(W)     math.inv (1|M0)          r3.1<1>:f     r2.0<0;1,0>:f                    {@2,$7}
        mov (16|M0)              r8.0<1>:f     r48.0<1;1,0>:ud                  {Compacted}
        sync.nop                             null                             {Compacted,$7.dst}
(W)     mad (1|M0)               r6.4<1>:f     r3.1<0;0>:f       r3.2<0;0>:f       r3.1<0>:f        {F@2}
(W)     mov (1|M0)               r2.1<1>:ud    r2.0<0;1,0>:f                   
        mov (16|M0)              r12.0<1>:ud   r8.0<1;1,0>:f                    {F@2}
        mul (16|M0)              r10.0<1>:f    r8.0<1;1,0>:f     r6.4<0;1,0>:f    {Compacted,F@1}
(W)     add (1|M0)               r3.0<1>:d     r5.0<0;1,0>:d     -r2.1<0;1,0>:d   {Compacted,I@2}
        add (16|M0)              r12.0<1>:d    r48.0<1;1,0>:d    -r12.0<1;1,0>:d  {Compacted,I@2}
        sync.allrd                           ($4,$5,$6)                
        mov (16|M0)              r14.0<1>:ud   r10.0<1;1,0>:f                   {F@1}
(W)     mov (1|M0)               r6.5<1>:f     r3.0<0;1,0>:ud                   {Compacted,I@3}
        mov (16|M0)              r16.0<1>:f    r12.0<1;1,0>:ud                  {Compacted,I@2}
        mov (16|M0)              r18.0<1>:f    r14.0<1;1,0>:ud                  {Compacted,I@1}
        mad (16|M0)              acc0.0<1>:f   r8.0<1;0>:f       r18.0<1;0>:f      -r2.0<0>:f       {Compacted,F@1}
        mad (16|M0)              acc2.0<1>:f   r16.0<1;0>:f      r18.0<1;0>:f      -r6.5<0>:f       {Compacted}
        add (16|M0)              acc0.0<1>:f   acc0.0<1;1,0>:f   acc2.0<1;1,0>:f 
        mul (16|M0)              r26.0<1>:f    r6.4<0;1,0>:f     acc0.0<1;1,0>:f 
(W)     xor (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x30:uw              {A@1}
        mov (16|M0)              r28.0<1>:ud   r26.0<1;1,0>:f                   {A@1}
        add (16|M0)              r30.0<1>:d    r28.0<1;1,0>:d    r14.0<1;1,0>:d   {Compacted,I@1}
(W)     mul (8|M0)               acc0.0<1>:d   r30.0<1;1,0>:d    r5.0<0;1,0>:uw   {Compacted,I@1}
        mach (8|M0)              r30.0<1>:d    r30.0<1;1,0>:d    r5.0<0;1,0>:d    {Compacted}
(W)     mul (8|M8)               acc0.0<1>:d   r31.0<1;1,0>:d    r5.0<0;1,0>:uw  
        mach (8|M8)              r31.0<1>:d    r31.0<1;1,0>:d    r5.0<0;1,0>:d    {Compacted}
        add (16|M0)              r30.0<1>:d    r48.0<1;1,0>:d    -r30.0<1;1,0>:d  {Compacted,I@1}
        cmp (16|M0)   (ge)f1.0   r8.0<1>:ud    r30.0<1;1,0>:ud   r5.0<0;1,0>:ud   {I@1}
        add3 (16|M0)             r44.0<1>:d    r28.0<1;0>:d      r14.0<1;0>:d      -r8.0<1>:d       {I@1}
L1176:
        join (16|M0)                         L16000                                
L1192:
(W)     mul (8|M0)               acc0.0<1>:d   r44.0<1;1,0>:d    r5.0<0;1,0>:uw   {Compacted,I@2}
        mach (8|M0)              r2.0<1>:d     r44.0<1;1,0>:d    r5.0<0;1,0>:d    {Compacted}
(W)     mul (8|M8)               acc0.0<1>:d   r45.0<1;1,0>:d    r5.0<0;1,0>:uw  
        mach (8|M8)              r3.0<1>:d     r45.0<1;1,0>:d    r5.0<0;1,0>:d    {Compacted}
        add (16|M0)              r42.0<1>:d    r48.0<1;1,0>:d    -r2.0<1;1,0>:d   {Compacted,I@1}
(~f0.1) goto (16|M0)                         L1288                  L1288                
L1256:
        mov (16|M0)              r40.0<1>:d    -1:w                              
        goto (16|M0)                         L1288                  L1672                
L1288:
        join (16|M0)                         L1672                                
L1304:
(W)     xor (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x30:uw              {A@1}
(W)     mov (1|M0)               r2.0<1>:f     r5.1<0;1,0>:ud                   {Compacted,A@1}
(W)     mov (1|M0)               r3.2<1>:f     0xB4C00000:f                               {Compacted}
(W)     math.inv (1|M0)          r3.1<1>:f     r2.0<0;1,0>:f                    {@2,$8}
        mov (16|M0)              r8.0<1>:f     r42.0<1;1,0>:ud                  {Compacted}
        sync.nop                             null                             {Compacted,$8.dst}
(W)     mad (1|M0)               r6.4<1>:f     r3.1<0;0>:f       r3.2<0;0>:f       r3.1<0>:f        {F@2}
(W)     mov (1|M0)               r2.1<1>:ud    r2.0<0;1,0>:f                   
        mov (16|M0)              r12.0<1>:ud   r8.0<1;1,0>:f                    {F@2}
        mul (16|M0)              r10.0<1>:f    r8.0<1;1,0>:f     r6.4<0;1,0>:f    {Compacted,F@1}
(W)     add (1|M0)               r3.0<1>:d     r5.1<0;1,0>:d     -r2.1<0;1,0>:d   {I@2}
        add (16|M0)              r12.0<1>:d    r42.0<1;1,0>:d    -r12.0<1;1,0>:d  {Compacted,I@2}
        sync.allrd                           ($4,$5,$6)                
        mov (16|M0)              r14.0<1>:ud   r10.0<1;1,0>:f                   {F@1}
(W)     mov (1|M0)               r6.5<1>:f     r3.0<0;1,0>:ud                   {Compacted,I@3}
        mov (16|M0)              r16.0<1>:f    r12.0<1;1,0>:ud                  {Compacted,I@2}
        mov (16|M0)              r18.0<1>:f    r14.0<1;1,0>:ud                  {Compacted,I@1}
        mad (16|M0)              acc0.0<1>:f   r8.0<1;0>:f       r18.0<1;0>:f      -r2.0<0>:f       {Compacted,F@1}
        mad (16|M0)              acc2.0<1>:f   r16.0<1;0>:f      r18.0<1;0>:f      -r6.5<0>:f       {Compacted}
        add (16|M0)              acc0.0<1>:f   acc0.0<1;1,0>:f   acc2.0<1;1,0>:f 
        mul (16|M0)              r26.0<1>:f    r6.4<0;1,0>:f     acc0.0<1;1,0>:f 
(W)     xor (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x30:uw              {A@1}
        mov (16|M0)              r28.0<1>:ud   r26.0<1;1,0>:f                   {A@1}
        add (16|M0)              r30.0<1>:d    r28.0<1;1,0>:d    r14.0<1;1,0>:d   {Compacted,I@1}
(W)     mul (8|M0)               acc0.0<1>:d   r30.0<1;1,0>:d    r5.2<0;1,0>:uw   {Compacted,I@1}
        mach (8|M0)              r30.0<1>:d    r30.0<1;1,0>:d    r5.1<0;1,0>:d    {Compacted}
(W)     mul (8|M8)               acc0.0<1>:d   r31.0<1;1,0>:d    r5.2<0;1,0>:uw  
        mach (8|M8)              r31.0<1>:d    r31.0<1;1,0>:d    r5.1<0;1,0>:d    {Compacted}
        add (16|M0)              r30.0<1>:d    r42.0<1;1,0>:d    -r30.0<1;1,0>:d  {Compacted,I@1}
        cmp (16|M0)   (ge)f1.1   r8.0<1>:ud    r30.0<1;1,0>:ud   r5.1<0;1,0>:ud   {I@1}
        add3 (16|M0)             r40.0<1>:d    r28.0<1;0>:d      r14.0<1;0>:d      -r8.0<1>:d       {I@1}
L1672:
        join (16|M0)                         L16000                                
L1688:
(W)     mul (8|M0)               acc0.0<1>:d   r40.0<1;1,0>:d    r5.2<0;1,0>:uw   {Compacted,I@2}
        shl (16|M0)              r8.0<1>:d     r48.0<1;1,0>:d    2:w               {Compacted}
        mach (8|M0)              r2.0<1>:d     r40.0<1;1,0>:d    r5.1<0;1,0>:d    {Compacted}
(W)     mul (8|M8)               acc0.0<1>:d   r41.0<1;1,0>:d    r5.2<0;1,0>:uw  
        mach (8|M8)              r3.0<1>:d     r41.0<1;1,0>:d    r5.1<0;1,0>:d    {Compacted}
        addc (8|M0)              r14.0<1>:ud   r8.0<1;1,0>:ud    r7.3<0;1,0>:ud   {AccWrEn,Compacted,I@4}
        shr (16|M0)              r10.0<1>:ud   r48.0<1;1,0>:ud   30:w              
        shl (16|M0)              r12.0<1>:d    r46.0<1;1,0>:d    2:w               {Compacted}
        sync.allrd                           ($5,$6)                
        mov (8|M0)               r16.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted,$4.src}
        addc (8|M8)              r15.0<1>:ud   r9.0<1;1,0>:ud    r7.3<0;1,0>:ud   {AccWrEn}
        or (16|M0)               r12.0<1>:d    r12.0<1;1,0>:d    r10.0<1;1,0>:d   {Compacted,I@3}
        mov (8|M8)               r22.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        add3 (8|M0)              r17.1<2>:ud   r16.0<1;0>:ud     r12.0<1;0>:ud     r7.4<0>:ud       {I@2}
        add3 (8|M8)              r19.1<2>:ud   r22.0<1;0>:ud     r13.0<1;0>:ud     r7.4<0>:ud       {I@2}
        mov (8|M0)               r17.0<2>:d    r14.0<1;1,0>:d                  
        mov (8|M8)               r19.0<2>:d    r15.0<1;1,0>:d                  
        add (16|M0)              r38.0<1>:d    r42.0<1;1,0>:d    -r2.0<1;1,0>:d   {Compacted}
        send.ugm (16|M0)         r50      r17     null:0  0x0            0x08280580           {A@2,$9} // wr:4+0, rd:2; load.ugm.d32.a64.ca.ca
        shr (16|M0)              r36.0<1>:ud   r38.0<1;1,0>:ud   5:w               {I@1}
        and (16|M0)              r2.0<1>:d     r50.0<1;1,0>:d    2147483647:d               {$9.dst}
        sel (16|M0)   (lt)f0.0   r14.0<1>:f    r2.0<1;1,0>:f     448.0:f               {Compacted,I@1}
        shr (16|M0)              r24.0<1>:ud   r14.0<1;1,0>:ud   23:w               {F@1}
        and (16|M0)   (ne)f1.1   r80.0<1>:d    r14.0<1;1,0>:d    8388607:d              
        and (16|M0)              r70.0<1>:d    r24.0<1;1,0>:d    255:w               {Compacted,I@2}
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r70.0<1;1,0>:d    255:w               {I@1}
        sel (16|M0)   (ge)f0.0   r10.0<1>:ud   r70.0<1;1,0>:ud   0x79:uw             
        shl (16|M0)              r60.0<1>:d    r10.0<1;1,0>:d    23:w               {Compacted,I@1}
(~f1.1) goto (16|M0)                         L2080                  L2080                
L2048:
        mov (16|M0)              r62.0<1>:ud   0x7FC00000:ud                             
        goto (16|M0)                         L2080                  L8056                
L2080:
        join (16|M0)                         L8056                                
L2096:
        cmp (16|M0)   (eq)f1.0   null<1>:d     r80.0<1;1,0>:d    0:w              
        add (16|M0)              r10.0<1>:d    -r60.0<1;1,0>:d   -2139095040:d               {I@6}
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r70.0<1;1,0>:d    255:w              
        xor (16|M0)              r58.0<1>:d    r10.0<1;1,0>:d    r14.0<1;1,0>:d   {Compacted,I@2}
(f1.0)  goto (16|M0)                         L8024                  L8024                
L2168:
        or (16|M0)    (eq)f1.1   null<1>:d     r70.0<1;1,0>:d    r80.0<1;1,0>:d  
(~f1.1) goto (16|M0)                         L2232                  L2232                
L2200:
        mov (16|M0)              r62.0<1>:ud   0x0:ud                             
        goto (16|M0)                         L2232                  L8056                
L2232:
        join (16|M0)                         L8024                                
L2248:
        cmp (16|M0)   (eq)f1.1   null<1>:d     r70.0<1;1,0>:d    0:w              
        shr (16|M0)              r78.0<1>:ud   r10.0<1;1,0>:ud   23:w              
        add (16|M0)              r76.0<1>:d    r70.0<1;1,0>:d    -127:w               {Compacted}
(f1.1)  mov (16|M0)              r76.0<1>:d    -126:w                              
        add (16|M0)              r56.0<1>:d    r78.0<1;1,0>:d    r76.0<1;1,0>:d   {Compacted,I@1}
        cmp (16|M0)   (gt)f1.0   null<1>:d     r56.0<1;1,0>:d    254:w               {I@1}
(f1.0)  goto (16|M0)                         L7960                  L7960                
L2344:
        or (16|M0)    (eq)f1.0   null<4>:b     r24.0<1;1,0>:d    r78.0<1;1,0>:d  
(f1.0)  goto (16|M0)                         L7896                  L7896                
L2376:
(W)     mov (1|M0)               r2.0<1>:hf    0.0:hf                             
(W)     mov (1|M0)               r14.0<1>:d    0:w                              
(f1.1)  sel (16|M0)              r8.0<1>:d     r2.0<0;1,0>:w     8388608:d               {F@1}
        or (16|M0)               r8.0<1>:d     r8.0<1;1,0>:d     r80.0<1;1,0>:d   {Compacted,I@1}
        shl (16|M0)              r54.0<1>:d    r8.0<1;1,0>:d     23:w               {Compacted,I@1}
        shr (16|M0)              r52.0<1>:ud   r8.0<1;1,0>:ud    9:w              
(W)     mov (1|M0)               r69.7<1>:f    -0.0:f                               {Compacted}
(W)     mov (2|M0)               r69.4<1>:d    0:w                              
L2480:
(W)     shl (1|M0)               r2.0<1>:d     r69.7<0;1,0>:d    31:w               {Compacted,F@1}
(W)     shr (1|M0)               r2.1<1>:ud    r14.0<0;1,0>:ud   1:w              
(W)     cmp (16|M0)   (gt)f1.1   null<1>:d     r69.4<0;1,0>:ud   0x3E:uw              {I@3}
(W)     or (1|M0)                r14.0<1>:d    r2.1<0;1,0>:d     r2.0<0;1,0>:d    {Compacted,I@2}
        bfn.0xE0 (16|M0)         r8.0<1>:ud    r2.1<0;0>:ud      r2.0<0;0>:ud      r54.0<1>:ud      // (s0|s1)&s2
(W)     shr (1|M0)               r69.6<1>:ud   r69.7<0;1,0>:ud   1:w              
(W&f1.1) cmp (16|M0)  (eq)f1.1   null<1>:d     r69.5<0;1,0>:d    0:w              
        cmp (16|M0)   (eq)f1.0   null<1>:d     r8.0<1;1,0>:d     r14.0<0;1,0>:d   {I@3}
        and (16|M0)              r10.0<1>:d    r69.6<0;1,0>:d    r52.0<1;1,0>:d   {Compacted,I@3}
(W&~f1.1) cmp (16|M0) (gt)f1.1   null<1>:d     r69.5<0;1,0>:ud   0x0:uw             
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r10.0<1;1,0>:d    r69.6<0;1,0>:d   {I@2}
(W)     mov (1|M0)               r6.8<1>:hf    0x1:hf                             
(W)     addc (1|M0)              r15.0<1>:ud   r69.4<0;1,0>:ud   0x1:ud              {AccWrEn}
(f1.1)  sel (16|M0)              r12.0<1>:uw   r6.8<0;1,0>:uw    0x0:uw              {Compacted,F@1}
(f1.0)  sel (16|M0)              acc2.0<1>:uw  r6.8<0;1,0>:uw    0x0:uw             
(W)     mov (1|M0)               r3.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        or (16|M0)    (ne)f1.1   null<1>:uw    r12.0<1;1,0>:uw   acc2.0<1;1,0>:uw {I@3}
(W)     add (1|M0)               r14.1<1>:ud   r3.0<0;1,0>:ud    r69.5<0;1,0>:ud  {I@2}
        mov (16|M0)              r74.0<1>:d    r69.4<0;1,0>:d                  
        mov (16|M0)              r72.0<1>:d    r69.5<0;1,0>:d                  
        mov (16|M0)              r62.0<1>:f    r15.0<0;1,0>:f                   {Compacted}
        mov (16|M0)              r66.0<1>:d    r14.1<0;1,0>:d                   {I@3}
(f1.1)  goto (16|M0)                         L2864                  L2864                
L2800:
(W)     mov (1|M0)               r69.7<1>:d    r69.6<0;1,0>:d                  
(W)     mov (1|M0)               r69.4<1>:d    r15.0<0;1,0>:d                  
(W)     mov (1|M0)               r69.5<1>:d    r14.1<0;1,0>:d                  
(W)     jmpi                                 L2480                                
L2864:
        join (16|M0)                         L7896                                
L2880:
(W)     mov (1|M0)               r2.0<1>:f     8.68805e-44:f                              
(W)     mov (1|M0)               r3.0<1>:hf    0.0:hf                             
        subb (8|M0)              r64.0<1>:ud   r2.0<0;1,0>:ud    r74.0<1;1,0>:ud  {AccWrEn,Compacted,A@2}
        add3 (8|M0)              r102.0<1>:ud  -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r72.0<1>:ud     {A@1}
        subb (8|M8)              r65.0<1>:ud   r2.0<0;1,0>:ud    r75.0<1;1,0>:ud  {AccWrEn}
        add3 (16|M0)             r112.0<1>:d   r56.0<1;0>:d      r64.0<1;0>:d      -173:w               {I@1}
        cmp (16|M0)   (gt)f1.1   null<1>:d     r112.0<1;1,0>:d   127:w               {I@1}
        add3 (8|M8)              r103.0<1>:ud  -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r73.0<1>:ud    
        add3 (16|M0)             r116.0<1>:d   r78.0<1;0>:d      r76.0<1;0>:d      r64.0<1>:d      
(f1.1)  goto (16|M0)                         L7832                  L7832                
L3032:
        cmp (16|M0)   (gt)f1.0   null<1>:d     r112.0<1;1,0>:d   -127:w              
(f1.0)  goto (16|M0)                         L5512                  L5512                
L3064:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r112.0<1;1,0>:ud  0xFFFFFF6B:ud             
(f1.1)  goto (16|M0)                         L5008                  L5008                
L3096:
(W)     mov (1|M0)               r2.0<1>:f     8.82818e-44:f                              
(W)     mov (1|M0)               r3.0<1>:hf    0.0:hf                              {I@7}
        subb (8|M0)              r24.0<1>:ud   r2.0<0;1,0>:ud    r74.0<1;1,0>:ud  {AccWrEn,Compacted,F@2}
        add3 (16|M0)             r26.0<1>:d    r56.0<1;0>:d      r64.0<1;0>:d      -23:w              
        add3 (8|M0)              r8.0<1>:ud    -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r72.0<1>:ud     {F@1}
        subb (8|M8)              r25.0<1>:ud   r2.0<0;1,0>:ud    r75.0<1;1,0>:ud  {AccWrEn}
        cmp (16|M0)   (gt)f1.1   null<1>:d     r24.0<1;1,0>:ud   r26.0<1;1,0>:ud  {I@1}
        add3 (8|M8)              r9.0<1>:ud    -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r73.0<1>:ud    
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r8.0<1;1,0>:d     0:w               {I@1}
(~f1.1) cmp (16|M0)   (gt)f1.1   null<1>:d     r8.0<1;1,0>:ud    0x0:uw             
(f1.1)  goto (16|M0)                         L3320                  L3320                
L3264:
        add3 (16|M0)             r2.0<1>:d     r116.0<1;0>:d     -r24.0<1;0>:d     -23:w              
        mov (16|M0)              r126.0<1>:d   0:w                              
        shl (16|M0)              r8.0<1>:d     r54.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
        goto (16|M0)                         L3320                  L4944                
L3320:
        join (16|M0)                         L4944                                
L3336:
        add3 (16|M0)             r16.0<1>:d    r24.0<1;0>:d      -r116.0<1;0>:d    23:w              
        cmp (16|M0)   (lt)f1.0   null<1>:d     r16.0<1;1,0>:d    2:w               {Compacted,I@1}
(f1.0)  goto (16|M0)                         L3480                  L3480                
L3376:
        cmp (16|M0)   (eq)f1.1   null<1>:d     r16.0<1;1,0>:d    2:w              
(~f1.1) goto (16|M0)                         L3480                  L3528                
L3408:
        shr (16|M0)              r110.0<1>:ud  r54.0<1;1,0>:ud   1:w              
        mov (16|M0)              r112.0<1>:d   0:w                              
        mov (16|M0)              r56.0<1>:d    0:w                              
        mov (16|M0)              r108.0<1>:f   r110.0<1;1,0>:f                  {Compacted,I@3}
        goto (16|M0)                         L3480                  L4416                
L3480:
        join (16|M0)                         L3528                                
L3496:
        cmp (16|M0)   (eq)f1.0   null<1>:d     r16.0<1;1,0>:d    1:w              
(f1.0)  goto (16|M0)                         L3528                  L4360                
L3528:
        join (16|M0)                         L4360                                
L3544:
        add3 (16|M0)             r2.0<1>:d     r24.0<1;0>:d      -r26.0<1;0>:d     -1:w              
        and (16|M0)   (ne)f1.1   r88.0<1>:d    r2.0<1;1,0>:d     63:w               {I@1}
(f1.1)  goto (16|M0)                         L3616                  L3616                
L3592:
        mov (16|M0)              r14.0<1>:f    r54.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L3616                  L3728                
L3616:
        join (16|M0)                         L3728                                
L3632:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r88.0<1;1,0>:ud   0x20:uw              {I@4}
(~f1.0) add (16|M0)              r2.0<1>:d     r88.0<1;1,0>:d    -32:w              
(~f1.0) shr (16|M0)              r110.0<1>:ud  r52.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.0)  add (16|M0)              r2.0<1>:d     -r88.0<1;1,0>:d   32:w               {Compacted}
(f1.0)  shr (16|M0)              r8.0<1>:ud    r54.0<1;1,0>:ud   r88.0<1;1,0>:d  
(f1.0)  shl (16|M0)              r2.0<1>:d     r52.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.0)  or (16|M0)               r110.0<1>:d   r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
        mov (16|M0)              r14.0<1>:f    r110.0<1;1,0>:f                  {Compacted,I@1}
L3728:
        join (16|M0)                         L4360                                
L3744:
        add3 (16|M0)             r28.0<1>:d    r24.0<1;0>:d      -r26.0<1;0>:d     -2:w              
        and (16|M0)   (ne)f1.1   r86.0<1>:d    r28.0<1;1,0>:d    63:w               {I@1}
(f1.1)  goto (16|M0)                         L3816                  L3816                
L3792:
        mov (16|M0)              r110.0<1>:f   r54.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L3816                  L3920                
L3816:
        join (16|M0)                         L3920                                
L3832:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r86.0<1;1,0>:ud   0x20:uw              {I@4}
(~f1.0) add (16|M0)              r2.0<1>:d     r86.0<1;1,0>:d    -32:w              
(~f1.0) shr (16|M0)              r110.0<1>:ud  r52.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.0)  add (16|M0)              r2.0<1>:d     -r86.0<1;1,0>:d   32:w               {Compacted}
(f1.0)  shr (16|M0)              r8.0<1>:ud    r54.0<1;1,0>:ud   r86.0<1;1,0>:d  
(f1.0)  shl (16|M0)              r2.0<1>:d     r52.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.0)  or (16|M0)               r110.0<1>:d   r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
L3920:
        join (16|M0)                         L4360                                
L3936:
        and (16|M0)   (ne)f1.1   r62.0<1>:d    r28.0<1;1,0>:d    63:w              
        and (16|M0)              r56.0<1>:d    r110.0<1;1,0>:d   1:w               {Compacted,I@3}
(f1.1)  goto (16|M0)                         L4024                  L4024                
L3976:
        mov (16|M0)              r66.0<1>:d    -1:w                              
        mov (16|M0)              r72.0<1>:d    -1:w                              
        goto (16|M0)                         L4024                  L4208                
L4024:
        join (16|M0)                         L4208                                
L4040:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r62.0<1;1,0>:ud   0x20:uw              {I@7}
(f1.0)  goto (16|M0)                         L4144                  L4144                
L4072:
        add (16|M0)              r2.0<1>:d     r62.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r6.8<1>:hf    -qnan(0x1FF):hf                             
        mov (16|M0)              r66.0<1>:d    0:w                              
        shl (16|M0)              r72.0<1>:d    r6.8<0;1,0>:w     r2.0<1;1,0>:d    {A@1}
        goto (16|M0)                         L4144                  L4208                
L4144:
        join (16|M0)                         L4208                                
L4160:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (16|M0)              r72.0<1>:d    -1:w                              
        shl (16|M0)              r66.0<1>:d    r2.0<0;1,0>:w     r62.0<1;1,0>:d   {F@1}
L4208:
        join (16|M0)                         L4360                                
L4224:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r66.0<1;0>:ud     r7.5<0;0>:ud      r54.0<1>:ud      {I@2} // (s0^s1)&s2
        cmp (16|M0)   (ne)f1.1   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
        bfn.0x60 (16|M0)         r8.0<1>:ud    r72.0<1;0>:ud     r7.5<0;0>:ud      r52.0<1>:ud      // (s0^s1)&s2
(~f1.1) cmp (16|M0)   (ne)f1.1   null<1>:d     r8.0<1;1,0>:d     0:w               {I@1}
(W)     mov (1|M0)               r6.8<1>:hf    -qnan(0x1FF):hf                             
        mov (16|M0)              r108.0<1>:f   r14.0<1;1,0>:f                   {Compacted}
(f1.1)  sel (16|M0)              r10.0<1>:d    r6.8<0;1,0>:w     0:w               {F@2}
        mov (16|M0)              r112.0<1>:d   -r10.0<1;1,0>:d                  {I@1}
        goto (16|M0)                         L4360                  L4416                
L4360:
        join (16|M0)                         L4416                                
L4376:
        mov (16|M0)              r112.0<1>:d   0:w                              
        mov (16|M0)              r56.0<1>:d    0:w                              
        mov (16|M0)              r108.0<1>:f   r54.0<1;1,0>:f                   {Compacted}
L4416:
        join (16|M0)                         L4944                                
L4432:
        and (16|M0)   (ne)f1.1   r84.0<1>:d    r16.0<1;1,0>:d    63:w              
(f1.1)  goto (16|M0)                         L4488                  L4488                
L4464:
        mov (16|M0)              r110.0<1>:f   r54.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L4488                  L4592                
L4488:
        join (16|M0)                         L4592                                
L4504:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r84.0<1;1,0>:ud   0x20:uw              {I@4}
(~f1.0) add (16|M0)              r2.0<1>:d     r84.0<1;1,0>:d    -32:w              
(~f1.0) shr (16|M0)              r110.0<1>:ud  r52.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.0)  add (16|M0)              r2.0<1>:d     -r84.0<1;1,0>:d   32:w               {Compacted}
(f1.0)  shr (16|M0)              r8.0<1>:ud    r54.0<1;1,0>:ud   r84.0<1;1,0>:d  
(f1.0)  shl (16|M0)              r2.0<1>:d     r52.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.0)  or (16|M0)               r110.0<1>:d   r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
L4592:
        join (16|M0)                         L4944                                
L4608:
        shl (16|M0)              r2.0<1>:d     r108.0<1;1,0>:d   2:w               {Compacted}
        shl (16|M0)              r8.0<1>:d     r56.0<1;1,0>:d    1:w               {Compacted}
        and (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     4:w               {Compacted,I@2}
        bfn.0xFE (16|M0)         r112.0<1>:ud  r2.0<1;0>:ud      r8.0<1;0>:ud      r112.0<1>:ud     {I@1} // s0|s1|s2
        cmp (16|M0)   (eq)f1.1   null<1>:d     r112.0<1;1,0>:d   0:w               {I@1}
(~f1.1) goto (16|M0)                         L4712                  L4712                
L4680:
        mov (16|M0)              r116.0<1>:d   0:w                              
        goto (16|M0)                         L4712                  L4872                
L4712:
        join (16|M0)                         L4872                                
L4728:
        cmp (16|M0)   (gt)f1.0   null<1>:d     r112.0<1;1,0>:ud  0x4:uw             
(~f1.0) goto (16|M0)                         L4792                  L4792                
L4760:
        mov (16|M0)              r116.0<1>:d   1:w                              
        goto (16|M0)                         L4792                  L4872                
L4792:
        join (16|M0)                         L4872                                
L4808:
        and (16|M0)   (ne)f1.0   null<1>:d     r110.0<1;1,0>:d   1:w              
(W)     mov (1|M0)               r2.0<1>:hf    0x1:hf                             
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r112.0<1;1,0>:d   4:w              
(f1.0)  sel (16|M0)              r116.0<1>:d   r2.0<0;1,0>:w     0:w               {F@1}
L4872:
        join (16|M0)                         L4944                                
L4888:
        add (16|M0)              r2.0<1>:d     r116.0<1;1,0>:d   r110.0<1;1,0>:d  {Compacted,I@2}
        cmp (16|M0)   (gt)f1.1   null<1>:d     r2.0<1;1,0>:ud    0x7FFFFF:ud              {I@1}
(W)     mov (1|M0)               r6.4<1>:f     0x800000:f                               {Compacted}
(~f1.1) sel (16|M0)              r8.0<1>:d     r2.0<1;1,0>:d     0:w              
(f1.1)  sel (16|M0)              r126.0<1>:d   r6.4<0;1,0>:d     0:w               {Compacted,F@1}
L4944:
        join (16|M0)                         L5008                                
L4960:
        and (16|M0)              r2.0<1>:d     r58.0<1;1,0>:d    -2147483648:d              
        bfn.0xFE (16|M0)         r62.0<1>:ud   r2.0<1;0>:ud      r126.0<1;0>:ud    r8.0<1>:ud       {I@1} // s0|s1|s2
        goto (16|M0)                         L5008                  L8056                
L5008:
        join (16|M0)                         L5512                                
L5024:
        and (16|M0)   (ne)f1.1   r12.0<1>:d    r64.0<1;1,0>:d    63:w              
(f1.1)  goto (16|M0)                         L5104                  L5104                
L5056:
        mov (16|M0)              r24.0<1>:d    -1:w                              
        mov (16|M0)              r30.0<1>:d    -1:w                              
        goto (16|M0)                         L5104                  L5288                
L5104:
        join (16|M0)                         L5288                                
L5120:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r12.0<1;1,0>:ud   0x20:uw              {I@6}
(f1.0)  goto (16|M0)                         L5224                  L5224                
L5152:
        add (16|M0)              r2.0<1>:d     r12.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r6.8<1>:hf    -qnan(0x1FF):hf                             
        mov (16|M0)              r24.0<1>:d    0:w                              
        shl (16|M0)              r30.0<1>:d    r6.8<0;1,0>:w     r2.0<1;1,0>:d    {A@1}
        goto (16|M0)                         L5224                  L5288                
L5224:
        join (16|M0)                         L5288                                
L5240:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (16|M0)              r30.0<1>:d    -1:w                              
        shl (16|M0)              r24.0<1>:d    r2.0<0;1,0>:w     r12.0<1;1,0>:d   {F@1}
L5288:
        join (16|M0)                         L5512                                
L5304:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r24.0<1;0>:ud     r7.5<0;0>:ud      r54.0<1>:ud      {I@2} // (s0^s1)&s2
        cmp (16|M0)   (ne)f1.0   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
        bfn.0x60 (16|M0)         r8.0<1>:ud    r30.0<1;0>:ud     r7.5<0;0>:ud      r52.0<1>:ud      // (s0^s1)&s2
        cmp (16|M0)   (gt)f1.1   null<1>:d     r58.0<1;1,0>:d    -1:w              
(~f1.0) cmp (16|M0)   (ne)f1.0   null<1>:d     r8.0<1;1,0>:d     0:w               {I@2}
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r112.0<1;1,0>:d   -150:w              
(f1.1)  goto (16|M0)                         L5456                  L5456                
L5416:
(W)     mov (1|M0)               r2.0<1>:ud    0x80000001:ud                             
(f1.0)  sel (16|M0)              r62.0<1>:f    r2.0<0;1,0>:f     -0.0:f               {Compacted,I@1}
        goto (16|M0)                         L5456                  L8056                
L5456:
        join (16|M0)                         L5512                                
L5472:
(W)     mov (1|M0)               r2.0<1>:ud    0x1:ud                              {F@1}
(f1.0)  sel (16|M0)              r62.0<1>:f    r2.0<0;1,0>:f     0.0:f               {Compacted,I@1}
        goto (16|M0)                         L5512                  L8056                
L5512:
        join (16|M0)                         L7832                                
L5528:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r64.0<1;1,0>:ud   0x18:uw             
        add3 (16|M0)             r70.0<1>:d    r56.0<1;0>:d      r64.0<1;0>:d      -46:w              
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r102.0<1;1,0>:d   0:w              
(f1.1)  goto (16|M0)                         L7520                  L7520                
L5592:
        shl (16|M0)              r2.0<1>:d     r62.0<1;1,0>:d    1:w               {Compacted,F@1}
        shr (16|M0)              r8.0<1>:ud    r62.0<1;1,0>:ud   31:w              
        shl (16|M0)              r10.0<1>:d    r66.0<1;1,0>:d    1:w               {Compacted}
        cmp (16|M0)   (lt)f1.0   null<1>:d     r2.0<1;1,0>:ud    0x4E:uw              {I@3}
        or (16|M0)               r10.0<1>:d    r10.0<1;1,0>:d    r8.0<1;1,0>:d    {Compacted,I@2}
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r10.0<1;1,0>:d    0:w               {I@1}
(~f1.0) cmp (16|M0)   (lt)f1.0   null<1>:d     r10.0<1;1,0>:d    0:w              
(f1.0)  goto (16|M0)                         L5824                  L5824                
L5696:
        cmp (16|M0)   (eq)f1.0   null<1>:d     r62.0<1;1,0>:d    39:w              
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r66.0<1;1,0>:d    0:w              
(~f1.0) goto (16|M0)                         L5824                  L5888                
L5744:
        shr (16|M0)              r110.0<1>:ud  r54.0<1;1,0>:ud   1:w              
        mov (16|M0)              r114.0<1>:d   0:w                              
        mov (16|M0)              r100.0<1>:d   0:w                              
        mov (16|M0)              r52.0<1>:f    r110.0<1;1,0>:f                  {Compacted,I@3}
        mov (16|M0)              r110.0<1>:f   r54.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L5824                  L6992                
L5824:
        join (16|M0)                         L5888                                
L5840:
        cmp (16|M0)   (eq)f1.1   null<1>:d     r62.0<1;1,0>:d    38:w              
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r66.0<1;1,0>:d    0:w              
(f1.1)  goto (16|M0)                         L5888                  L6904                
L5888:
        join (16|M0)                         L6904                                
L5904:
        add (16|M0)              r2.0<1>:d     -r62.0<1;1,0>:d   39:w               {Compacted}
        and (16|M0)   (ne)f1.0   r100.0<1>:d   r2.0<1;1,0>:d     63:w               {I@1}
        add (16|M0)              r98.0<1>:d    -r62.0<1;1,0>:d   40:w               {Compacted}
(f1.0)  goto (16|M0)                         L5976                  L5976                
L5952:
        mov (16|M0)              r96.0<1>:f    r54.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L5976                  L6088                
L5976:
        join (16|M0)                         L6088                                
L5992:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r100.0<1;1,0>:ud  0x20:uw              {I@5}
(~f1.1) add (16|M0)              r2.0<1>:d     r100.0<1;1,0>:d   -32:w              
(~f1.1) shr (16|M0)              r110.0<1>:ud  r52.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.1)  add (16|M0)              r2.0<1>:d     -r100.0<1;1,0>:d  32:w               {Compacted}
(f1.1)  shr (16|M0)              r8.0<1>:ud    r54.0<1;1,0>:ud   r100.0<1;1,0>:d 
(f1.1)  shl (16|M0)              r2.0<1>:d     r52.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.1)  or (16|M0)               r110.0<1>:d   r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
        mov (16|M0)              r96.0<1>:f    r110.0<1;1,0>:f                  {Compacted,I@1}
L6088:
        join (16|M0)                         L6904                                
L6104:
        add (16|M0)              r28.0<1>:d    -r62.0<1;1,0>:d   38:w               {Compacted}
        and (16|M0)   (ne)f1.0   r104.0<1>:d   r28.0<1;1,0>:d    63:w               {I@1}
(f1.0)  goto (16|M0)                         L6168                  L6168                
L6144:
        mov (16|M0)              r110.0<1>:f   r54.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L6168                  L6272                
L6168:
        join (16|M0)                         L6272                                
L6184:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r104.0<1;1,0>:ud  0x20:uw              {I@4}
(~f1.1) add (16|M0)              r2.0<1>:d     r104.0<1;1,0>:d   -32:w              
(~f1.1) shr (16|M0)              r110.0<1>:ud  r52.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.1)  add (16|M0)              r2.0<1>:d     -r104.0<1;1,0>:d  32:w               {Compacted}
(f1.1)  shr (16|M0)              r8.0<1>:ud    r54.0<1;1,0>:ud   r104.0<1;1,0>:d 
(f1.1)  shl (16|M0)              r2.0<1>:d     r52.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.1)  or (16|M0)               r110.0<1>:d   r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
L6272:
        join (16|M0)                         L6904                                
L6288:
        and (16|M0)   (ne)f1.0   r76.0<1>:d    r28.0<1;1,0>:d    63:w              
        and (16|M0)              r100.0<1>:d   r110.0<1;1,0>:d   1:w               {Compacted,I@3}
(f1.0)  goto (16|M0)                         L6376                  L6376                
L6328:
        mov (16|M0)              r102.0<1>:d   -1:w                              
        mov (16|M0)              r106.0<1>:d   -1:w                              
        goto (16|M0)                         L6376                  L6560                
L6376:
        join (16|M0)                         L6560                                
L6392:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r76.0<1;1,0>:ud   0x20:uw              {I@7}
(f1.1)  goto (16|M0)                         L6496                  L6496                
L6424:
        add (16|M0)              r2.0<1>:d     r76.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r6.8<1>:hf    -qnan(0x1FF):hf                             
        mov (16|M0)              r102.0<1>:d   0:w                              
        shl (16|M0)              r106.0<1>:d   r6.8<0;1,0>:w     r2.0<1;1,0>:d    {A@1}
        goto (16|M0)                         L6496                  L6560                
L6496:
        join (16|M0)                         L6560                                
L6512:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (16|M0)              r106.0<1>:d   -1:w                              
        shl (16|M0)              r102.0<1>:d   r2.0<0;1,0>:w     r76.0<1;1,0>:d   {F@1}
L6560:
        join (16|M0)                         L6904                                
L6576:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r102.0<1;0>:ud    r7.5<0;0>:ud      r54.0<1>:ud      {I@2} // (s0^s1)&s2
        cmp (16|M0)   (ne)f1.0   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
        bfn.0x60 (16|M0)         r8.0<1>:ud    r106.0<1;0>:ud    r7.5<0;0>:ud      r52.0<1>:ud      // (s0^s1)&s2
(~f1.0) cmp (16|M0)   (ne)f1.0   null<1>:d     r8.0<1;1,0>:d     0:w               {I@1}
(W)     mov (1|M0)               r6.8<1>:hf    -qnan(0x1FF):hf                             
(f1.0)  sel (16|M0)              r10.0<1>:d    r6.8<0;1,0>:w     0:w               {F@1}
        and (16|M0)   (ne)f1.0   r102.0<1>:d   r98.0<1;1,0>:d    63:w              
        mov (16|M0)              r114.0<1>:d   -r10.0<1;1,0>:d                  {I@2}
(f1.0)  goto (16|M0)                         L6744                  L6744                
L6720:
        mov (16|M0)              r110.0<1>:f   r54.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L6744                  L6848                
L6744:
        join (16|M0)                         L6848                                
L6760:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r102.0<1;1,0>:ud  0x20:uw              {I@5}
(~f1.1) add (16|M0)              r2.0<1>:d     r102.0<1;1,0>:d   -32:w              
(~f1.1) shr (16|M0)              r110.0<1>:ud  r52.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.1)  add (16|M0)              r2.0<1>:d     -r102.0<1;1,0>:d  32:w               {Compacted}
(f1.1)  shr (16|M0)              r8.0<1>:ud    r54.0<1;1,0>:ud   r102.0<1;1,0>:d 
(f1.1)  shl (16|M0)              r2.0<1>:d     r52.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.1)  or (16|M0)               r110.0<1>:d   r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
L6848:
        join (16|M0)                         L6904                                
L6864:
        mov (16|M0)              r52.0<1>:f    r110.0<1;1,0>:f                  {Compacted,I@2}
        mov (16|M0)              r110.0<1>:d   r96.0<1;1,0>:d                   {F@1}
        goto (16|M0)                         L6904                  L6992                
L6904:
        join (16|M0)                         L6992                                
L6920:
        shr (16|M0)              r110.0<1>:ud  r54.0<1;1,0>:ud   2:w              
        mov (16|M0)              r114.0<1>:d   0:w                              
        mov (16|M0)              r100.0<1>:d   0:w                              
        mov (16|M0)              r52.0<1>:f    r110.0<1;1,0>:f                  {Compacted,I@3}
        shr (16|M0)              r110.0<1>:ud  r54.0<1;1,0>:ud   1:w               {F@1}
L6992:
        join (16|M0)                         L7520                                
L7008:
        shl (16|M0)              r2.0<1>:d     r110.0<1;1,0>:d   2:w               {Compacted,I@2}
        shl (16|M0)              r8.0<1>:d     r100.0<1;1,0>:d   1:w               {Compacted}
        and (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     4:w               {Compacted,I@2}
        bfn.0xFE (16|M0)         r22.0<1>:ud   r2.0<1;0>:ud      r8.0<1;0>:ud      r114.0<1>:ud     {I@1} // s0|s1|s2
        cmp (16|M0)   (eq)f1.0   null<1>:d     r22.0<1;1,0>:d    0:w               {I@1}
        and (16|M0)              r54.0<1>:d    r52.0<1;1,0>:d    8388607:d              
(~f1.0) goto (16|M0)                         L7128                  L7128                
L7096:
        mov (16|M0)              r10.0<1>:d    0:w                              
        goto (16|M0)                         L7128                  L7288                
L7128:
        join (16|M0)                         L7288                                
L7144:
        cmp (16|M0)   (gt)f1.1   null<1>:d     r22.0<1;1,0>:ud   0x4:uw             
(~f1.1) goto (16|M0)                         L7208                  L7208                
L7176:
        mov (16|M0)              r10.0<1>:d    1:w                              
        goto (16|M0)                         L7208                  L7288                
L7208:
        join (16|M0)                         L7288                                
L7224:
        and (16|M0)   (ne)f1.1   null<1>:d     r52.0<1;1,0>:d    1:w              
(W)     mov (1|M0)               r2.0<1>:hf    0x1:hf                             
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r22.0<1;1,0>:d    4:w              
(f1.1)  sel (16|M0)              r10.0<1>:d    r2.0<0;1,0>:w     0:w               {F@1}
L7288:
        join (16|M0)                         L7520                                
L7304:
        add (16|M0)              r16.0<1>:d    r54.0<1;1,0>:d    r10.0<1;1,0>:d   {Compacted,I@2}
        cmp (16|M0)   (gt)f1.1   null<1>:d     r16.0<1;1,0>:ud   0x7FFFFF:ud              {I@1}
        add3 (16|M0)             r2.0<1>:d     r56.0<1;0>:d      r64.0<1;0>:d      -45:w              
(f1.1)  sel (16|M0)              r14.0<1>:d    r2.0<1;1,0>:d     r70.0<1;1,0>:d   {Compacted,I@1}
        cmp (16|M0)   (eq)f1.0   null<1>:d     r14.0<1;1,0>:d    255:w               {I@1}
(f1.0)  goto (16|M0)                         L7456                  L7456                
L7384:
(~f1.1) sel (16|M0)              r2.0<1>:d     r16.0<1;1,0>:d    0:w              
        and (16|M0)              r8.0<1>:d     r58.0<1;1,0>:d    -2147483648:d              
        shl (16|M0)              r10.0<1>:d    r14.0<1;1,0>:d    23:w               {Compacted}
        bfn.0xFE (16|M0)         r62.0<1>:ud   r8.0<1;0>:ud      r10.0<1;0>:ud     r2.0<1>:ud       {I@1} // s0|s1|s2
        goto (16|M0)                         L7456                  L8056                
L7456:
        join (16|M0)                         L7520                                
L7472:
        cmp (16|M0)   (gt)f1.1   null<1>:d     r58.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r2.0<1>:f     inf:f                               {Compacted,I@4}
(f1.1)  sel (16|M0)              r62.0<1>:f    r2.0<0;1,0>:f     -inf:f               {Compacted,F@1}
        goto (16|M0)                         L7520                  L8056                
L7520:
        join (16|M0)                         L7832                                
L7536:
        and (16|M0)   (ne)f1.1   r124.0<1>:d   r64.0<1;1,0>:d    63:w               {F@1}
(f1.1)  goto (16|M0)                         L7600                  L7600                
L7568:
        mov (16|M0)              r124.0<1>:d   -1:w                              
        goto (16|M0)                         L7600                  L7728                
L7600:
        join (16|M0)                         L7728                                
L7616:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r124.0<1;1,0>:ud  0x20:uw              {I@3}
(f1.0)  goto (16|M0)                         L7680                  L7680                
L7648:
        mov (16|M0)              r124.0<1>:d   0:w                              
        goto (16|M0)                         L7680                  L7728                
L7680:
        join (16|M0)                         L7728                                
L7696:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                             
        shl (16|M0)              r124.0<1>:d   r2.0<0;1,0>:w     r124.0<1;1,0>:d  {A@1}
L7728:
        join (16|M0)                         L7832                                
L7744:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r124.0<1;0>:ud    r7.5<0;0>:ud      r54.0<1>:ud      {I@2} // (s0^s1)&s2
        add (16|M0)              r8.0<1>:d     -r64.0<1;1,0>:d   23:w               {Compacted}
        and (16|M0)              r10.0<1>:d    r58.0<1;1,0>:d    -2147483648:d              
        shl (16|M0)              r12.0<1>:d    r70.0<1;1,0>:d    23:w               {Compacted}
        shl (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     r8.0<1;1,0>:d    {Compacted,I@3}
        bfn.0xFE (16|M0)         r62.0<1>:ud   r10.0<1;0>:ud     r12.0<1;0>:ud     r2.0<1>:ud       {I@1} // s0|s1|s2
        goto (16|M0)                         L7832                  L8056                
L7832:
        join (16|M0)                         L7896                                
L7848:
        cmp (16|M0)   (gt)f1.0   null<1>:d     r58.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r2.0<1>:f     inf:f                               {Compacted,I@4}
(f1.0)  sel (16|M0)              r62.0<1>:f    r2.0<0;1,0>:f     -inf:f               {Compacted,F@1}
        goto (16|M0)                         L7896                  L8056                
L7896:
        join (16|M0)                         L7960                                
L7912:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r58.0<1;1,0>:d    0:w              
(W)     mov (1|M0)               r2.0<1>:f     -0.0:f                               {Compacted}
(f1.1)  sel (16|M0)              r62.0<1>:f    r2.0<0;1,0>:f     0.0:f               {Compacted,F@1}
        goto (16|M0)                         L7960                  L8056                
L7960:
        join (16|M0)                         L8024                                
L7976:
        cmp (16|M0)   (gt)f1.0   null<1>:d     r58.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r2.0<1>:f     inf:f                               {Compacted}
(f1.0)  sel (16|M0)              r62.0<1>:f    r2.0<0;1,0>:f     -inf:f               {Compacted,F@1}
        goto (16|M0)                         L8024                  L8056                
L8024:
        join (16|M0)                         L8056                                
L8040:
        bfn.0xF8 (16|M0)         r62.0<1>:ud   r58.0<1;0>:ud     r7.7<0;0>:ud      r7.6<0>:ud       {F@1} // s0&s1|s2
L8056:
        join (16|M0)                         L16000                                
L8072:
        rnde (16|M0)             r20.0<1>:f    r62.0<1;1,0>:f                   {Compacted,I@2}
        shr (16|M0)              r22.0<1>:ud   r20.0<1;1,0>:ud   23:w               {F@1}
        and (16|M0)   (ne)f1.0   r96.0<1>:d    r20.0<1;1,0>:d    8388607:d              
        and (16|M0)              r74.0<1>:d    r22.0<1;1,0>:d    255:w               {Compacted,I@2}
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r74.0<1;1,0>:d    255:w               {I@1}
(~f1.0) goto (16|M0)                         L8184                  L8184                
L8152:
        mov (16|M0)              r60.0<1>:ud   0x7FC00000:ud                             
        goto (16|M0)                         L8184                  L14216                
L8184:
        join (16|M0)                         L14216                                
L8200:
        cmp (16|M0)   (eq)f1.1   null<1>:d     r96.0<1;1,0>:d    0:w              
        add (16|M0)              r2.0<1>:d     r60.0<1;1,0>:d    -25165824:d               {I@4}
        shr (16|M0)              r18.0<1>:ud   r2.0<1;1,0>:ud    23:w               {I@1}
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r74.0<1;1,0>:d    255:w              
        and (16|M0)              r94.0<1>:d    r18.0<1;1,0>:d    255:w               {Compacted,I@2}
(~f1.1) cmp (16|M0)   (eq)f1.1   null<1>:d     r94.0<1;1,0>:d    255:w               {I@1}
        xor (16|M0)              r92.0<1>:d    r2.0<1;1,0>:d     r20.0<1;1,0>:d   {Compacted}
(f1.1)  goto (16|M0)                         L14184                  L14184                
L8312:
        cmp (16|M0)   (eq)f1.1   null<1>:d     r94.0<1;1,0>:d    0:w              
        or (16|M0)               r2.0<1>:d     r74.0<1;1,0>:d    r96.0<1;1,0>:d   {Compacted}
(~f1.1) cmp (16|M0)   (eq)f1.1   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
(~f1.1) goto (16|M0)                         L8400                  L8400                
L8368:
        mov (16|M0)              r60.0<1>:ud   0x0:ud                             
        goto (16|M0)                         L8400                  L14216                
L8400:
        join (16|M0)                         L14184                                
L8416:
        cmp (16|M0)   (eq)f1.0   null<1>:d     r74.0<1;1,0>:d    0:w              
        add (16|M0)              r90.0<1>:d    r74.0<1;1,0>:d    -127:w               {Compacted}
(f1.0)  mov (16|M0)              r90.0<1>:d    -126:w                              
        add (16|M0)              r88.0<1>:d    r94.0<1;1,0>:d    r90.0<1;1,0>:d   {Compacted,I@1}
        cmp (16|M0)   (gt)f1.1   null<1>:d     r88.0<1;1,0>:d    254:w               {I@1}
(f1.1)  goto (16|M0)                         L14120                  L14120                
L8496:
        or (16|M0)    (eq)f1.1   null<4>:b     r22.0<1;1,0>:d    r18.0<1;1,0>:d  
(f1.1)  goto (16|M0)                         L14056                  L14056                
L8528:
(W)     mov (1|M0)               r2.0<1>:hf    0.0:hf                             
(W)     mov (1|M0)               r14.0<1>:d    0:w                              
(f1.0)  sel (16|M0)              r8.0<1>:d     r2.0<0;1,0>:w     8388608:d               {F@1}
        or (16|M0)               r8.0<1>:d     r8.0<1;1,0>:d     r96.0<1;1,0>:d   {Compacted,I@1}
        shl (16|M0)              r86.0<1>:d    r8.0<1;1,0>:d     23:w               {Compacted,I@1}
        shr (16|M0)              r84.0<1>:ud   r8.0<1;1,0>:ud    9:w              
(W)     mov (1|M0)               r69.7<1>:f    -0.0:f                               {Compacted}
(W)     mov (2|M0)               r69.4<1>:d    0:w                              
L8632:
(W)     shl (1|M0)               r2.0<1>:d     r69.7<0;1,0>:d    31:w               {Compacted,F@1}
(W)     shr (1|M0)               r2.1<1>:ud    r14.0<0;1,0>:ud   1:w              
(W)     cmp (16|M0)   (gt)f1.0   null<1>:d     r69.4<0;1,0>:ud   0x3E:uw              {I@3}
(W)     or (1|M0)                r14.0<1>:d    r2.1<0;1,0>:d     r2.0<0;1,0>:d    {Compacted,I@2}
        bfn.0xE0 (16|M0)         r8.0<1>:ud    r2.1<0;0>:ud      r2.0<0;0>:ud      r86.0<1>:ud      // (s0|s1)&s2
(W)     shr (1|M0)               r69.6<1>:ud   r69.7<0;1,0>:ud   1:w              
(W&f1.0) cmp (16|M0)  (eq)f1.0   null<1>:d     r69.5<0;1,0>:d    0:w              
        cmp (16|M0)   (eq)f1.1   null<1>:d     r8.0<1;1,0>:d     r14.0<0;1,0>:d   {I@3}
        and (16|M0)              r10.0<1>:d    r69.6<0;1,0>:d    r84.0<1;1,0>:d   {Compacted,I@3}
(W&~f1.0) cmp (16|M0) (gt)f1.0   null<1>:d     r69.5<0;1,0>:ud   0x0:uw             
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r10.0<1;1,0>:d    r69.6<0;1,0>:d   {I@2}
(W)     mov (1|M0)               r6.8<1>:hf    0x1:hf                             
(W)     addc (1|M0)              r15.0<1>:ud   r69.4<0;1,0>:ud   0x1:ud              {AccWrEn}
(f1.0)  sel (16|M0)              r12.0<1>:uw   r6.8<0;1,0>:uw    0x0:uw              {Compacted,F@1}
(f1.1)  sel (16|M0)              acc2.0<1>:uw  r6.8<0;1,0>:uw    0x0:uw             
(W)     mov (1|M0)               r3.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        or (16|M0)    (ne)f1.0   null<1>:uw    r12.0<1;1,0>:uw   acc2.0<1;1,0>:uw {I@3}
(W)     add (1|M0)               r14.1<1>:ud   r3.0<0;1,0>:ud    r69.5<0;1,0>:ud  {I@2}
        mov (16|M0)              r108.0<1>:d   r69.4<0;1,0>:d                  
        mov (16|M0)              r106.0<1>:d   r69.5<0;1,0>:d                  
        mov (16|M0)              r82.0<1>:f    r15.0<0;1,0>:f                   {Compacted}
        mov (16|M0)              r80.0<1>:d    r14.1<0;1,0>:d                   {I@3}
(f1.0)  goto (16|M0)                         L9016                  L9016                
L8952:
(W)     mov (1|M0)               r69.7<1>:d    r69.6<0;1,0>:d                  
(W)     mov (1|M0)               r69.4<1>:d    r15.0<0;1,0>:d                  
(W)     mov (1|M0)               r69.5<1>:d    r14.1<0;1,0>:d                  
(W)     jmpi                                 L8632                                
L9016:
        join (16|M0)                         L14056                                
L9032:
(W)     mov (1|M0)               r2.0<1>:f     8.68805e-44:f                              
(W)     mov (1|M0)               r3.0<1>:hf    0.0:hf                             
        subb (8|M0)              r104.0<1>:ud  r2.0<0;1,0>:ud    r108.0<1;1,0>:ud {AccWrEn,Compacted,A@2}
        add3 (8|M0)              r126.0<1>:ud  -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r106.0<1>:ud    {A@1}
        subb (8|M8)              r105.0<1>:ud  r2.0<0;1,0>:ud    r109.0<1;1,0>:ud {AccWrEn}
        add3 (16|M0)             r12.0<1>:d    r88.0<1;0>:d      r104.0<1;0>:d     -173:w               {I@1}
        cmp (16|M0)   (gt)f1.0   null<1>:d     r12.0<1;1,0>:d    127:w               {I@1}
        add3 (8|M8)              r127.0<1>:ud  -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r107.0<1>:ud   
        add3 (16|M0)             r20.0<1>:d    r94.0<1;0>:d      r90.0<1;0>:d      r104.0<1>:d     
(f1.0)  goto (16|M0)                         L13992                  L13992                
L9184:
        cmp (16|M0)   (gt)f1.1   null<1>:d     r12.0<1;1,0>:d    -127:w              
(f1.1)  goto (16|M0)                         L11672                  L11672                
L9216:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r12.0<1;1,0>:ud   0xFFFFFF6B:ud             
(f1.0)  goto (16|M0)                         L11168                  L11168                
L9248:
(W)     mov (1|M0)               r2.0<1>:f     8.82818e-44:f                              
(W)     mov (1|M0)               r3.0<1>:hf    0.0:hf                              {I@7}
        subb (8|M0)              r72.0<1>:ud   r2.0<0;1,0>:ud    r108.0<1;1,0>:ud {AccWrEn,Compacted,F@2}
        add3 (16|M0)             r110.0<1>:d   r88.0<1;0>:d      r104.0<1;0>:d     -23:w              
        add3 (8|M0)              r8.0<1>:ud    -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r106.0<1>:ud    {F@1}
        subb (8|M8)              r73.0<1>:ud   r2.0<0;1,0>:ud    r109.0<1;1,0>:ud {AccWrEn}
        cmp (16|M0)   (gt)f1.0   null<1>:d     r72.0<1;1,0>:ud   r110.0<1;1,0>:ud {I@1}
        add3 (8|M8)              r9.0<1>:ud    -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r107.0<1>:ud   
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r8.0<1;1,0>:d     0:w               {I@1}
(~f1.0) cmp (16|M0)   (gt)f1.0   null<1>:d     r8.0<1;1,0>:ud    0x0:uw             
(f1.0)  goto (16|M0)                         L9472                  L9472                
L9416:
        add3 (16|M0)             r2.0<1>:d     r20.0<1;0>:d      -r72.0<1;0>:d     -23:w              
        mov (16|M0)              r118.0<1>:d   0:w                              
        shl (16|M0)              r120.0<1>:d   r86.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
        goto (16|M0)                         L9472                  L11104                
L9472:
        join (16|M0)                         L11104                                
L9488:
        add3 (16|M0)             r22.0<1>:d    r72.0<1;0>:d      -r20.0<1;0>:d     23:w              
        cmp (16|M0)   (lt)f1.1   null<1>:d     r22.0<1;1,0>:d    2:w               {I@1}
(f1.1)  goto (16|M0)                         L9640                  L9640                
L9536:
        cmp (16|M0)   (eq)f1.0   null<1>:d     r22.0<1;1,0>:d    2:w              
(~f1.0) goto (16|M0)                         L9640                  L9688                
L9568:
        shr (16|M0)              r10.0<1>:ud   r86.0<1;1,0>:ud   1:w              
        mov (16|M0)              r104.0<1>:d   0:w                              
        mov (16|M0)              r54.0<1>:d    0:w                              
        mov (16|M0)              r88.0<1>:f    r10.0<1;1,0>:f                   {Compacted,I@3}
        goto (16|M0)                         L9640                  L10576                
L9640:
        join (16|M0)                         L9688                                
L9656:
        cmp (16|M0)   (eq)f1.1   null<1>:d     r22.0<1;1,0>:d    1:w              
(f1.1)  goto (16|M0)                         L9688                  L10520                
L9688:
        join (16|M0)                         L10520                                
L9704:
        add3 (16|M0)             r2.0<1>:d     r72.0<1;0>:d      -r110.0<1;0>:d    -1:w              
        and (16|M0)   (ne)f1.0   r82.0<1>:d    r2.0<1;1,0>:d     63:w               {I@1}
(f1.0)  goto (16|M0)                         L9776                  L9776                
L9752:
        mov (16|M0)              r30.0<1>:f    r86.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L9776                  L9888                
L9776:
        join (16|M0)                         L9888                                
L9792:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r82.0<1;1,0>:ud   0x20:uw              {I@4}
(~f1.1) add (16|M0)              r2.0<1>:d     r82.0<1;1,0>:d    -32:w              
(~f1.1) shr (16|M0)              r10.0<1>:ud   r84.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.1)  add (16|M0)              r2.0<1>:d     -r82.0<1;1,0>:d   32:w               {Compacted}
(f1.1)  shr (16|M0)              r8.0<1>:ud    r86.0<1;1,0>:ud   r82.0<1;1,0>:d  
(f1.1)  shl (16|M0)              r2.0<1>:d     r84.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.1)  or (16|M0)               r10.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
        mov (16|M0)              r30.0<1>:f    r10.0<1;1,0>:f                   {Compacted,I@1}
L9888:
        join (16|M0)                         L10520                                
L9904:
        add3 (16|M0)             r26.0<1>:d    r72.0<1;0>:d      -r110.0<1;0>:d    -2:w              
        and (16|M0)   (ne)f1.0   r80.0<1>:d    r26.0<1;1,0>:d    63:w               {I@1}
(f1.0)  goto (16|M0)                         L9976                  L9976                
L9952:
        mov (16|M0)              r10.0<1>:f    r86.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L9976                  L10080                
L9976:
        join (16|M0)                         L10080                                
L9992:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r80.0<1;1,0>:ud   0x20:uw              {I@4}
(~f1.1) add (16|M0)              r2.0<1>:d     r80.0<1;1,0>:d    -32:w              
(~f1.1) shr (16|M0)              r10.0<1>:ud   r84.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.1)  add (16|M0)              r2.0<1>:d     -r80.0<1;1,0>:d   32:w               {Compacted}
(f1.1)  shr (16|M0)              r8.0<1>:ud    r86.0<1;1,0>:ud   r80.0<1;1,0>:d  
(f1.1)  shl (16|M0)              r2.0<1>:d     r84.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.1)  or (16|M0)               r10.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
L10080:
        join (16|M0)                         L10520                                
L10096:
        and (16|M0)   (ne)f1.0   r18.0<1>:d    r26.0<1;1,0>:d    63:w              
        and (16|M0)              r54.0<1>:d    r10.0<1;1,0>:d    1:w               {Compacted,I@3}
(f1.0)  goto (16|M0)                         L10184                  L10184                
L10136:
        mov (16|M0)              r28.0<1>:d    -1:w                              
        mov (16|M0)              r64.0<1>:d    -1:w                              
        goto (16|M0)                         L10184                  L10368                
L10184:
        join (16|M0)                         L10368                                
L10200:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r18.0<1;1,0>:ud   0x20:uw              {I@7}
(f1.1)  goto (16|M0)                         L10304                  L10304                
L10232:
        add (16|M0)              r2.0<1>:d     r18.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r6.8<1>:hf    -qnan(0x1FF):hf                             
        mov (16|M0)              r28.0<1>:d    0:w                              
        shl (16|M0)              r64.0<1>:d    r6.8<0;1,0>:w     r2.0<1;1,0>:d    {A@1}
        goto (16|M0)                         L10304                  L10368                
L10304:
        join (16|M0)                         L10368                                
L10320:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (16|M0)              r64.0<1>:d    -1:w                              
        shl (16|M0)              r28.0<1>:d    r2.0<0;1,0>:w     r18.0<1;1,0>:d   {F@1}
L10368:
        join (16|M0)                         L10520                                
L10384:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r28.0<1;0>:ud     r7.5<0;0>:ud      r86.0<1>:ud      {I@2} // (s0^s1)&s2
        cmp (16|M0)   (ne)f1.0   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
        bfn.0x60 (16|M0)         r8.0<1>:ud    r64.0<1;0>:ud     r7.5<0;0>:ud      r84.0<1>:ud      // (s0^s1)&s2
(~f1.0) cmp (16|M0)   (ne)f1.0   null<1>:d     r8.0<1;1,0>:d     0:w               {I@1}
(W)     mov (1|M0)               r6.8<1>:hf    -qnan(0x1FF):hf                             
        mov (16|M0)              r88.0<1>:f    r30.0<1;1,0>:f                   {Compacted}
(f1.0)  sel (16|M0)              r10.0<1>:d    r6.8<0;1,0>:w     0:w               {F@2}
        mov (16|M0)              r104.0<1>:d   -r10.0<1;1,0>:d                  {I@1}
        goto (16|M0)                         L10520                  L10576                
L10520:
        join (16|M0)                         L10576                                
L10536:
        mov (16|M0)              r104.0<1>:d   0:w                              
        mov (16|M0)              r54.0<1>:d    0:w                              
        mov (16|M0)              r88.0<1>:f    r86.0<1;1,0>:f                   {Compacted}
L10576:
        join (16|M0)                         L11104                                
L10592:
        and (16|M0)   (ne)f1.0   r78.0<1>:d    r22.0<1;1,0>:d    63:w              
(f1.0)  goto (16|M0)                         L10648                  L10648                
L10624:
        mov (16|M0)              r10.0<1>:f    r86.0<1;1,0>:f                   {Compacted,I@7}
        goto (16|M0)                         L10648                  L10752                
L10648:
        join (16|M0)                         L10752                                
L10664:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r78.0<1;1,0>:ud   0x20:uw              {I@4}
(~f1.1) add (16|M0)              r2.0<1>:d     r78.0<1;1,0>:d    -32:w              
(~f1.1) shr (16|M0)              r10.0<1>:ud   r84.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.1)  add (16|M0)              r2.0<1>:d     -r78.0<1;1,0>:d   32:w               {Compacted}
(f1.1)  shr (16|M0)              r8.0<1>:ud    r86.0<1;1,0>:ud   r78.0<1;1,0>:d  
(f1.1)  shl (16|M0)              r2.0<1>:d     r84.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.1)  or (16|M0)               r10.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
L10752:
        join (16|M0)                         L11104                                
L10768:
        shl (16|M0)              r2.0<1>:d     r88.0<1;1,0>:d    2:w               {Compacted}
        shl (16|M0)              r8.0<1>:d     r54.0<1;1,0>:d    1:w               {Compacted}
        and (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     4:w               {Compacted,I@2}
        bfn.0xFE (16|M0)         r108.0<1>:ud  r2.0<1;0>:ud      r8.0<1;0>:ud      r104.0<1>:ud     {I@1} // s0|s1|s2
        cmp (16|M0)   (eq)f1.0   null<1>:d     r108.0<1;1,0>:d   0:w               {I@1}
(~f1.0) goto (16|M0)                         L10872                  L10872                
L10840:
        mov (16|M0)              r110.0<1>:d   0:w                              
        goto (16|M0)                         L10872                  L11032                
L10872:
        join (16|M0)                         L11032                                
L10888:
        cmp (16|M0)   (gt)f1.1   null<1>:d     r108.0<1;1,0>:ud  0x4:uw             
(~f1.1) goto (16|M0)                         L10952                  L10952                
L10920:
        mov (16|M0)              r110.0<1>:d   1:w                              
        goto (16|M0)                         L10952                  L11032                
L10952:
        join (16|M0)                         L11032                                
L10968:
        and (16|M0)   (ne)f1.1   null<1>:d     r10.0<1;1,0>:d    1:w              
(W)     mov (1|M0)               r2.0<1>:hf    0x1:hf                             
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r108.0<1;1,0>:d   4:w              
(f1.1)  sel (16|M0)              r110.0<1>:d   r2.0<0;1,0>:w     0:w               {F@1}
L11032:
        join (16|M0)                         L11104                                
L11048:
        add (16|M0)              r2.0<1>:d     r110.0<1;1,0>:d   r10.0<1;1,0>:d   {Compacted,I@2}
        cmp (16|M0)   (gt)f1.0   null<1>:d     r2.0<1;1,0>:ud    0x7FFFFF:ud              {I@1}
(W)     mov (1|M0)               r6.4<1>:f     0x800000:f                               {Compacted}
(~f1.0) sel (16|M0)              r120.0<1>:d   r2.0<1;1,0>:d     0:w              
(f1.0)  sel (16|M0)              r118.0<1>:d   r6.4<0;1,0>:d     0:w               {Compacted,F@1}
L11104:
        join (16|M0)                         L11168                                
L11120:
        and (16|M0)              r2.0<1>:d     r92.0<1;1,0>:d    -2147483648:d              
        bfn.0xFE (16|M0)         r60.0<1>:ud   r2.0<1;0>:ud      r118.0<1;0>:ud    r120.0<1>:ud     {I@1} // s0|s1|s2
        goto (16|M0)                         L11168                  L14216                
L11168:
        join (16|M0)                         L11672                                
L11184:
        and (16|M0)   (ne)f1.0   r122.0<1>:d   r104.0<1;1,0>:d   63:w              
(f1.0)  goto (16|M0)                         L11264                  L11264                
L11216:
        mov (16|M0)              r8.0<1>:d     -1:w                              
        mov (16|M0)              r16.0<1>:d    -1:w                              
        goto (16|M0)                         L11264                  L11448                
L11264:
        join (16|M0)                         L11448                                
L11280:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r122.0<1;1,0>:ud  0x20:uw              {I@6}
(f1.1)  goto (16|M0)                         L11384                  L11384                
L11312:
        add (16|M0)              r2.0<1>:d     r122.0<1;1,0>:d   -32:w               {Compacted}
(W)     mov (1|M0)               r6.8<1>:hf    -qnan(0x1FF):hf                             
        mov (16|M0)              r8.0<1>:d     0:w                              
        shl (16|M0)              r16.0<1>:d    r6.8<0;1,0>:w     r2.0<1;1,0>:d    {A@1}
        goto (16|M0)                         L11384                  L11448                
L11384:
        join (16|M0)                         L11448                                
L11400:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (16|M0)              r16.0<1>:d    -1:w                              
        shl (16|M0)              r8.0<1>:d     r2.0<0;1,0>:w     r122.0<1;1,0>:d  {F@1}
L11448:
        join (16|M0)                         L11672                                
L11464:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r8.0<1;0>:ud      r7.5<0;0>:ud      r86.0<1>:ud      {I@2} // (s0^s1)&s2
        cmp (16|M0)   (ne)f1.1   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
        bfn.0x60 (16|M0)         r8.0<1>:ud    r16.0<1;0>:ud     r7.5<0;0>:ud      r84.0<1>:ud      // (s0^s1)&s2
        cmp (16|M0)   (gt)f1.0   null<1>:d     r92.0<1;1,0>:d    -1:w              
(~f1.1) cmp (16|M0)   (ne)f1.1   null<1>:d     r8.0<1;1,0>:d     0:w               {I@2}
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r12.0<1;1,0>:d    -150:w              
(f1.0)  goto (16|M0)                         L11616                  L11616                
L11576:
(W)     mov (1|M0)               r2.0<1>:ud    0x80000001:ud                             
(f1.1)  sel (16|M0)              r60.0<1>:f    r2.0<0;1,0>:f     -0.0:f               {Compacted,I@1}
        goto (16|M0)                         L11616                  L14216                
L11616:
        join (16|M0)                         L11672                                
L11632:
(W)     mov (1|M0)               r2.0<1>:ud    0x1:ud                              {F@1}
(f1.1)  sel (16|M0)              r60.0<1>:f    r2.0<0;1,0>:f     0.0:f               {Compacted,I@1}
        goto (16|M0)                         L11672                  L14216                
L11672:
        join (16|M0)                         L13992                                
L11688:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r104.0<1;1,0>:ud  0x18:uw             
        add3 (16|M0)             r118.0<1>:d   r88.0<1;0>:d      r104.0<1;0>:d     -46:w              
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r126.0<1;1,0>:d   0:w              
(f1.0)  goto (16|M0)                         L13680                  L13680                
L11752:
        shl (16|M0)              r2.0<1>:d     r82.0<1;1,0>:d    1:w               {Compacted,F@1}
        shr (16|M0)              r8.0<1>:ud    r82.0<1;1,0>:ud   31:w              
        shl (16|M0)              r10.0<1>:d    r80.0<1;1,0>:d    1:w               {Compacted}
        cmp (16|M0)   (lt)f1.1   null<1>:d     r2.0<1;1,0>:ud    0x4E:uw              {I@3}
        or (16|M0)               r10.0<1>:d    r10.0<1;1,0>:d    r8.0<1;1,0>:d    {Compacted,I@2}
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r10.0<1;1,0>:d    0:w               {I@1}
(~f1.1) cmp (16|M0)   (lt)f1.1   null<1>:d     r10.0<1;1,0>:d    0:w              
(f1.1)  goto (16|M0)                         L11984                  L11984                
L11856:
        cmp (16|M0)   (eq)f1.1   null<1>:d     r82.0<1;1,0>:d    39:w              
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r80.0<1;1,0>:d    0:w              
(~f1.1) goto (16|M0)                         L11984                  L12048                
L11904:
        shr (16|M0)              r10.0<1>:ud   r86.0<1;1,0>:ud   1:w              
        mov (16|M0)              r18.0<1>:d    0:w                              
        mov (16|M0)              r124.0<1>:d   0:w                              
        mov (16|M0)              r58.0<1>:f    r10.0<1;1,0>:f                   {Compacted,I@3}
        mov (16|M0)              r10.0<1>:f    r86.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L11984                  L13152                
L11984:
        join (16|M0)                         L12048                                
L12000:
        cmp (16|M0)   (eq)f1.0   null<1>:d     r82.0<1;1,0>:d    38:w              
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r80.0<1;1,0>:d    0:w              
(f1.0)  goto (16|M0)                         L12048                  L13064                
L12048:
        join (16|M0)                         L13064                                
L12064:
        add (16|M0)              r2.0<1>:d     -r82.0<1;1,0>:d   39:w               {Compacted}
        and (16|M0)   (ne)f1.1   r90.0<1>:d    r2.0<1;1,0>:d     63:w               {I@1}
        add (16|M0)              r122.0<1>:d   -r82.0<1;1,0>:d   40:w               {Compacted}
(f1.1)  goto (16|M0)                         L12136                  L12136                
L12112:
        mov (16|M0)              r120.0<1>:f   r86.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L12136                  L12248                
L12136:
        join (16|M0)                         L12248                                
L12152:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r90.0<1;1,0>:ud   0x20:uw              {I@5}
(~f1.0) add (16|M0)              r2.0<1>:d     r90.0<1;1,0>:d    -32:w              
(~f1.0) shr (16|M0)              r10.0<1>:ud   r84.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.0)  add (16|M0)              r2.0<1>:d     -r90.0<1;1,0>:d   32:w               {Compacted}
(f1.0)  shr (16|M0)              r8.0<1>:ud    r86.0<1;1,0>:ud   r90.0<1;1,0>:d  
(f1.0)  shl (16|M0)              r2.0<1>:d     r84.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.0)  or (16|M0)               r10.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
        mov (16|M0)              r120.0<1>:f   r10.0<1;1,0>:f                   {Compacted,I@1}
L12248:
        join (16|M0)                         L13064                                
L12264:
        add (16|M0)              r30.0<1>:d    -r82.0<1;1,0>:d   38:w               {Compacted}
        and (16|M0)   (ne)f1.1   r96.0<1>:d    r30.0<1;1,0>:d    63:w               {I@1}
(f1.1)  goto (16|M0)                         L12328                  L12328                
L12304:
        mov (16|M0)              r10.0<1>:f    r86.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L12328                  L12432                
L12328:
        join (16|M0)                         L12432                                
L12344:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r96.0<1;1,0>:ud   0x20:uw              {I@4}
(~f1.0) add (16|M0)              r2.0<1>:d     r96.0<1;1,0>:d    -32:w              
(~f1.0) shr (16|M0)              r10.0<1>:ud   r84.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.0)  add (16|M0)              r2.0<1>:d     -r96.0<1;1,0>:d   32:w               {Compacted}
(f1.0)  shr (16|M0)              r8.0<1>:ud    r86.0<1;1,0>:ud   r96.0<1;1,0>:d  
(f1.0)  shl (16|M0)              r2.0<1>:d     r84.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.0)  or (16|M0)               r10.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
L12432:
        join (16|M0)                         L13064                                
L12448:
        and (16|M0)   (ne)f1.1   r70.0<1>:d    r30.0<1;1,0>:d    63:w              
        and (16|M0)              r124.0<1>:d   r10.0<1;1,0>:d    1:w               {Compacted,I@3}
(f1.1)  goto (16|M0)                         L12536                  L12536                
L12488:
        mov (16|M0)              r74.0<1>:d    -1:w                              
        mov (16|M0)              r82.0<1>:d    -1:w                              
        goto (16|M0)                         L12536                  L12720                
L12536:
        join (16|M0)                         L12720                                
L12552:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r70.0<1;1,0>:ud   0x20:uw              {I@7}
(f1.0)  goto (16|M0)                         L12656                  L12656                
L12584:
        add (16|M0)              r2.0<1>:d     r70.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r6.8<1>:hf    -qnan(0x1FF):hf                             
        mov (16|M0)              r74.0<1>:d    0:w                              
        shl (16|M0)              r82.0<1>:d    r6.8<0;1,0>:w     r2.0<1;1,0>:d    {A@1}
        goto (16|M0)                         L12656                  L12720                
L12656:
        join (16|M0)                         L12720                                
L12672:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (16|M0)              r82.0<1>:d    -1:w                              
        shl (16|M0)              r74.0<1>:d    r2.0<0;1,0>:w     r70.0<1;1,0>:d   {F@1}
L12720:
        join (16|M0)                         L13064                                
L12736:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r74.0<1;0>:ud     r7.5<0;0>:ud      r86.0<1>:ud      {I@2} // (s0^s1)&s2
        cmp (16|M0)   (ne)f1.1   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
        bfn.0x60 (16|M0)         r8.0<1>:ud    r82.0<1;0>:ud     r7.5<0;0>:ud      r84.0<1>:ud      // (s0^s1)&s2
(~f1.1) cmp (16|M0)   (ne)f1.1   null<1>:d     r8.0<1;1,0>:d     0:w               {I@1}
(W)     mov (1|M0)               r6.8<1>:hf    -qnan(0x1FF):hf                             
(f1.1)  sel (16|M0)              r10.0<1>:d    r6.8<0;1,0>:w     0:w               {F@1}
        and (16|M0)   (ne)f1.1   r94.0<1>:d    r122.0<1;1,0>:d   63:w              
        mov (16|M0)              r18.0<1>:d    -r10.0<1;1,0>:d                  {I@2}
(f1.1)  goto (16|M0)                         L12904                  L12904                
L12880:
        mov (16|M0)              r10.0<1>:f    r86.0<1;1,0>:f                   {Compacted,I@2}
        goto (16|M0)                         L12904                  L13008                
L12904:
        join (16|M0)                         L13008                                
L12920:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r94.0<1;1,0>:ud   0x20:uw             
(~f1.0) add (16|M0)              r2.0<1>:d     r94.0<1;1,0>:d    -32:w              
(~f1.0) shr (16|M0)              r10.0<1>:ud   r84.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.0)  add (16|M0)              r2.0<1>:d     -r94.0<1;1,0>:d   32:w               {Compacted}
(f1.0)  shr (16|M0)              r8.0<1>:ud    r86.0<1;1,0>:ud   r94.0<1;1,0>:d  
(f1.0)  shl (16|M0)              r2.0<1>:d     r84.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.0)  or (16|M0)               r10.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
L13008:
        join (16|M0)                         L13064                                
L13024:
        mov (16|M0)              r58.0<1>:f    r10.0<1;1,0>:f                   {Compacted,I@2}
        mov (16|M0)              r10.0<1>:d    r120.0<1;1,0>:d                  {F@1}
        goto (16|M0)                         L13064                  L13152                
L13064:
        join (16|M0)                         L13152                                
L13080:
        shr (16|M0)              r10.0<1>:ud   r86.0<1;1,0>:ud   2:w              
        mov (16|M0)              r18.0<1>:d    0:w                              
        mov (16|M0)              r124.0<1>:d   0:w                              
        mov (16|M0)              r58.0<1>:f    r10.0<1;1,0>:f                   {Compacted,I@3}
        shr (16|M0)              r10.0<1>:ud   r86.0<1;1,0>:ud   1:w               {F@1}
L13152:
        join (16|M0)                         L13680                                
L13168:
        shl (16|M0)              r2.0<1>:d     r10.0<1;1,0>:d    2:w               {Compacted,I@2}
        shl (16|M0)              r8.0<1>:d     r124.0<1;1,0>:d   1:w               {Compacted}
        and (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     4:w               {Compacted,I@2}
        bfn.0xFE (16|M0)         r126.0<1>:ud  r2.0<1;0>:ud      r8.0<1;0>:ud      r18.0<1>:ud      {I@1} // s0|s1|s2
        cmp (16|M0)   (eq)f1.1   null<1>:d     r126.0<1;1,0>:d   0:w               {I@1}
        and (16|M0)              r52.0<1>:d    r58.0<1;1,0>:d    8388607:d              
(~f1.1) goto (16|M0)                         L13288                  L13288                
L13256:
        mov (16|M0)              r120.0<1>:d   0:w                              
        goto (16|M0)                         L13288                  L13448                
L13288:
        join (16|M0)                         L13448                                
L13304:
        cmp (16|M0)   (gt)f1.0   null<1>:d     r126.0<1;1,0>:ud  0x4:uw             
(~f1.0) goto (16|M0)                         L13368                  L13368                
L13336:
        mov (16|M0)              r120.0<1>:d   1:w                              
        goto (16|M0)                         L13368                  L13448                
L13368:
        join (16|M0)                         L13448                                
L13384:
        and (16|M0)   (ne)f1.0   null<1>:d     r58.0<1;1,0>:d    1:w              
(W)     mov (1|M0)               r2.0<1>:hf    0x1:hf                             
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r126.0<1;1,0>:d   4:w              
(f1.0)  sel (16|M0)              r120.0<1>:d   r2.0<0;1,0>:w     0:w               {F@1}
L13448:
        join (16|M0)                         L13680                                
L13464:
        add (16|M0)              r12.0<1>:d    r52.0<1;1,0>:d    r120.0<1;1,0>:d  {Compacted,I@2}
        cmp (16|M0)   (gt)f1.0   null<1>:d     r12.0<1;1,0>:ud   0x7FFFFF:ud              {I@1}
        add3 (16|M0)             r2.0<1>:d     r88.0<1;0>:d      r104.0<1;0>:d     -45:w              
(f1.0)  sel (16|M0)              r122.0<1>:d   r2.0<1;1,0>:d     r118.0<1;1,0>:d  {Compacted,I@1}
        cmp (16|M0)   (eq)f1.1   null<1>:d     r122.0<1;1,0>:d   255:w               {I@1}
(f1.1)  goto (16|M0)                         L13616                  L13616                
L13544:
(~f1.0) sel (16|M0)              r2.0<1>:d     r12.0<1;1,0>:d    0:w              
        and (16|M0)              r8.0<1>:d     r92.0<1;1,0>:d    -2147483648:d              
        shl (16|M0)              r10.0<1>:d    r122.0<1;1,0>:d   23:w               {Compacted}
        bfn.0xFE (16|M0)         r60.0<1>:ud   r8.0<1;0>:ud      r10.0<1;0>:ud     r2.0<1>:ud       {I@1} // s0|s1|s2
        goto (16|M0)                         L13616                  L14216                
L13616:
        join (16|M0)                         L13680                                
L13632:
        cmp (16|M0)   (gt)f1.1   null<1>:d     r92.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r2.0<1>:f     inf:f                               {Compacted,I@4}
(f1.1)  sel (16|M0)              r60.0<1>:f    r2.0<0;1,0>:f     -inf:f               {Compacted,F@1}
        goto (16|M0)                         L13680                  L14216                
L13680:
        join (16|M0)                         L13992                                
L13696:
        and (16|M0)   (ne)f1.0   r116.0<1>:d   r104.0<1;1,0>:d   63:w              
(f1.0)  goto (16|M0)                         L13760                  L13760                
L13728:
        mov (16|M0)              r114.0<1>:d   -1:w                              
        goto (16|M0)                         L13760                  L13888                
L13760:
        join (16|M0)                         L13888                                
L13776:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r116.0<1;1,0>:ud  0x20:uw              {A@1}
(f1.1)  goto (16|M0)                         L13840                  L13840                
L13808:
        mov (16|M0)              r114.0<1>:d   0:w                              
        goto (16|M0)                         L13840                  L13888                
L13840:
        join (16|M0)                         L13888                                
L13856:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                             
        shl (16|M0)              r114.0<1>:d   r2.0<0;1,0>:w     r116.0<1;1,0>:d  {F@1}
L13888:
        join (16|M0)                         L13992                                
L13904:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r114.0<1;0>:ud    r7.5<0;0>:ud      r86.0<1>:ud      {I@2} // (s0^s1)&s2
        add (16|M0)              r8.0<1>:d     -r104.0<1;1,0>:d  23:w               {Compacted}
        and (16|M0)              r10.0<1>:d    r92.0<1;1,0>:d    -2147483648:d              
        shl (16|M0)              r12.0<1>:d    r118.0<1;1,0>:d   23:w               {Compacted}
        shl (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     r8.0<1;1,0>:d    {Compacted,I@3}
        bfn.0xFE (16|M0)         r60.0<1>:ud   r10.0<1;0>:ud     r12.0<1;0>:ud     r2.0<1>:ud       {I@1} // s0|s1|s2
        goto (16|M0)                         L13992                  L14216                
L13992:
        join (16|M0)                         L14056                                
L14008:
        cmp (16|M0)   (gt)f1.0   null<1>:d     r92.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r2.0<1>:f     inf:f                               {Compacted,I@4}
(f1.0)  sel (16|M0)              r60.0<1>:f    r2.0<0;1,0>:f     -inf:f               {Compacted,F@1}
        goto (16|M0)                         L14056                  L14216                
L14056:
        join (16|M0)                         L14120                                
L14072:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r92.0<1;1,0>:d    0:w              
(W)     mov (1|M0)               r2.0<1>:f     -0.0:f                               {Compacted}
(f1.1)  sel (16|M0)              r60.0<1>:f    r2.0<0;1,0>:f     0.0:f               {Compacted,F@1}
        goto (16|M0)                         L14120                  L14216                
L14120:
        join (16|M0)                         L14184                                
L14136:
        cmp (16|M0)   (gt)f1.0   null<1>:d     r92.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r2.0<1>:f     inf:f                               {Compacted}
(f1.0)  sel (16|M0)              r60.0<1>:f    r2.0<0;1,0>:f     -inf:f               {Compacted,F@1}
        goto (16|M0)                         L14184                  L14216                
L14184:
        join (16|M0)                         L14216                                
L14200:
        bfn.0xF8 (16|M0)         r60.0<1>:ud   r92.0<1;0>:ud     r7.7<0;0>:ud      r7.6<0>:ud       {F@1} // s0&s1|s2
L14216:
        join (16|M0)                         L16000                                
L14232:
        cmp (16|M0)   (lt)f1.0   null<1>:f     r50.0<1;1,0>:f    0.0:f               {Compacted,I@5}
(f1.0)  sel (16|M0)              r2.0<1>:f     -r60.0<1;1,0>:f   r60.0<1;1,0>:f   {Compacted,I@2}
        mov (8|M0)               r114.0<1>:hf  r2.0<1;1,0>:f                    {F@1}
        mov (8|M8)               r114.8<1>:hf  r3.0<1;1,0>:f                   
(~f0.0) goto (16|M0)                         L14328                  L14328                
L14296:
        mov (16|M0)              r64.0<1>:d    -1:w                              
        goto (16|M0)                         L14328                  L14696                
L14328:
        join (16|M0)                         L14696                                
L14344:
(W)     xor (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x30:uw              {A@1}
(W)     mov (1|M0)               r2.0<1>:f     r5.4<0;1,0>:ud                   {Compacted,A@1}
(W)     mov (1|M0)               r3.2<1>:f     0xB4C00000:f                               {Compacted}
(W)     math.inv (1|M0)          r3.1<1>:f     r2.0<0;1,0>:f                    {@2,$10}
        mov (16|M0)              r8.0<1>:f     r44.0<1;1,0>:ud                  {Compacted}
        sync.nop                             null                             {Compacted,$10.dst}
(W)     mad (1|M0)               r6.4<1>:f     r3.1<0;0>:f       r3.2<0;0>:f       r3.1<0>:f        {F@2}
(W)     mov (1|M0)               r2.1<1>:ud    r2.0<0;1,0>:f                   
        mov (16|M0)              r12.0<1>:ud   r8.0<1;1,0>:f                    {F@2}
        mul (16|M0)              r10.0<1>:f    r8.0<1;1,0>:f     r6.4<0;1,0>:f    {Compacted,F@1}
(W)     add (1|M0)               r3.0<1>:d     r5.4<0;1,0>:d     -r2.1<0;1,0>:d   {I@2}
        add (16|M0)              r12.0<1>:d    r44.0<1;1,0>:d    -r12.0<1;1,0>:d  {Compacted,I@2}
        mov (16|M0)              r14.0<1>:ud   r10.0<1;1,0>:f                   {F@1}
(W)     mov (1|M0)               r6.5<1>:f     r3.0<0;1,0>:ud                   {Compacted,I@3}
        mov (16|M0)              r16.0<1>:f    r12.0<1;1,0>:ud                  {Compacted,I@2}
        mov (16|M0)              r18.0<1>:f    r14.0<1;1,0>:ud                  {Compacted,I@1}
        mad (16|M0)              acc0.0<1>:f   r8.0<1;0>:f       r18.0<1;0>:f      -r2.0<0>:f       {Compacted,F@1}
        mad (16|M0)              acc2.0<1>:f   r16.0<1;0>:f      r18.0<1;0>:f      -r6.5<0>:f       {Compacted}
        add (16|M0)              acc0.0<1>:f   acc0.0<1;1,0>:f   acc2.0<1;1,0>:f 
        mul (16|M0)              r26.0<1>:f    r6.4<0;1,0>:f     acc0.0<1;1,0>:f 
(W)     xor (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x30:uw              {A@1}
        mov (16|M0)              r28.0<1>:ud   r26.0<1;1,0>:f                   {A@1}
        add (16|M0)              r30.0<1>:d    r28.0<1;1,0>:d    r14.0<1;1,0>:d   {Compacted,I@1}
(W)     mul (8|M0)               acc0.0<1>:d   r30.0<1;1,0>:d    r5.8<0;1,0>:uw   {Compacted,I@1}
        mach (8|M0)              r30.0<1>:d    r30.0<1;1,0>:d    r5.4<0;1,0>:d    {Compacted}
(W)     mul (8|M8)               acc0.0<1>:d   r31.0<1;1,0>:d    r5.8<0;1,0>:uw  
        mach (8|M8)              r31.0<1>:d    r31.0<1;1,0>:d    r5.4<0;1,0>:d    {Compacted}
        add (16|M0)              r30.0<1>:d    r44.0<1;1,0>:d    -r30.0<1;1,0>:d  {Compacted,I@1}
        cmp (16|M0)   (ge)f1.0   r8.0<1>:ud    r30.0<1;1,0>:ud   r5.4<0;1,0>:ud   {I@1}
        add3 (16|M0)             r64.0<1>:d    r28.0<1;0>:d      r14.0<1;0>:d      -r8.0<1>:d       {I@1}
L14696:
        join (16|M0)                         L16000                                
L14712:
(W)     mul (8|M0)               acc0.0<1>:d   r64.0<1;1,0>:d    r5.8<0;1,0>:uw   {Compacted,I@2}
        mach (8|M0)              r2.0<1>:d     r64.0<1;1,0>:d    r5.4<0;1,0>:d    {Compacted}
(W)     mul (8|M8)               acc0.0<1>:d   r65.0<1;1,0>:d    r5.8<0;1,0>:uw  
        mach (8|M8)              r3.0<1>:d     r65.0<1;1,0>:d    r5.4<0;1,0>:d    {Compacted}
        mul (8|M0)               acc0.0<1>:ud  r64.0<1;1,0>:ud   r5.10<0;1,0>:uw 
        mach (8|M0)              r10.0<1>:ud   r64.0<1;1,0>:ud   r5.5<0;1,0>:ud   {AccWrEn,Compacted}
        add (16|M0)              r8.0<1>:d     r44.0<1;1,0>:d    -r2.0<1;1,0>:d   {Compacted,I@3}
        mov (8|M0)               r12.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mul (8|M8)               acc0.0<1>:ud  r65.0<1;1,0>:ud   r5.10<0;1,0>:uw 
        mach (8|M8)              r11.0<1>:ud   r65.0<1;1,0>:ud   r5.5<0;1,0>:ud   {AccWrEn}
        cmp (16|M0)   (lt)f1.1   null<1>:d     r42.0<1;1,0>:ud   r5.1<0;1,0>:ud  
        mov (8|M8)               r13.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mov (16|M0)              r16.0<1>:f    r10.0<1;1,0>:f                   {Compacted,A@3}
        mov (16|M0)              r14.0<1>:f    r12.0<1;1,0>:f                   {Compacted,I@1}
        addc (8|M0)              r18.0<1>:ud   r14.0<1;1,0>:ud   r36.0<1;1,0>:ud  {AccWrEn,Compacted,F@1}
        add (8|M0)               r20.0<1>:ud   acc0.0<1;1,0>:ud  r16.0<1;1,0>:ud 
        addc (8|M8)              r19.0<1>:ud   r15.0<1;1,0>:ud   r37.0<1;1,0>:ud  {AccWrEn}
        add (8|M8)               r21.0<1>:ud   acc0.0<1;1,0>:ud  r17.0<1;1,0>:ud 
        mul (8|M0)               acc0.0<1>:ud  r18.0<1;1,0>:ud   r5.8<0;1,0>:uw   {I@4}
        mach (8|M0)              r2.0<1>:ud    r18.0<1;1,0>:ud   r5.4<0;1,0>:ud   {AccWrEn,Compacted}
        mov (8|M0)               r22.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mul (8|M8)               acc0.0<1>:ud  r19.0<1;1,0>:ud   r5.8<0;1,0>:uw   {I@5}
        mach (8|M8)              r3.0<1>:ud    r19.0<1;1,0>:ud   r5.4<0;1,0>:ud   {AccWrEn}
        mov (8|M8)               r23.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
(W)     mul (8|M0)               acc0.0<1>:d   r5.4<0;1,0>:ud    r20.0<2;1,0>:uw 
        mach (8|M0)              r10.0<1>:d    r5.4<0;1,0>:ud    r20.0<1;1,0>:d  
(W)     mul (8|M8)               acc0.0<1>:d   r5.4<0;1,0>:ud    r21.0<2;1,0>:uw  {I@7}
        mov (16|M0)              r12.0<1>:f    r22.0<1;1,0>:f                   {Compacted,A@4}
        mach (8|M8)              r11.0<1>:d    r5.4<0;1,0>:ud    r21.0<1;1,0>:d  
        addc (8|M0)              r16.0<1>:ud   r12.0<1;1,0>:ud   r8.0<1;1,0>:ud   {AccWrEn,Compacted,F@1}
        add (16|M0)              r14.0<1>:d    r2.0<1;1,0>:d     r10.0<1;1,0>:d   {Compacted,I@2}
        add (8|M0)               r24.0<1>:ud   acc0.0<1;1,0>:ud  r14.0<1;1,0>:ud  {I@1}
        addc (8|M8)              r17.0<1>:ud   r13.0<1;1,0>:ud   r9.0<1;1,0>:ud   {AccWrEn}
        add (8|M8)               r25.0<1>:ud   acc0.0<1;1,0>:ud  r15.0<1;1,0>:ud 
        shl (16|M0)              r18.0<1>:d    r16.0<1;1,0>:d    5:w               {Compacted,I@2}
        shl (16|M0)              r24.0<1>:d    r24.0<1;1,0>:d    5:w               {Compacted,I@2}
        shr (16|M0)              r16.0<1>:ud   r16.0<1;1,0>:ud   27:w              
        bfn.0xEA (16|M0)         r66.0<1>:ud   r18.0<1;0>:ud     r38.0<1;0>:ud     r69.0<0>:ud      {I@3} // s0|s1&s2
        or (16|M0)               r26.0<1>:d    r24.0<1;1,0>:d    r16.0<1;1,0>:d   {Compacted,I@2}
(f1.1)  goto (16|M0)                         L15632                  L15632                
L15200:
        cmp (16|M0)   (eq)f1.0   null<1>:d     r40.0<1;1,0>:d    1:w              
(f1.0)  goto (16|M0)                         L15424                  L15424                
L15232:
        shl (16|M0)              r2.0<1>:d     r66.0<1;1,0>:d    1:w               {Compacted,I@5}
        addc (8|M0)              r12.0<1>:ud   r2.0<1;1,0>:ud    r69.1<0;1,0>:ud  {AccWrEn,Compacted,I@1}
        shr (16|M0)              r8.0<1>:ud    r66.0<1;1,0>:ud   31:w              
        shl (16|M0)              r10.0<1>:d    r26.0<1;1,0>:d    1:w               {Compacted}
        mov (8|M0)               r14.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        addc (8|M8)              r13.0<1>:ud   r3.0<1;1,0>:ud    r69.1<0;1,0>:ud  {AccWrEn}
        or (16|M0)               r10.0<1>:d    r10.0<1;1,0>:d    r8.0<1;1,0>:d    {Compacted,I@3}
        mov (8|M8)               r20.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mov (16|M0)              r22.0<1>:ud   r114.0<1;1,0>:uw                
        add3 (8|M0)              r15.1<2>:ud   r14.0<1;0>:ud     r10.0<1;0>:ud     r69.2<0>:ud      {I@3}
        add3 (8|M8)              r17.1<2>:ud   r20.0<1;0>:ud     r11.0<1;0>:ud     r69.2<0>:ud      {I@3}
        mov (8|M0)               r15.0<2>:d    r12.0<1;1,0>:d                  
        mov (8|M8)               r17.0<2>:d    r13.0<1;1,0>:d                  
        send.ugm (16|M0)         null     r15     r22:2   0x0            0x080E0B84           {A@1,$4} // wr:4+2, rd:0; store.ugm.d16u32.a64.wb.wb
        goto (16|M0)                         L15424                  L15832                
L15424:
        join (16|M0)                         L15632                                
L15440:
        shl (16|M0)              r2.0<1>:d     r66.0<1;1,0>:d    1:w               {Compacted}
        addc (8|M0)              r12.0<1>:ud   r2.0<1;1,0>:ud    r5.6<0;1,0>:ud   {AccWrEn,Compacted,I@1}
        shr (16|M0)              r8.0<1>:ud    r66.0<1;1,0>:ud   31:w              
        shl (16|M0)              r10.0<1>:d    r26.0<1;1,0>:d    1:w               {Compacted}
        mov (8|M0)               r14.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        addc (8|M8)              r13.0<1>:ud   r3.0<1;1,0>:ud    r5.6<0;1,0>:ud   {AccWrEn}
        or (16|M0)               r10.0<1>:d    r10.0<1;1,0>:d    r8.0<1;1,0>:d    {Compacted,I@3}
        mov (8|M8)               r20.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mov (16|M0)              r22.0<1>:ud   r114.0<1;1,0>:uw                 {$4.src}
        add3 (8|M0)              r15.1<2>:ud   r14.0<1;0>:ud     r10.0<1;0>:ud     r5.7<0>:ud       {I@3}
        add3 (8|M8)              r17.1<2>:ud   r20.0<1;0>:ud     r11.0<1;0>:ud     r5.7<0>:ud       {I@3}
        mov (8|M0)               r15.0<2>:d    r12.0<1;1,0>:d                  
        mov (8|M8)               r17.0<2>:d    r13.0<1;1,0>:d                  
        send.ugm (16|M0)         null     r15     r22:2   0x0            0x080E0B84           {A@1,$6} // wr:4+2, rd:0; store.ugm.d16u32.a64.wb.wb
        goto (16|M0)                         L15632                  L15832                
L15632:
        join (16|M0)                         L15832                                
L15648:
        shl (16|M0)              r2.0<1>:d     r66.0<1;1,0>:d    1:w               {Compacted}
        addc (8|M0)              r12.0<1>:ud   r2.0<1;1,0>:ud    r5.2<0;1,0>:ud   {AccWrEn,Compacted,I@1}
        shr (16|M0)              r8.0<1>:ud    r66.0<1;1,0>:ud   31:w              
        shl (16|M0)              r10.0<1>:d    r26.0<1;1,0>:d    1:w               {Compacted}
        mov (8|M0)               r14.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        addc (8|M8)              r13.0<1>:ud   r3.0<1;1,0>:ud    r5.2<0;1,0>:ud   {AccWrEn}
        or (16|M0)               r10.0<1>:d    r10.0<1;1,0>:d    r8.0<1;1,0>:d    {Compacted,I@3}
        mov (8|M8)               r20.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        sync.nop                             null                             {Compacted,$6.src}
        mov (16|M0)              r22.0<1>:ud   r114.0<1;1,0>:uw                 {$4.src}
        add3 (8|M0)              r15.1<2>:ud   r14.0<1;0>:ud     r10.0<1;0>:ud     r5.3<0>:ud       {I@3}
        add3 (8|M8)              r17.1<2>:ud   r20.0<1;0>:ud     r11.0<1;0>:ud     r5.3<0>:ud       {I@3}
        mov (8|M0)               r15.0<2>:d    r12.0<1;1,0>:d                  
        mov (8|M8)               r17.0<2>:d    r13.0<1;1,0>:d                  
        send.ugm (16|M0)         null     r15     r22:2   0x0            0x080E0B84           {A@1,$5} // wr:4+2, rd:0; store.ugm.d16u32.a64.wb.wb
L15832:
        join (16|M0)                         L16000                                
L15848:
        addc (8|M0)              r106.0<1>:ud  r48.0<1;1,0>:ud   r7.0<0;1,0>:ud   {AccWrEn,Compacted}
        add (8|M0)               r76.0<1>:ud   acc0.0<1;1,0>:ud  r46.0<1;1,0>:ud 
        addc (8|M8)              r107.0<1>:ud  r49.0<1;1,0>:ud   r7.0<0;1,0>:ud   {AccWrEn}
        cmp (16|M0)   (lt)f1.1   null<1>:d     r106.0<1;1,0>:ud  r4.6<0;1,0>:ud   {I@1}
        add (8|M8)               r77.0<1>:ud   acc0.0<1;1,0>:ud  r47.0<1;1,0>:ud 
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r76.0<1;1,0>:d    r4.7<0;1,0>:d    {I@1}
(~f1.1) cmp (16|M0)   (lt)f1.1   null<1>:d     r76.0<1;1,0>:ud   r4.7<0;1,0>:ud  
(~f1.1) goto (16|M0)                         L16000                  L16000                
L15968:
(f1.1)  sel (16|M0)              r48.0<1>:d    r106.0<1;1,0>:d   r34.0<1;1,0>:d   {Compacted}
(f1.1)  sel (16|M0)              r46.0<1>:d    r76.0<1;1,0>:d    r32.0<1;1,0>:d   {Compacted}
(W)     jmpi                                 L736                                
L16000:
        join (16|M0)                         L16016                                
L16016:
(W)     mov (8|M0)               r127.0<1>:f   r68.0<1;1,0>:f                   {Compacted,$3.src}
(W)     send.gtwy (1|M0)         null     r127    null:0  0x0            0x02000010           {EOT,A@1} // wr:1+0, rd:0; end of thread
L16040:
        nop                    
(W)     mov (16|M0)              null<1>:ud    0x9E09665A:ud                             
(W)     mov (16|M0)              null<1>:ud    0xA6E09A48:ud                             
(W)     mov (16|M0)              null<1>:ud    0x0:ud                             
(W)     mov (16|M0)              null<1>:ud    0x41:ud                             
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
