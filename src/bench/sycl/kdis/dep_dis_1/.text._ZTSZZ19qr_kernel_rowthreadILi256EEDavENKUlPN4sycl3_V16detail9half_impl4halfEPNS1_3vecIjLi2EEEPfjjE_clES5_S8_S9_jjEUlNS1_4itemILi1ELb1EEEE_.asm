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
        mul (1|M0)               acc0.0<1>:ud  r2.0<0;1,0>:ud    r0.2<0;1,0>:uw   {A@1}
        mach (1|M0)              r5.0<1>:ud    r2.0<0;1,0>:ud    r0.1<0;1,0>:ud   {AccWrEn}
        mov (1|M0)               r1.2<1>:d     r1.0<0;1,0>:uw                   {$0.dst}
        mov (1|M0)               r4.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r2.3<1>:d     r2.6<0;1,0>:d                   
        addc (1|M0)              r6.0<1>:ud    r4.0<0;1,0>:ud    r1.2<0;1,0>:ud   {AccWrEn,I@2}
        mov (1|M0)               r114.2<1>:d   r6.0<0;1,0>:d                    {I@1}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mul (1|M0)               acc0.0<1>:ud  r114.2<0;1,0>:ud  r2.6<0;1,0>:uw   {I@2}
        mach (1|M0)              r9.0<1>:ud    r114.2<0;1,0>:ud  r2.3<0;1,0>:ud   {AccWrEn}
        add3 (1|M0)              r114.3<1>:d   r7.0<0;0>:d       r5.0<0;0>:d       0:w               {I@3}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r114.3<0;1,0>:d   r2.6<0;1,0>:uw   {I@2}
        mov (1|M0)               r114.0<1>:d   r8.0<0;1,0>:d                    {I@2}
        mach (1|M0)              r10.0<1>:d    r114.3<0;1,0>:d   r2.3<0;1,0>:d   
        shl (1|M0)               r1.4<1>:d     r114.0<0;1,0>:d   1:w               {Compacted,I@2}
        add3 (1|M0)              r114.1<1>:d   r10.0<0;0>:d      r9.0<0;0>:d       0:w               {I@2}
        addc (1|M0)              r4.0<1>:ud    r3.0<0;1,0>:ud    r1.4<0;1,0>:ud   {AccWrEn,I@2}
        shr (1|M0)               r1.3<1>:ud    r114.0<0;1,0>:ud  0x1F:uw             
        shl (1|M0)               r1.2<1>:d     r114.1<0;1,0>:d   1:w               {I@3}
        mov (1|M0)               r6.0<1>:d     r4.0<0;1,0>:d                    {I@3}
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@3}
        addc (1|M0)              r7.0<1>:ud    r6.0<0;1,0>:ud    0x100:ud              {AccWrEn,I@3}
        add3 (1|M0)              r6.1<1>:d     r5.0<0;0>:d       r3.1<0;0>:d       r1.5<0>:d        {I@2}
        mov (1|M0)               r19.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r8.0<1>:d     r7.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r8.1<1>:d     r19.0<0;0>:d      r6.1<0;0>:d       0:w               {I@2}
        send.ugm (1|M0)          r11      r6      null:0  0x0            0x0280E780           {$2} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        send.ugm (1|M0)          r20      r8      null:0  0x0            0x0280E780           {A@1,$3} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        mov (8|M0)               r38.0<1>:f    r11.0<1;1,0>:hf                  {$2.dst}
        mov (8|M0)               r39.0<1>:f    r11.8<1;1,0>:hf                 
        mov (8|M0)               r68.0<1>:f    r12.0<1;1,0>:hf                 
        mov (8|M0)               r69.0<1>:f    r12.8<1;1,0>:hf                 
        mov (8|M0)               r66.0<1>:f    r13.0<1;1,0>:hf                 
        mov (8|M0)               r67.0<1>:f    r13.8<1;1,0>:hf                 
        mov (8|M0)               r64.0<1>:f    r14.0<1;1,0>:hf                 
        mov (8|M0)               r65.0<1>:f    r14.8<1;1,0>:hf                 
        mov (8|M0)               r62.0<1>:f    r15.0<1;1,0>:hf                 
        mov (8|M0)               r63.0<1>:f    r15.8<1;1,0>:hf                 
        mov (8|M0)               r60.0<1>:f    r16.0<1;1,0>:hf                 
        mov (8|M0)               r61.0<1>:f    r16.8<1;1,0>:hf                 
        mov (8|M0)               r58.0<1>:f    r17.0<1;1,0>:hf                 
        mov (8|M0)               r59.0<1>:f    r17.8<1;1,0>:hf                 
        mov (8|M0)               r56.0<1>:f    r18.0<1;1,0>:hf                 
        mov (8|M0)               r57.0<1>:f    r18.8<1;1,0>:hf                 
        mov (8|M0)               r54.0<1>:f    r20.0<1;1,0>:hf                  {$3.dst}
        mov (8|M0)               r55.0<1>:f    r20.8<1;1,0>:hf                 
        mov (8|M0)               r52.0<1>:f    r21.0<1;1,0>:hf                 
        mov (8|M0)               r53.0<1>:f    r21.8<1;1,0>:hf                 
        mov (8|M0)               r50.0<1>:f    r22.0<1;1,0>:hf                 
        mov (8|M0)               r51.0<1>:f    r22.8<1;1,0>:hf                 
        mov (8|M0)               r48.0<1>:f    r23.0<1;1,0>:hf                 
        mov (8|M0)               r49.0<1>:f    r23.8<1;1,0>:hf                 
        mov (8|M0)               r46.0<1>:f    r24.0<1;1,0>:hf                 
        mov (8|M0)               r47.0<1>:f    r24.8<1;1,0>:hf                 
        mov (8|M0)               r44.0<1>:f    r25.0<1;1,0>:hf                 
        mov (8|M0)               r45.0<1>:f    r25.8<1;1,0>:hf                 
        mov (8|M0)               r42.0<1>:f    r26.0<1;1,0>:hf                 
        mov (8|M0)               r43.0<1>:f    r26.8<1;1,0>:hf                 
        mov (8|M0)               r40.0<1>:f    r27.0<1;1,0>:hf                 
        mov (8|M0)               r41.0<1>:f    r27.8<1;1,0>:hf                 
        sel (16|M0)   (ge)f0.0   r4.0<1>:f     (abs)r38.0<1;1,0>:f  (abs)r54.0<1;1,0>:f {Compacted}
        sel (16|M0)   (ge)f0.0   r6.0<1>:f     (abs)r68.0<1;1,0>:f  (abs)r52.0<1;1,0>:f {Compacted}
        sel (16|M0)   (ge)f0.0   r8.0<1>:f     (abs)r66.0<1;1,0>:f  (abs)r50.0<1;1,0>:f {Compacted}
        sel (16|M0)   (ge)f0.0   r10.0<1>:f    (abs)r64.0<1;1,0>:f  (abs)r48.0<1;1,0>:f {Compacted}
        sel (16|M0)   (ge)f0.0   acc0.0<1>:f   (abs)r62.0<1;1,0>:f  (abs)r46.0<1;1,0>:f {Compacted,F@7}
        sel (16|M0)   (ge)f0.0   acc2.0<1>:f   (abs)r60.0<1;1,0>:f  (abs)r44.0<1;1,0>:f {Compacted,F@7}
        sel (16|M0)   (ge)f0.0   r16.0<1>:f    (abs)r58.0<1;1,0>:f  (abs)r42.0<1;1,0>:f {Compacted,F@7}
        sel (16|M0)   (ge)f0.0   r18.0<1>:f    (abs)r56.0<1;1,0>:f  (abs)r40.0<1;1,0>:f {Compacted,F@7}
        sel (16|M0)   (ge)f0.0   r4.0<1>:f     r4.0<1;1,0>:f     acc0.0<1;1,0>:f  {F@7}
        sel (16|M0)   (ge)f0.0   r6.0<1>:f     r6.0<1;1,0>:f     acc2.0<1;1,0>:f  {F@7}
        sel (16|M0)   (ge)f0.0   acc0.0<1>:f   r8.0<1;1,0>:f     r16.0<1;1,0>:f   {Compacted,F@4}
        sel (16|M0)   (ge)f0.0   acc2.0<1>:f   r10.0<1;1,0>:f    r18.0<1;1,0>:f   {Compacted,F@4}
        sel (16|M0)   (ge)f0.0   acc0.0<1>:f   r4.0<1;1,0>:f     acc0.0<1;1,0>:f  {F@4}
        sel (16|M0)   (ge)f0.0   acc2.0<1>:f   r6.0<1;1,0>:f     acc2.0<1;1,0>:f  {F@4}
        sel (16|M0)   (ge)f0.0   r4.0<1>:f     acc0.0<1;1,0>:f   acc2.0<1;1,0>:f 
        sel (8|M0)    (ge)f0.0   r20.0<1>:f    r4.0<1;1,0>:f     r5.0<1;1,0>:f    {Compacted,F@1}
        mov (4|M0)               r21.0<1>:ud   r20.4<1;1,0>:ud                  {F@1}
        sel (4|M0)    (ge)f0.0   r22.0<1>:f    r20.0<1;1,0>:f    r21.0<1;1,0>:f   {I@1}
        mov (2|M0)               r23.0<1>:ud   r22.2<1;1,0>:ud                  {F@1}
        sel (2|M0)    (ge)f0.0   r24.0<1>:f    r22.0<1;1,0>:f    r23.0<1;1,0>:f   {I@1}
        sel (1|M0)    (ge)f0.0   r114.4<1>:f   r24.0<0;1,0>:f    r24.1<0;1,0>:f   {F@1}
        cmp (1|M0)    (eq)f1.0   null<1>:f     r114.4<0;1,0>:f   0.0:f               {F@1}
(W)     and (1|M0)               f0.0<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
(f0.0.any16h) goto (16|M0)                   L1544                  L1544                
L1464:
        mov (1|M0)               r114.5<1>:f   127.0:f                              
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r8.2          L7272                                 {A@1}
L1528:
        goto (16|M0)                         L1544                  L1568                
L1544:
        join (16|M0)                         L1568                                
L1560:
        mov (1|M0)               r8.0<1>:f     1.0:f                               {Compacted}
L1568:
        join (16|M0)                         L1584                                
L1584:
        shl (1|M0)               r1.4<1>:d     r114.2<0;1,0>:d   2:w              
        shl (1|M0)               r1.2<1>:d     r114.3<0;1,0>:d   2:w              
        shr (1|M0)               r1.3<1>:ud    r114.2<0;1,0>:ud  0x1E:uw             
        addc (1|M0)              r4.0<1>:ud    r3.2<0;1,0>:ud    r1.4<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (16|M0)              r76.0<1>:f    r8.0<0;1,0>:f                    {Compacted,F@1}
        mov (1|M0)               r6.0<1>:f     r4.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r6.1<1>:d     r5.0<0;0>:d       r3.3<0;0>:d       r1.5<0>:d        {I@1}
        mov (16|M0)              r72.0<1>:f    r76.0<1;1,0>:f                   {Compacted,F@2}
        send.ugm (1|M0)          null     r6      r8:1    0x0            0x04000584           {A@1,$4} // wr:2+1, rd:0; store.ugm.d32.a64
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r114.4        L4136                                 {A@1}
L1776:
        mov (16|M0)              r74.0<1>:ud   r36.0<1;1,0>:ud                 
        mov (16|M0)              r38.0<1>:f    r68.0<1;1,0>:f                   {Compacted}
        mov (16|M0)              r72.0<1>:f    r76.0<1;1,0>:f                   {Compacted}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r114.4        L4136                                 {A@1}
L1856:
        mov (16|M0)              r82.0<1>:ud   r36.0<1;1,0>:ud                 
        mov (16|M0)              r38.0<1>:f    r66.0<1;1,0>:f                   {Compacted}
        mov (16|M0)              r72.0<1>:f    r76.0<1;1,0>:f                   {Compacted}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r114.4        L4136                                 {A@1}
L1936:
        mov (16|M0)              r94.0<1>:ud   r36.0<1;1,0>:ud                 
        mov (16|M0)              r38.0<1>:f    r64.0<1;1,0>:f                   {Compacted}
        mov (16|M0)              r72.0<1>:f    r76.0<1;1,0>:f                   {Compacted}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r114.4        L4136                                 {A@1}
L2016:
        mov (16|M0)              r102.0<1>:ud  r36.0<1;1,0>:ud                 
        mov (16|M0)              r38.0<1>:f    r62.0<1;1,0>:f                   {Compacted}
        mov (16|M0)              r72.0<1>:f    r76.0<1;1,0>:f                   {Compacted}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r114.4        L4136                                 {A@1}
L2096:
        mov (16|M0)              r108.0<1>:ud  r36.0<1;1,0>:ud                 
        mov (16|M0)              r38.0<1>:f    r60.0<1;1,0>:f                   {Compacted}
        mov (16|M0)              r72.0<1>:f    r76.0<1;1,0>:f                   {Compacted}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r114.4        L4136                                 {A@1}
L2176:
        mov (16|M0)              r106.0<1>:ud  r36.0<1;1,0>:ud                 
        mov (16|M0)              r38.0<1>:f    r58.0<1;1,0>:f                   {Compacted}
        mov (16|M0)              r72.0<1>:f    r76.0<1;1,0>:f                   {Compacted}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r114.4        L4136                                 {A@1}
L2256:
        mov (16|M0)              r104.0<1>:ud  r36.0<1;1,0>:ud                 
        mov (16|M0)              r38.0<1>:f    r56.0<1;1,0>:f                   {Compacted}
        mov (16|M0)              r72.0<1>:f    r76.0<1;1,0>:f                   {Compacted}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r114.4        L4136                                 {A@1}
L2336:
        mov (16|M0)              r100.0<1>:ud  r36.0<1;1,0>:ud                 
        mov (16|M0)              r38.0<1>:f    r54.0<1;1,0>:f                   {Compacted}
        mov (16|M0)              r72.0<1>:f    r76.0<1;1,0>:f                   {Compacted}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r114.4        L4136                                 {A@1}
L2416:
        mov (16|M0)              r98.0<1>:ud   r36.0<1;1,0>:ud                 
        mov (16|M0)              r38.0<1>:f    r52.0<1;1,0>:f                   {Compacted}
        mov (16|M0)              r72.0<1>:f    r76.0<1;1,0>:f                   {Compacted}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r114.4        L4136                                 {A@1}
L2496:
        mov (16|M0)              r96.0<1>:ud   r36.0<1;1,0>:ud                 
        mov (16|M0)              r38.0<1>:f    r50.0<1;1,0>:f                   {Compacted}
        mov (16|M0)              r72.0<1>:f    r76.0<1;1,0>:f                   {Compacted}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r114.4        L4136                                 {A@1}
L2576:
        mov (16|M0)              r92.0<1>:ud   r36.0<1;1,0>:ud                 
        mov (16|M0)              r38.0<1>:f    r48.0<1;1,0>:f                   {Compacted}
        mov (16|M0)              r72.0<1>:f    r76.0<1;1,0>:f                   {Compacted}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r114.4        L4136                                 {A@1}
L2656:
        mov (16|M0)              r90.0<1>:ud   r36.0<1;1,0>:ud                 
        mov (16|M0)              r38.0<1>:f    r46.0<1;1,0>:f                   {Compacted}
        mov (16|M0)              r72.0<1>:f    r76.0<1;1,0>:f                   {Compacted}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r114.4        L4136                                 {A@1}
L2736:
        mov (16|M0)              r88.0<1>:ud   r36.0<1;1,0>:ud                 
        mov (16|M0)              r38.0<1>:f    r44.0<1;1,0>:f                   {Compacted}
        mov (16|M0)              r72.0<1>:f    r76.0<1;1,0>:f                   {Compacted}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r114.4        L4136                                 {A@1}
L2816:
        mov (16|M0)              r80.0<1>:ud   r36.0<1;1,0>:ud                 
        mov (16|M0)              r38.0<1>:f    r42.0<1;1,0>:f                   {Compacted}
        mov (16|M0)              r72.0<1>:f    r76.0<1;1,0>:f                   {Compacted}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r114.4        L4136                                 {A@1}
L2896:
        mov (16|M0)              r78.0<1>:ud   r36.0<1;1,0>:ud                 
        mov (16|M0)              r38.0<1>:f    r40.0<1;1,0>:f                   {Compacted}
        mov (16|M0)              r72.0<1>:f    r76.0<1;1,0>:f                   {Compacted}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r114.4        L4136                                 {A@1}
L2976:
        rnde (16|M0)             r74.0<1>:f    r74.0<1;1,0>:f                   {Compacted}
        rnde (16|M0)             r36.0<1>:f    r36.0<1;1,0>:f                   {Compacted,I@2}
        sel (16|M0)   (ge)f0.0   r74.0<1>:f    r74.0<1;1,0>:f    -127.0:f               {F@2}
        rnde (16|M0)             r82.0<1>:f    r82.0<1;1,0>:f                   {Compacted}
        rnde (16|M0)             r94.0<1>:f    r94.0<1;1,0>:f                   {Compacted}
        rnde (16|M0)             r102.0<1>:f   r102.0<1;1,0>:f                  {Compacted}
        rnde (16|M0)             r108.0<1>:f   r108.0<1;1,0>:f                  {Compacted}
        rnde (16|M0)             r106.0<1>:f   r106.0<1;1,0>:f                  {Compacted}
        rnde (16|M0)             r104.0<1>:f   r104.0<1;1,0>:f                  {Compacted}
        rnde (16|M0)             r100.0<1>:f   r100.0<1;1,0>:f                  {Compacted}
        rnde (16|M0)             r98.0<1>:f    r98.0<1;1,0>:f                   {Compacted}
        rnde (16|M0)             r96.0<1>:f    r96.0<1;1,0>:f                   {Compacted}
        rnde (16|M0)             r92.0<1>:f    r92.0<1;1,0>:f                   {Compacted}
        rnde (16|M0)             r90.0<1>:f    r90.0<1;1,0>:f                   {Compacted}
        rnde (16|M0)             r88.0<1>:f    r88.0<1;1,0>:f                   {Compacted}
        rnde (16|M0)             r80.0<1>:f    r80.0<1;1,0>:f                   {Compacted}
        rnde (16|M0)             r78.0<1>:f    r78.0<1;1,0>:f                   {Compacted}
        sel (16|M0)   (ge)f0.0   r36.0<1>:f    r36.0<1;1,0>:f    -127.0:f              
        sel (16|M0)   (lt)f0.0   r74.0<1>:f    r74.0<1;1,0>:f    127.0:f              
        sel (16|M0)   (ge)f0.0   r82.0<1>:f    r82.0<1;1,0>:f    -127.0:f              
        sel (16|M0)   (ge)f0.0   r94.0<1>:f    r94.0<1;1,0>:f    -127.0:f              
        sel (16|M0)   (ge)f0.0   r102.0<1>:f   r102.0<1;1,0>:f   -127.0:f              
        sel (16|M0)   (ge)f0.0   r108.0<1>:f   r108.0<1;1,0>:f   -127.0:f              
        sel (16|M0)   (ge)f0.0   r106.0<1>:f   r106.0<1;1,0>:f   -127.0:f              
        sel (16|M0)   (ge)f0.0   r104.0<1>:f   r104.0<1;1,0>:f   -127.0:f              
        sel (16|M0)   (ge)f0.0   r100.0<1>:f   r100.0<1;1,0>:f   -127.0:f              
        sel (16|M0)   (ge)f0.0   r98.0<1>:f    r98.0<1;1,0>:f    -127.0:f              
        sel (16|M0)   (ge)f0.0   r96.0<1>:f    r96.0<1;1,0>:f    -127.0:f              
        sel (16|M0)   (ge)f0.0   r92.0<1>:f    r92.0<1;1,0>:f    -127.0:f              
        sel (16|M0)   (ge)f0.0   r90.0<1>:f    r90.0<1;1,0>:f    -127.0:f              
        sel (16|M0)   (ge)f0.0   r88.0<1>:f    r88.0<1;1,0>:f    -127.0:f              
        sel (16|M0)   (ge)f0.0   r80.0<1>:f    r80.0<1;1,0>:f    -127.0:f              
        sel (16|M0)   (ge)f0.0   r78.0<1>:f    r78.0<1;1,0>:f    -127.0:f              
        sel (16|M0)   (lt)f0.0   r36.0<1>:f    r36.0<1;1,0>:f    127.0:f              
        mov (16|M0)              r4.0<1>:d     r74.0<1;1,0>:f                   {Compacted}
        sel (16|M0)   (lt)f0.0   r82.0<1>:f    r82.0<1;1,0>:f    127.0:f              
        sel (16|M0)   (lt)f0.0   r94.0<1>:f    r94.0<1;1,0>:f    127.0:f              
        sel (16|M0)   (lt)f0.0   r102.0<1>:f   r102.0<1;1,0>:f   127.0:f              
        sel (16|M0)   (lt)f0.0   r108.0<1>:f   r108.0<1;1,0>:f   127.0:f              
        sel (16|M0)   (lt)f0.0   r106.0<1>:f   r106.0<1;1,0>:f   127.0:f              
        sel (16|M0)   (lt)f0.0   r104.0<1>:f   r104.0<1;1,0>:f   127.0:f              
        sel (16|M0)   (lt)f0.0   r100.0<1>:f   r100.0<1;1,0>:f   127.0:f              
        sel (16|M0)   (lt)f0.0   r98.0<1>:f    r98.0<1;1,0>:f    127.0:f              
        sel (16|M0)   (lt)f0.0   r96.0<1>:f    r96.0<1;1,0>:f    127.0:f              
        sel (16|M0)   (lt)f0.0   r92.0<1>:f    r92.0<1;1,0>:f    127.0:f              
        sel (16|M0)   (lt)f0.0   r90.0<1>:f    r90.0<1;1,0>:f    127.0:f              
        sel (16|M0)   (lt)f0.0   r88.0<1>:f    r88.0<1;1,0>:f    127.0:f              
        sel (16|M0)   (lt)f0.0   r80.0<1>:f    r80.0<1;1,0>:f    127.0:f              
        sel (16|M0)   (lt)f0.0   r78.0<1>:f    r78.0<1;1,0>:f    127.0:f              
        mov (16|M0)              r34.0<1>:d    r36.0<1;1,0>:f                   {Compacted}
        mov (16|M0)              r36.0<1>:b    r4.0<4;1,0>:b                    {I@2}
        addc (1|M0)              r4.0<1>:ud    r3.4<0;1,0>:ud    r114.0<0;1,0>:ud {AccWrEn}
        mov (16|M0)              r6.0<1>:d     r82.0<1;1,0>:f                   {Compacted}
        mov (16|M0)              r8.0<1>:d     r94.0<1;1,0>:f                   {Compacted}
        mov (16|M0)              r10.0<1>:d    r102.0<1;1,0>:f                  {Compacted}
        mov (16|M0)              r12.0<1>:d    r108.0<1;1,0>:f                  {Compacted,F@7}
        mov (16|M0)              r14.0<1>:d    r106.0<1;1,0>:f                  {Compacted,F@7}
        mov (16|M0)              r16.0<1>:d    r104.0<1;1,0>:f                  {Compacted,F@7}
        mov (16|M0)              r18.0<1>:d    r100.0<1;1,0>:f                  {Compacted,F@7}
        mov (16|M0)              r20.0<1>:d    r98.0<1;1,0>:f                   {Compacted,F@7}
        mov (16|M0)              r22.0<1>:d    r96.0<1;1,0>:f                   {Compacted,F@6}
        mov (16|M0)              r24.0<1>:d    r92.0<1;1,0>:f                   {Compacted,F@5}
        mov (16|M0)              r26.0<1>:d    r90.0<1;1,0>:f                   {Compacted,F@4}
        mov (16|M0)              r28.0<1>:d    r88.0<1;1,0>:f                   {Compacted,F@3}
        mov (16|M0)              r30.0<1>:d    r80.0<1;1,0>:f                   {Compacted,F@2}
        mov (16|M0)              r32.0<1>:d    r78.0<1;1,0>:f                   {Compacted,F@1}
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (16|M0)              r43.16<1>:b   r34.0<4;1,0>:b                  
        mov (16|M0)              r36.16<1>:b   r6.0<4;1,0>:b                   
        mov (16|M0)              r37.0<1>:b    r8.0<4;1,0>:b                   
        mov (16|M0)              r37.16<1>:b   r10.0<4;1,0>:b                  
        mov (16|M0)              r38.0<1>:b    r12.0<4;1,0>:b                  
        mov (16|M0)              r38.16<1>:b   r14.0<4;1,0>:b                  
        mov (16|M0)              r39.0<1>:b    r16.0<4;1,0>:b                  
        mov (16|M0)              r39.16<1>:b   r18.0<4;1,0>:b                  
        mov (16|M0)              r40.0<1>:b    r20.0<4;1,0>:b                  
        mov (16|M0)              r40.16<1>:b   r22.0<4;1,0>:b                  
        mov (16|M0)              r41.0<1>:b    r24.0<4;1,0>:b                  
        mov (16|M0)              r41.16<1>:b   r26.0<4;1,0>:b                  
        mov (16|M0)              r42.0<1>:b    r28.0<4;1,0>:b                  
        mov (16|M0)              r42.16<1>:b   r30.0<4;1,0>:b                  
        mov (16|M0)              r43.0<1>:b    r32.0<4;1,0>:b                  
        mov (1|M0)               r6.0<1>:d     r4.0<0;1,0>:d                   
        add3 (1|M0)              r6.1<1>:d     r5.0<0;0>:d       r3.5<0;0>:d       r114.1<0>:d     
(W)     mov (8|M0)               r127.0<1>:ud  r0.0<1;1,0>:ud                  
        send.ugm (1|M0)          null     r6      r36:8   0x0            0x0200E784           {A@2,$5} // wr:1+8, rd:0; store.ugm.d64x32t.a64
(W)     send.ugm (1|M0)          r7       r0      null:0  0x0            0x0210641F           {$6} // wr:1+0, rd:1; fence invalid flush type scoped to tile
(W)     mov (8|M0)               null<1>:ud    r7.0<1;1,0>:ud                   {$6.dst}
(W)     send.gtwy (1|M0)         null     r127    null:0  0x0            0x02000010           {EOT,A@1} // wr:1+0, rd:0; end of thread
L4136:
(W)     shr (16|M0)              r4.0<1>:ud    r38.0<1;1,0>:ud   0x17:uw             
(W)     and (16|M0)              r32.0<1>:w    r4.0<2;1,0>:w     255:w               {I@1}
(W)     add (16|M0)              r8.0<1>:d     r32.0<1;1,0>:uw   -191:w               {I@1}
(W)     cmp (16|M0)   (lt)f1.0   null<1>:d     r8.0<1;1,0>:ud    0xFFFFFF82:ud              {I@1}
(W)     shr (16|M0)              r6.0<1>:ud    r72.0<1;1,0>:ud   0x17:uw             
(W)     mov (1|M0)               r114.4<1>:uw  f1.0<0;1,0>:uw                   {Compacted}
(W)     and (16|M0)              r31.0<1>:w    r6.0<2;1,0>:w     255:w               {I@2}
(W)     mov (1|M0)               f0.1<1>:uw    r114.4<0;1,0>:uw                 {I@2}
(W)     add (16|M0)              r10.0<1>:d    r31.0<1;1,0>:uw   -191:w               {I@2}
(W)     mov (16|M0)              r86.0<1>:d    r32.0<1;1,0>:uw                 
(W&~f0.1) cmp (16|M0) (lt)f0.1   null<1>:d     r10.0<1;1,0>:ud   0xFFFFFF81:ud              {I@2}
(W)     mov (16|M0)              r117.0<1>:d   r32.0<1;1,0>:uw                 
(W)     mov (1|M0)               r114.4<1>:uw  f0.1<0;1,0>:uw                  
(W)     mov (16|M0)              r115.0<1>:d   r31.0<1;1,0>:uw                 
(W)     mov (1|M0)               f0.0<1>:uw    r114.4<0;1,0>:uw                 {I@2}
(W)     mov (16|M0)              r112.0<1>:d   r31.0<1;1,0>:uw                 
(~f0.0.any16h) goto (16|M0)                  L6944                  L6944                
L4400:
(W)     add (16|M0)              r4.0<1>:d     r32.0<1;1,0>:uw   -255:w              
(W)     cmp (16|M0)   (lt)f0.0   null<1>:d     r4.0<1;1,0>:ud    0xFFFFFF02:ud              {I@1}
(W)     add (16|M0)              r6.0<1>:d     r31.0<1;1,0>:uw   -255:w              
(W&~f0.0) cmp (16|M0) (lt)f0.0   null<1>:d     r6.0<1;1,0>:ud    0xFFFFFF02:ud              {I@1}
(W)     mov (16|M0)              r119.0<1>:f   (abs)r38.0<1;1,0>:f              {Compacted}
(f0.0.any16h) goto (16|M0)                   L4560                  L4560                
L4488:
(W)     mov (16|M0)              r4.0<1>:f     (abs)r72.0<1;1,0>:f              {Compacted}
(W)     add (16|M0)              r119.0<1>:d   r119.0<1;1,0>:d   -r4.0<1;1,0>:d   {Compacted,A@1}
(W)     mov (4|M0)               r29.0<1>:d    0:w                              
(W)     mov (16|M0)              r70.0<1>:f    r38.0<1;1,0>:f                   {Compacted}
(W)     mov (16|M0)              r110.0<1>:f   r72.0<1;1,0>:f                   {Compacted}
(W)     asr (16|M0)              r119.0<1>:d   r119.0<1;1,0>:d   23:w               {Compacted,I@2}
        goto (16|M0)                         L4560                  L5816                
L4560:
        join (16|M0)                         L5816                                
L4576:
(W)     mov (16|M0)              r121.0<1>:f   (abs)r72.0<1;1,0>:f              {Compacted}
(W)     cmp (16|M0)   (gt)f1.1   null<1>:d     r119.0<1;1,0>:ud  0x7F800000:ud              {I@3}
(W)     cmp (16|M0)   (lt)f1.0   null<1>:d     r121.0<1;1,0>:ud  0x7F800001:ud              {F@1}
(W)     and (16|M0)              r125.0<1>:ud  r38.0<1;1,0>:ud   0x7F800000:ud             
(W)     mov (1|M0)               r1.3<1>:uw    f1.1<0;1,0>:uw                  
(W)     mov (1|M0)               r2.6<1>:uw    f1.0<0;1,0>:uw                   {Compacted}
(W)     or (1|M0)                f0.1<1>:uw    f1.0<0;1,0>:uw    r1.3<0;1,0>:uw   {I@2}
(W)     cmp (16|M0)   (ne)f1.0   null<1>:d     r125.0<1;1,0>:d   2139095040:d              
(W)     or (1|M0)                r3.12<1>:uw   f1.1<0;1,0>:uw    ~r2.6<0;1,0>:uw  {I@3}
(W)     mov (1|M0)               r8.0<1>:f     -0.0:f                               {Compacted}
(W)     or (1|M0)                r3.13<1>:uw   f1.0<0;1,0>:uw    r3.12<0;1,0>:uw  {I@1}
(W&f0.1) sel (16|M0)             acc0.0<1>:f   r38.0<1;1,0>:f    r72.0<1;1,0>:f  
(W)     mov (1|M0)               f0.1<1>:uw    r3.13<0;1,0>:uw                  {A@1}
(W)     and (16|M0)              r17.0<1>:ud   r72.0<1;1,0>:ud   0x7F800000:ud             
(W)     bfn.0x6A (16|M0)         r36.0<1>:ud   r38.0<1;0>:ud     r72.0<1;0>:ud     r8.0<0>:ud       // s0^s1&s2
(W)     bfn.0x6A (16|M0)         r9.0<1>:ud    r72.0<1;0>:ud     r38.0<1;0>:ud     r8.0<0>:ud       // s0^s1&s2
(W)     add (16|M0)              r36.0<1>:f    r36.0<1;1,0>:f    -r9.0<1;1,0>:f   {Compacted,A@1}
(W&f0.1) add (16|M0)             r36.0<1>:f    acc0.0<1;1,0>:f   r72.0<1;1,0>:f  
(W)     cmp (16|M0)   (ne)f0.1   null<1>:d     r17.0<1;1,0>:d    2139095040:d               {F@1}
(W)     or (1|M0)                r3.12<1>:uw   ~f1.0<0;1,0>:uw   r3.12<0;1,0>:uw 
(W)     cmp (16|M0)   (eq)f1.0   null<1>:f     r72.0<1;1,0>:f    0.0:f               {I@1}
(W)     or (1|M0)                r1.3<1>:uw    f0.1<0;1,0>:uw    r3.12<0;1,0>:uw 
(W)     or (1|M0)                r3.12<1>:uw   ~f0.1<0;1,0>:uw   r3.12<0;1,0>:uw 
(W)     mov (1|M0)               r2.6<1>:hf    -qnan(0x1FF):hf                             
(W)     mov (1|M0)               f0.1<1>:uw    r3.12<0;1,0>:uw                  {I@1}
(W)     and (1|M0)               r4.0<1>:uw    f1.0<0;1,0>:uw    ~r3.12<0;1,0>:uw
(W)     mov (1|M0)               f1.1<1>:uw    r1.3<0;1,0>:uw                  
(W)     and (16|M0)              r6.0<1>:ud    r72.0<1;1,0>:ud   0x80000000:ud             
(W&f0.1) sel (16|M0)             r11.0<2>:b    r2.6<0;1,0>:w     0:w               {F@1}
(W)     mov (1|M0)               f0.1<1>:uw    r4.0<0;1,0>:uw                   {I@4}
(W)     and (16|M0)              r123.0<1>:ud  r38.0<1;1,0>:ud   0x80000000:ud             
(W&~f1.1) mul (16|M0)            r36.0<1>:f    r6.0<1;1,0>:f     r38.0<1;1,0>:f   {I@4}
(W)     mov (16|M0)              r29.0<1>:b    r11.0<2;1,0>:b                   {I@3}
(~f0.1) goto (16|M0)                         L5208                  L5208                
L5088:
(W)     cmp (16|M0)   (eq)f1.0   null<1>:f     r38.0<1;1,0>:f    0.0:f              
(W)     mov (1|M0)               r1.2<1>:ud    0x7F800000:ud                             
(W)     mov (1|M0)               r2.12<2>:b    -1:w                              
(W&f1.0) mov (16|M0)             r123.0<1>:ud  0:w                              
(W)     bfn.0x96 (16|M0)         r123.0<1>:ud  r1.2<0;0>:ud      r123.0<1;0>:ud    r72.0<1>:ud      {I@1} // s0^s1^s2
(W&f1.0) mul (16|M0)             r123.0<1>:f   r123.0<1;1,0>:f   r38.0<1;1,0>:f   {I@1}
        mov (16|M0)              r29.0<1>:b    r2.12<0;1,0>:b                  
        mov (16|M0)              r36.0<1>:f    r123.0<1;1,0>:f                  {Compacted,F@1}
L5208:
        join (16|M0)                         L5816                                
L5224:
(W)     cmp (16|M0)   (eq)f0.1   null<1>:f     r38.0<1;1,0>:f    0.0:f              
(W&f0.1) cmp (16|M0)  (eq)f0.1   null<1>:w     r29.0<1;1,0>:ub   0x0:uw              {A@1}
(W&~f0.1) sel (16|M0)            r4.0<2>:b     r29.0<1;1,0>:b    -1:w              
(W)     mov (16|M0)              r29.0<1>:b    r4.0<2;1,0>:b                    {I@1}
(W)     cmp (16|M0)   (ne)f1.1   null<1>:w     r29.0<1;1,0>:ub   0x0:uw              {I@1}
(W&f0.1) mul (16|M0)             r36.0<1>:f    r38.0<1;1,0>:f    r72.0<1;1,0>:f  
(f1.1.all16h) goto (16|M0)                   L5816                  L6944                
L5336:
(W)     cmp (16|M0)   (eq)f1.1   null<1>:w     r29.0<1;1,0>:ub   0x0:uw             
(W)     mov (1|M0)               r1.3<1>:uw    f0.0<0;1,0>:uw                  
(W)     cmp (16|M0)   (eq)f1.0   null<1>:d     r125.0<1;1,0>:d   0:w              
(W)     and (1|M0)               f0.0<1>:uw    f1.1<0;1,0>:uw    r1.3<0;1,0>:uw   {I@2}
(W)     mov (16|M0)              r84.0<1>:d    0:w                              
(W)     mov (1|M0)               r2.6<1>:uw    f1.0<0;1,0>:uw                   {Compacted}
(W)     mov (16|M0)              r70.0<1>:f    r38.0<1;1,0>:f                   {Compacted}
(W)     and (1|M0)               f1.0<1>:uw    f0.0<0;1,0>:uw    r2.6<0;1,0>:uw   {I@1}
(W)     mov (16|M0)              r23.0<1>:f    r84.0<1;1,0>:f                   {Compacted}
(~f1.0) goto (16|M0)                         L5568                  L5568                
L5472:
        mul (16|M0)              r70.0<1>:f    r38.0<1;1,0>:f    0x4F800000:f               {Compacted}
(W)     shr (16|M0)              r4.0<1>:ud    r70.0<1;1,0>:ud   0x17:uw              {F@1}
(W)     and (16|M0)              r6.0<1>:w     r4.0<2;1,0>:w     255:w               {I@1}
        add (16|M0)              r117.0<1>:d   r6.0<1;1,0>:uw    -32:w               {I@1}
(W)     mov (16|M0)              r23.0<1>:d    0:w                              
(W)     mov (16|M0)              r86.0<1>:f    r117.0<1;1,0>:f                  {Compacted,I@2}
        mov (16|M0)              r23.0<1>:d    -32:w                              
L5568:
        join (16|M0)                         L5816                                
L5584:
(W)     cmp (16|M0)   (eq)f0.1   null<1>:d     r17.0<1;1,0>:d    0:w              
(W)     mov (16|M0)              r110.0<1>:f   r72.0<1;1,0>:f                   {Compacted}
(W)     mov (1|M0)               r1.3<1>:uw    f0.1<0;1,0>:uw                  
(W)     and (1|M0)               f0.1<1>:uw    f0.0<0;1,0>:uw    r1.3<0;1,0>:uw   {I@1}
(~f0.1) goto (16|M0)                         L5760                  L5760                
L5656:
        mul (16|M0)              r110.0<1>:f   r72.0<1;1,0>:f    0x4F800000:f               {Compacted}
(W)     shr (16|M0)              r4.0<1>:ud    r110.0<1;1,0>:ud  0x17:uw              {F@1}
(W)     and (16|M0)              r6.0<1>:w     r4.0<2;1,0>:w     255:w               {I@1}
        add (16|M0)              r112.0<1>:d   r6.0<1;1,0>:uw    -32:w               {I@1}
(W)     mov (16|M0)              r84.0<1>:d    0:w                              
(W)     mov (16|M0)              r121.0<1>:f   (abs)r110.0<1;1,0>:f             {Compacted}
(W)     mov (16|M0)              r115.0<1>:f   r112.0<1;1,0>:f                  {Compacted,I@2}
        mov (16|M0)              r84.0<1>:d    32:w                              
L5760:
        join (16|M0)                         L5816                                
L5776:
(W)     mov (16|M0)              r119.0<1>:f   (abs)r70.0<1;1,0>:f              {Compacted}
(W)     add (16|M0)              r119.0<1>:d   r119.0<1;1,0>:d   -r121.0<1;1,0>:d {Compacted,F@1}
(W)     asr (16|M0)              r119.0<1>:d   r119.0<1;1,0>:d   23:w               {Compacted,I@1}
(W)     add3 (16|M0)             r84.0<1>:d    r84.0<1;0>:d      r23.0<1;0>:d      r119.0<1>:d      {I@1}
L5816:
        join (16|M0)                         L6944                                
L5832:
(W)     mov (1|M0)               r1.2<1>:f     1.0:f                               {Compacted}
(W)     mov (1|M0)               r4.0<1>:f     0x807FFFFF:f                              
(W&~f0.0) mov (16|M0)            r84.0<1>:f    r119.0<1;1,0>:f                  {I@2}
(W)     bfn.0xEA (16|M0)         r110.0<1>:ud  r1.2<0;0>:ud      r110.0<1;0>:ud    r4.0<0>:ud       {A@2} // s0|s1&s2
(W)     add (16|M0)              r15.0<1>:d    r84.0<1;1,0>:d    126:w               {Compacted,F@1}
(W)     add (16|M0)              r5.0<1>:d     -r84.0<1;1,0>:d   -152:w               {Compacted}
        sync.nop                             null                             {Compacted,I@3}
(W)     math.inv (16|M0)         r7.0<1>:f     r110.0<1;1,0>:f                  {$7}
(W)     cmp (16|M0)   (eq)f0.0   null<1>:w     r29.0<1;1,0>:ub   0x0:uw             
(W)     and (16|M0)              r5.0<1>:d     r5.0<1;1,0>:d     r15.0<1;1,0>:d   {Compacted,I@2}
(W)     mov (1|M0)               r2.3<1>:f     1.0:f                               {Compacted}
(W)     bfn.0xEA (16|M0)         r70.0<1>:ud   r1.2<0;0>:ud      r70.0<1;0>:ud     r4.0<0>:ud       // s0|s1&s2
(W)     asr (16|M0)              r5.0<1>:d     r5.0<1;1,0>:d     31:w               {Compacted,I@2}
        sync.nop                             null                             {Compacted,$7.dst}
(W)     mad (16|M0)              r13.0<1>:f    r2.3<0;0>:f       r7.0<1;0>:f       -r110.0<1>:f     {F@1}
(W)     mul (16|M0)              acc0.0<1>:f   r7.0<1;1,0>:f     r70.0<1;1,0>:f   {Compacted,I@2}
(W&f0.0) sel (16|M0)             r30.0<1>:w    r5.0<4;1,0>:ub    0:w               {I@1}
(W)     mad (16|M0)              r13.0<1>:f    r7.0<1;0>:f       r7.0<1;0>:f       r13.0<1>:f       {Compacted,F@2}
(W)     mad (16|M0)              r11.0<1>:f    r70.0<1;0>:f      acc0.0<1;0>:f     -r110.0<1>:f    
(W)     cmp (16|M0)   (ne)f1.1   null<1>:w     r30.0<2;1,0>:ub   0x0:uw              {I@1}
(W)     mad (16|M0)              r11.0<1>:f    acc0.0<1;0>:f     r13.0<1;0>:f      r11.0<1>:f       {F@1}
(W)     add (16|M0)              r86.0<1>:d    r86.0<1;1,0>:d    -r115.0<1;1,0>:d {Compacted}
(W)     mad (16|M0)              r70.0<1>:f    r70.0<1;0>:f      r11.0<1;0>:f      -r110.0<1>:f     {Compacted,F@1}
(~f1.1.any16h) goto (16|M0)                  L6688                  L6688                
L6120:
(W)     mov (16|M0)              r19.0<1>:ud   r70.0<1;1,0>:ud                  {F@1}
(W)     mov (16|M0)              r27.0<1>:f    r13.0<1;1,0>:f                   {Compacted}
(W)     mov (16|M0)              r25.0<1>:f    r11.0<1;1,0>:f                   {Compacted}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r3.0          L7152                                 {A@1}
L6200:
(W)     add (16|M0)              r84.0<1>:d    r84.0<1;1,0>:d    125:w               {Compacted}
(W)     cmp (16|M0)   (lt)f0.0   null<1>:d     r84.0<1;1,0>:d    -2:w               {Compacted,I@1}
(W)     cmp (16|M0)   (eq)f0.1   null<1>:f     r70.0<1;1,0>:f    0.0:f              
(W)     mov (1|M0)               r1.3<1>:uw    f0.0<0;1,0>:uw                  
(W)     or (1|M0)                f1.0<1>:uw    f0.1<0;1,0>:uw    r1.3<0;1,0>:uw   {I@1}
(f1.0.any16h) goto (16|M0)                   L6328                  L6328                
L6280:
(W)     mov (1|M0)               r1.3<1>:hf    0x1:hf                              {I@2}
(W&f0.1) sel (16|M0)             r21.0<1>:d    r1.3<0;1,0>:w     0:w               {F@1}
        goto (16|M0)                         L6328                  L6448                
L6328:
        join (16|M0)                         L6448                                
L6344:
(W)     mov (1|M0)               r1.3<1>:hf    0x1:hf                              {I@3}
(W)     and (16|M0)              r4.0<1>:d     r19.0<1;1,0>:d    -2139095041:d              
(W)     mov (1|M0)               r6.0<1>:f     0x800000:f                               {Compacted}
(W)     shl (16|M0)              r15.0<1>:d    r15.0<1;1,0>:d    23:w               {Compacted}
(W&f0.1) sel (16|M0)             r21.0<1>:d    r1.3<0;1,0>:w     0:w               {F@2}
(W)     add (16|M0)              r15.0<1>:d    r15.0<1;1,0>:d    1065353216:d               {I@2}
(W)     bfn.0xFE (16|M0)         r4.0<1>:ud    r4.0<1;0>:ud      r21.0<1;0>:ud     r6.0<0>:ud       {A@1} // s0|s1|s2
(W)     mul (16|M0)              r15.0<1>:f    r15.0<1;1,0>:f    r4.0<1;1,0>:f    {Compacted,A@1}
L6448:
        join (16|M0)                         L6688                                
L6464:
(W)     and (16|M0)   (eq)f1.1   null<1>:ud    r19.0<1;1,0>:ud   0x400000:ud             
(W)     shl (16|M0)              r4.0<1>:d     r19.0<1;1,0>:d    1:w               {Compacted,F@1}
(W)     mov (1|M0)               r1.2<1>:f     0x800000:f                               {Compacted}
(W)     mov (1|M0)               r6.0<1>:f     -0.0:f                               {Compacted}
(W)     mov (1|M0)               r2.3<1>:f     1.469368e-38:f                               {Compacted}
(W)     and (16|M0)              r4.0<1>:d     r4.0<1;1,0>:d     8388606:d               {I@1}
(W)     bfn.0xEA (16|M0)         r7.0<1>:ud    r1.2<0;0>:ud      r19.0<1;0>:ud     r6.0<0>:ud       {A@2} // s0|s1&s2
(W&f1.1) sel (16|M0)             r9.0<1>:d     r2.3<0;1,0>:d     12582912:d               {F@1}
(W)     mov (1|M0)               r3.6<1>:f     0.25:f                               {Compacted}
(W)     bfn.0xFE (16|M0)         r21.0<1>:ud   r21.0<1;0>:ud     r7.0<1;0>:ud      r4.0<1>:ud       {I@2} // s0|s1|s2
(W)     bfn.0xEA (16|M0)         r9.0<1>:ud    r9.0<1;0>:ud      r19.0<1;0>:ud     r6.0<0>:ud       {I@2} // s0|s1&s2
(W)     mad (16|M0)              r21.0<1>:f    r9.0<1;0>:f       r21.0<1;0>:f      r3.6<0>:f        {Compacted,A@1}
(W)     add (16|M0)              r21.0<1>:f    r21.0<1;1,0>:f    -r7.0<1;1,0>:f   {Compacted,F@1}
(W)     mul (16|M0)              r7.0<1>:f     r7.0<1;1,0>:f     r7.0<1;1,0>:f    {Compacted}
(W)     bfn.0xAE (16|M0)         r21.0<1>:ud   r21.0<1;0>:ud     r7.0<1;0>:ud      0x1:uw              {A@1} // s0|s1&~s2
(W&~f1.0) mov (16|M0)            r15.0<1>:f    r21.0<1;1,0>:f                   {I@1}
(W)     and (16|M0)   (ne)f1.0   null<1>:w     r30.0<2;1,0>:ub   1:w               {F@1}
(W&f1.0) mov (16|M0)             r36.0<1>:f    r15.0<1;1,0>:f                  
L6688:
        join (16|M0)                         L6944                                
L6704:
(W)     add (16|M0)              r4.0<1>:d     r86.0<1;1,0>:d    -253:w               {Compacted}
(W)     cmp (16|M0)   (lt)f1.1   null<1>:d     r4.0<1;1,0>:ud    0xFFFFFE85:ud              {I@1}
(W)     mov (1|M0)               r1.3<1>:hf    -qnan(0x1FF):hf                             
(W)     asr (16|M0)              r6.0<1>:d     r86.0<1;1,0>:d    11:w               {Compacted}
(W&f1.1.any16h) sel (1|M0)       r2.6<1>:w     r1.3<0;1,0>:w     0:w               {F@1}
(W)     add (16|M0)              r8.0<1>:d     r6.0<1;1,0>:d     248:w               {Compacted,I@2}
(W)     mov (1|M0)               f0.1<1>:uw    r2.6<0;1,0>:uw                   {I@2}
(W)     mad (16|M0)              r70.0<1>:f    r11.0<1;0>:f      r13.0<1;0>:f      r70.0<1>:f       {Compacted}
(W)     mov (16|M0)              r10.0<1>:f    r86.0<1;1,0>:f                   {Compacted}
(W&f1.1) xor (16|M0)             r10.0<1>:d    r8.0<1;1,0>:d     r6.0<1;1,0>:d    {A@1}
(W&~f0.1) mov (16|M0)            r10.0<1>:f    r86.0<1;1,0>:f                   {I@1}
(W)     asr (16|M0)              r12.0<1>:d    r10.0<1;1,0>:d    1:w               {Compacted,F@1}
(W)     mov (16|M0)              r4.0<1>:uw    r29.0<1;1,0>:ub                 
(W)     add (16|M0)              r10.0<1>:d    r10.0<1;1,0>:d    -r12.0<1;1,0>:d  {Compacted,I@2}
(W)     or (16|M0)    (eq)f0.0   null<1>:w     r30.0<2;1,0>:ub   r4.0<1;1,0>:uw   {I@2}
(W)     shl (16|M0)              r12.0<1>:d    r12.0<1;1,0>:d    23:w               {Compacted}
(W)     shl (16|M0)              r10.0<1>:d    r10.0<1;1,0>:d    23:w               {Compacted,I@3}
(W)     add (16|M0)              r12.0<1>:d    r12.0<1;1,0>:d    r70.0<1;1,0>:d   {Compacted,I@2}
(W)     add (16|M0)              r10.0<1>:d    r10.0<1;1,0>:d    1065353216:d               {I@2}
(W&f0.0) mul (16|M0)             r36.0<1>:f    r12.0<1;1,0>:f    r10.0<1;1,0>:f   {A@1}
L6944:
        join (16|M0)                         L6960                                
L6960:
(W)     math.inv (16|M0)         r4.0<1>:f     r72.0<1;1,0>:f                   {$8}
(W)     mov (1|M0)               r1.2<1>:ud    0x3F800000:ud                             
(W)     mul (16|M0)              acc0.0<1>:f   r4.0<1;1,0>:f     r38.0<1;1,0>:f   {Compacted,$8.dst}
(W)     mad (16|M0)              acc2.0<1>:f   r1.2<0;0>:f       r4.0<1;0>:f       -r72.0<1>:f      {I@1}
(W)     mad (16|M0)              r10.0<1>:f    r38.0<1;0>:f      acc0.0<1;0>:f     -r72.0<1>:f     
(W)     mad (16|M0)              acc2.0<1>:f   r4.0<1;0>:f       acc2.0<1;0>:f     r4.0<1>:f        {Compacted}
(W)     mov (1|M0)               f1.1<1>:uw    r114.4<0;1,0>:uw                
(W)     mad (16|M0)              acc0.0<1>:f   acc0.0<1;0>:f     acc2.0<1;0>:f     r10.0<1>:f       {F@2}
(W)     mad (16|M0)              r38.0<1>:f    r38.0<1;0>:f      acc0.0<1;0>:f     -r72.0<1>:f     
(W&~f1.1) mad (16|M0)            r36.0<1>:f    acc0.0<1;0>:f     acc2.0<1;0>:f     r38.0<1>:f       {F@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        ret (16|M0)                          r114.4                           {A@1}
L7152:
(W)     mov (1|M0)               r1.2<1>:d     cr0.0<0;1,0>:ud                  {A@1}
(W)     and (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   -1265:w               {A@1}
(W)     or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   1264:w               {A@1}
(W)     mad (16|M0)              r19.0<1>:f    r25.0<1;0>:f      r27.0<1;0>:f      r19.0<1>:f       {Compacted,A@1}
(W)     mov (1|M0)               cr0.0<1>:ud   r1.2<0;1,0>:d                    {A@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        ret (16|M0)                          r3.0                             {A@1}
L7272:
        shr (1|M0)               r6.1<1>:ud    r114.5<0;1,0>:ud  0x17:uw             
        shr (1|M0)               r8.1<1>:ud    r114.4<0;1,0>:ud  0x17:uw             
        and (1|M0)               r6.1<1>:ud    r6.1<0;1,0>:ud    0xFF:uw              {I@2}
        and (1|M0)               r8.1<1>:ud    r8.1<0;1,0>:ud    0xFF:uw              {I@2}
        add (1|M0)               r1.3<1>:ud    r6.1<0;1,0>:ud    0xFFFFFF41:ud              {I@2}
        add (1|M0)               r1.2<1>:ud    r8.1<0;1,0>:ud    0xFFFFFF41:ud              {I@2}
        cmp (1|M0)    (lt)f1.1   null<1>:ud    r1.3<0;1,0>:ud    0xFFFFFF81:ud              {A@2}
(W)     mov (1|M0)               r2.6<1>:hf    -qnan(0x1FF):hf                             
(~f1.1) cmp (1|M0)    (lt)f1.1   null<1>:ud    r1.2<0;1,0>:ud    0xFFFFFF82:ud              {I@2}
(f1.1)  sel (1|M0)               r8.24<2>:b    r2.6<0;1,0>:w     0:w               {F@1}
        cmp (1|M0)    (ne)f1.1   null<1>:uw    r8.24<0;1,0>:ub   0x0:uw              {I@1}
(W)     and (1|M0)               f1.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(~f1.1.any16h) goto (16|M0)                  L10992                  L10992                
L7480:
        add (1|M0)               r1.3<1>:ud    r6.1<0;1,0>:ud    0xFFFFFF01:ud             
        add (1|M0)               r1.2<1>:ud    r8.1<0;1,0>:ud    0xFFFFFF01:ud             
        cmp (1|M0)    (lt)f1.0   null<1>:ud    r1.3<0;1,0>:ud    0xFFFFFF02:ud              {I@2}
(W)     mov (1|M0)               r2.6<1>:hf    -qnan(0x1FF):hf                             
        mov (1|M0)               r8.7<1>:f     (abs)r114.4<0;1,0>:f            
(~f1.0) cmp (1|M0)    (lt)f1.0   null<1>:ud    r1.2<0;1,0>:ud    0xFFFFFF02:ud              {I@2}
(f1.0)  sel (1|M0)               r6.0<2>:b     r2.6<0;1,0>:w     0:w               {F@2}
        cmp (1|M0)    (ne)f0.1   null<1>:uw    r6.0<0;1,0>:ub    0x0:uw              {I@1}
(W)     and (1|M0)               f1.0<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(f1.0.any16h) goto (16|M0)                   L7736                  L7736                
L7640:
        mov (1|M0)               r1.2<1>:f     (abs)r114.5<0;1,0>:f            
        mov (1|M0)               r114.24<2>:b  0:w                              
        add (1|M0)               r8.7<1>:d     r8.7<0;1,0>:d     -r1.2<0;1,0>:d   {A@1}
        mov (2|M0)               r8.4<1>:f     r114.4<1;1,0>:f                 
        asr (1|M0)               r8.7<1>:d     r8.7<0;1,0>:d     23:w               {I@1}
        goto (16|M0)                         L7736                  L9456                
L7736:
        join (16|M0)                         L9456                                
L7752:
        cmp (1|M0)    (gt)f0.0   null<1>:ud    r8.7<0;1,0>:ud    0x7F800000:ud              {I@3}
(W)     mov (1|M0)               r1.3<1>:hf    0xFF:hf                             
        mov (1|M0)               r114.7<1>:f   (abs)r114.5<0;1,0>:f            
(W)     mov (1|M0)               r2.7<1>:hf    -qnan(0x1FF):hf                             
(f0.0)  sel (1|M0)               r2.6<1>:w     r1.3<0;1,0>:w     0:w               {F@3}
        and (1|M0)               r6.3<1>:ud    r114.4<0;1,0>:ud  0x7F800000:ud             
        cmp (1|M0)    (eq)f0.1   null<1>:w     r2.12<0;1,0>:b    0:w               {I@2}
(W)     mov (1|M0)               r3.12<1>:uw   r2.12<0;1,0>:ub                 
        and (1|M0)               r6.2<1>:ud    r114.5<0;1,0>:ud  0x7F800000:ud             
        add (1|M0)               r8.0<1>:f     r114.4<0;1,0>:f   r114.5<0;1,0>:f 
(f0.1)  cmp (1|M0)    (gt)f0.1   null<1>:ud    r114.7<0;1,0>:ud  0x7F800000:ud              {F@3}
(W)     mov (1|M0)               r5.0<1>:f     -0.0:f                               {Compacted}
        and (1|M0)               r4.0<1>:ud    r114.5<0;1,0>:ud  0x80000000:ud             
        bfn.0x6A (1|M0)          r1.2<1>:ud    r114.4<0;0>:ud    r114.5<0;0>:ud    r5.0<0>:ud       {F@1} // s0^s1&s2
(f0.1)  sel (1|M0)               r2.16<2>:b    r2.7<0;1,0>:w     0:w              
        bfn.0x6A (1|M0)          r1.3<1>:ud    r114.5<0;0>:ud    r114.4<0;0>:ud    r5.0<0>:ud       // s0^s1&s2
        and (1|M0)    (ne)f1.0   null<1>:w     r2.16<0;1,0>:ub   1:w               {I@2}
        or (1|M0)     (eq)f0.0   r2.16<2>:ub   r2.16<0;1,0>:ub   r3.12<0;1,0>:uw 
        and (1|M0)               r6.4<1>:ud    r114.4<0;1,0>:ud  0x80000000:ud             
(f1.0)  add (1|M0)               r8.0<1>:f     r114.5<0;1,0>:f   r114.5<0;1,0>:f 
(f0.0)  cmp (1|M0)    (eq)f0.0   null<1>:d     r6.3<0;1,0>:d     2139095040:d              
(W)     mov (1|M0)               r4.2<1>:uw    r2.16<0;1,0>:ub                  {I@3}
(f0.0)  sel (1|M0)               r1.6<2>:b     r2.7<0;1,0>:w     0:w              
        and (1|M0)    (ne)f0.1   null<1>:w     r1.6<0;1,0>:ub    1:w               {I@1}
        or (1|M0)     (eq)f1.1   r1.6<2>:ub    r1.6<0;1,0>:ub    r4.2<0;1,0>:uw  
(f0.1)  add (1|M0)               r8.0<1>:f     r1.2<0;1,0>:f     -r1.3<0;1,0>:f  
(f1.1)  cmp (1|M0)    (eq)f1.1   null<1>:d     r6.2<0;1,0>:d     2139095040:d              
(W)     mov (1|M0)               r3.12<1>:uw   r1.6<0;1,0>:ub                   {I@2}
(f1.1)  sel (1|M0)               r6.2<2>:b     r2.7<0;1,0>:w     0:w              
        and (1|M0)    (ne)f0.0   null<1>:w     r6.2<0;1,0>:ub    1:w               {I@1}
        or (1|M0)     (eq)f1.0   r6.2<2>:ub    r6.2<0;1,0>:ub    r3.12<0;1,0>:uw  {F@2}
(f0.0)  mul (1|M0)               r8.0<1>:f     r4.0<0;1,0>:f     r114.4<0;1,0>:f 
(f1.0)  cmp (1|M0)    (eq)f1.0   null<1>:f     r114.5<0;1,0>:f   0.0:f               {I@1}
(f1.0)  sel (1|M0)               r3.2<2>:b     r2.7<0;1,0>:w     0:w              
        cmp (1|M0)    (ne)f1.1   null<1>:uw    r3.2<0;1,0>:ub    0x0:uw              {I@1}
(W)     and (1|M0)               f0.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw              {F@3}
(f0.1.any16h) goto (16|M0)                   L8368                  L8368                
L8336:
        mov (1|M0)               r3.0<2>:b     r6.2<0;1,0>:b                   
        goto (16|M0)                         L8368                  L8552                
L8368:
        join (16|M0)                         L8552                                
L8384:
(W)     mov (1|M0)               r4.0<1>:f     inf:f                               {Compacted}
        cmp (1|M0)    (eq)f1.0   null<1>:f     r114.4<0;1,0>:f   0.0:f              
        bfn.0x96 (1|M0)          r6.4<1>:ud    r6.4<0;0>:ud      r114.5<0;0>:ud    r4.0<0>:ud       {F@2} // s0^s1^s2
        xor (1|M0)               r1.2<1>:ud    r114.5<0;1,0>:ud  0x7F800000:ud             
(W)     mov (1|M0)               r2.6<1>:uw    r6.2<0;1,0>:ub                  
(~f1.0) mov (1|M0)               r1.2<1>:f     r6.4<0;1,0>:f                    {A@2}
        or (1|M0)                r6.2<2>:ub    r3.2<0;1,0>:ub    r2.6<0;1,0>:uw   {I@1}
(f1.0)  mul (1|M0)               r6.4<1>:f     r1.2<0;1,0>:f     r114.4<0;1,0>:f  {F@1}
        and (1|M0)    (ne)f1.0   null<1>:w     r3.2<0;1,0>:ub    1:w               {F@1}
        mov (1|M0)               r3.0<2>:b     r6.2<0;1,0>:b                    {I@2}
(f1.0)  mov (1|M0)               r8.0<1>:f     r6.4<0;1,0>:f                   
L8552:
        join (16|M0)                         L9456                                
L8568:
        cmp (1|M0)    (eq)f0.1   null<1>:w     r6.2<0;1,0>:b     0:w              
(W)     mov (1|M0)               r1.3<1>:hf    -qnan(0x1FF):hf                             
(W)     mov (1|M0)               r2.6<1>:uw    r3.0<0;1,0>:ub                   {I@3}
(f0.1)  cmp (1|M0)    (eq)f0.1   null<1>:f     r114.4<0;1,0>:f   0.0:f               {I@2}
(f0.1)  sel (1|M0)               r114.24<2>:b  r1.3<0;1,0>:w     0:w               {F@2}
        and (1|M0)    (ne)f0.1   null<1>:w     r114.24<0;1,0>:ub  1:w              {A@1}
        or (1|M0)     (ne)f0.0   r114.24<2>:ub  r114.24<0;1,0>:ub  r2.6<0;1,0>:uw
(f0.1)  mul (1|M0)               r8.0<1>:f     r114.4<0;1,0>:f   r114.5<0;1,0>:f 
(W)     and (1|M0)               f0.0<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
(f0.0.any16h) goto (16|M0)                   L9456                  L10992                
L8728:
        cmp (1|M0)    (eq)f1.1   null<1>:uw    r114.24<0;1,0>:ub  0x0:uw             {I@3}
        cmp (1|M0)    (eq)f1.0   null<1>:d     r6.3<0;1,0>:d     0:w              
(~f1.1) mov (1|M0)               r6.0<2>:b     0:w                              
(f1.0)  sel (1|M0)               r3.1<1>:d     r6.0<0;1,0>:b     0:w               {I@1}
        cmp (1|M0)    (ne)f0.1   null<1>:d     r3.1<0;1,0>:d     0:w               {A@1}
(W)     and (1|M0)               f1.1<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(f1.1.any16h) goto (16|M0)                   L8888                  L8888                
L8840:
        mov (1|M0)               r3.0<1>:d     0:w                              
        mov (1|M0)               r8.4<1>:f     r114.4<0;1,0>:f                 
        goto (16|M0)                         L8888                  L9048                
L8888:
        join (16|M0)                         L9048                                
L8904:
        and (1|M0)    (ne)f0.0   r3.1<1>:d     r3.1<0;1,0>:d     1:w              
        mov (1|M0)               r8.4<1>:f     r114.4<0;1,0>:f                 
(W)     mov (1|M0)               r2.6<1>:hf    -qnan(0x1E0):hf                             
(f0.0)  mul (1|M0)               r8.4<1>:f     r114.4<0;1,0>:f   0x4F800000:f              
(f0.0)  sel (1|M0)               r3.0<1>:d     r2.6<0;1,0>:w     0:w               {F@2}
        shr (1|M0)               r1.2<1>:ud    r8.4<0;1,0>:ud    0x17:uw              {F@1}
        and (1|M0)               r1.2<1>:ud    r1.2<0;1,0>:ud    0xFF:uw              {I@1}
        add (1|M0)               r1.2<1>:ud    r1.2<0;1,0>:ud    0xFFFFFFE0:ud              {I@1}
(f0.0)  mov (1|M0)               r8.1<1>:d     r1.2<0;1,0>:d                    {I@1}
L9048:
        join (16|M0)                         L9456                                
L9064:
        cmp (1|M0)    (eq)f0.0   null<1>:d     r6.2<0;1,0>:d     0:w              
(f0.0)  sel (1|M0)               r3.6<1>:d     r6.0<0;1,0>:b     0:w              
        cmp (1|M0)    (ne)f1.1   null<1>:d     r3.6<0;1,0>:d     0:w               {I@1}
(W)     and (1|M0)               f1.0<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(f1.0.any16h) goto (16|M0)                   L9192                  L9192                
L9144:
        mov (1|M0)               r3.1<1>:d     0:w                              
        mov (1|M0)               r8.5<1>:f     r114.5<0;1,0>:f                 
        goto (16|M0)                         L9192                  L9368                
L9192:
        join (16|M0)                         L9368                                
L9208:
        and (1|M0)    (ne)f1.1   r3.6<1>:d     r3.6<0;1,0>:d     1:w              
        mov (1|M0)               r8.5<1>:f     r114.5<0;1,0>:f                 
(W)     mov (1|M0)               r2.6<1>:hf    0x20:hf                             
(f1.1)  mul (1|M0)               r8.5<1>:f     r114.5<0;1,0>:f   0x4F800000:f              
(f1.1)  sel (1|M0)               r3.1<1>:d     r2.6<0;1,0>:w     0:w               {F@2}
        shr (1|M0)               r1.2<1>:ud    r8.5<0;1,0>:ud    0x17:uw              {F@1}
        mov (1|M0)               r114.7<1>:f   (abs)r8.5<0;1,0>:f              
        and (1|M0)               r1.2<1>:ud    r1.2<0;1,0>:ud    0xFF:uw              {I@1}
        add (1|M0)               r1.2<1>:ud    r1.2<0;1,0>:ud    0xFFFFFFE0:ud              {I@1}
(f1.1)  mov (1|M0)               r6.1<1>:d     r1.2<0;1,0>:d                    {I@1}
L9368:
        join (16|M0)                         L9456                                
L9384:
        mov (1|M0)               r8.7<1>:f     (abs)r8.4<0;1,0>:f              
        add (1|M0)               r3.1<1>:d     r3.1<0;1,0>:d     r3.0<0;1,0>:d    {Compacted}
        add (1|M0)               r8.7<1>:d     r8.7<0;1,0>:d     -r114.7<0;1,0>:d {F@1}
        asr (1|M0)               r8.7<1>:d     r8.7<0;1,0>:d     23:w               {I@1}
        add (1|M0)               r3.1<1>:d     r3.1<0;1,0>:d     r8.7<0;1,0>:d    {I@1}
L9456:
        join (16|M0)                         L10992                                
L9472:
        cmp (1|M0)    (eq)f1.0   null<1>:uw    r6.0<0;1,0>:ub    0x0:uw             
(W)     mov (1|M0)               r1.2<1>:f     1.0:f                               {Compacted}
(W)     mov (1|M0)               r4.0<1>:f     0x807FFFFF:f                              
        cmp (1|M0)    (eq)f0.1   null<1>:w     r114.24<0;1,0>:b  0:w              
(~f1.0) mov (1|M0)               r8.7<1>:d     r3.1<0;1,0>:d                    {I@4}
        bfn.0xEA (1|M0)          r8.5<1>:ud    r1.2<0;0>:ud      r8.5<0;0>:ud      r4.0<0>:ud       {A@1} // s0|s1&s2
        add (1|M0)               r6.4<1>:d     r8.7<0;1,0>:d     126:w               {I@2}
        add (1|M0)               r6.3<1>:d     -r8.7<0;1,0>:d    -152:w              
        sync.nop                             null                             {Compacted,I@3}
        math.inv (1|M0)          r2.3<1>:f     r8.5<0;1,0>:f                    {$9}
        and (1|M0)               r6.3<1>:d     r6.3<0;1,0>:d     r6.4<0;1,0>:d    {I@1}
        mov (1|M0)               r6.0<1>:f     1.0:f                               {Compacted}
        asr (1|M0)               r6.3<1>:d     r6.3<0;1,0>:d     31:w               {Compacted,I@1}
(~f0.1) mov (1|M0)               r6.3<1>:d     0:w                              
        bfn.0xEA (1|M0)          r8.4<1>:ud    r1.2<0;0>:ud      r8.4<0;0>:ud      r4.0<0>:ud       // s0|s1&s2
        cmp (1|M0)    (ne)f0.0   null<1>:d     r6.3<0;1,0>:d     0:w               {I@2}
        sync.nop                             null                             {Compacted,$9.dst}
        mad (1|M0)               r6.0<1>:f     r6.0<0;0>:f       r2.3<0;0>:f       -r8.5<0>:f       {F@1}
        mul (1|M0)               r2.4<1>:f     r2.3<0;1,0>:f     r8.4<0;1,0>:f    {I@2}
        add (1|M0)               r8.1<1>:d     r8.1<0;1,0>:d     -r6.1<0;1,0>:d  
        mad (1|M0)               r6.0<1>:f     r2.3<0;0>:f       r2.3<0;0>:f       r6.0<0>:f        {F@2}
        mad (1|M0)               r6.1<1>:f     r8.4<0;0>:f       r2.4<0;0>:f       -r8.5<0>:f       {A@1}
(W)     and (1|M0)               f0.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
        mad (1|M0)               r6.1<1>:f     r2.4<0;0>:f       r6.0<0;0>:f       r6.1<0>:f        {F@1}
        mad (1|M0)               r8.4<1>:f     r8.4<0;0>:f       r6.1<0;0>:f       -r8.5<0>:f       {F@1}
(~f0.1.any16h) goto (16|M0)                  L10648                  L10648                
L9848:
        mov (1|M0)               r6.2<1>:f     r8.4<0;1,0>:f                    {F@1}
        mov (2|M0)               r2.0<1>:f     r6.0<1;1,0>:f                   
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r3.0          L11224                                 {A@1}
L9928:
        cmp (1|M0)    (eq)f1.0   null<1>:f     r8.4<0;1,0>:f     0.0:f              
(W)     mov (1|M0)               r1.3<1>:hf    0x1:hf                             
        add (1|M0)               r8.7<1>:d     r8.7<0;1,0>:d     125:w              
(W)     mov (1|M0)               r3.12<1>:hf   0x1:hf                             
(f1.0)  sel (1|M0)               r2.6<1>:w     r1.3<0;1,0>:w     0:w               {F@2}
        cmp (1|M0)    (lt)f0.0   null<1>:d     r8.7<0;1,0>:d     -2:w               {I@2}
        cmp (1|M0)    (ne)f0.1   null<1>:w     r2.6<0;1,0>:w     0:w               {I@2}
(W)     mov (1|M0)               r5.0<1>:hf    -qnan(0x1FF):hf                             
(f0.0)  sel (1|M0)               r3.13<1>:uw   r3.12<0;1,0>:uw   0x0:uw              {F@2}
(f0.1)  sel (1|M0)               r4.0<1>:uw    r3.12<0;1,0>:uw   0x0:uw             
        or (1|M0)     (ne)f1.1   null<1>:uw    r3.13<0;1,0>:uw   r4.0<0;1,0>:uw   {I@1}
(f1.1)  sel (1|M0)               r6.20<2>:b    r5.0<0;1,0>:w     0:w               {F@1}
        cmp (1|M0)    (ne)f1.1   null<1>:uw    r6.20<0;1,0>:ub   0x0:uw              {I@1}
(W)     and (1|M0)               f0.0<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(~f0.0.any16h) goto (16|M0)                  L10288                  L10288                
L10168:
(W)     mov (1|M0)               r1.3<1>:hf    0x1:hf                             
        and (1|M0)               r1.2<1>:d     r6.2<0;1,0>:d     -2139095041:d              
(W)     mov (1|M0)               r4.0<1>:f     0x800000:f                               {Compacted}
        shl (1|M0)               r6.4<1>:d     r6.4<0;1,0>:d     23:w              
(f1.0)  sel (1|M0)               r2.3<1>:d     r1.3<0;1,0>:w     0:w               {F@2}
        add (1|M0)               r6.4<1>:d     r6.4<0;1,0>:d     1065353216:d               {I@2}
        bfn.0xFE (1|M0)          r1.2<1>:ud    r1.2<0;0>:ud      r2.3<0;0>:ud      r4.0<0>:ud       {A@1} // s0|s1|s2
        mul (1|M0)               r6.4<1>:f     r6.4<0;1,0>:f     r1.2<0;1,0>:f    {A@1}
L10288:
        join (16|M0)                         L10648                                
L10304:
        and (1|M0)               r1.2<1>:d     r6.2<0;1,0>:d     -2147483648:d               {F@1}
        shl (1|M0)               r6.2<1>:d     r6.2<0;1,0>:d     1:w              
(W)     mov (1|M0)               r1.3<1>:hf    0x1:hf                             
        and (1|M0)               r1.3<1>:d     r6.2<0;1,0>:d     8388606:d               {I@1}
        and (1|M0)    (eq)f1.1   r6.2<1>:d     r6.2<0;1,0>:d     8388608:d              
(W)     mov (1|M0)               r2.5<1>:f     1.469368e-38:f                               {Compacted}
(f0.1)  sel (1|M0)               r2.3<1>:d     r1.3<0;1,0>:w     0:w               {F@2}
(W)     mov (1|M0)               r3.7<1>:f     0x800000:f                               {Compacted}
        or (1|M0)                r2.3<1>:d     r1.2<0;1,0>:d     r2.3<0;1,0>:d    {I@1}
(f1.1)  sel (1|M0)               r3.6<1>:d     r2.5<0;1,0>:d     12582912:d               {F@2}
        mov (1|M0)               r4.0<1>:f     0.25:f                               {Compacted}
        bfn.0xFE (1|M0)          r2.3<1>:ud    r3.7<0;0>:ud      r2.3<0;0>:ud      r1.3<0>:ud       {A@2} // s0|s1|s2
        or (1|M0)                r3.6<1>:d     r3.6<0;1,0>:d     r1.2<0;1,0>:d    {I@2}
        or (1|M0)                r2.4<1>:d     r1.2<0;1,0>:d     8388608:d              
        mad (1|M0)               r2.3<1>:f     r3.6<0;0>:f       r4.0<0;0>:f       r2.3<0>:f        {A@1}
        cmp (1|M0)    (eq)f0.0   null<1>:uw    r6.20<0;1,0>:ub   0x0:uw             
        add (1|M0)               r2.3<1>:f     r2.3<0;1,0>:f     -r2.4<0;1,0>:f   {A@1}
        mul (1|M0)               r2.4<1>:f     r2.4<0;1,0>:f     r2.4<0;1,0>:f   
        and (1|M0)    (ne)f1.1   null<1>:d     r6.3<0;1,0>:d     1:w              
        and (1|M0)               r2.4<1>:d     r2.4<0;1,0>:d     -2:w               {F@1}
        or (1|M0)                r2.4<1>:d     r2.4<0;1,0>:d     r2.3<0;1,0>:d    {I@1}
(~f0.0) mov (1|M0)               r2.4<1>:f     r6.4<0;1,0>:f                    {I@1}
(f1.1)  mov (1|M0)               r8.0<1>:f     r2.4<0;1,0>:f                    {F@1}
L10648:
        join (16|M0)                         L10992                                
L10664:
        add (1|M0)               r2.3<1>:d     r8.1<0;1,0>:d     126:w              
(W)     mov (1|M0)               r1.3<1>:uw    r6.12<0;1,0>:ub                 
        cmp (1|M0)    (gt)f0.0   null<1>:ud    r2.3<0;1,0>:ud    0x17A:uw              {I@2}
        mad (1|M0)               r8.4<1>:f     r6.1<0;0>:f       r6.0<0;0>:f       r8.4<0>:f       
        or (1|M0)                r3.0<1>:w     r114.24<0;1,0>:ub  r1.3<0;1,0>:uw  {I@2}
(W)     and (1|M0)               f1.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw              {F@2}
(~f1.1.any16h) goto (16|M0)                  L10856                  L10856                
L10776:
(f0.0)  sel (1|M0)               r1.2<1>:d     r8.1<0;1,0>:d     0:w              
        asr (1|M0)               r1.2<1>:d     r1.2<0;1,0>:d     11:w               {I@1}
        add (1|M0)               r1.3<1>:d     r1.2<0;1,0>:d     248:w               {I@1}
        xor (1|M0)               r1.3<1>:d     r1.3<0;1,0>:d     r1.2<0;1,0>:d    {I@1}
(f0.0)  mov (1|M0)               r8.1<1>:d     r1.3<0;1,0>:d                    {I@1}
L10856:
        join (16|M0)                         L10992                                
L10872:
        asr (1|M0)               r1.2<1>:d     r8.1<0;1,0>:d     1:w               {I@2}
        cmp (1|M0)    (eq)f1.0   null<1>:w     r3.0<0;1,0>:w     0:w              
        add (1|M0)               r8.1<1>:d     r8.1<0;1,0>:d     -r1.2<0;1,0>:d   {I@2}
        shl (1|M0)               r1.2<1>:d     r1.2<0;1,0>:d     23:w              
        shl (1|M0)               r8.1<1>:d     r8.1<0;1,0>:d     23:w               {Compacted,I@2}
        add (1|M0)               r1.2<1>:d     r1.2<0;1,0>:d     r8.4<0;1,0>:d    {A@1}
        add (1|M0)               r8.1<1>:d     r8.1<0;1,0>:d     1065353216:d               {I@2}
(f1.0)  mul (1|M0)               r8.0<1>:f     r8.1<0;1,0>:f     r1.2<0;1,0>:f    {I@1}
L10992:
        join (16|M0)                         L11008                                
L11008:
        sync.nop                             null                             {Compacted,F@1}
        math.inv (1|M0)          r1.2<1>:f     r114.5<0;1,0>:f                  {$10}
        mov (1|M0)               r1.4<1>:ud    0x3F800000:ud                             
        mul (1|M0)               r1.3<1>:f     r1.2<0;1,0>:f     r114.4<0;1,0>:f  {$10.dst}
        mad (1|M0)               r1.4<1>:f     r1.4<0;0>:f       r1.2<0;0>:f       -r114.5<0>:f     {I@1}
        mad (1|M0)               r2.3<1>:f     r114.4<0;0>:f     r1.3<0;0>:f       -r114.5<0>:f     {F@2}
        mad (1|M0)               r1.4<1>:f     r1.2<0;0>:f       r1.2<0;0>:f       r1.4<0>:f        {F@2}
        cmp (1|M0)    (eq)f0.1   null<1>:uw    r8.24<0;1,0>:ub   0x0:uw             
        mad (1|M0)               r2.3<1>:f     r1.3<0;0>:f       r1.4<0;0>:f       r2.3<0>:f        {F@1}
        mad (1|M0)               r114.4<1>:f   r114.4<0;0>:f     r2.3<0;0>:f       -r114.5<0>:f     {F@1}
(f0.1)  mad (1|M0)               r8.0<1>:f     r2.3<0;0>:f       r1.4<0;0>:f       r114.4<0>:f      {F@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        ret (16|M0)                          r8.2                             {A@1}
L11224:
        mov (1|M0)               r1.2<1>:d     cr0.0<0;1,0>:ud                  {A@1}
        and (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   -1265:w               {A@1}
        or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   1264:w               {A@1}
        mad (1|M0)               r6.2<1>:f     r2.1<0;0>:f       r2.0<0;0>:f       r6.2<0>:f        {A@1}
        mov (1|M0)               cr0.0<1>:ud   r1.2<0;1,0>:d                    {A@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        ret (16|M0)                          r3.0                             {A@1}
L11352:
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
