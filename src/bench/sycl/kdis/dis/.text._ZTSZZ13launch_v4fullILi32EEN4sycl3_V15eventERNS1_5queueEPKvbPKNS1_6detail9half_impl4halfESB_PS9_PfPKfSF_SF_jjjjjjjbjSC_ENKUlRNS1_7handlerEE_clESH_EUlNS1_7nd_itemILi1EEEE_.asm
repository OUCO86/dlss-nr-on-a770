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
(W)     mov (2|M0)               r124.0<1>:ud  r3.6<1;1,0>:ud                   {$1.dst}
        and (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   -1265:w               {A@1}
        or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   1216:w               {A@1}
        and (1|M0)               r3.1<1>:d     r2.4<0;1,0>:d     -2:w               {A@1}
        and (1|M0)               r1.6<2>:b     r3.0<0;1,0>:b     1:w               {$0.dst}
        cmp (1|M0)    (eq)f0.0   null<1>:d     r3.1<0;1,0>:d     0xFFFE:uw              {I@2}
        mov (1|M0)               r3.0<1>:d     r1.0<0;1,0>:uw                  
        and (1|M0)               r1.12<2>:b    r5.12<0;1,0>:b    1:w              
        mov (1|M0)               r1.2<1>:d     r0.1<0;1,0>:ud                  
(W)     and (1|M0)               f0.0<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
        mov (1|M0)               r3.5<1>:d     r0.1<0;1,0>:ud                  
        mov (1|M0)               r3.6<1>:d     0:w                              
        mov (1|M0)               r1.6<1>:d     r1.0<0;1,0>:uw                  
        mov (1|M0)               r1.7<1>:d     0:w                              
        and (1|M0)               r1.5<1>:d     r1.0<0;1,0>:uw    15:w              
        shr (1|M0)               r102.2<1>:ud  r3.0<0;1,0>:ud    0x4:uw              {I@7}
(f0.0.any16h) goto (16|M0)                   L34576                  L34576                
L448:
        mov (1|M0)               r6.5<1>:d     r1.2<0;1,0>:d                    {I@7}
        mov (1|M0)               r6.1<1>:d     r2.5<0;1,0>:d                   
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r102.0        L34656                                 {A@1}
L528:
        shl (1|M0)               r1.4<1>:d     r6.0<0;1,0>:d     3:w               {Compacted}
        shr (1|M0)               r102.1<1>:ud  r3.0<0;1,0>:ud    0x3:uw             
(W)     mul (1|M0)               acc0.0<1>:d   r6.0<0;1,0>:d     r2.10<0;1,0>:uw  {Compacted}
        add3 (1|M0)              r1.4<1>:ud    r1.4<0;0>:ud      r102.1<0;0>:ud    -r2.2<0>:ud      {I@2}
        mach (1|M0)              r6.0<1>:d     r6.0<0;1,0>:d     r2.5<0;1,0>:d    {Compacted}
        cmp (1|M0)    (gt)f0.1   null<1>:d     r1.4<0;1,0>:d     -1:w               {I@2}
        add (1|M0)               r1.2<1>:d     r1.2<0;1,0>:d     -r6.0<0;1,0>:d   {I@2}
        and (1|M0)               r3.1<1>:d     r1.0<0;1,0>:uw    7:w              
        shl (1|M0)               r3.7<1>:ud    r102.1<0;1,0>:ud  0x7:uw             
        shl (1|M0)               r1.2<1>:d     r1.2<0;1,0>:d     3:w               {I@3}
(W)     and (1|M0)               f1.1<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
        shl (1|M0)               r102.5<1>:ud  r102.2<0;1,0>:ud  0x9:uw             
        and (1|M0)               r3.7<1>:ud    r3.7<0;1,0>:ud    0x80:uw              {I@4}
        add3 (1|M0)              r1.2<1>:d     r1.2<0;0>:d       r3.1<0;0>:d       -r2.3<0>:d       {I@4}
        shl (1|M0)               r3.1<1>:d     r3.1<0;1,0>:d     4:w               {Compacted}
        mov (16|M0)              r11.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r13.0<1>:f    0.0:f                               {Compacted}
        bfn.0xFE (1|M0)          r102.5<1>:ud  r3.1<0;0>:ud      r3.7<0;0>:ud      r102.5<0>:ud     {I@1} // s0|s1|s2
(~f1.1.any16h) goto (16|M0)                  L1440                  L1440                
L784:
        cmp (1|M0)    (gt)f1.0   null<1>:d     r1.2<0;1,0>:d     -1:w              
        cmp (1|M0)    (lt)f1.1   null<1>:d     r1.2<0;1,0>:d     r2.7<0;1,0>:d   
(W)     mov (1|M0)               r102.0<1>:hf  0x1:hf                             
(f1.0)  cmp (1|M0)    (lt)f1.0   null<1>:d     r1.4<0;1,0>:d     r2.6<0;1,0>:d   
(f1.0)  sel (1|M0)               r102.1<1>:uw  r102.0<0;1,0>:uw  0x0:uw              {F@1}
(f1.1)  sel (1|M0)               r102.0<1>:uw  r102.0<0;1,0>:uw  0x0:uw             
        and (1|M0)    (ne)f1.1   null<1>:uw    r102.1<0;1,0>:uw  r102.0<0;1,0>:uw {I@1}
(W)     and (1|M0)               f1.0<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(~f1.0.any16h) goto (16|M0)                  L1440                  L1440                
L928:
        mul (1|M0)               acc0.0<1>:ud  r1.4<0;1,0>:ud    r2.14<0;1,0>:uw 
        mach (1|M0)              r126.0<1>:ud  r1.4<0;1,0>:ud    r2.7<0;1,0>:ud   {AccWrEn}
        cmp (1|M0)    (eq)f1.0   null<1>:w     r1.6<0;1,0>:b     0:w              
        mov (1|M0)               r125.0<1>:ud  acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r6.0<1>:ud    r125.0<0;1,0>:ud  r1.2<0;1,0>:ud   {AccWrEn,I@1}
(W)     and (1|M0)               f0.0<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
        mov (1|M0)               r102.0<1>:ud  acc0.0<0;1,0>:ud                 {Compacted}
        shr (1|M0)               r6.1<1>:ud    r6.0<0;1,0>:ud    0x1B:uw              {I@3}
        add3 (1|M0)              r102.4<1>:d   r102.0<0;0>:d     r126.0<0;0>:d     0:w               {I@2}
        shl (1|M0)               r102.3<1>:d   r6.0<0;1,0>:d     5:w               {Compacted}
        shl (1|M0)               r6.2<1>:d     r102.4<0;1,0>:d   5:w               {I@2}
        or (1|M0)                r102.4<1>:d   r6.2<0;1,0>:d     r6.1<0;1,0>:d    {I@1}
(f0.0.any16h) goto (16|M0)                   L1304                  L1304                
L1112:
        shr (1|M0)               r102.0<1>:ud  r102.3<0;1,0>:ud  0x1F:uw             
        shl (1|M0)               r102.3<1>:d   r102.3<0;1,0>:d   1:w               {Compacted}
        shl (1|M0)               r102.6<1>:d   r102.4<0;1,0>:d   1:w               {I@4}
        addc (1|M0)              r6.0<1>:ud    r3.2<0;1,0>:ud    r102.3<0;1,0>:ud {AccWrEn,I@2}
        or (1|M0)                r102.4<1>:d   r102.6<0;1,0>:d   r102.0<0;1,0>:d  {I@2}
        mov (1|M0)               r102.0<1>:ud  acc0.0<0;1,0>:ud                 {Compacted}
        add3 (1|M0)              r6.1<1>:d     r102.0<0;0>:d     r3.3<0;0>:d       r102.4<0>:d      {I@1}
        send.ugm (1|M0)          r114     r6      null:0  0x0            0x0220C780           {A@1,$2} // wr:1+0, rd:2; load.ugm.d64x8t.a64
        mov (8|M0)               r11.0<1>:f    r114.0<1;1,0>:hf                 {$2.dst}
        mov (8|M0)               r12.0<1>:f    r114.8<1;1,0>:hf                
        mov (8|M0)               r13.0<1>:f    r115.0<1;1,0>:hf                
        mov (8|M0)               r14.0<1>:f    r115.8<1;1,0>:hf                
        goto (16|M0)                         L1304                  L1440                
L1304:
        join (16|M0)                         L1440                                
L1320:
        shl (1|M0)               r6.1<1>:d     r102.4<0;1,0>:d   2:w              
        shr (1|M0)               r6.0<1>:ud    r102.3<0;1,0>:ud  0x1E:uw             
        shl (1|M0)               r6.2<1>:d     r102.3<0;1,0>:d   2:w              
        or (1|M0)                r6.3<1>:d     r6.1<0;1,0>:d     r6.0<0;1,0>:d    {I@2}
        addc (1|M0)              r6.0<1>:ud    r3.2<0;1,0>:ud    r6.2<0;1,0>:ud   {AccWrEn,I@2}
        mov (1|M0)               r102.0<1>:ud  acc0.0<0;1,0>:ud                 {Compacted}
        add3 (1|M0)              r6.1<1>:d     r102.0<0;0>:d     r3.3<0;0>:d       r6.3<0>:d        {I@1}
        send.ugm (1|M0)          r11      r6      null:0  0x0            0x0240D780           {A@1,$3} // wr:1+0, rd:4; load.ugm.d64x16t.a64
L1440:
        join (16|M0)                         L34576                                
L1456:
        sel (16|M0)   (lt)f0.0   r29.0<1>:f    (abs)r11.0<1;1,0>:f  448.0:f            {Compacted,$3.dst}
        sel (16|M0)   (lt)f0.0   r19.0<1>:f    (abs)r13.0<1;1,0>:f  448.0:f            {Compacted}
        shr (16|M0)              r84.0<1>:ud   r29.0<1;1,0>:ud   0x17:uw              {F@2}
        shr (16|M0)              r82.0<1>:ud   r19.0<1;1,0>:ud   0x17:uw              {F@1}
        sel (16|M0)   (ge)f0.0   r49.0<2>:ub   r84.0<4;1,0>:ub   0x79:uw              {I@2}
        sel (16|M0)   (ge)f0.0   r50.0<2>:ub   r82.0<4;1,0>:ub   0x79:uw              {I@2}
        mov (16|M0)              r45.0<1>:d    r49.0<2;1,0>:ub                  {I@2}
        mov (16|M0)              r43.0<1>:d    r50.0<2;1,0>:ub                  {I@2}
        shl (16|M0)              r45.0<1>:d    r45.0<1;1,0>:d    23:w               {Compacted,I@2}
        shl (16|M0)              r43.0<1>:d    r43.0<1;1,0>:d    23:w               {Compacted,I@2}
        add (16|M0)              r47.0<1>:d    r45.0<1;1,0>:d    -25165824:d               {I@2}
        add (16|M0)              r41.0<1>:d    r43.0<1;1,0>:d    -25165824:d               {I@2}
        add (16|M0)              r45.0<1>:d    -r45.0<1;1,0>:d   -2139095040:d              
        add (16|M0)              r43.0<1>:d    -r43.0<1;1,0>:d   -2139095040:d              
        mul (16|M0)              acc0.0<1>:f   r29.0<1;1,0>:f    r45.0<1;1,0>:f   {Compacted,I@2}
        mul (16|M0)              acc2.0<1>:f   r19.0<1;1,0>:f    r43.0<1;1,0>:f   {Compacted,I@1}
        rnde (16|M0)             acc0.0<1>:f   acc0.0<1;1,0>:f                 
        rnde (16|M0)             acc2.0<1>:f   acc2.0<1;1,0>:f                 
        cmp (16|M0)   (lt)f0.0   null<1>:f     r11.0<1;1,0>:f    0.0:f               {Compacted}
        cmp (16|M0)   (lt)f1.1   null<1>:f     r13.0<1;1,0>:f    0.0:f              
        mul (16|M0)              acc0.0<1>:f   acc0.0<1;1,0>:f   r47.0<1;1,0>:f   {Compacted}
        mul (16|M0)              acc2.0<1>:f   acc2.0<1;1,0>:f   r41.0<1;1,0>:f   {Compacted}
        mov (16|M0)              r51.0<1>:f    (abs)acc0.0<1;1,0>:f             {Compacted}
        mov (16|M0)              r69.0<1>:f    (abs)acc2.0<1;1,0>:f             {Compacted}
        shl (1|M0)               r105.0<1>:ud  r102.5<0;1,0>:ud  0x1:uw             
(f0.0)  or (16|M0)               r51.0<1>:d    r51.0<1;1,0>:d    -2147483648:d               {F@2}
(f1.1)  or (16|M0)               r69.0<1>:d    r69.0<1;1,0>:d    -2147483648:d               {F@1}
        or (1|M0)                r102.0<1>:ud  r105.0<0;1,0>:ud  0x200:uw              {I@3}
        mov (8|M0)               r84.0<1>:hf   r51.0<1;1,0>:f                   {I@3}
        mov (8|M0)               r84.8<1>:hf   r52.0<1;1,0>:f                  
        mov (8|M0)               r85.0<1>:hf   r69.0<1;1,0>:f                   {I@2}
        mov (8|M0)               r85.8<1>:hf   r70.0<1;1,0>:f                  
        send.slm (1|M0)          null     r105    r84:1   0x0            0x0200B704           {A@3,$4} // wr:1+1, rd:0; store.slm.d64x4t.a32
        send.slm (1|M0)          null     r102    r85:1   0x0            0x0200B704           {A@1,$5} // wr:1+1, rd:0; store.slm.d64x4t.a32
(W)     send.slm (1|M0)          r112     r0      null:0  0x0            0x0210001F           {$6} // wr:1+0, rd:1; fence.slm.none.group
(W)     mov (1|M0)               r111.2<1>:f   0.0:f                               {Compacted}
(W)     mov (2|M0)               r111.10<1>:ub  r0.11<0;1,0>:ub                 {F@1}
(W)     mov (8|M0)               null<1>:ud    r112.0<1;1,0>:ud                 {$6.dst}
(W)     send.gtwy (1|M0)         null     r111    null:0  0x0            0x02000004           {A@2,$7} // wr:1+0, rd:0; signal barrier
(W)     sync.bar                             null                            
        shl (1|M0)               r123.0<1>:ud  r3.0<0;1,0>:ud    0x2:uw             
        cmp (1|M0)    (eq)f1.0   null<1>:d     r3.4<0;1,0>:d     -1:w              
        send.slm (1|M0)          r19      r123    null:0  0x0            0x0240D700           {A@2,$8} // wr:1+0, rd:4; load.slm.d64x16t.a32
(W)     and (1|M0)               f1.1<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
(~f1.1.any16h) goto (16|M0)                  L2176                  L2176                
L2080:
        add (16|M0)              acc0.0<1>:f   r19.0<1;1,0>:f    r19.0<1;1,0>:f   {Compacted,$8.dst}
        add (16|M0)              acc2.0<1>:f   r21.0<1;1,0>:f    r21.0<1;1,0>:f   {Compacted}
        add (16|M0)              acc0.0<1>:f   acc0.0<1;1,0>:f   r19.0<1;1,0>:f   {Compacted}
        add (16|M0)              acc2.0<1>:f   acc2.0<1;1,0>:f   r21.0<1;1,0>:f   {Compacted}
        add (16|M0)              acc0.0<1>:f   acc0.0<1;1,0>:f   r19.0<1;1,0>:f   {Compacted}
        add (16|M0)              acc2.0<1>:f   acc2.0<1;1,0>:f   r21.0<1;1,0>:f   {Compacted}
        add (16|M0)              r23.0<1>:f    acc0.0<1;1,0>:f   0x45046016:f              
        add (16|M0)              r25.0<1>:f    acc2.0<1;1,0>:f   0x45046016:f              
        send.slm (1|M0)          null     r123    r23:4   0x0            0x0200D704           {A@1,$9} // wr:1+4, rd:0; store.slm.d64x16t.a32
L2176:
        join (16|M0)                         L34576                                
L2192:
        cmp (1|M0)    (eq)f0.0   null<1>:d     r2.4<0;1,0>:d     101:w              
(W)     and (1|M0)               f1.0<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
(f1.0.any16h) goto (16|M0)                   L34576                  L34576                
L2240:
        send.ugm (1|M0)          r6       r124    null:0  0x0            0x0280E780           {$10} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        addc (1|M0)              r15.0<1>:ud   r124.0<0;1,0>:ud  0x100:ud              {AccWrEn}
        shl (1|M0)               r102.0<1>:ud  r102.2<0;1,0>:ud  0xC:uw              {$5.src}
        mov (1|M0)               r14.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        sync.nop                             null                             {Compacted,$8.dst}
        mov (1|M0)               r22.0<1>:d    r15.0<0;1,0>:d                   {I@3}
        add3 (1|M0)              r22.1<1>:d    r14.0<0;0>:d      r124.1<0;0>:d     0:w               {I@2}
        add (1|M0)               r104.0<1>:ud  r102.0<0;1,0>:ud  0x7000:uw             
        send.ugm (1|M0)          r14      r22     null:0  0x0            0x0280E780           {A@2,$11} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        add (1|M0)               r122.0<1>:ud  r102.0<0;1,0>:ud  0x7800:uw             
        shl (1|M0)               r102.0<1>:ud  r102.2<0;1,0>:ud  0xB:uw             
        mov (16|M0)              r78.0<1>:ud   0x0:ud                             
        add (1|M0)               r103.0<1>:ud  r102.0<0;1,0>:ud  0x5000:uw              {I@2}
        shl (1|M0)               r102.0<1>:ud  r102.2<0;1,0>:ud  0xA:uw             
        mov (16|M0)              r80.0<1>:ud   0x0:ud                             
        or (1|M0)                r127.0<1>:ud  r102.0<0;1,0>:ud  0x100:uw              {I@2}
        send.slm (1|M0)          r54      r102    null:0  0x0            0x0280E700           {$12} // wr:1+0, rd:8; load.slm.d64x32t.a32
        send.slm (1|M0)          r62      r127    null:0  0x0            0x0280E700           {A@1,$13} // wr:1+0, rd:8; load.slm.d64x32t.a32
        mov (16|M0)              r82.0<1>:ud   0x0:ud                             
        mov (16|M0)              r84.0<1>:ud   0x0:ud                              {$4.src}
        mov (16|M0)              r24.0<1>:ud   0x0:ud                              {$9.src}
        mov (16|M0)              r26.0<1>:ud   0x0:ud                             
        mov (16|M0)              r28.0<1>:ud   0x0:ud                             
        mov (16|M0)              r22.0<1>:ud   0x0:ud                              {$11.src}
        mov (16|M0)              r30.0<1>:ud   0x0:ud                             
        mov (16|M0)              r32.0<1>:ud   0x0:ud                             
        mov (16|M0)              r34.0<1>:ud   0x0:ud                             
        mov (16|M0)              r36.0<1>:ud   0x0:ud                             
        mov (16|M0)              r46.0<1>:ud   0x0:ud                             
        mov (16|M0)              r48.0<1>:ud   0x0:ud                             
        mov (16|M0)              r50.0<1>:ud   0x0:ud                             
        mov (16|M0)              r52.0<1>:ud   0x0:ud                             
        or (1|M0)                r126.0<1>:ud  r102.0<0;1,0>:ud  0x200:uw             
        or (1|M0)                r125.0<1>:ud  r102.0<0;1,0>:ud  0x300:uw             
        send.slm (1|M0)          r114     r126    null:0  0x0            0x0280E700           {A@2,$14} // wr:1+0, rd:8; load.slm.d64x32t.a32
        sync.allwr                           ($10,$12,$13)                
(W)     sync.nop                             null                            
        dpas.8x8 (8|M0)          r78:f         null:f            r78:hf            r78.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r78:f         r78:f             r6:hf             r54.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r22:f         r22:f             r6:hf             r62.0:hf         {$10}
        addc (1|M0)              r6.0<1>:ud    r124.0<0;1,0>:ud  0xC00:ud              {AccWrEn,$10.src}
        sync.nop                             null                             {Compacted,$7.src}
        send.slm (1|M0)          r106     r125    null:0  0x0            0x0280E700           {A@2,$15} // wr:1+0, rd:8; load.slm.d64x32t.a32
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        add3 (1|M0)              r6.1<1>:d     r7.0<0;0>:d       r124.1<0;0>:d     0:w               {I@1}
        addc (1|M0)              r7.0<1>:ud    r124.0<0;1,0>:ud  0xD00:ud              {AccWrEn}
        send.ugm (1|M0)          r38      r6      null:0  0x0            0x0280E780           {A@2,$0} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$0.src}
        sync.nop                             null                             {Compacted,$11.dst}
        dpas.8x8 (8|M0)          r30:f         null:f            r30:hf            r30.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r30:f         r30:f             r14:hf            r54.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r46:f         r46:f             r14:hf            r62.0:hf         {$11}
        sync.nop                             null                             {Compacted,$11.src}
        mov (1|M0)               r14.0<1>:d    r7.0<0;1,0>:d                    {I@2}
        add3 (1|M0)              r14.1<1>:d    r6.0<0;0>:d       r124.1<0;0>:d     0:w               {I@2}
        send.ugm (1|M0)          r6       r14     null:0  0x0            0x0280E780           {A@1,$1} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        sync.allwr                           ($0,$10,$14,$15)                
        dpas.8x8 (8|M0)          r78:f         null:f            r78:hf            r78.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r78:f         r78:f             r38:hf            r114.0:hf        {Atomic}
        dpas.8x8 (8|M0)          r22:f         r22:f             r38:hf            r106.0:hf        {$14}
        mov (16|M0)              r38.0<1>:ud   0x0:ud                              {$14.src}
        mov (16|M0)              r40.0<1>:ud   0x0:ud                             
        mov (16|M0)              r42.0<1>:ud   0x0:ud                             
        sync.allwr                           ($1,$11)                
        dpas.8x8 (8|M0)          r30:f         null:f            r30:hf            r30.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r30:f         r30:f             r6:hf             r114.0:hf        {Atomic}
        dpas.8x8 (8|M0)          r46:f         r46:f             r6:hf             r106.0:hf        {$11}
        addc (1|M0)              r6.0<1>:ud    r124.0<0;1,0>:ud  0x200:ud              {AccWrEn,$11.src}
        mov (16|M0)              r44.0<1>:ud   0x0:ud                             
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        add3 (1|M0)              r6.1<1>:d     r7.0<0;0>:d       r124.1<0;0>:d     0:w               {I@1}
        mov (16|M0)              r8.0<1>:ud    0x0:ud                             
        send.ugm (1|M0)          r70      r6      null:0  0x0            0x0280E780           {A@2,$2} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        addc (1|M0)              r6.0<1>:ud    r124.0<0;1,0>:ud  0x300:ud              {AccWrEn,$2.src}
        mov (16|M0)              r10.0<1>:ud   0x0:ud                             
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        add3 (1|M0)              r6.1<1>:d     r7.0<0;0>:d       r124.1<0;0>:d     0:w               {I@1}
        mov (16|M0)              r12.0<1>:ud   0x0:ud                             
        send.ugm (1|M0)          r14      r6      null:0  0x0            0x0280E780           {A@2,$3} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        mov (16|M0)              r6.0<1>:f     0.0:f                               {Compacted,$3.src}
        mov (8|M0)               r100.0<1>:f   r22.0<1;1,0>:f                   {Compacted,$14.dst}
        mov (8|M0)               r101.0<1>:f   r46.0<1;1,0>:f                   {Compacted,$11.dst}
        mov (8|M0)               r98.0<1>:f    r79.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r99.0<1>:f    r31.0<1;1,0>:f                   {Compacted}
        sync.nop                             null                             {Compacted,A@1}
        sync.allwr                           ($2,$3)                
        dpas.8x8 (8|M0)          r38:f         r38:f             r70:hf            r54.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r6:f          r6:f              r14:hf            r54.0:hf         {$2}
        mov (16|M0)              r54.0<1>:f    0.0:f                               {Compacted,$2.src}
        mov (16|M0)              r56.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r58.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r60.0<1>:f    0.0:f                               {Compacted}
        sync.nop                             null                             {Compacted,A@1}
        dpas.8x8 (8|M0)          r54:f         r54:f             r70:hf            r62.0:hf         {$4}
        mov (16|M0)              r70.0<1>:f    0.0:f                               {Compacted,$4.src}
        mov (16|M0)              r72.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r74.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r76.0<1>:f    0.0:f                               {Compacted}
        sync.nop                             null                             {Compacted,A@1}
        dpas.8x8 (8|M0)          r70:f         r70:f             r14:hf            r62.0:hf         {$5}
        addc (1|M0)              r14.0<1>:ud   r124.0<0;1,0>:ud  0xE00:ud              {AccWrEn,$5.src}
        mov (1|M0)               r15.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        add3 (1|M0)              r14.1<1>:d    r15.0<0;0>:d      r124.1<0;0>:d     0:w               {I@1}
        addc (1|M0)              r15.0<1>:ud   r124.0<0;1,0>:ud  0xF00:ud              {AccWrEn}
        send.ugm (1|M0)          r62      r14     null:0  0x0            0x0280E780           {A@2,$6} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        mov (1|M0)               r14.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,$6.src}
        mov (1|M0)               r86.0<1>:d    r15.0<0;1,0>:d                   {I@2}
        add3 (1|M0)              r86.1<1>:d    r14.0<0;0>:d      r124.1<0;0>:d     0:w               {I@2}
        send.ugm (1|M0)          r14      r86     null:0  0x0            0x0280E780           {A@1,$7} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        sync.allwr                           ($2,$4,$6)                
        dpas.8x8 (8|M0)          r38:f         null:f            r38:hf            r38.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r38:f         r38:f             r62:hf            r114.0:hf        {Atomic}
        dpas.8x8 (8|M0)          r54:f         r54:f             r62:hf            r106.0:hf        {$2}
        mov (8|M0)               r62.0<1>:f    r78.0<1;1,0>:f                   {Compacted,$2.src}
        mov (8|M0)               r63.0<1>:f    r30.0<1;1,0>:f                   {Compacted}
        sync.allwr                           ($5,$7)                
        dpas.8x8 (8|M0)          r6:f          null:f            r6:hf             r6.0:hf          {Atomic}
        dpas.8x8 (8|M0)          r6:f          r6:f              r14:hf            r114.0:hf        {Atomic}
        dpas.8x8 (8|M0)          r70:f         r70:f             r14:hf            r106.0:hf        {$5}
        or (1|M0)                r14.0<1>:ud   r104.0<0;1,0>:ud  0x400:uw              {$5.src}
        send.slm (1|M0)          null     r104    r62:2   0x0            0x0200C704           {A@1,$8} // wr:1+2, rd:0; store.slm.d64x8t.a32
        send.slm (1|M0)          null     r14     r100:2  0x0            0x0200C704           {A@1,$10} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r92.0<1>:f    r38.0<1;1,0>:f                   {Compacted,$2.dst}
        or (1|M0)                r14.0<1>:ud   r104.0<0;1,0>:ud  0x40:uw              {$10.src}
        mov (8|M0)               r90.0<1>:f    r54.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r93.0<1>:f    r6.0<1;1,0>:f                    {Compacted,$5.dst}
        mov (8|M0)               r91.0<1>:f    r70.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r14     r92:2   0x0            0x0200C704           {A@1,$11} // wr:1+2, rd:0; store.slm.d64x8t.a32
        or (1|M0)                r14.0<1>:ud   r104.0<0;1,0>:ud  0x440:uw              {$11.src}
        mov (8|M0)               r88.0<1>:f    r39.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r14     r90:2   0x0            0x0200C704           {A@1,$12} // wr:1+2, rd:0; store.slm.d64x8t.a32
        or (1|M0)                r14.0<1>:ud   r104.0<0;1,0>:ud  0x80:uw              {$12.src}
        mov (8|M0)               r90.0<1>:f    r23.0<1;1,0>:f                   {Compacted}
        sync.nop                             null                             {Compacted,I@1}
        send.slm (1|M0)          null     r14     r98:2   0x0            0x0200C704           {$13} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r91.0<1>:f    r47.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r14.0<1>:ud   r104.0<0;1,0>:ud  0x480:uw              {$13.src}
        mov (8|M0)               r89.0<1>:f    r7.0<1;1,0>:f                    {Compacted}
        send.slm (1|M0)          null     r14     r90:2   0x0            0x0200C704           {A@1,$14} // wr:1+2, rd:0; store.slm.d64x8t.a32
        or (1|M0)                r14.0<1>:ud   r104.0<0;1,0>:ud  0xC0:uw              {$14.src}
        mov (8|M0)               r96.0<1>:f    r55.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r14     r88:2   0x0            0x0200C704           {A@1,$15} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r97.0<1>:f    r71.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r14.0<1>:ud   r104.0<0;1,0>:ud  0x4C0:uw              {$15.src}
        mov (8|M0)               r88.0<1>:f    r24.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r14     r96:2   0x0            0x0200C704           {A@1,$0} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r96.0<1>:f    r80.0<1;1,0>:f                   {Compacted,$0.src}
        mov (8|M0)               r97.0<1>:f    r32.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r14.0<1>:ud   r104.0<0;1,0>:ud  0x100:uw             
        mov (8|M0)               r89.0<1>:f    r48.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r14     r96:2   0x0            0x0200C704           {A@1,$1} // wr:1+2, rd:0; store.slm.d64x8t.a32
        or (1|M0)                r14.0<1>:ud   r104.0<0;1,0>:ud  0x500:uw              {$1.src}
        mov (8|M0)               r86.0<1>:f    r40.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r14     r88:2   0x0            0x0200C704           {A@1,$2} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r87.0<1>:f    r8.0<1;1,0>:f                    {Compacted}
        or (1|M0)                r14.0<1>:ud   r104.0<0;1,0>:ud  0x140:uw              {$2.src}
        mov (8|M0)               r94.0<1>:f    r56.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r14     r86:2   0x0            0x0200C704           {A@1,$3} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r95.0<1>:f    r72.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r14.0<1>:ud   r104.0<0;1,0>:ud  0x540:uw              {$3.src}
        mov (8|M0)               r86.0<1>:f    r25.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r14     r94:2   0x0            0x0200C704           {A@1,$4} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r94.0<1>:f    r81.0<1;1,0>:f                   {Compacted,$4.src}
        mov (8|M0)               r95.0<1>:f    r33.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r14.0<1>:ud   r104.0<0;1,0>:ud  0x180:uw             
        mov (8|M0)               r87.0<1>:f    r49.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r14     r94:2   0x0            0x0200C704           {A@1,$5} // wr:1+2, rd:0; store.slm.d64x8t.a32
        or (1|M0)                r14.0<1>:ud   r104.0<0;1,0>:ud  0x580:uw              {$5.src}
        mov (8|M0)               r68.0<1>:f    r41.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r14     r86:2   0x0            0x0200C704           {A@1,$6} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r69.0<1>:f    r9.0<1;1,0>:f                    {Compacted}
        or (1|M0)                r14.0<1>:ud   r104.0<0;1,0>:ud  0x1C0:uw              {$6.src}
        mov (8|M0)               r92.0<1>:f    r57.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r14     r68:2   0x0            0x0200C704           {A@1,$7} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r93.0<1>:f    r73.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r14.0<1>:ud   r104.0<0;1,0>:ud  0x5C0:uw              {$7.src}
        mov (8|M0)               r68.0<1>:f    r26.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r14     r92:2   0x0            0x0200C704           {A@1,$10} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r92.0<1>:f    r82.0<1;1,0>:f                   {Compacted,$10.src}
        mov (8|M0)               r93.0<1>:f    r34.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r14.0<1>:ud   r104.0<0;1,0>:ud  0x200:uw             
        mov (8|M0)               r69.0<1>:f    r50.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r14     r92:2   0x0            0x0200C704           {A@1,$11} // wr:1+2, rd:0; store.slm.d64x8t.a32
        or (1|M0)                r14.0<1>:ud   r104.0<0;1,0>:ud  0x600:uw              {$11.src}
        mov (8|M0)               r66.0<1>:f    r42.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r14     r68:2   0x0            0x0200C704           {A@1,$12} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r67.0<1>:f    r10.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r14.0<1>:ud   r104.0<0;1,0>:ud  0x240:uw              {$12.src}
        mov (8|M0)               r90.0<1>:f    r58.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r14     r66:2   0x0            0x0200C704           {A@1,$13} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r91.0<1>:f    r74.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r14.0<1>:ud   r104.0<0;1,0>:ud  0x640:uw              {$13.src}
        mov (8|M0)               r66.0<1>:f    r27.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r14     r90:2   0x0            0x0200C704           {A@1,$14} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r90.0<1>:f    r83.0<1;1,0>:f                   {Compacted,$14.src}
        mov (8|M0)               r91.0<1>:f    r35.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r14.0<1>:ud   r104.0<0;1,0>:ud  0x280:uw             
        mov (8|M0)               r67.0<1>:f    r51.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r14     r90:2   0x0            0x0200C704           {A@1,$15} // wr:1+2, rd:0; store.slm.d64x8t.a32
        or (1|M0)                r14.0<1>:ud   r104.0<0;1,0>:ud  0x680:uw              {$15.src}
        mov (8|M0)               r64.0<1>:f    r43.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r14     r66:2   0x0            0x0200C704           {A@1,$0} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r65.0<1>:f    r11.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r14.0<1>:ud   r104.0<0;1,0>:ud  0x2C0:uw              {$0.src}
        mov (8|M0)               r88.0<1>:f    r59.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r14     r64:2   0x0            0x0200C704           {A@1,$1} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r89.0<1>:f    r75.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r14.0<1>:ud   r104.0<0;1,0>:ud  0x6C0:uw              {$1.src}
        mov (8|M0)               r64.0<1>:f    r28.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r14     r88:2   0x0            0x0200C704           {A@1,$2} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r88.0<1>:f    r84.0<1;1,0>:f                   {Compacted,$2.src}
        mov (8|M0)               r89.0<1>:f    r36.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r14.0<1>:ud   r104.0<0;1,0>:ud  0x300:uw             
        mov (8|M0)               r65.0<1>:f    r52.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r14     r88:2   0x0            0x0200C704           {A@1,$3} // wr:1+2, rd:0; store.slm.d64x8t.a32
        or (1|M0)                r14.0<1>:ud   r104.0<0;1,0>:ud  0x700:uw              {$3.src}
        mov (8|M0)               r62.0<1>:f    r44.0<1;1,0>:f                   {Compacted,$8.src}
        send.slm (1|M0)          null     r14     r64:2   0x0            0x0200C704           {A@1,$4} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r63.0<1>:f    r12.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r14.0<1>:ud   r104.0<0;1,0>:ud  0x340:uw              {$4.src}
        or (1|M0)                r6.0<1>:ud    r104.0<0;1,0>:ud  0x380:uw             
        send.slm (1|M0)          null     r14     r62:2   0x0            0x0200C704           {A@1,$5} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r86.0<1>:f    r60.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r87.0<1>:f    r76.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r14.0<1>:ud   r104.0<0;1,0>:ud  0x740:uw              {$5.src}
        mov (8|M0)               r62.0<1>:f    r85.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r63.0<1>:f    r37.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r14     r86:2   0x0            0x0200C704           {A@1,$6} // wr:1+2, rd:0; store.slm.d64x8t.a32
        send.slm (1|M0)          null     r6      r62:2   0x0            0x0200C704           {A@1,$7} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r110.0<1>:f   r29.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r111.0<1>:f   r53.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r6.0<1>:ud    r104.0<0;1,0>:ud  0x780:uw              {$7.src}
        mov (8|M0)               r19.0<1>:f    r45.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r6      r110:2  0x0            0x0200C704           {A@1,$10} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r20.0<1>:f    r13.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r6.0<1>:ud    r104.0<0;1,0>:ud  0x3C0:uw              {$10.src}
        mov (8|M0)               r9.0<1>:f     r61.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r6      r19:2   0x0            0x0200C704           {A@1,$11} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r10.0<1>:f    r77.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r6.0<1>:ud    r104.0<0;1,0>:ud  0x7C0:uw              {$11.src}
        mov (16|M0)              r70.0<1>:f    0.0:f                               {Compacted}
        send.slm (1|M0)          null     r6      r9:2    0x0            0x0200C704           {A@1,$12} // wr:1+2, rd:0; store.slm.d64x8t.a32
        addc (1|M0)              r6.0<1>:ud    r124.0<0;1,0>:ud  0x400:ud              {AccWrEn,$12.src}
        mov (16|M0)              r72.0<1>:f    0.0:f                               {Compacted}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        add3 (1|M0)              r6.1<1>:d     r7.0<0;0>:d       r124.1<0;0>:d     0:w               {I@1}
        send.slm (1|M0)          r46      r102    null:0  0x0            0x0280E700           {$13} // wr:1+0, rd:8; load.slm.d64x32t.a32
        send.ugm (1|M0)          r38      r6      null:0  0x0            0x0280E780           {A@1,$14} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        addc (1|M0)              r6.0<1>:ud    r124.0<0;1,0>:ud  0x500:ud              {AccWrEn,$14.src}
        send.slm (1|M0)          r94      r127    null:0  0x0            0x0280E700           {$15} // wr:1+0, rd:8; load.slm.d64x32t.a32
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r22.0<1>:ud   r124.0<0;1,0>:ud  0x1000:ud              {AccWrEn}
        add3 (1|M0)              r6.1<1>:d     r7.0<0;0>:d       r124.1<0;0>:d     0:w               {I@2}
        mov (1|M0)               r23.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        sync.nop                             null                             {Compacted,$6.src}
        send.ugm (1|M0)          r86      r6      null:0  0x0            0x0280E780           {A@2,$0} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        add3 (1|M0)              r22.1<1>:d    r23.0<0;0>:d      r124.1<0;0>:d     0:w               {I@1}
        mov (16|M0)              r74.0<1>:f    0.0:f                               {Compacted}
        sync.nop                             null                             {Compacted,I@1}
        send.ugm (1|M0)          r30      r22     null:0  0x0            0x0280E780           {$1} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        addc (1|M0)              r22.0<1>:ud   r124.0<0;1,0>:ud  0x1100:ud              {AccWrEn,$1.src}
        mov (16|M0)              r12.0<1>:f    0.0:f                               {Compacted}
        mov (1|M0)               r23.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        add3 (1|M0)              r22.1<1>:d    r23.0<0;0>:d      r124.1<0;0>:d     0:w               {I@1}
        mov (16|M0)              r76.0<1>:f    0.0:f                               {Compacted}
        sync.nop                             null                             {Compacted,I@1}
        send.ugm (1|M0)          r106     r22     null:0  0x0            0x0280E780           {$2} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        mov (16|M0)              r8.0<1>:f     0.0:f                               {Compacted}
        mov (16|M0)              r10.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r6.0<1>:f     0.0:f                               {Compacted,$0.src}
        addc (1|M0)              r22.0<1>:ud   r124.0<0;1,0>:ud  0x600:ud              {AccWrEn,$2.src}
        mov (16|M0)              r16.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r14.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r18.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r20.0<1>:f    0.0:f                               {Compacted}
        mov (1|M0)               r23.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        add3 (1|M0)              r22.1<1>:d    r23.0<0;0>:d      r124.1<0;0>:d     0:w               {I@1}
        send.slm (1|M0)          r78      r125    null:0  0x0            0x0280E700           {$3} // wr:1+0, rd:8; load.slm.d64x32t.a32
        send.ugm (1|M0)          r62      r22     null:0  0x0            0x0280E780           {A@1,$4} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        addc (1|M0)              r22.0<1>:ud   r124.0<0;1,0>:ud  0x700:ud              {AccWrEn,$4.src}
        mov (16|M0)              r114.0<1>:f   0.0:f                               {Compacted}
        mov (1|M0)               r23.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        add3 (1|M0)              r22.1<1>:d    r23.0<0;0>:d      r124.1<0;0>:d     0:w               {I@1}
        mov (16|M0)              r116.0<1>:f   0.0:f                               {Compacted}
        sync.nop                             null                             {Compacted,F@7}
        sync.allwr                           ($13,$14,$15)                
        dpas.8x8 (8|M0)          r70:f         null:f            r70:hf            r70.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r70:f         r70:f             r38:hf            r46.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r6:f          r6:f              r38:hf            r94.0:hf         {$13}
        mov (16|M0)              r38.0<1>:f    0.0:f                               {Compacted,$13.src}
        mov (16|M0)              r40.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r42.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r44.0<1>:f    0.0:f                               {Compacted}
        sync.nop                             null                             {Compacted,A@1}
        sync.nop                             null                             {Compacted,$0.dst}
        dpas.8x8 (8|M0)          r14:f         null:f            r14:hf            r14.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r14:f         r14:f             r86:hf            r46.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r38:f         r38:f             r86:hf            r94.0:hf         {$0}
        sync.nop                             null                             {Compacted,$0.src}
        send.slm (1|M0)          r86      r126    null:0  0x0            0x0280E700           {$5} // wr:1+0, rd:8; load.slm.d64x32t.a32
        sync.allwr                           ($3,$13)                
        dpas.8x8 (8|M0)          r6:f          r6:f              r30:hf            r78.0:hf         {$1}
        mov (16|M0)              r118.0<1>:f   0.0:f                               {Compacted}
        mov (16|M0)              r120.0<1>:f   0.0:f                               {Compacted}
        mov (16|M0)              r24.0<1>:f    0.0:f                               {Compacted}
        sync.allwr                           ($0,$2,$5)                
        dpas.8x8 (8|M0)          r70:f         null:f            r70:hf            r70.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r70:f         r70:f             r30:hf            r86.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r14:f         r14:f             r106:hf           r86.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r38:f         r38:f             r106:hf           r78.0:hf         {$2}
        sync.nop                             null                             {Compacted,I@1}
        sync.nop                             null                             {Compacted,$2.src}
        send.ugm (1|M0)          r106     r22     null:0  0x0            0x0280E780           {$6} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        addc (1|M0)              r31.0<1>:ud   r124.0<0;1,0>:ud  0x1200:ud              {AccWrEn}
        mov (16|M0)              r26.0<1>:f    0.0:f                               {Compacted}
        mov (1|M0)               r30.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r54.0<1>:d    r31.0<0;1,0>:d                   {I@2}
        add3 (1|M0)              r54.1<1>:d    r30.0<0;0>:d      r124.1<0;0>:d     0:w               {I@2}
        mov (16|M0)              r28.0<1>:f    0.0:f                               {Compacted}
        send.ugm (1|M0)          r30      r54     null:0  0x0            0x0280E780           {A@1,$7} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        mov (16|M0)              r22.0<1>:f    0.0:f                               {Compacted,$6.src}
        addc (1|M0)              r54.0<1>:ud   r124.0<0;1,0>:ud  0x1300:ud              {AccWrEn,$7.src}
        mov (1|M0)               r55.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        add3 (1|M0)              r54.1<1>:d    r55.0<0;0>:d      r124.1<0;0>:d     0:w               {I@1}
        sync.nop                             null                             {Compacted,A@1}
        sync.allwr                           ($4,$6)                
        dpas.8x8 (8|M0)          r22:f         r22:f             r62:hf            r46.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r114:f        r114:f            r106:hf           r46.0:hf         {$4}
        mov (16|M0)              r46.0<1>:f    0.0:f                               {Compacted,$4.src}
        mov (16|M0)              r48.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r50.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r52.0<1>:f    0.0:f                               {Compacted}
        sync.nop                             null                             {Compacted,A@1}
        dpas.8x8 (8|M0)          r46:f         r46:f             r62:hf            r94.0:hf         {$8}
        mov (16|M0)              r62.0<1>:f    0.0:f                               {Compacted,$8.src}
        mov (16|M0)              r64.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r66.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r68.0<1>:f    0.0:f                               {Compacted}
        sync.nop                             null                             {Compacted,A@1}
        dpas.8x8 (8|M0)          r62:f         r62:f             r106:hf           r94.0:hf         {$10}
        sync.nop                             null                             {Compacted,I@1}
        sync.nop                             null                             {Compacted,$10.src}
        send.ugm (1|M0)          r94      r54     null:0  0x0            0x0280E780           {$11} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        sync.allwr                           ($4,$7,$8)                
        dpas.8x8 (8|M0)          r22:f         null:f            r22:hf            r22.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r22:f         r22:f             r30:hf            r86.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r46:f         r46:f             r30:hf            r78.0:hf         {$7}
        sync.nop                             null                             {Compacted,$7.src}
        mov (8|M0)               r30.0<1>:f    r70.0<1;1,0>:f                   {Compacted,$2.dst}
        mov (8|M0)               r31.0<1>:f    r14.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r108.0<1>:f   r13.0<1;1,0>:f                   {Compacted,$1.dst}
        send.slm (1|M0)          null     r122    r30:2   0x0            0x0200C704           {A@2,$12} // wr:1+2, rd:0; store.slm.d64x8t.a32
        or (1|M0)                r30.0<1>:ud   r122.0<0;1,0>:ud  0x400:uw              {$12.src}
        mov (8|M0)               r109.0<1>:f   r45.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r60.0<1>:f    r22.0<1;1,0>:f                   {Compacted,$7.dst}
        mov (8|M0)               r58.0<1>:f    r46.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r56.0<1>:f    r23.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r54.0<1>:f    r24.0<1;1,0>:f                   {Compacted,$11.src}
        mov (8|M0)               r36.0<1>:f    r25.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r34.0<1>:f    r26.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r32.0<1>:f    r27.0<1;1,0>:f                   {Compacted}
        mov (16|M0)              r106.0<1>:f   0.0:f                               {Compacted}
        mov (16|M0)              r110.0<1>:f   0.0:f                               {Compacted}
        mov (16|M0)              r112.0<1>:f   0.0:f                               {Compacted}
        sync.allwr                           ($10,$11)                
(W)     sync.nop                             null                            
(W)     sync.nop                             null                            
        dpas.8x8 (8|M0)          r114:f        null:f            r114:hf           r114.0:hf        {Atomic}
        dpas.8x8 (8|M0)          r114:f        r114:f            r94:hf            r86.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r62:f         r62:f             r94:hf            r78.0:hf         {$10}
        mov (8|M0)               r78.0<1>:f    r6.0<1;1,0>:f                    {Compacted,$10.src}
        mov (8|M0)               r79.0<1>:f    r38.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r80.0<1>:f    r47.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r30     r78:2   0x0            0x0200C704           {A@1,$13} // wr:1+2, rd:0; store.slm.d64x8t.a32
        or (1|M0)                r30.0<1>:ud   r122.0<0;1,0>:ud  0x40:uw              {$13.src}
        mov (8|M0)               r78.0<1>:f    r48.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r61.0<1>:f    r114.0<1;1,0>:f                  {Compacted,$10.dst}
        mov (8|M0)               r59.0<1>:f    r62.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r30     r60:2   0x0            0x0200C704           {A@1,$14} // wr:1+2, rd:0; store.slm.d64x8t.a32
        or (1|M0)                r30.0<1>:ud   r122.0<0;1,0>:ud  0x440:uw              {$14.src}
        mov (8|M0)               r60.0<1>:f    r71.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r30     r58:2   0x0            0x0200C704           {A@1,$15} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r61.0<1>:f    r15.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r30.0<1>:ud   r122.0<0;1,0>:ud  0x80:uw              {$15.src}
        mov (8|M0)               r58.0<1>:f    r7.0<1;1,0>:f                    {Compacted}
        send.slm (1|M0)          null     r30     r60:2   0x0            0x0200C704           {A@1,$0} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r59.0<1>:f    r39.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r30.0<1>:ud   r122.0<0;1,0>:ud  0x480:uw              {$0.src}
        mov (8|M0)               r57.0<1>:f    r115.0<1;1,0>:f                  {Compacted}
        send.slm (1|M0)          null     r30     r58:2   0x0            0x0200C704           {A@1,$1} // wr:1+2, rd:0; store.slm.d64x8t.a32
        or (1|M0)                r30.0<1>:ud   r122.0<0;1,0>:ud  0xC0:uw              {$1.src}
        mov (8|M0)               r81.0<1>:f    r63.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r30     r56:2   0x0            0x0200C704           {A@1,$2} // wr:1+2, rd:0; store.slm.d64x8t.a32
        or (1|M0)                r30.0<1>:ud   r122.0<0;1,0>:ud  0x4C0:uw              {$2.src}
        mov (8|M0)               r58.0<1>:f    r72.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r30     r80:2   0x0            0x0200C704           {A@1,$3} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r59.0<1>:f    r16.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r30.0<1>:ud   r122.0<0;1,0>:ud  0x100:uw              {$3.src}
        mov (8|M0)               r56.0<1>:f    r8.0<1;1,0>:f                    {Compacted}
        send.slm (1|M0)          null     r30     r58:2   0x0            0x0200C704           {A@1,$4} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r57.0<1>:f    r40.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r30.0<1>:ud   r122.0<0;1,0>:ud  0x500:uw              {$4.src}
        mov (8|M0)               r55.0<1>:f    r116.0<1;1,0>:f                  {Compacted}
        send.slm (1|M0)          null     r30     r56:2   0x0            0x0200C704           {A@1,$5} // wr:1+2, rd:0; store.slm.d64x8t.a32
        or (1|M0)                r30.0<1>:ud   r122.0<0;1,0>:ud  0x140:uw              {$5.src}
        mov (8|M0)               r79.0<1>:f    r64.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r30     r54:2   0x0            0x0200C704           {A@1,$6} // wr:1+2, rd:0; store.slm.d64x8t.a32
        or (1|M0)                r30.0<1>:ud   r122.0<0;1,0>:ud  0x540:uw              {$6.src}
        mov (8|M0)               r56.0<1>:f    r73.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r30     r78:2   0x0            0x0200C704           {A@1,$7} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r57.0<1>:f    r17.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r30.0<1>:ud   r122.0<0;1,0>:ud  0x180:uw              {$7.src}
        mov (8|M0)               r54.0<1>:f    r9.0<1;1,0>:f                    {Compacted}
        send.slm (1|M0)          null     r30     r56:2   0x0            0x0200C704           {A@1,$8} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r55.0<1>:f    r41.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r30.0<1>:ud   r122.0<0;1,0>:ud  0x580:uw              {$8.src}
        mov (8|M0)               r37.0<1>:f    r117.0<1;1,0>:f                  {Compacted}
        send.slm (1|M0)          null     r30     r54:2   0x0            0x0200C704           {A@1,$10} // wr:1+2, rd:0; store.slm.d64x8t.a32
        or (1|M0)                r30.0<1>:ud   r122.0<0;1,0>:ud  0x1C0:uw              {$10.src}
        mov (8|M0)               r60.0<1>:f    r49.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r30     r36:2   0x0            0x0200C704           {A@1,$11} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r61.0<1>:f    r65.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r30.0<1>:ud   r122.0<0;1,0>:ud  0x5C0:uw              {$11.src}
        mov (8|M0)               r54.0<1>:f    r74.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r30     r60:2   0x0            0x0200C704           {A@1,$12} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r55.0<1>:f    r18.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r30.0<1>:ud   r122.0<0;1,0>:ud  0x200:uw              {$12.src}
        mov (8|M0)               r36.0<1>:f    r10.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r30     r54:2   0x0            0x0200C704           {A@1,$13} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r37.0<1>:f    r42.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r30.0<1>:ud   r122.0<0;1,0>:ud  0x600:uw              {$13.src}
        mov (8|M0)               r35.0<1>:f    r118.0<1;1,0>:f                  {Compacted}
        send.slm (1|M0)          null     r30     r36:2   0x0            0x0200C704           {A@1,$14} // wr:1+2, rd:0; store.slm.d64x8t.a32
        or (1|M0)                r30.0<1>:ud   r122.0<0;1,0>:ud  0x240:uw              {$14.src}
        mov (8|M0)               r58.0<1>:f    r50.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r30     r34:2   0x0            0x0200C704           {A@1,$15} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r59.0<1>:f    r66.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r30.0<1>:ud   r122.0<0;1,0>:ud  0x640:uw              {$15.src}
        mov (8|M0)               r36.0<1>:f    r75.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r30     r58:2   0x0            0x0200C704           {A@1,$0} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r37.0<1>:f    r19.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r30.0<1>:ud   r122.0<0;1,0>:ud  0x280:uw              {$0.src}
        mov (8|M0)               r34.0<1>:f    r11.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r30     r36:2   0x0            0x0200C704           {A@1,$1} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r35.0<1>:f    r43.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r30.0<1>:ud   r122.0<0;1,0>:ud  0x680:uw              {$1.src}
        mov (8|M0)               r33.0<1>:f    r119.0<1;1,0>:f                  {Compacted}
        send.slm (1|M0)          null     r30     r34:2   0x0            0x0200C704           {A@1,$2} // wr:1+2, rd:0; store.slm.d64x8t.a32
        or (1|M0)                r30.0<1>:ud   r122.0<0;1,0>:ud  0x2C0:uw              {$2.src}
        mov (8|M0)               r56.0<1>:f    r51.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r30     r32:2   0x0            0x0200C704           {A@1,$3} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r57.0<1>:f    r67.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r36.0<1>:ud   r122.0<0;1,0>:ud  0x300:uw             
        mov (8|M0)               r34.0<1>:f    r76.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r35.0<1>:f    r20.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r30.0<1>:ud   r122.0<0;1,0>:ud  0x6C0:uw              {$3.src}
        mov (8|M0)               r32.0<1>:f    r12.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r30     r56:2   0x0            0x0200C704           {A@1,$4} // wr:1+2, rd:0; store.slm.d64x8t.a32
        send.slm (1|M0)          null     r36     r34:2   0x0            0x0200C704           {A@2,$5} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r33.0<1>:f    r44.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r34.0<1>:ud   r122.0<0;1,0>:ud  0x700:uw              {$5.src}
        mov (8|M0)               r31.0<1>:f    r120.0<1;1,0>:f                  {Compacted}
        send.slm (1|M0)          null     r34     r32:2   0x0            0x0200C704           {A@1,$6} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r30.0<1>:f    r28.0<1;1,0>:f                   {Compacted,$4.src}
        or (1|M0)                r32.0<1>:ud   r122.0<0;1,0>:ud  0x340:uw              {$6.src}
        mov (8|M0)               r54.0<1>:f    r52.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r32     r30:2   0x0            0x0200C704           {A@1,$7} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r55.0<1>:f    r68.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r30.0<1>:ud   r122.0<0;1,0>:ud  0x740:uw              {$7.src}
        or (1|M0)                r6.0<1>:ud    r122.0<0;1,0>:ud  0x380:uw             
        send.slm (1|M0)          null     r30     r54:2   0x0            0x0200C704           {A@1,$8} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r31.0<1>:f    r21.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r30.0<1>:f    r77.0<1;1,0>:f                   {Compacted,$8.src}
        mov (8|M0)               r17.0<1>:f    r29.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r6      r30:2   0x0            0x0200C704           {A@1,$10} // wr:1+2, rd:0; store.slm.d64x8t.a32
        or (1|M0)                r6.0<1>:ud    r122.0<0;1,0>:ud  0x780:uw              {$10.src}
        mov (8|M0)               r18.0<1>:f    r121.0<1;1,0>:f                  {Compacted}
        sync.nop                             null                             {Compacted,I@1}
        send.slm (1|M0)          null     r6      r108:2  0x0            0x0200C704           {$11} // wr:1+2, rd:0; store.slm.d64x8t.a32
        or (1|M0)                r6.0<1>:ud    r122.0<0;1,0>:ud  0x3C0:uw              {$11.src}
        mov (8|M0)               r7.0<1>:f     r53.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r6      r17:2   0x0            0x0200C704           {A@1,$12} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r8.0<1>:f     r69.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r6.0<1>:ud    r122.0<0;1,0>:ud  0x7C0:uw              {$12.src}
        mov (16|M0)              r60.0<1>:f    0.0:f                               {Compacted}
        send.slm (1|M0)          null     r6      r7:2    0x0            0x0200C704           {A@1,$13} // wr:1+2, rd:0; store.slm.d64x8t.a32
        addc (1|M0)              r6.0<1>:ud    r124.0<0;1,0>:ud  0x800:ud              {AccWrEn,$13.src}
        mov (16|M0)              r58.0<1>:f    0.0:f                               {Compacted}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        add3 (1|M0)              r6.1<1>:d     r7.0<0;0>:d       r124.1<0;0>:d     0:w               {I@1}
        send.slm (1|M0)          r30      r102    null:0  0x0            0x0280E700           {$14} // wr:1+0, rd:8; load.slm.d64x32t.a32
        send.ugm (1|M0)          r78      r6      null:0  0x0            0x0280E780           {A@1,$15} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        addc (1|M0)              r6.0<1>:ud    r124.0<0;1,0>:ud  0x900:ud              {AccWrEn,$15.src}
        send.slm (1|M0)          r70      r127    null:0  0x0            0x0280E700           {$0} // wr:1+0, rd:8; load.slm.d64x32t.a32
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        add3 (1|M0)              r6.1<1>:d     r7.0<0;0>:d       r124.1<0;0>:d     0:w               {I@1}
        mov (16|M0)              r56.0<1>:f    0.0:f                               {Compacted}
        sync.nop                             null                             {Compacted,I@1}
        send.ugm (1|M0)          r94      r6      null:0  0x0            0x0280E780           {$1} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        addc (1|M0)              r6.0<1>:ud    r124.0<0;1,0>:ud  0x1400:ud              {AccWrEn,$1.src}
        mov (16|M0)              r54.0<1>:f    0.0:f                               {Compacted}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (16|M0)              r108.0<1>:f   0.0:f                               {Compacted}
        add3 (1|M0)              r6.1<1>:d     r7.0<0;0>:d       r124.1<0;0>:d     0:w               {I@1}
        mov (16|M0)              r86.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r88.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r90.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r92.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r62.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r64.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r66.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r68.0<1>:f    0.0:f                               {Compacted}
        send.slm (1|M0)          r14      r126    null:0  0x0            0x0280E700           {$2} // wr:1+0, rd:8; load.slm.d64x32t.a32
        send.slm (1|M0)          r22      r125    null:0  0x0            0x0280E700           {$3} // wr:1+0, rd:8; load.slm.d64x32t.a32
        mov (16|M0)              r114.0<1>:f   0.0:f                               {Compacted}
        mov (16|M0)              r116.0<1>:f   0.0:f                               {Compacted}
        mov (16|M0)              r118.0<1>:f   0.0:f                               {Compacted}
        mov (16|M0)              r120.0<1>:f   0.0:f                               {Compacted}
        sync.allwr                           ($0,$14,$15)                
(W)     sync.nop                             null                            
        dpas.8x8 (8|M0)          r106:f        null:f            r106:hf           r106.0:hf        {Atomic}
        dpas.8x8 (8|M0)          r106:f        r106:f            r78:hf            r30.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r54:f         r54:f             r78:hf            r70.0:hf         {$14}
        sync.nop                             null                             {Compacted,I@1}
        sync.nop                             null                             {Compacted,$14.src}
        send.ugm (1|M0)          r78      r6      null:0  0x0            0x0280E780           {$4} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        addc (1|M0)              r6.0<1>:ud    r124.0<0;1,0>:ud  0x1500:ud              {AccWrEn,$4.src}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        add3 (1|M0)              r6.1<1>:d     r7.0<0;0>:d       r124.1<0;0>:d     0:w               {I@1}
        sync.nop                             null                             {Compacted,A@5}
        dpas.8x8 (8|M0)          r62:f         r62:f             r94:hf            r30.0:hf         {$1}
        send.ugm (1|M0)          r46      r6      null:0  0x0            0x0280E780           {A@1,$5} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        dpas.8x8 (8|M0)          r86:f         null:f            r86:hf            r86.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r86:f         r86:f             r94:hf            r70.0:hf         {$6}
        addc (1|M0)              r7.0<1>:ud    r124.0<0;1,0>:ud  0xA00:ud              {AccWrEn}
        mov (16|M0)              r94.0<1>:f    0.0:f                               {Compacted,$6.src}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$5.src}
        mov (1|M0)               r38.0<1>:d    r7.0<0;1,0>:d                    {I@2}
        addc (1|M0)              r39.0<1>:ud   r124.0<0;1,0>:ud  0xB00:ud              {AccWrEn}
        add3 (1|M0)              r38.1<1>:d    r6.0<0;0>:d       r124.1<0;0>:d     0:w               {I@3}
        mov (16|M0)              r96.0<1>:f    0.0:f                               {Compacted}
        send.ugm (1|M0)          r6       r38     null:0  0x0            0x0280E780           {A@1,$7} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        mov (1|M0)               r38.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,$7.src}
        mov (16|M0)              r98.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r100.0<1>:f   0.0:f                               {Compacted}
        sync.allwr                           ($2,$3,$4,$14)                
        dpas.8x8 (8|M0)          r106:f        null:f            r106:hf           r106.0:hf        {Atomic}
        dpas.8x8 (8|M0)          r106:f        r106:f            r78:hf            r14.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r54:f         r54:f             r78:hf            r22.0:hf         {$2}
        mov (16|M0)              r78.0<1>:f    0.0:f                               {Compacted,$2.src}
        mov (16|M0)              r80.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r82.0<1>:f    0.0:f                               {Compacted}
        sync.allwr                           ($1,$5,$6)                
(W)     sync.nop                             null                            
(W)     sync.nop                             null                            
        dpas.8x8 (8|M0)          r62:f         null:f            r62:hf            r62.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r62:f         r62:f             r46:hf            r14.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r86:f         r86:f             r46:hf            r22.0:hf         {$1}
        mov (1|M0)               r46.0<1>:d    r39.0<0;1,0>:d                   {$1.src}
        add3 (1|M0)              r46.1<1>:d    r38.0<0;0>:d      r124.1<0;0>:d     0:w               {I@2}
        mov (16|M0)              r84.0<1>:f    0.0:f                               {Compacted}
        send.ugm (1|M0)          r38      r46     null:0  0x0            0x0280E780           {A@1,$8} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        mov (8|M0)               r126.0<1>:f   r107.0<1;1,0>:f                  {Compacted,$2.dst}
        mov (8|M0)               r127.0<1>:f   r63.0<1;1,0>:f                   {Compacted,$1.dst}
        mov (8|M0)               r125.0<1>:f   r64.0<1;1,0>:f                   {Compacted}
        sync.nop                             null                             {Compacted,A@7}
        sync.nop                             null                             {Compacted,$7.dst}
        dpas.8x8 (8|M0)          r94:f         null:f            r94:hf            r94.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r94:f         r94:f             r6:hf             r30.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r114:f        r114:f            r6:hf             r70.0:hf         {$7}
        mov (16|M0)              r6.0<1>:f     0.0:f                               {Compacted,$7.src}
        mov (16|M0)              r8.0<1>:f     0.0:f                               {Compacted}
        mov (16|M0)              r10.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r12.0<1>:f    0.0:f                               {Compacted}
        mov (8|M0)               r107.0<1>:f   r93.0<1;1,0>:f                   {Compacted}
        sync.nop                             null                             {Compacted,A@7}
        dpas.8x8 (8|M0)          r78:f         r78:f             r38:hf            r30.0:hf         {$8}
        addc (1|M0)              r30.0<1>:ud   r124.0<0;1,0>:ud  0x1600:ud              {AccWrEn,$8.src}
        sync.nop                             null                             {Compacted,A@2}
        dpas.8x8 (8|M0)          r6:f          r6:f              r38:hf            r70.0:hf         {$10}
        mov (1|M0)               r31.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        add3 (1|M0)              r30.1<1>:d    r31.0<0;0>:d      r124.1<0;0>:d     0:w               {I@1}
        addc (1|M0)              r31.0<1>:ud   r124.0<0;1,0>:ud  0x1700:ud              {AccWrEn}
        sync.nop                             null                             {Compacted,$10.src}
        send.ugm (1|M0)          r70      r30     null:0  0x0            0x0280E780           {A@2,$11} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        mov (1|M0)               r30.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,$11.src}
        mov (1|M0)               r38.0<1>:d    r31.0<0;1,0>:d                   {I@2}
        add3 (1|M0)              r38.1<1>:d    r30.0<0;0>:d      r124.1<0;0>:d     0:w               {I@2}
        mov (8|M0)               r124.0<1>:f   r108.0<1;1,0>:f                  {Compacted,I@1}
        send.ugm (1|M0)          r30      r38     null:0  0x0            0x0280E780           {$12} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        sync.allwr                           ($7,$11)                
        dpas.8x8 (8|M0)          r94:f         null:f            r94:hf            r94.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r94:f         r94:f             r70:hf            r14.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r114:f        r114:f            r70:hf            r22.0:hf         {$7}
        mov (8|M0)               r70.0<1>:f    r106.0<1;1,0>:f                  {Compacted,$7.src}
        mov (8|M0)               r71.0<1>:f    r62.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r74.0<1>:f    r55.0<1;1,0>:f                   {Compacted}
        sync.allwr                           ($8,$10,$12)                
        dpas.8x8 (8|M0)          r78:f         null:f            r78:hf            r78.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r78:f         r78:f             r30:hf            r14.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r6:f          r6:f              r30:hf            r22.0:hf         {$8}
        mov (8|M0)               r16.0<1>:f    r54.0<1;1,0>:f                   {Compacted,$8.src}
        mov (8|M0)               r17.0<1>:f    r86.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r36.0<1>:ud   r103.0<0;1,0>:ud  0x400:uw             
        send.slm (1|M0)          null     r103    r70:2   0x0            0x0200C704           {A@4,$13} // wr:1+2, rd:0; store.slm.d64x8t.a32
        send.slm (1|M0)          null     r36     r16:2   0x0            0x0200C704           {A@1,$14} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r14.0<1>:f    r94.0<1;1,0>:f                   {Compacted,$7.dst}
        or (1|M0)                r16.0<1>:ud   r103.0<0;1,0>:ud  0x40:uw              {$14.src}
        mov (8|M0)               r15.0<1>:f    r78.0<1;1,0>:f                   {Compacted,$8.dst}
        mov (8|M0)               r76.0<1>:f    r114.0<1;1,0>:f                  {Compacted}
        send.slm (1|M0)          null     r16     r14:2   0x0            0x0200C704           {A@1,$15} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r77.0<1>:f    r6.0<1;1,0>:f                    {Compacted}
        or (1|M0)                r14.0<1>:ud   r103.0<0;1,0>:ud  0x440:uw              {$15.src}
        mov (8|M0)               r75.0<1>:f    r87.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r14     r76:2   0x0            0x0200C704           {A@1,$0} // wr:1+2, rd:0; store.slm.d64x8t.a32
        or (1|M0)                r14.0<1>:ud   r103.0<0;1,0>:ud  0x80:uw              {$0.src}
        mov (8|M0)               r18.0<1>:f    r95.0<1;1,0>:f                   {Compacted}
        sync.nop                             null                             {Compacted,I@1}
        send.slm (1|M0)          null     r14     r126:2  0x0            0x0200C704           {$1} // wr:1+2, rd:0; store.slm.d64x8t.a32
        or (1|M0)                r14.0<1>:ud   r103.0<0;1,0>:ud  0x480:uw              {$1.src}
        mov (8|M0)               r19.0<1>:f    r79.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r14     r74:2   0x0            0x0200C704           {A@1,$2} // wr:1+2, rd:0; store.slm.d64x8t.a32
        or (1|M0)                r14.0<1>:ud   r103.0<0;1,0>:ud  0xC0:uw              {$2.src}
        mov (8|M0)               r17.0<1>:f    r7.0<1;1,0>:f                    {Compacted}
        send.slm (1|M0)          null     r14     r18:2   0x0            0x0200C704           {A@1,$3} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r16.0<1>:f    r115.0<1;1,0>:f                  {Compacted}
        or (1|M0)                r14.0<1>:ud   r103.0<0;1,0>:ud  0x4C0:uw              {$3.src}
        mov (8|M0)               r72.0<1>:f    r56.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r14     r16:2   0x0            0x0200C704           {A@1,$4} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r73.0<1>:f    r88.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r35.0<1>:ud   r103.0<0;1,0>:ud  0x100:uw             
        or (1|M0)                r34.0<1>:ud   r103.0<0;1,0>:ud  0x500:uw             
        or (1|M0)                r18.0<1>:ud   r103.0<0;1,0>:ud  0x140:uw             
        mov (8|M0)               r16.0<1>:f    r96.0<1;1,0>:f                   {Compacted,$4.src}
        mov (8|M0)               r17.0<1>:f    r80.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r35     r124:2  0x0            0x0200C704           {A@3,$5} // wr:1+2, rd:0; store.slm.d64x8t.a32
        send.slm (1|M0)          null     r34     r72:2   0x0            0x0200C704           {A@2,$6} // wr:1+2, rd:0; store.slm.d64x8t.a32
        send.slm (1|M0)          null     r18     r16:2   0x0            0x0200C704           {A@1,$7} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r15.0<1>:f    r8.0<1;1,0>:f                    {Compacted}
        mov (8|M0)               r14.0<1>:f    r116.0<1;1,0>:f                  {Compacted}
        or (1|M0)                r16.0<1>:ud   r103.0<0;1,0>:ud  0x540:uw              {$7.src}
        or (1|M0)                r20.0<1>:ud   r103.0<0;1,0>:ud  0x180:uw             
        send.slm (1|M0)          null     r16     r14:2   0x0            0x0200C704           {A@1,$8} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r14.0<1>:f    r109.0<1;1,0>:f                  {Compacted,$8.src}
        mov (8|M0)               r15.0<1>:f    r65.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r126.0<1>:f   r57.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r20     r14:2   0x0            0x0200C704           {A@1,$10} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r127.0<1>:f   r89.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r14.0<1>:ud   r103.0<0;1,0>:ud  0x580:uw              {$10.src}
        mov (8|M0)               r19.0<1>:f    r81.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r14     r126:2  0x0            0x0200C704           {A@1,$11} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r18.0<1>:f    r97.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r14.0<1>:ud   r103.0<0;1,0>:ud  0x1C0:uw              {$11.src}
        mov (8|M0)               r17.0<1>:f    r9.0<1;1,0>:f                    {Compacted}
        send.slm (1|M0)          null     r14     r18:2   0x0            0x0200C704           {A@1,$12} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r16.0<1>:f    r117.0<1;1,0>:f                  {Compacted}
        or (1|M0)                r14.0<1>:ud   r103.0<0;1,0>:ud  0x5C0:uw              {$12.src}
        or (1|M0)                r33.0<1>:ud   r103.0<0;1,0>:ud  0x200:uw             
        send.slm (1|M0)          null     r14     r16:2   0x0            0x0200C704           {A@1,$14} // wr:1+2, rd:0; store.slm.d64x8t.a32
        or (1|M0)                r32.0<1>:ud   r103.0<0;1,0>:ud  0x600:uw             
        mov (8|M0)               r124.0<1>:f   r58.0<1;1,0>:f                   {Compacted,$5.src}
        mov (8|M0)               r125.0<1>:f   r90.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r126.0<1>:f   r110.0<1;1,0>:f                  {Compacted}
        mov (8|M0)               r127.0<1>:f   r66.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r18.0<1>:ud   r103.0<0;1,0>:ud  0x240:uw             
        mov (8|M0)               r16.0<1>:f    r98.0<1;1,0>:f                   {Compacted,$14.src}
        mov (8|M0)               r17.0<1>:f    r82.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r33     r126:2  0x0            0x0200C704           {A@3,$15} // wr:1+2, rd:0; store.slm.d64x8t.a32
        sync.nop                             null                             {Compacted,I@2}
        send.slm (1|M0)          null     r32     r124:2  0x0            0x0200C704           {$0} // wr:1+2, rd:0; store.slm.d64x8t.a32
        send.slm (1|M0)          null     r18     r16:2   0x0            0x0200C704           {A@1,$1} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r15.0<1>:f    r10.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r14.0<1>:f    r118.0<1;1,0>:f                  {Compacted}
        or (1|M0)                r16.0<1>:ud   r103.0<0;1,0>:ud  0x640:uw              {$1.src}
        mov (8|M0)               r126.0<1>:f   r59.0<1;1,0>:f                   {Compacted,$15.src}
        send.slm (1|M0)          null     r16     r14:2   0x0            0x0200C704           {A@1,$2} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r14.0<1>:f    r111.0<1;1,0>:f                  {Compacted,$2.src}
        mov (8|M0)               r15.0<1>:f    r67.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r16.0<1>:ud   r103.0<0;1,0>:ud  0x280:uw             
        mov (8|M0)               r127.0<1>:f   r91.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r16     r14:2   0x0            0x0200C704           {A@1,$3} // wr:1+2, rd:0; store.slm.d64x8t.a32
        or (1|M0)                r14.0<1>:ud   r103.0<0;1,0>:ud  0x680:uw              {$3.src}
        mov (8|M0)               r47.0<1>:f    r99.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r14     r126:2  0x0            0x0200C704           {A@1,$4} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r48.0<1>:f    r83.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r14.0<1>:ud   r103.0<0;1,0>:ud  0x2C0:uw              {$4.src}
        mov (8|M0)               r21.0<1>:f    r119.0<1;1,0>:f                  {Compacted}
        send.slm (1|M0)          null     r14     r47:2   0x0            0x0200C704           {A@1,$5} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r22.0<1>:f    r11.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r14.0<1>:ud   r103.0<0;1,0>:ud  0x6C0:uw              {$5.src}
        or (1|M0)                r31.0<1>:ud   r103.0<0;1,0>:ud  0x300:uw             
        send.slm (1|M0)          null     r14     r21:2   0x0            0x0200C704           {A@1,$7} // wr:1+2, rd:0; store.slm.d64x8t.a32
        or (1|M0)                r30.0<1>:ud   r103.0<0;1,0>:ud  0x700:uw             
        mov (8|M0)               r45.0<1>:f    r100.0<1;1,0>:f                  {Compacted}
        mov (8|M0)               r46.0<1>:f    r84.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r124.0<1>:f   r60.0<1;1,0>:f                   {Compacted,$0.src}
        mov (8|M0)               r125.0<1>:f   r92.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r126.0<1>:f   r112.0<1;1,0>:f                  {Compacted}
        mov (8|M0)               r127.0<1>:f   r68.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r14.0<1>:ud   r103.0<0;1,0>:ud  0x340:uw              {$7.src}
        send.slm (1|M0)          null     r31     r126:2  0x0            0x0200C704           {A@1,$8} // wr:1+2, rd:0; store.slm.d64x8t.a32
        sync.nop                             null                             {Compacted,I@2}
        send.slm (1|M0)          null     r30     r124:2  0x0            0x0200C704           {$10} // wr:1+2, rd:0; store.slm.d64x8t.a32
        send.slm (1|M0)          null     r14     r45:2   0x0            0x0200C704           {A@1,$11} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r70.0<1>:f    r113.0<1;1,0>:f                  {Compacted,$13.src}
        mov (8|M0)               r71.0<1>:f    r69.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r6.0<1>:ud    r103.0<0;1,0>:ud  0x380:uw             
        mov (8|M0)               r20.0<1>:f    r12.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r19.0<1>:f    r120.0<1;1,0>:f                  {Compacted}
        or (1|M0)                r14.0<1>:ud   r103.0<0;1,0>:ud  0x740:uw              {$11.src}
        mov (8|M0)               r106.0<1>:f   r61.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r14     r19:2   0x0            0x0200C704           {A@1,$12} // wr:1+2, rd:0; store.slm.d64x8t.a32
        send.slm (1|M0)          null     r6      r70:2   0x0            0x0200C704           {$14} // wr:1+2, rd:0; store.slm.d64x8t.a32
        or (1|M0)                r6.0<1>:ud    r103.0<0;1,0>:ud  0x780:uw              {$14.src}
        mov (8|M0)               r86.0<1>:f    r101.0<1;1,0>:f                  {Compacted}
        send.slm (1|M0)          null     r6      r106:2  0x0            0x0200C704           {A@1,$15} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r87.0<1>:f    r85.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r6.0<1>:ud    r103.0<0;1,0>:ud  0x3C0:uw              {$15.src}
        mov (8|M0)               r21.0<1>:f    r121.0<1;1,0>:f                  {Compacted}
        send.slm (1|M0)          null     r6      r86:2   0x0            0x0200C704           {A@1,$0} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r22.0<1>:f    r13.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r6.0<1>:ud    r103.0<0;1,0>:ud  0x7C0:uw              {$0.src}
        send.slm (1|M0)          null     r6      r21:2   0x0            0x0200C704           {A@1,$1} // wr:1+2, rd:0; store.slm.d64x8t.a32
        sync.nop                             null                             {Compacted,$6.src}
(W)     send.slm (1|M0)          r73      r0      null:0  0x0            0x0210001F           {$2} // wr:1+0, rd:1; fence.slm.none.group
(W)     mov (1|M0)               r72.2<1>:ud   0x0:ud                             
(W)     mov (2|M0)               r72.10<1>:ub  r0.11<0;1,0>:ub                 
(W)     mov (8|M0)               null<1>:ud    r73.0<1;1,0>:ud                  {$2.dst}
(W)     send.gtwy (1|M0)         null     r72     null:0  0x0            0x02000004           {A@2,$3} // wr:1+0, rd:0; signal barrier
(W)     sync.bar                             null                            
        shl (1|M0)               r30.1<1>:ud   r3.0<0;1,0>:ud    0x5:uw              {$10.src}
        shl (1|M0)               r6.1<1>:ud    r3.0<0;1,0>:ud    0x4:uw              {$1.src}
        shl (1|M0)               r6.5<1>:d     r1.5<0;1,0>:d     7:w              
        and (1|M0)               r6.2<1>:ud    r30.1<0;1,0>:ud   0x1FFE00:ud              {I@3}
        and (1|M0)               r6.0<1>:ud    r6.1<0;1,0>:ud    0x70:uw              {I@3}
        and (1|M0)               r6.4<1>:ud    r30.1<0;1,0>:ud   0x100:uw             
        bfn.0xFE (1|M0)          r6.2<1>:ud    r3.7<0;0>:ud      r6.2<0;0>:ud      r6.0<0>:ud       {I@2} // s0|s1|s2
        or (1|M0)                r6.0<1>:d     r104.0<0;1,0>:d   r6.5<0;1,0>:d    {Compacted}
        bfn.0xEA (1|M0)          r6.4<1>:ud    r6.4<0;0>:ud      r123.0<0;0>:ud    0x1C:uw              {I@3} // s0|s1&s2
        send.slm (1|M0)          r59      r6      null:0  0x0            0x0240D700           {A@1,$4} // wr:1+0, rd:4; load.slm.d64x16t.a32
        cmp (1|M0)    (eq)f0.0   null<1>:d     r2.4<0;1,0>:d     102:w              
        shl (1|M0)               r6.2<1>:ud    r6.2<0;1,0>:ud    0x1:uw              {$4.src}
        and (1|M0)               r6.3<1>:d     r1.0<0;1,0>:uw    1:w              
        add (1|M0)               r8.0<1>:ud    r6.2<0;1,0>:ud    0x1000:uw              {I@2}
(W)     and (1|M0)               f0.0<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
        add (1|M0)               r17.0<1>:ud   r6.2<0;1,0>:ud    0x1200:uw             
        mov (8|M0)               r37.0<1>:hf   r59.0<1;1,0>:f                   {$4.dst}
        mov (8|M0)               r20.0<1>:hf   r61.0<1;1,0>:f                   {$12.src}
        mov (8|M0)               r41.0<1>:f    r37.0<1;1,0>:hf                  {F@2}
        mov (8|M0)               r39.0<1>:f    r20.0<1;1,0>:hf                  {F@2}
        mul (8|M0)               r75.0<1>:f    r41.0<1;1,0>:f    r41.0<1;1,0>:f   {Compacted,F@2}
        mul (8|M0)               r74.0<1>:f    r39.0<1;1,0>:f    r39.0<1;1,0>:f   {Compacted,F@2}
        mov (8|M0)               r30.8<1>:hf   r75.0<1;1,0>:f                   {F@2}
        mov (8|M0)               r37.8<1>:hf   r60.0<1;1,0>:f                  
        mov (8|M0)               r20.8<1>:hf   r62.0<1;1,0>:f                  
        mov (8|M0)               acc0.0<1>:f   r30.8<1;1,0>:hf                  {F@3}
        mov (8|M0)               r30.8<1>:hf   r74.0<1;1,0>:f                  
        mov (8|M0)               r42.0<1>:f    r37.8<1;1,0>:hf                  {F@4}
        mov (8|M0)               r40.0<1>:f    r20.8<1;1,0>:hf                  {F@4}
        mov (8|M0)               acc1.0<1>:f   r30.8<1;1,0>:hf                  {F@3}
        mad (8|M0)               r50.0<1>:f    acc0.0<1;0>:f     r42.0<1;0>:f      r42.0<1>:f       {F@3}
        mad (8|M0)               r48.0<1>:f    acc1.0<1;0>:f     r40.0<1;0>:f      r40.0<1>:f       {F@3}
        mov (8|M0)               r9.0<1>:hf    r50.0<1;1,0>:f                   {F@2}
        mov (8|M0)               r7.0<1>:hf    r48.0<1;1,0>:f                   {F@2}
        shl (1|M0)               r6.2<1>:ud    r3.0<0;1,0>:ud    0x3:uw             
        add (8|M0)               r9.0<1>:hf    r9.0<1;1,0>:hf    r7.0<1;1,0>:hf   {F@1}
        and (1|M0)               r6.2<1>:ud    r6.2<0;1,0>:ud    0x70:uw              {I@1}
        mov (8|M0)               r47.0<1>:f    r9.0<1;1,0>:hf                   {F@1}
        mov (4|M0)               r7.0<1>:ud    r47.4<1;1,0>:ud                  {F@1}
        add (4|M0)               r73.0<1>:f    r7.0<1;1,0>:f     r47.0<1;1,0>:f   {I@1}
        send.ugm (1|M0)          r7       r4      null:0  0x0            0x04100580           {A@1,$5} // wr:2+0, rd:1; load.ugm.d32.a64
        mov (8|M0)               r30.8<1>:hf   r73.0<1;1,0>:f                  
        mov (4|M0)               r46.0<1>:f    r30.8<1;1,0>:hf                  {F@1}
        add (1|M0)               r45.0<1>:f    r46.2<0;1,0>:f    r46.0<0;1,0>:f   {Compacted,F@1}
        add (1|M0)               r45.1<1>:f    r46.3<0;1,0>:f    r46.1<0;1,0>:f  
        mov (8|M0)               r8.8<1>:hf    r45.0<1;1,0>:f                   {F@1}
        mov (1|M0)               r44.0<1>:f    r8.8<0;1,0>:hf                   {F@1}
        mov (1|M0)               r44.1<1>:f    r8.9<0;1,0>:hf                  
        add (1|M0)               r6.6<1>:f     r44.0<0;1,0>:f    r44.1<0;1,0>:f   {F@1}
        mov (1|M0)               r6.12<2>:hf   r6.6<0;1,0>:f                    {F@1}
        mov (1|M0)               r6.6<1>:f     r6.12<0;1,0>:hf                  {F@1}
        sel (1|M0)    (ge)f0.0   r6.6<1>:f     r6.6<0;1,0>:f     6.198883e-05:f               {F@1}
        math.sqt (1|M0)          r6.6<1>:f     r6.6<0;1,0>:f                    {@1,$6}
        math.inv (1|M0)          r6.6<1>:f     r6.6<0;1,0>:f                    {$6}
        mov (1|M0)               r6.12<2>:hf   r6.6<0;1,0>:f                    {$6.dst}
        mov (1|M0)               r6.7<1>:f     r6.12<0;1,0>:hf                  {F@1}
        mul (16|M0)              r41.0<1>:f    r6.7<0;1,0>:f     r41.0<1;1,0>:f   {Compacted,F@1}
        mul (16|M0)              r39.0<1>:f    r6.7<0;1,0>:f     r39.0<1;1,0>:f   {Compacted}
        mov (8|M0)               r29.0<1>:hf   r41.0<1;1,0>:f                   {F@2}
        mov (8|M0)               r29.8<1>:hf   r42.0<1;1,0>:f                  
        mov (8|M0)               r28.0<1>:hf   r39.0<1;1,0>:f                   {F@3}
        mov (8|M0)               r28.8<1>:hf   r40.0<1;1,0>:f                  
        mov (8|M0)               r125.0<1>:f   r29.0<1;1,0>:hf                  {F@4}
        sync.nop                             null                             {Compacted,$8.src}
        mov (8|M0)               r126.0<1>:f   r29.8<1;1,0>:hf                  {F@4}
        mov (8|M0)               r123.0<1>:f   r28.0<1;1,0>:hf                  {F@4}
        mov (8|M0)               r124.0<1>:f   r28.8<1;1,0>:hf                  {F@4}
        mov (1|M0)               r6.12<2>:hf   r7.0<0;1,0>:f                    {$5.dst}
        mov (1|M0)               r6.6<1>:f     r6.12<0;1,0>:hf                  {F@1}
        mul (16|M0)              r125.0<1>:f   r6.6<0;1,0>:f     r125.0<1;1,0>:f  {Compacted,F@1}
        mul (16|M0)              r123.0<1>:f   r6.6<0;1,0>:f     r123.0<1;1,0>:f  {Compacted}
        mov (8|M0)               r39.0<1>:hf   r125.0<1;1,0>:f                  {F@2}
        mov (8|M0)               r39.8<1>:hf   r126.0<1;1,0>:f                 
        mov (8|M0)               r22.0<1>:hf   r123.0<1;1,0>:f                  {F@3}
        mov (8|M0)               r22.8<1>:hf   r124.0<1;1,0>:f                 
        mov (8|M0)               r43.0<1>:f    (abs)r39.0<1;1,0>:hf             {F@4}
        mov (8|M0)               r44.0<1>:f    (abs)r39.8<1;1,0>:hf             {F@4}
        mov (8|M0)               r120.0<1>:f   (abs)r22.0<1;1,0>:hf             {F@4}
        mov (8|M0)               r121.0<1>:f   (abs)r22.8<1;1,0>:hf             {F@4}
        sel (16|M0)   (lt)f0.0   r43.0<1>:f    r43.0<1;1,0>:f    448.0:f               {Compacted,F@3}
        sel (16|M0)   (lt)f0.0   r120.0<1>:f   r120.0<1;1,0>:f   448.0:f               {Compacted,F@2}
        shr (16|M0)              r110.0<1>:ud  r43.0<1;1,0>:ud   0x17:uw              {F@2}
        shr (16|M0)              r108.0<1>:ud  r120.0<1;1,0>:ud  0x17:uw              {F@1}
        sel (16|M0)   (ge)f0.0   r15.0<2>:ub   r110.0<4;1,0>:ub  0x79:uw              {I@2}
        sel (16|M0)   (ge)f0.0   r16.0<2>:ub   r108.0<4;1,0>:ub  0x79:uw              {I@2}
        mov (16|M0)              r11.0<1>:d    r15.0<2;1,0>:ub                  {I@2}
        mov (16|M0)              r9.0<1>:d     r16.0<2;1,0>:ub                  {I@2}
        shl (16|M0)              r11.0<1>:d    r11.0<1;1,0>:d    23:w               {Compacted,I@2}
        shl (16|M0)              r9.0<1>:d     r9.0<1;1,0>:d     23:w               {Compacted,I@2}
        add (16|M0)              r13.0<1>:d    r11.0<1;1,0>:d    -25165824:d               {I@2}
        add (16|M0)              r108.0<1>:d   r9.0<1;1,0>:d     -25165824:d               {I@2}
        add (16|M0)              r11.0<1>:d    -r11.0<1;1,0>:d   -2139095040:d              
        add (16|M0)              r9.0<1>:d     -r9.0<1;1,0>:d    -2139095040:d              
        mul (16|M0)              acc0.0<1>:f   r43.0<1;1,0>:f    r11.0<1;1,0>:f   {Compacted,I@2}
        mul (16|M0)              acc2.0<1>:f   r120.0<1;1,0>:f   r9.0<1;1,0>:f    {Compacted,I@1}
        rnde (16|M0)             acc0.0<1>:f   acc0.0<1;1,0>:f                 
        rnde (16|M0)             acc2.0<1>:f   acc2.0<1;1,0>:f                 
        cmp (16|M0)   (lt)f1.1   null<1>:f     r125.0<1;1,0>:f   0xB3000000:f              
        cmp (16|M0)   (lt)f1.0   null<1>:f     r123.0<1;1,0>:f   0xB3000000:f               {Compacted}
        mul (16|M0)              acc0.0<1>:f   acc0.0<1;1,0>:f   r13.0<1;1,0>:f   {Compacted}
        mul (16|M0)              acc2.0<1>:f   acc2.0<1;1,0>:f   r108.0<1;1,0>:f  {Compacted}
        mov (16|M0)              r25.0<1>:f    (abs)acc0.0<1;1,0>:f             {Compacted}
        mov (16|M0)              r86.0<1>:f    (abs)acc2.0<1;1,0>:f             {Compacted}
(f1.1)  or (16|M0)               r25.0<1>:d    r25.0<1;1,0>:d    -2147483648:d               {F@2}
(f1.0)  or (16|M0)               r86.0<1>:d    r86.0<1;1,0>:d    -2147483648:d               {F@1}
        mov (8|M0)               r49.0<1>:hf   r25.0<1;1,0>:f                   {I@2}
        mov (8|M0)               r49.8<1>:hf   r26.0<1;1,0>:f                  
        mov (8|M0)               r53.0<1>:hf   r86.0<1;1,0>:f                   {I@1}
        mov (8|M0)               r53.8<1>:hf   r87.0<1;1,0>:f                  
        send.slm (1|M0)          null     r8      r49:1   0x0            0x0200B704           {A@3,$7} // wr:1+1, rd:0; store.slm.d64x4t.a32
        send.slm (1|M0)          null     r17     r53:1   0x0            0x0200B704           {A@1,$8} // wr:1+1, rd:0; store.slm.d64x4t.a32
(f0.0.any16h) goto (16|M0)                   L34576                  L34576                
L12952:
        or (1|M0)                r7.0<1>:d     r122.0<0;1,0>:d   r6.5<0;1,0>:d    {Compacted}
        mov (1|M0)               r6.7<1>:d     0:w                              
        send.slm (1|M0)          r63      r7      null:0  0x0            0x0240D700           {A@2,$10} // wr:1+0, rd:4; load.slm.d64x16t.a32
        mov (8|M0)               r52.0<1>:hf   r63.0<1;1,0>:f                   {$10.dst}
        mov (8|M0)               r43.0<1>:hf   r65.0<1;1,0>:f                  
        mov (8|M0)               r118.0<1>:f   r52.0<1;1,0>:hf                  {F@2}
        mov (8|M0)               r116.0<1>:f   r43.0<1;1,0>:hf                  {F@2}
        sync.nop                             null                             {Compacted,$3.src}
        mul (8|M0)               r72.0<1>:f    r118.0<1;1,0>:f   r118.0<1;1,0>:f  {Compacted,F@2}
        mul (8|M0)               r71.0<1>:f    r116.0<1;1,0>:f   r116.0<1;1,0>:f  {Compacted,F@2}
        mov (8|M0)               r30.8<1>:hf   r72.0<1;1,0>:f                   {F@2}
        mov (8|M0)               r52.8<1>:hf   r64.0<1;1,0>:f                  
        mov (8|M0)               r43.8<1>:hf   r66.0<1;1,0>:f                  
        mov (8|M0)               acc0.0<1>:f   r30.8<1;1,0>:hf                  {F@3}
        mov (8|M0)               r30.8<1>:hf   r71.0<1;1,0>:f                  
        mov (8|M0)               r119.0<1>:f   r52.8<1;1,0>:hf                  {F@4}
        mov (8|M0)               r117.0<1>:f   r43.8<1;1,0>:hf                  {F@4}
        mov (8|M0)               acc1.0<1>:f   r30.8<1;1,0>:hf                  {F@3}
        mad (8|M0)               r63.0<1>:f    acc0.0<1;0>:f     r119.0<1;0>:f     r119.0<1>:f      {F@3}
        mad (8|M0)               r58.0<1>:f    acc1.0<1;0>:f     r117.0<1;0>:f     r117.0<1>:f      {F@3}
        sync.nop                             null                             {Compacted,$7.src}
        mov (8|M0)               r8.0<1>:hf    r63.0<1;1,0>:f                   {F@2}
        mov (8|M0)               r7.0<1>:hf    r58.0<1;1,0>:f                   {F@2}
        add (8|M0)               r8.0<1>:hf    r8.0<1;1,0>:hf    r7.0<1;1,0>:hf   {F@1}
        mov (8|M0)               r57.0<1>:f    r8.0<1;1,0>:hf                   {F@1}
        mov (4|M0)               r7.0<1>:ud    r57.4<1;1,0>:ud                  {F@1}
        add (4|M0)               r70.0<1>:f    r7.0<1;1,0>:f     r57.0<1;1,0>:f   {I@1}
        mov (8|M0)               r30.8<1>:hf   r70.0<1;1,0>:f                   {F@1}
        mov (4|M0)               r56.0<1>:f    r30.8<1;1,0>:hf                  {F@1}
        add (1|M0)               r55.0<1>:f    r56.2<0;1,0>:f    r56.0<0;1,0>:f   {Compacted,F@1}
        add (1|M0)               r55.1<1>:f    r56.3<0;1,0>:f    r56.1<0;1,0>:f  
        mov (8|M0)               r30.8<1>:hf   r55.0<1;1,0>:f                   {F@1}
        mov (1|M0)               r54.0<1>:f    r30.8<0;1,0>:hf                  {F@1}
        mov (1|M0)               r54.1<1>:f    r30.9<0;1,0>:hf                 
        add (1|M0)               r6.6<1>:f     r54.0<0;1,0>:f    r54.1<0;1,0>:f   {F@1}
        mov (1|M0)               r6.12<2>:hf   r6.6<0;1,0>:f                    {F@1}
        mov (1|M0)               r6.6<1>:f     r6.12<0;1,0>:hf                  {F@1}
        sel (1|M0)    (ge)f0.0   r6.6<1>:f     r6.6<0;1,0>:f     6.198883e-05:f               {F@1}
        math.sqt (1|M0)          r6.6<1>:f     r6.6<0;1,0>:f                    {@1,$11}
        math.inv (1|M0)          r6.6<1>:f     r6.6<0;1,0>:f                    {$11}
        mov (1|M0)               r6.12<2>:hf   r6.6<0;1,0>:f                    {$11.dst}
        mov (1|M0)               r6.6<1>:f     r6.12<0;1,0>:hf                  {F@1}
        mul (16|M0)              r118.0<1>:f   r6.6<0;1,0>:f     r118.0<1;1,0>:f  {Compacted,F@1}
        mul (16|M0)              r116.0<1>:f   r6.6<0;1,0>:f     r116.0<1;1,0>:f  {Compacted}
        mov (8|M0)               r51.0<1>:hf   r118.0<1;1,0>:f                  {F@2}
        mov (8|M0)               r51.8<1>:hf   r119.0<1;1,0>:f                 
        mov (8|M0)               r42.0<1>:hf   r116.0<1;1,0>:f                  {F@3}
        mov (8|M0)               r42.8<1>:hf   r117.0<1;1,0>:f                 
        mov (8|M0)               r82.0<1>:f    (abs)r51.0<1;1,0>:hf             {F@4}
        mov (8|M0)               r83.0<1>:f    (abs)r51.8<1;1,0>:hf             {F@4}
        mov (8|M0)               r80.0<1>:f    (abs)r42.0<1;1,0>:hf             {F@4}
        mov (8|M0)               r81.0<1>:f    (abs)r42.8<1;1,0>:hf             {F@4}
        sel (16|M0)   (lt)f0.0   r82.0<1>:f    r82.0<1;1,0>:f    448.0:f               {Compacted,F@3}
        sel (16|M0)   (lt)f0.0   r80.0<1>:f    r80.0<1;1,0>:f    448.0:f               {Compacted,F@2}
        shr (16|M0)              r71.0<1>:ud   r82.0<1;1,0>:ud   0x17:uw              {F@2}
        shr (16|M0)              r69.0<1>:ud   r80.0<1;1,0>:ud   0x17:uw              {F@1}
        sel (16|M0)   (ge)f0.0   r106.0<2>:ub  r71.0<4;1,0>:ub   0x79:uw              {I@2}
        sel (16|M0)   (ge)f0.0   r107.0<2>:ub  r69.0<4;1,0>:ub   0x79:uw              {I@2}
        mov (16|M0)              r98.0<1>:d    r106.0<2;1,0>:ub                 {I@2}
        mov (16|M0)              r96.0<1>:d    r107.0<2;1,0>:ub                 {I@2}
        shl (16|M0)              r98.0<1>:d    r98.0<1;1,0>:d    23:w               {Compacted,I@2}
        shl (16|M0)              r96.0<1>:d    r96.0<1;1,0>:d    23:w               {Compacted,I@2}
        add (16|M0)              r100.0<1>:d   r98.0<1;1,0>:d    -25165824:d               {I@2}
        add (16|M0)              r65.0<1>:d    r96.0<1;1,0>:d    -25165824:d               {I@2}
        add (16|M0)              r98.0<1>:d    -r98.0<1;1,0>:d   -2139095040:d              
        add (16|M0)              r96.0<1>:d    -r96.0<1;1,0>:d   -2139095040:d              
        mul (16|M0)              acc0.0<1>:f   r82.0<1;1,0>:f    r98.0<1;1,0>:f   {Compacted,I@2}
        mul (16|M0)              acc2.0<1>:f   r80.0<1;1,0>:f    r96.0<1;1,0>:f   {Compacted,I@1}
        rnde (16|M0)             acc0.0<1>:f   acc0.0<1;1,0>:f                 
        rnde (16|M0)             acc2.0<1>:f   acc2.0<1;1,0>:f                 
        cmp (16|M0)   (lt)f1.1   null<1>:f     r118.0<1;1,0>:f   0xB3000000:f              
        cmp (16|M0)   (lt)f1.0   null<1>:f     r116.0<1;1,0>:f   0xB3000000:f               {Compacted}
        mul (16|M0)              acc0.0<1>:f   acc0.0<1;1,0>:f   r100.0<1;1,0>:f  {Compacted}
        mul (16|M0)              acc2.0<1>:f   acc2.0<1;1,0>:f   r65.0<1;1,0>:f   {Compacted}
        mov (16|M0)              r94.0<1>:f    (abs)acc0.0<1;1,0>:f             {Compacted}
        mov (16|M0)              r67.0<1>:f    (abs)acc2.0<1;1,0>:f             {Compacted}
(f1.1)  or (16|M0)               r94.0<1>:d    r94.0<1;1,0>:d    -2147483648:d               {F@2}
(f1.0)  or (16|M0)               r67.0<1>:d    r67.0<1;1,0>:d    -2147483648:d               {F@1}
        mov (8|M0)               r19.0<1>:hf   r94.0<1;1,0>:f                   {I@2}
        mov (8|M0)               r19.8<1>:hf   r95.0<1;1,0>:f                  
        mov (8|M0)               r20.0<1>:hf   r67.0<1;1,0>:f                   {I@1}
        mov (8|M0)               r20.8<1>:hf   r68.0<1;1,0>:f                  
L14112:
        shr (1|M0)               r30.3<1>:ud   r6.7<0;1,0>:ud    0x2:uw             
        shl (1|M0)               r30.2<1>:ud   r6.7<0;1,0>:ud    0x4:uw             
        shl (1|M0)               r6.12<1>:w    r6.14<0;1,0>:w    1:w              
        cmp (1|M0)    (lt)f0.0   null<1>:ud    r6.7<0;1,0>:ud    0x1E:uw             
        and (1|M0)               r30.3<1>:ud   r30.3<0;1,0>:ud   0x4:uw              {I@4}
        and (1|M0)               r30.2<1>:ud   r30.2<0;1,0>:ud   0xE0:uw              {I@4}
        add (1|M0)               a0.0<1>:uw    r6.12<0;1,0>:uw   0x260:uw              {A@1}
        add (1|M0)               r30.3<1>:ud   r30.3<0;1,0>:ud   r102.2<0;1,0>:ud {I@3}
        bfn.0xFE (1|M0)          r30.2<1>:ud   0x2000:uw               r6.4<0;0>:ud      r30.2<0>:ud      {I@3} // s0|s1|s2
(W)     and (1|M0)               f1.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
        shl (1|M0)               r30.3<1>:ud   r30.3<0;1,0>:ud   0x9:uw              {I@3}
        sync.nop                             null                             {Compacted,$12.src}
        mov (2|M0)               r7.0<1>:uw    r[a0.0]<1;1,0>:uw                {A@1}
        add (1|M0)               r8.0<1>:ud    r30.2<0;1,0>:ud   r30.3<0;1,0>:ud  {A@1}
        add (1|M0)               r30.2<1>:ud   r6.7<0;1,0>:ud    0x2:uw             
        send.slm (1|M0)          null     r8      r7:1    0x0            0x02000504           {A@2,$12} // wr:1+1, rd:0; store.slm.d32.a32
(f1.1.any16h) goto (16|M0)                   L14440                  L14440                
L14376:
        cmp (1|M0)    (eq)f1.1   null<1>:d     r2.4<0;1,0>:d     103:w              
(W)     and (1|M0)               f1.0<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(f1.0.any16h) goto (16|M0)                   L14440                  L34576                
L14424:
        goto (16|M0)                         L14440                  L14488                
L14440:
        join (16|M0)                         L14488                                
L14456:
        mov (1|M0)               r6.7<1>:d     r30.2<0;1,0>:d                   {I@7}
        goto.b (16|M0)                       L14488                  L14112                
L14488:
        join (16|M0)                         L34576                                
L14504:
        or (1|M0)                r7.0<1>:d     r103.0<0;1,0>:d   r6.5<0;1,0>:d    {Compacted,$12.src}
        mov (1|M0)               r6.5<1>:d     0:w                              
        send.slm (1|M0)          r47      r7      null:0  0x0            0x0240D700           {A@2,$13} // wr:1+0, rd:4; load.slm.d64x16t.a32
        sel (16|M0)   (lt)f0.0   r71.0<1>:f    (abs)r47.0<1;1,0>:f  448.0:f            {Compacted,$13.dst}
        sel (16|M0)   (lt)f0.0   r23.0<1>:f    (abs)r49.0<1;1,0>:f  448.0:f            {Compacted}
        sync.nop                             null                             {Compacted,$8.src}
        shr (16|M0)              r17.0<1>:ud   r71.0<1;1,0>:ud   0x17:uw              {F@2}
        shr (16|M0)              r15.0<1>:ud   r23.0<1;1,0>:ud   0x17:uw              {F@1}
        sel (16|M0)   (ge)f0.0   r81.0<2>:ub   r17.0<4;1,0>:ub   0x79:uw              {I@2}
        sel (16|M0)   (ge)f0.0   r82.0<2>:ub   r15.0<4;1,0>:ub   0x79:uw              {I@2}
        mov (16|M0)              r77.0<1>:d    r81.0<2;1,0>:ub                  {I@2}
        mov (16|M0)              r75.0<1>:d    r82.0<2;1,0>:ub                  {I@2}
        shl (16|M0)              r77.0<1>:d    r77.0<1;1,0>:d    23:w               {Compacted,I@2}
        shl (16|M0)              r75.0<1>:d    r75.0<1;1,0>:d    23:w               {Compacted,I@2}
        add (16|M0)              r79.0<1>:d    r77.0<1;1,0>:d    -25165824:d               {I@2}
        add (16|M0)              r17.0<1>:d    r75.0<1;1,0>:d    -25165824:d               {I@2}
        add (16|M0)              r77.0<1>:d    -r77.0<1;1,0>:d   -2139095040:d              
        add (16|M0)              r75.0<1>:d    -r75.0<1;1,0>:d   -2139095040:d              
        mul (16|M0)              acc0.0<1>:f   r71.0<1;1,0>:f    r77.0<1;1,0>:f   {Compacted,I@2}
        mul (16|M0)              acc2.0<1>:f   r23.0<1;1,0>:f    r75.0<1;1,0>:f   {Compacted,I@1}
        rnde (16|M0)             acc0.0<1>:f   acc0.0<1;1,0>:f                 
        rnde (16|M0)             acc2.0<1>:f   acc2.0<1;1,0>:f                 
        cmp (16|M0)   (lt)f1.0   null<1>:f     r47.0<1;1,0>:f    0.0:f               {Compacted}
        cmp (16|M0)   (lt)f0.0   null<1>:f     r49.0<1;1,0>:f    0.0:f               {Compacted}
        mul (16|M0)              acc0.0<1>:f   acc0.0<1;1,0>:f   r79.0<1;1,0>:f   {Compacted}
        mul (16|M0)              acc2.0<1>:f   acc2.0<1;1,0>:f   r17.0<1;1,0>:f   {Compacted}
        mov (16|M0)              r73.0<1>:f    (abs)acc0.0<1;1,0>:f             {Compacted}
        mov (16|M0)              r13.0<1>:f    (abs)acc2.0<1;1,0>:f             {Compacted}
(f1.0)  or (16|M0)               r73.0<1>:d    r73.0<1;1,0>:d    -2147483648:d               {F@2}
(f0.0)  or (16|M0)               r13.0<1>:d    r13.0<1;1,0>:d    -2147483648:d               {F@1}
        mov (8|M0)               r11.0<1>:hf   r73.0<1;1,0>:f                   {I@2}
        mov (8|M0)               r11.8<1>:hf   r74.0<1;1,0>:f                  
        mov (8|M0)               r12.0<1>:hf   r13.0<1;1,0>:f                   {I@1}
        mov (8|M0)               r12.8<1>:hf   r14.0<1;1,0>:f                  
L14936:
        shr (1|M0)               r8.0<1>:ud    r6.5<0;1,0>:ud    0x4:uw              {$14.src}
        shl (1|M0)               r6.4<1>:ud    r6.5<0;1,0>:ud    0x4:uw             
        bfn.0xEA (1|M0)          r8.0<1>:ud    r8.0<0;0>:ud      r102.1<0;0>:ud    0x1FFE:uw              {I@2} // s0|s1&s2
        and (1|M0)               r6.4<1>:ud    r6.4<0;1,0>:ud    0x80:uw              {I@2}
        shl (1|M0)               r8.0<1>:ud    r8.0<0;1,0>:ud    0x8:uw              {I@2}
        bfn.0xFE (1|M0)          r8.0<1>:ud    r6.2<0;0>:ud      r8.0<0;0>:ud      r6.4<0>:ud       {I@1} // s0|s1|s2
        shl (1|M0)               r6.4<1>:ud    r6.5<0;1,0>:ud    0x1:uw             
        and (1|M0)               r6.4<1>:ud    r6.4<0;1,0>:ud    0xE:uw              {I@1}
        bfn.0xFE (1|M0)          r8.0<1>:ud    r6.3<0;0>:ud      r8.0<0;0>:ud      r6.4<0>:ud       {I@1} // s0|s1|s2
        shl (1|M0)               r6.8<1>:w     r6.10<0;1,0>:w    1:w              
        add (1|M0)               r6.5<1>:ud    r6.5<0;1,0>:ud    0x1:uw             
        add (1|M0)               a0.0<1>:uw    r6.8<0;1,0>:uw    0x160:uw              {A@1}
        cmp (1|M0)    (eq)f1.1   null<1>:d     r6.5<0;1,0>:d     32:w               {I@2}
        shl (1|M0)               r8.0<1>:ud    r8.0<0;1,0>:ud    0x1:uw             
        add (1|M0)               r8.0<1>:ud    r8.0<0;1,0>:ud    0x3000:uw              {I@1}
(W)     and (1|M0)               f0.0<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
        mov (1|M0)               r7.0<1>:d     r[a0.0]<0;1,0>:uw                {A@1}
        send.slm (1|M0)          null     r8      r7:1    0x0            0x02000B04           {A@1,$14} // wr:1+1, rd:0; store.slm.d16u32.a32
(~f0.0.any16h) goto.b (16|M0)                L15240                  L14936                
L15240:
        join (16|M0)                         L34576                                
L15256:
        cmp (1|M0)    (eq)f0.0   null<1>:d     r4.3<0;1,0>:d     0:w              
(f0.0)  cmp (1|M0)    (eq)f0.0   null<1>:d     r4.2<0;1,0>:d     0:w              
(W)     and (1|M0)               f1.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
(f1.1.any16h) goto (16|M0)                   L15408                  L15408                
L15320:
(W)     send.slm (1|M0)          r77      r0      null:0  0x0            0x0210001F           {$15} // wr:1+0, rd:1; fence.slm.none.group
(W)     mov (1|M0)               r76.2<1>:f    0.0:f                               {Compacted}
(W)     mov (2|M0)               r76.10<1>:ub  r0.11<0;1,0>:ub                  {F@1}
(W)     mov (8|M0)               null<1>:ud    r77.0<1;1,0>:ud                  {$15.dst}
(W)     send.gtwy (1|M0)         null     r76     null:0  0x0            0x02000004           {A@2,$0} // wr:1+0, rd:0; signal barrier
(W)     sync.bar                             null                            
L15408:
        join (16|M0)                         L34576                                
L15424:
        cmp (1|M0)    (lt)f1.0   null<1>:d     r2.4<0;1,0>:d     11:w              
(W)     and (1|M0)               f1.0<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
(f1.0.any16h) goto (16|M0)                   L16992                  L16992                
L15472:
        cmp (1|M0)    (eq)f1.1   null<1>:d     r2.4<0;1,0>:d     11:w              
(W)     and (1|M0)               f1.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(f1.1.any16h) goto (16|M0)                   L16272                  L16272                
L15520:
        cmp (1|M0)    (eq)f1.0   null<1>:d     r2.4<0;1,0>:d     12:w              
(W)     and (1|M0)               f1.0<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
(~f1.0.any16h) goto (16|M0)                  L16272                  L17056                
L15568:
(W)     and (1|M0)               f1.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
(f1.1.any16h) goto (16|M0)                   L16272                  L34576                
L15600:
        shl (1|M0)               r3.1<1>:d     r3.6<0;1,0>:d     12:w              
        shr (1|M0)               r3.0<1>:ud    r3.5<0;1,0>:ud    0x14:uw             
        shl (1|M0)               r4.0<1>:d     r3.5<0;1,0>:d     12:w               {Compacted}
        or (1|M0)                r4.1<1>:d     r3.1<0;1,0>:d     r3.0<0;1,0>:d    {Compacted,I@2}
        shr (1|M0)               r2.0<1>:ud    r4.0<0;1,0>:ud    0x1F:uw              {I@2}
        shl (1|M0)               r2.1<1>:d     r4.0<0;1,0>:d     1:w               {Compacted}
        shl (1|M0)               r2.3<1>:d     r4.1<0;1,0>:d     1:w               {I@3}
        mov (1|M0)               r2.5<2>:f     0.0:f                              
        or (1|M0)                r2.2<1>:d     r2.3<0;1,0>:d     r2.0<0;1,0>:d    {I@1}
        addc (1|M0)              r2.0<1>:ud    r4.2<0;1,0>:ud    r2.1<0;1,0>:ud   {AccWrEn}
        shl (1|M0)               r2.3<1>:d     r1.6<0;1,0>:d     1:w              
        mov (1|M0)               r4.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        shr (1|M0)               r2.1<1>:ud    r1.6<0;1,0>:ud    0x1F:uw             
        addc (1|M0)              r3.0<1>:ud    r2.0<0;1,0>:ud    r2.3<0;1,0>:ud   {AccWrEn,I@3}
        add3 (1|M0)              r2.6<1>:d     r4.0<0;0>:d       r4.3<0;0>:d       r2.2<0>:d        {I@3}
        shl (1|M0)               r2.2<1>:d     r1.7<0;1,0>:d     1:w              
        mov (1|M0)               r2.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        or (1|M0)                r2.4<1>:d     r2.2<0;1,0>:d     r2.1<0;1,0>:d    {I@2}
        mov (1|M0)               r2.1<1>:d     r3.0<0;1,0>:d                   
        add3 (1|M0)              r2.2<1>:d     r2.0<0;0>:d       r2.6<0;0>:d       r2.4<0>:d        {I@2}
        mov (1|M0)               r2.4<2>:f     0.0:f                               {I@1}
L15896:
        addc (1|M0)              r3.0<1>:ud    r2.4<0;1,0>:ud    r1.6<0;1,0>:ud   {AccWrEn,F@1}
        cmp (1|M0)    (lt)f1.1   null<1>:ud    r2.4<0;1,0>:ud    0x7C0:uw             
        mov (1|M0)               r2.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        shl (1|M0)               r2.6<1>:d     r2.4<0;1,0>:d     1:w              
        add3 (1|M0)              r2.7<1>:d     r2.0<0;0>:d       r2.5<0;0>:d       r1.7<0>:d        {I@2}
        shl (1|M0)               r2.0<1>:d     r3.0<0;1,0>:d     1:w               {Compacted}
        shl (1|M0)               r3.1<1>:d     r2.5<0;1,0>:d     1:w              
        add (1|M0)               r2.0<1>:d     r2.0<0;1,0>:d     12288:w               {I@2}
        addc (1|M0)              r4.0<1>:ud    r2.1<0;1,0>:ud    r2.6<0;1,0>:ud   {AccWrEn}
        send.slm (1|M0)          r22      r2      null:0  0x0            0x0210B700           {A@2,$1} // wr:1+0, rd:1; load.slm.d64x4t.a32
(f1.1)  cmp (1|M0)    (eq)f1.1   null<1>:d     r2.5<0;1,0>:d     0:w              
        shr (1|M0)               r3.0<1>:ud    r2.4<0;1,0>:ud    0x1F:uw             
        sync.nop                             null                             {Compacted,$1.src}
        or (1|M0)                r2.7<1>:d     r3.1<0;1,0>:d     r3.0<0;1,0>:d    {I@1}
        mov (1|M0)               r3.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
(W)     and (1|M0)               f1.0<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
        add3 (1|M0)              r4.1<1>:d     r3.0<0;0>:d       r2.2<0;0>:d       r2.7<0>:d        {I@2}
        mov (1|M0)               r2.0<1>:d     r22.0<0;1,0>:uw                  {$1.dst}
        addc (1|M0)              r3.0<1>:ud    r2.4<0;1,0>:ud    0x40:ud              {AccWrEn}
        send.ugm (1|M0)          null     r4      r2:1    0x0            0x04000B84           {A@2,$2} // wr:2+1, rd:0; store.ugm.d16u32.a64
        mov (1|M0)               r2.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$2.src}
        mov (1|M0)               r2.6<1>:d     r3.0<0;1,0>:d                    {I@2}
        add3 (1|M0)              r2.7<1>:d     r2.0<0;0>:d       r2.5<0;0>:d       0:w               {I@2}
(~f1.0.any16h) goto (16|M0)                  L16272                  L34576                
L16240:
(W)     mov (2|M0)               r2.4<1>:ud    r2.6<1;1,0>:ud                   {I@2}
        goto.b (16|M0)                       L16272                  L15896                
L16272:
        join (16|M0)                         L16992                                
L16288:
(W)     and (1|M0)               f0.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
(f0.1.any16h) goto (16|M0)                   L16992                  L34576                
L16320:
        shl (1|M0)               r3.1<1>:d     r3.6<0;1,0>:d     12:w              
        shr (1|M0)               r3.0<1>:ud    r3.5<0;1,0>:ud    0x14:uw             
        shl (1|M0)               r4.0<1>:d     r3.5<0;1,0>:d     12:w               {Compacted}
        or (1|M0)                r4.1<1>:d     r3.1<0;1,0>:d     r3.0<0;1,0>:d    {Compacted,I@2}
        shr (1|M0)               r2.0<1>:ud    r4.0<0;1,0>:ud    0x1F:uw              {I@2}
        shl (1|M0)               r2.1<1>:d     r4.0<0;1,0>:d     1:w               {Compacted}
        shl (1|M0)               r2.3<1>:d     r4.1<0;1,0>:d     1:w               {I@3}
        mov (1|M0)               r2.5<2>:f     0.0:f                              
        or (1|M0)                r2.2<1>:d     r2.3<0;1,0>:d     r2.0<0;1,0>:d    {I@1}
        addc (1|M0)              r2.0<1>:ud    r4.2<0;1,0>:ud    r2.1<0;1,0>:ud   {AccWrEn}
        shl (1|M0)               r2.3<1>:d     r1.6<0;1,0>:d     1:w              
        mov (1|M0)               r4.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        shr (1|M0)               r2.1<1>:ud    r1.6<0;1,0>:ud    0x1F:uw             
        addc (1|M0)              r3.0<1>:ud    r2.0<0;1,0>:ud    r2.3<0;1,0>:ud   {AccWrEn,I@3}
        add3 (1|M0)              r2.6<1>:d     r4.0<0;0>:d       r4.3<0;0>:d       r2.2<0>:d        {I@3}
        shl (1|M0)               r2.2<1>:d     r1.7<0;1,0>:d     1:w              
        mov (1|M0)               r2.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        or (1|M0)                r2.4<1>:d     r2.2<0;1,0>:d     r2.1<0;1,0>:d    {I@2}
        mov (1|M0)               r2.1<1>:d     r3.0<0;1,0>:d                   
        add3 (1|M0)              r2.2<1>:d     r2.0<0;0>:d       r2.6<0;0>:d       r2.4<0>:d        {I@2}
        mov (1|M0)               r2.4<2>:f     0.0:f                               {I@1}
L16616:
        addc (1|M0)              r3.0<1>:ud    r2.4<0;1,0>:ud    r1.6<0;1,0>:ud   {AccWrEn,F@1}
        cmp (1|M0)    (lt)f1.0   null<1>:ud    r2.4<0;1,0>:ud    0x7C0:uw             
        mov (1|M0)               r2.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        shl (1|M0)               r2.6<1>:d     r2.4<0;1,0>:d     1:w              
        add3 (1|M0)              r2.7<1>:d     r2.0<0;0>:d       r2.5<0;0>:d       r1.7<0>:d        {I@2}
        shl (1|M0)               r2.0<1>:d     r3.0<0;1,0>:d     1:w               {Compacted}
        shl (1|M0)               r3.1<1>:d     r2.5<0;1,0>:d     1:w              
        add (1|M0)               r2.0<1>:d     r2.0<0;1,0>:d     8192:w               {I@2}
        addc (1|M0)              r4.0<1>:ud    r2.1<0;1,0>:ud    r2.6<0;1,0>:ud   {AccWrEn}
        send.slm (1|M0)          r21      r2      null:0  0x0            0x0210B700           {A@2,$3} // wr:1+0, rd:1; load.slm.d64x4t.a32
(f1.0)  cmp (1|M0)    (eq)f1.0   null<1>:d     r2.5<0;1,0>:d     0:w              
        shr (1|M0)               r3.0<1>:ud    r2.4<0;1,0>:ud    0x1F:uw             
        sync.nop                             null                             {Compacted,$3.src}
        or (1|M0)                r2.7<1>:d     r3.1<0;1,0>:d     r3.0<0;1,0>:d    {I@1}
        mov (1|M0)               r3.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
(W)     and (1|M0)               f0.0<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
        add3 (1|M0)              r4.1<1>:d     r3.0<0;0>:d       r2.2<0;0>:d       r2.7<0>:d        {I@2}
        mov (1|M0)               r2.0<1>:d     r21.0<0;1,0>:uw                  {$3.dst}
        addc (1|M0)              r3.0<1>:ud    r2.4<0;1,0>:ud    0x40:ud              {AccWrEn}
        send.ugm (1|M0)          null     r4      r2:1    0x0            0x04000B84           {A@2,$4} // wr:2+1, rd:0; store.ugm.d16u32.a64
        mov (1|M0)               r2.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$4.src}
        mov (1|M0)               r2.6<1>:d     r3.0<0;1,0>:d                    {I@2}
        add3 (1|M0)              r2.7<1>:d     r2.0<0;0>:d       r2.5<0;0>:d       0:w               {I@2}
(~f0.0.any16h) goto (16|M0)                  L16992                  L34576                
L16960:
(W)     mov (2|M0)               r2.4<1>:ud    r2.6<1;1,0>:ud                   {I@2}
        goto.b (16|M0)                       L16992                  L16616                
L16992:
        join (16|M0)                         L17056                                
L17008:
        cmp (1|M0)    (eq)f1.1   null<1>:d     r2.4<0;1,0>:d     10:w               {I@3}
(W)     and (1|M0)               f1.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(f1.1.any16h) goto (16|M0)                   L17056                  L33856                
L17056:
        join (16|M0)                         L33856                                
L17072:
(W)     send.slm (1|M0)          r75      r0      null:0  0x0            0x0210001F           {$5} // wr:1+0, rd:1; fence.slm.none.group
(W)     mov (1|M0)               r74.2<1>:f    0.0:f                               {Compacted}
(W)     mov (2|M0)               r74.10<1>:ub  r0.11<0;1,0>:ub                  {F@1}
(W)     mov (8|M0)               null<1>:ud    r75.0<1;1,0>:ud                  {$5.dst}
(W)     send.gtwy (1|M0)         null     r74     null:0  0x0            0x02000004           {A@2,$6} // wr:1+0, rd:0; signal barrier
(W)     sync.bar                             null                            
        add (1|M0)               r7.0<1>:ud    r102.0<0;1,0>:ud  0x1000:uw              {$14.src}
        mov (16|M0)              r94.0<1>:f    0.0:f                               {Compacted}
        sync.nop                             null                             {Compacted,I@1}
        send.slm (1|M0)          r45      r7      null:0  0x0            0x0280E700           {$7} // wr:1+0, rd:8; load.slm.d64x32t.a32
        add (1|M0)               r7.0<1>:ud    r102.0<0;1,0>:ud  0x1100:uw              {$7.src}
        mov (16|M0)              r96.0<1>:f    0.0:f                               {Compacted}
        sync.nop                             null                             {Compacted,I@1}
        send.slm (1|M0)          r53      r7      null:0  0x0            0x0280E700           {$8} // wr:1+0, rd:8; load.slm.d64x32t.a32
        add (1|M0)               r7.0<1>:ud    r102.0<0;1,0>:ud  0x1200:uw              {$8.src}
        mov (16|M0)              r98.0<1>:f    0.0:f                               {Compacted}
        sync.nop                             null                             {Compacted,I@1}
        sync.allrd                           ($0,$6)                
        send.slm (1|M0)          r69      r7      null:0  0x0            0x0280E700           {$10} // wr:1+0, rd:8; load.slm.d64x32t.a32
        add (1|M0)               r7.0<1>:ud    r102.0<0;1,0>:ud  0x1300:uw              {$10.src}
        mov (16|M0)              r100.0<1>:f   0.0:f                               {Compacted}
        sync.nop                             null                             {Compacted,I@1}
        send.slm (1|M0)          r77      r7      null:0  0x0            0x0280E700           {$11} // wr:1+0, rd:8; load.slm.d64x32t.a32
        mov (1|M0)               r6.2<1>:d     0:w                              
L17384:
        shl (1|M0)               r6.3<1>:d     r6.2<0;1,0>:d     9:w               {I@1}
        sync.allrd                           ($11,$13)                
        or (1|M0)                r7.0<1>:d     r6.3<0;1,0>:d     8192:w               {I@1}
        send.slm (1|M0)          r22      r7      null:0  0x0            0x0280E700           {A@1,$15} // wr:1+0, rd:8; load.slm.d64x32t.a32
        or (1|M0)                r7.0<1>:d     r6.3<0;1,0>:d     8448:w               {$15.src}
        send.slm (1|M0)          r61      r7      null:0  0x0            0x0280E700           {A@1,$1} // wr:1+0, rd:8; load.slm.d64x32t.a32
        sync.nop                             null                             {Compacted,A@1}
        sync.allwr                           ($7,$8,$15)                
        sync.nop                             null                             {Compacted,$1.src}
        dpas.8x8 (8|M0)          r7:f          null:f            r7:hf             r7.0:hf          {Atomic}
        dpas.8x8 (8|M0)          r7:f          r94:f             r22:hf            r45.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r85:f         r94:f             r22:hf            r53.0:hf         {$7}
        or (1|M0)                r23.0<1>:d    r6.3<0;1,0>:d     10240:w               {$7.src}
        send.slm (1|M0)          r15      r23     null:0  0x0            0x0280E700           {A@1,$2} // wr:1+0, rd:8; load.slm.d64x32t.a32
        or (1|M0)                r23.0<1>:d    r6.3<0;1,0>:d     10496:w               {$2.src}
        sync.nop                             null                             {Compacted,$1.dst}
        dpas.8x8 (8|M0)          r106:f        null:f            r106:hf           r106.0:hf        {Atomic}
        dpas.8x8 (8|M0)          r106:f        r94:f             r61:hf            r45.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r114:f        r94:f             r61:hf            r53.0:hf         {$1}
        sync.nop                             null                             {Compacted,$1.src}
        send.slm (1|M0)          r61      r23     null:0  0x0            0x0280E700           {A@1,$3} // wr:1+0, rd:8; load.slm.d64x32t.a32
        shl (1|M0)               r6.3<1>:d     r6.2<0;1,0>:d     6:w              
        add (1|M0)               r6.2<1>:d     r6.2<0;1,0>:d     1:w              
        sync.allwr                           ($2,$7,$10,$11)                
        dpas.8x8 (8|M0)          r7:f          null:f            r7:hf             r7.0:hf          {Atomic}
        dpas.8x8 (8|M0)          r7:f          r7:f              r15:hf            r69.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r85:f         r85:f             r15:hf            r77.0:hf         {$10}
        sync.nop                             null                             {Compacted,$10.src}
        or (1|M0)                r19.0<1>:d    r6.3<0;1,0>:d     r104.0<0;1,0>:d  {Compacted,I@2}
        cmp (1|M0)    (eq)f1.0   null<1>:d     r6.2<0;1,0>:d     4:w               {I@2}
        sync.allwr                           ($1,$3)                
(W)     sync.nop                             null                            
(W)     sync.nop                             null                            
        dpas.8x8 (8|M0)          r106:f        null:f            r106:hf           r106.0:hf        {Atomic}
        dpas.8x8 (8|M0)          r106:f        r106:f            r61:hf            r69.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r114:f        r114:f            r61:hf            r77.0:hf         {$1}
        or (1|M0)                r15.0<1>:ud   r19.0<0;1,0>:ud   0x800:uw              {I@2}
(W)     and (1|M0)               f1.0<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
        mov (8|M0)               r122.0<1>:f   r7.0<1;1,0>:f                    {Compacted,$10.dst}
        mov (8|M0)               r43.0<1>:f    r85.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r41.0<1>:f    r8.0<1;1,0>:f                    {Compacted}
        mov (8|M0)               r17.0<1>:f    r86.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r123.0<1>:f   r106.0<1;1,0>:f                  {Compacted,$1.dst}
        mov (8|M0)               r44.0<1>:f    r114.0<1;1,0>:f                  {Compacted}
        send.slm (1|M0)          null     r19     r122:2  0x0            0x0200C704           {A@2,$4} // wr:1+2, rd:0; store.slm.d64x8t.a32
        send.slm (1|M0)          null     r15     r43:2   0x0            0x0200C704           {A@1,$5} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r42.0<1>:f    r107.0<1;1,0>:f                  {Compacted}
        or (1|M0)                r15.0<1>:ud   r19.0<0;1,0>:ud   0x100:uw              {$5.src}
        mov (8|M0)               r18.0<1>:f    r115.0<1;1,0>:f                  {Compacted}
        send.slm (1|M0)          null     r15     r41:2   0x0            0x0200C704           {A@1,$9} // wr:1+2, rd:0; store.slm.d64x8t.a32
        or (1|M0)                r15.0<1>:ud   r19.0<0;1,0>:ud   0x900:uw              {$9.src}
        mov (8|M0)               r39.0<1>:f    r9.0<1;1,0>:f                    {Compacted}
        send.slm (1|M0)          null     r15     r17:2   0x0            0x0200C704           {A@1,$14} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r40.0<1>:f    r108.0<1;1,0>:f                  {Compacted}
        or (1|M0)                r17.0<1>:ud   r19.0<0;1,0>:ud   0x200:uw              {$14.src}
        mov (8|M0)               r16.0<1>:f    r116.0<1;1,0>:f                  {Compacted}
        send.slm (1|M0)          null     r17     r39:2   0x0            0x0200C704           {A@1,$6} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r15.0<1>:f    r87.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r17.0<1>:ud   r19.0<0;1,0>:ud   0xA00:uw              {$6.src}
        mov (8|M0)               r37.0<1>:f    r10.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r17     r15:2   0x0            0x0200C704           {A@1,$7} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r38.0<1>:f    r109.0<1;1,0>:f                  {Compacted}
        or (1|M0)                r15.0<1>:ud   r19.0<0;1,0>:ud   0x300:uw              {$7.src}
        mov (8|M0)               r126.0<1>:f   r88.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r15     r37:2   0x0            0x0200C704           {A@1,$8} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r127.0<1>:f   r117.0<1;1,0>:f                  {Compacted}
        or (1|M0)                r15.0<1>:ud   r19.0<0;1,0>:ud   0xB00:uw              {$8.src}
        mov (8|M0)               r27.0<1>:f    r11.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r15     r126:2  0x0            0x0200C704           {A@1,$10} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r28.0<1>:f    r110.0<1;1,0>:f                  {Compacted}
        or (1|M0)                r15.0<1>:ud   r19.0<0;1,0>:ud   0x400:uw              {$10.src}
        mov (8|M0)               r124.0<1>:f   r89.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r15     r27:2   0x0            0x0200C704           {A@1,$11} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r125.0<1>:f   r118.0<1;1,0>:f                  {Compacted}
        or (1|M0)                r15.0<1>:ud   r19.0<0;1,0>:ud   0xC00:uw              {$11.src}
        mov (8|M0)               r25.0<1>:f    r12.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r15     r124:2  0x0            0x0200C704           {A@1,$15} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r26.0<1>:f    r111.0<1;1,0>:f                  {Compacted}
        or (1|M0)                r15.0<1>:ud   r19.0<0;1,0>:ud   0x500:uw              {$15.src}
        mov (8|M0)               r122.0<1>:f   r90.0<1;1,0>:f                   {Compacted,$4.src}
        send.slm (1|M0)          null     r15     r25:2   0x0            0x0200C704           {A@1,$1} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r123.0<1>:f   r119.0<1;1,0>:f                  {Compacted}
        or (1|M0)                r15.0<1>:ud   r19.0<0;1,0>:ud   0xD00:uw              {$1.src}
        mov (8|M0)               r23.0<1>:f    r13.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r15     r122:2  0x0            0x0200C704           {A@1,$2} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r24.0<1>:f    r112.0<1;1,0>:f                  {Compacted}
        or (1|M0)                r15.0<1>:ud   r19.0<0;1,0>:ud   0x600:uw              {$2.src}
        mov (8|M0)               r67.0<1>:f    r91.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r15     r23:2   0x0            0x0200C704           {A@1,$3} // wr:1+2, rd:0; store.slm.d64x8t.a32
        or (1|M0)                r7.0<1>:ud    r19.0<0;1,0>:ud   0x700:uw             
        mov (8|M0)               r68.0<1>:f    r120.0<1;1,0>:f                  {Compacted}
        mov (8|M0)               r122.0<1>:f   r14.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r123.0<1>:f   r113.0<1;1,0>:f                  {Compacted}
        or (1|M0)                r15.0<1>:ud   r19.0<0;1,0>:ud   0xE00:uw              {$3.src}
        mov (8|M0)               r85.0<1>:f    r92.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r15     r67:2   0x0            0x0200C704           {A@1,$12} // wr:1+2, rd:0; store.slm.d64x8t.a32
        send.slm (1|M0)          null     r7      r122:2  0x0            0x0200C704           {A@2,$5} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r86.0<1>:f    r121.0<1;1,0>:f                  {Compacted}
        or (1|M0)                r7.0<1>:ud    r19.0<0;1,0>:ud   0xF00:uw              {$5.src}
        send.slm (1|M0)          null     r7      r85:2   0x0            0x0200C704           {A@1,$13} // wr:1+2, rd:0; store.slm.d64x8t.a32
(~f1.0.any16h) goto.b (16|M0)                L18696                  L17384                
L18696:
        join (16|M0)                         L33856                                
L18712:
        sync.nop                             null                             {Compacted,$12.src}
(W)     send.slm (1|M0)          r67      r0      null:0  0x0            0x0210001F           {$6} // wr:1+0, rd:1; fence.slm.none.group
(W)     mov (1|M0)               r66.2<1>:f    0.0:f                               {Compacted}
(W)     mov (2|M0)               r66.10<1>:ub  r0.11<0;1,0>:ub                  {F@1}
(W)     mov (8|M0)               null<1>:ud    r67.0<1;1,0>:ud                  {$6.dst}
(W)     send.gtwy (1|M0)         null     r66     null:0  0x0            0x02000004           {A@2,$7} // wr:1+0, rd:0; signal barrier
(W)     sync.bar                             null                            
        cmp (1|M0)    (eq)f1.1   null<1>:d     r2.4<0;1,0>:d     5:w              
(W)     and (1|M0)               f1.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(f1.1.any16h) goto (16|M0)                   L33056                  L33056                
L18856:
        shl (1|M0)               r1.5<1>:d     r1.5<0;1,0>:d     8:w              
        shl (1|M0)               r6.3<1>:d     r1.7<0;1,0>:d     6:w              
        sync.nop                             null                             {Compacted,$13.src}
        or (1|M0)                r7.0<1>:d     r104.0<0;1,0>:d   r1.5<0;1,0>:d    {Compacted,I@2}
        shr (1|M0)               r6.2<1>:ud    r1.6<0;1,0>:ud    0x1A:uw             
        send.slm (1|M0)          r43      r7      null:0  0x0            0x0240D700           {A@2,$8} // wr:1+0, rd:4; load.slm.d64x16t.a32
        bfn.0xFE (1|M0)          r7.0<1>:ud    0x80:uw               r104.0<0;0>:ud    r1.5<0>:ud       {$8.src} // s0|s1|s2
        shl (1|M0)               r1.5<1>:d     r1.6<0;1,0>:d     6:w              
        or (1|M0)                r1.6<1>:d     r6.3<0;1,0>:d     r6.2<0;1,0>:d    {I@3}
        shl (1|M0)               r6.2<1>:d     r1.5<0;1,0>:d     2:w               {I@2}
        send.slm (1|M0)          r39      r7      null:0  0x0            0x0240D700           {$10} // wr:1+0, rd:4; load.slm.d64x16t.a32
        shr (1|M0)               r1.0<1>:ud    r1.5<0;1,0>:ud    0x1E:uw             
        shl (1|M0)               r1.7<1>:d     r1.6<0;1,0>:d     2:w               {I@3}
        sync.nop                             null                             {Compacted,$10.src}
        addc (1|M0)              r7.0<1>:ud    r4.4<0;1,0>:ud    r6.2<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r6.3<1>:d     r1.7<0;1,0>:d     r1.0<0;1,0>:d    {I@2}
        mov (1|M0)               r1.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r8.0<1>:d     r7.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r8.1<1>:d     r1.0<0;0>:d       r4.5<0;0>:d       r6.3<0>:d        {I@2}
        addc (1|M0)              r7.0<1>:ud    r8.0<0;1,0>:ud    0x80:ud              {AccWrEn,I@2}
        send.ugm (1|M0)          r55      r8      null:0  0x0            0x0240E580           {A@2,$11} // wr:1+0, rd:4; load.ugm.d32x32t.a64
        mov (1|M0)               r1.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        add3 (1|M0)              r7.1<1>:d     r1.0<0;0>:d       r8.1<0;0>:d       0:w               {I@1}
        mov (1|M0)               r1.7<1>:ud    0x3D380000:ud                             
        send.ugm (1|M0)          r51      r7      null:0  0x0            0x0240E580           {A@2,$15} // wr:1+0, rd:4; load.ugm.d32x32t.a64
        mov (1|M0)               r1.0<1>:ud    0x3FA68000:ud                             
        bfn.0xFE (1|M0)          r3.7<1>:ud    r102.0<0;0>:ud    r3.7<0;0>:ud      r3.1<0>:ud       // s0|s1|s2
        shl (1|M0)               r3.7<1>:ud    r3.7<0;1,0>:ud    0x1:uw              {I@1}
        sync.nop                             null                             {Compacted,$11.dst}
        add (16|M0)              r15.0<1>:f    r57.0<1;1,0>:f    r45.0<1;1,0>:f   {Compacted,$8.dst}
        add (16|M0)              r63.0<1>:f    r55.0<1;1,0>:f    r43.0<1;1,0>:f   {Compacted}
        mov (8|M0)               r8.0<1>:hf    r15.0<1;1,0>:f                   {F@2}
        mov (8|M0)               r8.8<1>:hf    r16.0<1;1,0>:f                  
        mov (8|M0)               r9.0<1>:hf    r63.0<1;1,0>:f                   {F@3}
        mov (8|M0)               r9.8<1>:hf    r64.0<1;1,0>:f                  
        mov (8|M0)               r112.0<1>:f   r8.0<1;1,0>:hf                   {F@4}
        mov (8|M0)               r113.0<1>:f   r8.8<1;1,0>:hf                   {F@4}
        mov (8|M0)               r114.0<1>:f   r9.0<1;1,0>:hf                   {F@4}
        mov (8|M0)               r115.0<1>:f   r9.8<1;1,0>:hf                   {F@4}
        mad (16|M0)              r112.0<1>:f   r1.0<0;0>:f       r112.0<1;0>:f     r1.7<0>:f        {Compacted,F@3}
        sync.nop                             null                             {Compacted,$15.dst}
        add (16|M0)              r109.0<1>:f   r53.0<1;1,0>:f    r41.0<1;1,0>:f   {Compacted,$10.dst}
        mad (16|M0)              r114.0<1>:f   r1.0<0;0>:f       r114.0<1;0>:f     r1.7<0>:f        {Compacted,F@3}
        mov (8|M0)               r18.0<1>:hf   r112.0<1;1,0>:f                  {F@3}
        mov (8|M0)               r18.8<1>:hf   r113.0<1;1,0>:f                 
        mov (8|M0)               r26.8<1>:hf   r110.0<1;1,0>:f                  {F@4}
        mov (8|M0)               r19.0<1>:hf   r114.0<1;1,0>:f                  {F@4}
        mov (8|M0)               r19.8<1>:hf   r115.0<1;1,0>:f                 
        mov (8|M0)               r110.0<1>:f   r18.0<1;1,0>:hf                  {F@5}
        mov (8|M0)               r111.0<1>:f   r18.8<1;1,0>:hf                  {F@5}
        add (16|M0)              r120.0<1>:f   r51.0<1;1,0>:f    r39.0<1;1,0>:f   {Compacted}
        mov (8|M0)               r7.0<1>:f     r19.0<1;1,0>:hf                  {F@5}
        mov (8|M0)               r8.0<1>:f     r19.8<1;1,0>:hf                  {F@5}
        sel (16|M0)   (ge)f0.0   acc0.0<1>:f   r110.0<1;1,0>:f   1.03125:f               {F@4}
        mov (8|M0)               r27.0<1>:hf   r120.0<1;1,0>:f                  {F@4}
        mov (8|M0)               r27.8<1>:hf   r121.0<1;1,0>:f                 
        sel (16|M0)   (ge)f0.0   acc2.0<1>:f   r7.0<1;1,0>:f     1.03125:f               {F@4}
        sel (16|M0)   (lt)f0.0   r110.0<1>:f   acc0.0<1;1,0>:f   0x3FC8E000:f              
        mov (8|M0)               r26.0<1>:hf   r109.0<1;1,0>:f                 
        mov (8|M0)               r118.0<1>:f   r27.0<1;1,0>:hf                  {F@5}
        mov (8|M0)               r119.0<1>:f   r27.8<1;1,0>:hf                  {F@5}
        sel (16|M0)   (lt)f0.0   r7.0<1>:f     acc2.0<1;1,0>:f   0x3FC8E000:f              
        mov (8|M0)               r67.0<1>:ud   r110.0<2;1,0>:ud                 {F@5}
        mov (8|M0)               r64.0<1>:ud   r110.1<2;1,0>:ud                
        mov (8|M0)               r117.0<1>:f   r26.8<1;1,0>:hf                 
        mov (8|M0)               r116.0<1>:f   r26.0<1;1,0>:hf                  {F@5}
        mad (16|M0)              r118.0<1>:f   r1.0<0;0>:f       r118.0<1;0>:f     r1.7<0>:f        {Compacted,F@4}
        mov (8|M0)               r69.0<1>:ud   r7.0<2;1,0>:ud                   {F@4}
        mov (8|M0)               r66.0<1>:ud   r7.1<2;1,0>:ud                   {$7.src}
        mov (8|M0)               r68.0<2>:hf   r67.0<1;1,0>:f                   {I@4}
        mov (8|M0)               r65.0<2>:hf   r64.0<1;1,0>:f                   {I@3}
        mad (16|M0)              r116.0<1>:f   r1.0<0;0>:f       r116.0<1;0>:f     r1.7<0>:f        {Compacted,F@4}
        mov (8|M0)               r25.0<1>:hf   r118.0<1;1,0>:f                  {F@4}
        mov (8|M0)               r7.0<1>:hf    r66.0<1;1,0>:f                   {I@1}
        mov (8|M0)               r7.8<1>:uw    r65.0<2;1,0>:uw                  {F@4}
        mov (8|M0)               r118.0<1>:hf  r69.0<1;1,0>:f                  
        mov (8|M0)               r118.8<1>:uw  r68.0<2;1,0>:uw                  {F@3}
        mov (8|M0)               r24.0<1>:hf   r116.0<1;1,0>:f                 
        mov (8|M0)               r24.8<1>:hf   r117.0<1;1,0>:f                 
        mov (16|M0)              r21.0<1>:d    r7.0<1;1,0>:uw                   {A@2}
        shl (16|M0)              r116.0<1>:d   r118.0<1;1,0>:uw  5:w               {A@1}
        shl (16|M0)              r21.0<1>:d    r21.0<1;1,0>:d    21:w               {Compacted,I@2}
        add (16|M0)              r116.0<1>:d   r116.0<1;1,0>:d   2146992128:d               {I@2}
        add (16|M0)              r116.0<1>:d   r116.0<1;1,0>:d   r21.0<1;1,0>:d   {Compacted,I@1}
        mov (8|M0)               r114.0<1>:f   r116.0<1;1,0>:hf                 {I@1}
        mov (8|M0)               r115.0<1>:f   r116.8<1;1,0>:hf                
        add (1|M0)               r1.0<1>:f     r114.0<0;1,0>:f   r114.1<0;1,0>:f  {Compacted,F@2}
        mov (8|M0)               r112.0<1>:f   r117.0<1;1,0>:hf                
        add (1|M0)               r1.0<1>:f     r1.0<0;1,0>:f     r114.2<0;1,0>:f  {Compacted,F@2}
        mov (8|M0)               r25.8<1>:hf   r119.0<1;1,0>:f                 
        add (1|M0)               r1.0<1>:f     r1.0<0;1,0>:f     r114.3<0;1,0>:f  {Compacted,F@2}
        mov (8|M0)               r27.0<1>:f    r24.0<1;1,0>:hf                 
        add (1|M0)               r1.0<1>:f     r1.0<0;1,0>:f     r114.4<0;1,0>:f  {Compacted,F@2}
        mov (8|M0)               r28.0<1>:f    r24.8<1;1,0>:hf                 
        add (1|M0)               r1.0<1>:f     r1.0<0;1,0>:f     r114.5<0;1,0>:f  {Compacted,F@2}
        mov (8|M0)               r37.0<1>:f    r25.0<1;1,0>:hf                 
        add (1|M0)               r1.0<1>:f     r1.0<0;1,0>:f     r114.6<0;1,0>:f  {Compacted,F@2}
        mov (8|M0)               r113.0<1>:f   r117.8<1;1,0>:hf                
        add (1|M0)               r1.0<1>:f     r1.0<0;1,0>:f     r114.7<0;1,0>:f  {Compacted,F@2}
        mov (8|M0)               r38.0<1>:f    r25.8<1;1,0>:hf                 
        add (1|M0)               r1.0<1>:f     r1.0<0;1,0>:f     r115.0<0;1,0>:f  {Compacted,F@2}
        sel (16|M0)   (ge)f0.0   acc0.0<1>:f   r27.0<1;1,0>:f    1.03125:f              
        add (1|M0)               r1.0<1>:f     r1.0<0;1,0>:f     r115.1<0;1,0>:f  {Compacted,F@2}
        sel (16|M0)   (ge)f0.0   acc2.0<1>:f   r37.0<1;1,0>:f    1.03125:f              
        add (1|M0)               r1.0<1>:f     r1.0<0;1,0>:f     r115.2<0;1,0>:f  {Compacted,F@2}
        sel (16|M0)   (lt)f0.0   r27.0<1>:f    acc0.0<1;1,0>:f   0x3FC8E000:f              
        add (1|M0)               r1.0<1>:f     r1.0<0;1,0>:f     r115.3<0;1,0>:f  {Compacted,F@2}
        sel (16|M0)   (lt)f0.0   r37.0<1>:f    acc2.0<1;1,0>:f   0x3FC8E000:f              
        add (1|M0)               r1.0<1>:f     r1.0<0;1,0>:f     r115.4<0;1,0>:f  {Compacted,F@2}
        mov (8|M0)               r61.0<1>:ud   r27.0<2;1,0>:ud                 
        add (1|M0)               r1.0<1>:f     r1.0<0;1,0>:f     r115.5<0;1,0>:f  {Compacted,F@1}
        mov (8|M0)               r58.0<1>:ud   r27.1<2;1,0>:ud                 
        add (1|M0)               r1.0<1>:f     r1.0<0;1,0>:f     r115.6<0;1,0>:f  {Compacted,F@1}
        mov (8|M0)               r63.0<1>:ud   r37.0<2;1,0>:ud                 
        add (1|M0)               r1.0<1>:f     r1.0<0;1,0>:f     r115.7<0;1,0>:f  {Compacted,F@1}
        mov (8|M0)               r60.0<1>:ud   r37.1<2;1,0>:ud                 
        add (1|M0)               r1.0<1>:f     r1.0<0;1,0>:f     r112.0<0;1,0>:f  {Compacted,F@1}
        mov (8|M0)               r62.0<2>:hf   r61.0<1;1,0>:f                   {I@4}
        add (1|M0)               r1.0<1>:f     r1.0<0;1,0>:f     r112.1<0;1,0>:f  {Compacted,F@2}
        mov (8|M0)               r59.0<2>:hf   r58.0<1;1,0>:f                   {I@3}
        add (1|M0)               r1.0<1>:f     r1.0<0;1,0>:f     r112.2<0;1,0>:f  {Compacted,F@2}
        mov (8|M0)               r12.0<1>:hf   r63.0<1;1,0>:f                   {I@2}
        add (1|M0)               r1.0<1>:f     r1.0<0;1,0>:f     r112.3<0;1,0>:f  {Compacted,F@2}
        mov (8|M0)               r17.0<1>:hf   r60.0<1;1,0>:f                   {I@1}
        add (1|M0)               r1.0<1>:f     r1.0<0;1,0>:f     r112.4<0;1,0>:f  {Compacted,F@2}
        mov (8|M0)               r12.8<1>:uw   r62.0<2;1,0>:uw                 
        add (1|M0)               r1.0<1>:f     r1.0<0;1,0>:f     r112.5<0;1,0>:f  {Compacted,F@1}
        mov (8|M0)               r17.8<1>:uw   r59.0<2;1,0>:uw                 
        add (1|M0)               r1.0<1>:f     r1.0<0;1,0>:f     r112.6<0;1,0>:f  {Compacted,F@1}
        shl (16|M0)              r21.0<1>:d    r12.0<1;1,0>:uw   5:w               {I@2}
        add (1|M0)               r1.0<1>:f     r1.0<0;1,0>:f     r112.7<0;1,0>:f  {Compacted,F@1}
        mov (16|M0)              r27.0<1>:d    r17.0<1;1,0>:uw                  {I@2}
        add (1|M0)               r1.0<1>:f     r1.0<0;1,0>:f     r113.0<0;1,0>:f  {Compacted,F@1}
        add (16|M0)              r21.0<1>:d    r21.0<1;1,0>:d    2146992128:d               {I@2}
        add (1|M0)               r1.0<1>:f     r1.0<0;1,0>:f     r113.1<0;1,0>:f  {Compacted,F@1}
        shl (16|M0)              r27.0<1>:d    r27.0<1;1,0>:d    21:w               {Compacted,I@2}
        add (1|M0)               r1.0<1>:f     r1.0<0;1,0>:f     r113.2<0;1,0>:f  {Compacted,F@1}
        add (16|M0)              r21.0<1>:d    r21.0<1;1,0>:d    r27.0<1;1,0>:d   {Compacted,I@1}
        add (1|M0)               r1.0<1>:f     r1.0<0;1,0>:f     r113.3<0;1,0>:f  {Compacted,F@1}
        mov (8|M0)               r9.0<1>:f     r21.0<1;1,0>:hf                  {I@1}
        add (1|M0)               r1.0<1>:f     r1.0<0;1,0>:f     r113.4<0;1,0>:f  {Compacted,F@2}
        mov (8|M0)               r10.0<1>:f    r21.8<1;1,0>:hf                 
        add (1|M0)               r1.0<1>:f     r1.0<0;1,0>:f     r113.5<0;1,0>:f  {Compacted,F@2}
        mov (8|M0)               r7.0<1>:f     r22.0<1;1,0>:hf                 
        add (1|M0)               r1.0<1>:f     r1.0<0;1,0>:f     r113.6<0;1,0>:f  {Compacted,F@2}
        mov (8|M0)               r8.0<1>:f     r22.8<1;1,0>:hf                 
        add (1|M0)               r1.0<1>:f     r1.0<0;1,0>:f     r113.7<0;1,0>:f  {Compacted,F@2}
        add (1|M0)               r1.0<1>:f     r1.0<0;1,0>:f     r9.0<0;1,0>:f    {Compacted,F@1}
        add (1|M0)               r1.0<1>:f     r1.0<0;1,0>:f     r9.1<0;1,0>:f    {Compacted,F@1}
        add (1|M0)               r1.0<1>:f     r1.0<0;1,0>:f     r9.2<0;1,0>:f    {Compacted,F@1}
        add (1|M0)               r1.0<1>:f     r1.0<0;1,0>:f     r9.3<0;1,0>:f    {Compacted,F@1}
        add (1|M0)               r1.0<1>:f     r1.0<0;1,0>:f     r9.4<0;1,0>:f    {Compacted,F@1}
        add (1|M0)               r1.0<1>:f     r1.0<0;1,0>:f     r9.5<0;1,0>:f    {Compacted,F@1}
        add (1|M0)               r1.0<1>:f     r1.0<0;1,0>:f     r9.6<0;1,0>:f    {Compacted,F@1}
        add (1|M0)               r1.0<1>:f     r1.0<0;1,0>:f     r9.7<0;1,0>:f    {Compacted,F@1}
        add (1|M0)               r1.0<1>:f     r1.0<0;1,0>:f     r10.0<0;1,0>:f   {Compacted,F@1}
        add (1|M0)               r1.0<1>:f     r1.0<0;1,0>:f     r10.1<0;1,0>:f   {Compacted,F@1}
        add (1|M0)               r1.0<1>:f     r1.0<0;1,0>:f     r10.2<0;1,0>:f   {Compacted,F@1}
        add (1|M0)               r1.0<1>:f     r1.0<0;1,0>:f     r10.3<0;1,0>:f   {Compacted,F@1}
        add (1|M0)               r1.0<1>:f     r1.0<0;1,0>:f     r10.4<0;1,0>:f   {Compacted,F@1}
        add (1|M0)               r1.0<1>:f     r1.0<0;1,0>:f     r10.5<0;1,0>:f   {Compacted,F@1}
        add (1|M0)               r1.0<1>:f     r1.0<0;1,0>:f     r10.6<0;1,0>:f   {Compacted,F@1}
        add (1|M0)               r1.0<1>:f     r1.0<0;1,0>:f     r10.7<0;1,0>:f   {Compacted,F@1}
        add (1|M0)               r1.0<1>:f     r1.0<0;1,0>:f     r7.0<0;1,0>:f    {Compacted,F@1}
        add (1|M0)               r1.0<1>:f     r1.0<0;1,0>:f     r7.1<0;1,0>:f    {Compacted,F@1}
        add (1|M0)               r1.0<1>:f     r1.0<0;1,0>:f     r7.2<0;1,0>:f    {Compacted,F@1}
        add (1|M0)               r1.0<1>:f     r1.0<0;1,0>:f     r7.3<0;1,0>:f    {Compacted,F@1}
        add (1|M0)               r1.0<1>:f     r1.0<0;1,0>:f     r7.4<0;1,0>:f    {Compacted,F@1}
        add (1|M0)               r1.0<1>:f     r1.0<0;1,0>:f     r7.5<0;1,0>:f    {Compacted,F@1}
        add (1|M0)               r1.0<1>:f     r1.0<0;1,0>:f     r7.6<0;1,0>:f    {Compacted,F@1}
        add (1|M0)               r1.0<1>:f     r1.0<0;1,0>:f     r7.7<0;1,0>:f    {Compacted,F@1}
        add (1|M0)               r1.0<1>:f     r1.0<0;1,0>:f     r8.0<0;1,0>:f    {Compacted,F@1}
        add (1|M0)               r1.0<1>:f     r1.0<0;1,0>:f     r8.1<0;1,0>:f    {Compacted,F@1}
        add (1|M0)               r1.0<1>:f     r1.0<0;1,0>:f     r8.2<0;1,0>:f    {Compacted,F@1}
        add (1|M0)               r1.0<1>:f     r1.0<0;1,0>:f     r8.3<0;1,0>:f    {Compacted,F@1}
        add (1|M0)               r1.0<1>:f     r1.0<0;1,0>:f     r8.4<0;1,0>:f    {Compacted,F@1}
        add (1|M0)               r1.0<1>:f     r1.0<0;1,0>:f     r8.5<0;1,0>:f    {Compacted,F@1}
        add (1|M0)               r1.0<1>:f     r1.0<0;1,0>:f     r8.6<0;1,0>:f    {Compacted,F@1}
        add (1|M0)               r1.0<1>:f     r1.0<0;1,0>:f     r8.7<0;1,0>:f    {Compacted,F@1}
        mov (1|M0)               r1.0<2>:hf    r1.0<0;1,0>:f                    {F@1}
        math.inv (8|M0)          r11.0<1>:hf   r1.0<0;1,0>:hf                   {@1,$1}
        mov (1|M0)               r1.0<1>:uw    r11.0<0;1,0>:uw                  {$1.dst}
        mov (1|M0)               r1.0<1>:f     r1.0<0;1,0>:hf                   {I@1}
        mul (16|M0)              r114.0<1>:f   r1.0<0;1,0>:f     r114.0<1;1,0>:f  {Compacted,F@1}
        mul (16|M0)              r112.0<1>:f   r1.0<0;1,0>:f     r112.0<1;1,0>:f  {Compacted}
        mov (8|M0)               r21.0<1>:hf   r114.0<1;1,0>:f                  {F@2}
        mov (8|M0)               r21.8<1>:hf   r115.0<1;1,0>:f                 
        mul (16|M0)              r9.0<1>:f     r1.0<0;1,0>:f     r9.0<1;1,0>:f    {Compacted}
        mov (8|M0)               r11.0<1>:hf   r112.0<1;1,0>:f                  {F@4}
        mov (8|M0)               r11.8<1>:hf   r113.0<1;1,0>:f                 
        mov (8|M0)               r78.0<1>:f    (abs)r21.0<1;1,0>:hf             {F@5}
        mov (8|M0)               r79.0<1>:f    (abs)r21.8<1;1,0>:hf             {F@5}
        mul (16|M0)              r7.0<1>:f     r1.0<0;1,0>:f     r7.0<1;1,0>:f    {Compacted}
        mov (8|M0)               r41.0<1>:hf   r9.0<1;1,0>:f                    {F@6}
        mov (8|M0)               r41.8<1>:hf   r10.0<1;1,0>:f                  
        mov (8|M0)               r76.0<1>:f    (abs)r11.0<1;1,0>:hf             {F@7}
        mov (8|M0)               r77.0<1>:f    (abs)r11.8<1;1,0>:hf             {F@7}
        sel (16|M0)   (lt)f0.0   r78.0<1>:f    r78.0<1;1,0>:f    448.0:f               {Compacted,F@6}
        mov (8|M0)               r23.0<1>:hf   r7.0<1;1,0>:f                    {F@6}
        mov (8|M0)               r23.8<1>:hf   r8.0<1;1,0>:f                   
        mov (8|M0)               r106.0<1>:f   (abs)r41.0<1;1,0>:hf             {F@7}
        mov (8|M0)               r107.0<1>:f   (abs)r41.8<1;1,0>:hf             {F@7}
        sel (16|M0)   (lt)f0.0   r76.0<1>:f    r76.0<1;1,0>:f    448.0:f               {Compacted,F@6}
        shr (16|M0)              r49.0<1>:ud   r78.0<1;1,0>:ud   0x17:uw              {F@6}
        mov (8|M0)               r88.0<1>:f    (abs)r23.0<1;1,0>:hf             {F@5}
        mov (8|M0)               r89.0<1>:f    (abs)r23.8<1;1,0>:hf             {F@5}
        sel (16|M0)   (lt)f0.0   r106.0<1>:f   r106.0<1;1,0>:f   448.0:f               {Compacted,F@4}
        shr (16|M0)              r47.0<1>:ud   r76.0<1;1,0>:ud   0x17:uw              {F@4}
        sel (16|M0)   (ge)f0.0   r84.0<2>:ub   r49.0<4;1,0>:ub   0x79:uw              {I@2}
        cmp (16|M0)   (lt)f1.0   null<1>:f     r114.0<1;1,0>:f   0xB3000000:f               {Compacted}
        cmp (16|M0)   (lt)f1.1   null<1>:f     r112.0<1;1,0>:f   0xB3000000:f              
        sel (16|M0)   (lt)f0.0   r88.0<1>:f    r88.0<1;1,0>:f    448.0:f               {Compacted,F@4}
        sel (16|M0)   (ge)f0.0   r85.0<2>:ub   r47.0<4;1,0>:ub   0x79:uw              {I@2}
        mov (16|M0)              r80.0<1>:d    r84.0<2;1,0>:ub                  {I@2}
        shr (16|M0)              r113.0<1>:ud  r106.0<1;1,0>:ud  0x17:uw              {A@2}
        shr (16|M0)              r111.0<1>:ud  r88.0<1;1,0>:ud   0x17:uw              {F@1}
        mov (16|M0)              r73.0<1>:d    r85.0<2;1,0>:ub                  {I@4}
        shl (16|M0)              r80.0<1>:d    r80.0<1;1,0>:d    23:w               {Compacted,I@4}
        sel (16|M0)   (ge)f0.0   r126.0<2>:ub  r113.0<4;1,0>:ub  0x79:uw              {I@4}
        sel (16|M0)   (ge)f0.0   r127.0<2>:ub  r111.0<4;1,0>:ub  0x79:uw              {I@4}
        shl (16|M0)              r73.0<1>:d    r73.0<1;1,0>:d    23:w               {Compacted,I@4}
        add (16|M0)              r82.0<1>:d    r80.0<1;1,0>:d    -25165824:d               {I@4}
        mov (16|M0)              r122.0<1>:d   r126.0<2;1,0>:ub                 {I@4}
        add (16|M0)              r80.0<1>:d    -r80.0<1;1,0>:d   -2139095040:d              
        mov (16|M0)              r120.0<1>:d   r127.0<2;1,0>:ub                 {I@5}
        add (16|M0)              r59.0<1>:d    r73.0<1;1,0>:d    -25165824:d               {I@5}
        shl (16|M0)              r122.0<1>:d   r122.0<1;1,0>:d   23:w               {Compacted,I@4}
        mul (16|M0)              acc0.0<1>:f   r78.0<1;1,0>:f    r80.0<1;1,0>:f   {Compacted,I@4}
        add (16|M0)              r73.0<1>:d    -r73.0<1;1,0>:d   -2139095040:d              
        shl (16|M0)              r120.0<1>:d   r120.0<1;1,0>:d   23:w               {Compacted,I@4}
        add (16|M0)              r124.0<1>:d   r122.0<1;1,0>:d   -25165824:d               {I@3}
        rnde (16|M0)             acc0.0<1>:f   acc0.0<1;1,0>:f                 
        mul (16|M0)              acc2.0<1>:f   r76.0<1;1,0>:f    r73.0<1;1,0>:f   {Compacted,I@3}
        add (16|M0)              r122.0<1>:d   -r122.0<1;1,0>:d  -2139095040:d              
        add (16|M0)              r90.0<1>:d    r120.0<1;1,0>:d   -25165824:d               {I@3}
        mul (16|M0)              acc0.0<1>:f   acc0.0<1;1,0>:f   r82.0<1;1,0>:f   {Compacted}
        rnde (16|M0)             acc2.0<1>:f   acc2.0<1;1,0>:f                 
        mul (16|M0)              r106.0<1>:f   r106.0<1;1,0>:f   r122.0<1;1,0>:f  {Compacted,I@2}
        add (16|M0)              r120.0<1>:d   -r120.0<1;1,0>:d  -2139095040:d              
        mov (16|M0)              r92.0<1>:f    (abs)acc0.0<1;1,0>:f             {Compacted}
        mul (16|M0)              acc0.0<1>:f   acc2.0<1;1,0>:f   r59.0<1;1,0>:f   {Compacted}
        rnde (16|M0)             acc2.0<1>:f   r106.0<1;1,0>:f                  {F@3}
        mul (16|M0)              r88.0<1>:f    r88.0<1;1,0>:f    r120.0<1;1,0>:f  {Compacted,I@1}
(f1.0)  or (16|M0)               r92.0<1>:d    r92.0<1;1,0>:d    -2147483648:d               {F@4}
        mov (16|M0)              r13.0<1>:f    (abs)acc0.0<1;1,0>:f             {Compacted}
        mul (16|M0)              acc0.0<1>:f   acc2.0<1;1,0>:f   r124.0<1;1,0>:f  {Compacted}
        rnde (16|M0)             acc2.0<1>:f   r88.0<1;1,0>:f                   {F@3}
        cmp (16|M0)   (lt)f1.0   null<1>:f     r9.0<1;1,0>:f     0xB3000000:f               {Compacted,I@1}
        add (1|M0)               r1.0<1>:ud    r3.7<0;1,0>:ud    0x5000:uw             
        mov (8|M0)               r55.0<1>:hf   r92.0<1;1,0>:f                  
        mov (8|M0)               r55.8<1>:hf   r93.0<1;1,0>:f                  
(f1.1)  or (16|M0)               r13.0<1>:d    r13.0<1;1,0>:d    -2147483648:d               {F@6}
        mov (16|M0)              r11.0<1>:f    (abs)acc0.0<1;1,0>:f             {Compacted}
        mul (16|M0)              acc0.0<1>:f   acc2.0<1;1,0>:f   r90.0<1;1,0>:f   {Compacted}
        cmp (16|M0)   (lt)f1.1   null<1>:f     r7.0<1;1,0>:f     0xB3000000:f               {I@1}
        send.slm (1|M0)          null     r1      r55:1   0x0            0x0200B704           {A@4,$2} // wr:1+1, rd:0; store.slm.d64x4t.a32
        mov (8|M0)               r56.0<1>:hf   r13.0<1;1,0>:f                  
        mov (8|M0)               r56.8<1>:hf   r14.0<1;1,0>:f                  
(f1.0)  or (16|M0)               r11.0<1>:d    r11.0<1;1,0>:d    -2147483648:d               {F@5}
        mov (16|M0)              r107.0<1>:f   (abs)acc0.0<1;1,0>:f             {Compacted}
        add (1|M0)               r1.0<1>:ud    r3.7<0;1,0>:ud    0x5200:uw              {$2.src}
        mov (8|M0)               r38.0<1>:hf   r11.0<1;1,0>:f                   {I@2}
        send.slm (1|M0)          null     r1      r56:1   0x0            0x0200B704           {A@1,$3} // wr:1+1, rd:0; store.slm.d64x4t.a32
        mov (8|M0)               r38.8<1>:hf   r12.0<1;1,0>:f                  
(f1.1)  or (16|M0)               r107.0<1>:d   r107.0<1;1,0>:d   -2147483648:d               {F@3}
        add (1|M0)               r1.0<1>:ud    r3.7<0;1,0>:ud    0x5400:uw              {$3.src}
        mov (8|M0)               r40.0<1>:hf   r107.0<1;1,0>:f                  {I@2}
        send.slm (1|M0)          null     r1      r38:1   0x0            0x0200B704           {A@1,$4} // wr:1+1, rd:0; store.slm.d64x4t.a32
        mov (8|M0)               r40.8<1>:hf   r108.0<1;1,0>:f                 
        add (1|M0)               r1.0<1>:ud    r3.7<0;1,0>:ud    0x5600:uw              {$4.src}
        send.slm (1|M0)          null     r1      r40:1   0x0            0x0200B704           {A@1,$5} // wr:1+1, rd:0; store.slm.d64x4t.a32
(W)     send.slm (1|M0)          r71      r0      null:0  0x0            0x0210001F           {$6} // wr:1+0, rd:1; fence.slm.none.group
(W)     mov (1|M0)               r70.2<1>:ud   0x0:ud                             
(W)     mov (2|M0)               r70.10<1>:ub  r0.11<0;1,0>:ub                 
(W)     mov (8|M0)               null<1>:ud    r71.0<1;1,0>:ud                  {$6.dst}
(W)     send.gtwy (1|M0)         null     r70     null:0  0x0            0x02000004           {A@2,$8} // wr:1+0, rd:0; signal barrier
(W)     sync.bar                             null                            
        cmp (1|M0)    (eq)f1.0   null<1>:d     r2.4<0;1,0>:d     6:w              
(W)     and (1|M0)               f1.0<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
(f1.0.any16h) goto (16|M0)                   L32240                  L32240                
L22472:
(W)     mov (1|M0)               f1.1<1>:uw    0x1:uw                             
        mov (1|M0)               r1.0<1>:d     0:w                               {$5.src}
L22504:
        shl (1|M0)               r1.5<1>:d     r1.0<0;1,0>:d     9:w               {Compacted,I@1}
        send.slm (1|M0)          r85      r35     null:0  0x0            0x0280E700           {$11} // wr:1+0, rd:8; load.slm.d64x32t.a32
        sync.nop                             null                             {Compacted,$10.src}
        or (1|M0)                r7.0<1>:d     r1.5<0;1,0>:d     12288:w               {I@1}
        send.slm (1|M0)          r106     r103    null:0  0x0            0x0280E700           {$15} // wr:1+0, rd:8; load.slm.d64x32t.a32
        send.slm (1|M0)          r77      r7      null:0  0x0            0x0280E700           {A@1,$1} // wr:1+0, rd:8; load.slm.d64x32t.a32
        or (1|M0)                r7.0<1>:d     r1.5<0;1,0>:d     12544:w               {$1.src}
        send.slm (1|M0)          r114     r33     null:0  0x0            0x0280E700           {$2} // wr:1+0, rd:8; load.slm.d64x32t.a32
        sync.nop                             null                             {Compacted,$8.src}
        send.slm (1|M0)          r69      r7      null:0  0x0            0x0280E700           {A@1,$3} // wr:1+0, rd:8; load.slm.d64x32t.a32
        or (1|M0)                r7.0<1>:d     r1.5<0;1,0>:d     13312:w               {$3.src}
        shl (1|M0)               r1.0<1>:d     r1.0<0;1,0>:d     6:w               {Compacted}
(W)     and (1|M0)               f1.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
        sync.allwr                           ($1,$11,$15)                
        dpas.8x8 (8|M0)          r22:f         null:f            r22:hf            r22.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r22:f         r94:f             r77:hf            r85.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r14:f         r94:f             r77:hf            r106.0:hf        {$11}
        sync.nop                             null                             {Compacted,$11.src}
        send.slm (1|M0)          r77      r36     null:0  0x0            0x0280E700           {$4} // wr:1+0, rd:8; load.slm.d64x32t.a32
        dpas.8x8 (8|M0)          r61:f         r94:f             r69:hf            r85.0:hf         {$3}
        sync.nop                             null                             {Compacted,$3.src}
        send.slm (1|M0)          r85      r7      null:0  0x0            0x0280E700           {A@3,$6} // wr:1+0, rd:8; load.slm.d64x32t.a32
        or (1|M0)                r7.0<1>:d     r1.5<0;1,0>:d     13568:w               {$6.src}
        dpas.8x8 (8|M0)          r37:f         r94:f             r69:hf            r106.0:hf        {$15}
        sync.nop                             null                             {Compacted,$15.src}
        send.slm (1|M0)          r106     r31     null:0  0x0            0x0280E700           {$1} // wr:1+0, rd:8; load.slm.d64x32t.a32
        send.slm (1|M0)          r53      r7      null:0  0x0            0x0280E700           {A@1,$0} // wr:1+0, rd:8; load.slm.d64x32t.a32
        or (1|M0)                r7.0<1>:d     r1.5<0;1,0>:d     14336:w               {$0.src}
        send.slm (1|M0)          r69      r34     null:0  0x0            0x0280E700           {$9} // wr:1+0, rd:8; load.slm.d64x32t.a32
        sync.allwr                           ($0,$1,$2,$3,$6,$11,$15)                
        dpas.8x8 (8|M0)          r14:f         null:f            r14:hf            r14.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r14:f         r14:f             r85:hf            r114.0:hf        {Atomic}
        dpas.8x8 (8|M0)          r22:f         r22:f             r85:hf            r106.0:hf        {Atomic}
        dpas.8x8 (8|M0)          r37:f         r37:f             r53:hf            r114.0:hf        {Atomic}
        dpas.8x8 (8|M0)          r61:f         r61:f             r53:hf            r106.0:hf        {$2}
        sync.nop                             null                             {Compacted,$2.src}
        send.slm (1|M0)          r53      r7      null:0  0x0            0x0280E700           {A@1,$11} // wr:1+0, rd:8; load.slm.d64x32t.a32
        or (1|M0)                r7.0<1>:d     r1.5<0;1,0>:d     14592:w               {$11.src}
        send.slm (1|M0)          r114     r30     null:0  0x0            0x0280E700           {$15} // wr:1+0, rd:8; load.slm.d64x32t.a32
        send.slm (1|M0)          r45      r7      null:0  0x0            0x0280E700           {A@1,$1} // wr:1+0, rd:8; load.slm.d64x32t.a32
        or (1|M0)                r7.0<1>:d     r1.5<0;1,0>:d     15360:w               {$1.src}
        send.slm (1|M0)          r106     r7      null:0  0x0            0x0280E700           {A@1,$3} // wr:1+0, rd:8; load.slm.d64x32t.a32
        or (1|M0)                r7.0<1>:d     r1.5<0;1,0>:d     15616:w               {$3.src}
        sync.allwr                           ($1,$2,$4,$9,$11)                
(W)     sync.nop                             null                            
(W)     sync.nop                             null                            
        dpas.8x8 (8|M0)          r14:f         null:f            r14:hf            r14.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r14:f         r14:f             r53:hf            r77.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r22:f         r22:f             r53:hf            r69.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r37:f         r37:f             r45:hf            r77.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r61:f         r61:f             r45:hf            r69.0:hf         {$4}
        sync.nop                             null                             {Compacted,$4.src}
        send.slm (1|M0)          r53      r7      null:0  0x0            0x0280E700           {A@1,$6} // wr:1+0, rd:8; load.slm.d64x32t.a32
        send.slm (1|M0)          r45      r32     null:0  0x0            0x0280E700           {$11} // wr:1+0, rd:8; load.slm.d64x32t.a32
        or (1|M0)                r7.0<1>:d     r1.0<0;1,0>:d     r104.0<0;1,0>:d  {Compacted,$6.src}
        or (1|M0)                r1.0<1>:ud    r7.0<0;1,0>:ud    0x400:uw              {I@1}
        sync.allwr                           ($3,$4,$6,$11,$15)                
        dpas.8x8 (8|M0)          r22:f         r22:f             r106:hf           r114.0:hf        {Atomic}
        dpas.8x8 (8|M0)          r61:f         r61:f             r53:hf            r114.0:hf        {Atomic}
        dpas.8x8 (8|M0)          r14:f         r14:f             r106:hf           r45.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r37:f         r37:f             r53:hf            r45.0:hf         {$15}
        mov (8|M0)               r57.0<1>:f    r22.0<1;1,0>:f                   {Compacted,$15.dst}
        mov (8|M0)               r126.0<1>:f   r23.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r58.0<1>:f    r61.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r69.0<1>:f    r14.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r70.0<1>:f    r37.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r55.0<1>:f    r15.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r7      r69:2   0x0            0x0200C704           {A@2,$10} // wr:1+2, rd:0; store.slm.d64x8t.a32
        sync.nop                             null                             {Compacted,I@1}
        send.slm (1|M0)          null     r1      r57:2   0x0            0x0200C704           {$1} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r56.0<1>:f    r38.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r1.0<1>:ud    r7.0<0;1,0>:ud    0x80:uw              {$1.src}
        mov (8|M0)               r127.0<1>:f   r62.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r1      r55:2   0x0            0x0200C704           {A@1,$2} // wr:1+2, rd:0; store.slm.d64x8t.a32
        or (1|M0)                r1.0<1>:ud    r7.0<0;1,0>:ud    0x480:uw              {$2.src}
        mov (8|M0)               r53.0<1>:f    r16.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r1      r126:2  0x0            0x0200C704           {A@1,$3} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r54.0<1>:f    r39.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r1.0<1>:ud    r7.0<0;1,0>:ud    0x100:uw              {$3.src}
        mov (8|M0)               r124.0<1>:f   r24.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r1      r53:2   0x0            0x0200C704           {A@1,$4} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r125.0<1>:f   r63.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r1.0<1>:ud    r7.0<0;1,0>:ud    0x500:uw              {$4.src}
        mov (8|M0)               r51.0<1>:f    r17.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r1      r124:2  0x0            0x0200C704           {A@1,$6} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r52.0<1>:f    r40.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r1.0<1>:ud    r7.0<0;1,0>:ud    0x180:uw              {$6.src}
        mov (8|M0)               r122.0<1>:f   r25.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r1      r51:2   0x0            0x0200C704           {A@1,$11} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r123.0<1>:f   r64.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r1.0<1>:ud    r7.0<0;1,0>:ud    0x580:uw              {$11.src}
        mov (8|M0)               r49.0<1>:f    r18.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r1      r122:2  0x0            0x0200C704           {A@1,$15} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r50.0<1>:f    r41.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r1.0<1>:ud    r7.0<0;1,0>:ud    0x200:uw              {$15.src}
        mov (8|M0)               r120.0<1>:f   r26.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r1      r49:2   0x0            0x0200C704           {A@1,$1} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r121.0<1>:f   r65.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r1.0<1>:ud    r7.0<0;1,0>:ud    0x600:uw              {$1.src}
        mov (8|M0)               r47.0<1>:f    r19.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r1      r120:2  0x0            0x0200C704           {A@1,$2} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r48.0<1>:f    r42.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r1.0<1>:ud    r7.0<0;1,0>:ud    0x280:uw              {$2.src}
        mov (8|M0)               r118.0<1>:f   r27.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r1      r47:2   0x0            0x0200C704           {A@1,$3} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r119.0<1>:f   r66.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r1.0<1>:ud    r7.0<0;1,0>:ud    0x680:uw              {$3.src}
        mov (8|M0)               r45.0<1>:f    r20.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r1      r118:2  0x0            0x0200C704           {A@1,$4} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r46.0<1>:f    r43.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r1.0<1>:ud    r7.0<0;1,0>:ud    0x300:uw              {$4.src}
        mov (8|M0)               r116.0<1>:f   r28.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r1      r45:2   0x0            0x0200C704           {A@1,$6} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r117.0<1>:f   r67.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r1.0<1>:ud    r7.0<0;1,0>:ud    0x700:uw              {$6.src}
        mov (8|M0)               r45.0<1>:f    r21.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r1      r116:2  0x0            0x0200C704           {A@1,$11} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r46.0<1>:f    r44.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r1.0<1>:ud    r7.0<0;1,0>:ud    0x380:uw              {$11.src}
        mov (8|M0)               r37.0<1>:f    r29.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r1      r45:2   0x0            0x0200C704           {A@1,$15} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r38.0<1>:f    r68.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r1.0<1>:ud    r7.0<0;1,0>:ud    0x780:uw              {$15.src}
        send.slm (1|M0)          null     r1      r37:2   0x0            0x0200C704           {A@1,$1} // wr:1+2, rd:0; store.slm.d64x8t.a32
(~f1.1.any16h) goto (16|M0)                  L24208                  L24208                
L24160:
(W)     mov (1|M0)               f1.1<1>:uw    0x0:uw                             
        mov (1|M0)               r1.0<1>:d     1:w                               {$1.src}
        goto.b (16|M0)                       L24208                  L22504                
L24208:
        join (16|M0)                         L32240                                
L24224:
(W)     send.slm (1|M0)          r106     r0      null:0  0x0            0x0210001F           {$2} // wr:1+0, rd:1; fence.slm.none.group
(W)     mov (1|M0)               r103.2<1>:f   0.0:f                               {Compacted}
(W)     mov (2|M0)               r103.10<1>:ub  r0.11<0;1,0>:ub                 {F@1}
(W)     mov (8|M0)               null<1>:ud    r106.0<1;1,0>:ud                 {$2.dst}
(W)     send.gtwy (1|M0)         null     r103    null:0  0x0            0x02000004           {A@2,$3} // wr:1+0, rd:0; signal barrier
(W)     sync.bar                             null                            
        cmp (1|M0)    (eq)f1.1   null<1>:d     r2.4<0;1,0>:d     8:w              
(W)     and (1|M0)               f1.0<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(f1.0.any16h) goto (16|M0)                   L31472                  L31472                
L24360:
        send.slm (1|M0)          r15      r6      null:0  0x0            0x0240D700           {$4} // wr:1+0, rd:4; load.slm.d64x16t.a32
        add (1|M0)               r1.0<1>:ud    r105.0<0;1,0>:ud  0x4000:uw              {$1.src}
        sel (16|M0)   (lt)f0.0   r39.0<1>:f    (abs)r15.0<1;1,0>:f  448.0:f            {Compacted,$4.dst}
        sel (16|M0)   (lt)f0.0   r31.0<1>:f    (abs)r17.0<1;1,0>:f  448.0:f            {Compacted}
        shr (16|M0)              r106.0<1>:ud  r39.0<1;1,0>:ud   0x17:uw              {F@2}
        shr (16|M0)              r92.0<1>:ud   r31.0<1;1,0>:ud   0x17:uw              {F@1}
        sel (16|M0)   (ge)f0.0   r67.0<2>:ub   r106.0<4;1,0>:ub  0x79:uw              {I@2}
        sel (16|M0)   (ge)f0.0   r68.0<2>:ub   r92.0<4;1,0>:ub   0x79:uw              {I@2}
        mov (16|M0)              r63.0<1>:d    r67.0<2;1,0>:ub                  {I@2}
        mov (16|M0)              r61.0<1>:d    r68.0<2;1,0>:ub                  {I@2}
        shl (16|M0)              r63.0<1>:d    r63.0<1;1,0>:d    23:w               {Compacted,I@2}
        shl (16|M0)              r61.0<1>:d    r61.0<1;1,0>:d    23:w               {Compacted,I@2}
        add (16|M0)              r65.0<1>:d    r63.0<1;1,0>:d    -25165824:d               {I@2}
        add (16|M0)              r63.0<1>:d    -r63.0<1;1,0>:d   -2139095040:d              
        add (16|M0)              r53.0<1>:d    r61.0<1;1,0>:d    -25165824:d               {I@3}
        mul (16|M0)              acc0.0<1>:f   r39.0<1;1,0>:f    r63.0<1;1,0>:f   {Compacted,I@2}
        add (16|M0)              r61.0<1>:d    -r61.0<1;1,0>:d   -2139095040:d              
        rnde (16|M0)             acc0.0<1>:f   acc0.0<1;1,0>:f                 
        mul (16|M0)              acc2.0<1>:f   r31.0<1;1,0>:f    r61.0<1;1,0>:f   {Compacted,I@1}
        cmp (16|M0)   (lt)f1.0   null<1>:f     r15.0<1;1,0>:f    0.0:f               {Compacted}
        mul (16|M0)              acc0.0<1>:f   acc0.0<1;1,0>:f   r65.0<1;1,0>:f   {Compacted}
        rnde (16|M0)             acc2.0<1>:f   acc2.0<1;1,0>:f                 
        cmp (16|M0)   (lt)f1.1   null<1>:f     r17.0<1;1,0>:f    0.0:f              
        mov (16|M0)              r80.0<1>:f    (abs)acc0.0<1;1,0>:f             {Compacted}
        mul (16|M0)              acc0.0<1>:f   acc2.0<1;1,0>:f   r53.0<1;1,0>:f   {Compacted}
(f1.0)  or (16|M0)               r80.0<1>:d    r80.0<1;1,0>:d    -2147483648:d               {F@2}
        mov (16|M0)              r86.0<1>:f    (abs)acc0.0<1;1,0>:f             {Compacted}
        mov (8|M0)               r82.0<1>:hf   r80.0<1;1,0>:f                   {I@1}
        mov (8|M0)               r82.8<1>:hf   r81.0<1;1,0>:f                  
(f1.1)  or (16|M0)               r86.0<1>:d    r86.0<1;1,0>:d    -2147483648:d               {F@3}
        send.slm (1|M0)          null     r1      r82:1   0x0            0x0200B704           {A@1,$6} // wr:1+1, rd:0; store.slm.d64x4t.a32
        mov (8|M0)               r83.0<1>:hf   r86.0<1;1,0>:f                   {I@1}
        mov (8|M0)               r83.8<1>:hf   r87.0<1;1,0>:f                  
        add (1|M0)               r1.0<1>:ud    r105.0<0;1,0>:ud  0x4200:uw              {$6.src}
        send.slm (1|M0)          null     r1      r83:1   0x0            0x0200B704           {A@1,$11} // wr:1+1, rd:0; store.slm.d64x4t.a32
(W)     send.slm (1|M0)          r110     r0      null:0  0x0            0x0210001F           {$15} // wr:1+0, rd:1; fence.slm.none.group
(W)     mov (1|M0)               r109.2<1>:f   0.0:f                               {Compacted}
(W)     mov (2|M0)               r109.10<1>:ub  r0.11<0;1,0>:ub                 {F@1}
(W)     mov (8|M0)               null<1>:ud    r110.0<1;1,0>:ud                 {$15.dst}
(W)     send.gtwy (1|M0)         null     r109    null:0  0x0            0x02000004           {A@2,$2} // wr:1+0, rd:0; signal barrier
(W)     sync.bar                             null                            
        add (1|M0)               r24.0<1>:ud   r102.0<0;1,0>:ud  0x4000:uw             
(W)     mov (1|M0)               f1.0<1>:uw    0x1:uw                             
        mov (1|M0)               r1.6<2>:f     0.0:f                               {$11.src}
        mov (1|M0)               r1.7<2>:f     0.0:f                              
        or (1|M0)                r23.0<1>:ud   r24.0<0;1,0>:ud   0x100:uw              {I@2}
        or (1|M0)                r30.0<1>:ud   r24.0<0;1,0>:ud   0x200:uw             
        or (1|M0)                r1.0<1>:ud    r24.0<0;1,0>:ud   0x300:uw             
L25032:
        shl (1|M0)               r3.4<1>:d     r1.7<0;1,0>:d     8:w               {F@1}
        shr (1|M0)               r3.1<1>:ud    r1.6<0;1,0>:ud    0x18:uw             
        shl (1|M0)               r6.1<1>:d     r1.6<0;1,0>:d     8:w              
        or (1|M0)                r6.2<1>:d     r3.4<0;1,0>:d     r3.1<0;1,0>:d    {I@2}
        shr (1|M0)               r3.1<1>:ud    r6.1<0;1,0>:ud    0x1F:uw              {I@2}
        shl (1|M0)               r6.1<1>:d     r6.1<0;1,0>:d     1:w               {Compacted}
        shl (1|M0)               r3.4<1>:d     r6.2<0;1,0>:d     1:w               {I@3}
        sync.nop                             null                             {Compacted,$4.src}
        addc (1|M0)              r8.0<1>:ud    r4.6<0;1,0>:ud    r6.1<0;1,0>:ud   {AccWrEn,I@2}
        or (1|M0)                r6.2<1>:d     r3.4<0;1,0>:d     r3.1<0;1,0>:d    {I@2}
        mov (1|M0)               r25.0<1>:f    r8.0<0;1,0>:f                    {Compacted,I@2}
        sync.nop                             null                             {Compacted,$14.src}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$10.src}
        addc (1|M0)              r15.0<1>:ud   r25.0<0;1,0>:ud   0x100:ud              {AccWrEn,F@1}
        add3 (1|M0)              r25.1<1>:d    r7.0<0;0>:d       r4.7<0;0>:d       r6.2<0>:d        {I@2}
        mov (1|M0)               r16.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        add3 (1|M0)              r15.1<1>:d    r16.0<0;0>:d      r25.1<0;0>:d      0:w               {I@1}
        send.ugm (1|M0)          r114     r25     null:0  0x0            0x0280E780           {$6} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        send.ugm (1|M0)          r47      r15     null:0  0x0            0x0280E780           {A@1,$11} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        send.slm (1|M0)          r31      r24     null:0  0x0            0x0280E700           {$15} // wr:1+0, rd:8; load.slm.d64x32t.a32
        send.slm (1|M0)          r7       r23     null:0  0x0            0x0280E700           {$12} // wr:1+0, rd:8; load.slm.d64x32t.a32
        send.slm (1|M0)          r86      r30     null:0  0x0            0x0280E700           {$13} // wr:1+0, rd:8; load.slm.d64x32t.a32
        send.slm (1|M0)          r78      r1      null:0  0x0            0x0280E700           {$7} // wr:1+0, rd:8; load.slm.d64x32t.a32
        shl (1|M0)               r1.5<1>:d     r1.6<0;1,0>:d     6:w               {$7.src}
(W)     and (1|M0)               f1.1<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
        sync.allwr                           ($6,$11,$12,$15)                
        dpas.8x8 (8|M0)          r15:f         null:f            r15:hf            r15.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r15:f         r94:f             r114:hf           r31.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r39:f         r94:f             r47:hf            r31.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r70:f         r94:f             r47:hf            r7.0:hf          {Atomic}
        dpas.8x8 (8|M0)          r31:f         r94:f             r114:hf           r7.0:hf          {$6}
        addc (1|M0)              r8.0<1>:ud    r25.0<0;1,0>:ud   0x400:ud              {AccWrEn,$6.src}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        add3 (1|M0)              r8.1<1>:d     r7.0<0;0>:d       r25.1<0;0>:d      0:w               {I@1}
        addc (1|M0)              r7.0<1>:ud    r8.0<0;1,0>:ud    0x100:ud              {AccWrEn}
        send.ugm (1|M0)          r61      r8      null:0  0x0            0x0280E780           {A@2,$11} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        add3 (1|M0)              r7.1<1>:d     r9.0<0;0>:d       r8.1<0;0>:d       0:w               {I@1}
        or (1|M0)                r8.0<1>:d     r1.5<0;1,0>:d     r104.0<0;1,0>:d  {Compacted,$11.src}
        sync.nop                             null                             {Compacted,$2.src}
        send.ugm (1|M0)          r105     r7      null:0  0x0            0x0280E780           {A@2,$15} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        sync.nop                             null                             {Compacted,$15.src}
        or (1|M0)                r7.0<1>:ud    r8.0<0;1,0>:ud    0x400:uw              {I@1}
        sync.allwr                           ($6,$7,$11,$13,$15)                
(W)     sync.nop                             null                            
        dpas.8x8 (8|M0)          r15:f         null:f            r15:hf            r15.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r15:f         r15:f             r61:hf            r86.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r31:f         r31:f             r61:hf            r78.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r39:f         r39:f             r105:hf           r86.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r70:f         r70:f             r105:hf           r78.0:hf         {$13}
        mov (8|M0)               r118.0<1>:f   r15.0<1;1,0>:f                   {Compacted,$13.dst}
        mov (8|M0)               r105.0<1>:f   r31.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r102.0<1>:f   r16.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r61.0<1>:f    r32.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r91.0<1>:f    r17.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r119.0<1>:f   r39.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r106.0<1>:f   r70.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r8      r118:2  0x0            0x0200C704           {A@2,$4} // wr:1+2, rd:0; store.slm.d64x8t.a32
        send.slm (1|M0)          null     r7      r105:2  0x0            0x0200C704           {A@1,$2} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r103.0<1>:f   r40.0<1;1,0>:f                   {Compacted,$3.src}
        or (1|M0)                r7.0<1>:ud    r8.0<0;1,0>:ud    0x80:uw              {$2.src}
        mov (8|M0)               r62.0<1>:f    r71.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r7      r102:2  0x0            0x0200C704           {A@1,$6} // wr:1+2, rd:0; store.slm.d64x8t.a32
        or (1|M0)                r7.0<1>:ud    r8.0<0;1,0>:ud    0x480:uw              {$6.src}
        mov (8|M0)               r92.0<1>:f    r41.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r7      r61:2   0x0            0x0200C704           {A@1,$11} // wr:1+2, rd:0; store.slm.d64x8t.a32
        or (1|M0)                r7.0<1>:ud    r8.0<0;1,0>:ud    0x100:uw              {$11.src}
        mov (8|M0)               r59.0<1>:f    r33.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r7      r91:2   0x0            0x0200C704           {A@1,$15} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r60.0<1>:f    r72.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r7.0<1>:ud    r8.0<0;1,0>:ud    0x500:uw              {$15.src}
        mov (8|M0)               r89.0<1>:f    r18.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r7      r59:2   0x0            0x0200C704           {A@1,$5} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r90.0<1>:f    r42.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r7.0<1>:ud    r8.0<0;1,0>:ud    0x180:uw              {$5.src}
        mov (8|M0)               r57.0<1>:f    r34.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r7      r89:2   0x0            0x0200C704           {A@1,$8} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r58.0<1>:f    r73.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r7.0<1>:ud    r8.0<0;1,0>:ud    0x580:uw              {$8.src}
        mov (8|M0)               r87.0<1>:f    r19.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r7      r57:2   0x0            0x0200C704           {A@1,$0} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r88.0<1>:f    r43.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r7.0<1>:ud    r8.0<0;1,0>:ud    0x200:uw              {$0.src}
        mov (8|M0)               r55.0<1>:f    r35.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r7      r87:2   0x0            0x0200C704           {A@1,$2} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r56.0<1>:f    r74.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r7.0<1>:ud    r8.0<0;1,0>:ud    0x600:uw              {$2.src}
        mov (8|M0)               r85.0<1>:f    r20.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r7      r55:2   0x0            0x0200C704           {A@1,$6} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r86.0<1>:f    r44.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r7.0<1>:ud    r8.0<0;1,0>:ud    0x280:uw              {$6.src}
        mov (8|M0)               r53.0<1>:f    r36.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r7      r85:2   0x0            0x0200C704           {A@1,$11} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r54.0<1>:f    r75.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r7.0<1>:ud    r8.0<0;1,0>:ud    0x680:uw              {$11.src}
        mov (8|M0)               r83.0<1>:f    r21.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r7      r53:2   0x0            0x0200C704           {A@1,$15} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r84.0<1>:f    r45.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r7.0<1>:ud    r8.0<0;1,0>:ud    0x300:uw              {$15.src}
        mov (8|M0)               r51.0<1>:f    r37.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r7      r83:2   0x0            0x0200C704           {A@1,$9} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r52.0<1>:f    r76.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r7.0<1>:ud    r8.0<0;1,0>:ud    0x700:uw              {$9.src}
        mov (8|M0)               r25.0<1>:f    r22.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r7      r51:2   0x0            0x0200C704           {A@1,$10} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r26.0<1>:f    r46.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r7.0<1>:ud    r8.0<0;1,0>:ud    0x380:uw              {$10.src}
        mov (8|M0)               r78.0<1>:f    r38.0<1;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r7      r25:2   0x0            0x0200C704           {A@1,$1} // wr:1+2, rd:0; store.slm.d64x8t.a32
        mov (8|M0)               r79.0<1>:f    r77.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r7.0<1>:ud    r8.0<0;1,0>:ud    0x780:uw              {$1.src}
        send.slm (1|M0)          null     r7      r78:2   0x0            0x0200C704           {A@1,$14} // wr:1+2, rd:0; store.slm.d64x8t.a32
(~f1.1.any16h) goto (16|M0)                  L26560                  L26560                
L26496:
(W)     mov (1|M0)               f1.0<1>:uw    0x0:uw                             
        mov (1|M0)               r1.6<2>:f     1.4013e-45:f                              
        mov (1|M0)               r1.7<2>:d     0:d                              
        goto.b (16|M0)                       L26560                  L25032                
L26560:
        join (16|M0)                         L31472                                
L26576:
        sync.nop                             null                             {Compacted,$4.src}
(W)     send.slm (1|M0)          r8       r0      null:0  0x0            0x0210001F           {$2} // wr:1+0, rd:1; fence.slm.none.group
(W)     mov (1|M0)               r7.2<1>:f     0.0:f                               {Compacted,$14.src}
(W)     mov (2|M0)               r7.10<1>:ub   r0.11<0;1,0>:ub                  {F@1}
(W)     mov (8|M0)               null<1>:ud    r8.0<1;1,0>:ud                   {$2.dst}
(W)     send.gtwy (1|M0)         null     r7      null:0  0x0            0x02000004           {A@2,$6} // wr:1+0, rd:0; signal barrier
(W)     sync.bar                             null                            
        cmp (1|M0)    (eq)f1.0   null<1>:d     r2.4<0;1,0>:d     9:w              
(W)     and (1|M0)               f1.0<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
(~f1.0.any16h) goto (16|M0)                  L27456                  L27456                
L26720:
(W)     and (1|M0)               f0.0<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
        shl (1|M0)               r3.0<1>:ud    r3.0<0;1,0>:ud    0x8:uw             
        add (1|M0)               r3.0<1>:ud    r3.0<0;1,0>:ud    0x7000:uw              {I@1}
(f0.0.any16h) goto (16|M0)                   L27456                  L34576                
L26784:
        shl (1|M0)               r3.4<1>:d     r3.6<0;1,0>:d     12:w              
        shr (1|M0)               r3.3<1>:ud    r3.5<0;1,0>:ud    0x14:uw             
        shl (1|M0)               r3.1<1>:d     r3.5<0;1,0>:d     12:w              
        or (1|M0)                r3.2<1>:d     r3.4<0;1,0>:d     r3.3<0;1,0>:d    {I@2}
        shr (1|M0)               r3.3<1>:ud    r3.1<0;1,0>:ud    0x1F:uw              {I@2}
        shl (1|M0)               r3.1<1>:d     r3.1<0;1,0>:d     1:w               {Compacted}
        shl (1|M0)               r2.0<1>:d     r30.1<0;1,0>:d    1:w               {Compacted}
        shl (1|M0)               r3.4<1>:d     r3.2<0;1,0>:d     1:w               {I@4}
        addc (1|M0)              r30.0<1>:ud   r4.2<0;1,0>:ud    r3.1<0;1,0>:ud   {AccWrEn,I@3}
        shr (1|M0)               r2.2<1>:ud    r30.1<0;1,0>:ud   0x1F:uw             
        or (1|M0)                r3.2<1>:d     r3.4<0;1,0>:d     r3.3<0;1,0>:d    {I@3}
        mov (1|M0)               r4.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r1.0<1>:ud    r30.0<0;1,0>:ud   r2.0<0;1,0>:ud   {AccWrEn,I@4}
        or (1|M0)                r2.1<1>:d     r2.2<0;1,0>:d     0:w               {I@4}
        add3 (1|M0)              r2.5<1>:d     r4.0<0;0>:d       r4.3<0;0>:d       r3.2<0>:d        {I@3}
        mov (1|M0)               r30.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r2.4<2>:f     0.0:f                              
        mov (1|M0)               r2.2<1>:d     r1.0<0;1,0>:d                    {I@4}
        add3 (1|M0)              r2.3<1>:d     r30.0<0;0>:d      r2.5<0;0>:d       r2.1<0>:d        {I@2}
        mov (1|M0)               r2.5<2>:f     0.0:f                               {I@1}
L27072:
        bfn.0xEA (1|M0)          r2.0<1>:ud    r2.4<0;0>:ud      r30.1<0;0>:ud     0x1E0:uw              {F@2} // s0|s1&s2
(W)     mov (1|M0)               r30.0<1>:f    9.401659e-38:f                              
        shl (1|M0)               r2.0<1>:ud    r2.0<0;1,0>:ud    0x2:uw              {I@1}
        shl (1|M0)               r2.1<1>:d     r2.5<0;1,0>:d     1:w               {F@2}
        bfn.0xEA (1|M0)          r30.0<1>:ud   r2.0<0;0>:ud      r3.0<0;0>:ud      r30.0<0>:ud      {A@1} // s0|s1&s2
        shl (1|M0)               r3.1<1>:d     r2.4<0;1,0>:d     1:w              
        send.slm (1|M0)          r30      r30     null:0  0x0            0x02100500           {A@2,$11} // wr:1+0, rd:1; load.slm.d32.a32
        shr (1|M0)               r2.0<1>:ud    r2.4<0;1,0>:ud    0x1F:uw             
        or (1|M0)                r3.2<1>:d     r2.1<0;1,0>:d     r2.0<0;1,0>:d    {I@1}
        addc (1|M0)              r2.0<1>:ud    r2.2<0;1,0>:ud    r3.1<0;1,0>:ud   {AccWrEn}
        mov (1|M0)               r2.12<2>:hf   r30.0<0;1,0>:f                   {$11.dst}
        mov (1|M0)               r30.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,F@1}
        add3 (1|M0)              r2.1<1>:d     r30.0<0;0>:d      r2.3<0;0>:d       r3.2<0>:d        {I@1}
        mov (1|M0)               r30.0<1>:d    r2.12<0;1,0>:uw                 
        send.ugm (1|M0)          null     r2      r30:1   0x0            0x04000B84           {A@1,$15} // wr:2+1, rd:0; store.ugm.d16u32.a64
        addc (1|M0)              r30.0<1>:ud   r2.4<0;1,0>:ud    0x1:ud              {AccWrEn,$15.src}
        mov (1|M0)               r2.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r2.6<1>:d     r30.0<0;1,0>:d                   {I@2}
        add3 (1|M0)              r2.7<1>:d     r2.0<0;0>:d       r2.5<0;0>:d       0:w               {I@2}
        cmp (1|M0)    (eq)f0.1   null<1>:d     r2.7<0;1,0>:d     0:w               {I@1}
(f0.1)  cmp (1|M0)    (eq)f0.1   null<1>:d     r2.6<0;1,0>:d     32:w              
(W)     and (1|M0)               f1.1<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(f1.1.any16h) goto (16|M0)                   L27456                  L34576                
L27424:
(W)     mov (2|M0)               r2.4<1>:ud    r2.6<1;1,0>:ud                  
        goto.b (16|M0)                       L27456                  L27072                
L27456:
        join (16|M0)                         L31472                                
L27472:
(W)     and (1|M0)               f1.0<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(~f1.0.any16h) goto (16|M0)                  L31472                  L34576                
L27504:
        cmp (1|M0)    (gt)f0.1   null<1>:d     r1.2<0;1,0>:d     -1:w              
        cmp (1|M0)    (lt)f1.0   null<1>:d     r1.2<0;1,0>:d     r2.7<0;1,0>:d   
(W)     mov (1|M0)               r1.0<1>:hf    0x1:hf                             
(f0.1)  cmp (1|M0)    (lt)f0.1   null<1>:d     r1.4<0;1,0>:d     r2.6<0;1,0>:d   
(f0.1)  sel (1|M0)               r1.1<1>:uw    r1.0<0;1,0>:uw    0x0:uw              {F@1}
(f1.0)  sel (1|M0)               r1.0<1>:uw    r1.0<0;1,0>:uw    0x0:uw             
        and (1|M0)    (ne)f0.0   null<1>:uw    r1.1<0;1,0>:uw    r1.0<0;1,0>:uw   {I@1}
(W)     and (1|M0)               f0.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
(~f0.1.any16h) goto (16|M0)                  L31472                  L34576                
L27648:
        mul (1|M0)               acc0.0<1>:ud  r1.4<0;1,0>:ud    r2.14<0;1,0>:uw 
        mach (1|M0)              r121.0<1>:ud  r1.4<0;1,0>:ud    r2.7<0;1,0>:ud   {AccWrEn}
        cmp (1|M0)    (eq)f1.1   null<1>:w     r1.6<0;1,0>:b     0:w              
        mov (1|M0)               r120.0<1>:ud  acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r3.0<1>:ud    r120.0<0;1,0>:ud  r1.2<0;1,0>:ud   {AccWrEn,I@1}
(W)     and (1|M0)               f0.0<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
        mov (1|M0)               r1.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        shl (1|M0)               r1.4<1>:d     r3.0<0;1,0>:d     5:w               {Compacted,I@3}
        add3 (1|M0)              r1.5<1>:d     r1.0<0;0>:d       r121.0<0;0>:d     0:w               {I@2}
        shr (1|M0)               r1.0<1>:ud    r3.0<0;1,0>:ud    0x1B:uw             
        shl (1|M0)               r1.2<1>:d     r1.5<0;1,0>:d     5:w               {I@2}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.0<0;1,0>:d    {I@1}
(f0.0.any16h) goto (16|M0)                   L28024                  L28024                
L27832:
        shl (1|M0)               r1.0<1>:d     r1.4<0;1,0>:d     1:w               {Compacted}
        shl (1|M0)               r1.6<1>:d     r1.5<0;1,0>:d     1:w               {I@3}
        shr (1|M0)               r1.2<1>:ud    r1.4<0;1,0>:ud    0x1F:uw             
        addc (1|M0)              r3.0<1>:ud    r3.2<0;1,0>:ud    r1.0<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r1.1<1>:d     r1.6<0;1,0>:d     r1.2<0;1,0>:d    {I@2}
        mov (1|M0)               r2.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        add3 (1|M0)              r3.1<1>:d     r2.0<0;0>:d       r3.3<0;0>:d       r1.1<0>:d        {I@1}
        send.ugm (1|M0)          r122     r3      null:0  0x0            0x0220C780           {A@1,$2} // wr:1+0, rd:2; load.ugm.d64x8t.a64
        mov (8|M0)               r13.0<1>:f    r122.0<1;1,0>:hf                 {$2.dst}
        mov (8|M0)               r14.0<1>:f    r122.8<1;1,0>:hf                
        mov (8|M0)               r15.0<1>:f    r123.0<1;1,0>:hf                
        mov (8|M0)               r16.0<1>:f    r123.8<1;1,0>:hf                
        goto (16|M0)                         L28024                  L28168                
L28024:
        join (16|M0)                         L28168                                
L28040:
        shl (1|M0)               r1.6<1>:d     r1.4<0;1,0>:d     2:w              
        shl (1|M0)               r3.1<1>:d     r1.5<0;1,0>:d     2:w              
        shr (1|M0)               r3.0<1>:ud    r1.4<0;1,0>:ud    0x1E:uw             
        addc (1|M0)              r2.0<1>:ud    r3.2<0;1,0>:ud    r1.6<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r1.7<1>:d     r3.1<0;1,0>:d     r3.0<0;1,0>:d    {I@2}
        mov (1|M0)               r3.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r1.0<1>:f     r2.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r1.1<1>:d     r3.0<0;0>:d       r3.3<0;0>:d       r1.7<0>:d        {I@1}
        send.ugm (1|M0)          r13      r1      null:0  0x0            0x0240E580           {A@1,$11} // wr:1+0, rd:4; load.ugm.d32x32t.a64
L28168:
        join (16|M0)                         L31472                                
L28184:
        send.ugm (1|M0)          r59      r5      null:0  0x0            0x0240E580           {$15} // wr:1+0, rd:4; load.ugm.d32x32t.a64
        cmp (1|M0)    (lt)f1.0   null<1>:d     r5.2<0;1,0>:d     1:w              
        send.slm (1|M0)          r45      r6      null:0  0x0            0x0240D700           {$2} // wr:1+0, rd:4; load.slm.d64x16t.a32
(W)     and (1|M0)               f1.1<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
        sync.allwr                           ($2,$15)                
        mad (16|M0)              r45.0<1>:f    r45.0<1;0>:f      r59.0<1;0>:f      r13.0<1>:f       {Compacted,$11.dst}
        mad (16|M0)              r47.0<1>:f    r47.0<1;0>:f      r61.0<1;0>:f      r15.0<1>:f       {Compacted}
(f1.1.any16h) goto (16|M0)                   L28960                  L28960                
L28296:
        cmp (1|M0)    (lt)f0.1   null<1>:d     r5.2<0;1,0>:d     4:w              
(W)     and (1|M0)               f1.0<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(f1.0.any16h) goto (16|M0)                   L28536                  L28536                
L28344:
        cmp (1|M0)    (eq)f0.0   null<1>:d     r5.2<0;1,0>:d     4:w              
(W)     and (1|M0)               f0.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
(~f0.1.any16h) goto (16|M0)                  L28536                  L29024                
L28392:
        mov (8|M0)               r20.0<1>:hf   r45.0<1;1,0>:f                   {F@2}
        mov (8|M0)               r20.8<1>:hf   r46.0<1;1,0>:f                  
        mov (8|M0)               r19.0<1>:hf   r47.0<1;1,0>:f                   {F@3}
        mov (8|M0)               r19.8<1>:hf   r48.0<1;1,0>:f                  
        mov (8|M0)               r45.0<1>:f    r20.0<1;1,0>:hf                  {F@4}
        mov (8|M0)               r46.0<1>:f    r20.8<1;1,0>:hf                  {F@4}
        mov (8|M0)               r47.0<1>:f    r19.0<1;1,0>:hf                  {F@4}
        mov (8|M0)               r48.0<1>:f    r19.8<1;1,0>:hf                  {F@4}
        goto (16|M0)                         L28536                  L30136                
L28536:
        join (16|M0)                         L28960                                
L28552:
        cmp (1|M0)    (eq)f1.1   null<1>:d     r5.2<0;1,0>:d     1:w              
(W)     and (1|M0)               f0.0<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(~f0.0.any16h) goto (16|M0)                  L28960                  L29024                
L28600:
        sel (16|M0)   (lt)f0.0   r68.0<1>:f    (abs)r45.0<1;1,0>:f  448.0:f            {Compacted,F@3}
        sel (16|M0)   (lt)f0.0   r64.0<1>:f    (abs)r47.0<1;1,0>:f  448.0:f            {Compacted,F@2}
        shr (16|M0)              r115.0<1>:ud  r68.0<1;1,0>:ud   0x17:uw              {F@2}
        shr (16|M0)              r113.0<1>:ud  r64.0<1;1,0>:ud   0x17:uw              {F@1}
        sel (16|M0)   (ge)f0.0   r92.0<2>:ub   r115.0<4;1,0>:ub  0x79:uw              {I@2}
        sel (16|M0)   (ge)f0.0   r93.0<2>:ub   r113.0<4;1,0>:ub  0x79:uw              {I@2}
        mov (16|M0)              r88.0<1>:d    r92.0<2;1,0>:ub                  {I@2}
        mov (16|M0)              r86.0<1>:d    r93.0<2;1,0>:ub                  {I@2}
        shl (16|M0)              r88.0<1>:d    r88.0<1;1,0>:d    23:w               {Compacted,I@2}
        shl (16|M0)              r86.0<1>:d    r86.0<1;1,0>:d    23:w               {Compacted,I@2}
        add (16|M0)              r90.0<1>:d    r88.0<1;1,0>:d    -25165824:d               {I@2}
        add (16|M0)              r78.0<1>:d    r86.0<1;1,0>:d    -25165824:d               {I@2}
        add (16|M0)              r88.0<1>:d    -r88.0<1;1,0>:d   -2139095040:d              
        add (16|M0)              r86.0<1>:d    -r86.0<1;1,0>:d   -2139095040:d              
        mul (16|M0)              acc0.0<1>:f   r68.0<1;1,0>:f    r88.0<1;1,0>:f   {Compacted,I@2}
        mul (16|M0)              acc2.0<1>:f   r64.0<1;1,0>:f    r86.0<1;1,0>:f   {Compacted,I@1}
        rnde (16|M0)             acc0.0<1>:f   acc0.0<1;1,0>:f                 
        rnde (16|M0)             acc2.0<1>:f   acc2.0<1;1,0>:f                 
        cmp (16|M0)   (lt)f1.0   null<1>:f     r45.0<1;1,0>:f    0.0:f               {Compacted}
        cmp (16|M0)   (lt)f0.1   null<1>:f     r47.0<1;1,0>:f    0.0:f              
        mul (16|M0)              acc0.0<1>:f   acc0.0<1;1,0>:f   r90.0<1;1,0>:f   {Compacted}
        mul (16|M0)              acc2.0<1>:f   acc2.0<1;1,0>:f   r78.0<1;1,0>:f   {Compacted}
        mov (16|M0)              r107.0<1>:f   (abs)acc0.0<1;1,0>:f             {Compacted}
        mov (16|M0)              r118.0<1>:f   (abs)acc2.0<1;1,0>:f             {Compacted}
(f1.0)  or (16|M0)               r107.0<1>:d   r107.0<1;1,0>:d   -2147483648:d               {F@2}
(f0.1)  or (16|M0)               r118.0<1>:d   r118.0<1;1,0>:d   -2147483648:d               {F@1}
        mov (16|M0)              r45.0<1>:f    r107.0<1;1,0>:f                  {Compacted,I@2}
        mov (16|M0)              r47.0<1>:f    r118.0<1;1,0>:f                  {Compacted,I@1}
        goto (16|M0)                         L28960                  L30136                
L28960:
        join (16|M0)                         L29024                                
L28976:
        cmp (1|M0)    (eq)f0.0   null<1>:d     r5.2<0;1,0>:d     0:w              
(W)     and (1|M0)               f1.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
(f1.1.any16h) goto (16|M0)                   L29024                  L30136                
L29024:
        join (16|M0)                         L30136                                
L29040:
        and (1|M0)               r1.7<1>:d     r5.2<0;1,0>:d     -2:w              
        and (1|M0)               r1.6<1>:d     r5.2<0;1,0>:d     -3:w              
        mov (1|M0)               r1.2<1>:d     0:w                              
L29088:
        cmp (1|M0)    (eq)f1.1   null<1>:d     r1.7<0;1,0>:d     2:w               {I@3}
        shl (1|M0)               r1.2<1>:w     r1.4<0;1,0>:w     2:w               {I@2}
        add (1|M0)               a0.0<1>:uw    r1.2<0;1,0>:uw    0x5A0:uw              {A@1}
(W)     and (1|M0)               f1.0<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
        mov (1|M0)               r2.0<1>:f     r[a0.0]<0;1,0>:f                 {F@1}
(~f1.0.any16h) goto (16|M0)                  L29416                  L29416                 {A@1}
L29184:
        mov (1|M0)               r2.0<2>:hf    r[a0.0]<0;1,0>:f                
        cmp (1|M0)    (lt)f1.0   null<1>:f     r[a0.0]<0;1,0>:f  -4.001953e+00:f               {A@1}
        mov (1|M0)               r2.1<1>:f     r2.0<0;1,0>:hf                   {A@1}
        mov (1|M0)               r2.2<1>:ud    0xBD650000:ud                             
        sel (1|M0)    (lt)f0.0   r2.1<1>:f     r2.1<0;1,0>:f     4.0:f               {F@1}
        mov (1|M0)               r1.0<1>:ud    0x3EE50000:ud                             
(~f1.0) sel (1|M0)               r2.1<1>:f     r2.1<0;1,0>:f     -4.0:f               {F@1}
        mad (1|M0)               r2.2<1>:f     r1.0<0;0>:f       r2.2<0;0>:f       (abs)r2.1<0>:f   {A@1}
        mov (1|M0)               r1.0<2>:hf    r2.2<0;1,0>:f                    {F@1}
        mov (1|M0)               r1.0<1>:f     r1.0<0;1,0>:hf                   {F@1}
        mul (1|M0)               r2.1<1>:f     r2.1<0;1,0>:f     r1.0<0;1,0>:f    {Compacted,F@1}
        mov (1|M0)               r2.2<2>:hf    r2.1<0;1,0>:f                    {F@1}
        add (1|M0)               r2.2<1>:hf    r2.2<0;1,0>:hf    0x3B28:hf              {F@1}
        mul (1|M0)               r2.2<1>:hf    r2.2<0;1,0>:hf    r2.0<0;1,0>:hf   {F@1}
        mov (1|M0)               r2.0<1>:f     r2.2<0;1,0>:hf                   {F@1}
L29416:
        join (16|M0)                         L30096                                
L29432:
        cmp (1|M0)    (eq)f0.1   null<1>:d     r1.6<0;1,0>:d     1:w              
(W)     and (1|M0)               f0.1<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(f0.1.any16h) goto (16|M0)                   L29560                  L29560                
L29480:
        cmp (1|M0)    (eq)f0.0   null<1>:d     r5.2<0;1,0>:d     4:w              
        mov (1|M0)               r1.0<2>:hf    r2.0<0;1,0>:f                    {F@1}
        mov (1|M0)               r2.2<1>:f     r1.0<0;1,0>:hf                   {F@1}
(~f0.0) mov (1|M0)               r2.2<1>:f     r2.0<0;1,0>:f                   
        goto (16|M0)                         L29560                  L29984                
L29560:
        join (16|M0)                         L29984                                
L29576:
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
        cmp (1|M0)    (gt)f1.1   null<1>:f     r2.0<0;1,0>:f     0.5:f               {F@1}
(W)     and (1|M0)               f0.0<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(f0.0.any16h) goto (16|M0)                   L29888                  L29888                
L29800:
        cmp (1|M0)    (lt)f0.0   null<1>:f     r2.0<0;1,0>:f     0.5:f               {A@1}
        and (1|M0)               r2.3<1>:d     r2.3<0;1,0>:d     1:w               {Compacted}
        add (1|M0)               r2.4<1>:f     r2.2<0;1,0>:f     1.0:f              
(~f0.0) cmp (1|M0)    (eq)f0.0   null<1>:d     r2.3<0;1,0>:d     0:w               {A@1}
(~f0.0) mov (1|M0)               r2.2<1>:f     r2.4<0;1,0>:f                    {F@1}
        goto (16|M0)                         L29888                  L29920                
L29888:
        join (16|M0)                         L29920                                
L29904:
        add (1|M0)               r2.2<1>:f     r2.2<0;1,0>:f     1.0:f               {F@1}
L29920:
        join (16|M0)                         L29984                                
L29936:
        add (1|M0)               r2.1<1>:ud    r2.1<0;1,0>:ud    0xFE800000:ud             
        mul (1|M0)               r2.2<1>:f     r2.2<0;1,0>:f     r2.1<0;1,0>:f    {A@1}
(f0.1)  mov (1|M0)               r2.2<1>:f     -r2.2<0;1,0>:f                   {F@1}
L29984:
        join (16|M0)                         L30096                                
L30000:
        add (1|M0)               r1.2<1>:d     r1.2<0;1,0>:d     1:w              
        add (1|M0)               a0.0<1>:uw    r1.2<0;1,0>:uw    0x7A0:uw              {A@1}
        cmp (1|M0)    (eq)f1.0   null<1>:d     r1.2<0;1,0>:d     32:w               {I@2}
        mov (1|M0)               r[a0.0]<1>:f  r2.2<0;1,0>:f                    {F@1}
(W)     and (1|M0)               f1.1<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
(~f1.1.any16h) goto.b (16|M0)                L30096                  L29088                
L30096:
        join (16|M0)                         L30136                                
L30112:
        mov (16|M0)              r45.0<1>:ud   r61.0<1;1,0>:ud                  {F@1}
        mov (16|M0)              r47.0<1>:f    r63.0<1;1,0>:f                   {Compacted}
L30136:
        join (16|M0)                         L31472                                
L30152:
        cmp (1|M0)    (eq)f0.1   null<1>:w     r1.12<0;1,0>:b    0:w              
(W)     and (1|M0)               f1.0<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(f1.0.any16h) goto (16|M0)                   L31328                  L31328                
L30200:
        shl (1|M0)               r5.2<1>:d     r1.4<0;1,0>:d     1:w              
        shl (1|M0)               r1.1<1>:d     r1.5<0;1,0>:d     1:w              
        shr (1|M0)               r1.0<1>:ud    r1.4<0;1,0>:ud    0x1F:uw             
        addc (1|M0)              r5.0<1>:ud    r5.4<0;1,0>:ud    r5.2<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r5.3<1>:d     r1.1<0;1,0>:d     r1.0<0;1,0>:d    {I@2}
        mov (1|M0)               r1.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        add3 (1|M0)              r5.1<1>:d     r1.0<0;0>:d       r5.5<0;0>:d       r5.3<0>:d        {I@1}
        mov (4|M0)               r1.0<1>:w     0x64206420:v                              
        mov (8|M0)               r121.0<2>:f   r5.0<0;1,0>:f                    {Compacted}
        mov (4|M0)               r49.0<4>:uw   r1.0<1;1,0>:uw                   {I@1}
        mov (8|M0)               r121.1<2>:f   r5.1<0;1,0>:f                    {Compacted}
        mov (4|M0)               r1.0<2>:d     r49.0<4;1,0>:w                   {I@1}
        mov (8|M0)               r113.0<1>:hf  r45.0<1;1,0>:f                  
        asr (4|M0)               r1.1<2>:d     r1.0<2;1,0>:d     31:w               {I@1}
        mov (8|M0)               r113.8<1>:hf  r46.0<1;1,0>:f                  
        mov (4|M0)               r117.0<2>:ud  r1.0<2;1,0>:ud                   {I@1}
        mov (4|M0)               r117.1<2>:ud  r1.1<2;1,0>:ud                  
        mov (8|M0)               r108.0<1>:hf  r47.0<1;1,0>:f                   {F@5}
        addc (4|M0)              r4.0<1>:ud    r117.0<2;1,0>:ud  0x8:ud              {AccWrEn,I@1}
        mov (8|M0)               r108.8<1>:hf  r48.0<1;1,0>:f                  
        mov (4|M0)               r3.0<1>:ud    acc0.0<1;1,0>:ud                
        mov (4|M0)               r2.0<2>:d     r4.0<1;1,0>:d                    {I@2}
        addc (4|M0)              r4.0<1>:ud    r117.0<2;1,0>:ud  0x10:ud              {AccWrEn}
        add3 (4|M0)              r2.1<2>:d     r3.0<1;0>:d       r117.1<4;2>:d     0:w               {I@3}
        mov (4|M0)               r3.0<1>:ud    acc0.0<1;1,0>:ud                
        mov (4|M0)               r119.0<2>:d   r4.0<1;1,0>:d                    {I@3}
        addc (4|M0)              r4.0<1>:ud    r117.0<2;1,0>:ud  0x18:ud              {AccWrEn}
        add3 (4|M0)              r119.1<2>:d   r3.0<1;0>:d       r117.1<4;2>:d     0:w               {I@3}
        mov (4|M0)               r3.0<1>:ud    acc0.0<1;1,0>:ud                
        mov (4|M0)               r120.0<2>:d   r4.0<1;1,0>:d                    {I@3}
        addc (4|M0)              r4.0<1>:ud    r117.0<2;1,0>:ud  0x20:ud              {AccWrEn}
        add3 (4|M0)              r120.1<2>:d   r3.0<1;0>:d       r117.1<4;2>:d     0:w               {I@3}
        mov (4|M0)               r3.0<1>:ud    acc0.0<1;1,0>:ud                
        mov (4|M0)               r111.0<2>:d   r4.0<1;1,0>:d                    {I@3}
        addc (4|M0)              r4.0<1>:ud    r117.0<2;1,0>:ud  0x28:ud              {AccWrEn}
        add3 (4|M0)              r111.1<2>:d   r3.0<1;0>:d       r117.1<4;2>:d     0:w               {I@3}
        mov (4|M0)               r3.0<1>:ud    acc0.0<1;1,0>:ud                
        mov (4|M0)               r112.0<2>:d   r4.0<1;1,0>:d                    {I@3}
        addc (4|M0)              r4.0<1>:ud    r117.0<2;1,0>:ud  0x30:ud              {AccWrEn}
        add3 (4|M0)              r112.1<2>:d   r3.0<1;0>:d       r117.1<4;2>:d     0:w               {I@3}
        mov (4|M0)               r3.0<1>:ud    acc0.0<1;1,0>:ud                
        mov (4|M0)               r109.0<2>:d   r4.0<1;1,0>:d                    {I@3}
        addc (4|M0)              r4.0<1>:ud    r117.0<2;1,0>:ud  0x38:ud              {AccWrEn}
        add3 (4|M0)              r109.1<2>:d   r3.0<1;0>:d       r117.1<4;2>:d     0:w               {I@3}
        mov (4|M0)               r3.0<1>:ud    acc0.0<1;1,0>:ud                
        addc (8|M0)              r10.0<1>:ud   r121.0<2;1,0>:ud  r1.0<2;1,0>:ud   {AccWrEn,Compacted,A@5}
        mov (4|M0)               r110.0<2>:d   r4.0<1;1,0>:d                    {I@4}
        mov (8|M0)               r127.0<1>:ud  acc0.0<1;1,0>:ud                 {Compacted}
        addc (8|M0)              r16.0<1>:ud   r121.0<2;1,0>:ud  r119.0<2;1,0>:ud {AccWrEn,Compacted}
        add3 (4|M0)              r110.1<2>:d   r3.0<1;0>:d       r117.1<4;2>:d     0:w               {I@5}
        mov (8|M0)               r14.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        addc (8|M0)              r9.0<1>:ud    r121.0<2;1,0>:ud  r111.0<2;1,0>:ud {AccWrEn,Compacted}
        mov (8|M0)               r56.0<1>:d    r1.1<2;1,0>:d                   
        mov (8|M0)               r126.0<1>:ud  acc0.0<1;1,0>:ud                 {Compacted}
        addc (8|M0)              r15.0<1>:ud   r121.0<2;1,0>:ud  r109.0<2;1,0>:ud {AccWrEn,Compacted,I@5}
        mov (8|M0)               r54.0<1>:d    r119.1<2;1,0>:d                 
        mov (8|M0)               r52.0<1>:d    r111.1<2;1,0>:d                 
        mov (8|M0)               r50.0<1>:d    r109.1<2;1,0>:d                 
        mov (8|M0)               r13.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        add3 (8|M0)              r57.0<1>:d    r127.0<1;0>:d     r121.1<4;2>:d     r56.0<1>:d       {I@7}
        add3 (8|M0)              r55.0<1>:d    r14.0<1;0>:d      r121.1<4;2>:d     r54.0<1>:d       {I@5}
        add3 (8|M0)              r53.0<1>:d    r126.0<1;0>:d     r121.1<4;2>:d     r52.0<1>:d       {I@5}
        add3 (8|M0)              r51.0<1>:d    r13.0<1;0>:d      r121.1<4;2>:d     r50.0<1>:d       {I@4}
        mov (16|M0)              r124.0<1>:d   r113.0<1;1,0>:uw                 {A@3}
        mov (16|M0)              r11.0<1>:d    r108.0<1;1,0>:uw                 {A@1}
        mov (8|M0)               r90.0<2>:d    r10.0<1;1,0>:d                  
        mov (8|M0)               r92.0<2>:d    r16.0<1;1,0>:d                  
        mov (8|M0)               r59.0<2>:d    r15.0<1;1,0>:d                  
        mov (8|M0)               r90.1<2>:d    r57.0<1;1,0>:d                   {I@7}
        mov (8|M0)               r92.1<2>:d    r55.0<1;1,0>:d                   {I@7}
        mov (8|M0)               r59.1<2>:d    r51.0<1;1,0>:d                   {I@7}
        mov (8|M0)               r57.0<2>:d    r9.0<1;1,0>:d                   
        mov (8|M0)               r57.1<2>:d    r53.0<1;1,0>:d                  
        send.ugm (16|M0)         null     r90     r124:2  0x0            0x08000B84           {A@4,$15} // wr:4+2, rd:0; store.ugm.d16u32.a64
        send.ugm (16|M0)         null     r57     r11:2   0x0            0x08000B84           {A@1,$2} // wr:4+2, rd:0; store.ugm.d16u32.a64
        goto (16|M0)                         L31328                  L34576                
L31328:
        join (16|M0)                         L31472                                
L31344:
        shl (1|M0)               r1.0<1>:d     r1.4<0;1,0>:d     2:w               {Compacted}
        shl (1|M0)               r1.3<1>:d     r1.5<0;1,0>:d     2:w              
        shr (1|M0)               r1.2<1>:ud    r1.4<0;1,0>:ud    0x1E:uw             
        addc (1|M0)              r3.0<1>:ud    r5.6<0;1,0>:ud    r1.0<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r1.1<1>:d     r1.3<0;1,0>:d     r1.2<0;1,0>:d    {I@2}
        mov (1|M0)               r2.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        add3 (1|M0)              r3.1<1>:d     r2.0<0;0>:d       r5.7<0;0>:d       r1.1<0>:d        {I@1}
        send.ugm (1|M0)          null     r3      r45:4   0x0            0x0200E584           {A@1,$3} // wr:1+4, rd:0; store.ugm.d32x32t.a64
        goto (16|M0)                         L31472                  L34576                
L31472:
        join (16|M0)                         L32240                                
L31488:
(W)     and (1|M0)               f0.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
        shl (1|M0)               r3.0<1>:ud    r3.0<0;1,0>:ud    0x8:uw              {$3.src}
        add (1|M0)               r3.0<1>:ud    r3.0<0;1,0>:ud    0x7000:uw              {I@1}
(f0.1.any16h) goto (16|M0)                   L32240                  L34576                
L31552:
        shl (1|M0)               r3.4<1>:d     r3.6<0;1,0>:d     12:w              
        shr (1|M0)               r3.3<1>:ud    r3.5<0;1,0>:ud    0x14:uw             
        shl (1|M0)               r3.1<1>:d     r3.5<0;1,0>:d     12:w              
        or (1|M0)                r3.2<1>:d     r3.4<0;1,0>:d     r3.3<0;1,0>:d    {I@2}
        shr (1|M0)               r3.3<1>:ud    r3.1<0;1,0>:ud    0x1F:uw              {I@2}
        shl (1|M0)               r3.1<1>:d     r3.1<0;1,0>:d     1:w               {Compacted}
        shl (1|M0)               r2.0<1>:d     r30.1<0;1,0>:d    1:w               {Compacted}
        shl (1|M0)               r3.4<1>:d     r3.2<0;1,0>:d     1:w               {I@4}
        addc (1|M0)              r30.0<1>:ud   r4.2<0;1,0>:ud    r3.1<0;1,0>:ud   {AccWrEn,I@3}
        shr (1|M0)               r2.2<1>:ud    r30.1<0;1,0>:ud   0x1F:uw             
        or (1|M0)                r3.2<1>:d     r3.4<0;1,0>:d     r3.3<0;1,0>:d    {I@3}
        mov (1|M0)               r4.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        sync.allrd                           ($1,$11)                
        addc (1|M0)              r1.0<1>:ud    r30.0<0;1,0>:ud   r2.0<0;1,0>:ud   {AccWrEn,I@4}
        or (1|M0)                r2.1<1>:d     r2.2<0;1,0>:d     0:w               {I@4}
        add3 (1|M0)              r2.5<1>:d     r4.0<0;0>:d       r4.3<0;0>:d       r3.2<0>:d        {I@3}
        mov (1|M0)               r30.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r2.4<2>:f     0.0:f                              
        mov (1|M0)               r2.2<1>:d     r1.0<0;1,0>:d                    {I@4}
        add3 (1|M0)              r2.3<1>:d     r30.0<0;0>:d      r2.5<0;0>:d       r2.1<0>:d        {I@2}
        mov (1|M0)               r2.5<2>:f     0.0:f                               {I@1}
L31856:
        bfn.0xEA (1|M0)          r2.0<1>:ud    r2.4<0;0>:ud      r30.1<0;0>:ud     0x1E0:uw              {F@2} // s0|s1&s2
(W)     mov (1|M0)               r30.0<1>:f    9.401659e-38:f                              
        shl (1|M0)               r2.0<1>:ud    r2.0<0;1,0>:ud    0x2:uw              {I@1}
        shl (1|M0)               r2.1<1>:d     r2.5<0;1,0>:d     1:w               {F@2}
        bfn.0xEA (1|M0)          r30.0<1>:ud   r2.0<0;0>:ud      r3.0<0;0>:ud      r30.0<0>:ud      {A@1} // s0|s1&s2
        shl (1|M0)               r3.1<1>:d     r2.4<0;1,0>:d     1:w              
        send.slm (1|M0)          r30      r30     null:0  0x0            0x02100500           {A@2,$12} // wr:1+0, rd:1; load.slm.d32.a32
        shr (1|M0)               r2.0<1>:ud    r2.4<0;1,0>:ud    0x1F:uw             
        or (1|M0)                r3.2<1>:d     r2.1<0;1,0>:d     r2.0<0;1,0>:d    {I@1}
        addc (1|M0)              r2.0<1>:ud    r2.2<0;1,0>:ud    r3.1<0;1,0>:ud   {AccWrEn}
        mov (1|M0)               r2.12<2>:hf   r30.0<0;1,0>:f                   {$12.dst}
        mov (1|M0)               r30.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,F@1}
        add3 (1|M0)              r2.1<1>:d     r30.0<0;0>:d      r2.3<0;0>:d       r3.2<0>:d        {I@1}
        mov (1|M0)               r30.0<1>:d    r2.12<0;1,0>:uw                 
        send.ugm (1|M0)          null     r2      r30:1   0x0            0x04000B84           {A@1,$7} // wr:2+1, rd:0; store.ugm.d16u32.a64
        addc (1|M0)              r30.0<1>:ud   r2.4<0;1,0>:ud    0x1:ud              {AccWrEn,$7.src}
        mov (1|M0)               r2.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r2.6<1>:d     r30.0<0;1,0>:d                   {I@2}
        add3 (1|M0)              r2.7<1>:d     r2.0<0;0>:d       r2.5<0;0>:d       0:w               {I@2}
        cmp (1|M0)    (eq)f0.0   null<1>:d     r2.7<0;1,0>:d     0:w               {I@1}
(f0.0)  cmp (1|M0)    (eq)f0.0   null<1>:d     r2.6<0;1,0>:d     32:w              
(W)     and (1|M0)               f0.0<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
(f0.0.any16h) goto (16|M0)                   L32240                  L34576                
L32208:
(W)     mov (2|M0)               r2.4<1>:ud    r2.6<1;1,0>:ud                  
        goto.b (16|M0)                       L32240                  L31856                
L32240:
        join (16|M0)                         L33056                                
L32256:
(W)     and (1|M0)               f1.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
(f1.1.any16h) goto (16|M0)                   L33056                  L34576                
L32288:
        sync.allrd                           ($1,$11)                
        shl (1|M0)               r1.3<1>:d     r3.6<0;1,0>:d     12:w               {$5.src}
        shr (1|M0)               r1.2<1>:ud    r3.5<0;1,0>:ud    0x14:uw             
        shl (1|M0)               r1.0<1>:d     r3.5<0;1,0>:d     12:w               {Compacted}
        or (1|M0)                r1.1<1>:d     r1.3<0;1,0>:d     r1.2<0;1,0>:d    {I@2}
        shr (1|M0)               r1.3<1>:ud    r1.0<0;1,0>:ud    0x1F:uw              {I@2}
        shl (1|M0)               r1.4<1>:d     r1.1<0;1,0>:d     1:w               {I@2}
        shl (1|M0)               r1.1<1>:d     r1.0<0;1,0>:d     1:w               {Compacted}
        or (1|M0)                r1.2<1>:d     r1.4<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        addc (1|M0)              r4.0<1>:ud    r4.2<0;1,0>:ud    r1.1<0;1,0>:ud   {AccWrEn,I@2}
        shl (1|M0)               r1.7<1>:d     r1.6<0;1,0>:d     1:w              
        mov (1|M0)               r1.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        shr (1|M0)               r1.4<1>:ud    r1.5<0;1,0>:ud    0x1F:uw             
        add3 (1|M0)              r1.1<1>:d     r1.0<0;0>:d       r4.3<0;0>:d       r1.2<0>:d        {I@2}
        shl (1|M0)               r1.2<1>:d     r1.5<0;1,0>:d     1:w              
        or (1|M0)                r1.3<1>:d     r1.7<0;1,0>:d     r1.4<0;1,0>:d    {I@3}
        addc (1|M0)              r6.0<1>:ud    r4.0<0;1,0>:ud    r1.2<0;1,0>:ud   {AccWrEn,I@2}
        shr (1|M0)               r3.0<1>:ud    r3.0<0;1,0>:ud    0x2:uw              {$3.src}
        mov (1|M0)               r2.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        and (1|M0)               r6.1<1>:ud    r6.1<0;1,0>:ud    0xF0:uw             
        mov (1|M0)               r2.4<2>:f     0.0:f                              
        mov (1|M0)               r2.5<2>:f     0.0:f                              
        mov (1|M0)               r2.2<1>:d     r6.0<0;1,0>:d                    {I@4}
        add3 (1|M0)              r2.3<1>:d     r2.0<0;0>:d       r1.1<0;0>:d       r1.3<0>:d        {I@3}
L32640:
        shr (1|M0)               r2.1<1>:ud    r2.4<0;1,0>:ud    0x4:uw              {F@2}
        and (1|M0)               r2.0<1>:d     r2.4<0;1,0>:d     15:w               {Compacted}
        bfn.0xEA (1|M0)          r2.1<1>:ud    r2.1<0;0>:ud      r3.0<0;0>:ud      0x3FFC:uw              {I@2} // s0|s1&s2
        shl (1|M0)               r2.6<1>:d     r2.4<0;1,0>:d     1:w              
        shl (1|M0)               r2.1<1>:ud    r2.1<0;1,0>:ud    0x8:uw              {I@2}
        shl (1|M0)               r3.2<1>:d     r2.5<0;1,0>:d     1:w               {F@1}
        bfn.0xFE (1|M0)          r2.0<1>:ud    r2.0<0;0>:ud      r2.1<0;0>:ud      r6.1<0>:ud       {I@2} // s0|s1|s2
        shr (1|M0)               r3.1<1>:ud    r2.4<0;1,0>:ud    0x1F:uw             
        shl (1|M0)               r2.0<1>:ud    r2.0<0;1,0>:ud    0x1:uw              {I@2}
        addc (1|M0)              r1.0<1>:ud    r2.2<0;1,0>:ud    r2.6<0;1,0>:ud   {AccWrEn}
        add (1|M0)               r6.0<1>:ud    r2.0<0;1,0>:ud    0x5000:uw              {I@2}
        or (1|M0)                r2.7<1>:d     r3.2<0;1,0>:d     r3.1<0;1,0>:d   
        send.slm (1|M0)          r17      r6      null:0  0x0            0x0210B700           {A@2,$13} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$13.src}
        mov (1|M0)               r2.0<1>:f     r1.0<0;1,0>:f                    {Compacted}
        add3 (1|M0)              r2.1<1>:d     r6.0<0;0>:d       r2.3<0;0>:d       r2.7<0>:d        {I@1}
        mov (1|M0)               r6.0<1>:d     r17.0<0;1,0>:uw                  {$13.dst}
        send.ugm (1|M0)          null     r2      r6:1    0x0            0x04000B84           {A@1,$4} // wr:2+1, rd:0; store.ugm.d16u32.a64
        addc (1|M0)              r6.0<1>:ud    r2.4<0;1,0>:ud    0x1:ud              {AccWrEn,$4.src}
        mov (1|M0)               r2.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r2.6<1>:d     r6.0<0;1,0>:d                    {I@2}
        add3 (1|M0)              r2.7<1>:d     r2.0<0;0>:d       r2.5<0;0>:d       0:w               {I@2}
        cmp (1|M0)    (eq)f1.1   null<1>:d     r2.7<0;1,0>:d     0:w               {I@1}
(f1.1)  cmp (1|M0)    (eq)f1.1   null<1>:d     r2.6<0;1,0>:d     64:w              
(W)     and (1|M0)               f1.0<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(f1.0.any16h) goto (16|M0)                   L33056                  L34576                
L33024:
(W)     mov (2|M0)               r2.4<1>:ud    r2.6<1;1,0>:ud                  
        goto.b (16|M0)                       L33056                  L32640                
L33056:
        join (16|M0)                         L33856                                
L33072:
(W)     and (1|M0)               f0.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
(f0.1.any16h) goto (16|M0)                   L33856                  L34576                
L33104:
        sync.allrd                           ($1,$11)                
        shl (1|M0)               r1.5<1>:d     r3.6<0;1,0>:d     12:w               {$5.src}
        shr (1|M0)               r1.0<1>:ud    r3.5<0;1,0>:ud    0x14:uw             
        shl (1|M0)               r1.3<1>:d     r3.5<0;1,0>:d     12:w              
        or (1|M0)                r1.4<1>:d     r1.5<0;1,0>:d     r1.0<0;1,0>:d    {I@2}
        shl (1|M0)               r1.2<1>:ud    r3.0<0;1,0>:ud    0x6:uw             
        shr (1|M0)               r1.0<1>:ud    r1.3<0;1,0>:ud    0x1F:uw              {I@3}
        shl (1|M0)               r1.5<1>:d     r1.4<0;1,0>:d     1:w               {I@3}
        shl (1|M0)               r1.3<1>:d     r1.3<0;1,0>:d     1:w               {Compacted}
        or (1|M0)                r1.4<1>:d     r1.5<0;1,0>:d     r1.0<0;1,0>:d    {I@2}
        addc (1|M0)              r1.0<1>:ud    r4.2<0;1,0>:ud    r1.3<0;1,0>:ud   {AccWrEn,I@2}
        shl (1|M0)               r1.5<1>:d     r1.2<0;1,0>:d     1:w              
        shl (1|M0)               r1.1<1>:ud    r3.0<0;1,0>:ud    0x8:uw             
        shr (1|M0)               r1.3<1>:ud    r1.2<0;1,0>:ud    0x1F:uw             
        mov (1|M0)               r4.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        sync.nop                             null                             {Compacted,$3.src}
        addc (1|M0)              r3.0<1>:ud    r1.0<0;1,0>:ud    r1.5<0;1,0>:ud   {AccWrEn,I@4}
        or (1|M0)                r1.6<1>:d     r1.3<0;1,0>:d     0:w               {I@3}
        add3 (1|M0)              r2.1<1>:d     r4.0<0;0>:d       r4.3<0;0>:d       r1.4<0>:d        {I@3}
        mov (1|M0)               r1.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r1.7<2>:f     0.0:f                              
        add (1|M0)               r1.1<1>:ud    r1.1<0;1,0>:ud    0x7000:uw             
        mov (1|M0)               r1.3<1>:d     r3.0<0;1,0>:d                    {I@5}
        add3 (1|M0)              r1.4<1>:d     r1.0<0;0>:d       r2.1<0;0>:d       r1.6<0>:d        {I@3}
        mov (1|M0)               r1.6<2>:f     0.0:f                               {I@1}
L33472:
        bfn.0xEA (1|M0)          r2.0<1>:ud    r1.6<0;0>:ud      r1.2<0;0>:ud      0x3C0:uw              {F@1} // s0|s1&s2
(W)     mov (1|M0)               r1.0<1>:f     9.401659e-38:f                              
        shl (1|M0)               r2.0<1>:ud    r2.0<0;1,0>:ud    0x2:uw              {I@1}
        shl (1|M0)               r4.1<1>:d     r1.7<0;1,0>:d     1:w              
        bfn.0xEA (1|M0)          r1.0<1>:ud    r2.0<0;0>:ud      r1.1<0;0>:ud      r1.0<0>:ud       {A@1} // s0|s1&s2
        shr (1|M0)               r4.0<1>:ud    r1.6<0;1,0>:ud    0x1F:uw             
        send.slm (1|M0)          r1       r1      null:0  0x0            0x02100500           {A@1,$5} // wr:1+0, rd:1; load.slm.d32.a32
        shl (1|M0)               r4.3<1>:d     r1.6<0;1,0>:d     1:w               {$5.dst}
        or (1|M0)                r4.4<1>:d     r4.1<0;1,0>:d     r4.0<0;1,0>:d   
        addc (1|M0)              r4.0<1>:ud    r1.3<0;1,0>:ud    r4.3<0;1,0>:ud   {AccWrEn,I@2}
        mov (1|M0)               r2.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r4.4<2>:hf    r1.0<0;1,0>:f                   
        addc (1|M0)              r3.0<1>:ud    r1.6<0;1,0>:ud    0x1:ud              {AccWrEn}
        add3 (1|M0)              r4.1<1>:d     r2.0<0;0>:d       r1.4<0;0>:d       r4.4<0>:d        {I@2}
        mov (1|M0)               r2.0<1>:d     r4.4<0;1,0>:uw                   {F@1}
        mov (1|M0)               r2.2<1>:d     r3.0<0;1,0>:d                    {I@3}
        send.ugm (1|M0)          null     r4      r2:1    0x0            0x04000B84           {A@1,$8} // wr:2+1, rd:0; store.ugm.d16u32.a64
        mov (1|M0)               r2.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$8.src}
        add3 (1|M0)              r2.3<1>:d     r2.0<0;0>:d       r1.7<0;0>:d       0:w               {I@1}
        cmp (1|M0)    (eq)f1.0   null<1>:d     r2.3<0;1,0>:d     0:w               {I@1}
(f1.0)  cmp (1|M0)    (eq)f1.0   null<1>:d     r2.2<0;1,0>:d     64:w              
(W)     and (1|M0)               f0.0<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
(f0.0.any16h) goto (16|M0)                   L33856                  L34576                
L33824:
(W)     mov (2|M0)               r1.6<1>:ud    r2.2<1;1,0>:ud                  
        goto.b (16|M0)                       L33856                  L33472                
L33856:
        join (16|M0)                         L34576                                
L33872:
(W)     and (1|M0)               f1.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
(f1.1.any16h) goto (16|M0)                   L34576                  L34576                
L33904:
        shl (1|M0)               r3.1<1>:d     r3.6<0;1,0>:d     12:w               {$3.src}
        shr (1|M0)               r3.0<1>:ud    r3.5<0;1,0>:ud    0x14:uw             
        shl (1|M0)               r4.0<1>:d     r3.5<0;1,0>:d     12:w               {Compacted}
        or (1|M0)                r4.1<1>:d     r3.1<0;1,0>:d     r3.0<0;1,0>:d    {Compacted,I@2}
        shr (1|M0)               r2.0<1>:ud    r4.0<0;1,0>:ud    0x1F:uw              {I@2}
        shl (1|M0)               r2.1<1>:d     r4.0<0;1,0>:d     1:w               {Compacted}
        shl (1|M0)               r2.3<1>:d     r4.1<0;1,0>:d     1:w               {I@3}
        mov (1|M0)               r2.5<2>:f     0.0:f                              
        or (1|M0)                r2.2<1>:d     r2.3<0;1,0>:d     r2.0<0;1,0>:d    {I@1}
        addc (1|M0)              r2.0<1>:ud    r4.2<0;1,0>:ud    r2.1<0;1,0>:ud   {AccWrEn}
        shl (1|M0)               r2.3<1>:d     r1.6<0;1,0>:d     1:w              
        mov (1|M0)               r4.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        shr (1|M0)               r2.1<1>:ud    r1.6<0;1,0>:ud    0x1F:uw             
        addc (1|M0)              r3.0<1>:ud    r2.0<0;1,0>:ud    r2.3<0;1,0>:ud   {AccWrEn,I@3}
        add3 (1|M0)              r2.6<1>:d     r4.0<0;0>:d       r4.3<0;0>:d       r2.2<0>:d        {I@3}
        shl (1|M0)               r2.2<1>:d     r1.7<0;1,0>:d     1:w              
        mov (1|M0)               r2.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        or (1|M0)                r2.4<1>:d     r2.2<0;1,0>:d     r2.1<0;1,0>:d    {I@2}
        mov (1|M0)               r2.1<1>:d     r3.0<0;1,0>:d                   
        add3 (1|M0)              r2.2<1>:d     r2.0<0;0>:d       r2.6<0;0>:d       r2.4<0>:d        {I@2}
        mov (1|M0)               r2.4<2>:f     0.0:f                               {I@1}
L34200:
        addc (1|M0)              r3.0<1>:ud    r2.4<0;1,0>:ud    r1.6<0;1,0>:ud   {AccWrEn,F@1}
        cmp (1|M0)    (lt)f0.1   null<1>:ud    r2.4<0;1,0>:ud    0x7C0:uw             
        mov (1|M0)               r2.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        shl (1|M0)               r2.6<1>:d     r2.4<0;1,0>:d     1:w              
        add3 (1|M0)              r2.7<1>:d     r2.0<0;0>:d       r2.5<0;0>:d       r1.7<0>:d        {I@2}
        shl (1|M0)               r2.0<1>:d     r3.0<0;1,0>:d     1:w               {Compacted}
        shl (1|M0)               r3.1<1>:d     r2.5<0;1,0>:d     1:w              
        add (1|M0)               r2.0<1>:d     r2.0<0;1,0>:d     4096:w               {I@2}
        addc (1|M0)              r4.0<1>:ud    r2.1<0;1,0>:ud    r2.6<0;1,0>:ud   {AccWrEn}
        send.slm (1|M0)          r18      r2      null:0  0x0            0x0210B700           {A@2,$0} // wr:1+0, rd:1; load.slm.d64x4t.a32
(f0.1)  cmp (1|M0)    (eq)f0.1   null<1>:d     r2.5<0;1,0>:d     0:w              
        shr (1|M0)               r3.0<1>:ud    r2.4<0;1,0>:ud    0x1F:uw             
        sync.nop                             null                             {Compacted,$0.src}
        or (1|M0)                r2.7<1>:d     r3.1<0;1,0>:d     r3.0<0;1,0>:d    {I@1}
        mov (1|M0)               r3.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
(W)     and (1|M0)               f1.0<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
        add3 (1|M0)              r4.1<1>:d     r3.0<0;0>:d       r2.2<0;0>:d       r2.7<0>:d        {I@2}
        mov (1|M0)               r2.0<1>:d     r18.0<0;1,0>:uw                  {$0.dst}
        addc (1|M0)              r3.0<1>:ud    r2.4<0;1,0>:ud    0x40:ud              {AccWrEn}
        send.ugm (1|M0)          null     r4      r2:1    0x0            0x04000B84           {A@2,$9} // wr:2+1, rd:0; store.ugm.d16u32.a64
        mov (1|M0)               r2.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$9.src}
        mov (1|M0)               r2.6<1>:d     r3.0<0;1,0>:d                    {I@2}
        add3 (1|M0)              r2.7<1>:d     r2.0<0;0>:d       r2.5<0;0>:d       0:w               {I@2}
(~f1.0.any16h) goto (16|M0)                  L34576                  L34576                
L34544:
(W)     mov (2|M0)               r2.4<1>:ud    r2.6<1;1,0>:ud                   {I@2}
        goto.b (16|M0)                       L34576                  L34200                
L34576:
        join (16|M0)                         L34592                                
L34592:
(W)     mov (8|M0)               r112.0<1>:f   r0.0<1;1,0>:f                    {Compacted}
        sync.nop                             null                             {Compacted,$9.src}
(W)     send.ugm (1|M0)          r23      r0      null:0  0x0            0x0210641F           {$14} // wr:1+0, rd:1; fence invalid flush type scoped to tile
(W)     mov (8|M0)               null<1>:ud    r23.0<1;1,0>:ud                  {$14.dst}
(W)     send.gtwy (1|M0)         null     r112    null:0  0x0            0x02000010           {EOT,A@1} // wr:1+0, rd:0; end of thread
L34656:
        mov (1|M0)               r3.7<1>:d     cr0.0<0;1,0>:ud                  {A@1}
        and (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   -1265:w               {A@1}
        or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   1264:w               {A@1}
        mov (1|M0)               r6.0<1>:f     r6.1<0;1,0>:ud                   {Compacted,A@1}
        mov (1|M0)               r102.5<1>:f   r6.5<0;1,0>:ud                  
        math.inv (1|M0)          r6.3<1>:f     r6.0<0;1,0>:f                    {@2,$15}
        mov (1|M0)               r3.1<1>:f     0xB4C00000:f                               {Compacted}
        mov (1|M0)               r6.2<1>:ud    r102.5<0;1,0>:f                  {F@2}
        sync.nop                             null                             {Compacted,$15.dst}
        mad (1|M0)               r6.3<1>:f     r6.3<0;0>:f       r3.1<0;0>:f       r6.3<0>:f        {F@1}
        mov (1|M0)               r6.4<1>:ud    r6.0<0;1,0>:f                   
        add (1|M0)               r6.2<1>:ud    r6.5<0;1,0>:ud    -r6.2<0;1,0>:ud  {I@2}
        mul (1|M0)               r3.1<1>:f     r6.3<0;1,0>:f     r102.5<0;1,0>:f  {F@1}
        add (1|M0)               r6.4<1>:ud    r6.1<0;1,0>:ud    -r6.4<0;1,0>:ud  {I@2}
        mov (1|M0)               r6.6<1>:f     r6.2<0;1,0>:ud                   {I@2}
        mov (1|M0)               r6.2<1>:ud    r3.1<0;1,0>:f                    {A@1}
        mov (1|M0)               r102.4<1>:f   r6.4<0;1,0>:ud                   {I@2}
        mov (1|M0)               r6.7<1>:f     r6.2<0;1,0>:ud                   {I@1}
        mad (1|M0)               r102.5<1>:f   r102.5<0;0>:f     r6.7<0;0>:f       -r6.0<0>:f       {F@1}
        mad (1|M0)               r6.7<1>:f     r6.6<0;0>:f       r6.7<0;0>:f       -r102.4<0>:f    
        add (1|M0)               r102.5<1>:f   r102.5<0;1,0>:f   r6.7<0;1,0>:f    {F@1}
        mul (1|M0)               r6.3<1>:f     r6.3<0;1,0>:f     r102.5<0;1,0>:f  {F@1}
        mov (1|M0)               r3.1<1>:ud    r6.3<0;1,0>:f                    {F@1}
        add (1|M0)               r6.2<1>:ud    r6.2<0;1,0>:ud    r3.1<0;1,0>:ud   {I@1}
(W)     mov (1|M0)               r3.2<1>:hf    0x1:hf                              {I@1}
(W)     mul (1|M0)               acc0.0<1>:ud  r6.2<0;1,0>:ud    r6.2<0;1,0>:uw  
        mach (1|M0)              r6.0<1>:ud    r6.2<0;1,0>:ud    r6.1<0;1,0>:ud  
        add (1|M0)               r6.5<1>:ud    r6.5<0;1,0>:ud    -r6.0<0;1,0>:ud  {I@1}
        cmp (1|M0)    (ge)f1.1   null<1>:ud    r6.5<0;1,0>:ud    r6.1<0;1,0>:ud   {I@1}
(f1.1)  sel (1|M0)               r3.1<1>:d     r3.2<0;1,0>:w     0:w               {F@1}
        add (1|M0)               r6.0<1>:ud    r6.2<0;1,0>:ud    r3.1<0;1,0>:ud   {I@1}
        mov (1|M0)               cr0.0<1>:ud   r3.7<0;1,0>:d                    {A@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        ret (16|M0)                          r102.0                           {A@1}
L35192:
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
