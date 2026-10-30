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
        mov (1|M0)               r47.0<1>:d    r0.1<0;1,0>:ud                   {A@1}
        mov (1|M0)               r88.1<1>:d    r2.6<0;1,0>:d                    {$1.dst}
(W)     mul (1|M0)               acc0.0<1>:d   r47.0<0;1,0>:d    r2.0<0;1,0>:uw   {Compacted,I@2}
        mach (1|M0)              r47.0<1>:d    r47.0<0;1,0>:d    r2.0<0;1,0>:d    {Compacted}
        sync.nop                             null                             {Compacted,$0.dst}
        add (1|M0)               r47.0<1>:d    r47.0<0;1,0>:d    r1.0<0;1,0>:uw   {I@1}
        mov (1|M0)               r88.0<1>:f    r47.0<0;1,0>:f                   {Compacted,I@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r88.2         L8048                                 {A@1}
L368:
        cmp (1|M0)    (gt)f0.0   null<1>:d     r2.7<0;1,0>:d     0:w              
(W)     mul (1|M0)               acc0.0<1>:d   r46.0<0;1,0>:d    r2.12<0;1,0>:uw  {Compacted}
        mach (1|M0)              r5.0<1>:d     r46.0<0;1,0>:d    r2.6<0;1,0>:d    {Compacted}
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
        mov (16|M0)              r79.0<1>:f    0.0:f                               {Compacted}
        add (1|M0)               r47.0<1>:d    r47.0<0;1,0>:d    -r5.0<0;1,0>:d   {Compacted,A@7}
(~f0.1.any16h) goto (16|M0)                  L1688                  L1688                
L624:
(W)     mul (1|M0)               acc0.0<1>:d   r46.0<0;1,0>:d    r2.14<0;1,0>:uw  {Compacted}
        mach (1|M0)              r5.0<1>:d     r46.0<0;1,0>:d    r2.7<0;1,0>:d    {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r46.0<0;1,0>:d    r2.14<0;1,0>:uw  {Compacted}
        mov (1|M0)               r46.1<1>:d    r2.6<0;1,0>:d                   
        asr (1|M0)               r46.2<1>:d    r2.6<0;1,0>:d     31:w              
        mov (1|M0)               r46.3<1>:d    r47.0<0;1,0>:d                   {I@7}
        asr (1|M0)               r46.4<1>:d    r47.0<0;1,0>:d    31:w               {Compacted}
        mov (1|M0)               r46.5<1>:d    r2.7<0;1,0>:d                   
        mov (1|M0)               r46.6<1>:d    0:w                              
        mov (1|M0)               r47.2<2>:f    0.0:f                              
        mov (1|M0)               r47.3<2>:f    0.0:f                              
        mach (1|M0)              r48.0<1>:d    r46.0<0;1,0>:d    r2.7<0;1,0>:d    {Compacted}
        asr (1|M0)               r48.1<1>:d    r5.0<0;1,0>:d     31:w               {Compacted,I@7}
L784:
        addc (1|M0)              r5.0<1>:ud    r47.2<0;1,0>:ud   r48.0<0;1,0>:ud  {AccWrEn,A@2}
        shl (1|M0)               r4.1<1>:d     r5.0<0;1,0>:d     8:w               {Compacted,I@1}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        shl (1|M0)               r7.0<1>:d     r4.1<0;1,0>:d     1:w               {Compacted,I@2}
        add3 (1|M0)              r1.3<1>:d     r6.0<0;0>:d       r47.3<0;0>:d      r48.1<0>:d       {A@1}
        addc (1|M0)              r8.0<1>:ud    r3.0<0;1,0>:ud    r7.0<0;1,0>:ud   {AccWrEn,I@2}
        shr (1|M0)               r2.4<1>:ud    r5.0<0;1,0>:ud    0x18:uw             
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mul (1|M0)               acc0.0<1>:ud  r47.2<0;1,0>:ud   r46.2<0;1,0>:uw 
        mach (1|M0)              r12.0<1>:ud   r47.2<0;1,0>:ud   r46.1<0;1,0>:ud  {AccWrEn}
        shl (1|M0)               r2.3<1>:d     r1.3<0;1,0>:d     8:w               {Compacted,I@6}
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r47.2<0;1,0>:d    r46.4<0;1,0>:uw 
        mach (1|M0)              r5.0<1>:d     r47.2<0;1,0>:d    r46.2<0;1,0>:d  
(W)     mul (1|M0)               acc0.0<1>:d   r47.3<0;1,0>:d    r46.2<0;1,0>:uw 
        or (1|M0)                r4.2<1>:d     r2.3<0;1,0>:d     r2.4<0;1,0>:d    {I@5}
        mach (1|M0)              r6.0<1>:d     r47.3<0;1,0>:d    r46.1<0;1,0>:d  
        addc (1|M0)              r13.0<1>:ud   r11.0<0;1,0>:ud   r46.3<0;1,0>:ud  {AccWrEn,I@6}
        shr (1|M0)               r4.4<1>:ud    r4.1<0;1,0>:ud    0x1F:uw             
        shl (1|M0)               r4.3<1>:d     r4.2<0;1,0>:d     1:w               {I@4}
        add3 (1|M0)              r1.3<1>:d     r6.0<0;0>:d       r12.0<0;0>:d      r5.0<0>:d        {I@4}
        mov (1|M0)               r14.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,$3.src}
        or (1|M0)                r7.1<1>:d     r4.3<0;1,0>:d     r4.4<0;1,0>:d    {I@3}
        add3 (1|M0)              r2.4<1>:d     r14.0<0;0>:d      r1.3<0;0>:d       r46.4<0>:d       {I@2}
        shl (1|M0)               r4.3<1>:d     r13.0<0;1,0>:d    8:w               {Compacted}
        shr (1|M0)               r4.2<1>:ud    r13.0<0;1,0>:ud   0x18:uw             
        shl (1|M0)               r4.1<1>:d     r2.4<0;1,0>:d     8:w               {I@3}
        shl (1|M0)               r7.2<1>:d     r4.3<0;1,0>:d     1:w               {I@3}
        mov (1|M0)               r10.0<1>:f    r8.0<0;1,0>:f                    {Compacted}
        or (1|M0)                r4.4<1>:d     r4.1<0;1,0>:d     r4.2<0;1,0>:d    {I@2}
        addc (1|M0)              r5.0<1>:ud    r3.2<0;1,0>:ud    r7.2<0;1,0>:ud   {AccWrEn,I@2}
        add3 (1|M0)              r10.1<1>:d    r9.0<0;0>:d       r3.1<0;0>:d       r7.1<0>:d       
        shl (1|M0)               r7.0<1>:d     r4.4<0;1,0>:d     1:w               {Compacted,I@3}
        shr (1|M0)               r7.1<1>:ud    r4.3<0;1,0>:ud    0x1F:uw             
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r8.0<1>:f     r5.0<0;1,0>:f                    {Compacted,I@5}
        addc (1|M0)              r9.0<1>:ud    r10.0<0;1,0>:ud   0x100:ud              {AccWrEn,F@2}
        or (1|M0)                r7.3<1>:d     r7.0<0;1,0>:d     r7.1<0;1,0>:d    {I@3}
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r5.0<1>:ud    r8.0<0;1,0>:ud    0x100:ud              {AccWrEn,F@1}
        add3 (1|M0)              r8.1<1>:d     r6.0<0;0>:d       r3.3<0;0>:d       r7.3<0>:d        {I@3}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r12.0<1>:f    r9.0<0;1,0>:f                    {Compacted}
        add3 (1|M0)              r12.1<1>:d    r11.0<0;0>:d      r10.1<0;0>:d      0:w               {I@4}
        mov (1|M0)               r7.0<1>:f     r5.0<0;1,0>:f                    {Compacted,I@4}
        add3 (1|M0)              r7.1<1>:d     r6.0<0;0>:d       r8.1<0;0>:d       0:w               {I@2}
        send.ugm (1|M0)          r14      r10     null:0  0x0            0x0280E780           {$4} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        send.ugm (1|M0)          r30      r8      null:0  0x0            0x0280E780           {$5} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        send.ugm (1|M0)          r22      r12     null:0  0x0            0x0280E780           {A@2,$6} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        send.ugm (1|M0)          r38      r7      null:0  0x0            0x0280E780           {A@1,$7} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        addc (1|M0)              r9.0<1>:ud    r47.2<0;1,0>:ud   0x1:ud              {AccWrEn}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,$4.src}
        mov (1|M0)               r47.4<1>:d    r9.0<0;1,0>:d                    {I@2}
        add3 (1|M0)              r47.5<1>:d    r10.0<0;0>:d      r47.3<0;0>:d      0:w               {I@2}
        cmp (1|M0)    (eq)f1.0   null<1>:d     r47.5<0;1,0>:d    r46.6<0;1,0>:d   {I@1}
(f1.0)  cmp (1|M0)    (eq)f1.0   null<1>:d     r47.4<0;1,0>:d    r46.5<0;1,0>:d  
(W)     and (1|M0)               f0.0<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
        sync.allwr                           ($3,$4,$5,$6,$7)                
        dpas.8x8 (8|M0)          r73:f         r73:f             r30:hf            r14.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r57:f         r57:f             r30:hf            r22.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r65:f         r65:f             r38:hf            r14.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r49:f         r49:f             r38:hf            r22.0:hf         {$3}
(f0.0.any16h) goto (16|M0)                   L1688                  L1688                
L1656:
(W)     mov (2|M0)               r47.2<1>:ud   r47.4<1;1,0>:ud                 
        goto.b (16|M0)                       L1688                  L784                
L1688:
        join (16|M0)                         L1704                                
L1704:
        shl (1|M0)               r46.0<1>:d    r46.0<0;1,0>:d    4:w               {Compacted}
        shl (1|M0)               r4.1<1>:d     r47.0<0;1,0>:d    4:w               {Compacted}
        mul (1|M0)               acc0.0<1>:d   r46.0<0;1,0>:d    r3.12<0;1,0>:uw  {Compacted,I@2}
        mach (1|M0)              r6.0<1>:d     r46.0<0;1,0>:d    r3.6<0;1,0>:d    {AccWrEn}
        shl (1|M0)               r7.1<1>:d     r4.1<0;1,0>:d     1:w               {Compacted,I@3}
        mov (1|M0)               r5.0<1>:d     acc0.0<0;1,0>:d                 
        shl (1|M0)               r1.2<1>:d     r6.0<0;1,0>:d     1:w               {Compacted,I@3}
        shl (1|M0)               r1.4<1>:d     r5.0<0;1,0>:d     1:w               {Compacted,I@2}
        shr (1|M0)               r1.3<1>:ud    r5.0<0;1,0>:ud    0x1F:uw             
        addc (1|M0)              r7.0<1>:ud    r3.4<0;1,0>:ud    r1.4<0;1,0>:ud   {AccWrEn,I@2}
        shr (1|M0)               r2.5<1>:ud    r4.1<0;1,0>:ud    0x1F:uw             
        mov (8|M0)               r5.0<1>:uw    0xECA86420:uv                             
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@4}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r9.0<1>:ud    r7.0<0;1,0>:ud    r7.1<0;1,0>:ud   {AccWrEn,I@5}
        or (1|M0)                r7.2<1>:d     r2.5<0;1,0>:d     0:w               {I@5}
        mov (8|M0)               r11.0<4>:uw   r5.0<1;1,0>:uw                   {I@5}
        add3 (1|M0)              r2.4<1>:d     r8.0<0;0>:d       r3.5<0;0>:d       r1.5<0>:d        {I@4}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r47.6<1>:f    r3.6<0;1,0>:f                   
        asr (1|M0)               r47.7<1>:d    r3.6<0;1,0>:d     31:w              
        and (1|M0)               r46.7<1>:d    r4.0<0;1,0>:d     -2:w               {Compacted}
        and (1|M0)               r47.1<1>:d    r4.0<0;1,0>:d     -3:w               {Compacted}
        mov (1|M0)               r48.4<2>:f    0.0:f                              
        mov (1|M0)               r48.5<2>:f    0.0:f                              
        mov (1|M0)               r48.6<1>:d    0:w                              
        mov (1|M0)               r48.2<1>:d    r9.0<0;1,0>:d                    {I@7}
        mov (8|M0)               r81.0<2>:ud   r11.0<4;1,0>:uw                  {I@7}
        add3 (1|M0)              r48.3<1>:d    r10.0<0;0>:d      r2.4<0;0>:d       r7.2<0>:d        {I@7}
        mov (8|M0)               r81.1<2>:ud   0.0:f                              
L2104:
        or (1|M0)                r1.2<1>:d     r46.0<0;1,0>:d    r48.4<0;1,0>:d   {F@2}
        cmp (1|M0)    (eq)f0.0   null<1>:d     r4.0<0;1,0>:d     4:w              
        cmp (1|M0)    (lt)f1.1   null<1>:ud    r1.2<0;1,0>:ud    r3.7<0;1,0>:ud   {I@2}
        cmp (1|M0)    (eq)f0.1   null<1>:d     r47.1<0;1,0>:d    1:w              
(W)     mov (1|M0)               r85.13<1>:uw  f0.0<0;1,0>:uw                  
(W)     and (1|M0)               f1.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
        cmp (1|M0)    (eq)f0.0   null<1>:d     r46.7<0;1,0>:d    2:w              
(~f1.1.any16h) goto (16|M0)                  L4952                  L4952                
L2232:
        shl (1|M0)               r48.14<1>:w   r48.12<0;1,0>:w   5:w              
        mov (1|M0)               r83.4<1>:d    0:w                              
L2264:
        mad (1|M0)               r1.3<1>:w     r48.14<0;0>:w     r83.8<0;0>:w      4:w               {I@1}
(W)     and (1|M0)               f1.0<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0x920:uw              {A@1}
        mov (1|M0)               r83.5<1>:f    r[a0.0]<0;1,0>:f                 {$3.dst}
(~f1.0.any16h) goto (16|M0)                  L2584                  L2584                 {A@1}
L2344:
        mov (1|M0)               r1.4<2>:hf    r[a0.0]<0;1,0>:f                
        cmp (1|M0)    (lt)f1.1   null<1>:f     r[a0.0]<0;1,0>:f  -4.001953e+00:f               {A@1}
        mov (1|M0)               r1.3<1>:f     r1.4<0;1,0>:hf                   {A@1}
        mov (1|M0)               r2.4<1>:ud    0xBD650000:ud                             
        sel (1|M0)    (lt)f0.0   r1.3<1>:f     r1.3<0;1,0>:f     4.0:f               {F@1}
        mov (1|M0)               r2.5<1>:ud    0x3EE50000:ud                             
(~f1.1) sel (1|M0)               r2.3<1>:f     r1.3<0;1,0>:f     -4.0:f               {F@1}
        mov (1|M0)               r5.1<1>:ud    0x3F650000:ud                             
        mad (1|M0)               r2.4<1>:f     r2.5<0;0>:f       r2.4<0;0>:f       (abs)r2.3<0>:f   {A@1}
        mov (1|M0)               r4.2<2>:hf    r2.4<0;1,0>:f                    {F@1}
        mov (1|M0)               r5.0<1>:f     r4.2<0;1,0>:hf                   {F@1}
        mad (1|M0)               r2.3<1>:f     r5.1<0;0>:f       r5.0<0;0>:f       r2.3<0>:f        {A@1}
        mov (1|M0)               r6.0<2>:hf    r2.3<0;1,0>:f                    {F@1}
        mul (1|M0)               r1.4<1>:hf    r1.4<0;1,0>:hf    r6.0<0;1,0>:hf   {F@1}
        mov (1|M0)               r83.5<1>:f    r1.4<0;1,0>:hf                   {F@1}
L2584:
        join (16|M0)                         L3304                                
L2600:
(W)     and (1|M0)               f1.1<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(f1.1.any16h) goto (16|M0)                   L2712                  L2712                
L2632:
(W)     mov (1|M0)               f1.1<1>:uw    r85.13<0;1,0>:uw                
        mov (1|M0)               r1.4<2>:hf    r83.5<0;1,0>:f                   {F@1}
        mov (1|M0)               r84.4<1>:f    r1.4<0;1,0>:hf                   {F@1}
(~f1.1) mov (1|M0)               r84.4<1>:f    r83.5<0;1,0>:f                  
        goto (16|M0)                         L2712                  L3160                
L2712:
        join (16|M0)                         L3160                                
L2728:
        cmp (1|M0)    (lt)f1.1   null<1>:f     r83.5<0;1,0>:f    0.0:f               {I@3}
(f1.1)  mov (1|M0)               r83.5<1>:f    -r83.5<0;1,0>:f                 
        sel (1|M0)    (lt)f0.0   r83.5<1>:f    r83.5<0;1,0>:f    448.0:f               {F@1}
        shr (1|M0)               r83.7<1>:ud   r83.5<0;1,0>:ud   0x17:uw              {F@1}
        and (1|M0)               r83.7<1>:ud   r83.7<0;1,0>:ud   0xFF:uw              {I@1}
        sel (1|M0)    (ge)f0.0   r83.7<1>:ud   r83.7<0;1,0>:ud   0x79:uw              {I@1}
        shl (1|M0)               r83.7<1>:ud   r83.7<0;1,0>:ud   0x17:uw              {I@1}
        add (1|M0)               r1.2<1>:ud    -r83.7<0;1,0>:ud  0x80800000:ud              {I@1}
        mul (1|M0)               r1.3<1>:f     r83.5<0;1,0>:f    r1.2<0;1,0>:f    {I@1}
        mov (1|M0)               r83.6<1>:d    r1.3<0;1,0>:f                    {F@1}
        mov (1|M0)               r84.4<1>:f    r83.6<0;1,0>:d                   {I@1}
        mad (1|M0)               r83.5<1>:f    -r84.4<0;0>:f     r1.2<0;0>:f       r83.5<0>:f       {F@1}
        cmp (1|M0)    (gt)f1.0   null<1>:f     r83.5<0;1,0>:f    0.5:f               {F@1}
(W)     and (1|M0)               f1.0<1>:uw    f1.0<0;1,0>:uw    0x1:uw              {F@1}
(f1.0.any16h) goto (16|M0)                   L3064                  L3064                
L2968:
        cmp (1|M0)    (lt)f1.0   null<1>:f     r83.5<0;1,0>:f    0.5:f               {A@1}
        and (1|M0)               r83.6<1>:d    r83.6<0;1,0>:d    1:w              
        add (1|M0)               r1.2<1>:f     r84.4<0;1,0>:f    1.0:f              
(~f1.0) cmp (1|M0)    (eq)f1.0   null<1>:d     r83.6<0;1,0>:d    0:w               {A@1}
(~f1.0) mov (1|M0)               r84.4<1>:f    r1.2<0;1,0>:f                    {F@1}
        goto (16|M0)                         L3064                  L3096                
L3064:
        join (16|M0)                         L3096                                
L3080:
        add (1|M0)               r84.4<1>:f    r84.4<0;1,0>:f    1.0:f               {F@1}
L3096:
        join (16|M0)                         L3160                                
L3112:
        add (1|M0)               r83.7<1>:ud   r83.7<0;1,0>:ud   0xFE800000:ud             
        mul (1|M0)               r84.4<1>:f    r84.4<0;1,0>:f    r83.7<0;1,0>:f   {A@1}
(f1.1)  mov (1|M0)               r84.4<1>:f    -r84.4<0;1,0>:f                  {F@1}
L3160:
        join (16|M0)                         L3304                                
L3176:
        shl (1|M0)               r1.3<1>:w     r83.8<0;1,0>:w    1:w              
        add (1|M0)               r83.4<1>:d    r83.4<0;1,0>:d    1:w              
(W)     mov (1|M0)               r2.6<2>:hf    r84.4<0;1,0>:f                   {F@1}
        cmp (1|M0)    (eq)f1.1   null<1>:d     r83.4<0;1,0>:d    8:w               {I@1}
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0xA60:uw              {A@1}
        mov (1|M0)               r[a0.0]<1>:hf  r2.6<0;1,0>:hf                  {F@1}
(W)     and (1|M0)               f1.0<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(~f1.0.any16h) goto.b (16|M0)                L3304                  L2264                
L3304:
        join (16|M0)                         L4952                                
L3320:
        mov (1|M0)               r84.5<1>:d    0:w                              
L3336:
        mad (1|M0)               r1.3<1>:w     r48.14<0;0>:w     r84.10<0;0>:w     4:w               {I@1}
(W)     and (1|M0)               f1.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0x820:uw              {A@1}
        mov (1|M0)               r84.6<1>:f    r[a0.0]<0;1,0>:f                
(~f1.1.any16h) goto (16|M0)                  L3656                  L3656                 {A@1}
L3416:
        mov (1|M0)               r1.4<2>:hf    r[a0.0]<0;1,0>:f                
        cmp (1|M0)    (lt)f1.0   null<1>:f     r[a0.0]<0;1,0>:f  -4.001953e+00:f               {A@1}
        mov (1|M0)               r1.3<1>:f     r1.4<0;1,0>:hf                   {A@1}
        mov (1|M0)               r2.4<1>:ud    0xBD650000:ud                             
        sel (1|M0)    (lt)f0.0   r1.3<1>:f     r1.3<0;1,0>:f     4.0:f               {F@1}
        mov (1|M0)               r2.5<1>:ud    0x3EE50000:ud                             
(~f1.0) sel (1|M0)               r2.3<1>:f     r1.3<0;1,0>:f     -4.0:f               {F@1}
        mov (1|M0)               r5.1<1>:ud    0x3F650000:ud                             
        mad (1|M0)               r2.4<1>:f     r2.5<0;0>:f       r2.4<0;0>:f       (abs)r2.3<0>:f   {A@1}
        mov (1|M0)               r4.2<2>:hf    r2.4<0;1,0>:f                    {F@1}
        mov (1|M0)               r5.0<1>:f     r4.2<0;1,0>:hf                   {F@1}
        mad (1|M0)               r2.3<1>:f     r5.1<0;0>:f       r5.0<0;0>:f       r2.3<0>:f        {A@1}
        mov (1|M0)               r6.0<2>:hf    r2.3<0;1,0>:f                    {F@1}
        mul (1|M0)               r1.4<1>:hf    r1.4<0;1,0>:hf    r6.0<0;1,0>:hf   {F@1}
        mov (1|M0)               r84.6<1>:f    r1.4<0;1,0>:hf                   {F@1}
L3656:
        join (16|M0)                         L4376                                
L3672:
(W)     and (1|M0)               f1.0<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(f1.0.any16h) goto (16|M0)                   L3784                  L3784                
L3704:
(W)     mov (1|M0)               f1.0<1>:uw    r85.13<0;1,0>:uw                
        mov (1|M0)               r1.4<2>:hf    r84.6<0;1,0>:f                   {F@1}
        mov (1|M0)               r85.5<1>:f    r1.4<0;1,0>:hf                   {F@1}
(~f1.0) mov (1|M0)               r85.5<1>:f    r84.6<0;1,0>:f                  
        goto (16|M0)                         L3784                  L4232                
L3784:
        join (16|M0)                         L4232                                
L3800:
        cmp (1|M0)    (lt)f1.0   null<1>:f     r84.6<0;1,0>:f    0.0:f               {I@3}
(f1.0)  mov (1|M0)               r84.6<1>:f    -r84.6<0;1,0>:f                 
        sel (1|M0)    (lt)f0.0   r84.6<1>:f    r84.6<0;1,0>:f    448.0:f               {F@1}
        shr (1|M0)               r85.4<1>:ud   r84.6<0;1,0>:ud   0x17:uw              {F@1}
        and (1|M0)               r85.4<1>:ud   r85.4<0;1,0>:ud   0xFF:uw              {I@1}
        sel (1|M0)    (ge)f0.0   r85.4<1>:ud   r85.4<0;1,0>:ud   0x79:uw              {I@1}
        shl (1|M0)               r85.4<1>:ud   r85.4<0;1,0>:ud   0x17:uw              {I@1}
        add (1|M0)               r1.2<1>:ud    -r85.4<0;1,0>:ud  0x80800000:ud              {I@1}
        mul (1|M0)               r1.3<1>:f     r84.6<0;1,0>:f    r1.2<0;1,0>:f    {I@1}
        mov (1|M0)               r84.7<1>:d    r1.3<0;1,0>:f                    {F@1}
        mov (1|M0)               r85.5<1>:f    r84.7<0;1,0>:d                   {I@1}
        mad (1|M0)               r84.6<1>:f    -r85.5<0;0>:f     r1.2<0;0>:f       r84.6<0>:f       {F@1}
        cmp (1|M0)    (gt)f1.1   null<1>:f     r84.6<0;1,0>:f    0.5:f               {F@1}
(W)     and (1|M0)               f1.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw              {F@1}
(f1.1.any16h) goto (16|M0)                   L4136                  L4136                
L4040:
        cmp (1|M0)    (lt)f1.1   null<1>:f     r84.6<0;1,0>:f    0.5:f               {A@1}
        and (1|M0)               r84.7<1>:d    r84.7<0;1,0>:d    1:w              
        add (1|M0)               r1.2<1>:f     r85.5<0;1,0>:f    1.0:f              
(~f1.1) cmp (1|M0)    (eq)f1.1   null<1>:d     r84.7<0;1,0>:d    0:w               {A@1}
(~f1.1) mov (1|M0)               r85.5<1>:f    r1.2<0;1,0>:f                    {F@1}
        goto (16|M0)                         L4136                  L4168                
L4136:
        join (16|M0)                         L4168                                
L4152:
        add (1|M0)               r85.5<1>:f    r85.5<0;1,0>:f    1.0:f               {F@1}
L4168:
        join (16|M0)                         L4232                                
L4184:
        add (1|M0)               r85.4<1>:ud   r85.4<0;1,0>:ud   0xFE800000:ud             
        mul (1|M0)               r85.5<1>:f    r85.5<0;1,0>:f    r85.4<0;1,0>:f   {A@1}
(f1.0)  mov (1|M0)               r85.5<1>:f    -r85.5<0;1,0>:f                  {F@1}
L4232:
        join (16|M0)                         L4376                                
L4248:
        shl (1|M0)               r1.3<1>:w     r84.10<0;1,0>:w   1:w              
        add (1|M0)               r84.5<1>:d    r84.5<0;1,0>:d    1:w              
(W)     mov (1|M0)               r2.6<2>:hf    r85.5<0;1,0>:f                   {F@1}
        cmp (1|M0)    (eq)f1.1   null<1>:d     r84.5<0;1,0>:d    8:w               {I@1}
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0xA80:uw              {A@1}
        mov (1|M0)               r[a0.0]<1>:hf  r2.6<0;1,0>:hf                  {F@1}
(W)     and (1|M0)               f1.0<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(~f1.0.any16h) goto.b (16|M0)                L4376                  L3336                
L4376:
        join (16|M0)                         L4952                                
L4392:
        mul (1|M0)               acc0.0<1>:ud  r48.4<0;1,0>:ud   r47.12<0;1,0>:uw
        mach (1|M0)              r6.0<1>:ud    r48.4<0;1,0>:ud   r47.6<0;1,0>:ud  {AccWrEn}
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r48.4<0;1,0>:d    r47.14<0;1,0>:uw
        mach (1|M0)              r7.0<1>:d     r48.4<0;1,0>:d    r47.7<0;1,0>:d   {$9.src}
(W)     mul (1|M0)               acc0.0<1>:d   r48.5<0;1,0>:d    r47.12<0;1,0>:uw
        mach (1|M0)              r8.0<1>:d     r48.5<0;1,0>:d    r47.6<0;1,0>:d   {$8.src}
        shl (1|M0)               r4.1<1>:d     r5.0<0;1,0>:d     1:w               {Compacted,I@5}
        add3 (1|M0)              r1.3<1>:d     r8.0<0;0>:d       r6.0<0;0>:d       r7.0<0>:d        {I@2}
        shr (1|M0)               r2.4<1>:ud    r5.0<0;1,0>:ud    0x1F:uw             
        sync.nop                             null                             {Compacted,$11.src}
        addc (1|M0)              r9.0<1>:ud    r48.2<0;1,0>:ud   r4.1<0;1,0>:ud   {AccWrEn,I@3}
        shl (1|M0)               r2.3<1>:d     r1.3<0;1,0>:d     1:w               {Compacted,A@1}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,$10.src}
        or (1|M0)                r4.2<1>:d     r2.3<0;1,0>:d     r2.4<0;1,0>:d    {I@2}
        mov (1|M0)               r4.4<1>:d     r9.0<0;1,0>:d                   
        add3 (1|M0)              r4.5<1>:d     r10.0<0;0>:d      r48.3<0;0>:d      r4.2<0>:d        {I@2}
        mov (8|M0)               r11.0<2>:ud   r4.4<0;1,0>:ud                   {I@2}
        mov (8|M0)               r11.1<2>:ud   r4.5<0;1,0>:ud                   {I@2}
        mov (8|M0)               r5.0<1>:d     r81.1<2;1,0>:d                  
        addc (8|M0)              r13.0<1>:ud   r11.0<2;1,0>:ud   r81.0<2;1,0>:ud  {AccWrEn,Compacted,I@2}
        mov (8|M0)               r8.0<1>:d     r83.0<1;1,0>:uw                 
        mov (8|M0)               r7.0<1>:ud    acc0.0<1;1,0>:ud                 {Compacted}
        addc (1|M0)              r9.0<1>:ud    r4.4<0;1,0>:ud    0x10:ud              {AccWrEn}
        mov (8|M0)               r14.0<2>:d    r13.0<1;1,0>:d                   {I@4}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r1.2<1>:d     r9.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r1.3<1>:d     r10.0<0;0>:d      r4.5<0;0>:d       0:w               {I@2}
        mov (8|M0)               r16.0<2>:ud   r1.2<0;1,0>:ud                   {I@2}
        mov (8|M0)               r16.1<2>:ud   r1.3<0;1,0>:ud                   {I@2}
        add3 (8|M0)              r6.0<1>:d     r7.0<1;0>:d       r11.1<4;2>:d      r5.0<1>:d       
        addc (8|M0)              r18.0<1>:ud   r16.0<2;1,0>:ud   r81.0<2;1,0>:ud  {AccWrEn,Compacted,I@2}
        mov (8|M0)               r14.1<2>:d    r6.0<1;1,0>:d                    {I@2}
        mov (8|M0)               r13.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mov (8|M0)               r7.0<1>:d     r84.0<1;1,0>:uw                 
        add3 (8|M0)              r6.0<1>:d     r13.0<1;0>:d      r16.1<4;2>:d      r5.0<1>:d        {I@2}
        mov (8|M0)               r11.0<2>:d    r18.0<1;1,0>:d                  
        mov (8|M0)               r11.1<2>:d    r6.0<1;1,0>:d                    {I@2}
        send.ugm (8|M0)          null     r14     r8:1    0x0            0x04000B84           {$8} // wr:2+1, rd:0; store.ugm.d16u32.a64
        send.ugm (8|M0)          null     r11     r7:1    0x0            0x04000B84           {A@1,$9} // wr:2+1, rd:0; store.ugm.d16u32.a64
L4952:
        join (16|M0)                         L7976                                
L4968:
        bfn.0xFE (1|M0)          r1.2<1>:ud    0x8:uw               r46.0<0;0>:ud     r48.4<0>:ud      // s0|s1|s2
        cmp (1|M0)    (lt)f1.0   null<1>:ud    r1.2<0;1,0>:ud    r3.7<0;1,0>:ud   {I@1}
(W)     and (1|M0)               f1.1<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
(~f1.1.any16h) goto (16|M0)                  L7792                  L7792                
L5032:
        shl (1|M0)               r85.12<1>:w   r48.12<0;1,0>:w   5:w              
        mov (1|M0)               r85.7<1>:d    0:w                              
L5064:
        mad (1|M0)               r1.3<1>:w     r85.12<0;0>:w     r85.14<0;0>:w     4:w               {I@1}
(W)     and (1|M0)               f1.0<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0x720:uw              {A@1}
        mov (1|M0)               r86.4<1>:f    r[a0.0]<0;1,0>:f                 {$3.dst}
(~f1.0.any16h) goto (16|M0)                  L5384                  L5384                 {A@1}
L5144:
        mov (1|M0)               r1.4<2>:hf    r[a0.0]<0;1,0>:f                
        cmp (1|M0)    (lt)f1.1   null<1>:f     r[a0.0]<0;1,0>:f  -4.001953e+00:f               {A@1}
        mov (1|M0)               r1.3<1>:f     r1.4<0;1,0>:hf                   {A@1}
        mov (1|M0)               r2.4<1>:ud    0xBD650000:ud                             
        sel (1|M0)    (lt)f0.0   r1.3<1>:f     r1.3<0;1,0>:f     4.0:f               {F@1}
        mov (1|M0)               r2.5<1>:ud    0x3EE50000:ud                             
(~f1.1) sel (1|M0)               r2.3<1>:f     r1.3<0;1,0>:f     -4.0:f               {F@1}
        mov (1|M0)               r5.1<1>:ud    0x3F650000:ud                             
        mad (1|M0)               r2.4<1>:f     r2.5<0;0>:f       r2.4<0;0>:f       (abs)r2.3<0>:f   {A@1}
        mov (1|M0)               r4.2<2>:hf    r2.4<0;1,0>:f                    {F@1}
        mov (1|M0)               r5.0<1>:f     r4.2<0;1,0>:hf                   {F@1}
        mad (1|M0)               r2.3<1>:f     r5.1<0;0>:f       r5.0<0;0>:f       r2.3<0>:f        {A@1}
        mov (1|M0)               r6.0<2>:hf    r2.3<0;1,0>:f                    {F@1}
        mul (1|M0)               r1.4<1>:hf    r1.4<0;1,0>:hf    r6.0<0;1,0>:hf   {F@1}
        mov (1|M0)               r86.4<1>:f    r1.4<0;1,0>:hf                   {F@1}
L5384:
        join (16|M0)                         L6104                                
L5400:
(W)     and (1|M0)               f1.1<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(f1.1.any16h) goto (16|M0)                   L5512                  L5512                
L5432:
(W)     mov (1|M0)               f1.1<1>:uw    r85.13<0;1,0>:uw                
        mov (1|M0)               r1.4<2>:hf    r86.4<0;1,0>:f                   {F@1}
        mov (1|M0)               r86.7<1>:f    r1.4<0;1,0>:hf                   {F@1}
(~f1.1) mov (1|M0)               r86.7<1>:f    r86.4<0;1,0>:f                  
        goto (16|M0)                         L5512                  L5960                
L5512:
        join (16|M0)                         L5960                                
L5528:
        cmp (1|M0)    (lt)f1.1   null<1>:f     r86.4<0;1,0>:f    0.0:f               {I@3}
(f1.1)  mov (1|M0)               r86.4<1>:f    -r86.4<0;1,0>:f                 
        sel (1|M0)    (lt)f0.0   r86.4<1>:f    r86.4<0;1,0>:f    448.0:f               {F@1}
        shr (1|M0)               r86.6<1>:ud   r86.4<0;1,0>:ud   0x17:uw              {F@1}
        and (1|M0)               r86.6<1>:ud   r86.6<0;1,0>:ud   0xFF:uw              {I@1}
        sel (1|M0)    (ge)f0.0   r86.6<1>:ud   r86.6<0;1,0>:ud   0x79:uw              {I@1}
        shl (1|M0)               r86.6<1>:ud   r86.6<0;1,0>:ud   0x17:uw              {I@1}
        add (1|M0)               r1.2<1>:ud    -r86.6<0;1,0>:ud  0x80800000:ud              {I@1}
        mul (1|M0)               r1.3<1>:f     r86.4<0;1,0>:f    r1.2<0;1,0>:f    {I@1}
        mov (1|M0)               r86.5<1>:d    r1.3<0;1,0>:f                    {F@1}
        mov (1|M0)               r86.7<1>:f    r86.5<0;1,0>:d                   {I@1}
        mad (1|M0)               r86.4<1>:f    -r86.7<0;0>:f     r1.2<0;0>:f       r86.4<0>:f       {F@1}
        cmp (1|M0)    (gt)f1.0   null<1>:f     r86.4<0;1,0>:f    0.5:f               {F@1}
(W)     and (1|M0)               f1.0<1>:uw    f1.0<0;1,0>:uw    0x1:uw              {F@1}
(f1.0.any16h) goto (16|M0)                   L5864                  L5864                
L5768:
        cmp (1|M0)    (lt)f1.0   null<1>:f     r86.4<0;1,0>:f    0.5:f               {A@1}
        and (1|M0)               r86.5<1>:d    r86.5<0;1,0>:d    1:w              
        add (1|M0)               r1.2<1>:f     r86.7<0;1,0>:f    1.0:f              
(~f1.0) cmp (1|M0)    (eq)f1.0   null<1>:d     r86.5<0;1,0>:d    0:w               {A@1}
(~f1.0) mov (1|M0)               r86.7<1>:f    r1.2<0;1,0>:f                    {F@1}
        goto (16|M0)                         L5864                  L5896                
L5864:
        join (16|M0)                         L5896                                
L5880:
        add (1|M0)               r86.7<1>:f    r86.7<0;1,0>:f    1.0:f               {F@1}
L5896:
        join (16|M0)                         L5960                                
L5912:
        add (1|M0)               r86.6<1>:ud   r86.6<0;1,0>:ud   0xFE800000:ud             
        mul (1|M0)               r86.7<1>:f    r86.7<0;1,0>:f    r86.6<0;1,0>:f   {A@1}
(f1.1)  mov (1|M0)               r86.7<1>:f    -r86.7<0;1,0>:f                  {F@1}
L5960:
        join (16|M0)                         L6104                                
L5976:
        shl (1|M0)               r1.3<1>:w     r85.14<0;1,0>:w   1:w              
        add (1|M0)               r85.7<1>:d    r85.7<0;1,0>:d    1:w              
(W)     mov (1|M0)               r2.6<2>:hf    r86.7<0;1,0>:f                   {F@1}
        cmp (1|M0)    (eq)f1.1   null<1>:d     r85.7<0;1,0>:d    8:w               {I@1}
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0xAA0:uw              {A@1}
        mov (1|M0)               r[a0.0]<1>:hf  r2.6<0;1,0>:hf                  {F@1}
(W)     and (1|M0)               f1.0<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(~f1.0.any16h) goto.b (16|M0)                L6104                  L5064                
L6104:
        join (16|M0)                         L7792                                
L6120:
        mov (1|M0)               r87.0<1>:d    0:w                              
L6136:
        mad (1|M0)               r1.3<1>:w     r85.12<0;0>:w     r87.0<0;0>:w      4:w               {I@1}
(W)     and (1|M0)               f1.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0x620:uw              {A@1}
        mov (1|M0)               r87.1<1>:f    r[a0.0]<0;1,0>:f                
(~f1.1.any16h) goto (16|M0)                  L6456                  L6456                 {A@1}
L6216:
        mov (1|M0)               r1.4<2>:hf    r[a0.0]<0;1,0>:f                
        cmp (1|M0)    (lt)f1.0   null<1>:f     r[a0.0]<0;1,0>:f  -4.001953e+00:f               {A@1}
        mov (1|M0)               r1.3<1>:f     r1.4<0;1,0>:hf                   {A@1}
        mov (1|M0)               r2.4<1>:ud    0xBD650000:ud                             
        sel (1|M0)    (lt)f0.0   r1.3<1>:f     r1.3<0;1,0>:f     4.0:f               {F@1}
        mov (1|M0)               r2.5<1>:ud    0x3EE50000:ud                             
(~f1.0) sel (1|M0)               r2.3<1>:f     r1.3<0;1,0>:f     -4.0:f               {F@1}
        mov (1|M0)               r5.1<1>:ud    0x3F650000:ud                             
        mad (1|M0)               r2.4<1>:f     r2.5<0;0>:f       r2.4<0;0>:f       (abs)r2.3<0>:f   {A@1}
        mov (1|M0)               r4.2<2>:hf    r2.4<0;1,0>:f                    {F@1}
        mov (1|M0)               r5.0<1>:f     r4.2<0;1,0>:hf                   {F@1}
        mad (1|M0)               r2.3<1>:f     r5.1<0;0>:f       r5.0<0;0>:f       r2.3<0>:f        {A@1}
        mov (1|M0)               r6.0<2>:hf    r2.3<0;1,0>:f                    {F@1}
        mul (1|M0)               r1.4<1>:hf    r1.4<0;1,0>:hf    r6.0<0;1,0>:hf   {F@1}
        mov (1|M0)               r87.1<1>:f    r1.4<0;1,0>:hf                   {F@1}
L6456:
        join (16|M0)                         L7168                                
L6472:
(W)     and (1|M0)               f1.0<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(f1.0.any16h) goto (16|M0)                   L6584                  L6584                
L6504:
(W)     mov (1|M0)               f1.0<1>:uw    r85.13<0;1,0>:uw                
        mov (1|M0)               r1.4<2>:hf    r87.1<0;1,0>:f                   {F@1}
        mov (1|M0)               r87.4<1>:f    r1.4<0;1,0>:hf                   {F@1}
(~f1.0) mov (1|M0)               r87.4<1>:f    r87.1<0;1,0>:f                  
        goto (16|M0)                         L6584                  L7032                
L6584:
        join (16|M0)                         L7032                                
L6600:
        cmp (1|M0)    (lt)f1.0   null<1>:f     r87.1<0;1,0>:f    0.0:f               {I@3}
(f1.0)  mov (1|M0)               r87.1<1>:f    -r87.1<0;1,0>:f                 
        sel (1|M0)    (lt)f0.0   r87.1<1>:f    r87.1<0;1,0>:f    448.0:f               {F@1}
        shr (1|M0)               r87.3<1>:ud   r87.1<0;1,0>:ud   0x17:uw              {F@1}
        and (1|M0)               r87.3<1>:ud   r87.3<0;1,0>:ud   0xFF:uw              {I@1}
        sel (1|M0)    (ge)f0.0   r87.3<1>:ud   r87.3<0;1,0>:ud   0x79:uw              {I@1}
        shl (1|M0)               r87.3<1>:ud   r87.3<0;1,0>:ud   0x17:uw              {I@1}
        add (1|M0)               r1.2<1>:ud    -r87.3<0;1,0>:ud  0x80800000:ud              {I@1}
        mul (1|M0)               r1.3<1>:f     r87.1<0;1,0>:f    r1.2<0;1,0>:f    {I@1}
        mov (1|M0)               r87.2<1>:d    r1.3<0;1,0>:f                    {F@1}
        mov (1|M0)               r87.4<1>:f    r87.2<0;1,0>:d                   {I@1}
        mad (1|M0)               r87.1<1>:f    -r87.4<0;0>:f     r1.2<0;0>:f       r87.1<0>:f       {F@1}
        cmp (1|M0)    (gt)f1.1   null<1>:f     r87.1<0;1,0>:f    0.5:f               {F@1}
(W)     and (1|M0)               f1.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw              {F@1}
(f1.1.any16h) goto (16|M0)                   L6936                  L6936                
L6840:
        cmp (1|M0)    (lt)f1.1   null<1>:f     r87.1<0;1,0>:f    0.5:f               {A@1}
        and (1|M0)               r87.2<1>:d    r87.2<0;1,0>:d    1:w              
        add (1|M0)               r1.2<1>:f     r87.4<0;1,0>:f    1.0:f              
(~f1.1) cmp (1|M0)    (eq)f1.1   null<1>:d     r87.2<0;1,0>:d    0:w               {A@1}
(~f1.1) mov (1|M0)               r87.4<1>:f    r1.2<0;1,0>:f                    {F@1}
        goto (16|M0)                         L6936                  L6968                
L6936:
        join (16|M0)                         L6968                                
L6952:
        add (1|M0)               r87.4<1>:f    r87.4<0;1,0>:f    1.0:f               {F@1}
L6968:
        join (16|M0)                         L7032                                
L6984:
        add (1|M0)               r87.3<1>:ud   r87.3<0;1,0>:ud   0xFE800000:ud             
        mul (1|M0)               r87.4<1>:f    r87.4<0;1,0>:f    r87.3<0;1,0>:f   {A@1}
(f1.0)  mov (1|M0)               r87.4<1>:f    -r87.4<0;1,0>:f                  {F@1}
L7032:
        join (16|M0)                         L7168                                
L7048:
        shl (1|M0)               r1.3<1>:w     r87.0<0;1,0>:w    1:w              
        add (1|M0)               r87.0<1>:d    r87.0<0;1,0>:d    1:w               {Compacted}
(W)     mov (1|M0)               r2.6<2>:hf    r87.4<0;1,0>:f                   {F@1}
        cmp (1|M0)    (eq)f1.0   null<1>:d     r87.0<0;1,0>:d    8:w               {I@1}
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0xAC0:uw              {A@1}
        mov (1|M0)               r[a0.0]<1>:hf  r2.6<0;1,0>:hf                  {F@1}
(W)     and (1|M0)               f1.0<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
(~f1.0.any16h) goto.b (16|M0)                L7168                  L6136                
L7168:
        join (16|M0)                         L7792                                
L7184:
        mov (2|M0)               r1.8<1>:w     0x90909090:uv                             
        mov (2|M0)               r6.0<1>:d     0x8:uv                             
        add (2|M0)               r5.0<1>:d     r1.8<1;1,0>:w     -9:w               {I@2}
        bfn.0xEA (2|M0)          r6.0<1>:ud    r6.0<1;0>:ud      r48.4<1;0>:ud     r5.0<1>:ud       {I@1} // s0|s1&s2
        mul (1|M0)               acc0.0<1>:ud  r6.0<0;1,0>:ud    r47.12<0;1,0>:uw {I@1}
        mach (1|M0)              r8.0<1>:ud    r6.0<0;1,0>:ud    r47.6<0;1,0>:ud  {AccWrEn,$8.src}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$9.src}
(W)     mul (1|M0)               acc0.0<1>:d   r6.0<0;1,0>:d     r47.14<0;1,0>:uw {Compacted}
        mach (1|M0)              r9.0<1>:d     r6.0<0;1,0>:d     r47.7<0;1,0>:d   {Compacted,$11.src}
(W)     mul (1|M0)               acc0.0<1>:d   r6.1<0;1,0>:d     r47.12<0;1,0>:uw
        mach (1|M0)              r10.0<1>:d    r6.1<0;1,0>:d     r47.6<0;1,0>:d   {$10.src}
        shl (1|M0)               r1.3<1>:d     r7.0<0;1,0>:d     1:w               {Compacted,I@5}
        add3 (1|M0)              r2.4<1>:d     r10.0<0;0>:d      r8.0<0;0>:d       r9.0<0>:d        {I@2}
        shr (1|M0)               r1.2<1>:ud    r7.0<0;1,0>:ud    0x1F:uw             
        addc (1|M0)              r5.0<1>:ud    r48.2<0;1,0>:ud   r1.3<0;1,0>:ud   {AccWrEn,I@3}
        shl (1|M0)               r4.1<1>:d     r2.4<0;1,0>:d     1:w               {I@3}
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        or (1|M0)                r1.4<1>:d     r4.1<0;1,0>:d     r1.2<0;1,0>:d    {I@2}
        mov (1|M0)               r11.2<1>:d    r5.0<0;1,0>:d                   
        add3 (1|M0)              r11.3<1>:d    r11.0<0;0>:d      r48.3<0;0>:d      r1.4<0>:d        {I@2}
        mov (8|M0)               r12.0<2>:ud   r11.2<0;1,0>:ud                  {I@2}
        mov (8|M0)               r12.1<2>:ud   r11.3<0;1,0>:ud                  {I@2}
        mov (8|M0)               r7.0<1>:d     r81.1<2;1,0>:d                  
        addc (8|M0)              r6.0<1>:ud    r12.0<2;1,0>:ud   r81.0<2;1,0>:ud  {AccWrEn,Compacted,I@2}
        mov (8|M0)               r10.0<1>:d    r85.0<1;1,0>:uw                 
        mov (8|M0)               r9.0<1>:ud    acc0.0<1;1,0>:ud                 {Compacted}
        addc (1|M0)              r5.0<1>:ud    r11.2<0;1,0>:ud   0x10:ud              {AccWrEn}
        mov (8|M0)               r14.0<2>:d    r6.0<1;1,0>:d                    {I@4}
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r1.2<1>:d     r5.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r1.3<1>:d     r11.0<0;0>:d      r11.3<0;0>:d      0:w               {I@2}
        mov (8|M0)               r16.0<2>:ud   r1.2<0;1,0>:ud                   {I@2}
        mov (8|M0)               r16.1<2>:ud   r1.3<0;1,0>:ud                   {I@2}
        add3 (8|M0)              r8.0<1>:d     r9.0<1;0>:d       r12.1<4;2>:d      r7.0<1>:d       
        addc (8|M0)              r18.0<1>:ud   r16.0<2;1,0>:ud   r81.0<2;1,0>:ud  {AccWrEn,Compacted,I@2}
        mov (8|M0)               r14.1<2>:d    r8.0<1;1,0>:d                    {I@2}
        mov (8|M0)               r6.0<1>:ud    acc0.0<1;1,0>:ud                 {Compacted}
        mov (8|M0)               r9.0<1>:d     r86.0<1;1,0>:uw                  {F@1}
        add3 (8|M0)              r8.0<1>:d     r6.0<1;0>:d       r16.1<4;2>:d      r7.0<1>:d        {I@2}
        mov (8|M0)               r12.0<2>:d    r18.0<1;1,0>:d                  
        mov (8|M0)               r12.1<2>:d    r8.0<1;1,0>:d                    {I@2}
        send.ugm (8|M0)          null     r14     r10:1   0x0            0x04000B84           {$10} // wr:2+1, rd:0; store.ugm.d16u32.a64
        send.ugm (8|M0)          null     r12     r9:1    0x0            0x04000B84           {A@1,$11} // wr:2+1, rd:0; store.ugm.d16u32.a64
L7792:
        join (16|M0)                         L7976                                
L7808:
        addc (1|M0)              r5.0<1>:ud    r48.4<0;1,0>:ud   0x1:ud              {AccWrEn}
        add (1|M0)               r48.6<1>:d    r48.6<0;1,0>:d    1:w              
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r87.6<1>:d    r5.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r87.7<1>:d    r6.0<0;0>:d       r48.5<0;0>:d      0:w               {I@2}
        cmp (1|M0)    (eq)f0.1   null<1>:d     r87.7<0;1,0>:d    0:w               {I@1}
(f0.1)  cmp (1|M0)    (eq)f0.1   null<1>:d     r87.6<0;1,0>:d    8:w              
(W)     and (1|M0)               f0.1<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(f0.1.any16h) goto (16|M0)                   L7976                  L7976                
L7944:
(W)     mov (2|M0)               r48.4<1>:ud   r87.6<1;1,0>:ud                 
        goto.b (16|M0)                       L7976                  L2104                
L7976:
        join (16|M0)                         L7992                                
L7992:
(W)     mov (8|M0)               r127.0<1>:f   r0.0<1;1,0>:f                    {Compacted}
(W)     send.ugm (1|M0)          r5       r0      null:0  0x0            0x0210641F           {$12} // wr:1+0, rd:1; fence invalid flush type scoped to tile
(W)     mov (8|M0)               null<1>:ud    r5.0<1;1,0>:ud                   {$12.dst}
(W)     send.gtwy (1|M0)         null     r127    null:0  0x0            0x02000010           {EOT,A@1} // wr:1+0, rd:0; end of thread
L8048:
        mov (1|M0)               r1.2<1>:d     cr0.0<0;1,0>:ud                  {A@1}
        and (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   -1265:w               {A@1}
        or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   1264:w               {A@1}
        mov (1|M0)               r1.3<1>:f     (abs)r88.1<0;1,0>:d              {A@1}
        mov (1|M0)               r4.3<1>:f     0xB4C00000:f                               {Compacted}
        math.inv (1|M0)          r4.2<1>:f     r1.3<0;1,0>:f                    {@2,$13}
        mov (1|M0)               r2.4<1>:f     (abs)r88.0<0;1,0>:d              {Compacted}
        sync.nop                             null                             {Compacted,$13.dst}
        mad (1|M0)               r4.2<1>:f     r4.2<0;0>:f       r4.3<0;0>:f       r4.2<0>:f        {F@2}
        mov (2|M0)               r1.4<1>:d     (abs)r88.0<1;1,0>:d             
        mov (1|M0)               r1.6<1>:ud    r1.3<0;1,0>:f                   
        mov (1|M0)               r2.5<1>:ud    r2.4<0;1,0>:f                    {F@2}
        mul (1|M0)               r5.0<1>:f     r4.2<0;1,0>:f     r2.4<0;1,0>:f    {A@1}
        add (1|M0)               r1.6<1>:ud    r1.5<0;1,0>:ud    -r1.6<0;1,0>:ud  {I@2}
        add (1|M0)               r2.5<1>:ud    r1.4<0;1,0>:ud    -r2.5<0;1,0>:ud  {I@2}
        mov (1|M0)               r6.0<1>:ud    r5.0<0;1,0>:f                    {F@1}
        mov (1|M0)               r2.3<1>:f     r1.6<0;1,0>:ud                   {I@3}
        mov (1|M0)               r4.1<1>:f     r2.5<0;1,0>:ud                   {I@2}
        mov (1|M0)               r6.1<1>:f     r6.0<0;1,0>:ud                   {Compacted,I@1}
        xor (1|M0)               r88.1<1>:d    r88.1<0;1,0>:d    r88.0<0;1,0>:d   {Compacted}
        mad (1|M0)               r2.4<1>:f     r2.4<0;0>:f       r6.1<0;0>:f       -r1.3<0>:f       {F@1}
        mad (1|M0)               r6.1<1>:f     r4.1<0;0>:f       r6.1<0;0>:f       -r2.3<0>:f      
(W)     mov (1|M0)               r5.0<1>:hf    0x1:hf                             
        add (1|M0)               r2.4<1>:f     r2.4<0;1,0>:f     r6.1<0;1,0>:f    {F@2}
        asr (1|M0)               r88.1<1>:d    r88.1<0;1,0>:d    31:w               {Compacted,I@1}
        mul (1|M0)               r4.2<1>:f     r4.2<0;1,0>:f     r2.4<0;1,0>:f    {F@1}
        mov (1|M0)               r7.0<1>:ud    r4.2<0;1,0>:f                    {F@1}
        add (1|M0)               r6.0<1>:ud    r6.0<0;1,0>:ud    r7.0<0;1,0>:ud   {Compacted,I@1}
(W)     mul (1|M0)               acc0.0<1>:ud  r6.0<0;1,0>:ud    r1.10<0;1,0>:uw  {I@1}
        mach (1|M0)              r8.0<1>:ud    r6.0<0;1,0>:ud    r1.5<0;1,0>:ud   {Compacted}
        add (1|M0)               r1.4<1>:ud    r1.4<0;1,0>:ud    -r8.0<0;1,0>:ud  {I@1}
        cmp (1|M0)    (ge)f1.1   null<1>:ud    r1.4<0;1,0>:ud    r1.5<0;1,0>:ud   {I@1}
(f1.1)  sel (1|M0)               r9.0<1>:d     r5.0<0;1,0>:w     0:w              
        add3 (1|M0)              r6.0<1>:d     r6.0<0;0>:d       r88.1<0;0>:d      r9.0<0>:d        {I@1}
        xor (1|M0)               r46.0<1>:d    r6.0<0;1,0>:d     r88.1<0;1,0>:d   {Compacted,I@1}
        mov (1|M0)               cr0.0<1>:ud   r1.2<0;1,0>:d                    {A@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        ret (16|M0)                          r88.2                            {A@1}
L8600:
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
