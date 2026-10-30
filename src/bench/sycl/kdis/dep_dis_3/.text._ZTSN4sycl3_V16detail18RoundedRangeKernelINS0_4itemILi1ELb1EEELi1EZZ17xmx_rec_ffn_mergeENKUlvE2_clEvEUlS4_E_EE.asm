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
(W)     mov (8|M0)               r62.0<1>:ud   r0.0<1;1,0>:ud                  
(W)     or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x4C0:uw              {A@1}
(W)     mul (1|M0)               acc0.0<1>:ud  r4.3<0;1,0>:ud    r62.2<0;1,0>:uw  {A@1}
(W)     mach (1|M0)              r3.0<1>:ud    r4.3<0;1,0>:ud    r62.1<0;1,0>:ud  {AccWrEn,$1.dst}
        mov (16|M0)              r8.0<1>:d     r1.0<1;1,0>:uw                   {$0.dst}
(W)     mov (1|M0)               r2.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (8|M0)              r10.0<1>:ud   r2.0<0;1,0>:ud    r8.0<1;1,0>:ud   {AccWrEn,Compacted,I@1}
        add (8|M0)               r12.0<1>:ud   acc0.0<1;1,0>:ud  r3.0<0;1,0>:ud  
        addc (8|M8)              r11.0<1>:ud   r2.0<0;1,0>:ud    r9.0<1;1,0>:ud   {AccWrEn}
        add (8|M8)               r13.0<1>:ud   acc0.0<1;1,0>:ud  r3.0<0;1,0>:ud  
        addc (8|M0)              r36.0<1>:ud   r10.0<1;1,0>:ud   r4.0<0;1,0>:ud   {AccWrEn,Compacted,I@4}
        add (8|M0)               r34.0<1>:ud   acc0.0<1;1,0>:ud  r12.0<1;1,0>:ud  {I@4}
        addc (8|M8)              r37.0<1>:ud   r11.0<1;1,0>:ud   r4.0<0;1,0>:ud   {AccWrEn,I@4}
        cmp (16|M0)   (lt)f0.0   null<1>:d     r36.0<1;1,0>:ud   r4.6<0;1,0>:ud   {I@1}
        add (8|M8)               r35.0<1>:ud   acc0.0<1;1,0>:ud  r13.0<1;1,0>:ud 
(f0.0)  cmp (16|M0)   (eq)f0.0   null<1>:d     r34.0<1;1,0>:d    r4.7<0;1,0>:d    {I@1}
(~f0.0) cmp (16|M0)   (lt)f0.0   null<1>:d     r34.0<1;1,0>:ud   r4.7<0;1,0>:ud  
(~f0.0) goto (16|M0)                         L21424                  L21424                
L552:
(W)     cmp (16|M0)   (eq)f0.0   null<1>:d     r5.0<0;1,0>:d     0:w               {Compacted,$2.dst}
        mov (16|M0)              r40.0<1>:f    r36.0<1;1,0>:f                   {Compacted}
        mov (16|M0)              r38.0<1>:f    r34.0<1;1,0>:f                   {Compacted}
(W)     mov (2|M0)               r7.5<1>:d     r5.2<1;1,0>:d                    {$3.dst}
(W)     mov (2|M0)               r7.3<1>:d     r5.4<1;1,0>:d                   
(W)     mov (2|M0)               r63.0<1>:d    r6.2<1;1,0>:d                   
(W)     mov (1|M0)               r7.7<1>:f     -0.0:f                               {Compacted}
(W)     mov (2|M0)               r5.2<1>:d     r6.0<1;1,0>:d                   
(W)     mov (2|M0)               r5.4<1>:d     r5.6<1;1,0>:d                   
(W)     mov (1|M0)               r5.7<1>:f     inf:f                               {Compacted,I@1}
(W)     mov (1|M0)               r5.6<1>:d     -1:w                              
L688:
        shl (16|M0)              r2.0<1>:d     r38.0<1;1,0>:d    27:w               {Compacted,F@3}
        shr (16|M0)              r8.0<1>:ud    r40.0<1;1,0>:ud   5:w              
        and (16|M0)              r52.0<1>:d    r40.0<1;1,0>:d    31:w               {Compacted}
        or (16|M0)               r50.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@2}
(~f0.0) goto (16|M0)                         L776                  L776                
L744:
        mov (16|M0)              r76.0<1>:d    -1:w                              
        goto (16|M0)                         L776                  L1144                
L776:
        join (16|M0)                         L1144                                
L792:
(W)     xor (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x30:uw              {A@1}
(W)     mov (1|M0)               r2.0<1>:f     r5.0<0;1,0>:ud                   {Compacted,A@1}
(W)     mov (1|M0)               r3.2<1>:f     0xB4C00000:f                               {Compacted}
(W)     math.inv (1|M0)          r3.1<1>:f     r2.0<0;1,0>:f                    {@2,$5}
        mov (16|M0)              r8.0<1>:f     r50.0<1;1,0>:ud                  {Compacted}
        sync.nop                             null                             {Compacted,$5.dst}
(W)     mad (1|M0)               r6.4<1>:f     r3.1<0;0>:f       r3.2<0;0>:f       r3.1<0>:f        {F@2}
(W)     mov (1|M0)               r2.1<1>:ud    r2.0<0;1,0>:f                   
        sync.nop                             null                             {Compacted,$4.src}
        mov (16|M0)              r12.0<1>:ud   r8.0<1;1,0>:f                    {F@2}
        mul (16|M0)              r10.0<1>:f    r8.0<1;1,0>:f     r6.4<0;1,0>:f    {Compacted,F@1}
(W)     add (1|M0)               r3.0<1>:d     r5.0<0;1,0>:d     -r2.1<0;1,0>:d   {Compacted,I@2}
        add (16|M0)              r12.0<1>:d    r50.0<1;1,0>:d    -r12.0<1;1,0>:d  {Compacted,I@2}
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
        add (16|M0)              r30.0<1>:d    r50.0<1;1,0>:d    -r30.0<1;1,0>:d  {Compacted,I@1}
        cmp (16|M0)   (ge)f0.1   r8.0<1>:ud    r30.0<1;1,0>:ud   r5.0<0;1,0>:ud   {I@1}
        add3 (16|M0)             r76.0<1>:d    r28.0<1;0>:d      r14.0<1;0>:d      -r8.0<1>:d       {I@1}
L1144:
        join (16|M0)                         L21424                                
L1160:
(W)     mul (8|M0)               acc0.0<1>:d   r76.0<1;1,0>:d    r5.0<0;1,0>:uw   {Compacted,I@2}
        shr (16|M0)              r8.0<1>:ud    r76.0<1;1,0>:ud   1:w              
        mach (8|M0)              r2.0<1>:d     r76.0<1;1,0>:d    r5.0<0;1,0>:d    {Compacted}
(W)     mul (8|M8)               acc0.0<1>:d   r77.0<1;1,0>:d    r5.0<0;1,0>:uw  
        mach (8|M8)              r3.0<1>:d     r77.0<1;1,0>:d    r5.0<0;1,0>:d    {Compacted}
        mul (8|M0)               acc0.0<1>:ud  r8.0<1;1,0>:ud    r5.2<0;1,0>:uw   {I@4}
        mach (8|M0)              r10.0<1>:ud   r8.0<1;1,0>:ud    r5.1<0;1,0>:ud   {AccWrEn,Compacted}
        add (16|M0)              r2.0<1>:d     r50.0<1;1,0>:d    -r2.0<1;1,0>:d   {Compacted,I@3}
        mov (8|M0)               r12.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mul (8|M8)               acc0.0<1>:ud  r9.0<1;1,0>:ud    r5.2<0;1,0>:uw  
        mach (8|M8)              r11.0<1>:ud   r9.0<1;1,0>:ud    r5.1<0;1,0>:ud   {AccWrEn}
        shr (16|M0)              r2.0<1>:ud    r2.0<1;1,0>:ud    1:w               {I@4}
        mov (8|M8)               r13.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted,$4.src}
        mov (16|M0)              r16.0<1>:f    r10.0<1;1,0>:f                   {Compacted,I@3}
        mov (16|M0)              r14.0<1>:f    r12.0<1;1,0>:f                   {Compacted,I@1}
        addc (8|M0)              r18.0<1>:ud   r14.0<1;1,0>:ud   r2.0<1;1,0>:ud   {AccWrEn,Compacted,F@1}
        shl (16|M0)              r10.0<1>:d    r52.0<1;1,0>:d    1:w               {Compacted}
        add (8|M0)               r20.0<1>:ud   acc0.0<1;1,0>:ud  r16.0<1;1,0>:ud 
        addc (8|M8)              r19.0<1>:ud   r15.0<1;1,0>:ud   r3.0<1;1,0>:ud   {AccWrEn}
        shr (16|M0)              r24.0<1>:ud   r52.0<1;1,0>:ud   31:w              
        add (8|M8)               r21.0<1>:ud   acc0.0<1;1,0>:ud  r17.0<1;1,0>:ud 
        shl (16|M0)              r22.0<1>:d    r18.0<1;1,0>:d    6:w               {Compacted,I@3}
        shl (16|M0)              r20.0<1>:d    r20.0<1;1,0>:d    6:w               {Compacted,I@2}
        shr (16|M0)              r18.0<1>:ud   r18.0<1;1,0>:ud   26:w              
        addc (8|M0)              r8.0<1>:ud    r22.0<1;1,0>:ud   r7.5<0;1,0>:ud   {AccWrEn,Compacted,I@3}
        or (16|M0)               r20.0<1>:d    r20.0<1;1,0>:d    r18.0<1;1,0>:d   {Compacted,I@2}
        add3 (8|M0)              r12.0<1>:ud   acc0.0<1;0>:ud    r20.0<1;0>:ud     r7.6<0>:ud       {I@1}
        addc (8|M8)              r9.0<1>:ud    r23.0<1;1,0>:ud   r7.5<0;1,0>:ud   {AccWrEn}
        shl (16|M0)              r22.0<1>:d    r52.0<1;1,0>:d    2:w               {Compacted}
        add3 (8|M8)              r13.0<1>:ud   acc0.0<1;0>:ud    r21.0<1;0>:ud     r7.6<0>:ud      
        addc (8|M0)              r2.0<1>:ud    r8.0<1;1,0>:ud    r10.0<1;1,0>:ud  {AccWrEn,Compacted}
        shr (16|M0)              r32.0<1>:ud   r52.0<1;1,0>:ud   30:w              
        mov (8|M0)               r14.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        addc (8|M8)              r3.0<1>:ud    r9.0<1;1,0>:ud    r11.0<1;1,0>:ud  {AccWrEn,I@6}
        add3 (8|M0)              r16.0<1>:ud   r14.0<1;0>:ud     r12.0<1;0>:ud     r24.0<1>:ud      {I@2}
        mov (8|M8)               acc0.0<1>:ud  acc0.0<1;1,0>:ud                
        mov (8|M0)               r26.1<2>:ud   r16.0<1;1,0>:ud                  {I@2}
        add3 (8|M8)              r30.0<1>:ud   acc0.0<1;0>:ud    r13.0<1;0>:ud     r25.0<1>:ud     
        mov (8|M0)               r26.0<2>:d    r2.0<1;1,0>:d                   
        mov (8|M8)               r28.1<2>:ud   r30.0<1;1,0>:ud                  {I@2}
        mov (8|M8)               r28.0<2>:d    r3.0<1;1,0>:d                   
        addc (8|M0)              r56.0<1>:ud   r22.0<1;1,0>:ud   r7.3<0;1,0>:ud   {AccWrEn,Compacted}
        send.ugm (16|M0)         r20      r26     null:0  0x0            0x08280B80           {A@2,$6} // wr:4+0, rd:2; load.ugm.d16u32.a64.ca.ca
        add3 (8|M0)              r46.0<1>:ud   acc0.0<1;0>:ud    r32.0<1;0>:ud     r7.4<0>:ud      
        addc (8|M8)              r57.0<1>:ud   r23.0<1;1,0>:ud   r7.3<0;1,0>:ud   {AccWrEn}
        add3 (8|M8)              r47.0<1>:ud   acc0.0<1;0>:ud    r33.0<1;0>:ud     r7.4<0>:ud      
        mov (16|M0)              r8.0<1>:uw    r20.0<2;1,0>:uw                  {$6.dst}
        mov (16|M0)              r124.0<1>:f   r8.0<1;1,0>:hf                   {I@1}
        shr (16|M0)              r22.0<1>:ud   r124.0<1;1,0>:ud  23:w               {F@1}
        and (16|M0)   (ne)f1.0   r54.0<1>:d    r124.0<1;1,0>:d   8388607:d              
        and (16|M0)              r88.0<1>:d    r22.0<1;1,0>:d    255:w               {Compacted,I@2}
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r88.0<1;1,0>:d    255:w               {I@1}
(~f1.0) goto (16|M0)                         L1880                  L1880                
L1848:
        mov (16|M0)              r48.0<1>:ud   0x7FC00000:ud                             
        goto (16|M0)                         L1880                  L8264                
L1880:
        join (16|M0)                         L8264                                
L1896:
        mov (8|M0)               r8.0<2>:d     r56.0<1;1,0>:d                  
        mov (8|M8)               r10.0<2>:d    r57.0<1;1,0>:d                  
        mov (8|M0)               r8.1<2>:d     r46.0<1;1,0>:d                  
        mov (8|M8)               r10.1<2>:d    r47.0<1;1,0>:d                  
        send.ugm (16|M0)         r90      r8      null:0  0x0            0x08280580           {A@1,$7} // wr:4+0, rd:2; load.ugm.d32.a64.ca.ca
        shr (16|M0)              r126.0<1>:ud  r90.0<1;1,0>:ud   23:w               {$7.dst}
        and (16|M0)   (ne)f0.1   r52.0<1>:d    r90.0<1;1,0>:d    8388607:d              
        and (16|M0)              r86.0<1>:d    r126.0<1;1,0>:d   255:w               {Compacted,I@2}
(f0.1)  cmp (16|M0)   (eq)f0.1   null<1>:d     r86.0<1;1,0>:d    255:w               {I@1}
(~f0.1) goto (16|M0)                         L2080                  L2080                
L2048:
        mov (16|M0)              r48.0<1>:ud   0x7FC00000:ud                             
        goto (16|M0)                         L2080                  L8264                
L2080:
        join (16|M0)                         L8264                                
L2096:
        cmp (16|M0)   (eq)f0.1   null<1>:d     r54.0<1;1,0>:d    0:w              
        cmp (16|M0)   (eq)f1.1   null<1>:d     r52.0<1;1,0>:d    0:w              
(f0.1)  cmp (16|M0)   (eq)f0.1   null<1>:d     r88.0<1;1,0>:d    255:w              
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r86.0<1;1,0>:d    255:w              
(W)     mov (1|M0)               r2.0<1>:hf    0x1:hf                             
        xor (16|M0)              r92.0<1>:d    r90.0<1;1,0>:d    r124.0<1;1,0>:d  {Compacted}
(f0.1)  sel (16|M0)              acc0.0<1>:uw  r2.0<0;1,0>:uw    0x0:uw              {F@1}
(f1.1)  sel (16|M0)              acc2.0<1>:uw  r2.0<0;1,0>:uw    0x0:uw             
        or (16|M0)    (ne)f0.1   null<1>:uw    acc0.0<1;1,0>:uw  acc2.0<1;1,0>:uw
(f0.1)  goto (16|M0)                         L8232                  L8232                
L2248:
        or (16|M0)    (eq)f1.1   null<1>:d     r86.0<1;1,0>:d    r52.0<1;1,0>:d  
        or (16|M0)               r2.0<1>:d     r88.0<1;1,0>:d    r54.0<1;1,0>:d   {Compacted}
(~f1.1) cmp (16|M0)   (eq)f1.1   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
(~f1.1) goto (16|M0)                         L2336                  L2336                
L2304:
        mov (16|M0)              r48.0<1>:ud   0x0:ud                             
        goto (16|M0)                         L2336                  L8264                
L2336:
        join (16|M0)                         L8232                                
L2352:
        cmp (16|M0)   (eq)f1.0   null<1>:d     r88.0<1;1,0>:d    0:w              
        cmp (16|M0)   (eq)f0.1   null<1>:d     r86.0<1;1,0>:d    0:w              
        add (16|M0)              r108.0<1>:d   r88.0<1;1,0>:d    -127:w               {Compacted}
        add (16|M0)              r106.0<1>:d   r86.0<1;1,0>:d    -127:w               {Compacted}
(f1.0)  mov (16|M0)              r108.0<1>:d   -126:w                              
(f0.1)  mov (16|M0)              r106.0<1>:d   -126:w                              
        add (16|M0)              r90.0<1>:d    r108.0<1;1,0>:d   r106.0<1;1,0>:d  {Compacted,I@1}
        cmp (16|M0)   (gt)f1.1   null<1>:d     r90.0<1;1,0>:d    127:w               {I@1}
(f1.1)  goto (16|M0)                         L8168                  L8168                
L2472:
        or (16|M0)    (eq)f1.1   null<4>:b     r22.0<1;1,0>:d    r126.0<1;1,0>:d 
(f1.1)  goto (16|M0)                         L8104                  L8104                
L2504:
(W)     mov (1|M0)               r2.0<1>:hf    0.0:hf                             
(W)     mov (1|M0)               r63.6<1>:d    0:w                              
(f1.0)  sel (16|M0)              r8.0<1>:d     r2.0<0;1,0>:w     8388608:d               {F@1}
(f0.1)  sel (16|M0)              r10.0<1>:d    r2.0<0;1,0>:w     8388608:d              
        or (16|M0)               r8.0<1>:d     r8.0<1;1,0>:d     r54.0<1;1,0>:d   {Compacted,I@2}
        or (16|M0)               r10.0<1>:d    r10.0<1;1,0>:d    r52.0<1;1,0>:d   {Compacted,I@2}
        mul (8|M0)               acc0.0<1>:ud  r8.0<1;1,0>:ud    r10.0<2;1,0>:uw  {I@1}
        mach (8|M0)              r12.0<1>:ud   r8.0<1;1,0>:ud    r10.0<1;1,0>:ud  {AccWrEn,Compacted}
(W)     mov (1|M0)               r63.3<1>:f    -0.0:f                               {Compacted}
        mov (8|M0)               r14.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mul (8|M8)               acc0.0<1>:ud  r9.0<1;1,0>:ud    r11.0<2;1,0>:uw 
        mach (8|M8)              r13.0<1>:ud   r9.0<1;1,0>:ud    r11.0<1;1,0>:ud  {AccWrEn}
(W)     mov (2|M0)               r63.4<1>:d    0:w                              
        mov (8|M8)               r15.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mov (16|M0)              r94.0<1>:f    r12.0<1;1,0>:f                   {Compacted,A@3}
        mov (16|M0)              r96.0<1>:f    r14.0<1;1,0>:f                   {Compacted,I@1}
L2696:
(W)     shl (1|M0)               r2.0<1>:d     r63.3<0;1,0>:d    31:w               {Compacted,F@3}
(W)     shr (1|M0)               r2.1<1>:ud    r63.6<0;1,0>:ud   1:w              
(W)     cmp (16|M0)   (gt)f0.1   null<1>:d     r63.4<0;1,0>:ud   0x3E:uw             
(W)     or (1|M0)                r63.6<1>:d    r2.1<0;1,0>:d     r2.0<0;1,0>:d    {I@2}
        bfn.0xA8 (16|M0)         r8.0<1>:ud    r96.0<1;0>:ud     r2.1<0;0>:ud      r2.0<0>:ud       {F@1} // s0&(s1|s2)
(W)     shr (1|M0)               r63.2<1>:ud   r63.3<0;1,0>:ud   1:w              
(W&f0.1) cmp (16|M0)  (eq)f0.1   null<1>:d     r63.5<0;1,0>:d    0:w              
        cmp (16|M0)   (eq)f1.0   null<1>:d     r8.0<1;1,0>:d     r63.6<0;1,0>:d   {I@3}
        and (16|M0)              r10.0<1>:d    r94.0<1;1,0>:d    r63.2<0;1,0>:d   {Compacted,I@3}
(W&~f0.1) cmp (16|M0) (gt)f0.1   null<1>:d     r63.5<0;1,0>:ud   0x0:uw             
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r10.0<1;1,0>:d    r63.2<0;1,0>:d   {I@2}
(W)     mov (1|M0)               r6.8<1>:hf    0x1:hf                             
(W)     addc (1|M0)              r14.0<1>:ud   r63.4<0;1,0>:ud   0x1:ud              {AccWrEn}
(f0.1)  sel (16|M0)              r12.0<1>:uw   r6.8<0;1,0>:uw    0x0:uw              {Compacted,F@1}
(f1.0)  sel (16|M0)              acc2.0<1>:uw  r6.8<0;1,0>:uw    0x0:uw             
(W)     mov (1|M0)               r3.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        or (16|M0)    (ne)f1.1   null<1>:uw    r12.0<1;1,0>:uw   acc2.0<1;1,0>:uw {I@3}
(W)     add (1|M0)               r63.7<1>:ud   r3.0<0;1,0>:ud    r63.5<0;1,0>:ud  {I@2}
        mov (16|M0)              r64.0<1>:d    r63.4<0;1,0>:d                  
        mov (16|M0)              r60.0<1>:d    r63.5<0;1,0>:d                  
        mov (16|M0)              r98.0<1>:f    r14.0<0;1,0>:f                   {Compacted}
        mov (16|M0)              r58.0<1>:d    r63.7<0;1,0>:d                   {I@3}
(f1.1)  goto (16|M0)                         L3088                  L3088                
L3024:
(W)     mov (1|M0)               r63.3<1>:d    r63.2<0;1,0>:d                  
(W)     mov (1|M0)               r63.4<1>:d    r14.0<0;1,0>:d                  
(W)     mov (1|M0)               r63.5<1>:d    r63.7<0;1,0>:d                  
(W)     jmpi                                 L2696                                
L3088:
        join (16|M0)                         L8104                                
L3104:
(W)     mov (1|M0)               r2.0<1>:f     8.68805e-44:f                              
(W)     mov (1|M0)               r3.0<1>:hf    0.0:hf                             
        subb (8|M0)              r110.0<1>:ud  r2.0<0;1,0>:ud    r64.0<1;1,0>:ud  {AccWrEn,Compacted,A@2}
        add3 (8|M0)              r20.0<1>:ud   -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r60.0<1>:ud     {A@1}
        subb (8|M8)              r111.0<1>:ud  r2.0<0;1,0>:ud    r65.0<1;1,0>:ud  {AccWrEn}
        add3 (16|M0)             r22.0<1>:d    r90.0<1;0>:d      r110.0<1;0>:d     -46:w               {I@1}
        cmp (16|M0)   (gt)f1.0   null<1>:d     r22.0<1;1,0>:d    127:w               {I@1}
        add3 (8|M8)              r21.0<1>:ud   -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r61.0<1>:ud    
        add3 (16|M0)             r18.0<1>:d    r108.0<1;0>:d     r106.0<1;0>:d     r110.0<1>:d     
(f1.0)  goto (16|M0)                         L8040                  L8040                
L3256:
        cmp (16|M0)   (gt)f0.1   null<1>:d     r22.0<1;1,0>:d    -127:w              
(f0.1)  goto (16|M0)                         L5728                  L5728                
L3288:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r22.0<1;1,0>:ud   0xFFFFFF6B:ud             
(f1.1)  goto (16|M0)                         L5224                  L5224                
L3320:
(W)     mov (1|M0)               r2.0<1>:f     8.82818e-44:f                              
(W)     mov (1|M0)               r3.0<1>:hf    0.0:hf                              {I@7}
        subb (8|M0)              r78.0<1>:ud   r2.0<0;1,0>:ud    r64.0<1;1,0>:ud  {AccWrEn,Compacted,F@2}
        add3 (16|M0)             r42.0<1>:d    r90.0<1;0>:d      r110.0<1;0>:d     104:w              
        add3 (8|M0)              r8.0<1>:ud    -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r60.0<1>:ud     {F@1}
        subb (8|M8)              r79.0<1>:ud   r2.0<0;1,0>:ud    r65.0<1;1,0>:ud  {AccWrEn}
        cmp (16|M0)   (gt)f0.1   null<1>:d     r78.0<1;1,0>:ud   r42.0<1;1,0>:ud  {I@1}
        add3 (8|M8)              r9.0<1>:ud    -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r61.0<1>:ud    
(f0.1)  cmp (16|M0)   (eq)f0.1   null<1>:d     r8.0<1;1,0>:d     0:w               {I@1}
(~f0.1) cmp (16|M0)   (gt)f0.1   null<1>:d     r8.0<1;1,0>:ud    0x0:uw             
(f0.1)  goto (16|M0)                         L3544                  L3544                
L3488:
        add3 (16|M0)             r2.0<1>:d     r18.0<1;0>:d      -r78.0<1;0>:d     104:w              
        mov (16|M0)              r82.0<1>:d    0:w                              
        shl (16|M0)              r84.0<1>:d    r96.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
        goto (16|M0)                         L3544                  L5160                
L3544:
        join (16|M0)                         L5160                                
L3560:
        add3 (16|M0)             r70.0<1>:d    r78.0<1;0>:d      -r18.0<1;0>:d     -104:w              
        cmp (16|M0)   (lt)f1.0   null<1>:d     r70.0<1;1,0>:d    2:w               {Compacted,I@1}
(f1.0)  goto (16|M0)                         L3696                  L3696                
L3600:
        cmp (16|M0)   (eq)f0.1   null<1>:d     r70.0<1;1,0>:d    2:w              
(~f0.1) goto (16|M0)                         L3696                  L3744                
L3632:
        shr (16|M0)              r24.0<1>:ud   r96.0<1;1,0>:ud   1:w              
        and (16|M0)              r72.0<1>:d    r96.0<1;1,0>:d    1:w               {Compacted}
        mov (16|M0)              r26.0<1>:d    0:w                              
        mov (16|M0)              r12.0<1>:f    r24.0<1;1,0>:f                   {Compacted,I@3}
        goto (16|M0)                         L3696                  L4632                
L3696:
        join (16|M0)                         L3744                                
L3712:
        cmp (16|M0)   (eq)f1.1   null<1>:d     r70.0<1;1,0>:d    1:w              
(f1.1)  goto (16|M0)                         L3744                  L4576                
L3744:
        join (16|M0)                         L4576                                
L3760:
        add3 (16|M0)             r2.0<1>:d     r78.0<1;0>:d      -r42.0<1;0>:d     -1:w              
        and (16|M0)   (ne)f1.0   r102.0<1>:d   r2.0<1;1,0>:d     63:w               {I@1}
(f1.0)  goto (16|M0)                         L3832                  L3832                
L3808:
        mov (16|M0)              r48.0<1>:f    r96.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L3832                  L3944                
L3832:
        join (16|M0)                         L3944                                
L3848:
        cmp (16|M0)   (lt)f0.1   null<1>:d     r102.0<1;1,0>:ud  0x20:uw              {I@4}
(~f0.1) add (16|M0)              r2.0<1>:d     r102.0<1;1,0>:d   -32:w              
(~f0.1) shr (16|M0)              r24.0<1>:ud   r94.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f0.1)  add (16|M0)              r2.0<1>:d     -r102.0<1;1,0>:d  32:w               {Compacted}
(f0.1)  shr (16|M0)              r8.0<1>:ud    r96.0<1;1,0>:ud   r102.0<1;1,0>:d 
(f0.1)  shl (16|M0)              r2.0<1>:d     r94.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f0.1)  or (16|M0)               r24.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
        mov (16|M0)              r48.0<1>:f    r24.0<1;1,0>:f                   {Compacted,I@1}
L3944:
        join (16|M0)                         L4576                                
L3960:
        add3 (16|M0)             r120.0<1>:d   r78.0<1;0>:d      -r42.0<1;0>:d     -2:w              
        and (16|M0)   (ne)f1.1   r100.0<1>:d   r120.0<1;1,0>:d   63:w               {I@1}
(f1.1)  goto (16|M0)                         L4032                  L4032                
L4008:
        mov (16|M0)              r24.0<1>:f    r96.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L4032                  L4136                
L4032:
        join (16|M0)                         L4136                                
L4048:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r100.0<1;1,0>:ud  0x20:uw              {I@4}
(~f1.0) add (16|M0)              r2.0<1>:d     r100.0<1;1,0>:d   -32:w              
(~f1.0) shr (16|M0)              r24.0<1>:ud   r94.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.0)  add (16|M0)              r2.0<1>:d     -r100.0<1;1,0>:d  32:w               {Compacted}
(f1.0)  shr (16|M0)              r8.0<1>:ud    r96.0<1;1,0>:ud   r100.0<1;1,0>:d 
(f1.0)  shl (16|M0)              r2.0<1>:d     r94.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.0)  or (16|M0)               r24.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
L4136:
        join (16|M0)                         L4576                                
L4152:
        and (16|M0)   (ne)f0.1   r86.0<1>:d    r120.0<1;1,0>:d   63:w              
        and (16|M0)              r72.0<1>:d    r24.0<1;1,0>:d    1:w               {Compacted,I@3}
(f0.1)  goto (16|M0)                         L4240                  L4240                
L4192:
        mov (16|M0)              r102.0<1>:d   -1:w                              
        mov (16|M0)              r110.0<1>:d   -1:w                              
        goto (16|M0)                         L4240                  L4424                
L4240:
        join (16|M0)                         L4424                                
L4256:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r86.0<1;1,0>:ud   0x20:uw              {I@7}
(f1.1)  goto (16|M0)                         L4360                  L4360                
L4288:
        add (16|M0)              r2.0<1>:d     r86.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r6.8<1>:hf    -qnan(0x1FF):hf                             
        mov (16|M0)              r102.0<1>:d   0:w                              
        shl (16|M0)              r110.0<1>:d   r6.8<0;1,0>:w     r2.0<1;1,0>:d    {A@1}
        goto (16|M0)                         L4360                  L4424                
L4360:
        join (16|M0)                         L4424                                
L4376:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (16|M0)              r110.0<1>:d   -1:w                              
        shl (16|M0)              r102.0<1>:d   r2.0<0;1,0>:w     r86.0<1;1,0>:d   {F@1}
L4424:
        join (16|M0)                         L4576                                
L4440:
        bfn.0x28 (16|M0)         r2.0<1>:ud    r96.0<1;0>:ud     r102.0<1;0>:ud    r5.6<0>:ud       {I@2} // s0&(s1^s2)
        cmp (16|M0)   (ne)f1.0   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
        bfn.0x28 (16|M0)         r8.0<1>:ud    r94.0<1;0>:ud     r110.0<1;0>:ud    r5.6<0>:ud       // s0&(s1^s2)
(~f1.0) cmp (16|M0)   (ne)f1.0   null<1>:d     r8.0<1;1,0>:d     0:w               {I@1}
(W)     mov (1|M0)               r6.8<1>:hf    -qnan(0x1FF):hf                             
        mov (16|M0)              r12.0<1>:f    r48.0<1;1,0>:f                   {Compacted}
(f1.0)  sel (16|M0)              r10.0<1>:d    r6.8<0;1,0>:w     0:w               {F@2}
        mov (16|M0)              r26.0<1>:d    -r10.0<1;1,0>:d                  {I@1}
        goto (16|M0)                         L4576                  L4632                
L4576:
        join (16|M0)                         L4632                                
L4592:
        mov (16|M0)              r26.0<1>:d    0:w                              
        mov (16|M0)              r72.0<1>:d    0:w                              
        mov (16|M0)              r12.0<1>:f    r96.0<1;1,0>:f                   {Compacted}
L4632:
        join (16|M0)                         L5160                                
L4648:
        and (16|M0)   (ne)f1.0   r98.0<1>:d    r70.0<1;1,0>:d    63:w              
(f1.0)  goto (16|M0)                         L4704                  L4704                
L4680:
        mov (16|M0)              r24.0<1>:f    r96.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L4704                  L4808                
L4704:
        join (16|M0)                         L4808                                
L4720:
        cmp (16|M0)   (lt)f0.1   null<1>:d     r98.0<1;1,0>:ud   0x20:uw              {I@4}
(~f0.1) add (16|M0)              r2.0<1>:d     r98.0<1;1,0>:d    -32:w              
(~f0.1) shr (16|M0)              r24.0<1>:ud   r94.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f0.1)  add (16|M0)              r2.0<1>:d     -r98.0<1;1,0>:d   32:w               {Compacted}
(f0.1)  shr (16|M0)              r8.0<1>:ud    r96.0<1;1,0>:ud   r98.0<1;1,0>:d  
(f0.1)  shl (16|M0)              r2.0<1>:d     r94.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f0.1)  or (16|M0)               r24.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
L4808:
        join (16|M0)                         L5160                                
L4824:
        shl (16|M0)              r2.0<1>:d     r12.0<1;1,0>:d    2:w               {Compacted}
        shl (16|M0)              r8.0<1>:d     r72.0<1;1,0>:d    1:w               {Compacted}
        and (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     4:w               {Compacted,I@2}
        bfn.0xFE (16|M0)         r30.0<1>:ud   r2.0<1;0>:ud      r8.0<1;0>:ud      r26.0<1>:ud      {I@1} // s0|s1|s2
        cmp (16|M0)   (eq)f1.1   null<1>:d     r30.0<1;1,0>:d    0:w               {I@1}
(~f1.1) goto (16|M0)                         L4928                  L4928                
L4896:
        mov (16|M0)              r42.0<1>:d    0:w                              
        goto (16|M0)                         L4928                  L5088                
L4928:
        join (16|M0)                         L5088                                
L4944:
        cmp (16|M0)   (gt)f1.0   null<1>:d     r30.0<1;1,0>:ud   0x4:uw             
(~f1.0) goto (16|M0)                         L5008                  L5008                
L4976:
        mov (16|M0)              r42.0<1>:d    1:w                              
        goto (16|M0)                         L5008                  L5088                
L5008:
        join (16|M0)                         L5088                                
L5024:
        and (16|M0)   (ne)f0.1   null<1>:d     r24.0<1;1,0>:d    1:w              
(W)     mov (1|M0)               r2.0<1>:hf    0x1:hf                             
(f0.1)  cmp (16|M0)   (eq)f0.1   null<1>:d     r30.0<1;1,0>:d    4:w              
(f0.1)  sel (16|M0)              r42.0<1>:d    r2.0<0;1,0>:w     0:w               {F@1}
L5088:
        join (16|M0)                         L5160                                
L5104:
        add (16|M0)              r2.0<1>:d     r42.0<1;1,0>:d    r24.0<1;1,0>:d   {Compacted,I@2}
        cmp (16|M0)   (gt)f0.1   null<1>:d     r2.0<1;1,0>:ud    0x7FFFFF:ud              {I@1}
(W)     mov (1|M0)               r6.4<1>:f     0x800000:f                               {Compacted}
(~f0.1) sel (16|M0)              r84.0<1>:d    r2.0<1;1,0>:d     0:w              
(f0.1)  sel (16|M0)              r82.0<1>:d    r6.4<0;1,0>:d     0:w               {Compacted,F@1}
L5160:
        join (16|M0)                         L5224                                
L5176:
        and (16|M0)              r2.0<1>:d     r92.0<1;1,0>:d    -2147483648:d              
        bfn.0xFE (16|M0)         r48.0<1>:ud   r2.0<1;0>:ud      r82.0<1;0>:ud     r84.0<1>:ud      {I@1} // s0|s1|s2
        goto (16|M0)                         L5224                  L8264                
L5224:
        join (16|M0)                         L5728                                
L5240:
        and (16|M0)   (ne)f0.1   r60.0<1>:d    r110.0<1;1,0>:d   63:w              
(f0.1)  goto (16|M0)                         L5320                  L5320                
L5272:
        mov (16|M0)              r74.0<1>:d    -1:w                              
        mov (16|M0)              r84.0<1>:d    -1:w                              
        goto (16|M0)                         L5320                  L5504                
L5320:
        join (16|M0)                         L5504                                
L5336:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r60.0<1;1,0>:ud   0x20:uw              {I@6}
(f1.1)  goto (16|M0)                         L5440                  L5440                
L5368:
        add (16|M0)              r2.0<1>:d     r60.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r6.8<1>:hf    -qnan(0x1FF):hf                             
        mov (16|M0)              r74.0<1>:d    0:w                              
        shl (16|M0)              r84.0<1>:d    r6.8<0;1,0>:w     r2.0<1;1,0>:d    {A@1}
        goto (16|M0)                         L5440                  L5504                
L5440:
        join (16|M0)                         L5504                                
L5456:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (16|M0)              r84.0<1>:d    -1:w                              
        shl (16|M0)              r74.0<1>:d    r2.0<0;1,0>:w     r60.0<1;1,0>:d   {F@1}
L5504:
        join (16|M0)                         L5728                                
L5520:
        bfn.0x28 (16|M0)         r2.0<1>:ud    r96.0<1;0>:ud     r74.0<1;0>:ud     r5.6<0>:ud       {I@2} // s0&(s1^s2)
        cmp (16|M0)   (ne)f1.1   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
        bfn.0x28 (16|M0)         r8.0<1>:ud    r94.0<1;0>:ud     r84.0<1;0>:ud     r5.6<0>:ud       // s0&(s1^s2)
        cmp (16|M0)   (gt)f1.0   null<1>:d     r92.0<1;1,0>:d    -1:w              
(~f1.1) cmp (16|M0)   (ne)f1.1   null<1>:d     r8.0<1;1,0>:d     0:w               {I@2}
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r22.0<1;1,0>:d    -150:w              
(f1.0)  goto (16|M0)                         L5672                  L5672                
L5632:
(W)     mov (1|M0)               r2.0<1>:ud    0x80000001:ud                             
(f1.1)  sel (16|M0)              r48.0<1>:f    r2.0<0;1,0>:f     -0.0:f               {Compacted,I@1}
        goto (16|M0)                         L5672                  L8264                
L5672:
        join (16|M0)                         L5728                                
L5688:
(W)     mov (1|M0)               r2.0<1>:ud    0x1:ud                              {F@1}
(f1.1)  sel (16|M0)              r48.0<1>:f    r2.0<0;1,0>:f     0.0:f               {Compacted,I@1}
        goto (16|M0)                         L5728                  L8264                
L5728:
        join (16|M0)                         L8040                                
L5744:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r110.0<1;1,0>:ud  0x18:uw              {F@1}
        add3 (16|M0)             r118.0<1>:d   r90.0<1;0>:d      r110.0<1;0>:d     81:w              
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r20.0<1;1,0>:d    0:w              
(f1.1)  goto (16|M0)                         L7728                  L7728                
L5808:
        shl (16|M0)              r2.0<1>:d     r98.0<1;1,0>:d    1:w               {Compacted}
        shr (16|M0)              r8.0<1>:ud    r98.0<1;1,0>:ud   31:w              
        shl (16|M0)              r10.0<1>:d    r58.0<1;1,0>:d    1:w               {Compacted}
        cmp (16|M0)   (lt)f1.1   null<1>:d     r2.0<1;1,0>:ud    0x4E:uw              {I@3}
        or (16|M0)               r10.0<1>:d    r10.0<1;1,0>:d    r8.0<1;1,0>:d    {Compacted,I@2}
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r10.0<1;1,0>:d    0:w               {I@1}
(~f1.1) cmp (16|M0)   (lt)f1.1   null<1>:d     r10.0<1;1,0>:d    0:w              
(f1.1)  goto (16|M0)                         L6040                  L6040                
L5912:
        cmp (16|M0)   (eq)f1.0   null<1>:d     r98.0<1;1,0>:d    39:w              
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r58.0<1;1,0>:d    0:w              
(~f1.0) goto (16|M0)                         L6040                  L6104                
L5960:
        shr (16|M0)              r24.0<1>:ud   r96.0<1;1,0>:ud   1:w              
        mov (16|M0)              r58.0<1>:d    0:w                              
        mov (16|M0)              r54.0<1>:d    0:w                              
        mov (16|M0)              r16.0<1>:f    r24.0<1;1,0>:f                   {Compacted,I@3}
        mov (16|M0)              r24.0<1>:f    r96.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L6040                  L7200                
L6040:
        join (16|M0)                         L6104                                
L6056:
        cmp (16|M0)   (eq)f0.1   null<1>:d     r98.0<1;1,0>:d    38:w              
(f0.1)  cmp (16|M0)   (eq)f0.1   null<1>:d     r58.0<1;1,0>:d    0:w               {I@5}
(f0.1)  goto (16|M0)                         L6104                  L7120                
L6104:
        join (16|M0)                         L7120                                
L6120:
        add (16|M0)              r2.0<1>:d     -r98.0<1;1,0>:d   39:w               {Compacted}
        and (16|M0)   (ne)f0.1   r116.0<1>:d   r2.0<1;1,0>:d     63:w               {I@1}
        add (16|M0)              r32.0<1>:d    -r98.0<1;1,0>:d   40:w               {Compacted}
(f0.1)  goto (16|M0)                         L6192                  L6192                
L6168:
        mov (16|M0)              r12.0<1>:f    r96.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L6192                  L6304                
L6192:
        join (16|M0)                         L6304                                
L6208:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r116.0<1;1,0>:ud  0x20:uw              {I@5}
(~f1.1) add (16|M0)              r2.0<1>:d     r116.0<1;1,0>:d   -32:w              
(~f1.1) shr (16|M0)              r24.0<1>:ud   r94.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.1)  add (16|M0)              r2.0<1>:d     -r116.0<1;1,0>:d  32:w               {Compacted}
(f1.1)  shr (16|M0)              r8.0<1>:ud    r96.0<1;1,0>:ud   r116.0<1;1,0>:d 
(f1.1)  shl (16|M0)              r2.0<1>:d     r94.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.1)  or (16|M0)               r24.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
        mov (16|M0)              r12.0<1>:f    r24.0<1;1,0>:f                   {Compacted,I@1}
L6304:
        join (16|M0)                         L7120                                
L6320:
        add (16|M0)              r10.0<1>:d    -r98.0<1;1,0>:d   38:w               {Compacted}
        and (16|M0)   (ne)f1.0   r122.0<1>:d   r10.0<1;1,0>:d    63:w               {I@1}
(f1.0)  goto (16|M0)                         L6384                  L6384                
L6360:
        mov (16|M0)              r24.0<1>:f    r96.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L6384                  L6488                
L6384:
        join (16|M0)                         L6488                                
L6400:
        cmp (16|M0)   (lt)f0.1   null<1>:d     r122.0<1;1,0>:ud  0x20:uw              {I@4}
(~f0.1) add (16|M0)              r2.0<1>:d     r122.0<1;1,0>:d   -32:w              
(~f0.1) shr (16|M0)              r24.0<1>:ud   r94.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f0.1)  add (16|M0)              r2.0<1>:d     -r122.0<1;1,0>:d  32:w               {Compacted}
(f0.1)  shr (16|M0)              r8.0<1>:ud    r96.0<1;1,0>:ud   r122.0<1;1,0>:d 
(f0.1)  shl (16|M0)              r2.0<1>:d     r94.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f0.1)  or (16|M0)               r24.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
L6488:
        join (16|M0)                         L7120                                
L6504:
        and (16|M0)   (ne)f1.1   r116.0<1>:d   r10.0<1;1,0>:d    63:w              
        and (16|M0)              r54.0<1>:d    r24.0<1;1,0>:d    1:w               {Compacted,I@3}
(f1.1)  goto (16|M0)                         L6592                  L6592                
L6544:
        mov (16|M0)              r122.0<1>:d   -1:w                              
        mov (16|M0)              r10.0<1>:d    -1:w                              
        goto (16|M0)                         L6592                  L6776                
L6592:
        join (16|M0)                         L6776                                
L6608:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r116.0<1;1,0>:ud  0x20:uw              {I@7}
(f1.0)  goto (16|M0)                         L6712                  L6712                
L6640:
        add (16|M0)              r2.0<1>:d     r116.0<1;1,0>:d   -32:w               {Compacted}
(W)     mov (1|M0)               r6.8<1>:hf    -qnan(0x1FF):hf                             
        mov (16|M0)              r122.0<1>:d   0:w                              
        shl (16|M0)              r10.0<1>:d    r6.8<0;1,0>:w     r2.0<1;1,0>:d    {A@1}
        goto (16|M0)                         L6712                  L6776                
L6712:
        join (16|M0)                         L6776                                
L6728:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (16|M0)              r10.0<1>:d    -1:w                              
        shl (16|M0)              r122.0<1>:d   r2.0<0;1,0>:w     r116.0<1;1,0>:d  {F@1}
L6776:
        join (16|M0)                         L7120                                
L6792:
        bfn.0x28 (16|M0)         r2.0<1>:ud    r96.0<1;0>:ud     r122.0<1;0>:ud    r5.6<0>:ud       {I@2} // s0&(s1^s2)
        cmp (16|M0)   (ne)f1.1   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
        bfn.0x28 (16|M0)         r8.0<1>:ud    r94.0<1;0>:ud     r10.0<1;0>:ud     r5.6<0>:ud       // s0&(s1^s2)
(~f1.1) cmp (16|M0)   (ne)f1.1   null<1>:d     r8.0<1;1,0>:d     0:w               {I@1}
(W)     mov (1|M0)               r6.8<1>:hf    -qnan(0x1FF):hf                             
        and (16|M0)   (ne)f0.1   r120.0<1>:d   r32.0<1;1,0>:d    63:w              
(f1.1)  sel (16|M0)              r10.0<1>:d    r6.8<0;1,0>:w     0:w               {F@1}
        mov (16|M0)              r58.0<1>:d    -r10.0<1;1,0>:d                  {I@1}
(f0.1)  goto (16|M0)                         L6960                  L6960                
L6936:
        mov (16|M0)              r24.0<1>:f    r96.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L6960                  L7064                
L6960:
        join (16|M0)                         L7064                                
L6976:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r120.0<1;1,0>:ud  0x20:uw             
(~f1.1) add (16|M0)              r2.0<1>:d     r120.0<1;1,0>:d   -32:w              
(~f1.1) shr (16|M0)              r24.0<1>:ud   r94.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.1)  add (16|M0)              r2.0<1>:d     -r120.0<1;1,0>:d  32:w               {Compacted}
(f1.1)  shr (16|M0)              r8.0<1>:ud    r96.0<1;1,0>:ud   r120.0<1;1,0>:d 
(f1.1)  shl (16|M0)              r2.0<1>:d     r94.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.1)  or (16|M0)               r24.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
L7064:
        join (16|M0)                         L7120                                
L7080:
        mov (16|M0)              r16.0<1>:f    r24.0<1;1,0>:f                   {Compacted,I@2}
        mov (16|M0)              r24.0<1>:d    r12.0<1;1,0>:d                   {F@1}
        goto (16|M0)                         L7120                  L7200                
L7120:
        join (16|M0)                         L7200                                
L7136:
        shr (16|M0)              r24.0<1>:ud   r96.0<1;1,0>:ud   2:w              
        and (16|M0)              r54.0<1>:d    r96.0<1;1,0>:d    1:w               {Compacted}
        mov (16|M0)              r58.0<1>:d    0:w                              
        mov (16|M0)              r16.0<1>:f    r24.0<1;1,0>:f                   {Compacted,I@3}
        shr (16|M0)              r24.0<1>:ud   r96.0<1;1,0>:ud   1:w               {F@1}
L7200:
        join (16|M0)                         L7728                                
L7216:
        shl (16|M0)              r2.0<1>:d     r24.0<1;1,0>:d    2:w               {Compacted,I@2}
        shl (16|M0)              r8.0<1>:d     r54.0<1;1,0>:d    1:w               {Compacted}
        and (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     4:w               {Compacted,I@2}
        bfn.0xFE (16|M0)         r72.0<1>:ud   r2.0<1;0>:ud      r8.0<1;0>:ud      r58.0<1>:ud      {I@1} // s0|s1|s2
        cmp (16|M0)   (eq)f1.0   null<1>:d     r72.0<1;1,0>:d    0:w               {I@1}
        and (16|M0)              r60.0<1>:d    r16.0<1;1,0>:d    8388607:d              
(~f1.0) goto (16|M0)                         L7336                  L7336                
L7304:
        mov (16|M0)              r58.0<1>:d    0:w                              
        goto (16|M0)                         L7336                  L7496                
L7336:
        join (16|M0)                         L7496                                
L7352:
        cmp (16|M0)   (gt)f0.1   null<1>:d     r72.0<1;1,0>:ud   0x4:uw             
(~f0.1) goto (16|M0)                         L7416                  L7416                
L7384:
        mov (16|M0)              r58.0<1>:d    1:w                              
        goto (16|M0)                         L7416                  L7496                
L7416:
        join (16|M0)                         L7496                                
L7432:
        and (16|M0)   (ne)f1.0   null<1>:d     r16.0<1;1,0>:d    1:w              
(W)     mov (1|M0)               r2.0<1>:hf    0x1:hf                             
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r72.0<1;1,0>:d    4:w              
(f1.0)  sel (16|M0)              r58.0<1>:d    r2.0<0;1,0>:w     0:w               {F@1}
L7496:
        join (16|M0)                         L7728                                
L7512:
        add (16|M0)              r106.0<1>:d   r60.0<1;1,0>:d    r58.0<1;1,0>:d   {Compacted,I@2}
        cmp (16|M0)   (gt)f0.1   null<1>:d     r106.0<1;1,0>:ud  0x7FFFFF:ud              {I@1}
        add3 (16|M0)             r2.0<1>:d     r90.0<1;0>:d      r110.0<1;0>:d     82:w              
(f0.1)  sel (16|M0)              r94.0<1>:d    r2.0<1;1,0>:d     r118.0<1;1,0>:d  {Compacted,I@1}
        cmp (16|M0)   (eq)f1.1   null<1>:d     r94.0<1;1,0>:d    255:w               {I@1}
(f1.1)  goto (16|M0)                         L7664                  L7664                
L7592:
(~f0.1) sel (16|M0)              r2.0<1>:d     r106.0<1;1,0>:d   0:w              
        and (16|M0)              r8.0<1>:d     r92.0<1;1,0>:d    -2147483648:d              
        shl (16|M0)              r10.0<1>:d    r94.0<1;1,0>:d    23:w               {Compacted}
        bfn.0xFE (16|M0)         r48.0<1>:ud   r8.0<1;0>:ud      r10.0<1;0>:ud     r2.0<1>:ud       {I@1} // s0|s1|s2
        goto (16|M0)                         L7664                  L8264                
L7664:
        join (16|M0)                         L7728                                
L7680:
        cmp (16|M0)   (gt)f1.1   null<1>:d     r92.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r2.0<1>:f     inf:f                               {Compacted,I@4}
(f1.1)  sel (16|M0)              r48.0<1>:f    r2.0<0;1,0>:f     -inf:f               {Compacted,F@1}
        goto (16|M0)                         L7728                  L8264                
L7728:
        join (16|M0)                         L8040                                
L7744:
        and (16|M0)   (ne)f1.0   r80.0<1>:d    r110.0<1;1,0>:d   63:w              
(f1.0)  goto (16|M0)                         L7808                  L7808                
L7776:
        mov (16|M0)              r50.0<1>:d    -1:w                              
        goto (16|M0)                         L7808                  L7936                
L7808:
        join (16|M0)                         L7936                                
L7824:
        cmp (16|M0)   (lt)f0.1   null<1>:d     r80.0<1;1,0>:ud   0x20:uw              {I@5}
(f0.1)  goto (16|M0)                         L7888                  L7888                
L7856:
        mov (16|M0)              r50.0<1>:d    0:w                              
        goto (16|M0)                         L7888                  L7936                
L7888:
        join (16|M0)                         L7936                                
L7904:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                             
        shl (16|M0)              r50.0<1>:d    r2.0<0;1,0>:w     r80.0<1;1,0>:d   {F@1}
L7936:
        join (16|M0)                         L8040                                
L7952:
        bfn.0x28 (16|M0)         r2.0<1>:ud    r96.0<1;0>:ud     r50.0<1;0>:ud     r5.6<0>:ud       {I@2} // s0&(s1^s2)
        add (16|M0)              r8.0<1>:d     -r110.0<1;1,0>:d  23:w               {Compacted}
        and (16|M0)              r10.0<1>:d    r92.0<1;1,0>:d    -2147483648:d              
        shl (16|M0)              r12.0<1>:d    r118.0<1;1,0>:d   23:w               {Compacted}
        shl (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     r8.0<1;1,0>:d    {Compacted,I@3}
        bfn.0xFE (16|M0)         r48.0<1>:ud   r10.0<1;0>:ud     r12.0<1;0>:ud     r2.0<1>:ud       {I@1} // s0|s1|s2
        goto (16|M0)                         L8040                  L8264                
L8040:
        join (16|M0)                         L8104                                
L8056:
        cmp (16|M0)   (gt)f1.0   null<1>:d     r92.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r2.0<1>:f     inf:f                               {Compacted,I@4}
(f1.0)  sel (16|M0)              r48.0<1>:f    r2.0<0;1,0>:f     -inf:f               {Compacted,F@1}
        goto (16|M0)                         L8104                  L8264                
L8104:
        join (16|M0)                         L8168                                
L8120:
        cmp (16|M0)   (lt)f0.1   null<1>:d     r92.0<1;1,0>:d    0:w              
(W)     mov (1|M0)               r2.0<1>:f     -0.0:f                               {Compacted}
(f0.1)  sel (16|M0)              r48.0<1>:f    r2.0<0;1,0>:f     0.0:f               {Compacted,F@1}
        goto (16|M0)                         L8168                  L8264                
L8168:
        join (16|M0)                         L8232                                
L8184:
        cmp (16|M0)   (gt)f1.1   null<1>:d     r92.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r2.0<1>:f     inf:f                               {Compacted}
(f1.1)  sel (16|M0)              r48.0<1>:f    r2.0<0;1,0>:f     -inf:f               {Compacted,F@1}
        goto (16|M0)                         L8232                  L8264                
L8232:
        join (16|M0)                         L8264                                
L8248:
        bfn.0xF8 (16|M0)         r48.0<1>:ud   r92.0<1;0>:ud     r7.7<0;0>:ud      r5.7<0>:ud       {F@1} // s0&s1|s2
L8264:
        join (16|M0)                         L21424                                
L8280:
        shl (16|M0)              r44.0<1>:d    r40.0<1;1,0>:d    1:w               {Compacted}
        addc (8|M0)              r2.0<1>:ud    r44.0<1;1,0>:ud   r5.4<0;1,0>:ud   {AccWrEn,Compacted,I@1}
        shr (16|M0)              r8.0<1>:ud    r40.0<1;1,0>:ud   31:w              
        shl (16|M0)              r10.0<1>:d    r38.0<1;1,0>:d    1:w               {Compacted}
        mov (8|M0)               r12.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        addc (8|M8)              r3.0<1>:ud    r45.0<1;1,0>:ud   r5.4<0;1,0>:ud   {AccWrEn}
        or (16|M0)               r42.0<1>:d    r10.0<1;1,0>:d    r8.0<1;1,0>:d    {Compacted,I@3}
        mov (8|M8)               r14.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        addc (8|M0)              r16.0<1>:ud   r56.0<1;1,0>:ud   0x80:ud              {AccWrEn,Compacted}
        add3 (8|M0)              r18.1<2>:ud   r12.0<1;0>:ud     r42.0<1;0>:ud     r5.5<0>:ud       {I@3}
        add3 (8|M8)              r20.1<2>:ud   r14.0<1;0>:ud     r43.0<1;0>:ud     r5.5<0>:ud       {I@3}
        mov (8|M0)               r18.0<2>:d    r2.0<1;1,0>:d                   
        mov (8|M0)               r22.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mov (8|M8)               r20.0<2>:d    r3.0<1;1,0>:d                   
        addc (8|M8)              r17.0<1>:ud   r57.0<1;1,0>:ud   0x80:ud              {AccWrEn}
        send.ugm (16|M0)         r24      r18     null:0  0x0            0x08280B80           {A@2,$8} // wr:4+0, rd:2; load.ugm.d16u32.a64.ca.ca
        mov (8|M8)               r26.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        add (8|M0)               r27.1<2>:ud   r22.0<1;1,0>:ud   r46.0<1;1,0>:ud  {Compacted}
        add (8|M8)               r29.1<2>:ud   r26.0<1;1,0>:ud   r47.0<1;1,0>:ud  {Compacted,I@2}
        mov (8|M0)               r27.0<2>:d    r16.0<1;1,0>:d                  
        mov (8|M8)               r29.0<2>:d    r17.0<1;1,0>:d                  
        shl (16|M0)              r14.0<1>:d    r40.0<1;1,0>:d    2:w               {Compacted}
        send.ugm (16|M0)         r8       r27     null:0  0x0            0x08280580           {A@2,$9} // wr:4+0, rd:2; load.ugm.d32.a64.ca.ca
        mov (16|M0)              r10.0<1>:uw   r24.0<2;1,0>:uw                  {$8.dst}
        mov (16|M0)              r12.0<1>:f    r10.0<1;1,0>:hf                  {I@1}
        addc (8|M0)              r18.0<1>:ud   r14.0<1;1,0>:ud   r5.2<0;1,0>:ud   {AccWrEn,Compacted}
        shr (16|M0)              r20.0<1>:ud   r40.0<1;1,0>:ud   30:w              
        shl (16|M0)              r22.0<1>:d    r38.0<1;1,0>:d    2:w               {Compacted}
        mov (8|M0)               r16.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        sync.nop                             null                             {Compacted,$9.dst}
        mad (16|M0)              r54.0<1>:f    r48.0<1;0>:f      r12.0<1;0>:f      r8.0<1>:f        {Compacted,F@1}
        and (16|M0)              r2.0<1>:d     r54.0<1;1,0>:d    2147483647:d               {F@1}
        sel (16|M0)   (lt)f0.0   r78.0<1>:f    r2.0<1;1,0>:f     448.0:f               {Compacted,I@1}
        shr (16|M0)              r60.0<1>:ud   r78.0<1;1,0>:ud   23:w               {F@1}
        and (16|M0)   (ne)f0.1   r58.0<1>:d    r78.0<1;1,0>:d    8388607:d              
        addc (8|M8)              r19.0<1>:ud   r15.0<1;1,0>:ud   r5.2<0;1,0>:ud   {AccWrEn}
        and (16|M0)              r48.0<1>:d    r60.0<1;1,0>:d    255:w               {Compacted,I@3}
        or (16|M0)               r22.0<1>:d    r22.0<1;1,0>:d    r20.0<1;1,0>:d   {Compacted}
        mov (8|M8)               r8.0<1>:ud    acc0.0<1;1,0>:ud                 {Compacted}
(f0.1)  cmp (16|M0)   (eq)f0.1   null<1>:d     r48.0<1;1,0>:d    255:w               {I@3}
        sel (16|M0)   (ge)f0.0   r2.0<1>:ud    r48.0<1;1,0>:ud   0x79:uw             
        add3 (8|M0)              r9.1<2>:ud    r16.0<1;0>:ud     r22.0<1;0>:ud     r5.3<0>:ud       {I@4}
        add3 (8|M8)              r11.1<2>:ud   r8.0<1;0>:ud      r23.0<1;0>:ud     r5.3<0>:ud       {I@4}
        mov (8|M0)               r9.0<2>:d     r18.0<1;1,0>:d                  
        mov (8|M8)               r11.0<2>:d    r19.0<1;1,0>:d                  
        shl (16|M0)              r68.0<1>:d    r2.0<1;1,0>:d     23:w               {Compacted,I@5}
        send.ugm (16|M0)         null     r9      r54:2   0x0            0x080E0584           {A@2,$10} // wr:4+2, rd:0; store.ugm.d32.a64.wb.wb
(~f0.1) goto (16|M0)                         L8904                  L8904                
L8872:
        mov (16|M0)              r74.0<1>:ud   0x7FC00000:ud                             
        goto (16|M0)                         L8904                  L14904                
L8904:
        join (16|M0)                         L14904                                
L8920:
        cmp (16|M0)   (eq)f1.1   null<1>:d     r58.0<1;1,0>:d    0:w              
        add (16|M0)              r104.0<1>:d   -r68.0<1;1,0>:d   -2139095040:d               {I@6}
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r48.0<1;1,0>:d    255:w              
        xor (16|M0)              r66.0<1>:d    r104.0<1;1,0>:d   r78.0<1;1,0>:d   {Compacted,I@2}
(f1.1)  goto (16|M0)                         L14872                  L14872                
L8992:
        or (16|M0)    (eq)f1.1   null<1>:d     r48.0<1;1,0>:d    r58.0<1;1,0>:d  
(~f1.1) goto (16|M0)                         L9056                  L9056                
L9024:
        mov (16|M0)              r74.0<1>:ud   0x0:ud                             
        goto (16|M0)                         L9056                  L14904                
L9056:
        join (16|M0)                         L14872                                
L9072:
        cmp (16|M0)   (eq)f1.1   null<1>:d     r48.0<1;1,0>:d    0:w              
        shr (16|M0)              r80.0<1>:ud   r104.0<1;1,0>:ud  23:w              
        add (16|M0)              r78.0<1>:d    r48.0<1;1,0>:d    -127:w               {Compacted}
(f1.1)  mov (16|M0)              r78.0<1>:d    -126:w                              
        add (16|M0)              r64.0<1>:d    r80.0<1;1,0>:d    r78.0<1;1,0>:d   {Compacted,I@1}
        cmp (16|M0)   (gt)f1.0   null<1>:d     r64.0<1;1,0>:d    254:w               {I@1}
(f1.0)  goto (16|M0)                         L14808                  L14808                
L9168:
        or (16|M0)    (eq)f0.1   null<4>:b     r60.0<1;1,0>:d    r80.0<1;1,0>:d  
(f0.1)  goto (16|M0)                         L14744                  L14744                
L9200:
(W)     mov (1|M0)               r2.0<1>:hf    0.0:hf                             
(W)     mov (1|M0)               r63.6<1>:d    0:w                              
        sync.nop                             null                             {Compacted,$10.src}
(f1.1)  sel (16|M0)              r8.0<1>:d     r2.0<0;1,0>:w     8388608:d               {F@1}
        or (16|M0)               r8.0<1>:d     r8.0<1;1,0>:d     r58.0<1;1,0>:d   {Compacted,I@1}
        shl (16|M0)              r74.0<1>:d    r8.0<1;1,0>:d     23:w               {Compacted,I@1}
        shr (16|M0)              r72.0<1>:ud   r8.0<1;1,0>:ud    9:w              
(W)     mov (1|M0)               r63.3<1>:f    -0.0:f                               {Compacted}
(W)     mov (2|M0)               r63.4<1>:d    0:w                              
L9312:
(W)     shl (1|M0)               r2.0<1>:d     r63.3<0;1,0>:d    31:w               {Compacted,F@1}
(W)     shr (1|M0)               r2.1<1>:ud    r63.6<0;1,0>:ud   1:w              
(W)     cmp (16|M0)   (gt)f1.1   null<1>:d     r63.4<0;1,0>:ud   0x3E:uw              {I@3}
(W)     or (1|M0)                r63.6<1>:d    r2.1<0;1,0>:d     r2.0<0;1,0>:d    {I@2}
        bfn.0xE0 (16|M0)         r8.0<1>:ud    r2.1<0;0>:ud      r2.0<0;0>:ud      r74.0<1>:ud      // (s0|s1)&s2
(W)     shr (1|M0)               r63.2<1>:ud   r63.3<0;1,0>:ud   1:w              
(W&f1.1) cmp (16|M0)  (eq)f1.1   null<1>:d     r63.5<0;1,0>:d    0:w              
        cmp (16|M0)   (eq)f0.1   null<1>:d     r8.0<1;1,0>:d     r63.6<0;1,0>:d   {I@3}
        and (16|M0)              r10.0<1>:d    r63.2<0;1,0>:d    r72.0<1;1,0>:d   {Compacted,I@3}
(W&~f1.1) cmp (16|M0) (gt)f1.1   null<1>:d     r63.5<0;1,0>:ud   0x0:uw             
(f0.1)  cmp (16|M0)   (eq)f0.1   null<1>:d     r10.0<1;1,0>:d    r63.2<0;1,0>:d   {I@2}
(W)     mov (1|M0)               r6.8<1>:hf    0x1:hf                             
(W)     addc (1|M0)              r14.0<1>:ud   r63.4<0;1,0>:ud   0x1:ud              {AccWrEn}
(f1.1)  sel (16|M0)              r12.0<1>:uw   r6.8<0;1,0>:uw    0x0:uw              {Compacted,F@1}
(f0.1)  sel (16|M0)              acc2.0<1>:uw  r6.8<0;1,0>:uw    0x0:uw             
(W)     mov (1|M0)               r3.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        or (16|M0)    (ne)f1.0   null<1>:uw    r12.0<1;1,0>:uw   acc2.0<1;1,0>:uw {I@3}
(W)     add (1|M0)               r63.7<1>:ud   r3.0<0;1,0>:ud    r63.5<0;1,0>:ud  {I@2}
        mov (16|M0)              r30.0<1>:d    r63.4<0;1,0>:d                  
        mov (16|M0)              r28.0<1>:d    r63.5<0;1,0>:d                  
        mov (16|M0)              r70.0<1>:f    r14.0<0;1,0>:f                   {Compacted}
        mov (16|M0)              r104.0<1>:d   r63.7<0;1,0>:d                   {I@3}
(f1.0)  goto (16|M0)                         L9704                  L9704                
L9640:
(W)     mov (1|M0)               r63.3<1>:d    r63.2<0;1,0>:d                  
(W)     mov (1|M0)               r63.4<1>:d    r14.0<0;1,0>:d                  
(W)     mov (1|M0)               r63.5<1>:d    r63.7<0;1,0>:d                  
(W)     jmpi                                 L9312                                
L9704:
        join (16|M0)                         L14744                                
L9720:
(W)     mov (1|M0)               r2.0<1>:f     8.68805e-44:f                              
(W)     mov (1|M0)               r3.0<1>:hf    0.0:hf                             
        subb (8|M0)              r76.0<1>:ud   r2.0<0;1,0>:ud    r30.0<1;1,0>:ud  {AccWrEn,Compacted,A@2}
        add3 (8|M0)              r46.0<1>:ud   -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r28.0<1>:ud     {A@1}
        subb (8|M8)              r77.0<1>:ud   r2.0<0;1,0>:ud    r31.0<1;1,0>:ud  {AccWrEn}
        add3 (16|M0)             r26.0<1>:d    r64.0<1;0>:d      r76.0<1;0>:d      -173:w               {I@1}
        cmp (16|M0)   (gt)f1.1   null<1>:d     r26.0<1;1,0>:d    127:w               {I@1}
        add3 (8|M8)              r47.0<1>:ud   -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r29.0<1>:ud    
        add3 (16|M0)             r32.0<1>:d    r80.0<1;0>:d      r78.0<1;0>:d      r76.0<1>:d      
(f1.1)  goto (16|M0)                         L14680                  L14680                
L9872:
        cmp (16|M0)   (gt)f1.0   null<1>:d     r26.0<1;1,0>:d    -127:w              
(f1.0)  goto (16|M0)                         L12360                  L12360                
L9904:
        cmp (16|M0)   (lt)f0.1   null<1>:d     r26.0<1;1,0>:ud   0xFFFFFF6B:ud             
(f0.1)  goto (16|M0)                         L11856                  L11856                
L9936:
(W)     mov (1|M0)               r2.0<1>:f     8.82818e-44:f                              
(W)     mov (1|M0)               r3.0<1>:hf    0.0:hf                              {I@7}
        subb (8|M0)              r82.0<1>:ud   r2.0<0;1,0>:ud    r30.0<1;1,0>:ud  {AccWrEn,Compacted,F@2}
        add3 (16|M0)             r50.0<1>:d    r64.0<1;0>:d      r76.0<1;0>:d      -23:w              
        add3 (8|M0)              r8.0<1>:ud    -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r28.0<1>:ud     {F@1}
        subb (8|M8)              r83.0<1>:ud   r2.0<0;1,0>:ud    r31.0<1;1,0>:ud  {AccWrEn}
        cmp (16|M0)   (gt)f1.0   null<1>:d     r82.0<1;1,0>:ud   r50.0<1;1,0>:ud  {I@1}
        add3 (8|M8)              r9.0<1>:ud    -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r29.0<1>:ud    
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r8.0<1;1,0>:d     0:w               {I@1}
(~f1.0) cmp (16|M0)   (gt)f1.0   null<1>:d     r8.0<1;1,0>:ud    0x0:uw             
(f1.0)  goto (16|M0)                         L10160                  L10160                
L10104:
        add3 (16|M0)             r2.0<1>:d     r32.0<1;0>:d      -r82.0<1;0>:d     -23:w              
        mov (16|M0)              r100.0<1>:d   0:w                              
        shl (16|M0)              r102.0<1>:d   r74.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
        goto (16|M0)                         L10160                  L11792                
L10160:
        join (16|M0)                         L11792                                
L10176:
        add3 (16|M0)             r26.0<1>:d    r82.0<1;0>:d      -r32.0<1;0>:d     23:w              
        cmp (16|M0)   (lt)f1.1   null<1>:d     r26.0<1;1,0>:d    2:w               {I@1}
(f1.1)  goto (16|M0)                         L10328                  L10328                
L10224:
        cmp (16|M0)   (eq)f1.0   null<1>:d     r26.0<1;1,0>:d    2:w              
(~f1.0) goto (16|M0)                         L10328                  L10376                
L10256:
        shr (16|M0)              r120.0<1>:ud  r74.0<1;1,0>:ud   1:w              
        mov (16|M0)              r48.0<1>:d    0:w                              
        mov (16|M0)              r76.0<1>:d    0:w                              
        mov (16|M0)              r32.0<1>:f    r120.0<1;1,0>:f                  {Compacted,I@3}
        goto (16|M0)                         L10328                  L11264                
L10328:
        join (16|M0)                         L10376                                
L10344:
        cmp (16|M0)   (eq)f0.1   null<1>:d     r26.0<1;1,0>:d    1:w              
(f0.1)  goto (16|M0)                         L10376                  L11208                
L10376:
        join (16|M0)                         L11208                                
L10392:
        add3 (16|M0)             r2.0<1>:d     r82.0<1;0>:d      -r50.0<1;0>:d     -1:w              
        and (16|M0)   (ne)f1.1   r114.0<1>:d   r2.0<1;1,0>:d     63:w               {I@1}
(f1.1)  goto (16|M0)                         L10464                  L10464                
L10440:
        mov (16|M0)              r52.0<1>:f    r74.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L10464                  L10576                
L10464:
        join (16|M0)                         L10576                                
L10480:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r114.0<1;1,0>:ud  0x20:uw              {I@4}
(~f1.0) add (16|M0)              r2.0<1>:d     r114.0<1;1,0>:d   -32:w              
(~f1.0) shr (16|M0)              r120.0<1>:ud  r72.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.0)  add (16|M0)              r2.0<1>:d     -r114.0<1;1,0>:d  32:w               {Compacted}
(f1.0)  shr (16|M0)              r8.0<1>:ud    r74.0<1;1,0>:ud   r114.0<1;1,0>:d 
(f1.0)  shl (16|M0)              r2.0<1>:d     r72.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.0)  or (16|M0)               r120.0<1>:d   r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
        mov (16|M0)              r52.0<1>:f    r120.0<1;1,0>:f                  {Compacted,I@1}
L10576:
        join (16|M0)                         L11208                                
L10592:
        add3 (16|M0)             r124.0<1>:d   r82.0<1;0>:d      -r50.0<1;0>:d     -2:w              
        and (16|M0)   (ne)f0.1   r112.0<1>:d   r124.0<1;1,0>:d   63:w               {I@1}
(f0.1)  goto (16|M0)                         L10664                  L10664                
L10640:
        mov (16|M0)              r120.0<1>:f   r74.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L10664                  L10768                
L10664:
        join (16|M0)                         L10768                                
L10680:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r112.0<1;1,0>:ud  0x20:uw              {I@4}
(~f1.1) add (16|M0)              r2.0<1>:d     r112.0<1;1,0>:d   -32:w              
(~f1.1) shr (16|M0)              r120.0<1>:ud  r72.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.1)  add (16|M0)              r2.0<1>:d     -r112.0<1;1,0>:d  32:w               {Compacted}
(f1.1)  shr (16|M0)              r8.0<1>:ud    r74.0<1;1,0>:ud   r112.0<1;1,0>:d 
(f1.1)  shl (16|M0)              r2.0<1>:d     r72.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.1)  or (16|M0)               r120.0<1>:d   r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
L10768:
        join (16|M0)                         L11208                                
L10784:
        and (16|M0)   (ne)f1.0   r108.0<1>:d   r124.0<1;1,0>:d   63:w              
        and (16|M0)              r76.0<1>:d    r120.0<1;1,0>:d   1:w               {Compacted,I@3}
(f1.0)  goto (16|M0)                         L10872                  L10872                
L10824:
        mov (16|M0)              r114.0<1>:d   -1:w                              
        mov (16|M0)              r120.0<1>:d   -1:w                              
        goto (16|M0)                         L10872                  L11056                
L10872:
        join (16|M0)                         L11056                                
L10888:
        cmp (16|M0)   (lt)f0.1   null<1>:d     r108.0<1;1,0>:ud  0x20:uw              {I@7}
(f0.1)  goto (16|M0)                         L10992                  L10992                
L10920:
        add (16|M0)              r2.0<1>:d     r108.0<1;1,0>:d   -32:w               {Compacted}
(W)     mov (1|M0)               r6.8<1>:hf    -qnan(0x1FF):hf                             
        mov (16|M0)              r114.0<1>:d   0:w                              
        shl (16|M0)              r120.0<1>:d   r6.8<0;1,0>:w     r2.0<1;1,0>:d    {A@1}
        goto (16|M0)                         L10992                  L11056                
L10992:
        join (16|M0)                         L11056                                
L11008:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (16|M0)              r120.0<1>:d   -1:w                              
        shl (16|M0)              r114.0<1>:d   r2.0<0;1,0>:w     r108.0<1;1,0>:d  {F@1}
L11056:
        join (16|M0)                         L11208                                
L11072:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r114.0<1;0>:ud    r5.6<0;0>:ud      r74.0<1>:ud      {I@2} // (s0^s1)&s2
        cmp (16|M0)   (ne)f1.0   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
        bfn.0x60 (16|M0)         r8.0<1>:ud    r120.0<1;0>:ud    r5.6<0;0>:ud      r72.0<1>:ud      // (s0^s1)&s2
(~f1.0) cmp (16|M0)   (ne)f1.0   null<1>:d     r8.0<1;1,0>:d     0:w               {I@1}
(W)     mov (1|M0)               r6.8<1>:hf    -qnan(0x1FF):hf                             
        mov (16|M0)              r32.0<1>:f    r52.0<1;1,0>:f                   {Compacted}
(f1.0)  sel (16|M0)              r10.0<1>:d    r6.8<0;1,0>:w     0:w               {F@2}
        mov (16|M0)              r48.0<1>:d    -r10.0<1;1,0>:d                  {I@1}
        goto (16|M0)                         L11208                  L11264                
L11208:
        join (16|M0)                         L11264                                
L11224:
        mov (16|M0)              r48.0<1>:d    0:w                              
        mov (16|M0)              r76.0<1>:d    0:w                              
        mov (16|M0)              r32.0<1>:f    r74.0<1;1,0>:f                   {Compacted}
L11264:
        join (16|M0)                         L11792                                
L11280:
        and (16|M0)   (ne)f1.1   r110.0<1>:d   r26.0<1;1,0>:d    63:w              
(f1.1)  goto (16|M0)                         L11336                  L11336                
L11312:
        mov (16|M0)              r120.0<1>:f   r74.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L11336                  L11440                
L11336:
        join (16|M0)                         L11440                                
L11352:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r110.0<1;1,0>:ud  0x20:uw              {I@4}
(~f1.0) add (16|M0)              r2.0<1>:d     r110.0<1;1,0>:d   -32:w              
(~f1.0) shr (16|M0)              r120.0<1>:ud  r72.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.0)  add (16|M0)              r2.0<1>:d     -r110.0<1;1,0>:d  32:w               {Compacted}
(f1.0)  shr (16|M0)              r8.0<1>:ud    r74.0<1;1,0>:ud   r110.0<1;1,0>:d 
(f1.0)  shl (16|M0)              r2.0<1>:d     r72.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.0)  or (16|M0)               r120.0<1>:d   r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
L11440:
        join (16|M0)                         L11792                                
L11456:
        shl (16|M0)              r2.0<1>:d     r32.0<1;1,0>:d    2:w               {Compacted}
        shl (16|M0)              r8.0<1>:d     r76.0<1;1,0>:d    1:w               {Compacted}
        and (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     4:w               {Compacted,I@2}
        bfn.0xFE (16|M0)         r48.0<1>:ud   r2.0<1;0>:ud      r8.0<1;0>:ud      r48.0<1>:ud      {I@1} // s0|s1|s2
        cmp (16|M0)   (eq)f0.1   null<1>:d     r48.0<1;1,0>:d    0:w               {I@1}
(~f0.1) goto (16|M0)                         L11560                  L11560                
L11528:
        mov (16|M0)              r56.0<1>:d    0:w                              
        goto (16|M0)                         L11560                  L11720                
L11560:
        join (16|M0)                         L11720                                
L11576:
        cmp (16|M0)   (gt)f1.1   null<1>:d     r48.0<1;1,0>:ud   0x4:uw             
(~f1.1) goto (16|M0)                         L11640                  L11640                
L11608:
        mov (16|M0)              r56.0<1>:d    1:w                              
        goto (16|M0)                         L11640                  L11720                
L11640:
        join (16|M0)                         L11720                                
L11656:
        and (16|M0)   (ne)f0.1   null<1>:d     r120.0<1;1,0>:d   1:w              
(W)     mov (1|M0)               r2.0<1>:hf    0x1:hf                             
(f0.1)  cmp (16|M0)   (eq)f0.1   null<1>:d     r48.0<1;1,0>:d    4:w              
(f0.1)  sel (16|M0)              r56.0<1>:d    r2.0<0;1,0>:w     0:w               {F@1}
L11720:
        join (16|M0)                         L11792                                
L11736:
        add (16|M0)              r2.0<1>:d     r56.0<1;1,0>:d    r120.0<1;1,0>:d  {Compacted,I@2}
        cmp (16|M0)   (gt)f1.1   null<1>:d     r2.0<1;1,0>:ud    0x7FFFFF:ud              {I@1}
(W)     mov (1|M0)               r6.4<1>:f     0x800000:f                               {Compacted}
(~f1.1) sel (16|M0)              r102.0<1>:d   r2.0<1;1,0>:d     0:w              
(f1.1)  sel (16|M0)              r100.0<1>:d   r6.4<0;1,0>:d     0:w               {Compacted,F@1}
L11792:
        join (16|M0)                         L11856                                
L11808:
        and (16|M0)              r2.0<1>:d     r66.0<1;1,0>:d    -2147483648:d              
        bfn.0xFE (16|M0)         r74.0<1>:ud   r2.0<1;0>:ud      r100.0<1;0>:ud    r102.0<1>:ud     {I@1} // s0|s1|s2
        goto (16|M0)                         L11856                  L14904                
L11856:
        join (16|M0)                         L12360                                
L11872:
        and (16|M0)   (ne)f1.0   r82.0<1>:d    r76.0<1;1,0>:d    63:w              
(f1.0)  goto (16|M0)                         L11952                  L11952                
L11904:
        mov (16|M0)              r100.0<1>:d   -1:w                              
        mov (16|M0)              r106.0<1>:d   -1:w                              
        goto (16|M0)                         L11952                  L12136                
L11952:
        join (16|M0)                         L12136                                
L11968:
        cmp (16|M0)   (lt)f0.1   null<1>:d     r82.0<1;1,0>:ud   0x20:uw              {I@6}
(f0.1)  goto (16|M0)                         L12072                  L12072                
L12000:
        add (16|M0)              r2.0<1>:d     r82.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r6.8<1>:hf    -qnan(0x1FF):hf                             
        mov (16|M0)              r100.0<1>:d   0:w                              
        shl (16|M0)              r106.0<1>:d   r6.8<0;1,0>:w     r2.0<1;1,0>:d    {A@1}
        goto (16|M0)                         L12072                  L12136                
L12072:
        join (16|M0)                         L12136                                
L12088:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (16|M0)              r106.0<1>:d   -1:w                              
        shl (16|M0)              r100.0<1>:d   r2.0<0;1,0>:w     r82.0<1;1,0>:d   {F@1}
L12136:
        join (16|M0)                         L12360                                
L12152:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r100.0<1;0>:ud    r5.6<0;0>:ud      r74.0<1>:ud      {I@2} // (s0^s1)&s2
        cmp (16|M0)   (ne)f1.0   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
        bfn.0x60 (16|M0)         r8.0<1>:ud    r106.0<1;0>:ud    r5.6<0;0>:ud      r72.0<1>:ud      // (s0^s1)&s2
        cmp (16|M0)   (gt)f1.1   null<1>:d     r66.0<1;1,0>:d    -1:w              
(~f1.0) cmp (16|M0)   (ne)f1.0   null<1>:d     r8.0<1;1,0>:d     0:w               {I@2}
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r26.0<1;1,0>:d    -150:w              
(f1.1)  goto (16|M0)                         L12304                  L12304                
L12264:
(W)     mov (1|M0)               r2.0<1>:ud    0x80000001:ud                             
(f1.0)  sel (16|M0)              r74.0<1>:f    r2.0<0;1,0>:f     -0.0:f               {Compacted,I@1}
        goto (16|M0)                         L12304                  L14904                
L12304:
        join (16|M0)                         L12360                                
L12320:
(W)     mov (1|M0)               r2.0<1>:ud    0x1:ud                              {F@1}
(f1.0)  sel (16|M0)              r74.0<1>:f    r2.0<0;1,0>:f     0.0:f               {Compacted,I@1}
        goto (16|M0)                         L12360                  L14904                
L12360:
        join (16|M0)                         L14680                                
L12376:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r76.0<1;1,0>:ud   0x18:uw             
        add3 (16|M0)             r112.0<1>:d   r64.0<1;0>:d      r76.0<1;0>:d      -46:w              
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r46.0<1;1,0>:d    0:w              
(f1.1)  goto (16|M0)                         L14368                  L14368                
L12440:
        shl (16|M0)              r2.0<1>:d     r70.0<1;1,0>:d    1:w               {Compacted,F@1}
        shr (16|M0)              r8.0<1>:ud    r70.0<1;1,0>:ud   31:w              
        shl (16|M0)              r10.0<1>:d    r104.0<1;1,0>:d   1:w               {Compacted}
        cmp (16|M0)   (lt)f0.1   null<1>:d     r2.0<1;1,0>:ud    0x4E:uw              {I@3}
        or (16|M0)               r10.0<1>:d    r10.0<1;1,0>:d    r8.0<1;1,0>:d    {Compacted,I@2}
(f0.1)  cmp (16|M0)   (eq)f0.1   null<1>:d     r10.0<1;1,0>:d    0:w               {I@1}
(~f0.1) cmp (16|M0)   (lt)f0.1   null<1>:d     r10.0<1;1,0>:d    0:w              
(f0.1)  goto (16|M0)                         L12672                  L12672                
L12544:
        cmp (16|M0)   (eq)f1.0   null<1>:d     r70.0<1;1,0>:d    39:w              
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r104.0<1;1,0>:d   0:w              
(~f1.0) goto (16|M0)                         L12672                  L12736                
L12592:
        shr (16|M0)              r120.0<1>:ud  r74.0<1;1,0>:ud   1:w              
        mov (16|M0)              r70.0<1>:d    0:w                              
        mov (16|M0)              r22.0<1>:d    0:w                              
        mov (16|M0)              r20.0<1>:f    r120.0<1;1,0>:f                  {Compacted,I@3}
        mov (16|M0)              r120.0<1>:f   r74.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L12672                  L13840                
L12672:
        join (16|M0)                         L12736                                
L12688:
        cmp (16|M0)   (eq)f0.1   null<1>:d     r70.0<1;1,0>:d    38:w               {I@4}
(f0.1)  cmp (16|M0)   (eq)f0.1   null<1>:d     r104.0<1;1,0>:d   0:w              
(f0.1)  goto (16|M0)                         L12736                  L13752                
L12736:
        join (16|M0)                         L13752                                
L12752:
        add (16|M0)              r2.0<1>:d     -r70.0<1;1,0>:d   39:w               {Compacted}
        and (16|M0)   (ne)f1.0   r10.0<1>:d    r2.0<1;1,0>:d     63:w               {I@1}
        add (16|M0)              r18.0<1>:d    -r70.0<1;1,0>:d   40:w               {Compacted}
(f1.0)  goto (16|M0)                         L12824                  L12824                
L12800:
        mov (16|M0)              r126.0<1>:f   r74.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L12824                  L12936                
L12824:
        join (16|M0)                         L12936                                
L12840:
        cmp (16|M0)   (lt)f0.1   null<1>:d     r10.0<1;1,0>:ud   0x20:uw              {I@5}
(~f0.1) add (16|M0)              r2.0<1>:d     r10.0<1;1,0>:d    -32:w              
(~f0.1) shr (16|M0)              r120.0<1>:ud  r72.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f0.1)  add (16|M0)              r2.0<1>:d     -r10.0<1;1,0>:d   32:w               {Compacted}
(f0.1)  shr (16|M0)              r8.0<1>:ud    r74.0<1;1,0>:ud   r10.0<1;1,0>:d  
(f0.1)  shl (16|M0)              r2.0<1>:d     r72.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f0.1)  or (16|M0)               r120.0<1>:d   r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
        mov (16|M0)              r126.0<1>:f   r120.0<1;1,0>:f                  {Compacted,I@1}
L12936:
        join (16|M0)                         L13752                                
L12952:
        add (16|M0)              r16.0<1>:d    -r70.0<1;1,0>:d   38:w               {Compacted}
        and (16|M0)   (ne)f1.1   r14.0<1>:d    r16.0<1;1,0>:d    63:w               {I@1}
(f1.1)  goto (16|M0)                         L13016                  L13016                
L12992:
        mov (16|M0)              r120.0<1>:f   r74.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L13016                  L13120                
L13016:
        join (16|M0)                         L13120                                
L13032:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r14.0<1;1,0>:ud   0x20:uw              {I@4}
(~f1.0) add (16|M0)              r2.0<1>:d     r14.0<1;1,0>:d    -32:w              
(~f1.0) shr (16|M0)              r120.0<1>:ud  r72.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.0)  add (16|M0)              r2.0<1>:d     -r14.0<1;1,0>:d   32:w               {Compacted}
(f1.0)  shr (16|M0)              r8.0<1>:ud    r74.0<1;1,0>:ud   r14.0<1;1,0>:d  
(f1.0)  shl (16|M0)              r2.0<1>:d     r72.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.0)  or (16|M0)               r120.0<1>:d   r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
L13120:
        join (16|M0)                         L13752                                
L13136:
        and (16|M0)   (ne)f0.1   r8.0<1>:d     r16.0<1;1,0>:d    63:w              
        and (16|M0)              r22.0<1>:d    r120.0<1;1,0>:d   1:w               {Compacted,I@3}
(f0.1)  goto (16|M0)                         L13224                  L13224                
L13176:
        mov (16|M0)              r24.0<1>:d    -1:w                              
        mov (16|M0)              r30.0<1>:d    -1:w                              
        goto (16|M0)                         L13224                  L13408                
L13224:
        join (16|M0)                         L13408                                
L13240:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r8.0<1;1,0>:ud    0x20:uw              {I@7}
(f1.1)  goto (16|M0)                         L13344                  L13344                
L13272:
        add (16|M0)              r2.0<1>:d     r8.0<1;1,0>:d     -32:w               {Compacted}
(W)     mov (1|M0)               r6.8<1>:hf    -qnan(0x1FF):hf                             
        mov (16|M0)              r24.0<1>:d    0:w                              
        shl (16|M0)              r30.0<1>:d    r6.8<0;1,0>:w     r2.0<1;1,0>:d    {A@1}
        goto (16|M0)                         L13344                  L13408                
L13344:
        join (16|M0)                         L13408                                
L13360:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (16|M0)              r30.0<1>:d    -1:w                              
        shl (16|M0)              r24.0<1>:d    r2.0<0;1,0>:w     r8.0<1;1,0>:d    {F@1}
L13408:
        join (16|M0)                         L13752                                
L13424:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r24.0<1;0>:ud     r5.6<0;0>:ud      r74.0<1>:ud      {I@2} // (s0^s1)&s2
        cmp (16|M0)   (ne)f1.1   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
        bfn.0x60 (16|M0)         r8.0<1>:ud    r30.0<1;0>:ud     r5.6<0;0>:ud      r72.0<1>:ud      // (s0^s1)&s2
(~f1.1) cmp (16|M0)   (ne)f1.1   null<1>:d     r8.0<1;1,0>:d     0:w               {I@1}
(W)     mov (1|M0)               r6.8<1>:hf    -qnan(0x1FF):hf                             
        and (16|M0)   (ne)f1.0   r12.0<1>:d    r18.0<1;1,0>:d    63:w              
(f1.1)  sel (16|M0)              r10.0<1>:d    r6.8<0;1,0>:w     0:w               {F@1}
        mov (16|M0)              r70.0<1>:d    -r10.0<1;1,0>:d                  {I@1}
(f1.0)  goto (16|M0)                         L13592                  L13592                
L13568:
        mov (16|M0)              r120.0<1>:f   r74.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L13592                  L13696                
L13592:
        join (16|M0)                         L13696                                
L13608:
        cmp (16|M0)   (lt)f0.1   null<1>:d     r12.0<1;1,0>:ud   0x20:uw             
(~f0.1) add (16|M0)              r2.0<1>:d     r12.0<1;1,0>:d    -32:w              
(~f0.1) shr (16|M0)              r120.0<1>:ud  r72.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f0.1)  add (16|M0)              r2.0<1>:d     -r12.0<1;1,0>:d   32:w               {Compacted}
(f0.1)  shr (16|M0)              r8.0<1>:ud    r74.0<1;1,0>:ud   r12.0<1;1,0>:d  
(f0.1)  shl (16|M0)              r2.0<1>:d     r72.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f0.1)  or (16|M0)               r120.0<1>:d   r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
L13696:
        join (16|M0)                         L13752                                
L13712:
        mov (16|M0)              r20.0<1>:f    r120.0<1;1,0>:f                  {Compacted,I@2}
        mov (16|M0)              r120.0<1>:d   r126.0<1;1,0>:d                  {F@1}
        goto (16|M0)                         L13752                  L13840                
L13752:
        join (16|M0)                         L13840                                
L13768:
        shr (16|M0)              r120.0<1>:ud  r74.0<1;1,0>:ud   2:w              
        mov (16|M0)              r70.0<1>:d    0:w                              
        mov (16|M0)              r22.0<1>:d    0:w                              
        mov (16|M0)              r20.0<1>:f    r120.0<1;1,0>:f                  {Compacted,I@3}
        shr (16|M0)              r120.0<1>:ud  r74.0<1;1,0>:ud   1:w               {F@1}
L13840:
        join (16|M0)                         L14368                                
L13856:
        shl (16|M0)              r2.0<1>:d     r120.0<1;1,0>:d   2:w               {Compacted,I@2}
        shl (16|M0)              r8.0<1>:d     r22.0<1;1,0>:d    1:w               {Compacted}
        and (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     4:w               {Compacted,I@2}
        bfn.0xFE (16|M0)         r98.0<1>:ud   r2.0<1;0>:ud      r8.0<1;0>:ud      r70.0<1>:ud      {I@1} // s0|s1|s2
        cmp (16|M0)   (eq)f1.1   null<1>:d     r98.0<1;1,0>:d    0:w               {I@1}
        and (16|M0)              r72.0<1>:d    r20.0<1;1,0>:d    8388607:d              
(~f1.1) goto (16|M0)                         L13976                  L13976                
L13944:
        mov (16|M0)              r80.0<1>:d    0:w                              
        goto (16|M0)                         L13976                  L14136                
L13976:
        join (16|M0)                         L14136                                
L13992:
        cmp (16|M0)   (gt)f1.0   null<1>:d     r98.0<1;1,0>:ud   0x4:uw             
(~f1.0) goto (16|M0)                         L14056                  L14056                
L14024:
        mov (16|M0)              r80.0<1>:d    1:w                              
        goto (16|M0)                         L14056                  L14136                
L14056:
        join (16|M0)                         L14136                                
L14072:
        and (16|M0)   (ne)f1.0   null<1>:d     r20.0<1;1,0>:d    1:w              
(W)     mov (1|M0)               r2.0<1>:hf    0x1:hf                             
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r98.0<1;1,0>:d    4:w              
(f1.0)  sel (16|M0)              r80.0<1>:d    r2.0<0;1,0>:w     0:w               {F@1}
L14136:
        join (16|M0)                         L14368                                
L14152:
        add (16|M0)              r114.0<1>:d   r72.0<1;1,0>:d    r80.0<1;1,0>:d   {Compacted,I@2}
        cmp (16|M0)   (gt)f1.1   null<1>:d     r114.0<1;1,0>:ud  0x7FFFFF:ud              {I@1}
        add3 (16|M0)             r2.0<1>:d     r64.0<1;0>:d      r76.0<1;0>:d      -45:w              
(f1.1)  sel (16|M0)              r110.0<1>:d   r2.0<1;1,0>:d     r112.0<1;1,0>:d  {Compacted,I@1}
        cmp (16|M0)   (eq)f0.1   null<1>:d     r110.0<1;1,0>:d   255:w               {I@1}
(f0.1)  goto (16|M0)                         L14304                  L14304                
L14232:
(~f1.1) sel (16|M0)              r2.0<1>:d     r114.0<1;1,0>:d   0:w              
        and (16|M0)              r8.0<1>:d     r66.0<1;1,0>:d    -2147483648:d              
        shl (16|M0)              r10.0<1>:d    r110.0<1;1,0>:d   23:w               {Compacted}
        bfn.0xFE (16|M0)         r74.0<1>:ud   r8.0<1;0>:ud      r10.0<1;0>:ud     r2.0<1>:ud       {I@1} // s0|s1|s2
        goto (16|M0)                         L14304                  L14904                
L14304:
        join (16|M0)                         L14368                                
L14320:
        cmp (16|M0)   (gt)f1.0   null<1>:d     r66.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r2.0<1>:f     inf:f                               {Compacted,I@4}
(f1.0)  sel (16|M0)              r74.0<1>:f    r2.0<0;1,0>:f     -inf:f               {Compacted,F@1}
        goto (16|M0)                         L14368                  L14904                
L14368:
        join (16|M0)                         L14680                                
L14384:
        and (16|M0)   (ne)f1.1   r98.0<1>:d    r76.0<1;1,0>:d    63:w              
(f1.1)  goto (16|M0)                         L14448                  L14448                
L14416:
        mov (16|M0)              r70.0<1>:d    -1:w                              
        goto (16|M0)                         L14448                  L14576                
L14448:
        join (16|M0)                         L14576                                
L14464:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r98.0<1;1,0>:ud   0x20:uw              {A@1}
(f1.0)  goto (16|M0)                         L14528                  L14528                
L14496:
        mov (16|M0)              r70.0<1>:d    0:w                              
        goto (16|M0)                         L14528                  L14576                
L14528:
        join (16|M0)                         L14576                                
L14544:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                             
        shl (16|M0)              r70.0<1>:d    r2.0<0;1,0>:w     r98.0<1;1,0>:d   {F@1}
L14576:
        join (16|M0)                         L14680                                
L14592:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r70.0<1;0>:ud     r5.6<0;0>:ud      r74.0<1>:ud      {I@2} // (s0^s1)&s2
        add (16|M0)              r8.0<1>:d     -r76.0<1;1,0>:d   23:w               {Compacted}
        and (16|M0)              r10.0<1>:d    r66.0<1;1,0>:d    -2147483648:d              
        shl (16|M0)              r12.0<1>:d    r112.0<1;1,0>:d   23:w               {Compacted}
        shl (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     r8.0<1;1,0>:d    {Compacted,I@3}
        bfn.0xFE (16|M0)         r74.0<1>:ud   r10.0<1;0>:ud     r12.0<1;0>:ud     r2.0<1>:ud       {I@1} // s0|s1|s2
        goto (16|M0)                         L14680                  L14904                
L14680:
        join (16|M0)                         L14744                                
L14696:
        cmp (16|M0)   (gt)f0.1   null<1>:d     r66.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r2.0<1>:f     inf:f                               {Compacted,I@4}
(f0.1)  sel (16|M0)              r74.0<1>:f    r2.0<0;1,0>:f     -inf:f               {Compacted,F@1}
        goto (16|M0)                         L14744                  L14904                
L14744:
        join (16|M0)                         L14808                                
L14760:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r66.0<1;1,0>:d    0:w              
(W)     mov (1|M0)               r2.0<1>:f     -0.0:f                               {Compacted}
(f1.1)  sel (16|M0)              r74.0<1>:f    r2.0<0;1,0>:f     0.0:f               {Compacted,F@1}
        goto (16|M0)                         L14808                  L14904                
L14808:
        join (16|M0)                         L14872                                
L14824:
        cmp (16|M0)   (gt)f1.0   null<1>:d     r66.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r2.0<1>:f     inf:f                               {Compacted}
(f1.0)  sel (16|M0)              r74.0<1>:f    r2.0<0;1,0>:f     -inf:f               {Compacted,F@1}
        goto (16|M0)                         L14872                  L14904                
L14872:
        join (16|M0)                         L14904                                
L14888:
        bfn.0xF8 (16|M0)         r74.0<1>:ud   r66.0<1;0>:ud     r7.7<0;0>:ud      r5.7<0>:ud       {F@1} // s0&s1|s2
L14904:
        join (16|M0)                         L21424                                
L14920:
        rnde (16|M0)             r96.0<1>:f    r74.0<1;1,0>:f                   {Compacted,I@2}
        shr (16|M0)              r118.0<1>:ud  r96.0<1;1,0>:ud   23:w               {F@1}
        and (16|M0)   (ne)f0.1   r20.0<1>:d    r96.0<1;1,0>:d    8388607:d              
        and (16|M0)              r84.0<1>:d    r118.0<1;1,0>:d   255:w               {Compacted,I@2}
(f0.1)  cmp (16|M0)   (eq)f0.1   null<1>:d     r84.0<1;1,0>:d    255:w               {I@1}
(~f0.1) goto (16|M0)                         L15032                  L15032                
L15000:
        mov (16|M0)              r72.0<1>:ud   0x7FC00000:ud                             
        goto (16|M0)                         L15032                  L21064                
L15032:
        join (16|M0)                         L21064                                
L15048:
        cmp (16|M0)   (eq)f1.1   null<1>:d     r20.0<1;1,0>:d    0:w              
        add (16|M0)              r2.0<1>:d     r68.0<1;1,0>:d    -25165824:d              
        shr (16|M0)              r116.0<1>:ud  r2.0<1;1,0>:ud    23:w               {I@1}
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r84.0<1;1,0>:d    255:w              
        and (16|M0)              r122.0<1>:d   r116.0<1;1,0>:d   255:w               {Compacted,I@2}
(~f1.1) cmp (16|M0)   (eq)f1.1   null<1>:d     r122.0<1;1,0>:d   255:w               {I@1}
        xor (16|M0)              r88.0<1>:d    r2.0<1;1,0>:d     r96.0<1;1,0>:d   {Compacted}
(f1.1)  goto (16|M0)                         L21032                  L21032                
L15160:
        cmp (16|M0)   (eq)f1.1   null<1>:d     r122.0<1;1,0>:d   0:w              
        or (16|M0)               r2.0<1>:d     r84.0<1;1,0>:d    r20.0<1;1,0>:d   {Compacted}
(~f1.1) cmp (16|M0)   (eq)f1.1   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
(~f1.1) goto (16|M0)                         L15248                  L15248                
L15216:
        mov (16|M0)              r72.0<1>:ud   0x0:ud                             
        goto (16|M0)                         L15248                  L21064                
L15248:
        join (16|M0)                         L21032                                
L15264:
        cmp (16|M0)   (eq)f1.0   null<1>:d     r84.0<1;1,0>:d    0:w              
        add (16|M0)              r16.0<1>:d    r84.0<1;1,0>:d    -127:w               {Compacted}
(f1.0)  mov (16|M0)              r16.0<1>:d    -126:w                              
        add (16|M0)              r86.0<1>:d    r122.0<1;1,0>:d   r16.0<1;1,0>:d   {Compacted,I@1}
        cmp (16|M0)   (gt)f0.1   null<1>:d     r86.0<1;1,0>:d    254:w               {I@1}
(f0.1)  goto (16|M0)                         L20968                  L20968                
L15344:
        or (16|M0)    (eq)f1.1   null<4>:b     r118.0<1;1,0>:d   r116.0<1;1,0>:d 
(f1.1)  goto (16|M0)                         L20912                  L20912                
L15376:
(W)     mov (1|M0)               r2.0<1>:hf    0.0:hf                             
(W)     mov (1|M0)               r63.6<1>:d    0:w                              
        sync.nop                             null                             {Compacted,$10.src}
(f1.0)  sel (16|M0)              r8.0<1>:d     r2.0<0;1,0>:w     8388608:d               {F@1}
        or (16|M0)               r8.0<1>:d     r8.0<1;1,0>:d     r20.0<1;1,0>:d   {Compacted,I@1}
        shl (16|M0)              r84.0<1>:d    r8.0<1;1,0>:d     23:w               {Compacted,I@1}
        shr (16|M0)              r82.0<1>:ud   r8.0<1;1,0>:ud    9:w              
(W)     mov (1|M0)               r63.3<1>:f    -0.0:f                               {Compacted}
(W)     mov (2|M0)               r63.4<1>:d    0:w                              
L15488:
(W)     shl (1|M0)               r2.0<1>:d     r63.3<0;1,0>:d    31:w               {Compacted,F@1}
(W)     shr (1|M0)               r2.1<1>:ud    r63.6<0;1,0>:ud   1:w              
(W)     cmp (16|M0)   (gt)f1.0   null<1>:d     r63.4<0;1,0>:ud   0x3E:uw              {I@3}
(W)     or (1|M0)                r63.6<1>:d    r2.1<0;1,0>:d     r2.0<0;1,0>:d    {I@2}
        bfn.0xE0 (16|M0)         r8.0<1>:ud    r2.1<0;0>:ud      r2.0<0;0>:ud      r84.0<1>:ud      // (s0|s1)&s2
(W)     shr (1|M0)               r63.2<1>:ud   r63.3<0;1,0>:ud   1:w              
(W&f1.0) cmp (16|M0)  (eq)f1.0   null<1>:d     r63.5<0;1,0>:d    0:w              
        cmp (16|M0)   (eq)f1.1   null<1>:d     r8.0<1;1,0>:d     r63.6<0;1,0>:d   {I@3}
        and (16|M0)              r10.0<1>:d    r63.2<0;1,0>:d    r82.0<1;1,0>:d   {Compacted,I@3}
(W&~f1.0) cmp (16|M0) (gt)f1.0   null<1>:d     r63.5<0;1,0>:ud   0x0:uw             
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r10.0<1;1,0>:d    r63.2<0;1,0>:d   {I@2}
(W)     mov (1|M0)               r6.8<1>:hf    0x1:hf                             
(W)     addc (1|M0)              r14.0<1>:ud   r63.4<0;1,0>:ud   0x1:ud              {AccWrEn}
(f1.0)  sel (16|M0)              r12.0<1>:uw   r6.8<0;1,0>:uw    0x0:uw              {Compacted,F@1}
(f1.1)  sel (16|M0)              acc2.0<1>:uw  r6.8<0;1,0>:uw    0x0:uw             
(W)     mov (1|M0)               r3.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        or (16|M0)    (ne)f0.1   null<1>:uw    r12.0<1;1,0>:uw   acc2.0<1;1,0>:uw {I@3}
(W)     add (1|M0)               r63.7<1>:ud   r3.0<0;1,0>:ud    r63.5<0;1,0>:ud  {I@2}
        mov (16|M0)              r68.0<1>:d    r63.4<0;1,0>:d                  
        mov (16|M0)              r66.0<1>:d    r63.5<0;1,0>:d                  
        mov (16|M0)              r100.0<1>:f   r14.0<0;1,0>:f                   {Compacted}
        mov (16|M0)              r116.0<1>:d   r63.7<0;1,0>:d                   {I@3}
(f0.1)  goto (16|M0)                         L15880                  L15880                
L15816:
(W)     mov (1|M0)               r63.3<1>:d    r63.2<0;1,0>:d                  
(W)     mov (1|M0)               r63.4<1>:d    r14.0<0;1,0>:d                  
(W)     mov (1|M0)               r63.5<1>:d    r63.7<0;1,0>:d                  
(W)     jmpi                                 L15488                                
L15880:
        join (16|M0)                         L20912                                
L15896:
(W)     mov (1|M0)               r2.0<1>:f     8.68805e-44:f                              
(W)     mov (1|M0)               r3.0<1>:hf    0.0:hf                             
        subb (8|M0)              r102.0<1>:ud  r2.0<0;1,0>:ud    r68.0<1;1,0>:ud  {AccWrEn,Compacted,A@2}
        add3 (8|M0)              r28.0<1>:ud   -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r66.0<1>:ud     {A@1}
        subb (8|M8)              r103.0<1>:ud  r2.0<0;1,0>:ud    r69.0<1;1,0>:ud  {AccWrEn}
        add3 (16|M0)             r24.0<1>:d    r86.0<1;0>:d      r102.0<1;0>:d     -173:w               {I@1}
        cmp (16|M0)   (gt)f1.0   null<1>:d     r24.0<1;1,0>:d    127:w               {I@1}
        add3 (8|M8)              r29.0<1>:ud   -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r67.0<1>:ud    
        add3 (16|M0)             r26.0<1>:d    r122.0<1;0>:d     r16.0<1;0>:d      r102.0<1>:d     
(f1.0)  goto (16|M0)                         L20848                  L20848                
L16048:
        cmp (16|M0)   (gt)f0.1   null<1>:d     r24.0<1;1,0>:d    -127:w              
(f0.1)  goto (16|M0)                         L18528                  L18528                
L16080:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r24.0<1;1,0>:ud   0xFFFFFF6B:ud             
(f1.1)  goto (16|M0)                         L18024                  L18024                
L16112:
(W)     mov (1|M0)               r2.0<1>:f     8.82818e-44:f                              
(W)     mov (1|M0)               r3.0<1>:hf    0.0:hf                              {I@7}
        subb (8|M0)              r80.0<1>:ud   r2.0<0;1,0>:ud    r68.0<1;1,0>:ud  {AccWrEn,Compacted,F@2}
        add3 (16|M0)             r46.0<1>:d    r86.0<1;0>:d      r102.0<1;0>:d     -23:w              
        add3 (8|M0)              r8.0<1>:ud    -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r66.0<1>:ud     {F@1}
        subb (8|M8)              r81.0<1>:ud   r2.0<0;1,0>:ud    r69.0<1;1,0>:ud  {AccWrEn}
        cmp (16|M0)   (gt)f1.0   null<1>:d     r80.0<1;1,0>:ud   r46.0<1;1,0>:ud  {I@1}
        add3 (8|M8)              r9.0<1>:ud    -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r67.0<1>:ud    
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r8.0<1;1,0>:d     0:w               {I@1}
(~f1.0) cmp (16|M0)   (gt)f1.0   null<1>:d     r8.0<1;1,0>:ud    0x0:uw             
(f1.0)  goto (16|M0)                         L16336                  L16336                
L16280:
        add3 (16|M0)             r2.0<1>:d     r26.0<1;0>:d      -r80.0<1;0>:d     -23:w              
        mov (16|M0)              r90.0<1>:d    0:w                              
        shl (16|M0)              r92.0<1>:d    r84.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
        goto (16|M0)                         L16336                  L17960                
L16336:
        join (16|M0)                         L17960                                
L16352:
        add3 (16|M0)             r50.0<1>:d    r80.0<1;0>:d      -r26.0<1;0>:d     23:w              
        cmp (16|M0)   (lt)f1.0   null<1>:d     r50.0<1;1,0>:d    2:w               {Compacted,I@1}
(f1.0)  goto (16|M0)                         L16496                  L16496                
L16392:
        cmp (16|M0)   (eq)f0.1   null<1>:d     r50.0<1;1,0>:d    2:w              
(~f0.1) goto (16|M0)                         L16496                  L16544                
L16424:
        shr (16|M0)              r20.0<1>:ud   r84.0<1;1,0>:ud   1:w              
        mov (16|M0)              r28.0<1>:d    0:w                              
        mov (16|M0)              r74.0<1>:d    0:w                              
        mov (16|M0)              r18.0<1>:f    r20.0<1;1,0>:f                   {Compacted,I@3}
        goto (16|M0)                         L16496                  L17432                
L16496:
        join (16|M0)                         L16544                                
L16512:
        cmp (16|M0)   (eq)f1.1   null<1>:d     r50.0<1;1,0>:d    1:w              
(f1.1)  goto (16|M0)                         L16544                  L17376                
L16544:
        join (16|M0)                         L17376                                
L16560:
        add3 (16|M0)             r2.0<1>:d     r80.0<1;0>:d      -r46.0<1;0>:d     -1:w              
        and (16|M0)   (ne)f1.0   r108.0<1>:d   r2.0<1;1,0>:d     63:w               {I@1}
(f1.0)  goto (16|M0)                         L16632                  L16632                
L16608:
        mov (16|M0)              r52.0<1>:f    r84.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L16632                  L16744                
L16632:
        join (16|M0)                         L16744                                
L16648:
        cmp (16|M0)   (lt)f0.1   null<1>:d     r108.0<1;1,0>:ud  0x20:uw              {I@4}
(~f0.1) add (16|M0)              r2.0<1>:d     r108.0<1;1,0>:d   -32:w              
(~f0.1) shr (16|M0)              r20.0<1>:ud   r82.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f0.1)  add (16|M0)              r2.0<1>:d     -r108.0<1;1,0>:d  32:w               {Compacted}
(f0.1)  shr (16|M0)              r8.0<1>:ud    r84.0<1;1,0>:ud   r108.0<1;1,0>:d 
(f0.1)  shl (16|M0)              r2.0<1>:d     r82.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f0.1)  or (16|M0)               r20.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
        mov (16|M0)              r52.0<1>:f    r20.0<1;1,0>:f                   {Compacted,I@1}
L16744:
        join (16|M0)                         L17376                                
L16760:
        add3 (16|M0)             r122.0<1>:d   r80.0<1;0>:d      -r46.0<1;0>:d     -2:w              
        and (16|M0)   (ne)f1.1   r106.0<1>:d   r122.0<1;1,0>:d   63:w               {I@1}
(f1.1)  goto (16|M0)                         L16832                  L16832                
L16808:
        mov (16|M0)              r20.0<1>:f    r84.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L16832                  L16936                
L16832:
        join (16|M0)                         L16936                                
L16848:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r106.0<1;1,0>:ud  0x20:uw              {I@4}
(~f1.0) add (16|M0)              r2.0<1>:d     r106.0<1;1,0>:d   -32:w              
(~f1.0) shr (16|M0)              r20.0<1>:ud   r82.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.0)  add (16|M0)              r2.0<1>:d     -r106.0<1;1,0>:d  32:w               {Compacted}
(f1.0)  shr (16|M0)              r8.0<1>:ud    r84.0<1;1,0>:ud   r106.0<1;1,0>:d 
(f1.0)  shl (16|M0)              r2.0<1>:d     r82.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.0)  or (16|M0)               r20.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
L16936:
        join (16|M0)                         L17376                                
L16952:
        and (16|M0)   (ne)f0.1   r94.0<1>:d    r122.0<1;1,0>:d   63:w              
        and (16|M0)              r74.0<1>:d    r20.0<1;1,0>:d    1:w               {Compacted,I@3}
(f0.1)  goto (16|M0)                         L17040                  L17040                
L16992:
        mov (16|M0)              r104.0<1>:d   -1:w                              
        mov (16|M0)              r112.0<1>:d   -1:w                              
        goto (16|M0)                         L17040                  L17224                
L17040:
        join (16|M0)                         L17224                                
L17056:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r94.0<1;1,0>:ud   0x20:uw              {I@7}
(f1.1)  goto (16|M0)                         L17160                  L17160                
L17088:
        add (16|M0)              r2.0<1>:d     r94.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r6.8<1>:hf    -qnan(0x1FF):hf                             
        mov (16|M0)              r104.0<1>:d   0:w                              
        shl (16|M0)              r112.0<1>:d   r6.8<0;1,0>:w     r2.0<1;1,0>:d    {A@1}
        goto (16|M0)                         L17160                  L17224                
L17160:
        join (16|M0)                         L17224                                
L17176:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (16|M0)              r112.0<1>:d   -1:w                              
        shl (16|M0)              r104.0<1>:d   r2.0<0;1,0>:w     r94.0<1;1,0>:d   {F@1}
L17224:
        join (16|M0)                         L17376                                
L17240:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r104.0<1;0>:ud    r5.6<0;0>:ud      r84.0<1>:ud      {I@2} // (s0^s1)&s2
        cmp (16|M0)   (ne)f1.0   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
        bfn.0x60 (16|M0)         r8.0<1>:ud    r112.0<1;0>:ud    r5.6<0;0>:ud      r82.0<1>:ud      // (s0^s1)&s2
(~f1.0) cmp (16|M0)   (ne)f1.0   null<1>:d     r8.0<1;1,0>:d     0:w               {I@1}
(W)     mov (1|M0)               r6.8<1>:hf    -qnan(0x1FF):hf                             
        mov (16|M0)              r18.0<1>:f    r52.0<1;1,0>:f                   {Compacted}
(f1.0)  sel (16|M0)              r10.0<1>:d    r6.8<0;1,0>:w     0:w               {F@2}
        mov (16|M0)              r28.0<1>:d    -r10.0<1;1,0>:d                  {I@1}
        goto (16|M0)                         L17376                  L17432                
L17376:
        join (16|M0)                         L17432                                
L17392:
        mov (16|M0)              r28.0<1>:d    0:w                              
        mov (16|M0)              r74.0<1>:d    0:w                              
        mov (16|M0)              r18.0<1>:f    r84.0<1;1,0>:f                   {Compacted}
L17432:
        join (16|M0)                         L17960                                
L17448:
        and (16|M0)   (ne)f1.0   r104.0<1>:d   r50.0<1;1,0>:d    63:w              
(f1.0)  goto (16|M0)                         L17504                  L17504                
L17480:
        mov (16|M0)              r20.0<1>:f    r84.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L17504                  L17608                
L17504:
        join (16|M0)                         L17608                                
L17520:
        cmp (16|M0)   (lt)f0.1   null<1>:d     r104.0<1;1,0>:ud  0x20:uw              {I@4}
(~f0.1) add (16|M0)              r2.0<1>:d     r104.0<1;1,0>:d   -32:w              
(~f0.1) shr (16|M0)              r20.0<1>:ud   r82.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f0.1)  add (16|M0)              r2.0<1>:d     -r104.0<1;1,0>:d  32:w               {Compacted}
(f0.1)  shr (16|M0)              r8.0<1>:ud    r84.0<1;1,0>:ud   r104.0<1;1,0>:d 
(f0.1)  shl (16|M0)              r2.0<1>:d     r82.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f0.1)  or (16|M0)               r20.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
L17608:
        join (16|M0)                         L17960                                
L17624:
        shl (16|M0)              r2.0<1>:d     r18.0<1;1,0>:d    2:w               {Compacted}
        shl (16|M0)              r8.0<1>:d     r74.0<1;1,0>:d    1:w               {Compacted}
        and (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     4:w               {Compacted,I@2}
        bfn.0xFE (16|M0)         r32.0<1>:ud   r2.0<1;0>:ud      r8.0<1;0>:ud      r28.0<1>:ud      {I@1} // s0|s1|s2
        cmp (16|M0)   (eq)f1.1   null<1>:d     r32.0<1;1,0>:d    0:w               {I@1}
(~f1.1) goto (16|M0)                         L17728                  L17728                
L17696:
        mov (16|M0)              r46.0<1>:d    0:w                              
        goto (16|M0)                         L17728                  L17888                
L17728:
        join (16|M0)                         L17888                                
L17744:
        cmp (16|M0)   (gt)f1.0   null<1>:d     r32.0<1;1,0>:ud   0x4:uw             
(~f1.0) goto (16|M0)                         L17808                  L17808                
L17776:
        mov (16|M0)              r46.0<1>:d    1:w                              
        goto (16|M0)                         L17808                  L17888                
L17808:
        join (16|M0)                         L17888                                
L17824:
        and (16|M0)   (ne)f0.1   null<1>:d     r20.0<1;1,0>:d    1:w              
(W)     mov (1|M0)               r2.0<1>:hf    0x1:hf                             
(f0.1)  cmp (16|M0)   (eq)f0.1   null<1>:d     r32.0<1;1,0>:d    4:w              
(f0.1)  sel (16|M0)              r46.0<1>:d    r2.0<0;1,0>:w     0:w               {F@1}
L17888:
        join (16|M0)                         L17960                                
L17904:
        add (16|M0)              r2.0<1>:d     r46.0<1;1,0>:d    r20.0<1;1,0>:d   {Compacted,I@2}
        cmp (16|M0)   (gt)f1.0   null<1>:d     r2.0<1;1,0>:ud    0x7FFFFF:ud              {I@1}
(W)     mov (1|M0)               r6.4<1>:f     0x800000:f                               {Compacted}
(~f1.0) sel (16|M0)              r92.0<1>:d    r2.0<1;1,0>:d     0:w              
(f1.0)  sel (16|M0)              r90.0<1>:d    r6.4<0;1,0>:d     0:w               {Compacted,F@1}
L17960:
        join (16|M0)                         L18024                                
L17976:
        and (16|M0)              r2.0<1>:d     r88.0<1;1,0>:d    -2147483648:d              
        bfn.0xFE (16|M0)         r72.0<1>:ud   r2.0<1;0>:ud      r90.0<1;0>:ud     r92.0<1>:ud      {I@1} // s0|s1|s2
        goto (16|M0)                         L18024                  L21064                
L18024:
        join (16|M0)                         L18528                                
L18040:
        and (16|M0)   (ne)f0.1   r66.0<1>:d    r102.0<1;1,0>:d   63:w              
(f0.1)  goto (16|M0)                         L18120                  L18120                
L18072:
        mov (16|M0)              r78.0<1>:d    -1:w                              
        mov (16|M0)              r92.0<1>:d    -1:w                              
        goto (16|M0)                         L18120                  L18304                
L18120:
        join (16|M0)                         L18304                                
L18136:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r66.0<1;1,0>:ud   0x20:uw              {I@6}
(f1.1)  goto (16|M0)                         L18240                  L18240                
L18168:
        add (16|M0)              r2.0<1>:d     r66.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r6.8<1>:hf    -qnan(0x1FF):hf                             
        mov (16|M0)              r78.0<1>:d    0:w                              
        shl (16|M0)              r92.0<1>:d    r6.8<0;1,0>:w     r2.0<1;1,0>:d    {A@1}
        goto (16|M0)                         L18240                  L18304                
L18240:
        join (16|M0)                         L18304                                
L18256:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (16|M0)              r92.0<1>:d    -1:w                              
        shl (16|M0)              r78.0<1>:d    r2.0<0;1,0>:w     r66.0<1;1,0>:d   {F@1}
L18304:
        join (16|M0)                         L18528                                
L18320:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r78.0<1;0>:ud     r5.6<0;0>:ud      r84.0<1>:ud      {I@2} // (s0^s1)&s2
        cmp (16|M0)   (ne)f0.1   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
        bfn.0x60 (16|M0)         r8.0<1>:ud    r92.0<1;0>:ud     r5.6<0;0>:ud      r82.0<1>:ud      // (s0^s1)&s2
        cmp (16|M0)   (gt)f1.0   null<1>:d     r88.0<1;1,0>:d    -1:w              
(~f0.1) cmp (16|M0)   (ne)f0.1   null<1>:d     r8.0<1;1,0>:d     0:w               {I@2}
(f0.1)  cmp (16|M0)   (eq)f0.1   null<1>:d     r24.0<1;1,0>:d    -150:w              
(f1.0)  goto (16|M0)                         L18472                  L18472                
L18432:
(W)     mov (1|M0)               r2.0<1>:ud    0x80000001:ud                             
(f0.1)  sel (16|M0)              r72.0<1>:f    r2.0<0;1,0>:f     -0.0:f               {Compacted,I@1}
        goto (16|M0)                         L18472                  L21064                
L18472:
        join (16|M0)                         L18528                                
L18488:
(W)     mov (1|M0)               r2.0<1>:ud    0x1:ud                              {F@1}
(f0.1)  sel (16|M0)              r72.0<1>:f    r2.0<0;1,0>:f     0.0:f               {Compacted,I@1}
        goto (16|M0)                         L18528                  L21064                
L18528:
        join (16|M0)                         L20848                                
L18544:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r102.0<1;1,0>:ud  0x18:uw             
        add3 (16|M0)             r114.0<1>:d   r86.0<1;0>:d      r102.0<1;0>:d     -46:w              
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r28.0<1;1,0>:d    0:w              
(f1.1)  goto (16|M0)                         L20536                  L20536                
L18608:
        shl (16|M0)              r2.0<1>:d     r100.0<1;1,0>:d   1:w               {Compacted,F@1}
        shr (16|M0)              r8.0<1>:ud    r100.0<1;1,0>:ud  31:w              
        shl (16|M0)              r10.0<1>:d    r116.0<1;1,0>:d   1:w               {Compacted}
        cmp (16|M0)   (lt)f0.1   null<1>:d     r2.0<1;1,0>:ud    0x4E:uw              {I@3}
        or (16|M0)               r10.0<1>:d    r10.0<1;1,0>:d    r8.0<1;1,0>:d    {Compacted,I@2}
(f0.1)  cmp (16|M0)   (eq)f0.1   null<1>:d     r10.0<1;1,0>:d    0:w               {I@1}
(~f0.1) cmp (16|M0)   (lt)f0.1   null<1>:d     r10.0<1;1,0>:d    0:w              
(f0.1)  goto (16|M0)                         L18840                  L18840                
L18712:
        cmp (16|M0)   (eq)f1.0   null<1>:d     r100.0<1;1,0>:d   39:w              
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r116.0<1;1,0>:d   0:w              
(~f1.0) goto (16|M0)                         L18840                  L18904                
L18760:
        shr (16|M0)              r20.0<1>:ud   r84.0<1;1,0>:ud   1:w              
        mov (16|M0)              r60.0<1>:d    0:w                              
        mov (16|M0)              r46.0<1>:d    0:w                              
        mov (16|M0)              r18.0<1>:f    r20.0<1;1,0>:f                   {Compacted,I@3}
        mov (16|M0)              r20.0<1>:f    r84.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L18840                  L20008                
L18840:
        join (16|M0)                         L18904                                
L18856:
        cmp (16|M0)   (eq)f0.1   null<1>:d     r100.0<1;1,0>:d   38:w              
(f0.1)  cmp (16|M0)   (eq)f0.1   null<1>:d     r116.0<1;1,0>:d   0:w              
(f0.1)  goto (16|M0)                         L18904                  L19920                
L18904:
        join (16|M0)                         L19920                                
L18920:
        add (16|M0)              r2.0<1>:d     -r100.0<1;1,0>:d  39:w               {Compacted}
        and (16|M0)   (ne)f0.1   r118.0<1>:d   r2.0<1;1,0>:d     63:w               {I@1}
        add (16|M0)              r14.0<1>:d    -r100.0<1;1,0>:d  40:w               {Compacted}
(f0.1)  goto (16|M0)                         L18992                  L18992                
L18968:
        mov (16|M0)              r124.0<1>:f   r84.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L18992                  L19104                
L18992:
        join (16|M0)                         L19104                                
L19008:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r118.0<1;1,0>:ud  0x20:uw              {I@5}
(~f1.1) add (16|M0)              r2.0<1>:d     r118.0<1;1,0>:d   -32:w              
(~f1.1) shr (16|M0)              r20.0<1>:ud   r82.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.1)  add (16|M0)              r2.0<1>:d     -r118.0<1;1,0>:d  32:w               {Compacted}
(f1.1)  shr (16|M0)              r8.0<1>:ud    r84.0<1;1,0>:ud   r118.0<1;1,0>:d 
(f1.1)  shl (16|M0)              r2.0<1>:d     r82.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.1)  or (16|M0)               r20.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
        mov (16|M0)              r124.0<1>:f   r20.0<1;1,0>:f                   {Compacted,I@1}
L19104:
        join (16|M0)                         L19920                                
L19120:
        add (16|M0)              r12.0<1>:d    -r100.0<1;1,0>:d  38:w               {Compacted}
        and (16|M0)   (ne)f1.0   r8.0<1>:d     r12.0<1;1,0>:d    63:w               {I@1}
(f1.0)  goto (16|M0)                         L19184                  L19184                
L19160:
        mov (16|M0)              r20.0<1>:f    r84.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L19184                  L19288                
L19184:
        join (16|M0)                         L19288                                
L19200:
        cmp (16|M0)   (lt)f0.1   null<1>:d     r8.0<1;1,0>:ud    0x20:uw              {I@4}
(~f0.1) add (16|M0)              r2.0<1>:d     r8.0<1;1,0>:d     -32:w              
(~f0.1) shr (16|M0)              r20.0<1>:ud   r82.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f0.1)  add (16|M0)              r2.0<1>:d     -r8.0<1;1,0>:d    32:w               {Compacted}
(f0.1)  shl (16|M0)              r2.0<1>:d     r82.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@1}
(f0.1)  shr (16|M0)              r8.0<1>:ud    r84.0<1;1,0>:ud   r8.0<1;1,0>:d   
(f0.1)  or (16|M0)               r20.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
L19288:
        join (16|M0)                         L19920                                
L19304:
        and (16|M0)   (ne)f1.1   r118.0<1>:d   r12.0<1;1,0>:d    63:w              
        and (16|M0)              r46.0<1>:d    r20.0<1;1,0>:d    1:w               {Compacted,I@3}
(f1.1)  goto (16|M0)                         L19392                  L19392                
L19344:
        mov (16|M0)              r126.0<1>:d   -1:w                              
        mov (16|M0)              r16.0<1>:d    -1:w                              
        goto (16|M0)                         L19392                  L19576                
L19392:
        join (16|M0)                         L19576                                
L19408:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r118.0<1;1,0>:ud  0x20:uw              {I@7}
(f1.0)  goto (16|M0)                         L19512                  L19512                
L19440:
        add (16|M0)              r2.0<1>:d     r118.0<1;1,0>:d   -32:w               {Compacted}
(W)     mov (1|M0)               r6.8<1>:hf    -qnan(0x1FF):hf                             
        mov (16|M0)              r126.0<1>:d   0:w                              
        shl (16|M0)              r16.0<1>:d    r6.8<0;1,0>:w     r2.0<1;1,0>:d    {A@1}
        goto (16|M0)                         L19512                  L19576                
L19512:
        join (16|M0)                         L19576                                
L19528:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (16|M0)              r16.0<1>:d    -1:w                              
        shl (16|M0)              r126.0<1>:d   r2.0<0;1,0>:w     r118.0<1;1,0>:d  {F@1}
L19576:
        join (16|M0)                         L19920                                
L19592:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r126.0<1;0>:ud    r5.6<0;0>:ud      r84.0<1>:ud      {I@2} // (s0^s1)&s2
        cmp (16|M0)   (ne)f1.1   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
        bfn.0x60 (16|M0)         r8.0<1>:ud    r16.0<1;0>:ud     r5.6<0;0>:ud      r82.0<1>:ud      // (s0^s1)&s2
(~f1.1) cmp (16|M0)   (ne)f1.1   null<1>:d     r8.0<1;1,0>:d     0:w               {I@1}
(W)     mov (1|M0)               r6.8<1>:hf    -qnan(0x1FF):hf                             
        and (16|M0)   (ne)f0.1   r126.0<1>:d   r14.0<1;1,0>:d    63:w              
(f1.1)  sel (16|M0)              r10.0<1>:d    r6.8<0;1,0>:w     0:w               {F@1}
        mov (16|M0)              r60.0<1>:d    -r10.0<1;1,0>:d                  {I@1}
(f0.1)  goto (16|M0)                         L19760                  L19760                
L19736:
        mov (16|M0)              r20.0<1>:f    r84.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L19760                  L19864                
L19760:
        join (16|M0)                         L19864                                
L19776:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r126.0<1;1,0>:ud  0x20:uw             
(~f1.1) add (16|M0)              r2.0<1>:d     r126.0<1;1,0>:d   -32:w              
(~f1.1) shr (16|M0)              r20.0<1>:ud   r82.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.1)  add (16|M0)              r2.0<1>:d     -r126.0<1;1,0>:d  32:w               {Compacted}
(f1.1)  shr (16|M0)              r8.0<1>:ud    r84.0<1;1,0>:ud   r126.0<1;1,0>:d 
(f1.1)  shl (16|M0)              r2.0<1>:d     r82.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.1)  or (16|M0)               r20.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
L19864:
        join (16|M0)                         L19920                                
L19880:
        mov (16|M0)              r18.0<1>:f    r20.0<1;1,0>:f                   {Compacted,I@2}
        mov (16|M0)              r20.0<1>:d    r124.0<1;1,0>:d                  {F@1}
        goto (16|M0)                         L19920                  L20008                
L19920:
        join (16|M0)                         L20008                                
L19936:
        shr (16|M0)              r20.0<1>:ud   r84.0<1;1,0>:ud   2:w              
        mov (16|M0)              r60.0<1>:d    0:w                              
        mov (16|M0)              r46.0<1>:d    0:w                              
        mov (16|M0)              r18.0<1>:f    r20.0<1;1,0>:f                   {Compacted,I@3}
        shr (16|M0)              r20.0<1>:ud   r84.0<1;1,0>:ud   1:w               {F@1}
L20008:
        join (16|M0)                         L20536                                
L20024:
        shl (16|M0)              r2.0<1>:d     r20.0<1;1,0>:d    2:w               {Compacted,I@2}
        shl (16|M0)              r8.0<1>:d     r46.0<1;1,0>:d    1:w               {Compacted}
        and (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     4:w               {Compacted,I@2}
        bfn.0xFE (16|M0)         r76.0<1>:ud   r2.0<1;0>:ud      r8.0<1;0>:ud      r60.0<1>:ud      {I@1} // s0|s1|s2
        cmp (16|M0)   (eq)f1.0   null<1>:d     r76.0<1;1,0>:d    0:w               {I@1}
        and (16|M0)              r66.0<1>:d    r18.0<1;1,0>:d    8388607:d              
(~f1.0) goto (16|M0)                         L20144                  L20144                
L20112:
        mov (16|M0)              r64.0<1>:d    0:w                              
        goto (16|M0)                         L20144                  L20304                
L20144:
        join (16|M0)                         L20304                                
L20160:
        cmp (16|M0)   (gt)f0.1   null<1>:d     r76.0<1;1,0>:ud   0x4:uw             
(~f0.1) goto (16|M0)                         L20224                  L20224                
L20192:
        mov (16|M0)              r64.0<1>:d    1:w                              
        goto (16|M0)                         L20224                  L20304                
L20224:
        join (16|M0)                         L20304                                
L20240:
        and (16|M0)   (ne)f1.0   null<1>:d     r18.0<1;1,0>:d    1:w              
(W)     mov (1|M0)               r2.0<1>:hf    0x1:hf                             
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r76.0<1;1,0>:d    4:w              
(f1.0)  sel (16|M0)              r64.0<1>:d    r2.0<0;1,0>:w     0:w               {F@1}
L20304:
        join (16|M0)                         L20536                                
L20320:
        add (16|M0)              r108.0<1>:d   r66.0<1;1,0>:d    r64.0<1;1,0>:d   {Compacted,I@2}
        cmp (16|M0)   (gt)f1.0   null<1>:d     r108.0<1;1,0>:ud  0x7FFFFF:ud              {I@1}
        add3 (16|M0)             r2.0<1>:d     r86.0<1;0>:d      r102.0<1;0>:d     -45:w              
(f1.0)  sel (16|M0)              r96.0<1>:d    r2.0<1;1,0>:d     r114.0<1;1,0>:d  {Compacted,I@1}
        cmp (16|M0)   (eq)f1.1   null<1>:d     r96.0<1;1,0>:d    255:w               {I@1}
(f1.1)  goto (16|M0)                         L20472                  L20472                
L20400:
(~f1.0) sel (16|M0)              r2.0<1>:d     r108.0<1;1,0>:d   0:w              
        and (16|M0)              r8.0<1>:d     r88.0<1;1,0>:d    -2147483648:d              
        shl (16|M0)              r10.0<1>:d    r96.0<1;1,0>:d    23:w               {Compacted}
        bfn.0xFE (16|M0)         r72.0<1>:ud   r8.0<1;0>:ud      r10.0<1;0>:ud     r2.0<1>:ud       {I@1} // s0|s1|s2
        goto (16|M0)                         L20472                  L21064                
L20472:
        join (16|M0)                         L20536                                
L20488:
        cmp (16|M0)   (gt)f0.1   null<1>:d     r88.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r2.0<1>:f     inf:f                               {Compacted,I@4}
(f0.1)  sel (16|M0)              r72.0<1>:f    r2.0<0;1,0>:f     -inf:f               {Compacted,F@1}
        goto (16|M0)                         L20536                  L21064                
L20536:
        join (16|M0)                         L20848                                
L20552:
        and (16|M0)   (ne)f1.0   r86.0<1>:d    r102.0<1;1,0>:d   63:w              
(f1.0)  goto (16|M0)                         L20616                  L20616                
L20584:
        mov (16|M0)              r52.0<1>:d    -1:w                              
        goto (16|M0)                         L20616                  L20744                
L20616:
        join (16|M0)                         L20744                                
L20632:
        cmp (16|M0)   (lt)f0.1   null<1>:d     r86.0<1;1,0>:ud   0x20:uw              {A@1}
(f0.1)  goto (16|M0)                         L20696                  L20696                
L20664:
        mov (16|M0)              r52.0<1>:d    0:w                              
        goto (16|M0)                         L20696                  L20744                
L20696:
        join (16|M0)                         L20744                                
L20712:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                             
        shl (16|M0)              r52.0<1>:d    r2.0<0;1,0>:w     r86.0<1;1,0>:d   {F@1}
L20744:
        join (16|M0)                         L20848                                
L20760:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r52.0<1;0>:ud     r5.6<0;0>:ud      r84.0<1>:ud      {I@2} // (s0^s1)&s2
        add (16|M0)              r8.0<1>:d     -r102.0<1;1,0>:d  23:w               {Compacted}
        and (16|M0)              r10.0<1>:d    r88.0<1;1,0>:d    -2147483648:d              
        shl (16|M0)              r12.0<1>:d    r114.0<1;1,0>:d   23:w               {Compacted}
        shl (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     r8.0<1;1,0>:d    {Compacted,I@3}
        bfn.0xFE (16|M0)         r72.0<1>:ud   r10.0<1;0>:ud     r12.0<1;0>:ud     r2.0<1>:ud       {I@1} // s0|s1|s2
        goto (16|M0)                         L20848                  L21064                
L20848:
        join (16|M0)                         L20912                                
L20864:
        cmp (16|M0)   (gt)f1.1   null<1>:d     r88.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r2.0<1>:f     inf:f                               {Compacted,I@4}
(f1.1)  sel (16|M0)              r72.0<1>:f    r2.0<0;1,0>:f     -inf:f               {Compacted,F@1}
        goto (16|M0)                         L20912                  L21064                
L20912:
        join (16|M0)                         L20968                                
L20928:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r88.0<1;1,0>:d    0:w               {Compacted}
(W)     mov (1|M0)               r2.0<1>:f     -0.0:f                               {Compacted}
(f1.0)  sel (16|M0)              r72.0<1>:f    r2.0<0;1,0>:f     0.0:f               {Compacted,F@1}
        goto (16|M0)                         L20968                  L21064                
L20968:
        join (16|M0)                         L21032                                
L20984:
        cmp (16|M0)   (gt)f0.1   null<1>:d     r88.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r2.0<1>:f     inf:f                               {Compacted}
(f0.1)  sel (16|M0)              r72.0<1>:f    r2.0<0;1,0>:f     -inf:f               {Compacted,F@1}
        goto (16|M0)                         L21032                  L21064                
L21032:
        join (16|M0)                         L21064                                
L21048:
        bfn.0xF8 (16|M0)         r72.0<1>:ud   r88.0<1;0>:ud     r7.7<0;0>:ud      r5.7<0>:ud       {F@1} // s0&s1|s2
L21064:
        join (16|M0)                         L21424                                
L21080:
        addc (8|M0)              r10.0<1>:ud   r44.0<1;1,0>:ud   r63.0<0;1,0>:ud  {AccWrEn,Compacted,$10.src}
        cmp (16|M0)   (lt)f1.1   null<1>:f     r54.0<1;1,0>:f    0.0:f              
        mov (8|M0)               r12.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        addc (8|M8)              r11.0<1>:ud   r45.0<1;1,0>:ud   r63.0<0;1,0>:ud  {AccWrEn}
(f1.1)  sel (16|M0)              r2.0<1>:f     -r72.0<1;1,0>:f   r72.0<1;1,0>:f   {Compacted,I@5}
        mov (8|M8)               r18.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        addc (8|M0)              r28.0<1>:ud   r40.0<1;1,0>:ud   r7.0<0;1,0>:ud   {AccWrEn,Compacted}
        mov (8|M0)               r8.0<1>:hf    r2.0<1;1,0>:f                    {F@1}
        add (8|M0)               r90.0<1>:ud   acc0.0<1;1,0>:ud  r38.0<1;1,0>:ud 
        addc (8|M8)              r29.0<1>:ud   r41.0<1;1,0>:ud   r7.0<0;1,0>:ud   {AccWrEn}
        mov (8|M8)               r8.8<1>:hf    r3.0<1;1,0>:f                   
        cmp (16|M0)   (lt)f1.1   null<1>:d     r28.0<1;1,0>:ud   r4.6<0;1,0>:ud   {I@1}
        add (8|M8)               r91.0<1>:ud   acc0.0<1;1,0>:ud  r39.0<1;1,0>:ud 
        add3 (8|M0)              r13.1<2>:ud   r12.0<1;0>:ud     r42.0<1;0>:ud     r63.1<0>:ud     
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r90.0<1;1,0>:d    r4.7<0;1,0>:d    {I@2}
        add3 (8|M8)              r15.1<2>:ud   r18.0<1;0>:ud     r43.0<1;0>:ud     r63.1<0>:ud     
        mov (16|M0)              r20.0<1>:ud   r8.0<1;1,0>:uw                   {A@1}
(~f1.1) cmp (16|M0)   (lt)f1.1   null<1>:d     r90.0<1;1,0>:ud   r4.7<0;1,0>:ud  
        mov (8|M0)               r13.0<2>:d    r10.0<1;1,0>:d                  
        mov (8|M8)               r15.0<2>:d    r11.0<1;1,0>:d                  
        send.ugm (16|M0)         null     r13     r20:2   0x0            0x080E0B84           {A@1,$4} // wr:4+2, rd:0; store.ugm.d16u32.a64.wb.wb
(~f1.1) goto (16|M0)                         L21424                  L21424                
L21392:
(f1.1)  sel (16|M0)              r40.0<1>:d    r28.0<1;1,0>:d    r36.0<1;1,0>:d   {Compacted}
(f1.1)  sel (16|M0)              r38.0<1>:d    r90.0<1;1,0>:d    r34.0<1;1,0>:d   {Compacted}
(W)     jmpi                                 L688                                
L21424:
        join (16|M0)                         L21440                                
L21440:
(W)     mov (8|M0)               r127.0<1>:f   r62.0<1;1,0>:f                   {Compacted,$3.src}
(W)     send.gtwy (1|M0)         null     r127    null:0  0x0            0x02000010           {EOT,A@1} // wr:1+0, rd:0; end of thread
L21464:
        nop                    
(W)     mov (16|M0)              null<1>:ud    0x9E09665A:ud                             
(W)     mov (16|M0)              null<1>:ud    0xA6E09A48:ud                             
(W)     mov (16|M0)              null<1>:ud    0x0:ud                             
(W)     mov (16|M0)              null<1>:ud    0x33:ud                             
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
