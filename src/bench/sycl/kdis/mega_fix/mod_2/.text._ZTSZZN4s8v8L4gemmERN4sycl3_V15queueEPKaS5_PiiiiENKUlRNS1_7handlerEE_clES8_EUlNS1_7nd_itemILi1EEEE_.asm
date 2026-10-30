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
        asr (1|M0)               r77.1<1>:d    r2.2<0;1,0>:d     31:w               {A@1}
        mov (1|M0)               r77.0<1>:d    r0.1<0;1,0>:ud                  
        shr (1|M0)               r77.1<1>:ud   r77.1<0;1,0>:ud   0x1A:uw              {I@2}
        mov (1|M0)               r41.0<1>:d    r1.0<0;1,0>:uw                   {$0.dst}
        add (1|M0)               r77.1<1>:d    r2.2<0;1,0>:d     r77.1<0;1,0>:d   {I@2}
        asr (1|M0)               r77.1<1>:d    r77.1<0;1,0>:d    6:w               {Compacted,I@1}
        mov (2|M0)               r44.4<1>:d    r77.0<1;1,0>:d                   {I@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r43.6         L6000                                 {A@1}
L376:
        asr (1|M0)               r41.5<1>:d    r2.6<0;1,0>:d     31:w              
(W)     mul (1|M0)               acc0.0<1>:d   r41.1<0;1,0>:d    r77.2<0;1,0>:uw 
        shr (1|M0)               r41.5<1>:ud   r41.5<0;1,0>:ud   0x1B:uw              {I@2}
(W)     mach (1|M0)              r2.0<1>:d     r41.1<0;1,0>:d    r77.1<0;1,0>:d  
        add (1|M0)               r41.5<1>:d    r2.6<0;1,0>:d     r41.5<0;1,0>:d   {I@2}
        mov (1|M0)               r77.1<1>:d    r2.0<0;1,0>:d                    {I@2}
        asr (1|M0)               r41.5<1>:d    r41.5<0;1,0>:d    5:w               {I@2}
        add (1|M0)               r3.6<1>:d     r77.0<0;1,0>:d    -r77.1<0;1,0>:d  {I@2}
(W)     mul (1|M0)               acc0.0<1>:d   r41.1<0;1,0>:d    r41.10<0;1,0>:uw {I@2}
        mach (1|M0)              r4.0<1>:d     r41.1<0;1,0>:d    r41.5<0;1,0>:d  
(W)     mul (1|M0)               acc0.0<1>:d   r41.1<0;1,0>:d    r41.10<0;1,0>:uw
        mach (1|M0)              r5.0<1>:d     r41.1<0;1,0>:d    r41.5<0;1,0>:d  
        shl (1|M0)               r7.0<1>:d     r3.6<0;1,0>:d     11:w               {Compacted,I@5}
        shl (1|M0)               r1.4<1>:d     r5.0<0;1,0>:d     12:w               {Compacted,I@2}
        asr (1|M0)               r5.1<1>:d     r4.0<0;1,0>:d     31:w               {Compacted}
        addc (1|M0)              r2.0<1>:ud    r2.4<0;1,0>:ud    r1.4<0;1,0>:ud   {AccWrEn,I@2}
        shr (1|M0)               r1.3<1>:ud    r5.0<0;1,0>:ud    0x14:uw             
        shl (1|M0)               r1.2<1>:d     r5.1<0;1,0>:d     12:w               {I@3}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        shl (1|M0)               r5.0<1>:ud    r41.0<0;1,0>:ud   0x7:uw             
        addc (1|M0)              r4.0<1>:ud    r3.0<0;1,0>:ud    r7.0<0;1,0>:ud   {AccWrEn}
        shr (1|M0)               r2.1<1>:ud    r3.6<0;1,0>:ud    0x15:uw             
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@5}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        shl (1|M0)               r1.2<1>:ud    r41.0<0;1,0>:ud   0x6:uw             
        addc (1|M0)              r9.0<1>:ud    r2.0<0;1,0>:ud    r5.0<0;1,0>:ud   {AccWrEn,I@6}
        or (1|M0)                r7.1<1>:d     r2.1<0;1,0>:d     0:w               {Compacted,I@5}
        add3 (1|M0)              r3.5<1>:d     r6.0<0;0>:d       r2.5<0;0>:d       r1.5<0>:d        {I@5}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r6.0<1>:ud    r4.0<0;1,0>:ud    r1.2<0;1,0>:ud   {AccWrEn,I@5}
        add3 (1|M0)              r4.2<1>:d     r8.0<0;0>:d       r3.1<0;0>:d       r7.1<0>:d        {I@4}
        mov (1|M0)               r15.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r43.0<1>:f    r9.0<0;1,0>:f                    {Compacted}
        add3 (1|M0)              r43.1<1>:d    r10.0<0;0>:d      r3.5<0;0>:d       0:w               {I@4}
        mov (1|M0)               r44.0<1>:f    r6.0<0;1,0>:f                    {Compacted,I@4}
        add3 (1|M0)              r44.1<1>:d    r15.0<0;0>:d      r4.2<0;0>:d       0:w               {I@2}
        send.ugm (1|M0)          r11      r43     null:0  0x0            0x0240D780           {A@2,$2} // wr:1+0, rd:4; load.ugm.d64x16t.a64
        send.ugm (1|M0)          r7       r44     null:0  0x0            0x0220C780           {A@1,$3} // wr:1+0, rd:2; load.ugm.d64x8t.a64
        add (1|M0)               r42.0<1>:ud   r1.2<0;1,0>:ud    0x2000:uw             
        shr (1|M0)               r41.3<1>:ud   r41.0<0;1,0>:ud   0x2:uw             
        and (1|M0)               r41.4<1>:d    r1.0<0;1,0>:uw    3:w              
        add (1|M0)               r41.2<1>:d    r77.0<0;1,0>:d    -r77.1<0;1,0>:d 
        send.slm (1|M0)          null     r5      r11:4   0x0            0x0200D704           {$2} // wr:1+4, rd:0; store.slm.d64x16t.a32
        send.slm (1|M0)          null     r42     r7:2    0x0            0x0200C704           {A@4,$3} // wr:1+2, rd:0; store.slm.d64x8t.a32
(W)     send.slm (1|M0)          r9       r0      null:0  0x0            0x0210001F           {$4} // wr:1+0, rd:1; fence.slm.none.group
(W)     mov (1|M0)               r10.2<1>:f    0.0:f                               {Compacted}
(W)     mov (2|M0)               r10.10<1>:ub  r0.11<0;1,0>:ub                  {F@1}
(W)     mov (8|M0)               null<1>:ud    r9.0<1;1,0>:ud                   {$4.dst}
(W)     send.gtwy (1|M0)         null     r10     null:0  0x0            0x02000004           {A@2,$5} // wr:1+0, rd:0; signal barrier
(W)     sync.bar                             null                            
        cmp (1|M0)    (gt)f0.0   null<1>:d     r2.6<0;1,0>:d     31:w              
        shl (1|M0)               r41.6<1>:ud   r41.3<0;1,0>:ud   0x9:uw             
        shl (1|M0)               r41.7<1>:d    r41.4<0;1,0>:d    9:w              
        mov (16|M0)              r45.0<1>:d    0:w                              
(W)     and (1|M0)               f1.0<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
        mov (16|M0)              r47.0<1>:d    0:w                              
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
(~f1.0.any16h) goto (16|M0)                  L2736                  L2736                
L1424:
        asr (1|M0)               r1.3<1>:d     r2.2<0;1,0>:d     31:w              
        shr (1|M0)               r2.1<1>:ud    r2.2<0;1,0>:ud    0x1B:uw             
        mov (1|M0)               r42.5<1>:f    r41.5<0;1,0>:f                   {$3.src}
        shl (1|M0)               r2.0<1>:d     r1.3<0;1,0>:d     5:w               {Compacted,I@2}
        shl (1|M0)               r42.3<1>:d    r2.2<0;1,0>:d     5:w              
        mov (1|M0)               r43.2<2>:f    0.0:f                              
        mov (1|M0)               r43.3<2>:f    0.0:f                              
        mov (2|M0)               r42.1<1>:d    r42.5<1;1,0>:d                   {F@3}
        or (1|M0)                r42.4<1>:d    r2.0<0;1,0>:d     r2.1<0;1,0>:d    {I@3}
        asr (1|M0)               r42.2<1>:d    r41.5<0;1,0>:d    31:w              
        mov (1|M0)               r42.6<1>:d    0:w                              
L1592:
        addc (1|M0)              r2.0<1>:ud    r43.2<0;1,0>:ud   0x1:ud              {AccWrEn,F@2}
(W)     mov (1|M0)               r1.3<1>:hf    0x1:hf                             
        mov (1|M0)               r43.4<1>:d    r2.0<0;1,0>:d                    {I@1}
        mov (1|M0)               r4.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        cmp (1|M0)    (lt)f1.0   null<1>:ud    r43.4<0;1,0>:ud   r42.1<0;1,0>:ud  {I@2}
        add3 (1|M0)              r43.5<1>:d    r4.0<0;0>:d       r43.3<0;0>:d      0:w               {A@2}
        and (1|M0)               r42.7<1>:d    r43.2<0;1,0>:d    1:w              
        cmp (1|M0)    (lt)f0.0   null<1>:d     r43.5<0;1,0>:d    r42.2<0;1,0>:d   {I@2}
(f1.0)  cmp (1|M0)    (eq)f1.0   null<1>:d     r43.5<0;1,0>:d    r42.2<0;1,0>:d  
(f0.0)  sel (1|M0)               r3.8<1>:uw    r1.3<0;1,0>:uw    0x0:uw              {F@1}
(f1.0)  sel (1|M0)               r1.4<1>:uw    r1.3<0;1,0>:uw    0x0:uw             
        or (1|M0)     (ne)f1.1   null<1>:uw    r1.4<0;1,0>:uw    r3.8<0;1,0>:uw   {I@1}
(W)     and (1|M0)               f0.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(~f0.1.any16h) goto (16|M0)                  L2272                  L2272                
L1808:
        shl (1|M0)               r1.5<1>:d     r43.4<0;1,0>:d    12:w              
        shl (1|M0)               r1.3<1>:d     r43.5<0;1,0>:d    12:w              
        shr (1|M0)               r1.4<1>:ud    r43.4<0;1,0>:ud   0x14:uw             
        addc (1|M0)              r2.0<1>:ud    r43.0<0;1,0>:ud   r1.5<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r1.6<1>:d     r1.3<0;1,0>:d     r1.4<0;1,0>:d    {I@2}
        mov (1|M0)               r4.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        sync.allrd                           ($2,$6)                
        mov (1|M0)               r5.0<1>:f     r2.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r5.1<1>:d     r4.0<0;0>:d       r43.1<0;0>:d      r1.6<0>:d        {I@1}
        mul (1|M0)               acc0.0<1>:ud  r42.3<0;1,0>:ud   r43.8<0;1,0>:uw 
        sync.nop                             null                             {Compacted,$8.src}
        send.ugm (1|M0)          r6       r5      null:0  0x0            0x0240D780           {A@1,$9} // wr:1+0, rd:4; load.ugm.d64x16t.a64
        mach (1|M0)              r12.0<1>:ud   r42.3<0;1,0>:ud   r43.4<0;1,0>:ud  {AccWrEn}
        xor (1|M0)               r1.2<1>:d     r42.7<0;1,0>:d    1:w              
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r42.3<0;1,0>:d    r43.10<0;1,0>:uw
        mach (1|M0)              r13.0<1>:d    r42.3<0;1,0>:d    r43.5<0;1,0>:d  
(W)     mul (1|M0)               acc0.0<1>:d   r42.4<0;1,0>:d    r43.8<0;1,0>:uw 
        mach (1|M0)              r2.0<1>:d     r42.4<0;1,0>:d    r43.4<0;1,0>:d  
        addc (1|M0)              r4.0<1>:ud    r44.0<0;1,0>:ud   r11.0<0;1,0>:ud  {AccWrEn,I@5}
        shl (1|M0)               r3.4<1>:d     r1.2<0;1,0>:d     12:w              
        add3 (1|M0)              r1.4<1>:d     r2.0<0;0>:d       r12.0<0;0>:d      r13.0<0>:d       {I@3}
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$9.src}
        mov (1|M0)               r14.0<1>:f    r4.0<0;1,0>:f                    {Compacted,I@4}
        sync.nop                             null                             {Compacted,$5.src}
        mad (1|M0)               r10.0<1>:d    r3.4<0;0>:d       r1.0<0;0>:uw      128:w               {I@3}
        add3 (1|M0)              r14.1<1>:d    r5.0<0;0>:d       r44.1<0;0>:d      r1.4<0>:d        {I@2}
        shl (1|M0)               r1.2<1>:d     r1.2<0;1,0>:d     11:w              
        send.slm (1|M0)          null     r10     r6:4    0x0            0x0200D704           {A@3,$9} // wr:1+4, rd:0; store.slm.d64x16t.a32
        sync.nop                             null                             {Compacted,$9.src}
        send.ugm (1|M0)          r6       r14     null:0  0x0            0x0220C780           {A@1,$10} // wr:1+0, rd:2; load.ugm.d64x8t.a64
        add (1|M0)               r8.0<1>:d     r1.2<0;1,0>:d     r42.0<0;1,0>:d   {Compacted,I@1}
        sync.nop                             null                             {Compacted,$10.dst}
        send.slm (1|M0)          null     r8      r6:2    0x0            0x0200C704           {A@1,$8} // wr:1+2, rd:0; store.slm.d64x8t.a32
L2272:
        join (16|M0)                         L2736                                
L2288:
        shl (1|M0)               r1.2<1>:d     r42.7<0;1,0>:d    12:w              
        shl (1|M0)               r42.7<1>:d    r42.7<0;1,0>:d    11:w              
        add (1|M0)               r2.0<1>:d     r1.2<0;1,0>:d     r41.6<0;1,0>:d   {I@2}
        bfn.0xFE (1|M0)          r4.0<1>:ud    0x2000:uw               r42.7<0;0>:ud     r41.7<0>:ud      {I@2} // s0|s1|s2
        bfn.0xFE (1|M0)          r30.0<1>:ud   0x2100:uw               r42.7<0;0>:ud     r41.7<0>:ud      // s0|s1|s2
        sync.nop                             null                             {Compacted,$2.src}
        or (1|M0)                r13.0<1>:ud   r2.0<0;1,0>:ud    0x100:uw              {I@3}
        sync.allrd                           ($5,$6)                
        send.slm (1|M0)          r5       r2      null:0  0x0            0x0280E700           {$11} // wr:1+0, rd:8; load.slm.d64x32t.a32
        send.slm (1|M0)          r22      r4      null:0  0x0            0x0280E700           {A@3,$12} // wr:1+0, rd:8; load.slm.d64x32t.a32
        send.slm (1|M0)          r31      r30     null:0  0x0            0x0280E700           {A@2,$13} // wr:1+0, rd:8; load.slm.d64x32t.a32
        send.slm (1|M0)          r14      r13     null:0  0x0            0x0280E700           {A@1,$14} // wr:1+0, rd:8; load.slm.d64x32t.a32
        sync.allwr                           ($6,$11,$12,$13,$14)                
        dpas.8x8 (8|M0)          r69:d         r69:d             r22:b             r5.0:b           {Atomic}
        dpas.8x8 (8|M0)          r61:d         r61:d             r31:b             r5.0:b           {Atomic}
        dpas.8x8 (8|M0)          r53:d         r53:d             r22:b             r14.0:b          {Atomic}
        dpas.8x8 (8|M0)          r45:d         r45:d             r31:b             r14.0:b          {$6}
(W)     send.slm (1|M0)          r39      r0      null:0  0x0            0x0210001F           {$15} // wr:1+0, rd:1; fence.slm.none.group
(W)     mov (1|M0)               r40.2<1>:f    0.0:f                               {Compacted,$7.src}
(W)     mov (2|M0)               r40.10<1>:ub  r0.11<0;1,0>:ub                  {F@1}
(W)     mov (8|M0)               null<1>:ud    r39.0<1;1,0>:ud                  {$15.dst}
(W)     send.gtwy (1|M0)         null     r40     null:0  0x0            0x02000004           {A@2,$7} // wr:1+0, rd:0; signal barrier
(W)     sync.bar                             null                            
        cmp (1|M0)    (eq)f0.1   null<1>:d     r43.5<0;1,0>:d    r42.6<0;1,0>:d  
(f0.1)  cmp (1|M0)    (eq)f0.1   null<1>:d     r43.4<0;1,0>:d    r42.5<0;1,0>:d  
(W)     and (1|M0)               f0.0<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(f0.0.any16h) goto (16|M0)                   L2736                  L2736                
L2704:
(W)     mov (2|M0)               r43.2<1>:ud   r43.4<1;1,0>:ud                 
        goto.b (16|M0)                       L2736                  L1592                
L2736:
        join (16|M0)                         L2752                                
L2752:
        shl (1|M0)               r41.2<1>:d    r41.2<0;1,0>:d    6:w              
        shl (1|M0)               r41.4<1>:d    r41.4<0;1,0>:d    4:w              
        shl (1|M0)               r41.1<1>:d    r41.1<0;1,0>:d    7:w               {Compacted}
        or (1|M0)                r1.2<1>:d     r41.2<0;1,0>:d    r41.4<0;1,0>:d   {I@2}
        shl (1|M0)               r41.3<1>:ud   r41.3<0;1,0>:ud   0x4:uw             
        shl (1|M0)               r2.0<1>:d     r1.2<0;1,0>:d     2:w               {Compacted,I@2}
        add (1|M0)               r41.1<1>:d    r41.1<0;1,0>:d    r41.3<0;1,0>:d   {I@2}
        addc (1|M0)              r4.0<1>:ud    r3.2<0;1,0>:ud    r2.0<0;1,0>:ud   {AccWrEn,I@2}
        shr (1|M0)               r1.4<1>:ud    r1.2<0;1,0>:ud    0x1E:uw             
        sync.nop                             null                             {Compacted,$6.src}
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$2.src}
        mul (1|M0)               acc0.0<1>:d   r41.1<0;1,0>:d    r2.4<0;1,0>:uw   {I@4}
        mach (1|M0)              r11.0<1>:d    r41.1<0;1,0>:d    r2.2<0;1,0>:d    {AccWrEn}
        or (1|M0)                r4.1<1>:d     r41.1<0;1,0>:d    8:w               {Compacted}
        mov (1|M0)               r10.0<1>:d    acc0.0<0;1,0>:d                  {$5.src}
        or (1|M0)                r2.1<1>:d     r1.4<0;1,0>:d     0:w               {I@6}
        shl (1|M0)               r1.3<1>:d     r10.0<0;1,0>:d    2:w               {Compacted,I@2}
        add3 (1|M0)              r3.5<1>:d     r5.0<0;0>:d       r3.3<0;0>:d       r2.1<0>:d        {I@2}
        addc (1|M0)              r2.0<1>:ud    r4.0<0;1,0>:ud    r1.3<0;1,0>:ud   {AccWrEn,I@2}
        shl (1|M0)               r3.6<1>:d     r11.0<0;1,0>:d    2:w               {Compacted}
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mul (1|M0)               acc0.0<1>:d   r4.1<0;1,0>:d     r2.4<0;1,0>:uw  
        mach (1|M0)              r14.0<1>:d    r4.1<0;1,0>:d     r2.2<0;1,0>:d    {AccWrEn}
        shr (1|M0)               r1.2<1>:ud    r10.0<0;1,0>:ud   0x1E:uw             
        mov (1|M0)               r13.0<1>:d    acc0.0<0;1,0>:d                 
        or (1|M0)                r1.4<1>:d     r3.6<0;1,0>:d     r1.2<0;1,0>:d    {I@2}
        shl (1|M0)               r3.6<1>:d     r13.0<0;1,0>:d    2:w               {Compacted,I@2}
        or (1|M0)                r1.2<1>:d     r41.1<0;1,0>:d    1:w              
        addc (1|M0)              r11.0<1>:ud   r4.0<0;1,0>:ud    r3.6<0;1,0>:ud   {AccWrEn,I@2}
        mov (1|M0)               r12.0<1>:f    r2.0<0;1,0>:f                    {Compacted}
        mov (1|M0)               r2.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,F@1}
        mul (1|M0)               acc0.0<1>:d   r1.2<0;1,0>:d     r2.4<0;1,0>:uw   {I@3}
        sync.nop                             null                             {Compacted,$6.dst}
        mov (8|M0)               r6.0<1>:f     r69.0<1;1,0>:f                   {Compacted,$8.src}
        mov (8|M0)               r7.0<1>:f     r61.0<1;1,0>:f                   {Compacted,$3.src}
        shl (1|M0)               r15.0<1>:d    r14.0<0;1,0>:d    2:w               {Compacted}
        shr (1|M0)               r10.0<1>:ud   r13.0<0;1,0>:ud   0x1E:uw             
        add3 (1|M0)              r12.1<1>:d    r5.0<0;0>:d       r3.5<0;0>:d       r1.4<0>:d       
        mach (1|M0)              r13.0<1>:d    r1.2<0;1,0>:d     r2.2<0;1,0>:d    {AccWrEn}
        send.ugm (1|M0)          null     r12     r6:2    0x0            0x0200C784           {A@1,$0} // wr:1+2, rd:0; store.ugm.d64x8t.a64
        or (1|M0)                r3.7<1>:d     r15.0<0;1,0>:d    r10.0<0;1,0>:d   {Compacted}
        mov (1|M0)               r12.0<1>:d    acc0.0<0;1,0>:d                  {$0.src}
        mov (8|M0)               r8.0<1>:f     r53.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r9.0<1>:f     r45.0<1;1,0>:f                   {Compacted}
        mov (1|M0)               r5.0<1>:f     r11.0<0;1,0>:f                   {Compacted}
        add3 (1|M0)              r5.1<1>:d     r2.0<0;0>:d       r3.5<0;0>:d       r3.7<0>:d        {I@2}
        shl (1|M0)               r2.0<1>:d     r12.0<0;1,0>:d    2:w               {Compacted,I@2}
        send.ugm (1|M0)          null     r5      r8:2    0x0            0x0200C784           {A@1,$1} // wr:1+2, rd:0; store.ugm.d64x8t.a64
        or (1|M0)                r3.6<1>:d     r41.1<0;1,0>:d    9:w              
        sync.nop                             null                             {Compacted,$1.src}
        addc (1|M0)              r5.0<1>:ud    r4.0<0;1,0>:ud    r2.0<0;1,0>:ud   {AccWrEn,I@2}
        shr (1|M0)               r4.2<1>:ud    r12.0<0;1,0>:ud   0x1E:uw             
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mul (1|M0)               acc0.0<1>:d   r3.6<0;1,0>:d     r2.4<0;1,0>:uw   {I@4}
        mach (1|M0)              r11.0<1>:d    r3.6<0;1,0>:d     r2.2<0;1,0>:d    {AccWrEn}
        or (1|M0)                r3.6<1>:d     r41.1<0;1,0>:d    2:w              
        mov (1|M0)               r10.0<1>:d    acc0.0<0;1,0>:d                 
        mov (1|M0)               r9.0<1>:f     r5.0<0;1,0>:f                    {Compacted,I@7}
        shl (1|M0)               r1.4<1>:d     r10.0<0;1,0>:d    2:w               {Compacted,I@1}
        shl (1|M0)               r4.1<1>:d     r13.0<0;1,0>:d    2:w               {Compacted}
        addc (1|M0)              r12.0<1>:ud   r4.0<0;1,0>:ud    r1.4<0;1,0>:ud   {AccWrEn,I@2}
        shl (1|M0)               r1.2<1>:d     r11.0<0;1,0>:d    2:w               {Compacted}
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,F@1}
        mul (1|M0)               acc0.0<1>:d   r3.6<0;1,0>:d     r2.4<0;1,0>:uw  
        shr (1|M0)               r1.3<1>:ud    r10.0<0;1,0>:ud   0x1E:uw             
        mach (1|M0)              r11.0<1>:d    r3.6<0;1,0>:d     r2.2<0;1,0>:d    {AccWrEn}
        or (1|M0)                r2.1<1>:d     r4.1<0;1,0>:d     r4.2<0;1,0>:d    {I@7}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@3}
        mov (1|M0)               r10.0<1>:d    acc0.0<0;1,0>:d                 
        mov (8|M0)               r16.0<1>:f    r54.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r17.0<1>:f    r46.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r6.0<1>:f     r70.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r7.0<1>:f     r62.0<1;1,0>:f                   {Compacted}
        mov (1|M0)               r2.0<1>:f     r12.0<0;1,0>:f                   {Compacted}
        add3 (1|M0)              r9.1<1>:d     r8.0<0;0>:d       r3.5<0;0>:d       r2.1<0>:d        {I@3}
        shl (1|M0)               r1.2<1>:d     r10.0<0;1,0>:d    2:w               {Compacted,I@2}
        add3 (1|M0)              r2.1<1>:d     r5.0<0;0>:d       r3.5<0;0>:d       r1.5<0>:d       
        send.ugm (1|M0)          null     r9      r6:2    0x0            0x0200C784           {A@2,$2} // wr:1+2, rd:0; store.ugm.d64x8t.a64
        send.ugm (1|M0)          null     r2      r16:2   0x0            0x0200C784           {A@1,$3} // wr:1+2, rd:0; store.ugm.d64x8t.a64
        or (1|M0)                r13.0<1>:d    r41.1<0;1,0>:d    10:w               {Compacted}
        addc (1|M0)              r2.0<1>:ud    r4.0<0;1,0>:ud    r1.2<0;1,0>:ud   {AccWrEn,$3.src}
        shl (1|M0)               r4.1<1>:d     r11.0<0;1,0>:d    2:w               {Compacted}
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mul (1|M0)               acc0.0<1>:d   r13.0<0;1,0>:d    r2.4<0;1,0>:uw   {Compacted,I@4}
        mach (1|M0)              r15.0<1>:d    r13.0<0;1,0>:d    r2.2<0;1,0>:d    {AccWrEn}
        shr (1|M0)               r4.2<1>:ud    r10.0<0;1,0>:ud   0x1E:uw             
        mov (1|M0)               r14.0<1>:d    acc0.0<0;1,0>:d                 
        or (1|M0)                r1.3<1>:d     r4.1<0;1,0>:d     r4.2<0;1,0>:d    {I@2}
        shl (1|M0)               r4.1<1>:d     r14.0<0;1,0>:d    2:w               {Compacted,I@2}
        or (1|M0)                r1.2<1>:d     r41.1<0;1,0>:d    3:w              
        addc (1|M0)              r10.0<1>:ud   r4.0<0;1,0>:ud    r4.1<0;1,0>:ud   {AccWrEn,I@2}
        mov (1|M0)               r12.0<1>:f    r2.0<0;1,0>:f                    {Compacted}
        mov (1|M0)               r2.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,F@1}
        mul (1|M0)               acc0.0<1>:d   r1.2<0;1,0>:d     r2.4<0;1,0>:uw   {I@3}
        shl (1|M0)               r3.6<1>:d     r15.0<0;1,0>:d    2:w               {Compacted}
        shr (1|M0)               r3.7<1>:ud    r14.0<0;1,0>:ud   0x1E:uw             
        mach (1|M0)              r14.0<1>:d    r1.2<0;1,0>:d     r2.2<0;1,0>:d    {AccWrEn}
        or (1|M0)                r4.2<1>:d     r3.6<0;1,0>:d     r3.7<0;1,0>:d    {I@2}
        mov (1|M0)               r13.0<1>:d    acc0.0<0;1,0>:d                 
        mov (8|M0)               r8.0<1>:f     r55.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r6.0<1>:f     r71.0<1;1,0>:f                   {Compacted,$2.src}
        mov (8|M0)               r7.0<1>:f     r63.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r9.0<1>:f     r47.0<1;1,0>:f                   {Compacted}
        add3 (1|M0)              r12.1<1>:d    r5.0<0;0>:d       r3.5<0;0>:d       r1.3<0>:d       
        add3 (1|M0)              r5.1<1>:d     r2.0<0;0>:d       r3.5<0;0>:d       r4.2<0>:d        {I@3}
        mov (1|M0)               r5.0<1>:f     r10.0<0;1,0>:f                   {Compacted,I@2}
        shl (1|M0)               r2.0<1>:d     r13.0<0;1,0>:d    2:w               {Compacted}
        send.ugm (1|M0)          null     r12     r6:2    0x0            0x0200C784           {A@3,$4} // wr:1+2, rd:0; store.ugm.d64x8t.a64
        send.ugm (1|M0)          null     r5      r8:2    0x0            0x0200C784           {A@1,$5} // wr:1+2, rd:0; store.ugm.d64x8t.a64
        or (1|M0)                r4.1<1>:d     r41.1<0;1,0>:d    11:w               {Compacted}
        sync.nop                             null                             {Compacted,$5.src}
        addc (1|M0)              r5.0<1>:ud    r4.0<0;1,0>:ud    r2.0<0;1,0>:ud   {AccWrEn,I@2}
        shl (1|M0)               r3.6<1>:d     r14.0<0;1,0>:d    2:w               {Compacted}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mul (1|M0)               acc0.0<1>:d   r4.1<0;1,0>:d     r2.4<0;1,0>:uw   {I@4}
        mach (1|M0)              r16.0<1>:d    r4.1<0;1,0>:d     r2.2<0;1,0>:d    {AccWrEn}
        shr (1|M0)               r3.7<1>:ud    r13.0<0;1,0>:ud   0x1E:uw             
        mov (1|M0)               r15.0<1>:d    acc0.0<0;1,0>:d                 
        or (1|M0)                r2.1<1>:d     r3.6<0;1,0>:d     r3.7<0;1,0>:d    {I@2}
        shl (1|M0)               r1.4<1>:d     r15.0<0;1,0>:d    2:w               {Compacted,I@2}
        or (1|M0)                r3.6<1>:d     r41.1<0;1,0>:d    4:w              
        addc (1|M0)              r10.0<1>:ud   r4.0<0;1,0>:ud    r1.4<0;1,0>:ud   {AccWrEn,I@2}
        mov (1|M0)               r9.0<1>:f     r5.0<0;1,0>:f                    {Compacted}
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,F@1}
        mul (1|M0)               acc0.0<1>:d   r3.6<0;1,0>:d     r2.4<0;1,0>:uw   {I@3}
        shl (1|M0)               r1.2<1>:d     r16.0<0;1,0>:d    2:w               {Compacted}
        shr (1|M0)               r1.3<1>:ud    r15.0<0;1,0>:ud   0x1E:uw             
        mach (1|M0)              r14.0<1>:d    r3.6<0;1,0>:d     r2.2<0;1,0>:d    {AccWrEn}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        mov (1|M0)               r13.0<1>:d    acc0.0<0;1,0>:d                 
        mov (8|M0)               r11.0<1>:f    r56.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r6.0<1>:f     r72.0<1;1,0>:f                   {Compacted,$4.src}
        mov (8|M0)               r7.0<1>:f     r64.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r12.0<1>:f    r48.0<1;1,0>:f                   {Compacted}
        add3 (1|M0)              r9.1<1>:d     r8.0<0;0>:d       r3.5<0;0>:d       r2.1<0>:d       
        mov (1|M0)               r2.0<1>:f     r10.0<0;1,0>:f                   {Compacted}
        shl (1|M0)               r1.2<1>:d     r13.0<0;1,0>:d    2:w               {Compacted,I@2}
        add3 (1|M0)              r2.1<1>:d     r5.0<0;0>:d       r3.5<0;0>:d       r1.5<0>:d       
        send.ugm (1|M0)          null     r9      r6:2    0x0            0x0200C784           {A@3,$6} // wr:1+2, rd:0; store.ugm.d64x8t.a64
        send.ugm (1|M0)          null     r2      r11:2   0x0            0x0200C784           {A@1,$7} // wr:1+2, rd:0; store.ugm.d64x8t.a64
        addc (1|M0)              r2.0<1>:ud    r4.0<0;1,0>:ud    r1.2<0;1,0>:ud   {AccWrEn,$7.src}
        or (1|M0)                r11.0<1>:d    r41.1<0;1,0>:d    12:w               {Compacted}
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mul (1|M0)               acc0.0<1>:d   r11.0<0;1,0>:d    r2.4<0;1,0>:uw   {Compacted,I@2}
        mach (1|M0)              r16.0<1>:d    r11.0<0;1,0>:d    r2.2<0;1,0>:d    {AccWrEn}
        shl (1|M0)               r4.1<1>:d     r14.0<0;1,0>:d    2:w               {Compacted}
        shr (1|M0)               r4.2<1>:ud    r13.0<0;1,0>:ud   0x1E:uw             
        mov (1|M0)               r15.0<1>:d    acc0.0<0;1,0>:d                 
        or (1|M0)                r1.3<1>:d     r4.1<0;1,0>:d     r4.2<0;1,0>:d    {I@2}
        shl (1|M0)               r4.1<1>:d     r15.0<0;1,0>:d    2:w               {Compacted,I@2}
        or (1|M0)                r1.2<1>:d     r41.1<0;1,0>:d    5:w              
        addc (1|M0)              r12.0<1>:ud   r4.0<0;1,0>:ud    r4.1<0;1,0>:ud   {AccWrEn,I@2}
        mov (1|M0)               r10.0<1>:f    r2.0<0;1,0>:f                    {Compacted}
        mov (1|M0)               r2.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,F@1}
        mul (1|M0)               acc0.0<1>:d   r1.2<0;1,0>:d     r2.4<0;1,0>:uw   {I@3}
        shl (1|M0)               r3.6<1>:d     r16.0<0;1,0>:d    2:w               {Compacted}
        shr (1|M0)               r3.7<1>:ud    r15.0<0;1,0>:ud   0x1E:uw             
        mach (1|M0)              r14.0<1>:d    r1.2<0;1,0>:d     r2.2<0;1,0>:d    {AccWrEn}
        or (1|M0)                r4.2<1>:d     r3.6<0;1,0>:d     r3.7<0;1,0>:d    {I@2}
        mov (1|M0)               r13.0<1>:d    acc0.0<0;1,0>:d                 
        mov (8|M0)               r8.0<1>:f     r57.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r6.0<1>:f     r73.0<1;1,0>:f                   {Compacted,$6.src}
        mov (8|M0)               r7.0<1>:f     r65.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r9.0<1>:f     r49.0<1;1,0>:f                   {Compacted}
        add3 (1|M0)              r10.1<1>:d    r5.0<0;0>:d       r3.5<0;0>:d       r1.3<0>:d       
        add3 (1|M0)              r5.1<1>:d     r2.0<0;0>:d       r3.5<0;0>:d       r4.2<0>:d        {I@3}
        mov (1|M0)               r5.0<1>:f     r12.0<0;1,0>:f                   {Compacted,I@2}
        shl (1|M0)               r2.0<1>:d     r13.0<0;1,0>:d    2:w               {Compacted}
        send.ugm (1|M0)          null     r10     r6:2    0x0            0x0200C784           {A@3,$8} // wr:1+2, rd:0; store.ugm.d64x8t.a64
        send.ugm (1|M0)          null     r5      r8:2    0x0            0x0200C784           {A@1,$9} // wr:1+2, rd:0; store.ugm.d64x8t.a64
        or (1|M0)                r4.1<1>:d     r41.1<0;1,0>:d    13:w               {Compacted}
        sync.nop                             null                             {Compacted,$9.src}
        addc (1|M0)              r5.0<1>:ud    r4.0<0;1,0>:ud    r2.0<0;1,0>:ud   {AccWrEn,I@2}
        shl (1|M0)               r3.6<1>:d     r14.0<0;1,0>:d    2:w               {Compacted}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mul (1|M0)               acc0.0<1>:d   r4.1<0;1,0>:d     r2.4<0;1,0>:uw   {I@4}
        mach (1|M0)              r16.0<1>:d    r4.1<0;1,0>:d     r2.2<0;1,0>:d    {AccWrEn}
        shr (1|M0)               r3.7<1>:ud    r13.0<0;1,0>:ud   0x1E:uw             
        mov (1|M0)               r15.0<1>:d    acc0.0<0;1,0>:d                 
        or (1|M0)                r2.1<1>:d     r3.6<0;1,0>:d     r3.7<0;1,0>:d    {I@2}
        shl (1|M0)               r1.4<1>:d     r15.0<0;1,0>:d    2:w               {Compacted,I@2}
        or (1|M0)                r3.6<1>:d     r41.1<0;1,0>:d    6:w              
        addc (1|M0)              r12.0<1>:ud   r4.0<0;1,0>:ud    r1.4<0;1,0>:ud   {AccWrEn,I@2}
        mov (1|M0)               r9.0<1>:f     r5.0<0;1,0>:f                    {Compacted}
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,F@1}
        mul (1|M0)               acc0.0<1>:d   r3.6<0;1,0>:d     r2.4<0;1,0>:uw   {I@3}
        shl (1|M0)               r1.2<1>:d     r16.0<0;1,0>:d    2:w               {Compacted}
        shr (1|M0)               r1.3<1>:ud    r15.0<0;1,0>:ud   0x1E:uw             
        mach (1|M0)              r14.0<1>:d    r3.6<0;1,0>:d     r2.2<0;1,0>:d    {AccWrEn}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        mov (1|M0)               r13.0<1>:d    acc0.0<0;1,0>:d                 
        mov (8|M0)               r11.0<1>:f    r50.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r6.0<1>:f     r74.0<1;1,0>:f                   {Compacted,$8.src}
        mov (8|M0)               r7.0<1>:f     r66.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r10.0<1>:f    r58.0<1;1,0>:f                   {Compacted}
        add3 (1|M0)              r9.1<1>:d     r8.0<0;0>:d       r3.5<0;0>:d       r2.1<0>:d       
        mov (1|M0)               r2.0<1>:f     r12.0<0;1,0>:f                   {Compacted}
        shl (1|M0)               r1.2<1>:d     r13.0<0;1,0>:d    2:w               {Compacted,I@2}
        add3 (1|M0)              r2.1<1>:d     r5.0<0;0>:d       r3.5<0;0>:d       r1.5<0>:d       
        send.ugm (1|M0)          null     r9      r6:2    0x0            0x0200C784           {A@3,$10} // wr:1+2, rd:0; store.ugm.d64x8t.a64
        send.ugm (1|M0)          null     r2      r10:2   0x0            0x0200C784           {A@1,$11} // wr:1+2, rd:0; store.ugm.d64x8t.a64
        addc (1|M0)              r2.0<1>:ud    r4.0<0;1,0>:ud    r1.2<0;1,0>:ud   {AccWrEn,$11.src}
        or (1|M0)                r11.0<1>:d    r41.1<0;1,0>:d    14:w               {Compacted}
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mul (1|M0)               acc0.0<1>:d   r11.0<0;1,0>:d    r2.4<0;1,0>:uw   {Compacted,I@2}
        mach (1|M0)              r16.0<1>:d    r11.0<0;1,0>:d    r2.2<0;1,0>:d    {AccWrEn}
        shl (1|M0)               r4.1<1>:d     r14.0<0;1,0>:d    2:w               {Compacted}
        shr (1|M0)               r4.2<1>:ud    r13.0<0;1,0>:ud   0x1E:uw             
        mov (1|M0)               r15.0<1>:d    acc0.0<0;1,0>:d                 
        or (1|M0)                r1.3<1>:d     r4.1<0;1,0>:d     r4.2<0;1,0>:d    {I@2}
        shl (1|M0)               r4.1<1>:d     r15.0<0;1,0>:d    2:w               {Compacted,I@2}
        or (1|M0)                r1.2<1>:d     r41.1<0;1,0>:d    7:w              
        addc (1|M0)              r12.0<1>:ud   r4.0<0;1,0>:ud    r4.1<0;1,0>:ud   {AccWrEn,I@2}
        mov (1|M0)               r10.0<1>:f    r2.0<0;1,0>:f                    {Compacted}
        mov (1|M0)               r2.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,F@1}
        mul (1|M0)               acc0.0<1>:d   r1.2<0;1,0>:d     r2.4<0;1,0>:uw   {I@3}
        shl (1|M0)               r3.6<1>:d     r16.0<0;1,0>:d    2:w               {Compacted}
        shr (1|M0)               r3.7<1>:ud    r15.0<0;1,0>:ud   0x1E:uw             
        mach (1|M0)              r14.0<1>:d    r1.2<0;1,0>:d     r2.2<0;1,0>:d    {AccWrEn}
        or (1|M0)                r4.2<1>:d     r3.6<0;1,0>:d     r3.7<0;1,0>:d    {I@2}
        mov (1|M0)               r13.0<1>:d    acc0.0<0;1,0>:d                 
        mov (8|M0)               r8.0<1>:f     r59.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r6.0<1>:f     r75.0<1;1,0>:f                   {Compacted,$10.src}
        mov (8|M0)               r7.0<1>:f     r67.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r9.0<1>:f     r51.0<1;1,0>:f                   {Compacted}
        add3 (1|M0)              r10.1<1>:d    r5.0<0;0>:d       r3.5<0;0>:d       r1.3<0>:d       
        add3 (1|M0)              r5.1<1>:d     r2.0<0;0>:d       r3.5<0;0>:d       r4.2<0>:d        {I@3}
        mov (1|M0)               r5.0<1>:f     r12.0<0;1,0>:f                   {Compacted,I@2}
        shl (1|M0)               r2.0<1>:d     r13.0<0;1,0>:d    2:w               {Compacted}
        send.ugm (1|M0)          null     r10     r6:2    0x0            0x0200C784           {A@3,$12} // wr:1+2, rd:0; store.ugm.d64x8t.a64
        send.ugm (1|M0)          null     r5      r8:2    0x0            0x0200C784           {A@1,$13} // wr:1+2, rd:0; store.ugm.d64x8t.a64
        or (1|M0)                r41.1<1>:d    r41.1<0;1,0>:d    15:w               {Compacted}
        sync.nop                             null                             {Compacted,$13.src}
        addc (1|M0)              r5.0<1>:ud    r4.0<0;1,0>:ud    r2.0<0;1,0>:ud   {AccWrEn,I@2}
        shl (1|M0)               r3.6<1>:d     r14.0<0;1,0>:d    2:w               {Compacted}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mul (1|M0)               acc0.0<1>:d   r41.1<0;1,0>:d    r2.4<0;1,0>:uw   {I@4}
        mach (1|M0)              r16.0<1>:d    r41.1<0;1,0>:d    r2.2<0;1,0>:d    {AccWrEn}
        shr (1|M0)               r3.7<1>:ud    r13.0<0;1,0>:ud   0x1E:uw             
        mov (1|M0)               r15.0<1>:d    acc0.0<0;1,0>:d                 
        shl (1|M0)               r1.2<1>:d     r16.0<0;1,0>:d    2:w               {Compacted,I@3}
        shl (1|M0)               r1.4<1>:d     r15.0<0;1,0>:d    2:w               {Compacted,I@2}
        shr (1|M0)               r1.3<1>:ud    r15.0<0;1,0>:ud   0x1E:uw             
        addc (1|M0)              r12.0<1>:ud   r4.0<0;1,0>:ud    r1.4<0;1,0>:ud   {AccWrEn,I@2}
        mov (1|M0)               r9.0<1>:f     r5.0<0;1,0>:f                    {Compacted}
        or (1|M0)                r2.1<1>:d     r3.6<0;1,0>:d     r3.7<0;1,0>:d   
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@3}
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,F@1}
        mov (8|M0)               r11.0<1>:f    r52.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r6.0<1>:f     r76.0<1;1,0>:f                   {Compacted,$12.src}
        mov (8|M0)               r7.0<1>:f     r68.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r10.0<1>:f    r60.0<1;1,0>:f                   {Compacted}
        mov (1|M0)               r2.0<1>:f     r12.0<0;1,0>:f                   {Compacted,I@4}
        add3 (1|M0)              r9.1<1>:d     r8.0<0;0>:d       r3.5<0;0>:d       r2.1<0>:d        {I@3}
        add3 (1|M0)              r2.1<1>:d     r5.0<0;0>:d       r3.5<0;0>:d       r1.5<0>:d        {I@2}
        send.ugm (1|M0)          null     r9      r6:2    0x0            0x0200C784           {A@2,$14} // wr:1+2, rd:0; store.ugm.d64x8t.a64
        send.ugm (1|M0)          null     r2      r10:2   0x0            0x0200C784           {A@1,$15} // wr:1+2, rd:0; store.ugm.d64x8t.a64
(W)     mov (8|M0)               r127.0<1>:f   r0.0<1;1,0>:f                    {Compacted}
        sync.nop                             null                             {Compacted,$14.src}
(W)     send.ugm (1|M0)          r6       r0      null:0  0x0            0x0210641F           {$0} // wr:1+0, rd:1; fence invalid flush type scoped to tile
(W)     mov (8|M0)               null<1>:ud    r6.0<1;1,0>:ud                   {$0.dst}
(W)     send.gtwy (1|M0)         null     r127    null:0  0x0            0x02000010           {EOT,A@1} // wr:1+0, rd:0; end of thread
L6000:
        mov (1|M0)               r1.2<1>:d     cr0.0<0;1,0>:ud                  {A@1}
        and (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   -1265:w               {A@1}
        or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   1264:w               {A@1}
        mov (1|M0)               r1.5<1>:f     (abs)r44.5<0;1,0>:d              {A@1}
        mov (1|M0)               r3.6<1>:f     0xB4C00000:f                               {Compacted}
        math.inv (1|M0)          r3.5<1>:f     r1.5<0;1,0>:f                    {@2,$1}
        mov (1|M0)               r2.1<1>:f     (abs)r44.4<0;1,0>:d             
        sync.nop                             null                             {Compacted,$1.dst}
        mad (1|M0)               r3.5<1>:f     r3.5<0;0>:f       r3.6<0;0>:f       r3.5<0>:f        {F@2}
        mov (1|M0)               r1.3<1>:d     (abs)r44.4<0;1,0>:d             
        mov (1|M0)               r1.4<1>:d     (abs)r44.5<0;1,0>:d             
        mov (1|M0)               r1.6<1>:ud    r1.5<0;1,0>:f                   
        mov (1|M0)               r2.3<1>:ud    r2.1<0;1,0>:f                    {F@2}
        mul (1|M0)               r4.0<1>:f     r3.5<0;1,0>:f     r2.1<0;1,0>:f    {F@1}
        add (1|M0)               r1.6<1>:ud    r1.4<0;1,0>:ud    -r1.6<0;1,0>:ud  {I@2}
        add (1|M0)               r2.3<1>:ud    r1.3<0;1,0>:ud    -r2.3<0;1,0>:ud  {I@2}
        mov (1|M0)               r5.0<1>:ud    r4.0<0;1,0>:f                    {F@1}
        mov (1|M0)               r2.0<1>:f     r1.6<0;1,0>:ud                   {Compacted,I@3}
        mov (1|M0)               r3.4<1>:f     r2.3<0;1,0>:ud                   {I@2}
        mov (1|M0)               r5.1<1>:f     r5.0<0;1,0>:ud                   {Compacted,I@1}
        xor (1|M0)               r44.5<1>:d    r44.5<0;1,0>:d    r44.4<0;1,0>:d  
        mad (1|M0)               r2.1<1>:f     r2.1<0;0>:f       r5.1<0;0>:f       -r1.5<0>:f       {F@1}
        mad (1|M0)               r5.1<1>:f     r3.4<0;0>:f       r5.1<0;0>:f       -r2.0<0>:f      
(W)     mov (1|M0)               r4.0<1>:hf    0x1:hf                             
        add (1|M0)               r2.1<1>:f     r2.1<0;1,0>:f     r5.1<0;1,0>:f    {F@2}
        asr (1|M0)               r44.5<1>:d    r44.5<0;1,0>:d    31:w               {I@1}
        mul (1|M0)               r3.5<1>:f     r3.5<0;1,0>:f     r2.1<0;1,0>:f    {F@1}
        mov (1|M0)               r6.0<1>:ud    r3.5<0;1,0>:f                    {F@1}
        add (1|M0)               r5.0<1>:ud    r5.0<0;1,0>:ud    r6.0<0;1,0>:ud   {Compacted,I@1}
(W)     mul (1|M0)               acc0.0<1>:ud  r5.0<0;1,0>:ud    r1.8<0;1,0>:uw   {I@1}
        mach (1|M0)              r7.0<1>:ud    r5.0<0;1,0>:ud    r1.4<0;1,0>:ud   {Compacted}
        add (1|M0)               r1.3<1>:ud    r1.3<0;1,0>:ud    -r7.0<0;1,0>:ud  {Compacted,I@1}
        cmp (1|M0)    (ge)f1.1   null<1>:ud    r1.3<0;1,0>:ud    r1.4<0;1,0>:ud   {I@1}
(f1.1)  sel (1|M0)               r8.0<1>:d     r4.0<0;1,0>:w     0:w              
        add3 (1|M0)              r5.0<1>:d     r5.0<0;0>:d       r44.5<0;0>:d      r8.0<0>:d        {I@1}
        xor (1|M0)               r41.1<1>:d    r5.0<0;1,0>:d     r44.5<0;1,0>:d   {I@1}
        mov (1|M0)               cr0.0<1>:ud   r1.2<0;1,0>:d                    {A@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        ret (16|M0)                          r43.6                            {A@1}
L6584:
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
