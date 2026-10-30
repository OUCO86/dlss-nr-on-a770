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
        mov (1|M0)               r27.0<1>:d    r6.0<0;1,0>:d                    {I@1}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mul (1|M0)               acc0.0<1>:ud  r27.0<0;1,0>:ud   r2.6<0;1,0>:uw   {I@2}
        mach (1|M0)              r9.0<1>:ud    r27.0<0;1,0>:ud   r2.3<0;1,0>:ud   {AccWrEn}
        add3 (1|M0)              r27.1<1>:d    r7.0<0;0>:d       r5.0<0;0>:d       0:w               {I@3}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r27.1<0;1,0>:d    r2.6<0;1,0>:uw   {I@2}
        mach (1|M0)              r10.0<1>:d    r27.1<0;1,0>:d    r2.3<0;1,0>:d   
        mov (1|M0)               r27.2<1>:d    r8.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r27.3<1>:d    r10.0<0;0>:d      r9.0<0;0>:d       0:w               {I@2}
        shl (1|M0)               r1.4<1>:d     r27.2<0;1,0>:d    1:w               {I@2}
        shr (1|M0)               r1.3<1>:ud    r27.2<0;1,0>:ud   0x1F:uw             
        shl (1|M0)               r1.2<1>:d     r27.3<0;1,0>:d    1:w               {I@3}
        addc (1|M0)              r4.0<1>:ud    r3.0<0;1,0>:ud    r1.4<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r6.0<1>:d     r4.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r6.1<1>:d     r5.0<0;0>:d       r3.1<0;0>:d       r1.5<0>:d        {I@2}
        send.ugm (1|M0)          r11      r6      null:0  0x0            0x0280E780           {A@1,$2} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        mov (8|M0)               r58.0<1>:f    r11.0<1;1,0>:hf                  {$2.dst}
        mov (8|M0)               r59.0<1>:f    r11.8<1;1,0>:hf                 
        mov (8|M0)               r28.0<1>:f    r12.0<1;1,0>:hf                 
        mov (8|M0)               r29.0<1>:f    r12.8<1;1,0>:hf                 
        mov (8|M0)               r30.0<1>:f    r13.0<1;1,0>:hf                 
        mov (8|M0)               r31.0<1>:f    r13.8<1;1,0>:hf                 
        mov (8|M0)               r32.0<1>:f    r14.0<1;1,0>:hf                 
        mov (8|M0)               r33.0<1>:f    r14.8<1;1,0>:hf                 
        mov (8|M0)               r34.0<1>:f    r15.0<1;1,0>:hf                 
        mov (8|M0)               r35.0<1>:f    r15.8<1;1,0>:hf                 
        mov (8|M0)               r36.0<1>:f    r16.0<1;1,0>:hf                 
        mov (8|M0)               r37.0<1>:f    r16.8<1;1,0>:hf                 
        mov (8|M0)               r38.0<1>:f    r17.0<1;1,0>:hf                 
        mov (8|M0)               r39.0<1>:f    r17.8<1;1,0>:hf                 
        mov (8|M0)               r40.0<1>:f    r18.0<1;1,0>:hf                 
        mov (8|M0)               r41.0<1>:f    r18.8<1;1,0>:hf                 
        sel (16|M0)   (ge)f0.0   r4.0<1>:f     (abs)r58.0<1;1,0>:f  (abs)r34.0<1;1,0>:f {Compacted,F@7}
        sel (16|M0)   (ge)f0.0   r6.0<1>:f     (abs)r28.0<1;1,0>:f  (abs)r36.0<1;1,0>:f {Compacted,F@6}
        sel (16|M0)   (ge)f0.0   acc0.0<1>:f   (abs)r30.0<1;1,0>:f  (abs)r38.0<1;1,0>:f {Compacted,F@5}
        sel (16|M0)   (ge)f0.0   acc2.0<1>:f   (abs)r32.0<1;1,0>:f  (abs)r40.0<1;1,0>:f {Compacted,F@4}
        sel (16|M0)   (ge)f0.0   acc0.0<1>:f   r4.0<1;1,0>:f     acc0.0<1;1,0>:f  {F@4}
        sel (16|M0)   (ge)f0.0   acc2.0<1>:f   r6.0<1;1,0>:f     acc2.0<1;1,0>:f  {F@4}
        sel (16|M0)   (ge)f0.0   r4.0<1>:f     acc0.0<1;1,0>:f   acc2.0<1;1,0>:f 
        sel (8|M0)    (ge)f0.0   r10.0<1>:f    r4.0<1;1,0>:f     r5.0<1;1,0>:f    {Compacted,F@1}
        mov (4|M0)               r21.0<1>:ud   r10.4<1;1,0>:ud                  {F@1}
        sel (4|M0)    (ge)f0.0   r22.0<1>:f    r10.0<1;1,0>:f    r21.0<1;1,0>:f   {I@1}
        mov (2|M0)               r23.0<1>:ud   r22.2<1;1,0>:ud                  {F@1}
        sel (2|M0)    (ge)f0.0   r11.0<1>:f    r22.0<1;1,0>:f    r23.0<1;1,0>:f   {I@1}
        sel (1|M0)    (ge)f0.0   r110.4<1>:f   r11.0<0;1,0>:f    r11.1<0;1,0>:f   {F@1}
        cmp (1|M0)    (eq)f1.0   null<1>:f     r110.4<0;1,0>:f   0.0:f               {F@1}
(W)     and (1|M0)               f0.0<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
(f0.0.any16h) goto (16|M0)                   L1144                  L1144                
L1064:
        mov (1|M0)               r110.5<1>:f   127.0:f                              
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r109.6        L5728                                 {A@1}
L1128:
        goto (16|M0)                         L1144                  L1168                
L1144:
        join (16|M0)                         L1168                                
L1160:
        mov (1|M0)               r110.0<1>:f   1.0:f                               {Compacted}
L1168:
        join (16|M0)                         L1184                                
L1184:
        shl (1|M0)               r1.4<1>:d     r27.0<0;1,0>:d    2:w               {Compacted}
        shl (1|M0)               r1.2<1>:d     r27.1<0;1,0>:d    2:w              
        shr (1|M0)               r1.3<1>:ud    r27.0<0;1,0>:ud   0x1E:uw             
        addc (1|M0)              r4.0<1>:ud    r3.2<0;1,0>:ud    r1.4<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (16|M0)              r42.0<1>:f    r110.0<0;1,0>:f                  {Compacted,F@1}
        mov (1|M0)               r6.0<1>:f     r4.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r6.1<1>:d     r5.0<0;0>:d       r3.3<0;0>:d       r1.5<0>:d        {I@1}
        mov (16|M0)              r60.0<1>:f    r42.0<1;1,0>:f                   {Compacted,F@2}
        send.ugm (1|M0)          null     r6      r110:1  0x0            0x04000584           {A@1,$3} // wr:2+1, rd:0; store.ugm.d32.a64
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        sync.nop                             null                             {Compacted,$3.src}
(W)     call (16|M0)             r110.2        L2584                                 {A@1}
L1376:
        mov (16|M0)              r44.0<1>:ud   r62.0<1;1,0>:ud                 
        mov (16|M0)              r58.0<1>:f    r28.0<1;1,0>:f                   {Compacted}
        mov (16|M0)              r60.0<1>:f    r42.0<1;1,0>:f                   {Compacted}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r110.2        L2584                                 {A@1}
L1456:
        mov (16|M0)              r46.0<1>:ud   r62.0<1;1,0>:ud                 
        mov (16|M0)              r58.0<1>:f    r30.0<1;1,0>:f                   {Compacted}
        mov (16|M0)              r60.0<1>:f    r42.0<1;1,0>:f                   {Compacted}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r110.2        L2584                                 {A@1}
L1536:
        mov (16|M0)              r48.0<1>:ud   r62.0<1;1,0>:ud                 
        mov (16|M0)              r58.0<1>:f    r32.0<1;1,0>:f                   {Compacted}
        mov (16|M0)              r60.0<1>:f    r42.0<1;1,0>:f                   {Compacted}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r110.2        L2584                                 {A@1}
L1616:
        mov (16|M0)              r50.0<1>:ud   r62.0<1;1,0>:ud                 
        mov (16|M0)              r58.0<1>:f    r34.0<1;1,0>:f                   {Compacted}
        mov (16|M0)              r60.0<1>:f    r42.0<1;1,0>:f                   {Compacted}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r110.2        L2584                                 {A@1}
L1696:
        mov (16|M0)              r52.0<1>:ud   r62.0<1;1,0>:ud                 
        mov (16|M0)              r58.0<1>:f    r36.0<1;1,0>:f                   {Compacted}
        mov (16|M0)              r60.0<1>:f    r42.0<1;1,0>:f                   {Compacted}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r110.2        L2584                                 {A@1}
L1776:
        mov (16|M0)              r54.0<1>:ud   r62.0<1;1,0>:ud                 
        mov (16|M0)              r58.0<1>:f    r38.0<1;1,0>:f                   {Compacted}
        mov (16|M0)              r60.0<1>:f    r42.0<1;1,0>:f                   {Compacted}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r110.2        L2584                                 {A@1}
L1856:
        mov (16|M0)              r56.0<1>:ud   r62.0<1;1,0>:ud                 
        mov (16|M0)              r58.0<1>:f    r40.0<1;1,0>:f                   {Compacted}
        mov (16|M0)              r60.0<1>:f    r42.0<1;1,0>:f                   {Compacted}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r110.2        L2584                                 {A@1}
L1936:
        rnde (16|M0)             r44.0<1>:f    r44.0<1;1,0>:f                   {Compacted}
        rnde (16|M0)             r46.0<1>:f    r46.0<1;1,0>:f                   {Compacted}
        rnde (16|M0)             r48.0<1>:f    r48.0<1;1,0>:f                   {Compacted,I@7}
        rnde (16|M0)             r50.0<1>:f    r50.0<1;1,0>:f                   {Compacted,I@7}
        rnde (16|M0)             r52.0<1>:f    r52.0<1;1,0>:f                   {Compacted,I@6}
        rnde (16|M0)             r54.0<1>:f    r54.0<1;1,0>:f                   {Compacted,I@4}
        rnde (16|M0)             r56.0<1>:f    r56.0<1;1,0>:f                   {Compacted,I@2}
        rnde (16|M0)             r62.0<1>:f    r62.0<1;1,0>:f                   {Compacted}
        sel (16|M0)   (ge)f0.0   r44.0<1>:f    r44.0<1;1,0>:f    -127.0:f               {F@7}
        sel (16|M0)   (ge)f0.0   r46.0<1>:f    r46.0<1;1,0>:f    -127.0:f               {F@7}
        sel (16|M0)   (ge)f0.0   r48.0<1>:f    r48.0<1;1,0>:f    -127.0:f               {F@7}
        sel (16|M0)   (ge)f0.0   r50.0<1>:f    r50.0<1;1,0>:f    -127.0:f               {F@7}
        sel (16|M0)   (ge)f0.0   r52.0<1>:f    r52.0<1;1,0>:f    -127.0:f               {F@7}
        sel (16|M0)   (ge)f0.0   r54.0<1>:f    r54.0<1;1,0>:f    -127.0:f               {F@7}
        sel (16|M0)   (ge)f0.0   r56.0<1>:f    r56.0<1;1,0>:f    -127.0:f               {F@7}
        sel (16|M0)   (ge)f0.0   r62.0<1>:f    r62.0<1;1,0>:f    -127.0:f               {F@7}
        addc (1|M0)              r24.0<1>:ud   r3.4<0;1,0>:ud    r27.2<0;1,0>:ud  {AccWrEn}
        sel (16|M0)   (lt)f0.0   r44.0<1>:f    r44.0<1;1,0>:f    127.0:f               {F@7}
        sel (16|M0)   (lt)f0.0   r46.0<1>:f    r46.0<1;1,0>:f    127.0:f               {F@7}
        sel (16|M0)   (lt)f0.0   r48.0<1>:f    r48.0<1;1,0>:f    127.0:f               {F@7}
        sel (16|M0)   (lt)f0.0   r50.0<1>:f    r50.0<1;1,0>:f    127.0:f               {F@7}
        sel (16|M0)   (lt)f0.0   r52.0<1>:f    r52.0<1;1,0>:f    127.0:f               {F@7}
        sel (16|M0)   (lt)f0.0   r54.0<1>:f    r54.0<1;1,0>:f    127.0:f               {F@7}
        sel (16|M0)   (lt)f0.0   r56.0<1>:f    r56.0<1;1,0>:f    127.0:f               {F@7}
        sel (16|M0)   (lt)f0.0   r62.0<1>:f    r62.0<1;1,0>:f    127.0:f               {F@7}
        mov (1|M0)               r25.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (16|M0)              r4.0<1>:d     r44.0<1;1,0>:f                   {Compacted,F@7}
        mov (16|M0)              r6.0<1>:d     r46.0<1;1,0>:f                   {Compacted,F@7}
        mov (16|M0)              r8.0<1>:d     r48.0<1;1,0>:f                   {Compacted,F@6}
        mov (16|M0)              r10.0<1>:d    r50.0<1;1,0>:f                   {Compacted,F@5}
        mov (16|M0)              r12.0<1>:d    r52.0<1;1,0>:f                   {Compacted,F@4}
        mov (16|M0)              r14.0<1>:d    r54.0<1;1,0>:f                   {Compacted,F@3}
        mov (16|M0)              r16.0<1>:d    r56.0<1;1,0>:f                   {Compacted,F@2}
        mov (16|M0)              r18.0<1>:d    r62.0<1;1,0>:f                   {Compacted,F@1}
        mov (1|M0)               r26.0<1>:d    r24.0<0;1,0>:d                   {I@7}
        add3 (1|M0)              r26.1<1>:d    r25.0<0;0>:d      r3.5<0;0>:d       r27.3<0>:d       {I@7}
        mov (16|M0)              r20.0<1>:b    r4.0<4;1,0>:b                    {I@7}
        mov (16|M0)              r20.16<1>:b   r6.0<4;1,0>:b                    {I@7}
        mov (16|M0)              r21.0<1>:b    r8.0<4;1,0>:b                    {I@7}
        mov (16|M0)              r21.16<1>:b   r10.0<4;1,0>:b                   {I@7}
        mov (16|M0)              r22.0<1>:b    r12.0<4;1,0>:b                   {I@7}
        mov (16|M0)              r22.16<1>:b   r14.0<4;1,0>:b                   {I@7}
        mov (16|M0)              r23.0<1>:b    r16.0<4;1,0>:b                   {I@7}
        mov (16|M0)              r23.16<1>:b   r18.0<4;1,0>:b                   {I@7}
        send.ugm (1|M0)          null     r26     r20:4   0x0            0x0200D784           {A@1,$4} // wr:1+4, rd:0; store.ugm.d64x16t.a64
(W)     mov (8|M0)               r127.0<1>:ud  r0.0<1;1,0>:ud                  
(W)     send.ugm (1|M0)          r4       r0      null:0  0x0            0x0210641F           {$5} // wr:1+0, rd:1; fence invalid flush type scoped to tile
(W)     mov (8|M0)               null<1>:ud    r4.0<1;1,0>:ud                   {$5.dst}
(W)     send.gtwy (1|M0)         null     r127    null:0  0x0            0x02000010           {EOT,A@1} // wr:1+0, rd:0; end of thread
L2584:
(W)     shr (16|M0)              r4.0<1>:ud    r58.0<1;1,0>:ud   0x17:uw             
(W)     and (16|M0)              r64.0<1>:w    r4.0<2;1,0>:w     255:w               {I@1}
(W)     add (16|M0)              r8.0<1>:d     r64.0<1;1,0>:uw   -191:w               {I@1}
(W)     cmp (16|M0)   (lt)f1.0   null<1>:d     r8.0<1;1,0>:ud    0xFFFFFF82:ud              {I@1}
(W)     shr (16|M0)              r6.0<1>:ud    r60.0<1;1,0>:ud   0x17:uw             
(W)     mov (1|M0)               r109.3<1>:uw  f1.0<0;1,0>:uw                  
(W)     and (16|M0)              r69.0<1>:w    r6.0<2;1,0>:w     255:w               {I@2}
(W)     mov (1|M0)               f0.1<1>:uw    r109.3<0;1,0>:uw                 {I@2}
(W)     add (16|M0)              r10.0<1>:d    r69.0<1;1,0>:uw   -191:w               {I@2}
(W)     mov (16|M0)              r65.0<1>:d    r64.0<1;1,0>:uw                 
(W&~f0.1) cmp (16|M0) (lt)f0.1   null<1>:d     r10.0<1;1,0>:ud   0xFFFFFF81:ud              {I@2}
(W)     mov (16|M0)              r67.0<1>:d    r64.0<1;1,0>:uw                 
(W)     mov (1|M0)               r109.3<1>:uw  f0.1<0;1,0>:uw                  
(W)     mov (16|M0)              r70.0<1>:d    r69.0<1;1,0>:uw                 
(W)     mov (1|M0)               f0.0<1>:uw    r109.3<0;1,0>:uw                 {I@2}
(W)     mov (16|M0)              r72.0<1>:d    r69.0<1;1,0>:uw                 
(~f0.0.any16h) goto (16|M0)                  L5400                  L5400                
L2856:
(W)     add (16|M0)              r4.0<1>:d     r64.0<1;1,0>:uw   -255:w              
(W)     cmp (16|M0)   (lt)f0.0   null<1>:d     r4.0<1;1,0>:ud    0xFFFFFF02:ud              {I@1}
(W)     add (16|M0)              r6.0<1>:d     r69.0<1;1,0>:uw   -255:w              
(W&~f0.0) cmp (16|M0) (lt)f0.0   null<1>:d     r6.0<1;1,0>:ud    0xFFFFFF02:ud              {I@1}
(W)     mov (16|M0)              r84.0<1>:f    (abs)r58.0<1;1,0>:f              {Compacted}
(f0.0.any16h) goto (16|M0)                   L3016                  L3016                
L2944:
(W)     mov (16|M0)              r4.0<1>:f     (abs)r60.0<1;1,0>:f              {Compacted}
(W)     add (16|M0)              r84.0<1>:d    r84.0<1;1,0>:d    -r4.0<1;1,0>:d   {Compacted,A@1}
(W)     mov (4|M0)               r27.4<1>:d    0:w                              
(W)     mov (16|M0)              r96.0<1>:f    r58.0<1;1,0>:f                   {Compacted}
(W)     mov (16|M0)              r86.0<1>:f    r60.0<1;1,0>:f                   {Compacted}
(W)     asr (16|M0)              r84.0<1>:d    r84.0<1;1,0>:d    23:w               {Compacted,I@2}
        goto (16|M0)                         L3016                  L4272                
L3016:
        join (16|M0)                         L4272                                
L3032:
(W)     mov (16|M0)              r82.0<1>:f    (abs)r60.0<1;1,0>:f              {Compacted}
(W)     cmp (16|M0)   (gt)f1.1   null<1>:d     r84.0<1;1,0>:ud   0x7F800000:ud              {I@3}
(W)     cmp (16|M0)   (lt)f1.0   null<1>:d     r82.0<1;1,0>:ud   0x7F800001:ud              {F@1}
(W)     and (16|M0)              r74.0<1>:ud   r58.0<1;1,0>:ud   0x7F800000:ud             
(W)     mov (1|M0)               r1.3<1>:uw    f1.1<0;1,0>:uw                  
(W)     mov (1|M0)               r2.6<1>:uw    f1.0<0;1,0>:uw                   {Compacted}
(W)     or (1|M0)                f0.1<1>:uw    f1.0<0;1,0>:uw    r1.3<0;1,0>:uw   {I@2}
(W)     cmp (16|M0)   (ne)f1.0   null<1>:d     r74.0<1;1,0>:d    2139095040:d              
(W)     or (1|M0)                r3.12<1>:uw   f1.1<0;1,0>:uw    ~r2.6<0;1,0>:uw  {I@3}
(W)     mov (1|M0)               r8.0<1>:f     -0.0:f                               {Compacted}
(W)     or (1|M0)                r3.13<1>:uw   f1.0<0;1,0>:uw    r3.12<0;1,0>:uw  {I@1}
(W&f0.1) sel (16|M0)             acc0.0<1>:f   r58.0<1;1,0>:f    r60.0<1;1,0>:f  
(W)     mov (1|M0)               f0.1<1>:uw    r3.13<0;1,0>:uw                  {A@1}
(W)     and (16|M0)              r76.0<1>:ud   r60.0<1;1,0>:ud   0x7F800000:ud             
(W)     bfn.0x6A (16|M0)         r62.0<1>:ud   r58.0<1;0>:ud     r60.0<1;0>:ud     r8.0<0>:ud       // s0^s1&s2
(W)     bfn.0x6A (16|M0)         r9.0<1>:ud    r60.0<1;0>:ud     r58.0<1;0>:ud     r8.0<0>:ud       // s0^s1&s2
(W)     add (16|M0)              r62.0<1>:f    r62.0<1;1,0>:f    -r9.0<1;1,0>:f   {Compacted,A@1}
(W&f0.1) add (16|M0)             r62.0<1>:f    acc0.0<1;1,0>:f   r60.0<1;1,0>:f  
(W)     cmp (16|M0)   (ne)f0.1   null<1>:d     r76.0<1;1,0>:d    2139095040:d               {F@1}
(W)     or (1|M0)                r3.12<1>:uw   ~f1.0<0;1,0>:uw   r3.12<0;1,0>:uw 
(W)     cmp (16|M0)   (eq)f1.0   null<1>:f     r60.0<1;1,0>:f    0.0:f               {I@1}
(W)     or (1|M0)                r1.3<1>:uw    f0.1<0;1,0>:uw    r3.12<0;1,0>:uw 
(W)     or (1|M0)                r3.12<1>:uw   ~f0.1<0;1,0>:uw   r3.12<0;1,0>:uw 
(W)     mov (1|M0)               r2.6<1>:hf    -qnan(0x1FF):hf                             
(W)     mov (1|M0)               f0.1<1>:uw    r3.12<0;1,0>:uw                  {I@1}
(W)     and (1|M0)               r4.0<1>:uw    f1.0<0;1,0>:uw    ~r3.12<0;1,0>:uw
(W)     mov (1|M0)               f1.1<1>:uw    r1.3<0;1,0>:uw                  
(W)     and (16|M0)              r6.0<1>:ud    r60.0<1;1,0>:ud   0x80000000:ud             
(W&f0.1) sel (16|M0)             r11.0<2>:b    r2.6<0;1,0>:w     0:w               {F@1}
(W)     mov (1|M0)               f0.1<1>:uw    r4.0<0;1,0>:uw                   {I@4}
(W)     and (16|M0)              r78.0<1>:ud   r58.0<1;1,0>:ud   0x80000000:ud             
(W&~f1.1) mul (16|M0)            r62.0<1>:f    r6.0<1;1,0>:f     r58.0<1;1,0>:f   {I@4}
(W)     mov (16|M0)              r27.16<1>:b   r11.0<2;1,0>:b                   {I@3}
(~f0.1) goto (16|M0)                         L3664                  L3664                
L3544:
(W)     cmp (16|M0)   (eq)f1.0   null<1>:f     r58.0<1;1,0>:f    0.0:f              
(W)     mov (1|M0)               r1.2<1>:ud    0x7F800000:ud                             
(W)     mov (1|M0)               r2.12<2>:b    -1:w                              
(W&f1.0) mov (16|M0)             r78.0<1>:ud   0:w                              
(W)     bfn.0x96 (16|M0)         r78.0<1>:ud   r1.2<0;0>:ud      r78.0<1;0>:ud     r60.0<1>:ud      {I@1} // s0^s1^s2
(W&f1.0) mul (16|M0)             r78.0<1>:f    r78.0<1;1,0>:f    r58.0<1;1,0>:f   {I@1}
        mov (16|M0)              r27.16<1>:b   r2.12<0;1,0>:b                  
        mov (16|M0)              r62.0<1>:f    r78.0<1;1,0>:f                   {Compacted,F@1}
L3664:
        join (16|M0)                         L4272                                
L3680:
(W)     cmp (16|M0)   (eq)f0.1   null<1>:f     r58.0<1;1,0>:f    0.0:f              
(W&f0.1) cmp (16|M0)  (eq)f0.1   null<1>:w     r27.16<1;1,0>:ub  0x0:uw              {A@1}
(W&~f0.1) sel (16|M0)            r4.0<2>:b     r27.16<1;1,0>:b   -1:w              
(W)     mov (16|M0)              r27.16<1>:b   r4.0<2;1,0>:b                    {I@1}
(W)     cmp (16|M0)   (ne)f1.1   null<1>:w     r27.16<1;1,0>:ub  0x0:uw              {I@1}
(W&f0.1) mul (16|M0)             r62.0<1>:f    r58.0<1;1,0>:f    r60.0<1;1,0>:f  
(f1.1.all16h) goto (16|M0)                   L4272                  L5400                
L3792:
(W)     cmp (16|M0)   (eq)f1.1   null<1>:w     r27.16<1;1,0>:ub  0x0:uw             
(W)     mov (1|M0)               r1.3<1>:uw    f0.0<0;1,0>:uw                  
(W)     cmp (16|M0)   (eq)f1.0   null<1>:d     r74.0<1;1,0>:d    0:w              
(W)     and (1|M0)               f0.0<1>:uw    f1.1<0;1,0>:uw    r1.3<0;1,0>:uw   {I@2}
(W)     mov (16|M0)              r88.0<1>:d    0:w                              
(W)     mov (1|M0)               r2.6<1>:uw    f1.0<0;1,0>:uw                   {Compacted}
(W)     mov (16|M0)              r96.0<1>:f    r58.0<1;1,0>:f                   {Compacted}
(W)     and (1|M0)               f1.0<1>:uw    f0.0<0;1,0>:uw    r2.6<0;1,0>:uw   {I@1}
(W)     mov (16|M0)              r80.0<1>:f    r88.0<1;1,0>:f                   {Compacted}
(~f1.0) goto (16|M0)                         L4024                  L4024                
L3928:
        mul (16|M0)              r96.0<1>:f    r58.0<1;1,0>:f    0x4F800000:f               {Compacted}
(W)     shr (16|M0)              r4.0<1>:ud    r96.0<1;1,0>:ud   0x17:uw              {F@1}
(W)     and (16|M0)              r6.0<1>:w     r4.0<2;1,0>:w     255:w               {I@1}
        add (16|M0)              r67.0<1>:d    r6.0<1;1,0>:uw    -32:w               {I@1}
(W)     mov (16|M0)              r80.0<1>:d    0:w                              
(W)     mov (16|M0)              r65.0<1>:f    r67.0<1;1,0>:f                   {Compacted,I@2}
        mov (16|M0)              r80.0<1>:d    -32:w                              
L4024:
        join (16|M0)                         L4272                                
L4040:
(W)     cmp (16|M0)   (eq)f0.1   null<1>:d     r76.0<1;1,0>:d    0:w              
(W)     mov (16|M0)              r86.0<1>:f    r60.0<1;1,0>:f                   {Compacted}
(W)     mov (1|M0)               r1.3<1>:uw    f0.1<0;1,0>:uw                  
(W)     and (1|M0)               f0.1<1>:uw    f0.0<0;1,0>:uw    r1.3<0;1,0>:uw   {I@1}
(~f0.1) goto (16|M0)                         L4216                  L4216                
L4112:
        mul (16|M0)              r86.0<1>:f    r60.0<1;1,0>:f    0x4F800000:f               {Compacted}
(W)     shr (16|M0)              r4.0<1>:ud    r86.0<1;1,0>:ud   0x17:uw              {F@1}
(W)     and (16|M0)              r6.0<1>:w     r4.0<2;1,0>:w     255:w               {I@1}
        add (16|M0)              r72.0<1>:d    r6.0<1;1,0>:uw    -32:w               {I@1}
(W)     mov (16|M0)              r88.0<1>:d    0:w                              
(W)     mov (16|M0)              r82.0<1>:f    (abs)r86.0<1;1,0>:f              {Compacted}
(W)     mov (16|M0)              r70.0<1>:f    r72.0<1;1,0>:f                   {Compacted,I@2}
        mov (16|M0)              r88.0<1>:d    32:w                              
L4216:
        join (16|M0)                         L4272                                
L4232:
(W)     mov (16|M0)              r84.0<1>:f    (abs)r96.0<1;1,0>:f              {Compacted}
(W)     add (16|M0)              r84.0<1>:d    r84.0<1;1,0>:d    -r82.0<1;1,0>:d  {Compacted,F@1}
(W)     asr (16|M0)              r84.0<1>:d    r84.0<1;1,0>:d    23:w               {Compacted,I@1}
(W)     add3 (16|M0)             r88.0<1>:d    r88.0<1;0>:d      r80.0<1;0>:d      r84.0<1>:d       {I@1}
L4272:
        join (16|M0)                         L5400                                
L4288:
(W)     mov (1|M0)               r1.2<1>:f     1.0:f                               {Compacted}
(W)     mov (1|M0)               r4.0<1>:f     0x807FFFFF:f                              
(W&~f0.0) mov (16|M0)            r88.0<1>:f    r84.0<1;1,0>:f                   {I@2}
(W)     bfn.0xEA (16|M0)         r86.0<1>:ud   r1.2<0;0>:ud      r86.0<1;0>:ud     r4.0<0>:ud       {A@2} // s0|s1&s2
(W)     add (16|M0)              r90.0<1>:d    r88.0<1;1,0>:d    126:w               {Compacted,F@1}
(W)     add (16|M0)              r5.0<1>:d     -r88.0<1;1,0>:d   -152:w               {Compacted}
        sync.nop                             null                             {Compacted,I@3}
(W)     math.inv (16|M0)         r7.0<1>:f     r86.0<1;1,0>:f                   {$6}
(W)     cmp (16|M0)   (eq)f0.0   null<1>:w     r27.16<1;1,0>:ub  0x0:uw             
(W)     and (16|M0)              r5.0<1>:d     r5.0<1;1,0>:d     r90.0<1;1,0>:d   {Compacted,I@2}
(W)     mov (1|M0)               r2.3<1>:f     1.0:f                               {Compacted}
(W)     bfn.0xEA (16|M0)         r96.0<1>:ud   r1.2<0;0>:ud      r96.0<1;0>:ud     r4.0<0>:ud       // s0|s1&s2
(W)     asr (16|M0)              r5.0<1>:d     r5.0<1;1,0>:d     31:w               {Compacted,I@2}
        sync.nop                             null                             {Compacted,$6.dst}
(W)     mad (16|M0)              r92.0<1>:f    r2.3<0;0>:f       r7.0<1;0>:f       -r86.0<1>:f      {F@1}
(W)     mul (16|M0)              acc0.0<1>:f   r7.0<1;1,0>:f     r96.0<1;1,0>:f   {Compacted,I@2}
(W&f0.0) sel (16|M0)             r98.0<1>:w    r5.0<4;1,0>:ub    0:w               {I@1}
(W)     mad (16|M0)              r92.0<1>:f    r7.0<1;0>:f       r7.0<1;0>:f       r92.0<1>:f       {Compacted,F@2}
(W)     mad (16|M0)              r94.0<1>:f    r96.0<1;0>:f      acc0.0<1;0>:f     -r86.0<1>:f     
(W)     cmp (16|M0)   (ne)f1.1   null<1>:w     r98.0<2;1,0>:ub   0x0:uw              {I@1}
(W)     mad (16|M0)              r94.0<1>:f    acc0.0<1;0>:f     r92.0<1;0>:f      r94.0<1>:f       {F@1}
(W)     add (16|M0)              r65.0<1>:d    r65.0<1;1,0>:d    -r70.0<1;1,0>:d  {Compacted}
(W)     mad (16|M0)              r96.0<1>:f    r96.0<1;0>:f      r94.0<1;0>:f      -r86.0<1>:f      {Compacted,F@1}
(~f1.1.any16h) goto (16|M0)                  L5144                  L5144                
L4576:
(W)     mov (16|M0)              r105.0<1>:ud  r96.0<1;1,0>:ud                  {F@1}
(W)     mov (16|M0)              r101.0<1>:f   r92.0<1;1,0>:f                   {Compacted}
(W)     mov (16|M0)              r103.0<1>:f   r94.0<1;1,0>:f                   {Compacted}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r110.6        L5608                                 {A@1}
L4656:
(W)     add (16|M0)              r88.0<1>:d    r88.0<1;1,0>:d    125:w               {Compacted}
(W)     cmp (16|M0)   (lt)f0.0   null<1>:d     r88.0<1;1,0>:d    -2:w               {Compacted,I@1}
(W)     cmp (16|M0)   (eq)f0.1   null<1>:f     r96.0<1;1,0>:f    0.0:f              
(W)     mov (1|M0)               r1.3<1>:uw    f0.0<0;1,0>:uw                  
(W)     or (1|M0)                f1.0<1>:uw    f0.1<0;1,0>:uw    r1.3<0;1,0>:uw   {I@1}
(f1.0.any16h) goto (16|M0)                   L4784                  L4784                
L4736:
(W)     mov (1|M0)               r1.3<1>:hf    0x1:hf                              {I@2}
(W&f0.1) sel (16|M0)             r99.0<1>:d    r1.3<0;1,0>:w     0:w               {F@1}
        goto (16|M0)                         L4784                  L4904                
L4784:
        join (16|M0)                         L4904                                
L4800:
(W)     mov (1|M0)               r1.3<1>:hf    0x1:hf                              {I@3}
(W)     and (16|M0)              r4.0<1>:d     r105.0<1;1,0>:d   -2139095041:d              
(W)     mov (1|M0)               r6.0<1>:f     0x800000:f                               {Compacted}
(W)     shl (16|M0)              r90.0<1>:d    r90.0<1;1,0>:d    23:w               {Compacted}
(W&f0.1) sel (16|M0)             r99.0<1>:d    r1.3<0;1,0>:w     0:w               {F@2}
(W)     add (16|M0)              r90.0<1>:d    r90.0<1;1,0>:d    1065353216:d               {I@2}
(W)     bfn.0xFE (16|M0)         r4.0<1>:ud    r4.0<1;0>:ud      r99.0<1;0>:ud     r6.0<0>:ud       {A@1} // s0|s1|s2
(W)     mul (16|M0)              r90.0<1>:f    r90.0<1;1,0>:f    r4.0<1;1,0>:f    {Compacted,A@1}
L4904:
        join (16|M0)                         L5144                                
L4920:
(W)     and (16|M0)   (eq)f1.1   null<1>:ud    r105.0<1;1,0>:ud  0x400000:ud             
(W)     shl (16|M0)              r4.0<1>:d     r105.0<1;1,0>:d   1:w               {Compacted,F@1}
(W)     mov (1|M0)               r1.2<1>:f     0x800000:f                               {Compacted}
(W)     mov (1|M0)               r6.0<1>:f     -0.0:f                               {Compacted}
(W)     mov (1|M0)               r2.3<1>:f     1.469368e-38:f                               {Compacted}
(W)     and (16|M0)              r4.0<1>:d     r4.0<1;1,0>:d     8388606:d               {I@1}
(W)     bfn.0xEA (16|M0)         r7.0<1>:ud    r1.2<0;0>:ud      r105.0<1;0>:ud    r6.0<0>:ud       {A@2} // s0|s1&s2
(W&f1.1) sel (16|M0)             r9.0<1>:d     r2.3<0;1,0>:d     12582912:d               {F@1}
(W)     mov (1|M0)               r3.6<1>:f     0.25:f                               {Compacted}
(W)     bfn.0xFE (16|M0)         r99.0<1>:ud   r99.0<1;0>:ud     r7.0<1;0>:ud      r4.0<1>:ud       {I@2} // s0|s1|s2
(W)     bfn.0xEA (16|M0)         r9.0<1>:ud    r9.0<1;0>:ud      r105.0<1;0>:ud    r6.0<0>:ud       {I@2} // s0|s1&s2
(W)     mad (16|M0)              r99.0<1>:f    r9.0<1;0>:f       r99.0<1;0>:f      r3.6<0>:f        {Compacted,A@1}
(W)     add (16|M0)              r99.0<1>:f    r99.0<1;1,0>:f    -r7.0<1;1,0>:f   {Compacted,F@1}
(W)     mul (16|M0)              r7.0<1>:f     r7.0<1;1,0>:f     r7.0<1;1,0>:f    {Compacted}
(W)     bfn.0xAE (16|M0)         r99.0<1>:ud   r99.0<1;0>:ud     r7.0<1;0>:ud      0x1:uw              {A@1} // s0|s1&~s2
(W&~f1.0) mov (16|M0)            r90.0<1>:f    r99.0<1;1,0>:f                   {I@1}
(W)     and (16|M0)   (ne)f1.0   null<1>:w     r98.0<2;1,0>:ub   1:w               {F@1}
(W&f1.0) mov (16|M0)             r62.0<1>:f    r90.0<1;1,0>:f                  
L5144:
        join (16|M0)                         L5400                                
L5160:
(W)     add (16|M0)              r4.0<1>:d     r65.0<1;1,0>:d    -253:w               {Compacted}
(W)     cmp (16|M0)   (lt)f1.1   null<1>:d     r4.0<1;1,0>:ud    0xFFFFFE85:ud              {I@1}
(W)     mov (1|M0)               r1.3<1>:hf    -qnan(0x1FF):hf                             
(W)     asr (16|M0)              r6.0<1>:d     r65.0<1;1,0>:d    11:w               {Compacted}
(W&f1.1.any16h) sel (1|M0)       r2.6<1>:w     r1.3<0;1,0>:w     0:w               {F@1}
(W)     add (16|M0)              r8.0<1>:d     r6.0<1;1,0>:d     248:w               {Compacted,I@2}
(W)     mov (1|M0)               f0.1<1>:uw    r2.6<0;1,0>:uw                   {I@2}
(W)     mov (16|M0)              r10.0<1>:f    r65.0<1;1,0>:f                   {Compacted}
(W&f1.1) xor (16|M0)             r10.0<1>:d    r8.0<1;1,0>:d     r6.0<1;1,0>:d    {A@1}
(W&~f0.1) mov (16|M0)            r10.0<1>:f    r65.0<1;1,0>:f                   {I@1}
(W)     asr (16|M0)              r12.0<1>:d    r10.0<1;1,0>:d    1:w               {Compacted,F@1}
(W)     mov (16|M0)              r4.0<1>:uw    r27.16<1;1,0>:ub                
(W)     add (16|M0)              r10.0<1>:d    r10.0<1;1,0>:d    -r12.0<1;1,0>:d  {Compacted,I@2}
(W)     mad (16|M0)              r96.0<1>:f    r94.0<1;0>:f      r92.0<1;0>:f      r96.0<1>:f       {Compacted}
(W)     or (16|M0)    (eq)f0.0   null<1>:w     r98.0<2;1,0>:ub   r4.0<1;1,0>:uw   {I@2}
(W)     shl (16|M0)              r12.0<1>:d    r12.0<1;1,0>:d    23:w               {Compacted}
(W)     shl (16|M0)              r10.0<1>:d    r10.0<1;1,0>:d    23:w               {Compacted,I@3}
(W)     add (16|M0)              r12.0<1>:d    r12.0<1;1,0>:d    r96.0<1;1,0>:d   {Compacted,A@1}
(W)     add (16|M0)              r10.0<1>:d    r10.0<1;1,0>:d    1065353216:d               {I@2}
(W&f0.0) mul (16|M0)             r62.0<1>:f    r12.0<1;1,0>:f    r10.0<1;1,0>:f   {A@1}
L5400:
        join (16|M0)                         L5416                                
L5416:
(W)     math.inv (16|M0)         r4.0<1>:f     r60.0<1;1,0>:f                   {$7}
(W)     mov (1|M0)               r1.2<1>:ud    0x3F800000:ud                             
(W)     mul (16|M0)              acc0.0<1>:f   r4.0<1;1,0>:f     r58.0<1;1,0>:f   {Compacted,$7.dst}
(W)     mad (16|M0)              acc2.0<1>:f   r1.2<0;0>:f       r4.0<1;0>:f       -r60.0<1>:f      {I@1}
(W)     mad (16|M0)              r10.0<1>:f    r58.0<1;0>:f      acc0.0<1;0>:f     -r60.0<1>:f     
(W)     mad (16|M0)              acc2.0<1>:f   r4.0<1;0>:f       acc2.0<1;0>:f     r4.0<1>:f        {Compacted}
(W)     mov (1|M0)               f1.1<1>:uw    r109.3<0;1,0>:uw                
(W)     mad (16|M0)              acc0.0<1>:f   acc0.0<1;0>:f     acc2.0<1;0>:f     r10.0<1>:f       {F@2}
(W)     mad (16|M0)              r58.0<1>:f    r58.0<1;0>:f      acc0.0<1;0>:f     -r60.0<1>:f     
(W&~f1.1) mad (16|M0)            r62.0<1>:f    acc0.0<1;0>:f     acc2.0<1;0>:f     r58.0<1>:f       {F@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        ret (16|M0)                          r110.2                           {A@1}
L5608:
(W)     mov (1|M0)               r1.2<1>:d     cr0.0<0;1,0>:ud                  {A@1}
(W)     and (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   -1265:w               {A@1}
(W)     or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   1264:w               {A@1}
(W)     mad (16|M0)              r105.0<1>:f   r103.0<1;0>:f     r101.0<1;0>:f     r105.0<1>:f      {Compacted,A@1}
(W)     mov (1|M0)               cr0.0<1>:ud   r1.2<0;1,0>:d                    {A@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        ret (16|M0)                          r110.6                           {A@1}
L5728:
        shr (1|M0)               r107.2<1>:ud  r110.5<0;1,0>:ud  0x17:uw             
        shr (1|M0)               r107.1<1>:ud  r110.4<0;1,0>:ud  0x17:uw             
        and (1|M0)               r107.2<1>:ud  r107.2<0;1,0>:ud  0xFF:uw              {I@2}
        and (1|M0)               r107.1<1>:ud  r107.1<0;1,0>:ud  0xFF:uw              {I@2}
        add (1|M0)               r1.3<1>:ud    r107.2<0;1,0>:ud  0xFFFFFF41:ud              {I@2}
        add (1|M0)               r1.2<1>:ud    r107.1<0;1,0>:ud  0xFFFFFF41:ud              {I@2}
        cmp (1|M0)    (lt)f1.1   null<1>:ud    r1.3<0;1,0>:ud    0xFFFFFF81:ud              {A@2}
(W)     mov (1|M0)               r2.6<1>:hf    -qnan(0x1FF):hf                             
(~f1.1) cmp (1|M0)    (lt)f1.1   null<1>:ud    r1.2<0;1,0>:ud    0xFFFFFF82:ud              {I@2}
(f1.1)  sel (1|M0)               r107.0<2>:b   r2.6<0;1,0>:w     0:w               {F@1}
        cmp (1|M0)    (ne)f1.1   null<1>:uw    r107.0<0;1,0>:ub  0x0:uw              {I@1}
(W)     and (1|M0)               f1.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(~f1.1.any16h) goto (16|M0)                  L9440                  L9440                
L5936:
        add (1|M0)               r1.3<1>:ud    r107.2<0;1,0>:ud  0xFFFFFF01:ud             
        add (1|M0)               r1.2<1>:ud    r107.1<0;1,0>:ud  0xFFFFFF01:ud             
        cmp (1|M0)    (lt)f1.0   null<1>:ud    r1.3<0;1,0>:ud    0xFFFFFF02:ud              {I@2}
(W)     mov (1|M0)               r2.6<1>:hf    -qnan(0x1FF):hf                             
        mov (1|M0)               r108.6<1>:f   (abs)r110.4<0;1,0>:f            
(~f1.0) cmp (1|M0)    (lt)f1.0   null<1>:ud    r1.2<0;1,0>:ud    0xFFFFFF02:ud              {I@2}
(f1.0)  sel (1|M0)               r107.2<2>:b   r2.6<0;1,0>:w     0:w               {F@2}
        cmp (1|M0)    (ne)f0.1   null<1>:uw    r107.2<0;1,0>:ub  0x0:uw              {I@1}
(W)     and (1|M0)               f1.0<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(f1.0.any16h) goto (16|M0)                   L6192                  L6192                
L6096:
        mov (1|M0)               r1.2<1>:f     (abs)r110.5<0;1,0>:f            
        mov (1|M0)               r108.16<2>:b  0:w                              
        add (1|M0)               r108.6<1>:d   r108.6<0;1,0>:d   -r1.2<0;1,0>:d   {A@1}
        mov (2|M0)               r109.4<1>:f   r110.4<1;1,0>:f                 
        asr (1|M0)               r108.6<1>:d   r108.6<0;1,0>:d   23:w               {I@1}
        goto (16|M0)                         L6192                  L7920                
L6192:
        join (16|M0)                         L7920                                
L6208:
        cmp (1|M0)    (gt)f0.0   null<1>:ud    r108.6<0;1,0>:ud  0x7F800000:ud              {I@3}
(W)     mov (1|M0)               r1.3<1>:hf    0xFF:hf                             
        mov (1|M0)               r108.3<1>:f   (abs)r110.5<0;1,0>:f            
(W)     mov (1|M0)               r2.7<1>:hf    -qnan(0x1FF):hf                             
(f0.0)  sel (1|M0)               r2.6<1>:w     r1.3<0;1,0>:w     0:w               {F@3}
        and (1|M0)               r107.4<1>:ud  r110.4<0;1,0>:ud  0x7F800000:ud             
        cmp (1|M0)    (eq)f0.1   null<1>:w     r2.12<0;1,0>:b    0:w               {I@2}
(W)     mov (1|M0)               r3.12<1>:uw   r2.12<0;1,0>:ub                 
        and (1|M0)               r107.5<1>:ud  r110.5<0;1,0>:ud  0x7F800000:ud             
        add (1|M0)               r110.0<1>:f   r110.4<0;1,0>:f   r110.5<0;1,0>:f 
(f0.1)  cmp (1|M0)    (gt)f0.1   null<1>:ud    r108.3<0;1,0>:ud  0x7F800000:ud              {F@3}
(W)     mov (1|M0)               r5.0<1>:f     -0.0:f                               {Compacted}
        and (1|M0)               r4.0<1>:ud    r110.5<0;1,0>:ud  0x80000000:ud             
        bfn.0x6A (1|M0)          r1.2<1>:ud    r110.4<0;0>:ud    r110.5<0;0>:ud    r5.0<0>:ud       {F@1} // s0^s1&s2
(f0.1)  sel (1|M0)               r2.16<2>:b    r2.7<0;1,0>:w     0:w              
        bfn.0x6A (1|M0)          r1.3<1>:ud    r110.5<0;0>:ud    r110.4<0;0>:ud    r5.0<0>:ud       // s0^s1&s2
        and (1|M0)    (ne)f1.0   null<1>:w     r2.16<0;1,0>:ub   1:w               {I@2}
        or (1|M0)     (eq)f0.0   r2.16<2>:ub   r2.16<0;1,0>:ub   r3.12<0;1,0>:uw 
        and (1|M0)               r107.3<1>:ud  r110.4<0;1,0>:ud  0x80000000:ud             
(f1.0)  add (1|M0)               r110.0<1>:f   r110.5<0;1,0>:f   r110.5<0;1,0>:f 
(f0.0)  cmp (1|M0)    (eq)f0.0   null<1>:d     r107.4<0;1,0>:d   2139095040:d              
(W)     mov (1|M0)               r4.2<1>:uw    r2.16<0;1,0>:ub                  {I@3}
(f0.0)  sel (1|M0)               r1.6<2>:b     r2.7<0;1,0>:w     0:w              
        and (1|M0)    (ne)f0.1   null<1>:w     r1.6<0;1,0>:ub    1:w               {I@1}
        or (1|M0)     (eq)f1.1   r1.6<2>:ub    r1.6<0;1,0>:ub    r4.2<0;1,0>:uw  
(f0.1)  add (1|M0)               r110.0<1>:f   r1.2<0;1,0>:f     -r1.3<0;1,0>:f  
(f1.1)  cmp (1|M0)    (eq)f1.1   null<1>:d     r107.5<0;1,0>:d   2139095040:d              
(W)     mov (1|M0)               r3.12<1>:uw   r1.6<0;1,0>:ub                   {I@2}
(f1.1)  sel (1|M0)               r107.26<2>:b  r2.7<0;1,0>:w     0:w              
        and (1|M0)    (ne)f0.0   null<1>:w     r107.26<0;1,0>:ub  1:w              {I@1}
        or (1|M0)     (eq)f1.0   r107.26<2>:ub  r107.26<0;1,0>:ub  r3.12<0;1,0>:uw {F@2}
(f0.0)  mul (1|M0)               r110.0<1>:f   r4.0<0;1,0>:f     r110.4<0;1,0>:f 
(f1.0)  cmp (1|M0)    (eq)f1.0   null<1>:f     r110.5<0;1,0>:f   0.0:f               {I@1}
(f1.0)  sel (1|M0)               r107.24<2>:b  r2.7<0;1,0>:w     0:w              
        cmp (1|M0)    (ne)f1.1   null<1>:uw    r107.24<0;1,0>:ub  0x0:uw             {I@1}
(W)     and (1|M0)               f0.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw              {F@3}
(f0.1.any16h) goto (16|M0)                   L6824                  L6824                
L6792:
        mov (1|M0)               r107.28<2>:b  r107.26<0;1,0>:b                
        goto (16|M0)                         L6824                  L7008                
L6824:
        join (16|M0)                         L7008                                
L6840:
(W)     mov (1|M0)               r4.0<1>:f     inf:f                               {Compacted}
        cmp (1|M0)    (eq)f1.0   null<1>:f     r110.4<0;1,0>:f   0.0:f              
        bfn.0x96 (1|M0)          r107.3<1>:ud  r107.3<0;0>:ud    r110.5<0;0>:ud    r4.0<0>:ud       {F@2} // s0^s1^s2
        xor (1|M0)               r1.2<1>:ud    r110.5<0;1,0>:ud  0x7F800000:ud             
(W)     mov (1|M0)               r2.6<1>:uw    r107.26<0;1,0>:ub               
(~f1.0) mov (1|M0)               r1.2<1>:f     r107.3<0;1,0>:f                  {A@2}
        or (1|M0)                r107.26<2>:ub  r107.24<0;1,0>:ub  r2.6<0;1,0>:uw {I@1}
(f1.0)  mul (1|M0)               r107.3<1>:f   r1.2<0;1,0>:f     r110.4<0;1,0>:f  {F@1}
        and (1|M0)    (ne)f1.0   null<1>:w     r107.24<0;1,0>:ub  1:w              {F@1}
        mov (1|M0)               r107.28<2>:b  r107.26<0;1,0>:b                 {I@2}
(f1.0)  mov (1|M0)               r110.0<1>:f   r107.3<0;1,0>:f                 
L7008:
        join (16|M0)                         L7920                                
L7024:
        cmp (1|M0)    (eq)f0.1   null<1>:w     r107.26<0;1,0>:b  0:w              
(W)     mov (1|M0)               r1.3<1>:hf    -qnan(0x1FF):hf                             
(W)     mov (1|M0)               r2.6<1>:uw    r107.28<0;1,0>:ub                {I@3}
(f0.1)  cmp (1|M0)    (eq)f0.1   null<1>:f     r110.4<0;1,0>:f   0.0:f               {I@2}
(f0.1)  sel (1|M0)               r108.16<2>:b  r1.3<0;1,0>:w     0:w               {F@2}
        and (1|M0)    (ne)f0.1   null<1>:w     r108.16<0;1,0>:ub  1:w              {A@1}
        or (1|M0)     (ne)f0.0   r108.16<2>:ub  r108.16<0;1,0>:ub  r2.6<0;1,0>:uw
(f0.1)  mul (1|M0)               r110.0<1>:f   r110.4<0;1,0>:f   r110.5<0;1,0>:f 
(W)     and (1|M0)               f0.0<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
(f0.0.any16h) goto (16|M0)                   L7920                  L9440                
L7184:
        cmp (1|M0)    (eq)f1.1   null<1>:uw    r108.16<0;1,0>:ub  0x0:uw             {I@3}
        cmp (1|M0)    (eq)f1.0   null<1>:d     r107.4<0;1,0>:d   0:w              
(~f1.1) mov (1|M0)               r107.2<2>:b   0:w                              
(f1.0)  sel (1|M0)               r108.0<1>:d   r107.2<0;1,0>:b   0:w               {I@1}
        cmp (1|M0)    (ne)f0.1   null<1>:d     r108.0<0;1,0>:d   0:w               {A@1}
(W)     and (1|M0)               f1.1<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(f1.1.any16h) goto (16|M0)                   L7344                  L7344                
L7296:
        mov (1|M0)               r108.1<1>:d   0:w                              
        mov (1|M0)               r109.4<1>:f   r110.4<0;1,0>:f                 
        goto (16|M0)                         L7344                  L7504                
L7344:
        join (16|M0)                         L7504                                
L7360:
        and (1|M0)    (ne)f0.0   r108.0<1>:d   r108.0<0;1,0>:d   1:w              
        mov (1|M0)               r109.4<1>:f   r110.4<0;1,0>:f                 
(W)     mov (1|M0)               r2.6<1>:hf    -qnan(0x1E0):hf                             
(f0.0)  mul (1|M0)               r109.4<1>:f   r110.4<0;1,0>:f   0x4F800000:f              
(f0.0)  sel (1|M0)               r108.1<1>:d   r2.6<0;1,0>:w     0:w               {F@2}
        shr (1|M0)               r1.2<1>:ud    r109.4<0;1,0>:ud  0x17:uw              {F@1}
        and (1|M0)               r1.2<1>:ud    r1.2<0;1,0>:ud    0xFF:uw              {I@1}
        add (1|M0)               r1.2<1>:ud    r1.2<0;1,0>:ud    0xFFFFFFE0:ud              {I@1}
(f0.0)  mov (1|M0)               r107.1<1>:d   r1.2<0;1,0>:d                    {I@1}
L7504:
        join (16|M0)                         L7920                                
L7520:
        cmp (1|M0)    (eq)f0.0   null<1>:d     r107.5<0;1,0>:d   0:w              
(f0.0)  sel (1|M0)               r108.2<1>:d   r107.2<0;1,0>:b   0:w              
        cmp (1|M0)    (ne)f1.1   null<1>:d     r108.2<0;1,0>:d   0:w               {I@1}
(W)     and (1|M0)               f1.0<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(f1.0.any16h) goto (16|M0)                   L7648                  L7648                
L7600:
        mov (1|M0)               r108.5<1>:d   0:w                              
        mov (1|M0)               r109.5<1>:f   r110.5<0;1,0>:f                 
        goto (16|M0)                         L7648                  L7824                
L7648:
        join (16|M0)                         L7824                                
L7664:
        and (1|M0)    (ne)f1.1   r108.2<1>:d   r108.2<0;1,0>:d   1:w              
        mov (1|M0)               r109.5<1>:f   r110.5<0;1,0>:f                 
(W)     mov (1|M0)               r2.6<1>:hf    0x20:hf                             
(f1.1)  mul (1|M0)               r109.5<1>:f   r110.5<0;1,0>:f   0x4F800000:f              
(f1.1)  sel (1|M0)               r108.5<1>:d   r2.6<0;1,0>:w     0:w               {F@2}
        shr (1|M0)               r1.2<1>:ud    r109.5<0;1,0>:ud  0x17:uw              {F@1}
        mov (1|M0)               r108.3<1>:f   (abs)r109.5<0;1,0>:f            
        and (1|M0)               r1.2<1>:ud    r1.2<0;1,0>:ud    0xFF:uw              {I@1}
        add (1|M0)               r1.2<1>:ud    r1.2<0;1,0>:ud    0xFFFFFFE0:ud              {I@1}
(f1.1)  mov (1|M0)               r107.2<1>:f   r1.2<0;1,0>:f                    {I@1}
L7824:
        join (16|M0)                         L7920                                
L7840:
        mov (1|M0)               r108.6<1>:f   (abs)r109.4<0;1,0>:f            
        add (1|M0)               r108.5<1>:d   r108.5<0;1,0>:d   r108.1<0;1,0>:d 
        add (1|M0)               r108.6<1>:d   r108.6<0;1,0>:d   -r108.3<0;1,0>:d {F@1}
        asr (1|M0)               r108.6<1>:d   r108.6<0;1,0>:d   23:w               {I@1}
        add (1|M0)               r108.5<1>:d   r108.5<0;1,0>:d   r108.6<0;1,0>:d  {I@1}
L7920:
        join (16|M0)                         L9440                                
L7936:
        cmp (1|M0)    (eq)f1.0   null<1>:uw    r107.2<0;1,0>:ub  0x0:uw             
(W)     mov (1|M0)               r1.2<1>:f     1.0:f                               {Compacted}
(W)     mov (1|M0)               r4.0<1>:f     0x807FFFFF:f                              
        cmp (1|M0)    (eq)f0.1   null<1>:w     r108.16<0;1,0>:b  0:w              
(~f1.0) mov (1|M0)               r108.6<1>:d   r108.5<0;1,0>:d                  {I@4}
        bfn.0xEA (1|M0)          r109.5<1>:ud  r1.2<0;0>:ud      r109.5<0;0>:ud    r4.0<0>:ud       {A@1} // s0|s1&s2
        add (1|M0)               r108.7<1>:d   r108.6<0;1,0>:d   126:w               {I@2}
        add (1|M0)               r109.0<1>:d   -r108.6<0;1,0>:d  -152:w               {Compacted}
        sync.nop                             null                             {Compacted,I@3}
        math.inv (1|M0)          r2.3<1>:f     r109.5<0;1,0>:f                  {$8}
        and (1|M0)               r109.0<1>:d   r109.0<0;1,0>:d   r108.7<0;1,0>:d  {Compacted,I@1}
        mov (1|M0)               r112.0<1>:f   1.0:f                               {Compacted}
        asr (1|M0)               r109.0<1>:d   r109.0<0;1,0>:d   31:w               {Compacted,I@1}
(~f0.1) mov (1|M0)               r109.0<1>:d   0:w                              
        bfn.0xEA (1|M0)          r109.4<1>:ud  r1.2<0;0>:ud      r109.4<0;0>:ud    r4.0<0>:ud       // s0|s1&s2
        cmp (1|M0)    (ne)f0.0   null<1>:d     r109.0<0;1,0>:d   0:w               {I@2}
        sync.nop                             null                             {Compacted,$8.dst}
        mad (1|M0)               r112.0<1>:f   r112.0<0;0>:f     r2.3<0;0>:f       -r109.5<0>:f     {F@1}
        mul (1|M0)               r2.4<1>:f     r2.3<0;1,0>:f     r109.4<0;1,0>:f  {I@2}
        mad (1|M0)               r112.0<1>:f   r2.3<0;0>:f       r2.3<0;0>:f       r112.0<0>:f      {F@2}
        mad (1|M0)               r112.1<1>:f   r109.4<0;0>:f     r2.4<0;0>:f       -r109.5<0>:f     {F@2}
(W)     and (1|M0)               f0.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
        mad (1|M0)               r112.1<1>:f   r2.4<0;0>:f       r112.0<0;0>:f     r112.1<0>:f      {F@1}
        add (1|M0)               r107.1<1>:d   r107.1<0;1,0>:d   -r107.2<0;1,0>:d
        mad (1|M0)               r109.4<1>:f   r109.4<0;0>:f     r112.1<0;0>:f     -r109.5<0>:f     {F@1}
(~f0.1.any16h) goto (16|M0)                  L9096                  L9096                
L8296:
        mov (1|M0)               r109.2<1>:f   r109.4<0;1,0>:f                  {F@1}
        mov (2|M0)               r111.0<1>:f   r112.0<1;1,0>:f                 
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r111.2        L9672                                 {A@1}
L8376:
        cmp (1|M0)    (eq)f1.0   null<1>:f     r109.4<0;1,0>:f   0.0:f              
(W)     mov (1|M0)               r1.3<1>:hf    0x1:hf                             
        add (1|M0)               r108.6<1>:d   r108.6<0;1,0>:d   125:w              
(W)     mov (1|M0)               r3.12<1>:hf   0x1:hf                             
(f1.0)  sel (1|M0)               r2.6<1>:w     r1.3<0;1,0>:w     0:w               {F@2}
        cmp (1|M0)    (lt)f0.0   null<1>:d     r108.6<0;1,0>:d   -2:w               {I@2}
        cmp (1|M0)    (ne)f0.1   null<1>:w     r2.6<0;1,0>:w     0:w               {I@2}
(W)     mov (1|M0)               r5.0<1>:hf    -qnan(0x1FF):hf                             
(f0.0)  sel (1|M0)               r3.13<1>:uw   r3.12<0;1,0>:uw   0x0:uw              {F@2}
(f0.1)  sel (1|M0)               r4.0<1>:uw    r3.12<0;1,0>:uw   0x0:uw             
        or (1|M0)     (ne)f1.1   null<1>:uw    r3.13<0;1,0>:uw   r4.0<0;1,0>:uw   {I@1}
(f1.1)  sel (1|M0)               r108.18<2>:b  r5.0<0;1,0>:w     0:w               {F@1}
        cmp (1|M0)    (ne)f1.1   null<1>:uw    r108.18<0;1,0>:ub  0x0:uw             {I@1}
(W)     and (1|M0)               f0.0<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(~f0.0.any16h) goto (16|M0)                  L8736                  L8736                
L8616:
(W)     mov (1|M0)               r1.3<1>:hf    0x1:hf                             
        and (1|M0)               r1.2<1>:d     r109.2<0;1,0>:d   -2139095041:d              
(W)     mov (1|M0)               r4.0<1>:f     0x800000:f                               {Compacted}
        shl (1|M0)               r108.7<1>:d   r108.7<0;1,0>:d   23:w              
(f1.0)  sel (1|M0)               r2.3<1>:d     r1.3<0;1,0>:w     0:w               {F@2}
        add (1|M0)               r108.7<1>:d   r108.7<0;1,0>:d   1065353216:d               {I@2}
        bfn.0xFE (1|M0)          r1.2<1>:ud    r1.2<0;0>:ud      r2.3<0;0>:ud      r4.0<0>:ud       {A@1} // s0|s1|s2
        mul (1|M0)               r108.7<1>:f   r108.7<0;1,0>:f   r1.2<0;1,0>:f    {A@1}
L8736:
        join (16|M0)                         L9096                                
L8752:
        and (1|M0)               r1.2<1>:d     r109.2<0;1,0>:d   -2147483648:d               {F@1}
        shl (1|M0)               r109.2<1>:d   r109.2<0;1,0>:d   1:w              
(W)     mov (1|M0)               r1.3<1>:hf    0x1:hf                             
        and (1|M0)               r1.3<1>:d     r109.2<0;1,0>:d   8388606:d               {I@1}
        and (1|M0)    (eq)f1.1   r109.2<1>:d   r109.2<0;1,0>:d   8388608:d              
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
        cmp (1|M0)    (eq)f0.0   null<1>:uw    r108.18<0;1,0>:ub  0x0:uw            
        add (1|M0)               r2.3<1>:f     r2.3<0;1,0>:f     -r2.4<0;1,0>:f   {A@1}
        mul (1|M0)               r2.4<1>:f     r2.4<0;1,0>:f     r2.4<0;1,0>:f   
        and (1|M0)    (ne)f1.1   null<1>:d     r109.0<0;1,0>:d   1:w              
        and (1|M0)               r2.4<1>:d     r2.4<0;1,0>:d     -2:w               {F@1}
        or (1|M0)                r2.4<1>:d     r2.4<0;1,0>:d     r2.3<0;1,0>:d    {I@1}
(~f0.0) mov (1|M0)               r2.4<1>:f     r108.7<0;1,0>:f                  {I@1}
(f1.1)  mov (1|M0)               r110.0<1>:f   r2.4<0;1,0>:f                    {F@1}
L9096:
        join (16|M0)                         L9440                                
L9112:
        add (1|M0)               r2.3<1>:d     r107.1<0;1,0>:d   126:w              
(W)     mov (1|M0)               r1.3<1>:uw    r109.0<0;1,0>:ub                
        cmp (1|M0)    (gt)f0.0   null<1>:ud    r2.3<0;1,0>:ud    0x17A:uw              {I@2}
        mad (1|M0)               r109.4<1>:f   r112.1<0;0>:f     r112.0<0;0>:f     r109.4<0>:f     
        or (1|M0)                r109.2<1>:w   r108.16<0;1,0>:ub  r1.3<0;1,0>:uw  {I@2}
(W)     and (1|M0)               f1.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw              {F@2}
(~f1.1.any16h) goto (16|M0)                  L9304                  L9304                
L9224:
(f0.0)  sel (1|M0)               r1.2<1>:d     r107.1<0;1,0>:d   0:w              
        asr (1|M0)               r1.2<1>:d     r1.2<0;1,0>:d     11:w               {I@1}
        add (1|M0)               r1.3<1>:d     r1.2<0;1,0>:d     248:w               {I@1}
        xor (1|M0)               r1.3<1>:d     r1.3<0;1,0>:d     r1.2<0;1,0>:d    {I@1}
(f0.0)  mov (1|M0)               r107.1<1>:d   r1.3<0;1,0>:d                    {I@1}
L9304:
        join (16|M0)                         L9440                                
L9320:
        asr (1|M0)               r1.2<1>:d     r107.1<0;1,0>:d   1:w               {I@2}
        cmp (1|M0)    (eq)f1.0   null<1>:w     r109.2<0;1,0>:w   0:w              
        add (1|M0)               r107.1<1>:d   r107.1<0;1,0>:d   -r1.2<0;1,0>:d   {I@2}
        shl (1|M0)               r1.2<1>:d     r1.2<0;1,0>:d     23:w              
        shl (1|M0)               r107.1<1>:d   r107.1<0;1,0>:d   23:w               {Compacted,I@2}
        add (1|M0)               r1.2<1>:d     r1.2<0;1,0>:d     r109.4<0;1,0>:d  {A@1}
        add (1|M0)               r107.1<1>:d   r107.1<0;1,0>:d   1065353216:d               {I@2}
(f1.0)  mul (1|M0)               r110.0<1>:f   r107.1<0;1,0>:f   r1.2<0;1,0>:f    {I@1}
L9440:
        join (16|M0)                         L9456                                
L9456:
        sync.nop                             null                             {Compacted,F@1}
        math.inv (1|M0)          r1.2<1>:f     r110.5<0;1,0>:f                  {$9}
        mov (1|M0)               r1.4<1>:ud    0x3F800000:ud                             
        mul (1|M0)               r1.3<1>:f     r1.2<0;1,0>:f     r110.4<0;1,0>:f  {$9.dst}
        mad (1|M0)               r1.4<1>:f     r1.4<0;0>:f       r1.2<0;0>:f       -r110.5<0>:f     {I@1}
        mad (1|M0)               r2.3<1>:f     r110.4<0;0>:f     r1.3<0;0>:f       -r110.5<0>:f     {F@2}
        mad (1|M0)               r1.4<1>:f     r1.2<0;0>:f       r1.2<0;0>:f       r1.4<0>:f        {F@2}
        cmp (1|M0)    (eq)f0.1   null<1>:uw    r107.0<0;1,0>:ub  0x0:uw             
        mad (1|M0)               r2.3<1>:f     r1.3<0;0>:f       r1.4<0;0>:f       r2.3<0>:f        {F@1}
        mad (1|M0)               r110.4<1>:f   r110.4<0;0>:f     r2.3<0;0>:f       -r110.5<0>:f     {F@1}
(f0.1)  mad (1|M0)               r110.0<1>:f   r2.3<0;0>:f       r1.4<0;0>:f       r110.4<0>:f      {F@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        ret (16|M0)                          r109.6                           {A@1}
L9672:
        mov (1|M0)               r1.2<1>:d     cr0.0<0;1,0>:ud                  {A@1}
        and (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   -1265:w               {A@1}
        or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   1264:w               {A@1}
        mad (1|M0)               r109.2<1>:f   r111.1<0;0>:f     r111.0<0;0>:f     r109.2<0>:f      {A@1}
        mov (1|M0)               cr0.0<1>:ud   r1.2<0;1,0>:d                    {A@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        ret (16|M0)                          r111.2                           {A@1}
L9800:
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
