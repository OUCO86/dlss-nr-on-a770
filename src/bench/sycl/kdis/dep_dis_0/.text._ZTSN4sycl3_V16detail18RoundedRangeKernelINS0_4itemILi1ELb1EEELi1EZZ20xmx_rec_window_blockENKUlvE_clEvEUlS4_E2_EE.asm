L0:
(W)     mov (8|M0)               r127.0<1>:ud  0x0:ud                              {A@1}
(W)     and (1|M0)               r127.2<1>:ud  r0.0<0;1,0>:ud    0xFFFFFFC0:ud             
(W)     and (1|M0)               r127.0<1>:uw  r0.4<0;1,0>:uw    0xFF:uw             
(W)     add (1|M0)               r127.2<1>:ud  r127.2<0;1,0>:ud  0xA0:ud              {I@2}
(W)     mad (1|M0)               r127.2<1>:ud  r127.2<0;0>:ud    r127.0<0;0>:uw    0x20:uw              {I@1}
(W)     send.dc0 (8|M0)          r1       r127    null:0  0x0            0x021842FD           {A@1,$0} // wr:1h+0, rd:1; oword aligned block read x2
        nop                    
        nop                    
(W)     mov (8|M0)               r127.0<1>:ud  0x0:ud                              {$0.src}
(W)     and (1|M0)               r127.2<1>:ud  r0.0<0;1,0>:ud    0xFFFFFFC0:ud             
(W)     send.dc0 (8|M0)          r2       r127    null:0  0x0            0x024844FD           {A@1,$1} // wr:1h+0, rd:4; oword aligned block read x8
(W)     add (1|M0)               r127.2<1>:ud  r127.2<0;1,0>:ud  0x80:uw              {$1.src}
(W)     send.dc0 (8|M0)          r6       r127    null:0  0x0            0x021842FD           {A@1,$2} // wr:1h+0, rd:1; oword aligned block read x2
        and (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   -1265:w               {A@1}
        or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   1216:w               {A@1}
        sync.nop                             null                             {Compacted,A@1}
        sync.nop                             null                             {Compacted,$1.dst}
        mul (1|M0)               acc0.0<1>:ud  r2.3<0;1,0>:ud    r0.2<0;1,0>:uw   {A@1}
        mach (1|M0)              r8.0<1>:ud    r2.3<0;1,0>:ud    r0.1<0;1,0>:ud   {AccWrEn}
        mov (1|M0)               r1.2<1>:d     r1.0<0;1,0>:uw                   {$0.dst}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
(W)     mov (1|M0)               r16.12<1>:hf  0x1:hf                             
        addc (1|M0)              r4.0<1>:ud    r7.0<0;1,0>:ud    r1.2<0;1,0>:ud   {AccWrEn,I@1}
        mov (1|M0)               r1.6<1>:d     r4.0<0;1,0>:d                    {I@1}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        cmp (1|M0)    (lt)f0.0   null<1>:ud    r1.6<0;1,0>:ud    r3.0<0;1,0>:ud   {I@2}
        add3 (1|M0)              r1.7<1>:d     r9.0<0;0>:d       r8.0<0;0>:d       0:w               {I@2}
        mul (1|M0)               acc0.0<1>:ud  r2.0<0;1,0>:ud    r2.6<0;1,0>:uw  
        cmp (1|M0)    (lt)f0.1   null<1>:ud    r1.7<0;1,0>:ud    r3.1<0;1,0>:ud   {I@2}
(f0.0)  cmp (1|M0)    (eq)f0.0   null<1>:d     r1.7<0;1,0>:d     r3.1<0;1,0>:d   
        mach (1|M0)              r11.0<1>:ud   r2.0<0;1,0>:ud    r2.3<0;1,0>:ud   {AccWrEn}
(f0.1)  sel (1|M0)               r5.11<1>:uw   r16.12<0;1,0>:uw  0x0:uw              {F@1}
(f0.0)  sel (1|M0)               r1.3<1>:uw    r16.12<0;1,0>:uw  0x0:uw             
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        or (1|M0)     (ne)f1.0   null<1>:uw    r1.3<0;1,0>:uw    r5.11<0;1,0>:uw  {I@2}
        mov (1|M0)               r1.5<1>:d     r11.0<0;1,0>:d                  
        mov (1|M0)               r1.4<1>:d     r10.0<0;1,0>:d                   {I@3}
(W)     and (1|M0)               f1.0<1>:ud    f1.0<0;1,0>:uw    0x1:uw             
(~f1.0.any32h) goto (32|M0)                  L2440                  L2440                
L584:
        shr (1|M0)               r3.3<1>:ud    r1.6<0;1,0>:ud    0x6:uw             
        mov (1|M0)               r14.1<1>:d    r5.0<0;1,0>:d                   
        mov (1|M0)               r17.5<1>:d    r3.3<0;1,0>:d                    {I@2}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (32|M0)             r17.2         L2512                                 {A@1}
L680:
(W)     mul (1|M0)               acc0.0<1>:d   r57.0<0;1,0>:d    r5.0<0;1,0>:uw   {Compacted}
        shl (1|M0)               r2.6<1>:d     r57.0<0;1,0>:d    3:w               {Compacted}
        mach (1|M0)              r57.0<1>:d    r57.0<0;1,0>:d    r5.0<0;1,0>:d    {Compacted}
        and (1|M0)               r3.2<1>:d     r1.6<0;1,0>:d     7:w              
        add (1|M0)               r3.3<1>:d     r3.3<0;1,0>:d     -r57.0<0;1,0>:d  {Compacted,I@2}
        shr (1|M0)               r2.7<1>:ud    r1.6<0;1,0>:ud    0x3:uw             
        shl (1|M0)               r3.3<1>:d     r3.3<0;1,0>:d     3:w               {Compacted,I@2}
        and (1|M0)               r2.7<1>:ud    r2.7<0;1,0>:ud    0x7:uw              {I@2}
        add3 (1|M0)              r3.3<1>:d     r3.3<0;0>:d       r3.2<0;0>:d       -r5.2<0>:d       {I@2}
        add3 (1|M0)              r2.7<1>:d     r2.7<0;0>:d       -r5.1<0;0>:d      r2.6<0>:d        {I@2}
        cmp (1|M0)    (gt)f0.1   null<1>:d     r3.3<0;1,0>:d     -1:w               {I@2}
        cmp (1|M0)    (lt)f1.0   null<1>:d     r2.7<0;1,0>:d     r5.3<0;1,0>:d    {I@2}
(W)     mov (1|M0)               r16.13<1>:hf  0x1:hf                             
        cmp (1|M0)    (lt)f1.1   null<1>:d     r3.3<0;1,0>:d     r5.4<0;1,0>:d   
(f0.1)  cmp (1|M0)    (gt)f0.1   null<1>:d     r2.7<0;1,0>:d     -1:w              
(f1.0)  sel (1|M0)               r16.5<1>:uw   r16.13<0;1,0>:uw  0x0:uw              {F@1}
(f1.1)  sel (1|M0)               r16.3<1>:uw   r16.13<0;1,0>:uw  0x0:uw             
(f0.1)  sel (1|M0)               r16.4<1>:uw   r16.13<0;1,0>:uw  0x0:uw             
        and (1|M0)    (ne)f0.1   null<1>:uw    r16.4<0;1,0>:uw   r16.5<0;1,0>:uw  {I@1}
(f0.1)  sel (1|M0)               r16.2<1>:uw   r16.13<0;1,0>:uw  0x0:uw             
        and (1|M0)    (ne)f0.0   null<1>:uw    r16.2<0;1,0>:uw   r16.3<0;1,0>:uw  {I@1}
(W)     and (1|M0)               f0.0<1>:ud    f0.0<0;1,0>:uw    0x1:uw             
(f0.0.any32h) goto (32|M0)                   L1040                  L1040                
L1008:
        mov (32|M0)              r50.0<1>:uw   0x0:uw                             
        goto (32|M0)                         L1040                  L2000                
L1040:
        join (32|M0)                         L2000                                
L1056:
        mul (1|M0)               acc0.0<1>:ud  r2.7<0;1,0>:ud    r5.8<0;1,0>:uw  
        mach (1|M0)              r13.0<1>:ud   r2.7<0;1,0>:ud    r5.4<0;1,0>:ud   {AccWrEn}
        cmp (1|M0)    (eq)f1.1   null<1>:w     r5.20<0;1,0>:b    0:w              
        mov (1|M0)               r12.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r14.0<1>:ud   r12.0<0;1,0>:ud   r3.3<0;1,0>:ud   {AccWrEn,I@1}
(W)     and (1|M0)               f1.0<1>:ud    f1.1<0;1,0>:uw    0x1:uw             
        mov (1|M0)               r15.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        shr (1|M0)               r3.7<1>:ud    r14.0<0;1,0>:ud   0x1B:uw              {I@3}
        add3 (1|M0)              r3.5<1>:d     r15.0<0;0>:d      r13.0<0;0>:d      0:w               {I@2}
        shl (1|M0)               r4.1<1>:d     r14.0<0;1,0>:d    5:w               {Compacted}
        shl (1|M0)               r3.6<1>:d     r3.5<0;1,0>:d     5:w               {I@2}
        or (1|M0)                r4.2<1>:d     r3.6<0;1,0>:d     r3.7<0;1,0>:d    {I@1}
(f1.0.any32h) goto (32|M0)                   L1448                  L1448                
L1240:
        shl (1|M0)               r4.5<1>:d     r4.1<0;1,0>:d     1:w              
        shl (1|M0)               r4.3<1>:d     r4.2<0;1,0>:d     1:w               {I@3}
        shr (1|M0)               r4.4<1>:ud    r4.1<0;1,0>:ud    0x1F:uw             
        addc (1|M0)              r16.0<1>:ud   r5.6<0;1,0>:ud    r4.5<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r4.6<1>:d     r4.3<0;1,0>:d     r4.4<0;1,0>:d    {I@2}
        mov (1|M0)               r17.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r18.0<1>:f    r16.0<0;1,0>:f                   {Compacted,I@3}
        add3 (1|M0)              r18.1<1>:d    r17.0<0;0>:d      r5.7<0;0>:d       r4.6<0>:d        {I@1}
        send.ugm (1|M0)          r19      r18     null:0  0x0            0x0220C780           {A@1,$5} // wr:1+0, rd:2; load.ugm.d64x8t.a64
        mov (8|M0)               r24.0<1>:f    r19.0<1;1,0>:hf                  {$5.dst}
        mov (8|M0)               r25.0<1>:f    r19.8<1;1,0>:hf                 
        mov (8|M0)               r26.0<1>:f    r20.0<1;1,0>:hf                 
        mov (8|M0)               r27.0<1>:f    r20.8<1;1,0>:hf                 
        goto (32|M0)                         L1448                  L1592                
L1448:
        join (32|M0)                         L1592                                
L1464:
        shl (1|M0)               r6.5<1>:d     r4.1<0;1,0>:d     2:w              
        shl (1|M0)               r4.7<1>:d     r4.2<0;1,0>:d     2:w              
        shr (1|M0)               r6.4<1>:ud    r4.1<0;1,0>:ud    0x1E:uw             
        addc (1|M0)              r21.0<1>:ud   r6.0<0;1,0>:ud    r6.5<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r6.6<1>:d     r4.7<0;1,0>:d     r6.4<0;1,0>:d    {I@2}
        mov (1|M0)               r22.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r23.0<1>:f    r21.0<0;1,0>:f                   {Compacted,I@3}
        add3 (1|M0)              r23.1<1>:d    r22.0<0;0>:d      r6.1<0;0>:d       r6.6<0>:d        {I@1}
        send.ugm (1|M0)          r24      r23     null:0  0x0            0x0240D780           {A@1,$3} // wr:1+0, rd:4; load.ugm.d64x16t.a64
L1592:
        join (32|M0)                         L2000                                
L1608:
        sel (16|M0)   (lt)f0.0   r42.0<1>:f    (abs)r24.0<1;1,0>:f  448.0:f            {Compacted,$3.dst}
        sel (16|M0)   (lt)f0.0   r44.0<1>:f    (abs)r26.0<1;1,0>:f  448.0:f            {Compacted}
        shr (16|M0)              r28.0<1>:ud   r42.0<1;1,0>:ud   0x17:uw              {F@2}
        shr (16|M0)              r30.0<1>:ud   r44.0<1;1,0>:ud   0x17:uw              {F@1}
        sel (16|M0)   (ge)f0.0   r32.0<2>:ub   r28.0<4;1,0>:ub   0x79:uw              {I@2}
        sel (16|M0)   (ge)f0.0   r33.0<2>:ub   r30.0<4;1,0>:ub   0x79:uw              {I@2}
        mov (16|M0)              r38.0<1>:d    r32.0<2;1,0>:ub                  {I@2}
        mov (16|M0)              r40.0<1>:d    r33.0<2;1,0>:ub                  {I@2}
        shl (16|M0)              r38.0<1>:d    r38.0<1;1,0>:d    23:w               {Compacted,I@2}
        shl (16|M0)              r40.0<1>:d    r40.0<1;1,0>:d    23:w               {Compacted,I@2}
        add (16|M0)              r34.0<1>:d    r38.0<1;1,0>:d    -25165824:d               {I@2}
        add (16|M0)              r36.0<1>:d    r40.0<1;1,0>:d    -25165824:d               {I@2}
        add (16|M0)              r38.0<1>:d    -r38.0<1;1,0>:d   -2139095040:d              
        add (16|M0)              r40.0<1>:d    -r40.0<1;1,0>:d   -2139095040:d              
        mul (16|M0)              acc0.0<1>:f   r42.0<1;1,0>:f    r38.0<1;1,0>:f   {Compacted,I@2}
        mul (16|M0)              acc2.0<1>:f   r44.0<1;1,0>:f    r40.0<1;1,0>:f   {Compacted,I@1}
        rnde (16|M0)             acc0.0<1>:f   acc0.0<1;1,0>:f                 
        rnde (16|M0)             acc2.0<1>:f   acc2.0<1;1,0>:f                 
        cmp (16|M0)   (lt)f1.0   null<1>:f     r24.0<1;1,0>:f    0.0:f               {Compacted}
        cmp (16|M0)   (lt)f0.1   null<1>:f     r26.0<1;1,0>:f    0.0:f              
        mul (16|M0)              acc0.0<1>:f   acc0.0<1;1,0>:f   r34.0<1;1,0>:f   {Compacted}
        mul (16|M0)              acc2.0<1>:f   acc2.0<1;1,0>:f   r36.0<1;1,0>:f   {Compacted}
        mov (16|M0)              r46.0<1>:f    (abs)acc0.0<1;1,0>:f             {Compacted}
        mov (16|M0)              r48.0<1>:f    (abs)acc2.0<1;1,0>:f             {Compacted}
(f1.0)  or (16|M0)               r46.0<1>:d    r46.0<1;1,0>:d    -2147483648:d               {F@2}
(f0.1)  or (16|M0)               r48.0<1>:d    r48.0<1;1,0>:d    -2147483648:d               {F@1}
        mov (8|M0)               r50.0<1>:hf   r46.0<1;1,0>:f                   {I@2}
        mov (8|M0)               r50.8<1>:hf   r47.0<1;1,0>:f                  
        mov (8|M0)               r51.0<1>:hf   r48.0<1;1,0>:f                   {I@1}
        mov (8|M0)               r51.8<1>:hf   r49.0<1;1,0>:f                  
L2000:
        join (32|M0)                         L2440                                
L2016:
        shl (1|M0)               r9.2<1>:d     r1.6<0;1,0>:d     5:w              
(W)     mov (1|M0)               r16.14<1>:hf  0x1:hf                             
        shl (1|M0)               r9.6<1>:d     r9.2<0;1,0>:d     1:w               {I@1}
        shl (1|M0)               r6.7<1>:d     r1.7<0;1,0>:d     5:w              
        addc (1|M0)              r52.0<1>:ud   r6.2<0;1,0>:ud    r9.6<0;1,0>:ud   {AccWrEn,I@2}
        shr (1|M0)               r9.1<1>:ud    r1.6<0;1,0>:ud    0x1B:uw             
        mov (1|M0)               r53.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r55.0<1>:ud   r1.6<0;1,0>:ud    r1.4<0;1,0>:ud   {AccWrEn}
        or (1|M0)                r9.3<1>:d     r6.7<0;1,0>:d     r9.1<0;1,0>:d    {I@3}
        mov (1|M0)               r14.2<1>:d    r55.0<0;1,0>:d                   {I@2}
        mov (1|M0)               r56.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        cmp (1|M0)    (lt)f1.1   null<1>:ud    r14.2<0;1,0>:ud   r3.0<0;1,0>:ud   {I@2}
        add3 (1|M0)              r14.3<1>:d    r56.0<0;0>:d      r1.7<0;0>:d       r1.5<0>:d        {I@2}
        shr (1|M0)               r9.5<1>:ud    r9.2<0;1,0>:ud    0x1F:uw             
        cmp (1|M0)    (lt)f0.0   null<1>:ud    r14.3<0;1,0>:ud   r3.1<0;1,0>:ud   {I@2}
(f1.1)  cmp (1|M0)    (eq)f1.1   null<1>:d     r14.3<0;1,0>:d    r3.1<0;1,0>:d   
        shl (1|M0)               r9.4<1>:d     r9.3<0;1,0>:d     1:w              
        mov (1|M0)               r54.0<1>:f    r52.0<0;1,0>:f                   {Compacted}
(f0.0)  sel (1|M0)               r16.7<1>:uw   r16.14<0;1,0>:uw  0x0:uw              {F@2}
(f1.1)  sel (1|M0)               r16.6<1>:uw   r16.14<0;1,0>:uw  0x0:uw             
        or (1|M0)                r9.7<1>:d     r9.4<0;1,0>:d     r9.5<0;1,0>:d    {I@3}
        or (1|M0)     (ne)f0.0   null<1>:uw    r16.6<0;1,0>:uw   r16.7<0;1,0>:uw  {I@2}
        add3 (1|M0)              r54.1<1>:d    r53.0<0;0>:d      r6.3<0;0>:d       r9.7<0>:d        {I@2}
        send.ugm (1|M0)          null     r54     r50:2   0x0            0x0200C784           {A@1,$4} // wr:1+2, rd:0; store.ugm.d64x8t.a64
(W)     and (1|M0)               f0.0<1>:ud    f0.0<0;1,0>:uw    0x1:uw             
(~f0.0.any32h) goto (32|M0)                  L2440                  L2440                
L2408:
(W)     mov (2|M0)               r1.6<1>:ud    r14.2<1;1,0>:ud                 
        goto.b (32|M0)                       L2440                  L584                
L2440:
        join (32|M0)                         L2456                                
L2456:
(W)     mov (8|M0)               r127.0<1>:f   r0.0<1;1,0>:f                    {Compacted,$2.src}
(W)     send.ugm (1|M0)          r59      r0      null:0  0x0            0x0210641F           {$6} // wr:1+0, rd:1; fence invalid flush type scoped to tile
(W)     mov (8|M0)               null<1>:ud    r59.0<1;1,0>:ud                  {$6.dst}
(W)     send.gtwy (1|M0)         null     r127    null:0  0x0            0x02000010           {EOT,A@1} // wr:1+0, rd:0; end of thread
L2512:
        mov (1|M0)               r14.4<1>:d    cr0.0<0;1,0>:ud                  {A@1}
        and (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   -1265:w               {A@1}
        or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   1264:w               {A@1}
        mov (1|M0)               r14.5<1>:f    r14.1<0;1,0>:ud                  {A@1}
        mov (1|M0)               r15.1<1>:f    0xB4C00000:f                               {Compacted}
        math.inv (1|M0)          r15.4<1>:f    r14.5<0;1,0>:f                   {@2,$7}
        mov (1|M0)               r16.5<1>:f    r17.5<0;1,0>:ud                 
        sync.nop                             null                             {Compacted,$7.dst}
        mad (1|M0)               r15.4<1>:f    r15.4<0;0>:f      r15.1<0;0>:f      r15.4<0>:f       {F@2}
        mov (1|M0)               r17.4<1>:ud   r14.5<0;1,0>:f                  
        mov (1|M0)               r14.6<1>:ud   r16.5<0;1,0>:f                   {F@2}
        mul (1|M0)               r15.2<1>:f    r15.4<0;1,0>:f    r16.5<0;1,0>:f   {F@1}
        add (1|M0)               r17.4<1>:ud   r14.1<0;1,0>:ud   -r17.4<0;1,0>:ud {I@2}
        add (1|M0)               r14.6<1>:ud   r17.5<0;1,0>:ud   -r14.6<0;1,0>:ud {I@2}
        mov (1|M0)               r15.6<1>:ud   r15.2<0;1,0>:f                   {F@1}
        mov (1|M0)               r16.4<1>:f    r17.4<0;1,0>:ud                  {I@3}
        mov (1|M0)               r14.7<1>:f    r14.6<0;1,0>:ud                  {I@2}
        mov (1|M0)               r15.3<1>:f    r15.6<0;1,0>:ud                  {I@1}
(W)     mov (1|M0)               r17.2<1>:hf   0x1:hf                             
        mad (1|M0)               r16.5<1>:f    r16.5<0;0>:f      r15.3<0;0>:f      -r14.5<0>:f      {F@2}
        mad (1|M0)               r15.3<1>:f    r14.7<0;0>:f      r15.3<0;0>:f      -r16.4<0>:f     
        add (1|M0)               r16.5<1>:f    r16.5<0;1,0>:f    r15.3<0;1,0>:f   {F@1}
        mul (1|M0)               r15.4<1>:f    r15.4<0;1,0>:f    r16.5<0;1,0>:f   {F@1}
        mov (1|M0)               r15.5<1>:ud   r15.4<0;1,0>:f                   {F@1}
        add (1|M0)               r15.6<1>:ud   r15.6<0;1,0>:ud   r15.5<0;1,0>:ud  {I@1}
(W)     mul (1|M0)               acc0.0<1>:ud  r15.6<0;1,0>:ud   r14.2<0;1,0>:uw  {I@1}
        mach (1|M0)              r58.0<1>:ud   r15.6<0;1,0>:ud   r14.1<0;1,0>:ud 
        add (1|M0)               r17.5<1>:ud   r17.5<0;1,0>:ud   -r58.0<0;1,0>:ud {I@1}
        cmp (1|M0)    (ge)f1.0   null<1>:ud    r17.5<0;1,0>:ud   r14.1<0;1,0>:ud  {I@1}
(f1.0)  sel (1|M0)               r15.7<1>:d    r17.2<0;1,0>:w    0:w              
        add (1|M0)               r57.0<1>:ud   r15.6<0;1,0>:ud   r15.7<0;1,0>:ud  {I@1}
        mov (1|M0)               cr0.0<1>:ud   r14.4<0;1,0>:d                   {A@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        ret (32|M0)                          r17.2                            {A@1}
L3056:
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
