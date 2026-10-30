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
        mov (1|M0)               r15.0<1>:d    r0.1<0;1,0>:ud                   {A@1}
        sync.nop                             null                             {Compacted,$1.dst}
        add (1|M0)               r1.2<1>:d     r2.7<0;1,0>:d     -1:w               {$0.dst}
        mul (1|M0)               r15.0<1>:d    r15.0<0;1,0>:d    0xFFFF:uw              {I@2}
        shr (1|M0)               r14.0<1>:ud   r2.6<0;1,0>:ud    0x4:uw             
        add (1|M0)               r15.0<1>:d    r15.0<0;1,0>:d    r0.6<0;1,0>:d    {Compacted,I@2}
        mov (1|M0)               r14.1<1>:d    r1.1<0;1,0>:uw                  
(W)     mul (1|M0)               acc0.0<1>:d   r15.0<0;1,0>:d    r2.2<0;1,0>:uw   {Compacted,I@2}
        mach (1|M0)              r15.0<1>:d    r15.0<0;1,0>:d    r2.1<0;1,0>:d    {Compacted}
        mov (16|M0)              r16.0<1>:f    0.0:f                               {Compacted}
        add (1|M0)               r15.0<1>:d    r15.0<0;1,0>:d    r1.1<0;1,0>:uw   {I@1}
        cmp (1|M0)    (lt)f0.1   null<1>:ud    r15.0<0;1,0>:ud   r2.7<0;1,0>:ud   {I@1}
(W)     mov (1|M0)               r74.2<1>:uw   f0.1<0;1,0>:uw                  
(W)     mov (1|M0)               f0.0<1>:uw    r74.2<0;1,0>:uw                  {I@1}
(f0.0)  mov (1|M0)               r1.2<1>:d     r15.0<0;1,0>:d                  
        cmp (1|M0)    (lt)f0.0   null<1>:ud    r2.6<0;1,0>:ud    0x10:uw             
        mul (1|M0)               acc0.0<1>:ud  r1.2<0;1,0>:ud    r2.12<0;1,0>:uw  {I@2}
        mach (1|M0)              r5.0<1>:ud    r1.2<0;1,0>:ud    r2.6<0;1,0>:ud   {AccWrEn}
        mov (1|M0)               r4.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        shl (1|M0)               r2.3<1>:d     r5.0<0;1,0>:d     1:w               {Compacted,I@2}
        shl (1|M0)               r3.6<1>:d     r4.0<0;1,0>:d     1:w               {Compacted,I@2}
(W)     and (1|M0)               f0.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
        shr (1|M0)               r2.4<1>:ud    r4.0<0;1,0>:ud    0x1F:uw             
        addc (1|M0)              r6.0<1>:ud    r3.0<0;1,0>:ud    r3.6<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r3.7<1>:d     r2.3<0;1,0>:d     r2.4<0;1,0>:d    {I@2}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r14.2<1>:d    r6.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r14.3<1>:d    r7.0<0;0>:d       r3.1<0;0>:d       r3.7<0>:d        {I@2}
(f0.1.any16h) goto (16|M0)                   L1048                  L1048                
L600:
        sel (1|M0)    (ge)f0.0   r14.4<1>:ud   r14.0<0;1,0>:ud   0x1:uw             
        mov (1|M0)               r14.5<1>:d    0:w                              
        mov (1|M0)               r14.6<2>:f    0.0:f                              
        mov (1|M0)               r14.7<2>:f    0.0:f                              
L664:
        shl (1|M0)               r1.2<1>:d     r14.7<0;1,0>:d    4:w               {F@1}
        shr (1|M0)               r1.3<1>:ud    r14.6<0;1,0>:ud   0x1C:uw             
        shl (1|M0)               r1.4<1>:d     r14.6<0;1,0>:d    4:w              
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        shl (1|M0)               r3.6<1>:d     r1.4<0;1,0>:d     1:w               {I@2}
        shr (1|M0)               r2.4<1>:ud    r1.4<0;1,0>:ud    0x1F:uw             
        shl (1|M0)               r2.3<1>:d     r1.5<0;1,0>:d     1:w               {I@3}
        addc (1|M0)              r4.0<1>:ud    r14.2<0;1,0>:ud   r3.6<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r3.7<1>:d     r2.3<0;1,0>:d     r2.4<0;1,0>:d    {I@2}
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r6.0<1>:f     r4.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r6.1<1>:d     r5.0<0;0>:d       r14.3<0;0>:d      r3.7<0>:d        {I@1}
        addc (1|M0)              r10.0<1>:ud   r14.6<0;1,0>:ud   0x1:ud              {AccWrEn}
        send.ugm (1|M0)          r7       r6      null:0  0x0            0x0210B780           {A@1,$2} // wr:1+0, rd:1; load.ugm.d64x4t.a64
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r15.2<1>:d    r10.0<0;1,0>:d                   {I@2}
        add3 (1|M0)              r15.3<1>:d    r11.0<0;0>:d      r14.7<0;0>:d      0:w               {I@2}
        cmp (1|M0)    (eq)f1.0   null<1>:d     r15.3<0;1,0>:d    r14.5<0;1,0>:d   {I@1}
(f1.0)  cmp (1|M0)    (eq)f1.0   null<1>:d     r15.2<0;1,0>:d    r14.4<0;1,0>:d  
(W)     and (1|M0)               f1.1<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
        mov (8|M0)               r8.0<1>:f     (abs)r7.0<1;1,0>:hf              {$2.dst}
        mov (8|M0)               r9.0<1>:f     (abs)r7.8<1;1,0>:hf             
        sel (16|M0)   (ge)f0.0   r16.0<1>:f    r16.0<1;1,0>:f    r8.0<1;1,0>:f    {Compacted,F@1}
(f1.1.any16h) goto (16|M0)                   L1048                  L1048                
L1016:
(W)     mov (2|M0)               r14.6<1>:ud   r15.2<1;1,0>:ud                 
        goto.b (16|M0)                       L1048                  L664                
L1048:
        join (16|M0)                         L1064                                
L1064:
        sel (8|M0)    (ge)f0.0   r5.0<1>:f     r16.0<1;1,0>:f    r17.0<1;1,0>:f   {Compacted,F@1}
        shl (1|M0)               r4.0<1>:d     r14.1<0;1,0>:d    2:w               {Compacted}
        mov (4|M0)               r6.0<1>:ud    r5.4<1;1,0>:ud                   {F@1}
        sel (4|M0)    (ge)f0.0   r7.0<1>:f     r5.0<1;1,0>:f     r6.0<1;1,0>:f    {I@1}
        mov (2|M0)               r8.0<1>:ud    r7.2<1;1,0>:ud                   {F@1}
        sel (2|M0)    (ge)f0.0   r9.0<1>:f     r7.0<1;1,0>:f     r8.0<1;1,0>:f    {I@1}
        sel (1|M0)    (ge)f0.0   r10.0<1>:f    r9.0<0;1,0>:f     r9.1<0;1,0>:f    {F@1}
        send.slm (1|M0)          null     r4      r10:1   0x0            0x02000504           {A@1,$3} // wr:1+1, rd:0; store.slm.d32.a32
(W)     send.slm (1|M0)          r11      r0      null:0  0x0            0x0210001F           {$4} // wr:1+0, rd:1; fence.slm.none.group
(W)     mov (1|M0)               r12.2<1>:f    0.0:f                               {Compacted}
(W)     mov (2|M0)               r12.10<1>:ub  r0.11<0;1,0>:ub                  {F@1}
(W)     mov (8|M0)               null<1>:ud    r11.0<1;1,0>:ud                  {$4.dst}
(W)     send.gtwy (1|M0)         null     r12     null:0  0x0            0x02000004           {A@2,$5} // wr:1+0, rd:0; signal barrier
(W)     sync.bar                             null                            
        send.slm (1|M0)          r71      r4      null:0  0x0            0x02100500           {$6} // wr:1+0, rd:1; load.slm.d32.a32
        sel (1|M0)    (ge)f0.0   r71.0<1>:f    r71.0<0;1,0>:f    0.0:f               {$6.dst}
        cmp (1|M0)    (eq)f0.1   null<1>:f     r71.0<0;1,0>:f    0.0:f               {F@1}
(W)     and (1|M0)               f1.0<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(f1.0.any16h) goto (16|M0)                   L1424                  L1424                
L1344:
        mov (1|M0)               r15.1<1>:f    127.0:f                              
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r73.2         L5744                                 {A@1}
L1408:
        goto (16|M0)                         L1424                  L1448                
L1424:
        join (16|M0)                         L1448                                
L1440:
        mov (1|M0)               r74.0<1>:f    1.0:f                               {Compacted}
L1448:
        join (16|M0)                         L1464                                
L1464:
(W)     and (1|M0)               f0.1<1>:uw    r74.2<0;1,0>:uw   0x1:uw              {F@3}
        mov (1|M0)               r15.4<1>:d    r15.0<0;1,0>:d                  
        mov (1|M0)               r15.5<1>:d    0:w                              
(~f0.1.any16h) goto (16|M0)                  L1656                  L1656                
L1528:
        shl (1|M0)               r1.4<1>:d     r15.4<0;1,0>:d    2:w               {I@3}
        shl (1|M0)               r1.2<1>:d     r15.5<0;1,0>:d    2:w               {I@3}
        shr (1|M0)               r1.3<1>:ud    r15.4<0;1,0>:ud   0x1E:uw             
        addc (1|M0)              r4.0<1>:ud    r3.2<0;1,0>:ud    r1.4<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r6.0<1>:f     r4.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r6.1<1>:d     r5.0<0;0>:d       r3.3<0;0>:d       r1.5<0>:d        {I@1}
        send.ugm (1|M0)          null     r6      r74:1   0x0            0x04000584           {A@1,$7} // wr:2+1, rd:0; store.ugm.d32.a64
L1656:
        join (16|M0)                         L1672                                
L1672:
        mul (1|M0)               acc0.0<1>:ud  r15.0<0;1,0>:ud   r14.0<0;1,0>:uw 
        mach (1|M0)              r5.0<1>:ud    r15.0<0;1,0>:ud   r14.0<0;1,0>:ud  {AccWrEn}
(W)     and (1|M0)               f0.0<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
        mov (1|M0)               r4.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        shl (1|M0)               r1.2<1>:d     r5.0<0;1,0>:d     4:w               {Compacted,I@3}
        shl (1|M0)               r1.4<1>:d     r4.0<0;1,0>:d     4:w               {Compacted,I@2}
        shr (1|M0)               r1.3<1>:ud    r4.0<0;1,0>:ud    0x1C:uw             
        sync.nop                             null                             {Compacted,$7.src}
        addc (1|M0)              r6.0<1>:ud    r3.4<0;1,0>:ud    r1.4<0;1,0>:ud   {AccWrEn,I@2}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (16|M0)              r18.0<1>:f    r74.0<0;1,0>:f                   {Compacted}
        mov (1|M0)               r15.6<1>:d    r6.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r15.7<1>:d    r7.0<0;0>:d       r3.5<0;0>:d       r1.5<0>:d        {I@2}
(f0.0.any16h) goto (16|M0)                   L2544                  L2544                
L1864:
        sel (1|M0)    (ge)f0.0   r20.0<1>:ud   r14.0<0;1,0>:ud   0x1:uw             
        mov (1|M0)               r20.1<1>:d    0:w                              
        mov (1|M0)               r20.2<2>:f    0.0:f                              
        mov (1|M0)               r20.3<2>:f    0.0:f                              
L1928:
(W)     and (1|M0)               f1.1<1>:uw    r74.2<0;1,0>:uw   0x1:uw             
(~f1.1.any16h) goto (16|M0)                  L2376                  L2376                
L1960:
        shl (1|M0)               r1.2<1>:d     r20.3<0;1,0>:d    4:w               {F@1}
        shr (1|M0)               r1.3<1>:ud    r20.2<0;1,0>:ud   0x1C:uw             
        shl (1|M0)               r20.4<1>:d    r20.2<0;1,0>:d    4:w              
        or (1|M0)                r20.5<1>:d    r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        shl (1|M0)               r3.6<1>:d     r20.4<0;1,0>:d    1:w               {I@2}
        shr (1|M0)               r2.4<1>:ud    r20.4<0;1,0>:ud   0x1F:uw             
        shl (1|M0)               r2.3<1>:d     r20.5<0;1,0>:d    1:w               {I@3}
        addc (1|M0)              r4.0<1>:ud    r14.2<0;1,0>:ud   r3.6<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r3.7<1>:d     r2.3<0;1,0>:d     r2.4<0;1,0>:d    {I@2}
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        sync.nop                             null                             {Compacted,$8.src}
        mov (1|M0)               r6.0<1>:f     r4.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r6.1<1>:d     r5.0<0;0>:d       r14.3<0;0>:d      r3.7<0>:d        {I@1}
        mov (16|M0)              r28.0<1>:f    r18.0<1;1,0>:f                   {Compacted}
        send.ugm (1|M0)          r7       r6      null:0  0x0            0x0210B780           {A@1,$9} // wr:1+0, rd:1; load.ugm.d64x4t.a64
        mov (8|M0)               r21.0<1>:f    r7.0<1;1,0>:hf                   {$9.dst}
        mov (8|M0)               r22.0<1>:f    r7.8<1;1,0>:hf                  
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r73.4         L2616                                 {A@1}
L2248:
        rnde (16|M0)             r63.0<1>:f    r63.0<1;1,0>:f                   {Compacted}
        sel (16|M0)   (ge)f0.0   r63.0<1>:f    r63.0<1;1,0>:f    -127.0:f               {F@1}
        addc (1|M0)              r7.0<1>:ud    r15.6<0;1,0>:ud   r20.4<0;1,0>:ud  {AccWrEn}
        sel (16|M0)   (lt)f0.0   r63.0<1>:f    r63.0<1;1,0>:f    127.0:f               {F@1}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (16|M0)              r4.0<1>:d     r63.0<1;1,0>:f                   {Compacted,F@1}
        mov (1|M0)               r9.0<1>:f     r7.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r9.1<1>:d     r8.0<0;0>:d       r15.7<0;0>:d      r20.5<0>:d       {I@2}
        mov (16|M0)              r6.0<1>:b     r4.0<4;1,0>:b                    {I@2}
        send.ugm (1|M0)          null     r9      r6:1    0x0            0x02009784           {A@1,$8} // wr:1+1, rd:0; store.ugm.d64x2t.a64
L2376:
        join (16|M0)                         L2544                                
L2392:
        addc (1|M0)              r4.0<1>:ud    r20.2<0;1,0>:ud   0x1:ud              {AccWrEn}
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r20.6<1>:d    r4.0<0;1,0>:d                    {I@2}
        add3 (1|M0)              r20.7<1>:d    r5.0<0;0>:d       r20.3<0;0>:d      0:w               {I@2}
        cmp (1|M0)    (eq)f1.0   null<1>:d     r20.7<0;1,0>:d    r20.1<0;1,0>:d   {I@1}
(f1.0)  cmp (1|M0)    (eq)f1.0   null<1>:d     r20.6<0;1,0>:d    r20.0<0;1,0>:d  
(W)     and (1|M0)               f1.0<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
(f1.0.any16h) goto (16|M0)                   L2544                  L2544                
L2512:
(W)     mov (2|M0)               r20.2<1>:ud   r20.6<1;1,0>:ud                 
        goto.b (16|M0)                       L2544                  L1928                
L2544:
        join (16|M0)                         L2560                                
L2560:
(W)     mov (8|M0)               r127.0<1>:f   r0.0<1;1,0>:f                    {Compacted}
(W)     send.ugm (1|M0)          r4       r0      null:0  0x0            0x0210641F           {$10} // wr:1+0, rd:1; fence invalid flush type scoped to tile
(W)     mov (8|M0)               null<1>:ud    r4.0<1;1,0>:ud                   {$10.dst}
(W)     send.gtwy (1|M0)         null     r127    null:0  0x0            0x02000010           {EOT,A@1} // wr:1+0, rd:0; end of thread
L2616:
(W)     shr (16|M0)              r4.0<1>:ud    r21.0<1;1,0>:ud   0x17:uw             
(W)     and (16|M0)              r23.0<1>:w    r4.0<2;1,0>:w     255:w               {I@1}
(W)     add (16|M0)              r8.0<1>:d     r23.0<1;1,0>:uw   -191:w               {I@1}
(W)     cmp (16|M0)   (lt)f1.1   null<1>:d     r8.0<1;1,0>:ud    0xFFFFFF82:ud              {I@1}
(W)     shr (16|M0)              r6.0<1>:ud    r28.0<1;1,0>:ud   0x17:uw             
(W)     mov (1|M0)               r73.1<1>:uw   f1.1<0;1,0>:uw                   {Compacted}
(W)     and (16|M0)              r30.0<1>:w    r6.0<2;1,0>:w     255:w               {I@2}
(W)     mov (1|M0)               f1.0<1>:uw    r73.1<0;1,0>:uw                  {I@2}
(W)     add (16|M0)              r10.0<1>:d    r30.0<1;1,0>:uw   -191:w               {I@2}
(W)     mov (16|M0)              r24.0<1>:d    r23.0<1;1,0>:uw                 
(W&~f1.0) cmp (16|M0) (lt)f1.0   null<1>:d     r10.0<1;1,0>:ud   0xFFFFFF81:ud              {I@2}
(W)     mov (16|M0)              r26.0<1>:d    r23.0<1;1,0>:uw                 
(W)     mov (1|M0)               r73.1<1>:uw   f1.0<0;1,0>:uw                   {Compacted}
(W)     mov (16|M0)              r31.0<1>:d    r30.0<1;1,0>:uw                 
(W)     mov (1|M0)               f0.1<1>:uw    r73.1<0;1,0>:uw                  {I@2}
(W)     mov (16|M0)              r33.0<1>:d    r30.0<1;1,0>:uw                 
(~f0.1.any16h) goto (16|M0)                  L5416                  L5416                
L2872:
(W)     add (16|M0)              r4.0<1>:d     r23.0<1;1,0>:uw   -255:w              
(W)     cmp (16|M0)   (lt)f1.1   null<1>:d     r4.0<1;1,0>:ud    0xFFFFFF02:ud              {I@1}
(W)     add (16|M0)              r6.0<1>:d     r30.0<1;1,0>:uw   -255:w              
(W&~f1.1) cmp (16|M0) (lt)f1.1   null<1>:d     r6.0<1;1,0>:ud    0xFFFFFF02:ud              {I@1}
(W)     mov (16|M0)              r45.0<1>:f    (abs)r21.0<1;1,0>:f              {Compacted}
(f1.1.any16h) goto (16|M0)                   L3032                  L3032                
L2960:
(W)     mov (16|M0)              r4.0<1>:f     (abs)r28.0<1;1,0>:f              {Compacted}
(W)     add (16|M0)              r45.0<1>:d    r45.0<1;1,0>:d    -r4.0<1;1,0>:d   {Compacted,A@1}
(W)     mov (4|M0)               r49.0<1>:d    0:w                              
(W)     mov (16|M0)              r58.0<1>:f    r21.0<1;1,0>:f                   {Compacted}
(W)     mov (16|M0)              r47.0<1>:f    r28.0<1;1,0>:f                   {Compacted}
(W)     asr (16|M0)              r45.0<1>:d    r45.0<1;1,0>:d    23:w               {Compacted,I@2}
        goto (16|M0)                         L3032                  L4288                
L3032:
        join (16|M0)                         L4288                                
L3048:
(W)     mov (16|M0)              r43.0<1>:f    (abs)r28.0<1;1,0>:f              {Compacted}
(W)     cmp (16|M0)   (gt)f1.0   null<1>:d     r45.0<1;1,0>:ud   0x7F800000:ud              {I@3}
(W)     cmp (16|M0)   (lt)f0.1   null<1>:d     r43.0<1;1,0>:ud   0x7F800001:ud              {F@1}
(W)     mov (1|M0)               r1.3<1>:uw    f1.0<0;1,0>:uw                  
(W)     and (16|M0)              r35.0<1>:ud   r21.0<1;1,0>:ud   0x7F800000:ud             
(W)     or (1|M0)                f0.0<1>:uw    f0.1<0;1,0>:uw    r1.3<0;1,0>:uw   {I@2}
(W)     and (16|M0)              r37.0<1>:ud   r28.0<1;1,0>:ud   0x7F800000:ud             
(W)     mov (1|M0)               r2.6<1>:uw    f0.1<0;1,0>:uw                  
(W)     cmp (16|M0)   (ne)f0.1   null<1>:d     r35.0<1;1,0>:d    2139095040:d               {I@4}
(W&f0.0) sel (16|M0)             acc0.0<1>:f   r21.0<1;1,0>:f    r28.0<1;1,0>:f  
(W)     or (1|M0)                r3.12<1>:uw   f1.0<0;1,0>:uw    ~r2.6<0;1,0>:uw  {I@2}
(W)     cmp (16|M0)   (ne)f0.0   null<1>:d     r37.0<1;1,0>:d    2139095040:d               {F@1}
(W)     or (1|M0)                r3.13<1>:uw   f0.1<0;1,0>:uw    r3.12<0;1,0>:uw  {I@2}
(W)     or (1|M0)                r3.12<1>:uw   ~f0.1<0;1,0>:uw   r3.12<0;1,0>:uw 
(W)     mov (1|M0)               r8.0<1>:f     -0.0:f                               {Compacted}
(W)     mov (1|M0)               f1.0<1>:uw    r3.13<0;1,0>:uw                  {I@2}
(W)     cmp (16|M0)   (eq)f0.1   null<1>:f     r28.0<1;1,0>:f    0.0:f               {I@2}
(W)     or (1|M0)                r1.3<1>:uw    f0.0<0;1,0>:uw    r3.12<0;1,0>:uw 
(W)     or (1|M0)                r3.12<1>:uw   ~f0.0<0;1,0>:uw   r3.12<0;1,0>:uw 
(W)     bfn.0x6A (16|M0)         r63.0<1>:ud   r21.0<1;0>:ud     r28.0<1;0>:ud     r8.0<0>:ud       {F@2} // s0^s1&s2
(W)     bfn.0x6A (16|M0)         r9.0<1>:ud    r28.0<1;0>:ud     r21.0<1;0>:ud     r8.0<0>:ud       // s0^s1&s2
(W)     mov (1|M0)               f0.0<1>:uw    r3.12<0;1,0>:uw                  {I@3}
(W)     mov (1|M0)               r2.6<1>:hf    -qnan(0x1FF):hf                             
(W)     add (16|M0)              r63.0<1>:f    r63.0<1;1,0>:f    -r9.0<1;1,0>:f   {Compacted,A@2}
(W&f1.0) add (16|M0)             r63.0<1>:f    acc0.0<1;1,0>:f   r28.0<1;1,0>:f  
(W)     and (1|M0)               r4.0<1>:uw    f0.1<0;1,0>:uw    ~r3.12<0;1,0>:uw
(W&f0.0) sel (16|M0)             r11.0<2>:b    r2.6<0;1,0>:w     0:w               {F@3}
(W)     mov (1|M0)               f1.0<1>:uw    r1.3<0;1,0>:uw                   {F@1}
(W)     mov (1|M0)               f0.0<1>:uw    r4.0<0;1,0>:uw                   {I@3}
(W)     and (16|M0)              r6.0<1>:ud    r28.0<1;1,0>:ud   0x80000000:ud             
(W)     and (16|M0)              r39.0<1>:ud   r21.0<1;1,0>:ud   0x80000000:ud             
(W)     mov (16|M0)              r49.0<1>:b    r11.0<2;1,0>:b                   {I@5}
(W&~f1.0) mul (16|M0)            r63.0<1>:f    r6.0<1;1,0>:f     r21.0<1;1,0>:f   {I@3}
(~f0.0) goto (16|M0)                         L3688                  L3688                
L3568:
(W)     cmp (16|M0)   (eq)f1.0   null<1>:f     r21.0<1;1,0>:f    0.0:f              
(W)     mov (1|M0)               r1.2<1>:ud    0x7F800000:ud                             
(W)     mov (1|M0)               r2.12<2>:b    -1:w                              
(W&f1.0) mov (16|M0)             r39.0<1>:ud   0:w                              
(W)     bfn.0x96 (16|M0)         r39.0<1>:ud   r1.2<0;0>:ud      r39.0<1;0>:ud     r28.0<1>:ud      {I@1} // s0^s1^s2
(W&f1.0) mul (16|M0)             r39.0<1>:f    r39.0<1;1,0>:f    r21.0<1;1,0>:f   {I@1}
        mov (16|M0)              r49.0<1>:b    r2.12<0;1,0>:b                  
        mov (16|M0)              r63.0<1>:f    r39.0<1;1,0>:f                   {Compacted,F@1}
L3688:
        join (16|M0)                         L4288                                
L3704:
(W)     cmp (16|M0)   (eq)f0.0   null<1>:f     r21.0<1;1,0>:f    0.0:f               {Compacted}
(W&f0.0) cmp (16|M0)  (eq)f0.0   null<1>:w     r49.0<1;1,0>:ub   0x0:uw              {A@1}
(W&~f0.0) sel (16|M0)            r4.0<2>:b     r49.0<1;1,0>:b    -1:w              
(W)     mov (16|M0)              r49.0<1>:b    r4.0<2;1,0>:b                    {I@1}
(W)     cmp (16|M0)   (ne)f1.0   null<1>:w     r49.0<1;1,0>:ub   0x0:uw              {I@1}
(W&f0.0) mul (16|M0)             r63.0<1>:f    r21.0<1;1,0>:f    r28.0<1;1,0>:f  
(f1.0.all16h) goto (16|M0)                   L4288                  L5416                
L3808:
(W)     cmp (16|M0)   (eq)f1.0   null<1>:w     r49.0<1;1,0>:ub   0x0:uw             
(W)     mov (1|M0)               r1.3<1>:uw    f1.1<0;1,0>:uw                  
(W)     cmp (16|M0)   (eq)f0.1   null<1>:d     r35.0<1;1,0>:d    0:w              
(W)     and (1|M0)               f1.1<1>:uw    f1.0<0;1,0>:uw    r1.3<0;1,0>:uw   {I@2}
(W)     mov (16|M0)              r50.0<1>:d    0:w                              
(W)     mov (1|M0)               r2.6<1>:uw    f0.1<0;1,0>:uw                  
(W)     mov (16|M0)              r58.0<1>:f    r21.0<1;1,0>:f                   {Compacted}
(W)     and (1|M0)               f0.1<1>:uw    f1.1<0;1,0>:uw    r2.6<0;1,0>:uw   {I@1}
(W)     mov (16|M0)              r41.0<1>:f    r50.0<1;1,0>:f                   {Compacted}
(~f0.1) goto (16|M0)                         L4048                  L4048                
L3952:
        mul (16|M0)              r58.0<1>:f    r21.0<1;1,0>:f    0x4F800000:f               {Compacted}
(W)     shr (16|M0)              r4.0<1>:ud    r58.0<1;1,0>:ud   0x17:uw              {F@1}
(W)     and (16|M0)              r6.0<1>:w     r4.0<2;1,0>:w     255:w               {I@1}
        add (16|M0)              r26.0<1>:d    r6.0<1;1,0>:uw    -32:w               {I@1}
(W)     mov (16|M0)              r41.0<1>:d    0:w                              
(W)     mov (16|M0)              r24.0<1>:f    r26.0<1;1,0>:f                   {Compacted,I@2}
        mov (16|M0)              r41.0<1>:d    -32:w                              
L4048:
        join (16|M0)                         L4288                                
L4064:
(W)     cmp (16|M0)   (eq)f0.0   null<1>:d     r37.0<1;1,0>:d    0:w               {Compacted}
(W)     mov (16|M0)              r47.0<1>:f    r28.0<1;1,0>:f                   {Compacted}
(W)     mov (1|M0)               r1.3<1>:uw    f0.0<0;1,0>:uw                  
(W)     and (1|M0)               f0.0<1>:uw    f1.1<0;1,0>:uw    r1.3<0;1,0>:uw   {I@1}
(~f0.0) goto (16|M0)                         L4232                  L4232                
L4128:
        mul (16|M0)              r47.0<1>:f    r28.0<1;1,0>:f    0x4F800000:f               {Compacted}
(W)     shr (16|M0)              r4.0<1>:ud    r47.0<1;1,0>:ud   0x17:uw              {F@1}
(W)     and (16|M0)              r6.0<1>:w     r4.0<2;1,0>:w     255:w               {I@1}
        add (16|M0)              r33.0<1>:d    r6.0<1;1,0>:uw    -32:w               {I@1}
(W)     mov (16|M0)              r50.0<1>:d    0:w                              
(W)     mov (16|M0)              r43.0<1>:f    (abs)r47.0<1;1,0>:f              {Compacted}
(W)     mov (16|M0)              r31.0<1>:f    r33.0<1;1,0>:f                   {Compacted,I@2}
        mov (16|M0)              r50.0<1>:d    32:w                              
L4232:
        join (16|M0)                         L4288                                
L4248:
(W)     mov (16|M0)              r45.0<1>:f    (abs)r58.0<1;1,0>:f              {Compacted}
(W)     add (16|M0)              r45.0<1>:d    r45.0<1;1,0>:d    -r43.0<1;1,0>:d  {Compacted,F@1}
(W)     asr (16|M0)              r45.0<1>:d    r45.0<1;1,0>:d    23:w               {Compacted,I@1}
(W)     add3 (16|M0)             r50.0<1>:d    r50.0<1;0>:d      r41.0<1;0>:d      r45.0<1>:d       {I@1}
L4288:
        join (16|M0)                         L5416                                
L4304:
(W)     mov (1|M0)               r1.2<1>:f     1.0:f                               {Compacted}
(W)     mov (1|M0)               r4.0<1>:f     0x807FFFFF:f                              
(W&~f1.1) mov (16|M0)            r50.0<1>:f    r45.0<1;1,0>:f                   {I@2}
(W)     bfn.0xEA (16|M0)         r47.0<1>:ud   r1.2<0;0>:ud      r47.0<1;0>:ud     r4.0<0>:ud       {A@2} // s0|s1&s2
(W)     add (16|M0)              r52.0<1>:d    r50.0<1;1,0>:d    126:w               {Compacted,F@1}
(W)     add (16|M0)              r5.0<1>:d     -r50.0<1;1,0>:d   -152:w               {Compacted}
        sync.nop                             null                             {Compacted,I@3}
(W)     math.inv (16|M0)         r7.0<1>:f     r47.0<1;1,0>:f                   {$11}
(W)     cmp (16|M0)   (eq)f1.0   null<1>:w     r49.0<1;1,0>:ub   0x0:uw             
(W)     and (16|M0)              r5.0<1>:d     r5.0<1;1,0>:d     r52.0<1;1,0>:d   {Compacted,I@2}
(W)     mov (1|M0)               r2.3<1>:f     1.0:f                               {Compacted}
(W)     bfn.0xEA (16|M0)         r58.0<1>:ud   r1.2<0;0>:ud      r58.0<1;0>:ud     r4.0<0>:ud       // s0|s1&s2
(W)     asr (16|M0)              r5.0<1>:d     r5.0<1;1,0>:d     31:w               {Compacted,I@2}
        sync.nop                             null                             {Compacted,$11.dst}
(W)     mad (16|M0)              r54.0<1>:f    r2.3<0;0>:f       r7.0<1;0>:f       -r47.0<1>:f      {F@1}
(W)     mul (16|M0)              acc0.0<1>:f   r7.0<1;1,0>:f     r58.0<1;1,0>:f   {Compacted,I@2}
(W&f1.0) sel (16|M0)             r60.0<1>:w    r5.0<4;1,0>:ub    0:w               {I@1}
(W)     mad (16|M0)              r54.0<1>:f    r7.0<1;0>:f       r7.0<1;0>:f       r54.0<1>:f       {Compacted,F@2}
(W)     mad (16|M0)              r56.0<1>:f    r58.0<1;0>:f      acc0.0<1;0>:f     -r47.0<1>:f     
(W)     cmp (16|M0)   (ne)f0.1   null<1>:w     r60.0<2;1,0>:ub   0x0:uw              {I@1}
(W)     mad (16|M0)              r56.0<1>:f    acc0.0<1;0>:f     r54.0<1;0>:f      r56.0<1>:f       {F@1}
(W)     add (16|M0)              r24.0<1>:d    r24.0<1;1,0>:d    -r31.0<1;1,0>:d  {Compacted}
(W)     mad (16|M0)              r58.0<1>:f    r58.0<1;0>:f      r56.0<1;0>:f      -r47.0<1>:f      {Compacted,F@1}
(~f0.1.any16h) goto (16|M0)                  L5160                  L5160                
L4592:
(W)     mov (16|M0)              r69.0<1>:ud   r58.0<1;1,0>:ud                  {F@1}
(W)     mov (16|M0)              r65.0<1>:f    r54.0<1;1,0>:f                   {Compacted}
(W)     mov (16|M0)              r67.0<1>:f    r56.0<1;1,0>:f                   {Compacted}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r73.6         L5624                                 {A@1}
L4672:
(W)     add (16|M0)              r50.0<1>:d    r50.0<1;1,0>:d    125:w               {Compacted}
(W)     cmp (16|M0)   (lt)f1.1   null<1>:d     r50.0<1;1,0>:d    -2:w               {I@1}
(W)     cmp (16|M0)   (eq)f0.0   null<1>:f     r58.0<1;1,0>:f    0.0:f               {Compacted}
(W)     mov (1|M0)               r1.3<1>:uw    f1.1<0;1,0>:uw                  
(W)     or (1|M0)                f1.1<1>:uw    f0.0<0;1,0>:uw    r1.3<0;1,0>:uw   {I@1}
(f1.1.any16h) goto (16|M0)                   L4800                  L4800                
L4752:
(W)     mov (1|M0)               r1.3<1>:hf    0x1:hf                              {I@2}
(W&f0.0) sel (16|M0)             r61.0<1>:d    r1.3<0;1,0>:w     0:w               {F@1}
        goto (16|M0)                         L4800                  L4920                
L4800:
        join (16|M0)                         L4920                                
L4816:
(W)     mov (1|M0)               r1.3<1>:hf    0x1:hf                              {I@3}
(W)     and (16|M0)              r4.0<1>:d     r69.0<1;1,0>:d    -2139095041:d              
(W)     mov (1|M0)               r6.0<1>:f     0x800000:f                               {Compacted}
(W)     shl (16|M0)              r52.0<1>:d    r52.0<1;1,0>:d    23:w               {Compacted}
(W&f0.0) sel (16|M0)             r61.0<1>:d    r1.3<0;1,0>:w     0:w               {F@2}
(W)     add (16|M0)              r52.0<1>:d    r52.0<1;1,0>:d    1065353216:d               {I@2}
(W)     bfn.0xFE (16|M0)         r4.0<1>:ud    r4.0<1;0>:ud      r61.0<1;0>:ud     r6.0<0>:ud       {A@1} // s0|s1|s2
(W)     mul (16|M0)              r52.0<1>:f    r52.0<1;1,0>:f    r4.0<1;1,0>:f    {Compacted,A@1}
L4920:
        join (16|M0)                         L5160                                
L4936:
(W)     and (16|M0)   (eq)f1.0   null<1>:ud    r69.0<1;1,0>:ud   0x400000:ud             
(W)     shl (16|M0)              r4.0<1>:d     r69.0<1;1,0>:d    1:w               {Compacted,F@1}
(W)     mov (1|M0)               r1.2<1>:f     0x800000:f                               {Compacted}
(W)     mov (1|M0)               r6.0<1>:f     -0.0:f                               {Compacted}
(W)     mov (1|M0)               r2.3<1>:f     1.469368e-38:f                               {Compacted}
(W)     and (16|M0)              r4.0<1>:d     r4.0<1;1,0>:d     8388606:d               {I@1}
(W)     bfn.0xEA (16|M0)         r7.0<1>:ud    r1.2<0;0>:ud      r69.0<1;0>:ud     r6.0<0>:ud       {A@2} // s0|s1&s2
(W&f1.0) sel (16|M0)             r9.0<1>:d     r2.3<0;1,0>:d     12582912:d               {F@1}
(W)     mov (1|M0)               r3.6<1>:f     0.25:f                               {Compacted}
(W)     bfn.0xFE (16|M0)         r61.0<1>:ud   r61.0<1;0>:ud     r7.0<1;0>:ud      r4.0<1>:ud       {I@2} // s0|s1|s2
(W)     bfn.0xEA (16|M0)         r9.0<1>:ud    r9.0<1;0>:ud      r69.0<1;0>:ud     r6.0<0>:ud       {I@2} // s0|s1&s2
(W)     mad (16|M0)              r61.0<1>:f    r9.0<1;0>:f       r61.0<1;0>:f      r3.6<0>:f        {Compacted,A@1}
(W)     add (16|M0)              r61.0<1>:f    r61.0<1;1,0>:f    -r7.0<1;1,0>:f   {Compacted,F@1}
(W)     mul (16|M0)              r7.0<1>:f     r7.0<1;1,0>:f     r7.0<1;1,0>:f    {Compacted}
(W)     and (16|M0)   (ne)f0.0   null<1>:w     r60.0<2;1,0>:ub   1:w              
(W)     bfn.0xAE (16|M0)         r61.0<1>:ud   r61.0<1;0>:ud     r7.0<1;0>:ud      0x1:uw              {A@1} // s0|s1&~s2
(W&~f1.1) mov (16|M0)            r52.0<1>:f    r61.0<1;1,0>:f                   {I@1}
(W&f0.0) mov (16|M0)             r63.0<1>:f    r52.0<1;1,0>:f                   {F@1}
L5160:
        join (16|M0)                         L5416                                
L5176:
(W)     add (16|M0)              r4.0<1>:d     r24.0<1;1,0>:d    -253:w               {Compacted}
(W)     cmp (16|M0)   (lt)f0.1   null<1>:d     r4.0<1;1,0>:ud    0xFFFFFE85:ud              {I@1}
(W)     mov (1|M0)               r1.3<1>:hf    -qnan(0x1FF):hf                             
(W)     asr (16|M0)              r6.0<1>:d     r24.0<1;1,0>:d    11:w               {Compacted}
(W&f0.1.any16h) sel (1|M0)       r2.6<1>:w     r1.3<0;1,0>:w     0:w               {F@1}
(W)     add (16|M0)              r8.0<1>:d     r6.0<1;1,0>:d     248:w               {Compacted,I@2}
(W)     mov (1|M0)               f1.1<1>:uw    r2.6<0;1,0>:uw                   {I@2}
(W)     mov (16|M0)              r10.0<1>:f    r24.0<1;1,0>:f                   {Compacted}
(W&f0.1) xor (16|M0)             r10.0<1>:d    r8.0<1;1,0>:d     r6.0<1;1,0>:d    {A@1}
(W&~f1.1) mov (16|M0)            r10.0<1>:f    r24.0<1;1,0>:f                   {I@1}
(W)     asr (16|M0)              r12.0<1>:d    r10.0<1;1,0>:d    1:w               {Compacted,F@1}
(W)     mov (16|M0)              r4.0<1>:uw    r49.0<1;1,0>:ub                 
(W)     add (16|M0)              r10.0<1>:d    r10.0<1;1,0>:d    -r12.0<1;1,0>:d  {Compacted,I@2}
(W)     mad (16|M0)              r58.0<1>:f    r56.0<1;0>:f      r54.0<1;0>:f      r58.0<1>:f       {Compacted}
(W)     or (16|M0)    (eq)f1.0   null<1>:w     r60.0<2;1,0>:ub   r4.0<1;1,0>:uw   {I@2}
(W)     shl (16|M0)              r12.0<1>:d    r12.0<1;1,0>:d    23:w               {Compacted}
(W)     shl (16|M0)              r10.0<1>:d    r10.0<1;1,0>:d    23:w               {Compacted,I@3}
(W)     add (16|M0)              r12.0<1>:d    r12.0<1;1,0>:d    r58.0<1;1,0>:d   {Compacted,A@1}
(W)     add (16|M0)              r10.0<1>:d    r10.0<1;1,0>:d    1065353216:d               {I@2}
(W&f1.0) mul (16|M0)             r63.0<1>:f    r12.0<1;1,0>:f    r10.0<1;1,0>:f   {A@1}
L5416:
        join (16|M0)                         L5432                                
L5432:
(W)     math.inv (16|M0)         r4.0<1>:f     r28.0<1;1,0>:f                   {$12}
(W)     mov (1|M0)               r1.2<1>:ud    0x3F800000:ud                             
(W)     mul (16|M0)              acc0.0<1>:f   r4.0<1;1,0>:f     r21.0<1;1,0>:f   {Compacted,$12.dst}
(W)     mad (16|M0)              acc2.0<1>:f   r1.2<0;0>:f       r4.0<1;0>:f       -r28.0<1>:f      {I@1}
(W)     mad (16|M0)              r10.0<1>:f    r21.0<1;0>:f      acc0.0<1;0>:f     -r28.0<1>:f     
(W)     mad (16|M0)              acc2.0<1>:f   r4.0<1;0>:f       acc2.0<1;0>:f     r4.0<1>:f        {Compacted}
(W)     mov (1|M0)               f0.0<1>:uw    r73.1<0;1,0>:uw                 
(W)     mad (16|M0)              acc0.0<1>:f   acc0.0<1;0>:f     acc2.0<1;0>:f     r10.0<1>:f       {F@2}
(W)     mad (16|M0)              r21.0<1>:f    r21.0<1;0>:f      acc0.0<1;0>:f     -r28.0<1>:f     
(W&~f0.0) mad (16|M0)            r63.0<1>:f    acc0.0<1;0>:f     acc2.0<1;0>:f     r21.0<1>:f       {F@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        ret (16|M0)                          r73.4                            {A@1}
L5624:
(W)     mov (1|M0)               r1.2<1>:d     cr0.0<0;1,0>:ud                  {A@1}
(W)     and (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   -1265:w               {A@1}
(W)     or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   1264:w               {A@1}
(W)     mad (16|M0)              r69.0<1>:f    r67.0<1;0>:f      r65.0<1;0>:f      r69.0<1>:f       {Compacted,A@1}
(W)     mov (1|M0)               cr0.0<1>:ud   r1.2<0;1,0>:d                    {A@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        ret (16|M0)                          r73.6                            {A@1}
L5744:
        shr (1|M0)               r49.6<1>:ud   r15.1<0;1,0>:ud   0x17:uw             
        shr (1|M0)               r49.5<1>:ud   r71.0<0;1,0>:ud   0x17:uw             
        and (1|M0)               r49.6<1>:ud   r49.6<0;1,0>:ud   0xFF:uw              {I@2}
        and (1|M0)               r49.5<1>:ud   r49.5<0;1,0>:ud   0xFF:uw              {I@2}
        add (1|M0)               r1.3<1>:ud    r49.6<0;1,0>:ud   0xFFFFFF41:ud              {I@2}
        add (1|M0)               r1.2<1>:ud    r49.5<0;1,0>:ud   0xFFFFFF41:ud              {I@2}
        cmp (1|M0)    (lt)f0.1   null<1>:ud    r1.3<0;1,0>:ud    0xFFFFFF81:ud              {I@2}
(W)     mov (1|M0)               r2.6<1>:hf    -qnan(0x1FF):hf                             
(~f0.1) cmp (1|M0)    (lt)f0.1   null<1>:ud    r1.2<0;1,0>:ud    0xFFFFFF82:ud              {I@2}
(f0.1)  sel (1|M0)               r49.16<2>:b   r2.6<0;1,0>:w     0:w               {F@1}
        cmp (1|M0)    (ne)f0.1   null<1>:uw    r49.16<0;1,0>:ub  0x0:uw              {I@1}
(W)     and (1|M0)               f0.1<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(~f0.1.any16h) goto (16|M0)                  L9376                  L9376                
L5952:
        add (1|M0)               r1.3<1>:ud    r49.6<0;1,0>:ud   0xFFFFFF01:ud             
        add (1|M0)               r1.2<1>:ud    r49.5<0;1,0>:ud   0xFFFFFF01:ud             
        cmp (1|M0)    (lt)f1.1   null<1>:ud    r1.3<0;1,0>:ud    0xFFFFFF02:ud              {I@2}
(W)     mov (1|M0)               r2.6<1>:hf    -qnan(0x1FF):hf                             
        mov (1|M0)               r72.3<1>:f    (abs)r71.0<0;1,0>:f              {Compacted}
(~f1.1) cmp (1|M0)    (lt)f1.1   null<1>:ud    r1.2<0;1,0>:ud    0xFFFFFF02:ud              {I@2}
(f1.1)  sel (1|M0)               r49.18<2>:b   r2.6<0;1,0>:w     0:w               {F@2}
        cmp (1|M0)    (ne)f0.1   null<1>:uw    r49.18<0;1,0>:ub  0x0:uw              {I@1}
(W)     and (1|M0)               f1.1<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(f1.1.any16h) goto (16|M0)                   L6192                  L6192                
L6104:
        mov (1|M0)               r1.2<1>:f     (abs)r15.1<0;1,0>:f             
        mov (1|M0)               r71.18<2>:b   0:w                              
        add (1|M0)               r72.3<1>:d    r72.3<0;1,0>:d    -r1.2<0;1,0>:d   {A@1}
        mov (1|M0)               r76.0<1>:f    r71.0<0;1,0>:f                   {Compacted}
        mov (1|M0)               r72.1<1>:f    r15.1<0;1,0>:f                   {Compacted}
        asr (1|M0)               r72.3<1>:d    r72.3<0;1,0>:d    23:w               {Compacted,I@1}
        goto (16|M0)                         L6192                  L7840                
L6192:
        join (16|M0)                         L7840                                
L6208:
        cmp (1|M0)    (gt)f1.1   null<1>:ud    r72.3<0;1,0>:ud   0x7F800000:ud              {I@3}
(W)     mov (1|M0)               r1.3<1>:hf    0xFF:hf                             
        mov (1|M0)               r72.0<1>:f    (abs)r15.1<0;1,0>:f              {Compacted}
(W)     mov (1|M0)               r2.7<1>:hf    -qnan(0x1FF):hf                             
(f1.1)  sel (1|M0)               r2.6<1>:w     r1.3<0;1,0>:w     0:w               {F@3}
        and (1|M0)               r71.1<1>:ud   r71.0<0;1,0>:ud   0x7F800000:ud             
        cmp (1|M0)    (eq)f1.0   null<1>:w     r2.12<0;1,0>:b    0:w               {I@2}
(W)     mov (1|M0)               r3.12<1>:uw   r2.12<0;1,0>:ub                 
        add (1|M0)               r74.0<1>:f    r71.0<0;1,0>:f    r15.1<0;1,0>:f   {Compacted}
        and (1|M0)               r71.2<1>:ud   r15.1<0;1,0>:ud   0x7F800000:ud             
(f1.0)  cmp (1|M0)    (gt)f1.0   null<1>:ud    r72.0<0;1,0>:ud   0x7F800000:ud              {F@3}
(W)     mov (1|M0)               r5.0<1>:f     -0.0:f                               {Compacted}
        and (1|M0)               r4.0<1>:ud    r15.1<0;1,0>:ud   0x80000000:ud             
        bfn.0x6A (1|M0)          r1.2<1>:ud    r71.0<0;0>:ud     r15.1<0;0>:ud     r5.0<0>:ud       {F@1} // s0^s1&s2
(f1.0)  sel (1|M0)               r2.16<2>:b    r2.7<0;1,0>:w     0:w              
        bfn.0x6A (1|M0)          r1.3<1>:ud    r15.1<0;0>:ud     r71.0<0;0>:ud     r5.0<0>:ud       // s0^s1&s2
        and (1|M0)    (ne)f1.1   null<1>:w     r2.16<0;1,0>:ub   1:w               {I@2}
        or (1|M0)     (eq)f0.1   r2.16<2>:ub   r2.16<0;1,0>:ub   r3.12<0;1,0>:uw 
        and (1|M0)               r49.7<1>:ud   r71.0<0;1,0>:ud   0x80000000:ud             
(f1.1)  add (1|M0)               r74.0<1>:f    r15.1<0;1,0>:f    r15.1<0;1,0>:f  
(f0.1)  cmp (1|M0)    (eq)f0.1   null<1>:d     r71.1<0;1,0>:d    2139095040:d              
(W)     mov (1|M0)               r4.2<1>:uw    r2.16<0;1,0>:ub                  {I@3}
(f0.1)  sel (1|M0)               r1.6<2>:b     r2.7<0;1,0>:w     0:w              
        and (1|M0)    (ne)f1.0   null<1>:w     r1.6<0;1,0>:ub    1:w               {I@1}
        or (1|M0)     (eq)f1.1   r1.6<2>:ub    r1.6<0;1,0>:ub    r4.2<0;1,0>:uw   {F@1}
(f1.0)  add (1|M0)               r74.0<1>:f    r1.2<0;1,0>:f     -r1.3<0;1,0>:f  
(f1.1)  cmp (1|M0)    (eq)f1.1   null<1>:d     r71.2<0;1,0>:d    2139095040:d              
(W)     mov (1|M0)               r3.12<1>:uw   r1.6<0;1,0>:ub                   {I@2}
(f1.1)  sel (1|M0)               r71.14<2>:b   r2.7<0;1,0>:w     0:w              
        and (1|M0)    (ne)f0.1   null<1>:w     r71.14<0;1,0>:ub  1:w               {I@1}
        or (1|M0)     (eq)f1.0   r71.14<2>:ub  r71.14<0;1,0>:ub  r3.12<0;1,0>:uw  {F@1}
(f0.1)  mul (1|M0)               r74.0<1>:f    r4.0<0;1,0>:f     r71.0<0;1,0>:f  
(f1.0)  cmp (1|M0)    (eq)f1.0   null<1>:f     r15.1<0;1,0>:f    0.0:f               {I@1}
(f1.0)  sel (1|M0)               r71.12<2>:b   r2.7<0;1,0>:w     0:w              
        cmp (1|M0)    (ne)f1.1   null<1>:uw    r71.12<0;1,0>:ub  0x0:uw              {I@1}
(W)     and (1|M0)               f1.0<1>:uw    f1.1<0;1,0>:uw    0x1:uw              {F@1}
(f1.0.any16h) goto (16|M0)                   L6808                  L6808                
L6776:
        mov (1|M0)               r71.16<2>:b   r71.14<0;1,0>:b                 
        goto (16|M0)                         L6808                  L6992                
L6808:
        join (16|M0)                         L6992                                
L6824:
(W)     mov (1|M0)               r4.0<1>:f     inf:f                               {Compacted}
        cmp (1|M0)    (eq)f0.1   null<1>:f     r71.0<0;1,0>:f    0.0:f              
        bfn.0x96 (1|M0)          r49.7<1>:ud   r49.7<0;0>:ud     r15.1<0;0>:ud     r4.0<0>:ud       {F@2} // s0^s1^s2
        xor (1|M0)               r1.2<1>:ud    r15.1<0;1,0>:ud   0x7F800000:ud             
        and (1|M0)    (ne)f1.0   null<1>:w     r71.12<0;1,0>:ub  1:w              
(W)     mov (1|M0)               r2.6<1>:uw    r71.14<0;1,0>:ub                
(~f0.1) mov (1|M0)               r1.2<1>:f     r49.7<0;1,0>:f                   {A@3}
        or (1|M0)                r71.14<2>:ub  r71.12<0;1,0>:ub  r2.6<0;1,0>:uw   {I@1}
(f0.1)  mul (1|M0)               r49.7<1>:f    r1.2<0;1,0>:f     r71.0<0;1,0>:f   {F@1}
        mov (1|M0)               r71.16<2>:b   r71.14<0;1,0>:b                  {I@1}
(f1.0)  mov (1|M0)               r74.0<1>:f    r49.7<0;1,0>:f                   {F@1}
L6992:
        join (16|M0)                         L7840                                
L7008:
        cmp (1|M0)    (eq)f0.1   null<1>:w     r71.14<0;1,0>:b   0:w              
(W)     mov (1|M0)               r1.3<1>:hf    -qnan(0x1FF):hf                             
(W)     mov (1|M0)               r2.6<1>:uw    r71.16<0;1,0>:ub                 {I@3}
(f0.1)  cmp (1|M0)    (eq)f0.1   null<1>:f     r71.0<0;1,0>:f    0.0:f               {I@2}
(f0.1)  sel (1|M0)               r71.18<2>:b   r1.3<0;1,0>:w     0:w               {F@2}
        and (1|M0)    (ne)f0.1   null<1>:w     r71.18<0;1,0>:ub  1:w               {A@1}
        or (1|M0)     (ne)f1.1   r71.18<2>:ub  r71.18<0;1,0>:ub  r2.6<0;1,0>:uw  
(f0.1)  mul (1|M0)               r74.0<1>:f    r71.0<0;1,0>:f    r15.1<0;1,0>:f  
(W)     and (1|M0)               f0.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw              {F@1}
(f0.1.any16h) goto (16|M0)                   L7840                  L9376                
L7168:
        cmp (1|M0)    (eq)f1.0   null<1>:uw    r71.18<0;1,0>:ub  0x0:uw              {I@3}
        cmp (1|M0)    (eq)f0.1   null<1>:d     r71.1<0;1,0>:d    0:w              
(~f1.0) mov (1|M0)               r49.18<2>:b   0:w                              
(f0.1)  sel (1|M0)               r71.5<1>:d    r49.18<0;1,0>:b   0:w               {I@1}
        cmp (1|M0)    (ne)f1.1   null<1>:d     r71.5<0;1,0>:d    0:w               {I@1}
(W)     and (1|M0)               f1.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(f1.1.any16h) goto (16|M0)                   L7320                  L7320                
L7280:
        mov (1|M0)               r71.6<1>:d    0:w                              
        mov (1|M0)               r76.0<1>:f    r71.0<0;1,0>:f                   {Compacted}
        goto (16|M0)                         L7320                  L7472                
L7320:
        join (16|M0)                         L7472                                
L7336:
        and (1|M0)    (ne)f1.1   r71.5<1>:d    r71.5<0;1,0>:d    1:w              
        mov (1|M0)               r76.0<1>:f    r71.0<0;1,0>:f                   {Compacted}
(W)     mov (1|M0)               r2.6<1>:hf    -qnan(0x1E0):hf                             
(f1.1)  mul (1|M0)               r76.0<1>:f    r71.0<0;1,0>:f    0x4F800000:f              
(f1.1)  sel (1|M0)               r71.6<1>:d    r2.6<0;1,0>:w     0:w               {F@2}
        shr (1|M0)               r1.2<1>:ud    r76.0<0;1,0>:ud   0x17:uw              {F@1}
        and (1|M0)               r1.2<1>:ud    r1.2<0;1,0>:ud    0xFF:uw              {I@1}
        add (1|M0)               r1.2<1>:ud    r1.2<0;1,0>:ud    0xFFFFFFE0:ud              {I@1}
(f1.1)  mov (1|M0)               r49.5<1>:d    r1.2<0;1,0>:d                    {I@1}
L7472:
        join (16|M0)                         L7840                                
L7488:
        cmp (1|M0)    (eq)f1.0   null<1>:d     r71.2<0;1,0>:d    0:w              
(f1.0)  sel (1|M0)               r71.7<1>:d    r49.18<0;1,0>:b   0:w              
        cmp (1|M0)    (ne)f0.1   null<1>:d     r71.7<0;1,0>:d    0:w               {I@1}
(W)     and (1|M0)               f1.0<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(f1.0.any16h) goto (16|M0)                   L7608                  L7608                
L7568:
        mov (1|M0)               r72.2<1>:d    0:w                              
        mov (1|M0)               r72.1<1>:f    r15.1<0;1,0>:f                   {Compacted}
        goto (16|M0)                         L7608                  L7768                
L7608:
        join (16|M0)                         L7768                                
L7624:
        and (1|M0)    (ne)f1.0   r71.7<1>:d    r71.7<0;1,0>:d    1:w              
        mov (1|M0)               r72.1<1>:f    r15.1<0;1,0>:f                   {Compacted}
(W)     mov (1|M0)               r2.6<1>:hf    0x20:hf                             
(f1.0)  mul (1|M0)               r72.1<1>:f    r15.1<0;1,0>:f    0x4F800000:f              
(f1.0)  sel (1|M0)               r72.2<1>:d    r2.6<0;1,0>:w     0:w               {F@2}
        shr (1|M0)               r1.2<1>:ud    r72.1<0;1,0>:ud   0x17:uw              {F@1}
        mov (1|M0)               r72.0<1>:f    (abs)r72.1<0;1,0>:f              {Compacted}
        and (1|M0)               r1.2<1>:ud    r1.2<0;1,0>:ud    0xFF:uw              {I@1}
        add (1|M0)               r1.2<1>:ud    r1.2<0;1,0>:ud    0xFFFFFFE0:ud              {I@1}
(f1.0)  mov (1|M0)               r49.6<1>:d    r1.2<0;1,0>:d                    {I@1}
L7768:
        join (16|M0)                         L7840                                
L7784:
        mov (1|M0)               r72.3<1>:f    (abs)r76.0<0;1,0>:f              {Compacted}
        add (1|M0)               r72.2<1>:d    r72.2<0;1,0>:d    r71.6<0;1,0>:d  
        add (1|M0)               r72.3<1>:d    r72.3<0;1,0>:d    -r72.0<0;1,0>:d  {Compacted,F@1}
        asr (1|M0)               r72.3<1>:d    r72.3<0;1,0>:d    23:w               {Compacted,I@1}
        add (1|M0)               r72.2<1>:d    r72.2<0;1,0>:d    r72.3<0;1,0>:d   {I@1}
L7840:
        join (16|M0)                         L9376                                
L7856:
        cmp (1|M0)    (eq)f1.1   null<1>:uw    r49.18<0;1,0>:ub  0x0:uw             
(W)     mov (1|M0)               r1.2<1>:f     1.0:f                               {Compacted}
(W)     mov (1|M0)               r4.0<1>:f     0x807FFFFF:f                              
        cmp (1|M0)    (eq)f1.0   null<1>:w     r71.18<0;1,0>:b   0:w              
(~f1.1) mov (1|M0)               r72.3<1>:d    r72.2<0;1,0>:d                   {I@4}
        bfn.0xEA (1|M0)          r72.1<1>:ud   r1.2<0;0>:ud      r72.1<0;0>:ud     r4.0<0>:ud       {A@1} // s0|s1&s2
        add (1|M0)               r72.4<1>:d    r72.3<0;1,0>:d    126:w               {I@2}
        add (1|M0)               r72.6<1>:d    -r72.3<0;1,0>:d   -152:w              
        sync.nop                             null                             {Compacted,I@3}
        math.inv (1|M0)          r2.3<1>:f     r72.1<0;1,0>:f                   {$13}
        and (1|M0)               r72.6<1>:d    r72.6<0;1,0>:d    r72.4<0;1,0>:d   {I@1}
        mov (1|M0)               r76.1<1>:f    1.0:f                               {Compacted}
        asr (1|M0)               r72.6<1>:d    r72.6<0;1,0>:d    31:w               {I@1}
(~f1.0) mov (1|M0)               r72.6<1>:d    0:w                              
        bfn.0xEA (1|M0)          r76.0<1>:ud   r1.2<0;0>:ud      r76.0<0;0>:ud     r4.0<0>:ud       // s0|s1&s2
        cmp (1|M0)    (ne)f0.1   null<1>:d     r72.6<0;1,0>:d    0:w               {I@2}
        sync.nop                             null                             {Compacted,$13.dst}
        mad (1|M0)               r76.1<1>:f    r76.1<0;0>:f      r2.3<0;0>:f       -r72.1<0>:f      {F@1}
        mul (1|M0)               r2.4<1>:f     r2.3<0;1,0>:f     r76.0<0;1,0>:f   {I@2}
        mad (1|M0)               r76.1<1>:f    r2.3<0;0>:f       r2.3<0;0>:f       r76.1<0>:f       {F@2}
        mad (1|M0)               r72.5<1>:f    r76.0<0;0>:f      r2.4<0;0>:f       -r72.1<0>:f      {F@2}
(W)     and (1|M0)               f0.1<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
        mad (1|M0)               r72.5<1>:f    r2.4<0;0>:f       r76.1<0;0>:f      r72.5<0>:f       {F@1}
        add (1|M0)               r49.5<1>:d    r49.5<0;1,0>:d    -r49.6<0;1,0>:d 
        mad (1|M0)               r76.0<1>:f    r76.0<0;0>:f      r72.5<0;0>:f      -r72.1<0>:f      {F@1}
(~f0.1.any16h) goto (16|M0)                  L9024                  L9024                
L8240:
        mov (2|M0)               r75.0<1>:f    r76.0<1;1,0>:f                   {F@1}
        mov (1|M0)               r73.1<1>:f    r72.5<0;1,0>:f                  
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r74.2         L9608                                 {A@1}
L8320:
        cmp (1|M0)    (eq)f1.0   null<1>:f     r76.0<0;1,0>:f    0.0:f              
(W)     mov (1|M0)               r1.3<1>:hf    0x1:hf                             
        add (1|M0)               r72.3<1>:d    r72.3<0;1,0>:d    125:w               {Compacted}
(W)     mov (1|M0)               r3.12<1>:hf   0x1:hf                             
(f1.0)  sel (1|M0)               r2.6<1>:w     r1.3<0;1,0>:w     0:w               {F@2}
        cmp (1|M0)    (lt)f1.1   null<1>:d     r72.3<0;1,0>:d    -2:w               {I@2}
        cmp (1|M0)    (ne)f0.1   null<1>:w     r2.6<0;1,0>:w     0:w               {I@2}
(W)     mov (1|M0)               r5.0<1>:hf    -qnan(0x1FF):hf                             
(f1.1)  sel (1|M0)               r3.13<1>:uw   r3.12<0;1,0>:uw   0x0:uw              {F@2}
(f0.1)  sel (1|M0)               r4.0<1>:uw    r3.12<0;1,0>:uw   0x0:uw             
        or (1|M0)     (ne)f1.1   null<1>:uw    r3.13<0;1,0>:uw   r4.0<0;1,0>:uw   {I@1}
(f1.1)  sel (1|M0)               r72.28<2>:b   r5.0<0;1,0>:w     0:w               {F@1}
        cmp (1|M0)    (ne)f1.1   null<1>:uw    r72.28<0;1,0>:ub  0x0:uw              {I@1}
(W)     and (1|M0)               f1.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(~f1.1.any16h) goto (16|M0)                  L8672                  L8672                
L8552:
(W)     mov (1|M0)               r1.3<1>:hf    0x1:hf                             
        and (1|M0)               r1.2<1>:d     r75.0<0;1,0>:d    -2139095041:d              
(W)     mov (1|M0)               r4.0<1>:f     0x800000:f                               {Compacted}
        shl (1|M0)               r72.4<1>:d    r72.4<0;1,0>:d    23:w              
(f1.0)  sel (1|M0)               r2.3<1>:d     r1.3<0;1,0>:w     0:w               {F@2}
        add (1|M0)               r72.4<1>:d    r72.4<0;1,0>:d    1065353216:d               {I@2}
        bfn.0xFE (1|M0)          r1.2<1>:ud    r1.2<0;0>:ud      r2.3<0;0>:ud      r4.0<0>:ud       {A@1} // s0|s1|s2
        mul (1|M0)               r72.4<1>:f    r72.4<0;1,0>:f    r1.2<0;1,0>:f    {A@1}
L8672:
        join (16|M0)                         L9024                                
L8688:
        and (1|M0)               r1.2<1>:d     r75.0<0;1,0>:d    -2147483648:d               {F@1}
        shl (1|M0)               r75.0<1>:d    r75.0<0;1,0>:d    1:w               {Compacted}
(W)     mov (1|M0)               r1.3<1>:hf    0x1:hf                             
        and (1|M0)               r1.3<1>:d     r75.0<0;1,0>:d    8388606:d               {I@1}
        and (1|M0)    (eq)f1.0   r75.0<1>:d    r75.0<0;1,0>:d    8388608:d              
(W)     mov (1|M0)               r2.5<1>:f     1.469368e-38:f                               {Compacted}
(f0.1)  sel (1|M0)               r2.3<1>:d     r1.3<0;1,0>:w     0:w               {F@2}
(W)     mov (1|M0)               r3.7<1>:f     0x800000:f                               {Compacted}
        or (1|M0)                r2.3<1>:d     r1.2<0;1,0>:d     r2.3<0;1,0>:d    {I@1}
(f1.0)  sel (1|M0)               r3.6<1>:d     r2.5<0;1,0>:d     12582912:d               {F@2}
        mov (1|M0)               r4.0<1>:f     0.25:f                               {Compacted}
        bfn.0xFE (1|M0)          r2.3<1>:ud    r3.7<0;0>:ud      r2.3<0;0>:ud      r1.3<0>:ud       {A@2} // s0|s1|s2
        or (1|M0)                r3.6<1>:d     r3.6<0;1,0>:d     r1.2<0;1,0>:d    {I@2}
        or (1|M0)                r2.4<1>:d     r1.2<0;1,0>:d     8388608:d              
        mad (1|M0)               r2.3<1>:f     r3.6<0;0>:f       r4.0<0;0>:f       r2.3<0>:f        {A@1}
        cmp (1|M0)    (eq)f1.0   null<1>:uw    r72.28<0;1,0>:ub  0x0:uw             
        add (1|M0)               r2.3<1>:f     r2.3<0;1,0>:f     -r2.4<0;1,0>:f   {A@1}
        mul (1|M0)               r2.4<1>:f     r2.4<0;1,0>:f     r2.4<0;1,0>:f   
        and (1|M0)    (ne)f0.1   null<1>:d     r72.6<0;1,0>:d    1:w              
        and (1|M0)               r2.4<1>:d     r2.4<0;1,0>:d     -2:w               {F@1}
        or (1|M0)                r2.4<1>:d     r2.4<0;1,0>:d     r2.3<0;1,0>:d    {I@1}
(~f1.0) mov (1|M0)               r2.4<1>:f     r72.4<0;1,0>:f                   {I@1}
(f0.1)  mov (1|M0)               r74.0<1>:f    r2.4<0;1,0>:f                    {F@1}
L9024:
        join (16|M0)                         L9376                                
L9040:
        add (1|M0)               r2.3<1>:d     r49.5<0;1,0>:d    126:w              
(W)     mov (1|M0)               r1.3<1>:uw    r72.24<0;1,0>:ub                
        cmp (1|M0)    (gt)f1.1   null<1>:ud    r2.3<0;1,0>:ud    0x17A:uw              {I@2}
        mad (1|M0)               r76.0<1>:f    r72.5<0;0>:f      r76.1<0;0>:f      r76.0<0>:f      
        or (1|M0)                r73.0<1>:w    r71.18<0;1,0>:ub  r1.3<0;1,0>:uw   {I@2}
(W)     and (1|M0)               f1.0<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(~f1.0.any16h) goto (16|M0)                  L9232                  L9232                
L9152:
(f1.1)  sel (1|M0)               r1.2<1>:d     r49.5<0;1,0>:d    0:w              
        asr (1|M0)               r1.2<1>:d     r1.2<0;1,0>:d     11:w               {I@1}
        add (1|M0)               r1.3<1>:d     r1.2<0;1,0>:d     248:w               {I@1}
        xor (1|M0)               r1.3<1>:d     r1.3<0;1,0>:d     r1.2<0;1,0>:d    {I@1}
(f1.1)  mov (1|M0)               r49.5<1>:d    r1.3<0;1,0>:d                    {I@1}
L9232:
        join (16|M0)                         L9376                                
L9248:
        asr (1|M0)               r1.2<1>:d     r49.5<0;1,0>:d    1:w               {I@2}
        cmp (1|M0)    (eq)f1.1   null<1>:w     r73.0<0;1,0>:w    0:w              
        add (1|M0)               r49.5<1>:d    r49.5<0;1,0>:d    -r1.2<0;1,0>:d   {I@2}
        shl (1|M0)               r1.2<1>:d     r1.2<0;1,0>:d     23:w              
        shl (1|M0)               r49.5<1>:d    r49.5<0;1,0>:d    23:w               {I@2}
        add (1|M0)               r1.2<1>:d     r1.2<0;1,0>:d     r76.0<0;1,0>:d   {A@1}
        add (1|M0)               r49.5<1>:d    r49.5<0;1,0>:d    1065353216:d               {I@2}
(f1.1)  mul (1|M0)               r74.0<1>:f    r49.5<0;1,0>:f    r1.2<0;1,0>:f    {I@1}
L9376:
        join (16|M0)                         L9392                                
L9392:
        sync.nop                             null                             {Compacted,F@1}
        math.inv (1|M0)          r1.2<1>:f     r15.1<0;1,0>:f                   {$14}
        mov (1|M0)               r1.4<1>:ud    0x3F800000:ud                             
        mul (1|M0)               r1.3<1>:f     r1.2<0;1,0>:f     r71.0<0;1,0>:f   {$14.dst}
        mad (1|M0)               r1.4<1>:f     r1.4<0;0>:f       r1.2<0;0>:f       -r15.1<0>:f      {I@1}
        mad (1|M0)               r2.3<1>:f     r71.0<0;0>:f      r1.3<0;0>:f       -r15.1<0>:f      {F@2}
        mad (1|M0)               r1.4<1>:f     r1.2<0;0>:f       r1.2<0;0>:f       r1.4<0>:f        {F@2}
        cmp (1|M0)    (eq)f1.0   null<1>:uw    r49.16<0;1,0>:ub  0x0:uw             
        mad (1|M0)               r2.3<1>:f     r1.3<0;0>:f       r1.4<0;0>:f       r2.3<0>:f        {F@1}
        mad (1|M0)               r71.0<1>:f    r71.0<0;0>:f      r2.3<0;0>:f       -r15.1<0>:f      {F@1}
(f1.0)  mad (1|M0)               r74.0<1>:f    r2.3<0;0>:f       r1.4<0;0>:f       r71.0<0>:f       {F@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        ret (16|M0)                          r73.2                            {A@1}
L9608:
        mov (1|M0)               r1.2<1>:d     cr0.0<0;1,0>:ud                  {A@1}
        and (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   -1265:w               {A@1}
        or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   1264:w               {A@1}
        mad (1|M0)               r75.0<1>:f    r73.1<0;0>:f      r75.1<0;0>:f      r75.0<0>:f       {A@1}
        mov (1|M0)               cr0.0<1>:ud   r1.2<0;1,0>:d                    {A@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        ret (16|M0)                          r74.2                            {A@1}
L9736:
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
