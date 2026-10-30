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
        mov (1|M0)               r45.0<1>:d    r0.1<0;1,0>:ud                   {A@1}
        mov (1|M0)               r86.5<1>:d    r2.6<0;1,0>:d                    {$1.dst}
(W)     mul (1|M0)               acc0.0<1>:d   r45.0<0;1,0>:d    r2.0<0;1,0>:uw   {Compacted,I@2}
        mach (1|M0)              r45.0<1>:d    r45.0<0;1,0>:d    r2.0<0;1,0>:d    {Compacted}
        sync.nop                             null                             {Compacted,$0.dst}
        add (1|M0)               r45.0<1>:d    r45.0<0;1,0>:d    r1.0<0;1,0>:uw   {I@1}
        mov (1|M0)               r86.4<1>:d    r45.0<0;1,0>:d                   {I@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r86.6         L7680                                 {A@1}
L344:
        cmp (1|M0)    (gt)f0.0   null<1>:d     r2.7<0;1,0>:d     0:w              
        mov (16|M0)              r47.0<1>:ud   0x0:ud                             
        mov (16|M0)              r49.0<1>:ud   0x0:ud                             
(W)     and (1|M0)               f0.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
        mov (16|M0)              r51.0<1>:ud   0x0:ud                             
        mov (16|M0)              r53.0<1>:ud   0x0:ud                             
        mov (16|M0)              r55.0<1>:ud   0x0:ud                             
        mov (16|M0)              r57.0<1>:ud   0x0:ud                             
        mov (16|M0)              r59.0<1>:ud   0x0:ud                             
        mov (16|M0)              r61.0<1>:ud   0x0:ud                             
        mov (16|M0)              r63.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r65.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r67.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r69.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r71.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r73.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r75.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r77.0<1>:f    0.0:f                               {Compacted}
(~f0.1.any16h) goto (16|M0)                  L1536                  L1536                
L584:
(W)     mul (1|M0)               acc0.0<1>:d   r45.1<0;1,0>:d    r2.14<0;1,0>:uw 
        mach (1|M0)              r4.0<1>:d     r45.1<0;1,0>:d    r2.7<0;1,0>:d   
(W)     mul (1|M0)               acc0.0<1>:d   r45.1<0;1,0>:d    r2.14<0;1,0>:uw 
        mov (1|M0)               r45.2<1>:d    r2.7<0;1,0>:d                   
        mov (1|M0)               r45.3<1>:d    0:w                              
        mov (1|M0)               r45.4<2>:f    0.0:f                              
        mov (1|M0)               r45.5<2>:f    0.0:f                              
        mach (1|M0)              r46.0<1>:d    r45.1<0;1,0>:d    r2.7<0;1,0>:d   
        asr (1|M0)               r46.1<1>:d    r4.0<0;1,0>:d     31:w               {Compacted,I@5}
L720:
        addc (1|M0)              r4.0<1>:ud    r45.4<0;1,0>:ud   r46.0<0;1,0>:ud  {AccWrEn,A@2}
        shl (1|M0)               r6.0<1>:d     r4.0<0;1,0>:d     8:w               {Compacted,I@1}
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        shl (1|M0)               r7.0<1>:d     r6.0<0;1,0>:d     1:w               {Compacted,I@2}
        add3 (1|M0)              r1.3<1>:d     r5.0<0;0>:d       r45.5<0;0>:d      r46.1<0>:d       {A@1}
        addc (1|M0)              r8.0<1>:ud    r3.0<0;1,0>:ud    r7.0<0;1,0>:ud   {AccWrEn,I@2}
        add (1|M0)               r5.0<1>:d     r45.4<0;1,0>:d    -r45.1<0;1,0>:d 
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r5.0<0;1,0>:d     r2.12<0;1,0>:uw  {Compacted,I@2}
        mach (1|M0)              r5.0<1>:d     r5.0<0;1,0>:d     r2.6<0;1,0>:d    {Compacted}
        shr (1|M0)               r2.4<1>:ud    r4.0<0;1,0>:ud    0x18:uw             
        shl (1|M0)               r2.3<1>:d     r1.3<0;1,0>:d     8:w               {Compacted}
        add (1|M0)               r1.2<1>:d     r5.0<0;1,0>:d     r45.0<0;1,0>:d   {Compacted,I@3}
        add (1|M0)               r1.3<1>:d     r5.0<0;1,0>:d     r45.0<0;1,0>:d   {Compacted}
        or (1|M0)                r6.1<1>:d     r2.3<0;1,0>:d     r2.4<0;1,0>:d    {I@3}
        asr (1|M0)               r1.4<1>:d     r1.2<0;1,0>:d     31:w               {I@3}
        shl (1|M0)               r4.0<1>:d     r1.3<0;1,0>:d     8:w               {Compacted,I@3}
        shr (1|M0)               r6.3<1>:ud    r6.0<0;1,0>:ud    0x1F:uw             
        shr (1|M0)               r2.4<1>:ud    r1.3<0;1,0>:ud    0x18:uw             
        shl (1|M0)               r6.2<1>:d     r6.1<0;1,0>:d     1:w               {I@5}
        shl (1|M0)               r2.3<1>:d     r1.4<0;1,0>:d     8:w               {I@5}
        shl (1|M0)               r6.0<1>:d     r4.0<0;1,0>:d     1:w               {Compacted,I@5}
        mov (1|M0)               r10.0<1>:f    r8.0<0;1,0>:f                    {Compacted}
        or (1|M0)                r7.1<1>:d     r6.2<0;1,0>:d     r6.3<0;1,0>:d    {I@3}
        or (1|M0)                r4.1<1>:d     r2.3<0;1,0>:d     r2.4<0;1,0>:d    {I@3}
        addc (1|M0)              r7.0<1>:ud    r3.2<0;1,0>:ud    r6.0<0;1,0>:ud   {AccWrEn,I@3}
        shr (1|M0)               r4.3<1>:ud    r4.0<0;1,0>:ud    0x1F:uw             
        add3 (1|M0)              r10.1<1>:d    r9.0<0;0>:d       r3.1<0;0>:d       r7.1<0>:d        {I@4}
        shl (1|M0)               r4.2<1>:d     r4.1<0;1,0>:d     1:w               {I@4}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,F@1}
        mov (1|M0)               r5.0<1>:f     r7.0<0;1,0>:f                    {Compacted,I@5}
        addc (1|M0)              r9.0<1>:ud    r10.0<0;1,0>:ud   0x100:ud              {AccWrEn}
        or (1|M0)                r6.1<1>:d     r4.2<0;1,0>:d     r4.3<0;1,0>:d    {I@3}
        mov (1|M0)               r19.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r4.0<1>:ud    r5.0<0;1,0>:ud    0x100:ud              {AccWrEn,F@1}
        add3 (1|M0)              r5.1<1>:d     r8.0<0;0>:d       r3.3<0;0>:d       r6.1<0>:d        {I@3}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r20.0<1>:f    r9.0<0;1,0>:f                    {Compacted}
        add3 (1|M0)              r20.1<1>:d    r19.0<0;0>:d      r10.1<0;0>:d      0:w               {I@4}
        mov (1|M0)               r7.0<1>:f     r4.0<0;1,0>:f                    {Compacted,I@4}
        add3 (1|M0)              r7.1<1>:d     r6.0<0;0>:d       r5.1<0;0>:d       0:w               {I@2}
        sync.nop                             null                             {Compacted,$2.src}
        send.ugm (1|M0)          r11      r10     null:0  0x0            0x0280E780           {$3} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        send.ugm (1|M0)          r29      r5      null:0  0x0            0x0280E780           {$4} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        send.ugm (1|M0)          r21      r20     null:0  0x0            0x0280E780           {A@2,$5} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        send.ugm (1|M0)          r37      r7      null:0  0x0            0x0280E780           {A@1,$6} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        addc (1|M0)              r8.0<1>:ud    r45.4<0;1,0>:ud   0x1:ud              {AccWrEn}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r45.6<1>:d    r8.0<0;1,0>:d                    {I@2}
        add3 (1|M0)              r45.7<1>:d    r9.0<0;0>:d       r45.5<0;0>:d      0:w               {I@2}
        cmp (1|M0)    (eq)f1.0   null<1>:d     r45.7<0;1,0>:d    r45.3<0;1,0>:d   {I@1}
(f1.0)  cmp (1|M0)    (eq)f1.0   null<1>:d     r45.6<0;1,0>:d    r45.2<0;1,0>:d  
(W)     and (1|M0)               f0.0<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
        sync.allwr                           ($2,$3,$4,$5,$6)                
        dpas.8x8 (8|M0)          r71:f         r71:f             r29:hf            r11.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r55:f         r55:f             r29:hf            r21.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r63:f         r63:f             r37:hf            r11.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r47:f         r47:f             r37:hf            r21.0:hf         {$2}
(f0.0.any16h) goto (16|M0)                   L1536                  L1536                
L1504:
(W)     mov (2|M0)               r45.4<1>:ud   r45.6<1;1,0>:ud                 
        goto.b (16|M0)                       L1536                  L720                
L1536:
        join (16|M0)                         L1552                                
L1552:
        shl (1|M0)               r1.2<1>:d     r45.0<0;1,0>:d    1:w               {Compacted}
        shl (1|M0)               r45.1<1>:d    r45.1<0;1,0>:d    4:w               {Compacted}
        asr (1|M0)               r1.4<1>:d     r1.2<0;1,0>:d     31:w               {I@2}
        shl (1|M0)               r4.0<1>:d     r1.2<0;1,0>:d     7:w               {Compacted}
        shr (1|M0)               r2.4<1>:ud    r1.2<0;1,0>:ud    0x19:uw             
        shl (1|M0)               r2.3<1>:d     r1.4<0;1,0>:d     7:w               {I@3}
        shl (1|M0)               r5.0<1>:d     r4.0<0;1,0>:d     1:w               {Compacted,I@3}
        or (1|M0)                r4.1<1>:d     r2.3<0;1,0>:d     r2.4<0;1,0>:d    {I@2}
        addc (1|M0)              r6.0<1>:ud    r3.4<0;1,0>:ud    r5.0<0;1,0>:ud   {AccWrEn,I@2}
        shr (1|M0)               r4.3<1>:ud    r4.0<0;1,0>:ud    0x1F:uw             
        shl (1|M0)               r4.2<1>:d     r4.1<0;1,0>:d     1:w               {I@3}
        mov (1|M0)               r46.2<1>:d    r6.0<0;1,0>:d                    {I@3}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        or (1|M0)                r5.1<1>:d     r4.2<0;1,0>:d     r4.3<0;1,0>:d    {I@3}
        addc (1|M0)              r8.0<1>:ud    r46.2<0;1,0>:ud   0x100:ud              {AccWrEn,I@3}
        mov (8|M0)               r4.0<1>:uw    0xECA86420:uv                             
        add3 (1|M0)              r46.3<1>:d    r7.0<0;0>:d       r3.5<0;0>:d       r5.1<0>:d        {I@3}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        sync.nop                             null                             {Compacted,$2.src}
        mov (8|M0)               r10.0<4>:uw   r4.0<1;1,0>:uw                   {I@3}
        and (1|M0)               r46.4<1>:d    r3.7<0;1,0>:d     -2:w              
        and (1|M0)               r46.5<1>:d    r3.7<0;1,0>:d     -3:w              
        mov (1|M0)               r81.0<2>:f    0.0:f                              
        mov (1|M0)               r81.1<2>:f    0.0:f                              
        mov (1|M0)               r81.2<1>:d    0:w                              
        mov (1|M0)               r46.6<1>:d    r8.0<0;1,0>:d                   
        add3 (1|M0)              r46.7<1>:d    r9.0<0;0>:d       r46.3<0;0>:d      0:w               {I@6}
        mov (8|M0)               r79.0<2>:ud   r10.0<4;1,0>:uw                  {I@6}
        mov (8|M0)               r79.1<2>:ud   0.0:f                              
L1960:
        or (1|M0)                r1.2<1>:d     r45.1<0;1,0>:d    r81.0<0;1,0>:d   {F@2}
        cmp (1|M0)    (eq)f0.0   null<1>:d     r3.7<0;1,0>:d     4:w              
        cmp (1|M0)    (lt)f1.1   null<1>:ud    r1.2<0;1,0>:ud    r3.6<0;1,0>:ud   {I@2}
        cmp (1|M0)    (eq)f0.1   null<1>:d     r46.5<0;1,0>:d    1:w              
(W)     mov (1|M0)               r84.13<1>:uw  f0.0<0;1,0>:uw                  
(W)     and (1|M0)               f1.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
        cmp (1|M0)    (eq)f0.0   null<1>:d     r46.4<0;1,0>:d    2:w              
(f1.1.any16h) goto (16|M0)                   L2136                  L2136                
L2088:
        mov (8|M0)               r81.6<1>:uw   0x0:uw                             
        mov (8|M0)               r82.0<1>:hf   0.0:hf                             
        goto (16|M0)                         L2136                  L4296                
L2136:
        join (16|M0)                         L4296                                
L2152:
        shl (1|M0)               r81.14<1>:w   r81.4<0;1,0>:w    5:w              
        mov (1|M0)               r82.4<1>:d    0:w                              
L2184:
        mad (1|M0)               r1.3<1>:w     r81.14<0;0>:w     r82.8<0;0>:w      4:w               {I@1}
(W)     and (1|M0)               f1.0<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0x8E0:uw              {A@1}
        mov (1|M0)               r82.5<1>:f    r[a0.0]<0;1,0>:f                 {$2.dst}
(~f1.0.any16h) goto (16|M0)                  L2504                  L2504                 {A@1}
L2264:
        mov (1|M0)               r1.4<2>:hf    r[a0.0]<0;1,0>:f                
        cmp (1|M0)    (lt)f1.1   null<1>:f     r[a0.0]<0;1,0>:f  -4.001953e+00:f               {A@1}
        mov (1|M0)               r1.3<1>:f     r1.4<0;1,0>:hf                   {A@1}
        mov (1|M0)               r2.4<1>:ud    0xBD650000:ud                             
        sel (1|M0)    (lt)f0.0   r1.3<1>:f     r1.3<0;1,0>:f     4.0:f               {F@1}
        mov (1|M0)               r2.5<1>:ud    0x3EE50000:ud                             
(~f1.1) sel (1|M0)               r2.3<1>:f     r1.3<0;1,0>:f     -4.0:f               {F@1}
        mov (1|M0)               r5.1<1>:ud    0x3F650000:ud                             
        mad (1|M0)               r2.4<1>:f     r2.5<0;0>:f       r2.4<0;0>:f       (abs)r2.3<0>:f   {A@1}
        mov (1|M0)               r4.0<2>:hf    r2.4<0;1,0>:f                    {F@1}
        mov (1|M0)               r5.0<1>:f     r4.0<0;1,0>:hf                   {F@1}
        mad (1|M0)               r2.3<1>:f     r5.1<0;0>:f       r5.0<0;0>:f       r2.3<0>:f        {A@1}
        mov (1|M0)               r6.0<2>:hf    r2.3<0;1,0>:f                    {F@1}
        mul (1|M0)               r1.4<1>:hf    r1.4<0;1,0>:hf    r6.0<0;1,0>:hf   {F@1}
        mov (1|M0)               r82.5<1>:f    r1.4<0;1,0>:hf                   {F@1}
L2504:
        join (16|M0)                         L3224                                
L2520:
(W)     and (1|M0)               f1.1<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(f1.1.any16h) goto (16|M0)                   L2632                  L2632                
L2552:
(W)     mov (1|M0)               f1.1<1>:uw    r84.13<0;1,0>:uw                
        mov (1|M0)               r1.4<2>:hf    r82.5<0;1,0>:f                   {F@1}
        mov (1|M0)               r83.4<1>:f    r1.4<0;1,0>:hf                   {F@1}
(~f1.1) mov (1|M0)               r83.4<1>:f    r82.5<0;1,0>:f                  
        goto (16|M0)                         L2632                  L3080                
L2632:
        join (16|M0)                         L3080                                
L2648:
        cmp (1|M0)    (lt)f1.1   null<1>:f     r82.5<0;1,0>:f    0.0:f               {I@3}
(f1.1)  mov (1|M0)               r82.5<1>:f    -r82.5<0;1,0>:f                 
        sel (1|M0)    (lt)f0.0   r82.5<1>:f    r82.5<0;1,0>:f    448.0:f               {F@1}
        shr (1|M0)               r82.7<1>:ud   r82.5<0;1,0>:ud   0x17:uw              {F@1}
        and (1|M0)               r82.7<1>:ud   r82.7<0;1,0>:ud   0xFF:uw              {I@1}
        sel (1|M0)    (ge)f0.0   r82.7<1>:ud   r82.7<0;1,0>:ud   0x79:uw              {I@1}
        shl (1|M0)               r82.7<1>:ud   r82.7<0;1,0>:ud   0x17:uw              {I@1}
        add (1|M0)               r1.2<1>:ud    -r82.7<0;1,0>:ud  0x80800000:ud              {I@1}
        mul (1|M0)               r1.3<1>:f     r82.5<0;1,0>:f    r1.2<0;1,0>:f    {I@1}
        mov (1|M0)               r82.6<1>:d    r1.3<0;1,0>:f                    {F@1}
        mov (1|M0)               r83.4<1>:f    r82.6<0;1,0>:d                   {I@1}
        mad (1|M0)               r82.5<1>:f    -r83.4<0;0>:f     r1.2<0;0>:f       r82.5<0>:f       {F@1}
        cmp (1|M0)    (gt)f1.0   null<1>:f     r82.5<0;1,0>:f    0.5:f               {F@1}
(W)     and (1|M0)               f1.0<1>:uw    f1.0<0;1,0>:uw    0x1:uw              {F@1}
(f1.0.any16h) goto (16|M0)                   L2984                  L2984                
L2888:
        cmp (1|M0)    (lt)f1.0   null<1>:f     r82.5<0;1,0>:f    0.5:f               {A@1}
        and (1|M0)               r82.6<1>:d    r82.6<0;1,0>:d    1:w              
        add (1|M0)               r1.2<1>:f     r83.4<0;1,0>:f    1.0:f              
(~f1.0) cmp (1|M0)    (eq)f1.0   null<1>:d     r82.6<0;1,0>:d    0:w               {A@1}
(~f1.0) mov (1|M0)               r83.4<1>:f    r1.2<0;1,0>:f                    {F@1}
        goto (16|M0)                         L2984                  L3016                
L2984:
        join (16|M0)                         L3016                                
L3000:
        add (1|M0)               r83.4<1>:f    r83.4<0;1,0>:f    1.0:f               {F@1}
L3016:
        join (16|M0)                         L3080                                
L3032:
        add (1|M0)               r82.7<1>:ud   r82.7<0;1,0>:ud   0xFE800000:ud             
        mul (1|M0)               r83.4<1>:f    r83.4<0;1,0>:f    r82.7<0;1,0>:f   {A@1}
(f1.1)  mov (1|M0)               r83.4<1>:f    -r83.4<0;1,0>:f                  {F@1}
L3080:
        join (16|M0)                         L3224                                
L3096:
        shl (1|M0)               r1.3<1>:w     r82.8<0;1,0>:w    1:w              
        add (1|M0)               r82.4<1>:d    r82.4<0;1,0>:d    1:w              
(W)     mov (1|M0)               r2.6<2>:hf    r83.4<0;1,0>:f                   {F@1}
        cmp (1|M0)    (eq)f1.1   null<1>:d     r82.4<0;1,0>:d    8:w               {I@1}
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0xA2C:uw              {A@1}
        mov (1|M0)               r[a0.0]<1>:hf  r2.6<0;1,0>:hf                  {F@1}
(W)     and (1|M0)               f1.0<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(~f1.0.any16h) goto.b (16|M0)                L3224                  L2184                
L3224:
        join (16|M0)                         L4296                                
L3240:
        mov (1|M0)               r83.5<1>:d    0:w                              
L3256:
        mad (1|M0)               r1.3<1>:w     r81.14<0;0>:w     r83.10<0;0>:w     4:w               {I@1}
(W)     and (1|M0)               f1.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0x7E0:uw              {A@1}
        mov (1|M0)               r83.6<1>:f    r[a0.0]<0;1,0>:f                
(~f1.1.any16h) goto (16|M0)                  L3576                  L3576                 {A@1}
L3336:
        mov (1|M0)               r1.4<2>:hf    r[a0.0]<0;1,0>:f                
        cmp (1|M0)    (lt)f1.0   null<1>:f     r[a0.0]<0;1,0>:f  -4.001953e+00:f               {A@1}
        mov (1|M0)               r1.3<1>:f     r1.4<0;1,0>:hf                   {A@1}
        mov (1|M0)               r2.4<1>:ud    0xBD650000:ud                             
        sel (1|M0)    (lt)f0.0   r1.3<1>:f     r1.3<0;1,0>:f     4.0:f               {F@1}
        mov (1|M0)               r2.5<1>:ud    0x3EE50000:ud                             
(~f1.0) sel (1|M0)               r2.3<1>:f     r1.3<0;1,0>:f     -4.0:f               {F@1}
        mov (1|M0)               r5.1<1>:ud    0x3F650000:ud                             
        mad (1|M0)               r2.4<1>:f     r2.5<0;0>:f       r2.4<0;0>:f       (abs)r2.3<0>:f   {A@1}
        mov (1|M0)               r4.0<2>:hf    r2.4<0;1,0>:f                    {F@1}
        mov (1|M0)               r5.0<1>:f     r4.0<0;1,0>:hf                   {F@1}
        mad (1|M0)               r2.3<1>:f     r5.1<0;0>:f       r5.0<0;0>:f       r2.3<0>:f        {A@1}
        mov (1|M0)               r6.0<2>:hf    r2.3<0;1,0>:f                    {F@1}
        mul (1|M0)               r1.4<1>:hf    r1.4<0;1,0>:hf    r6.0<0;1,0>:hf   {F@1}
        mov (1|M0)               r83.6<1>:f    r1.4<0;1,0>:hf                   {F@1}
L3576:
        join (16|M0)                         L4296                                
L3592:
(W)     and (1|M0)               f1.0<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(f1.0.any16h) goto (16|M0)                   L3704                  L3704                
L3624:
(W)     mov (1|M0)               f1.0<1>:uw    r84.13<0;1,0>:uw                
        mov (1|M0)               r1.4<2>:hf    r83.6<0;1,0>:f                   {F@1}
        mov (1|M0)               r84.5<1>:f    r1.4<0;1,0>:hf                   {F@1}
(~f1.0) mov (1|M0)               r84.5<1>:f    r83.6<0;1,0>:f                  
        goto (16|M0)                         L3704                  L4152                
L3704:
        join (16|M0)                         L4152                                
L3720:
        cmp (1|M0)    (lt)f1.0   null<1>:f     r83.6<0;1,0>:f    0.0:f               {I@3}
(f1.0)  mov (1|M0)               r83.6<1>:f    -r83.6<0;1,0>:f                 
        sel (1|M0)    (lt)f0.0   r83.6<1>:f    r83.6<0;1,0>:f    448.0:f               {F@1}
        shr (1|M0)               r84.4<1>:ud   r83.6<0;1,0>:ud   0x17:uw              {F@1}
        and (1|M0)               r84.4<1>:ud   r84.4<0;1,0>:ud   0xFF:uw              {I@1}
        sel (1|M0)    (ge)f0.0   r84.4<1>:ud   r84.4<0;1,0>:ud   0x79:uw              {I@1}
        shl (1|M0)               r84.4<1>:ud   r84.4<0;1,0>:ud   0x17:uw              {I@1}
        add (1|M0)               r1.2<1>:ud    -r84.4<0;1,0>:ud  0x80800000:ud              {I@1}
        mul (1|M0)               r1.3<1>:f     r83.6<0;1,0>:f    r1.2<0;1,0>:f    {I@1}
        mov (1|M0)               r83.7<1>:d    r1.3<0;1,0>:f                    {F@1}
        mov (1|M0)               r84.5<1>:f    r83.7<0;1,0>:d                   {I@1}
        mad (1|M0)               r83.6<1>:f    -r84.5<0;0>:f     r1.2<0;0>:f       r83.6<0>:f       {F@1}
        cmp (1|M0)    (gt)f1.1   null<1>:f     r83.6<0;1,0>:f    0.5:f               {F@1}
(W)     and (1|M0)               f1.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw              {F@1}
(f1.1.any16h) goto (16|M0)                   L4056                  L4056                
L3960:
        cmp (1|M0)    (lt)f1.1   null<1>:f     r83.6<0;1,0>:f    0.5:f               {A@1}
        and (1|M0)               r83.7<1>:d    r83.7<0;1,0>:d    1:w              
        add (1|M0)               r1.2<1>:f     r84.5<0;1,0>:f    1.0:f              
(~f1.1) cmp (1|M0)    (eq)f1.1   null<1>:d     r83.7<0;1,0>:d    0:w               {A@1}
(~f1.1) mov (1|M0)               r84.5<1>:f    r1.2<0;1,0>:f                    {F@1}
        goto (16|M0)                         L4056                  L4088                
L4056:
        join (16|M0)                         L4088                                
L4072:
        add (1|M0)               r84.5<1>:f    r84.5<0;1,0>:f    1.0:f               {F@1}
L4088:
        join (16|M0)                         L4152                                
L4104:
        add (1|M0)               r84.4<1>:ud   r84.4<0;1,0>:ud   0xFE800000:ud             
        mul (1|M0)               r84.5<1>:f    r84.5<0;1,0>:f    r84.4<0;1,0>:f   {A@1}
(f1.0)  mov (1|M0)               r84.5<1>:f    -r84.5<0;1,0>:f                  {F@1}
L4152:
        join (16|M0)                         L4296                                
L4168:
        shl (1|M0)               r1.3<1>:w     r83.10<0;1,0>:w   1:w              
        add (1|M0)               r83.5<1>:d    r83.5<0;1,0>:d    1:w              
(W)     mov (1|M0)               r2.6<2>:hf    r84.5<0;1,0>:f                   {F@1}
        cmp (1|M0)    (eq)f1.1   null<1>:d     r83.5<0;1,0>:d    8:w               {I@1}
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0xA40:uw              {A@1}
        mov (1|M0)               r[a0.0]<1>:hf  r2.6<0;1,0>:hf                  {F@1}
(W)     and (1|M0)               f1.0<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(~f1.0.any16h) goto.b (16|M0)                L4296                  L3256                
L4296:
        join (16|M0)                         L7608                                
L4312:
        bfn.0xFE (1|M0)          r1.2<1>:ud    0x8:uw               r45.1<0;0>:ud     r81.0<0>:ud      // s0|s1|s2
        cmp (1|M0)    (lt)f1.0   null<1>:ud    r1.2<0;1,0>:ud    r3.6<0;1,0>:ud   {I@1}
(W)     and (1|M0)               f1.1<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
(f1.1.any16h) goto (16|M0)                   L4424                  L4424                
L4376:
        mov (8|M0)               r83.0<1>:uw   0x0:uw                             
        mov (8|M0)               r84.0<1>:hf   0.0:hf                             
        goto (16|M0)                         L4424                  L6536                
L4424:
        join (16|M0)                         L6536                                
L4440:
        shl (1|M0)               r84.12<1>:w   r81.4<0;1,0>:w    5:w              
        mov (1|M0)               r84.7<1>:d    0:w                              
L4472:
        mad (1|M0)               r1.3<1>:w     r84.12<0;0>:w     r84.14<0;0>:w     4:w               {I@1}
(W)     and (1|M0)               f1.0<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0x6E0:uw              {A@1}
        mov (1|M0)               r85.0<1>:f    r[a0.0]<0;1,0>:f                 {$2.dst}
(~f1.0.any16h) goto (16|M0)                  L4792                  L4792                 {A@1}
L4552:
        mov (1|M0)               r1.4<2>:hf    r[a0.0]<0;1,0>:f                
        cmp (1|M0)    (lt)f1.1   null<1>:f     r[a0.0]<0;1,0>:f  -4.001953e+00:f               {A@1}
        mov (1|M0)               r1.3<1>:f     r1.4<0;1,0>:hf                   {A@1}
        mov (1|M0)               r2.4<1>:ud    0xBD650000:ud                             
        sel (1|M0)    (lt)f0.0   r1.3<1>:f     r1.3<0;1,0>:f     4.0:f               {F@1}
        mov (1|M0)               r2.5<1>:ud    0x3EE50000:ud                             
(~f1.1) sel (1|M0)               r2.3<1>:f     r1.3<0;1,0>:f     -4.0:f               {F@1}
        mov (1|M0)               r5.1<1>:ud    0x3F650000:ud                             
        mad (1|M0)               r2.4<1>:f     r2.5<0;0>:f       r2.4<0;0>:f       (abs)r2.3<0>:f   {A@1}
        mov (1|M0)               r4.0<2>:hf    r2.4<0;1,0>:f                    {F@1}
        mov (1|M0)               r5.0<1>:f     r4.0<0;1,0>:hf                   {F@1}
        mad (1|M0)               r2.3<1>:f     r5.1<0;0>:f       r5.0<0;0>:f       r2.3<0>:f        {A@1}
        mov (1|M0)               r6.0<2>:hf    r2.3<0;1,0>:f                    {F@1}
        mul (1|M0)               r1.4<1>:hf    r1.4<0;1,0>:hf    r6.0<0;1,0>:hf   {F@1}
        mov (1|M0)               r85.0<1>:f    r1.4<0;1,0>:hf                   {F@1}
L4792:
        join (16|M0)                         L5496                                
L4808:
(W)     and (1|M0)               f1.1<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(f1.1.any16h) goto (16|M0)                   L4920                  L4920                
L4840:
(W)     mov (1|M0)               f1.1<1>:uw    r84.13<0;1,0>:uw                
        mov (1|M0)               r1.4<2>:hf    r85.0<0;1,0>:f                   {F@1}
        mov (1|M0)               r85.3<1>:f    r1.4<0;1,0>:hf                   {F@1}
(~f1.1) mov (1|M0)               r85.3<1>:f    r85.0<0;1,0>:f                  
        goto (16|M0)                         L4920                  L5352                
L4920:
        join (16|M0)                         L5352                                
L4936:
        cmp (1|M0)    (lt)f1.1   null<1>:f     r85.0<0;1,0>:f    0.0:f               {I@3}
(f1.1)  mov (1|M0)               r85.0<1>:f    -r85.0<0;1,0>:f                 
        sel (1|M0)    (lt)f0.0   r85.0<1>:f    r85.0<0;1,0>:f    448.0:f               {F@1}
        shr (1|M0)               r85.2<1>:ud   r85.0<0;1,0>:ud   0x17:uw              {F@1}
        and (1|M0)               r85.2<1>:ud   r85.2<0;1,0>:ud   0xFF:uw              {I@1}
        sel (1|M0)    (ge)f0.0   r85.2<1>:ud   r85.2<0;1,0>:ud   0x79:uw              {I@1}
        shl (1|M0)               r85.2<1>:ud   r85.2<0;1,0>:ud   0x17:uw              {I@1}
        add (1|M0)               r1.2<1>:ud    -r85.2<0;1,0>:ud  0x80800000:ud              {I@1}
        mul (1|M0)               r1.3<1>:f     r85.0<0;1,0>:f    r1.2<0;1,0>:f    {I@1}
        mov (1|M0)               r85.1<1>:d    r1.3<0;1,0>:f                    {F@1}
        mov (1|M0)               r85.3<1>:f    r85.1<0;1,0>:d                   {I@1}
        mad (1|M0)               r85.0<1>:f    -r85.3<0;0>:f     r1.2<0;0>:f       r85.0<0>:f       {F@1}
        cmp (1|M0)    (gt)f1.0   null<1>:f     r85.0<0;1,0>:f    0.5:f               {F@1}
(W)     and (1|M0)               f1.0<1>:uw    f1.0<0;1,0>:uw    0x1:uw              {F@1}
(f1.0.any16h) goto (16|M0)                   L5264                  L5264                
L5176:
        cmp (1|M0)    (lt)f1.0   null<1>:f     r85.0<0;1,0>:f    0.5:f               {A@1}
        and (1|M0)               r85.1<1>:d    r85.1<0;1,0>:d    1:w               {Compacted}
        add (1|M0)               r1.2<1>:f     r85.3<0;1,0>:f    1.0:f              
(~f1.0) cmp (1|M0)    (eq)f1.0   null<1>:d     r85.1<0;1,0>:d    0:w               {A@1}
(~f1.0) mov (1|M0)               r85.3<1>:f    r1.2<0;1,0>:f                    {F@1}
        goto (16|M0)                         L5264                  L5288                
L5264:
        join (16|M0)                         L5288                                
L5280:
        add (1|M0)               r85.3<1>:f    r85.3<0;1,0>:f    1.0:f               {Compacted,F@1}
L5288:
        join (16|M0)                         L5352                                
L5304:
        add (1|M0)               r85.2<1>:ud   r85.2<0;1,0>:ud   0xFE800000:ud             
        mul (1|M0)               r85.3<1>:f    r85.3<0;1,0>:f    r85.2<0;1,0>:f   {A@1}
(f1.1)  mov (1|M0)               r85.3<1>:f    -r85.3<0;1,0>:f                  {F@1}
L5352:
        join (16|M0)                         L5496                                
L5368:
        shl (1|M0)               r1.3<1>:w     r84.14<0;1,0>:w   1:w              
        add (1|M0)               r84.7<1>:d    r84.7<0;1,0>:d    1:w              
(W)     mov (1|M0)               r2.6<2>:hf    r85.3<0;1,0>:f                   {F@1}
        cmp (1|M0)    (eq)f1.1   null<1>:d     r84.7<0;1,0>:d    8:w               {I@1}
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0xA60:uw              {A@1}
        mov (1|M0)               r[a0.0]<1>:hf  r2.6<0;1,0>:hf                  {F@1}
(W)     and (1|M0)               f1.0<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(~f1.0.any16h) goto.b (16|M0)                L5496                  L4472                
L5496:
        join (16|M0)                         L6536                                
L5512:
        mov (1|M0)               r85.4<1>:d    0:w                              
L5528:
        mad (1|M0)               r1.3<1>:w     r84.12<0;0>:w     r85.8<0;0>:w      4:w               {I@1}
(W)     and (1|M0)               f1.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0x5E0:uw              {A@1}
        mov (1|M0)               r85.5<1>:f    r[a0.0]<0;1,0>:f                
(~f1.1.any16h) goto (16|M0)                  L5848                  L5848                 {A@1}
L5608:
        mov (1|M0)               r1.4<2>:hf    r[a0.0]<0;1,0>:f                
        cmp (1|M0)    (lt)f1.0   null<1>:f     r[a0.0]<0;1,0>:f  -4.001953e+00:f               {A@1}
        mov (1|M0)               r1.3<1>:f     r1.4<0;1,0>:hf                   {A@1}
        mov (1|M0)               r2.4<1>:ud    0xBD650000:ud                             
        sel (1|M0)    (lt)f0.0   r1.3<1>:f     r1.3<0;1,0>:f     4.0:f               {F@1}
        mov (1|M0)               r2.5<1>:ud    0x3EE50000:ud                             
(~f1.0) sel (1|M0)               r2.3<1>:f     r1.3<0;1,0>:f     -4.0:f               {F@1}
        mov (1|M0)               r5.1<1>:ud    0x3F650000:ud                             
        mad (1|M0)               r2.4<1>:f     r2.5<0;0>:f       r2.4<0;0>:f       (abs)r2.3<0>:f   {A@1}
        mov (1|M0)               r4.0<2>:hf    r2.4<0;1,0>:f                    {F@1}
        mov (1|M0)               r5.0<1>:f     r4.0<0;1,0>:hf                   {F@1}
        mad (1|M0)               r2.3<1>:f     r5.1<0;0>:f       r5.0<0;0>:f       r2.3<0>:f        {A@1}
        mov (1|M0)               r6.0<2>:hf    r2.3<0;1,0>:f                    {F@1}
        mul (1|M0)               r1.4<1>:hf    r1.4<0;1,0>:hf    r6.0<0;1,0>:hf   {F@1}
        mov (1|M0)               r85.5<1>:f    r1.4<0;1,0>:hf                   {F@1}
L5848:
        join (16|M0)                         L6536                                
L5864:
(W)     and (1|M0)               f1.0<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(f1.0.any16h) goto (16|M0)                   L5976                  L5976                
L5896:
(W)     mov (1|M0)               f1.0<1>:uw    r84.13<0;1,0>:uw                
        mov (1|M0)               r1.4<2>:hf    r85.5<0;1,0>:f                   {F@1}
        mov (1|M0)               r86.0<1>:f    r1.4<0;1,0>:hf                   {F@1}
(~f1.0) mov (1|M0)               r86.0<1>:f    r85.5<0;1,0>:f                  
        goto (16|M0)                         L5976                  L6392                
L5976:
        join (16|M0)                         L6392                                
L5992:
        cmp (1|M0)    (lt)f1.0   null<1>:f     r85.5<0;1,0>:f    0.0:f               {I@3}
(f1.0)  mov (1|M0)               r85.5<1>:f    -r85.5<0;1,0>:f                 
        sel (1|M0)    (lt)f0.0   r85.5<1>:f    r85.5<0;1,0>:f    448.0:f               {F@1}
        shr (1|M0)               r85.7<1>:ud   r85.5<0;1,0>:ud   0x17:uw              {F@1}
        and (1|M0)               r85.7<1>:ud   r85.7<0;1,0>:ud   0xFF:uw              {I@1}
        sel (1|M0)    (ge)f0.0   r85.7<1>:ud   r85.7<0;1,0>:ud   0x79:uw              {I@1}
        shl (1|M0)               r85.7<1>:ud   r85.7<0;1,0>:ud   0x17:uw              {I@1}
        add (1|M0)               r1.2<1>:ud    -r85.7<0;1,0>:ud  0x80800000:ud              {I@1}
        mul (1|M0)               r1.3<1>:f     r85.5<0;1,0>:f    r1.2<0;1,0>:f    {I@1}
        mov (1|M0)               r85.6<1>:d    r1.3<0;1,0>:f                    {F@1}
        mov (1|M0)               r86.0<1>:f    r85.6<0;1,0>:d                   {Compacted,I@1}
        mad (1|M0)               r85.5<1>:f    -r86.0<0;0>:f     r1.2<0;0>:f       r85.5<0>:f       {F@1}
        cmp (1|M0)    (gt)f1.1   null<1>:f     r85.5<0;1,0>:f    0.5:f               {F@1}
(W)     and (1|M0)               f1.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw              {F@1}
(f1.1.any16h) goto (16|M0)                   L6312                  L6312                
L6224:
        cmp (1|M0)    (lt)f1.1   null<1>:f     r85.5<0;1,0>:f    0.5:f               {A@1}
        and (1|M0)               r85.6<1>:d    r85.6<0;1,0>:d    1:w              
        add (1|M0)               r1.2<1>:f     r86.0<0;1,0>:f    1.0:f               {Compacted}
(~f1.1) cmp (1|M0)    (eq)f1.1   null<1>:d     r85.6<0;1,0>:d    0:w               {A@1}
(~f1.1) mov (1|M0)               r86.0<1>:f    r1.2<0;1,0>:f                    {F@1}
        goto (16|M0)                         L6312                  L6336                
L6312:
        join (16|M0)                         L6336                                
L6328:
        add (1|M0)               r86.0<1>:f    r86.0<0;1,0>:f    1.0:f               {Compacted,F@1}
L6336:
        join (16|M0)                         L6392                                
L6352:
        add (1|M0)               r85.7<1>:ud   r85.7<0;1,0>:ud   0xFE800000:ud             
        mul (1|M0)               r86.0<1>:f    r86.0<0;1,0>:f    r85.7<0;1,0>:f   {Compacted,A@1}
(f1.0)  mov (1|M0)               r86.0<1>:f    -r86.0<0;1,0>:f                  {F@1}
L6392:
        join (16|M0)                         L6536                                
L6408:
        shl (1|M0)               r1.3<1>:w     r85.8<0;1,0>:w    1:w              
        add (1|M0)               r85.4<1>:d    r85.4<0;1,0>:d    1:w              
(W)     mov (1|M0)               r2.6<2>:hf    r86.0<0;1,0>:f                   {F@1}
        cmp (1|M0)    (eq)f1.0   null<1>:d     r85.4<0;1,0>:d    8:w               {I@1}
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0xA80:uw              {A@1}
        mov (1|M0)               r[a0.0]<1>:hf  r2.6<0;1,0>:hf                  {F@1}
(W)     and (1|M0)               f1.0<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
(~f1.0.any16h) goto.b (16|M0)                L6536                  L5528                
L6536:
        join (16|M0)                         L7608                                
L6552:
        shl (1|M0)               r1.2<1>:d     r81.1<0;1,0>:d    4:w              
        shr (1|M0)               r1.3<1>:ud    r81.0<0;1,0>:ud   0x1C:uw             
        shl (1|M0)               r1.4<1>:d     r81.0<0;1,0>:d    4:w               {Compacted}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        shl (1|M0)               r4.0<1>:d     r1.4<0;1,0>:d     1:w               {Compacted,I@2}
        shr (1|M0)               r2.4<1>:ud    r1.4<0;1,0>:ud    0x1F:uw             
        shl (1|M0)               r2.3<1>:d     r1.5<0;1,0>:d     1:w               {A@1}
        addc (1|M0)              r5.0<1>:ud    r46.2<0;1,0>:ud   r4.0<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r4.1<1>:d     r2.3<0;1,0>:d     r2.4<0;1,0>:d    {I@2}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r4.2<1>:d     r5.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r4.3<1>:d     r6.0<0;0>:d       r46.3<0;0>:d      r4.1<0>:d        {I@2}
        sync.nop                             null                             {Compacted,$7.src}
        mov (8|M0)               r7.0<2>:ud    r4.2<0;1,0>:ud                   {I@2}
        mov (8|M0)               r7.1<2>:ud    r4.3<0;1,0>:ud                   {I@2}
        mov (8|M0)               r13.0<1>:d    r79.1<2;1,0>:d                  
        addc (8|M0)              r9.0<1>:ud    r7.0<2;1,0>:ud    r79.0<2;1,0>:ud  {AccWrEn,Compacted,I@2}
        mov (8|M0)               r15.0<1>:d    r81.6<1;1,0>:uw                 
        mov (8|M0)               r10.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        addc (1|M0)              r5.0<1>:ud    r4.2<0;1,0>:ud    0x10:ud              {AccWrEn}
        mov (8|M0)               r11.0<2>:d    r9.0<1;1,0>:d                    {I@4}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r1.2<1>:d     r5.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r1.3<1>:d     r6.0<0;0>:d       r4.3<0;0>:d       0:w               {I@2}
        mov (8|M0)               r16.0<2>:ud   r1.2<0;1,0>:ud                   {I@2}
        mov (8|M0)               r16.1<2>:ud   r1.3<0;1,0>:ud                   {I@2}
        add3 (8|M0)              r14.0<1>:d    r10.0<1;0>:d      r7.1<4;2>:d       r13.0<1>:d      
        addc (8|M0)              r18.0<1>:ud   r16.0<2;1,0>:ud   r79.0<2;1,0>:ud  {AccWrEn,Compacted,I@2}
        mov (8|M0)               r11.1<2>:d    r14.0<1;1,0>:d                   {I@2}
        mov (8|M0)               r9.0<1>:ud    acc0.0<1;1,0>:ud                 {Compacted}
        addc (1|M0)              r5.0<1>:ud    r46.6<0;1,0>:ud   r4.0<0;1,0>:ud   {AccWrEn}
        send.ugm (8|M0)          null     r11     r15:1   0x0            0x04000B84           {A@3,$8} // wr:2+1, rd:0; store.ugm.d16u32.a64
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r2.4<1>:d     r5.0<0;1,0>:d                    {I@2}
        add3 (1|M0)              r2.5<1>:d     r6.0<0;0>:d       r46.7<0;0>:d      r4.1<0>:d        {I@2}
        sync.nop                             null                             {Compacted,$8.src}
        mov (8|M0)               r14.0<2>:ud   r2.4<0;1,0>:ud                   {I@2}
        mov (8|M0)               r14.1<2>:ud   r2.5<0;1,0>:ud                   {I@2}
        add3 (8|M0)              r10.0<1>:d    r9.0<1;0>:d       r16.1<4;2>:d      r13.0<1>:d      
        addc (8|M0)              r12.0<1>:ud   r14.0<2;1,0>:ud   r79.0<2;1,0>:ud  {AccWrEn,Compacted,I@2}
        mov (8|M0)               r7.0<2>:d     r18.0<1;1,0>:d                  
        mov (8|M0)               r19.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        addc (1|M0)              r5.0<1>:ud    r2.4<0;1,0>:ud    0x10:ud              {AccWrEn}
        mov (8|M0)               r11.0<1>:d    r82.0<1;1,0>:uw                 
        mov (1|M0)               r4.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (8|M0)               r7.1<2>:d     r10.0<1;1,0>:d                   {I@7}
        mov (1|M0)               r1.2<1>:d     r5.0<0;1,0>:d                    {I@4}
        add3 (1|M0)              r1.3<1>:d     r4.0<0;0>:d       r2.5<0;0>:d       0:w               {I@3}
        send.ugm (8|M0)          null     r7      r11:1   0x0            0x04000B84           {A@3,$9} // wr:2+1, rd:0; store.ugm.d16u32.a64
        sync.nop                             null                             {Compacted,$9.src}
        mov (8|M0)               r10.0<2>:ud   r1.2<0;1,0>:ud                   {I@2}
        mov (8|M0)               r10.1<2>:ud   r1.3<0;1,0>:ud                   {I@2}
        add3 (8|M0)              r9.0<1>:d     r19.0<1;0>:d      r14.1<4;2>:d      r13.0<1>:d      
        addc (8|M0)              r6.0<1>:ud    r10.0<2;1,0>:ud   r79.0<2;1,0>:ud  {AccWrEn,Compacted,I@2}
        mov (8|M0)               r16.0<2>:d    r12.0<1;1,0>:d                  
        mov (8|M0)               r8.0<1>:ud    acc0.0<1;1,0>:ud                 {Compacted}
        addc (1|M0)              r5.0<1>:ud    r81.0<0;1,0>:ud   0x1:ud              {AccWrEn}
        mov (8|M0)               r7.0<1>:d     r83.0<1;1,0>:uw                 
        mov (1|M0)               r4.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r86.2<1>:d    r5.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r86.3<1>:d    r4.0<0;0>:d       r81.1<0;0>:d      0:w               {I@2}
        mov (8|M0)               r16.1<2>:d    r9.0<1;1,0>:d                   
        cmp (1|M0)    (eq)f0.1   null<1>:d     r86.3<0;1,0>:d    0:w               {I@2}
        add3 (8|M0)              r9.0<1>:d     r8.0<1;0>:d       r10.1<4;2>:d      r13.0<1>:d      
        send.ugm (8|M0)          null     r16     r7:1    0x0            0x04000B84           {A@3,$10} // wr:2+1, rd:0; store.ugm.d16u32.a64
        mov (8|M0)               r14.0<2>:d    r6.0<1;1,0>:d                   
(f0.1)  cmp (1|M0)    (eq)f0.1   null<1>:d     r86.2<0;1,0>:d    8:w              
        mov (8|M0)               r7.0<1>:d     r84.0<1;1,0>:uw                  {$10.src}
        mov (8|M0)               r14.1<2>:d    r9.0<1;1,0>:d                    {I@4}
        add (1|M0)               r81.2<1>:d    r81.2<0;1,0>:d    1:w              
(W)     and (1|M0)               f0.1<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
        send.ugm (8|M0)          null     r14     r7:1    0x0            0x04000B84           {A@3,$7} // wr:2+1, rd:0; store.ugm.d16u32.a64
(f0.1.any16h) goto (16|M0)                   L7608                  L7608                
L7576:
(W)     mov (2|M0)               r81.0<1>:ud   r86.2<1;1,0>:ud                 
        goto.b (16|M0)                       L7608                  L1960                
L7608:
        join (16|M0)                         L7624                                
L7624:
(W)     mov (8|M0)               r127.0<1>:f   r0.0<1;1,0>:f                    {Compacted}
(W)     send.ugm (1|M0)          r4       r0      null:0  0x0            0x0210641F           {$11} // wr:1+0, rd:1; fence invalid flush type scoped to tile
(W)     mov (8|M0)               null<1>:ud    r4.0<1;1,0>:ud                   {$11.dst}
(W)     send.gtwy (1|M0)         null     r127    null:0  0x0            0x02000010           {EOT,A@1} // wr:1+0, rd:0; end of thread
L7680:
        mov (1|M0)               r1.2<1>:d     cr0.0<0;1,0>:ud                  {A@1}
        and (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   -1265:w               {A@1}
        or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   1264:w               {A@1}
        mov (1|M0)               r1.3<1>:f     (abs)r86.5<0;1,0>:d              {A@1}
        mov (1|M0)               r4.2<1>:f     0xB4C00000:f                               {Compacted,I@4}
        math.inv (1|M0)          r4.1<1>:f     r1.3<0;1,0>:f                    {@2,$12}
        mov (1|M0)               r2.4<1>:f     (abs)r86.4<0;1,0>:d             
        sync.nop                             null                             {Compacted,$12.dst}
        mad (1|M0)               r4.1<1>:f     r4.1<0;0>:f       r4.2<0;0>:f       r4.1<0>:f        {F@2}
        mov (2|M0)               r1.4<1>:d     (abs)r86.4<1;1,0>:d             
        mov (1|M0)               r1.6<1>:ud    r1.3<0;1,0>:f                   
        mov (1|M0)               r2.5<1>:ud    r2.4<0;1,0>:f                    {F@2}
        mul (1|M0)               r5.0<1>:f     r4.1<0;1,0>:f     r2.4<0;1,0>:f    {F@1}
        add (1|M0)               r1.6<1>:ud    r1.5<0;1,0>:ud    -r1.6<0;1,0>:ud  {I@2}
        add (1|M0)               r2.5<1>:ud    r1.4<0;1,0>:ud    -r2.5<0;1,0>:ud  {I@2}
        mov (1|M0)               r6.0<1>:ud    r5.0<0;1,0>:f                    {F@1}
        mov (1|M0)               r2.3<1>:f     r1.6<0;1,0>:ud                   {I@3}
        mov (1|M0)               r4.0<1>:f     r2.5<0;1,0>:ud                   {Compacted,I@2}
        mov (1|M0)               r6.1<1>:f     r6.0<0;1,0>:ud                   {Compacted,I@1}
        xor (1|M0)               r86.5<1>:d    r86.5<0;1,0>:d    r86.4<0;1,0>:d  
        mad (1|M0)               r2.4<1>:f     r2.4<0;0>:f       r6.1<0;0>:f       -r1.3<0>:f       {F@1}
        mad (1|M0)               r6.1<1>:f     r4.0<0;0>:f       r6.1<0;0>:f       -r2.3<0>:f      
(W)     mov (1|M0)               r5.0<1>:hf    0x1:hf                             
        add (1|M0)               r2.4<1>:f     r2.4<0;1,0>:f     r6.1<0;1,0>:f    {F@2}
        asr (1|M0)               r86.5<1>:d    r86.5<0;1,0>:d    31:w               {I@1}
        mul (1|M0)               r4.1<1>:f     r4.1<0;1,0>:f     r2.4<0;1,0>:f    {F@1}
        mov (1|M0)               r7.0<1>:ud    r4.1<0;1,0>:f                    {F@1}
        add (1|M0)               r6.0<1>:ud    r6.0<0;1,0>:ud    r7.0<0;1,0>:ud   {Compacted,I@1}
(W)     mul (1|M0)               acc0.0<1>:ud  r6.0<0;1,0>:ud    r1.10<0;1,0>:uw  {I@1}
        mach (1|M0)              r8.0<1>:ud    r6.0<0;1,0>:ud    r1.5<0;1,0>:ud   {Compacted}
        add (1|M0)               r1.4<1>:ud    r1.4<0;1,0>:ud    -r8.0<0;1,0>:ud  {I@1}
        cmp (1|M0)    (ge)f1.1   null<1>:ud    r1.4<0;1,0>:ud    r1.5<0;1,0>:ud   {I@1}
(f1.1)  sel (1|M0)               r9.0<1>:d     r5.0<0;1,0>:w     0:w              
        add3 (1|M0)              r6.0<1>:d     r6.0<0;0>:d       r86.5<0;0>:d      r9.0<0>:d        {I@1}
        xor (1|M0)               r45.1<1>:d    r6.0<0;1,0>:d     r86.5<0;1,0>:d   {I@1}
        mov (1|M0)               cr0.0<1>:ud   r1.2<0;1,0>:d                    {A@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        ret (16|M0)                          r86.6                            {A@1}
L8256:
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
