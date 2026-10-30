L0:
(W)     mov (8|M0)               r127.0<1>:ud  0x0:ud                             
(W)     and (1|M0)               r127.2<1>:ud  r0.0<0;1,0>:ud    0xFFFFFFC0:ud             
(W)     and (1|M0)               r127.0<1>:uw  r0.4<0;1,0>:uw    0xFF:uw             
(W)     add (1|M0)               r127.2<1>:ud  r127.2<0;1,0>:ud  0x60:ud              {I@2}
(W)     add (1|M0)               r127.2<1>:ud  r127.2<0;1,0>:ud  0x0:ud              {I@1}
(W)     mad (1|M0)               r127.2<1>:ud  r127.2<0;0>:ud    r127.0<0;0>:uw    0xC0:uw              {I@1}
(W)     mov (8|M0)               r7.0<1>:ud    r1.0<1;1,0>:ud                  
(W)     send.dc0 (8|M0)          r1       r127    null:0  0x0            0x024844FD           {A@1,$0} // wr:1h+0, rd:4; oword aligned block read x8
(W)     add (1|M0)               r127.2<1>:ud  r127.2<0;1,0>:ud  0x80:uw              {$0.src}
(W)     send.dc0 (8|M0)          r5       r127    null:0  0x0            0x022843FD           {A@1,$1} // wr:1h+0, rd:2; oword aligned block read x4
        nop                    
        nop                    
(W)     mov (8|M0)               r127.0<1>:ud  0x0:ud                              {$1.src}
(W)     and (1|M0)               r127.2<1>:ud  r0.0<0;1,0>:ud    0xFFFFFFC0:ud             
(W)     add (1|M0)               r127.2<1>:ud  r127.2<0;1,0>:ud  0x0:ud              {I@1}
(W)     send.dc0 (8|M0)          r8       r127    null:0  0x0            0x022843FD           {A@1,$2} // wr:1h+0, rd:2; oword aligned block read x4
(W)     add (1|M0)               r127.2<1>:ud  r127.2<0;1,0>:ud  0x40:uw              {$2.src}
(W)     send.dc0 (8|M0)          r10      r127    null:0  0x0            0x021842FD           {A@1,$3} // wr:1h+0, rd:1; oword aligned block read x2
(W)     mov (8|M0)               r46.0<1>:ud   r0.0<1;1,0>:ud                  
(W)     or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x4C0:uw              {A@1}
(W)     mul (1|M0)               acc0.0<1>:d   r7.3<0;1,0>:d     r46.2<0;1,0>:uw  {A@1}
(W)     cmp (16|M0)   (eq)f1.0   null<1>:d     r8.4<0;1,0>:d     0:w               {$2.dst}
(W)     cmp (16|M16)  (eq)f1.0   null<1>:d     r8.4<0;1,0>:d     0:w              
(W)     mach (1|M0)              r3.0<1>:d     r7.3<0;1,0>:d     r46.1<0;1,0>:d   {$0.dst}
        add3 (16|M0)             r52.0<1>:d    r3.0<0;0>:d       r1.0<1;0>:uw      r7.0<0>:d        {I@1}
        add3 (16|M16)            r50.0<1>:d    r3.0<0;0>:d       r2.0<1;0>:uw      r7.0<0>:d       
        shr (16|M0)              r56.0<1>:ud   r52.0<1;1,0>:ud   6:w               {I@2}
        shr (16|M16)             r54.0<1>:ud   r50.0<1;1,0>:ud   6:w               {I@2}
(~f1.0) goto (32|M0)                         L512                  L512                
L464:
        mov (16|M0)              r24.0<1>:d    -1:w                              
        mov (16|M16)             r48.0<1>:d    -1:w                              
        goto (32|M0)                         L512                  L1144                
L512:
        join (32|M0)                         L1144                                
L528:
(W)     xor (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x30:uw              {A@1}
(W)     mov (1|M0)               r3.0<1>:f     r8.4<0;1,0>:ud                   {Compacted,A@1}
(W)     mov (1|M0)               r4.2<1>:f     0xB4C00000:f                               {Compacted}
(W)     math.inv (1|M0)          r4.1<1>:f     r3.0<0;1,0>:f                    {@2,$4}
        mov (16|M0)              r12.0<1>:f    r56.0<1;1,0>:ud                  {Compacted,I@7}
        sync.allwr                           ($1,$4)                
(W)     mad (1|M0)               r5.0<1>:f     r4.1<0;0>:f       r4.2<0;0>:f       r4.1<0>:f        {F@2}
        mov (16|M16)             r14.0<1>:f    r54.0<1;1,0>:ud                  {Compacted,I@7}
(W)     mov (1|M0)               r3.1<1>:ud    r3.0<0;1,0>:f                   
        mov (16|M0)              r20.0<1>:ud   r12.0<1;1,0>:f                   {F@3}
        mul (16|M0)              r16.0<1>:f    r12.0<1;1,0>:f    r5.0<0;1,0>:f    {Compacted,F@2}
        mul (16|M16)             r18.0<1>:f    r14.0<1;1,0>:f    r5.0<0;1,0>:f    {Compacted,F@2}
        mov (16|M16)             r22.0<1>:ud   r14.0<1;1,0>:f                  
(W)     add (1|M0)               r4.0<1>:d     r8.4<0;1,0>:d     -r3.1<0;1,0>:d   {I@3}
        add (16|M0)              r20.0<1>:d    r56.0<1;1,0>:d    -r20.0<1;1,0>:d  {Compacted,I@3}
        mov (16|M0)              r24.0<1>:ud   r16.0<1;1,0>:f                   {F@2}
        mov (16|M16)             r26.0<1>:ud   r18.0<1;1,0>:f                   {F@1}
        add (16|M16)             r22.0<1>:d    r54.0<1;1,0>:d    -r22.0<1;1,0>:d  {Compacted,I@5}
(W)     mov (1|M0)               r3.1<1>:f     r4.0<0;1,0>:ud                   {Compacted,I@5}
        mov (16|M0)              r28.0<1>:f    r20.0<1;1,0>:ud                  {Compacted,I@4}
        mov (16|M0)              r32.0<1>:f    r24.0<1;1,0>:ud                  {Compacted,I@3}
        mov (16|M16)             r34.0<1>:f    r26.0<1;1,0>:ud                  {Compacted,I@2}
        mov (16|M16)             r30.0<1>:f    r22.0<1;1,0>:ud                  {Compacted,I@1}
        mad (16|M0)              r36.0<1>:f    r12.0<1;0>:f      r32.0<1;0>:f      -r3.0<0>:f       {Compacted,F@3}
        mad (16|M0)              r40.0<1>:f    r28.0<1;0>:f      r32.0<1;0>:f      -r3.1<0>:f       {Compacted}
        mad (16|M16)             r38.0<1>:f    r14.0<1;0>:f      r34.0<1;0>:f      -r3.0<0>:f       {Compacted,F@4}
        mad (16|M16)             acc2.0<1>:f   r30.0<1;0>:f      r34.0<1;0>:f      -r3.1<0>:f       {F@4}
        add (16|M0)              acc0.0<1>:f   r36.0<1;1,0>:f    r40.0<1;1,0>:f   {Compacted,F@3}
        add (16|M16)             r16.0<1>:f    r38.0<1;1,0>:f    acc2.0<1;1,0>:f  {F@3}
        mul (16|M0)              r18.0<1>:f    r5.0<0;1,0>:f     acc0.0<1;1,0>:f 
(W)     xor (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x30:uw              {A@1}
(W)     xor (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x30:uw              {A@1}
        mul (16|M16)             r20.0<1>:f    r5.0<0;1,0>:f     r16.0<1;1,0>:f   {Compacted,A@1}
(W)     xor (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x30:uw              {A@1}
        mov (16|M0)              r22.0<1>:ud   r18.0<1;1,0>:f                   {A@1}
        mov (16|M16)             r12.0<1>:ud   r20.0<1;1,0>:f                   {F@1}
        add (16|M0)              r14.0<1>:d    r22.0<1;1,0>:d    r24.0<1;1,0>:d   {Compacted,I@2}
        add (16|M16)             r28.0<1>:d    r12.0<1;1,0>:d    r26.0<1;1,0>:d   {Compacted,I@2}
(W)     mul (8|M0)               acc0.0<1>:d   r14.0<1;1,0>:d    r8.8<0;1,0>:uw   {Compacted,I@2}
        mach (8|M0)              r14.0<1>:d    r14.0<1;1,0>:d    r8.4<0;1,0>:d    {Compacted}
(W)     mul (8|M8)               acc0.0<1>:d   r15.0<1;1,0>:d    r8.8<0;1,0>:uw  
        mach (8|M8)              r15.0<1>:d    r15.0<1;1,0>:d    r8.4<0;1,0>:d    {Compacted}
(W)     mul (8|M16)              acc0.0<1>:d   r28.0<1;1,0>:d    r8.8<0;1,0>:uw   {I@5}
        mach (8|M16)             r28.0<1>:d    r28.0<1;1,0>:d    r8.4<0;1,0>:d    {Compacted}
(W)     mul (8|M24)              acc0.0<1>:d   r29.0<1;1,0>:d    r8.8<0;1,0>:uw  
        mach (8|M24)             r29.0<1>:d    r29.0<1;1,0>:d    r8.4<0;1,0>:d    {Compacted}
        add (16|M0)              r14.0<1>:d    r56.0<1;1,0>:d    -r14.0<1;1,0>:d  {Compacted,I@5}
        add (16|M16)             r28.0<1>:d    r54.0<1;1,0>:d    -r28.0<1;1,0>:d  {Compacted,I@2}
        cmp (16|M0)   (ge)f1.0   r4.0<1>:ud    r14.0<1;1,0>:ud   r8.4<0;1,0>:ud   {I@2}
        cmp (16|M16)  (ge)f0.0   r16.0<1>:ud   r28.0<1;1,0>:ud   r8.4<0;1,0>:ud   {I@2}
        add3 (16|M0)             r24.0<1>:d    r22.0<1;0>:d      r24.0<1;0>:d      -r4.0<1>:d       {I@2}
        add3 (16|M16)            r48.0<1>:d    r12.0<1;0>:d      r26.0<1;0>:d      -r16.0<1>:d      {I@2}
L1144:
        join (32|M0)                         L1160                                
L1160:
(W)     mul (8|M0)               acc0.0<1>:d   r24.0<1;1,0>:d    r8.8<0;1,0>:uw   {Compacted,I@3}
        mach (8|M0)              r18.0<1>:d    r24.0<1;1,0>:d    r8.4<0;1,0>:d    {Compacted}
(W)     mul (8|M8)               acc0.0<1>:d   r25.0<1;1,0>:d    r8.8<0;1,0>:uw  
        mach (8|M8)              r19.0<1>:d    r25.0<1;1,0>:d    r8.4<0;1,0>:d    {Compacted}
(W)     mul (8|M16)              acc0.0<1>:d   r48.0<1;1,0>:d    r8.8<0;1,0>:uw   {I@6}
        mach (8|M16)             r20.0<1>:d    r48.0<1;1,0>:d    r8.4<0;1,0>:d    {Compacted}
(W)     mul (8|M24)              acc0.0<1>:d   r49.0<1;1,0>:d    r8.8<0;1,0>:uw  
        mach (8|M24)             r21.0<1>:d    r49.0<1;1,0>:d    r8.4<0;1,0>:d    {Compacted}
        shl (16|M16)             r12.0<1>:d    r48.0<1;1,0>:d    3:w               {Compacted}
        shr (16|M16)             r16.0<1>:ud   r50.0<1;1,0>:ud   3:w              
(W)     mov (1|M0)               r3.0<1>:d     7:w                              
        add (16|M16)             r20.0<1>:d    r54.0<1;1,0>:d    -r20.0<1;1,0>:d  {Compacted,I@4}
        shl (16|M0)              r4.0<1>:d     r24.0<1;1,0>:d    3:w               {Compacted,$1.dst}
        shr (16|M0)              r14.0<1>:ud   r52.0<1;1,0>:ud   3:w              
        add (16|M0)              r18.0<1>:d    r56.0<1;1,0>:d    -r18.0<1;1,0>:d  {Compacted}
        bfn.0xEA (16|M16)        r12.0<1>:ud   r12.0<1;0>:ud     r16.0<1;0>:ud     r3.0<0>:ud       {I@5} // s0|s1&s2
        shl (16|M16)             r20.0<1>:d    r20.0<1;1,0>:d    3:w               {Compacted,I@5}
        bfn.0xEA (16|M0)         r4.0<1>:ud    r4.0<1;0>:ud      r14.0<1;0>:ud     r3.0<0>:ud       {I@4} // s0|s1&s2
        shl (16|M0)              r18.0<1>:d    r18.0<1;1,0>:d    3:w               {Compacted,I@4}
        add (16|M16)             r38.0<1>:d    r12.0<1;1,0>:d    -r8.5<0;1,0>:d   {Compacted,I@4}
        bfn.0xEA (16|M16)        r20.0<1>:ud   r20.0<1;0>:ud     r50.0<1;0>:ud     r3.0<0>:ud       {I@4} // s0|s1&s2
        add (16|M0)              r22.0<1>:d    r4.0<1;1,0>:d     -r8.5<0;1,0>:d   {Compacted,I@4}
        bfn.0xEA (16|M0)         r18.0<1>:ud   r18.0<1;0>:ud     r52.0<1;0>:ud     r3.0<0>:ud       {I@4} // s0|s1&s2
        cmp (16|M16)  (lt)f0.0   null<1>:d     r38.0<1;1,0>:d    r8.7<0;1,0>:d    {I@4}
        add (16|M16)             r40.0<1>:d    r20.0<1;1,0>:d    -r8.6<0;1,0>:d   {Compacted,I@4}
        cmp (16|M0)   (lt)f1.0   null<1>:d     r22.0<1;1,0>:d    r8.7<0;1,0>:d    {I@4}
        add (16|M0)              r26.0<1>:d    r18.0<1;1,0>:d    -r8.6<0;1,0>:d   {Compacted,I@4}
        or (16|M16)              r12.0<1>:d    r38.0<1;1,0>:d    r40.0<1;1,0>:d   {Compacted,I@3}
        cmp (16|M16)  (lt)f1.0   null<1>:d     r40.0<1;1,0>:d    r9.0<0;1,0>:d   
        or (16|M0)               r4.0<1>:d     r22.0<1;1,0>:d    r26.0<1;1,0>:d   {Compacted,I@3}
(f0.0)  cmp (16|M16)  (gt)f0.0   null<1>:d     r12.0<1;1,0>:d    -1:w               {I@3}
(W)     mov (1|M0)               r6.0<1>:hf    0x1:hf                             
(f1.0)  cmp (16|M0)   (gt)f1.0   null<1>:d     r4.0<1;1,0>:d     -1:w               {I@2}
(f1.0)  sel (16|M16)             acc0.0<1>:uw  r6.0<0;1,0>:uw    0x0:uw              {F@1}
(f0.0)  sel (16|M16)             acc2.0<1>:uw  r6.0<0;1,0>:uw    0x0:uw             
(f1.0)  cmp (16|M0)   (lt)f1.0   null<1>:d     r26.0<1;1,0>:d    r9.0<0;1,0>:d   
        and (16|M16)  (ne)f1.0   null<1>:uw    acc0.0<1;1,0>:uw  acc2.0<1;1,0>:uw
(f1.0)  goto (32|M0)                         L2736                  L2736                
L1632:
        shl (16|M0)              r4.0<1>:d     r52.0<1;1,0>:d    5:w               {Compacted}
        shl (16|M16)             r12.0<1>:d    r50.0<1;1,0>:d    5:w               {Compacted}
(W)     mov (1|M0)               a0.0<1>:ud    r9.7<0;1,0>:d                    {A@1}
        shl (16|M0)              r4.0<1>:d     r4.0<1;1,0>:d     1:w               {Compacted,I@3}
        mov (16|M0)              r22.0<1>:d    0:w                              
        shl (16|M16)             r12.0<1>:d    r12.0<1;1,0>:d    1:w               {Compacted,I@4}
        add (16|M0)              r14.0<1>:d    r4.0<1;1,0>:d     r9.4<0;1,0>:d    {Compacted,I@3}
        send.ugm (16|M0)         null     r14     r22:2   a0.0        0x240E0504           {ExBSO,A@1,$5} // wr:2+2, rd:0; store.ugm.d32.a32.wb.wb.bss[a0.0]
        mov (16|M16)             r24.0<1>:d    0:w                              
        add3 (16|M0)             r18.0<1>:d    r4.0<1;0>:d       r9.4<0;0>:d       8:w              
        add3 (16|M0)             r26.0<1>:d    r4.0<1;0>:d       r9.4<0;0>:d       4:w              
        add3 (16|M0)             r34.0<1>:d    r4.0<1;0>:d       r9.4<0;0>:d       12:w              
        add (16|M16)             r16.0<1>:d    r12.0<1;1,0>:d    r9.4<0;1,0>:d    {Compacted}
        add3 (16|M16)            r20.0<1>:d    r12.0<1;0>:d      r9.4<0;0>:d       8:w              
        add3 (16|M16)            r28.0<1>:d    r12.0<1;0>:d      r9.4<0;0>:d       4:w              
        add3 (16|M16)            r14.0<1>:d    r12.0<1;0>:d      r9.4<0;0>:d       12:w               {$5.src}
        send.ugm (16|M16)        null     r16     r24:2   a0.0        0x240E0504           {ExBSO,A@4,$6} // wr:2+2, rd:0; store.ugm.d32.a32.wb.wb.bss[a0.0]
        send.ugm (16|M0)         null     r26     r22:2   a0.0        0x240E0504           {ExBSO,$7} // wr:2+2, rd:0; store.ugm.d32.a32.wb.wb.bss[a0.0]
        send.ugm (16|M16)        null     r28     r24:2   a0.0        0x240E0504           {ExBSO,A@2,$8} // wr:2+2, rd:0; store.ugm.d32.a32.wb.wb.bss[a0.0]
        send.ugm (16|M0)         null     r18     r22:2   a0.0        0x240E0504           {ExBSO,$9} // wr:2+2, rd:0; store.ugm.d32.a32.wb.wb.bss[a0.0]
        send.ugm (16|M16)        null     r20     r24:2   a0.0        0x240E0504           {ExBSO,$10} // wr:2+2, rd:0; store.ugm.d32.a32.wb.wb.bss[a0.0]
        send.ugm (16|M0)         null     r34     r22:2   a0.0        0x240E0504           {ExBSO,$11} // wr:2+2, rd:0; store.ugm.d32.a32.wb.wb.bss[a0.0]
        send.ugm (16|M16)        null     r14     r24:2   a0.0        0x240E0504           {ExBSO,A@1,$12} // wr:2+2, rd:0; store.ugm.d32.a32.wb.wb.bss[a0.0]
        add3 (16|M0)             r30.0<1>:d    r4.0<1;0>:d       r9.4<0;0>:d       16:w              
        add3 (16|M16)            r32.0<1>:d    r12.0<1;0>:d      r9.4<0;0>:d       16:w              
        add3 (16|M16)            r36.0<1>:d    r12.0<1;0>:d      r9.4<0;0>:d       24:w              
        add3 (16|M0)             r16.0<1>:d    r4.0<1;0>:d       r9.4<0;0>:d       24:w               {$6.src}
        add3 (16|M0)             r26.0<1>:d    r4.0<1;0>:d       r9.4<0;0>:d       20:w               {$7.src}
        add3 (16|M16)            r28.0<1>:d    r12.0<1;0>:d      r9.4<0;0>:d       20:w               {$8.src}
        add3 (16|M0)             r14.0<1>:d    r4.0<1;0>:d       r9.4<0;0>:d       28:w               {$12.src}
        send.ugm (16|M0)         null     r30     r22:2   a0.0        0x240E0504           {ExBSO,A@7,$13} // wr:2+2, rd:0; store.ugm.d32.a32.wb.wb.bss[a0.0]
        send.ugm (16|M16)        null     r32     r24:2   a0.0        0x240E0504           {ExBSO,A@6,$14} // wr:2+2, rd:0; store.ugm.d32.a32.wb.wb.bss[a0.0]
        send.ugm (16|M0)         null     r26     r22:2   a0.0        0x240E0504           {ExBSO,A@3,$15} // wr:2+2, rd:0; store.ugm.d32.a32.wb.wb.bss[a0.0]
        send.ugm (16|M16)        null     r28     r24:2   a0.0        0x240E0504           {ExBSO,A@2,$0} // wr:2+2, rd:0; store.ugm.d32.a32.wb.wb.bss[a0.0]
        send.ugm (16|M0)         null     r16     r22:2   a0.0        0x240E0504           {ExBSO,$1} // wr:2+2, rd:0; store.ugm.d32.a32.wb.wb.bss[a0.0]
        send.ugm (16|M16)        null     r36     r24:2   a0.0        0x240E0504           {ExBSO,$2} // wr:2+2, rd:0; store.ugm.d32.a32.wb.wb.bss[a0.0]
        send.ugm (16|M0)         null     r14     r22:2   a0.0        0x240E0504           {ExBSO,A@1,$4} // wr:2+2, rd:0; store.ugm.d32.a32.wb.wb.bss[a0.0]
        add3 (16|M0)             r18.0<1>:d    r4.0<1;0>:d       r9.4<0;0>:d       32:w               {$9.src}
        add3 (16|M16)            r20.0<1>:d    r12.0<1;0>:d      r9.4<0;0>:d       32:w               {$10.src}
        add3 (16|M16)            r34.0<1>:d    r12.0<1;0>:d      r9.4<0;0>:d       28:w               {$11.src}
        add3 (16|M0)             r30.0<1>:d    r4.0<1;0>:d       r9.4<0;0>:d       40:w               {$13.src}
        add3 (16|M16)            r32.0<1>:d    r12.0<1;0>:d      r9.4<0;0>:d       40:w               {$14.src}
        add3 (16|M0)             r26.0<1>:d    r4.0<1;0>:d       r9.4<0;0>:d       36:w               {$15.src}
        add3 (16|M16)            r28.0<1>:d    r12.0<1;0>:d      r9.4<0;0>:d       36:w               {$0.src}
        add3 (16|M0)             r14.0<1>:d    r4.0<1;0>:d       r9.4<0;0>:d       44:w               {$4.src}
        send.ugm (16|M16)        null     r34     r24:2   a0.0        0x240E0504           {ExBSO,A@6,$3} // wr:2+2, rd:0; store.ugm.d32.a32.wb.wb.bss[a0.0]
        send.ugm (16|M0)         null     r18     r22:2   a0.0        0x240E0504           {ExBSO,$5} // wr:2+2, rd:0; store.ugm.d32.a32.wb.wb.bss[a0.0]
        send.ugm (16|M16)        null     r20     r24:2   a0.0        0x240E0504           {ExBSO,$6} // wr:2+2, rd:0; store.ugm.d32.a32.wb.wb.bss[a0.0]
        send.ugm (16|M0)         null     r26     r22:2   a0.0        0x240E0504           {ExBSO,A@3,$7} // wr:2+2, rd:0; store.ugm.d32.a32.wb.wb.bss[a0.0]
        send.ugm (16|M16)        null     r28     r24:2   a0.0        0x240E0504           {ExBSO,A@2,$8} // wr:2+2, rd:0; store.ugm.d32.a32.wb.wb.bss[a0.0]
        send.ugm (16|M0)         null     r30     r22:2   a0.0        0x240E0504           {ExBSO,$9} // wr:2+2, rd:0; store.ugm.d32.a32.wb.wb.bss[a0.0]
        send.ugm (16|M16)        null     r32     r24:2   a0.0        0x240E0504           {ExBSO,$10} // wr:2+2, rd:0; store.ugm.d32.a32.wb.wb.bss[a0.0]
        send.ugm (16|M0)         null     r14     r22:2   a0.0        0x240E0504           {ExBSO,A@1,$11} // wr:2+2, rd:0; store.ugm.d32.a32.wb.wb.bss[a0.0]
        add3 (16|M0)             r16.0<1>:d    r4.0<1;0>:d       r9.4<0;0>:d       48:w               {$1.src}
        add3 (16|M16)            r36.0<1>:d    r12.0<1;0>:d      r9.4<0;0>:d       48:w               {$2.src}
        add3 (16|M16)            r34.0<1>:d    r12.0<1;0>:d      r9.4<0;0>:d       44:w               {$3.src}
        add3 (16|M0)             r18.0<1>:d    r4.0<1;0>:d       r9.4<0;0>:d       56:w               {$5.src}
        add3 (16|M16)            r20.0<1>:d    r12.0<1;0>:d      r9.4<0;0>:d       56:w               {$6.src}
        add3 (16|M0)             r26.0<1>:d    r4.0<1;0>:d       r9.4<0;0>:d       52:w               {$7.src}
        add3 (16|M16)            r28.0<1>:d    r12.0<1;0>:d      r9.4<0;0>:d       52:w               {$8.src}
        add3 (16|M16)            r30.0<1>:d    r12.0<1;0>:d      r9.4<0;0>:d       60:w               {$9.src}
        add3 (16|M0)             r14.0<1>:d    r4.0<1;0>:d       r9.4<0;0>:d       60:w               {$11.src}
        send.ugm (16|M16)        null     r34     r24:2   a0.0        0x240E0504           {ExBSO,A@7,$12} // wr:2+2, rd:0; store.ugm.d32.a32.wb.wb.bss[a0.0]
        send.ugm (16|M0)         null     r16     r22:2   a0.0        0x240E0504           {ExBSO,$13} // wr:2+2, rd:0; store.ugm.d32.a32.wb.wb.bss[a0.0]
        send.ugm (16|M16)        null     r36     r24:2   a0.0        0x240E0504           {ExBSO,$14} // wr:2+2, rd:0; store.ugm.d32.a32.wb.wb.bss[a0.0]
        send.ugm (16|M0)         null     r26     r22:2   a0.0        0x240E0504           {ExBSO,A@4,$15} // wr:2+2, rd:0; store.ugm.d32.a32.wb.wb.bss[a0.0]
        send.ugm (16|M16)        null     r28     r24:2   a0.0        0x240E0504           {ExBSO,A@3,$0} // wr:2+2, rd:0; store.ugm.d32.a32.wb.wb.bss[a0.0]
        send.ugm (16|M0)         null     r18     r22:2   a0.0        0x240E0504           {ExBSO,$1} // wr:2+2, rd:0; store.ugm.d32.a32.wb.wb.bss[a0.0]
        send.ugm (16|M16)        null     r20     r24:2   a0.0        0x240E0504           {ExBSO,$2} // wr:2+2, rd:0; store.ugm.d32.a32.wb.wb.bss[a0.0]
        send.ugm (16|M0)         null     r14     r22:2   a0.0        0x240E0504           {ExBSO,A@1,$4} // wr:2+2, rd:0; store.ugm.d32.a32.wb.wb.bss[a0.0]
        send.ugm (16|M16)        null     r30     r24:2   a0.0        0x240E0504           {ExBSO,$3} // wr:2+2, rd:0; store.ugm.d32.a32.wb.wb.bss[a0.0]
        goto (32|M0)                         L2736                  L47048                
L2736:
        join (32|M0)                         L47048                                
L2752:
        mul (8|M0)               acc0.0<1>:ud  r22.0<1;1,0>:ud   r9.0<0;1,0>:uw  
        mach (8|M0)              r4.0<1>:ud    r22.0<1;1,0>:ud   r9.0<0;1,0>:ud   {AccWrEn,Compacted}
(W)     and (1|M0)               r3.0<2>:b     r9.4<0;1,0>:b     1:w              
        mov (8|M0)               r12.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mul (8|M8)               acc0.0<1>:ud  r23.0<1;1,0>:ud   r9.0<0;1,0>:uw  
        mach (8|M8)              r5.0<1>:ud    r23.0<1;1,0>:ud   r9.0<0;1,0>:ud   {AccWrEn}
(W)     cmp (16|M0)   (eq)f1.0   null<1>:w     r3.0<0;1,0>:b     0:w               {I@4}
        mov (8|M8)               r13.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mul (8|M16)              acc0.0<1>:ud  r38.0<1;1,0>:ud   r9.0<0;1,0>:uw  
        mach (8|M16)             r16.0<1>:ud   r38.0<1;1,0>:ud   r9.0<0;1,0>:ud   {AccWrEn,$13.src}
(W)     mov (1|M0)               r10.7<1>:ud   f1.0<0;1,0>:ud                   {Compacted,$3.dst}
        mov (8|M16)              r18.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted,$1.src}
        mul (8|M24)              acc0.0<1>:ud  r39.0<1;1,0>:ud   r9.0<0;1,0>:uw  
        mach (8|M24)             r17.0<1>:ud   r39.0<1;1,0>:ud   r9.0<0;1,0>:ud   {AccWrEn}
        add (16|M0)              r88.0<1>:d    r12.0<1;1,0>:d    r26.0<1;1,0>:d   {Compacted,I@7}
        mov (8|M24)              r19.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
(W)     mov (1|M0)               f0.0<1>:ud    r10.7<0;1,0>:ud                  {I@6}
        add (16|M16)             r86.0<1>:d    r18.0<1;1,0>:d    r40.0<1;1,0>:d   {Compacted,I@2}
(W)     cmp (16|M16)  (eq)f0.0   null<1>:w     r3.0<0;1,0>:b     0:w              
        shl (16|M0)              r92.0<1>:d    r52.0<1;1,0>:d    5:w               {Compacted}
        shl (16|M16)             r90.0<1>:d    r50.0<1;1,0>:d    5:w               {Compacted}
        shl (16|M0)              r88.0<1>:d    r88.0<1;1,0>:d    5:w               {Compacted}
        shl (16|M16)             r86.0<1>:d    r86.0<1;1,0>:d    5:w               {Compacted,I@5}
        mov (16|M0)              r14.0<1>:f    r4.0<1;1,0>:f                    {Compacted,$4.src}
        mov (16|M16)             r20.0<1>:f    r16.0<1;1,0>:f                   {Compacted,$2.src}
        shl (16|M0)              r92.0<1>:d    r92.0<1;1,0>:d    1:w               {Compacted,I@4}
        shl (16|M16)             r90.0<1>:d    r90.0<1;1,0>:d    1:w               {Compacted,I@4}
        shl (16|M0)              r96.0<1>:d    r88.0<1;1,0>:d    2:w               {Compacted,I@4}
        shl (16|M16)             r94.0<1>:d    r86.0<1;1,0>:d    2:w               {Compacted,I@4}
        shl (16|M0)              r88.0<1>:d    r88.0<1;1,0>:d    1:w               {Compacted}
        shl (16|M16)             r86.0<1>:d    r86.0<1;1,0>:d    1:w               {Compacted}
(W)     mov (1|M0)               r10.4<1>:f    -0.0:f                               {Compacted}
(W)     mov (1|M0)               r10.3<1>:f    inf:f                               {Compacted}
(W)     mov (1|M0)               r10.2<1>:d    -1:w                              
(W)     mov (1|M0)               r10.6<1>:d    0:w                              
(W)     mov (1|M0)               r10.7<1>:ud   f0.0<0;1,0>:ud                   {Compacted}
L3144:
(W)     mov (1|M0)               f1.0<1>:ud    r10.7<0;1,0>:ud                  {I@1}
(f1.0)  goto (32|M0)                         L3344                  L3344                
L3176:
(W)     shl (1|M0)               r3.0<1>:d     r10.6<0;1,0>:d    1:w               {Compacted}
(W)     mov (1|M0)               a0.0<1>:ud    r10.0<0;1,0>:d                   {A@1}
        add3 (16|M0)             r4.0<1>:d     r88.0<1;0>:d      r9.5<0;0>:d       r3.0<0>:d        {A@2}
        add3 (16|M16)            r12.0<1>:d    r86.0<1;0>:d      r9.5<0;0>:d       r3.0<0>:d       
        send.ugm (16|M0)         r14      r4      null:0  a0.0        0x24280B00           {ExBSO,A@2,$7} // wr:2+0, rd:2; load.ugm.d16u32.a32.ca.ca.bss[a0.0]
        send.ugm (16|M16)        r16      r12     null:0  a0.0        0x24280B00           {ExBSO,A@1,$8} // wr:2+0, rd:2; load.ugm.d16u32.a32.ca.ca.bss[a0.0]
        mov (16|M0)              r6.0<1>:uw    r14.0<2;1,0>:uw                  {$7.dst}
        mov (16|M16)             r11.0<1>:uw   r16.0<2;1,0>:uw                  {$8.dst}
        mov (16|M0)              r78.0<1>:f    r6.0<1;1,0>:hf                   {I@2}
        mov (16|M16)             r76.0<1>:f    r11.0<1;1,0>:hf                  {I@1}
        goto (32|M0)                         L3344                  L3448                
L3344:
        join (32|M0)                         L3448                                
L3360:
(W)     shl (1|M0)               r3.0<1>:d     r10.6<0;1,0>:d    2:w               {Compacted}
(W)     mov (1|M0)               a0.0<1>:ud    r10.1<0;1,0>:d                   {A@1}
        add3 (16|M0)             r4.0<1>:d     r96.0<1;0>:d      r9.6<0;0>:d       r3.0<0>:d        {I@2}
        add3 (16|M16)            r12.0<1>:d    r94.0<1;0>:d      r9.6<0;0>:d       r3.0<0>:d       
        send.ugm (16|M0)         r78      r4      null:0  a0.0        0x24280500           {ExBSO,A@2,$9} // wr:2+0, rd:2; load.ugm.d32.a32.ca.ca.bss[a0.0]
        send.ugm (16|M16)        r76      r12     null:0  a0.0        0x24280500           {ExBSO,A@1,$11} // wr:2+0, rd:2; load.ugm.d32.a32.ca.ca.bss[a0.0]
L3448:
        join (32|M0)                         L47048                                
L3464:
        and (16|M0)              r4.0<1>:d     r78.0<1;1,0>:d    2147483647:d               {$9.dst}
        and (16|M16)             r12.0<1>:d    r76.0<1;1,0>:d    2147483647:d               {$11.dst}
        sel (16|M0)   (lt)f0.0   r22.0<1>:f    r4.0<1;1,0>:f     448.0:f               {Compacted,I@2}
        sync.nop                             null                             {Compacted,$3.src}
        sel (16|M16)  (lt)f0.0   r24.0<1>:f    r12.0<1;1,0>:f    448.0:f               {I@1}
        shr (16|M0)              r12.0<1>:ud   r22.0<1;1,0>:ud   23:w               {A@1}
        shr (16|M16)             r6.0<1>:ud    r24.0<1;1,0>:ud   23:w              
        sync.nop                             null                             {Compacted,$6.src}
        and (16|M0)              r20.0<1>:d    r12.0<1;1,0>:d    255:w               {Compacted,I@2}
        sync.nop                             null                             {Compacted,$5.src}
        and (16|M16)             r18.0<1>:d    r6.0<1;1,0>:d     255:w               {Compacted,I@2}
        sel (16|M0)   (ge)f0.0   r14.0<1>:ud   r20.0<1;1,0>:ud   0x79:uw              {I@2}
        sel (16|M16)  (ge)f0.0   r16.0<1>:ud   r18.0<1;1,0>:ud   0x79:uw              {I@2}
        cmp (16|M16)  (eq)f1.0   null<1>:d     r18.0<1;1,0>:d    255:w              
        shl (16|M0)              r82.0<1>:d    r14.0<1;1,0>:d    23:w               {Compacted,I@3}
        and (16|M16)  (ne)f0.0   r14.0<1>:d    r24.0<1;1,0>:d    8388607:d              
(W)     mov (1|M0)               r3.0<1>:hf    0x1:hf                             
        shl (16|M16)             r84.0<1>:d    r16.0<1;1,0>:d    23:w               {Compacted,I@4}
        and (16|M0)   (ne)f1.0   r16.0<1>:d    r22.0<1;1,0>:d    8388607:d              
(f1.0)  sel (16|M16)             acc0.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw              {F@1}
(f0.0)  sel (16|M16)             acc2.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw             
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r20.0<1;1,0>:d    255:w              
        and (16|M16)  (ne)f1.0   null<1>:uw    acc0.0<1;1,0>:uw  acc2.0<1;1,0>:uw
(~f1.0) goto (32|M0)                         L3824                  L3824                
L3784:
        mov (16|M0)              r22.0<1>:ud   0x7FC00000:ud                             
        mov (16|M16)             r28.0<1>:f    qnan(0x0):f                               {Compacted,$0.src}
        goto (32|M0)                         L3824                  L14048                
L3824:
        join (32|M0)                         L14048                                
L3840:
        cmp (16|M16)  (eq)f1.0   null<1>:d     r14.0<1;1,0>:d    0:w               {I@7}
        cmp (16|M16)  (eq)f0.0   null<1>:d     r18.0<1;1,0>:d    255:w              
        cmp (16|M0)   (eq)f0.0   null<1>:d     r16.0<1;1,0>:d    0:w               {Compacted,I@7}
(W)     mov (1|M0)               r3.0<1>:hf    0x1:hf                              {I@7}
        add (16|M0)              r30.0<1>:d    -r82.0<1;1,0>:d   -2139095040:d              
(f0.0)  sel (16|M16)             acc0.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw              {F@1}
(f1.0)  sel (16|M16)             acc2.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw             
(f0.0)  cmp (16|M0)   (eq)f0.0   null<1>:d     r20.0<1;1,0>:d    255:w              
        and (16|M16)  (ne)f0.0   null<1>:uw    acc0.0<1;1,0>:uw  acc2.0<1;1,0>:uw
        add (16|M16)             r32.0<1>:d    -r84.0<1;1,0>:d   -2139095040:d               {$10.src}
        xor (16|M0)              r22.0<1>:d    r30.0<1;1,0>:d    r22.0<1;1,0>:d   {Compacted,I@6}
        sync.nop                             null                             {Compacted,$15.src}
        xor (16|M16)             r26.0<1>:d    r32.0<1;1,0>:d    r24.0<1;1,0>:d   {Compacted,I@2}
(f0.0)  goto (32|M0)                         L13992                  L13992                
L4032:
        or (16|M0)    (eq)f1.0   null<1>:d     r20.0<1;1,0>:d    r16.0<1;1,0>:d  
        or (16|M16)   (eq)f1.0   null<1>:d     r18.0<1;1,0>:d    r14.0<1;1,0>:d  
(~f1.0) goto (32|M0)                         L4120                  L4120                
L4080:
        mov (16|M0)              r22.0<1>:ud   0x0:ud                             
        mov (16|M16)             r28.0<1>:f    0.0:f                               {Compacted,$0.src}
        goto (32|M0)                         L4120                  L14048                
L4120:
        join (32|M0)                         L13992                                
L4136:
        cmp (16|M0)   (eq)f1.0   null<1>:d     r20.0<1;1,0>:d    0:w              
        cmp (16|M16)  (eq)f1.0   null<1>:d     r18.0<1;1,0>:d    0:w              
        shr (16|M0)              r60.0<1>:ud   r30.0<1;1,0>:ud   23:w              
        shr (16|M16)             r64.0<1>:ud   r32.0<1;1,0>:ud   23:w              
        add (16|M0)              r58.0<1>:d    r20.0<1;1,0>:d    -127:w               {Compacted}
        add (16|M16)             r56.0<1>:d    r18.0<1;1,0>:d    -127:w               {Compacted}
(f1.0)  mov (16|M0)              r58.0<1>:d    -126:w                              
(f1.0)  mov (16|M16)             r56.0<1>:d    -126:w                              
        add (16|M0)              r52.0<1>:d    r60.0<1;1,0>:d    r58.0<1;1,0>:d   {Compacted,I@2}
        add (16|M16)             r50.0<1>:d    r64.0<1;1,0>:d    r56.0<1;1,0>:d   {Compacted,I@2}
        cmp (16|M0)   (gt)f0.0   null<1>:d     r52.0<1;1,0>:d    254:w               {Compacted,I@2}
        cmp (16|M16)  (gt)f0.0   null<1>:d     r50.0<1;1,0>:d    254:w               {I@2}
(f0.0)  goto (32|M0)                         L13904                  L13904                
L4304:
        or (16|M0)    (eq)f0.0   null<4>:b     r12.0<1;1,0>:d    r60.0<1;1,0>:d  
        or (16|M16)   (eq)f0.0   null<4>:b     r6.0<1;1,0>:d     r64.0<1;1,0>:d  
(f0.0)  goto (32|M0)                         L13816                  L13816                
L4352:
(W)     mov (1|M0)               r3.0<1>:hf    0.0:hf                             
(W)     mov (1|M0)               r2.3<1>:d     0:w                              
(f1.0)  sel (16|M0)              r4.0<1>:d     r3.0<0;1,0>:w     8388608:d               {F@1}
(f1.0)  sel (16|M16)             r12.0<1>:d    r3.0<0;1,0>:w     8388608:d              
        or (16|M0)               r4.0<1>:d     r4.0<1;1,0>:d     r16.0<1;1,0>:d   {Compacted,I@2}
        or (16|M16)              r12.0<1>:d    r12.0<1;1,0>:d    r14.0<1;1,0>:d   {Compacted,I@2}
        shl (16|M0)              r48.0<1>:d    r4.0<1;1,0>:d     23:w               {Compacted,I@2}
        shr (16|M0)              r42.0<1>:ud   r4.0<1;1,0>:ud    9:w              
        shl (16|M16)             r44.0<1>:d    r12.0<1;1,0>:d    23:w               {Compacted,I@3}
        shr (16|M16)             r40.0<1>:ud   r12.0<1;1,0>:ud   9:w              
(W)     mov (1|M0)               r2.5<1>:f     -0.0:f                               {Compacted}
(W)     mov (2|M0)               r2.0<1>:d     0:w                              
L4504:
(W)     shl (1|M0)               r3.0<1>:d     r2.5<0;1,0>:d     31:w               {Compacted,F@1}
(W)     shr (1|M0)               r3.1<1>:ud    r2.3<0;1,0>:ud    1:w              
(W)     addc (1|M0)              r7.0<1>:ud    r2.0<0;1,0>:ud    0x1:ud              {AccWrEn,I@3}
(W)     or (1|M0)                r2.3<1>:d     r3.1<0;1,0>:d     r3.0<0;1,0>:d    {I@2}
        bfn.0xE0 (16|M0)         r12.0<1>:ud   r3.1<0;0>:ud      r3.0<0;0>:ud      r48.0<1>:ud      // (s0|s1)&s2
        cmp (16|M0)   (eq)f0.0   null<1>:d     r12.0<1;1,0>:d    r2.3<0;1,0>:d    {I@1}
(W)     mov (1|M0)               r4.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        bfn.0xE0 (16|M16)        r14.0<1>:ud   r3.1<0;0>:ud      r3.0<0;0>:ud      r44.0<1>:ud      // (s0|s1)&s2
(W)     add (1|M0)               r2.4<1>:ud    r4.0<0;1,0>:ud    r2.1<0;1,0>:ud   {I@2}
(W)     mov (1|M0)               r4.0<1>:ud    f0.0<0;1,0>:ud                   {Compacted}
(W)     shr (1|M0)               r2.2<1>:ud    r2.5<0;1,0>:ud    1:w              
(W)     mov (1|M0)               f0.0<1>:ud    r4.0<0;1,0>:ud                   {I@2}
        cmp (16|M16)  (eq)f0.0   null<1>:d     r14.0<1;1,0>:d    r2.3<0;1,0>:d   
        and (16|M0)              r16.0<1>:d    r2.2<0;1,0>:d     r42.0<1;1,0>:d   {Compacted,I@3}
(W)     mov (1|M0)               r4.0<1>:ud    f0.0<0;1,0>:ud                   {Compacted}
(W)     cmp (16|M0)   (gt)f1.0   null<1>:d     r2.0<0;1,0>:ud    0x3E:uw             
(W)     mov (1|M0)               f0.0<1>:ud    r4.0<0;1,0>:ud                   {I@2}
        and (16|M16)             r18.0<1>:d    r2.2<0;1,0>:d     r40.0<1;1,0>:d   {Compacted}
(W&f1.0) cmp (16|M0)  (eq)f1.0   null<1>:d     r2.1<0;1,0>:d     0:w              
(f0.0)  cmp (16|M0)   (eq)f0.0   null<1>:d     r16.0<1;1,0>:d    r2.2<0;1,0>:d   
(W&~f1.0) cmp (16|M0) (gt)f1.0   null<1>:d     r2.1<0;1,0>:ud    0x0:uw             
(W)     mov (1|M0)               r4.0<1>:ud    f0.0<0;1,0>:ud                   {Compacted}
(W)     cmp (16|M16)  (gt)f1.0   null<1>:d     r2.0<0;1,0>:ud    0x3E:uw             
(W)     mov (1|M0)               f0.0<1>:ud    r4.0<0;1,0>:ud                   {I@2}
(W)     mov (1|M0)               r3.0<1>:hf    0x1:hf                             
(W&f1.0) cmp (16|M16) (eq)f1.0   null<1>:d     r2.1<0;1,0>:d     0:w              
(f0.0)  cmp (16|M16)  (eq)f0.0   null<1>:d     r18.0<1;1,0>:d    r2.2<0;1,0>:d   
(f1.0)  sel (16|M0)              acc0.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw              {F@1}
(f0.0)  sel (16|M0)              acc2.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw             
(W)     mov (1|M0)               r4.0<1>:ud    f0.0<0;1,0>:ud                   {Compacted}
        or (16|M0)    (ne)f0.0   null<1>:uw    acc0.0<1;1,0>:uw  acc2.0<1;1,0>:uw
(W&~f1.0) cmp (16|M16) (gt)f1.0  null<1>:d     r2.1<0;1,0>:ud    0x0:uw             
(W)     mov (1|M0)               r3.1<1>:ud    f0.0<0;1,0>:ud                   {Compacted}
(W)     mov (1|M0)               f0.0<1>:ud    r4.0<0;1,0>:ud                   {I@4}
(f1.0)  sel (16|M16)             acc0.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw             
(W)     mov (1|M0)               f1.0<1>:ud    r3.1<0;1,0>:ud                   {I@3}
(f0.0)  sel (16|M16)             acc2.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw             
        or (16|M16)   (ne)f1.0   null<1>:uw    acc0.0<1;1,0>:uw  acc2.0<1;1,0>:uw
        mov (16|M0)              r62.0<1>:f    r2.0<0;1,0>:f                    {Compacted}
(W)     mov (1|M0)               r3.1<1>:ud    f1.0<0;1,0>:ud                   {Compacted}
        mov (16|M16)             r54.0<1>:f    r2.0<0;1,0>:f                    {Compacted}
(W)     mov (1|M0)               f0.0<1>:ud    r3.1<0;1,0>:ud                   {I@1}
        mov (16|M16)             r20.0<1>:d    r2.1<0;1,0>:d                   
        mov (16|M0)              r38.0<1>:f    r7.0<0;1,0>:f                    {Compacted}
        mov (16|M16)             r36.0<1>:f    r7.0<0;1,0>:f                    {Compacted,$14.src}
        mov (16|M0)              r34.0<1>:d    r2.4<0;1,0>:d                    {$12.src}
        mov (16|M16)             r32.0<1>:d    r2.4<0;1,0>:d                   
        mov (16|M0)              r16.0<1>:d    r2.1<0;1,0>:d                   
(f0.0)  goto (32|M0)                         L5232                  L5232                
L5176:
(W)     mov (1|M0)               r2.5<1>:d     r2.2<0;1,0>:d                   
(W)     mov (1|M0)               r2.0<1>:f     r7.0<0;1,0>:f                    {Compacted}
(W)     mov (1|M0)               r2.1<1>:d     r2.4<0;1,0>:d                   
(W)     jmpi                                 L4504                                
L5232:
        join (32|M0)                         L13816                                
L5248:
(W)     mov (1|M0)               r3.0<1>:f     8.68805e-44:f                              
(W)     mov (1|M0)               r4.0<1>:hf    0.0:hf                             
        subb (8|M0)              r30.0<1>:ud   r3.0<0;1,0>:ud    r62.0<1;1,0>:ud  {AccWrEn,Compacted,F@2}
        add3 (8|M0)              r68.0<1>:ud   -acc0.0<1;0>:ud   r4.0<0;0>:uw      -r16.0<1>:ud     {A@1}
        subb (8|M8)              r31.0<1>:ud   r3.0<0;1,0>:ud    r63.0<1;1,0>:ud  {AccWrEn}
        add3 (8|M8)              r69.0<1>:ud   -acc0.0<1;0>:ud   r4.0<0;0>:uw      -r17.0<1>:ud    
        subb (8|M16)             r24.0<1>:ud   r3.0<0;1,0>:ud    r54.0<1;1,0>:ud  {AccWrEn}
        add3 (16|M0)             r18.0<1>:d    r52.0<1;0>:d      r30.0<1;0>:d      -173:w               {I@3}
        add3 (8|M16)             r80.0<1>:ud   -acc0.0<1;0>:ud   r4.0<0;0>:uw      -r20.0<1>:ud    
        subb (8|M24)             r25.0<1>:ud   r3.0<0;1,0>:ud    r55.0<1;1,0>:ud  {AccWrEn}
        cmp (16|M0)   (gt)f0.0   null<1>:d     r18.0<1;1,0>:d    127:w               {Compacted,I@3}
        add3 (16|M16)            r64.0<1>:d    r64.0<1;0>:d      r56.0<1;0>:d      r24.0<1>:d       {I@2}
        add3 (16|M16)            r56.0<1>:d    r50.0<1;0>:d      r24.0<1;0>:d      -173:w              
        cmp (16|M16)  (gt)f0.0   null<1>:d     r56.0<1;1,0>:d    127:w               {I@1}
        add3 (16|M0)             r66.0<1>:d    r60.0<1;0>:d      r58.0<1;0>:d      r30.0<1>:d      
        add3 (8|M24)             r81.0<1>:ud   -acc0.0<1;0>:ud   r4.0<0;0>:uw      -r21.0<1>:ud    
(f0.0)  goto (32|M0)                         L13728                  L13728                
L5504:
        cmp (16|M0)   (gt)f1.0   null<1>:d     r18.0<1;1,0>:d    -127:w              
        cmp (16|M16)  (gt)f1.0   null<1>:d     r56.0<1;1,0>:d    -127:w              
(f1.0)  goto (32|M0)                         L9616                  L9616                
L5552:
        cmp (16|M0)   (lt)f0.0   null<1>:d     r18.0<1;1,0>:ud   0xFFFFFF6B:ud             
        cmp (16|M16)  (lt)f0.0   null<1>:d     r56.0<1;1,0>:ud   0xFFFFFF6B:ud             
(f0.0)  goto (32|M0)                         L8864                  L8864                
L5600:
(W)     mov (1|M0)               r3.0<1>:f     8.82818e-44:f                              
        add3 (16|M0)             r34.0<1>:d    r52.0<1;0>:d      r30.0<1;0>:d      -23:w              
(W)     mov (1|M0)               r4.0<1>:hf    0.0:hf                              {I@7}
        subb (8|M0)              r30.0<1>:ud   r3.0<0;1,0>:ud    r62.0<1;1,0>:ud  {AccWrEn,Compacted,F@2}
        add3 (16|M16)            r60.0<1>:d    r50.0<1;0>:d      r24.0<1;0>:d      -23:w              
        add3 (8|M0)              r12.0<1>:ud   -acc0.0<1;0>:ud   r4.0<0;0>:uw      -r16.0<1>:ud     {F@1}
        subb (8|M8)              r31.0<1>:ud   r3.0<0;1,0>:ud    r63.0<1;1,0>:ud  {AccWrEn}
(W)     mov (1|M0)               r5.0<1>:hf    0x1:hf                             
        add3 (8|M8)              r13.0<1>:ud   -acc0.0<1;0>:ud   r4.0<0;0>:uw      -r17.0<1>:ud    
        subb (8|M16)             r58.0<1>:ud   r3.0<0;1,0>:ud    r54.0<1;1,0>:ud  {AccWrEn}
        cmp (16|M0)   (gt)f1.0   null<1>:d     r30.0<1;1,0>:ud   r34.0<1;1,0>:ud  {I@3}
        add3 (8|M16)             r14.0<1>:ud   -acc0.0<1;0>:ud   r4.0<0;0>:uw      -r20.0<1>:ud    
        subb (8|M24)             r59.0<1>:ud   r3.0<0;1,0>:ud    r55.0<1;1,0>:ud  {AccWrEn}
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r12.0<1;1,0>:d    0:w               {I@5}
        cmp (16|M16)  (gt)f0.0   null<1>:d     r58.0<1;1,0>:ud   r60.0<1;1,0>:ud  {I@2}
        add3 (8|M24)             r15.0<1>:ud   -acc0.0<1;0>:ud   r4.0<0;0>:uw      -r21.0<1>:ud    
(~f1.0) cmp (16|M0)   (gt)f1.0   null<1>:d     r12.0<1;1,0>:ud   0x0:uw             
(f0.0)  cmp (16|M16)  (eq)f0.0   null<1>:d     r14.0<1;1,0>:d    0:w               {I@2}
        cmp (16|M16)  (gt)f1.0   null<1>:d     r14.0<1;1,0>:ud   0x0:uw             
(f0.0)  sel (16|M16)             acc0.0<1>:uw  r5.0<0;1,0>:uw    0x0:uw              {F@1}
(f1.0)  sel (16|M16)             acc2.0<1>:uw  r5.0<0;1,0>:uw    0x0:uw             
        or (16|M16)   (ne)f1.0   null<1>:uw    acc2.0<1;1,0>:uw  acc0.0<1;1,0>:uw
(f1.0)  goto (32|M0)                         L6056                  L6056                
L5960:
        add3 (16|M0)             r4.0<1>:d     r66.0<1;0>:d      -r30.0<1;0>:d     -23:w              
        add3 (16|M16)            r12.0<1>:d    r64.0<1;0>:d      -r58.0<1;0>:d     -23:w              
        mov (16|M0)              r18.0<1>:d    0:w                              
        mov (16|M16)             r72.0<1>:d    0:w                              
        shl (16|M0)              r30.0<1>:d    r48.0<1;1,0>:d    r4.0<1;1,0>:d    {Compacted,I@4}
        shl (16|M16)             r74.0<1>:d    r44.0<1;1,0>:d    r12.0<1;1,0>:d   {Compacted,I@4}
        goto (32|M0)                         L6056                  L8760                
L6056:
        join (32|M0)                         L8760                                
L6072:
        add3 (16|M0)             r38.0<1>:d    r30.0<1;0>:d      -r66.0<1;0>:d     23:w               {I@4}
        add3 (16|M16)            r6.0<1>:d     r58.0<1;0>:d      -r64.0<1;0>:d     23:w              
        cmp (16|M0)   (lt)f1.0   null<1>:d     r38.0<1;1,0>:d    2:w               {Compacted,I@2}
        cmp (16|M16)  (lt)f1.0   null<1>:d     r6.0<1;1,0>:d     2:w               {I@2}
(f1.0)  goto (32|M0)                         L6312                  L6312                
L6144:
        cmp (16|M0)   (eq)f0.0   null<1>:d     r38.0<1;1,0>:d    2:w               {Compacted}
        cmp (16|M16)  (eq)f0.0   null<1>:d     r6.0<1;1,0>:d     2:w              
(~f0.0) goto (32|M0)                         L6312                  L6376                
L6184:
        shr (16|M0)              r18.0<1>:ud   r48.0<1;1,0>:ud   1:w              
        shr (16|M16)             r54.0<1>:ud   r44.0<1;1,0>:ud   1:w              
        mov (16|M0)              r52.0<1>:d    0:w                              
        mov (16|M16)             r66.0<1>:d    0:w                              
        mov (16|M0)              r30.0<1>:d    0:w                              
        mov (16|M16)             r64.0<1>:d    0:w                              
        mov (16|M0)              r34.0<1>:f    r18.0<1;1,0>:f                   {Compacted,I@6}
        mov (16|M16)             r62.0<1>:f    r54.0<1;1,0>:f                   {Compacted,I@5}
        goto (32|M0)                         L6312                  L7896                
L6312:
        join (32|M0)                         L6376                                
L6328:
        cmp (16|M0)   (eq)f1.0   null<1>:d     r38.0<1;1,0>:d    1:w              
        cmp (16|M16)  (eq)f1.0   null<1>:d     r6.0<1;1,0>:d     1:w              
(f1.0)  goto (32|M0)                         L6376                  L7800                
L6376:
        join (32|M0)                         L7800                                
L6392:
        add3 (16|M0)             r4.0<1>:d     r30.0<1;0>:d      -r34.0<1;0>:d     -1:w               {A@2}
        add3 (16|M16)            r12.0<1>:d    r58.0<1;0>:d      -r60.0<1;0>:d     -1:w              
        and (16|M0)   (ne)f0.0   r14.0<1>:d    r4.0<1;1,0>:d     63:w               {Compacted,I@2}
        and (16|M16)  (ne)f0.0   r2.0<1>:d     r12.0<1;1,0>:d    63:w               {I@2}
(f0.0)  goto (32|M0)                         L6504                  L6504                
L6464:
        mov (16|M0)              r68.0<1>:f    r48.0<1;1,0>:f                   {Compacted}
        mov (16|M16)             r70.0<1>:d    r44.0<1;1,0>:d                  
        goto (32|M0)                         L6504                  L6768                
L6504:
        join (32|M0)                         L6768                                
L6520:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r14.0<1;1,0>:ud   0x20:uw              {I@6}
        cmp (16|M16)  (lt)f1.0   null<1>:d     r2.0<1;1,0>:ud    0x20:uw              {I@6}
(f1.0)  goto (32|M0)                         L6632                  L6632                
L6568:
        add (16|M0)              r4.0<1>:d     r14.0<1;1,0>:d    -32:w               {Compacted}
        add (16|M16)             r12.0<1>:d    r2.0<1;1,0>:d     -32:w               {Compacted}
        shr (16|M0)              r18.0<1>:ud   r42.0<1;1,0>:ud   r4.0<1;1,0>:d    {I@2}
        shr (16|M16)             r54.0<1>:ud   r40.0<1;1,0>:ud   r12.0<1;1,0>:d   {A@2}
        goto (32|M0)                         L6632                  L6728                
L6632:
        join (32|M0)                         L6728                                
L6648:
        add (16|M0)              r4.0<1>:d     -r14.0<1;1,0>:d   32:w               {Compacted}
        add (16|M16)             r12.0<1>:d    -r2.0<1;1,0>:d    32:w               {Compacted}
        shr (16|M16)             r16.0<1>:ud   r44.0<1;1,0>:ud   r2.0<1;1,0>:d   
        shl (16|M0)              r4.0<1>:d     r42.0<1;1,0>:d    r4.0<1;1,0>:d    {Compacted,I@3}
        shr (16|M0)              r14.0<1>:ud   r48.0<1;1,0>:ud   r14.0<1;1,0>:d  
        shl (16|M16)             r12.0<1>:d    r40.0<1;1,0>:d    r12.0<1;1,0>:d   {Compacted,I@4}
        or (16|M0)               r18.0<1>:d    r14.0<1;1,0>:d    r4.0<1;1,0>:d    {Compacted,I@2}
        or (16|M16)              r54.0<1>:d    r16.0<1;1,0>:d    r12.0<1;1,0>:d   {Compacted,I@2}
L6728:
        join (32|M0)                         L6768                                
L6744:
        mov (16|M0)              r68.0<1>:f    r18.0<1;1,0>:f                   {Compacted,I@3}
        mov (16|M16)             r70.0<1>:d    r54.0<1;1,0>:d                   {I@2}
L6768:
        join (32|M0)                         L7800                                
L6784:
        add3 (16|M0)             r34.0<1>:d    r30.0<1;0>:d      -r34.0<1;0>:d     -2:w              
        add3 (16|M16)            r20.0<1>:d    r58.0<1;0>:d      -r60.0<1;0>:d     -2:w              
        and (16|M0)   (ne)f0.0   r14.0<1>:d    r34.0<1;1,0>:d    63:w               {Compacted,I@2}
        and (16|M16)  (ne)f0.0   r2.0<1>:d     r20.0<1;1,0>:d    63:w               {I@2}
(f0.0)  goto (32|M0)                         L6896                  L6896                
L6856:
        mov (16|M0)              r18.0<1>:f    r48.0<1;1,0>:f                   {Compacted}
        mov (16|M16)             r54.0<1>:d    r44.0<1;1,0>:d                  
        goto (32|M0)                         L6896                  L7120                
L6896:
        join (32|M0)                         L7120                                
L6912:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r14.0<1;1,0>:ud   0x20:uw              {I@6}
        cmp (16|M16)  (lt)f1.0   null<1>:d     r2.0<1;1,0>:ud    0x20:uw              {I@6}
(f1.0)  goto (32|M0)                         L7024                  L7024                
L6960:
        add (16|M0)              r4.0<1>:d     r14.0<1;1,0>:d    -32:w               {Compacted}
        add (16|M16)             r12.0<1>:d    r2.0<1;1,0>:d     -32:w               {Compacted}
        shr (16|M0)              r18.0<1>:ud   r42.0<1;1,0>:ud   r4.0<1;1,0>:d    {A@1}
        shr (16|M16)             r54.0<1>:ud   r40.0<1;1,0>:ud   r12.0<1;1,0>:d   {I@2}
        goto (32|M0)                         L7024                  L7120                
L7024:
        join (32|M0)                         L7120                                
L7040:
        add (16|M0)              r4.0<1>:d     -r14.0<1;1,0>:d   32:w               {Compacted}
        add (16|M16)             r12.0<1>:d    -r2.0<1;1,0>:d    32:w               {Compacted}
        shr (16|M16)             r16.0<1>:ud   r44.0<1;1,0>:ud   r2.0<1;1,0>:d   
        shl (16|M0)              r4.0<1>:d     r42.0<1;1,0>:d    r4.0<1;1,0>:d    {Compacted,I@3}
        shr (16|M0)              r14.0<1>:ud   r48.0<1;1,0>:ud   r14.0<1;1,0>:d  
        shl (16|M16)             r12.0<1>:d    r40.0<1;1,0>:d    r12.0<1;1,0>:d   {Compacted,I@4}
        or (16|M0)               r18.0<1>:d    r14.0<1;1,0>:d    r4.0<1;1,0>:d    {Compacted,I@2}
        or (16|M16)              r54.0<1>:d    r16.0<1;1,0>:d    r12.0<1;1,0>:d   {Compacted,I@2}
L7120:
        join (32|M0)                         L7800                                
L7136:
        and (16|M0)   (ne)f0.0   r4.0<1>:d     r34.0<1;1,0>:d    63:w               {Compacted}
        and (16|M16)  (ne)f0.0   r20.0<1>:d    r20.0<1;1,0>:d    63:w              
        and (16|M0)              r30.0<1>:d    r18.0<1;1,0>:d    1:w               {Compacted,I@5}
        and (16|M16)             r64.0<1>:d    r54.0<1;1,0>:d    1:w               {Compacted,I@5}
(f0.0)  goto (32|M0)                         L7272                  L7272                
L7192:
        mov (16|M0)              r4.0<1>:d     -1:w                              
        mov (16|M16)             r14.0<1>:d    -1:w                              
        mov (16|M0)              r18.0<1>:d    -1:w                              
        mov (16|M16)             r16.0<1>:d    -1:w                              
        goto (32|M0)                         L7272                  L7544                
L7272:
        join (32|M0)                         L7544                                
L7288:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r4.0<1;1,0>:ud    0x20:uw              {I@6}
        cmp (16|M16)  (lt)f1.0   null<1>:d     r20.0<1;1,0>:ud   0x20:uw             
(f1.0)  goto (32|M0)                         L7448                  L7448                
L7336:
        add (16|M0)              r4.0<1>:d     r4.0<1;1,0>:d     -32:w               {Compacted}
        add (16|M16)             r12.0<1>:d    r20.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r3.0<1>:hf    -qnan(0x1FF):hf                             
        mov (16|M16)             r14.0<1>:d    0:w                              
        shl (16|M0)              r18.0<1>:d    r3.0<0;1,0>:w     r4.0<1;1,0>:d    {A@1}
        shl (16|M16)             r16.0<1>:d    r3.0<0;1,0>:w     r12.0<1;1,0>:d   {I@3}
        mov (16|M0)              r4.0<1>:d     0:w                              
        goto (32|M0)                         L7448                  L7544                
L7448:
        join (32|M0)                         L7544                                
L7464:
(W)     mov (1|M0)               r3.0<1>:hf    -qnan(0x1FF):hf                              {I@4}
        mov (16|M0)              r18.0<1>:d    -1:w                              
        mov (16|M16)             r16.0<1>:d    -1:w                              
        shl (16|M0)              r4.0<1>:d     r3.0<0;1,0>:w     r4.0<1;1,0>:d    {A@1}
        shl (16|M16)             r14.0<1>:d    r3.0<0;1,0>:w     r20.0<1;1,0>:d  
L7544:
        join (32|M0)                         L7800                                
L7560:
        bfn.0x60 (16|M0)         r4.0<1>:ud    r4.0<1;0>:ud      r10.2<0;0>:ud     r48.0<1>:ud      {I@3} // (s0^s1)&s2
        bfn.0x60 (16|M16)        r12.0<1>:ud   r14.0<1;0>:ud     r10.2<0;0>:ud     r44.0<1>:ud      {I@3} // (s0^s1)&s2
        cmp (16|M0)   (ne)f1.0   null<1>:d     r4.0<1;1,0>:d     0:w               {I@2}
        cmp (16|M16)  (ne)f1.0   null<1>:d     r12.0<1;1,0>:d    0:w               {I@2}
        bfn.0x60 (16|M16)        r16.0<1>:ud   r16.0<1;0>:ud     r10.2<0;0>:ud     r40.0<1>:ud      // (s0^s1)&s2
        bfn.0x60 (16|M0)         r14.0<1>:ud   r18.0<1;0>:ud     r10.2<0;0>:ud     r42.0<1>:ud      // (s0^s1)&s2
(~f1.0) cmp (16|M16)  (ne)f1.0   null<1>:d     r16.0<1;1,0>:d    0:w               {I@2}
(~f1.0) cmp (16|M0)   (ne)f1.0   null<1>:d     r14.0<1;1,0>:d    0:w               {I@2}
(W)     mov (1|M0)               r3.0<1>:hf    -qnan(0x1FF):hf                             
        mov (16|M0)              r34.0<1>:f    r68.0<1;1,0>:f                   {Compacted}
(f1.0)  sel (16|M0)              r18.0<1>:d    r3.0<0;1,0>:w     0:w               {F@2}
(f1.0)  sel (16|M16)             r20.0<1>:d    r3.0<0;1,0>:w     0:w              
        mov (16|M16)             r62.0<1>:f    r70.0<1;1,0>:f                   {Compacted}
        mov (16|M0)              r52.0<1>:d    -r18.0<1;1,0>:d                  {I@2}
        mov (16|M16)             r66.0<1>:d    -r20.0<1;1,0>:d                  {I@2}
        goto (32|M0)                         L7800                  L7896                
L7800:
        join (32|M0)                         L7896                                
L7816:
        mov (16|M0)              r52.0<1>:d    0:w                              
        mov (16|M16)             r66.0<1>:d    0:w                              
        mov (16|M0)              r30.0<1>:d    0:w                              
        mov (16|M16)             r64.0<1>:d    0:w                              
        mov (16|M0)              r34.0<1>:f    r48.0<1;1,0>:f                   {Compacted}
        mov (16|M16)             r62.0<1>:f    r44.0<1;1,0>:f                   {Compacted}
L7896:
        join (32|M0)                         L8760                                
L7912:
        and (16|M0)   (ne)f0.0   r14.0<1>:d    r38.0<1;1,0>:d    63:w               {Compacted}
        and (16|M16)  (ne)f0.0   r2.0<1>:d     r6.0<1;1,0>:d     63:w              
(f0.0)  goto (32|M0)                         L7992                  L7992                
L7952:
        mov (16|M0)              r18.0<1>:f    r48.0<1;1,0>:f                   {Compacted}
        mov (16|M16)             r54.0<1>:d    r44.0<1;1,0>:d                  
        goto (32|M0)                         L7992                  L8216                
L7992:
        join (32|M0)                         L8216                                
L8008:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r14.0<1;1,0>:ud   0x20:uw              {I@6}
        cmp (16|M16)  (lt)f1.0   null<1>:d     r2.0<1;1,0>:ud    0x20:uw              {I@6}
(f1.0)  goto (32|M0)                         L8120                  L8120                
L8056:
        add (16|M0)              r4.0<1>:d     r14.0<1;1,0>:d    -32:w               {Compacted}
        add (16|M16)             r12.0<1>:d    r2.0<1;1,0>:d     -32:w               {Compacted}
        shr (16|M0)              r18.0<1>:ud   r42.0<1;1,0>:ud   r4.0<1;1,0>:d    {A@1}
        shr (16|M16)             r54.0<1>:ud   r40.0<1;1,0>:ud   r12.0<1;1,0>:d   {I@2}
        goto (32|M0)                         L8120                  L8216                
L8120:
        join (32|M0)                         L8216                                
L8136:
        add (16|M0)              r4.0<1>:d     -r14.0<1;1,0>:d   32:w               {Compacted}
        add (16|M16)             r12.0<1>:d    -r2.0<1;1,0>:d    32:w               {Compacted}
        shr (16|M16)             r16.0<1>:ud   r44.0<1;1,0>:ud   r2.0<1;1,0>:d   
        shl (16|M0)              r4.0<1>:d     r42.0<1;1,0>:d    r4.0<1;1,0>:d    {Compacted,I@3}
        shr (16|M0)              r14.0<1>:ud   r48.0<1;1,0>:ud   r14.0<1;1,0>:d  
        shl (16|M16)             r12.0<1>:d    r40.0<1;1,0>:d    r12.0<1;1,0>:d   {Compacted,I@4}
        or (16|M0)               r18.0<1>:d    r14.0<1;1,0>:d    r4.0<1;1,0>:d    {Compacted,I@2}
        or (16|M16)              r54.0<1>:d    r16.0<1;1,0>:d    r12.0<1;1,0>:d   {Compacted,I@2}
L8216:
        join (32|M0)                         L8760                                
L8232:
        shl (16|M0)              r4.0<1>:d     r34.0<1;1,0>:d    2:w               {Compacted}
        shl (16|M16)             r12.0<1>:d    r62.0<1;1,0>:d    2:w               {Compacted}
        shl (16|M0)              r14.0<1>:d    r30.0<1;1,0>:d    1:w               {Compacted}
        shl (16|M16)             r16.0<1>:d    r64.0<1;1,0>:d    1:w               {Compacted}
        and (16|M0)              r4.0<1>:d     r4.0<1;1,0>:d     4:w               {Compacted,I@4}
        and (16|M16)             r12.0<1>:d    r12.0<1;1,0>:d    4:w               {Compacted,I@4}
        bfn.0xFE (16|M0)         r14.0<1>:ud   r4.0<1;0>:ud      r14.0<1;0>:ud     r52.0<1>:ud      {I@2} // s0|s1|s2
        bfn.0xFE (16|M16)        r4.0<1>:ud    r12.0<1;0>:ud     r16.0<1;0>:ud     r66.0<1>:ud      {I@2} // s0|s1|s2
        cmp (16|M0)   (eq)f0.0   null<1>:d     r14.0<1;1,0>:d    0:w               {Compacted,I@2}
        cmp (16|M16)  (eq)f0.0   null<1>:d     r4.0<1;1,0>:d     0:w               {I@2}
(~f0.0) goto (32|M0)                         L8400                  L8400                
L8352:
        mov (16|M0)              r12.0<1>:d    0:w                              
        mov (16|M16)             r6.0<1>:d     0:w                              
        goto (32|M0)                         L8400                  L8632                
L8400:
        join (32|M0)                         L8632                                
L8416:
        cmp (16|M0)   (gt)f1.0   null<1>:d     r14.0<1;1,0>:ud   0x4:uw             
        cmp (16|M16)  (gt)f1.0   null<1>:d     r4.0<1;1,0>:ud    0x4:uw             
(~f1.0) goto (32|M0)                         L8512                  L8512                
L8464:
        mov (16|M0)              r12.0<1>:d    1:w                              
        mov (16|M16)             r6.0<1>:d     1:w                              
        goto (32|M0)                         L8512                  L8632                
L8512:
        join (32|M0)                         L8632                                
L8528:
        and (16|M0)   (ne)f0.0   null<1>:d     r18.0<1;1,0>:d    1:w               {Compacted}
        and (16|M16)  (ne)f0.0   null<1>:d     r54.0<1;1,0>:d    1:w              
(f0.0)  cmp (16|M0)   (eq)f0.0   null<1>:d     r14.0<1;1,0>:d    4:w              
(f0.0)  cmp (16|M16)  (eq)f0.0   null<1>:d     r4.0<1;1,0>:d     4:w              
(W)     mov (1|M0)               r3.0<1>:hf    0x1:hf                             
(f0.0)  sel (16|M0)              r12.0<1>:d    r3.0<0;1,0>:w     0:w               {F@1}
(f0.0)  sel (16|M16)             r6.0<1>:d     r3.0<0;1,0>:w     0:w              
L8632:
        join (32|M0)                         L8760                                
L8648:
        add (16|M0)              r4.0<1>:d     r12.0<1;1,0>:d    r18.0<1;1,0>:d   {Compacted,I@3}
        add (16|M16)             r12.0<1>:d    r6.0<1;1,0>:d     r54.0<1;1,0>:d   {Compacted,I@3}
        cmp (16|M0)   (gt)f1.0   null<1>:d     r4.0<1;1,0>:ud    0x7FFFFF:ud              {I@2}
        cmp (16|M16)  (gt)f1.0   null<1>:d     r12.0<1;1,0>:ud   0x7FFFFF:ud              {I@2}
(W)     mov (1|M0)               r3.0<1>:f     0x800000:f                               {Compacted}
(~f1.0) sel (16|M0)              r30.0<1>:d    r4.0<1;1,0>:d     0:w              
(~f1.0) sel (16|M16)             r74.0<1>:d    r12.0<1;1,0>:d    0:w              
(f1.0)  sel (16|M0)              r18.0<1>:d    r3.0<0;1,0>:d     0:w               {Compacted,F@1}
(f1.0)  sel (16|M16)             r72.0<1>:d    r3.0<0;1,0>:d     0:w              
L8760:
        join (32|M0)                         L8864                                
L8776:
        and (16|M0)              r4.0<1>:d     r22.0<1;1,0>:d    -2147483648:d              
        and (16|M16)             r12.0<1>:d    r26.0<1;1,0>:d    -2147483648:d              
        bfn.0xFE (16|M0)         r22.0<1>:ud   r4.0<1;0>:ud      r18.0<1;0>:ud     r30.0<1>:ud      {I@2} // s0|s1|s2
        sync.nop                             null                             {Compacted,$0.src}
        bfn.0xFE (16|M16)        r28.0<1>:ud   r12.0<1;0>:ud     r72.0<1;0>:ud     r74.0<1>:ud      {I@2} // s0|s1|s2
        goto (32|M0)                         L8864                  L14048                
L8864:
        join (32|M0)                         L9616                                
L8880:
        and (16|M0)   (ne)f0.0   r4.0<1>:d     r30.0<1;1,0>:d    63:w               {Compacted}
        and (16|M16)  (ne)f0.0   r16.0<1>:d    r24.0<1;1,0>:d    63:w              
(f0.0)  goto (32|M0)                         L9000                  L9000                
L8920:
        mov (16|M0)              r4.0<1>:d     -1:w                              
        mov (16|M16)             r14.0<1>:d    -1:w                              
        mov (16|M0)              r20.0<1>:d    -1:w                              
        mov (16|M16)             r6.0<1>:d     -1:w                              
        goto (32|M0)                         L9000                  L9272                
L9000:
        join (32|M0)                         L9272                                
L9016:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r4.0<1;1,0>:ud    0x20:uw              {I@6}
        cmp (16|M16)  (lt)f1.0   null<1>:d     r16.0<1;1,0>:ud   0x20:uw             
(f1.0)  goto (32|M0)                         L9176                  L9176                
L9064:
        add (16|M0)              r4.0<1>:d     r4.0<1;1,0>:d     -32:w               {Compacted}
        add (16|M16)             r12.0<1>:d    r16.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r3.0<1>:hf    -qnan(0x1FF):hf                             
        mov (16|M16)             r14.0<1>:d    0:w                              
        shl (16|M0)              r20.0<1>:d    r3.0<0;1,0>:w     r4.0<1;1,0>:d    {A@1}
        shl (16|M16)             r6.0<1>:d     r3.0<0;1,0>:w     r12.0<1;1,0>:d   {I@3}
        mov (16|M0)              r4.0<1>:d     0:w                              
        goto (32|M0)                         L9176                  L9272                
L9176:
        join (32|M0)                         L9272                                
L9192:
(W)     mov (1|M0)               r3.0<1>:hf    -qnan(0x1FF):hf                              {I@4}
        mov (16|M0)              r20.0<1>:d    -1:w                              
        mov (16|M16)             r6.0<1>:d     -1:w                              
        shl (16|M0)              r4.0<1>:d     r3.0<0;1,0>:w     r4.0<1;1,0>:d    {A@1}
        shl (16|M16)             r14.0<1>:d    r3.0<0;1,0>:w     r16.0<1;1,0>:d  
L9272:
        join (32|M0)                         L9616                                
L9288:
        bfn.0x60 (16|M0)         r4.0<1>:ud    r4.0<1;0>:ud      r10.2<0;0>:ud     r48.0<1>:ud      {I@3} // (s0^s1)&s2
        bfn.0x60 (16|M16)        r12.0<1>:ud   r14.0<1;0>:ud     r10.2<0;0>:ud     r44.0<1>:ud      {I@3} // (s0^s1)&s2
        cmp (16|M0)   (ne)f1.0   null<1>:d     r4.0<1;1,0>:d     0:w               {I@2}
        cmp (16|M16)  (ne)f1.0   null<1>:d     r12.0<1;1,0>:d    0:w               {I@2}
        bfn.0x60 (16|M16)        r16.0<1>:ud   r6.0<1;0>:ud      r10.2<0;0>:ud     r40.0<1>:ud      // (s0^s1)&s2
        bfn.0x60 (16|M0)         r14.0<1>:ud   r20.0<1;0>:ud     r10.2<0;0>:ud     r42.0<1>:ud      // (s0^s1)&s2
        cmp (16|M0)   (gt)f0.0   null<1>:d     r22.0<1;1,0>:d    -1:w               {Compacted}
        cmp (16|M16)  (gt)f0.0   null<1>:d     r26.0<1;1,0>:d    -1:w              
(~f1.0) cmp (16|M16)  (ne)f1.0   null<1>:d     r16.0<1;1,0>:d    0:w               {I@4}
(~f1.0) cmp (16|M0)   (ne)f1.0   null<1>:d     r14.0<1;1,0>:d    0:w               {I@4}
(f1.0)  cmp (16|M16)  (eq)f1.0   null<1>:d     r56.0<1;1,0>:d    -150:w              
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r18.0<1;1,0>:d    -150:w              
(f0.0)  goto (32|M0)                         L9544                  L9544                
L9488:
(W)     mov (1|M0)               r3.0<1>:ud    0x80000001:ud                             
(f1.0)  sel (16|M0)              r22.0<1>:f    r3.0<0;1,0>:f     -0.0:f               {Compacted,I@1}
(f1.0)  sel (16|M16)             r28.0<1>:f    r3.0<0;1,0>:f     -0.0:f               {$0.src}
        goto (32|M0)                         L9544                  L14048                
L9544:
        join (32|M0)                         L9616                                
L9560:
(W)     mov (1|M0)               r3.0<1>:ud    0x1:ud                              {F@1}
(f1.0)  sel (16|M0)              r22.0<1>:f    r3.0<0;1,0>:f     0.0:f               {Compacted,I@1}
(f1.0)  sel (16|M16)             r28.0<1>:f    r3.0<0;1,0>:f     0.0:f               {$0.src}
        goto (32|M0)                         L9616                  L14048                
L9616:
        join (32|M0)                         L13728                                
L9632:
        cmp (16|M16)  (lt)f0.0   null<1>:d     r24.0<1;1,0>:ud   0x18:uw             
        cmp (16|M16)  (eq)f1.0   null<1>:d     r80.0<1;1,0>:d    0:w               {F@1}
        cmp (16|M0)   (lt)f1.0   null<1>:d     r30.0<1;1,0>:ud   0x18:uw             
(W)     mov (1|M0)               r3.0<1>:hf    0x1:hf                             
        add3 (16|M0)             r60.0<1>:d    r52.0<1;0>:d      r30.0<1;0>:d      -46:w              
(f1.0)  sel (16|M16)             acc0.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw              {F@1}
(f0.0)  sel (16|M16)             acc2.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw             
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r68.0<1;1,0>:d    0:w              
        and (16|M16)  (ne)f1.0   null<1>:uw    acc0.0<1;1,0>:uw  acc2.0<1;1,0>:uw
        add3 (16|M16)            r64.0<1>:d    r50.0<1;0>:d      r24.0<1;0>:d      -46:w              
(f1.0)  goto (32|M0)                         L13264                  L13264                
L9808:
        shl (16|M16)             r12.0<1>:d    r36.0<1;1,0>:d    1:w               {Compacted}
        shl (16|M0)              r4.0<1>:d     r38.0<1;1,0>:d    1:w               {Compacted}
        shr (16|M16)             r16.0<1>:ud   r36.0<1;1,0>:ud   31:w              
        shl (16|M16)             r20.0<1>:d    r32.0<1;1,0>:d    1:w               {Compacted}
        cmp (16|M16)  (lt)f1.0   null<1>:d     r12.0<1;1,0>:ud   0x4E:uw              {I@4}
        shr (16|M0)              r14.0<1>:ud   r38.0<1;1,0>:ud   31:w              
        shl (16|M0)              r18.0<1>:d    r34.0<1;1,0>:d    1:w               {Compacted}
        cmp (16|M0)   (lt)f0.0   null<1>:d     r4.0<1;1,0>:ud    0x4E:uw              {I@6}
        or (16|M16)              r20.0<1>:d    r20.0<1;1,0>:d    r16.0<1;1,0>:d   {Compacted,I@5}
        or (16|M0)               r18.0<1>:d    r18.0<1;1,0>:d    r14.0<1;1,0>:d   {Compacted,I@3}
(f1.0)  cmp (16|M16)  (eq)f1.0   null<1>:d     r20.0<1;1,0>:d    0:w               {I@2}
        cmp (16|M16)  (lt)f0.0   null<1>:d     r20.0<1;1,0>:d    0:w              
(W)     mov (1|M0)               r3.0<1>:hf    0x1:hf                             
(f0.0)  cmp (16|M0)   (eq)f0.0   null<1>:d     r18.0<1;1,0>:d    0:w               {I@3}
(f0.0)  sel (16|M16)             acc0.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw              {F@1}
(f1.0)  sel (16|M16)             acc2.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw             
(~f0.0) cmp (16|M0)   (lt)f0.0   null<1>:d     r18.0<1;1,0>:d    0:w              
        or (16|M16)   (ne)f0.0   null<1>:uw    acc0.0<1;1,0>:uw  acc2.0<1;1,0>:uw
(f0.0)  goto (32|M0)                         L10344                  L10344                
L10064:
        cmp (16|M16)  (eq)f1.0   null<1>:d     r36.0<1;1,0>:d    39:w              
        cmp (16|M16)  (eq)f0.0   null<1>:d     r32.0<1;1,0>:d    0:w              
        cmp (16|M0)   (eq)f0.0   null<1>:d     r38.0<1;1,0>:d    39:w               {Compacted}
(W)     mov (1|M0)               r3.0<1>:hf    0x1:hf                              {I@7}
(f0.0)  sel (16|M16)             acc0.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw              {F@1}
(f1.0)  sel (16|M16)             acc2.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw             
(f0.0)  cmp (16|M0)   (eq)f0.0   null<1>:d     r34.0<1;1,0>:d    0:w              
        and (16|M16)  (ne)f0.0   null<1>:uw    acc0.0<1;1,0>:uw  acc2.0<1;1,0>:uw
(~f0.0) goto (32|M0)                         L10344                  L10504                
L10200:
        shr (16|M0)              r18.0<1>:ud   r48.0<1;1,0>:ud   1:w              
        shr (16|M16)             r54.0<1>:ud   r44.0<1;1,0>:ud   1:w              
        mov (16|M0)              r62.0<1>:d    0:w                              
        mov (16|M16)             r58.0<1>:d    0:w                              
        mov (16|M0)              r38.0<1>:d    0:w                              
        mov (16|M16)             r56.0<1>:d    0:w                              
        mov (16|M0)              r42.0<1>:f    r18.0<1;1,0>:f                   {Compacted,I@6}
        mov (16|M16)             r6.0<1>:f     r54.0<1;1,0>:f                   {Compacted,I@5}
        mov (16|M0)              r18.0<1>:f    r48.0<1;1,0>:f                   {Compacted}
        mov (16|M16)             r54.0<1>:f    r44.0<1;1,0>:f                   {Compacted}
        goto (32|M0)                         L10344                  L12424                
L10344:
        join (32|M0)                         L10504                                
L10360:
        cmp (16|M16)  (eq)f0.0   null<1>:d     r36.0<1;1,0>:d    38:w              
        cmp (16|M16)  (eq)f1.0   null<1>:d     r32.0<1;1,0>:d    0:w              
        cmp (16|M0)   (eq)f1.0   null<1>:d     r38.0<1;1,0>:d    38:w               {I@6}
(W)     mov (1|M0)               r3.0<1>:hf    0x1:hf                             
(f1.0)  sel (16|M16)             acc0.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw              {F@1}
(f0.0)  sel (16|M16)             acc2.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw             
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r34.0<1;1,0>:d    0:w              
        and (16|M16)  (ne)f1.0   null<1>:uw    acc0.0<1;1,0>:uw  acc2.0<1;1,0>:uw
(f1.0)  goto (32|M0)                         L10504                  L12264                
L10504:
        join (32|M0)                         L12264                                
L10520:
        add (16|M0)              r4.0<1>:d     -r38.0<1;1,0>:d   39:w               {Compacted}
        add (16|M16)             r12.0<1>:d    -r36.0<1;1,0>:d   39:w               {Compacted}
        and (16|M0)   (ne)f0.0   r14.0<1>:d    r4.0<1;1,0>:d     63:w               {Compacted,I@2}
        and (16|M16)  (ne)f0.0   r2.0<1>:d     r12.0<1;1,0>:d    63:w               {I@2}
        add (16|M0)              r66.0<1>:d    -r38.0<1;1,0>:d   40:w               {Compacted}
        add (16|M16)             r68.0<1>:d    -r36.0<1;1,0>:d   40:w               {Compacted}
(f0.0)  goto (32|M0)                         L10632                  L10632                
L10592:
        mov (16|M0)              r34.0<1>:f    r48.0<1;1,0>:f                   {Compacted}
        mov (16|M16)             r32.0<1>:d    r44.0<1;1,0>:d                  
        goto (32|M0)                         L10632                  L10896                
L10632:
        join (32|M0)                         L10896                                
L10648:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r14.0<1;1,0>:ud   0x20:uw              {I@7}
        cmp (16|M16)  (lt)f1.0   null<1>:d     r2.0<1;1,0>:ud    0x20:uw              {I@7}
(f1.0)  goto (32|M0)                         L10760                  L10760                
L10696:
        add (16|M0)              r4.0<1>:d     r14.0<1;1,0>:d    -32:w               {Compacted}
        add (16|M16)             r12.0<1>:d    r2.0<1;1,0>:d     -32:w               {Compacted}
        shr (16|M0)              r18.0<1>:ud   r42.0<1;1,0>:ud   r4.0<1;1,0>:d    {I@2}
        shr (16|M16)             r54.0<1>:ud   r40.0<1;1,0>:ud   r12.0<1;1,0>:d   {I@2}
        goto (32|M0)                         L10760                  L10856                
L10760:
        join (32|M0)                         L10856                                
L10776:
        add (16|M0)              r4.0<1>:d     -r14.0<1;1,0>:d   32:w               {Compacted}
        add (16|M16)             r12.0<1>:d    -r2.0<1;1,0>:d    32:w               {Compacted}
        shr (16|M16)             r16.0<1>:ud   r44.0<1;1,0>:ud   r2.0<1;1,0>:d   
        shl (16|M0)              r4.0<1>:d     r42.0<1;1,0>:d    r4.0<1;1,0>:d    {Compacted,I@3}
        shr (16|M0)              r14.0<1>:ud   r48.0<1;1,0>:ud   r14.0<1;1,0>:d  
        shl (16|M16)             r12.0<1>:d    r40.0<1;1,0>:d    r12.0<1;1,0>:d   {Compacted,I@4}
        or (16|M0)               r18.0<1>:d    r14.0<1;1,0>:d    r4.0<1;1,0>:d    {Compacted,I@2}
        or (16|M16)              r54.0<1>:d    r16.0<1;1,0>:d    r12.0<1;1,0>:d   {Compacted,I@2}
L10856:
        join (32|M0)                         L10896                                
L10872:
        mov (16|M0)              r34.0<1>:f    r18.0<1;1,0>:f                   {Compacted,I@3}
        mov (16|M16)             r32.0<1>:d    r54.0<1;1,0>:d                   {I@2}
L10896:
        join (32|M0)                         L12264                                
L10912:
        add (16|M0)              r20.0<1>:d    -r38.0<1;1,0>:d   38:w               {Compacted}
        add (16|M16)             r2.0<1>:d     -r36.0<1;1,0>:d   38:w               {Compacted}
        and (16|M0)   (ne)f0.0   r14.0<1>:d    r20.0<1;1,0>:d    63:w               {Compacted,I@2}
        and (16|M16)  (ne)f0.0   r16.0<1>:d    r2.0<1;1,0>:d     63:w               {I@2}
(f0.0)  goto (32|M0)                         L11008                  L11008                
L10968:
        mov (16|M0)              r18.0<1>:f    r48.0<1;1,0>:f                   {Compacted}
        mov (16|M16)             r54.0<1>:d    r44.0<1;1,0>:d                  
        goto (32|M0)                         L11008                  L11232                
L11008:
        join (32|M0)                         L11232                                
L11024:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r14.0<1;1,0>:ud   0x20:uw              {I@6}
        cmp (16|M16)  (lt)f1.0   null<1>:d     r16.0<1;1,0>:ud   0x20:uw              {I@6}
(f1.0)  goto (32|M0)                         L11136                  L11136                
L11072:
        add (16|M0)              r4.0<1>:d     r14.0<1;1,0>:d    -32:w               {Compacted}
        add (16|M16)             r12.0<1>:d    r16.0<1;1,0>:d    -32:w               {Compacted}
        shr (16|M0)              r18.0<1>:ud   r42.0<1;1,0>:ud   r4.0<1;1,0>:d    {A@1}
        shr (16|M16)             r54.0<1>:ud   r40.0<1;1,0>:ud   r12.0<1;1,0>:d   {I@2}
        goto (32|M0)                         L11136                  L11232                
L11136:
        join (32|M0)                         L11232                                
L11152:
        add (16|M0)              r4.0<1>:d     -r14.0<1;1,0>:d   32:w               {Compacted}
        add (16|M16)             r12.0<1>:d    -r16.0<1;1,0>:d   32:w               {Compacted}
        shl (16|M0)              r4.0<1>:d     r42.0<1;1,0>:d    r4.0<1;1,0>:d    {Compacted,I@2}
        shr (16|M0)              r14.0<1>:ud   r48.0<1;1,0>:ud   r14.0<1;1,0>:d  
        shl (16|M16)             r12.0<1>:d    r40.0<1;1,0>:d    r12.0<1;1,0>:d   {Compacted,I@3}
        shr (16|M16)             r16.0<1>:ud   r44.0<1;1,0>:ud   r16.0<1;1,0>:d  
        or (16|M0)               r18.0<1>:d    r14.0<1;1,0>:d    r4.0<1;1,0>:d    {Compacted,I@3}
        or (16|M16)              r54.0<1>:d    r16.0<1;1,0>:d    r12.0<1;1,0>:d   {Compacted,I@2}
L11232:
        join (32|M0)                         L12264                                
L11248:
        and (16|M0)   (ne)f0.0   r4.0<1>:d     r20.0<1;1,0>:d    63:w               {Compacted}
        and (16|M16)  (ne)f0.0   r20.0<1>:d    r2.0<1;1,0>:d     63:w              
        and (16|M0)              r38.0<1>:d    r18.0<1;1,0>:d    1:w               {Compacted,I@5}
        and (16|M16)             r56.0<1>:d    r54.0<1;1,0>:d    1:w               {Compacted,I@5}
(f0.0)  goto (32|M0)                         L11384                  L11384                
L11304:
        mov (16|M0)              r4.0<1>:d     -1:w                              
        mov (16|M16)             r14.0<1>:d    -1:w                              
        mov (16|M0)              r18.0<1>:d    -1:w                              
        mov (16|M16)             r16.0<1>:d    -1:w                              
        goto (32|M0)                         L11384                  L11656                
L11384:
        join (32|M0)                         L11656                                
L11400:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r4.0<1;1,0>:ud    0x20:uw              {I@6}
        cmp (16|M16)  (lt)f1.0   null<1>:d     r20.0<1;1,0>:ud   0x20:uw             
(f1.0)  goto (32|M0)                         L11560                  L11560                
L11448:
        add (16|M0)              r4.0<1>:d     r4.0<1;1,0>:d     -32:w               {Compacted}
        add (16|M16)             r12.0<1>:d    r20.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r3.0<1>:hf    -qnan(0x1FF):hf                             
        mov (16|M16)             r14.0<1>:d    0:w                              
        shl (16|M0)              r18.0<1>:d    r3.0<0;1,0>:w     r4.0<1;1,0>:d    {A@1}
        shl (16|M16)             r16.0<1>:d    r3.0<0;1,0>:w     r12.0<1;1,0>:d   {I@3}
        mov (16|M0)              r4.0<1>:d     0:w                              
        goto (32|M0)                         L11560                  L11656                
L11560:
        join (32|M0)                         L11656                                
L11576:
(W)     mov (1|M0)               r3.0<1>:hf    -qnan(0x1FF):hf                              {I@4}
        mov (16|M0)              r18.0<1>:d    -1:w                              
        mov (16|M16)             r16.0<1>:d    -1:w                              
        shl (16|M0)              r4.0<1>:d     r3.0<0;1,0>:w     r4.0<1;1,0>:d    {A@1}
        shl (16|M16)             r14.0<1>:d    r3.0<0;1,0>:w     r20.0<1;1,0>:d  
L11656:
        join (32|M0)                         L12264                                
L11672:
        bfn.0x60 (16|M0)         r4.0<1>:ud    r4.0<1;0>:ud      r10.2<0;0>:ud     r48.0<1>:ud      {I@3} // (s0^s1)&s2
        bfn.0x60 (16|M16)        r12.0<1>:ud   r14.0<1;0>:ud     r10.2<0;0>:ud     r44.0<1>:ud      {I@3} // (s0^s1)&s2
        cmp (16|M0)   (ne)f1.0   null<1>:d     r4.0<1;1,0>:d     0:w               {I@2}
        cmp (16|M16)  (ne)f1.0   null<1>:d     r12.0<1;1,0>:d    0:w               {I@2}
        bfn.0x60 (16|M16)        r16.0<1>:ud   r16.0<1;0>:ud     r10.2<0;0>:ud     r40.0<1>:ud      // (s0^s1)&s2
        bfn.0x60 (16|M0)         r14.0<1>:ud   r18.0<1;0>:ud     r10.2<0;0>:ud     r42.0<1>:ud      // (s0^s1)&s2
(~f1.0) cmp (16|M16)  (ne)f1.0   null<1>:d     r16.0<1;1,0>:d    0:w               {I@2}
(~f1.0) cmp (16|M0)   (ne)f1.0   null<1>:d     r14.0<1;1,0>:d    0:w               {I@2}
(W)     mov (1|M0)               r3.0<1>:hf    -qnan(0x1FF):hf                             
        and (16|M0)   (ne)f0.0   r14.0<1>:d    r66.0<1;1,0>:d    63:w               {Compacted}
(f1.0)  sel (16|M0)              r18.0<1>:d    r3.0<0;1,0>:w     0:w               {F@1}
(f1.0)  sel (16|M16)             r20.0<1>:d    r3.0<0;1,0>:w     0:w              
        and (16|M16)  (ne)f0.0   r2.0<1>:d     r68.0<1;1,0>:d    63:w              
        mov (16|M0)              r62.0<1>:d    -r18.0<1;1,0>:d                  {I@3}
        mov (16|M16)             r58.0<1>:d    -r20.0<1;1,0>:d                  {I@3}
(f0.0)  goto (32|M0)                         L11960                  L11960                
L11920:
        mov (16|M0)              r18.0<1>:f    r48.0<1;1,0>:f                   {Compacted,I@3}
        mov (16|M16)             r54.0<1>:d    r44.0<1;1,0>:d                  
        goto (32|M0)                         L11960                  L12184                
L11960:
        join (32|M0)                         L12184                                
L11976:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r14.0<1;1,0>:ud   0x20:uw             
        cmp (16|M16)  (lt)f1.0   null<1>:d     r2.0<1;1,0>:ud    0x20:uw             
(f1.0)  goto (32|M0)                         L12088                  L12088                
L12024:
        add (16|M0)              r4.0<1>:d     r14.0<1;1,0>:d    -32:w               {Compacted}
        add (16|M16)             r12.0<1>:d    r2.0<1;1,0>:d     -32:w               {Compacted}
        shr (16|M0)              r18.0<1>:ud   r42.0<1;1,0>:ud   r4.0<1;1,0>:d    {A@1}
        shr (16|M16)             r54.0<1>:ud   r40.0<1;1,0>:ud   r12.0<1;1,0>:d   {I@2}
        goto (32|M0)                         L12088                  L12184                
L12088:
        join (32|M0)                         L12184                                
L12104:
        add (16|M0)              r4.0<1>:d     -r14.0<1;1,0>:d   32:w               {Compacted}
        add (16|M16)             r12.0<1>:d    -r2.0<1;1,0>:d    32:w               {Compacted}
        shr (16|M16)             r16.0<1>:ud   r44.0<1;1,0>:ud   r2.0<1;1,0>:d   
        shl (16|M0)              r4.0<1>:d     r42.0<1;1,0>:d    r4.0<1;1,0>:d    {Compacted,I@3}
        shr (16|M0)              r14.0<1>:ud   r48.0<1;1,0>:ud   r14.0<1;1,0>:d  
        shl (16|M16)             r12.0<1>:d    r40.0<1;1,0>:d    r12.0<1;1,0>:d   {Compacted,I@4}
        or (16|M0)               r18.0<1>:d    r14.0<1;1,0>:d    r4.0<1;1,0>:d    {Compacted,I@2}
        or (16|M16)              r54.0<1>:d    r16.0<1;1,0>:d    r12.0<1;1,0>:d   {Compacted,I@2}
L12184:
        join (32|M0)                         L12264                                
L12200:
        mov (16|M0)              r42.0<1>:f    r18.0<1;1,0>:f                   {Compacted,I@3}
        mov (16|M16)             r6.0<1>:f     r54.0<1;1,0>:f                   {Compacted,I@2}
        mov (16|M0)              r18.0<1>:d    r34.0<1;1,0>:d                   {F@2}
        mov (16|M16)             r54.0<1>:d    r32.0<1;1,0>:d                   {F@1}
        goto (32|M0)                         L12264                  L12424                
L12264:
        join (32|M0)                         L12424                                
L12280:
        shr (16|M0)              r18.0<1>:ud   r48.0<1;1,0>:ud   2:w              
        shr (16|M16)             r54.0<1>:ud   r44.0<1;1,0>:ud   2:w              
        mov (16|M0)              r62.0<1>:d    0:w                              
        mov (16|M16)             r58.0<1>:d    0:w                              
        mov (16|M0)              r38.0<1>:d    0:w                              
        mov (16|M16)             r56.0<1>:d    0:w                              
        mov (16|M0)              r42.0<1>:f    r18.0<1;1,0>:f                   {Compacted,I@6}
        mov (16|M16)             r6.0<1>:f     r54.0<1;1,0>:f                   {Compacted,I@5}
        shr (16|M0)              r18.0<1>:ud   r48.0<1;1,0>:ud   1:w               {F@2}
        shr (16|M16)             r54.0<1>:ud   r44.0<1;1,0>:ud   1:w               {F@1}
L12424:
        join (32|M0)                         L13264                                
L12440:
        shl (16|M0)              r4.0<1>:d     r18.0<1;1,0>:d    2:w               {Compacted,I@3}
        shl (16|M16)             r12.0<1>:d    r54.0<1;1,0>:d    2:w               {Compacted,I@3}
        shl (16|M0)              r14.0<1>:d    r38.0<1;1,0>:d    1:w               {Compacted}
        shl (16|M16)             r16.0<1>:d    r56.0<1;1,0>:d    1:w               {Compacted}
        and (16|M0)              r4.0<1>:d     r4.0<1;1,0>:d     4:w               {Compacted,I@4}
        and (16|M16)             r12.0<1>:d    r12.0<1;1,0>:d    4:w               {Compacted,I@4}
        bfn.0xFE (16|M0)         r4.0<1>:ud    r4.0<1;0>:ud      r14.0<1;0>:ud     r62.0<1>:ud      {I@2} // s0|s1|s2
        bfn.0xFE (16|M16)        r14.0<1>:ud   r12.0<1;0>:ud     r16.0<1;0>:ud     r58.0<1>:ud      {I@2} // s0|s1|s2
        cmp (16|M0)   (eq)f0.0   null<1>:d     r4.0<1;1,0>:d     0:w               {Compacted,I@2}
        cmp (16|M16)  (eq)f0.0   null<1>:d     r14.0<1;1,0>:d    0:w               {I@2}
        and (16|M0)              r32.0<1>:d    r42.0<1;1,0>:d    8388607:d              
        and (16|M16)             r20.0<1>:d    r6.0<1;1,0>:d     8388607:d              
(~f0.0) goto (32|M0)                         L12640                  L12640                
L12592:
        mov (16|M0)              r4.0<1>:d     0:w                              
        mov (16|M16)             r12.0<1>:d    0:w                              
        goto (32|M0)                         L12640                  L12872                
L12640:
        join (32|M0)                         L12872                                
L12656:
        cmp (16|M0)   (gt)f1.0   null<1>:d     r4.0<1;1,0>:ud    0x4:uw              {I@4}
        cmp (16|M16)  (gt)f1.0   null<1>:d     r14.0<1;1,0>:ud   0x4:uw             
(~f1.0) goto (32|M0)                         L12752                  L12752                
L12704:
        mov (16|M0)              r4.0<1>:d     1:w                              
        mov (16|M16)             r12.0<1>:d    1:w                              
        goto (32|M0)                         L12752                  L12872                
L12752:
        join (32|M0)                         L12872                                
L12768:
        and (16|M0)   (ne)f0.0   null<1>:d     r42.0<1;1,0>:d    1:w               {Compacted}
        and (16|M16)  (ne)f0.0   null<1>:d     r6.0<1;1,0>:d     1:w              
(f0.0)  cmp (16|M0)   (eq)f0.0   null<1>:d     r4.0<1;1,0>:d     4:w               {I@6}
(f0.0)  cmp (16|M16)  (eq)f0.0   null<1>:d     r14.0<1;1,0>:d    4:w              
(W)     mov (1|M0)               r3.0<1>:hf    0x1:hf                             
(f0.0)  sel (16|M0)              r4.0<1>:d     r3.0<0;1,0>:w     0:w               {F@1}
(f0.0)  sel (16|M16)             r12.0<1>:d    r3.0<0;1,0>:w     0:w              
L12872:
        join (32|M0)                         L13264                                
L12888:
        add (16|M0)              r16.0<1>:d    r32.0<1;1,0>:d    r4.0<1;1,0>:d    {Compacted,I@3}
        add (16|M16)             r14.0<1>:d    r20.0<1;1,0>:d    r12.0<1;1,0>:d   {Compacted,I@3}
        cmp (16|M0)   (gt)f1.0   null<1>:d     r16.0<1;1,0>:ud   0x7FFFFF:ud              {I@2}
        cmp (16|M16)  (gt)f1.0   null<1>:d     r14.0<1;1,0>:ud   0x7FFFFF:ud              {I@2}
        add3 (16|M0)             r4.0<1>:d     r52.0<1;0>:d      r30.0<1;0>:d      -45:w              
        add3 (16|M16)            r12.0<1>:d    r50.0<1;0>:d      r24.0<1;0>:d      -45:w              
(f1.0)  sel (16|M0)              r6.0<1>:d     r4.0<1;1,0>:d     r60.0<1;1,0>:d   {Compacted,I@2}
(f1.0)  sel (16|M16)             r2.0<1>:d     r12.0<1;1,0>:d    r64.0<1;1,0>:d   {I@2}
        cmp (16|M0)   (eq)f0.0   null<1>:d     r6.0<1;1,0>:d     255:w               {Compacted,I@2}
        cmp (16|M16)  (eq)f0.0   null<1>:d     r2.0<1;1,0>:d     255:w               {I@2}
(f0.0)  goto (32|M0)                         L13168                  L13168                
L13032:
(~f1.0) sel (16|M0)              r4.0<1>:d     r16.0<1;1,0>:d    0:w              
(~f1.0) sel (16|M16)             r12.0<1>:d    r14.0<1;1,0>:d    0:w              
        shl (16|M0)              r18.0<1>:d    r6.0<1;1,0>:d     23:w               {Compacted}
        shl (16|M16)             r20.0<1>:d    r2.0<1;1,0>:d     23:w               {Compacted}
        and (16|M16)             r16.0<1>:d    r26.0<1;1,0>:d    -2147483648:d              
        and (16|M0)              r14.0<1>:d    r22.0<1;1,0>:d    -2147483648:d              
        sync.nop                             null                             {Compacted,$0.src}
        bfn.0xFE (16|M16)        r28.0<1>:ud   r16.0<1;0>:ud     r20.0<1;0>:ud     r12.0<1>:ud      {I@2} // s0|s1|s2
        bfn.0xFE (16|M0)         r22.0<1>:ud   r14.0<1;0>:ud     r18.0<1;0>:ud     r4.0<1>:ud       {I@2} // s0|s1|s2
        goto (32|M0)                         L13168                  L14048                
L13168:
        join (32|M0)                         L13264                                
L13184:
        cmp (16|M0)   (gt)f1.0   null<1>:d     r22.0<1;1,0>:d    -1:w               {I@3}
        cmp (16|M16)  (gt)f1.0   null<1>:d     r26.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r3.0<1>:f     inf:f                               {Compacted}
(f1.0)  sel (16|M0)              r22.0<1>:f    r3.0<0;1,0>:f     -inf:f               {Compacted,A@1}
(f1.0)  sel (16|M16)             r28.0<1>:f    r3.0<0;1,0>:f     -inf:f               {$0.src}
        goto (32|M0)                         L13264                  L14048                
L13264:
        join (32|M0)                         L13728                                
L13280:
        and (16|M0)   (ne)f0.0   r4.0<1>:d     r30.0<1;1,0>:d    63:w               {Compacted}
        and (16|M16)  (ne)f0.0   r12.0<1>:d    r24.0<1;1,0>:d    63:w              
(f0.0)  goto (32|M0)                         L13368                  L13368                
L13320:
        mov (16|M0)              r4.0<1>:d     -1:w                              
        mov (16|M16)             r6.0<1>:d     -1:w                              
        goto (32|M0)                         L13368                  L13544                
L13368:
        join (32|M0)                         L13544                                
L13384:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r4.0<1;1,0>:ud    0x20:uw              {A@1}
        cmp (16|M16)  (lt)f1.0   null<1>:d     r12.0<1;1,0>:ud   0x20:uw             
(f1.0)  goto (32|M0)                         L13480                  L13480                
L13432:
        mov (16|M0)              r4.0<1>:d     0:w                              
        mov (16|M16)             r6.0<1>:d     0:w                              
        goto (32|M0)                         L13480                  L13544                
L13480:
        join (32|M0)                         L13544                                
L13496:
(W)     mov (1|M0)               r3.0<1>:hf    -qnan(0x1FF):hf                             
        shl (16|M0)              r4.0<1>:d     r3.0<0;1,0>:w     r4.0<1;1,0>:d    {A@1}
        shl (16|M16)             r6.0<1>:d     r3.0<0;1,0>:w     r12.0<1;1,0>:d  
L13544:
        join (32|M0)                         L13728                                
L13560:
        bfn.0x60 (16|M0)         r4.0<1>:ud    r4.0<1;0>:ud      r10.2<0;0>:ud     r48.0<1>:ud      {I@3} // (s0^s1)&s2
        bfn.0x60 (16|M16)        r12.0<1>:ud   r6.0<1;0>:ud      r10.2<0;0>:ud     r44.0<1>:ud      {I@3} // (s0^s1)&s2
        add (16|M0)              r14.0<1>:d    -r30.0<1;1,0>:d   23:w               {Compacted}
        add (16|M16)             r16.0<1>:d    -r24.0<1;1,0>:d   23:w               {Compacted}
        and (16|M0)              r18.0<1>:d    r22.0<1;1,0>:d    -2147483648:d              
        and (16|M16)             r20.0<1>:d    r26.0<1;1,0>:d    -2147483648:d              
        shl (16|M0)              r4.0<1>:d     r4.0<1;1,0>:d     r14.0<1;1,0>:d   {Compacted,I@4}
        shl (16|M16)             r12.0<1>:d    r12.0<1;1,0>:d    r16.0<1;1,0>:d   {Compacted,I@4}
        shl (16|M16)             r24.0<1>:d    r64.0<1;1,0>:d    23:w               {Compacted}
        shl (16|M0)              r22.0<1>:d    r60.0<1;1,0>:d    23:w               {Compacted}
        sync.nop                             null                             {Compacted,$0.src}
        bfn.0xFE (16|M16)        r28.0<1>:ud   r20.0<1;0>:ud     r24.0<1;0>:ud     r12.0<1>:ud      {I@2} // s0|s1|s2
        bfn.0xFE (16|M0)         r22.0<1>:ud   r18.0<1;0>:ud     r22.0<1;0>:ud     r4.0<1>:ud       {I@2} // s0|s1|s2
        goto (32|M0)                         L13728                  L14048                
L13728:
        join (32|M0)                         L13816                                
L13744:
        cmp (16|M0)   (gt)f0.0   null<1>:d     r22.0<1;1,0>:d    -1:w               {Compacted,I@3}
        cmp (16|M16)  (gt)f0.0   null<1>:d     r26.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r3.0<1>:f     inf:f                               {Compacted}
(f0.0)  sel (16|M0)              r22.0<1>:f    r3.0<0;1,0>:f     -inf:f               {Compacted,A@1}
(f0.0)  sel (16|M16)             r28.0<1>:f    r3.0<0;1,0>:f     -inf:f               {$0.src}
        goto (32|M0)                         L13816                  L14048                
L13816:
        join (32|M0)                         L13904                                
L13832:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r22.0<1;1,0>:d    0:w               {Compacted,F@2}
        cmp (16|M16)  (lt)f1.0   null<1>:d     r26.0<1;1,0>:d    0:w              
(W)     mov (1|M0)               r3.0<1>:f     -0.0:f                               {Compacted}
(f1.0)  sel (16|M0)              r22.0<1>:f    r3.0<0;1,0>:f     0.0:f               {Compacted,A@1}
(f1.0)  sel (16|M16)             r28.0<1>:f    r3.0<0;1,0>:f     0.0:f               {$0.src}
        goto (32|M0)                         L13904                  L14048                
L13904:
        join (32|M0)                         L13992                                
L13920:
        cmp (16|M0)   (gt)f0.0   null<1>:d     r22.0<1;1,0>:d    -1:w               {Compacted,F@2}
        cmp (16|M16)  (gt)f0.0   null<1>:d     r26.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r3.0<1>:f     inf:f                               {Compacted}
(f0.0)  sel (16|M0)              r22.0<1>:f    r3.0<0;1,0>:f     -inf:f               {Compacted,A@1}
(f0.0)  sel (16|M16)             r28.0<1>:f    r3.0<0;1,0>:f     -inf:f               {$0.src}
        goto (32|M0)                         L13992                  L14048                
L13992:
        join (32|M0)                         L14048                                
L14008:
        bfn.0xF8 (16|M0)         r22.0<1>:ud   r22.0<1;0>:ud     r10.4<0;0>:ud     r10.3<0>:ud      {F@2} // s0&s1|s2
        sync.nop                             null                             {Compacted,$0.src}
        bfn.0xF8 (16|M16)        r28.0<1>:ud   r26.0<1;0>:ud     r10.4<0;0>:ud     r10.3<0>:ud      {F@1} // s0&s1|s2
L14048:
        join (32|M0)                         L47048                                
L14064:
        sync.nop                             null                             {Compacted,$0.src}
        rnde (16|M16)            r28.0<1>:f    r28.0<1;1,0>:f                   {Compacted,I@2}
        shr (16|M16)             r16.0<1>:ud   r28.0<1;1,0>:ud   23:w               {F@1}
        and (16|M16)             r30.0<1>:d    r16.0<1;1,0>:d    255:w               {Compacted,I@1}
        rnde (16|M0)             r6.0<1>:f     r22.0<1;1,0>:f                   {Compacted}
        and (16|M16)  (ne)f1.0   r14.0<1>:d    r28.0<1;1,0>:d    8388607:d              
        cmp (16|M16)  (eq)f0.0   null<1>:d     r30.0<1;1,0>:d    255:w               {I@2}
(W)     mov (1|M0)               r3.0<1>:hf    0x1:hf                             
        shr (16|M0)              r20.0<1>:ud   r6.0<1;1,0>:ud    23:w               {F@2}
        and (16|M0)   (ne)f0.0   r18.0<1>:d    r6.0<1;1,0>:d     8388607:d              
(f0.0)  sel (16|M16)             acc0.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw              {F@1}
(f1.0)  sel (16|M16)             acc2.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw             
        sync.nop                             null                             {Compacted,$12.src}
        and (16|M0)              r34.0<1>:d    r20.0<1;1,0>:d    255:w               {Compacted,I@4}
        and (16|M16)  (ne)f0.0   null<1>:uw    acc0.0<1;1,0>:uw  acc2.0<1;1,0>:uw
(f0.0)  cmp (16|M0)   (eq)f0.0   null<1>:d     r34.0<1;1,0>:d    255:w               {I@2}
(~f0.0) goto (32|M0)                         L14328                  L14328                
L14288:
        mov (16|M0)              r22.0<1>:ud   0x7FC00000:ud                             
        mov (16|M16)             r26.0<1>:f    qnan(0x0):f                               {Compacted,$15.src}
        goto (32|M0)                         L14328                  L24720                
L14328:
        join (32|M0)                         L24720                                
L14344:
        add (16|M16)             r12.0<1>:d    r84.0<1;1,0>:d    -25165824:d              
        cmp (16|M16)  (eq)f0.0   null<1>:d     r14.0<1;1,0>:d    0:w              
        shr (16|M16)             r24.0<1>:ud   r12.0<1;1,0>:ud   23:w               {I@2}
        cmp (16|M0)   (eq)f1.0   null<1>:d     r18.0<1;1,0>:d    0:w              
        and (16|M16)             r60.0<1>:d    r24.0<1;1,0>:d    255:w               {Compacted,I@2}
        add (16|M0)              r4.0<1>:d     r82.0<1;1,0>:d    -25165824:d              
(f0.0)  cmp (16|M16)  (eq)f0.0   null<1>:d     r30.0<1;1,0>:d    255:w              
        cmp (16|M16)  (eq)f1.0   null<1>:d     r60.0<1;1,0>:d    255:w               {I@3}
(W)     mov (1|M0)               r3.0<1>:hf    0x1:hf                             
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r34.0<1;1,0>:d    255:w              
        sync.nop                             null                             {Compacted,$10.src}
        shr (16|M0)              r32.0<1>:ud   r4.0<1;1,0>:ud    23:w               {I@4}
        xor (16|M0)              r22.0<1>:d    r4.0<1;1,0>:d     r6.0<1;1,0>:d    {Compacted}
(f0.0)  sel (16|M16)             acc0.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw              {F@1}
        and (16|M0)              r62.0<1>:d    r32.0<1;1,0>:d    255:w               {Compacted,I@3}
(f1.0)  sel (16|M16)             acc2.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw             
(~f1.0) cmp (16|M0)   (eq)f1.0   null<1>:d     r62.0<1;1,0>:d    255:w               {I@2}
        or (16|M16)   (ne)f1.0   null<1>:uw    acc2.0<1;1,0>:uw  acc0.0<1;1,0>:uw
        xor (16|M16)             r28.0<1>:d    r12.0<1;1,0>:d    r28.0<1;1,0>:d   {Compacted}
(f1.0)  goto (32|M0)                         L24664                  L24664                
L14624:
        cmp (16|M16)  (eq)f0.0   null<1>:d     r60.0<1;1,0>:d    0:w              
        or (16|M16)   (eq)f1.0   null<1>:d     r30.0<1;1,0>:d    r14.0<1;1,0>:d  
        cmp (16|M0)   (eq)f1.0   null<1>:d     r62.0<1;1,0>:d    0:w              
(W)     mov (1|M0)               r3.0<1>:hf    0x1:hf                              {I@7}
        or (16|M0)               r4.0<1>:d     r34.0<1;1,0>:d    r18.0<1;1,0>:d   {Compacted}
(f1.0)  sel (16|M16)             acc0.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw              {F@1}
(f0.0)  sel (16|M16)             acc2.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw             
(~f1.0) cmp (16|M0)   (eq)f1.0   null<1>:d     r4.0<1;1,0>:d     0:w               {I@3}
        or (16|M16)   (ne)f1.0   null<1>:uw    acc0.0<1;1,0>:uw  acc2.0<1;1,0>:uw
(~f1.0) goto (32|M0)                         L14816                  L14816                
L14776:
        mov (16|M0)              r22.0<1>:ud   0x0:ud                             
        mov (16|M16)             r26.0<1>:f    0.0:f                               {Compacted,$15.src}
        goto (32|M0)                         L14816                  L24720                
L14816:
        join (32|M0)                         L24664                                
L14832:
        cmp (16|M0)   (eq)f0.0   null<1>:d     r34.0<1;1,0>:d    0:w               {Compacted}
        cmp (16|M16)  (eq)f0.0   null<1>:d     r30.0<1;1,0>:d    0:w              
        add (16|M0)              r58.0<1>:d    r34.0<1;1,0>:d    -127:w               {Compacted}
        add (16|M16)             r56.0<1>:d    r30.0<1;1,0>:d    -127:w               {Compacted}
(f0.0)  mov (16|M0)              r58.0<1>:d    -126:w                              
(f0.0)  mov (16|M16)             r56.0<1>:d    -126:w                              
        add (16|M0)              r52.0<1>:d    r62.0<1;1,0>:d    r58.0<1;1,0>:d   {Compacted,I@2}
        add (16|M16)             r50.0<1>:d    r60.0<1;1,0>:d    r56.0<1;1,0>:d   {Compacted,I@2}
        cmp (16|M0)   (gt)f1.0   null<1>:d     r52.0<1;1,0>:d    254:w               {I@2}
        cmp (16|M16)  (gt)f1.0   null<1>:d     r50.0<1;1,0>:d    254:w               {I@2}
(f1.0)  goto (32|M0)                         L24576                  L24576                
L14968:
        or (16|M0)    (eq)f1.0   null<4>:b     r20.0<1;1,0>:d    r32.0<1;1,0>:d  
        or (16|M16)   (eq)f1.0   null<4>:b     r16.0<1;1,0>:d    r24.0<1;1,0>:d  
(f1.0)  goto (32|M0)                         L24488                  L24488                
L15016:
(W)     mov (1|M0)               r3.0<1>:hf    0.0:hf                             
(W)     mov (1|M0)               r2.3<1>:d     0:w                              
(f0.0)  sel (16|M0)              r4.0<1>:d     r3.0<0;1,0>:w     8388608:d               {F@1}
(f0.0)  sel (16|M16)             r12.0<1>:d    r3.0<0;1,0>:w     8388608:d              
        or (16|M0)               r4.0<1>:d     r4.0<1;1,0>:d     r18.0<1;1,0>:d   {Compacted,I@2}
        or (16|M16)              r12.0<1>:d    r12.0<1;1,0>:d    r14.0<1;1,0>:d   {Compacted,I@2}
        shl (16|M0)              r48.0<1>:d    r4.0<1;1,0>:d     23:w               {Compacted,I@2}
        shr (16|M0)              r42.0<1>:ud   r4.0<1;1,0>:ud    9:w              
        shl (16|M16)             r44.0<1>:d    r12.0<1;1,0>:d    23:w               {Compacted,I@3}
        shr (16|M16)             r40.0<1>:ud   r12.0<1;1,0>:ud   9:w              
(W)     mov (1|M0)               r2.5<1>:f     -0.0:f                               {Compacted}
(W)     mov (2|M0)               r2.0<1>:d     0:w                              
L15168:
(W)     shl (1|M0)               r3.0<1>:d     r2.5<0;1,0>:d     31:w               {Compacted,F@1}
(W)     shr (1|M0)               r3.1<1>:ud    r2.3<0;1,0>:ud    1:w              
(W)     addc (1|M0)              r7.0<1>:ud    r2.0<0;1,0>:ud    0x1:ud              {AccWrEn,I@3}
(W)     or (1|M0)                r2.3<1>:d     r3.1<0;1,0>:d     r3.0<0;1,0>:d    {I@2}
        bfn.0xE0 (16|M0)         r12.0<1>:ud   r3.1<0;0>:ud      r3.0<0;0>:ud      r48.0<1>:ud      // (s0|s1)&s2
        cmp (16|M0)   (eq)f1.0   null<1>:d     r12.0<1;1,0>:d    r2.3<0;1,0>:d    {I@1}
(W)     mov (1|M0)               r4.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        bfn.0xE0 (16|M16)        r14.0<1>:ud   r3.1<0;0>:ud      r3.0<0;0>:ud      r44.0<1>:ud      // (s0|s1)&s2
(W)     add (1|M0)               r2.4<1>:ud    r4.0<0;1,0>:ud    r2.1<0;1,0>:ud   {I@2}
(W)     mov (1|M0)               r4.0<1>:ud    f1.0<0;1,0>:ud                   {Compacted}
(W)     shr (1|M0)               r2.2<1>:ud    r2.5<0;1,0>:ud    1:w              
(W)     mov (1|M0)               f1.0<1>:ud    r4.0<0;1,0>:ud                   {I@2}
        cmp (16|M16)  (eq)f1.0   null<1>:d     r14.0<1;1,0>:d    r2.3<0;1,0>:d   
        and (16|M0)              r16.0<1>:d    r2.2<0;1,0>:d     r42.0<1;1,0>:d   {Compacted,I@3}
(W)     mov (1|M0)               r4.0<1>:ud    f1.0<0;1,0>:ud                   {Compacted}
(W)     cmp (16|M0)   (gt)f0.0   null<1>:d     r2.0<0;1,0>:ud    0x3E:uw             
(W)     mov (1|M0)               f1.0<1>:ud    r4.0<0;1,0>:ud                   {I@2}
        and (16|M16)             r18.0<1>:d    r2.2<0;1,0>:d     r40.0<1;1,0>:d   {Compacted}
(W&f0.0) cmp (16|M0)  (eq)f0.0   null<1>:d     r2.1<0;1,0>:d     0:w              
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r16.0<1;1,0>:d    r2.2<0;1,0>:d   
(W&~f0.0) cmp (16|M0) (gt)f0.0   null<1>:d     r2.1<0;1,0>:ud    0x0:uw             
(W)     mov (1|M0)               r4.0<1>:ud    f1.0<0;1,0>:ud                   {Compacted}
(W)     cmp (16|M16)  (gt)f0.0   null<1>:d     r2.0<0;1,0>:ud    0x3E:uw             
(W)     mov (1|M0)               f1.0<1>:ud    r4.0<0;1,0>:ud                   {I@2}
(W)     mov (1|M0)               r3.0<1>:hf    0x1:hf                             
(W&f0.0) cmp (16|M16) (eq)f0.0   null<1>:d     r2.1<0;1,0>:d     0:w              
(f1.0)  cmp (16|M16)  (eq)f1.0   null<1>:d     r18.0<1;1,0>:d    r2.2<0;1,0>:d   
(f0.0)  sel (16|M0)              acc0.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw              {F@1}
(f1.0)  sel (16|M0)              acc2.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw             
(W)     mov (1|M0)               r4.0<1>:ud    f1.0<0;1,0>:ud                   {Compacted}
        or (16|M0)    (ne)f1.0   null<1>:uw    acc0.0<1;1,0>:uw  acc2.0<1;1,0>:uw
(W&~f0.0) cmp (16|M16) (gt)f0.0  null<1>:d     r2.1<0;1,0>:ud    0x0:uw             
(W)     mov (1|M0)               r3.1<1>:ud    f1.0<0;1,0>:ud                   {Compacted}
(W)     mov (1|M0)               f1.0<1>:ud    r4.0<0;1,0>:ud                   {I@4}
(f0.0)  sel (16|M16)             acc0.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw             
        mov (16|M0)              r64.0<1>:f    r2.0<0;1,0>:f                    {Compacted}
(f1.0)  sel (16|M16)             acc2.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw             
(W)     mov (1|M0)               f1.0<1>:ud    r3.1<0;1,0>:ud                   {I@4}
        or (16|M16)   (ne)f1.0   null<1>:uw    acc0.0<1;1,0>:uw  acc2.0<1;1,0>:uw
        mov (16|M16)             r54.0<1>:f    r2.0<0;1,0>:f                    {Compacted}
(W)     mov (1|M0)               r3.1<1>:ud    f1.0<0;1,0>:ud                   {Compacted}
        mov (16|M16)             r20.0<1>:d    r2.1<0;1,0>:d                   
(W)     mov (1|M0)               f0.0<1>:ud    r3.1<0;1,0>:ud                   {I@2}
        mov (16|M0)              r38.0<1>:f    r7.0<0;1,0>:f                    {Compacted}
        mov (16|M16)             r36.0<1>:f    r7.0<0;1,0>:f                    {Compacted,$14.src}
        mov (16|M0)              r34.0<1>:d    r2.4<0;1,0>:d                   
        mov (16|M16)             r32.0<1>:d    r2.4<0;1,0>:d                   
        mov (16|M0)              r16.0<1>:d    r2.1<0;1,0>:d                   
(f0.0)  goto (32|M0)                         L15896                  L15896                
L15840:
(W)     mov (1|M0)               r2.5<1>:d     r2.2<0;1,0>:d                   
(W)     mov (1|M0)               r2.0<1>:f     r7.0<0;1,0>:f                    {Compacted}
(W)     mov (1|M0)               r2.1<1>:d     r2.4<0;1,0>:d                   
(W)     jmpi                                 L15168                                
L15896:
        join (32|M0)                         L24488                                
L15912:
(W)     mov (1|M0)               r3.0<1>:f     8.68805e-44:f                              
(W)     mov (1|M0)               r4.0<1>:hf    0.0:hf                             
        subb (8|M0)              r30.0<1>:ud   r3.0<0;1,0>:ud    r64.0<1;1,0>:ud  {AccWrEn,Compacted,F@2}
        add3 (8|M0)              r68.0<1>:ud   -acc0.0<1;0>:ud   r4.0<0;0>:uw      -r16.0<1>:ud     {A@1}
        subb (8|M8)              r31.0<1>:ud   r3.0<0;1,0>:ud    r65.0<1;1,0>:ud  {AccWrEn}
        add3 (8|M8)              r69.0<1>:ud   -acc0.0<1;0>:ud   r4.0<0;0>:uw      -r17.0<1>:ud    
        subb (8|M16)             r24.0<1>:ud   r3.0<0;1,0>:ud    r54.0<1;1,0>:ud  {AccWrEn}
        add3 (16|M0)             r18.0<1>:d    r52.0<1;0>:d      r30.0<1;0>:d      -173:w               {I@3}
        add3 (8|M16)             r80.0<1>:ud   -acc0.0<1;0>:ud   r4.0<0;0>:uw      -r20.0<1>:ud    
        subb (8|M24)             r25.0<1>:ud   r3.0<0;1,0>:ud    r55.0<1;1,0>:ud  {AccWrEn}
        cmp (16|M0)   (gt)f0.0   null<1>:d     r18.0<1;1,0>:d    127:w               {Compacted,I@3}
        add3 (16|M16)            r66.0<1>:d    r60.0<1;0>:d      r56.0<1;0>:d      r24.0<1>:d       {I@2}
        add3 (16|M16)            r56.0<1>:d    r50.0<1;0>:d      r24.0<1;0>:d      -173:w              
        cmp (16|M16)  (gt)f0.0   null<1>:d     r56.0<1;1,0>:d    127:w               {I@1}
        add3 (16|M0)             r62.0<1>:d    r62.0<1;0>:d      r58.0<1;0>:d      r30.0<1>:d      
        add3 (8|M24)             r81.0<1>:ud   -acc0.0<1;0>:ud   r4.0<0;0>:uw      -r21.0<1>:ud    
(f0.0)  goto (32|M0)                         L24400                  L24400                
L16168:
        cmp (16|M0)   (gt)f1.0   null<1>:d     r18.0<1;1,0>:d    -127:w              
        cmp (16|M16)  (gt)f1.0   null<1>:d     r56.0<1;1,0>:d    -127:w              
(f1.0)  goto (32|M0)                         L20280                  L20280                
L16216:
        cmp (16|M0)   (lt)f0.0   null<1>:d     r18.0<1;1,0>:ud   0xFFFFFF6B:ud             
        cmp (16|M16)  (lt)f0.0   null<1>:d     r56.0<1;1,0>:ud   0xFFFFFF6B:ud             
(f0.0)  goto (32|M0)                         L19528                  L19528                
L16264:
(W)     mov (1|M0)               r3.0<1>:f     8.82818e-44:f                              
        add3 (16|M0)             r34.0<1>:d    r52.0<1;0>:d      r30.0<1;0>:d      -23:w              
(W)     mov (1|M0)               r4.0<1>:hf    0.0:hf                              {I@7}
        subb (8|M0)              r30.0<1>:ud   r3.0<0;1,0>:ud    r64.0<1;1,0>:ud  {AccWrEn,Compacted,F@2}
        add3 (16|M16)            r60.0<1>:d    r50.0<1;0>:d      r24.0<1;0>:d      -23:w              
        add3 (8|M0)              r12.0<1>:ud   -acc0.0<1;0>:ud   r4.0<0;0>:uw      -r16.0<1>:ud     {F@1}
        subb (8|M8)              r31.0<1>:ud   r3.0<0;1,0>:ud    r65.0<1;1,0>:ud  {AccWrEn}
(W)     mov (1|M0)               r5.0<1>:hf    0x1:hf                             
        add3 (8|M8)              r13.0<1>:ud   -acc0.0<1;0>:ud   r4.0<0;0>:uw      -r17.0<1>:ud    
        subb (8|M16)             r58.0<1>:ud   r3.0<0;1,0>:ud    r54.0<1;1,0>:ud  {AccWrEn}
        cmp (16|M0)   (gt)f0.0   null<1>:d     r30.0<1;1,0>:ud   r34.0<1;1,0>:ud  {I@3}
        add3 (8|M16)             r14.0<1>:ud   -acc0.0<1;0>:ud   r4.0<0;0>:uw      -r20.0<1>:ud    
        subb (8|M24)             r59.0<1>:ud   r3.0<0;1,0>:ud    r55.0<1;1,0>:ud  {AccWrEn}
(f0.0)  cmp (16|M0)   (eq)f0.0   null<1>:d     r12.0<1;1,0>:d    0:w               {I@5}
        cmp (16|M16)  (gt)f1.0   null<1>:d     r58.0<1;1,0>:ud   r60.0<1;1,0>:ud  {I@2}
        add3 (8|M24)             r15.0<1>:ud   -acc0.0<1;0>:ud   r4.0<0;0>:uw      -r21.0<1>:ud    
(~f0.0) cmp (16|M0)   (gt)f0.0   null<1>:d     r12.0<1;1,0>:ud   0x0:uw             
(f1.0)  cmp (16|M16)  (eq)f1.0   null<1>:d     r14.0<1;1,0>:d    0:w               {I@2}
        cmp (16|M16)  (gt)f0.0   null<1>:d     r14.0<1;1,0>:ud   0x0:uw             
(f1.0)  sel (16|M16)             acc0.0<1>:uw  r5.0<0;1,0>:uw    0x0:uw              {F@1}
(f0.0)  sel (16|M16)             acc2.0<1>:uw  r5.0<0;1,0>:uw    0x0:uw             
        or (16|M16)   (ne)f0.0   null<1>:uw    acc2.0<1;1,0>:uw  acc0.0<1;1,0>:uw
(f0.0)  goto (32|M0)                         L16720                  L16720                
L16624:
        add3 (16|M0)             r4.0<1>:d     r62.0<1;0>:d      -r30.0<1;0>:d     -23:w              
        add3 (16|M16)            r12.0<1>:d    r66.0<1;0>:d      -r58.0<1;0>:d     -23:w              
        mov (16|M0)              r18.0<1>:d    0:w                              
        mov (16|M16)             r72.0<1>:d    0:w                              
        shl (16|M0)              r30.0<1>:d    r48.0<1;1,0>:d    r4.0<1;1,0>:d    {Compacted,I@4}
        shl (16|M16)             r74.0<1>:d    r44.0<1;1,0>:d    r12.0<1;1,0>:d   {Compacted,I@4}
        goto (32|M0)                         L16720                  L19424                
L16720:
        join (32|M0)                         L19424                                
L16736:
        add3 (16|M0)             r38.0<1>:d    r30.0<1;0>:d      -r62.0<1;0>:d     23:w               {I@4}
        add3 (16|M16)            r6.0<1>:d     r58.0<1;0>:d      -r66.0<1;0>:d     23:w              
        cmp (16|M0)   (lt)f1.0   null<1>:d     r38.0<1;1,0>:d    2:w               {Compacted,I@2}
        cmp (16|M16)  (lt)f1.0   null<1>:d     r6.0<1;1,0>:d     2:w               {I@2}
(f1.0)  goto (32|M0)                         L16976                  L16976                
L16808:
        cmp (16|M0)   (eq)f0.0   null<1>:d     r38.0<1;1,0>:d    2:w               {Compacted}
        cmp (16|M16)  (eq)f0.0   null<1>:d     r6.0<1;1,0>:d     2:w              
(~f0.0) goto (32|M0)                         L16976                  L17040                
L16848:
        shr (16|M0)              r18.0<1>:ud   r48.0<1;1,0>:ud   1:w              
        shr (16|M16)             r54.0<1>:ud   r44.0<1;1,0>:ud   1:w              
        mov (16|M0)              r52.0<1>:d    0:w                              
        mov (16|M16)             r66.0<1>:d    0:w                              
        mov (16|M0)              r30.0<1>:d    0:w                              
        mov (16|M16)             r64.0<1>:d    0:w                              
        mov (16|M0)              r34.0<1>:f    r18.0<1;1,0>:f                   {Compacted,I@6}
        mov (16|M16)             r62.0<1>:f    r54.0<1;1,0>:f                   {Compacted,I@5}
        goto (32|M0)                         L16976                  L18560                
L16976:
        join (32|M0)                         L17040                                
L16992:
        cmp (16|M0)   (eq)f1.0   null<1>:d     r38.0<1;1,0>:d    1:w              
        cmp (16|M16)  (eq)f1.0   null<1>:d     r6.0<1;1,0>:d     1:w              
(f1.0)  goto (32|M0)                         L17040                  L18464                
L17040:
        join (32|M0)                         L18464                                
L17056:
        add3 (16|M0)             r4.0<1>:d     r30.0<1;0>:d      -r34.0<1;0>:d     -1:w               {A@2}
        add3 (16|M16)            r12.0<1>:d    r58.0<1;0>:d      -r60.0<1;0>:d     -1:w              
        and (16|M0)   (ne)f0.0   r14.0<1>:d    r4.0<1;1,0>:d     63:w               {Compacted,I@2}
        and (16|M16)  (ne)f0.0   r2.0<1>:d     r12.0<1;1,0>:d    63:w               {I@2}
(f0.0)  goto (32|M0)                         L17168                  L17168                
L17128:
        mov (16|M0)              r68.0<1>:f    r48.0<1;1,0>:f                   {Compacted}
        mov (16|M16)             r70.0<1>:d    r44.0<1;1,0>:d                  
        goto (32|M0)                         L17168                  L17432                
L17168:
        join (32|M0)                         L17432                                
L17184:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r14.0<1;1,0>:ud   0x20:uw              {I@6}
        cmp (16|M16)  (lt)f1.0   null<1>:d     r2.0<1;1,0>:ud    0x20:uw              {I@6}
(f1.0)  goto (32|M0)                         L17296                  L17296                
L17232:
        add (16|M0)              r4.0<1>:d     r14.0<1;1,0>:d    -32:w               {Compacted}
        add (16|M16)             r12.0<1>:d    r2.0<1;1,0>:d     -32:w               {Compacted}
        shr (16|M0)              r18.0<1>:ud   r42.0<1;1,0>:ud   r4.0<1;1,0>:d    {I@2}
        shr (16|M16)             r54.0<1>:ud   r40.0<1;1,0>:ud   r12.0<1;1,0>:d   {A@2}
        goto (32|M0)                         L17296                  L17392                
L17296:
        join (32|M0)                         L17392                                
L17312:
        add (16|M0)              r4.0<1>:d     -r14.0<1;1,0>:d   32:w               {Compacted}
        add (16|M16)             r12.0<1>:d    -r2.0<1;1,0>:d    32:w               {Compacted}
        shr (16|M16)             r16.0<1>:ud   r44.0<1;1,0>:ud   r2.0<1;1,0>:d   
        shl (16|M0)              r4.0<1>:d     r42.0<1;1,0>:d    r4.0<1;1,0>:d    {Compacted,I@3}
        shr (16|M0)              r14.0<1>:ud   r48.0<1;1,0>:ud   r14.0<1;1,0>:d  
        shl (16|M16)             r12.0<1>:d    r40.0<1;1,0>:d    r12.0<1;1,0>:d   {Compacted,I@4}
        or (16|M0)               r18.0<1>:d    r14.0<1;1,0>:d    r4.0<1;1,0>:d    {Compacted,I@2}
        or (16|M16)              r54.0<1>:d    r16.0<1;1,0>:d    r12.0<1;1,0>:d   {Compacted,I@2}
L17392:
        join (32|M0)                         L17432                                
L17408:
        mov (16|M0)              r68.0<1>:f    r18.0<1;1,0>:f                   {Compacted,I@3}
        mov (16|M16)             r70.0<1>:d    r54.0<1;1,0>:d                   {I@2}
L17432:
        join (32|M0)                         L18464                                
L17448:
        add3 (16|M0)             r34.0<1>:d    r30.0<1;0>:d      -r34.0<1;0>:d     -2:w              
        add3 (16|M16)            r20.0<1>:d    r58.0<1;0>:d      -r60.0<1;0>:d     -2:w              
        and (16|M0)   (ne)f0.0   r14.0<1>:d    r34.0<1;1,0>:d    63:w               {Compacted,I@2}
        and (16|M16)  (ne)f0.0   r2.0<1>:d     r20.0<1;1,0>:d    63:w               {I@2}
(f0.0)  goto (32|M0)                         L17560                  L17560                
L17520:
        mov (16|M0)              r18.0<1>:f    r48.0<1;1,0>:f                   {Compacted}
        mov (16|M16)             r54.0<1>:d    r44.0<1;1,0>:d                  
        goto (32|M0)                         L17560                  L17784                
L17560:
        join (32|M0)                         L17784                                
L17576:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r14.0<1;1,0>:ud   0x20:uw              {I@6}
        cmp (16|M16)  (lt)f1.0   null<1>:d     r2.0<1;1,0>:ud    0x20:uw              {I@6}
(f1.0)  goto (32|M0)                         L17688                  L17688                
L17624:
        add (16|M0)              r4.0<1>:d     r14.0<1;1,0>:d    -32:w               {Compacted}
        add (16|M16)             r12.0<1>:d    r2.0<1;1,0>:d     -32:w               {Compacted}
        shr (16|M0)              r18.0<1>:ud   r42.0<1;1,0>:ud   r4.0<1;1,0>:d    {A@1}
        shr (16|M16)             r54.0<1>:ud   r40.0<1;1,0>:ud   r12.0<1;1,0>:d   {I@2}
        goto (32|M0)                         L17688                  L17784                
L17688:
        join (32|M0)                         L17784                                
L17704:
        add (16|M0)              r4.0<1>:d     -r14.0<1;1,0>:d   32:w               {Compacted}
        add (16|M16)             r12.0<1>:d    -r2.0<1;1,0>:d    32:w               {Compacted}
        shr (16|M16)             r16.0<1>:ud   r44.0<1;1,0>:ud   r2.0<1;1,0>:d   
        shl (16|M0)              r4.0<1>:d     r42.0<1;1,0>:d    r4.0<1;1,0>:d    {Compacted,I@3}
        shr (16|M0)              r14.0<1>:ud   r48.0<1;1,0>:ud   r14.0<1;1,0>:d  
        shl (16|M16)             r12.0<1>:d    r40.0<1;1,0>:d    r12.0<1;1,0>:d   {Compacted,I@4}
        or (16|M0)               r18.0<1>:d    r14.0<1;1,0>:d    r4.0<1;1,0>:d    {Compacted,I@2}
        or (16|M16)              r54.0<1>:d    r16.0<1;1,0>:d    r12.0<1;1,0>:d   {Compacted,I@2}
L17784:
        join (32|M0)                         L18464                                
L17800:
        and (16|M0)   (ne)f0.0   r4.0<1>:d     r34.0<1;1,0>:d    63:w               {Compacted}
        and (16|M16)  (ne)f0.0   r20.0<1>:d    r20.0<1;1,0>:d    63:w              
        and (16|M0)              r30.0<1>:d    r18.0<1;1,0>:d    1:w               {Compacted,I@5}
        and (16|M16)             r64.0<1>:d    r54.0<1;1,0>:d    1:w               {Compacted,I@5}
(f0.0)  goto (32|M0)                         L17936                  L17936                
L17856:
        mov (16|M0)              r4.0<1>:d     -1:w                              
        mov (16|M16)             r14.0<1>:d    -1:w                              
        mov (16|M0)              r18.0<1>:d    -1:w                              
        mov (16|M16)             r16.0<1>:d    -1:w                              
        goto (32|M0)                         L17936                  L18208                
L17936:
        join (32|M0)                         L18208                                
L17952:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r4.0<1;1,0>:ud    0x20:uw              {I@6}
        cmp (16|M16)  (lt)f1.0   null<1>:d     r20.0<1;1,0>:ud   0x20:uw             
(f1.0)  goto (32|M0)                         L18112                  L18112                
L18000:
        add (16|M0)              r4.0<1>:d     r4.0<1;1,0>:d     -32:w               {Compacted}
        add (16|M16)             r12.0<1>:d    r20.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r3.0<1>:hf    -qnan(0x1FF):hf                             
        mov (16|M16)             r14.0<1>:d    0:w                              
        shl (16|M0)              r18.0<1>:d    r3.0<0;1,0>:w     r4.0<1;1,0>:d    {A@1}
        shl (16|M16)             r16.0<1>:d    r3.0<0;1,0>:w     r12.0<1;1,0>:d   {I@3}
        mov (16|M0)              r4.0<1>:d     0:w                              
        goto (32|M0)                         L18112                  L18208                
L18112:
        join (32|M0)                         L18208                                
L18128:
(W)     mov (1|M0)               r3.0<1>:hf    -qnan(0x1FF):hf                              {I@4}
        mov (16|M0)              r18.0<1>:d    -1:w                              
        mov (16|M16)             r16.0<1>:d    -1:w                              
        shl (16|M0)              r4.0<1>:d     r3.0<0;1,0>:w     r4.0<1;1,0>:d    {A@1}
        shl (16|M16)             r14.0<1>:d    r3.0<0;1,0>:w     r20.0<1;1,0>:d  
L18208:
        join (32|M0)                         L18464                                
L18224:
        bfn.0x60 (16|M0)         r4.0<1>:ud    r4.0<1;0>:ud      r10.2<0;0>:ud     r48.0<1>:ud      {I@3} // (s0^s1)&s2
        bfn.0x60 (16|M16)        r12.0<1>:ud   r14.0<1;0>:ud     r10.2<0;0>:ud     r44.0<1>:ud      {I@3} // (s0^s1)&s2
        cmp (16|M0)   (ne)f1.0   null<1>:d     r4.0<1;1,0>:d     0:w               {I@2}
        cmp (16|M16)  (ne)f1.0   null<1>:d     r12.0<1;1,0>:d    0:w               {I@2}
        bfn.0x60 (16|M16)        r16.0<1>:ud   r16.0<1;0>:ud     r10.2<0;0>:ud     r40.0<1>:ud      // (s0^s1)&s2
        bfn.0x60 (16|M0)         r14.0<1>:ud   r18.0<1;0>:ud     r10.2<0;0>:ud     r42.0<1>:ud      // (s0^s1)&s2
(~f1.0) cmp (16|M16)  (ne)f1.0   null<1>:d     r16.0<1;1,0>:d    0:w               {I@2}
(~f1.0) cmp (16|M0)   (ne)f1.0   null<1>:d     r14.0<1;1,0>:d    0:w               {I@2}
(W)     mov (1|M0)               r3.0<1>:hf    -qnan(0x1FF):hf                             
        mov (16|M0)              r34.0<1>:f    r68.0<1;1,0>:f                   {Compacted}
(f1.0)  sel (16|M0)              r18.0<1>:d    r3.0<0;1,0>:w     0:w               {F@2}
(f1.0)  sel (16|M16)             r20.0<1>:d    r3.0<0;1,0>:w     0:w              
        mov (16|M16)             r62.0<1>:f    r70.0<1;1,0>:f                   {Compacted}
        mov (16|M0)              r52.0<1>:d    -r18.0<1;1,0>:d                  {I@2}
        mov (16|M16)             r66.0<1>:d    -r20.0<1;1,0>:d                  {I@2}
        goto (32|M0)                         L18464                  L18560                
L18464:
        join (32|M0)                         L18560                                
L18480:
        mov (16|M0)              r52.0<1>:d    0:w                              
        mov (16|M16)             r66.0<1>:d    0:w                              
        mov (16|M0)              r30.0<1>:d    0:w                              
        mov (16|M16)             r64.0<1>:d    0:w                              
        mov (16|M0)              r34.0<1>:f    r48.0<1;1,0>:f                   {Compacted}
        mov (16|M16)             r62.0<1>:f    r44.0<1;1,0>:f                   {Compacted}
L18560:
        join (32|M0)                         L19424                                
L18576:
        and (16|M0)   (ne)f0.0   r14.0<1>:d    r38.0<1;1,0>:d    63:w               {Compacted}
        and (16|M16)  (ne)f0.0   r2.0<1>:d     r6.0<1;1,0>:d     63:w              
(f0.0)  goto (32|M0)                         L18656                  L18656                
L18616:
        mov (16|M0)              r18.0<1>:f    r48.0<1;1,0>:f                   {Compacted}
        mov (16|M16)             r54.0<1>:d    r44.0<1;1,0>:d                  
        goto (32|M0)                         L18656                  L18880                
L18656:
        join (32|M0)                         L18880                                
L18672:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r14.0<1;1,0>:ud   0x20:uw              {I@6}
        cmp (16|M16)  (lt)f1.0   null<1>:d     r2.0<1;1,0>:ud    0x20:uw              {I@6}
(f1.0)  goto (32|M0)                         L18784                  L18784                
L18720:
        add (16|M0)              r4.0<1>:d     r14.0<1;1,0>:d    -32:w               {Compacted}
        add (16|M16)             r12.0<1>:d    r2.0<1;1,0>:d     -32:w               {Compacted}
        shr (16|M0)              r18.0<1>:ud   r42.0<1;1,0>:ud   r4.0<1;1,0>:d    {A@1}
        shr (16|M16)             r54.0<1>:ud   r40.0<1;1,0>:ud   r12.0<1;1,0>:d   {I@2}
        goto (32|M0)                         L18784                  L18880                
L18784:
        join (32|M0)                         L18880                                
L18800:
        add (16|M0)              r4.0<1>:d     -r14.0<1;1,0>:d   32:w               {Compacted}
        add (16|M16)             r12.0<1>:d    -r2.0<1;1,0>:d    32:w               {Compacted}
        shr (16|M16)             r16.0<1>:ud   r44.0<1;1,0>:ud   r2.0<1;1,0>:d   
        shl (16|M0)              r4.0<1>:d     r42.0<1;1,0>:d    r4.0<1;1,0>:d    {Compacted,I@3}
        shr (16|M0)              r14.0<1>:ud   r48.0<1;1,0>:ud   r14.0<1;1,0>:d  
        shl (16|M16)             r12.0<1>:d    r40.0<1;1,0>:d    r12.0<1;1,0>:d   {Compacted,I@4}
        or (16|M0)               r18.0<1>:d    r14.0<1;1,0>:d    r4.0<1;1,0>:d    {Compacted,I@2}
        or (16|M16)              r54.0<1>:d    r16.0<1;1,0>:d    r12.0<1;1,0>:d   {Compacted,I@2}
L18880:
        join (32|M0)                         L19424                                
L18896:
        shl (16|M0)              r4.0<1>:d     r34.0<1;1,0>:d    2:w               {Compacted}
        shl (16|M16)             r12.0<1>:d    r62.0<1;1,0>:d    2:w               {Compacted}
        shl (16|M0)              r14.0<1>:d    r30.0<1;1,0>:d    1:w               {Compacted}
        shl (16|M16)             r16.0<1>:d    r64.0<1;1,0>:d    1:w               {Compacted}
        and (16|M0)              r4.0<1>:d     r4.0<1;1,0>:d     4:w               {Compacted,I@4}
        and (16|M16)             r12.0<1>:d    r12.0<1;1,0>:d    4:w               {Compacted,I@4}
        bfn.0xFE (16|M0)         r14.0<1>:ud   r4.0<1;0>:ud      r14.0<1;0>:ud     r52.0<1>:ud      {I@2} // s0|s1|s2
        bfn.0xFE (16|M16)        r4.0<1>:ud    r12.0<1;0>:ud     r16.0<1;0>:ud     r66.0<1>:ud      {I@2} // s0|s1|s2
        cmp (16|M0)   (eq)f0.0   null<1>:d     r14.0<1;1,0>:d    0:w               {Compacted,I@2}
        cmp (16|M16)  (eq)f0.0   null<1>:d     r4.0<1;1,0>:d     0:w               {I@2}
(~f0.0) goto (32|M0)                         L19064                  L19064                
L19016:
        mov (16|M0)              r12.0<1>:d    0:w                              
        mov (16|M16)             r6.0<1>:d     0:w                              
        goto (32|M0)                         L19064                  L19296                
L19064:
        join (32|M0)                         L19296                                
L19080:
        cmp (16|M0)   (gt)f1.0   null<1>:d     r14.0<1;1,0>:ud   0x4:uw             
        cmp (16|M16)  (gt)f1.0   null<1>:d     r4.0<1;1,0>:ud    0x4:uw             
(~f1.0) goto (32|M0)                         L19176                  L19176                
L19128:
        mov (16|M0)              r12.0<1>:d    1:w                              
        mov (16|M16)             r6.0<1>:d     1:w                              
        goto (32|M0)                         L19176                  L19296                
L19176:
        join (32|M0)                         L19296                                
L19192:
        and (16|M0)   (ne)f0.0   null<1>:d     r18.0<1;1,0>:d    1:w               {Compacted}
        and (16|M16)  (ne)f0.0   null<1>:d     r54.0<1;1,0>:d    1:w              
(f0.0)  cmp (16|M0)   (eq)f0.0   null<1>:d     r14.0<1;1,0>:d    4:w              
(f0.0)  cmp (16|M16)  (eq)f0.0   null<1>:d     r4.0<1;1,0>:d     4:w              
(W)     mov (1|M0)               r3.0<1>:hf    0x1:hf                             
(f0.0)  sel (16|M0)              r12.0<1>:d    r3.0<0;1,0>:w     0:w               {F@1}
(f0.0)  sel (16|M16)             r6.0<1>:d     r3.0<0;1,0>:w     0:w              
L19296:
        join (32|M0)                         L19424                                
L19312:
        add (16|M0)              r4.0<1>:d     r12.0<1;1,0>:d    r18.0<1;1,0>:d   {Compacted,I@3}
        add (16|M16)             r12.0<1>:d    r6.0<1;1,0>:d     r54.0<1;1,0>:d   {Compacted,I@3}
        cmp (16|M0)   (gt)f0.0   null<1>:d     r4.0<1;1,0>:ud    0x7FFFFF:ud              {I@2}
        cmp (16|M16)  (gt)f0.0   null<1>:d     r12.0<1;1,0>:ud   0x7FFFFF:ud              {I@2}
(W)     mov (1|M0)               r3.0<1>:f     0x800000:f                               {Compacted}
(~f0.0) sel (16|M0)              r30.0<1>:d    r4.0<1;1,0>:d     0:w              
(~f0.0) sel (16|M16)             r74.0<1>:d    r12.0<1;1,0>:d    0:w              
(f0.0)  sel (16|M0)              r18.0<1>:d    r3.0<0;1,0>:d     0:w               {Compacted,F@1}
(f0.0)  sel (16|M16)             r72.0<1>:d    r3.0<0;1,0>:d     0:w              
L19424:
        join (32|M0)                         L19528                                
L19440:
        and (16|M0)              r4.0<1>:d     r22.0<1;1,0>:d    -2147483648:d              
        and (16|M16)             r12.0<1>:d    r28.0<1;1,0>:d    -2147483648:d              
        bfn.0xFE (16|M0)         r22.0<1>:ud   r4.0<1;0>:ud      r18.0<1;0>:ud     r30.0<1>:ud      {I@2} // s0|s1|s2
        sync.nop                             null                             {Compacted,$15.src}
        bfn.0xFE (16|M16)        r26.0<1>:ud   r12.0<1;0>:ud     r72.0<1;0>:ud     r74.0<1>:ud      {I@2} // s0|s1|s2
        goto (32|M0)                         L19528                  L24720                
L19528:
        join (32|M0)                         L20280                                
L19544:
        and (16|M0)   (ne)f0.0   r4.0<1>:d     r30.0<1;1,0>:d    63:w               {Compacted}
        and (16|M16)  (ne)f0.0   r16.0<1>:d    r24.0<1;1,0>:d    63:w              
(f0.0)  goto (32|M0)                         L19664                  L19664                
L19584:
        mov (16|M0)              r4.0<1>:d     -1:w                              
        mov (16|M16)             r14.0<1>:d    -1:w                              
        mov (16|M0)              r20.0<1>:d    -1:w                              
        mov (16|M16)             r6.0<1>:d     -1:w                              
        goto (32|M0)                         L19664                  L19936                
L19664:
        join (32|M0)                         L19936                                
L19680:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r4.0<1;1,0>:ud    0x20:uw              {I@6}
        cmp (16|M16)  (lt)f1.0   null<1>:d     r16.0<1;1,0>:ud   0x20:uw             
(f1.0)  goto (32|M0)                         L19840                  L19840                
L19728:
        add (16|M0)              r4.0<1>:d     r4.0<1;1,0>:d     -32:w               {Compacted}
        add (16|M16)             r12.0<1>:d    r16.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r3.0<1>:hf    -qnan(0x1FF):hf                             
        mov (16|M16)             r14.0<1>:d    0:w                              
        shl (16|M0)              r20.0<1>:d    r3.0<0;1,0>:w     r4.0<1;1,0>:d    {A@1}
        shl (16|M16)             r6.0<1>:d     r3.0<0;1,0>:w     r12.0<1;1,0>:d   {I@3}
        mov (16|M0)              r4.0<1>:d     0:w                              
        goto (32|M0)                         L19840                  L19936                
L19840:
        join (32|M0)                         L19936                                
L19856:
(W)     mov (1|M0)               r3.0<1>:hf    -qnan(0x1FF):hf                              {I@4}
        mov (16|M0)              r20.0<1>:d    -1:w                              
        mov (16|M16)             r6.0<1>:d     -1:w                              
        shl (16|M0)              r4.0<1>:d     r3.0<0;1,0>:w     r4.0<1;1,0>:d    {A@1}
        shl (16|M16)             r14.0<1>:d    r3.0<0;1,0>:w     r16.0<1;1,0>:d  
L19936:
        join (32|M0)                         L20280                                
L19952:
        bfn.0x60 (16|M0)         r4.0<1>:ud    r4.0<1;0>:ud      r10.2<0;0>:ud     r48.0<1>:ud      {I@3} // (s0^s1)&s2
        bfn.0x60 (16|M16)        r12.0<1>:ud   r14.0<1;0>:ud     r10.2<0;0>:ud     r44.0<1>:ud      {I@3} // (s0^s1)&s2
        cmp (16|M0)   (ne)f0.0   null<1>:d     r4.0<1;1,0>:d     0:w               {Compacted,I@2}
        cmp (16|M16)  (ne)f0.0   null<1>:d     r12.0<1;1,0>:d    0:w               {I@2}
        bfn.0x60 (16|M16)        r16.0<1>:ud   r6.0<1;0>:ud      r10.2<0;0>:ud     r40.0<1>:ud      // (s0^s1)&s2
        bfn.0x60 (16|M0)         r14.0<1>:ud   r20.0<1;0>:ud     r10.2<0;0>:ud     r42.0<1>:ud      // (s0^s1)&s2
        cmp (16|M0)   (gt)f1.0   null<1>:d     r22.0<1;1,0>:d    -1:w              
        cmp (16|M16)  (gt)f1.0   null<1>:d     r28.0<1;1,0>:d    -1:w              
(~f0.0) cmp (16|M16)  (ne)f0.0   null<1>:d     r16.0<1;1,0>:d    0:w               {I@4}
(~f0.0) cmp (16|M0)   (ne)f0.0   null<1>:d     r14.0<1;1,0>:d    0:w               {I@4}
(f0.0)  cmp (16|M16)  (eq)f0.0   null<1>:d     r56.0<1;1,0>:d    -150:w              
(f0.0)  cmp (16|M0)   (eq)f0.0   null<1>:d     r18.0<1;1,0>:d    -150:w              
(f1.0)  goto (32|M0)                         L20208                  L20208                
L20152:
(W)     mov (1|M0)               r3.0<1>:ud    0x80000001:ud                             
(f0.0)  sel (16|M0)              r22.0<1>:f    r3.0<0;1,0>:f     -0.0:f               {Compacted,I@1}
(f0.0)  sel (16|M16)             r26.0<1>:f    r3.0<0;1,0>:f     -0.0:f               {$15.src}
        goto (32|M0)                         L20208                  L24720                
L20208:
        join (32|M0)                         L20280                                
L20224:
(W)     mov (1|M0)               r3.0<1>:ud    0x1:ud                              {F@1}
(f0.0)  sel (16|M0)              r22.0<1>:f    r3.0<0;1,0>:f     0.0:f               {Compacted,I@1}
(f0.0)  sel (16|M16)             r26.0<1>:f    r3.0<0;1,0>:f     0.0:f               {$15.src}
        goto (32|M0)                         L20280                  L24720                
L20280:
        join (32|M0)                         L24400                                
L20296:
        cmp (16|M16)  (lt)f1.0   null<1>:d     r24.0<1;1,0>:ud   0x18:uw             
        cmp (16|M16)  (eq)f0.0   null<1>:d     r80.0<1;1,0>:d    0:w               {F@1}
        cmp (16|M0)   (lt)f0.0   null<1>:d     r30.0<1;1,0>:ud   0x18:uw             
(W)     mov (1|M0)               r3.0<1>:hf    0x1:hf                             
        add3 (16|M0)             r60.0<1>:d    r52.0<1;0>:d      r30.0<1;0>:d      -46:w              
(f0.0)  sel (16|M16)             acc0.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw              {F@1}
(f1.0)  sel (16|M16)             acc2.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw             
(f0.0)  cmp (16|M0)   (eq)f0.0   null<1>:d     r68.0<1;1,0>:d    0:w              
        and (16|M16)  (ne)f0.0   null<1>:uw    acc0.0<1;1,0>:uw  acc2.0<1;1,0>:uw
        add3 (16|M16)            r64.0<1>:d    r50.0<1;0>:d      r24.0<1;0>:d      -46:w              
(f0.0)  goto (32|M0)                         L23936                  L23936                
L20472:
        shl (16|M16)             r12.0<1>:d    r36.0<1;1,0>:d    1:w               {Compacted}
        shl (16|M0)              r4.0<1>:d     r38.0<1;1,0>:d    1:w               {Compacted}
        shr (16|M16)             r16.0<1>:ud   r36.0<1;1,0>:ud   31:w              
        shl (16|M16)             r20.0<1>:d    r32.0<1;1,0>:d    1:w               {Compacted}
        cmp (16|M16)  (lt)f0.0   null<1>:d     r12.0<1;1,0>:ud   0x4E:uw              {I@4}
        shr (16|M0)              r14.0<1>:ud   r38.0<1;1,0>:ud   31:w              
        shl (16|M0)              r18.0<1>:d    r34.0<1;1,0>:d    1:w               {Compacted}
        cmp (16|M0)   (lt)f1.0   null<1>:d     r4.0<1;1,0>:ud    0x4E:uw              {I@6}
        or (16|M16)              r20.0<1>:d    r20.0<1;1,0>:d    r16.0<1;1,0>:d   {Compacted,I@5}
        or (16|M0)               r18.0<1>:d    r18.0<1;1,0>:d    r14.0<1;1,0>:d   {Compacted,I@3}
(f0.0)  cmp (16|M16)  (eq)f0.0   null<1>:d     r20.0<1;1,0>:d    0:w               {I@2}
        cmp (16|M16)  (lt)f1.0   null<1>:d     r20.0<1;1,0>:d    0:w              
(W)     mov (1|M0)               r3.0<1>:hf    0x1:hf                             
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r18.0<1;1,0>:d    0:w               {I@3}
(f1.0)  sel (16|M16)             acc0.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw              {F@1}
(f0.0)  sel (16|M16)             acc2.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw             
(~f1.0) cmp (16|M0)   (lt)f1.0   null<1>:d     r18.0<1;1,0>:d    0:w              
        or (16|M16)   (ne)f1.0   null<1>:uw    acc0.0<1;1,0>:uw  acc2.0<1;1,0>:uw
(f1.0)  goto (32|M0)                         L21016                  L21016                
L20728:
        cmp (16|M16)  (eq)f0.0   null<1>:d     r36.0<1;1,0>:d    39:w              
        cmp (16|M16)  (eq)f1.0   null<1>:d     r32.0<1;1,0>:d    0:w              
        cmp (16|M0)   (eq)f1.0   null<1>:d     r38.0<1;1,0>:d    39:w              
(W)     mov (1|M0)               r3.0<1>:hf    0x1:hf                              {I@7}
(f1.0)  sel (16|M16)             acc0.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw              {F@1}
(f0.0)  sel (16|M16)             acc2.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw             
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r34.0<1;1,0>:d    0:w              
        and (16|M16)  (ne)f1.0   null<1>:uw    acc0.0<1;1,0>:uw  acc2.0<1;1,0>:uw
(~f1.0) goto (32|M0)                         L21016                  L21168                
L20872:
        shr (16|M0)              r18.0<1>:ud   r48.0<1;1,0>:ud   1:w              
        shr (16|M16)             r54.0<1>:ud   r44.0<1;1,0>:ud   1:w              
        mov (16|M0)              r62.0<1>:d    0:w                              
        mov (16|M16)             r58.0<1>:d    0:w                              
        mov (16|M0)              r38.0<1>:d    0:w                              
        mov (16|M16)             r56.0<1>:d    0:w                              
        mov (16|M0)              r42.0<1>:f    r18.0<1;1,0>:f                   {Compacted,I@6}
        mov (16|M16)             r6.0<1>:f     r54.0<1;1,0>:f                   {Compacted,I@5}
        mov (16|M0)              r18.0<1>:f    r48.0<1;1,0>:f                   {Compacted}
        mov (16|M16)             r54.0<1>:f    r44.0<1;1,0>:f                   {Compacted}
        goto (32|M0)                         L21016                  L23088                
L21016:
        join (32|M0)                         L21168                                
L21032:
        cmp (16|M16)  (eq)f1.0   null<1>:d     r36.0<1;1,0>:d    38:w              
        cmp (16|M16)  (eq)f0.0   null<1>:d     r32.0<1;1,0>:d    0:w              
        cmp (16|M0)   (eq)f0.0   null<1>:d     r38.0<1;1,0>:d    38:w               {Compacted,I@6}
(W)     mov (1|M0)               r3.0<1>:hf    0x1:hf                             
(f0.0)  sel (16|M16)             acc0.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw              {F@1}
(f1.0)  sel (16|M16)             acc2.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw             
(f0.0)  cmp (16|M0)   (eq)f0.0   null<1>:d     r34.0<1;1,0>:d    0:w              
        and (16|M16)  (ne)f0.0   null<1>:uw    acc0.0<1;1,0>:uw  acc2.0<1;1,0>:uw
(f0.0)  goto (32|M0)                         L21168                  L22928                
L21168:
        join (32|M0)                         L22928                                
L21184:
        add (16|M0)              r4.0<1>:d     -r38.0<1;1,0>:d   39:w               {Compacted}
        add (16|M16)             r12.0<1>:d    -r36.0<1;1,0>:d   39:w               {Compacted}
        and (16|M0)   (ne)f0.0   r14.0<1>:d    r4.0<1;1,0>:d     63:w               {Compacted,I@2}
        and (16|M16)  (ne)f0.0   r2.0<1>:d     r12.0<1;1,0>:d    63:w               {I@2}
        add (16|M0)              r66.0<1>:d    -r38.0<1;1,0>:d   40:w               {Compacted}
        add (16|M16)             r68.0<1>:d    -r36.0<1;1,0>:d   40:w               {Compacted}
(f0.0)  goto (32|M0)                         L21296                  L21296                
L21256:
        mov (16|M0)              r34.0<1>:f    r48.0<1;1,0>:f                   {Compacted}
        mov (16|M16)             r32.0<1>:d    r44.0<1;1,0>:d                  
        goto (32|M0)                         L21296                  L21560                
L21296:
        join (32|M0)                         L21560                                
L21312:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r14.0<1;1,0>:ud   0x20:uw              {I@7}
        cmp (16|M16)  (lt)f1.0   null<1>:d     r2.0<1;1,0>:ud    0x20:uw              {I@7}
(f1.0)  goto (32|M0)                         L21424                  L21424                
L21360:
        add (16|M0)              r4.0<1>:d     r14.0<1;1,0>:d    -32:w               {Compacted}
        add (16|M16)             r12.0<1>:d    r2.0<1;1,0>:d     -32:w               {Compacted}
        shr (16|M0)              r18.0<1>:ud   r42.0<1;1,0>:ud   r4.0<1;1,0>:d    {I@2}
        shr (16|M16)             r54.0<1>:ud   r40.0<1;1,0>:ud   r12.0<1;1,0>:d   {I@2}
        goto (32|M0)                         L21424                  L21520                
L21424:
        join (32|M0)                         L21520                                
L21440:
        add (16|M0)              r4.0<1>:d     -r14.0<1;1,0>:d   32:w               {Compacted}
        add (16|M16)             r12.0<1>:d    -r2.0<1;1,0>:d    32:w               {Compacted}
        shr (16|M16)             r16.0<1>:ud   r44.0<1;1,0>:ud   r2.0<1;1,0>:d   
        shl (16|M0)              r4.0<1>:d     r42.0<1;1,0>:d    r4.0<1;1,0>:d    {Compacted,I@3}
        shr (16|M0)              r14.0<1>:ud   r48.0<1;1,0>:ud   r14.0<1;1,0>:d  
        shl (16|M16)             r12.0<1>:d    r40.0<1;1,0>:d    r12.0<1;1,0>:d   {Compacted,I@4}
        or (16|M0)               r18.0<1>:d    r14.0<1;1,0>:d    r4.0<1;1,0>:d    {Compacted,I@2}
        or (16|M16)              r54.0<1>:d    r16.0<1;1,0>:d    r12.0<1;1,0>:d   {Compacted,I@2}
L21520:
        join (32|M0)                         L21560                                
L21536:
        mov (16|M0)              r34.0<1>:f    r18.0<1;1,0>:f                   {Compacted,I@3}
        mov (16|M16)             r32.0<1>:d    r54.0<1;1,0>:d                   {I@2}
L21560:
        join (32|M0)                         L22928                                
L21576:
        add (16|M0)              r20.0<1>:d    -r38.0<1;1,0>:d   38:w               {Compacted}
        add (16|M16)             r2.0<1>:d     -r36.0<1;1,0>:d   38:w               {Compacted}
        and (16|M0)   (ne)f0.0   r14.0<1>:d    r20.0<1;1,0>:d    63:w               {Compacted,I@2}
        and (16|M16)  (ne)f0.0   r16.0<1>:d    r2.0<1;1,0>:d     63:w               {I@2}
(f0.0)  goto (32|M0)                         L21672                  L21672                
L21632:
        mov (16|M0)              r18.0<1>:f    r48.0<1;1,0>:f                   {Compacted}
        mov (16|M16)             r54.0<1>:d    r44.0<1;1,0>:d                  
        goto (32|M0)                         L21672                  L21896                
L21672:
        join (32|M0)                         L21896                                
L21688:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r14.0<1;1,0>:ud   0x20:uw              {I@6}
        cmp (16|M16)  (lt)f1.0   null<1>:d     r16.0<1;1,0>:ud   0x20:uw              {I@6}
(f1.0)  goto (32|M0)                         L21800                  L21800                
L21736:
        add (16|M0)              r4.0<1>:d     r14.0<1;1,0>:d    -32:w               {Compacted}
        add (16|M16)             r12.0<1>:d    r16.0<1;1,0>:d    -32:w               {Compacted}
        shr (16|M0)              r18.0<1>:ud   r42.0<1;1,0>:ud   r4.0<1;1,0>:d    {A@1}
        shr (16|M16)             r54.0<1>:ud   r40.0<1;1,0>:ud   r12.0<1;1,0>:d   {I@2}
        goto (32|M0)                         L21800                  L21896                
L21800:
        join (32|M0)                         L21896                                
L21816:
        add (16|M0)              r4.0<1>:d     -r14.0<1;1,0>:d   32:w               {Compacted}
        add (16|M16)             r12.0<1>:d    -r16.0<1;1,0>:d   32:w               {Compacted}
        shl (16|M0)              r4.0<1>:d     r42.0<1;1,0>:d    r4.0<1;1,0>:d    {Compacted,I@2}
        shr (16|M0)              r14.0<1>:ud   r48.0<1;1,0>:ud   r14.0<1;1,0>:d  
        shl (16|M16)             r12.0<1>:d    r40.0<1;1,0>:d    r12.0<1;1,0>:d   {Compacted,I@3}
        shr (16|M16)             r16.0<1>:ud   r44.0<1;1,0>:ud   r16.0<1;1,0>:d  
        or (16|M0)               r18.0<1>:d    r14.0<1;1,0>:d    r4.0<1;1,0>:d    {Compacted,I@3}
        or (16|M16)              r54.0<1>:d    r16.0<1;1,0>:d    r12.0<1;1,0>:d   {Compacted,I@2}
L21896:
        join (32|M0)                         L22928                                
L21912:
        and (16|M0)   (ne)f0.0   r4.0<1>:d     r20.0<1;1,0>:d    63:w               {Compacted}
        and (16|M16)  (ne)f0.0   r20.0<1>:d    r2.0<1;1,0>:d     63:w              
        and (16|M0)              r38.0<1>:d    r18.0<1;1,0>:d    1:w               {Compacted,I@5}
        and (16|M16)             r56.0<1>:d    r54.0<1;1,0>:d    1:w               {Compacted,I@5}
(f0.0)  goto (32|M0)                         L22048                  L22048                
L21968:
        mov (16|M0)              r4.0<1>:d     -1:w                              
        mov (16|M16)             r14.0<1>:d    -1:w                              
        mov (16|M0)              r18.0<1>:d    -1:w                              
        mov (16|M16)             r16.0<1>:d    -1:w                              
        goto (32|M0)                         L22048                  L22320                
L22048:
        join (32|M0)                         L22320                                
L22064:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r4.0<1;1,0>:ud    0x20:uw              {I@6}
        cmp (16|M16)  (lt)f1.0   null<1>:d     r20.0<1;1,0>:ud   0x20:uw             
(f1.0)  goto (32|M0)                         L22224                  L22224                
L22112:
        add (16|M0)              r4.0<1>:d     r4.0<1;1,0>:d     -32:w               {Compacted}
        add (16|M16)             r12.0<1>:d    r20.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r3.0<1>:hf    -qnan(0x1FF):hf                             
        mov (16|M16)             r14.0<1>:d    0:w                              
        shl (16|M0)              r18.0<1>:d    r3.0<0;1,0>:w     r4.0<1;1,0>:d    {A@1}
        shl (16|M16)             r16.0<1>:d    r3.0<0;1,0>:w     r12.0<1;1,0>:d   {I@3}
        mov (16|M0)              r4.0<1>:d     0:w                              
        goto (32|M0)                         L22224                  L22320                
L22224:
        join (32|M0)                         L22320                                
L22240:
(W)     mov (1|M0)               r3.0<1>:hf    -qnan(0x1FF):hf                              {I@4}
        mov (16|M0)              r18.0<1>:d    -1:w                              
        mov (16|M16)             r16.0<1>:d    -1:w                              
        shl (16|M0)              r4.0<1>:d     r3.0<0;1,0>:w     r4.0<1;1,0>:d    {A@1}
        shl (16|M16)             r14.0<1>:d    r3.0<0;1,0>:w     r20.0<1;1,0>:d  
L22320:
        join (32|M0)                         L22928                                
L22336:
        bfn.0x60 (16|M0)         r4.0<1>:ud    r4.0<1;0>:ud      r10.2<0;0>:ud     r48.0<1>:ud      {I@3} // (s0^s1)&s2
        bfn.0x60 (16|M16)        r12.0<1>:ud   r14.0<1;0>:ud     r10.2<0;0>:ud     r44.0<1>:ud      {I@3} // (s0^s1)&s2
        cmp (16|M0)   (ne)f1.0   null<1>:d     r4.0<1;1,0>:d     0:w               {I@2}
        cmp (16|M16)  (ne)f1.0   null<1>:d     r12.0<1;1,0>:d    0:w               {I@2}
        bfn.0x60 (16|M16)        r16.0<1>:ud   r16.0<1;0>:ud     r10.2<0;0>:ud     r40.0<1>:ud      // (s0^s1)&s2
        bfn.0x60 (16|M0)         r14.0<1>:ud   r18.0<1;0>:ud     r10.2<0;0>:ud     r42.0<1>:ud      // (s0^s1)&s2
(~f1.0) cmp (16|M16)  (ne)f1.0   null<1>:d     r16.0<1;1,0>:d    0:w               {I@2}
(~f1.0) cmp (16|M0)   (ne)f1.0   null<1>:d     r14.0<1;1,0>:d    0:w               {I@2}
(W)     mov (1|M0)               r3.0<1>:hf    -qnan(0x1FF):hf                             
        and (16|M0)   (ne)f0.0   r14.0<1>:d    r66.0<1;1,0>:d    63:w               {Compacted}
(f1.0)  sel (16|M0)              r18.0<1>:d    r3.0<0;1,0>:w     0:w               {F@1}
(f1.0)  sel (16|M16)             r20.0<1>:d    r3.0<0;1,0>:w     0:w              
        and (16|M16)  (ne)f0.0   r2.0<1>:d     r68.0<1;1,0>:d    63:w              
        mov (16|M0)              r62.0<1>:d    -r18.0<1;1,0>:d                  {I@3}
        mov (16|M16)             r58.0<1>:d    -r20.0<1;1,0>:d                  {I@3}
(f0.0)  goto (32|M0)                         L22624                  L22624                
L22584:
        mov (16|M0)              r18.0<1>:f    r48.0<1;1,0>:f                   {Compacted,I@3}
        mov (16|M16)             r54.0<1>:d    r44.0<1;1,0>:d                  
        goto (32|M0)                         L22624                  L22848                
L22624:
        join (32|M0)                         L22848                                
L22640:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r14.0<1;1,0>:ud   0x20:uw             
        cmp (16|M16)  (lt)f1.0   null<1>:d     r2.0<1;1,0>:ud    0x20:uw             
(f1.0)  goto (32|M0)                         L22752                  L22752                
L22688:
        add (16|M0)              r4.0<1>:d     r14.0<1;1,0>:d    -32:w               {Compacted}
        add (16|M16)             r12.0<1>:d    r2.0<1;1,0>:d     -32:w               {Compacted}
        shr (16|M0)              r18.0<1>:ud   r42.0<1;1,0>:ud   r4.0<1;1,0>:d    {A@1}
        shr (16|M16)             r54.0<1>:ud   r40.0<1;1,0>:ud   r12.0<1;1,0>:d   {I@2}
        goto (32|M0)                         L22752                  L22848                
L22752:
        join (32|M0)                         L22848                                
L22768:
        add (16|M0)              r4.0<1>:d     -r14.0<1;1,0>:d   32:w               {Compacted}
        add (16|M16)             r12.0<1>:d    -r2.0<1;1,0>:d    32:w               {Compacted}
        shr (16|M16)             r16.0<1>:ud   r44.0<1;1,0>:ud   r2.0<1;1,0>:d   
        shl (16|M0)              r4.0<1>:d     r42.0<1;1,0>:d    r4.0<1;1,0>:d    {Compacted,I@3}
        shr (16|M0)              r14.0<1>:ud   r48.0<1;1,0>:ud   r14.0<1;1,0>:d  
        shl (16|M16)             r12.0<1>:d    r40.0<1;1,0>:d    r12.0<1;1,0>:d   {Compacted,I@4}
        or (16|M0)               r18.0<1>:d    r14.0<1;1,0>:d    r4.0<1;1,0>:d    {Compacted,I@2}
        or (16|M16)              r54.0<1>:d    r16.0<1;1,0>:d    r12.0<1;1,0>:d   {Compacted,I@2}
L22848:
        join (32|M0)                         L22928                                
L22864:
        mov (16|M0)              r42.0<1>:f    r18.0<1;1,0>:f                   {Compacted,I@3}
        mov (16|M16)             r6.0<1>:f     r54.0<1;1,0>:f                   {Compacted,I@2}
        mov (16|M0)              r18.0<1>:d    r34.0<1;1,0>:d                   {F@2}
        mov (16|M16)             r54.0<1>:d    r32.0<1;1,0>:d                   {F@1}
        goto (32|M0)                         L22928                  L23088                
L22928:
        join (32|M0)                         L23088                                
L22944:
        shr (16|M0)              r18.0<1>:ud   r48.0<1;1,0>:ud   2:w              
        shr (16|M16)             r54.0<1>:ud   r44.0<1;1,0>:ud   2:w              
        mov (16|M0)              r62.0<1>:d    0:w                              
        mov (16|M16)             r58.0<1>:d    0:w                              
        mov (16|M0)              r38.0<1>:d    0:w                              
        mov (16|M16)             r56.0<1>:d    0:w                              
        mov (16|M0)              r42.0<1>:f    r18.0<1;1,0>:f                   {Compacted,I@6}
        mov (16|M16)             r6.0<1>:f     r54.0<1;1,0>:f                   {Compacted,I@5}
        shr (16|M0)              r18.0<1>:ud   r48.0<1;1,0>:ud   1:w               {F@2}
        shr (16|M16)             r54.0<1>:ud   r44.0<1;1,0>:ud   1:w               {F@1}
L23088:
        join (32|M0)                         L23936                                
L23104:
        shl (16|M0)              r4.0<1>:d     r18.0<1;1,0>:d    2:w               {Compacted,I@3}
        shl (16|M16)             r12.0<1>:d    r54.0<1;1,0>:d    2:w               {Compacted,I@3}
        shl (16|M0)              r14.0<1>:d    r38.0<1;1,0>:d    1:w               {Compacted}
        shl (16|M16)             r16.0<1>:d    r56.0<1;1,0>:d    1:w               {Compacted}
        and (16|M0)              r4.0<1>:d     r4.0<1;1,0>:d     4:w               {Compacted,I@4}
        and (16|M16)             r12.0<1>:d    r12.0<1;1,0>:d    4:w               {Compacted,I@4}
        bfn.0xFE (16|M0)         r4.0<1>:ud    r4.0<1;0>:ud      r14.0<1;0>:ud     r62.0<1>:ud      {I@2} // s0|s1|s2
        bfn.0xFE (16|M16)        r12.0<1>:ud   r12.0<1;0>:ud     r16.0<1;0>:ud     r58.0<1>:ud      {I@2} // s0|s1|s2
        cmp (16|M0)   (eq)f0.0   null<1>:d     r4.0<1;1,0>:d     0:w               {Compacted,I@2}
        cmp (16|M16)  (eq)f0.0   null<1>:d     r12.0<1;1,0>:d    0:w               {I@2}
        and (16|M0)              r32.0<1>:d    r42.0<1;1,0>:d    8388607:d              
        and (16|M16)             r20.0<1>:d    r6.0<1;1,0>:d     8388607:d              
(~f0.0) goto (32|M0)                         L23304                  L23304                
L23256:
        mov (16|M0)              r4.0<1>:d     0:w                              
        mov (16|M16)             r14.0<1>:d    0:w                              
        goto (32|M0)                         L23304                  L23536                
L23304:
        join (32|M0)                         L23536                                
L23320:
        cmp (16|M0)   (gt)f1.0   null<1>:d     r4.0<1;1,0>:ud    0x4:uw              {I@4}
        cmp (16|M16)  (gt)f1.0   null<1>:d     r12.0<1;1,0>:ud   0x4:uw             
(~f1.0) goto (32|M0)                         L23416                  L23416                
L23368:
        mov (16|M0)              r4.0<1>:d     1:w                              
        mov (16|M16)             r14.0<1>:d    1:w                              
        goto (32|M0)                         L23416                  L23536                
L23416:
        join (32|M0)                         L23536                                
L23432:
        and (16|M0)   (ne)f0.0   null<1>:d     r42.0<1;1,0>:d    1:w               {Compacted}
        and (16|M16)  (ne)f0.0   null<1>:d     r6.0<1;1,0>:d     1:w              
(f0.0)  cmp (16|M0)   (eq)f0.0   null<1>:d     r4.0<1;1,0>:d     4:w               {I@6}
(f0.0)  cmp (16|M16)  (eq)f0.0   null<1>:d     r12.0<1;1,0>:d    4:w              
(W)     mov (1|M0)               r3.0<1>:hf    0x1:hf                             
(f0.0)  sel (16|M0)              r4.0<1>:d     r3.0<0;1,0>:w     0:w               {F@1}
(f0.0)  sel (16|M16)             r14.0<1>:d    r3.0<0;1,0>:w     0:w              
L23536:
        join (32|M0)                         L23936                                
L23552:
        add (16|M0)              r16.0<1>:d    r32.0<1;1,0>:d    r4.0<1;1,0>:d    {Compacted,I@3}
        add (16|M16)             r14.0<1>:d    r20.0<1;1,0>:d    r14.0<1;1,0>:d   {Compacted,I@3}
        cmp (16|M0)   (gt)f0.0   null<1>:d     r16.0<1;1,0>:ud   0x7FFFFF:ud              {I@2}
        cmp (16|M16)  (gt)f0.0   null<1>:d     r14.0<1;1,0>:ud   0x7FFFFF:ud              {I@2}
        add3 (16|M16)            r12.0<1>:d    r50.0<1;0>:d      r24.0<1;0>:d      -45:w              
        add3 (16|M0)             r4.0<1>:d     r52.0<1;0>:d      r30.0<1;0>:d      -45:w              
(f0.0)  sel (16|M16)             r2.0<1>:d     r12.0<1;1,0>:d    r64.0<1;1,0>:d   {I@2}
(f0.0)  sel (16|M0)              r6.0<1>:d     r4.0<1;1,0>:d     r60.0<1;1,0>:d   {Compacted,I@2}
        cmp (16|M16)  (eq)f1.0   null<1>:d     r2.0<1;1,0>:d     255:w               {I@2}
        cmp (16|M0)   (eq)f1.0   null<1>:d     r6.0<1;1,0>:d     255:w               {I@2}
(f1.0)  goto (32|M0)                         L23840                  L23840                
L23704:
(~f0.0) sel (16|M0)              r4.0<1>:d     r16.0<1;1,0>:d    0:w              
(~f0.0) sel (16|M16)             r12.0<1>:d    r14.0<1;1,0>:d    0:w              
        shl (16|M0)              r18.0<1>:d    r6.0<1;1,0>:d     23:w               {Compacted}
        shl (16|M16)             r20.0<1>:d    r2.0<1;1,0>:d     23:w               {Compacted}
        and (16|M16)             r16.0<1>:d    r28.0<1;1,0>:d    -2147483648:d              
        and (16|M0)              r14.0<1>:d    r22.0<1;1,0>:d    -2147483648:d              
        sync.nop                             null                             {Compacted,$15.src}
        bfn.0xFE (16|M16)        r26.0<1>:ud   r16.0<1;0>:ud     r20.0<1;0>:ud     r12.0<1>:ud      {I@2} // s0|s1|s2
        bfn.0xFE (16|M0)         r22.0<1>:ud   r14.0<1;0>:ud     r18.0<1;0>:ud     r4.0<1>:ud       {I@2} // s0|s1|s2
        goto (32|M0)                         L23840                  L24720                
L23840:
        join (32|M0)                         L23936                                
L23856:
        cmp (16|M0)   (gt)f1.0   null<1>:d     r22.0<1;1,0>:d    -1:w               {I@3}
        cmp (16|M16)  (gt)f1.0   null<1>:d     r28.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r3.0<1>:f     inf:f                               {Compacted}
(f1.0)  sel (16|M0)              r22.0<1>:f    r3.0<0;1,0>:f     -inf:f               {Compacted,A@1}
(f1.0)  sel (16|M16)             r26.0<1>:f    r3.0<0;1,0>:f     -inf:f               {$15.src}
        goto (32|M0)                         L23936                  L24720                
L23936:
        join (32|M0)                         L24400                                
L23952:
        and (16|M0)   (ne)f0.0   r4.0<1>:d     r30.0<1;1,0>:d    63:w               {Compacted}
        and (16|M16)  (ne)f0.0   r12.0<1>:d    r24.0<1;1,0>:d    63:w              
(f0.0)  goto (32|M0)                         L24040                  L24040                
L23992:
        mov (16|M0)              r4.0<1>:d     -1:w                              
        mov (16|M16)             r6.0<1>:d     -1:w                              
        goto (32|M0)                         L24040                  L24216                
L24040:
        join (32|M0)                         L24216                                
L24056:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r4.0<1;1,0>:ud    0x20:uw              {A@1}
        cmp (16|M16)  (lt)f1.0   null<1>:d     r12.0<1;1,0>:ud   0x20:uw             
(f1.0)  goto (32|M0)                         L24152                  L24152                
L24104:
        mov (16|M0)              r4.0<1>:d     0:w                              
        mov (16|M16)             r6.0<1>:d     0:w                              
        goto (32|M0)                         L24152                  L24216                
L24152:
        join (32|M0)                         L24216                                
L24168:
(W)     mov (1|M0)               r3.0<1>:hf    -qnan(0x1FF):hf                             
        shl (16|M0)              r4.0<1>:d     r3.0<0;1,0>:w     r4.0<1;1,0>:d    {A@1}
        shl (16|M16)             r6.0<1>:d     r3.0<0;1,0>:w     r12.0<1;1,0>:d  
L24216:
        join (32|M0)                         L24400                                
L24232:
        bfn.0x60 (16|M0)         r4.0<1>:ud    r4.0<1;0>:ud      r10.2<0;0>:ud     r48.0<1>:ud      {I@3} // (s0^s1)&s2
        bfn.0x60 (16|M16)        r12.0<1>:ud   r6.0<1;0>:ud      r10.2<0;0>:ud     r44.0<1>:ud      {I@3} // (s0^s1)&s2
        add (16|M0)              r14.0<1>:d    -r30.0<1;1,0>:d   23:w               {Compacted}
        add (16|M16)             r16.0<1>:d    -r24.0<1;1,0>:d   23:w               {Compacted}
        and (16|M0)              r18.0<1>:d    r22.0<1;1,0>:d    -2147483648:d              
        and (16|M16)             r20.0<1>:d    r28.0<1;1,0>:d    -2147483648:d              
        shl (16|M0)              r4.0<1>:d     r4.0<1;1,0>:d     r14.0<1;1,0>:d   {Compacted,I@4}
        shl (16|M16)             r12.0<1>:d    r12.0<1;1,0>:d    r16.0<1;1,0>:d   {Compacted,I@4}
        shl (16|M16)             r24.0<1>:d    r64.0<1;1,0>:d    23:w               {Compacted}
        shl (16|M0)              r22.0<1>:d    r60.0<1;1,0>:d    23:w               {Compacted}
        sync.nop                             null                             {Compacted,$15.src}
        bfn.0xFE (16|M16)        r26.0<1>:ud   r20.0<1;0>:ud     r24.0<1;0>:ud     r12.0<1>:ud      {I@2} // s0|s1|s2
        bfn.0xFE (16|M0)         r22.0<1>:ud   r18.0<1;0>:ud     r22.0<1;0>:ud     r4.0<1>:ud       {I@2} // s0|s1|s2
        goto (32|M0)                         L24400                  L24720                
L24400:
        join (32|M0)                         L24488                                
L24416:
        cmp (16|M0)   (gt)f0.0   null<1>:d     r22.0<1;1,0>:d    -1:w               {Compacted,I@3}
        cmp (16|M16)  (gt)f0.0   null<1>:d     r28.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r3.0<1>:f     inf:f                               {Compacted}
(f0.0)  sel (16|M0)              r22.0<1>:f    r3.0<0;1,0>:f     -inf:f               {Compacted,A@1}
(f0.0)  sel (16|M16)             r26.0<1>:f    r3.0<0;1,0>:f     -inf:f               {$15.src}
        goto (32|M0)                         L24488                  L24720                
L24488:
        join (32|M0)                         L24576                                
L24504:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r22.0<1;1,0>:d    0:w               {Compacted,F@2}
        cmp (16|M16)  (lt)f1.0   null<1>:d     r28.0<1;1,0>:d    0:w              
(W)     mov (1|M0)               r3.0<1>:f     -0.0:f                               {Compacted}
(f1.0)  sel (16|M0)              r22.0<1>:f    r3.0<0;1,0>:f     0.0:f               {Compacted,A@1}
(f1.0)  sel (16|M16)             r26.0<1>:f    r3.0<0;1,0>:f     0.0:f               {$15.src}
        goto (32|M0)                         L24576                  L24720                
L24576:
        join (32|M0)                         L24664                                
L24592:
        cmp (16|M0)   (gt)f0.0   null<1>:d     r22.0<1;1,0>:d    -1:w               {Compacted,F@2}
        cmp (16|M16)  (gt)f0.0   null<1>:d     r28.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r3.0<1>:f     inf:f                               {Compacted}
(f0.0)  sel (16|M0)              r22.0<1>:f    r3.0<0;1,0>:f     -inf:f               {Compacted,A@1}
(f0.0)  sel (16|M16)             r26.0<1>:f    r3.0<0;1,0>:f     -inf:f               {$15.src}
        goto (32|M0)                         L24664                  L24720                
L24664:
        join (32|M0)                         L24720                                
L24680:
        bfn.0xF8 (16|M0)         r22.0<1>:ud   r22.0<1;0>:ud     r10.4<0;0>:ud     r10.3<0>:ud      {F@2} // s0&s1|s2
        sync.nop                             null                             {Compacted,$15.src}
        bfn.0xF8 (16|M16)        r26.0<1>:ud   r28.0<1;0>:ud     r10.4<0;0>:ud     r10.3<0>:ud      {F@1} // s0&s1|s2
L24720:
        join (32|M0)                         L47048                                
L24736:
        cmp (16|M0)   (lt)f1.0   null<1>:f     r78.0<1;1,0>:f    0.0:f               {Compacted}
        cmp (16|M16)  (lt)f1.0   null<1>:f     r76.0<1;1,0>:f    0.0:f              
(f1.0)  sel (16|M0)              r4.0<1>:f     -r22.0<1;1,0>:f   r22.0<1;1,0>:f   {Compacted,I@3}
(f1.0)  sel (16|M16)             r12.0<1>:f    -r26.0<1;1,0>:f   r26.0<1;1,0>:f   {I@2}
(W)     shl (1|M0)               r7.6<1>:d     r10.6<0;1,0>:d    1:w              
(W)     mov (1|M0)               a0.0<1>:ud    r9.7<0;1,0>:d                    {A@1}
        mov (8|M0)               r3.0<1>:hf    r4.0<1;1,0>:f                    {F@2}
        mov (8|M8)               r3.8<1>:hf    r5.0<1;1,0>:f                   
        mov (8|M16)              r6.0<1>:hf    r12.0<1;1,0>:f                   {F@3}
        mov (8|M24)              r6.8<1>:hf    r13.0<1;1,0>:f                  
(W)     mov (1|M0)               f1.0<1>:ud    r10.7<0;1,0>:ud                 
        add3 (16|M0)             r14.0<1>:d    r92.0<1;0>:d      r9.4<0;0>:d       r7.6<0>:d        {I@3}
        add3 (16|M16)            r16.0<1>:d    r90.0<1;0>:d      r9.4<0;0>:d       r7.6<0>:d       
        mov (16|M0)              r18.0<1>:ud   r3.0<1;1,0>:uw                   {A@3}
        mov (16|M16)             r20.0<1>:ud   r6.0<1;1,0>:uw                   {A@1}
        send.ugm (16|M0)         null     r14     r18:2   a0.0        0x240E0B04           {ExBSO,A@2,$13} // wr:2+2, rd:0; store.ugm.d16u32.a32.wb.wb.bss[a0.0]
        send.ugm (16|M16)        null     r16     r20:2   a0.0        0x240E0B04           {ExBSO,A@1,$0} // wr:2+2, rd:0; store.ugm.d16u32.a32.wb.wb.bss[a0.0]
(W)     or (1|M0)                r10.5<1>:d    r10.6<0;1,0>:d    1:w              
(f1.0)  goto (32|M0)                         L25192                  L25192                
L25024:
(W)     shl (1|M0)               r3.0<1>:d     r10.5<0;1,0>:d    1:w               {Compacted,I@2}
(W)     mov (1|M0)               a0.0<1>:ud    r10.0<0;1,0>:d                   {A@1}
        add3 (16|M0)             r4.0<1>:d     r88.0<1;0>:d      r9.5<0;0>:d       r3.0<0>:d        {I@2}
        add3 (16|M16)            r12.0<1>:d    r86.0<1;0>:d      r9.5<0;0>:d       r3.0<0>:d       
        send.ugm (16|M0)         r14      r4      null:0  a0.0        0x24280B00           {ExBSO,A@2,$1} // wr:2+0, rd:2; load.ugm.d16u32.a32.ca.ca.bss[a0.0]
        send.ugm (16|M16)        r16      r12     null:0  a0.0        0x24280B00           {ExBSO,A@1,$2} // wr:2+0, rd:2; load.ugm.d16u32.a32.ca.ca.bss[a0.0]
        mov (16|M0)              r6.0<1>:uw    r14.0<2;1,0>:uw                  {$1.dst}
        mov (16|M16)             r11.0<1>:uw   r16.0<2;1,0>:uw                  {$2.dst}
        mov (16|M0)              r78.0<1>:f    r6.0<1;1,0>:hf                   {I@2}
        mov (16|M16)             r76.0<1>:f    r11.0<1;1,0>:hf                  {I@1}
        goto (32|M0)                         L25192                  L25296                
L25192:
        join (32|M0)                         L25296                                
L25208:
(W)     shl (1|M0)               r3.0<1>:d     r10.5<0;1,0>:d    2:w               {Compacted}
(W)     mov (1|M0)               a0.0<1>:ud    r10.1<0;1,0>:d                   {A@1}
        add3 (16|M0)             r4.0<1>:d     r96.0<1;0>:d      r9.6<0;0>:d       r3.0<0>:d        {I@2}
        add3 (16|M16)            r12.0<1>:d    r94.0<1;0>:d      r9.6<0;0>:d       r3.0<0>:d       
        send.ugm (16|M0)         r78      r4      null:0  a0.0        0x24280500           {ExBSO,A@2,$4} // wr:2+0, rd:2; load.ugm.d32.a32.ca.ca.bss[a0.0]
        send.ugm (16|M16)        r76      r12     null:0  a0.0        0x24280500           {ExBSO,A@1,$7} // wr:2+0, rd:2; load.ugm.d32.a32.ca.ca.bss[a0.0]
L25296:
        join (32|M0)                         L47048                                
L25312:
        and (16|M0)              r4.0<1>:d     r78.0<1;1,0>:d    2147483647:d               {$4.dst}
        and (16|M16)             r12.0<1>:d    r76.0<1;1,0>:d    2147483647:d               {$7.dst}
        sel (16|M0)   (lt)f0.0   r22.0<1>:f    r4.0<1;1,0>:f     448.0:f               {Compacted,I@2}
        sel (16|M16)  (lt)f0.0   r24.0<1>:f    r12.0<1;1,0>:f    448.0:f               {I@1}
        shr (16|M0)              r12.0<1>:ud   r22.0<1;1,0>:ud   23:w               {A@1}
        shr (16|M16)             r6.0<1>:ud    r24.0<1;1,0>:ud   23:w              
        sync.nop                             null                             {Compacted,$0.src}
        and (16|M0)              r20.0<1>:d    r12.0<1;1,0>:d    255:w               {Compacted,I@2}
        sync.nop                             null                             {Compacted,$13.src}
        and (16|M16)             r18.0<1>:d    r6.0<1;1,0>:d     255:w               {Compacted,I@2}
        sel (16|M0)   (ge)f0.0   r14.0<1>:ud   r20.0<1;1,0>:ud   0x79:uw              {I@2}
        sel (16|M16)  (ge)f0.0   r16.0<1>:ud   r18.0<1;1,0>:ud   0x79:uw              {I@2}
        cmp (16|M16)  (eq)f1.0   null<1>:d     r18.0<1;1,0>:d    255:w              
        shl (16|M0)              r82.0<1>:d    r14.0<1;1,0>:d    23:w               {Compacted,I@3}
        and (16|M16)  (ne)f0.0   r14.0<1>:d    r24.0<1;1,0>:d    8388607:d              
(W)     mov (1|M0)               r3.0<1>:hf    0x1:hf                             
        shl (16|M16)             r84.0<1>:d    r16.0<1;1,0>:d    23:w               {Compacted,I@4}
        and (16|M0)   (ne)f1.0   r16.0<1>:d    r22.0<1;1,0>:d    8388607:d              
(f1.0)  sel (16|M16)             acc0.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw              {F@1}
(f0.0)  sel (16|M16)             acc2.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw             
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r20.0<1;1,0>:d    255:w              
        and (16|M16)  (ne)f1.0   null<1>:uw    acc0.0<1;1,0>:uw  acc2.0<1;1,0>:uw
(~f1.0) goto (32|M0)                         L25664                  L25664                
L25624:
        mov (16|M0)              r22.0<1>:ud   0x7FC00000:ud                             
        mov (16|M16)             r28.0<1>:f    qnan(0x0):f                               {Compacted}
        goto (32|M0)                         L25664                  L35960                
L25664:
        join (32|M0)                         L35960                                
L25680:
        cmp (16|M16)  (eq)f1.0   null<1>:d     r14.0<1;1,0>:d    0:w               {I@7}
        cmp (16|M16)  (eq)f0.0   null<1>:d     r18.0<1;1,0>:d    255:w              
        cmp (16|M0)   (eq)f0.0   null<1>:d     r16.0<1;1,0>:d    0:w               {Compacted,I@7}
(W)     mov (1|M0)               r3.0<1>:hf    0x1:hf                              {I@7}
        add (16|M0)              r30.0<1>:d    -r82.0<1;1,0>:d   -2139095040:d              
(f0.0)  sel (16|M16)             acc0.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw              {F@1}
(f1.0)  sel (16|M16)             acc2.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw             
(f0.0)  cmp (16|M0)   (eq)f0.0   null<1>:d     r20.0<1;1,0>:d    255:w              
        and (16|M16)  (ne)f0.0   null<1>:uw    acc0.0<1;1,0>:uw  acc2.0<1;1,0>:uw
        add (16|M16)             r32.0<1>:d    -r84.0<1;1,0>:d   -2139095040:d               {$10.src}
        xor (16|M0)              r22.0<1>:d    r30.0<1;1,0>:d    r22.0<1;1,0>:d   {Compacted,I@6}
        sync.nop                             null                             {Compacted,$15.src}
        xor (16|M16)             r26.0<1>:d    r32.0<1;1,0>:d    r24.0<1;1,0>:d   {Compacted,I@2}
(f0.0)  goto (32|M0)                         L35912                  L35912                
L25872:
        or (16|M0)    (eq)f0.0   null<1>:d     r20.0<1;1,0>:d    r16.0<1;1,0>:d  
        or (16|M16)   (eq)f0.0   null<1>:d     r18.0<1;1,0>:d    r14.0<1;1,0>:d  
(~f0.0) goto (32|M0)                         L25960                  L25960                
L25920:
        mov (16|M0)              r22.0<1>:ud   0x0:ud                             
        mov (16|M16)             r28.0<1>:f    0.0:f                               {Compacted}
        goto (32|M0)                         L25960                  L35960                
L25960:
        join (32|M0)                         L35912                                
L25976:
        cmp (16|M0)   (eq)f1.0   null<1>:d     r20.0<1;1,0>:d    0:w              
        cmp (16|M16)  (eq)f1.0   null<1>:d     r18.0<1;1,0>:d    0:w              
        shr (16|M0)              r60.0<1>:ud   r30.0<1;1,0>:ud   23:w              
        shr (16|M16)             r64.0<1>:ud   r32.0<1;1,0>:ud   23:w              
        add (16|M0)              r58.0<1>:d    r20.0<1;1,0>:d    -127:w               {Compacted}
        add (16|M16)             r56.0<1>:d    r18.0<1;1,0>:d    -127:w               {Compacted}
(f1.0)  mov (16|M0)              r58.0<1>:d    -126:w                              
(f1.0)  mov (16|M16)             r56.0<1>:d    -126:w                              
        add (16|M0)              r52.0<1>:d    r60.0<1;1,0>:d    r58.0<1;1,0>:d   {Compacted,I@2}
        add (16|M16)             r50.0<1>:d    r64.0<1;1,0>:d    r56.0<1;1,0>:d   {Compacted,I@2}
        cmp (16|M0)   (gt)f0.0   null<1>:d     r52.0<1;1,0>:d    254:w               {Compacted,I@2}
        cmp (16|M16)  (gt)f0.0   null<1>:d     r50.0<1;1,0>:d    254:w               {I@2}
(f0.0)  goto (32|M0)                         L35816                  L35816                
L26144:
        or (16|M0)    (eq)f0.0   null<4>:b     r12.0<1;1,0>:d    r60.0<1;1,0>:d  
        or (16|M16)   (eq)f0.0   null<4>:b     r6.0<1;1,0>:d     r64.0<1;1,0>:d  
(f0.0)  goto (32|M0)                         L35728                  L35728                
L26192:
(W)     mov (1|M0)               r3.0<1>:hf    0.0:hf                             
(W)     mov (1|M0)               r2.3<1>:d     0:w                              
(f1.0)  sel (16|M0)              r4.0<1>:d     r3.0<0;1,0>:w     8388608:d               {F@1}
(f1.0)  sel (16|M16)             r12.0<1>:d    r3.0<0;1,0>:w     8388608:d              
        or (16|M0)               r4.0<1>:d     r4.0<1;1,0>:d     r16.0<1;1,0>:d   {Compacted,I@2}
        or (16|M16)              r12.0<1>:d    r12.0<1;1,0>:d    r14.0<1;1,0>:d   {Compacted,I@2}
        shl (16|M0)              r48.0<1>:d    r4.0<1;1,0>:d     23:w               {Compacted,I@2}
        shr (16|M0)              r42.0<1>:ud   r4.0<1;1,0>:ud    9:w              
        shl (16|M16)             r44.0<1>:d    r12.0<1;1,0>:d    23:w               {Compacted,I@3}
        shr (16|M16)             r40.0<1>:ud   r12.0<1;1,0>:ud   9:w              
(W)     mov (1|M0)               r2.5<1>:f     -0.0:f                               {Compacted}
(W)     mov (2|M0)               r2.0<1>:d     0:w                              
L26344:
(W)     shl (1|M0)               r3.0<1>:d     r2.5<0;1,0>:d     31:w               {Compacted,F@1}
(W)     shr (1|M0)               r3.1<1>:ud    r2.3<0;1,0>:ud    1:w              
(W)     addc (1|M0)              r7.0<1>:ud    r2.0<0;1,0>:ud    0x1:ud              {AccWrEn,I@3}
(W)     or (1|M0)                r2.3<1>:d     r3.1<0;1,0>:d     r3.0<0;1,0>:d    {I@2}
        bfn.0xE0 (16|M0)         r12.0<1>:ud   r3.1<0;0>:ud      r3.0<0;0>:ud      r48.0<1>:ud      // (s0|s1)&s2
        cmp (16|M0)   (eq)f0.0   null<1>:d     r12.0<1;1,0>:d    r2.3<0;1,0>:d    {I@1}
(W)     mov (1|M0)               r4.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        bfn.0xE0 (16|M16)        r14.0<1>:ud   r3.1<0;0>:ud      r3.0<0;0>:ud      r44.0<1>:ud      // (s0|s1)&s2
(W)     add (1|M0)               r2.4<1>:ud    r4.0<0;1,0>:ud    r2.1<0;1,0>:ud   {I@2}
(W)     mov (1|M0)               r4.0<1>:ud    f0.0<0;1,0>:ud                   {Compacted}
(W)     shr (1|M0)               r2.2<1>:ud    r2.5<0;1,0>:ud    1:w              
(W)     mov (1|M0)               f0.0<1>:ud    r4.0<0;1,0>:ud                   {I@2}
        cmp (16|M16)  (eq)f0.0   null<1>:d     r14.0<1;1,0>:d    r2.3<0;1,0>:d   
        and (16|M0)              r16.0<1>:d    r2.2<0;1,0>:d     r42.0<1;1,0>:d   {Compacted,I@3}
(W)     mov (1|M0)               r4.0<1>:ud    f0.0<0;1,0>:ud                   {Compacted}
(W)     cmp (16|M0)   (gt)f1.0   null<1>:d     r2.0<0;1,0>:ud    0x3E:uw             
(W)     mov (1|M0)               f0.0<1>:ud    r4.0<0;1,0>:ud                   {I@2}
        and (16|M16)             r18.0<1>:d    r2.2<0;1,0>:d     r40.0<1;1,0>:d   {Compacted}
(W&f1.0) cmp (16|M0)  (eq)f1.0   null<1>:d     r2.1<0;1,0>:d     0:w              
(f0.0)  cmp (16|M0)   (eq)f0.0   null<1>:d     r16.0<1;1,0>:d    r2.2<0;1,0>:d   
(W&~f1.0) cmp (16|M0) (gt)f1.0   null<1>:d     r2.1<0;1,0>:ud    0x0:uw             
(W)     mov (1|M0)               r4.0<1>:ud    f0.0<0;1,0>:ud                   {Compacted}
(W)     cmp (16|M16)  (gt)f1.0   null<1>:d     r2.0<0;1,0>:ud    0x3E:uw             
(W)     mov (1|M0)               f0.0<1>:ud    r4.0<0;1,0>:ud                   {I@2}
(W)     mov (1|M0)               r3.0<1>:hf    0x1:hf                             
(W&f1.0) cmp (16|M16) (eq)f1.0   null<1>:d     r2.1<0;1,0>:d     0:w              
(f0.0)  cmp (16|M16)  (eq)f0.0   null<1>:d     r18.0<1;1,0>:d    r2.2<0;1,0>:d   
(f1.0)  sel (16|M0)              acc0.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw              {F@1}
(f0.0)  sel (16|M0)              acc2.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw             
(W)     mov (1|M0)               r4.0<1>:ud    f0.0<0;1,0>:ud                   {Compacted}
        or (16|M0)    (ne)f0.0   null<1>:uw    acc0.0<1;1,0>:uw  acc2.0<1;1,0>:uw
(W&~f1.0) cmp (16|M16) (gt)f1.0  null<1>:d     r2.1<0;1,0>:ud    0x0:uw             
(W)     mov (1|M0)               r3.1<1>:ud    f0.0<0;1,0>:ud                   {Compacted}
(W)     mov (1|M0)               f0.0<1>:ud    r4.0<0;1,0>:ud                   {I@4}
(f1.0)  sel (16|M16)             acc0.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw             
(W)     mov (1|M0)               f1.0<1>:ud    r3.1<0;1,0>:ud                   {I@3}
(f0.0)  sel (16|M16)             acc2.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw             
        or (16|M16)   (ne)f1.0   null<1>:uw    acc0.0<1;1,0>:uw  acc2.0<1;1,0>:uw
        mov (16|M0)              r62.0<1>:f    r2.0<0;1,0>:f                    {Compacted}
(W)     mov (1|M0)               r3.1<1>:ud    f1.0<0;1,0>:ud                   {Compacted}
        mov (16|M16)             r54.0<1>:f    r2.0<0;1,0>:f                    {Compacted}
(W)     mov (1|M0)               f0.0<1>:ud    r3.1<0;1,0>:ud                   {I@1}
        mov (16|M16)             r20.0<1>:d    r2.1<0;1,0>:d                   
        mov (16|M0)              r38.0<1>:f    r7.0<0;1,0>:f                    {Compacted}
        mov (16|M16)             r36.0<1>:f    r7.0<0;1,0>:f                    {Compacted,$14.src}
        mov (16|M0)              r34.0<1>:d    r2.4<0;1,0>:d                   
        mov (16|M16)             r32.0<1>:d    r2.4<0;1,0>:d                   
        mov (16|M0)              r16.0<1>:d    r2.1<0;1,0>:d                   
(f0.0)  goto (32|M0)                         L27072                  L27072                
L27016:
(W)     mov (1|M0)               r2.5<1>:d     r2.2<0;1,0>:d                   
(W)     mov (1|M0)               r2.0<1>:f     r7.0<0;1,0>:f                    {Compacted}
(W)     mov (1|M0)               r2.1<1>:d     r2.4<0;1,0>:d                   
(W)     jmpi                                 L26344                                
L27072:
        join (32|M0)                         L35728                                
L27088:
(W)     mov (1|M0)               r3.0<1>:f     8.68805e-44:f                              
(W)     mov (1|M0)               r4.0<1>:hf    0.0:hf                             
        subb (8|M0)              r30.0<1>:ud   r3.0<0;1,0>:ud    r62.0<1;1,0>:ud  {AccWrEn,Compacted,F@2}
        add3 (8|M0)              r68.0<1>:ud   -acc0.0<1;0>:ud   r4.0<0;0>:uw      -r16.0<1>:ud     {A@1}
        subb (8|M8)              r31.0<1>:ud   r3.0<0;1,0>:ud    r63.0<1;1,0>:ud  {AccWrEn}
        add3 (8|M8)              r69.0<1>:ud   -acc0.0<1;0>:ud   r4.0<0;0>:uw      -r17.0<1>:ud    
        subb (8|M16)             r24.0<1>:ud   r3.0<0;1,0>:ud    r54.0<1;1,0>:ud  {AccWrEn}
        add3 (16|M0)             r18.0<1>:d    r52.0<1;0>:d      r30.0<1;0>:d      -173:w               {I@3}
        add3 (8|M16)             r80.0<1>:ud   -acc0.0<1;0>:ud   r4.0<0;0>:uw      -r20.0<1>:ud    
        subb (8|M24)             r25.0<1>:ud   r3.0<0;1,0>:ud    r55.0<1;1,0>:ud  {AccWrEn}
        cmp (16|M0)   (gt)f1.0   null<1>:d     r18.0<1;1,0>:d    127:w               {I@3}
        add3 (16|M16)            r64.0<1>:d    r64.0<1;0>:d      r56.0<1;0>:d      r24.0<1>:d       {I@2}
        add3 (16|M16)            r56.0<1>:d    r50.0<1;0>:d      r24.0<1;0>:d      -173:w              
        cmp (16|M16)  (gt)f1.0   null<1>:d     r56.0<1;1,0>:d    127:w               {I@1}
        add3 (16|M0)             r66.0<1>:d    r60.0<1;0>:d      r58.0<1;0>:d      r30.0<1>:d      
        add3 (8|M24)             r81.0<1>:ud   -acc0.0<1;0>:ud   r4.0<0;0>:uw      -r21.0<1>:ud    
(f1.0)  goto (32|M0)                         L35632                  L35632                
L27352:
        cmp (16|M0)   (gt)f0.0   null<1>:d     r18.0<1;1,0>:d    -127:w               {Compacted}
        cmp (16|M16)  (gt)f0.0   null<1>:d     r56.0<1;1,0>:d    -127:w              
(f0.0)  goto (32|M0)                         L31496                  L31496                
L27392:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r18.0<1;1,0>:ud   0xFFFFFF6B:ud             
        cmp (16|M16)  (lt)f1.0   null<1>:d     r56.0<1;1,0>:ud   0xFFFFFF6B:ud             
(f1.0)  goto (32|M0)                         L30736                  L30736                
L27440:
(W)     mov (1|M0)               r3.0<1>:f     8.82818e-44:f                              
        add3 (16|M0)             r34.0<1>:d    r52.0<1;0>:d      r30.0<1;0>:d      -23:w              
(W)     mov (1|M0)               r4.0<1>:hf    0.0:hf                              {I@7}
        subb (8|M0)              r30.0<1>:ud   r3.0<0;1,0>:ud    r62.0<1;1,0>:ud  {AccWrEn,Compacted,F@2}
        add3 (16|M16)            r60.0<1>:d    r50.0<1;0>:d      r24.0<1;0>:d      -23:w              
        add3 (8|M0)              r12.0<1>:ud   -acc0.0<1;0>:ud   r4.0<0;0>:uw      -r16.0<1>:ud     {F@1}
        subb (8|M8)              r31.0<1>:ud   r3.0<0;1,0>:ud    r63.0<1;1,0>:ud  {AccWrEn}
(W)     mov (1|M0)               r5.0<1>:hf    0x1:hf                             
        add3 (8|M8)              r13.0<1>:ud   -acc0.0<1;0>:ud   r4.0<0;0>:uw      -r17.0<1>:ud    
        subb (8|M16)             r58.0<1>:ud   r3.0<0;1,0>:ud    r54.0<1;1,0>:ud  {AccWrEn}
        cmp (16|M0)   (gt)f0.0   null<1>:d     r30.0<1;1,0>:ud   r34.0<1;1,0>:ud  {I@3}
        add3 (8|M16)             r14.0<1>:ud   -acc0.0<1;0>:ud   r4.0<0;0>:uw      -r20.0<1>:ud    
        subb (8|M24)             r59.0<1>:ud   r3.0<0;1,0>:ud    r55.0<1;1,0>:ud  {AccWrEn}
(f0.0)  cmp (16|M0)   (eq)f0.0   null<1>:d     r12.0<1;1,0>:d    0:w               {I@5}
        cmp (16|M16)  (gt)f1.0   null<1>:d     r58.0<1;1,0>:ud   r60.0<1;1,0>:ud  {I@2}
        add3 (8|M24)             r15.0<1>:ud   -acc0.0<1;0>:ud   r4.0<0;0>:uw      -r21.0<1>:ud    
(~f0.0) cmp (16|M0)   (gt)f0.0   null<1>:d     r12.0<1;1,0>:ud   0x0:uw             
(f1.0)  cmp (16|M16)  (eq)f1.0   null<1>:d     r14.0<1;1,0>:d    0:w               {I@2}
        cmp (16|M16)  (gt)f0.0   null<1>:d     r14.0<1;1,0>:ud   0x0:uw             
(f1.0)  sel (16|M16)             acc0.0<1>:uw  r5.0<0;1,0>:uw    0x0:uw              {F@1}
(f0.0)  sel (16|M16)             acc2.0<1>:uw  r5.0<0;1,0>:uw    0x0:uw             
        or (16|M16)   (ne)f0.0   null<1>:uw    acc2.0<1;1,0>:uw  acc0.0<1;1,0>:uw
(f0.0)  goto (32|M0)                         L27896                  L27896                
L27800:
        add3 (16|M0)             r4.0<1>:d     r66.0<1;0>:d      -r30.0<1;0>:d     -23:w              
        add3 (16|M16)            r12.0<1>:d    r64.0<1;0>:d      -r58.0<1;0>:d     -23:w              
        mov (16|M0)              r18.0<1>:d    0:w                              
        mov (16|M16)             r72.0<1>:d    0:w                              
        shl (16|M0)              r30.0<1>:d    r48.0<1;1,0>:d    r4.0<1;1,0>:d    {Compacted,I@4}
        shl (16|M16)             r74.0<1>:d    r44.0<1;1,0>:d    r12.0<1;1,0>:d   {Compacted,I@4}
        goto (32|M0)                         L27896                  L30640                
L27896:
        join (32|M0)                         L30640                                
L27912:
        add3 (16|M0)             r38.0<1>:d    r30.0<1;0>:d      -r66.0<1;0>:d     23:w               {I@4}
        add3 (16|M16)            r6.0<1>:d     r58.0<1;0>:d      -r64.0<1;0>:d     23:w              
        cmp (16|M0)   (lt)f0.0   null<1>:d     r38.0<1;1,0>:d    2:w               {Compacted,I@2}
        cmp (16|M16)  (lt)f0.0   null<1>:d     r6.0<1;1,0>:d     2:w               {I@2}
(f0.0)  goto (32|M0)                         L28160                  L28160                
L27984:
        cmp (16|M0)   (eq)f1.0   null<1>:d     r38.0<1;1,0>:d    2:w              
        cmp (16|M16)  (eq)f1.0   null<1>:d     r6.0<1;1,0>:d     2:w              
(~f1.0) goto (32|M0)                         L28160                  L28216                
L28032:
        shr (16|M0)              r18.0<1>:ud   r48.0<1;1,0>:ud   1:w              
        shr (16|M16)             r54.0<1>:ud   r44.0<1;1,0>:ud   1:w              
        mov (16|M0)              r52.0<1>:d    0:w                              
        mov (16|M16)             r66.0<1>:d    0:w                              
        mov (16|M0)              r30.0<1>:d    0:w                              
        mov (16|M16)             r64.0<1>:d    0:w                              
        mov (16|M0)              r34.0<1>:f    r18.0<1;1,0>:f                   {Compacted,I@6}
        mov (16|M16)             r62.0<1>:f    r54.0<1;1,0>:f                   {Compacted,I@5}
        goto (32|M0)                         L28160                  L29760                
L28160:
        join (32|M0)                         L28216                                
L28176:
        cmp (16|M0)   (eq)f0.0   null<1>:d     r38.0<1;1,0>:d    1:w               {Compacted}
        cmp (16|M16)  (eq)f0.0   null<1>:d     r6.0<1;1,0>:d     1:w              
(f0.0)  goto (32|M0)                         L28216                  L29664                
L28216:
        join (32|M0)                         L29664                                
L28232:
        add3 (16|M0)             r4.0<1>:d     r30.0<1;0>:d      -r34.0<1;0>:d     -1:w               {A@2}
        add3 (16|M16)            r12.0<1>:d    r58.0<1;0>:d      -r60.0<1;0>:d     -1:w              
        and (16|M0)   (ne)f1.0   r14.0<1>:d    r4.0<1;1,0>:d     63:w               {I@2}
        and (16|M16)  (ne)f1.0   r2.0<1>:d     r12.0<1;1,0>:d    63:w               {I@2}
(f1.0)  goto (32|M0)                         L28352                  L28352                
L28312:
        mov (16|M0)              r68.0<1>:f    r48.0<1;1,0>:f                   {Compacted}
        mov (16|M16)             r70.0<1>:d    r44.0<1;1,0>:d                  
        goto (32|M0)                         L28352                  L28616                
L28352:
        join (32|M0)                         L28616                                
L28368:
        cmp (16|M0)   (lt)f0.0   null<1>:d     r14.0<1;1,0>:ud   0x20:uw              {I@6}
        cmp (16|M16)  (lt)f0.0   null<1>:d     r2.0<1;1,0>:ud    0x20:uw              {I@6}
(f0.0)  goto (32|M0)                         L28480                  L28480                
L28416:
        add (16|M0)              r4.0<1>:d     r14.0<1;1,0>:d    -32:w               {Compacted}
        add (16|M16)             r12.0<1>:d    r2.0<1;1,0>:d     -32:w               {Compacted}
        shr (16|M0)              r18.0<1>:ud   r42.0<1;1,0>:ud   r4.0<1;1,0>:d    {I@2}
        shr (16|M16)             r54.0<1>:ud   r40.0<1;1,0>:ud   r12.0<1;1,0>:d   {A@2}
        goto (32|M0)                         L28480                  L28576                
L28480:
        join (32|M0)                         L28576                                
L28496:
        add (16|M0)              r4.0<1>:d     -r14.0<1;1,0>:d   32:w               {Compacted}
        add (16|M16)             r12.0<1>:d    -r2.0<1;1,0>:d    32:w               {Compacted}
        shr (16|M16)             r16.0<1>:ud   r44.0<1;1,0>:ud   r2.0<1;1,0>:d   
        shl (16|M0)              r4.0<1>:d     r42.0<1;1,0>:d    r4.0<1;1,0>:d    {Compacted,I@3}
        shr (16|M0)              r14.0<1>:ud   r48.0<1;1,0>:ud   r14.0<1;1,0>:d  
        shl (16|M16)             r12.0<1>:d    r40.0<1;1,0>:d    r12.0<1;1,0>:d   {Compacted,I@4}
        or (16|M0)               r18.0<1>:d    r14.0<1;1,0>:d    r4.0<1;1,0>:d    {Compacted,I@2}
        or (16|M16)              r54.0<1>:d    r16.0<1;1,0>:d    r12.0<1;1,0>:d   {Compacted,I@2}
L28576:
        join (32|M0)                         L28616                                
L28592:
        mov (16|M0)              r68.0<1>:f    r18.0<1;1,0>:f                   {Compacted,I@3}
        mov (16|M16)             r70.0<1>:d    r54.0<1;1,0>:d                   {I@2}
L28616:
        join (32|M0)                         L29664                                
L28632:
        add3 (16|M0)             r34.0<1>:d    r30.0<1;0>:d      -r34.0<1;0>:d     -2:w              
        add3 (16|M16)            r20.0<1>:d    r58.0<1;0>:d      -r60.0<1;0>:d     -2:w              
        and (16|M0)   (ne)f1.0   r14.0<1>:d    r34.0<1;1,0>:d    63:w               {I@2}
        and (16|M16)  (ne)f1.0   r2.0<1>:d     r20.0<1;1,0>:d    63:w               {I@2}
(f1.0)  goto (32|M0)                         L28752                  L28752                
L28712:
        mov (16|M0)              r18.0<1>:f    r48.0<1;1,0>:f                   {Compacted}
        mov (16|M16)             r54.0<1>:d    r44.0<1;1,0>:d                  
        goto (32|M0)                         L28752                  L28976                
L28752:
        join (32|M0)                         L28976                                
L28768:
        cmp (16|M0)   (lt)f0.0   null<1>:d     r14.0<1;1,0>:ud   0x20:uw              {I@6}
        cmp (16|M16)  (lt)f0.0   null<1>:d     r2.0<1;1,0>:ud    0x20:uw              {I@6}
(f0.0)  goto (32|M0)                         L28880                  L28880                
L28816:
        add (16|M0)              r4.0<1>:d     r14.0<1;1,0>:d    -32:w               {Compacted}
        add (16|M16)             r12.0<1>:d    r2.0<1;1,0>:d     -32:w               {Compacted}
        shr (16|M0)              r18.0<1>:ud   r42.0<1;1,0>:ud   r4.0<1;1,0>:d    {A@1}
        shr (16|M16)             r54.0<1>:ud   r40.0<1;1,0>:ud   r12.0<1;1,0>:d   {I@2}
        goto (32|M0)                         L28880                  L28976                
L28880:
        join (32|M0)                         L28976                                
L28896:
        add (16|M0)              r4.0<1>:d     -r14.0<1;1,0>:d   32:w               {Compacted}
        add (16|M16)             r12.0<1>:d    -r2.0<1;1,0>:d    32:w               {Compacted}
        shr (16|M16)             r16.0<1>:ud   r44.0<1;1,0>:ud   r2.0<1;1,0>:d   
        shl (16|M0)              r4.0<1>:d     r42.0<1;1,0>:d    r4.0<1;1,0>:d    {Compacted,I@3}
        shr (16|M0)              r14.0<1>:ud   r48.0<1;1,0>:ud   r14.0<1;1,0>:d  
        shl (16|M16)             r12.0<1>:d    r40.0<1;1,0>:d    r12.0<1;1,0>:d   {Compacted,I@4}
        or (16|M0)               r18.0<1>:d    r14.0<1;1,0>:d    r4.0<1;1,0>:d    {Compacted,I@2}
        or (16|M16)              r54.0<1>:d    r16.0<1;1,0>:d    r12.0<1;1,0>:d   {Compacted,I@2}
L28976:
        join (32|M0)                         L29664                                
L28992:
        and (16|M0)   (ne)f1.0   r4.0<1>:d     r34.0<1;1,0>:d    63:w              
        and (16|M16)  (ne)f1.0   r20.0<1>:d    r20.0<1;1,0>:d    63:w              
        and (16|M0)              r30.0<1>:d    r18.0<1;1,0>:d    1:w               {Compacted,I@5}
        and (16|M16)             r64.0<1>:d    r54.0<1;1,0>:d    1:w               {Compacted,I@5}
(f1.0)  goto (32|M0)                         L29136                  L29136                
L29056:
        mov (16|M0)              r4.0<1>:d     -1:w                              
        mov (16|M16)             r14.0<1>:d    -1:w                              
        mov (16|M0)              r18.0<1>:d    -1:w                              
        mov (16|M16)             r16.0<1>:d    -1:w                              
        goto (32|M0)                         L29136                  L29408                
L29136:
        join (32|M0)                         L29408                                
L29152:
        cmp (16|M0)   (lt)f0.0   null<1>:d     r4.0<1;1,0>:ud    0x20:uw              {I@6}
        cmp (16|M16)  (lt)f0.0   null<1>:d     r20.0<1;1,0>:ud   0x20:uw             
(f0.0)  goto (32|M0)                         L29312                  L29312                
L29200:
        add (16|M0)              r4.0<1>:d     r4.0<1;1,0>:d     -32:w               {Compacted}
        add (16|M16)             r12.0<1>:d    r20.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r3.0<1>:hf    -qnan(0x1FF):hf                             
        mov (16|M16)             r14.0<1>:d    0:w                              
        shl (16|M0)              r18.0<1>:d    r3.0<0;1,0>:w     r4.0<1;1,0>:d    {A@1}
        shl (16|M16)             r16.0<1>:d    r3.0<0;1,0>:w     r12.0<1;1,0>:d   {I@3}
        mov (16|M0)              r4.0<1>:d     0:w                              
        goto (32|M0)                         L29312                  L29408                
L29312:
        join (32|M0)                         L29408                                
L29328:
(W)     mov (1|M0)               r3.0<1>:hf    -qnan(0x1FF):hf                              {I@4}
        mov (16|M0)              r18.0<1>:d    -1:w                              
        mov (16|M16)             r16.0<1>:d    -1:w                              
        shl (16|M0)              r4.0<1>:d     r3.0<0;1,0>:w     r4.0<1;1,0>:d    {A@1}
        shl (16|M16)             r14.0<1>:d    r3.0<0;1,0>:w     r20.0<1;1,0>:d  
L29408:
        join (32|M0)                         L29664                                
L29424:
        bfn.0x60 (16|M0)         r4.0<1>:ud    r4.0<1;0>:ud      r10.2<0;0>:ud     r48.0<1>:ud      {I@3} // (s0^s1)&s2
        bfn.0x60 (16|M16)        r12.0<1>:ud   r14.0<1;0>:ud     r10.2<0;0>:ud     r44.0<1>:ud      {I@3} // (s0^s1)&s2
        cmp (16|M0)   (ne)f1.0   null<1>:d     r4.0<1;1,0>:d     0:w               {I@2}
        cmp (16|M16)  (ne)f1.0   null<1>:d     r12.0<1;1,0>:d    0:w               {I@2}
        bfn.0x60 (16|M16)        r16.0<1>:ud   r16.0<1;0>:ud     r10.2<0;0>:ud     r40.0<1>:ud      // (s0^s1)&s2
        bfn.0x60 (16|M0)         r14.0<1>:ud   r18.0<1;0>:ud     r10.2<0;0>:ud     r42.0<1>:ud      // (s0^s1)&s2
(~f1.0) cmp (16|M16)  (ne)f1.0   null<1>:d     r16.0<1;1,0>:d    0:w               {I@2}
(~f1.0) cmp (16|M0)   (ne)f1.0   null<1>:d     r14.0<1;1,0>:d    0:w               {I@2}
(W)     mov (1|M0)               r3.0<1>:hf    -qnan(0x1FF):hf                             
        mov (16|M0)              r34.0<1>:f    r68.0<1;1,0>:f                   {Compacted}
(f1.0)  sel (16|M0)              r18.0<1>:d    r3.0<0;1,0>:w     0:w               {F@2}
(f1.0)  sel (16|M16)             r20.0<1>:d    r3.0<0;1,0>:w     0:w              
        mov (16|M16)             r62.0<1>:f    r70.0<1;1,0>:f                   {Compacted}
        mov (16|M0)              r52.0<1>:d    -r18.0<1;1,0>:d                  {I@2}
        mov (16|M16)             r66.0<1>:d    -r20.0<1;1,0>:d                  {I@2}
        goto (32|M0)                         L29664                  L29760                
L29664:
        join (32|M0)                         L29760                                
L29680:
        mov (16|M0)              r52.0<1>:d    0:w                              
        mov (16|M16)             r66.0<1>:d    0:w                              
        mov (16|M0)              r30.0<1>:d    0:w                              
        mov (16|M16)             r64.0<1>:d    0:w                              
        mov (16|M0)              r34.0<1>:f    r48.0<1;1,0>:f                   {Compacted}
        mov (16|M16)             r62.0<1>:f    r44.0<1;1,0>:f                   {Compacted}
L29760:
        join (32|M0)                         L30640                                
L29776:
        and (16|M0)   (ne)f1.0   r14.0<1>:d    r38.0<1;1,0>:d    63:w              
        and (16|M16)  (ne)f1.0   r2.0<1>:d     r6.0<1;1,0>:d     63:w              
(f1.0)  goto (32|M0)                         L29864                  L29864                
L29824:
        mov (16|M0)              r18.0<1>:f    r48.0<1;1,0>:f                   {Compacted}
        mov (16|M16)             r54.0<1>:d    r44.0<1;1,0>:d                  
        goto (32|M0)                         L29864                  L30088                
L29864:
        join (32|M0)                         L30088                                
L29880:
        cmp (16|M0)   (lt)f0.0   null<1>:d     r14.0<1;1,0>:ud   0x20:uw              {I@6}
        cmp (16|M16)  (lt)f0.0   null<1>:d     r2.0<1;1,0>:ud    0x20:uw              {I@6}
(f0.0)  goto (32|M0)                         L29992                  L29992                
L29928:
        add (16|M0)              r4.0<1>:d     r14.0<1;1,0>:d    -32:w               {Compacted}
        add (16|M16)             r12.0<1>:d    r2.0<1;1,0>:d     -32:w               {Compacted}
        shr (16|M0)              r18.0<1>:ud   r42.0<1;1,0>:ud   r4.0<1;1,0>:d    {A@1}
        shr (16|M16)             r54.0<1>:ud   r40.0<1;1,0>:ud   r12.0<1;1,0>:d   {I@2}
        goto (32|M0)                         L29992                  L30088                
L29992:
        join (32|M0)                         L30088                                
L30008:
        add (16|M0)              r4.0<1>:d     -r14.0<1;1,0>:d   32:w               {Compacted}
        add (16|M16)             r12.0<1>:d    -r2.0<1;1,0>:d    32:w               {Compacted}
        shr (16|M16)             r16.0<1>:ud   r44.0<1;1,0>:ud   r2.0<1;1,0>:d   
        shl (16|M0)              r4.0<1>:d     r42.0<1;1,0>:d    r4.0<1;1,0>:d    {Compacted,I@3}
        shr (16|M0)              r14.0<1>:ud   r48.0<1;1,0>:ud   r14.0<1;1,0>:d  
        shl (16|M16)             r12.0<1>:d    r40.0<1;1,0>:d    r12.0<1;1,0>:d   {Compacted,I@4}
        or (16|M0)               r18.0<1>:d    r14.0<1;1,0>:d    r4.0<1;1,0>:d    {Compacted,I@2}
        or (16|M16)              r54.0<1>:d    r16.0<1;1,0>:d    r12.0<1;1,0>:d   {Compacted,I@2}
L30088:
        join (32|M0)                         L30640                                
L30104:
        shl (16|M0)              r4.0<1>:d     r34.0<1;1,0>:d    2:w               {Compacted}
        shl (16|M16)             r12.0<1>:d    r62.0<1;1,0>:d    2:w               {Compacted}
        shl (16|M0)              r14.0<1>:d    r30.0<1;1,0>:d    1:w               {Compacted}
        shl (16|M16)             r16.0<1>:d    r64.0<1;1,0>:d    1:w               {Compacted}
        and (16|M0)              r4.0<1>:d     r4.0<1;1,0>:d     4:w               {Compacted,I@4}
        and (16|M16)             r12.0<1>:d    r12.0<1;1,0>:d    4:w               {Compacted,I@4}
        bfn.0xFE (16|M0)         r14.0<1>:ud   r4.0<1;0>:ud      r14.0<1;0>:ud     r52.0<1>:ud      {I@2} // s0|s1|s2
        bfn.0xFE (16|M16)        r4.0<1>:ud    r12.0<1;0>:ud     r16.0<1;0>:ud     r66.0<1>:ud      {I@2} // s0|s1|s2
        cmp (16|M0)   (eq)f1.0   null<1>:d     r14.0<1;1,0>:d    0:w               {I@2}
        cmp (16|M16)  (eq)f1.0   null<1>:d     r4.0<1;1,0>:d     0:w               {I@2}
(~f1.0) goto (32|M0)                         L30280                  L30280                
L30232:
        mov (16|M0)              r12.0<1>:d    0:w                              
        mov (16|M16)             r6.0<1>:d     0:w                              
        goto (32|M0)                         L30280                  L30512                
L30280:
        join (32|M0)                         L30512                                
L30296:
        cmp (16|M0)   (gt)f0.0   null<1>:d     r14.0<1;1,0>:ud   0x4:uw             
        cmp (16|M16)  (gt)f0.0   null<1>:d     r4.0<1;1,0>:ud    0x4:uw             
(~f0.0) goto (32|M0)                         L30392                  L30392                
L30344:
        mov (16|M0)              r12.0<1>:d    1:w                              
        mov (16|M16)             r6.0<1>:d     1:w                              
        goto (32|M0)                         L30392                  L30512                
L30392:
        join (32|M0)                         L30512                                
L30408:
        and (16|M0)   (ne)f0.0   null<1>:d     r18.0<1;1,0>:d    1:w               {Compacted}
        and (16|M16)  (ne)f0.0   null<1>:d     r54.0<1;1,0>:d    1:w              
(f0.0)  cmp (16|M0)   (eq)f0.0   null<1>:d     r14.0<1;1,0>:d    4:w              
(f0.0)  cmp (16|M16)  (eq)f0.0   null<1>:d     r4.0<1;1,0>:d     4:w              
(W)     mov (1|M0)               r3.0<1>:hf    0x1:hf                             
(f0.0)  sel (16|M0)              r12.0<1>:d    r3.0<0;1,0>:w     0:w               {F@1}
(f0.0)  sel (16|M16)             r6.0<1>:d     r3.0<0;1,0>:w     0:w              
L30512:
        join (32|M0)                         L30640                                
L30528:
        add (16|M0)              r4.0<1>:d     r12.0<1;1,0>:d    r18.0<1;1,0>:d   {Compacted,I@3}
        add (16|M16)             r12.0<1>:d    r6.0<1;1,0>:d     r54.0<1;1,0>:d   {Compacted,I@3}
        cmp (16|M0)   (gt)f1.0   null<1>:d     r4.0<1;1,0>:ud    0x7FFFFF:ud              {I@2}
        cmp (16|M16)  (gt)f1.0   null<1>:d     r12.0<1;1,0>:ud   0x7FFFFF:ud              {I@2}
(W)     mov (1|M0)               r3.0<1>:f     0x800000:f                               {Compacted}
(~f1.0) sel (16|M0)              r30.0<1>:d    r4.0<1;1,0>:d     0:w              
(~f1.0) sel (16|M16)             r74.0<1>:d    r12.0<1;1,0>:d    0:w              
(f1.0)  sel (16|M0)              r18.0<1>:d    r3.0<0;1,0>:d     0:w               {Compacted,F@1}
(f1.0)  sel (16|M16)             r72.0<1>:d    r3.0<0;1,0>:d     0:w              
L30640:
        join (32|M0)                         L30736                                
L30656:
        and (16|M0)              r4.0<1>:d     r22.0<1;1,0>:d    -2147483648:d              
        and (16|M16)             r12.0<1>:d    r26.0<1;1,0>:d    -2147483648:d              
        bfn.0xFE (16|M0)         r22.0<1>:ud   r4.0<1;0>:ud      r18.0<1;0>:ud     r30.0<1>:ud      {I@2} // s0|s1|s2
        bfn.0xFE (16|M16)        r28.0<1>:ud   r12.0<1;0>:ud     r72.0<1;0>:ud     r74.0<1>:ud      {I@2} // s0|s1|s2
        goto (32|M0)                         L30736                  L35960                
L30736:
        join (32|M0)                         L31496                                
L30752:
        and (16|M0)   (ne)f1.0   r4.0<1>:d     r30.0<1;1,0>:d    63:w              
        and (16|M16)  (ne)f1.0   r16.0<1>:d    r24.0<1;1,0>:d    63:w              
(f1.0)  goto (32|M0)                         L30880                  L30880                
L30800:
        mov (16|M0)              r4.0<1>:d     -1:w                              
        mov (16|M16)             r14.0<1>:d    -1:w                              
        mov (16|M0)              r20.0<1>:d    -1:w                              
        mov (16|M16)             r6.0<1>:d     -1:w                              
        goto (32|M0)                         L30880                  L31152                
L30880:
        join (32|M0)                         L31152                                
L30896:
        cmp (16|M0)   (lt)f0.0   null<1>:d     r4.0<1;1,0>:ud    0x20:uw              {I@6}
        cmp (16|M16)  (lt)f0.0   null<1>:d     r16.0<1;1,0>:ud   0x20:uw             
(f0.0)  goto (32|M0)                         L31056                  L31056                
L30944:
        add (16|M0)              r4.0<1>:d     r4.0<1;1,0>:d     -32:w               {Compacted}
        add (16|M16)             r12.0<1>:d    r16.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r3.0<1>:hf    -qnan(0x1FF):hf                             
        mov (16|M16)             r14.0<1>:d    0:w                              
        shl (16|M0)              r20.0<1>:d    r3.0<0;1,0>:w     r4.0<1;1,0>:d    {A@1}
        shl (16|M16)             r6.0<1>:d     r3.0<0;1,0>:w     r12.0<1;1,0>:d   {I@3}
        mov (16|M0)              r4.0<1>:d     0:w                              
        goto (32|M0)                         L31056                  L31152                
L31056:
        join (32|M0)                         L31152                                
L31072:
(W)     mov (1|M0)               r3.0<1>:hf    -qnan(0x1FF):hf                              {I@4}
        mov (16|M0)              r20.0<1>:d    -1:w                              
        mov (16|M16)             r6.0<1>:d     -1:w                              
        shl (16|M0)              r4.0<1>:d     r3.0<0;1,0>:w     r4.0<1;1,0>:d    {A@1}
        shl (16|M16)             r14.0<1>:d    r3.0<0;1,0>:w     r16.0<1;1,0>:d  
L31152:
        join (32|M0)                         L31496                                
L31168:
        bfn.0x60 (16|M0)         r4.0<1>:ud    r4.0<1;0>:ud      r10.2<0;0>:ud     r48.0<1>:ud      {I@3} // (s0^s1)&s2
        bfn.0x60 (16|M16)        r12.0<1>:ud   r14.0<1;0>:ud     r10.2<0;0>:ud     r44.0<1>:ud      {I@3} // (s0^s1)&s2
        cmp (16|M0)   (ne)f1.0   null<1>:d     r4.0<1;1,0>:d     0:w               {I@2}
        cmp (16|M16)  (ne)f1.0   null<1>:d     r12.0<1;1,0>:d    0:w               {I@2}
        bfn.0x60 (16|M16)        r16.0<1>:ud   r6.0<1;0>:ud      r10.2<0;0>:ud     r40.0<1>:ud      // (s0^s1)&s2
        bfn.0x60 (16|M0)         r14.0<1>:ud   r20.0<1;0>:ud     r10.2<0;0>:ud     r42.0<1>:ud      // (s0^s1)&s2
        cmp (16|M0)   (gt)f0.0   null<1>:d     r22.0<1;1,0>:d    -1:w               {Compacted}
        cmp (16|M16)  (gt)f0.0   null<1>:d     r26.0<1;1,0>:d    -1:w              
(~f1.0) cmp (16|M16)  (ne)f1.0   null<1>:d     r16.0<1;1,0>:d    0:w               {I@4}
(~f1.0) cmp (16|M0)   (ne)f1.0   null<1>:d     r14.0<1;1,0>:d    0:w               {I@4}
(f1.0)  cmp (16|M16)  (eq)f1.0   null<1>:d     r56.0<1;1,0>:d    -150:w              
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r18.0<1;1,0>:d    -150:w              
(f0.0)  goto (32|M0)                         L31424                  L31424                
L31368:
(W)     mov (1|M0)               r3.0<1>:ud    0x80000001:ud                             
(f1.0)  sel (16|M0)              r22.0<1>:f    r3.0<0;1,0>:f     -0.0:f               {Compacted,I@1}
(f1.0)  sel (16|M16)             r28.0<1>:f    r3.0<0;1,0>:f     -0.0:f              
        goto (32|M0)                         L31424                  L35960                
L31424:
        join (32|M0)                         L31496                                
L31440:
(W)     mov (1|M0)               r3.0<1>:ud    0x1:ud                              {F@1}
(f1.0)  sel (16|M0)              r22.0<1>:f    r3.0<0;1,0>:f     0.0:f               {Compacted,I@1}
(f1.0)  sel (16|M16)             r28.0<1>:f    r3.0<0;1,0>:f     0.0:f              
        goto (32|M0)                         L31496                  L35960                
L31496:
        join (32|M0)                         L35632                                
L31512:
        cmp (16|M16)  (lt)f0.0   null<1>:d     r24.0<1;1,0>:ud   0x18:uw             
        cmp (16|M16)  (eq)f1.0   null<1>:d     r80.0<1;1,0>:d    0:w               {F@1}
        cmp (16|M0)   (lt)f1.0   null<1>:d     r30.0<1;1,0>:ud   0x18:uw             
(W)     mov (1|M0)               r3.0<1>:hf    0x1:hf                             
        add3 (16|M0)             r60.0<1>:d    r52.0<1;0>:d      r30.0<1;0>:d      -46:w              
(f1.0)  sel (16|M16)             acc0.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw              {F@1}
(f0.0)  sel (16|M16)             acc2.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw             
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r68.0<1;1,0>:d    0:w              
        and (16|M16)  (ne)f1.0   null<1>:uw    acc0.0<1;1,0>:uw  acc2.0<1;1,0>:uw
        add3 (16|M16)            r64.0<1>:d    r50.0<1;0>:d      r24.0<1;0>:d      -46:w              
(f1.0)  goto (32|M0)                         L35168                  L35168                
L31688:
        shl (16|M16)             r12.0<1>:d    r36.0<1;1,0>:d    1:w               {Compacted}
        shl (16|M0)              r4.0<1>:d     r38.0<1;1,0>:d    1:w               {Compacted}
        shr (16|M16)             r16.0<1>:ud   r36.0<1;1,0>:ud   31:w              
        shl (16|M16)             r20.0<1>:d    r32.0<1;1,0>:d    1:w               {Compacted}
        cmp (16|M16)  (lt)f0.0   null<1>:d     r12.0<1;1,0>:ud   0x4E:uw              {I@4}
        shr (16|M0)              r14.0<1>:ud   r38.0<1;1,0>:ud   31:w              
        shl (16|M0)              r18.0<1>:d    r34.0<1;1,0>:d    1:w               {Compacted}
        cmp (16|M0)   (lt)f1.0   null<1>:d     r4.0<1;1,0>:ud    0x4E:uw              {I@6}
        or (16|M16)              r20.0<1>:d    r20.0<1;1,0>:d    r16.0<1;1,0>:d   {Compacted,I@5}
        or (16|M0)               r18.0<1>:d    r18.0<1;1,0>:d    r14.0<1;1,0>:d   {Compacted,I@3}
(f0.0)  cmp (16|M16)  (eq)f0.0   null<1>:d     r20.0<1;1,0>:d    0:w               {I@2}
        cmp (16|M16)  (lt)f1.0   null<1>:d     r20.0<1;1,0>:d    0:w              
(W)     mov (1|M0)               r3.0<1>:hf    0x1:hf                             
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r18.0<1;1,0>:d    0:w               {I@3}
(f1.0)  sel (16|M16)             acc0.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw              {F@1}
(f0.0)  sel (16|M16)             acc2.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw             
(~f1.0) cmp (16|M0)   (lt)f1.0   null<1>:d     r18.0<1;1,0>:d    0:w              
        or (16|M16)   (ne)f1.0   null<1>:uw    acc0.0<1;1,0>:uw  acc2.0<1;1,0>:uw
(f1.0)  goto (32|M0)                         L32224                  L32224                
L31944:
        cmp (16|M16)  (eq)f1.0   null<1>:d     r36.0<1;1,0>:d    39:w              
        cmp (16|M16)  (eq)f0.0   null<1>:d     r32.0<1;1,0>:d    0:w              
        cmp (16|M0)   (eq)f0.0   null<1>:d     r38.0<1;1,0>:d    39:w               {Compacted}
(W)     mov (1|M0)               r3.0<1>:hf    0x1:hf                              {I@7}
(f0.0)  sel (16|M16)             acc0.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw              {F@1}
(f1.0)  sel (16|M16)             acc2.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw             
(f0.0)  cmp (16|M0)   (eq)f0.0   null<1>:d     r34.0<1;1,0>:d    0:w              
        and (16|M16)  (ne)f0.0   null<1>:uw    acc0.0<1;1,0>:uw  acc2.0<1;1,0>:uw
(~f0.0) goto (32|M0)                         L32224                  L32384                
L32080:
        shr (16|M0)              r18.0<1>:ud   r48.0<1;1,0>:ud   1:w              
        shr (16|M16)             r54.0<1>:ud   r44.0<1;1,0>:ud   1:w              
        mov (16|M0)              r62.0<1>:d    0:w                              
        mov (16|M16)             r58.0<1>:d    0:w                              
        mov (16|M0)              r38.0<1>:d    0:w                              
        mov (16|M16)             r56.0<1>:d    0:w                              
        mov (16|M0)              r42.0<1>:f    r18.0<1;1,0>:f                   {Compacted,I@6}
        mov (16|M16)             r6.0<1>:f     r54.0<1;1,0>:f                   {Compacted,I@5}
        mov (16|M0)              r18.0<1>:f    r48.0<1;1,0>:f                   {Compacted}
        mov (16|M16)             r54.0<1>:f    r44.0<1;1,0>:f                   {Compacted}
        goto (32|M0)                         L32224                  L34336                
L32224:
        join (32|M0)                         L32384                                
L32240:
        cmp (16|M16)  (eq)f0.0   null<1>:d     r36.0<1;1,0>:d    38:w              
        cmp (16|M16)  (eq)f1.0   null<1>:d     r32.0<1;1,0>:d    0:w              
        cmp (16|M0)   (eq)f1.0   null<1>:d     r38.0<1;1,0>:d    38:w               {I@6}
(W)     mov (1|M0)               r3.0<1>:hf    0x1:hf                             
(f1.0)  sel (16|M16)             acc0.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw              {F@1}
(f0.0)  sel (16|M16)             acc2.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw             
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r34.0<1;1,0>:d    0:w              
        and (16|M16)  (ne)f1.0   null<1>:uw    acc0.0<1;1,0>:uw  acc2.0<1;1,0>:uw
(f1.0)  goto (32|M0)                         L32384                  L34176                
L32384:
        join (32|M0)                         L34176                                
L32400:
        add (16|M0)              r4.0<1>:d     -r38.0<1;1,0>:d   39:w               {Compacted}
        add (16|M16)             r12.0<1>:d    -r36.0<1;1,0>:d   39:w               {Compacted}
        and (16|M0)   (ne)f1.0   r14.0<1>:d    r4.0<1;1,0>:d     63:w               {I@2}
        and (16|M16)  (ne)f1.0   r2.0<1>:d     r12.0<1;1,0>:d    63:w               {I@2}
        add (16|M0)              r66.0<1>:d    -r38.0<1;1,0>:d   40:w               {Compacted}
        add (16|M16)             r68.0<1>:d    -r36.0<1;1,0>:d   40:w               {Compacted}
(f1.0)  goto (32|M0)                         L32520                  L32520                
L32480:
        mov (16|M0)              r34.0<1>:f    r48.0<1;1,0>:f                   {Compacted}
        mov (16|M16)             r32.0<1>:d    r44.0<1;1,0>:d                  
        goto (32|M0)                         L32520                  L32784                
L32520:
        join (32|M0)                         L32784                                
L32536:
        cmp (16|M0)   (lt)f0.0   null<1>:d     r14.0<1;1,0>:ud   0x20:uw              {I@7}
        cmp (16|M16)  (lt)f0.0   null<1>:d     r2.0<1;1,0>:ud    0x20:uw              {I@7}
(f0.0)  goto (32|M0)                         L32648                  L32648                
L32584:
        add (16|M0)              r4.0<1>:d     r14.0<1;1,0>:d    -32:w               {Compacted}
        add (16|M16)             r12.0<1>:d    r2.0<1;1,0>:d     -32:w               {Compacted}
        shr (16|M0)              r18.0<1>:ud   r42.0<1;1,0>:ud   r4.0<1;1,0>:d    {I@2}
        shr (16|M16)             r54.0<1>:ud   r40.0<1;1,0>:ud   r12.0<1;1,0>:d   {I@2}
        goto (32|M0)                         L32648                  L32744                
L32648:
        join (32|M0)                         L32744                                
L32664:
        add (16|M0)              r4.0<1>:d     -r14.0<1;1,0>:d   32:w               {Compacted}
        add (16|M16)             r12.0<1>:d    -r2.0<1;1,0>:d    32:w               {Compacted}
        shr (16|M16)             r16.0<1>:ud   r44.0<1;1,0>:ud   r2.0<1;1,0>:d   
        shl (16|M0)              r4.0<1>:d     r42.0<1;1,0>:d    r4.0<1;1,0>:d    {Compacted,I@3}
        shr (16|M0)              r14.0<1>:ud   r48.0<1;1,0>:ud   r14.0<1;1,0>:d  
        shl (16|M16)             r12.0<1>:d    r40.0<1;1,0>:d    r12.0<1;1,0>:d   {Compacted,I@4}
        or (16|M0)               r18.0<1>:d    r14.0<1;1,0>:d    r4.0<1;1,0>:d    {Compacted,I@2}
        or (16|M16)              r54.0<1>:d    r16.0<1;1,0>:d    r12.0<1;1,0>:d   {Compacted,I@2}
L32744:
        join (32|M0)                         L32784                                
L32760:
        mov (16|M0)              r34.0<1>:f    r18.0<1;1,0>:f                   {Compacted,I@3}
        mov (16|M16)             r32.0<1>:d    r54.0<1;1,0>:d                   {I@2}
L32784:
        join (32|M0)                         L34176                                
L32800:
        add (16|M0)              r20.0<1>:d    -r38.0<1;1,0>:d   38:w               {Compacted}
        add (16|M16)             r2.0<1>:d     -r36.0<1;1,0>:d   38:w               {Compacted}
        and (16|M0)   (ne)f1.0   r14.0<1>:d    r20.0<1;1,0>:d    63:w               {I@2}
        and (16|M16)  (ne)f1.0   r16.0<1>:d    r2.0<1;1,0>:d     63:w               {I@2}
(f1.0)  goto (32|M0)                         L32904                  L32904                
L32864:
        mov (16|M0)              r18.0<1>:f    r48.0<1;1,0>:f                   {Compacted}
        mov (16|M16)             r54.0<1>:d    r44.0<1;1,0>:d                  
        goto (32|M0)                         L32904                  L33128                
L32904:
        join (32|M0)                         L33128                                
L32920:
        cmp (16|M0)   (lt)f0.0   null<1>:d     r14.0<1;1,0>:ud   0x20:uw              {I@6}
        cmp (16|M16)  (lt)f0.0   null<1>:d     r16.0<1;1,0>:ud   0x20:uw              {I@6}
(f0.0)  goto (32|M0)                         L33032                  L33032                
L32968:
        add (16|M0)              r4.0<1>:d     r14.0<1;1,0>:d    -32:w               {Compacted}
        add (16|M16)             r12.0<1>:d    r16.0<1;1,0>:d    -32:w               {Compacted}
        shr (16|M0)              r18.0<1>:ud   r42.0<1;1,0>:ud   r4.0<1;1,0>:d    {A@1}
        shr (16|M16)             r54.0<1>:ud   r40.0<1;1,0>:ud   r12.0<1;1,0>:d   {I@2}
        goto (32|M0)                         L33032                  L33128                
L33032:
        join (32|M0)                         L33128                                
L33048:
        add (16|M0)              r4.0<1>:d     -r14.0<1;1,0>:d   32:w               {Compacted}
        add (16|M16)             r12.0<1>:d    -r16.0<1;1,0>:d   32:w               {Compacted}
        shl (16|M0)              r4.0<1>:d     r42.0<1;1,0>:d    r4.0<1;1,0>:d    {Compacted,I@2}
        shr (16|M0)              r14.0<1>:ud   r48.0<1;1,0>:ud   r14.0<1;1,0>:d  
        shl (16|M16)             r12.0<1>:d    r40.0<1;1,0>:d    r12.0<1;1,0>:d   {Compacted,I@3}
        shr (16|M16)             r16.0<1>:ud   r44.0<1;1,0>:ud   r16.0<1;1,0>:d  
        or (16|M0)               r18.0<1>:d    r14.0<1;1,0>:d    r4.0<1;1,0>:d    {Compacted,I@3}
        or (16|M16)              r54.0<1>:d    r16.0<1;1,0>:d    r12.0<1;1,0>:d   {Compacted,I@2}
L33128:
        join (32|M0)                         L34176                                
L33144:
        and (16|M0)   (ne)f1.0   r4.0<1>:d     r20.0<1;1,0>:d    63:w              
        and (16|M16)  (ne)f1.0   r20.0<1>:d    r2.0<1;1,0>:d     63:w              
        and (16|M0)              r38.0<1>:d    r18.0<1;1,0>:d    1:w               {Compacted,I@5}
        and (16|M16)             r56.0<1>:d    r54.0<1;1,0>:d    1:w               {Compacted,I@5}
(f1.0)  goto (32|M0)                         L33288                  L33288                
L33208:
        mov (16|M0)              r4.0<1>:d     -1:w                              
        mov (16|M16)             r14.0<1>:d    -1:w                              
        mov (16|M0)              r18.0<1>:d    -1:w                              
        mov (16|M16)             r16.0<1>:d    -1:w                              
        goto (32|M0)                         L33288                  L33560                
L33288:
        join (32|M0)                         L33560                                
L33304:
        cmp (16|M0)   (lt)f0.0   null<1>:d     r4.0<1;1,0>:ud    0x20:uw              {I@6}
        cmp (16|M16)  (lt)f0.0   null<1>:d     r20.0<1;1,0>:ud   0x20:uw             
(f0.0)  goto (32|M0)                         L33464                  L33464                
L33352:
        add (16|M0)              r4.0<1>:d     r4.0<1;1,0>:d     -32:w               {Compacted}
        add (16|M16)             r12.0<1>:d    r20.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r3.0<1>:hf    -qnan(0x1FF):hf                             
        mov (16|M16)             r14.0<1>:d    0:w                              
        shl (16|M0)              r18.0<1>:d    r3.0<0;1,0>:w     r4.0<1;1,0>:d    {A@1}
        shl (16|M16)             r16.0<1>:d    r3.0<0;1,0>:w     r12.0<1;1,0>:d   {I@3}
        mov (16|M0)              r4.0<1>:d     0:w                              
        goto (32|M0)                         L33464                  L33560                
L33464:
        join (32|M0)                         L33560                                
L33480:
(W)     mov (1|M0)               r3.0<1>:hf    -qnan(0x1FF):hf                              {I@4}
        mov (16|M0)              r18.0<1>:d    -1:w                              
        mov (16|M16)             r16.0<1>:d    -1:w                              
        shl (16|M0)              r4.0<1>:d     r3.0<0;1,0>:w     r4.0<1;1,0>:d    {A@1}
        shl (16|M16)             r14.0<1>:d    r3.0<0;1,0>:w     r20.0<1;1,0>:d  
L33560:
        join (32|M0)                         L34176                                
L33576:
        bfn.0x60 (16|M0)         r4.0<1>:ud    r4.0<1;0>:ud      r10.2<0;0>:ud     r48.0<1>:ud      {I@3} // (s0^s1)&s2
        bfn.0x60 (16|M16)        r12.0<1>:ud   r14.0<1;0>:ud     r10.2<0;0>:ud     r44.0<1>:ud      {I@3} // (s0^s1)&s2
        cmp (16|M0)   (ne)f1.0   null<1>:d     r4.0<1;1,0>:d     0:w               {I@2}
        cmp (16|M16)  (ne)f1.0   null<1>:d     r12.0<1;1,0>:d    0:w               {I@2}
        bfn.0x60 (16|M16)        r16.0<1>:ud   r16.0<1;0>:ud     r10.2<0;0>:ud     r40.0<1>:ud      // (s0^s1)&s2
        bfn.0x60 (16|M0)         r14.0<1>:ud   r18.0<1;0>:ud     r10.2<0;0>:ud     r42.0<1>:ud      // (s0^s1)&s2
(~f1.0) cmp (16|M16)  (ne)f1.0   null<1>:d     r16.0<1;1,0>:d    0:w               {I@2}
(~f1.0) cmp (16|M0)   (ne)f1.0   null<1>:d     r14.0<1;1,0>:d    0:w               {I@2}
(W)     mov (1|M0)               r3.0<1>:hf    -qnan(0x1FF):hf                             
(f1.0)  sel (16|M0)              r18.0<1>:d    r3.0<0;1,0>:w     0:w               {F@1}
(f1.0)  sel (16|M16)             r20.0<1>:d    r3.0<0;1,0>:w     0:w              
        and (16|M0)   (ne)f1.0   r14.0<1>:d    r66.0<1;1,0>:d    63:w              
        and (16|M16)  (ne)f1.0   r2.0<1>:d     r68.0<1;1,0>:d    63:w              
        mov (16|M0)              r62.0<1>:d    -r18.0<1;1,0>:d                  {I@4}
        mov (16|M16)             r58.0<1>:d    -r20.0<1;1,0>:d                  {I@4}
(f1.0)  goto (32|M0)                         L33872                  L33872                
L33832:
        mov (16|M0)              r18.0<1>:f    r48.0<1;1,0>:f                   {Compacted,I@3}
        mov (16|M16)             r54.0<1>:d    r44.0<1;1,0>:d                  
        goto (32|M0)                         L33872                  L34096                
L33872:
        join (32|M0)                         L34096                                
L33888:
        cmp (16|M0)   (lt)f0.0   null<1>:d     r14.0<1;1,0>:ud   0x20:uw             
        cmp (16|M16)  (lt)f0.0   null<1>:d     r2.0<1;1,0>:ud    0x20:uw             
(f0.0)  goto (32|M0)                         L34000                  L34000                
L33936:
        add (16|M0)              r4.0<1>:d     r14.0<1;1,0>:d    -32:w               {Compacted}
        add (16|M16)             r12.0<1>:d    r2.0<1;1,0>:d     -32:w               {Compacted}
        shr (16|M0)              r18.0<1>:ud   r42.0<1;1,0>:ud   r4.0<1;1,0>:d    {A@1}
        shr (16|M16)             r54.0<1>:ud   r40.0<1;1,0>:ud   r12.0<1;1,0>:d   {I@2}
        goto (32|M0)                         L34000                  L34096                
L34000:
        join (32|M0)                         L34096                                
L34016:
        add (16|M0)              r4.0<1>:d     -r14.0<1;1,0>:d   32:w               {Compacted}
        add (16|M16)             r12.0<1>:d    -r2.0<1;1,0>:d    32:w               {Compacted}
        shr (16|M16)             r16.0<1>:ud   r44.0<1;1,0>:ud   r2.0<1;1,0>:d   
        shl (16|M0)              r4.0<1>:d     r42.0<1;1,0>:d    r4.0<1;1,0>:d    {Compacted,I@3}
        shr (16|M0)              r14.0<1>:ud   r48.0<1;1,0>:ud   r14.0<1;1,0>:d  
        shl (16|M16)             r12.0<1>:d    r40.0<1;1,0>:d    r12.0<1;1,0>:d   {Compacted,I@4}
        or (16|M0)               r18.0<1>:d    r14.0<1;1,0>:d    r4.0<1;1,0>:d    {Compacted,I@2}
        or (16|M16)              r54.0<1>:d    r16.0<1;1,0>:d    r12.0<1;1,0>:d   {Compacted,I@2}
L34096:
        join (32|M0)                         L34176                                
L34112:
        mov (16|M0)              r42.0<1>:f    r18.0<1;1,0>:f                   {Compacted,I@3}
        mov (16|M16)             r6.0<1>:f     r54.0<1;1,0>:f                   {Compacted,I@2}
        mov (16|M0)              r18.0<1>:d    r34.0<1;1,0>:d                   {F@2}
        mov (16|M16)             r54.0<1>:d    r32.0<1;1,0>:d                   {F@1}
        goto (32|M0)                         L34176                  L34336                
L34176:
        join (32|M0)                         L34336                                
L34192:
        shr (16|M0)              r18.0<1>:ud   r48.0<1;1,0>:ud   2:w              
        shr (16|M16)             r54.0<1>:ud   r44.0<1;1,0>:ud   2:w              
        mov (16|M0)              r62.0<1>:d    0:w                              
        mov (16|M16)             r58.0<1>:d    0:w                              
        mov (16|M0)              r38.0<1>:d    0:w                              
        mov (16|M16)             r56.0<1>:d    0:w                              
        mov (16|M0)              r42.0<1>:f    r18.0<1;1,0>:f                   {Compacted,I@6}
        mov (16|M16)             r6.0<1>:f     r54.0<1;1,0>:f                   {Compacted,I@5}
        shr (16|M0)              r18.0<1>:ud   r48.0<1;1,0>:ud   1:w               {F@2}
        shr (16|M16)             r54.0<1>:ud   r44.0<1;1,0>:ud   1:w               {F@1}
L34336:
        join (32|M0)                         L35168                                
L34352:
        shl (16|M0)              r4.0<1>:d     r18.0<1;1,0>:d    2:w               {Compacted,I@3}
        shl (16|M16)             r12.0<1>:d    r54.0<1;1,0>:d    2:w               {Compacted,I@3}
        shl (16|M0)              r14.0<1>:d    r38.0<1;1,0>:d    1:w               {Compacted}
        shl (16|M16)             r16.0<1>:d    r56.0<1;1,0>:d    1:w               {Compacted}
        and (16|M0)              r4.0<1>:d     r4.0<1;1,0>:d     4:w               {Compacted,I@4}
        and (16|M16)             r12.0<1>:d    r12.0<1;1,0>:d    4:w               {Compacted,I@4}
        bfn.0xFE (16|M0)         r4.0<1>:ud    r4.0<1;0>:ud      r14.0<1;0>:ud     r62.0<1>:ud      {I@2} // s0|s1|s2
        bfn.0xFE (16|M16)        r14.0<1>:ud   r12.0<1;0>:ud     r16.0<1;0>:ud     r58.0<1>:ud      {I@2} // s0|s1|s2
        cmp (16|M0)   (eq)f1.0   null<1>:d     r4.0<1;1,0>:d     0:w               {I@2}
        cmp (16|M16)  (eq)f1.0   null<1>:d     r14.0<1;1,0>:d    0:w               {I@2}
        and (16|M0)              r32.0<1>:d    r42.0<1;1,0>:d    8388607:d              
        and (16|M16)             r20.0<1>:d    r6.0<1;1,0>:d     8388607:d              
(~f1.0) goto (32|M0)                         L34560                  L34560                
L34512:
        mov (16|M0)              r4.0<1>:d     0:w                              
        mov (16|M16)             r12.0<1>:d    0:w                              
        goto (32|M0)                         L34560                  L34792                
L34560:
        join (32|M0)                         L34792                                
L34576:
        cmp (16|M0)   (gt)f0.0   null<1>:d     r4.0<1;1,0>:ud    0x4:uw              {I@4}
        cmp (16|M16)  (gt)f0.0   null<1>:d     r14.0<1;1,0>:ud   0x4:uw             
(~f0.0) goto (32|M0)                         L34672                  L34672                
L34624:
        mov (16|M0)              r4.0<1>:d     1:w                              
        mov (16|M16)             r12.0<1>:d    1:w                              
        goto (32|M0)                         L34672                  L34792                
L34672:
        join (32|M0)                         L34792                                
L34688:
        and (16|M0)   (ne)f0.0   null<1>:d     r42.0<1;1,0>:d    1:w               {Compacted}
        and (16|M16)  (ne)f0.0   null<1>:d     r6.0<1;1,0>:d     1:w              
(f0.0)  cmp (16|M0)   (eq)f0.0   null<1>:d     r4.0<1;1,0>:d     4:w               {I@6}
(f0.0)  cmp (16|M16)  (eq)f0.0   null<1>:d     r14.0<1;1,0>:d    4:w              
(W)     mov (1|M0)               r3.0<1>:hf    0x1:hf                             
(f0.0)  sel (16|M0)              r4.0<1>:d     r3.0<0;1,0>:w     0:w               {F@1}
(f0.0)  sel (16|M16)             r12.0<1>:d    r3.0<0;1,0>:w     0:w              
L34792:
        join (32|M0)                         L35168                                
L34808:
        add (16|M0)              r14.0<1>:d    r32.0<1;1,0>:d    r4.0<1;1,0>:d    {Compacted,I@3}
        add (16|M16)             r6.0<1>:d     r20.0<1;1,0>:d    r12.0<1;1,0>:d   {Compacted,I@3}
        cmp (16|M0)   (gt)f1.0   null<1>:d     r14.0<1;1,0>:ud   0x7FFFFF:ud              {I@2}
        cmp (16|M16)  (gt)f1.0   null<1>:d     r6.0<1;1,0>:ud    0x7FFFFF:ud              {I@2}
        add3 (16|M0)             r4.0<1>:d     r52.0<1;0>:d      r30.0<1;0>:d      -45:w              
        add3 (16|M16)            r12.0<1>:d    r50.0<1;0>:d      r24.0<1;0>:d      -45:w              
(f1.0)  sel (16|M0)              r18.0<1>:d    r4.0<1;1,0>:d     r60.0<1;1,0>:d   {Compacted,I@2}
(f1.0)  sel (16|M16)             r2.0<1>:d     r12.0<1;1,0>:d    r64.0<1;1,0>:d   {I@2}
        cmp (16|M0)   (eq)f0.0   null<1>:d     r18.0<1;1,0>:d    255:w               {Compacted,I@2}
        cmp (16|M16)  (eq)f0.0   null<1>:d     r2.0<1;1,0>:d     255:w               {I@2}
(f0.0)  goto (32|M0)                         L35080                  L35080                
L34952:
(~f1.0) sel (16|M0)              r4.0<1>:d     r14.0<1;1,0>:d    0:w              
(~f1.0) sel (16|M16)             r12.0<1>:d    r6.0<1;1,0>:d     0:w              
        and (16|M16)             r16.0<1>:d    r26.0<1;1,0>:d    -2147483648:d              
        shl (16|M0)              r18.0<1>:d    r18.0<1;1,0>:d    23:w               {Compacted}
        shl (16|M16)             r20.0<1>:d    r2.0<1;1,0>:d     23:w               {Compacted}
        and (16|M0)              r14.0<1>:d    r22.0<1;1,0>:d    -2147483648:d              
        bfn.0xFE (16|M16)        r28.0<1>:ud   r16.0<1;0>:ud     r20.0<1;0>:ud     r12.0<1>:ud      {I@2} // s0|s1|s2
        bfn.0xFE (16|M0)         r22.0<1>:ud   r14.0<1;0>:ud     r18.0<1;0>:ud     r4.0<1>:ud       {I@2} // s0|s1|s2
        goto (32|M0)                         L35080                  L35960                
L35080:
        join (32|M0)                         L35168                                
L35096:
        cmp (16|M0)   (gt)f0.0   null<1>:d     r22.0<1;1,0>:d    -1:w               {Compacted,I@3}
        cmp (16|M16)  (gt)f0.0   null<1>:d     r26.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r3.0<1>:f     inf:f                               {Compacted}
(f0.0)  sel (16|M0)              r22.0<1>:f    r3.0<0;1,0>:f     -inf:f               {Compacted,A@1}
(f0.0)  sel (16|M16)             r28.0<1>:f    r3.0<0;1,0>:f     -inf:f              
        goto (32|M0)                         L35168                  L35960                
L35168:
        join (32|M0)                         L35632                                
L35184:
        and (16|M0)   (ne)f1.0   r4.0<1>:d     r30.0<1;1,0>:d    63:w              
        and (16|M16)  (ne)f1.0   r12.0<1>:d    r24.0<1;1,0>:d    63:w              
(f1.0)  goto (32|M0)                         L35280                  L35280                
L35232:
        mov (16|M0)              r4.0<1>:d     -1:w                              
        mov (16|M16)             r6.0<1>:d     -1:w                              
        goto (32|M0)                         L35280                  L35456                
L35280:
        join (32|M0)                         L35456                                
L35296:
        cmp (16|M0)   (lt)f0.0   null<1>:d     r4.0<1;1,0>:ud    0x20:uw              {A@1}
        cmp (16|M16)  (lt)f0.0   null<1>:d     r12.0<1;1,0>:ud   0x20:uw             
(f0.0)  goto (32|M0)                         L35392                  L35392                
L35344:
        mov (16|M0)              r4.0<1>:d     0:w                              
        mov (16|M16)             r6.0<1>:d     0:w                              
        goto (32|M0)                         L35392                  L35456                
L35392:
        join (32|M0)                         L35456                                
L35408:
(W)     mov (1|M0)               r3.0<1>:hf    -qnan(0x1FF):hf                             
        shl (16|M0)              r4.0<1>:d     r3.0<0;1,0>:w     r4.0<1;1,0>:d    {A@1}
        shl (16|M16)             r6.0<1>:d     r3.0<0;1,0>:w     r12.0<1;1,0>:d  
L35456:
        join (32|M0)                         L35632                                
L35472:
        bfn.0x60 (16|M0)         r4.0<1>:ud    r4.0<1;0>:ud      r10.2<0;0>:ud     r48.0<1>:ud      {I@3} // (s0^s1)&s2
        bfn.0x60 (16|M16)        r12.0<1>:ud   r6.0<1;0>:ud      r10.2<0;0>:ud     r44.0<1>:ud      {I@3} // (s0^s1)&s2
        add (16|M0)              r14.0<1>:d    -r30.0<1;1,0>:d   23:w               {Compacted}
        add (16|M16)             r16.0<1>:d    -r24.0<1;1,0>:d   23:w               {Compacted}
        and (16|M0)              r18.0<1>:d    r22.0<1;1,0>:d    -2147483648:d              
        and (16|M16)             r20.0<1>:d    r26.0<1;1,0>:d    -2147483648:d              
        shl (16|M0)              r4.0<1>:d     r4.0<1;1,0>:d     r14.0<1;1,0>:d   {Compacted,I@4}
        shl (16|M16)             r12.0<1>:d    r12.0<1;1,0>:d    r16.0<1;1,0>:d   {Compacted,I@4}
        shl (16|M16)             r24.0<1>:d    r64.0<1;1,0>:d    23:w               {Compacted}
        shl (16|M0)              r22.0<1>:d    r60.0<1;1,0>:d    23:w               {Compacted}
        bfn.0xFE (16|M16)        r28.0<1>:ud   r20.0<1;0>:ud     r24.0<1;0>:ud     r12.0<1>:ud      {I@2} // s0|s1|s2
        bfn.0xFE (16|M0)         r22.0<1>:ud   r18.0<1;0>:ud     r22.0<1;0>:ud     r4.0<1>:ud       {I@2} // s0|s1|s2
        goto (32|M0)                         L35632                  L35960                
L35632:
        join (32|M0)                         L35728                                
L35648:
        cmp (16|M0)   (gt)f1.0   null<1>:d     r22.0<1;1,0>:d    -1:w               {I@3}
        cmp (16|M16)  (gt)f1.0   null<1>:d     r26.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r3.0<1>:f     inf:f                               {Compacted}
(f1.0)  sel (16|M0)              r22.0<1>:f    r3.0<0;1,0>:f     -inf:f               {Compacted,A@1}
(f1.0)  sel (16|M16)             r28.0<1>:f    r3.0<0;1,0>:f     -inf:f              
        goto (32|M0)                         L35728                  L35960                
L35728:
        join (32|M0)                         L35816                                
L35744:
        cmp (16|M0)   (lt)f0.0   null<1>:d     r22.0<1;1,0>:d    0:w               {Compacted,F@2}
        cmp (16|M16)  (lt)f0.0   null<1>:d     r26.0<1;1,0>:d    0:w              
(W)     mov (1|M0)               r3.0<1>:f     -0.0:f                               {Compacted}
(f0.0)  sel (16|M0)              r22.0<1>:f    r3.0<0;1,0>:f     0.0:f               {Compacted,A@1}
(f0.0)  sel (16|M16)             r28.0<1>:f    r3.0<0;1,0>:f     0.0:f              
        goto (32|M0)                         L35816                  L35960                
L35816:
        join (32|M0)                         L35912                                
L35832:
        cmp (16|M0)   (gt)f1.0   null<1>:d     r22.0<1;1,0>:d    -1:w               {F@2}
        cmp (16|M16)  (gt)f1.0   null<1>:d     r26.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r3.0<1>:f     inf:f                               {Compacted}
(f1.0)  sel (16|M0)              r22.0<1>:f    r3.0<0;1,0>:f     -inf:f               {Compacted,A@1}
(f1.0)  sel (16|M16)             r28.0<1>:f    r3.0<0;1,0>:f     -inf:f              
        goto (32|M0)                         L35912                  L35960                
L35912:
        join (32|M0)                         L35960                                
L35928:
        bfn.0xF8 (16|M0)         r22.0<1>:ud   r22.0<1;0>:ud     r10.4<0;0>:ud     r10.3<0>:ud      {F@2} // s0&s1|s2
        bfn.0xF8 (16|M16)        r28.0<1>:ud   r26.0<1;0>:ud     r10.4<0;0>:ud     r10.3<0>:ud      {F@1} // s0&s1|s2
L35960:
        join (32|M0)                         L47048                                
L35976:
        rnde (16|M16)            r6.0<1>:f     r28.0<1;1,0>:f                   {Compacted,I@2}
        shr (16|M16)             r16.0<1>:ud   r6.0<1;1,0>:ud    23:w               {F@1}
        and (16|M16)             r30.0<1>:d    r16.0<1;1,0>:d    255:w               {Compacted,I@1}
        rnde (16|M0)             r22.0<1>:f    r22.0<1;1,0>:f                   {Compacted}
        and (16|M16)  (ne)f1.0   r14.0<1>:d    r6.0<1;1,0>:d     8388607:d              
        cmp (16|M16)  (eq)f0.0   null<1>:d     r30.0<1;1,0>:d    255:w               {I@2}
(W)     mov (1|M0)               r3.0<1>:hf    0x1:hf                             
        shr (16|M0)              r20.0<1>:ud   r22.0<1;1,0>:ud   23:w               {F@2}
        and (16|M0)   (ne)f0.0   r18.0<1>:d    r22.0<1;1,0>:d    8388607:d              
(f0.0)  sel (16|M16)             acc0.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw              {F@1}
(f1.0)  sel (16|M16)             acc2.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw             
        and (16|M0)              r34.0<1>:d    r20.0<1;1,0>:d    255:w               {Compacted,I@4}
        and (16|M16)  (ne)f0.0   null<1>:uw    acc0.0<1;1,0>:uw  acc2.0<1;1,0>:uw
(f0.0)  cmp (16|M0)   (eq)f0.0   null<1>:d     r34.0<1;1,0>:d    255:w               {I@2}
(~f0.0) goto (32|M0)                         L36224                  L36224                
L36184:
        mov (16|M0)              r22.0<1>:ud   0x7FC00000:ud                             
        mov (16|M16)             r26.0<1>:f    qnan(0x0):f                               {Compacted,$15.src}
        goto (32|M0)                         L36224                  L46712                
L36224:
        join (32|M0)                         L46712                                
L36240:
        add (16|M16)             r12.0<1>:d    r84.0<1;1,0>:d    -25165824:d              
        cmp (16|M16)  (eq)f1.0   null<1>:d     r14.0<1;1,0>:d    0:w              
        shr (16|M16)             r24.0<1>:ud   r12.0<1;1,0>:ud   23:w               {I@2}
        cmp (16|M0)   (eq)f0.0   null<1>:d     r18.0<1;1,0>:d    0:w               {Compacted}
        and (16|M16)             r60.0<1>:d    r24.0<1;1,0>:d    255:w               {Compacted,I@2}
        add (16|M0)              r4.0<1>:d     r82.0<1;1,0>:d    -25165824:d              
(f1.0)  cmp (16|M16)  (eq)f1.0   null<1>:d     r30.0<1;1,0>:d    255:w              
        cmp (16|M16)  (eq)f0.0   null<1>:d     r60.0<1;1,0>:d    255:w               {I@3}
(W)     mov (1|M0)               r3.0<1>:hf    0x1:hf                             
(f0.0)  cmp (16|M0)   (eq)f0.0   null<1>:d     r34.0<1;1,0>:d    255:w              
        sync.nop                             null                             {Compacted,$10.src}
        shr (16|M0)              r32.0<1>:ud   r4.0<1;1,0>:ud    23:w               {I@4}
        xor (16|M16)             r28.0<1>:d    r12.0<1;1,0>:d    r6.0<1;1,0>:d    {Compacted}
(f1.0)  sel (16|M16)             acc0.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw              {F@1}
        and (16|M0)              r62.0<1>:d    r32.0<1;1,0>:d    255:w               {Compacted,I@3}
(f0.0)  sel (16|M16)             acc2.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw             
(~f0.0) cmp (16|M0)   (eq)f0.0   null<1>:d     r62.0<1;1,0>:d    255:w               {I@2}
        or (16|M16)   (ne)f0.0   null<1>:uw    acc2.0<1;1,0>:uw  acc0.0<1;1,0>:uw
        xor (16|M0)              r22.0<1>:d    r4.0<1;1,0>:d     r22.0<1;1,0>:d   {Compacted}
(f0.0)  goto (32|M0)                         L46656                  L46656                
L36512:
        cmp (16|M16)  (eq)f0.0   null<1>:d     r60.0<1;1,0>:d    0:w              
        or (16|M16)   (eq)f1.0   null<1>:d     r30.0<1;1,0>:d    r14.0<1;1,0>:d  
        cmp (16|M0)   (eq)f1.0   null<1>:d     r62.0<1;1,0>:d    0:w              
(W)     mov (1|M0)               r3.0<1>:hf    0x1:hf                              {I@7}
        or (16|M0)               r4.0<1>:d     r34.0<1;1,0>:d    r18.0<1;1,0>:d   {Compacted}
(f1.0)  sel (16|M16)             acc0.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw              {F@1}
(f0.0)  sel (16|M16)             acc2.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw             
(~f1.0) cmp (16|M0)   (eq)f1.0   null<1>:d     r4.0<1;1,0>:d     0:w               {I@3}
        or (16|M16)   (ne)f1.0   null<1>:uw    acc0.0<1;1,0>:uw  acc2.0<1;1,0>:uw
(~f1.0) goto (32|M0)                         L36704                  L36704                
L36664:
        mov (16|M0)              r22.0<1>:ud   0x0:ud                             
        mov (16|M16)             r26.0<1>:f    0.0:f                               {Compacted,$15.src}
        goto (32|M0)                         L36704                  L46712                
L36704:
        join (32|M0)                         L46656                                
L36720:
        cmp (16|M0)   (eq)f0.0   null<1>:d     r34.0<1;1,0>:d    0:w               {Compacted}
        cmp (16|M16)  (eq)f0.0   null<1>:d     r30.0<1;1,0>:d    0:w              
        add (16|M0)              r58.0<1>:d    r34.0<1;1,0>:d    -127:w               {Compacted}
        add (16|M16)             r56.0<1>:d    r30.0<1;1,0>:d    -127:w               {Compacted}
(f0.0)  mov (16|M0)              r58.0<1>:d    -126:w                              
(f0.0)  mov (16|M16)             r56.0<1>:d    -126:w                              
        add (16|M0)              r52.0<1>:d    r62.0<1;1,0>:d    r58.0<1;1,0>:d   {Compacted,I@2}
        add (16|M16)             r50.0<1>:d    r60.0<1;1,0>:d    r56.0<1;1,0>:d   {Compacted,I@2}
        cmp (16|M0)   (gt)f1.0   null<1>:d     r52.0<1;1,0>:d    254:w               {I@2}
        cmp (16|M16)  (gt)f1.0   null<1>:d     r50.0<1;1,0>:d    254:w               {I@2}
(f1.0)  goto (32|M0)                         L46560                  L46560                
L36856:
        or (16|M0)    (eq)f1.0   null<4>:b     r20.0<1;1,0>:d    r32.0<1;1,0>:d  
        or (16|M16)   (eq)f1.0   null<4>:b     r16.0<1;1,0>:d    r24.0<1;1,0>:d  
(f1.0)  goto (32|M0)                         L46472                  L46472                
L36904:
(W)     mov (1|M0)               r3.0<1>:hf    0.0:hf                             
(W)     mov (1|M0)               r2.3<1>:d     0:w                              
(f0.0)  sel (16|M0)              r4.0<1>:d     r3.0<0;1,0>:w     8388608:d               {F@1}
(f0.0)  sel (16|M16)             r12.0<1>:d    r3.0<0;1,0>:w     8388608:d              
        or (16|M0)               r4.0<1>:d     r4.0<1;1,0>:d     r18.0<1;1,0>:d   {Compacted,I@2}
        or (16|M16)              r12.0<1>:d    r12.0<1;1,0>:d    r14.0<1;1,0>:d   {Compacted,I@2}
        shl (16|M0)              r48.0<1>:d    r4.0<1;1,0>:d     23:w               {Compacted,I@2}
        shr (16|M0)              r42.0<1>:ud   r4.0<1;1,0>:ud    9:w              
        shl (16|M16)             r44.0<1>:d    r12.0<1;1,0>:d    23:w               {Compacted,I@3}
        shr (16|M16)             r40.0<1>:ud   r12.0<1;1,0>:ud   9:w              
(W)     mov (1|M0)               r2.5<1>:f     -0.0:f                               {Compacted}
(W)     mov (2|M0)               r2.0<1>:d     0:w                              
L37056:
(W)     shl (1|M0)               r3.0<1>:d     r2.5<0;1,0>:d     31:w               {Compacted,F@1}
(W)     shr (1|M0)               r3.1<1>:ud    r2.3<0;1,0>:ud    1:w              
(W)     addc (1|M0)              r7.0<1>:ud    r2.0<0;1,0>:ud    0x1:ud              {AccWrEn,I@3}
(W)     or (1|M0)                r2.3<1>:d     r3.1<0;1,0>:d     r3.0<0;1,0>:d    {I@2}
        bfn.0xE0 (16|M0)         r12.0<1>:ud   r3.1<0;0>:ud      r3.0<0;0>:ud      r48.0<1>:ud      // (s0|s1)&s2
        cmp (16|M0)   (eq)f1.0   null<1>:d     r12.0<1;1,0>:d    r2.3<0;1,0>:d    {I@1}
(W)     mov (1|M0)               r4.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        bfn.0xE0 (16|M16)        r14.0<1>:ud   r3.1<0;0>:ud      r3.0<0;0>:ud      r44.0<1>:ud      // (s0|s1)&s2
(W)     add (1|M0)               r2.4<1>:ud    r4.0<0;1,0>:ud    r2.1<0;1,0>:ud   {I@2}
(W)     mov (1|M0)               r4.0<1>:ud    f1.0<0;1,0>:ud                   {Compacted}
(W)     shr (1|M0)               r2.2<1>:ud    r2.5<0;1,0>:ud    1:w              
(W)     mov (1|M0)               f1.0<1>:ud    r4.0<0;1,0>:ud                   {I@2}
        cmp (16|M16)  (eq)f1.0   null<1>:d     r14.0<1;1,0>:d    r2.3<0;1,0>:d   
        and (16|M0)              r16.0<1>:d    r2.2<0;1,0>:d     r42.0<1;1,0>:d   {Compacted,I@3}
(W)     mov (1|M0)               r4.0<1>:ud    f1.0<0;1,0>:ud                   {Compacted}
(W)     cmp (16|M0)   (gt)f0.0   null<1>:d     r2.0<0;1,0>:ud    0x3E:uw             
(W)     mov (1|M0)               f1.0<1>:ud    r4.0<0;1,0>:ud                   {I@2}
(W)     cmp (16|M16)  (gt)f0.0   null<1>:d     r2.0<0;1,0>:ud    0x3E:uw             
(W&f0.0) cmp (16|M0)  (eq)f0.0   null<1>:d     r2.1<0;1,0>:d     0:w              
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r16.0<1;1,0>:d    r2.2<0;1,0>:d   
        and (16|M16)             r18.0<1>:d    r2.2<0;1,0>:d     r40.0<1;1,0>:d   {Compacted}
(W)     mov (1|M0)               r4.0<1>:ud    f1.0<0;1,0>:ud                   {Compacted}
(W&f0.0) cmp (16|M16) (eq)f0.0   null<1>:d     r2.1<0;1,0>:d     0:w              
(W)     mov (1|M0)               f1.0<1>:ud    r4.0<0;1,0>:ud                   {I@2}
(W&~f0.0) cmp (16|M0) (gt)f0.0   null<1>:d     r2.1<0;1,0>:ud    0x0:uw             
(W)     mov (1|M0)               r3.0<1>:hf    0x1:hf                             
(f1.0)  cmp (16|M16)  (eq)f1.0   null<1>:d     r18.0<1;1,0>:d    r2.2<0;1,0>:d   
(W&~f0.0) cmp (16|M16) (gt)f0.0  null<1>:d     r2.1<0;1,0>:ud    0x0:uw             
(f0.0)  sel (16|M0)              acc0.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw              {F@1}
(f1.0)  sel (16|M0)              acc2.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw             
(W)     mov (1|M0)               r4.0<1>:ud    f1.0<0;1,0>:ud                   {Compacted}
(f0.0)  sel (16|M16)             r11.0<1>:uw   r3.0<0;1,0>:uw    0x0:uw             
        or (16|M0)    (ne)f1.0   null<1>:uw    acc0.0<1;1,0>:uw  acc2.0<1;1,0>:uw
(W)     mov (1|M0)               f0.0<1>:ud    r4.0<0;1,0>:ud                   {I@3}
        mov (16|M0)              r64.0<1>:f    r2.0<0;1,0>:f                    {Compacted}
(W)     mov (1|M0)               r3.1<1>:ud    f1.0<0;1,0>:ud                   {Compacted}
(f0.0)  sel (16|M16)             acc0.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw             
(W)     mov (1|M0)               f0.0<1>:ud    r3.1<0;1,0>:ud                   {I@2}
        or (16|M16)   (ne)f0.0   null<1>:uw    r11.0<1;1,0>:uw   acc0.0<1;1,0>:uw
        mov (16|M16)             r54.0<1>:f    r2.0<0;1,0>:f                    {Compacted}
(W)     mov (1|M0)               r3.1<1>:ud    f0.0<0;1,0>:ud                   {Compacted}
        mov (16|M16)             r20.0<1>:d    r2.1<0;1,0>:d                   
(W)     mov (1|M0)               f1.0<1>:ud    r3.1<0;1,0>:ud                   {I@2}
        mov (16|M0)              r38.0<1>:f    r7.0<0;1,0>:f                    {Compacted}
        mov (16|M16)             r36.0<1>:f    r7.0<0;1,0>:f                    {Compacted,$14.src}
        mov (16|M0)              r34.0<1>:d    r2.4<0;1,0>:d                   
        mov (16|M16)             r32.0<1>:d    r2.4<0;1,0>:d                   
        mov (16|M0)              r16.0<1>:d    r2.1<0;1,0>:d                   
(f1.0)  goto (32|M0)                         L37784                  L37784                
L37728:
(W)     mov (1|M0)               r2.5<1>:d     r2.2<0;1,0>:d                   
(W)     mov (1|M0)               r2.0<1>:f     r7.0<0;1,0>:f                    {Compacted}
(W)     mov (1|M0)               r2.1<1>:d     r2.4<0;1,0>:d                   
(W)     jmpi                                 L37056                                
L37784:
        join (32|M0)                         L46472                                
L37800:
(W)     mov (1|M0)               r3.0<1>:f     8.68805e-44:f                              
(W)     mov (1|M0)               r4.0<1>:hf    0.0:hf                             
        subb (8|M0)              r30.0<1>:ud   r3.0<0;1,0>:ud    r64.0<1;1,0>:ud  {AccWrEn,Compacted,F@2}
        add3 (8|M0)              r68.0<1>:ud   -acc0.0<1;0>:ud   r4.0<0;0>:uw      -r16.0<1>:ud     {A@1}
        subb (8|M8)              r31.0<1>:ud   r3.0<0;1,0>:ud    r65.0<1;1,0>:ud  {AccWrEn}
        add3 (8|M8)              r69.0<1>:ud   -acc0.0<1;0>:ud   r4.0<0;0>:uw      -r17.0<1>:ud    
        subb (8|M16)             r24.0<1>:ud   r3.0<0;1,0>:ud    r54.0<1;1,0>:ud  {AccWrEn}
        add3 (16|M0)             r18.0<1>:d    r52.0<1;0>:d      r30.0<1;0>:d      -173:w               {I@3}
        add3 (8|M16)             r80.0<1>:ud   -acc0.0<1;0>:ud   r4.0<0;0>:uw      -r20.0<1>:ud    
        subb (8|M24)             r25.0<1>:ud   r3.0<0;1,0>:ud    r55.0<1;1,0>:ud  {AccWrEn}
        cmp (16|M0)   (gt)f1.0   null<1>:d     r18.0<1;1,0>:d    127:w               {I@3}
        add3 (16|M16)            r66.0<1>:d    r60.0<1;0>:d      r56.0<1;0>:d      r24.0<1>:d       {I@2}
        add3 (16|M16)            r56.0<1>:d    r50.0<1;0>:d      r24.0<1;0>:d      -173:w              
        cmp (16|M16)  (gt)f1.0   null<1>:d     r56.0<1;1,0>:d    127:w               {I@1}
        add3 (16|M0)             r62.0<1>:d    r62.0<1;0>:d      r58.0<1;0>:d      r30.0<1>:d      
        add3 (8|M24)             r81.0<1>:ud   -acc0.0<1;0>:ud   r4.0<0;0>:uw      -r21.0<1>:ud    
(f1.0)  goto (32|M0)                         L46376                  L46376                
L38064:
        cmp (16|M0)   (gt)f0.0   null<1>:d     r18.0<1;1,0>:d    -127:w               {Compacted}
        cmp (16|M16)  (gt)f0.0   null<1>:d     r56.0<1;1,0>:d    -127:w              
(f0.0)  goto (32|M0)                         L42216                  L42216                
L38104:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r18.0<1;1,0>:ud   0xFFFFFF6B:ud             
        cmp (16|M16)  (lt)f1.0   null<1>:d     r56.0<1;1,0>:ud   0xFFFFFF6B:ud             
(f1.0)  goto (32|M0)                         L41456                  L41456                
L38152:
(W)     mov (1|M0)               r3.0<1>:f     8.82818e-44:f                              
        add3 (16|M0)             r34.0<1>:d    r52.0<1;0>:d      r30.0<1;0>:d      -23:w              
(W)     mov (1|M0)               r4.0<1>:hf    0.0:hf                              {I@7}
        subb (8|M0)              r30.0<1>:ud   r3.0<0;1,0>:ud    r64.0<1;1,0>:ud  {AccWrEn,Compacted,F@2}
        add3 (16|M16)            r60.0<1>:d    r50.0<1;0>:d      r24.0<1;0>:d      -23:w              
        add3 (8|M0)              r12.0<1>:ud   -acc0.0<1;0>:ud   r4.0<0;0>:uw      -r16.0<1>:ud     {F@1}
        subb (8|M8)              r31.0<1>:ud   r3.0<0;1,0>:ud    r65.0<1;1,0>:ud  {AccWrEn}
(W)     mov (1|M0)               r5.0<1>:hf    0x1:hf                             
        add3 (8|M8)              r13.0<1>:ud   -acc0.0<1;0>:ud   r4.0<0;0>:uw      -r17.0<1>:ud    
        subb (8|M16)             r58.0<1>:ud   r3.0<0;1,0>:ud    r54.0<1;1,0>:ud  {AccWrEn}
        cmp (16|M0)   (gt)f1.0   null<1>:d     r30.0<1;1,0>:ud   r34.0<1;1,0>:ud  {I@3}
        add3 (8|M16)             r14.0<1>:ud   -acc0.0<1;0>:ud   r4.0<0;0>:uw      -r20.0<1>:ud    
        subb (8|M24)             r59.0<1>:ud   r3.0<0;1,0>:ud    r55.0<1;1,0>:ud  {AccWrEn}
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r12.0<1;1,0>:d    0:w               {I@5}
        cmp (16|M16)  (gt)f0.0   null<1>:d     r58.0<1;1,0>:ud   r60.0<1;1,0>:ud  {I@2}
        add3 (8|M24)             r15.0<1>:ud   -acc0.0<1;0>:ud   r4.0<0;0>:uw      -r21.0<1>:ud    
(~f1.0) cmp (16|M0)   (gt)f1.0   null<1>:d     r12.0<1;1,0>:ud   0x0:uw             
(f0.0)  cmp (16|M16)  (eq)f0.0   null<1>:d     r14.0<1;1,0>:d    0:w               {I@2}
        cmp (16|M16)  (gt)f1.0   null<1>:d     r14.0<1;1,0>:ud   0x0:uw             
(f0.0)  sel (16|M16)             acc0.0<1>:uw  r5.0<0;1,0>:uw    0x0:uw              {F@1}
(f1.0)  sel (16|M16)             acc2.0<1>:uw  r5.0<0;1,0>:uw    0x0:uw             
        or (16|M16)   (ne)f1.0   null<1>:uw    acc2.0<1;1,0>:uw  acc0.0<1;1,0>:uw
(f1.0)  goto (32|M0)                         L38608                  L38608                
L38512:
        add3 (16|M0)             r4.0<1>:d     r62.0<1;0>:d      -r30.0<1;0>:d     -23:w              
        add3 (16|M16)            r12.0<1>:d    r66.0<1;0>:d      -r58.0<1;0>:d     -23:w              
        mov (16|M0)              r18.0<1>:d    0:w                              
        mov (16|M16)             r72.0<1>:d    0:w                              
        shl (16|M0)              r30.0<1>:d    r48.0<1;1,0>:d    r4.0<1;1,0>:d    {Compacted,I@4}
        shl (16|M16)             r74.0<1>:d    r44.0<1;1,0>:d    r12.0<1;1,0>:d   {Compacted,I@4}
        goto (32|M0)                         L38608                  L41352                
L38608:
        join (32|M0)                         L41352                                
L38624:
        add3 (16|M0)             r38.0<1>:d    r30.0<1;0>:d      -r62.0<1;0>:d     23:w               {I@4}
        add3 (16|M16)            r6.0<1>:d     r58.0<1;0>:d      -r66.0<1;0>:d     23:w              
        cmp (16|M0)   (lt)f0.0   null<1>:d     r38.0<1;1,0>:d    2:w               {Compacted,I@2}
        cmp (16|M16)  (lt)f0.0   null<1>:d     r6.0<1;1,0>:d     2:w               {I@2}
(f0.0)  goto (32|M0)                         L38872                  L38872                
L38696:
        cmp (16|M0)   (eq)f1.0   null<1>:d     r38.0<1;1,0>:d    2:w              
        cmp (16|M16)  (eq)f1.0   null<1>:d     r6.0<1;1,0>:d     2:w              
(~f1.0) goto (32|M0)                         L38872                  L38928                
L38744:
        shr (16|M0)              r18.0<1>:ud   r48.0<1;1,0>:ud   1:w              
        shr (16|M16)             r54.0<1>:ud   r44.0<1;1,0>:ud   1:w              
        mov (16|M0)              r52.0<1>:d    0:w                              
        mov (16|M16)             r66.0<1>:d    0:w                              
        mov (16|M0)              r30.0<1>:d    0:w                              
        mov (16|M16)             r64.0<1>:d    0:w                              
        mov (16|M0)              r34.0<1>:f    r18.0<1;1,0>:f                   {Compacted,I@6}
        mov (16|M16)             r62.0<1>:f    r54.0<1;1,0>:f                   {Compacted,I@5}
        goto (32|M0)                         L38872                  L40472                
L38872:
        join (32|M0)                         L38928                                
L38888:
        cmp (16|M0)   (eq)f0.0   null<1>:d     r38.0<1;1,0>:d    1:w               {Compacted}
        cmp (16|M16)  (eq)f0.0   null<1>:d     r6.0<1;1,0>:d     1:w              
(f0.0)  goto (32|M0)                         L38928                  L40376                
L38928:
        join (32|M0)                         L40376                                
L38944:
        add3 (16|M0)             r4.0<1>:d     r30.0<1;0>:d      -r34.0<1;0>:d     -1:w               {A@2}
        add3 (16|M16)            r12.0<1>:d    r58.0<1;0>:d      -r60.0<1;0>:d     -1:w              
        and (16|M0)   (ne)f1.0   r14.0<1>:d    r4.0<1;1,0>:d     63:w               {I@2}
        and (16|M16)  (ne)f1.0   r2.0<1>:d     r12.0<1;1,0>:d    63:w               {I@2}
(f1.0)  goto (32|M0)                         L39064                  L39064                
L39024:
        mov (16|M0)              r68.0<1>:f    r48.0<1;1,0>:f                   {Compacted}
        mov (16|M16)             r70.0<1>:d    r44.0<1;1,0>:d                  
        goto (32|M0)                         L39064                  L39328                
L39064:
        join (32|M0)                         L39328                                
L39080:
        cmp (16|M0)   (lt)f0.0   null<1>:d     r14.0<1;1,0>:ud   0x20:uw              {I@6}
        cmp (16|M16)  (lt)f0.0   null<1>:d     r2.0<1;1,0>:ud    0x20:uw              {I@6}
(f0.0)  goto (32|M0)                         L39192                  L39192                
L39128:
        add (16|M0)              r4.0<1>:d     r14.0<1;1,0>:d    -32:w               {Compacted}
        add (16|M16)             r12.0<1>:d    r2.0<1;1,0>:d     -32:w               {Compacted}
        shr (16|M0)              r18.0<1>:ud   r42.0<1;1,0>:ud   r4.0<1;1,0>:d    {I@2}
        shr (16|M16)             r54.0<1>:ud   r40.0<1;1,0>:ud   r12.0<1;1,0>:d   {A@2}
        goto (32|M0)                         L39192                  L39288                
L39192:
        join (32|M0)                         L39288                                
L39208:
        add (16|M0)              r4.0<1>:d     -r14.0<1;1,0>:d   32:w               {Compacted}
        add (16|M16)             r12.0<1>:d    -r2.0<1;1,0>:d    32:w               {Compacted}
        shr (16|M16)             r16.0<1>:ud   r44.0<1;1,0>:ud   r2.0<1;1,0>:d   
        shl (16|M0)              r4.0<1>:d     r42.0<1;1,0>:d    r4.0<1;1,0>:d    {Compacted,I@3}
        shr (16|M0)              r14.0<1>:ud   r48.0<1;1,0>:ud   r14.0<1;1,0>:d  
        shl (16|M16)             r12.0<1>:d    r40.0<1;1,0>:d    r12.0<1;1,0>:d   {Compacted,I@4}
        or (16|M0)               r18.0<1>:d    r14.0<1;1,0>:d    r4.0<1;1,0>:d    {Compacted,I@2}
        or (16|M16)              r54.0<1>:d    r16.0<1;1,0>:d    r12.0<1;1,0>:d   {Compacted,I@2}
L39288:
        join (32|M0)                         L39328                                
L39304:
        mov (16|M0)              r68.0<1>:f    r18.0<1;1,0>:f                   {Compacted,I@3}
        mov (16|M16)             r70.0<1>:d    r54.0<1;1,0>:d                   {I@2}
L39328:
        join (32|M0)                         L40376                                
L39344:
        add3 (16|M0)             r34.0<1>:d    r30.0<1;0>:d      -r34.0<1;0>:d     -2:w              
        add3 (16|M16)            r20.0<1>:d    r58.0<1;0>:d      -r60.0<1;0>:d     -2:w              
        and (16|M0)   (ne)f1.0   r14.0<1>:d    r34.0<1;1,0>:d    63:w               {I@2}
        and (16|M16)  (ne)f1.0   r2.0<1>:d     r20.0<1;1,0>:d    63:w               {I@2}
(f1.0)  goto (32|M0)                         L39464                  L39464                
L39424:
        mov (16|M0)              r18.0<1>:f    r48.0<1;1,0>:f                   {Compacted}
        mov (16|M16)             r54.0<1>:d    r44.0<1;1,0>:d                  
        goto (32|M0)                         L39464                  L39688                
L39464:
        join (32|M0)                         L39688                                
L39480:
        cmp (16|M0)   (lt)f0.0   null<1>:d     r14.0<1;1,0>:ud   0x20:uw              {I@6}
        cmp (16|M16)  (lt)f0.0   null<1>:d     r2.0<1;1,0>:ud    0x20:uw              {I@6}
(f0.0)  goto (32|M0)                         L39592                  L39592                
L39528:
        add (16|M0)              r4.0<1>:d     r14.0<1;1,0>:d    -32:w               {Compacted}
        add (16|M16)             r12.0<1>:d    r2.0<1;1,0>:d     -32:w               {Compacted}
        shr (16|M0)              r18.0<1>:ud   r42.0<1;1,0>:ud   r4.0<1;1,0>:d    {A@1}
        shr (16|M16)             r54.0<1>:ud   r40.0<1;1,0>:ud   r12.0<1;1,0>:d   {I@2}
        goto (32|M0)                         L39592                  L39688                
L39592:
        join (32|M0)                         L39688                                
L39608:
        add (16|M0)              r4.0<1>:d     -r14.0<1;1,0>:d   32:w               {Compacted}
        add (16|M16)             r12.0<1>:d    -r2.0<1;1,0>:d    32:w               {Compacted}
        shr (16|M16)             r16.0<1>:ud   r44.0<1;1,0>:ud   r2.0<1;1,0>:d   
        shl (16|M0)              r4.0<1>:d     r42.0<1;1,0>:d    r4.0<1;1,0>:d    {Compacted,I@3}
        shr (16|M0)              r14.0<1>:ud   r48.0<1;1,0>:ud   r14.0<1;1,0>:d  
        shl (16|M16)             r12.0<1>:d    r40.0<1;1,0>:d    r12.0<1;1,0>:d   {Compacted,I@4}
        or (16|M0)               r18.0<1>:d    r14.0<1;1,0>:d    r4.0<1;1,0>:d    {Compacted,I@2}
        or (16|M16)              r54.0<1>:d    r16.0<1;1,0>:d    r12.0<1;1,0>:d   {Compacted,I@2}
L39688:
        join (32|M0)                         L40376                                
L39704:
        and (16|M0)   (ne)f1.0   r4.0<1>:d     r34.0<1;1,0>:d    63:w              
        and (16|M16)  (ne)f1.0   r20.0<1>:d    r20.0<1;1,0>:d    63:w              
        and (16|M0)              r30.0<1>:d    r18.0<1;1,0>:d    1:w               {Compacted,I@5}
        and (16|M16)             r64.0<1>:d    r54.0<1;1,0>:d    1:w               {Compacted,I@5}
(f1.0)  goto (32|M0)                         L39848                  L39848                
L39768:
        mov (16|M0)              r4.0<1>:d     -1:w                              
        mov (16|M16)             r14.0<1>:d    -1:w                              
        mov (16|M0)              r18.0<1>:d    -1:w                              
        mov (16|M16)             r16.0<1>:d    -1:w                              
        goto (32|M0)                         L39848                  L40120                
L39848:
        join (32|M0)                         L40120                                
L39864:
        cmp (16|M0)   (lt)f0.0   null<1>:d     r4.0<1;1,0>:ud    0x20:uw              {I@6}
        cmp (16|M16)  (lt)f0.0   null<1>:d     r20.0<1;1,0>:ud   0x20:uw             
(f0.0)  goto (32|M0)                         L40024                  L40024                
L39912:
        add (16|M0)              r4.0<1>:d     r4.0<1;1,0>:d     -32:w               {Compacted}
        add (16|M16)             r12.0<1>:d    r20.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r3.0<1>:hf    -qnan(0x1FF):hf                             
        mov (16|M16)             r14.0<1>:d    0:w                              
        shl (16|M0)              r18.0<1>:d    r3.0<0;1,0>:w     r4.0<1;1,0>:d    {A@1}
        shl (16|M16)             r16.0<1>:d    r3.0<0;1,0>:w     r12.0<1;1,0>:d   {I@3}
        mov (16|M0)              r4.0<1>:d     0:w                              
        goto (32|M0)                         L40024                  L40120                
L40024:
        join (32|M0)                         L40120                                
L40040:
(W)     mov (1|M0)               r3.0<1>:hf    -qnan(0x1FF):hf                              {I@4}
        mov (16|M0)              r18.0<1>:d    -1:w                              
        mov (16|M16)             r16.0<1>:d    -1:w                              
        shl (16|M0)              r4.0<1>:d     r3.0<0;1,0>:w     r4.0<1;1,0>:d    {A@1}
        shl (16|M16)             r14.0<1>:d    r3.0<0;1,0>:w     r20.0<1;1,0>:d  
L40120:
        join (32|M0)                         L40376                                
L40136:
        bfn.0x60 (16|M0)         r4.0<1>:ud    r4.0<1;0>:ud      r10.2<0;0>:ud     r48.0<1>:ud      {I@3} // (s0^s1)&s2
        bfn.0x60 (16|M16)        r12.0<1>:ud   r14.0<1;0>:ud     r10.2<0;0>:ud     r44.0<1>:ud      {I@3} // (s0^s1)&s2
        cmp (16|M0)   (ne)f1.0   null<1>:d     r4.0<1;1,0>:d     0:w               {I@2}
        cmp (16|M16)  (ne)f1.0   null<1>:d     r12.0<1;1,0>:d    0:w               {I@2}
        bfn.0x60 (16|M16)        r16.0<1>:ud   r16.0<1;0>:ud     r10.2<0;0>:ud     r40.0<1>:ud      // (s0^s1)&s2
        bfn.0x60 (16|M0)         r14.0<1>:ud   r18.0<1;0>:ud     r10.2<0;0>:ud     r42.0<1>:ud      // (s0^s1)&s2
(~f1.0) cmp (16|M16)  (ne)f1.0   null<1>:d     r16.0<1;1,0>:d    0:w               {I@2}
(~f1.0) cmp (16|M0)   (ne)f1.0   null<1>:d     r14.0<1;1,0>:d    0:w               {I@2}
(W)     mov (1|M0)               r3.0<1>:hf    -qnan(0x1FF):hf                             
        mov (16|M0)              r34.0<1>:f    r68.0<1;1,0>:f                   {Compacted}
(f1.0)  sel (16|M0)              r18.0<1>:d    r3.0<0;1,0>:w     0:w               {F@2}
(f1.0)  sel (16|M16)             r20.0<1>:d    r3.0<0;1,0>:w     0:w              
        mov (16|M16)             r62.0<1>:f    r70.0<1;1,0>:f                   {Compacted}
        mov (16|M0)              r52.0<1>:d    -r18.0<1;1,0>:d                  {I@2}
        mov (16|M16)             r66.0<1>:d    -r20.0<1;1,0>:d                  {I@2}
        goto (32|M0)                         L40376                  L40472                
L40376:
        join (32|M0)                         L40472                                
L40392:
        mov (16|M0)              r52.0<1>:d    0:w                              
        mov (16|M16)             r66.0<1>:d    0:w                              
        mov (16|M0)              r30.0<1>:d    0:w                              
        mov (16|M16)             r64.0<1>:d    0:w                              
        mov (16|M0)              r34.0<1>:f    r48.0<1;1,0>:f                   {Compacted}
        mov (16|M16)             r62.0<1>:f    r44.0<1;1,0>:f                   {Compacted}
L40472:
        join (32|M0)                         L41352                                
L40488:
        and (16|M0)   (ne)f1.0   r14.0<1>:d    r38.0<1;1,0>:d    63:w              
        and (16|M16)  (ne)f1.0   r2.0<1>:d     r6.0<1;1,0>:d     63:w              
(f1.0)  goto (32|M0)                         L40576                  L40576                
L40536:
        mov (16|M0)              r18.0<1>:f    r48.0<1;1,0>:f                   {Compacted}
        mov (16|M16)             r54.0<1>:d    r44.0<1;1,0>:d                  
        goto (32|M0)                         L40576                  L40800                
L40576:
        join (32|M0)                         L40800                                
L40592:
        cmp (16|M0)   (lt)f0.0   null<1>:d     r14.0<1;1,0>:ud   0x20:uw              {I@6}
        cmp (16|M16)  (lt)f0.0   null<1>:d     r2.0<1;1,0>:ud    0x20:uw              {I@6}
(f0.0)  goto (32|M0)                         L40704                  L40704                
L40640:
        add (16|M0)              r4.0<1>:d     r14.0<1;1,0>:d    -32:w               {Compacted}
        add (16|M16)             r12.0<1>:d    r2.0<1;1,0>:d     -32:w               {Compacted}
        shr (16|M0)              r18.0<1>:ud   r42.0<1;1,0>:ud   r4.0<1;1,0>:d    {A@1}
        shr (16|M16)             r54.0<1>:ud   r40.0<1;1,0>:ud   r12.0<1;1,0>:d   {I@2}
        goto (32|M0)                         L40704                  L40800                
L40704:
        join (32|M0)                         L40800                                
L40720:
        add (16|M0)              r4.0<1>:d     -r14.0<1;1,0>:d   32:w               {Compacted}
        add (16|M16)             r12.0<1>:d    -r2.0<1;1,0>:d    32:w               {Compacted}
        shr (16|M16)             r16.0<1>:ud   r44.0<1;1,0>:ud   r2.0<1;1,0>:d   
        shl (16|M0)              r4.0<1>:d     r42.0<1;1,0>:d    r4.0<1;1,0>:d    {Compacted,I@3}
        shr (16|M0)              r14.0<1>:ud   r48.0<1;1,0>:ud   r14.0<1;1,0>:d  
        shl (16|M16)             r12.0<1>:d    r40.0<1;1,0>:d    r12.0<1;1,0>:d   {Compacted,I@4}
        or (16|M0)               r18.0<1>:d    r14.0<1;1,0>:d    r4.0<1;1,0>:d    {Compacted,I@2}
        or (16|M16)              r54.0<1>:d    r16.0<1;1,0>:d    r12.0<1;1,0>:d   {Compacted,I@2}
L40800:
        join (32|M0)                         L41352                                
L40816:
        shl (16|M0)              r4.0<1>:d     r34.0<1;1,0>:d    2:w               {Compacted}
        shl (16|M16)             r12.0<1>:d    r62.0<1;1,0>:d    2:w               {Compacted}
        shl (16|M0)              r14.0<1>:d    r30.0<1;1,0>:d    1:w               {Compacted}
        shl (16|M16)             r16.0<1>:d    r64.0<1;1,0>:d    1:w               {Compacted}
        and (16|M0)              r4.0<1>:d     r4.0<1;1,0>:d     4:w               {Compacted,I@4}
        and (16|M16)             r12.0<1>:d    r12.0<1;1,0>:d    4:w               {Compacted,I@4}
        bfn.0xFE (16|M0)         r14.0<1>:ud   r4.0<1;0>:ud      r14.0<1;0>:ud     r52.0<1>:ud      {I@2} // s0|s1|s2
        bfn.0xFE (16|M16)        r4.0<1>:ud    r12.0<1;0>:ud     r16.0<1;0>:ud     r66.0<1>:ud      {I@2} // s0|s1|s2
        cmp (16|M0)   (eq)f1.0   null<1>:d     r14.0<1;1,0>:d    0:w               {I@2}
        cmp (16|M16)  (eq)f1.0   null<1>:d     r4.0<1;1,0>:d     0:w               {I@2}
(~f1.0) goto (32|M0)                         L40992                  L40992                
L40944:
        mov (16|M0)              r12.0<1>:d    0:w                              
        mov (16|M16)             r6.0<1>:d     0:w                              
        goto (32|M0)                         L40992                  L41224                
L40992:
        join (32|M0)                         L41224                                
L41008:
        cmp (16|M0)   (gt)f0.0   null<1>:d     r14.0<1;1,0>:ud   0x4:uw             
        cmp (16|M16)  (gt)f0.0   null<1>:d     r4.0<1;1,0>:ud    0x4:uw             
(~f0.0) goto (32|M0)                         L41104                  L41104                
L41056:
        mov (16|M0)              r12.0<1>:d    1:w                              
        mov (16|M16)             r6.0<1>:d     1:w                              
        goto (32|M0)                         L41104                  L41224                
L41104:
        join (32|M0)                         L41224                                
L41120:
        and (16|M0)   (ne)f0.0   null<1>:d     r18.0<1;1,0>:d    1:w               {Compacted}
        and (16|M16)  (ne)f0.0   null<1>:d     r54.0<1;1,0>:d    1:w              
(f0.0)  cmp (16|M0)   (eq)f0.0   null<1>:d     r14.0<1;1,0>:d    4:w              
(f0.0)  cmp (16|M16)  (eq)f0.0   null<1>:d     r4.0<1;1,0>:d     4:w              
(W)     mov (1|M0)               r3.0<1>:hf    0x1:hf                             
(f0.0)  sel (16|M0)              r12.0<1>:d    r3.0<0;1,0>:w     0:w               {F@1}
(f0.0)  sel (16|M16)             r6.0<1>:d     r3.0<0;1,0>:w     0:w              
L41224:
        join (32|M0)                         L41352                                
L41240:
        add (16|M0)              r4.0<1>:d     r12.0<1;1,0>:d    r18.0<1;1,0>:d   {Compacted,I@3}
        add (16|M16)             r12.0<1>:d    r6.0<1;1,0>:d     r54.0<1;1,0>:d   {Compacted,I@3}
        cmp (16|M0)   (gt)f0.0   null<1>:d     r4.0<1;1,0>:ud    0x7FFFFF:ud              {I@2}
        cmp (16|M16)  (gt)f0.0   null<1>:d     r12.0<1;1,0>:ud   0x7FFFFF:ud              {I@2}
(W)     mov (1|M0)               r3.0<1>:f     0x800000:f                               {Compacted}
(~f0.0) sel (16|M0)              r30.0<1>:d    r4.0<1;1,0>:d     0:w              
(~f0.0) sel (16|M16)             r74.0<1>:d    r12.0<1;1,0>:d    0:w              
(f0.0)  sel (16|M0)              r18.0<1>:d    r3.0<0;1,0>:d     0:w               {Compacted,F@1}
(f0.0)  sel (16|M16)             r72.0<1>:d    r3.0<0;1,0>:d     0:w              
L41352:
        join (32|M0)                         L41456                                
L41368:
        and (16|M0)              r4.0<1>:d     r22.0<1;1,0>:d    -2147483648:d              
        and (16|M16)             r12.0<1>:d    r28.0<1;1,0>:d    -2147483648:d              
        bfn.0xFE (16|M0)         r22.0<1>:ud   r4.0<1;0>:ud      r18.0<1;0>:ud     r30.0<1>:ud      {I@2} // s0|s1|s2
        sync.nop                             null                             {Compacted,$15.src}
        bfn.0xFE (16|M16)        r26.0<1>:ud   r12.0<1;0>:ud     r72.0<1;0>:ud     r74.0<1>:ud      {I@2} // s0|s1|s2
        goto (32|M0)                         L41456                  L46712                
L41456:
        join (32|M0)                         L42216                                
L41472:
        and (16|M0)   (ne)f1.0   r4.0<1>:d     r30.0<1;1,0>:d    63:w              
        and (16|M16)  (ne)f1.0   r16.0<1>:d    r24.0<1;1,0>:d    63:w              
(f1.0)  goto (32|M0)                         L41600                  L41600                
L41520:
        mov (16|M0)              r4.0<1>:d     -1:w                              
        mov (16|M16)             r14.0<1>:d    -1:w                              
        mov (16|M0)              r20.0<1>:d    -1:w                              
        mov (16|M16)             r6.0<1>:d     -1:w                              
        goto (32|M0)                         L41600                  L41872                
L41600:
        join (32|M0)                         L41872                                
L41616:
        cmp (16|M0)   (lt)f0.0   null<1>:d     r4.0<1;1,0>:ud    0x20:uw              {I@6}
        cmp (16|M16)  (lt)f0.0   null<1>:d     r16.0<1;1,0>:ud   0x20:uw             
(f0.0)  goto (32|M0)                         L41776                  L41776                
L41664:
        add (16|M0)              r4.0<1>:d     r4.0<1;1,0>:d     -32:w               {Compacted}
        add (16|M16)             r12.0<1>:d    r16.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r3.0<1>:hf    -qnan(0x1FF):hf                             
        mov (16|M16)             r14.0<1>:d    0:w                              
        shl (16|M0)              r20.0<1>:d    r3.0<0;1,0>:w     r4.0<1;1,0>:d    {A@1}
        shl (16|M16)             r6.0<1>:d     r3.0<0;1,0>:w     r12.0<1;1,0>:d   {I@3}
        mov (16|M0)              r4.0<1>:d     0:w                              
        goto (32|M0)                         L41776                  L41872                
L41776:
        join (32|M0)                         L41872                                
L41792:
(W)     mov (1|M0)               r3.0<1>:hf    -qnan(0x1FF):hf                              {I@4}
        mov (16|M0)              r20.0<1>:d    -1:w                              
        mov (16|M16)             r6.0<1>:d     -1:w                              
        shl (16|M0)              r4.0<1>:d     r3.0<0;1,0>:w     r4.0<1;1,0>:d    {A@1}
        shl (16|M16)             r14.0<1>:d    r3.0<0;1,0>:w     r16.0<1;1,0>:d  
L41872:
        join (32|M0)                         L42216                                
L41888:
        bfn.0x60 (16|M0)         r4.0<1>:ud    r4.0<1;0>:ud      r10.2<0;0>:ud     r48.0<1>:ud      {I@3} // (s0^s1)&s2
        bfn.0x60 (16|M16)        r12.0<1>:ud   r14.0<1;0>:ud     r10.2<0;0>:ud     r44.0<1>:ud      {I@3} // (s0^s1)&s2
        cmp (16|M0)   (ne)f0.0   null<1>:d     r4.0<1;1,0>:d     0:w               {Compacted,I@2}
        cmp (16|M16)  (ne)f0.0   null<1>:d     r12.0<1;1,0>:d    0:w               {I@2}
        bfn.0x60 (16|M16)        r16.0<1>:ud   r6.0<1;0>:ud      r10.2<0;0>:ud     r40.0<1>:ud      // (s0^s1)&s2
        bfn.0x60 (16|M0)         r14.0<1>:ud   r20.0<1;0>:ud     r10.2<0;0>:ud     r42.0<1>:ud      // (s0^s1)&s2
        cmp (16|M0)   (gt)f1.0   null<1>:d     r22.0<1;1,0>:d    -1:w              
        cmp (16|M16)  (gt)f1.0   null<1>:d     r28.0<1;1,0>:d    -1:w              
(~f0.0) cmp (16|M16)  (ne)f0.0   null<1>:d     r16.0<1;1,0>:d    0:w               {I@4}
(~f0.0) cmp (16|M0)   (ne)f0.0   null<1>:d     r14.0<1;1,0>:d    0:w               {I@4}
(f0.0)  cmp (16|M16)  (eq)f0.0   null<1>:d     r56.0<1;1,0>:d    -150:w              
(f0.0)  cmp (16|M0)   (eq)f0.0   null<1>:d     r18.0<1;1,0>:d    -150:w              
(f1.0)  goto (32|M0)                         L42144                  L42144                
L42088:
(W)     mov (1|M0)               r3.0<1>:ud    0x80000001:ud                             
(f0.0)  sel (16|M0)              r22.0<1>:f    r3.0<0;1,0>:f     -0.0:f               {Compacted,I@1}
(f0.0)  sel (16|M16)             r26.0<1>:f    r3.0<0;1,0>:f     -0.0:f               {$15.src}
        goto (32|M0)                         L42144                  L46712                
L42144:
        join (32|M0)                         L42216                                
L42160:
(W)     mov (1|M0)               r3.0<1>:ud    0x1:ud                              {F@1}
(f0.0)  sel (16|M0)              r22.0<1>:f    r3.0<0;1,0>:f     0.0:f               {Compacted,I@1}
(f0.0)  sel (16|M16)             r26.0<1>:f    r3.0<0;1,0>:f     0.0:f               {$15.src}
        goto (32|M0)                         L42216                  L46712                
L42216:
        join (32|M0)                         L46376                                
L42232:
        cmp (16|M16)  (lt)f1.0   null<1>:d     r24.0<1;1,0>:ud   0x18:uw             
        cmp (16|M16)  (eq)f0.0   null<1>:d     r80.0<1;1,0>:d    0:w               {F@1}
        cmp (16|M0)   (lt)f0.0   null<1>:d     r30.0<1;1,0>:ud   0x18:uw             
(W)     mov (1|M0)               r3.0<1>:hf    0x1:hf                             
        add3 (16|M0)             r60.0<1>:d    r52.0<1;0>:d      r30.0<1;0>:d      -46:w              
(f0.0)  sel (16|M16)             acc0.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw              {F@1}
(f1.0)  sel (16|M16)             acc2.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw             
(f0.0)  cmp (16|M0)   (eq)f0.0   null<1>:d     r68.0<1;1,0>:d    0:w              
        and (16|M16)  (ne)f0.0   null<1>:uw    acc0.0<1;1,0>:uw  acc2.0<1;1,0>:uw
        add3 (16|M16)            r64.0<1>:d    r50.0<1;0>:d      r24.0<1;0>:d      -46:w              
(f0.0)  goto (32|M0)                         L45904                  L45904                
L42408:
        shl (16|M16)             r12.0<1>:d    r36.0<1;1,0>:d    1:w               {Compacted}
        shl (16|M0)              r4.0<1>:d     r38.0<1;1,0>:d    1:w               {Compacted}
        shr (16|M16)             r16.0<1>:ud   r36.0<1;1,0>:ud   31:w              
        shl (16|M16)             r20.0<1>:d    r32.0<1;1,0>:d    1:w               {Compacted}
        cmp (16|M16)  (lt)f1.0   null<1>:d     r12.0<1;1,0>:ud   0x4E:uw              {I@4}
        shr (16|M0)              r14.0<1>:ud   r38.0<1;1,0>:ud   31:w              
        shl (16|M0)              r18.0<1>:d    r34.0<1;1,0>:d    1:w               {Compacted}
        cmp (16|M0)   (lt)f0.0   null<1>:d     r4.0<1;1,0>:ud    0x4E:uw              {I@6}
        or (16|M16)              r20.0<1>:d    r20.0<1;1,0>:d    r16.0<1;1,0>:d   {Compacted,I@5}
        or (16|M0)               r18.0<1>:d    r18.0<1;1,0>:d    r14.0<1;1,0>:d   {Compacted,I@3}
(f1.0)  cmp (16|M16)  (eq)f1.0   null<1>:d     r20.0<1;1,0>:d    0:w               {I@2}
        cmp (16|M16)  (lt)f0.0   null<1>:d     r20.0<1;1,0>:d    0:w              
(W)     mov (1|M0)               r3.0<1>:hf    0x1:hf                             
(f0.0)  cmp (16|M0)   (eq)f0.0   null<1>:d     r18.0<1;1,0>:d    0:w               {I@3}
(f0.0)  sel (16|M16)             acc0.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw              {F@1}
(f1.0)  sel (16|M16)             acc2.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw             
(~f0.0) cmp (16|M0)   (lt)f0.0   null<1>:d     r18.0<1;1,0>:d    0:w              
        or (16|M16)   (ne)f0.0   null<1>:uw    acc0.0<1;1,0>:uw  acc2.0<1;1,0>:uw
(f0.0)  goto (32|M0)                         L42952                  L42952                
L42664:
        cmp (16|M16)  (eq)f0.0   null<1>:d     r36.0<1;1,0>:d    39:w              
        cmp (16|M16)  (eq)f1.0   null<1>:d     r32.0<1;1,0>:d    0:w              
        cmp (16|M0)   (eq)f1.0   null<1>:d     r38.0<1;1,0>:d    39:w              
(W)     mov (1|M0)               r3.0<1>:hf    0x1:hf                              {I@7}
(f1.0)  sel (16|M16)             acc0.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw              {F@1}
(f0.0)  sel (16|M16)             acc2.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw             
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r34.0<1;1,0>:d    0:w              
        and (16|M16)  (ne)f1.0   null<1>:uw    acc0.0<1;1,0>:uw  acc2.0<1;1,0>:uw
(~f1.0) goto (32|M0)                         L42952                  L43104                
L42808:
        shr (16|M0)              r18.0<1>:ud   r48.0<1;1,0>:ud   1:w              
        shr (16|M16)             r54.0<1>:ud   r44.0<1;1,0>:ud   1:w              
        mov (16|M0)              r62.0<1>:d    0:w                              
        mov (16|M16)             r58.0<1>:d    0:w                              
        mov (16|M0)              r38.0<1>:d    0:w                              
        mov (16|M16)             r56.0<1>:d    0:w                              
        mov (16|M0)              r42.0<1>:f    r18.0<1;1,0>:f                   {Compacted,I@6}
        mov (16|M16)             r6.0<1>:f     r54.0<1;1,0>:f                   {Compacted,I@5}
        mov (16|M0)              r18.0<1>:f    r48.0<1;1,0>:f                   {Compacted}
        mov (16|M16)             r54.0<1>:f    r44.0<1;1,0>:f                   {Compacted}
        goto (32|M0)                         L42952                  L45056                
L42952:
        join (32|M0)                         L43104                                
L42968:
        cmp (16|M16)  (eq)f1.0   null<1>:d     r36.0<1;1,0>:d    38:w              
        cmp (16|M16)  (eq)f0.0   null<1>:d     r32.0<1;1,0>:d    0:w              
        cmp (16|M0)   (eq)f0.0   null<1>:d     r38.0<1;1,0>:d    38:w               {Compacted,I@6}
(W)     mov (1|M0)               r3.0<1>:hf    0x1:hf                             
(f0.0)  sel (16|M16)             acc0.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw              {F@1}
(f1.0)  sel (16|M16)             acc2.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw             
(f0.0)  cmp (16|M0)   (eq)f0.0   null<1>:d     r34.0<1;1,0>:d    0:w              
        and (16|M16)  (ne)f0.0   null<1>:uw    acc0.0<1;1,0>:uw  acc2.0<1;1,0>:uw
(f0.0)  goto (32|M0)                         L43104                  L44896                
L43104:
        join (32|M0)                         L44896                                
L43120:
        add (16|M0)              r4.0<1>:d     -r38.0<1;1,0>:d   39:w               {Compacted}
        add (16|M16)             r12.0<1>:d    -r36.0<1;1,0>:d   39:w               {Compacted}
        and (16|M0)   (ne)f1.0   r14.0<1>:d    r4.0<1;1,0>:d     63:w               {I@2}
        and (16|M16)  (ne)f1.0   r2.0<1>:d     r12.0<1;1,0>:d    63:w               {I@2}
        add (16|M0)              r66.0<1>:d    -r38.0<1;1,0>:d   40:w               {Compacted}
        add (16|M16)             r68.0<1>:d    -r36.0<1;1,0>:d   40:w               {Compacted}
(f1.0)  goto (32|M0)                         L43240                  L43240                
L43200:
        mov (16|M0)              r34.0<1>:f    r48.0<1;1,0>:f                   {Compacted}
        mov (16|M16)             r32.0<1>:d    r44.0<1;1,0>:d                  
        goto (32|M0)                         L43240                  L43504                
L43240:
        join (32|M0)                         L43504                                
L43256:
        cmp (16|M0)   (lt)f0.0   null<1>:d     r14.0<1;1,0>:ud   0x20:uw              {I@7}
        cmp (16|M16)  (lt)f0.0   null<1>:d     r2.0<1;1,0>:ud    0x20:uw              {I@7}
(f0.0)  goto (32|M0)                         L43368                  L43368                
L43304:
        add (16|M0)              r4.0<1>:d     r14.0<1;1,0>:d    -32:w               {Compacted}
        add (16|M16)             r12.0<1>:d    r2.0<1;1,0>:d     -32:w               {Compacted}
        shr (16|M0)              r18.0<1>:ud   r42.0<1;1,0>:ud   r4.0<1;1,0>:d    {I@2}
        shr (16|M16)             r54.0<1>:ud   r40.0<1;1,0>:ud   r12.0<1;1,0>:d   {I@2}
        goto (32|M0)                         L43368                  L43464                
L43368:
        join (32|M0)                         L43464                                
L43384:
        add (16|M0)              r4.0<1>:d     -r14.0<1;1,0>:d   32:w               {Compacted}
        add (16|M16)             r12.0<1>:d    -r2.0<1;1,0>:d    32:w               {Compacted}
        shr (16|M16)             r16.0<1>:ud   r44.0<1;1,0>:ud   r2.0<1;1,0>:d   
        shl (16|M0)              r4.0<1>:d     r42.0<1;1,0>:d    r4.0<1;1,0>:d    {Compacted,I@3}
        shr (16|M0)              r14.0<1>:ud   r48.0<1;1,0>:ud   r14.0<1;1,0>:d  
        shl (16|M16)             r12.0<1>:d    r40.0<1;1,0>:d    r12.0<1;1,0>:d   {Compacted,I@4}
        or (16|M0)               r18.0<1>:d    r14.0<1;1,0>:d    r4.0<1;1,0>:d    {Compacted,I@2}
        or (16|M16)              r54.0<1>:d    r16.0<1;1,0>:d    r12.0<1;1,0>:d   {Compacted,I@2}
L43464:
        join (32|M0)                         L43504                                
L43480:
        mov (16|M0)              r34.0<1>:f    r18.0<1;1,0>:f                   {Compacted,I@3}
        mov (16|M16)             r32.0<1>:d    r54.0<1;1,0>:d                   {I@2}
L43504:
        join (32|M0)                         L44896                                
L43520:
        add (16|M0)              r20.0<1>:d    -r38.0<1;1,0>:d   38:w               {Compacted}
        add (16|M16)             r2.0<1>:d     -r36.0<1;1,0>:d   38:w               {Compacted}
        and (16|M0)   (ne)f1.0   r14.0<1>:d    r20.0<1;1,0>:d    63:w               {I@2}
        and (16|M16)  (ne)f1.0   r16.0<1>:d    r2.0<1;1,0>:d     63:w               {I@2}
(f1.0)  goto (32|M0)                         L43624                  L43624                
L43584:
        mov (16|M0)              r18.0<1>:f    r48.0<1;1,0>:f                   {Compacted}
        mov (16|M16)             r54.0<1>:d    r44.0<1;1,0>:d                  
        goto (32|M0)                         L43624                  L43848                
L43624:
        join (32|M0)                         L43848                                
L43640:
        cmp (16|M0)   (lt)f0.0   null<1>:d     r14.0<1;1,0>:ud   0x20:uw              {I@6}
        cmp (16|M16)  (lt)f0.0   null<1>:d     r16.0<1;1,0>:ud   0x20:uw              {I@6}
(f0.0)  goto (32|M0)                         L43752                  L43752                
L43688:
        add (16|M0)              r4.0<1>:d     r14.0<1;1,0>:d    -32:w               {Compacted}
        add (16|M16)             r12.0<1>:d    r16.0<1;1,0>:d    -32:w               {Compacted}
        shr (16|M0)              r18.0<1>:ud   r42.0<1;1,0>:ud   r4.0<1;1,0>:d    {A@1}
        shr (16|M16)             r54.0<1>:ud   r40.0<1;1,0>:ud   r12.0<1;1,0>:d   {I@2}
        goto (32|M0)                         L43752                  L43848                
L43752:
        join (32|M0)                         L43848                                
L43768:
        add (16|M0)              r4.0<1>:d     -r14.0<1;1,0>:d   32:w               {Compacted}
        add (16|M16)             r12.0<1>:d    -r16.0<1;1,0>:d   32:w               {Compacted}
        shl (16|M0)              r4.0<1>:d     r42.0<1;1,0>:d    r4.0<1;1,0>:d    {Compacted,I@2}
        shr (16|M0)              r14.0<1>:ud   r48.0<1;1,0>:ud   r14.0<1;1,0>:d  
        shl (16|M16)             r12.0<1>:d    r40.0<1;1,0>:d    r12.0<1;1,0>:d   {Compacted,I@3}
        shr (16|M16)             r16.0<1>:ud   r44.0<1;1,0>:ud   r16.0<1;1,0>:d  
        or (16|M0)               r18.0<1>:d    r14.0<1;1,0>:d    r4.0<1;1,0>:d    {Compacted,I@3}
        or (16|M16)              r54.0<1>:d    r16.0<1;1,0>:d    r12.0<1;1,0>:d   {Compacted,I@2}
L43848:
        join (32|M0)                         L44896                                
L43864:
        and (16|M0)   (ne)f1.0   r4.0<1>:d     r20.0<1;1,0>:d    63:w              
        and (16|M16)  (ne)f1.0   r20.0<1>:d    r2.0<1;1,0>:d     63:w              
        and (16|M0)              r38.0<1>:d    r18.0<1;1,0>:d    1:w               {Compacted,I@5}
        and (16|M16)             r56.0<1>:d    r54.0<1;1,0>:d    1:w               {Compacted,I@5}
(f1.0)  goto (32|M0)                         L44008                  L44008                
L43928:
        mov (16|M0)              r4.0<1>:d     -1:w                              
        mov (16|M16)             r14.0<1>:d    -1:w                              
        mov (16|M0)              r18.0<1>:d    -1:w                              
        mov (16|M16)             r16.0<1>:d    -1:w                              
        goto (32|M0)                         L44008                  L44280                
L44008:
        join (32|M0)                         L44280                                
L44024:
        cmp (16|M0)   (lt)f0.0   null<1>:d     r4.0<1;1,0>:ud    0x20:uw              {I@6}
        cmp (16|M16)  (lt)f0.0   null<1>:d     r20.0<1;1,0>:ud   0x20:uw             
(f0.0)  goto (32|M0)                         L44184                  L44184                
L44072:
        add (16|M0)              r4.0<1>:d     r4.0<1;1,0>:d     -32:w               {Compacted}
        add (16|M16)             r12.0<1>:d    r20.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r3.0<1>:hf    -qnan(0x1FF):hf                             
        mov (16|M16)             r14.0<1>:d    0:w                              
        shl (16|M0)              r18.0<1>:d    r3.0<0;1,0>:w     r4.0<1;1,0>:d    {A@1}
        shl (16|M16)             r16.0<1>:d    r3.0<0;1,0>:w     r12.0<1;1,0>:d   {I@3}
        mov (16|M0)              r4.0<1>:d     0:w                              
        goto (32|M0)                         L44184                  L44280                
L44184:
        join (32|M0)                         L44280                                
L44200:
(W)     mov (1|M0)               r3.0<1>:hf    -qnan(0x1FF):hf                              {I@4}
        mov (16|M0)              r18.0<1>:d    -1:w                              
        mov (16|M16)             r16.0<1>:d    -1:w                              
        shl (16|M0)              r4.0<1>:d     r3.0<0;1,0>:w     r4.0<1;1,0>:d    {A@1}
        shl (16|M16)             r14.0<1>:d    r3.0<0;1,0>:w     r20.0<1;1,0>:d  
L44280:
        join (32|M0)                         L44896                                
L44296:
        bfn.0x60 (16|M0)         r4.0<1>:ud    r4.0<1;0>:ud      r10.2<0;0>:ud     r48.0<1>:ud      {I@3} // (s0^s1)&s2
        bfn.0x60 (16|M16)        r12.0<1>:ud   r14.0<1;0>:ud     r10.2<0;0>:ud     r44.0<1>:ud      {I@3} // (s0^s1)&s2
        cmp (16|M0)   (ne)f1.0   null<1>:d     r4.0<1;1,0>:d     0:w               {I@2}
        cmp (16|M16)  (ne)f1.0   null<1>:d     r12.0<1;1,0>:d    0:w               {I@2}
        bfn.0x60 (16|M16)        r16.0<1>:ud   r16.0<1;0>:ud     r10.2<0;0>:ud     r40.0<1>:ud      // (s0^s1)&s2
        bfn.0x60 (16|M0)         r14.0<1>:ud   r18.0<1;0>:ud     r10.2<0;0>:ud     r42.0<1>:ud      // (s0^s1)&s2
(~f1.0) cmp (16|M16)  (ne)f1.0   null<1>:d     r16.0<1;1,0>:d    0:w               {I@2}
(~f1.0) cmp (16|M0)   (ne)f1.0   null<1>:d     r14.0<1;1,0>:d    0:w               {I@2}
(W)     mov (1|M0)               r3.0<1>:hf    -qnan(0x1FF):hf                             
(f1.0)  sel (16|M0)              r18.0<1>:d    r3.0<0;1,0>:w     0:w               {F@1}
(f1.0)  sel (16|M16)             r20.0<1>:d    r3.0<0;1,0>:w     0:w              
        and (16|M0)   (ne)f1.0   r14.0<1>:d    r66.0<1;1,0>:d    63:w              
        and (16|M16)  (ne)f1.0   r2.0<1>:d     r68.0<1;1,0>:d    63:w              
        mov (16|M0)              r62.0<1>:d    -r18.0<1;1,0>:d                  {I@4}
        mov (16|M16)             r58.0<1>:d    -r20.0<1;1,0>:d                  {I@4}
(f1.0)  goto (32|M0)                         L44592                  L44592                
L44552:
        mov (16|M0)              r18.0<1>:f    r48.0<1;1,0>:f                   {Compacted,I@3}
        mov (16|M16)             r54.0<1>:d    r44.0<1;1,0>:d                  
        goto (32|M0)                         L44592                  L44816                
L44592:
        join (32|M0)                         L44816                                
L44608:
        cmp (16|M0)   (lt)f0.0   null<1>:d     r14.0<1;1,0>:ud   0x20:uw             
        cmp (16|M16)  (lt)f0.0   null<1>:d     r2.0<1;1,0>:ud    0x20:uw             
(f0.0)  goto (32|M0)                         L44720                  L44720                
L44656:
        add (16|M0)              r4.0<1>:d     r14.0<1;1,0>:d    -32:w               {Compacted}
        add (16|M16)             r12.0<1>:d    r2.0<1;1,0>:d     -32:w               {Compacted}
        shr (16|M0)              r18.0<1>:ud   r42.0<1;1,0>:ud   r4.0<1;1,0>:d    {A@1}
        shr (16|M16)             r54.0<1>:ud   r40.0<1;1,0>:ud   r12.0<1;1,0>:d   {I@2}
        goto (32|M0)                         L44720                  L44816                
L44720:
        join (32|M0)                         L44816                                
L44736:
        add (16|M0)              r4.0<1>:d     -r14.0<1;1,0>:d   32:w               {Compacted}
        add (16|M16)             r12.0<1>:d    -r2.0<1;1,0>:d    32:w               {Compacted}
        shr (16|M16)             r16.0<1>:ud   r44.0<1;1,0>:ud   r2.0<1;1,0>:d   
        shl (16|M0)              r4.0<1>:d     r42.0<1;1,0>:d    r4.0<1;1,0>:d    {Compacted,I@3}
        shr (16|M0)              r14.0<1>:ud   r48.0<1;1,0>:ud   r14.0<1;1,0>:d  
        shl (16|M16)             r12.0<1>:d    r40.0<1;1,0>:d    r12.0<1;1,0>:d   {Compacted,I@4}
        or (16|M0)               r18.0<1>:d    r14.0<1;1,0>:d    r4.0<1;1,0>:d    {Compacted,I@2}
        or (16|M16)              r54.0<1>:d    r16.0<1;1,0>:d    r12.0<1;1,0>:d   {Compacted,I@2}
L44816:
        join (32|M0)                         L44896                                
L44832:
        mov (16|M0)              r42.0<1>:f    r18.0<1;1,0>:f                   {Compacted,I@3}
        mov (16|M16)             r6.0<1>:f     r54.0<1;1,0>:f                   {Compacted,I@2}
        mov (16|M0)              r18.0<1>:d    r34.0<1;1,0>:d                   {F@2}
        mov (16|M16)             r54.0<1>:d    r32.0<1;1,0>:d                   {F@1}
        goto (32|M0)                         L44896                  L45056                
L44896:
        join (32|M0)                         L45056                                
L44912:
        shr (16|M0)              r18.0<1>:ud   r48.0<1;1,0>:ud   2:w              
        shr (16|M16)             r54.0<1>:ud   r44.0<1;1,0>:ud   2:w              
        mov (16|M0)              r62.0<1>:d    0:w                              
        mov (16|M16)             r58.0<1>:d    0:w                              
        mov (16|M0)              r38.0<1>:d    0:w                              
        mov (16|M16)             r56.0<1>:d    0:w                              
        mov (16|M0)              r42.0<1>:f    r18.0<1;1,0>:f                   {Compacted,I@6}
        mov (16|M16)             r6.0<1>:f     r54.0<1;1,0>:f                   {Compacted,I@5}
        shr (16|M0)              r18.0<1>:ud   r48.0<1;1,0>:ud   1:w               {F@2}
        shr (16|M16)             r54.0<1>:ud   r44.0<1;1,0>:ud   1:w               {F@1}
L45056:
        join (32|M0)                         L45904                                
L45072:
        shl (16|M0)              r4.0<1>:d     r18.0<1;1,0>:d    2:w               {Compacted,I@3}
        shl (16|M16)             r12.0<1>:d    r54.0<1;1,0>:d    2:w               {Compacted,I@3}
        shl (16|M0)              r14.0<1>:d    r38.0<1;1,0>:d    1:w               {Compacted}
        shl (16|M16)             r16.0<1>:d    r56.0<1;1,0>:d    1:w               {Compacted}
        and (16|M0)              r4.0<1>:d     r4.0<1;1,0>:d     4:w               {Compacted,I@4}
        and (16|M16)             r12.0<1>:d    r12.0<1;1,0>:d    4:w               {Compacted,I@4}
        bfn.0xFE (16|M0)         r4.0<1>:ud    r4.0<1;0>:ud      r14.0<1;0>:ud     r62.0<1>:ud      {I@2} // s0|s1|s2
        bfn.0xFE (16|M16)        r14.0<1>:ud   r12.0<1;0>:ud     r16.0<1;0>:ud     r58.0<1>:ud      {I@2} // s0|s1|s2
        cmp (16|M0)   (eq)f1.0   null<1>:d     r4.0<1;1,0>:d     0:w               {I@2}
        cmp (16|M16)  (eq)f1.0   null<1>:d     r14.0<1;1,0>:d    0:w               {I@2}
        and (16|M0)              r32.0<1>:d    r42.0<1;1,0>:d    8388607:d              
        and (16|M16)             r20.0<1>:d    r6.0<1;1,0>:d     8388607:d              
(~f1.0) goto (32|M0)                         L45280                  L45280                
L45232:
        mov (16|M0)              r4.0<1>:d     0:w                              
        mov (16|M16)             r12.0<1>:d    0:w                              
        goto (32|M0)                         L45280                  L45512                
L45280:
        join (32|M0)                         L45512                                
L45296:
        cmp (16|M0)   (gt)f0.0   null<1>:d     r4.0<1;1,0>:ud    0x4:uw              {I@4}
        cmp (16|M16)  (gt)f0.0   null<1>:d     r14.0<1;1,0>:ud   0x4:uw             
(~f0.0) goto (32|M0)                         L45392                  L45392                
L45344:
        mov (16|M0)              r4.0<1>:d     1:w                              
        mov (16|M16)             r12.0<1>:d    1:w                              
        goto (32|M0)                         L45392                  L45512                
L45392:
        join (32|M0)                         L45512                                
L45408:
        and (16|M0)   (ne)f0.0   null<1>:d     r42.0<1;1,0>:d    1:w               {Compacted}
        and (16|M16)  (ne)f0.0   null<1>:d     r6.0<1;1,0>:d     1:w              
(f0.0)  cmp (16|M0)   (eq)f0.0   null<1>:d     r4.0<1;1,0>:d     4:w               {I@6}
(f0.0)  cmp (16|M16)  (eq)f0.0   null<1>:d     r14.0<1;1,0>:d    4:w              
(W)     mov (1|M0)               r3.0<1>:hf    0x1:hf                             
(f0.0)  sel (16|M0)              r4.0<1>:d     r3.0<0;1,0>:w     0:w               {F@1}
(f0.0)  sel (16|M16)             r12.0<1>:d    r3.0<0;1,0>:w     0:w              
L45512:
        join (32|M0)                         L45904                                
L45528:
        add (16|M0)              r16.0<1>:d    r32.0<1;1,0>:d    r4.0<1;1,0>:d    {Compacted,I@3}
        add (16|M16)             r14.0<1>:d    r20.0<1;1,0>:d    r12.0<1;1,0>:d   {Compacted,I@3}
        cmp (16|M0)   (gt)f0.0   null<1>:d     r16.0<1;1,0>:ud   0x7FFFFF:ud              {I@2}
        cmp (16|M16)  (gt)f0.0   null<1>:d     r14.0<1;1,0>:ud   0x7FFFFF:ud              {I@2}
        add3 (16|M0)             r4.0<1>:d     r52.0<1;0>:d      r30.0<1;0>:d      -45:w              
        add3 (16|M16)            r12.0<1>:d    r50.0<1;0>:d      r24.0<1;0>:d      -45:w              
(f0.0)  sel (16|M0)              r6.0<1>:d     r4.0<1;1,0>:d     r60.0<1;1,0>:d   {Compacted,I@2}
(f0.0)  sel (16|M16)             r2.0<1>:d     r12.0<1;1,0>:d    r64.0<1;1,0>:d   {I@2}
        cmp (16|M0)   (eq)f1.0   null<1>:d     r6.0<1;1,0>:d     255:w               {I@2}
        cmp (16|M16)  (eq)f1.0   null<1>:d     r2.0<1;1,0>:d     255:w               {I@2}
(f1.0)  goto (32|M0)                         L45816                  L45816                
L45680:
(~f0.0) sel (16|M0)              r4.0<1>:d     r16.0<1;1,0>:d    0:w              
(~f0.0) sel (16|M16)             r12.0<1>:d    r14.0<1;1,0>:d    0:w              
        shl (16|M0)              r18.0<1>:d    r6.0<1;1,0>:d     23:w               {Compacted}
        shl (16|M16)             r20.0<1>:d    r2.0<1;1,0>:d     23:w               {Compacted}
        and (16|M16)             r16.0<1>:d    r28.0<1;1,0>:d    -2147483648:d              
        and (16|M0)              r14.0<1>:d    r22.0<1;1,0>:d    -2147483648:d              
        sync.nop                             null                             {Compacted,$15.src}
        bfn.0xFE (16|M16)        r26.0<1>:ud   r16.0<1;0>:ud     r20.0<1;0>:ud     r12.0<1>:ud      {I@2} // s0|s1|s2
        bfn.0xFE (16|M0)         r22.0<1>:ud   r14.0<1;0>:ud     r18.0<1;0>:ud     r4.0<1>:ud       {I@2} // s0|s1|s2
        goto (32|M0)                         L45816                  L46712                
L45816:
        join (32|M0)                         L45904                                
L45832:
        cmp (16|M0)   (gt)f0.0   null<1>:d     r22.0<1;1,0>:d    -1:w               {Compacted,I@3}
        cmp (16|M16)  (gt)f0.0   null<1>:d     r28.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r3.0<1>:f     inf:f                               {Compacted}
(f0.0)  sel (16|M0)              r22.0<1>:f    r3.0<0;1,0>:f     -inf:f               {Compacted,A@1}
(f0.0)  sel (16|M16)             r26.0<1>:f    r3.0<0;1,0>:f     -inf:f               {$15.src}
        goto (32|M0)                         L45904                  L46712                
L45904:
        join (32|M0)                         L46376                                
L45920:
        and (16|M0)   (ne)f1.0   r4.0<1>:d     r30.0<1;1,0>:d    63:w              
        and (16|M16)  (ne)f1.0   r12.0<1>:d    r24.0<1;1,0>:d    63:w              
(f1.0)  goto (32|M0)                         L46016                  L46016                
L45968:
        mov (16|M0)              r4.0<1>:d     -1:w                              
        mov (16|M16)             r6.0<1>:d     -1:w                              
        goto (32|M0)                         L46016                  L46192                
L46016:
        join (32|M0)                         L46192                                
L46032:
        cmp (16|M0)   (lt)f0.0   null<1>:d     r4.0<1;1,0>:ud    0x20:uw              {A@1}
        cmp (16|M16)  (lt)f0.0   null<1>:d     r12.0<1;1,0>:ud   0x20:uw             
(f0.0)  goto (32|M0)                         L46128                  L46128                
L46080:
        mov (16|M0)              r4.0<1>:d     0:w                              
        mov (16|M16)             r6.0<1>:d     0:w                              
        goto (32|M0)                         L46128                  L46192                
L46128:
        join (32|M0)                         L46192                                
L46144:
(W)     mov (1|M0)               r3.0<1>:hf    -qnan(0x1FF):hf                             
        shl (16|M0)              r4.0<1>:d     r3.0<0;1,0>:w     r4.0<1;1,0>:d    {A@1}
        shl (16|M16)             r6.0<1>:d     r3.0<0;1,0>:w     r12.0<1;1,0>:d  
L46192:
        join (32|M0)                         L46376                                
L46208:
        bfn.0x60 (16|M0)         r4.0<1>:ud    r4.0<1;0>:ud      r10.2<0;0>:ud     r48.0<1>:ud      {I@3} // (s0^s1)&s2
        bfn.0x60 (16|M16)        r12.0<1>:ud   r6.0<1;0>:ud      r10.2<0;0>:ud     r44.0<1>:ud      {I@3} // (s0^s1)&s2
        add (16|M0)              r14.0<1>:d    -r30.0<1;1,0>:d   23:w               {Compacted}
        add (16|M16)             r16.0<1>:d    -r24.0<1;1,0>:d   23:w               {Compacted}
        and (16|M0)              r18.0<1>:d    r22.0<1;1,0>:d    -2147483648:d              
        and (16|M16)             r20.0<1>:d    r28.0<1;1,0>:d    -2147483648:d              
        shl (16|M0)              r4.0<1>:d     r4.0<1;1,0>:d     r14.0<1;1,0>:d   {Compacted,I@4}
        shl (16|M16)             r12.0<1>:d    r12.0<1;1,0>:d    r16.0<1;1,0>:d   {Compacted,I@4}
        shl (16|M16)             r24.0<1>:d    r64.0<1;1,0>:d    23:w               {Compacted}
        shl (16|M0)              r22.0<1>:d    r60.0<1;1,0>:d    23:w               {Compacted}
        sync.nop                             null                             {Compacted,$15.src}
        bfn.0xFE (16|M16)        r26.0<1>:ud   r20.0<1;0>:ud     r24.0<1;0>:ud     r12.0<1>:ud      {I@2} // s0|s1|s2
        bfn.0xFE (16|M0)         r22.0<1>:ud   r18.0<1;0>:ud     r22.0<1;0>:ud     r4.0<1>:ud       {I@2} // s0|s1|s2
        goto (32|M0)                         L46376                  L46712                
L46376:
        join (32|M0)                         L46472                                
L46392:
        cmp (16|M0)   (gt)f1.0   null<1>:d     r22.0<1;1,0>:d    -1:w               {I@3}
        cmp (16|M16)  (gt)f1.0   null<1>:d     r28.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r3.0<1>:f     inf:f                               {Compacted}
(f1.0)  sel (16|M0)              r22.0<1>:f    r3.0<0;1,0>:f     -inf:f               {Compacted,A@1}
(f1.0)  sel (16|M16)             r26.0<1>:f    r3.0<0;1,0>:f     -inf:f               {$15.src}
        goto (32|M0)                         L46472                  L46712                
L46472:
        join (32|M0)                         L46560                                
L46488:
        cmp (16|M0)   (lt)f0.0   null<1>:d     r22.0<1;1,0>:d    0:w               {Compacted,F@2}
        cmp (16|M16)  (lt)f0.0   null<1>:d     r28.0<1;1,0>:d    0:w              
(W)     mov (1|M0)               r3.0<1>:f     -0.0:f                               {Compacted}
(f0.0)  sel (16|M0)              r22.0<1>:f    r3.0<0;1,0>:f     0.0:f               {Compacted,A@1}
(f0.0)  sel (16|M16)             r26.0<1>:f    r3.0<0;1,0>:f     0.0:f               {$15.src}
        goto (32|M0)                         L46560                  L46712                
L46560:
        join (32|M0)                         L46656                                
L46576:
        cmp (16|M0)   (gt)f1.0   null<1>:d     r22.0<1;1,0>:d    -1:w               {F@2}
        cmp (16|M16)  (gt)f1.0   null<1>:d     r28.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r3.0<1>:f     inf:f                               {Compacted}
(f1.0)  sel (16|M0)              r22.0<1>:f    r3.0<0;1,0>:f     -inf:f               {Compacted,A@1}
(f1.0)  sel (16|M16)             r26.0<1>:f    r3.0<0;1,0>:f     -inf:f               {$15.src}
        goto (32|M0)                         L46656                  L46712                
L46656:
        join (32|M0)                         L46712                                
L46672:
        bfn.0xF8 (16|M0)         r22.0<1>:ud   r22.0<1;0>:ud     r10.4<0;0>:ud     r10.3<0>:ud      {F@2} // s0&s1|s2
        sync.nop                             null                             {Compacted,$15.src}
        bfn.0xF8 (16|M16)        r26.0<1>:ud   r28.0<1;0>:ud     r10.4<0;0>:ud     r10.3<0>:ud      {F@1} // s0&s1|s2
L46712:
        join (32|M0)                         L47048                                
L46728:
        cmp (16|M0)   (lt)f0.0   null<1>:f     r78.0<1;1,0>:f    0.0:f               {Compacted}
        cmp (16|M16)  (lt)f0.0   null<1>:f     r76.0<1;1,0>:f    0.0:f              
(f0.0)  sel (16|M0)              r4.0<1>:f     -r22.0<1;1,0>:f   r22.0<1;1,0>:f   {Compacted,I@3}
(f0.0)  sel (16|M16)             r12.0<1>:f    -r26.0<1;1,0>:f   r26.0<1;1,0>:f   {I@2}
(W)     shl (1|M0)               r7.6<1>:d     r10.5<0;1,0>:d    1:w              
(W)     mov (1|M0)               a0.0<1>:ud    r9.7<0;1,0>:d                    {A@1}
(W)     cmp (16|M0)   (lt)f1.0   null<1>:d     r10.5<0;1,0>:ud   0x1F:uw             
(W)     cmp (16|M16)  (lt)f1.0   null<1>:d     r10.5<0;1,0>:ud   0x1F:uw             
        mov (8|M0)               r3.0<1>:hf    r4.0<1;1,0>:f                    {F@2}
        mov (8|M8)               r3.8<1>:hf    r5.0<1;1,0>:f                   
        mov (8|M16)              r6.0<1>:hf    r12.0<1;1,0>:f                   {F@3}
        mov (8|M24)              r6.8<1>:hf    r13.0<1;1,0>:f                  
        add3 (16|M0)             r14.0<1>:d    r92.0<1;0>:d      r9.4<0;0>:d       r7.6<0>:d        {I@4}
        add3 (16|M16)            r16.0<1>:d    r90.0<1;0>:d      r9.4<0;0>:d       r7.6<0>:d       
        mov (16|M0)              r18.0<1>:ud   r3.0<1;1,0>:uw                   {A@3}
        mov (16|M16)             r20.0<1>:ud   r6.0<1;1,0>:uw                   {A@1}
        send.ugm (16|M0)         null     r14     r18:2   a0.0        0x240E0B04           {ExBSO,A@2,$5} // wr:2+2, rd:0; store.ugm.d16u32.a32.wb.wb.bss[a0.0]
        send.ugm (16|M16)        null     r16     r20:2   a0.0        0x240E0B04           {ExBSO,A@1,$6} // wr:2+2, rd:0; store.ugm.d16u32.a32.wb.wb.bss[a0.0]
(~f1.0) goto (32|M0)                         L47048                  L47048                
L47016:
(W)     add (1|M0)               r10.6<1>:d    r10.6<0;1,0>:d    2:w              
(W)     jmpi                                 L3144                                
L47048:
        join (32|M0)                         L47064                                
L47064:
(W)     mov (8|M0)               r127.0<1>:f   r46.0<1;1,0>:f                   {Compacted,$3.src}
(W)     send.gtwy (1|M0)         null     r127    null:0  0x0            0x02000010           {EOT,A@1} // wr:1+0, rd:0; end of thread
L47088:
        nop                    
(W)     mov (16|M0)              null<1>:ud    0x9E09665A:ud                             
(W)     mov (16|M0)              null<1>:ud    0xA6E09A48:ud                             
(W)     mov (16|M0)              null<1>:ud    0x0:ud                             
(W)     mov (16|M0)              null<1>:ud    0x67:ud                             
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
