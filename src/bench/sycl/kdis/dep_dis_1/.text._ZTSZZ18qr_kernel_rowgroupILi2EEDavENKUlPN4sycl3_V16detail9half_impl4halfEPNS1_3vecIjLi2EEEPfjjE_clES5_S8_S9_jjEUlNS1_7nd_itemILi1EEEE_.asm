L0:
(W)     mov (8|M0)               r127.0<1>:ud  0x0:ud                              {A@1}
(W)     and (1|M0)               r127.2<1>:ud  r0.0<0;1,0>:ud    0xFFFFFFC0:ud             
(W)     and (1|M0)               r127.0<1>:uw  r0.4<0;1,0>:uw    0xFF:uw             
(W)     add (1|M0)               r127.2<1>:ud  r127.2<0;1,0>:ud  0x20:ud              {I@2}
(W)     mad (1|M0)               r127.2<1>:ud  r127.2<0;0>:ud    r127.0<0;0>:uw    0x20:uw              {I@1}
(W)     send.dc0 (8|M0)          r1       r127    null:0  0x0            0x021842FD           {A@1,$0} // wr:1h+0, rd:1; oword aligned block read x2
        nop                    
        nop                    
(W)     mov (8|M0)               r127.0<1>:ud  0x0:ud                              {$0.src}
(W)     and (1|M0)               r127.2<1>:ud  r0.0<0;1,0>:ud    0xFFFFFFC0:ud             
(W)     send.dc0 (8|M0)          r2       r127    null:0  0x0            0x021842FD           {A@1,$1} // wr:1h+0, rd:1; oword aligned block read x2
        and (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   -1265:w               {A@1}
        or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   1216:w               {A@1}
        mov (1|M0)               r25.0<1>:d    r0.1<0;1,0>:ud                   {A@1}
        mov (1|M0)               r25.1<1>:d    0:w                              
        mov (1|M0)               r4.3<1>:d     r1.0<0;1,0>:uw                   {$0.dst}
        shr (1|M0)               r1.3<1>:ud    r25.0<0;1,0>:ud   0x15:uw              {I@3}
        shl (1|M0)               r25.2<1>:d    r25.0<0;1,0>:d    11:w               {Compacted}
        shl (1|M0)               r1.2<1>:d     r25.1<0;1,0>:d    11:w               {I@4}
        shl (1|M0)               r25.4<1>:d    r4.3<0;1,0>:d     4:w               {I@4}
        shl (1|M0)               r3.0<1>:d     r25.2<0;1,0>:d    1:w               {Compacted,I@3}
        or (1|M0)                r25.3<1>:d    r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@3}
        shr (1|M0)               r2.1<1>:ud    r25.2<0;1,0>:ud   0x1F:uw              {$1.dst}
        shl (1|M0)               r1.4<1>:d     r25.4<0;1,0>:d    1:w               {I@4}
        addc (1|M0)              r4.0<1>:ud    r2.2<0;1,0>:ud    r3.0<0;1,0>:ud   {AccWrEn,I@4}
        shl (1|M0)               r2.0<1>:d     r25.3<0;1,0>:d    1:w               {Compacted,I@4}
        shr (1|M0)               r4.5<1>:ud    r4.3<0;1,0>:ud    0x1C:uw             
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        or (1|M0)                r3.1<1>:d     r2.0<0;1,0>:d     r2.1<0;1,0>:d    {I@3}
        addc (1|M0)              r2.0<1>:ud    r4.0<0;1,0>:ud    r1.4<0;1,0>:ud   {AccWrEn}
        or (1|M0)                r25.5<1>:d    r4.5<0;1,0>:d     0:w               {I@4}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r3.0<1>:ud    r25.4<0;1,0>:ud   0x400:ud              {AccWrEn}
        shr (1|M0)               r1.3<1>:ud    r25.4<0;1,0>:ud   0x1F:uw             
        add3 (1|M0)              r4.2<1>:d     r5.0<0;0>:d       r2.3<0;0>:d       r3.1<0>:d        {I@6}
        shl (1|M0)               r1.2<1>:d     r25.5<0;1,0>:d    1:w               {I@5}
        mov (1|M0)               r25.6<1>:d    r3.0<0;1,0>:d                    {I@4}
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r7.0<1>:f     r2.0<0;1,0>:f                    {Compacted}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@3}
        add3 (1|M0)              r25.7<1>:d    r5.0<0;0>:d       r25.5<0;0>:d      0:w               {I@2}
        shl (1|M0)               r2.0<1>:d     r25.6<0;1,0>:d    1:w               {Compacted,F@1}
        shr (1|M0)               r4.4<1>:ud    r25.6<0;1,0>:ud   0x1F:uw             
        add3 (1|M0)              r7.1<1>:d     r6.0<0;0>:d       r4.2<0;0>:d       r1.5<0>:d        {I@4}
        shl (1|M0)               r4.3<1>:d     r25.7<0;1,0>:d    1:w               {I@4}
        addc (1|M0)              r6.0<1>:ud    r4.0<0;1,0>:ud    r2.0<0;1,0>:ud   {AccWrEn,I@4}
        send.ugm (1|M0)          r26      r7      null:0  0x0            0x0210B780           {A@3,$2} // wr:1+0, rd:1; load.ugm.d64x4t.a64
        or (1|M0)                r2.1<1>:d     r4.3<0;1,0>:d     r4.4<0;1,0>:d    {I@2}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$2.src}
        mov (1|M0)               r10.0<1>:f    r6.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r10.1<1>:d    r7.0<0;0>:d       r4.2<0;0>:d       r2.1<0>:d        {I@1}
        shl (1|M0)               r6.0<1>:d     r1.0<0;1,0>:uw    2:w               {F@1}
        send.ugm (1|M0)          r27      r10     null:0  0x0            0x0210B780           {A@2,$3} // wr:1+0, rd:1; load.ugm.d64x4t.a64
        mov (8|M0)               r8.0<1>:f     (abs)r26.0<1;1,0>:hf             {$2.dst}
        mov (8|M0)               r9.0<1>:f     (abs)r26.8<1;1,0>:hf            
        sel (16|M0)   (ge)f0.0   acc0.0<1>:f   r8.0<1;1,0>:f     0.0:f               {Compacted,F@1}
        mov (8|M0)               r11.0<1>:f    (abs)r27.0<1;1,0>:hf             {$3.dst}
        mov (8|M0)               r12.0<1>:f    (abs)r27.8<1;1,0>:hf            
        sel (16|M0)   (ge)f0.0   r8.0<1>:f     acc0.0<1;1,0>:f   r11.0<1;1,0>:f   {Compacted,F@1}
        sel (8|M0)    (ge)f0.0   r3.0<1>:f     r8.0<1;1,0>:f     r9.0<1;1,0>:f    {Compacted,F@1}
        mov (4|M0)               r5.0<1>:ud    r3.4<1;1,0>:ud                   {F@1}
        sel (4|M0)    (ge)f0.0   r13.0<1>:f    r3.0<1;1,0>:f     r5.0<1;1,0>:f    {I@1}
        mov (2|M0)               r14.0<1>:ud   r13.2<1;1,0>:ud                  {F@1}
        sel (2|M0)    (ge)f0.0   r15.0<1>:f    r13.0<1;1,0>:f    r14.0<1;1,0>:f   {I@1}
        sel (1|M0)    (ge)f0.0   r16.0<1>:f    r15.0<0;1,0>:f    r15.1<0;1,0>:f   {F@1}
        send.slm (1|M0)          null     r6      r16:1   0x0            0x02000504           {A@1,$4} // wr:1+1, rd:0; store.slm.d32.a32
(W)     send.slm (1|M0)          r4       r0      null:0  0x0            0x0210001F           {$5} // wr:1+0, rd:1; fence.slm.none.group
(W)     mov (1|M0)               r7.2<1>:f     0.0:f                               {Compacted}
(W)     mov (2|M0)               r7.10<1>:ub   r0.11<0;1,0>:ub                  {F@1}
(W)     mov (8|M0)               null<1>:ud    r4.0<1;1,0>:ud                   {$5.dst}
(W)     send.gtwy (1|M0)         null     r7      null:0  0x0            0x02000004           {A@2,$6} // wr:1+0, rd:0; signal barrier
(W)     sync.bar                             null                            
        mov (1|M0)               r2.0<1>:d     0:w                              
        send.slm (1|M0)          r17      r2      null:0  0x0            0x0280E700           {A@1,$7} // wr:1+0, rd:8; load.slm.d64x32t.a32
        sel (16|M0)   (ge)f0.0   acc0.0<1>:f   r17.0<1;1,0>:f    r21.0<1;1,0>:f   {Compacted,$7.dst}
        sel (16|M0)   (ge)f0.0   acc2.0<1>:f   r19.0<1;1,0>:f    r23.0<1;1,0>:f   {Compacted}
        sel (16|M0)   (ge)f0.0   r8.0<1>:f     acc0.0<1;1,0>:f   acc2.0<1;1,0>:f 
        sel (8|M0)    (ge)f0.0   r3.0<1>:f     r8.0<1;1,0>:f     r9.0<1;1,0>:f    {Compacted,F@1}
        mov (4|M0)               r5.0<1>:ud    r3.4<1;1,0>:ud                   {F@1}
        sel (4|M0)    (ge)f0.0   r4.0<1>:f     r3.0<1;1,0>:f     r5.0<1;1,0>:f    {I@1}
        sync.nop                             null                             {Compacted,$4.src}
        mov (2|M0)               r6.0<1>:ud    r4.2<1;1,0>:ud                   {F@1}
        sel (2|M0)    (ge)f0.0   r12.0<1>:f    r4.0<1;1,0>:f     r6.0<1;1,0>:f    {I@1}
        sel (1|M0)    (ge)f0.0   r83.0<1>:f    r12.0<0;1,0>:f    r12.1<0;1,0>:f   {F@1}
        cmp (1|M0)    (eq)f1.1   null<1>:f     r83.0<0;1,0>:f    0.0:f               {F@1}
(W)     and (1|M0)               f0.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(f0.1.any16h) goto (16|M0)                   L1328                  L1328                
L1248:
        mov (1|M0)               r83.1<1>:f    127.0:f                              
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r82.2         L5256                                 {A@1}
L1312:
        goto (16|M0)                         L1328                  L1352                
L1328:
        join (16|M0)                         L1352                                
L1344:
        mov (1|M0)               r82.0<1>:f    1.0:f                               {Compacted}
L1352:
        join (16|M0)                         L1368                                
L1368:
        cmp (1|M0)    (eq)f1.0   null<1>:w     r1.0<0;1,0>:w     0:w              
(W)     and (1|M0)               f0.0<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
(~f0.0.any16h) goto (16|M0)                  L1536                  L1536                
L1416:
        shl (1|M0)               r1.4<1>:d     r25.0<0;1,0>:d    2:w               {Compacted}
        shl (1|M0)               r1.2<1>:d     r25.1<0;1,0>:d    2:w              
        shr (1|M0)               r1.3<1>:ud    r25.0<0;1,0>:ud   0x1E:uw             
        addc (1|M0)              r2.0<1>:ud    r2.4<0;1,0>:ud    r1.4<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        mov (1|M0)               r3.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r4.0<1>:f     r2.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r4.1<1>:d     r3.0<0;0>:d       r2.5<0;0>:d       r1.5<0>:d        {I@1}
        send.ugm (1|M0)          null     r4      r82:1   0x0            0x04000584           {A@1,$8} // wr:2+1, rd:0; store.ugm.d32.a64
L1536:
        join (16|M0)                         L1552                                
L1552:
        addc (1|M0)              r2.0<1>:ud    r2.6<0;1,0>:ud    r25.2<0;1,0>:ud  {AccWrEn}
        mov (16|M0)              r28.0<1>:f    r82.0<0;1,0>:f                   {Compacted}
        mov (1|M0)               r3.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (16|M0)              r38.0<1>:f    r28.0<1;1,0>:f                   {Compacted,F@1}
        mov (8|M0)               r31.0<1>:f    r26.0<1;1,0>:hf                 
        mov (8|M0)               r32.0<1>:f    r26.8<1;1,0>:hf                 
        mov (1|M0)               r30.0<1>:d    r2.0<0;1,0>:d                    {I@2}
        add3 (1|M0)              r30.1<1>:d    r3.0<0;0>:d       r2.7<0;0>:d       r25.3<0>:d       {I@2}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        sync.nop                             null                             {Compacted,$8.src}
(W)     call (16|M0)             r82.6         L2120                                 {A@1}
L1712:
        rnde (16|M0)             r72.0<1>:f    r72.0<1;1,0>:f                   {Compacted}
        sel (16|M0)   (ge)f0.0   r72.0<1>:f    r72.0<1;1,0>:f    -127.0:f               {F@1}
        addc (1|M0)              r2.0<1>:ud    r30.0<0;1,0>:ud   r25.4<0;1,0>:ud  {AccWrEn,I@3}
        sel (16|M0)   (lt)f0.0   r72.0<1>:f    r72.0<1;1,0>:f    127.0:f               {F@1}
        mov (1|M0)               r3.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (16|M0)              r5.0<1>:d     r72.0<1;1,0>:f                   {Compacted,F@1}
        mov (1|M0)               r4.0<1>:d     r2.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r4.1<1>:d     r3.0<0;0>:d       r30.1<0;0>:d      r25.5<0>:d       {I@3}
        mov (16|M0)              r7.0<1>:b     r5.0<4;1,0>:b                    {I@3}
        mov (16|M0)              r38.0<1>:f    r28.0<1;1,0>:f                   {Compacted}
        send.ugm (1|M0)          null     r4      r7:1    0x0            0x02009784           {A@1,$9} // wr:1+1, rd:0; store.ugm.d64x2t.a64
        mov (8|M0)               r31.0<1>:f    r27.0<1;1,0>:hf                 
        mov (8|M0)               r32.0<1>:f    r27.8<1;1,0>:hf                 
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r82.6         L2120                                 {A@1}
L1936:
        rnde (16|M0)             r72.0<1>:f    r72.0<1;1,0>:f                   {Compacted}
        sel (16|M0)   (ge)f0.0   r72.0<1>:f    r72.0<1;1,0>:f    -127.0:f               {F@1}
        addc (1|M0)              r2.0<1>:ud    r30.0<0;1,0>:ud   r25.6<0;1,0>:ud  {AccWrEn}
        sel (16|M0)   (lt)f0.0   r72.0<1>:f    r72.0<1;1,0>:f    127.0:f               {F@1}
        mov (1|M0)               r3.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (16|M0)              r5.0<1>:d     r72.0<1;1,0>:f                   {Compacted,F@1}
        mov (1|M0)               r4.0<1>:f     r2.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r4.1<1>:d     r3.0<0;0>:d       r30.1<0;0>:d      r25.7<0>:d       {I@2}
        mov (16|M0)              r7.0<1>:b     r5.0<4;1,0>:b                    {I@2}
        send.ugm (1|M0)          null     r4      r7:1    0x0            0x02009784           {A@1,$10} // wr:1+1, rd:0; store.ugm.d64x2t.a64
(W)     mov (8|M0)               r127.0<1>:f   r0.0<1;1,0>:f                    {Compacted}
(W)     send.ugm (1|M0)          r8       r0      null:0  0x0            0x0210641F           {$11} // wr:1+0, rd:1; fence invalid flush type scoped to tile
(W)     mov (8|M0)               null<1>:ud    r8.0<1;1,0>:ud                   {$11.dst}
(W)     send.gtwy (1|M0)         null     r127    null:0  0x0            0x02000010           {EOT,A@1} // wr:1+0, rd:0; end of thread
L2120:
(W)     shr (16|M0)              r3.0<1>:ud    r31.0<1;1,0>:ud   0x17:uw             
(W)     and (16|M0)              r33.0<1>:w    r3.0<2;1,0>:w     255:w               {I@1}
(W)     add (16|M0)              r7.0<1>:d     r33.0<1;1,0>:uw   -191:w               {I@1}
(W)     cmp (16|M0)   (lt)f1.0   null<1>:d     r7.0<1;1,0>:ud    0xFFFFFF82:ud              {I@1}
(W)     shr (16|M0)              r5.0<1>:ud    r38.0<1;1,0>:ud   0x17:uw             
(W)     mov (1|M0)               r82.2<1>:uw   f1.0<0;1,0>:uw                   {Compacted}
(W)     and (16|M0)              r40.0<1>:w    r5.0<2;1,0>:w     255:w               {I@2}
(W)     mov (1|M0)               f0.1<1>:uw    r82.2<0;1,0>:uw                  {I@2}
(W)     add (16|M0)              r9.0<1>:d     r40.0<1;1,0>:uw   -191:w               {I@2}
(W)     mov (16|M0)              r34.0<1>:d    r33.0<1;1,0>:uw                 
(W&~f0.1) cmp (16|M0) (lt)f0.1   null<1>:d     r9.0<1;1,0>:ud    0xFFFFFF81:ud              {I@2}
(W)     mov (16|M0)              r36.0<1>:d    r33.0<1;1,0>:uw                 
(W)     mov (1|M0)               r82.2<1>:uw   f0.1<0;1,0>:uw                  
(W)     mov (16|M0)              r41.0<1>:d    r40.0<1;1,0>:uw                 
(W)     mov (1|M0)               f0.0<1>:uw    r82.2<0;1,0>:uw                  {I@2}
(W)     mov (16|M0)              r43.0<1>:d    r40.0<1;1,0>:uw                 
(~f0.0.any16h) goto (16|M0)                  L4928                  L4928                
L2384:
(W)     add (16|M0)              r3.0<1>:d     r33.0<1;1,0>:uw   -255:w              
(W)     cmp (16|M0)   (lt)f0.0   null<1>:d     r3.0<1;1,0>:ud    0xFFFFFF02:ud              {I@1}
(W)     add (16|M0)              r5.0<1>:d     r40.0<1;1,0>:uw   -255:w              
(W&~f0.0) cmp (16|M0) (lt)f0.0   null<1>:d     r5.0<1;1,0>:ud    0xFFFFFF02:ud              {I@1}
(W)     mov (16|M0)              r55.0<1>:f    (abs)r31.0<1;1,0>:f              {Compacted}
(f0.0.any16h) goto (16|M0)                   L2544                  L2544                
L2472:
(W)     mov (16|M0)              r3.0<1>:f     (abs)r38.0<1;1,0>:f              {Compacted}
(W)     add (16|M0)              r55.0<1>:d    r55.0<1;1,0>:d    -r3.0<1;1,0>:d   {Compacted,A@1}
(W)     mov (4|M0)               r30.2<1>:d    0:w                              
(W)     mov (16|M0)              r67.0<1>:f    r31.0<1;1,0>:f                   {Compacted}
(W)     mov (16|M0)              r57.0<1>:f    r38.0<1;1,0>:f                   {Compacted}
(W)     asr (16|M0)              r55.0<1>:d    r55.0<1;1,0>:d    23:w               {Compacted,I@2}
        goto (16|M0)                         L2544                  L3800                
L2544:
        join (16|M0)                         L3800                                
L2560:
(W)     mov (16|M0)              r53.0<1>:f    (abs)r38.0<1;1,0>:f              {Compacted}
(W)     cmp (16|M0)   (gt)f1.1   null<1>:d     r55.0<1;1,0>:ud   0x7F800000:ud              {I@3}
(W)     cmp (16|M0)   (lt)f1.0   null<1>:d     r53.0<1;1,0>:ud   0x7F800001:ud              {F@1}
(W)     and (16|M0)              r45.0<1>:ud   r31.0<1;1,0>:ud   0x7F800000:ud             
(W)     mov (1|M0)               r1.3<1>:uw    f1.1<0;1,0>:uw                  
(W)     mov (1|M0)               r2.0<1>:uw    f1.0<0;1,0>:uw                   {Compacted}
(W)     or (1|M0)                f0.1<1>:uw    f1.0<0;1,0>:uw    r1.3<0;1,0>:uw   {I@2}
(W)     cmp (16|M0)   (ne)f1.0   null<1>:d     r45.0<1;1,0>:d    2139095040:d              
(W)     or (1|M0)                r5.0<1>:uw    f1.1<0;1,0>:uw    ~r2.0<0;1,0>:uw  {I@3}
(W)     mov (1|M0)               r8.0<1>:f     -0.0:f                               {Compacted}
(W)     or (1|M0)                r5.1<1>:uw    f1.0<0;1,0>:uw    r5.0<0;1,0>:uw   {I@1}
(W&f0.1) sel (16|M0)             acc0.0<1>:f   r31.0<1;1,0>:f    r38.0<1;1,0>:f  
(W)     mov (1|M0)               f0.1<1>:uw    r5.1<0;1,0>:uw                   {A@1}
(W)     and (16|M0)              r47.0<1>:ud   r38.0<1;1,0>:ud   0x7F800000:ud             
(W)     bfn.0x6A (16|M0)         r72.0<1>:ud   r31.0<1;0>:ud     r38.0<1;0>:ud     r8.0<0>:ud       // s0^s1&s2
(W)     bfn.0x6A (16|M0)         r9.0<1>:ud    r38.0<1;0>:ud     r31.0<1;0>:ud     r8.0<0>:ud       // s0^s1&s2
(W)     add (16|M0)              r72.0<1>:f    r72.0<1;1,0>:f    -r9.0<1;1,0>:f   {Compacted,A@1}
(W&f0.1) add (16|M0)             r72.0<1>:f    acc0.0<1;1,0>:f   r38.0<1;1,0>:f  
(W)     cmp (16|M0)   (ne)f0.1   null<1>:d     r47.0<1;1,0>:d    2139095040:d               {F@1}
(W)     or (1|M0)                r5.0<1>:uw    ~f1.0<0;1,0>:uw   r5.0<0;1,0>:uw  
(W)     cmp (16|M0)   (eq)f1.0   null<1>:f     r38.0<1;1,0>:f    0.0:f               {I@1}
(W)     or (1|M0)                r1.3<1>:uw    f0.1<0;1,0>:uw    r5.0<0;1,0>:uw  
(W)     or (1|M0)                r5.0<1>:uw    ~f0.1<0;1,0>:uw   r5.0<0;1,0>:uw  
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                             
(W)     mov (1|M0)               f0.1<1>:uw    r5.0<0;1,0>:uw                   {I@1}
(W)     and (1|M0)               r3.0<1>:uw    f1.0<0;1,0>:uw    ~r5.0<0;1,0>:uw 
(W)     mov (1|M0)               f1.1<1>:uw    r1.3<0;1,0>:uw                  
(W)     and (16|M0)              r6.0<1>:ud    r38.0<1;1,0>:ud   0x80000000:ud             
(W&f0.1) sel (16|M0)             r11.0<2>:b    r2.0<0;1,0>:w     0:w               {F@1}
(W)     mov (1|M0)               f0.1<1>:uw    r3.0<0;1,0>:uw                   {I@4}
(W)     and (16|M0)              r49.0<1>:ud   r31.0<1;1,0>:ud   0x80000000:ud             
(W&~f1.1) mul (16|M0)            r72.0<1>:f    r6.0<1;1,0>:f     r31.0<1;1,0>:f   {I@4}
(W)     mov (16|M0)              r30.8<1>:b    r11.0<2;1,0>:b                   {I@3}
(~f0.1) goto (16|M0)                         L3192                  L3192                
L3072:
(W)     cmp (16|M0)   (eq)f1.0   null<1>:f     r31.0<1;1,0>:f    0.0:f              
(W)     mov (1|M0)               r1.2<1>:ud    0x7F800000:ud                             
(W)     mov (1|M0)               r2.0<2>:b     -1:w                              
(W&f1.0) mov (16|M0)             r49.0<1>:ud   0:w                              
(W)     bfn.0x96 (16|M0)         r49.0<1>:ud   r1.2<0;0>:ud      r49.0<1;0>:ud     r38.0<1>:ud      {I@1} // s0^s1^s2
(W&f1.0) mul (16|M0)             r49.0<1>:f    r49.0<1;1,0>:f    r31.0<1;1,0>:f   {I@1}
        mov (16|M0)              r30.8<1>:b    r2.0<0;1,0>:b                   
        mov (16|M0)              r72.0<1>:f    r49.0<1;1,0>:f                   {Compacted,F@1}
L3192:
        join (16|M0)                         L3800                                
L3208:
(W)     cmp (16|M0)   (eq)f0.1   null<1>:f     r31.0<1;1,0>:f    0.0:f              
(W&f0.1) cmp (16|M0)  (eq)f0.1   null<1>:w     r30.8<1;1,0>:ub   0x0:uw              {A@1}
(W&~f0.1) sel (16|M0)            r3.0<2>:b     r30.8<1;1,0>:b    -1:w              
(W)     mov (16|M0)              r30.8<1>:b    r3.0<2;1,0>:b                    {I@1}
(W)     cmp (16|M0)   (ne)f1.1   null<1>:w     r30.8<1;1,0>:ub   0x0:uw              {I@1}
(W&f0.1) mul (16|M0)             r72.0<1>:f    r31.0<1;1,0>:f    r38.0<1;1,0>:f  
(f1.1.all16h) goto (16|M0)                   L3800                  L4928                
L3320:
(W)     cmp (16|M0)   (eq)f1.1   null<1>:w     r30.8<1;1,0>:ub   0x0:uw             
(W)     mov (1|M0)               r1.3<1>:uw    f0.0<0;1,0>:uw                  
(W)     cmp (16|M0)   (eq)f1.0   null<1>:d     r45.0<1;1,0>:d    0:w              
(W)     and (1|M0)               f0.0<1>:uw    f1.1<0;1,0>:uw    r1.3<0;1,0>:uw   {I@2}
(W)     mov (16|M0)              r59.0<1>:d    0:w                              
(W)     mov (1|M0)               r2.0<1>:uw    f1.0<0;1,0>:uw                   {Compacted}
(W)     mov (16|M0)              r67.0<1>:f    r31.0<1;1,0>:f                   {Compacted}
(W)     and (1|M0)               f1.0<1>:uw    f0.0<0;1,0>:uw    r2.0<0;1,0>:uw   {I@1}
(W)     mov (16|M0)              r51.0<1>:f    r59.0<1;1,0>:f                   {Compacted}
(~f1.0) goto (16|M0)                         L3552                  L3552                
L3456:
        mul (16|M0)              r67.0<1>:f    r31.0<1;1,0>:f    0x4F800000:f               {Compacted}
(W)     shr (16|M0)              r3.0<1>:ud    r67.0<1;1,0>:ud   0x17:uw              {F@1}
(W)     and (16|M0)              r5.0<1>:w     r3.0<2;1,0>:w     255:w               {I@1}
        add (16|M0)              r36.0<1>:d    r5.0<1;1,0>:uw    -32:w               {I@1}
(W)     mov (16|M0)              r51.0<1>:d    0:w                              
(W)     mov (16|M0)              r34.0<1>:f    r36.0<1;1,0>:f                   {Compacted,I@2}
        mov (16|M0)              r51.0<1>:d    -32:w                              
L3552:
        join (16|M0)                         L3800                                
L3568:
(W)     cmp (16|M0)   (eq)f0.1   null<1>:d     r47.0<1;1,0>:d    0:w              
(W)     mov (16|M0)              r57.0<1>:f    r38.0<1;1,0>:f                   {Compacted}
(W)     mov (1|M0)               r1.3<1>:uw    f0.1<0;1,0>:uw                  
(W)     and (1|M0)               f0.1<1>:uw    f0.0<0;1,0>:uw    r1.3<0;1,0>:uw   {I@1}
(~f0.1) goto (16|M0)                         L3744                  L3744                
L3640:
        mul (16|M0)              r57.0<1>:f    r38.0<1;1,0>:f    0x4F800000:f               {Compacted}
(W)     shr (16|M0)              r3.0<1>:ud    r57.0<1;1,0>:ud   0x17:uw              {F@1}
(W)     and (16|M0)              r5.0<1>:w     r3.0<2;1,0>:w     255:w               {I@1}
        add (16|M0)              r43.0<1>:d    r5.0<1;1,0>:uw    -32:w               {I@1}
(W)     mov (16|M0)              r59.0<1>:d    0:w                              
(W)     mov (16|M0)              r53.0<1>:f    (abs)r57.0<1;1,0>:f              {Compacted}
(W)     mov (16|M0)              r41.0<1>:f    r43.0<1;1,0>:f                   {Compacted,I@2}
        mov (16|M0)              r59.0<1>:d    32:w                              
L3744:
        join (16|M0)                         L3800                                
L3760:
(W)     mov (16|M0)              r55.0<1>:f    (abs)r67.0<1;1,0>:f              {Compacted}
(W)     add (16|M0)              r55.0<1>:d    r55.0<1;1,0>:d    -r53.0<1;1,0>:d  {Compacted,F@1}
(W)     asr (16|M0)              r55.0<1>:d    r55.0<1;1,0>:d    23:w               {Compacted,I@1}
(W)     add3 (16|M0)             r59.0<1>:d    r59.0<1;0>:d      r51.0<1;0>:d      r55.0<1>:d       {I@1}
L3800:
        join (16|M0)                         L4928                                
L3816:
(W)     mov (1|M0)               r1.2<1>:f     1.0:f                               {Compacted}
(W)     mov (1|M0)               r2.0<1>:f     0x807FFFFF:f                              
(W&~f0.0) mov (16|M0)            r59.0<1>:f    r55.0<1;1,0>:f                   {I@2}
(W)     bfn.0xEA (16|M0)         r57.0<1>:ud   r1.2<0;0>:ud      r57.0<1;0>:ud     r2.0<0>:ud       {A@2} // s0|s1&s2
(W)     add (16|M0)              r61.0<1>:d    r59.0<1;1,0>:d    126:w               {Compacted,F@1}
(W)     add (16|M0)              r3.0<1>:d     -r59.0<1;1,0>:d   -152:w               {Compacted}
        sync.nop                             null                             {Compacted,I@3}
(W)     math.inv (16|M0)         r5.0<1>:f     r57.0<1;1,0>:f                   {$12}
(W)     cmp (16|M0)   (eq)f0.0   null<1>:w     r30.8<1;1,0>:ub   0x0:uw             
(W)     and (16|M0)              r3.0<1>:d     r3.0<1;1,0>:d     r61.0<1;1,0>:d   {Compacted,I@2}
(W)     mov (1|M0)               r9.0<1>:f     1.0:f                               {Compacted}
(W)     bfn.0xEA (16|M0)         r67.0<1>:ud   r1.2<0;0>:ud      r67.0<1;0>:ud     r2.0<0>:ud       // s0|s1&s2
(W)     asr (16|M0)              r3.0<1>:d     r3.0<1;1,0>:d     31:w               {Compacted,I@2}
        sync.nop                             null                             {Compacted,$12.dst}
(W)     mad (16|M0)              r63.0<1>:f    r9.0<0;0>:f       r5.0<1;0>:f       -r57.0<1>:f      {F@1}
(W)     mul (16|M0)              acc0.0<1>:f   r5.0<1;1,0>:f     r67.0<1;1,0>:f   {Compacted,I@2}
(W&f0.0) sel (16|M0)             r69.0<1>:w    r3.0<4;1,0>:ub    0:w               {I@1}
(W)     mad (16|M0)              r63.0<1>:f    r5.0<1;0>:f       r5.0<1;0>:f       r63.0<1>:f       {Compacted,F@2}
(W)     mad (16|M0)              r65.0<1>:f    r67.0<1;0>:f      acc0.0<1;0>:f     -r57.0<1>:f     
(W)     cmp (16|M0)   (ne)f1.1   null<1>:w     r69.0<2;1,0>:ub   0x0:uw              {I@1}
(W)     mad (16|M0)              r65.0<1>:f    acc0.0<1;0>:f     r63.0<1;0>:f      r65.0<1>:f       {F@1}
(W)     add (16|M0)              r34.0<1>:d    r34.0<1;1,0>:d    -r41.0<1;1,0>:d  {Compacted}
(W)     mad (16|M0)              r67.0<1>:f    r67.0<1;0>:f      r65.0<1;0>:f      -r57.0<1>:f      {Compacted,F@1}
(~f1.1.any16h) goto (16|M0)                  L4672                  L4672                
L4104:
(W)     mov (16|M0)              r78.0<1>:ud   r67.0<1;1,0>:ud                  {F@1}
(W)     mov (16|M0)              r74.0<1>:f    r63.0<1;1,0>:f                   {Compacted}
(W)     mov (16|M0)              r76.0<1>:f    r65.0<1;1,0>:f                   {Compacted}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r83.2         L5136                                 {A@1}
L4184:
(W)     add (16|M0)              r59.0<1>:d    r59.0<1;1,0>:d    125:w               {Compacted}
(W)     cmp (16|M0)   (lt)f0.0   null<1>:d     r59.0<1;1,0>:d    -2:w               {Compacted,I@1}
(W)     cmp (16|M0)   (eq)f0.1   null<1>:f     r67.0<1;1,0>:f    0.0:f              
(W)     mov (1|M0)               r1.3<1>:uw    f0.0<0;1,0>:uw                  
(W)     or (1|M0)                f1.0<1>:uw    f0.1<0;1,0>:uw    r1.3<0;1,0>:uw   {I@1}
(f1.0.any16h) goto (16|M0)                   L4312                  L4312                
L4264:
(W)     mov (1|M0)               r1.3<1>:hf    0x1:hf                              {I@2}
(W&f0.1) sel (16|M0)             r70.0<1>:d    r1.3<0;1,0>:w     0:w               {F@1}
        goto (16|M0)                         L4312                  L4432                
L4312:
        join (16|M0)                         L4432                                
L4328:
(W)     mov (1|M0)               r1.3<1>:hf    0x1:hf                              {I@3}
(W)     and (16|M0)              r3.0<1>:d     r78.0<1;1,0>:d    -2139095041:d              
(W)     mov (1|M0)               r2.0<1>:f     0x800000:f                               {Compacted}
(W)     shl (16|M0)              r61.0<1>:d    r61.0<1;1,0>:d    23:w               {Compacted}
(W&f0.1) sel (16|M0)             r70.0<1>:d    r1.3<0;1,0>:w     0:w               {F@2}
(W)     add (16|M0)              r61.0<1>:d    r61.0<1;1,0>:d    1065353216:d               {I@2}
(W)     bfn.0xFE (16|M0)         r3.0<1>:ud    r3.0<1;0>:ud      r70.0<1;0>:ud     r2.0<0>:ud       {A@1} // s0|s1|s2
(W)     mul (16|M0)              r61.0<1>:f    r61.0<1;1,0>:f    r3.0<1;1,0>:f    {Compacted,A@1}
L4432:
        join (16|M0)                         L4672                                
L4448:
(W)     and (16|M0)   (eq)f1.1   null<1>:ud    r78.0<1;1,0>:ud   0x400000:ud             
(W)     shl (16|M0)              r3.0<1>:d     r78.0<1;1,0>:d    1:w               {Compacted,F@1}
(W)     mov (1|M0)               r1.2<1>:f     0x800000:f                               {Compacted}
(W)     mov (1|M0)               r2.0<1>:f     -0.0:f                               {Compacted}
(W)     mov (1|M0)               r2.1<1>:f     1.469368e-38:f                               {Compacted}
(W)     and (16|M0)              r3.0<1>:d     r3.0<1;1,0>:d     8388606:d               {I@1}
(W)     bfn.0xEA (16|M0)         r5.0<1>:ud    r1.2<0;0>:ud      r78.0<1;0>:ud     r2.0<0>:ud       {A@2} // s0|s1&s2
(W&f1.1) sel (16|M0)             r7.0<1>:d     r2.1<0;1,0>:d     12582912:d               {F@1}
(W)     mov (1|M0)               r9.0<1>:f     0.25:f                               {Compacted}
(W)     bfn.0xFE (16|M0)         r70.0<1>:ud   r70.0<1;0>:ud     r5.0<1;0>:ud      r3.0<1>:ud       {I@2} // s0|s1|s2
(W)     bfn.0xEA (16|M0)         r7.0<1>:ud    r7.0<1;0>:ud      r78.0<1;0>:ud     r2.0<0>:ud       {I@2} // s0|s1&s2
(W)     mad (16|M0)              r70.0<1>:f    r7.0<1;0>:f       r70.0<1;0>:f      r9.0<0>:f        {Compacted,A@1}
(W)     add (16|M0)              r70.0<1>:f    r70.0<1;1,0>:f    -r5.0<1;1,0>:f   {Compacted,F@1}
(W)     mul (16|M0)              r5.0<1>:f     r5.0<1;1,0>:f     r5.0<1;1,0>:f    {Compacted}
(W)     bfn.0xAE (16|M0)         r70.0<1>:ud   r70.0<1;0>:ud     r5.0<1;0>:ud      0x1:uw              {A@1} // s0|s1&~s2
(W&~f1.0) mov (16|M0)            r61.0<1>:f    r70.0<1;1,0>:f                   {I@1}
(W)     and (16|M0)   (ne)f1.0   null<1>:w     r69.0<2;1,0>:ub   1:w               {F@1}
(W&f1.0) mov (16|M0)             r72.0<1>:f    r61.0<1;1,0>:f                  
L4672:
        join (16|M0)                         L4928                                
L4688:
(W)     add (16|M0)              r3.0<1>:d     r34.0<1;1,0>:d    -253:w               {Compacted}
(W)     cmp (16|M0)   (lt)f1.1   null<1>:d     r3.0<1;1,0>:ud    0xFFFFFE85:ud              {I@1}
(W)     mov (1|M0)               r1.3<1>:hf    -qnan(0x1FF):hf                             
(W)     asr (16|M0)              r5.0<1>:d     r34.0<1;1,0>:d    11:w               {Compacted}
(W&f1.1.any16h) sel (1|M0)       r2.0<1>:w     r1.3<0;1,0>:w     0:w               {F@1}
(W)     add (16|M0)              r7.0<1>:d     r5.0<1;1,0>:d     248:w               {Compacted,I@2}
(W)     mov (1|M0)               f0.1<1>:uw    r2.0<0;1,0>:uw                   {I@2}
(W)     mov (16|M0)              r9.0<1>:f     r34.0<1;1,0>:f                   {Compacted}
(W&f1.1) xor (16|M0)             r9.0<1>:d     r7.0<1;1,0>:d     r5.0<1;1,0>:d    {A@1}
(W&~f0.1) mov (16|M0)            r9.0<1>:f     r34.0<1;1,0>:f                   {I@1}
(W)     asr (16|M0)              r11.0<1>:d    r9.0<1;1,0>:d     1:w               {Compacted,F@1}
(W)     mov (16|M0)              r3.0<1>:uw    r30.8<1;1,0>:ub                 
(W)     add (16|M0)              r9.0<1>:d     r9.0<1;1,0>:d     -r11.0<1;1,0>:d  {Compacted,I@2}
(W)     mad (16|M0)              r67.0<1>:f    r65.0<1;0>:f      r63.0<1;0>:f      r67.0<1>:f       {Compacted}
(W)     or (16|M0)    (eq)f0.0   null<1>:w     r69.0<2;1,0>:ub   r3.0<1;1,0>:uw   {I@2}
(W)     shl (16|M0)              r11.0<1>:d    r11.0<1;1,0>:d    23:w               {Compacted}
(W)     shl (16|M0)              r9.0<1>:d     r9.0<1;1,0>:d     23:w               {Compacted,I@3}
(W)     add (16|M0)              r11.0<1>:d    r11.0<1;1,0>:d    r67.0<1;1,0>:d   {Compacted,A@1}
(W)     add (16|M0)              r9.0<1>:d     r9.0<1;1,0>:d     1065353216:d               {I@2}
(W&f0.0) mul (16|M0)             r72.0<1>:f    r11.0<1;1,0>:f    r9.0<1;1,0>:f    {A@1}
L4928:
        join (16|M0)                         L4944                                
L4944:
(W)     math.inv (16|M0)         r3.0<1>:f     r38.0<1;1,0>:f                   {$13}
(W)     mov (1|M0)               r1.2<1>:ud    0x3F800000:ud                             
(W)     mul (16|M0)              acc0.0<1>:f   r3.0<1;1,0>:f     r31.0<1;1,0>:f   {Compacted,$13.dst}
(W)     mad (16|M0)              acc2.0<1>:f   r1.2<0;0>:f       r3.0<1;0>:f       -r38.0<1>:f      {I@1}
(W)     mad (16|M0)              r9.0<1>:f     r31.0<1;0>:f      acc0.0<1;0>:f     -r38.0<1>:f     
(W)     mad (16|M0)              acc2.0<1>:f   r3.0<1;0>:f       acc2.0<1;0>:f     r3.0<1>:f        {Compacted}
(W)     mov (1|M0)               f1.1<1>:uw    r82.2<0;1,0>:uw                 
(W)     mad (16|M0)              acc0.0<1>:f   acc0.0<1;0>:f     acc2.0<1;0>:f     r9.0<1>:f        {F@2}
(W)     mad (16|M0)              r31.0<1>:f    r31.0<1;0>:f      acc0.0<1;0>:f     -r38.0<1>:f     
(W&~f1.1) mad (16|M0)            r72.0<1>:f    acc0.0<1;0>:f     acc2.0<1;0>:f     r31.0<1>:f       {F@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        ret (16|M0)                          r82.6                            {A@1}
L5136:
(W)     mov (1|M0)               r1.2<1>:d     cr0.0<0;1,0>:ud                  {A@1}
(W)     and (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   -1265:w               {A@1}
(W)     or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   1264:w               {A@1}
(W)     mad (16|M0)              r78.0<1>:f    r76.0<1;0>:f      r74.0<1;0>:f      r78.0<1>:f       {Compacted,A@1}
(W)     mov (1|M0)               cr0.0<1>:ud   r1.2<0;1,0>:d                    {A@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        ret (16|M0)                          r83.2                            {A@1}
L5256:
        shr (1|M0)               r80.0<1>:ud   r83.1<0;1,0>:ud   0x17:uw             
        shr (1|M0)               r30.7<1>:ud   r83.0<0;1,0>:ud   0x17:uw             
        and (1|M0)               r80.0<1>:ud   r80.0<0;1,0>:ud   0xFF:uw              {I@2}
        and (1|M0)               r30.7<1>:ud   r30.7<0;1,0>:ud   0xFF:uw              {I@2}
        add (1|M0)               r1.3<1>:ud    r80.0<0;1,0>:ud   0xFFFFFF41:ud              {I@2}
        add (1|M0)               r1.2<1>:ud    r30.7<0;1,0>:ud   0xFFFFFF41:ud              {I@2}
        cmp (1|M0)    (lt)f0.0   null<1>:ud    r1.3<0;1,0>:ud    0xFFFFFF81:ud              {I@2}
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                             
(~f0.0) cmp (1|M0)    (lt)f0.0   null<1>:ud    r1.2<0;1,0>:ud    0xFFFFFF82:ud              {I@2}
(f0.0)  sel (1|M0)               r30.24<2>:b   r2.0<0;1,0>:w     0:w               {F@1}
        cmp (1|M0)    (ne)f1.1   null<1>:uw    r30.24<0;1,0>:ub  0x0:uw              {I@1}
(W)     and (1|M0)               f1.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(~f1.1.any16h) goto (16|M0)                  L8888                  L8888                
L5464:
        add (1|M0)               r1.3<1>:ud    r80.0<0;1,0>:ud   0xFFFFFF01:ud             
        add (1|M0)               r1.2<1>:ud    r30.7<0;1,0>:ud   0xFFFFFF01:ud             
        cmp (1|M0)    (lt)f1.1   null<1>:ud    r1.3<0;1,0>:ud    0xFFFFFF02:ud              {I@2}
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                             
        mov (1|M0)               r81.3<1>:f    (abs)r83.0<0;1,0>:f              {Compacted}
(~f1.1) cmp (1|M0)    (lt)f1.1   null<1>:ud    r1.2<0;1,0>:ud    0xFFFFFF02:ud              {I@2}
(f1.1)  sel (1|M0)               r30.26<2>:b   r2.0<0;1,0>:w     0:w               {F@2}
        cmp (1|M0)    (ne)f0.1   null<1>:uw    r30.26<0;1,0>:ub  0x0:uw              {I@1}
(W)     and (1|M0)               f1.0<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(f1.0.any16h) goto (16|M0)                   L5704                  L5704                
L5616:
        mov (1|M0)               r1.2<1>:f     (abs)r83.1<0;1,0>:f             
        mov (1|M0)               r80.22<2>:b   0:w                              
        add (1|M0)               r81.3<1>:d    r81.3<0;1,0>:d    -r1.2<0;1,0>:d   {A@1}
        mov (2|M0)               r82.4<1>:d    r83.0<1;1,0>:ud                 
        asr (1|M0)               r81.3<1>:d    r81.3<0;1,0>:d    23:w               {Compacted,I@2}
        goto (16|M0)                         L5704                  L7392                
L5704:
        join (16|M0)                         L7392                                
L5720:
        cmp (1|M0)    (gt)f0.0   null<1>:ud    r81.3<0;1,0>:ud   0x7F800000:ud              {I@3}
(W)     mov (1|M0)               r1.3<1>:hf    0xFF:hf                             
        mov (1|M0)               r81.1<1>:f    (abs)r83.1<0;1,0>:f              {Compacted}
(W)     mov (1|M0)               r2.1<1>:hf    -qnan(0x1FF):hf                             
(f0.0)  sel (1|M0)               r2.0<1>:w     r1.3<0;1,0>:w     0:w               {F@3}
        and (1|M0)               r80.2<1>:ud   r83.0<0;1,0>:ud   0x7F800000:ud             
        cmp (1|M0)    (eq)f1.0   null<1>:w     r2.0<0;1,0>:b     0:w               {I@2}
(W)     mov (1|M0)               r3.0<1>:uw    r2.0<0;1,0>:ub                  
        and (1|M0)               r80.3<1>:ud   r83.1<0;1,0>:ud   0x7F800000:ud             
(W)     mov (1|M0)               r5.0<1>:f     -0.0:f                               {Compacted}
(f1.0)  cmp (1|M0)    (gt)f1.0   null<1>:ud    r81.1<0;1,0>:ud   0x7F800000:ud              {F@3}
        bfn.0x6A (1|M0)          r1.2<1>:ud    r83.0<0;0>:ud     r83.1<0;0>:ud     r5.0<0>:ud       {F@1} // s0^s1&s2
        bfn.0x6A (1|M0)          r1.3<1>:ud    r83.1<0;0>:ud     r83.0<0;0>:ud     r5.0<0>:ud       // s0^s1&s2
        add (1|M0)               r82.0<1>:f    r83.0<0;1,0>:f    r83.1<0;1,0>:f   {Compacted}
(f1.0)  sel (1|M0)               r2.4<2>:b     r2.1<0;1,0>:w     0:w              
        and (1|M0)               r4.0<1>:ud    r83.1<0;1,0>:ud   0x80000000:ud             
        and (1|M0)    (ne)f1.0   null<1>:w     r2.4<0;1,0>:ub    1:w               {I@2}
        or (1|M0)     (eq)f0.1   r2.4<2>:ub    r2.4<0;1,0>:ub    r3.0<0;1,0>:uw  
        and (1|M0)               r80.1<1>:ud   r83.0<0;1,0>:ud   0x80000000:ud             
(f1.0)  add (1|M0)               r82.0<1>:f    r83.1<0;1,0>:f    r83.1<0;1,0>:f  
(f0.1)  cmp (1|M0)    (eq)f0.1   null<1>:d     r80.2<0;1,0>:d    2139095040:d              
(W)     mov (1|M0)               r4.2<1>:uw    r2.4<0;1,0>:ub                   {I@3}
(f0.1)  sel (1|M0)               r1.6<2>:b     r2.1<0;1,0>:w     0:w              
        and (1|M0)    (ne)f0.1   null<1>:w     r1.6<0;1,0>:ub    1:w               {I@1}
        or (1|M0)     (eq)f0.0   r1.6<2>:ub    r1.6<0;1,0>:ub    r4.2<0;1,0>:uw  
(f0.1)  add (1|M0)               r82.0<1>:f    r1.2<0;1,0>:f     -r1.3<0;1,0>:f  
(f0.0)  cmp (1|M0)    (eq)f0.0   null<1>:d     r80.3<0;1,0>:d    2139095040:d              
(W)     mov (1|M0)               r3.0<1>:uw    r1.6<0;1,0>:ub                   {I@2}
(f0.0)  sel (1|M0)               r80.18<2>:b   r2.1<0;1,0>:w     0:w              
        and (1|M0)    (ne)f0.0   null<1>:w     r80.18<0;1,0>:ub  1:w               {I@1}
        or (1|M0)     (eq)f1.1   r80.18<2>:ub  r80.18<0;1,0>:ub  r3.0<0;1,0>:uw  
(f0.0)  mul (1|M0)               r82.0<1>:f    r4.0<0;1,0>:f     r83.0<0;1,0>:f  
(f1.1)  cmp (1|M0)    (eq)f1.1   null<1>:f     r83.1<0;1,0>:f    0.0:f               {I@1}
(f1.1)  sel (1|M0)               r80.16<2>:b   r2.1<0;1,0>:w     0:w              
        cmp (1|M0)    (ne)f1.1   null<1>:uw    r80.16<0;1,0>:ub  0x0:uw              {A@1}
(W)     and (1|M0)               f0.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(f0.1.any16h) goto (16|M0)                   L6320                  L6320                
L6288:
        mov (1|M0)               r80.20<2>:b   r80.18<0;1,0>:b                 
        goto (16|M0)                         L6320                  L6504                
L6320:
        join (16|M0)                         L6504                                
L6336:
(W)     mov (1|M0)               r2.0<1>:f     inf:f                               {Compacted}
        cmp (1|M0)    (eq)f1.0   null<1>:f     r83.0<0;1,0>:f    0.0:f              
        bfn.0x96 (1|M0)          r80.1<1>:ud   r80.1<0;0>:ud     r83.1<0;0>:ud     r2.0<0>:ud       {F@2} // s0^s1^s2
        xor (1|M0)               r1.2<1>:ud    r83.1<0;1,0>:ud   0x7F800000:ud             
(W)     mov (1|M0)               r3.0<1>:uw    r80.18<0;1,0>:ub                
(~f1.0) mov (1|M0)               r1.2<1>:f     r80.1<0;1,0>:f                   {A@2}
        or (1|M0)                r80.18<2>:ub  r80.16<0;1,0>:ub  r3.0<0;1,0>:uw   {I@1}
(f1.0)  mul (1|M0)               r80.1<1>:f    r1.2<0;1,0>:f     r83.0<0;1,0>:f   {F@1}
        and (1|M0)    (ne)f1.0   null<1>:w     r80.16<0;1,0>:ub  1:w               {F@1}
        mov (1|M0)               r80.20<2>:b   r80.18<0;1,0>:b                  {I@2}
(f1.0)  mov (1|M0)               r82.0<1>:f    r80.1<0;1,0>:f                  
L6504:
        join (16|M0)                         L7392                                
L6520:
        cmp (1|M0)    (eq)f1.0   null<1>:w     r80.18<0;1,0>:b   0:w               {F@1}
(W)     mov (1|M0)               r1.3<1>:hf    -qnan(0x1FF):hf                             
(W)     mov (1|M0)               r2.0<1>:uw    r80.20<0;1,0>:ub                 {I@3}
(f1.0)  cmp (1|M0)    (eq)f1.0   null<1>:f     r83.0<0;1,0>:f    0.0:f               {I@2}
(f1.0)  sel (1|M0)               r80.22<2>:b   r1.3<0;1,0>:w     0:w               {F@2}
        and (1|M0)    (ne)f0.1   null<1>:w     r80.22<0;1,0>:ub  1:w               {I@1}
        or (1|M0)     (ne)f0.0   r80.22<2>:ub  r80.22<0;1,0>:ub  r2.0<0;1,0>:uw  
(f0.1)  mul (1|M0)               r82.0<1>:f    r83.0<0;1,0>:f    r83.1<0;1,0>:f  
(W)     and (1|M0)               f0.0<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
(f0.0.any16h) goto (16|M0)                   L7392                  L8888                
L6680:
        cmp (1|M0)    (eq)f1.1   null<1>:uw    r80.22<0;1,0>:ub  0x0:uw              {I@3}
        cmp (1|M0)    (eq)f1.0   null<1>:d     r80.2<0;1,0>:d    0:w               {F@2}
(~f1.1) mov (1|M0)               r30.26<2>:b   0:w                              
(f1.0)  sel (1|M0)               r80.6<1>:d    r30.26<0;1,0>:b   0:w               {I@1}
        cmp (1|M0)    (ne)f0.1   null<1>:d     r80.6<0;1,0>:d    0:w               {A@1}
(W)     and (1|M0)               f1.1<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(f1.1.any16h) goto (16|M0)                   L6832                  L6832                
L6792:
        mov (1|M0)               r80.7<1>:d    0:w                              
        mov (1|M0)               r82.4<1>:f    r83.0<0;1,0>:f                   {Compacted}
        goto (16|M0)                         L6832                  L6984                
L6832:
        join (16|M0)                         L6984                                
L6848:
        and (1|M0)    (ne)f0.1   r80.6<1>:d    r80.6<0;1,0>:d    1:w              
        mov (1|M0)               r82.4<1>:f    r83.0<0;1,0>:f                   {Compacted}
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1E0):hf                             
(f0.1)  mul (1|M0)               r82.4<1>:f    r83.0<0;1,0>:f    0x4F800000:f              
(f0.1)  sel (1|M0)               r80.7<1>:d    r2.0<0;1,0>:w     0:w               {F@2}
        shr (1|M0)               r1.2<1>:ud    r82.4<0;1,0>:ud   0x17:uw              {F@1}
        and (1|M0)               r1.2<1>:ud    r1.2<0;1,0>:ud    0xFF:uw              {I@1}
        add (1|M0)               r1.2<1>:ud    r1.2<0;1,0>:ud    0xFFFFFFE0:ud              {I@1}
(f0.1)  mov (1|M0)               r30.7<1>:d    r1.2<0;1,0>:d                    {I@1}
L6984:
        join (16|M0)                         L7392                                
L7000:
        cmp (1|M0)    (eq)f0.0   null<1>:d     r80.3<0;1,0>:d    0:w              
(f0.0)  sel (1|M0)               r81.0<1>:d    r30.26<0;1,0>:b   0:w              
        cmp (1|M0)    (ne)f1.1   null<1>:d     r81.0<0;1,0>:d    0:w               {I@1}
(W)     and (1|M0)               f1.0<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(f1.0.any16h) goto (16|M0)                   L7128                  L7128                
L7080:
        mov (1|M0)               r81.2<1>:d    0:w                              
        mov (1|M0)               r82.5<1>:d    r83.1<0;1,0>:ud                 
        goto (16|M0)                         L7128                  L7304                
L7128:
        join (16|M0)                         L7304                                
L7144:
        and (1|M0)    (ne)f0.0   r81.0<1>:d    r81.0<0;1,0>:d    1:w              
        mov (1|M0)               r82.5<1>:f    r83.1<0;1,0>:f                   {I@4}
(W)     mov (1|M0)               r2.0<1>:hf    0x20:hf                             
(f0.0)  mul (1|M0)               r82.5<1>:f    r83.1<0;1,0>:f    0x4F800000:f              
(f0.0)  sel (1|M0)               r81.2<1>:d    r2.0<0;1,0>:w     0:w               {F@2}
        shr (1|M0)               r1.2<1>:ud    r82.5<0;1,0>:ud   0x17:uw              {F@1}
        mov (1|M0)               r81.1<1>:f    (abs)r82.5<0;1,0>:f             
        and (1|M0)               r1.2<1>:ud    r1.2<0;1,0>:ud    0xFF:uw              {I@1}
        add (1|M0)               r1.2<1>:ud    r1.2<0;1,0>:ud    0xFFFFFFE0:ud              {I@1}
(f0.0)  mov (1|M0)               r80.0<1>:d    r1.2<0;1,0>:d                    {I@1}
L7304:
        join (16|M0)                         L7392                                
L7320:
        mov (1|M0)               r81.3<1>:f    (abs)r82.4<0;1,0>:f             
        add (1|M0)               r81.2<1>:d    r81.2<0;1,0>:d    r80.7<0;1,0>:d  
        add (1|M0)               r81.3<1>:d    r81.3<0;1,0>:d    -r81.1<0;1,0>:d  {F@1}
        asr (1|M0)               r81.3<1>:d    r81.3<0;1,0>:d    23:w               {Compacted,I@1}
        add (1|M0)               r81.2<1>:d    r81.2<0;1,0>:d    r81.3<0;1,0>:d   {I@1}
L7392:
        join (16|M0)                         L8888                                
L7408:
        cmp (1|M0)    (eq)f1.0   null<1>:uw    r30.26<0;1,0>:ub  0x0:uw             
(W)     mov (1|M0)               r1.2<1>:f     1.0:f                               {Compacted}
(W)     mov (1|M0)               r2.0<1>:f     0x807FFFFF:f                              
        cmp (1|M0)    (eq)f0.1   null<1>:w     r80.22<0;1,0>:b   0:w              
(~f1.0) mov (1|M0)               r81.3<1>:d    r81.2<0;1,0>:d                   {I@4}
        bfn.0xEA (1|M0)          r82.5<1>:ud   r1.2<0;0>:ud      r82.5<0;0>:ud     r2.0<0>:ud       {A@1} // s0|s1&s2
        add (1|M0)               r81.4<1>:d    r81.3<0;1,0>:d    126:w               {I@2}
        add (1|M0)               r81.5<1>:d    -r81.3<0;1,0>:d   -152:w              
        sync.nop                             null                             {Compacted,I@3}
        math.inv (1|M0)          r3.0<1>:f     r82.5<0;1,0>:f                   {$14}
        and (1|M0)               r81.5<1>:d    r81.5<0;1,0>:d    r81.4<0;1,0>:d   {I@1}
        mov (1|M0)               r85.0<1>:f    1.0:f                               {Compacted}
        asr (1|M0)               r81.5<1>:d    r81.5<0;1,0>:d    31:w               {I@1}
(~f0.1) mov (1|M0)               r81.5<1>:d    0:w                              
        bfn.0xEA (1|M0)          r82.4<1>:ud   r1.2<0;0>:ud      r82.4<0;0>:ud     r2.0<0>:ud       // s0|s1&s2
        cmp (1|M0)    (ne)f0.0   null<1>:d     r81.5<0;1,0>:d    0:w               {I@2}
        sync.nop                             null                             {Compacted,$14.dst}
        mad (1|M0)               r85.0<1>:f    r85.0<0;0>:f      r3.0<0;0>:f       -r82.5<0>:f      {F@1}
        mul (1|M0)               r3.1<1>:f     r3.0<0;1,0>:f     r82.4<0;1,0>:f   {I@2}
        mad (1|M0)               r85.0<1>:f    r3.0<0;0>:f       r3.0<0;0>:f       r85.0<0>:f       {F@2}
        mad (1|M0)               r85.1<1>:f    r82.4<0;0>:f      r3.1<0;0>:f       -r82.5<0>:f      {F@2}
(W)     and (1|M0)               f0.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
        mad (1|M0)               r85.1<1>:f    r3.1<0;0>:f       r85.0<0;0>:f      r85.1<0>:f       {F@1}
        add (1|M0)               r30.7<1>:d    r30.7<0;1,0>:d    -r80.0<0;1,0>:d 
        mad (1|M0)               r82.4<1>:f    r82.4<0;0>:f      r85.1<0;0>:f      -r82.5<0>:f      {F@1}
(~f0.1.any16h) goto (16|M0)                  L8544                  L8544                
L7792:
        mov (1|M0)               r81.7<1>:f    r82.4<0;1,0>:f                   {F@1}
        mov (2|M0)               r84.0<1>:f    r85.0<1;1,0>:f                  
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r83.4         L9120                                 {A@1}
L7872:
        cmp (1|M0)    (eq)f1.0   null<1>:f     r82.4<0;1,0>:f    0.0:f              
(W)     mov (1|M0)               r1.3<1>:hf    0x1:hf                             
        add (1|M0)               r81.3<1>:d    r81.3<0;1,0>:d    125:w               {Compacted}
(W)     mov (1|M0)               r3.0<1>:hf    0x1:hf                             
(f1.0)  sel (1|M0)               r2.0<1>:w     r1.3<0;1,0>:w     0:w               {F@2}
        cmp (1|M0)    (lt)f0.0   null<1>:d     r81.3<0;1,0>:d    -2:w               {I@2}
        cmp (1|M0)    (ne)f0.1   null<1>:w     r2.0<0;1,0>:w     0:w               {I@2}
(W)     mov (1|M0)               r5.0<1>:hf    -qnan(0x1FF):hf                             
(f0.0)  sel (1|M0)               r3.1<1>:uw    r3.0<0;1,0>:uw    0x0:uw              {F@2}
(f0.1)  sel (1|M0)               r4.0<1>:uw    r3.0<0;1,0>:uw    0x0:uw             
        or (1|M0)     (ne)f1.1   null<1>:uw    r3.1<0;1,0>:uw    r4.0<0;1,0>:uw   {I@1}
(f1.1)  sel (1|M0)               r81.24<2>:b   r5.0<0;1,0>:w     0:w               {F@1}
        cmp (1|M0)    (ne)f1.1   null<1>:uw    r81.24<0;1,0>:ub  0x0:uw              {I@1}
(W)     and (1|M0)               f0.0<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(~f0.0.any16h) goto (16|M0)                  L8224                  L8224                
L8104:
(W)     mov (1|M0)               r1.3<1>:hf    0x1:hf                             
        and (1|M0)               r1.2<1>:d     r81.7<0;1,0>:d    -2139095041:d              
(W)     mov (1|M0)               r3.0<1>:f     0x800000:f                               {Compacted}
        shl (1|M0)               r81.4<1>:d    r81.4<0;1,0>:d    23:w              
(f1.0)  sel (1|M0)               r2.0<1>:d     r1.3<0;1,0>:w     0:w               {F@2}
        add (1|M0)               r81.4<1>:d    r81.4<0;1,0>:d    1065353216:d               {I@2}
        bfn.0xFE (1|M0)          r1.2<1>:ud    r1.2<0;0>:ud      r2.0<0;0>:ud      r3.0<0>:ud       {A@1} // s0|s1|s2
        mul (1|M0)               r81.4<1>:f    r81.4<0;1,0>:f    r1.2<0;1,0>:f    {A@1}
L8224:
        join (16|M0)                         L8544                                
L8240:
        and (1|M0)               r1.2<1>:d     r81.7<0;1,0>:d    -2147483648:d               {F@1}
        shl (1|M0)               r81.7<1>:d    r81.7<0;1,0>:d    1:w              
(W)     mov (1|M0)               r1.3<1>:hf    0x1:hf                             
        and (1|M0)               r1.3<1>:d     r81.7<0;1,0>:d    8388606:d               {I@1}
        and (1|M0)    (eq)f1.1   r81.7<1>:d    r81.7<0;1,0>:d    8388608:d              
(W)     mov (1|M0)               r3.0<1>:f     1.469368e-38:f                               {Compacted}
(f0.1)  sel (1|M0)               r2.0<1>:d     r1.3<0;1,0>:w     0:w               {F@2}
(W)     mov (1|M0)               r4.1<1>:f     0x800000:f                               {Compacted}
        or (1|M0)                r2.0<1>:d     r1.2<0;1,0>:d     r2.0<0;1,0>:d    {Compacted,I@1}
(f1.1)  sel (1|M0)               r4.0<1>:d     r3.0<0;1,0>:d     12582912:d               {F@2}
        mov (1|M0)               r5.0<1>:f     0.25:f                               {Compacted}
        bfn.0xFE (1|M0)          r2.0<1>:ud    r4.1<0;0>:ud      r2.0<0;0>:ud      r1.3<0>:ud       {A@2} // s0|s1|s2
        or (1|M0)                r4.0<1>:d     r4.0<0;1,0>:d     r1.2<0;1,0>:d    {Compacted,I@2}
        or (1|M0)                r2.1<1>:d     r1.2<0;1,0>:d     8388608:d              
        mad (1|M0)               r2.0<1>:f     r4.0<0;0>:f       r5.0<0;0>:f       r2.0<0>:f        {A@1}
        cmp (1|M0)    (eq)f0.1   null<1>:uw    r81.24<0;1,0>:ub  0x0:uw             
        add (1|M0)               r2.0<1>:f     r2.0<0;1,0>:f     -r2.1<0;1,0>:f   {Compacted,A@1}
        mul (1|M0)               r2.1<1>:f     r2.1<0;1,0>:f     r2.1<0;1,0>:f   
        and (1|M0)    (ne)f0.0   null<1>:d     r81.5<0;1,0>:d    1:w              
        and (1|M0)               r2.1<1>:d     r2.1<0;1,0>:d     -2:w               {Compacted,F@1}
        or (1|M0)                r2.1<1>:d     r2.1<0;1,0>:d     r2.0<0;1,0>:d    {Compacted,I@1}
(~f0.1) mov (1|M0)               r2.1<1>:f     r81.4<0;1,0>:f                   {I@1}
(f0.0)  mov (1|M0)               r82.0<1>:f    r2.1<0;1,0>:f                    {F@1}
L8544:
        join (16|M0)                         L8888                                
L8560:
        add (1|M0)               r2.0<1>:d     r30.7<0;1,0>:d    126:w               {Compacted}
(W)     mov (1|M0)               r1.3<1>:uw    r81.20<0;1,0>:ub                
        cmp (1|M0)    (gt)f0.0   null<1>:ud    r2.0<0;1,0>:ud    0x17A:uw              {A@1}
        mad (1|M0)               r82.4<1>:f    r85.1<0;0>:f      r85.0<0;0>:f      r82.4<0>:f      
        or (1|M0)                r81.13<1>:w   r80.22<0;1,0>:ub  r1.3<0;1,0>:uw   {I@2}
(W)     and (1|M0)               f1.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
(~f1.1.any16h) goto (16|M0)                  L8744                  L8744                
L8664:
(f0.0)  sel (1|M0)               r1.2<1>:d     r30.7<0;1,0>:d    0:w              
        asr (1|M0)               r1.2<1>:d     r1.2<0;1,0>:d     11:w               {I@1}
        add (1|M0)               r1.3<1>:d     r1.2<0;1,0>:d     248:w               {I@1}
        xor (1|M0)               r1.3<1>:d     r1.3<0;1,0>:d     r1.2<0;1,0>:d    {I@1}
(f0.0)  mov (1|M0)               r30.7<1>:d    r1.3<0;1,0>:d                    {I@1}
L8744:
        join (16|M0)                         L8888                                
L8760:
        asr (1|M0)               r1.2<1>:d     r30.7<0;1,0>:d    1:w               {I@2}
        cmp (1|M0)    (eq)f1.1   null<1>:w     r81.13<0;1,0>:w   0:w              
        add (1|M0)               r30.7<1>:d    r30.7<0;1,0>:d    -r1.2<0;1,0>:d   {I@2}
        shl (1|M0)               r1.2<1>:d     r1.2<0;1,0>:d     23:w              
        shl (1|M0)               r30.7<1>:d    r30.7<0;1,0>:d    23:w               {I@2}
        add (1|M0)               r1.2<1>:d     r1.2<0;1,0>:d     r82.4<0;1,0>:d   {A@1}
        add (1|M0)               r30.7<1>:d    r30.7<0;1,0>:d    1065353216:d               {I@2}
(f1.1)  mul (1|M0)               r82.0<1>:f    r30.7<0;1,0>:f    r1.2<0;1,0>:f    {I@1}
L8888:
        join (16|M0)                         L8904                                
L8904:
        sync.nop                             null                             {Compacted,F@1}
        math.inv (1|M0)          r1.2<1>:f     r83.1<0;1,0>:f                   {$15}
        mov (1|M0)               r1.4<1>:ud    0x3F800000:ud                             
        mul (1|M0)               r1.3<1>:f     r1.2<0;1,0>:f     r83.0<0;1,0>:f   {$15.dst}
        mad (1|M0)               r1.4<1>:f     r1.4<0;0>:f       r1.2<0;0>:f       -r83.1<0>:f      {I@1}
        mad (1|M0)               r2.0<1>:f     r83.0<0;0>:f      r1.3<0;0>:f       -r83.1<0>:f      {F@2}
        mad (1|M0)               r1.4<1>:f     r1.2<0;0>:f       r1.2<0;0>:f       r1.4<0>:f        {F@2}
        cmp (1|M0)    (eq)f1.0   null<1>:uw    r30.24<0;1,0>:ub  0x0:uw             
        mad (1|M0)               r2.0<1>:f     r1.3<0;0>:f       r1.4<0;0>:f       r2.0<0>:f        {F@1}
        mad (1|M0)               r83.0<1>:f    r83.0<0;0>:f      r2.0<0;0>:f       -r83.1<0>:f      {F@1}
(f1.0)  mad (1|M0)               r82.0<1>:f    r2.0<0;0>:f       r1.4<0;0>:f       r83.0<0>:f       {F@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        ret (16|M0)                          r82.2                            {A@1}
L9120:
        mov (1|M0)               r1.2<1>:d     cr0.0<0;1,0>:ud                  {A@1}
        and (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   -1265:w               {A@1}
        or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   1264:w               {A@1}
        mad (1|M0)               r81.7<1>:f    r84.1<0;0>:f      r84.0<0;0>:f      r81.7<0>:f       {A@1}
        mov (1|M0)               cr0.0<1>:ud   r1.2<0;1,0>:d                    {A@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        ret (16|M0)                          r83.4                            {A@1}
L9248:
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
