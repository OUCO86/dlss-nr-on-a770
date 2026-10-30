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
        shr (1|M0)               r1.3<1>:ud    r25.0<0;1,0>:ud   0x14:uw              {I@3}
        shl (1|M0)               r25.2<1>:d    r25.0<0;1,0>:d    12:w               {Compacted}
        shl (1|M0)               r1.2<1>:d     r25.1<0;1,0>:d    12:w               {I@4}
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
        addc (1|M0)              r3.0<1>:ud    r25.4<0;1,0>:ud   0x800:ud              {AccWrEn}
        send.ugm (1|M0)          r27      r10     null:0  0x0            0x0210B780           {A@1,$3} // wr:1+0, rd:1; load.ugm.d64x4t.a64
        mov (1|M0)               r28.0<1>:f    r3.0<0;1,0>:f                    {Compacted,I@1}
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        shl (1|M0)               r1.4<1>:d     r28.0<0;1,0>:d    1:w               {Compacted,F@1}
        add3 (1|M0)              r28.1<1>:d    r5.0<0;0>:d       r25.5<0;0>:d      0:w               {I@2}
        addc (1|M0)              r2.0<1>:ud    r4.0<0;1,0>:ud    r1.4<0;1,0>:ud   {AccWrEn,I@2}
        shr (1|M0)               r1.3<1>:ud    r28.0<0;1,0>:ud   0x1F:uw             
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r3.0<1>:ud    r25.4<0;1,0>:ud   0xC00:ud              {AccWrEn}
        shl (1|M0)               r1.2<1>:d     r28.1<0;1,0>:d    1:w               {I@5}
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r28.2<1>:d    r3.0<0;1,0>:d                    {I@3}
        mov (1|M0)               r7.0<1>:f     r2.0<0;1,0>:f                    {Compacted}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@3}
        add3 (1|M0)              r28.3<1>:d    r5.0<0;0>:d       r25.5<0;0>:d      0:w               {I@3}
        shl (1|M0)               r2.0<1>:d     r28.2<0;1,0>:d    1:w               {Compacted,A@1}
        shr (1|M0)               r4.4<1>:ud    r28.2<0;1,0>:ud   0x1F:uw             
        add3 (1|M0)              r7.1<1>:d     r6.0<0;0>:d       r4.2<0;0>:d       r1.5<0>:d        {I@4}
        shl (1|M0)               r4.3<1>:d     r28.3<0;1,0>:d    1:w               {Compacted,I@4}
        addc (1|M0)              r6.0<1>:ud    r4.0<0;1,0>:ud    r2.0<0;1,0>:ud   {AccWrEn,I@4}
        send.ugm (1|M0)          r29      r7      null:0  0x0            0x0210B780           {A@3,$4} // wr:1+0, rd:1; load.ugm.d64x4t.a64
        or (1|M0)                r2.1<1>:d     r4.3<0;1,0>:d     r4.4<0;1,0>:d    {I@2}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$4.src}
        mov (8|M0)               r8.0<1>:f     (abs)r26.0<1;1,0>:hf             {$2.dst}
        mov (8|M0)               r9.0<1>:f     (abs)r26.8<1;1,0>:hf            
        sel (16|M0)   (ge)f0.0   acc0.0<1>:f   r8.0<1;1,0>:f     0.0:f               {Compacted,A@1}
        mov (8|M0)               r11.0<1>:f    (abs)r27.0<1;1,0>:hf             {$3.dst}
        mov (8|M0)               r12.0<1>:f    (abs)r27.8<1;1,0>:hf            
        sel (16|M0)   (ge)f0.0   acc0.0<1>:f   acc0.0<1;1,0>:f   r11.0<1;1,0>:f   {Compacted,F@1}
        mov (1|M0)               r12.0<1>:f    r6.0<0;1,0>:f                    {Compacted}
        add3 (1|M0)              r12.1<1>:d    r7.0<0;0>:d       r4.2<0;0>:d       r2.1<0>:d        {F@2}
        shl (1|M0)               r6.0<1>:d     r1.0<0;1,0>:uw    2:w               {F@1}
        send.ugm (1|M0)          r30      r12     null:0  0x0            0x0210B780           {A@2,$5} // wr:1+0, rd:1; load.ugm.d64x4t.a64
        mov (8|M0)               r10.0<1>:f    (abs)r29.0<1;1,0>:hf             {$4.dst}
        mov (8|M0)               r11.0<1>:f    (abs)r29.8<1;1,0>:hf            
        sel (16|M0)   (ge)f0.0   acc0.0<1>:f   acc0.0<1;1,0>:f   r10.0<1;1,0>:f   {Compacted,F@1}
        mov (8|M0)               r10.0<1>:f    (abs)r30.0<1;1,0>:hf             {$5.dst}
        mov (8|M0)               r11.0<1>:f    (abs)r30.8<1;1,0>:hf            
        sel (16|M0)   (ge)f0.0   r8.0<1>:f     acc0.0<1;1,0>:f   r10.0<1;1,0>:f   {Compacted,F@1}
        sel (8|M0)    (ge)f0.0   r3.0<1>:f     r8.0<1;1,0>:f     r9.0<1;1,0>:f    {Compacted,F@1}
        mov (4|M0)               r5.0<1>:ud    r3.4<1;1,0>:ud                   {F@1}
        sel (4|M0)    (ge)f0.0   r13.0<1>:f    r3.0<1;1,0>:f     r5.0<1;1,0>:f    {I@1}
        mov (2|M0)               r14.0<1>:ud   r13.2<1;1,0>:ud                  {F@1}
        sel (2|M0)    (ge)f0.0   r15.0<1>:f    r13.0<1;1,0>:f    r14.0<1;1,0>:f   {I@1}
        sel (1|M0)    (ge)f0.0   r16.0<1>:f    r15.0<0;1,0>:f    r15.1<0;1,0>:f   {F@1}
        send.slm (1|M0)          null     r6      r16:1   0x0            0x02000504           {A@1,$6} // wr:1+1, rd:0; store.slm.d32.a32
(W)     send.slm (1|M0)          r4       r0      null:0  0x0            0x0210001F           {$7} // wr:1+0, rd:1; fence.slm.none.group
(W)     mov (1|M0)               r7.2<1>:f     0.0:f                               {Compacted}
(W)     mov (2|M0)               r7.10<1>:ub   r0.11<0;1,0>:ub                  {F@1}
(W)     mov (8|M0)               null<1>:ud    r4.0<1;1,0>:ud                   {$7.dst}
(W)     send.gtwy (1|M0)         null     r7      null:0  0x0            0x02000004           {A@2,$8} // wr:1+0, rd:0; signal barrier
(W)     sync.bar                             null                            
        mov (1|M0)               r2.0<1>:d     0:w                              
        send.slm (1|M0)          r17      r2      null:0  0x0            0x0280E700           {A@1,$9} // wr:1+0, rd:8; load.slm.d64x32t.a32
        sel (16|M0)   (ge)f0.0   acc0.0<1>:f   r17.0<1;1,0>:f    r21.0<1;1,0>:f   {Compacted,$9.dst}
        sel (16|M0)   (ge)f0.0   acc2.0<1>:f   r19.0<1;1,0>:f    r23.0<1;1,0>:f   {Compacted}
        sel (16|M0)   (ge)f0.0   r8.0<1>:f     acc0.0<1;1,0>:f   acc2.0<1;1,0>:f 
        sel (8|M0)    (ge)f0.0   r3.0<1>:f     r8.0<1;1,0>:f     r9.0<1;1,0>:f    {Compacted,F@1}
        mov (4|M0)               r5.0<1>:ud    r3.4<1;1,0>:ud                   {F@1}
        sel (4|M0)    (ge)f0.0   r4.0<1>:f     r3.0<1;1,0>:f     r5.0<1;1,0>:f    {I@1}
        sync.nop                             null                             {Compacted,$6.src}
        mov (2|M0)               r6.0<1>:ud    r4.2<1;1,0>:ud                   {F@1}
        sel (2|M0)    (ge)f0.0   r12.0<1>:f    r4.0<1;1,0>:f     r6.0<1;1,0>:f    {I@1}
        sel (1|M0)    (ge)f0.0   r85.0<1>:f    r12.0<0;1,0>:f    r12.1<0;1,0>:f   {F@1}
        cmp (1|M0)    (eq)f1.1   null<1>:f     r85.0<0;1,0>:f    0.0:f               {F@1}
(W)     and (1|M0)               f0.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(f0.1.any16h) goto (16|M0)                   L1744                  L1744                
L1664:
        mov (1|M0)               r85.1<1>:f    127.0:f                              
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r84.6         L6112                                 {A@1}
L1728:
        goto (16|M0)                         L1744                  L1768                
L1744:
        join (16|M0)                         L1768                                
L1760:
        mov (1|M0)               r86.0<1>:f    1.0:f                               {Compacted}
L1768:
        join (16|M0)                         L1784                                
L1784:
        cmp (1|M0)    (eq)f1.0   null<1>:w     r1.0<0;1,0>:w     0:w              
(W)     and (1|M0)               f0.0<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
(~f0.0.any16h) goto (16|M0)                  L1952                  L1952                
L1832:
        shl (1|M0)               r1.4<1>:d     r25.0<0;1,0>:d    2:w               {Compacted}
        shl (1|M0)               r1.2<1>:d     r25.1<0;1,0>:d    2:w              
        shr (1|M0)               r1.3<1>:ud    r25.0<0;1,0>:ud   0x1E:uw             
        addc (1|M0)              r2.0<1>:ud    r2.4<0;1,0>:ud    r1.4<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        mov (1|M0)               r3.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r4.0<1>:f     r2.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r4.1<1>:d     r3.0<0;0>:d       r2.5<0;0>:d       r1.5<0>:d        {I@1}
        send.ugm (1|M0)          null     r4      r86:1   0x0            0x04000584           {A@1,$10} // wr:2+1, rd:0; store.ugm.d32.a64
L1952:
        join (16|M0)                         L1968                                
L1968:
        addc (1|M0)              r2.0<1>:ud    r2.6<0;1,0>:ud    r25.2<0;1,0>:ud  {AccWrEn}
        mov (16|M0)              r31.0<1>:f    r86.0<0;1,0>:f                   {Compacted}
        mov (1|M0)               r3.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (16|M0)              r35.0<1>:f    r31.0<1;1,0>:f                   {Compacted,F@1}
        mov (8|M0)               r33.0<1>:f    r26.0<1;1,0>:hf                 
        mov (8|M0)               r34.0<1>:f    r26.8<1;1,0>:hf                 
        mov (1|M0)               r28.4<1>:d    r2.0<0;1,0>:d                    {I@2}
        add3 (1|M0)              r28.5<1>:d    r3.0<0;0>:d       r2.7<0;0>:d       r25.3<0>:d       {I@2}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r85.2         L2976                                 {A@1}
L2120:
        rnde (16|M0)             r37.0<1>:f    r37.0<1;1,0>:f                   {Compacted}
        sel (16|M0)   (ge)f0.0   r37.0<1>:f    r37.0<1;1,0>:f    -127.0:f               {F@1}
        addc (1|M0)              r2.0<1>:ud    r28.4<0;1,0>:ud   r25.4<0;1,0>:ud  {AccWrEn,I@3}
        sel (16|M0)   (lt)f0.0   r37.0<1>:f    r37.0<1;1,0>:f    127.0:f               {F@1}
        mov (1|M0)               r3.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (16|M0)              r5.0<1>:d     r37.0<1;1,0>:f                   {Compacted,F@1}
        mov (1|M0)               r4.0<1>:d     r2.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r4.1<1>:d     r3.0<0;0>:d       r28.5<0;0>:d      r25.5<0>:d       {I@3}
        mov (16|M0)              r7.0<1>:b     r5.0<4;1,0>:b                    {I@3}
        mov (16|M0)              r35.0<1>:f    r31.0<1;1,0>:f                   {Compacted}
        send.ugm (1|M0)          null     r4      r7:1    0x0            0x02009784           {A@1,$11} // wr:1+1, rd:0; store.ugm.d64x2t.a64
        mov (8|M0)               r33.0<1>:f    r27.0<1;1,0>:hf                 
        mov (8|M0)               r34.0<1>:f    r27.8<1;1,0>:hf                 
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r85.2         L2976                                 {A@1}
L2344:
        rnde (16|M0)             r37.0<1>:f    r37.0<1;1,0>:f                   {Compacted}
        sel (16|M0)   (ge)f0.0   r37.0<1>:f    r37.0<1;1,0>:f    -127.0:f               {F@1}
        addc (1|M0)              r2.0<1>:ud    r28.4<0;1,0>:ud   r25.6<0;1,0>:ud  {AccWrEn}
        sel (16|M0)   (lt)f0.0   r37.0<1>:f    r37.0<1;1,0>:f    127.0:f               {F@1}
        mov (1|M0)               r3.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (16|M0)              r5.0<1>:d     r37.0<1;1,0>:f                   {Compacted,F@1}
        mov (1|M0)               r4.0<1>:d     r2.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r4.1<1>:d     r3.0<0;0>:d       r28.5<0;0>:d      r25.7<0>:d       {I@3}
        mov (16|M0)              r7.0<1>:b     r5.0<4;1,0>:b                    {I@3}
        mov (16|M0)              r35.0<1>:f    r31.0<1;1,0>:f                   {Compacted}
        send.ugm (1|M0)          null     r4      r7:1    0x0            0x02009784           {A@1,$12} // wr:1+1, rd:0; store.ugm.d64x2t.a64
        mov (8|M0)               r33.0<1>:f    r29.0<1;1,0>:hf                 
        mov (8|M0)               r34.0<1>:f    r29.8<1;1,0>:hf                 
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r85.2         L2976                                 {A@1}
L2568:
        rnde (16|M0)             r37.0<1>:f    r37.0<1;1,0>:f                   {Compacted}
        sel (16|M0)   (ge)f0.0   r37.0<1>:f    r37.0<1;1,0>:f    -127.0:f               {F@1}
        addc (1|M0)              r2.0<1>:ud    r28.4<0;1,0>:ud   r28.0<0;1,0>:ud  {AccWrEn}
        sel (16|M0)   (lt)f0.0   r37.0<1>:f    r37.0<1;1,0>:f    127.0:f               {F@1}
        mov (1|M0)               r3.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (16|M0)              r5.0<1>:d     r37.0<1;1,0>:f                   {Compacted,F@1}
        mov (1|M0)               r4.0<1>:d     r2.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r4.1<1>:d     r3.0<0;0>:d       r28.5<0;0>:d      r28.1<0>:d       {I@3}
        mov (16|M0)              r7.0<1>:b     r5.0<4;1,0>:b                    {I@3}
        mov (16|M0)              r35.0<1>:f    r31.0<1;1,0>:f                   {Compacted}
        send.ugm (1|M0)          null     r4      r7:1    0x0            0x02009784           {A@1,$13} // wr:1+1, rd:0; store.ugm.d64x2t.a64
        mov (8|M0)               r33.0<1>:f    r30.0<1;1,0>:hf                 
        mov (8|M0)               r34.0<1>:f    r30.8<1;1,0>:hf                 
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r85.2         L2976                                 {A@1}
L2792:
        rnde (16|M0)             r37.0<1>:f    r37.0<1;1,0>:f                   {Compacted}
        sel (16|M0)   (ge)f0.0   r37.0<1>:f    r37.0<1;1,0>:f    -127.0:f               {F@1}
        addc (1|M0)              r2.0<1>:ud    r28.4<0;1,0>:ud   r28.2<0;1,0>:ud  {AccWrEn}
        sel (16|M0)   (lt)f0.0   r37.0<1>:f    r37.0<1;1,0>:f    127.0:f               {F@1}
        mov (1|M0)               r3.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (16|M0)              r5.0<1>:d     r37.0<1;1,0>:f                   {Compacted,F@1}
        mov (1|M0)               r4.0<1>:f     r2.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r4.1<1>:d     r3.0<0;0>:d       r28.5<0;0>:d      r28.3<0>:d       {I@2}
        mov (16|M0)              r7.0<1>:b     r5.0<4;1,0>:b                    {I@2}
        send.ugm (1|M0)          null     r4      r7:1    0x0            0x02009784           {A@1,$14} // wr:1+1, rd:0; store.ugm.d64x2t.a64
(W)     mov (8|M0)               r127.0<1>:f   r0.0<1;1,0>:f                    {Compacted}
(W)     send.ugm (1|M0)          r8       r0      null:0  0x0            0x0210641F           {$15} // wr:1+0, rd:1; fence invalid flush type scoped to tile
(W)     mov (8|M0)               null<1>:ud    r8.0<1;1,0>:ud                   {$15.dst}
(W)     send.gtwy (1|M0)         null     r127    null:0  0x0            0x02000010           {EOT,A@1} // wr:1+0, rd:0; end of thread
L2976:
(W)     shr (16|M0)              r3.0<1>:ud    r33.0<1;1,0>:ud   0x17:uw             
(W)     and (16|M0)              r39.0<1>:w    r3.0<2;1,0>:w     255:w               {I@1}
(W)     add (16|M0)              r7.0<1>:d     r39.0<1;1,0>:uw   -191:w               {I@1}
(W)     cmp (16|M0)   (lt)f1.0   null<1>:d     r7.0<1;1,0>:ud    0xFFFFFF82:ud              {I@1}
(W)     shr (16|M0)              r5.0<1>:ud    r35.0<1;1,0>:ud   0x17:uw             
(W)     mov (1|M0)               r86.2<1>:uw   f1.0<0;1,0>:uw                   {Compacted}
(W)     and (16|M0)              r44.0<1>:w    r5.0<2;1,0>:w     255:w               {I@2}
(W)     mov (1|M0)               f0.1<1>:uw    r86.2<0;1,0>:uw                  {I@2}
(W)     add (16|M0)              r9.0<1>:d     r44.0<1;1,0>:uw   -191:w               {I@2}
(W)     mov (16|M0)              r40.0<1>:d    r39.0<1;1,0>:uw                 
(W&~f0.1) cmp (16|M0) (lt)f0.1   null<1>:d     r9.0<1;1,0>:ud    0xFFFFFF81:ud              {I@2}
(W)     mov (16|M0)              r42.0<1>:d    r39.0<1;1,0>:uw                 
(W)     mov (1|M0)               r86.2<1>:uw   f0.1<0;1,0>:uw                  
(W)     mov (16|M0)              r45.0<1>:d    r44.0<1;1,0>:uw                 
(W)     mov (1|M0)               f0.0<1>:uw    r86.2<0;1,0>:uw                  {I@2}
(W)     mov (16|M0)              r47.0<1>:d    r44.0<1;1,0>:uw                 
(~f0.0.any16h) goto (16|M0)                  L5784                  L5784                
L3240:
(W)     add (16|M0)              r3.0<1>:d     r39.0<1;1,0>:uw   -255:w              
(W)     cmp (16|M0)   (lt)f0.0   null<1>:d     r3.0<1;1,0>:ud    0xFFFFFF02:ud              {I@1}
(W)     add (16|M0)              r5.0<1>:d     r44.0<1;1,0>:uw   -255:w              
(W&~f0.0) cmp (16|M0) (lt)f0.0   null<1>:d     r5.0<1;1,0>:ud    0xFFFFFF02:ud              {I@1}
(W)     mov (16|M0)              r59.0<1>:f    (abs)r33.0<1;1,0>:f              {Compacted}
(f0.0.any16h) goto (16|M0)                   L3400                  L3400                
L3328:
(W)     mov (16|M0)              r3.0<1>:f     (abs)r35.0<1;1,0>:f              {Compacted}
(W)     add (16|M0)              r59.0<1>:d    r59.0<1;1,0>:d    -r3.0<1;1,0>:d   {Compacted,A@1}
(W)     mov (4|M0)               r63.0<1>:d    0:w                              
(W)     mov (16|M0)              r72.0<1>:f    r33.0<1;1,0>:f                   {Compacted}
(W)     mov (16|M0)              r61.0<1>:f    r35.0<1;1,0>:f                   {Compacted}
(W)     asr (16|M0)              r59.0<1>:d    r59.0<1;1,0>:d    23:w               {Compacted,I@2}
        goto (16|M0)                         L3400                  L4656                
L3400:
        join (16|M0)                         L4656                                
L3416:
(W)     mov (16|M0)              r57.0<1>:f    (abs)r35.0<1;1,0>:f              {Compacted}
(W)     cmp (16|M0)   (gt)f1.1   null<1>:d     r59.0<1;1,0>:ud   0x7F800000:ud              {I@3}
(W)     cmp (16|M0)   (lt)f1.0   null<1>:d     r57.0<1;1,0>:ud   0x7F800001:ud              {F@1}
(W)     and (16|M0)              r49.0<1>:ud   r33.0<1;1,0>:ud   0x7F800000:ud             
(W)     mov (1|M0)               r1.3<1>:uw    f1.1<0;1,0>:uw                  
(W)     mov (1|M0)               r2.0<1>:uw    f1.0<0;1,0>:uw                   {Compacted}
(W)     or (1|M0)                f0.1<1>:uw    f1.0<0;1,0>:uw    r1.3<0;1,0>:uw   {I@2}
(W)     cmp (16|M0)   (ne)f1.0   null<1>:d     r49.0<1;1,0>:d    2139095040:d              
(W)     or (1|M0)                r5.0<1>:uw    f1.1<0;1,0>:uw    ~r2.0<0;1,0>:uw  {I@3}
(W)     mov (1|M0)               r8.0<1>:f     -0.0:f                               {Compacted}
(W)     or (1|M0)                r5.1<1>:uw    f1.0<0;1,0>:uw    r5.0<0;1,0>:uw   {I@1}
(W&f0.1) sel (16|M0)             acc0.0<1>:f   r33.0<1;1,0>:f    r35.0<1;1,0>:f  
(W)     mov (1|M0)               f0.1<1>:uw    r5.1<0;1,0>:uw                   {A@1}
(W)     and (16|M0)              r51.0<1>:ud   r35.0<1;1,0>:ud   0x7F800000:ud             
(W)     bfn.0x6A (16|M0)         r37.0<1>:ud   r33.0<1;0>:ud     r35.0<1;0>:ud     r8.0<0>:ud       // s0^s1&s2
(W)     bfn.0x6A (16|M0)         r9.0<1>:ud    r35.0<1;0>:ud     r33.0<1;0>:ud     r8.0<0>:ud       // s0^s1&s2
(W)     add (16|M0)              r37.0<1>:f    r37.0<1;1,0>:f    -r9.0<1;1,0>:f   {Compacted,A@1}
(W&f0.1) add (16|M0)             r37.0<1>:f    acc0.0<1;1,0>:f   r35.0<1;1,0>:f  
(W)     cmp (16|M0)   (ne)f0.1   null<1>:d     r51.0<1;1,0>:d    2139095040:d               {F@1}
(W)     or (1|M0)                r5.0<1>:uw    ~f1.0<0;1,0>:uw   r5.0<0;1,0>:uw  
(W)     cmp (16|M0)   (eq)f1.0   null<1>:f     r35.0<1;1,0>:f    0.0:f               {I@1}
(W)     or (1|M0)                r1.3<1>:uw    f0.1<0;1,0>:uw    r5.0<0;1,0>:uw  
(W)     or (1|M0)                r5.0<1>:uw    ~f0.1<0;1,0>:uw   r5.0<0;1,0>:uw  
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                             
(W)     mov (1|M0)               f0.1<1>:uw    r5.0<0;1,0>:uw                   {I@1}
(W)     and (1|M0)               r3.0<1>:uw    f1.0<0;1,0>:uw    ~r5.0<0;1,0>:uw 
(W)     mov (1|M0)               f1.1<1>:uw    r1.3<0;1,0>:uw                  
(W)     and (16|M0)              r6.0<1>:ud    r35.0<1;1,0>:ud   0x80000000:ud             
(W&f0.1) sel (16|M0)             r11.0<2>:b    r2.0<0;1,0>:w     0:w               {F@1}
(W)     mov (1|M0)               f0.1<1>:uw    r3.0<0;1,0>:uw                   {I@4}
(W)     and (16|M0)              r53.0<1>:ud   r33.0<1;1,0>:ud   0x80000000:ud             
(W&~f1.1) mul (16|M0)            r37.0<1>:f    r6.0<1;1,0>:f     r33.0<1;1,0>:f   {I@4}
(W)     mov (16|M0)              r63.0<1>:b    r11.0<2;1,0>:b                   {I@3}
(~f0.1) goto (16|M0)                         L4048                  L4048                
L3928:
(W)     cmp (16|M0)   (eq)f1.0   null<1>:f     r33.0<1;1,0>:f    0.0:f              
(W)     mov (1|M0)               r1.2<1>:ud    0x7F800000:ud                             
(W)     mov (1|M0)               r2.0<2>:b     -1:w                              
(W&f1.0) mov (16|M0)             r53.0<1>:ud   0:w                              
(W)     bfn.0x96 (16|M0)         r53.0<1>:ud   r1.2<0;0>:ud      r53.0<1;0>:ud     r35.0<1>:ud      {I@1} // s0^s1^s2
(W&f1.0) mul (16|M0)             r53.0<1>:f    r53.0<1;1,0>:f    r33.0<1;1,0>:f   {I@1}
        mov (16|M0)              r63.0<1>:b    r2.0<0;1,0>:b                   
        mov (16|M0)              r37.0<1>:f    r53.0<1;1,0>:f                   {Compacted,F@1}
L4048:
        join (16|M0)                         L4656                                
L4064:
(W)     cmp (16|M0)   (eq)f0.1   null<1>:f     r33.0<1;1,0>:f    0.0:f              
(W&f0.1) cmp (16|M0)  (eq)f0.1   null<1>:w     r63.0<1;1,0>:ub   0x0:uw              {A@1}
(W&~f0.1) sel (16|M0)            r3.0<2>:b     r63.0<1;1,0>:b    -1:w              
(W)     mov (16|M0)              r63.0<1>:b    r3.0<2;1,0>:b                    {I@1}
(W)     cmp (16|M0)   (ne)f1.1   null<1>:w     r63.0<1;1,0>:ub   0x0:uw              {I@1}
(W&f0.1) mul (16|M0)             r37.0<1>:f    r33.0<1;1,0>:f    r35.0<1;1,0>:f  
(f1.1.all16h) goto (16|M0)                   L4656                  L5784                
L4176:
(W)     cmp (16|M0)   (eq)f1.1   null<1>:w     r63.0<1;1,0>:ub   0x0:uw             
(W)     mov (1|M0)               r1.3<1>:uw    f0.0<0;1,0>:uw                  
(W)     cmp (16|M0)   (eq)f1.0   null<1>:d     r49.0<1;1,0>:d    0:w              
(W)     and (1|M0)               f0.0<1>:uw    f1.1<0;1,0>:uw    r1.3<0;1,0>:uw   {I@2}
(W)     mov (16|M0)              r64.0<1>:d    0:w                              
(W)     mov (1|M0)               r2.0<1>:uw    f1.0<0;1,0>:uw                   {Compacted}
(W)     mov (16|M0)              r72.0<1>:f    r33.0<1;1,0>:f                   {Compacted}
(W)     and (1|M0)               f1.0<1>:uw    f0.0<0;1,0>:uw    r2.0<0;1,0>:uw   {I@1}
(W)     mov (16|M0)              r55.0<1>:f    r64.0<1;1,0>:f                   {Compacted}
(~f1.0) goto (16|M0)                         L4408                  L4408                
L4312:
        mul (16|M0)              r72.0<1>:f    r33.0<1;1,0>:f    0x4F800000:f               {Compacted}
(W)     shr (16|M0)              r3.0<1>:ud    r72.0<1;1,0>:ud   0x17:uw              {F@1}
(W)     and (16|M0)              r5.0<1>:w     r3.0<2;1,0>:w     255:w               {I@1}
        add (16|M0)              r42.0<1>:d    r5.0<1;1,0>:uw    -32:w               {I@1}
(W)     mov (16|M0)              r55.0<1>:d    0:w                              
(W)     mov (16|M0)              r40.0<1>:f    r42.0<1;1,0>:f                   {Compacted,I@2}
        mov (16|M0)              r55.0<1>:d    -32:w                              
L4408:
        join (16|M0)                         L4656                                
L4424:
(W)     cmp (16|M0)   (eq)f0.1   null<1>:d     r51.0<1;1,0>:d    0:w              
(W)     mov (16|M0)              r61.0<1>:f    r35.0<1;1,0>:f                   {Compacted}
(W)     mov (1|M0)               r1.3<1>:uw    f0.1<0;1,0>:uw                  
(W)     and (1|M0)               f0.1<1>:uw    f0.0<0;1,0>:uw    r1.3<0;1,0>:uw   {I@1}
(~f0.1) goto (16|M0)                         L4600                  L4600                
L4496:
        mul (16|M0)              r61.0<1>:f    r35.0<1;1,0>:f    0x4F800000:f               {Compacted}
(W)     shr (16|M0)              r3.0<1>:ud    r61.0<1;1,0>:ud   0x17:uw              {F@1}
(W)     and (16|M0)              r5.0<1>:w     r3.0<2;1,0>:w     255:w               {I@1}
        add (16|M0)              r47.0<1>:d    r5.0<1;1,0>:uw    -32:w               {I@1}
(W)     mov (16|M0)              r64.0<1>:d    0:w                              
(W)     mov (16|M0)              r57.0<1>:f    (abs)r61.0<1;1,0>:f              {Compacted}
(W)     mov (16|M0)              r45.0<1>:f    r47.0<1;1,0>:f                   {Compacted,I@2}
        mov (16|M0)              r64.0<1>:d    32:w                              
L4600:
        join (16|M0)                         L4656                                
L4616:
(W)     mov (16|M0)              r59.0<1>:f    (abs)r72.0<1;1,0>:f              {Compacted}
(W)     add (16|M0)              r59.0<1>:d    r59.0<1;1,0>:d    -r57.0<1;1,0>:d  {Compacted,F@1}
(W)     asr (16|M0)              r59.0<1>:d    r59.0<1;1,0>:d    23:w               {Compacted,I@1}
(W)     add3 (16|M0)             r64.0<1>:d    r64.0<1;0>:d      r55.0<1;0>:d      r59.0<1>:d       {I@1}
L4656:
        join (16|M0)                         L5784                                
L4672:
(W)     mov (1|M0)               r1.2<1>:f     1.0:f                               {Compacted}
(W)     mov (1|M0)               r2.0<1>:f     0x807FFFFF:f                              
(W&~f0.0) mov (16|M0)            r64.0<1>:f    r59.0<1;1,0>:f                   {I@2}
(W)     bfn.0xEA (16|M0)         r61.0<1>:ud   r1.2<0;0>:ud      r61.0<1;0>:ud     r2.0<0>:ud       {A@2} // s0|s1&s2
(W)     add (16|M0)              r66.0<1>:d    r64.0<1;1,0>:d    126:w               {Compacted,F@1}
(W)     add (16|M0)              r3.0<1>:d     -r64.0<1;1,0>:d   -152:w               {Compacted}
        sync.nop                             null                             {Compacted,I@3}
(W)     math.inv (16|M0)         r5.0<1>:f     r61.0<1;1,0>:f                   {$0}
(W)     cmp (16|M0)   (eq)f0.0   null<1>:w     r63.0<1;1,0>:ub   0x0:uw             
(W)     and (16|M0)              r3.0<1>:d     r3.0<1;1,0>:d     r66.0<1;1,0>:d   {Compacted,I@2}
(W)     mov (1|M0)               r9.0<1>:f     1.0:f                               {Compacted}
(W)     bfn.0xEA (16|M0)         r72.0<1>:ud   r1.2<0;0>:ud      r72.0<1;0>:ud     r2.0<0>:ud       // s0|s1&s2
(W)     asr (16|M0)              r3.0<1>:d     r3.0<1;1,0>:d     31:w               {Compacted,I@2}
        sync.nop                             null                             {Compacted,$0.dst}
(W)     mad (16|M0)              r68.0<1>:f    r9.0<0;0>:f       r5.0<1;0>:f       -r61.0<1>:f      {F@1}
(W)     mul (16|M0)              acc0.0<1>:f   r5.0<1;1,0>:f     r72.0<1;1,0>:f   {Compacted,I@2}
(W&f0.0) sel (16|M0)             r74.0<1>:w    r3.0<4;1,0>:ub    0:w               {I@1}
(W)     mad (16|M0)              r68.0<1>:f    r5.0<1;0>:f       r5.0<1;0>:f       r68.0<1>:f       {Compacted,F@2}
(W)     mad (16|M0)              r70.0<1>:f    r72.0<1;0>:f      acc0.0<1;0>:f     -r61.0<1>:f     
(W)     cmp (16|M0)   (ne)f1.1   null<1>:w     r74.0<2;1,0>:ub   0x0:uw              {I@1}
(W)     mad (16|M0)              r70.0<1>:f    acc0.0<1;0>:f     r68.0<1;0>:f      r70.0<1>:f       {F@1}
(W)     add (16|M0)              r40.0<1>:d    r40.0<1;1,0>:d    -r45.0<1;1,0>:d  {Compacted}
(W)     mad (16|M0)              r72.0<1>:f    r72.0<1;0>:f      r70.0<1;0>:f      -r61.0<1>:f      {Compacted,F@1}
(~f1.1.any16h) goto (16|M0)                  L5528                  L5528                
L4960:
(W)     mov (16|M0)              r81.0<1>:ud   r72.0<1;1,0>:ud                  {F@1}
(W)     mov (16|M0)              r77.0<1>:f    r68.0<1;1,0>:f                   {Compacted}
(W)     mov (16|M0)              r79.0<1>:f    r70.0<1;1,0>:f                   {Compacted}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r85.4         L5992                                 {A@1}
L5040:
(W)     add (16|M0)              r64.0<1>:d    r64.0<1;1,0>:d    125:w               {Compacted}
(W)     cmp (16|M0)   (lt)f0.0   null<1>:d     r64.0<1;1,0>:d    -2:w               {Compacted,I@1}
(W)     cmp (16|M0)   (eq)f0.1   null<1>:f     r72.0<1;1,0>:f    0.0:f              
(W)     mov (1|M0)               r1.3<1>:uw    f0.0<0;1,0>:uw                  
(W)     or (1|M0)                f1.0<1>:uw    f0.1<0;1,0>:uw    r1.3<0;1,0>:uw   {I@1}
(f1.0.any16h) goto (16|M0)                   L5168                  L5168                
L5120:
(W)     mov (1|M0)               r1.3<1>:hf    0x1:hf                              {I@2}
(W&f0.1) sel (16|M0)             r75.0<1>:d    r1.3<0;1,0>:w     0:w               {F@1}
        goto (16|M0)                         L5168                  L5288                
L5168:
        join (16|M0)                         L5288                                
L5184:
(W)     mov (1|M0)               r1.3<1>:hf    0x1:hf                              {I@3}
(W)     and (16|M0)              r3.0<1>:d     r81.0<1;1,0>:d    -2139095041:d              
(W)     mov (1|M0)               r2.0<1>:f     0x800000:f                               {Compacted}
(W)     shl (16|M0)              r66.0<1>:d    r66.0<1;1,0>:d    23:w               {Compacted}
(W&f0.1) sel (16|M0)             r75.0<1>:d    r1.3<0;1,0>:w     0:w               {F@2}
(W)     add (16|M0)              r66.0<1>:d    r66.0<1;1,0>:d    1065353216:d               {I@2}
(W)     bfn.0xFE (16|M0)         r3.0<1>:ud    r3.0<1;0>:ud      r75.0<1;0>:ud     r2.0<0>:ud       {A@1} // s0|s1|s2
(W)     mul (16|M0)              r66.0<1>:f    r66.0<1;1,0>:f    r3.0<1;1,0>:f    {Compacted,A@1}
L5288:
        join (16|M0)                         L5528                                
L5304:
(W)     and (16|M0)   (eq)f1.1   null<1>:ud    r81.0<1;1,0>:ud   0x400000:ud             
(W)     shl (16|M0)              r3.0<1>:d     r81.0<1;1,0>:d    1:w               {Compacted,F@1}
(W)     mov (1|M0)               r1.2<1>:f     0x800000:f                               {Compacted}
(W)     mov (1|M0)               r2.0<1>:f     -0.0:f                               {Compacted}
(W)     mov (1|M0)               r2.1<1>:f     1.469368e-38:f                               {Compacted}
(W)     and (16|M0)              r3.0<1>:d     r3.0<1;1,0>:d     8388606:d               {I@1}
(W)     bfn.0xEA (16|M0)         r5.0<1>:ud    r1.2<0;0>:ud      r81.0<1;0>:ud     r2.0<0>:ud       {A@2} // s0|s1&s2
(W&f1.1) sel (16|M0)             r7.0<1>:d     r2.1<0;1,0>:d     12582912:d               {F@1}
(W)     mov (1|M0)               r9.0<1>:f     0.25:f                               {Compacted}
(W)     bfn.0xFE (16|M0)         r75.0<1>:ud   r75.0<1;0>:ud     r5.0<1;0>:ud      r3.0<1>:ud       {I@2} // s0|s1|s2
(W)     bfn.0xEA (16|M0)         r7.0<1>:ud    r7.0<1;0>:ud      r81.0<1;0>:ud     r2.0<0>:ud       {I@2} // s0|s1&s2
(W)     mad (16|M0)              r75.0<1>:f    r7.0<1;0>:f       r75.0<1;0>:f      r9.0<0>:f        {Compacted,A@1}
(W)     add (16|M0)              r75.0<1>:f    r75.0<1;1,0>:f    -r5.0<1;1,0>:f   {Compacted,F@1}
(W)     mul (16|M0)              r5.0<1>:f     r5.0<1;1,0>:f     r5.0<1;1,0>:f    {Compacted}
(W)     bfn.0xAE (16|M0)         r75.0<1>:ud   r75.0<1;0>:ud     r5.0<1;0>:ud      0x1:uw              {A@1} // s0|s1&~s2
(W&~f1.0) mov (16|M0)            r66.0<1>:f    r75.0<1;1,0>:f                   {I@1}
(W)     and (16|M0)   (ne)f1.0   null<1>:w     r74.0<2;1,0>:ub   1:w               {F@1}
(W&f1.0) mov (16|M0)             r37.0<1>:f    r66.0<1;1,0>:f                  
L5528:
        join (16|M0)                         L5784                                
L5544:
(W)     add (16|M0)              r3.0<1>:d     r40.0<1;1,0>:d    -253:w               {Compacted}
(W)     cmp (16|M0)   (lt)f1.1   null<1>:d     r3.0<1;1,0>:ud    0xFFFFFE85:ud              {I@1}
(W)     mov (1|M0)               r1.3<1>:hf    -qnan(0x1FF):hf                             
(W)     asr (16|M0)              r5.0<1>:d     r40.0<1;1,0>:d    11:w               {Compacted}
(W&f1.1.any16h) sel (1|M0)       r2.0<1>:w     r1.3<0;1,0>:w     0:w               {F@1}
(W)     add (16|M0)              r7.0<1>:d     r5.0<1;1,0>:d     248:w               {Compacted,I@2}
(W)     mov (1|M0)               f0.1<1>:uw    r2.0<0;1,0>:uw                   {I@2}
(W)     mov (16|M0)              r9.0<1>:f     r40.0<1;1,0>:f                   {Compacted}
(W&f1.1) xor (16|M0)             r9.0<1>:d     r7.0<1;1,0>:d     r5.0<1;1,0>:d    {A@1}
(W&~f0.1) mov (16|M0)            r9.0<1>:f     r40.0<1;1,0>:f                   {I@1}
(W)     asr (16|M0)              r11.0<1>:d    r9.0<1;1,0>:d     1:w               {Compacted,F@1}
(W)     mov (16|M0)              r3.0<1>:uw    r63.0<1;1,0>:ub                 
(W)     add (16|M0)              r9.0<1>:d     r9.0<1;1,0>:d     -r11.0<1;1,0>:d  {Compacted,I@2}
(W)     mad (16|M0)              r72.0<1>:f    r70.0<1;0>:f      r68.0<1;0>:f      r72.0<1>:f       {Compacted}
(W)     or (16|M0)    (eq)f0.0   null<1>:w     r74.0<2;1,0>:ub   r3.0<1;1,0>:uw   {I@2}
(W)     shl (16|M0)              r11.0<1>:d    r11.0<1;1,0>:d    23:w               {Compacted}
(W)     shl (16|M0)              r9.0<1>:d     r9.0<1;1,0>:d     23:w               {Compacted,I@3}
(W)     add (16|M0)              r11.0<1>:d    r11.0<1;1,0>:d    r72.0<1;1,0>:d   {Compacted,A@1}
(W)     add (16|M0)              r9.0<1>:d     r9.0<1;1,0>:d     1065353216:d               {I@2}
(W&f0.0) mul (16|M0)             r37.0<1>:f    r11.0<1;1,0>:f    r9.0<1;1,0>:f    {A@1}
L5784:
        join (16|M0)                         L5800                                
L5800:
(W)     math.inv (16|M0)         r3.0<1>:f     r35.0<1;1,0>:f                   {$1}
(W)     mov (1|M0)               r1.2<1>:ud    0x3F800000:ud                             
(W)     mul (16|M0)              acc0.0<1>:f   r3.0<1;1,0>:f     r33.0<1;1,0>:f   {Compacted,$1.dst}
(W)     mad (16|M0)              acc2.0<1>:f   r1.2<0;0>:f       r3.0<1;0>:f       -r35.0<1>:f      {I@1}
(W)     mad (16|M0)              r9.0<1>:f     r33.0<1;0>:f      acc0.0<1;0>:f     -r35.0<1>:f     
(W)     mad (16|M0)              acc2.0<1>:f   r3.0<1;0>:f       acc2.0<1;0>:f     r3.0<1>:f        {Compacted}
(W)     mov (1|M0)               f1.1<1>:uw    r86.2<0;1,0>:uw                 
(W)     mad (16|M0)              acc0.0<1>:f   acc0.0<1;0>:f     acc2.0<1;0>:f     r9.0<1>:f        {F@2}
(W)     mad (16|M0)              r33.0<1>:f    r33.0<1;0>:f      acc0.0<1;0>:f     -r35.0<1>:f     
(W&~f1.1) mad (16|M0)            r37.0<1>:f    acc0.0<1;0>:f     acc2.0<1;0>:f     r33.0<1>:f       {F@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        ret (16|M0)                          r85.2                            {A@1}
L5992:
(W)     mov (1|M0)               r1.2<1>:d     cr0.0<0;1,0>:ud                  {A@1}
(W)     and (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   -1265:w               {A@1}
(W)     or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   1264:w               {A@1}
(W)     mad (16|M0)              r81.0<1>:f    r79.0<1;0>:f      r77.0<1;0>:f      r81.0<1>:f       {Compacted,A@1}
(W)     mov (1|M0)               cr0.0<1>:ud   r1.2<0;1,0>:d                    {A@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        ret (16|M0)                          r85.4                            {A@1}
L6112:
        shr (1|M0)               r63.4<1>:ud   r85.1<0;1,0>:ud   0x17:uw             
        shr (1|M0)               r28.7<1>:ud   r85.0<0;1,0>:ud   0x17:uw             
        and (1|M0)               r63.4<1>:ud   r63.4<0;1,0>:ud   0xFF:uw              {I@2}
        and (1|M0)               r28.7<1>:ud   r28.7<0;1,0>:ud   0xFF:uw              {I@2}
        add (1|M0)               r1.3<1>:ud    r63.4<0;1,0>:ud   0xFFFFFF41:ud              {I@2}
        add (1|M0)               r1.2<1>:ud    r28.7<0;1,0>:ud   0xFFFFFF41:ud              {I@2}
        cmp (1|M0)    (lt)f0.0   null<1>:ud    r1.3<0;1,0>:ud    0xFFFFFF81:ud              {I@2}
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                             
(~f0.0) cmp (1|M0)    (lt)f0.0   null<1>:ud    r1.2<0;1,0>:ud    0xFFFFFF82:ud              {I@2}
(f0.0)  sel (1|M0)               r28.24<2>:b   r2.0<0;1,0>:w     0:w               {F@1}
        cmp (1|M0)    (ne)f1.1   null<1>:uw    r28.24<0;1,0>:ub  0x0:uw              {I@1}
(W)     and (1|M0)               f1.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(~f1.1.any16h) goto (16|M0)                  L9728                  L9728                
L6320:
        add (1|M0)               r1.3<1>:ud    r63.4<0;1,0>:ud   0xFFFFFF01:ud             
        add (1|M0)               r1.2<1>:ud    r28.7<0;1,0>:ud   0xFFFFFF01:ud             
        cmp (1|M0)    (lt)f1.1   null<1>:ud    r1.3<0;1,0>:ud    0xFFFFFF02:ud              {I@2}
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                             
        mov (1|M0)               r83.7<1>:f    (abs)r85.0<0;1,0>:f              {Compacted}
(~f1.1) cmp (1|M0)    (lt)f1.1   null<1>:ud    r1.2<0;1,0>:ud    0xFFFFFF02:ud              {I@2}
(f1.1)  sel (1|M0)               r28.26<2>:b   r2.0<0;1,0>:w     0:w               {F@2}
        cmp (1|M0)    (ne)f0.1   null<1>:uw    r28.26<0;1,0>:ub  0x0:uw              {I@1}
(W)     and (1|M0)               f1.0<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(f1.0.any16h) goto (16|M0)                   L6568                  L6568                
L6472:
        mov (1|M0)               r1.2<1>:f     (abs)r85.1<0;1,0>:f             
        mov (1|M0)               r83.6<2>:b    0:w                              
        add (1|M0)               r83.7<1>:d    r83.7<0;1,0>:d    -r1.2<0;1,0>:d   {A@1}
        mov (2|M0)               r84.4<1>:d    r85.0<1;1,0>:ud                 
        asr (1|M0)               r83.7<1>:d    r83.7<0;1,0>:d    23:w               {I@2}
        goto (16|M0)                         L6568                  L8272                
L6568:
        join (16|M0)                         L8272                                
L6584:
        cmp (1|M0)    (gt)f0.0   null<1>:ud    r83.7<0;1,0>:ud   0x7F800000:ud              {I@3}
(W)     mov (1|M0)               r1.3<1>:hf    0xFF:hf                             
        mov (1|M0)               r83.5<1>:f    (abs)r85.1<0;1,0>:f             
(W)     mov (1|M0)               r2.1<1>:hf    -qnan(0x1FF):hf                             
(f0.0)  sel (1|M0)               r2.0<1>:w     r1.3<0;1,0>:w     0:w               {F@3}
        and (1|M0)               r63.6<1>:ud   r85.0<0;1,0>:ud   0x7F800000:ud             
        cmp (1|M0)    (eq)f1.0   null<1>:w     r2.0<0;1,0>:b     0:w               {I@2}
(W)     mov (1|M0)               r3.0<1>:uw    r2.0<0;1,0>:ub                  
        and (1|M0)               r63.7<1>:ud   r85.1<0;1,0>:ud   0x7F800000:ud             
(W)     mov (1|M0)               r5.0<1>:f     -0.0:f                               {Compacted}
(f1.0)  cmp (1|M0)    (gt)f1.0   null<1>:ud    r83.5<0;1,0>:ud   0x7F800000:ud              {F@3}
        bfn.0x6A (1|M0)          r1.2<1>:ud    r85.0<0;0>:ud     r85.1<0;0>:ud     r5.0<0>:ud       {F@1} // s0^s1&s2
        bfn.0x6A (1|M0)          r1.3<1>:ud    r85.1<0;0>:ud     r85.0<0;0>:ud     r5.0<0>:ud       // s0^s1&s2
        add (1|M0)               r86.0<1>:f    r85.0<0;1,0>:f    r85.1<0;1,0>:f   {Compacted}
(f1.0)  sel (1|M0)               r2.4<2>:b     r2.1<0;1,0>:w     0:w              
        and (1|M0)               r4.0<1>:ud    r85.1<0;1,0>:ud   0x80000000:ud             
        and (1|M0)    (ne)f1.0   null<1>:w     r2.4<0;1,0>:ub    1:w               {I@2}
        or (1|M0)     (eq)f0.1   r2.4<2>:ub    r2.4<0;1,0>:ub    r3.0<0;1,0>:uw  
        and (1|M0)               r63.5<1>:ud   r85.0<0;1,0>:ud   0x80000000:ud             
(f1.0)  add (1|M0)               r86.0<1>:f    r85.1<0;1,0>:f    r85.1<0;1,0>:f  
(f0.1)  cmp (1|M0)    (eq)f0.1   null<1>:d     r63.6<0;1,0>:d    2139095040:d              
(W)     mov (1|M0)               r4.2<1>:uw    r2.4<0;1,0>:ub                   {I@3}
(f0.1)  sel (1|M0)               r1.6<2>:b     r2.1<0;1,0>:w     0:w              
        and (1|M0)    (ne)f0.1   null<1>:w     r1.6<0;1,0>:ub    1:w               {I@1}
        or (1|M0)     (eq)f0.0   r1.6<2>:ub    r1.6<0;1,0>:ub    r4.2<0;1,0>:uw  
(f0.1)  add (1|M0)               r86.0<1>:f    r1.2<0;1,0>:f     -r1.3<0;1,0>:f  
(f0.0)  cmp (1|M0)    (eq)f0.0   null<1>:d     r63.7<0;1,0>:d    2139095040:d              
(W)     mov (1|M0)               r3.0<1>:uw    r1.6<0;1,0>:ub                   {I@2}
(f0.0)  sel (1|M0)               r83.2<2>:b    r2.1<0;1,0>:w     0:w              
        and (1|M0)    (ne)f0.0   null<1>:w     r83.2<0;1,0>:ub   1:w               {I@1}
        or (1|M0)     (eq)f1.1   r83.2<2>:ub   r83.2<0;1,0>:ub   r3.0<0;1,0>:uw  
(f0.0)  mul (1|M0)               r86.0<1>:f    r4.0<0;1,0>:f     r85.0<0;1,0>:f  
(f1.1)  cmp (1|M0)    (eq)f1.1   null<1>:f     r85.1<0;1,0>:f    0.0:f               {I@1}
(f1.1)  sel (1|M0)               r83.0<2>:b    r2.1<0;1,0>:w     0:w              
        cmp (1|M0)    (ne)f1.1   null<1>:uw    r83.0<0;1,0>:ub   0x0:uw              {A@1}
(W)     and (1|M0)               f0.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(f0.1.any16h) goto (16|M0)                   L7192                  L7192                
L7160:
        mov (1|M0)               r83.4<2>:b    r83.2<0;1,0>:b                  
        goto (16|M0)                         L7192                  L7376                
L7192:
        join (16|M0)                         L7376                                
L7208:
(W)     mov (1|M0)               r2.0<1>:f     inf:f                               {Compacted}
        cmp (1|M0)    (eq)f1.0   null<1>:f     r85.0<0;1,0>:f    0.0:f              
        bfn.0x96 (1|M0)          r63.5<1>:ud   r63.5<0;0>:ud     r85.1<0;0>:ud     r2.0<0>:ud       {F@2} // s0^s1^s2
        xor (1|M0)               r1.2<1>:ud    r85.1<0;1,0>:ud   0x7F800000:ud             
(W)     mov (1|M0)               r3.0<1>:uw    r83.2<0;1,0>:ub                 
(~f1.0) mov (1|M0)               r1.2<1>:f     r63.5<0;1,0>:f                   {A@2}
        or (1|M0)                r83.2<2>:ub   r83.0<0;1,0>:ub   r3.0<0;1,0>:uw   {I@1}
(f1.0)  mul (1|M0)               r63.5<1>:f    r1.2<0;1,0>:f     r85.0<0;1,0>:f   {F@1}
        and (1|M0)    (ne)f1.0   null<1>:w     r83.0<0;1,0>:ub   1:w               {F@1}
        mov (1|M0)               r83.4<2>:b    r83.2<0;1,0>:b                   {I@2}
(f1.0)  mov (1|M0)               r86.0<1>:f    r63.5<0;1,0>:f                  
L7376:
        join (16|M0)                         L8272                                
L7392:
        cmp (1|M0)    (eq)f1.0   null<1>:w     r83.2<0;1,0>:b    0:w               {F@1}
(W)     mov (1|M0)               r1.3<1>:hf    -qnan(0x1FF):hf                             
(W)     mov (1|M0)               r2.0<1>:uw    r83.4<0;1,0>:ub                  {I@3}
(f1.0)  cmp (1|M0)    (eq)f1.0   null<1>:f     r85.0<0;1,0>:f    0.0:f               {I@2}
(f1.0)  sel (1|M0)               r83.6<2>:b    r1.3<0;1,0>:w     0:w               {F@2}
        and (1|M0)    (ne)f0.1   null<1>:w     r83.6<0;1,0>:ub   1:w               {I@1}
        or (1|M0)     (ne)f0.0   r83.6<2>:ub   r83.6<0;1,0>:ub   r2.0<0;1,0>:uw  
(f0.1)  mul (1|M0)               r86.0<1>:f    r85.0<0;1,0>:f    r85.1<0;1,0>:f  
(W)     and (1|M0)               f0.0<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
(f0.0.any16h) goto (16|M0)                   L8272                  L9728                
L7552:
        cmp (1|M0)    (eq)f1.1   null<1>:uw    r83.6<0;1,0>:ub   0x0:uw              {I@3}
        cmp (1|M0)    (eq)f1.0   null<1>:d     r63.6<0;1,0>:d    0:w               {F@2}
(~f1.1) mov (1|M0)               r28.26<2>:b   0:w                              
(f1.0)  sel (1|M0)               r83.2<1>:d    r28.26<0;1,0>:b   0:w               {I@1}
        cmp (1|M0)    (ne)f0.1   null<1>:d     r83.2<0;1,0>:d    0:w               {A@1}
(W)     and (1|M0)               f1.1<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(f1.1.any16h) goto (16|M0)                   L7704                  L7704                
L7664:
        mov (1|M0)               r83.3<1>:d    0:w                              
        mov (1|M0)               r84.4<1>:f    r85.0<0;1,0>:f                   {Compacted}
        goto (16|M0)                         L7704                  L7856                
L7704:
        join (16|M0)                         L7856                                
L7720:
        and (1|M0)    (ne)f0.1   r83.2<1>:d    r83.2<0;1,0>:d    1:w              
        mov (1|M0)               r84.4<1>:f    r85.0<0;1,0>:f                   {Compacted}
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1E0):hf                             
(f0.1)  mul (1|M0)               r84.4<1>:f    r85.0<0;1,0>:f    0x4F800000:f              
(f0.1)  sel (1|M0)               r83.3<1>:d    r2.0<0;1,0>:w     0:w               {F@2}
        shr (1|M0)               r1.2<1>:ud    r84.4<0;1,0>:ud   0x17:uw              {F@1}
        and (1|M0)               r1.2<1>:ud    r1.2<0;1,0>:ud    0xFF:uw              {I@1}
        add (1|M0)               r1.2<1>:ud    r1.2<0;1,0>:ud    0xFFFFFFE0:ud              {I@1}
(f0.1)  mov (1|M0)               r28.7<1>:d    r1.2<0;1,0>:d                    {I@1}
L7856:
        join (16|M0)                         L8272                                
L7872:
        cmp (1|M0)    (eq)f0.0   null<1>:d     r63.7<0;1,0>:d    0:w              
(f0.0)  sel (1|M0)               r83.4<1>:d    r28.26<0;1,0>:b   0:w              
        cmp (1|M0)    (ne)f1.1   null<1>:d     r83.4<0;1,0>:d    0:w               {I@1}
(W)     and (1|M0)               f1.0<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(f1.0.any16h) goto (16|M0)                   L8000                  L8000                
L7952:
        mov (1|M0)               r83.6<1>:d    0:w                              
        mov (1|M0)               r84.5<1>:d    r85.1<0;1,0>:ud                 
        goto (16|M0)                         L8000                  L8176                
L8000:
        join (16|M0)                         L8176                                
L8016:
        and (1|M0)    (ne)f0.0   r83.4<1>:d    r83.4<0;1,0>:d    1:w              
        mov (1|M0)               r84.5<1>:f    r85.1<0;1,0>:f                   {I@4}
(W)     mov (1|M0)               r2.0<1>:hf    0x20:hf                             
(f0.0)  mul (1|M0)               r84.5<1>:f    r85.1<0;1,0>:f    0x4F800000:f              
(f0.0)  sel (1|M0)               r83.6<1>:d    r2.0<0;1,0>:w     0:w               {F@2}
        shr (1|M0)               r1.2<1>:ud    r84.5<0;1,0>:ud   0x17:uw              {F@1}
        mov (1|M0)               r83.5<1>:f    (abs)r84.5<0;1,0>:f             
        and (1|M0)               r1.2<1>:ud    r1.2<0;1,0>:ud    0xFF:uw              {I@1}
        add (1|M0)               r1.2<1>:ud    r1.2<0;1,0>:ud    0xFFFFFFE0:ud              {I@1}
(f0.0)  mov (1|M0)               r63.4<1>:d    r1.2<0;1,0>:d                    {I@1}
L8176:
        join (16|M0)                         L8272                                
L8192:
        mov (1|M0)               r83.7<1>:f    (abs)r84.4<0;1,0>:f             
        add (1|M0)               r83.6<1>:d    r83.6<0;1,0>:d    r83.3<0;1,0>:d  
        add (1|M0)               r83.7<1>:d    r83.7<0;1,0>:d    -r83.5<0;1,0>:d  {F@1}
        asr (1|M0)               r83.7<1>:d    r83.7<0;1,0>:d    23:w               {I@1}
        add (1|M0)               r83.6<1>:d    r83.6<0;1,0>:d    r83.7<0;1,0>:d   {I@1}
L8272:
        join (16|M0)                         L9728                                
L8288:
        cmp (1|M0)    (eq)f1.0   null<1>:uw    r28.26<0;1,0>:ub  0x0:uw             
(W)     mov (1|M0)               r1.2<1>:f     1.0:f                               {Compacted}
(W)     mov (1|M0)               r2.0<1>:f     0x807FFFFF:f                              
        cmp (1|M0)    (eq)f0.1   null<1>:w     r83.6<0;1,0>:b    0:w              
(~f1.0) mov (1|M0)               r83.7<1>:d    r83.6<0;1,0>:d                   {I@4}
        bfn.0xEA (1|M0)          r84.5<1>:ud   r1.2<0;0>:ud      r84.5<0;0>:ud     r2.0<0>:ud       {A@1} // s0|s1&s2
        add (1|M0)               r84.0<1>:d    r83.7<0;1,0>:d    126:w               {Compacted,I@2}
        add (1|M0)               r84.1<1>:d    -r83.7<0;1,0>:d   -152:w              
        sync.nop                             null                             {Compacted,I@3}
        math.inv (1|M0)          r3.0<1>:f     r84.5<0;1,0>:f                   {$2}
        and (1|M0)               r84.1<1>:d    r84.1<0;1,0>:d    r84.0<0;1,0>:d   {Compacted,I@1}
        mov (1|M0)               r88.0<1>:f    1.0:f                               {Compacted}
        asr (1|M0)               r84.1<1>:d    r84.1<0;1,0>:d    31:w               {Compacted,I@1}
(~f0.1) mov (1|M0)               r84.1<1>:d    0:w                              
        bfn.0xEA (1|M0)          r84.4<1>:ud   r1.2<0;0>:ud      r84.4<0;0>:ud     r2.0<0>:ud       // s0|s1&s2
        cmp (1|M0)    (ne)f0.0   null<1>:d     r84.1<0;1,0>:d    0:w               {I@2}
        sync.nop                             null                             {Compacted,$2.dst}
        mad (1|M0)               r88.0<1>:f    r88.0<0;0>:f      r3.0<0;0>:f       -r84.5<0>:f      {F@1}
        mul (1|M0)               r3.1<1>:f     r3.0<0;1,0>:f     r84.4<0;1,0>:f   {I@2}
        mad (1|M0)               r88.0<1>:f    r3.0<0;0>:f       r3.0<0;0>:f       r88.0<0>:f       {F@2}
        mad (1|M0)               r88.1<1>:f    r84.4<0;0>:f      r3.1<0;0>:f       -r84.5<0>:f      {F@2}
(W)     and (1|M0)               f0.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
        mad (1|M0)               r88.1<1>:f    r3.1<0;0>:f       r88.0<0;0>:f      r88.1<0>:f       {F@1}
        add (1|M0)               r28.7<1>:d    r28.7<0;1,0>:d    -r63.4<0;1,0>:d 
        mad (1|M0)               r84.4<1>:f    r84.4<0;0>:f      r88.1<0;0>:f      -r84.5<0>:f      {F@1}
(~f0.1.any16h) goto (16|M0)                  L9384                  L9384                
L8648:
        mov (1|M0)               r84.3<1>:f    r84.4<0;1,0>:f                   {F@1}
        mov (2|M0)               r87.0<1>:f    r88.0<1;1,0>:f                  
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r85.6         L9960                                 {A@1}
L8728:
        cmp (1|M0)    (eq)f1.0   null<1>:f     r84.4<0;1,0>:f    0.0:f              
(W)     mov (1|M0)               r1.3<1>:hf    0x1:hf                             
        add (1|M0)               r83.7<1>:d    r83.7<0;1,0>:d    125:w              
(W)     mov (1|M0)               r3.0<1>:hf    0x1:hf                             
(f1.0)  sel (1|M0)               r2.0<1>:w     r1.3<0;1,0>:w     0:w               {F@2}
        cmp (1|M0)    (lt)f0.0   null<1>:d     r83.7<0;1,0>:d    -2:w               {I@2}
        cmp (1|M0)    (ne)f0.1   null<1>:w     r2.0<0;1,0>:w     0:w               {I@2}
(W)     mov (1|M0)               r5.0<1>:hf    -qnan(0x1FF):hf                             
(f0.0)  sel (1|M0)               r3.1<1>:uw    r3.0<0;1,0>:uw    0x0:uw              {F@2}
(f0.1)  sel (1|M0)               r4.0<1>:uw    r3.0<0;1,0>:uw    0x0:uw             
        or (1|M0)     (ne)f1.1   null<1>:uw    r3.1<0;1,0>:uw    r4.0<0;1,0>:uw   {I@1}
(f1.1)  sel (1|M0)               r84.8<2>:b    r5.0<0;1,0>:w     0:w               {F@1}
        cmp (1|M0)    (ne)f1.1   null<1>:uw    r84.8<0;1,0>:ub   0x0:uw              {I@1}
(W)     and (1|M0)               f0.0<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(~f0.0.any16h) goto (16|M0)                  L9072                  L9072                
L8968:
(W)     mov (1|M0)               r1.3<1>:hf    0x1:hf                             
        and (1|M0)               r1.2<1>:d     r84.3<0;1,0>:d    -2139095041:d              
(W)     mov (1|M0)               r3.0<1>:f     0x800000:f                               {Compacted}
        shl (1|M0)               r84.0<1>:d    r84.0<0;1,0>:d    23:w               {Compacted}
(f1.0)  sel (1|M0)               r2.0<1>:d     r1.3<0;1,0>:w     0:w               {F@2}
        add (1|M0)               r84.0<1>:d    r84.0<0;1,0>:d    1065353216:d               {I@2}
        bfn.0xFE (1|M0)          r1.2<1>:ud    r1.2<0;0>:ud      r2.0<0;0>:ud      r3.0<0>:ud       {A@1} // s0|s1|s2
        mul (1|M0)               r84.0<1>:f    r84.0<0;1,0>:f    r1.2<0;1,0>:f    {Compacted,A@1}
L9072:
        join (16|M0)                         L9384                                
L9088:
        and (1|M0)               r1.2<1>:d     r84.3<0;1,0>:d    -2147483648:d               {F@1}
        shl (1|M0)               r84.3<1>:d    r84.3<0;1,0>:d    1:w               {Compacted}
(W)     mov (1|M0)               r1.3<1>:hf    0x1:hf                             
        and (1|M0)               r1.3<1>:d     r84.3<0;1,0>:d    8388606:d               {I@1}
        and (1|M0)    (eq)f1.1   r84.3<1>:d    r84.3<0;1,0>:d    8388608:d              
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
        cmp (1|M0)    (eq)f0.1   null<1>:uw    r84.8<0;1,0>:ub   0x0:uw             
        add (1|M0)               r2.0<1>:f     r2.0<0;1,0>:f     -r2.1<0;1,0>:f   {Compacted,A@1}
        mul (1|M0)               r2.1<1>:f     r2.1<0;1,0>:f     r2.1<0;1,0>:f   
        and (1|M0)    (ne)f0.0   null<1>:d     r84.1<0;1,0>:d    1:w              
        and (1|M0)               r2.1<1>:d     r2.1<0;1,0>:d     -2:w               {Compacted,F@1}
        or (1|M0)                r2.1<1>:d     r2.1<0;1,0>:d     r2.0<0;1,0>:d    {Compacted,I@1}
(~f0.1) mov (1|M0)               r2.1<1>:f     r84.0<0;1,0>:f                   {I@1}
(f0.0)  mov (1|M0)               r86.0<1>:f    r2.1<0;1,0>:f                    {F@1}
L9384:
        join (16|M0)                         L9728                                
L9400:
        add (1|M0)               r2.0<1>:d     r28.7<0;1,0>:d    126:w               {Compacted}
(W)     mov (1|M0)               r1.3<1>:uw    r84.4<0;1,0>:ub                 
        cmp (1|M0)    (gt)f0.0   null<1>:ud    r2.0<0;1,0>:ud    0x17A:uw              {A@1}
        mad (1|M0)               r84.4<1>:f    r88.1<0;0>:f      r88.0<0;0>:f      r84.4<0>:f      
        or (1|M0)                r84.5<1>:w    r83.6<0;1,0>:ub   r1.3<0;1,0>:uw   {I@2}
(W)     and (1|M0)               f1.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
(~f1.1.any16h) goto (16|M0)                  L9584                  L9584                
L9504:
(f0.0)  sel (1|M0)               r1.2<1>:d     r28.7<0;1,0>:d    0:w              
        asr (1|M0)               r1.2<1>:d     r1.2<0;1,0>:d     11:w               {I@1}
        add (1|M0)               r1.3<1>:d     r1.2<0;1,0>:d     248:w               {I@1}
        xor (1|M0)               r1.3<1>:d     r1.3<0;1,0>:d     r1.2<0;1,0>:d    {I@1}
(f0.0)  mov (1|M0)               r28.7<1>:d    r1.3<0;1,0>:d                    {I@1}
L9584:
        join (16|M0)                         L9728                                
L9600:
        asr (1|M0)               r1.2<1>:d     r28.7<0;1,0>:d    1:w               {I@2}
        cmp (1|M0)    (eq)f1.1   null<1>:w     r84.5<0;1,0>:w    0:w              
        add (1|M0)               r28.7<1>:d    r28.7<0;1,0>:d    -r1.2<0;1,0>:d   {I@2}
        shl (1|M0)               r1.2<1>:d     r1.2<0;1,0>:d     23:w              
        shl (1|M0)               r28.7<1>:d    r28.7<0;1,0>:d    23:w               {I@2}
        add (1|M0)               r1.2<1>:d     r1.2<0;1,0>:d     r84.4<0;1,0>:d   {A@1}
        add (1|M0)               r28.7<1>:d    r28.7<0;1,0>:d    1065353216:d               {I@2}
(f1.1)  mul (1|M0)               r86.0<1>:f    r28.7<0;1,0>:f    r1.2<0;1,0>:f    {I@1}
L9728:
        join (16|M0)                         L9744                                
L9744:
        sync.nop                             null                             {Compacted,F@1}
        math.inv (1|M0)          r1.2<1>:f     r85.1<0;1,0>:f                   {$3}
        mov (1|M0)               r1.4<1>:ud    0x3F800000:ud                             
        mul (1|M0)               r1.3<1>:f     r1.2<0;1,0>:f     r85.0<0;1,0>:f   {$3.dst}
        mad (1|M0)               r1.4<1>:f     r1.4<0;0>:f       r1.2<0;0>:f       -r85.1<0>:f      {I@1}
        mad (1|M0)               r2.0<1>:f     r85.0<0;0>:f      r1.3<0;0>:f       -r85.1<0>:f      {F@2}
        mad (1|M0)               r1.4<1>:f     r1.2<0;0>:f       r1.2<0;0>:f       r1.4<0>:f        {F@2}
        cmp (1|M0)    (eq)f1.0   null<1>:uw    r28.24<0;1,0>:ub  0x0:uw             
        mad (1|M0)               r2.0<1>:f     r1.3<0;0>:f       r1.4<0;0>:f       r2.0<0>:f        {F@1}
        mad (1|M0)               r85.0<1>:f    r85.0<0;0>:f      r2.0<0;0>:f       -r85.1<0>:f      {F@1}
(f1.0)  mad (1|M0)               r86.0<1>:f    r2.0<0;0>:f       r1.4<0;0>:f       r85.0<0>:f       {F@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        ret (16|M0)                          r84.6                            {A@1}
L9960:
        mov (1|M0)               r1.2<1>:d     cr0.0<0;1,0>:ud                  {A@1}
        and (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   -1265:w               {A@1}
        or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   1264:w               {A@1}
        mad (1|M0)               r84.3<1>:f    r87.1<0;0>:f      r87.0<0;0>:f      r84.3<0>:f       {A@1}
        mov (1|M0)               cr0.0<1>:ud   r1.2<0;1,0>:d                    {A@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        ret (16|M0)                          r85.6                            {A@1}
L10088:
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
