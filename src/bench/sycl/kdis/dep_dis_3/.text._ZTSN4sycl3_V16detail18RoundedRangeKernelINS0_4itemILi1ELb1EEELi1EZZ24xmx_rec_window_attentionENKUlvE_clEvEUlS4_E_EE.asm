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
(W)     mov (8|M0)               r44.0<1>:ud   r0.0<1;1,0>:ud                  
(W)     or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x4C0:uw              {A@1}
(W)     mul (1|M0)               acc0.0<1>:ud  r4.3<0;1,0>:ud    r44.2<0;1,0>:uw  {A@1}
(W)     mach (1|M0)              r3.0<1>:ud    r4.3<0;1,0>:ud    r44.1<0;1,0>:ud  {AccWrEn,$1.dst}
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
(~f0.0) goto (16|M0)                         L14288                  L14288                
L520:
(W)     cmp (16|M0)   (eq)f0.0   null<1>:d     r5.0<0;1,0>:d     0:w               {Compacted,$2.dst}
        mov (16|M0)              r38.0<1>:f    r34.0<1;1,0>:f                   {Compacted}
        mov (16|M0)              r36.0<1>:f    r32.0<1;1,0>:f                   {Compacted}
(W)     mov (2|M0)               r6.3<1>:d     r5.2<1;1,0>:d                   
(W)     mov (2|M0)               r45.0<1>:d    r5.4<1;1,0>:d                   
(W)     mov (1|M0)               r6.7<1>:f     -0.0:f                               {Compacted}
(W)     mov (1|M0)               r6.6<1>:d     2139095040:d                              
(W)     mov (1|M0)               r6.5<1>:d     -1:w                              
L616:
(~f0.0) goto (16|M0)                         L664                  L664                
L632:
        mov (16|M0)              r102.0<1>:d   -1:w                              
        goto (16|M0)                         L664                  L1040                
L664:
        join (16|M0)                         L1040                                
L680:
(W)     xor (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x30:uw              {A@1}
        sync.nop                             null                             {Compacted,A@1}
        sync.nop                             null                             {Compacted,$3.src}
(W)     mov (1|M0)               r2.0<1>:f     r5.0<0;1,0>:ud                   {Compacted,A@1}
(W)     mov (1|M0)               r3.2<1>:f     0xB4C00000:f                               {Compacted}
(W)     math.inv (1|M0)          r3.1<1>:f     r2.0<0;1,0>:f                    {@2,$4}
        mov (16|M0)              r8.0<1>:f     r38.0<1;1,0>:ud                  {Compacted}
        sync.nop                             null                             {Compacted,$4.dst}
(W)     mad (1|M0)               r5.6<1>:f     r3.1<0;0>:f       r3.2<0;0>:f       r3.1<0>:f        {F@2}
(W)     mov (1|M0)               r2.1<1>:ud    r2.0<0;1,0>:f                   
        mov (16|M0)              r12.0<1>:ud   r8.0<1;1,0>:f                    {F@2}
        mul (16|M0)              r10.0<1>:f    r8.0<1;1,0>:f     r5.6<0;1,0>:f    {Compacted,F@1}
(W)     add (1|M0)               r3.0<1>:d     r5.0<0;1,0>:d     -r2.1<0;1,0>:d   {Compacted,I@2}
        add (16|M0)              r12.0<1>:d    r38.0<1;1,0>:d    -r12.0<1;1,0>:d  {Compacted,I@2}
        mov (16|M0)              r14.0<1>:ud   r10.0<1;1,0>:f                   {F@1}
(W)     mov (1|M0)               r5.7<1>:f     r3.0<0;1,0>:ud                   {Compacted,I@3}
        mov (16|M0)              r16.0<1>:f    r12.0<1;1,0>:ud                  {Compacted,I@2}
        mov (16|M0)              r18.0<1>:f    r14.0<1;1,0>:ud                  {Compacted,I@1}
        mad (16|M0)              acc0.0<1>:f   r8.0<1;0>:f       r18.0<1;0>:f      -r2.0<0>:f       {Compacted,F@1}
        mad (16|M0)              acc2.0<1>:f   r16.0<1;0>:f      r18.0<1;0>:f      -r5.7<0>:f       {Compacted}
        add (16|M0)              acc0.0<1>:f   acc0.0<1;1,0>:f   acc2.0<1;1,0>:f 
        mul (16|M0)              r26.0<1>:f    r5.6<0;1,0>:f     acc0.0<1;1,0>:f 
(W)     xor (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x30:uw              {A@1}
        mov (16|M0)              r28.0<1>:ud   r26.0<1;1,0>:f                   {A@1}
        add (16|M0)              r30.0<1>:d    r28.0<1;1,0>:d    r14.0<1;1,0>:d   {Compacted,I@1}
(W)     mul (8|M0)               acc0.0<1>:d   r30.0<1;1,0>:d    r5.0<0;1,0>:uw   {Compacted,I@1}
        mach (8|M0)              r30.0<1>:d    r30.0<1;1,0>:d    r5.0<0;1,0>:d    {Compacted}
(W)     mul (8|M8)               acc0.0<1>:d   r31.0<1;1,0>:d    r5.0<0;1,0>:uw  
        mach (8|M8)              r31.0<1>:d    r31.0<1;1,0>:d    r5.0<0;1,0>:d    {Compacted}
        add (16|M0)              r30.0<1>:d    r38.0<1;1,0>:d    -r30.0<1;1,0>:d  {Compacted,I@1}
        cmp (16|M0)   (ge)f0.1   r8.0<1>:ud    r30.0<1;1,0>:ud   r5.0<0;1,0>:ud   {I@1}
        add3 (16|M0)             r102.0<1>:d   r28.0<1;0>:d      r14.0<1;0>:d      -r8.0<1>:d       {I@1}
L1040:
        join (16|M0)                         L14288                                
L1056:
(W)     mul (8|M0)               acc0.0<1>:d   r102.0<1;1,0>:d   r5.0<0;1,0>:uw   {Compacted,I@2}
        shr (16|M0)              r10.0<1>:ud   r102.0<1;1,0>:ud  6:w              
        mach (8|M0)              r2.0<1>:d     r102.0<1;1,0>:d   r5.0<0;1,0>:d    {Compacted,$3.src}
(W)     mul (8|M8)               acc0.0<1>:d   r103.0<1;1,0>:d   r5.0<0;1,0>:uw  
        mach (8|M8)              r3.0<1>:d     r103.0<1;1,0>:d   r5.0<0;1,0>:d    {Compacted}
        mul (8|M0)               acc0.0<1>:ud  r10.0<1;1,0>:ud   r5.2<0;1,0>:uw   {I@4}
        mach (8|M0)              r12.0<1>:ud   r10.0<1;1,0>:ud   r5.1<0;1,0>:ud   {AccWrEn,Compacted}
        add (16|M0)              r8.0<1>:d     r38.0<1;1,0>:d    -r2.0<1;1,0>:d   {Compacted,I@3}
        mov (8|M0)               r14.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mul (8|M8)               acc0.0<1>:ud  r11.0<1;1,0>:ud   r5.2<0;1,0>:uw  
        mach (8|M8)              r13.0<1>:ud   r11.0<1;1,0>:ud   r5.1<0;1,0>:ud   {AccWrEn}
        shr (16|M0)              r20.0<1>:ud   r8.0<1;1,0>:ud    5:w               {I@4}
        mov (8|M8)               r15.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mov (16|M0)              r18.0<1>:f    r12.0<1;1,0>:f                   {Compacted,I@3}
        mov (16|M0)              r16.0<1>:f    r14.0<1;1,0>:f                   {Compacted,I@1}
        addc (8|M0)              r22.0<1>:ud   r16.0<1;1,0>:ud   r20.0<1;1,0>:ud  {AccWrEn,Compacted,F@1}
        shl (16|M0)              r10.0<1>:d    r102.0<1;1,0>:d   7:w               {Compacted}
        add (8|M0)               r2.0<1>:ud    acc0.0<1;1,0>:ud  r18.0<1;1,0>:ud 
        addc (8|M8)              r23.0<1>:ud   r17.0<1;1,0>:ud   r21.0<1;1,0>:ud  {AccWrEn}
        and (16|M0)              r10.0<1>:d    r10.0<1;1,0>:d    8064:w               {I@3}
        add (8|M8)               r3.0<1>:ud    acc0.0<1;1,0>:ud  r19.0<1;1,0>:ud 
        shl (16|M0)              r24.0<1>:d    r22.0<1;1,0>:d    13:w               {Compacted,I@3}
        shl (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     13:w               {Compacted,I@2}
        shr (16|M0)              r22.0<1>:ud   r22.0<1;1,0>:ud   19:w              
        addc (8|M0)              r12.0<1>:ud   r24.0<1;1,0>:ud   r45.0<0;1,0>:ud  {AccWrEn,Compacted,I@3}
        or (16|M0)               r2.0<1>:d     r2.0<1;1,0>:d     r22.0<1;1,0>:d   {Compacted,I@2}
        add3 (8|M0)              r14.0<1>:ud   acc0.0<1;0>:ud    r2.0<1;0>:ud      r45.1<0>:ud      {I@1}
        addc (8|M8)              r13.0<1>:ud   r25.0<1;1,0>:ud   r45.0<0;1,0>:ud  {AccWrEn}
        shl (16|M0)              r20.0<1>:d    r8.0<1;1,0>:d     2:w               {Compacted}
        add3 (8|M8)              r15.0<1>:ud   acc0.0<1;0>:ud    r3.0<1;0>:ud      r45.1<0>:ud     
        addc (8|M0)              r16.0<1>:ud   r12.0<1;1,0>:ud   r10.0<1;1,0>:ud  {AccWrEn,Compacted}
        and (16|M0)              r20.0<1>:d    r20.0<1;1,0>:d    124:w               {Compacted,I@3}
        add (8|M0)               r18.0<1>:ud   acc0.0<1;1,0>:ud  r14.0<1;1,0>:ud 
        addc (8|M8)              r17.0<1>:ud   r13.0<1;1,0>:ud   r11.0<1;1,0>:ud  {AccWrEn}
        add (8|M8)               r19.0<1>:ud   acc0.0<1;1,0>:ud  r15.0<1;1,0>:ud  {I@5}
        addc (8|M0)              r22.0<1>:ud   r16.0<1;1,0>:ud   r20.0<1;1,0>:ud  {AccWrEn,Compacted,I@4}
        mov (8|M0)               r26.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        addc (8|M8)              r23.0<1>:ud   r17.0<1;1,0>:ud   r21.0<1;1,0>:ud  {AccWrEn,I@4}
        add (8|M0)               r27.1<2>:ud   r26.0<1;1,0>:ud   r18.0<1;1,0>:ud  {Compacted,I@2}
        mov (8|M8)               r24.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mov (8|M0)               r27.0<2>:d    r22.0<1;1,0>:d                  
        add (8|M8)               r29.1<2>:ud   r24.0<1;1,0>:ud   r19.0<1;1,0>:ud  {Compacted,I@2}
        mov (8|M8)               r29.0<2>:d    r23.0<1;1,0>:d                  
        send.ugm (16|M0)         r40      r27     null:0  0x0            0x08280580           {A@1,$5} // wr:4+0, rd:2; load.ugm.d32.a64.ca.ca
        and (16|M0)              r2.0<1>:d     r40.0<1;1,0>:d    2147483647:d               {$5.dst}
        sel (16|M0)   (lt)f0.0   r72.0<1>:f    r2.0<1;1,0>:f     448.0:f               {Compacted,I@1}
        shr (16|M0)              r66.0<1>:ud   r72.0<1;1,0>:ud   23:w               {F@1}
        and (16|M0)   (ne)f0.1   r106.0<1>:d   r72.0<1;1,0>:d    8388607:d              
        and (16|M0)              r104.0<1>:d   r66.0<1;1,0>:d    255:w               {Compacted,I@2}
(f0.1)  cmp (16|M0)   (eq)f0.1   null<1>:d     r104.0<1;1,0>:d   255:w               {I@1}
        sel (16|M0)   (ge)f0.0   r8.0<1>:ud    r104.0<1;1,0>:ud  0x79:uw             
        shl (16|M0)              r42.0<1>:d    r8.0<1;1,0>:d     23:w               {Compacted,I@1}
(~f0.1) goto (16|M0)                         L1728                  L1728                
L1696:
        mov (16|M0)              r100.0<1>:ud  0x7FC00000:ud                             
        goto (16|M0)                         L1728                  L7720                
L1728:
        join (16|M0)                         L7720                                
L1744:
        cmp (16|M0)   (eq)f1.1   null<1>:d     r106.0<1;1,0>:d   0:w              
        add (16|M0)              r54.0<1>:d    -r42.0<1;1,0>:d   -2139095040:d               {I@6}
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r104.0<1;1,0>:d   255:w              
        xor (16|M0)              r48.0<1>:d    r54.0<1;1,0>:d    r72.0<1;1,0>:d   {Compacted,I@2}
(f1.1)  goto (16|M0)                         L7688                  L7688                
L1816:
        or (16|M0)    (eq)f0.1   null<1>:d     r104.0<1;1,0>:d   r106.0<1;1,0>:d 
(~f0.1) goto (16|M0)                         L1880                  L1880                
L1848:
        mov (16|M0)              r100.0<1>:ud  0x0:ud                             
        goto (16|M0)                         L1880                  L7720                
L1880:
        join (16|M0)                         L7688                                
L1896:
        cmp (16|M0)   (eq)f0.1   null<1>:d     r104.0<1;1,0>:d   0:w              
        shr (16|M0)              r88.0<1>:ud   r54.0<1;1,0>:ud   23:w              
        add (16|M0)              r86.0<1>:d    r104.0<1;1,0>:d   -127:w               {Compacted}
(f0.1)  mov (16|M0)              r86.0<1>:d    -126:w                              
        add (16|M0)              r58.0<1>:d    r88.0<1;1,0>:d    r86.0<1;1,0>:d   {Compacted,I@1}
        cmp (16|M0)   (gt)f1.1   null<1>:d     r58.0<1;1,0>:d    254:w               {I@1}
(f1.1)  goto (16|M0)                         L7624                  L7624                
L1992:
        or (16|M0)    (eq)f1.0   null<4>:b     r66.0<1;1,0>:d    r88.0<1;1,0>:d  
(f1.0)  goto (16|M0)                         L7560                  L7560                
L2024:
(W)     mov (1|M0)               r2.0<1>:hf    0.0:hf                             
(W)     mov (1|M0)               r45.6<1>:d    0:w                              
(f0.1)  sel (16|M0)              r8.0<1>:d     r2.0<0;1,0>:w     8388608:d               {F@1}
        or (16|M0)               r8.0<1>:d     r8.0<1;1,0>:d     r106.0<1;1,0>:d  {Compacted,I@1}
        shl (16|M0)              r52.0<1>:d    r8.0<1;1,0>:d     23:w               {Compacted,I@1}
        shr (16|M0)              r50.0<1>:ud   r8.0<1;1,0>:ud    9:w              
(W)     mov (1|M0)               r45.3<1>:f    -0.0:f                               {Compacted}
(W)     mov (2|M0)               r45.4<1>:d    0:w                              
L2128:
(W)     shl (1|M0)               r2.0<1>:d     r45.3<0;1,0>:d    31:w               {Compacted,F@1}
(W)     shr (1|M0)               r2.1<1>:ud    r45.6<0;1,0>:ud   1:w              
(W)     cmp (16|M0)   (gt)f1.1   null<1>:d     r45.4<0;1,0>:ud   0x3E:uw              {I@3}
(W)     or (1|M0)                r45.6<1>:d    r2.1<0;1,0>:d     r2.0<0;1,0>:d    {I@2}
        bfn.0xE0 (16|M0)         r8.0<1>:ud    r2.1<0;0>:ud      r2.0<0;0>:ud      r52.0<1>:ud      // (s0|s1)&s2
(W)     shr (1|M0)               r45.2<1>:ud   r45.3<0;1,0>:ud   1:w              
(W&f1.1) cmp (16|M0)  (eq)f1.1   null<1>:d     r45.5<0;1,0>:d    0:w              
        cmp (16|M0)   (eq)f1.0   null<1>:d     r8.0<1;1,0>:d     r45.6<0;1,0>:d   {I@3}
        and (16|M0)              r10.0<1>:d    r45.2<0;1,0>:d    r50.0<1;1,0>:d   {Compacted,I@3}
(W&~f1.1) cmp (16|M0) (gt)f1.1   null<1>:d     r45.5<0;1,0>:ud   0x0:uw             
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r10.0<1;1,0>:d    r45.2<0;1,0>:d   {I@2}
(W)     mov (1|M0)               r5.12<1>:hf   0x1:hf                             
(W)     addc (1|M0)              r13.0<1>:ud   r45.4<0;1,0>:ud   0x1:ud              {AccWrEn}
(f1.1)  sel (16|M0)              r7.0<1>:uw    r5.12<0;1,0>:uw   0x0:uw              {Compacted,F@1}
(f1.0)  sel (16|M0)              acc2.0<1>:uw  r5.12<0;1,0>:uw   0x0:uw             
(W)     mov (1|M0)               r3.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        or (16|M0)    (ne)f1.0   null<1>:uw    r7.0<1;1,0>:uw    acc2.0<1;1,0>:uw {I@3}
(W)     add (1|M0)               r45.7<1>:ud   r3.0<0;1,0>:ud    r45.5<0;1,0>:ud  {I@2}
        mov (16|M0)              r92.0<1>:d    r45.4<0;1,0>:d                  
        mov (16|M0)              r90.0<1>:d    r45.5<0;1,0>:d                  
        mov (16|M0)              r70.0<1>:f    r13.0<0;1,0>:f                   {Compacted}
        mov (16|M0)              r84.0<1>:d    r45.7<0;1,0>:d                   {I@3}
(f1.0)  goto (16|M0)                         L2520                  L2520                
L2456:
(W)     mov (1|M0)               r45.3<1>:d    r45.2<0;1,0>:d                  
(W)     mov (1|M0)               r45.4<1>:d    r13.0<0;1,0>:d                  
(W)     mov (1|M0)               r45.5<1>:d    r45.7<0;1,0>:d                  
(W)     jmpi                                 L2128                                
L2520:
        join (16|M0)                         L7560                                
L2536:
(W)     mov (1|M0)               r2.0<1>:f     8.68805e-44:f                              
(W)     mov (1|M0)               r3.0<1>:hf    0.0:hf                             
        subb (8|M0)              r64.0<1>:ud   r2.0<0;1,0>:ud    r92.0<1;1,0>:ud  {AccWrEn,Compacted,A@2}
        add3 (8|M0)              r94.0<1>:ud   -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r90.0<1>:ud     {A@1}
        subb (8|M8)              r65.0<1>:ud   r2.0<0;1,0>:ud    r93.0<1;1,0>:ud  {AccWrEn}
        add3 (16|M0)             r24.0<1>:d    r58.0<1;0>:d      r64.0<1;0>:d      -173:w               {I@1}
        cmp (16|M0)   (gt)f0.1   null<1>:d     r24.0<1;1,0>:d    127:w               {I@1}
        add3 (8|M8)              r95.0<1>:ud   -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r91.0<1>:ud    
        add3 (16|M0)             r86.0<1>:d    r88.0<1;0>:d      r86.0<1;0>:d      r64.0<1>:d      
(f0.1)  goto (16|M0)                         L7496                  L7496                
L2688:
        cmp (16|M0)   (gt)f1.1   null<1>:d     r24.0<1;1,0>:d    -127:w              
(f1.1)  goto (16|M0)                         L5176                  L5176                
L2720:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r24.0<1;1,0>:ud   0xFFFFFF6B:ud             
(f1.0)  goto (16|M0)                         L4672                  L4672                
L2752:
(W)     mov (1|M0)               r2.0<1>:f     8.82818e-44:f                              
(W)     mov (1|M0)               r3.0<1>:hf    0.0:hf                              {I@7}
        subb (8|M0)              r108.0<1>:ud  r2.0<0;1,0>:ud    r92.0<1;1,0>:ud  {AccWrEn,Compacted,F@2}
        add3 (16|M0)             r10.0<1>:d    r58.0<1;0>:d      r64.0<1;0>:d      -23:w              
        add3 (8|M0)              r8.0<1>:ud    -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r90.0<1>:ud     {F@1}
        subb (8|M8)              r109.0<1>:ud  r2.0<0;1,0>:ud    r93.0<1;1,0>:ud  {AccWrEn}
        cmp (16|M0)   (gt)f0.1   null<1>:d     r108.0<1;1,0>:ud  r10.0<1;1,0>:ud  {I@1}
        add3 (8|M8)              r9.0<1>:ud    -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r91.0<1>:ud    
(f0.1)  cmp (16|M0)   (eq)f0.1   null<1>:d     r8.0<1;1,0>:d     0:w               {I@1}
(~f0.1) cmp (16|M0)   (gt)f0.1   null<1>:d     r8.0<1;1,0>:ud    0x0:uw             
(f0.1)  goto (16|M0)                         L2976                  L2976                
L2920:
        add3 (16|M0)             r2.0<1>:d     r86.0<1;0>:d      -r108.0<1;0>:d    -23:w              
        mov (16|M0)              r50.0<1>:d    0:w                              
        shl (16|M0)              r52.0<1>:d    r52.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
        goto (16|M0)                         L2976                  L4608                
L2976:
        join (16|M0)                         L4608                                
L2992:
        add3 (16|M0)             r30.0<1>:d    r108.0<1;0>:d     -r86.0<1;0>:d     23:w              
        cmp (16|M0)   (lt)f0.1   null<1>:d     r30.0<1;1,0>:d    2:w               {I@1}
(f0.1)  goto (16|M0)                         L3144                  L3144                
L3040:
        cmp (16|M0)   (eq)f1.1   null<1>:d     r30.0<1;1,0>:d    2:w              
(~f1.1) goto (16|M0)                         L3144                  L3192                
L3072:
        shr (16|M0)              r72.0<1>:ud   r52.0<1;1,0>:ud   1:w              
        mov (16|M0)              r126.0<1>:d   0:w                              
        mov (16|M0)              r20.0<1>:d    0:w                              
        mov (16|M0)              r122.0<1>:f   r72.0<1;1,0>:f                   {Compacted,I@3}
        goto (16|M0)                         L3144                  L4080                
L3144:
        join (16|M0)                         L3192                                
L3160:
        cmp (16|M0)   (eq)f1.0   null<1>:d     r30.0<1;1,0>:d    1:w              
(f1.0)  goto (16|M0)                         L3192                  L4024                
L3192:
        join (16|M0)                         L4024                                
L3208:
        add3 (16|M0)             r2.0<1>:d     r108.0<1;0>:d     -r10.0<1;0>:d     -1:w              
        and (16|M0)   (ne)f0.1   r124.0<1>:d   r2.0<1;1,0>:d     63:w               {I@1}
(f0.1)  goto (16|M0)                         L3280                  L3280                
L3256:
        mov (16|M0)              r100.0<1>:f   r52.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L3280                  L3392                
L3280:
        join (16|M0)                         L3392                                
L3296:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r124.0<1;1,0>:ud  0x20:uw              {I@4}
(~f1.1) add (16|M0)              r2.0<1>:d     r124.0<1;1,0>:d   -32:w              
(~f1.1) shr (16|M0)              r72.0<1>:ud   r50.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.1)  add (16|M0)              r2.0<1>:d     -r124.0<1;1,0>:d  32:w               {Compacted}
(f1.1)  shr (16|M0)              r8.0<1>:ud    r52.0<1;1,0>:ud   r124.0<1;1,0>:d 
(f1.1)  shl (16|M0)              r2.0<1>:d     r50.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.1)  or (16|M0)               r72.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
        mov (16|M0)              r100.0<1>:f   r72.0<1;1,0>:f                   {Compacted,I@1}
L3392:
        join (16|M0)                         L4024                                
L3408:
        add3 (16|M0)             r70.0<1>:d    r108.0<1;0>:d     -r10.0<1;0>:d     -2:w              
        and (16|M0)   (ne)f1.0   r122.0<1>:d   r70.0<1;1,0>:d    63:w               {I@1}
(f1.0)  goto (16|M0)                         L3480                  L3480                
L3456:
        mov (16|M0)              r72.0<1>:f    r52.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L3480                  L3584                
L3480:
        join (16|M0)                         L3584                                
L3496:
        cmp (16|M0)   (lt)f0.1   null<1>:d     r122.0<1;1,0>:ud  0x20:uw              {I@4}
(~f0.1) add (16|M0)              r2.0<1>:d     r122.0<1;1,0>:d   -32:w              
(~f0.1) shr (16|M0)              r72.0<1>:ud   r50.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f0.1)  add (16|M0)              r2.0<1>:d     -r122.0<1;1,0>:d  32:w               {Compacted}
(f0.1)  shr (16|M0)              r8.0<1>:ud    r52.0<1;1,0>:ud   r122.0<1;1,0>:d 
(f0.1)  shl (16|M0)              r2.0<1>:d     r50.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f0.1)  or (16|M0)               r72.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
L3584:
        join (16|M0)                         L4024                                
L3600:
        and (16|M0)   (ne)f1.1   r90.0<1>:d    r70.0<1;1,0>:d    63:w              
        and (16|M0)              r20.0<1>:d    r72.0<1;1,0>:d    1:w               {Compacted,I@3}
(f1.1)  goto (16|M0)                         L3688                  L3688                
L3640:
        mov (16|M0)              r94.0<1>:d    -1:w                              
        mov (16|M0)              r98.0<1>:d    -1:w                              
        goto (16|M0)                         L3688                  L3872                
L3688:
        join (16|M0)                         L3872                                
L3704:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r90.0<1;1,0>:ud   0x20:uw              {I@7}
(f1.0)  goto (16|M0)                         L3808                  L3808                
L3736:
        add (16|M0)              r2.0<1>:d     r90.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r5.12<1>:hf   -qnan(0x1FF):hf                             
        mov (16|M0)              r94.0<1>:d    0:w                              
        shl (16|M0)              r98.0<1>:d    r5.12<0;1,0>:w    r2.0<1;1,0>:d    {A@1}
        goto (16|M0)                         L3808                  L3872                
L3808:
        join (16|M0)                         L3872                                
L3824:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (16|M0)              r98.0<1>:d    -1:w                              
        shl (16|M0)              r94.0<1>:d    r2.0<0;1,0>:w     r90.0<1;1,0>:d   {F@1}
L3872:
        join (16|M0)                         L4024                                
L3888:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r94.0<1;0>:ud     r6.5<0;0>:ud      r52.0<1>:ud      {I@2} // (s0^s1)&s2
        cmp (16|M0)   (ne)f1.0   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
        bfn.0x60 (16|M0)         r8.0<1>:ud    r98.0<1;0>:ud     r6.5<0;0>:ud      r50.0<1>:ud      // (s0^s1)&s2
(~f1.0) cmp (16|M0)   (ne)f1.0   null<1>:d     r8.0<1;1,0>:d     0:w               {I@1}
(W)     mov (1|M0)               r5.12<1>:hf   -qnan(0x1FF):hf                             
        mov (16|M0)              r122.0<1>:f   r100.0<1;1,0>:f                  {Compacted}
(f1.0)  sel (16|M0)              r10.0<1>:d    r5.12<0;1,0>:w    0:w               {F@2}
        mov (16|M0)              r126.0<1>:d   -r10.0<1;1,0>:d                  {I@1}
        goto (16|M0)                         L4024                  L4080                
L4024:
        join (16|M0)                         L4080                                
L4040:
        mov (16|M0)              r126.0<1>:d   0:w                              
        mov (16|M0)              r20.0<1>:d    0:w                              
        mov (16|M0)              r122.0<1>:f   r52.0<1;1,0>:f                   {Compacted}
L4080:
        join (16|M0)                         L4608                                
L4096:
        and (16|M0)   (ne)f0.1   r120.0<1>:d   r30.0<1;1,0>:d    63:w              
(f0.1)  goto (16|M0)                         L4152                  L4152                
L4128:
        mov (16|M0)              r72.0<1>:f    r52.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L4152                  L4256                
L4152:
        join (16|M0)                         L4256                                
L4168:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r120.0<1;1,0>:ud  0x20:uw              {I@4}
(~f1.1) add (16|M0)              r2.0<1>:d     r120.0<1;1,0>:d   -32:w              
(~f1.1) shr (16|M0)              r72.0<1>:ud   r50.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.1)  add (16|M0)              r2.0<1>:d     -r120.0<1;1,0>:d  32:w               {Compacted}
(f1.1)  shr (16|M0)              r8.0<1>:ud    r52.0<1;1,0>:ud   r120.0<1;1,0>:d 
(f1.1)  shl (16|M0)              r2.0<1>:d     r50.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.1)  or (16|M0)               r72.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
L4256:
        join (16|M0)                         L4608                                
L4272:
        shl (16|M0)              r2.0<1>:d     r122.0<1;1,0>:d   2:w               {Compacted}
        shl (16|M0)              r8.0<1>:d     r20.0<1;1,0>:d    1:w               {Compacted}
        and (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     4:w               {Compacted,I@2}
        bfn.0xFE (16|M0)         r50.0<1>:ud   r2.0<1;0>:ud      r8.0<1;0>:ud      r126.0<1>:ud     {I@1} // s0|s1|s2
        cmp (16|M0)   (eq)f1.0   null<1>:d     r50.0<1;1,0>:d    0:w               {I@1}
(~f1.0) goto (16|M0)                         L4376                  L4376                
L4344:
        mov (16|M0)              r54.0<1>:d    0:w                              
        goto (16|M0)                         L4376                  L4536                
L4376:
        join (16|M0)                         L4536                                
L4392:
        cmp (16|M0)   (gt)f0.1   null<1>:d     r50.0<1;1,0>:ud   0x4:uw             
(~f0.1) goto (16|M0)                         L4456                  L4456                
L4424:
        mov (16|M0)              r54.0<1>:d    1:w                              
        goto (16|M0)                         L4456                  L4536                
L4456:
        join (16|M0)                         L4536                                
L4472:
        and (16|M0)   (ne)f0.1   null<1>:d     r72.0<1;1,0>:d    1:w              
(W)     mov (1|M0)               r2.0<1>:hf    0x1:hf                             
(f0.1)  cmp (16|M0)   (eq)f0.1   null<1>:d     r50.0<1;1,0>:d    4:w              
(f0.1)  sel (16|M0)              r54.0<1>:d    r2.0<0;1,0>:w     0:w               {F@1}
L4536:
        join (16|M0)                         L4608                                
L4552:
        add (16|M0)              r2.0<1>:d     r54.0<1;1,0>:d    r72.0<1;1,0>:d   {Compacted,I@2}
        cmp (16|M0)   (gt)f1.1   null<1>:d     r2.0<1;1,0>:ud    0x7FFFFF:ud              {I@1}
(W)     mov (1|M0)               r5.6<1>:f     0x800000:f                               {Compacted}
(~f1.1) sel (16|M0)              r52.0<1>:d    r2.0<1;1,0>:d     0:w              
(f1.1)  sel (16|M0)              r50.0<1>:d    r5.6<0;1,0>:d     0:w               {Compacted,F@1}
L4608:
        join (16|M0)                         L4672                                
L4624:
        and (16|M0)              r2.0<1>:d     r48.0<1;1,0>:d    -2147483648:d              
        bfn.0xFE (16|M0)         r100.0<1>:ud  r2.0<1;0>:ud      r50.0<1;0>:ud     r52.0<1>:ud      {I@1} // s0|s1|s2
        goto (16|M0)                         L4672                  L7720                
L4672:
        join (16|M0)                         L5176                                
L4688:
        and (16|M0)   (ne)f1.1   r70.0<1>:d    r64.0<1;1,0>:d    63:w              
(f1.1)  goto (16|M0)                         L4768                  L4768                
L4720:
        mov (16|M0)              r84.0<1>:d    -1:w                              
        mov (16|M0)              r88.0<1>:d    -1:w                              
        goto (16|M0)                         L4768                  L4952                
L4768:
        join (16|M0)                         L4952                                
L4784:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r70.0<1;1,0>:ud   0x20:uw              {I@6}
(f1.0)  goto (16|M0)                         L4888                  L4888                
L4816:
        add (16|M0)              r2.0<1>:d     r70.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r5.12<1>:hf   -qnan(0x1FF):hf                             
        mov (16|M0)              r84.0<1>:d    0:w                              
        shl (16|M0)              r88.0<1>:d    r5.12<0;1,0>:w    r2.0<1;1,0>:d    {A@1}
        goto (16|M0)                         L4888                  L4952                
L4888:
        join (16|M0)                         L4952                                
L4904:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (16|M0)              r88.0<1>:d    -1:w                              
        shl (16|M0)              r84.0<1>:d    r2.0<0;1,0>:w     r70.0<1;1,0>:d   {F@1}
L4952:
        join (16|M0)                         L5176                                
L4968:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r84.0<1;0>:ud     r6.5<0;0>:ud      r52.0<1>:ud      {I@2} // (s0^s1)&s2
        cmp (16|M0)   (ne)f1.0   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
        bfn.0x60 (16|M0)         r8.0<1>:ud    r88.0<1;0>:ud     r6.5<0;0>:ud      r50.0<1>:ud      // (s0^s1)&s2
        cmp (16|M0)   (gt)f0.1   null<1>:d     r48.0<1;1,0>:d    -1:w              
(~f1.0) cmp (16|M0)   (ne)f1.0   null<1>:d     r8.0<1;1,0>:d     0:w               {I@2}
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r24.0<1;1,0>:d    -150:w              
(f0.1)  goto (16|M0)                         L5120                  L5120                
L5080:
(W)     mov (1|M0)               r2.0<1>:ud    0x80000001:ud                             
(f1.0)  sel (16|M0)              r100.0<1>:f   r2.0<0;1,0>:f     -0.0:f               {Compacted,I@1}
        goto (16|M0)                         L5120                  L7720                
L5120:
        join (16|M0)                         L5176                                
L5136:
(W)     mov (1|M0)               r2.0<1>:ud    0x1:ud                              {F@1}
(f1.0)  sel (16|M0)              r100.0<1>:f   r2.0<0;1,0>:f     0.0:f               {Compacted,I@1}
        goto (16|M0)                         L5176                  L7720                
L5176:
        join (16|M0)                         L7496                                
L5192:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r64.0<1;1,0>:ud   0x18:uw             
        add3 (16|M0)             r66.0<1>:d    r58.0<1;0>:d      r64.0<1;0>:d      -46:w              
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r94.0<1;1,0>:d    0:w              
(f1.1)  goto (16|M0)                         L7184                  L7184                
L5256:
        shl (16|M0)              r2.0<1>:d     r70.0<1;1,0>:d    1:w               {Compacted,F@1}
        shr (16|M0)              r8.0<1>:ud    r70.0<1;1,0>:ud   31:w              
        shl (16|M0)              r10.0<1>:d    r84.0<1;1,0>:d    1:w               {Compacted}
        cmp (16|M0)   (lt)f1.1   null<1>:d     r2.0<1;1,0>:ud    0x4E:uw              {I@3}
        or (16|M0)               r10.0<1>:d    r10.0<1;1,0>:d    r8.0<1;1,0>:d    {Compacted,I@2}
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r10.0<1;1,0>:d    0:w               {I@1}
(~f1.1) cmp (16|M0)   (lt)f1.1   null<1>:d     r10.0<1;1,0>:d    0:w              
(f1.1)  goto (16|M0)                         L5488                  L5488                
L5360:
        cmp (16|M0)   (eq)f1.0   null<1>:d     r70.0<1;1,0>:d    39:w              
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r84.0<1;1,0>:d    0:w              
(~f1.0) goto (16|M0)                         L5488                  L5552                
L5408:
        shr (16|M0)              r72.0<1>:ud   r52.0<1;1,0>:ud   1:w              
        mov (16|M0)              r16.0<1>:d    0:w                              
        mov (16|M0)              r24.0<1>:d    0:w                              
        mov (16|M0)              r20.0<1>:f    r72.0<1;1,0>:f                   {Compacted,I@3}
        mov (16|M0)              r72.0<1>:f    r52.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L5488                  L6656                
L5488:
        join (16|M0)                         L5552                                
L5504:
        cmp (16|M0)   (eq)f0.1   null<1>:d     r70.0<1;1,0>:d    38:w              
(f0.1)  cmp (16|M0)   (eq)f0.1   null<1>:d     r84.0<1;1,0>:d    0:w              
(f0.1)  goto (16|M0)                         L5552                  L6568                
L5552:
        join (16|M0)                         L6568                                
L5568:
        add (16|M0)              r2.0<1>:d     -r70.0<1;1,0>:d   39:w               {Compacted}
        and (16|M0)   (ne)f1.1   r12.0<1>:d    r2.0<1;1,0>:d     63:w               {I@1}
        add (16|M0)              r112.0<1>:d   -r70.0<1;1,0>:d   40:w               {Compacted}
(f1.1)  goto (16|M0)                         L5640                  L5640                
L5616:
        mov (16|M0)              r104.0<1>:f   r52.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L5640                  L5752                
L5640:
        join (16|M0)                         L5752                                
L5656:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r12.0<1;1,0>:ud   0x20:uw              {I@5}
(~f1.0) add (16|M0)              r2.0<1>:d     r12.0<1;1,0>:d    -32:w              
(~f1.0) shr (16|M0)              r72.0<1>:ud   r50.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.0)  add (16|M0)              r2.0<1>:d     -r12.0<1;1,0>:d   32:w               {Compacted}
(f1.0)  shr (16|M0)              r8.0<1>:ud    r52.0<1;1,0>:ud   r12.0<1;1,0>:d  
(f1.0)  shl (16|M0)              r2.0<1>:d     r50.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.0)  or (16|M0)               r72.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
        mov (16|M0)              r104.0<1>:f   r72.0<1;1,0>:f                   {Compacted,I@1}
L5752:
        join (16|M0)                         L6568                                
L5768:
        add (16|M0)              r74.0<1>:d    -r70.0<1;1,0>:d   38:w               {Compacted}
        and (16|M0)   (ne)f0.1   r16.0<1>:d    r74.0<1;1,0>:d    63:w               {I@1}
(f0.1)  goto (16|M0)                         L5832                  L5832                
L5808:
        mov (16|M0)              r72.0<1>:f    r52.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L5832                  L5936                
L5832:
        join (16|M0)                         L5936                                
L5848:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r16.0<1;1,0>:ud   0x20:uw              {I@4}
(~f1.1) add (16|M0)              r2.0<1>:d     r16.0<1;1,0>:d    -32:w              
(~f1.1) shr (16|M0)              r72.0<1>:ud   r50.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.1)  add (16|M0)              r2.0<1>:d     -r16.0<1;1,0>:d   32:w               {Compacted}
(f1.1)  shr (16|M0)              r8.0<1>:ud    r52.0<1;1,0>:ud   r16.0<1;1,0>:d  
(f1.1)  shl (16|M0)              r2.0<1>:d     r50.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.1)  or (16|M0)               r72.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
L5936:
        join (16|M0)                         L6568                                
L5952:
        and (16|M0)   (ne)f1.0   r102.0<1>:d   r74.0<1;1,0>:d    63:w              
        and (16|M0)              r24.0<1>:d    r72.0<1;1,0>:d    1:w               {Compacted,I@3}
(f1.0)  goto (16|M0)                         L6040                  L6040                
L5992:
        mov (16|M0)              r114.0<1>:d   -1:w                              
        mov (16|M0)              r118.0<1>:d   -1:w                              
        goto (16|M0)                         L6040                  L6224                
L6040:
        join (16|M0)                         L6224                                
L6056:
        cmp (16|M0)   (lt)f0.1   null<1>:d     r102.0<1;1,0>:ud  0x20:uw              {I@7}
(f0.1)  goto (16|M0)                         L6160                  L6160                
L6088:
        add (16|M0)              r2.0<1>:d     r102.0<1;1,0>:d   -32:w               {Compacted}
(W)     mov (1|M0)               r5.12<1>:hf   -qnan(0x1FF):hf                             
        mov (16|M0)              r114.0<1>:d   0:w                              
        shl (16|M0)              r118.0<1>:d   r5.12<0;1,0>:w    r2.0<1;1,0>:d    {A@1}
        goto (16|M0)                         L6160                  L6224                
L6160:
        join (16|M0)                         L6224                                
L6176:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (16|M0)              r118.0<1>:d   -1:w                              
        shl (16|M0)              r114.0<1>:d   r2.0<0;1,0>:w     r102.0<1;1,0>:d  {F@1}
L6224:
        join (16|M0)                         L6568                                
L6240:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r114.0<1;0>:ud    r6.5<0;0>:ud      r52.0<1>:ud      {I@2} // (s0^s1)&s2
        cmp (16|M0)   (ne)f1.1   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
        bfn.0x60 (16|M0)         r8.0<1>:ud    r118.0<1;0>:ud    r6.5<0;0>:ud      r50.0<1>:ud      // (s0^s1)&s2
(~f1.1) cmp (16|M0)   (ne)f1.1   null<1>:d     r8.0<1;1,0>:d     0:w               {I@1}
(W)     mov (1|M0)               r5.12<1>:hf   -qnan(0x1FF):hf                             
(f1.1)  sel (16|M0)              r10.0<1>:d    r5.12<0;1,0>:w    0:w               {F@1}
        and (16|M0)   (ne)f1.1   r14.0<1>:d    r112.0<1;1,0>:d   63:w              
        mov (16|M0)              r16.0<1>:d    -r10.0<1;1,0>:d                  {I@2}
(f1.1)  goto (16|M0)                         L6408                  L6408                
L6384:
        mov (16|M0)              r72.0<1>:f    r52.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L6408                  L6512                
L6408:
        join (16|M0)                         L6512                                
L6424:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r14.0<1;1,0>:ud   0x20:uw              {I@5}
(~f1.0) add (16|M0)              r2.0<1>:d     r14.0<1;1,0>:d    -32:w              
(~f1.0) shr (16|M0)              r72.0<1>:ud   r50.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.0)  add (16|M0)              r2.0<1>:d     -r14.0<1;1,0>:d   32:w               {Compacted}
(f1.0)  shr (16|M0)              r8.0<1>:ud    r52.0<1;1,0>:ud   r14.0<1;1,0>:d  
(f1.0)  shl (16|M0)              r2.0<1>:d     r50.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.0)  or (16|M0)               r72.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
L6512:
        join (16|M0)                         L6568                                
L6528:
        mov (16|M0)              r20.0<1>:f    r72.0<1;1,0>:f                   {Compacted,I@2}
        mov (16|M0)              r72.0<1>:d    r104.0<1;1,0>:d                  {F@1}
        goto (16|M0)                         L6568                  L6656                
L6568:
        join (16|M0)                         L6656                                
L6584:
        shr (16|M0)              r72.0<1>:ud   r52.0<1;1,0>:ud   2:w              
        mov (16|M0)              r16.0<1>:d    0:w                              
        mov (16|M0)              r24.0<1>:d    0:w                              
        mov (16|M0)              r20.0<1>:f    r72.0<1;1,0>:f                   {Compacted,I@3}
        shr (16|M0)              r72.0<1>:ud   r52.0<1;1,0>:ud   1:w               {F@1}
L6656:
        join (16|M0)                         L7184                                
L6672:
        shl (16|M0)              r2.0<1>:d     r72.0<1;1,0>:d    2:w               {Compacted,I@2}
        shl (16|M0)              r8.0<1>:d     r24.0<1;1,0>:d    1:w               {Compacted}
        and (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     4:w               {Compacted,I@2}
        bfn.0xFE (16|M0)         r82.0<1>:ud   r2.0<1;0>:ud      r8.0<1;0>:ud      r16.0<1>:ud      {I@1} // s0|s1|s2
        cmp (16|M0)   (eq)f0.1   null<1>:d     r82.0<1;1,0>:d    0:w               {I@1}
        and (16|M0)              r108.0<1>:d   r20.0<1;1,0>:d    8388607:d              
(~f0.1) goto (16|M0)                         L6792                  L6792                
L6760:
        mov (16|M0)              r68.0<1>:d    0:w                              
        goto (16|M0)                         L6792                  L6952                
L6792:
        join (16|M0)                         L6952                                
L6808:
        cmp (16|M0)   (gt)f1.1   null<1>:d     r82.0<1;1,0>:ud   0x4:uw             
(~f1.1) goto (16|M0)                         L6872                  L6872                
L6840:
        mov (16|M0)              r68.0<1>:d    1:w                              
        goto (16|M0)                         L6872                  L6952                
L6872:
        join (16|M0)                         L6952                                
L6888:
        and (16|M0)   (ne)f1.0   null<1>:d     r20.0<1;1,0>:d    1:w              
(W)     mov (1|M0)               r2.0<1>:hf    0x1:hf                             
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r82.0<1;1,0>:d    4:w              
(f1.0)  sel (16|M0)              r68.0<1>:d    r2.0<0;1,0>:w     0:w               {F@1}
L6952:
        join (16|M0)                         L7184                                
L6968:
        add (16|M0)              r60.0<1>:d    r108.0<1;1,0>:d   r68.0<1;1,0>:d   {Compacted,I@2}
        cmp (16|M0)   (gt)f1.1   null<1>:d     r60.0<1;1,0>:ud   0x7FFFFF:ud              {I@1}
        add3 (16|M0)             r2.0<1>:d     r58.0<1;0>:d      r64.0<1;0>:d      -45:w              
(f1.1)  sel (16|M0)              r58.0<1>:d    r2.0<1;1,0>:d     r66.0<1;1,0>:d   {Compacted,I@1}
        cmp (16|M0)   (eq)f1.0   null<1>:d     r58.0<1;1,0>:d    255:w               {I@1}
(f1.0)  goto (16|M0)                         L7120                  L7120                
L7048:
(~f1.1) sel (16|M0)              r2.0<1>:d     r60.0<1;1,0>:d    0:w              
        and (16|M0)              r8.0<1>:d     r48.0<1;1,0>:d    -2147483648:d              
        shl (16|M0)              r10.0<1>:d    r58.0<1;1,0>:d    23:w               {Compacted}
        bfn.0xFE (16|M0)         r100.0<1>:ud  r8.0<1;0>:ud      r10.0<1;0>:ud     r2.0<1>:ud       {I@1} // s0|s1|s2
        goto (16|M0)                         L7120                  L7720                
L7120:
        join (16|M0)                         L7184                                
L7136:
        cmp (16|M0)   (gt)f1.1   null<1>:d     r48.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r2.0<1>:f     inf:f                               {Compacted,I@4}
(f1.1)  sel (16|M0)              r100.0<1>:f   r2.0<0;1,0>:f     -inf:f               {Compacted,F@1}
        goto (16|M0)                         L7184                  L7720                
L7184:
        join (16|M0)                         L7496                                
L7200:
        and (16|M0)   (ne)f0.1   r46.0<1>:d    r64.0<1;1,0>:d    63:w              
(f0.1)  goto (16|M0)                         L7264                  L7264                
L7232:
        mov (16|M0)              r60.0<1>:d    -1:w                              
        goto (16|M0)                         L7264                  L7392                
L7264:
        join (16|M0)                         L7392                                
L7280:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r46.0<1;1,0>:ud   0x20:uw              {A@1}
(f1.1)  goto (16|M0)                         L7344                  L7344                
L7312:
        mov (16|M0)              r60.0<1>:d    0:w                              
        goto (16|M0)                         L7344                  L7392                
L7344:
        join (16|M0)                         L7392                                
L7360:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                             
        shl (16|M0)              r60.0<1>:d    r2.0<0;1,0>:w     r46.0<1;1,0>:d   {F@1}
L7392:
        join (16|M0)                         L7496                                
L7408:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r60.0<1;0>:ud     r6.5<0;0>:ud      r52.0<1>:ud      {I@2} // (s0^s1)&s2
        add (16|M0)              r8.0<1>:d     -r64.0<1;1,0>:d   23:w               {Compacted}
        and (16|M0)              r10.0<1>:d    r48.0<1;1,0>:d    -2147483648:d              
        shl (16|M0)              r12.0<1>:d    r66.0<1;1,0>:d    23:w               {Compacted}
        shl (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     r8.0<1;1,0>:d    {Compacted,I@3}
        bfn.0xFE (16|M0)         r100.0<1>:ud  r10.0<1;0>:ud     r12.0<1;0>:ud     r2.0<1>:ud       {I@1} // s0|s1|s2
        goto (16|M0)                         L7496                  L7720                
L7496:
        join (16|M0)                         L7560                                
L7512:
        cmp (16|M0)   (gt)f1.0   null<1>:d     r48.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r2.0<1>:f     inf:f                               {Compacted,I@4}
(f1.0)  sel (16|M0)              r100.0<1>:f   r2.0<0;1,0>:f     -inf:f               {Compacted,F@1}
        goto (16|M0)                         L7560                  L7720                
L7560:
        join (16|M0)                         L7624                                
L7576:
        cmp (16|M0)   (lt)f0.1   null<1>:d     r48.0<1;1,0>:d    0:w              
(W)     mov (1|M0)               r2.0<1>:f     -0.0:f                               {Compacted}
(f0.1)  sel (16|M0)              r100.0<1>:f   r2.0<0;1,0>:f     0.0:f               {Compacted,F@1}
        goto (16|M0)                         L7624                  L7720                
L7624:
        join (16|M0)                         L7688                                
L7640:
        cmp (16|M0)   (gt)f1.1   null<1>:d     r48.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r2.0<1>:f     inf:f                               {Compacted}
(f1.1)  sel (16|M0)              r100.0<1>:f   r2.0<0;1,0>:f     -inf:f               {Compacted,F@1}
        goto (16|M0)                         L7688                  L7720                
L7688:
        join (16|M0)                         L7720                                
L7704:
        bfn.0xF8 (16|M0)         r100.0<1>:ud  r48.0<1;0>:ud     r6.7<0;0>:ud      r6.6<0>:ud       {F@1} // s0&s1|s2
L7720:
        join (16|M0)                         L14288                                
L7736:
        rnde (16|M0)             r80.0<1>:f    r100.0<1;1,0>:f                  {Compacted,I@2}
        shr (16|M0)              r64.0<1>:ud   r80.0<1;1,0>:ud   23:w               {F@1}
        and (16|M0)   (ne)f0.1   r112.0<1>:d   r80.0<1;1,0>:d    8388607:d              
        and (16|M0)              r110.0<1>:d   r64.0<1;1,0>:d    255:w               {Compacted,I@2}
(f0.1)  cmp (16|M0)   (eq)f0.1   null<1>:d     r110.0<1;1,0>:d   255:w               {I@1}
(~f0.1) goto (16|M0)                         L7848                  L7848                
L7816:
        mov (16|M0)              r98.0<1>:ud   0x7FC00000:ud                             
        goto (16|M0)                         L7848                  L13888                
L7848:
        join (16|M0)                         L13888                                
L7864:
        cmp (16|M0)   (eq)f1.0   null<1>:d     r112.0<1;1,0>:d   0:w              
        add (16|M0)              r2.0<1>:d     r42.0<1;1,0>:d    -25165824:d              
        shr (16|M0)              r62.0<1>:ud   r2.0<1;1,0>:ud    23:w               {I@1}
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r110.0<1;1,0>:d   255:w              
        and (16|M0)              r78.0<1>:d    r62.0<1;1,0>:d    255:w               {Compacted,I@2}
(~f1.0) cmp (16|M0)   (eq)f1.0   null<1>:d     r78.0<1;1,0>:d    255:w               {I@1}
        xor (16|M0)              r46.0<1>:d    r2.0<1;1,0>:d     r80.0<1;1,0>:d   {Compacted}
(f1.0)  goto (16|M0)                         L13856                  L13856                
L7976:
        cmp (16|M0)   (eq)f1.1   null<1>:d     r78.0<1;1,0>:d    0:w              
        or (16|M0)               r2.0<1>:d     r110.0<1;1,0>:d   r112.0<1;1,0>:d  {Compacted}
(~f1.1) cmp (16|M0)   (eq)f1.1   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
(~f1.1) goto (16|M0)                         L8064                  L8064                
L8032:
        mov (16|M0)              r98.0<1>:ud   0x0:ud                             
        goto (16|M0)                         L8064                  L13888                
L8064:
        join (16|M0)                         L13856                                
L8080:
        cmp (16|M0)   (eq)f1.1   null<1>:d     r110.0<1;1,0>:d   0:w              
        add (16|M0)              r80.0<1>:d    r110.0<1;1,0>:d   -127:w               {Compacted}
(f1.1)  mov (16|M0)              r80.0<1>:d    -126:w                              
        add (16|M0)              r60.0<1>:d    r78.0<1;1,0>:d    r80.0<1;1,0>:d   {Compacted,I@1}
        cmp (16|M0)   (gt)f1.0   null<1>:d     r60.0<1;1,0>:d    254:w               {I@1}
(f1.0)  goto (16|M0)                         L13792                  L13792                
L8160:
        or (16|M0)    (eq)f0.1   null<4>:b     r64.0<1;1,0>:d    r62.0<1;1,0>:d  
(f0.1)  goto (16|M0)                         L13728                  L13728                
L8192:
(W)     mov (1|M0)               r2.0<1>:hf    0.0:hf                             
(W)     mov (1|M0)               r45.6<1>:d    0:w                              
(f1.1)  sel (16|M0)              r8.0<1>:d     r2.0<0;1,0>:w     8388608:d               {F@1}
        or (16|M0)               r8.0<1>:d     r8.0<1;1,0>:d     r112.0<1;1,0>:d  {Compacted,I@1}
        shl (16|M0)              r56.0<1>:d    r8.0<1;1,0>:d     23:w               {Compacted,I@1}
        shr (16|M0)              r54.0<1>:ud   r8.0<1;1,0>:ud    9:w              
(W)     mov (1|M0)               r45.3<1>:f    -0.0:f                               {Compacted}
(W)     mov (2|M0)               r45.4<1>:d    0:w                              
L8296:
(W)     shl (1|M0)               r2.0<1>:d     r45.3<0;1,0>:d    31:w               {Compacted,F@1}
(W)     shr (1|M0)               r2.1<1>:ud    r45.6<0;1,0>:ud   1:w              
(W)     cmp (16|M0)   (gt)f1.0   null<1>:d     r45.4<0;1,0>:ud   0x3E:uw              {I@3}
(W)     or (1|M0)                r45.6<1>:d    r2.1<0;1,0>:d     r2.0<0;1,0>:d    {I@2}
        bfn.0xE0 (16|M0)         r8.0<1>:ud    r2.1<0;0>:ud      r2.0<0;0>:ud      r56.0<1>:ud      // (s0|s1)&s2
(W)     shr (1|M0)               r45.2<1>:ud   r45.3<0;1,0>:ud   1:w              
(W&f1.0) cmp (16|M0)  (eq)f1.0   null<1>:d     r45.5<0;1,0>:d    0:w              
        cmp (16|M0)   (eq)f0.1   null<1>:d     r8.0<1;1,0>:d     r45.6<0;1,0>:d   {I@3}
        and (16|M0)              r10.0<1>:d    r45.2<0;1,0>:d    r54.0<1;1,0>:d   {Compacted,I@3}
(W&~f1.0) cmp (16|M0) (gt)f1.0   null<1>:d     r45.5<0;1,0>:ud   0x0:uw             
(f0.1)  cmp (16|M0)   (eq)f0.1   null<1>:d     r10.0<1;1,0>:d    r45.2<0;1,0>:d   {I@2}
(W)     mov (1|M0)               r5.12<1>:hf   0x1:hf                             
(W)     addc (1|M0)              r13.0<1>:ud   r45.4<0;1,0>:ud   0x1:ud              {AccWrEn}
(f1.0)  sel (16|M0)              r7.0<1>:uw    r5.12<0;1,0>:uw   0x0:uw              {Compacted,F@1}
(f0.1)  sel (16|M0)              acc2.0<1>:uw  r5.12<0;1,0>:uw   0x0:uw             
(W)     mov (1|M0)               r3.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        or (16|M0)    (ne)f0.1   null<1>:uw    r7.0<1;1,0>:uw    acc2.0<1;1,0>:uw {I@3}
(W)     add (1|M0)               r45.7<1>:ud   r3.0<0;1,0>:ud    r45.5<0;1,0>:ud  {I@2}
        mov (16|M0)              r96.0<1>:d    r45.4<0;1,0>:d                  
        mov (16|M0)              r94.0<1>:d    r45.5<0;1,0>:d                  
        mov (16|M0)              r76.0<1>:f    r13.0<0;1,0>:f                   {Compacted}
        mov (16|M0)              r82.0<1>:d    r45.7<0;1,0>:d                   {I@3}
(f0.1)  goto (16|M0)                         L8688                  L8688                
L8624:
(W)     mov (1|M0)               r45.3<1>:d    r45.2<0;1,0>:d                  
(W)     mov (1|M0)               r45.4<1>:d    r13.0<0;1,0>:d                  
(W)     mov (1|M0)               r45.5<1>:d    r45.7<0;1,0>:d                  
(W)     jmpi                                 L8296                                
L8688:
        join (16|M0)                         L13728                                
L8704:
(W)     mov (1|M0)               r2.0<1>:f     8.68805e-44:f                              
(W)     mov (1|M0)               r3.0<1>:hf    0.0:hf                             
        subb (8|M0)              r62.0<1>:ud   r2.0<0;1,0>:ud    r96.0<1;1,0>:ud  {AccWrEn,Compacted,A@2}
        add3 (8|M0)              r84.0<1>:ud   -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r94.0<1>:ud     {A@1}
        subb (8|M8)              r63.0<1>:ud   r2.0<0;1,0>:ud    r97.0<1;1,0>:ud  {AccWrEn}
        add3 (16|M0)             r22.0<1>:d    r60.0<1;0>:d      r62.0<1;0>:d      -173:w               {I@1}
        cmp (16|M0)   (gt)f1.1   null<1>:d     r22.0<1;1,0>:d    127:w               {I@1}
        add3 (8|M8)              r85.0<1>:ud   -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r95.0<1>:ud    
        add3 (16|M0)             r78.0<1>:d    r78.0<1;0>:d      r80.0<1;0>:d      r62.0<1>:d      
(f1.1)  goto (16|M0)                         L13664                  L13664                
L8856:
        cmp (16|M0)   (gt)f1.0   null<1>:d     r22.0<1;1,0>:d    -127:w              
(f1.0)  goto (16|M0)                         L11344                  L11344                
L8888:
        cmp (16|M0)   (lt)f0.1   null<1>:d     r22.0<1;1,0>:ud   0xFFFFFF6B:ud             
(f0.1)  goto (16|M0)                         L10840                  L10840                
L8920:
(W)     mov (1|M0)               r2.0<1>:f     8.82818e-44:f                              
(W)     mov (1|M0)               r3.0<1>:hf    0.0:hf                              {I@7}
        subb (8|M0)              r106.0<1>:ud  r2.0<0;1,0>:ud    r96.0<1;1,0>:ud  {AccWrEn,Compacted,F@2}
        add3 (16|M0)             r124.0<1>:d   r60.0<1;0>:d      r62.0<1;0>:d      -23:w              
        add3 (8|M0)              r8.0<1>:ud    -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r94.0<1>:ud     {F@1}
        subb (8|M8)              r107.0<1>:ud  r2.0<0;1,0>:ud    r97.0<1;1,0>:ud  {AccWrEn}
        cmp (16|M0)   (gt)f0.1   null<1>:d     r106.0<1;1,0>:ud  r124.0<1;1,0>:ud {I@1}
        add3 (8|M8)              r9.0<1>:ud    -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r95.0<1>:ud    
(f0.1)  cmp (16|M0)   (eq)f0.1   null<1>:d     r8.0<1;1,0>:d     0:w               {I@1}
(~f0.1) cmp (16|M0)   (gt)f0.1   null<1>:d     r8.0<1;1,0>:ud    0x0:uw             
(f0.1)  goto (16|M0)                         L9144                  L9144                
L9088:
        add3 (16|M0)             r2.0<1>:d     r78.0<1;0>:d      -r106.0<1;0>:d    -23:w              
        mov (16|M0)              r28.0<1>:d    0:w                              
        shl (16|M0)              r30.0<1>:d    r56.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
        goto (16|M0)                         L9144                  L10776                
L9144:
        join (16|M0)                         L10776                                
L9160:
        add3 (16|M0)             r28.0<1>:d    r106.0<1;0>:d     -r78.0<1;0>:d     23:w              
        cmp (16|M0)   (lt)f1.1   null<1>:d     r28.0<1;1,0>:d    2:w               {I@1}
(f1.1)  goto (16|M0)                         L9312                  L9312                
L9208:
        cmp (16|M0)   (eq)f1.0   null<1>:d     r28.0<1;1,0>:d    2:w              
(~f1.0) goto (16|M0)                         L9312                  L9360                
L9240:
        shr (16|M0)              r74.0<1>:ud   r56.0<1;1,0>:ud   1:w              
        mov (16|M0)              r116.0<1>:d   0:w                              
        mov (16|M0)              r18.0<1>:d    0:w                              
        mov (16|M0)              r110.0<1>:f   r74.0<1;1,0>:f                   {Compacted,I@3}
        goto (16|M0)                         L9312                  L10248                
L9312:
        join (16|M0)                         L9360                                
L9328:
        cmp (16|M0)   (eq)f0.1   null<1>:d     r28.0<1;1,0>:d    1:w              
(f0.1)  goto (16|M0)                         L9360                  L10192                
L9360:
        join (16|M0)                         L10192                                
L9376:
        add3 (16|M0)             r2.0<1>:d     r106.0<1;0>:d     -r124.0<1;0>:d    -1:w              
        and (16|M0)   (ne)f1.1   r118.0<1>:d   r2.0<1;1,0>:d     63:w               {I@1}
(f1.1)  goto (16|M0)                         L9448                  L9448                
L9424:
        mov (16|M0)              r96.0<1>:f    r56.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L9448                  L9560                
L9448:
        join (16|M0)                         L9560                                
L9464:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r118.0<1;1,0>:ud  0x20:uw              {I@4}
(~f1.0) add (16|M0)              r2.0<1>:d     r118.0<1;1,0>:d   -32:w              
(~f1.0) shr (16|M0)              r74.0<1>:ud   r54.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.0)  add (16|M0)              r2.0<1>:d     -r118.0<1;1,0>:d  32:w               {Compacted}
(f1.0)  shr (16|M0)              r8.0<1>:ud    r56.0<1;1,0>:ud   r118.0<1;1,0>:d 
(f1.0)  shl (16|M0)              r2.0<1>:d     r54.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.0)  or (16|M0)               r74.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
        mov (16|M0)              r96.0<1>:f    r74.0<1;1,0>:f                   {Compacted,I@1}
L9560:
        join (16|M0)                         L10192                                
L9576:
        add3 (16|M0)             r68.0<1>:d    r106.0<1;0>:d     -r124.0<1;0>:d    -2:w              
        and (16|M0)   (ne)f0.1   r116.0<1>:d   r68.0<1;1,0>:d    63:w               {I@1}
(f0.1)  goto (16|M0)                         L9648                  L9648                
L9624:
        mov (16|M0)              r74.0<1>:f    r56.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L9648                  L9752                
L9648:
        join (16|M0)                         L9752                                
L9664:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r116.0<1;1,0>:ud  0x20:uw              {I@4}
(~f1.1) add (16|M0)              r2.0<1>:d     r116.0<1;1,0>:d   -32:w              
(~f1.1) shr (16|M0)              r74.0<1>:ud   r54.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.1)  add (16|M0)              r2.0<1>:d     -r116.0<1;1,0>:d  32:w               {Compacted}
(f1.1)  shr (16|M0)              r8.0<1>:ud    r56.0<1;1,0>:ud   r116.0<1;1,0>:d 
(f1.1)  shl (16|M0)              r2.0<1>:d     r54.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.1)  or (16|M0)               r74.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
L9752:
        join (16|M0)                         L10192                                
L9768:
        and (16|M0)   (ne)f1.0   r76.0<1>:d    r68.0<1;1,0>:d    63:w              
        and (16|M0)              r18.0<1>:d    r74.0<1;1,0>:d    1:w               {Compacted,I@3}
(f1.0)  goto (16|M0)                         L9856                  L9856                
L9808:
        mov (16|M0)              r86.0<1>:d    -1:w                              
        mov (16|M0)              r92.0<1>:d    -1:w                              
        goto (16|M0)                         L9856                  L10040                
L9856:
        join (16|M0)                         L10040                                
L9872:
        cmp (16|M0)   (lt)f0.1   null<1>:d     r76.0<1;1,0>:ud   0x20:uw              {I@7}
(f0.1)  goto (16|M0)                         L9976                  L9976                
L9904:
        add (16|M0)              r2.0<1>:d     r76.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r5.12<1>:hf   -qnan(0x1FF):hf                             
        mov (16|M0)              r86.0<1>:d    0:w                              
        shl (16|M0)              r92.0<1>:d    r5.12<0;1,0>:w    r2.0<1;1,0>:d    {A@1}
        goto (16|M0)                         L9976                  L10040                
L9976:
        join (16|M0)                         L10040                                
L9992:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (16|M0)              r92.0<1>:d    -1:w                              
        shl (16|M0)              r86.0<1>:d    r2.0<0;1,0>:w     r76.0<1;1,0>:d   {F@1}
L10040:
        join (16|M0)                         L10192                                
L10056:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r86.0<1;0>:ud     r6.5<0;0>:ud      r56.0<1>:ud      {I@2} // (s0^s1)&s2
        cmp (16|M0)   (ne)f1.0   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
        bfn.0x60 (16|M0)         r8.0<1>:ud    r92.0<1;0>:ud     r6.5<0;0>:ud      r54.0<1>:ud      // (s0^s1)&s2
(~f1.0) cmp (16|M0)   (ne)f1.0   null<1>:d     r8.0<1;1,0>:d     0:w               {I@1}
(W)     mov (1|M0)               r5.12<1>:hf   -qnan(0x1FF):hf                             
        mov (16|M0)              r110.0<1>:f   r96.0<1;1,0>:f                   {Compacted}
(f1.0)  sel (16|M0)              r10.0<1>:d    r5.12<0;1,0>:w    0:w               {F@2}
        mov (16|M0)              r116.0<1>:d   -r10.0<1;1,0>:d                  {I@1}
        goto (16|M0)                         L10192                  L10248                
L10192:
        join (16|M0)                         L10248                                
L10208:
        mov (16|M0)              r116.0<1>:d   0:w                              
        mov (16|M0)              r18.0<1>:d    0:w                              
        mov (16|M0)              r110.0<1>:f   r56.0<1;1,0>:f                   {Compacted}
L10248:
        join (16|M0)                         L10776                                
L10264:
        and (16|M0)   (ne)f1.1   r114.0<1>:d   r28.0<1;1,0>:d    63:w              
(f1.1)  goto (16|M0)                         L10320                  L10320                
L10296:
        mov (16|M0)              r74.0<1>:f    r56.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L10320                  L10424                
L10320:
        join (16|M0)                         L10424                                
L10336:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r114.0<1;1,0>:ud  0x20:uw              {I@4}
(~f1.0) add (16|M0)              r2.0<1>:d     r114.0<1;1,0>:d   -32:w              
(~f1.0) shr (16|M0)              r74.0<1>:ud   r54.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.0)  add (16|M0)              r2.0<1>:d     -r114.0<1;1,0>:d  32:w               {Compacted}
(f1.0)  shr (16|M0)              r8.0<1>:ud    r56.0<1;1,0>:ud   r114.0<1;1,0>:d 
(f1.0)  shl (16|M0)              r2.0<1>:d     r54.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.0)  or (16|M0)               r74.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
L10424:
        join (16|M0)                         L10776                                
L10440:
        shl (16|M0)              r2.0<1>:d     r110.0<1;1,0>:d   2:w               {Compacted}
        shl (16|M0)              r8.0<1>:d     r18.0<1;1,0>:d    1:w               {Compacted}
        and (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     4:w               {Compacted,I@2}
        bfn.0xFE (16|M0)         r42.0<1>:ud   r2.0<1;0>:ud      r8.0<1;0>:ud      r116.0<1>:ud     {I@1} // s0|s1|s2
        cmp (16|M0)   (eq)f0.1   null<1>:d     r42.0<1;1,0>:d    0:w               {I@1}
(~f0.1) goto (16|M0)                         L10544                  L10544                
L10512:
        mov (16|M0)              r48.0<1>:d    0:w                              
        goto (16|M0)                         L10544                  L10704                
L10544:
        join (16|M0)                         L10704                                
L10560:
        cmp (16|M0)   (gt)f1.1   null<1>:d     r42.0<1;1,0>:ud   0x4:uw             
(~f1.1) goto (16|M0)                         L10624                  L10624                
L10592:
        mov (16|M0)              r48.0<1>:d    1:w                              
        goto (16|M0)                         L10624                  L10704                
L10624:
        join (16|M0)                         L10704                                
L10640:
        and (16|M0)   (ne)f0.1   null<1>:d     r74.0<1;1,0>:d    1:w              
(W)     mov (1|M0)               r2.0<1>:hf    0x1:hf                             
(f0.1)  cmp (16|M0)   (eq)f0.1   null<1>:d     r42.0<1;1,0>:d    4:w              
(f0.1)  sel (16|M0)              r48.0<1>:d    r2.0<0;1,0>:w     0:w               {F@1}
L10704:
        join (16|M0)                         L10776                                
L10720:
        add (16|M0)              r2.0<1>:d     r48.0<1;1,0>:d    r74.0<1;1,0>:d   {Compacted,I@2}
        cmp (16|M0)   (gt)f1.0   null<1>:d     r2.0<1;1,0>:ud    0x7FFFFF:ud              {I@1}
(W)     mov (1|M0)               r5.6<1>:f     0x800000:f                               {Compacted}
(~f1.0) sel (16|M0)              r30.0<1>:d    r2.0<1;1,0>:d     0:w              
(f1.0)  sel (16|M0)              r28.0<1>:d    r5.6<0;1,0>:d     0:w               {Compacted,F@1}
L10776:
        join (16|M0)                         L10840                                
L10792:
        and (16|M0)              r2.0<1>:d     r46.0<1;1,0>:d    -2147483648:d              
        bfn.0xFE (16|M0)         r98.0<1>:ud   r2.0<1;0>:ud      r28.0<1;0>:ud     r30.0<1>:ud      {I@1} // s0|s1|s2
        goto (16|M0)                         L10840                  L13888                
L10840:
        join (16|M0)                         L11344                                
L10856:
        and (16|M0)   (ne)f1.0   r58.0<1>:d    r62.0<1;1,0>:d    63:w              
(f1.0)  goto (16|M0)                         L10936                  L10936                
L10888:
        mov (16|M0)              r66.0<1>:d    -1:w                              
        mov (16|M0)              r74.0<1>:d    -1:w                              
        goto (16|M0)                         L10936                  L11120                
L10936:
        join (16|M0)                         L11120                                
L10952:
        cmp (16|M0)   (lt)f0.1   null<1>:d     r58.0<1;1,0>:ud   0x20:uw              {I@6}
(f0.1)  goto (16|M0)                         L11056                  L11056                
L10984:
        add (16|M0)              r2.0<1>:d     r58.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r5.12<1>:hf   -qnan(0x1FF):hf                             
        mov (16|M0)              r66.0<1>:d    0:w                              
        shl (16|M0)              r74.0<1>:d    r5.12<0;1,0>:w    r2.0<1;1,0>:d    {A@1}
        goto (16|M0)                         L11056                  L11120                
L11056:
        join (16|M0)                         L11120                                
L11072:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (16|M0)              r74.0<1>:d    -1:w                              
        shl (16|M0)              r66.0<1>:d    r2.0<0;1,0>:w     r58.0<1;1,0>:d   {F@1}
L11120:
        join (16|M0)                         L11344                                
L11136:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r66.0<1;0>:ud     r6.5<0;0>:ud      r56.0<1>:ud      {I@2} // (s0^s1)&s2
        cmp (16|M0)   (ne)f0.1   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
        bfn.0x60 (16|M0)         r8.0<1>:ud    r74.0<1;0>:ud     r6.5<0;0>:ud      r54.0<1>:ud      // (s0^s1)&s2
        cmp (16|M0)   (gt)f1.1   null<1>:d     r46.0<1;1,0>:d    -1:w              
(~f0.1) cmp (16|M0)   (ne)f0.1   null<1>:d     r8.0<1;1,0>:d     0:w               {I@2}
(f0.1)  cmp (16|M0)   (eq)f0.1   null<1>:d     r22.0<1;1,0>:d    -150:w              
(f1.1)  goto (16|M0)                         L11288                  L11288                
L11248:
(W)     mov (1|M0)               r2.0<1>:ud    0x80000001:ud                             
(f0.1)  sel (16|M0)              r98.0<1>:f    r2.0<0;1,0>:f     -0.0:f               {Compacted,I@1}
        goto (16|M0)                         L11288                  L13888                
L11288:
        join (16|M0)                         L11344                                
L11304:
(W)     mov (1|M0)               r2.0<1>:ud    0x1:ud                              {F@1}
(f0.1)  sel (16|M0)              r98.0<1>:f    r2.0<0;1,0>:f     0.0:f               {Compacted,I@1}
        goto (16|M0)                         L11344                  L13888                
L11344:
        join (16|M0)                         L13664                                
L11360:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r62.0<1;1,0>:ud   0x18:uw             
        add3 (16|M0)             r68.0<1>:d    r60.0<1;0>:d      r62.0<1;0>:d      -46:w              
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r84.0<1;1,0>:d    0:w              
(f1.1)  goto (16|M0)                         L13352                  L13352                
L11424:
        shl (16|M0)              r2.0<1>:d     r76.0<1;1,0>:d    1:w               {Compacted,F@1}
        shr (16|M0)              r8.0<1>:ud    r76.0<1;1,0>:ud   31:w              
        shl (16|M0)              r10.0<1>:d    r82.0<1;1,0>:d    1:w               {Compacted}
        cmp (16|M0)   (lt)f1.1   null<1>:d     r2.0<1;1,0>:ud    0x4E:uw              {I@3}
        or (16|M0)               r10.0<1>:d    r10.0<1;1,0>:d    r8.0<1;1,0>:d    {Compacted,I@2}
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r10.0<1;1,0>:d    0:w               {I@1}
(~f1.1) cmp (16|M0)   (lt)f1.1   null<1>:d     r10.0<1;1,0>:d    0:w              
(f1.1)  goto (16|M0)                         L11656                  L11656                
L11528:
        cmp (16|M0)   (eq)f1.0   null<1>:d     r76.0<1;1,0>:d    39:w              
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r82.0<1;1,0>:d    0:w              
(~f1.0) goto (16|M0)                         L11656                  L11720                
L11576:
        shr (16|M0)              r74.0<1>:ud   r56.0<1;1,0>:ud   1:w              
        mov (16|M0)              r12.0<1>:d    0:w                              
        mov (16|M0)              r22.0<1>:d    0:w                              
        mov (16|M0)              r18.0<1>:f    r74.0<1;1,0>:f                   {Compacted,I@3}
        mov (16|M0)              r74.0<1>:f    r56.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L11656                  L12824                
L11656:
        join (16|M0)                         L11720                                
L11672:
        cmp (16|M0)   (eq)f0.1   null<1>:d     r76.0<1;1,0>:d    38:w              
(f0.1)  cmp (16|M0)   (eq)f0.1   null<1>:d     r82.0<1;1,0>:d    0:w              
(f0.1)  goto (16|M0)                         L11720                  L12736                
L11720:
        join (16|M0)                         L12736                                
L11736:
        add (16|M0)              r2.0<1>:d     -r76.0<1;1,0>:d   39:w               {Compacted}
        and (16|M0)   (ne)f1.0   r126.0<1>:d   r2.0<1;1,0>:d     63:w               {I@1}
        add (16|M0)              r110.0<1>:d   -r76.0<1;1,0>:d   40:w               {Compacted}
(f1.0)  goto (16|M0)                         L11808                  L11808                
L11784:
        mov (16|M0)              r102.0<1>:f   r56.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L11808                  L11920                
L11808:
        join (16|M0)                         L11920                                
L11824:
        cmp (16|M0)   (lt)f0.1   null<1>:d     r126.0<1;1,0>:ud  0x20:uw              {I@5}
(~f0.1) add (16|M0)              r2.0<1>:d     r126.0<1;1,0>:d   -32:w              
(~f0.1) shr (16|M0)              r74.0<1>:ud   r54.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f0.1)  add (16|M0)              r2.0<1>:d     -r126.0<1;1,0>:d  32:w               {Compacted}
(f0.1)  shr (16|M0)              r8.0<1>:ud    r56.0<1;1,0>:ud   r126.0<1;1,0>:d 
(f0.1)  shl (16|M0)              r2.0<1>:d     r54.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f0.1)  or (16|M0)               r74.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
        mov (16|M0)              r102.0<1>:f   r74.0<1;1,0>:f                   {Compacted,I@1}
L11920:
        join (16|M0)                         L12736                                
L11936:
        add (16|M0)              r72.0<1>:d    -r76.0<1;1,0>:d   38:w               {Compacted}
        and (16|M0)   (ne)f1.1   r10.0<1>:d    r72.0<1;1,0>:d    63:w               {I@1}
(f1.1)  goto (16|M0)                         L12000                  L12000                
L11976:
        mov (16|M0)              r74.0<1>:f    r56.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L12000                  L12104                
L12000:
        join (16|M0)                         L12104                                
L12016:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r10.0<1;1,0>:ud   0x20:uw              {I@4}
(~f1.0) add (16|M0)              r2.0<1>:d     r10.0<1;1,0>:d    -32:w              
(~f1.0) shr (16|M0)              r74.0<1>:ud   r54.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.0)  add (16|M0)              r2.0<1>:d     -r10.0<1;1,0>:d   32:w               {Compacted}
(f1.0)  shr (16|M0)              r8.0<1>:ud    r56.0<1;1,0>:ud   r10.0<1;1,0>:d  
(f1.0)  shl (16|M0)              r2.0<1>:d     r54.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.0)  or (16|M0)               r74.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
L12104:
        join (16|M0)                         L12736                                
L12120:
        and (16|M0)   (ne)f0.1   r96.0<1>:d    r72.0<1;1,0>:d    63:w              
        and (16|M0)              r22.0<1>:d    r74.0<1;1,0>:d    1:w               {Compacted,I@3}
(f0.1)  goto (16|M0)                         L12208                  L12208                
L12160:
        mov (16|M0)              r100.0<1>:d   -1:w                              
        mov (16|M0)              r108.0<1>:d   -1:w                              
        goto (16|M0)                         L12208                  L12392                
L12208:
        join (16|M0)                         L12392                                
L12224:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r96.0<1;1,0>:ud   0x20:uw              {I@7}
(f1.1)  goto (16|M0)                         L12328                  L12328                
L12256:
        add (16|M0)              r2.0<1>:d     r96.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r5.12<1>:hf   -qnan(0x1FF):hf                             
        mov (16|M0)              r100.0<1>:d   0:w                              
        shl (16|M0)              r108.0<1>:d   r5.12<0;1,0>:w    r2.0<1;1,0>:d    {A@1}
        goto (16|M0)                         L12328                  L12392                
L12328:
        join (16|M0)                         L12392                                
L12344:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (16|M0)              r108.0<1>:d   -1:w                              
        shl (16|M0)              r100.0<1>:d   r2.0<0;1,0>:w     r96.0<1;1,0>:d   {F@1}
L12392:
        join (16|M0)                         L12736                                
L12408:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r100.0<1;0>:ud    r6.5<0;0>:ud      r56.0<1>:ud      {I@2} // (s0^s1)&s2
        cmp (16|M0)   (ne)f1.1   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
        bfn.0x60 (16|M0)         r8.0<1>:ud    r108.0<1;0>:ud    r6.5<0;0>:ud      r54.0<1>:ud      // (s0^s1)&s2
(~f1.1) cmp (16|M0)   (ne)f1.1   null<1>:d     r8.0<1;1,0>:d     0:w               {I@1}
(W)     mov (1|M0)               r5.12<1>:hf   -qnan(0x1FF):hf                             
        and (16|M0)   (ne)f1.0   r8.0<1>:d     r110.0<1;1,0>:d   63:w              
(f1.1)  sel (16|M0)              r10.0<1>:d    r5.12<0;1,0>:w    0:w               {F@1}
        mov (16|M0)              r12.0<1>:d    -r10.0<1;1,0>:d                  {I@1}
(f1.0)  goto (16|M0)                         L12576                  L12576                
L12552:
        mov (16|M0)              r74.0<1>:f    r56.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L12576                  L12680                
L12576:
        join (16|M0)                         L12680                                
L12592:
        cmp (16|M0)   (lt)f0.1   null<1>:d     r8.0<1;1,0>:ud    0x20:uw             
(~f0.1) add (16|M0)              r2.0<1>:d     r8.0<1;1,0>:d     -32:w              
(~f0.1) shr (16|M0)              r74.0<1>:ud   r54.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f0.1)  add (16|M0)              r2.0<1>:d     -r8.0<1;1,0>:d    32:w               {Compacted}
(f0.1)  shl (16|M0)              r2.0<1>:d     r54.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@1}
(f0.1)  shr (16|M0)              r8.0<1>:ud    r56.0<1;1,0>:ud   r8.0<1;1,0>:d   
(f0.1)  or (16|M0)               r74.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@1}
L12680:
        join (16|M0)                         L12736                                
L12696:
        mov (16|M0)              r18.0<1>:f    r74.0<1;1,0>:f                   {Compacted,I@2}
        mov (16|M0)              r74.0<1>:d    r102.0<1;1,0>:d                  {F@1}
        goto (16|M0)                         L12736                  L12824                
L12736:
        join (16|M0)                         L12824                                
L12752:
        shr (16|M0)              r74.0<1>:ud   r56.0<1;1,0>:ud   2:w              
        mov (16|M0)              r12.0<1>:d    0:w                              
        mov (16|M0)              r22.0<1>:d    0:w                              
        mov (16|M0)              r18.0<1>:f    r74.0<1;1,0>:f                   {Compacted,I@3}
        shr (16|M0)              r74.0<1>:ud   r56.0<1;1,0>:ud   1:w               {F@1}
L12824:
        join (16|M0)                         L13352                                
L12840:
        shl (16|M0)              r2.0<1>:d     r74.0<1;1,0>:d    2:w               {Compacted,I@2}
        shl (16|M0)              r8.0<1>:d     r22.0<1;1,0>:d    1:w               {Compacted}
        and (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     4:w               {Compacted,I@2}
        bfn.0xFE (16|M0)         r64.0<1>:ud   r2.0<1;0>:ud      r8.0<1;0>:ud      r12.0<1>:ud      {I@1} // s0|s1|s2
        cmp (16|M0)   (eq)f1.1   null<1>:d     r64.0<1;1,0>:d    0:w               {I@1}
        and (16|M0)              r106.0<1>:d   r18.0<1;1,0>:d    8388607:d              
(~f1.1) goto (16|M0)                         L12960                  L12960                
L12928:
        mov (16|M0)              r56.0<1>:d    0:w                              
        goto (16|M0)                         L12960                  L13120                
L12960:
        join (16|M0)                         L13120                                
L12976:
        cmp (16|M0)   (gt)f1.0   null<1>:d     r64.0<1;1,0>:ud   0x4:uw             
(~f1.0) goto (16|M0)                         L13040                  L13040                
L13008:
        mov (16|M0)              r56.0<1>:d    1:w                              
        goto (16|M0)                         L13040                  L13120                
L13040:
        join (16|M0)                         L13120                                
L13056:
        and (16|M0)   (ne)f1.0   null<1>:d     r18.0<1;1,0>:d    1:w              
(W)     mov (1|M0)               r2.0<1>:hf    0x1:hf                             
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r64.0<1;1,0>:d    4:w              
(f1.0)  sel (16|M0)              r56.0<1>:d    r2.0<0;1,0>:w     0:w               {F@1}
L13120:
        join (16|M0)                         L13352                                
L13136:
        add (16|M0)              r56.0<1>:d    r106.0<1;1,0>:d   r56.0<1;1,0>:d   {Compacted,I@2}
        cmp (16|M0)   (gt)f1.0   null<1>:d     r56.0<1;1,0>:ud   0x7FFFFF:ud              {I@1}
        add3 (16|M0)             r2.0<1>:d     r60.0<1;0>:d      r62.0<1;0>:d      -45:w              
(f1.0)  sel (16|M0)              r42.0<1>:d    r2.0<1;1,0>:d     r68.0<1;1,0>:d   {Compacted,I@1}
        cmp (16|M0)   (eq)f0.1   null<1>:d     r42.0<1;1,0>:d    255:w               {I@1}
(f0.1)  goto (16|M0)                         L13288                  L13288                
L13216:
(~f1.0) sel (16|M0)              r2.0<1>:d     r56.0<1;1,0>:d    0:w              
        and (16|M0)              r8.0<1>:d     r46.0<1;1,0>:d    -2147483648:d              
        shl (16|M0)              r10.0<1>:d    r42.0<1;1,0>:d    23:w               {Compacted}
        bfn.0xFE (16|M0)         r98.0<1>:ud   r8.0<1;0>:ud      r10.0<1;0>:ud     r2.0<1>:ud       {I@1} // s0|s1|s2
        goto (16|M0)                         L13288                  L13888                
L13288:
        join (16|M0)                         L13352                                
L13304:
        cmp (16|M0)   (gt)f1.0   null<1>:d     r46.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r2.0<1>:f     inf:f                               {Compacted,I@4}
(f1.0)  sel (16|M0)              r98.0<1>:f    r2.0<0;1,0>:f     -inf:f               {Compacted,F@1}
        goto (16|M0)                         L13352                  L13888                
L13352:
        join (16|M0)                         L13664                                
L13368:
        and (16|M0)   (ne)f1.1   r26.0<1>:d    r62.0<1;1,0>:d    63:w              
(f1.1)  goto (16|M0)                         L13432                  L13432                
L13400:
        mov (16|M0)              r52.0<1>:d    -1:w                              
        goto (16|M0)                         L13432                  L13560                
L13432:
        join (16|M0)                         L13560                                
L13448:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r26.0<1;1,0>:ud   0x20:uw              {A@1}
(f1.0)  goto (16|M0)                         L13512                  L13512                
L13480:
        mov (16|M0)              r52.0<1>:d    0:w                              
        goto (16|M0)                         L13512                  L13560                
L13512:
        join (16|M0)                         L13560                                
L13528:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                             
        shl (16|M0)              r52.0<1>:d    r2.0<0;1,0>:w     r26.0<1;1,0>:d   {F@1}
L13560:
        join (16|M0)                         L13664                                
L13576:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r52.0<1;0>:ud     r6.5<0;0>:ud      r56.0<1>:ud      {I@2} // (s0^s1)&s2
        add (16|M0)              r8.0<1>:d     -r62.0<1;1,0>:d   23:w               {Compacted}
        and (16|M0)              r10.0<1>:d    r46.0<1;1,0>:d    -2147483648:d              
        shl (16|M0)              r12.0<1>:d    r68.0<1;1,0>:d    23:w               {Compacted}
        shl (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     r8.0<1;1,0>:d    {Compacted,I@3}
        bfn.0xFE (16|M0)         r98.0<1>:ud   r10.0<1;0>:ud     r12.0<1;0>:ud     r2.0<1>:ud       {I@1} // s0|s1|s2
        goto (16|M0)                         L13664                  L13888                
L13664:
        join (16|M0)                         L13728                                
L13680:
        cmp (16|M0)   (gt)f0.1   null<1>:d     r46.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r2.0<1>:f     inf:f                               {Compacted,I@4}
(f0.1)  sel (16|M0)              r98.0<1>:f    r2.0<0;1,0>:f     -inf:f               {Compacted,F@1}
        goto (16|M0)                         L13728                  L13888                
L13728:
        join (16|M0)                         L13792                                
L13744:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r46.0<1;1,0>:d    0:w              
(W)     mov (1|M0)               r2.0<1>:f     -0.0:f                               {Compacted}
(f1.1)  sel (16|M0)              r98.0<1>:f    r2.0<0;1,0>:f     0.0:f               {Compacted,F@1}
        goto (16|M0)                         L13792                  L13888                
L13792:
        join (16|M0)                         L13856                                
L13808:
        cmp (16|M0)   (gt)f1.0   null<1>:d     r46.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r2.0<1>:f     inf:f                               {Compacted}
(f1.0)  sel (16|M0)              r98.0<1>:f    r2.0<0;1,0>:f     -inf:f               {Compacted,F@1}
        goto (16|M0)                         L13856                  L13888                
L13856:
        join (16|M0)                         L13888                                
L13872:
        bfn.0xF8 (16|M0)         r98.0<1>:ud   r46.0<1;0>:ud     r6.7<0;0>:ud      r6.6<0>:ud       {F@1} // s0&s1|s2
L13888:
        join (16|M0)                         L14288                                
L13904:
        shl (16|M0)              r8.0<1>:d     r38.0<1;1,0>:d    1:w               {Compacted}
        addc (8|M0)              r14.0<1>:ud   r8.0<1;1,0>:ud    r6.3<0;1,0>:ud   {AccWrEn,Compacted,I@1}
        cmp (16|M0)   (lt)f0.1   null<1>:f     r40.0<1;1,0>:f    0.0:f              
        mov (8|M0)               r16.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        addc (8|M8)              r15.0<1>:ud   r9.0<1;1,0>:ud    r6.3<0;1,0>:ud   {AccWrEn}
        shr (16|M0)              r10.0<1>:ud   r38.0<1;1,0>:ud   31:w              
        mov (8|M8)               r22.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        addc (8|M0)              r26.0<1>:ud   r38.0<1;1,0>:ud   r6.0<0;1,0>:ud   {AccWrEn,Compacted}
        shl (16|M0)              r12.0<1>:d    r36.0<1;1,0>:d    1:w               {Compacted}
        add (8|M0)               r112.0<1>:ud  acc0.0<1;1,0>:ud  r36.0<1;1,0>:ud 
        addc (8|M8)              r27.0<1>:ud   r39.0<1;1,0>:ud   r6.0<0;1,0>:ud   {AccWrEn}
(f0.1)  sel (16|M0)              r2.0<1>:f     -r98.0<1;1,0>:f   r98.0<1;1,0>:f   {Compacted}
        cmp (16|M0)   (lt)f1.1   null<1>:d     r26.0<1;1,0>:ud   r4.6<0;1,0>:ud   {I@1}
        add (8|M8)               r113.0<1>:ud  acc0.0<1;1,0>:ud  r37.0<1;1,0>:ud 
        or (16|M0)               r12.0<1>:d    r12.0<1;1,0>:d    r10.0<1;1,0>:d   {Compacted}
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r112.0<1;1,0>:d   r4.7<0;1,0>:d    {I@2}
        mov (8|M0)               r7.0<1>:hf    r2.0<1;1,0>:f                    {F@1}
        mov (8|M8)               r7.8<1>:hf    r3.0<1;1,0>:f                   
(~f1.1) cmp (16|M0)   (lt)f1.1   null<1>:d     r112.0<1;1,0>:ud  r4.7<0;1,0>:ud  
        add3 (8|M0)              r17.1<2>:ud   r16.0<1;0>:ud     r12.0<1;0>:ud     r6.4<0>:ud       {I@3}
        add3 (8|M8)              r19.1<2>:ud   r22.0<1;0>:ud     r13.0<1;0>:ud     r6.4<0>:ud      
        mov (16|M0)              r2.0<1>:ud    r7.0<1;1,0>:uw                   {A@1}
        mov (8|M0)               r17.0<2>:d    r14.0<1;1,0>:d                  
        mov (8|M8)               r19.0<2>:d    r15.0<1;1,0>:d                  
        send.ugm (16|M0)         null     r17     r2:2    0x0            0x080E0B84           {A@1,$3} // wr:4+2, rd:0; store.ugm.d16u32.a64.wb.wb
(~f1.1) goto (16|M0)                         L14288                  L14288                
L14256:
(f1.1)  sel (16|M0)              r38.0<1>:d    r26.0<1;1,0>:d    r34.0<1;1,0>:d   {Compacted}
(f1.1)  sel (16|M0)              r36.0<1>:d    r112.0<1;1,0>:d   r32.0<1;1,0>:d   {Compacted}
(W)     jmpi                                 L616                                
L14288:
        join (16|M0)                         L14304                                
L14304:
(W)     mov (8|M0)               r127.0<1>:f   r44.0<1;1,0>:f                   {Compacted,$2.src}
(W)     send.gtwy (1|M0)         null     r127    null:0  0x0            0x02000010           {EOT,A@1} // wr:1+0, rd:0; end of thread
L14328:
        nop                    
(W)     mov (16|M0)              null<1>:ud    0x9E09665A:ud                             
(W)     mov (16|M0)              null<1>:ud    0xA6E09A48:ud                             
(W)     mov (16|M0)              null<1>:ud    0x0:ud                             
(W)     mov (16|M0)              null<1>:ud    0x5A:ud                             
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
