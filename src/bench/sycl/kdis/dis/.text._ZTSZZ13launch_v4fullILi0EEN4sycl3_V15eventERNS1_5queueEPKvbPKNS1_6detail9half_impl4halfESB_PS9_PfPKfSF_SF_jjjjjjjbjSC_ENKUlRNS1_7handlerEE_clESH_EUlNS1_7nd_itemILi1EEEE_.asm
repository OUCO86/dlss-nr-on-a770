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
(W)     mov (2|M0)               r74.0<1>:ud   r3.6<1;1,0>:ud                   {$1.dst}
        and (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   -1265:w               {A@1}
        or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   1216:w               {A@1}
        and (1|M0)               r38.0<1>:d    r2.4<0;1,0>:d     -2:w               {Compacted,A@1}
        mov (1|M0)               r3.1<1>:d     r1.0<0;1,0>:uw                   {$0.dst}
        cmp (1|M0)    (eq)f1.1   null<1>:d     r38.0<0;1,0>:d    0xFFFE:uw              {I@2}
        and (1|M0)               r1.6<2>:b     r3.0<0;1,0>:b     1:w              
        and (1|M0)               r1.12<2>:b    r5.12<0;1,0>:b    1:w              
        mov (1|M0)               r1.2<1>:d     r0.1<0;1,0>:ud                  
(W)     and (1|M0)               f1.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
        mov (1|M0)               r3.6<1>:d     r0.1<0;1,0>:ud                  
        mov (1|M0)               r3.7<1>:d     0:w                              
        mov (1|M0)               r3.4<1>:d     r1.0<0;1,0>:uw                  
        mov (1|M0)               r3.5<1>:d     0:w                              
        and (1|M0)               r1.7<1>:d     r1.0<0;1,0>:uw    15:w              
        shr (1|M0)               r38.2<1>:ud   r3.1<0;1,0>:ud    0x4:uw              {I@7}
(f1.1.any16h) goto (16|M0)                   L34280                  L34280                
L440:
        mov (1|M0)               r6.5<1>:d     r1.2<0;1,0>:d                    {I@7}
        mov (1|M0)               r6.2<1>:d     r2.5<0;1,0>:d                   
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r38.0         L34368                                 {A@1}
L520:
        shl (1|M0)               r1.6<1>:d     r6.0<0;1,0>:d     3:w               {Compacted}
        shr (1|M0)               r38.1<1>:ud   r3.1<0;1,0>:ud    0x3:uw             
(W)     mul (1|M0)               acc0.0<1>:d   r6.0<0;1,0>:d     r2.10<0;1,0>:uw  {Compacted}
        add3 (1|M0)              r1.6<1>:ud    r1.6<0;0>:ud      r38.1<0;0>:ud     -r2.2<0>:ud      {I@2}
        mach (1|M0)              r6.0<1>:d     r6.0<0;1,0>:d     r2.5<0;1,0>:d    {Compacted}
        cmp (1|M0)    (gt)f0.1   null<1>:d     r1.6<0;1,0>:d     -1:w               {I@2}
        add (1|M0)               r1.2<1>:d     r1.2<0;1,0>:d     -r6.0<0;1,0>:d   {I@2}
        and (1|M0)               r1.4<1>:d     r1.0<0;1,0>:uw    7:w              
        shl (1|M0)               r1.5<1>:ud    r38.1<0;1,0>:ud   0x7:uw             
        shl (1|M0)               r1.2<1>:d     r1.2<0;1,0>:d     3:w               {I@3}
(W)     and (1|M0)               f1.0<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
        shl (1|M0)               r38.5<1>:ud   r38.2<0;1,0>:ud   0x9:uw             
        and (1|M0)               r1.5<1>:ud    r1.5<0;1,0>:ud    0x80:uw              {I@4}
        add3 (1|M0)              r1.2<1>:d     r1.2<0;0>:d       r1.4<0;0>:d       -r2.3<0>:d       {I@4}
        shl (1|M0)               r1.4<1>:d     r1.4<0;1,0>:d     4:w              
        mov (16|M0)              r8.0<1>:f     0.0:f                               {Compacted}
        mov (16|M0)              r6.0<1>:f     0.0:f                               {Compacted}
        bfn.0xFE (1|M0)          r38.5<1>:ud   r1.4<0;0>:ud      r1.5<0;0>:ud      r38.5<0>:ud      {I@1} // s0|s1|s2
(~f1.0.any16h) goto (16|M0)                  L1440                  L1440                
L784:
        cmp (1|M0)    (gt)f1.0   null<1>:d     r1.2<0;1,0>:d     -1:w              
        cmp (1|M0)    (lt)f1.1   null<1>:d     r1.2<0;1,0>:d     r2.7<0;1,0>:d   
(W)     mov (1|M0)               r38.0<1>:hf   0x1:hf                             
(f1.0)  cmp (1|M0)    (lt)f1.0   null<1>:d     r1.6<0;1,0>:d     r2.6<0;1,0>:d   
(f1.0)  sel (1|M0)               r38.1<1>:uw   r38.0<0;1,0>:uw   0x0:uw              {F@1}
(f1.1)  sel (1|M0)               r38.0<1>:uw   r38.0<0;1,0>:uw   0x0:uw             
        and (1|M0)    (ne)f1.0   null<1>:uw    r38.1<0;1,0>:uw   r38.0<0;1,0>:uw  {I@1}
(W)     and (1|M0)               f0.0<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
(~f0.0.any16h) goto (16|M0)                  L1440                  L1440                
L928:
        mul (1|M0)               acc0.0<1>:ud  r1.6<0;1,0>:ud    r2.14<0;1,0>:uw 
        mach (1|M0)              r7.0<1>:ud    r1.6<0;1,0>:ud    r2.7<0;1,0>:ud   {AccWrEn}
        cmp (1|M0)    (eq)f0.0   null<1>:w     r1.6<0;1,0>:b     0:w              
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r8.0<1>:ud    r6.0<0;1,0>:ud    r1.2<0;1,0>:ud   {AccWrEn,I@1}
(W)     and (1|M0)               f1.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
        mov (1|M0)               r38.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        shr (1|M0)               r8.1<1>:ud    r8.0<0;1,0>:ud    0x1B:uw              {I@3}
        add3 (1|M0)              r38.4<1>:d    r38.0<0;0>:d      r7.0<0;0>:d       0:w               {I@2}
        shl (1|M0)               r38.3<1>:d    r8.0<0;1,0>:d     5:w               {Compacted}
        shl (1|M0)               r8.2<1>:d     r38.4<0;1,0>:d    5:w               {I@2}
        or (1|M0)                r38.4<1>:d    r8.2<0;1,0>:d     r8.1<0;1,0>:d    {I@1}
(f1.1.any16h) goto (16|M0)                   L1304                  L1304                
L1112:
        shr (1|M0)               r38.0<1>:ud   r38.3<0;1,0>:ud   0x1F:uw             
        shl (1|M0)               r38.3<1>:d    r38.3<0;1,0>:d    1:w               {Compacted}
        shl (1|M0)               r38.6<1>:d    r38.4<0;1,0>:d    1:w               {I@4}
        addc (1|M0)              r6.0<1>:ud    r3.2<0;1,0>:ud    r38.3<0;1,0>:ud  {AccWrEn,I@2}
        or (1|M0)                r38.4<1>:d    r38.6<0;1,0>:d    r38.0<0;1,0>:d   {I@2}
        mov (1|M0)               r38.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        add3 (1|M0)              r6.1<1>:d     r38.0<0;0>:d      r3.3<0;0>:d       r38.4<0>:d       {I@1}
        send.ugm (1|M0)          r10      r6      null:0  0x0            0x0220C780           {A@1,$2} // wr:1+0, rd:2; load.ugm.d64x8t.a64
        mov (8|M0)               r6.0<1>:f     r10.0<1;1,0>:hf                  {$2.dst}
        mov (8|M0)               r7.0<1>:f     r10.8<1;1,0>:hf                 
        mov (8|M0)               r8.0<1>:f     r11.0<1;1,0>:hf                 
        mov (8|M0)               r9.0<1>:f     r11.8<1;1,0>:hf                 
        goto (16|M0)                         L1304                  L1440                
L1304:
        join (16|M0)                         L1440                                
L1320:
        shl (1|M0)               r10.1<1>:d    r38.4<0;1,0>:d    2:w               {F@4}
        shr (1|M0)               r10.0<1>:ud   r38.3<0;1,0>:ud   0x1E:uw             
        shl (1|M0)               r10.2<1>:d    r38.3<0;1,0>:d    2:w              
        or (1|M0)                r10.3<1>:d    r10.1<0;1,0>:d    r10.0<0;1,0>:d   {I@2}
        addc (1|M0)              r10.0<1>:ud   r3.2<0;1,0>:ud    r10.2<0;1,0>:ud  {AccWrEn,I@2}
        mov (1|M0)               r38.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        add3 (1|M0)              r10.1<1>:d    r38.0<0;0>:d      r3.3<0;0>:d       r10.3<0>:d       {I@1}
        send.ugm (1|M0)          r6       r10     null:0  0x0            0x0240D780           {A@1,$3} // wr:1+0, rd:4; load.ugm.d64x16t.a64
L1440:
        join (16|M0)                         L34280                                
L1456:
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
        shl (1|M0)               r40.0<1>:ud   r38.5<0;1,0>:ud   0x1:uw             
(f1.1)  or (16|M0)               r16.0<1>:d    r16.0<1;1,0>:d    -2147483648:d               {F@2}
(f1.0)  or (16|M0)               r12.0<1>:d    r12.0<1;1,0>:d    -2147483648:d               {F@1}
        or (1|M0)                r38.0<1>:ud   r40.0<0;1,0>:ud   0x200:uw              {I@3}
        mov (8|M0)               r6.0<1>:hf    r16.0<1;1,0>:f                   {I@3}
        mov (8|M0)               r6.8<1>:hf    r17.0<1;1,0>:f                  
        mov (8|M0)               r7.0<1>:hf    r12.0<1;1,0>:f                   {I@2}
        mov (8|M0)               r7.8<1>:hf    r13.0<1;1,0>:f                  
        send.slm (1|M0)          null     r40     r6:1    0x0            0x0200B704           {A@3,$4} // wr:1+1, rd:0; store.slm.d64x4t.a32
        send.slm (1|M0)          null     r38     r7:1    0x0            0x0200B704           {A@1,$5} // wr:1+1, rd:0; store.slm.d64x4t.a32
        sync.nop                             null                             {Compacted,$4.src}
(W)     send.slm (1|M0)          r6       r0      null:0  0x0            0x0210001F           {$6} // wr:1+0, rd:1; fence.slm.none.group
(W)     mov (8|M0)               null<1>:ud    r6.0<1;1,0>:ud                   {$6.dst}
(W)     mov (1|M0)               r6.2<1>:f     0.0:f                               {Compacted,I@1}
(W)     mov (2|M0)               r6.10<1>:ub   r0.11<0;1,0>:ub                  {F@1}
(W)     send.gtwy (1|M0)         null     r6      null:0  0x0            0x02000004           {A@1,$7} // wr:1+0, rd:0; signal barrier
(W)     sync.bar                             null                            
        cmp (1|M0)    (eq)f0.0   null<1>:d     r2.4<0;1,0>:d     101:w              
(W)     and (1|M0)               f1.0<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
(f1.0.any16h) goto (16|M0)                   L34280                  L34280                
L2056:
        addc (1|M0)              r6.0<1>:ud    r74.0<0;1,0>:ud   0x100:ud              {AccWrEn,$7.src}
        send.ugm (1|M0)          r22      r74     null:0  0x0            0x0280E780           {$8} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$5.src}
        add3 (1|M0)              r6.1<1>:d     r7.0<0;0>:d       r74.1<0;0>:d      0:w               {I@1}
        shl (1|M0)               r3.0<1>:ud    r38.2<0;1,0>:ud   0xA:uw             
        send.ugm (1|M0)          r41      r6      null:0  0x0            0x0280E780           {A@2,$9} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        or (1|M0)                r101.0<1>:ud  r3.0<0;1,0>:ud    0x100:uw              {I@1}
        send.slm (1|M0)          r57      r3      null:0  0x0            0x0280E700           {$10} // wr:1+0, rd:8; load.slm.d64x32t.a32
        send.slm (1|M0)          r91      r101    null:0  0x0            0x0280E700           {A@1,$11} // wr:1+0, rd:8; load.slm.d64x32t.a32
        mov (16|M0)              r30.0<1>:ud   0x0:ud                             
        mov (16|M0)              r32.0<1>:ud   0x0:ud                             
        mov (16|M0)              r34.0<1>:ud   0x0:ud                             
        mov (16|M0)              r36.0<1>:ud   0x0:ud                             
        mov (16|M0)              r8.0<1>:ud    0x0:ud                             
        mov (16|M0)              r10.0<1>:ud   0x0:ud                             
        mov (16|M0)              r12.0<1>:ud   0x0:ud                             
        mov (16|M0)              r6.0<1>:ud    0x0:ud                              {$9.src}
        mov (16|M0)              r14.0<1>:ud   0x0:ud                             
        mov (16|M0)              r16.0<1>:ud   0x0:ud                             
        mov (16|M0)              r18.0<1>:ud   0x0:ud                             
        mov (16|M0)              r20.0<1>:ud   0x0:ud                             
        or (1|M0)                r100.0<1>:ud  r3.0<0;1,0>:ud    0x200:uw             
        or (1|M0)                r99.0<1>:ud   r3.0<0;1,0>:ud    0x300:uw             
        send.slm (1|M0)          r83      r100    null:0  0x0            0x0280E700           {A@2,$12} // wr:1+0, rd:8; load.slm.d64x32t.a32
        send.slm (1|M0)          r75      r99     null:0  0x0            0x0280E700           {A@1,$13} // wr:1+0, rd:8; load.slm.d64x32t.a32
        shl (1|M0)               r38.0<1>:ud   r38.2<0;1,0>:ud   0xC:uw             
        add (1|M0)               r39.0<1>:ud   r38.0<0;1,0>:ud   0x7000:uw              {I@1}
        add (1|M0)               r73.0<1>:ud   r38.0<0;1,0>:ud   0x7800:uw             
        shl (1|M0)               r38.0<1>:ud   r38.2<0;1,0>:ud   0xB:uw             
        add (1|M0)               r38.0<1>:ud   r38.0<0;1,0>:ud   0x5000:uw              {I@1}
        sync.allwr                           ($8,$10,$11)                
(W)     sync.nop                             null                            
        dpas.8x8 (8|M0)          r30:f         null:f            r30:hf            r30.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r30:f         r30:f             r22:hf            r57.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r6:f          r6:f              r22:hf            r91.0:hf         {$8}
        mov (16|M0)              r22.0<1>:ud   0x0:ud                              {$8.src}
        mov (16|M0)              r24.0<1>:ud   0x0:ud                             
        mov (16|M0)              r26.0<1>:ud   0x0:ud                             
        mov (16|M0)              r28.0<1>:ud   0x0:ud                             
        sync.nop                             null                             {Compacted,A@1}
        sync.nop                             null                             {Compacted,$9.dst}
        dpas.8x8 (8|M0)          r14:f         null:f            r14:hf            r14.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r14:f         r14:f             r41:hf            r57.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r22:f         r22:f             r41:hf            r91.0:hf         {$9}
        addc (1|M0)              r42.0<1>:ud   r74.0<0;1,0>:ud   0xC00:ud              {AccWrEn,$9.src}
        mov (1|M0)               r41.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r49.0<1>:d    r42.0<0;1,0>:d                   {I@2}
        add3 (1|M0)              r49.1<1>:d    r41.0<0;0>:d      r74.1<0;0>:d      0:w               {I@2}
        addc (1|M0)              r50.0<1>:ud   r74.0<0;1,0>:ud   0xD00:ud              {AccWrEn}
        send.ugm (1|M0)          r41      r49     null:0  0x0            0x0280E780           {A@2,$14} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        mov (1|M0)               r49.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,$14.src}
        mov (1|M0)               r65.0<1>:d    r50.0<0;1,0>:d                   {I@2}
        add3 (1|M0)              r65.1<1>:d    r49.0<0;0>:d      r74.1<0;0>:d      0:w               {I@2}
        send.ugm (1|M0)          r49      r65     null:0  0x0            0x0280E780           {A@1,$15} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        sync.allwr                           ($8,$12,$13,$14)                
        dpas.8x8 (8|M0)          r30:f         null:f            r30:hf            r30.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r30:f         r30:f             r41:hf            r83.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r6:f          r6:f              r41:hf            r75.0:hf         {$12}
        addc (1|M0)              r41.0<1>:ud   r74.0<0;1,0>:ud   0x200:ud              {AccWrEn,$12.src}
        mov (16|M0)              r43.0<1>:ud   0x0:ud                             
        mov (1|M0)               r42.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        add3 (1|M0)              r41.1<1>:d    r42.0<0;0>:d      r74.1<0;0>:d      0:w               {I@1}
        mov (16|M0)              r45.0<1>:ud   0x0:ud                             
        send.ugm (1|M0)          r65      r41     null:0  0x0            0x0280E780           {A@2,$0} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        addc (1|M0)              r41.0<1>:ud   r74.0<0;1,0>:ud   0x300:ud              {AccWrEn,$0.src}
        mov (16|M0)              r47.0<1>:ud   0x0:ud                             
        mov (1|M0)               r42.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        add3 (1|M0)              r41.1<1>:d    r42.0<0;0>:d      r74.1<0;0>:d      0:w               {I@1}
        sync.nop                             null                             {Compacted,$15.dst}
        dpas.8x8 (8|M0)          r14:f         r14:f             r49:hf            r83.0:hf         {$9}
        send.ugm (1|M0)          r102     r41     null:0  0x0            0x0280E780           {A@1,$1} // wr:1+0, rd:8; load.ugm.d64x32t.a64
(W)     sync.nop                             null                            
        dpas.8x8 (8|M0)          r22:f         null:f            r22:hf            r22.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r22:f         r22:f             r49:hf            r75.0:hf         {$2}
        mov (16|M0)              r41.0<1>:ud   0x0:ud                              {$1.src}
        mov (16|M0)              r49.0<1>:ud   0x0:ud                              {$2.src}
        mov (16|M0)              r51.0<1>:ud   0x0:ud                             
        mov (16|M0)              r53.0<1>:ud   0x0:ud                             
        mov (16|M0)              r55.0<1>:f    0.0:f                               {Compacted}
        sync.nop                             null                             {Compacted,A@1}
        sync.allwr                           ($0,$1)                
        dpas.8x8 (8|M0)          r49:f         r49:f             r65:hf            r57.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r41:f         r41:f             r102:hf           r57.0:hf         {$0}
        mov (16|M0)              r57.0<1>:f    0.0:f                               {Compacted,$0.src}
        mov (16|M0)              r59.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r61.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r63.0<1>:f    0.0:f                               {Compacted}
        sync.nop                             null                             {Compacted,A@1}
        dpas.8x8 (8|M0)          r57:f         r57:f             r65:hf            r91.0:hf         {$3}
        mov (16|M0)              r65.0<1>:f    0.0:f                               {Compacted,$3.src}
        mov (16|M0)              r67.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r69.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r71.0<1>:f    0.0:f                               {Compacted}
        sync.nop                             null                             {Compacted,A@1}
        dpas.8x8 (8|M0)          r65:f         r65:f             r102:hf           r91.0:hf         {$4}
        addc (1|M0)              r92.0<1>:ud   r74.0<0;1,0>:ud   0xE00:ud              {AccWrEn,$4.src}
        mov (1|M0)               r91.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r102.0<1>:d   r92.0<0;1,0>:d                   {I@2}
        addc (1|M0)              r103.0<1>:ud  r74.0<0;1,0>:ud   0xF00:ud              {AccWrEn}
        add3 (1|M0)              r102.1<1>:d   r91.0<0;0>:d      r74.1<0;0>:d      0:w               {I@3}
        mov (1|M0)               r110.0<1>:d   r103.0<0;1,0>:d                  {I@2}
        send.ugm (1|M0)          r91      r102    null:0  0x0            0x0280E780           {A@2,$5} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        mov (1|M0)               r102.0<1>:ud  acc0.0<0;1,0>:ud                 {Compacted,$5.src}
        add3 (1|M0)              r110.1<1>:d   r102.0<0;0>:d     r74.1<0;0>:d      0:w               {I@1}
        send.ugm (1|M0)          r102     r110    null:0  0x0            0x0280E780           {A@1,$6} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        sync.allwr                           ($0,$3,$4,$5,$6)                
(W)     sync.nop                             null                            
        dpas.8x8 (8|M0)          r49:f         null:f            r49:hf            r49.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r49:f         r49:f             r91:hf            r83.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r57:f         r57:f             r91:hf            r75.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r41:f         r41:f             r102:hf           r83.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r65:f         r65:f             r102:hf           r75.0:hf         {$0}
        sync.nop                             null                             {Compacted,$0.src}
        mov (8|M0)               r81.0<1>:f    r30.0<1;1,0>:f                   {Compacted,$12.dst}
        mov (8|M0)               r82.0<1>:f    r14.0<1;1,0>:f                   {Compacted,$9.dst}
        mov (8|M0)               r79.0<1>:f    r6.0<1;1,0>:f                    {Compacted}
        send.slm (1|M0)          null     r39     r81:2   0x0            0x0200C704           {A@2,$7} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r80.0<1>:f    r22.0<1;1,0>:f                   {Compacted,$2.dst}
        or (1|M0)                r81.0<1>:ud   r39.0<0;1,0>:ud   0x400:uw              {$7.src}
        mov (8|M0)               r77.0<1>:f    r49.0<1;1,0>:f                   {Compacted,$0.dst}
        send.slm (1|M0)          null     r81     r79:2   0x0            0x0200C704           {A@1,$8} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r78.0<1>:f    r41.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r79.0<1>:ud   r39.0<0;1,0>:ud   0x40:uw              {$8.src}
        or (1|M0)                r83.0<1>:ud   r39.0<0;1,0>:ud   0x80:uw             
        send.slm (1|M0)          null     r79     r77:2   0x0            0x0200C704           {A@1,$9} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r75.0<1>:f    r57.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r82.0<1>:f    r15.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r76.0<1>:f    r65.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r81.0<1>:f    r31.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r77.0<1>:ud   r39.0<0;1,0>:ud   0x440:uw              {$9.src}
        mov (8|M0)               r80.0<1>:f    r23.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r77     r75:2   0x0            0x0200C704           {A@1,$10} // wr:1+2, rd:0; store.slm.d64x8t.a32
        send.slm (1|M0)          null     r83     r81:2   0x0            0x0200C704           {A@2,$11} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r79.0<1>:f    r7.0<1;1,0>:f                    {Compacted}
        or (1|M0)                r81.0<1>:ud   r39.0<0;1,0>:ud   0x480:uw              {$11.src}
        mov (8|M0)               r78.0<1>:f    r42.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r81     r79:2   0x0            0x0200C704           {A@1,$12} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r77.0<1>:f    r50.0<1;1,0>:f                   {Compacted,$10.src}
        or (1|M0)                r79.0<1>:ud   r39.0<0;1,0>:ud   0xC0:uw              {$12.src}
        mov (8|M0)               r75.0<1>:f    r58.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r79     r77:2   0x0            0x0200C704           {A@1,$13} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r76.0<1>:f    r66.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r82.0<1>:f    r16.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r83.0<1>:ud   r39.0<0;1,0>:ud   0x100:uw             
        mov (8|M0)               r81.0<1>:f    r32.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r77.0<1>:ud   r39.0<0;1,0>:ud   0x4C0:uw              {$13.src}
        mov (8|M0)               r80.0<1>:f    r24.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r77     r75:2   0x0            0x0200C704           {A@1,$14} // wr:1+2, rd:0; store.slm.d64x8t.a32
        send.slm (1|M0)          null     r83     r81:2   0x0            0x0200C704           {A@2,$15} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r79.0<1>:f    r8.0<1;1,0>:f                    {Compacted}
        or (1|M0)                r81.0<1>:ud   r39.0<0;1,0>:ud   0x500:uw              {$15.src}
        mov (8|M0)               r78.0<1>:f    r43.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r81     r79:2   0x0            0x0200C704           {A@1,$0} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r77.0<1>:f    r51.0<1;1,0>:f                   {Compacted,$14.src}
        or (1|M0)                r79.0<1>:ud   r39.0<0;1,0>:ud   0x140:uw              {$0.src}
        mov (8|M0)               r75.0<1>:f    r59.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r79     r77:2   0x0            0x0200C704           {A@1,$1} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r76.0<1>:f    r67.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r82.0<1>:f    r17.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r83.0<1>:ud   r39.0<0;1,0>:ud   0x180:uw             
        mov (8|M0)               r81.0<1>:f    r33.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r77.0<1>:ud   r39.0<0;1,0>:ud   0x540:uw              {$1.src}
        mov (8|M0)               r80.0<1>:f    r25.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r77     r75:2   0x0            0x0200C704           {A@1,$2} // wr:1+2, rd:0; store.slm.d64x8t.a32
        send.slm (1|M0)          null     r83     r81:2   0x0            0x0200C704           {A@2,$3} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r79.0<1>:f    r9.0<1;1,0>:f                    {Compacted}
        or (1|M0)                r81.0<1>:ud   r39.0<0;1,0>:ud   0x580:uw              {$3.src}
        mov (8|M0)               r78.0<1>:f    r44.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r81     r79:2   0x0            0x0200C704           {A@1,$4} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r77.0<1>:f    r52.0<1;1,0>:f                   {Compacted,$2.src}
        or (1|M0)                r79.0<1>:ud   r39.0<0;1,0>:ud   0x1C0:uw              {$4.src}
        mov (8|M0)               r75.0<1>:f    r60.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r79     r77:2   0x0            0x0200C704           {A@1,$5} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r76.0<1>:f    r68.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r82.0<1>:f    r18.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r83.0<1>:ud   r39.0<0;1,0>:ud   0x200:uw             
        mov (8|M0)               r81.0<1>:f    r34.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r77.0<1>:ud   r39.0<0;1,0>:ud   0x5C0:uw              {$5.src}
        mov (8|M0)               r80.0<1>:f    r26.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r77     r75:2   0x0            0x0200C704           {A@1,$6} // wr:1+2, rd:0; store.slm.d64x8t.a32
        send.slm (1|M0)          null     r83     r81:2   0x0            0x0200C704           {A@2,$7} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r79.0<1>:f    r10.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r81.0<1>:ud   r39.0<0;1,0>:ud   0x600:uw              {$7.src}
        mov (8|M0)               r78.0<1>:f    r45.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r81     r79:2   0x0            0x0200C704           {A@1,$8} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r77.0<1>:f    r53.0<1;1,0>:f                   {Compacted,$6.src}
        or (1|M0)                r79.0<1>:ud   r39.0<0;1,0>:ud   0x240:uw              {$8.src}
        mov (8|M0)               r75.0<1>:f    r61.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r79     r77:2   0x0            0x0200C704           {A@1,$9} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r76.0<1>:f    r69.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r82.0<1>:f    r19.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r83.0<1>:ud   r39.0<0;1,0>:ud   0x280:uw             
        mov (8|M0)               r81.0<1>:f    r35.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r77.0<1>:ud   r39.0<0;1,0>:ud   0x640:uw              {$9.src}
        mov (8|M0)               r80.0<1>:f    r27.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r77     r75:2   0x0            0x0200C704           {A@1,$10} // wr:1+2, rd:0; store.slm.d64x8t.a32
        send.slm (1|M0)          null     r83     r81:2   0x0            0x0200C704           {A@2,$11} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r79.0<1>:f    r11.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r81.0<1>:ud   r39.0<0;1,0>:ud   0x680:uw              {$11.src}
        mov (8|M0)               r78.0<1>:f    r46.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r81     r79:2   0x0            0x0200C704           {A@1,$12} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r77.0<1>:f    r54.0<1;1,0>:f                   {Compacted,$10.src}
        or (1|M0)                r79.0<1>:ud   r39.0<0;1,0>:ud   0x2C0:uw              {$12.src}
        mov (8|M0)               r75.0<1>:f    r62.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r79     r77:2   0x0            0x0200C704           {A@1,$13} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r76.0<1>:f    r70.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r82.0<1>:f    r20.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r83.0<1>:ud   r39.0<0;1,0>:ud   0x300:uw             
        mov (8|M0)               r81.0<1>:f    r36.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r77.0<1>:ud   r39.0<0;1,0>:ud   0x6C0:uw              {$13.src}
        mov (8|M0)               r80.0<1>:f    r28.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r77     r75:2   0x0            0x0200C704           {A@1,$14} // wr:1+2, rd:0; store.slm.d64x8t.a32
        send.slm (1|M0)          null     r83     r81:2   0x0            0x0200C704           {A@2,$15} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r79.0<1>:f    r12.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r81.0<1>:ud   r39.0<0;1,0>:ud   0x700:uw              {$15.src}
        mov (8|M0)               r78.0<1>:f    r47.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r81     r79:2   0x0            0x0200C704           {A@1,$0} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r77.0<1>:f    r55.0<1;1,0>:f                   {Compacted,$14.src}
        or (1|M0)                r79.0<1>:ud   r39.0<0;1,0>:ud   0x340:uw              {$0.src}
        mov (8|M0)               r30.0<1>:f    r37.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r79     r77:2   0x0            0x0200C704           {A@1,$1} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r31.0<1>:f    r21.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r8.0<1>:ud    r39.0<0;1,0>:ud   0x380:uw             
        mov (8|M0)               r75.0<1>:f    r63.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r76.0<1>:f    r71.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r77.0<1>:ud   r39.0<0;1,0>:ud   0x740:uw              {$1.src}
        mov (8|M0)               r6.0<1>:f     r13.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r77     r75:2   0x0            0x0200C704           {A@1,$2} // wr:1+2, rd:0; store.slm.d64x8t.a32
        send.slm (1|M0)          null     r8      r30:2   0x0            0x0200C704           {$3} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r7.0<1>:f     r29.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r8.0<1>:ud    r39.0<0;1,0>:ud   0x780:uw              {$3.src}
        mov (8|M0)               r9.0<1>:f     r56.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r8      r6:2    0x0            0x0200C704           {A@1,$4} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r10.0<1>:f    r48.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r6.0<1>:ud    r39.0<0;1,0>:ud   0x3C0:uw              {$4.src}
        mov (8|M0)               r11.0<1>:f    r64.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r6      r9:2    0x0            0x0200C704           {A@1,$5} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r12.0<1>:f    r72.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r6.0<1>:ud    r39.0<0;1,0>:ud   0x7C0:uw              {$5.src}
        mov (16|M0)              r32.0<1>:f    0.0:f                               {Compacted}
        send.slm (1|M0)          null     r6      r11:2   0x0            0x0200C704           {A@1,$6} // wr:1+2, rd:0; store.slm.d64x8t.a32
        addc (1|M0)              r6.0<1>:ud    r74.0<0;1,0>:ud   0x400:ud              {AccWrEn,$6.src}
        mov (16|M0)              r34.0<1>:f    0.0:f                               {Compacted}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        add3 (1|M0)              r6.1<1>:d     r7.0<0;0>:d       r74.1<0;0>:d      0:w               {I@1}
        send.slm (1|M0)          r57      r3      null:0  0x0            0x0280E700           {$7} // wr:1+0, rd:8; load.slm.d64x32t.a32
        send.ugm (1|M0)          r22      r6      null:0  0x0            0x0280E780           {A@1,$8} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        addc (1|M0)              r6.0<1>:ud    r74.0<0;1,0>:ud   0x500:ud              {AccWrEn,$8.src}
        send.slm (1|M0)          r91      r101    null:0  0x0            0x0280E700           {$9} // wr:1+0, rd:8; load.slm.d64x32t.a32
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        add3 (1|M0)              r6.1<1>:d     r7.0<0;0>:d       r74.1<0;0>:d      0:w               {I@1}
        mov (16|M0)              r36.0<1>:f    0.0:f                               {Compacted}
        sync.nop                             null                             {Compacted,I@1}
        send.ugm (1|M0)          r41      r6      null:0  0x0            0x0280E780           {$10} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        mov (16|M0)              r30.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r8.0<1>:f     0.0:f                               {Compacted}
        mov (16|M0)              r10.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r12.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r6.0<1>:f     0.0:f                               {Compacted,$10.src}
        mov (16|M0)              r14.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r16.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r18.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r20.0<1>:f    0.0:f                               {Compacted}
        send.slm (1|M0)          r83      r100    null:0  0x0            0x0280E700           {$11} // wr:1+0, rd:8; load.slm.d64x32t.a32
        send.slm (1|M0)          r75      r99     null:0  0x0            0x0280E700           {$12} // wr:1+0, rd:8; load.slm.d64x32t.a32
        sync.nop                             null                             {Compacted,F@5}
        sync.allwr                           ($7,$8,$9)                
        dpas.8x8 (8|M0)          r30:f         null:f            r30:hf            r30.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r30:f         r30:f             r22:hf            r57.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r6:f          r6:f              r22:hf            r91.0:hf         {$7}
        mov (16|M0)              r22.0<1>:f    0.0:f                               {Compacted,$7.src}
        mov (16|M0)              r24.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r26.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r28.0<1>:f    0.0:f                               {Compacted}
        sync.nop                             null                             {Compacted,A@1}
        sync.nop                             null                             {Compacted,$10.dst}
        dpas.8x8 (8|M0)          r14:f         null:f            r14:hf            r14.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r14:f         r14:f             r41:hf            r57.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r22:f         r22:f             r41:hf            r91.0:hf         {$10}
        addc (1|M0)              r42.0<1>:ud   r74.0<0;1,0>:ud   0x1000:ud              {AccWrEn,$10.src}
        mov (1|M0)               r41.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r49.0<1>:d    r42.0<0;1,0>:d                   {I@2}
        add3 (1|M0)              r49.1<1>:d    r41.0<0;0>:d      r74.1<0;0>:d      0:w               {I@2}
        addc (1|M0)              r50.0<1>:ud   r74.0<0;1,0>:ud   0x1100:ud              {AccWrEn}
        send.ugm (1|M0)          r41      r49     null:0  0x0            0x0280E780           {A@2,$13} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        mov (1|M0)               r49.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,$13.src}
        mov (1|M0)               r65.0<1>:d    r50.0<0;1,0>:d                   {I@2}
        add3 (1|M0)              r65.1<1>:d    r49.0<0;0>:d      r74.1<0;0>:d      0:w               {I@2}
        send.ugm (1|M0)          r49      r65     null:0  0x0            0x0280E780           {A@1,$14} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        sync.allwr                           ($7,$11,$12,$13)                
(W)     sync.nop                             null                            
        dpas.8x8 (8|M0)          r30:f         null:f            r30:hf            r30.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r30:f         r30:f             r41:hf            r83.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r6:f          r6:f              r41:hf            r75.0:hf         {$11}
        addc (1|M0)              r41.0<1>:ud   r74.0<0;1,0>:ud   0x600:ud              {AccWrEn,$11.src}
        mov (16|M0)              r43.0<1>:f    0.0:f                               {Compacted}
        mov (1|M0)               r42.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        add3 (1|M0)              r41.1<1>:d    r42.0<0;0>:d      r74.1<0;0>:d      0:w               {I@1}
        mov (16|M0)              r45.0<1>:f    0.0:f                               {Compacted}
        sync.nop                             null                             {Compacted,I@1}
        send.ugm (1|M0)          r65      r41     null:0  0x0            0x0280E780           {$15} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        addc (1|M0)              r41.0<1>:ud   r74.0<0;1,0>:ud   0x700:ud              {AccWrEn,$15.src}
        mov (16|M0)              r47.0<1>:f    0.0:f                               {Compacted}
        mov (1|M0)               r42.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        add3 (1|M0)              r41.1<1>:d    r42.0<0;0>:d      r74.1<0;0>:d      0:w               {I@1}
        sync.nop                             null                             {Compacted,$14.dst}
        dpas.8x8 (8|M0)          r14:f         r14:f             r49:hf            r83.0:hf         {$10}
        send.ugm (1|M0)          r102     r41     null:0  0x0            0x0280E780           {A@1,$0} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        dpas.8x8 (8|M0)          r22:f         null:f            r22:hf            r22.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r22:f         r22:f             r49:hf            r75.0:hf         {$1}
        mov (16|M0)              r41.0<1>:f    0.0:f                               {Compacted,$0.src}
        mov (16|M0)              r49.0<1>:f    0.0:f                               {Compacted,$1.src}
        mov (16|M0)              r51.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r53.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r55.0<1>:f    0.0:f                               {Compacted}
        sync.nop                             null                             {Compacted,A@1}
        sync.allwr                           ($0,$15)                
        dpas.8x8 (8|M0)          r49:f         r49:f             r65:hf            r57.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r41:f         r41:f             r102:hf           r57.0:hf         {$15}
        mov (16|M0)              r57.0<1>:f    0.0:f                               {Compacted,$15.src}
        mov (16|M0)              r59.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r61.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r63.0<1>:f    0.0:f                               {Compacted}
        sync.nop                             null                             {Compacted,A@1}
        dpas.8x8 (8|M0)          r57:f         r57:f             r65:hf            r91.0:hf         {$2}
        mov (16|M0)              r65.0<1>:f    0.0:f                               {Compacted,$2.src}
        mov (16|M0)              r67.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r69.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r71.0<1>:f    0.0:f                               {Compacted}
        sync.nop                             null                             {Compacted,A@1}
        dpas.8x8 (8|M0)          r65:f         r65:f             r102:hf           r91.0:hf         {$3}
        addc (1|M0)              r92.0<1>:ud   r74.0<0;1,0>:ud   0x1200:ud              {AccWrEn,$3.src}
        mov (1|M0)               r91.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r102.0<1>:d   r92.0<0;1,0>:d                   {I@2}
        addc (1|M0)              r103.0<1>:ud  r74.0<0;1,0>:ud   0x1300:ud              {AccWrEn}
        add3 (1|M0)              r102.1<1>:d   r91.0<0;0>:d      r74.1<0;0>:d      0:w               {I@3}
        mov (1|M0)               r110.0<1>:d   r103.0<0;1,0>:d                  {I@2}
        send.ugm (1|M0)          r91      r102    null:0  0x0            0x0280E780           {A@2,$4} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        mov (1|M0)               r102.0<1>:ud  acc0.0<0;1,0>:ud                 {Compacted,$4.src}
        add3 (1|M0)              r110.1<1>:d   r102.0<0;0>:d     r74.1<0;0>:d      0:w               {I@1}
        send.ugm (1|M0)          r102     r110    null:0  0x0            0x0280E780           {A@1,$5} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        sync.allwr                           ($2,$3,$4,$5,$15)                
(W)     sync.nop                             null                            
(W)     sync.nop                             null                            
        dpas.8x8 (8|M0)          r49:f         null:f            r49:hf            r49.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r49:f         r49:f             r91:hf            r83.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r57:f         r57:f             r91:hf            r75.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r41:f         r41:f             r102:hf           r83.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r65:f         r65:f             r102:hf           r75.0:hf         {$15}
        sync.nop                             null                             {Compacted,$15.src}
        mov (8|M0)               r81.0<1>:f    r30.0<1;1,0>:f                   {Compacted,$11.dst}
        mov (8|M0)               r82.0<1>:f    r14.0<1;1,0>:f                   {Compacted,$10.dst}
        mov (8|M0)               r79.0<1>:f    r6.0<1;1,0>:f                    {Compacted}
        send.slm (1|M0)          null     r73     r81:2   0x0            0x0200C704           {A@2,$6} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r80.0<1>:f    r22.0<1;1,0>:f                   {Compacted,$1.dst}
        or (1|M0)                r81.0<1>:ud   r73.0<0;1,0>:ud   0x400:uw              {$6.src}
        mov (8|M0)               r77.0<1>:f    r49.0<1;1,0>:f                   {Compacted,$15.dst}
        send.slm (1|M0)          null     r81     r79:2   0x0            0x0200C704           {A@1,$7} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r78.0<1>:f    r41.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r79.0<1>:ud   r73.0<0;1,0>:ud   0x40:uw              {$7.src}
        or (1|M0)                r83.0<1>:ud   r73.0<0;1,0>:ud   0x80:uw             
        send.slm (1|M0)          null     r79     r77:2   0x0            0x0200C704           {A@1,$8} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r75.0<1>:f    r57.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r82.0<1>:f    r15.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r76.0<1>:f    r65.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r81.0<1>:f    r31.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r77.0<1>:ud   r73.0<0;1,0>:ud   0x440:uw              {$8.src}
        mov (8|M0)               r80.0<1>:f    r23.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r77     r75:2   0x0            0x0200C704           {A@1,$9} // wr:1+2, rd:0; store.slm.d64x8t.a32
        send.slm (1|M0)          null     r83     r81:2   0x0            0x0200C704           {A@2,$10} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r79.0<1>:f    r7.0<1;1,0>:f                    {Compacted}
        or (1|M0)                r81.0<1>:ud   r73.0<0;1,0>:ud   0x480:uw              {$10.src}
        mov (8|M0)               r78.0<1>:f    r42.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r81     r79:2   0x0            0x0200C704           {A@1,$11} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r77.0<1>:f    r50.0<1;1,0>:f                   {Compacted,$9.src}
        or (1|M0)                r79.0<1>:ud   r73.0<0;1,0>:ud   0xC0:uw              {$11.src}
        mov (8|M0)               r75.0<1>:f    r58.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r79     r77:2   0x0            0x0200C704           {A@1,$12} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r76.0<1>:f    r66.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r82.0<1>:f    r16.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r83.0<1>:ud   r73.0<0;1,0>:ud   0x100:uw             
        mov (8|M0)               r81.0<1>:f    r32.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r77.0<1>:ud   r73.0<0;1,0>:ud   0x4C0:uw              {$12.src}
        mov (8|M0)               r80.0<1>:f    r24.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r77     r75:2   0x0            0x0200C704           {A@1,$13} // wr:1+2, rd:0; store.slm.d64x8t.a32
        send.slm (1|M0)          null     r83     r81:2   0x0            0x0200C704           {A@2,$14} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r79.0<1>:f    r8.0<1;1,0>:f                    {Compacted}
        or (1|M0)                r81.0<1>:ud   r73.0<0;1,0>:ud   0x500:uw              {$14.src}
        mov (8|M0)               r78.0<1>:f    r43.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r81     r79:2   0x0            0x0200C704           {A@1,$15} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r77.0<1>:f    r51.0<1;1,0>:f                   {Compacted,$13.src}
        or (1|M0)                r79.0<1>:ud   r73.0<0;1,0>:ud   0x140:uw              {$15.src}
        mov (8|M0)               r75.0<1>:f    r59.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r79     r77:2   0x0            0x0200C704           {A@1,$0} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r76.0<1>:f    r67.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r82.0<1>:f    r17.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r83.0<1>:ud   r73.0<0;1,0>:ud   0x180:uw             
        mov (8|M0)               r81.0<1>:f    r33.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r77.0<1>:ud   r73.0<0;1,0>:ud   0x540:uw              {$0.src}
        mov (8|M0)               r80.0<1>:f    r25.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r77     r75:2   0x0            0x0200C704           {A@1,$1} // wr:1+2, rd:0; store.slm.d64x8t.a32
        send.slm (1|M0)          null     r83     r81:2   0x0            0x0200C704           {A@2,$2} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r79.0<1>:f    r9.0<1;1,0>:f                    {Compacted}
        or (1|M0)                r81.0<1>:ud   r73.0<0;1,0>:ud   0x580:uw              {$2.src}
        mov (8|M0)               r78.0<1>:f    r44.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r81     r79:2   0x0            0x0200C704           {A@1,$3} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r77.0<1>:f    r52.0<1;1,0>:f                   {Compacted,$1.src}
        or (1|M0)                r79.0<1>:ud   r73.0<0;1,0>:ud   0x1C0:uw              {$3.src}
        mov (8|M0)               r75.0<1>:f    r60.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r79     r77:2   0x0            0x0200C704           {A@1,$4} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r76.0<1>:f    r68.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r82.0<1>:f    r18.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r83.0<1>:ud   r73.0<0;1,0>:ud   0x200:uw             
        mov (8|M0)               r81.0<1>:f    r34.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r77.0<1>:ud   r73.0<0;1,0>:ud   0x5C0:uw              {$4.src}
        mov (8|M0)               r80.0<1>:f    r26.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r77     r75:2   0x0            0x0200C704           {A@1,$5} // wr:1+2, rd:0; store.slm.d64x8t.a32
        send.slm (1|M0)          null     r83     r81:2   0x0            0x0200C704           {A@2,$6} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r79.0<1>:f    r10.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r81.0<1>:ud   r73.0<0;1,0>:ud   0x600:uw              {$6.src}
        mov (8|M0)               r78.0<1>:f    r45.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r81     r79:2   0x0            0x0200C704           {A@1,$7} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r77.0<1>:f    r53.0<1;1,0>:f                   {Compacted,$5.src}
        or (1|M0)                r79.0<1>:ud   r73.0<0;1,0>:ud   0x240:uw              {$7.src}
        mov (8|M0)               r75.0<1>:f    r61.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r79     r77:2   0x0            0x0200C704           {A@1,$8} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r76.0<1>:f    r69.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r82.0<1>:f    r19.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r83.0<1>:ud   r73.0<0;1,0>:ud   0x280:uw             
        mov (8|M0)               r81.0<1>:f    r35.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r77.0<1>:ud   r73.0<0;1,0>:ud   0x640:uw              {$8.src}
        mov (8|M0)               r80.0<1>:f    r27.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r77     r75:2   0x0            0x0200C704           {A@1,$9} // wr:1+2, rd:0; store.slm.d64x8t.a32
        send.slm (1|M0)          null     r83     r81:2   0x0            0x0200C704           {A@2,$10} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r79.0<1>:f    r11.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r81.0<1>:ud   r73.0<0;1,0>:ud   0x680:uw              {$10.src}
        mov (8|M0)               r78.0<1>:f    r46.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r81     r79:2   0x0            0x0200C704           {A@1,$11} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r77.0<1>:f    r54.0<1;1,0>:f                   {Compacted,$9.src}
        or (1|M0)                r79.0<1>:ud   r73.0<0;1,0>:ud   0x2C0:uw              {$11.src}
        mov (8|M0)               r75.0<1>:f    r62.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r79     r77:2   0x0            0x0200C704           {A@1,$12} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r76.0<1>:f    r70.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r82.0<1>:f    r20.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r83.0<1>:ud   r73.0<0;1,0>:ud   0x300:uw             
        mov (8|M0)               r81.0<1>:f    r36.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r77.0<1>:ud   r73.0<0;1,0>:ud   0x6C0:uw              {$12.src}
        mov (8|M0)               r80.0<1>:f    r28.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r77     r75:2   0x0            0x0200C704           {A@1,$13} // wr:1+2, rd:0; store.slm.d64x8t.a32
        send.slm (1|M0)          null     r83     r81:2   0x0            0x0200C704           {A@2,$14} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r79.0<1>:f    r12.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r81.0<1>:ud   r73.0<0;1,0>:ud   0x700:uw              {$14.src}
        mov (8|M0)               r78.0<1>:f    r47.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r81     r79:2   0x0            0x0200C704           {A@1,$15} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r77.0<1>:f    r55.0<1;1,0>:f                   {Compacted,$13.src}
        or (1|M0)                r79.0<1>:ud   r73.0<0;1,0>:ud   0x340:uw              {$15.src}
        mov (8|M0)               r30.0<1>:f    r37.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r79     r77:2   0x0            0x0200C704           {A@1,$0} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r31.0<1>:f    r21.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r8.0<1>:ud    r73.0<0;1,0>:ud   0x380:uw             
        mov (8|M0)               r75.0<1>:f    r63.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r76.0<1>:f    r71.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r77.0<1>:ud   r73.0<0;1,0>:ud   0x740:uw              {$0.src}
        mov (8|M0)               r6.0<1>:f     r13.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r77     r75:2   0x0            0x0200C704           {A@1,$1} // wr:1+2, rd:0; store.slm.d64x8t.a32
        send.slm (1|M0)          null     r8      r30:2   0x0            0x0200C704           {$2} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r7.0<1>:f     r29.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r8.0<1>:ud    r73.0<0;1,0>:ud   0x780:uw              {$2.src}
        mov (8|M0)               r9.0<1>:f     r56.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r8      r6:2    0x0            0x0200C704           {A@1,$3} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r10.0<1>:f    r48.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r6.0<1>:ud    r73.0<0;1,0>:ud   0x3C0:uw              {$3.src}
        mov (8|M0)               r11.0<1>:f    r64.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r6      r9:2    0x0            0x0200C704           {A@1,$4} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r12.0<1>:f    r72.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r6.0<1>:ud    r73.0<0;1,0>:ud   0x7C0:uw              {$4.src}
        mov (16|M0)              r32.0<1>:f    0.0:f                               {Compacted}
        send.slm (1|M0)          null     r6      r11:2   0x0            0x0200C704           {A@1,$5} // wr:1+2, rd:0; store.slm.d64x8t.a32
        addc (1|M0)              r6.0<1>:ud    r74.0<0;1,0>:ud   0x800:ud              {AccWrEn,$5.src}
        mov (16|M0)              r34.0<1>:f    0.0:f                               {Compacted}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        add3 (1|M0)              r6.1<1>:d     r7.0<0;0>:d       r74.1<0;0>:d      0:w               {I@1}
        send.slm (1|M0)          r57      r3      null:0  0x0            0x0280E700           {$6} // wr:1+0, rd:8; load.slm.d64x32t.a32
        send.ugm (1|M0)          r22      r6      null:0  0x0            0x0280E780           {A@1,$7} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        addc (1|M0)              r6.0<1>:ud    r74.0<0;1,0>:ud   0x900:ud              {AccWrEn,$7.src}
        send.slm (1|M0)          r75      r101    null:0  0x0            0x0280E700           {$8} // wr:1+0, rd:8; load.slm.d64x32t.a32
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        add3 (1|M0)              r6.1<1>:d     r7.0<0;0>:d       r74.1<0;0>:d      0:w               {I@1}
        mov (16|M0)              r36.0<1>:f    0.0:f                               {Compacted}
        sync.nop                             null                             {Compacted,I@1}
        send.ugm (1|M0)          r41      r6      null:0  0x0            0x0280E780           {$9} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        mov (16|M0)              r30.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r8.0<1>:f     0.0:f                               {Compacted}
        mov (16|M0)              r10.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r12.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r6.0<1>:f     0.0:f                               {Compacted,$9.src}
        mov (16|M0)              r14.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r16.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r18.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r20.0<1>:f    0.0:f                               {Compacted}
        send.slm (1|M0)          r83      r100    null:0  0x0            0x0280E700           {$10} // wr:1+0, rd:8; load.slm.d64x32t.a32
        send.slm (1|M0)          r91      r99     null:0  0x0            0x0280E700           {$11} // wr:1+0, rd:8; load.slm.d64x32t.a32
        sync.nop                             null                             {Compacted,F@5}
        sync.allwr                           ($6,$7,$8)                
        dpas.8x8 (8|M0)          r30:f         null:f            r30:hf            r30.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r30:f         r30:f             r22:hf            r57.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r6:f          r6:f              r22:hf            r75.0:hf         {$6}
        mov (16|M0)              r22.0<1>:f    0.0:f                               {Compacted,$6.src}
        mov (16|M0)              r24.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r26.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r28.0<1>:f    0.0:f                               {Compacted}
        sync.nop                             null                             {Compacted,A@1}
        sync.nop                             null                             {Compacted,$9.dst}
        dpas.8x8 (8|M0)          r14:f         null:f            r14:hf            r14.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r14:f         r14:f             r41:hf            r57.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r22:f         r22:f             r41:hf            r75.0:hf         {$9}
        addc (1|M0)              r42.0<1>:ud   r74.0<0;1,0>:ud   0x1400:ud              {AccWrEn,$9.src}
        mov (1|M0)               r41.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r49.0<1>:d    r42.0<0;1,0>:d                   {I@2}
        add3 (1|M0)              r49.1<1>:d    r41.0<0;0>:d      r74.1<0;0>:d      0:w               {I@2}
        addc (1|M0)              r50.0<1>:ud   r74.0<0;1,0>:ud   0x1500:ud              {AccWrEn}
        send.ugm (1|M0)          r41      r49     null:0  0x0            0x0280E780           {A@2,$12} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        mov (1|M0)               r49.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,$12.src}
        mov (1|M0)               r65.0<1>:d    r50.0<0;1,0>:d                   {I@2}
        add3 (1|M0)              r65.1<1>:d    r49.0<0;0>:d      r74.1<0;0>:d      0:w               {I@2}
        send.ugm (1|M0)          r49      r65     null:0  0x0            0x0280E780           {A@1,$13} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        sync.allwr                           ($6,$10,$11,$12)                
(W)     sync.nop                             null                            
        dpas.8x8 (8|M0)          r30:f         null:f            r30:hf            r30.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r30:f         r30:f             r41:hf            r83.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r6:f          r6:f              r41:hf            r91.0:hf         {$10}
        addc (1|M0)              r41.0<1>:ud   r74.0<0;1,0>:ud   0xA00:ud              {AccWrEn,$10.src}
        mov (16|M0)              r43.0<1>:f    0.0:f                               {Compacted}
        mov (1|M0)               r42.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        add3 (1|M0)              r41.1<1>:d    r42.0<0;0>:d      r74.1<0;0>:d      0:w               {I@1}
        mov (16|M0)              r45.0<1>:f    0.0:f                               {Compacted}
        sync.nop                             null                             {Compacted,I@1}
        send.ugm (1|M0)          r65      r41     null:0  0x0            0x0280E780           {$14} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        addc (1|M0)              r41.0<1>:ud   r74.0<0;1,0>:ud   0xB00:ud              {AccWrEn,$14.src}
        mov (16|M0)              r47.0<1>:f    0.0:f                               {Compacted}
        mov (1|M0)               r42.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        add3 (1|M0)              r41.1<1>:d    r42.0<0;0>:d      r74.1<0;0>:d      0:w               {I@1}
        sync.nop                             null                             {Compacted,$13.dst}
        dpas.8x8 (8|M0)          r14:f         r14:f             r49:hf            r83.0:hf         {$9}
        send.ugm (1|M0)          r99      r41     null:0  0x0            0x0280E780           {A@1,$15} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        dpas.8x8 (8|M0)          r22:f         null:f            r22:hf            r22.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r22:f         r22:f             r49:hf            r91.0:hf         {$0}
        mov (16|M0)              r41.0<1>:f    0.0:f                               {Compacted,$15.src}
        mov (16|M0)              r49.0<1>:f    0.0:f                               {Compacted,$0.src}
        mov (16|M0)              r51.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r53.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r55.0<1>:f    0.0:f                               {Compacted}
        sync.nop                             null                             {Compacted,A@1}
        sync.allwr                           ($14,$15)                
        dpas.8x8 (8|M0)          r49:f         r49:f             r65:hf            r57.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r41:f         r41:f             r99:hf            r57.0:hf         {$14}
        mov (16|M0)              r57.0<1>:f    0.0:f                               {Compacted,$14.src}
        mov (16|M0)              r59.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r61.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r63.0<1>:f    0.0:f                               {Compacted}
        sync.nop                             null                             {Compacted,A@1}
        dpas.8x8 (8|M0)          r57:f         r57:f             r65:hf            r75.0:hf         {$1}
        mov (16|M0)              r65.0<1>:f    0.0:f                               {Compacted,$1.src}
        mov (16|M0)              r67.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r69.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r71.0<1>:f    0.0:f                               {Compacted}
        sync.nop                             null                             {Compacted,A@1}
        dpas.8x8 (8|M0)          r65:f         r65:f             r99:hf            r75.0:hf         {$2}
        addc (1|M0)              r76.0<1>:ud   r74.0<0;1,0>:ud   0x1600:ud              {AccWrEn,$2.src}
        mov (1|M0)               r75.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r99.0<1>:d    r76.0<0;1,0>:d                   {I@2}
        addc (1|M0)              r100.0<1>:ud  r74.0<0;1,0>:ud   0x1700:ud              {AccWrEn}
        add3 (1|M0)              r99.1<1>:d    r75.0<0;0>:d      r74.1<0;0>:d      0:w               {I@3}
        mov (1|M0)               r107.0<1>:d   r100.0<0;1,0>:d                  {I@2}
        send.ugm (1|M0)          r75      r99     null:0  0x0            0x0280E780           {A@2,$3} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        mov (1|M0)               r99.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,$3.src}
        add3 (1|M0)              r107.1<1>:d   r99.0<0;0>:d      r74.1<0;0>:d      0:w               {I@1}
        send.ugm (1|M0)          r99      r107    null:0  0x0            0x0280E780           {A@1,$4} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        sync.allwr                           ($1,$3,$14)                
(W)     sync.nop                             null                            
(W)     sync.nop                             null                            
        dpas.8x8 (8|M0)          r49:f         null:f            r49:hf            r49.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r49:f         r49:f             r75:hf            r83.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r57:f         r57:f             r75:hf            r91.0:hf         {$14}
        sync.nop                             null                             {Compacted,$14.src}
        mov (8|M0)               r80.0<1>:f    r30.0<1;1,0>:f                   {Compacted,$10.dst}
        mov (8|M0)               r81.0<1>:f    r14.0<1;1,0>:f                   {Compacted,$9.dst}
        mov (8|M0)               r78.0<1>:f    r6.0<1;1,0>:f                    {Compacted}
        sync.allwr                           ($2,$4)                
(W)     sync.nop                             null                            
(W)     sync.nop                             null                            
        dpas.8x8 (8|M0)          r41:f         null:f            r41:hf            r41.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r41:f         r41:f             r99:hf            r83.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r65:f         r65:f             r99:hf            r91.0:hf         {$2}
        send.slm (1|M0)          null     r38     r80:2   0x0            0x0200C704           {A@2,$5} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r79.0<1>:f    r22.0<1;1,0>:f                   {Compacted,$0.dst}
        or (1|M0)                r80.0<1>:ud   r38.0<0;1,0>:ud   0x400:uw              {$5.src}
        mov (8|M0)               r76.0<1>:f    r49.0<1;1,0>:f                   {Compacted,$14.dst}
        send.slm (1|M0)          null     r80     r78:2   0x0            0x0200C704           {A@1,$6} // wr:1+2, rd:0; store.slm.d64x8t.a32
        or (1|M0)                r78.0<1>:ud   r38.0<0;1,0>:ud   0x40:uw              {$6.src}
        mov (8|M0)               r77.0<1>:f    r41.0<1;1,0>:f                   {Compacted,$2.dst}
        mov (8|M0)               r82.0<1>:f    r15.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r78     r76:2   0x0            0x0200C704           {A@1,$7} // wr:1+2, rd:0; store.slm.d64x8t.a32
        or (1|M0)                r83.0<1>:ud   r38.0<0;1,0>:ud   0x80:uw             
        mov (8|M0)               r81.0<1>:f    r31.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r74.0<1>:f    r57.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r75.0<1>:f    r65.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r76.0<1>:ud   r38.0<0;1,0>:ud   0x440:uw              {$7.src}
        mov (8|M0)               r79.0<1>:f    r23.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r76     r74:2   0x0            0x0200C704           {A@1,$8} // wr:1+2, rd:0; store.slm.d64x8t.a32
        send.slm (1|M0)          null     r83     r81:2   0x0            0x0200C704           {$9} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r78.0<1>:f    r7.0<1;1,0>:f                    {Compacted}
        or (1|M0)                r81.0<1>:ud   r38.0<0;1,0>:ud   0x480:uw              {$9.src}
        mov (8|M0)               r77.0<1>:f    r42.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r81     r78:2   0x0            0x0200C704           {A@1,$10} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r76.0<1>:f    r50.0<1;1,0>:f                   {Compacted,$8.src}
        or (1|M0)                r78.0<1>:ud   r38.0<0;1,0>:ud   0xC0:uw              {$10.src}
        mov (8|M0)               r84.0<1>:f    r16.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r78     r76:2   0x0            0x0200C704           {A@1,$11} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r74.0<1>:f    r58.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r75.0<1>:f    r66.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r83.0<1>:f    r32.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r82.0<1>:f    r24.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r81.0<1>:f    r8.0<1;1,0>:f                    {Compacted}
        or (1|M0)                r79.0<1>:ud   r38.0<0;1,0>:ud   0x100:uw             
        or (1|M0)                r76.0<1>:ud   r38.0<0;1,0>:ud   0x4C0:uw              {$11.src}
        or (1|M0)                r78.0<1>:ud   r38.0<0;1,0>:ud   0x500:uw             
        send.slm (1|M0)          null     r76     r74:2   0x0            0x0200C704           {A@2,$12} // wr:1+2, rd:0; store.slm.d64x8t.a32
        sync.nop                             null                             {Compacted,F@3}
        send.slm (1|M0)          null     r79     r83:2   0x0            0x0200C704           {$13} // wr:1+2, rd:0; store.slm.d64x8t.a32
        send.slm (1|M0)          null     r78     r81:2   0x0            0x0200C704           {A@1,$14} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r77.0<1>:f    r43.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r76.0<1>:f    r51.0<1;1,0>:f                   {Compacted,$12.src}
        or (1|M0)                r81.0<1>:ud   r38.0<0;1,0>:ud   0x140:uw              {$14.src}
        or (1|M0)                r85.0<1>:ud   r38.0<0;1,0>:ud   0x180:uw             
        send.slm (1|M0)          null     r81     r76:2   0x0            0x0200C704           {A@1,$15} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r74.0<1>:f    r59.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r75.0<1>:f    r67.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r83.0<1>:f    r33.0<1;1,0>:f                   {Compacted,$13.src}
        mov (8|M0)               r84.0<1>:f    r17.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r76.0<1>:ud   r38.0<0;1,0>:ud   0x540:uw              {$15.src}
        mov (8|M0)               r82.0<1>:f    r25.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r76     r74:2   0x0            0x0200C704           {A@1,$0} // wr:1+2, rd:0; store.slm.d64x8t.a32
        send.slm (1|M0)          null     r85     r83:2   0x0            0x0200C704           {A@2,$1} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r81.0<1>:f    r9.0<1;1,0>:f                    {Compacted}
        or (1|M0)                r83.0<1>:ud   r38.0<0;1,0>:ud   0x580:uw              {$1.src}
        mov (8|M0)               r77.0<1>:f    r44.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r83     r81:2   0x0            0x0200C704           {A@1,$2} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r76.0<1>:f    r52.0<1;1,0>:f                   {Compacted,$0.src}
        or (1|M0)                r81.0<1>:ud   r38.0<0;1,0>:ud   0x1C0:uw              {$2.src}
        mov (8|M0)               r74.0<1>:f    r60.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r81     r76:2   0x0            0x0200C704           {A@1,$3} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r75.0<1>:f    r68.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r76.0<1>:ud   r38.0<0;1,0>:ud   0x5C0:uw              {$3.src}
        mov (8|M0)               r86.0<1>:f    r18.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r76     r74:2   0x0            0x0200C704           {A@1,$4} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r85.0<1>:f    r34.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r84.0<1>:f    r26.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r83.0<1>:f    r10.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r77.0<1>:ud   r38.0<0;1,0>:ud   0x200:uw             
        or (1|M0)                r76.0<1>:ud   r38.0<0;1,0>:ud   0x600:uw              {$4.src}
        send.slm (1|M0)          null     r77     r85:2   0x0            0x0200C704           {A@2,$5} // wr:1+2, rd:0; store.slm.d64x8t.a32
        send.slm (1|M0)          null     r76     r83:2   0x0            0x0200C704           {A@1,$6} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r82.0<1>:f    r45.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r81.0<1>:f    r53.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r83.0<1>:ud   r38.0<0;1,0>:ud   0x240:uw              {$6.src}
        or (1|M0)                r87.0<1>:ud   r38.0<0;1,0>:ud   0x280:uw             
        send.slm (1|M0)          null     r83     r81:2   0x0            0x0200C704           {A@1,$7} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r74.0<1>:f    r61.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r75.0<1>:f    r69.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r85.0<1>:f    r35.0<1;1,0>:f                   {Compacted,$5.src}
        mov (8|M0)               r86.0<1>:f    r19.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r81.0<1>:ud   r38.0<0;1,0>:ud   0x640:uw              {$7.src}
        mov (8|M0)               r84.0<1>:f    r27.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r81     r74:2   0x0            0x0200C704           {A@1,$8} // wr:1+2, rd:0; store.slm.d64x8t.a32
        send.slm (1|M0)          null     r87     r85:2   0x0            0x0200C704           {A@2,$9} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r83.0<1>:f    r11.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r85.0<1>:ud   r38.0<0;1,0>:ud   0x680:uw              {$9.src}
        mov (8|M0)               r82.0<1>:f    r46.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r85     r83:2   0x0            0x0200C704           {A@1,$10} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r81.0<1>:f    r54.0<1;1,0>:f                   {Compacted,$8.src}
        or (1|M0)                r83.0<1>:ud   r38.0<0;1,0>:ud   0x2C0:uw              {$10.src}
        mov (8|M0)               r74.0<1>:f    r62.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r83     r81:2   0x0            0x0200C704           {A@1,$11} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r75.0<1>:f    r70.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r81.0<1>:ud   r38.0<0;1,0>:ud   0x6C0:uw              {$11.src}
        mov (8|M0)               r88.0<1>:f    r20.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r81     r74:2   0x0            0x0200C704           {A@1,$12} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r87.0<1>:f    r36.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r86.0<1>:f    r28.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r85.0<1>:f    r12.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r75.0<1>:ud   r38.0<0;1,0>:ud   0x300:uw              {$12.src}
        or (1|M0)                r74.0<1>:ud   r38.0<0;1,0>:ud   0x700:uw             
        send.slm (1|M0)          null     r75     r87:2   0x0            0x0200C704           {A@2,$13} // wr:1+2, rd:0; store.slm.d64x8t.a32
        send.slm (1|M0)          null     r74     r85:2   0x0            0x0200C704           {A@1,$14} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r84.0<1>:f    r47.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r83.0<1>:f    r55.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r85.0<1>:ud   r38.0<0;1,0>:ud   0x340:uw              {$14.src}
        mov (8|M0)               r30.0<1>:f    r37.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r85     r83:2   0x0            0x0200C704           {A@1,$15} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r31.0<1>:f    r21.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r8.0<1>:ud    r38.0<0;1,0>:ud   0x380:uw             
        mov (8|M0)               r82.0<1>:f    r71.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r81.0<1>:f    r63.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r83.0<1>:ud   r38.0<0;1,0>:ud   0x740:uw              {$15.src}
        mov (8|M0)               r6.0<1>:f     r13.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r83     r81:2   0x0            0x0200C704           {A@1,$0} // wr:1+2, rd:0; store.slm.d64x8t.a32
        send.slm (1|M0)          null     r8      r30:2   0x0            0x0200C704           {$1} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r7.0<1>:f     r29.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r8.0<1>:ud    r38.0<0;1,0>:ud   0x780:uw              {$1.src}
        mov (8|M0)               r9.0<1>:f     r56.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r8      r6:2    0x0            0x0200C704           {A@1,$2} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r10.0<1>:f    r48.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r6.0<1>:ud    r38.0<0;1,0>:ud   0x3C0:uw              {$2.src}
        mov (8|M0)               r11.0<1>:f    r64.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r6      r9:2    0x0            0x0200C704           {A@1,$3} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r12.0<1>:f    r72.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r6.0<1>:ud    r38.0<0;1,0>:ud   0x7C0:uw              {$3.src}
        send.slm (1|M0)          null     r6      r11:2   0x0            0x0200C704           {A@1,$4} // wr:1+2, rd:0; store.slm.d64x8t.a32
        sync.nop                             null                             {Compacted,$4.src}
(W)     send.slm (1|M0)          r6       r0      null:0  0x0            0x0210001F           {$5} // wr:1+0, rd:1; fence.slm.none.group
(W)     mov (8|M0)               null<1>:ud    r6.0<1;1,0>:ud                   {$5.dst}
(W)     mov (1|M0)               r6.2<1>:ud    0x0:ud                             
(W)     mov (2|M0)               r6.10<1>:ub   r0.11<0;1,0>:ub                 
(W)     send.gtwy (1|M0)         null     r6      null:0  0x0            0x02000004           {A@1,$6} // wr:1+0, rd:0; signal barrier
(W)     sync.bar                             null                            
        shl (1|M0)               r39.1<1>:d    r1.7<0;1,0>:d     7:w              
        shl (1|M0)               r38.3<1>:ud   r3.1<0;1,0>:ud    0x5:uw             
        or (1|M0)                r65.0<1>:d    r39.0<0;1,0>:d    r39.1<0;1,0>:d   {Compacted,I@2}
        shl (1|M0)               r38.4<1>:ud   r3.1<0;1,0>:ud    0x4:uw             
        sync.nop                             null                             {Compacted,$6.src}
        send.slm (1|M0)          r6       r65     null:0  0x0            0x0240D700           {A@2,$7} // wr:1+0, rd:4; load.slm.d64x16t.a32
        and (1|M0)               r22.2<1>:ud   r38.3<0;1,0>:ud   0x1FFE00:ud             
        and (1|M0)               r39.2<1>:ud   r38.4<0;1,0>:ud   0x70:uw              {I@2}
        shl (1|M0)               r22.1<1>:ud   r3.1<0;1,0>:ud    0x2:uw             
        bfn.0xFE (1|M0)          r22.2<1>:ud   r1.5<0;0>:ud      r22.2<0;0>:ud     r39.2<0>:ud      {I@2} // s0|s1|s2
        and (1|M0)               r38.7<1>:ud   r38.3<0;1,0>:ud   0x100:uw             
        cmp (1|M0)    (eq)f0.0   null<1>:d     r2.4<0;1,0>:d     102:w              
        mov (8|M0)               r6.0<1>:hf    r6.0<1;1,0>:f                    {$7.dst}
        mov (8|M0)               r10.0<1>:hf   r8.0<1;1,0>:f                   
        mov (8|M0)               r10.8<1>:hf   r9.0<1;1,0>:f                   
        mov (8|M0)               r6.8<1>:hf    r7.0<1;1,0>:f                   
        mov (8|M0)               r8.0<1>:f     r6.0<1;1,0>:hf                   {F@4}
        mov (8|M0)               r7.0<1>:f     r10.8<1;1,0>:hf                  {F@3}
        mov (8|M0)               r9.0<1>:f     r6.8<1;1,0>:hf                   {F@3}
        mov (8|M0)               r6.0<1>:f     r10.0<1;1,0>:hf                 
        mul (8|M0)               r10.0<1>:f    r8.0<1;1,0>:f     r8.0<1;1,0>:f    {Compacted,F@4}
        bfn.0xEA (1|M0)          r38.7<1>:ud   r38.7<0;0>:ud     r22.1<0;0>:ud     0x1C:uw              {I@2} // s0|s1&s2
        mov (8|M0)               r39.8<1>:hf   r10.0<1;1,0>:f                   {F@1}
        shl (1|M0)               r22.2<1>:ud   r22.2<0;1,0>:ud   0x1:uw             
        mov (8|M0)               acc0.0<1>:f   r39.8<1;1,0>:hf                  {F@1}
(W)     and (1|M0)               f0.0<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
        mad (8|M0)               r10.0<1>:f    acc0.0<1;0>:f     r9.0<1;0>:f       r9.0<1>:f       
        shl (1|M0)               r38.6<1>:ud   r3.1<0;1,0>:ud    0x3:uw             
        mov (8|M0)               r11.0<1>:hf   r10.0<1;1,0>:f                   {F@1}
        mul (8|M0)               r10.0<1>:f    r6.0<1;1,0>:f     r6.0<1;1,0>:f    {Compacted}
        add (1|M0)               r22.0<1>:ud   r22.2<0;1,0>:ud   0x1000:uw              {I@3}
        mov (8|M0)               r39.8<1>:hf   r10.0<1;1,0>:f                   {F@1}
        add (1|M0)               r23.0<1>:ud   r22.2<0;1,0>:ud   0x1200:uw             
        mov (8|M0)               acc0.0<1>:f   r39.8<1;1,0>:hf                  {F@1}
        and (1|M0)               r38.5<1>:d    r1.0<0;1,0>:uw    1:w              
        mad (8|M0)               r10.0<1>:f    acc0.0<1;0>:f     r7.0<1;0>:f       r7.0<1>:f       
        and (1|M0)               r38.6<1>:ud   r38.6<0;1,0>:ud   0x70:uw              {I@4}
        mov (8|M0)               r10.0<1>:hf   r10.0<1;1,0>:f                   {F@1}
        add (8|M0)               r11.0<1>:hf   r11.0<1;1,0>:hf   r10.0<1;1,0>:hf  {F@1}
        mov (8|M0)               r11.0<1>:f    r11.0<1;1,0>:hf                  {F@1}
        mov (4|M0)               r10.0<1>:ud   r11.4<1;1,0>:ud                  {F@1}
        add (4|M0)               r10.0<1>:f    r10.0<1;1,0>:f    r11.0<1;1,0>:f   {I@1}
        mov (8|M0)               r39.8<1>:hf   r10.0<1;1,0>:f                   {F@1}
        mov (4|M0)               r11.0<1>:f    r39.8<1;1,0>:hf                  {F@1}
        add (1|M0)               r10.0<1>:f    r11.2<0;1,0>:f    r11.0<0;1,0>:f   {Compacted,F@1}
        add (1|M0)               r10.1<1>:f    r11.3<0;1,0>:f    r11.1<0;1,0>:f  
        mov (8|M0)               r22.8<1>:hf   r10.0<1;1,0>:f                   {F@1}
        mov (1|M0)               r10.0<1>:f    r22.8<0;1,0>:hf                  {F@1}
        mov (1|M0)               r10.1<1>:f    r22.9<0;1,0>:hf                 
        add (1|M0)               r39.2<1>:f    r10.0<0;1,0>:f    r10.1<0;1,0>:f   {F@1}
        send.ugm (1|M0)          r10      r4      null:0  0x0            0x04100580           {A@1,$8} // wr:2+0, rd:1; load.ugm.d32.a64
        mov (1|M0)               r39.4<2>:hf   r39.2<0;1,0>:f                  
        mov (1|M0)               r22.1<1>:f    r39.4<0;1,0>:hf                  {F@1}
        sel (1|M0)    (ge)f0.0   r22.1<1>:f    r22.1<0;1,0>:f    6.198883e-05:f               {F@1}
        math.sqt (1|M0)          r22.1<1>:f    r22.1<0;1,0>:f                   {@1,$9}
        math.inv (1|M0)          r22.1<1>:f    r22.1<0;1,0>:f                   {$9}
        mov (1|M0)               r39.4<2>:hf   r22.1<0;1,0>:f                   {$9.dst}
        sync.nop                             null                             {Compacted,$8.dst}
        mov (1|M0)               r10.1<1>:f    r39.4<0;1,0>:hf                  {F@1}
        mul (16|M0)              r8.0<1>:f     r10.1<0;1,0>:f    r8.0<1;1,0>:f    {Compacted,F@1}
        mul (16|M0)              r6.0<1>:f     r10.1<0;1,0>:f    r6.0<1;1,0>:f    {Compacted}
        mov (8|M0)               r13.0<1>:hf   r8.0<1;1,0>:f                    {F@2}
        mov (8|M0)               r13.8<1>:hf   r9.0<1;1,0>:f                   
        mov (8|M0)               r12.0<1>:hf   r6.0<1;1,0>:f                    {F@3}
        mov (8|M0)               r12.8<1>:hf   r7.0<1;1,0>:f                   
        mov (8|M0)               r11.0<1>:f    r13.8<1;1,0>:hf                  {F@3}
        mov (8|M0)               r8.0<1>:f     r12.0<1;1,0>:hf                  {F@3}
        mov (8|M0)               r9.0<1>:f     r12.8<1;1,0>:hf                  {F@3}
        mov (1|M0)               r39.4<2>:hf   r10.0<0;1,0>:f                  
        mov (8|M0)               r10.0<1>:f    r13.0<1;1,0>:hf                 
        mov (1|M0)               r22.1<1>:f    r39.4<0;1,0>:hf                  {F@2}
        mul (16|M0)              r10.0<1>:f    r22.1<0;1,0>:f    r10.0<1;1,0>:f   {Compacted,F@1}
        mul (16|M0)              r8.0<1>:f     r22.1<0;1,0>:f    r8.0<1;1,0>:f    {Compacted}
        mov (8|M0)               r6.0<1>:hf    r10.0<1;1,0>:f                   {F@2}
        mov (8|M0)               r6.8<1>:hf    r11.0<1;1,0>:f                  
        mov (8|M0)               r14.0<1>:hf   r8.0<1;1,0>:f                    {F@3}
        mov (8|M0)               r14.8<1>:hf   r9.0<1;1,0>:f                   
        mov (8|M0)               r12.0<1>:f    (abs)r6.0<1;1,0>:hf              {F@4}
        mov (8|M0)               r13.0<1>:f    (abs)r6.8<1;1,0>:hf              {F@4}
        mov (8|M0)               r7.0<1>:f     (abs)r14.8<1;1,0>:hf             {F@3}
        mov (8|M0)               r6.0<1>:f     (abs)r14.0<1;1,0>:hf            
        sel (16|M0)   (lt)f0.0   r12.0<1>:f    r12.0<1;1,0>:f    448.0:f               {Compacted,F@3}
        sel (16|M0)   (lt)f0.0   r6.0<1>:f     r6.0<1;1,0>:f     448.0:f               {Compacted,F@2}
        shr (16|M0)              r18.0<1>:ud   r12.0<1;1,0>:ud   0x17:uw              {F@2}
        shr (16|M0)              r16.0<1>:ud   r6.0<1;1,0>:ud    0x17:uw              {F@1}
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
        mul (16|M0)              acc2.0<1>:f   r6.0<1;1,0>:f     r16.0<1;1,0>:f   {Compacted,I@1}
        rnde (16|M0)             acc0.0<1>:f   acc0.0<1;1,0>:f                 
        rnde (16|M0)             acc2.0<1>:f   acc2.0<1;1,0>:f                 
        cmp (16|M0)   (lt)f1.1   null<1>:f     r10.0<1;1,0>:f    0xB3000000:f              
        cmp (16|M0)   (lt)f1.0   null<1>:f     r8.0<1;1,0>:f     0xB3000000:f               {Compacted}
        mul (16|M0)              acc0.0<1>:f   acc0.0<1;1,0>:f   r20.0<1;1,0>:f   {Compacted}
        mul (16|M0)              acc2.0<1>:f   acc2.0<1;1,0>:f   r14.0<1;1,0>:f   {Compacted}
        mov (16|M0)              r16.0<1>:f    (abs)acc0.0<1;1,0>:f             {Compacted}
        mov (16|M0)              r12.0<1>:f    (abs)acc2.0<1;1,0>:f             {Compacted}
(f1.1)  or (16|M0)               r16.0<1>:d    r16.0<1;1,0>:d    -2147483648:d               {F@2}
(f1.0)  or (16|M0)               r12.0<1>:d    r12.0<1;1,0>:d    -2147483648:d               {F@1}
        mov (8|M0)               r6.0<1>:hf    r16.0<1;1,0>:f                   {I@2}
        mov (8|M0)               r6.8<1>:hf    r17.0<1;1,0>:f                  
        mov (8|M0)               r7.0<1>:hf    r12.0<1;1,0>:f                   {I@1}
        mov (8|M0)               r7.8<1>:hf    r13.0<1;1,0>:f                  
        send.slm (1|M0)          null     r22     r6:1    0x0            0x0200B704           {A@3,$10} // wr:1+1, rd:0; store.slm.d64x4t.a32
        send.slm (1|M0)          null     r23     r7:1    0x0            0x0200B704           {A@1,$11} // wr:1+1, rd:0; store.slm.d64x4t.a32
(f0.0.any16h) goto (16|M0)                   L34280                  L34280                
L12792:
        or (1|M0)                r10.0<1>:d    r73.0<0;1,0>:d    r39.1<0;1,0>:d   {Compacted}
        send.slm (1|M0)          r6       r10     null:0  0x0            0x0240D700           {A@1,$12} // wr:1+0, rd:4; load.slm.d64x16t.a32
        mov (8|M0)               r6.0<1>:hf    r6.0<1;1,0>:f                    {$12.dst}
        mov (8|M0)               r10.0<1>:hf   r8.0<1;1,0>:f                   
        mov (8|M0)               r10.8<1>:hf   r9.0<1;1,0>:f                   
        mov (8|M0)               r6.8<1>:hf    r7.0<1;1,0>:f                   
        mov (8|M0)               r8.0<1>:f     r6.0<1;1,0>:hf                   {F@4}
        mov (8|M0)               r7.0<1>:f     r10.8<1;1,0>:hf                  {F@3}
        mov (8|M0)               r9.0<1>:f     r6.8<1;1,0>:hf                   {F@3}
        mov (8|M0)               r6.0<1>:f     r10.0<1;1,0>:hf                 
        mul (8|M0)               r10.0<1>:f    r8.0<1;1,0>:f     r8.0<1;1,0>:f    {Compacted,F@4}
        mov (8|M0)               r39.8<1>:hf   r10.0<1;1,0>:f                   {F@1}
        mov (8|M0)               acc0.0<1>:f   r39.8<1;1,0>:hf                  {F@1}
        mad (8|M0)               r10.0<1>:f    acc0.0<1;0>:f     r9.0<1;0>:f       r9.0<1>:f       
        mov (8|M0)               r11.0<1>:hf   r10.0<1;1,0>:f                   {F@1}
        mul (8|M0)               r10.0<1>:f    r6.0<1;1,0>:f     r6.0<1;1,0>:f    {Compacted}
        mov (8|M0)               r39.8<1>:hf   r10.0<1;1,0>:f                   {F@1}
        mov (8|M0)               acc0.0<1>:f   r39.8<1;1,0>:hf                  {F@1}
        mad (8|M0)               r10.0<1>:f    acc0.0<1;0>:f     r7.0<1;0>:f       r7.0<1>:f       
        mov (8|M0)               r10.0<1>:hf   r10.0<1;1,0>:f                   {F@1}
        add (8|M0)               r11.0<1>:hf   r11.0<1;1,0>:hf   r10.0<1;1,0>:hf  {F@1}
        mov (8|M0)               r11.0<1>:f    r11.0<1;1,0>:hf                  {F@1}
        mov (4|M0)               r10.0<1>:ud   r11.4<1;1,0>:ud                  {F@1}
        add (4|M0)               r10.0<1>:f    r10.0<1;1,0>:f    r11.0<1;1,0>:f   {I@1}
        mov (8|M0)               r39.8<1>:hf   r10.0<1;1,0>:f                   {F@1}
        mov (4|M0)               r11.0<1>:f    r39.8<1;1,0>:hf                  {F@1}
        add (1|M0)               r10.0<1>:f    r11.2<0;1,0>:f    r11.0<0;1,0>:f   {Compacted,F@1}
        add (1|M0)               r10.1<1>:f    r11.3<0;1,0>:f    r11.1<0;1,0>:f  
        mov (8|M0)               r39.8<1>:hf   r10.0<1;1,0>:f                   {F@1}
        mov (1|M0)               r10.0<1>:f    r39.8<0;1,0>:hf                  {F@1}
        mov (1|M0)               r10.1<1>:f    r39.9<0;1,0>:hf                 
        add (1|M0)               r39.2<1>:f    r10.0<0;1,0>:f    r10.1<0;1,0>:f   {F@1}
        mov (1|M0)               r39.4<2>:hf   r39.2<0;1,0>:f                   {F@1}
        mov (1|M0)               r39.2<1>:f    r39.4<0;1,0>:hf                  {F@1}
        sel (1|M0)    (ge)f0.0   r39.2<1>:f    r39.2<0;1,0>:f    6.198883e-05:f               {F@1}
        math.sqt (1|M0)          r39.2<1>:f    r39.2<0;1,0>:f                   {@1,$14}
        math.inv (1|M0)          r39.2<1>:f    r39.2<0;1,0>:f                   {$14}
        mov (1|M0)               r39.4<2>:hf   r39.2<0;1,0>:f                   {$14.dst}
        mov (1|M0)               r39.2<1>:f    r39.4<0;1,0>:hf                  {F@1}
        mul (16|M0)              r8.0<1>:f     r39.2<0;1,0>:f    r8.0<1;1,0>:f    {Compacted,F@1}
        mul (16|M0)              r6.0<1>:f     r39.2<0;1,0>:f    r6.0<1;1,0>:f    {Compacted}
        mov (8|M0)               r10.0<1>:hf   r8.0<1;1,0>:f                    {F@2}
        mov (8|M0)               r10.8<1>:hf   r9.0<1;1,0>:f                   
        mov (8|M0)               r14.0<1>:hf   r6.0<1;1,0>:f                    {F@3}
        mov (8|M0)               r14.8<1>:hf   r7.0<1;1,0>:f                   
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
        cmp (16|M0)   (lt)f1.1   null<1>:f     r8.0<1;1,0>:f     0xB3000000:f              
        cmp (16|M0)   (lt)f1.0   null<1>:f     r6.0<1;1,0>:f     0xB3000000:f               {Compacted}
        mul (16|M0)              acc0.0<1>:f   acc0.0<1;1,0>:f   r20.0<1;1,0>:f   {Compacted}
        mul (16|M0)              acc2.0<1>:f   acc2.0<1;1,0>:f   r14.0<1;1,0>:f   {Compacted}
        mov (16|M0)              r16.0<1>:f    (abs)acc0.0<1;1,0>:f             {Compacted}
        mov (16|M0)              r12.0<1>:f    (abs)acc2.0<1;1,0>:f             {Compacted}
(f1.1)  or (16|M0)               r16.0<1>:d    r16.0<1;1,0>:d    -2147483648:d               {F@2}
(f1.0)  or (16|M0)               r12.0<1>:d    r12.0<1;1,0>:d    -2147483648:d               {F@1}
        mov (1|M0)               r6.1<1>:d     0:w                              
        mov (8|M0)               r7.0<1>:hf    r16.0<1;1,0>:f                   {I@3}
        mov (8|M0)               r7.8<1>:hf    r17.0<1;1,0>:f                  
        mov (8|M0)               r8.0<1>:hf    r12.0<1;1,0>:f                   {I@2}
        mov (8|M0)               r8.8<1>:hf    r13.0<1;1,0>:f                  
L13936:
        shr (1|M0)               r6.2<1>:ud    r6.1<0;1,0>:ud    0x2:uw              {I@1}
        shl (1|M0)               r6.0<1>:ud    r6.1<0;1,0>:ud    0x4:uw             
        shl (1|M0)               r39.4<1>:w    r6.2<0;1,0>:w     1:w              
        cmp (1|M0)    (lt)f0.0   null<1>:ud    r6.1<0;1,0>:ud    0x1E:uw             
        and (1|M0)               r6.2<1>:ud    r6.2<0;1,0>:ud    0x4:uw              {I@4}
        and (1|M0)               r6.0<1>:ud    r6.0<0;1,0>:ud    0xE0:uw              {I@4}
        add (1|M0)               a0.0<1>:uw    r39.4<0;1,0>:uw   0xE0:uw              {A@1}
        add (1|M0)               r6.2<1>:ud    r6.2<0;1,0>:ud    r38.2<0;1,0>:ud  {I@3}
        bfn.0xFE (1|M0)          r6.0<1>:ud    0x2000:uw               r38.7<0;0>:ud     r6.0<0>:ud       {I@3} // s0|s1|s2
(W)     and (1|M0)               f1.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
        shl (1|M0)               r6.2<1>:ud    r6.2<0;1,0>:ud    0x9:uw              {I@3}
        add (1|M0)               r9.0<1>:ud    r6.0<0;1,0>:ud    r6.2<0;1,0>:ud   {Compacted,I@1}
        mov (2|M0)               r6.0<1>:uw    r[a0.0]<1;1,0>:uw                {A@1}
        send.slm (1|M0)          null     r9      r6:1    0x0            0x02000504           {A@1,$15} // wr:1+1, rd:0; store.slm.d32.a32
        add (1|M0)               r6.0<1>:ud    r6.1<0;1,0>:ud    0x2:uw              {$15.src}
(f1.1.any16h) goto (16|M0)                   L14248                  L14248                
L14184:
        cmp (1|M0)    (eq)f1.1   null<1>:d     r2.4<0;1,0>:d     103:w              
(W)     and (1|M0)               f1.0<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(f1.0.any16h) goto (16|M0)                   L14248                  L34280                
L14232:
        goto (16|M0)                         L14248                  L14296                
L14248:
        join (16|M0)                         L14296                                
L14264:
        mov (1|M0)               r6.1<1>:d     r6.0<0;1,0>:d                    {I@7}
        goto.b (16|M0)                       L14296                  L13936                
L14296:
        join (16|M0)                         L34280                                
L14312:
        or (1|M0)                r10.0<1>:d    r38.0<0;1,0>:d    r39.1<0;1,0>:d   {Compacted}
        send.slm (1|M0)          r6       r10     null:0  0x0            0x0240D700           {A@1,$1} // wr:1+0, rd:4; load.slm.d64x16t.a32
        sel (16|M0)   (lt)f0.0   r12.0<1>:f    (abs)r6.0<1;1,0>:f  448.0:f             {Compacted,$1.dst}
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
        cmp (16|M0)   (lt)f0.0   null<1>:f     r8.0<1;1,0>:f     0.0:f               {Compacted}
        mul (16|M0)              acc0.0<1>:f   acc0.0<1;1,0>:f   r20.0<1;1,0>:f   {Compacted}
        mul (16|M0)              acc2.0<1>:f   acc2.0<1;1,0>:f   r14.0<1;1,0>:f   {Compacted}
        mov (16|M0)              r16.0<1>:f    (abs)acc0.0<1;1,0>:f             {Compacted}
        mov (16|M0)              r12.0<1>:f    (abs)acc2.0<1;1,0>:f             {Compacted}
(f1.0)  or (16|M0)               r16.0<1>:d    r16.0<1;1,0>:d    -2147483648:d               {F@2}
(f0.0)  or (16|M0)               r12.0<1>:d    r12.0<1;1,0>:d    -2147483648:d               {F@1}
        mov (1|M0)               r6.1<1>:d     0:w                              
        mov (8|M0)               r7.0<1>:hf    r16.0<1;1,0>:f                   {I@3}
        mov (8|M0)               r7.8<1>:hf    r17.0<1;1,0>:f                  
        mov (8|M0)               r8.0<1>:hf    r12.0<1;1,0>:f                   {I@2}
        mov (8|M0)               r8.8<1>:hf    r13.0<1;1,0>:f                  
L14736:
        sync.nop                             null                             {Compacted,$2.src}
        shr (1|M0)               r9.0<1>:ud    r6.1<0;1,0>:ud    0x4:uw              {I@1}
        shl (1|M0)               r6.0<1>:ud    r6.1<0;1,0>:ud    0x4:uw             
        bfn.0xEA (1|M0)          r9.0<1>:ud    r9.0<0;0>:ud      r38.1<0;0>:ud     0x1FFE:uw              {I@2} // s0|s1&s2
        and (1|M0)               r6.0<1>:ud    r6.0<0;1,0>:ud    0x80:uw              {I@2}
        shl (1|M0)               r9.0<1>:ud    r9.0<0;1,0>:ud    0x8:uw              {I@2}
        shl (1|M0)               r38.4<1>:w    r6.2<0;1,0>:w     1:w              
        bfn.0xFE (1|M0)          r9.0<1>:ud    r38.6<0;0>:ud     r9.0<0;0>:ud      r6.0<0>:ud       {I@2} // s0|s1|s2
        shl (1|M0)               r6.0<1>:ud    r6.1<0;1,0>:ud    0x1:uw             
        add (1|M0)               r6.1<1>:ud    r6.1<0;1,0>:ud    0x1:uw             
        and (1|M0)               r6.0<1>:ud    r6.0<0;1,0>:ud    0xE:uw              {I@2}
        cmp (1|M0)    (eq)f1.1   null<1>:d     r6.1<0;1,0>:d     32:w               {I@2}
        add (1|M0)               a0.0<1>:uw    r38.4<0;1,0>:uw   0xE0:uw              {A@1}
        bfn.0xFE (1|M0)          r9.0<1>:ud    r38.5<0;0>:ud     r9.0<0;0>:ud      r6.0<0>:ud       {I@3} // s0|s1|s2
        shl (1|M0)               r9.0<1>:ud    r9.0<0;1,0>:ud    0x1:uw              {I@1}
(W)     and (1|M0)               f0.0<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
        mov (1|M0)               r6.0<1>:d     r[a0.0]<0;1,0>:uw                {A@1}
        add (1|M0)               r9.0<1>:ud    r9.0<0;1,0>:ud    0x3000:uw              {A@1}
        send.slm (1|M0)          null     r9      r6:1    0x0            0x02000B04           {A@1,$2} // wr:1+1, rd:0; store.slm.d16u32.a32
(~f0.0.any16h) goto.b (16|M0)                L15048                  L14736                
L15048:
        join (16|M0)                         L34280                                
L15064:
        cmp (1|M0)    (eq)f0.0   null<1>:d     r4.3<0;1,0>:d     0:w              
(f0.0)  cmp (1|M0)    (eq)f0.0   null<1>:d     r4.2<0;1,0>:d     0:w              
(W)     and (1|M0)               f1.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
(f1.1.any16h) goto (16|M0)                   L15224                  L15224                
L15128:
        sync.nop                             null                             {Compacted,$2.src}
(W)     send.slm (1|M0)          r6       r0      null:0  0x0            0x0210001F           {$3} // wr:1+0, rd:1; fence.slm.none.group
(W)     mov (8|M0)               null<1>:ud    r6.0<1;1,0>:ud                   {$3.dst}
(W)     mov (1|M0)               r6.2<1>:f     0.0:f                               {Compacted,I@1}
(W)     mov (2|M0)               r6.10<1>:ub   r0.11<0;1,0>:ub                  {F@1}
(W)     send.gtwy (1|M0)         null     r6      null:0  0x0            0x02000004           {A@1,$4} // wr:1+0, rd:0; signal barrier
(W)     sync.bar                             null                            
L15224:
        join (16|M0)                         L34280                                
L15240:
        cmp (1|M0)    (lt)f1.0   null<1>:d     r2.4<0;1,0>:d     11:w              
(W)     and (1|M0)               f1.0<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
(f1.0.any16h) goto (16|M0)                   L16792                  L16792                
L15288:
        cmp (1|M0)    (eq)f1.1   null<1>:d     r2.4<0;1,0>:d     11:w              
(W)     and (1|M0)               f1.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(f1.1.any16h) goto (16|M0)                   L16080                  L16080                
L15336:
        cmp (1|M0)    (eq)f1.0   null<1>:d     r2.4<0;1,0>:d     12:w              
(W)     and (1|M0)               f1.0<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
(~f1.0.any16h) goto (16|M0)                  L16080                  L16856                
L15384:
(W)     and (1|M0)               f1.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
(f1.1.any16h) goto (16|M0)                   L16080                  L34280                
L15416:
        shl (1|M0)               r4.1<1>:d     r3.7<0;1,0>:d     12:w              
        shr (1|M0)               r4.0<1>:ud    r3.6<0;1,0>:ud    0x14:uw             
        shl (1|M0)               r3.0<1>:d     r3.6<0;1,0>:d     12:w               {Compacted}
        or (1|M0)                r3.1<1>:d     r4.1<0;1,0>:d     r4.0<0;1,0>:d    {Compacted,I@2}
        shr (1|M0)               r2.0<1>:ud    r3.0<0;1,0>:ud    0x1F:uw              {I@2}
        shl (1|M0)               r2.1<1>:d     r3.0<0;1,0>:d     1:w               {Compacted}
        shl (1|M0)               r2.3<1>:d     r3.1<0;1,0>:d     1:w               {I@3}
        mov (1|M0)               r2.5<2>:f     0.0:f                              
        or (1|M0)                r2.2<1>:d     r2.3<0;1,0>:d     r2.0<0;1,0>:d    {I@1}
        addc (1|M0)              r2.0<1>:ud    r4.2<0;1,0>:ud    r2.1<0;1,0>:ud   {AccWrEn}
        shl (1|M0)               r2.3<1>:d     r3.4<0;1,0>:d     1:w              
        mov (1|M0)               r3.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        shr (1|M0)               r2.1<1>:ud    r3.4<0;1,0>:ud    0x1F:uw             
        add3 (1|M0)              r2.6<1>:d     r3.0<0;0>:d       r4.3<0;0>:d       r2.2<0>:d        {I@2}
        shl (1|M0)               r2.2<1>:d     r3.5<0;1,0>:d     1:w              
        addc (1|M0)              r3.0<1>:ud    r2.0<0;1,0>:ud    r2.3<0;1,0>:ud   {AccWrEn}
        or (1|M0)                r2.4<1>:d     r2.2<0;1,0>:d     r2.1<0;1,0>:d    {I@2}
        mov (1|M0)               r2.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r2.1<1>:d     r3.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r2.2<1>:d     r2.0<0;0>:d       r2.6<0;0>:d       r2.4<0>:d        {I@2}
        mov (1|M0)               r2.4<2>:f     0.0:f                               {I@1}
L15712:
        addc (1|M0)              r2.0<1>:ud    r2.4<0;1,0>:ud    r3.4<0;1,0>:ud   {AccWrEn,F@1}
        cmp (1|M0)    (lt)f1.0   null<1>:ud    r2.4<0;1,0>:ud    0x7C0:uw             
        mov (1|M0)               r3.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        shl (1|M0)               r2.6<1>:d     r2.4<0;1,0>:d     1:w              
        add3 (1|M0)              r2.7<1>:d     r3.0<0;0>:d       r2.5<0;0>:d       r3.5<0>:d        {I@2}
        shl (1|M0)               r3.0<1>:d     r2.0<0;1,0>:d     1:w               {Compacted}
        shl (1|M0)               r3.1<1>:d     r2.5<0;1,0>:d     1:w              
        add (1|M0)               r3.0<1>:d     r3.0<0;1,0>:d     12288:w               {I@2}
        addc (1|M0)              r4.0<1>:ud    r2.1<0;1,0>:ud    r2.6<0;1,0>:ud   {AccWrEn}
        send.slm (1|M0)          r1       r3      null:0  0x0            0x0210B700           {A@2,$5} // wr:1+0, rd:1; load.slm.d64x4t.a32
(f1.0)  cmp (1|M0)    (eq)f1.0   null<1>:d     r2.5<0;1,0>:d     0:w              
        shr (1|M0)               r3.0<1>:ud    r2.4<0;1,0>:ud    0x1F:uw              {$5.src}
        or (1|M0)                r2.7<1>:d     r3.1<0;1,0>:d     r3.0<0;1,0>:d    {I@1}
        mov (1|M0)               r3.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
(W)     and (1|M0)               f1.0<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
        add3 (1|M0)              r4.1<1>:d     r3.0<0;0>:d       r2.2<0;0>:d       r2.7<0>:d        {I@2}
        mov (1|M0)               r2.0<1>:d     r1.0<0;1,0>:uw                   {$5.dst}
        addc (1|M0)              r3.0<1>:ud    r2.4<0;1,0>:ud    0x40:ud              {AccWrEn}
        send.ugm (1|M0)          null     r4      r2:1    0x0            0x04000B84           {A@2,$6} // wr:2+1, rd:0; store.ugm.d16u32.a64
        mov (1|M0)               r2.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$6.src}
        mov (1|M0)               r2.6<1>:d     r3.0<0;1,0>:d                    {I@2}
        add3 (1|M0)              r2.7<1>:d     r2.0<0;0>:d       r2.5<0;0>:d       0:w               {I@2}
(~f1.0.any16h) goto (16|M0)                  L16080                  L34280                
L16048:
(W)     mov (2|M0)               r2.4<1>:ud    r2.6<1;1,0>:ud                   {I@2}
        goto.b (16|M0)                       L16080                  L15712                
L16080:
        join (16|M0)                         L16792                                
L16096:
(W)     and (1|M0)               f0.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
(f0.1.any16h) goto (16|M0)                   L16792                  L34280                
L16128:
        shl (1|M0)               r4.1<1>:d     r3.7<0;1,0>:d     12:w              
        shr (1|M0)               r4.0<1>:ud    r3.6<0;1,0>:ud    0x14:uw             
        shl (1|M0)               r3.0<1>:d     r3.6<0;1,0>:d     12:w               {Compacted}
        or (1|M0)                r3.1<1>:d     r4.1<0;1,0>:d     r4.0<0;1,0>:d    {Compacted,I@2}
        shr (1|M0)               r2.0<1>:ud    r3.0<0;1,0>:ud    0x1F:uw              {I@2}
        shl (1|M0)               r2.1<1>:d     r3.0<0;1,0>:d     1:w               {Compacted}
        shl (1|M0)               r2.3<1>:d     r3.1<0;1,0>:d     1:w               {I@3}
        mov (1|M0)               r2.5<2>:f     0.0:f                              
        or (1|M0)                r2.2<1>:d     r2.3<0;1,0>:d     r2.0<0;1,0>:d    {I@1}
        addc (1|M0)              r2.0<1>:ud    r4.2<0;1,0>:ud    r2.1<0;1,0>:ud   {AccWrEn}
        shl (1|M0)               r2.3<1>:d     r3.4<0;1,0>:d     1:w              
        mov (1|M0)               r3.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        shr (1|M0)               r2.1<1>:ud    r3.4<0;1,0>:ud    0x1F:uw             
        add3 (1|M0)              r2.6<1>:d     r3.0<0;0>:d       r4.3<0;0>:d       r2.2<0>:d        {I@2}
        shl (1|M0)               r2.2<1>:d     r3.5<0;1,0>:d     1:w              
        addc (1|M0)              r3.0<1>:ud    r2.0<0;1,0>:ud    r2.3<0;1,0>:ud   {AccWrEn}
        or (1|M0)                r2.4<1>:d     r2.2<0;1,0>:d     r2.1<0;1,0>:d    {I@2}
        mov (1|M0)               r2.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r2.1<1>:d     r3.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r2.2<1>:d     r2.0<0;0>:d       r2.6<0;0>:d       r2.4<0>:d        {I@2}
        mov (1|M0)               r2.4<2>:f     0.0:f                               {I@1}
L16424:
        addc (1|M0)              r2.0<1>:ud    r2.4<0;1,0>:ud    r3.4<0;1,0>:ud   {AccWrEn,F@1}
        cmp (1|M0)    (lt)f0.1   null<1>:ud    r2.4<0;1,0>:ud    0x7C0:uw             
        mov (1|M0)               r3.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        shl (1|M0)               r2.6<1>:d     r2.4<0;1,0>:d     1:w              
        add3 (1|M0)              r2.7<1>:d     r3.0<0;0>:d       r2.5<0;0>:d       r3.5<0>:d        {I@2}
        shl (1|M0)               r3.0<1>:d     r2.0<0;1,0>:d     1:w               {Compacted}
        shl (1|M0)               r3.1<1>:d     r2.5<0;1,0>:d     1:w              
        add (1|M0)               r3.0<1>:d     r3.0<0;1,0>:d     8192:w               {I@2}
        addc (1|M0)              r4.0<1>:ud    r2.1<0;1,0>:ud    r2.6<0;1,0>:ud   {AccWrEn}
        send.slm (1|M0)          r1       r3      null:0  0x0            0x0210B700           {A@2,$7} // wr:1+0, rd:1; load.slm.d64x4t.a32
(f0.1)  cmp (1|M0)    (eq)f0.1   null<1>:d     r2.5<0;1,0>:d     0:w              
        shr (1|M0)               r3.0<1>:ud    r2.4<0;1,0>:ud    0x1F:uw              {$7.src}
        or (1|M0)                r2.7<1>:d     r3.1<0;1,0>:d     r3.0<0;1,0>:d    {I@1}
        mov (1|M0)               r3.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
(W)     and (1|M0)               f0.0<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
        add3 (1|M0)              r4.1<1>:d     r3.0<0;0>:d       r2.2<0;0>:d       r2.7<0>:d        {I@2}
        mov (1|M0)               r2.0<1>:d     r1.0<0;1,0>:uw                   {$7.dst}
        addc (1|M0)              r3.0<1>:ud    r2.4<0;1,0>:ud    0x40:ud              {AccWrEn}
        send.ugm (1|M0)          null     r4      r2:1    0x0            0x04000B84           {A@2,$8} // wr:2+1, rd:0; store.ugm.d16u32.a64
        mov (1|M0)               r2.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$8.src}
        mov (1|M0)               r2.6<1>:d     r3.0<0;1,0>:d                    {I@2}
        add3 (1|M0)              r2.7<1>:d     r2.0<0;0>:d       r2.5<0;0>:d       0:w               {I@2}
(~f0.0.any16h) goto (16|M0)                  L16792                  L34280                
L16760:
(W)     mov (2|M0)               r2.4<1>:ud    r2.6<1;1,0>:ud                   {I@2}
        goto.b (16|M0)                       L16792                  L16424                
L16792:
        join (16|M0)                         L16856                                
L16808:
        cmp (1|M0)    (eq)f1.1   null<1>:d     r2.4<0;1,0>:d     10:w               {I@3}
(W)     and (1|M0)               f1.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(f1.1.any16h) goto (16|M0)                   L16856                  L33560                
L16856:
        join (16|M0)                         L33560                                
L16872:
        sync.allrd                           ($2,$4)                
(W)     send.slm (1|M0)          r6       r0      null:0  0x0            0x0210001F           {$9} // wr:1+0, rd:1; fence.slm.none.group
(W)     mov (8|M0)               null<1>:ud    r6.0<1;1,0>:ud                   {$9.dst}
(W)     mov (1|M0)               r6.2<1>:f     0.0:f                               {Compacted,I@1}
(W)     mov (2|M0)               r6.10<1>:ub   r0.11<0;1,0>:ub                  {F@1}
(W)     send.gtwy (1|M0)         null     r6      null:0  0x0            0x02000004           {A@1,$10} // wr:1+0, rd:0; signal barrier
(W)     sync.bar                             null                            
        add (1|M0)               r6.0<1>:ud    r3.0<0;1,0>:ud    0x1000:uw              {$10.src}
        mov (16|M0)              r8.0<1>:f     0.0:f                               {Compacted}
        sync.nop                             null                             {Compacted,I@1}
        send.slm (1|M0)          r14      r6      null:0  0x0            0x0280E700           {$11} // wr:1+0, rd:8; load.slm.d64x32t.a32
        add (1|M0)               r6.0<1>:ud    r3.0<0;1,0>:ud    0x1100:uw              {$11.src}
        mov (16|M0)              r10.0<1>:f    0.0:f                               {Compacted}
        sync.nop                             null                             {Compacted,I@1}
        send.slm (1|M0)          r22      r6      null:0  0x0            0x0280E700           {$12} // wr:1+0, rd:8; load.slm.d64x32t.a32
        add (1|M0)               r6.0<1>:ud    r3.0<0;1,0>:ud    0x1200:uw              {$12.src}
        mov (16|M0)              r12.0<1>:f    0.0:f                               {Compacted}
        sync.nop                             null                             {Compacted,I@1}
        send.slm (1|M0)          r30      r6      null:0  0x0            0x0280E700           {$14} // wr:1+0, rd:8; load.slm.d64x32t.a32
        add (1|M0)               r6.0<1>:ud    r3.0<0;1,0>:ud    0x1300:uw              {$14.src}
        mov (1|M0)               r38.1<1>:d    0:w                              
        send.slm (1|M0)          r41      r6      null:0  0x0            0x0280E700           {A@2,$15} // wr:1+0, rd:8; load.slm.d64x32t.a32
        mov (16|M0)              r6.0<1>:f     0.0:f                               {Compacted,$15.src}
L17176:
        shl (1|M0)               r38.2<1>:d    r38.1<0;1,0>:d    9:w               {I@1}
        sync.nop                             null                             {Compacted,$3.src}
        or (1|M0)                r49.0<1>:d    r38.2<0;1,0>:d    8192:w               {I@1}
        or (1|M0)                r97.0<1>:d    r38.2<0;1,0>:d    10240:w              
        send.slm (1|M0)          r66      r49     null:0  0x0            0x0280E700           {A@2,$5} // wr:1+0, rd:8; load.slm.d64x32t.a32
        or (1|M0)                r49.0<1>:d    r38.2<0;1,0>:d    8448:w               {$5.src}
        or (1|M0)                r105.0<1>:d   r38.2<0;1,0>:d    10496:w              
        send.slm (1|M0)          r89      r49     null:0  0x0            0x0280E700           {A@2,$6} // wr:1+0, rd:8; load.slm.d64x32t.a32
        shl (1|M0)               r38.2<1>:d    r38.1<0;1,0>:d    6:w              
        add (1|M0)               r38.1<1>:d    r38.1<0;1,0>:d    1:w               {Compacted}
        sync.nop                             null                             {Compacted,F@1}
        sync.allwr                           ($5,$11,$12)                
        sync.allrd                           ($0,$6,$13)                
        dpas.8x8 (8|M0)          r81:f         null:f            r67:hf            r67.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r81:f         r6:f              r66:hf            r14.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r49:f         r6:f              r66:hf            r22.0:hf         {$11}
        cmp (1|M0)    (eq)f1.0   null<1>:d     r38.1<0;1,0>:d    4:w               {I@1}
        sync.nop                             null                             {Compacted,$6.dst}
        dpas.8x8 (8|M0)          r57:f         null:f            r57:hf            r57.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r57:f         r6:f              r89:hf            r14.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r66:f         r6:f              r89:hf            r22.0:hf         {$6}
        sync.nop                             null                             {Compacted,$6.src}
        send.slm (1|M0)          r89      r97     null:0  0x0            0x0280E700           {$7} // wr:1+0, rd:8; load.slm.d64x32t.a32
        send.slm (1|M0)          r97      r105    null:0  0x0            0x0280E700           {$13} // wr:1+0, rd:8; load.slm.d64x32t.a32
(W)     and (1|M0)               f1.0<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
        sync.allwr                           ($6,$7,$11,$13,$14,$15)                
        dpas.8x8 (8|M0)          r81:f         r81:f             r89:hf            r30.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r57:f         r57:f             r97:hf            r30.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r49:f         r49:f             r89:hf            r41.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r66:f         r66:f             r97:hf            r41.0:hf         {$14}
        or (1|M0)                r93.0<1>:d    r38.2<0;1,0>:d    r39.0<0;1,0>:d   {Compacted,$14.src}
        or (1|M0)                r94.0<1>:ud   r93.0<0;1,0>:ud   0x100:uw              {I@1}
        mov (8|M0)               r91.0<1>:f    r81.0<1;1,0>:f                   {Compacted,$14.dst}
        mov (8|M0)               r92.0<1>:f    r57.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r89.0<1>:f    r49.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r93     r91:2   0x0            0x0200C704           {A@2,$8} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r90.0<1>:f    r66.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r91.0<1>:ud   r93.0<0;1,0>:ud   0x800:uw              {$8.src}
        mov (8|M0)               r92.0<1>:f    r58.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r91     r89:2   0x0            0x0200C704           {A@1,$9} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r91.0<1>:f    r82.0<1;1,0>:f                   {Compacted,$9.src}
        mov (8|M0)               r89.0<1>:f    r50.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r94     r91:2   0x0            0x0200C704           {A@2,$0} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r90.0<1>:f    r67.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r91.0<1>:ud   r93.0<0;1,0>:ud   0x900:uw              {$0.src}
        mov (8|M0)               r92.0<1>:f    r59.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r91     r89:2   0x0            0x0200C704           {A@1,$2} // wr:1+2, rd:0; store.slm.d64x8t.a32
        or (1|M0)                r94.0<1>:ud   r93.0<0;1,0>:ud   0x200:uw             
        mov (8|M0)               r91.0<1>:f    r83.0<1;1,0>:f                   {Compacted,$2.src}
        mov (8|M0)               r89.0<1>:f    r51.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r94     r91:2   0x0            0x0200C704           {A@1,$10} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r90.0<1>:f    r68.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r91.0<1>:ud   r93.0<0;1,0>:ud   0xA00:uw              {$10.src}
        mov (8|M0)               r92.0<1>:f    r60.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r91     r89:2   0x0            0x0200C704           {A@1,$11} // wr:1+2, rd:0; store.slm.d64x8t.a32
        or (1|M0)                r94.0<1>:ud   r93.0<0;1,0>:ud   0x300:uw             
        mov (8|M0)               r91.0<1>:f    r84.0<1;1,0>:f                   {Compacted,$11.src}
        mov (8|M0)               r89.0<1>:f    r52.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r94     r91:2   0x0            0x0200C704           {A@1,$12} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r90.0<1>:f    r69.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r91.0<1>:ud   r93.0<0;1,0>:ud   0xB00:uw              {$12.src}
        mov (8|M0)               r92.0<1>:f    r61.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r91     r89:2   0x0            0x0200C704           {A@1,$14} // wr:1+2, rd:0; store.slm.d64x8t.a32
        or (1|M0)                r94.0<1>:ud   r93.0<0;1,0>:ud   0x400:uw             
        mov (8|M0)               r91.0<1>:f    r85.0<1;1,0>:f                   {Compacted,$14.src}
        mov (8|M0)               r89.0<1>:f    r53.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r94     r91:2   0x0            0x0200C704           {A@1,$15} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r90.0<1>:f    r70.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r91.0<1>:ud   r93.0<0;1,0>:ud   0xC00:uw              {$15.src}
        mov (8|M0)               r92.0<1>:f    r62.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r91     r89:2   0x0            0x0200C704           {A@1,$5} // wr:1+2, rd:0; store.slm.d64x8t.a32
        or (1|M0)                r94.0<1>:ud   r93.0<0;1,0>:ud   0x500:uw             
        mov (8|M0)               r91.0<1>:f    r86.0<1;1,0>:f                   {Compacted,$5.src}
        mov (8|M0)               r89.0<1>:f    r54.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r94     r91:2   0x0            0x0200C704           {A@1,$6} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r90.0<1>:f    r71.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r91.0<1>:ud   r93.0<0;1,0>:ud   0xD00:uw              {$6.src}
        mov (8|M0)               r92.0<1>:f    r63.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r91     r89:2   0x0            0x0200C704           {A@1,$7} // wr:1+2, rd:0; store.slm.d64x8t.a32
        or (1|M0)                r94.0<1>:ud   r93.0<0;1,0>:ud   0x600:uw             
        mov (8|M0)               r91.0<1>:f    r87.0<1;1,0>:f                   {Compacted,$7.src}
        mov (8|M0)               r81.0<1>:f    r88.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r94     r91:2   0x0            0x0200C704           {A@1,$8} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r82.0<1>:f    r64.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r51.0<1>:ud   r93.0<0;1,0>:ud   0x700:uw             
        mov (8|M0)               r89.0<1>:f    r55.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r90.0<1>:f    r72.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r91.0<1>:ud   r93.0<0;1,0>:ud   0xE00:uw              {$8.src}
        mov (8|M0)               r49.0<1>:f    r56.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r91     r89:2   0x0            0x0200C704           {A@1,$1} // wr:1+2, rd:0; store.slm.d64x8t.a32
        send.slm (1|M0)          null     r51     r81:2   0x0            0x0200C704           {$9} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r50.0<1>:f    r73.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r51.0<1>:ud   r93.0<0;1,0>:ud   0xF00:uw              {$9.src}
        send.slm (1|M0)          null     r51     r49:2   0x0            0x0200C704           {A@1,$3} // wr:1+2, rd:0; store.slm.d64x8t.a32
(~f1.0.any16h) goto.b (16|M0)                L18392                  L17176                
L18392:
        join (16|M0)                         L33560                                
L18408:
(W)     send.slm (1|M0)          r14      r0      null:0  0x0            0x0210001F           {$10} // wr:1+0, rd:1; fence.slm.none.group
(W)     mov (8|M0)               null<1>:ud    r14.0<1;1,0>:ud                  {$10.dst}
(W)     mov (1|M0)               r14.2<1>:f    0.0:f                               {Compacted,I@1}
(W)     mov (2|M0)               r14.10<1>:ub  r0.11<0;1,0>:ub                  {F@1}
(W)     send.gtwy (1|M0)         null     r14     null:0  0x0            0x02000004           {A@1,$11} // wr:1+0, rd:0; signal barrier
(W)     sync.bar                             null                            
        cmp (1|M0)    (eq)f1.1   null<1>:d     r2.4<0;1,0>:d     5:w              
(W)     and (1|M0)               f1.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(f1.1.any16h) goto (16|M0)                   L32760                  L32760                
L18544:
        shl (1|M0)               r1.7<1>:d     r1.7<0;1,0>:d     8:w              
        shl (1|M0)               r38.1<1>:d    r3.4<0;1,0>:d     6:w              
        sync.nop                             null                             {Compacted,$11.src}
        or (1|M0)                r14.0<1>:d    r39.0<0;1,0>:d    r1.7<0;1,0>:d    {Compacted,I@2}
        bfn.0xFE (1|M0)          r1.0<1>:ud    0x80:uw               r39.0<0;0>:ud     r1.7<0>:ud       // s0|s1|s2
        send.slm (1|M0)          r18      r14     null:0  0x0            0x0240D700           {A@2,$12} // wr:1+0, rd:4; load.slm.d64x16t.a32
        send.slm (1|M0)          r14      r1      null:0  0x0            0x0240D700           {A@1,$14} // wr:1+0, rd:4; load.slm.d64x16t.a32
        shl (1|M0)               r1.7<1>:d     r3.5<0;1,0>:d     6:w               {$14.src}
        shr (1|M0)               r1.0<1>:ud    r3.4<0;1,0>:ud    0x1A:uw             
        shl (1|M0)               r22.2<1>:d    r38.1<0;1,0>:d    2:w              
        or (1|M0)                r38.2<1>:d    r1.7<0;1,0>:d     r1.0<0;1,0>:d    {I@2}
        shr (1|M0)               r1.0<1>:ud    r38.1<0;1,0>:ud   0x1E:uw             
        addc (1|M0)              r22.0<1>:ud   r4.4<0;1,0>:ud    r22.2<0;1,0>:ud  {AccWrEn,I@3}
        shl (1|M0)               r1.7<1>:d     r38.2<0;1,0>:d    2:w               {I@3}
        or (1|M0)                r22.3<1>:d    r1.7<0;1,0>:d     r1.0<0;1,0>:d    {I@1}
        mov (1|M0)               r1.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r23.0<1>:ud   r22.0<0;1,0>:ud   0x80:ud              {AccWrEn}
        add3 (1|M0)              r22.1<1>:d    r1.0<0;0>:d       r4.5<0;0>:d       r22.3<0>:d       {I@2}
        mov (1|M0)               r1.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        send.ugm (1|M0)          r26      r22     null:0  0x0            0x0240E580           {A@2,$15} // wr:1+0, rd:4; load.ugm.d32x32t.a64
        mov (1|M0)               r30.0<1>:d    r23.0<0;1,0>:d                  
        add3 (1|M0)              r30.1<1>:d    r1.0<0;0>:d       r22.1<0;0>:d      0:w               {I@2}
        mov (1|M0)               r1.7<1>:ud    0x3D380000:ud                             
        send.ugm (1|M0)          r22      r30     null:0  0x0            0x0240E580           {A@2,$5} // wr:1+0, rd:4; load.ugm.d32x32t.a64
        mov (1|M0)               r1.0<1>:ud    0x3FA68000:ud                             
        bfn.0xFE (1|M0)          r1.5<1>:ud    r3.0<0;0>:ud      r1.5<0;0>:ud      r1.4<0>:ud       // s0|s1|s2
        shl (1|M0)               r1.5<1>:ud    r1.5<0;1,0>:ud    0x1:uw              {I@1}
        sync.nop                             null                             {Compacted,$15.dst}
        add (16|M0)              r32.0<1>:f    r26.0<1;1,0>:f    r18.0<1;1,0>:f   {Compacted,$12.dst}
        add (16|M0)              r30.0<1>:f    r28.0<1;1,0>:f    r20.0<1;1,0>:f   {Compacted,$5.src}
        mov (8|M0)               r18.0<1>:hf   r32.0<1;1,0>:f                   {F@2}
        mov (8|M0)               r18.8<1>:hf   r33.0<1;1,0>:f                  
        mov (8|M0)               r26.0<1>:hf   r30.0<1;1,0>:f                   {F@3}
        mov (8|M0)               r26.8<1>:hf   r31.0<1;1,0>:f                  
        sync.nop                             null                             {Compacted,$5.dst}
        add (16|M0)              r28.0<1>:f    r22.0<1;1,0>:f    r14.0<1;1,0>:f   {Compacted,$14.dst}
        mov (8|M0)               r20.0<1>:f    r18.0<1;1,0>:hf                  {F@5}
        mov (8|M0)               r21.0<1>:f    r18.8<1;1,0>:hf                  {F@5}
        mov (8|M0)               r19.0<1>:f    r26.8<1;1,0>:hf                  {F@4}
        mov (8|M0)               r15.0<1>:hf   r28.0<1;1,0>:f                   {F@4}
        mov (8|M0)               r15.8<1>:hf   r29.0<1;1,0>:f                  
        mov (8|M0)               r18.0<1>:f    r26.0<1;1,0>:hf                 
        mad (16|M0)              r20.0<1>:f    r1.0<0;0>:f       r20.0<1;0>:f      r1.7<0>:f        {Compacted,F@5}
        add (16|M0)              r26.0<1>:f    r24.0<1;1,0>:f    r16.0<1;1,0>:f   {Compacted}
        mad (16|M0)              r18.0<1>:f    r1.0<0;0>:f       r18.0<1;0>:f      r1.7<0>:f        {Compacted,F@3}
        mov (8|M0)               r14.0<1>:hf   r26.0<1;1,0>:f                   {F@2}
        mov (8|M0)               r14.8<1>:hf   r27.0<1;1,0>:f                  
        mov (8|M0)               r26.0<1>:f    r15.0<1;1,0>:hf                 
        mov (8|M0)               r27.0<1>:f    r15.8<1;1,0>:hf                 
        mov (8|M0)               r15.0<1>:hf   r20.0<1;1,0>:f                  
        mov (8|M0)               r15.8<1>:hf   r21.0<1;1,0>:f                  
        mov (8|M0)               r24.0<1>:f    r14.0<1;1,0>:hf                  {F@6}
        mov (8|M0)               r25.0<1>:f    r14.8<1;1,0>:hf                  {F@6}
        mov (8|M0)               r22.0<1>:f    r15.0<1;1,0>:hf                  {F@4}
        mov (8|M0)               r14.0<1>:hf   r18.0<1;1,0>:f                  
        mov (8|M0)               r23.0<1>:f    r15.8<1;1,0>:hf                  {F@5}
        mov (8|M0)               r14.8<1>:hf   r19.0<1;1,0>:f                  
        mad (16|M0)              r24.0<1>:f    r1.0<0;0>:f       r24.0<1;0>:f      r1.7<0>:f        {Compacted,F@5}
        mov (8|M0)               r15.0<1>:f    r14.0<1;1,0>:hf                  {F@4}
        sel (16|M0)   (ge)f0.0   acc0.0<1>:f   r22.0<1;1,0>:f    1.03125:f               {F@4}
        mov (8|M0)               r16.0<1>:f    r14.8<1;1,0>:hf                  {F@4}
        mad (16|M0)              r26.0<1>:f    r1.0<0;0>:f       r26.0<1;0>:f      r1.7<0>:f        {Compacted}
        mov (8|M0)               r14.0<1>:hf   r24.0<1;1,0>:f                   {F@5}
        sel (16|M0)   (lt)f0.0   r22.0<1>:f    acc0.0<1;1,0>:f   0x3FC8E000:f              
        mov (8|M0)               r14.8<1>:hf   r25.0<1;1,0>:f                  
        sel (16|M0)   (ge)f0.0   acc0.0<1>:f   r15.0<1;1,0>:f    1.03125:f               {F@5}
        mov (8|M0)               r17.0<1>:hf   r26.0<1;1,0>:f                   {F@5}
        mov (8|M0)               r18.0<1>:f    r14.0<1;1,0>:hf                  {F@5}
        mov (8|M0)               r19.0<1>:f    r14.8<1;1,0>:hf                  {F@4}
        sel (16|M0)   (lt)f0.0   r15.0<1>:f    acc0.0<1;1,0>:f   0x3FC8E000:f              
        mov (8|M0)               r14.0<1>:ud   r22.0<2;1,0>:ud                  {A@2}
        mov (8|M0)               r20.0<1>:f    r17.0<1;1,0>:hf                 
        mov (8|M0)               r17.0<1>:hf   r14.0<1;1,0>:f                   {I@1}
        mov (8|M0)               r14.0<1>:ud   r15.0<2;1,0>:ud                  {A@1}
        mov (8|M0)               r17.8<1>:hf   r27.0<1;1,0>:f                  
        mov (8|M0)               r14.0<2>:hf   r14.0<1;1,0>:f                   {I@1}
        mov (8|M0)               r21.0<1>:f    r17.8<1;1,0>:hf                  {F@2}
        mov (8|M0)               r17.8<1>:uw   r14.0<2;1,0>:uw                  {A@1}
        mov (8|M0)               r14.0<1>:ud   r22.1<2;1,0>:ud                 
        sel (16|M0)   (ge)f0.0   acc0.0<1>:f   r20.0<1;1,0>:f    1.03125:f              
        mov (8|M0)               r22.0<1>:hf   r14.0<1;1,0>:f                   {I@1}
        mov (8|M0)               r14.0<1>:ud   r15.1<2;1,0>:ud                  {F@1}
        sel (16|M0)   (ge)f0.0   acc2.0<1>:f   r18.0<1;1,0>:f    1.03125:f              
        sel (16|M0)   (lt)f0.0   r20.0<1>:f    acc0.0<1;1,0>:f   0x3FC8E000:f              
        mov (8|M0)               r14.0<2>:hf   r14.0<1;1,0>:f                   {I@1}
        sel (16|M0)   (lt)f0.0   r18.0<1>:f    acc2.0<1;1,0>:f   0x3FC8E000:f              
        mov (8|M0)               r22.8<1>:uw   r14.0<2;1,0>:uw                  {F@2}
        mov (8|M0)               r14.0<1>:ud   r20.0<2;1,0>:ud                 
        shl (16|M0)              r25.0<1>:d    r17.0<1;1,0>:uw   5:w              
        mov (8|M0)               r16.0<1>:hf   r14.0<1;1,0>:f                   {I@2}
        mov (8|M0)               r14.0<1>:ud   r18.0<2;1,0>:ud                  {A@1}
        add (16|M0)              r25.0<1>:d    r25.0<1;1,0>:d    2146992128:d               {I@2}
        mov (8|M0)               r14.0<2>:hf   r14.0<1;1,0>:f                   {I@2}
        mov (8|M0)               r16.8<1>:uw   r14.0<2;1,0>:uw                  {F@1}
        mov (16|M0)              r14.0<1>:d    r22.0<1;1,0>:uw                 
        shl (16|M0)              r14.0<1>:d    r14.0<1;1,0>:d    21:w               {Compacted,I@1}
        add (16|M0)              r25.0<1>:d    r25.0<1;1,0>:d    r14.0<1;1,0>:d   {Compacted,I@1}
        shl (16|M0)              r23.0<1>:d    r16.0<1;1,0>:uw   5:w              
        mov (8|M0)               r16.0<1>:f    r25.0<1;1,0>:hf                  {A@1}
        mov (8|M0)               r17.0<1>:f    r25.8<1;1,0>:hf                 
        add (1|M0)               r1.0<1>:f     r16.0<0;1,0>:f    r16.1<0;1,0>:f   {Compacted,F@2}
        mov (8|M0)               r14.0<1>:f    r26.0<1;1,0>:hf                 
        add (1|M0)               r1.0<1>:f     r1.0<0;1,0>:f     r16.2<0;1,0>:f   {Compacted,F@2}
        mov (8|M0)               r15.0<1>:f    r26.8<1;1,0>:hf                 
        add (1|M0)               r1.0<1>:f     r1.0<0;1,0>:f     r16.3<0;1,0>:f   {Compacted,F@2}
        mov (8|M0)               r22.0<1>:ud   r20.1<2;1,0>:ud                 
        add (1|M0)               r1.0<1>:f     r1.0<0;1,0>:f     r16.4<0;1,0>:f   {Compacted,F@1}
        mov (8|M0)               r20.0<1>:ud   r18.1<2;1,0>:ud                 
        add (1|M0)               r1.0<1>:f     r1.0<0;1,0>:f     r16.5<0;1,0>:f   {Compacted,F@1}
        mov (8|M0)               r18.0<2>:hf   r20.0<1;1,0>:f                   {I@1}
        add (1|M0)               r1.0<1>:f     r1.0<0;1,0>:f     r16.6<0;1,0>:f   {Compacted,F@2}
        mov (8|M0)               r21.0<1>:hf   r22.0<1;1,0>:f                  
        add (1|M0)               r1.0<1>:f     r1.0<0;1,0>:f     r16.7<0;1,0>:f   {Compacted,F@2}
        mov (8|M0)               r21.8<1>:uw   r18.0<2;1,0>:uw                 
        add (1|M0)               r1.0<1>:f     r1.0<0;1,0>:f     r17.0<0;1,0>:f   {Compacted,F@1}
        mov (16|M0)              r18.0<1>:d    r21.0<1;1,0>:uw                  {I@1}
        add (1|M0)               r1.0<1>:f     r1.0<0;1,0>:f     r17.1<0;1,0>:f   {Compacted,F@1}
        add (16|M0)              r23.0<1>:d    r23.0<1;1,0>:d    2146992128:d              
        add (1|M0)               r1.0<1>:f     r1.0<0;1,0>:f     r17.2<0;1,0>:f   {Compacted,F@1}
        shl (16|M0)              r18.0<1>:d    r18.0<1;1,0>:d    21:w               {Compacted,I@2}
        add (1|M0)               r1.0<1>:f     r1.0<0;1,0>:f     r17.3<0;1,0>:f   {Compacted,F@1}
        add (16|M0)              r23.0<1>:d    r23.0<1;1,0>:d    r18.0<1;1,0>:d   {Compacted,I@1}
        add (1|M0)               r1.0<1>:f     r1.0<0;1,0>:f     r17.4<0;1,0>:f   {Compacted,F@1}
        mov (8|M0)               r20.0<1>:f    r23.0<1;1,0>:hf                  {I@1}
        add (1|M0)               r1.0<1>:f     r1.0<0;1,0>:f     r17.5<0;1,0>:f   {Compacted,F@2}
        mov (8|M0)               r21.0<1>:f    r23.8<1;1,0>:hf                 
        add (1|M0)               r1.0<1>:f     r1.0<0;1,0>:f     r17.6<0;1,0>:f   {Compacted,F@2}
        mov (8|M0)               r18.0<1>:f    r24.0<1;1,0>:hf                 
        add (1|M0)               r1.0<1>:f     r1.0<0;1,0>:f     r17.7<0;1,0>:f   {Compacted,F@2}
        mov (8|M0)               r19.0<1>:f    r24.8<1;1,0>:hf                 
        add (1|M0)               r1.0<1>:f     r1.0<0;1,0>:f     r14.0<0;1,0>:f   {Compacted,F@2}
        add (1|M0)               r1.0<1>:f     r1.0<0;1,0>:f     r14.1<0;1,0>:f   {Compacted,F@1}
        add (1|M0)               r1.0<1>:f     r1.0<0;1,0>:f     r14.2<0;1,0>:f   {Compacted,F@1}
        add (1|M0)               r1.0<1>:f     r1.0<0;1,0>:f     r14.3<0;1,0>:f   {Compacted,F@1}
        add (1|M0)               r1.0<1>:f     r1.0<0;1,0>:f     r14.4<0;1,0>:f   {Compacted,F@1}
        add (1|M0)               r1.0<1>:f     r1.0<0;1,0>:f     r14.5<0;1,0>:f   {Compacted,F@1}
        add (1|M0)               r1.0<1>:f     r1.0<0;1,0>:f     r14.6<0;1,0>:f   {Compacted,F@1}
        add (1|M0)               r1.0<1>:f     r1.0<0;1,0>:f     r14.7<0;1,0>:f   {Compacted,F@1}
        add (1|M0)               r1.0<1>:f     r1.0<0;1,0>:f     r15.0<0;1,0>:f   {Compacted,F@1}
        add (1|M0)               r1.0<1>:f     r1.0<0;1,0>:f     r15.1<0;1,0>:f   {Compacted,F@1}
        add (1|M0)               r1.0<1>:f     r1.0<0;1,0>:f     r15.2<0;1,0>:f   {Compacted,F@1}
        add (1|M0)               r1.0<1>:f     r1.0<0;1,0>:f     r15.3<0;1,0>:f   {Compacted,F@1}
        add (1|M0)               r1.0<1>:f     r1.0<0;1,0>:f     r15.4<0;1,0>:f   {Compacted,F@1}
        add (1|M0)               r1.0<1>:f     r1.0<0;1,0>:f     r15.5<0;1,0>:f   {Compacted,F@1}
        add (1|M0)               r1.0<1>:f     r1.0<0;1,0>:f     r15.6<0;1,0>:f   {Compacted,F@1}
        add (1|M0)               r1.0<1>:f     r1.0<0;1,0>:f     r15.7<0;1,0>:f   {Compacted,F@1}
        add (1|M0)               r1.0<1>:f     r1.0<0;1,0>:f     r20.0<0;1,0>:f   {Compacted,F@1}
        add (1|M0)               r1.0<1>:f     r1.0<0;1,0>:f     r20.1<0;1,0>:f   {Compacted,F@1}
        add (1|M0)               r1.0<1>:f     r1.0<0;1,0>:f     r20.2<0;1,0>:f   {Compacted,F@1}
        add (1|M0)               r1.0<1>:f     r1.0<0;1,0>:f     r20.3<0;1,0>:f   {Compacted,F@1}
        add (1|M0)               r1.0<1>:f     r1.0<0;1,0>:f     r20.4<0;1,0>:f   {Compacted,F@1}
        add (1|M0)               r1.0<1>:f     r1.0<0;1,0>:f     r20.5<0;1,0>:f   {Compacted,F@1}
        add (1|M0)               r1.0<1>:f     r1.0<0;1,0>:f     r20.6<0;1,0>:f   {Compacted,F@1}
        add (1|M0)               r1.0<1>:f     r1.0<0;1,0>:f     r20.7<0;1,0>:f   {Compacted,F@1}
        add (1|M0)               r1.0<1>:f     r1.0<0;1,0>:f     r21.0<0;1,0>:f   {Compacted,F@1}
        add (1|M0)               r1.0<1>:f     r1.0<0;1,0>:f     r21.1<0;1,0>:f   {Compacted,F@1}
        add (1|M0)               r1.0<1>:f     r1.0<0;1,0>:f     r21.2<0;1,0>:f   {Compacted,F@1}
        add (1|M0)               r1.0<1>:f     r1.0<0;1,0>:f     r21.3<0;1,0>:f   {Compacted,F@1}
        add (1|M0)               r1.0<1>:f     r1.0<0;1,0>:f     r21.4<0;1,0>:f   {Compacted,F@1}
        add (1|M0)               r1.0<1>:f     r1.0<0;1,0>:f     r21.5<0;1,0>:f   {Compacted,F@1}
        add (1|M0)               r1.0<1>:f     r1.0<0;1,0>:f     r21.6<0;1,0>:f   {Compacted,F@1}
        add (1|M0)               r1.0<1>:f     r1.0<0;1,0>:f     r21.7<0;1,0>:f   {Compacted,F@1}
        add (1|M0)               r1.0<1>:f     r1.0<0;1,0>:f     r18.0<0;1,0>:f   {Compacted,F@1}
        add (1|M0)               r1.0<1>:f     r1.0<0;1,0>:f     r18.1<0;1,0>:f   {Compacted,F@1}
        add (1|M0)               r1.0<1>:f     r1.0<0;1,0>:f     r18.2<0;1,0>:f   {Compacted,F@1}
        add (1|M0)               r1.0<1>:f     r1.0<0;1,0>:f     r18.3<0;1,0>:f   {Compacted,F@1}
        add (1|M0)               r1.0<1>:f     r1.0<0;1,0>:f     r18.4<0;1,0>:f   {Compacted,F@1}
        add (1|M0)               r1.0<1>:f     r1.0<0;1,0>:f     r18.5<0;1,0>:f   {Compacted,F@1}
        add (1|M0)               r1.0<1>:f     r1.0<0;1,0>:f     r18.6<0;1,0>:f   {Compacted,F@1}
        add (1|M0)               r1.0<1>:f     r1.0<0;1,0>:f     r18.7<0;1,0>:f   {Compacted,F@1}
        add (1|M0)               r1.0<1>:f     r1.0<0;1,0>:f     r19.0<0;1,0>:f   {Compacted,F@1}
        add (1|M0)               r1.0<1>:f     r1.0<0;1,0>:f     r19.1<0;1,0>:f   {Compacted,F@1}
        add (1|M0)               r1.0<1>:f     r1.0<0;1,0>:f     r19.2<0;1,0>:f   {Compacted,F@1}
        add (1|M0)               r1.0<1>:f     r1.0<0;1,0>:f     r19.3<0;1,0>:f   {Compacted,F@1}
        add (1|M0)               r1.0<1>:f     r1.0<0;1,0>:f     r19.4<0;1,0>:f   {Compacted,F@1}
        add (1|M0)               r1.0<1>:f     r1.0<0;1,0>:f     r19.5<0;1,0>:f   {Compacted,F@1}
        add (1|M0)               r1.0<1>:f     r1.0<0;1,0>:f     r19.6<0;1,0>:f   {Compacted,F@1}
        add (1|M0)               r1.0<1>:f     r1.0<0;1,0>:f     r19.7<0;1,0>:f   {Compacted,F@1}
        mov (1|M0)               r1.0<2>:hf    r1.0<0;1,0>:f                    {F@1}
        math.inv (8|M0)          r22.0<1>:hf   r1.0<0;1,0>:hf                   {@1,$6}
        mov (1|M0)               r1.0<1>:uw    r22.0<0;1,0>:uw                  {$6.dst}
        mov (1|M0)               r1.0<1>:f     r1.0<0;1,0>:hf                   {I@1}
        mul (16|M0)              r16.0<1>:f    r1.0<0;1,0>:f     r16.0<1;1,0>:f   {Compacted,F@1}
        mul (16|M0)              r14.0<1>:f    r1.0<0;1,0>:f     r14.0<1;1,0>:f   {Compacted}
        mov (8|M0)               r22.0<1>:hf   r16.0<1;1,0>:f                   {F@2}
        mov (8|M0)               r22.8<1>:hf   r17.0<1;1,0>:f                  
        mov (8|M0)               r26.0<1>:hf   r14.0<1;1,0>:f                   {F@3}
        mov (8|M0)               r26.8<1>:hf   r15.0<1;1,0>:f                  
        mov (8|M0)               r24.0<1>:f    (abs)r22.0<1;1,0>:hf             {F@4}
        mov (8|M0)               r25.0<1>:f    (abs)r22.8<1;1,0>:hf             {F@4}
        mov (8|M0)               r23.0<1>:f    (abs)r26.8<1;1,0>:hf             {F@3}
        mov (8|M0)               r22.0<1>:f    (abs)r26.0<1;1,0>:hf            
        sel (16|M0)   (lt)f0.0   r24.0<1>:f    r24.0<1;1,0>:f    448.0:f               {Compacted,F@3}
        sel (16|M0)   (lt)f0.0   r22.0<1>:f    r22.0<1;1,0>:f    448.0:f               {Compacted,F@2}
        shr (16|M0)              r30.0<1>:ud   r24.0<1;1,0>:ud   0x17:uw              {F@2}
        shr (16|M0)              r28.0<1>:ud   r22.0<1;1,0>:ud   0x17:uw              {F@1}
        sel (16|M0)   (ge)f0.0   r26.0<2>:ub   r30.0<4;1,0>:ub   0x79:uw              {I@2}
        sel (16|M0)   (ge)f0.0   r27.0<2>:ub   r28.0<4;1,0>:ub   0x79:uw              {I@2}
        mov (16|M0)              r30.0<1>:d    r26.0<2;1,0>:ub                  {I@2}
        mov (16|M0)              r28.0<1>:d    r27.0<2;1,0>:ub                  {I@2}
        shl (16|M0)              r30.0<1>:d    r30.0<1;1,0>:d    23:w               {Compacted,I@2}
        shl (16|M0)              r28.0<1>:d    r28.0<1;1,0>:d    23:w               {Compacted,I@2}
        add (16|M0)              r32.0<1>:d    r30.0<1;1,0>:d    -25165824:d               {I@2}
        add (16|M0)              r26.0<1>:d    r28.0<1;1,0>:d    -25165824:d               {I@2}
        add (16|M0)              r30.0<1>:d    -r30.0<1;1,0>:d   -2139095040:d              
        add (16|M0)              r28.0<1>:d    -r28.0<1;1,0>:d   -2139095040:d              
        mul (16|M0)              r20.0<1>:f    r1.0<0;1,0>:f     r20.0<1;1,0>:f   {Compacted}
        mul (16|M0)              acc0.0<1>:f   r24.0<1;1,0>:f    r30.0<1;1,0>:f   {Compacted,I@2}
        mul (16|M0)              acc2.0<1>:f   r22.0<1;1,0>:f    r28.0<1;1,0>:f   {Compacted,I@1}
        mul (16|M0)              r18.0<1>:f    r1.0<0;1,0>:f     r18.0<1;1,0>:f   {Compacted}
        cmp (16|M0)   (lt)f1.1   null<1>:f     r14.0<1;1,0>:f    0xB3000000:f              
        rnde (16|M0)             acc0.0<1>:f   acc0.0<1;1,0>:f                 
        rnde (16|M0)             acc2.0<1>:f   acc2.0<1;1,0>:f                 
        mov (8|M0)               r14.0<1>:hf   r20.0<1;1,0>:f                   {F@7}
        mov (8|M0)               r14.8<1>:hf   r21.0<1;1,0>:f                  
        cmp (16|M0)   (lt)f1.0   null<1>:f     r16.0<1;1,0>:f    0xB3000000:f               {Compacted}
        mul (16|M0)              acc0.0<1>:f   acc0.0<1;1,0>:f   r32.0<1;1,0>:f   {Compacted}
        mov (8|M0)               r16.0<1>:f    (abs)r14.0<1;1,0>:hf             {F@4}
        mov (8|M0)               r17.0<1>:f    (abs)r14.8<1;1,0>:hf             {F@4}
        mul (16|M0)              acc2.0<1>:f   acc2.0<1;1,0>:f   r26.0<1;1,0>:f   {Compacted}
        mov (8|M0)               r22.0<1>:hf   r18.0<1;1,0>:f                  
        mov (8|M0)               r22.8<1>:hf   r19.0<1;1,0>:f                  
        sel (16|M0)   (lt)f0.0   r16.0<1>:f    r16.0<1;1,0>:f    448.0:f               {Compacted,F@4}
        mov (16|M0)              r24.0<1>:f    (abs)acc2.0<1;1,0>:f             {Compacted}
        mov (8|M0)               r14.0<1>:f    (abs)r22.0<1;1,0>:hf             {F@4}
        mov (8|M0)               r15.0<1>:f    (abs)r22.8<1;1,0>:hf             {F@4}
        shr (16|M0)              r26.0<1>:ud   r16.0<1;1,0>:ud   0x17:uw              {F@4}
(f1.1)  or (16|M0)               r24.0<1>:d    r24.0<1;1,0>:d    -2147483648:d               {F@3}
        sel (16|M0)   (lt)f0.0   r14.0<1>:f    r14.0<1;1,0>:f    448.0:f               {Compacted,F@1}
        sel (16|M0)   (ge)f0.0   r22.0<2>:ub   r26.0<4;1,0>:ub   0x79:uw              {I@2}
        mov (8|M0)               r31.0<1>:hf   r24.0<1;1,0>:f                   {I@2}
        mov (8|M0)               r31.8<1>:hf   r25.0<1;1,0>:f                  
        shr (16|M0)              r24.0<1>:ud   r14.0<1;1,0>:ud   0x17:uw              {A@1}
        mov (16|M0)              r28.0<1>:f    (abs)acc0.0<1;1,0>:f             {Compacted}
        mov (16|M0)              r26.0<1>:d    r22.0<2;1,0>:ub                  {I@2}
        sel (16|M0)   (ge)f0.0   r23.0<2>:ub   r24.0<4;1,0>:ub   0x79:uw              {I@2}
(f1.0)  or (16|M0)               r28.0<1>:d    r28.0<1;1,0>:d    -2147483648:d               {F@1}
        shl (16|M0)              r26.0<1>:d    r26.0<1;1,0>:d    23:w               {Compacted,I@3}
        mov (16|M0)              r24.0<1>:d    r23.0<2;1,0>:ub                  {I@3}
        mov (8|M0)               r30.0<1>:hf   r28.0<1;1,0>:f                   {I@3}
        mov (8|M0)               r30.8<1>:hf   r29.0<1;1,0>:f                  
        shl (16|M0)              r24.0<1>:d    r24.0<1;1,0>:d    23:w               {Compacted,I@1}
        add (16|M0)              r28.0<1>:d    r26.0<1;1,0>:d    -25165824:d               {A@1}
        add (16|M0)              r26.0<1>:d    -r26.0<1;1,0>:d   -2139095040:d              
        add (16|M0)              r22.0<1>:d    r24.0<1;1,0>:d    -25165824:d               {I@3}
        mul (16|M0)              acc0.0<1>:f   r16.0<1;1,0>:f    r26.0<1;1,0>:f   {Compacted,I@2}
        add (16|M0)              r24.0<1>:d    -r24.0<1;1,0>:d   -2139095040:d              
        rnde (16|M0)             acc0.0<1>:f   acc0.0<1;1,0>:f                 
        mul (16|M0)              acc2.0<1>:f   r14.0<1;1,0>:f    r24.0<1;1,0>:f   {Compacted,I@1}
        cmp (16|M0)   (lt)f1.0   null<1>:f     r20.0<1;1,0>:f    0xB3000000:f               {Compacted}
        rnde (16|M0)             acc2.0<1>:f   acc2.0<1;1,0>:f                 
        mul (16|M0)              acc0.0<1>:f   acc0.0<1;1,0>:f   r28.0<1;1,0>:f   {Compacted}
        add (1|M0)               r1.0<1>:ud    r1.5<0;1,0>:ud    0x5000:uw             
        cmp (16|M0)   (lt)f1.1   null<1>:f     r18.0<1;1,0>:f    0xB3000000:f              
        mul (16|M0)              acc2.0<1>:f   acc2.0<1;1,0>:f   r22.0<1;1,0>:f   {Compacted}
        mov (16|M0)              r24.0<1>:f    (abs)acc0.0<1;1,0>:f             {Compacted}
        sync.nop                             null                             {Compacted,I@1}
        send.slm (1|M0)          null     r1      r30:1   0x0            0x0200B704           {$7} // wr:1+1, rd:0; store.slm.d64x4t.a32
        mov (16|M0)              r16.0<1>:f    (abs)acc2.0<1;1,0>:f             {Compacted}
(f1.0)  or (16|M0)               r24.0<1>:d    r24.0<1;1,0>:d    -2147483648:d               {F@2}
        add (1|M0)               r1.0<1>:ud    r1.5<0;1,0>:ud    0x5200:uw              {$7.src}
(f1.1)  or (16|M0)               r16.0<1>:d    r16.0<1;1,0>:d    -2147483648:d               {F@1}
        send.slm (1|M0)          null     r1      r31:1   0x0            0x0200B704           {A@2,$8} // wr:1+1, rd:0; store.slm.d64x4t.a32
        mov (8|M0)               r14.0<1>:hf   r24.0<1;1,0>:f                  
        mov (8|M0)               r14.8<1>:hf   r25.0<1;1,0>:f                  
        add (1|M0)               r1.0<1>:ud    r1.5<0;1,0>:ud    0x5400:uw              {$8.src}
        mov (8|M0)               r15.0<1>:hf   r16.0<1;1,0>:f                   {I@2}
        send.slm (1|M0)          null     r1      r14:1   0x0            0x0200B704           {A@1,$9} // wr:1+1, rd:0; store.slm.d64x4t.a32
        mov (8|M0)               r15.8<1>:hf   r17.0<1;1,0>:f                  
        add (1|M0)               r1.0<1>:ud    r1.5<0;1,0>:ud    0x5600:uw              {$9.src}
        send.slm (1|M0)          null     r1      r15:1   0x0            0x0200B704           {A@1,$10} // wr:1+1, rd:0; store.slm.d64x4t.a32
(W)     send.slm (1|M0)          r14      r0      null:0  0x0            0x0210001F           {$12} // wr:1+0, rd:1; fence.slm.none.group
(W)     mov (8|M0)               null<1>:ud    r14.0<1;1,0>:ud                  {$12.dst}
(W)     mov (1|M0)               r14.2<1>:ud   0x0:ud                             
(W)     mov (2|M0)               r14.10<1>:ub  r0.11<0;1,0>:ub                 
(W)     send.gtwy (1|M0)         null     r14     null:0  0x0            0x02000004           {A@1,$14} // wr:1+0, rd:0; signal barrier
(W)     sync.bar                             null                            
        cmp (1|M0)    (eq)f1.0   null<1>:d     r2.4<0;1,0>:d     6:w              
(W)     and (1|M0)               f1.0<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
(f1.0.any16h) goto (16|M0)                   L31928                  L31928                
L22160:
(W)     mov (1|M0)               f1.1<1>:uw    0x1:uw                             
        mov (1|M0)               r1.0<1>:d     0:w                               {$10.src}
L22192:
        shl (1|M0)               r1.4<1>:d     r1.0<0;1,0>:d     9:w               {Compacted,I@1}
        send.slm (1|M0)          r22      r38     null:0  0x0            0x0280E700           {$15} // wr:1+0, rd:8; load.slm.d64x32t.a32
        sync.nop                             null                             {Compacted,$14.src}
        or (1|M0)                r14.0<1>:d    r1.4<0;1,0>:d     12288:w               {I@1}
        send.slm (1|M0)          r57      r79     null:0  0x0            0x0280E700           {$5} // wr:1+0, rd:8; load.slm.d64x32t.a32
        send.slm (1|M0)          r41      r14     null:0  0x0            0x0280E700           {A@1,$6} // wr:1+0, rd:8; load.slm.d64x32t.a32
        or (1|M0)                r14.0<1>:d    r1.4<0;1,0>:d     12544:w               {$6.src}
        or (1|M0)                r81.0<1>:d    r1.4<0;1,0>:d     13312:w              
        send.slm (1|M0)          r49      r14     null:0  0x0            0x0280E700           {A@2,$7} // wr:1+0, rd:8; load.slm.d64x32t.a32
        or (1|M0)                r89.0<1>:d    r1.4<0;1,0>:d     13568:w               {$1.src}
        send.slm (1|M0)          r66      r77     null:0  0x0            0x0280E700           {$8} // wr:1+0, rd:8; load.slm.d64x32t.a32
        shl (1|M0)               r1.0<1>:d     r1.0<0;1,0>:d     6:w               {Compacted}
        sync.allwr                           ($6,$15)                
        sync.nop                             null                             {Compacted,$7.src}
        dpas.8x8 (8|M0)          r14:f         null:f            r14:hf            r14.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r14:f         r6:f              r41:hf            r22.0:hf         {$15}
(W)     and (1|M0)               f1.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
        sync.allwr                           ($5,$7)                
        dpas.8x8 (8|M0)          r30:f         r6:f              r49:hf            r22.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r22:f         r6:f              r41:hf            r57.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r41:f         r6:f              r49:hf            r57.0:hf         {$5}
        sync.nop                             null                             {Compacted,$5.src}
        send.slm (1|M0)          r57      r75     null:0  0x0            0x0280E700           {$9} // wr:1+0, rd:8; load.slm.d64x32t.a32
        send.slm (1|M0)          r49      r81     null:0  0x0            0x0280E700           {A@4,$12} // wr:1+0, rd:8; load.slm.d64x32t.a32
        send.slm (1|M0)          r81      r89     null:0  0x0            0x0280E700           {A@3,$6} // wr:1+0, rd:8; load.slm.d64x32t.a32
        or (1|M0)                r89.0<1>:d    r1.4<0;1,0>:d     14592:w               {$6.src}
        sync.allwr                           ($5,$6,$8,$9,$12,$15)                
        dpas.8x8 (8|M0)          r14:f         r14:f             r49:hf            r66.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r30:f         r30:f             r81:hf            r66.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r41:f         r41:f             r81:hf            r57.0:hf         {$8}
        or (1|M0)                r81.0<1>:d    r1.4<0;1,0>:d     14336:w               {$8.src}
        send.slm (1|M0)          r66      r80     null:0  0x0            0x0280E700           {$7} // wr:1+0, rd:8; load.slm.d64x32t.a32
        dpas.8x8 (8|M0)          r22:f         r22:f             r49:hf            r57.0:hf         {$9}
        sync.nop                             null                             {Compacted,$9.src}
        send.slm (1|M0)          r57      r78     null:0  0x0            0x0280E700           {$12} // wr:1+0, rd:8; load.slm.d64x32t.a32
        send.slm (1|M0)          r49      r81     null:0  0x0            0x0280E700           {A@1,$15} // wr:1+0, rd:8; load.slm.d64x32t.a32
        send.slm (1|M0)          r81      r89     null:0  0x0            0x0280E700           {$5} // wr:1+0, rd:8; load.slm.d64x32t.a32
        or (1|M0)                r89.0<1>:d    r1.4<0;1,0>:d     15616:w               {$5.src}
        sync.allwr                           ($5,$7,$8,$12,$15)                
        dpas.8x8 (8|M0)          r14:f         r14:f             r49:hf            r66.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r30:f         r30:f             r81:hf            r66.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r41:f         r41:f             r81:hf            r57.0:hf         {$8}
        or (1|M0)                r81.0<1>:d    r1.4<0;1,0>:d     15360:w               {$8.src}
        dpas.8x8 (8|M0)          r22:f         r22:f             r49:hf            r57.0:hf         {$9}
        send.slm (1|M0)          r66      r76     null:0  0x0            0x0280E700           {$6} // wr:1+0, rd:8; load.slm.d64x32t.a32
        sync.nop                             null                             {Compacted,$9.src}
        send.slm (1|M0)          r57      r74     null:0  0x0            0x0280E700           {$7} // wr:1+0, rd:8; load.slm.d64x32t.a32
        send.slm (1|M0)          r49      r81     null:0  0x0            0x0280E700           {A@1,$12} // wr:1+0, rd:8; load.slm.d64x32t.a32
        send.slm (1|M0)          r81      r89     null:0  0x0            0x0280E700           {$15} // wr:1+0, rd:8; load.slm.d64x32t.a32
        sync.allwr                           ($6,$7,$8,$9,$12,$15)                
        dpas.8x8 (8|M0)          r14:f         null:f            r14:hf            r14.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r14:f         r14:f             r49:hf            r66.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r22:f         r22:f             r49:hf            r57.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r30:f         r30:f             r81:hf            r66.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r41:f         r41:f             r81:hf            r57.0:hf         {$8}
        or (1|M0)                r49.0<1>:d    r1.0<0;1,0>:d     r39.0<0;1,0>:d   {Compacted,$8.src}
        or (1|M0)                r1.0<1>:ud    r49.0<0;1,0>:ud   0x400:uw              {I@1}
        mov (8|M0)               r52.0<1>:f    r14.0<1;1,0>:f                   {Compacted,$8.dst}
        mov (8|M0)               r50.0<1>:f    r22.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r53.0<1>:f    r30.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r51.0<1>:f    r41.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r49     r52:2   0x0            0x0200C704           {A@2,$5} // wr:1+2, rd:0; store.slm.d64x8t.a32
        send.slm (1|M0)          null     r1      r50:2   0x0            0x0200C704           {A@1,$6} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r52.0<1>:f    r15.0<1;1,0>:f                   {Compacted,$5.src}
        mov (8|M0)               r53.0<1>:f    r31.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r1.0<1>:ud    r49.0<0;1,0>:ud   0x80:uw              {$6.src}
        mov (8|M0)               r50.0<1>:f    r23.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r1      r52:2   0x0            0x0200C704           {A@1,$7} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r51.0<1>:f    r42.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r1.0<1>:ud    r49.0<0;1,0>:ud   0x480:uw              {$7.src}
        mov (8|M0)               r52.0<1>:f    r16.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r1      r50:2   0x0            0x0200C704           {A@1,$8} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r53.0<1>:f    r32.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r1.0<1>:ud    r49.0<0;1,0>:ud   0x100:uw              {$8.src}
        mov (8|M0)               r50.0<1>:f    r24.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r1      r52:2   0x0            0x0200C704           {A@1,$9} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r51.0<1>:f    r43.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r1.0<1>:ud    r49.0<0;1,0>:ud   0x500:uw              {$9.src}
        mov (8|M0)               r52.0<1>:f    r17.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r1      r50:2   0x0            0x0200C704           {A@1,$12} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r53.0<1>:f    r33.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r1.0<1>:ud    r49.0<0;1,0>:ud   0x180:uw              {$12.src}
        mov (8|M0)               r50.0<1>:f    r25.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r1      r52:2   0x0            0x0200C704           {A@1,$15} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r51.0<1>:f    r44.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r1.0<1>:ud    r49.0<0;1,0>:ud   0x580:uw              {$15.src}
        mov (8|M0)               r52.0<1>:f    r18.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r1      r50:2   0x0            0x0200C704           {A@1,$5} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r53.0<1>:f    r34.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r1.0<1>:ud    r49.0<0;1,0>:ud   0x200:uw              {$5.src}
        mov (8|M0)               r50.0<1>:f    r26.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r1      r52:2   0x0            0x0200C704           {A@1,$6} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r51.0<1>:f    r45.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r1.0<1>:ud    r49.0<0;1,0>:ud   0x600:uw              {$6.src}
        mov (8|M0)               r52.0<1>:f    r19.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r1      r50:2   0x0            0x0200C704           {A@1,$7} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r53.0<1>:f    r35.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r1.0<1>:ud    r49.0<0;1,0>:ud   0x280:uw              {$7.src}
        mov (8|M0)               r50.0<1>:f    r27.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r1      r52:2   0x0            0x0200C704           {A@1,$8} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r51.0<1>:f    r46.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r1.0<1>:ud    r49.0<0;1,0>:ud   0x680:uw              {$8.src}
        mov (8|M0)               r52.0<1>:f    r20.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r1      r50:2   0x0            0x0200C704           {A@1,$9} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r53.0<1>:f    r36.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r1.0<1>:ud    r49.0<0;1,0>:ud   0x300:uw              {$9.src}
        mov (8|M0)               r50.0<1>:f    r28.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r1      r52:2   0x0            0x0200C704           {A@1,$12} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r51.0<1>:f    r47.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r1.0<1>:ud    r49.0<0;1,0>:ud   0x700:uw              {$12.src}
        mov (8|M0)               r14.0<1>:f    r21.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r1      r50:2   0x0            0x0200C704           {A@1,$15} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r15.0<1>:f    r37.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r1.0<1>:ud    r49.0<0;1,0>:ud   0x380:uw              {$15.src}
        mov (8|M0)               r16.0<1>:f    r29.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r1      r14:2   0x0            0x0200C704           {A@1,$5} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r17.0<1>:f    r48.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r1.0<1>:ud    r49.0<0;1,0>:ud   0x780:uw              {$5.src}
        send.slm (1|M0)          null     r1      r16:2   0x0            0x0200C704           {A@1,$6} // wr:1+2, rd:0; store.slm.d64x8t.a32
(~f1.1.any16h) goto (16|M0)                  L23840                  L23840                
L23792:
(W)     mov (1|M0)               f1.1<1>:uw    0x0:uw                             
        mov (1|M0)               r1.0<1>:d     1:w                               {$6.src}
        goto.b (16|M0)                       L23840                  L22192                
L23840:
        join (16|M0)                         L31928                                
L23856:
(W)     send.slm (1|M0)          r14      r0      null:0  0x0            0x0210001F           {$7} // wr:1+0, rd:1; fence.slm.none.group
(W)     mov (8|M0)               null<1>:ud    r14.0<1;1,0>:ud                  {$7.dst}
(W)     mov (1|M0)               r14.2<1>:f    0.0:f                               {Compacted,I@1}
(W)     mov (2|M0)               r14.10<1>:ub  r0.11<0;1,0>:ub                  {F@1}
(W)     send.gtwy (1|M0)         null     r14     null:0  0x0            0x02000004           {A@1,$8} // wr:1+0, rd:0; signal barrier
(W)     sync.bar                             null                            
        cmp (1|M0)    (eq)f1.1   null<1>:d     r2.4<0;1,0>:d     8:w              
(W)     and (1|M0)               f1.0<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(f1.0.any16h) goto (16|M0)                   L31152                  L31152                
L23992:
        sync.nop                             null                             {Compacted,$8.src}
        send.slm (1|M0)          r14      r65     null:0  0x0            0x0240D700           {$9} // wr:1+0, rd:4; load.slm.d64x16t.a32
        add (1|M0)               r1.0<1>:ud    r40.0<0;1,0>:ud   0x4000:uw              {$6.src}
        sel (16|M0)   (lt)f0.0   r20.0<1>:f    (abs)r14.0<1;1,0>:f  448.0:f            {Compacted,$9.dst}
        sel (16|M0)   (lt)f0.0   r18.0<1>:f    (abs)r16.0<1;1,0>:f  448.0:f            {Compacted}
        shr (16|M0)              r26.0<1>:ud   r20.0<1;1,0>:ud   0x17:uw              {F@2}
        shr (16|M0)              r24.0<1>:ud   r18.0<1;1,0>:ud   0x17:uw              {F@1}
        sel (16|M0)   (ge)f0.0   r22.0<2>:ub   r26.0<4;1,0>:ub   0x79:uw              {I@2}
        sel (16|M0)   (ge)f0.0   r23.0<2>:ub   r24.0<4;1,0>:ub   0x79:uw              {I@2}
        mov (16|M0)              r26.0<1>:d    r22.0<2;1,0>:ub                  {I@2}
        mov (16|M0)              r24.0<1>:d    r23.0<2;1,0>:ub                  {I@2}
        shl (16|M0)              r26.0<1>:d    r26.0<1;1,0>:d    23:w               {Compacted,I@2}
        shl (16|M0)              r24.0<1>:d    r24.0<1;1,0>:d    23:w               {Compacted,I@2}
        add (16|M0)              r28.0<1>:d    r26.0<1;1,0>:d    -25165824:d               {I@2}
        add (16|M0)              r26.0<1>:d    -r26.0<1;1,0>:d   -2139095040:d              
        add (16|M0)              r22.0<1>:d    r24.0<1;1,0>:d    -25165824:d               {I@3}
        mul (16|M0)              acc0.0<1>:f   r20.0<1;1,0>:f    r26.0<1;1,0>:f   {Compacted,I@2}
        add (16|M0)              r24.0<1>:d    -r24.0<1;1,0>:d   -2139095040:d              
        rnde (16|M0)             acc0.0<1>:f   acc0.0<1;1,0>:f                 
        mul (16|M0)              acc2.0<1>:f   r18.0<1;1,0>:f    r24.0<1;1,0>:f   {Compacted,I@1}
        cmp (16|M0)   (lt)f1.0   null<1>:f     r14.0<1;1,0>:f    0.0:f               {Compacted}
        rnde (16|M0)             acc2.0<1>:f   acc2.0<1;1,0>:f                 
        mul (16|M0)              acc0.0<1>:f   acc0.0<1;1,0>:f   r28.0<1;1,0>:f   {Compacted}
        cmp (16|M0)   (lt)f1.1   null<1>:f     r16.0<1;1,0>:f    0.0:f              
        mul (16|M0)              acc2.0<1>:f   acc2.0<1;1,0>:f   r22.0<1;1,0>:f   {Compacted}
        mov (16|M0)              r24.0<1>:f    (abs)acc0.0<1;1,0>:f             {Compacted}
        mov (16|M0)              r20.0<1>:f    (abs)acc2.0<1;1,0>:f             {Compacted}
(f1.0)  or (16|M0)               r24.0<1>:d    r24.0<1;1,0>:d    -2147483648:d               {F@2}
(f1.1)  or (16|M0)               r20.0<1>:d    r20.0<1;1,0>:d    -2147483648:d               {F@1}
        mov (8|M0)               r14.0<1>:hf   r24.0<1;1,0>:f                   {I@2}
        mov (8|M0)               r14.8<1>:hf   r25.0<1;1,0>:f                  
        mov (8|M0)               r15.0<1>:hf   r20.0<1;1,0>:f                   {I@1}
        send.slm (1|M0)          null     r1      r14:1   0x0            0x0200B704           {A@2,$12} // wr:1+1, rd:0; store.slm.d64x4t.a32
        mov (8|M0)               r15.8<1>:hf   r21.0<1;1,0>:f                  
        add (1|M0)               r1.0<1>:ud    r40.0<0;1,0>:ud   0x4200:uw              {$12.src}
        send.slm (1|M0)          null     r1      r15:1   0x0            0x0200B704           {A@1,$15} // wr:1+1, rd:0; store.slm.d64x4t.a32
(W)     send.slm (1|M0)          r14      r0      null:0  0x0            0x0210001F           {$5} // wr:1+0, rd:1; fence.slm.none.group
(W)     mov (8|M0)               null<1>:ud    r14.0<1;1,0>:ud                  {$5.dst}
(W)     mov (1|M0)               r14.2<1>:f    0.0:f                               {Compacted,I@1}
(W)     mov (2|M0)               r14.10<1>:ub  r0.11<0;1,0>:ub                  {F@1}
(W)     send.gtwy (1|M0)         null     r14     null:0  0x0            0x02000004           {A@1,$7} // wr:1+0, rd:0; signal barrier
(W)     sync.bar                             null                            
        add (1|M0)               r82.0<1>:ud   r3.0<0;1,0>:ud    0x4000:uw             
(W)     mov (1|M0)               f1.0<1>:uw    0x1:uw                             
        mov (1|M0)               r1.4<2>:f     0.0:f                               {$15.src}
        mov (1|M0)               r1.5<2>:f     0.0:f                              
        or (1|M0)                r64.0<1>:ud   r82.0<0;1,0>:ud   0x100:uw              {I@2}
        or (1|M0)                r38.0<1>:ud   r82.0<0;1,0>:ud   0x200:uw             
        or (1|M0)                r1.0<1>:ud    r82.0<0;1,0>:ud   0x300:uw             
L24672:
        shl (1|M0)               r38.4<1>:d    r1.5<0;1,0>:d     8:w               {F@1}
        shr (1|M0)               r1.7<1>:ud    r1.4<0;1,0>:ud    0x18:uw             
        shl (1|M0)               r38.1<1>:d    r1.4<0;1,0>:d     8:w              
        or (1|M0)                r38.2<1>:d    r38.4<0;1,0>:d    r1.7<0;1,0>:d    {I@2}
        shr (1|M0)               r1.7<1>:ud    r38.1<0;1,0>:ud   0x1F:uw              {I@2}
        shl (1|M0)               r38.1<1>:d    r38.1<0;1,0>:d    1:w               {Compacted}
        shl (1|M0)               r38.4<1>:d    r38.2<0;1,0>:d    1:w               {I@3}
        addc (1|M0)              r15.0<1>:ud   r4.6<0;1,0>:ud    r38.1<0;1,0>:ud  {AccWrEn,I@2}
        or (1|M0)                r38.2<1>:d    r38.4<0;1,0>:d    r1.7<0;1,0>:d    {I@2}
        sync.nop                             null                             {Compacted,$4.src}
        mov (1|M0)               r14.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,$7.src}
        mov (1|M0)               r66.0<1>:f    r15.0<0;1,0>:f                   {Compacted,I@3}
        add3 (1|M0)              r66.1<1>:d    r14.0<0;0>:d      r4.7<0;0>:d       r38.2<0>:d       {I@1}
        addc (1|M0)              r14.0<1>:ud   r66.0<0;1,0>:ud   0x100:ud              {AccWrEn,F@1}
        send.ugm (1|M0)          r40      r66     null:0  0x0            0x0280E780           {A@2,$12} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        mov (1|M0)               r15.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        add3 (1|M0)              r14.1<1>:d    r15.0<0;0>:d      r66.1<0;0>:d      0:w               {I@1}
        send.slm (1|M0)          r22      r82     null:0  0x0            0x0280E700           {$15} // wr:1+0, rd:8; load.slm.d64x32t.a32
        send.ugm (1|M0)          r56      r14     null:0  0x0            0x0280E780           {A@1,$5} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        send.slm (1|M0)          r48      r64     null:0  0x0            0x0280E700           {$13} // wr:1+0, rd:8; load.slm.d64x32t.a32
        shl (1|M0)               r1.4<1>:d     r1.4<0;1,0>:d     6:w              
(W)     and (1|M0)               f1.1<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
        sync.allwr                           ($5,$12,$13,$15)                
        dpas.8x8 (8|M0)          r14:f         null:f            r14:hf            r14.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r14:f         r6:f              r40:hf            r22.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r30:f         r6:f              r56:hf            r22.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r22:f         r6:f              r40:hf            r48.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r40:f         r6:f              r56:hf            r48.0:hf         {$12}
        addc (1|M0)              r49.0<1>:ud   r66.0<0;1,0>:ud   0x400:ud              {AccWrEn,$12.src}
        send.slm (1|M0)          r56      r1      null:0  0x0            0x0280E700           {A@3,$0} // wr:1+0, rd:8; load.slm.d64x32t.a32
        mov (1|M0)               r74.0<1>:f    r49.0<0;1,0>:f                   {Compacted,I@1}
        mov (1|M0)               r48.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r76.0<1>:ud   r74.0<0;1,0>:ud   0x100:ud              {AccWrEn,F@1}
        add3 (1|M0)              r74.1<1>:d    r48.0<0;0>:d      r66.1<0;0>:d      0:w               {I@2}
        mov (1|M0)               r75.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r83.0<1>:f    r76.0<0;1,0>:f                   {Compacted,I@3}
        add3 (1|M0)              r83.1<1>:d    r75.0<0;0>:d      r74.1<0;0>:d      0:w               {I@1}
        send.ugm (1|M0)          r48      r74     null:0  0x0            0x0280E780           {$2} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        send.ugm (1|M0)          r74      r83     null:0  0x0            0x0280E780           {A@1,$1} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        send.slm (1|M0)          r66      r38     null:0  0x0            0x0280E700           {$3} // wr:1+0, rd:8; load.slm.d64x32t.a32
        sync.allwr                           ($0,$1,$2,$3,$12)                
(W)     sync.nop                             null                            
(W)     sync.nop                             null                            
        dpas.8x8 (8|M0)          r14:f         null:f            r14:hf            r14.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r14:f         r14:f             r48:hf            r66.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r22:f         r22:f             r48:hf            r56.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r30:f         r30:f             r74:hf            r66.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r40:f         r40:f             r74:hf            r56.0:hf         {$12}
        or (1|M0)                r49.0<1>:d    r1.4<0;1,0>:d     r39.0<0;1,0>:d   {Compacted,$12.src}
        or (1|M0)                r48.0<1>:ud   r49.0<0;1,0>:ud   0x400:uw              {I@1}
        mov (8|M0)               r52.0<1>:f    r14.0<1;1,0>:f                   {Compacted,$12.dst}
        mov (8|M0)               r50.0<1>:f    r22.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r53.0<1>:f    r30.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r51.0<1>:f    r40.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r49     r52:2   0x0            0x0200C704           {A@2,$7} // wr:1+2, rd:0; store.slm.d64x8t.a32
        send.slm (1|M0)          null     r48     r50:2   0x0            0x0200C704           {A@1,$12} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r52.0<1>:f    r15.0<1;1,0>:f                   {Compacted,$7.src}
        mov (8|M0)               r53.0<1>:f    r31.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r48.0<1>:ud   r49.0<0;1,0>:ud   0x80:uw              {$12.src}
        mov (8|M0)               r50.0<1>:f    r23.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r48     r52:2   0x0            0x0200C704           {A@1,$15} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r51.0<1>:f    r41.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r48.0<1>:ud   r49.0<0;1,0>:ud   0x480:uw              {$15.src}
        mov (8|M0)               r52.0<1>:f    r16.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r48     r50:2   0x0            0x0200C704           {A@1,$5} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r53.0<1>:f    r32.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r48.0<1>:ud   r49.0<0;1,0>:ud   0x100:uw              {$5.src}
        mov (8|M0)               r50.0<1>:f    r24.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r48     r52:2   0x0            0x0200C704           {A@1,$11} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r51.0<1>:f    r42.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r48.0<1>:ud   r49.0<0;1,0>:ud   0x500:uw              {$11.src}
        mov (8|M0)               r52.0<1>:f    r17.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r48     r50:2   0x0            0x0200C704           {A@1,$10} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r53.0<1>:f    r33.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r48.0<1>:ud   r49.0<0;1,0>:ud   0x180:uw              {$10.src}
        mov (8|M0)               r50.0<1>:f    r25.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r48     r52:2   0x0            0x0200C704           {A@1,$14} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r51.0<1>:f    r43.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r48.0<1>:ud   r49.0<0;1,0>:ud   0x580:uw              {$14.src}
        mov (8|M0)               r52.0<1>:f    r18.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r48     r50:2   0x0            0x0200C704           {A@1,$7} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r53.0<1>:f    r34.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r48.0<1>:ud   r49.0<0;1,0>:ud   0x200:uw              {$7.src}
        mov (8|M0)               r50.0<1>:f    r26.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r48     r52:2   0x0            0x0200C704           {A@1,$12} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r51.0<1>:f    r44.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r48.0<1>:ud   r49.0<0;1,0>:ud   0x600:uw              {$12.src}
        mov (8|M0)               r52.0<1>:f    r19.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r48     r50:2   0x0            0x0200C704           {A@1,$15} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r53.0<1>:f    r35.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r48.0<1>:ud   r49.0<0;1,0>:ud   0x280:uw              {$15.src}
        mov (8|M0)               r50.0<1>:f    r27.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r48     r52:2   0x0            0x0200C704           {A@1,$5} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r51.0<1>:f    r45.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r48.0<1>:ud   r49.0<0;1,0>:ud   0x680:uw              {$5.src}
        mov (8|M0)               r52.0<1>:f    r20.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r48     r50:2   0x0            0x0200C704           {A@1,$6} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r53.0<1>:f    r36.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r48.0<1>:ud   r49.0<0;1,0>:ud   0x300:uw              {$6.src}
        or (1|M0)                r14.0<1>:ud   r49.0<0;1,0>:ud   0x380:uw             
        send.slm (1|M0)          null     r48     r52:2   0x0            0x0200C704           {A@1,$8} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r15.0<1>:f    r21.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r16.0<1>:f    r37.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r50.0<1>:f    r28.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r51.0<1>:f    r46.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r48.0<1>:ud   r49.0<0;1,0>:ud   0x700:uw              {$8.src}
        mov (8|M0)               r17.0<1>:f    r29.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r48     r50:2   0x0            0x0200C704           {A@1,$9} // wr:1+2, rd:0; store.slm.d64x8t.a32
        send.slm (1|M0)          null     r14     r15:2   0x0            0x0200C704           {$7} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r18.0<1>:f    r47.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r14.0<1>:ud   r49.0<0;1,0>:ud   0x780:uw              {$7.src}
        send.slm (1|M0)          null     r14     r17:2   0x0            0x0200C704           {A@1,$4} // wr:1+2, rd:0; store.slm.d64x8t.a32
(~f1.1.any16h) goto (16|M0)                  L26208                  L26208                
L26144:
(W)     mov (1|M0)               f1.0<1>:uw    0x0:uw                             
        mov (1|M0)               r1.4<2>:f     1.4013e-45:f                              
        mov (1|M0)               r1.5<2>:d     0:d                              
        goto.b (16|M0)                       L26208                  L24672                
L26208:
        join (16|M0)                         L31152                                
L26224:
(W)     send.slm (1|M0)          r6       r0      null:0  0x0            0x0210001F           {$12} // wr:1+0, rd:1; fence.slm.none.group
(W)     mov (8|M0)               null<1>:ud    r6.0<1;1,0>:ud                   {$12.dst}
(W)     mov (1|M0)               r6.2<1>:f     0.0:f                               {Compacted,I@1}
(W)     mov (2|M0)               r6.10<1>:ub   r0.11<0;1,0>:ub                  {F@1}
(W)     send.gtwy (1|M0)         null     r6      null:0  0x0            0x02000004           {A@1,$15} // wr:1+0, rd:0; signal barrier
(W)     sync.bar                             null                            
        cmp (1|M0)    (eq)f1.0   null<1>:d     r2.4<0;1,0>:d     9:w              
(W)     and (1|M0)               f1.0<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
(~f1.0.any16h) goto (16|M0)                  L27112                  L27112                
L26360:
(W)     and (1|M0)               f0.0<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
        shl (1|M0)               r3.1<1>:ud    r3.1<0;1,0>:ud    0x8:uw             
        add (1|M0)               r3.1<1>:ud    r3.1<0;1,0>:ud    0x7000:uw              {I@1}
(f0.0.any16h) goto (16|M0)                   L27112                  L34280                
L26424:
        shl (1|M0)               r4.1<1>:d     r3.7<0;1,0>:d     12:w              
        shr (1|M0)               r4.0<1>:ud    r3.6<0;1,0>:ud    0x14:uw             
        shl (1|M0)               r3.2<1>:d     r3.6<0;1,0>:d     12:w              
        or (1|M0)                r3.3<1>:d     r4.1<0;1,0>:d     r4.0<0;1,0>:d    {I@2}
        shr (1|M0)               r3.0<1>:ud    r3.2<0;1,0>:ud    0x1F:uw              {I@2}
        shl (1|M0)               r3.2<1>:d     r3.2<0;1,0>:d     1:w              
        shl (1|M0)               r2.0<1>:d     r38.3<0;1,0>:d    1:w               {Compacted}
        shl (1|M0)               r3.4<1>:d     r3.3<0;1,0>:d     1:w               {I@4}
        addc (1|M0)              r4.0<1>:ud    r4.2<0;1,0>:ud    r3.2<0;1,0>:ud   {AccWrEn,I@3}
        shr (1|M0)               r2.2<1>:ud    r38.3<0;1,0>:ud   0x1F:uw             
        or (1|M0)                r3.3<1>:d     r3.4<0;1,0>:d     r3.0<0;1,0>:d    {I@3}
        mov (1|M0)               r3.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r38.0<1>:ud   r4.0<0;1,0>:ud    r2.0<0;1,0>:ud   {AccWrEn,I@4}
        or (1|M0)                r2.1<1>:d     r2.2<0;1,0>:d     0:w               {I@4}
        add3 (1|M0)              r2.5<1>:d     r3.0<0;0>:d       r4.3<0;0>:d       r3.3<0>:d        {I@3}
        mov (1|M0)               r3.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r2.4<2>:f     0.0:f                              
        mov (1|M0)               r2.2<1>:d     r38.0<0;1,0>:d                   {I@4}
        add3 (1|M0)              r2.3<1>:d     r3.0<0;0>:d       r2.5<0;0>:d       r2.1<0>:d        {I@2}
        mov (1|M0)               r2.5<2>:f     0.0:f                               {I@1}
L26720:
        bfn.0xEA (1|M0)          r2.0<1>:ud    r2.4<0;0>:ud      r38.3<0;0>:ud     0x1E0:uw              {F@2} // s0|s1&s2
(W)     mov (1|M0)               r3.0<1>:f     9.401659e-38:f                              
        shl (1|M0)               r2.0<1>:ud    r2.0<0;1,0>:ud    0x2:uw              {I@1}
        shl (1|M0)               r2.1<1>:d     r2.5<0;1,0>:d     1:w               {F@2}
        bfn.0xEA (1|M0)          r3.0<1>:ud    r2.0<0;0>:ud      r3.1<0;0>:ud      r3.0<0>:ud       {A@1} // s0|s1&s2
        shl (1|M0)               r3.2<1>:d     r2.4<0;1,0>:d     1:w              
        send.slm (1|M0)          r3       r3      null:0  0x0            0x02100500           {A@1,$5} // wr:1+0, rd:1; load.slm.d32.a32
        shr (1|M0)               r2.0<1>:ud    r2.4<0;1,0>:ud    0x1F:uw             
        sync.nop                             null                             {Compacted,$5.dst}
        or (1|M0)                r3.3<1>:d     r2.1<0;1,0>:d     r2.0<0;1,0>:d    {I@1}
        addc (1|M0)              r2.0<1>:ud    r2.2<0;1,0>:ud    r3.2<0;1,0>:ud   {AccWrEn}
        mov (1|M0)               r2.12<2>:hf   r3.0<0;1,0>:f                   
        mov (1|M0)               r3.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,F@1}
        mov (1|M0)               r38.0<1>:d    r2.12<0;1,0>:uw                 
        add3 (1|M0)              r2.1<1>:d     r3.0<0;0>:d       r2.3<0;0>:d       r3.3<0>:d        {I@2}
        addc (1|M0)              r3.0<1>:ud    r2.4<0;1,0>:ud    0x1:ud              {AccWrEn}
        send.ugm (1|M0)          null     r2      r38:1   0x0            0x04000B84           {A@1,$7} // wr:2+1, rd:0; store.ugm.d16u32.a64
        mov (1|M0)               r2.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$7.src}
        mov (1|M0)               r2.6<1>:d     r3.0<0;1,0>:d                   
        add3 (1|M0)              r2.7<1>:d     r2.0<0;0>:d       r2.5<0;0>:d       0:w               {I@2}
        cmp (1|M0)    (eq)f0.0   null<1>:d     r2.7<0;1,0>:d     0:w               {I@1}
(f0.0)  cmp (1|M0)    (eq)f0.0   null<1>:d     r2.6<0;1,0>:d     32:w              
(W)     and (1|M0)               f1.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
(f1.1.any16h) goto (16|M0)                   L27112                  L34280                
L27080:
(W)     mov (2|M0)               r2.4<1>:ud    r2.6<1;1,0>:ud                  
        goto.b (16|M0)                       L27112                  L26720                
L27112:
        join (16|M0)                         L31152                                
L27128:
(W)     and (1|M0)               f1.0<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(~f1.0.any16h) goto (16|M0)                  L31152                  L34280                
L27160:
        cmp (1|M0)    (gt)f0.0   null<1>:d     r1.2<0;1,0>:d     -1:w              
        cmp (1|M0)    (lt)f1.0   null<1>:d     r1.2<0;1,0>:d     r2.7<0;1,0>:d   
(W)     mov (1|M0)               r1.0<1>:hf    0x1:hf                             
(f0.0)  cmp (1|M0)    (lt)f0.0   null<1>:d     r1.6<0;1,0>:d     r2.6<0;1,0>:d   
(f0.0)  sel (1|M0)               r1.1<1>:uw    r1.0<0;1,0>:uw    0x0:uw              {F@1}
(f1.0)  sel (1|M0)               r1.0<1>:uw    r1.0<0;1,0>:uw    0x0:uw             
        and (1|M0)    (ne)f1.1   null<1>:uw    r1.1<0;1,0>:uw    r1.0<0;1,0>:uw   {I@1}
(W)     and (1|M0)               f0.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(~f0.1.any16h) goto (16|M0)                  L31152                  L34280                
L27304:
        mul (1|M0)               acc0.0<1>:ud  r1.6<0;1,0>:ud    r2.14<0;1,0>:uw 
        mach (1|M0)              r7.0<1>:ud    r1.6<0;1,0>:ud    r2.7<0;1,0>:ud   {AccWrEn}
        cmp (1|M0)    (eq)f1.0   null<1>:w     r1.6<0;1,0>:b     0:w              
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$15.src}
        addc (1|M0)              r3.0<1>:ud    r6.0<0;1,0>:ud    r1.2<0;1,0>:ud   {AccWrEn,I@1}
(W)     and (1|M0)               f0.0<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
        mov (1|M0)               r1.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        shl (1|M0)               r1.4<1>:d     r3.0<0;1,0>:d     5:w               {Compacted,I@3}
        add3 (1|M0)              r1.5<1>:d     r1.0<0;0>:d       r7.0<0;0>:d       0:w               {I@2}
        shr (1|M0)               r1.0<1>:ud    r3.0<0;1,0>:ud    0x1B:uw             
        shl (1|M0)               r1.2<1>:d     r1.5<0;1,0>:d     5:w               {I@2}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.0<0;1,0>:d    {I@1}
(f0.0.any16h) goto (16|M0)                   L27688                  L27688                
L27488:
        shl (1|M0)               r1.0<1>:d     r1.4<0;1,0>:d     1:w               {Compacted}
        shl (1|M0)               r1.6<1>:d     r1.5<0;1,0>:d     1:w               {I@3}
        shr (1|M0)               r1.2<1>:ud    r1.4<0;1,0>:ud    0x1F:uw             
        addc (1|M0)              r2.0<1>:ud    r3.2<0;1,0>:ud    r1.0<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r1.1<1>:d     r1.6<0;1,0>:d     r1.2<0;1,0>:d    {I@2}
        mov (1|M0)               r3.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r4.0<1>:f     r2.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r4.1<1>:d     r3.0<0;0>:d       r3.3<0;0>:d       r1.1<0>:d        {I@1}
        send.ugm (1|M0)          r2       r4      null:0  0x0            0x0220C780           {A@1,$12} // wr:1+0, rd:2; load.ugm.d64x8t.a64
        mov (8|M0)               r10.0<1>:f    r2.0<1;1,0>:hf                   {$12.dst}
        mov (8|M0)               r11.0<1>:f    r2.8<1;1,0>:hf                  
        mov (8|M0)               r12.0<1>:f    r3.0<1;1,0>:hf                  
        mov (8|M0)               r13.0<1>:f    r3.8<1;1,0>:hf                  
        goto (16|M0)                         L27688                  L27832                
L27688:
        join (16|M0)                         L27832                                
L27704:
        shl (1|M0)               r1.6<1>:d     r1.4<0;1,0>:d     2:w              
        shl (1|M0)               r3.1<1>:d     r1.5<0;1,0>:d     2:w               {F@2}
        shr (1|M0)               r3.0<1>:ud    r1.4<0;1,0>:ud    0x1E:uw             
        addc (1|M0)              r2.0<1>:ud    r3.2<0;1,0>:ud    r1.6<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r1.7<1>:d     r3.1<0;1,0>:d     r3.0<0;1,0>:d    {I@2}
        mov (1|M0)               r3.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r1.0<1>:f     r2.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r1.1<1>:d     r3.0<0;0>:d       r3.3<0;0>:d       r1.7<0>:d        {I@1}
        send.ugm (1|M0)          r10      r1      null:0  0x0            0x0240E580           {A@1,$5} // wr:1+0, rd:4; load.ugm.d32x32t.a64
L27832:
        join (16|M0)                         L31152                                
L27848:
        sync.nop                             null                             {Compacted,$4.src}
        send.ugm (1|M0)          r14      r5      null:0  0x0            0x0240E580           {$7} // wr:1+0, rd:4; load.ugm.d32x32t.a64
        cmp (1|M0)    (lt)f0.1   null<1>:d     r5.2<0;1,0>:d     1:w              
        send.slm (1|M0)          r6       r65     null:0  0x0            0x0240D700           {$12} // wr:1+0, rd:4; load.slm.d64x16t.a32
(W)     and (1|M0)               f1.1<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
        sync.allwr                           ($7,$12)                
        mad (16|M0)              r6.0<1>:f     r6.0<1;0>:f       r14.0<1;0>:f      r10.0<1>:f       {Compacted,$5.dst}
        mad (16|M0)              r8.0<1>:f     r8.0<1;0>:f       r16.0<1;0>:f      r12.0<1>:f       {Compacted}
(f1.1.any16h) goto (16|M0)                   L28632                  L28632                
L27968:
        cmp (1|M0)    (lt)f0.0   null<1>:d     r5.2<0;1,0>:d     4:w              
(W)     and (1|M0)               f1.0<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
(f1.0.any16h) goto (16|M0)                   L28208                  L28208                
L28016:
        cmp (1|M0)    (eq)f1.1   null<1>:d     r5.2<0;1,0>:d     4:w              
(W)     and (1|M0)               f0.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(~f0.1.any16h) goto (16|M0)                  L28208                  L28696                
L28064:
        mov (8|M0)               r3.0<1>:hf    r6.0<1;1,0>:f                    {F@2}
        mov (8|M0)               r3.8<1>:hf    r7.0<1;1,0>:f                   
        mov (8|M0)               r2.0<1>:hf    r8.0<1;1,0>:f                    {F@3}
        mov (8|M0)               r2.8<1>:hf    r9.0<1;1,0>:f                   
        mov (8|M0)               r6.0<1>:f     r3.0<1;1,0>:hf                   {F@4}
        mov (8|M0)               r7.0<1>:f     r3.8<1;1,0>:hf                   {F@4}
        mov (8|M0)               r8.0<1>:f     r2.0<1;1,0>:hf                   {F@4}
        mov (8|M0)               r9.0<1>:f     r2.8<1;1,0>:hf                   {F@4}
        goto (16|M0)                         L28208                  L29808                
L28208:
        join (16|M0)                         L28632                                
L28224:
        cmp (1|M0)    (eq)f1.0   null<1>:d     r5.2<0;1,0>:d     1:w              
(W)     and (1|M0)               f0.0<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
(~f0.0.any16h) goto (16|M0)                  L28632                  L28696                
L28272:
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
        goto (16|M0)                         L28632                  L29808                
L28632:
        join (16|M0)                         L28696                                
L28648:
        cmp (1|M0)    (eq)f1.1   null<1>:d     r5.2<0;1,0>:d     0:w              
(W)     and (1|M0)               f1.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(f1.1.any16h) goto (16|M0)                   L28696                  L29808                
L28696:
        join (16|M0)                         L29808                                
L28712:
        and (1|M0)               r1.7<1>:d     r5.2<0;1,0>:d     -2:w              
        and (1|M0)               r1.6<1>:d     r5.2<0;1,0>:d     -3:w              
        mov (1|M0)               r1.2<1>:d     0:w                              
L28760:
        cmp (1|M0)    (eq)f1.0   null<1>:d     r1.7<0;1,0>:d     2:w               {I@3}
        shl (1|M0)               r1.2<1>:w     r1.4<0;1,0>:w     2:w               {I@2}
        add (1|M0)               a0.0<1>:uw    r1.2<0;1,0>:uw    0xC0:uw              {A@1}
(W)     and (1|M0)               f1.0<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
        mov (1|M0)               r2.0<1>:f     r[a0.0]<0;1,0>:f                 {F@1}
(~f1.0.any16h) goto (16|M0)                  L29088                  L29088                 {A@1}
L28856:
        mov (1|M0)               r2.0<2>:hf    r[a0.0]<0;1,0>:f                
        cmp (1|M0)    (lt)f0.1   null<1>:f     r[a0.0]<0;1,0>:f  -4.001953e+00:f               {A@1}
        mov (1|M0)               r2.1<1>:f     r2.0<0;1,0>:hf                   {A@1}
        mov (1|M0)               r2.2<1>:ud    0xBD650000:ud                             
        sel (1|M0)    (lt)f0.0   r2.1<1>:f     r2.1<0;1,0>:f     4.0:f               {F@1}
        mov (1|M0)               r1.0<1>:ud    0x3EE50000:ud                             
(~f0.1) sel (1|M0)               r2.1<1>:f     r2.1<0;1,0>:f     -4.0:f               {F@1}
        mad (1|M0)               r2.2<1>:f     r1.0<0;0>:f       r2.2<0;0>:f       (abs)r2.1<0>:f   {A@1}
        mov (1|M0)               r1.0<2>:hf    r2.2<0;1,0>:f                    {F@1}
        mov (1|M0)               r1.0<1>:f     r1.0<0;1,0>:hf                   {F@1}
        mul (1|M0)               r2.1<1>:f     r2.1<0;1,0>:f     r1.0<0;1,0>:f    {Compacted,F@1}
        mov (1|M0)               r2.2<2>:hf    r2.1<0;1,0>:f                    {F@1}
        add (1|M0)               r2.2<1>:hf    r2.2<0;1,0>:hf    0x3B28:hf              {F@1}
        mul (1|M0)               r2.2<1>:hf    r2.2<0;1,0>:hf    r2.0<0;1,0>:hf   {F@1}
        mov (1|M0)               r2.0<1>:f     r2.2<0;1,0>:hf                   {F@1}
L29088:
        join (16|M0)                         L29768                                
L29104:
        cmp (1|M0)    (eq)f0.0   null<1>:d     r1.6<0;1,0>:d     1:w              
(W)     and (1|M0)               f0.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
(f0.1.any16h) goto (16|M0)                   L29232                  L29232                
L29152:
        cmp (1|M0)    (eq)f1.1   null<1>:d     r5.2<0;1,0>:d     4:w              
        mov (1|M0)               r1.0<2>:hf    r2.0<0;1,0>:f                    {F@1}
        mov (1|M0)               r2.2<1>:f     r1.0<0;1,0>:hf                   {F@1}
(~f1.1) mov (1|M0)               r2.2<1>:f     r2.0<0;1,0>:f                   
        goto (16|M0)                         L29232                  L29656                
L29232:
        join (16|M0)                         L29656                                
L29248:
        cmp (1|M0)    (lt)f0.1   null<1>:f     r2.0<0;1,0>:f     0.0:f               {A@4}
(f0.1)  mov (1|M0)               r2.0<1>:f     -r2.0<0;1,0>:f                  
        sel (1|M0)    (lt)f0.0   r2.0<1>:f     r2.0<0;1,0>:f     448.0:f               {F@1}
        shr (1|M0)               r2.1<1>:ud    r2.0<0;1,0>:ud    0x17:uw              {F@1}
        and (1|M0)               r2.1<1>:ud    r2.1<0;1,0>:ud    0xFF:uw              {I@1}
        sel (1|M0)    (ge)f0.0   r2.1<1>:ud    r2.1<0;1,0>:ud    0x79:uw              {I@1}
        shl (1|M0)               r2.1<1>:ud    r2.1<0;1,0>:ud    0x17:uw              {I@1}
        add (1|M0)               r2.4<1>:ud    -r2.1<0;1,0>:ud   0x80800000:ud              {I@1}
        mul (1|M0)               r1.0<1>:f     r2.0<0;1,0>:f     r2.4<0;1,0>:f    {Compacted,I@1}
        mov (1|M0)               r2.3<1>:d     r1.0<0;1,0>:f                    {Compacted,F@1}
        mov (1|M0)               r2.2<1>:f     r2.3<0;1,0>:d                    {I@1}
        mad (1|M0)               r2.0<1>:f     -r2.2<0;0>:f      r2.4<0;0>:f       r2.0<0>:f        {F@1}
        cmp (1|M0)    (gt)f1.0   null<1>:f     r2.0<0;1,0>:f     0.5:f               {F@1}
(W)     and (1|M0)               f0.0<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
(f0.0.any16h) goto (16|M0)                   L29560                  L29560                
L29472:
        cmp (1|M0)    (lt)f1.1   null<1>:f     r2.0<0;1,0>:f     0.5:f              
        and (1|M0)               r2.3<1>:d     r2.3<0;1,0>:d     1:w               {Compacted}
        add (1|M0)               r2.4<1>:f     r2.2<0;1,0>:f     1.0:f              
(~f1.1) cmp (1|M0)    (eq)f1.1   null<1>:d     r2.3<0;1,0>:d     0:w               {A@1}
(~f1.1) mov (1|M0)               r2.2<1>:f     r2.4<0;1,0>:f                    {F@1}
        goto (16|M0)                         L29560                  L29592                
L29560:
        join (16|M0)                         L29592                                
L29576:
        add (1|M0)               r2.2<1>:f     r2.2<0;1,0>:f     1.0:f               {F@1}
L29592:
        join (16|M0)                         L29656                                
L29608:
        add (1|M0)               r2.1<1>:ud    r2.1<0;1,0>:ud    0xFE800000:ud             
        mul (1|M0)               r2.2<1>:f     r2.2<0;1,0>:f     r2.1<0;1,0>:f    {A@1}
(f0.1)  mov (1|M0)               r2.2<1>:f     -r2.2<0;1,0>:f                   {F@1}
L29656:
        join (16|M0)                         L29768                                
L29672:
        add (1|M0)               r1.2<1>:d     r1.2<0;1,0>:d     1:w              
        add (1|M0)               a0.0<1>:uw    r1.2<0;1,0>:uw    0x140:uw              {A@1}
        cmp (1|M0)    (eq)f0.1   null<1>:d     r1.2<0;1,0>:d     32:w               {A@1}
        mov (1|M0)               r[a0.0]<1>:f  r2.2<0;1,0>:f                   
(W)     and (1|M0)               f1.1<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(~f1.1.any16h) goto.b (16|M0)                L29768                  L28760                
L29768:
        join (16|M0)                         L29808                                
L29784:
        mov (16|M0)              r6.0<1>:ud    r10.0<1;1,0>:ud                  {F@1}
        mov (16|M0)              r8.0<1>:f     r12.0<1;1,0>:f                   {Compacted}
L29808:
        join (16|M0)                         L31152                                
L29824:
        cmp (1|M0)    (eq)f0.0   null<1>:w     r1.12<0;1,0>:b    0:w              
(W)     and (1|M0)               f1.0<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
(f1.0.any16h) goto (16|M0)                   L31000                  L31000                
L29872:
        shl (1|M0)               r5.2<1>:d     r1.4<0;1,0>:d     1:w              
        shl (1|M0)               r1.1<1>:d     r1.5<0;1,0>:d     1:w              
        shr (1|M0)               r1.0<1>:ud    r1.4<0;1,0>:ud    0x1F:uw             
        addc (1|M0)              r5.0<1>:ud    r5.4<0;1,0>:ud    r5.2<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r5.3<1>:d     r1.1<0;1,0>:d     r1.0<0;1,0>:d    {I@2}
        mov (1|M0)               r1.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (8|M0)               r10.0<1>:hf   r8.0<1;1,0>:f                    {F@1}
        add3 (1|M0)              r5.1<1>:d     r1.0<0;0>:d       r5.5<0;0>:d       r5.3<0>:d        {I@1}
        mov (4|M0)               r1.0<1>:w     0x64206420:v                              
        mov (8|M0)               r10.8<1>:hf   r9.0<1;1,0>:f                   
        mov (4|M0)               r1.0<4>:uw    r1.0<1;1,0>:uw                   {I@1}
        mov (8|M0)               r15.0<1>:hf   r6.0<1;1,0>:f                   
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
        send.ugm (16|M0)         null     r2      r11:2   0x0            0x08000B84           {$7} // wr:4+2, rd:0; store.ugm.d16u32.a64
        send.ugm (16|M0)         null     r6      r13:2   0x0            0x08000B84           {A@1,$12} // wr:4+2, rd:0; store.ugm.d16u32.a64
        goto (16|M0)                         L31000                  L34280                
L31000:
        join (16|M0)                         L31152                                
L31016:
        shl (1|M0)               r1.0<1>:d     r1.4<0;1,0>:d     2:w               {Compacted}
        shl (1|M0)               r1.3<1>:d     r1.5<0;1,0>:d     2:w              
        shr (1|M0)               r1.2<1>:ud    r1.4<0;1,0>:ud    0x1E:uw             
        sync.nop                             null                             {Compacted,$7.src}
        addc (1|M0)              r3.0<1>:ud    r5.6<0;1,0>:ud    r1.0<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r1.1<1>:d     r1.3<0;1,0>:d     r1.2<0;1,0>:d    {I@2}
        mov (1|M0)               r2.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        add3 (1|M0)              r3.1<1>:d     r2.0<0;0>:d       r5.7<0;0>:d       r1.1<0>:d        {I@1}
        send.ugm (1|M0)          null     r3      r6:4    0x0            0x0200E584           {A@1,$13} // wr:1+4, rd:0; store.ugm.d32x32t.a64
        goto (16|M0)                         L31152                  L34280                
L31152:
        join (16|M0)                         L31928                                
L31168:
(W)     and (1|M0)               f0.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
        sync.nop                             null                             {Compacted,$13.src}
        shl (1|M0)               r3.1<1>:ud    r3.1<0;1,0>:ud    0x8:uw              {$7.src}
        add (1|M0)               r3.1<1>:ud    r3.1<0;1,0>:ud    0x7000:uw              {I@1}
(f0.1.any16h) goto (16|M0)                   L31928                  L34280                
L31240:
        shl (1|M0)               r4.1<1>:d     r3.7<0;1,0>:d     12:w              
        shr (1|M0)               r4.0<1>:ud    r3.6<0;1,0>:ud    0x14:uw             
        shl (1|M0)               r3.2<1>:d     r3.6<0;1,0>:d     12:w              
        or (1|M0)                r3.3<1>:d     r4.1<0;1,0>:d     r4.0<0;1,0>:d    {I@2}
        shr (1|M0)               r3.0<1>:ud    r3.2<0;1,0>:ud    0x1F:uw              {I@2}
        shl (1|M0)               r3.2<1>:d     r3.2<0;1,0>:d     1:w              
        shl (1|M0)               r2.0<1>:d     r38.3<0;1,0>:d    1:w               {Compacted}
        shl (1|M0)               r3.4<1>:d     r3.3<0;1,0>:d     1:w               {I@4}
        addc (1|M0)              r4.0<1>:ud    r4.2<0;1,0>:ud    r3.2<0;1,0>:ud   {AccWrEn,I@3}
        shr (1|M0)               r2.2<1>:ud    r38.3<0;1,0>:ud   0x1F:uw             
        or (1|M0)                r3.3<1>:d     r3.4<0;1,0>:d     r3.0<0;1,0>:d    {I@3}
        mov (1|M0)               r3.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r38.0<1>:ud   r4.0<0;1,0>:ud    r2.0<0;1,0>:ud   {AccWrEn,I@4}
        or (1|M0)                r2.1<1>:d     r2.2<0;1,0>:d     0:w               {I@4}
        add3 (1|M0)              r2.5<1>:d     r3.0<0;0>:d       r4.3<0;0>:d       r3.3<0>:d        {I@3}
        mov (1|M0)               r3.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r2.4<2>:f     0.0:f                              
        mov (1|M0)               r2.2<1>:d     r38.0<0;1,0>:d                   {I@4}
        add3 (1|M0)              r2.3<1>:d     r3.0<0;0>:d       r2.5<0;0>:d       r2.1<0>:d        {I@2}
        mov (1|M0)               r2.5<2>:f     0.0:f                               {I@1}
L31536:
        bfn.0xEA (1|M0)          r2.0<1>:ud    r2.4<0;0>:ud      r38.3<0;0>:ud     0x1E0:uw              {F@2} // s0|s1&s2
(W)     mov (1|M0)               r3.0<1>:f     9.401659e-38:f                              
        shl (1|M0)               r2.0<1>:ud    r2.0<0;1,0>:ud    0x2:uw              {I@1}
        shl (1|M0)               r2.1<1>:d     r2.5<0;1,0>:d     1:w               {F@2}
        bfn.0xEA (1|M0)          r3.0<1>:ud    r2.0<0;0>:ud      r3.1<0;0>:ud      r3.0<0>:ud       {A@1} // s0|s1&s2
        shl (1|M0)               r3.2<1>:d     r2.4<0;1,0>:d     1:w              
        send.slm (1|M0)          r3       r3      null:0  0x0            0x02100500           {A@1,$0} // wr:1+0, rd:1; load.slm.d32.a32
        shr (1|M0)               r2.0<1>:ud    r2.4<0;1,0>:ud    0x1F:uw             
        sync.nop                             null                             {Compacted,$0.dst}
        or (1|M0)                r3.3<1>:d     r2.1<0;1,0>:d     r2.0<0;1,0>:d    {I@1}
        addc (1|M0)              r2.0<1>:ud    r2.2<0;1,0>:ud    r3.2<0;1,0>:ud   {AccWrEn}
        mov (1|M0)               r2.12<2>:hf   r3.0<0;1,0>:f                   
        mov (1|M0)               r3.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,F@1}
        mov (1|M0)               r38.0<1>:d    r2.12<0;1,0>:uw                 
        add3 (1|M0)              r2.1<1>:d     r3.0<0;0>:d       r2.3<0;0>:d       r3.3<0>:d        {I@2}
        addc (1|M0)              r3.0<1>:ud    r2.4<0;1,0>:ud    0x1:ud              {AccWrEn}
        send.ugm (1|M0)          null     r2      r38:1   0x0            0x04000B84           {A@1,$2} // wr:2+1, rd:0; store.ugm.d16u32.a64
        mov (1|M0)               r2.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$2.src}
        mov (1|M0)               r2.6<1>:d     r3.0<0;1,0>:d                   
        add3 (1|M0)              r2.7<1>:d     r2.0<0;0>:d       r2.5<0;0>:d       0:w               {I@2}
        cmp (1|M0)    (eq)f1.1   null<1>:d     r2.7<0;1,0>:d     0:w               {I@1}
(f1.1)  cmp (1|M0)    (eq)f1.1   null<1>:d     r2.6<0;1,0>:d     32:w              
(W)     and (1|M0)               f0.0<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(f0.0.any16h) goto (16|M0)                   L31928                  L34280                
L31896:
(W)     mov (2|M0)               r2.4<1>:ud    r2.6<1;1,0>:ud                  
        goto.b (16|M0)                       L31928                  L31536                
L31928:
        join (16|M0)                         L32760                                
L31944:
(W)     and (1|M0)               f1.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
(f1.1.any16h) goto (16|M0)                   L32760                  L34280                
L31976:
        shl (1|M0)               r4.1<1>:d     r3.7<0;1,0>:d     12:w               {$7.src}
        shr (1|M0)               r4.0<1>:ud    r3.6<0;1,0>:ud    0x14:uw             
        shl (1|M0)               r3.2<1>:d     r3.6<0;1,0>:d     12:w               {$13.src}
        or (1|M0)                r3.3<1>:d     r4.1<0;1,0>:d     r4.0<0;1,0>:d    {I@2}
        shr (1|M0)               r3.0<1>:ud    r3.2<0;1,0>:ud    0x1F:uw              {I@2}
        shl (1|M0)               r3.2<1>:d     r3.2<0;1,0>:d     1:w              
        shl (1|M0)               r2.4<1>:d     r38.1<0;1,0>:d    1:w              
        shl (1|M0)               r3.4<1>:d     r3.3<0;1,0>:d     1:w               {I@4}
        addc (1|M0)              r4.0<1>:ud    r4.2<0;1,0>:ud    r3.2<0;1,0>:ud   {AccWrEn,I@3}
        shl (1|M0)               r2.3<1>:d     r38.2<0;1,0>:d    1:w              
        shr (1|M0)               r2.2<1>:ud    r38.1<0;1,0>:ud   0x1F:uw             
        or (1|M0)                r3.3<1>:d     r3.4<0;1,0>:d     r3.0<0;1,0>:d    {I@4}
        mov (1|M0)               r3.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r38.0<1>:ud   r4.0<0;1,0>:ud    r2.4<0;1,0>:ud   {AccWrEn,I@5}
        or (1|M0)                r2.5<1>:d     r2.3<0;1,0>:d     r2.2<0;1,0>:d    {I@4}
        add3 (1|M0)              r2.1<1>:d     r3.0<0;0>:d       r4.3<0;0>:d       r3.3<0>:d        {I@3}
        mov (1|M0)               r3.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        shr (1|M0)               r3.1<1>:ud    r3.1<0;1,0>:ud    0x2:uw             
        and (1|M0)               r38.4<1>:ud   r38.4<0;1,0>:ud   0xF0:uw             
        mov (1|M0)               r2.4<2>:f     0.0:f                               {I@6}
        mov (1|M0)               r2.2<1>:d     r38.0<0;1,0>:d                  
        add3 (1|M0)              r2.3<1>:d     r3.0<0;0>:d       r2.1<0;0>:d       r2.5<0>:d        {I@4}
        mov (1|M0)               r2.5<2>:f     0.0:f                               {I@1}
L32328:
        shr (1|M0)               r2.1<1>:ud    r2.4<0;1,0>:ud    0x4:uw              {F@2}
        and (1|M0)               r2.0<1>:d     r2.4<0;1,0>:d     15:w               {Compacted}
        bfn.0xEA (1|M0)          r2.1<1>:ud    r2.1<0;0>:ud      r3.1<0;0>:ud      0x3FFC:uw              {I@2} // s0|s1&s2
        shl (1|M0)               r2.6<1>:d     r2.4<0;1,0>:d     1:w              
        shl (1|M0)               r2.1<1>:ud    r2.1<0;1,0>:ud    0x8:uw              {I@2}
        shl (1|M0)               r3.2<1>:d     r2.5<0;1,0>:d     1:w               {F@1}
        bfn.0xFE (1|M0)          r2.0<1>:ud    r2.0<0;0>:ud      r2.1<0;0>:ud      r38.4<0>:ud      {I@2} // s0|s1|s2
        addc (1|M0)              r38.0<1>:ud   r2.2<0;1,0>:ud    r2.6<0;1,0>:ud   {AccWrEn}
        shl (1|M0)               r2.0<1>:ud    r2.0<0;1,0>:ud    0x1:uw              {I@2}
        add (1|M0)               r3.0<1>:ud    r2.0<0;1,0>:ud    0x5000:uw              {I@1}
        mov (1|M0)               r2.0<1>:f     r38.0<0;1,0>:f                   {Compacted,I@1}
        sync.nop                             null                             {Compacted,$5.src}
        send.slm (1|M0)          r1       r3      null:0  0x0            0x0210B700           {$1} // wr:1+0, rd:1; load.slm.d64x4t.a32
        shr (1|M0)               r3.0<1>:ud    r2.4<0;1,0>:ud    0x1F:uw              {$1.src}
        or (1|M0)                r2.7<1>:d     r3.2<0;1,0>:d     r3.0<0;1,0>:d    {I@1}
        mov (1|M0)               r3.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        add3 (1|M0)              r2.1<1>:d     r3.0<0;0>:d       r2.3<0;0>:d       r2.7<0>:d        {I@1}
        sync.nop                             null                             {Compacted,$1.dst}
        mov (1|M0)               r38.0<1>:d    r1.0<0;1,0>:uw                   {F@1}
        addc (1|M0)              r3.0<1>:ud    r2.4<0;1,0>:ud    0x1:ud              {AccWrEn}
        send.ugm (1|M0)          null     r2      r38:1   0x0            0x04000B84           {A@1,$3} // wr:2+1, rd:0; store.ugm.d16u32.a64
        mov (1|M0)               r2.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$3.src}
        mov (1|M0)               r2.6<1>:d     r3.0<0;1,0>:d                   
        add3 (1|M0)              r2.7<1>:d     r2.0<0;0>:d       r2.5<0;0>:d       0:w               {I@2}
        cmp (1|M0)    (eq)f1.0   null<1>:d     r2.7<0;1,0>:d     0:w               {I@1}
(f1.0)  cmp (1|M0)    (eq)f1.0   null<1>:d     r2.6<0;1,0>:d     64:w              
(W)     and (1|M0)               f1.0<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
(f1.0.any16h) goto (16|M0)                   L32760                  L34280                
L32728:
(W)     mov (2|M0)               r2.4<1>:ud    r2.6<1;1,0>:ud                  
        goto.b (16|M0)                       L32760                  L32328                
L32760:
        join (16|M0)                         L33560                                
L32776:
(W)     and (1|M0)               f0.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
(f0.1.any16h) goto (16|M0)                   L33560                  L34280                
L32808:
        sync.allrd                           ($5,$6)                
        shl (1|M0)               r1.5<1>:d     r3.7<0;1,0>:d     12:w               {$10.src}
        shr (1|M0)               r1.0<1>:ud    r3.6<0;1,0>:ud    0x14:uw             
        shl (1|M0)               r1.3<1>:d     r3.6<0;1,0>:d     12:w              
        or (1|M0)                r1.4<1>:d     r1.5<0;1,0>:d     r1.0<0;1,0>:d    {I@2}
        shl (1|M0)               r1.2<1>:ud    r3.1<0;1,0>:ud    0x6:uw             
        shr (1|M0)               r1.0<1>:ud    r1.3<0;1,0>:ud    0x1F:uw              {I@3}
        shl (1|M0)               r1.5<1>:d     r1.4<0;1,0>:d     1:w               {I@3}
        shl (1|M0)               r1.3<1>:d     r1.3<0;1,0>:d     1:w               {Compacted}
        or (1|M0)                r1.4<1>:d     r1.5<0;1,0>:d     r1.0<0;1,0>:d    {I@2}
        addc (1|M0)              r1.0<1>:ud    r4.2<0;1,0>:ud    r1.3<0;1,0>:ud   {AccWrEn,I@2}
        shl (1|M0)               r1.5<1>:d     r1.2<0;1,0>:d     1:w              
        shr (1|M0)               r1.3<1>:ud    r1.2<0;1,0>:ud    0x1F:uw             
        mov (1|M0)               r4.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$7.src}
        sync.nop                             null                             {Compacted,$13.src}
        addc (1|M0)              r3.0<1>:ud    r1.0<0;1,0>:ud    r1.5<0;1,0>:ud   {AccWrEn,I@3}
        shl (1|M0)               r1.1<1>:ud    r3.1<0;1,0>:ud    0x8:uw             
        or (1|M0)                r1.6<1>:d     r1.3<0;1,0>:d     0:w               {I@4}
        add3 (1|M0)              r2.1<1>:d     r4.0<0;0>:d       r4.3<0;0>:d       r1.4<0>:d        {I@4}
        mov (1|M0)               r1.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r1.7<2>:f     0.0:f                              
        add (1|M0)               r1.1<1>:ud    r1.1<0;1,0>:ud    0x7000:uw              {I@4}
        mov (1|M0)               r1.3<1>:d     r3.0<0;1,0>:d                   
        add3 (1|M0)              r1.4<1>:d     r1.0<0;0>:d       r2.1<0;0>:d       r1.6<0>:d        {I@3}
        mov (1|M0)               r1.6<2>:f     0.0:f                               {I@1}
L33176:
        bfn.0xEA (1|M0)          r2.0<1>:ud    r1.6<0;0>:ud      r1.2<0;0>:ud      0x3C0:uw              {F@1} // s0|s1&s2
(W)     mov (1|M0)               r1.0<1>:f     9.401659e-38:f                              
        shl (1|M0)               r2.0<1>:ud    r2.0<0;1,0>:ud    0x2:uw              {I@1}
        shl (1|M0)               r4.1<1>:d     r1.7<0;1,0>:d     1:w              
        bfn.0xEA (1|M0)          r1.0<1>:ud    r2.0<0;0>:ud      r1.1<0;0>:ud      r1.0<0>:ud       {A@1} // s0|s1&s2
        shr (1|M0)               r4.0<1>:ud    r1.6<0;1,0>:ud    0x1F:uw             
        send.slm (1|M0)          r1       r1      null:0  0x0            0x02100500           {A@1,$11} // wr:1+0, rd:1; load.slm.d32.a32
        shl (1|M0)               r4.3<1>:d     r1.6<0;1,0>:d     1:w               {$11.dst}
        or (1|M0)                r4.4<1>:d     r4.1<0;1,0>:d     r4.0<0;1,0>:d   
        addc (1|M0)              r4.0<1>:ud    r1.3<0;1,0>:ud    r4.3<0;1,0>:ud   {AccWrEn,I@2}
        mov (1|M0)               r2.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r4.4<2>:hf    r1.0<0;1,0>:f                   
        addc (1|M0)              r3.0<1>:ud    r1.6<0;1,0>:ud    0x1:ud              {AccWrEn}
        add3 (1|M0)              r4.1<1>:d     r2.0<0;0>:d       r1.4<0;0>:d       r4.4<0>:d        {I@2}
        mov (1|M0)               r2.0<1>:d     r4.4<0;1,0>:uw                   {F@1}
        mov (1|M0)               r2.2<1>:d     r3.0<0;1,0>:d                    {I@3}
        send.ugm (1|M0)          null     r4      r2:1    0x0            0x04000B84           {A@1,$10} // wr:2+1, rd:0; store.ugm.d16u32.a64
        mov (1|M0)               r2.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$10.src}
        add3 (1|M0)              r2.3<1>:d     r2.0<0;0>:d       r1.7<0;0>:d       0:w               {I@1}
        cmp (1|M0)    (eq)f0.1   null<1>:d     r2.3<0;1,0>:d     0:w               {I@1}
(f0.1)  cmp (1|M0)    (eq)f0.1   null<1>:d     r2.2<0;1,0>:d     64:w              
(W)     and (1|M0)               f0.0<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(f0.0.any16h) goto (16|M0)                   L33560                  L34280                
L33528:
(W)     mov (2|M0)               r1.6<1>:ud    r2.2<1;1,0>:ud                  
        goto.b (16|M0)                       L33560                  L33176                
L33560:
        join (16|M0)                         L34280                                
L33576:
(W)     and (1|M0)               f1.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
(f1.1.any16h) goto (16|M0)                   L34280                  L34280                
L33608:
        shl (1|M0)               r4.1<1>:d     r3.7<0;1,0>:d     12:w               {$7.src}
        shr (1|M0)               r4.0<1>:ud    r3.6<0;1,0>:ud    0x14:uw             
        shl (1|M0)               r3.0<1>:d     r3.6<0;1,0>:d     12:w               {Compacted,$13.src}
        or (1|M0)                r3.1<1>:d     r4.1<0;1,0>:d     r4.0<0;1,0>:d    {Compacted,I@2}
        shr (1|M0)               r2.0<1>:ud    r3.0<0;1,0>:ud    0x1F:uw              {I@2}
        shl (1|M0)               r2.1<1>:d     r3.0<0;1,0>:d     1:w               {Compacted}
        shl (1|M0)               r2.3<1>:d     r3.1<0;1,0>:d     1:w               {I@3}
        mov (1|M0)               r2.5<2>:f     0.0:f                              
        or (1|M0)                r2.2<1>:d     r2.3<0;1,0>:d     r2.0<0;1,0>:d    {I@1}
        addc (1|M0)              r2.0<1>:ud    r4.2<0;1,0>:ud    r2.1<0;1,0>:ud   {AccWrEn}
        shl (1|M0)               r2.3<1>:d     r3.4<0;1,0>:d     1:w              
        mov (1|M0)               r3.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        shr (1|M0)               r2.1<1>:ud    r3.4<0;1,0>:ud    0x1F:uw             
        add3 (1|M0)              r2.6<1>:d     r3.0<0;0>:d       r4.3<0;0>:d       r2.2<0>:d        {I@2}
        shl (1|M0)               r2.2<1>:d     r3.5<0;1,0>:d     1:w              
        addc (1|M0)              r3.0<1>:ud    r2.0<0;1,0>:ud    r2.3<0;1,0>:ud   {AccWrEn}
        or (1|M0)                r2.4<1>:d     r2.2<0;1,0>:d     r2.1<0;1,0>:d    {I@2}
        mov (1|M0)               r2.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r2.1<1>:d     r3.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r2.2<1>:d     r2.0<0;0>:d       r2.6<0;0>:d       r2.4<0>:d        {I@2}
        mov (1|M0)               r2.4<2>:f     0.0:f                               {I@1}
L33904:
        addc (1|M0)              r2.0<1>:ud    r2.4<0;1,0>:ud    r3.4<0;1,0>:ud   {AccWrEn,F@1}
        cmp (1|M0)    (lt)f0.0   null<1>:ud    r2.4<0;1,0>:ud    0x7C0:uw             
        mov (1|M0)               r3.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        shl (1|M0)               r2.6<1>:d     r2.4<0;1,0>:d     1:w              
        add3 (1|M0)              r2.7<1>:d     r3.0<0;0>:d       r2.5<0;0>:d       r3.5<0>:d        {I@2}
        shl (1|M0)               r3.0<1>:d     r2.0<0;1,0>:d     1:w               {Compacted}
        shl (1|M0)               r3.1<1>:d     r2.5<0;1,0>:d     1:w              
        add (1|M0)               r3.0<1>:d     r3.0<0;1,0>:d     4096:w               {I@2}
        addc (1|M0)              r4.0<1>:ud    r2.1<0;1,0>:ud    r2.6<0;1,0>:ud   {AccWrEn}
        sync.nop                             null                             {Compacted,$5.src}
        send.slm (1|M0)          r1       r3      null:0  0x0            0x0210B700           {A@2,$7} // wr:1+0, rd:1; load.slm.d64x4t.a32
(f0.0)  cmp (1|M0)    (eq)f0.0   null<1>:d     r2.5<0;1,0>:d     0:w              
        shr (1|M0)               r3.0<1>:ud    r2.4<0;1,0>:ud    0x1F:uw              {$7.src}
        or (1|M0)                r2.7<1>:d     r3.1<0;1,0>:d     r3.0<0;1,0>:d    {I@1}
        mov (1|M0)               r3.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
(W)     and (1|M0)               f1.0<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
        add3 (1|M0)              r4.1<1>:d     r3.0<0;0>:d       r2.2<0;0>:d       r2.7<0>:d        {I@2}
        mov (1|M0)               r2.0<1>:d     r1.0<0;1,0>:uw                   {$7.dst}
        addc (1|M0)              r3.0<1>:ud    r2.4<0;1,0>:ud    0x40:ud              {AccWrEn}
        send.ugm (1|M0)          null     r4      r2:1    0x0            0x04000B84           {A@2,$7} // wr:2+1, rd:0; store.ugm.d16u32.a64
        mov (1|M0)               r2.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$7.src}
        mov (1|M0)               r2.6<1>:d     r3.0<0;1,0>:d                    {I@2}
        add3 (1|M0)              r2.7<1>:d     r2.0<0;0>:d       r2.5<0;0>:d       0:w               {I@2}
(~f1.0.any16h) goto (16|M0)                  L34280                  L34280                
L34248:
(W)     mov (2|M0)               r2.4<1>:ud    r2.6<1;1,0>:ud                   {I@2}
        goto.b (16|M0)                       L34280                  L33904                
L34280:
        join (16|M0)                         L34296                                
L34296:
(W)     mov (8|M0)               r112.0<1>:f   r0.0<1;1,0>:f                    {Compacted}
        sync.allrd                           ($5,$6,$10)                
(W)     send.ugm (1|M0)          r1       r0      null:0  0x0            0x0210641F           {$14} // wr:1+0, rd:1; fence invalid flush type scoped to tile
(W)     mov (8|M0)               null<1>:ud    r1.0<1;1,0>:ud                   {$14.dst}
(W)     send.gtwy (1|M0)         null     r112    null:0  0x0            0x02000010           {EOT,A@1} // wr:1+0, rd:0; end of thread
L34368:
        mov (1|M0)               r6.1<1>:d     cr0.0<0;1,0>:ud                  {A@1}
        and (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   -1265:w               {A@1}
        or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   1264:w               {A@1}
        mov (1|M0)               r6.0<1>:f     r6.2<0;1,0>:ud                   {Compacted,A@1}
        mov (1|M0)               r38.5<1>:f    r6.5<0;1,0>:ud                  
        math.inv (1|M0)          r6.6<1>:f     r6.0<0;1,0>:f                    {@2,$6}
        mov (1|M0)               r38.3<1>:f    0xB4C00000:f                               {Compacted}
        mov (1|M0)               r6.3<1>:ud    r38.5<0;1,0>:f                   {F@2}
        sync.nop                             null                             {Compacted,$6.dst}
        mad (1|M0)               r6.6<1>:f     r6.6<0;0>:f       r38.3<0;0>:f      r6.6<0>:f        {F@1}
        mov (1|M0)               r6.4<1>:ud    r6.0<0;1,0>:f                   
        add (1|M0)               r6.3<1>:ud    r6.5<0;1,0>:ud    -r6.3<0;1,0>:ud  {I@2}
        mul (1|M0)               r38.3<1>:f    r6.6<0;1,0>:f     r38.5<0;1,0>:f   {F@1}
        add (1|M0)               r6.4<1>:ud    r6.2<0;1,0>:ud    -r6.4<0;1,0>:ud  {I@2}
        mov (1|M0)               r6.7<1>:f     r6.3<0;1,0>:ud                   {I@2}
        mov (1|M0)               r6.3<1>:ud    r38.3<0;1,0>:f                   {A@1}
        mov (1|M0)               r38.4<1>:f    r6.4<0;1,0>:ud                   {I@2}
        mov (1|M0)               r38.3<1>:f    r6.3<0;1,0>:ud                   {Compacted,I@1}
        mad (1|M0)               r38.5<1>:f    r38.5<0;0>:f      r38.3<0;0>:f      -r6.0<0>:f       {F@1}
        mad (1|M0)               r38.3<1>:f    r6.7<0;0>:f       r38.3<0;0>:f      -r38.4<0>:f     
        add (1|M0)               r38.5<1>:f    r38.5<0;1,0>:f    r38.3<0;1,0>:f   {F@1}
        mul (1|M0)               r6.6<1>:f     r6.6<0;1,0>:f     r38.5<0;1,0>:f   {F@1}
        mov (1|M0)               r38.3<1>:ud   r6.6<0;1,0>:f                    {F@1}
        add (1|M0)               r6.3<1>:ud    r6.3<0;1,0>:ud    r38.3<0;1,0>:ud  {I@1}
(W)     mov (1|M0)               r38.6<1>:hf   0x1:hf                              {I@1}
(W)     mul (1|M0)               acc0.0<1>:ud  r6.3<0;1,0>:ud    r6.4<0;1,0>:uw  
        mach (1|M0)              r6.0<1>:ud    r6.3<0;1,0>:ud    r6.2<0;1,0>:ud  
        add (1|M0)               r6.5<1>:ud    r6.5<0;1,0>:ud    -r6.0<0;1,0>:ud  {I@1}
        cmp (1|M0)    (ge)f1.1   null<1>:ud    r6.5<0;1,0>:ud    r6.2<0;1,0>:ud   {I@1}
(f1.1)  sel (1|M0)               r38.3<1>:d    r38.6<0;1,0>:w    0:w               {F@1}
        add (1|M0)               r6.0<1>:ud    r6.3<0;1,0>:ud    r38.3<0;1,0>:ud  {I@1}
        mov (1|M0)               cr0.0<1>:ud   r6.1<0;1,0>:d                    {A@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        ret (16|M0)                          r38.0                            {A@1}
L34896:
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
