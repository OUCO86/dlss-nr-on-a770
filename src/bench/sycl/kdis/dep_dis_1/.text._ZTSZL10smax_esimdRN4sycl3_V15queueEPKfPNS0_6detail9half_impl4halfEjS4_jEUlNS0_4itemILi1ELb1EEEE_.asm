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
        cmp (1|M0)    (eq)f1.0   null<1>:d     r3.1<0;1,0>:d     0:w              
        addc (1|M0)              r6.0<1>:ud    r4.0<0;1,0>:ud    r1.2<0;1,0>:ud   {AccWrEn,I@2}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r3.6<1>:d     r6.0<0;1,0>:d                    {I@2}
        add3 (1|M0)              r3.7<1>:d     r7.0<0;0>:d       r5.0<0;0>:d       0:w               {I@2}
(f1.0)  cmp (1|M0)    (eq)f1.0   null<1>:d     r3.0<0;1,0>:d     0:w              
        shr (1|M0)               r9.0<1>:ud    r3.6<0;1,0>:ud    0x1A:uw              {I@3}
        shl (1|M0)               r112.0<1>:d   r3.6<0;1,0>:d     6:w               {Compacted}
        shl (1|M0)               r8.0<1>:d     r3.7<0;1,0>:d     6:w               {Compacted,I@4}
        shl (1|M0)               r12.0<1>:d    r112.0<0;1,0>:d   2:w               {Compacted,I@2}
        or (1|M0)                r112.1<1>:d   r8.0<0;1,0>:d     r9.0<0;1,0>:d    {Compacted,I@2}
        shr (1|M0)               r11.0<1>:ud   r112.0<0;1,0>:ud  0x1E:uw             
(W)     and (1|M0)               f0.0<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
        addc (1|M0)              r13.0<1>:ud   r2.6<0;1,0>:ud    r12.0<0;1,0>:ud  {AccWrEn,I@4}
        shl (1|M0)               r10.0<1>:d    r112.1<0;1,0>:d   2:w               {Compacted,I@4}
        mov (1|M0)               r14.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        or (1|M0)                r12.1<1>:d    r10.0<0;1,0>:d    r11.0<0;1,0>:d   {Compacted,I@2}
        mov (1|M0)               r113.0<1>:f   r13.0<0;1,0>:f                   {Compacted}
        add3 (1|M0)              r113.1<1>:d   r14.0<0;0>:d      r2.7<0;0>:d       r12.1<0>:d       {I@1}
(f0.0.any16h) goto (16|M0)                   L880                  L880                
L528:
        shr (1|M0)               r112.5<1>:ud  r3.6<0;1,0>:ud    0x6:uw             
        sel (1|M0)    (ge)f0.0   r3.3<1>:ud    r3.2<0;1,0>:ud    0x1:uw             
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r112.6        L5472                                 {A@1}
L608:
        shr (1|M0)               r1.2<1>:ud    r112.2<0;1,0>:ud  0x14:uw             
        mov (2|M0)               r5.0<1>:w     0x1010101:v                              
        shl (1|M0)               r4.0<1>:d     r112.2<0;1,0>:d   12:w               {Compacted}
        or (1|M0)                r4.1<1>:d     r1.2<0;1,0>:d     0:w               {I@3}
        mul (2|M0)               r6.0<1>:d     r5.0<1;1,0>:w     4032:w               {I@3}
        bfn.0xEA (2|M0)          r4.0<1>:ud    r4.0<1;0>:ud      r112.0<1;0>:ud    r6.0<1>:ud       {I@1} // s0|s1&s2
        shl (1|M0)               r9.0<1>:d     r4.0<0;1,0>:d     2:w               {Compacted,I@1}
        shl (1|M0)               r7.0<1>:d     r4.1<0;1,0>:d     2:w               {Compacted}
        addc (1|M0)              r10.0<1>:ud   r3.0<0;1,0>:ud    r9.0<0;1,0>:ud   {AccWrEn,I@2}
        shr (1|M0)               r8.0<1>:ud    r4.0<0;1,0>:ud    0x1E:uw             
        mov (1|M0)               r12.0<1>:f    r10.0<0;1,0>:f                   {Compacted,I@2}
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        or (1|M0)                r9.1<1>:d     r7.0<0;1,0>:d     r8.0<0;1,0>:d    {Compacted,I@2}
        addc (1|M0)              r13.0<1>:ud   r12.0<0;1,0>:ud   0x80:ud              {AccWrEn,F@1}
        add3 (1|M0)              r12.1<1>:d    r11.0<0;0>:d      r3.1<0;0>:d       r9.1<0>:d        {I@2}
        mov (1|M0)               r14.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r15.0<1>:f    r13.0<0;1,0>:f                   {Compacted,I@3}
        add3 (1|M0)              r15.1<1>:d    r14.0<0;0>:d      r12.1<0;0>:d      0:w               {I@1}
        send.ugm (1|M0)          r118     r12     null:0  0x0            0x0240E580           {$2} // wr:1+0, rd:4; load.ugm.d32x32t.a64
        send.ugm (1|M0)          r114     r15     null:0  0x0            0x0240E580           {A@1,$3} // wr:1+0, rd:4; load.ugm.d32x32t.a64
        goto (16|M0)                         L880                  L944                
L880:
        join (16|M0)                         L944                                
L896:
        mov (16|M0)              r114.0<1>:ud  0x0:ud                              {$3.dst}
        mov (16|M0)              r116.0<1>:ud  0x0:ud                             
        mov (16|M0)              r118.0<1>:f   0.0:f                               {Compacted,$2.dst}
        mov (16|M0)              r120.0<1>:f   0.0:f                               {Compacted}
L944:
        join (16|M0)                         L960                                
L960:
        send.ugm (1|M0)          r4       r113    null:0  0x0            0x0240E580           {$4} // wr:1+0, rd:4; load.ugm.d32x32t.a64
        mov (1|M0)               r35.0<1>:f    0x3D380000:f                              
        mov (1|M0)               r36.0<1>:f    0x3FA68000:f                              
        addc (1|M0)              r8.0<1>:ud    r113.0<0;1,0>:ud  0x80:ud              {AccWrEn}
(W)     mov (8|M0)               r127.0<1>:f   r0.0<1;1,0>:f                    {Compacted}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r10.0<1>:f    r8.0<0;1,0>:f                    {Compacted,I@2}
        add3 (1|M0)              r10.1<1>:d    r9.0<0;0>:d       r113.1<0;0>:d     0:w               {I@1}
        send.ugm (1|M0)          r11      r10     null:0  0x0            0x0240E580           {A@1,$5} // wr:1+0, rd:4; load.ugm.d32x32t.a64
        sync.nop                             null                             {Compacted,$4.dst}
        add (16|M0)              r17.0<1>:f    r120.0<1;1,0>:f   r6.0<1;1,0>:f    {Compacted,$2.dst}
        add (16|M0)              r15.0<1>:f    r118.0<1;1,0>:f   r4.0<1;1,0>:f    {Compacted,$3.src}
        mov (8|M0)               r20.0<1>:hf   r17.0<1;1,0>:f                   {F@2}
        mov (8|M0)               r20.8<1>:hf   r18.0<1;1,0>:f                  
        mov (8|M0)               r19.0<1>:hf   r15.0<1;1,0>:f                   {F@3}
        mov (8|M0)               r19.8<1>:hf   r16.0<1;1,0>:f                  
        mov (8|M0)               r23.0<1>:f    r20.0<1;1,0>:hf                  {F@4}
        mov (8|M0)               r24.0<1>:f    r20.8<1;1,0>:hf                  {F@4}
        mov (8|M0)               r21.0<1>:f    r19.0<1;1,0>:hf                  {F@4}
        mov (8|M0)               r22.0<1>:f    r19.8<1;1,0>:hf                  {F@4}
        mad (16|M0)              r23.0<1>:f    r36.0<0;0>:f      r23.0<1;0>:f      r35.0<0>:f       {Compacted,F@3}
        mad (16|M0)              r21.0<1>:f    r36.0<0;0>:f      r21.0<1;0>:f      r35.0<0>:f       {Compacted,F@2}
        mov (8|M0)               r38.0<1>:hf   r23.0<1;1,0>:f                   {F@2}
        mov (8|M0)               r38.8<1>:hf   r24.0<1;1,0>:f                  
        mov (8|M0)               r37.0<1>:hf   r21.0<1;1,0>:f                   {F@3}
        mov (8|M0)               r37.8<1>:hf   r22.0<1;1,0>:f                  
        mov (8|M0)               r41.0<1>:f    r38.0<1;1,0>:hf                  {F@4}
        mov (8|M0)               r42.0<1>:f    r38.8<1;1,0>:hf                  {F@4}
        mov (8|M0)               r39.0<1>:f    r37.0<1;1,0>:hf                  {F@4}
        mov (8|M0)               r40.0<1>:f    r37.8<1;1,0>:hf                  {F@4}
        sel (16|M0)   (ge)f0.0   acc0.0<1>:f   r41.0<1;1,0>:f    1.03125:f               {F@3}
        sel (16|M0)   (ge)f0.0   acc2.0<1>:f   r39.0<1;1,0>:f    1.03125:f               {F@2}
        sel (16|M0)   (lt)f0.0   r41.0<1>:f    acc0.0<1;1,0>:f   0x3FC8E000:f              
        sel (16|M0)   (lt)f0.0   r39.0<1>:f    acc2.0<1;1,0>:f   0x3FC8E000:f              
        mov (8|M0)               r51.0<1>:ud   r41.0<2;1,0>:ud                  {F@2}
        mov (8|M0)               r55.0<1>:ud   r41.1<2;1,0>:ud                 
        mov (8|M0)               r49.0<1>:ud   r39.0<2;1,0>:ud                  {F@1}
        mov (8|M0)               r53.0<1>:ud   r39.1<2;1,0>:ud                 
        mov (8|M0)               r52.0<2>:hf   r51.0<1;1,0>:f                   {I@4}
        mov (8|M0)               r56.0<2>:hf   r55.0<1;1,0>:f                   {I@3}
        mov (8|M0)               r50.0<1>:hf   r49.0<1;1,0>:f                   {I@2}
        mov (8|M0)               r54.0<1>:hf   r53.0<1;1,0>:f                   {I@1}
        mov (8|M0)               r50.8<1>:uw   r52.0<2;1,0>:uw                  {F@4}
        mov (8|M0)               r54.8<1>:uw   r56.0<2;1,0>:uw                  {F@3}
        shl (16|M0)              r63.0<1>:d    r50.0<1;1,0>:uw   5:w               {A@2}
        mov (16|M0)              r61.0<1>:d    r54.0<1;1,0>:uw                  {A@1}
        add (16|M0)              r63.0<1>:d    r63.0<1;1,0>:d    2146992128:d               {I@2}
        shl (16|M0)              r61.0<1>:d    r61.0<1;1,0>:d    21:w               {Compacted,I@2}
        add (16|M0)              r63.0<1>:d    r63.0<1;1,0>:d    r61.0<1;1,0>:d   {Compacted,I@1}
        mov (8|M0)               r67.0<1>:f    r63.0<1;1,0>:hf                  {I@1}
        mov (8|M0)               r68.0<1>:f    r63.8<1;1,0>:hf                 
        add (1|M0)               r71.0<1>:f    r67.0<0;1,0>:f    r67.1<0;1,0>:f   {Compacted,F@2}
        mov (8|M0)               r69.0<1>:f    r64.0<1;1,0>:hf                 
        add (1|M0)               r71.0<1>:f    r71.0<0;1,0>:f    r67.2<0;1,0>:f   {Compacted,F@2}
        sync.nop                             null                             {Compacted,$5.dst}
        add (16|M0)              r27.0<1>:f    r116.0<1;1,0>:f   r13.0<1;1,0>:f   {Compacted,$3.dst}
        add (1|M0)               r71.0<1>:f    r71.0<0;1,0>:f    r67.3<0;1,0>:f   {Compacted,F@2}
        add (16|M0)              r25.0<1>:f    r114.0<1;1,0>:f   r11.0<1;1,0>:f   {Compacted}
        add (1|M0)               r71.0<1>:f    r71.0<0;1,0>:f    r67.4<0;1,0>:f   {Compacted,F@2}
        mov (8|M0)               r30.0<1>:hf   r27.0<1;1,0>:f                  
        add (1|M0)               r71.0<1>:f    r71.0<0;1,0>:f    r67.5<0;1,0>:f   {Compacted,F@2}
        mov (8|M0)               r30.8<1>:hf   r28.0<1;1,0>:f                  
        add (1|M0)               r71.0<1>:f    r71.0<0;1,0>:f    r67.6<0;1,0>:f   {Compacted,F@2}
        mov (8|M0)               r29.0<1>:hf   r25.0<1;1,0>:f                  
        add (1|M0)               r71.0<1>:f    r71.0<0;1,0>:f    r67.7<0;1,0>:f   {Compacted,F@2}
        mov (8|M0)               r29.8<1>:hf   r26.0<1;1,0>:f                  
        add (1|M0)               r71.0<1>:f    r71.0<0;1,0>:f    r68.0<0;1,0>:f   {Compacted,F@2}
        mov (8|M0)               r33.0<1>:f    r30.0<1;1,0>:hf                 
        add (1|M0)               r71.0<1>:f    r71.0<0;1,0>:f    r68.1<0;1,0>:f   {Compacted,F@2}
        mov (8|M0)               r34.0<1>:f    r30.8<1;1,0>:hf                 
        add (1|M0)               r71.0<1>:f    r71.0<0;1,0>:f    r68.2<0;1,0>:f   {Compacted,F@2}
        mov (8|M0)               r31.0<1>:f    r29.0<1;1,0>:hf                 
        add (1|M0)               r71.0<1>:f    r71.0<0;1,0>:f    r68.3<0;1,0>:f   {Compacted,F@2}
        mov (8|M0)               r32.0<1>:f    r29.8<1;1,0>:hf                 
        add (1|M0)               r71.0<1>:f    r71.0<0;1,0>:f    r68.4<0;1,0>:f   {Compacted,F@2}
        mad (16|M0)              r33.0<1>:f    r36.0<0;0>:f      r33.0<1;0>:f      r35.0<0>:f       {Compacted}
        add (1|M0)               r71.0<1>:f    r71.0<0;1,0>:f    r68.5<0;1,0>:f   {Compacted,F@2}
        mad (16|M0)              r31.0<1>:f    r36.0<0;0>:f      r31.0<1;0>:f      r35.0<0>:f       {Compacted}
        add (1|M0)               r71.0<1>:f    r71.0<0;1,0>:f    r68.6<0;1,0>:f   {Compacted,F@2}
        mov (8|M0)               r44.0<1>:hf   r33.0<1;1,0>:f                  
        add (1|M0)               r71.0<1>:f    r71.0<0;1,0>:f    r68.7<0;1,0>:f   {Compacted,F@2}
        mov (8|M0)               r44.8<1>:hf   r34.0<1;1,0>:f                  
        add (1|M0)               r71.0<1>:f    r71.0<0;1,0>:f    r69.0<0;1,0>:f   {Compacted,F@2}
        mov (8|M0)               r43.0<1>:hf   r31.0<1;1,0>:f                  
        add (1|M0)               r71.0<1>:f    r71.0<0;1,0>:f    r69.1<0;1,0>:f   {Compacted,F@2}
        mov (8|M0)               r43.8<1>:hf   r32.0<1;1,0>:f                  
        add (1|M0)               r71.0<1>:f    r71.0<0;1,0>:f    r69.2<0;1,0>:f   {Compacted,F@2}
        mov (8|M0)               r47.0<1>:f    r44.0<1;1,0>:hf                 
        add (1|M0)               r71.0<1>:f    r71.0<0;1,0>:f    r69.3<0;1,0>:f   {Compacted,F@2}
        mov (8|M0)               r48.0<1>:f    r44.8<1;1,0>:hf                 
        add (1|M0)               r71.0<1>:f    r71.0<0;1,0>:f    r69.4<0;1,0>:f   {Compacted,F@2}
        mov (8|M0)               r70.0<1>:f    r64.8<1;1,0>:hf                 
        add (1|M0)               r71.0<1>:f    r71.0<0;1,0>:f    r69.5<0;1,0>:f   {Compacted,F@2}
        mov (8|M0)               r45.0<1>:f    r43.0<1;1,0>:hf                 
        add (1|M0)               r71.0<1>:f    r71.0<0;1,0>:f    r69.6<0;1,0>:f   {Compacted,F@2}
        mov (8|M0)               r46.0<1>:f    r43.8<1;1,0>:hf                 
        sel (16|M0)   (ge)f0.0   acc0.0<1>:f   r47.0<1;1,0>:f    1.03125:f              
        add (1|M0)               r71.0<1>:f    r71.0<0;1,0>:f    r69.7<0;1,0>:f   {Compacted,F@3}
        sel (16|M0)   (ge)f0.0   acc2.0<1>:f   r45.0<1;1,0>:f    1.03125:f               {F@3}
        sel (16|M0)   (lt)f0.0   r47.0<1>:f    acc0.0<1;1,0>:f   0x3FC8E000:f              
        add (1|M0)               r71.0<1>:f    r71.0<0;1,0>:f    r70.0<0;1,0>:f   {Compacted,F@3}
        sel (16|M0)   (lt)f0.0   r45.0<1>:f    acc2.0<1;1,0>:f   0x3FC8E000:f              
        mov (8|M0)               r59.0<1>:ud   r47.0<2;1,0>:ud                  {F@3}
        mov (8|M0)               r74.0<1>:ud   r47.1<2;1,0>:ud                 
        add (1|M0)               r71.0<1>:f    r71.0<0;1,0>:f    r70.1<0;1,0>:f   {Compacted,F@2}
        mov (8|M0)               r57.0<1>:ud   r45.0<2;1,0>:ud                  {F@2}
        mov (8|M0)               r72.0<1>:ud   r45.1<2;1,0>:ud                 
        mov (8|M0)               r60.0<2>:hf   r59.0<1;1,0>:f                   {I@4}
        mov (8|M0)               r75.0<2>:hf   r74.0<1;1,0>:f                   {I@3}
        add (1|M0)               r71.0<1>:f    r71.0<0;1,0>:f    r70.2<0;1,0>:f   {Compacted,F@3}
        mov (8|M0)               r58.0<1>:hf   r57.0<1;1,0>:f                   {I@2}
        mov (8|M0)               r73.0<1>:hf   r72.0<1;1,0>:f                   {I@1}
        mov (8|M0)               r58.8<1>:uw   r60.0<2;1,0>:uw                  {F@5}
        mov (8|M0)               r73.8<1>:uw   r75.0<2;1,0>:uw                  {F@4}
        add (1|M0)               r71.0<1>:f    r71.0<0;1,0>:f    r70.3<0;1,0>:f   {Compacted,F@3}
        shl (16|M0)              r65.0<1>:d    r58.0<1;1,0>:uw   5:w               {A@2}
        mov (16|M0)              r76.0<1>:d    r73.0<1;1,0>:uw                  {A@2}
        add (1|M0)               r71.0<1>:f    r71.0<0;1,0>:f    r70.4<0;1,0>:f   {Compacted,F@1}
        add (16|M0)              r65.0<1>:d    r65.0<1;1,0>:d    2146992128:d               {I@2}
        shl (16|M0)              r76.0<1>:d    r76.0<1;1,0>:d    21:w               {Compacted,I@2}
        add (1|M0)               r71.0<1>:f    r71.0<0;1,0>:f    r70.5<0;1,0>:f   {Compacted,F@1}
        add (16|M0)              r65.0<1>:d    r65.0<1;1,0>:d    r76.0<1;1,0>:d   {Compacted,I@1}
        add (1|M0)               r71.0<1>:f    r71.0<0;1,0>:f    r70.6<0;1,0>:f   {Compacted,F@1}
        mov (8|M0)               r78.0<1>:f    r65.0<1;1,0>:hf                  {I@1}
        add (1|M0)               r71.0<1>:f    r71.0<0;1,0>:f    r70.7<0;1,0>:f   {Compacted,F@2}
        mov (8|M0)               r79.0<1>:f    r65.8<1;1,0>:hf                 
        add (1|M0)               r71.0<1>:f    r71.0<0;1,0>:f    r78.0<0;1,0>:f   {Compacted,F@2}
        mov (8|M0)               r80.0<1>:f    r66.0<1;1,0>:hf                 
        add (1|M0)               r71.0<1>:f    r71.0<0;1,0>:f    r78.1<0;1,0>:f   {Compacted,F@2}
        mov (8|M0)               r81.0<1>:f    r66.8<1;1,0>:hf                 
        add (1|M0)               r71.0<1>:f    r71.0<0;1,0>:f    r78.2<0;1,0>:f   {Compacted,F@2}
        mov (4|M0)               r36.0<1>:w    0x64206420:v                              
        add (1|M0)               r71.0<1>:f    r71.0<0;1,0>:f    r78.3<0;1,0>:f   {Compacted,F@1}
        mov (4|M0)               r37.0<4>:uw   r36.0<1;1,0>:uw                  {I@1}
        add (1|M0)               r71.0<1>:f    r71.0<0;1,0>:f    r78.4<0;1,0>:f   {Compacted,F@1}
        mov (4|M0)               r38.0<2>:d    r37.0<4;1,0>:w                   {I@1}
        add (1|M0)               r71.0<1>:f    r71.0<0;1,0>:f    r78.5<0;1,0>:f   {Compacted,F@1}
        shl (1|M0)               r32.0<1>:d    r112.0<0;1,0>:d   1:w               {Compacted}
        add (1|M0)               r71.0<1>:f    r71.0<0;1,0>:f    r78.6<0;1,0>:f   {Compacted,F@1}
        asr (4|M0)               r38.1<2>:d    r38.0<2;1,0>:d    31:w               {I@2}
        add (1|M0)               r71.0<1>:f    r71.0<0;1,0>:f    r78.7<0;1,0>:f   {Compacted,F@1}
        addc (1|M0)              r33.0<1>:ud   r3.4<0;1,0>:ud    r32.0<0;1,0>:ud  {AccWrEn,I@2}
        add (1|M0)               r71.0<1>:f    r71.0<0;1,0>:f    r79.0<0;1,0>:f   {Compacted,F@1}
        mov (4|M0)               r40.0<2>:ud   r38.0<2;1,0>:ud                  {I@2}
        add (1|M0)               r71.0<1>:f    r71.0<0;1,0>:f    r79.1<0;1,0>:f   {Compacted,F@1}
        mov (4|M0)               r40.1<2>:ud   r38.1<2;1,0>:ud                 
        add (1|M0)               r71.0<1>:f    r71.0<0;1,0>:f    r79.2<0;1,0>:f   {Compacted,F@1}
        mov (1|M0)               r34.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        add (1|M0)               r71.0<1>:f    r71.0<0;1,0>:f    r79.3<0;1,0>:f   {Compacted,F@1}
        addc (4|M0)              r41.0<1>:ud   r40.0<2;1,0>:ud   0x8:ud              {AccWrEn,I@2}
        add (1|M0)               r71.0<1>:f    r71.0<0;1,0>:f    r79.4<0;1,0>:f   {Compacted,F@1}
        mov (4|M0)               r42.0<1>:ud   acc0.0<1;1,0>:ud                
        add (1|M0)               r71.0<1>:f    r71.0<0;1,0>:f    r79.5<0;1,0>:f   {Compacted,F@1}
        addc (4|M0)              r43.0<1>:ud   r40.0<2;1,0>:ud   0x10:ud              {AccWrEn}
        add (1|M0)               r71.0<1>:f    r71.0<0;1,0>:f    r79.6<0;1,0>:f   {Compacted,F@1}
        mov (4|M0)               r44.0<1>:ud   acc0.0<1;1,0>:ud                
        add (1|M0)               r71.0<1>:f    r71.0<0;1,0>:f    r79.7<0;1,0>:f   {Compacted,F@1}
        addc (4|M0)              r47.0<1>:ud   r40.0<2;1,0>:ud   0x18:ud              {AccWrEn}
        add (1|M0)               r71.0<1>:f    r71.0<0;1,0>:f    r80.0<0;1,0>:f   {Compacted,F@1}
        shl (1|M0)               r30.0<1>:d    r112.1<0;1,0>:d   1:w               {Compacted}
        add (1|M0)               r71.0<1>:f    r71.0<0;1,0>:f    r80.1<0;1,0>:f   {Compacted,F@1}
        shr (1|M0)               r31.0<1>:ud   r112.0<0;1,0>:ud  0x1F:uw             
        add (1|M0)               r71.0<1>:f    r71.0<0;1,0>:f    r80.2<0;1,0>:f   {Compacted,F@1}
        mov (4|M0)               r48.0<1>:ud   acc0.0<1;1,0>:ud                
        add (1|M0)               r71.0<1>:f    r71.0<0;1,0>:f    r80.3<0;1,0>:f   {Compacted,F@1}
        addc (4|M0)              r49.0<1>:ud   r40.0<2;1,0>:ud   0x20:ud              {AccWrEn}
        add (1|M0)               r71.0<1>:f    r71.0<0;1,0>:f    r80.4<0;1,0>:f   {Compacted,F@1}
        or (1|M0)                r32.1<1>:d    r30.0<0;1,0>:d    r31.0<0;1,0>:d   {Compacted,I@3}
        add (1|M0)               r71.0<1>:f    r71.0<0;1,0>:f    r80.5<0;1,0>:f   {Compacted,F@1}
        mov (4|M0)               r50.0<1>:ud   acc0.0<1;1,0>:ud                
        add (1|M0)               r71.0<1>:f    r71.0<0;1,0>:f    r80.6<0;1,0>:f   {Compacted,F@1}
        addc (4|M0)              r53.0<1>:ud   r40.0<2;1,0>:ud   0x28:ud              {AccWrEn}
        add (1|M0)               r71.0<1>:f    r71.0<0;1,0>:f    r80.7<0;1,0>:f   {Compacted,F@1}
        mov (1|M0)               r35.0<1>:f    r33.0<0;1,0>:f                   {Compacted}
        add (1|M0)               r71.0<1>:f    r71.0<0;1,0>:f    r81.0<0;1,0>:f   {Compacted,F@2}
        add3 (1|M0)              r35.1<1>:d    r34.0<0;0>:d      r3.5<0;0>:d       r32.1<0>:d       {I@3}
        add (1|M0)               r71.0<1>:f    r71.0<0;1,0>:f    r81.1<0;1,0>:f   {Compacted,F@1}
        mov (4|M0)               r54.0<1>:ud   acc0.0<1;1,0>:ud                
        add (1|M0)               r71.0<1>:f    r71.0<0;1,0>:f    r81.2<0;1,0>:f   {Compacted,F@1}
        addc (4|M0)              r55.0<1>:ud   r40.0<2;1,0>:ud   0x30:ud              {AccWrEn}
        add (1|M0)               r71.0<1>:f    r71.0<0;1,0>:f    r81.3<0;1,0>:f   {Compacted,F@1}
        mov (4|M0)               r39.0<2>:d    r41.0<1;1,0>:d                  
        add (1|M0)               r71.0<1>:f    r71.0<0;1,0>:f    r81.4<0;1,0>:f   {Compacted,F@1}
        mov (8|M0)               r61.0<2>:f    r35.0<0;1,0>:f                   {Compacted}
        add (1|M0)               r71.0<1>:f    r71.0<0;1,0>:f    r81.5<0;1,0>:f   {Compacted,F@2}
        mov (4|M0)               r56.0<1>:ud   acc0.0<1;1,0>:ud                
        add (1|M0)               r71.0<1>:f    r71.0<0;1,0>:f    r81.6<0;1,0>:f   {Compacted,F@1}
        add3 (4|M0)              r39.1<2>:d    r42.0<1;0>:d      r40.1<4;2>:d      0:w              
        add (1|M0)               r71.0<1>:f    r71.0<0;1,0>:f    r81.7<0;1,0>:f   {Compacted,F@1}
        mov (8|M0)               r61.1<2>:f    r35.1<0;1,0>:f                   {Compacted,I@6}
        mov (1|M0)               r82.0<2>:hf   r71.0<0;1,0>:f                   {F@2}
        addc (4|M0)              r59.0<1>:ud   r40.0<2;1,0>:ud   0x38:ud              {AccWrEn}
        sync.nop                             null                             {Compacted,F@1}
        math.inv (8|M0)          r83.0<1>:hf   r82.0<0;1,0>:hf                  {$6}
        mov (1|M0)               r82.0<1>:hf   r83.0<0;1,0>:hf                  {$6.dst}
        mov (4|M0)               r45.0<2>:d    r43.0<1;1,0>:d                  
        mov (1|M0)               r84.0<1>:f    r82.0<0;1,0>:hf                  {F@1}
        mov (4|M0)               r46.0<2>:d    r47.0<1;1,0>:d                  
        mul (16|M0)              r67.0<1>:f    r84.0<0;1,0>:f    r67.0<1;1,0>:f   {Compacted,F@1}
        mul (16|M0)              r69.0<1>:f    r84.0<0;1,0>:f    r69.0<1;1,0>:f   {Compacted}
        mov (8|M0)               r85.0<1>:hf   r67.0<1;1,0>:f                   {F@2}
        mov (8|M0)               r85.8<1>:hf   r68.0<1;1,0>:f                  
        mov (8|M0)               r86.0<1>:hf   r69.0<1;1,0>:f                   {F@3}
        mov (8|M0)               r86.8<1>:hf   r70.0<1;1,0>:f                  
        mov (8|M0)               r87.0<1>:f    (abs)r85.0<1;1,0>:hf             {F@4}
        mov (8|M0)               r88.0<1>:f    (abs)r85.8<1;1,0>:hf             {F@4}
        mul (16|M0)              r78.0<1>:f    r84.0<0;1,0>:f    r78.0<1;1,0>:f   {Compacted}
        mul (16|M0)              r80.0<1>:f    r84.0<0;1,0>:f    r80.0<1;1,0>:f   {Compacted}
        mov (8|M0)               r89.0<1>:f    (abs)r86.0<1;1,0>:hf             {F@6}
        mov (8|M0)               r90.0<1>:f    (abs)r86.8<1;1,0>:hf             {F@6}
        sel (16|M0)   (lt)f0.0   r87.0<1>:f    r87.0<1;1,0>:f    448.0:f               {Compacted,F@5}
        mov (4|M0)               r60.0<1>:ud   acc0.0<1;1,0>:ud                
        add3 (4|M0)              r45.1<2>:d    r44.0<1;0>:d      r40.1<4;2>:d      0:w              
        add3 (4|M0)              r46.1<2>:d    r48.0<1;0>:d      r40.1<4;2>:d      0:w              
        mov (8|M0)               r4.0<1>:hf    r78.0<1;1,0>:f                   {F@5}
        mov (8|M0)               r4.8<1>:hf    r79.0<1;1,0>:f                  
        mov (8|M0)               r5.0<1>:hf    r80.0<1;1,0>:f                   {F@6}
        mov (8|M0)               r5.8<1>:hf    r81.0<1;1,0>:f                  
        sel (16|M0)   (lt)f0.0   r89.0<1>:f    r89.0<1;1,0>:f    448.0:f               {Compacted,F@6}
        shr (16|M0)              r91.0<1>:ud   r87.0<1;1,0>:ud   0x17:uw              {F@6}
        addc (8|M0)              r63.0<1>:ud   r61.0<2;1,0>:ud   r38.0<2;1,0>:ud  {AccWrEn,Compacted,I@7}
        mov (4|M0)               r51.0<2>:d    r49.0<1;1,0>:d                  
        mov (4|M0)               r52.0<2>:d    r53.0<1;1,0>:d                  
        mov (8|M0)               r6.0<1>:f     (abs)r4.0<1;1,0>:hf              {F@5}
        mov (8|M0)               r7.0<1>:f     (abs)r4.8<1;1,0>:hf              {F@5}
        mov (8|M0)               r8.0<1>:f     (abs)r5.0<1;1,0>:hf              {F@5}
        mov (8|M0)               r9.0<1>:f     (abs)r5.8<1;1,0>:hf              {F@5}
        shr (16|M0)              r93.0<1>:ud   r89.0<1;1,0>:ud   0x17:uw              {F@5}
        sel (16|M0)   (ge)f0.0   r95.0<2>:ub   r91.0<4;1,0>:ub   0x79:uw              {I@5}
        add3 (4|M0)              r51.1<2>:d    r50.0<1;0>:d      r40.1<4;2>:d      0:w              
        mov (8|M0)               r64.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        add3 (4|M0)              r52.1<2>:d    r54.0<1;0>:d      r40.1<4;2>:d      0:w              
        addc (8|M0)              r71.0<1>:ud   r61.0<2;1,0>:ud   r45.0<2;1,0>:ud  {AccWrEn,Compacted}
        mov (4|M0)               r57.0<2>:d    r55.0<1;1,0>:d                  
        mov (4|M0)               r58.0<2>:d    r59.0<1;1,0>:d                  
        sel (16|M0)   (lt)f0.0   r6.0<1>:f     r6.0<1;1,0>:f     448.0:f               {Compacted,F@3}
        sel (16|M0)   (lt)f0.0   r8.0<1>:f     r8.0<1;1,0>:f     448.0:f               {Compacted,F@2}
        sel (16|M0)   (ge)f0.0   r96.0<2>:ub   r93.0<4;1,0>:ub   0x79:uw              {I@7}
        mov (16|M0)              r97.0<1>:d    r95.0<2;1,0>:ub                  {I@7}
        add3 (4|M0)              r57.1<2>:d    r56.0<1;0>:d      r40.1<4;2>:d      0:w              
        mov (8|M0)               r72.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        add3 (4|M0)              r58.1<2>:d    r60.0<1;0>:d      r40.1<4;2>:d      0:w              
        addc (8|M0)              r75.0<1>:ud   r61.0<2;1,0>:ud   r51.0<2;1,0>:ud  {AccWrEn,Compacted,I@7}
        shr (16|M0)              r10.0<1>:ud   r6.0<1;1,0>:ud    0x17:uw              {F@2}
        shr (16|M0)              r12.0<1>:ud   r8.0<1;1,0>:ud    0x17:uw              {F@1}
        mov (16|M0)              r99.0<1>:d    r96.0<2;1,0>:ub                  {I@7}
        shl (16|M0)              r97.0<1>:d    r97.0<1;1,0>:d    23:w               {Compacted,I@7}
        mov (8|M0)               r76.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        addc (8|M0)              r83.0<1>:ud   r61.0<2;1,0>:ud   r57.0<2;1,0>:ud  {AccWrEn,Compacted,I@7}
        sel (16|M0)   (ge)f0.0   r14.0<2>:ub   r10.0<4;1,0>:ub   0x79:uw              {I@6}
        sel (16|M0)   (ge)f0.0   r15.0<2>:ub   r12.0<4;1,0>:ub   0x79:uw              {I@6}
        shl (16|M0)              r99.0<1>:d    r99.0<1;1,0>:d    23:w               {Compacted,I@6}
        add (16|M0)              r101.0<1>:d   r97.0<1;1,0>:d    -25165824:d               {I@6}
        mov (8|M0)               r84.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        add (16|M0)              r97.0<1>:d    -r97.0<1;1,0>:d   -2139095040:d              
        addc (1|M0)              r91.0<1>:ud   r35.0<0;1,0>:ud   0x40:ud              {AccWrEn}
        mov (16|M0)              r16.0<1>:d    r14.0<2;1,0>:ub                  {I@7}
        mov (16|M0)              r18.0<1>:d    r15.0<2;1,0>:ub                  {I@7}
        add (16|M0)              r103.0<1>:d   r99.0<1;1,0>:d    -25165824:d               {I@7}
        mul (16|M0)              acc2.0<1>:f   r87.0<1;1,0>:f    r97.0<1;1,0>:f   {Compacted,I@5}
        mov (1|M0)               r92.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        add (16|M0)              r99.0<1>:d    -r99.0<1;1,0>:d   -2139095040:d              
        mov (1|M0)               r93.0<1>:f    r91.0<0;1,0>:f                   {Compacted,I@6}
        shl (16|M0)              r16.0<1>:d    r16.0<1;1,0>:d    23:w               {Compacted,I@5}
        shl (16|M0)              r18.0<1>:d    r18.0<1;1,0>:d    23:w               {Compacted,I@5}
        rnde (16|M0)             acc0.0<1>:f   acc2.0<1;1,0>:f                  {I@4}
        add3 (1|M0)              r93.1<1>:d    r92.0<0;0>:d      r35.1<0;0>:d      0:w              
        mul (16|M0)              acc2.0<1>:f   r89.0<1;1,0>:f    r99.0<1;1,0>:f   {Compacted,I@4}
        cmp (16|M0)   (lt)f0.1   null<1>:f     r67.0<1;1,0>:f    0xB3000000:f              
        mov (8|M0)               r94.0<2>:f    r93.0<0;1,0>:f                   {Compacted,F@4}
        add (16|M0)              r20.0<1>:d    r16.0<1;1,0>:d    -25165824:d               {I@3}
        add (16|M0)              r22.0<1>:d    r18.0<1;1,0>:d    -25165824:d               {I@3}
        mul (16|M0)              acc0.0<1>:f   acc0.0<1;1,0>:f   r101.0<1;1,0>:f  {Compacted}
        rnde (16|M0)             acc2.0<1>:f   acc2.0<1;1,0>:f                 
        mov (8|M0)               r94.1<2>:f    r93.1<0;1,0>:f                   {Compacted,I@3}
        add (16|M0)              r16.0<1>:d    -r16.0<1;1,0>:d   -2139095040:d              
        add (16|M0)              r18.0<1>:d    -r18.0<1;1,0>:d   -2139095040:d              
        cmp (16|M0)   (lt)f0.0   null<1>:f     r69.0<1;1,0>:f    0xB3000000:f               {Compacted}
        mov (16|M0)              r105.0<1>:f   (abs)acc0.0<1;1,0>:f             {Compacted}
        mul (16|M0)              r107.0<1>:f   acc2.0<1;1,0>:f   r103.0<1;1,0>:f  {Compacted}
        addc (8|M0)              r96.0<1>:ud   r94.0<2;1,0>:ud   r38.0<2;1,0>:ud  {AccWrEn,Compacted,A@2}
        mul (16|M0)              acc2.0<1>:f   r6.0<1;1,0>:f     r16.0<1;1,0>:f   {Compacted,I@3}
        mul (16|M0)              r8.0<1>:f     r8.0<1;1,0>:f     r18.0<1;1,0>:f   {Compacted,I@2}
(f0.1)  or (16|M0)               r105.0<1>:d   r105.0<1;1,0>:d   -2147483648:d              
        mov (16|M0)              r107.0<1>:f   (abs)r107.0<1;1,0>:f             {Compacted,F@3}
        mov (8|M0)               r97.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        rnde (16|M0)             r6.0<1>:f     acc2.0<1;1,0>:f                  {Compacted}
        rnde (16|M0)             r8.0<1>:f     r8.0<1;1,0>:f                    {Compacted,F@3}
        addc (8|M0)              r103.0<1>:ud  r94.0<2;1,0>:ud   r45.0<2;1,0>:ud  {AccWrEn,Compacted}
        cmp (16|M0)   (lt)f1.1   null<1>:f     r78.0<1;1,0>:f    0xB3000000:f              
        cmp (16|M0)   (lt)f1.0   null<1>:f     r80.0<1;1,0>:f    0xB3000000:f               {Compacted}
        mov (8|M0)               r109.8<1>:hf  r106.0<1;1,0>:f                  {I@3}
(f0.0)  or (16|M0)               r107.0<1>:d   r107.0<1;1,0>:d   -2147483648:d               {F@6}
        mul (16|M0)              acc2.0<1>:f   r6.0<1;1,0>:f     r20.0<1;1,0>:f   {Compacted,F@5}
        mul (16|M0)              r26.0<1>:f    r8.0<1;1,0>:f     r22.0<1;1,0>:f   {Compacted,F@5}
        mov (8|M0)               r104.0<1>:ud  acc0.0<1;1,0>:ud                 {Compacted}
        addc (8|M0)              r106.0<1>:ud  r94.0<2;1,0>:ud   r51.0<2;1,0>:ud  {AccWrEn,Compacted,F@3}
        mov (8|M0)               r110.0<1>:hf  r107.0<1;1,0>:f                  {I@3}
        mov (16|M0)              r24.0<1>:f    (abs)acc2.0<1;1,0>:f             {Compacted}
        mov (16|M0)              r26.0<1>:f    (abs)r26.0<1;1,0>:f              {Compacted,F@3}
        mov (8|M0)               r107.0<1>:ud  acc0.0<1;1,0>:ud                 {Compacted,F@3}
        addc (8|M0)              r5.0<1>:ud    r94.0<2;1,0>:ud   r57.0<2;1,0>:ud  {AccWrEn,Compacted}
        mov (8|M0)               r73.0<1>:d    r45.1<2;1,0>:d                  
        mov (8|M0)               r85.0<1>:d    r57.1<2;1,0>:d                  
        mov (8|M0)               r69.0<1>:d    r38.1<2;1,0>:d                  
        mov (8|M0)               r81.0<1>:d    r51.1<2;1,0>:d                  
(f1.1)  or (16|M0)               r24.0<1>:d    r24.0<1;1,0>:d    -2147483648:d               {F@2}
(f1.0)  or (16|M0)               r26.0<1>:d    r26.0<1;1,0>:d    -2147483648:d               {F@1}
        mov (8|M0)               r6.0<1>:ud    acc0.0<1;1,0>:ud                 {Compacted}
        mov (8|M0)               r109.0<1>:hf  r105.0<1;1,0>:f                 
        mov (8|M0)               r110.8<1>:hf  r108.0<1;1,0>:f                 
        add3 (8|M0)              r74.0<1>:d    r72.0<1;0>:d      r61.1<4;2>:d      r73.0<1>:d       {I@7}
        add3 (8|M0)              r86.0<1>:d    r84.0<1;0>:d      r61.1<4;2>:d      r85.0<1>:d       {I@7}
        add3 (8|M0)              r70.0<1>:d    r64.0<1;0>:d      r61.1<4;2>:d      r69.0<1>:d       {I@7}
        add3 (8|M0)              r102.0<1>:d   r97.0<1;0>:d      r94.1<4;2>:d      r69.0<1>:d      
        add3 (8|M0)              r82.0<1>:d    r76.0<1;0>:d      r61.1<4;2>:d      r81.0<1>:d       {I@7}
        add3 (8|M0)              r4.0<1>:d     r107.0<1;0>:d     r94.1<4;2>:d      r81.0<1>:d      
        mov (8|M0)               r28.0<1>:hf   r24.0<1;1,0>:f                   {I@7}
        mov (8|M0)               r28.8<1>:hf   r25.0<1;1,0>:f                  
        mov (8|M0)               r29.0<1>:hf   r26.0<1;1,0>:f                   {I@7}
        mov (8|M0)               r29.8<1>:hf   r27.0<1;1,0>:f                  
        add3 (8|M0)              r105.0<1>:d   r104.0<1;0>:d     r94.1<4;2>:d      r73.0<1>:d       {F@6}
        add3 (8|M0)              r7.0<1>:d     r6.0<1;0>:d       r94.1<4;2>:d      r85.0<1>:d       {I@7}
        mov (8|M0)               r65.0<2>:d    r63.0<1;1,0>:d                  
        mov (8|M0)               r67.0<2>:d    r71.0<1;1,0>:d                  
        mov (8|M0)               r98.0<2>:d    r96.0<1;1,0>:d                  
        mov (8|M0)               r100.0<2>:d   r103.0<1;1,0>:d                 
        mov (8|M0)               r77.0<2>:d    r75.0<1;1,0>:d                  
        mov (8|M0)               r79.0<2>:d    r83.0<1;1,0>:d                  
        mov (16|M0)              r87.0<1>:d    r109.0<1;1,0>:uw                
        mov (16|M0)              r89.0<1>:d    r110.0<1;1,0>:uw                 {F@5}
        mov (16|M0)              r8.0<1>:d     r28.0<1;1,0>:uw                  {A@3}
        mov (16|M0)              r10.0<1>:d    r29.0<1;1,0>:uw                  {A@1}
        mov (8|M0)               r65.1<2>:d    r70.0<1;1,0>:d                  
        mov (8|M0)               r67.1<2>:d    r74.0<1;1,0>:d                  
        mov (8|M0)               r98.1<2>:d    r102.0<1;1,0>:d                 
        mov (8|M0)               r100.1<2>:d   r105.0<1;1,0>:d                 
        mov (8|M0)               r77.1<2>:d    r82.0<1;1,0>:d                  
        mov (8|M0)               r79.1<2>:d    r86.0<1;1,0>:d                  
        mov (8|M0)               r108.0<2>:d   r106.0<1;1,0>:d                 
        mov (8|M0)               r110.0<2>:d   r5.0<1;1,0>:d                   
        mov (8|M0)               r108.1<2>:d   r4.0<1;1,0>:d                   
        mov (8|M0)               r110.1<2>:d   r7.0<1;1,0>:d                   
        send.ugm (16|M0)         null     r65     r87:2   0x0            0x08000B84           {A@7,$7} // wr:4+2, rd:0; store.ugm.d16u32.a64
        send.ugm (16|M0)         null     r77     r89:2   0x0            0x08000B84           {A@5,$8} // wr:4+2, rd:0; store.ugm.d16u32.a64
        send.ugm (16|M0)         null     r98     r8:2    0x0            0x08000B84           {$9} // wr:4+2, rd:0; store.ugm.d16u32.a64
        send.ugm (16|M0)         null     r108    r10:2   0x0            0x08000B84           {A@1,$10} // wr:4+2, rd:0; store.ugm.d16u32.a64
(W)     send.ugm (1|M0)          r12      r0      null:0  0x0            0x0210641F           {$11} // wr:1+0, rd:1; fence invalid flush type scoped to tile
(W)     mov (8|M0)               null<1>:ud    r12.0<1;1,0>:ud                  {$11.dst}
(W)     send.gtwy (1|M0)         null     r127    null:0  0x0            0x02000010           {EOT,A@1} // wr:1+0, rd:0; end of thread
L5472:
        mov (1|M0)               r1.2<1>:d     cr0.0<0;1,0>:ud                  {A@1}
        and (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   -1265:w               {A@1}
        or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   1264:w               {A@1}
        mov (1|M0)               r2.3<1>:f     r3.3<0;1,0>:ud                   {Compacted,A@1}
        mov (1|M0)               r8.0<1>:f     0xB4C00000:f                               {Compacted}
        math.inv (1|M0)          r7.0<1>:f     r2.3<0;1,0>:f                    {@2,$12}
        mov (1|M0)               r4.1<1>:f     r112.5<0;1,0>:ud                
        sync.nop                             null                             {Compacted,$12.dst}
        mad (1|M0)               r7.0<1>:f     r7.0<0;0>:f       r8.0<0;0>:f       r7.0<0>:f        {F@2}
        mov (1|M0)               r112.4<1>:ud  r2.3<0;1,0>:f                   
        mov (1|M0)               r5.0<1>:ud    r4.1<0;1,0>:f                    {F@2}
        mul (1|M0)               r9.0<1>:f     r7.0<0;1,0>:f     r4.1<0;1,0>:f    {Compacted,F@1}
        add (1|M0)               r112.4<1>:ud  r3.3<0;1,0>:ud    -r112.4<0;1,0>:ud {I@2}
        add (1|M0)               r5.0<1>:ud    r112.5<0;1,0>:ud  -r5.0<0;1,0>:ud  {Compacted,I@2}
        mov (1|M0)               r10.0<1>:ud   r9.0<0;1,0>:f                    {F@1}
        mov (1|M0)               r4.0<1>:f     r112.4<0;1,0>:ud                 {Compacted,I@3}
        mov (1|M0)               r6.0<1>:f     r5.0<0;1,0>:ud                   {Compacted,I@2}
        mov (1|M0)               r11.0<1>:f    r10.0<0;1,0>:ud                  {Compacted,I@1}
        mad (1|M0)               r4.1<1>:f     r4.1<0;0>:f       r11.0<0;0>:f      -r2.3<0>:f       {F@1}
        mad (1|M0)               r11.0<1>:f    r6.0<0;0>:f       r11.0<0;0>:f      -r4.0<0>:f      
        add (1|M0)               r4.1<1>:f     r4.1<0;1,0>:f     r11.0<0;1,0>:f   {Compacted,F@1}
        mul (1|M0)               r7.0<1>:f     r7.0<0;1,0>:f     r4.1<0;1,0>:f    {Compacted,F@1}
        mov (1|M0)               r12.0<1>:ud   r7.0<0;1,0>:f                    {F@1}
        add (1|M0)               r10.0<1>:ud   r10.0<0;1,0>:ud   r12.0<0;1,0>:ud  {Compacted,I@1}
(W)     mul (1|M0)               acc0.0<1>:ud  r10.0<0;1,0>:ud   r3.6<0;1,0>:uw   {I@1}
        mach (1|M0)              r10.0<1>:ud   r10.0<0;1,0>:ud   r3.3<0;1,0>:ud   {Compacted}
        add (1|M0)               r112.5<1>:ud  r112.5<0;1,0>:ud  -r10.0<0;1,0>:ud {I@1}
        cmp (1|M0)    (lt)f0.1   null<1>:ud    r112.5<0;1,0>:ud  r3.3<0;1,0>:ud   {I@1}
(f0.1)  mov (1|M0)               r3.3<1>:d     0:w                              
        add (1|M0)               r112.2<1>:ud  r112.5<0;1,0>:ud  -r3.3<0;1,0>:ud  {I@1}
        mov (1|M0)               cr0.0<1>:ud   r1.2<0;1,0>:d                    {A@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        ret (16|M0)                          r112.6                           {A@1}
L5920:
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
