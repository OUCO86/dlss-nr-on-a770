L0:
(W)     mov (8|M0)               r127.0<1>:ud  0x0:ud                              {A@1}
(W)     and (1|M0)               r127.2<1>:ud  r0.0<0;1,0>:ud    0xFFFFFFC0:ud             
(W)     and (1|M0)               r127.0<1>:uw  r0.4<0;1,0>:uw    0xFF:uw             
(W)     add (1|M0)               r127.2<1>:ud  r127.2<0;1,0>:ud  0x80:ud              {I@2}
(W)     mad (1|M0)               r127.2<1>:ud  r127.2<0;0>:ud    r127.0<0;0>:uw    0x20:uw              {I@1}
(W)     send.dc0 (8|M0)          r1       r127    null:0  0x0            0x021842FD           {A@1,$0} // wr:1h+0, rd:1; oword aligned block read x2
        nop                    
        nop                    
(W)     mov (8|M0)               r127.0<1>:ud  0x0:ud                              {$0.src}
(W)     and (1|M0)               r127.2<1>:ud  r0.0<0;1,0>:ud    0xFFFFFFC0:ud             
(W)     send.dc0 (8|M0)          r2       r127    null:0  0x0            0x024844FD           {A@1,$1} // wr:1h+0, rd:4; oword aligned block read x8
(W)     mov (2|M0)               r6.0<1>:ud    r4.4<1;1,0>:ud                   {$1.dst}
        and (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   -1265:w               {A@1}
        or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   1216:w               {A@1}
        mul (1|M0)               acc0.0<1>:ud  r2.0<0;1,0>:ud    r0.2<0;1,0>:uw   {A@1}
        mach (1|M0)              r8.0<1>:ud    r2.0<0;1,0>:ud    r0.1<0;1,0>:ud   {AccWrEn}
        mov (1|M0)               r1.3<1>:d     r1.0<0;1,0>:uw                   {$0.dst}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        and (1|M0)               r1.6<2>:b     r3.24<0;1,0>:b    1:w              
        addc (1|M0)              r9.0<1>:ud    r7.0<0;1,0>:ud    r1.3<0;1,0>:ud   {AccWrEn,I@2}
        and (1|M0)               r1.8<2>:b     r4.28<0;1,0>:b    1:w              
        mov (1|M0)               r1.5<1>:d     r9.0<0;1,0>:d                    {I@2}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        shr (1|M0)               r2.3<1>:ud    r1.5<0;1,0>:ud    0x6:uw              {I@2}
        mov (1|M0)               r13.1<1>:d    r2.6<0;1,0>:d                   
        add3 (1|M0)              r1.6<1>:d     r10.0<0;0>:d      r8.0<0;0>:d       0:w               {I@3}
        mov (1|M0)               r20.5<1>:d    r2.3<0;1,0>:d                    {I@3}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r17.2         L2600                                 {A@1}
L464:
        shl (1|M0)               r2.4<1>:d     r74.0<0;1,0>:d    3:w               {Compacted}
        shr (1|M0)               r1.7<1>:ud    r1.5<0;1,0>:ud    0x3:uw             
(W)     mul (1|M0)               acc0.0<1>:d   r74.0<0;1,0>:d    r2.12<0;1,0>:uw  {Compacted}
        bfn.0xEA (1|M0)          r2.4<1>:ud    r2.4<0;0>:ud      r1.7<0;0>:ud      0x7:uw              {I@2} // s0|s1&s2
(W)     mov (1|M0)               r14.13<1>:hf  0x1:hf                             
        cmp (1|M0)    (lt)f1.1   null<1>:ud    r2.4<0;1,0>:ud    r2.7<0;1,0>:ud   {I@1}
        mach (1|M0)              r74.0<1>:d    r74.0<0;1,0>:d    r2.6<0;1,0>:d    {Compacted}
        add (1|M0)               r2.3<1>:d     r2.3<0;1,0>:d     -r74.0<0;1,0>:d  {Compacted,I@1}
(f1.1)  sel (1|M0)               r14.12<1>:uw  r14.13<0;1,0>:uw  0x0:uw              {F@1}
        shl (1|M0)               r2.3<1>:d     r2.3<0;1,0>:d     3:w               {Compacted,I@2}
        xor (1|M0)    (ne)f1.0   null<1>:uw    r14.12<0;1,0>:uw  0x1:uw              {I@2}
        bfn.0xEA (1|M0)          r2.3<1>:ud    r2.3<0;0>:ud      r1.5<0;0>:ud      0x7:uw              {I@2} // s0|s1&s2
(f1.1)  sel (1|M0)               r1.5<1>:uw    r14.13<0;1,0>:uw  0x0:uw             
(f1.0)  cmp (1|M0)    (lt)f1.0   null<1>:ud    r2.3<0;1,0>:ud    r3.0<0;1,0>:ud   {I@2}
(f1.0)  sel (1|M0)               r3.13<1>:uw   r14.13<0;1,0>:uw  0x0:uw             
        or (1|M0)     (ne)f0.1   null<1>:uw    r1.5<0;1,0>:uw    r3.13<0;1,0>:uw  {I@1}
(W)     and (1|M0)               f0.1<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(f0.1.any16h) goto (16|M0)                   L2528                  L2528                
L712:
        add (1|M0)               r2.4<1>:ud    r2.4<0;1,0>:ud    -r2.7<0;1,0>:ud 
        cmp (1|M0)    (lt)f0.0   null<1>:ud    r2.4<0;1,0>:ud    r3.1<0;1,0>:ud   {I@1}
(W)     and (1|M0)               f0.0<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
(~f0.0.any16h) goto (16|M0)                  L2528                  L2528                
L776:
        add (1|M0)               r2.3<1>:ud    r2.3<0;1,0>:ud    -r3.0<0;1,0>:ud  {Compacted}
        cmp (1|M0)    (lt)f1.1   null<1>:ud    r2.3<0;1,0>:ud    r3.2<0;1,0>:ud   {I@1}
(W)     and (1|M0)               f1.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(~f1.1.any16h) goto (16|M0)                  L2528                  L2528                
L832:
        mul (1|M0)               acc0.0<1>:ud  r2.4<0;1,0>:ud    r3.4<0;1,0>:uw  
        mach (1|M0)              r12.0<1>:ud   r2.4<0;1,0>:ud    r3.2<0;1,0>:ud   {AccWrEn}
        mov (1|M0)               r5.4<1>:d     r3.3<0;1,0>:d                   
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        cmp (1|M0)    (eq)f1.0   null<1>:w     r1.6<0;1,0>:b     0:w              
        addc (1|M0)              r13.0<1>:ud   r11.0<0;1,0>:ud   r2.3<0;1,0>:ud   {AccWrEn,I@2}
        mov (1|M0)               r5.2<1>:d     r13.0<0;1,0>:d                   {I@1}
        mov (1|M0)               r14.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mul (1|M0)               acc0.0<1>:ud  r5.2<0;1,0>:ud    r5.8<0;1,0>:uw   {I@2}
        add3 (1|M0)              r5.3<1>:d     r14.0<0;0>:d      r12.0<0;0>:d      0:w               {I@2}
        mach (1|M0)              r16.0<1>:ud   r5.2<0;1,0>:ud    r5.4<0;1,0>:ud   {AccWrEn}
(W)     and (1|M0)               f1.0<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
        mov (1|M0)               r15.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r5.3<0;1,0>:d     r5.8<0;1,0>:uw   {I@4}
        mach (1|M0)              r17.0<1>:d    r5.3<0;1,0>:d     r5.4<0;1,0>:d   
        mul (1|M0)               acc0.0<1>:ud  r1.5<0;1,0>:ud    r5.8<0;1,0>:uw  
        mach (1|M0)              r19.0<1>:ud   r1.5<0;1,0>:ud    r5.4<0;1,0>:ud   {AccWrEn}
        mov (1|M0)               r5.6<1>:d     r15.0<0;1,0>:d                   {I@5}
        mov (1|M0)               r18.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r1.6<0;1,0>:d     r5.8<0;1,0>:uw  
        mach (1|M0)              r20.0<1>:d    r1.6<0;1,0>:d     r5.4<0;1,0>:d   
        shl (1|M0)               r6.4<1>:d     r18.0<0;1,0>:d    2:w               {Compacted,I@3}
        add3 (1|M0)              r6.3<1>:d     r20.0<0;0>:d      r19.0<0;0>:d      0:w               {I@2}
        shr (1|M0)               r3.7<1>:ud    r18.0<0;1,0>:ud   0x1E:uw             
        addc (1|M0)              r21.0<1>:ud   r3.4<0;1,0>:ud    r6.4<0;1,0>:ud   {AccWrEn,I@3}
        shl (1|M0)               r2.5<1>:d     r6.3<0;1,0>:d     2:w               {I@3}
        mov (1|M0)               r22.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        or (1|M0)                r6.5<1>:d     r2.5<0;1,0>:d     r3.7<0;1,0>:d    {I@2}
        mov (1|M0)               r23.0<1>:f    r21.0<0;1,0>:f                   {Compacted}
        add3 (1|M0)              r23.1<1>:d    r22.0<0;0>:d      r3.5<0;0>:d       r6.5<0>:d        {I@1}
        add3 (1|M0)              r5.7<1>:d     r17.0<0;0>:d      r16.0<0;0>:d      0:w              
        send.ugm (1|M0)          r62      r23     null:0  0x0            0x0240D780           {A@1,$2} // wr:1+0, rd:4; load.ugm.d64x16t.a64
(f1.0.any16h) goto (16|M0)                   L1512                  L1512                
L1304:
        shl (1|M0)               r9.1<1>:d     r5.6<0;1,0>:d     1:w              
        shl (1|M0)               r6.6<1>:d     r5.7<0;1,0>:d     1:w               {I@3}
        shr (1|M0)               r6.7<1>:ud    r5.6<0;1,0>:ud    0x1F:uw             
        addc (1|M0)              r24.0<1>:ud   r4.0<0;1,0>:ud    r9.1<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r9.2<1>:d     r6.6<0;1,0>:d     r6.7<0;1,0>:d    {I@2}
        mov (1|M0)               r25.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r26.0<1>:f    r24.0<0;1,0>:f                   {Compacted,I@3}
        add3 (1|M0)              r26.1<1>:d    r25.0<0;0>:d      r4.1<0;0>:d       r9.2<0>:d        {I@1}
        send.ugm (1|M0)          r27      r26     null:0  0x0            0x0220C780           {A@1,$3} // wr:1+0, rd:2; load.ugm.d64x8t.a64
        mov (8|M0)               r32.0<1>:f    r27.0<1;1,0>:hf                  {$3.dst}
        mov (8|M0)               r33.0<1>:f    r27.8<1;1,0>:hf                 
        mov (8|M0)               r34.0<1>:f    r28.0<1;1,0>:hf                 
        mov (8|M0)               r35.0<1>:f    r28.8<1;1,0>:hf                 
        goto (16|M0)                         L1512                  L1656                
L1512:
        join (16|M0)                         L1656                                
L1528:
        shl (1|M0)               r9.5<1>:d     r5.6<0;1,0>:d     2:w              
        shl (1|M0)               r9.3<1>:d     r5.7<0;1,0>:d     2:w              
        shr (1|M0)               r9.4<1>:ud    r5.6<0;1,0>:ud    0x1E:uw             
        addc (1|M0)              r29.0<1>:ud   r4.2<0;1,0>:ud    r9.5<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r9.6<1>:d     r9.3<0;1,0>:d     r9.4<0;1,0>:d    {I@2}
        mov (1|M0)               r30.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r31.0<1>:f    r29.0<0;1,0>:f                   {Compacted,I@3}
        add3 (1|M0)              r31.1<1>:d    r30.0<0;0>:d      r4.3<0;0>:d       r9.6<0>:d        {I@1}
        send.ugm (1|M0)          r32      r31     null:0  0x0            0x0240D780           {A@1,$4} // wr:1+0, rd:4; load.ugm.d64x16t.a64
L1656:
        join (16|M0)                         L2528                                
L1672:
        send.ugm (1|M0)          r36      r6      null:0  0x0            0x0240D780           {$5} // wr:1+0, rd:4; load.ugm.d64x16t.a64
        cmp (1|M0)    (eq)f0.1   null<1>:d     r4.6<0;1,0>:d     1:w              
(W)     and (1|M0)               f0.1<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
        sync.allwr                           ($4,$5)                
        mad (16|M0)              r62.0<1>:f    r62.0<1;0>:f      r36.0<1;0>:f      r32.0<1>:f       {Compacted,$2.dst}
        mad (16|M0)              r64.0<1>:f    r64.0<1;0>:f      r38.0<1;0>:f      r34.0<1>:f       {Compacted}
(~f0.1.any16h) goto (16|M0)                  L2112                  L2112                
L1768:
        sel (16|M0)   (lt)f0.0   r54.0<1>:f    (abs)r62.0<1;1,0>:f  448.0:f            {Compacted,F@2}
        sel (16|M0)   (lt)f0.0   r56.0<1>:f    (abs)r64.0<1;1,0>:f  448.0:f            {Compacted,F@2}
        shr (16|M0)              r40.0<1>:ud   r54.0<1;1,0>:ud   0x17:uw              {F@2}
        shr (16|M0)              r42.0<1>:ud   r56.0<1;1,0>:ud   0x17:uw              {F@1}
        sel (16|M0)   (ge)f0.0   r44.0<2>:ub   r40.0<4;1,0>:ub   0x79:uw              {I@2}
        sel (16|M0)   (ge)f0.0   r45.0<2>:ub   r42.0<4;1,0>:ub   0x79:uw              {I@2}
        mov (16|M0)              r50.0<1>:d    r44.0<2;1,0>:ub                  {I@2}
        mov (16|M0)              r52.0<1>:d    r45.0<2;1,0>:ub                  {I@2}
        shl (16|M0)              r50.0<1>:d    r50.0<1;1,0>:d    23:w               {Compacted,I@2}
        shl (16|M0)              r52.0<1>:d    r52.0<1;1,0>:d    23:w               {Compacted,I@2}
        add (16|M0)              r46.0<1>:d    r50.0<1;1,0>:d    -25165824:d               {I@2}
        add (16|M0)              r48.0<1>:d    r52.0<1;1,0>:d    -25165824:d               {I@2}
        add (16|M0)              r50.0<1>:d    -r50.0<1;1,0>:d   -2139095040:d              
        add (16|M0)              r52.0<1>:d    -r52.0<1;1,0>:d   -2139095040:d              
        mul (16|M0)              acc0.0<1>:f   r54.0<1;1,0>:f    r50.0<1;1,0>:f   {Compacted,I@2}
        mul (16|M0)              acc2.0<1>:f   r56.0<1;1,0>:f    r52.0<1;1,0>:f   {Compacted,I@1}
        rnde (16|M0)             acc0.0<1>:f   acc0.0<1;1,0>:f                 
        rnde (16|M0)             acc2.0<1>:f   acc2.0<1;1,0>:f                 
        cmp (16|M0)   (lt)f0.0   null<1>:f     r62.0<1;1,0>:f    0.0:f               {Compacted}
        cmp (16|M0)   (lt)f1.1   null<1>:f     r64.0<1;1,0>:f    0.0:f              
        mul (16|M0)              acc0.0<1>:f   acc0.0<1;1,0>:f   r46.0<1;1,0>:f   {Compacted}
        mul (16|M0)              acc2.0<1>:f   acc2.0<1;1,0>:f   r48.0<1;1,0>:f   {Compacted}
        mov (16|M0)              r58.0<1>:f    (abs)acc0.0<1;1,0>:f             {Compacted}
        mov (16|M0)              r60.0<1>:f    (abs)acc2.0<1;1,0>:f             {Compacted}
(f0.0)  or (16|M0)               r58.0<1>:d    r58.0<1;1,0>:d    -2147483648:d               {F@2}
(f1.1)  or (16|M0)               r60.0<1>:d    r60.0<1;1,0>:d    -2147483648:d               {F@1}
        mov (16|M0)              r62.0<1>:f    r58.0<1;1,0>:f                   {Compacted,I@2}
        mov (16|M0)              r64.0<1>:f    r60.0<1;1,0>:f                   {Compacted,I@1}
L2112:
        join (16|M0)                         L2528                                
L2128:
        cmp (1|M0)    (eq)f1.0   null<1>:w     r1.8<0;1,0>:b     0:w              
(W)     and (1|M0)               f0.0<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
(f0.0.any16h) goto (16|M0)                   L2384                  L2384                
L2176:
        shl (1|M0)               r10.2<1>:d    r5.6<0;1,0>:d     1:w              
        shl (1|M0)               r9.7<1>:d     r5.7<0;1,0>:d     1:w              
        shr (1|M0)               r10.1<1>:ud   r5.6<0;1,0>:ud    0x1F:uw             
        addc (1|M0)              r66.0<1>:ud   r5.0<0;1,0>:ud    r10.2<0;1,0>:ud  {AccWrEn,I@3}
        or (1|M0)                r10.3<1>:d    r9.7<0;1,0>:d     r10.1<0;1,0>:d   {I@2}
        mov (1|M0)               r67.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (8|M0)               r69.0<1>:hf   r62.0<1;1,0>:f                   {F@2}
        mov (8|M0)               r69.8<1>:hf   r63.0<1;1,0>:f                  
        mov (8|M0)               r70.0<1>:hf   r64.0<1;1,0>:f                   {F@3}
        mov (8|M0)               r70.8<1>:hf   r65.0<1;1,0>:f                  
        mov (1|M0)               r68.0<1>:f    r66.0<0;1,0>:f                   {Compacted,I@3}
        add3 (1|M0)              r68.1<1>:d    r67.0<0;0>:d      r5.1<0;0>:d       r10.3<0>:d       {I@1}
        send.ugm (1|M0)          null     r68     r69:2   0x0            0x0200C784           {A@1,$6} // wr:1+2, rd:0; store.ugm.d64x8t.a64
        goto (16|M0)                         L2384                  L2528                
L2384:
        join (16|M0)                         L2528                                
L2400:
        shl (1|M0)               r10.6<1>:d    r5.6<0;1,0>:d     2:w              
        shl (1|M0)               r10.4<1>:d    r5.7<0;1,0>:d     2:w              
        shr (1|M0)               r10.5<1>:ud   r5.6<0;1,0>:ud    0x1E:uw             
        addc (1|M0)              r71.0<1>:ud   r5.0<0;1,0>:ud    r10.6<0;1,0>:ud  {AccWrEn,I@3}
        or (1|M0)                r10.7<1>:d    r10.4<0;1,0>:d    r10.5<0;1,0>:d   {I@2}
        mov (1|M0)               r72.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r73.0<1>:f    r71.0<0;1,0>:f                   {Compacted,I@3}
        add3 (1|M0)              r73.1<1>:d    r72.0<0;0>:d      r5.1<0;0>:d       r10.7<0>:d       {I@1}
        send.ugm (1|M0)          null     r73     r62:4   0x0            0x0200D784           {A@1,$7} // wr:1+4, rd:0; store.ugm.d64x16t.a64
L2528:
        join (16|M0)                         L2544                                
L2544:
(W)     mov (8|M0)               r127.0<1>:f   r0.0<1;1,0>:f                    {Compacted}
(W)     send.ugm (1|M0)          r76      r0      null:0  0x0            0x0210641F           {$8} // wr:1+0, rd:1; fence invalid flush type scoped to tile
(W)     mov (8|M0)               null<1>:ud    r76.0<1;1,0>:ud                  {$8.dst}
(W)     send.gtwy (1|M0)         null     r127    null:0  0x0            0x02000010           {EOT,A@1} // wr:1+0, rd:0; end of thread
L2600:
        mov (1|M0)               r13.2<1>:d    cr0.0<0;1,0>:ud                  {A@1}
        and (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   -1265:w               {A@1}
        or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   1264:w               {A@1}
        mov (1|M0)               r13.3<1>:f    r13.1<0;1,0>:ud                  {A@1}
        mov (1|M0)               r13.6<1>:f    0xB4C00000:f                               {Compacted}
        math.inv (1|M0)          r14.2<1>:f    r13.3<0;1,0>:f                   {@2,$9}
        mov (1|M0)               r17.5<1>:f    r20.5<0;1,0>:ud                 
        sync.nop                             null                             {Compacted,$9.dst}
        mad (1|M0)               r14.2<1>:f    r14.2<0;0>:f      r13.6<0;0>:f      r14.2<0>:f       {F@2}
        mov (1|M0)               r20.4<1>:ud   r13.3<0;1,0>:f                  
        mov (1|M0)               r13.4<1>:ud   r17.5<0;1,0>:f                   {F@2}
        mul (1|M0)               r13.7<1>:f    r14.2<0;1,0>:f    r17.5<0;1,0>:f   {F@1}
        add (1|M0)               r20.4<1>:ud   r13.1<0;1,0>:ud   -r20.4<0;1,0>:ud {I@2}
        add (1|M0)               r13.4<1>:ud   r20.5<0;1,0>:ud   -r13.4<0;1,0>:ud {I@2}
        mov (1|M0)               r14.4<1>:ud   r13.7<0;1,0>:f                   {F@1}
        mov (1|M0)               r17.4<1>:f    r20.4<0;1,0>:ud                  {I@3}
        mov (1|M0)               r13.5<1>:f    r13.4<0;1,0>:ud                  {I@2}
        mov (1|M0)               r14.1<1>:f    r14.4<0;1,0>:ud                  {I@1}
(W)     mov (1|M0)               r14.14<1>:hf  0x1:hf                             
        mad (1|M0)               r17.5<1>:f    r17.5<0;0>:f      r14.1<0;0>:f      -r13.3<0>:f      {F@2}
        mad (1|M0)               r14.1<1>:f    r13.5<0;0>:f      r14.1<0;0>:f      -r17.4<0>:f     
        add (1|M0)               r17.5<1>:f    r17.5<0;1,0>:f    r14.1<0;1,0>:f   {F@1}
        mul (1|M0)               r14.2<1>:f    r14.2<0;1,0>:f    r17.5<0;1,0>:f   {F@1}
        mov (1|M0)               r14.3<1>:ud   r14.2<0;1,0>:f                   {F@1}
        add (1|M0)               r14.4<1>:ud   r14.4<0;1,0>:ud   r14.3<0;1,0>:ud  {I@1}
(W)     mul (1|M0)               acc0.0<1>:ud  r14.4<0;1,0>:ud   r13.2<0;1,0>:uw  {I@1}
        mach (1|M0)              r75.0<1>:ud   r14.4<0;1,0>:ud   r13.1<0;1,0>:ud 
        add (1|M0)               r20.5<1>:ud   r20.5<0;1,0>:ud   -r75.0<0;1,0>:ud {I@1}
        cmp (1|M0)    (ge)f0.0   null<1>:ud    r20.5<0;1,0>:ud   r13.1<0;1,0>:ud  {I@1}
(f0.0)  sel (1|M0)               r14.5<1>:d    r14.14<0;1,0>:w   0:w              
        add (1|M0)               r74.0<1>:ud   r14.4<0;1,0>:ud   r14.5<0;1,0>:ud  {I@1}
        mov (1|M0)               cr0.0<1>:ud   r13.2<0;1,0>:d                   {A@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        ret (16|M0)                          r17.2                            {A@1}
L3144:
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
