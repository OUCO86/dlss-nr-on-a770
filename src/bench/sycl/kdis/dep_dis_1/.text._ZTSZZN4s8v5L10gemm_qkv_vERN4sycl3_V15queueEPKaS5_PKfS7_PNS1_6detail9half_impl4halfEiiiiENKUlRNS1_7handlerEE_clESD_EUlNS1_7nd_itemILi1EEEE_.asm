L0:
(W)     mov (8|M0)               r127.0<1>:ud  0x0:ud                              {A@1}
(W)     and (1|M0)               r127.2<1>:ud  r0.0<0;1,0>:ud    0xFFFFFFC0:ud             
(W)     and (1|M0)               r127.0<1>:uw  r0.4<0;1,0>:uw    0xFF:uw             
(W)     add (1|M0)               r127.2<1>:ud  r127.2<0;1,0>:ud  0x60:ud              {I@2}
(W)     mad (1|M0)               r127.2<1>:ud  r127.2<0;0>:ud    r127.0<0;0>:uw    0x20:uw              {I@1}
(W)     send.dc0 (8|M0)          r1       r127    null:0  0x0            0x021842FD           {A@1,$0} // wr:1h+0, rd:1; oword aligned block read x2
        nop                    
        nop                    
(W)     mov (8|M0)               r127.0<1>:ud  0x0:ud                              {$0.src}
(W)     and (1|M0)               r127.2<1>:ud  r0.0<0;1,0>:ud    0xFFFFFFC0:ud             
(W)     send.dc0 (8|M0)          r2       r127    null:0  0x0            0x022843FD           {A@1,$1} // wr:1h+0, rd:2; oword aligned block read x4
(W)     add (1|M0)               r127.2<1>:ud  r127.2<0;1,0>:ud  0x40:uw              {$1.src}
(W)     send.dc0 (8|M0)          r4       r127    null:0  0x0            0x021842FD           {A@1,$2} // wr:1h+0, rd:1; oword aligned block read x2
        and (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   -1265:w               {A@1}
        or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   1216:w               {A@1}
        mov (1|M0)               r42.0<1>:d    r0.1<0;1,0>:ud                   {A@1}
        mov (1|M0)               r42.1<1>:d    r1.0<0;1,0>:uw                   {$0.dst}
        mov (1|M0)               r88.5<1>:d    r2.2<0;1,0>:d                    {$1.dst}
        mov (1|M0)               r88.4<1>:d    r42.0<0;1,0>:d                   {I@3}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r86.6         L9192                                 {A@1}
L352:
        asr (1|M0)               r42.3<1>:d    r2.6<0;1,0>:d     31:w              
(W)     mul (1|M0)               acc0.0<1>:d   r86.4<0;1,0>:d    r2.4<0;1,0>:uw  
        shr (1|M0)               r42.3<1>:ud   r42.3<0;1,0>:ud   0x1B:uw              {I@2}
        mach (1|M0)              r2.0<1>:d     r86.4<0;1,0>:d    r2.2<0;1,0>:d   
        add (1|M0)               r42.3<1>:d    r2.6<0;1,0>:d     r42.3<0;1,0>:d   {I@2}
        add (1|M0)               r7.1<1>:d     r42.0<0;1,0>:d    -r2.0<0;1,0>:d   {Compacted,I@2}
        asr (1|M0)               r42.3<1>:d    r42.3<0;1,0>:d    5:w               {Compacted,I@2}
        shl (1|M0)               r9.0<1>:d     r7.1<0;1,0>:d     11:w               {Compacted,I@2}
(W)     mul (1|M0)               acc0.0<1>:d   r86.4<0;1,0>:d    r42.6<0;1,0>:uw  {I@2}
        mach (1|M0)              r5.0<1>:d     r86.4<0;1,0>:d    r42.3<0;1,0>:d  
(W)     mul (1|M0)               acc0.0<1>:d   r86.4<0;1,0>:d    r42.6<0;1,0>:uw 
        mach (1|M0)              r6.0<1>:d     r86.4<0;1,0>:d    r42.3<0;1,0>:d  
        asr (1|M0)               r6.1<1>:d     r5.0<0;1,0>:d     31:w               {Compacted,I@3}
        shl (1|M0)               r1.4<1>:d     r6.0<0;1,0>:d     12:w               {Compacted,I@2}
        shr (1|M0)               r1.3<1>:ud    r6.0<0;1,0>:ud    0x14:uw             
        addc (1|M0)              r7.0<1>:ud    r2.4<0;1,0>:ud    r1.4<0;1,0>:ud   {AccWrEn,I@2}
        shl (1|M0)               r1.2<1>:d     r6.1<0;1,0>:d     12:w              
        shl (1|M0)               r6.0<1>:ud    r42.1<0;1,0>:ud   0x7:uw             
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r5.0<1>:ud    r3.0<0;1,0>:ud    r9.0<0;1,0>:ud   {AccWrEn}
        shr (1|M0)               r3.3<1>:ud    r7.1<0;1,0>:ud    0x15:uw             
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@5}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        shl (1|M0)               r1.2<1>:ud    r42.1<0;1,0>:ud   0x6:uw             
        addc (1|M0)              r11.0<1>:ud   r7.0<0;1,0>:ud    r6.0<0;1,0>:ud   {AccWrEn,I@7}
        add (1|M0)               r42.2<1>:d    r42.0<0;1,0>:d    -r2.0<0;1,0>:d   {Compacted}
        or (1|M0)                r9.1<1>:d     r3.3<0;1,0>:d     0:w               {I@6}
        mov (1|M0)               r12.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r2.0<1>:ud    r5.0<0;1,0>:ud    r1.2<0;1,0>:ud   {AccWrEn,I@5}
        add3 (1|M0)              r4.7<1>:d     r8.0<0;0>:d       r2.5<0;0>:d       r1.5<0>:d       
        add3 (1|M0)              r5.2<1>:d     r10.0<0;0>:d      r3.1<0;0>:d       r9.1<0>:d        {I@4}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r44.0<1>:f    r11.0<0;1,0>:f                   {Compacted}
        mov (1|M0)               r45.0<1>:f    r2.0<0;1,0>:f                    {Compacted,I@4}
        add3 (1|M0)              r44.1<1>:d    r12.0<0;0>:d      r4.7<0;0>:d       0:w               {I@3}
        add3 (1|M0)              r45.1<1>:d    r8.0<0;0>:d       r5.2<0;0>:d       0:w               {I@2}
        send.ugm (1|M0)          r13      r44     null:0  0x0            0x0240D780           {A@2,$3} // wr:1+0, rd:4; load.ugm.d64x16t.a64
        send.ugm (1|M0)          r9       r45     null:0  0x0            0x0220C780           {A@1,$4} // wr:1+0, rd:2; load.ugm.d64x8t.a64
        add (1|M0)               r43.0<1>:ud   r1.2<0;1,0>:ud    0x2000:uw             
        shr (1|M0)               r44.4<1>:ud   r42.1<0;1,0>:ud   0x2:uw              {$3.src}
        and (1|M0)               r44.5<1>:d    r1.0<0;1,0>:uw    3:w              
        shl (1|M0)               r42.2<1>:d    r42.2<0;1,0>:d    6:w              
        send.slm (1|M0)          null     r6      r13:4   0x0            0x0200D704           {$3} // wr:1+4, rd:0; store.slm.d64x16t.a32
        send.slm (1|M0)          null     r43     r9:2    0x0            0x0200C704           {A@4,$4} // wr:1+2, rd:0; store.slm.d64x8t.a32
(W)     send.slm (1|M0)          r7       r0      null:0  0x0            0x0210001F           {$5} // wr:1+0, rd:1; fence.slm.none.group
(W)     mov (1|M0)               r11.2<1>:f    0.0:f                               {Compacted}
(W)     mov (2|M0)               r11.10<1>:ub  r0.11<0;1,0>:ub                  {F@1}
(W)     mov (8|M0)               null<1>:ud    r7.0<1;1,0>:ud                   {$5.dst}
(W)     send.gtwy (1|M0)         null     r11     null:0  0x0            0x02000004           {A@2,$6} // wr:1+0, rd:0; signal barrier
(W)     sync.bar                             null                            
        cmp (1|M0)    (gt)f1.1   null<1>:d     r2.6<0;1,0>:d     31:w              
        shl (1|M0)               r42.4<1>:ud   r44.4<0;1,0>:ud   0x9:uw             
        shl (1|M0)               r42.5<1>:d    r44.5<0;1,0>:d    9:w              
        mov (16|M0)              r46.0<1>:d    0:w                              
(W)     and (1|M0)               f1.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
        mov (16|M0)              r48.0<1>:d    0:w                              
        mov (16|M0)              r50.0<1>:d    0:w                              
        mov (16|M0)              r52.0<1>:d    0:w                              
        mov (16|M0)              r54.0<1>:d    0:w                              
        mov (16|M0)              r56.0<1>:d    0:w                              
        mov (16|M0)              r58.0<1>:d    0:w                              
        mov (16|M0)              r60.0<1>:d    0:w                              
        mov (16|M0)              r62.0<1>:d    0:w                              
        mov (16|M0)              r64.0<1>:d    0:w                              
        mov (16|M0)              r66.0<1>:d    0:w                              
        mov (16|M0)              r68.0<1>:d    0:w                              
        mov (16|M0)              r70.0<1>:d    0:w                              
        mov (16|M0)              r72.0<1>:d    0:w                              
        mov (16|M0)              r74.0<1>:d    0:w                              
        mov (16|M0)              r76.0<1>:d    0:w                              
(~f1.1.any16h) goto (16|M0)                  L2656                  L2656                
L1384:
        shr (1|M0)               r1.2<1>:ud    r2.6<0;1,0>:ud    0x1B:uw             
        mov (1|M0)               r43.3<1>:f    r42.3<0;1,0>:f                   {Compacted,$4.src}
        shl (1|M0)               r43.1<1>:d    r2.6<0;1,0>:d     5:w              
        mov (1|M0)               r43.6<2>:f    0.0:f                              
        mov (1|M0)               r43.7<2>:f    0.0:f                              
        or (1|M0)                r43.2<1>:d    r1.2<0;1,0>:d     0:w               {I@2}
        mov (2|M0)               r42.6<1>:d    r43.3<1;1,0>:d                   {F@3}
        asr (1|M0)               r42.7<1>:d    r42.3<0;1,0>:d    31:w              
        mov (1|M0)               r43.4<1>:d    0:w                              
L1520:
        addc (1|M0)              r2.0<1>:ud    r43.6<0;1,0>:ud   0x1:ud              {AccWrEn,F@2}
(W)     mov (1|M0)               r1.3<1>:hf    0x1:hf                             
        mov (1|M0)               r44.2<1>:d    r2.0<0;1,0>:d                    {I@1}
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        cmp (1|M0)    (lt)f0.1   null<1>:ud    r44.2<0;1,0>:ud   r42.6<0;1,0>:ud  {I@2}
        add3 (1|M0)              r44.3<1>:d    r5.0<0;0>:d       r43.7<0;0>:d      0:w               {A@2}
        and (1|M0)               r43.5<1>:d    r43.6<0;1,0>:d    1:w              
        cmp (1|M0)    (lt)f1.0   null<1>:d     r44.3<0;1,0>:d    r42.7<0;1,0>:d   {I@2}
(f0.1)  cmp (1|M0)    (eq)f0.1   null<1>:d     r44.3<0;1,0>:d    r42.7<0;1,0>:d  
(f1.0)  sel (1|M0)               r3.6<1>:uw    r1.3<0;1,0>:uw    0x0:uw              {F@1}
(f0.1)  sel (1|M0)               r1.4<1>:uw    r1.3<0;1,0>:uw    0x0:uw             
        or (1|M0)     (ne)f1.0   null<1>:uw    r1.4<0;1,0>:uw    r3.6<0;1,0>:uw   {I@1}
(W)     and (1|M0)               f1.0<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
(~f1.0.any16h) goto (16|M0)                  L2192                  L2192                
L1736:
        shl (1|M0)               r1.5<1>:d     r44.2<0;1,0>:d    12:w              
        shl (1|M0)               r1.3<1>:d     r44.3<0;1,0>:d    12:w               {Compacted}
        shr (1|M0)               r1.4<1>:ud    r44.2<0;1,0>:ud   0x14:uw             
        addc (1|M0)              r2.0<1>:ud    r44.0<0;1,0>:ud   r1.5<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r1.6<1>:d     r1.3<0;1,0>:d     r1.4<0;1,0>:d    {I@2}
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        sync.allrd                           ($3,$8)                
        mov (1|M0)               r6.0<1>:f     r2.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r6.1<1>:d     r5.0<0;0>:d       r44.1<0;0>:d      r1.6<0>:d        {I@1}
        mul (1|M0)               acc0.0<1>:ud  r43.1<0;1,0>:ud   r44.4<0;1,0>:uw 
        sync.nop                             null                             {Compacted,$9.src}
        send.ugm (1|M0)          r7       r6      null:0  0x0            0x0240D780           {A@1,$10} // wr:1+0, rd:4; load.ugm.d64x16t.a64
        mach (1|M0)              r13.0<1>:ud   r43.1<0;1,0>:ud   r44.2<0;1,0>:ud  {AccWrEn}
        xor (1|M0)               r1.2<1>:d     r43.5<0;1,0>:d    1:w              
        mov (1|M0)               r12.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r43.1<0;1,0>:d    r44.6<0;1,0>:uw 
        mach (1|M0)              r14.0<1>:d    r43.1<0;1,0>:d    r44.3<0;1,0>:d  
(W)     mul (1|M0)               acc0.0<1>:d   r43.2<0;1,0>:d    r44.4<0;1,0>:uw 
        mach (1|M0)              r2.0<1>:d     r43.2<0;1,0>:d    r44.2<0;1,0>:d  
        addc (1|M0)              r5.0<1>:ud    r45.0<0;1,0>:ud   r12.0<0;1,0>:ud  {AccWrEn,I@5}
        shl (1|M0)               r3.3<1>:d     r1.2<0;1,0>:d     12:w              
        add3 (1|M0)              r1.4<1>:d     r2.0<0;0>:d       r13.0<0;0>:d      r14.0<0>:d       {I@3}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$10.src}
        mov (1|M0)               r15.0<1>:f    r5.0<0;1,0>:f                    {Compacted,I@4}
        sync.nop                             null                             {Compacted,$6.src}
        mad (1|M0)               r11.0<1>:d    r3.3<0;0>:d       r1.0<0;0>:uw      128:w               {I@3}
        add3 (1|M0)              r15.1<1>:d    r6.0<0;0>:d       r45.1<0;0>:d      r1.4<0>:d        {I@2}
        shl (1|M0)               r1.2<1>:d     r1.2<0;1,0>:d     11:w              
        send.slm (1|M0)          null     r11     r7:4    0x0            0x0200D704           {A@3,$10} // wr:1+4, rd:0; store.slm.d64x16t.a32
        sync.nop                             null                             {Compacted,$10.src}
        send.ugm (1|M0)          r7       r15     null:0  0x0            0x0220C780           {A@1,$11} // wr:1+0, rd:2; load.ugm.d64x8t.a64
        add (1|M0)               r9.0<1>:d     r1.2<0;1,0>:d     r43.0<0;1,0>:d   {Compacted,I@1}
        sync.nop                             null                             {Compacted,$11.dst}
        send.slm (1|M0)          null     r9      r7:2    0x0            0x0200C704           {A@1,$9} // wr:1+2, rd:0; store.slm.d64x8t.a32
L2192:
        join (16|M0)                         L2656                                
L2208:
        shl (1|M0)               r1.2<1>:d     r43.5<0;1,0>:d    12:w              
        shl (1|M0)               r43.5<1>:d    r43.5<0;1,0>:d    11:w              
        add (1|M0)               r2.0<1>:d     r1.2<0;1,0>:d     r42.4<0;1,0>:d   {I@2}
        bfn.0xFE (1|M0)          r5.0<1>:ud    0x2000:uw               r43.5<0;0>:ud     r42.5<0>:ud      {I@2} // s0|s1|s2
        bfn.0xFE (1|M0)          r31.0<1>:ud   0x2100:uw               r43.5<0;0>:ud     r42.5<0>:ud      // s0|s1|s2
        sync.nop                             null                             {Compacted,$3.src}
        or (1|M0)                r14.0<1>:ud   r2.0<0;1,0>:ud    0x100:uw              {I@3}
        sync.allrd                           ($6,$8)                
        send.slm (1|M0)          r6       r2      null:0  0x0            0x0280E700           {$12} // wr:1+0, rd:8; load.slm.d64x32t.a32
        send.slm (1|M0)          r23      r5      null:0  0x0            0x0280E700           {A@3,$13} // wr:1+0, rd:8; load.slm.d64x32t.a32
        send.slm (1|M0)          r32      r31     null:0  0x0            0x0280E700           {A@2,$14} // wr:1+0, rd:8; load.slm.d64x32t.a32
        send.slm (1|M0)          r15      r14     null:0  0x0            0x0280E700           {A@1,$15} // wr:1+0, rd:8; load.slm.d64x32t.a32
        sync.allwr                           ($8,$12,$13,$14,$15)                
        dpas.8x8 (8|M0)          r70:d         r70:d             r23:b             r6.0:b           {Atomic}
        dpas.8x8 (8|M0)          r62:d         r62:d             r32:b             r6.0:b           {Atomic}
        dpas.8x8 (8|M0)          r54:d         r54:d             r23:b             r15.0:b          {Atomic}
        dpas.8x8 (8|M0)          r46:d         r46:d             r32:b             r15.0:b          {$8}
(W)     send.slm (1|M0)          r40      r0      null:0  0x0            0x0210001F           {$0} // wr:1+0, rd:1; fence.slm.none.group
(W)     mov (1|M0)               r41.2<1>:f    0.0:f                               {Compacted,$7.src}
(W)     mov (2|M0)               r41.10<1>:ub  r0.11<0;1,0>:ub                  {F@1}
(W)     mov (8|M0)               null<1>:ud    r40.0<1;1,0>:ud                  {$0.dst}
(W)     send.gtwy (1|M0)         null     r41     null:0  0x0            0x02000004           {A@2,$7} // wr:1+0, rd:0; signal barrier
(W)     sync.bar                             null                            
        cmp (1|M0)    (eq)f0.0   null<1>:d     r44.3<0;1,0>:d    r43.4<0;1,0>:d  
(f0.0)  cmp (1|M0)    (eq)f0.0   null<1>:d     r44.2<0;1,0>:d    r43.3<0;1,0>:d  
(W)     and (1|M0)               f0.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
(f0.1.any16h) goto (16|M0)                   L2656                  L2656                
L2624:
(W)     mov (2|M0)               r43.6<1>:ud   r44.2<1;1,0>:ud                 
        goto.b (16|M0)                       L2656                  L1520                
L2656:
        join (16|M0)                         L2672                                
L2672:
        shl (1|M0)               r86.4<1>:d    r86.4<0;1,0>:d    7:w              
        shl (1|M0)               r44.4<1>:ud   r44.4<0;1,0>:ud   0x4:uw             
        shl (1|M0)               r44.5<1>:d    r44.5<0;1,0>:d    4:w              
        mov (1|M0)               r44.6<1>:f    r3.6<0;1,0>:f                   
        asr (1|M0)               r44.7<1>:d    r3.6<0;1,0>:d     31:w              
        mov (1|M0)               r45.2<1>:d    0:w                              
        add (1|M0)               r44.4<1>:d    r86.4<0;1,0>:d    r44.4<0;1,0>:d   {I@4}
L2784:
        or (1|M0)                r45.3<1>:d    r45.2<0;1,0>:d    r44.4<0;1,0>:d   {I@1}
        cmp (1|M0)    (lt)f0.1   null<1>:d     r45.3<0;1,0>:d    r3.2<0;1,0>:d    {I@1}
        or (1|M0)                r45.4<1>:d    r45.3<0;1,0>:d    8:w              
(W)     and (1|M0)               f0.0<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(~f0.0.any16h) goto (16|M0)                  L5920                  L5920                
L2864:
        asr (1|M0)               r1.3<1>:d     r45.3<0;1,0>:d    31:w               {Compacted}
        shl (1|M0)               r4.6<1>:d     r45.3<0;1,0>:d    2:w              
        shr (1|M0)               r2.1<1>:ud    r45.3<0;1,0>:ud   0x1E:uw             
        shl (1|M0)               r2.0<1>:d     r1.3<0;1,0>:d     2:w               {Compacted,I@3}
        addc (1|M0)              r5.0<1>:ud    r3.4<0;1,0>:ud    r4.6<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r4.7<1>:d     r2.0<0;1,0>:d     r2.1<0;1,0>:d    {I@2}
        sync.nop                             null                             {Compacted,$8.src}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$3.src}
        sync.nop                             null                             {Compacted,$9.src}
        mov (1|M0)               r8.0<1>:f     r5.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r8.1<1>:d     r6.0<0;0>:d       r3.5<0;0>:d       r4.7<0>:d        {I@1}
        mov (1|M0)               r88.4<1>:d    r45.3<0;1,0>:d                  
        send.ugm (1|M0)          r78      r8      null:0  0x0            0x04100580           {A@1,$11} // wr:2+0, rd:1; load.ugm.d32.a64
        mov (1|M0)               r88.5<1>:d    r3.6<0;1,0>:d                   
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r86.6         L9192                                 {A@1}
L3088:
        shl (1|M0)               r1.3<1>:w     r45.4<0;1,0>:w    5:w              
(W)     mul (1|M0)               acc0.0<1>:d   r86.4<0;1,0>:d    r3.12<0;1,0>:uw 
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0x8C0:uw              {A@1}
        mach (1|M0)              r2.0<1>:d     r86.4<0;1,0>:d    r3.6<0;1,0>:d   
        mul (1|M0)               acc0.0<1>:d   r86.4<0;1,0>:d    r4.4<0;1,0>:uw  
        mach (1|M0)              r8.0<1>:d     r86.4<0;1,0>:d    r4.2<0;1,0>:d    {AccWrEn}
        mov (8|M0)               r5.0<1>:ud    r[a0.0]<1;1,0>:ud               
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0x7C0:uw              {A@1}
        add (1|M0)               r1.2<1>:d     r45.3<0;1,0>:d    -r2.0<0;1,0>:d   {I@5}
        mov (1|M0)               r7.0<1>:d     acc0.0<0;1,0>:d                 
        mov (1|M0)               r45.7<1>:d    0:w                              
        mov (8|M0)               r6.0<1>:ud    r[a0.0]<1;1,0>:ud               
        add (1|M0)               r78.1<1>:d    r45.3<0;1,0>:d    -r2.0<0;1,0>:d   {A@1}
        mov (1|M0)               r45.6<1>:d    r8.0<0;1,0>:d                    {I@7}
        mov (8|M0)               r79.0<1>:f    r5.0<1;1,0>:d                    {Compacted,I@7}
        asr (1|M0)               r78.2<1>:d    r1.2<0;1,0>:d     31:w               {I@6}
        mov (1|M0)               r45.5<1>:d    r7.0<0;1,0>:d                    {I@6}
        mov (8|M0)               r80.0<1>:f    r6.0<1;1,0>:d                    {Compacted,I@5}
L3360:
        bfn.0xFE (1|M0)          r78.3<1>:ud   r45.7<0;0>:ud     r42.2<0;0>:ud     r44.5<0>:ud      // s0|s1|s2
        mov (1|M0)               r86.5<1>:d    r2.6<0;1,0>:d                   
        or (1|M0)                r88.1<1>:ud   r78.3<0;1,0>:ud   0x8:uw              {I@2}
        mov (1|M0)               r87.5<1>:d    r78.3<0;1,0>:d                  
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r87.2         L9760                                 {A@1}
L3472:
        mov (2|M0)               r87.4<1>:d    r88.0<1;1,0>:d                   {I@3}
        mov (1|M0)               r86.5<1>:d    r2.6<0;1,0>:d                   
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r87.2         L9760                                 {A@1}
L3552:
        bfn.0xFE (1|M0)          r1.2<1>:ud    r45.7<0;0>:ud     r42.2<0;0>:ud     r44.5<0>:ud      // s0|s1|s2
        or (1|M0)                r4.6<1>:d     r78.3<0;1,0>:d    8:w              
        shl (1|M0)               r2.0<1>:d     r1.2<0;1,0>:d     2:w               {Compacted,I@2}
        shr (1|M0)               r1.4<1>:ud    r1.2<0;1,0>:ud    0x1E:uw             
        addc (1|M0)              r5.0<1>:ud    r4.0<0;1,0>:ud    r2.0<0;1,0>:ud   {AccWrEn,A@2}
        or (1|M0)                r2.1<1>:d     r1.4<0;1,0>:d     0:w               {I@2}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,F@1}
        mov (1|M0)               r8.0<1>:f     r5.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r8.1<1>:d     r6.0<0;0>:d       r4.1<0;0>:d       r2.1<0>:d        {I@1}
        shl (1|M0)               r1.2<1>:d     r4.6<0;1,0>:d     2:w              
        send.ugm (1|M0)          r81      r8      null:0  0x0            0x04100580           {A@1,$12} // wr:2+0, rd:1; load.ugm.d32.a64
        shr (1|M0)               r4.3<1>:ud    r4.6<0;1,0>:ud    0x1E:uw             
        addc (1|M0)              r7.0<1>:ud    r4.0<0;1,0>:ud    r1.2<0;1,0>:ud   {AccWrEn,I@2}
        or (1|M0)                r1.3<1>:d     r4.3<0;1,0>:d     0:w               {Compacted,I@2}
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r2.0<1>:f     r7.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r2.1<1>:d     r5.0<0;0>:d       r4.1<0;0>:d       r1.3<0>:d        {I@1}
        shl (1|M0)               r1.3<1>:w     r45.14<0;1,0>:w   2:w              
        send.ugm (1|M0)          r82      r2      null:0  0x0            0x04100580           {A@1,$13} // wr:2+0, rd:1; load.ugm.d32.a64
        shr (1|M0)               r6.0<1>:ud    r87.4<0;1,0>:ud   0x5:uw             
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0x9E0:uw              {A@1}
        sync.nop                             null                             {Compacted,$12.src}
        addc (1|M0)              r8.0<1>:ud    r45.5<0;1,0>:ud   r6.0<0;1,0>:ud   {AccWrEn,I@2}
        mov (1|M0)               r4.6<1>:d     r8.0<0;1,0>:d                    {I@1}
        mul (1|M0)               r3.3<1>:f     r78.0<0;1,0>:f    r[a0.0]<0;1,0>:f {$13.src}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,A@1}
        mul (1|M0)               acc0.0<1>:ud  r4.6<0;1,0>:ud    r44.12<0;1,0>:uw {I@2}
        mach (1|M0)              r11.0<1>:ud   r4.6<0;1,0>:ud    r44.6<0;1,0>:ud  {AccWrEn}
        add3 (1|M0)              r4.7<1>:d     r9.0<0;0>:d       r45.6<0;0>:d      0:w               {I@3}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r4.6<0;1,0>:d     r44.14<0;1,0>:uw
        mach (1|M0)              r2.0<1>:d     r4.6<0;1,0>:d     r44.7<0;1,0>:d  
(W)     mul (1|M0)               acc0.0<1>:d   r4.7<0;1,0>:d     r44.12<0;1,0>:uw {I@4}
        shr (1|M0)               r8.0<1>:ud    r88.0<0;1,0>:ud   0x5:uw             
        mach (1|M0)              r5.0<1>:d     r4.7<0;1,0>:d     r44.6<0;1,0>:d  
        addc (1|M0)              r6.0<1>:ud    r10.0<0;1,0>:ud   r78.1<0;1,0>:ud  {AccWrEn,I@6}
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0xA00:uw              {A@1}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r9.0<1>:ud    r45.5<0;1,0>:ud   r8.0<0;1,0>:ud   {AccWrEn,I@5}
        add3 (1|M0)              r1.3<1>:d     r5.0<0;0>:d       r11.0<0;0>:d      r2.0<0>:d        {I@5}
        mov (1|M0)               r12.1<1>:d    r9.0<0;1,0>:d                    {I@2}
        mov (1|M0)               r12.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mul (1|M0)               acc0.0<1>:ud  r12.1<0;1,0>:ud   r44.12<0;1,0>:uw {I@2}
        mach (1|M0)              r14.0<1>:ud   r12.1<0;1,0>:ud   r44.6<0;1,0>:ud  {AccWrEn}
        add3 (1|M0)              r12.2<1>:d    r12.0<0;0>:d      r45.6<0;0>:d      0:w               {I@3}
        mov (1|M0)               r13.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r12.1<0;1,0>:d    r44.14<0;1,0>:uw
        mach (1|M0)              r2.0<1>:d     r12.1<0;1,0>:d    r44.7<0;1,0>:d  
(W)     mul (1|M0)               acc0.0<1>:d   r12.2<0;1,0>:d    r44.12<0;1,0>:uw {I@4}
        mach (1|M0)              r5.0<1>:d     r12.2<0;1,0>:d    r44.6<0;1,0>:d  
        add3 (1|M0)              r81.2<1>:d    r7.0<0;0>:d       r1.3<0;0>:d       r78.2<0>:d       {$12.dst}
        add3 (1|M0)              r1.3<1>:d     r5.0<0;0>:d       r14.0<0;0>:d      r2.0<0>:d        {I@2}
        mov (1|M0)               r81.1<1>:d    r6.0<0;1,0>:d                   
        addc (1|M0)              r6.0<1>:ud    r13.0<0;1,0>:ud   r78.1<0;1,0>:ud  {AccWrEn}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r81.5<1>:d    r6.0<0;1,0>:d                    {I@2}
        add3 (1|M0)              r81.6<1>:d    r7.0<0;0>:d       r1.3<0;0>:d       r78.2<0>:d       {I@2}
        mul (1|M0)    (lt)f0.1   r81.0<1>:f    r81.0<0;1,0>:f    r3.3<0;1,0>:f    {F@1}
        mul (1|M0)               r3.3<1>:f     r78.0<0;1,0>:f    r[a0.0]<0;1,0>:f
(f0.1)  mov (1|M0)               r81.0<1>:f    -r81.0<0;1,0>:f                  {A@1}
        sel (1|M0)    (lt)f0.0   r81.0<1>:f    r81.0<0;1,0>:f    448.0:f               {F@1}
        shr (1|M0)               r78.5<1>:ud   r81.0<0;1,0>:ud   0x17:uw              {F@1}
        mul (1|M0)               r82.0<1>:f    r82.0<0;1,0>:f    r3.3<0;1,0>:f    {Compacted,$13.dst}
        and (1|M0)               r78.5<1>:ud   r78.5<0;1,0>:ud   0xFF:uw              {I@1}
        sel (1|M0)    (ge)f0.0   r78.5<1>:ud   r78.5<0;1,0>:ud   0x79:uw              {I@1}
        shl (1|M0)               r78.5<1>:ud   r78.5<0;1,0>:ud   0x17:uw              {I@1}
        add (1|M0)               r3.3<1>:ud    -r78.5<0;1,0>:ud  0x80800000:ud              {A@1}
        mul (1|M0)               r2.0<1>:f     r81.0<0;1,0>:f    r3.3<0;1,0>:f    {Compacted,I@1}
        mov (1|M0)               r78.4<1>:d    r2.0<0;1,0>:f                    {Compacted,F@1}
        mov (1|M0)               r78.6<1>:f    r78.4<0;1,0>:d                   {I@1}
        mad (1|M0)               r81.0<1>:f    -r78.6<0;0>:f     r3.3<0;0>:f       r81.0<0>:f       {F@1}
        cmp (1|M0)    (gt)f0.0   null<1>:f     r81.0<0;1,0>:f    0.5:f               {F@1}
(W)     and (1|M0)               f1.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
(f1.1.any16h) goto (16|M0)                   L4704                  L4704                
L4608:
        cmp (1|M0)    (lt)f0.0   null<1>:f     r81.0<0;1,0>:f    0.5:f               {I@2}
        and (1|M0)               r78.4<1>:d    r78.4<0;1,0>:d    1:w              
        add (1|M0)               r1.2<1>:f     r78.6<0;1,0>:f    1.0:f              
(~f0.0) cmp (1|M0)    (eq)f0.0   null<1>:d     r78.4<0;1,0>:d    0:w               {A@1}
(~f0.0) mov (1|M0)               r78.6<1>:f    r1.2<0;1,0>:f                    {F@1}
        goto (16|M0)                         L4704                  L4736                
L4704:
        join (16|M0)                         L4736                                
L4720:
        add (1|M0)               r78.6<1>:f    r78.6<0;1,0>:f    1.0:f               {F@1}
L4736:
        join (16|M0)                         L5920                                
L4752:
        cmp (1|M0)    (lt)f0.0   null<1>:f     r82.0<0;1,0>:f    0.0:f               {I@4}
        and (1|M0)               r2.0<1>:d     r78.3<0;1,0>:d    23:w               {Compacted}
        shl (1|M0)               r1.3<1>:d     r81.2<0;1,0>:d    5:w              
        shr (1|M0)               r3.3<1>:ud    r2.0<0;1,0>:ud    0x1F:uw              {I@2}
(f0.0)  mov (1|M0)               r82.0<1>:f    -r82.0<0;1,0>:f                 
        shl (1|M0)               r5.3<1>:d     r2.0<0;1,0>:d     1:w               {Compacted}
        sel (1|M0)    (lt)f0.0   r82.0<1>:f    r82.0<0;1,0>:f    448.0:f               {F@1}
        shr (1|M0)               r1.4<1>:ud    r81.1<0;1,0>:ud   0x1B:uw             
        shr (1|M0)               r81.3<1>:ud   r82.0<0;1,0>:ud   0x17:uw              {F@1}
        shl (1|M0)               r1.5<1>:d     r81.1<0;1,0>:d    5:w              
        and (1|M0)               r81.3<1>:ud   r81.3<0;1,0>:ud   0xFF:uw              {I@2}
        add (1|M0)               r78.5<1>:ud   r78.5<0;1,0>:ud   0xFE800000:ud             
        sel (1|M0)    (ge)f0.0   r81.3<1>:ud   r81.3<0;1,0>:ud   0x79:uw              {I@2}
        or (1|M0)                r1.6<1>:d     r1.3<0;1,0>:d     r1.4<0;1,0>:d   
        shl (1|M0)               r81.3<1>:ud   r81.3<0;1,0>:ud   0x17:uw              {I@2}
        shl (1|M0)               r4.6<1>:d     r1.5<0;1,0>:d     1:w              
        add (1|M0)               r2.0<1>:ud    -r81.3<0;1,0>:ud  0x80800000:ud              {I@2}
        shr (1|M0)               r2.7<1>:ud    r1.5<0;1,0>:ud    0x1F:uw             
        mul (1|M0)               r2.1<1>:f     r82.0<0;1,0>:f    r2.0<0;1,0>:f    {Compacted,I@2}
        mul (1|M0)               r78.6<1>:f    r78.6<0;1,0>:f    r78.5<0;1,0>:f  
        mov (1|M0)               r78.7<1>:d    r2.1<0;1,0>:f                    {F@2}
        shl (1|M0)               r2.3<1>:d     r1.6<0;1,0>:d     1:w              
        mov (1|M0)               r81.4<1>:f    r78.7<0;1,0>:d                   {I@2}
        addc (1|M0)              r5.0<1>:ud    r4.4<0;1,0>:ud    r4.6<0;1,0>:ud   {AccWrEn}
        mad (1|M0)               r82.0<1>:f    -r81.4<0;0>:f     r2.0<0;0>:f       r82.0<0>:f       {F@1}
(f0.1)  mov (1|M0)               r78.6<1>:f    -r78.6<0;1,0>:f                 
        cmp (1|M0)    (gt)f1.1   null<1>:f     r82.0<0;1,0>:f    0.5:f               {F@2}
        or (1|M0)                r4.7<1>:d     r2.3<0;1,0>:d     r2.7<0;1,0>:d    {I@2}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r7.0<1>:ud    r5.0<0;1,0>:ud    r5.3<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r5.4<1>:d     r3.3<0;1,0>:d     0:w              
        mov (1|M0)               r1.4<2>:hf    r78.6<0;1,0>:f                   {F@2}
        add3 (1|M0)              r5.2<1>:d     r6.0<0;0>:d       r4.5<0;0>:d       r4.7<0>:d        {I@3}
(W)     and (1|M0)               f1.0<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r10.0<1>:f    r7.0<0;1,0>:f                    {Compacted,I@5}
        mov (1|M0)               r12.0<1>:d    r1.4<0;1,0>:uw                   {F@2}
        add3 (1|M0)              r10.1<1>:d    r8.0<0;0>:d       r5.2<0;0>:d       r5.4<0>:d        {I@2}
        send.ugm (1|M0)          null     r10     r12:1   0x0            0x04000B84           {A@1,$1} // wr:2+1, rd:0; store.ugm.d16u32.a64
(f1.0.any16h) goto (16|M0)                   L5440                  L5440                
L5344:
        cmp (1|M0)    (lt)f1.1   null<1>:f     r82.0<0;1,0>:f    0.5:f              
        and (1|M0)               r78.7<1>:d    r78.7<0;1,0>:d    1:w              
        add (1|M0)               r1.2<1>:f     r81.4<0;1,0>:f    1.0:f              
(~f1.1) cmp (1|M0)    (eq)f1.1   null<1>:d     r78.7<0;1,0>:d    0:w               {A@1}
(~f1.1) mov (1|M0)               r81.4<1>:f    r1.2<0;1,0>:f                    {F@1}
        goto (16|M0)                         L5440                  L5472                
L5440:
        join (16|M0)                         L5472                                
L5456:
        add (1|M0)               r81.4<1>:f    r81.4<0;1,0>:f    1.0:f               {F@1}
L5472:
        join (16|M0)                         L5920                                
L5488:
        shl (1|M0)               r1.3<1>:d     r81.6<0;1,0>:d    5:w              
        shr (1|M0)               r1.4<1>:ud    r81.5<0;1,0>:ud   0x1B:uw             
        shl (1|M0)               r1.5<1>:d     r81.5<0;1,0>:d    5:w              
        add (1|M0)               r81.3<1>:ud   r81.3<0;1,0>:ud   0xFE800000:ud             
        and (1|M0)               r2.0<1>:d     r88.1<0;1,0>:d    31:w               {Compacted}
        add (1|M0)               r45.7<1>:ud   r45.7<0;1,0>:ud   0x1:uw             
        or (1|M0)                r1.6<1>:d     r1.3<0;1,0>:d     r1.4<0;1,0>:d    {I@5}
        shl (1|M0)               r4.6<1>:d     r1.5<0;1,0>:d     1:w               {I@5}
        shr (1|M0)               r2.7<1>:ud    r1.5<0;1,0>:ud    0x1F:uw             
        mul (1|M0)               r81.4<1>:f    r81.4<0;1,0>:f    r81.3<0;1,0>:f   {A@1}
        shl (1|M0)               r5.3<1>:d     r2.0<0;1,0>:d     1:w               {Compacted,I@5}
        cmp (1|M0)    (eq)f1.0   null<1>:d     r45.7<0;1,0>:d    8:w               {I@5}
        shl (1|M0)               r2.3<1>:d     r1.6<0;1,0>:d     1:w               {I@5}
        addc (1|M0)              r5.0<1>:ud    r4.4<0;1,0>:ud    r4.6<0;1,0>:ud   {AccWrEn,I@5}
        shr (1|M0)               r3.3<1>:ud    r2.0<0;1,0>:ud    0x1F:uw             
(f0.0)  mov (1|M0)               r81.4<1>:f    -r81.4<0;1,0>:f                  {F@1}
        or (1|M0)                r4.7<1>:d     r2.3<0;1,0>:d     r2.7<0;1,0>:d    {I@3}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r7.0<1>:ud    r5.0<0;1,0>:ud    r5.3<0;1,0>:ud   {AccWrEn,I@4}
(W)     and (1|M0)               f0.1<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
        or (1|M0)                r5.4<1>:d     r3.3<0;1,0>:d     0:w               {I@5}
        mov (1|M0)               r1.4<2>:hf    r81.4<0;1,0>:f                   {F@1}
        add3 (1|M0)              r5.2<1>:d     r6.0<0;0>:d       r4.5<0;0>:d       r4.7<0>:d        {I@4}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        sync.nop                             null                             {Compacted,$1.src}
        mov (1|M0)               r10.0<1>:f    r7.0<0;1,0>:f                    {Compacted,I@5}
        mov (1|M0)               r12.0<1>:d    r1.4<0;1,0>:uw                   {F@2}
        add3 (1|M0)              r10.1<1>:d    r8.0<0;0>:d       r5.2<0;0>:d       r5.4<0>:d        {I@2}
        send.ugm (1|M0)          null     r10     r12:1   0x0            0x04000B84           {A@1,$2} // wr:2+1, rd:0; store.ugm.d16u32.a64
(~f0.1.any16h) goto.b (16|M0)                L5920                  L3360                
L5920:
        join (16|M0)                         L9120                                
L5936:
        cmp (1|M0)    (lt)f0.1   null<1>:d     r45.4<0;1,0>:d    r3.2<0;1,0>:d   
(W)     and (1|M0)               f0.0<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(~f0.0.any16h) goto (16|M0)                  L9040                  L9040                
L5984:
        asr (1|M0)               r1.3<1>:d     r45.4<0;1,0>:d    31:w              
        shl (1|M0)               r4.6<1>:d     r45.4<0;1,0>:d    2:w              
        shr (1|M0)               r2.1<1>:ud    r45.4<0;1,0>:ud   0x1E:uw             
        shl (1|M0)               r2.0<1>:d     r1.3<0;1,0>:d     2:w               {Compacted,I@3}
        addc (1|M0)              r5.0<1>:ud    r3.4<0;1,0>:ud    r4.6<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r4.7<1>:d     r2.0<0;1,0>:d     r2.1<0;1,0>:d    {I@2}
        sync.nop                             null                             {Compacted,$8.src}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$3.src}
        sync.nop                             null                             {Compacted,$9.src}
        mov (1|M0)               r8.0<1>:f     r5.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r8.1<1>:d     r6.0<0;0>:d       r3.5<0;0>:d       r4.7<0>:d        {I@1}
        mov (1|M0)               r88.4<1>:f    r45.4<0;1,0>:f                  
        send.ugm (1|M0)          r83      r8      null:0  0x0            0x04100580           {A@1,$14} // wr:2+0, rd:1; load.ugm.d32.a64
        mov (1|M0)               r88.5<1>:d    r3.6<0;1,0>:d                   
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r86.6         L9192                                 {A@1}
L6216:
        shl (1|M0)               r1.3<1>:w     r45.4<0;1,0>:w    5:w              
(W)     mul (1|M0)               acc0.0<1>:d   r86.4<0;1,0>:d    r3.12<0;1,0>:uw 
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0x6C0:uw              {A@1}
        mach (1|M0)              r2.0<1>:d     r86.4<0;1,0>:d    r3.6<0;1,0>:d   
        mul (1|M0)               acc0.0<1>:d   r86.4<0;1,0>:d    r4.4<0;1,0>:uw  
        mach (1|M0)              r8.0<1>:d     r86.4<0;1,0>:d    r4.2<0;1,0>:d    {AccWrEn}
        mov (8|M0)               r5.0<1>:ud    r[a0.0]<1;1,0>:ud               
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0x5C0:uw              {A@1}
        add (1|M0)               r1.2<1>:d     r45.4<0;1,0>:d    -r2.0<0;1,0>:d   {I@5}
        mov (1|M0)               r7.0<1>:d     acc0.0<0;1,0>:d                 
        mov (1|M0)               r81.7<1>:d    0:w                              
        mov (8|M0)               r6.0<1>:ud    r[a0.0]<1;1,0>:ud               
        add (1|M0)               r82.3<1>:d    r45.4<0;1,0>:d    -r2.0<0;1,0>:d   {A@1}
        mov (1|M0)               r82.2<1>:d    r8.0<0;1,0>:d                    {I@7}
        mov (8|M0)               r84.0<1>:f    r5.0<1;1,0>:d                    {Compacted,I@7}
        asr (1|M0)               r82.4<1>:d    r1.2<0;1,0>:d     31:w               {I@6}
        mov (1|M0)               r82.1<1>:d    r7.0<0;1,0>:d                    {I@6}
        mov (8|M0)               r85.0<1>:f    r6.0<1;1,0>:d                    {Compacted,I@5}
L6488:
        bfn.0xFE (1|M0)          r82.5<1>:ud   r81.7<0;0>:ud     r42.2<0;0>:ud     r44.5<0>:ud      // s0|s1|s2
        mov (1|M0)               r86.5<1>:d    r2.6<0;1,0>:d                   
        or (1|M0)                r82.6<1>:ud   r82.5<0;1,0>:ud   0x8:uw              {I@2}
        mov (1|M0)               r87.5<1>:f    r82.5<0;1,0>:f                  
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r87.2         L9760                                 {A@1}
L6600:
        mov (1|M0)               r82.7<1>:d    r88.0<0;1,0>:d                  
        mov (1|M0)               r87.5<1>:d    r82.6<0;1,0>:d                   {A@1}
        mov (1|M0)               r86.5<1>:d    r2.6<0;1,0>:d                   
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r87.2         L9760                                 {A@1}
L6696:
        bfn.0xFE (1|M0)          r1.2<1>:ud    r81.7<0;0>:ud     r42.2<0;0>:ud     r44.5<0>:ud      // s0|s1|s2
        or (1|M0)                r4.6<1>:d     r82.5<0;1,0>:d    8:w              
        shl (1|M0)               r2.0<1>:d     r1.2<0;1,0>:d     2:w               {Compacted,I@2}
        shr (1|M0)               r1.4<1>:ud    r1.2<0;1,0>:ud    0x1E:uw             
        addc (1|M0)              r5.0<1>:ud    r4.0<0;1,0>:ud    r2.0<0;1,0>:ud   {AccWrEn,I@2}
        or (1|M0)                r2.1<1>:d     r1.4<0;1,0>:d     0:w               {I@2}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r8.0<1>:f     r5.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r8.1<1>:d     r6.0<0;0>:d       r4.1<0;0>:d       r2.1<0>:d        {I@1}
        shl (1|M0)               r1.2<1>:d     r4.6<0;1,0>:d     2:w              
        send.ugm (1|M0)          r86      r8      null:0  0x0            0x04100580           {A@1,$15} // wr:2+0, rd:1; load.ugm.d32.a64
        shr (1|M0)               r4.3<1>:ud    r4.6<0;1,0>:ud    0x1E:uw             
        addc (1|M0)              r7.0<1>:ud    r4.0<0;1,0>:ud    r1.2<0;1,0>:ud   {AccWrEn,I@2}
        or (1|M0)                r1.3<1>:d     r4.3<0;1,0>:d     0:w               {Compacted,I@2}
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r2.0<1>:f     r7.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r2.1<1>:d     r5.0<0;0>:d       r4.1<0;0>:d       r1.3<0>:d        {I@1}
        shl (1|M0)               r1.3<1>:w     r81.14<0;1,0>:w   2:w              
        send.ugm (1|M0)          r87      r2      null:0  0x0            0x04100580           {A@1,$0} // wr:2+0, rd:1; load.ugm.d32.a64
        shr (1|M0)               r6.0<1>:ud    r82.7<0;1,0>:ud   0x5:uw             
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0xA80:uw              {A@1}
        sync.nop                             null                             {Compacted,$15.src}
        addc (1|M0)              r8.0<1>:ud    r82.1<0;1,0>:ud   r6.0<0;1,0>:ud   {AccWrEn,I@2}
        mov (1|M0)               r4.6<1>:d     r8.0<0;1,0>:d                    {I@1}
        mul (1|M0)               r3.3<1>:f     r83.0<0;1,0>:f    r[a0.0]<0;1,0>:f {$0.src}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,A@1}
        mul (1|M0)               acc0.0<1>:ud  r4.6<0;1,0>:ud    r44.12<0;1,0>:uw {I@2}
        mach (1|M0)              r11.0<1>:ud   r4.6<0;1,0>:ud    r44.6<0;1,0>:ud  {AccWrEn}
        add3 (1|M0)              r4.7<1>:d     r9.0<0;0>:d       r82.2<0;0>:d      0:w               {I@3}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r4.6<0;1,0>:d     r44.14<0;1,0>:uw
        mach (1|M0)              r2.0<1>:d     r4.6<0;1,0>:d     r44.7<0;1,0>:d  
(W)     mul (1|M0)               acc0.0<1>:d   r4.7<0;1,0>:d     r44.12<0;1,0>:uw {I@4}
        shr (1|M0)               r8.0<1>:ud    r88.0<0;1,0>:ud   0x5:uw             
        mach (1|M0)              r5.0<1>:d     r4.7<0;1,0>:d     r44.6<0;1,0>:d  
        addc (1|M0)              r6.0<1>:ud    r10.0<0;1,0>:ud   r82.3<0;1,0>:ud  {AccWrEn,I@6}
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0xAA0:uw              {A@1}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r9.0<1>:ud    r82.1<0;1,0>:ud   r8.0<0;1,0>:ud   {AccWrEn,I@5}
        add3 (1|M0)              r1.3<1>:d     r5.0<0;0>:d       r11.0<0;0>:d      r2.0<0>:d        {I@5}
        mov (1|M0)               r12.1<1>:d    r9.0<0;1,0>:d                    {I@2}
        mov (1|M0)               r12.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mul (1|M0)               acc0.0<1>:ud  r12.1<0;1,0>:ud   r44.12<0;1,0>:uw {I@2}
        mach (1|M0)              r14.0<1>:ud   r12.1<0;1,0>:ud   r44.6<0;1,0>:ud  {AccWrEn}
        add3 (1|M0)              r12.2<1>:d    r12.0<0;0>:d      r82.2<0;0>:d      0:w               {I@3}
        mov (1|M0)               r13.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r12.1<0;1,0>:d    r44.14<0;1,0>:uw
        mach (1|M0)              r2.0<1>:d     r12.1<0;1,0>:d    r44.7<0;1,0>:d  
(W)     mul (1|M0)               acc0.0<1>:d   r12.2<0;1,0>:d    r44.12<0;1,0>:uw {I@4}
        mach (1|M0)              r5.0<1>:d     r12.2<0;1,0>:d    r44.6<0;1,0>:d  
        add3 (1|M0)              r83.5<1>:d    r7.0<0;0>:d       r1.3<0;0>:d       r82.4<0>:d      
        add3 (1|M0)              r1.3<1>:d     r5.0<0;0>:d       r14.0<0;0>:d      r2.0<0>:d        {I@2}
        mov (1|M0)               r83.4<1>:d    r6.0<0;1,0>:d                   
        addc (1|M0)              r6.0<1>:ud    r13.0<0;1,0>:ud   r82.3<0;1,0>:ud  {AccWrEn}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        sync.nop                             null                             {Compacted,$15.dst}
        mov (1|M0)               r86.2<1>:d    r6.0<0;1,0>:d                    {I@2}
        add3 (1|M0)              r86.3<1>:d    r7.0<0;0>:d       r1.3<0;0>:d       r82.4<0>:d       {I@2}
        mul (1|M0)    (lt)f0.1   r86.0<1>:f    r86.0<0;1,0>:f    r3.3<0;1,0>:f    {F@1}
        mul (1|M0)               r3.3<1>:f     r83.0<0;1,0>:f    r[a0.0]<0;1,0>:f
(f0.1)  mov (1|M0)               r86.0<1>:f    -r86.0<0;1,0>:f                  {A@1}
        sel (1|M0)    (lt)f0.0   r86.0<1>:f    r86.0<0;1,0>:f    448.0:f               {F@1}
        shr (1|M0)               r83.2<1>:ud   r86.0<0;1,0>:ud   0x17:uw              {F@1}
        mul (1|M0)               r87.0<1>:f    r87.0<0;1,0>:f    r3.3<0;1,0>:f    {Compacted,$0.dst}
        and (1|M0)               r83.2<1>:ud   r83.2<0;1,0>:ud   0xFF:uw              {I@1}
        sel (1|M0)    (ge)f0.0   r83.2<1>:ud   r83.2<0;1,0>:ud   0x79:uw              {I@1}
        shl (1|M0)               r83.2<1>:ud   r83.2<0;1,0>:ud   0x17:uw              {I@1}
        add (1|M0)               r3.3<1>:ud    -r83.2<0;1,0>:ud  0x80800000:ud              {A@1}
        mul (1|M0)               r2.0<1>:f     r86.0<0;1,0>:f    r3.3<0;1,0>:f    {Compacted,I@1}
        mov (1|M0)               r83.1<1>:d    r2.0<0;1,0>:f                    {Compacted,F@1}
        mov (1|M0)               r83.3<1>:f    r83.1<0;1,0>:d                   {I@1}
        mad (1|M0)               r86.0<1>:f    -r83.3<0;0>:f     r3.3<0;0>:f       r86.0<0>:f       {F@1}
        cmp (1|M0)    (gt)f0.0   null<1>:f     r86.0<0;1,0>:f    0.5:f               {F@1}
(W)     and (1|M0)               f1.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
(f1.1.any16h) goto (16|M0)                   L7848                  L7848                
L7760:
        cmp (1|M0)    (lt)f1.0   null<1>:f     r86.0<0;1,0>:f    0.5:f              
        and (1|M0)               r83.1<1>:d    r83.1<0;1,0>:d    1:w               {Compacted}
        add (1|M0)               r1.2<1>:f     r83.3<0;1,0>:f    1.0:f              
(~f1.0) cmp (1|M0)    (eq)f1.0   null<1>:d     r83.1<0;1,0>:d    0:w               {A@1}
(~f1.0) mov (1|M0)               r83.3<1>:f    r1.2<0;1,0>:f                    {F@1}
        goto (16|M0)                         L7848                  L7872                
L7848:
        join (16|M0)                         L7872                                
L7864:
        add (1|M0)               r83.3<1>:f    r83.3<0;1,0>:f    1.0:f               {Compacted,F@1}
L7872:
        join (16|M0)                         L9040                                
L7888:
        cmp (1|M0)    (lt)f0.0   null<1>:f     r87.0<0;1,0>:f    0.0:f              
        and (1|M0)               r2.0<1>:d     r82.5<0;1,0>:d    23:w               {Compacted}
        shl (1|M0)               r1.3<1>:d     r83.5<0;1,0>:d    5:w              
        shr (1|M0)               r3.3<1>:ud    r2.0<0;1,0>:ud    0x1F:uw              {I@2}
(f0.0)  mov (1|M0)               r87.0<1>:f    -r87.0<0;1,0>:f                 
        shl (1|M0)               r5.3<1>:d     r2.0<0;1,0>:d     1:w               {Compacted}
        sel (1|M0)    (lt)f0.0   r87.0<1>:f    r87.0<0;1,0>:f    448.0:f               {F@1}
        shr (1|M0)               r1.4<1>:ud    r83.4<0;1,0>:ud   0x1B:uw             
        shr (1|M0)               r83.7<1>:ud   r87.0<0;1,0>:ud   0x17:uw              {F@1}
        shl (1|M0)               r1.5<1>:d     r83.4<0;1,0>:d    5:w              
        and (1|M0)               r83.7<1>:ud   r83.7<0;1,0>:ud   0xFF:uw              {I@2}
        add (1|M0)               r83.2<1>:ud   r83.2<0;1,0>:ud   0xFE800000:ud             
        sel (1|M0)    (ge)f0.0   r83.7<1>:ud   r83.7<0;1,0>:ud   0x79:uw              {I@2}
        or (1|M0)                r1.6<1>:d     r1.3<0;1,0>:d     r1.4<0;1,0>:d   
        shl (1|M0)               r83.7<1>:ud   r83.7<0;1,0>:ud   0x17:uw              {I@2}
        shl (1|M0)               r4.6<1>:d     r1.5<0;1,0>:d     1:w              
        add (1|M0)               r2.0<1>:ud    -r83.7<0;1,0>:ud  0x80800000:ud              {I@2}
        shr (1|M0)               r2.7<1>:ud    r1.5<0;1,0>:ud    0x1F:uw             
        mul (1|M0)               r2.1<1>:f     r87.0<0;1,0>:f    r2.0<0;1,0>:f    {Compacted,I@2}
        mul (1|M0)               r83.3<1>:f    r83.3<0;1,0>:f    r83.2<0;1,0>:f  
        mov (1|M0)               r83.6<1>:d    r2.1<0;1,0>:f                    {F@2}
        shl (1|M0)               r2.3<1>:d     r1.6<0;1,0>:d     1:w              
        mov (1|M0)               r86.1<1>:f    r83.6<0;1,0>:d                   {I@2}
        addc (1|M0)              r5.0<1>:ud    r4.4<0;1,0>:ud    r4.6<0;1,0>:ud   {AccWrEn}
        mad (1|M0)               r87.0<1>:f    -r86.1<0;0>:f     r2.0<0;0>:f       r87.0<0>:f       {F@1}
(f0.1)  mov (1|M0)               r83.3<1>:f    -r83.3<0;1,0>:f                 
        cmp (1|M0)    (gt)f1.1   null<1>:f     r87.0<0;1,0>:f    0.5:f               {F@2}
        or (1|M0)                r4.7<1>:d     r2.3<0;1,0>:d     r2.7<0;1,0>:d    {I@2}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r7.0<1>:ud    r5.0<0;1,0>:ud    r5.3<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r5.4<1>:d     r3.3<0;1,0>:d     0:w              
        mov (1|M0)               r1.4<2>:hf    r83.3<0;1,0>:f                   {F@2}
        add3 (1|M0)              r5.2<1>:d     r6.0<0;0>:d       r4.5<0;0>:d       r4.7<0>:d        {I@3}
(W)     and (1|M0)               f1.0<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r10.0<1>:f    r7.0<0;1,0>:f                    {Compacted,I@5}
        mov (1|M0)               r12.0<1>:d    r1.4<0;1,0>:uw                   {F@2}
        add3 (1|M0)              r10.1<1>:d    r8.0<0;0>:d       r5.2<0;0>:d       r5.4<0>:d        {I@2}
        send.ugm (1|M0)          null     r10     r12:1   0x0            0x04000B84           {A@1,$5} // wr:2+1, rd:0; store.ugm.d16u32.a64
(f1.0.any16h) goto (16|M0)                   L8576                  L8576                
L8480:
        cmp (1|M0)    (lt)f0.1   null<1>:f     r87.0<0;1,0>:f    0.5:f              
        and (1|M0)               r83.6<1>:d    r83.6<0;1,0>:d    1:w              
        add (1|M0)               r1.2<1>:f     r86.1<0;1,0>:f    1.0:f              
(~f0.1) cmp (1|M0)    (eq)f0.1   null<1>:d     r83.6<0;1,0>:d    0:w               {A@1}
(~f0.1) mov (1|M0)               r86.1<1>:f    r1.2<0;1,0>:f                    {F@1}
        goto (16|M0)                         L8576                  L8600                
L8576:
        join (16|M0)                         L8600                                
L8592:
        add (1|M0)               r86.1<1>:f    r86.1<0;1,0>:f    1.0:f               {Compacted,F@1}
L8600:
        join (16|M0)                         L9040                                
L8616:
        shl (1|M0)               r1.3<1>:d     r86.3<0;1,0>:d    5:w               {Compacted}
        shr (1|M0)               r1.4<1>:ud    r86.2<0;1,0>:ud   0x1B:uw             
        shl (1|M0)               r1.5<1>:d     r86.2<0;1,0>:d    5:w              
        add (1|M0)               r83.7<1>:ud   r83.7<0;1,0>:ud   0xFE800000:ud             
        and (1|M0)               r2.0<1>:d     r82.6<0;1,0>:d    31:w               {Compacted}
        add (1|M0)               r81.7<1>:ud   r81.7<0;1,0>:ud   0x1:uw             
        or (1|M0)                r1.6<1>:d     r1.3<0;1,0>:d     r1.4<0;1,0>:d    {I@5}
        shl (1|M0)               r4.6<1>:d     r1.5<0;1,0>:d     1:w               {I@5}
        shr (1|M0)               r2.7<1>:ud    r1.5<0;1,0>:ud    0x1F:uw             
        mul (1|M0)               r86.1<1>:f    r86.1<0;1,0>:f    r83.7<0;1,0>:f   {A@1}
        shl (1|M0)               r5.3<1>:d     r2.0<0;1,0>:d     1:w               {Compacted,I@5}
        cmp (1|M0)    (eq)f1.0   null<1>:d     r81.7<0;1,0>:d    8:w               {I@5}
        shl (1|M0)               r2.3<1>:d     r1.6<0;1,0>:d     1:w               {I@5}
        addc (1|M0)              r5.0<1>:ud    r4.4<0;1,0>:ud    r4.6<0;1,0>:ud   {AccWrEn,I@5}
        shr (1|M0)               r3.3<1>:ud    r2.0<0;1,0>:ud    0x1F:uw             
(f0.0)  mov (1|M0)               r86.1<1>:f    -r86.1<0;1,0>:f                  {F@1}
        or (1|M0)                r4.7<1>:d     r2.3<0;1,0>:d     r2.7<0;1,0>:d    {I@3}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r7.0<1>:ud    r5.0<0;1,0>:ud    r5.3<0;1,0>:ud   {AccWrEn,I@4}
(W)     and (1|M0)               f0.1<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
        or (1|M0)                r5.4<1>:d     r3.3<0;1,0>:d     0:w               {I@5}
        mov (1|M0)               r1.4<2>:hf    r86.1<0;1,0>:f                   {F@1}
        add3 (1|M0)              r5.2<1>:d     r6.0<0;0>:d       r4.5<0;0>:d       r4.7<0>:d        {I@4}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        sync.nop                             null                             {Compacted,$5.src}
        mov (1|M0)               r10.0<1>:f    r7.0<0;1,0>:f                    {Compacted,I@5}
        mov (1|M0)               r12.0<1>:d    r1.4<0;1,0>:uw                   {F@2}
        add3 (1|M0)              r10.1<1>:d    r8.0<0;0>:d       r5.2<0;0>:d       r5.4<0>:d        {I@2}
        send.ugm (1|M0)          null     r10     r12:1   0x0            0x04000B84           {A@1,$10} // wr:2+1, rd:0; store.ugm.d16u32.a64
(~f0.1.any16h) goto.b (16|M0)                L9040                  L6488                
L9040:
        join (16|M0)                         L9120                                
L9056:
        add (1|M0)               r45.2<1>:d    r45.2<0;1,0>:d    1:w              
        cmp (1|M0)    (eq)f0.1   null<1>:d     r45.2<0;1,0>:d    8:w               {I@1}
(W)     and (1|M0)               f0.0<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(~f0.0.any16h) goto.b (16|M0)                L9120                  L2784                
L9120:
        join (16|M0)                         L9136                                
L9136:
(W)     mov (8|M0)               r127.0<1>:f   r0.0<1;1,0>:f                    {Compacted}
(W)     send.ugm (1|M0)          r5       r0      null:0  0x0            0x0210641F           {$11} // wr:1+0, rd:1; fence invalid flush type scoped to tile
(W)     mov (8|M0)               null<1>:ud    r5.0<1;1,0>:ud                   {$11.dst}
(W)     send.gtwy (1|M0)         null     r127    null:0  0x0            0x02000010           {EOT,A@1} // wr:1+0, rd:0; end of thread
L9192:
        mov (1|M0)               r1.2<1>:d     cr0.0<0;1,0>:ud                  {A@1}
        and (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   -1265:w               {A@1}
        or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   1264:w               {A@1}
        mov (1|M0)               r1.3<1>:f     (abs)r88.5<0;1,0>:d              {A@1}
        mov (1|M0)               r4.3<1>:f     0xB4C00000:f                               {Compacted}
        math.inv (1|M0)          r3.7<1>:f     r1.3<0;1,0>:f                    {@2,$12}
        mov (1|M0)               r2.1<1>:f     (abs)r88.4<0;1,0>:d             
        sync.nop                             null                             {Compacted,$12.dst}
        mad (1|M0)               r3.7<1>:f     r3.7<0;0>:f       r4.3<0;0>:f       r3.7<0>:f        {F@2}
        mov (2|M0)               r1.4<1>:d     (abs)r88.4<1;1,0>:d             
        mov (1|M0)               r1.6<1>:ud    r1.3<0;1,0>:f                   
        mov (1|M0)               r2.3<1>:ud    r2.1<0;1,0>:f                    {F@2}
        mul (1|M0)               r5.0<1>:f     r3.7<0;1,0>:f     r2.1<0;1,0>:f    {A@1}
        add (1|M0)               r1.6<1>:ud    r1.5<0;1,0>:ud    -r1.6<0;1,0>:ud  {I@2}
        add (1|M0)               r2.3<1>:ud    r1.4<0;1,0>:ud    -r2.3<0;1,0>:ud  {I@2}
        mov (1|M0)               r6.0<1>:ud    r5.0<0;1,0>:f                    {F@1}
        mov (1|M0)               r2.0<1>:f     r1.6<0;1,0>:ud                   {Compacted,I@3}
        mov (1|M0)               r3.3<1>:f     r2.3<0;1,0>:ud                   {Compacted,I@2}
        mov (1|M0)               r6.1<1>:f     r6.0<0;1,0>:ud                   {Compacted,I@1}
(W)     mov (1|M0)               r4.6<1>:hf    0x1:hf                             
        mad (1|M0)               r2.1<1>:f     r2.1<0;0>:f       r6.1<0;0>:f       -r1.3<0>:f       {F@2}
        mad (1|M0)               r6.1<1>:f     r3.3<0;0>:f       r6.1<0;0>:f       -r2.0<0>:f      
        xor (1|M0)               r88.5<1>:d    r88.5<0;1,0>:d    r88.4<0;1,0>:d  
        add (1|M0)               r2.1<1>:f     r2.1<0;1,0>:f     r6.1<0;1,0>:f    {F@1}
        asr (1|M0)               r88.5<1>:d    r88.5<0;1,0>:d    31:w               {I@1}
        mul (1|M0)               r3.7<1>:f     r3.7<0;1,0>:f     r2.1<0;1,0>:f    {F@1}
        mov (1|M0)               r7.0<1>:ud    r3.7<0;1,0>:f                    {F@1}
        add (1|M0)               r6.0<1>:ud    r6.0<0;1,0>:ud    r7.0<0;1,0>:ud   {Compacted,I@1}
(W)     mul (1|M0)               acc0.0<1>:ud  r6.0<0;1,0>:ud    r1.10<0;1,0>:uw  {I@1}
        mach (1|M0)              r8.0<1>:ud    r6.0<0;1,0>:ud    r1.5<0;1,0>:ud   {Compacted}
        add (1|M0)               r1.4<1>:ud    r1.4<0;1,0>:ud    -r8.0<0;1,0>:ud  {I@1}
        cmp (1|M0)    (ge)f1.0   null<1>:ud    r1.4<0;1,0>:ud    r1.5<0;1,0>:ud   {I@1}
(f1.0)  sel (1|M0)               r5.0<1>:d     r4.6<0;1,0>:w     0:w              
        add3 (1|M0)              r6.0<1>:d     r6.0<0;0>:d       r88.5<0;0>:d      r5.0<0>:d        {I@1}
        xor (1|M0)               r86.4<1>:d    r6.0<0;1,0>:d     r88.5<0;1,0>:d   {I@1}
        mov (1|M0)               cr0.0<1>:ud   r1.2<0;1,0>:d                    {A@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        ret (16|M0)                          r86.6                            {A@1}
L9760:
        mov (1|M0)               r1.2<1>:d     cr0.0<0;1,0>:ud                  {A@1}
        and (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   -1265:w               {A@1}
        or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   1264:w               {A@1}
        mov (1|M0)               r1.6<1>:f     (abs)r86.5<0;1,0>:d              {A@1}
        mov (1|M0)               r4.3<1>:f     0xB4C00000:f                               {Compacted}
        math.inv (1|M0)          r3.7<1>:f     r1.6<0;1,0>:f                    {@2,$13}
        mov (1|M0)               r2.1<1>:f     (abs)r87.5<0;1,0>:d             
        sync.nop                             null                             {Compacted,$13.dst}
        mad (1|M0)               r3.7<1>:f     r3.7<0;0>:f       r4.3<0;0>:f       r3.7<0>:f        {F@2}
        mov (1|M0)               r1.4<1>:d     (abs)r87.5<0;1,0>:d             
        mov (1|M0)               r1.5<1>:d     (abs)r86.5<0;1,0>:d             
        mov (1|M0)               r1.7<1>:ud    r1.6<0;1,0>:f                   
        mov (1|M0)               r2.3<1>:ud    r2.1<0;1,0>:f                    {F@2}
        mul (1|M0)               r5.0<1>:f     r3.7<0;1,0>:f     r2.1<0;1,0>:f    {F@1}
        add (1|M0)               r1.7<1>:ud    r1.5<0;1,0>:ud    -r1.7<0;1,0>:ud  {I@2}
        add (1|M0)               r2.3<1>:ud    r1.4<0;1,0>:ud    -r2.3<0;1,0>:ud  {I@2}
        mov (1|M0)               r6.0<1>:ud    r5.0<0;1,0>:f                    {F@1}
        mov (1|M0)               r2.0<1>:f     r1.7<0;1,0>:ud                   {Compacted,I@3}
        mov (1|M0)               r3.3<1>:f     r2.3<0;1,0>:ud                   {Compacted,I@2}
        mov (1|M0)               r6.1<1>:f     r6.0<0;1,0>:ud                   {Compacted,I@1}
        asr (1|M0)               r1.3<1>:d     r87.5<0;1,0>:d    31:w              
        mad (1|M0)               r2.1<1>:f     r2.1<0;0>:f       r6.1<0;0>:f       -r1.6<0>:f       {F@1}
        mad (1|M0)               r6.1<1>:f     r3.3<0;0>:f       r6.1<0;0>:f       -r2.0<0>:f      
        add (1|M0)               r2.1<1>:f     r2.1<0;1,0>:f     r6.1<0;1,0>:f    {F@1}
        mul (1|M0)               r3.7<1>:f     r3.7<0;1,0>:f     r2.1<0;1,0>:f    {F@1}
        mov (1|M0)               r7.0<1>:ud    r3.7<0;1,0>:f                    {F@1}
        add (1|M0)               r6.0<1>:ud    r6.0<0;1,0>:ud    r7.0<0;1,0>:ud   {Compacted,I@1}
(W)     mul (1|M0)               acc0.0<1>:ud  r6.0<0;1,0>:ud    r1.10<0;1,0>:uw  {I@1}
        mach (1|M0)              r6.0<1>:ud    r6.0<0;1,0>:ud    r1.5<0;1,0>:ud   {Compacted}
        add (1|M0)               r1.4<1>:ud    r1.4<0;1,0>:ud    -r6.0<0;1,0>:ud  {I@1}
        cmp (1|M0)    (lt)f0.0   null<1>:ud    r1.4<0;1,0>:ud    r1.5<0;1,0>:ud   {I@1}
(f0.0)  mov (1|M0)               r1.5<1>:d     0:w                              
        add3 (1|M0)              r1.4<1>:d     r1.4<0;0>:d       r1.3<0;0>:d       -r1.5<0>:d       {I@1}
        xor (1|M0)               r88.0<1>:d    r1.4<0;1,0>:d     r1.3<0;1,0>:d    {I@1}
        mov (1|M0)               cr0.0<1>:ud   r1.2<0;1,0>:d                    {A@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        ret (16|M0)                          r87.2                            {A@1}
L10312:
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
