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
        sync.nop                             null                             {Compacted,$1.dst}
        mul (1|M0)               acc0.0<1>:ud  r2.3<0;1,0>:ud    r0.2<0;1,0>:uw   {A@1}
        mach (1|M0)              r6.0<1>:ud    r2.3<0;1,0>:ud    r0.1<0;1,0>:ud   {AccWrEn}
        mov (1|M0)               r1.2<1>:d     r1.0<0;1,0>:uw                   {$0.dst}
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
(W)     mov (1|M0)               r1.3<1>:hf    0x1:hf                             
        addc (1|M0)              r7.0<1>:ud    r5.0<0;1,0>:ud    r1.2<0;1,0>:ud   {AccWrEn,I@1}
        mov (1|M0)               r39.2<1>:d    r7.0<0;1,0>:d                    {I@1}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        cmp (1|M0)    (lt)f0.1   null<1>:ud    r39.2<0;1,0>:ud   r3.0<0;1,0>:ud   {I@2}
        add3 (1|M0)              r39.3<1>:d    r8.0<0;0>:d       r6.0<0;0>:d       0:w               {I@2}
        mul (1|M0)               acc0.0<1>:ud  r2.0<0;1,0>:ud    r2.6<0;1,0>:uw  
        cmp (1|M0)    (lt)f1.1   null<1>:ud    r39.3<0;1,0>:ud   r3.1<0;1,0>:ud   {I@2}
(f0.1)  cmp (1|M0)    (eq)f0.1   null<1>:d     r39.3<0;1,0>:d    r3.1<0;1,0>:d   
        mach (1|M0)              r10.0<1>:ud   r2.0<0;1,0>:ud    r2.3<0;1,0>:ud   {AccWrEn}
(f1.1)  sel (1|M0)               r2.12<1>:uw   r1.3<0;1,0>:uw    0x0:uw              {F@1}
(f0.1)  sel (1|M0)               r1.4<1>:uw    r1.3<0;1,0>:uw    0x0:uw             
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        or (1|M0)     (ne)f0.0   null<1>:uw    r1.4<0;1,0>:uw    r2.12<0;1,0>:uw  {I@2}
        mov (1|M0)               r34.1<1>:d    r10.0<0;1,0>:d                  
        mov (1|M0)               r34.0<1>:f    r9.0<0;1,0>:f                    {Compacted,I@3}
(W)     and (1|M0)               f1.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
(~f1.1.any16h) goto (16|M0)                  L7080                  L7080                
L576:
        mov (4|M0)               r5.0<1>:w     0x64206420:v                              
        cmp (1|M0)    (eq)f0.0   null<1>:d     r4.3<0;1,0>:d     0:w               {$2.dst}
        mov (4|M0)               r6.0<4>:uw    r5.0<1;1,0>:uw                   {I@2}
        mov (2|M0)               r39.4<1>:d    0x100:v                              
        mov (4|M0)               r35.0<2>:d    r6.0<4;1,0>:w                    {I@2}
        mov (2|M0)               r39.0<1>:d    0x1:v                              
        asr (4|M0)               r35.1<2>:d    r35.0<2;1,0>:d    31:w               {I@2}
        mul (2|M0)               r39.4<1>:d    r39.4<1;1,0>:d    4127:w              
        mov (4|M0)               r7.0<2>:ud    r35.0<2;1,0>:ud                  {I@2}
        mov (4|M0)               r7.1<2>:ud    r35.1<2;1,0>:ud                 
        sel (1|M0)    (ge)f0.0   r34.2<1>:ud   r4.4<0;1,0>:ud    0x1:uw             
        addc (4|M0)              r8.0<1>:ud    r7.0<2;1,0>:ud    0x8:ud              {AccWrEn,I@2}
        mov (1|M0)               r34.3<1>:f    0x3D380000:f                              
        mov (4|M0)               r9.0<1>:ud    acc0.0<1;1,0>:ud                 {F@2}
        addc (4|M0)              r10.0<1>:ud   r7.0<2;1,0>:ud    0x10:ud              {AccWrEn}
        mov (1|M0)               r34.4<1>:f    0x3FA68000:f                              
        mov (4|M0)               r11.0<1>:ud   acc0.0<1;1,0>:ud                
        addc (4|M0)              r5.0<1>:ud    r7.0<2;1,0>:ud    0x18:ud              {AccWrEn}
(f0.0)  cmp (1|M0)    (eq)f0.0   null<1>:d     r4.2<0;1,0>:d     0:w              
        mov (4|M0)               r6.0<1>:ud    acc0.0<1;1,0>:ud                
        mul (2|M0)               r40.0<1>:d    r39.0<1;1,0>:d    24:w              
        mul (2|M0)               r34.5<1>:d    r39.0<1;1,0>:d    112:w              
        add (2|M0)               r39.4<1>:d    r39.4<1;1,0>:d    -4096:w              
        mov (4|M0)               r36.0<2>:d    r8.0<1;1,0>:d                    {I@7}
        mov (4|M0)               r37.0<2>:d    r10.0<1;1,0>:d                   {I@7}
        mov (4|M0)               r38.0<2>:d    r5.0<1;1,0>:d                    {I@7}
        add3 (4|M0)              r36.1<2>:d    r9.0<1;0>:d       r7.1<4;2>:d       0:w              
        add3 (4|M0)              r37.1<2>:d    r11.0<1;0>:d      r7.1<4;2>:d       0:w              
        add3 (4|M0)              r38.1<2>:d    r6.0<1;0>:d       r7.1<4;2>:d       0:w               {I@7}
L1040:
        shl (1|M0)               r1.2<1>:d     r39.3<0;1,0>:d    6:w              
        shr (1|M0)               r1.3<1>:ud    r39.2<0;1,0>:ud   0x1A:uw             
        shl (1|M0)               r39.6<1>:d    r39.2<0;1,0>:d    6:w              
        or (1|M0)                r39.7<1>:d    r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        shl (1|M0)               r3.2<1>:d     r39.6<0;1,0>:d    2:w               {I@2}
(W)     and (1|M0)               f1.0<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
        shr (1|M0)               r2.7<1>:ud    r39.6<0;1,0>:ud   0x1E:uw             
        shl (1|M0)               r2.6<1>:d     r39.7<0;1,0>:d    2:w               {I@4}
        addc (1|M0)              r5.0<1>:ud    r4.0<0;1,0>:ud    r3.2<0;1,0>:ud   {AccWrEn,I@4}
        or (1|M0)                r3.3<1>:d     r2.6<0;1,0>:d     r2.7<0;1,0>:d    {I@2}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r41.0<1>:f    r5.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r41.1<1>:d    r6.0<0;0>:d       r4.1<0;0>:d       r3.3<0>:d        {I@1}
(f1.0.any16h) goto (16|M0)                   L1600                  L1600                
L1248:
        shr (1|M0)               r41.5<1>:ud   r39.2<0;1,0>:ud   0x6:uw             
        mov (1|M0)               r34.7<1>:d    r34.2<0;1,0>:d                  
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r40.6         L7152                                 {A@1}
L1328:
        shr (1|M0)               r1.2<1>:ud    r40.4<0;1,0>:ud   0x14:uw             
        shl (1|M0)               r5.0<1>:d     r40.4<0;1,0>:d    12:w               {Compacted,F@1}
        mul (2|M0)               r6.0<1>:d     r39.0<1;1,0>:d    4032:w              
        or (1|M0)                r5.1<1>:d     r1.2<0;1,0>:d     0:w               {I@3}
        bfn.0xEA (2|M0)          r5.0<1>:ud    r5.0<1;0>:ud      r39.6<1;0>:ud     r6.0<1>:ud       {I@1} // s0|s1&s2
        shl (1|M0)               r3.2<1>:d     r5.0<0;1,0>:d     2:w               {Compacted,I@1}
        shl (1|M0)               r2.6<1>:d     r5.1<0;1,0>:d     2:w              
        addc (1|M0)              r7.0<1>:ud    r4.2<0;1,0>:ud    r3.2<0;1,0>:ud   {AccWrEn,I@2}
        shr (1|M0)               r2.7<1>:ud    r5.0<0;1,0>:ud    0x1E:uw             
        mov (1|M0)               r9.0<1>:f     r7.0<0;1,0>:f                    {Compacted,I@2}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        or (1|M0)                r3.3<1>:d     r2.6<0;1,0>:d     r2.7<0;1,0>:d    {I@2}
        addc (1|M0)              r10.0<1>:ud   r9.0<0;1,0>:ud    0x80:ud              {AccWrEn,F@1}
        add3 (1|M0)              r9.1<1>:d     r8.0<0;0>:d       r4.3<0;0>:d       r3.3<0>:d        {I@2}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r11.0<1>:f    r10.0<0;1,0>:f                   {Compacted,I@3}
        add3 (1|M0)              r11.1<1>:d    r6.0<0;0>:d       r9.1<0;0>:d       0:w               {I@1}
        send.ugm (1|M0)          r46      r9      null:0  0x0            0x0240E580           {$4} // wr:1+0, rd:4; load.ugm.d32x32t.a64
        send.ugm (1|M0)          r42      r11     null:0  0x0            0x0240E580           {A@1,$5} // wr:1+0, rd:4; load.ugm.d32x32t.a64
        goto (16|M0)                         L1600                  L1664                
L1600:
        join (16|M0)                         L1664                                
L1616:
        mov (16|M0)              r42.0<1>:ud   0x0:ud                              {$5.dst}
        mov (16|M0)              r44.0<1>:ud   0x0:ud                             
        mov (16|M0)              r46.0<1>:f    0.0:f                               {Compacted,$4.dst}
        mov (16|M0)              r48.0<1>:f    0.0:f                               {Compacted}
L1664:
        join (16|M0)                         L7080                                
L1680:
        send.ugm (1|M0)          r5       r41     null:0  0x0            0x0240E580           {$6} // wr:1+0, rd:4; load.ugm.d32x32t.a64
        addc (1|M0)              r9.0<1>:ud    r41.0<0;1,0>:ud   0x80:ud              {AccWrEn,$4.src}
        shl (1|M0)               r1.3<1>:d     r39.3<0;1,0>:d    29:w               {Compacted}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        sync.nop                             null                             {Compacted,$5.src}
        mov (1|M0)               r11.0<1>:f    r9.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r11.1<1>:d    r10.0<0;0>:d      r41.1<0;0>:d      0:w               {I@1}
        shr (1|M0)               r4.5<1>:ud    r39.2<0;1,0>:ud   0x1:uw             
        sync.nop                             null                             {Compacted,$3.src}
        send.ugm (1|M0)          r12      r11     null:0  0x0            0x0240E580           {A@1,$7} // wr:1+0, rd:4; load.ugm.d32x32t.a64
        and (2|M0)               r39.6<1>:d    r39.6<1;1,0>:d    r39.4<1;1,0>:d  
        shl (1|M0)               r1.4<1>:d     r39.3<0;1,0>:d    4:w              
        shr (1|M0)               r1.5<1>:ud    r39.2<0;1,0>:ud   0x1C:uw             
        shl (1|M0)               r1.6<1>:d     r39.2<0;1,0>:d    4:w              
        shr (1|M0)               r2.7<1>:ud    r39.6<0;1,0>:ud   0x1F:uw              {I@4}
        or (1|M0)                r1.7<1>:d     r1.4<0;1,0>:d     r1.5<0;1,0>:d    {I@3}
(W)     mov (1|M0)               r1.3<1>:hf    0x1:hf                             
        and (2|M0)               r1.6<1>:d     r1.6<1;1,0>:d     r34.5<1;1,0>:d   {I@1}
        sync.nop                             null                             {Compacted,$6.dst}
        add (16|M0)              r18.0<1>:f    r48.0<1;1,0>:f    r7.0<1;1,0>:f    {Compacted,$4.dst}
        add (16|M0)              r16.0<1>:f    r46.0<1;1,0>:f    r5.0<1;1,0>:f    {Compacted}
        mov (8|M0)               r21.0<1>:hf   r18.0<1;1,0>:f                   {F@2}
        mov (8|M0)               r21.8<1>:hf   r19.0<1;1,0>:f                  
        mov (8|M0)               r20.0<1>:hf   r16.0<1;1,0>:f                   {F@3}
        mov (8|M0)               r20.8<1>:hf   r17.0<1;1,0>:f                  
        mov (8|M0)               r24.0<1>:f    r21.0<1;1,0>:hf                  {F@4}
        mov (8|M0)               r25.0<1>:f    r21.8<1;1,0>:hf                  {F@4}
        mov (8|M0)               r22.0<1>:f    r20.0<1;1,0>:hf                  {F@4}
        mov (8|M0)               r23.0<1>:f    r20.8<1;1,0>:hf                  {F@4}
        mad (16|M0)              r24.0<1>:f    r34.4<0;0>:f      r24.0<1;0>:f      r34.3<0>:f       {F@3}
        sync.nop                             null                             {Compacted,$7.dst}
        add (16|M0)              r9.0<1>:f     r42.0<1;1,0>:f    r12.0<1;1,0>:f   {Compacted,$5.dst}
        add (16|M0)              r26.0<1>:f    r44.0<1;1,0>:f    r14.0<1;1,0>:f   {Compacted}
        mad (16|M0)              r22.0<1>:f    r34.4<0;0>:f      r22.0<1;0>:f      r34.3<0>:f       {F@4}
        mov (8|M0)               r12.0<1>:hf   r24.0<1;1,0>:f                   {F@4}
        mov (8|M0)               r12.8<1>:hf   r25.0<1;1,0>:f                  
        mov (8|M0)               r11.0<1>:hf   r9.0<1;1,0>:f                    {F@5}
        mov (8|M0)               r11.8<1>:hf   r10.0<1;1,0>:f                  
        mov (8|M0)               r5.0<1>:hf    r26.0<1;1,0>:f                   {F@6}
        mov (8|M0)               r5.8<1>:hf    r27.0<1;1,0>:f                  
        mov (8|M0)               r8.0<1>:hf    r22.0<1;1,0>:f                   {F@7}
        mov (8|M0)               r8.8<1>:hf    r23.0<1;1,0>:f                  
        mov (8|M0)               r13.0<1>:f    r12.0<1;1,0>:hf                  {F@7}
        mov (8|M0)               r14.0<1>:f    r12.8<1;1,0>:hf                  {F@7}
        mov (8|M0)               r6.0<1>:f     r11.0<1;1,0>:hf                  {F@7}
        mov (8|M0)               r7.0<1>:f     r11.8<1;1,0>:hf                  {F@7}
        mov (8|M0)               r16.0<1>:f    r5.0<1;1,0>:hf                   {F@7}
        mov (8|M0)               r17.0<1>:f    r5.8<1;1,0>:hf                   {F@7}
        mov (8|M0)               r9.0<1>:f     r8.0<1;1,0>:hf                   {F@7}
        mov (8|M0)               r10.0<1>:f    r8.8<1;1,0>:hf                   {F@7}
        sel (16|M0)   (ge)f0.0   acc0.0<1>:f   r13.0<1;1,0>:f    1.03125:f               {F@7}
        mad (16|M0)              r6.0<1>:f     r34.4<0;0>:f      r6.0<1;0>:f       r34.3<0>:f       {F@6}
        mad (16|M0)              r16.0<1>:f    r34.4<0;0>:f      r16.0<1;0>:f      r34.3<0>:f       {F@5}
        sel (16|M0)   (ge)f0.0   acc2.0<1>:f   r9.0<1;1,0>:f     1.03125:f               {F@4}
        sel (16|M0)   (lt)f0.0   r13.0<1>:f    acc0.0<1;1,0>:f   0x3FC8E000:f              
        mov (8|M0)               r5.8<1>:hf    r7.0<1;1,0>:f                    {F@4}
        mov (8|M0)               r11.0<1>:hf   r16.0<1;1,0>:f                   {F@4}
        mov (8|M0)               r11.8<1>:hf   r17.0<1;1,0>:f                  
        sel (16|M0)   (lt)f0.0   r9.0<1>:f     acc2.0<1;1,0>:f   0x3FC8E000:f              
        mov (8|M0)               r15.0<1>:ud   r13.1<2;1,0>:ud                  {F@5}
        mov (8|M0)               r7.0<1>:ud    r13.0<2;1,0>:ud                  {F@4}
        mov (8|M0)               r5.0<1>:hf    r6.0<1;1,0>:f                   
        mov (8|M0)               r20.0<1>:f    r11.0<1;1,0>:hf                  {F@4}
        mov (8|M0)               r21.0<1>:f    r11.8<1;1,0>:hf                  {F@4}
        mov (8|M0)               r16.0<2>:hf   r15.0<1;1,0>:f                   {I@2}
        mov (8|M0)               r6.0<1>:ud    r9.0<2;1,0>:ud                   {A@4}
        mov (8|M0)               r8.0<2>:hf    r7.0<1;1,0>:f                    {I@2}
        mov (8|M0)               r11.0<1>:ud   r9.1<2;1,0>:ud                   {A@3}
        mov (8|M0)               r19.0<1>:f    r5.8<1;1,0>:hf                  
        mov (8|M0)               r18.0<1>:f    r5.0<1;1,0>:hf                  
        mov (8|M0)               r12.8<1>:uw   r16.0<2;1,0>:uw                  {F@4}
        mov (8|M0)               r5.8<1>:uw    r8.0<2;1,0>:uw                   {A@2}
        mov (8|M0)               r12.0<1>:hf   r11.0<1;1,0>:f                   {I@3}
        mov (8|M0)               r5.0<1>:hf    r6.0<1;1,0>:f                   
        mov (16|M0)              r24.0<1>:d    r12.0<1;1,0>:uw                  {A@2}
        shl (16|M0)              r7.0<1>:d     r5.0<1;1,0>:uw    5:w               {A@1}
        shl (16|M0)              r24.0<1>:d    r24.0<1;1,0>:d    21:w               {Compacted,I@2}
        add (16|M0)              r7.0<1>:d     r7.0<1;1,0>:d     2146992128:d               {I@2}
        add (16|M0)              r7.0<1>:d     r7.0<1;1,0>:d     r24.0<1;1,0>:d   {Compacted,I@1}
        mov (8|M0)               r13.0<1>:f    r7.0<1;1,0>:hf                   {I@1}
        mov (8|M0)               r14.0<1>:f    r7.8<1;1,0>:hf                  
        add (1|M0)               r1.2<1>:f     r13.0<0;1,0>:f    r13.1<0;1,0>:f   {F@2}
        mov (8|M0)               r15.0<1>:f    r8.0<1;1,0>:hf                  
        add (1|M0)               r1.2<1>:f     r1.2<0;1,0>:f     r13.2<0;1,0>:f   {F@2}
        sel (16|M0)   (ge)f0.0   acc0.0<1>:f   r20.0<1;1,0>:f    1.03125:f              
        add (1|M0)               r1.2<1>:f     r1.2<0;1,0>:f     r13.3<0;1,0>:f   {F@2}
        mov (8|M0)               r16.0<1>:f    r8.8<1;1,0>:hf                  
        add (1|M0)               r1.2<1>:f     r1.2<0;1,0>:f     r13.4<0;1,0>:f   {F@2}
        sel (16|M0)   (ge)f0.0   acc2.0<1>:f   r18.0<1;1,0>:f    1.03125:f              
        add (1|M0)               r1.2<1>:f     r1.2<0;1,0>:f     r13.5<0;1,0>:f   {F@2}
        sel (16|M0)   (lt)f0.0   r20.0<1>:f    acc0.0<1;1,0>:f   0x3FC8E000:f              
        add (1|M0)               r1.2<1>:f     r1.2<0;1,0>:f     r13.6<0;1,0>:f   {F@2}
        sel (16|M0)   (lt)f0.0   r18.0<1>:f    acc2.0<1;1,0>:f   0x3FC8E000:f              
        add (1|M0)               r1.2<1>:f     r1.2<0;1,0>:f     r13.7<0;1,0>:f   {F@2}
        mov (8|M0)               r23.0<1>:ud   r20.0<2;1,0>:ud                 
        add (1|M0)               r1.2<1>:f     r1.2<0;1,0>:f     r14.0<0;1,0>:f   {F@1}
        mov (8|M0)               r7.0<1>:ud    r20.1<2;1,0>:ud                 
        add (1|M0)               r1.2<1>:f     r1.2<0;1,0>:f     r14.1<0;1,0>:f   {F@1}
        mov (8|M0)               r17.0<1>:ud   r18.0<2;1,0>:ud                 
        add (1|M0)               r1.2<1>:f     r1.2<0;1,0>:f     r14.2<0;1,0>:f   {F@1}
        mov (8|M0)               r5.0<1>:ud    r18.1<2;1,0>:ud                 
        add (1|M0)               r1.2<1>:f     r1.2<0;1,0>:f     r14.3<0;1,0>:f   {F@1}
        mov (8|M0)               r6.0<2>:hf    r23.0<1;1,0>:f                   {I@4}
        add (1|M0)               r1.2<1>:f     r1.2<0;1,0>:f     r14.4<0;1,0>:f   {F@2}
        mov (8|M0)               r8.0<2>:hf    r7.0<1;1,0>:f                    {I@3}
        add (1|M0)               r1.2<1>:f     r1.2<0;1,0>:f     r14.5<0;1,0>:f   {F@2}
        mov (8|M0)               r22.0<1>:hf   r17.0<1;1,0>:f                   {I@2}
        add (1|M0)               r1.2<1>:f     r1.2<0;1,0>:f     r14.6<0;1,0>:f   {F@2}
        mov (8|M0)               r22.8<1>:uw   r6.0<2;1,0>:uw                  
        add (1|M0)               r1.2<1>:f     r1.2<0;1,0>:f     r14.7<0;1,0>:f   {F@1}
        mov (8|M0)               r6.0<1>:hf    r5.0<1;1,0>:f                    {A@1}
        add (1|M0)               r1.2<1>:f     r1.2<0;1,0>:f     r15.0<0;1,0>:f   {F@2}
        mov (8|M0)               r6.8<1>:uw    r8.0<2;1,0>:uw                  
        add (1|M0)               r1.2<1>:f     r1.2<0;1,0>:f     r15.1<0;1,0>:f   {F@1}
        shl (16|M0)              r9.0<1>:d     r22.0<1;1,0>:uw   5:w              
        add (1|M0)               r1.2<1>:f     r1.2<0;1,0>:f     r15.2<0;1,0>:f   {F@1}
        mov (16|M0)              r11.0<1>:d    r6.0<1;1,0>:uw                   {I@2}
        add (1|M0)               r1.2<1>:f     r1.2<0;1,0>:f     r15.3<0;1,0>:f   {F@1}
        add (16|M0)              r9.0<1>:d     r9.0<1;1,0>:d     2146992128:d               {I@2}
        add (1|M0)               r1.2<1>:f     r1.2<0;1,0>:f     r15.4<0;1,0>:f   {F@1}
        shl (16|M0)              r11.0<1>:d    r11.0<1;1,0>:d    21:w               {Compacted,I@2}
        add (1|M0)               r1.2<1>:f     r1.2<0;1,0>:f     r15.5<0;1,0>:f   {F@1}
        add (16|M0)              r9.0<1>:d     r9.0<1;1,0>:d     r11.0<1;1,0>:d   {Compacted,I@1}
        add (1|M0)               r1.2<1>:f     r1.2<0;1,0>:f     r15.6<0;1,0>:f   {F@1}
        mov (8|M0)               r22.0<1>:f    r9.0<1;1,0>:hf                   {I@1}
        add (1|M0)               r1.2<1>:f     r1.2<0;1,0>:f     r15.7<0;1,0>:f   {F@2}
        mov (8|M0)               r23.0<1>:f    r9.8<1;1,0>:hf                  
        add (1|M0)               r1.2<1>:f     r1.2<0;1,0>:f     r16.0<0;1,0>:f   {F@2}
        mov (8|M0)               r24.0<1>:f    r10.0<1;1,0>:hf                 
        add (1|M0)               r1.2<1>:f     r1.2<0;1,0>:f     r16.1<0;1,0>:f   {F@2}
        mov (8|M0)               r25.0<1>:f    r10.8<1;1,0>:hf                 
        add (1|M0)               r1.2<1>:f     r1.2<0;1,0>:f     r16.2<0;1,0>:f   {F@2}
        add (1|M0)               r1.2<1>:f     r1.2<0;1,0>:f     r16.3<0;1,0>:f   {F@1}
        add (1|M0)               r1.2<1>:f     r1.2<0;1,0>:f     r16.4<0;1,0>:f   {F@1}
        add (1|M0)               r1.2<1>:f     r1.2<0;1,0>:f     r16.5<0;1,0>:f   {F@1}
        add (1|M0)               r1.2<1>:f     r1.2<0;1,0>:f     r16.6<0;1,0>:f   {F@1}
        add (1|M0)               r1.2<1>:f     r1.2<0;1,0>:f     r16.7<0;1,0>:f   {F@1}
        add (1|M0)               r1.2<1>:f     r1.2<0;1,0>:f     r22.0<0;1,0>:f   {F@1}
        add (1|M0)               r1.2<1>:f     r1.2<0;1,0>:f     r22.1<0;1,0>:f   {F@1}
        add (1|M0)               r1.2<1>:f     r1.2<0;1,0>:f     r22.2<0;1,0>:f   {F@1}
        add (1|M0)               r1.2<1>:f     r1.2<0;1,0>:f     r22.3<0;1,0>:f   {F@1}
        add (1|M0)               r1.2<1>:f     r1.2<0;1,0>:f     r22.4<0;1,0>:f   {F@1}
        add (1|M0)               r1.2<1>:f     r1.2<0;1,0>:f     r22.5<0;1,0>:f   {F@1}
        add (1|M0)               r1.2<1>:f     r1.2<0;1,0>:f     r22.6<0;1,0>:f   {F@1}
        add (1|M0)               r1.2<1>:f     r1.2<0;1,0>:f     r22.7<0;1,0>:f   {F@1}
        add (1|M0)               r1.2<1>:f     r1.2<0;1,0>:f     r23.0<0;1,0>:f   {F@1}
        add (1|M0)               r1.2<1>:f     r1.2<0;1,0>:f     r23.1<0;1,0>:f   {F@1}
        add (1|M0)               r1.2<1>:f     r1.2<0;1,0>:f     r23.2<0;1,0>:f   {F@1}
        add (1|M0)               r1.2<1>:f     r1.2<0;1,0>:f     r23.3<0;1,0>:f   {F@1}
        add (1|M0)               r1.2<1>:f     r1.2<0;1,0>:f     r23.4<0;1,0>:f   {F@1}
        add (1|M0)               r1.2<1>:f     r1.2<0;1,0>:f     r23.5<0;1,0>:f   {F@1}
        add (1|M0)               r1.2<1>:f     r1.2<0;1,0>:f     r23.6<0;1,0>:f   {F@1}
        add (1|M0)               r1.2<1>:f     r1.2<0;1,0>:f     r23.7<0;1,0>:f   {F@1}
        add (1|M0)               r1.2<1>:f     r1.2<0;1,0>:f     r24.0<0;1,0>:f   {F@1}
        add (1|M0)               r1.2<1>:f     r1.2<0;1,0>:f     r24.1<0;1,0>:f   {F@1}
        add (1|M0)               r1.2<1>:f     r1.2<0;1,0>:f     r24.2<0;1,0>:f   {F@1}
        add (1|M0)               r1.2<1>:f     r1.2<0;1,0>:f     r24.3<0;1,0>:f   {F@1}
        add (1|M0)               r1.2<1>:f     r1.2<0;1,0>:f     r24.4<0;1,0>:f   {F@1}
        add (1|M0)               r1.2<1>:f     r1.2<0;1,0>:f     r24.5<0;1,0>:f   {F@1}
        add (1|M0)               r1.2<1>:f     r1.2<0;1,0>:f     r24.6<0;1,0>:f   {F@1}
        add (1|M0)               r1.2<1>:f     r1.2<0;1,0>:f     r24.7<0;1,0>:f   {F@1}
        add (1|M0)               r1.2<1>:f     r1.2<0;1,0>:f     r25.0<0;1,0>:f   {F@1}
        add (1|M0)               r1.2<1>:f     r1.2<0;1,0>:f     r25.1<0;1,0>:f   {F@1}
        add (1|M0)               r1.2<1>:f     r1.2<0;1,0>:f     r25.2<0;1,0>:f   {F@1}
        add (1|M0)               r1.2<1>:f     r1.2<0;1,0>:f     r25.3<0;1,0>:f   {F@1}
        add (1|M0)               r1.2<1>:f     r1.2<0;1,0>:f     r25.4<0;1,0>:f   {F@1}
        add (1|M0)               r1.2<1>:f     r1.2<0;1,0>:f     r25.5<0;1,0>:f   {F@1}
        add (1|M0)               r1.2<1>:f     r1.2<0;1,0>:f     r25.6<0;1,0>:f   {F@1}
        add (1|M0)               r1.2<1>:f     r1.2<0;1,0>:f     r25.7<0;1,0>:f   {F@1}
        mov (1|M0)               r2.12<2>:hf   r1.2<0;1,0>:f                    {F@1}
        shr (1|M0)               r1.2<1>:ud    r39.2<0;1,0>:ud   0x3:uw              {F@1}
        math.inv (8|M0)          r5.0<1>:hf    r2.12<0;1,0>:hf                  {$8}
        mov (1|M0)               r2.12<1>:hf   r5.0<0;1,0>:hf                   {$8.dst}
        mov (1|M0)               r3.2<1>:f     r2.12<0;1,0>:hf                  {F@1}
        shl (1|M0)               r2.6<1>:d     r39.7<0;1,0>:d    1:w               {F@1}
        mul (16|M0)              r13.0<1>:f    r3.2<0;1,0>:f     r13.0<1;1,0>:f   {Compacted}
        mul (16|M0)              r15.0<1>:f    r3.2<0;1,0>:f     r15.0<1;1,0>:f   {Compacted}
        mov (8|M0)               r6.0<1>:hf    r13.0<1;1,0>:f                   {F@2}
        mov (8|M0)               r6.8<1>:hf    r14.0<1;1,0>:f                  
        mov (8|M0)               r7.0<1>:hf    r15.0<1;1,0>:f                   {F@3}
        mov (8|M0)               r7.8<1>:hf    r16.0<1;1,0>:f                  
        mov (8|M0)               r8.0<1>:f     (abs)r6.0<1;1,0>:hf              {F@4}
        mov (8|M0)               r9.0<1>:f     (abs)r6.8<1;1,0>:hf              {F@4}
        mov (8|M0)               r10.0<1>:f    (abs)r7.0<1;1,0>:hf              {F@4}
        mov (8|M0)               r11.0<1>:f    (abs)r7.8<1;1,0>:hf              {F@4}
        sel (16|M0)   (lt)f0.0   r8.0<1>:f     r8.0<1;1,0>:f     448.0:f               {Compacted,F@3}
        sel (16|M0)   (lt)f0.0   r10.0<1>:f    r10.0<1;1,0>:f    448.0:f               {Compacted,F@2}
        shr (16|M0)              r17.0<1>:ud   r8.0<1;1,0>:ud    0x17:uw              {F@2}
        shr (16|M0)              r19.0<1>:ud   r10.0<1;1,0>:ud   0x17:uw              {F@1}
        sel (16|M0)   (ge)f0.0   r26.0<2>:ub   r17.0<4;1,0>:ub   0x79:uw              {I@2}
        sel (16|M0)   (ge)f0.0   r27.0<2>:ub   r19.0<4;1,0>:ub   0x79:uw              {I@2}
        mov (16|M0)              r28.0<1>:d    r26.0<2;1,0>:ub                  {I@2}
        mov (16|M0)              r30.0<1>:d    r27.0<2;1,0>:ub                  {I@2}
        shl (16|M0)              r28.0<1>:d    r28.0<1;1,0>:d    23:w               {Compacted,I@2}
        shl (16|M0)              r30.0<1>:d    r30.0<1;1,0>:d    23:w               {Compacted,I@2}
        add (16|M0)              r5.0<1>:d     r28.0<1;1,0>:d    -25165824:d               {I@2}
        add (16|M0)              r28.0<1>:d    -r28.0<1;1,0>:d   -2139095040:d              
        add (16|M0)              r32.0<1>:d    r30.0<1;1,0>:d    -25165824:d               {I@3}
        mul (16|M0)              acc0.0<1>:f   r8.0<1;1,0>:f     r28.0<1;1,0>:f   {Compacted,I@2}
        add (16|M0)              r30.0<1>:d    -r30.0<1;1,0>:d   -2139095040:d              
        mul (16|M0)              r24.0<1>:f    r3.2<0;1,0>:f     r24.0<1;1,0>:f   {Compacted}
        rnde (16|M0)             acc0.0<1>:f   acc0.0<1;1,0>:f                 
        mul (16|M0)              acc2.0<1>:f   r10.0<1;1,0>:f    r30.0<1;1,0>:f   {Compacted,I@1}
        mul (16|M0)              acc0.0<1>:f   acc0.0<1;1,0>:f   r5.0<1;1,0>:f    {Compacted}
        rnde (16|M0)             acc2.0<1>:f   acc2.0<1;1,0>:f                 
        mov (8|M0)               r6.0<1>:hf    r24.0<1;1,0>:f                   {F@5}
        mov (8|M0)               r6.8<1>:hf    r25.0<1;1,0>:f                  
        cmp (16|M0)   (lt)f1.1   null<1>:f     r13.0<1;1,0>:f    0xB3000000:f              
        mul (16|M0)              acc2.0<1>:f   acc2.0<1;1,0>:f   r32.0<1;1,0>:f   {Compacted}
        mov (8|M0)               r10.0<1>:f    (abs)r6.0<1;1,0>:hf              {F@4}
        mov (8|M0)               r11.0<1>:f    (abs)r6.8<1;1,0>:hf              {F@4}
        mov (16|M0)              r17.0<1>:f    (abs)acc0.0<1;1,0>:f             {Compacted}
        sel (16|M0)   (lt)f0.0   r10.0<1>:f    r10.0<1;1,0>:f    448.0:f               {Compacted,F@2}
        mul (16|M0)              r22.0<1>:f    r3.2<0;1,0>:f     r22.0<1;1,0>:f   {Compacted}
        cmp (16|M0)   (lt)f1.0   null<1>:f     r15.0<1;1,0>:f    0xB3000000:f               {Compacted}
(f1.1)  or (16|M0)               r17.0<1>:d    r17.0<1;1,0>:d    -2147483648:d               {F@4}
        shr (16|M0)              r15.0<1>:ud   r10.0<1;1,0>:ud   0x17:uw              {A@1}
        mov (8|M0)               r5.0<1>:hf    r22.0<1;1,0>:f                  
        mov (8|M0)               r5.8<1>:hf    r23.0<1;1,0>:f                  
        mov (8|M0)               r7.8<1>:hf    r18.0<1;1,0>:f                   {I@2}
        sel (16|M0)   (ge)f0.0   r18.0<2>:ub   r15.0<4;1,0>:ub   0x79:uw              {A@1}
        mov (8|M0)               r8.0<1>:f     (abs)r5.0<1;1,0>:hf             
        mov (8|M0)               r9.0<1>:f     (abs)r5.8<1;1,0>:hf             
        mov (16|M0)              r26.0<1>:d    r18.0<2;1,0>:ub                  {I@1}
        sel (16|M0)   (lt)f0.0   r8.0<1>:f     r8.0<1;1,0>:f     448.0:f               {Compacted,F@1}
        shl (16|M0)              r26.0<1>:d    r26.0<1;1,0>:d    23:w               {Compacted,I@1}
        mov (16|M0)              r19.0<1>:f    (abs)acc2.0<1;1,0>:f             {Compacted}
        shr (16|M0)              r13.0<1>:ud   r8.0<1;1,0>:ud    0x17:uw              {F@2}
        add (16|M0)              r5.0<1>:d     r26.0<1;1,0>:d    -25165824:d               {I@2}
        add (16|M0)              r26.0<1>:d    -r26.0<1;1,0>:d   -2139095040:d              
        mov (8|M0)               r7.0<1>:hf    r17.0<1;1,0>:f                  
(f1.0)  or (16|M0)               r19.0<1>:d    r19.0<1;1,0>:d    -2147483648:d               {F@2}
        mul (16|M0)              acc0.0<1>:f   r10.0<1;1,0>:f    r26.0<1;1,0>:f   {Compacted,I@2}
        sel (16|M0)   (ge)f0.0   r17.0<2>:ub   r13.0<4;1,0>:ub   0x79:uw              {F@2}
        mov (8|M0)               r12.0<1>:hf   r19.0<1;1,0>:f                   {I@2}
        mov (8|M0)               r12.8<1>:hf   r20.0<1;1,0>:f                  
        rnde (16|M0)             acc0.0<1>:f   acc0.0<1;1,0>:f                 
        mov (16|M0)              r19.0<1>:d    r17.0<2;1,0>:ub                  {A@1}
        mul (16|M0)              r15.0<1>:f    acc0.0<1;1,0>:f   r5.0<1;1,0>:f    {Compacted}
        shl (16|M0)              r19.0<1>:d    r19.0<1;1,0>:d    23:w               {Compacted,I@1}
        or (1|M0)                r5.0<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {F@1}
        shr (1|M0)               r5.1<1>:ud    r39.3<0;1,0>:ud   0x3:uw             
        shl (1|M0)               r1.2<1>:d     r39.3<0;1,0>:d    31:w              
        shr (1|M0)               r5.5<1>:ud    r39.3<0;1,0>:ud   0x1:uw             
        add (16|M0)              r28.0<1>:d    r19.0<1;1,0>:d    -25165824:d               {I@5}
        and (2|M0)               r5.0<1>:d     r5.0<1;1,0>:d     r39.0<1;1,0>:d   {I@4}
        or (1|M0)                r5.4<1>:d     r4.5<0;1,0>:d     r1.2<0;1,0>:d    {I@4}
        add (16|M0)              r19.0<1>:d    -r19.0<1;1,0>:d   -2139095040:d              
        shl (1|M0)               r3.2<1>:d     r39.6<0;1,0>:d    1:w              
        bfn.0xEA (2|M0)          r5.0<1>:ud    r5.0<1;0>:ud      r5.4<1;0>:ud      r40.0<1>:ud      {I@3} // s0|s1&s2
        mul (16|M0)              acc2.0<1>:f   r8.0<1;1,0>:f     r19.0<1;1,0>:f   {Compacted,I@3}
        addc (1|M0)              r6.0<1>:ud    r4.6<0;1,0>:ud    r3.2<0;1,0>:ud   {AccWrEn,I@2}
        shl (1|M0)               r6.1<1>:d     r5.1<0;1,0>:d     7:w               {Compacted,I@2}
        shr (1|M0)               r6.2<1>:ud    r5.0<0;1,0>:ud    0x19:uw             
        shl (1|M0)               r6.3<1>:d     r5.0<0;1,0>:d     7:w               {Compacted}
        rnde (16|M0)             acc2.0<1>:f   acc2.0<1;1,0>:f                 
        or (1|M0)                r3.3<1>:d     r2.6<0;1,0>:d     r2.7<0;1,0>:d   
        or (1|M0)                r6.4<1>:d     r6.1<0;1,0>:d     r6.2<0;1,0>:d    {I@3}
        shl (1|M0)               r3.2<1>:d     r6.3<0;1,0>:d     1:w               {I@3}
        mul (16|M0)              acc2.0<1>:f   acc2.0<1;1,0>:f   r28.0<1;1,0>:f   {Compacted}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,F@3}
        shr (1|M0)               r2.7<1>:ud    r6.3<0;1,0>:ud    0x1F:uw             
        shl (1|M0)               r2.6<1>:d     r6.4<0;1,0>:d     1:w               {I@4}
        shl (1|M0)               r8.2<1>:d     r1.6<0;1,0>:d     1:w              
        add3 (1|M0)              r5.3<1>:d     r8.0<0;0>:d       r4.7<0;0>:d       r3.3<0>:d        {I@4}
        addc (1|M0)              r8.0<1>:ud    r6.0<0;1,0>:ud    r3.2<0;1,0>:ud   {AccWrEn}
        cmp (16|M0)   (lt)f0.1   null<1>:f     r22.0<1;1,0>:f    0xB3000000:f              
        shl (1|M0)               r4.5<1>:d     r1.7<0;1,0>:d     1:w              
        shr (1|M0)               r8.1<1>:ud    r1.6<0;1,0>:ud    0x1F:uw             
        or (1|M0)                r3.3<1>:d     r2.6<0;1,0>:d     r2.7<0;1,0>:d    {I@6}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r6.0<1>:ud    r8.0<0;1,0>:ud    r8.2<0;1,0>:ud   {AccWrEn,I@5}
        mov (16|M0)              r13.0<1>:f    (abs)acc2.0<1;1,0>:f             {Compacted}
        or (1|M0)                r8.3<1>:d     r4.5<0;1,0>:d     r8.1<0;1,0>:d    {I@4}
        add3 (1|M0)              r1.3<1>:d     r9.0<0;0>:d       r5.3<0;0>:d       r3.3<0>:d        {I@3}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        cmp (16|M0)   (lt)f1.1   null<1>:f     r24.0<1;1,0>:f    0xB3000000:f              
        mov (1|M0)               r2.6<1>:d     r6.0<0;1,0>:d                    {I@4}
(f0.1)  or (16|M0)               r13.0<1>:d    r13.0<1;1,0>:d    -2147483648:d               {F@2}
        add3 (1|M0)              r2.7<1>:d     r10.0<0;0>:d      r1.3<0;0>:d       r8.3<0>:d        {I@3}
        mov (16|M0)              r15.0<1>:f    (abs)r15.0<1;1,0>:f              {Compacted}
        mov (8|M0)               r17.0<1>:hf   r13.0<1;1,0>:f                   {I@2}
        mov (8|M0)               r17.8<1>:hf   r14.0<1;1,0>:f                  
        mov (8|M0)               r13.0<2>:ud   r2.6<0;1,0>:ud                   {A@1}
        mov (8|M0)               r13.1<2>:ud   r2.7<0;1,0>:ud                   {I@2}
(f1.1)  or (16|M0)               r15.0<1>:d    r15.0<1;1,0>:d    -2147483648:d              
        addc (8|M0)              r5.0<1>:ud    r13.0<2;1,0>:ud   r35.0<2;1,0>:ud  {AccWrEn,Compacted,I@2}
        mov (8|M0)               r18.8<1>:hf   r16.0<1;1,0>:f                   {I@2}
        mov (8|M0)               r9.0<1>:ud    acc0.0<1;1,0>:ud                 {Compacted}
        addc (8|M0)              r16.0<1>:ud   r13.0<2;1,0>:ud   r37.0<2;1,0>:ud  {AccWrEn,Compacted,F@1}
        mov (8|M0)               r11.0<1>:d    r35.1<2;1,0>:d                  
        mov (8|M0)               r19.0<2>:d    r5.0<1;1,0>:d                    {I@4}
        mov (8|M0)               r6.0<1>:ud    acc0.0<1;1,0>:ud                 {Compacted}
        addc (1|M0)              r5.0<1>:ud    r2.6<0;1,0>:ud    0x200:ud              {AccWrEn}
        mov (8|M0)               r18.0<1>:hf   r15.0<1;1,0>:f                  
        add3 (8|M0)              r15.0<1>:d    r9.0<1;0>:d       r13.1<4;2>:d      r11.0<1>:d       {A@1}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r1.2<1>:d     r5.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r1.3<1>:d     r9.0<0;0>:d       r2.7<0;0>:d       0:w               {I@2}
        mov (8|M0)               r25.0<2>:ud   r1.2<0;1,0>:ud                   {I@2}
        mov (8|M0)               r25.1<2>:ud   r1.3<0;1,0>:ud                   {I@2}
        mov (8|M0)               r8.0<1>:d     r37.1<2;1,0>:d                  
        mov (8|M0)               r19.1<2>:d    r15.0<1;1,0>:d                  
        addc (8|M0)              r15.0<1>:ud   r25.0<2;1,0>:ud   r35.0<2;1,0>:ud  {AccWrEn,Compacted,I@3}
        mov (16|M0)              r23.0<1>:d    r7.0<1;1,0>:uw                  
        mov (8|M0)               r21.0<2>:d    r16.0<1;1,0>:d                  
        add3 (8|M0)              r10.0<1>:d    r6.0<1;0>:d       r13.1<4;2>:d      r8.0<1>:d        {I@5}
        mov (8|M0)               r16.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        addc (8|M0)              r7.0<1>:ud    r25.0<2;1,0>:ud   r37.0<2;1,0>:ud  {AccWrEn,Compacted}
        mov (8|M0)               r21.1<2>:d    r10.0<1;1,0>:d                   {I@3}
        mov (8|M0)               r10.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        addc (1|M0)              r9.0<1>:ud    r2.6<0;1,0>:ud    0x400:ud              {AccWrEn}
        send.ugm (16|M0)         null     r19     r23:2   0x0            0x08000B84           {A@3,$9} // wr:4+2, rd:0; store.ugm.d16u32.a64
        mov (1|M0)               r19.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,$9.src}
        mov (1|M0)               r1.2<1>:d     r9.0<0;1,0>:d                    {I@2}
        add3 (1|M0)              r1.3<1>:d     r19.0<0;0>:d      r2.7<0;0>:d       0:w               {I@2}
        mov (8|M0)               r27.0<2>:d    r15.0<1;1,0>:d                  
        add3 (8|M0)              r6.0<1>:d     r16.0<1;0>:d      r25.1<4;2>:d      r11.0<1>:d      
        mov (8|M0)               r15.0<2>:ud   r1.2<0;1,0>:ud                   {I@4}
        mov (8|M0)               r15.1<2>:ud   r1.3<0;1,0>:ud                   {I@4}
        add3 (8|M0)              r5.0<1>:d     r10.0<1;0>:d      r25.1<4;2>:d      r8.0<1>:d       
        mov (8|M0)               r27.1<2>:d    r6.0<1;1,0>:d                    {I@4}
        addc (8|M0)              r6.0<1>:ud    r15.0<2;1,0>:ud   r35.0<2;1,0>:ud  {AccWrEn,Compacted,I@3}
        mov (16|M0)              r13.0<1>:d    r12.0<1;1,0>:uw                 
        mov (8|M0)               r29.0<2>:d    r7.0<1;1,0>:d                   
        mov (8|M0)               r20.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mov (8|M0)               r29.1<2>:d    r5.0<1;1,0>:d                    {I@6}
        addc (8|M0)              r7.0<1>:ud    r15.0<2;1,0>:ud   r37.0<2;1,0>:ud  {AccWrEn,Compacted}
        send.ugm (16|M0)         null     r27     r13:2   0x0            0x08000B84           {A@2,$10} // wr:4+2, rd:0; store.ugm.d16u32.a64
        mov (8|M0)               r10.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        addc (1|M0)              r14.0<1>:ud   r2.6<0;1,0>:ud    0x600:ud              {AccWrEn,$10.src}
        add3 (8|M0)              r5.0<1>:d     r20.0<1;0>:d      r15.1<4;2>:d      r11.0<1>:d      
        mov (1|M0)               r19.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r1.2<1>:d     r14.0<0;1,0>:d                   {I@3}
        add3 (1|M0)              r1.3<1>:d     r19.0<0;0>:d      r2.7<0;0>:d       0:w               {I@2}
        mov (8|M0)               r21.0<2>:d    r6.0<1;1,0>:d                   
        mov (8|M0)               r21.1<2>:d    r5.0<1;1,0>:d                   
        mov (8|M0)               r5.0<2>:ud    r1.2<0;1,0>:ud                   {I@4}
        mov (8|M0)               r5.1<2>:ud    r1.3<0;1,0>:ud                   {I@4}
        add3 (8|M0)              r9.0<1>:d     r10.0<1;0>:d      r15.1<4;2>:d      r8.0<1>:d       
        addc (8|M0)              r20.0<1>:ud   r5.0<2;1,0>:ud    r35.0<2;1,0>:ud  {AccWrEn,Compacted,I@2}
        mov (8|M0)               r23.0<2>:d    r7.0<1;1,0>:d                   
        mov (8|M0)               r23.1<2>:d    r9.0<1;1,0>:d                    {I@3}
        mov (8|M0)               r25.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        addc (8|M0)              r9.0<1>:ud    r5.0<2;1,0>:ud    r37.0<2;1,0>:ud  {AccWrEn,Compacted}
        mov (16|M0)              r12.0<1>:d    r17.0<1;1,0>:uw                 
        mov (8|M0)               r10.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        addc (1|M0)              r15.0<1>:ud   r39.2<0;1,0>:ud   r34.0<0;1,0>:ud  {AccWrEn}
        send.ugm (16|M0)         null     r21     r12:2   0x0            0x08000B84           {A@3,$11} // wr:4+2, rd:0; store.ugm.d16u32.a64
        mov (1|M0)               r40.2<1>:d    r15.0<0;1,0>:d                   {I@1}
        mov (1|M0)               r16.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        cmp (1|M0)    (lt)f1.0   null<1>:ud    r40.2<0;1,0>:ud   r3.0<0;1,0>:ud   {I@2}
        add3 (1|M0)              r40.3<1>:d    r16.0<0;0>:d      r39.3<0;0>:d      r34.1<0>:d       {I@2}
        add3 (8|M0)              r7.0<1>:d     r25.0<1;0>:d      r5.1<4;2>:d       r11.0<1>:d      
        cmp (1|M0)    (lt)f0.1   null<1>:ud    r40.3<0;1,0>:ud   r3.1<0;1,0>:ud   {I@2}
(f1.0)  cmp (1|M0)    (eq)f1.0   null<1>:d     r40.3<0;1,0>:d    r3.1<0;1,0>:d   
        add3 (8|M0)              r12.0<1>:d    r10.0<1;0>:d      r5.1<4;2>:d       r8.0<1>:d        {$11.src}
        mov (8|M0)               r26.0<2>:d    r20.0<1;1,0>:d                  
(f0.1)  sel (1|M0)               r2.12<1>:uw   r1.3<0;1,0>:uw    0x0:uw             
(f1.0)  sel (1|M0)               r1.4<1>:uw    r1.3<0;1,0>:uw    0x0:uw             
        mov (8|M0)               r28.0<2>:d    r9.0<1;1,0>:d                   
        or (1|M0)     (ne)f1.0   null<1>:uw    r1.4<0;1,0>:uw    r2.12<0;1,0>:uw  {I@2}
        mov (16|M0)              r13.0<1>:d    r18.0<1;1,0>:uw                 
        mov (8|M0)               r26.1<2>:d    r7.0<1;1,0>:d                   
(W)     and (1|M0)               f0.1<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
        mov (8|M0)               r28.1<2>:d    r12.0<1;1,0>:d                  
        send.ugm (16|M0)         null     r26     r13:2   0x0            0x08000B84           {A@1,$3} // wr:4+2, rd:0; store.ugm.d16u32.a64
(~f0.1.any16h) goto (16|M0)                  L7080                  L7080                
L7048:
(W)     mov (2|M0)               r39.2<1>:ud   r40.2<1;1,0>:ud                 
        goto.b (16|M0)                       L7080                  L1040                
L7080:
        join (16|M0)                         L7096                                
L7096:
(W)     mov (8|M0)               r127.0<1>:f   r0.0<1;1,0>:f                    {Compacted,$2.src}
(W)     send.ugm (1|M0)          r5       r0      null:0  0x0            0x0210641F           {$12} // wr:1+0, rd:1; fence invalid flush type scoped to tile
(W)     mov (8|M0)               null<1>:ud    r5.0<1;1,0>:ud                   {$12.dst}
(W)     send.gtwy (1|M0)         null     r127    null:0  0x0            0x02000010           {EOT,A@1} // wr:1+0, rd:0; end of thread
L7152:
        mov (1|M0)               r1.2<1>:d     cr0.0<0;1,0>:ud                  {A@1}
        and (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   -1265:w               {A@1}
        or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   1264:w               {A@1}
        mov (1|M0)               r1.3<1>:f     r34.7<0;1,0>:ud                  {A@1}
        mov (1|M0)               r3.2<1>:f     0xB4C00000:f                               {Compacted}
        math.inv (1|M0)          r2.7<1>:f     r1.3<0;1,0>:f                    {@2,$13}
        mov (1|M0)               r1.5<1>:f     r41.5<0;1,0>:ud                 
        sync.nop                             null                             {Compacted,$13.dst}
        mad (1|M0)               r2.7<1>:f     r2.7<0;0>:f       r3.2<0;0>:f       r2.7<0>:f        {F@2}
        mov (1|M0)               r41.4<1>:ud   r1.3<0;1,0>:f                   
        mov (1|M0)               r1.6<1>:ud    r1.5<0;1,0>:f                    {F@2}
        mul (1|M0)               r4.5<1>:f     r2.7<0;1,0>:f     r1.5<0;1,0>:f    {F@1}
        add (1|M0)               r41.4<1>:ud   r34.7<0;1,0>:ud   -r41.4<0;1,0>:ud {I@2}
        add (1|M0)               r1.6<1>:ud    r41.5<0;1,0>:ud   -r1.6<0;1,0>:ud  {I@2}
        mov (1|M0)               r5.0<1>:ud    r4.5<0;1,0>:f                    {F@1}
        mov (1|M0)               r1.4<1>:f     r41.4<0;1,0>:ud                  {I@3}
        mov (1|M0)               r2.6<1>:f     r1.6<0;1,0>:ud                   {I@2}
        mov (1|M0)               r5.1<1>:f     r5.0<0;1,0>:ud                   {Compacted,I@1}
        mad (1|M0)               r1.5<1>:f     r1.5<0;0>:f       r5.1<0;0>:f       -r1.3<0>:f       {F@1}
        mad (1|M0)               r5.1<1>:f     r2.6<0;0>:f       r5.1<0;0>:f       -r1.4<0>:f      
        add (1|M0)               r1.5<1>:f     r1.5<0;1,0>:f     r5.1<0;1,0>:f    {F@1}
        mul (1|M0)               r2.7<1>:f     r2.7<0;1,0>:f     r1.5<0;1,0>:f    {F@1}
        mov (1|M0)               r6.0<1>:ud    r2.7<0;1,0>:f                    {F@1}
        add (1|M0)               r5.0<1>:ud    r5.0<0;1,0>:ud    r6.0<0;1,0>:ud   {Compacted,I@1}
(W)     mul (1|M0)               acc0.0<1>:ud  r5.0<0;1,0>:ud    r34.14<0;1,0>:uw {I@1}
        mach (1|M0)              r5.0<1>:ud    r5.0<0;1,0>:ud    r34.7<0;1,0>:ud  {Compacted}
        add (1|M0)               r41.5<1>:ud   r41.5<0;1,0>:ud   -r5.0<0;1,0>:ud  {I@1}
        cmp (1|M0)    (lt)f0.1   null<1>:ud    r41.5<0;1,0>:ud   r34.7<0;1,0>:ud  {I@1}
(f0.1)  mov (1|M0)               r34.7<1>:d    0:w                              
        add (1|M0)               r40.4<1>:ud   r41.5<0;1,0>:ud   -r34.7<0;1,0>:ud {I@1}
        mov (1|M0)               cr0.0<1>:ud   r1.2<0;1,0>:d                    {A@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        ret (16|M0)                          r40.6                            {A@1}
L7656:
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
