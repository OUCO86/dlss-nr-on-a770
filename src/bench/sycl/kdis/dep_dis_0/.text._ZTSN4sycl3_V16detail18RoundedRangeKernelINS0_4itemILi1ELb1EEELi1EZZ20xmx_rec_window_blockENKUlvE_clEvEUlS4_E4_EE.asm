L0:
(W)     mov (8|M0)               r127.0<1>:ud  0x0:ud                              {A@1}
(W)     and (1|M0)               r127.2<1>:ud  r0.0<0;1,0>:ud    0xFFFFFFC0:ud             
(W)     and (1|M0)               r127.0<1>:uw  r0.4<0;1,0>:uw    0xFF:uw             
(W)     add (1|M0)               r127.2<1>:ud  r127.2<0;1,0>:ud  0x40:ud              {I@2}
(W)     mad (1|M0)               r127.2<1>:ud  r127.2<0;0>:ud    r127.0<0;0>:uw    0x20:uw              {I@1}
(W)     send.dc0 (8|M0)          r1       r127    null:0  0x0            0x021842FD           {A@1,$0} // wr:1h+0, rd:1; oword aligned block read x2
        nop                    
        nop                    
(W)     mov (8|M0)               r127.0<1>:ud  0x0:ud                              {$0.src}
(W)     and (1|M0)               r127.2<1>:ud  r0.0<0;1,0>:ud    0xFFFFFFC0:ud             
(W)     send.dc0 (8|M0)          r2       r127    null:0  0x0            0x022843FD           {A@1,$1} // wr:1h+0, rd:2; oword aligned block read x4
        and (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   -1265:w               {A@1}
        or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   1216:w               {A@1}
        sync.nop                             null                             {Compacted,A@1}
        sync.nop                             null                             {Compacted,$1.dst}
        mul (1|M0)               acc0.0<1>:ud  r2.3<0;1,0>:ud    r0.2<0;1,0>:uw   {A@1}
        mach (1|M0)              r5.0<1>:ud    r2.3<0;1,0>:ud    r0.1<0;1,0>:ud   {AccWrEn}
        mov (1|M0)               r1.2<1>:d     r1.0<0;1,0>:uw                   {$0.dst}
        mov (1|M0)               r4.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
(W)     mov (1|M0)               r7.12<1>:hf   0x1:hf                             
        addc (1|M0)              r6.0<1>:ud    r4.0<0;1,0>:ud    r1.2<0;1,0>:ud   {AccWrEn,I@1}
        mov (1|M0)               r1.6<1>:d     r6.0<0;1,0>:d                    {I@1}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        cmp (1|M0)    (lt)f1.1   null<1>:ud    r1.6<0;1,0>:ud    r3.0<0;1,0>:ud   {I@2}
        add3 (1|M0)              r1.7<1>:d     r7.0<0;0>:d       r5.0<0;0>:d       0:w               {I@2}
        mul (1|M0)               acc0.0<1>:ud  r2.0<0;1,0>:ud    r2.6<0;1,0>:uw  
        cmp (1|M0)    (lt)f0.1   null<1>:ud    r1.7<0;1,0>:ud    r3.1<0;1,0>:ud   {I@2}
(f1.1)  cmp (1|M0)    (eq)f1.1   null<1>:d     r1.7<0;1,0>:d     r3.1<0;1,0>:d   
        mach (1|M0)              r9.0<1>:ud    r2.0<0;1,0>:ud    r2.3<0;1,0>:ud   {AccWrEn}
(f0.1)  sel (1|M0)               r6.14<1>:uw   r7.12<0;1,0>:uw   0x0:uw              {F@1}
(f1.1)  sel (1|M0)               r1.3<1>:uw    r7.12<0;1,0>:uw   0x0:uw             
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        or (1|M0)     (ne)f0.1   null<1>:uw    r1.3<0;1,0>:uw    r6.14<0;1,0>:uw  {I@2}
        mov (1|M0)               r1.5<1>:d     r9.0<0;1,0>:d                   
        mov (1|M0)               r1.4<1>:d     r8.0<0;1,0>:d                    {I@3}
(W)     and (1|M0)               f0.1<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(~f0.1.any16h) goto (16|M0)                  L1496                  L1496                
L552:
        shl (1|M0)               r2.6<1>:d     r1.7<0;1,0>:d     5:w              
        shr (1|M0)               r2.7<1>:ud    r1.6<0;1,0>:ud    0x1B:uw             
        shl (1|M0)               r3.2<1>:d     r1.6<0;1,0>:d     5:w              
        or (1|M0)                r3.3<1>:d     r2.6<0;1,0>:d     r2.7<0;1,0>:d    {I@2}
        shl (1|M0)               r6.3<1>:d     r3.2<0;1,0>:d     2:w               {I@2}
        shr (1|M0)               r6.2<1>:ud    r3.2<0;1,0>:ud    0x1E:uw             
        shl (1|M0)               r6.1<1>:d     r3.3<0;1,0>:d     2:w               {I@3}
        addc (1|M0)              r10.0<1>:ud   r3.4<0;1,0>:ud    r6.3<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r6.4<1>:d     r6.1<0;1,0>:d     r6.2<0;1,0>:d    {I@2}
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r12.0<1>:f    r10.0<0;1,0>:f                   {Compacted,I@3}
        add3 (1|M0)              r12.1<1>:d    r11.0<0;0>:d      r3.5<0;0>:d       r6.4<0>:d        {I@1}
        shl (1|M0)               r7.1<1>:d     r3.2<0;1,0>:d     1:w              
        send.ugm (1|M0)          r13      r12     null:0  0x0            0x0240D780           {A@1,$3} // wr:1+0, rd:4; load.ugm.d64x16t.a64
        addc (1|M0)              r17.0<1>:ud   r3.6<0;1,0>:ud    r7.1<0;1,0>:ud   {AccWrEn,I@1}
(W)     mov (1|M0)               r7.13<1>:hf   0x1:hf                             
        mov (1|M0)               r18.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r44.0<1>:ud   r1.6<0;1,0>:ud    r1.4<0;1,0>:ud   {AccWrEn}
        shr (1|M0)               r6.6<1>:ud    r3.2<0;1,0>:ud    0x1F:uw             
        mov (1|M0)               r7.4<1>:d     r44.0<0;1,0>:d                   {I@2}
        mov (1|M0)               r45.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        cmp (1|M0)    (lt)f1.0   null<1>:ud    r7.4<0;1,0>:ud    r3.0<0;1,0>:ud   {I@2}
        add3 (1|M0)              r7.5<1>:d     r45.0<0;0>:d      r1.7<0;0>:d       r1.5<0>:d        {I@2}
        shl (1|M0)               r6.5<1>:d     r3.3<0;1,0>:d     1:w              
        mov (1|M0)               r19.0<1>:f    r17.0<0;1,0>:f                   {Compacted,$2.src}
(f1.0)  cmp (1|M0)    (eq)f1.0   null<1>:d     r7.5<0;1,0>:d     r3.1<0;1,0>:d    {I@2}
        or (1|M0)                r7.2<1>:d     r6.5<0;1,0>:d     r6.6<0;1,0>:d    {I@2}
        add3 (1|M0)              r19.1<1>:d    r18.0<0;0>:d      r3.7<0;0>:d       r7.2<0>:d        {I@1}
(f1.0)  sel (1|M0)               r7.6<1>:uw    r7.13<0;1,0>:uw   0x0:uw              {F@2}
        sel (16|M0)   (lt)f0.0   r34.0<1>:f    (abs)r13.0<1;1,0>:f  448.0:f            {Compacted,$3.dst}
        shr (16|M0)              r20.0<1>:ud   r34.0<1;1,0>:ud   0x17:uw              {F@1}
        sel (16|M0)   (ge)f0.0   r24.0<2>:ub   r20.0<4;1,0>:ub   0x79:uw              {I@1}
        mov (16|M0)              r30.0<1>:d    r24.0<2;1,0>:ub                  {I@1}
        shl (16|M0)              r30.0<1>:d    r30.0<1;1,0>:d    23:w               {Compacted,I@1}
        sel (16|M0)   (lt)f0.0   r36.0<1>:f    (abs)r15.0<1;1,0>:f  448.0:f            {Compacted}
        add (16|M0)              r26.0<1>:d    r30.0<1;1,0>:d    -25165824:d               {I@1}
        add (16|M0)              r30.0<1>:d    -r30.0<1;1,0>:d   -2139095040:d              
        shr (16|M0)              r22.0<1>:ud   r36.0<1;1,0>:ud   0x17:uw              {F@1}
        mul (16|M0)              acc0.0<1>:f   r34.0<1;1,0>:f    r30.0<1;1,0>:f   {Compacted,I@2}
        sel (16|M0)   (ge)f0.0   r25.0<2>:ub   r22.0<4;1,0>:ub   0x79:uw              {I@1}
        rnde (16|M0)             acc0.0<1>:f   acc0.0<1;1,0>:f                 
        cmp (16|M0)   (lt)f0.0   null<1>:f     r13.0<1;1,0>:f    0.0:f               {Compacted}
        mov (16|M0)              r32.0<1>:d    r25.0<2;1,0>:ub                  {I@1}
        mul (16|M0)              acc0.0<1>:f   acc0.0<1;1,0>:f   r26.0<1;1,0>:f   {Compacted}
        shl (16|M0)              r32.0<1>:d    r32.0<1;1,0>:d    23:w               {Compacted,I@1}
        mov (16|M0)              r38.0<1>:f    (abs)acc0.0<1;1,0>:f             {Compacted}
        add (16|M0)              r28.0<1>:d    r32.0<1;1,0>:d    -25165824:d               {I@1}
(f0.0)  or (16|M0)               r38.0<1>:d    r38.0<1;1,0>:d    -2147483648:d               {F@1}
        add (16|M0)              r32.0<1>:d    -r32.0<1;1,0>:d   -2139095040:d              
        cmp (1|M0)    (lt)f0.0   null<1>:ud    r7.5<0;1,0>:ud    r3.1<0;1,0>:ud  
        mul (16|M0)              acc0.0<1>:f   r36.0<1;1,0>:f    r32.0<1;1,0>:f   {Compacted,I@2}
        rnde (16|M0)             acc0.0<1>:f   acc0.0<1;1,0>:f                 
(f0.0)  sel (1|M0)               r7.7<1>:uw    r7.13<0;1,0>:uw   0x0:uw             
        cmp (16|M0)   (lt)f1.1   null<1>:f     r15.0<1;1,0>:f    0.0:f              
        mul (16|M0)              acc0.0<1>:f   acc0.0<1;1,0>:f   r28.0<1;1,0>:f   {Compacted}
        or (1|M0)     (ne)f1.0   null<1>:uw    r7.6<0;1,0>:uw    r7.7<0;1,0>:uw   {I@1}
        mov (16|M0)              r40.0<1>:f    (abs)acc0.0<1;1,0>:f             {Compacted}
(f1.1)  or (16|M0)               r40.0<1>:d    r40.0<1;1,0>:d    -2147483648:d               {F@1}
(W)     and (1|M0)               f0.0<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
        mov (8|M0)               r42.0<1>:hf   r38.0<1;1,0>:f                  
        mov (8|M0)               r42.8<1>:hf   r39.0<1;1,0>:f                  
        mov (8|M0)               r43.0<1>:hf   r40.0<1;1,0>:f                   {I@2}
        mov (8|M0)               r43.8<1>:hf   r41.0<1;1,0>:f                  
        send.ugm (1|M0)          null     r19     r42:2   0x0            0x0200C784           {A@1,$2} // wr:1+2, rd:0; store.ugm.d64x8t.a64
(~f0.0.any16h) goto (16|M0)                  L1496                  L1496                
L1464:
(W)     mov (2|M0)               r1.6<1>:ud    r7.4<1;1,0>:ud                  
        goto.b (16|M0)                       L1496                  L552                
L1496:
        join (16|M0)                         L1512                                
L1512:
(W)     mov (8|M0)               r127.0<1>:f   r0.0<1;1,0>:f                    {Compacted}
(W)     send.ugm (1|M0)          r46      r0      null:0  0x0            0x0210641F           {$4} // wr:1+0, rd:1; fence invalid flush type scoped to tile
(W)     mov (8|M0)               null<1>:ud    r46.0<1;1,0>:ud                  {$4.dst}
(W)     send.gtwy (1|M0)         null     r127    null:0  0x0            0x02000010           {EOT,A@1} // wr:1+0, rd:0; end of thread
L1568:
        nop                    
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
