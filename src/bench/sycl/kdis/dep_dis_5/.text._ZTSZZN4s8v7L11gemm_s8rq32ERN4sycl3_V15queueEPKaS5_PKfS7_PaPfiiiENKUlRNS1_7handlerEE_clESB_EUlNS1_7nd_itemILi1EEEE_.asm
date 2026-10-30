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
        sync.nop                             null                             {Compacted,A@1}
        sync.nop                             null                             {Compacted,$0.dst}
        mov (1|M0)               r42.0<1>:d    r1.0<0;1,0>:uw                   {A@1}
        asr (1|M0)               r84.5<1>:d    r2.2<0;1,0>:d     31:w               {$1.dst}
        shl (1|M0)               r1.2<1>:d     r42.0<0;1,0>:d    2:w               {Compacted,I@2}
        shr (1|M0)               r84.5<1>:ud   r84.5<0;1,0>:ud   0x1B:uw              {I@2}
        mov (1|M0)               r5.0<1>:f     0.0:f                               {Compacted}
        add (1|M0)               r2.0<1>:d     r1.2<0;1,0>:d     10240:w               {I@2}
        add (1|M0)               r84.5<1>:d    r2.2<0;1,0>:d     r84.5<0;1,0>:d   {I@2}
        send.slm (1|M0)          null     r2      r5:1    0x0            0x02000504           {A@1,$3} // wr:1+1, rd:0; store.slm.d32.a32
        mov (1|M0)               r84.4<1>:d    r0.1<0;1,0>:ud                  
        add (1|M0)               r6.0<1>:d     r1.2<0;1,0>:d     10304:w              
        add (1|M0)               r7.0<1>:d     r1.2<0;1,0>:d     10368:w              
        add (1|M0)               r8.0<1>:d     r1.2<0;1,0>:d     10432:w              
        add (1|M0)               r9.0<1>:d     r1.2<0;1,0>:d     10496:w              
        add (1|M0)               r10.0<1>:d    r1.2<0;1,0>:d     10560:w              
        add (1|M0)               r11.0<1>:d    r1.2<0;1,0>:d     10624:w              
        add (1|M0)               r2.0<1>:d     r1.2<0;1,0>:d     10688:w               {$3.src}
        asr (1|M0)               r84.5<1>:d    r84.5<0;1,0>:d    5:w               {I@7}
        send.slm (1|M0)          null     r6      r5:1    0x0            0x02000504           {A@7,$4} // wr:1+1, rd:0; store.slm.d32.a32
        send.slm (1|M0)          null     r7      r5:1    0x0            0x02000504           {A@7,$5} // wr:1+1, rd:0; store.slm.d32.a32
        send.slm (1|M0)          null     r8      r5:1    0x0            0x02000504           {A@6,$6} // wr:1+1, rd:0; store.slm.d32.a32
        send.slm (1|M0)          null     r9      r5:1    0x0            0x02000504           {A@5,$7} // wr:1+1, rd:0; store.slm.d32.a32
        send.slm (1|M0)          null     r10     r5:1    0x0            0x02000504           {A@4,$8} // wr:1+1, rd:0; store.slm.d32.a32
        send.slm (1|M0)          null     r11     r5:1    0x0            0x02000504           {A@3,$9} // wr:1+1, rd:0; store.slm.d32.a32
        send.slm (1|M0)          null     r2      r5:1    0x0            0x02000504           {A@2,$10} // wr:1+1, rd:0; store.slm.d32.a32
        mov (2|M0)               r83.4<1>:f    r84.4<1;1,0>:f                   {I@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r83.2         L6528                                 {A@1}
L688:
        asr (1|M0)               r42.5<1>:d    r2.6<0;1,0>:d     31:w              
(W)     mul (1|M0)               acc0.0<1>:d   r42.1<0;1,0>:d    r84.10<0;1,0>:uw
        shr (1|M0)               r42.5<1>:ud   r42.5<0;1,0>:ud   0x1B:uw              {I@2}
(W)     mach (1|M0)              r2.0<1>:d     r42.1<0;1,0>:d    r84.5<0;1,0>:d  
        add (1|M0)               r42.5<1>:d    r2.6<0;1,0>:d     r42.5<0;1,0>:d   {I@2}
        mov (1|M0)               r84.5<1>:d    r2.0<0;1,0>:d                    {A@1}
        asr (1|M0)               r42.5<1>:d    r42.5<0;1,0>:d    5:w               {I@2}
        add (1|M0)               r4.4<1>:d     r84.4<0;1,0>:d    -r84.5<0;1,0>:d  {I@2}
(W)     mul (1|M0)               acc0.0<1>:d   r42.1<0;1,0>:d    r42.10<0;1,0>:uw {I@2}
        mach (1|M0)              r5.0<1>:d     r42.1<0;1,0>:d    r42.5<0;1,0>:d  
(W)     mul (1|M0)               acc0.0<1>:d   r42.1<0;1,0>:d    r42.10<0;1,0>:uw
        mach (1|M0)              r6.0<1>:d     r42.1<0;1,0>:d    r42.5<0;1,0>:d  
        shl (1|M0)               r8.0<1>:d     r4.4<0;1,0>:d     10:w               {Compacted,I@5}
        shl (1|M0)               r1.4<1>:d     r6.0<0;1,0>:d     12:w               {Compacted,I@2}
        asr (1|M0)               r6.1<1>:d     r5.0<0;1,0>:d     31:w               {Compacted}
        addc (1|M0)              r2.0<1>:ud    r2.4<0;1,0>:ud    r1.4<0;1,0>:ud   {AccWrEn,I@2}
        shr (1|M0)               r1.3<1>:ud    r6.0<0;1,0>:ud    0x14:uw             
        shl (1|M0)               r1.2<1>:d     r6.1<0;1,0>:d     12:w               {I@3}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        shl (1|M0)               r6.0<1>:ud    r42.0<0;1,0>:ud   0x8:uw             
        addc (1|M0)              r5.0<1>:ud    r3.0<0;1,0>:ud    r8.0<0;1,0>:ud   {AccWrEn}
        shr (1|M0)               r2.1<1>:ud    r4.4<0;1,0>:ud    0x16:uw             
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@5}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        shl (1|M0)               r1.2<1>:ud    r42.0<0;1,0>:ud   0x6:uw             
        addc (1|M0)              r10.0<1>:ud   r2.0<0;1,0>:ud    r6.0<0;1,0>:ud   {AccWrEn,I@6}
        or (1|M0)                r8.1<1>:d     r2.1<0;1,0>:d     0:w               {Compacted,I@5}
        add3 (1|M0)              r4.3<1>:d     r7.0<0;0>:d       r2.5<0;0>:d       r1.5<0>:d        {I@5}
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r7.0<1>:ud    r5.0<0;1,0>:ud    r1.2<0;1,0>:ud   {AccWrEn,I@5}
        add3 (1|M0)              r5.2<1>:d     r9.0<0;0>:d       r3.1<0;0>:d       r8.1<0>:d        {I@4}
        mov (1|M0)               r20.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r44.0<1>:f    r10.0<0;1,0>:f                   {Compacted}
        add3 (1|M0)              r44.1<1>:d    r11.0<0;0>:d      r4.3<0;0>:d       0:w               {I@4}
        mov (1|M0)               r45.0<1>:f    r7.0<0;1,0>:f                    {Compacted,I@4}
        add3 (1|M0)              r45.1<1>:d    r20.0<0;0>:d      r5.2<0;0>:d       0:w               {I@2}
        send.ugm (1|M0)          r12      r44     null:0  0x0            0x0280E780           {A@2,$11} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        send.ugm (1|M0)          r8       r45     null:0  0x0            0x0220C780           {A@1,$12} // wr:1+0, rd:2; load.ugm.d64x8t.a64
        add (1|M0)               r43.0<1>:ud   r1.2<0;1,0>:ud    0x2000:uw             
        shr (1|M0)               r42.3<1>:ud   r42.0<0;1,0>:ud   0x1:uw             
        and (1|M0)               r42.4<1>:d    r1.0<0;1,0>:uw    1:w              
        add (1|M0)               r42.2<1>:d    r84.4<0;1,0>:d    -r84.5<0;1,0>:d 
        send.slm (1|M0)          null     r6      r12:8   0x0            0x0200E704           {$11} // wr:1+8, rd:0; store.slm.d64x32t.a32
        send.slm (1|M0)          null     r43     r8:2    0x0            0x0200C704           {A@4,$12} // wr:1+2, rd:0; store.slm.d64x8t.a32
(W)     send.slm (1|M0)          r10      r0      null:0  0x0            0x0210001F           {$13} // wr:1+0, rd:1; fence.slm.none.group
(W)     mov (1|M0)               r11.2<1>:f    0.0:f                               {Compacted}
(W)     mov (2|M0)               r11.10<1>:ub  r0.11<0;1,0>:ub                  {F@1}
(W)     mov (8|M0)               null<1>:ud    r10.0<1;1,0>:ud                  {$13.dst}
(W)     send.gtwy (1|M0)         null     r11     null:0  0x0            0x02000004           {A@2,$14} // wr:1+0, rd:0; signal barrier
(W)     sync.bar                             null                            
        cmp (1|M0)    (gt)f0.0   null<1>:d     r2.6<0;1,0>:d     31:w              
        shl (1|M0)               r42.6<1>:ud   r42.3<0;1,0>:ud   0x9:uw             
        shl (1|M0)               r42.7<1>:d    r42.4<0;1,0>:d    9:w              
        mov (16|M0)              r46.0<1>:d    0:w                              
(W)     and (1|M0)               f0.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
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
(~f0.1.any16h) goto (16|M0)                  L3048                  L3048                
L1736:
        asr (1|M0)               r1.3<1>:d     r2.2<0;1,0>:d     31:w              
        shr (1|M0)               r2.1<1>:ud    r2.2<0;1,0>:ud    0x1B:uw             
        mov (1|M0)               r43.5<1>:f    r42.5<0;1,0>:f                   {$12.src}
        shl (1|M0)               r2.0<1>:d     r1.3<0;1,0>:d     5:w               {Compacted,I@2}
        shl (1|M0)               r43.3<1>:d    r2.2<0;1,0>:d     5:w              
        mov (1|M0)               r44.2<2>:f    0.0:f                              
        mov (1|M0)               r44.3<2>:f    0.0:f                              
        mov (2|M0)               r43.1<1>:d    r43.5<1;1,0>:d                   {F@3}
        or (1|M0)                r43.4<1>:d    r2.0<0;1,0>:d     r2.1<0;1,0>:d    {I@3}
        asr (1|M0)               r43.2<1>:d    r42.5<0;1,0>:d    31:w              
        mov (1|M0)               r43.6<1>:d    0:w                              
L1904:
        addc (1|M0)              r2.0<1>:ud    r44.2<0;1,0>:ud   0x1:ud              {AccWrEn,F@2}
(W)     mov (1|M0)               r1.3<1>:hf    0x1:hf                             
        mov (1|M0)               r44.4<1>:d    r2.0<0;1,0>:d                    {I@1}
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        cmp (1|M0)    (lt)f1.0   null<1>:ud    r44.4<0;1,0>:ud   r43.1<0;1,0>:ud  {I@2}
        add3 (1|M0)              r44.5<1>:d    r5.0<0;0>:d       r44.3<0;0>:d      0:w               {A@2}
        and (1|M0)               r43.7<1>:d    r44.2<0;1,0>:d    1:w              
        cmp (1|M0)    (lt)f0.0   null<1>:d     r44.5<0;1,0>:d    r43.2<0;1,0>:d   {I@2}
(f1.0)  cmp (1|M0)    (eq)f1.0   null<1>:d     r44.5<0;1,0>:d    r43.2<0;1,0>:d  
(f0.0)  sel (1|M0)               r4.4<1>:uw    r1.3<0;1,0>:uw    0x0:uw              {F@1}
(f1.0)  sel (1|M0)               r1.4<1>:uw    r1.3<0;1,0>:uw    0x0:uw             
        or (1|M0)     (ne)f1.1   null<1>:uw    r1.4<0;1,0>:uw    r4.4<0;1,0>:uw   {I@1}
(W)     and (1|M0)               f0.0<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(~f0.0.any16h) goto (16|M0)                  L2584                  L2584                
L2120:
        shl (1|M0)               r1.5<1>:d     r44.4<0;1,0>:d    12:w              
        shl (1|M0)               r1.3<1>:d     r44.5<0;1,0>:d    12:w              
        shr (1|M0)               r1.4<1>:ud    r44.4<0;1,0>:ud   0x14:uw             
        addc (1|M0)              r2.0<1>:ud    r44.0<0;1,0>:ud   r1.5<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r1.6<1>:d     r1.3<0;1,0>:d     r1.4<0;1,0>:d    {I@2}
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        sync.allrd                           ($0,$11)                
        mov (1|M0)               r6.0<1>:f     r2.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r6.1<1>:d     r5.0<0;0>:d       r44.1<0;0>:d      r1.6<0>:d        {I@1}
        mul (1|M0)               acc0.0<1>:ud  r43.3<0;1,0>:ud   r44.8<0;1,0>:uw 
        sync.allrd                           ($14,$15)                
        send.ugm (1|M0)          r7       r6      null:0  0x0            0x0280E780           {A@1,$2} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        mach (1|M0)              r17.0<1>:ud   r43.3<0;1,0>:ud   r44.4<0;1,0>:ud  {AccWrEn}
        xor (1|M0)               r1.2<1>:d     r43.7<0;1,0>:d    1:w              
        mov (1|M0)               r16.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r43.3<0;1,0>:d    r44.10<0;1,0>:uw
        mach (1|M0)              r18.0<1>:d    r43.3<0;1,0>:d    r44.5<0;1,0>:d  
(W)     mul (1|M0)               acc0.0<1>:d   r43.4<0;1,0>:d    r44.8<0;1,0>:uw 
        mach (1|M0)              r2.0<1>:d     r43.4<0;1,0>:d    r44.4<0;1,0>:d  
        addc (1|M0)              r5.0<1>:ud    r45.0<0;1,0>:ud   r16.0<0;1,0>:ud  {AccWrEn,I@5}
        shl (1|M0)               r4.2<1>:d     r1.2<0;1,0>:d     12:w              
        add3 (1|M0)              r1.4<1>:d     r2.0<0;0>:d       r17.0<0;0>:d      r18.0<0>:d       {I@3}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$2.src}
        mov (1|M0)               r19.0<1>:f    r5.0<0;1,0>:f                    {Compacted,I@4}
        mad (1|M0)               r15.0<1>:d    r4.2<0;0>:d       r1.0<0;0>:uw      256:w               {I@3}
        add3 (1|M0)              r19.1<1>:d    r6.0<0;0>:d       r45.1<0;0>:d      r1.4<0>:d        {I@2}
        shl (1|M0)               r1.2<1>:d     r1.2<0;1,0>:d     10:w              
        send.slm (1|M0)          null     r15     r7:8    0x0            0x0200E704           {A@3,$2} // wr:1+8, rd:0; store.slm.d64x32t.a32
        sync.nop                             null                             {Compacted,$2.src}
        send.ugm (1|M0)          r7       r19     null:0  0x0            0x0220C780           {A@1,$3} // wr:1+0, rd:2; load.ugm.d64x8t.a64
        add (1|M0)               r9.0<1>:d     r1.2<0;1,0>:d     r43.0<0;1,0>:d   {Compacted,I@1}
        sync.nop                             null                             {Compacted,$3.dst}
        send.slm (1|M0)          null     r9      r7:2    0x0            0x0200C704           {A@1,$15} // wr:1+2, rd:0; store.slm.d64x8t.a32
L2584:
        join (16|M0)                         L3048                                
L2600:
        shl (1|M0)               r1.2<1>:d     r43.7<0;1,0>:d    12:w              
        shl (1|M0)               r43.7<1>:d    r43.7<0;1,0>:d    10:w              
        add (1|M0)               r2.0<1>:d     r1.2<0;1,0>:d     r42.6<0;1,0>:d   {I@2}
        bfn.0xFE (1|M0)          r5.0<1>:ud    0x2000:uw               r43.7<0;0>:ud     r42.7<0>:ud      {I@2} // s0|s1|s2
        bfn.0xFE (1|M0)          r31.0<1>:ud   0x2100:uw               r43.7<0;0>:ud     r42.7<0>:ud      // s0|s1|s2
        sync.nop                             null                             {Compacted,$11.src}
        or (1|M0)                r14.0<1>:ud   r2.0<0;1,0>:ud    0x100:uw              {I@3}
        sync.allrd                           ($0,$14)                
        send.slm (1|M0)          r6       r2      null:0  0x0            0x0280E700           {$4} // wr:1+0, rd:8; load.slm.d64x32t.a32
        send.slm (1|M0)          r23      r5      null:0  0x0            0x0280E700           {A@3,$5} // wr:1+0, rd:8; load.slm.d64x32t.a32
        send.slm (1|M0)          r32      r31     null:0  0x0            0x0280E700           {A@2,$6} // wr:1+0, rd:8; load.slm.d64x32t.a32
        send.slm (1|M0)          r15      r14     null:0  0x0            0x0280E700           {A@1,$7} // wr:1+0, rd:8; load.slm.d64x32t.a32
        sync.allwr                           ($0,$4,$5,$6,$7)                
        dpas.8x8 (8|M0)          r70:d         r70:d             r23:b             r6.0:b           {Atomic}
        dpas.8x8 (8|M0)          r62:d         r62:d             r32:b             r6.0:b           {Atomic}
        dpas.8x8 (8|M0)          r54:d         r54:d             r23:b             r15.0:b          {Atomic}
        dpas.8x8 (8|M0)          r46:d         r46:d             r32:b             r15.0:b          {$0}
(W)     send.slm (1|M0)          r40      r0      null:0  0x0            0x0210001F           {$8} // wr:1+0, rd:1; fence.slm.none.group
(W)     mov (1|M0)               r41.2<1>:f    0.0:f                               {Compacted,$1.src}
(W)     mov (2|M0)               r41.10<1>:ub  r0.11<0;1,0>:ub                  {F@1}
(W)     mov (8|M0)               null<1>:ud    r40.0<1;1,0>:ud                  {$8.dst}
(W)     send.gtwy (1|M0)         null     r41     null:0  0x0            0x02000004           {A@2,$1} // wr:1+0, rd:0; signal barrier
(W)     sync.bar                             null                            
        cmp (1|M0)    (eq)f0.1   null<1>:d     r44.5<0;1,0>:d    r43.6<0;1,0>:d  
(f0.1)  cmp (1|M0)    (eq)f0.1   null<1>:d     r44.4<0;1,0>:d    r43.5<0;1,0>:d  
(W)     and (1|M0)               f1.1<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(f1.1.any16h) goto (16|M0)                   L3048                  L3048                
L3016:
(W)     mov (2|M0)               r44.2<1>:ud   r44.4<1;1,0>:ud                 
        goto.b (16|M0)                       L3048                  L1904                
L3048:
        join (16|M0)                         L3064                                
L3064:
        shl (1|M0)               r42.2<1>:d    r42.2<0;1,0>:d    5:w              
        shl (1|M0)               r1.2<1>:d     r42.4<0;1,0>:d    4:w              
        mov (1|M0)               r45.3<1>:d    0:w                              
        or (1|M0)                r45.2<1>:d    r42.2<0;1,0>:d    r1.2<0;1,0>:d    {I@2}
        shl (1|M0)               r2.0<1>:d     r45.3<0;1,0>:d    2:w               {Compacted,I@2}
        shl (1|M0)               r4.2<1>:d     r45.2<0;1,0>:d    2:w               {I@2}
        shr (1|M0)               r2.1<1>:ud    r45.2<0;1,0>:ud   0x1E:uw             
        addc (1|M0)              r5.0<1>:ud    r3.2<0;1,0>:ud    r4.2<0;1,0>:ud   {AccWrEn,I@2}
        or (1|M0)                r4.3<1>:d     r2.0<0;1,0>:d     r2.1<0;1,0>:d    {I@2}
        sync.allrd                           ($0,$15)                
        mov (1|M0)               r7.0<1>:f     r5.0<0;1,0>:f                    {Compacted,I@2}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$11.src}
        sync.nop                             null                             {Compacted,$12.src}
        addc (1|M0)              r8.0<1>:ud    r7.0<0;1,0>:ud    0x20:ud              {AccWrEn,F@1}
        add3 (1|M0)              r7.1<1>:d     r6.0<0;0>:d       r3.3<0;0>:d       r4.3<0>:d        {I@2}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        shl (1|M0)               r42.1<1>:d    r42.1<0;1,0>:d    7:w               {Compacted}
        shl (1|M0)               r44.6<1>:ud   r42.3<0;1,0>:ud   0x4:uw             
        mov (1|M0)               r10.0<1>:f    r8.0<0;1,0>:f                    {Compacted,I@5}
        add3 (1|M0)              r10.1<1>:d    r9.0<0;0>:d       r7.1<0;0>:d       0:w               {I@3}
        send.ugm (1|M0)          r78      r7      null:0  0x0            0x0210B780           {$9} // wr:1+0, rd:1; load.ugm.d64x4t.a64
        send.ugm (1|M0)          r79      r10     null:0  0x0            0x0210B780           {A@1,$10} // wr:1+0, rd:1; load.ugm.d64x4t.a64
        mov (1|M0)               r44.7<1>:d    0:w                              
        add (1|M0)               r42.1<1>:d    r42.1<0;1,0>:d    r44.6<0;1,0>:d  
L3392:
        or (1|M0)                r1.2<1>:d     r44.7<0;1,0>:d    r42.1<0;1,0>:d   {I@1}
        or (1|M0)                r1.3<1>:d     r44.7<0;1,0>:d    r42.1<0;1,0>:d  
        asr (1|M0)               r1.4<1>:d     r1.2<0;1,0>:d     31:w               {I@2}
        shl (1|M0)               r4.2<1>:d     r1.3<0;1,0>:d     2:w               {I@2}
        shr (1|M0)               r2.1<1>:ud    r1.3<0;1,0>:ud    0x1E:uw             
        shl (1|M0)               r2.0<1>:d     r1.4<0;1,0>:d     2:w               {Compacted,I@3}
        sync.nop                             null                             {Compacted,$11.src}
        addc (1|M0)              r5.0<1>:ud    r3.4<0;1,0>:ud    r4.2<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r4.3<1>:d     r2.0<0;1,0>:d     r2.1<0;1,0>:d    {I@2}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r8.0<1>:f     r5.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r8.1<1>:d     r6.0<0;0>:d       r3.5<0;0>:d       r4.3<0>:d        {I@1}
        addc (1|M0)              r9.0<1>:ud    r8.0<0;1,0>:ud    0x20:ud              {AccWrEn,F@1}
        send.ugm (1|M0)          r7       r8      null:0  0x0            0x04100580           {A@1,$13} // wr:2+0, rd:1; load.ugm.d32.a64
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,$10.src}
        mov (1|M0)               r12.0<1>:f    r9.0<0;1,0>:f                    {Compacted}
        add3 (1|M0)              r12.1<1>:d    r10.0<0;0>:d      r8.1<0;0>:d       0:w               {I@1}
        shl (1|M0)               r1.3<1>:w     r44.14<0;1,0>:w   5:w              
        send.ugm (1|M0)          r2       r12     null:0  0x0            0x04100580           {A@1,$15} // wr:2+0, rd:1; load.ugm.d32.a64
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0x8C0:uw              {A@1}
        mov (8|M0)               r5.0<1>:ud    r[a0.0]<1;1,0>:ud                {$0.dst}
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0x7C0:uw              {A@1}
        mov (8|M0)               r6.0<1>:f     r5.0<1;1,0>:d                    {Compacted,I@2}
        mov (8|M0)               r13.0<1>:ud   r[a0.0]<1;1,0>:ud                {$15.src}
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0x6C0:uw              {A@1}
        sync.nop                             null                             {Compacted,$13.src}
        mov (8|M0)               r9.0<1>:f     r13.0<1;1,0>:d                   {Compacted,I@2}
        mov (8|M0)               r10.0<1>:ud   r[a0.0]<1;1,0>:ud               
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0x5C0:uw              {A@1}
        mov (8|M0)               r12.0<1>:f    r10.0<1;1,0>:d                   {Compacted,I@2}
        sync.nop                             null                             {Compacted,$13.dst}
        mul (8|M0)               acc0.0<1>:f   r7.0<0;1,0>:f     r6.0<1;1,0>:f    {Compacted,F@3}
        mul (8|M0)               acc1.0<1>:f   r7.0<0;1,0>:f     r9.0<1;1,0>:f    {Compacted,F@3}
        mul (8|M0)               acc0.0<1>:f   acc0.0<1;1,0>:f   r78.0<1;1,0>:f   {Compacted,$9.dst}
        mov (8|M0)               r6.0<1>:ud    r[a0.0]<1;1,0>:ud                {F@3}
        sync.nop                             null                             {Compacted,A@1}
        sync.nop                             null                             {Compacted,$10.dst}
        mul (8|M0)               acc1.0<1>:f   acc1.0<1;1,0>:f   r79.0<1;1,0>:f   {Compacted,A@1}
        mov (8|M0)               r14.0<1>:f    r6.0<1;1,0>:d                    {Compacted,I@1}
        mul (8|M0)               acc2.0<1>:f   r2.0<0;1,0>:f     r12.0<1;1,0>:f   {Compacted,$15.dst}
        mov (8|M0)               r8.0<1>:f     (abs)acc1.0<1;1,0>:f             {Compacted}
        mul (8|M0)               acc1.0<1>:f   r2.0<0;1,0>:f     r14.0<1;1,0>:f   {Compacted,F@3}
        mov (8|M0)               r11.0<1>:f    (abs)acc0.0<1;1,0>:f             {Compacted,$14.src}
        mul (8|M0)               acc0.0<1>:f   acc2.0<1;1,0>:f   r78.0<1;1,0>:f   {Compacted}
        mul (8|M0)               acc1.0<1>:f   acc1.0<1;1,0>:f   r79.0<1;1,0>:f   {Compacted}
        mov (4|M0)               r12.0<1>:ud   r8.4<1;1,0>:ud                   {F@5}
        mov (4|M0)               r7.0<1>:ud    r11.4<1;1,0>:ud                  {F@3}
        mov (8|M0)               r5.0<1>:f     (abs)acc0.0<1;1,0>:f             {Compacted}
        mov (8|M0)               r13.0<1>:f    (abs)acc1.0<1;1,0>:f             {Compacted}
        sync.nop                             null                             {Compacted,$12.src}
        sel (4|M0)    (ge)f0.0   r16.0<1>:f    r8.0<1;1,0>:f     r12.0<1;1,0>:f   {I@2}
        sel (4|M0)    (ge)f0.0   r9.0<1>:f     r11.0<1;1,0>:f    r7.0<1;1,0>:f    {I@1}
        mov (4|M0)               r8.0<1>:ud    r13.4<1;1,0>:ud                  {A@2}
        mov (2|M0)               r6.0<1>:ud    r16.2<1;1,0>:ud                 
        mov (4|M0)               r7.0<1>:ud    r5.4<1;1,0>:ud                   {F@1}
        mov (2|M0)               r15.0<1>:ud   r9.2<1;1,0>:ud                  
        sel (4|M0)    (ge)f0.0   r12.0<1>:f    r13.0<1;1,0>:f    r8.0<1;1,0>:f    {I@4}
        sel (2|M0)    (ge)f0.0   r2.0<1>:f     r16.0<1;1,0>:f    r6.0<1;1,0>:f    {I@3}
        sel (4|M0)    (ge)f0.0   r11.0<1>:f    r5.0<1;1,0>:f     r7.0<1;1,0>:f    {I@2}
        or (1|M0)                r16.0<1>:d    r44.7<0;1,0>:d    r44.6<0;1,0>:d   {F@2}
        add (1|M0)               r44.7<1>:d    r44.7<0;1,0>:d    1:w              
        sel (2|M0)    (ge)f0.0   r10.0<1>:f    r9.0<1;1,0>:f     r15.0<1;1,0>:f   {I@3}
        mov (2|M0)               r6.0<1>:ud    r12.2<1;1,0>:ud                 
        mov (2|M0)               r9.0<1>:ud    r11.2<1;1,0>:ud                  {A@1}
        cmp (1|M0)    (eq)f1.0   null<1>:d     r44.7<0;1,0>:d    8:w               {I@3}
        sel (1|M0)    (ge)f0.0   r1.2<1>:f     r2.0<0;1,0>:f     r2.1<0;1,0>:f   
        sel (1|M0)    (ge)f0.0   r4.2<1>:f     r10.0<0;1,0>:f    r10.1<0;1,0>:f  
        sel (2|M0)    (ge)f0.0   r2.0<1>:f     r12.0<1;1,0>:f    r6.0<1;1,0>:f    {I@3}
        sel (2|M0)    (ge)f0.0   r10.0<1>:f    r11.0<1;1,0>:f    r9.0<1;1,0>:f    {I@2}
        shl (1|M0)               r16.0<1>:d    r16.0<0;1,0>:d    2:w               {Compacted}
        sel (1|M0)    (ge)f0.0   r14.0<1>:f    r4.2<0;1,0>:f     r1.2<0;1,0>:f    {F@3}
(W)     and (1|M0)               f1.0<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
        sel (1|M0)    (ge)f0.0   r14.1<1>:f    r10.0<0;1,0>:f    r10.1<0;1,0>:f   {F@2}
        sel (1|M0)    (ge)f0.0   r1.2<1>:f     r2.0<0;1,0>:f     r2.1<0;1,0>:f   
        add (1|M0)               r5.0<1>:d     r16.0<0;1,0>:d    10240:w               {I@2}
        sel (1|M0)    (ge)f0.0   r15.0<1>:f    r14.1<0;1,0>:f    r1.2<0;1,0>:f    {F@1}
        add (1|M0)               r16.0<1>:d    r16.0<0;1,0>:d    10272:w              
        send.slm (1|M0)          null     r5      r14:1   0x0            0x02000516           {A@2,$11} // wr:1+1, rd:0; atomic_fmax.slm.d32.a32
        send.slm (1|M0)          null     r16     r15:1   0x0            0x02000516           {A@1,$12} // wr:1+1, rd:0; atomic_fmax.slm.d32.a32
(~f1.0.any16h) goto.b (16|M0)                L4448                  L3392                
L4448:
        join (16|M0)                         L4464                                
L4464:
        sync.nop                             null                             {Compacted,$11.src}
(W)     send.slm (1|M0)          r5       r0      null:0  0x0            0x0210001F           {$2} // wr:1+0, rd:1; fence.slm.none.group
(W)     mov (1|M0)               r6.2<1>:f     0.0:f                               {Compacted}
(W)     mov (2|M0)               r6.10<1>:ub   r0.11<0;1,0>:ub                  {F@1}
(W)     mov (8|M0)               null<1>:ud    r5.0<1;1,0>:ud                   {$2.dst}
(W)     send.gtwy (1|M0)         null     r6      null:0  0x0            0x02000004           {A@2,$3} // wr:1+0, rd:0; signal barrier
(W)     sync.bar                             null                            
        shl (1|M0)               r42.3<1>:ud   r42.3<0;1,0>:ud   0x6:uw             
        addc (1|M0)              r7.0<1>:ud    r4.0<0;1,0>:ud    r45.2<0;1,0>:ud  {AccWrEn}
        add (1|M0)               r2.0<1>:ud    r42.3<0;1,0>:ud   0x2800:uw              {I@2}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        send.slm (1|M0)          r80      r2      null:0  0x0            0x0220C700           {A@2,$4} // wr:1+0, rd:2; load.slm.d64x8t.a32
        mov (1|M0)               r45.6<1>:d    0:w                              
        mov (1|M0)               r45.4<1>:d    r7.0<0;1,0>:d                   
        add3 (1|M0)              r45.5<1>:d    r8.0<0;0>:d       r4.1<0;0>:d       r45.3<0>:d       {I@3}
L4680:
        shl (1|M0)               r1.3<1>:w     r45.12<0;1,0>:w   2:w               {I@3}
        or (1|M0)                r45.7<1>:d    r45.6<0;1,0>:d    r42.1<0;1,0>:d  
        add (1|M0)               a0.1<1>:uw    r1.3<0;1,0>:uw    0xA00:uw              {A@1}
        or (1|M0)                r2.0<1>:uw    r1.3<0;1,0>:uw    0x20:uw              {$4.src}
        or (1|M0)                r1.2<1>:d     r45.6<0;1,0>:d    r42.1<0;1,0>:d  
        add (1|M0)               a0.0<1>:uw    r2.0<0;1,0>:uw    0xA00:uw              {A@1}
(W)     mov (1|M0)               r4.2<1>:f     r[a0.1]<0;1,0>:f                 {$4.dst}
        or (1|M0)                r82.2<1>:d    r45.7<0;1,0>:d    8:w               {A@1}
        sync.nop                             null                             {Compacted,F@1}
        math.inv (1|M0)          r82.5<1>:f    r4.2<0;1,0>:f                    {$6}
        shl (1|M0)               r82.0<1>:d    r1.2<0;1,0>:d     2:w               {Compacted,I@3}
        or (1|M0)                r4.2<1>:d     r45.7<0;1,0>:d    8:w               {$6.src}
(W)     mov (1|M0)               r5.0<1>:f     r[a0.0]<0;1,0>:f                
        asr (1|M0)               r1.3<1>:d     r45.7<0;1,0>:d    31:w               {A@1}
        asr (1|M0)               r4.3<1>:d     r82.2<0;1,0>:d    31:w               {I@4}
        addc (1|M0)              r2.0<1>:ud    r3.4<0;1,0>:ud    r82.0<0;1,0>:ud  {AccWrEn,I@4}
        shl (1|M0)               r82.3<1>:d    r4.2<0;1,0>:d     2:w               {I@4}
        sync.nop                             null                             {Compacted,F@1}
        math.inv (1|M0)          r82.6<1>:f    r5.0<0;1,0>:f                    {$7}
        shr (1|M0)               r1.5<1>:ud    r1.2<0;1,0>:ud    0x1E:uw             
        shr (1|M0)               r4.5<1>:ud    r4.2<0;1,0>:ud    0x1E:uw             
        shl (1|M0)               r1.4<1>:d     r1.3<0;1,0>:d     2:w               {I@6}
        shl (1|M0)               r4.4<1>:d     r4.3<0;1,0>:d     2:w               {I@6}
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$7.src}
        addc (1|M0)              r7.0<1>:ud    r3.4<0;1,0>:ud    r82.3<0;1,0>:ud  {AccWrEn,I@6}
        mov (1|M0)               r6.0<1>:f     r2.0<0;1,0>:f                    {Compacted,$3.src}
        or (1|M0)                r82.1<1>:d    r1.4<0;1,0>:d     r1.5<0;1,0>:d    {I@4}
        or (1|M0)                r82.4<1>:d    r4.4<0;1,0>:d     r4.5<0;1,0>:d    {I@4}
        mov (1|M0)               r2.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,F@1}
        mov (1|M0)               r8.0<1>:f     r7.0<0;1,0>:f                    {Compacted,I@4}
        add3 (1|M0)              r6.1<1>:d     r5.0<0;0>:d       r3.5<0;0>:d       r82.1<0>:d       {I@3}
        add3 (1|M0)              r8.1<1>:d     r2.0<0;0>:d       r3.5<0;0>:d       r82.4<0>:d       {I@2}
        send.ugm (1|M0)          r83      r6      null:0  0x0            0x04100580           {A@2,$8} // wr:2+0, rd:1; load.ugm.d32.a64
        send.ugm (1|M0)          r84      r8      null:0  0x0            0x04100580           {A@1,$9} // wr:2+0, rd:1; load.ugm.d32.a64
        cmp (1|M0)    (eq)f1.1   null<1>:d     r42.4<0;1,0>:d    0:w              
        cmp (1|M0)    (gt)f0.1   null<1>:f     r[a0.1]<0;1,0>:f  0.0:f              
        cmp (1|M0)    (gt)f0.0   null<1>:f     r[a0.0]<0;1,0>:f  0.0:f               {A@1}
        sync.nop                             null                             {Compacted,A@1}
        sync.nop                             null                             {Compacted,$6.dst}
        mul (1|M0)               r82.5<1>:f    r82.5<0;1,0>:f    127.0:f               {A@1}
        mul (1|M0)               r82.6<1>:f    r82.6<0;1,0>:f    127.0:f               {$7.dst}
(~f0.1) mov (1|M0)               r82.5<1>:f    0.0:f                              
(W)     and (1|M0)               f0.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw              {A@1}
(~f0.0) mov (1|M0)               r82.6<1>:f    0.0:f                              
(~f0.1.any16h) goto (16|M0)                  L5520                  L5520                
L5328:
        addc (1|M0)              r5.0<1>:ud    r3.6<0;1,0>:ud    r82.0<0;1,0>:ud  {AccWrEn}
        mul (1|M0)               r2.0<1>:f     r[a0.1]<0;1,0>:f  7.874016e-03:f              
        sync.nop                             null                             {Compacted,A@1}
        sync.nop                             null                             {Compacted,$8.src}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,A@1}
        addc (1|M0)              r7.0<1>:ud    r3.6<0;1,0>:ud    r82.3<0;1,0>:ud  {AccWrEn}
        mul (1|M0)               r10.0<1>:f    r[a0.0]<0;1,0>:f  7.874016e-03:f               {$5.src}
        sync.nop                             null                             {Compacted,A@1}
        sync.nop                             null                             {Compacted,$9.src}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,A@1}
        mov (1|M0)               r8.0<1>:f     r5.0<0;1,0>:f                    {Compacted,I@4}
        add3 (1|M0)              r8.1<1>:d     r6.0<0;0>:d       r3.7<0;0>:d       r82.1<0>:d       {I@3}
        mov (1|M0)               r12.0<1>:f    r7.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r12.1<1>:d    r9.0<0;0>:d       r3.7<0;0>:d       r82.4<0>:d       {I@2}
        send.ugm (1|M0)          null     r8      r2:1    0x0            0x04000584           {A@2,$10} // wr:2+1, rd:0; store.ugm.d32.a64
        send.ugm (1|M0)          null     r12     r10:1   0x0            0x04000584           {A@1,$11} // wr:2+1, rd:0; store.ugm.d32.a64
L5520:
        join (16|M0)                         L6456                                
L5536:
        shl (1|M0)               r1.3<1>:w     r45.12<0;1,0>:w   5:w              
        mul (1|M0)               acc0.0<1>:d   r45.7<0;1,0>:d    r2.4<0;1,0>:uw  
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0x8C0:uw              {A@1}
        mach (1|M0)              r12.0<1>:d    r45.7<0;1,0>:d    r2.2<0;1,0>:d    {AccWrEn,$11.src}
        add (1|M0)               r45.6<1>:d    r45.6<0;1,0>:d    1:w              
        mov (1|M0)               r11.0<1>:d    acc0.0<0;1,0>:d                 
        mov (8|M0)               r5.0<1>:ud    r[a0.0]<1;1,0>:ud               
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0x7C0:uw              {A@1}
        sync.nop                             null                             {Compacted,$8.src}
        mov (8|M0)               r6.0<1>:f     r5.0<1;1,0>:d                    {Compacted,I@2}
        addc (1|M0)              r2.0<1>:ud    r45.4<0;1,0>:ud   r11.0<0;1,0>:ud  {AccWrEn,$10.src}
        sync.nop                             null                             {Compacted,$8.dst}
        mul (8|M0)               acc2.0<1>:f   r83.0<0;1,0>:f    r6.0<1;1,0>:f    {Compacted,F@1}
        mov (8|M0)               r7.0<1>:ud    r[a0.0]<1;1,0>:ud               
        mul (8|M0)               acc2.0<1>:f   acc2.0<1;1,0>:f   r78.0<1;1,0>:f   {Compacted,A@1}
        sync.nop                             null                             {Compacted,$9.src}
        mov (8|M0)               r8.0<1>:f     r7.0<1;1,0>:d                    {Compacted,I@1}
        mul (8|M0)               acc2.0<1>:f   r82.5<0;1,0>:f    acc2.0<1;1,0>:f 
        mul (8|M0)               acc3.0<1>:f   r83.0<0;1,0>:f    r8.0<1;1,0>:f    {Compacted,F@2}
        rnde (8|M0)              acc2.0<1>:f   acc2.0<1;1,0>:f                 
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0x6C0:uw              {A@1}
        mul (8|M0)               acc3.0<1>:f   acc3.0<1;1,0>:f   r79.0<1;1,0>:f   {Compacted}
        sel (8|M0)    (ge)f0.0   acc2.0<1>:f   acc2.0<1;1,0>:f   -127.0:f              
        mul (8|M0)               acc3.0<1>:f   r82.5<0;1,0>:f    acc3.0<1;1,0>:f 
        sel (8|M0)    (lt)f0.0   r6.0<1>:f     acc2.0<1;1,0>:f   127.0:f              
        rnde (8|M0)              acc2.0<1>:f   acc3.0<1;1,0>:f                 
        mov (8|M0)               r5.0<1>:d     r6.0<1;1,0>:f                    {Compacted,F@2}
        mov (8|M0)               r6.0<1>:ud    r[a0.0]<1;1,0>:ud               
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0x5C0:uw              {A@1}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        sel (8|M0)    (ge)f0.0   acc0.0<1>:f   acc2.0<1;1,0>:f   -127.0:f               {I@1}
        add3 (1|M0)              r13.1<1>:d    r7.0<0;0>:d       r45.5<0;0>:d      r12.0<0>:d       {$5.src}
        sel (8|M0)    (lt)f0.0   r8.0<1>:f     acc0.0<1;1,0>:f   127.0:f              
        mov (8|M0)               r7.0<1>:ud    r[a0.0]<1;1,0>:ud               
        mov (8|M0)               r10.0<1>:b    r5.0<4;1,0>:b                    {A@1}
        mov (8|M0)               r9.0<1>:d     r8.0<1;1,0>:f                    {Compacted,F@1}
        mov (8|M0)               r5.0<1>:f     r6.0<1;1,0>:d                    {Compacted,I@2}
        mov (8|M0)               r8.0<1>:f     r7.0<1;1,0>:d                    {Compacted,I@1}
        sync.nop                             null                             {Compacted,$9.dst}
        mul (8|M0)               acc0.0<1>:f   r84.0<0;1,0>:f    r5.0<1;1,0>:f    {Compacted,F@2}
        mul (8|M0)               acc1.0<1>:f   r84.0<0;1,0>:f    r8.0<1;1,0>:f    {Compacted,F@2}
        mul (8|M0)               acc0.0<1>:f   acc0.0<1;1,0>:f   r78.0<1;1,0>:f   {Compacted}
        mul (8|M0)               acc1.0<1>:f   acc1.0<1;1,0>:f   r79.0<1;1,0>:f   {Compacted}
        mul (8|M0)               r5.0<1>:f     r82.6<0;1,0>:f    acc0.0<1;1,0>:f 
        mul (8|M0)               r8.0<1>:f     r82.6<0;1,0>:f    acc1.0<1;1,0>:f 
        mul (1|M0)               acc0.0<1>:d   r82.2<0;1,0>:d    r2.4<0;1,0>:uw   {A@1}
        rnde (8|M0)              acc2.0<1>:f   r5.0<1;1,0>:f                   
        rnde (8|M0)              acc3.0<1>:f   r8.0<1;1,0>:f                   
        mach (1|M0)              r12.0<1>:d    r82.2<0;1,0>:d    r2.2<0;1,0>:d    {AccWrEn}
        cmp (1|M0)    (eq)f1.0   null<1>:d     r45.6<0;1,0>:d    8:w              
        sel (8|M0)    (ge)f0.0   acc2.0<1>:f   acc2.0<1;1,0>:f   -127.0:f              
        sel (8|M0)    (ge)f0.0   acc3.0<1>:f   acc3.0<1;1,0>:f   -127.0:f              
        mov (1|M0)               r11.0<1>:d    acc0.0<0;1,0>:d                 
        mov (1|M0)               r13.0<1>:f    r2.0<0;1,0>:f                    {Compacted}
        sel (8|M0)    (lt)f0.0   r5.0<1>:f     acc2.0<1;1,0>:f   127.0:f              
        sel (8|M0)    (lt)f0.0   r8.0<1>:f     acc3.0<1;1,0>:f   127.0:f              
        addc (1|M0)              r2.0<1>:ud    r45.4<0;1,0>:ud   r11.0<0;1,0>:ud  {AccWrEn,A@1}
        mov (8|M0)               r10.8<1>:b    r9.0<4;1,0>:b                   
(W)     and (1|M0)               f0.0<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
        mov (8|M0)               r6.0<1>:d     r5.0<1;1,0>:f                    {Compacted,F@2}
        mov (8|M0)               r9.0<1>:d     r8.0<1;1,0>:f                    {Compacted,F@1}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        send.ugm (1|M0)          null     r13     r10:1   0x0            0x02009784           {A@5,$13} // wr:1+1, rd:0; store.ugm.d64x2t.a64
        sync.nop                             null                             {Compacted,$13.src}
        mov (8|M0)               r10.0<1>:b    r6.0<4;1,0>:b                    {I@3}
        mov (8|M0)               r10.8<1>:b    r9.0<4;1,0>:b                    {I@3}
        mov (1|M0)               r13.0<1>:f    r2.0<0;1,0>:f                    {Compacted}
        add3 (1|M0)              r13.1<1>:d    r7.0<0;0>:d       r45.5<0;0>:d      r12.0<0>:d       {I@3}
        send.ugm (1|M0)          null     r13     r10:1   0x0            0x02009784           {A@1,$5} // wr:1+1, rd:0; store.ugm.d64x2t.a64
(~f0.0.any16h) goto.b (16|M0)                L6456                  L4680                
L6456:
        join (16|M0)                         L6472                                
L6472:
(W)     mov (8|M0)               r127.0<1>:f   r0.0<1;1,0>:f                    {Compacted}
(W)     send.ugm (1|M0)          r5       r0      null:0  0x0            0x0210641F           {$14} // wr:1+0, rd:1; fence invalid flush type scoped to tile
(W)     mov (8|M0)               null<1>:ud    r5.0<1;1,0>:ud                   {$14.dst}
(W)     send.gtwy (1|M0)         null     r127    null:0  0x0            0x02000010           {EOT,A@1} // wr:1+0, rd:0; end of thread
L6528:
        mov (1|M0)               r1.2<1>:d     cr0.0<0;1,0>:ud                  {A@1}
        and (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   -1265:w               {A@1}
        or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   1264:w               {A@1}
        mov (1|M0)               r1.5<1>:f     (abs)r83.5<0;1,0>:d              {A@1}
        mov (1|M0)               r4.4<1>:f     0xB4C00000:f                               {Compacted}
        math.inv (1|M0)          r4.3<1>:f     r1.5<0;1,0>:f                    {@2,$15}
        mov (1|M0)               r2.1<1>:f     (abs)r83.4<0;1,0>:d             
        sync.nop                             null                             {Compacted,$15.dst}
        mad (1|M0)               r4.3<1>:f     r4.3<0;0>:f       r4.4<0;0>:f       r4.3<0>:f        {F@2}
        mov (1|M0)               r1.3<1>:d     (abs)r83.4<0;1,0>:d             
        mov (1|M0)               r1.4<1>:d     (abs)r83.5<0;1,0>:d             
        mov (1|M0)               r1.6<1>:ud    r1.5<0;1,0>:f                   
        mov (1|M0)               r2.3<1>:ud    r2.1<0;1,0>:f                    {F@2}
        mul (1|M0)               r5.0<1>:f     r4.3<0;1,0>:f     r2.1<0;1,0>:f    {A@1}
        add (1|M0)               r1.6<1>:ud    r1.4<0;1,0>:ud    -r1.6<0;1,0>:ud  {I@2}
        add (1|M0)               r2.3<1>:ud    r1.3<0;1,0>:ud    -r2.3<0;1,0>:ud  {I@2}
        mov (1|M0)               r6.0<1>:ud    r5.0<0;1,0>:f                    {F@1}
        mov (1|M0)               r2.0<1>:f     r1.6<0;1,0>:ud                   {Compacted,I@3}
        mov (1|M0)               r4.2<1>:f     r2.3<0;1,0>:ud                   {I@2}
        mov (1|M0)               r6.1<1>:f     r6.0<0;1,0>:ud                   {Compacted,I@1}
        xor (1|M0)               r83.5<1>:d    r83.5<0;1,0>:d    r83.4<0;1,0>:d  
        mad (1|M0)               r2.1<1>:f     r2.1<0;0>:f       r6.1<0;0>:f       -r1.5<0>:f       {F@1}
        mad (1|M0)               r6.1<1>:f     r4.2<0;0>:f       r6.1<0;0>:f       -r2.0<0>:f      
(W)     mov (1|M0)               r5.0<1>:hf    0x1:hf                             
        add (1|M0)               r2.1<1>:f     r2.1<0;1,0>:f     r6.1<0;1,0>:f    {F@2}
        asr (1|M0)               r83.5<1>:d    r83.5<0;1,0>:d    31:w               {I@1}
        mul (1|M0)               r4.3<1>:f     r4.3<0;1,0>:f     r2.1<0;1,0>:f    {F@1}
        mov (1|M0)               r7.0<1>:ud    r4.3<0;1,0>:f                    {F@1}
        add (1|M0)               r6.0<1>:ud    r6.0<0;1,0>:ud    r7.0<0;1,0>:ud   {Compacted,I@1}
(W)     mul (1|M0)               acc0.0<1>:ud  r6.0<0;1,0>:ud    r1.8<0;1,0>:uw   {I@1}
        mach (1|M0)              r8.0<1>:ud    r6.0<0;1,0>:ud    r1.4<0;1,0>:ud   {Compacted}
        add (1|M0)               r1.3<1>:ud    r1.3<0;1,0>:ud    -r8.0<0;1,0>:ud  {Compacted,I@1}
        cmp (1|M0)    (ge)f1.1   null<1>:ud    r1.3<0;1,0>:ud    r1.4<0;1,0>:ud   {I@1}
(f1.1)  sel (1|M0)               r9.0<1>:d     r5.0<0;1,0>:w     0:w              
        add3 (1|M0)              r6.0<1>:d     r6.0<0;0>:d       r83.5<0;0>:d      r9.0<0>:d        {I@1}
        xor (1|M0)               r42.1<1>:d    r6.0<0;1,0>:d     r83.5<0;1,0>:d   {I@1}
        mov (1|M0)               cr0.0<1>:ud   r1.2<0;1,0>:d                    {A@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        ret (16|M0)                          r83.2                            {A@1}
L7112:
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
