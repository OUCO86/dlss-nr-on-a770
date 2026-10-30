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
        and (1|M0)               r46.0<2>:b    r4.16<0;1,0>:b    1:w               {$2.dst}
        sync.nop                             null                             {Compacted,$1.dst}
(W)     mul (1|M0)               acc0.0<1>:d   r47.0<0;1,0>:d    r2.0<0;1,0>:uw   {Compacted,I@2}
        mach (1|M0)              r47.0<1>:d    r47.0<0;1,0>:d    r2.0<0;1,0>:d    {Compacted}
        mov (1|M0)               r107.1<1>:d   r2.6<0;1,0>:d                   
        sync.nop                             null                             {Compacted,$0.dst}
        add (1|M0)               r47.0<1>:d    r47.0<0;1,0>:d    r1.0<0;1,0>:uw   {I@2}
        mov (1|M0)               r107.0<1>:f   r47.0<0;1,0>:f                   {Compacted,I@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r107.2        L8992                                 {A@1}
L392:
        cmp (1|M0)    (gt)f1.1   null<1>:d     r2.7<0;1,0>:d     0:w              
(W)     mul (1|M0)               acc0.0<1>:d   r46.1<0;1,0>:d    r2.12<0;1,0>:uw 
        mach (1|M0)              r5.0<1>:d     r46.1<0;1,0>:d    r2.6<0;1,0>:d   
        mov (16|M0)              r49.0<1>:ud   0x0:ud                             
(W)     and (1|M0)               f0.0<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
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
(~f0.0.any16h) goto (16|M0)                  L1760                  L1760                
L664:
(W)     mul (1|M0)               acc0.0<1>:d   r46.1<0;1,0>:d    r2.14<0;1,0>:uw 
        mach (1|M0)              r5.0<1>:d     r46.1<0;1,0>:d    r2.7<0;1,0>:d   
(W)     mul (1|M0)               acc0.0<1>:d   r46.1<0;1,0>:d    r2.14<0;1,0>:uw 
        mov (1|M0)               r46.2<1>:d    r2.6<0;1,0>:d                   
        asr (1|M0)               r46.3<1>:d    r2.6<0;1,0>:d     31:w              
        mov (1|M0)               r46.4<1>:d    r47.0<0;1,0>:d                   {I@7}
        asr (1|M0)               r46.5<1>:d    r47.0<0;1,0>:d    31:w               {Compacted}
        mov (1|M0)               r46.6<1>:d    r2.7<0;1,0>:d                   
        mov (1|M0)               r46.7<1>:d    0:w                              
        mov (1|M0)               r47.2<2>:f    0.0:f                              
        mov (1|M0)               r47.3<2>:f    0.0:f                              
        mach (1|M0)              r48.0<1>:d    r46.1<0;1,0>:d    r2.7<0;1,0>:d   
        asr (1|M0)               r48.1<1>:d    r5.0<0;1,0>:d     31:w               {Compacted,I@7}
L856:
        addc (1|M0)              r5.0<1>:ud    r47.2<0;1,0>:ud   r48.0<0;1,0>:ud  {AccWrEn,A@2}
        shl (1|M0)               r7.0<1>:d     r5.0<0;1,0>:d     8:w               {Compacted,I@1}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        shl (1|M0)               r8.0<1>:d     r7.0<0;1,0>:d     1:w               {Compacted,I@2}
        add3 (1|M0)              r1.3<1>:d     r6.0<0;0>:d       r47.3<0;0>:d      r48.1<0>:d       {A@1}
        addc (1|M0)              r9.0<1>:ud    r3.0<0;1,0>:ud    r8.0<0;1,0>:ud   {AccWrEn,I@2}
        shr (1|M0)               r2.4<1>:ud    r5.0<0;1,0>:ud    0x18:uw             
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mul (1|M0)               acc0.0<1>:ud  r47.2<0;1,0>:ud   r46.4<0;1,0>:uw 
        mach (1|M0)              r13.0<1>:ud   r47.2<0;1,0>:ud   r46.2<0;1,0>:ud  {AccWrEn,$3.src}
        shr (1|M0)               r4.5<1>:ud    r7.0<0;1,0>:ud    0x1F:uw             
        mov (1|M0)               r12.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r47.2<0;1,0>:d    r46.6<0;1,0>:uw 
        mach (1|M0)              r5.0<1>:d     r47.2<0;1,0>:d    r46.3<0;1,0>:d  
(W)     mul (1|M0)               acc0.0<1>:d   r47.3<0;1,0>:d    r46.4<0;1,0>:uw 
        shl (1|M0)               r2.3<1>:d     r1.3<0;1,0>:d     8:w               {Compacted,I@7}
        mach (1|M0)              r6.0<1>:d     r47.3<0;1,0>:d    r46.2<0;1,0>:d  
        addc (1|M0)              r7.0<1>:ud    r12.0<0;1,0>:ud   r46.4<0;1,0>:ud  {AccWrEn,I@6}
        or (1|M0)                r7.1<1>:d     r2.3<0;1,0>:d     r2.4<0;1,0>:d    {I@3}
        add3 (1|M0)              r1.3<1>:d     r6.0<0;0>:d       r13.0<0;0>:d      r5.0<0>:d        {I@3}
        mov (1|M0)               r14.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        shl (1|M0)               r8.0<1>:d     r7.0<0;1,0>:d     8:w               {Compacted,I@4}
        shl (1|M0)               r3.7<1>:d     r7.1<0;1,0>:d     1:w               {I@4}
        add3 (1|M0)              r2.4<1>:d     r14.0<0;0>:d      r1.3<0;0>:d       r46.5<0>:d       {I@3}
        mov (1|M0)               r11.0<1>:f    r9.0<0;1,0>:f                    {Compacted}
        or (1|M0)                r8.1<1>:d     r3.7<0;1,0>:d     r4.5<0;1,0>:d    {I@2}
        shl (1|M0)               r9.0<1>:d     r8.0<0;1,0>:d     1:w               {Compacted,F@1}
        shl (1|M0)               r3.7<1>:d     r2.4<0;1,0>:d     8:w               {I@3}
        shr (1|M0)               r4.5<1>:ud    r7.0<0;1,0>:ud    0x18:uw             
        add3 (1|M0)              r11.1<1>:d    r10.0<0;0>:d      r3.1<0;0>:d       r8.1<0>:d        {I@4}
        addc (1|M0)              r5.0<1>:ud    r3.2<0;1,0>:ud    r9.0<0;1,0>:ud   {AccWrEn,I@4}
        or (1|M0)                r8.1<1>:d     r3.7<0;1,0>:d     r4.5<0;1,0>:d    {I@3}
        shr (1|M0)               r8.3<1>:ud    r8.0<0;1,0>:ud    0x1F:uw             
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r10.0<1>:f    r5.0<0;1,0>:f                    {Compacted,I@4}
        shl (1|M0)               r8.2<1>:d     r8.1<0;1,0>:d     1:w               {I@3}
        addc (1|M0)              r7.0<1>:ud    r11.0<0;1,0>:ud   0x100:ud              {AccWrEn}
        or (1|M0)                r9.1<1>:d     r8.2<0;1,0>:d     r8.3<0;1,0>:d    {I@2}
        mov (1|M0)               r20.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r5.0<1>:ud    r10.0<0;1,0>:ud   0x100:ud              {AccWrEn,F@1}
        add3 (1|M0)              r10.1<1>:d    r6.0<0;0>:d       r3.3<0;0>:d       r9.1<0>:d        {I@3}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r21.0<1>:f    r7.0<0;1,0>:f                    {Compacted}
        add3 (1|M0)              r21.1<1>:d    r20.0<0;0>:d      r11.1<0;0>:d      0:w               {I@4}
        mov (1|M0)               r8.0<1>:f     r5.0<0;1,0>:f                    {Compacted,I@4}
        add3 (1|M0)              r8.1<1>:d     r6.0<0;0>:d       r10.1<0;0>:d      0:w               {I@2}
        send.ugm (1|M0)          r12      r11     null:0  0x0            0x0280E780           {$4} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        send.ugm (1|M0)          r30      r10     null:0  0x0            0x0280E780           {$5} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        send.ugm (1|M0)          r22      r21     null:0  0x0            0x0280E780           {A@2,$6} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        send.ugm (1|M0)          r38      r8      null:0  0x0            0x0280E780           {A@1,$7} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        addc (1|M0)              r7.0<1>:ud    r47.2<0;1,0>:ud   0x1:ud              {AccWrEn}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r47.4<1>:d    r7.0<0;1,0>:d                    {I@2}
        add3 (1|M0)              r47.5<1>:d    r9.0<0;0>:d       r47.3<0;0>:d      0:w               {I@2}
        cmp (1|M0)    (eq)f0.0   null<1>:d     r47.5<0;1,0>:d    r46.7<0;1,0>:d   {I@1}
(f0.0)  cmp (1|M0)    (eq)f0.0   null<1>:d     r47.4<0;1,0>:d    r46.6<0;1,0>:d  
(W)     and (1|M0)               f1.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
        sync.allwr                           ($3,$4,$5,$6,$7)                
        dpas.8x8 (8|M0)          r73:f         r73:f             r30:hf            r12.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r57:f         r57:f             r30:hf            r22.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r65:f         r65:f             r38:hf            r12.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r49:f         r49:f             r38:hf            r22.0:hf         {$3}
(f1.1.any16h) goto (16|M0)                   L1760                  L1760                
L1728:
(W)     mov (2|M0)               r47.2<1>:ud   r47.4<1;1,0>:ud                 
        goto.b (16|M0)                       L1760                  L856                
L1760:
        join (16|M0)                         L1776                                
L1776:
        mov (4|M0)               r10.0<1>:w    0x64206420:v                              
        shl (1|M0)               r1.2<1>:d     r47.0<0;1,0>:d    4:w               {Compacted}
        mov (4|M0)               r11.0<4>:uw   r10.0<1;1,0>:uw                  {I@2}
        shl (1|M0)               r47.6<1>:d    r1.2<0;1,0>:d     2:w               {I@2}
        mov (4|M0)               r83.0<2>:d    r11.0<4;1,0>:w                   {I@2}
        shr (1|M0)               r1.4<1>:ud    r1.2<0;1,0>:ud    0x1E:uw             
        addc (1|M0)              r5.0<1>:ud    r3.4<0;1,0>:ud    r47.6<0;1,0>:ud  {AccWrEn,I@3}
        asr (4|M0)               r83.1<2>:d    r83.0<2;1,0>:d    31:w               {I@3}
        or (1|M0)                r47.7<1>:d    r1.4<0;1,0>:d     0:w               {I@3}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r7.0<1>:f     r5.0<0;1,0>:f                    {Compacted,I@4}
        addc (1|M0)              r8.0<1>:ud    r4.0<0;1,0>:ud    r47.6<0;1,0>:ud  {AccWrEn}
        mov (4|M0)               r5.0<2>:ud    r83.0<2;1,0>:ud                  {A@1}
        mov (4|M0)               r5.1<2>:ud    r83.1<2;1,0>:ud                 
        add3 (1|M0)              r7.1<1>:d     r6.0<0;0>:d       r3.5<0;0>:d       r47.7<0>:d       {I@4}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (4|M0)              r6.0<1>:ud    r5.0<2;1,0>:ud    0x8:ud              {AccWrEn,I@3}
        send.ugm (1|M0)          r81      r7      null:0  0x0            0x0220C780           {A@3,$8} // wr:1+0, rd:2; load.ugm.d64x8t.a64
        mov (1|M0)               r48.3<1>:d    r8.0<0;1,0>:d                   
        mov (4|M0)               r7.0<1>:ud    acc0.0<1;1,0>:ud                 {$8.src}
        addc (4|M0)              r8.0<1>:ud    r5.0<2;1,0>:ud    0x10:ud              {AccWrEn}
        add3 (1|M0)              r48.4<1>:d    r9.0<0;0>:d       r4.1<0;0>:d       r47.7<0>:d       {I@5}
        mov (4|M0)               r9.0<1>:ud    acc0.0<1;1,0>:ud                
        addc (4|M0)              r10.0<1>:ud   r5.0<2;1,0>:ud    0x18:ud              {AccWrEn}
        mov (1|M0)               r48.6<1>:d    0:w                              
        shr (1|M0)               r2.3<1>:ud    r1.2<0;1,0>:ud    0x1F:uw             
        mov (4|M0)               r11.0<1>:ud   acc0.0<1;1,0>:ud                
        shl (1|M0)               r46.1<1>:d    r46.1<0;1,0>:d    4:w               {Compacted}
        and (1|M0)               r47.1<1>:d    r4.3<0;1,0>:d     -2:w              
        and (1|M0)               r48.2<1>:d    r4.3<0;1,0>:d     -3:w              
        mov (1|M0)               r48.7<1>:d    0:w                              
        shl (1|M0)               r48.5<1>:d    r1.2<0;1,0>:d     1:w              
        mov (4|M0)               r84.0<2>:d    r6.0<1;1,0>:d                   
        mov (4|M0)               r85.0<2>:d    r8.0<1;1,0>:d                   
        mov (4|M0)               r86.0<2>:d    r10.0<1;1,0>:d                   {I@7}
        or (1|M0)                r48.6<1>:d    r48.6<0;1,0>:d    r2.3<0;1,0>:d    {I@7}
        add3 (4|M0)              r84.1<2>:d    r7.0<1;0>:d       r5.1<4;2>:d       0:w              
        add3 (4|M0)              r85.1<2>:d    r9.0<1;0>:d       r5.1<4;2>:d       0:w              
        add3 (4|M0)              r86.1<2>:d    r11.0<1;0>:d      r5.1<4;2>:d       0:w              
L2360:
        or (1|M0)                r94.7<1>:d    r48.7<0;1,0>:d    r46.1<0;1,0>:d   {I@7}
        cmp (1|M0)    (eq)f0.0   null<1>:w     r46.0<0;1,0>:b    0:w              
        cmp (1|M0)    (lt)f1.0   null<1>:ud    r94.7<0;1,0>:ud   r3.6<0;1,0>:ud   {I@2}
        cmp (1|M0)    (eq)f1.1   null<1>:d     r4.3<0;1,0>:d     4:w              
        cmp (1|M0)    (eq)f0.1   null<1>:d     r48.2<0;1,0>:d    1:w              
(W)     mov (1|M0)               r107.8<1>:uw  f0.0<0;1,0>:uw                   {Compacted}
(W)     and (1|M0)               f1.0<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
        cmp (1|M0)    (eq)f0.0   null<1>:d     r47.1<0;1,0>:d    2:w              
(W)     mov (1|M0)               r102.7<1>:uw  f1.1<0;1,0>:uw                  
(~f1.0.any16h) goto (16|M0)                  L5624                  L5624                
L2512:
        mul (1|M0)               acc0.0<1>:d   r94.7<0;1,0>:d    r4.4<0;1,0>:uw  
        sync.nop                             null                             {Compacted,$14.src}
        mach (1|M0)              r6.0<1>:d     r94.7<0;1,0>:d    r4.2<0;1,0>:d    {AccWrEn,$11.src}
        shl (1|M0)               r46.1<1>:w    r48.14<0;1,0>:w   5:w              
        mov (1|M0)               r5.0<1>:d     acc0.0<0;1,0>:d                 
        mov (1|M0)               r91.1<1>:d    r6.0<0;1,0>:d                    {I@3}
        mov (1|M0)               r91.0<1>:f    r5.0<0;1,0>:f                    {Compacted,I@2}
        shl (1|M0)               r1.2<1>:d     r91.1<0;1,0>:d    2:w               {I@1}
        shl (1|M0)               r91.2<1>:d    r91.0<0;1,0>:d    2:w               {Compacted,F@1}
        shr (1|M0)               r1.3<1>:ud    r91.0<0;1,0>:ud   0x1E:uw             
        addc (1|M0)              r7.0<1>:ud    r48.3<0;1,0>:ud   r91.2<0;1,0>:ud  {AccWrEn,I@2}
        or (1|M0)                r91.3<1>:d    r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        sync.allrd                           ($10,$13)                
        mov (1|M0)               r9.0<1>:f     r7.0<0;1,0>:f                    {Compacted,I@2}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r10.0<1>:ud   r9.0<0;1,0>:ud    0x20:ud              {AccWrEn,F@1}
        add3 (1|M0)              r9.1<1>:d     r8.0<0;0>:d       r48.4<0;0>:d      r91.3<0>:d       {I@2}
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r6.0<1>:f     r10.0<0;1,0>:f                   {Compacted,I@3}
        add3 (1|M0)              r6.1<1>:d     r5.0<0;0>:d       r9.1<0;0>:d       0:w               {I@1}
        send.ugm (1|M0)          r92      r9      null:0  0x0            0x0210B780           {$15} // wr:1+0, rd:1; load.ugm.d64x4t.a64
        send.ugm (1|M0)          r93      r6      null:0  0x0            0x0210B780           {A@1,$11} // wr:1+0, rd:1; load.ugm.d64x4t.a64
        mov (1|M0)               r91.4<1>:d    0:w                              
L2824:
        shl (1|M0)               r91.10<1>:w   r91.8<0;1,0>:w    2:w               {I@1}
        mad (1|M0)               r1.3<1>:w     r46.1<0;0>:w      r91.8<0;0>:w      4:w              
        add (1|M0)               a0.1<1>:uw    r91.10<0;1,0>:uw  0xB80:uw              {A@1}
        add (1|M0)               a0.0<1>:uw    r91.10<0;1,0>:uw  0xA20:uw              {A@1}
(W)     and (1|M0)               f1.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
        sync.nop                             null                             {Compacted,$15.dst}
        mul (1|M0)               r91.6<1>:f    r[a0.1]<0;1,0>:f  r[a0.0]<0;1,0>:f {$8.dst}
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0x920:uw              {A@1}
        sync.nop                             null                             {Compacted,$3.dst}
        add (1|M0)               r91.6<1>:f    r91.6<0;1,0>:f    r[a0.0]<0;1,0>:f {F@1}
(~f1.1.any16h) goto (16|M0)                  L3232                  L3232                 {A@1}
L2984:
        mov (1|M0)               r1.4<2>:hf    r91.6<0;1,0>:f                   {F@1}
        cmp (1|M0)    (lt)f1.0   null<1>:f     r91.6<0;1,0>:f    -4.001953e+00:f              
        mov (1|M0)               r1.3<1>:f     r1.4<0;1,0>:hf                   {F@2}
        mov (1|M0)               r2.4<1>:ud    0xBD650000:ud                             
        sel (1|M0)    (lt)f0.0   r1.3<1>:f     r1.3<0;1,0>:f     4.0:f               {F@1}
        mov (1|M0)               r2.5<1>:ud    0x3EE50000:ud                             
(~f1.0) sel (1|M0)               r2.3<1>:f     r1.3<0;1,0>:f     -4.0:f               {F@1}
        mov (1|M0)               r5.0<1>:ud    0x3F650000:ud                             
        mad (1|M0)               r2.4<1>:f     r2.5<0;0>:f       r2.4<0;0>:f       (abs)r2.3<0>:f   {A@1}
        mov (1|M0)               r3.14<2>:hf   r2.4<0;1,0>:f                    {F@1}
        mov (1|M0)               r4.5<1>:f     r3.14<0;1,0>:hf                  {F@1}
        mad (1|M0)               r2.3<1>:f     r5.0<0;0>:f       r4.5<0;0>:f       r2.3<0>:f        {A@1}
        sync.nop                             null                             {Compacted,$11.src}
        mov (1|M0)               r6.0<2>:hf    r2.3<0;1,0>:f                    {F@1}
        mul (1|M0)               r1.4<1>:hf    r1.4<0;1,0>:hf    r6.0<0;1,0>:hf   {F@1}
        mov (1|M0)               r91.6<1>:f    r1.4<0;1,0>:hf                   {F@1}
L3232:
        join (16|M0)                         L3904                                
L3248:
(W)     and (1|M0)               f1.0<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(f1.0.any16h) goto (16|M0)                   L3360                  L3360                
L3280:
(W)     mov (1|M0)               f1.0<1>:uw    r102.7<0;1,0>:uw                
        mov (1|M0)               r1.4<2>:hf    r91.6<0;1,0>:f                   {F@1}
        mov (1|M0)               r94.1<1>:f    r1.4<0;1,0>:hf                   {F@1}
(~f1.0) mov (1|M0)               r94.1<1>:f    r91.6<0;1,0>:f                  
        goto (16|M0)                         L3360                  L3792                
L3360:
        join (16|M0)                         L3792                                
L3376:
        cmp (1|M0)    (lt)f1.0   null<1>:f     r91.6<0;1,0>:f    0.0:f               {I@3}
(f1.0)  mov (1|M0)               r91.6<1>:f    -r91.6<0;1,0>:f                 
        sel (1|M0)    (lt)f0.0   r91.6<1>:f    r91.6<0;1,0>:f    448.0:f               {F@1}
        shr (1|M0)               r94.0<1>:ud   r91.6<0;1,0>:ud   0x17:uw              {F@1}
        and (1|M0)               r94.0<1>:ud   r94.0<0;1,0>:ud   0xFF:uw              {I@1}
        sel (1|M0)    (ge)f0.0   r94.0<1>:ud   r94.0<0;1,0>:ud   0x79:uw              {I@1}
        shl (1|M0)               r94.0<1>:ud   r94.0<0;1,0>:ud   0x17:uw              {I@1}
        add (1|M0)               r1.2<1>:ud    -r94.0<0;1,0>:ud  0x80800000:ud              {I@1}
        mul (1|M0)               r1.3<1>:f     r91.6<0;1,0>:f    r1.2<0;1,0>:f    {I@1}
        mov (1|M0)               r91.7<1>:d    r1.3<0;1,0>:f                    {F@1}
        mov (1|M0)               r94.1<1>:f    r91.7<0;1,0>:d                   {I@1}
        mad (1|M0)               r91.6<1>:f    -r94.1<0;0>:f     r1.2<0;0>:f       r91.6<0>:f       {F@1}
        cmp (1|M0)    (gt)f1.1   null<1>:f     r91.6<0;1,0>:f    0.5:f               {F@1}
(W)     and (1|M0)               f1.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw              {F@1}
(f1.1.any16h) goto (16|M0)                   L3712                  L3712                
L3616:
        cmp (1|M0)    (lt)f1.1   null<1>:f     r91.6<0;1,0>:f    0.5:f               {A@1}
        and (1|M0)               r91.7<1>:d    r91.7<0;1,0>:d    1:w              
        add (1|M0)               r1.2<1>:f     r94.1<0;1,0>:f    1.0:f              
(~f1.1) cmp (1|M0)    (eq)f1.1   null<1>:d     r91.7<0;1,0>:d    0:w               {A@1}
(~f1.1) mov (1|M0)               r94.1<1>:f    r1.2<0;1,0>:f                    {F@1}
        goto (16|M0)                         L3712                  L3736                
L3712:
        join (16|M0)                         L3736                                
L3728:
        add (1|M0)               r94.1<1>:f    r94.1<0;1,0>:f    1.0:f               {Compacted,F@1}
L3736:
        join (16|M0)                         L3792                                
L3752:
        add (1|M0)               r94.0<1>:ud   r94.0<0;1,0>:ud   0xFE800000:ud             
        mul (1|M0)               r94.1<1>:f    r94.1<0;1,0>:f    r94.0<0;1,0>:f   {Compacted,A@1}
(f1.0)  mov (1|M0)               r94.1<1>:f    -r94.1<0;1,0>:f                  {F@1}
L3792:
        join (16|M0)                         L3904                                
L3808:
        add (1|M0)               r91.4<1>:d    r91.4<0;1,0>:d    1:w              
        add (1|M0)               a0.0<1>:uw    r91.10<0;1,0>:uw  0xAE0:uw              {A@1}
        cmp (1|M0)    (eq)f1.0   null<1>:d     r91.4<0;1,0>:d    8:w               {A@1}
        mov (1|M0)               r[a0.0]<1>:f  r94.1<0;1,0>:f                  
(W)     and (1|M0)               f1.1<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
(~f1.1.any16h) goto.b (16|M0)                L3904                  L2824                
L3904:
        join (16|M0)                         L5624                                
L3920:
        mov (1|M0)               r94.2<1>:d    0:w                              
L3936:
        shl (1|M0)               r91.11<1>:w   r94.4<0;1,0>:w    2:w               {I@1}
        mad (1|M0)               r1.3<1>:w     r46.1<0;0>:w      r94.4<0;0>:w      4:w              
        add (1|M0)               a0.1<1>:uw    r91.11<0;1,0>:uw  0xBA0:uw              {A@1}
        add (1|M0)               a0.0<1>:uw    r91.11<0;1,0>:uw  0xA20:uw              {A@1}
(W)     and (1|M0)               f1.0<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
        mul (1|M0)               r94.3<1>:f    r[a0.1]<0;1,0>:f  r[a0.0,32]<0;1,0>:f {$11.dst}
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0x820:uw              {A@1}
        add (1|M0)               r94.3<1>:f    r94.3<0;1,0>:f    r[a0.0]<0;1,0>:f {F@1}
(~f1.0.any16h) goto (16|M0)                  L4320                  L4320                 {A@1}
L4080:
        mov (1|M0)               r1.4<2>:hf    r94.3<0;1,0>:f                   {F@1}
        cmp (1|M0)    (lt)f1.1   null<1>:f     r94.3<0;1,0>:f    -4.001953e+00:f              
        mov (1|M0)               r1.3<1>:f     r1.4<0;1,0>:hf                   {F@2}
        mov (1|M0)               r2.4<1>:ud    0xBD650000:ud                             
        sel (1|M0)    (lt)f0.0   r1.3<1>:f     r1.3<0;1,0>:f     4.0:f               {F@1}
        mov (1|M0)               r2.5<1>:ud    0x3EE50000:ud                             
(~f1.1) sel (1|M0)               r2.3<1>:f     r1.3<0;1,0>:f     -4.0:f               {F@1}
        mov (1|M0)               r5.0<1>:ud    0x3F650000:ud                             
        mad (1|M0)               r2.4<1>:f     r2.5<0;0>:f       r2.4<0;0>:f       (abs)r2.3<0>:f   {A@1}
        mov (1|M0)               r3.14<2>:hf   r2.4<0;1,0>:f                    {F@1}
        mov (1|M0)               r4.5<1>:f     r3.14<0;1,0>:hf                  {F@1}
        mad (1|M0)               r2.3<1>:f     r5.0<0;0>:f       r4.5<0;0>:f       r2.3<0>:f        {A@1}
        mov (1|M0)               r6.0<2>:hf    r2.3<0;1,0>:f                    {F@1}
        mul (1|M0)               r1.4<1>:hf    r1.4<0;1,0>:hf    r6.0<0;1,0>:hf   {F@1}
        mov (1|M0)               r94.3<1>:f    r1.4<0;1,0>:hf                   {F@1}
L4320:
        join (16|M0)                         L5024                                
L4336:
(W)     and (1|M0)               f1.1<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(f1.1.any16h) goto (16|M0)                   L4448                  L4448                
L4368:
(W)     mov (1|M0)               f1.1<1>:uw    r102.7<0;1,0>:uw                
        mov (1|M0)               r1.4<2>:hf    r94.3<0;1,0>:f                   {F@1}
        mov (1|M0)               r94.6<1>:f    r1.4<0;1,0>:hf                   {F@1}
(~f1.1) mov (1|M0)               r94.6<1>:f    r94.3<0;1,0>:f                  
        goto (16|M0)                         L4448                  L4896                
L4448:
        join (16|M0)                         L4896                                
L4464:
        cmp (1|M0)    (lt)f1.1   null<1>:f     r94.3<0;1,0>:f    0.0:f               {I@3}
(f1.1)  mov (1|M0)               r94.3<1>:f    -r94.3<0;1,0>:f                 
        sel (1|M0)    (lt)f0.0   r94.3<1>:f    r94.3<0;1,0>:f    448.0:f               {F@1}
        shr (1|M0)               r94.5<1>:ud   r94.3<0;1,0>:ud   0x17:uw              {F@1}
        and (1|M0)               r94.5<1>:ud   r94.5<0;1,0>:ud   0xFF:uw              {I@1}
        sel (1|M0)    (ge)f0.0   r94.5<1>:ud   r94.5<0;1,0>:ud   0x79:uw              {I@1}
        shl (1|M0)               r94.5<1>:ud   r94.5<0;1,0>:ud   0x17:uw              {I@1}
        add (1|M0)               r1.2<1>:ud    -r94.5<0;1,0>:ud  0x80800000:ud              {I@1}
        mul (1|M0)               r1.3<1>:f     r94.3<0;1,0>:f    r1.2<0;1,0>:f    {I@1}
        mov (1|M0)               r94.4<1>:d    r1.3<0;1,0>:f                    {F@1}
        mov (1|M0)               r94.6<1>:f    r94.4<0;1,0>:d                   {I@1}
        mad (1|M0)               r94.3<1>:f    -r94.6<0;0>:f     r1.2<0;0>:f       r94.3<0>:f       {F@1}
        cmp (1|M0)    (gt)f1.0   null<1>:f     r94.3<0;1,0>:f    0.5:f               {F@1}
(W)     and (1|M0)               f1.0<1>:uw    f1.0<0;1,0>:uw    0x1:uw              {F@1}
(f1.0.any16h) goto (16|M0)                   L4800                  L4800                
L4704:
        cmp (1|M0)    (lt)f1.0   null<1>:f     r94.3<0;1,0>:f    0.5:f               {A@1}
        and (1|M0)               r94.4<1>:d    r94.4<0;1,0>:d    1:w              
        add (1|M0)               r1.2<1>:f     r94.6<0;1,0>:f    1.0:f              
(~f1.0) cmp (1|M0)    (eq)f1.0   null<1>:d     r94.4<0;1,0>:d    0:w               {A@1}
(~f1.0) mov (1|M0)               r94.6<1>:f    r1.2<0;1,0>:f                    {F@1}
        goto (16|M0)                         L4800                  L4832                
L4800:
        join (16|M0)                         L4832                                
L4816:
        add (1|M0)               r94.6<1>:f    r94.6<0;1,0>:f    1.0:f               {F@1}
L4832:
        join (16|M0)                         L4896                                
L4848:
        add (1|M0)               r94.5<1>:ud   r94.5<0;1,0>:ud   0xFE800000:ud             
        mul (1|M0)               r94.6<1>:f    r94.6<0;1,0>:f    r94.5<0;1,0>:f   {A@1}
(f1.1)  mov (1|M0)               r94.6<1>:f    -r94.6<0;1,0>:f                  {F@1}
L4896:
        join (16|M0)                         L5024                                
L4912:
        add (1|M0)               r94.2<1>:d    r94.2<0;1,0>:d    1:w              
        or (1|M0)                r1.3<1>:uw    r91.11<0;1,0>:uw  0x20:uw             
        cmp (1|M0)    (eq)f1.0   null<1>:d     r94.2<0;1,0>:d    8:w               {I@2}
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0xAE0:uw              {A@1}
        mov (1|M0)               r[a0.0]<1>:f  r94.6<0;1,0>:f                   {F@1}
(W)     and (1|M0)               f1.0<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
(~f1.0.any16h) goto.b (16|M0)                L5024                  L3936                
L5024:
        join (16|M0)                         L5624                                
L5040:
(W)     and (1|M0)               f1.1<1>:uw    r107.8<0;1,0>:uw  0x1:uw             
(f1.1.any16h) goto (16|M0)                   L5504                  L5504                
L5072:
        addc (1|M0)              r6.0<1>:ud    r4.6<0;1,0>:ud    r48.5<0;1,0>:ud  {AccWrEn}
        shl (1|M0)               r1.6<1>:d     r91.0<0;1,0>:d    1:w               {Compacted}
        shl (1|M0)               r1.4<1>:d     r91.1<0;1,0>:d    1:w              
        shr (1|M0)               r1.5<1>:ud    r91.0<0;1,0>:ud   0x1F:uw             
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r8.0<1>:ud    r6.0<0;1,0>:ud    r1.6<0;1,0>:ud   {AccWrEn,I@4}
        or (1|M0)                r1.7<1>:d     r1.4<0;1,0>:d     r1.5<0;1,0>:d    {I@3}
        add3 (1|M0)              r1.3<1>:d     r7.0<0;0>:d       r4.7<0;0>:d       r48.6<0>:d       {I@3}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r2.4<1>:d     r8.0<0;1,0>:d                    {I@4}
        add3 (1|M0)              r2.5<1>:d     r9.0<0;0>:d       r1.3<0;0>:d       r1.7<0>:d        {I@2}
        mov (8|M0)               r10.0<2>:ud   r2.4<0;1,0>:ud                   {I@2}
        mov (8|M0)               r10.1<2>:ud   r2.5<0;1,0>:ud                   {I@2}
        mov (8|M0)               r17.0<1>:d    r83.1<2;1,0>:d                  
        addc (8|M0)              r12.0<1>:ud   r10.0<2;1,0>:ud   r83.0<2;1,0>:ud  {AccWrEn,Compacted,I@2}
        mov (8|M0)               r9.0<1>:d     r85.1<2;1,0>:d                  
        mov (8|M0)               r7.0<1>:ud    acc0.0<1;1,0>:ud                 {Compacted}
        addc (8|M0)              r6.0<1>:ud    r10.0<2;1,0>:ud   r85.0<2;1,0>:ud  {AccWrEn,Compacted}
        mov (8|M0)               r5.0<1>:hf    r87.0<1;1,0>:f                   {F@1}
        mov (8|M0)               r8.0<1>:ud    acc0.0<1;1,0>:ud                 {Compacted}
        mov (8|M0)               r5.8<1>:hf    r88.0<1;1,0>:f                  
        add3 (8|M0)              r18.0<1>:d    r7.0<1;0>:d       r10.1<4;2>:d      r17.0<1>:d       {I@3}
        add3 (8|M0)              r19.0<1>:d    r8.0<1;0>:d       r10.1<4;2>:d      r9.0<1>:d        {I@2}
        sync.nop                             null                             {Compacted,$9.src}
        mov (8|M0)               r13.0<2>:d    r12.0<1;1,0>:d                   {$12.src}
        mov (8|M0)               r15.0<2>:d    r6.0<1;1,0>:d                   
        mov (16|M0)              r20.0<1>:d    r5.0<1;1,0>:uw                   {A@1}
        mov (8|M0)               r13.1<2>:d    r18.0<1;1,0>:d                   {I@5}
        mov (8|M0)               r15.1<2>:d    r19.0<1;1,0>:d                   {I@5}
        send.ugm (16|M0)         null     r13     r20:2   0x0            0x08000B84           {A@1,$12} // wr:4+2, rd:0; store.ugm.d16u32.a64
        goto (16|M0)                         L5504                  L5624                
L5504:
        join (16|M0)                         L5624                                
L5520:
        addc (1|M0)              r5.0<1>:ud    r4.6<0;1,0>:ud    r47.6<0;1,0>:ud  {AccWrEn}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r7.0<1>:ud    r5.0<0;1,0>:ud    r91.2<0;1,0>:ud  {AccWrEn,I@2}
        add3 (1|M0)              r1.3<1>:d     r6.0<0;0>:d       r4.7<0;0>:d       r47.7<0>:d       {I@2}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r9.0<1>:f     r7.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r9.1<1>:d     r8.0<0;0>:d       r1.3<0;0>:d       r91.3<0>:d       {I@1}
        send.ugm (1|M0)          null     r9      r87:2   0x0            0x0200D584           {A@1,$13} // wr:1+2, rd:0; store.ugm.d32x16t.a64
L5624:
        join (16|M0)                         L8920                                
L5640:
        or (1|M0)                r94.7<1>:ud   r94.7<0;1,0>:ud   0x8:uw             
        cmp (1|M0)    (lt)f1.1   null<1>:ud    r94.7<0;1,0>:ud   r3.6<0;1,0>:ud   {I@1}
(W)     and (1|M0)               f1.0<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(~f1.0.any16h) goto (16|M0)                  L8840                  L8840                
L5704:
        mul (1|M0)               acc0.0<1>:d   r94.7<0;1,0>:d    r4.4<0;1,0>:uw  
        sync.nop                             null                             {Compacted,$14.src}
        mach (1|M0)              r6.0<1>:d     r94.7<0;1,0>:d    r4.2<0;1,0>:d    {AccWrEn,$11.src}
        shl (1|M0)               r99.0<1>:w    r48.14<0;1,0>:w   5:w              
        mov (1|M0)               r5.0<1>:d     acc0.0<0;1,0>:d                 
        mov (1|M0)               r99.2<1>:d    r6.0<0;1,0>:d                    {I@3}
        mov (1|M0)               r99.1<1>:d    r5.0<0;1,0>:d                    {I@2}
        shl (1|M0)               r1.2<1>:d     r99.2<0;1,0>:d    2:w               {I@2}
        shl (1|M0)               r99.3<1>:d    r99.1<0;1,0>:d    2:w               {I@2}
        shr (1|M0)               r1.3<1>:ud    r99.1<0;1,0>:ud   0x1E:uw             
        addc (1|M0)              r7.0<1>:ud    r48.3<0;1,0>:ud   r99.3<0;1,0>:ud  {AccWrEn,I@2}
        or (1|M0)                r99.4<1>:d    r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        sync.allrd                           ($10,$13)                
        mov (1|M0)               r9.0<1>:f     r7.0<0;1,0>:f                    {Compacted,I@2}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r10.0<1>:ud   r9.0<0;1,0>:ud    0x20:ud              {AccWrEn,F@1}
        add3 (1|M0)              r9.1<1>:d     r8.0<0;0>:d       r48.4<0;0>:d      r99.4<0>:d       {I@2}
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r6.0<1>:f     r10.0<0;1,0>:f                   {Compacted,I@3}
        add3 (1|M0)              r6.1<1>:d     r5.0<0;0>:d       r9.1<0;0>:d       0:w               {I@1}
        send.ugm (1|M0)          r100     r9      null:0  0x0            0x0210B780           {$0} // wr:1+0, rd:1; load.ugm.d64x4t.a64
        send.ugm (1|M0)          r101     r6      null:0  0x0            0x0210B780           {A@1,$14} // wr:1+0, rd:1; load.ugm.d64x4t.a64
        mov (1|M0)               r99.5<1>:d    0:w                              
L6032:
        shl (1|M0)               r99.1<1>:w    r99.10<0;1,0>:w   2:w               {I@1}
        mad (1|M0)               r1.3<1>:w     r99.0<0;0>:w      r99.10<0;0>:w     4:w              
        add (1|M0)               a0.1<1>:uw    r99.1<0;1,0>:uw   0xC80:uw              {A@1}
        add (1|M0)               a0.0<1>:uw    r99.1<0;1,0>:uw   0xA20:uw              {A@1}
(W)     and (1|M0)               f1.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
        sync.nop                             null                             {Compacted,$0.dst}
        mul (1|M0)               r99.6<1>:f    r[a0.1]<0;1,0>:f  r[a0.0]<0;1,0>:f {$8.dst}
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0x720:uw              {A@1}
        sync.nop                             null                             {Compacted,$3.dst}
        add (1|M0)               r99.6<1>:f    r99.6<0;1,0>:f    r[a0.0]<0;1,0>:f {F@1}
(~f1.1.any16h) goto (16|M0)                  L6440                  L6440                 {A@1}
L6192:
        mov (1|M0)               r1.4<2>:hf    r99.6<0;1,0>:f                   {F@1}
        cmp (1|M0)    (lt)f1.0   null<1>:f     r99.6<0;1,0>:f    -4.001953e+00:f              
        mov (1|M0)               r1.3<1>:f     r1.4<0;1,0>:hf                   {F@2}
        mov (1|M0)               r2.4<1>:ud    0xBD650000:ud                             
        sel (1|M0)    (lt)f0.0   r1.3<1>:f     r1.3<0;1,0>:f     4.0:f               {F@1}
        mov (1|M0)               r2.5<1>:ud    0x3EE50000:ud                             
(~f1.0) sel (1|M0)               r2.3<1>:f     r1.3<0;1,0>:f     -4.0:f               {F@1}
        mov (1|M0)               r5.0<1>:ud    0x3F650000:ud                             
        mad (1|M0)               r2.4<1>:f     r2.5<0;0>:f       r2.4<0;0>:f       (abs)r2.3<0>:f   {A@1}
        mov (1|M0)               r3.14<2>:hf   r2.4<0;1,0>:f                    {F@1}
        mov (1|M0)               r4.5<1>:f     r3.14<0;1,0>:hf                  {F@1}
        mad (1|M0)               r2.3<1>:f     r5.0<0;0>:f       r4.5<0;0>:f       r2.3<0>:f        {A@1}
        sync.nop                             null                             {Compacted,$14.src}
        mov (1|M0)               r6.0<2>:hf    r2.3<0;1,0>:f                    {F@1}
        mul (1|M0)               r1.4<1>:hf    r1.4<0;1,0>:hf    r6.0<0;1,0>:hf   {F@1}
        mov (1|M0)               r99.6<1>:f    r1.4<0;1,0>:hf                   {F@1}
L6440:
        join (16|M0)                         L7112                                
L6456:
(W)     and (1|M0)               f1.0<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(f1.0.any16h) goto (16|M0)                   L6568                  L6568                
L6488:
(W)     mov (1|M0)               f1.0<1>:uw    r102.7<0;1,0>:uw                
        mov (1|M0)               r1.4<2>:hf    r99.6<0;1,0>:f                   {F@1}
        mov (1|M0)               r102.1<1>:f   r1.4<0;1,0>:hf                   {F@1}
(~f1.0) mov (1|M0)               r102.1<1>:f   r99.6<0;1,0>:f                  
        goto (16|M0)                         L6568                  L7000                
L6568:
        join (16|M0)                         L7000                                
L6584:
        cmp (1|M0)    (lt)f1.0   null<1>:f     r99.6<0;1,0>:f    0.0:f               {I@3}
(f1.0)  mov (1|M0)               r99.6<1>:f    -r99.6<0;1,0>:f                 
        sel (1|M0)    (lt)f0.0   r99.6<1>:f    r99.6<0;1,0>:f    448.0:f               {F@1}
        shr (1|M0)               r102.0<1>:ud  r99.6<0;1,0>:ud   0x17:uw              {F@1}
        and (1|M0)               r102.0<1>:ud  r102.0<0;1,0>:ud  0xFF:uw              {I@1}
        sel (1|M0)    (ge)f0.0   r102.0<1>:ud  r102.0<0;1,0>:ud  0x79:uw              {I@1}
        shl (1|M0)               r102.0<1>:ud  r102.0<0;1,0>:ud  0x17:uw              {I@1}
        add (1|M0)               r1.2<1>:ud    -r102.0<0;1,0>:ud  0x80800000:ud             {I@1}
        mul (1|M0)               r1.3<1>:f     r99.6<0;1,0>:f    r1.2<0;1,0>:f    {I@1}
        mov (1|M0)               r99.7<1>:d    r1.3<0;1,0>:f                    {F@1}
        mov (1|M0)               r102.1<1>:f   r99.7<0;1,0>:d                   {I@1}
        mad (1|M0)               r99.6<1>:f    -r102.1<0;0>:f    r1.2<0;0>:f       r99.6<0>:f       {F@1}
        cmp (1|M0)    (gt)f1.1   null<1>:f     r99.6<0;1,0>:f    0.5:f               {F@1}
(W)     and (1|M0)               f1.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw              {F@1}
(f1.1.any16h) goto (16|M0)                   L6920                  L6920                
L6824:
        cmp (1|M0)    (lt)f1.1   null<1>:f     r99.6<0;1,0>:f    0.5:f               {A@1}
        and (1|M0)               r99.7<1>:d    r99.7<0;1,0>:d    1:w              
        add (1|M0)               r1.2<1>:f     r102.1<0;1,0>:f   1.0:f              
(~f1.1) cmp (1|M0)    (eq)f1.1   null<1>:d     r99.7<0;1,0>:d    0:w               {A@1}
(~f1.1) mov (1|M0)               r102.1<1>:f   r1.2<0;1,0>:f                    {F@1}
        goto (16|M0)                         L6920                  L6944                
L6920:
        join (16|M0)                         L6944                                
L6936:
        add (1|M0)               r102.1<1>:f   r102.1<0;1,0>:f   1.0:f               {Compacted,F@1}
L6944:
        join (16|M0)                         L7000                                
L6960:
        add (1|M0)               r102.0<1>:ud  r102.0<0;1,0>:ud  0xFE800000:ud             
        mul (1|M0)               r102.1<1>:f   r102.1<0;1,0>:f   r102.0<0;1,0>:f  {Compacted,A@1}
(f1.0)  mov (1|M0)               r102.1<1>:f   -r102.1<0;1,0>:f                 {F@1}
L7000:
        join (16|M0)                         L7112                                
L7016:
        add (1|M0)               r99.5<1>:d    r99.5<0;1,0>:d    1:w              
        add (1|M0)               a0.0<1>:uw    r99.1<0;1,0>:uw   0xB20:uw              {A@1}
        cmp (1|M0)    (eq)f1.0   null<1>:d     r99.5<0;1,0>:d    8:w               {A@1}
        mov (1|M0)               r[a0.0]<1>:f  r102.1<0;1,0>:f                 
(W)     and (1|M0)               f1.1<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
(~f1.1.any16h) goto.b (16|M0)                L7112                  L6032                
L7112:
        join (16|M0)                         L8840                                
L7128:
        mov (1|M0)               r102.2<1>:d   0:w                              
L7144:
        shl (1|M0)               r102.6<1>:w   r102.4<0;1,0>:w   2:w               {I@1}
        mad (1|M0)               r1.3<1>:w     r99.0<0;0>:w      r102.4<0;0>:w     4:w              
        add (1|M0)               a0.1<1>:uw    r102.6<0;1,0>:uw  0xCA0:uw              {A@1}
        add (1|M0)               a0.0<1>:uw    r102.6<0;1,0>:uw  0xA20:uw              {A@1}
(W)     and (1|M0)               f1.0<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
        mul (1|M0)               r102.4<1>:f   r[a0.1]<0;1,0>:f  r[a0.0,32]<0;1,0>:f {$14.dst}
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0x620:uw              {A@1}
        add (1|M0)               r102.4<1>:f   r102.4<0;1,0>:f   r[a0.0]<0;1,0>:f {F@1}
(~f1.0.any16h) goto (16|M0)                  L7528                  L7528                 {A@1}
L7288:
        mov (1|M0)               r1.4<2>:hf    r102.4<0;1,0>:f                  {F@1}
        cmp (1|M0)    (lt)f1.1   null<1>:f     r102.4<0;1,0>:f   -4.001953e+00:f              
        mov (1|M0)               r1.3<1>:f     r1.4<0;1,0>:hf                   {F@2}
        mov (1|M0)               r2.4<1>:ud    0xBD650000:ud                             
        sel (1|M0)    (lt)f0.0   r1.3<1>:f     r1.3<0;1,0>:f     4.0:f               {F@1}
        mov (1|M0)               r2.5<1>:ud    0x3EE50000:ud                             
(~f1.1) sel (1|M0)               r2.3<1>:f     r1.3<0;1,0>:f     -4.0:f               {F@1}
        mov (1|M0)               r5.0<1>:ud    0x3F650000:ud                             
        mad (1|M0)               r2.4<1>:f     r2.5<0;0>:f       r2.4<0;0>:f       (abs)r2.3<0>:f   {A@1}
        mov (1|M0)               r3.14<2>:hf   r2.4<0;1,0>:f                    {F@1}
        mov (1|M0)               r4.5<1>:f     r3.14<0;1,0>:hf                  {F@1}
        mad (1|M0)               r2.3<1>:f     r5.0<0;0>:f       r4.5<0;0>:f       r2.3<0>:f        {A@1}
        mov (1|M0)               r6.0<2>:hf    r2.3<0;1,0>:f                    {F@1}
        mul (1|M0)               r1.4<1>:hf    r1.4<0;1,0>:hf    r6.0<0;1,0>:hf   {F@1}
        mov (1|M0)               r102.4<1>:f   r1.4<0;1,0>:hf                   {F@1}
L7528:
        join (16|M0)                         L8232                                
L7544:
(W)     and (1|M0)               f1.1<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(f1.1.any16h) goto (16|M0)                   L7656                  L7656                
L7576:
(W)     mov (1|M0)               f1.1<1>:uw    r102.7<0;1,0>:uw                
        mov (1|M0)               r1.4<2>:hf    r102.4<0;1,0>:f                  {F@1}
        mov (1|M0)               r102.7<1>:f   r1.4<0;1,0>:hf                   {F@1}
(~f1.1) mov (1|M0)               r102.7<1>:f   r102.4<0;1,0>:f                 
        goto (16|M0)                         L7656                  L8104                
L7656:
        join (16|M0)                         L8104                                
L7672:
        cmp (1|M0)    (lt)f1.1   null<1>:f     r102.4<0;1,0>:f   0.0:f               {I@3}
(f1.1)  mov (1|M0)               r102.4<1>:f   -r102.4<0;1,0>:f                
        sel (1|M0)    (lt)f0.0   r102.4<1>:f   r102.4<0;1,0>:f   448.0:f               {F@1}
        shr (1|M0)               r102.6<1>:ud  r102.4<0;1,0>:ud  0x17:uw              {F@1}
        and (1|M0)               r102.6<1>:ud  r102.6<0;1,0>:ud  0xFF:uw              {I@1}
        sel (1|M0)    (ge)f0.0   r102.6<1>:ud  r102.6<0;1,0>:ud  0x79:uw              {I@1}
        shl (1|M0)               r102.6<1>:ud  r102.6<0;1,0>:ud  0x17:uw              {I@1}
        add (1|M0)               r1.2<1>:ud    -r102.6<0;1,0>:ud  0x80800000:ud             {I@1}
        mul (1|M0)               r1.3<1>:f     r102.4<0;1,0>:f   r1.2<0;1,0>:f    {I@1}
        mov (1|M0)               r102.5<1>:d   r1.3<0;1,0>:f                    {F@1}
        mov (1|M0)               r102.7<1>:f   r102.5<0;1,0>:d                  {I@1}
        mad (1|M0)               r102.4<1>:f   -r102.7<0;0>:f    r1.2<0;0>:f       r102.4<0>:f      {F@1}
        cmp (1|M0)    (gt)f1.0   null<1>:f     r102.4<0;1,0>:f   0.5:f               {F@1}
(W)     and (1|M0)               f1.0<1>:uw    f1.0<0;1,0>:uw    0x1:uw              {F@1}
(f1.0.any16h) goto (16|M0)                   L8008                  L8008                
L7912:
        cmp (1|M0)    (lt)f1.0   null<1>:f     r102.4<0;1,0>:f   0.5:f               {A@1}
        and (1|M0)               r102.5<1>:d   r102.5<0;1,0>:d   1:w              
        add (1|M0)               r1.2<1>:f     r102.7<0;1,0>:f   1.0:f              
(~f1.0) cmp (1|M0)    (eq)f1.0   null<1>:d     r102.5<0;1,0>:d   0:w               {A@1}
(~f1.0) mov (1|M0)               r102.7<1>:f   r1.2<0;1,0>:f                    {F@1}
        goto (16|M0)                         L8008                  L8040                
L8008:
        join (16|M0)                         L8040                                
L8024:
        add (1|M0)               r102.7<1>:f   r102.7<0;1,0>:f   1.0:f               {F@1}
L8040:
        join (16|M0)                         L8104                                
L8056:
        add (1|M0)               r102.6<1>:ud  r102.6<0;1,0>:ud  0xFE800000:ud             
        mul (1|M0)               r102.7<1>:f   r102.7<0;1,0>:f   r102.6<0;1,0>:f  {A@1}
(f1.1)  mov (1|M0)               r102.7<1>:f   -r102.7<0;1,0>:f                 {F@1}
L8104:
        join (16|M0)                         L8232                                
L8120:
        add (1|M0)               r102.2<1>:d   r102.2<0;1,0>:d   1:w              
        or (1|M0)                r1.3<1>:uw    r102.6<0;1,0>:uw  0x20:uw             
        cmp (1|M0)    (eq)f1.0   null<1>:d     r102.2<0;1,0>:d   8:w               {I@2}
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0xB20:uw              {A@1}
        mov (1|M0)               r[a0.0]<1>:f  r102.7<0;1,0>:f                  {F@1}
(W)     and (1|M0)               f1.1<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
(~f1.1.any16h) goto.b (16|M0)                L8232                  L7144                
L8232:
        join (16|M0)                         L8840                                
L8248:
(W)     and (1|M0)               f1.0<1>:uw    r107.8<0;1,0>:uw  0x1:uw             
(f1.0.any16h) goto (16|M0)                   L8720                  L8720                
L8280:
        addc (1|M0)              r6.0<1>:ud    r4.6<0;1,0>:ud    r48.5<0;1,0>:ud  {AccWrEn}
        shl (1|M0)               r1.6<1>:d     r99.1<0;1,0>:d    1:w              
        shl (1|M0)               r1.4<1>:d     r99.2<0;1,0>:d    1:w              
        shr (1|M0)               r1.5<1>:ud    r99.1<0;1,0>:ud   0x1F:uw             
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r8.0<1>:ud    r6.0<0;1,0>:ud    r1.6<0;1,0>:ud   {AccWrEn,I@4}
        or (1|M0)                r1.7<1>:d     r1.4<0;1,0>:d     r1.5<0;1,0>:d    {I@3}
        add3 (1|M0)              r1.3<1>:d     r7.0<0;0>:d       r4.7<0;0>:d       r48.6<0>:d       {I@3}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r2.4<1>:d     r8.0<0;1,0>:d                    {I@4}
        add3 (1|M0)              r2.5<1>:d     r9.0<0;0>:d       r1.3<0;0>:d       r1.7<0>:d        {I@2}
        mov (8|M0)               r10.0<2>:ud   r2.4<0;1,0>:ud                   {I@2}
        mov (8|M0)               r10.1<2>:ud   r2.5<0;1,0>:ud                   {I@2}
        mov (8|M0)               r17.0<1>:d    r83.1<2;1,0>:d                  
        addc (8|M0)              r12.0<1>:ud   r10.0<2;1,0>:ud   r83.0<2;1,0>:ud  {AccWrEn,Compacted,I@2}
        mov (8|M0)               r9.0<1>:d     r85.1<2;1,0>:d                  
        mov (8|M0)               r7.0<1>:ud    acc0.0<1;1,0>:ud                 {Compacted}
        addc (8|M0)              r6.0<1>:ud    r10.0<2;1,0>:ud   r85.0<2;1,0>:ud  {AccWrEn,Compacted}
        mov (8|M0)               r5.0<1>:hf    r89.0<1;1,0>:f                   {F@1}
        mov (8|M0)               r8.0<1>:ud    acc0.0<1;1,0>:ud                 {Compacted}
        mov (8|M0)               r5.8<1>:hf    r90.0<1;1,0>:f                  
        add3 (8|M0)              r18.0<1>:d    r7.0<1;0>:d       r10.1<4;2>:d      r17.0<1>:d       {I@3}
        add3 (8|M0)              r19.0<1>:d    r8.0<1;0>:d       r10.1<4;2>:d      r9.0<1>:d        {I@2}
        sync.nop                             null                             {Compacted,$9.src}
        mov (8|M0)               r13.0<2>:d    r12.0<1;1,0>:d                   {$12.src}
        mov (8|M0)               r15.0<2>:d    r6.0<1;1,0>:d                   
        mov (16|M0)              r20.0<1>:d    r5.0<1;1,0>:uw                   {A@1}
        mov (8|M0)               r13.1<2>:d    r18.0<1;1,0>:d                   {I@5}
        mov (8|M0)               r15.1<2>:d    r19.0<1;1,0>:d                   {I@5}
        send.ugm (16|M0)         null     r13     r20:2   0x0            0x08000B84           {A@1,$9} // wr:4+2, rd:0; store.ugm.d16u32.a64
        goto (16|M0)                         L8720                  L8840                
L8720:
        join (16|M0)                         L8840                                
L8736:
        addc (1|M0)              r5.0<1>:ud    r4.6<0;1,0>:ud    r47.6<0;1,0>:ud  {AccWrEn}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r7.0<1>:ud    r5.0<0;1,0>:ud    r99.3<0;1,0>:ud  {AccWrEn,I@2}
        add3 (1|M0)              r1.3<1>:d     r6.0<0;0>:d       r4.7<0;0>:d       r47.7<0>:d       {I@2}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r9.0<1>:f     r7.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r9.1<1>:d     r8.0<0;0>:d       r1.3<0;0>:d       r99.4<0>:d       {I@1}
        send.ugm (1|M0)          null     r9      r89:2   0x0            0x0200D584           {A@1,$10} // wr:1+2, rd:0; store.ugm.d32x16t.a64
L8840:
        join (16|M0)                         L8920                                
L8856:
        add (1|M0)               r48.7<1>:d    r48.7<0;1,0>:d    1:w              
        cmp (1|M0)    (eq)f0.1   null<1>:d     r48.7<0;1,0>:d    8:w               {I@1}
(W)     and (1|M0)               f0.1<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(~f0.1.any16h) goto.b (16|M0)                L8920                  L2360                
L8920:
        join (16|M0)                         L8936                                
L8936:
(W)     mov (8|M0)               r127.0<1>:f   r0.0<1;1,0>:f                    {Compacted}
(W)     send.ugm (1|M0)          r5       r0      null:0  0x0            0x0210641F           {$1} // wr:1+0, rd:1; fence invalid flush type scoped to tile
(W)     mov (8|M0)               null<1>:ud    r5.0<1;1,0>:ud                   {$1.dst}
(W)     send.gtwy (1|M0)         null     r127    null:0  0x0            0x02000010           {EOT,A@1} // wr:1+0, rd:0; end of thread
L8992:
        mov (1|M0)               r1.2<1>:d     cr0.0<0;1,0>:ud                  {A@1}
        and (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   -1265:w               {A@1}
        or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   1264:w               {A@1}
        mov (1|M0)               r1.3<1>:f     (abs)r107.1<0;1,0>:d             {A@1}
        mov (1|M0)               r5.0<1>:f     0xB4C00000:f                               {Compacted,I@4}
        math.inv (1|M0)          r4.5<1>:f     r1.3<0;1,0>:f                    {@2,$2}
        mov (1|M0)               r2.4<1>:f     (abs)r107.0<0;1,0>:d             {Compacted}
        sync.nop                             null                             {Compacted,$2.dst}
        mad (1|M0)               r4.5<1>:f     r4.5<0;0>:f       r5.0<0;0>:f       r4.5<0>:f        {F@2}
        mov (2|M0)               r1.4<1>:d     (abs)r107.0<1;1,0>:d            
        mov (1|M0)               r1.6<1>:ud    r1.3<0;1,0>:f                   
        mov (1|M0)               r2.5<1>:ud    r2.4<0;1,0>:f                    {F@2}
        mul (1|M0)               r6.0<1>:f     r4.5<0;1,0>:f     r2.4<0;1,0>:f    {F@1}
        add (1|M0)               r1.6<1>:ud    r1.5<0;1,0>:ud    -r1.6<0;1,0>:ud  {I@2}
        add (1|M0)               r2.5<1>:ud    r1.4<0;1,0>:ud    -r2.5<0;1,0>:ud  {I@2}
        mov (1|M0)               r7.0<1>:ud    r6.0<0;1,0>:f                    {F@1}
        mov (1|M0)               r2.3<1>:f     r1.6<0;1,0>:ud                   {I@3}
        mov (1|M0)               r3.7<1>:f     r2.5<0;1,0>:ud                   {I@2}
        mov (1|M0)               r7.1<1>:f     r7.0<0;1,0>:ud                   {Compacted,I@1}
        xor (1|M0)               r107.1<1>:d   r107.1<0;1,0>:d   r107.0<0;1,0>:d  {Compacted}
        mad (1|M0)               r2.4<1>:f     r2.4<0;0>:f       r7.1<0;0>:f       -r1.3<0>:f       {F@1}
        mad (1|M0)               r7.1<1>:f     r3.7<0;0>:f       r7.1<0;0>:f       -r2.3<0>:f      
(W)     mov (1|M0)               r6.0<1>:hf    0x1:hf                             
        add (1|M0)               r2.4<1>:f     r2.4<0;1,0>:f     r7.1<0;1,0>:f    {F@2}
        asr (1|M0)               r107.1<1>:d   r107.1<0;1,0>:d   31:w               {Compacted,I@1}
        mul (1|M0)               r4.5<1>:f     r4.5<0;1,0>:f     r2.4<0;1,0>:f    {F@1}
        mov (1|M0)               r8.0<1>:ud    r4.5<0;1,0>:f                    {F@1}
        add (1|M0)               r7.0<1>:ud    r7.0<0;1,0>:ud    r8.0<0;1,0>:ud   {Compacted,I@1}
(W)     mul (1|M0)               acc0.0<1>:ud  r7.0<0;1,0>:ud    r1.10<0;1,0>:uw  {I@1}
        mach (1|M0)              r5.0<1>:ud    r7.0<0;1,0>:ud    r1.5<0;1,0>:ud   {Compacted}
        add (1|M0)               r1.4<1>:ud    r1.4<0;1,0>:ud    -r5.0<0;1,0>:ud  {I@1}
        cmp (1|M0)    (ge)f0.1   null<1>:ud    r1.4<0;1,0>:ud    r1.5<0;1,0>:ud   {I@1}
(f0.1)  sel (1|M0)               r3.7<1>:d     r6.0<0;1,0>:w     0:w              
        add3 (1|M0)              r7.0<1>:d     r7.0<0;0>:d       r107.1<0;0>:d     r3.7<0>:d        {I@1}
        xor (1|M0)               r46.1<1>:d    r7.0<0;1,0>:d     r107.1<0;1,0>:d  {I@1}
        mov (1|M0)               cr0.0<1>:ud   r1.2<0;1,0>:d                    {A@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        ret (16|M0)                          r107.2                           {A@1}
L9552:
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
