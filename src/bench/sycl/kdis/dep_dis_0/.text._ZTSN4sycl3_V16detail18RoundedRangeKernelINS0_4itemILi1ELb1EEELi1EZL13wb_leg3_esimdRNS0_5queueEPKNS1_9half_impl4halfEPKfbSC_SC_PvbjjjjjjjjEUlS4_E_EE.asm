L0:
(W)     mov (8|M0)               r127.0<1>:ud  0x0:ud                              {A@1}
(W)     and (1|M0)               r127.2<1>:ud  r0.0<0;1,0>:ud    0xFFFFFFC0:ud             
(W)     and (1|M0)               r127.0<1>:uw  r0.4<0;1,0>:uw    0xFF:uw             
(W)     add (1|M0)               r127.2<1>:ud  r127.2<0;1,0>:ud  0xC0:ud              {I@2}
(W)     mad (1|M0)               r127.2<1>:ud  r127.2<0;0>:ud    r127.0<0;0>:uw    0x20:uw              {I@1}
(W)     send.dc0 (8|M0)          r1       r127    null:0  0x0            0x021842FD           {A@1,$0} // wr:1h+0, rd:1; oword aligned block read x2
        nop                    
        nop                    
(W)     mov (8|M0)               r127.0<1>:ud  0x0:ud                              {$0.src}
(W)     and (1|M0)               r127.2<1>:ud  r0.0<0;1,0>:ud    0xFFFFFFC0:ud             
(W)     send.dc0 (8|M0)          r2       r127    null:0  0x0            0x024844FD           {A@1,$1} // wr:1h+0, rd:4; oword aligned block read x8
(W)     add (1|M0)               r127.2<1>:ud  r127.2<0;1,0>:ud  0x80:uw              {$1.src}
(W)     send.dc0 (8|M0)          r6       r127    null:0  0x0            0x022843FD           {A@1,$2} // wr:1h+0, rd:2; oword aligned block read x4
(W)     mov (2|M0)               r30.0<1>:ud   r6.6<1;1,0>:ud                   {$2.dst}
        and (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   -1265:w               {A@1}
        or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   1216:w               {A@1}
        sync.nop                             null                             {Compacted,A@1}
        sync.nop                             null                             {Compacted,$1.dst}
        mul (1|M0)               acc0.0<1>:ud  r2.3<0;1,0>:ud    r0.2<0;1,0>:uw   {A@1}
        mach (1|M0)              r9.0<1>:ud    r2.3<0;1,0>:ud    r0.1<0;1,0>:ud   {AccWrEn}
        mov (1|M0)               r1.2<1>:d     r1.0<0;1,0>:uw                   {$0.dst}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
(W)     mov (1|M0)               r14.0<1>:hf   0x1:hf                             
        addc (1|M0)              r10.0<1>:ud   r8.0<0;1,0>:ud    r1.2<0;1,0>:ud   {AccWrEn,I@1}
        mov (1|M0)               r30.6<1>:d    r10.0<0;1,0>:d                   {I@1}
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        cmp (1|M0)    (lt)f0.0   null<1>:ud    r30.6<0;1,0>:ud   r3.0<0;1,0>:ud   {I@2}
        add3 (1|M0)              r30.7<1>:d    r11.0<0;0>:d      r9.0<0;0>:d       0:w               {I@2}
        mul (1|M0)               acc0.0<1>:ud  r2.0<0;1,0>:ud    r2.6<0;1,0>:uw  
        cmp (1|M0)    (lt)f0.1   null<1>:ud    r30.7<0;1,0>:ud   r3.1<0;1,0>:ud   {I@2}
(f0.0)  cmp (1|M0)    (eq)f0.0   null<1>:d     r30.7<0;1,0>:d    r3.1<0;1,0>:d   
        mach (1|M0)              r13.0<1>:ud   r2.0<0;1,0>:ud    r2.3<0;1,0>:ud   {AccWrEn}
(f0.1)  sel (1|M0)               r16.0<1>:uw   r14.0<0;1,0>:uw   0x0:uw              {F@1}
(f0.0)  sel (1|M0)               r15.0<1>:uw   r14.0<0;1,0>:uw   0x0:uw             
        mov (1|M0)               r12.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        or (1|M0)     (ne)f0.1   null<1>:uw    r15.0<0;1,0>:uw   r16.0<0;1,0>:uw  {I@2}
        mov (1|M0)               r30.3<1>:d    r13.0<0;1,0>:d                  
        mov (1|M0)               r30.2<1>:d    r12.0<0;1,0>:d                   {I@3}
(W)     and (1|M0)               f1.1<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(~f1.1.any16h) goto (16|M0)                  L3072                  L3072                
L600:
        mov (1|M0)               r30.4<1>:d    r5.5<0;1,0>:d                   
        mov (1|M0)               r30.5<1>:d    0:w                              
L632:
        shr (1|M0)               r31.0<1>:ud   r30.6<0;1,0>:ud   0x6:uw             
        mov (1|M0)               r31.6<1>:d    r5.0<0;1,0>:d                   
        mov (1|M0)               r40.5<1>:d    r31.0<0;1,0>:d                   {I@2}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r40.2         L3144                                 {A@1}
L728:
        shl (1|M0)               r31.1<1>:d    r40.0<0;1,0>:d    3:w               {Compacted}
        shr (1|M0)               r1.2<1>:ud    r30.6<0;1,0>:ud   0x3:uw             
(W)     mul (1|M0)               acc0.0<1>:d   r40.0<0;1,0>:d    r5.0<0;1,0>:uw   {Compacted}
        bfn.0xEA (1|M0)          r31.1<1>:ud   r31.1<0;0>:ud     r1.2<0;0>:ud      0x7:uw              {I@2} // s0|s1&s2
(W)     mov (1|M0)               r2.12<1>:hf   0x1:hf                             
        cmp (1|M0)    (lt)f0.1   null<1>:ud    r31.1<0;1,0>:ud   r5.1<0;1,0>:ud   {I@1}
        mach (1|M0)              r40.0<1>:d    r40.0<0;1,0>:d    r5.0<0;1,0>:d    {Compacted}
        add (1|M0)               r31.0<1>:d    r31.0<0;1,0>:d    -r40.0<0;1,0>:d  {Compacted,I@1}
(f0.1)  sel (1|M0)               r3.4<1>:uw    r2.12<0;1,0>:uw   0x0:uw              {F@1}
        shl (1|M0)               r31.0<1>:d    r31.0<0;1,0>:d    3:w               {Compacted,I@2}
        xor (1|M0)    (ne)f1.1   null<1>:uw    r3.4<0;1,0>:uw    0x1:uw              {I@2}
        bfn.0xEA (1|M0)          r31.0<1>:ud   r31.0<0;0>:ud     r30.6<0;0>:ud     0x7:uw              {I@2} // s0|s1&s2
(f0.1)  sel (1|M0)               r4.0<1>:uw    r2.12<0;1,0>:uw   0x0:uw             
(f1.1)  cmp (1|M0)    (lt)f1.1   null<1>:ud    r31.0<0;1,0>:ud   r5.2<0;1,0>:ud   {I@2}
(f1.1)  sel (1|M0)               r6.1<1>:uw    r2.12<0;1,0>:uw   0x0:uw             
        or (1|M0)     (ne)f0.0   null<1>:uw    r4.0<0;1,0>:uw    r6.1<0;1,0>:uw   {I@1}
(W)     and (1|M0)               f1.0<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
(f1.0.any16h) goto (16|M0)                   L2808                  L2808                
L976:
        add (1|M0)               r31.1<1>:ud   r31.1<0;1,0>:ud   -r5.1<0;1,0>:ud 
        cmp (1|M0)    (lt)f1.1   null<1>:ud    r31.1<0;1,0>:ud   r5.3<0;1,0>:ud   {I@1}
(W)     and (1|M0)               f0.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(~f0.1.any16h) goto (16|M0)                  L2808                  L2808                
L1040:
        add (1|M0)               r31.0<1>:ud   r31.0<0;1,0>:ud   -r5.2<0;1,0>:ud  {Compacted}
        cmp (1|M0)    (lt)f1.0   null<1>:ud    r31.0<0;1,0>:ud   r5.4<0;1,0>:ud   {I@1}
(W)     and (1|M0)               f0.0<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
(~f0.0.any16h) goto (16|M0)                  L2808                  L2808                
L1096:
        mul (1|M0)               acc0.0<1>:ud  r31.1<0;1,0>:ud   r5.8<0;1,0>:uw  
        mach (1|M0)              r9.0<1>:ud    r31.1<0;1,0>:ud   r5.4<0;1,0>:ud   {AccWrEn}
        cmp (1|M0)    (eq)f0.1   null<1>:w     r6.0<0;1,0>:b     0:w              
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r10.0<1>:ud   r8.0<0;1,0>:ud    r31.0<0;1,0>:ud  {AccWrEn,I@1}
(W)     and (1|M0)               f1.1<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
        mov (1|M0)               r12.0<1>:f    r10.0<0;1,0>:f                   {Compacted,I@2}
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mul (1|M0)               acc0.0<1>:ud  r12.0<0;1,0>:ud   r30.8<0;1,0>:uw  {F@1}
        mach (1|M0)              r14.0<1>:ud   r12.0<0;1,0>:ud   r30.4<0;1,0>:ud  {AccWrEn}
        add3 (1|M0)              r12.1<1>:d    r11.0<0;0>:d      r9.0<0;0>:d       0:w               {I@3}
        mov (1|M0)               r13.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r12.0<0;1,0>:d    r30.10<0;1,0>:uw {Compacted}
        mach (1|M0)              r15.0<1>:d    r12.0<0;1,0>:d    r30.5<0;1,0>:d   {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r12.1<0;1,0>:d    r30.8<0;1,0>:uw  {I@4}
        mach (1|M0)              r16.0<1>:d    r12.1<0;1,0>:d    r30.4<0;1,0>:d  
        mul (1|M0)               acc0.0<1>:ud  r30.6<0;1,0>:ud   r30.8<0;1,0>:uw 
        mach (1|M0)              r18.0<1>:ud   r30.6<0;1,0>:ud   r30.4<0;1,0>:ud  {AccWrEn}
        mov (1|M0)               r31.2<1>:d    r13.0<0;1,0>:d                   {I@7}
        mov (1|M0)               r17.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r30.6<0;1,0>:d    r30.10<0;1,0>:uw
        mach (1|M0)              r19.0<1>:d    r30.6<0;1,0>:d    r30.5<0;1,0>:d  
(W)     mul (1|M0)               acc0.0<1>:d   r30.7<0;1,0>:d    r30.8<0;1,0>:uw 
        mach (1|M0)              r20.0<1>:d    r30.7<0;1,0>:d    r30.4<0;1,0>:d  
        shl (1|M0)               r24.0<1>:d    r17.0<0;1,0>:d    2:w               {Compacted,I@5}
        add3 (1|M0)              r21.1<1>:d    r20.0<0;0>:d      r18.0<0;0>:d      r19.0<0>:d       {I@2}
        shr (1|M0)               r23.0<1>:ud   r17.0<0;1,0>:ud   0x1E:uw             
        addc (1|M0)              r25.0<1>:ud   r5.6<0;1,0>:ud    r24.0<0;1,0>:ud  {AccWrEn,I@3}
        shl (1|M0)               r22.0<1>:d    r21.1<0;1,0>:d    2:w               {Compacted,I@3}
        mov (1|M0)               r26.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        or (1|M0)                r24.1<1>:d    r22.0<0;1,0>:d    r23.0<0;1,0>:d   {Compacted,I@2}
        mov (1|M0)               r27.0<1>:f    r25.0<0;1,0>:f                   {Compacted}
        add3 (1|M0)              r27.1<1>:d    r26.0<0;0>:d      r5.7<0;0>:d       r24.1<0>:d       {I@1}
        add3 (1|M0)              r31.3<1>:d    r16.0<0;0>:d      r14.0<0;0>:d      r15.0<0>:d      
        send.ugm (1|M0)          r36      r27     null:0  0x0            0x0240D780           {A@1,$3} // wr:1+0, rd:4; load.ugm.d64x16t.a64
(f1.1.any16h) goto (16|M0)                   L1784                  L1784                
L1576:
        shl (1|M0)               r3.2<1>:d     r31.2<0;1,0>:d    1:w              
        shl (1|M0)               r1.2<1>:d     r31.3<0;1,0>:d    1:w               {I@3}
        shr (1|M0)               r2.6<1>:ud    r31.2<0;1,0>:ud   0x1F:uw             
        addc (1|M0)              r4.0<1>:ud    r6.2<0;1,0>:ud    r3.2<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r3.3<1>:d     r1.2<0;1,0>:d     r2.6<0;1,0>:d    {I@2}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r9.0<1>:f     r4.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r9.1<1>:d     r8.0<0;0>:d       r6.3<0;0>:d       r3.3<0>:d        {I@1}
        send.ugm (1|M0)          r10      r9      null:0  0x0            0x0220C780           {A@1,$4} // wr:1+0, rd:2; load.ugm.d64x8t.a64
        mov (8|M0)               r32.0<1>:f    r10.0<1;1,0>:hf                  {$4.dst}
        mov (8|M0)               r33.0<1>:f    r10.8<1;1,0>:hf                 
        mov (8|M0)               r34.0<1>:f    r11.0<1;1,0>:hf                 
        mov (8|M0)               r35.0<1>:f    r11.8<1;1,0>:hf                 
        goto (16|M0)                         L1784                  L1928                
L1784:
        join (16|M0)                         L1928                                
L1800:
        shl (1|M0)               r3.2<1>:d     r31.2<0;1,0>:d    2:w              
        shl (1|M0)               r1.2<1>:d     r31.3<0;1,0>:d    2:w              
        shr (1|M0)               r2.6<1>:ud    r31.2<0;1,0>:ud   0x1E:uw             
        addc (1|M0)              r4.0<1>:ud    r6.4<0;1,0>:ud    r3.2<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r3.3<1>:d     r1.2<0;1,0>:d     r2.6<0;1,0>:d    {I@2}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r9.0<1>:f     r4.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r9.1<1>:d     r8.0<0;0>:d       r6.5<0;0>:d       r3.3<0>:d        {I@1}
        send.ugm (1|M0)          r32      r9      null:0  0x0            0x0240D780           {A@1,$5} // wr:1+0, rd:4; load.ugm.d64x16t.a64
L1928:
        join (16|M0)                         L2808                                
L1944:
        send.ugm (1|M0)          r8       r30     null:0  0x0            0x0240D780           {$6} // wr:1+0, rd:4; load.ugm.d64x16t.a64
        cmp (1|M0)    (eq)f0.0   null<1>:d     r7.0<0;1,0>:d     1:w              
(W)     and (1|M0)               f1.0<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
        sync.allwr                           ($5,$6)                
        mad (16|M0)              r36.0<1>:f    r36.0<1;0>:f      r8.0<1;0>:f       r32.0<1>:f       {Compacted,$3.dst}
        mad (16|M0)              r38.0<1>:f    r38.0<1;0>:f      r10.0<1;0>:f      r34.0<1>:f       {Compacted}
(~f1.0.any16h) goto (16|M0)                  L2384                  L2384                
L2040:
        sel (16|M0)   (lt)f0.0   r8.0<1>:f     (abs)r36.0<1;1,0>:f  448.0:f            {Compacted,F@2}
        sel (16|M0)   (lt)f0.0   r10.0<1>:f    (abs)r38.0<1;1,0>:f  448.0:f            {Compacted,F@2}
        shr (16|M0)              r12.0<1>:ud   r8.0<1;1,0>:ud    0x17:uw              {F@2}
        shr (16|M0)              r14.0<1>:ud   r10.0<1;1,0>:ud   0x17:uw              {F@1}
        sel (16|M0)   (ge)f0.0   r16.0<2>:ub   r12.0<4;1,0>:ub   0x79:uw              {I@2}
        sel (16|M0)   (ge)f0.0   r17.0<2>:ub   r14.0<4;1,0>:ub   0x79:uw              {I@2}
        mov (16|M0)              r18.0<1>:d    r16.0<2;1,0>:ub                  {I@2}
        mov (16|M0)              r20.0<1>:d    r17.0<2;1,0>:ub                  {I@2}
        shl (16|M0)              r18.0<1>:d    r18.0<1;1,0>:d    23:w               {Compacted,I@2}
        shl (16|M0)              r20.0<1>:d    r20.0<1;1,0>:d    23:w               {Compacted,I@2}
        add (16|M0)              r22.0<1>:d    r18.0<1;1,0>:d    -25165824:d               {I@2}
        add (16|M0)              r24.0<1>:d    r20.0<1;1,0>:d    -25165824:d               {I@2}
        add (16|M0)              r18.0<1>:d    -r18.0<1;1,0>:d   -2139095040:d              
        add (16|M0)              r20.0<1>:d    -r20.0<1;1,0>:d   -2139095040:d              
        mul (16|M0)              acc0.0<1>:f   r8.0<1;1,0>:f     r18.0<1;1,0>:f   {Compacted,I@2}
        mul (16|M0)              acc2.0<1>:f   r10.0<1;1,0>:f    r20.0<1;1,0>:f   {Compacted,I@1}
        rnde (16|M0)             acc0.0<1>:f   acc0.0<1;1,0>:f                 
        rnde (16|M0)             acc2.0<1>:f   acc2.0<1;1,0>:f                 
        cmp (16|M0)   (lt)f1.1   null<1>:f     r36.0<1;1,0>:f    0.0:f              
        cmp (16|M0)   (lt)f1.0   null<1>:f     r38.0<1;1,0>:f    0.0:f               {Compacted}
        mul (16|M0)              acc0.0<1>:f   acc0.0<1;1,0>:f   r22.0<1;1,0>:f   {Compacted}
        mul (16|M0)              acc2.0<1>:f   acc2.0<1;1,0>:f   r24.0<1;1,0>:f   {Compacted}
        mov (16|M0)              r26.0<1>:f    (abs)acc0.0<1;1,0>:f             {Compacted}
        mov (16|M0)              r28.0<1>:f    (abs)acc2.0<1;1,0>:f             {Compacted}
(f1.1)  or (16|M0)               r26.0<1>:d    r26.0<1;1,0>:d    -2147483648:d               {F@2}
(f1.0)  or (16|M0)               r28.0<1>:d    r28.0<1;1,0>:d    -2147483648:d               {F@1}
        mov (16|M0)              r36.0<1>:f    r26.0<1;1,0>:f                   {Compacted,I@2}
        mov (16|M0)              r38.0<1>:f    r28.0<1;1,0>:f                   {Compacted,I@1}
L2384:
        join (16|M0)                         L2808                                
L2400:
        cmp (1|M0)    (eq)f0.1   null<1>:w     r7.4<0;1,0>:b     0:w              
(W)     and (1|M0)               f0.1<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(f0.1.any16h) goto (16|M0)                   L2656                  L2656                
L2448:
        shl (1|M0)               r3.2<1>:d     r31.2<0;1,0>:d    1:w              
        shl (1|M0)               r1.2<1>:d     r31.3<0;1,0>:d    1:w              
        shr (1|M0)               r2.6<1>:ud    r31.2<0;1,0>:ud   0x1F:uw             
        addc (1|M0)              r4.0<1>:ud    r7.2<0;1,0>:ud    r3.2<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r3.3<1>:d     r1.2<0;1,0>:d     r2.6<0;1,0>:d    {I@2}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (8|M0)               r10.0<1>:hf   r36.0<1;1,0>:f                   {F@2}
        mov (8|M0)               r10.8<1>:hf   r37.0<1;1,0>:f                  
        mov (8|M0)               r11.0<1>:hf   r38.0<1;1,0>:f                   {F@3}
        mov (8|M0)               r11.8<1>:hf   r39.0<1;1,0>:f                  
        mov (1|M0)               r9.0<1>:f     r4.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r9.1<1>:d     r8.0<0;0>:d       r7.3<0;0>:d       r3.3<0>:d        {I@1}
        send.ugm (1|M0)          null     r9      r10:2   0x0            0x0200C784           {A@1,$7} // wr:1+2, rd:0; store.ugm.d64x8t.a64
        goto (16|M0)                         L2656                  L2808                
L2656:
        join (16|M0)                         L2808                                
L2672:
        shl (1|M0)               r3.2<1>:d     r31.2<0;1,0>:d    2:w              
        shl (1|M0)               r1.2<1>:d     r31.3<0;1,0>:d    2:w              
        shr (1|M0)               r2.6<1>:ud    r31.2<0;1,0>:ud   0x1E:uw             
        addc (1|M0)              r4.0<1>:ud    r7.2<0;1,0>:ud    r3.2<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r3.3<1>:d     r1.2<0;1,0>:d     r2.6<0;1,0>:d    {I@2}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        sync.nop                             null                             {Compacted,$7.src}
        mov (1|M0)               r9.0<1>:f     r4.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r9.1<1>:d     r8.0<0;0>:d       r7.3<0;0>:d       r3.3<0>:d        {I@1}
        send.ugm (1|M0)          null     r9      r36:4   0x0            0x0200D784           {A@1,$8} // wr:1+4, rd:0; store.ugm.d64x16t.a64
L2808:
        join (16|M0)                         L3072                                
L2824:
        addc (1|M0)              r4.0<1>:ud    r30.6<0;1,0>:ud   r30.2<0;1,0>:ud  {AccWrEn}
        sync.allrd                           ($7,$8)                
(W)     mov (1|M0)               r9.0<1>:hf    0x1:hf                              {$5.src}
        mov (1|M0)               r31.4<1>:d    r4.0<0;1,0>:d                    {I@1}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        cmp (1|M0)    (lt)f1.0   null<1>:ud    r31.4<0;1,0>:ud   r3.0<0;1,0>:ud   {I@2}
        add3 (1|M0)              r31.5<1>:d    r8.0<0;0>:d       r30.7<0;0>:d      r30.3<0>:d       {I@2}
        cmp (1|M0)    (lt)f1.1   null<1>:ud    r31.5<0;1,0>:ud   r3.1<0;1,0>:ud   {I@1}
(f1.0)  cmp (1|M0)    (eq)f1.0   null<1>:d     r31.5<0;1,0>:d    r3.1<0;1,0>:d   
(f1.1)  sel (1|M0)               r11.0<1>:uw   r9.0<0;1,0>:uw    0x0:uw              {F@1}
(f1.0)  sel (1|M0)               r10.0<1>:uw   r9.0<0;1,0>:uw    0x0:uw             
        or (1|M0)     (ne)f0.0   null<1>:uw    r10.0<0;1,0>:uw   r11.0<0;1,0>:uw  {I@1}
(W)     and (1|M0)               f0.0<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
(~f0.0.any16h) goto (16|M0)                  L3072                  L3072                
L3040:
(W)     mov (2|M0)               r30.6<1>:ud   r31.4<1;1,0>:ud                 
        goto.b (16|M0)                       L3072                  L632                
L3072:
        join (16|M0)                         L3088                                
L3088:
(W)     mov (8|M0)               r127.0<1>:f   r0.0<1;1,0>:f                    {Compacted}
(W)     send.ugm (1|M0)          r4       r0      null:0  0x0            0x0210641F           {$9} // wr:1+0, rd:1; fence invalid flush type scoped to tile
(W)     mov (8|M0)               null<1>:ud    r4.0<1;1,0>:ud                   {$9.dst}
(W)     send.gtwy (1|M0)         null     r127    null:0  0x0            0x02000010           {EOT,A@1} // wr:1+0, rd:0; end of thread
L3144:
        mov (1|M0)               r1.2<1>:d     cr0.0<0;1,0>:ud                  {A@1}
        and (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   -1265:w               {A@1}
        or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   1264:w               {A@1}
        mov (1|M0)               r2.6<1>:f     r31.6<0;1,0>:ud                  {A@1}
        mov (1|M0)               r8.0<1>:f     0xB4C00000:f                               {Compacted}
        math.inv (1|M0)          r7.4<1>:f     r2.6<0;1,0>:f                    {@2,$10}
        mov (1|M0)               r3.5<1>:f     r40.5<0;1,0>:ud                 
        sync.nop                             null                             {Compacted,$10.dst}
        mad (1|M0)               r7.4<1>:f     r7.4<0;0>:f       r8.0<0;0>:f       r7.4<0>:f        {F@2}
        mov (1|M0)               r40.4<1>:ud   r2.6<0;1,0>:f                   
        mov (1|M0)               r4.0<1>:ud    r3.5<0;1,0>:f                    {F@2}
        mul (1|M0)               r9.0<1>:f     r7.4<0;1,0>:f     r3.5<0;1,0>:f    {F@1}
        add (1|M0)               r40.4<1>:ud   r31.6<0;1,0>:ud   -r40.4<0;1,0>:ud {I@2}
        add (1|M0)               r4.0<1>:ud    r40.5<0;1,0>:ud   -r4.0<0;1,0>:ud  {Compacted,I@2}
        mov (1|M0)               r10.0<1>:ud   r9.0<0;1,0>:f                    {F@1}
        mov (1|M0)               r3.4<1>:f     r40.4<0;1,0>:ud                  {I@3}
        mov (1|M0)               r6.1<1>:f     r4.0<0;1,0>:ud                   {Compacted,I@2}
        mov (1|M0)               r11.0<1>:f    r10.0<0;1,0>:ud                  {Compacted,I@1}
(W)     mov (1|M0)               r14.0<1>:hf   0x1:hf                             
        mad (1|M0)               r3.5<1>:f     r3.5<0;0>:f       r11.0<0;0>:f      -r2.6<0>:f       {F@2}
        mad (1|M0)               r11.0<1>:f    r6.1<0;0>:f       r11.0<0;0>:f      -r3.4<0>:f      
        add (1|M0)               r3.5<1>:f     r3.5<0;1,0>:f     r11.0<0;1,0>:f   {F@1}
        mul (1|M0)               r7.4<1>:f     r7.4<0;1,0>:f     r3.5<0;1,0>:f    {F@1}
        mov (1|M0)               r12.0<1>:ud   r7.4<0;1,0>:f                    {F@1}
        add (1|M0)               r10.0<1>:ud   r10.0<0;1,0>:ud   r12.0<0;1,0>:ud  {Compacted,I@1}
(W)     mul (1|M0)               acc0.0<1>:ud  r10.0<0;1,0>:ud   r31.12<0;1,0>:uw {I@1}
        mach (1|M0)              r13.0<1>:ud   r10.0<0;1,0>:ud   r31.6<0;1,0>:ud  {Compacted}
        add (1|M0)               r40.5<1>:ud   r40.5<0;1,0>:ud   -r13.0<0;1,0>:ud {I@1}
        cmp (1|M0)    (ge)f1.0   null<1>:ud    r40.5<0;1,0>:ud   r31.6<0;1,0>:ud  {I@1}
(f1.0)  sel (1|M0)               r15.0<1>:d    r14.0<0;1,0>:w    0:w              
        add (1|M0)               r40.0<1>:ud   r10.0<0;1,0>:ud   r15.0<0;1,0>:ud  {Compacted,I@1}
        mov (1|M0)               cr0.0<1>:ud   r1.2<0;1,0>:d                    {A@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        ret (16|M0)                          r40.2                            {A@1}
L3640:
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
