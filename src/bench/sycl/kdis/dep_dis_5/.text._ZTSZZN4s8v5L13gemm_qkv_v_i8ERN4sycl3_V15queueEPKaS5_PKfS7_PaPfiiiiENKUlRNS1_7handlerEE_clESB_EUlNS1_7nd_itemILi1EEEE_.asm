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
        mov (1|M0)               r89.5<1>:d    r2.2<0;1,0>:d                    {$1.dst}
        mov (1|M0)               r89.4<1>:d    r42.0<0;1,0>:d                   {I@3}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r89.2         L13232                                 {A@1}
L352:
        asr (1|M0)               r42.5<1>:d    r2.6<0;1,0>:d     31:w              
        mov (1|M0)               r42.2<1>:d    r94.0<0;1,0>:d                  
        shr (1|M0)               r42.5<1>:ud   r42.5<0;1,0>:ud   0x1B:uw              {I@2}
        shl (1|M0)               r1.2<1>:d     r42.1<0;1,0>:d    2:w              
        add (1|M0)               r42.5<1>:d    r2.6<0;1,0>:d     r42.5<0;1,0>:d   {I@2}
        mov (1|M0)               r6.0<1>:f     0.0:f                               {Compacted}
        asr (1|M0)               r42.5<1>:d    r42.5<0;1,0>:d    5:w               {I@1}
(W)     mul (1|M0)               acc0.0<1>:d   r42.2<0;1,0>:d    r2.4<0;1,0>:uw  
        add (1|M0)               r5.0<1>:d     r1.2<0;1,0>:d     12288:w              
        add (1|M0)               r7.0<1>:d     r1.2<0;1,0>:d     12416:w              
        mach (1|M0)              r2.0<1>:d     r42.2<0;1,0>:d    r2.2<0;1,0>:d   
(W)     mul (1|M0)               acc0.0<1>:d   r42.2<0;1,0>:d    r42.10<0;1,0>:uw {I@5}
        send.slm (1|M0)          null     r5      r6:1    0x0            0x02000504           {A@1,$3} // wr:1+1, rd:0; store.slm.d32.a32
        mach (1|M0)              r5.0<1>:d     r42.2<0;1,0>:d    r42.5<0;1,0>:d   {$3.src}
(W)     mul (1|M0)               acc0.0<1>:d   r42.2<0;1,0>:d    r42.10<0;1,0>:uw
        send.slm (1|M0)          null     r7      r6:1    0x0            0x02000504           {A@5,$4} // wr:1+1, rd:0; store.slm.d32.a32
        mach (1|M0)              r7.0<1>:d     r42.2<0;1,0>:d    r42.5<0;1,0>:d   {$4.src}
        add (1|M0)               r8.0<1>:d     r1.2<0;1,0>:d     12544:w              
        add (1|M0)               r9.0<1>:d     r1.2<0;1,0>:d     12672:w              
        add (1|M0)               r6.1<1>:d     r42.0<0;1,0>:d    -r2.0<0;1,0>:d   {Compacted,I@7}
        shl (1|M0)               r1.4<1>:d     r7.0<0;1,0>:d     12:w               {Compacted,I@4}
        send.slm (1|M0)          null     r8      r6:1    0x0            0x02000504           {A@2,$5} // wr:1+1, rd:0; store.slm.d32.a32
        send.slm (1|M0)          null     r9      r6:1    0x0            0x02000504           {$6} // wr:1+1, rd:0; store.slm.d32.a32
        asr (1|M0)               r7.1<1>:d     r5.0<0;1,0>:d     31:w               {Compacted}
        sync.nop                             null                             {Compacted,$6.src}
        addc (1|M0)              r6.0<1>:ud    r2.4<0;1,0>:ud    r1.4<0;1,0>:ud   {AccWrEn,I@2}
        shl (1|M0)               r9.0<1>:d     r6.1<0;1,0>:d     11:w               {Compacted}
        shr (1|M0)               r1.3<1>:ud    r7.0<0;1,0>:ud    0x14:uw             
        shl (1|M0)               r1.2<1>:d     r7.1<0;1,0>:d     12:w               {I@4}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$5.src}
        shl (1|M0)               r7.0<1>:ud    r42.1<0;1,0>:ud   0x7:uw             
        addc (1|M0)              r5.0<1>:ud    r3.0<0;1,0>:ud    r9.0<0;1,0>:ud   {AccWrEn,I@5}
        shr (1|M0)               r3.5<1>:ud    r6.1<0;1,0>:ud    0x15:uw             
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@5}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        shl (1|M0)               r1.2<1>:ud    r42.1<0;1,0>:ud   0x6:uw             
        addc (1|M0)              r11.0<1>:ud   r6.0<0;1,0>:ud    r7.0<0;1,0>:ud   {AccWrEn,I@6}
        add (1|M0)               r42.4<1>:d    r42.0<0;1,0>:d    -r2.0<0;1,0>:d   {Compacted}
        or (1|M0)                r9.1<1>:d     r3.5<0;1,0>:d     0:w               {I@6}
        mov (1|M0)               r12.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r2.0<1>:ud    r5.0<0;1,0>:ud    r1.2<0;1,0>:ud   {AccWrEn,I@5}
        add3 (1|M0)              r4.7<1>:d     r8.0<0;0>:d       r2.5<0;0>:d       r1.5<0>:d       
        add3 (1|M0)              r5.2<1>:d     r10.0<0;0>:d      r3.1<0;0>:d       r9.1<0>:d        {I@4}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r44.0<1>:f    r11.0<0;1,0>:f                   {Compacted}
        mov (1|M0)               r45.0<1>:f    r2.0<0;1,0>:f                    {Compacted,I@4}
        add3 (1|M0)              r44.1<1>:d    r12.0<0;0>:d      r4.7<0;0>:d       0:w               {I@3}
        add3 (1|M0)              r45.1<1>:d    r8.0<0;0>:d       r5.2<0;0>:d       0:w               {I@2}
        send.ugm (1|M0)          r13      r44     null:0  0x0            0x0240D780           {A@2,$7} // wr:1+0, rd:4; load.ugm.d64x16t.a64
        send.ugm (1|M0)          r9       r45     null:0  0x0            0x0220C780           {A@1,$8} // wr:1+0, rd:2; load.ugm.d64x8t.a64
        add (1|M0)               r43.0<1>:ud   r1.2<0;1,0>:ud    0x2000:uw             
        and (1|M0)               r44.7<1>:d    r1.0<0;1,0>:uw    3:w               {$7.src}
        shr (1|M0)               r42.3<1>:ud   r42.1<0;1,0>:ud   0x2:uw             
        shl (1|M0)               r42.4<1>:d    r42.4<0;1,0>:d    6:w              
        send.slm (1|M0)          null     r7      r13:4   0x0            0x0200D704           {$7} // wr:1+4, rd:0; store.slm.d64x16t.a32
        send.slm (1|M0)          null     r43     r9:2    0x0            0x0200C704           {A@4,$8} // wr:1+2, rd:0; store.slm.d64x8t.a32
(W)     send.slm (1|M0)          r6       r0      null:0  0x0            0x0210001F           {$9} // wr:1+0, rd:1; fence.slm.none.group
(W)     mov (1|M0)               r11.2<1>:f    0.0:f                               {Compacted}
(W)     mov (2|M0)               r11.10<1>:ub  r0.11<0;1,0>:ub                  {F@1}
(W)     mov (8|M0)               null<1>:ud    r6.0<1;1,0>:ud                   {$9.dst}
(W)     send.gtwy (1|M0)         null     r11     null:0  0x0            0x02000004           {A@2,$10} // wr:1+0, rd:0; signal barrier
(W)     sync.bar                             null                            
        cmp (1|M0)    (gt)f0.1   null<1>:d     r2.6<0;1,0>:d     31:w              
        shl (1|M0)               r42.6<1>:ud   r42.3<0;1,0>:ud   0x9:uw             
        shl (1|M0)               r42.7<1>:d    r44.7<0;1,0>:d    9:w              
        mov (16|M0)              r46.0<1>:d    0:w                              
(W)     and (1|M0)               f0.1<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
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
(~f0.1.any16h) goto (16|M0)                  L2856                  L2856                
L1568:
        shr (1|M0)               r1.2<1>:ud    r2.6<0;1,0>:ud    0x1B:uw             
        mov (1|M0)               r43.5<1>:f    r42.5<0;1,0>:f                   {$8.src}
        shl (1|M0)               r43.3<1>:d    r2.6<0;1,0>:d     5:w              
        mov (1|M0)               r44.2<2>:f    0.0:f                              
        mov (1|M0)               r44.3<2>:f    0.0:f                              
        or (1|M0)                r43.4<1>:d    r1.2<0;1,0>:d     0:w               {I@2}
        mov (2|M0)               r43.1<1>:d    r43.5<1;1,0>:d                   {F@3}
        asr (1|M0)               r43.2<1>:d    r42.5<0;1,0>:d    31:w              
        mov (1|M0)               r43.6<1>:d    0:w                              
L1712:
        addc (1|M0)              r2.0<1>:ud    r44.2<0;1,0>:ud   0x1:ud              {AccWrEn,F@2}
(W)     mov (1|M0)               r1.3<1>:hf    0x1:hf                             
        mov (1|M0)               r44.4<1>:d    r2.0<0;1,0>:d                    {I@1}
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        cmp (1|M0)    (lt)f0.0   null<1>:ud    r44.4<0;1,0>:ud   r43.1<0;1,0>:ud  {I@2}
        add3 (1|M0)              r44.5<1>:d    r5.0<0;0>:d       r44.3<0;0>:d      0:w               {A@2}
        and (1|M0)               r43.7<1>:d    r44.2<0;1,0>:d    1:w              
        cmp (1|M0)    (lt)f1.0   null<1>:d     r44.5<0;1,0>:d    r43.2<0;1,0>:d   {I@2}
(f0.0)  cmp (1|M0)    (eq)f0.0   null<1>:d     r44.5<0;1,0>:d    r43.2<0;1,0>:d  
(f1.0)  sel (1|M0)               r3.10<1>:uw   r1.3<0;1,0>:uw    0x0:uw              {F@1}
(f0.0)  sel (1|M0)               r1.4<1>:uw    r1.3<0;1,0>:uw    0x0:uw             
        or (1|M0)     (ne)f0.0   null<1>:uw    r1.4<0;1,0>:uw    r3.10<0;1,0>:uw  {I@1}
(W)     and (1|M0)               f0.0<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
(~f0.0.any16h) goto (16|M0)                  L2392                  L2392                
L1928:
        shl (1|M0)               r1.5<1>:d     r44.4<0;1,0>:d    12:w              
        shl (1|M0)               r1.3<1>:d     r44.5<0;1,0>:d    12:w              
        shr (1|M0)               r1.4<1>:ud    r44.4<0;1,0>:ud   0x14:uw             
        addc (1|M0)              r2.0<1>:ud    r44.0<0;1,0>:ud   r1.5<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r1.6<1>:d     r1.3<0;1,0>:d     r1.4<0;1,0>:d    {I@2}
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        sync.nop                             null                             {Compacted,$12.src}
        mov (1|M0)               r6.0<1>:f     r2.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r6.1<1>:d     r5.0<0;0>:d       r44.1<0;0>:d      r1.6<0>:d        {I@1}
        mul (1|M0)               acc0.0<1>:ud  r43.3<0;1,0>:ud   r44.8<0;1,0>:uw 
        sync.allrd                           ($7,$11)                
        send.ugm (1|M0)          r7       r6      null:0  0x0            0x0240D780           {A@1,$14} // wr:1+0, rd:4; load.ugm.d64x16t.a64
        mach (1|M0)              r13.0<1>:ud   r43.3<0;1,0>:ud   r44.4<0;1,0>:ud  {AccWrEn}
        xor (1|M0)               r1.2<1>:d     r43.7<0;1,0>:d    1:w              
        mov (1|M0)               r12.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r43.3<0;1,0>:d    r44.10<0;1,0>:uw
        mach (1|M0)              r14.0<1>:d    r43.3<0;1,0>:d    r44.5<0;1,0>:d  
(W)     mul (1|M0)               acc0.0<1>:d   r43.4<0;1,0>:d    r44.8<0;1,0>:uw 
        mach (1|M0)              r2.0<1>:d     r43.4<0;1,0>:d    r44.4<0;1,0>:d  
        addc (1|M0)              r5.0<1>:ud    r45.0<0;1,0>:ud   r12.0<0;1,0>:ud  {AccWrEn,I@5}
        shl (1|M0)               r3.5<1>:d     r1.2<0;1,0>:d     12:w              
        add3 (1|M0)              r1.4<1>:d     r2.0<0;0>:d       r13.0<0;0>:d      r14.0<0>:d       {I@3}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$14.src}
        mov (1|M0)               r15.0<1>:f    r5.0<0;1,0>:f                    {Compacted,I@4}
        sync.nop                             null                             {Compacted,$10.src}
        mad (1|M0)               r11.0<1>:d    r3.5<0;0>:d       r1.0<0;0>:uw      128:w               {I@3}
        add3 (1|M0)              r15.1<1>:d    r6.0<0;0>:d       r45.1<0;0>:d      r1.4<0>:d        {I@2}
        shl (1|M0)               r1.2<1>:d     r1.2<0;1,0>:d     11:w              
        send.slm (1|M0)          null     r11     r7:4    0x0            0x0200D704           {A@3,$14} // wr:1+4, rd:0; store.slm.d64x16t.a32
        sync.nop                             null                             {Compacted,$14.src}
        send.ugm (1|M0)          r7       r15     null:0  0x0            0x0220C780           {A@1,$15} // wr:1+0, rd:2; load.ugm.d64x8t.a64
        add (1|M0)               r9.0<1>:d     r1.2<0;1,0>:d     r43.0<0;1,0>:d   {Compacted,I@1}
        sync.nop                             null                             {Compacted,$15.dst}
        send.slm (1|M0)          null     r9      r7:2    0x0            0x0200C704           {A@1,$11} // wr:1+2, rd:0; store.slm.d64x8t.a32
L2392:
        join (16|M0)                         L2856                                
L2408:
        shl (1|M0)               r1.2<1>:d     r43.7<0;1,0>:d    12:w              
        shl (1|M0)               r43.7<1>:d    r43.7<0;1,0>:d    11:w              
        add (1|M0)               r2.0<1>:d     r1.2<0;1,0>:d     r42.6<0;1,0>:d   {I@2}
        bfn.0xFE (1|M0)          r5.0<1>:ud    0x2000:uw               r43.7<0;0>:ud     r42.7<0>:ud      {I@2} // s0|s1|s2
        bfn.0xFE (1|M0)          r31.0<1>:ud   0x2100:uw               r43.7<0;0>:ud     r42.7<0>:ud      // s0|s1|s2
        sync.nop                             null                             {Compacted,$7.src}
        or (1|M0)                r14.0<1>:ud   r2.0<0;1,0>:ud    0x100:uw              {I@3}
        sync.allrd                           ($10,$12)                
        send.slm (1|M0)          r6       r2      null:0  0x0            0x0280E700           {$0} // wr:1+0, rd:8; load.slm.d64x32t.a32
        send.slm (1|M0)          r23      r5      null:0  0x0            0x0280E700           {A@3,$1} // wr:1+0, rd:8; load.slm.d64x32t.a32
        send.slm (1|M0)          r32      r31     null:0  0x0            0x0280E700           {A@2,$2} // wr:1+0, rd:8; load.slm.d64x32t.a32
        send.slm (1|M0)          r15      r14     null:0  0x0            0x0280E700           {A@1,$3} // wr:1+0, rd:8; load.slm.d64x32t.a32
        sync.allwr                           ($0,$1,$2,$3,$12)                
        dpas.8x8 (8|M0)          r70:d         r70:d             r23:b             r6.0:b           {Atomic}
        dpas.8x8 (8|M0)          r62:d         r62:d             r32:b             r6.0:b           {Atomic}
        dpas.8x8 (8|M0)          r54:d         r54:d             r23:b             r15.0:b          {Atomic}
        dpas.8x8 (8|M0)          r46:d         r46:d             r32:b             r15.0:b          {$12}
(W)     send.slm (1|M0)          r40      r0      null:0  0x0            0x0210001F           {$4} // wr:1+0, rd:1; fence.slm.none.group
(W)     mov (1|M0)               r41.2<1>:f    0.0:f                               {Compacted,$13.src}
(W)     mov (2|M0)               r41.10<1>:ub  r0.11<0;1,0>:ub                  {F@1}
(W)     mov (8|M0)               null<1>:ud    r40.0<1;1,0>:ud                  {$4.dst}
(W)     send.gtwy (1|M0)         null     r41     null:0  0x0            0x02000004           {A@2,$13} // wr:1+0, rd:0; signal barrier
(W)     sync.bar                             null                            
        cmp (1|M0)    (eq)f1.0   null<1>:d     r44.5<0;1,0>:d    r43.6<0;1,0>:d  
(f1.0)  cmp (1|M0)    (eq)f1.0   null<1>:d     r44.4<0;1,0>:d    r43.5<0;1,0>:d  
(W)     and (1|M0)               f1.1<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
(f1.1.any16h) goto (16|M0)                   L2856                  L2856                
L2824:
(W)     mov (2|M0)               r44.2<1>:ud   r44.4<1;1,0>:ud                 
        goto.b (16|M0)                       L2856                  L1712                
L2856:
        join (16|M0)                         L2872                                
L2872:
        shl (1|M0)               r44.7<1>:d    r44.7<0;1,0>:d    4:w              
        shl (1|M0)               r44.6<1>:d    r42.2<0;1,0>:d    7:w              
        or (1|M0)                r1.2<1>:d     r42.4<0;1,0>:d    r44.7<0;1,0>:d   {I@2}
        shl (1|M0)               r42.3<1>:ud   r42.3<0;1,0>:ud   0x4:uw             
        shl (1|M0)               r2.0<1>:d     r1.2<0;1,0>:d     2:w               {Compacted,I@2}
        shr (1|M0)               r1.4<1>:ud    r1.2<0;1,0>:ud    0x1E:uw             
        addc (1|M0)              r5.0<1>:ud    r3.6<0;1,0>:ud    r2.0<0;1,0>:ud   {AccWrEn,I@2}
        or (1|M0)                r2.1<1>:d     r1.4<0;1,0>:d     0:w               {I@2}
        mov (1|M0)               r78.0<1>:f    r5.0<0;1,0>:f                    {Compacted,I@2}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$12.src}
        sync.allrd                           ($7,$11)                
        addc (1|M0)              r7.0<1>:ud    r78.0<0;1,0>:ud   0x20:ud              {AccWrEn,F@1}
        add3 (1|M0)              r78.1<1>:d    r6.0<0;0>:d       r3.7<0;0>:d       r2.1<0>:d        {I@2}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r80.0<1>:f    r7.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r80.1<1>:d    r8.0<0;0>:d       r78.1<0;0>:d      0:w               {I@1}
        send.ugm (1|M0)          r79      r78     null:0  0x0            0x0210B780           {$5} // wr:1+0, rd:1; load.ugm.d64x4t.a64
        send.ugm (1|M0)          r81      r80     null:0  0x0            0x0210B780           {A@1,$6} // wr:1+0, rd:1; load.ugm.d64x4t.a64
        add (1|M0)               r45.3<1>:d    r3.4<0;1,0>:d     -1:w              
        mov (1|M0)               r45.4<1>:d    0:w                              
        mov (8|M0)               r82.0<1>:f    0.0:f                               {Compacted}
        mov (8|M0)               r83.0<1>:f    0.0:f                               {Compacted}
        or (1|M0)                r45.2<1>:d    r42.4<0;1,0>:d    r44.7<0;1,0>:d  
        add (1|M0)               r44.6<1>:d    r44.6<0;1,0>:d    r42.3<0;1,0>:d  
L3200:
        or (1|M0)                r1.2<1>:d     r45.4<0;1,0>:d    r44.6<0;1,0>:d   {I@1}
        bfn.0xFE (1|M0)          r1.3<1>:ud    0x8:uw               r45.4<0;0>:ud     r44.6<0>:ud      // s0|s1|s2
        sel (1|M0)    (lt)f0.0   r1.4<1>:d     r1.2<0;1,0>:d     r45.3<0;1,0>:d   {I@2}
        sel (1|M0)    (lt)f0.0   r2.0<1>:d     r1.2<0;1,0>:d     r45.3<0;1,0>:d  
        asr (1|M0)               r2.1<1>:d     r1.4<0;1,0>:d     31:w               {I@2}
        shl (1|M0)               r4.6<1>:d     r2.0<0;1,0>:d     2:w               {Compacted,I@2}
        shr (1|M0)               r2.7<1>:ud    r2.0<0;1,0>:ud    0x1E:uw             
        shl (1|M0)               r2.3<1>:d     r2.1<0;1,0>:d     2:w               {I@3}
        addc (1|M0)              r5.0<1>:ud    r3.2<0;1,0>:ud    r4.6<0;1,0>:ud   {AccWrEn,I@3}
        sel (1|M0)    (lt)f0.0   r3.5<1>:d     r1.3<0;1,0>:d     r45.3<0;1,0>:d  
        sel (1|M0)    (lt)f0.0   r7.1<1>:d     r1.3<0;1,0>:d     r45.3<0;1,0>:d  
        or (1|M0)                r4.7<1>:d     r2.3<0;1,0>:d     r2.7<0;1,0>:d    {I@4}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r8.0<1>:f     r5.0<0;1,0>:f                    {Compacted,I@5}
        asr (1|M0)               r7.2<1>:d     r3.5<0;1,0>:d     31:w               {I@4}
        shl (1|M0)               r2.0<1>:d     r7.1<0;1,0>:d     2:w               {Compacted,I@4}
        add3 (1|M0)              r8.1<1>:d     r6.0<0;0>:d       r3.3<0;0>:d       r4.7<0>:d        {I@3}
        shr (1|M0)               r7.4<1>:ud    r7.1<0;1,0>:ud    0x1E:uw             
        send.ugm (1|M0)          r7       r8      null:0  0x0            0x04100580           {A@1,$7} // wr:2+0, rd:1; load.ugm.d32.a64
        shl (1|M0)               r7.3<1>:d     r7.2<0;1,0>:d     2:w               {$7.dst}
        addc (1|M0)              r9.0<1>:ud    r3.2<0;1,0>:ud    r2.0<0;1,0>:ud   {AccWrEn,$8.src}
        or (1|M0)                r2.1<1>:d     r7.3<0;1,0>:d     r7.4<0;1,0>:d    {I@2}
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r6.0<1>:f     r9.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r6.1<1>:d     r5.0<0;0>:d       r3.3<0;0>:d       r2.1<0>:d        {I@1}
        shl (1|M0)               r1.3<1>:w     r45.8<0;1,0>:w    5:w              
        send.ugm (1|M0)          r8       r6      null:0  0x0            0x04100580           {A@1,$9} // wr:2+0, rd:1; load.ugm.d32.a64
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0x8C0:uw              {A@1}
        add (1|M0)               r45.4<1>:ud   r45.4<0;1,0>:ud   0x1:uw             
        cmp (1|M0)    (eq)f1.1   null<1>:d     r45.4<0;1,0>:d    8:w               {I@1}
        mov (8|M0)               r10.0<1>:ud   r[a0.0]<1;1,0>:ud                {$12.dst}
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0x7C0:uw              {A@1}
        sync.nop                             null                             {Compacted,$10.src}
        mov (8|M0)               r11.0<1>:f    r10.0<1;1,0>:d                   {Compacted,I@2}
(W)     and (1|M0)               f1.0<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
        mov (8|M0)               r13.0<1>:ud   r[a0.0]<1;1,0>:ud               
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0x6C0:uw              {A@1}
        mov (8|M0)               r9.0<1>:f     r13.0<1;1,0>:d                   {Compacted,I@2}
        mov (8|M0)               r6.0<1>:ud    r[a0.0]<1;1,0>:ud                {$9.src}
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0x5C0:uw              {A@1}
        mov (8|M0)               r14.0<1>:f    r6.0<1;1,0>:d                    {Compacted,I@2}
        mul (8|M0)               acc0.0<1>:f   r7.0<0;1,0>:f     r11.0<1;1,0>:f   {Compacted,F@3}
        mul (8|M0)               acc1.0<1>:f   r7.0<0;1,0>:f     r9.0<1;1,0>:f    {Compacted,F@3}
        mul (8|M0)               acc0.0<1>:f   acc0.0<1;1,0>:f   r79.0<1;1,0>:f   {Compacted,$5.dst}
        mov (8|M0)               r11.0<1>:ud   r[a0.0]<1;1,0>:ud                {F@3}
        sync.nop                             null                             {Compacted,A@1}
        sync.nop                             null                             {Compacted,$6.dst}
        mul (8|M0)               acc1.0<1>:f   acc1.0<1;1,0>:f   r81.0<1;1,0>:f   {Compacted,A@1}
        mov (8|M0)               r15.0<1>:f    r11.0<1;1,0>:d                   {Compacted,I@1}
        sel (8|M0)    (ge)f0.0   r82.0<1>:f    r82.0<1;1,0>:f    (abs)acc0.0<1;1,0>:f
        sel (8|M0)    (ge)f0.0   r83.0<1>:f    r83.0<1;1,0>:f    (abs)acc1.0<1;1,0>:f
        mul (8|M0)               acc0.0<1>:f   r8.0<0;1,0>:f     r14.0<1;1,0>:f   {Compacted,$9.dst}
        mul (8|M0)               acc1.0<1>:f   r8.0<0;1,0>:f     r15.0<1;1,0>:f   {Compacted,F@4}
        mul (8|M0)               acc0.0<1>:f   acc0.0<1;1,0>:f   r79.0<1;1,0>:f   {Compacted}
        mul (8|M0)               acc1.0<1>:f   acc1.0<1;1,0>:f   r81.0<1;1,0>:f   {Compacted}
        sel (8|M0)    (ge)f0.0   r82.0<1>:f    r82.0<1;1,0>:f    (abs)acc0.0<1;1,0>:f {F@6}
        sel (8|M0)    (ge)f0.0   r83.0<1>:f    r83.0<1;1,0>:f    (abs)acc1.0<1;1,0>:f {F@6}
(~f1.0.any16h) goto.b (16|M0)                L3960                  L3200                
L3960:
        join (16|M0)                         L3976                                
L3976:
        cmp (1|M0)    (gt)f0.0   null<1>:uw    r1.0<0;1,0>:uw    0xF:uw             
(W)     mov (1|M0)               r1.3<1>:hf    0x40:hf                             
        mov (1|M0)               r7.0<1>:f     r82.1<0;1,0>:f                   {Compacted,F@3}
        mov (1|M0)               r9.0<1>:f     r83.1<0;1,0>:f                   {Compacted,F@3}
(f0.0)  sel (1|M0)               r2.0<1>:d     r1.3<0;1,0>:w     0:w               {F@3}
        mov (1|M0)               r11.0<1>:f    r82.2<0;1,0>:f                   {Compacted}
        or (1|M0)                r2.0<1>:d     r44.7<0;1,0>:d    r2.0<0;1,0>:d    {Compacted,I@1}
        mov (1|M0)               r13.0<1>:f    r83.2<0;1,0>:f                   {Compacted}
        shl (1|M0)               r2.0<1>:d     r2.0<0;1,0>:d     2:w               {Compacted,I@1}
        mov (1|M0)               r15.0<1>:f    r82.3<0;1,0>:f                   {Compacted}
        or (1|M0)                r84.0<1>:d    r2.0<0;1,0>:d     12288:w               {I@1}
        or (1|M0)                r5.0<1>:d     r2.0<0;1,0>:d     12320:w              
        or (1|M0)                r6.0<1>:d     r2.0<0;1,0>:d     12292:w              
        or (1|M0)                r8.0<1>:d     r2.0<0;1,0>:d     12324:w              
        or (1|M0)                r10.0<1>:d    r2.0<0;1,0>:d     12296:w              
        or (1|M0)                r12.0<1>:d    r2.0<0;1,0>:d     12328:w              
        send.slm (1|M0)          null     r84     r82:1   0x0            0x02000516           {A@6,$11} // wr:1+1, rd:0; atomic_fmax.slm.d32.a32
        send.slm (1|M0)          null     r5      r83:1   0x0            0x02000516           {A@5,$12} // wr:1+1, rd:0; atomic_fmax.slm.d32.a32
        send.slm (1|M0)          null     r6      r7:1    0x0            0x02000516           {A@4,$14} // wr:1+1, rd:0; atomic_fmax.slm.d32.a32
        send.slm (1|M0)          null     r8      r9:1    0x0            0x02000516           {A@3,$15} // wr:1+1, rd:0; atomic_fmax.slm.d32.a32
        send.slm (1|M0)          null     r10     r11:1   0x0            0x02000516           {A@2,$0} // wr:1+1, rd:0; atomic_fmax.slm.d32.a32
        send.slm (1|M0)          null     r12     r13:1   0x0            0x02000516           {A@1,$1} // wr:1+1, rd:0; atomic_fmax.slm.d32.a32
        or (1|M0)                r14.0<1>:d    r2.0<0;1,0>:d     12300:w              
        or (1|M0)                r6.0<1>:d     r2.0<0;1,0>:d     12332:w               {$14.src}
        mov (1|M0)               r7.0<1>:f     r83.3<0;1,0>:f                   {Compacted}
        or (1|M0)                r8.0<1>:d     r2.0<0;1,0>:d     12304:w               {$15.src}
        mov (1|M0)               r9.0<1>:f     r82.4<0;1,0>:f                   {Compacted}
        or (1|M0)                r10.0<1>:d    r2.0<0;1,0>:d     12336:w               {$0.src}
        mov (1|M0)               r11.0<1>:f    r83.4<0;1,0>:f                   {Compacted}
        or (1|M0)                r12.0<1>:d    r2.0<0;1,0>:d     12308:w               {$1.src}
        mov (1|M0)               r13.0<1>:f    r82.5<0;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r14     r15:1   0x0            0x02000516           {A@5,$2} // wr:1+1, rd:0; atomic_fmax.slm.d32.a32
        send.slm (1|M0)          null     r6      r7:1    0x0            0x02000516           {A@4,$3} // wr:1+1, rd:0; atomic_fmax.slm.d32.a32
        send.slm (1|M0)          null     r8      r9:1    0x0            0x02000516           {A@3,$4} // wr:1+1, rd:0; atomic_fmax.slm.d32.a32
        send.slm (1|M0)          null     r10     r11:1   0x0            0x02000516           {A@2,$5} // wr:1+1, rd:0; atomic_fmax.slm.d32.a32
        send.slm (1|M0)          null     r12     r13:1   0x0            0x02000516           {A@1,$6} // wr:1+1, rd:0; atomic_fmax.slm.d32.a32
        or (1|M0)                r14.0<1>:d    r2.0<0;1,0>:d     12340:w               {$2.src}
        mov (1|M0)               r15.0<1>:f    r83.5<0;1,0>:f                   {Compacted}
        or (1|M0)                r6.0<1>:d     r2.0<0;1,0>:d     12312:w               {$3.src}
        mov (1|M0)               r7.0<1>:f     r82.6<0;1,0>:f                   {Compacted}
        or (1|M0)                r8.0<1>:d     r2.0<0;1,0>:d     12344:w               {$4.src}
        mov (1|M0)               r9.0<1>:f     r83.6<0;1,0>:f                   {Compacted}
        or (1|M0)                r10.0<1>:d    r2.0<0;1,0>:d     12316:w               {$5.src}
        mov (1|M0)               r11.0<1>:f    r82.7<0;1,0>:f                   {Compacted}
        mov (1|M0)               r12.0<1>:f    r83.7<0;1,0>:f                   {Compacted,$6.src}
        or (1|M0)                r2.0<1>:d     r2.0<0;1,0>:d     12348:w              
        send.slm (1|M0)          null     r14     r15:1   0x0            0x02000516           {A@5,$7} // wr:1+1, rd:0; atomic_fmax.slm.d32.a32
        send.slm (1|M0)          null     r6      r7:1    0x0            0x02000516           {A@4,$8} // wr:1+1, rd:0; atomic_fmax.slm.d32.a32
        send.slm (1|M0)          null     r8      r9:1    0x0            0x02000516           {A@3,$9} // wr:1+1, rd:0; atomic_fmax.slm.d32.a32
        send.slm (1|M0)          null     r10     r11:1   0x0            0x02000516           {A@2,$10} // wr:1+1, rd:0; atomic_fmax.slm.d32.a32
        send.slm (1|M0)          null     r2      r12:1   0x0            0x02000516           {A@1,$14} // wr:1+1, rd:0; atomic_fmax.slm.d32.a32
(W)     send.slm (1|M0)          r13      r0      null:0  0x0            0x0210001F           {$15} // wr:1+0, rd:1; fence.slm.none.group
(W)     mov (1|M0)               r14.2<1>:f    0.0:f                               {Compacted,$7.src}
(W)     mov (2|M0)               r14.10<1>:ub  r0.11<0;1,0>:ub                  {F@1}
(W)     mov (8|M0)               null<1>:ud    r13.0<1;1,0>:ud                  {$15.dst}
(W)     send.gtwy (1|M0)         null     r14     null:0  0x0            0x02000004           {A@2,$0} // wr:1+0, rd:0; signal barrier
(W)     sync.bar                             null                            
        send.slm (1|M0)          r6       r84     null:0  0x0            0x0210B700           {$1} // wr:1+0, rd:1; load.slm.d64x4t.a32
        send.slm (1|M0)          r7       r5      null:0  0x0            0x0210B700           {$2} // wr:1+0, rd:1; load.slm.d64x4t.a32
        send.ugm (1|M0)          r87      r78     null:0  0x0            0x0210B780           {$3} // wr:1+0, rd:1; load.ugm.d64x4t.a64
        send.ugm (1|M0)          r88      r80     null:0  0x0            0x0210B780           {$4} // wr:1+0, rd:1; load.ugm.d64x4t.a64
        shr (1|M0)               r45.5<1>:ud   r45.2<0;1,0>:ud   0x5:uw             
        mov (1|M0)               r45.6<1>:d    0:w                              
        mov (1|M0)               r78.2<1>:d    r4.0<0;1,0>:d                    {$3.src}
        math.inv (1|M0)          r1.2<1>:f     r6.0<0;1,0>:f                    {$1}
        cmp (1|M0)    (gt)f1.0   null<1>:f     r6.0<0;1,0>:f     0.0:f              
        sync.nop                             null                             {Compacted,$14.src}
        math.inv (1|M0)          r2.0<1>:f     r7.0<0;1,0>:f                    {$2}
        cmp (1|M0)    (gt)f0.1   null<1>:f     r7.0<0;1,0>:f     0.0:f              
        math.inv (1|M0)          r3.5<1>:f     r6.1<0;1,0>:f                    {$5}
        mul (1|M0)               r1.2<1>:f     r1.2<0;1,0>:f     127.0:f               {$1.dst}
        math.inv (1|M0)          r4.6<1>:f     r7.1<0;1,0>:f                    {$6}
        cmp (1|M0)    (gt)f1.1   null<1>:f     r6.1<0;1,0>:f     0.0:f              
        mul (1|M0)               r2.0<1>:f     r2.0<0;1,0>:f     127.0:f               {$2.dst}
(f1.0)  sel (1|M0)               r85.0<1>:f    r1.2<0;1,0>:f     0.0:f               {F@3}
        cmp (1|M0)    (gt)f1.0   null<1>:f     r7.1<0;1,0>:f     0.0:f              
        sync.nop                             null                             {Compacted,F@2}
        math.inv (1|M0)          r1.2<1>:f     r6.2<0;1,0>:f                    {$8}
        mul (1|M0)               r3.5<1>:f     r3.5<0;1,0>:f     127.0:f               {$5.dst}
        mul (1|M0)               r4.6<1>:f     r4.6<0;1,0>:f     127.0:f               {$6.dst}
(f0.1)  sel (1|M0)               r86.0<1>:f    r2.0<0;1,0>:f     0.0:f              
        cmp (1|M0)    (gt)f0.1   null<1>:f     r6.2<0;1,0>:f     0.0:f              
        sync.nop                             null                             {Compacted,F@2}
        math.inv (1|M0)          r2.0<1>:f     r7.2<0;1,0>:f                    {$14}
        mul (1|M0)               r1.2<1>:f     r1.2<0;1,0>:f     127.0:f               {$8.dst}
(f1.1)  sel (1|M0)               r85.1<1>:f    r3.5<0;1,0>:f     0.0:f              
(f1.0)  sel (1|M0)               r86.1<1>:f    r4.6<0;1,0>:f     0.0:f              
        cmp (1|M0)    (gt)f1.1   null<1>:f     r7.2<0;1,0>:f     0.0:f              
        sync.nop                             null                             {Compacted,F@3}
        math.inv (1|M0)          r3.5<1>:f     r6.3<0;1,0>:f                    {$15}
        mul (1|M0)               r2.0<1>:f     r2.0<0;1,0>:f     127.0:f               {$14.dst}
        sync.nop                             null                             {Compacted,F@3}
        math.inv (1|M0)          r4.6<1>:f     r7.3<0;1,0>:f                    {$1}
(f0.1)  sel (1|M0)               r85.2<1>:f    r1.2<0;1,0>:f     0.0:f              
        cmp (1|M0)    (gt)f1.0   null<1>:f     r6.3<0;1,0>:f     0.0:f              
        cmp (1|M0)    (gt)f0.1   null<1>:f     r7.3<0;1,0>:f     0.0:f              
        sync.nop                             null                             {Compacted,F@3}
        math.inv (1|M0)          r1.2<1>:f     r6.4<0;1,0>:f                    {$2}
        mul (1|M0)               r3.5<1>:f     r3.5<0;1,0>:f     127.0:f               {$15.dst}
(f1.1)  sel (1|M0)               r86.2<1>:f    r2.0<0;1,0>:f     0.0:f              
        mul (1|M0)               r4.6<1>:f     r4.6<0;1,0>:f     127.0:f               {$1.dst}
        cmp (1|M0)    (gt)f1.1   null<1>:f     r6.4<0;1,0>:f     0.0:f              
        sync.nop                             null                             {Compacted,F@3}
        math.inv (1|M0)          r2.0<1>:f     r7.4<0;1,0>:f                    {$5}
        mul (1|M0)               r1.2<1>:f     r1.2<0;1,0>:f     127.0:f               {$2.dst}
(f1.0)  sel (1|M0)               r85.3<1>:f    r3.5<0;1,0>:f     0.0:f              
(f0.1)  sel (1|M0)               r86.3<1>:f    r4.6<0;1,0>:f     0.0:f               {F@4}
        cmp (1|M0)    (gt)f1.0   null<1>:f     r7.4<0;1,0>:f     0.0:f              
        sync.nop                             null                             {Compacted,F@3}
        math.inv (1|M0)          r3.5<1>:f     r6.5<0;1,0>:f                    {$6}
        mul (1|M0)               r2.0<1>:f     r2.0<0;1,0>:f     127.0:f               {$5.dst}
        sync.nop                             null                             {Compacted,F@3}
        math.inv (1|M0)          r4.6<1>:f     r7.5<0;1,0>:f                    {$7}
(f1.1)  sel (1|M0)               r85.4<1>:f    r1.2<0;1,0>:f     0.0:f              
        cmp (1|M0)    (gt)f0.1   null<1>:f     r6.5<0;1,0>:f     0.0:f              
        cmp (1|M0)    (gt)f1.1   null<1>:f     r7.5<0;1,0>:f     0.0:f              
        sync.nop                             null                             {Compacted,F@3}
        math.inv (1|M0)          r1.2<1>:f     r6.6<0;1,0>:f                    {$8}
        mul (1|M0)               r3.5<1>:f     r3.5<0;1,0>:f     127.0:f               {$6.dst}
(f1.0)  sel (1|M0)               r86.4<1>:f    r2.0<0;1,0>:f     0.0:f              
        mul (1|M0)               r4.6<1>:f     r4.6<0;1,0>:f     127.0:f               {$7.dst}
        cmp (1|M0)    (gt)f1.0   null<1>:f     r6.6<0;1,0>:f     0.0:f              
        mul (1|M0)               r1.2<1>:f     r1.2<0;1,0>:f     127.0:f               {$8.dst}
(f0.1)  sel (1|M0)               r85.5<1>:f    r3.5<0;1,0>:f     0.0:f               {F@5}
        sync.nop                             null                             {Compacted,F@5}
        math.inv (1|M0)          r2.0<1>:f     r7.6<0;1,0>:f                    {$14}
(f1.1)  sel (1|M0)               r86.5<1>:f    r4.6<0;1,0>:f     0.0:f               {F@4}
        sync.nop                             null                             {Compacted,F@2}
        math.inv (1|M0)          r3.5<1>:f     r6.7<0;1,0>:f                    {$15}
        cmp (1|M0)    (gt)f0.1   null<1>:f     r7.6<0;1,0>:f     0.0:f              
        sync.nop                             null                             {Compacted,F@2}
        math.inv (1|M0)          r4.6<1>:f     r7.7<0;1,0>:f                    {$1}
(f1.0)  sel (1|M0)               r85.6<1>:f    r1.2<0;1,0>:f     0.0:f              
        cmp (1|M0)    (gt)f1.1   null<1>:f     r6.7<0;1,0>:f     0.0:f              
        cmp (1|M0)    (gt)f1.0   null<1>:f     r7.7<0;1,0>:f     0.0:f              
        mul (1|M0)               r2.0<1>:f     r2.0<0;1,0>:f     127.0:f               {$14.dst}
        mul (1|M0)               r3.5<1>:f     r3.5<0;1,0>:f     127.0:f               {$15.dst}
        mul (1|M0)               r4.6<1>:f     r4.6<0;1,0>:f     127.0:f               {$1.dst}
        and (1|M0)               r1.2<1>:d     r44.7<0;1,0>:d    16:w               {F@6}
        asr (1|M0)               r78.3<1>:d    r4.0<0;1,0>:d     31:w               {Compacted}
        and (1|M0)               r78.4<1>:d    r44.7<0;1,0>:d    16:w              
        mov (1|M0)               r78.5<1>:d    0:w                              
        mov (1|M0)               r78.7<1>:d    0:w                              
        mov (1|M0)               r80.3<1>:d    0:w                               {$4.src}
        mov (1|M0)               r80.5<1>:d    0:w                              
        mov (1|M0)               r80.7<1>:d    0:w                              
        mov (1|M0)               r84.2<1>:d    0:w                              
        mov (1|M0)               r84.4<1>:d    0:w                              
        mov (1|M0)               r84.6<1>:d    0:w                              
        mov (1|M0)               r45.7<1>:d    0:w                              
(f0.1)  sel (1|M0)               r86.6<1>:f    r2.0<0;1,0>:f     0.0:f               {F@3}
(f1.1)  sel (1|M0)               r85.7<1>:f    r3.5<0;1,0>:f     0.0:f               {F@3}
(f1.0)  sel (1|M0)               r86.7<1>:f    r4.6<0;1,0>:f     0.0:f               {F@3}
        or (1|M0)                r78.6<1>:d    r1.2<0;1,0>:d     1:w              
        or (1|M0)                r80.2<1>:d    r1.2<0;1,0>:d     2:w              
        or (1|M0)                r80.4<1>:d    r1.2<0;1,0>:d     3:w              
        or (1|M0)                r80.6<1>:d    r1.2<0;1,0>:d     4:w              
        or (1|M0)                r84.1<1>:d    r1.2<0;1,0>:d     5:w              
        or (1|M0)                r84.3<1>:d    r1.2<0;1,0>:d     6:w              
        or (1|M0)                r84.5<1>:d    r1.2<0;1,0>:d     7:w              
L6288:
        or (1|M0)                r84.7<1>:ud   r45.7<0;1,0>:ud   r44.6<0;1,0>:ud  {I@7}
        cmp (1|M0)    (lt)f0.1   null<1>:d     r84.7<0;1,0>:d    r3.4<0;1,0>:d    {A@1}
        or (1|M0)                r89.0<1>:ud   r84.7<0;1,0>:ud   0x8:uw             
(W)     and (1|M0)               f0.1<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(~f0.1.any16h) goto (16|M0)                  L8880                  L8880                
L6368:
        asr (1|M0)               r1.3<1>:d     r84.7<0;1,0>:d    31:w              
        shl (1|M0)               r4.6<1>:d     r84.7<0;1,0>:d    2:w               {F@1}
        shr (1|M0)               r2.1<1>:ud    r84.7<0;1,0>:ud   0x1E:uw             
        shl (1|M0)               r2.0<1>:d     r1.3<0;1,0>:d     2:w               {Compacted,I@3}
        addc (1|M0)              r5.0<1>:ud    r3.2<0;1,0>:ud    r4.6<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r4.7<1>:d     r2.0<0;1,0>:d     r2.1<0;1,0>:d    {I@2}
        sync.nop                             null                             {Compacted,$7.src}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$5.src}
        sync.allrd                           ($2,$6,$9)                
        mov (1|M0)               r8.0<1>:f     r5.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r8.1<1>:d     r6.0<0;0>:d       r3.3<0;0>:d       r4.7<0>:d        {I@1}
        mov (1|M0)               r89.4<1>:d    r84.7<0;1,0>:d                  
        send.ugm (1|M0)          r90      r8      null:0  0x0            0x04100580           {A@1,$8} // wr:2+0, rd:1; load.ugm.d32.a64
        mov (1|M0)               r89.5<1>:d    r4.0<0;1,0>:d                   
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r89.2         L13232                                 {A@1}
L6608:
        shl (1|M0)               r1.3<1>:w     r45.14<0;1,0>:w   5:w              
(W)     mul (1|M0)               acc0.0<1>:d   r94.0<0;1,0>:d    r4.0<0;1,0>:uw   {Compacted}
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0x8C0:uw              {A@1}
        mach (1|M0)              r2.0<1>:d     r94.0<0;1,0>:d    r4.0<0;1,0>:d    {Compacted}
        mul (1|M0)               acc0.0<1>:d   r94.0<0;1,0>:d    r4.2<0;1,0>:uw   {Compacted}
        mach (1|M0)              r10.0<1>:d    r94.0<0;1,0>:d    r4.1<0;1,0>:d    {AccWrEn}
        mov (8|M0)               r5.0<1>:ud    r[a0.0]<1;1,0>:ud               
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0x7C0:uw              {A@1}
        mov (1|M0)               r9.0<1>:d     acc0.0<0;1,0>:d                 
        mov (8|M0)               r6.0<1>:f     r5.0<1;1,0>:d                    {Compacted,I@3}
        addc (1|M0)              r5.0<1>:ud    r9.0<0;1,0>:ud    r45.5<0;1,0>:ud  {AccWrEn,A@1}
        mov (8|M0)               r7.0<1>:ud    r[a0.0]<1;1,0>:ud               
        mov (1|M0)               r4.6<1>:d     r5.0<0;1,0>:d                    {A@1}
        mov (8|M0)               r8.0<1>:f     r7.0<1;1,0>:d                    {Compacted,I@2}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,F@1}
        mul (1|M0)               acc0.0<1>:ud  r4.6<0;1,0>:ud    r78.4<0;1,0>:uw  {I@2}
        mach (1|M0)              r12.0<1>:ud   r4.6<0;1,0>:ud    r78.2<0;1,0>:ud  {AccWrEn}
        add3 (1|M0)              r4.7<1>:d     r7.0<0;0>:d       r10.0<0;0>:d      r45.6<0>:d       {I@3}
        add (1|M0)               r1.3<1>:d     r84.7<0;1,0>:d    -r2.0<0;1,0>:d  
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r4.6<0;1,0>:d     r78.6<0;1,0>:uw 
        add (1|M0)               r1.2<1>:d     r84.7<0;1,0>:d    -r2.0<0;1,0>:d  
        mach (1|M0)              r2.0<1>:d     r4.6<0;1,0>:d     r78.3<0;1,0>:d  
(W)     mul (1|M0)               acc0.0<1>:d   r4.7<0;1,0>:d     r78.4<0;1,0>:uw  {I@6}
        mul (8|M0)               acc2.0<1>:f   r90.0<0;1,0>:f    r6.0<1;1,0>:f    {Compacted}
        mul (8|M0)               acc3.0<1>:f   r90.0<0;1,0>:f    r8.0<1;1,0>:f    {Compacted}
        mach (1|M0)              r13.0<1>:d    r4.7<0;1,0>:d     r78.2<0;1,0>:d  
        addc (1|M0)              r14.0<1>:ud   r11.0<0;1,0>:ud   r1.3<0;1,0>:ud   {AccWrEn,I@6}
        mul (8|M0)               acc2.0<1>:f   acc2.0<1;1,0>:f   r87.0<1;1,0>:f   {Compacted}
        mul (8|M0)               acc3.0<1>:f   acc3.0<1;1,0>:f   r88.0<1;1,0>:f   {Compacted}
        shl (1|M0)               r7.1<1>:d     r14.0<0;1,0>:d    5:w               {Compacted,I@1}
        asr (1|M0)               r1.4<1>:d     r1.2<0;1,0>:d     31:w              
        add3 (1|M0)              r1.6<1>:d     r13.0<0;0>:d      r12.0<0;0>:d      r2.0<0>:d       
        mov (1|M0)               r15.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mul (8|M0)               r6.0<1>:f     r85.0<1;1,0>:f    acc2.0<1;1,0>:f 
        mul (8|M0)               r8.0<1>:f     r86.0<1;1,0>:f    acc3.0<1;1,0>:f 
        addc (1|M0)              r9.0<1>:ud    r4.2<0;1,0>:ud    r7.1<0;1,0>:ud   {AccWrEn,I@4}
        add3 (1|M0)              r5.1<1>:d     r15.0<0;0>:d      r1.6<0;0>:d       r1.4<0>:d        {I@2}
        rnde (8|M0)              acc2.0<1>:f   r6.0<1;1,0>:f                    {F@2}
        rnde (8|M0)              acc3.0<1>:f   r8.0<1;1,0>:f                    {F@2}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r11.0<1>:ud   r9.0<0;1,0>:ud    r78.4<0;1,0>:ud  {AccWrEn,I@3}
        shr (1|M0)               r7.0<1>:ud    r14.0<0;1,0>:ud   0x1B:uw             
        shl (1|M0)               r3.5<1>:d     r5.1<0;1,0>:d     5:w               {I@4}
        sel (8|M0)    (ge)f0.0   acc2.0<1>:f   acc2.0<1;1,0>:f   -127.0:f              
        sel (8|M0)    (ge)f0.0   acc3.0<1>:f   acc3.0<1;1,0>:f   -127.0:f              
        mov (1|M0)               r18.0<1>:f    r11.0<0;1,0>:f                   {Compacted,I@3}
        mov (1|M0)               r12.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        or (1|M0)                r7.2<1>:d     r3.5<0;1,0>:d     r7.0<0;1,0>:d    {I@2}
        sel (8|M0)    (lt)f0.0   r6.0<1>:f     acc2.0<1;1,0>:f   127.0:f              
        sel (8|M0)    (lt)f0.0   r8.0<1>:f     acc3.0<1;1,0>:f   127.0:f              
        addc (1|M0)              r13.0<1>:ud   r18.0<0;1,0>:ud   0x8:ud              {AccWrEn,F@3}
        add3 (1|M0)              r9.2<1>:d     r10.0<0;0>:d      r4.3<0;0>:d       r7.2<0>:d        {I@2}
        mov (8|M0)               r16.0<1>:d    r6.0<1;1,0>:f                    {Compacted,F@2}
        mov (8|M0)               r5.0<1>:d     r8.0<1;1,0>:f                    {Compacted,F@1}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r11.0<1>:ud   r9.0<0;1,0>:ud    r78.6<0;1,0>:ud  {AccWrEn}
        add3 (1|M0)              r18.1<1>:d    r12.0<0;0>:d      r9.2<0;0>:d       r78.5<0>:d       {I@5}
        mov (4|M0)               r2.0<1>:b     r16.0<1;1,0>:b                   {I@5}
        mov (4|M0)               r1.6<1>:b     r5.0<1;1,0>:b                    {I@5}
        mov (1|M0)               r12.0<1>:f    r11.0<0;1,0>:f                   {Compacted,A@3}
        mov (1|M0)               r6.0<1>:f     r13.0<0;1,0>:f                   {Compacted}
        add3 (1|M0)              r6.1<1>:d     r7.0<0;0>:d       r18.1<0;0>:d      0:w              
        mov (1|M0)               r20.0<1>:d    r2.0<0;1,0>:ub                   {I@3}
        mov (1|M0)               r10.0<1>:d    r1.6<0;1,0>:ub                   {I@3}
        mov (1|M0)               r2.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r13.0<1>:ud   r12.0<0;1,0>:ud   0x8:ud              {AccWrEn,A@1}
        send.ugm (1|M0)          null     r18     r20:1   0x0            0x04000984           {A@4,$14} // wr:2+1, rd:0; store.ugm.d8u32.a64
        send.ugm (1|M0)          null     r6      r10:1   0x0            0x04000984           {A@3,$15} // wr:2+1, rd:0; store.ugm.d8u32.a64
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$15.src}
        addc (1|M0)              r10.0<1>:ud   r9.0<0;1,0>:ud    r80.2<0;1,0>:ud  {AccWrEn}
        mov (4|M0)               r3.20<1>:b    r16.4<1;1,0>:b                  
        sync.nop                             null                             {Compacted,$14.src}
        mov (1|M0)               r18.0<1>:f    r10.0<0;1,0>:f                   {Compacted,I@2}
        mov (4|M0)               r4.24<1>:b    r5.4<1;1,0>:b                   
        add3 (1|M0)              r12.1<1>:d    r2.0<0;0>:d       r9.2<0;0>:d       r78.7<0>:d      
        mov (1|M0)               r2.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r11.0<1>:ud   r18.0<0;1,0>:ud   0x8:ud              {AccWrEn,F@1}
        mov (1|M0)               r14.0<1>:f    r13.0<0;1,0>:f                   {Compacted}
        mov (1|M0)               r8.0<1>:d     r3.20<0;1,0>:ub                  {I@5}
        mov (1|M0)               r6.0<1>:d     r4.24<0;1,0>:ub                  {I@5}
        add3 (1|M0)              r14.1<1>:d    r7.0<0;0>:d       r12.1<0;0>:d      0:w               {I@5}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r10.0<1>:ud   r9.0<0;1,0>:ud    r80.4<0;1,0>:ud  {AccWrEn}
        send.ugm (1|M0)          null     r12     r8:1    0x0            0x04000984           {A@5,$1} // wr:2+1, rd:0; store.ugm.d8u32.a64
        send.ugm (1|M0)          null     r14     r6:1    0x0            0x04000984           {A@1,$8} // wr:2+1, rd:0; store.ugm.d8u32.a64
        sync.nop                             null                             {Compacted,$8.src}
        mov (1|M0)               r14.0<1>:f    r10.0<0;1,0>:f                   {Compacted,I@1}
        mov (4|M0)               r1.6<1>:b     r16.8<1;1,0>:b                  
        add3 (1|M0)              r18.1<1>:d    r2.0<0;0>:d       r9.2<0;0>:d       r80.3<0>:d      
        mov (4|M0)               r3.20<1>:b    r5.8<1;1,0>:b                   
        mov (1|M0)               r12.0<1>:f    r11.0<0;1,0>:f                   {Compacted,$1.src}
        mov (1|M0)               r2.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r11.0<1>:ud   r14.0<0;1,0>:ud   0x8:ud              {AccWrEn,A@1}
        mov (1|M0)               r8.0<1>:d     r1.6<0;1,0>:ub                   {I@5}
        add3 (1|M0)              r12.1<1>:d    r7.0<0;0>:d       r18.1<0;0>:d      0:w               {I@5}
        mov (1|M0)               r6.0<1>:d     r3.20<0;1,0>:ub                  {I@5}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r10.0<1>:ud   r9.0<0;1,0>:ud    r80.6<0;1,0>:ud  {AccWrEn}
        send.ugm (1|M0)          null     r18     r8:1    0x0            0x04000984           {A@5,$13} // wr:2+1, rd:0; store.ugm.d8u32.a64
        send.ugm (1|M0)          null     r12     r6:1    0x0            0x04000984           {A@3,$11} // wr:2+1, rd:0; store.ugm.d8u32.a64
        sync.nop                             null                             {Compacted,$11.src}
        mov (1|M0)               r12.0<1>:f    r10.0<0;1,0>:f                   {Compacted,I@1}
        mov (4|M0)               r4.24<1>:b    r16.12<1;1,0>:b                 
        add3 (1|M0)              r14.1<1>:d    r2.0<0;0>:d       r9.2<0;0>:d       r80.5<0>:d      
        mov (4|M0)               r1.6<1>:b     r5.12<1;1,0>:b                  
        mov (1|M0)               r18.0<1>:f    r11.0<0;1,0>:f                   {Compacted,$13.src}
        mov (1|M0)               r2.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r11.0<1>:ud   r12.0<0;1,0>:ud   0x8:ud              {AccWrEn,A@1}
        mov (1|M0)               r8.0<1>:d     r4.24<0;1,0>:ub                  {I@5}
        add3 (1|M0)              r18.1<1>:d    r7.0<0;0>:d       r14.1<0;0>:d      0:w               {I@5}
        mov (1|M0)               r6.0<1>:d     r1.6<0;1,0>:ub                   {I@5}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r10.0<1>:ud   r9.0<0;1,0>:ud    r84.1<0;1,0>:ud  {AccWrEn}
        send.ugm (1|M0)          null     r14     r8:1    0x0            0x04000984           {A@5,$12} // wr:2+1, rd:0; store.ugm.d8u32.a64
        send.ugm (1|M0)          null     r18     r6:1    0x0            0x04000984           {A@3,$9} // wr:2+1, rd:0; store.ugm.d8u32.a64
        sync.nop                             null                             {Compacted,$9.src}
        mov (1|M0)               r18.0<1>:f    r10.0<0;1,0>:f                   {Compacted,I@1}
        mov (4|M0)               r3.20<1>:b    r16.16<1;1,0>:b                 
        add3 (1|M0)              r12.1<1>:d    r2.0<0;0>:d       r9.2<0;0>:d       r80.7<0>:d      
        mov (4|M0)               r4.24<1>:b    r5.16<1;1,0>:b                  
        mov (1|M0)               r14.0<1>:f    r11.0<0;1,0>:f                   {Compacted,$12.src}
        mov (1|M0)               r2.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r11.0<1>:ud   r18.0<0;1,0>:ud   0x8:ud              {AccWrEn,A@1}
        mov (1|M0)               r8.0<1>:d     r3.20<0;1,0>:ub                  {I@5}
        add3 (1|M0)              r14.1<1>:d    r7.0<0;0>:d       r12.1<0;0>:d      0:w               {I@5}
        mov (1|M0)               r6.0<1>:d     r4.24<0;1,0>:ub                  {I@5}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r10.0<1>:ud   r9.0<0;1,0>:ud    r84.3<0;1,0>:ud  {AccWrEn}
        send.ugm (1|M0)          null     r12     r8:1    0x0            0x04000984           {A@5,$15} // wr:2+1, rd:0; store.ugm.d8u32.a64
        send.ugm (1|M0)          null     r14     r6:1    0x0            0x04000984           {A@3,$14} // wr:2+1, rd:0; store.ugm.d8u32.a64
        sync.nop                             null                             {Compacted,$14.src}
        mov (1|M0)               r14.0<1>:f    r10.0<0;1,0>:f                   {Compacted,I@1}
        mov (4|M0)               r1.6<1>:b     r16.20<1;1,0>:b                 
        add3 (1|M0)              r18.1<1>:d    r2.0<0;0>:d       r9.2<0;0>:d       r84.2<0>:d      
        mov (4|M0)               r3.20<1>:b    r5.20<1;1,0>:b                  
        mov (1|M0)               r12.0<1>:f    r11.0<0;1,0>:f                   {Compacted,$15.src}
        mov (1|M0)               r2.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r11.0<1>:ud   r14.0<0;1,0>:ud   0x8:ud              {AccWrEn,A@1}
        mov (1|M0)               r8.0<1>:d     r1.6<0;1,0>:ub                   {I@5}
        add3 (1|M0)              r12.1<1>:d    r7.0<0;0>:d       r18.1<0;0>:d      0:w               {I@5}
        mov (1|M0)               r6.0<1>:d     r3.20<0;1,0>:ub                  {I@5}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r10.0<1>:ud   r9.0<0;1,0>:ud    r84.5<0;1,0>:ud  {AccWrEn}
        send.ugm (1|M0)          null     r18     r8:1    0x0            0x04000984           {A@5,$8} // wr:2+1, rd:0; store.ugm.d8u32.a64
        send.ugm (1|M0)          null     r12     r6:1    0x0            0x04000984           {A@3,$1} // wr:2+1, rd:0; store.ugm.d8u32.a64
        sync.nop                             null                             {Compacted,$1.src}
        mov (1|M0)               r12.0<1>:f    r10.0<0;1,0>:f                   {Compacted,I@1}
        mov (4|M0)               r4.24<1>:b    r16.24<1;1,0>:b                 
        add3 (1|M0)              r14.1<1>:d    r2.0<0;0>:d       r9.2<0;0>:d       r84.4<0>:d      
        mov (4|M0)               r1.6<1>:b     r5.24<1;1,0>:b                  
        mov (1|M0)               r18.0<1>:f    r11.0<0;1,0>:f                   {Compacted,$8.src}
        mov (1|M0)               r2.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r11.0<1>:ud   r12.0<0;1,0>:ud   0x8:ud              {AccWrEn,A@1}
        mov (4|M0)               r3.20<1>:b    r16.28<1;1,0>:b                 
        mov (1|M0)               r8.0<1>:d     r4.24<0;1,0>:ub                  {I@6}
        add3 (1|M0)              r18.1<1>:d    r7.0<0;0>:d       r14.1<0;0>:d      0:w               {I@6}
        mov (1|M0)               r6.0<1>:d     r1.6<0;1,0>:ub                   {I@6}
        add3 (1|M0)              r12.1<1>:d    r2.0<0;0>:d       r9.2<0;0>:d       r84.6<0>:d       {I@6}
        mov (4|M0)               r4.24<1>:b    r5.28<1;1,0>:b                  
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        send.ugm (1|M0)          null     r14     r8:1    0x0            0x04000984           {A@6,$10} // wr:2+1, rd:0; store.ugm.d8u32.a64
        send.ugm (1|M0)          null     r18     r6:1    0x0            0x04000984           {A@4,$0} // wr:2+1, rd:0; store.ugm.d8u32.a64
        mov (1|M0)               r8.0<1>:d     r3.20<0;1,0>:ub                  {$10.src}
        mov (1|M0)               r14.0<1>:f    r11.0<0;1,0>:f                   {Compacted}
        add3 (1|M0)              r14.1<1>:d    r7.0<0;0>:d       r12.1<0;0>:d      0:w               {I@2}
        mov (1|M0)               r6.0<1>:d     r4.24<0;1,0>:ub                  {$0.src}
        send.ugm (1|M0)          null     r12     r8:1    0x0            0x04000984           {A@3,$2} // wr:2+1, rd:0; store.ugm.d8u32.a64
        send.ugm (1|M0)          null     r14     r6:1    0x0            0x04000984           {A@1,$5} // wr:2+1, rd:0; store.ugm.d8u32.a64
L8880:
        join (16|M0)                         L11504                                
L8896:
        cmp (1|M0)    (lt)f1.1   null<1>:d     r89.0<0;1,0>:d    r3.4<0;1,0>:d   
(W)     and (1|M0)               f1.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(~f1.1.any16h) goto (16|M0)                  L11424                  L11424                
L8944:
        asr (1|M0)               r1.3<1>:d     r89.0<0;1,0>:d    31:w               {Compacted}
        shl (1|M0)               r4.6<1>:d     r89.0<0;1,0>:d    2:w               {Compacted}
        shr (1|M0)               r2.1<1>:ud    r89.0<0;1,0>:ud   0x1E:uw             
        shl (1|M0)               r2.0<1>:d     r1.3<0;1,0>:d     2:w               {Compacted,I@3}
        addc (1|M0)              r5.0<1>:ud    r3.2<0;1,0>:ud    r4.6<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r4.7<1>:d     r2.0<0;1,0>:d     r2.1<0;1,0>:d    {I@2}
        sync.nop                             null                             {Compacted,$7.src}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$5.src}
        sync.allrd                           ($2,$6,$9)                
        mov (1|M0)               r8.0<1>:f     r5.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r8.1<1>:d     r6.0<0;0>:d       r3.3<0;0>:d       r4.7<0>:d        {I@1}
        mov (1|M0)               r89.4<1>:d    r89.0<0;1,0>:d                  
        send.ugm (1|M0)          r91      r8      null:0  0x0            0x04100580           {A@1,$14} // wr:2+0, rd:1; load.ugm.d32.a64
        mov (1|M0)               r89.5<1>:d    r4.0<0;1,0>:d                   
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r89.2         L13232                                 {A@1}
L9168:
        shl (1|M0)               r1.3<1>:w     r45.14<0;1,0>:w   5:w              
(W)     mul (1|M0)               acc0.0<1>:d   r94.0<0;1,0>:d    r4.0<0;1,0>:uw   {Compacted}
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0x6C0:uw              {A@1}
        mach (1|M0)              r2.0<1>:d     r94.0<0;1,0>:d    r4.0<0;1,0>:d    {Compacted}
        mul (1|M0)               acc0.0<1>:d   r94.0<0;1,0>:d    r4.2<0;1,0>:uw   {Compacted}
        mach (1|M0)              r10.0<1>:d    r94.0<0;1,0>:d    r4.1<0;1,0>:d    {AccWrEn}
        mov (8|M0)               r5.0<1>:ud    r[a0.0]<1;1,0>:ud               
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0x5C0:uw              {A@1}
        mov (1|M0)               r9.0<1>:d     acc0.0<0;1,0>:d                 
        mov (8|M0)               r6.0<1>:f     r5.0<1;1,0>:d                    {Compacted,I@3}
        addc (1|M0)              r5.0<1>:ud    r9.0<0;1,0>:ud    r45.5<0;1,0>:ud  {AccWrEn,A@1}
        mov (8|M0)               r7.0<1>:ud    r[a0.0]<1;1,0>:ud               
        mov (1|M0)               r4.6<1>:d     r5.0<0;1,0>:d                    {A@1}
        mov (8|M0)               r8.0<1>:f     r7.0<1;1,0>:d                    {Compacted,I@2}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,F@1}
        mul (1|M0)               acc0.0<1>:ud  r4.6<0;1,0>:ud    r78.4<0;1,0>:uw  {I@2}
        mach (1|M0)              r12.0<1>:ud   r4.6<0;1,0>:ud    r78.2<0;1,0>:ud  {AccWrEn}
        add3 (1|M0)              r4.7<1>:d     r7.0<0;0>:d       r10.0<0;0>:d      r45.6<0>:d       {I@3}
        add (1|M0)               r1.3<1>:d     r89.0<0;1,0>:d    -r2.0<0;1,0>:d   {Compacted}
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r4.6<0;1,0>:d     r78.6<0;1,0>:uw 
        add (1|M0)               r1.2<1>:d     r89.0<0;1,0>:d    -r2.0<0;1,0>:d   {Compacted}
        mach (1|M0)              r2.0<1>:d     r4.6<0;1,0>:d     r78.3<0;1,0>:d  
(W)     mul (1|M0)               acc0.0<1>:d   r4.7<0;1,0>:d     r78.4<0;1,0>:uw  {I@6}
        mul (8|M0)               acc2.0<1>:f   r91.0<0;1,0>:f    r6.0<1;1,0>:f    {Compacted}
        mul (8|M0)               acc3.0<1>:f   r91.0<0;1,0>:f    r8.0<1;1,0>:f    {Compacted}
        mach (1|M0)              r13.0<1>:d    r4.7<0;1,0>:d     r78.2<0;1,0>:d  
        addc (1|M0)              r14.0<1>:ud   r11.0<0;1,0>:ud   r1.3<0;1,0>:ud   {AccWrEn,I@6}
        mul (8|M0)               acc2.0<1>:f   acc2.0<1;1,0>:f   r87.0<1;1,0>:f   {Compacted}
        mul (8|M0)               acc3.0<1>:f   acc3.0<1;1,0>:f   r88.0<1;1,0>:f   {Compacted}
        shl (1|M0)               r7.1<1>:d     r14.0<0;1,0>:d    5:w               {Compacted,I@1}
        asr (1|M0)               r1.4<1>:d     r1.2<0;1,0>:d     31:w              
        add3 (1|M0)              r1.6<1>:d     r13.0<0;0>:d      r12.0<0;0>:d      r2.0<0>:d       
        mov (1|M0)               r15.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mul (8|M0)               r6.0<1>:f     r85.0<1;1,0>:f    acc2.0<1;1,0>:f 
        mul (8|M0)               r8.0<1>:f     r86.0<1;1,0>:f    acc3.0<1;1,0>:f 
        addc (1|M0)              r9.0<1>:ud    r4.2<0;1,0>:ud    r7.1<0;1,0>:ud   {AccWrEn,I@4}
        add3 (1|M0)              r5.1<1>:d     r15.0<0;0>:d      r1.6<0;0>:d       r1.4<0>:d        {I@2}
        rnde (8|M0)              acc2.0<1>:f   r6.0<1;1,0>:f                    {F@2}
        rnde (8|M0)              acc3.0<1>:f   r8.0<1;1,0>:f                    {F@2}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r11.0<1>:ud   r9.0<0;1,0>:ud    r78.4<0;1,0>:ud  {AccWrEn,I@3}
        shr (1|M0)               r7.0<1>:ud    r14.0<0;1,0>:ud   0x1B:uw             
        shl (1|M0)               r3.5<1>:d     r5.1<0;1,0>:d     5:w               {I@4}
        sel (8|M0)    (ge)f0.0   acc2.0<1>:f   acc2.0<1;1,0>:f   -127.0:f              
        sel (8|M0)    (ge)f0.0   acc3.0<1>:f   acc3.0<1;1,0>:f   -127.0:f              
        mov (1|M0)               r18.0<1>:f    r11.0<0;1,0>:f                   {Compacted,I@3}
        mov (1|M0)               r12.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        or (1|M0)                r7.2<1>:d     r3.5<0;1,0>:d     r7.0<0;1,0>:d    {I@2}
        sel (8|M0)    (lt)f0.0   r6.0<1>:f     acc2.0<1;1,0>:f   127.0:f              
        sel (8|M0)    (lt)f0.0   r8.0<1>:f     acc3.0<1;1,0>:f   127.0:f              
        addc (1|M0)              r13.0<1>:ud   r18.0<0;1,0>:ud   0x8:ud              {AccWrEn,F@3}
        add3 (1|M0)              r9.2<1>:d     r10.0<0;0>:d      r4.3<0;0>:d       r7.2<0>:d        {I@2}
        mov (8|M0)               r16.0<1>:d    r6.0<1;1,0>:f                    {Compacted,F@2}
        mov (8|M0)               r5.0<1>:d     r8.0<1;1,0>:f                    {Compacted,F@1}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r11.0<1>:ud   r9.0<0;1,0>:ud    r78.6<0;1,0>:ud  {AccWrEn}
        add3 (1|M0)              r18.1<1>:d    r12.0<0;0>:d      r9.2<0;0>:d       r78.5<0>:d       {I@5}
        mov (4|M0)               r2.0<1>:b     r16.0<1;1,0>:b                   {I@5}
        mov (4|M0)               r1.6<1>:b     r5.0<1;1,0>:b                    {I@5}
        mov (1|M0)               r12.0<1>:f    r11.0<0;1,0>:f                   {Compacted,A@3}
        mov (1|M0)               r6.0<1>:f     r13.0<0;1,0>:f                   {Compacted}
        add3 (1|M0)              r6.1<1>:d     r7.0<0;0>:d       r18.1<0;0>:d      0:w              
        mov (1|M0)               r20.0<1>:d    r2.0<0;1,0>:ub                   {I@3}
        mov (1|M0)               r10.0<1>:d    r1.6<0;1,0>:ub                   {I@3}
        mov (1|M0)               r2.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r13.0<1>:ud   r12.0<0;1,0>:ud   0x8:ud              {AccWrEn,A@1}
        send.ugm (1|M0)          null     r18     r20:1   0x0            0x04000984           {A@4,$15} // wr:2+1, rd:0; store.ugm.d8u32.a64
        send.ugm (1|M0)          null     r6      r10:1   0x0            0x04000984           {A@3,$1} // wr:2+1, rd:0; store.ugm.d8u32.a64
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$1.src}
        addc (1|M0)              r10.0<1>:ud   r9.0<0;1,0>:ud    r80.2<0;1,0>:ud  {AccWrEn}
        mov (4|M0)               r3.20<1>:b    r16.4<1;1,0>:b                  
        sync.nop                             null                             {Compacted,$15.src}
        mov (1|M0)               r18.0<1>:f    r10.0<0;1,0>:f                   {Compacted,I@2}
        mov (4|M0)               r4.24<1>:b    r5.4<1;1,0>:b                   
        add3 (1|M0)              r12.1<1>:d    r2.0<0;0>:d       r9.2<0;0>:d       r78.7<0>:d      
        mov (1|M0)               r2.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r11.0<1>:ud   r18.0<0;1,0>:ud   0x8:ud              {AccWrEn,F@1}
        mov (1|M0)               r14.0<1>:f    r13.0<0;1,0>:f                   {Compacted}
        mov (1|M0)               r8.0<1>:d     r3.20<0;1,0>:ub                  {I@5}
        mov (1|M0)               r6.0<1>:d     r4.24<0;1,0>:ub                  {I@5}
        add3 (1|M0)              r14.1<1>:d    r7.0<0;0>:d       r12.1<0;0>:d      0:w               {I@5}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r10.0<1>:ud   r9.0<0;1,0>:ud    r80.4<0;1,0>:ud  {AccWrEn}
        send.ugm (1|M0)          null     r12     r8:1    0x0            0x04000984           {A@5,$8} // wr:2+1, rd:0; store.ugm.d8u32.a64
        send.ugm (1|M0)          null     r14     r6:1    0x0            0x04000984           {A@1,$14} // wr:2+1, rd:0; store.ugm.d8u32.a64
        sync.nop                             null                             {Compacted,$14.src}
        mov (1|M0)               r14.0<1>:f    r10.0<0;1,0>:f                   {Compacted,I@1}
        mov (4|M0)               r1.6<1>:b     r16.8<1;1,0>:b                  
        add3 (1|M0)              r18.1<1>:d    r2.0<0;0>:d       r9.2<0;0>:d       r80.3<0>:d      
        mov (4|M0)               r3.20<1>:b    r5.8<1;1,0>:b                   
        mov (1|M0)               r12.0<1>:f    r11.0<0;1,0>:f                   {Compacted,$8.src}
        mov (1|M0)               r2.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r11.0<1>:ud   r14.0<0;1,0>:ud   0x8:ud              {AccWrEn,A@1}
        mov (1|M0)               r8.0<1>:d     r1.6<0;1,0>:ub                   {I@5}
        add3 (1|M0)              r12.1<1>:d    r7.0<0;0>:d       r18.1<0;0>:d      0:w               {I@5}
        mov (1|M0)               r6.0<1>:d     r3.20<0;1,0>:ub                  {I@5}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r10.0<1>:ud   r9.0<0;1,0>:ud    r80.6<0;1,0>:ud  {AccWrEn}
        send.ugm (1|M0)          null     r18     r8:1    0x0            0x04000984           {A@5,$3} // wr:2+1, rd:0; store.ugm.d8u32.a64
        send.ugm (1|M0)          null     r12     r6:1    0x0            0x04000984           {A@3,$4} // wr:2+1, rd:0; store.ugm.d8u32.a64
        sync.nop                             null                             {Compacted,$4.src}
        mov (1|M0)               r12.0<1>:f    r10.0<0;1,0>:f                   {Compacted,I@1}
        mov (4|M0)               r4.24<1>:b    r16.12<1;1,0>:b                 
        add3 (1|M0)              r14.1<1>:d    r2.0<0;0>:d       r9.2<0;0>:d       r80.5<0>:d      
        mov (4|M0)               r1.6<1>:b     r5.12<1;1,0>:b                  
        mov (1|M0)               r18.0<1>:f    r11.0<0;1,0>:f                   {Compacted,$3.src}
        mov (1|M0)               r2.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r11.0<1>:ud   r12.0<0;1,0>:ud   0x8:ud              {AccWrEn,A@1}
        mov (1|M0)               r8.0<1>:d     r4.24<0;1,0>:ub                  {I@5}
        add3 (1|M0)              r18.1<1>:d    r7.0<0;0>:d       r14.1<0;0>:d      0:w               {I@5}
        mov (1|M0)               r6.0<1>:d     r1.6<0;1,0>:ub                   {I@5}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r10.0<1>:ud   r9.0<0;1,0>:ud    r84.1<0;1,0>:ud  {AccWrEn}
        send.ugm (1|M0)          null     r14     r8:1    0x0            0x04000984           {A@5,$13} // wr:2+1, rd:0; store.ugm.d8u32.a64
        send.ugm (1|M0)          null     r18     r6:1    0x0            0x04000984           {A@3,$11} // wr:2+1, rd:0; store.ugm.d8u32.a64
        sync.nop                             null                             {Compacted,$11.src}
        mov (1|M0)               r18.0<1>:f    r10.0<0;1,0>:f                   {Compacted,I@1}
        mov (4|M0)               r3.20<1>:b    r16.16<1;1,0>:b                 
        add3 (1|M0)              r12.1<1>:d    r2.0<0;0>:d       r9.2<0;0>:d       r80.7<0>:d      
        mov (4|M0)               r4.24<1>:b    r5.16<1;1,0>:b                  
        mov (1|M0)               r14.0<1>:f    r11.0<0;1,0>:f                   {Compacted,$13.src}
        mov (1|M0)               r2.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r11.0<1>:ud   r18.0<0;1,0>:ud   0x8:ud              {AccWrEn,A@1}
        mov (1|M0)               r8.0<1>:d     r3.20<0;1,0>:ub                  {I@5}
        add3 (1|M0)              r14.1<1>:d    r7.0<0;0>:d       r12.1<0;0>:d      0:w               {I@5}
        mov (1|M0)               r6.0<1>:d     r4.24<0;1,0>:ub                  {I@5}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r10.0<1>:ud   r9.0<0;1,0>:ud    r84.3<0;1,0>:ud  {AccWrEn}
        send.ugm (1|M0)          null     r12     r8:1    0x0            0x04000984           {A@5,$1} // wr:2+1, rd:0; store.ugm.d8u32.a64
        send.ugm (1|M0)          null     r14     r6:1    0x0            0x04000984           {A@3,$15} // wr:2+1, rd:0; store.ugm.d8u32.a64
        sync.nop                             null                             {Compacted,$15.src}
        mov (1|M0)               r14.0<1>:f    r10.0<0;1,0>:f                   {Compacted,I@1}
        mov (4|M0)               r1.6<1>:b     r16.20<1;1,0>:b                 
        add3 (1|M0)              r18.1<1>:d    r2.0<0;0>:d       r9.2<0;0>:d       r84.2<0>:d      
        mov (4|M0)               r3.20<1>:b    r5.20<1;1,0>:b                  
        mov (1|M0)               r12.0<1>:f    r11.0<0;1,0>:f                   {Compacted,$1.src}
        mov (1|M0)               r2.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r11.0<1>:ud   r14.0<0;1,0>:ud   0x8:ud              {AccWrEn,A@1}
        mov (1|M0)               r8.0<1>:d     r1.6<0;1,0>:ub                   {I@5}
        add3 (1|M0)              r12.1<1>:d    r7.0<0;0>:d       r18.1<0;0>:d      0:w               {I@5}
        mov (1|M0)               r6.0<1>:d     r3.20<0;1,0>:ub                  {I@5}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r10.0<1>:ud   r9.0<0;1,0>:ud    r84.5<0;1,0>:ud  {AccWrEn}
        send.ugm (1|M0)          null     r18     r8:1    0x0            0x04000984           {A@5,$14} // wr:2+1, rd:0; store.ugm.d8u32.a64
        send.ugm (1|M0)          null     r12     r6:1    0x0            0x04000984           {A@3,$8} // wr:2+1, rd:0; store.ugm.d8u32.a64
        sync.nop                             null                             {Compacted,$8.src}
        mov (1|M0)               r12.0<1>:f    r10.0<0;1,0>:f                   {Compacted,I@1}
        mov (4|M0)               r4.24<1>:b    r16.24<1;1,0>:b                 
        add3 (1|M0)              r14.1<1>:d    r2.0<0;0>:d       r9.2<0;0>:d       r84.4<0>:d      
        mov (4|M0)               r1.6<1>:b     r5.24<1;1,0>:b                  
        mov (1|M0)               r18.0<1>:f    r11.0<0;1,0>:f                   {Compacted,$14.src}
        mov (1|M0)               r2.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r11.0<1>:ud   r12.0<0;1,0>:ud   0x8:ud              {AccWrEn,A@1}
        mov (4|M0)               r3.20<1>:b    r16.28<1;1,0>:b                 
        mov (1|M0)               r8.0<1>:d     r4.24<0;1,0>:ub                  {I@6}
        add3 (1|M0)              r18.1<1>:d    r7.0<0;0>:d       r14.1<0;0>:d      0:w               {I@6}
        mov (1|M0)               r6.0<1>:d     r1.6<0;1,0>:ub                   {I@6}
        add3 (1|M0)              r12.1<1>:d    r2.0<0;0>:d       r9.2<0;0>:d       r84.6<0>:d       {I@6}
        mov (4|M0)               r4.24<1>:b    r5.28<1;1,0>:b                  
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        send.ugm (1|M0)          null     r14     r8:1    0x0            0x04000984           {A@6,$12} // wr:2+1, rd:0; store.ugm.d8u32.a64
        send.ugm (1|M0)          null     r18     r6:1    0x0            0x04000984           {A@4,$9} // wr:2+1, rd:0; store.ugm.d8u32.a64
        mov (1|M0)               r8.0<1>:d     r3.20<0;1,0>:ub                  {$12.src}
        mov (1|M0)               r14.0<1>:f    r11.0<0;1,0>:f                   {Compacted}
        add3 (1|M0)              r14.1<1>:d    r7.0<0;0>:d       r12.1<0;0>:d      0:w               {I@2}
        mov (1|M0)               r6.0<1>:d     r4.24<0;1,0>:ub                  {$9.src}
        send.ugm (1|M0)          null     r12     r8:1    0x0            0x04000984           {A@3,$6} // wr:2+1, rd:0; store.ugm.d8u32.a64
        send.ugm (1|M0)          null     r14     r6:1    0x0            0x04000984           {A@1,$7} // wr:2+1, rd:0; store.ugm.d8u32.a64
L11424:
        join (16|M0)                         L11504                                
L11440:
        add (1|M0)               r45.7<1>:ud   r45.7<0;1,0>:ud   0x1:uw             
        cmp (1|M0)    (eq)f1.0   null<1>:d     r45.7<0;1,0>:d    8:w               {I@1}
(W)     and (1|M0)               f1.0<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
(~f1.0.any16h) goto.b (16|M0)                L11504                  L6288                
L11504:
        join (16|M0)                         L11520                                
L11520:
        and (1|M0)               r2.0<1>:d     r1.0<0;1,0>:uw    0xFFFC:uw             
(W)     mov (1|M0)               r1.3<1>:hf    0x1:hf                             
        cmp (1|M0)    (eq)f1.1   null<1>:d     r2.0<0;1,0>:d     16:w               {I@1}
(f0.0)  sel (1|M0)               r89.1<1>:d    r1.3<0;1,0>:w     0:w               {F@1}
(~f1.1) cmp (1|M0)    (lt)f1.1   null<1>:uw    r1.0<0;1,0>:uw    0x4:uw             
(W)     and (1|M0)               f0.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(~f0.1.any16h) goto (16|M0)                  L13160                  L13160                
L11632:
        send.slm (1|M0)          r92      r84     null:0  0x0            0x0220C700           {$15} // wr:1+0, rd:2; load.slm.d64x8t.a32
        mov (1|M0)               r89.4<1>:d    128:w                              
        mov (1|M0)               r89.5<1>:d    r4.0<0;1,0>:d                   
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r89.2         L13232                                 {A@1}
L11728:
(W)     mul (1|M0)               acc0.0<1>:d   r94.0<0;1,0>:d    r42.4<0;1,0>:uw  {Compacted}
        mach (1|M0)              r94.0<1>:d    r94.0<0;1,0>:d    r42.2<0;1,0>:d   {Compacted}
        shl (1|M0)               r1.3<1>:d     r42.4<0;1,0>:d    2:w              
        add (1|M0)               r94.0<1>:d    r94.0<0;1,0>:d    r89.1<0;1,0>:d   {Compacted,I@2}
        shl (1|M0)               r8.0<1>:d     r44.7<0;1,0>:d    2:w               {Compacted}
        mul (1|M0)               acc0.0<1>:d   r94.0<0;1,0>:d    r2.12<0;1,0>:uw  {Compacted,I@2}
        mach (1|M0)              r6.0<1>:d     r94.0<0;1,0>:d    r2.6<0;1,0>:d    {AccWrEn}
        shr (1|M0)               r1.2<1>:ud    r42.4<0;1,0>:ud   0x1E:uw             
        mov (1|M0)               r5.0<1>:d     acc0.0<0;1,0>:d                 
        addc (1|M0)              r2.0<1>:ud    r4.4<0;1,0>:ud    r1.3<0;1,0>:ud   {AccWrEn}
        shl (1|M0)               r9.4<1>:d     r5.0<0;1,0>:d     2:w               {Compacted,I@2}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r9.0<1>:ud    r2.0<0;1,0>:ud    r8.0<0;1,0>:ud   {AccWrEn,I@3}
        shr (1|M0)               r2.1<1>:ud    r44.7<0;1,0>:ud   0x1E:uw             
        or (1|M0)                r1.4<1>:d     r1.2<0;1,0>:d     0:w              
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r11.0<1>:ud   r9.0<0;1,0>:ud    r9.4<0;1,0>:ud   {AccWrEn,I@4}
        shl (1|M0)               r3.5<1>:d     r6.0<0;1,0>:d     2:w               {Compacted}
        shr (1|M0)               r9.3<1>:ud    r5.0<0;1,0>:ud    0x1E:uw             
        or (1|M0)                r8.1<1>:d     r2.1<0;1,0>:d     0:w               {Compacted,I@6}
        add3 (1|M0)              r4.7<1>:d     r7.0<0;0>:d       r4.5<0;0>:d       r1.4<0>:d        {I@6}
        mov (1|M0)               r12.0<1>:f    r11.0<0;1,0>:f                   {Compacted,I@5}
        or (1|M0)                r9.5<1>:d     r3.5<0;1,0>:d     r9.3<0;1,0>:d    {I@3}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        add3 (1|M0)              r9.2<1>:d     r10.0<0;0>:d      r4.7<0;0>:d       r8.1<0>:d        {I@3}
        addc (1|M0)              r2.0<1>:ud    r12.0<0;1,0>:ud   0x4:ud              {AccWrEn,F@1}
        mul (16|M0)              r92.0<1>:f    r92.0<1;1,0>:f    7.874016e-03:f              
        add3 (1|M0)              r12.1<1>:d    r7.0<0;0>:d       r9.2<0;0>:d       r9.5<0>:d        {I@2}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r5.0<1>:ud    r12.0<0;1,0>:ud   0x8:ud              {AccWrEn}
        mov (1|M0)               r10.0<1>:f    r2.0<0;1,0>:f                    {Compacted,I@4}
        mov (1|M0)               r6.0<1>:f     r92.1<0;1,0>:f                   {Compacted,F@2}
        add3 (1|M0)              r10.1<1>:d    r8.0<0;0>:d       r12.1<0;0>:d      0:w               {I@2}
        mov (1|M0)               r13.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r7.0<1>:ud    r12.0<0;1,0>:ud   0xC:ud              {AccWrEn}
        send.ugm (1|M0)          null     r12     r92:1   0x0            0x04000584           {A@2,$1} // wr:2+1, rd:0; store.ugm.d32.a64
        send.ugm (1|M0)          null     r10     r6:1    0x0            0x04000584           {A@1,$2} // wr:2+1, rd:0; store.ugm.d32.a64
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r6.0<1>:ud    r12.0<0;1,0>:ud   0x10:ud              {AccWrEn,$2.src}
        mov (1|M0)               r16.0<1>:f    r92.2<0;1,0>:f                   {Compacted}
        mov (1|M0)               r14.0<1>:f    r5.0<0;1,0>:f                    {Compacted}
        mov (1|M0)               r8.0<1>:f     r92.3<0;1,0>:f                   {Compacted}
        add3 (1|M0)              r14.1<1>:d    r13.0<0;0>:d      r12.1<0;0>:d      0:w              
        mov (1|M0)               r2.0<1>:f     r7.0<0;1,0>:f                    {Compacted,I@4}
        add3 (1|M0)              r2.1<1>:d     r9.0<0;0>:d       r12.1<0;0>:d      0:w               {I@3}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r5.0<1>:ud    r12.0<0;1,0>:ud   0x14:ud              {AccWrEn,F@3}
        send.ugm (1|M0)          null     r14     r16:1   0x0            0x04000584           {A@4,$3} // wr:2+1, rd:0; store.ugm.d32.a64
        send.ugm (1|M0)          null     r2      r8:1    0x0            0x04000584           {A@1,$4} // wr:2+1, rd:0; store.ugm.d32.a64
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r2.0<1>:ud    r12.0<0;1,0>:ud   0x18:ud              {AccWrEn,$4.src}
        mov (1|M0)               r20.0<1>:f    r92.4<0;1,0>:f                   {Compacted}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r9.0<1>:ud    r12.0<0;1,0>:ud   0x1C:ud              {AccWrEn}
        mov (1|M0)               r18.0<1>:f    r6.0<0;1,0>:f                    {Compacted}
        add3 (1|M0)              r18.1<1>:d    r10.0<0;0>:d      r12.1<0;0>:d      0:w               {I@6}
        sync.nop                             null                             {Compacted,$3.src}
        mov (1|M0)               r14.0<1>:f    r5.0<0;1,0>:f                    {Compacted,I@6}
        mov (1|M0)               r16.0<1>:f    r92.5<0;1,0>:f                   {Compacted}
        mov (1|M0)               r8.0<1>:f     r92.6<0;1,0>:f                   {Compacted}
        add3 (1|M0)              r14.1<1>:d    r11.0<0;0>:d      r12.1<0;0>:d      0:w               {I@5}
        add3 (1|M0)              r6.1<1>:d     r7.0<0;0>:d       r12.1<0;0>:d      0:w               {I@4}
        mov (1|M0)               r6.0<1>:f     r2.0<0;1,0>:f                    {Compacted}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r5.0<1>:ud    r12.0<0;1,0>:ud   0x20:ud              {AccWrEn,F@4}
        send.ugm (1|M0)          null     r18     r20:1   0x0            0x04000584           {A@5,$5} // wr:2+1, rd:0; store.ugm.d32.a64
        send.ugm (1|M0)          null     r14     r16:1   0x0            0x04000584           {A@3,$6} // wr:2+1, rd:0; store.ugm.d32.a64
        send.ugm (1|M0)          null     r6      r8:1    0x0            0x04000584           {A@1,$7} // wr:2+1, rd:0; store.ugm.d32.a64
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r6.0<1>:ud    r12.0<0;1,0>:ud   0x24:ud              {AccWrEn,$7.src}
        mov (1|M0)               r18.0<1>:f    r9.0<0;1,0>:f                    {Compacted,$5.src}
        add3 (1|M0)              r18.1<1>:d    r10.0<0;0>:d      r12.1<0;0>:d      0:w               {I@4}
        mov (1|M0)               r20.0<1>:f    r92.7<0;1,0>:f                   {Compacted}
        mov (1|M0)               r2.0<1>:f     r5.0<0;1,0>:f                    {Compacted,I@4}
        add3 (1|M0)              r2.1<1>:d     r11.0<0;0>:d      r12.1<0;0>:d      0:w               {I@3}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r9.0<1>:ud    r12.0<0;1,0>:ud   0x28:ud              {AccWrEn,F@3}
        send.ugm (1|M0)          null     r18     r20:1   0x0            0x04000584           {A@2,$8} // wr:2+1, rd:0; store.ugm.d32.a64
        send.ugm (1|M0)          null     r2      r93:1   0x0            0x04000584           {A@1,$9} // wr:2+1, rd:0; store.ugm.d32.a64
        mov (1|M0)               r13.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,$1.src}
        addc (1|M0)              r2.0<1>:ud    r12.0<0;1,0>:ud   0x2C:ud              {AccWrEn,$9.src}
        mov (1|M0)               r8.0<1>:f     r6.0<0;1,0>:f                    {Compacted}
        mov (1|M0)               r10.0<1>:f    r93.1<0;1,0>:f                   {Compacted}
        add3 (1|M0)              r8.1<1>:d     r7.0<0;0>:d       r12.1<0;0>:d      0:w               {I@4}
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r7.0<1>:ud    r12.0<0;1,0>:ud   0x30:ud              {AccWrEn}
        send.ugm (1|M0)          null     r8      r10:1   0x0            0x04000584           {A@1,$10} // wr:2+1, rd:0; store.ugm.d32.a64
        mov (1|M0)               r14.0<1>:f    r9.0<0;1,0>:f                    {Compacted,$6.src}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$10.src}
        addc (1|M0)              r9.0<1>:ud    r12.0<0;1,0>:ud   0x34:ud              {AccWrEn,F@1}
        mov (1|M0)               r16.0<1>:f    r93.2<0;1,0>:f                   {Compacted}
        mov (1|M0)               r18.0<1>:f    r93.3<0;1,0>:f                   {Compacted,$8.src}
        add3 (1|M0)              r14.1<1>:d    r13.0<0;0>:d      r12.1<0;0>:d      0:w              
        mov (1|M0)               r6.0<1>:f     r2.0<0;1,0>:f                    {Compacted}
        add3 (1|M0)              r6.1<1>:d     r5.0<0;0>:d       r12.1<0;0>:d      0:w               {I@5}
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r5.0<1>:ud    r12.0<0;1,0>:ud   0x38:ud              {AccWrEn}
        send.ugm (1|M0)          null     r14     r16:1   0x0            0x04000584           {A@3,$11} // wr:2+1, rd:0; store.ugm.d32.a64
        send.ugm (1|M0)          null     r6      r18:1   0x0            0x04000584           {A@1,$12} // wr:2+1, rd:0; store.ugm.d32.a64
        mov (1|M0)               r20.0<1>:f    r93.4<0;1,0>:f                   {Compacted}
        mov (1|M0)               r10.0<1>:f    r7.0<0;1,0>:f                    {Compacted}
        add3 (1|M0)              r10.1<1>:d    r8.0<0;0>:d       r12.1<0;0>:d      0:w              
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$12.src}
        addc (1|M0)              r7.0<1>:ud    r12.0<0;1,0>:ud   0x3C:ud              {AccWrEn,F@1}
        send.ugm (1|M0)          null     r10     r20:1   0x0            0x04000584           {A@3,$13} // wr:2+1, rd:0; store.ugm.d32.a64
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,$13.src}
        mov (1|M0)               r2.0<1>:f     r9.0<0;1,0>:f                    {Compacted}
        add3 (1|M0)              r2.1<1>:d     r11.0<0;0>:d      r12.1<0;0>:d      0:w              
        mov (1|M0)               r14.0<1>:f    r93.5<0;1,0>:f                   {Compacted,$11.src}
        mov (1|M0)               r16.0<1>:f    r5.0<0;1,0>:f                    {Compacted}
        mov (1|M0)               r8.0<1>:f     r93.6<0;1,0>:f                   {Compacted}
        add3 (1|M0)              r16.1<1>:d    r6.0<0;0>:d       r12.1<0;0>:d      0:w               {I@4}
        mov (1|M0)               r18.0<1>:f    r7.0<0;1,0>:f                    {Compacted,I@4}
        mov (1|M0)               r20.0<1>:f    r93.7<0;1,0>:f                   {Compacted}
        add3 (1|M0)              r18.1<1>:d    r10.0<0;0>:d      r12.1<0;0>:d      0:w               {I@3}
        send.ugm (1|M0)          null     r2      r14:1   0x0            0x04000584           {A@3,$14} // wr:2+1, rd:0; store.ugm.d32.a64
        send.ugm (1|M0)          null     r16     r8:1    0x0            0x04000584           {A@2,$15} // wr:2+1, rd:0; store.ugm.d32.a64
        send.ugm (1|M0)          null     r18     r20:1   0x0            0x04000584           {A@1,$0} // wr:2+1, rd:0; store.ugm.d32.a64
L13160:
        join (16|M0)                         L13176                                
L13176:
(W)     mov (8|M0)               r127.0<1>:f   r0.0<1;1,0>:f                    {Compacted}
(W)     send.ugm (1|M0)          r5       r0      null:0  0x0            0x0210641F           {$1} // wr:1+0, rd:1; fence invalid flush type scoped to tile
(W)     mov (8|M0)               null<1>:ud    r5.0<1;1,0>:ud                   {$1.dst}
(W)     send.gtwy (1|M0)         null     r127    null:0  0x0            0x02000010           {EOT,A@1} // wr:1+0, rd:0; end of thread
L13232:
        mov (1|M0)               r1.2<1>:d     cr0.0<0;1,0>:ud                  {A@1}
        and (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   -1265:w               {A@1}
        or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   1264:w               {A@1}
        mov (1|M0)               r1.3<1>:f     (abs)r89.5<0;1,0>:d              {A@1}
        mov (1|M0)               r4.7<1>:f     0xB4C00000:f                               {Compacted}
        math.inv (1|M0)          r4.6<1>:f     r1.3<0;1,0>:f                    {@2,$2}
        mov (1|M0)               r2.1<1>:f     (abs)r89.4<0;1,0>:d             
        sync.nop                             null                             {Compacted,$2.dst}
        mad (1|M0)               r4.6<1>:f     r4.6<0;0>:f       r4.7<0;0>:f       r4.6<0>:f        {F@2}
        mov (2|M0)               r1.4<1>:d     (abs)r89.4<1;1,0>:d             
        mov (1|M0)               r1.6<1>:ud    r1.3<0;1,0>:f                   
        mov (1|M0)               r2.3<1>:ud    r2.1<0;1,0>:f                    {F@2}
        mul (1|M0)               r5.0<1>:f     r4.6<0;1,0>:f     r2.1<0;1,0>:f    {A@1}
        add (1|M0)               r1.6<1>:ud    r1.5<0;1,0>:ud    -r1.6<0;1,0>:ud  {I@2}
        add (1|M0)               r2.3<1>:ud    r1.4<0;1,0>:ud    -r2.3<0;1,0>:ud  {I@2}
        mov (1|M0)               r6.0<1>:ud    r5.0<0;1,0>:f                    {F@1}
        mov (1|M0)               r2.0<1>:f     r1.6<0;1,0>:ud                   {Compacted,I@3}
        mov (1|M0)               r3.5<1>:f     r2.3<0;1,0>:ud                   {I@2}
        mov (1|M0)               r6.1<1>:f     r6.0<0;1,0>:ud                   {Compacted,I@1}
        xor (1|M0)               r89.5<1>:d    r89.5<0;1,0>:d    r89.4<0;1,0>:d  
        mad (1|M0)               r2.1<1>:f     r2.1<0;0>:f       r6.1<0;0>:f       -r1.3<0>:f       {F@1}
        mad (1|M0)               r6.1<1>:f     r3.5<0;0>:f       r6.1<0;0>:f       -r2.0<0>:f      
(W)     mov (1|M0)               r5.0<1>:hf    0x1:hf                             
        add (1|M0)               r2.1<1>:f     r2.1<0;1,0>:f     r6.1<0;1,0>:f    {F@2}
        asr (1|M0)               r89.5<1>:d    r89.5<0;1,0>:d    31:w               {I@1}
        mul (1|M0)               r4.6<1>:f     r4.6<0;1,0>:f     r2.1<0;1,0>:f    {F@1}
        mov (1|M0)               r7.0<1>:ud    r4.6<0;1,0>:f                    {F@1}
        add (1|M0)               r6.0<1>:ud    r6.0<0;1,0>:ud    r7.0<0;1,0>:ud   {Compacted,I@1}
(W)     mul (1|M0)               acc0.0<1>:ud  r6.0<0;1,0>:ud    r1.10<0;1,0>:uw  {I@1}
        mach (1|M0)              r8.0<1>:ud    r6.0<0;1,0>:ud    r1.5<0;1,0>:ud   {Compacted}
        add (1|M0)               r1.4<1>:ud    r1.4<0;1,0>:ud    -r8.0<0;1,0>:ud  {I@1}
        cmp (1|M0)    (ge)f0.1   null<1>:ud    r1.4<0;1,0>:ud    r1.5<0;1,0>:ud   {I@1}
(f0.1)  sel (1|M0)               r3.5<1>:d     r5.0<0;1,0>:w     0:w              
        add3 (1|M0)              r6.0<1>:d     r6.0<0;0>:d       r89.5<0;0>:d      r3.5<0>:d        {I@1}
        xor (1|M0)               r94.0<1>:d    r6.0<0;1,0>:d     r89.5<0;1,0>:d   {Compacted,I@1}
        mov (1|M0)               cr0.0<1>:ud   r1.2<0;1,0>:d                    {A@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        ret (16|M0)                          r89.2                            {A@1}
L13800:
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
