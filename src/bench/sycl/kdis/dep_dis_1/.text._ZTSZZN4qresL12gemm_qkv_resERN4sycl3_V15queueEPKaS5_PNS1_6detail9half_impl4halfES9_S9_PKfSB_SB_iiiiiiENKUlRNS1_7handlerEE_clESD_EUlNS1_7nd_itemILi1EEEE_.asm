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
        and (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   -1265:w               {A@1}
        or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   1216:w               {A@1}
        sync.nop                             null                             {Compacted,A@1}
        sync.nop                             null                             {Compacted,$1.dst}
        asr (1|M0)               r99.1<1>:d    r2.2<0;1,0>:d     31:w               {A@1}
        mov (1|M0)               r99.0<1>:d    r0.1<0;1,0>:ud                  
        shr (1|M0)               r99.1<1>:ud   r99.1<0;1,0>:ud   0x1A:uw              {I@2}
        mov (1|M0)               r43.0<1>:d    r1.0<0;1,0>:uw                   {$0.dst}
        add (1|M0)               r99.1<1>:d    r2.2<0;1,0>:d     r99.1<0;1,0>:d   {I@2}
        asr (1|M0)               r99.1<1>:d    r99.1<0;1,0>:d    6:w               {Compacted,I@1}
        mov (2|M0)               r98.4<1>:d    r99.0<1;1,0>:d                   {I@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r98.6         L9384                                 {A@1}
L376:
        asr (1|M0)               r43.1<1>:d    r2.6<0;1,0>:d     31:w              
(W)     mul (1|M0)               acc0.0<1>:d   r98.0<0;1,0>:d    r99.2<0;1,0>:uw  {Compacted}
        shr (1|M0)               r43.1<1>:ud   r43.1<0;1,0>:ud   0x1B:uw              {I@2}
(W)     mach (1|M0)              r2.0<1>:d     r98.0<0;1,0>:d    r99.1<0;1,0>:d   {Compacted}
        add (1|M0)               r43.1<1>:d    r2.6<0;1,0>:d     r43.1<0;1,0>:d   {I@2}
        mov (1|M0)               r99.1<1>:d    r2.0<0;1,0>:d                    {I@2}
        asr (1|M0)               r43.1<1>:d    r43.1<0;1,0>:d    5:w               {Compacted,I@2}
        add (1|M0)               r5.4<1>:d     r99.0<0;1,0>:d    -r99.1<0;1,0>:d  {I@2}
(W)     mul (1|M0)               acc0.0<1>:d   r98.0<0;1,0>:d    r43.2<0;1,0>:uw  {Compacted,I@2}
        mach (1|M0)              r6.0<1>:d     r98.0<0;1,0>:d    r43.1<0;1,0>:d   {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r98.0<0;1,0>:d    r43.2<0;1,0>:uw  {Compacted}
        mach (1|M0)              r7.0<1>:d     r98.0<0;1,0>:d    r43.1<0;1,0>:d   {Compacted}
        shl (1|M0)               r9.0<1>:d     r5.4<0;1,0>:d     11:w               {Compacted,I@5}
        shl (1|M0)               r1.4<1>:d     r7.0<0;1,0>:d     12:w               {Compacted,I@2}
        asr (1|M0)               r7.1<1>:d     r6.0<0;1,0>:d     31:w               {Compacted}
        addc (1|M0)              r2.0<1>:ud    r2.4<0;1,0>:ud    r1.4<0;1,0>:ud   {AccWrEn,I@2}
        shr (1|M0)               r1.3<1>:ud    r7.0<0;1,0>:ud    0x14:uw             
        shl (1|M0)               r1.2<1>:d     r7.1<0;1,0>:d     12:w               {I@3}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        shl (1|M0)               r7.0<1>:ud    r43.0<0;1,0>:ud   0x7:uw             
        addc (1|M0)              r6.0<1>:ud    r3.0<0;1,0>:ud    r9.0<0;1,0>:ud   {AccWrEn}
        shr (1|M0)               r2.1<1>:ud    r5.4<0;1,0>:ud    0x15:uw             
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@5}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        shl (1|M0)               r1.2<1>:ud    r43.0<0;1,0>:ud   0x6:uw             
        addc (1|M0)              r11.0<1>:ud   r2.0<0;1,0>:ud    r7.0<0;1,0>:ud   {AccWrEn,I@6}
        or (1|M0)                r9.1<1>:d     r2.1<0;1,0>:d     0:w               {Compacted,I@5}
        add3 (1|M0)              r5.3<1>:d     r8.0<0;0>:d       r2.5<0;0>:d       r1.5<0>:d        {I@5}
        mov (1|M0)               r12.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r8.0<1>:ud    r6.0<0;1,0>:ud    r1.2<0;1,0>:ud   {AccWrEn,I@5}
        add3 (1|M0)              r6.2<1>:d     r10.0<0;0>:d      r3.1<0;0>:d       r9.1<0>:d        {I@4}
        mov (1|M0)               r17.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r45.0<1>:f    r11.0<0;1,0>:f                   {Compacted}
        add3 (1|M0)              r45.1<1>:d    r12.0<0;0>:d      r5.3<0;0>:d       0:w               {I@4}
        mov (1|M0)               r46.0<1>:f    r8.0<0;1,0>:f                    {Compacted,I@4}
        add3 (1|M0)              r46.1<1>:d    r17.0<0;0>:d      r6.2<0;0>:d       0:w               {I@2}
        send.ugm (1|M0)          r13      r45     null:0  0x0            0x0240D780           {A@2,$2} // wr:1+0, rd:4; load.ugm.d64x16t.a64
        send.ugm (1|M0)          r9       r46     null:0  0x0            0x0220C780           {A@1,$3} // wr:1+0, rd:2; load.ugm.d64x8t.a64
        add (1|M0)               r44.0<1>:ud   r1.2<0;1,0>:ud    0x2000:uw             
        shr (1|M0)               r45.4<1>:ud   r43.0<0;1,0>:ud   0x2:uw              {$2.src}
        and (1|M0)               r45.6<1>:d    r1.0<0;1,0>:uw    3:w              
        add (1|M0)               r45.2<1>:d    r99.0<0;1,0>:d    -r99.1<0;1,0>:d 
        send.slm (1|M0)          null     r7      r13:4   0x0            0x0200D704           {$2} // wr:1+4, rd:0; store.slm.d64x16t.a32
        send.slm (1|M0)          null     r44     r9:2    0x0            0x0200C704           {A@4,$3} // wr:1+2, rd:0; store.slm.d64x8t.a32
(W)     send.slm (1|M0)          r11      r0      null:0  0x0            0x0210001F           {$4} // wr:1+0, rd:1; fence.slm.none.group
(W)     mov (1|M0)               r12.2<1>:f    0.0:f                               {Compacted}
(W)     mov (2|M0)               r12.10<1>:ub  r0.11<0;1,0>:ub                  {F@1}
(W)     mov (8|M0)               null<1>:ud    r11.0<1;1,0>:ud                  {$4.dst}
(W)     send.gtwy (1|M0)         null     r12     null:0  0x0            0x02000004           {A@2,$5} // wr:1+0, rd:0; signal barrier
(W)     sync.bar                             null                            
        cmp (1|M0)    (gt)f0.1   null<1>:d     r2.6<0;1,0>:d     31:w              
        shl (1|M0)               r43.2<1>:ud   r45.4<0;1,0>:ud   0x9:uw             
        shl (1|M0)               r43.3<1>:d    r45.6<0;1,0>:d    9:w              
        mov (16|M0)              r47.0<1>:d    0:w                              
(W)     and (1|M0)               f1.1<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
        mov (16|M0)              r49.0<1>:d    0:w                              
        mov (16|M0)              r51.0<1>:d    0:w                              
        mov (16|M0)              r53.0<1>:d    0:w                              
        mov (16|M0)              r55.0<1>:d    0:w                              
        mov (16|M0)              r57.0<1>:d    0:w                              
        mov (16|M0)              r59.0<1>:d    0:w                              
        mov (16|M0)              r61.0<1>:d    0:w                              
        mov (16|M0)              r63.0<1>:d    0:w                              
        mov (16|M0)              r65.0<1>:d    0:w                              
        mov (16|M0)              r67.0<1>:d    0:w                              
        mov (16|M0)              r69.0<1>:d    0:w                              
        mov (16|M0)              r71.0<1>:d    0:w                              
        mov (16|M0)              r73.0<1>:d    0:w                              
        mov (16|M0)              r75.0<1>:d    0:w                              
        mov (16|M0)              r77.0<1>:d    0:w                              
(~f1.1.any16h) goto (16|M0)                  L2664                  L2664                
L1368:
        asr (1|M0)               r1.3<1>:d     r2.2<0;1,0>:d     31:w              
        shr (1|M0)               r2.1<1>:ud    r2.2<0;1,0>:ud    0x1B:uw             
        mov (1|M0)               r44.1<1>:f    r43.1<0;1,0>:f                   {Compacted,$3.src}
        shl (1|M0)               r2.0<1>:d     r1.3<0;1,0>:d     5:w               {Compacted,I@2}
        shl (1|M0)               r43.6<1>:d    r2.2<0;1,0>:d     5:w              
        mov (1|M0)               r44.4<2>:f    0.0:f                              
        mov (1|M0)               r44.5<2>:f    0.0:f                              
        mov (2|M0)               r43.4<1>:d    r44.1<1;1,0>:d                   {F@3}
        or (1|M0)                r43.7<1>:d    r2.0<0;1,0>:d     r2.1<0;1,0>:d    {I@3}
        asr (1|M0)               r43.5<1>:d    r43.1<0;1,0>:d    31:w              
        mov (1|M0)               r44.2<1>:d    0:w                              
L1528:
        addc (1|M0)              r2.0<1>:ud    r44.4<0;1,0>:ud   0x1:ud              {AccWrEn,F@2}
(W)     mov (1|M0)               r1.3<1>:hf    0x1:hf                             
        mov (1|M0)               r44.6<1>:d    r2.0<0;1,0>:d                    {I@1}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        cmp (1|M0)    (lt)f0.0   null<1>:ud    r44.6<0;1,0>:ud   r43.4<0;1,0>:ud  {I@2}
        add3 (1|M0)              r44.7<1>:d    r6.0<0;0>:d       r44.5<0;0>:d      0:w               {A@2}
        and (1|M0)               r44.3<1>:d    r44.4<0;1,0>:d    1:w              
        cmp (1|M0)    (lt)f1.0   null<1>:d     r44.7<0;1,0>:d    r43.5<0;1,0>:d   {I@2}
(f0.0)  cmp (1|M0)    (eq)f0.0   null<1>:d     r44.7<0;1,0>:d    r43.5<0;1,0>:d  
(f1.0)  sel (1|M0)               r4.2<1>:uw    r1.3<0;1,0>:uw    0x0:uw              {F@1}
(f0.0)  sel (1|M0)               r1.4<1>:uw    r1.3<0;1,0>:uw    0x0:uw             
        or (1|M0)     (ne)f0.0   null<1>:uw    r1.4<0;1,0>:uw    r4.2<0;1,0>:uw   {I@1}
(W)     and (1|M0)               f1.0<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
(~f1.0.any16h) goto (16|M0)                  L2208                  L2208                
L1744:
        shl (1|M0)               r1.5<1>:d     r44.6<0;1,0>:d    12:w              
        shl (1|M0)               r1.3<1>:d     r44.7<0;1,0>:d    12:w              
        shr (1|M0)               r1.4<1>:ud    r44.6<0;1,0>:ud   0x14:uw             
        addc (1|M0)              r2.0<1>:ud    r45.0<0;1,0>:ud   r1.5<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r1.6<1>:d     r1.3<0;1,0>:d     r1.4<0;1,0>:d    {I@2}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        sync.allrd                           ($2,$6)                
        mov (1|M0)               r7.0<1>:f     r2.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r7.1<1>:d     r6.0<0;0>:d       r45.1<0;0>:d      r1.6<0>:d        {I@1}
        mul (1|M0)               acc0.0<1>:ud  r43.6<0;1,0>:ud   r44.12<0;1,0>:uw
        sync.nop                             null                             {Compacted,$8.src}
        send.ugm (1|M0)          r8       r7      null:0  0x0            0x0240D780           {A@1,$9} // wr:1+0, rd:4; load.ugm.d64x16t.a64
        mach (1|M0)              r14.0<1>:ud   r43.6<0;1,0>:ud   r44.6<0;1,0>:ud  {AccWrEn}
        xor (1|M0)               r1.2<1>:d     r44.3<0;1,0>:d    1:w              
        mov (1|M0)               r13.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r43.6<0;1,0>:d    r44.14<0;1,0>:uw
        mach (1|M0)              r15.0<1>:d    r43.6<0;1,0>:d    r44.7<0;1,0>:d  
(W)     mul (1|M0)               acc0.0<1>:d   r43.7<0;1,0>:d    r44.12<0;1,0>:uw
        mach (1|M0)              r2.0<1>:d     r43.7<0;1,0>:d    r44.6<0;1,0>:d  
        addc (1|M0)              r6.0<1>:ud    r46.0<0;1,0>:ud   r13.0<0;1,0>:ud  {AccWrEn,I@5}
        shl (1|M0)               r4.1<1>:d     r1.2<0;1,0>:d     12:w              
        add3 (1|M0)              r1.4<1>:d     r2.0<0;0>:d       r14.0<0;0>:d      r15.0<0>:d       {I@3}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$9.src}
        mov (1|M0)               r16.0<1>:f    r6.0<0;1,0>:f                    {Compacted,I@4}
        sync.nop                             null                             {Compacted,$5.src}
        mad (1|M0)               r12.0<1>:d    r4.1<0;0>:d       r1.0<0;0>:uw      128:w               {I@3}
        add3 (1|M0)              r16.1<1>:d    r7.0<0;0>:d       r46.1<0;0>:d      r1.4<0>:d        {I@2}
        shl (1|M0)               r1.2<1>:d     r1.2<0;1,0>:d     11:w              
        send.slm (1|M0)          null     r12     r8:4    0x0            0x0200D704           {A@3,$9} // wr:1+4, rd:0; store.slm.d64x16t.a32
        sync.nop                             null                             {Compacted,$9.src}
        send.ugm (1|M0)          r8       r16     null:0  0x0            0x0220C780           {A@1,$10} // wr:1+0, rd:2; load.ugm.d64x8t.a64
        add (1|M0)               r10.0<1>:d    r1.2<0;1,0>:d     r44.0<0;1,0>:d   {Compacted,I@1}
        sync.nop                             null                             {Compacted,$10.dst}
        send.slm (1|M0)          null     r10     r8:2    0x0            0x0200C704           {A@1,$8} // wr:1+2, rd:0; store.slm.d64x8t.a32
L2208:
        join (16|M0)                         L2664                                
L2224:
        shl (1|M0)               r1.2<1>:d     r44.3<0;1,0>:d    12:w              
        shl (1|M0)               r44.3<1>:d    r44.3<0;1,0>:d    11:w               {Compacted}
        add (1|M0)               r2.0<1>:d     r1.2<0;1,0>:d     r43.2<0;1,0>:d   {I@2}
        bfn.0xFE (1|M0)          r6.0<1>:ud    0x2000:uw               r44.3<0;0>:ud     r43.3<0>:ud      {I@2} // s0|s1|s2
        bfn.0xFE (1|M0)          r32.0<1>:ud   0x2100:uw               r44.3<0;0>:ud     r43.3<0>:ud      // s0|s1|s2
        sync.nop                             null                             {Compacted,$2.src}
        or (1|M0)                r15.0<1>:ud   r2.0<0;1,0>:ud    0x100:uw              {I@3}
        sync.allrd                           ($5,$6)                
        send.slm (1|M0)          r7       r2      null:0  0x0            0x0280E700           {$11} // wr:1+0, rd:8; load.slm.d64x32t.a32
        send.slm (1|M0)          r24      r6      null:0  0x0            0x0280E700           {A@3,$12} // wr:1+0, rd:8; load.slm.d64x32t.a32
        send.slm (1|M0)          r33      r32     null:0  0x0            0x0280E700           {A@2,$13} // wr:1+0, rd:8; load.slm.d64x32t.a32
        send.slm (1|M0)          r16      r15     null:0  0x0            0x0280E700           {A@1,$14} // wr:1+0, rd:8; load.slm.d64x32t.a32
        sync.allwr                           ($6,$11,$12,$13,$14)                
        dpas.8x8 (8|M0)          r71:d         r71:d             r24:b             r7.0:b           {Atomic}
        dpas.8x8 (8|M0)          r63:d         r63:d             r33:b             r7.0:b           {Atomic}
        dpas.8x8 (8|M0)          r55:d         r55:d             r24:b             r16.0:b          {Atomic}
        dpas.8x8 (8|M0)          r47:d         r47:d             r33:b             r16.0:b          {$6}
(W)     send.slm (1|M0)          r41      r0      null:0  0x0            0x0210001F           {$15} // wr:1+0, rd:1; fence.slm.none.group
(W)     mov (1|M0)               r42.2<1>:f    0.0:f                               {Compacted,$7.src}
(W)     mov (2|M0)               r42.10<1>:ub  r0.11<0;1,0>:ub                  {F@1}
(W)     mov (8|M0)               null<1>:ud    r41.0<1;1,0>:ud                  {$15.dst}
(W)     send.gtwy (1|M0)         null     r42     null:0  0x0            0x02000004           {A@2,$7} // wr:1+0, rd:0; signal barrier
(W)     sync.bar                             null                            
        cmp (1|M0)    (eq)f1.0   null<1>:d     r44.7<0;1,0>:d    r44.2<0;1,0>:d  
(f1.0)  cmp (1|M0)    (eq)f1.0   null<1>:d     r44.6<0;1,0>:d    r44.1<0;1,0>:d  
(W)     and (1|M0)               f0.1<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
(f0.1.any16h) goto (16|M0)                   L2664                  L2664                
L2632:
(W)     mov (2|M0)               r44.4<1>:ud   r44.6<1;1,0>:ud                 
        goto.b (16|M0)                       L2664                  L1528                
L2664:
        join (16|M0)                         L2680                                
L2680:
        shl (1|M0)               r45.2<1>:d    r45.2<0;1,0>:d    6:w              
        shl (1|M0)               r1.2<1>:d     r45.6<0;1,0>:d    4:w              
        shl (1|M0)               r45.3<1>:d    r98.0<0;1,0>:d    7:w               {Compacted}
        or (1|M0)                r2.0<1>:d     r45.2<0;1,0>:d    r1.2<0;1,0>:d    {I@2}
        shl (1|M0)               r45.4<1>:ud   r45.4<0;1,0>:ud   0x4:uw             
        shl (1|M0)               r5.2<1>:d     r2.0<0;1,0>:d     2:w               {Compacted,I@2}
        shr (1|M0)               r2.3<1>:ud    r2.0<0;1,0>:ud    0x1E:uw             
        addc (1|M0)              r6.0<1>:ud    r3.2<0;1,0>:ud    r5.2<0;1,0>:ud   {AccWrEn,I@2}
        or (1|M0)                r5.3<1>:d     r2.3<0;1,0>:d     0:w               {Compacted,I@2}
        sync.nop                             null                             {Compacted,$6.src}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$2.src}
        sync.nop                             null                             {Compacted,$8.src}
        mov (1|M0)               r8.0<1>:f     r6.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r8.1<1>:d     r7.0<0;0>:d       r3.3<0;0>:d       r5.3<0>:d        {I@1}
        add (1|M0)               r45.7<1>:d    r3.6<0;1,0>:d     -1:w              
        send.ugm (1|M0)          r79      r8      null:0  0x0            0x0220C780           {A@1,$0} // wr:1+0, rd:2; load.ugm.d64x8t.a64
        mov (1|M0)               r46.2<1>:d    0:w                              
        shl (1|M0)               r45.6<1>:d    r45.6<0;1,0>:d    6:w              
        add (1|M0)               r45.5<1>:d    r45.3<0;1,0>:d    r45.4<0;1,0>:d  
L2928:
        or (1|M0)                r1.2<1>:d     r46.2<0;1,0>:d    r45.5<0;1,0>:d   {I@1}
        bfn.0xFE (1|M0)          r1.3<1>:ud    0x8:uw               r46.2<0;0>:ud     r45.5<0>:ud      // s0|s1|s2
        sel (1|M0)    (lt)f0.0   r2.0<1>:d     r1.2<0;1,0>:d     r45.7<0;1,0>:d   {I@2}
        sel (1|M0)    (lt)f0.0   r1.4<1>:d     r1.2<0;1,0>:d     r45.7<0;1,0>:d  
        sel (1|M0)    (lt)f0.0   r4.1<1>:d     r1.3<0;1,0>:d     r45.7<0;1,0>:d   {I@3}
        sync.nop                             null                             {Compacted,$1.src}
        sel (1|M0)    (lt)f0.0   r9.1<1>:d     r1.3<0;1,0>:d     r45.7<0;1,0>:d   {$3.src}
        shl (1|M0)               r5.2<1>:d     r2.0<0;1,0>:d     2:w               {Compacted,I@4}
        shr (1|M0)               r2.7<1>:ud    r2.0<0;1,0>:ud    0x1E:uw             
        asr (1|M0)               r2.1<1>:d     r1.4<0;1,0>:d     31:w               {I@5}
        asr (1|M0)               r9.2<1>:d     r4.1<0;1,0>:d     31:w               {I@5}
        sync.nop                             null                             {Compacted,$2.src}
        addc (1|M0)              r6.0<1>:ud    r3.4<0;1,0>:ud    r5.2<0;1,0>:ud   {AccWrEn,I@4}
        shl (1|M0)               r2.0<1>:d     r9.1<0;1,0>:d     2:w               {Compacted}
        shr (1|M0)               r9.4<1>:ud    r9.1<0;1,0>:ud    0x1E:uw             
        shl (1|M0)               r2.3<1>:d     r2.1<0;1,0>:d     2:w               {I@5}
        shl (1|M0)               r9.3<1>:d     r9.2<0;1,0>:d     2:w               {I@5}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r10.0<1>:ud   r3.4<0;1,0>:ud    r2.0<0;1,0>:ud   {AccWrEn,I@5}
        mov (1|M0)               r8.0<1>:f     r6.0<0;1,0>:f                    {Compacted,$0.src}
        or (1|M0)                r5.3<1>:d     r2.3<0;1,0>:d     r2.7<0;1,0>:d    {I@4}
        or (1|M0)                r2.1<1>:d     r9.3<0;1,0>:d     r9.4<0;1,0>:d    {I@4}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,F@1}
        sync.nop                             null                             {Compacted,$5.src}
        mov (1|M0)               r12.0<1>:f    r10.0<0;1,0>:f                   {Compacted,I@4}
        add3 (1|M0)              r8.1<1>:d     r7.0<0;0>:d       r3.5<0;0>:d       r5.3<0>:d        {I@3}
        add3 (1|M0)              r12.1<1>:d    r6.0<0;0>:d       r3.5<0;0>:d       r2.1<0>:d        {I@2}
        send.ugm (1|M0)          r9       r8      null:0  0x0            0x04100580           {A@2,$4} // wr:2+0, rd:1; load.ugm.d32.a64
        send.ugm (1|M0)          r7       r12     null:0  0x0            0x04100580           {A@1,$5} // wr:2+0, rd:1; load.ugm.d32.a64
        shl (1|M0)               r1.3<1>:w     r46.4<0;1,0>:w    5:w              
        or (1|M0)                r2.0<1>:d     r46.2<0;1,0>:d    r45.4<0;1,0>:d  
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0x8E0:uw              {A@1}
        add (1|M0)               r46.2<1>:d    r46.2<0;1,0>:d    1:w              
        shl (1|M0)               r2.0<1>:d     r2.0<0;1,0>:d     8:w               {Compacted,I@3}
        cmp (1|M0)    (eq)f1.1   null<1>:d     r46.2<0;1,0>:d    8:w               {I@2}
        sync.nop                             null                             {Compacted,$4.src}
        mov (8|M0)               r8.0<1>:ud    r[a0.0]<1;1,0>:ud                {$6.dst}
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0x7E0:uw              {A@1}
        mov (8|M0)               r11.0<1>:f    r8.0<1;1,0>:d                    {Compacted,I@2}
(W)     and (1|M0)               f0.0<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
        mov (8|M0)               r15.0<1>:ud   r[a0.0]<1;1,0>:ud               
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0x6E0:uw              {A@1}
        mov (8|M0)               r16.0<1>:f    r15.0<1;1,0>:d                   {Compacted,I@2}
        mov (8|M0)               r6.0<1>:ud    r[a0.0]<1;1,0>:ud               
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0x5E0:uw              {A@1}
        mov (8|M0)               r10.0<1>:f    r6.0<1;1,0>:d                    {Compacted,I@2}
        bfn.0xFE (1|M0)          r6.0<1>:ud    0x800:uw               r2.0<0;0>:ud      r45.6<0>:ud      {F@1} // s0|s1|s2
        mov (8|M0)               r12.0<1>:ud   r[a0.0]<1;1,0>:ud                {$5.src}
        mov (8|M0)               r8.0<1>:f     r12.0<1;1,0>:d                   {Compacted,A@1}
        mul (8|M0)               r13.0<1>:f    r9.0<0;1,0>:f     r11.0<1;1,0>:f   {Compacted,$4.dst}
        mul (8|M0)               r14.0<1>:f    r9.0<0;1,0>:f     r16.0<1;1,0>:f   {Compacted}
        mul (8|M0)               r17.0<1>:f    r7.0<0;1,0>:f     r10.0<1;1,0>:f   {Compacted,$5.dst}
        mul (8|M0)               r18.0<1>:f    r7.0<0;1,0>:f     r8.0<1;1,0>:f    {Compacted,F@4}
        or (1|M0)                r9.0<1>:d     r2.0<0;1,0>:d     r45.6<0;1,0>:d   {Compacted,F@3}
        mul (16|M0)              r13.0<1>:f    r13.0<1;1,0>:f    r79.0<1;1,0>:f   {Compacted,$0.dst}
        mul (16|M0)              r17.0<1>:f    r17.0<1;1,0>:f    r79.0<1;1,0>:f   {Compacted,F@2}
        send.slm (1|M0)          null     r9      r13:2   0x0            0x0200C704           {A@1,$1} // wr:1+2, rd:0; store.slm.d64x8t.a32
        send.slm (1|M0)          null     r6      r17:2   0x0            0x0200C704           {A@1,$2} // wr:1+2, rd:0; store.slm.d64x8t.a32
(~f0.0.any16h) goto.b (16|M0)                L3696                  L2928                
L3696:
        join (16|M0)                         L3712                                
L3712:
        sync.nop                             null                             {Compacted,$2.src}
(W)     send.slm (1|M0)          r6       r0      null:0  0x0            0x0210001F           {$8} // wr:1+0, rd:1; fence.slm.none.group
(W)     mov (1|M0)               r7.2<1>:f     0.0:f                               {Compacted}
(W)     mov (2|M0)               r7.10<1>:ub   r0.11<0;1,0>:ub                  {F@1}
(W)     mov (8|M0)               null<1>:ud    r6.0<1;1,0>:ud                   {$8.dst}
(W)     send.gtwy (1|M0)         null     r7      null:0  0x0            0x02000004           {A@2,$9} // wr:1+0, rd:0; signal barrier
(W)     sync.bar                             null                            
        mov (1|M0)               r98.4<1>:d    r45.2<0;1,0>:d                  
        mov (1|M0)               r98.5<1>:d    r2.6<0;1,0>:d                   
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r98.6         L9384                                 {A@1}
L3888:
(W)     mul (1|M0)               acc0.0<1>:d   r98.0<0;1,0>:d    r2.12<0;1,0>:uw  {Compacted}
        mach (1|M0)              r2.0<1>:d     r98.0<0;1,0>:d    r2.6<0;1,0>:d    {Compacted}
        and (1|M0)               r1.2<1>:d     r1.0<0;1,0>:uw    1:w              
        add (1|M0)               r45.2<1>:d    r45.2<0;1,0>:d    -r2.0<0;1,0>:d   {I@2}
        mov (1|M0)               r46.5<1>:d    0:w                              
        shr (1|M0)               r45.2<1>:ud   r45.2<0;1,0>:ud   0x5:uw              {I@2}
        cmp (1|M0)    (eq)f0.0   null<1>:d     r98.0<0;1,0>:d    0:w              
        add (1|M0)               r46.4<1>:d    r45.2<0;1,0>:d    r1.2<0;1,0>:d    {I@2}
        shl (1|M0)               r2.0<1>:d     r46.5<0;1,0>:d    2:w               {Compacted}
        shl (1|M0)               r5.2<1>:d     r46.4<0;1,0>:d    2:w               {I@2}
        shr (1|M0)               r2.1<1>:ud    r46.4<0;1,0>:ud   0x1E:uw             
        addc (1|M0)              r6.0<1>:ud    r5.0<0;1,0>:ud    r5.2<0;1,0>:ud   {AccWrEn,I@2}
        or (1|M0)                r5.3<1>:d     r2.0<0;1,0>:d     r2.1<0;1,0>:d    {I@2}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r46.6<1>:d    r4.0<0;1,0>:d                   
        asr (1|M0)               r46.7<1>:d    r4.0<0;1,0>:d     31:w               {Compacted}
        mov (1|M0)               r81.0<1>:d    r3.7<0;1,0>:d                   
        asr (1|M0)               r81.1<1>:d    r3.7<0;1,0>:d     31:w              
        mov (1|M0)               r81.2<1>:d    0:w                              
        shl (1|M0)               r46.3<1>:d    r1.2<0;1,0>:d     7:w              
(f0.0)  mov (1|M0)               r4.6<1>:d     r4.4<0;1,0>:d                   
(f0.0)  mov (1|M0)               r4.7<1>:d     r4.5<0;1,0>:d                   
        mov (1|M0)               r82.0<1>:f    r6.0<0;1,0>:f                    {Compacted,I@7}
        add3 (1|M0)              r82.1<1>:d    r7.0<0;0>:d       r5.1<0;0>:d       r5.3<0>:d        {I@7}
L4224:
        shl (1|M0)               r81.3<1>:d    r81.2<0;1,0>:d    5:w               {I@5}
        add (1|M0)               r81.3<1>:d    r81.3<0;1,0>:d    r1.0<0;1,0>:uw   {I@1}
        shr (1|M0)               r81.3<1>:ud   r81.3<0;1,0>:ud   0x1:uw              {I@1}
        add (1|M0)               r81.4<1>:d    r81.3<0;1,0>:d    r45.3<0;1,0>:d   {I@1}
        cmp (1|M0)    (lt)f1.0   null<1>:d     r81.4<0;1,0>:d    r3.6<0;1,0>:d    {I@1}
(W)     and (1|M0)               f1.1<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
(~f1.1.any16h) goto (16|M0)                  L9232                  L9232                
L4336:
        shl (1|M0)               r81.3<1>:d    r81.3<0;1,0>:d    8:w               {Compacted}
        mov (1|M0)               r81.6<2>:f    0.0:f                              
        or (1|M0)                r2.0<1>:d     r81.3<0;1,0>:d    r46.3<0;1,0>:d   {I@1}
        mov (1|M0)               r81.7<2>:f    0.0:f                              
        sync.nop                             null                             {Compacted,I@1}
        send.slm (1|M0)          r91      r2      null:0  0x0            0x0240D700           {$12} // wr:1+0, rd:4; load.slm.d64x16t.a32
        mov (1|M0)               r81.5<1>:d    0:w                              
L4432:
        addc (1|M0)              r6.0<1>:ud    r81.6<0;1,0>:ud   0x1:ud              {AccWrEn,F@2}
        shl (1|M0)               r1.3<1>:w     r81.10<0;1,0>:w   2:w               {I@2}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r82.2<1>:d    r6.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r82.3<1>:d    r7.0<0;0>:d       r81.7<0;0>:d      0:w               {A@1}
        add (1|M0)               a0.1<1>:uw    r1.3<0;1,0>:uw    0xB60:uw              {A@1}
        cmp (1|M0)    (eq)f1.1   null<1>:d     r82.3<0;1,0>:d    0:w               {I@2}
        shl (1|M0)               r2.0<1>:w     r81.12<0;1,0>:w   2:w               {$12.src}
        add (1|M0)               r81.5<1>:d    r81.5<0;1,0>:d    1:w              
        add (1|M0)               a0.0<1>:uw    r2.0<0;1,0>:uw    0xAE0:uw              {A@1}
(f1.1)  cmp (1|M0)    (eq)f1.1   null<1>:d     r82.2<0;1,0>:d    32:w              
        mov (1|M0)               r[a0.0]<1>:f  r[a0.1]<0;1,0>:f                 {$12.dst}
(W)     and (1|M0)               f1.0<1>:uw    f1.1<0;1,0>:uw    0x1:uw              {A@1}
(f1.0.any16h) goto (16|M0)                   L4680                  L4680                
L4648:
(W)     mov (2|M0)               r81.6<1>:ud   r82.2<1;1,0>:ud                 
        goto.b (16|M0)                       L4680                  L4432                
L4680:
        join (16|M0)                         L9232                                
L4696:
        mov (1|M0)               r99.5<1>:d    r81.4<0;1,0>:d                  
        mov (1|M0)               r98.1<1>:d    r3.7<0;1,0>:d                   
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r99.2         L9960                                 {A@1}
L4776:
        mov (1|M0)               r1.2<1>:f     r98.2<0;1,0>:f                  
(W)     mul (1|M0)               acc0.0<1>:d   r98.2<0;1,0>:d    r3.14<0;1,0>:uw 
        mach (1|M0)              r2.0<1>:d     r98.2<0;1,0>:d    r3.7<0;1,0>:d   
        mul (1|M0)               acc0.0<1>:ud  r1.2<0;1,0>:ud    r46.12<0;1,0>:uw {F@1}
        mach (1|M0)              r7.0<1>:ud    r1.2<0;1,0>:ud    r46.6<0;1,0>:ud  {AccWrEn}
        add (1|M0)               r1.4<1>:d     r81.4<0;1,0>:d    -r2.0<0;1,0>:d   {I@3}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r1.2<0;1,0>:d     r46.14<0;1,0>:uw
        mach (1|M0)              r8.0<1>:d     r1.2<0;1,0>:d     r46.7<0;1,0>:d  
        addc (1|M0)              r9.0<1>:ud    r6.0<0;1,0>:ud    r46.4<0;1,0>:ud  {AccWrEn,I@3}
        add3 (1|M0)              r5.3<1>:d     0:w                r7.0<0;0>:d       r8.0<0>:d        {I@2}
        mov (1|M0)               r5.4<1>:d     r9.0<0;1,0>:d                    {I@2}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mul (1|M0)               acc0.0<1>:ud  r5.4<0;1,0>:ud    r81.0<0;1,0>:uw  {I@2}
        mach (1|M0)              r12.0<1>:ud   r5.4<0;1,0>:ud    r81.0<0;1,0>:ud  {AccWrEn}
        add3 (1|M0)              r5.5<1>:d     r10.0<0;0>:d      r5.3<0;0>:d       r46.5<0>:d       {I@3}
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r5.4<0;1,0>:d     r81.2<0;1,0>:uw 
        mach (1|M0)              r13.0<1>:d    r5.4<0;1,0>:d     r81.1<0;1,0>:d  
(W)     mul (1|M0)               acc0.0<1>:d   r5.5<0;1,0>:d     r81.0<0;1,0>:uw  {Compacted,I@4}
        cmp (1|M0)    (eq)f0.1   null<1>:d     r98.0<0;1,0>:d    2:w              
        mach (1|M0)              r14.0<1>:d    r5.5<0;1,0>:d     r81.0<0;1,0>:d   {Compacted}
        addc (1|M0)              r6.0<1>:ud    r11.0<0;1,0>:ud   r1.4<0;1,0>:ud   {AccWrEn,I@6}
        add3 (1|M0)              r1.3<1>:d     r14.0<0;0>:d      r12.0<0;0>:d      r13.0<0>:d       {I@2}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
(W)     and (1|M0)               f0.1<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
        add3 (1|M0)              r6.2<1>:d     r7.0<0;0>:d       r1.3<0;0>:d       0:w               {I@2}
        shr (1|M0)               r8.0<1>:ud    r6.0<0;1,0>:ud    0x1B:uw             
        shl (1|M0)               r4.1<1>:d     r6.2<0;1,0>:d     5:w               {I@2}
        shl (1|M0)               r82.4<1>:d    r6.0<0;1,0>:d     5:w               {Compacted}
        or (1|M0)                r82.5<1>:d    r4.1<0;1,0>:d     r8.0<0;1,0>:d    {I@2}
(f0.1.any16h) goto (16|M0)                   L8256                  L8256                
L5232:
        mov (1|M0)               r82.6<2>:f    0.0:f                              
        mov (1|M0)               r82.7<2>:d    0:d                              
L5264:
        addc (1|M0)              r2.0<1>:ud    r82.6<0;1,0>:ud   0x1:ud              {AccWrEn,F@1}
        shl (1|M0)               r1.3<1>:w     r82.12<0;1,0>:w   2:w              
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r95.0<1>:f    r2.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r95.1<1>:d    r6.0<0;0>:d       r82.7<0;0>:d      0:w               {I@1}
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0xAE0:uw              {A@1}
        cmp (1|M0)    (eq)f1.0   null<1>:d     r95.1<0;1,0>:d    0:w               {I@2}
        mov (1|M0)               r1.4<2>:hf    r[a0.0]<0;1,0>:f                
(f1.0)  cmp (1|M0)    (eq)f1.0   null<1>:d     r95.0<0;1,0>:d    32:w               {A@1}
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0xA60:uw              {A@1}
        mov (1|M0)               r[a0.0]<1>:f  r1.4<0;1,0>:hf                   {F@1}
(W)     and (1|M0)               f1.1<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
(f1.1.any16h) goto (16|M0)                   L5488                  L5488                
L5456:
(W)     mov (2|M0)               r82.6<1>:ud   r95.0<1;1,0>:ud                 
        goto.b (16|M0)                       L5488                  L5264                
L5488:
        join (16|M0)                         L8256                                
L5504:
        mul (1|M0)               r1.2<1>:f     r83.0<0;1,0>:f    r83.0<0;1,0>:f   {Compacted,F@1}
        mul (1|M0)               r5.3<1>:f     r85.0<0;1,0>:f    r85.0<0;1,0>:f   {Compacted}
        mov (1|M0)               r2.0<2>:hf    r1.2<0;1,0>:f                    {F@2}
        mul (1|M0)               r9.0<1>:f     r83.1<0;1,0>:f    r83.1<0;1,0>:f  
        mov (1|M0)               r4.1<1>:f     r2.0<0;1,0>:hf                   {F@2}
        mul (1|M0)               r2.1<1>:f     r85.1<0;1,0>:f    r85.1<0;1,0>:f  
        mov (1|M0)               r6.0<2>:hf    r5.3<0;1,0>:f                   
        mov (1|M0)               r10.0<2>:hf   r9.0<0;1,0>:f                    {F@4}
        mad (1|M0)               r4.1<1>:f     r4.1<0;0>:f       r84.0<0;0>:f      r84.0<0>:f       {F@4}
        mov (1|M0)               r7.0<1>:f     r6.0<0;1,0>:hf                   {F@3}
        mov (1|M0)               r1.2<1>:f     r10.0<0;1,0>:hf                  {F@3}
        mov (1|M0)               r5.4<2>:hf    r4.1<0;1,0>:f                    {F@3}
        mov (1|M0)               r4.2<2>:hf    r2.1<0;1,0>:f                   
        mad (1|M0)               r7.0<1>:f     r7.0<0;0>:f       r86.0<0;0>:f      r86.0<0>:f       {F@4}
        mad (1|M0)               r1.2<1>:f     r1.2<0;0>:f       r84.1<0;0>:f      r84.1<0>:f       {F@4}
        mov (1|M0)               r5.3<1>:f     r4.2<0;1,0>:hf                   {F@3}
        mov (1|M0)               r8.0<2>:hf    r7.0<0;1,0>:f                    {F@3}
        mov (1|M0)               r2.0<2>:hf    r1.2<0;1,0>:f                    {F@3}
        mad (1|M0)               r5.3<1>:f     r5.3<0;0>:f       r86.1<0;0>:f      r86.1<0>:f       {F@3}
        mul (1|M0)               r7.0<1>:f     r83.2<0;1,0>:f    r83.2<0;1,0>:f  
        mul (1|M0)               r1.2<1>:f     r85.2<0;1,0>:f    r85.2<0;1,0>:f  
        add (1|M0)               r5.4<1>:hf    r5.4<0;1,0>:hf    r8.0<0;1,0>:hf   {F@5}
        mov (1|M0)               r6.0<2>:hf    r5.3<0;1,0>:f                    {F@4}
        mov (1|M0)               r8.0<2>:hf    r7.0<0;1,0>:f                    {F@4}
        mov (1|M0)               r10.2<2>:hf   r1.2<0;1,0>:f                    {F@4}
        mul (1|M0)               r5.3<1>:f     r83.3<0;1,0>:f    r83.3<0;1,0>:f  
        add (1|M0)               r2.0<1>:hf    r2.0<0;1,0>:hf    r6.0<0;1,0>:hf   {F@4}
        mov (1|M0)               r9.0<1>:f     r8.0<0;1,0>:hf                   {F@4}
        mov (1|M0)               r2.1<1>:f     r10.2<0;1,0>:hf                  {F@4}
        mov (1|M0)               r6.0<2>:hf    r5.3<0;1,0>:f                    {F@4}
        mad (1|M0)               r9.0<1>:f     r9.0<0;0>:f       r84.2<0;0>:f      r84.2<0>:f       {F@3}
        mad (1|M0)               r2.1<1>:f     r2.1<0;0>:f       r86.2<0;0>:f      r86.2<0>:f       {F@3}
        mov (1|M0)               r7.0<1>:f     r6.0<0;1,0>:hf                   {F@3}
        mul (1|M0)               r8.1<1>:f     r85.3<0;1,0>:f    r85.3<0;1,0>:f  
        mul (1|M0)               r6.1<1>:f     r85.4<0;1,0>:f    r85.4<0;1,0>:f  
        mov (1|M0)               r10.0<2>:hf   r9.0<0;1,0>:f                    {F@5}
        mov (1|M0)               r4.2<2>:hf    r2.1<0;1,0>:f                    {F@5}
        mad (1|M0)               r7.0<1>:f     r7.0<0;0>:f       r84.3<0;0>:f      r84.3<0>:f       {F@5}
        mul (1|M0)               r2.1<1>:f     r83.4<0;1,0>:f    r83.4<0;1,0>:f  
        mov (1|M0)               r9.0<2>:hf    r8.1<0;1,0>:f                    {F@6}
        add (1|M0)               r10.0<1>:hf   r10.0<0;1,0>:hf   r4.2<0;1,0>:hf   {F@4}
        mov (1|M0)               r8.0<2>:hf    r7.0<0;1,0>:f                    {F@4}
        mov (1|M0)               r4.2<2>:hf    r2.1<0;1,0>:f                    {F@4}
        mov (1|M0)               r7.0<2>:hf    r6.1<0;1,0>:f                   
        mov (1|M0)               r1.2<1>:f     r9.0<0;1,0>:hf                   {F@5}
        mov (1|M0)               r5.3<1>:f     r4.2<0;1,0>:hf                   {F@3}
        mov (1|M0)               r8.1<1>:f     r7.0<0;1,0>:hf                   {F@3}
        mad (1|M0)               r1.2<1>:f     r1.2<0;0>:f       r86.3<0;0>:f      r86.3<0>:f       {F@3}
        mad (1|M0)               r5.3<1>:f     r5.3<0;0>:f       r84.4<0;0>:f      r84.4<0>:f       {F@3}
        mad (1|M0)               r8.1<1>:f     r8.1<0;0>:f       r86.4<0;0>:f      r86.4<0>:f       {F@3}
        mov (1|M0)               r10.2<2>:hf   r1.2<0;1,0>:f                    {F@3}
        mov (1|M0)               r6.0<2>:hf    r5.3<0;1,0>:f                    {F@3}
        mov (1|M0)               r9.0<2>:hf    r8.1<0;1,0>:f                    {F@3}
        mul (1|M0)               r1.2<1>:f     r83.5<0;1,0>:f    r83.5<0;1,0>:f  
        mul (1|M0)               r5.3<1>:f     r85.5<0;1,0>:f    r85.5<0;1,0>:f  
        mul (1|M0)               r8.1<1>:f     r83.6<0;1,0>:f    r83.6<0;1,0>:f  
        add (1|M0)               r8.0<1>:hf    r8.0<0;1,0>:hf    r10.2<0;1,0>:hf  {F@6}
        add (1|M0)               r6.0<1>:hf    r6.0<0;1,0>:hf    r9.0<0;1,0>:hf   {F@5}
        mov (1|M0)               r11.0<2>:hf   r5.3<0;1,0>:f                    {F@4}
        mov (1|M0)               r10.2<2>:hf   r1.2<0;1,0>:f                   
        mov (1|M0)               r9.0<2>:hf    r8.1<0;1,0>:f                    {F@5}
        mov (1|M0)               r6.1<1>:f     r11.0<0;1,0>:hf                  {F@3}
        mov (1|M0)               r2.1<1>:f     r10.2<0;1,0>:hf                  {F@3}
        mov (1|M0)               r1.2<1>:f     r9.0<0;1,0>:hf                   {F@3}
        mad (1|M0)               r6.1<1>:f     r6.1<0;0>:f       r86.5<0;0>:f      r86.5<0>:f       {F@3}
        mad (1|M0)               r2.1<1>:f     r2.1<0;0>:f       r84.5<0;0>:f      r84.5<0>:f       {F@3}
        mad (1|M0)               r1.2<1>:f     r1.2<0;0>:f       r84.6<0;0>:f      r84.6<0>:f       {F@3}
        mov (1|M0)               r7.0<2>:hf    r6.1<0;1,0>:f                    {F@3}
        mov (1|M0)               r4.2<2>:hf    r2.1<0;1,0>:f                    {F@3}
        mov (1|M0)               r10.2<2>:hf   r1.2<0;1,0>:f                    {F@3}
        mul (1|M0)               r6.1<1>:f     r83.7<0;1,0>:f    r83.7<0;1,0>:f  
        mul (1|M0)               r2.1<1>:f     r85.6<0;1,0>:f    r85.6<0;1,0>:f  
        mul (1|M0)               r1.2<1>:f     r85.7<0;1,0>:f    r85.7<0;1,0>:f  
        add (1|M0)               r4.2<1>:hf    r4.2<0;1,0>:hf    r7.0<0;1,0>:hf   {F@5}
        mov (1|M0)               r10.4<2>:hf   r2.1<0;1,0>:f                    {F@3}
        mov (1|M0)               r7.0<2>:hf    r6.1<0;1,0>:f                   
        mov (1|M0)               r9.2<2>:hf    r1.2<0;1,0>:f                    {F@4}
        mov (1|M0)               r5.3<1>:f     r10.4<0;1,0>:hf                  {F@3}
        mov (1|M0)               r8.1<1>:f     r7.0<0;1,0>:hf                   {F@3}
        mov (1|M0)               r2.1<1>:f     r9.2<0;1,0>:hf                   {F@3}
        mad (1|M0)               r5.3<1>:f     r5.3<0;0>:f       r86.6<0;0>:f      r86.6<0>:f       {F@3}
        mad (1|M0)               r8.1<1>:f     r8.1<0;0>:f       r84.7<0;0>:f      r84.7<0>:f       {F@3}
        mad (1|M0)               r2.1<1>:f     r2.1<0;0>:f       r86.7<0;0>:f      r86.7<0>:f       {F@3}
        mov (1|M0)               r11.0<2>:hf   r5.3<0;1,0>:f                    {F@3}
        mov (1|M0)               r9.0<2>:hf    r8.1<0;1,0>:f                    {F@3}
        mov (1|M0)               r10.4<2>:hf   r2.1<0;1,0>:f                    {F@3}
        add (1|M0)               r10.2<1>:hf   r10.2<0;1,0>:hf   r11.0<0;1,0>:hf  {F@3}
        add (1|M0)               r9.0<1>:hf    r9.0<0;1,0>:hf    r10.4<0;1,0>:hf  {F@2}
        add (1|M0)               r5.4<1>:hf    r5.4<0;1,0>:hf    r6.0<0;1,0>:hf  
        add (1|M0)               r2.0<1>:hf    r2.0<0;1,0>:hf    r4.2<0;1,0>:hf  
        add (1|M0)               r10.0<1>:hf   r10.0<0;1,0>:hf   r10.2<0;1,0>:hf  {F@4}
        add (1|M0)               r8.0<1>:hf    r8.0<0;1,0>:hf    r9.0<0;1,0>:hf   {F@4}
        add (1|M0)               r5.4<1>:hf    r5.4<0;1,0>:hf    r10.0<0;1,0>:hf  {F@2}
        add (1|M0)               r2.0<1>:hf    r2.0<0;1,0>:hf    r8.0<0;1,0>:hf   {F@2}
(W)     and (1|M0)               f1.0<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
        add (1|M0)               r5.4<1>:hf    r5.4<0;1,0>:hf    r2.0<0;1,0>:hf   {F@1}
        mov (1|M0)               r1.2<1>:f     r5.4<0;1,0>:hf                   {F@1}
        sel (1|M0)    (ge)f0.0   r1.2<1>:f     r1.2<0;1,0>:f     6.198883e-05:f               {F@1}
        math.sqt (1|M0)          r1.2<1>:f     r1.2<0;1,0>:f                    {@1,$13}
        math.inv (1|M0)          r1.2<1>:f     r1.2<0;1,0>:f                    {$13}
        mov (1|M0)               r7.0<2>:hf    r1.2<0;1,0>:f                    {$13.dst}
        mov (1|M0)               r95.2<1>:f    r7.0<0;1,0>:hf                   {F@1}
(f1.0.any16h) goto (16|M0)                   L7160                  L7160                
L7136:
        mov (1|M0)               r95.3<1>:f    1.0:f                               {Compacted}
        goto (16|M0)                         L7160                  L7232                
L7160:
        join (16|M0)                         L7232                                
L7176:
        sync.nop                             null                             {Compacted,I@7}
        send.ugm (1|M0)          r2       r82     null:0  0x0            0x04100580           {$14} // wr:2+0, rd:1; load.ugm.d32.a64
        mov (1|M0)               r1.4<2>:hf    r2.0<0;1,0>:f                    {$14.dst}
        mov (1|M0)               r95.3<1>:f    r1.4<0;1,0>:hf                   {F@1}
L7232:
        join (16|M0)                         L8256                                
L7248:
        shl (1|M0)               r1.4<1>:d     r82.4<0;1,0>:d    1:w              
        shl (1|M0)               r1.2<1>:d     r82.5<0;1,0>:d    1:w               {F@1}
        shr (1|M0)               r1.3<1>:ud    r82.4<0;1,0>:ud   0x1F:uw             
        addc (1|M0)              r2.0<1>:ud    r4.6<0;1,0>:ud    r1.4<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r95.6<2>:f    0.0:f                              
        mov (1|M0)               r95.7<2>:f    0.0:f                              
        mov (1|M0)               r95.4<1>:d    r2.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r95.5<1>:d    r6.0<0;0>:d       r4.7<0;0>:d       r1.5<0>:d        {I@2}
L7400:
        shl (1|M0)               r1.3<1>:w     r95.12<0;1,0>:w   2:w               {F@2}
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0xA60:uw              {A@1}
        mul (1|M0)               r2.0<1>:f     r[a0.0]<0;1,0>:f  r95.2<0;1,0>:f  
        mov (1|M0)               r4.2<2>:hf    r2.0<0;1,0>:f                    {A@1}
        mov (1|M0)               r5.2<1>:f     r4.2<0;1,0>:hf                   {F@1}
        mul (1|M0)               r5.3<1>:f     r95.3<0;1,0>:f    r5.2<0;1,0>:f    {F@1}
        mov (1|M0)               r6.0<2>:hf    r5.3<0;1,0>:f                    {F@1}
        mov (1|M0)               r96.1<1>:f    r6.0<0;1,0>:hf                   {F@1}
(~f0.0) mov (1|M0)               r96.1<1>:f    r5.2<0;1,0>:f                   
        cmp (1|M0)    (lt)f1.0   null<1>:f     r96.1<0;1,0>:f    0.0:f               {F@1}
(f1.0)  mov (1|M0)               r96.1<1>:f    -r96.1<0;1,0>:f                 
        sel (1|M0)    (lt)f0.0   r96.1<1>:f    r96.1<0;1,0>:f    448.0:f               {F@1}
        shr (1|M0)               r96.2<1>:ud   r96.1<0;1,0>:ud   0x17:uw              {F@1}
        and (1|M0)               r96.2<1>:ud   r96.2<0;1,0>:ud   0xFF:uw              {I@1}
        sel (1|M0)    (ge)f0.0   r96.2<1>:ud   r96.2<0;1,0>:ud   0x79:uw              {I@1}
        shl (1|M0)               r96.2<1>:ud   r96.2<0;1,0>:ud   0x17:uw              {I@1}
        add (1|M0)               r1.2<1>:ud    -r96.2<0;1,0>:ud  0x80800000:ud              {I@1}
        mul (1|M0)               r1.3<1>:f     r96.1<0;1,0>:f    r1.2<0;1,0>:f    {I@1}
        mov (1|M0)               r96.0<1>:d    r1.3<0;1,0>:f                    {Compacted,F@1}
        mov (1|M0)               r96.3<1>:f    r96.0<0;1,0>:d                   {Compacted,I@1}
        mad (1|M0)               r96.1<1>:f    -r96.3<0;0>:f     r1.2<0;0>:f       r96.1<0>:f       {F@1}
        cmp (1|M0)    (gt)f1.1   null<1>:f     r96.1<0;1,0>:f    0.5:f               {F@1}
(W)     and (1|M0)               f0.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(f0.1.any16h) goto (16|M0)                   L7856                  L7856                
L7768:
        cmp (1|M0)    (lt)f1.1   null<1>:f     r96.1<0;1,0>:f    0.5:f               {I@2}
        and (1|M0)               r96.0<1>:d    r96.0<0;1,0>:d    1:w               {Compacted}
        add (1|M0)               r1.2<1>:f     r96.3<0;1,0>:f    1.0:f              
(~f1.1) cmp (1|M0)    (eq)f1.1   null<1>:d     r96.0<0;1,0>:d    0:w               {A@1}
(~f1.1) mov (1|M0)               r96.3<1>:f    r1.2<0;1,0>:f                    {F@1}
        goto (16|M0)                         L7856                  L7880                
L7856:
        join (16|M0)                         L7880                                
L7872:
        add (1|M0)               r96.3<1>:f    r96.3<0;1,0>:f    1.0:f               {Compacted,F@1}
L7880:
        join (16|M0)                         L8256                                
L7896:
        shl (1|M0)               r1.5<1>:d     r95.6<0;1,0>:d    1:w              
        add (1|M0)               r96.2<1>:ud   r96.2<0;1,0>:ud   0xFE800000:ud             
        addc (1|M0)              r2.0<1>:ud    r95.4<0;1,0>:ud   r1.5<0;1,0>:ud   {AccWrEn,I@2}
        mul (1|M0)               r96.3<1>:f    r96.3<0;1,0>:f    r96.2<0;1,0>:f   {A@1}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r7.0<1>:ud    r95.6<0;1,0>:ud   0x1:ud              {AccWrEn}
        shl (1|M0)               r1.3<1>:d     r95.7<0;1,0>:d    1:w              
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$11.src}
        mov (1|M0)               r96.4<1>:d    r7.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r96.5<1>:d    r9.0<0;0>:d       r95.7<0;0>:d      0:w               {I@2}
        shr (1|M0)               r1.4<1>:ud    r95.6<0;1,0>:ud   0x1F:uw             
        cmp (1|M0)    (eq)f0.1   null<1>:d     r96.5<0;1,0>:d    0:w               {I@2}
(f1.0)  mov (1|M0)               r96.3<1>:f    -r96.3<0;1,0>:f                  {F@1}
        or (1|M0)                r1.6<1>:d     r1.3<0;1,0>:d     r1.4<0;1,0>:d    {I@2}
        mov (1|M0)               r1.4<2>:hf    r96.3<0;1,0>:f                   {F@1}
(f0.1)  cmp (1|M0)    (eq)f0.1   null<1>:d     r96.4<0;1,0>:d    32:w              
        mov (1|M0)               r8.0<1>:f     r2.0<0;1,0>:f                    {Compacted}
        add3 (1|M0)              r8.1<1>:d     r6.0<0;0>:d       r95.5<0;0>:d      r1.6<0>:d        {I@2}
        mov (1|M0)               r10.0<1>:d    r1.4<0;1,0>:uw                   {F@2}
(W)     and (1|M0)               f1.1<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
        send.ugm (1|M0)          null     r8      r10:1   0x0            0x04000B84           {A@1,$11} // wr:2+1, rd:0; store.ugm.d16u32.a64
(f1.1.any16h) goto (16|M0)                   L8256                  L9232                
L8224:
(W)     mov (2|M0)               r95.6<1>:ud   r96.4<1;1,0>:ud                 
        goto.b (16|M0)                       L8256                  L7400                
L8256:
        join (16|M0)                         L9232                                
L8272:
        shl (1|M0)               r1.4<1>:d     r82.4<0;1,0>:d    1:w              
        shl (1|M0)               r1.2<1>:d     r82.5<0;1,0>:d    1:w              
        shr (1|M0)               r1.3<1>:ud    r82.4<0;1,0>:ud   0x1F:uw             
        addc (1|M0)              r2.0<1>:ud    r4.2<0;1,0>:ud    r1.4<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r97.0<2>:f    0.0:f                              
        mov (1|M0)               r97.1<2>:f    0.0:f                              
        mov (1|M0)               r96.6<1>:d    r2.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r96.7<1>:d    r6.0<0;0>:d       r4.3<0;0>:d       r1.5<0>:d        {I@2}
L8424:
        shl (1|M0)               r1.3<1>:w     r97.0<0;1,0>:w    2:w               {F@2}
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0xAE0:uw              {A@1}
        cmp (1|M0)    (lt)f0.1   null<1>:f     r[a0.0]<0;1,0>:f  0.0:f              
(W)     mov (1|M0)               r2.0<1>:f     -r[a0.0]<0;1,0>:f                {A@1}
(W)     mov (1|M0)               r2.1<1>:f     r[a0.0]<0;1,0>:f                 {A@1}
(f0.1)  sel (1|M0)               r97.3<1>:f    r2.0<0;1,0>:f     r2.1<0;1,0>:f    {A@1}
        sel (1|M0)    (lt)f0.0   r97.3<1>:f    r97.3<0;1,0>:f    448.0:f               {F@1}
        shr (1|M0)               r97.4<1>:ud   r97.3<0;1,0>:ud   0x17:uw              {F@1}
        and (1|M0)               r97.4<1>:ud   r97.4<0;1,0>:ud   0xFF:uw              {I@1}
        sel (1|M0)    (ge)f0.0   r97.4<1>:ud   r97.4<0;1,0>:ud   0x79:uw              {I@1}
        shl (1|M0)               r97.4<1>:ud   r97.4<0;1,0>:ud   0x17:uw              {I@1}
        add (1|M0)               r4.1<1>:ud    -r97.4<0;1,0>:ud  0x80800000:ud              {I@1}
        mul (1|M0)               r5.2<1>:f     r97.3<0;1,0>:f    r4.1<0;1,0>:f    {I@1}
        mov (1|M0)               r97.2<1>:d    r5.2<0;1,0>:f                    {F@1}
        mov (1|M0)               r97.5<1>:f    r97.2<0;1,0>:d                   {I@1}
        mad (1|M0)               r97.3<1>:f    -r97.5<0;0>:f     r4.1<0;0>:f       r97.3<0>:f       {F@1}
        cmp (1|M0)    (gt)f1.0   null<1>:f     r97.3<0;1,0>:f    0.5:f               {F@1}
(W)     and (1|M0)               f1.0<1>:uw    f1.0<0;1,0>:uw    0x1:uw              {F@1}
(f1.0.any16h) goto (16|M0)                   L8824                  L8824                
L8728:
        cmp (1|M0)    (lt)f1.0   null<1>:f     r97.3<0;1,0>:f    0.5:f               {A@1}
        and (1|M0)               r97.2<1>:d    r97.2<0;1,0>:d    1:w              
        add (1|M0)               r1.2<1>:f     r97.5<0;1,0>:f    1.0:f              
(~f1.0) cmp (1|M0)    (eq)f1.0   null<1>:d     r97.2<0;1,0>:d    0:w               {A@1}
(~f1.0) mov (1|M0)               r97.5<1>:f    r1.2<0;1,0>:f                    {F@1}
        goto (16|M0)                         L8824                  L8856                
L8824:
        join (16|M0)                         L8856                                
L8840:
        add (1|M0)               r97.5<1>:f    r97.5<0;1,0>:f    1.0:f               {F@1}
L8856:
        join (16|M0)                         L9232                                
L8872:
        shl (1|M0)               r1.5<1>:d     r97.0<0;1,0>:d    1:w               {Compacted}
        add (1|M0)               r97.4<1>:ud   r97.4<0;1,0>:ud   0xFE800000:ud             
        addc (1|M0)              r2.0<1>:ud    r96.6<0;1,0>:ud   r1.5<0;1,0>:ud   {AccWrEn,I@2}
        mul (1|M0)               r97.5<1>:f    r97.5<0;1,0>:f    r97.4<0;1,0>:f   {A@1}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r7.0<1>:ud    r97.0<0;1,0>:ud   0x1:ud              {AccWrEn}
        shl (1|M0)               r1.3<1>:d     r97.1<0;1,0>:d    1:w              
        sync.nop                             null                             {Compacted,$10.src}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$11.src}
        mov (1|M0)               r97.6<1>:d    r7.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r97.7<1>:d    r9.0<0;0>:d       r97.1<0;0>:d      0:w               {I@2}
        shr (1|M0)               r1.4<1>:ud    r97.0<0;1,0>:ud   0x1F:uw             
        cmp (1|M0)    (eq)f1.1   null<1>:d     r97.7<0;1,0>:d    0:w               {I@2}
(f0.1)  mov (1|M0)               r97.5<1>:f    -r97.5<0;1,0>:f                  {F@1}
        or (1|M0)                r1.6<1>:d     r1.3<0;1,0>:d     r1.4<0;1,0>:d    {I@2}
        mov (1|M0)               r1.4<2>:hf    r97.5<0;1,0>:f                   {F@1}
(f1.1)  cmp (1|M0)    (eq)f1.1   null<1>:d     r97.6<0;1,0>:d    32:w              
        mov (1|M0)               r8.0<1>:f     r2.0<0;1,0>:f                    {Compacted}
        add3 (1|M0)              r8.1<1>:d     r6.0<0;0>:d       r96.7<0;0>:d      r1.6<0>:d        {I@2}
        mov (1|M0)               r10.0<1>:d    r1.4<0;1,0>:uw                   {F@2}
(W)     and (1|M0)               f0.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
        send.ugm (1|M0)          null     r8      r10:1   0x0            0x04000B84           {A@1,$10} // wr:2+1, rd:0; store.ugm.d16u32.a64
(f0.1.any16h) goto (16|M0)                   L9232                  L9232                
L9200:
(W)     mov (2|M0)               r97.0<1>:ud   r97.6<1;1,0>:ud                 
        goto.b (16|M0)                       L9232                  L8424                
L9232:
        join (16|M0)                         L9312                                
L9248:
        add (1|M0)               r81.2<1>:d    r81.2<0;1,0>:d    1:w              
        cmp (1|M0)    (eq)f0.1   null<1>:d     r81.2<0;1,0>:d    8:w               {I@1}
(W)     and (1|M0)               f1.1<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(~f1.1.any16h) goto.b (16|M0)                L9312                  L4224                
L9312:
        join (16|M0)                         L9328                                
L9328:
(W)     mov (8|M0)               r127.0<1>:f   r0.0<1;1,0>:f                    {Compacted}
(W)     send.ugm (1|M0)          r6       r0      null:0  0x0            0x0210641F           {$15} // wr:1+0, rd:1; fence invalid flush type scoped to tile
(W)     mov (8|M0)               null<1>:ud    r6.0<1;1,0>:ud                   {$15.dst}
(W)     send.gtwy (1|M0)         null     r127    null:0  0x0            0x02000010           {EOT,A@1} // wr:1+0, rd:0; end of thread
L9384:
        mov (1|M0)               r1.2<1>:d     cr0.0<0;1,0>:ud                  {A@1}
        and (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   -1265:w               {A@1}
        or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   1264:w               {A@1}
        mov (1|M0)               r1.5<1>:f     (abs)r98.5<0;1,0>:d              {A@1}
        mov (1|M0)               r5.3<1>:f     0xB4C00000:f                               {Compacted}
        math.inv (1|M0)          r5.2<1>:f     r1.5<0;1,0>:f                    {@2,$0}
        mov (1|M0)               r2.1<1>:f     (abs)r98.4<0;1,0>:d             
        sync.nop                             null                             {Compacted,$0.dst}
        mad (1|M0)               r5.2<1>:f     r5.2<0;0>:f       r5.3<0;0>:f       r5.2<0>:f        {F@2}
        mov (1|M0)               r1.3<1>:d     (abs)r98.4<0;1,0>:d             
        mov (1|M0)               r1.4<1>:d     (abs)r98.5<0;1,0>:d             
        mov (1|M0)               r1.6<1>:ud    r1.5<0;1,0>:f                   
        mov (1|M0)               r2.3<1>:ud    r2.1<0;1,0>:f                    {F@2}
        mul (1|M0)               r6.0<1>:f     r5.2<0;1,0>:f     r2.1<0;1,0>:f    {A@1}
        add (1|M0)               r1.6<1>:ud    r1.4<0;1,0>:ud    -r1.6<0;1,0>:ud  {I@2}
        add (1|M0)               r2.3<1>:ud    r1.3<0;1,0>:ud    -r2.3<0;1,0>:ud  {I@2}
        mov (1|M0)               r7.0<1>:ud    r6.0<0;1,0>:f                    {F@1}
        mov (1|M0)               r2.0<1>:f     r1.6<0;1,0>:ud                   {Compacted,I@3}
        mov (1|M0)               r4.1<1>:f     r2.3<0;1,0>:ud                   {I@2}
        mov (1|M0)               r7.1<1>:f     r7.0<0;1,0>:ud                   {Compacted,I@1}
        xor (1|M0)               r98.5<1>:d    r98.5<0;1,0>:d    r98.4<0;1,0>:d  
        mad (1|M0)               r2.1<1>:f     r2.1<0;0>:f       r7.1<0;0>:f       -r1.5<0>:f       {F@1}
        mad (1|M0)               r7.1<1>:f     r4.1<0;0>:f       r7.1<0;0>:f       -r2.0<0>:f      
(W)     mov (1|M0)               r6.0<1>:hf    0x1:hf                             
        add (1|M0)               r2.1<1>:f     r2.1<0;1,0>:f     r7.1<0;1,0>:f    {F@2}
        asr (1|M0)               r98.5<1>:d    r98.5<0;1,0>:d    31:w               {I@1}
        mul (1|M0)               r5.2<1>:f     r5.2<0;1,0>:f     r2.1<0;1,0>:f    {F@1}
        mov (1|M0)               r8.0<1>:ud    r5.2<0;1,0>:f                    {F@1}
        add (1|M0)               r7.0<1>:ud    r7.0<0;1,0>:ud    r8.0<0;1,0>:ud   {Compacted,I@1}
(W)     mul (1|M0)               acc0.0<1>:ud  r7.0<0;1,0>:ud    r1.8<0;1,0>:uw   {I@1}
        mach (1|M0)              r9.0<1>:ud    r7.0<0;1,0>:ud    r1.4<0;1,0>:ud   {Compacted}
        add (1|M0)               r1.3<1>:ud    r1.3<0;1,0>:ud    -r9.0<0;1,0>:ud  {Compacted,I@1}
        cmp (1|M0)    (ge)f0.0   null<1>:ud    r1.3<0;1,0>:ud    r1.4<0;1,0>:ud   {I@1}
(f0.0)  sel (1|M0)               r4.1<1>:d     r6.0<0;1,0>:w     0:w              
        add3 (1|M0)              r7.0<1>:d     r7.0<0;0>:d       r98.5<0;0>:d      r4.1<0>:d        {I@1}
        xor (1|M0)               r98.0<1>:d    r7.0<0;1,0>:d     r98.5<0;1,0>:d   {Compacted,I@1}
        mov (1|M0)               cr0.0<1>:ud   r1.2<0;1,0>:d                    {A@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        ret (16|M0)                          r98.6                            {A@1}
L9960:
        mov (1|M0)               r1.2<1>:d     cr0.0<0;1,0>:ud                  {A@1}
        and (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   -1265:w               {A@1}
        or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   1264:w               {A@1}
        mov (1|M0)               r1.3<1>:f     r98.1<0;1,0>:ud                  {A@1}
        mov (1|M0)               r2.3<1>:f     0xB4C00000:f                               {Compacted}
        math.inv (1|M0)          r2.1<1>:f     r1.3<0;1,0>:f                    {@2,$1}
        mov (1|M0)               r1.5<1>:f     r99.5<0;1,0>:ud                 
        sync.nop                             null                             {Compacted,$1.dst}
        mad (1|M0)               r2.1<1>:f     r2.1<0;0>:f       r2.3<0;0>:f       r2.1<0>:f        {F@2}
        mov (1|M0)               r99.4<1>:ud   r1.3<0;1,0>:f                   
        mov (1|M0)               r1.6<1>:ud    r1.5<0;1,0>:f                    {F@2}
        mul (1|M0)               r4.1<1>:f     r2.1<0;1,0>:f     r1.5<0;1,0>:f    {F@1}
        add (1|M0)               r99.4<1>:ud   r98.1<0;1,0>:ud   -r99.4<0;1,0>:ud {I@2}
        add (1|M0)               r1.6<1>:ud    r99.5<0;1,0>:ud   -r1.6<0;1,0>:ud  {I@2}
        mov (1|M0)               r5.2<1>:ud    r4.1<0;1,0>:f                    {F@1}
        mov (1|M0)               r1.4<1>:f     r99.4<0;1,0>:ud                  {I@3}
        mov (1|M0)               r2.0<1>:f     r1.6<0;1,0>:ud                   {Compacted,I@2}
        mov (1|M0)               r5.3<1>:f     r5.2<0;1,0>:ud                   {I@1}
(W)     mov (1|M0)               r4.2<1>:hf    0x1:hf                             
        mad (1|M0)               r1.5<1>:f     r1.5<0;0>:f       r5.3<0;0>:f       -r1.3<0>:f       {F@2}
        mad (1|M0)               r5.3<1>:f     r2.0<0;0>:f       r5.3<0;0>:f       -r1.4<0>:f      
        add (1|M0)               r1.5<1>:f     r1.5<0;1,0>:f     r5.3<0;1,0>:f    {F@1}
        mul (1|M0)               r2.1<1>:f     r2.1<0;1,0>:f     r1.5<0;1,0>:f    {F@1}
        mov (1|M0)               r6.0<1>:ud    r2.1<0;1,0>:f                    {F@1}
        add (1|M0)               r5.2<1>:ud    r5.2<0;1,0>:ud    r6.0<0;1,0>:ud   {I@1}
(W)     mul (1|M0)               acc0.0<1>:ud  r5.2<0;1,0>:ud    r98.2<0;1,0>:uw  {I@1}
        mach (1|M0)              r7.0<1>:ud    r5.2<0;1,0>:ud    r98.1<0;1,0>:ud 
        add (1|M0)               r99.5<1>:ud   r99.5<0;1,0>:ud   -r7.0<0;1,0>:ud  {I@1}
        cmp (1|M0)    (ge)f0.1   null<1>:ud    r99.5<0;1,0>:ud   r98.1<0;1,0>:ud  {I@1}
(f0.1)  sel (1|M0)               r8.0<1>:d     r4.2<0;1,0>:w     0:w              
        add (1|M0)               r98.2<1>:ud   r5.2<0;1,0>:ud    r8.0<0;1,0>:ud   {I@1}
        mov (1|M0)               cr0.0<1>:ud   r1.2<0;1,0>:d                    {A@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        ret (16|M0)                          r99.2                            {A@1}
L10496:
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
