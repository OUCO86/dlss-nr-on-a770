L0:
(W)     mov (8|M0)               r127.0<1>:ud  0x0:ud                             
(W)     and (1|M0)               r127.2<1>:ud  r0.0<0;1,0>:ud    0xFFFFFFC0:ud             
(W)     and (1|M0)               r127.0<1>:uw  r0.4<0;1,0>:uw    0xFF:uw             
(W)     add (1|M0)               r127.2<1>:ud  r127.2<0;1,0>:ud  0x80:ud              {I@2}
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
(W)     send.dc0 (8|M0)          r5       r127    null:0  0x0            0x024844FD           {A@1,$2} // wr:1h+0, rd:4; oword aligned block read x8
(W)     mov (8|M0)               r94.0<1>:ud   r0.0<1;1,0>:ud                  
(W)     or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x4C0:uw              {A@1}
(W)     mul (1|M0)               acc0.0<1>:ud  r4.3<0;1,0>:ud    r94.2<0;1,0>:uw  {A@1}
(W)     mach (1|M0)              r3.0<1>:ud    r4.3<0;1,0>:ud    r94.1<0;1,0>:ud  {AccWrEn,$1.dst}
        mov (16|M0)              r10.0<1>:d    r1.0<1;1,0>:uw                   {$0.dst}
(W)     mov (1|M0)               r2.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (8|M0)              r12.0<1>:ud   r2.0<0;1,0>:ud    r10.0<1;1,0>:ud  {AccWrEn,Compacted,I@1}
        add (8|M0)               r14.0<1>:ud   acc0.0<1;1,0>:ud  r3.0<0;1,0>:ud  
        addc (8|M8)              r13.0<1>:ud   r2.0<0;1,0>:ud    r11.0<1;1,0>:ud  {AccWrEn}
        add (8|M8)               r15.0<1>:ud   acc0.0<1;1,0>:ud  r3.0<0;1,0>:ud  
        addc (8|M0)              r30.0<1>:ud   r12.0<1;1,0>:ud   r4.0<0;1,0>:ud   {AccWrEn,Compacted,I@4}
        add (8|M0)               r28.0<1>:ud   acc0.0<1;1,0>:ud  r14.0<1;1,0>:ud  {I@4}
        addc (8|M8)              r31.0<1>:ud   r13.0<1;1,0>:ud   r4.0<0;1,0>:ud   {AccWrEn,I@4}
        cmp (16|M0)   (lt)f1.1   null<1>:d     r30.0<1;1,0>:ud   r4.6<0;1,0>:ud   {I@1}
        add (8|M8)               r29.0<1>:ud   acc0.0<1;1,0>:ud  r15.0<1;1,0>:ud 
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r28.0<1;1,0>:d    r4.7<0;1,0>:d    {I@1}
(~f1.1) cmp (16|M0)   (lt)f1.1   null<1>:d     r28.0<1;1,0>:ud   r4.7<0;1,0>:ud  
(~f1.1) goto (16|M0)                         L28248                  L28248                
L520:
(W)     cmp (16|M0)   (eq)f0.0   null<1>:d     r6.0<0;1,0>:d     0:w               {Compacted,$2.dst}
        mov (16|M0)              r60.0<1>:f    r30.0<1;1,0>:f                   {Compacted}
        mov (16|M0)              r58.0<1>:f    r28.0<1;1,0>:f                   {Compacted}
(W)     mov (2|M0)               r8.6<1>:f     r5.6<1;1,0>:f                   
(W)     mov (2|M0)               r7.6<1>:d     r6.6<1;1,0>:d                   
(W)     mov (2|M0)               r8.3<1>:d     r7.4<1;1,0>:d                   
(W)     mov (1|M0)               r95.2<1>:uw   f0.0<0;1,0>:uw                   {Compacted}
(W)     mov (2|M0)               r6.5<1>:d     r7.2<1;1,0>:d                   
L616:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r60.0<1;1,0>:ud   r5.0<0;1,0>:ud   {F@3}
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r58.0<1;1,0>:d    0:w               {F@2}
(~f1.0) goto (16|M0)                         L28080                  L28080                
L664:
        mul (8|M0)               acc0.0<1>:ud  r60.0<1;1,0>:ud   r6.0<0;1,0>:uw  
        mach (8|M0)              r2.0<1>:ud    r60.0<1;1,0>:ud   r6.0<0;1,0>:ud   {AccWrEn,Compacted,$3.src}
        shl (16|M0)              r48.0<1>:d    r60.0<1;1,0>:d    2:w               {Compacted}
        mov (8|M0)               r10.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mul (8|M8)               acc0.0<1>:ud  r61.0<1;1,0>:ud   r6.0<0;1,0>:uw  
        mach (8|M8)              r3.0<1>:ud    r61.0<1;1,0>:ud   r6.0<0;1,0>:ud   {AccWrEn}
(W)     mov (1|M0)               f1.1<1>:uw    r95.2<0;1,0>:uw                  {I@7}
        mov (8|M8)               r11.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted,$4.src}
(W)     mul (8|M0)               acc0.0<1>:d   r6.0<0;1,0>:ud    r58.0<2;1,0>:uw 
        mach (8|M0)              r14.0<1>:d    r6.0<0;1,0>:ud    r58.0<1;1,0>:d  
(W)     mul (8|M8)               acc0.0<1>:d   r6.0<0;1,0>:ud    r59.0<2;1,0>:uw 
        mach (8|M8)              r15.0<1>:d    r6.0<0;1,0>:ud    r59.0<1;1,0>:d  
        mov (16|M0)              r12.0<1>:f    r10.0<1;1,0>:f                   {Compacted,A@5}
        add (16|M0)              r16.0<1>:d    r2.0<1;1,0>:d     r14.0<1;1,0>:d   {Compacted,I@1}
        shl (16|M0)              r18.0<1>:d    r12.0<1;1,0>:d    2:w               {Compacted,F@1}
        shr (16|M0)              r20.0<1>:ud   r12.0<1;1,0>:ud   30:w              
        shl (16|M0)              r22.0<1>:d    r16.0<1;1,0>:d    2:w               {Compacted,I@3}
        addc (8|M0)              r56.0<1>:ud   r18.0<1;1,0>:ud   r8.6<0;1,0>:ud   {AccWrEn,Compacted,I@3}
        or (16|M0)               r22.0<1>:d    r22.0<1;1,0>:d    r20.0<1;1,0>:d   {Compacted,I@2}
        add3 (8|M0)              r54.0<1>:ud   acc0.0<1;0>:ud    r22.0<1;0>:ud     r8.7<0>:ud       {I@1}
        addc (8|M8)              r57.0<1>:ud   r19.0<1;1,0>:ud   r8.6<0;1,0>:ud   {AccWrEn}
        shl (16|M0)              r10.0<1>:d    r58.0<1;1,0>:d    2:w               {Compacted}
        add3 (8|M8)              r55.0<1>:ud   acc0.0<1;0>:ud    r23.0<1;0>:ud     r8.7<0>:ud      
        addc (8|M0)              r52.0<1>:ud   r12.0<1;1,0>:ud   r7.6<0;1,0>:ud   {AccWrEn,Compacted}
        shr (16|M0)              r2.0<1>:ud    r60.0<1;1,0>:ud   30:w              
        add3 (8|M0)              r50.0<1>:ud   acc0.0<1;0>:ud    r16.0<1;0>:ud     r7.7<0>:ud      
        addc (8|M8)              r53.0<1>:ud   r13.0<1;1,0>:ud   r7.6<0;1,0>:ud   {AccWrEn}
        or (16|M0)               r46.0<1>:d    r10.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@3}
        add3 (8|M8)              r51.0<1>:ud   acc0.0<1;0>:ud    r17.0<1;0>:ud     r7.7<0>:ud      
        addc (8|M0)              r102.0<1>:ud  r48.0<1;1,0>:ud   r7.0<0;1,0>:ud   {AccWrEn,Compacted}
        add3 (8|M0)              r100.0<1>:ud  acc0.0<1;0>:ud    r46.0<1;0>:ud     r7.1<0>:ud       {I@3}
        addc (8|M8)              r103.0<1>:ud  r49.0<1;1,0>:ud   r7.0<0;1,0>:ud   {AccWrEn}
        add3 (8|M8)              r101.0<1>:ud  acc0.0<1;0>:ud    r47.0<1;0>:ud     r7.1<0>:ud      
(~f1.1) goto (16|M0)                         L1128                  L1128                
L1096:
        mov (16|M0)              r44.0<1>:ud   0x0:ud                             
        goto (16|M0)                         L1128                  L27944                
L1128:
        join (16|M0)                         L27944                                
L1144:
        mov (8|M0)               r9.0<2>:d     r102.0<1;1,0>:d                  {I@7}
        mov (8|M8)               r11.0<2>:d    r103.0<1;1,0>:d                  {I@7}
        mov (8|M0)               r9.1<2>:d     r100.0<1;1,0>:d                 
        mov (8|M8)               r11.1<2>:d    r101.0<1;1,0>:d                  {I@7}
(W)     mov (1|M0)               r5.2<1>:hf    0.0:hf                             
        send.ugm (16|M0)         r42      r9      null:0  0x0            0x08280580           {A@1,$5} // wr:4+0, rd:2; load.ugm.d32.a64.ca.ca
        mov (16|M0)              r24.0<1>:f    0.0:f                               {Compacted}
(W)     mov (1|M0)               r6.4<1>:f     -0.0:f                               {Compacted}
(W)     mov (1|M0)               r6.3<1>:f     inf:f                               {Compacted}
(W)     mov (1|M0)               r6.2<1>:d     -1:w                              
(W)     mov (1|M0)               r6.1<1>:d     0:w                              
        and (16|M0)   (ne)f1.0   r14.0<1>:d    r42.0<1;1,0>:d    8388607:d               {$5.dst}
        shr (16|M0)              r40.0<1>:ud   r42.0<1;1,0>:ud   23:w              
(W)     mov (1|M0)               r95.0<1>:uw   f1.0<0;1,0>:uw                   {Compacted}
        and (16|M0)   (eq)f0.1   r2.0<1>:d     r40.0<1;1,0>:d    255:w               {I@2}
(W)     mov (1|M0)               f0.0<1>:uw    r95.0<0;1,0>:uw                  {I@2}
        or (16|M0)    (eq)f1.1   r38.0<1>:d    r2.0<1;1,0>:d     r14.0<1;1,0>:d   {I@2}
(f0.0)  cmp (16|M0)   (eq)f0.0   null<1>:d     r2.0<1;1,0>:d     255:w              
        add (16|M0)              r10.0<1>:d    r2.0<1;1,0>:d     -127:w               {Compacted}
(W)     mov (1|M0)               r95.0<1>:uw   f0.0<0;1,0>:uw                   {Compacted}
        cmp (16|M0)   (eq)f0.0   null<1>:d     r14.0<1;1,0>:d    0:w               {Compacted}
(f0.1)  sel (16|M0)              r12.0<1>:d    r5.2<0;1,0>:w     8388608:d               {F@4}
(~f0.1) sel (16|M0)              r36.0<1>:d    r10.0<1;1,0>:d    -126:w               {I@4}
(f0.0)  cmp (16|M0)   (eq)f0.0   null<1>:d     r2.0<1;1,0>:d     255:w              
        or (16|M0)               r34.0<1>:d    r12.0<1;1,0>:d    r14.0<1;1,0>:d   {Compacted,I@3}
(W)     mov (1|M0)               r95.1<1>:uw   f1.1<0;1,0>:uw                   {Compacted}
L1488:
(W)     shl (1|M0)               r8.5<1>:d     r6.1<0;1,0>:d     2:w              
(W)     shr (1|M0)               r6.7<1>:ud    r6.1<0;1,0>:ud    30:w              
        addc (8|M0)              r2.0<1>:ud    r56.0<1;1,0>:ud   r8.5<0;1,0>:ud   {AccWrEn,Compacted,I@2}
(W)     mov (1|M0)               f1.0<1>:uw    r95.0<0;1,0>:uw                 
        mov (8|M0)               r10.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        addc (8|M8)              r3.0<1>:ud    r57.0<1;1,0>:ud   r8.5<0;1,0>:ud   {AccWrEn}
        add3 (8|M0)              r11.1<2>:ud   r10.0<1;0>:ud     r54.0<1;0>:ud     r6.7<0>:ud       {I@2}
        mov (8|M8)               r16.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mov (8|M0)               r11.0<2>:d    r2.0<1;1,0>:d                   
        add3 (8|M8)              r13.1<2>:ud   r16.0<1;0>:ud     r55.0<1;0>:ud     r6.7<0>:ud       {I@2}
        mov (8|M8)               r13.0<2>:d    r3.0<1;1,0>:d                   
(W)     mov (1|M0)               r5.2<1>:hf    0x1:hf                             
        send.ugm (16|M0)         r18      r11     null:0  0x0            0x08280580           {A@1,$6} // wr:4+0, rd:2; load.ugm.d32.a64.ca.ca
(f1.0)  sel (16|M0)              acc0.0<1>:uw  r5.2<0;1,0>:uw    0x0:uw              {F@1}
        mov (16|M0)              r16.0<1>:f    r18.0<1;1,0>:d                   {Compacted,$6.dst}
        shr (16|M0)              r22.0<1>:ud   r16.0<1;1,0>:ud   23:w               {F@1}
        and (16|M0)   (ne)f0.1   r14.0<1>:d    r16.0<1;1,0>:d    8388607:d              
        and (16|M0)              r86.0<1>:d    r22.0<1;1,0>:d    255:w               {Compacted,I@2}
(f0.1)  cmp (16|M0)   (eq)f0.1   null<1>:d     r86.0<1;1,0>:d    255:w               {I@1}
(f0.1)  sel (16|M0)              acc2.0<1>:uw  r5.2<0;1,0>:uw    0x0:uw             
        or (16|M0)    (ne)f0.1   null<1>:uw    acc2.0<1;1,0>:uw  acc0.0<1;1,0>:uw
(~f0.1) goto (16|M0)                         L1832                  L1832                
L1800:
        mov (16|M0)              r92.0<1>:ud   0x7FC00000:ud                             
        goto (16|M0)                         L1832                  L7976                
L1832:
        join (16|M0)                         L7976                                
L1848:
        cmp (16|M0)   (eq)f1.1   null<1>:d     r14.0<1;1,0>:d    0:w              
(W)     mov (1|M0)               r2.0<1>:hf    0x1:hf                             
        xor (16|M0)              r74.0<1>:d    r42.0<1;1,0>:d    r16.0<1;1,0>:d   {Compacted}
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r86.0<1;1,0>:d    255:w              
(f0.0)  sel (16|M0)              acc0.0<1>:uw  r2.0<0;1,0>:uw    0x0:uw              {F@1}
(f1.1)  sel (16|M0)              acc2.0<1>:uw  r2.0<0;1,0>:uw    0x0:uw             
        or (16|M0)    (ne)f1.1   null<1>:uw    acc2.0<1;1,0>:uw  acc0.0<1;1,0>:uw
(f1.1)  goto (16|M0)                         L7944                  L7944                
L1968:
        or (16|M0)    (eq)f1.1   null<1>:d     r86.0<1;1,0>:d    r14.0<1;1,0>:d  
(W)     mov (1|M0)               f0.1<1>:uw    r95.1<0;1,0>:uw                 
(W)     mov (1|M0)               r2.0<1>:hf    0x1:hf                              {I@5}
(f1.1)  sel (16|M0)              acc0.0<1>:uw  r2.0<0;1,0>:uw    0x0:uw              {F@1}
(f0.1)  sel (16|M0)              acc2.0<1>:uw  r2.0<0;1,0>:uw    0x0:uw             
        or (16|M0)    (ne)f1.1   null<1>:uw    acc0.0<1;1,0>:uw  acc2.0<1;1,0>:uw
(~f1.1) goto (16|M0)                         L2112                  L2112                
L2080:
        mov (16|M0)              r92.0<1>:ud   0x0:ud                             
        goto (16|M0)                         L2112                  L7976                
L2112:
        join (16|M0)                         L7944                                
L2128:
        cmp (16|M0)   (eq)f1.1   null<1>:d     r86.0<1;1,0>:d    0:w              
        add (16|M0)              r72.0<1>:d    r86.0<1;1,0>:d    -127:w               {Compacted}
(f1.1)  mov (16|M0)              r72.0<1>:d    -126:w                              
        add (16|M0)              r70.0<1>:d    r72.0<1;1,0>:d    r36.0<1;1,0>:d   {Compacted,I@1}
        cmp (16|M0)   (gt)f1.0   null<1>:d     r70.0<1;1,0>:d    127:w               {I@1}
(f1.0)  goto (16|M0)                         L7880                  L7880                
L2208:
        or (16|M0)    (eq)f0.1   null<4>:b     r22.0<1;1,0>:d    r40.0<1;1,0>:d  
(f0.1)  goto (16|M0)                         L7824                  L7824                
L2240:
(W)     mov (1|M0)               r2.0<1>:hf    0.0:hf                             
(W)     mov (1|M0)               r95.6<1>:d    0:w                              
(f1.1)  sel (16|M0)              r10.0<1>:d    r2.0<0;1,0>:w     8388608:d               {F@1}
        or (16|M0)               r10.0<1>:d    r10.0<1;1,0>:d    r14.0<1;1,0>:d   {Compacted,I@1}
        mul (8|M0)               acc0.0<1>:ud  r10.0<1;1,0>:ud   r34.0<2;1,0>:uw  {I@1}
        mach (8|M0)              r12.0<1>:ud   r10.0<1;1,0>:ud   r34.0<1;1,0>:ud  {AccWrEn,Compacted}
(W)     mov (1|M0)               r95.3<1>:f    -0.0:f                               {Compacted}
        mov (8|M0)               r14.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mul (8|M8)               acc0.0<1>:ud  r11.0<1;1,0>:ud   r35.0<2;1,0>:uw 
        mach (8|M8)              r13.0<1>:ud   r11.0<1;1,0>:ud   r35.0<1;1,0>:ud  {AccWrEn}
(W)     mov (2|M0)               r95.4<1>:d    0:w                              
        mov (8|M8)               r15.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mov (16|M0)              r80.0<1>:f    r12.0<1;1,0>:f                   {Compacted,A@3}
        mov (16|M0)              r82.0<1>:f    r14.0<1;1,0>:f                   {Compacted,I@1}
L2408:
(W)     shl (1|M0)               r2.0<1>:d     r95.3<0;1,0>:d    31:w               {Compacted,F@3}
(W)     shr (1|M0)               r2.1<1>:ud    r95.6<0;1,0>:ud   1:w              
(W)     cmp (16|M0)   (gt)f1.0   null<1>:d     r95.4<0;1,0>:ud   0x3E:uw             
(W)     or (1|M0)                r95.6<1>:d    r2.1<0;1,0>:d     r2.0<0;1,0>:d    {I@2}
        bfn.0xA8 (16|M0)         r10.0<1>:ud   r82.0<1;0>:ud     r2.1<0;0>:ud      r2.0<0>:ud       {F@1} // s0&(s1|s2)
(W)     shr (1|M0)               r95.2<1>:ud   r95.3<0;1,0>:ud   1:w              
(W&f1.0) cmp (16|M0)  (eq)f1.0   null<1>:d     r95.5<0;1,0>:d    0:w              
        cmp (16|M0)   (eq)f1.1   null<1>:d     r10.0<1;1,0>:d    r95.6<0;1,0>:d   {I@3}
        and (16|M0)              r12.0<1>:d    r80.0<1;1,0>:d    r95.2<0;1,0>:d   {Compacted,I@3}
(W&~f1.0) cmp (16|M0) (gt)f1.0   null<1>:d     r95.5<0;1,0>:ud   0x0:uw             
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r12.0<1;1,0>:d    r95.2<0;1,0>:d   {I@2}
(W)     mov (1|M0)               r5.2<1>:hf    0x1:hf                             
(W)     addc (1|M0)              r15.0<1>:ud   r95.4<0;1,0>:ud   0x1:ud              {AccWrEn}
(f1.0)  sel (16|M0)              r9.0<1>:uw    r5.2<0;1,0>:uw    0x0:uw              {Compacted,F@1}
(f1.1)  sel (16|M0)              acc2.0<1>:uw  r5.2<0;1,0>:uw    0x0:uw             
(W)     mov (1|M0)               r3.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        or (16|M0)    (ne)f0.1   null<1>:uw    r9.0<1;1,0>:uw    acc2.0<1;1,0>:uw {I@3}
(W)     add (1|M0)               r95.7<1>:ud   r3.0<0;1,0>:ud    r95.5<0;1,0>:ud  {I@2}
        mov (16|M0)              r110.0<1>:d   r95.4<0;1,0>:d                  
        mov (16|M0)              r108.0<1>:d   r95.5<0;1,0>:d                  
        mov (16|M0)              r78.0<1>:f    r15.0<0;1,0>:f                   {Compacted}
        mov (16|M0)              r76.0<1>:d    r95.7<0;1,0>:d                   {I@3}
(f0.1)  goto (16|M0)                         L2800                  L2800                
L2736:
(W)     mov (1|M0)               r95.3<1>:d    r95.2<0;1,0>:d                  
(W)     mov (1|M0)               r95.4<1>:d    r15.0<0;1,0>:d                  
(W)     mov (1|M0)               r95.5<1>:d    r95.7<0;1,0>:d                  
(W)     jmpi                                 L2408                                
L2800:
        join (16|M0)                         L7824                                
L2816:
(W)     mov (1|M0)               r2.0<1>:f     8.68805e-44:f                              
(W)     mov (1|M0)               r3.0<1>:hf    0.0:hf                             
        subb (8|M0)              r88.0<1>:ud   r2.0<0;1,0>:ud    r110.0<1;1,0>:ud {AccWrEn,Compacted,A@2}
        add3 (8|M0)              r124.0<1>:ud  -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r108.0<1>:ud    {A@1}
        subb (8|M8)              r89.0<1>:ud   r2.0<0;1,0>:ud    r111.0<1;1,0>:ud {AccWrEn}
        add3 (16|M0)             r122.0<1>:d   r70.0<1;0>:d      r88.0<1;0>:d      -46:w               {I@1}
        cmp (16|M0)   (gt)f1.1   null<1>:d     r122.0<1;1,0>:d   127:w               {I@1}
        add3 (8|M8)              r125.0<1>:ud  -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r109.0<1>:ud   
        add3 (16|M0)             r84.0<1>:d    r72.0<1;0>:d      r36.0<1;0>:d      r88.0<1>:d      
(f1.1)  goto (16|M0)                         L7760                  L7760                
L2968:
        cmp (16|M0)   (gt)f1.0   null<1>:d     r122.0<1;1,0>:d   -127:w              
(f1.0)  goto (16|M0)                         L5448                  L5448                
L3000:
        cmp (16|M0)   (lt)f0.1   null<1>:d     r122.0<1;1,0>:ud  0xFFFFFF6B:ud             
(f0.1)  goto (16|M0)                         L4944                  L4944                
L3032:
(W)     mov (1|M0)               r2.0<1>:f     8.82818e-44:f                              
(W)     mov (1|M0)               r3.0<1>:hf    0.0:hf                              {I@7}
        subb (8|M0)              r18.0<1>:ud   r2.0<0;1,0>:ud    r110.0<1;1,0>:ud {AccWrEn,Compacted,F@2}
        add3 (16|M0)             r20.0<1>:d    r70.0<1;0>:d      r88.0<1;0>:d      104:w              
        add3 (8|M0)              r10.0<1>:ud   -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r108.0<1>:ud    {F@1}
        subb (8|M8)              r19.0<1>:ud   r2.0<0;1,0>:ud    r111.0<1;1,0>:ud {AccWrEn}
        cmp (16|M0)   (gt)f0.1   null<1>:d     r18.0<1;1,0>:ud   r20.0<1;1,0>:ud  {I@1}
        add3 (8|M8)              r11.0<1>:ud   -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r109.0<1>:ud   
(f0.1)  cmp (16|M0)   (eq)f0.1   null<1>:d     r10.0<1;1,0>:d    0:w               {I@1}
(~f0.1) cmp (16|M0)   (gt)f0.1   null<1>:d     r10.0<1;1,0>:ud   0x0:uw             
(f0.1)  goto (16|M0)                         L3256                  L3256                
L3200:
        add3 (16|M0)             r2.0<1>:d     r84.0<1;0>:d      -r18.0<1;0>:d     104:w              
        mov (16|M0)              r86.0<1>:d    0:w                              
        shl (16|M0)              r88.0<1>:d    r82.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
        goto (16|M0)                         L3256                  L4880                
L3256:
        join (16|M0)                         L4880                                
L3272:
        add3 (16|M0)             r16.0<1>:d    r18.0<1;0>:d      -r84.0<1;0>:d     -104:w              
        cmp (16|M0)   (lt)f1.1   null<1>:d     r16.0<1;1,0>:d    2:w               {I@1}
(f1.1)  goto (16|M0)                         L3416                  L3416                
L3320:
        cmp (16|M0)   (eq)f1.0   null<1>:d     r16.0<1;1,0>:d    2:w              
(~f1.0) goto (16|M0)                         L3416                  L3464                
L3352:
        shr (16|M0)              r120.0<1>:ud  r82.0<1;1,0>:ud   1:w              
        and (16|M0)              r22.0<1>:d    r82.0<1;1,0>:d    1:w               {Compacted}
        mov (16|M0)              r32.0<1>:d    0:w                              
        mov (16|M0)              r64.0<1>:f    r120.0<1;1,0>:f                  {Compacted,I@3}
        goto (16|M0)                         L3416                  L4352                
L3416:
        join (16|M0)                         L3464                                
L3432:
        cmp (16|M0)   (eq)f0.1   null<1>:d     r16.0<1;1,0>:d    1:w              
(f0.1)  goto (16|M0)                         L3464                  L4296                
L3464:
        join (16|M0)                         L4296                                
L3480:
        add3 (16|M0)             r2.0<1>:d     r18.0<1;0>:d      -r20.0<1;0>:d     -1:w              
        and (16|M0)   (ne)f1.1   r108.0<1>:d   r2.0<1;1,0>:d     63:w               {I@1}
(f1.1)  goto (16|M0)                         L3552                  L3552                
L3528:
        mov (16|M0)              r14.0<1>:f    r82.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L3552                  L3664                
L3552:
        join (16|M0)                         L3664                                
L3568:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r108.0<1;1,0>:ud  0x20:uw              {I@4}
(~f1.0) add (16|M0)              r2.0<1>:d     r108.0<1;1,0>:d   -32:w              
(~f1.0) shr (16|M0)              r120.0<1>:ud  r80.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.0)  add (16|M0)              r2.0<1>:d     -r108.0<1;1,0>:d  32:w               {Compacted}
(f1.0)  shr (16|M0)              r10.0<1>:ud   r82.0<1;1,0>:ud   r108.0<1;1,0>:d 
(f1.0)  shl (16|M0)              r2.0<1>:d     r80.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.0)  or (16|M0)               r120.0<1>:d   r10.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@1}
        mov (16|M0)              r14.0<1>:f    r120.0<1;1,0>:f                  {Compacted,I@1}
L3664:
        join (16|M0)                         L4296                                
L3680:
        add3 (16|M0)             r98.0<1>:d    r18.0<1;0>:d      -r20.0<1;0>:d     -2:w              
        and (16|M0)   (ne)f0.1   r106.0<1>:d   r98.0<1;1,0>:d    63:w               {I@1}
(f0.1)  goto (16|M0)                         L3752                  L3752                
L3728:
        mov (16|M0)              r120.0<1>:f   r82.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L3752                  L3856                
L3752:
        join (16|M0)                         L3856                                
L3768:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r106.0<1;1,0>:ud  0x20:uw              {I@4}
(~f1.1) add (16|M0)              r2.0<1>:d     r106.0<1;1,0>:d   -32:w              
(~f1.1) shr (16|M0)              r120.0<1>:ud  r80.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.1)  add (16|M0)              r2.0<1>:d     -r106.0<1;1,0>:d  32:w               {Compacted}
(f1.1)  shr (16|M0)              r10.0<1>:ud   r82.0<1;1,0>:ud   r106.0<1;1,0>:d 
(f1.1)  shl (16|M0)              r2.0<1>:d     r80.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.1)  or (16|M0)               r120.0<1>:d   r10.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@1}
L3856:
        join (16|M0)                         L4296                                
L3872:
        and (16|M0)   (ne)f1.0   r104.0<1>:d   r98.0<1;1,0>:d    63:w              
        and (16|M0)              r22.0<1>:d    r120.0<1;1,0>:d   1:w               {Compacted,I@3}
(f1.0)  goto (16|M0)                         L3960                  L3960                
L3912:
        mov (16|M0)              r84.0<1>:d    -1:w                              
        mov (16|M0)              r20.0<1>:d    -1:w                              
        goto (16|M0)                         L3960                  L4144                
L3960:
        join (16|M0)                         L4144                                
L3976:
        cmp (16|M0)   (lt)f0.1   null<1>:d     r104.0<1;1,0>:ud  0x20:uw              {I@7}
(f0.1)  goto (16|M0)                         L4080                  L4080                
L4008:
        add (16|M0)              r2.0<1>:d     r104.0<1;1,0>:d   -32:w               {Compacted}
(W)     mov (1|M0)               r5.2<1>:hf    -qnan(0x1FF):hf                             
        mov (16|M0)              r84.0<1>:d    0:w                              
        shl (16|M0)              r20.0<1>:d    r5.2<0;1,0>:w     r2.0<1;1,0>:d    {A@1}
        goto (16|M0)                         L4080                  L4144                
L4080:
        join (16|M0)                         L4144                                
L4096:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (16|M0)              r20.0<1>:d    -1:w                              
        shl (16|M0)              r84.0<1>:d    r2.0<0;1,0>:w     r104.0<1;1,0>:d  {F@1}
L4144:
        join (16|M0)                         L4296                                
L4160:
        bfn.0x28 (16|M0)         r2.0<1>:ud    r82.0<1;0>:ud     r84.0<1;0>:ud     r6.2<0>:ud       {I@2} // s0&(s1^s2)
        cmp (16|M0)   (ne)f1.0   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
        bfn.0x28 (16|M0)         r10.0<1>:ud   r80.0<1;0>:ud     r20.0<1;0>:ud     r6.2<0>:ud       // s0&(s1^s2)
(~f1.0) cmp (16|M0)   (ne)f1.0   null<1>:d     r10.0<1;1,0>:d    0:w               {I@1}
(W)     mov (1|M0)               r5.2<1>:hf    -qnan(0x1FF):hf                             
        mov (16|M0)              r64.0<1>:f    r14.0<1;1,0>:f                   {Compacted}
(f1.0)  sel (16|M0)              r12.0<1>:d    r5.2<0;1,0>:w     0:w               {F@2}
        mov (16|M0)              r32.0<1>:d    -r12.0<1;1,0>:d                  {I@1}
        goto (16|M0)                         L4296                  L4352                
L4296:
        join (16|M0)                         L4352                                
L4312:
        mov (16|M0)              r32.0<1>:d    0:w                              
        mov (16|M0)              r22.0<1>:d    0:w                              
        mov (16|M0)              r64.0<1>:f    r82.0<1;1,0>:f                   {Compacted}
L4352:
        join (16|M0)                         L4880                                
L4368:
        and (16|M0)   (ne)f1.1   r102.0<1>:d   r16.0<1;1,0>:d    63:w              
(f1.1)  goto (16|M0)                         L4424                  L4424                
L4400:
        mov (16|M0)              r120.0<1>:f   r82.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L4424                  L4528                
L4424:
        join (16|M0)                         L4528                                
L4440:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r102.0<1;1,0>:ud  0x20:uw              {I@4}
(~f1.0) add (16|M0)              r2.0<1>:d     r102.0<1;1,0>:d   -32:w              
(~f1.0) shr (16|M0)              r120.0<1>:ud  r80.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.0)  add (16|M0)              r2.0<1>:d     -r102.0<1;1,0>:d  32:w               {Compacted}
(f1.0)  shr (16|M0)              r10.0<1>:ud   r82.0<1;1,0>:ud   r102.0<1;1,0>:d 
(f1.0)  shl (16|M0)              r2.0<1>:d     r80.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.0)  or (16|M0)               r120.0<1>:d   r10.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@1}
L4528:
        join (16|M0)                         L4880                                
L4544:
        shl (16|M0)              r2.0<1>:d     r64.0<1;1,0>:d    2:w               {Compacted}
        shl (16|M0)              r10.0<1>:d    r22.0<1;1,0>:d    1:w               {Compacted}
        and (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     4:w               {Compacted,I@2}
        bfn.0xFE (16|M0)         r96.0<1>:ud   r2.0<1;0>:ud      r10.0<1;0>:ud     r32.0<1>:ud      {I@1} // s0|s1|s2
        cmp (16|M0)   (eq)f0.1   null<1>:d     r96.0<1;1,0>:d    0:w               {I@1}
(~f0.1) goto (16|M0)                         L4648                  L4648                
L4616:
        mov (16|M0)              r108.0<1>:d   0:w                              
        goto (16|M0)                         L4648                  L4808                
L4648:
        join (16|M0)                         L4808                                
L4664:
        cmp (16|M0)   (gt)f1.1   null<1>:d     r96.0<1;1,0>:ud   0x4:uw             
(~f1.1) goto (16|M0)                         L4728                  L4728                
L4696:
        mov (16|M0)              r108.0<1>:d   1:w                              
        goto (16|M0)                         L4728                  L4808                
L4728:
        join (16|M0)                         L4808                                
L4744:
        and (16|M0)   (ne)f0.1   null<1>:d     r120.0<1;1,0>:d   1:w              
(W)     mov (1|M0)               r2.0<1>:hf    0x1:hf                             
(f0.1)  cmp (16|M0)   (eq)f0.1   null<1>:d     r96.0<1;1,0>:d    4:w              
(f0.1)  sel (16|M0)              r108.0<1>:d   r2.0<0;1,0>:w     0:w               {F@1}
L4808:
        join (16|M0)                         L4880                                
L4824:
        add (16|M0)              r2.0<1>:d     r108.0<1;1,0>:d   r120.0<1;1,0>:d  {Compacted,I@2}
        cmp (16|M0)   (gt)f0.1   null<1>:d     r2.0<1;1,0>:ud    0x7FFFFF:ud              {I@1}
(W)     mov (1|M0)               r5.1<1>:f     0x800000:f                               {Compacted}
(~f0.1) sel (16|M0)              r88.0<1>:d    r2.0<1;1,0>:d     0:w              
(f0.1)  sel (16|M0)              r86.0<1>:d    r5.1<0;1,0>:d     0:w               {Compacted,F@1}
L4880:
        join (16|M0)                         L4944                                
L4896:
        and (16|M0)              r2.0<1>:d     r74.0<1;1,0>:d    -2147483648:d              
        bfn.0xFE (16|M0)         r92.0<1>:ud   r2.0<1;0>:ud      r86.0<1;0>:ud     r88.0<1>:ud      {I@1} // s0|s1|s2
        goto (16|M0)                         L4944                  L7976                
L4944:
        join (16|M0)                         L5448                                
L4960:
        and (16|M0)   (ne)f1.0   r22.0<1>:d    r88.0<1;1,0>:d    63:w              
(f1.0)  goto (16|M0)                         L5040                  L5040                
L4992:
        mov (16|M0)              r12.0<1>:d    -1:w                              
        mov (16|M0)              r116.0<1>:d   -1:w                              
        goto (16|M0)                         L5040                  L5224                
L5040:
        join (16|M0)                         L5224                                
L5056:
        cmp (16|M0)   (lt)f0.1   null<1>:d     r22.0<1;1,0>:ud   0x20:uw              {I@6}
(f0.1)  goto (16|M0)                         L5160                  L5160                
L5088:
        add (16|M0)              r2.0<1>:d     r22.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r5.2<1>:hf    -qnan(0x1FF):hf                             
        mov (16|M0)              r12.0<1>:d    0:w                              
        shl (16|M0)              r116.0<1>:d   r5.2<0;1,0>:w     r2.0<1;1,0>:d    {A@1}
        goto (16|M0)                         L5160                  L5224                
L5160:
        join (16|M0)                         L5224                                
L5176:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (16|M0)              r116.0<1>:d   -1:w                              
        shl (16|M0)              r12.0<1>:d    r2.0<0;1,0>:w     r22.0<1;1,0>:d   {F@1}
L5224:
        join (16|M0)                         L5448                                
L5240:
        bfn.0x28 (16|M0)         r2.0<1>:ud    r82.0<1;0>:ud     r12.0<1;0>:ud     r6.2<0>:ud       {I@2} // s0&(s1^s2)
        cmp (16|M0)   (ne)f1.0   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
        bfn.0x28 (16|M0)         r10.0<1>:ud   r80.0<1;0>:ud     r116.0<1;0>:ud    r6.2<0>:ud       // s0&(s1^s2)
        cmp (16|M0)   (gt)f1.1   null<1>:d     r74.0<1;1,0>:d    -1:w              
(~f1.0) cmp (16|M0)   (ne)f1.0   null<1>:d     r10.0<1;1,0>:d    0:w               {I@2}
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r122.0<1;1,0>:d   -150:w              
(f1.1)  goto (16|M0)                         L5392                  L5392                
L5352:
(W)     mov (1|M0)               r2.0<1>:ud    0x80000001:ud                             
(f1.0)  sel (16|M0)              r92.0<1>:f    r2.0<0;1,0>:f     -0.0:f               {Compacted,I@1}
        goto (16|M0)                         L5392                  L7976                
L5392:
        join (16|M0)                         L5448                                
L5408:
(W)     mov (1|M0)               r2.0<1>:ud    0x1:ud                              {F@1}
(f1.0)  sel (16|M0)              r92.0<1>:f    r2.0<0;1,0>:f     0.0:f               {Compacted,I@1}
        goto (16|M0)                         L5448                  L7976                
L5448:
        join (16|M0)                         L7760                                
L5464:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r88.0<1;1,0>:ud   0x18:uw             
        add3 (16|M0)             r90.0<1>:d    r70.0<1;0>:d      r88.0<1;0>:d      81:w              
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r124.0<1;1,0>:d   0:w              
(f1.1)  goto (16|M0)                         L7448                  L7448                
L5528:
        shl (16|M0)              r2.0<1>:d     r78.0<1;1,0>:d    1:w               {Compacted,F@1}
        shr (16|M0)              r10.0<1>:ud   r78.0<1;1,0>:ud   31:w              
        shl (16|M0)              r12.0<1>:d    r76.0<1;1,0>:d    1:w               {Compacted}
        cmp (16|M0)   (lt)f1.1   null<1>:d     r2.0<1;1,0>:ud    0x4E:uw              {I@3}
        or (16|M0)               r12.0<1>:d    r12.0<1;1,0>:d    r10.0<1;1,0>:d   {Compacted,I@2}
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r12.0<1;1,0>:d    0:w               {I@1}
(~f1.1) cmp (16|M0)   (lt)f1.1   null<1>:d     r12.0<1;1,0>:d    0:w              
(f1.1)  goto (16|M0)                         L5760                  L5760                
L5632:
        cmp (16|M0)   (eq)f1.0   null<1>:d     r78.0<1;1,0>:d    39:w              
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r76.0<1;1,0>:d    0:w              
(~f1.0) goto (16|M0)                         L5760                  L5824                
L5680:
        shr (16|M0)              r120.0<1>:ud  r82.0<1;1,0>:ud   1:w              
        mov (16|M0)              r76.0<1>:d    0:w                              
        mov (16|M0)              r112.0<1>:d   0:w                              
        mov (16|M0)              r126.0<1>:f   r120.0<1;1,0>:f                  {Compacted,I@3}
        mov (16|M0)              r120.0<1>:f   r82.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L5760                  L6920                
L5760:
        join (16|M0)                         L5824                                
L5776:
        cmp (16|M0)   (eq)f0.1   null<1>:d     r78.0<1;1,0>:d    38:w              
(f0.1)  cmp (16|M0)   (eq)f0.1   null<1>:d     r76.0<1;1,0>:d    0:w               {I@5}
(f0.1)  goto (16|M0)                         L5824                  L6840                
L5824:
        join (16|M0)                         L6840                                
L5840:
        add (16|M0)              r2.0<1>:d     -r78.0<1;1,0>:d   39:w               {Compacted}
        and (16|M0)   (ne)f1.0   r10.0<1>:d    r2.0<1;1,0>:d     63:w               {I@1}
        add (16|M0)              r106.0<1>:d   -r78.0<1;1,0>:d   40:w               {Compacted}
(f1.0)  goto (16|M0)                         L5912                  L5912                
L5888:
        mov (16|M0)              r104.0<1>:f   r82.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L5912                  L6024                
L5912:
        join (16|M0)                         L6024                                
L5928:
        cmp (16|M0)   (lt)f0.1   null<1>:d     r10.0<1;1,0>:ud   0x20:uw              {I@5}
(~f0.1) add (16|M0)              r2.0<1>:d     r10.0<1;1,0>:d    -32:w              
(~f0.1) shr (16|M0)              r120.0<1>:ud  r80.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f0.1)  add (16|M0)              r2.0<1>:d     -r10.0<1;1,0>:d   32:w               {Compacted}
(f0.1)  shl (16|M0)              r2.0<1>:d     r80.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@1}
(f0.1)  shr (16|M0)              r10.0<1>:ud   r82.0<1;1,0>:ud   r10.0<1;1,0>:d  
(f0.1)  or (16|M0)               r120.0<1>:d   r10.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@1}
        mov (16|M0)              r104.0<1>:f   r120.0<1;1,0>:f                  {Compacted,I@1}
L6024:
        join (16|M0)                         L6840                                
L6040:
        add (16|M0)              r124.0<1>:d   -r78.0<1;1,0>:d   38:w               {Compacted}
        and (16|M0)   (ne)f1.1   r96.0<1>:d    r124.0<1;1,0>:d   63:w               {I@1}
(f1.1)  goto (16|M0)                         L6104                  L6104                
L6080:
        mov (16|M0)              r120.0<1>:f   r82.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L6104                  L6208                
L6104:
        join (16|M0)                         L6208                                
L6120:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r96.0<1;1,0>:ud   0x20:uw              {I@4}
(~f1.0) add (16|M0)              r2.0<1>:d     r96.0<1;1,0>:d    -32:w              
(~f1.0) shr (16|M0)              r120.0<1>:ud  r80.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.0)  add (16|M0)              r2.0<1>:d     -r96.0<1;1,0>:d   32:w               {Compacted}
(f1.0)  shr (16|M0)              r10.0<1>:ud   r82.0<1;1,0>:ud   r96.0<1;1,0>:d  
(f1.0)  shl (16|M0)              r2.0<1>:d     r80.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.0)  or (16|M0)               r120.0<1>:d   r10.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@1}
L6208:
        join (16|M0)                         L6840                                
L6224:
        and (16|M0)   (ne)f0.1   r92.0<1>:d    r124.0<1;1,0>:d   63:w              
        and (16|M0)              r112.0<1>:d   r120.0<1;1,0>:d   1:w               {Compacted,I@3}
(f0.1)  goto (16|M0)                         L6312                  L6312                
L6264:
        mov (16|M0)              r62.0<1>:d    -1:w                              
        mov (16|M0)              r26.0<1>:d    -1:w                              
        goto (16|M0)                         L6312                  L6496                
L6312:
        join (16|M0)                         L6496                                
L6328:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r92.0<1;1,0>:ud   0x20:uw              {I@7}
(f1.1)  goto (16|M0)                         L6432                  L6432                
L6360:
        add (16|M0)              r2.0<1>:d     r92.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r5.2<1>:hf    -qnan(0x1FF):hf                             
        mov (16|M0)              r62.0<1>:d    0:w                              
        shl (16|M0)              r26.0<1>:d    r5.2<0;1,0>:w     r2.0<1;1,0>:d    {A@1}
        goto (16|M0)                         L6432                  L6496                
L6432:
        join (16|M0)                         L6496                                
L6448:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (16|M0)              r26.0<1>:d    -1:w                              
        shl (16|M0)              r62.0<1>:d    r2.0<0;1,0>:w     r92.0<1;1,0>:d   {F@1}
L6496:
        join (16|M0)                         L6840                                
L6512:
        bfn.0x28 (16|M0)         r2.0<1>:ud    r82.0<1;0>:ud     r62.0<1;0>:ud     r6.2<0>:ud       {I@2} // s0&(s1^s2)
        cmp (16|M0)   (ne)f1.1   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
        bfn.0x28 (16|M0)         r10.0<1>:ud   r80.0<1;0>:ud     r26.0<1;0>:ud     r6.2<0>:ud       // s0&(s1^s2)
(~f1.1) cmp (16|M0)   (ne)f1.1   null<1>:d     r10.0<1;1,0>:d    0:w               {I@1}
(W)     mov (1|M0)               r5.2<1>:hf    -qnan(0x1FF):hf                             
        and (16|M0)   (ne)f1.0   r86.0<1>:d    r106.0<1;1,0>:d   63:w              
(f1.1)  sel (16|M0)              r12.0<1>:d    r5.2<0;1,0>:w     0:w               {F@1}
        mov (16|M0)              r76.0<1>:d    -r12.0<1;1,0>:d                  {I@1}
(f1.0)  goto (16|M0)                         L6680                  L6680                
L6656:
        mov (16|M0)              r120.0<1>:f   r82.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L6680                  L6784                
L6680:
        join (16|M0)                         L6784                                
L6696:
        cmp (16|M0)   (lt)f0.1   null<1>:d     r86.0<1;1,0>:ud   0x20:uw             
(~f0.1) add (16|M0)              r2.0<1>:d     r86.0<1;1,0>:d    -32:w              
(~f0.1) shr (16|M0)              r120.0<1>:ud  r80.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f0.1)  add (16|M0)              r2.0<1>:d     -r86.0<1;1,0>:d   32:w               {Compacted}
(f0.1)  shr (16|M0)              r10.0<1>:ud   r82.0<1;1,0>:ud   r86.0<1;1,0>:d  
(f0.1)  shl (16|M0)              r2.0<1>:d     r80.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f0.1)  or (16|M0)               r120.0<1>:d   r10.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@1}
L6784:
        join (16|M0)                         L6840                                
L6800:
        mov (16|M0)              r126.0<1>:f   r120.0<1;1,0>:f                  {Compacted,I@2}
        mov (16|M0)              r120.0<1>:d   r104.0<1;1,0>:d                  {F@1}
        goto (16|M0)                         L6840                  L6920                
L6840:
        join (16|M0)                         L6920                                
L6856:
        shr (16|M0)              r120.0<1>:ud  r82.0<1;1,0>:ud   2:w              
        and (16|M0)              r112.0<1>:d   r82.0<1;1,0>:d    1:w               {Compacted}
        mov (16|M0)              r76.0<1>:d    0:w                              
        mov (16|M0)              r126.0<1>:f   r120.0<1;1,0>:f                  {Compacted,I@3}
        shr (16|M0)              r120.0<1>:ud  r82.0<1;1,0>:ud   1:w               {F@1}
L6920:
        join (16|M0)                         L7448                                
L6936:
        shl (16|M0)              r2.0<1>:d     r120.0<1;1,0>:d   2:w               {Compacted,I@2}
        shl (16|M0)              r10.0<1>:d    r112.0<1;1,0>:d   1:w               {Compacted}
        and (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     4:w               {Compacted,I@2}
        bfn.0xFE (16|M0)         r10.0<1>:ud   r2.0<1;0>:ud      r10.0<1;0>:ud     r76.0<1>:ud      {I@1} // s0|s1|s2
        cmp (16|M0)   (eq)f1.1   null<1>:d     r10.0<1;1,0>:d    0:w               {I@1}
        and (16|M0)              r44.0<1>:d    r126.0<1;1,0>:d   8388607:d              
(~f1.1) goto (16|M0)                         L7056                  L7056                
L7024:
        mov (16|M0)              r20.0<1>:d    0:w                              
        goto (16|M0)                         L7056                  L7216                
L7056:
        join (16|M0)                         L7216                                
L7072:
        cmp (16|M0)   (gt)f1.0   null<1>:d     r10.0<1;1,0>:ud   0x4:uw             
(~f1.0) goto (16|M0)                         L7136                  L7136                
L7104:
        mov (16|M0)              r20.0<1>:d    1:w                              
        goto (16|M0)                         L7136                  L7216                
L7136:
        join (16|M0)                         L7216                                
L7152:
        and (16|M0)   (ne)f1.0   null<1>:d     r126.0<1;1,0>:d   1:w              
(W)     mov (1|M0)               r2.0<1>:hf    0x1:hf                             
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r10.0<1;1,0>:d    4:w              
(f1.0)  sel (16|M0)              r20.0<1>:d    r2.0<0;1,0>:w     0:w               {F@1}
L7216:
        join (16|M0)                         L7448                                
L7232:
        add (16|M0)              r20.0<1>:d    r44.0<1;1,0>:d    r20.0<1;1,0>:d   {Compacted,I@2}
        cmp (16|M0)   (gt)f1.1   null<1>:d     r20.0<1;1,0>:ud   0x7FFFFF:ud              {I@1}
        add3 (16|M0)             r2.0<1>:d     r70.0<1;0>:d      r88.0<1;0>:d      82:w              
(f1.1)  sel (16|M0)              r92.0<1>:d    r2.0<1;1,0>:d     r90.0<1;1,0>:d   {Compacted,I@1}
        cmp (16|M0)   (eq)f0.1   null<1>:d     r92.0<1;1,0>:d    255:w               {I@1}
(f0.1)  goto (16|M0)                         L7384                  L7384                
L7312:
(~f1.1) sel (16|M0)              r2.0<1>:d     r20.0<1;1,0>:d    0:w              
        and (16|M0)              r10.0<1>:d    r74.0<1;1,0>:d    -2147483648:d              
        shl (16|M0)              r12.0<1>:d    r92.0<1;1,0>:d    23:w               {Compacted}
        bfn.0xFE (16|M0)         r92.0<1>:ud   r10.0<1;0>:ud     r12.0<1;0>:ud     r2.0<1>:ud       {I@1} // s0|s1|s2
        goto (16|M0)                         L7384                  L7976                
L7384:
        join (16|M0)                         L7448                                
L7400:
        cmp (16|M0)   (gt)f0.1   null<1>:d     r74.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r2.0<1>:f     inf:f                               {Compacted,I@4}
(f0.1)  sel (16|M0)              r92.0<1>:f    r2.0<0;1,0>:f     -inf:f               {Compacted,F@1}
        goto (16|M0)                         L7448                  L7976                
L7448:
        join (16|M0)                         L7760                                
L7464:
        and (16|M0)   (ne)f1.1   r84.0<1>:d    r88.0<1;1,0>:d    63:w              
(f1.1)  goto (16|M0)                         L7528                  L7528                
L7496:
        mov (16|M0)              r120.0<1>:d   -1:w                              
        goto (16|M0)                         L7528                  L7656                
L7528:
        join (16|M0)                         L7656                                
L7544:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r84.0<1;1,0>:ud   0x20:uw              {I@5}
(f1.0)  goto (16|M0)                         L7608                  L7608                
L7576:
        mov (16|M0)              r120.0<1>:d   0:w                              
        goto (16|M0)                         L7608                  L7656                
L7608:
        join (16|M0)                         L7656                                
L7624:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                             
        shl (16|M0)              r120.0<1>:d   r2.0<0;1,0>:w     r84.0<1;1,0>:d   {F@1}
L7656:
        join (16|M0)                         L7760                                
L7672:
        bfn.0x28 (16|M0)         r2.0<1>:ud    r82.0<1;0>:ud     r120.0<1;0>:ud    r6.2<0>:ud       {I@2} // s0&(s1^s2)
        add (16|M0)              r10.0<1>:d    -r88.0<1;1,0>:d   23:w               {Compacted}
        and (16|M0)              r12.0<1>:d    r74.0<1;1,0>:d    -2147483648:d              
        shl (16|M0)              r14.0<1>:d    r90.0<1;1,0>:d    23:w               {Compacted}
        shl (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     r10.0<1;1,0>:d   {Compacted,I@3}
        bfn.0xFE (16|M0)         r92.0<1>:ud   r12.0<1;0>:ud     r14.0<1;0>:ud     r2.0<1>:ud       {I@1} // s0|s1|s2
        goto (16|M0)                         L7760                  L7976                
L7760:
        join (16|M0)                         L7824                                
L7776:
        cmp (16|M0)   (gt)f1.1   null<1>:d     r74.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r2.0<1>:f     inf:f                               {Compacted,I@4}
(f1.1)  sel (16|M0)              r92.0<1>:f    r2.0<0;1,0>:f     -inf:f               {Compacted,F@1}
        goto (16|M0)                         L7824                  L7976                
L7824:
        join (16|M0)                         L7880                                
L7840:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r74.0<1;1,0>:d    0:w               {Compacted}
(W)     mov (1|M0)               r2.0<1>:f     -0.0:f                               {Compacted}
(f1.0)  sel (16|M0)              r92.0<1>:f    r2.0<0;1,0>:f     0.0:f               {Compacted,F@1}
        goto (16|M0)                         L7880                  L7976                
L7880:
        join (16|M0)                         L7944                                
L7896:
        cmp (16|M0)   (gt)f0.1   null<1>:d     r74.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r2.0<1>:f     inf:f                               {Compacted}
(f0.1)  sel (16|M0)              r92.0<1>:f    r2.0<0;1,0>:f     -inf:f               {Compacted,F@1}
        goto (16|M0)                         L7944                  L7976                
L7944:
        join (16|M0)                         L7976                                
L7960:
        bfn.0xF8 (16|M0)         r92.0<1>:ud   r74.0<1;0>:ud     r6.4<0;0>:ud      r6.3<0>:ud       {F@1} // s0&s1|s2
L7976:
        join (16|M0)                         L14600                                
L7992:
        shr (16|M0)              r90.0<1>:ud   r92.0<1;1,0>:ud   23:w               {I@2}
        and (16|M0)   (ne)f0.1   r88.0<1>:d    r92.0<1;1,0>:d    8388607:d              
        and (16|M0)              r100.0<1>:d   r90.0<1;1,0>:d    255:w               {Compacted,I@2}
(W)     addc (1|M0)              r3.0<1>:ud    r8.5<0;1,0>:ud    r6.5<0;1,0>:ud   {AccWrEn}
(f0.1)  cmp (16|M0)   (eq)f0.1   null<1>:d     r100.0<1;1,0>:d   255:w               {I@2}
(W)     mov (1|M0)               r2.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
(W)     add3 (1|M0)              r5.1<1>:ud    r2.0<0;0>:ud      r6.7<0;0>:ud      r6.6<0>:ud       {I@1}
(~f0.1) goto (16|M0)                         L8136                  L8136                
L8104:
        mov (16|M0)              r26.0<1>:ud   0x7FC00000:ud                             
        goto (16|M0)                         L8136                  L14536                
L8136:
        join (16|M0)                         L14536                                
L8152:
(W)     mov (1|M0)               r2.0<2>:f     r3.0<0;1,0>:f                    {Compacted,I@5}
(W)     mov (1|M0)               r2.1<2>:f     r5.1<0;1,0>:f                    {Compacted}
(W)     mov (2|M0)               r10.0<1>:f    r2.0<1;1,0>:f                    {Compacted,F@1}
(W)     send.ugm (1|M0)          r3       r10     null:0  0x0            0x02188580           {A@1,$7} // wr:1+0, rd:1; load.ugm.d32x1t.a64.ca.ca
(W)     and (1|M0)               r6.7<1>:d     r3.0<0;1,0>:d     8388607:d               {$7.dst}
(W)     shr (1|M0)               r5.2<1>:ud    r3.0<0;1,0>:ud    23:w              
(W)     cmp (16|M0)   (ne)f1.1   null<1>:d     r6.7<0;1,0>:d     0:w               {I@2}
(W)     and (1|M0)               r5.1<1>:d     r5.2<0;1,0>:d     255:w               {I@2}
(W&f1.1) cmp (16|M0)  (eq)f1.1   null<1>:d     r5.1<0;1,0>:d     255:w               {I@1}
(~f1.1) goto (16|M0)                         L8320                  L8320                
L8288:
        mov (16|M0)              r26.0<1>:ud   0x7FC00000:ud                             
        goto (16|M0)                         L8320                  L14536                
L8320:
        join (16|M0)                         L14536                                
L8336:
        cmp (16|M0)   (eq)f1.0   null<1>:d     r88.0<1;1,0>:d    0:w              
(W)     cmp (16|M0)   (eq)f0.1   null<1>:d     r6.7<0;1,0>:d     0:w              
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r100.0<1;1,0>:d   255:w              
(W&f0.1) cmp (16|M0)  (eq)f0.1   null<1>:d     r5.1<0;1,0>:d     255:w              
(W)     mov (1|M0)               r2.0<1>:hf    0x1:hf                             
        xor (16|M0)              r44.0<1>:d    r3.0<0;1,0>:d     r92.0<1;1,0>:d   {Compacted}
(f0.1)  sel (16|M0)              acc0.0<1>:uw  r2.0<0;1,0>:uw    0x0:uw              {F@1}
(f1.0)  sel (16|M0)              acc2.0<1>:uw  r2.0<0;1,0>:uw    0x0:uw             
        or (16|M0)    (ne)f0.1   null<1>:uw    acc2.0<1;1,0>:uw  acc0.0<1;1,0>:uw
(f0.1)  goto (16|M0)                         L14504                  L14504                
L8488:
(W)     or (1|M0)                r2.0<1>:d     r5.1<0;1,0>:d     r6.7<0;1,0>:d   
        or (16|M0)               r10.0<1>:d    r100.0<1;1,0>:d   r88.0<1;1,0>:d   {Compacted}
(W)     cmp (16|M0)   (eq)f1.0   null<1>:d     r2.0<0;1,0>:d     0:w               {I@2}
(~f1.0) cmp (16|M0)   (eq)f1.0   null<1>:d     r10.0<1;1,0>:d    0:w               {I@2}
(~f1.0) goto (16|M0)                         L8592                  L8592                
L8560:
        mov (16|M0)              r26.0<1>:ud   0x0:ud                             
        goto (16|M0)                         L8592                  L14536                
L8592:
        join (16|M0)                         L14504                                
L8608:
        cmp (16|M0)   (eq)f1.0   null<1>:d     r100.0<1;1,0>:d   0:w              
(W)     cmp (16|M0)   (eq)f0.1   null<1>:d     r5.1<0;1,0>:d     0:w              
(W)     add (1|M0)               r2.0<1>:d     r5.1<0;1,0>:d     -127:w               {Compacted}
        add (16|M0)              r32.0<1>:d    r100.0<1;1,0>:d   -127:w               {Compacted}
(W&~f0.1) sel (1|M0)             r95.7<1>:d    r2.0<0;1,0>:d     -126:w               {I@2}
(f1.0)  mov (16|M0)              r32.0<1>:d    -126:w                              
        add (16|M0)              r26.0<1>:d    r32.0<1;1,0>:d    r95.7<0;1,0>:d   {Compacted,I@1}
        cmp (16|M0)   (gt)f1.1   null<1>:d     r26.0<1;1,0>:d    127:w               {I@1}
(f1.1)  goto (16|M0)                         L14440                  L14440                
L8728:
        or (16|M0)    (eq)f1.1   null<4>:b     r90.0<1;1,0>:d    r5.2<0;1,0>:d   
(f1.1)  goto (16|M0)                         L14376                  L14376                
L8760:
(W)     mov (1|M0)               r2.0<1>:hf    0.0:hf                             
(W)     mov (1|M0)               r95.3<1>:d    0:w                              
(f1.0)  sel (16|M0)              r10.0<1>:d    r2.0<0;1,0>:w     8388608:d               {F@1}
(W&f0.1) sel (1|M0)              r3.0<1>:d     r2.0<0;1,0>:w     8388608:d              
        or (16|M0)               r10.0<1>:d    r10.0<1;1,0>:d    r88.0<1;1,0>:d   {Compacted,I@2}
(W)     or (1|M0)                r5.1<1>:d     r3.0<0;1,0>:d     r6.7<0;1,0>:d    {I@2}
(W)     mov (1|M0)               r95.2<1>:f    -0.0:f                               {Compacted}
        mul (8|M0)               acc0.0<1>:ud  r10.0<1;1,0>:ud   r5.2<0;1,0>:uw   {I@1}
        mach (8|M0)              r12.0<1>:ud   r10.0<1;1,0>:ud   r5.1<0;1,0>:ud   {AccWrEn,Compacted}
(W)     mov (2|M0)               r95.4<1>:d    0:w                              
        mov (8|M0)               r14.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mul (8|M8)               acc0.0<1>:ud  r11.0<1;1,0>:ud   r5.2<0;1,0>:uw  
        mach (8|M8)              r13.0<1>:ud   r11.0<1;1,0>:ud   r5.1<0;1,0>:ud   {AccWrEn}
        mov (8|M8)               r15.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mov (16|M0)              r66.0<1>:f    r12.0<1;1,0>:f                   {Compacted,A@2}
        mov (16|M0)              r68.0<1>:f    r14.0<1;1,0>:f                   {Compacted,I@1}
L8960:
(W)     shl (1|M0)               r2.0<1>:d     r95.2<0;1,0>:d    31:w               {Compacted,F@3}
(W)     shr (1|M0)               r2.1<1>:ud    r95.3<0;1,0>:ud   1:w              
(W)     cmp (16|M0)   (gt)f0.1   null<1>:d     r95.4<0;1,0>:ud   0x3E:uw             
(W)     or (1|M0)                r95.3<1>:d    r2.1<0;1,0>:d     r2.0<0;1,0>:d    {I@2}
        bfn.0xA8 (16|M0)         r10.0<1>:ud   r68.0<1;0>:ud     r2.1<0;0>:ud      r2.0<0>:ud       {F@1} // s0&(s1|s2)
(W)     shr (1|M0)               r6.7<1>:ud    r95.2<0;1,0>:ud   1:w              
(W&f0.1) cmp (16|M0)  (eq)f0.1   null<1>:d     r95.5<0;1,0>:d    0:w              
        cmp (16|M0)   (eq)f1.0   null<1>:d     r10.0<1;1,0>:d    r95.3<0;1,0>:d   {I@3}
        and (16|M0)              r12.0<1>:d    r66.0<1;1,0>:d    r6.7<0;1,0>:d    {Compacted,I@3}
(W&~f0.1) cmp (16|M0) (gt)f0.1   null<1>:d     r95.5<0;1,0>:ud   0x0:uw             
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r12.0<1;1,0>:d    r6.7<0;1,0>:d    {I@2}
(W)     mov (1|M0)               r5.2<1>:hf    0x1:hf                             
(W)     addc (1|M0)              r15.0<1>:ud   r95.4<0;1,0>:ud   0x1:ud              {AccWrEn}
(f0.1)  sel (16|M0)              r9.0<1>:uw    r5.2<0;1,0>:uw    0x0:uw              {Compacted,F@1}
(f1.0)  sel (16|M0)              acc2.0<1>:uw  r5.2<0;1,0>:uw    0x0:uw             
(W)     mov (1|M0)               r3.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        or (16|M0)    (ne)f1.1   null<1>:uw    r9.0<1;1,0>:uw    acc2.0<1;1,0>:uw {I@3}
(W)     add (1|M0)               r95.6<1>:ud   r3.0<0;1,0>:ud    r95.5<0;1,0>:ud  {I@2}
        mov (16|M0)              r102.0<1>:d   r95.4<0;1,0>:d                  
        mov (16|M0)              r100.0<1>:d   r95.5<0;1,0>:d                  
        mov (16|M0)              r64.0<1>:f    r15.0<0;1,0>:f                   {Compacted}
        mov (16|M0)              r62.0<1>:d    r95.6<0;1,0>:d                   {I@3}
(f1.1)  goto (16|M0)                         L9352                  L9352                
L9288:
(W)     mov (1|M0)               r95.2<1>:d    r6.7<0;1,0>:d                   
(W)     mov (1|M0)               r95.4<1>:d    r15.0<0;1,0>:d                  
(W)     mov (1|M0)               r95.5<1>:d    r95.6<0;1,0>:d                  
(W)     jmpi                                 L8960                                
L9352:
        join (16|M0)                         L14376                                
L9368:
(W)     mov (1|M0)               r2.0<1>:f     8.68805e-44:f                              
(W)     mov (1|M0)               r3.0<1>:hf    0.0:hf                             
        subb (8|M0)              r84.0<1>:ud   r2.0<0;1,0>:ud    r102.0<1;1,0>:ud {AccWrEn,Compacted,A@2}
        add3 (8|M0)              r118.0<1>:ud  -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r100.0<1>:ud    {A@1}
        subb (8|M8)              r85.0<1>:ud   r2.0<0;1,0>:ud    r103.0<1;1,0>:ud {AccWrEn}
        add3 (16|M0)             r116.0<1>:d   r26.0<1;0>:d      r84.0<1;0>:d      -46:w               {I@1}
        cmp (16|M0)   (gt)f1.1   null<1>:d     r116.0<1;1,0>:d   127:w               {I@1}
        add3 (8|M8)              r119.0<1>:ud  -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r101.0<1>:ud   
        add3 (16|M0)             r72.0<1>:d    r32.0<1;0>:d      r95.7<0;0>:d      r84.0<1>:d      
(f1.1)  goto (16|M0)                         L14312                  L14312                
L9520:
        cmp (16|M0)   (gt)f1.0   null<1>:d     r116.0<1;1,0>:d   -127:w              
(f1.0)  goto (16|M0)                         L12000                  L12000                
L9552:
        cmp (16|M0)   (lt)f0.1   null<1>:d     r116.0<1;1,0>:ud  0xFFFFFF6B:ud             
(f0.1)  goto (16|M0)                         L11496                  L11496                
L9584:
(W)     mov (1|M0)               r2.0<1>:f     8.82818e-44:f                              
(W)     mov (1|M0)               r3.0<1>:hf    0.0:hf                              {I@7}
        subb (8|M0)              r120.0<1>:ud  r2.0<0;1,0>:ud    r102.0<1;1,0>:ud {AccWrEn,Compacted,F@2}
        add3 (16|M0)             r122.0<1>:d   r26.0<1;0>:d      r84.0<1;0>:d      104:w              
        add3 (8|M0)              r10.0<1>:ud   -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r100.0<1>:ud    {F@1}
        subb (8|M8)              r121.0<1>:ud  r2.0<0;1,0>:ud    r103.0<1;1,0>:ud {AccWrEn}
        cmp (16|M0)   (gt)f1.0   null<1>:d     r120.0<1;1,0>:ud  r122.0<1;1,0>:ud {I@1}
        add3 (8|M8)              r11.0<1>:ud   -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r101.0<1>:ud   
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r10.0<1;1,0>:d    0:w               {I@1}
(~f1.0) cmp (16|M0)   (gt)f1.0   null<1>:d     r10.0<1;1,0>:ud   0x0:uw             
(f1.0)  goto (16|M0)                         L9808                  L9808                
L9752:
        add3 (16|M0)             r2.0<1>:d     r72.0<1;0>:d      -r120.0<1;0>:d    104:w              
        mov (16|M0)              r66.0<1>:d    0:w                              
        shl (16|M0)              r68.0<1>:d    r68.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
        goto (16|M0)                         L9808                  L11432                
L9808:
        join (16|M0)                         L11432                                
L9824:
        add3 (16|M0)             r118.0<1>:d   r120.0<1;0>:d     -r72.0<1;0>:d     -104:w              
        cmp (16|M0)   (lt)f1.1   null<1>:d     r118.0<1;1,0>:d   2:w               {I@1}
(f1.1)  goto (16|M0)                         L9968                  L9968                
L9872:
        cmp (16|M0)   (eq)f1.0   null<1>:d     r118.0<1;1,0>:d   2:w              
(~f1.0) goto (16|M0)                         L9968                  L10016                
L9904:
        shr (16|M0)              r114.0<1>:ud  r68.0<1;1,0>:ud   1:w              
        and (16|M0)              r84.0<1>:d    r68.0<1;1,0>:d    1:w               {Compacted}
        mov (16|M0)              r108.0<1>:d   0:w                              
        mov (16|M0)              r126.0<1>:f   r114.0<1;1,0>:f                  {Compacted,I@3}
        goto (16|M0)                         L9968                  L10904                
L9968:
        join (16|M0)                         L10016                                
L9984:
        cmp (16|M0)   (eq)f0.1   null<1>:d     r118.0<1;1,0>:d   1:w              
(f0.1)  goto (16|M0)                         L10016                  L10848                
L10016:
        join (16|M0)                         L10848                                
L10032:
        add3 (16|M0)             r2.0<1>:d     r120.0<1;0>:d     -r122.0<1;0>:d    -1:w              
        and (16|M0)   (ne)f1.1   r78.0<1>:d    r2.0<1;1,0>:d     63:w               {I@1}
(f1.1)  goto (16|M0)                         L10104                  L10104                
L10080:
        mov (16|M0)              r116.0<1>:f   r68.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L10104                  L10216                
L10104:
        join (16|M0)                         L10216                                
L10120:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r78.0<1;1,0>:ud   0x20:uw              {I@4}
(~f1.0) add (16|M0)              r2.0<1>:d     r78.0<1;1,0>:d    -32:w              
(~f1.0) shr (16|M0)              r114.0<1>:ud  r66.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.0)  add (16|M0)              r2.0<1>:d     -r78.0<1;1,0>:d   32:w               {Compacted}
(f1.0)  shr (16|M0)              r10.0<1>:ud   r68.0<1;1,0>:ud   r78.0<1;1,0>:d  
(f1.0)  shl (16|M0)              r2.0<1>:d     r66.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.0)  or (16|M0)               r114.0<1>:d   r10.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@1}
        mov (16|M0)              r116.0<1>:f   r114.0<1;1,0>:f                  {Compacted,I@1}
L10216:
        join (16|M0)                         L10848                                
L10232:
        add3 (16|M0)             r78.0<1>:d    r120.0<1;0>:d     -r122.0<1;0>:d    -2:w              
        and (16|M0)   (ne)f0.1   r76.0<1>:d    r78.0<1;1,0>:d    63:w               {I@1}
(f0.1)  goto (16|M0)                         L10304                  L10304                
L10280:
        mov (16|M0)              r114.0<1>:f   r68.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L10304                  L10408                
L10304:
        join (16|M0)                         L10408                                
L10320:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r76.0<1;1,0>:ud   0x20:uw              {I@4}
(~f1.1) add (16|M0)              r2.0<1>:d     r76.0<1;1,0>:d    -32:w              
(~f1.1) shr (16|M0)              r114.0<1>:ud  r66.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.1)  add (16|M0)              r2.0<1>:d     -r76.0<1;1,0>:d   32:w               {Compacted}
(f1.1)  shr (16|M0)              r10.0<1>:ud   r68.0<1;1,0>:ud   r76.0<1;1,0>:d  
(f1.1)  shl (16|M0)              r2.0<1>:d     r66.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.1)  or (16|M0)               r114.0<1>:d   r10.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@1}
L10408:
        join (16|M0)                         L10848                                
L10424:
        and (16|M0)   (ne)f1.0   r18.0<1>:d    r78.0<1;1,0>:d    63:w              
        and (16|M0)              r84.0<1>:d    r114.0<1;1,0>:d   1:w               {Compacted,I@3}
(f1.0)  goto (16|M0)                         L10512                  L10512                
L10464:
        mov (16|M0)              r126.0<1>:d   -1:w                              
        mov (16|M0)              r114.0<1>:d   -1:w                              
        goto (16|M0)                         L10512                  L10696                
L10512:
        join (16|M0)                         L10696                                
L10528:
        cmp (16|M0)   (lt)f0.1   null<1>:d     r18.0<1;1,0>:ud   0x20:uw              {I@7}
(f0.1)  goto (16|M0)                         L10632                  L10632                
L10560:
        add (16|M0)              r2.0<1>:d     r18.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r5.2<1>:hf    -qnan(0x1FF):hf                             
        mov (16|M0)              r126.0<1>:d   0:w                              
        shl (16|M0)              r114.0<1>:d   r5.2<0;1,0>:w     r2.0<1;1,0>:d    {A@1}
        goto (16|M0)                         L10632                  L10696                
L10632:
        join (16|M0)                         L10696                                
L10648:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (16|M0)              r114.0<1>:d   -1:w                              
        shl (16|M0)              r126.0<1>:d   r2.0<0;1,0>:w     r18.0<1;1,0>:d   {F@1}
L10696:
        join (16|M0)                         L10848                                
L10712:
        bfn.0x28 (16|M0)         r2.0<1>:ud    r68.0<1;0>:ud     r126.0<1;0>:ud    r6.2<0>:ud       {I@2} // s0&(s1^s2)
        cmp (16|M0)   (ne)f0.1   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
        bfn.0x28 (16|M0)         r10.0<1>:ud   r66.0<1;0>:ud     r114.0<1;0>:ud    r6.2<0>:ud       // s0&(s1^s2)
(~f0.1) cmp (16|M0)   (ne)f0.1   null<1>:d     r10.0<1;1,0>:d    0:w               {I@1}
(W)     mov (1|M0)               r5.2<1>:hf    -qnan(0x1FF):hf                             
        mov (16|M0)              r126.0<1>:f   r116.0<1;1,0>:f                  {Compacted}
(f0.1)  sel (16|M0)              r12.0<1>:d    r5.2<0;1,0>:w     0:w               {F@2}
        mov (16|M0)              r108.0<1>:d   -r12.0<1;1,0>:d                  {I@1}
        goto (16|M0)                         L10848                  L10904                
L10848:
        join (16|M0)                         L10904                                
L10864:
        mov (16|M0)              r108.0<1>:d   0:w                              
        mov (16|M0)              r84.0<1>:d    0:w                              
        mov (16|M0)              r126.0<1>:f   r68.0<1;1,0>:f                   {Compacted}
L10904:
        join (16|M0)                         L11432                                
L10920:
        and (16|M0)   (ne)f1.1   r74.0<1>:d    r118.0<1;1,0>:d   63:w              
(f1.1)  goto (16|M0)                         L10976                  L10976                
L10952:
        mov (16|M0)              r114.0<1>:f   r68.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L10976                  L11080                
L10976:
        join (16|M0)                         L11080                                
L10992:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r74.0<1;1,0>:ud   0x20:uw              {I@4}
(~f1.0) add (16|M0)              r2.0<1>:d     r74.0<1;1,0>:d    -32:w              
(~f1.0) shr (16|M0)              r114.0<1>:ud  r66.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.0)  add (16|M0)              r2.0<1>:d     -r74.0<1;1,0>:d   32:w               {Compacted}
(f1.0)  shr (16|M0)              r10.0<1>:ud   r68.0<1;1,0>:ud   r74.0<1;1,0>:d  
(f1.0)  shl (16|M0)              r2.0<1>:d     r66.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.0)  or (16|M0)               r114.0<1>:d   r10.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@1}
L11080:
        join (16|M0)                         L11432                                
L11096:
        shl (16|M0)              r2.0<1>:d     r126.0<1;1,0>:d   2:w               {Compacted}
        shl (16|M0)              r10.0<1>:d    r84.0<1;1,0>:d    1:w               {Compacted}
        and (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     4:w               {Compacted,I@2}
        bfn.0xFE (16|M0)         r82.0<1>:ud   r2.0<1;0>:ud      r10.0<1;0>:ud     r108.0<1>:ud     {I@1} // s0|s1|s2
        cmp (16|M0)   (eq)f0.1   null<1>:d     r82.0<1;1,0>:d    0:w               {I@1}
(~f0.1) goto (16|M0)                         L11200                  L11200                
L11168:
        mov (16|M0)              r86.0<1>:d    0:w                              
        goto (16|M0)                         L11200                  L11360                
L11200:
        join (16|M0)                         L11360                                
L11216:
        cmp (16|M0)   (gt)f1.1   null<1>:d     r82.0<1;1,0>:ud   0x4:uw             
(~f1.1) goto (16|M0)                         L11280                  L11280                
L11248:
        mov (16|M0)              r86.0<1>:d    1:w                              
        goto (16|M0)                         L11280                  L11360                
L11280:
        join (16|M0)                         L11360                                
L11296:
        and (16|M0)   (ne)f1.1   null<1>:d     r114.0<1;1,0>:d   1:w              
(W)     mov (1|M0)               r2.0<1>:hf    0x1:hf                             
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r82.0<1;1,0>:d    4:w              
(f1.1)  sel (16|M0)              r86.0<1>:d    r2.0<0;1,0>:w     0:w               {F@1}
L11360:
        join (16|M0)                         L11432                                
L11376:
        add (16|M0)              r2.0<1>:d     r86.0<1;1,0>:d    r114.0<1;1,0>:d  {Compacted,I@2}
        cmp (16|M0)   (gt)f1.1   null<1>:d     r2.0<1;1,0>:ud    0x7FFFFF:ud              {I@1}
(W)     mov (1|M0)               r5.1<1>:f     0x800000:f                               {Compacted}
(~f1.1) sel (16|M0)              r68.0<1>:d    r2.0<1;1,0>:d     0:w              
(f1.1)  sel (16|M0)              r66.0<1>:d    r5.1<0;1,0>:d     0:w               {Compacted,F@1}
L11432:
        join (16|M0)                         L11496                                
L11448:
        and (16|M0)              r2.0<1>:d     r44.0<1;1,0>:d    -2147483648:d              
        bfn.0xFE (16|M0)         r26.0<1>:ud   r2.0<1;0>:ud      r66.0<1;0>:ud     r68.0<1>:ud      {I@1} // s0|s1|s2
        goto (16|M0)                         L11496                  L14536                
L11496:
        join (16|M0)                         L12000                                
L11512:
        and (16|M0)   (ne)f1.0   r106.0<1>:d   r84.0<1;1,0>:d    63:w              
(f1.0)  goto (16|M0)                         L11592                  L11592                
L11544:
        mov (16|M0)              r118.0<1>:d   -1:w                              
        mov (16|M0)              r16.0<1>:d    -1:w                              
        goto (16|M0)                         L11592                  L11776                
L11592:
        join (16|M0)                         L11776                                
L11608:
        cmp (16|M0)   (lt)f0.1   null<1>:d     r106.0<1;1,0>:ud  0x20:uw              {I@6}
(f0.1)  goto (16|M0)                         L11712                  L11712                
L11640:
        add (16|M0)              r2.0<1>:d     r106.0<1;1,0>:d   -32:w               {Compacted}
(W)     mov (1|M0)               r5.2<1>:hf    -qnan(0x1FF):hf                             
        mov (16|M0)              r118.0<1>:d   0:w                              
        shl (16|M0)              r16.0<1>:d    r5.2<0;1,0>:w     r2.0<1;1,0>:d    {A@1}
        goto (16|M0)                         L11712                  L11776                
L11712:
        join (16|M0)                         L11776                                
L11728:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (16|M0)              r16.0<1>:d    -1:w                              
        shl (16|M0)              r118.0<1>:d   r2.0<0;1,0>:w     r106.0<1;1,0>:d  {F@1}
L11776:
        join (16|M0)                         L12000                                
L11792:
        bfn.0x28 (16|M0)         r2.0<1>:ud    r68.0<1;0>:ud     r118.0<1;0>:ud    r6.2<0>:ud       {I@2} // s0&(s1^s2)
        cmp (16|M0)   (ne)f0.1   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
        bfn.0x28 (16|M0)         r10.0<1>:ud   r66.0<1;0>:ud     r16.0<1;0>:ud     r6.2<0>:ud       // s0&(s1^s2)
        cmp (16|M0)   (gt)f1.1   null<1>:d     r44.0<1;1,0>:d    -1:w              
(~f0.1) cmp (16|M0)   (ne)f0.1   null<1>:d     r10.0<1;1,0>:d    0:w               {I@2}
(f0.1)  cmp (16|M0)   (eq)f0.1   null<1>:d     r116.0<1;1,0>:d   -150:w              
(f1.1)  goto (16|M0)                         L11944                  L11944                
L11904:
(W)     mov (1|M0)               r2.0<1>:ud    0x80000001:ud                             
(f0.1)  sel (16|M0)              r26.0<1>:f    r2.0<0;1,0>:f     -0.0:f               {Compacted,I@1}
        goto (16|M0)                         L11944                  L14536                
L11944:
        join (16|M0)                         L12000                                
L11960:
(W)     mov (1|M0)               r2.0<1>:ud    0x1:ud                              {F@1}
(f0.1)  sel (16|M0)              r26.0<1>:f    r2.0<0;1,0>:f     0.0:f               {Compacted,I@1}
        goto (16|M0)                         L12000                  L14536                
L12000:
        join (16|M0)                         L14312                                
L12016:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r84.0<1;1,0>:ud   0x18:uw             
        add3 (16|M0)             r86.0<1>:d    r26.0<1;0>:d      r84.0<1;0>:d      81:w               {F@1}
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r118.0<1;1,0>:d   0:w              
(f1.0)  goto (16|M0)                         L14000                  L14000                
L12080:
        shl (16|M0)              r2.0<1>:d     r64.0<1;1,0>:d    1:w               {Compacted}
        shr (16|M0)              r10.0<1>:ud   r64.0<1;1,0>:ud   31:w              
        shl (16|M0)              r12.0<1>:d    r62.0<1;1,0>:d    1:w               {Compacted}
        cmp (16|M0)   (lt)f0.1   null<1>:d     r2.0<1;1,0>:ud    0x4E:uw              {I@3}
        or (16|M0)               r12.0<1>:d    r12.0<1;1,0>:d    r10.0<1;1,0>:d   {Compacted,I@2}
(f0.1)  cmp (16|M0)   (eq)f0.1   null<1>:d     r12.0<1;1,0>:d    0:w               {I@1}
(~f0.1) cmp (16|M0)   (lt)f0.1   null<1>:d     r12.0<1;1,0>:d    0:w              
(f0.1)  goto (16|M0)                         L12312                  L12312                
L12184:
        cmp (16|M0)   (eq)f0.1   null<1>:d     r64.0<1;1,0>:d    39:w              
(f0.1)  cmp (16|M0)   (eq)f0.1   null<1>:d     r62.0<1;1,0>:d    0:w              
(~f0.1) goto (16|M0)                         L12312                  L12376                
L12232:
        shr (16|M0)              r114.0<1>:ud  r68.0<1;1,0>:ud   1:w              
        mov (16|M0)              r70.0<1>:d    0:w                              
        mov (16|M0)              r98.0<1>:d    0:w                              
        mov (16|M0)              r112.0<1>:f   r114.0<1;1,0>:f                  {Compacted,I@3}
        mov (16|M0)              r114.0<1>:f   r68.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L12312                  L13472                
L12312:
        join (16|M0)                         L12376                                
L12328:
        cmp (16|M0)   (eq)f1.1   null<1>:d     r64.0<1;1,0>:d    38:w              
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r62.0<1;1,0>:d    0:w              
(f1.1)  goto (16|M0)                         L12376                  L13392                
L12376:
        join (16|M0)                         L13392                                
L12392:
        add (16|M0)              r2.0<1>:d     -r64.0<1;1,0>:d   39:w               {Compacted}
        and (16|M0)   (ne)f1.0   r98.0<1>:d    r2.0<1;1,0>:d     63:w               {I@1}
        add (16|M0)              r96.0<1>:d    -r64.0<1;1,0>:d   40:w               {Compacted}
(f1.0)  goto (16|M0)                         L12464                  L12464                
L12440:
        mov (16|M0)              r92.0<1>:f    r68.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L12464                  L12576                
L12464:
        join (16|M0)                         L12576                                
L12480:
        cmp (16|M0)   (lt)f0.1   null<1>:d     r98.0<1;1,0>:ud   0x20:uw              {I@5}
(~f0.1) add (16|M0)              r2.0<1>:d     r98.0<1;1,0>:d    -32:w              
(~f0.1) shr (16|M0)              r114.0<1>:ud  r66.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f0.1)  add (16|M0)              r2.0<1>:d     -r98.0<1;1,0>:d   32:w               {Compacted}
(f0.1)  shr (16|M0)              r10.0<1>:ud   r68.0<1;1,0>:ud   r98.0<1;1,0>:d  
(f0.1)  shl (16|M0)              r2.0<1>:d     r66.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f0.1)  or (16|M0)               r114.0<1>:d   r10.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@1}
        mov (16|M0)              r92.0<1>:f    r114.0<1;1,0>:f                  {Compacted,I@1}
L12576:
        join (16|M0)                         L13392                                
L12592:
        add (16|M0)              r110.0<1>:d   -r64.0<1;1,0>:d   38:w               {Compacted}
        and (16|M0)   (ne)f1.1   r76.0<1>:d    r110.0<1;1,0>:d   63:w               {I@1}
(f1.1)  goto (16|M0)                         L12656                  L12656                
L12632:
        mov (16|M0)              r114.0<1>:f   r68.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L12656                  L12760                
L12656:
        join (16|M0)                         L12760                                
L12672:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r76.0<1;1,0>:ud   0x20:uw              {I@4}
(~f1.0) add (16|M0)              r2.0<1>:d     r76.0<1;1,0>:d    -32:w              
(~f1.0) shr (16|M0)              r114.0<1>:ud  r66.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.0)  add (16|M0)              r2.0<1>:d     -r76.0<1;1,0>:d   32:w               {Compacted}
(f1.0)  shr (16|M0)              r10.0<1>:ud   r68.0<1;1,0>:ud   r76.0<1;1,0>:d  
(f1.0)  shl (16|M0)              r2.0<1>:d     r66.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.0)  or (16|M0)               r114.0<1>:d   r10.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@1}
L12760:
        join (16|M0)                         L13392                                
L12776:
        and (16|M0)   (ne)f0.1   r74.0<1>:d    r110.0<1;1,0>:d   63:w              
        and (16|M0)              r98.0<1>:d    r114.0<1;1,0>:d   1:w               {Compacted,I@3}
(f0.1)  goto (16|M0)                         L12864                  L12864                
L12816:
        mov (16|M0)              r124.0<1>:d   -1:w                              
        mov (16|M0)              r106.0<1>:d   -1:w                              
        goto (16|M0)                         L12864                  L13048                
L12864:
        join (16|M0)                         L13048                                
L12880:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r74.0<1;1,0>:ud   0x20:uw              {I@7}
(f1.1)  goto (16|M0)                         L12984                  L12984                
L12912:
        add (16|M0)              r2.0<1>:d     r74.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r5.2<1>:hf    -qnan(0x1FF):hf                             
        mov (16|M0)              r124.0<1>:d   0:w                              
        shl (16|M0)              r106.0<1>:d   r5.2<0;1,0>:w     r2.0<1;1,0>:d    {A@1}
        goto (16|M0)                         L12984                  L13048                
L12984:
        join (16|M0)                         L13048                                
L13000:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (16|M0)              r106.0<1>:d   -1:w                              
        shl (16|M0)              r124.0<1>:d   r2.0<0;1,0>:w     r74.0<1;1,0>:d   {F@1}
L13048:
        join (16|M0)                         L13392                                
L13064:
        bfn.0x28 (16|M0)         r2.0<1>:ud    r68.0<1;0>:ud     r124.0<1;0>:ud    r6.2<0>:ud       {I@2} // s0&(s1^s2)
        cmp (16|M0)   (ne)f1.0   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
        bfn.0x28 (16|M0)         r10.0<1>:ud   r66.0<1;0>:ud     r106.0<1;0>:ud    r6.2<0>:ud       // s0&(s1^s2)
(~f1.0) cmp (16|M0)   (ne)f1.0   null<1>:d     r10.0<1;1,0>:d    0:w               {I@1}
(W)     mov (1|M0)               r5.2<1>:hf    -qnan(0x1FF):hf                             
(f1.0)  sel (16|M0)              r12.0<1>:d    r5.2<0;1,0>:w     0:w               {F@1}
        and (16|M0)   (ne)f1.0   r72.0<1>:d    r96.0<1;1,0>:d    63:w              
        mov (16|M0)              r70.0<1>:d    -r12.0<1;1,0>:d                  {I@2}
(f1.0)  goto (16|M0)                         L13232                  L13232                
L13208:
        mov (16|M0)              r114.0<1>:f   r68.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L13232                  L13336                
L13232:
        join (16|M0)                         L13336                                
L13248:
        cmp (16|M0)   (lt)f0.1   null<1>:d     r72.0<1;1,0>:ud   0x20:uw              {I@5}
(~f0.1) add (16|M0)              r2.0<1>:d     r72.0<1;1,0>:d    -32:w              
(~f0.1) shr (16|M0)              r114.0<1>:ud  r66.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f0.1)  add (16|M0)              r2.0<1>:d     -r72.0<1;1,0>:d   32:w               {Compacted}
(f0.1)  shr (16|M0)              r10.0<1>:ud   r68.0<1;1,0>:ud   r72.0<1;1,0>:d  
(f0.1)  shl (16|M0)              r2.0<1>:d     r66.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f0.1)  or (16|M0)               r114.0<1>:d   r10.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@1}
L13336:
        join (16|M0)                         L13392                                
L13352:
        mov (16|M0)              r112.0<1>:f   r114.0<1;1,0>:f                  {Compacted,I@2}
        mov (16|M0)              r114.0<1>:d   r92.0<1;1,0>:d                   {F@1}
        goto (16|M0)                         L13392                  L13472                
L13392:
        join (16|M0)                         L13472                                
L13408:
        shr (16|M0)              r114.0<1>:ud  r68.0<1;1,0>:ud   2:w              
        and (16|M0)              r98.0<1>:d    r68.0<1;1,0>:d    1:w               {Compacted}
        mov (16|M0)              r70.0<1>:d    0:w                              
        mov (16|M0)              r112.0<1>:f   r114.0<1;1,0>:f                  {Compacted,I@3}
        shr (16|M0)              r114.0<1>:ud  r68.0<1;1,0>:ud   1:w               {F@1}
L13472:
        join (16|M0)                         L14000                                
L13488:
        shl (16|M0)              r2.0<1>:d     r114.0<1;1,0>:d   2:w               {Compacted,I@2}
        shl (16|M0)              r10.0<1>:d    r98.0<1;1,0>:d    1:w               {Compacted}
        and (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     4:w               {Compacted,I@2}
        bfn.0xFE (16|M0)         r116.0<1>:ud  r2.0<1;0>:ud      r10.0<1;0>:ud     r70.0<1>:ud      {I@1} // s0|s1|s2
        cmp (16|M0)   (eq)f1.1   null<1>:d     r116.0<1;1,0>:d   0:w               {I@1}
        and (16|M0)              r122.0<1>:d   r112.0<1;1,0>:d   8388607:d              
(~f1.1) goto (16|M0)                         L13608                  L13608                
L13576:
        mov (16|M0)              r104.0<1>:d   0:w                              
        goto (16|M0)                         L13608                  L13768                
L13608:
        join (16|M0)                         L13768                                
L13624:
        cmp (16|M0)   (gt)f1.0   null<1>:d     r116.0<1;1,0>:ud  0x4:uw             
(~f1.0) goto (16|M0)                         L13688                  L13688                
L13656:
        mov (16|M0)              r104.0<1>:d   1:w                              
        goto (16|M0)                         L13688                  L13768                
L13688:
        join (16|M0)                         L13768                                
L13704:
        and (16|M0)   (ne)f0.1   null<1>:d     r112.0<1;1,0>:d   1:w              
(W)     mov (1|M0)               r2.0<1>:hf    0x1:hf                             
(f0.1)  cmp (16|M0)   (eq)f0.1   null<1>:d     r116.0<1;1,0>:d   4:w              
(f0.1)  sel (16|M0)              r104.0<1>:d   r2.0<0;1,0>:w     0:w               {F@1}
L13768:
        join (16|M0)                         L14000                                
L13784:
        add (16|M0)              r82.0<1>:d    r122.0<1;1,0>:d   r104.0<1;1,0>:d  {Compacted,I@2}
        cmp (16|M0)   (gt)f1.0   null<1>:d     r82.0<1;1,0>:ud   0x7FFFFF:ud              {I@1}
        add3 (16|M0)             r2.0<1>:d     r26.0<1;0>:d      r84.0<1;0>:d      82:w              
(f1.0)  sel (16|M0)              r72.0<1>:d    r2.0<1;1,0>:d     r86.0<1;1,0>:d   {Compacted,I@1}
        cmp (16|M0)   (eq)f0.1   null<1>:d     r72.0<1;1,0>:d    255:w               {I@1}
(f0.1)  goto (16|M0)                         L13936                  L13936                
L13864:
(~f1.0) sel (16|M0)              r2.0<1>:d     r82.0<1;1,0>:d    0:w              
        and (16|M0)              r10.0<1>:d    r44.0<1;1,0>:d    -2147483648:d              
        shl (16|M0)              r12.0<1>:d    r72.0<1;1,0>:d    23:w               {Compacted}
        bfn.0xFE (16|M0)         r26.0<1>:ud   r10.0<1;0>:ud     r12.0<1;0>:ud     r2.0<1>:ud       {I@1} // s0|s1|s2
        goto (16|M0)                         L13936                  L14536                
L13936:
        join (16|M0)                         L14000                                
L13952:
        cmp (16|M0)   (gt)f1.1   null<1>:d     r44.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r2.0<1>:f     inf:f                               {Compacted,I@4}
(f1.1)  sel (16|M0)              r26.0<1>:f    r2.0<0;1,0>:f     -inf:f               {Compacted,F@1}
        goto (16|M0)                         L14000                  L14536                
L14000:
        join (16|M0)                         L14312                                
L14016:
        and (16|M0)   (ne)f1.1   r64.0<1>:d    r84.0<1;1,0>:d    63:w               {F@1}
(f1.1)  goto (16|M0)                         L14080                  L14080                
L14048:
        mov (16|M0)              r92.0<1>:d    -1:w                              
        goto (16|M0)                         L14080                  L14208                
L14080:
        join (16|M0)                         L14208                                
L14096:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r64.0<1;1,0>:ud   0x20:uw              {I@5}
(f1.0)  goto (16|M0)                         L14160                  L14160                
L14128:
        mov (16|M0)              r92.0<1>:d    0:w                              
        goto (16|M0)                         L14160                  L14208                
L14160:
        join (16|M0)                         L14208                                
L14176:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                             
        shl (16|M0)              r92.0<1>:d    r2.0<0;1,0>:w     r64.0<1;1,0>:d   {F@1}
L14208:
        join (16|M0)                         L14312                                
L14224:
        bfn.0x28 (16|M0)         r2.0<1>:ud    r68.0<1;0>:ud     r92.0<1;0>:ud     r6.2<0>:ud       {I@2} // s0&(s1^s2)
        add (16|M0)              r10.0<1>:d    -r84.0<1;1,0>:d   23:w               {Compacted}
        and (16|M0)              r12.0<1>:d    r44.0<1;1,0>:d    -2147483648:d              
        shl (16|M0)              r14.0<1>:d    r86.0<1;1,0>:d    23:w               {Compacted}
        shl (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     r10.0<1;1,0>:d   {Compacted,I@3}
        bfn.0xFE (16|M0)         r26.0<1>:ud   r12.0<1;0>:ud     r14.0<1;0>:ud     r2.0<1>:ud       {I@1} // s0|s1|s2
        goto (16|M0)                         L14312                  L14536                
L14312:
        join (16|M0)                         L14376                                
L14328:
        cmp (16|M0)   (gt)f1.0   null<1>:d     r44.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r2.0<1>:f     inf:f                               {Compacted,I@4}
(f1.0)  sel (16|M0)              r26.0<1>:f    r2.0<0;1,0>:f     -inf:f               {Compacted,F@1}
        goto (16|M0)                         L14376                  L14536                
L14376:
        join (16|M0)                         L14440                                
L14392:
        cmp (16|M0)   (lt)f0.1   null<1>:d     r44.0<1;1,0>:d    0:w              
(W)     mov (1|M0)               r2.0<1>:f     -0.0:f                               {Compacted}
(f0.1)  sel (16|M0)              r26.0<1>:f    r2.0<0;1,0>:f     0.0:f               {Compacted,F@1}
        goto (16|M0)                         L14440                  L14536                
L14440:
        join (16|M0)                         L14504                                
L14456:
        cmp (16|M0)   (gt)f1.1   null<1>:d     r44.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r2.0<1>:f     inf:f                               {Compacted}
(f1.1)  sel (16|M0)              r26.0<1>:f    r2.0<0;1,0>:f     -inf:f               {Compacted,F@1}
        goto (16|M0)                         L14504                  L14536                
L14504:
        join (16|M0)                         L14536                                
L14520:
        bfn.0xF8 (16|M0)         r26.0<1>:ud   r44.0<1;0>:ud     r6.4<0;0>:ud      r6.3<0>:ud       {F@1} // s0&s1|s2
L14536:
        join (16|M0)                         L14600                                
L14552:
(W)     add (1|M0)               r6.1<1>:d     r6.1<0;1,0>:d     1:w               {Compacted}
        sel (16|M0)   (gt)f0.0   r24.0<1>:f    (abs)r26.0<1;1,0>:f  r24.0<1;1,0>:f {Compacted,I@3}
(W)     cmp (16|M0)   (lt)f0.1   null<1>:d     r6.1<0;1,0>:ud    r6.0<0;1,0>:ud   {I@1}
(f0.1)  goto.b (16|M0)                       L14600                  L1488                
L14600:
        join (16|M0)                         L27944                                
L14616:
        sync.nop                             null                             {Compacted,F@1}
        math.inv (16|M0)         r2.0<1>:f     r24.0<1;1,0>:f                   {$8}
        cmp (16|M0)   (gt)f1.1   null<1>:f     r24.0<1;1,0>:f    0.0:f              
        mul (16|M0)              acc0.0<1>:f   r2.0<1;1,0>:f     127.0:f               {$8.dst}
        mul (16|M0)              r44.0<1>:f    r24.0<1;1,0>:f    7.874016e-03:f              
(f1.1)  sel (16|M0)              r32.0<1>:f    acc0.0<1;1,0>:f   0.0:f               {Compacted}
(W)     mov (1|M0)               r6.1<1>:d     0:w                              
L14712:
(W)     shl (1|M0)               r7.2<1>:d     r6.1<0;1,0>:d     2:w               {I@1}
(W)     shr (1|M0)               r6.7<1>:ud    r6.1<0;1,0>:ud    30:w              
        sync.nop                             null                             {Compacted,$3.src}
        addc (8|M0)              r2.0<1>:ud    r56.0<1;1,0>:ud   r7.2<0;1,0>:ud   {AccWrEn,Compacted,A@1}
(W)     mov (1|M0)               r5.2<1>:hf    0x1:hf                             
        mov (8|M0)               r10.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        addc (8|M8)              r3.0<1>:ud    r57.0<1;1,0>:ud   r7.2<0;1,0>:ud   {AccWrEn}
        add3 (8|M0)              r11.1<2>:ud   r10.0<1;0>:ud     r54.0<1;0>:ud     r6.7<0>:ud       {I@2}
        mov (8|M8)               r16.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mov (8|M0)               r11.0<2>:d    r2.0<1;1,0>:d                   
        add3 (8|M8)              r13.1<2>:ud   r16.0<1;0>:ud     r55.0<1;0>:ud     r6.7<0>:ud       {I@2}
        mov (8|M8)               r13.0<2>:d    r3.0<1;1,0>:d                   
        send.ugm (16|M0)         r18      r11     null:0  0x0            0x08280580           {A@1,$9} // wr:4+0, rd:2; load.ugm.d32.a64.ca.ca
        mov (16|M0)              r124.0<1>:f   r18.0<1;1,0>:d                   {Compacted,$9.dst}
        shr (16|M0)              r104.0<1>:ud  r124.0<1;1,0>:ud  23:w               {F@1}
        and (16|M0)   (ne)f1.1   r100.0<1>:d   r124.0<1;1,0>:d   8388607:d              
        and (16|M0)              r120.0<1>:d   r104.0<1;1,0>:d   255:w               {Compacted,I@2}
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r120.0<1;1,0>:d   255:w               {I@1}
(f1.1)  sel (16|M0)              acc0.0<1>:uw  r5.2<0;1,0>:uw    0x0:uw             
(W)     mov (1|M0)               f1.1<1>:uw    r95.0<0;1,0>:uw                 
(f1.1)  sel (16|M0)              acc2.0<1>:uw  r5.2<0;1,0>:uw    0x0:uw             
        or (16|M0)    (ne)f1.0   null<1>:uw    acc0.0<1;1,0>:uw  acc2.0<1;1,0>:uw
(~f1.0) goto (16|M0)                         L15064                  L15064                
L15032:
        mov (16|M0)              r18.0<1>:ud   0x7FC00000:ud                             
        goto (16|M0)                         L15064                  L21160                
L15064:
        join (16|M0)                         L21160                                
L15080:
        cmp (16|M0)   (eq)f1.0   null<1>:d     r100.0<1;1,0>:d   0:w              
(W)     mov (1|M0)               r2.0<1>:hf    0x1:hf                             
        xor (16|M0)              r74.0<1>:d    r42.0<1;1,0>:d    r124.0<1;1,0>:d  {Compacted}
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r120.0<1;1,0>:d   255:w              
(f0.0)  sel (16|M0)              acc0.0<1>:uw  r2.0<0;1,0>:uw    0x0:uw              {F@1}
(f1.0)  sel (16|M0)              acc2.0<1>:uw  r2.0<0;1,0>:uw    0x0:uw             
        or (16|M0)    (ne)f0.1   null<1>:uw    acc2.0<1;1,0>:uw  acc0.0<1;1,0>:uw
(f0.1)  goto (16|M0)                         L21128                  L21128                
L15200:
        cmp (16|M0)   (eq)f0.1   null<1>:d     r38.0<1;1,0>:d    0:w              
        or (16|M0)               r2.0<1>:d     r120.0<1;1,0>:d   r100.0<1;1,0>:d  {Compacted}
(~f0.1) cmp (16|M0)   (eq)f0.1   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
(~f0.1) goto (16|M0)                         L15288                  L15288                
L15256:
        mov (16|M0)              r18.0<1>:ud   0x0:ud                             
        goto (16|M0)                         L15288                  L21160                
L15288:
        join (16|M0)                         L21128                                
L15304:
        cmp (16|M0)   (eq)f0.1   null<1>:d     r120.0<1;1,0>:d   0:w              
        add (16|M0)              r92.0<1>:d    r120.0<1;1,0>:d   -127:w               {Compacted}
(f0.1)  mov (16|M0)              r92.0<1>:d    -126:w                              
        add (16|M0)              r72.0<1>:d    r92.0<1;1,0>:d    r36.0<1;1,0>:d   {Compacted,I@1}
        cmp (16|M0)   (gt)f1.1   null<1>:d     r72.0<1;1,0>:d    127:w               {I@1}
(f1.1)  goto (16|M0)                         L21064                  L21064                
L15384:
        or (16|M0)    (eq)f1.0   null<4>:b     r104.0<1;1,0>:d   r40.0<1;1,0>:d  
(f1.0)  goto (16|M0)                         L21000                  L21000                
L15416:
(W)     mov (1|M0)               r2.0<1>:hf    0.0:hf                             
(W)     mov (1|M0)               r95.6<1>:d    0:w                              
(f0.1)  sel (16|M0)              r10.0<1>:d    r2.0<0;1,0>:w     8388608:d               {F@1}
        or (16|M0)               r10.0<1>:d    r10.0<1;1,0>:d    r100.0<1;1,0>:d  {Compacted,I@1}
        mul (8|M0)               acc0.0<1>:ud  r10.0<1;1,0>:ud   r34.0<2;1,0>:uw  {I@1}
        mach (8|M0)              r12.0<1>:ud   r10.0<1;1,0>:ud   r34.0<1;1,0>:ud  {AccWrEn,Compacted}
(W)     mov (1|M0)               r95.3<1>:f    -0.0:f                               {Compacted}
        mov (8|M0)               r14.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mul (8|M8)               acc0.0<1>:ud  r11.0<1;1,0>:ud   r35.0<2;1,0>:uw 
        mach (8|M8)              r13.0<1>:ud   r11.0<1;1,0>:ud   r35.0<1;1,0>:ud  {AccWrEn}
(W)     mov (2|M0)               r95.4<1>:d    0:w                              
        mov (8|M8)               r15.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mov (16|M0)              r78.0<1>:f    r12.0<1;1,0>:f                   {Compacted,A@3}
        mov (16|M0)              r80.0<1>:f    r14.0<1;1,0>:f                   {Compacted,I@1}
L15584:
(W)     shl (1|M0)               r2.0<1>:d     r95.3<0;1,0>:d    31:w               {Compacted,F@3}
(W)     shr (1|M0)               r2.1<1>:ud    r95.6<0;1,0>:ud   1:w              
(W)     cmp (16|M0)   (gt)f1.1   null<1>:d     r95.4<0;1,0>:ud   0x3E:uw             
(W)     or (1|M0)                r95.6<1>:d    r2.1<0;1,0>:d     r2.0<0;1,0>:d    {I@2}
        bfn.0xA8 (16|M0)         r10.0<1>:ud   r80.0<1;0>:ud     r2.1<0;0>:ud      r2.0<0>:ud       {F@1} // s0&(s1|s2)
(W)     shr (1|M0)               r95.2<1>:ud   r95.3<0;1,0>:ud   1:w              
(W&f1.1) cmp (16|M0)  (eq)f1.1   null<1>:d     r95.5<0;1,0>:d    0:w              
        cmp (16|M0)   (eq)f0.1   null<1>:d     r10.0<1;1,0>:d    r95.6<0;1,0>:d   {I@3}
        and (16|M0)              r12.0<1>:d    r78.0<1;1,0>:d    r95.2<0;1,0>:d   {Compacted,I@3}
(W&~f1.1) cmp (16|M0) (gt)f1.1   null<1>:d     r95.5<0;1,0>:ud   0x0:uw             
(f0.1)  cmp (16|M0)   (eq)f0.1   null<1>:d     r12.0<1;1,0>:d    r95.2<0;1,0>:d   {I@2}
(W)     mov (1|M0)               r5.2<1>:hf    0x1:hf                             
(W)     addc (1|M0)              r15.0<1>:ud   r95.4<0;1,0>:ud   0x1:ud              {AccWrEn}
(f1.1)  sel (16|M0)              r9.0<1>:uw    r5.2<0;1,0>:uw    0x0:uw              {Compacted,F@1}
(f0.1)  sel (16|M0)              acc2.0<1>:uw  r5.2<0;1,0>:uw    0x0:uw             
(W)     mov (1|M0)               r3.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        or (16|M0)    (ne)f1.0   null<1>:uw    r9.0<1;1,0>:uw    acc2.0<1;1,0>:uw {I@3}
(W)     add (1|M0)               r95.7<1>:ud   r3.0<0;1,0>:ud    r95.5<0;1,0>:ud  {I@2}
        mov (16|M0)              r114.0<1>:d   r95.4<0;1,0>:d                  
        mov (16|M0)              r112.0<1>:d   r95.5<0;1,0>:d                  
        mov (16|M0)              r76.0<1>:f    r15.0<0;1,0>:f                   {Compacted}
        mov (16|M0)              r90.0<1>:d    r95.7<0;1,0>:d                   {I@3}
(f1.0)  goto (16|M0)                         L15976                  L15976                
L15912:
(W)     mov (1|M0)               r95.3<1>:d    r95.2<0;1,0>:d                  
(W)     mov (1|M0)               r95.4<1>:d    r15.0<0;1,0>:d                  
(W)     mov (1|M0)               r95.5<1>:d    r95.7<0;1,0>:d                  
(W)     jmpi                                 L15584                                
L15976:
        join (16|M0)                         L21000                                
L15992:
(W)     mov (1|M0)               r2.0<1>:f     8.68805e-44:f                              
(W)     mov (1|M0)               r3.0<1>:hf    0.0:hf                             
        subb (8|M0)              r84.0<1>:ud   r2.0<0;1,0>:ud    r114.0<1;1,0>:ud {AccWrEn,Compacted,A@2}
        add3 (8|M0)              r14.0<1>:ud   -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r112.0<1>:ud    {A@1}
        subb (8|M8)              r85.0<1>:ud   r2.0<0;1,0>:ud    r115.0<1;1,0>:ud {AccWrEn}
        add3 (16|M0)             r12.0<1>:d    r72.0<1;0>:d      r84.0<1;0>:d      -46:w               {I@1}
        cmp (16|M0)   (gt)f0.1   null<1>:d     r12.0<1;1,0>:d    127:w               {I@1}
        add3 (8|M8)              r15.0<1>:ud   -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r113.0<1>:ud   
        add3 (16|M0)             r22.0<1>:d    r92.0<1;0>:d      r36.0<1;0>:d      r84.0<1>:d      
(f0.1)  goto (16|M0)                         L20936                  L20936                
L16144:
        cmp (16|M0)   (gt)f1.1   null<1>:d     r12.0<1;1,0>:d    -127:w              
(f1.1)  goto (16|M0)                         L18624                  L18624                
L16176:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r12.0<1;1,0>:ud   0xFFFFFF6B:ud             
(f1.0)  goto (16|M0)                         L18120                  L18120                
L16208:
(W)     mov (1|M0)               r2.0<1>:f     8.82818e-44:f                              
(W)     mov (1|M0)               r3.0<1>:hf    0.0:hf                              {I@7}
        subb (8|M0)              r66.0<1>:ud   r2.0<0;1,0>:ud    r114.0<1;1,0>:ud {AccWrEn,Compacted,F@2}
        add3 (16|M0)             r68.0<1>:d    r72.0<1;0>:d      r84.0<1;0>:d      104:w              
        add3 (8|M0)              r10.0<1>:ud   -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r112.0<1>:ud    {F@1}
        subb (8|M8)              r67.0<1>:ud   r2.0<0;1,0>:ud    r115.0<1;1,0>:ud {AccWrEn}
        cmp (16|M0)   (gt)f1.1   null<1>:d     r66.0<1;1,0>:ud   r68.0<1;1,0>:ud  {I@1}
        add3 (8|M8)              r11.0<1>:ud   -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r113.0<1>:ud   
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r10.0<1;1,0>:d    0:w               {I@1}
(~f1.1) cmp (16|M0)   (gt)f1.1   null<1>:d     r10.0<1;1,0>:ud   0x0:uw             
(f1.1)  goto (16|M0)                         L16432                  L16432                
L16376:
        add3 (16|M0)             r2.0<1>:d     r22.0<1;0>:d      -r66.0<1;0>:d     104:w              
        mov (16|M0)              r78.0<1>:d    0:w                              
        shl (16|M0)              r80.0<1>:d    r80.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
        goto (16|M0)                         L16432                  L18056                
L16432:
        join (16|M0)                         L18056                                
L16448:
        add3 (16|M0)             r64.0<1>:d    r66.0<1;0>:d      -r22.0<1;0>:d     -104:w              
        cmp (16|M0)   (lt)f0.1   null<1>:d     r64.0<1;1,0>:d    2:w               {I@1}
(f0.1)  goto (16|M0)                         L16592                  L16592                
L16496:
        cmp (16|M0)   (eq)f1.1   null<1>:d     r64.0<1;1,0>:d    2:w              
(~f1.1) goto (16|M0)                         L16592                  L16640                
L16528:
        shr (16|M0)              r126.0<1>:ud  r80.0<1;1,0>:ud   1:w              
        and (16|M0)              r86.0<1>:d    r80.0<1;1,0>:d    1:w               {Compacted}
        mov (16|M0)              r90.0<1>:d    0:w                              
        mov (16|M0)              r98.0<1>:f    r126.0<1;1,0>:f                  {Compacted,I@3}
        goto (16|M0)                         L16592                  L17528                
L16592:
        join (16|M0)                         L16640                                
L16608:
        cmp (16|M0)   (eq)f1.0   null<1>:d     r64.0<1;1,0>:d    1:w              
(f1.0)  goto (16|M0)                         L16640                  L17472                
L16640:
        join (16|M0)                         L17472                                
L16656:
        add3 (16|M0)             r2.0<1>:d     r66.0<1;0>:d      -r68.0<1;0>:d     -1:w              
        and (16|M0)   (ne)f0.1   r70.0<1>:d    r2.0<1;1,0>:d     63:w               {I@1}
(f0.1)  goto (16|M0)                         L16728                  L16728                
L16704:
        mov (16|M0)              r62.0<1>:f    r80.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L16728                  L16840                
L16728:
        join (16|M0)                         L16840                                
L16744:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r70.0<1;1,0>:ud   0x20:uw              {I@4}
(~f1.1) add (16|M0)              r2.0<1>:d     r70.0<1;1,0>:d    -32:w              
(~f1.1) shr (16|M0)              r126.0<1>:ud  r78.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.1)  add (16|M0)              r2.0<1>:d     -r70.0<1;1,0>:d   32:w               {Compacted}
(f1.1)  shr (16|M0)              r10.0<1>:ud   r80.0<1;1,0>:ud   r70.0<1;1,0>:d  
(f1.1)  shl (16|M0)              r2.0<1>:d     r78.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.1)  or (16|M0)               r126.0<1>:d   r10.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@1}
        mov (16|M0)              r62.0<1>:f    r126.0<1;1,0>:f                  {Compacted,I@1}
L16840:
        join (16|M0)                         L17472                                
L16856:
        add3 (16|M0)             r108.0<1>:d   r66.0<1;0>:d      -r68.0<1;0>:d     -2:w              
        and (16|M0)   (ne)f1.0   r68.0<1>:d    r108.0<1;1,0>:d   63:w               {I@1}
(f1.0)  goto (16|M0)                         L16928                  L16928                
L16904:
        mov (16|M0)              r126.0<1>:f   r80.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L16928                  L17032                
L16928:
        join (16|M0)                         L17032                                
L16944:
        cmp (16|M0)   (lt)f0.1   null<1>:d     r68.0<1;1,0>:ud   0x20:uw              {I@4}
(~f0.1) add (16|M0)              r2.0<1>:d     r68.0<1;1,0>:d    -32:w              
(~f0.1) shr (16|M0)              r126.0<1>:ud  r78.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f0.1)  add (16|M0)              r2.0<1>:d     -r68.0<1;1,0>:d   32:w               {Compacted}
(f0.1)  shr (16|M0)              r10.0<1>:ud   r80.0<1;1,0>:ud   r68.0<1;1,0>:d  
(f0.1)  shl (16|M0)              r2.0<1>:d     r78.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f0.1)  or (16|M0)               r126.0<1>:d   r10.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@1}
L17032:
        join (16|M0)                         L17472                                
L17048:
        and (16|M0)   (ne)f1.1   r66.0<1>:d    r108.0<1;1,0>:d   63:w              
        and (16|M0)              r86.0<1>:d    r126.0<1;1,0>:d   1:w               {Compacted,I@3}
(f1.1)  goto (16|M0)                         L17136                  L17136                
L17088:
        mov (16|M0)              r118.0<1>:d   -1:w                              
        mov (16|M0)              r102.0<1>:d   -1:w                              
        goto (16|M0)                         L17136                  L17320                
L17136:
        join (16|M0)                         L17320                                
L17152:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r66.0<1;1,0>:ud   0x20:uw              {I@7}
(f1.0)  goto (16|M0)                         L17256                  L17256                
L17184:
        add (16|M0)              r2.0<1>:d     r66.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r5.2<1>:hf    -qnan(0x1FF):hf                             
        mov (16|M0)              r118.0<1>:d   0:w                              
        shl (16|M0)              r102.0<1>:d   r5.2<0;1,0>:w     r2.0<1;1,0>:d    {A@1}
        goto (16|M0)                         L17256                  L17320                
L17256:
        join (16|M0)                         L17320                                
L17272:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (16|M0)              r102.0<1>:d   -1:w                              
        shl (16|M0)              r118.0<1>:d   r2.0<0;1,0>:w     r66.0<1;1,0>:d   {F@1}
L17320:
        join (16|M0)                         L17472                                
L17336:
        bfn.0x28 (16|M0)         r2.0<1>:ud    r80.0<1;0>:ud     r118.0<1;0>:ud    r6.2<0>:ud       {I@2} // s0&(s1^s2)
        cmp (16|M0)   (ne)f1.1   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
        bfn.0x28 (16|M0)         r10.0<1>:ud   r78.0<1;0>:ud     r102.0<1;0>:ud    r6.2<0>:ud       // s0&(s1^s2)
(~f1.1) cmp (16|M0)   (ne)f1.1   null<1>:d     r10.0<1;1,0>:d    0:w               {I@1}
(W)     mov (1|M0)               r5.2<1>:hf    -qnan(0x1FF):hf                             
        mov (16|M0)              r98.0<1>:f    r62.0<1;1,0>:f                   {Compacted}
(f1.1)  sel (16|M0)              r12.0<1>:d    r5.2<0;1,0>:w     0:w               {F@2}
        mov (16|M0)              r90.0<1>:d    -r12.0<1;1,0>:d                  {I@1}
        goto (16|M0)                         L17472                  L17528                
L17472:
        join (16|M0)                         L17528                                
L17488:
        mov (16|M0)              r90.0<1>:d    0:w                              
        mov (16|M0)              r86.0<1>:d    0:w                              
        mov (16|M0)              r98.0<1>:f    r80.0<1;1,0>:f                   {Compacted}
L17528:
        join (16|M0)                         L18056                                
L17544:
        and (16|M0)   (ne)f0.1   r62.0<1>:d    r64.0<1;1,0>:d    63:w               {F@2}
(f0.1)  goto (16|M0)                         L17600                  L17600                
L17576:
        mov (16|M0)              r126.0<1>:f   r80.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L17600                  L17704                
L17600:
        join (16|M0)                         L17704                                
L17616:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r62.0<1;1,0>:ud   0x20:uw              {I@4}
(~f1.1) add (16|M0)              r2.0<1>:d     r62.0<1;1,0>:d    -32:w              
(~f1.1) shr (16|M0)              r126.0<1>:ud  r78.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.1)  add (16|M0)              r2.0<1>:d     -r62.0<1;1,0>:d   32:w               {Compacted}
(f1.1)  shr (16|M0)              r10.0<1>:ud   r80.0<1;1,0>:ud   r62.0<1;1,0>:d  
(f1.1)  shl (16|M0)              r2.0<1>:d     r78.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.1)  or (16|M0)               r126.0<1>:d   r10.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@1}
L17704:
        join (16|M0)                         L18056                                
L17720:
        shl (16|M0)              r2.0<1>:d     r98.0<1;1,0>:d    2:w               {Compacted}
        shl (16|M0)              r10.0<1>:d    r86.0<1;1,0>:d    1:w               {Compacted}
        and (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     4:w               {Compacted,I@2}
        bfn.0xFE (16|M0)         r90.0<1>:ud   r2.0<1;0>:ud      r10.0<1;0>:ud     r90.0<1>:ud      {I@1} // s0|s1|s2
        cmp (16|M0)   (eq)f1.0   null<1>:d     r90.0<1;1,0>:d    0:w               {I@1}
(~f1.0) goto (16|M0)                         L17824                  L17824                
L17792:
        mov (16|M0)              r102.0<1>:d   0:w                              
        goto (16|M0)                         L17824                  L17984                
L17824:
        join (16|M0)                         L17984                                
L17840:
        cmp (16|M0)   (gt)f0.1   null<1>:d     r90.0<1;1,0>:ud   0x4:uw             
(~f0.1) goto (16|M0)                         L17904                  L17904                
L17872:
        mov (16|M0)              r102.0<1>:d   1:w                              
        goto (16|M0)                         L17904                  L17984                
L17904:
        join (16|M0)                         L17984                                
L17920:
        and (16|M0)   (ne)f1.0   null<1>:d     r126.0<1;1,0>:d   1:w              
(W)     mov (1|M0)               r2.0<1>:hf    0x1:hf                             
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r90.0<1;1,0>:d    4:w              
(f1.0)  sel (16|M0)              r102.0<1>:d   r2.0<0;1,0>:w     0:w               {F@1}
L17984:
        join (16|M0)                         L18056                                
L18000:
        add (16|M0)              r2.0<1>:d     r102.0<1;1,0>:d   r126.0<1;1,0>:d  {Compacted,I@2}
        cmp (16|M0)   (gt)f1.0   null<1>:d     r2.0<1;1,0>:ud    0x7FFFFF:ud              {I@1}
(W)     mov (1|M0)               r5.1<1>:f     0x800000:f                               {Compacted}
(~f1.0) sel (16|M0)              r80.0<1>:d    r2.0<1;1,0>:d     0:w              
(f1.0)  sel (16|M0)              r78.0<1>:d    r5.1<0;1,0>:d     0:w               {Compacted,F@1}
L18056:
        join (16|M0)                         L18120                                
L18072:
        and (16|M0)              r2.0<1>:d     r74.0<1;1,0>:d    -2147483648:d              
        bfn.0xFE (16|M0)         r18.0<1>:ud   r2.0<1;0>:ud      r78.0<1;0>:ud     r80.0<1>:ud      {I@1} // s0|s1|s2
        goto (16|M0)                         L18120                  L21160                
L18120:
        join (16|M0)                         L18624                                
L18136:
        and (16|M0)   (ne)f1.1   r14.0<1>:d    r84.0<1;1,0>:d    63:w              
(f1.1)  goto (16|M0)                         L18216                  L18216                
L18168:
        mov (16|M0)              r122.0<1>:d   -1:w                              
        mov (16|M0)              r112.0<1>:d   -1:w                              
        goto (16|M0)                         L18216                  L18400                
L18216:
        join (16|M0)                         L18400                                
L18232:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r14.0<1;1,0>:ud   0x20:uw              {I@6}
(f1.0)  goto (16|M0)                         L18336                  L18336                
L18264:
        add (16|M0)              r2.0<1>:d     r14.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r5.2<1>:hf    -qnan(0x1FF):hf                             
        mov (16|M0)              r122.0<1>:d   0:w                              
        shl (16|M0)              r112.0<1>:d   r5.2<0;1,0>:w     r2.0<1;1,0>:d    {A@1}
        goto (16|M0)                         L18336                  L18400                
L18336:
        join (16|M0)                         L18400                                
L18352:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (16|M0)              r112.0<1>:d   -1:w                              
        shl (16|M0)              r122.0<1>:d   r2.0<0;1,0>:w     r14.0<1;1,0>:d   {F@1}
L18400:
        join (16|M0)                         L18624                                
L18416:
        bfn.0x28 (16|M0)         r2.0<1>:ud    r80.0<1;0>:ud     r122.0<1;0>:ud    r6.2<0>:ud       {I@2} // s0&(s1^s2)
        cmp (16|M0)   (ne)f1.1   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
        bfn.0x28 (16|M0)         r10.0<1>:ud   r78.0<1;0>:ud     r112.0<1;0>:ud    r6.2<0>:ud       // s0&(s1^s2)
        cmp (16|M0)   (gt)f0.1   null<1>:d     r74.0<1;1,0>:d    -1:w              
(~f1.1) cmp (16|M0)   (ne)f1.1   null<1>:d     r10.0<1;1,0>:d    0:w               {I@2}
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r12.0<1;1,0>:d    -150:w              
(f0.1)  goto (16|M0)                         L18568                  L18568                
L18528:
(W)     mov (1|M0)               r2.0<1>:ud    0x80000001:ud                             
(f1.1)  sel (16|M0)              r18.0<1>:f    r2.0<0;1,0>:f     -0.0:f               {Compacted,I@1}
        goto (16|M0)                         L18568                  L21160                
L18568:
        join (16|M0)                         L18624                                
L18584:
(W)     mov (1|M0)               r2.0<1>:ud    0x1:ud                              {F@1}
(f1.1)  sel (16|M0)              r18.0<1>:f    r2.0<0;1,0>:f     0.0:f               {Compacted,I@1}
        goto (16|M0)                         L18624                  L21160                
L18624:
        join (16|M0)                         L20936                                
L18640:
        cmp (16|M0)   (lt)f0.1   null<1>:d     r84.0<1;1,0>:ud   0x18:uw             
        add3 (16|M0)             r98.0<1>:d    r72.0<1;0>:d      r84.0<1;0>:d      81:w              
(f0.1)  cmp (16|M0)   (eq)f0.1   null<1>:d     r14.0<1;1,0>:d    0:w              
(f0.1)  goto (16|M0)                         L20624                  L20624                
L18704:
        shl (16|M0)              r2.0<1>:d     r76.0<1;1,0>:d    1:w               {Compacted,F@1}
        shr (16|M0)              r10.0<1>:ud   r76.0<1;1,0>:ud   31:w              
        shl (16|M0)              r12.0<1>:d    r90.0<1;1,0>:d    1:w               {Compacted}
        cmp (16|M0)   (lt)f1.0   null<1>:d     r2.0<1;1,0>:ud    0x4E:uw              {I@3}
        or (16|M0)               r12.0<1>:d    r12.0<1;1,0>:d    r10.0<1;1,0>:d   {Compacted,I@2}
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r12.0<1;1,0>:d    0:w               {I@1}
(~f1.0) cmp (16|M0)   (lt)f1.0   null<1>:d     r12.0<1;1,0>:d    0:w              
(f1.0)  goto (16|M0)                         L18936                  L18936                
L18808:
        cmp (16|M0)   (eq)f1.1   null<1>:d     r76.0<1;1,0>:d    39:w              
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r90.0<1;1,0>:d    0:w              
(~f1.1) goto (16|M0)                         L18936                  L19000                
L18856:
        shr (16|M0)              r126.0<1>:ud  r80.0<1;1,0>:ud   1:w              
        mov (16|M0)              r20.0<1>:d    0:w                              
        mov (16|M0)              r118.0<1>:d   0:w                              
        mov (16|M0)              r26.0<1>:f    r126.0<1;1,0>:f                  {Compacted,I@3}
        mov (16|M0)              r126.0<1>:f   r80.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L18936                  L20096                
L18936:
        join (16|M0)                         L19000                                
L18952:
        cmp (16|M0)   (eq)f1.0   null<1>:d     r76.0<1;1,0>:d    38:w              
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r90.0<1;1,0>:d    0:w              
(f1.0)  goto (16|M0)                         L19000                  L20016                
L19000:
        join (16|M0)                         L20016                                
L19016:
        add (16|M0)              r2.0<1>:d     -r76.0<1;1,0>:d   39:w               {Compacted}
        and (16|M0)   (ne)f1.1   r82.0<1>:d    r2.0<1;1,0>:d     63:w               {I@1}
        add (16|M0)              r110.0<1>:d   -r76.0<1;1,0>:d   40:w               {Compacted}
(f1.1)  goto (16|M0)                         L19088                  L19088                
L19064:
        mov (16|M0)              r108.0<1>:f   r80.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L19088                  L19200                
L19088:
        join (16|M0)                         L19200                                
L19104:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r82.0<1;1,0>:ud   0x20:uw              {I@5}
(~f1.0) add (16|M0)              r2.0<1>:d     r82.0<1;1,0>:d    -32:w              
(~f1.0) shr (16|M0)              r126.0<1>:ud  r78.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.0)  add (16|M0)              r2.0<1>:d     -r82.0<1;1,0>:d   32:w               {Compacted}
(f1.0)  shr (16|M0)              r10.0<1>:ud   r80.0<1;1,0>:ud   r82.0<1;1,0>:d  
(f1.0)  shl (16|M0)              r2.0<1>:d     r78.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.0)  or (16|M0)               r126.0<1>:d   r10.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@1}
        mov (16|M0)              r108.0<1>:f   r126.0<1;1,0>:f                  {Compacted,I@1}
L19200:
        join (16|M0)                         L20016                                
L19216:
        add (16|M0)              r24.0<1>:d    -r76.0<1;1,0>:d   38:w               {Compacted}
        and (16|M0)   (ne)f0.1   r106.0<1>:d   r24.0<1;1,0>:d    63:w               {I@1}
(f0.1)  goto (16|M0)                         L19280                  L19280                
L19256:
        mov (16|M0)              r126.0<1>:f   r80.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L19280                  L19384                
L19280:
        join (16|M0)                         L19384                                
L19296:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r106.0<1;1,0>:ud  0x20:uw              {I@4}
(~f1.1) add (16|M0)              r2.0<1>:d     r106.0<1;1,0>:d   -32:w              
(~f1.1) shr (16|M0)              r126.0<1>:ud  r78.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.1)  add (16|M0)              r2.0<1>:d     -r106.0<1;1,0>:d  32:w               {Compacted}
(f1.1)  shr (16|M0)              r10.0<1>:ud   r80.0<1;1,0>:ud   r106.0<1;1,0>:d 
(f1.1)  shl (16|M0)              r2.0<1>:d     r78.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.1)  or (16|M0)               r126.0<1>:d   r10.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@1}
L19384:
        join (16|M0)                         L20016                                
L19400:
        and (16|M0)   (ne)f1.0   r104.0<1>:d   r24.0<1;1,0>:d    63:w              
        and (16|M0)              r118.0<1>:d   r126.0<1;1,0>:d   1:w               {Compacted,I@3}
(f1.0)  goto (16|M0)                         L19488                  L19488                
L19440:
        mov (16|M0)              r96.0<1>:d    -1:w                              
        mov (16|M0)              r88.0<1>:d    -1:w                              
        goto (16|M0)                         L19488                  L19672                
L19488:
        join (16|M0)                         L19672                                
L19504:
        cmp (16|M0)   (lt)f0.1   null<1>:d     r104.0<1;1,0>:ud  0x20:uw              {I@7}
(f0.1)  goto (16|M0)                         L19608                  L19608                
L19536:
        add (16|M0)              r2.0<1>:d     r104.0<1;1,0>:d   -32:w               {Compacted}
(W)     mov (1|M0)               r5.2<1>:hf    -qnan(0x1FF):hf                             
        mov (16|M0)              r96.0<1>:d    0:w                              
        shl (16|M0)              r88.0<1>:d    r5.2<0;1,0>:w     r2.0<1;1,0>:d    {A@1}
        goto (16|M0)                         L19608                  L19672                
L19608:
        join (16|M0)                         L19672                                
L19624:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (16|M0)              r88.0<1>:d    -1:w                              
        shl (16|M0)              r96.0<1>:d    r2.0<0;1,0>:w     r104.0<1;1,0>:d  {F@1}
L19672:
        join (16|M0)                         L20016                                
L19688:
        bfn.0x28 (16|M0)         r2.0<1>:ud    r80.0<1;0>:ud     r96.0<1;0>:ud     r6.2<0>:ud       {I@2} // s0&(s1^s2)
        cmp (16|M0)   (ne)f0.1   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
        bfn.0x28 (16|M0)         r10.0<1>:ud   r78.0<1;0>:ud     r88.0<1;0>:ud     r6.2<0>:ud       // s0&(s1^s2)
(~f0.1) cmp (16|M0)   (ne)f0.1   null<1>:d     r10.0<1;1,0>:d    0:w               {I@1}
(W)     mov (1|M0)               r5.2<1>:hf    -qnan(0x1FF):hf                             
        and (16|M0)   (ne)f1.1   r102.0<1>:d   r110.0<1;1,0>:d   63:w              
(f0.1)  sel (16|M0)              r12.0<1>:d    r5.2<0;1,0>:w     0:w               {F@1}
        mov (16|M0)              r20.0<1>:d    -r12.0<1;1,0>:d                  {I@1}
(f1.1)  goto (16|M0)                         L19856                  L19856                
L19832:
        mov (16|M0)              r126.0<1>:f   r80.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L19856                  L19960                
L19856:
        join (16|M0)                         L19960                                
L19872:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r102.0<1;1,0>:ud  0x20:uw             
(~f1.0) add (16|M0)              r2.0<1>:d     r102.0<1;1,0>:d   -32:w              
(~f1.0) shr (16|M0)              r126.0<1>:ud  r78.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.0)  add (16|M0)              r2.0<1>:d     -r102.0<1;1,0>:d  32:w               {Compacted}
(f1.0)  shr (16|M0)              r10.0<1>:ud   r80.0<1;1,0>:ud   r102.0<1;1,0>:d 
(f1.0)  shl (16|M0)              r2.0<1>:d     r78.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.0)  or (16|M0)               r126.0<1>:d   r10.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@1}
L19960:
        join (16|M0)                         L20016                                
L19976:
        mov (16|M0)              r26.0<1>:f    r126.0<1;1,0>:f                  {Compacted,I@2}
        mov (16|M0)              r126.0<1>:d   r108.0<1;1,0>:d                  {F@1}
        goto (16|M0)                         L20016                  L20096                
L20016:
        join (16|M0)                         L20096                                
L20032:
        shr (16|M0)              r126.0<1>:ud  r80.0<1;1,0>:ud   2:w              
        and (16|M0)              r118.0<1>:d   r80.0<1;1,0>:d    1:w               {Compacted}
        mov (16|M0)              r20.0<1>:d    0:w                              
        mov (16|M0)              r26.0<1>:f    r126.0<1;1,0>:f                  {Compacted,I@3}
        shr (16|M0)              r126.0<1>:ud  r80.0<1;1,0>:ud   1:w               {F@1}
L20096:
        join (16|M0)                         L20624                                
L20112:
        shl (16|M0)              r2.0<1>:d     r126.0<1;1,0>:d   2:w               {Compacted,I@2}
        shl (16|M0)              r10.0<1>:d    r118.0<1;1,0>:d   1:w               {Compacted}
        and (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     4:w               {Compacted,I@2}
        bfn.0xFE (16|M0)         r120.0<1>:ud  r2.0<1;0>:ud      r10.0<1;0>:ud     r20.0<1>:ud      {I@1} // s0|s1|s2
        cmp (16|M0)   (eq)f0.1   null<1>:d     r120.0<1;1,0>:d   0:w               {I@1}
        and (16|M0)              r92.0<1>:d    r26.0<1;1,0>:d    8388607:d              
(~f0.1) goto (16|M0)                         L20232                  L20232                
L20200:
        mov (16|M0)              r10.0<1>:d    0:w                              
        goto (16|M0)                         L20232                  L20392                
L20232:
        join (16|M0)                         L20392                                
L20248:
        cmp (16|M0)   (gt)f1.1   null<1>:d     r120.0<1;1,0>:ud  0x4:uw             
(~f1.1) goto (16|M0)                         L20312                  L20312                
L20280:
        mov (16|M0)              r10.0<1>:d    1:w                              
        goto (16|M0)                         L20312                  L20392                
L20312:
        join (16|M0)                         L20392                                
L20328:
        and (16|M0)   (ne)f1.1   null<1>:d     r26.0<1;1,0>:d    1:w              
(W)     mov (1|M0)               r2.0<1>:hf    0x1:hf                             
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r120.0<1;1,0>:d   4:w              
(f1.1)  sel (16|M0)              r10.0<1>:d    r2.0<0;1,0>:w     0:w               {F@1}
L20392:
        join (16|M0)                         L20624                                
L20408:
        add (16|M0)              r18.0<1>:d    r92.0<1;1,0>:d    r10.0<1;1,0>:d   {Compacted,I@2}
        cmp (16|M0)   (gt)f1.1   null<1>:d     r18.0<1;1,0>:ud   0x7FFFFF:ud              {I@1}
        add3 (16|M0)             r2.0<1>:d     r72.0<1;0>:d      r84.0<1;0>:d      82:w              
(f1.1)  sel (16|M0)              r90.0<1>:d    r2.0<1;1,0>:d     r98.0<1;1,0>:d   {Compacted,I@1}
        cmp (16|M0)   (eq)f1.0   null<1>:d     r90.0<1;1,0>:d    255:w               {I@1}
(f1.0)  goto (16|M0)                         L20560                  L20560                
L20488:
(~f1.1) sel (16|M0)              r2.0<1>:d     r18.0<1;1,0>:d    0:w              
        and (16|M0)              r10.0<1>:d    r74.0<1;1,0>:d    -2147483648:d              
        shl (16|M0)              r12.0<1>:d    r90.0<1;1,0>:d    23:w               {Compacted}
        bfn.0xFE (16|M0)         r18.0<1>:ud   r10.0<1;0>:ud     r12.0<1;0>:ud     r2.0<1>:ud       {I@1} // s0|s1|s2
        goto (16|M0)                         L20560                  L21160                
L20560:
        join (16|M0)                         L20624                                
L20576:
        cmp (16|M0)   (gt)f1.0   null<1>:d     r74.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r2.0<1>:f     inf:f                               {Compacted,I@4}
(f1.0)  sel (16|M0)              r18.0<1>:f    r2.0<0;1,0>:f     -inf:f               {Compacted,F@1}
        goto (16|M0)                         L20624                  L21160                
L20624:
        join (16|M0)                         L20936                                
L20640:
        and (16|M0)   (ne)f0.1   r76.0<1>:d    r84.0<1;1,0>:d    63:w              
(f0.1)  goto (16|M0)                         L20704                  L20704                
L20672:
        mov (16|M0)              r114.0<1>:d   -1:w                              
        goto (16|M0)                         L20704                  L20832                
L20704:
        join (16|M0)                         L20832                                
L20720:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r76.0<1;1,0>:ud   0x20:uw              {I@5}
(f1.1)  goto (16|M0)                         L20784                  L20784                
L20752:
        mov (16|M0)              r114.0<1>:d   0:w                              
        goto (16|M0)                         L20784                  L20832                
L20784:
        join (16|M0)                         L20832                                
L20800:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                             
        shl (16|M0)              r114.0<1>:d   r2.0<0;1,0>:w     r76.0<1;1,0>:d   {F@1}
L20832:
        join (16|M0)                         L20936                                
L20848:
        bfn.0x28 (16|M0)         r2.0<1>:ud    r80.0<1;0>:ud     r114.0<1;0>:ud    r6.2<0>:ud       {I@2} // s0&(s1^s2)
        add (16|M0)              r10.0<1>:d    -r84.0<1;1,0>:d   23:w               {Compacted}
        and (16|M0)              r12.0<1>:d    r74.0<1;1,0>:d    -2147483648:d              
        shl (16|M0)              r14.0<1>:d    r98.0<1;1,0>:d    23:w               {Compacted}
        shl (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     r10.0<1;1,0>:d   {Compacted,I@3}
        bfn.0xFE (16|M0)         r18.0<1>:ud   r12.0<1;0>:ud     r14.0<1;0>:ud     r2.0<1>:ud       {I@1} // s0|s1|s2
        goto (16|M0)                         L20936                  L21160                
L20936:
        join (16|M0)                         L21000                                
L20952:
        cmp (16|M0)   (gt)f0.1   null<1>:d     r74.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r2.0<1>:f     inf:f                               {Compacted,I@4}
(f0.1)  sel (16|M0)              r18.0<1>:f    r2.0<0;1,0>:f     -inf:f               {Compacted,F@1}
        goto (16|M0)                         L21000                  L21160                
L21000:
        join (16|M0)                         L21064                                
L21016:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r74.0<1;1,0>:d    0:w              
(W)     mov (1|M0)               r2.0<1>:f     -0.0:f                               {Compacted}
(f1.1)  sel (16|M0)              r18.0<1>:f    r2.0<0;1,0>:f     0.0:f               {Compacted,F@1}
        goto (16|M0)                         L21064                  L21160                
L21064:
        join (16|M0)                         L21128                                
L21080:
        cmp (16|M0)   (gt)f1.0   null<1>:d     r74.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r2.0<1>:f     inf:f                               {Compacted}
(f1.0)  sel (16|M0)              r18.0<1>:f    r2.0<0;1,0>:f     -inf:f               {Compacted,F@1}
        goto (16|M0)                         L21128                  L21160                
L21128:
        join (16|M0)                         L21160                                
L21144:
        bfn.0xF8 (16|M0)         r18.0<1>:ud   r74.0<1;0>:ud     r6.4<0;0>:ud      r6.3<0>:ud       {F@1} // s0&s1|s2
L21160:
        join (16|M0)                         L27944                                
L21176:
        shr (16|M0)              r16.0<1>:ud   r18.0<1;1,0>:ud   23:w               {I@2}
        and (16|M0)   (ne)f1.0   r12.0<1>:d    r18.0<1;1,0>:d    8388607:d              
        and (16|M0)              r26.0<1>:d    r16.0<1;1,0>:d    255:w               {Compacted,I@2}
(W)     addc (1|M0)              r3.0<1>:ud    r7.2<0;1,0>:ud    r6.5<0;1,0>:ud   {AccWrEn}
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r26.0<1;1,0>:d    255:w               {I@2}
(W)     mov (1|M0)               r2.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
(W)     add3 (1|M0)              r5.1<1>:ud    r2.0<0;0>:ud      r6.7<0;0>:ud      r6.6<0>:ud       {I@1}
(~f1.0) goto (16|M0)                         L21320                  L21320                
L21288:
        mov (16|M0)              r22.0<1>:ud   0x7FC00000:ud                             
        goto (16|M0)                         L21320                  L27712                
L21320:
        join (16|M0)                         L27712                                
L21336:
(W)     mov (1|M0)               r2.0<2>:f     r3.0<0;1,0>:f                    {Compacted,I@5}
(W)     mov (1|M0)               r2.1<2>:f     r5.1<0;1,0>:f                    {Compacted}
(W)     mov (2|M0)               r10.0<1>:f    r2.0<1;1,0>:f                    {Compacted,F@1}
(W)     send.ugm (1|M0)          r3       r10     null:0  0x0            0x02188580           {A@1,$10} // wr:1+0, rd:1; load.ugm.d32x1t.a64.ca.ca
(W)     and (1|M0)               r6.7<1>:d     r3.0<0;1,0>:d     8388607:d               {$10.dst}
(W)     shr (1|M0)               r5.2<1>:ud    r3.0<0;1,0>:ud    23:w              
(W)     cmp (16|M0)   (ne)f0.1   null<1>:d     r6.7<0;1,0>:d     0:w               {I@2}
(W)     and (1|M0)               r5.1<1>:d     r5.2<0;1,0>:d     255:w               {I@2}
(W&f0.1) cmp (16|M0)  (eq)f0.1   null<1>:d     r5.1<0;1,0>:d     255:w               {I@1}
(~f0.1) goto (16|M0)                         L21504                  L21504                
L21472:
        mov (16|M0)              r22.0<1>:ud   0x7FC00000:ud                             
        goto (16|M0)                         L21504                  L27712                
L21504:
        join (16|M0)                         L27712                                
L21520:
        cmp (16|M0)   (eq)f1.1   null<1>:d     r12.0<1;1,0>:d    0:w              
(W)     cmp (16|M0)   (eq)f1.0   null<1>:d     r6.7<0;1,0>:d     0:w              
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r26.0<1;1,0>:d    255:w              
(W&f1.0) cmp (16|M0)  (eq)f1.0   null<1>:d     r5.1<0;1,0>:d     255:w              
(W)     mov (1|M0)               r2.0<1>:hf    0x1:hf                             
        xor (16|M0)              r64.0<1>:d    r3.0<0;1,0>:d     r18.0<1;1,0>:d   {Compacted}
(f1.0)  sel (16|M0)              acc0.0<1>:uw  r2.0<0;1,0>:uw    0x0:uw              {F@1}
(f1.1)  sel (16|M0)              acc2.0<1>:uw  r2.0<0;1,0>:uw    0x0:uw             
        or (16|M0)    (ne)f1.0   null<1>:uw    acc2.0<1;1,0>:uw  acc0.0<1;1,0>:uw
(f1.0)  goto (16|M0)                         L27680                  L27680                
L21672:
(W)     or (1|M0)                r2.0<1>:d     r5.1<0;1,0>:d     r6.7<0;1,0>:d   
        or (16|M0)               r10.0<1>:d    r26.0<1;1,0>:d    r12.0<1;1,0>:d   {Compacted}
(W)     cmp (16|M0)   (eq)f1.1   null<1>:d     r2.0<0;1,0>:d     0:w               {I@2}
(~f1.1) cmp (16|M0)   (eq)f1.1   null<1>:d     r10.0<1;1,0>:d    0:w               {I@2}
(~f1.1) goto (16|M0)                         L21776                  L21776                
L21744:
        mov (16|M0)              r22.0<1>:ud   0x0:ud                             
        goto (16|M0)                         L21776                  L27712                
L21776:
        join (16|M0)                         L27680                                
L21792:
        cmp (16|M0)   (eq)f1.1   null<1>:d     r26.0<1;1,0>:d    0:w              
(W)     cmp (16|M0)   (eq)f1.0   null<1>:d     r5.1<0;1,0>:d     0:w              
(W)     add (1|M0)               r2.0<1>:d     r5.1<0;1,0>:d     -127:w               {Compacted}
        add (16|M0)              r88.0<1>:d    r26.0<1;1,0>:d    -127:w               {Compacted}
(W&~f1.0) sel (1|M0)             r95.7<1>:d    r2.0<0;1,0>:d     -126:w               {I@2}
(f1.1)  mov (16|M0)              r88.0<1>:d    -126:w                              
        add (16|M0)              r62.0<1>:d    r88.0<1;1,0>:d    r95.7<0;1,0>:d   {Compacted,I@1}
        cmp (16|M0)   (gt)f0.1   null<1>:d     r62.0<1;1,0>:d    127:w               {I@1}
(f0.1)  goto (16|M0)                         L27616                  L27616                
L21912:
        or (16|M0)    (eq)f0.1   null<4>:b     r16.0<1;1,0>:d    r5.2<0;1,0>:d   
(f0.1)  goto (16|M0)                         L27560                  L27560                
L21944:
(W)     mov (1|M0)               r2.0<1>:hf    0.0:hf                             
(W)     mov (1|M0)               r95.3<1>:d    0:w                              
(f1.1)  sel (16|M0)              r10.0<1>:d    r2.0<0;1,0>:w     8388608:d               {F@1}
(W&f1.0) sel (1|M0)              r3.0<1>:d     r2.0<0;1,0>:w     8388608:d              
        or (16|M0)               r10.0<1>:d    r10.0<1;1,0>:d    r12.0<1;1,0>:d   {Compacted,I@2}
(W)     or (1|M0)                r5.1<1>:d     r3.0<0;1,0>:d     r6.7<0;1,0>:d    {I@2}
(W)     mov (1|M0)               r95.2<1>:f    -0.0:f                               {Compacted}
        mul (8|M0)               acc0.0<1>:ud  r10.0<1;1,0>:ud   r5.2<0;1,0>:uw   {I@1}
        mach (8|M0)              r12.0<1>:ud   r10.0<1;1,0>:ud   r5.1<0;1,0>:ud   {AccWrEn,Compacted}
(W)     mov (2|M0)               r95.4<1>:d    0:w                              
        mov (8|M0)               r14.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mul (8|M8)               acc0.0<1>:ud  r11.0<1;1,0>:ud   r5.2<0;1,0>:uw  
        mach (8|M8)              r13.0<1>:ud   r11.0<1;1,0>:ud   r5.1<0;1,0>:ud   {AccWrEn}
        mov (8|M8)               r15.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mov (16|M0)              r68.0<1>:f    r12.0<1;1,0>:f                   {Compacted,A@2}
        mov (16|M0)              r70.0<1>:f    r14.0<1;1,0>:f                   {Compacted,I@1}
L22144:
(W)     shl (1|M0)               r2.0<1>:d     r95.2<0;1,0>:d    31:w               {Compacted,F@3}
(W)     shr (1|M0)               r2.1<1>:ud    r95.3<0;1,0>:ud   1:w              
(W)     cmp (16|M0)   (gt)f1.0   null<1>:d     r95.4<0;1,0>:ud   0x3E:uw             
(W)     or (1|M0)                r95.3<1>:d    r2.1<0;1,0>:d     r2.0<0;1,0>:d    {I@2}
        bfn.0xA8 (16|M0)         r10.0<1>:ud   r70.0<1;0>:ud     r2.1<0;0>:ud      r2.0<0>:ud       {F@1} // s0&(s1|s2)
(W)     shr (1|M0)               r6.7<1>:ud    r95.2<0;1,0>:ud   1:w              
(W&f1.0) cmp (16|M0)  (eq)f1.0   null<1>:d     r95.5<0;1,0>:d    0:w              
        cmp (16|M0)   (eq)f1.1   null<1>:d     r10.0<1;1,0>:d    r95.3<0;1,0>:d   {I@3}
        and (16|M0)              r12.0<1>:d    r68.0<1;1,0>:d    r6.7<0;1,0>:d    {Compacted,I@3}
(W&~f1.0) cmp (16|M0) (gt)f1.0   null<1>:d     r95.5<0;1,0>:ud   0x0:uw             
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r12.0<1;1,0>:d    r6.7<0;1,0>:d    {I@2}
(W)     mov (1|M0)               r5.2<1>:hf    0x1:hf                             
(W)     addc (1|M0)              r15.0<1>:ud   r95.4<0;1,0>:ud   0x1:ud              {AccWrEn}
(f1.0)  sel (16|M0)              r9.0<1>:uw    r5.2<0;1,0>:uw    0x0:uw              {Compacted,F@1}
(f1.1)  sel (16|M0)              acc2.0<1>:uw  r5.2<0;1,0>:uw    0x0:uw             
(W)     mov (1|M0)               r3.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        or (16|M0)    (ne)f0.1   null<1>:uw    r9.0<1;1,0>:uw    acc2.0<1;1,0>:uw {I@3}
(W)     add (1|M0)               r95.6<1>:ud   r3.0<0;1,0>:ud    r95.5<0;1,0>:ud  {I@2}
        mov (16|M0)              r106.0<1>:d   r95.4<0;1,0>:d                  
        mov (16|M0)              r104.0<1>:d   r95.5<0;1,0>:d                  
        mov (16|M0)              r66.0<1>:f    r15.0<0;1,0>:f                   {Compacted}
        mov (16|M0)              r86.0<1>:d    r95.6<0;1,0>:d                   {I@3}
(f0.1)  goto (16|M0)                         L22536                  L22536                
L22472:
(W)     mov (1|M0)               r95.2<1>:d    r6.7<0;1,0>:d                   
(W)     mov (1|M0)               r95.4<1>:d    r15.0<0;1,0>:d                  
(W)     mov (1|M0)               r95.5<1>:d    r95.6<0;1,0>:d                  
(W)     jmpi                                 L22144                                
L22536:
        join (16|M0)                         L27560                                
L22552:
(W)     mov (1|M0)               r2.0<1>:f     8.68805e-44:f                              
(W)     mov (1|M0)               r3.0<1>:hf    0.0:hf                             
        subb (8|M0)              r82.0<1>:ud   r2.0<0;1,0>:ud    r106.0<1;1,0>:ud {AccWrEn,Compacted,A@2}
        add3 (8|M0)              r124.0<1>:ud  -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r104.0<1>:ud    {A@1}
        subb (8|M8)              r83.0<1>:ud   r2.0<0;1,0>:ud    r107.0<1;1,0>:ud {AccWrEn}
        add3 (16|M0)             r122.0<1>:d   r62.0<1;0>:d      r82.0<1;0>:d      -46:w               {I@1}
        cmp (16|M0)   (gt)f1.1   null<1>:d     r122.0<1;1,0>:d   127:w               {I@1}
        add3 (8|M8)              r125.0<1>:ud  -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r105.0<1>:ud   
        add3 (16|M0)             r18.0<1>:d    r88.0<1;0>:d      r95.7<0;0>:d      r82.0<1>:d      
(f1.1)  goto (16|M0)                         L27496                  L27496                
L22704:
        cmp (16|M0)   (gt)f1.0   null<1>:d     r122.0<1;1,0>:d   -127:w              
(f1.0)  goto (16|M0)                         L25184                  L25184                
L22736:
        cmp (16|M0)   (lt)f0.1   null<1>:d     r122.0<1;1,0>:ud  0xFFFFFF6B:ud             
(f0.1)  goto (16|M0)                         L24680                  L24680                
L22768:
(W)     mov (1|M0)               r2.0<1>:f     8.82818e-44:f                              
(W)     mov (1|M0)               r3.0<1>:hf    0.0:hf                              {I@7}
        subb (8|M0)              r20.0<1>:ud   r2.0<0;1,0>:ud    r106.0<1;1,0>:ud {AccWrEn,Compacted,F@2}
        add3 (16|M0)             r22.0<1>:d    r62.0<1;0>:d      r82.0<1;0>:d      104:w              
        add3 (8|M0)              r10.0<1>:ud   -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r104.0<1>:ud    {F@1}
        subb (8|M8)              r21.0<1>:ud   r2.0<0;1,0>:ud    r107.0<1;1,0>:ud {AccWrEn}
        cmp (16|M0)   (gt)f0.1   null<1>:d     r20.0<1;1,0>:ud   r22.0<1;1,0>:ud  {I@1}
        add3 (8|M8)              r11.0<1>:ud   -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r105.0<1>:ud   
(f0.1)  cmp (16|M0)   (eq)f0.1   null<1>:d     r10.0<1;1,0>:d    0:w               {I@1}
(~f0.1) cmp (16|M0)   (gt)f0.1   null<1>:d     r10.0<1;1,0>:ud   0x0:uw             
(f0.1)  goto (16|M0)                         L22992                  L22992                
L22936:
        add3 (16|M0)             r2.0<1>:d     r18.0<1;0>:d      -r20.0<1;0>:d     104:w              
        mov (16|M0)              r26.0<1>:d    0:w                              
        shl (16|M0)              r62.0<1>:d    r70.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
        goto (16|M0)                         L22992                  L24616                
L22992:
        join (16|M0)                         L24616                                
L23008:
        add3 (16|M0)             r16.0<1>:d    r20.0<1;0>:d      -r18.0<1;0>:d     -104:w              
        cmp (16|M0)   (lt)f1.1   null<1>:d     r16.0<1;1,0>:d    2:w               {I@1}
(f1.1)  goto (16|M0)                         L23152                  L23152                
L23056:
        cmp (16|M0)   (eq)f1.0   null<1>:d     r16.0<1;1,0>:d    2:w              
(~f1.0) goto (16|M0)                         L23152                  L23200                
L23088:
        shr (16|M0)              r120.0<1>:ud  r70.0<1;1,0>:ud   1:w              
        and (16|M0)              r100.0<1>:d   r70.0<1;1,0>:d    1:w               {Compacted}
        mov (16|M0)              r72.0<1>:d    0:w                              
        mov (16|M0)              r78.0<1>:f    r120.0<1;1,0>:f                  {Compacted,I@3}
        goto (16|M0)                         L23152                  L24088                
L23152:
        join (16|M0)                         L23200                                
L23168:
        cmp (16|M0)   (eq)f0.1   null<1>:d     r16.0<1;1,0>:d    1:w              
(f0.1)  goto (16|M0)                         L23200                  L24032                
L23200:
        join (16|M0)                         L24032                                
L23216:
        add3 (16|M0)             r2.0<1>:d     r20.0<1;0>:d      -r22.0<1;0>:d     -1:w              
        and (16|M0)   (ne)f1.1   r72.0<1>:d    r2.0<1;1,0>:d     63:w               {I@1}
(f1.1)  goto (16|M0)                         L23288                  L23288                
L23264:
        mov (16|M0)              r14.0<1>:f    r70.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L23288                  L23400                
L23288:
        join (16|M0)                         L23400                                
L23304:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r72.0<1;1,0>:ud   0x20:uw              {I@4}
(~f1.0) add (16|M0)              r2.0<1>:d     r72.0<1;1,0>:d    -32:w              
(~f1.0) shr (16|M0)              r120.0<1>:ud  r68.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.0)  add (16|M0)              r2.0<1>:d     -r72.0<1;1,0>:d   32:w               {Compacted}
(f1.0)  shr (16|M0)              r10.0<1>:ud   r70.0<1;1,0>:ud   r72.0<1;1,0>:d  
(f1.0)  shl (16|M0)              r2.0<1>:d     r68.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.0)  or (16|M0)               r120.0<1>:d   r10.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@1}
        mov (16|M0)              r14.0<1>:f    r120.0<1;1,0>:f                  {Compacted,I@1}
L23400:
        join (16|M0)                         L24032                                
L23416:
        add3 (16|M0)             r116.0<1>:d   r20.0<1;0>:d      -r22.0<1;0>:d     -2:w              
        and (16|M0)   (ne)f0.1   r66.0<1>:d    r116.0<1;1,0>:d   63:w               {I@1}
(f0.1)  goto (16|M0)                         L23488                  L23488                
L23464:
        mov (16|M0)              r120.0<1>:f   r70.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L23488                  L23592                
L23488:
        join (16|M0)                         L23592                                
L23504:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r66.0<1;1,0>:ud   0x20:uw              {I@4}
(~f1.1) add (16|M0)              r2.0<1>:d     r66.0<1;1,0>:d    -32:w              
(~f1.1) shr (16|M0)              r120.0<1>:ud  r68.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.1)  add (16|M0)              r2.0<1>:d     -r66.0<1;1,0>:d   32:w               {Compacted}
(f1.1)  shr (16|M0)              r10.0<1>:ud   r70.0<1;1,0>:ud   r66.0<1;1,0>:d  
(f1.1)  shl (16|M0)              r2.0<1>:d     r68.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.1)  or (16|M0)               r120.0<1>:d   r10.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@1}
L23592:
        join (16|M0)                         L24032                                
L23608:
        and (16|M0)   (ne)f1.0   r126.0<1>:d   r116.0<1;1,0>:d   63:w              
        and (16|M0)              r100.0<1>:d   r120.0<1;1,0>:d   1:w               {Compacted,I@3}
(f1.0)  goto (16|M0)                         L23696                  L23696                
L23648:
        mov (16|M0)              r118.0<1>:d   -1:w                              
        mov (16|M0)              r110.0<1>:d   -1:w                              
        goto (16|M0)                         L23696                  L23880                
L23696:
        join (16|M0)                         L23880                                
L23712:
        cmp (16|M0)   (lt)f0.1   null<1>:d     r126.0<1;1,0>:ud  0x20:uw              {I@7}
(f0.1)  goto (16|M0)                         L23816                  L23816                
L23744:
        add (16|M0)              r2.0<1>:d     r126.0<1;1,0>:d   -32:w               {Compacted}
(W)     mov (1|M0)               r5.2<1>:hf    -qnan(0x1FF):hf                             
        mov (16|M0)              r118.0<1>:d   0:w                              
        shl (16|M0)              r110.0<1>:d   r5.2<0;1,0>:w     r2.0<1;1,0>:d    {A@1}
        goto (16|M0)                         L23816                  L23880                
L23816:
        join (16|M0)                         L23880                                
L23832:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (16|M0)              r110.0<1>:d   -1:w                              
        shl (16|M0)              r118.0<1>:d   r2.0<0;1,0>:w     r126.0<1;1,0>:d  {F@1}
L23880:
        join (16|M0)                         L24032                                
L23896:
        bfn.0x28 (16|M0)         r2.0<1>:ud    r70.0<1;0>:ud     r118.0<1;0>:ud    r6.2<0>:ud       {I@2} // s0&(s1^s2)
        cmp (16|M0)   (ne)f1.0   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
        bfn.0x28 (16|M0)         r10.0<1>:ud   r68.0<1;0>:ud     r110.0<1;0>:ud    r6.2<0>:ud       // s0&(s1^s2)
(~f1.0) cmp (16|M0)   (ne)f1.0   null<1>:d     r10.0<1;1,0>:d    0:w               {I@1}
(W)     mov (1|M0)               r5.2<1>:hf    -qnan(0x1FF):hf                             
        mov (16|M0)              r78.0<1>:f    r14.0<1;1,0>:f                   {Compacted}
(f1.0)  sel (16|M0)              r12.0<1>:d    r5.2<0;1,0>:w     0:w               {F@2}
        mov (16|M0)              r72.0<1>:d    -r12.0<1;1,0>:d                  {I@1}
        goto (16|M0)                         L24032                  L24088                
L24032:
        join (16|M0)                         L24088                                
L24048:
        mov (16|M0)              r72.0<1>:d    0:w                              
        mov (16|M0)              r100.0<1>:d   0:w                              
        mov (16|M0)              r78.0<1>:f    r70.0<1;1,0>:f                   {Compacted}
L24088:
        join (16|M0)                         L24616                                
L24104:
        and (16|M0)   (ne)f1.1   r62.0<1>:d    r16.0<1;1,0>:d    63:w              
(f1.1)  goto (16|M0)                         L24160                  L24160                
L24136:
        mov (16|M0)              r120.0<1>:f   r70.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L24160                  L24264                
L24160:
        join (16|M0)                         L24264                                
L24176:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r62.0<1;1,0>:ud   0x20:uw              {I@4}
(~f1.0) add (16|M0)              r2.0<1>:d     r62.0<1;1,0>:d    -32:w              
(~f1.0) shr (16|M0)              r120.0<1>:ud  r68.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.0)  add (16|M0)              r2.0<1>:d     -r62.0<1;1,0>:d   32:w               {Compacted}
(f1.0)  shr (16|M0)              r10.0<1>:ud   r70.0<1;1,0>:ud   r62.0<1;1,0>:d  
(f1.0)  shl (16|M0)              r2.0<1>:d     r68.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.0)  or (16|M0)               r120.0<1>:d   r10.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@1}
L24264:
        join (16|M0)                         L24616                                
L24280:
        shl (16|M0)              r2.0<1>:d     r78.0<1;1,0>:d    2:w               {Compacted}
        shl (16|M0)              r10.0<1>:d    r100.0<1;1,0>:d   1:w               {Compacted}
        and (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     4:w               {Compacted,I@2}
        bfn.0xFE (16|M0)         r80.0<1>:ud   r2.0<1;0>:ud      r10.0<1;0>:ud     r72.0<1>:ud      {I@1} // s0|s1|s2
        cmp (16|M0)   (eq)f0.1   null<1>:d     r80.0<1;1,0>:d    0:w               {I@1}
(~f0.1) goto (16|M0)                         L24384                  L24384                
L24352:
        mov (16|M0)              r84.0<1>:d    0:w                              
        goto (16|M0)                         L24384                  L24544                
L24384:
        join (16|M0)                         L24544                                
L24400:
        cmp (16|M0)   (gt)f1.1   null<1>:d     r80.0<1;1,0>:ud   0x4:uw             
(~f1.1) goto (16|M0)                         L24464                  L24464                
L24432:
        mov (16|M0)              r84.0<1>:d    1:w                              
        goto (16|M0)                         L24464                  L24544                
L24464:
        join (16|M0)                         L24544                                
L24480:
        and (16|M0)   (ne)f0.1   null<1>:d     r120.0<1;1,0>:d   1:w              
(W)     mov (1|M0)               r2.0<1>:hf    0x1:hf                             
(f0.1)  cmp (16|M0)   (eq)f0.1   null<1>:d     r80.0<1;1,0>:d    4:w              
(f0.1)  sel (16|M0)              r84.0<1>:d    r2.0<0;1,0>:w     0:w               {F@1}
L24544:
        join (16|M0)                         L24616                                
L24560:
        add (16|M0)              r2.0<1>:d     r84.0<1;1,0>:d    r120.0<1;1,0>:d  {Compacted,I@2}
        cmp (16|M0)   (gt)f0.1   null<1>:d     r2.0<1;1,0>:ud    0x7FFFFF:ud              {I@1}
(W)     mov (1|M0)               r5.1<1>:f     0x800000:f                               {Compacted}
(~f0.1) sel (16|M0)              r62.0<1>:d    r2.0<1;1,0>:d     0:w              
(f0.1)  sel (16|M0)              r26.0<1>:d    r5.1<0;1,0>:d     0:w               {Compacted,F@1}
L24616:
        join (16|M0)                         L24680                                
L24632:
        and (16|M0)              r2.0<1>:d     r64.0<1;1,0>:d    -2147483648:d              
        bfn.0xFE (16|M0)         r22.0<1>:ud   r2.0<1;0>:ud      r26.0<1;0>:ud     r62.0<1>:ud      {I@1} // s0|s1|s2
        goto (16|M0)                         L24680                  L27712                
L24680:
        join (16|M0)                         L25184                                
L24696:
        and (16|M0)   (ne)f1.0   r100.0<1>:d   r82.0<1;1,0>:d    63:w              
(f1.0)  goto (16|M0)                         L24776                  L24776                
L24728:
        mov (16|M0)              r112.0<1>:d   -1:w                              
        mov (16|M0)              r124.0<1>:d   -1:w                              
        goto (16|M0)                         L24776                  L24960                
L24776:
        join (16|M0)                         L24960                                
L24792:
        cmp (16|M0)   (lt)f0.1   null<1>:d     r100.0<1;1,0>:ud  0x20:uw              {I@6}
(f0.1)  goto (16|M0)                         L24896                  L24896                
L24824:
        add (16|M0)              r2.0<1>:d     r100.0<1;1,0>:d   -32:w               {Compacted}
(W)     mov (1|M0)               r5.2<1>:hf    -qnan(0x1FF):hf                             
        mov (16|M0)              r112.0<1>:d   0:w                              
        shl (16|M0)              r124.0<1>:d   r5.2<0;1,0>:w     r2.0<1;1,0>:d    {A@1}
        goto (16|M0)                         L24896                  L24960                
L24896:
        join (16|M0)                         L24960                                
L24912:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (16|M0)              r124.0<1>:d   -1:w                              
        shl (16|M0)              r112.0<1>:d   r2.0<0;1,0>:w     r100.0<1;1,0>:d  {F@1}
L24960:
        join (16|M0)                         L25184                                
L24976:
        bfn.0x28 (16|M0)         r2.0<1>:ud    r70.0<1;0>:ud     r112.0<1;0>:ud    r6.2<0>:ud       {I@2} // s0&(s1^s2)
        cmp (16|M0)   (ne)f1.0   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
        bfn.0x28 (16|M0)         r10.0<1>:ud   r68.0<1;0>:ud     r124.0<1;0>:ud    r6.2<0>:ud       // s0&(s1^s2)
        cmp (16|M0)   (gt)f1.1   null<1>:d     r64.0<1;1,0>:d    -1:w              
(~f1.0) cmp (16|M0)   (ne)f1.0   null<1>:d     r10.0<1;1,0>:d    0:w               {I@2}
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r122.0<1;1,0>:d   -150:w              
(f1.1)  goto (16|M0)                         L25128                  L25128                
L25088:
(W)     mov (1|M0)               r2.0<1>:ud    0x80000001:ud                             
(f1.0)  sel (16|M0)              r22.0<1>:f    r2.0<0;1,0>:f     -0.0:f               {Compacted,I@1}
        goto (16|M0)                         L25128                  L27712                
L25128:
        join (16|M0)                         L25184                                
L25144:
(W)     mov (1|M0)               r2.0<1>:ud    0x1:ud                              {F@1}
(f1.0)  sel (16|M0)              r22.0<1>:f    r2.0<0;1,0>:f     0.0:f               {Compacted,I@1}
        goto (16|M0)                         L25184                  L27712                
L25184:
        join (16|M0)                         L27496                                
L25200:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r82.0<1;1,0>:ud   0x18:uw             
        add3 (16|M0)             r96.0<1>:d    r62.0<1;0>:d      r82.0<1;0>:d      81:w              
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r124.0<1;1,0>:d   0:w              
(f1.1)  goto (16|M0)                         L27184                  L27184                
L25264:
        shl (16|M0)              r2.0<1>:d     r66.0<1;1,0>:d    1:w               {Compacted,F@1}
        shr (16|M0)              r10.0<1>:ud   r66.0<1;1,0>:ud   31:w              
        shl (16|M0)              r12.0<1>:d    r86.0<1;1,0>:d    1:w               {Compacted}
        cmp (16|M0)   (lt)f1.1   null<1>:d     r2.0<1;1,0>:ud    0x4E:uw              {I@3}
        or (16|M0)               r12.0<1>:d    r12.0<1;1,0>:d    r10.0<1;1,0>:d   {Compacted,I@2}
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r12.0<1;1,0>:d    0:w               {I@1}
(~f1.1) cmp (16|M0)   (lt)f1.1   null<1>:d     r12.0<1;1,0>:d    0:w              
(f1.1)  goto (16|M0)                         L25496                  L25496                
L25368:
        cmp (16|M0)   (eq)f1.0   null<1>:d     r66.0<1;1,0>:d    39:w              
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r86.0<1;1,0>:d    0:w              
(~f1.0) goto (16|M0)                         L25496                  L25560                
L25416:
        shr (16|M0)              r120.0<1>:ud  r70.0<1;1,0>:ud   1:w              
        mov (16|M0)              r16.0<1>:d    0:w                              
        mov (16|M0)              r116.0<1>:d   0:w                              
        mov (16|M0)              r12.0<1>:f    r120.0<1;1,0>:f                  {Compacted,I@3}
        mov (16|M0)              r120.0<1>:f   r70.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L25496                  L26656                
L25496:
        join (16|M0)                         L25560                                
L25512:
        cmp (16|M0)   (eq)f0.1   null<1>:d     r66.0<1;1,0>:d    38:w              
(f0.1)  cmp (16|M0)   (eq)f0.1   null<1>:d     r86.0<1;1,0>:d    0:w              
(f0.1)  goto (16|M0)                         L25560                  L26576                
L25560:
        join (16|M0)                         L26576                                
L25576:
        add (16|M0)              r2.0<1>:d     -r66.0<1;1,0>:d   39:w               {Compacted}
        and (16|M0)   (ne)f1.0   r24.0<1>:d    r2.0<1;1,0>:d     63:w               {I@1}
        add (16|M0)              r102.0<1>:d   -r66.0<1;1,0>:d   40:w               {Compacted}
(f1.0)  goto (16|M0)                         L25648                  L25648                
L25624:
        mov (16|M0)              r100.0<1>:f   r70.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L25648                  L25760                
L25648:
        join (16|M0)                         L25760                                
L25664:
        cmp (16|M0)   (lt)f0.1   null<1>:d     r24.0<1;1,0>:ud   0x20:uw              {I@5}
(~f0.1) add (16|M0)              r2.0<1>:d     r24.0<1;1,0>:d    -32:w              
(~f0.1) shr (16|M0)              r120.0<1>:ud  r68.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f0.1)  add (16|M0)              r2.0<1>:d     -r24.0<1;1,0>:d   32:w               {Compacted}
(f0.1)  shr (16|M0)              r10.0<1>:ud   r70.0<1;1,0>:ud   r24.0<1;1,0>:d  
(f0.1)  shl (16|M0)              r2.0<1>:d     r68.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f0.1)  or (16|M0)               r120.0<1>:d   r10.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@1}
        mov (16|M0)              r100.0<1>:f   r120.0<1;1,0>:f                  {Compacted,I@1}
L25760:
        join (16|M0)                         L26576                                
L25776:
        add (16|M0)              r126.0<1>:d   -r66.0<1;1,0>:d   38:w               {Compacted}
        and (16|M0)   (ne)f1.1   r114.0<1>:d   r126.0<1;1,0>:d   63:w               {I@1}
(f1.1)  goto (16|M0)                         L25840                  L25840                
L25816:
        mov (16|M0)              r120.0<1>:f   r70.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L25840                  L25944                
L25840:
        join (16|M0)                         L25944                                
L25856:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r114.0<1;1,0>:ud  0x20:uw              {I@4}
(~f1.0) add (16|M0)              r2.0<1>:d     r114.0<1;1,0>:d   -32:w              
(~f1.0) shr (16|M0)              r120.0<1>:ud  r68.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.0)  add (16|M0)              r2.0<1>:d     -r114.0<1;1,0>:d  32:w               {Compacted}
(f1.0)  shr (16|M0)              r10.0<1>:ud   r70.0<1;1,0>:ud   r114.0<1;1,0>:d 
(f1.0)  shl (16|M0)              r2.0<1>:d     r68.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.0)  or (16|M0)               r120.0<1>:d   r10.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@1}
L25944:
        join (16|M0)                         L26576                                
L25960:
        and (16|M0)   (ne)f0.1   r112.0<1>:d   r126.0<1;1,0>:d   63:w              
        and (16|M0)              r116.0<1>:d   r120.0<1;1,0>:d   1:w               {Compacted,I@3}
(f0.1)  goto (16|M0)                         L26048                  L26048                
L26000:
        mov (16|M0)              r76.0<1>:d    -1:w                              
        mov (16|M0)              r66.0<1>:d    -1:w                              
        goto (16|M0)                         L26048                  L26232                
L26048:
        join (16|M0)                         L26232                                
L26064:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r112.0<1;1,0>:ud  0x20:uw              {I@7}
(f1.1)  goto (16|M0)                         L26168                  L26168                
L26096:
        add (16|M0)              r2.0<1>:d     r112.0<1;1,0>:d   -32:w               {Compacted}
(W)     mov (1|M0)               r5.2<1>:hf    -qnan(0x1FF):hf                             
        mov (16|M0)              r76.0<1>:d    0:w                              
        shl (16|M0)              r66.0<1>:d    r5.2<0;1,0>:w     r2.0<1;1,0>:d    {A@1}
        goto (16|M0)                         L26168                  L26232                
L26168:
        join (16|M0)                         L26232                                
L26184:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (16|M0)              r66.0<1>:d    -1:w                              
        shl (16|M0)              r76.0<1>:d    r2.0<0;1,0>:w     r112.0<1;1,0>:d  {F@1}
L26232:
        join (16|M0)                         L26576                                
L26248:
        bfn.0x28 (16|M0)         r2.0<1>:ud    r70.0<1;0>:ud     r76.0<1;0>:ud     r6.2<0>:ud       {I@2} // s0&(s1^s2)
        cmp (16|M0)   (ne)f1.1   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
        bfn.0x28 (16|M0)         r10.0<1>:ud   r68.0<1;0>:ud     r66.0<1;0>:ud     r6.2<0>:ud       // s0&(s1^s2)
(~f1.1) cmp (16|M0)   (ne)f1.1   null<1>:d     r10.0<1;1,0>:d    0:w               {I@1}
(W)     mov (1|M0)               r5.2<1>:hf    -qnan(0x1FF):hf                             
        and (16|M0)   (ne)f1.0   r110.0<1>:d   r102.0<1;1,0>:d   63:w              
(f1.1)  sel (16|M0)              r12.0<1>:d    r5.2<0;1,0>:w     0:w               {F@1}
        mov (16|M0)              r16.0<1>:d    -r12.0<1;1,0>:d                  {I@1}
(f1.0)  goto (16|M0)                         L26416                  L26416                
L26392:
        mov (16|M0)              r120.0<1>:f   r70.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L26416                  L26520                
L26416:
        join (16|M0)                         L26520                                
L26432:
        cmp (16|M0)   (lt)f0.1   null<1>:d     r110.0<1;1,0>:ud  0x20:uw             
(~f0.1) add (16|M0)              r2.0<1>:d     r110.0<1;1,0>:d   -32:w              
(~f0.1) shr (16|M0)              r120.0<1>:ud  r68.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f0.1)  add (16|M0)              r2.0<1>:d     -r110.0<1;1,0>:d  32:w               {Compacted}
(f0.1)  shr (16|M0)              r10.0<1>:ud   r70.0<1;1,0>:ud   r110.0<1;1,0>:d 
(f0.1)  shl (16|M0)              r2.0<1>:d     r68.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f0.1)  or (16|M0)               r120.0<1>:d   r10.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@1}
L26520:
        join (16|M0)                         L26576                                
L26536:
        mov (16|M0)              r12.0<1>:f    r120.0<1;1,0>:f                  {Compacted,I@2}
        mov (16|M0)              r120.0<1>:d   r100.0<1;1,0>:d                  {F@1}
        goto (16|M0)                         L26576                  L26656                
L26576:
        join (16|M0)                         L26656                                
L26592:
        shr (16|M0)              r120.0<1>:ud  r70.0<1;1,0>:ud   2:w              
        and (16|M0)              r116.0<1>:d   r70.0<1;1,0>:d    1:w               {Compacted}
        mov (16|M0)              r16.0<1>:d    0:w                              
        mov (16|M0)              r12.0<1>:f    r120.0<1;1,0>:f                  {Compacted,I@3}
        shr (16|M0)              r120.0<1>:ud  r70.0<1;1,0>:ud   1:w               {F@1}
L26656:
        join (16|M0)                         L27184                                
L26672:
        shl (16|M0)              r2.0<1>:d     r120.0<1;1,0>:d   2:w               {Compacted,I@2}
        shl (16|M0)              r10.0<1>:d    r116.0<1;1,0>:d   1:w               {Compacted}
        and (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     4:w               {Compacted,I@2}
        bfn.0xFE (16|M0)         r110.0<1>:ud  r2.0<1;0>:ud      r10.0<1;0>:ud     r16.0<1>:ud      {I@1} // s0|s1|s2
        cmp (16|M0)   (eq)f1.1   null<1>:d     r110.0<1;1,0>:d   0:w               {I@1}
        and (16|M0)              r74.0<1>:d    r12.0<1;1,0>:d    8388607:d              
(~f1.1) goto (16|M0)                         L26792                  L26792                
L26760:
        mov (16|M0)              r98.0<1>:d    0:w                              
        goto (16|M0)                         L26792                  L26952                
L26792:
        join (16|M0)                         L26952                                
L26808:
        cmp (16|M0)   (gt)f1.0   null<1>:d     r110.0<1;1,0>:ud  0x4:uw             
(~f1.0) goto (16|M0)                         L26872                  L26872                
L26840:
        mov (16|M0)              r98.0<1>:d    1:w                              
        goto (16|M0)                         L26872                  L26952                
L26872:
        join (16|M0)                         L26952                                
L26888:
        and (16|M0)   (ne)f1.0   null<1>:d     r12.0<1;1,0>:d    1:w              
(W)     mov (1|M0)               r2.0<1>:hf    0x1:hf                             
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r110.0<1;1,0>:d   4:w              
(f1.0)  sel (16|M0)              r98.0<1>:d    r2.0<0;1,0>:w     0:w               {F@1}
L26952:
        join (16|M0)                         L27184                                
L26968:
        add (16|M0)              r74.0<1>:d    r74.0<1;1,0>:d    r98.0<1;1,0>:d   {Compacted,I@2}
        cmp (16|M0)   (gt)f1.0   null<1>:d     r74.0<1;1,0>:ud   0x7FFFFF:ud              {I@1}
        add3 (16|M0)             r2.0<1>:d     r62.0<1;0>:d      r82.0<1;0>:d      82:w              
(f1.0)  sel (16|M0)              r70.0<1>:d    r2.0<1;1,0>:d     r96.0<1;1,0>:d   {Compacted,I@1}
        cmp (16|M0)   (eq)f0.1   null<1>:d     r70.0<1;1,0>:d    255:w               {I@1}
(f0.1)  goto (16|M0)                         L27120                  L27120                
L27048:
(~f1.0) sel (16|M0)              r2.0<1>:d     r74.0<1;1,0>:d    0:w              
        and (16|M0)              r10.0<1>:d    r64.0<1;1,0>:d    -2147483648:d              
        shl (16|M0)              r12.0<1>:d    r70.0<1;1,0>:d    23:w               {Compacted}
        bfn.0xFE (16|M0)         r22.0<1>:ud   r10.0<1;0>:ud     r12.0<1;0>:ud     r2.0<1>:ud       {I@1} // s0|s1|s2
        goto (16|M0)                         L27120                  L27712                
L27120:
        join (16|M0)                         L27184                                
L27136:
        cmp (16|M0)   (gt)f0.1   null<1>:d     r64.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r2.0<1>:f     inf:f                               {Compacted,I@4}
(f0.1)  sel (16|M0)              r22.0<1>:f    r2.0<0;1,0>:f     -inf:f               {Compacted,F@1}
        goto (16|M0)                         L27184                  L27712                
L27184:
        join (16|M0)                         L27496                                
L27200:
        and (16|M0)   (ne)f1.1   r24.0<1>:d    r82.0<1;1,0>:d    63:w              
(f1.1)  goto (16|M0)                         L27264                  L27264                
L27232:
        mov (16|M0)              r88.0<1>:d    -1:w                              
        goto (16|M0)                         L27264                  L27392                
L27264:
        join (16|M0)                         L27392                                
L27280:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r24.0<1;1,0>:ud   0x20:uw              {I@5}
(f1.0)  goto (16|M0)                         L27344                  L27344                
L27312:
        mov (16|M0)              r88.0<1>:d    0:w                              
        goto (16|M0)                         L27344                  L27392                
L27344:
        join (16|M0)                         L27392                                
L27360:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                             
        shl (16|M0)              r88.0<1>:d    r2.0<0;1,0>:w     r24.0<1;1,0>:d   {F@1}
L27392:
        join (16|M0)                         L27496                                
L27408:
        bfn.0x28 (16|M0)         r2.0<1>:ud    r70.0<1;0>:ud     r88.0<1;0>:ud     r6.2<0>:ud       {I@2} // s0&(s1^s2)
        add (16|M0)              r10.0<1>:d    -r82.0<1;1,0>:d   23:w               {Compacted}
        and (16|M0)              r12.0<1>:d    r64.0<1;1,0>:d    -2147483648:d              
        shl (16|M0)              r14.0<1>:d    r96.0<1;1,0>:d    23:w               {Compacted}
        shl (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     r10.0<1;1,0>:d   {Compacted,I@3}
        bfn.0xFE (16|M0)         r22.0<1>:ud   r12.0<1;0>:ud     r14.0<1;0>:ud     r2.0<1>:ud       {I@1} // s0|s1|s2
        goto (16|M0)                         L27496                  L27712                
L27496:
        join (16|M0)                         L27560                                
L27512:
        cmp (16|M0)   (gt)f1.1   null<1>:d     r64.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r2.0<1>:f     inf:f                               {Compacted,I@4}
(f1.1)  sel (16|M0)              r22.0<1>:f    r2.0<0;1,0>:f     -inf:f               {Compacted,F@1}
        goto (16|M0)                         L27560                  L27712                
L27560:
        join (16|M0)                         L27616                                
L27576:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r64.0<1;1,0>:d    0:w               {Compacted}
(W)     mov (1|M0)               r2.0<1>:f     -0.0:f                               {Compacted}
(f1.0)  sel (16|M0)              r22.0<1>:f    r2.0<0;1,0>:f     0.0:f               {Compacted,F@1}
        goto (16|M0)                         L27616                  L27712                
L27616:
        join (16|M0)                         L27680                                
L27632:
        cmp (16|M0)   (gt)f0.1   null<1>:d     r64.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r2.0<1>:f     inf:f                               {Compacted}
(f0.1)  sel (16|M0)              r22.0<1>:f    r2.0<0;1,0>:f     -inf:f               {Compacted,F@1}
        goto (16|M0)                         L27680                  L27712                
L27680:
        join (16|M0)                         L27712                                
L27696:
        bfn.0xF8 (16|M0)         r22.0<1>:ud   r64.0<1;0>:ud     r6.4<0;0>:ud      r6.3<0>:ud       {F@1} // s0&s1|s2
L27712:
        join (16|M0)                         L27944                                
L27728:
        mul (16|M0)              acc0.0<1>:f   r22.0<1;1,0>:f    r32.0<1;1,0>:f   {Compacted,I@2}
        rnde (16|M0)             r10.0<1>:f    acc0.0<1;1,0>:f                  {Compacted}
        addc (8|M0)              r18.0<1>:ud   r52.0<1;1,0>:ud   r6.1<0;1,0>:ud   {AccWrEn,Compacted,A@1}
        sel (16|M0)   (ge)f0.0   acc2.0<1>:f   r10.0<1;1,0>:f    -127.0:f              
        mov (8|M0)               r20.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        sel (16|M0)   (lt)f0.0   r14.0<1>:f    acc2.0<1;1,0>:f   127.0:f              
        addc (8|M8)              r19.0<1>:ud   r53.0<1;1,0>:ud   r6.1<0;1,0>:ud   {AccWrEn}
(W)     add (1|M0)               r6.1<1>:d     r6.1<0;1,0>:d     1:w               {Compacted}
        mov (16|M0)              r16.0<1>:d    r14.0<1;1,0>:f                   {Compacted,F@1}
        mov (8|M8)               r26.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
(W)     cmp (16|M0)   (lt)f0.1   null<1>:d     r6.1<0;1,0>:ud    r6.0<0;1,0>:ud   {I@3}
        add (8|M0)               r21.1<2>:ud   r20.0<1;1,0>:ud   r50.0<1;1,0>:ud  {Compacted}
        mov (16|M0)              r2.0<1>:ud    r16.0<4;1,0>:ub                  {I@4}
        add (8|M8)               r23.1<2>:ud   r26.0<1;1,0>:ud   r51.0<1;1,0>:ud  {Compacted,I@4}
        mov (8|M0)               r21.0<2>:d    r18.0<1;1,0>:d                  
        mov (8|M8)               r23.0<2>:d    r19.0<1;1,0>:d                  
        send.ugm (16|M0)         null     r21     r2:2    0x0            0x080E0984           {A@1,$3} // wr:4+2, rd:0; store.ugm.d8u32.a64.wb.wb
(f0.1)  goto.b (16|M0)                       L27944                  L14712                
L27944:
        join (16|M0)                         L28080                                
L27960:
        addc (8|M0)              r2.0<1>:ud    r48.0<1;1,0>:ud   r8.3<0;1,0>:ud   {AccWrEn,Compacted,$3.src}
        mov (8|M0)               r10.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        addc (8|M8)              r3.0<1>:ud    r49.0<1;1,0>:ud   r8.3<0;1,0>:ud   {AccWrEn}
        add3 (8|M0)              r11.1<2>:ud   r10.0<1;0>:ud     r46.0<1;0>:ud     r8.4<0>:ud       {I@2}
        mov (8|M8)               r16.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mov (8|M0)               r11.0<2>:d    r2.0<1;1,0>:d                   
        add3 (8|M8)              r13.1<2>:ud   r16.0<1;0>:ud     r47.0<1;0>:ud     r8.4<0>:ud       {I@2}
        mov (8|M8)               r13.0<2>:d    r3.0<1;1,0>:d                   
        send.ugm (16|M0)         null     r11     r44:2   0x0            0x080E0584           {A@1,$4} // wr:4+2, rd:0; store.ugm.d32.a64.wb.wb
L28080:
        join (16|M0)                         L28248                                
L28096:
        addc (8|M0)              r98.0<1>:ud   r60.0<1;1,0>:ud   r8.0<0;1,0>:ud   {AccWrEn,Compacted}
        add (8|M0)               r96.0<1>:ud   acc0.0<1;1,0>:ud  r58.0<1;1,0>:ud 
        addc (8|M8)              r99.0<1>:ud   r61.0<1;1,0>:ud   r8.0<0;1,0>:ud   {AccWrEn}
        cmp (16|M0)   (lt)f0.0   null<1>:d     r98.0<1;1,0>:ud   r4.6<0;1,0>:ud   {I@1}
        add (8|M8)               r97.0<1>:ud   acc0.0<1;1,0>:ud  r59.0<1;1,0>:ud 
(f0.0)  cmp (16|M0)   (eq)f0.0   null<1>:d     r96.0<1;1,0>:d    r4.7<0;1,0>:d    {I@1}
(~f0.0) cmp (16|M0)   (lt)f0.0   null<1>:d     r96.0<1;1,0>:ud   r4.7<0;1,0>:ud  
(~f0.0) goto (16|M0)                         L28248                  L28248                
L28216:
(f0.0)  sel (16|M0)              r60.0<1>:d    r98.0<1;1,0>:d    r30.0<1;1,0>:d   {Compacted}
(f0.0)  sel (16|M0)              r58.0<1>:d    r96.0<1;1,0>:d    r28.0<1;1,0>:d   {Compacted}
(W)     jmpi                                 L616                                
L28248:
        join (16|M0)                         L28264                                
L28264:
(W)     mov (8|M0)               r127.0<1>:f   r94.0<1;1,0>:f                   {Compacted,$2.src}
(W)     send.gtwy (1|M0)         null     r127    null:0  0x0            0x02000010           {EOT,A@1} // wr:1+0, rd:0; end of thread
L28288:
        nop                    
(W)     mov (16|M0)              null<1>:ud    0x6F9278B:ud                             
(W)     mov (16|M0)              null<1>:ud    0x6180031B:ud                             
(W)     mov (16|M0)              null<1>:ud    0x0:ud                             
(W)     mov (16|M0)              null<1>:ud    0x1F:ud                             
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
