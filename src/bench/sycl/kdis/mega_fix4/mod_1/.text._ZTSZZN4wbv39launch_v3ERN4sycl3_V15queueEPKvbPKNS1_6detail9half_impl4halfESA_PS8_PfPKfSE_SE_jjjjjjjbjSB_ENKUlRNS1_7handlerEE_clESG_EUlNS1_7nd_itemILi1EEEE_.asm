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
(W)     mov (2|M0)               r46.0<1>:ud   r4.6<1;1,0>:ud                   {$1.dst}
        and (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   -1265:w               {A@1}
        or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   1216:w               {A@1}
        and (1|M0)               r4.7<1>:d     r2.4<0;1,0>:d     -2:w               {A@1}
        mov (1|M0)               r1.5<1>:d     r1.0<0;1,0>:uw                   {$0.dst}
        cmp (1|M0)    (eq)f0.0   null<1>:d     r4.7<0;1,0>:d     0xFFFE:uw              {I@2}
        and (1|M0)               r4.26<2>:b    r3.0<0;1,0>:b     1:w              
        and (1|M0)               r4.24<2>:b    r5.4<0;1,0>:b     1:w              
        mov (1|M0)               r1.2<1>:d     r0.1<0;1,0>:ud                  
(W)     and (1|M0)               f1.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
        mov (1|M0)               r1.6<1>:d     r0.1<0;1,0>:ud                  
        mov (1|M0)               r1.7<1>:d     0:w                              
        mov (1|M0)               r5.6<1>:d     r1.0<0;1,0>:uw                  
        mov (1|M0)               r5.7<1>:d     0:w                              
        shr (1|M0)               r1.4<1>:ud    r1.5<0;1,0>:ud    0x4:uw              {I@7}
(f1.1.any16h) goto (16|M0)                   L28784                  L28784                
L432:
        mov (1|M0)               r6.5<1>:d     r1.2<0;1,0>:d                    {I@7}
        mov (1|M0)               r6.2<1>:d     r2.5<0;1,0>:d                   
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r46.2         L28856                                 {A@1}
L512:
        shl (1|M0)               r1.3<1>:d     r6.0<0;1,0>:d     3:w               {Compacted}
        shr (1|M0)               r46.2<1>:ud   r1.5<0;1,0>:ud    0x3:uw             
(W)     mul (1|M0)               acc0.0<1>:d   r6.0<0;1,0>:d     r2.10<0;1,0>:uw  {Compacted}
        add3 (1|M0)              r1.3<1>:ud    r1.3<0;0>:ud      r46.2<0;0>:ud     -r2.2<0>:ud      {I@2}
        mach (1|M0)              r6.0<1>:d     r6.0<0;1,0>:d     r2.5<0;1,0>:d    {Compacted}
        cmp (1|M0)    (gt)f0.0   null<1>:d     r1.3<0;1,0>:d     -1:w               {I@2}
        add (1|M0)               r1.2<1>:d     r1.2<0;1,0>:d     -r6.0<0;1,0>:d   {I@2}
        and (1|M0)               r4.7<1>:d     r1.0<0;1,0>:uw    7:w              
        shl (1|M0)               r5.1<1>:ud    r46.2<0;1,0>:ud   0x7:uw             
        shl (1|M0)               r1.2<1>:d     r1.2<0;1,0>:d     3:w               {I@3}
(W)     and (1|M0)               f1.0<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
        shl (1|M0)               r46.5<1>:ud   r1.4<0;1,0>:ud    0x9:uw             
        and (1|M0)               r5.1<1>:ud    r5.1<0;1,0>:ud    0x80:uw              {I@4}
        add3 (1|M0)              r1.2<1>:d     r1.2<0;0>:d       r4.7<0;0>:d       -r2.3<0>:d       {I@4}
        shl (1|M0)               r4.7<1>:d     r4.7<0;1,0>:d     4:w              
        mov (16|M0)              r8.0<1>:f     0.0:f                               {Compacted}
        mov (16|M0)              r6.0<1>:f     0.0:f                               {Compacted}
        bfn.0xFE (1|M0)          r46.5<1>:ud   r4.7<0;0>:ud      r5.1<0;0>:ud      r46.5<0>:ud      {I@1} // s0|s1|s2
(~f1.0.any16h) goto (16|M0)                  L1432                  L1432                
L776:
        cmp (1|M0)    (gt)f1.1   null<1>:d     r1.2<0;1,0>:d     -1:w              
        cmp (1|M0)    (lt)f0.1   null<1>:d     r1.2<0;1,0>:d     r2.7<0;1,0>:d   
(W)     mov (1|M0)               r46.6<1>:hf   0x1:hf                             
(f1.1)  cmp (1|M0)    (lt)f1.1   null<1>:d     r1.3<0;1,0>:d     r2.6<0;1,0>:d   
(f1.1)  sel (1|M0)               r46.7<1>:uw   r46.6<0;1,0>:uw   0x0:uw              {F@1}
(f0.1)  sel (1|M0)               r46.6<1>:uw   r46.6<0;1,0>:uw   0x0:uw             
        and (1|M0)    (ne)f1.1   null<1>:uw    r46.7<0;1,0>:uw   r46.6<0;1,0>:uw  {I@1}
(W)     and (1|M0)               f0.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(~f0.1.any16h) goto (16|M0)                  L1432                  L1432                
L920:
        mul (1|M0)               acc0.0<1>:ud  r1.3<0;1,0>:ud    r2.14<0;1,0>:uw 
        mach (1|M0)              r8.0<1>:ud    r1.3<0;1,0>:ud    r2.7<0;1,0>:ud   {AccWrEn}
        cmp (1|M0)    (eq)f1.0   null<1>:w     r4.26<0;1,0>:b    0:w              
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r9.0<1>:ud    r7.0<0;1,0>:ud    r1.2<0;1,0>:ud   {AccWrEn,I@1}
(W)     and (1|M0)               f1.1<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        shr (1|M0)               r9.1<1>:ud    r9.0<0;1,0>:ud    0x1B:uw              {I@3}
        add3 (1|M0)              r46.4<1>:d    r6.0<0;0>:d       r8.0<0;0>:d       0:w               {I@2}
        shl (1|M0)               r46.3<1>:d    r9.0<0;1,0>:d     5:w               {Compacted}
        shl (1|M0)               r9.2<1>:d     r46.4<0;1,0>:d    5:w               {I@2}
        or (1|M0)                r46.4<1>:d    r9.2<0;1,0>:d     r9.1<0;1,0>:d    {I@1}
(f1.1.any16h) goto (16|M0)                   L1296                  L1296                
L1104:
        shr (1|M0)               r46.6<1>:ud   r46.3<0;1,0>:ud   0x1F:uw             
        shl (1|M0)               r46.3<1>:d    r46.3<0;1,0>:d    1:w               {Compacted}
        shl (1|M0)               r46.7<1>:d    r46.4<0;1,0>:d    1:w               {I@4}
        addc (1|M0)              r6.0<1>:ud    r3.2<0;1,0>:ud    r46.3<0;1,0>:ud  {AccWrEn,I@2}
        or (1|M0)                r46.4<1>:d    r46.7<0;1,0>:d    r46.6<0;1,0>:d   {I@2}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        add3 (1|M0)              r6.1<1>:d     r7.0<0;0>:d       r3.3<0;0>:d       r46.4<0>:d       {I@1}
        send.ugm (1|M0)          r10      r6      null:0  0x0            0x0220C780           {A@1,$2} // wr:1+0, rd:2; load.ugm.d64x8t.a64
        mov (8|M0)               r6.0<1>:f     r10.0<1;1,0>:hf                  {$2.dst}
        mov (8|M0)               r7.0<1>:f     r10.8<1;1,0>:hf                 
        mov (8|M0)               r8.0<1>:f     r11.0<1;1,0>:hf                 
        mov (8|M0)               r9.0<1>:f     r11.8<1;1,0>:hf                 
        goto (16|M0)                         L1296                  L1432                
L1296:
        join (16|M0)                         L1432                                
L1312:
        shl (1|M0)               r10.1<1>:d    r46.4<0;1,0>:d    2:w               {F@4}
        shr (1|M0)               r10.0<1>:ud   r46.3<0;1,0>:ud   0x1E:uw             
        shl (1|M0)               r10.2<1>:d    r46.3<0;1,0>:d    2:w              
        or (1|M0)                r10.3<1>:d    r10.1<0;1,0>:d    r10.0<0;1,0>:d   {I@2}
        addc (1|M0)              r10.0<1>:ud   r3.2<0;1,0>:ud    r10.2<0;1,0>:ud  {AccWrEn,I@2}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        add3 (1|M0)              r10.1<1>:d    r6.0<0;0>:d       r3.3<0;0>:d       r10.3<0>:d       {I@1}
        send.ugm (1|M0)          r6       r10     null:0  0x0            0x0240D780           {A@1,$3} // wr:1+0, rd:4; load.ugm.d64x16t.a64
L1432:
        join (16|M0)                         L28784                                
L1448:
        sel (16|M0)   (lt)f0.0   r12.0<1>:f    (abs)r6.0<1;1,0>:f  448.0:f             {Compacted,$3.dst}
        sel (16|M0)   (lt)f0.0   r10.0<1>:f    (abs)r8.0<1;1,0>:f  448.0:f             {Compacted}
        shr (16|M0)              r18.0<1>:ud   r12.0<1;1,0>:ud   0x17:uw              {F@2}
        shr (16|M0)              r16.0<1>:ud   r10.0<1;1,0>:ud   0x17:uw              {F@1}
        sel (16|M0)   (ge)f0.0   r14.0<2>:ub   r18.0<4;1,0>:ub   0x79:uw              {I@2}
        sel (16|M0)   (ge)f0.0   r15.0<2>:ub   r16.0<4;1,0>:ub   0x79:uw              {I@2}
        mov (16|M0)              r18.0<1>:d    r14.0<2;1,0>:ub                  {I@2}
        mov (16|M0)              r16.0<1>:d    r15.0<2;1,0>:ub                  {I@2}
        shl (16|M0)              r18.0<1>:d    r18.0<1;1,0>:d    23:w               {Compacted,I@2}
        shl (16|M0)              r16.0<1>:d    r16.0<1;1,0>:d    23:w               {Compacted,I@2}
        add (16|M0)              r20.0<1>:d    r18.0<1;1,0>:d    -25165824:d               {I@2}
        add (16|M0)              r18.0<1>:d    -r18.0<1;1,0>:d   -2139095040:d              
        add (16|M0)              r14.0<1>:d    r16.0<1;1,0>:d    -25165824:d               {I@3}
        mul (16|M0)              acc0.0<1>:f   r12.0<1;1,0>:f    r18.0<1;1,0>:f   {Compacted,I@2}
        add (16|M0)              r16.0<1>:d    -r16.0<1;1,0>:d   -2139095040:d              
        rnde (16|M0)             acc0.0<1>:f   acc0.0<1;1,0>:f                 
        mul (16|M0)              acc2.0<1>:f   r10.0<1;1,0>:f    r16.0<1;1,0>:f   {Compacted,I@1}
        cmp (16|M0)   (lt)f0.1   null<1>:f     r6.0<1;1,0>:f     0.0:f              
        rnde (16|M0)             acc2.0<1>:f   acc2.0<1;1,0>:f                 
        mul (16|M0)              acc0.0<1>:f   acc0.0<1;1,0>:f   r20.0<1;1,0>:f   {Compacted}
        cmp (16|M0)   (lt)f1.1   null<1>:f     r8.0<1;1,0>:f     0.0:f              
        mul (16|M0)              acc2.0<1>:f   acc2.0<1;1,0>:f   r14.0<1;1,0>:f   {Compacted}
        mov (16|M0)              r16.0<1>:f    (abs)acc0.0<1;1,0>:f             {Compacted}
        mov (16|M0)              r12.0<1>:f    (abs)acc2.0<1;1,0>:f             {Compacted}
(f0.1)  or (16|M0)               r16.0<1>:d    r16.0<1;1,0>:d    -2147483648:d               {F@2}
        shl (1|M0)               r79.0<1>:ud   r46.5<0;1,0>:ud   0x1:uw             
(f1.1)  or (16|M0)               r12.0<1>:d    r12.0<1;1,0>:d    -2147483648:d               {F@1}
        mov (8|M0)               r6.0<1>:hf    r16.0<1;1,0>:f                   {I@3}
        mov (8|M0)               r6.8<1>:hf    r17.0<1;1,0>:f                  
        mov (8|M0)               r7.0<1>:hf    r12.0<1;1,0>:f                   {I@1}
        send.slm (1|M0)          null     r79     r6:1    0x0            0x0200B704           {A@2,$4} // wr:1+1, rd:0; store.slm.d64x4t.a32
        mov (8|M0)               r7.8<1>:hf    r13.0<1;1,0>:f                  
        or (1|M0)                r6.0<1>:ud    r79.0<0;1,0>:ud   0x200:uw              {$4.src}
        send.slm (1|M0)          null     r6      r7:1    0x0            0x0200B704           {A@1,$5} // wr:1+1, rd:0; store.slm.d64x4t.a32
        sync.nop                             null                             {Compacted,$5.src}
(W)     send.slm (1|M0)          r6       r0      null:0  0x0            0x0210001F           {$6} // wr:1+0, rd:1; fence.slm.none.group
(W)     mov (8|M0)               null<1>:ud    r6.0<1;1,0>:ud                   {$6.dst}
(W)     mov (1|M0)               r6.2<1>:f     0.0:f                               {Compacted,I@1}
(W)     mov (2|M0)               r6.10<1>:ub   r0.11<0;1,0>:ub                  {F@1}
(W)     send.gtwy (1|M0)         null     r6      null:0  0x0            0x02000004           {A@1,$7} // wr:1+0, rd:0; signal barrier
(W)     sync.bar                             null                            
        cmp (1|M0)    (eq)f1.0   null<1>:d     r2.4<0;1,0>:d     1:w              
(W)     and (1|M0)               f1.0<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
(f1.0.any16h) goto (16|M0)                   L28024                  L28024                
L2056:
        cmp (1|M0)    (lt)f0.1   null<1>:uw    r1.0<0;1,0>:uw    0x180:uw             
(W)     and (1|M0)               f0.1<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(~f0.1.any16h) goto (16|M0)                  L3928                  L3928                
L2104:
        mov (16|M0)              r6.0<1>:ud    0x0:ud                              {$7.src}
        mov (16|M0)              r8.0<1>:ud    0x0:ud                             
        mov (16|M0)              r10.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r12.0<1>:f    0.0:f                               {Compacted}
        mov (1|M0)               r46.3<1>:d    r1.4<0;1,0>:d                   
L2168:
        mov (1|M0)               r79.4<2>:b    r46.12<0;1,0>:b                  {I@1}
        mov (1|M0)               r79.6<2>:b    6:w                              
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r46.6         L29400                                 {A@1}
L2248:
        mov (1|M0)               r46.18<2>:b   -6:w                              
        mov (1|M0)               r46.6<1>:d    r46.16<0;1,0>:ub                
(W)     mov (1|M0)               r46.9<1>:w    r46.18<0;1,0>:b                  {I@2}
        shl (1|M0)               r63.0<1>:d    r46.6<0;1,0>:d    10:w               {Compacted,I@2}
        mul (1|M0)               r46.9<1>:w    r46.16<0;1,0>:b   r46.9<0;1,0>:w   {I@2}
        send.slm (1|M0)          r22      r63     null:0  0x0            0x0280E700           {A@2,$10} // wr:1+0, rd:8; load.slm.d64x32t.a32
        add (1|M0)               r46.18<2>:b   r46.12<0;1,0>:b   r46.9<0;1,0>:w   {I@1}
        cmp (1|M0)    (lt)f1.1   null<1>:ud    r46.3<0;1,0>:ud   0x14:uw             
        mov (1|M0)               r46.5<1>:d    r46.18<0;1,0>:ub                 {I@2}
        mul (1|M0)               r46.4<1>:d    r46.16<0;1,0>:ub  6144:w              
        shl (1|M0)               r46.6<1>:d    r46.5<0;1,0>:d    8:w               {I@2}
        add (1|M0)               r46.4<1>:d    r46.4<0;1,0>:d    4096:w               {I@2}
        sync.nop                             null                             {Compacted,$10.src}
        shr (1|M0)               r63.1<1>:ud   r46.6<0;1,0>:ud   0x1F:uw              {I@2}
        shl (1|M0)               r46.6<1>:d    r46.6<0;1,0>:d    1:w              
        or (1|M0)                r46.7<1>:d    r63.1<0;1,0>:d    0:w               {I@2}
        addc (1|M0)              r15.0<1>:ud   r3.6<0;1,0>:ud    r46.6<0;1,0>:ud  {AccWrEn,I@2}
        shl (1|M0)               r46.5<1>:d    r46.5<0;1,0>:d    6:w              
        mov (1|M0)               r14.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r64.0<1>:f    r15.0<0;1,0>:f                   {Compacted,I@3}
        add3 (1|M0)              r64.1<1>:d    r14.0<0;0>:d      r3.7<0;0>:d       r46.7<0>:d       {I@1}
        or (1|M0)                r14.0<1>:ud   r63.0<0;1,0>:ud   0x100:uw             
        send.ugm (1|M0)          r47      r64     null:0  0x0            0x0280E780           {A@1,$11} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        send.slm (1|M0)          r38      r14     null:0  0x0            0x0280E700           {A@1,$12} // wr:1+0, rd:8; load.slm.d64x32t.a32
        addc (1|M0)              r14.0<1>:ud   r64.0<0;1,0>:ud   0x100:ud              {AccWrEn,$12.src}
(W)     and (1|M0)               f1.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
        mov (1|M0)               r15.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        add3 (1|M0)              r14.1<1>:d    r15.0<0;0>:d      r64.1<0;0>:d      0:w               {I@1}
        send.ugm (1|M0)          r55      r14     null:0  0x0            0x0280E780           {A@1,$13} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        sync.allwr                           ($10,$11,$12,$13)                
        dpas.8x8 (8|M0)          r30:f         null:f            r30:hf            r30.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r30:f         r6:f              r47:hf            r22.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r14:f         r6:f              r55:hf            r22.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r22:f         r6:f              r47:hf            r38.0:hf         {$10}
        addc (1|M0)              r48.0<1>:ud   r64.0<0;1,0>:ud   0xC00:ud              {AccWrEn,$10.src}
        dpas.8x8 (8|M0)          r38:f         r6:f              r55:hf            r38.0:hf         {$14}
        mov (1|M0)               r71.0<1>:f    r48.0<0;1,0>:f                   {Compacted,I@1}
        mov (1|M0)               r47.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r73.0<1>:ud   r71.0<0;1,0>:ud   0x100:ud              {AccWrEn,F@1}
        add3 (1|M0)              r71.1<1>:d    r47.0<0;0>:d      r64.1<0;0>:d      0:w               {I@2}
        mov (1|M0)               r72.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        or (1|M0)                r55.0<1>:ud   r63.0<0;1,0>:ud   0x200:uw              {$14.src}
        mov (1|M0)               r80.0<1>:f    r73.0<0;1,0>:f                   {Compacted,I@4}
        or (1|M0)                r63.0<1>:ud   r63.0<0;1,0>:ud   0x300:uw             
        add3 (1|M0)              r80.1<1>:d    r72.0<0;0>:d      r71.1<0;0>:d      0:w               {I@3}
        send.slm (1|M0)          r47      r55     null:0  0x0            0x0280E700           {A@3,$15} // wr:1+0, rd:8; load.slm.d64x32t.a32
        send.slm (1|M0)          r55      r63     null:0  0x0            0x0280E700           {A@2,$0} // wr:1+0, rd:8; load.slm.d64x32t.a32
        sync.nop                             null                             {Compacted,$0.src}
        send.ugm (1|M0)          r63      r71     null:0  0x0            0x0280E780           {$1} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        send.ugm (1|M0)          r71      r80     null:0  0x0            0x0280E780           {A@1,$2} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        sync.allwr                           ($0,$1,$2,$10,$14,$15)                
(W)     sync.nop                             null                            
(W)     sync.nop                             null                            
        dpas.8x8 (8|M0)          r30:f         null:f            r30:hf            r30.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r30:f         r30:f             r63:hf            r47.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r22:f         r22:f             r63:hf            r55.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r14:f         r14:f             r71:hf            r47.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r38:f         r38:f             r71:hf            r55.0:hf         {$10}
        or (1|M0)                r48.0<1>:d    r46.5<0;1,0>:d    r46.4<0;1,0>:d   {$10.src}
        add (1|M0)               r46.4<1>:d    r46.3<0;1,0>:d    4:w              
        add (1|M0)               r47.0<1>:ud   r48.0<0;1,0>:ud   0xC00:uw              {I@2}
        mov (8|M0)               r51.0<1>:f    r30.0<1;1,0>:f                   {Compacted,$10.dst}
        mov (8|M0)               r49.0<1>:f    r22.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r52.0<1>:f    r14.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r50.0<1>:f    r38.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r48     r51:2   0x0            0x0200C704           {A@2,$3} // wr:1+2, rd:0; store.slm.d64x8t.a32
        send.slm (1|M0)          null     r47     r49:2   0x0            0x0200C704           {A@1,$4} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r51.0<1>:f    r31.0<1;1,0>:f                   {Compacted,$3.src}
        mov (8|M0)               r52.0<1>:f    r15.0<1;1,0>:f                   {Compacted}
        add (1|M0)               r47.0<1>:ud   r48.0<0;1,0>:ud   0x180:uw              {$4.src}
        mov (8|M0)               r49.0<1>:f    r23.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r47     r51:2   0x0            0x0200C704           {A@1,$5} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r50.0<1>:f    r39.0<1;1,0>:f                   {Compacted}
        add (1|M0)               r47.0<1>:ud   r48.0<0;1,0>:ud   0xD80:uw              {$5.src}
        mov (8|M0)               r51.0<1>:f    r32.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r47     r49:2   0x0            0x0200C704           {A@1,$6} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r52.0<1>:f    r16.0<1;1,0>:f                   {Compacted}
        add (1|M0)               r47.0<1>:ud   r48.0<0;1,0>:ud   0x300:uw              {$6.src}
        mov (8|M0)               r49.0<1>:f    r24.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r47     r51:2   0x0            0x0200C704           {A@1,$10} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r50.0<1>:f    r40.0<1;1,0>:f                   {Compacted}
        add (1|M0)               r47.0<1>:ud   r48.0<0;1,0>:ud   0xF00:uw              {$10.src}
        mov (8|M0)               r51.0<1>:f    r33.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r47     r49:2   0x0            0x0200C704           {A@1,$11} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r52.0<1>:f    r17.0<1;1,0>:f                   {Compacted}
        add (1|M0)               r47.0<1>:ud   r48.0<0;1,0>:ud   0x480:uw              {$11.src}
        mov (8|M0)               r49.0<1>:f    r25.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r47     r51:2   0x0            0x0200C704           {A@1,$12} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r50.0<1>:f    r41.0<1;1,0>:f                   {Compacted}
        add (1|M0)               r47.0<1>:ud   r48.0<0;1,0>:ud   0x1080:uw              {$12.src}
        mov (8|M0)               r51.0<1>:f    r34.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r47     r49:2   0x0            0x0200C704           {A@1,$13} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r52.0<1>:f    r18.0<1;1,0>:f                   {Compacted}
        add (1|M0)               r47.0<1>:ud   r48.0<0;1,0>:ud   0x600:uw              {$13.src}
        mov (8|M0)               r49.0<1>:f    r26.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r47     r51:2   0x0            0x0200C704           {A@1,$14} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r50.0<1>:f    r42.0<1;1,0>:f                   {Compacted}
        add (1|M0)               r47.0<1>:ud   r48.0<0;1,0>:ud   0x1200:uw              {$14.src}
        mov (8|M0)               r51.0<1>:f    r35.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r47     r49:2   0x0            0x0200C704           {A@1,$15} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r52.0<1>:f    r19.0<1;1,0>:f                   {Compacted}
        add (1|M0)               r47.0<1>:ud   r48.0<0;1,0>:ud   0x780:uw              {$15.src}
        mov (8|M0)               r49.0<1>:f    r27.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r47     r51:2   0x0            0x0200C704           {A@1,$0} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r50.0<1>:f    r43.0<1;1,0>:f                   {Compacted}
        add (1|M0)               r47.0<1>:ud   r48.0<0;1,0>:ud   0x1380:uw              {$0.src}
        mov (8|M0)               r51.0<1>:f    r36.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r47     r49:2   0x0            0x0200C704           {A@1,$1} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r52.0<1>:f    r20.0<1;1,0>:f                   {Compacted}
        add (1|M0)               r47.0<1>:ud   r48.0<0;1,0>:ud   0x900:uw              {$1.src}
        mov (8|M0)               r30.0<1>:f    r37.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r47     r51:2   0x0            0x0200C704           {A@1,$2} // wr:1+2, rd:0; store.slm.d64x8t.a32
        add (1|M0)               r14.0<1>:ud   r48.0<0;1,0>:ud   0xA80:uw             
        mov (8|M0)               r31.0<1>:f    r21.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r49.0<1>:f    r28.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r50.0<1>:f    r44.0<1;1,0>:f                   {Compacted}
        add (1|M0)               r47.0<1>:ud   r48.0<0;1,0>:ud   0x1500:uw              {$2.src}
        mov (8|M0)               r15.0<1>:f    r29.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r47     r49:2   0x0            0x0200C704           {A@1,$9} // wr:1+2, rd:0; store.slm.d64x8t.a32
        send.slm (1|M0)          null     r14     r30:2   0x0            0x0200C704           {$3} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r16.0<1>:f    r45.0<1;1,0>:f                   {Compacted}
        add (1|M0)               r14.0<1>:ud   r48.0<0;1,0>:ud   0x1680:uw              {$3.src}
        send.slm (1|M0)          null     r14     r15:2   0x0            0x0200C704           {A@1,$8} // wr:1+2, rd:0; store.slm.d64x8t.a32
(~f1.1.any16h) goto (16|M0)                  L3928                  L3928                
L3896:
        mov (1|M0)               r46.3<1>:d    r46.4<0;1,0>:d                  
        goto.b (16|M0)                       L3928                  L2168                
L3928:
        join (16|M0)                         L28024                                
L3944:
        sync.nop                             null                             {Compacted,$7.src}
(W)     send.slm (1|M0)          r6       r0      null:0  0x0            0x0210001F           {$4} // wr:1+0, rd:1; fence.slm.none.group
(W)     mov (8|M0)               null<1>:ud    r6.0<1;1,0>:ud                   {$4.dst}
(W)     mov (1|M0)               r6.2<1>:f     0.0:f                               {Compacted,I@1}
(W)     mov (2|M0)               r6.10<1>:ub   r0.11<0;1,0>:ub                  {F@1}
(W)     send.gtwy (1|M0)         null     r6      null:0  0x0            0x02000004           {A@1,$5} // wr:1+0, rd:0; signal barrier
(W)     sync.bar                             null                            
        cmp (1|M0)    (eq)f1.0   null<1>:d     r2.4<0;1,0>:d     2:w              
(W)     and (1|M0)               f1.0<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
(f1.0.any16h) goto (16|M0)                   L27064                  L27064                
L4088:
        shl (1|M0)               r3.1<1>:ud    r1.5<0;1,0>:ud    0x4:uw             
        shl (1|M0)               r3.6<1>:ud    r1.5<0;1,0>:ud    0x1:uw             
        shl (1|M0)               r46.6<1>:ud   r1.5<0;1,0>:ud    0x3:uw             
        mul (1|M0)               r46.3<1>:d    r1.0<0;1,0>:uw    384:w              
        add (1|M0)               r55.0<1>:ud   r79.0<0;1,0>:ud   0x7000:uw             
        add (1|M0)               r3.0<1>:ud    r79.0<0;1,0>:ud   0x7200:uw             
        and (1|M0)               r46.5<1>:d    r1.0<0;1,0>:uw    1:w              
        mov (1|M0)               r46.4<1>:d    0:w                              
        and (1|M0)               r3.7<1>:ud    r3.1<0;1,0>:ud    0x80:uw              {I@7}
        and (1|M0)               r3.6<1>:ud    r3.6<0;1,0>:ud    0xE:uw              {I@7}
        and (1|M0)               r46.6<1>:ud   r46.6<0;1,0>:ud   0x70:uw              {I@7}
L4264:
        shl (1|M0)               r46.7<1>:d    r46.4<0;1,0>:d    7:w               {I@4}
        cmp (1|M0)    (eq)f0.1   null<1>:d     r46.4<0;1,0>:d    2:w              
        sync.nop                             null                             {Compacted,$6.src}
        add3 (1|M0)              r10.0<1>:d    r46.3<0;0>:d      r46.7<0;0>:d      4096:w               {I@2}
        sync.allrd                           ($5,$11)                
        send.slm (1|M0)          r6       r10     null:0  0x0            0x0240D700           {A@1,$6} // wr:1+0, rd:4; load.slm.d64x16t.a32
(W)     and (1|M0)               f0.1<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(f0.1.any16h) goto (16|M0)                   L6696                  L6696                
L4384:
        mov (8|M0)               r11.0<1>:hf   r6.0<1;1,0>:f                    {$6.dst}
        mov (8|M0)               r10.0<1>:hf   r8.0<1;1,0>:f                   
        mov (8|M0)               r10.8<1>:hf   r9.0<1;1,0>:f                   
        mov (8|M0)               r8.0<1>:f     r11.0<1;1,0>:hf                  {F@3}
        mov (8|M0)               r11.8<1>:hf   r7.0<1;1,0>:f                   
        mov (8|M0)               r6.0<1>:f     r10.0<1;1,0>:hf                  {F@4}
        sync.nop                             null                             {Compacted,$10.src}
        mov (8|M0)               r7.0<1>:f     r10.8<1;1,0>:hf                  {F@4}
        mul (8|M0)               r10.0<1>:f    r8.0<1;1,0>:f     r8.0<1;1,0>:f    {Compacted,F@4}
        mov (8|M0)               r9.0<1>:f     r11.8<1;1,0>:hf                  {F@4}
        mov (8|M0)               r55.8<1>:hf   r10.0<1;1,0>:f                   {F@2}
        cmp (1|M0)    (eq)f1.1   null<1>:d     r46.4<0;1,0>:d    0:w              
        mov (8|M0)               acc0.0<1>:f   r55.8<1;1,0>:hf                  {F@1}
        mad (8|M0)               r10.0<1>:f    acc0.0<1;0>:f     r9.0<1;0>:f       r9.0<1>:f       
(W)     and (1|M0)               f1.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
        mov (8|M0)               r11.0<1>:hf   r10.0<1;1,0>:f                   {F@1}
        mul (8|M0)               r10.0<1>:f    r6.0<1;1,0>:f     r6.0<1;1,0>:f    {Compacted}
        mov (8|M0)               r55.8<1>:hf   r10.0<1;1,0>:f                   {F@1}
        mov (8|M0)               acc0.0<1>:f   r55.8<1;1,0>:hf                  {F@1}
        mad (8|M0)               r10.0<1>:f    acc0.0<1;0>:f     r7.0<1;0>:f       r7.0<1>:f       
        mov (8|M0)               r10.0<1>:hf   r10.0<1;1,0>:f                   {F@1}
        add (8|M0)               r11.0<1>:hf   r11.0<1;1,0>:hf   r10.0<1;1,0>:hf  {F@1}
        mov (8|M0)               r11.0<1>:f    r11.0<1;1,0>:hf                  {F@1}
        mov (4|M0)               r10.0<1>:ud   r11.4<1;1,0>:ud                  {F@1}
        add (4|M0)               r11.0<1>:f    r10.0<1;1,0>:f    r11.0<1;1,0>:f   {I@1}
        mov (8|M0)               r55.8<1>:hf   r11.0<1;1,0>:f                   {F@1}
        mov (4|M0)               r11.0<1>:f    r55.8<1;1,0>:hf                  {F@1}
        add (1|M0)               r10.0<1>:f    r11.2<0;1,0>:f    r11.0<0;1,0>:f   {Compacted,F@1}
        add (1|M0)               r10.1<1>:f    r11.3<0;1,0>:f    r11.1<0;1,0>:f  
        mov (8|M0)               r55.8<1>:hf   r10.0<1;1,0>:f                   {F@1}
        mov (1|M0)               r10.0<1>:f    r55.8<0;1,0>:hf                  {F@1}
        mov (1|M0)               r10.1<1>:f    r55.9<0;1,0>:hf                 
        add (1|M0)               r46.7<1>:f    r10.0<0;1,0>:f    r10.1<0;1,0>:f   {F@1}
        mov (1|M0)               r46.14<2>:hf  r46.7<0;1,0>:f                   {F@1}
        mov (1|M0)               r46.7<1>:f    r46.14<0;1,0>:hf                 {F@1}
        sel (1|M0)    (ge)f0.0   r46.7<1>:f    r46.7<0;1,0>:f    6.198883e-05:f               {F@1}
        math.sqt (1|M0)          r46.7<1>:f    r46.7<0;1,0>:f                   {@1,$12}
        math.inv (1|M0)          r46.7<1>:f    r46.7<0;1,0>:f                   {$12}
        mov (1|M0)               r46.14<2>:hf  r46.7<0;1,0>:f                   {$12.dst}
        mov (1|M0)               r10.1<1>:f    r46.14<0;1,0>:hf                 {F@1}
(f1.1.any16h) goto (16|M0)                   L5888                  L5888                
L5008:
        mul (16|M0)              r8.0<1>:f     r10.1<0;1,0>:f    r8.0<1;1,0>:f    {Compacted,F@1}
        mul (16|M0)              r6.0<1>:f     r10.1<0;1,0>:f    r6.0<1;1,0>:f    {Compacted}
        mov (8|M0)               r10.8<1>:hf   r9.0<1;1,0>:f                    {F@2}
        mov (8|M0)               r10.0<1>:hf   r8.0<1;1,0>:f                   
        sync.nop                             null                             {Compacted,$8.src}
        mov (8|M0)               r14.0<1>:hf   r6.0<1;1,0>:f                    {F@3}
        mov (8|M0)               r14.8<1>:hf   r7.0<1;1,0>:f                   
        mov (8|M0)               r13.0<1>:f    (abs)r10.8<1;1,0>:hf             {F@4}
        mov (8|M0)               r12.0<1>:f    (abs)r10.0<1;1,0>:hf             {F@4}
        mov (8|M0)               r11.0<1>:f    (abs)r14.8<1;1,0>:hf             {F@3}
        mov (8|M0)               r10.0<1>:f    (abs)r14.0<1;1,0>:hf            
        sel (16|M0)   (lt)f0.0   r12.0<1>:f    r12.0<1;1,0>:f    448.0:f               {Compacted,F@3}
        sel (16|M0)   (lt)f0.0   r10.0<1>:f    r10.0<1;1,0>:f    448.0:f               {Compacted,F@2}
        shr (16|M0)              r18.0<1>:ud   r12.0<1;1,0>:ud   0x17:uw              {F@2}
        shr (16|M0)              r16.0<1>:ud   r10.0<1;1,0>:ud   0x17:uw              {F@1}
        sel (16|M0)   (ge)f0.0   r14.0<2>:ub   r18.0<4;1,0>:ub   0x79:uw              {I@2}
        sel (16|M0)   (ge)f0.0   r15.0<2>:ub   r16.0<4;1,0>:ub   0x79:uw              {I@2}
        mov (16|M0)              r18.0<1>:d    r14.0<2;1,0>:ub                  {I@2}
        mov (16|M0)              r16.0<1>:d    r15.0<2;1,0>:ub                  {I@2}
        shl (16|M0)              r18.0<1>:d    r18.0<1;1,0>:d    23:w               {Compacted,I@2}
        shl (16|M0)              r16.0<1>:d    r16.0<1;1,0>:d    23:w               {Compacted,I@2}
        add (16|M0)              r20.0<1>:d    r18.0<1;1,0>:d    -25165824:d               {I@2}
        add (16|M0)              r14.0<1>:d    r16.0<1;1,0>:d    -25165824:d               {I@2}
        add (16|M0)              r18.0<1>:d    -r18.0<1;1,0>:d   -2139095040:d              
        add (16|M0)              r16.0<1>:d    -r16.0<1;1,0>:d   -2139095040:d              
        mul (16|M0)              acc0.0<1>:f   r12.0<1;1,0>:f    r18.0<1;1,0>:f   {Compacted,I@2}
        mul (16|M0)              acc2.0<1>:f   r10.0<1;1,0>:f    r16.0<1;1,0>:f   {Compacted,I@1}
        rnde (16|M0)             acc0.0<1>:f   acc0.0<1;1,0>:f                 
        rnde (16|M0)             acc2.0<1>:f   acc2.0<1;1,0>:f                 
        cmp (16|M0)   (lt)f1.0   null<1>:f     r8.0<1;1,0>:f     0xB3000000:f               {Compacted}
        cmp (16|M0)   (lt)f0.1   null<1>:f     r6.0<1;1,0>:f     0xB3000000:f              
        mul (16|M0)              acc0.0<1>:f   acc0.0<1;1,0>:f   r20.0<1;1,0>:f   {Compacted}
        mul (16|M0)              acc2.0<1>:f   acc2.0<1;1,0>:f   r14.0<1;1,0>:f   {Compacted}
        mov (16|M0)              r16.0<1>:f    (abs)acc0.0<1;1,0>:f             {Compacted}
        mov (16|M0)              r12.0<1>:f    (abs)acc2.0<1;1,0>:f             {Compacted}
(f1.0)  or (16|M0)               r16.0<1>:d    r16.0<1;1,0>:d    -2147483648:d               {F@2}
(f0.1)  or (16|M0)               r12.0<1>:d    r12.0<1;1,0>:d    -2147483648:d               {F@1}
        mov (1|M0)               r6.1<1>:d     0:w                              
        mov (8|M0)               r7.0<1>:hf    r16.0<1;1,0>:f                   {I@3}
        mov (8|M0)               r7.8<1>:hf    r17.0<1;1,0>:f                  
        mov (8|M0)               r8.0<1>:hf    r12.0<1;1,0>:f                   {I@2}
        mov (8|M0)               r8.8<1>:hf    r13.0<1;1,0>:f                  
L5568:
        sync.nop                             null                             {Compacted,$13.src}
        shr (1|M0)               r6.2<1>:ud    r6.1<0;1,0>:ud    0x2:uw              {I@1}
        shl (1|M0)               r6.0<1>:ud    r6.1<0;1,0>:ud    0x3:uw             
        and (1|M0)               r6.2<1>:ud    r6.2<0;1,0>:ud    0x4:uw              {I@2}
        and (1|M0)               r9.0<1>:d     r6.1<0;1,0>:d     1:w               {Compacted}
        add (1|M0)               r6.2<1>:ud    r6.2<0;1,0>:ud    r1.4<0;1,0>:ud   {I@2}
        shl (1|M0)               r46.14<1>:w   r6.2<0;1,0>:w     1:w              
        and (1|M0)               r6.0<1>:ud    r6.0<0;1,0>:ud    0x70:uw             
        shl (1|M0)               r6.2<1>:ud    r6.2<0;1,0>:ud    0x8:uw              {I@3}
        add (1|M0)               r6.1<1>:ud    r6.1<0;1,0>:ud    0x1:uw             
        bfn.0xFE (1|M0)          r9.0<1>:ud    r9.0<0;0>:ud      r6.2<0;0>:ud      r6.0<0>:ud       {I@2} // s0|s1|s2
        cmp (1|M0)    (eq)f1.1   null<1>:d     r6.1<0;1,0>:d     32:w               {I@2}
        add (1|M0)               a0.0<1>:uw    r46.14<0;1,0>:uw  0xE0:uw              {A@1}
        bfn.0xFE (1|M0)          r9.0<1>:ud    r3.6<0;0>:ud      r9.0<0;0>:ud      r3.7<0>:ud       {I@3} // s0|s1|s2
        shl (1|M0)               r9.0<1>:ud    r9.0<0;1,0>:ud    0x1:uw              {I@1}
(W)     and (1|M0)               f1.0<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
        mov (1|M0)               r6.0<1>:d     r[a0.0]<0;1,0>:uw                {A@1}
        add (1|M0)               r9.0<1>:ud    r9.0<0;1,0>:ud    0x8000:uw              {A@1}
        send.slm (1|M0)          null     r9      r6:1    0x0            0x02000B04           {A@1,$13} // wr:1+1, rd:0; store.slm.d16u32.a32
(f1.0.any16h) goto (16|M0)                   L5888                  L7456                
L5872:
        goto.b (16|M0)                       L5888                  L5568                
L5888:
        join (16|M0)                         L6696                                
L5904:
        send.ugm (1|M0)          r10      r4      null:0  0x0            0x04100580           {$14} // wr:2+0, rd:1; load.ugm.d32.a64
        sync.nop                             null                             {Compacted,$14.dst}
        mul (16|M0)              r8.0<1>:f     r10.1<0;1,0>:f    r8.0<1;1,0>:f    {Compacted,$13.src}
        mul (16|M0)              r6.0<1>:f     r10.1<0;1,0>:f    r6.0<1;1,0>:f    {Compacted}
        mov (8|M0)               r11.0<1>:hf   r8.0<1;1,0>:f                    {F@2}
        mov (8|M0)               r11.8<1>:hf   r9.0<1;1,0>:f                   
        mov (8|M0)               r10.8<1>:hf   r7.0<1;1,0>:f                    {F@3}
        mov (8|M0)               r7.0<1>:f     r11.8<1;1,0>:hf                  {F@2}
        mov (8|M0)               r9.0<1>:f     r10.8<1;1,0>:hf                  {F@2}
        mov (1|M0)               r46.14<2>:hf  r10.0<0;1,0>:f                  
        mov (8|M0)               r10.0<1>:hf   r6.0<1;1,0>:f                   
        mov (1|M0)               r46.7<1>:f    r46.14<0;1,0>:hf                 {F@2}
        mov (8|M0)               r6.0<1>:f     r11.0<1;1,0>:hf                 
        mov (8|M0)               r8.0<1>:f     r10.0<1;1,0>:hf                  {F@3}
        mul (16|M0)              r6.0<1>:f     r46.7<0;1,0>:f    r6.0<1;1,0>:f    {Compacted,F@2}
        mul (16|M0)              r8.0<1>:f     r46.7<0;1,0>:f    r8.0<1;1,0>:f    {Compacted,F@2}
        mov (8|M0)               r10.0<1>:hf   r6.0<1;1,0>:f                    {F@2}
        mov (8|M0)               r10.8<1>:hf   r7.0<1;1,0>:f                   
        sync.nop                             null                             {Compacted,$8.src}
        mov (8|M0)               r14.0<1>:hf   r8.0<1;1,0>:f                    {F@3}
        mov (8|M0)               r14.8<1>:hf   r9.0<1;1,0>:f                   
        mov (8|M0)               r12.0<1>:f    (abs)r10.0<1;1,0>:hf             {F@4}
        mov (8|M0)               r13.0<1>:f    (abs)r10.8<1;1,0>:hf             {F@4}
        mov (8|M0)               r11.0<1>:f    (abs)r14.8<1;1,0>:hf             {F@3}
        mov (8|M0)               r10.0<1>:f    (abs)r14.0<1;1,0>:hf            
        sel (16|M0)   (lt)f0.0   r12.0<1>:f    r12.0<1;1,0>:f    448.0:f               {Compacted,F@3}
        sel (16|M0)   (lt)f0.0   r10.0<1>:f    r10.0<1;1,0>:f    448.0:f               {Compacted,F@2}
        shr (16|M0)              r18.0<1>:ud   r12.0<1;1,0>:ud   0x17:uw              {F@2}
        shr (16|M0)              r16.0<1>:ud   r10.0<1;1,0>:ud   0x17:uw              {F@1}
        sel (16|M0)   (ge)f0.0   r14.0<2>:ub   r18.0<4;1,0>:ub   0x79:uw              {I@2}
        sel (16|M0)   (ge)f0.0   r15.0<2>:ub   r16.0<4;1,0>:ub   0x79:uw              {I@2}
        mov (16|M0)              r18.0<1>:d    r14.0<2;1,0>:ub                  {I@2}
        mov (16|M0)              r16.0<1>:d    r15.0<2;1,0>:ub                  {I@2}
        shl (16|M0)              r18.0<1>:d    r18.0<1;1,0>:d    23:w               {Compacted,I@2}
        shl (16|M0)              r16.0<1>:d    r16.0<1;1,0>:d    23:w               {Compacted,I@2}
        add (16|M0)              r20.0<1>:d    r18.0<1;1,0>:d    -25165824:d               {I@2}
        add (16|M0)              r14.0<1>:d    r16.0<1;1,0>:d    -25165824:d               {I@2}
        add (16|M0)              r18.0<1>:d    -r18.0<1;1,0>:d   -2139095040:d              
        add (16|M0)              r16.0<1>:d    -r16.0<1;1,0>:d   -2139095040:d              
        mul (16|M0)              acc0.0<1>:f   r12.0<1;1,0>:f    r18.0<1;1,0>:f   {Compacted,I@2}
        mul (16|M0)              acc2.0<1>:f   r10.0<1;1,0>:f    r16.0<1;1,0>:f   {Compacted,I@1}
        rnde (16|M0)             acc0.0<1>:f   acc0.0<1;1,0>:f                 
        rnde (16|M0)             acc2.0<1>:f   acc2.0<1;1,0>:f                 
        cmp (16|M0)   (lt)f1.0   null<1>:f     r6.0<1;1,0>:f     0xB3000000:f               {Compacted}
        cmp (16|M0)   (lt)f0.1   null<1>:f     r8.0<1;1,0>:f     0xB3000000:f              
        mul (16|M0)              acc0.0<1>:f   acc0.0<1;1,0>:f   r20.0<1;1,0>:f   {Compacted}
        mul (16|M0)              acc2.0<1>:f   acc2.0<1;1,0>:f   r14.0<1;1,0>:f   {Compacted}
        mov (16|M0)              r16.0<1>:f    (abs)acc0.0<1;1,0>:f             {Compacted}
        mov (16|M0)              r12.0<1>:f    (abs)acc2.0<1;1,0>:f             {Compacted}
(f1.0)  or (16|M0)               r16.0<1>:d    r16.0<1;1,0>:d    -2147483648:d               {F@2}
(f0.1)  or (16|M0)               r12.0<1>:d    r12.0<1;1,0>:d    -2147483648:d               {F@1}
        mov (8|M0)               r6.0<1>:hf    r16.0<1;1,0>:f                   {I@2}
        mov (8|M0)               r6.8<1>:hf    r17.0<1;1,0>:f                  
        mov (8|M0)               r7.0<1>:hf    r12.0<1;1,0>:f                   {I@1}
        mov (8|M0)               r7.8<1>:hf    r13.0<1;1,0>:f                  
        send.slm (1|M0)          null     r55     r6:1    0x0            0x0200B704           {A@3,$15} // wr:1+1, rd:0; store.slm.d64x4t.a32
        send.slm (1|M0)          null     r3      r7:1    0x0            0x0200B704           {A@1,$10} // wr:1+1, rd:0; store.slm.d64x4t.a32
        goto (16|M0)                         L6696                  L7456                
L6696:
        join (16|M0)                         L7456                                
L6712:
        sel (16|M0)   (lt)f0.0   r12.0<1>:f    (abs)r6.0<1;1,0>:f  448.0:f             {Compacted,$6.dst}
        sel (16|M0)   (lt)f0.0   r10.0<1>:f    (abs)r8.0<1;1,0>:f  448.0:f             {Compacted}
        shr (16|M0)              r18.0<1>:ud   r12.0<1;1,0>:ud   0x17:uw              {F@2}
        sync.nop                             null                             {Compacted,$8.src}
        shr (16|M0)              r16.0<1>:ud   r10.0<1;1,0>:ud   0x17:uw              {F@1}
        sel (16|M0)   (ge)f0.0   r14.0<2>:ub   r18.0<4;1,0>:ub   0x79:uw              {I@2}
        sel (16|M0)   (ge)f0.0   r15.0<2>:ub   r16.0<4;1,0>:ub   0x79:uw              {I@2}
        mov (16|M0)              r18.0<1>:d    r14.0<2;1,0>:ub                  {I@2}
        mov (16|M0)              r16.0<1>:d    r15.0<2;1,0>:ub                  {I@2}
        shl (16|M0)              r18.0<1>:d    r18.0<1;1,0>:d    23:w               {Compacted,I@2}
        shl (16|M0)              r16.0<1>:d    r16.0<1;1,0>:d    23:w               {Compacted,I@2}
        add (16|M0)              r20.0<1>:d    r18.0<1;1,0>:d    -25165824:d               {I@2}
        add (16|M0)              r14.0<1>:d    r16.0<1;1,0>:d    -25165824:d               {I@2}
        add (16|M0)              r18.0<1>:d    -r18.0<1;1,0>:d   -2139095040:d              
        add (16|M0)              r16.0<1>:d    -r16.0<1;1,0>:d   -2139095040:d              
        mul (16|M0)              acc0.0<1>:f   r12.0<1;1,0>:f    r18.0<1;1,0>:f   {Compacted,I@2}
        mul (16|M0)              acc2.0<1>:f   r10.0<1;1,0>:f    r16.0<1;1,0>:f   {Compacted,I@1}
        rnde (16|M0)             acc0.0<1>:f   acc0.0<1;1,0>:f                 
        rnde (16|M0)             acc2.0<1>:f   acc2.0<1;1,0>:f                 
        cmp (16|M0)   (lt)f1.1   null<1>:f     r6.0<1;1,0>:f     0.0:f              
        cmp (16|M0)   (lt)f1.0   null<1>:f     r8.0<1;1,0>:f     0.0:f               {Compacted}
        mul (16|M0)              acc0.0<1>:f   acc0.0<1;1,0>:f   r20.0<1;1,0>:f   {Compacted}
        mul (16|M0)              acc2.0<1>:f   acc2.0<1;1,0>:f   r14.0<1;1,0>:f   {Compacted}
        mov (16|M0)              r16.0<1>:f    (abs)acc0.0<1;1,0>:f             {Compacted}
        mov (16|M0)              r12.0<1>:f    (abs)acc2.0<1;1,0>:f             {Compacted}
(f1.1)  or (16|M0)               r16.0<1>:d    r16.0<1;1,0>:d    -2147483648:d               {F@2}
(f1.0)  or (16|M0)               r12.0<1>:d    r12.0<1;1,0>:d    -2147483648:d               {F@1}
        sync.nop                             null                             {Compacted,$15.src}
        mov (1|M0)               r6.1<1>:d     0:w                               {$13.src}
        sync.nop                             null                             {Compacted,$10.src}
        mov (8|M0)               r7.0<1>:hf    r16.0<1;1,0>:f                   {I@3}
        mov (8|M0)               r7.8<1>:hf    r17.0<1;1,0>:f                  
        mov (8|M0)               r8.0<1>:hf    r12.0<1;1,0>:f                   {I@2}
        mov (8|M0)               r8.8<1>:hf    r13.0<1;1,0>:f                  
L7144:
        sync.nop                             null                             {Compacted,$0.src}
        shr (1|M0)               r9.0<1>:ud    r6.1<0;1,0>:ud    0x4:uw              {I@1}
        shl (1|M0)               r6.0<1>:ud    r6.1<0;1,0>:ud    0x4:uw             
        bfn.0xEA (1|M0)          r9.0<1>:ud    r9.0<0;0>:ud      r46.2<0;0>:ud     0x1FFE:uw              {I@2} // s0|s1&s2
        and (1|M0)               r6.0<1>:ud    r6.0<0;1,0>:ud    0x80:uw              {I@2}
        shl (1|M0)               r9.0<1>:ud    r9.0<0;1,0>:ud    0x8:uw              {I@2}
        shl (1|M0)               r46.14<1>:w   r6.2<0;1,0>:w     1:w              
        bfn.0xFE (1|M0)          r9.0<1>:ud    r46.6<0;0>:ud     r9.0<0;0>:ud      r6.0<0>:ud       {I@2} // s0|s1|s2
        shl (1|M0)               r6.0<1>:ud    r6.1<0;1,0>:ud    0x1:uw             
        add (1|M0)               r6.1<1>:ud    r6.1<0;1,0>:ud    0x1:uw             
        and (1|M0)               r6.0<1>:ud    r6.0<0;1,0>:ud    0xE:uw              {I@2}
        cmp (1|M0)    (eq)f0.1   null<1>:d     r6.1<0;1,0>:d     32:w               {I@2}
        add (1|M0)               a0.0<1>:uw    r46.14<0;1,0>:uw  0xE0:uw              {A@1}
        bfn.0xFE (1|M0)          r9.0<1>:ud    r46.5<0;0>:ud     r9.0<0;0>:ud      r6.0<0>:ud       {I@3} // s0|s1|s2
        shl (1|M0)               r9.0<1>:ud    r9.0<0;1,0>:ud    0x1:uw              {I@1}
(W)     and (1|M0)               f0.1<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
        mov (1|M0)               r6.0<1>:d     r[a0.0]<0;1,0>:uw                {A@1}
        add (1|M0)               r9.0<1>:ud    r9.0<0;1,0>:ud    0x9000:uw              {A@1}
        send.slm (1|M0)          null     r9      r6:1    0x0            0x02000B04           {A@1,$0} // wr:1+1, rd:0; store.slm.d16u32.a32
(~f0.1.any16h) goto.b (16|M0)                L7456                  L7144                
L7456:
        join (16|M0)                         L7640                                
L7472:
        sync.allrd                           ($0,$13,$15)                
(W)     send.slm (1|M0)          r6       r0      null:0  0x0            0x0210001F           {$6} // wr:1+0, rd:1; fence.slm.none.group
(W)     mov (8|M0)               null<1>:ud    r6.0<1;1,0>:ud                   {$6.dst}
(W)     mov (1|M0)               r6.2<1>:f     0.0:f                               {Compacted,I@1}
(W)     mov (2|M0)               r6.10<1>:ub   r0.11<0;1,0>:ub                  {F@1}
(W)     send.gtwy (1|M0)         null     r6      null:0  0x0            0x02000004           {A@1,$11} // wr:1+0, rd:0; signal barrier
(W)     sync.bar                             null                            
        add (1|M0)               r46.4<1>:d    r46.4<0;1,0>:d    1:w              
        cmp (1|M0)    (eq)f1.1   null<1>:d     r46.4<0;1,0>:d    3:w               {I@1}
(W)     and (1|M0)               f1.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(~f1.1.any16h) goto.b (16|M0)                L7640                  L4264                
L7640:
        join (16|M0)                         L27064                                
L7656:
        cmp (1|M0)    (lt)f1.0   null<1>:d     r2.4<0;1,0>:d     10:w              
(W)     and (1|M0)               f1.0<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
(f1.0.any16h) goto (16|M0)                   L8576                  L8576                
L7704:
        cmp (1|M0)    (lt)f0.1   null<1>:d     r2.4<0;1,0>:d     13:w              
(W)     and (1|M0)               f0.1<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(~f0.1.any16h) goto (16|M0)                  L8576                  L8640                
L7752:
        cmp (1|M0)    (eq)f1.1   null<1>:d     r2.4<0;1,0>:d     11:w              
        cmp (1|M0)    (eq)f0.0   null<1>:d     r2.4<0;1,0>:d     10:w              
(W)     mov (1|M0)               r2.0<1>:hf    -0.0:hf                             
(f1.1)  sel (1|M0)               r2.1<1>:d     r2.0<0;1,0>:uw    0x9000:uw              {F@1}
(f0.0)  mov (1|M0)               r2.1<1>:d     28672:w                              
        cmp (1|M0)    (eq)f0.0   null<1>:d     r3.5<0;1,0>:d     0:w              
(f0.0)  cmp (1|M0)    (eq)f0.0   null<1>:d     r3.4<0;1,0>:d     0:w              
(W)     and (1|M0)               f0.0<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
(f0.0.any16h) goto (16|M0)                   L8576                  L28784                
L7896:
        shl (1|M0)               r2.4<1>:d     r1.7<0;1,0>:d     12:w              
        shr (1|M0)               r2.0<1>:ud    r1.6<0;1,0>:ud    0x14:uw             
        shl (1|M0)               r2.2<1>:d     r1.6<0;1,0>:d     12:w              
        or (1|M0)                r2.3<1>:d     r2.4<0;1,0>:d     r2.0<0;1,0>:d    {I@2}
        shr (1|M0)               r1.0<1>:ud    r2.2<0;1,0>:ud    0x1F:uw              {I@2}
        shl (1|M0)               r1.1<1>:d     r2.2<0;1,0>:d     1:w              
        shl (1|M0)               r1.3<1>:d     r2.3<0;1,0>:d     1:w               {Compacted,I@3}
        mov (1|M0)               r1.5<2>:f     0.0:f                              
        or (1|M0)                r1.2<1>:d     r1.3<0;1,0>:d     r1.0<0;1,0>:d    {I@1}
        addc (1|M0)              r1.0<1>:ud    r3.4<0;1,0>:ud    r1.1<0;1,0>:ud   {AccWrEn}
        shl (1|M0)               r1.3<1>:d     r5.6<0;1,0>:d     1:w              
        mov (1|M0)               r3.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$10.src}
        shr (1|M0)               r1.1<1>:ud    r5.6<0;1,0>:ud    0x1F:uw             
        addc (1|M0)              r2.0<1>:ud    r1.0<0;1,0>:ud    r1.3<0;1,0>:ud   {AccWrEn,I@3}
        add3 (1|M0)              r1.6<1>:d     r3.0<0;0>:d       r3.5<0;0>:d       r1.2<0>:d        {I@3}
        shl (1|M0)               r1.2<1>:d     r5.7<0;1,0>:d     1:w              
        mov (1|M0)               r1.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        or (1|M0)                r1.4<1>:d     r1.2<0;1,0>:d     r1.1<0;1,0>:d    {I@2}
        mov (1|M0)               r1.1<1>:d     r2.0<0;1,0>:d                   
        add3 (1|M0)              r1.2<1>:d     r1.0<0;0>:d       r1.6<0;0>:d       r1.4<0>:d        {I@2}
        mov (1|M0)               r1.4<2>:f     0.0:f                               {I@1}
L8208:
        addc (1|M0)              r2.0<1>:ud    r1.4<0;1,0>:ud    r5.6<0;1,0>:ud   {AccWrEn,F@1}
        shl (1|M0)               r1.6<1>:d     r1.4<0;1,0>:d     1:w              
        mov (1|M0)               r1.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        cmp (1|M0)    (lt)f1.1   null<1>:ud    r1.4<0;1,0>:ud    0x7C0:uw             
        add3 (1|M0)              r1.7<1>:d     r1.0<0;0>:d       r1.5<0;0>:d       r5.7<0>:d        {I@2}
        shl (1|M0)               r1.0<1>:d     r2.0<0;1,0>:d     1:w               {Compacted}
        shl (1|M0)               r2.2<1>:d     r1.5<0;1,0>:d     1:w              
        add (1|M0)               r1.0<1>:d     r1.0<0;1,0>:d     r2.1<0;1,0>:d    {Compacted,I@2}
        addc (1|M0)              r4.0<1>:ud    r1.1<0;1,0>:ud    r1.6<0;1,0>:ud   {AccWrEn}
        send.slm (1|M0)          r3       r1      null:0  0x0            0x0210B700           {A@2,$1} // wr:1+0, rd:1; load.slm.d64x4t.a32
        shr (1|M0)               r2.0<1>:ud    r1.4<0;1,0>:ud    0x1F:uw             
(f1.1)  cmp (1|M0)    (eq)f1.1   null<1>:d     r1.5<0;1,0>:d     0:w              
        sync.nop                             null                             {Compacted,$1.src}
        or (1|M0)                r1.7<1>:d     r2.2<0;1,0>:d     r2.0<0;1,0>:d    {I@2}
        mov (1|M0)               r2.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        add3 (1|M0)              r4.1<1>:d     r2.0<0;0>:d       r1.2<0;0>:d       r1.7<0>:d        {I@1}
        mov (1|M0)               r2.0<1>:d     r3.0<0;1,0>:uw                   {$1.dst}
(W)     and (1|M0)               f1.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
        send.ugm (1|M0)          null     r4      r2:1    0x0            0x04000B84           {A@2,$2} // wr:2+1, rd:0; store.ugm.d16u32.a64
        addc (1|M0)              r2.0<1>:ud    r1.4<0;1,0>:ud    0x40:ud              {AccWrEn,$2.src}
        mov (1|M0)               r1.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r1.6<1>:d     r2.0<0;1,0>:d                    {I@2}
        add3 (1|M0)              r1.7<1>:d     r1.0<0;0>:d       r1.5<0;0>:d       0:w               {I@2}
(~f1.1.any16h) goto (16|M0)                  L8576                  L28784                
L8544:
(W)     mov (2|M0)               r1.4<1>:ud    r1.6<1;1,0>:ud                   {I@2}
        goto.b (16|M0)                       L8576                  L8208                
L8576:
        join (16|M0)                         L8640                                
L8592:
        cmp (1|M0)    (eq)f1.1   null<1>:d     r2.4<0;1,0>:d     3:w              
(W)     and (1|M0)               f1.0<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(f1.0.any16h) goto (16|M0)                   L8640                  L26128                
L8640:
        join (16|M0)                         L26128                                
L8656:
        cmp (1|M0)    (lt)f1.0   null<1>:uw    r1.0<0;1,0>:uw    0x100:uw             
(W)     and (1|M0)               f0.1<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
(~f0.1.any16h) goto (16|M0)                  L10288                  L10288                
L8704:
        sync.nop                             null                             {Compacted,$10.src}
        and (1|M0)               r3.6<1>:ud    r1.4<0;1,0>:ud    0x3:uw              {I@7}
        sync.allrd                           ($0,$11,$13,$15)                
        mov (16|M0)              r6.0<1>:f     0.0:f                               {Compacted,$6.dst}
        shl (1|M0)               r3.7<1>:ud    r3.6<0;1,0>:ud    0x9:uw              {I@1}
        mov (16|M0)              r8.0<1>:f     0.0:f                               {Compacted}
        mov (16|M0)              r10.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r12.0<1>:f    0.0:f                               {Compacted}
        shl (1|M0)               r3.6<1>:ud    r3.6<0;1,0>:ud    0x6:uw             
        or (1|M0)                r82.0<1>:ud   r3.7<0;1,0>:ud    0x8000:uw              {I@2}
        or (1|M0)                r81.0<1>:ud   r3.7<0;1,0>:ud    0x8100:uw             
        or (1|M0)                r80.0<1>:ud   r3.7<0;1,0>:ud    0x8800:uw             
        or (1|M0)                r83.0<1>:ud   r3.7<0;1,0>:ud    0x8900:uw             
        mov (1|M0)               r3.7<1>:d     r1.4<0;1,0>:d                   
L8888:
        shl (1|M0)               r46.2<1>:d    r3.7<0;1,0>:d     8:w               {I@1}
        send.slm (1|M0)          r56      r82     null:0  0x0            0x0280E700           {$12} // wr:1+0, rd:8; load.slm.d64x32t.a32
        and (1|M0)               r46.2<1>:d    r46.2<0;1,0>:d    3072:w               {I@1}
        send.slm (1|M0)          r47      r81     null:0  0x0            0x0280E700           {$14} // wr:1+0, rd:8; load.slm.d64x32t.a32
        sync.allrd                           ($4,$8)                
        or (1|M0)                r14.0<1>:d    r46.2<0;1,0>:d    28672:w               {I@1}
        or (1|M0)                r64.0<1>:d    r46.2<0;1,0>:d    29440:w              
        send.slm (1|M0)          r22      r14     null:0  0x0            0x0280E700           {A@2,$1} // wr:1+0, rd:8; load.slm.d64x32t.a32
        or (1|M0)                r14.0<1>:d    r46.2<0;1,0>:d    28928:w               {$1.src}
        send.slm (1|M0)          r72      r80     null:0  0x0            0x0280E700           {$7} // wr:1+0, rd:8; load.slm.d64x32t.a32
        send.slm (1|M0)          r38      r14     null:0  0x0            0x0280E700           {A@1,$9} // wr:1+0, rd:8; load.slm.d64x32t.a32
        cmp (1|M0)    (lt)f0.1   null<1>:ud    r3.7<0;1,0>:ud    0xC:uw             
        sync.nop                             null                             {Compacted,A@1}
        sync.allwr                           ($1,$12,$14)                
        sync.nop                             null                             {Compacted,$9.src}
        dpas.8x8 (8|M0)          r14:f         null:f            r14:hf            r14.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r14:f         r6:f              r56:hf            r22.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r30:f         r6:f              r47:hf            r22.0:hf         {$12}
(W)     and (1|M0)               f1.1<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
        dpas.8x8 (8|M0)          r22:f         r6:f              r56:hf            r38.0:hf         {$9}
        sync.nop                             null                             {Compacted,$9.src}
        or (1|M0)                r56.0<1>:d    r46.2<0;1,0>:d    29184:w               {$12.src}
        dpas.8x8 (8|M0)          r38:f         r6:f              r47:hf            r38.0:hf         {$8}
        sync.nop                             null                             {Compacted,$8.src}
        send.slm (1|M0)          r47      r56     null:0  0x0            0x0280E700           {A@1,$5} // wr:1+0, rd:8; load.slm.d64x32t.a32
        send.slm (1|M0)          r56      r64     null:0  0x0            0x0280E700           {$13} // wr:1+0, rd:8; load.slm.d64x32t.a32
        send.slm (1|M0)          r64      r83     null:0  0x0            0x0280E700           {$15} // wr:1+0, rd:8; load.slm.d64x32t.a32
        shl (1|M0)               r46.2<1>:d    r3.7<0;1,0>:d     10:w              
        and (1|M0)               r46.2<1>:d    r46.2<0;1,0>:d    12288:w               {I@1}
        sync.allwr                           ($5,$7,$8,$9,$12,$13,$15)                
(W)     sync.nop                             null                            
        dpas.8x8 (8|M0)          r14:f         null:f            r14:hf            r14.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r14:f         r14:f             r72:hf            r47.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r22:f         r22:f             r72:hf            r56.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r30:f         r30:f             r64:hf            r47.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r38:f         r38:f             r64:hf            r56.0:hf         {$7}
        add (1|M0)               r46.2<1>:d    r46.2<0;1,0>:d    0xA000:uw              {I@1}
        sync.nop                             null                             {Compacted,$7.src}
        or (1|M0)                r50.0<1>:d    r46.2<0;1,0>:d    r3.6<0;1,0>:d    {I@1}
        add (1|M0)               r46.2<1>:d    r3.7<0;1,0>:d     4:w              
        mov (8|M0)               r51.0<1>:f    r14.0<1;1,0>:f                   {Compacted,$7.dst}
        or (1|M0)                r47.0<1>:ud   r50.0<0;1,0>:ud   0x800:uw              {I@2}
        mov (8|M0)               r48.0<1>:f    r22.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r52.0<1>:f    r30.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r49.0<1>:f    r38.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r50     r51:2   0x0            0x0200C704           {A@2,$2} // wr:1+2, rd:0; store.slm.d64x8t.a32
        send.slm (1|M0)          null     r47     r48:2   0x0            0x0200C704           {A@1,$12} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r51.0<1>:f    r15.0<1;1,0>:f                   {Compacted,$2.src}
        mov (8|M0)               r52.0<1>:f    r31.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r47.0<1>:ud   r50.0<0;1,0>:ud   0x100:uw              {$12.src}
        mov (8|M0)               r48.0<1>:f    r23.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r47     r51:2   0x0            0x0200C704           {A@1,$14} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r49.0<1>:f    r39.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r47.0<1>:ud   r50.0<0;1,0>:ud   0x900:uw              {$14.src}
        mov (8|M0)               r51.0<1>:f    r16.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r47     r48:2   0x0            0x0200C704           {A@1,$1} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r52.0<1>:f    r32.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r47.0<1>:ud   r50.0<0;1,0>:ud   0x200:uw              {$1.src}
        mov (8|M0)               r48.0<1>:f    r24.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r47     r51:2   0x0            0x0200C704           {A@1,$10} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r49.0<1>:f    r40.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r47.0<1>:ud   r50.0<0;1,0>:ud   0xA00:uw              {$10.src}
        mov (8|M0)               r51.0<1>:f    r17.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r47     r48:2   0x0            0x0200C704           {A@1,$0} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r52.0<1>:f    r33.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r47.0<1>:ud   r50.0<0;1,0>:ud   0x300:uw              {$0.src}
        mov (8|M0)               r48.0<1>:f    r25.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r47     r51:2   0x0            0x0200C704           {A@1,$6} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r49.0<1>:f    r41.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r47.0<1>:ud   r50.0<0;1,0>:ud   0xB00:uw              {$6.src}
        mov (8|M0)               r51.0<1>:f    r18.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r47     r48:2   0x0            0x0200C704           {A@1,$2} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r52.0<1>:f    r34.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r47.0<1>:ud   r50.0<0;1,0>:ud   0x400:uw              {$2.src}
        mov (8|M0)               r48.0<1>:f    r26.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r47     r51:2   0x0            0x0200C704           {A@1,$12} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r49.0<1>:f    r42.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r47.0<1>:ud   r50.0<0;1,0>:ud   0xC00:uw              {$12.src}
        mov (8|M0)               r51.0<1>:f    r19.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r47     r48:2   0x0            0x0200C704           {A@1,$14} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r52.0<1>:f    r35.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r47.0<1>:ud   r50.0<0;1,0>:ud   0x500:uw              {$14.src}
        mov (8|M0)               r48.0<1>:f    r27.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r47     r51:2   0x0            0x0200C704           {A@1,$1} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r49.0<1>:f    r43.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r47.0<1>:ud   r50.0<0;1,0>:ud   0xD00:uw              {$1.src}
        mov (8|M0)               r51.0<1>:f    r20.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r47     r48:2   0x0            0x0200C704           {A@1,$11} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r52.0<1>:f    r36.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r47.0<1>:ud   r50.0<0;1,0>:ud   0x600:uw              {$11.src}
        or (1|M0)                r14.0<1>:ud   r50.0<0;1,0>:ud   0x700:uw             
        send.slm (1|M0)          null     r47     r51:2   0x0            0x0200C704           {A@1,$9} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r15.0<1>:f    r21.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r16.0<1>:f    r37.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r48.0<1>:f    r28.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r49.0<1>:f    r44.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r47.0<1>:ud   r50.0<0;1,0>:ud   0xE00:uw              {$9.src}
        mov (8|M0)               r17.0<1>:f    r29.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r47     r48:2   0x0            0x0200C704           {A@1,$3} // wr:1+2, rd:0; store.slm.d64x8t.a32
        send.slm (1|M0)          null     r14     r15:2   0x0            0x0200C704           {$2} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r18.0<1>:f    r45.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r14.0<1>:ud   r50.0<0;1,0>:ud   0xF00:uw              {$2.src}
        send.slm (1|M0)          null     r14     r17:2   0x0            0x0200C704           {A@1,$4} // wr:1+2, rd:0; store.slm.d64x8t.a32
(~f1.1.any16h) goto (16|M0)                  L10288                  L10288                
L10256:
        mov (1|M0)               r3.7<1>:d     r46.2<0;1,0>:d                  
        goto.b (16|M0)                       L10288                  L8888                
L10288:
        join (16|M0)                         L26128                                
L10304:
        sync.nop                             null                             {Compacted,$6.dst}
        sync.allrd                           ($0,$11,$13,$15)                
(W)     send.slm (1|M0)          r6       r0      null:0  0x0            0x0210001F           {$12} // wr:1+0, rd:1; fence.slm.none.group
(W)     mov (8|M0)               null<1>:ud    r6.0<1;1,0>:ud                   {$12.dst}
(W)     mov (1|M0)               r6.2<1>:f     0.0:f                               {Compacted,I@1}
(W)     mov (2|M0)               r6.10<1>:ub   r0.11<0;1,0>:ub                  {F@1}
(W)     send.gtwy (1|M0)         null     r6      null:0  0x0            0x02000004           {A@1,$14} // wr:1+0, rd:0; signal barrier
(W)     sync.bar                             null                            
        cmp (1|M0)    (eq)f1.1   null<1>:d     r2.4<0;1,0>:d     5:w              
(W)     and (1|M0)               f1.0<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(f1.0.any16h) goto (16|M0)                   L25352                  L25352                
L10464:
        shl (1|M0)               r3.7<1>:ud    r1.5<0;1,0>:ud    0x8:uw              {$10.src}
        shl (1|M0)               r46.3<1>:d    r5.7<0;1,0>:d     6:w              
        shr (1|M0)               r46.2<1>:ud   r5.6<0;1,0>:ud    0x1A:uw             
        shl (1|M0)               r5.6<1>:d     r5.6<0;1,0>:d     6:w              
        sync.nop                             null                             {Compacted,$14.src}
        add (1|M0)               r6.0<1>:ud    r3.7<0;1,0>:ud    0xA000:uw              {I@4}
        sync.nop                             null                             {Compacted,$4.src}
        add (1|M0)               r14.0<1>:ud   r3.7<0;1,0>:ud    0xA080:uw              {$8.src}
        or (1|M0)                r5.7<1>:d     r46.3<0;1,0>:d    r46.2<0;1,0>:d   {I@4}
        shr (1|M0)               r46.2<1>:ud   r5.6<0;1,0>:ud    0x1E:uw              {I@4}
        shl (1|M0)               r5.6<1>:d     r5.6<0;1,0>:d     2:w              
        send.slm (1|M0)          r10      r6      null:0  0x0            0x0240D700           {A@5,$1} // wr:1+0, rd:4; load.slm.d64x16t.a32
        send.slm (1|M0)          r6       r14     null:0  0x0            0x0240D700           {A@4,$2} // wr:1+0, rd:4; load.slm.d64x16t.a32
        shl (1|M0)               r46.3<1>:d    r5.7<0;1,0>:d     2:w               {I@3}
        sync.nop                             null                             {Compacted,$2.src}
        addc (1|M0)              r14.0<1>:ud   r4.2<0;1,0>:ud    r5.6<0;1,0>:ud   {AccWrEn,I@2}
        or (1|M0)                r5.7<1>:d     r46.3<0;1,0>:d    r46.2<0;1,0>:d   {I@2}
        mov (1|M0)               r15.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        add3 (1|M0)              r14.1<1>:d    r15.0<0;0>:d      r4.3<0;0>:d       r5.7<0>:d        {I@1}
        addc (1|M0)              r16.0<1>:ud   r14.0<0;1,0>:ud   0x80:ud              {AccWrEn}
        send.ugm (1|M0)          r18      r14     null:0  0x0            0x0240E580           {A@2,$12} // wr:1+0, rd:4; load.ugm.d32x32t.a64
        mov (1|M0)               r15.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r22.0<1>:d    r16.0<0;1,0>:d                   {I@2}
        add3 (1|M0)              r22.1<1>:d    r15.0<0;0>:d      r14.1<0;0>:d      0:w               {I@2}
        mov (1|M0)               r5.6<1>:ud    0x3FA68000:ud                             
        send.ugm (1|M0)          r14      r22     null:0  0x0            0x0240E580           {A@2,$8} // wr:1+0, rd:4; load.ugm.d32x32t.a64
        mov (1|M0)               r5.7<1>:ud    0x3D380000:ud                             
        add (1|M0)               r56.0<1>:ud   r3.7<0;1,0>:ud    0x1000:uw             
        add (1|M0)               r4.0<1>:ud    r3.7<0;1,0>:ud    0x1080:uw             
        shl (1|M0)               r3.6<1>:ud    r1.5<0;1,0>:ud    0x6:uw             
        sync.nop                             null                             {Compacted,$12.dst}
        add (16|M0)              r24.0<1>:f    r18.0<1;1,0>:f    r10.0<1;1,0>:f   {Compacted,$1.dst}
        add (16|M0)              r22.0<1>:f    r20.0<1;1,0>:f    r12.0<1;1,0>:f   {Compacted,$8.src}
        mov (8|M0)               r10.0<1>:hf   r24.0<1;1,0>:f                   {F@2}
        mov (8|M0)               r10.8<1>:hf   r25.0<1;1,0>:f                  
        mov (8|M0)               r18.0<1>:hf   r22.0<1;1,0>:f                   {F@3}
        mov (8|M0)               r18.8<1>:hf   r23.0<1;1,0>:f                  
        mov (8|M0)               r12.0<1>:f    r10.0<1;1,0>:hf                  {F@4}
        mov (8|M0)               r13.0<1>:f    r10.8<1;1,0>:hf                  {F@4}
        sync.nop                             null                             {Compacted,$8.dst}
        add (16|M0)              r20.0<1>:f    r14.0<1;1,0>:f    r6.0<1;1,0>:f    {Compacted,$2.dst}
        mov (8|M0)               r11.0<1>:f    r18.8<1;1,0>:hf                  {F@4}
        mov (8|M0)               r10.0<1>:f    r18.0<1;1,0>:hf                 
        mad (16|M0)              r12.0<1>:f    r5.6<0;0>:f       r12.0<1;0>:f      r5.7<0>:f        {A@4}
        add (16|M0)              r18.0<1>:f    r16.0<1;1,0>:f    r8.0<1;1,0>:f    {Compacted}
        mov (8|M0)               r6.0<1>:hf    r20.0<1;1,0>:f                   {F@5}
        mov (8|M0)               r6.8<1>:hf    r21.0<1;1,0>:f                  
        mad (16|M0)              r10.0<1>:f    r5.6<0;0>:f       r10.0<1;0>:f      r5.7<0>:f        {F@5}
        mov (8|M0)               r14.0<1>:hf   r18.0<1;1,0>:f                   {F@4}
        mov (8|M0)               r14.8<1>:hf   r19.0<1;1,0>:f                  
        mov (8|M0)               r16.0<1>:hf   r12.0<1;1,0>:f                  
        mov (8|M0)               r16.8<1>:hf   r13.0<1;1,0>:f                  
        mov (8|M0)               r8.0<1>:f     r6.0<1;1,0>:hf                   {F@7}
        mov (8|M0)               r9.0<1>:f     r6.8<1;1,0>:hf                   {F@7}
        mov (8|M0)               r15.0<1>:hf   r10.0<1;1,0>:f                   {F@7}
        mov (8|M0)               r15.8<1>:hf   r11.0<1;1,0>:f                  
        mov (8|M0)               r7.0<1>:f     r14.8<1;1,0>:hf                  {F@7}
        mov (8|M0)               r13.0<1>:f    r16.0<1;1,0>:hf                  {F@7}
        mov (8|M0)               r6.0<1>:f     r14.0<1;1,0>:hf                 
        mov (8|M0)               r14.0<1>:f    r16.8<1;1,0>:hf                  {F@7}
        mov (8|M0)               r11.0<1>:f    r15.0<1;1,0>:hf                  {F@6}
        mov (8|M0)               r12.0<1>:f    r15.8<1;1,0>:hf                  {F@6}
        sel (16|M0)   (ge)f0.0   acc0.0<1>:f   r13.0<1;1,0>:f    1.03125:f               {F@3}
        mad (16|M0)              r6.0<1>:f     r5.6<0;0>:f       r6.0<1;0>:f       r5.7<0>:f       
        sel (16|M0)   (ge)f0.0   acc2.0<1>:f   r11.0<1;1,0>:f    1.03125:f               {F@3}
        sel (16|M0)   (lt)f0.0   r13.0<1>:f    acc0.0<1;1,0>:f   0x3FC8E000:f              
        mov (8|M0)               r15.0<1>:hf   r6.0<1;1,0>:f                    {F@3}
        sel (16|M0)   (lt)f0.0   r11.0<1>:f    acc2.0<1;1,0>:f   0x3FC8E000:f              
        mov (8|M0)               r6.0<1>:ud    r13.0<2;1,0>:ud                  {A@2}
        mad (16|M0)              r8.0<1>:f     r5.6<0;0>:f       r8.0<1;0>:f       r5.7<0>:f       
        mov (8|M0)               r15.8<1>:hf   r7.0<1;1,0>:f                   
        mov (8|M0)               r7.0<1>:f     r15.0<1;1,0>:hf                 
        mov (8|M0)               r15.0<1>:hf   r6.0<1;1,0>:f                    {I@1}
        mov (8|M0)               r6.0<1>:ud    r11.0<2;1,0>:ud                  {A@1}
        mov (8|M0)               r16.0<1>:hf   r8.0<1;1,0>:f                   
        mov (8|M0)               r16.8<1>:hf   r9.0<1;1,0>:f                   
        mov (8|M0)               r6.0<2>:hf    r6.0<1;1,0>:f                    {I@1}
        mov (8|M0)               r8.0<1>:f     r15.8<1;1,0>:hf                 
        mov (8|M0)               r9.0<1>:f     r16.0<1;1,0>:hf                  {F@4}
        mov (8|M0)               r10.0<1>:f    r16.8<1;1,0>:hf                  {F@4}
        mov (8|M0)               r15.8<1>:uw   r6.0<2;1,0>:uw                   {A@3}
        mov (8|M0)               r6.0<1>:ud    r13.1<2;1,0>:ud                 
        sel (16|M0)   (ge)f0.0   acc0.0<1>:f   r9.0<1;1,0>:f     1.03125:f               {F@1}
        mov (8|M0)               r13.0<1>:hf   r6.0<1;1,0>:f                    {I@1}
        mov (8|M0)               r6.0<1>:ud    r11.1<2;1,0>:ud                  {F@1}
        sel (16|M0)   (ge)f0.0   acc2.0<1>:f   r7.0<1;1,0>:f     1.03125:f              
        sel (16|M0)   (lt)f0.0   r9.0<1>:f     acc0.0<1;1,0>:f   0x3FC8E000:f              
        mov (8|M0)               r6.0<2>:hf    r6.0<1;1,0>:f                    {I@1}
        sel (16|M0)   (lt)f0.0   r7.0<1>:f     acc2.0<1;1,0>:f   0x3FC8E000:f              
        mov (8|M0)               r13.8<1>:uw   r6.0<2;1,0>:uw                   {F@2}
        mov (8|M0)               r6.0<1>:ud    r9.0<2;1,0>:ud                  
        mov (8|M0)               r12.0<1>:hf   r6.0<1;1,0>:f                    {I@1}
        mov (8|M0)               r6.0<1>:ud    r7.0<2;1,0>:ud                   {A@1}
        mov (8|M0)               r6.0<2>:hf    r6.0<1;1,0>:f                    {I@1}
        mov (8|M0)               r12.8<1>:uw   r6.0<2;1,0>:uw                   {F@1}
        mov (8|M0)               r6.0<1>:ud    r9.1<2;1,0>:ud                  
        mov (16|M0)              r10.0<1>:d    r13.0<1;1,0>:uw                 
        mov (8|M0)               r14.0<1>:hf   r6.0<1;1,0>:f                    {I@2}
        mov (8|M0)               r6.0<1>:ud    r7.1<2;1,0>:ud                   {F@1}
        shl (16|M0)              r10.0<1>:d    r10.0<1;1,0>:d    21:w               {Compacted,I@2}
        mov (8|M0)               r6.0<2>:hf    r6.0<1;1,0>:f                    {I@2}
        mov (8|M0)               r14.8<1>:uw   r6.0<2;1,0>:uw                   {F@1}
        shl (16|M0)              r6.0<1>:d     r15.0<1;1,0>:uw   5:w              
        mov (16|M0)              r8.0<1>:d     r14.0<1;1,0>:uw                  {I@2}
        shl (16|M0)              r14.0<1>:d    r12.0<1;1,0>:uw   5:w              
        add (16|M0)              r6.0<1>:d     r6.0<1;1,0>:d     2146992128:d               {I@3}
        shl (16|M0)              r8.0<1>:d     r8.0<1;1,0>:d     21:w               {Compacted,I@3}
        add (16|M0)              r14.0<1>:d    r14.0<1;1,0>:d    2146992128:d               {I@3}
        add (16|M0)              r6.0<1>:d     r6.0<1;1,0>:d     r10.0<1;1,0>:d   {Compacted,I@3}
        add (16|M0)              r14.0<1>:d    r14.0<1;1,0>:d    r8.0<1;1,0>:d    {Compacted,I@2}
        mov (8|M0)               r10.0<1>:f    r6.0<1;1,0>:hf                   {I@2}
        mov (8|M0)               r11.0<1>:f    r6.8<1;1,0>:hf                  
        mov (8|M0)               r12.0<1>:f    r7.0<1;1,0>:hf                  
        mov (8|M0)               r13.0<1>:f    r7.8<1;1,0>:hf                  
        mov (8|M0)               r8.0<1>:f     r15.0<1;1,0>:hf                  {I@1}
        mov (8|M0)               r9.0<1>:f     r15.8<1;1,0>:hf                 
        mov (8|M0)               r6.0<1>:f     r14.0<1;1,0>:hf                 
        mov (8|M0)               r7.0<1>:f     r14.8<1;1,0>:hf                 
        send.slm (1|M0)          null     r56     r10:4   0x0            0x0200D704           {A@5,$1} // wr:1+4, rd:0; store.slm.d64x16t.a32
        send.slm (1|M0)          null     r4      r6:4    0x0            0x0200D704           {A@1,$2} // wr:1+4, rd:0; store.slm.d64x16t.a32
(W)     send.slm (1|M0)          r14      r0      null:0  0x0            0x0210001F           {$12} // wr:1+0, rd:1; fence.slm.none.group
(W)     mov (8|M0)               null<1>:ud    r14.0<1;1,0>:ud                  {$12.dst}
(W)     mov (1|M0)               r14.2<1>:ud   0x0:ud                             
(W)     mov (2|M0)               r14.10<1>:ub  r0.11<0;1,0>:ub                 
(W)     send.gtwy (1|M0)         null     r14     null:0  0x0            0x02000004           {A@1,$12} // wr:1+0, rd:0; signal barrier
(W)     sync.bar                             null                            
        mov (1|M0)               r3.7<1>:ud    0x0:ud                             
        mov (1|M0)               r5.6<1>:d     0:w                              
L12392:
        or (1|M0)                r5.7<1>:ud    r5.6<0;1,0>:ud    r3.6<0;1,0>:ud   {I@1}
        add (1|M0)               r5.6<1>:ud    r5.6<0;1,0>:ud    0x1:uw             
        shl (1|M0)               r5.7<1>:ud    r5.7<0;1,0>:ud    0x2:uw              {I@2}
        cmp (1|M0)    (eq)f1.0   null<1>:d     r5.6<0;1,0>:d     64:w               {I@2}
        sync.nop                             null                             {Compacted,$12.src}
        add (1|M0)               r14.0<1>:ud   r5.7<0;1,0>:ud    0x1000:uw              {I@2}
        send.slm (1|M0)          r14      r14     null:0  0x0            0x02100500           {A@1,$5} // wr:1+0, rd:1; load.slm.d32.a32
(W)     and (1|M0)               f0.1<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
        add (1|M0)               r3.7<1>:f     r3.7<0;1,0>:f     r14.0<0;1,0>:f   {$5.dst}
(~f0.1.any16h) goto.b (16|M0)                L12544                  L12392                
L12544:
        join (16|M0)                         L25352                                
L12560:
        sync.nop                             null                             {Compacted,F@1}
(W)     send.slm (1|M0)          r14      r0      null:0  0x0            0x0210001F           {$13} // wr:1+0, rd:1; fence.slm.none.group
(W)     mov (8|M0)               null<1>:ud    r14.0<1;1,0>:ud                  {$13.dst}
(W)     mov (1|M0)               r14.2<1>:ud   0x0:ud                             
(W)     mov (2|M0)               r14.10<1>:ub  r0.11<0;1,0>:ub                 
(W)     send.gtwy (1|M0)         null     r14     null:0  0x0            0x02000004           {A@1,$15} // wr:1+0, rd:0; signal barrier
(W)     sync.bar                             null                            
        mov (1|M0)               r3.14<2>:hf   r3.7<0;1,0>:f                   
        sync.nop                             null                             {Compacted,$15.src}
        math.inv (8|M0)          r14.0<1>:hf   r3.14<0;1,0>:hf                  {@1,$7}
        mov (1|M0)               r3.14<1>:hf   r14.0<0;1,0>:hf                  {$7.dst}
        mov (1|M0)               r3.7<1>:f     r3.14<0;1,0>:hf                  {F@1}
        mul (16|M0)              r16.0<1>:f    r3.7<0;1,0>:f     r10.0<1;1,0>:f   {Compacted,F@1}
        mul (16|M0)              r14.0<1>:f    r3.7<0;1,0>:f     r12.0<1;1,0>:f   {Compacted}
        sync.nop                             null                             {Compacted,$1.src}
        mov (8|M0)               r10.0<1>:hf   r16.0<1;1,0>:f                   {F@2}
        mov (8|M0)               r10.8<1>:hf   r17.0<1;1,0>:f                  
        mov (8|M0)               r18.0<1>:hf   r14.0<1;1,0>:f                   {F@3}
        mov (8|M0)               r18.8<1>:hf   r15.0<1;1,0>:f                  
        mov (8|M0)               r12.0<1>:f    (abs)r10.0<1;1,0>:hf             {F@4}
        mov (8|M0)               r13.0<1>:f    (abs)r10.8<1;1,0>:hf             {F@4}
        mov (8|M0)               r11.0<1>:f    (abs)r18.8<1;1,0>:hf             {F@3}
        mov (8|M0)               r10.0<1>:f    (abs)r18.0<1;1,0>:hf            
        sel (16|M0)   (lt)f0.0   r12.0<1>:f    r12.0<1;1,0>:f    448.0:f               {Compacted,F@3}
        sel (16|M0)   (lt)f0.0   r10.0<1>:f    r10.0<1;1,0>:f    448.0:f               {Compacted,F@2}
        shr (16|M0)              r22.0<1>:ud   r12.0<1;1,0>:ud   0x17:uw              {F@2}
        shr (16|M0)              r20.0<1>:ud   r10.0<1;1,0>:ud   0x17:uw              {F@1}
        sel (16|M0)   (ge)f0.0   r18.0<2>:ub   r22.0<4;1,0>:ub   0x79:uw              {I@2}
        sel (16|M0)   (ge)f0.0   r19.0<2>:ub   r20.0<4;1,0>:ub   0x79:uw              {I@2}
        mov (16|M0)              r22.0<1>:d    r18.0<2;1,0>:ub                  {I@2}
        mov (16|M0)              r20.0<1>:d    r19.0<2;1,0>:ub                  {I@2}
        shl (16|M0)              r22.0<1>:d    r22.0<1;1,0>:d    23:w               {Compacted,I@2}
        shl (16|M0)              r20.0<1>:d    r20.0<1;1,0>:d    23:w               {Compacted,I@2}
        add (16|M0)              r24.0<1>:d    r22.0<1;1,0>:d    -25165824:d               {I@2}
        add (16|M0)              r18.0<1>:d    r20.0<1;1,0>:d    -25165824:d               {I@2}
        add (16|M0)              r22.0<1>:d    -r22.0<1;1,0>:d   -2139095040:d              
        add (16|M0)              r20.0<1>:d    -r20.0<1;1,0>:d   -2139095040:d              
        mul (16|M0)              acc0.0<1>:f   r12.0<1;1,0>:f    r22.0<1;1,0>:f   {Compacted,I@2}
        mul (16|M0)              acc2.0<1>:f   r10.0<1;1,0>:f    r20.0<1;1,0>:f   {Compacted,I@1}
        rnde (16|M0)             acc0.0<1>:f   acc0.0<1;1,0>:f                 
        rnde (16|M0)             acc2.0<1>:f   acc2.0<1;1,0>:f                 
        cmp (16|M0)   (lt)f1.1   null<1>:f     r14.0<1;1,0>:f    0xB3000000:f              
        mul (16|M0)              acc0.0<1>:f   acc0.0<1;1,0>:f   r24.0<1;1,0>:f   {Compacted}
        mul (16|M0)              acc2.0<1>:f   acc2.0<1;1,0>:f   r18.0<1;1,0>:f   {Compacted}
        mov (16|M0)              r12.0<1>:f    (abs)acc2.0<1;1,0>:f             {Compacted}
(f1.1)  or (16|M0)               r12.0<1>:d    r12.0<1;1,0>:d    -2147483648:d               {F@1}
        mov (8|M0)               r23.0<1>:hf   r12.0<1;1,0>:f                   {I@1}
        mov (8|M0)               r23.8<1>:hf   r13.0<1;1,0>:f                  
        mul (16|M0)              r12.0<1>:f    r3.7<0;1,0>:f     r6.0<1;1,0>:f    {Compacted}
        mul (16|M0)              r10.0<1>:f    r3.7<0;1,0>:f     r8.0<1;1,0>:f    {Compacted}
        sync.nop                             null                             {Compacted,$2.src}
        mov (8|M0)               r6.0<1>:hf    r12.0<1;1,0>:f                   {F@2}
        mov (8|M0)               r6.8<1>:hf    r13.0<1;1,0>:f                  
        mov (8|M0)               r14.0<1>:hf   r10.0<1;1,0>:f                   {F@3}
        mov (8|M0)               r14.8<1>:hf   r11.0<1;1,0>:f                  
        mov (8|M0)               r8.0<1>:f     (abs)r6.0<1;1,0>:hf              {F@4}
        mov (8|M0)               r9.0<1>:f     (abs)r6.8<1;1,0>:hf              {F@4}
        mov (8|M0)               r7.0<1>:f     (abs)r14.8<1;1,0>:hf             {F@3}
        mov (8|M0)               r6.0<1>:f     (abs)r14.0<1;1,0>:hf            
        sel (16|M0)   (lt)f0.0   r8.0<1>:f     r8.0<1;1,0>:f     448.0:f               {Compacted,F@3}
        sel (16|M0)   (lt)f0.0   r6.0<1>:f     r6.0<1;1,0>:f     448.0:f               {Compacted,F@2}
        shr (16|M0)              r18.0<1>:ud   r8.0<1;1,0>:ud    0x17:uw              {F@2}
        cmp (16|M0)   (lt)f0.1   null<1>:f     r16.0<1;1,0>:f    0xB3000000:f              
        sel (16|M0)   (ge)f0.0   r14.0<2>:ub   r18.0<4;1,0>:ub   0x79:uw              {I@1}
        shr (16|M0)              r16.0<1>:ud   r6.0<1;1,0>:ud    0x17:uw              {A@1}
        mov (16|M0)              r20.0<1>:f    (abs)acc0.0<1;1,0>:f             {Compacted}
        mov (16|M0)              r18.0<1>:d    r14.0<2;1,0>:ub                  {I@2}
        sel (16|M0)   (ge)f0.0   r15.0<2>:ub   r16.0<4;1,0>:ub   0x79:uw              {I@2}
(f0.1)  or (16|M0)               r20.0<1>:d    r20.0<1;1,0>:d    -2147483648:d               {F@1}
        shl (16|M0)              r18.0<1>:d    r18.0<1;1,0>:d    23:w               {Compacted,I@3}
        mov (16|M0)              r16.0<1>:d    r15.0<2;1,0>:ub                  {I@3}
        mov (8|M0)               r22.0<1>:hf   r20.0<1;1,0>:f                   {I@3}
        mov (8|M0)               r22.8<1>:hf   r21.0<1;1,0>:f                  
        shl (16|M0)              r16.0<1>:d    r16.0<1;1,0>:d    23:w               {Compacted,I@1}
        add (16|M0)              r20.0<1>:d    r18.0<1;1,0>:d    -25165824:d               {A@1}
        add (16|M0)              r18.0<1>:d    -r18.0<1;1,0>:d   -2139095040:d              
        shl (1|M0)               r3.7<1>:d     r1.4<0;1,0>:d     10:w              
        add (16|M0)              r14.0<1>:d    r16.0<1;1,0>:d    -25165824:d               {I@4}
        mul (16|M0)              acc0.0<1>:f   r8.0<1;1,0>:f     r18.0<1;1,0>:f   {Compacted,I@3}
        add (16|M0)              r16.0<1>:d    -r16.0<1;1,0>:d   -2139095040:d              
        bfn.0xFE (1|M0)          r4.7<1>:ud    r4.7<0;0>:ud      r5.1<0;0>:ud      r3.7<0>:ud       {I@3} // s0|s1|s2
        rnde (16|M0)             acc0.0<1>:f   acc0.0<1;1,0>:f                 
        mul (16|M0)              acc2.0<1>:f   r6.0<1;1,0>:f     r16.0<1;1,0>:f   {Compacted,I@2}
        cmp (16|M0)   (lt)f1.0   null<1>:f     r12.0<1;1,0>:f    0xB3000000:f               {Compacted}
        shl (1|M0)               r4.7<1>:ud    r4.7<0;1,0>:ud    0x1:uw              {I@1}
        rnde (16|M0)             acc2.0<1>:f   acc2.0<1;1,0>:f                 
        mul (16|M0)              acc0.0<1>:f   acc0.0<1;1,0>:f   r20.0<1;1,0>:f   {Compacted}
        cmp (16|M0)   (lt)f0.1   null<1>:f     r10.0<1;1,0>:f    0xB3000000:f              
        mul (16|M0)              acc2.0<1>:f   acc2.0<1;1,0>:f   r14.0<1;1,0>:f   {Compacted}
        mov (16|M0)              r16.0<1>:f    (abs)acc0.0<1;1,0>:f             {Compacted}
        add (1|M0)               r6.0<1>:ud    r4.7<0;1,0>:ud    0xE000:uw              {A@1}
        mov (16|M0)              r8.0<1>:f     (abs)acc2.0<1;1,0>:f             {Compacted}
        sync.nop                             null                             {Compacted,I@1}
        send.slm (1|M0)          null     r6      r22:1   0x0            0x0200B704           {$12} // wr:1+1, rd:0; store.slm.d64x4t.a32
(f1.0)  or (16|M0)               r16.0<1>:d    r16.0<1;1,0>:d    -2147483648:d               {F@2}
        add (1|M0)               r6.0<1>:ud    r4.7<0;1,0>:ud    0xE200:uw              {$12.src}
(f0.1)  or (16|M0)               r8.0<1>:d     r8.0<1;1,0>:d     -2147483648:d               {F@1}
        send.slm (1|M0)          null     r6      r23:1   0x0            0x0200B704           {A@2,$10} // wr:1+1, rd:0; store.slm.d64x4t.a32
        mov (8|M0)               r7.0<1>:hf    r16.0<1;1,0>:f                  
        mov (8|M0)               r7.8<1>:hf    r17.0<1;1,0>:f                  
        add (1|M0)               r6.0<1>:ud    r4.7<0;1,0>:ud    0xE400:uw              {$10.src}
        mov (8|M0)               r10.0<1>:hf   r8.0<1;1,0>:f                    {I@2}
        send.slm (1|M0)          null     r6      r7:1    0x0            0x0200B704           {A@1,$0} // wr:1+1, rd:0; store.slm.d64x4t.a32
        mov (8|M0)               r10.8<1>:hf   r9.0<1;1,0>:f                   
        add (1|M0)               r6.0<1>:ud    r4.7<0;1,0>:ud    0xE600:uw              {$0.src}
        send.slm (1|M0)          null     r6      r10:1   0x0            0x0200B704           {A@1,$6} // wr:1+1, rd:0; store.slm.d64x4t.a32
        sync.nop                             null                             {Compacted,$6.src}
(W)     send.slm (1|M0)          r6       r0      null:0  0x0            0x0210001F           {$11} // wr:1+0, rd:1; fence.slm.none.group
(W)     mov (8|M0)               null<1>:ud    r6.0<1;1,0>:ud                   {$11.dst}
(W)     mov (1|M0)               r6.2<1>:ud    0x0:ud                             
(W)     mov (2|M0)               r6.10<1>:ub   r0.11<0;1,0>:ub                 
(W)     send.gtwy (1|M0)         null     r6      null:0  0x0            0x02000004           {A@1,$9} // wr:1+0, rd:0; signal barrier
(W)     sync.bar                             null                            
        cmp (1|M0)    (eq)f1.1   null<1>:d     r2.4<0;1,0>:d     6:w              
(W)     and (1|M0)               f1.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(f1.1.any16h) goto (16|M0)                   L24512                  L24512                
L14168:
        cmp (1|M0)    (lt)f0.1   null<1>:uw    r1.0<0;1,0>:uw    0x80:uw             
(W)     and (1|M0)               f1.0<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(~f1.0.any16h) goto (16|M0)                  L16176                  L16176                
L14216:
        and (1|M0)               r3.1<1>:d     r1.4<0;1,0>:d     1:w              
        mov (16|M0)              r22.0<1>:f    0.0:f                               {Compacted}
        shl (1|M0)               r3.6<1>:d     r3.1<0;1,0>:d     9:w               {I@1}
        mov (16|M0)              r24.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r26.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r28.0<1>:f    0.0:f                               {Compacted}
        shl (1|M0)               r3.1<1>:d     r3.1<0;1,0>:d     6:w               {Compacted}
        or (1|M0)                r87.0<1>:d    r3.6<0;1,0>:d     0x9000:uw              {I@2}
        or (1|M0)                r86.0<1>:d    r3.6<0;1,0>:d     0x9100:uw             
        or (1|M0)                r85.0<1>:d    r3.6<0;1,0>:d     0x9400:uw             
        or (1|M0)                r84.0<1>:d    r3.6<0;1,0>:d     0x9500:uw             
        or (1|M0)                r83.0<1>:d    r3.6<0;1,0>:d     0x9800:uw             
        or (1|M0)                r82.0<1>:d    r3.6<0;1,0>:d     0x9900:uw             
        or (1|M0)                r81.0<1>:d    r3.6<0;1,0>:d     0x9C00:uw             
        or (1|M0)                r88.0<1>:d    r3.6<0;1,0>:d     0x9D00:uw             
        mov (1|M0)               r3.6<1>:d     r1.4<0;1,0>:d                   
L14432:
        shl (1|M0)               r3.7<1>:d     r3.6<0;1,0>:d     10:w               {I@1}
        send.slm (1|M0)          r57      r87     null:0  0x0            0x0280E700           {$4} // wr:1+0, rd:8; load.slm.d64x32t.a32
        and (1|M0)               r3.7<1>:d     r3.7<0;1,0>:d     6144:w               {I@1}
        send.slm (1|M0)          r47      r86     null:0  0x0            0x0280E700           {$14} // wr:1+0, rd:8; load.slm.d64x32t.a32
        or (1|M0)                r14.0<1>:d    r3.7<0;1,0>:d     0xE000:uw              {I@1}
        or (1|M0)                r65.0<1>:d    r3.7<0;1,0>:d     0xE300:uw             
        sync.nop                             null                             {Compacted,$9.src}
        send.slm (1|M0)          r6       r14     null:0  0x0            0x0280E700           {A@2,$8} // wr:1+0, rd:8; load.slm.d64x32t.a32
        or (1|M0)                r14.0<1>:d    r3.7<0;1,0>:d     0xE100:uw              {$8.src}
        send.slm (1|M0)          r73      r85     null:0  0x0            0x0280E700           {$1} // wr:1+0, rd:8; load.slm.d64x32t.a32
        send.slm (1|M0)          r38      r14     null:0  0x0            0x0280E700           {A@1,$2} // wr:1+0, rd:8; load.slm.d64x32t.a32
        cmp (1|M0)    (lt)f1.0   null<1>:ud    r3.6<0;1,0>:ud    0x4:uw             
        sync.nop                             null                             {Compacted,A@1}
        sync.allwr                           ($4,$8,$14)                
        sync.nop                             null                             {Compacted,$2.src}
        dpas.8x8 (8|M0)          r14:f         null:f            r14:hf            r14.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r14:f         r22:f             r57:hf            r6.0:hf          {Atomic}
        dpas.8x8 (8|M0)          r30:f         r22:f             r47:hf            r6.0:hf          {$4}
(W)     and (1|M0)               f1.1<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
        dpas.8x8 (8|M0)          r6:f          r22:f             r57:hf            r38.0:hf         {$2}
        sync.nop                             null                             {Compacted,$2.src}
        or (1|M0)                r57.0<1>:d    r3.7<0;1,0>:d     0xE200:uw              {$4.src}
        dpas.8x8 (8|M0)          r38:f         r22:f             r47:hf            r38.0:hf         {$5}
        sync.nop                             null                             {Compacted,$5.src}
        send.slm (1|M0)          r47      r57     null:0  0x0            0x0280E700           {A@1,$13} // wr:1+0, rd:8; load.slm.d64x32t.a32
        send.slm (1|M0)          r57      r65     null:0  0x0            0x0280E700           {$15} // wr:1+0, rd:8; load.slm.d64x32t.a32
        send.slm (1|M0)          r65      r84     null:0  0x0            0x0280E700           {$7} // wr:1+0, rd:8; load.slm.d64x32t.a32
        sync.allwr                           ($1,$2,$4,$5,$7,$13,$15)                
(W)     sync.nop                             null                            
        dpas.8x8 (8|M0)          r14:f         null:f            r14:hf            r14.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r14:f         r14:f             r73:hf            r47.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r6:f          r6:f              r73:hf            r57.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r30:f         r30:f             r65:hf            r47.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r38:f         r38:f             r65:hf            r57.0:hf         {$1}
        or (1|M0)                r57.0<1>:d    r3.7<0;1,0>:d     0xE400:uw              {$1.src}
        or (1|M0)                r65.0<1>:d    r3.7<0;1,0>:d     0xE500:uw             
        send.slm (1|M0)          r73      r83     null:0  0x0            0x0280E700           {$3} // wr:1+0, rd:8; load.slm.d64x32t.a32
        send.slm (1|M0)          r47      r57     null:0  0x0            0x0280E700           {A@2,$12} // wr:1+0, rd:8; load.slm.d64x32t.a32
        send.slm (1|M0)          r57      r65     null:0  0x0            0x0280E700           {A@1,$10} // wr:1+0, rd:8; load.slm.d64x32t.a32
        send.slm (1|M0)          r65      r82     null:0  0x0            0x0280E700           {$0} // wr:1+0, rd:8; load.slm.d64x32t.a32
        sync.allwr                           ($0,$1,$3,$10,$12)                
        dpas.8x8 (8|M0)          r14:f         null:f            r14:hf            r14.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r14:f         r14:f             r73:hf            r47.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r6:f          r6:f              r73:hf            r57.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r30:f         r30:f             r65:hf            r47.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r38:f         r38:f             r65:hf            r57.0:hf         {$1}
        or (1|M0)                r57.0<1>:d    r3.7<0;1,0>:d     0xE600:uw              {$1.src}
        or (1|M0)                r65.0<1>:d    r3.7<0;1,0>:d     0xE700:uw             
        send.slm (1|M0)          r73      r81     null:0  0x0            0x0280E700           {$6} // wr:1+0, rd:8; load.slm.d64x32t.a32
        send.slm (1|M0)          r47      r57     null:0  0x0            0x0280E700           {A@2,$11} // wr:1+0, rd:8; load.slm.d64x32t.a32
        send.slm (1|M0)          r57      r65     null:0  0x0            0x0280E700           {A@1,$9} // wr:1+0, rd:8; load.slm.d64x32t.a32
        send.slm (1|M0)          r65      r88     null:0  0x0            0x0280E700           {$14} // wr:1+0, rd:8; load.slm.d64x32t.a32
        add (1|M0)               r3.7<1>:d     r3.7<0;1,0>:d     4096:w              
        sync.allwr                           ($1,$6,$9,$11,$14)                
        dpas.8x8 (8|M0)          r14:f         null:f            r14:hf            r14.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r14:f         r14:f             r73:hf            r47.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r6:f          r6:f              r73:hf            r57.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r30:f         r30:f             r65:hf            r47.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r38:f         r38:f             r65:hf            r57.0:hf         {$1}
        sync.nop                             null                             {Compacted,$1.src}
        or (1|M0)                r50.0<1>:d    r3.7<0;1,0>:d     r3.1<0;1,0>:d    {I@1}
        add (1|M0)               r3.7<1>:d     r3.6<0;1,0>:d     4:w              
        or (1|M0)                r47.0<1>:ud   r50.0<0;1,0>:ud   0x400:uw              {I@2}
        mov (8|M0)               r51.0<1>:f    r14.0<1;1,0>:f                   {Compacted,$1.dst}
        mov (8|M0)               r48.0<1>:f    r6.0<1;1,0>:f                    {Compacted}
        mov (8|M0)               r52.0<1>:f    r30.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r49.0<1>:f    r38.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r50     r51:2   0x0            0x0200C704           {A@2,$8} // wr:1+2, rd:0; store.slm.d64x8t.a32
        send.slm (1|M0)          null     r47     r48:2   0x0            0x0200C704           {A@1,$13} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r51.0<1>:f    r15.0<1;1,0>:f                   {Compacted,$8.src}
        mov (8|M0)               r52.0<1>:f    r31.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r47.0<1>:ud   r50.0<0;1,0>:ud   0x80:uw              {$13.src}
        mov (8|M0)               r48.0<1>:f    r7.0<1;1,0>:f                    {Compacted}
        send.slm (1|M0)          null     r47     r51:2   0x0            0x0200C704           {A@1,$4} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r49.0<1>:f    r39.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r47.0<1>:ud   r50.0<0;1,0>:ud   0x480:uw              {$4.src}
        mov (8|M0)               r51.0<1>:f    r16.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r47     r48:2   0x0            0x0200C704           {A@1,$2} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r52.0<1>:f    r32.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r47.0<1>:ud   r50.0<0;1,0>:ud   0x100:uw              {$2.src}
        mov (8|M0)               r48.0<1>:f    r8.0<1;1,0>:f                    {Compacted}
        send.slm (1|M0)          null     r47     r51:2   0x0            0x0200C704           {A@1,$5} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r49.0<1>:f    r40.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r47.0<1>:ud   r50.0<0;1,0>:ud   0x500:uw              {$5.src}
        mov (8|M0)               r51.0<1>:f    r17.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r47     r48:2   0x0            0x0200C704           {A@1,$15} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r52.0<1>:f    r33.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r47.0<1>:ud   r50.0<0;1,0>:ud   0x180:uw              {$15.src}
        mov (8|M0)               r48.0<1>:f    r9.0<1;1,0>:f                    {Compacted}
        send.slm (1|M0)          null     r47     r51:2   0x0            0x0200C704           {A@1,$7} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r49.0<1>:f    r41.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r47.0<1>:ud   r50.0<0;1,0>:ud   0x580:uw              {$7.src}
        mov (8|M0)               r51.0<1>:f    r18.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r47     r48:2   0x0            0x0200C704           {A@1,$10} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r52.0<1>:f    r34.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r47.0<1>:ud   r50.0<0;1,0>:ud   0x200:uw              {$10.src}
        mov (8|M0)               r48.0<1>:f    r10.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r47     r51:2   0x0            0x0200C704           {A@1,$0} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r49.0<1>:f    r42.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r47.0<1>:ud   r50.0<0;1,0>:ud   0x600:uw              {$0.src}
        mov (8|M0)               r51.0<1>:f    r19.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r47     r48:2   0x0            0x0200C704           {A@1,$6} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r52.0<1>:f    r35.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r47.0<1>:ud   r50.0<0;1,0>:ud   0x280:uw              {$6.src}
        mov (8|M0)               r48.0<1>:f    r11.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r47     r51:2   0x0            0x0200C704           {A@1,$11} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r49.0<1>:f    r43.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r47.0<1>:ud   r50.0<0;1,0>:ud   0x680:uw              {$11.src}
        mov (8|M0)               r51.0<1>:f    r20.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r47     r48:2   0x0            0x0200C704           {A@1,$9} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r52.0<1>:f    r36.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r47.0<1>:ud   r50.0<0;1,0>:ud   0x300:uw              {$9.src}
        mov (8|M0)               r14.0<1>:f    r21.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r47     r51:2   0x0            0x0200C704           {A@1,$14} // wr:1+2, rd:0; store.slm.d64x8t.a32
        or (1|M0)                r6.0<1>:ud    r50.0<0;1,0>:ud   0x380:uw             
        mov (8|M0)               r15.0<1>:f    r37.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r48.0<1>:f    r12.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r49.0<1>:f    r44.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r47.0<1>:ud   r50.0<0;1,0>:ud   0x700:uw              {$14.src}
        mov (8|M0)               r7.0<1>:f     r13.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r47     r48:2   0x0            0x0200C704           {A@1,$12} // wr:1+2, rd:0; store.slm.d64x8t.a32
        send.slm (1|M0)          null     r6      r14:2   0x0            0x0200C704           {$1} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r8.0<1>:f     r45.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r6.0<1>:ud    r50.0<0;1,0>:ud   0x780:uw              {$1.src}
        send.slm (1|M0)          null     r6      r7:2    0x0            0x0200C704           {A@1,$3} // wr:1+2, rd:0; store.slm.d64x8t.a32
(~f1.1.any16h) goto (16|M0)                  L16176                  L16176                
L16144:
        mov (1|M0)               r3.6<1>:d     r3.7<0;1,0>:d                   
        goto.b (16|M0)                       L16176                  L14432                
L16176:
        join (16|M0)                         L24512                                
L16192:
        sync.allrd                           ($3,$9)                
(W)     send.slm (1|M0)          r6       r0      null:0  0x0            0x0210001F           {$8} // wr:1+0, rd:1; fence.slm.none.group
(W)     mov (8|M0)               null<1>:ud    r6.0<1;1,0>:ud                   {$8.dst}
(W)     mov (1|M0)               r6.2<1>:f     0.0:f                               {Compacted,I@1}
(W)     mov (2|M0)               r6.10<1>:ub   r0.11<0;1,0>:ub                  {F@1}
(W)     send.gtwy (1|M0)         null     r6      null:0  0x0            0x02000004           {A@1,$13} // wr:1+0, rd:0; signal barrier
(W)     sync.bar                             null                            
        cmp (1|M0)    (eq)f1.1   null<1>:d     r2.4<0;1,0>:d     8:w              
(W)     and (1|M0)               f1.0<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(f1.0.any16h) goto (16|M0)                   L23736                  L23736                
L16344:
        shl (1|M0)               r3.1<1>:ud    r1.5<0;1,0>:ud    0x5:uw             
        shl (1|M0)               r1.5<1>:ud    r1.5<0;1,0>:ud    0x7:uw             
        add (1|M0)               r10.0<1>:ud   r1.5<0;1,0>:ud    0x1000:uw              {I@1}
        sync.nop                             null                             {Compacted,$13.src}
        send.slm (1|M0)          r6       r10     null:0  0x0            0x0240D700           {A@1,$4} // wr:1+0, rd:4; load.slm.d64x16t.a32
        sel (16|M0)   (lt)f0.0   r12.0<1>:f    (abs)r6.0<1;1,0>:f  448.0:f             {Compacted,$4.dst}
        sel (16|M0)   (lt)f0.0   r10.0<1>:f    (abs)r8.0<1;1,0>:f  448.0:f             {Compacted}
        shr (16|M0)              r18.0<1>:ud   r12.0<1;1,0>:ud   0x17:uw              {F@2}
        shr (16|M0)              r16.0<1>:ud   r10.0<1;1,0>:ud   0x17:uw              {F@1}
        sel (16|M0)   (ge)f0.0   r14.0<2>:ub   r18.0<4;1,0>:ub   0x79:uw              {I@2}
        sel (16|M0)   (ge)f0.0   r15.0<2>:ub   r16.0<4;1,0>:ub   0x79:uw              {I@2}
        mov (16|M0)              r18.0<1>:d    r14.0<2;1,0>:ub                  {I@2}
        mov (16|M0)              r16.0<1>:d    r15.0<2;1,0>:ub                  {I@2}
        shl (16|M0)              r18.0<1>:d    r18.0<1;1,0>:d    23:w               {Compacted,I@2}
        shl (16|M0)              r16.0<1>:d    r16.0<1;1,0>:d    23:w               {Compacted,I@2}
        add (16|M0)              r20.0<1>:d    r18.0<1;1,0>:d    -25165824:d               {I@2}
        add (16|M0)              r14.0<1>:d    r16.0<1;1,0>:d    -25165824:d               {I@2}
        add (16|M0)              r18.0<1>:d    -r18.0<1;1,0>:d   -2139095040:d              
        add (16|M0)              r16.0<1>:d    -r16.0<1;1,0>:d   -2139095040:d              
        mul (16|M0)              acc0.0<1>:f   r12.0<1;1,0>:f    r18.0<1;1,0>:f   {Compacted,I@2}
        mul (16|M0)              acc2.0<1>:f   r10.0<1;1,0>:f    r16.0<1;1,0>:f   {Compacted,I@1}
        rnde (16|M0)             acc0.0<1>:f   acc0.0<1;1,0>:f                 
        rnde (16|M0)             acc2.0<1>:f   acc2.0<1;1,0>:f                 
        cmp (16|M0)   (lt)f1.0   null<1>:f     r6.0<1;1,0>:f     0.0:f               {Compacted}
        cmp (16|M0)   (lt)f1.1   null<1>:f     r8.0<1;1,0>:f     0.0:f              
        mul (16|M0)              acc0.0<1>:f   acc0.0<1;1,0>:f   r20.0<1;1,0>:f   {Compacted}
        mul (16|M0)              acc2.0<1>:f   acc2.0<1;1,0>:f   r14.0<1;1,0>:f   {Compacted}
        mov (16|M0)              r16.0<1>:f    (abs)acc0.0<1;1,0>:f             {Compacted}
        mov (16|M0)              r12.0<1>:f    (abs)acc2.0<1;1,0>:f             {Compacted}
(f1.0)  or (16|M0)               r16.0<1>:d    r16.0<1;1,0>:d    -2147483648:d               {F@2}
(f1.1)  or (16|M0)               r12.0<1>:d    r12.0<1;1,0>:d    -2147483648:d               {F@1}
        mov (8|M0)               r6.0<1>:hf    r16.0<1;1,0>:f                   {I@2}
        mov (8|M0)               r6.8<1>:hf    r17.0<1;1,0>:f                  
        mov (8|M0)               r7.0<1>:hf    r12.0<1;1,0>:f                   {I@1}
        mov (8|M0)               r7.8<1>:hf    r13.0<1;1,0>:f                  
        send.slm (1|M0)          null     r55     r6:1    0x0            0x0200B704           {A@3,$2} // wr:1+1, rd:0; store.slm.d64x4t.a32
        send.slm (1|M0)          null     r3      r7:1    0x0            0x0200B704           {A@1,$5} // wr:1+1, rd:0; store.slm.d64x4t.a32
        sync.nop                             null                             {Compacted,$2.src}
(W)     send.slm (1|M0)          r6       r0      null:0  0x0            0x0210001F           {$15} // wr:1+0, rd:1; fence.slm.none.group
(W)     mov (8|M0)               null<1>:ud    r6.0<1;1,0>:ud                   {$15.dst}
(W)     mov (1|M0)               r6.2<1>:f     0.0:f                               {Compacted,I@1}
(W)     mov (2|M0)               r6.10<1>:ub   r0.11<0;1,0>:ub                  {F@1}
(W)     send.gtwy (1|M0)         null     r6      null:0  0x0            0x02000004           {A@1,$7} // wr:1+0, rd:0; signal barrier
(W)     sync.bar                             null                            
(W)     and (1|M0)               f1.1<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(~f1.1.any16h) goto (16|M0)                  L18640                  L18640                
L16968:
        and (1|M0)               r3.0<1>:d     r1.4<0;1,0>:d     1:w               {Compacted,$5.src}
        mov (16|M0)              r8.0<1>:f     0.0:f                               {Compacted}
        shl (1|M0)               r3.6<1>:d     r3.0<0;1,0>:d     8:w               {Compacted,I@1}
        mov (16|M0)              r10.0<1>:f    0.0:f                               {Compacted}
        shr (1|M0)               r4.1<1>:ud    r3.6<0;1,0>:ud    0x1F:uw              {I@1}
        shl (1|M0)               r3.6<1>:d     r3.6<0;1,0>:d     1:w              
        or (1|M0)                r3.7<1>:d     r4.1<0;1,0>:d     0:w               {I@2}
        addc (1|M0)              r7.0<1>:ud    r4.4<0;1,0>:ud    r3.6<0;1,0>:ud   {AccWrEn,I@2}
        mov (16|M0)              r12.0<1>:f    0.0:f                               {Compacted}
        mov (1|M0)               r55.0<1>:f    r7.0<0;1,0>:f                    {Compacted,I@1}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$7.src}
        addc (1|M0)              r7.0<1>:ud    r55.0<0;1,0>:ud   0x100:ud              {AccWrEn,F@1}
        add3 (1|M0)              r55.1<1>:d    r6.0<0;0>:d       r4.5<0;0>:d       r3.7<0>:d        {I@2}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r81.0<1>:f    r7.0<0;1,0>:f                    {Compacted,I@3}
        addc (1|M0)              r7.0<1>:ud    r55.0<0;1,0>:ud   0x400:ud              {AccWrEn,F@1}
        add3 (1|M0)              r81.1<1>:d    r6.0<0;0>:d       r55.1<0;0>:d      0:w               {I@2}
        mov (1|M0)               r82.0<1>:f    r7.0<0;1,0>:f                    {Compacted,I@2}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r7.0<1>:ud    r82.0<0;1,0>:ud   0x100:ud              {AccWrEn,F@1}
        add3 (1|M0)              r82.1<1>:d    r6.0<0;0>:d       r55.1<0;0>:d      0:w               {I@2}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r83.0<1>:f    r7.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r83.1<1>:d    r6.0<0;0>:d       r82.1<0;0>:d      0:w               {I@1}
        mov (16|M0)              r6.0<1>:f     0.0:f                               {Compacted,I@1}
        shl (1|M0)               r3.0<1>:d     r3.0<0;1,0>:d     6:w               {Compacted}
L17264:
        send.ugm (1|M0)          r57      r55     null:0  0x0            0x0280E780           {$10} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        sync.allrd                           ($0,$3,$9,$12)                
        send.ugm (1|M0)          r47      r81     null:0  0x0            0x0280E780           {$11} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        shr (1|M0)               r3.6<1>:ud    r1.4<0;1,0>:ud    0x1:uw             
        send.ugm (1|M0)          r73      r82     null:0  0x0            0x0280E780           {$9} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        shl (1|M0)               r3.7<1>:ud    r3.6<0;1,0>:ud    0xA:uw              {I@1}
        shl (1|M0)               r3.6<1>:ud    r3.6<0;1,0>:ud    0xB:uw             
        sync.nop                             null                             {Compacted,$6.src}
        or (1|M0)                r14.0<1>:ud   r3.7<0;1,0>:ud    0x7000:uw              {I@2}
        or (1|M0)                r65.0<1>:ud   r3.7<0;1,0>:ud    0x7300:uw             
        send.slm (1|M0)          r22      r14     null:0  0x0            0x0280E700           {A@2,$14} // wr:1+0, rd:8; load.slm.d64x32t.a32
        or (1|M0)                r14.0<1>:ud   r3.7<0;1,0>:ud    0x7100:uw              {$14.src}
        or (1|M0)                r3.6<1>:d     r3.6<0;1,0>:d     r3.0<0;1,0>:d   
        send.slm (1|M0)          r38      r14     null:0  0x0            0x0280E700           {A@2,$12} // wr:1+0, rd:8; load.slm.d64x32t.a32
        cmp (1|M0)    (lt)f1.0   null<1>:ud    r1.4<0;1,0>:ud    0x4:uw             
(W)     and (1|M0)               f1.0<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
        sync.nop                             null                             {Compacted,F@1}
        sync.allwr                           ($10,$11,$12,$14)                
        dpas.8x8 (8|M0)          r14:f         null:f            r14:hf            r14.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r14:f         r6:f              r57:hf            r22.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r30:f         r6:f              r47:hf            r22.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r22:f         r6:f              r57:hf            r38.0:hf         {$10}
        or (1|M0)                r57.0<1>:ud   r3.7<0;1,0>:ud    0x7200:uw              {$10.src}
        dpas.8x8 (8|M0)          r38:f         r6:f              r47:hf            r38.0:hf         {$1}
        sync.nop                             null                             {Compacted,$1.src}
        send.slm (1|M0)          r47      r57     null:0  0x0            0x0280E700           {A@1,$3} // wr:1+0, rd:8; load.slm.d64x32t.a32
        send.slm (1|M0)          r57      r65     null:0  0x0            0x0280E700           {$8} // wr:1+0, rd:8; load.slm.d64x32t.a32
        sync.nop                             null                             {Compacted,$8.src}
        send.ugm (1|M0)          r65      r83     null:0  0x0            0x0280E780           {$13} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        sync.allwr                           ($1,$3,$8,$9,$10,$13)                
(W)     sync.nop                             null                            
        dpas.8x8 (8|M0)          r14:f         null:f            r14:hf            r14.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r14:f         r14:f             r73:hf            r47.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r22:f         r22:f             r73:hf            r57.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r30:f         r30:f             r65:hf            r47.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r38:f         r38:f             r65:hf            r57.0:hf         {$9}
        or (1|M0)                r47.0<1>:d    r3.6<0;1,0>:d     0xA000:uw              {$9.src}
        mov (8|M0)               r50.0<1>:f    r14.0<1;1,0>:f                   {Compacted,$9.dst}
        mov (8|M0)               r48.0<1>:f    r22.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r14.0<1>:d    r3.6<0;1,0>:d     0xA380:uw              {F@2}
        mov (8|M0)               r51.0<1>:f    r30.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r49.0<1>:f    r38.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r47     r50:2   0x0            0x0200C704           {A@2,$4} // wr:1+2, rd:0; store.slm.d64x8t.a32
        or (1|M0)                r47.0<1>:d    r3.6<0;1,0>:d     0xA400:uw              {$4.src}
        mov (8|M0)               r50.0<1>:f    r15.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r47     r48:2   0x0            0x0200C704           {A@1,$2} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r51.0<1>:f    r31.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r47.0<1>:d    r3.6<0;1,0>:d     0xA080:uw              {$2.src}
        mov (8|M0)               r48.0<1>:f    r23.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r47     r50:2   0x0            0x0200C704           {A@1,$5} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r49.0<1>:f    r39.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r47.0<1>:d    r3.6<0;1,0>:d     0xA480:uw              {$5.src}
        mov (8|M0)               r50.0<1>:f    r16.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r47     r48:2   0x0            0x0200C704           {A@1,$15} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r51.0<1>:f    r32.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r47.0<1>:d    r3.6<0;1,0>:d     0xA100:uw              {$15.src}
        mov (8|M0)               r48.0<1>:f    r24.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r47     r50:2   0x0            0x0200C704           {A@1,$7} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r49.0<1>:f    r40.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r47.0<1>:d    r3.6<0;1,0>:d     0xA500:uw              {$7.src}
        mov (8|M0)               r50.0<1>:f    r17.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r47     r48:2   0x0            0x0200C704           {A@1,$6} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r51.0<1>:f    r33.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r47.0<1>:d    r3.6<0;1,0>:d     0xA180:uw              {$6.src}
        mov (8|M0)               r48.0<1>:f    r25.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r47     r50:2   0x0            0x0200C704           {A@1,$14} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r49.0<1>:f    r41.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r47.0<1>:d    r3.6<0;1,0>:d     0xA580:uw              {$14.src}
        mov (8|M0)               r50.0<1>:f    r18.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r47     r48:2   0x0            0x0200C704           {A@1,$11} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r51.0<1>:f    r34.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r47.0<1>:d    r3.6<0;1,0>:d     0xA200:uw              {$11.src}
        mov (8|M0)               r48.0<1>:f    r26.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r47     r50:2   0x0            0x0200C704           {A@1,$12} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r49.0<1>:f    r42.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r47.0<1>:d    r3.6<0;1,0>:d     0xA600:uw              {$12.src}
        mov (8|M0)               r50.0<1>:f    r19.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r47     r48:2   0x0            0x0200C704           {A@1,$10} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r51.0<1>:f    r35.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r47.0<1>:d    r3.6<0;1,0>:d     0xA280:uw              {$10.src}
        mov (8|M0)               r48.0<1>:f    r27.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r47     r50:2   0x0            0x0200C704           {A@1,$1} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r49.0<1>:f    r43.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r47.0<1>:d    r3.6<0;1,0>:d     0xA680:uw              {$1.src}
        mov (8|M0)               r50.0<1>:f    r20.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r47     r48:2   0x0            0x0200C704           {A@1,$3} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r51.0<1>:f    r36.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r47.0<1>:d    r3.6<0;1,0>:d     0xA300:uw              {$3.src}
        mov (8|M0)               r15.0<1>:f    r21.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r47     r50:2   0x0            0x0200C704           {A@1,$8} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r16.0<1>:f    r37.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r48.0<1>:f    r28.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r49.0<1>:f    r44.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r47.0<1>:d    r3.6<0;1,0>:d     0xA700:uw              {$8.src}
        mov (8|M0)               r17.0<1>:f    r29.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r47     r48:2   0x0            0x0200C704           {A@1,$0} // wr:1+2, rd:0; store.slm.d64x8t.a32
        send.slm (1|M0)          null     r14     r15:2   0x0            0x0200C704           {$13} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r18.0<1>:f    r45.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r14.0<1>:d    r3.6<0;1,0>:d     0xA780:uw              {$13.src}
        add (1|M0)               r3.6<1>:ud    r1.4<0;1,0>:ud    0x4:uw             
        send.slm (1|M0)          null     r14     r17:2   0x0            0x0200C704           {A@1,$6} // wr:1+2, rd:0; store.slm.d64x8t.a32
(~f1.0.any16h) goto (16|M0)                  L18640                  L18640                
L18608:
        mov (1|M0)               r1.4<1>:d     r3.6<0;1,0>:d                    {I@2}
        goto.b (16|M0)                       L18640                  L17264                
L18640:
        join (16|M0)                         L23736                                
L18656:
        sync.nop                             null                             {Compacted,$7.src}
(W)     send.slm (1|M0)          r6       r0      null:0  0x0            0x0210001F           {$9} // wr:1+0, rd:1; fence.slm.none.group
(W)     mov (8|M0)               null<1>:ud    r6.0<1;1,0>:ud                   {$9.dst}
(W)     mov (1|M0)               r6.2<1>:f     0.0:f                               {Compacted,I@1}
(W)     mov (2|M0)               r6.10<1>:ub   r0.11<0;1,0>:ub                  {F@1}
(W)     send.gtwy (1|M0)         null     r6      null:0  0x0            0x02000004           {A@1,$4} // wr:1+0, rd:0; signal barrier
(W)     sync.bar                             null                            
        cmp (1|M0)    (eq)f0.1   null<1>:d     r2.4<0;1,0>:d     9:w              
(W)     and (1|M0)               f0.1<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(~f0.1.any16h) goto (16|M0)                  L19544                  L19544                
L18800:
        cmp (1|M0)    (eq)f1.0   null<1>:d     r3.5<0;1,0>:d     0:w              
(f1.0)  cmp (1|M0)    (eq)f1.0   null<1>:d     r3.4<0;1,0>:d     0:w              
(W)     and (1|M0)               f0.0<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
(f0.0.any16h) goto (16|M0)                   L19544                  L28784                
L18864:
        shl (1|M0)               r3.6<1>:d     r1.7<0;1,0>:d     12:w               {$5.src}
        shr (1|M0)               r3.0<1>:ud    r1.6<0;1,0>:ud    0x14:uw             
        shl (1|M0)               r3.2<1>:d     r1.6<0;1,0>:d     12:w              
        or (1|M0)                r3.3<1>:d     r3.6<0;1,0>:d     r3.0<0;1,0>:d    {I@2}
        shr (1|M0)               r2.0<1>:ud    r3.2<0;1,0>:ud    0x1F:uw              {I@2}
        shl (1|M0)               r2.1<1>:d     r3.2<0;1,0>:d     1:w              
        shl (1|M0)               r2.3<1>:d     r3.3<0;1,0>:d     1:w               {Compacted,I@3}
        mov (1|M0)               r2.5<2>:f     0.0:f                              
        or (1|M0)                r2.2<1>:d     r2.3<0;1,0>:d     r2.0<0;1,0>:d    {I@1}
        addc (1|M0)              r2.0<1>:ud    r3.4<0;1,0>:ud    r2.1<0;1,0>:ud   {AccWrEn}
        shl (1|M0)               r2.3<1>:d     r3.1<0;1,0>:d     1:w              
        mov (1|M0)               r3.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        shr (1|M0)               r2.1<1>:ud    r3.1<0;1,0>:ud    0x1F:uw             
        add3 (1|M0)              r2.6<1>:d     r3.0<0;0>:d       r3.5<0;0>:d       r2.2<0>:d        {I@2}
        addc (1|M0)              r3.0<1>:ud    r2.0<0;1,0>:ud    r2.3<0;1,0>:ud   {AccWrEn}
        or (1|M0)                r2.4<1>:d     r2.1<0;1,0>:d     0:w               {I@3}
        mov (1|M0)               r2.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r2.1<1>:d     r3.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r2.2<1>:d     r2.0<0;0>:d       r2.6<0;0>:d       r2.4<0>:d        {I@2}
        mov (1|M0)               r2.4<2>:f     0.0:f                               {I@1}
L19160:
        or (1|M0)                r2.0<1>:d     r3.1<0;1,0>:d     r2.4<0;1,0>:d    {F@1}
        shl (1|M0)               r2.6<1>:d     r2.4<0;1,0>:d     1:w              
        shl (1|M0)               r2.0<1>:d     r2.0<0;1,0>:d     2:w               {Compacted,I@2}
        shl (1|M0)               r3.2<1>:d     r2.5<0;1,0>:d     1:w              
        add (1|M0)               r3.0<1>:d     r2.0<0;1,0>:d     0xA000:uw              {I@2}
        addc (1|M0)              r1.0<1>:ud    r2.1<0;1,0>:ud    r2.6<0;1,0>:ud   {AccWrEn}
        sync.nop                             null                             {Compacted,$4.src}
        send.slm (1|M0)          r4       r3      null:0  0x0            0x0240D700           {A@2,$2} // wr:1+0, rd:4; load.slm.d64x16t.a32
        shr (1|M0)               r3.0<1>:ud    r2.4<0;1,0>:ud    0x1F:uw              {$2.src}
        or (1|M0)                r2.7<1>:d     r3.2<0;1,0>:d     r3.0<0;1,0>:d    {I@1}
        mov (1|M0)               r3.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        sync.nop                             null                             {Compacted,$2.dst}
        add3 (1|M0)              r4.1<1>:d     r3.0<0;0>:d       r2.2<0;0>:d       r2.7<0>:d        {I@1}
        mov (1|M0)               r2.0<2>:hf    r4.0<0;1,0>:f                   
        addc (1|M0)              r3.0<1>:ud    r2.4<0;1,0>:ud    0x1:ud              {AccWrEn}
        mov (1|M0)               r4.0<1>:f     r1.0<0;1,0>:f                    {Compacted}
        mov (1|M0)               r2.0<1>:d     r2.0<0;1,0>:uw                   {F@2}
        mov (1|M0)               r2.6<1>:d     r3.0<0;1,0>:d                    {I@2}
        send.ugm (1|M0)          null     r4      r2:1    0x0            0x04000B84           {A@1,$5} // wr:2+1, rd:0; store.ugm.d16u32.a64
        mov (1|M0)               r2.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$5.src}
        add3 (1|M0)              r2.7<1>:d     r2.0<0;0>:d       r2.5<0;0>:d       0:w               {I@1}
        cmp (1|M0)    (eq)f0.1   null<1>:d     r2.7<0;1,0>:d     0:w               {I@1}
(f0.1)  cmp (1|M0)    (eq)f0.1   null<1>:d     r2.6<0;1,0>:d     32:w              
(W)     and (1|M0)               f1.1<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(f1.1.any16h) goto (16|M0)                   L19544                  L28784                
L19512:
(W)     mov (2|M0)               r2.4<1>:ud    r2.6<1;1,0>:ud                  
        goto.b (16|M0)                       L19544                  L19160                
L19544:
        join (16|M0)                         L23736                                
L19560:
(W)     and (1|M0)               f1.0<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
(~f1.0.any16h) goto (16|M0)                  L23736                  L28784                
L19592:
        cmp (1|M0)    (gt)f1.0   null<1>:d     r1.2<0;1,0>:d     -1:w              
        cmp (1|M0)    (lt)f0.0   null<1>:d     r1.2<0;1,0>:d     r2.7<0;1,0>:d   
(W)     mov (1|M0)               r1.0<1>:hf    0x1:hf                             
(f1.0)  cmp (1|M0)    (lt)f1.0   null<1>:d     r1.3<0;1,0>:d     r2.6<0;1,0>:d   
(f1.0)  sel (1|M0)               r1.1<1>:uw    r1.0<0;1,0>:uw    0x0:uw              {F@1}
(f0.0)  sel (1|M0)               r1.0<1>:uw    r1.0<0;1,0>:uw    0x0:uw             
        and (1|M0)    (ne)f1.1   null<1>:uw    r1.1<0;1,0>:uw    r1.0<0;1,0>:uw   {I@1}
(W)     and (1|M0)               f0.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(~f0.1.any16h) goto (16|M0)                  L23736                  L28784                
L19736:
        mul (1|M0)               acc0.0<1>:ud  r1.3<0;1,0>:ud    r2.14<0;1,0>:uw 
        mach (1|M0)              r7.0<1>:ud    r1.3<0;1,0>:ud    r2.7<0;1,0>:ud   {AccWrEn,$5.src}
        cmp (1|M0)    (eq)f1.0   null<1>:w     r4.26<0;1,0>:b    0:w              
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$4.src}
        addc (1|M0)              r3.0<1>:ud    r6.0<0;1,0>:ud    r1.2<0;1,0>:ud   {AccWrEn,I@1}
(W)     and (1|M0)               f0.0<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
        mov (1|M0)               r1.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        add3 (1|M0)              r1.1<1>:d     r1.0<0;0>:d       r7.0<0;0>:d       0:w               {I@1}
        shr (1|M0)               r1.0<1>:ud    r3.0<0;1,0>:ud    0x1B:uw             
        shl (1|M0)               r1.3<1>:d     r1.1<0;1,0>:d     5:w               {I@2}
        shl (1|M0)               r1.1<1>:d     r3.0<0;1,0>:d     5:w               {Compacted}
        or (1|M0)                r1.2<1>:d     r1.3<0;1,0>:d     r1.0<0;1,0>:d    {I@2}
(f0.0.any16h) goto (16|M0)                   L20128                  L20128                
L19920:
        shl (1|M0)               r1.3<1>:d     r1.1<0;1,0>:d     1:w               {I@3}
        shl (1|M0)               r1.6<1>:d     r1.2<0;1,0>:d     1:w               {I@3}
        shr (1|M0)               r1.0<1>:ud    r1.1<0;1,0>:ud    0x1F:uw             
        addc (1|M0)              r3.0<1>:ud    r3.2<0;1,0>:ud    r1.3<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r1.4<1>:d     r1.6<0;1,0>:d     r1.0<0;1,0>:d    {I@2}
        mov (1|M0)               r1.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r6.0<1>:f     r3.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r6.1<1>:d     r1.0<0;0>:d       r3.3<0;0>:d       r1.4<0>:d        {I@1}
        send.ugm (1|M0)          r2       r6      null:0  0x0            0x0220C780           {A@1,$15} // wr:1+0, rd:2; load.ugm.d64x8t.a64
        mov (8|M0)               r10.0<1>:f    r2.0<1;1,0>:hf                   {$15.dst}
        mov (8|M0)               r11.0<1>:f    r2.8<1;1,0>:hf                  
        mov (8|M0)               r12.0<1>:f    r3.0<1;1,0>:hf                  
        mov (8|M0)               r13.0<1>:f    r3.8<1;1,0>:hf                  
        goto (16|M0)                         L20128                  L20264                
L20128:
        join (16|M0)                         L20264                                
L20144:
        shl (1|M0)               r1.3<1>:d     r1.1<0;1,0>:d     2:w              
        shl (1|M0)               r1.6<1>:d     r1.2<0;1,0>:d     2:w              
        shr (1|M0)               r1.0<1>:ud    r1.1<0;1,0>:ud    0x1E:uw             
        addc (1|M0)              r3.0<1>:ud    r3.2<0;1,0>:ud    r1.3<0;1,0>:ud   {AccWrEn,A@2}
        or (1|M0)                r1.4<1>:d     r1.6<0;1,0>:d     r1.0<0;1,0>:d    {I@2}
        mov (1|M0)               r1.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        add3 (1|M0)              r3.1<1>:d     r1.0<0;0>:d       r3.3<0;0>:d       r1.4<0>:d        {I@1}
        send.ugm (1|M0)          r10      r3      null:0  0x0            0x0240E580           {A@1,$7} // wr:1+0, rd:4; load.ugm.d32x32t.a64
L20264:
        join (16|M0)                         L23736                                
L20280:
        sync.nop                             null                             {Compacted,$6.src}
        send.ugm (1|M0)          r14      r46     null:0  0x0            0x0240E580           {$14} // wr:1+0, rd:4; load.ugm.d32x32t.a64
        add (1|M0)               r1.0<1>:ud    r1.5<0;1,0>:ud    0xA000:uw             
        cmp (1|M0)    (lt)f0.1   null<1>:d     r5.0<0;1,0>:d     1:w              
        send.slm (1|M0)          r6       r1      null:0  0x0            0x0240D700           {A@2,$11} // wr:1+0, rd:4; load.slm.d64x16t.a32
(W)     and (1|M0)               f1.1<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
        sync.allwr                           ($11,$14)                
        mad (16|M0)              r6.0<1>:f     r6.0<1;0>:f       r14.0<1;0>:f      r10.0<1>:f       {Compacted,$7.dst}
        mad (16|M0)              r8.0<1>:f     r8.0<1;0>:f       r16.0<1;0>:f      r12.0<1>:f       {Compacted}
(f1.1.any16h) goto (16|M0)                   L21080                  L21080                
L20416:
        cmp (1|M0)    (lt)f0.0   null<1>:d     r5.0<0;1,0>:d     4:w              
(W)     and (1|M0)               f1.0<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
(f1.0.any16h) goto (16|M0)                   L20656                  L20656                
L20464:
        cmp (1|M0)    (eq)f1.1   null<1>:d     r5.0<0;1,0>:d     4:w              
(W)     and (1|M0)               f0.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(~f0.1.any16h) goto (16|M0)                  L20656                  L21144                
L20512:
        mov (8|M0)               r3.0<1>:hf    r6.0<1;1,0>:f                    {F@2}
        mov (8|M0)               r3.8<1>:hf    r7.0<1;1,0>:f                   
        mov (8|M0)               r2.0<1>:hf    r8.0<1;1,0>:f                    {F@3}
        mov (8|M0)               r2.8<1>:hf    r9.0<1;1,0>:f                   
        mov (8|M0)               r6.0<1>:f     r3.0<1;1,0>:hf                   {F@4}
        mov (8|M0)               r7.0<1>:f     r3.8<1;1,0>:hf                   {F@4}
        mov (8|M0)               r8.0<1>:f     r2.0<1;1,0>:hf                   {F@4}
        mov (8|M0)               r9.0<1>:f     r2.8<1;1,0>:hf                   {F@4}
        goto (16|M0)                         L20656                  L22392                
L20656:
        join (16|M0)                         L21080                                
L20672:
        cmp (1|M0)    (eq)f1.0   null<1>:d     r5.0<0;1,0>:d     1:w              
(W)     and (1|M0)               f0.0<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
(~f0.0.any16h) goto (16|M0)                  L21080                  L21144                
L20720:
        sel (16|M0)   (lt)f0.0   r10.0<1>:f    (abs)r6.0<1;1,0>:f  448.0:f             {Compacted,F@3}
        sel (16|M0)   (lt)f0.0   r2.0<1>:f     (abs)r8.0<1;1,0>:f  448.0:f             {Compacted,F@2}
        shr (16|M0)              r16.0<1>:ud   r10.0<1;1,0>:ud   0x17:uw              {F@2}
        shr (16|M0)              r14.0<1>:ud   r2.0<1;1,0>:ud    0x17:uw              {F@1}
        sel (16|M0)   (ge)f0.0   r12.0<2>:ub   r16.0<4;1,0>:ub   0x79:uw              {I@2}
        sel (16|M0)   (ge)f0.0   r13.0<2>:ub   r14.0<4;1,0>:ub   0x79:uw              {I@2}
        mov (16|M0)              r16.0<1>:d    r12.0<2;1,0>:ub                  {I@2}
        mov (16|M0)              r14.0<1>:d    r13.0<2;1,0>:ub                  {I@2}
        shl (16|M0)              r16.0<1>:d    r16.0<1;1,0>:d    23:w               {Compacted,I@2}
        shl (16|M0)              r14.0<1>:d    r14.0<1;1,0>:d    23:w               {Compacted,I@2}
        add (16|M0)              r18.0<1>:d    r16.0<1;1,0>:d    -25165824:d               {I@2}
        add (16|M0)              r12.0<1>:d    r14.0<1;1,0>:d    -25165824:d               {I@2}
        add (16|M0)              r16.0<1>:d    -r16.0<1;1,0>:d   -2139095040:d              
        add (16|M0)              r14.0<1>:d    -r14.0<1;1,0>:d   -2139095040:d              
        mul (16|M0)              acc0.0<1>:f   r10.0<1;1,0>:f    r16.0<1;1,0>:f   {Compacted,I@2}
        mul (16|M0)              acc2.0<1>:f   r2.0<1;1,0>:f     r14.0<1;1,0>:f   {Compacted,I@1}
        rnde (16|M0)             acc0.0<1>:f   acc0.0<1;1,0>:f                 
        rnde (16|M0)             acc2.0<1>:f   acc2.0<1;1,0>:f                 
        cmp (16|M0)   (lt)f0.1   null<1>:f     r6.0<1;1,0>:f     0.0:f              
        cmp (16|M0)   (lt)f0.0   null<1>:f     r8.0<1;1,0>:f     0.0:f               {Compacted}
        mul (16|M0)              acc0.0<1>:f   acc0.0<1;1,0>:f   r18.0<1;1,0>:f   {Compacted}
        mul (16|M0)              acc2.0<1>:f   acc2.0<1;1,0>:f   r12.0<1;1,0>:f   {Compacted}
        mov (16|M0)              r14.0<1>:f    (abs)acc0.0<1;1,0>:f             {Compacted}
        mov (16|M0)              r10.0<1>:f    (abs)acc2.0<1;1,0>:f             {Compacted}
(f0.1)  or (16|M0)               r14.0<1>:d    r14.0<1;1,0>:d    -2147483648:d               {F@2}
(f0.0)  or (16|M0)               r10.0<1>:d    r10.0<1;1,0>:d    -2147483648:d               {F@1}
        mov (16|M0)              r6.0<1>:f     r14.0<1;1,0>:f                   {Compacted,I@2}
        mov (16|M0)              r8.0<1>:f     r10.0<1;1,0>:f                   {Compacted,I@1}
        goto (16|M0)                         L21080                  L22392                
L21080:
        join (16|M0)                         L21144                                
L21096:
        cmp (1|M0)    (eq)f1.1   null<1>:d     r5.0<0;1,0>:d     0:w              
(W)     and (1|M0)               f1.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(f1.1.any16h) goto (16|M0)                   L21144                  L22392                
L21144:
        join (16|M0)                         L22392                                
L21160:
        send.slm (1|M0)          null     r56     r6:4    0x0            0x0200D704           {A@1,$12} // wr:1+4, rd:0; store.slm.d64x16t.a32
        and (1|M0)               r1.4<1>:d     r5.0<0;1,0>:d     -2:w               {Compacted}
        and (1|M0)               r1.3<1>:d     r5.0<0;1,0>:d     -3:w               {Compacted}
        mov (1|M0)               r1.0<1>:d     0:w                              
        send.slm (1|M0)          r10      r4      null:0  0x0            0x0240D700           {$10} // wr:1+0, rd:4; load.slm.d64x16t.a32
L21224:
        cmp (1|M0)    (lt)f0.1   null<1>:ud    r1.0<0;1,0>:ud    0x10:uw              {I@1}
(W)     mov (1|M0)               r4.0<1>:w     -1:w                               {$10.src}
        shl (1|M0)               r1.10<1>:w    r1.0<0;1,0>:w     2:w              
        cmp (1|M0)    (eq)f1.0   null<1>:d     r1.4<0;1,0>:d     2:w              
(f0.1)  sel (1|M0)               r4.0<1>:w     r4.0<0;1,0>:w     0:w               {I@3}
        mov (16|M0)              r18.0<1>:f    r10.0<1;1,0>:f                   {Compacted,$10.dst}
(W)     mov (1|M0)               f0.0<1>:uw    r4.0<0;1,0>:uw                   {I@1}
        add (1|M0)               r4.0<1>:w     r1.10<0;1,0>:w    -64:w              
(W)     and (1|M0)               f1.0<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
(f0.1)  sel (1|M0)               r4.0<1>:w     r1.10<0;1,0>:w    r4.0<0;1,0>:w    {I@2}
        mov (16|M0)              r20.0<1>:f    r12.0<1;1,0>:f                   {Compacted}
        add (1|M0)               a0.0<1>:uw    r4.0<0;1,0>:uw    0x240:uw              {A@1}
(f0.0)  sel (16|M0)              r18.0<1>:f    r6.0<1;1,0>:f     r10.0<1;1,0>:f   {Compacted}
(f0.0)  mov (16|M0)              r20.0<1>:f    r8.0<1;1,0>:f                    {Compacted}
        mov (1|M0)               r1.6<1>:f     r[a0.0]<0;1,0>:f                 {F@1}
(~f1.0.any16h) goto (16|M0)                  L21688                  L21688                 {A@1}
L21448:
        mov (1|M0)               r1.12<2>:hf   r[a0.0]<0;1,0>:f                
        cmp (1|M0)    (lt)f0.1   null<1>:f     r[a0.0]<0;1,0>:f  -4.001953e+00:f               {A@1}
        mov (1|M0)               r1.7<1>:f     r1.12<0;1,0>:hf                  {A@1}
        mov (1|M0)               r4.1<1>:ud    0xBD650000:ud                             
        sel (1|M0)    (lt)f0.0   r1.7<1>:f     r1.7<0;1,0>:f     4.0:f               {F@1}
        mov (1|M0)               r4.0<1>:ud    0x3EE50000:ud                             
(~f0.1) sel (1|M0)               r1.7<1>:f     r1.7<0;1,0>:f     -4.0:f               {F@1}
        mad (1|M0)               r4.1<1>:f     r4.0<0;0>:f       r4.1<0;0>:f       (abs)r1.7<0>:f   {A@1}
        mov (1|M0)               r4.0<2>:hf    r4.1<0;1,0>:f                    {F@1}
        mov (1|M0)               r4.0<1>:f     r4.0<0;1,0>:hf                   {F@1}
        mul (1|M0)               r1.7<1>:f     r1.7<0;1,0>:f     r4.0<0;1,0>:f    {F@1}
        mov (1|M0)               r1.14<2>:hf   r1.7<0;1,0>:f                    {F@1}
        add (1|M0)               r1.14<1>:hf   r1.14<0;1,0>:hf   0x3B28:hf              {F@1}
        mul (1|M0)               r1.14<1>:hf   r1.14<0;1,0>:hf   r1.12<0;1,0>:hf  {F@1}
        mov (1|M0)               r1.6<1>:f     r1.14<0;1,0>:hf                  {F@1}
L21688:
        join (16|M0)                         L22344                                
L21704:
        cmp (1|M0)    (eq)f0.0   null<1>:d     r1.3<0;1,0>:d     1:w              
(W)     and (1|M0)               f0.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
(f0.1.any16h) goto (16|M0)                   L21832                  L21832                
L21752:
        cmp (1|M0)    (eq)f1.1   null<1>:d     r5.0<0;1,0>:d     4:w              
        mov (1|M0)               r4.0<2>:hf    r1.6<0;1,0>:f                    {F@1}
        mov (1|M0)               r4.0<1>:f     r4.0<0;1,0>:hf                   {F@1}
(~f1.1) mov (1|M0)               r4.0<1>:f     r1.6<0;1,0>:f                   
        goto (16|M0)                         L21832                  L22232                
L21832:
        join (16|M0)                         L22232                                
L21848:
        cmp (1|M0)    (lt)f1.1   null<1>:f     r1.6<0;1,0>:f     0.0:f               {I@3}
(f1.1)  mov (1|M0)               r1.6<1>:f     -r1.6<0;1,0>:f                  
        sel (1|M0)    (lt)f0.0   r1.6<1>:f     r1.6<0;1,0>:f     448.0:f               {F@1}
        shr (1|M0)               r1.7<1>:ud    r1.6<0;1,0>:ud    0x17:uw              {F@1}
        and (1|M0)               r1.7<1>:ud    r1.7<0;1,0>:ud    0xFF:uw              {I@1}
        sel (1|M0)    (ge)f0.0   r1.7<1>:ud    r1.7<0;1,0>:ud    0x79:uw              {I@1}
        shl (1|M0)               r1.7<1>:ud    r1.7<0;1,0>:ud    0x17:uw              {I@1}
        add (1|M0)               r4.2<1>:ud    -r1.7<0;1,0>:ud   0x80800000:ud              {I@1}
        mul (1|M0)               r4.0<1>:f     r1.6<0;1,0>:f     r4.2<0;1,0>:f    {I@1}
        mov (1|M0)               r4.1<1>:d     r4.0<0;1,0>:f                    {Compacted,F@1}
        mov (1|M0)               r4.0<1>:f     r4.1<0;1,0>:d                    {Compacted,I@1}
        mad (1|M0)               r1.6<1>:f     -r4.0<0;0>:f      r4.2<0;0>:f       r1.6<0>:f        {F@1}
        cmp (1|M0)    (gt)f1.0   null<1>:f     r1.6<0;1,0>:f     0.5:f               {F@1}
(W)     and (1|M0)               f0.0<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
(f0.0.any16h) goto (16|M0)                   L22152                  L22152                
L22072:
        cmp (1|M0)    (lt)f0.1   null<1>:f     r1.6<0;1,0>:f     0.5:f              
        and (1|M0)               r4.1<1>:d     r4.1<0;1,0>:d     1:w               {Compacted}
        add (1|M0)               r4.2<1>:f     r4.0<0;1,0>:f     1.0:f               {Compacted}
(~f0.1) cmp (1|M0)    (eq)f0.1   null<1>:d     r4.1<0;1,0>:d     0:w               {A@1}
(~f0.1) mov (1|M0)               r4.0<1>:f     r4.2<0;1,0>:f                    {F@1}
        goto (16|M0)                         L22152                  L22176                
L22152:
        join (16|M0)                         L22176                                
L22168:
        add (1|M0)               r4.0<1>:f     r4.0<0;1,0>:f     1.0:f               {Compacted,F@1}
L22176:
        join (16|M0)                         L22232                                
L22192:
        add (1|M0)               r1.7<1>:ud    r1.7<0;1,0>:ud    0xFE800000:ud             
        mul (1|M0)               r4.0<1>:f     r4.0<0;1,0>:f     r1.7<0;1,0>:f    {Compacted,A@1}
(f1.1)  mov (1|M0)               r4.0<1>:f     -r4.0<0;1,0>:f                   {F@1}
L22232:
        join (16|M0)                         L22344                                
L22248:
        add (1|M0)               r1.0<1>:ud    r1.0<0;1,0>:ud    0x1:uw             
        add (1|M0)               a0.0<1>:uw    r1.10<0;1,0>:uw   0x1C0:uw              {A@1}
        cmp (1|M0)    (eq)f0.1   null<1>:d     r1.0<0;1,0>:d     32:w               {I@2}
        mov (1|M0)               r[a0.0]<1>:f  r4.0<0;1,0>:f                    {F@1}
(W)     and (1|M0)               f1.1<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(~f1.1.any16h) goto.b (16|M0)                L22344                  L21224                
L22344:
        join (16|M0)                         L22392                                
L22360:
        sync.nop                             null                             {Compacted,$12.src}
        mov (16|M0)              r6.0<1>:ud    r14.0<1;1,0>:ud                  {F@1}
        mov (16|M0)              r8.0<1>:f     r16.0<1;1,0>:f                   {Compacted}
L22392:
        join (16|M0)                         L23736                                
L22408:
        cmp (1|M0)    (eq)f0.0   null<1>:w     r4.24<0;1,0>:b    0:w              
(W)     and (1|M0)               f1.0<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
(f1.0.any16h) goto (16|M0)                   L23592                  L23592                
L22456:
        shl (1|M0)               r5.4<1>:d     r1.1<0;1,0>:d     1:w              
        shl (1|M0)               r1.3<1>:d     r1.2<0;1,0>:d     1:w              
        shr (1|M0)               r1.0<1>:ud    r1.1<0;1,0>:ud    0x1F:uw             
        addc (1|M0)              r5.0<1>:ud    r5.2<0;1,0>:ud    r5.4<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r5.5<1>:d     r1.3<0;1,0>:d     r1.0<0;1,0>:d    {I@2}
        mov (1|M0)               r1.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (8|M0)               r10.0<1>:hf   r8.0<1;1,0>:f                    {F@1}
        add3 (1|M0)              r5.1<1>:d     r1.0<0;0>:d       r5.3<0;0>:d       r5.5<0>:d        {I@1}
        mov (4|M0)               r1.0<1>:w     0x64206420:v                              
        mov (8|M0)               r10.8<1>:hf   r9.0<1;1,0>:f                   
        mov (4|M0)               r1.0<4>:uw    r1.0<1;1,0>:uw                   {I@1}
        mov (8|M0)               r15.0<1>:hf   r6.0<1;1,0>:f                   
        sync.nop                             null                             {Compacted,$12.src}
        mov (4|M0)               r8.0<2>:d     r1.0<4;1,0>:w                    {A@1}
        mov (8|M0)               r15.8<1>:hf   r7.0<1;1,0>:f                   
        asr (4|M0)               r8.1<2>:d     r8.0<2;1,0>:d     31:w               {I@1}
        mov (4|M0)               r1.0<2>:ud    r8.0<2;1,0>:ud                   {I@1}
        mov (4|M0)               r1.1<2>:ud    r8.1<2;1,0>:ud                  
        mov (8|M0)               r16.0<2>:f    r5.0<0;1,0>:f                    {Compacted}
        addc (4|M0)              r3.0<1>:ud    r1.0<2;1,0>:ud    0x8:ud              {AccWrEn,I@1}
        mov (8|M0)               r16.1<2>:f    r5.1<0;1,0>:f                    {Compacted}
        mov (4|M0)               r2.0<1>:ud    acc0.0<1;1,0>:ud                
        mov (4|M0)               r9.0<2>:d     r3.0<1;1,0>:d                    {A@2}
        addc (4|M0)              r3.0<1>:ud    r1.0<2;1,0>:ud    0x10:ud              {AccWrEn}
        add3 (4|M0)              r9.1<2>:d     r2.0<1;0>:d       r1.1<4;2>:d       0:w               {I@3}
        mov (4|M0)               r2.0<1>:ud    acc0.0<1;1,0>:ud                
        mov (4|M0)               r6.0<2>:d     r3.0<1;1,0>:d                    {A@3}
        addc (4|M0)              r3.0<1>:ud    r1.0<2;1,0>:ud    0x18:ud              {AccWrEn}
        add3 (4|M0)              r6.1<2>:d     r2.0<1;0>:d       r1.1<4;2>:d       0:w               {I@3}
        mov (4|M0)               r2.0<1>:ud    acc0.0<1;1,0>:ud                
        mov (4|M0)               r7.0<2>:d     r3.0<1;1,0>:d                    {A@3}
        addc (4|M0)              r3.0<1>:ud    r1.0<2;1,0>:ud    0x20:ud              {AccWrEn}
        add3 (4|M0)              r7.1<2>:d     r2.0<1;0>:d       r1.1<4;2>:d       0:w               {I@3}
        mov (4|M0)               r2.0<1>:ud    acc0.0<1;1,0>:ud                
        mov (4|M0)               r13.0<2>:d    r3.0<1;1,0>:d                    {I@3}
        addc (4|M0)              r3.0<1>:ud    r1.0<2;1,0>:ud    0x28:ud              {AccWrEn}
        add3 (4|M0)              r13.1<2>:d    r2.0<1;0>:d       r1.1<4;2>:d       0:w               {I@3}
        mov (4|M0)               r2.0<1>:ud    acc0.0<1;1,0>:ud                
        mov (4|M0)               r14.0<2>:d    r3.0<1;1,0>:d                    {I@3}
        addc (4|M0)              r3.0<1>:ud    r1.0<2;1,0>:ud    0x30:ud              {AccWrEn}
        add3 (4|M0)              r14.1<2>:d    r2.0<1;0>:d       r1.1<4;2>:d       0:w               {I@3}
        mov (4|M0)               r2.0<1>:ud    acc0.0<1;1,0>:ud                
        mov (4|M0)               r11.0<2>:d    r3.0<1;1,0>:d                    {I@3}
        addc (4|M0)              r3.0<1>:ud    r1.0<2;1,0>:ud    0x38:ud              {AccWrEn}
        add3 (4|M0)              r11.1<2>:d    r2.0<1;0>:d       r1.1<4;2>:d       0:w               {I@3}
        mov (4|M0)               r2.0<1>:ud    acc0.0<1;1,0>:ud                
        mov (4|M0)               r12.0<2>:d    r3.0<1;1,0>:d                    {I@3}
        add3 (4|M0)              r12.1<2>:d    r2.0<1;0>:d       r1.1<4;2>:d       0:w               {I@2}
        addc (8|M0)              r1.0<1>:ud    r16.0<2;1,0>:ud   r8.0<2;1,0>:ud   {AccWrEn,Compacted,A@1}
        mov (8|M0)               r18.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mov (8|M0)               r2.0<2>:d     r1.0<1;1,0>:d                    {I@2}
        mov (8|M0)               r1.0<1>:d     r8.1<2;1,0>:d                   
        add3 (8|M0)              r1.0<1>:d     r18.0<1;0>:d      r16.1<4;2>:d      r1.0<1>:d        {I@1}
        mov (8|M0)               r2.1<2>:d     r1.0<1;1,0>:d                    {I@1}
        addc (8|M0)              r1.0<1>:ud    r16.0<2;1,0>:ud   r6.0<2;1,0>:ud   {AccWrEn,Compacted}
        mov (8|M0)               r8.0<1>:ud    acc0.0<1;1,0>:ud                 {Compacted}
        mov (8|M0)               r4.0<2>:d     r1.0<1;1,0>:d                    {I@2}
        mov (8|M0)               r1.0<1>:d     r6.1<2;1,0>:d                   
        add3 (8|M0)              r1.0<1>:d     r8.0<1;0>:d       r16.1<4;2>:d      r1.0<1>:d        {I@1}
        mov (8|M0)               r4.1<2>:d     r1.0<1;1,0>:d                    {I@1}
        addc (8|M0)              r1.0<1>:ud    r16.0<2;1,0>:ud   r13.0<2;1,0>:ud  {AccWrEn,Compacted}
        mov (8|M0)               r18.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mov (8|M0)               r6.0<2>:d     r1.0<1;1,0>:d                    {I@2}
        mov (8|M0)               r1.0<1>:d     r13.1<2;1,0>:d                  
        add3 (8|M0)              r1.0<1>:d     r18.0<1;0>:d      r16.1<4;2>:d      r1.0<1>:d        {I@1}
        mov (8|M0)               r6.1<2>:d     r1.0<1;1,0>:d                    {I@1}
        addc (8|M0)              r1.0<1>:ud    r16.0<2;1,0>:ud   r11.0<2;1,0>:ud  {AccWrEn,Compacted}
        mov (8|M0)               r13.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mov (8|M0)               r8.0<2>:d     r1.0<1;1,0>:d                    {I@2}
        mov (8|M0)               r1.0<1>:d     r11.1<2;1,0>:d                  
        mov (16|M0)              r11.0<1>:d    r15.0<1;1,0>:uw                 
        add3 (8|M0)              r1.0<1>:d     r13.0<1;0>:d      r16.1<4;2>:d      r1.0<1>:d        {I@2}
        mov (16|M0)              r13.0<1>:d    r10.0<1;1,0>:uw                 
        mov (8|M0)               r8.1<2>:d     r1.0<1;1,0>:d                    {I@2}
        send.ugm (16|M0)         null     r2      r11:2   0x0            0x08000B84           {$1} // wr:4+2, rd:0; store.ugm.d16u32.a64
        send.ugm (16|M0)         null     r6      r13:2   0x0            0x08000B84           {A@1,$3} // wr:4+2, rd:0; store.ugm.d16u32.a64
        goto (16|M0)                         L23592                  L28784                
L23592:
        join (16|M0)                         L23736                                
L23608:
        shl (1|M0)               r5.0<1>:d     r1.1<0;1,0>:d     2:w               {Compacted,$1.src}
        shl (1|M0)               r1.3<1>:d     r1.2<0;1,0>:d     2:w              
        shr (1|M0)               r1.0<1>:ud    r1.1<0;1,0>:ud    0x1E:uw             
        addc (1|M0)              r2.0<1>:ud    r5.4<0;1,0>:ud    r5.0<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r5.1<1>:d     r1.3<0;1,0>:d     r1.0<0;1,0>:d    {I@2}
        mov (1|M0)               r1.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        add3 (1|M0)              r2.1<1>:d     r1.0<0;0>:d       r5.5<0;0>:d       r5.1<0>:d        {I@1}
        send.ugm (1|M0)          null     r2      r6:4    0x0            0x0200E584           {A@1,$8} // wr:1+4, rd:0; store.ugm.d32x32t.a64
        goto (16|M0)                         L23736                  L28784                
L23736:
        join (16|M0)                         L24512                                
L23752:
        cmp (1|M0)    (eq)f0.0   null<1>:d     r3.5<0;1,0>:d     0:w              
(f0.0)  cmp (1|M0)    (eq)f0.0   null<1>:d     r3.4<0;1,0>:d     0:w              
(W)     and (1|M0)               f0.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
(f0.1.any16h) goto (16|M0)                   L24512                  L28784                
L23816:
        sync.allrd                           ($1,$7)                
        shl (1|M0)               r3.3<1>:d     r1.7<0;1,0>:d     12:w               {$5.src}
        shr (1|M0)               r3.2<1>:ud    r1.6<0;1,0>:ud    0x14:uw             
        shl (1|M0)               r3.0<1>:d     r1.6<0;1,0>:d     12:w               {Compacted}
        or (1|M0)                r3.1<1>:d     r3.3<0;1,0>:d     r3.2<0;1,0>:d    {I@2}
        shl (1|M0)               r5.1<1>:ud    r1.5<0;1,0>:ud    0x5:uw             
        shr (1|M0)               r1.0<1>:ud    r3.0<0;1,0>:ud    0x1F:uw              {I@3}
        shl (1|M0)               r1.1<1>:d     r3.0<0;1,0>:d     1:w               {Compacted}
        shl (1|M0)               r1.3<1>:d     r3.1<0;1,0>:d     1:w               {I@4}
        shl (1|M0)               r5.4<1>:d     r5.1<0;1,0>:d     1:w               {I@4}
        or (1|M0)                r1.2<1>:d     r1.3<0;1,0>:d     r1.0<0;1,0>:d    {I@2}
        addc (1|M0)              r1.0<1>:ud    r3.4<0;1,0>:ud    r1.1<0;1,0>:ud   {AccWrEn}
        shr (1|M0)               r1.1<1>:ud    r5.1<0;1,0>:ud    0x1F:uw             
        mov (1|M0)               r3.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        sync.nop                             null                             {Compacted,$8.src}
        addc (1|M0)              r2.0<1>:ud    r1.0<0;1,0>:ud    r5.4<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r5.5<1>:d     r1.1<0;1,0>:d     0:w               {I@3}
        add3 (1|M0)              r5.7<1>:d     r3.0<0;0>:d       r3.5<0;0>:d       r1.2<0>:d        {I@3}
        mov (1|M0)               r1.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r5.4<2>:f     0.0:f                               {I@4}
        mov (1|M0)               r5.2<1>:d     r2.0<0;1,0>:d                   
        add3 (1|M0)              r5.3<1>:d     r1.0<0;0>:d       r5.7<0;0>:d       r5.5<0>:d        {I@2}
        mov (1|M0)               r5.5<2>:f     0.0:f                               {I@1}
L24144:
        or (1|M0)                r5.0<1>:ud    r5.1<0;1,0>:ud    r5.4<0;1,0>:ud   {F@2}
        shl (1|M0)               r5.0<1>:ud    r5.0<0;1,0>:ud    0x2:uw              {I@1}
        add (1|M0)               r5.0<1>:ud    r5.0<0;1,0>:ud    0x1000:uw              {I@1}
        send.slm (1|M0)          r1       r5      null:0  0x0            0x0240D700           {A@1,$0} // wr:1+0, rd:4; load.slm.d64x16t.a32
        shl (1|M0)               r4.1<1>:d     r5.5<0;1,0>:d     1:w               {$0.dst}
        shr (1|M0)               r4.0<1>:ud    r5.4<0;1,0>:ud    0x1F:uw             
        shl (1|M0)               r4.3<1>:d     r5.4<0;1,0>:d     1:w              
        or (1|M0)                r4.4<1>:d     r4.1<0;1,0>:d     r4.0<0;1,0>:d    {I@2}
        addc (1|M0)              r4.0<1>:ud    r5.2<0;1,0>:ud    r4.3<0;1,0>:ud   {AccWrEn,I@2}
        mov (1|M0)               r4.4<2>:hf    r1.0<0;1,0>:f                   
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r1.0<1>:ud    r5.4<0;1,0>:ud    0x1:ud              {AccWrEn,F@1}
        add3 (1|M0)              r4.1<1>:d     r5.0<0;0>:d       r5.3<0;0>:d       r4.4<0>:d        {I@2}
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r5.6<1>:d     r1.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r5.7<1>:d     r5.0<0;0>:d       r5.5<0;0>:d       0:w               {I@2}
        cmp (1|M0)    (eq)f1.1   null<1>:d     r5.7<0;1,0>:d     0:w               {I@1}
        mov (1|M0)               r2.0<1>:d     r4.4<0;1,0>:uw                  
        send.ugm (1|M0)          null     r4      r2:1    0x0            0x04000B84           {A@1,$13} // wr:2+1, rd:0; store.ugm.d16u32.a64
(f1.1)  cmp (1|M0)    (eq)f1.1   null<1>:d     r5.6<0;1,0>:d     32:w              
(W)     and (1|M0)               f0.0<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(f0.0.any16h) goto (16|M0)                   L24512                  L28784                
L24480:
(W)     mov (2|M0)               r5.4<1>:ud    r5.6<1;1,0>:ud                   {$13.src}
        goto.b (16|M0)                       L24512                  L24144                
L24512:
        join (16|M0)                         L25352                                
L24528:
        cmp (1|M0)    (eq)f1.0   null<1>:d     r3.5<0;1,0>:d     0:w              
(f1.0)  cmp (1|M0)    (eq)f1.0   null<1>:d     r3.4<0;1,0>:d     0:w              
(W)     and (1|M0)               f1.1<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
(f1.1.any16h) goto (16|M0)                   L25352                  L28784                
L24592:
        sync.allrd                           ($1,$7)                
        shl (1|M0)               r3.2<1>:d     r1.7<0;1,0>:d     12:w               {$5.src}
        shr (1|M0)               r3.0<1>:ud    r1.6<0;1,0>:ud    0x14:uw             
        shl (1|M0)               r1.0<1>:d     r1.6<0;1,0>:d     12:w               {Compacted}
        or (1|M0)                r1.1<1>:d     r3.2<0;1,0>:d     r3.0<0;1,0>:d    {I@2}
        shl (1|M0)               r1.6<1>:d     r3.6<0;1,0>:d     1:w              
        shl (1|M0)               r1.4<1>:d     r1.1<0;1,0>:d     1:w               {I@2}
        shl (1|M0)               r1.1<1>:d     r1.0<0;1,0>:d     1:w               {Compacted}
        shr (1|M0)               r1.3<1>:ud    r1.0<0;1,0>:ud    0x1F:uw             
        addc (1|M0)              r3.0<1>:ud    r3.4<0;1,0>:ud    r1.1<0;1,0>:ud   {AccWrEn,I@2}
        shr (1|M0)               r3.2<1>:ud    r3.6<0;1,0>:ud    0x1F:uw             
        or (1|M0)                r1.2<1>:d     r1.4<0;1,0>:d     r1.3<0;1,0>:d    {I@3}
        mov (1|M0)               r1.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        sync.allrd                           ($8,$13)                
        addc (1|M0)              r2.0<1>:ud    r3.0<0;1,0>:ud    r1.6<0;1,0>:ud   {AccWrEn,I@4}
        or (1|M0)                r1.7<1>:d     r3.2<0;1,0>:d     0:w               {I@4}
        add3 (1|M0)              r1.4<1>:d     r1.0<0;0>:d       r3.5<0;0>:d       r1.2<0>:d        {I@3}
        mov (1|M0)               r3.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        shr (1|M0)               r1.5<1>:ud    r1.5<0;1,0>:ud    0x2:uw             
        and (1|M0)               r3.1<1>:ud    r3.1<0;1,0>:ud    0xF0:uw             
        mov (1|M0)               r1.6<2>:f     0.0:f                               {I@6}
        mov (1|M0)               r1.1<1>:d     r2.0<0;1,0>:d                   
        add3 (1|M0)              r1.2<1>:d     r3.0<0;0>:d       r1.4<0;0>:d       r1.7<0>:d        {I@4}
        mov (1|M0)               r1.7<2>:f     0.0:f                               {I@1}
L24944:
        shr (1|M0)               r3.2<1>:ud    r1.6<0;1,0>:ud    0x4:uw              {F@2}
        and (1|M0)               r3.0<1>:d     r1.6<0;1,0>:d     15:w               {Compacted}
        bfn.0xEA (1|M0)          r3.2<1>:ud    r3.2<0;0>:ud      r1.5<0;0>:ud      0x3FFC:uw              {I@2} // s0|s1&s2
        shl (1|M0)               r3.4<1>:d     r1.7<0;1,0>:d     1:w               {F@1}
        shl (1|M0)               r3.2<1>:ud    r3.2<0;1,0>:ud    0x8:uw              {I@2}
        bfn.0xFE (1|M0)          r3.0<1>:ud    r3.0<0;0>:ud      r3.2<0;0>:ud      r3.1<0>:ud       {I@1} // s0|s1|s2
        shl (1|M0)               r3.2<1>:d     r1.6<0;1,0>:d     1:w              
        shl (1|M0)               r3.0<1>:ud    r3.0<0;1,0>:ud    0x1:uw              {I@2}
        addc (1|M0)              r4.0<1>:ud    r1.1<0;1,0>:ud    r3.2<0;1,0>:ud   {AccWrEn,I@2}
        add (1|M0)               r1.0<1>:ud    r3.0<0;1,0>:ud    0xE000:uw              {I@2}
        shr (1|M0)               r3.0<1>:ud    r1.6<0;1,0>:ud    0x1F:uw             
        send.slm (1|M0)          r2       r1      null:0  0x0            0x0210B700           {A@2,$6} // wr:1+0, rd:1; load.slm.d64x4t.a32
        or (1|M0)                r3.3<1>:d     r3.4<0;1,0>:d     r3.0<0;1,0>:d    {I@1}
        mov (1|M0)               r3.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        add3 (1|M0)              r4.1<1>:d     r3.0<0;0>:d       r1.2<0;0>:d       r3.3<0>:d        {I@1}
        mov (1|M0)               r2.0<1>:d     r2.0<0;1,0>:uw                   {$6.dst}
        send.ugm (1|M0)          null     r4      r2:1    0x0            0x04000B84           {A@1,$9} // wr:2+1, rd:0; store.ugm.d16u32.a64
        addc (1|M0)              r2.0<1>:ud    r1.6<0;1,0>:ud    0x1:ud              {AccWrEn,$9.src}
        mov (1|M0)               r3.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r3.2<1>:d     r2.0<0;1,0>:d                    {I@2}
        add3 (1|M0)              r3.3<1>:d     r3.0<0;0>:d       r1.7<0;0>:d       0:w               {I@2}
        cmp (1|M0)    (eq)f0.1   null<1>:d     r3.3<0;1,0>:d     0:w               {I@1}
(f0.1)  cmp (1|M0)    (eq)f0.1   null<1>:d     r3.2<0;1,0>:d     64:w              
(W)     and (1|M0)               f1.0<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(f1.0.any16h) goto (16|M0)                   L25352                  L28784                
L25320:
(W)     mov (2|M0)               r1.6<1>:ud    r3.2<1;1,0>:ud                  
        goto.b (16|M0)                       L25352                  L24944                
L25352:
        join (16|M0)                         L26128                                
L25368:
        cmp (1|M0)    (eq)f0.0   null<1>:d     r3.5<0;1,0>:d     0:w              
(f0.0)  cmp (1|M0)    (eq)f0.0   null<1>:d     r3.4<0;1,0>:d     0:w              
(W)     and (1|M0)               f0.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
(f0.1.any16h) goto (16|M0)                   L26128                  L28784                
L25432:
        sync.allrd                           ($1,$5,$7,$10)                
        shl (1|M0)               r3.3<1>:d     r1.7<0;1,0>:d     12:w               {I@7}
        shr (1|M0)               r3.2<1>:ud    r1.6<0;1,0>:ud    0x14:uw             
        shl (1|M0)               r3.0<1>:d     r1.6<0;1,0>:d     12:w               {Compacted}
        or (1|M0)                r3.1<1>:d     r3.3<0;1,0>:d     r3.2<0;1,0>:d    {I@2}
        shl (1|M0)               r5.1<1>:ud    r1.5<0;1,0>:ud    0x6:uw              {$13.src}
        shr (1|M0)               r1.0<1>:ud    r3.0<0;1,0>:ud    0x1F:uw              {I@3}
        shl (1|M0)               r1.1<1>:d     r3.0<0;1,0>:d     1:w               {Compacted}
        shl (1|M0)               r1.3<1>:d     r3.1<0;1,0>:d     1:w               {I@4}
        shl (1|M0)               r5.4<1>:d     r5.1<0;1,0>:d     1:w               {I@4}
        or (1|M0)                r1.2<1>:d     r1.3<0;1,0>:d     r1.0<0;1,0>:d    {I@2}
        addc (1|M0)              r1.0<1>:ud    r3.4<0;1,0>:ud    r1.1<0;1,0>:ud   {AccWrEn}
        shr (1|M0)               r1.1<1>:ud    r5.1<0;1,0>:ud    0x1F:uw             
        mov (1|M0)               r3.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        sync.nop                             null                             {Compacted,$8.src}
        addc (1|M0)              r2.0<1>:ud    r1.0<0;1,0>:ud    r5.4<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r5.5<1>:d     r1.1<0;1,0>:d     0:w               {I@3}
        add3 (1|M0)              r5.7<1>:d     r3.0<0;0>:d       r3.5<0;0>:d       r1.2<0>:d        {I@3}
        mov (1|M0)               r1.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r5.4<2>:f     0.0:f                               {I@4}
        mov (1|M0)               r5.2<1>:d     r2.0<0;1,0>:d                   
        add3 (1|M0)              r5.3<1>:d     r1.0<0;0>:d       r5.7<0;0>:d       r5.5<0>:d        {I@2}
        mov (1|M0)               r5.5<2>:f     0.0:f                               {I@1}
L25760:
        or (1|M0)                r5.0<1>:ud    r5.1<0;1,0>:ud    r5.4<0;1,0>:ud   {F@2}
        shl (1|M0)               r5.0<1>:ud    r5.0<0;1,0>:ud    0x2:uw              {I@1}
        add (1|M0)               r5.0<1>:ud    r5.0<0;1,0>:ud    0xA000:uw              {I@1}
        send.slm (1|M0)          r1       r5      null:0  0x0            0x0240D700           {A@1,$4} // wr:1+0, rd:4; load.slm.d64x16t.a32
        shl (1|M0)               r4.1<1>:d     r5.5<0;1,0>:d     1:w               {$4.dst}
        shr (1|M0)               r4.0<1>:ud    r5.4<0;1,0>:ud    0x1F:uw             
        shl (1|M0)               r4.3<1>:d     r5.4<0;1,0>:d     1:w              
        or (1|M0)                r4.4<1>:d     r4.1<0;1,0>:d     r4.0<0;1,0>:d    {I@2}
        addc (1|M0)              r4.0<1>:ud    r5.2<0;1,0>:ud    r4.3<0;1,0>:ud   {AccWrEn,I@2}
        mov (1|M0)               r4.4<2>:hf    r1.0<0;1,0>:f                   
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r1.0<1>:ud    r5.4<0;1,0>:ud    0x1:ud              {AccWrEn,F@1}
        add3 (1|M0)              r4.1<1>:d     r5.0<0;0>:d       r5.3<0;0>:d       r4.4<0>:d        {I@2}
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r5.6<1>:d     r1.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r5.7<1>:d     r5.0<0;0>:d       r5.5<0;0>:d       0:w               {I@2}
        cmp (1|M0)    (eq)f1.1   null<1>:d     r5.7<0;1,0>:d     0:w               {I@1}
        mov (1|M0)               r2.0<1>:d     r4.4<0;1,0>:uw                  
        send.ugm (1|M0)          null     r4      r2:1    0x0            0x04000B84           {A@1,$2} // wr:2+1, rd:0; store.ugm.d16u32.a64
(f1.1)  cmp (1|M0)    (eq)f1.1   null<1>:d     r5.6<0;1,0>:d     64:w              
(W)     and (1|M0)               f0.0<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(f0.0.any16h) goto (16|M0)                   L26128                  L28784                
L26096:
(W)     mov (2|M0)               r5.4<1>:ud    r5.6<1;1,0>:ud                   {$2.src}
        goto.b (16|M0)                       L26128                  L25760                
L26128:
        join (16|M0)                         L27064                                
L26144:
        cmp (1|M0)    (eq)f1.0   null<1>:d     r3.5<0;1,0>:d     0:w              
(f1.0)  cmp (1|M0)    (eq)f1.0   null<1>:d     r3.4<0;1,0>:d     0:w              
(W)     and (1|M0)               f1.1<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
(f1.1.any16h) goto (16|M0)                   L27064                  L28784                
L26208:
        sync.allrd                           ($2,$8,$13)                
        shl (1|M0)               r2.1<1>:d     r1.7<0;1,0>:d     12:w               {$1.src}
        shr (1|M0)               r2.0<1>:ud    r1.6<0;1,0>:ud    0x14:uw             
        shl (1|M0)               r1.5<1>:d     r1.6<0;1,0>:d     12:w              
        shl (1|M0)               r1.3<1>:d     r5.7<0;1,0>:d     5:w              
        shr (1|M0)               r1.0<1>:ud    r5.6<0;1,0>:ud    0x1B:uw             
        or (1|M0)                r1.6<1>:d     r2.1<0;1,0>:d     r2.0<0;1,0>:d    {I@4}
        or (1|M0)                r1.2<1>:d     r1.3<0;1,0>:d     r1.0<0;1,0>:d    {I@2}
        shr (1|M0)               r1.0<1>:ud    r1.5<0;1,0>:ud    0x1F:uw             
        shl (1|M0)               r1.5<1>:d     r1.5<0;1,0>:d     1:w              
        shl (1|M0)               r1.1<1>:d     r5.6<0;1,0>:d     5:w              
        shl (1|M0)               r1.3<1>:d     r1.6<0;1,0>:d     1:w               {I@5}
        addc (1|M0)              r2.0<1>:ud    r3.4<0;1,0>:ud    r1.5<0;1,0>:ud   {AccWrEn,I@3}
        shl (1|M0)               r2.1<1>:d     r1.1<0;1,0>:d     1:w               {Compacted,I@3}
        or (1|M0)                r1.6<1>:d     r1.3<0;1,0>:d     r1.0<0;1,0>:d    {I@3}
        mov (1|M0)               r1.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        shl (1|M0)               r1.3<1>:d     r1.2<0;1,0>:d     1:w              
        addc (1|M0)              r2.0<1>:ud    r2.0<0;1,0>:ud    r2.1<0;1,0>:ud   {AccWrEn,I@4}
        add3 (1|M0)              r1.6<1>:d     r1.0<0;0>:d       r3.5<0;0>:d       r1.6<0>:d        {I@3}
        shr (1|M0)               r1.0<1>:ud    r1.1<0;1,0>:ud    0x1F:uw             
        mov (1|M0)               r1.7<2>:f     0.0:f                              
        or (1|M0)                r2.2<1>:d     r1.3<0;1,0>:d     r1.0<0;1,0>:d    {I@1}
        mov (1|M0)               r1.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r1.1<1>:d     r2.0<0;1,0>:d                   
        add3 (1|M0)              r1.2<1>:d     r1.0<0;0>:d       r1.6<0;0>:d       r2.2<0>:d        {I@2}
        mov (1|M0)               r1.6<2>:f     0.0:f                               {I@1}
L26600:
        shr (1|M0)               r2.2<1>:ud    r1.6<0;1,0>:ud    0x2:uw              {F@1}
        shl (1|M0)               r2.1<1>:d     r1.6<0;1,0>:d     3:w              
        and (1|M0)               r2.2<1>:ud    r2.2<0;1,0>:ud    0x4:uw              {I@2}
        and (1|M0)               r2.0<1>:d     r1.6<0;1,0>:d     1:w               {Compacted}
        add (1|M0)               r2.2<1>:d     r2.2<0;1,0>:d     r1.4<0;1,0>:d    {I@2}
        and (1|M0)               r2.1<1>:d     r2.1<0;1,0>:d     112:w               {Compacted}
        shl (1|M0)               r2.2<1>:d     r2.2<0;1,0>:d     8:w               {I@2}
        shl (1|M0)               r4.1<1>:d     r1.7<0;1,0>:d     1:w               {$2.src}
        bfn.0xFE (1|M0)          r2.0<1>:ud    r2.0<0;0>:ud      r2.2<0;0>:ud      r2.1<0>:ud       {I@2} // s0|s1|s2
        shr (1|M0)               r4.0<1>:ud    r1.6<0;1,0>:ud    0x1F:uw             
        bfn.0xFE (1|M0)          r2.0<1>:ud    r3.6<0;0>:ud      r2.0<0;0>:ud      r3.7<0>:ud       {I@2} // s0|s1|s2
        shl (1|M0)               r4.2<1>:d     r1.6<0;1,0>:d     1:w              
        shl (1|M0)               r2.0<1>:ud    r2.0<0;1,0>:ud    0x1:uw              {I@2}
        or (1|M0)                r4.3<1>:d     r4.1<0;1,0>:d     r4.0<0;1,0>:d   
        add (1|M0)               r1.0<1>:ud    r2.0<0;1,0>:ud    0x8000:uw              {I@2}
        addc (1|M0)              r4.0<1>:ud    r1.1<0;1,0>:ud    r4.2<0;1,0>:ud   {AccWrEn}
        send.slm (1|M0)          r2       r1      null:0  0x0            0x0210B700           {A@2,$5} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        add3 (1|M0)              r4.1<1>:d     r5.0<0;0>:d       r1.2<0;0>:d       r4.3<0>:d        {I@1}
        mov (1|M0)               r2.0<1>:d     r2.0<0;1,0>:uw                   {$5.dst}
        send.ugm (1|M0)          null     r4      r2:1    0x0            0x04000B84           {A@1,$15} // wr:2+1, rd:0; store.ugm.d16u32.a64
        addc (1|M0)              r4.0<1>:ud    r1.6<0;1,0>:ud    0x1:ud              {AccWrEn,$15.src}
        mov (1|M0)               r2.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r2.2<1>:d     r4.0<0;1,0>:d                    {I@2}
        add3 (1|M0)              r2.3<1>:d     r2.0<0;0>:d       r1.7<0;0>:d       0:w               {I@2}
        cmp (1|M0)    (eq)f0.1   null<1>:d     r2.3<0;1,0>:d     0:w               {I@1}
(f0.1)  cmp (1|M0)    (eq)f0.1   null<1>:d     r2.2<0;1,0>:d     32:w              
(W)     and (1|M0)               f1.0<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(f1.0.any16h) goto (16|M0)                   L27064                  L28784                
L27032:
(W)     mov (2|M0)               r1.6<1>:ud    r2.2<1;1,0>:ud                  
        goto.b (16|M0)                       L27064                  L26600                
L27064:
        join (16|M0)                         L28024                                
L27080:
        cmp (1|M0)    (eq)f0.0   null<1>:d     r3.5<0;1,0>:d     0:w              
(f0.0)  cmp (1|M0)    (eq)f0.0   null<1>:d     r3.4<0;1,0>:d     0:w              
(W)     and (1|M0)               f0.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
(f0.1.any16h) goto (16|M0)                   L28024                  L28784                
L27144:
        sync.allrd                           ($1,$2,$13)                
        shl (1|M0)               r4.2<1>:d     r1.7<0;1,0>:d     12:w               {I@7}
        shr (1|M0)               r4.1<1>:ud    r1.6<0;1,0>:ud    0x14:uw             
        sync.allrd                           ($5,$7)                
        shl (1|M0)               r3.6<1>:d     r1.6<0;1,0>:d     12:w               {$10.src}
        or (1|M0)                r3.7<1>:d     r4.2<0;1,0>:d     r4.1<0;1,0>:d    {I@2}
        mul (1|M0)               r3.0<1>:d     r1.0<0;1,0>:uw    384:w              
        shl (1|M0)               r1.1<1>:d     r3.6<0;1,0>:d     1:w               {I@3}
        shl (1|M0)               r1.3<1>:d     r3.7<0;1,0>:d     1:w               {I@3}
        shr (1|M0)               r1.0<1>:ud    r3.6<0;1,0>:ud    0x1F:uw             
        shl (1|M0)               r3.1<1>:d     r5.6<0;1,0>:d     5:w              
        shl (1|M0)               r4.2<1>:d     r5.7<0;1,0>:d     5:w              
        shr (1|M0)               r4.1<1>:ud    r5.6<0;1,0>:ud    0x1B:uw             
        or (1|M0)                r1.2<1>:d     r1.3<0;1,0>:d     r1.0<0;1,0>:d    {I@4}
        addc (1|M0)              r1.0<1>:ud    r3.4<0;1,0>:ud    r1.1<0;1,0>:ud   {AccWrEn}
        add (1|M0)               r4.0<1>:d     r3.0<0;1,0>:d     4224:w              
        shl (1|M0)               r1.5<1>:d     r3.1<0;1,0>:d     1:w               {I@6}
        or (1|M0)                r3.2<1>:d     r4.2<0;1,0>:d     r4.1<0;1,0>:d    {I@5}
        mov (1|M0)               r3.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        shr (1|M0)               r1.1<1>:ud    r3.1<0;1,0>:ud    0x1F:uw             
        sync.nop                             null                             {Compacted,$8.src}
        addc (1|M0)              r2.0<1>:ud    r1.0<0;1,0>:ud    r1.5<0;1,0>:ud   {AccWrEn,I@4}
        add3 (1|M0)              r1.4<1>:d     r3.0<0;0>:d       r3.5<0;0>:d       r1.2<0>:d        {I@3}
        shl (1|M0)               r1.2<1>:d     r3.2<0;1,0>:d     1:w              
        mov (1|M0)               r1.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        or (1|M0)                r1.6<1>:d     r1.2<0;1,0>:d     r1.1<0;1,0>:d    {I@2}
        mov (1|M0)               r1.3<1>:d     0:w                              
        mov (1|M0)               r1.5<2>:f     0.0:f                              
        mov (1|M0)               r1.1<1>:d     r2.0<0;1,0>:d                   
        add3 (1|M0)              r1.2<1>:d     r1.0<0;0>:d       r1.4<0;0>:d       r1.6<0>:d        {I@3}
        mov (1|M0)               r1.4<2>:f     0.0:f                               {I@1}
L27616:
        sync.nop                             null                             {Compacted,$6.dst}
        sync.allrd                           ($3,$4,$5,$9,$11,$13,$14)                
        send.slm (1|M0)          r5       r4      null:0  0x0            0x0240D700           {$7} // wr:1+0, rd:4; load.slm.d64x16t.a32
        shl (1|M0)               r1.0<1>:w     r1.6<0;1,0>:w     2:w              
        shl (1|M0)               r1.6<1>:d     r1.4<0;1,0>:d     1:w               {F@1}
        add (1|M0)               a0.0<1>:uw    r1.0<0;1,0>:uw    0xA0:uw              {A@1}
        shl (1|M0)               r4.2<1>:d     r1.5<0;1,0>:d     1:w               {$7.src}
        shr (1|M0)               r4.1<1>:ud    r1.4<0;1,0>:ud    0x1F:uw             
        addc (1|M0)              r3.0<1>:ud    r1.1<0;1,0>:ud    r1.6<0;1,0>:ud   {AccWrEn,I@4}
        sync.nop                             null                             {Compacted,$7.dst}
        mov (1|M0)               r1.0<2>:hf    r[a0.0]<0;1,0>:f                 {I@4}
        or (1|M0)                r1.7<1>:d     r4.2<0;1,0>:d     r4.1<0;1,0>:d    {A@1}
        mov (1|M0)               r2.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        sync.nop                             null                             {Compacted,$12.src}
        mov (1|M0)               r6.0<1>:f     r3.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r6.1<1>:d     r2.0<0;0>:d       r1.2<0;0>:d       r1.7<0>:d        {A@1}
        mov (1|M0)               r2.0<1>:d     r1.0<0;1,0>:uw                  
        add (1|M0)               r1.3<1>:d     r1.3<0;1,0>:d     1:w               {Compacted}
        send.ugm (1|M0)          null     r6      r2:1    0x0            0x04000B84           {A@1,$14} // wr:2+1, rd:0; store.ugm.d16u32.a64
        addc (1|M0)              r2.0<1>:ud    r1.4<0;1,0>:ud    0x1:ud              {AccWrEn,$14.src}
        mov (1|M0)               r1.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r1.6<1>:d     r2.0<0;1,0>:d                    {I@2}
        add3 (1|M0)              r1.7<1>:d     r1.0<0;0>:d       r1.5<0;0>:d       0:w               {I@2}
        cmp (1|M0)    (eq)f1.1   null<1>:d     r1.7<0;1,0>:d     0:w               {I@1}
(f1.1)  cmp (1|M0)    (eq)f1.1   null<1>:d     r1.6<0;1,0>:d     32:w              
(W)     and (1|M0)               f0.0<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(f0.0.any16h) goto (16|M0)                   L28024                  L28784                
L27992:
(W)     mov (2|M0)               r1.4<1>:ud    r1.6<1;1,0>:ud                  
        goto.b (16|M0)                       L28024                  L27616                
L28024:
        join (16|M0)                         L28784                                
L28040:
        cmp (1|M0)    (eq)f1.0   null<1>:d     r3.5<0;1,0>:d     0:w              
(f1.0)  cmp (1|M0)    (eq)f1.0   null<1>:d     r3.4<0;1,0>:d     0:w              
(W)     and (1|M0)               f1.1<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
(f1.1.any16h) goto (16|M0)                   L28784                  L28784                
L28104:
        sync.allrd                           ($1,$5,$7)                
        shl (1|M0)               r3.1<1>:d     r1.7<0;1,0>:d     12:w               {$10.src}
        shr (1|M0)               r3.0<1>:ud    r1.6<0;1,0>:ud    0x14:uw             
        shl (1|M0)               r1.2<1>:d     r1.6<0;1,0>:d     12:w              
        or (1|M0)                r1.3<1>:d     r3.1<0;1,0>:d     r3.0<0;1,0>:d    {I@2}
        shr (1|M0)               r1.4<1>:ud    r1.2<0;1,0>:ud    0x1F:uw              {I@2}
        shl (1|M0)               r1.2<1>:d     r1.2<0;1,0>:d     1:w              
        shl (1|M0)               r1.5<1>:d     r1.3<0;1,0>:d     1:w               {I@3}
        sync.allrd                           ($2,$8,$13)                
        addc (1|M0)              r2.0<1>:ud    r3.4<0;1,0>:ud    r1.2<0;1,0>:ud   {AccWrEn,I@2}
        shl (1|M0)               r2.1<1>:d     r5.6<0;1,0>:d     1:w              
        or (1|M0)                r1.3<1>:d     r1.5<0;1,0>:d     r1.4<0;1,0>:d    {I@3}
        mov (1|M0)               r3.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        shr (1|M0)               r1.2<1>:ud    r5.6<0;1,0>:ud    0x1F:uw             
        add3 (1|M0)              r1.6<1>:d     r3.0<0;0>:d       r3.5<0;0>:d       r1.3<0>:d        {I@2}
        shl (1|M0)               r1.3<1>:d     r5.7<0;1,0>:d     1:w              
        addc (1|M0)              r3.0<1>:ud    r2.0<0;1,0>:ud    r2.1<0;1,0>:ud   {AccWrEn}
        or (1|M0)                r2.2<1>:d     r1.3<0;1,0>:d     r1.2<0;1,0>:d    {I@2}
        mov (1|M0)               r2.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r1.7<2>:f     0.0:f                              
        mov (1|M0)               r1.3<1>:d     r3.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r1.4<1>:d     r2.0<0;0>:d       r1.6<0;0>:d       r2.2<0>:d        {I@2}
        mov (1|M0)               r1.6<2>:f     0.0:f                               {I@1}
L28456:
        add (1|M0)               r1.2<1>:d     r1.6<0;1,0>:d     r1.0<0;1,0>:uw   {F@1}
        cmp (1|M0)    (lt)f0.1   null<1>:ud    r1.6<0;1,0>:ud    0x7C0:uw             
        shl (1|M0)               r2.0<1>:d     r1.2<0;1,0>:d     1:w               {Compacted,I@2}
        shl (1|M0)               r4.1<1>:d     r1.7<0;1,0>:d     1:w               {$2.src}
        send.slm (1|M0)          r2       r2      null:0  0x0            0x0210B700           {A@2,$10} // wr:1+0, rd:1; load.slm.d64x4t.a32
        shr (1|M0)               r4.0<1>:ud    r1.6<0;1,0>:ud    0x1F:uw             
        shl (1|M0)               r4.2<1>:d     r1.6<0;1,0>:d     1:w              
(f0.1)  cmp (1|M0)    (eq)f0.1   null<1>:d     r1.7<0;1,0>:d     0:w              
        or (1|M0)                r4.3<1>:d     r4.1<0;1,0>:d     r4.0<0;1,0>:d    {I@3}
        addc (1|M0)              r4.0<1>:ud    r1.3<0;1,0>:ud    r4.2<0;1,0>:ud   {AccWrEn,I@3}
        mov (1|M0)               r3.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r2.0<1>:d     r2.0<0;1,0>:uw                   {$10.dst}
(W)     and (1|M0)               f1.0<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
        add3 (1|M0)              r4.1<1>:d     r3.0<0;0>:d       r1.4<0;0>:d       r4.3<0>:d        {I@3}
        addc (1|M0)              r3.0<1>:ud    r1.6<0;1,0>:ud    0x40:ud              {AccWrEn}
        send.ugm (1|M0)          null     r4      r2:1    0x0            0x04000B84           {A@2,$2} // wr:2+1, rd:0; store.ugm.d16u32.a64
        mov (1|M0)               r2.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$2.src}
        mov (1|M0)               r2.2<1>:d     r3.0<0;1,0>:d                    {I@2}
        add3 (1|M0)              r2.3<1>:d     r2.0<0;0>:d       r1.7<0;0>:d       0:w               {I@2}
(~f1.0.any16h) goto (16|M0)                  L28784                  L28784                
L28752:
(W)     mov (2|M0)               r1.6<1>:ud    r2.2<1;1,0>:ud                   {I@2}
        goto.b (16|M0)                       L28784                  L28456                
L28784:
        join (16|M0)                         L28800                                
L28800:
(W)     mov (8|M0)               r112.0<1>:f   r0.0<1;1,0>:f                    {Compacted}
(W)     send.ugm (1|M0)          r1       r0      null:0  0x0            0x0210641F           {A@3,$10} // wr:1+0, rd:1; fence invalid flush type scoped to tile
(W)     mov (8|M0)               null<1>:ud    r1.0<1;1,0>:ud                   {$10.dst}
(W)     send.gtwy (1|M0)         null     r112    null:0  0x0            0x02000010           {EOT,A@1} // wr:1+0, rd:0; end of thread
L28856:
        mov (1|M0)               r6.1<1>:d     cr0.0<0;1,0>:ud                  {A@1}
        and (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   -1265:w               {A@1}
        or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   1264:w               {A@1}
        mov (1|M0)               r46.5<1>:f    r6.5<0;1,0>:ud                   {A@1}
        mov (1|M0)               r6.0<1>:f     r6.2<0;1,0>:ud                   {Compacted}
        mov (1|M0)               r4.7<1>:ud    r46.5<0;1,0>:f                   {F@2}
        sync.nop                             null                             {Compacted,F@1}
        math.inv (1|M0)          r6.6<1>:f     r6.0<0;1,0>:f                    {$11}
        add (1|M0)               r4.7<1>:ud    r6.5<0;1,0>:ud    -r4.7<0;1,0>:ud  {I@1}
        mov (1|M0)               r6.4<1>:ud    r6.0<0;1,0>:f                   
        mov (1|M0)               r6.7<1>:f     r4.7<0;1,0>:ud                   {I@2}
        mov (1|M0)               r4.7<1>:f     0xB4C00000:f                               {Compacted}
        add (1|M0)               r6.4<1>:ud    r6.2<0;1,0>:ud    -r6.4<0;1,0>:ud  {I@1}
        sync.nop                             null                             {Compacted,$11.dst}
        mad (1|M0)               r6.6<1>:f     r6.6<0;0>:f       r4.7<0;0>:f       r6.6<0>:f        {F@1}
        mov (1|M0)               r46.4<1>:f    r6.4<0;1,0>:ud                   {I@1}
        mul (1|M0)               r4.7<1>:f     r6.6<0;1,0>:f     r46.5<0;1,0>:f   {F@2}
        mov (1|M0)               r6.3<1>:ud    r4.7<0;1,0>:f                    {F@1}
        mov (1|M0)               r4.7<1>:f     r6.3<0;1,0>:ud                   {I@1}
        mad (1|M0)               r46.5<1>:f    r46.5<0;0>:f      r4.7<0;0>:f       -r6.0<0>:f       {F@1}
        mad (1|M0)               r4.7<1>:f     r6.7<0;0>:f       r4.7<0;0>:f       -r46.4<0>:f     
        add (1|M0)               r46.5<1>:f    r46.5<0;1,0>:f    r4.7<0;1,0>:f    {F@1}
        mul (1|M0)               r6.6<1>:f     r6.6<0;1,0>:f     r46.5<0;1,0>:f   {F@1}
        mov (1|M0)               r4.7<1>:ud    r6.6<0;1,0>:f                    {F@1}
        add (1|M0)               r6.3<1>:ud    r6.3<0;1,0>:ud    r4.7<0;1,0>:ud   {I@1}
(W)     mov (1|M0)               r4.14<1>:hf   0x1:hf                              {I@1}
(W)     mul (1|M0)               acc0.0<1>:ud  r6.3<0;1,0>:ud    r6.4<0;1,0>:uw  
        mach (1|M0)              r6.0<1>:ud    r6.3<0;1,0>:ud    r6.2<0;1,0>:ud  
        add (1|M0)               r6.5<1>:ud    r6.5<0;1,0>:ud    -r6.0<0;1,0>:ud  {I@1}
        cmp (1|M0)    (ge)f1.0   null<1>:ud    r6.5<0;1,0>:ud    r6.2<0;1,0>:ud   {I@1}
(f1.0)  sel (1|M0)               r4.7<1>:d     r4.14<0;1,0>:w    0:w               {F@1}
        add (1|M0)               r6.0<1>:ud    r6.3<0;1,0>:ud    r4.7<0;1,0>:ud   {I@1}
        mov (1|M0)               cr0.0<1>:ud   r6.1<0;1,0>:d                    {A@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        ret (16|M0)                          r46.2                            {A@1}
L29400:
(W)     mov (1|M0)               r79.2<1>:w    r79.4<0;1,0>:ub                 
        mov (1|M0)               r79.2<1>:f    r79.2<0;1,0>:w                   {I@1}
(W)     mov (1|M0)               r79.2<1>:w    r79.6<0;1,0>:ub                  {F@1}
        mul (1|M0)               r79.2<1>:f    r79.2<0;1,0>:f    1.000001e+00:f              
        mov (1|M0)               r79.1<1>:f    r79.2<0;1,0>:w                   {I@1}
        math.inv (1|M0)          r79.1<1>:f    r79.1<0;1,0>:f                   {@1,$12}
        mul (1|M0)               r79.1<1>:f    r79.1<0;1,0>:f    r79.2<0;1,0>:f   {$12.dst}
        mov (1|M0)               r79.2<2>:uw   r79.1<0;1,0>:f                   {F@1}
        mov (1|M0)               r46.16<2>:b   r79.4<0;1,0>:b                   {I@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        ret (16|M0)                          r46.6                            {A@1}
L29592:
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
