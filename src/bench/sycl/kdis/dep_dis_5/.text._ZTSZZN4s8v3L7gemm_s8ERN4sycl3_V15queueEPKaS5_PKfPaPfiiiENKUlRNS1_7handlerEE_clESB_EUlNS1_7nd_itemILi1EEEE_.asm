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
        asr (1|M0)               r82.1<1>:d    r2.2<0;1,0>:d     31:w               {A@1}
        mov (1|M0)               r41.0<1>:d    r1.0<0;1,0>:uw                   {$0.dst}
        shr (1|M0)               r82.1<1>:ud   r82.1<0;1,0>:ud   0x1A:uw              {I@2}
        shl (1|M0)               r1.2<1>:d     r41.0<0;1,0>:d    2:w               {Compacted,I@2}
        add (1|M0)               r82.1<1>:d    r2.2<0;1,0>:d     r82.1<0;1,0>:d   {I@2}
        mov (1|M0)               r4.0<1>:f     0.0:f                               {Compacted}
        mov (1|M0)               r82.0<1>:d    r0.1<0;1,0>:ud                  
        add (1|M0)               r2.0<1>:d     r1.2<0;1,0>:d     12288:w               {I@3}
        add (1|M0)               r5.0<1>:d     r1.2<0;1,0>:d     12416:w              
        add (1|M0)               r6.0<1>:d     r1.2<0;1,0>:d     12544:w              
        add (1|M0)               r7.0<1>:d     r1.2<0;1,0>:d     12672:w              
        asr (1|M0)               r82.1<1>:d    r82.1<0;1,0>:d    6:w               {Compacted,I@6}
        send.slm (1|M0)          null     r2      r4:1    0x0            0x02000504           {A@1,$2} // wr:1+1, rd:0; store.slm.d32.a32
        send.slm (1|M0)          null     r5      r4:1    0x0            0x02000504           {A@4,$3} // wr:1+1, rd:0; store.slm.d32.a32
        send.slm (1|M0)          null     r6      r4:1    0x0            0x02000504           {A@3,$4} // wr:1+1, rd:0; store.slm.d32.a32
        send.slm (1|M0)          null     r7      r4:1    0x0            0x02000504           {A@2,$5} // wr:1+1, rd:0; store.slm.d32.a32
        mov (2|M0)               r81.4<1>:d    r82.0<1;1,0>:d                   {I@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r81.2         L5800                                 {A@1}
L520:
        asr (1|M0)               r41.5<1>:d    r2.6<0;1,0>:d     31:w              
(W)     mul (1|M0)               acc0.0<1>:d   r41.1<0;1,0>:d    r82.2<0;1,0>:uw 
        shr (1|M0)               r41.5<1>:ud   r41.5<0;1,0>:ud   0x1B:uw              {I@2}
(W)     mach (1|M0)              r2.0<1>:d     r41.1<0;1,0>:d    r82.1<0;1,0>:d  
        add (1|M0)               r41.5<1>:d    r2.6<0;1,0>:d     r41.5<0;1,0>:d   {I@2}
        mov (1|M0)               r82.1<1>:d    r2.0<0;1,0>:d                    {I@2}
        asr (1|M0)               r41.5<1>:d    r41.5<0;1,0>:d    5:w               {I@2}
        add (1|M0)               r7.2<1>:d     r82.0<0;1,0>:d    -r82.1<0;1,0>:d  {I@2}
(W)     mul (1|M0)               acc0.0<1>:d   r41.1<0;1,0>:d    r41.10<0;1,0>:uw {I@2}
        mach (1|M0)              r4.0<1>:d     r41.1<0;1,0>:d    r41.5<0;1,0>:d  
(W)     mul (1|M0)               acc0.0<1>:d   r41.1<0;1,0>:d    r41.10<0;1,0>:uw
        mach (1|M0)              r5.0<1>:d     r41.1<0;1,0>:d    r41.5<0;1,0>:d  
        shl (1|M0)               r8.0<1>:d     r7.2<0;1,0>:d     11:w               {Compacted,I@5}
        shl (1|M0)               r1.4<1>:d     r5.0<0;1,0>:d     12:w               {Compacted,I@2}
        asr (1|M0)               r5.1<1>:d     r4.0<0;1,0>:d     31:w               {Compacted}
        addc (1|M0)              r2.0<1>:ud    r2.4<0;1,0>:ud    r1.4<0;1,0>:ud   {AccWrEn,I@2}
        shr (1|M0)               r1.3<1>:ud    r5.0<0;1,0>:ud    0x14:uw             
        shl (1|M0)               r1.2<1>:d     r5.1<0;1,0>:d     12:w               {I@3}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        shl (1|M0)               r5.0<1>:ud    r41.0<0;1,0>:ud   0x7:uw             
        addc (1|M0)              r4.0<1>:ud    r3.0<0;1,0>:ud    r8.0<0;1,0>:ud   {AccWrEn}
        shr (1|M0)               r2.1<1>:ud    r7.2<0;1,0>:ud    0x15:uw             
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@5}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        shl (1|M0)               r1.2<1>:ud    r41.0<0;1,0>:ud   0x6:uw             
        addc (1|M0)              r10.0<1>:ud   r2.0<0;1,0>:ud    r5.0<0;1,0>:ud   {AccWrEn,I@6}
        or (1|M0)                r8.1<1>:d     r2.1<0;1,0>:d     0:w               {Compacted,I@5}
        add3 (1|M0)              r7.1<1>:d     r6.0<0;0>:d       r2.5<0;0>:d       r1.5<0>:d        {I@5}
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r6.0<1>:ud    r4.0<0;1,0>:ud    r1.2<0;1,0>:ud   {AccWrEn,I@5}
        add3 (1|M0)              r4.2<1>:d     r9.0<0;0>:d       r3.1<0;0>:d       r8.1<0>:d        {I@4}
        mov (1|M0)               r16.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r43.0<1>:f    r10.0<0;1,0>:f                   {Compacted}
        add3 (1|M0)              r43.1<1>:d    r11.0<0;0>:d      r7.1<0;0>:d       0:w               {I@4}
        mov (1|M0)               r44.0<1>:f    r6.0<0;1,0>:f                    {Compacted,I@4}
        add3 (1|M0)              r44.1<1>:d    r16.0<0;0>:d      r4.2<0;0>:d       0:w               {I@2}
        send.ugm (1|M0)          r12      r43     null:0  0x0            0x0240D780           {A@2,$6} // wr:1+0, rd:4; load.ugm.d64x16t.a64
        send.ugm (1|M0)          r8       r44     null:0  0x0            0x0220C780           {A@1,$7} // wr:1+0, rd:2; load.ugm.d64x8t.a64
        add (1|M0)               r42.0<1>:ud   r1.2<0;1,0>:ud    0x2000:uw             
        shr (1|M0)               r41.3<1>:ud   r41.0<0;1,0>:ud   0x2:uw             
        and (1|M0)               r41.4<1>:d    r1.0<0;1,0>:uw    3:w              
        add (1|M0)               r41.2<1>:d    r82.0<0;1,0>:d    -r82.1<0;1,0>:d 
        send.slm (1|M0)          null     r5      r12:4   0x0            0x0200D704           {$6} // wr:1+4, rd:0; store.slm.d64x16t.a32
        send.slm (1|M0)          null     r42     r8:2    0x0            0x0200C704           {A@4,$7} // wr:1+2, rd:0; store.slm.d64x8t.a32
(W)     send.slm (1|M0)          r10      r0      null:0  0x0            0x0210001F           {$8} // wr:1+0, rd:1; fence.slm.none.group
(W)     mov (1|M0)               r7.2<1>:f     0.0:f                               {Compacted}
(W)     mov (2|M0)               r7.10<1>:ub   r0.11<0;1,0>:ub                  {F@1}
(W)     mov (8|M0)               null<1>:ud    r10.0<1;1,0>:ud                  {$8.dst}
(W)     send.gtwy (1|M0)         null     r7      null:0  0x0            0x02000004           {A@2,$9} // wr:1+0, rd:0; signal barrier
(W)     sync.bar                             null                            
        cmp (1|M0)    (gt)f0.0   null<1>:d     r2.6<0;1,0>:d     31:w              
        shl (1|M0)               r41.6<1>:ud   r41.3<0;1,0>:ud   0x9:uw             
        shl (1|M0)               r41.7<1>:d    r41.4<0;1,0>:d    9:w              
        mov (16|M0)              r45.0<1>:d    0:w                              
(W)     and (1|M0)               f0.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
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
(~f0.1.any16h) goto (16|M0)                  L2856                  L2856                
L1568:
        asr (1|M0)               r1.3<1>:d     r2.2<0;1,0>:d     31:w              
        shr (1|M0)               r2.1<1>:ud    r2.2<0;1,0>:ud    0x1B:uw             
        mov (1|M0)               r42.5<1>:f    r41.5<0;1,0>:f                   {$7.src}
        shl (1|M0)               r2.0<1>:d     r1.3<0;1,0>:d     5:w               {Compacted,I@2}
        shl (1|M0)               r42.3<1>:d    r2.2<0;1,0>:d     5:w              
        mov (1|M0)               r43.2<2>:f    0.0:f                              
        mov (1|M0)               r43.3<2>:f    0.0:f                              
        mov (2|M0)               r42.1<1>:d    r42.5<1;1,0>:d                   {F@3}
        or (1|M0)                r42.4<1>:d    r2.0<0;1,0>:d     r2.1<0;1,0>:d    {I@3}
        asr (1|M0)               r42.2<1>:d    r41.5<0;1,0>:d    31:w              
        mov (1|M0)               r42.6<1>:d    0:w                              
L1736:
        addc (1|M0)              r2.0<1>:ud    r43.2<0;1,0>:ud   0x1:ud              {AccWrEn,F@2}
(W)     mov (1|M0)               r1.3<1>:hf    0x1:hf                             
        mov (1|M0)               r43.4<1>:d    r2.0<0;1,0>:d                    {I@1}
        mov (1|M0)               r4.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        cmp (1|M0)    (lt)f1.0   null<1>:ud    r43.4<0;1,0>:ud   r42.1<0;1,0>:ud  {I@2}
        add3 (1|M0)              r43.5<1>:d    r4.0<0;0>:d       r43.3<0;0>:d      0:w               {A@2}
        and (1|M0)               r42.7<1>:d    r43.2<0;1,0>:d    1:w              
        cmp (1|M0)    (lt)f0.0   null<1>:d     r43.5<0;1,0>:d    r42.2<0;1,0>:d   {I@2}
(f1.0)  cmp (1|M0)    (eq)f1.0   null<1>:d     r43.5<0;1,0>:d    r42.2<0;1,0>:d  
        sync.allrd                           ($6,$11)                
(f0.0)  sel (1|M0)               r5.0<1>:uw    r1.3<0;1,0>:uw    0x0:uw              {F@1}
(f1.0)  sel (1|M0)               r1.4<1>:uw    r1.3<0;1,0>:uw    0x0:uw             
        or (1|M0)     (ne)f1.1   null<1>:uw    r1.4<0;1,0>:uw    r5.0<0;1,0>:uw   {I@1}
(W)     and (1|M0)               f0.0<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(~f0.0.any16h) goto (16|M0)                  L2408                  L2408                
L1968:
        shl (1|M0)               r1.5<1>:d     r43.4<0;1,0>:d    12:w              
        shl (1|M0)               r1.3<1>:d     r43.5<0;1,0>:d    12:w              
        shr (1|M0)               r1.4<1>:ud    r43.4<0;1,0>:ud   0x14:uw             
        addc (1|M0)              r2.0<1>:ud    r43.0<0;1,0>:ud   r1.5<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r1.6<1>:d     r1.3<0;1,0>:d     r1.4<0;1,0>:d    {I@2}
        mov (1|M0)               r4.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r5.0<1>:f     r2.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r5.1<1>:d     r4.0<0;0>:d       r43.1<0;0>:d      r1.6<0>:d        {I@1}
        mul (1|M0)               acc0.0<1>:ud  r42.3<0;1,0>:ud   r43.8<0;1,0>:uw 
        sync.allrd                           ($9,$10)                
        send.ugm (1|M0)          r6       r5      null:0  0x0            0x0240D780           {A@1,$13} // wr:1+0, rd:4; load.ugm.d64x16t.a64
        mach (1|M0)              r13.0<1>:ud   r42.3<0;1,0>:ud   r43.4<0;1,0>:ud  {AccWrEn}
        xor (1|M0)               r1.2<1>:d     r42.7<0;1,0>:d    1:w              
        mov (1|M0)               r12.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r42.3<0;1,0>:d    r43.10<0;1,0>:uw
        mach (1|M0)              r14.0<1>:d    r42.3<0;1,0>:d    r43.5<0;1,0>:d  
(W)     mul (1|M0)               acc0.0<1>:d   r42.4<0;1,0>:d    r43.8<0;1,0>:uw 
        mach (1|M0)              r2.0<1>:d     r42.4<0;1,0>:d    r43.4<0;1,0>:d  
        addc (1|M0)              r4.0<1>:ud    r44.0<0;1,0>:ud   r12.0<0;1,0>:ud  {AccWrEn,I@5}
        shl (1|M0)               r10.0<1>:d    r1.2<0;1,0>:d     12:w               {Compacted}
        add3 (1|M0)              r1.4<1>:d     r2.0<0;0>:d       r13.0<0;0>:d      r14.0<0>:d       {I@3}
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$13.src}
        mad (1|M0)               r11.0<1>:d    r10.0<0;0>:d      r1.0<0;0>:uw      128:w               {I@3}
        mov (1|M0)               r10.0<1>:f    r4.0<0;1,0>:f                    {Compacted,I@1}
        add3 (1|M0)              r10.1<1>:d    r5.0<0;0>:d       r44.1<0;0>:d      r1.4<0>:d       
        shl (1|M0)               r1.2<1>:d     r1.2<0;1,0>:d     11:w              
        send.slm (1|M0)          null     r11     r6:4    0x0            0x0200D704           {$13} // wr:1+4, rd:0; store.slm.d64x16t.a32
        sync.nop                             null                             {Compacted,$13.src}
        send.ugm (1|M0)          r6       r10     null:0  0x0            0x0220C780           {A@1,$14} // wr:1+0, rd:2; load.ugm.d64x8t.a64
        add (1|M0)               r8.0<1>:d     r1.2<0;1,0>:d     r42.0<0;1,0>:d   {Compacted,I@1}
        sync.nop                             null                             {Compacted,$14.dst}
        send.slm (1|M0)          null     r8      r6:2    0x0            0x0200C704           {A@1,$10} // wr:1+2, rd:0; store.slm.d64x8t.a32
L2408:
        join (16|M0)                         L2856                                
L2424:
        shl (1|M0)               r1.2<1>:d     r42.7<0;1,0>:d    12:w              
        shl (1|M0)               r42.7<1>:d    r42.7<0;1,0>:d    11:w              
        add (1|M0)               r2.0<1>:d     r1.2<0;1,0>:d     r41.6<0;1,0>:d   {I@2}
        bfn.0xFE (1|M0)          r4.0<1>:ud    0x2000:uw               r42.7<0;0>:ud     r41.7<0>:ud      {I@2} // s0|s1|s2
        bfn.0xFE (1|M0)          r30.0<1>:ud   0x2100:uw               r42.7<0;0>:ud     r41.7<0>:ud      // s0|s1|s2
        or (1|M0)                r13.0<1>:ud   r2.0<0;1,0>:ud    0x100:uw              {I@3}
        sync.nop                             null                             {Compacted,$9.src}
        send.slm (1|M0)          r5       r2      null:0  0x0            0x0280E700           {$15} // wr:1+0, rd:8; load.slm.d64x32t.a32
        send.slm (1|M0)          r22      r4      null:0  0x0            0x0280E700           {A@3,$0} // wr:1+0, rd:8; load.slm.d64x32t.a32
        send.slm (1|M0)          r31      r30     null:0  0x0            0x0280E700           {A@2,$1} // wr:1+0, rd:8; load.slm.d64x32t.a32
        send.slm (1|M0)          r14      r13     null:0  0x0            0x0280E700           {A@1,$2} // wr:1+0, rd:8; load.slm.d64x32t.a32
        sync.allwr                           ($0,$1,$2,$11,$15)                
        dpas.8x8 (8|M0)          r69:d         r69:d             r22:b             r5.0:b           {Atomic}
        dpas.8x8 (8|M0)          r61:d         r61:d             r31:b             r5.0:b           {Atomic}
        dpas.8x8 (8|M0)          r53:d         r53:d             r22:b             r14.0:b          {Atomic}
        dpas.8x8 (8|M0)          r45:d         r45:d             r31:b             r14.0:b          {$11}
(W)     send.slm (1|M0)          r39      r0      null:0  0x0            0x0210001F           {$3} // wr:1+0, rd:1; fence.slm.none.group
(W)     mov (1|M0)               r40.2<1>:f    0.0:f                               {Compacted,$12.src}
(W)     mov (2|M0)               r40.10<1>:ub  r0.11<0;1,0>:ub                  {F@1}
(W)     mov (8|M0)               null<1>:ud    r39.0<1;1,0>:ud                  {$3.dst}
(W)     send.gtwy (1|M0)         null     r40     null:0  0x0            0x02000004           {A@2,$12} // wr:1+0, rd:0; signal barrier
(W)     sync.bar                             null                            
        cmp (1|M0)    (eq)f0.1   null<1>:d     r43.5<0;1,0>:d    r42.6<0;1,0>:d  
(f0.1)  cmp (1|M0)    (eq)f0.1   null<1>:d     r43.4<0;1,0>:d    r42.5<0;1,0>:d  
(W)     and (1|M0)               f1.1<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(f1.1.any16h) goto (16|M0)                   L2856                  L2856                
L2824:
(W)     mov (2|M0)               r43.2<1>:ud   r43.4<1;1,0>:ud                 
        goto.b (16|M0)                       L2856                  L1736                
L2856:
        join (16|M0)                         L2872                                
L2872:
        shl (1|M0)               r41.2<1>:d    r41.2<0;1,0>:d    6:w              
        shl (1|M0)               r1.2<1>:d     r41.4<0;1,0>:d    4:w              
        mov (1|M0)               r44.3<1>:d    0:w                              
        or (1|M0)                r44.2<1>:d    r41.2<0;1,0>:d    r1.2<0;1,0>:d    {I@2}
        shl (1|M0)               r2.0<1>:d     r44.3<0;1,0>:d    2:w               {Compacted,I@2}
        shl (1|M0)               r4.0<1>:d     r44.2<0;1,0>:d    2:w               {Compacted,I@2}
        shr (1|M0)               r2.1<1>:ud    r44.2<0;1,0>:ud   0x1E:uw             
        sync.allrd                           ($6,$11)                
        addc (1|M0)              r5.0<1>:ud    r3.2<0;1,0>:ud    r4.0<0;1,0>:ud   {AccWrEn,I@2}
        or (1|M0)                r4.1<1>:d     r2.0<0;1,0>:d     r2.1<0;1,0>:d    {I@2}
        sync.allrd                           ($9,$10)                
        mov (1|M0)               r7.0<1>:f     r5.0<0;1,0>:f                    {Compacted,I@2}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        sync.nop                             null                             {Compacted,$7.src}
        addc (1|M0)              r8.0<1>:ud    r7.0<0;1,0>:ud    0x20:ud              {AccWrEn,F@1}
        add3 (1|M0)              r7.1<1>:d     r6.0<0;0>:d       r3.3<0;0>:d       r4.1<0>:d        {I@2}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r10.0<1>:f    r8.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r10.1<1>:d    r9.0<0;0>:d       r7.1<0;0>:d       0:w               {I@1}
        send.ugm (1|M0)          r77      r7      null:0  0x0            0x0210B780           {$4} // wr:1+0, rd:1; load.ugm.d64x4t.a64
        send.ugm (1|M0)          r78      r10     null:0  0x0            0x0210B780           {A@1,$5} // wr:1+0, rd:1; load.ugm.d64x4t.a64
        shl (1|M0)               r43.6<1>:ud   r41.3<0;1,0>:ud   0x4:uw             
        mov (1|M0)               r43.7<1>:d    0:w                              
L3184:
        shl (1|M0)               r1.3<1>:w     r43.14<0;1,0>:w   5:w               {I@1}
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0x8A0:uw              {A@1}
        sync.nop                             null                             {Compacted,$6.src}
        mov (8|M0)               r4.0<1>:ud    r[a0.0]<1;1,0>:ud                {$11.dst}
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0x7A0:uw              {A@1}
        mov (8|M0)               r5.0<1>:f     r4.0<1;1,0>:d                    {Compacted,I@2}
        sync.nop                             null                             {Compacted,$4.dst}
        mul (8|M0)               acc0.0<1>:f   r77.0<1;1,0>:f    r5.0<1;1,0>:f    {Compacted,F@1}
        mov (8|M0)               r7.0<1>:ud    r[a0.0]<1;1,0>:ud               
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0x6A0:uw              {A@1}
        mov (8|M0)               r8.0<1>:f     r7.0<1;1,0>:d                    {Compacted,I@2}
        mov (8|M0)               r6.0<1>:f     (abs)acc0.0<1;1,0>:f             {Compacted}
        sync.nop                             null                             {Compacted,$5.dst}
        mul (8|M0)               acc0.0<1>:f   r78.0<1;1,0>:f    r8.0<1;1,0>:f    {Compacted,F@2}
        mov (8|M0)               r10.0<1>:ud   r[a0.0]<1;1,0>:ud               
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0x5A0:uw              {A@1}
        mov (8|M0)               r9.0<1>:f     (abs)acc0.0<1;1,0>:f             {Compacted}
        mov (4|M0)               r14.0<1>:ud   r6.4<1;1,0>:ud                   {F@3}
        mov (8|M0)               r11.0<1>:f    r10.0<1;1,0>:d                   {Compacted,I@3}
        mov (8|M0)               r13.0<1>:ud   r[a0.0]<1;1,0>:ud                {$7.src}
        mov (4|M0)               r10.0<1>:ud   r9.4<1;1,0>:ud                   {A@1}
        sel (4|M0)    (ge)f0.0   r7.0<1>:f     r6.0<1;1,0>:f     r14.0<1;1,0>:f   {I@3}
        mul (8|M0)               acc0.0<1>:f   r77.0<1;1,0>:f    r11.0<1;1,0>:f   {Compacted}
        mov (8|M0)               r4.0<1>:f     r13.0<1;1,0>:d                   {Compacted,I@2}
        sel (4|M0)    (ge)f0.0   r11.0<1>:f    r9.0<1;1,0>:f     r10.0<1;1,0>:f   {I@1}
        mov (2|M0)               r2.0<1>:ud    r7.2<1;1,0>:ud                   {F@4}
        mul (8|M0)               acc1.0<1>:f   r78.0<1;1,0>:f    r4.0<1;1,0>:f    {Compacted,F@2}
        mov (2|M0)               r16.0<1>:ud   r11.2<1;1,0>:ud                  {F@2}
        mov (8|M0)               r12.0<1>:f    (abs)acc0.0<1;1,0>:f             {Compacted}
        sel (2|M0)    (ge)f0.0   r8.0<1>:f     r7.0<1;1,0>:f     r2.0<1;1,0>:f    {I@2}
        mov (8|M0)               r5.0<1>:f     (abs)acc1.0<1;1,0>:f             {Compacted}
        sel (2|M0)    (ge)f0.0   r13.0<1>:f    r11.0<1;1,0>:f    r16.0<1;1,0>:f   {I@1}
        mov (4|M0)               r6.0<1>:ud    r12.4<1;1,0>:ud                  {F@4}
        sel (1|M0)    (ge)f0.0   r15.0<1>:f    r8.0<0;1,0>:f     r8.1<0;1,0>:f    {F@3}
        sel (1|M0)    (ge)f0.0   r1.2<1>:f     r13.0<0;1,0>:f    r13.1<0;1,0>:f   {F@2}
        mov (4|M0)               r8.0<1>:ud    r5.4<1;1,0>:ud                   {F@2}
        sel (4|M0)    (ge)f0.0   r14.0<1>:f    r12.0<1;1,0>:f    r6.0<1;1,0>:f    {I@2}
        sel (1|M0)    (ge)f0.0   r4.0<1>:f     r15.0<0;1,0>:f    r1.2<0;1,0>:f    {F@2}
        sel (4|M0)    (ge)f0.0   r9.0<1>:f     r5.0<1;1,0>:f     r8.0<1;1,0>:f    {I@1}
        or (1|M0)                r15.0<1>:ud   r43.7<0;1,0>:ud   r43.6<0;1,0>:ud  {F@2}
        add (1|M0)               r43.7<1>:ud   r43.7<0;1,0>:ud   0x1:uw             
        mov (2|M0)               r2.0<1>:ud    r14.2<1;1,0>:ud                 
        mov (2|M0)               r10.0<1>:ud   r9.2<1;1,0>:ud                   {F@1}
        cmp (1|M0)    (eq)f1.0   null<1>:d     r43.7<0;1,0>:d    8:w               {I@3}
        sel (2|M0)    (ge)f0.0   r7.0<1>:f     r14.0<1;1,0>:f    r2.0<1;1,0>:f    {I@3}
        sel (2|M0)    (ge)f0.0   r11.0<1>:f    r9.0<1;1,0>:f     r10.0<1;1,0>:f   {I@2}
        shl (1|M0)               r15.0<1>:ud   r15.0<0;1,0>:ud   0x2:uw             
        sel (1|M0)    (ge)f0.0   r4.1<1>:f     r7.0<0;1,0>:f     r7.1<0;1,0>:f    {F@2}
        sel (1|M0)    (ge)f0.0   r1.2<1>:f     r11.0<0;1,0>:f    r11.1<0;1,0>:f   {F@2}
(W)     and (1|M0)               f1.0<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
        add (1|M0)               r6.0<1>:ud    r15.0<0;1,0>:ud   0x3000:uw              {I@2}
        sel (1|M0)    (ge)f0.0   r13.0<1>:f    r4.1<0;1,0>:f     r1.2<0;1,0>:f    {F@1}
        add (1|M0)               r15.0<1>:ud   r15.0<0;1,0>:ud   0x3020:uw             
        send.slm (1|M0)          null     r6      r4:1    0x0            0x02000516           {A@2,$6} // wr:1+1, rd:0; atomic_fmax.slm.d32.a32
        send.slm (1|M0)          null     r15     r13:1   0x0            0x02000516           {A@1,$7} // wr:1+1, rd:0; atomic_fmax.slm.d32.a32
(~f1.0.any16h) goto.b (16|M0)                L3960                  L3184                
L3960:
        join (16|M0)                         L3976                                
L3976:
        shl (1|M0)               r41.1<1>:d    r41.1<0;1,0>:d    7:w               {Compacted}
        add (1|M0)               r41.1<1>:d    r41.1<0;1,0>:d    r43.6<0;1,0>:d   {I@1}
        sync.nop                             null                             {Compacted,$6.src}
(W)     send.slm (1|M0)          r4       r0      null:0  0x0            0x0210001F           {$8} // wr:1+0, rd:1; fence.slm.none.group
(W)     mov (1|M0)               r5.2<1>:f     0.0:f                               {Compacted}
(W)     mov (2|M0)               r5.10<1>:ub   r0.11<0;1,0>:ub                  {F@1}
(W)     mov (8|M0)               null<1>:ud    r4.0<1;1,0>:ud                   {$8.dst}
(W)     send.gtwy (1|M0)         null     r5      null:0  0x0            0x02000004           {A@2,$9} // wr:1+0, rd:0; signal barrier
(W)     sync.bar                             null                            
        shl (1|M0)               r41.3<1>:ud   r41.3<0;1,0>:ud   0x6:uw             
        addc (1|M0)              r6.0<1>:ud    r3.6<0;1,0>:ud    r44.2<0;1,0>:ud  {AccWrEn}
        add (1|M0)               r2.0<1>:ud    r41.3<0;1,0>:ud   0x3000:uw              {I@2}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        send.slm (1|M0)          r79      r2      null:0  0x0            0x0220C700           {A@2,$10} // wr:1+0, rd:2; load.slm.d64x8t.a32
        mov (1|M0)               r44.6<1>:d    0:w                              
        mov (1|M0)               r44.4<1>:d    r6.0<0;1,0>:d                   
        add3 (1|M0)              r44.5<1>:d    r7.0<0;0>:d       r3.7<0;0>:d       r44.3<0>:d       {I@3}
L4216:
        shl (1|M0)               r1.3<1>:w     r44.12<0;1,0>:w   2:w               {I@3}
        cmp (1|M0)    (eq)f1.1   null<1>:d     r41.4<0;1,0>:d    0:w              
        add (1|M0)               a0.1<1>:uw    r1.3<0;1,0>:uw    0x9E0:uw              {A@1}
        or (1|M0)                r2.0<1>:uw    r1.3<0;1,0>:uw    0x20:uw              {$10.src}
        add (1|M0)               a0.0<1>:uw    r2.0<0;1,0>:uw    0x9E0:uw              {A@1}
(W)     mov (1|M0)               r4.0<1>:f     r[a0.1]<0;1,0>:f                 {$10.dst}
        cmp (1|M0)    (gt)f0.1   null<1>:f     r[a0.1]<0;1,0>:f  0.0:f               {A@1}
        sync.nop                             null                             {Compacted,A@1}
        math.inv (1|M0)          r81.0<1>:f    r4.0<0;1,0>:f                    {$13}
(W)     mov (1|M0)               r5.0<1>:f     r[a0.0]<0;1,0>:f                 {$9.src}
        cmp (1|M0)    (gt)f0.0   null<1>:f     r[a0.0]<0;1,0>:f  0.0:f               {A@1}
        sync.nop                             null                             {Compacted,A@1}
        sync.nop                             null                             {Compacted,$13.dst}
        mul (1|M0)               r81.0<1>:f    r81.0<0;1,0>:f    127.0:f               {A@1}
        math.inv (1|M0)          r81.1<1>:f    r5.0<0;1,0>:f                    {@3,$14}
(~f0.1) mov (1|M0)               r81.0<1>:ud   0x0:ud                              {F@1}
(W)     and (1|M0)               f0.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
        mul (1|M0)               r81.1<1>:f    r81.1<0;1,0>:f    127.0:f               {$14.dst}
(~f0.0) mov (1|M0)               r81.1<1>:f    0.0:f                              
(f0.1.any16h) goto (16|M0)                   L4544                  L4544                
L4512:
        or (1|M0)                r44.7<1>:d    r44.6<0;1,0>:d    r41.1<0;1,0>:d  
        goto (16|M0)                         L4544                  L4824                
L4544:
        join (16|M0)                         L4824                                
L4560:
        or (1|M0)                r1.2<1>:d     r44.6<0;1,0>:d    r41.1<0;1,0>:d  
        or (1|M0)                r44.7<1>:d    r44.6<0;1,0>:d    r41.1<0;1,0>:d  
        shl (1|M0)               r4.0<1>:d     r1.2<0;1,0>:d     2:w               {Compacted,I@2}
        asr (1|M0)               r1.3<1>:d     r44.7<0;1,0>:d    31:w               {I@2}
        addc (1|M0)              r5.0<1>:ud    r3.4<0;1,0>:ud    r4.0<0;1,0>:ud   {AccWrEn,I@2}
        shr (1|M0)               r1.5<1>:ud    r1.2<0;1,0>:ud    0x1E:uw             
        shl (1|M0)               r1.4<1>:d     r1.3<0;1,0>:d     2:w               {I@3}
        mov (1|M0)               r8.0<1>:f     r5.0<0;1,0>:f                    {Compacted,I@3}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        or (1|M0)                r4.1<1>:d     r1.4<0;1,0>:d     r1.5<0;1,0>:d    {I@2}
        addc (1|M0)              r7.0<1>:ud    r8.0<0;1,0>:ud    0x20:ud              {AccWrEn,F@1}
        add3 (1|M0)              r8.1<1>:d     r6.0<0;0>:d       r3.5<0;0>:d       r4.1<0>:d        {I@2}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$11.src}
        mul (1|M0)               r2.0<1>:f     r[a0.1]<0;1,0>:f  7.874016e-03:f              
        mul (1|M0)               r10.0<1>:f    r[a0.0]<0;1,0>:f  7.874016e-03:f               {A@1}
        mov (1|M0)               r12.0<1>:f    r7.0<0;1,0>:f                    {Compacted,A@1}
        add3 (1|M0)              r12.1<1>:d    r9.0<0;0>:d       r8.1<0;0>:d       0:w               {I@1}
        send.ugm (1|M0)          null     r8      r2:1    0x0            0x04000584           {A@3,$15} // wr:2+1, rd:0; store.ugm.d32.a64
        send.ugm (1|M0)          null     r12     r10:1   0x0            0x04000584           {A@1,$0} // wr:2+1, rd:0; store.ugm.d32.a64
L4824:
        join (16|M0)                         L5728                                
L4840:
        shl (1|M0)               r1.3<1>:w     r44.12<0;1,0>:w   5:w              
        mul (1|M0)               acc0.0<1>:d   r44.7<0;1,0>:d    r2.4<0;1,0>:uw  
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0x8A0:uw              {A@1}
        mach (1|M0)              r11.0<1>:d    r44.7<0;1,0>:d    r2.2<0;1,0>:d    {AccWrEn}
        or (1|M0)                r44.7<1>:d    r44.7<0;1,0>:d    8:w              
        mov (1|M0)               r10.0<1>:d    acc0.0<0;1,0>:d                  {$0.src}
        mov (8|M0)               r4.0<1>:ud    r[a0.0]<1;1,0>:ud               
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0x7A0:uw              {A@1}
        mov (8|M0)               r5.0<1>:f     r4.0<1;1,0>:d                    {Compacted,I@2}
        addc (1|M0)              r2.0<1>:ud    r44.4<0;1,0>:ud   r10.0<0;1,0>:ud  {AccWrEn,$15.src}
        mul (8|M0)               acc2.0<1>:f   r77.0<1;1,0>:f    r5.0<1;1,0>:f    {Compacted,F@1}
        mov (8|M0)               r6.0<1>:ud    r[a0.0]<1;1,0>:ud               
        mul (8|M0)               acc2.0<1>:f   r81.0<0;1,0>:f    acc2.0<1;1,0>:f  {A@1}
        mov (8|M0)               r7.0<1>:f     r6.0<1;1,0>:d                    {Compacted,I@1}
        rnde (8|M0)              acc2.0<1>:f   acc2.0<1;1,0>:f                 
        mul (8|M0)               acc3.0<1>:f   r78.0<1;1,0>:f    r7.0<1;1,0>:f    {Compacted,F@2}
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0x6A0:uw              {A@1}
        sel (8|M0)    (ge)f0.0   acc2.0<1>:f   acc2.0<1;1,0>:f   -127.0:f              
        mul (8|M0)               acc3.0<1>:f   r81.0<0;1,0>:f    acc3.0<1;1,0>:f 
        sel (8|M0)    (lt)f0.0   r5.0<1>:f     acc2.0<1;1,0>:f   127.0:f              
        rnde (8|M0)              acc2.0<1>:f   acc3.0<1;1,0>:f                 
        mov (8|M0)               r4.0<1>:d     r5.0<1;1,0>:f                    {Compacted,F@2}
        sel (8|M0)    (ge)f0.0   acc2.0<1>:f   acc2.0<1;1,0>:f   -127.0:f              
        mov (8|M0)               r5.0<1>:ud    r[a0.0]<1;1,0>:ud               
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0x5A0:uw              {A@1}
        sel (8|M0)    (lt)f0.0   r7.0<1>:f     acc2.0<1;1,0>:f   127.0:f              
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (8|M0)               r8.0<1>:d     r7.0<1;1,0>:f                    {Compacted,F@1}
        mov (8|M0)               r7.0<1>:ud    r[a0.0]<1;1,0>:ud               
        sync.nop                             null                             {Compacted,A@1}
        sync.nop                             null                             {Compacted,$11.src}
        mov (8|M0)               r9.0<1>:b     r4.0<4;1,0>:b                    {A@1}
        add3 (1|M0)              r12.1<1>:d    r6.0<0;0>:d       r44.5<0;0>:d      r11.0<0>:d       {I@4}
        mov (8|M0)               r4.0<1>:f     r5.0<1;1,0>:d                    {Compacted,I@2}
        mov (8|M0)               r6.0<1>:f     r7.0<1;1,0>:d                    {Compacted,I@1}
        mul (8|M0)               acc0.0<1>:f   r77.0<1;1,0>:f    r4.0<1;1,0>:f    {Compacted,F@2}
        mul (8|M0)               acc1.0<1>:f   r78.0<1;1,0>:f    r6.0<1;1,0>:f    {Compacted,F@2}
        mul (8|M0)               r4.0<1>:f     r81.1<0;1,0>:f    acc0.0<1;1,0>:f 
        mul (8|M0)               r6.0<1>:f     r81.1<0;1,0>:f    acc1.0<1;1,0>:f 
        mul (1|M0)               acc0.0<1>:d   r44.7<0;1,0>:d    r2.4<0;1,0>:uw   {A@1}
        add (1|M0)               r44.6<1>:d    r44.6<0;1,0>:d    1:w              
        rnde (8|M0)              acc2.0<1>:f   r4.0<1;1,0>:f                   
        rnde (8|M0)              acc3.0<1>:f   r6.0<1;1,0>:f                   
        mach (1|M0)              r11.0<1>:d    r44.7<0;1,0>:d    r2.2<0;1,0>:d    {AccWrEn}
        cmp (1|M0)    (eq)f1.0   null<1>:d     r44.6<0;1,0>:d    8:w               {I@2}
        sel (8|M0)    (ge)f0.0   acc2.0<1>:f   acc2.0<1;1,0>:f   -127.0:f              
        sel (8|M0)    (ge)f0.0   acc3.0<1>:f   acc3.0<1;1,0>:f   -127.0:f              
        mov (1|M0)               r10.0<1>:d    acc0.0<0;1,0>:d                 
        mov (1|M0)               r12.0<1>:f    r2.0<0;1,0>:f                    {Compacted}
        sel (8|M0)    (lt)f0.0   r4.0<1>:f     acc2.0<1;1,0>:f   127.0:f              
        sel (8|M0)    (lt)f0.0   r6.0<1>:f     acc3.0<1;1,0>:f   127.0:f              
        addc (1|M0)              r2.0<1>:ud    r44.4<0;1,0>:ud   r10.0<0;1,0>:ud  {AccWrEn,A@1}
        mov (8|M0)               r9.8<1>:b     r8.0<4;1,0>:b                   
(W)     and (1|M0)               f0.0<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
        mov (8|M0)               r5.0<1>:d     r4.0<1;1,0>:f                    {Compacted,F@2}
        mov (8|M0)               r8.0<1>:d     r6.0<1;1,0>:f                    {Compacted,F@1}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        send.ugm (1|M0)          null     r12     r9:1    0x0            0x02009784           {A@5,$1} // wr:1+1, rd:0; store.ugm.d64x2t.a64
        sync.nop                             null                             {Compacted,$1.src}
        mov (8|M0)               r9.0<1>:b     r5.0<4;1,0>:b                    {I@3}
        mov (8|M0)               r9.8<1>:b     r8.0<4;1,0>:b                    {I@3}
        mov (1|M0)               r12.0<1>:f    r2.0<0;1,0>:f                    {Compacted}
        add3 (1|M0)              r12.1<1>:d    r7.0<0;0>:d       r44.5<0;0>:d      r11.0<0>:d       {I@3}
        send.ugm (1|M0)          null     r12     r9:1    0x0            0x02009784           {A@1,$11} // wr:1+1, rd:0; store.ugm.d64x2t.a64
(~f0.0.any16h) goto.b (16|M0)                L5728                  L4216                
L5728:
        join (16|M0)                         L5744                                
L5744:
(W)     mov (8|M0)               r127.0<1>:f   r0.0<1;1,0>:f                    {Compacted}
(W)     send.ugm (1|M0)          r4       r0      null:0  0x0            0x0210641F           {$2} // wr:1+0, rd:1; fence invalid flush type scoped to tile
(W)     mov (8|M0)               null<1>:ud    r4.0<1;1,0>:ud                   {$2.dst}
(W)     send.gtwy (1|M0)         null     r127    null:0  0x0            0x02000010           {EOT,A@1} // wr:1+0, rd:0; end of thread
L5800:
        mov (1|M0)               r1.2<1>:d     cr0.0<0;1,0>:ud                  {A@1}
        and (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   -1265:w               {A@1}
        or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   1264:w               {A@1}
        mov (1|M0)               r1.5<1>:f     (abs)r81.5<0;1,0>:d              {A@1}
        mov (1|M0)               r4.2<1>:f     0xB4C00000:f                               {Compacted,I@4}
        math.inv (1|M0)          r4.1<1>:f     r1.5<0;1,0>:f                    {@2,$3}
        mov (1|M0)               r2.1<1>:f     (abs)r81.4<0;1,0>:d             
        sync.nop                             null                             {Compacted,$3.dst}
        mad (1|M0)               r4.1<1>:f     r4.1<0;0>:f       r4.2<0;0>:f       r4.1<0>:f        {F@2}
        mov (1|M0)               r1.3<1>:d     (abs)r81.4<0;1,0>:d             
        mov (1|M0)               r1.4<1>:d     (abs)r81.5<0;1,0>:d             
        mov (1|M0)               r1.6<1>:ud    r1.5<0;1,0>:f                   
        mov (1|M0)               r2.3<1>:ud    r2.1<0;1,0>:f                    {F@2}
        mul (1|M0)               r5.0<1>:f     r4.1<0;1,0>:f     r2.1<0;1,0>:f    {F@1}
        add (1|M0)               r1.6<1>:ud    r1.4<0;1,0>:ud    -r1.6<0;1,0>:ud  {I@2}
        add (1|M0)               r2.3<1>:ud    r1.3<0;1,0>:ud    -r2.3<0;1,0>:ud  {I@2}
        mov (1|M0)               r6.0<1>:ud    r5.0<0;1,0>:f                    {F@1}
        mov (1|M0)               r2.0<1>:f     r1.6<0;1,0>:ud                   {Compacted,I@3}
        mov (1|M0)               r4.0<1>:f     r2.3<0;1,0>:ud                   {Compacted,I@2}
        mov (1|M0)               r6.1<1>:f     r6.0<0;1,0>:ud                   {Compacted,I@1}
        xor (1|M0)               r81.5<1>:d    r81.5<0;1,0>:d    r81.4<0;1,0>:d  
        mad (1|M0)               r2.1<1>:f     r2.1<0;0>:f       r6.1<0;0>:f       -r1.5<0>:f       {F@1}
        mad (1|M0)               r6.1<1>:f     r4.0<0;0>:f       r6.1<0;0>:f       -r2.0<0>:f      
(W)     mov (1|M0)               r5.0<1>:hf    0x1:hf                             
        add (1|M0)               r2.1<1>:f     r2.1<0;1,0>:f     r6.1<0;1,0>:f    {F@2}
        asr (1|M0)               r81.5<1>:d    r81.5<0;1,0>:d    31:w               {I@1}
        mul (1|M0)               r4.1<1>:f     r4.1<0;1,0>:f     r2.1<0;1,0>:f    {F@1}
        mov (1|M0)               r7.0<1>:ud    r4.1<0;1,0>:f                    {F@1}
        add (1|M0)               r6.0<1>:ud    r6.0<0;1,0>:ud    r7.0<0;1,0>:ud   {Compacted,I@1}
(W)     mul (1|M0)               acc0.0<1>:ud  r6.0<0;1,0>:ud    r1.8<0;1,0>:uw   {I@1}
        mach (1|M0)              r8.0<1>:ud    r6.0<0;1,0>:ud    r1.4<0;1,0>:ud   {Compacted}
        add (1|M0)               r1.3<1>:ud    r1.3<0;1,0>:ud    -r8.0<0;1,0>:ud  {Compacted,I@1}
        cmp (1|M0)    (ge)f1.1   null<1>:ud    r1.3<0;1,0>:ud    r1.4<0;1,0>:ud   {I@1}
(f1.1)  sel (1|M0)               r9.0<1>:d     r5.0<0;1,0>:w     0:w              
        add3 (1|M0)              r6.0<1>:d     r6.0<0;0>:d       r81.5<0;0>:d      r9.0<0>:d        {I@1}
        xor (1|M0)               r41.1<1>:d    r6.0<0;1,0>:d     r81.5<0;1,0>:d   {I@1}
        mov (1|M0)               cr0.0<1>:ud   r1.2<0;1,0>:d                    {A@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        ret (16|M0)                          r81.2                            {A@1}
L6376:
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
