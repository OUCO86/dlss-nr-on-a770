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
        mov (1|M0)               r86.5<1>:d    r2.6<0;1,0>:d                    {$1.dst}
(W)     mul (1|M0)               acc0.0<1>:d   r47.0<0;1,0>:d    r2.0<0;1,0>:uw   {Compacted,I@2}
        mach (1|M0)              r47.0<1>:d    r47.0<0;1,0>:d    r2.0<0;1,0>:d    {Compacted}
        sync.nop                             null                             {Compacted,$0.dst}
        add (1|M0)               r47.0<1>:d    r47.0<0;1,0>:d    r1.0<0;1,0>:uw   {I@1}
        mov (1|M0)               r86.4<1>:d    r47.0<0;1,0>:d                   {I@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r86.2         L20760                                 {A@1}
L376:
        cmp (1|M0)    (gt)f1.0   null<1>:d     r2.7<0;1,0>:d     0:w              
(W)     mul (1|M0)               acc0.0<1>:d   r46.0<0;1,0>:d    r2.12<0;1,0>:uw  {Compacted}
        mach (1|M0)              r5.0<1>:d     r46.0<0;1,0>:d    r2.6<0;1,0>:d    {Compacted}
        mov (16|M0)              r49.0<1>:ud   0x0:ud                             
(W)     and (1|M0)               f0.1<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
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
        add (1|M0)               r47.0<1>:d    r47.0<0;1,0>:d    -r5.0<0;1,0>:d   {Compacted,I@7}
(~f0.1.any16h) goto (16|M0)                  L1696                  L1696                
L632:
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
L792:
        addc (1|M0)              r5.0<1>:ud    r47.2<0;1,0>:ud   r48.0<0;1,0>:ud  {AccWrEn,A@2}
        shl (1|M0)               r4.3<1>:d     r5.0<0;1,0>:d     8:w               {Compacted,I@1}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        shl (1|M0)               r7.0<1>:d     r4.3<0;1,0>:d     1:w               {Compacted,I@2}
        add3 (1|M0)              r1.3<1>:d     r6.0<0;0>:d       r47.3<0;0>:d      r48.1<0>:d       {A@1}
        addc (1|M0)              r8.0<1>:ud    r3.0<0;1,0>:ud    r7.0<0;1,0>:ud   {AccWrEn,I@2}
        shr (1|M0)               r2.4<1>:ud    r5.0<0;1,0>:ud    0x18:uw             
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r47.2<0;1,0>:d    r46.4<0;1,0>:uw 
        mach (1|M0)              r6.0<1>:d     r47.2<0;1,0>:d    r46.2<0;1,0>:d  
(W)     mul (1|M0)               acc0.0<1>:d   r47.3<0;1,0>:d    r46.2<0;1,0>:uw 
        mach (1|M0)              r5.0<1>:d     r47.3<0;1,0>:d    r46.1<0;1,0>:d  
        mul (1|M0)               acc0.0<1>:ud  r47.2<0;1,0>:ud   r46.2<0;1,0>:uw 
        mach (1|M0)              r12.0<1>:ud   r47.2<0;1,0>:ud   r46.1<0;1,0>:ud  {AccWrEn}
        shl (1|M0)               r2.3<1>:d     r1.3<0;1,0>:d     8:w               {Compacted,I@7}
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        add3 (1|M0)              r1.3<1>:d     r5.0<0;0>:d       r12.0<0;0>:d      r6.0<0>:d        {I@3}
        addc (1|M0)              r13.0<1>:ud   r11.0<0;1,0>:ud   r46.3<0;1,0>:ud  {AccWrEn,I@2}
        or (1|M0)                r4.4<1>:d     r2.3<0;1,0>:d     r2.4<0;1,0>:d   
        mov (1|M0)               r14.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,$3.src}
        shr (1|M0)               r4.5<1>:ud    r4.3<0;1,0>:ud    0x1F:uw             
        shl (1|M0)               r3.7<1>:d     r4.4<0;1,0>:d     1:w               {I@3}
        add3 (1|M0)              r2.4<1>:d     r14.0<0;0>:d      r1.3<0;0>:d       r46.4<0>:d       {I@3}
        shl (1|M0)               r4.4<1>:d     r13.0<0;1,0>:d    8:w               {Compacted}
        shr (1|M0)               r4.3<1>:ud    r13.0<0;1,0>:ud   0x18:uw             
        or (1|M0)                r7.1<1>:d     r3.7<0;1,0>:d     r4.5<0;1,0>:d    {I@4}
        shl (1|M0)               r7.2<1>:d     r4.4<0;1,0>:d     1:w               {I@3}
        shl (1|M0)               r3.7<1>:d     r2.4<0;1,0>:d     8:w              
        mov (1|M0)               r10.0<1>:f    r8.0<0;1,0>:f                    {Compacted}
        addc (1|M0)              r5.0<1>:ud    r3.2<0;1,0>:ud    r7.2<0;1,0>:ud   {AccWrEn,I@2}
        or (1|M0)                r4.5<1>:d     r3.7<0;1,0>:d     r4.3<0;1,0>:d    {I@2}
        add3 (1|M0)              r10.1<1>:d    r9.0<0;0>:d       r3.1<0;0>:d       r7.1<0>:d       
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r8.0<1>:f     r5.0<0;1,0>:f                    {Compacted,I@4}
        shl (1|M0)               r7.0<1>:d     r4.5<0;1,0>:d     1:w               {Compacted,I@3}
        shr (1|M0)               r7.1<1>:ud    r4.4<0;1,0>:ud    0x1F:uw             
        addc (1|M0)              r9.0<1>:ud    r10.0<0;1,0>:ud   0x100:ud              {AccWrEn,F@2}
        or (1|M0)                r7.3<1>:d     r7.0<0;1,0>:d     r7.1<0;1,0>:d    {I@2}
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
        cmp (1|M0)    (eq)f1.1   null<1>:d     r47.5<0;1,0>:d    r46.6<0;1,0>:d   {I@1}
(f1.1)  cmp (1|M0)    (eq)f1.1   null<1>:d     r47.4<0;1,0>:d    r46.5<0;1,0>:d  
(W)     and (1|M0)               f0.0<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
        sync.allwr                           ($3,$4,$5,$6,$7)                
        dpas.8x8 (8|M0)          r73:f         r73:f             r30:hf            r14.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r57:f         r57:f             r30:hf            r22.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r65:f         r65:f             r38:hf            r14.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r49:f         r49:f             r38:hf            r22.0:hf         {$3}
(f0.0.any16h) goto (16|M0)                   L1696                  L1696                
L1664:
(W)     mov (2|M0)               r47.2<1>:ud   r47.4<1;1,0>:ud                 
        goto.b (16|M0)                       L1696                  L792                
L1696:
        join (16|M0)                         L1712                                
L1712:
        shl (1|M0)               r46.0<1>:d    r46.0<0;1,0>:d    4:w               {Compacted}
        shl (1|M0)               r4.3<1>:d     r47.0<0;1,0>:d    4:w               {Compacted}
        mul (1|M0)               acc0.0<1>:d   r46.0<0;1,0>:d    r3.12<0;1,0>:uw  {Compacted,I@2}
        mach (1|M0)              r6.0<1>:d     r46.0<0;1,0>:d    r3.6<0;1,0>:d    {AccWrEn}
        shl (1|M0)               r4.5<1>:d     r4.3<0;1,0>:d     2:w               {I@3}
        mov (1|M0)               r5.0<1>:d     acc0.0<0;1,0>:d                 
        shl (1|M0)               r1.2<1>:d     r6.0<0;1,0>:d     2:w               {Compacted,I@3}
        shl (1|M0)               r1.4<1>:d     r5.0<0;1,0>:d     2:w               {Compacted,I@2}
        shr (1|M0)               r1.3<1>:ud    r5.0<0;1,0>:ud    0x1E:uw             
        addc (1|M0)              r7.0<1>:ud    r3.4<0;1,0>:ud    r1.4<0;1,0>:ud   {AccWrEn,I@2}
        shl (1|M0)               r11.1<1>:d    r5.0<0;1,0>:d     1:w               {Compacted}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@3}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r9.0<1>:ud    r7.0<0;1,0>:ud    r4.5<0;1,0>:ud   {AccWrEn,I@4}
        shl (1|M0)               r3.7<1>:d     r6.0<0;1,0>:d     1:w               {Compacted}
        shr (1|M0)               r11.0<1>:ud   r5.0<0;1,0>:ud    0x1F:uw             
        add3 (1|M0)              r2.4<1>:d     r8.0<0;0>:d       r3.5<0;0>:d       r1.5<0>:d        {I@4}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        shl (1|M0)               r1.5<1>:d     r4.3<0;1,0>:d     1:w              
        addc (1|M0)              r8.0<1>:ud    r4.0<0;1,0>:ud    r11.1<0;1,0>:ud  {AccWrEn}
        mov (1|M0)               r48.2<1>:d    r3.6<0;1,0>:d                   
        shr (1|M0)               r2.5<1>:ud    r4.3<0;1,0>:ud    0x1E:uw             
        shr (1|M0)               r1.4<1>:ud    r4.3<0;1,0>:ud    0x1F:uw             
        or (1|M0)                r11.2<1>:d    r3.7<0;1,0>:d     r11.0<0;1,0>:d   {I@7}
        mov (1|M0)               r12.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r7.0<1>:ud    r8.0<0;1,0>:ud    r1.5<0;1,0>:ud   {AccWrEn,I@6}
        asr (1|M0)               r48.3<1>:d    r3.6<0;1,0>:d     31:w              
        mov (1|M0)               r81.0<1>:f    r9.0<0;1,0>:f                    {Compacted}
        shl (1|M0)               r48.4<1>:d    r48.2<0;1,0>:d    3:w               {I@7}
        or (1|M0)                r4.6<1>:d     r2.5<0;1,0>:d     0:w               {I@7}
        or (1|M0)                r1.6<1>:d     r1.4<0;1,0>:d     0:w               {I@7}
        add3 (1|M0)              r1.3<1>:d     r12.0<0;0>:d      r4.1<0;0>:d       r11.2<0>:d       {I@6}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,F@1}
        shl (1|M0)               r2.3<1>:d     r48.3<0;1,0>:d    3:w               {Compacted,I@6}
        add3 (1|M0)              r81.1<1>:d    r10.0<0;0>:d      r2.4<0;0>:d       r4.6<0>:d        {I@5}
        addc (1|M0)              r5.0<1>:ud    r81.0<0;1,0>:ud   0x20:ud              {AccWrEn}
        add3 (1|M0)              r47.7<1>:d    r9.0<0;0>:d       r1.3<0;0>:d       r1.6<0>:d        {I@4}
        shr (1|M0)               r2.4<1>:ud    r48.2<0;1,0>:ud   0x1D:uw             
        shl (1|M0)               r1.3<1>:d     r48.4<0;1,0>:d    2:w              
        mov (1|M0)               r47.6<1>:d    r7.0<0;1,0>:d                   
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        or (1|M0)                r48.5<1>:d    r2.3<0;1,0>:d     r2.4<0;1,0>:d    {I@4}
        addc (1|M0)              r7.0<1>:ud    r81.0<0;1,0>:ud   r1.3<0;1,0>:ud   {AccWrEn,I@4}
        cmp (1|M0)    (lt)f0.1   null<1>:ud    r46.0<0;1,0>:ud   r4.2<0;1,0>:ud  
        shr (1|M0)               r1.2<1>:ud    r48.4<0;1,0>:ud   0x1E:uw             
        add3 (1|M0)              r10.1<1>:d    r6.0<0;0>:d       r81.1<0;0>:d      0:w               {I@5}
        shl (1|M0)               r3.7<1>:d     r48.5<0;1,0>:d    2:w               {I@5}
        mov (1|M0)               r6.0<1>:f     r7.0<0;1,0>:f                    {Compacted,A@2}
        mov (1|M0)               r10.0<1>:f    r5.0<0;1,0>:f                    {Compacted}
        or (1|M0)                r1.4<1>:d     r3.7<0;1,0>:d     r1.2<0;1,0>:d    {I@1}
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,F@1}
        addc (1|M0)              r8.0<1>:ud    r6.0<0;1,0>:ud    0x20:ud              {AccWrEn}
        mov (8|M0)               r11.0<1>:uw   0xECA86420:uv                             
(W)     and (1|M0)               f1.1<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
        add3 (1|M0)              r6.1<1>:d     r5.0<0;0>:d       r81.1<0;0>:d      r1.4<0>:d        {I@4}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        send.ugm (1|M0)          null     r81     r73:1   0x0            0x0200C584           {$3} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r10     r65:1   0x0            0x0200C584           {$8} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        mov (8|M0)               r12.0<4>:uw   r11.0<1;1,0>:uw                  {I@4}
        mov (1|M0)               r10.0<1>:f    r8.0<0;1,0>:f                    {Compacted,$8.src}
        add3 (1|M0)              r10.1<1>:d    r9.0<0;0>:d       r6.1<0;0>:d       0:w               {I@2}
        send.ugm (1|M0)          null     r6      r57:1   0x0            0x0200C584           {$9} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r10     r49:1   0x0            0x0200C584           {A@1,$10} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        mov (8|M0)               r82.0<2>:ud   r12.0<4;1,0>:uw                 
        mov (8|M0)               r82.1<2>:ud   0.0:f                              
(~f1.1.any16h) goto (16|M0)                  L3312                  L3312                
L2616:
        sel (8|M0)    (lt)f0.0   r5.0<1>:f     (abs)r73.0<1;1,0>:f  448.0:f            {Compacted}
        cmp (8|M0)    (lt)f0.0   null<1>:f     r73.0<1;1,0>:f    0.0:f               {Compacted}
        sync.nop                             null                             {Compacted,$9.src}
        shr (8|M0)               r6.0<1>:ud    r5.0<1;1,0>:ud    0x17:uw              {F@2}
        mov (8|M0)               r10.0<2>:ud   r47.6<0;1,0>:ud                  {$10.src}
        sel (8|M0)    (ge)f0.0   r1.6<2>:ub    r6.0<4;1,0>:ub    0x79:uw              {I@2}
        mov (8|M0)               r10.1<2>:ud   r47.7<0;1,0>:ud                 
        mov (8|M0)               r7.0<1>:d     r1.6<2;1,0>:ub                   {I@2}
        addc (8|M0)              r6.0<1>:ud    r10.0<2;1,0>:ud   r82.0<2;1,0>:ud  {AccWrEn,Compacted,I@2}
        shl (8|M0)               r7.0<1>:d     r7.0<1;1,0>:d     23:w               {Compacted,I@2}
        mov (8|M0)               r12.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        add (8|M0)               r8.0<1>:d     r7.0<1;1,0>:d     -25165824:d               {I@2}
        add (8|M0)               r7.0<1>:d     -r7.0<1;1,0>:d    -2139095040:d              
        mov (8|M0)               r13.0<2>:d    r6.0<1;1,0>:d                   
        mul (8|M0)               acc0.0<1>:f   r5.0<1;1,0>:f     r7.0<1;1,0>:f    {Compacted,I@2}
        mov (8|M0)               r7.0<1>:d     r82.1<2;1,0>:d                   {F@1}
        rnde (8|M0)              acc0.0<1>:f   acc0.0<1;1,0>:f                 
        add3 (8|M0)              r15.0<1>:d    r12.0<1;0>:d      r10.1<4;2>:d      r7.0<1>:d        {I@1}
        mul (8|M0)               acc0.0<1>:f   acc0.0<1;1,0>:f   r8.0<1;1,0>:f    {Compacted}
        sel (8|M0)    (lt)f0.0   r8.0<1>:f     (abs)r65.0<1;1,0>:f  448.0:f            {Compacted}
        mov (8|M0)               r9.0<1>:f     (abs)acc0.0<1;1,0>:f             {Compacted}
        mov (8|M0)               r13.1<2>:d    r15.0<1;1,0>:d                   {I@1}
(f0.0)  or (8|M0)                r9.0<1>:d     r9.0<1;1,0>:d     -2147483648:d               {F@1}
        cmp (8|M0)    (lt)f1.1   null<1>:f     r65.0<1;1,0>:f    0.0:f              
        mov (8|M0)               r4.8<1>:hf    r9.0<1;1,0>:f                    {I@1}
        shr (8|M0)               r9.0<1>:ud    r8.0<1;1,0>:ud    0x17:uw              {F@1}
        mov (8|M0)               r5.0<1>:d     r4.8<1;1,0>:uw                  
        sel (8|M0)    (ge)f0.0   r1.6<2>:ub    r9.0<4;1,0>:ub    0x79:uw              {I@2}
        send.ugm (8|M0)          null     r13     r5:1    0x0            0x04000B84           {A@2,$11} // wr:2+1, rd:0; store.ugm.d16u32.a64
        mov (8|M0)               r16.0<1>:d    r1.6<2;1,0>:ub                   {I@1}
        addc (1|M0)              r5.0<1>:ud    r47.6<0;1,0>:ud   0x10:ud              {AccWrEn,$11.src}
        shl (8|M0)               r16.0<1>:d    r16.0<1;1,0>:d    23:w               {Compacted,I@2}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        add (8|M0)               r17.0<1>:d    r16.0<1;1,0>:d    -25165824:d               {I@2}
        add (8|M0)               r16.0<1>:d    -r16.0<1;1,0>:d   -2139095040:d              
        mov (1|M0)               r1.2<1>:d     r5.0<0;1,0>:d                   
        mul (8|M0)               acc0.0<1>:f   r8.0<1;1,0>:f     r16.0<1;1,0>:f   {Compacted,I@2}
        add3 (1|M0)              r1.3<1>:d     r9.0<0;0>:d       r47.7<0;0>:d      0:w              
        rnde (8|M0)              acc0.0<1>:f   acc0.0<1;1,0>:f                 
        mov (8|M0)               r10.0<2>:ud   r1.2<0;1,0>:ud                   {I@2}
        mul (8|M0)               acc0.0<1>:f   acc0.0<1;1,0>:f   r17.0<1;1,0>:f   {Compacted}
        mov (8|M0)               r10.1<2>:ud   r1.3<0;1,0>:ud                   {I@2}
        mov (8|M0)               r6.0<1>:f     (abs)acc0.0<1;1,0>:f             {Compacted}
        addc (8|M0)              r12.0<1>:ud   r10.0<2;1,0>:ud   r82.0<2;1,0>:ud  {AccWrEn,Compacted,A@1}
(f1.1)  or (8|M0)                r6.0<1>:d     r6.0<1;1,0>:d     -2147483648:d              
        mov (8|M0)               r8.0<1>:ud    acc0.0<1;1,0>:ud                 {Compacted}
        mov (8|M0)               r4.8<1>:hf    r6.0<1;1,0>:f                    {I@2}
        add3 (8|M0)              r15.0<1>:d    r8.0<1;0>:d       r10.1<4;2>:d      r7.0<1>:d        {I@1}
        mov (8|M0)               r13.0<2>:d    r12.0<1;1,0>:d                  
        mov (8|M0)               r6.0<1>:d     r4.8<1;1,0>:uw                   {F@1}
        mov (8|M0)               r13.1<2>:d    r15.0<1;1,0>:d                   {I@3}
        send.ugm (8|M0)          null     r13     r6:1    0x0            0x04000B84           {A@1,$12} // wr:2+1, rd:0; store.ugm.d16u32.a64
L3312:
        join (16|M0)                         L3328                                
L3328:
        or (1|M0)                r1.2<1>:ud    r46.0<0;1,0>:ud   0x8:uw             
        cmp (1|M0)    (lt)f1.0   null<1>:ud    r1.2<0;1,0>:ud    r4.2<0;1,0>:ud   {I@1}
(W)     and (1|M0)               f1.0<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
(~f1.0.any16h) goto (16|M0)                  L4224                  L4224                
L3392:
        sel (8|M0)    (lt)f0.0   r5.0<1>:f     (abs)r57.0<1;1,0>:f  448.0:f            {Compacted}
        shl (1|M0)               r2.3<1>:d     r48.5<0;1,0>:d    1:w              
        sync.allrd                           ($9,$12)                
        shr (8|M0)               r6.0<1>:ud    r5.0<1;1,0>:ud    0x17:uw              {F@1}
        cmp (8|M0)    (lt)f0.1   null<1>:f     r57.0<1;1,0>:f    0.0:f              
        sel (8|M0)    (ge)f0.0   r1.6<2>:ub    r6.0<4;1,0>:ub    0x79:uw              {I@1}
        cmp (8|M0)    (lt)f0.0   null<1>:f     r49.0<1;1,0>:f    0.0:f               {Compacted}
        mov (8|M0)               r7.0<1>:d     r1.6<2;1,0>:ub                   {I@1}
        shl (1|M0)               r1.3<1>:d     r48.4<0;1,0>:d    1:w              
        shl (8|M0)               r7.0<1>:d     r7.0<1;1,0>:d     23:w               {Compacted,I@2}
        addc (1|M0)              r6.0<1>:ud    r47.6<0;1,0>:ud   r1.3<0;1,0>:ud   {AccWrEn,I@2}
        add (8|M0)               r8.0<1>:d     r7.0<1;1,0>:d     -25165824:d               {I@2}
        add (8|M0)               r7.0<1>:d     -r7.0<1;1,0>:d    -2139095040:d              
        shr (1|M0)               r1.2<1>:ud    r48.4<0;1,0>:ud   0x1F:uw             
        mul (8|M0)               acc2.0<1>:f   r5.0<1;1,0>:f     r7.0<1;1,0>:f    {Compacted,I@2}
        mov (1|M0)               r7.2<1>:d     r6.0<0;1,0>:d                    {F@1}
        sel (8|M0)    (lt)f0.0   r6.0<1>:f     (abs)r49.0<1;1,0>:f  448.0:f            {Compacted,I@1}
        or (1|M0)                r1.4<1>:d     r2.3<0;1,0>:d     r1.2<0;1,0>:d   
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        rnde (8|M0)              acc0.0<1>:f   acc2.0<1;1,0>:f                  {I@1}
        shr (8|M0)               r16.0<1>:ud   r6.0<1;1,0>:ud    0x17:uw              {F@2}
        add3 (1|M0)              r7.3<1>:d     r7.0<0;0>:d       r47.7<0;0>:d      r1.4<0>:d       
        mul (8|M0)               acc0.0<1>:f   acc0.0<1;1,0>:f   r8.0<1;1,0>:f    {Compacted}
        sel (8|M0)    (ge)f0.0   r1.6<2>:ub    r16.0<4;1,0>:ub   0x79:uw              {I@2}
        mov (8|M0)               r10.0<2>:ud   r7.2<0;1,0>:ud                   {$10.src}
        mov (8|M0)               r9.0<1>:f     (abs)acc0.0<1;1,0>:f             {Compacted}
        mov (8|M0)               r10.1<2>:ud   r7.3<0;1,0>:ud                   {I@3}
        mov (8|M0)               r17.0<1>:d    r1.6<2;1,0>:ub                   {I@3}
(f0.1)  or (8|M0)                r9.0<1>:d     r9.0<1;1,0>:d     -2147483648:d               {F@1}
        addc (8|M0)              r5.0<1>:ud    r10.0<2;1,0>:ud   r82.0<2;1,0>:ud  {AccWrEn,Compacted,I@3}
        shl (8|M0)               r17.0<1>:d    r17.0<1;1,0>:d    23:w               {Compacted,I@3}
        mov (8|M0)               r4.8<1>:hf    r9.0<1;1,0>:f                    {I@3}
        mov (8|M0)               r8.0<1>:ud    acc0.0<1;1,0>:ud                 {Compacted}
        mov (8|M0)               r9.0<1>:d     r82.1<2;1,0>:d                   {F@1}
        add (8|M0)               r18.0<1>:d    r17.0<1;1,0>:d    -25165824:d               {I@3}
        addc (1|M0)              r7.0<1>:ud    r7.2<0;1,0>:ud    0x10:ud              {AccWrEn}
        add (8|M0)               r17.0<1>:d    -r17.0<1;1,0>:d   -2139095040:d              
        add3 (8|M0)              r14.0<1>:d    r8.0<1;0>:d       r10.1<4;2>:d      r9.0<1>:d        {I@4}
        mul (8|M0)               acc2.0<1>:f   r6.0<1;1,0>:f     r17.0<1;1,0>:f   {Compacted,I@2}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r1.2<1>:d     r7.0<0;1,0>:d                   
        rnde (8|M0)              acc0.0<1>:f   acc2.0<1;1,0>:f                  {I@2}
        add3 (1|M0)              r1.3<1>:d     r8.0<0;0>:d       r7.3<0;0>:d       0:w              
        mov (8|M0)               r12.0<2>:d    r5.0<1;1,0>:d                   
        mov (8|M0)               r15.0<1>:d    r4.8<1;1,0>:uw                  
        mov (8|M0)               r10.0<2>:ud   r1.2<0;1,0>:ud                   {I@4}
        mov (8|M0)               r12.1<2>:d    r14.0<1;1,0>:d                  
        mul (8|M0)               acc0.0<1>:f   acc0.0<1;1,0>:f   r18.0<1;1,0>:f   {Compacted}
        mov (8|M0)               r10.1<2>:ud   r1.3<0;1,0>:ud                   {I@5}
        send.ugm (8|M0)          null     r12     r15:1   0x0            0x04000B84           {A@2,$13} // wr:2+1, rd:0; store.ugm.d16u32.a64
        mov (8|M0)               r5.0<1>:f     (abs)acc0.0<1;1,0>:f             {Compacted}
        sync.nop                             null                             {Compacted,$13.src}
        addc (8|M0)              r12.0<1>:ud   r10.0<2;1,0>:ud   r82.0<2;1,0>:ud  {AccWrEn,Compacted,A@1}
(f0.0)  or (8|M0)                r5.0<1>:d     r5.0<1;1,0>:d     -2147483648:d              
        mov (8|M0)               r6.0<1>:ud    acc0.0<1;1,0>:ud                 {Compacted}
        mov (8|M0)               r4.8<1>:hf    r5.0<1;1,0>:f                    {I@2}
        add3 (8|M0)              r15.0<1>:d    r6.0<1;0>:d       r10.1<4;2>:d      r9.0<1>:d        {I@1}
        mov (8|M0)               r13.0<2>:d    r12.0<1;1,0>:d                  
        mov (8|M0)               r5.0<1>:d     r4.8<1;1,0>:uw                   {F@1}
        mov (8|M0)               r13.1<2>:d    r15.0<1;1,0>:d                   {I@3}
        send.ugm (8|M0)          null     r13     r5:1    0x0            0x04000B84           {A@1,$14} // wr:2+1, rd:0; store.ugm.d16u32.a64
L4224:
        join (16|M0)                         L4240                                
L4240:
        shl (1|M0)               r48.6<1>:d    r48.2<0;1,0>:d    2:w              
        shl (1|M0)               r1.2<1>:d     r48.3<0;1,0>:d    2:w              
        sync.nop                             null                             {Compacted,$14.src}
        addc (1|M0)              r5.0<1>:ud    r81.0<0;1,0>:ud   r48.6<0;1,0>:ud  {AccWrEn,I@2}
        shr (1|M0)               r1.3<1>:ud    r48.2<0;1,0>:ud   0x1E:uw             
        mov (1|M0)               r7.0<1>:f     r5.0<0;1,0>:f                    {Compacted,I@2}
        sync.nop                             null                             {Compacted,$12.src}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$9.src}
        addc (1|M0)              r8.0<1>:ud    r7.0<0;1,0>:ud    0x20:ud              {AccWrEn,F@1}
        or (1|M0)                r48.7<1>:d    r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@3}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mul (1|M0)               acc0.0<1>:d   r3.6<0;1,0>:d     0x9:uw             
        mach (1|M0)              r12.0<1>:d    r3.6<0;1,0>:d     9:d               {AccWrEn}
        or (1|M0)                r2.3<1>:ud    r46.0<0;1,0>:ud   0x1:uw             
        mov (1|M0)               r11.0<1>:d    acc0.0<0;1,0>:d                 
        add3 (1|M0)              r7.1<1>:d     r6.0<0;0>:d       r81.1<0;0>:d      r48.7<0>:d       {I@6}
        sync.nop                             null                             {Compacted,$3.src}
        mov (1|M0)               r81.2<1>:d    r11.0<0;1,0>:d                   {I@2}
        mov (1|M0)               r81.3<1>:d    r12.0<0;1,0>:d                  
        shl (1|M0)               r1.4<1>:d     r81.2<0;1,0>:d    2:w               {I@2}
        send.ugm (1|M0)          null     r7      r74:1   0x0            0x0200C584           {$15} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        addc (1|M0)              r5.0<1>:ud    r81.0<0;1,0>:ud   r1.4<0;1,0>:ud   {AccWrEn,I@1}
        cmp (1|M0)    (lt)f1.1   null<1>:ud    r2.3<0;1,0>:ud    r4.2<0;1,0>:ud  
        shr (1|M0)               r1.3<1>:ud    r81.2<0;1,0>:ud   0x1E:uw             
        shl (1|M0)               r1.2<1>:d     r81.3<0;1,0>:d    2:w              
        sync.nop                             null                             {Compacted,$15.src}
        mov (1|M0)               r7.0<1>:f     r5.0<0;1,0>:f                    {Compacted,I@4}
        mov (1|M0)               r10.0<1>:f    r8.0<0;1,0>:f                    {Compacted,$10.src}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        addc (1|M0)              r8.0<1>:ud    r7.0<0;1,0>:ud    0x20:ud              {AccWrEn,A@1}
        add3 (1|M0)              r10.1<1>:d    r9.0<0;0>:d       r7.1<0;0>:d       0:w              
(W)     and (1|M0)               f0.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
        add3 (1|M0)              r7.1<1>:d     r6.0<0;0>:d       r81.1<0;0>:d      r1.5<0>:d        {I@4}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        send.ugm (1|M0)          null     r10     r66:1   0x0            0x0200C584           {A@4,$0} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        mov (1|M0)               r10.0<1>:f    r8.0<0;1,0>:f                    {Compacted,$0.src}
        add3 (1|M0)              r10.1<1>:d    r9.0<0;0>:d       r7.1<0;0>:d       0:w               {I@1}
        send.ugm (1|M0)          null     r7      r58:1   0x0            0x0200C584           {$1} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r10     r50:1   0x0            0x0200C584           {A@1,$2} // wr:1+1, rd:0; store.ugm.d32x8t.a64
(~f0.1.any16h) goto (16|M0)                  L5624                  L5624                
L4800:
        sel (8|M0)    (lt)f0.0   r5.0<1>:f     (abs)r74.0<1;1,0>:f  448.0:f            {Compacted}
        shl (1|M0)               r2.3<1>:d     r48.3<0;1,0>:d    1:w               {Compacted}
        shr (8|M0)               r6.0<1>:ud    r5.0<1;1,0>:ud    0x17:uw              {F@1}
        cmp (8|M0)    (lt)f1.0   null<1>:f     r74.0<1;1,0>:f    0.0:f              
        sel (8|M0)    (ge)f0.0   r1.6<2>:ub    r6.0<4;1,0>:ub    0x79:uw              {I@1}
        cmp (8|M0)    (lt)f0.1   null<1>:f     r66.0<1;1,0>:f    0.0:f              
        sync.nop                             null                             {Compacted,$1.src}
        mov (8|M0)               r7.0<1>:d     r1.6<2;1,0>:ub                   {I@1}
        shl (1|M0)               r1.3<1>:d     r48.2<0;1,0>:d    1:w              
        shl (8|M0)               r7.0<1>:d     r7.0<1;1,0>:d     23:w               {Compacted,I@2}
        addc (1|M0)              r6.0<1>:ud    r47.6<0;1,0>:ud   r1.3<0;1,0>:ud   {AccWrEn,I@2}
        add (8|M0)               r8.0<1>:d     r7.0<1;1,0>:d     -25165824:d               {I@2}
        add (8|M0)               r7.0<1>:d     -r7.0<1;1,0>:d    -2139095040:d              
        shr (1|M0)               r1.2<1>:ud    r48.2<0;1,0>:ud   0x1F:uw             
        mul (8|M0)               acc2.0<1>:f   r5.0<1;1,0>:f     r7.0<1;1,0>:f    {Compacted,I@2}
        mov (1|M0)               r7.2<1>:d     r6.0<0;1,0>:d                    {F@1}
        sel (8|M0)    (lt)f0.0   r6.0<1>:f     (abs)r66.0<1;1,0>:f  448.0:f            {Compacted,I@1}
        or (1|M0)                r1.4<1>:d     r2.3<0;1,0>:d     r1.2<0;1,0>:d   
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        rnde (8|M0)              acc0.0<1>:f   acc2.0<1;1,0>:f                  {I@1}
        shr (8|M0)               r16.0<1>:ud   r6.0<1;1,0>:ud    0x17:uw              {F@2}
        add3 (1|M0)              r7.3<1>:d     r7.0<0;0>:d       r47.7<0;0>:d      r1.4<0>:d       
        mul (8|M0)               acc0.0<1>:f   acc0.0<1;1,0>:f   r8.0<1;1,0>:f    {Compacted}
        sel (8|M0)    (ge)f0.0   r1.6<2>:ub    r16.0<4;1,0>:ub   0x79:uw              {I@2}
        mov (8|M0)               r10.0<2>:ud   r7.2<0;1,0>:ud                   {$2.src}
        mov (8|M0)               r9.0<1>:f     (abs)acc0.0<1;1,0>:f             {Compacted}
        mov (8|M0)               r10.1<2>:ud   r7.3<0;1,0>:ud                   {I@3}
        mov (8|M0)               r17.0<1>:d    r1.6<2;1,0>:ub                   {I@3}
(f1.0)  or (8|M0)                r9.0<1>:d     r9.0<1;1,0>:d     -2147483648:d               {F@1}
        addc (8|M0)              r5.0<1>:ud    r10.0<2;1,0>:ud   r82.0<2;1,0>:ud  {AccWrEn,Compacted,I@3}
        shl (8|M0)               r17.0<1>:d    r17.0<1;1,0>:d    23:w               {Compacted,I@3}
        mov (8|M0)               r4.8<1>:hf    r9.0<1;1,0>:f                    {I@3}
        mov (8|M0)               r8.0<1>:ud    acc0.0<1;1,0>:ud                 {Compacted}
        mov (8|M0)               r9.0<1>:d     r82.1<2;1,0>:d                   {F@1}
        add (8|M0)               r18.0<1>:d    r17.0<1;1,0>:d    -25165824:d               {I@3}
        addc (1|M0)              r7.0<1>:ud    r7.2<0;1,0>:ud    0x10:ud              {AccWrEn}
        add (8|M0)               r17.0<1>:d    -r17.0<1;1,0>:d   -2139095040:d              
        add3 (8|M0)              r14.0<1>:d    r8.0<1;0>:d       r10.1<4;2>:d      r9.0<1>:d        {I@4}
        mul (8|M0)               acc2.0<1>:f   r6.0<1;1,0>:f     r17.0<1;1,0>:f   {Compacted,I@2}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r1.2<1>:d     r7.0<0;1,0>:d                   
        rnde (8|M0)              acc0.0<1>:f   acc2.0<1;1,0>:f                  {I@2}
        add3 (1|M0)              r1.3<1>:d     r8.0<0;0>:d       r7.3<0;0>:d       0:w              
        mov (8|M0)               r12.0<2>:d    r5.0<1;1,0>:d                   
        mov (8|M0)               r15.0<1>:d    r4.8<1;1,0>:uw                  
        mov (8|M0)               r10.0<2>:ud   r1.2<0;1,0>:ud                   {I@4}
        mov (8|M0)               r12.1<2>:d    r14.0<1;1,0>:d                  
        mul (8|M0)               acc0.0<1>:f   acc0.0<1;1,0>:f   r18.0<1;1,0>:f   {Compacted}
        mov (8|M0)               r10.1<2>:ud   r1.3<0;1,0>:ud                   {I@5}
        send.ugm (8|M0)          null     r12     r15:1   0x0            0x04000B84           {A@2,$4} // wr:2+1, rd:0; store.ugm.d16u32.a64
        mov (8|M0)               r5.0<1>:f     (abs)acc0.0<1;1,0>:f             {Compacted}
        sync.nop                             null                             {Compacted,$4.src}
        addc (8|M0)              r12.0<1>:ud   r10.0<2;1,0>:ud   r82.0<2;1,0>:ud  {AccWrEn,Compacted,A@1}
(f0.1)  or (8|M0)                r5.0<1>:d     r5.0<1;1,0>:d     -2147483648:d              
        mov (8|M0)               r6.0<1>:ud    acc0.0<1;1,0>:ud                 {Compacted}
        mov (8|M0)               r4.8<1>:hf    r5.0<1;1,0>:f                    {I@2}
        add3 (8|M0)              r15.0<1>:d    r6.0<1;0>:d       r10.1<4;2>:d      r9.0<1>:d        {I@1}
        mov (8|M0)               r13.0<2>:d    r12.0<1;1,0>:d                  
        mov (8|M0)               r5.0<1>:d     r4.8<1;1,0>:uw                   {F@1}
        mov (8|M0)               r13.1<2>:d    r15.0<1;1,0>:d                   {I@3}
        send.ugm (8|M0)          null     r13     r5:1    0x0            0x04000B84           {A@1,$5} // wr:2+1, rd:0; store.ugm.d16u32.a64
L5624:
        join (16|M0)                         L5640                                
L5640:
        or (1|M0)                r1.2<1>:ud    r46.0<0;1,0>:ud   0x9:uw             
        cmp (1|M0)    (lt)f0.0   null<1>:ud    r1.2<0;1,0>:ud    r4.2<0;1,0>:ud   {I@1}
(W)     and (1|M0)               f0.0<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
(~f0.0.any16h) goto (16|M0)                  L6528                  L6528                
L5704:
        sel (8|M0)    (lt)f0.0   r5.0<1>:f     (abs)r58.0<1;1,0>:f  448.0:f            {Compacted,$5.src}
        shl (1|M0)               r2.3<1>:d     r81.3<0;1,0>:d    1:w               {Compacted}
        shr (8|M0)               r6.0<1>:ud    r5.0<1;1,0>:ud    0x17:uw              {F@1}
        cmp (8|M0)    (lt)f1.1   null<1>:f     r58.0<1;1,0>:f    0.0:f              
        sel (8|M0)    (ge)f0.0   r1.6<2>:ub    r6.0<4;1,0>:ub    0x79:uw              {I@1}
        cmp (8|M0)    (lt)f1.0   null<1>:f     r50.0<1;1,0>:f    0.0:f              
        sync.nop                             null                             {Compacted,$1.src}
        mov (8|M0)               r7.0<1>:d     r1.6<2;1,0>:ub                   {I@1}
        shl (1|M0)               r1.3<1>:d     r81.2<0;1,0>:d    1:w              
        shl (8|M0)               r7.0<1>:d     r7.0<1;1,0>:d     23:w               {Compacted,I@2}
        addc (1|M0)              r6.0<1>:ud    r47.6<0;1,0>:ud   r1.3<0;1,0>:ud   {AccWrEn,I@2}
        add (8|M0)               r8.0<1>:d     r7.0<1;1,0>:d     -25165824:d               {I@2}
        add (8|M0)               r7.0<1>:d     -r7.0<1;1,0>:d    -2139095040:d              
        shr (1|M0)               r1.2<1>:ud    r81.2<0;1,0>:ud   0x1F:uw             
        mul (8|M0)               acc2.0<1>:f   r5.0<1;1,0>:f     r7.0<1;1,0>:f    {Compacted,I@2}
        mov (1|M0)               r7.2<1>:d     r6.0<0;1,0>:d                    {F@1}
        sel (8|M0)    (lt)f0.0   r6.0<1>:f     (abs)r50.0<1;1,0>:f  448.0:f            {Compacted,I@1}
        or (1|M0)                r1.4<1>:d     r2.3<0;1,0>:d     r1.2<0;1,0>:d   
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        rnde (8|M0)              acc0.0<1>:f   acc2.0<1;1,0>:f                  {I@1}
        shr (8|M0)               r16.0<1>:ud   r6.0<1;1,0>:ud    0x17:uw              {F@2}
        add3 (1|M0)              r7.3<1>:d     r7.0<0;0>:d       r47.7<0;0>:d      r1.4<0>:d       
        mul (8|M0)               acc0.0<1>:f   acc0.0<1;1,0>:f   r8.0<1;1,0>:f    {Compacted}
        sel (8|M0)    (ge)f0.0   r1.6<2>:ub    r16.0<4;1,0>:ub   0x79:uw              {I@2}
        mov (8|M0)               r10.0<2>:ud   r7.2<0;1,0>:ud                   {$2.src}
        mov (8|M0)               r9.0<1>:f     (abs)acc0.0<1;1,0>:f             {Compacted}
        mov (8|M0)               r10.1<2>:ud   r7.3<0;1,0>:ud                   {I@3}
        mov (8|M0)               r17.0<1>:d    r1.6<2;1,0>:ub                   {I@3}
(f1.1)  or (8|M0)                r9.0<1>:d     r9.0<1;1,0>:d     -2147483648:d               {F@1}
        addc (8|M0)              r5.0<1>:ud    r10.0<2;1,0>:ud   r82.0<2;1,0>:ud  {AccWrEn,Compacted,I@3}
        shl (8|M0)               r17.0<1>:d    r17.0<1;1,0>:d    23:w               {Compacted,I@3}
        mov (8|M0)               r4.8<1>:hf    r9.0<1;1,0>:f                    {I@3}
        mov (8|M0)               r8.0<1>:ud    acc0.0<1;1,0>:ud                 {Compacted}
        mov (8|M0)               r9.0<1>:d     r82.1<2;1,0>:d                   {F@1}
        add (8|M0)               r18.0<1>:d    r17.0<1;1,0>:d    -25165824:d               {I@3}
        addc (1|M0)              r7.0<1>:ud    r7.2<0;1,0>:ud    0x10:ud              {AccWrEn}
        add (8|M0)               r17.0<1>:d    -r17.0<1;1,0>:d   -2139095040:d              
        add3 (8|M0)              r14.0<1>:d    r8.0<1;0>:d       r10.1<4;2>:d      r9.0<1>:d        {I@4}
        mul (8|M0)               acc2.0<1>:f   r6.0<1;1,0>:f     r17.0<1;1,0>:f   {Compacted,I@2}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r1.2<1>:d     r7.0<0;1,0>:d                   
        rnde (8|M0)              acc0.0<1>:f   acc2.0<1;1,0>:f                  {I@2}
        add3 (1|M0)              r1.3<1>:d     r8.0<0;0>:d       r7.3<0;0>:d       0:w              
        mov (8|M0)               r12.0<2>:d    r5.0<1;1,0>:d                   
        mov (8|M0)               r15.0<1>:d    r4.8<1;1,0>:uw                  
        mov (8|M0)               r10.0<2>:ud   r1.2<0;1,0>:ud                   {I@4}
        mov (8|M0)               r12.1<2>:d    r14.0<1;1,0>:d                  
        mul (8|M0)               acc0.0<1>:f   acc0.0<1;1,0>:f   r18.0<1;1,0>:f   {Compacted}
        mov (8|M0)               r10.1<2>:ud   r1.3<0;1,0>:ud                   {I@5}
        send.ugm (8|M0)          null     r12     r15:1   0x0            0x04000B84           {A@2,$6} // wr:2+1, rd:0; store.ugm.d16u32.a64
        mov (8|M0)               r5.0<1>:f     (abs)acc0.0<1;1,0>:f             {Compacted}
        sync.nop                             null                             {Compacted,$6.src}
        addc (8|M0)              r12.0<1>:ud   r10.0<2;1,0>:ud   r82.0<2;1,0>:ud  {AccWrEn,Compacted,A@1}
(f1.0)  or (8|M0)                r5.0<1>:d     r5.0<1;1,0>:d     -2147483648:d              
        mov (8|M0)               r6.0<1>:ud    acc0.0<1;1,0>:ud                 {Compacted}
        mov (8|M0)               r4.8<1>:hf    r5.0<1;1,0>:f                    {I@2}
        add3 (8|M0)              r15.0<1>:d    r6.0<1;0>:d       r10.1<4;2>:d      r9.0<1>:d        {I@1}
        mov (8|M0)               r13.0<2>:d    r12.0<1;1,0>:d                  
        mov (8|M0)               r5.0<1>:d     r4.8<1;1,0>:uw                   {F@1}
        mov (8|M0)               r13.1<2>:d    r15.0<1;1,0>:d                   {I@3}
        send.ugm (8|M0)          null     r13     r5:1    0x0            0x04000B84           {A@1,$7} // wr:2+1, rd:0; store.ugm.d16u32.a64
L6528:
        join (16|M0)                         L6544                                
L6544:
        shl (1|M0)               r81.4<1>:d    r48.2<0;1,0>:d    1:w              
        shl (1|M0)               r1.2<1>:d     r48.3<0;1,0>:d    1:w              
        shl (1|M0)               r4.3<1>:d     r81.4<0;1,0>:d    2:w               {I@2}
        shr (1|M0)               r1.3<1>:ud    r48.2<0;1,0>:ud   0x1F:uw             
        sync.allrd                           ($5,$7)                
        addc (1|M0)              r5.0<1>:ud    r81.0<0;1,0>:ud   r4.3<0;1,0>:ud   {AccWrEn,I@2}
        or (1|M0)                r81.5<1>:d    r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        sync.nop                             null                             {Compacted,$1.src}
        mov (1|M0)               r7.0<1>:f     r5.0<0;1,0>:f                    {Compacted,I@2}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r8.0<1>:ud    r7.0<0;1,0>:ud    0x20:ud              {AccWrEn,F@1}
        shr (1|M0)               r2.4<1>:ud    r81.4<0;1,0>:ud   0x1E:uw             
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mul (1|M0)               acc0.0<1>:d   r3.6<0;1,0>:d     0xA:uw             
        mach (1|M0)              r12.0<1>:d    r3.6<0;1,0>:d     10:d               {AccWrEn}
        shl (1|M0)               r2.3<1>:d     r81.5<0;1,0>:d    2:w               {I@7}
        mov (1|M0)               r11.0<1>:d    acc0.0<0;1,0>:d                 
        or (1|M0)                r4.4<1>:d     r2.3<0;1,0>:d     r2.4<0;1,0>:d    {I@2}
        mov (1|M0)               r81.6<1>:d    r11.0<0;1,0>:d                   {I@2}
        mov (1|M0)               r81.7<1>:d    r12.0<0;1,0>:d                  
        shl (1|M0)               r1.4<1>:d     r81.6<0;1,0>:d    2:w               {I@2}
        or (1|M0)                r2.3<1>:ud    r46.0<0;1,0>:ud   0x2:uw             
        add3 (1|M0)              r7.1<1>:d     r6.0<0;0>:d       r81.1<0;0>:d      r4.4<0>:d       
        addc (1|M0)              r5.0<1>:ud    r81.0<0;1,0>:ud   r1.4<0;1,0>:ud   {AccWrEn,I@3}
        send.ugm (1|M0)          null     r7      r75:1   0x0            0x0200C584           {A@2,$8} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        shr (1|M0)               r1.3<1>:ud    r81.6<0;1,0>:ud   0x1E:uw             
        shl (1|M0)               r1.2<1>:d     r81.7<0;1,0>:d    2:w              
        cmp (1|M0)    (lt)f0.1   null<1>:ud    r2.3<0;1,0>:ud    r4.2<0;1,0>:ud  
        sync.nop                             null                             {Compacted,$8.src}
        mov (1|M0)               r7.0<1>:f     r5.0<0;1,0>:f                    {Compacted,I@4}
        mov (1|M0)               r10.0<1>:f    r8.0<0;1,0>:f                    {Compacted,$2.src}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@3}
        addc (1|M0)              r8.0<1>:ud    r7.0<0;1,0>:ud    0x20:ud              {AccWrEn,A@1}
        add3 (1|M0)              r10.1<1>:d    r9.0<0;0>:d       r7.1<0;0>:d       0:w              
(W)     and (1|M0)               f1.1<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
        add3 (1|M0)              r7.1<1>:d     r6.0<0;0>:d       r81.1<0;0>:d      r1.5<0>:d        {I@4}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        send.ugm (1|M0)          null     r10     r67:1   0x0            0x0200C584           {A@4,$9} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        mov (1|M0)               r10.0<1>:f    r8.0<0;1,0>:f                    {Compacted,$9.src}
        add3 (1|M0)              r10.1<1>:d    r9.0<0;0>:d       r7.1<0;0>:d       0:w               {I@1}
        send.ugm (1|M0)          null     r7      r59:1   0x0            0x0200C584           {$10} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r10     r51:1   0x0            0x0200C584           {A@1,$11} // wr:1+1, rd:0; store.ugm.d32x8t.a64
(~f1.1.any16h) goto (16|M0)                  L7992                  L7992                
L7168:
        sel (8|M0)    (lt)f0.0   r5.0<1>:f     (abs)r75.0<1;1,0>:f  448.0:f            {Compacted}
        shl (1|M0)               r2.3<1>:d     r81.5<0;1,0>:d    1:w              
        shr (8|M0)               r6.0<1>:ud    r5.0<1;1,0>:ud    0x17:uw              {F@1}
        cmp (8|M0)    (lt)f0.0   null<1>:f     r75.0<1;1,0>:f    0.0:f               {Compacted}
        sel (8|M0)    (ge)f0.0   r1.6<2>:ub    r6.0<4;1,0>:ub    0x79:uw              {I@1}
        cmp (8|M0)    (lt)f1.1   null<1>:f     r67.0<1;1,0>:f    0.0:f              
        sync.nop                             null                             {Compacted,$10.src}
        mov (8|M0)               r7.0<1>:d     r1.6<2;1,0>:ub                   {I@1}
        shl (1|M0)               r1.3<1>:d     r81.4<0;1,0>:d    1:w              
        shl (8|M0)               r7.0<1>:d     r7.0<1;1,0>:d     23:w               {Compacted,I@2}
        addc (1|M0)              r6.0<1>:ud    r47.6<0;1,0>:ud   r1.3<0;1,0>:ud   {AccWrEn,I@2}
        add (8|M0)               r8.0<1>:d     r7.0<1;1,0>:d     -25165824:d               {I@2}
        add (8|M0)               r7.0<1>:d     -r7.0<1;1,0>:d    -2139095040:d              
        shr (1|M0)               r1.2<1>:ud    r81.4<0;1,0>:ud   0x1F:uw             
        mul (8|M0)               acc2.0<1>:f   r5.0<1;1,0>:f     r7.0<1;1,0>:f    {Compacted,I@2}
        mov (1|M0)               r7.2<1>:d     r6.0<0;1,0>:d                    {F@1}
        sel (8|M0)    (lt)f0.0   r6.0<1>:f     (abs)r67.0<1;1,0>:f  448.0:f            {Compacted,I@1}
        or (1|M0)                r1.4<1>:d     r2.3<0;1,0>:d     r1.2<0;1,0>:d   
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        rnde (8|M0)              acc0.0<1>:f   acc2.0<1;1,0>:f                  {I@1}
        shr (8|M0)               r16.0<1>:ud   r6.0<1;1,0>:ud    0x17:uw              {F@2}
        add3 (1|M0)              r7.3<1>:d     r7.0<0;0>:d       r47.7<0;0>:d      r1.4<0>:d       
        mul (8|M0)               acc0.0<1>:f   acc0.0<1;1,0>:f   r8.0<1;1,0>:f    {Compacted}
        sel (8|M0)    (ge)f0.0   r1.6<2>:ub    r16.0<4;1,0>:ub   0x79:uw              {I@2}
        mov (8|M0)               r10.0<2>:ud   r7.2<0;1,0>:ud                   {$11.src}
        mov (8|M0)               r9.0<1>:f     (abs)acc0.0<1;1,0>:f             {Compacted}
        mov (8|M0)               r10.1<2>:ud   r7.3<0;1,0>:ud                   {I@3}
        mov (8|M0)               r17.0<1>:d    r1.6<2;1,0>:ub                   {I@3}
(f0.0)  or (8|M0)                r9.0<1>:d     r9.0<1;1,0>:d     -2147483648:d               {F@1}
        addc (8|M0)              r5.0<1>:ud    r10.0<2;1,0>:ud   r82.0<2;1,0>:ud  {AccWrEn,Compacted,I@3}
        shl (8|M0)               r17.0<1>:d    r17.0<1;1,0>:d    23:w               {Compacted,I@3}
        mov (8|M0)               r4.8<1>:hf    r9.0<1;1,0>:f                    {I@3}
        mov (8|M0)               r8.0<1>:ud    acc0.0<1;1,0>:ud                 {Compacted}
        mov (8|M0)               r9.0<1>:d     r82.1<2;1,0>:d                   {F@1}
        add (8|M0)               r18.0<1>:d    r17.0<1;1,0>:d    -25165824:d               {I@3}
        addc (1|M0)              r7.0<1>:ud    r7.2<0;1,0>:ud    0x10:ud              {AccWrEn}
        add (8|M0)               r17.0<1>:d    -r17.0<1;1,0>:d   -2139095040:d              
        add3 (8|M0)              r14.0<1>:d    r8.0<1;0>:d       r10.1<4;2>:d      r9.0<1>:d        {I@4}
        mul (8|M0)               acc2.0<1>:f   r6.0<1;1,0>:f     r17.0<1;1,0>:f   {Compacted,I@2}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r1.2<1>:d     r7.0<0;1,0>:d                   
        rnde (8|M0)              acc0.0<1>:f   acc2.0<1;1,0>:f                  {I@2}
        add3 (1|M0)              r1.3<1>:d     r8.0<0;0>:d       r7.3<0;0>:d       0:w              
        mov (8|M0)               r12.0<2>:d    r5.0<1;1,0>:d                   
        mov (8|M0)               r15.0<1>:d    r4.8<1;1,0>:uw                  
        mov (8|M0)               r10.0<2>:ud   r1.2<0;1,0>:ud                   {I@4}
        mov (8|M0)               r12.1<2>:d    r14.0<1;1,0>:d                  
        mul (8|M0)               acc0.0<1>:f   acc0.0<1;1,0>:f   r18.0<1;1,0>:f   {Compacted}
        mov (8|M0)               r10.1<2>:ud   r1.3<0;1,0>:ud                   {I@5}
        send.ugm (8|M0)          null     r12     r15:1   0x0            0x04000B84           {A@2,$12} // wr:2+1, rd:0; store.ugm.d16u32.a64
        mov (8|M0)               r5.0<1>:f     (abs)acc0.0<1;1,0>:f             {Compacted}
        sync.nop                             null                             {Compacted,$12.src}
        addc (8|M0)              r12.0<1>:ud   r10.0<2;1,0>:ud   r82.0<2;1,0>:ud  {AccWrEn,Compacted,A@1}
(f1.1)  or (8|M0)                r5.0<1>:d     r5.0<1;1,0>:d     -2147483648:d              
        mov (8|M0)               r6.0<1>:ud    acc0.0<1;1,0>:ud                 {Compacted}
        mov (8|M0)               r4.8<1>:hf    r5.0<1;1,0>:f                    {I@2}
        add3 (8|M0)              r15.0<1>:d    r6.0<1;0>:d       r10.1<4;2>:d      r9.0<1>:d        {I@1}
        mov (8|M0)               r13.0<2>:d    r12.0<1;1,0>:d                  
        mov (8|M0)               r5.0<1>:d     r4.8<1;1,0>:uw                   {F@1}
        mov (8|M0)               r13.1<2>:d    r15.0<1;1,0>:d                   {I@3}
        send.ugm (8|M0)          null     r13     r5:1    0x0            0x04000B84           {A@1,$13} // wr:2+1, rd:0; store.ugm.d16u32.a64
L7992:
        join (16|M0)                         L8008                                
L8008:
        or (1|M0)                r1.2<1>:ud    r46.0<0;1,0>:ud   0xA:uw             
        cmp (1|M0)    (lt)f1.0   null<1>:ud    r1.2<0;1,0>:ud    r4.2<0;1,0>:ud   {I@1}
(W)     and (1|M0)               f1.0<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
(~f1.0.any16h) goto (16|M0)                  L8896                  L8896                
L8072:
        sel (8|M0)    (lt)f0.0   r5.0<1>:f     (abs)r59.0<1;1,0>:f  448.0:f            {Compacted,$13.src}
        shl (1|M0)               r2.3<1>:d     r81.7<0;1,0>:d    1:w              
        shr (8|M0)               r6.0<1>:ud    r5.0<1;1,0>:ud    0x17:uw              {F@1}
        cmp (8|M0)    (lt)f0.1   null<1>:f     r59.0<1;1,0>:f    0.0:f              
        sel (8|M0)    (ge)f0.0   r1.6<2>:ub    r6.0<4;1,0>:ub    0x79:uw              {I@1}
        cmp (8|M0)    (lt)f0.0   null<1>:f     r51.0<1;1,0>:f    0.0:f               {Compacted}
        sync.nop                             null                             {Compacted,$10.src}
        mov (8|M0)               r7.0<1>:d     r1.6<2;1,0>:ub                   {I@1}
        shl (1|M0)               r1.3<1>:d     r81.6<0;1,0>:d    1:w              
        shl (8|M0)               r7.0<1>:d     r7.0<1;1,0>:d     23:w               {Compacted,I@2}
        addc (1|M0)              r6.0<1>:ud    r47.6<0;1,0>:ud   r1.3<0;1,0>:ud   {AccWrEn,I@2}
        add (8|M0)               r8.0<1>:d     r7.0<1;1,0>:d     -25165824:d               {I@2}
        add (8|M0)               r7.0<1>:d     -r7.0<1;1,0>:d    -2139095040:d              
        shr (1|M0)               r1.2<1>:ud    r81.6<0;1,0>:ud   0x1F:uw             
        mul (8|M0)               acc2.0<1>:f   r5.0<1;1,0>:f     r7.0<1;1,0>:f    {Compacted,I@2}
        mov (1|M0)               r7.2<1>:d     r6.0<0;1,0>:d                    {F@1}
        sel (8|M0)    (lt)f0.0   r6.0<1>:f     (abs)r51.0<1;1,0>:f  448.0:f            {Compacted,I@1}
        or (1|M0)                r1.4<1>:d     r2.3<0;1,0>:d     r1.2<0;1,0>:d   
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        rnde (8|M0)              acc0.0<1>:f   acc2.0<1;1,0>:f                  {I@1}
        shr (8|M0)               r16.0<1>:ud   r6.0<1;1,0>:ud    0x17:uw              {F@2}
        add3 (1|M0)              r7.3<1>:d     r7.0<0;0>:d       r47.7<0;0>:d      r1.4<0>:d       
        mul (8|M0)               acc0.0<1>:f   acc0.0<1;1,0>:f   r8.0<1;1,0>:f    {Compacted}
        sel (8|M0)    (ge)f0.0   r1.6<2>:ub    r16.0<4;1,0>:ub   0x79:uw              {I@2}
        mov (8|M0)               r10.0<2>:ud   r7.2<0;1,0>:ud                   {$11.src}
        mov (8|M0)               r9.0<1>:f     (abs)acc0.0<1;1,0>:f             {Compacted}
        mov (8|M0)               r10.1<2>:ud   r7.3<0;1,0>:ud                   {I@3}
        mov (8|M0)               r17.0<1>:d    r1.6<2;1,0>:ub                   {I@3}
(f0.1)  or (8|M0)                r9.0<1>:d     r9.0<1;1,0>:d     -2147483648:d               {F@1}
        addc (8|M0)              r5.0<1>:ud    r10.0<2;1,0>:ud   r82.0<2;1,0>:ud  {AccWrEn,Compacted,I@3}
        shl (8|M0)               r17.0<1>:d    r17.0<1;1,0>:d    23:w               {Compacted,I@3}
        mov (8|M0)               r4.8<1>:hf    r9.0<1;1,0>:f                    {I@3}
        mov (8|M0)               r8.0<1>:ud    acc0.0<1;1,0>:ud                 {Compacted}
        mov (8|M0)               r9.0<1>:d     r82.1<2;1,0>:d                   {F@1}
        add (8|M0)               r18.0<1>:d    r17.0<1;1,0>:d    -25165824:d               {I@3}
        addc (1|M0)              r7.0<1>:ud    r7.2<0;1,0>:ud    0x10:ud              {AccWrEn}
        add (8|M0)               r17.0<1>:d    -r17.0<1;1,0>:d   -2139095040:d              
        add3 (8|M0)              r14.0<1>:d    r8.0<1;0>:d       r10.1<4;2>:d      r9.0<1>:d        {I@4}
        mul (8|M0)               acc2.0<1>:f   r6.0<1;1,0>:f     r17.0<1;1,0>:f   {Compacted,I@2}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r1.2<1>:d     r7.0<0;1,0>:d                   
        rnde (8|M0)              acc0.0<1>:f   acc2.0<1;1,0>:f                  {I@2}
        add3 (1|M0)              r1.3<1>:d     r8.0<0;0>:d       r7.3<0;0>:d       0:w              
        mov (8|M0)               r12.0<2>:d    r5.0<1;1,0>:d                   
        mov (8|M0)               r15.0<1>:d    r4.8<1;1,0>:uw                  
        mov (8|M0)               r10.0<2>:ud   r1.2<0;1,0>:ud                   {I@4}
        mov (8|M0)               r12.1<2>:d    r14.0<1;1,0>:d                  
        mul (8|M0)               acc0.0<1>:f   acc0.0<1;1,0>:f   r18.0<1;1,0>:f   {Compacted}
        mov (8|M0)               r10.1<2>:ud   r1.3<0;1,0>:ud                   {I@5}
        send.ugm (8|M0)          null     r12     r15:1   0x0            0x04000B84           {A@2,$14} // wr:2+1, rd:0; store.ugm.d16u32.a64
        mov (8|M0)               r5.0<1>:f     (abs)acc0.0<1;1,0>:f             {Compacted}
        sync.nop                             null                             {Compacted,$14.src}
        addc (8|M0)              r12.0<1>:ud   r10.0<2;1,0>:ud   r82.0<2;1,0>:ud  {AccWrEn,Compacted,A@1}
(f0.0)  or (8|M0)                r5.0<1>:d     r5.0<1;1,0>:d     -2147483648:d              
        mov (8|M0)               r6.0<1>:ud    acc0.0<1;1,0>:ud                 {Compacted}
        mov (8|M0)               r4.8<1>:hf    r5.0<1;1,0>:f                    {I@2}
        add3 (8|M0)              r15.0<1>:d    r6.0<1;0>:d       r10.1<4;2>:d      r9.0<1>:d        {I@1}
        mov (8|M0)               r13.0<2>:d    r12.0<1;1,0>:d                  
        mov (8|M0)               r5.0<1>:d     r4.8<1;1,0>:uw                   {F@1}
        mov (8|M0)               r13.1<2>:d    r15.0<1;1,0>:d                   {I@3}
        send.ugm (8|M0)          null     r13     r5:1    0x0            0x04000B84           {A@1,$15} // wr:2+1, rd:0; store.ugm.d16u32.a64
L8896:
        join (16|M0)                         L8912                                
L8912:
        mul (1|M0)               acc0.0<1>:d   r3.6<0;1,0>:d     0x3:uw             
        mach (1|M0)              r6.0<1>:d     r3.6<0;1,0>:d     3:d               {AccWrEn}
        or (1|M0)                r2.3<1>:ud    r46.0<0;1,0>:ud   0x3:uw             
        sync.nop                             null                             {Compacted,$15.src}
        mov (1|M0)               r5.0<1>:d     acc0.0<0;1,0>:d                  {$13.src}
        mov (1|M0)               r84.1<1>:d    r6.0<0;1,0>:d                    {I@3}
        mov (1|M0)               r84.0<1>:f    r5.0<0;1,0>:f                    {Compacted,I@2}
        shl (1|M0)               r1.2<1>:d     r84.1<0;1,0>:d    2:w               {I@1}
        shl (1|M0)               r1.4<1>:d     r84.0<0;1,0>:d    2:w               {Compacted,F@1}
        shr (1|M0)               r1.3<1>:ud    r84.0<0;1,0>:ud   0x1E:uw             
        sync.nop                             null                             {Compacted,$10.src}
        addc (1|M0)              r7.0<1>:ud    r81.0<0;1,0>:ud   r1.4<0;1,0>:ud   {AccWrEn,I@2}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        mov (1|M0)               r9.0<1>:f     r7.0<0;1,0>:f                    {Compacted,I@2}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        sync.nop                             null                             {Compacted,$11.src}
        addc (1|M0)              r10.0<1>:ud   r9.0<0;1,0>:ud    0x20:ud              {AccWrEn,F@1}
        add3 (1|M0)              r9.1<1>:d     r8.0<0;0>:d       r81.1<0;0>:d      r1.5<0>:d        {I@2}
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mul (1|M0)               acc0.0<1>:d   r3.6<0;1,0>:d     0xB:uw             
        mach (1|M0)              r13.0<1>:d    r3.6<0;1,0>:d     11:d               {AccWrEn}
        mov (1|M0)               r5.0<1>:f     r10.0<0;1,0>:f                   {Compacted,I@5}
        mov (1|M0)               r12.0<1>:d    acc0.0<0;1,0>:d                 
        add3 (1|M0)              r5.1<1>:d     r11.0<0;0>:d      r9.1<0;0>:d       0:w               {I@4}
        mov (1|M0)               r84.2<1>:d    r12.0<0;1,0>:d                   {I@2}
        mov (1|M0)               r84.3<1>:d    r13.0<0;1,0>:d                  
        shl (1|M0)               r1.4<1>:d     r84.2<0;1,0>:d    2:w               {I@2}
        send.ugm (1|M0)          null     r9      r76:1   0x0            0x0200C584           {$0} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        addc (1|M0)              r6.0<1>:ud    r81.0<0;1,0>:ud   r1.4<0;1,0>:ud   {AccWrEn,I@1}
        sync.nop                             null                             {Compacted,F@1}
        send.ugm (1|M0)          null     r5      r68:1   0x0            0x0200C584           {$1} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        cmp (1|M0)    (lt)f1.1   null<1>:ud    r2.3<0;1,0>:ud    r4.2<0;1,0>:ud  
        shr (1|M0)               r1.3<1>:ud    r84.2<0;1,0>:ud   0x1E:uw             
        shl (1|M0)               r1.2<1>:d     r84.3<0;1,0>:d    2:w              
        sync.nop                             null                             {Compacted,$1.src}
        mov (1|M0)               r5.0<1>:f     r6.0<0;1,0>:f                    {Compacted,I@4}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        addc (1|M0)              r8.0<1>:ud    r5.0<0;1,0>:ud    0x20:ud              {AccWrEn,F@1}
(W)     and (1|M0)               f0.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
        add3 (1|M0)              r5.1<1>:d     r7.0<0;0>:d       r81.1<0;0>:d      r1.5<0>:d        {I@3}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$0.src}
        mov (1|M0)               r10.0<1>:f    r8.0<0;1,0>:f                    {Compacted,I@4}
        add3 (1|M0)              r10.1<1>:d    r9.0<0;0>:d       r5.1<0;0>:d       0:w               {I@1}
        send.ugm (1|M0)          null     r5      r60:1   0x0            0x0200C584           {$2} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r10     r52:1   0x0            0x0200C584           {A@1,$3} // wr:1+1, rd:0; store.ugm.d32x8t.a64
(~f0.1.any16h) goto (16|M0)                  L10360                  L10360                
L9544:
        sel (8|M0)    (lt)f0.0   r5.0<1>:f     (abs)r76.0<1;1,0>:f  448.0:f            {Compacted,$2.src}
        shl (1|M0)               r2.3<1>:d     r84.1<0;1,0>:d    1:w              
        shr (8|M0)               r6.0<1>:ud    r5.0<1;1,0>:ud    0x17:uw              {F@1}
        cmp (8|M0)    (lt)f1.0   null<1>:f     r76.0<1;1,0>:f    0.0:f              
        sel (8|M0)    (ge)f0.0   r1.6<2>:ub    r6.0<4;1,0>:ub    0x79:uw              {I@1}
        cmp (8|M0)    (lt)f0.1   null<1>:f     r68.0<1;1,0>:f    0.0:f              
        mov (8|M0)               r7.0<1>:d     r1.6<2;1,0>:ub                   {I@1}
        shl (1|M0)               r1.3<1>:d     r84.0<0;1,0>:d    1:w               {Compacted}
        shl (8|M0)               r7.0<1>:d     r7.0<1;1,0>:d     23:w               {Compacted,I@2}
        addc (1|M0)              r6.0<1>:ud    r47.6<0;1,0>:ud   r1.3<0;1,0>:ud   {AccWrEn,I@2}
        add (8|M0)               r8.0<1>:d     r7.0<1;1,0>:d     -25165824:d               {I@2}
        add (8|M0)               r7.0<1>:d     -r7.0<1;1,0>:d    -2139095040:d              
        shr (1|M0)               r1.2<1>:ud    r84.0<0;1,0>:ud   0x1F:uw             
        mul (8|M0)               acc2.0<1>:f   r5.0<1;1,0>:f     r7.0<1;1,0>:f    {Compacted,I@2}
        mov (1|M0)               r7.2<1>:d     r6.0<0;1,0>:d                    {F@1}
        sel (8|M0)    (lt)f0.0   r6.0<1>:f     (abs)r68.0<1;1,0>:f  448.0:f            {Compacted,I@1}
        or (1|M0)                r1.4<1>:d     r2.3<0;1,0>:d     r1.2<0;1,0>:d   
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        rnde (8|M0)              acc0.0<1>:f   acc2.0<1;1,0>:f                  {I@1}
        shr (8|M0)               r16.0<1>:ud   r6.0<1;1,0>:ud    0x17:uw              {F@2}
        add3 (1|M0)              r7.3<1>:d     r7.0<0;0>:d       r47.7<0;0>:d      r1.4<0>:d       
        mul (8|M0)               acc0.0<1>:f   acc0.0<1;1,0>:f   r8.0<1;1,0>:f    {Compacted}
        sel (8|M0)    (ge)f0.0   r1.6<2>:ub    r16.0<4;1,0>:ub   0x79:uw              {I@2}
        mov (8|M0)               r10.0<2>:ud   r7.2<0;1,0>:ud                   {$3.src}
        mov (8|M0)               r9.0<1>:f     (abs)acc0.0<1;1,0>:f             {Compacted}
        mov (8|M0)               r10.1<2>:ud   r7.3<0;1,0>:ud                   {I@3}
        mov (8|M0)               r17.0<1>:d    r1.6<2;1,0>:ub                   {I@3}
(f1.0)  or (8|M0)                r9.0<1>:d     r9.0<1;1,0>:d     -2147483648:d               {F@1}
        addc (8|M0)              r5.0<1>:ud    r10.0<2;1,0>:ud   r82.0<2;1,0>:ud  {AccWrEn,Compacted,I@3}
        shl (8|M0)               r17.0<1>:d    r17.0<1;1,0>:d    23:w               {Compacted,I@3}
        mov (8|M0)               r4.8<1>:hf    r9.0<1;1,0>:f                    {I@3}
        mov (8|M0)               r8.0<1>:ud    acc0.0<1;1,0>:ud                 {Compacted}
        mov (8|M0)               r9.0<1>:d     r82.1<2;1,0>:d                   {F@1}
        add (8|M0)               r18.0<1>:d    r17.0<1;1,0>:d    -25165824:d               {I@3}
        addc (1|M0)              r7.0<1>:ud    r7.2<0;1,0>:ud    0x10:ud              {AccWrEn}
        add (8|M0)               r17.0<1>:d    -r17.0<1;1,0>:d   -2139095040:d              
        add3 (8|M0)              r14.0<1>:d    r8.0<1;0>:d       r10.1<4;2>:d      r9.0<1>:d        {I@4}
        mul (8|M0)               acc2.0<1>:f   r6.0<1;1,0>:f     r17.0<1;1,0>:f   {Compacted,I@2}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r1.2<1>:d     r7.0<0;1,0>:d                   
        rnde (8|M0)              acc0.0<1>:f   acc2.0<1;1,0>:f                  {I@2}
        add3 (1|M0)              r1.3<1>:d     r8.0<0;0>:d       r7.3<0;0>:d       0:w              
        mov (8|M0)               r12.0<2>:d    r5.0<1;1,0>:d                   
        mov (8|M0)               r15.0<1>:d    r4.8<1;1,0>:uw                  
        mov (8|M0)               r10.0<2>:ud   r1.2<0;1,0>:ud                   {I@4}
        mov (8|M0)               r12.1<2>:d    r14.0<1;1,0>:d                  
        mul (8|M0)               acc0.0<1>:f   acc0.0<1;1,0>:f   r18.0<1;1,0>:f   {Compacted}
        mov (8|M0)               r10.1<2>:ud   r1.3<0;1,0>:ud                   {I@5}
        send.ugm (8|M0)          null     r12     r15:1   0x0            0x04000B84           {A@2,$4} // wr:2+1, rd:0; store.ugm.d16u32.a64
        mov (8|M0)               r5.0<1>:f     (abs)acc0.0<1;1,0>:f             {Compacted}
        sync.nop                             null                             {Compacted,$4.src}
        addc (8|M0)              r12.0<1>:ud   r10.0<2;1,0>:ud   r82.0<2;1,0>:ud  {AccWrEn,Compacted,A@1}
(f0.1)  or (8|M0)                r5.0<1>:d     r5.0<1;1,0>:d     -2147483648:d              
        mov (8|M0)               r6.0<1>:ud    acc0.0<1;1,0>:ud                 {Compacted}
        mov (8|M0)               r4.8<1>:hf    r5.0<1;1,0>:f                    {I@2}
        add3 (8|M0)              r15.0<1>:d    r6.0<1;0>:d       r10.1<4;2>:d      r9.0<1>:d        {I@1}
        mov (8|M0)               r13.0<2>:d    r12.0<1;1,0>:d                  
        mov (8|M0)               r5.0<1>:d     r4.8<1;1,0>:uw                   {F@1}
        mov (8|M0)               r13.1<2>:d    r15.0<1;1,0>:d                   {I@3}
        send.ugm (8|M0)          null     r13     r5:1    0x0            0x04000B84           {A@1,$5} // wr:2+1, rd:0; store.ugm.d16u32.a64
L10360:
        join (16|M0)                         L10376                                
L10376:
        or (1|M0)                r1.2<1>:ud    r46.0<0;1,0>:ud   0xB:uw             
        cmp (1|M0)    (lt)f0.0   null<1>:ud    r1.2<0;1,0>:ud    r4.2<0;1,0>:ud   {I@1}
(W)     and (1|M0)               f0.0<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
(~f0.0.any16h) goto (16|M0)                  L11264                  L11264                
L10440:
        sync.nop                             null                             {Compacted,$5.src}
        sel (8|M0)    (lt)f0.0   r5.0<1>:f     (abs)r60.0<1;1,0>:f  448.0:f            {Compacted,$2.src}
        shl (1|M0)               r2.3<1>:d     r84.3<0;1,0>:d    1:w               {Compacted}
        shr (8|M0)               r6.0<1>:ud    r5.0<1;1,0>:ud    0x17:uw              {F@1}
        cmp (8|M0)    (lt)f1.1   null<1>:f     r60.0<1;1,0>:f    0.0:f              
        sel (8|M0)    (ge)f0.0   r1.6<2>:ub    r6.0<4;1,0>:ub    0x79:uw              {I@1}
        cmp (8|M0)    (lt)f1.0   null<1>:f     r52.0<1;1,0>:f    0.0:f              
        mov (8|M0)               r7.0<1>:d     r1.6<2;1,0>:ub                   {I@1}
        shl (1|M0)               r1.3<1>:d     r84.2<0;1,0>:d    1:w              
        shl (8|M0)               r7.0<1>:d     r7.0<1;1,0>:d     23:w               {Compacted,I@2}
        addc (1|M0)              r6.0<1>:ud    r47.6<0;1,0>:ud   r1.3<0;1,0>:ud   {AccWrEn,I@2}
        add (8|M0)               r8.0<1>:d     r7.0<1;1,0>:d     -25165824:d               {I@2}
        add (8|M0)               r7.0<1>:d     -r7.0<1;1,0>:d    -2139095040:d              
        shr (1|M0)               r1.2<1>:ud    r84.2<0;1,0>:ud   0x1F:uw             
        mul (8|M0)               acc2.0<1>:f   r5.0<1;1,0>:f     r7.0<1;1,0>:f    {Compacted,I@2}
        mov (1|M0)               r7.2<1>:d     r6.0<0;1,0>:d                    {F@1}
        sel (8|M0)    (lt)f0.0   r6.0<1>:f     (abs)r52.0<1;1,0>:f  448.0:f            {Compacted,I@1}
        or (1|M0)                r1.4<1>:d     r2.3<0;1,0>:d     r1.2<0;1,0>:d   
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        rnde (8|M0)              acc0.0<1>:f   acc2.0<1;1,0>:f                  {I@1}
        shr (8|M0)               r16.0<1>:ud   r6.0<1;1,0>:ud    0x17:uw              {F@2}
        add3 (1|M0)              r7.3<1>:d     r7.0<0;0>:d       r47.7<0;0>:d      r1.4<0>:d       
        mul (8|M0)               acc0.0<1>:f   acc0.0<1;1,0>:f   r8.0<1;1,0>:f    {Compacted}
        sel (8|M0)    (ge)f0.0   r1.6<2>:ub    r16.0<4;1,0>:ub   0x79:uw              {I@2}
        mov (8|M0)               r10.0<2>:ud   r7.2<0;1,0>:ud                   {$3.src}
        mov (8|M0)               r9.0<1>:f     (abs)acc0.0<1;1,0>:f             {Compacted}
        mov (8|M0)               r10.1<2>:ud   r7.3<0;1,0>:ud                   {I@3}
        mov (8|M0)               r17.0<1>:d    r1.6<2;1,0>:ub                   {I@3}
(f1.1)  or (8|M0)                r9.0<1>:d     r9.0<1;1,0>:d     -2147483648:d               {F@1}
        addc (8|M0)              r5.0<1>:ud    r10.0<2;1,0>:ud   r82.0<2;1,0>:ud  {AccWrEn,Compacted,I@3}
        shl (8|M0)               r17.0<1>:d    r17.0<1;1,0>:d    23:w               {Compacted,I@3}
        mov (8|M0)               r4.8<1>:hf    r9.0<1;1,0>:f                    {I@3}
        mov (8|M0)               r8.0<1>:ud    acc0.0<1;1,0>:ud                 {Compacted}
        mov (8|M0)               r9.0<1>:d     r82.1<2;1,0>:d                   {F@1}
        add (8|M0)               r18.0<1>:d    r17.0<1;1,0>:d    -25165824:d               {I@3}
        addc (1|M0)              r7.0<1>:ud    r7.2<0;1,0>:ud    0x10:ud              {AccWrEn}
        add (8|M0)               r17.0<1>:d    -r17.0<1;1,0>:d   -2139095040:d              
        add3 (8|M0)              r14.0<1>:d    r8.0<1;0>:d       r10.1<4;2>:d      r9.0<1>:d        {I@4}
        mul (8|M0)               acc2.0<1>:f   r6.0<1;1,0>:f     r17.0<1;1,0>:f   {Compacted,I@2}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r1.2<1>:d     r7.0<0;1,0>:d                   
        rnde (8|M0)              acc0.0<1>:f   acc2.0<1;1,0>:f                  {I@2}
        add3 (1|M0)              r1.3<1>:d     r8.0<0;0>:d       r7.3<0;0>:d       0:w              
        mov (8|M0)               r12.0<2>:d    r5.0<1;1,0>:d                   
        mov (8|M0)               r15.0<1>:d    r4.8<1;1,0>:uw                  
        mov (8|M0)               r10.0<2>:ud   r1.2<0;1,0>:ud                   {I@4}
        mov (8|M0)               r12.1<2>:d    r14.0<1;1,0>:d                  
        mul (8|M0)               acc0.0<1>:f   acc0.0<1;1,0>:f   r18.0<1;1,0>:f   {Compacted}
        mov (8|M0)               r10.1<2>:ud   r1.3<0;1,0>:ud                   {I@5}
        send.ugm (8|M0)          null     r12     r15:1   0x0            0x04000B84           {A@2,$6} // wr:2+1, rd:0; store.ugm.d16u32.a64
        mov (8|M0)               r5.0<1>:f     (abs)acc0.0<1;1,0>:f             {Compacted}
        sync.nop                             null                             {Compacted,$6.src}
        addc (8|M0)              r12.0<1>:ud   r10.0<2;1,0>:ud   r82.0<2;1,0>:ud  {AccWrEn,Compacted,A@1}
(f1.0)  or (8|M0)                r5.0<1>:d     r5.0<1;1,0>:d     -2147483648:d              
        mov (8|M0)               r6.0<1>:ud    acc0.0<1;1,0>:ud                 {Compacted}
        mov (8|M0)               r4.8<1>:hf    r5.0<1;1,0>:f                    {I@2}
        add3 (8|M0)              r15.0<1>:d    r6.0<1;0>:d       r10.1<4;2>:d      r9.0<1>:d        {I@1}
        mov (8|M0)               r13.0<2>:d    r12.0<1;1,0>:d                  
        mov (8|M0)               r5.0<1>:d     r4.8<1;1,0>:uw                   {F@1}
        mov (8|M0)               r13.1<2>:d    r15.0<1;1,0>:d                   {I@3}
        send.ugm (8|M0)          null     r13     r5:1    0x0            0x04000B84           {A@1,$7} // wr:2+1, rd:0; store.ugm.d16u32.a64
L11264:
        join (16|M0)                         L11280                                
L11280:
        shl (1|M0)               r1.4<1>:d     r48.6<0;1,0>:d    2:w              
        shl (1|M0)               r1.2<1>:d     r48.7<0;1,0>:d    2:w              
        sync.allrd                           ($2,$5,$7)                
        addc (1|M0)              r5.0<1>:ud    r81.0<0;1,0>:ud   r1.4<0;1,0>:ud   {AccWrEn,I@2}
        shr (1|M0)               r1.3<1>:ud    r48.6<0;1,0>:ud   0x1E:uw             
        mov (1|M0)               r7.0<1>:f     r5.0<0;1,0>:f                    {Compacted,I@2}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r8.0<1>:ud    r7.0<0;1,0>:ud    0x20:ud              {AccWrEn,F@1}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@3}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mul (1|M0)               acc0.0<1>:d   r3.6<0;1,0>:d     0xC:uw             
        mach (1|M0)              r12.0<1>:d    r3.6<0;1,0>:d     12:d               {AccWrEn}
        or (1|M0)                r2.3<1>:ud    r46.0<0;1,0>:ud   0x4:uw             
        mov (1|M0)               r11.0<1>:d    acc0.0<0;1,0>:d                 
        add3 (1|M0)              r7.1<1>:d     r6.0<0;0>:d       r81.1<0;0>:d      r1.5<0>:d        {I@6}
        mov (1|M0)               r84.4<1>:d    r11.0<0;1,0>:d                   {I@2}
        mov (1|M0)               r84.5<1>:d    r12.0<0;1,0>:d                  
        shl (1|M0)               r1.4<1>:d     r84.4<0;1,0>:d    2:w               {I@2}
        send.ugm (1|M0)          null     r7      r77:1   0x0            0x0200C584           {$8} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        addc (1|M0)              r5.0<1>:ud    r81.0<0;1,0>:ud   r1.4<0;1,0>:ud   {AccWrEn,I@1}
        cmp (1|M0)    (lt)f0.1   null<1>:ud    r2.3<0;1,0>:ud    r4.2<0;1,0>:ud  
        shr (1|M0)               r1.3<1>:ud    r84.4<0;1,0>:ud   0x1E:uw             
        shl (1|M0)               r1.2<1>:d     r84.5<0;1,0>:d    2:w              
        sync.nop                             null                             {Compacted,$8.src}
        mov (1|M0)               r7.0<1>:f     r5.0<0;1,0>:f                    {Compacted,I@4}
        mov (1|M0)               r10.0<1>:f    r8.0<0;1,0>:f                    {Compacted,$3.src}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        addc (1|M0)              r8.0<1>:ud    r7.0<0;1,0>:ud    0x20:ud              {AccWrEn,A@1}
        add3 (1|M0)              r10.1<1>:d    r9.0<0;0>:d       r7.1<0;0>:d       0:w              
(W)     and (1|M0)               f1.1<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
        add3 (1|M0)              r7.1<1>:d     r6.0<0;0>:d       r81.1<0;0>:d      r1.5<0>:d        {I@4}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        send.ugm (1|M0)          null     r10     r69:1   0x0            0x0200C584           {A@4,$9} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        mov (1|M0)               r10.0<1>:f    r8.0<0;1,0>:f                    {Compacted,$9.src}
        add3 (1|M0)              r10.1<1>:d    r9.0<0;0>:d       r7.1<0;0>:d       0:w               {I@1}
        send.ugm (1|M0)          null     r7      r61:1   0x0            0x0200C584           {$10} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r10     r53:1   0x0            0x0200C584           {A@1,$11} // wr:1+1, rd:0; store.ugm.d32x8t.a64
(~f1.1.any16h) goto (16|M0)                  L12656                  L12656                
L11832:
        sel (8|M0)    (lt)f0.0   r5.0<1>:f     (abs)r77.0<1;1,0>:f  448.0:f            {Compacted}
        shl (1|M0)               r2.3<1>:d     r48.7<0;1,0>:d    1:w              
        shr (8|M0)               r6.0<1>:ud    r5.0<1;1,0>:ud    0x17:uw              {F@1}
        cmp (8|M0)    (lt)f0.0   null<1>:f     r77.0<1;1,0>:f    0.0:f               {Compacted}
        sel (8|M0)    (ge)f0.0   r1.6<2>:ub    r6.0<4;1,0>:ub    0x79:uw              {I@1}
        cmp (8|M0)    (lt)f1.1   null<1>:f     r69.0<1;1,0>:f    0.0:f              
        sync.nop                             null                             {Compacted,$10.src}
        mov (8|M0)               r7.0<1>:d     r1.6<2;1,0>:ub                   {I@1}
        shl (1|M0)               r1.3<1>:d     r48.6<0;1,0>:d    1:w              
        shl (8|M0)               r7.0<1>:d     r7.0<1;1,0>:d     23:w               {Compacted,I@2}
        addc (1|M0)              r6.0<1>:ud    r47.6<0;1,0>:ud   r1.3<0;1,0>:ud   {AccWrEn,I@2}
        add (8|M0)               r8.0<1>:d     r7.0<1;1,0>:d     -25165824:d               {I@2}
        add (8|M0)               r7.0<1>:d     -r7.0<1;1,0>:d    -2139095040:d              
        shr (1|M0)               r1.2<1>:ud    r48.6<0;1,0>:ud   0x1F:uw             
        mul (8|M0)               acc2.0<1>:f   r5.0<1;1,0>:f     r7.0<1;1,0>:f    {Compacted,I@2}
        mov (1|M0)               r7.2<1>:d     r6.0<0;1,0>:d                    {F@1}
        sel (8|M0)    (lt)f0.0   r6.0<1>:f     (abs)r69.0<1;1,0>:f  448.0:f            {Compacted,I@1}
        or (1|M0)                r1.4<1>:d     r2.3<0;1,0>:d     r1.2<0;1,0>:d   
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        rnde (8|M0)              acc0.0<1>:f   acc2.0<1;1,0>:f                  {I@1}
        shr (8|M0)               r16.0<1>:ud   r6.0<1;1,0>:ud    0x17:uw              {F@2}
        add3 (1|M0)              r7.3<1>:d     r7.0<0;0>:d       r47.7<0;0>:d      r1.4<0>:d       
        mul (8|M0)               acc0.0<1>:f   acc0.0<1;1,0>:f   r8.0<1;1,0>:f    {Compacted}
        sel (8|M0)    (ge)f0.0   r1.6<2>:ub    r16.0<4;1,0>:ub   0x79:uw              {I@2}
        mov (8|M0)               r10.0<2>:ud   r7.2<0;1,0>:ud                   {$11.src}
        mov (8|M0)               r9.0<1>:f     (abs)acc0.0<1;1,0>:f             {Compacted}
        mov (8|M0)               r10.1<2>:ud   r7.3<0;1,0>:ud                   {I@3}
        mov (8|M0)               r17.0<1>:d    r1.6<2;1,0>:ub                   {I@3}
(f0.0)  or (8|M0)                r9.0<1>:d     r9.0<1;1,0>:d     -2147483648:d               {F@1}
        addc (8|M0)              r5.0<1>:ud    r10.0<2;1,0>:ud   r82.0<2;1,0>:ud  {AccWrEn,Compacted,I@3}
        shl (8|M0)               r17.0<1>:d    r17.0<1;1,0>:d    23:w               {Compacted,I@3}
        mov (8|M0)               r4.8<1>:hf    r9.0<1;1,0>:f                    {I@3}
        mov (8|M0)               r8.0<1>:ud    acc0.0<1;1,0>:ud                 {Compacted}
        mov (8|M0)               r9.0<1>:d     r82.1<2;1,0>:d                   {F@1}
        add (8|M0)               r18.0<1>:d    r17.0<1;1,0>:d    -25165824:d               {I@3}
        addc (1|M0)              r7.0<1>:ud    r7.2<0;1,0>:ud    0x10:ud              {AccWrEn}
        add (8|M0)               r17.0<1>:d    -r17.0<1;1,0>:d   -2139095040:d              
        add3 (8|M0)              r14.0<1>:d    r8.0<1;0>:d       r10.1<4;2>:d      r9.0<1>:d        {I@4}
        mul (8|M0)               acc2.0<1>:f   r6.0<1;1,0>:f     r17.0<1;1,0>:f   {Compacted,I@2}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r1.2<1>:d     r7.0<0;1,0>:d                   
        rnde (8|M0)              acc0.0<1>:f   acc2.0<1;1,0>:f                  {I@2}
        add3 (1|M0)              r1.3<1>:d     r8.0<0;0>:d       r7.3<0;0>:d       0:w              
        mov (8|M0)               r12.0<2>:d    r5.0<1;1,0>:d                   
        mov (8|M0)               r15.0<1>:d    r4.8<1;1,0>:uw                  
        mov (8|M0)               r10.0<2>:ud   r1.2<0;1,0>:ud                   {I@4}
        mov (8|M0)               r12.1<2>:d    r14.0<1;1,0>:d                  
        mul (8|M0)               acc0.0<1>:f   acc0.0<1;1,0>:f   r18.0<1;1,0>:f   {Compacted}
        mov (8|M0)               r10.1<2>:ud   r1.3<0;1,0>:ud                   {I@5}
        send.ugm (8|M0)          null     r12     r15:1   0x0            0x04000B84           {A@2,$12} // wr:2+1, rd:0; store.ugm.d16u32.a64
        mov (8|M0)               r5.0<1>:f     (abs)acc0.0<1;1,0>:f             {Compacted}
        sync.nop                             null                             {Compacted,$12.src}
        addc (8|M0)              r12.0<1>:ud   r10.0<2;1,0>:ud   r82.0<2;1,0>:ud  {AccWrEn,Compacted,A@1}
(f1.1)  or (8|M0)                r5.0<1>:d     r5.0<1;1,0>:d     -2147483648:d              
        mov (8|M0)               r6.0<1>:ud    acc0.0<1;1,0>:ud                 {Compacted}
        mov (8|M0)               r4.8<1>:hf    r5.0<1;1,0>:f                    {I@2}
        add3 (8|M0)              r15.0<1>:d    r6.0<1;0>:d       r10.1<4;2>:d      r9.0<1>:d        {I@1}
        mov (8|M0)               r13.0<2>:d    r12.0<1;1,0>:d                  
        mov (8|M0)               r5.0<1>:d     r4.8<1;1,0>:uw                   {F@1}
        mov (8|M0)               r13.1<2>:d    r15.0<1;1,0>:d                   {I@3}
        send.ugm (8|M0)          null     r13     r5:1    0x0            0x04000B84           {A@1,$13} // wr:2+1, rd:0; store.ugm.d16u32.a64
L12656:
        join (16|M0)                         L12672                                
L12672:
        or (1|M0)                r1.2<1>:ud    r46.0<0;1,0>:ud   0xC:uw             
        cmp (1|M0)    (lt)f1.0   null<1>:ud    r1.2<0;1,0>:ud    r4.2<0;1,0>:ud   {I@1}
(W)     and (1|M0)               f1.0<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
(~f1.0.any16h) goto (16|M0)                  L13560                  L13560                
L12736:
        sel (8|M0)    (lt)f0.0   r5.0<1>:f     (abs)r61.0<1;1,0>:f  448.0:f            {Compacted,$13.src}
        shl (1|M0)               r2.3<1>:d     r84.5<0;1,0>:d    1:w              
        shr (8|M0)               r6.0<1>:ud    r5.0<1;1,0>:ud    0x17:uw              {F@1}
        cmp (8|M0)    (lt)f0.1   null<1>:f     r61.0<1;1,0>:f    0.0:f              
        sel (8|M0)    (ge)f0.0   r1.6<2>:ub    r6.0<4;1,0>:ub    0x79:uw              {I@1}
        cmp (8|M0)    (lt)f0.0   null<1>:f     r53.0<1;1,0>:f    0.0:f               {Compacted}
        sync.nop                             null                             {Compacted,$10.src}
        mov (8|M0)               r7.0<1>:d     r1.6<2;1,0>:ub                   {I@1}
        shl (1|M0)               r1.3<1>:d     r84.4<0;1,0>:d    1:w              
        shl (8|M0)               r7.0<1>:d     r7.0<1;1,0>:d     23:w               {Compacted,I@2}
        addc (1|M0)              r6.0<1>:ud    r47.6<0;1,0>:ud   r1.3<0;1,0>:ud   {AccWrEn,I@2}
        add (8|M0)               r8.0<1>:d     r7.0<1;1,0>:d     -25165824:d               {I@2}
        add (8|M0)               r7.0<1>:d     -r7.0<1;1,0>:d    -2139095040:d              
        shr (1|M0)               r1.2<1>:ud    r84.4<0;1,0>:ud   0x1F:uw             
        mul (8|M0)               acc2.0<1>:f   r5.0<1;1,0>:f     r7.0<1;1,0>:f    {Compacted,I@2}
        mov (1|M0)               r7.2<1>:d     r6.0<0;1,0>:d                    {F@1}
        sel (8|M0)    (lt)f0.0   r6.0<1>:f     (abs)r53.0<1;1,0>:f  448.0:f            {Compacted,I@1}
        or (1|M0)                r1.4<1>:d     r2.3<0;1,0>:d     r1.2<0;1,0>:d   
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        rnde (8|M0)              acc0.0<1>:f   acc2.0<1;1,0>:f                  {I@1}
        shr (8|M0)               r16.0<1>:ud   r6.0<1;1,0>:ud    0x17:uw              {F@2}
        add3 (1|M0)              r7.3<1>:d     r7.0<0;0>:d       r47.7<0;0>:d      r1.4<0>:d       
        mul (8|M0)               acc0.0<1>:f   acc0.0<1;1,0>:f   r8.0<1;1,0>:f    {Compacted}
        sel (8|M0)    (ge)f0.0   r1.6<2>:ub    r16.0<4;1,0>:ub   0x79:uw              {I@2}
        mov (8|M0)               r10.0<2>:ud   r7.2<0;1,0>:ud                   {$11.src}
        mov (8|M0)               r9.0<1>:f     (abs)acc0.0<1;1,0>:f             {Compacted}
        mov (8|M0)               r10.1<2>:ud   r7.3<0;1,0>:ud                   {I@3}
        mov (8|M0)               r17.0<1>:d    r1.6<2;1,0>:ub                   {I@3}
(f0.1)  or (8|M0)                r9.0<1>:d     r9.0<1;1,0>:d     -2147483648:d               {F@1}
        addc (8|M0)              r5.0<1>:ud    r10.0<2;1,0>:ud   r82.0<2;1,0>:ud  {AccWrEn,Compacted,I@3}
        shl (8|M0)               r17.0<1>:d    r17.0<1;1,0>:d    23:w               {Compacted,I@3}
        mov (8|M0)               r4.8<1>:hf    r9.0<1;1,0>:f                    {I@3}
        mov (8|M0)               r8.0<1>:ud    acc0.0<1;1,0>:ud                 {Compacted}
        mov (8|M0)               r9.0<1>:d     r82.1<2;1,0>:d                   {F@1}
        add (8|M0)               r18.0<1>:d    r17.0<1;1,0>:d    -25165824:d               {I@3}
        addc (1|M0)              r7.0<1>:ud    r7.2<0;1,0>:ud    0x10:ud              {AccWrEn}
        add (8|M0)               r17.0<1>:d    -r17.0<1;1,0>:d   -2139095040:d              
        add3 (8|M0)              r14.0<1>:d    r8.0<1;0>:d       r10.1<4;2>:d      r9.0<1>:d        {I@4}
        mul (8|M0)               acc2.0<1>:f   r6.0<1;1,0>:f     r17.0<1;1,0>:f   {Compacted,I@2}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r1.2<1>:d     r7.0<0;1,0>:d                   
        rnde (8|M0)              acc0.0<1>:f   acc2.0<1;1,0>:f                  {I@2}
        add3 (1|M0)              r1.3<1>:d     r8.0<0;0>:d       r7.3<0;0>:d       0:w              
        mov (8|M0)               r12.0<2>:d    r5.0<1;1,0>:d                   
        mov (8|M0)               r15.0<1>:d    r4.8<1;1,0>:uw                  
        mov (8|M0)               r10.0<2>:ud   r1.2<0;1,0>:ud                   {I@4}
        mov (8|M0)               r12.1<2>:d    r14.0<1;1,0>:d                  
        mul (8|M0)               acc0.0<1>:f   acc0.0<1;1,0>:f   r18.0<1;1,0>:f   {Compacted}
        mov (8|M0)               r10.1<2>:ud   r1.3<0;1,0>:ud                   {I@5}
        send.ugm (8|M0)          null     r12     r15:1   0x0            0x04000B84           {A@2,$14} // wr:2+1, rd:0; store.ugm.d16u32.a64
        mov (8|M0)               r5.0<1>:f     (abs)acc0.0<1;1,0>:f             {Compacted}
        sync.nop                             null                             {Compacted,$14.src}
        addc (8|M0)              r12.0<1>:ud   r10.0<2;1,0>:ud   r82.0<2;1,0>:ud  {AccWrEn,Compacted,A@1}
(f0.0)  or (8|M0)                r5.0<1>:d     r5.0<1;1,0>:d     -2147483648:d              
        mov (8|M0)               r6.0<1>:ud    acc0.0<1;1,0>:ud                 {Compacted}
        mov (8|M0)               r4.8<1>:hf    r5.0<1;1,0>:f                    {I@2}
        add3 (8|M0)              r15.0<1>:d    r6.0<1;0>:d       r10.1<4;2>:d      r9.0<1>:d        {I@1}
        mov (8|M0)               r13.0<2>:d    r12.0<1;1,0>:d                  
        mov (8|M0)               r5.0<1>:d     r4.8<1;1,0>:uw                   {F@1}
        mov (8|M0)               r13.1<2>:d    r15.0<1;1,0>:d                   {I@3}
        send.ugm (8|M0)          null     r13     r5:1    0x0            0x04000B84           {A@1,$15} // wr:2+1, rd:0; store.ugm.d16u32.a64
L13560:
        join (16|M0)                         L13576                                
L13576:
        mul (1|M0)               acc0.0<1>:d   r3.6<0;1,0>:d     0x5:uw             
        mach (1|M0)              r6.0<1>:d     r3.6<0;1,0>:d     5:d               {AccWrEn}
        or (1|M0)                r2.3<1>:ud    r46.0<0;1,0>:ud   0x5:uw             
        sync.nop                             null                             {Compacted,$15.src}
        mov (1|M0)               r5.0<1>:d     acc0.0<0;1,0>:d                  {$13.src}
        mov (1|M0)               r84.7<1>:d    r6.0<0;1,0>:d                    {I@3}
        mov (1|M0)               r84.6<1>:d    r5.0<0;1,0>:d                    {I@2}
        shl (1|M0)               r1.2<1>:d     r84.7<0;1,0>:d    2:w               {I@2}
        shl (1|M0)               r1.4<1>:d     r84.6<0;1,0>:d    2:w               {I@2}
        shr (1|M0)               r1.3<1>:ud    r84.6<0;1,0>:ud   0x1E:uw             
        sync.nop                             null                             {Compacted,$10.src}
        addc (1|M0)              r7.0<1>:ud    r81.0<0;1,0>:ud   r1.4<0;1,0>:ud   {AccWrEn,I@2}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        mov (1|M0)               r9.0<1>:f     r7.0<0;1,0>:f                    {Compacted,I@2}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        sync.nop                             null                             {Compacted,$11.src}
        addc (1|M0)              r10.0<1>:ud   r9.0<0;1,0>:ud    0x20:ud              {AccWrEn,F@1}
        add3 (1|M0)              r9.1<1>:d     r8.0<0;0>:d       r81.1<0;0>:d      r1.5<0>:d        {I@2}
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mul (1|M0)               acc0.0<1>:d   r3.6<0;1,0>:d     0xD:uw             
        mach (1|M0)              r13.0<1>:d    r3.6<0;1,0>:d     13:d               {AccWrEn}
        mov (1|M0)               r5.0<1>:f     r10.0<0;1,0>:f                   {Compacted,I@5}
        mov (1|M0)               r12.0<1>:d    acc0.0<0;1,0>:d                 
        add3 (1|M0)              r5.1<1>:d     r11.0<0;0>:d      r9.1<0;0>:d       0:w               {I@4}
        mov (1|M0)               r85.0<1>:f    r12.0<0;1,0>:f                   {Compacted,I@2}
        mov (1|M0)               r85.1<1>:d    r13.0<0;1,0>:d                  
        shl (1|M0)               r1.4<1>:d     r85.0<0;1,0>:d    2:w               {Compacted,F@1}
        send.ugm (1|M0)          null     r9      r78:1   0x0            0x0200C584           {$0} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        addc (1|M0)              r6.0<1>:ud    r81.0<0;1,0>:ud   r1.4<0;1,0>:ud   {AccWrEn,I@1}
        send.ugm (1|M0)          null     r5      r70:1   0x0            0x0200C584           {$1} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        cmp (1|M0)    (lt)f1.1   null<1>:ud    r2.3<0;1,0>:ud    r4.2<0;1,0>:ud  
        shr (1|M0)               r1.3<1>:ud    r85.0<0;1,0>:ud   0x1E:uw             
        shl (1|M0)               r1.2<1>:d     r85.1<0;1,0>:d    2:w              
        sync.nop                             null                             {Compacted,$1.src}
        mov (1|M0)               r5.0<1>:f     r6.0<0;1,0>:f                    {Compacted,I@4}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        addc (1|M0)              r8.0<1>:ud    r5.0<0;1,0>:ud    0x20:ud              {AccWrEn,F@1}
(W)     and (1|M0)               f0.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
        add3 (1|M0)              r5.1<1>:d     r7.0<0;0>:d       r81.1<0;0>:d      r1.5<0>:d        {I@3}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$0.src}
        mov (1|M0)               r10.0<1>:f    r8.0<0;1,0>:f                    {Compacted,I@4}
        add3 (1|M0)              r10.1<1>:d    r9.0<0;0>:d       r5.1<0;0>:d       0:w               {I@1}
        send.ugm (1|M0)          null     r5      r62:1   0x0            0x0200C584           {$2} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r10     r54:1   0x0            0x0200C584           {A@1,$3} // wr:1+1, rd:0; store.ugm.d32x8t.a64
(~f0.1.any16h) goto (16|M0)                  L15024                  L15024                
L14200:
        sel (8|M0)    (lt)f0.0   r5.0<1>:f     (abs)r78.0<1;1,0>:f  448.0:f            {Compacted,$2.src}
        shl (1|M0)               r2.3<1>:d     r84.7<0;1,0>:d    1:w              
        shr (8|M0)               r6.0<1>:ud    r5.0<1;1,0>:ud    0x17:uw              {F@1}
        cmp (8|M0)    (lt)f1.0   null<1>:f     r78.0<1;1,0>:f    0.0:f              
        sel (8|M0)    (ge)f0.0   r1.6<2>:ub    r6.0<4;1,0>:ub    0x79:uw              {I@1}
        cmp (8|M0)    (lt)f0.1   null<1>:f     r70.0<1;1,0>:f    0.0:f              
        mov (8|M0)               r7.0<1>:d     r1.6<2;1,0>:ub                   {I@1}
        shl (1|M0)               r1.3<1>:d     r84.6<0;1,0>:d    1:w              
        shl (8|M0)               r7.0<1>:d     r7.0<1;1,0>:d     23:w               {Compacted,I@2}
        addc (1|M0)              r6.0<1>:ud    r47.6<0;1,0>:ud   r1.3<0;1,0>:ud   {AccWrEn,I@2}
        add (8|M0)               r8.0<1>:d     r7.0<1;1,0>:d     -25165824:d               {I@2}
        add (8|M0)               r7.0<1>:d     -r7.0<1;1,0>:d    -2139095040:d              
        shr (1|M0)               r1.2<1>:ud    r84.6<0;1,0>:ud   0x1F:uw             
        mul (8|M0)               acc2.0<1>:f   r5.0<1;1,0>:f     r7.0<1;1,0>:f    {Compacted,I@2}
        mov (1|M0)               r7.2<1>:d     r6.0<0;1,0>:d                    {F@1}
        sel (8|M0)    (lt)f0.0   r6.0<1>:f     (abs)r70.0<1;1,0>:f  448.0:f            {Compacted,I@1}
        or (1|M0)                r1.4<1>:d     r2.3<0;1,0>:d     r1.2<0;1,0>:d   
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        rnde (8|M0)              acc0.0<1>:f   acc2.0<1;1,0>:f                  {I@1}
        shr (8|M0)               r16.0<1>:ud   r6.0<1;1,0>:ud    0x17:uw              {F@2}
        add3 (1|M0)              r7.3<1>:d     r7.0<0;0>:d       r47.7<0;0>:d      r1.4<0>:d       
        mul (8|M0)               acc0.0<1>:f   acc0.0<1;1,0>:f   r8.0<1;1,0>:f    {Compacted}
        sel (8|M0)    (ge)f0.0   r1.6<2>:ub    r16.0<4;1,0>:ub   0x79:uw              {I@2}
        mov (8|M0)               r10.0<2>:ud   r7.2<0;1,0>:ud                   {$3.src}
        mov (8|M0)               r9.0<1>:f     (abs)acc0.0<1;1,0>:f             {Compacted}
        mov (8|M0)               r10.1<2>:ud   r7.3<0;1,0>:ud                   {I@3}
        mov (8|M0)               r17.0<1>:d    r1.6<2;1,0>:ub                   {I@3}
(f1.0)  or (8|M0)                r9.0<1>:d     r9.0<1;1,0>:d     -2147483648:d               {F@1}
        addc (8|M0)              r5.0<1>:ud    r10.0<2;1,0>:ud   r82.0<2;1,0>:ud  {AccWrEn,Compacted,I@3}
        shl (8|M0)               r17.0<1>:d    r17.0<1;1,0>:d    23:w               {Compacted,I@3}
        mov (8|M0)               r4.8<1>:hf    r9.0<1;1,0>:f                    {I@3}
        mov (8|M0)               r8.0<1>:ud    acc0.0<1;1,0>:ud                 {Compacted}
        mov (8|M0)               r9.0<1>:d     r82.1<2;1,0>:d                   {F@1}
        add (8|M0)               r18.0<1>:d    r17.0<1;1,0>:d    -25165824:d               {I@3}
        addc (1|M0)              r7.0<1>:ud    r7.2<0;1,0>:ud    0x10:ud              {AccWrEn}
        add (8|M0)               r17.0<1>:d    -r17.0<1;1,0>:d   -2139095040:d              
        add3 (8|M0)              r14.0<1>:d    r8.0<1;0>:d       r10.1<4;2>:d      r9.0<1>:d        {I@4}
        mul (8|M0)               acc2.0<1>:f   r6.0<1;1,0>:f     r17.0<1;1,0>:f   {Compacted,I@2}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r1.2<1>:d     r7.0<0;1,0>:d                   
        rnde (8|M0)              acc0.0<1>:f   acc2.0<1;1,0>:f                  {I@2}
        add3 (1|M0)              r1.3<1>:d     r8.0<0;0>:d       r7.3<0;0>:d       0:w              
        mov (8|M0)               r12.0<2>:d    r5.0<1;1,0>:d                   
        mov (8|M0)               r15.0<1>:d    r4.8<1;1,0>:uw                  
        mov (8|M0)               r10.0<2>:ud   r1.2<0;1,0>:ud                   {I@4}
        mov (8|M0)               r12.1<2>:d    r14.0<1;1,0>:d                  
        mul (8|M0)               acc0.0<1>:f   acc0.0<1;1,0>:f   r18.0<1;1,0>:f   {Compacted}
        mov (8|M0)               r10.1<2>:ud   r1.3<0;1,0>:ud                   {I@5}
        send.ugm (8|M0)          null     r12     r15:1   0x0            0x04000B84           {A@2,$4} // wr:2+1, rd:0; store.ugm.d16u32.a64
        mov (8|M0)               r5.0<1>:f     (abs)acc0.0<1;1,0>:f             {Compacted}
        sync.nop                             null                             {Compacted,$4.src}
        addc (8|M0)              r12.0<1>:ud   r10.0<2;1,0>:ud   r82.0<2;1,0>:ud  {AccWrEn,Compacted,A@1}
(f0.1)  or (8|M0)                r5.0<1>:d     r5.0<1;1,0>:d     -2147483648:d              
        mov (8|M0)               r6.0<1>:ud    acc0.0<1;1,0>:ud                 {Compacted}
        mov (8|M0)               r4.8<1>:hf    r5.0<1;1,0>:f                    {I@2}
        add3 (8|M0)              r15.0<1>:d    r6.0<1;0>:d       r10.1<4;2>:d      r9.0<1>:d        {I@1}
        mov (8|M0)               r13.0<2>:d    r12.0<1;1,0>:d                  
        mov (8|M0)               r5.0<1>:d     r4.8<1;1,0>:uw                   {F@1}
        mov (8|M0)               r13.1<2>:d    r15.0<1;1,0>:d                   {I@3}
        send.ugm (8|M0)          null     r13     r5:1    0x0            0x04000B84           {A@1,$5} // wr:2+1, rd:0; store.ugm.d16u32.a64
L15024:
        join (16|M0)                         L15040                                
L15040:
        or (1|M0)                r1.2<1>:ud    r46.0<0;1,0>:ud   0xD:uw             
        cmp (1|M0)    (lt)f0.0   null<1>:ud    r1.2<0;1,0>:ud    r4.2<0;1,0>:ud   {I@1}
(W)     and (1|M0)               f0.0<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
(~f0.0.any16h) goto (16|M0)                  L15928                  L15928                
L15104:
        sync.nop                             null                             {Compacted,$5.src}
        sel (8|M0)    (lt)f0.0   r5.0<1>:f     (abs)r62.0<1;1,0>:f  448.0:f            {Compacted,$2.src}
        shl (1|M0)               r2.3<1>:d     r85.1<0;1,0>:d    1:w              
        shr (8|M0)               r6.0<1>:ud    r5.0<1;1,0>:ud    0x17:uw              {F@1}
        cmp (8|M0)    (lt)f1.1   null<1>:f     r62.0<1;1,0>:f    0.0:f              
        sel (8|M0)    (ge)f0.0   r1.6<2>:ub    r6.0<4;1,0>:ub    0x79:uw              {I@1}
        cmp (8|M0)    (lt)f1.0   null<1>:f     r54.0<1;1,0>:f    0.0:f              
        mov (8|M0)               r7.0<1>:d     r1.6<2;1,0>:ub                   {I@1}
        shl (1|M0)               r1.3<1>:d     r85.0<0;1,0>:d    1:w               {Compacted}
        shl (8|M0)               r7.0<1>:d     r7.0<1;1,0>:d     23:w               {Compacted,I@2}
        addc (1|M0)              r6.0<1>:ud    r47.6<0;1,0>:ud   r1.3<0;1,0>:ud   {AccWrEn,I@2}
        add (8|M0)               r8.0<1>:d     r7.0<1;1,0>:d     -25165824:d               {I@2}
        add (8|M0)               r7.0<1>:d     -r7.0<1;1,0>:d    -2139095040:d              
        shr (1|M0)               r1.2<1>:ud    r85.0<0;1,0>:ud   0x1F:uw             
        mul (8|M0)               acc2.0<1>:f   r5.0<1;1,0>:f     r7.0<1;1,0>:f    {Compacted,I@2}
        mov (1|M0)               r7.2<1>:d     r6.0<0;1,0>:d                    {F@1}
        sel (8|M0)    (lt)f0.0   r6.0<1>:f     (abs)r54.0<1;1,0>:f  448.0:f            {Compacted,I@1}
        or (1|M0)                r1.4<1>:d     r2.3<0;1,0>:d     r1.2<0;1,0>:d   
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        rnde (8|M0)              acc0.0<1>:f   acc2.0<1;1,0>:f                  {I@1}
        shr (8|M0)               r16.0<1>:ud   r6.0<1;1,0>:ud    0x17:uw              {F@2}
        add3 (1|M0)              r7.3<1>:d     r7.0<0;0>:d       r47.7<0;0>:d      r1.4<0>:d       
        mul (8|M0)               acc0.0<1>:f   acc0.0<1;1,0>:f   r8.0<1;1,0>:f    {Compacted}
        sel (8|M0)    (ge)f0.0   r1.6<2>:ub    r16.0<4;1,0>:ub   0x79:uw              {I@2}
        mov (8|M0)               r10.0<2>:ud   r7.2<0;1,0>:ud                   {$3.src}
        mov (8|M0)               r9.0<1>:f     (abs)acc0.0<1;1,0>:f             {Compacted}
        mov (8|M0)               r10.1<2>:ud   r7.3<0;1,0>:ud                   {I@3}
        mov (8|M0)               r17.0<1>:d    r1.6<2;1,0>:ub                   {I@3}
(f1.1)  or (8|M0)                r9.0<1>:d     r9.0<1;1,0>:d     -2147483648:d               {F@1}
        addc (8|M0)              r5.0<1>:ud    r10.0<2;1,0>:ud   r82.0<2;1,0>:ud  {AccWrEn,Compacted,I@3}
        shl (8|M0)               r17.0<1>:d    r17.0<1;1,0>:d    23:w               {Compacted,I@3}
        mov (8|M0)               r4.8<1>:hf    r9.0<1;1,0>:f                    {I@3}
        mov (8|M0)               r8.0<1>:ud    acc0.0<1;1,0>:ud                 {Compacted}
        mov (8|M0)               r9.0<1>:d     r82.1<2;1,0>:d                   {F@1}
        add (8|M0)               r18.0<1>:d    r17.0<1;1,0>:d    -25165824:d               {I@3}
        addc (1|M0)              r7.0<1>:ud    r7.2<0;1,0>:ud    0x10:ud              {AccWrEn}
        add (8|M0)               r17.0<1>:d    -r17.0<1;1,0>:d   -2139095040:d              
        add3 (8|M0)              r14.0<1>:d    r8.0<1;0>:d       r10.1<4;2>:d      r9.0<1>:d        {I@4}
        mul (8|M0)               acc2.0<1>:f   r6.0<1;1,0>:f     r17.0<1;1,0>:f   {Compacted,I@2}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r1.2<1>:d     r7.0<0;1,0>:d                   
        rnde (8|M0)              acc0.0<1>:f   acc2.0<1;1,0>:f                  {I@2}
        add3 (1|M0)              r1.3<1>:d     r8.0<0;0>:d       r7.3<0;0>:d       0:w              
        mov (8|M0)               r12.0<2>:d    r5.0<1;1,0>:d                   
        mov (8|M0)               r15.0<1>:d    r4.8<1;1,0>:uw                  
        mov (8|M0)               r10.0<2>:ud   r1.2<0;1,0>:ud                   {I@4}
        mov (8|M0)               r12.1<2>:d    r14.0<1;1,0>:d                  
        mul (8|M0)               acc0.0<1>:f   acc0.0<1;1,0>:f   r18.0<1;1,0>:f   {Compacted}
        mov (8|M0)               r10.1<2>:ud   r1.3<0;1,0>:ud                   {I@5}
        send.ugm (8|M0)          null     r12     r15:1   0x0            0x04000B84           {A@2,$6} // wr:2+1, rd:0; store.ugm.d16u32.a64
        mov (8|M0)               r5.0<1>:f     (abs)acc0.0<1;1,0>:f             {Compacted}
        sync.nop                             null                             {Compacted,$6.src}
        addc (8|M0)              r12.0<1>:ud   r10.0<2;1,0>:ud   r82.0<2;1,0>:ud  {AccWrEn,Compacted,A@1}
(f1.0)  or (8|M0)                r5.0<1>:d     r5.0<1;1,0>:d     -2147483648:d              
        mov (8|M0)               r6.0<1>:ud    acc0.0<1;1,0>:ud                 {Compacted}
        mov (8|M0)               r4.8<1>:hf    r5.0<1;1,0>:f                    {I@2}
        add3 (8|M0)              r15.0<1>:d    r6.0<1;0>:d       r10.1<4;2>:d      r9.0<1>:d        {I@1}
        mov (8|M0)               r13.0<2>:d    r12.0<1;1,0>:d                  
        mov (8|M0)               r5.0<1>:d     r4.8<1;1,0>:uw                   {F@1}
        mov (8|M0)               r13.1<2>:d    r15.0<1;1,0>:d                   {I@3}
        send.ugm (8|M0)          null     r13     r5:1    0x0            0x04000B84           {A@1,$7} // wr:2+1, rd:0; store.ugm.d16u32.a64
L15928:
        join (16|M0)                         L15944                                
L15944:
        mul (1|M0)               acc0.0<1>:d   r3.6<0;1,0>:d     0x6:uw             
        mach (1|M0)              r6.0<1>:d     r3.6<0;1,0>:d     6:d               {AccWrEn}
        or (1|M0)                r2.3<1>:ud    r46.0<0;1,0>:ud   0x6:uw             
        sync.allrd                           ($5,$7)                
        mov (1|M0)               r5.0<1>:d     acc0.0<0;1,0>:d                  {$2.src}
        mov (1|M0)               r85.3<1>:d    r6.0<0;1,0>:d                    {I@3}
        mov (1|M0)               r85.2<1>:d    r5.0<0;1,0>:d                    {I@2}
        shl (1|M0)               r1.2<1>:d     r85.3<0;1,0>:d    2:w               {I@2}
        shl (1|M0)               r1.4<1>:d     r85.2<0;1,0>:d    2:w               {I@2}
        shr (1|M0)               r1.3<1>:ud    r85.2<0;1,0>:ud   0x1E:uw             
        addc (1|M0)              r7.0<1>:ud    r81.0<0;1,0>:ud   r1.4<0;1,0>:ud   {AccWrEn,I@2}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        mov (1|M0)               r9.0<1>:f     r7.0<0;1,0>:f                    {Compacted,I@2}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        sync.nop                             null                             {Compacted,$3.src}
        addc (1|M0)              r10.0<1>:ud   r9.0<0;1,0>:ud    0x20:ud              {AccWrEn,F@1}
        add3 (1|M0)              r9.1<1>:d     r8.0<0;0>:d       r81.1<0;0>:d      r1.5<0>:d        {I@2}
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mul (1|M0)               acc0.0<1>:d   r3.6<0;1,0>:d     0xE:uw             
        mach (1|M0)              r13.0<1>:d    r3.6<0;1,0>:d     14:d               {AccWrEn}
        mov (1|M0)               r5.0<1>:f     r10.0<0;1,0>:f                   {Compacted,I@5}
        mov (1|M0)               r12.0<1>:d    acc0.0<0;1,0>:d                 
        add3 (1|M0)              r5.1<1>:d     r11.0<0;0>:d      r9.1<0;0>:d       0:w               {I@4}
        mov (1|M0)               r85.4<1>:d    r12.0<0;1,0>:d                   {I@2}
        mov (1|M0)               r85.5<1>:d    r13.0<0;1,0>:d                  
        shl (1|M0)               r1.4<1>:d     r85.4<0;1,0>:d    2:w               {I@2}
        send.ugm (1|M0)          null     r9      r79:1   0x0            0x0200C584           {$8} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        addc (1|M0)              r6.0<1>:ud    r81.0<0;1,0>:ud   r1.4<0;1,0>:ud   {AccWrEn,I@1}
        sync.nop                             null                             {Compacted,F@1}
        send.ugm (1|M0)          null     r5      r71:1   0x0            0x0200C584           {$9} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        cmp (1|M0)    (lt)f0.1   null<1>:ud    r2.3<0;1,0>:ud    r4.2<0;1,0>:ud  
        shr (1|M0)               r1.3<1>:ud    r85.4<0;1,0>:ud   0x1E:uw             
        shl (1|M0)               r1.2<1>:d     r85.5<0;1,0>:d    2:w              
        sync.nop                             null                             {Compacted,$9.src}
        mov (1|M0)               r5.0<1>:f     r6.0<0;1,0>:f                    {Compacted,I@4}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        addc (1|M0)              r8.0<1>:ud    r5.0<0;1,0>:ud    0x20:ud              {AccWrEn,F@1}
(W)     and (1|M0)               f1.1<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
        add3 (1|M0)              r5.1<1>:d     r7.0<0;0>:d       r81.1<0;0>:d      r1.5<0>:d        {I@3}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$8.src}
        mov (1|M0)               r10.0<1>:f    r8.0<0;1,0>:f                    {Compacted,I@4}
        add3 (1|M0)              r10.1<1>:d    r9.0<0;0>:d       r5.1<0;0>:d       0:w               {I@1}
        send.ugm (1|M0)          null     r5      r63:1   0x0            0x0200C584           {$10} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r10     r55:1   0x0            0x0200C584           {A@1,$11} // wr:1+1, rd:0; store.ugm.d32x8t.a64
(~f1.1.any16h) goto (16|M0)                  L17400                  L17400                
L16592:
        sel (8|M0)    (lt)f0.0   r5.0<1>:f     (abs)r79.0<1;1,0>:f  448.0:f            {Compacted,$10.src}
        shl (1|M0)               r2.3<1>:d     r85.3<0;1,0>:d    1:w               {Compacted}
        shr (8|M0)               r6.0<1>:ud    r5.0<1;1,0>:ud    0x17:uw              {F@1}
        cmp (8|M0)    (lt)f0.0   null<1>:f     r79.0<1;1,0>:f    0.0:f               {Compacted}
        sel (8|M0)    (ge)f0.0   r1.6<2>:ub    r6.0<4;1,0>:ub    0x79:uw              {I@1}
        cmp (8|M0)    (lt)f1.1   null<1>:f     r71.0<1;1,0>:f    0.0:f              
        mov (8|M0)               r7.0<1>:d     r1.6<2;1,0>:ub                   {I@1}
        shl (1|M0)               r1.3<1>:d     r85.2<0;1,0>:d    1:w              
        shl (8|M0)               r7.0<1>:d     r7.0<1;1,0>:d     23:w               {Compacted,I@2}
        addc (1|M0)              r6.0<1>:ud    r47.6<0;1,0>:ud   r1.3<0;1,0>:ud   {AccWrEn,I@2}
        add (8|M0)               r8.0<1>:d     r7.0<1;1,0>:d     -25165824:d               {I@2}
        add (8|M0)               r7.0<1>:d     -r7.0<1;1,0>:d    -2139095040:d              
        shr (1|M0)               r1.2<1>:ud    r85.2<0;1,0>:ud   0x1F:uw             
        mul (8|M0)               acc2.0<1>:f   r5.0<1;1,0>:f     r7.0<1;1,0>:f    {Compacted,I@2}
        mov (1|M0)               r7.2<1>:d     r6.0<0;1,0>:d                    {F@1}
        sel (8|M0)    (lt)f0.0   r6.0<1>:f     (abs)r71.0<1;1,0>:f  448.0:f            {Compacted,I@1}
        or (1|M0)                r1.4<1>:d     r2.3<0;1,0>:d     r1.2<0;1,0>:d   
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        rnde (8|M0)              acc0.0<1>:f   acc2.0<1;1,0>:f                  {I@1}
        shr (8|M0)               r16.0<1>:ud   r6.0<1;1,0>:ud    0x17:uw              {F@2}
        add3 (1|M0)              r7.3<1>:d     r7.0<0;0>:d       r47.7<0;0>:d      r1.4<0>:d       
        mul (8|M0)               acc0.0<1>:f   acc0.0<1;1,0>:f   r8.0<1;1,0>:f    {Compacted}
        sel (8|M0)    (ge)f0.0   r1.6<2>:ub    r16.0<4;1,0>:ub   0x79:uw              {I@2}
        mov (8|M0)               r10.0<2>:ud   r7.2<0;1,0>:ud                   {$11.src}
        mov (8|M0)               r9.0<1>:f     (abs)acc0.0<1;1,0>:f             {Compacted}
        mov (8|M0)               r10.1<2>:ud   r7.3<0;1,0>:ud                   {I@3}
        mov (8|M0)               r17.0<1>:d    r1.6<2;1,0>:ub                   {I@3}
(f0.0)  or (8|M0)                r9.0<1>:d     r9.0<1;1,0>:d     -2147483648:d               {F@1}
        addc (8|M0)              r5.0<1>:ud    r10.0<2;1,0>:ud   r82.0<2;1,0>:ud  {AccWrEn,Compacted,I@3}
        shl (8|M0)               r17.0<1>:d    r17.0<1;1,0>:d    23:w               {Compacted,I@3}
        mov (8|M0)               r4.8<1>:hf    r9.0<1;1,0>:f                    {I@3}
        mov (8|M0)               r8.0<1>:ud    acc0.0<1;1,0>:ud                 {Compacted}
        mov (8|M0)               r9.0<1>:d     r82.1<2;1,0>:d                   {F@1}
        add (8|M0)               r18.0<1>:d    r17.0<1;1,0>:d    -25165824:d               {I@3}
        addc (1|M0)              r7.0<1>:ud    r7.2<0;1,0>:ud    0x10:ud              {AccWrEn}
        add (8|M0)               r17.0<1>:d    -r17.0<1;1,0>:d   -2139095040:d              
        add3 (8|M0)              r14.0<1>:d    r8.0<1;0>:d       r10.1<4;2>:d      r9.0<1>:d        {I@4}
        mul (8|M0)               acc2.0<1>:f   r6.0<1;1,0>:f     r17.0<1;1,0>:f   {Compacted,I@2}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r1.2<1>:d     r7.0<0;1,0>:d                   
        rnde (8|M0)              acc0.0<1>:f   acc2.0<1;1,0>:f                  {I@2}
        add3 (1|M0)              r1.3<1>:d     r8.0<0;0>:d       r7.3<0;0>:d       0:w              
        mov (8|M0)               r12.0<2>:d    r5.0<1;1,0>:d                   
        mov (8|M0)               r15.0<1>:d    r4.8<1;1,0>:uw                  
        mov (8|M0)               r10.0<2>:ud   r1.2<0;1,0>:ud                   {I@4}
        mov (8|M0)               r12.1<2>:d    r14.0<1;1,0>:d                  
        mul (8|M0)               acc0.0<1>:f   acc0.0<1;1,0>:f   r18.0<1;1,0>:f   {Compacted}
        mov (8|M0)               r10.1<2>:ud   r1.3<0;1,0>:ud                   {I@5}
        send.ugm (8|M0)          null     r12     r15:1   0x0            0x04000B84           {A@2,$12} // wr:2+1, rd:0; store.ugm.d16u32.a64
        mov (8|M0)               r5.0<1>:f     (abs)acc0.0<1;1,0>:f             {Compacted}
        sync.nop                             null                             {Compacted,$12.src}
        addc (8|M0)              r12.0<1>:ud   r10.0<2;1,0>:ud   r82.0<2;1,0>:ud  {AccWrEn,Compacted,A@1}
(f1.1)  or (8|M0)                r5.0<1>:d     r5.0<1;1,0>:d     -2147483648:d              
        mov (8|M0)               r6.0<1>:ud    acc0.0<1;1,0>:ud                 {Compacted}
        mov (8|M0)               r4.8<1>:hf    r5.0<1;1,0>:f                    {I@2}
        add3 (8|M0)              r15.0<1>:d    r6.0<1;0>:d       r10.1<4;2>:d      r9.0<1>:d        {I@1}
        mov (8|M0)               r13.0<2>:d    r12.0<1;1,0>:d                  
        mov (8|M0)               r5.0<1>:d     r4.8<1;1,0>:uw                   {F@1}
        mov (8|M0)               r13.1<2>:d    r15.0<1;1,0>:d                   {I@3}
        send.ugm (8|M0)          null     r13     r5:1    0x0            0x04000B84           {A@1,$13} // wr:2+1, rd:0; store.ugm.d16u32.a64
L17400:
        join (16|M0)                         L17416                                
L17416:
        or (1|M0)                r1.2<1>:ud    r46.0<0;1,0>:ud   0xE:uw             
        cmp (1|M0)    (lt)f1.0   null<1>:ud    r1.2<0;1,0>:ud    r4.2<0;1,0>:ud   {I@1}
(W)     and (1|M0)               f1.0<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
(~f1.0.any16h) goto (16|M0)                  L18304                  L18304                
L17480:
        sync.nop                             null                             {Compacted,$13.src}
        sel (8|M0)    (lt)f0.0   r5.0<1>:f     (abs)r63.0<1;1,0>:f  448.0:f            {Compacted,$10.src}
        shl (1|M0)               r2.3<1>:d     r85.5<0;1,0>:d    1:w              
        shr (8|M0)               r6.0<1>:ud    r5.0<1;1,0>:ud    0x17:uw              {F@1}
        cmp (8|M0)    (lt)f0.1   null<1>:f     r63.0<1;1,0>:f    0.0:f              
        sel (8|M0)    (ge)f0.0   r1.6<2>:ub    r6.0<4;1,0>:ub    0x79:uw              {I@1}
        cmp (8|M0)    (lt)f0.0   null<1>:f     r55.0<1;1,0>:f    0.0:f               {Compacted}
        mov (8|M0)               r7.0<1>:d     r1.6<2;1,0>:ub                   {I@1}
        shl (1|M0)               r1.3<1>:d     r85.4<0;1,0>:d    1:w              
        shl (8|M0)               r7.0<1>:d     r7.0<1;1,0>:d     23:w               {Compacted,I@2}
        addc (1|M0)              r6.0<1>:ud    r47.6<0;1,0>:ud   r1.3<0;1,0>:ud   {AccWrEn,I@2}
        add (8|M0)               r8.0<1>:d     r7.0<1;1,0>:d     -25165824:d               {I@2}
        add (8|M0)               r7.0<1>:d     -r7.0<1;1,0>:d    -2139095040:d              
        shr (1|M0)               r1.2<1>:ud    r85.4<0;1,0>:ud   0x1F:uw             
        mul (8|M0)               acc2.0<1>:f   r5.0<1;1,0>:f     r7.0<1;1,0>:f    {Compacted,I@2}
        mov (1|M0)               r7.2<1>:d     r6.0<0;1,0>:d                    {F@1}
        sel (8|M0)    (lt)f0.0   r6.0<1>:f     (abs)r55.0<1;1,0>:f  448.0:f            {Compacted,I@1}
        or (1|M0)                r1.4<1>:d     r2.3<0;1,0>:d     r1.2<0;1,0>:d   
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        rnde (8|M0)              acc0.0<1>:f   acc2.0<1;1,0>:f                  {I@1}
        shr (8|M0)               r16.0<1>:ud   r6.0<1;1,0>:ud    0x17:uw              {F@2}
        add3 (1|M0)              r7.3<1>:d     r7.0<0;0>:d       r47.7<0;0>:d      r1.4<0>:d       
        mul (8|M0)               acc0.0<1>:f   acc0.0<1;1,0>:f   r8.0<1;1,0>:f    {Compacted}
        sel (8|M0)    (ge)f0.0   r1.6<2>:ub    r16.0<4;1,0>:ub   0x79:uw              {I@2}
        mov (8|M0)               r10.0<2>:ud   r7.2<0;1,0>:ud                   {$11.src}
        mov (8|M0)               r9.0<1>:f     (abs)acc0.0<1;1,0>:f             {Compacted}
        mov (8|M0)               r10.1<2>:ud   r7.3<0;1,0>:ud                   {I@3}
        mov (8|M0)               r17.0<1>:d    r1.6<2;1,0>:ub                   {I@3}
(f0.1)  or (8|M0)                r9.0<1>:d     r9.0<1;1,0>:d     -2147483648:d               {F@1}
        addc (8|M0)              r5.0<1>:ud    r10.0<2;1,0>:ud   r82.0<2;1,0>:ud  {AccWrEn,Compacted,I@3}
        shl (8|M0)               r17.0<1>:d    r17.0<1;1,0>:d    23:w               {Compacted,I@3}
        mov (8|M0)               r4.8<1>:hf    r9.0<1;1,0>:f                    {I@3}
        mov (8|M0)               r8.0<1>:ud    acc0.0<1;1,0>:ud                 {Compacted}
        mov (8|M0)               r9.0<1>:d     r82.1<2;1,0>:d                   {F@1}
        add (8|M0)               r18.0<1>:d    r17.0<1;1,0>:d    -25165824:d               {I@3}
        addc (1|M0)              r7.0<1>:ud    r7.2<0;1,0>:ud    0x10:ud              {AccWrEn}
        add (8|M0)               r17.0<1>:d    -r17.0<1;1,0>:d   -2139095040:d              
        add3 (8|M0)              r14.0<1>:d    r8.0<1;0>:d       r10.1<4;2>:d      r9.0<1>:d        {I@4}
        mul (8|M0)               acc2.0<1>:f   r6.0<1;1,0>:f     r17.0<1;1,0>:f   {Compacted,I@2}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r1.2<1>:d     r7.0<0;1,0>:d                   
        rnde (8|M0)              acc0.0<1>:f   acc2.0<1;1,0>:f                  {I@2}
        add3 (1|M0)              r1.3<1>:d     r8.0<0;0>:d       r7.3<0;0>:d       0:w              
        mov (8|M0)               r12.0<2>:d    r5.0<1;1,0>:d                   
        mov (8|M0)               r15.0<1>:d    r4.8<1;1,0>:uw                  
        mov (8|M0)               r10.0<2>:ud   r1.2<0;1,0>:ud                   {I@4}
        mov (8|M0)               r12.1<2>:d    r14.0<1;1,0>:d                  
        mul (8|M0)               acc0.0<1>:f   acc0.0<1;1,0>:f   r18.0<1;1,0>:f   {Compacted}
        mov (8|M0)               r10.1<2>:ud   r1.3<0;1,0>:ud                   {I@5}
        send.ugm (8|M0)          null     r12     r15:1   0x0            0x04000B84           {A@2,$14} // wr:2+1, rd:0; store.ugm.d16u32.a64
        mov (8|M0)               r5.0<1>:f     (abs)acc0.0<1;1,0>:f             {Compacted}
        sync.nop                             null                             {Compacted,$14.src}
        addc (8|M0)              r12.0<1>:ud   r10.0<2;1,0>:ud   r82.0<2;1,0>:ud  {AccWrEn,Compacted,A@1}
(f0.0)  or (8|M0)                r5.0<1>:d     r5.0<1;1,0>:d     -2147483648:d              
        mov (8|M0)               r6.0<1>:ud    acc0.0<1;1,0>:ud                 {Compacted}
        mov (8|M0)               r4.8<1>:hf    r5.0<1;1,0>:f                    {I@2}
        add3 (8|M0)              r15.0<1>:d    r6.0<1;0>:d       r10.1<4;2>:d      r9.0<1>:d        {I@1}
        mov (8|M0)               r13.0<2>:d    r12.0<1;1,0>:d                  
        mov (8|M0)               r5.0<1>:d     r4.8<1;1,0>:uw                   {F@1}
        mov (8|M0)               r13.1<2>:d    r15.0<1;1,0>:d                   {I@3}
        send.ugm (8|M0)          null     r13     r5:1    0x0            0x04000B84           {A@1,$15} // wr:2+1, rd:0; store.ugm.d16u32.a64
L18304:
        join (16|M0)                         L18320                                
L18320:
        mul (1|M0)               acc0.0<1>:d   r3.6<0;1,0>:d     0x7:uw             
        mach (1|M0)              r6.0<1>:d     r3.6<0;1,0>:d     7:d               {AccWrEn}
        or (1|M0)                r2.3<1>:ud    r46.0<0;1,0>:ud   0x7:uw             
        sync.allrd                           ($13,$15)                
        mov (1|M0)               r5.0<1>:d     acc0.0<0;1,0>:d                  {$10.src}
        mov (1|M0)               r85.7<1>:d    r6.0<0;1,0>:d                    {I@3}
        mov (1|M0)               r85.6<1>:d    r5.0<0;1,0>:d                    {I@2}
        shl (1|M0)               r1.2<1>:d     r85.7<0;1,0>:d    2:w               {I@2}
        shl (1|M0)               r1.4<1>:d     r85.6<0;1,0>:d    2:w               {I@2}
        shr (1|M0)               r1.3<1>:ud    r85.6<0;1,0>:ud   0x1E:uw             
        addc (1|M0)              r7.0<1>:ud    r81.0<0;1,0>:ud   r1.4<0;1,0>:ud   {AccWrEn,I@2}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        mov (1|M0)               r9.0<1>:f     r7.0<0;1,0>:f                    {Compacted,I@2}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        sync.nop                             null                             {Compacted,$11.src}
        addc (1|M0)              r10.0<1>:ud   r9.0<0;1,0>:ud    0x20:ud              {AccWrEn,F@1}
        add3 (1|M0)              r9.1<1>:d     r8.0<0;0>:d       r81.1<0;0>:d      r1.5<0>:d        {I@2}
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mul (1|M0)               acc0.0<1>:d   r3.6<0;1,0>:d     0xF:uw             
        mach (1|M0)              r13.0<1>:d    r3.6<0;1,0>:d     15:d               {AccWrEn}
        mov (1|M0)               r5.0<1>:f     r10.0<0;1,0>:f                   {Compacted,I@5}
        mov (1|M0)               r12.0<1>:d    acc0.0<0;1,0>:d                 
        add3 (1|M0)              r5.1<1>:d     r11.0<0;0>:d      r9.1<0;0>:d       0:w               {I@4}
        mov (1|M0)               r86.0<1>:f    r12.0<0;1,0>:f                   {Compacted,I@2}
        mov (1|M0)               r86.1<1>:d    r13.0<0;1,0>:d                  
        shl (1|M0)               r1.4<1>:d     r86.0<0;1,0>:d    2:w               {Compacted,F@1}
        send.ugm (1|M0)          null     r9      r80:1   0x0            0x0200C584           {$0} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        addc (1|M0)              r6.0<1>:ud    r81.0<0;1,0>:ud   r1.4<0;1,0>:ud   {AccWrEn,I@1}
        send.ugm (1|M0)          null     r5      r72:1   0x0            0x0200C584           {$1} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        cmp (1|M0)    (lt)f1.1   null<1>:ud    r2.3<0;1,0>:ud    r4.2<0;1,0>:ud  
        shr (1|M0)               r1.3<1>:ud    r86.0<0;1,0>:ud   0x1E:uw             
        shl (1|M0)               r1.2<1>:d     r86.1<0;1,0>:d    2:w              
        sync.nop                             null                             {Compacted,$1.src}
        mov (1|M0)               r5.0<1>:f     r6.0<0;1,0>:f                    {Compacted,I@4}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        addc (1|M0)              r8.0<1>:ud    r5.0<0;1,0>:ud    0x20:ud              {AccWrEn,F@1}
(W)     and (1|M0)               f0.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
        add3 (1|M0)              r5.1<1>:d     r7.0<0;0>:d       r81.1<0;0>:d      r1.5<0>:d        {I@3}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$0.src}
        mov (1|M0)               r10.0<1>:f    r8.0<0;1,0>:f                    {Compacted,I@4}
        add3 (1|M0)              r10.1<1>:d    r9.0<0;0>:d       r5.1<0;0>:d       0:w               {I@1}
        send.ugm (1|M0)          null     r5      r64:1   0x0            0x0200C584           {$2} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r10     r56:1   0x0            0x0200C584           {A@1,$3} // wr:1+1, rd:0; store.ugm.d32x8t.a64
(~f0.1.any16h) goto (16|M0)                  L19768                  L19768                
L18944:
        sel (8|M0)    (lt)f0.0   r5.0<1>:f     (abs)r80.0<1;1,0>:f  448.0:f            {Compacted,$2.src}
        shl (1|M0)               r2.3<1>:d     r85.7<0;1,0>:d    1:w              
        shr (8|M0)               r6.0<1>:ud    r5.0<1;1,0>:ud    0x17:uw              {F@1}
        cmp (8|M0)    (lt)f1.0   null<1>:f     r80.0<1;1,0>:f    0.0:f              
        sel (8|M0)    (ge)f0.0   r1.6<2>:ub    r6.0<4;1,0>:ub    0x79:uw              {I@1}
        cmp (8|M0)    (lt)f0.1   null<1>:f     r72.0<1;1,0>:f    0.0:f              
        mov (8|M0)               r7.0<1>:d     r1.6<2;1,0>:ub                   {I@1}
        shl (1|M0)               r1.3<1>:d     r85.6<0;1,0>:d    1:w              
        shl (8|M0)               r7.0<1>:d     r7.0<1;1,0>:d     23:w               {Compacted,I@2}
        addc (1|M0)              r6.0<1>:ud    r47.6<0;1,0>:ud   r1.3<0;1,0>:ud   {AccWrEn,I@2}
        add (8|M0)               r8.0<1>:d     r7.0<1;1,0>:d     -25165824:d               {I@2}
        add (8|M0)               r7.0<1>:d     -r7.0<1;1,0>:d    -2139095040:d              
        shr (1|M0)               r1.2<1>:ud    r85.6<0;1,0>:ud   0x1F:uw             
        mul (8|M0)               acc2.0<1>:f   r5.0<1;1,0>:f     r7.0<1;1,0>:f    {Compacted,I@2}
        mov (1|M0)               r7.2<1>:d     r6.0<0;1,0>:d                    {F@1}
        sel (8|M0)    (lt)f0.0   r6.0<1>:f     (abs)r72.0<1;1,0>:f  448.0:f            {Compacted,I@1}
        or (1|M0)                r1.4<1>:d     r2.3<0;1,0>:d     r1.2<0;1,0>:d   
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        rnde (8|M0)              acc0.0<1>:f   acc2.0<1;1,0>:f                  {I@1}
        shr (8|M0)               r16.0<1>:ud   r6.0<1;1,0>:ud    0x17:uw              {F@2}
        add3 (1|M0)              r7.3<1>:d     r7.0<0;0>:d       r47.7<0;0>:d      r1.4<0>:d       
        mul (8|M0)               acc0.0<1>:f   acc0.0<1;1,0>:f   r8.0<1;1,0>:f    {Compacted}
        sel (8|M0)    (ge)f0.0   r1.6<2>:ub    r16.0<4;1,0>:ub   0x79:uw              {I@2}
        mov (8|M0)               r10.0<2>:ud   r7.2<0;1,0>:ud                   {$3.src}
        mov (8|M0)               r9.0<1>:f     (abs)acc0.0<1;1,0>:f             {Compacted}
        mov (8|M0)               r10.1<2>:ud   r7.3<0;1,0>:ud                   {I@3}
        mov (8|M0)               r17.0<1>:d    r1.6<2;1,0>:ub                   {I@3}
(f1.0)  or (8|M0)                r9.0<1>:d     r9.0<1;1,0>:d     -2147483648:d               {F@1}
        addc (8|M0)              r5.0<1>:ud    r10.0<2;1,0>:ud   r82.0<2;1,0>:ud  {AccWrEn,Compacted,I@3}
        shl (8|M0)               r17.0<1>:d    r17.0<1;1,0>:d    23:w               {Compacted,I@3}
        mov (8|M0)               r4.8<1>:hf    r9.0<1;1,0>:f                    {I@3}
        mov (8|M0)               r8.0<1>:ud    acc0.0<1;1,0>:ud                 {Compacted}
        mov (8|M0)               r9.0<1>:d     r82.1<2;1,0>:d                   {F@1}
        add (8|M0)               r18.0<1>:d    r17.0<1;1,0>:d    -25165824:d               {I@3}
        addc (1|M0)              r7.0<1>:ud    r7.2<0;1,0>:ud    0x10:ud              {AccWrEn}
        add (8|M0)               r17.0<1>:d    -r17.0<1;1,0>:d   -2139095040:d              
        add3 (8|M0)              r14.0<1>:d    r8.0<1;0>:d       r10.1<4;2>:d      r9.0<1>:d        {I@4}
        mul (8|M0)               acc2.0<1>:f   r6.0<1;1,0>:f     r17.0<1;1,0>:f   {Compacted,I@2}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r1.2<1>:d     r7.0<0;1,0>:d                   
        rnde (8|M0)              acc0.0<1>:f   acc2.0<1;1,0>:f                  {I@2}
        add3 (1|M0)              r1.3<1>:d     r8.0<0;0>:d       r7.3<0;0>:d       0:w              
        mov (8|M0)               r12.0<2>:d    r5.0<1;1,0>:d                   
        mov (8|M0)               r15.0<1>:d    r4.8<1;1,0>:uw                  
        mov (8|M0)               r10.0<2>:ud   r1.2<0;1,0>:ud                   {I@4}
        mov (8|M0)               r12.1<2>:d    r14.0<1;1,0>:d                  
        mul (8|M0)               acc0.0<1>:f   acc0.0<1;1,0>:f   r18.0<1;1,0>:f   {Compacted}
        mov (8|M0)               r10.1<2>:ud   r1.3<0;1,0>:ud                   {I@5}
        send.ugm (8|M0)          null     r12     r15:1   0x0            0x04000B84           {A@2,$4} // wr:2+1, rd:0; store.ugm.d16u32.a64
        mov (8|M0)               r5.0<1>:f     (abs)acc0.0<1;1,0>:f             {Compacted}
        sync.nop                             null                             {Compacted,$4.src}
        addc (8|M0)              r12.0<1>:ud   r10.0<2;1,0>:ud   r82.0<2;1,0>:ud  {AccWrEn,Compacted,A@1}
(f0.1)  or (8|M0)                r5.0<1>:d     r5.0<1;1,0>:d     -2147483648:d              
        mov (8|M0)               r6.0<1>:ud    acc0.0<1;1,0>:ud                 {Compacted}
        mov (8|M0)               r4.8<1>:hf    r5.0<1;1,0>:f                    {I@2}
        add3 (8|M0)              r15.0<1>:d    r6.0<1;0>:d       r10.1<4;2>:d      r9.0<1>:d        {I@1}
        mov (8|M0)               r13.0<2>:d    r12.0<1;1,0>:d                  
        mov (8|M0)               r5.0<1>:d     r4.8<1;1,0>:uw                   {F@1}
        mov (8|M0)               r13.1<2>:d    r15.0<1;1,0>:d                   {I@3}
        send.ugm (8|M0)          null     r13     r5:1    0x0            0x04000B84           {A@1,$5} // wr:2+1, rd:0; store.ugm.d16u32.a64
L19768:
        join (16|M0)                         L19784                                
L19784:
        or (1|M0)                r46.0<1>:ud   r46.0<0;1,0>:ud   0xF:uw             
        cmp (1|M0)    (lt)f0.0   null<1>:ud    r46.0<0;1,0>:ud   r4.2<0;1,0>:ud   {I@1}
(W)     and (1|M0)               f0.0<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
(~f0.0.any16h) goto (16|M0)                  L20672                  L20672                
L19848:
        sync.nop                             null                             {Compacted,$5.src}
        sel (8|M0)    (lt)f0.0   r5.0<1>:f     (abs)r64.0<1;1,0>:f  448.0:f            {Compacted,$2.src}
        shl (1|M0)               r2.3<1>:d     r86.1<0;1,0>:d    1:w              
        shr (8|M0)               r6.0<1>:ud    r5.0<1;1,0>:ud    0x17:uw              {F@1}
        cmp (8|M0)    (lt)f1.1   null<1>:f     r64.0<1;1,0>:f    0.0:f              
        sel (8|M0)    (ge)f0.0   r1.6<2>:ub    r6.0<4;1,0>:ub    0x79:uw              {I@1}
        cmp (8|M0)    (lt)f1.0   null<1>:f     r56.0<1;1,0>:f    0.0:f              
        mov (8|M0)               r7.0<1>:d     r1.6<2;1,0>:ub                   {I@1}
        shl (1|M0)               r1.3<1>:d     r86.0<0;1,0>:d    1:w               {Compacted}
        shl (8|M0)               r7.0<1>:d     r7.0<1;1,0>:d     23:w               {Compacted,I@2}
        addc (1|M0)              r6.0<1>:ud    r47.6<0;1,0>:ud   r1.3<0;1,0>:ud   {AccWrEn,I@2}
        add (8|M0)               r8.0<1>:d     r7.0<1;1,0>:d     -25165824:d               {I@2}
        add (8|M0)               r7.0<1>:d     -r7.0<1;1,0>:d    -2139095040:d              
        shr (1|M0)               r1.2<1>:ud    r86.0<0;1,0>:ud   0x1F:uw             
        mul (8|M0)               acc2.0<1>:f   r5.0<1;1,0>:f     r7.0<1;1,0>:f    {Compacted,I@2}
        mov (1|M0)               r7.2<1>:d     r6.0<0;1,0>:d                    {F@1}
        sel (8|M0)    (lt)f0.0   r6.0<1>:f     (abs)r56.0<1;1,0>:f  448.0:f            {Compacted,I@1}
        or (1|M0)                r1.4<1>:d     r2.3<0;1,0>:d     r1.2<0;1,0>:d   
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        rnde (8|M0)              acc0.0<1>:f   acc2.0<1;1,0>:f                  {I@1}
        shr (8|M0)               r16.0<1>:ud   r6.0<1;1,0>:ud    0x17:uw              {F@2}
        add3 (1|M0)              r7.3<1>:d     r7.0<0;0>:d       r47.7<0;0>:d      r1.4<0>:d       
        mul (8|M0)               acc0.0<1>:f   acc0.0<1;1,0>:f   r8.0<1;1,0>:f    {Compacted}
        sel (8|M0)    (ge)f0.0   r1.6<2>:ub    r16.0<4;1,0>:ub   0x79:uw              {I@2}
        mov (8|M0)               r10.0<2>:ud   r7.2<0;1,0>:ud                   {$3.src}
        mov (8|M0)               r9.0<1>:f     (abs)acc0.0<1;1,0>:f             {Compacted}
        mov (8|M0)               r10.1<2>:ud   r7.3<0;1,0>:ud                   {I@3}
        mov (8|M0)               r17.0<1>:d    r1.6<2;1,0>:ub                   {I@3}
(f1.1)  or (8|M0)                r9.0<1>:d     r9.0<1;1,0>:d     -2147483648:d               {F@1}
        addc (8|M0)              r5.0<1>:ud    r10.0<2;1,0>:ud   r82.0<2;1,0>:ud  {AccWrEn,Compacted,I@3}
        shl (8|M0)               r17.0<1>:d    r17.0<1;1,0>:d    23:w               {Compacted,I@3}
        mov (8|M0)               r4.8<1>:hf    r9.0<1;1,0>:f                    {I@3}
        mov (8|M0)               r8.0<1>:ud    acc0.0<1;1,0>:ud                 {Compacted}
        mov (8|M0)               r9.0<1>:d     r82.1<2;1,0>:d                   {F@1}
        add (8|M0)               r18.0<1>:d    r17.0<1;1,0>:d    -25165824:d               {I@3}
        addc (1|M0)              r7.0<1>:ud    r7.2<0;1,0>:ud    0x10:ud              {AccWrEn}
        add (8|M0)               r17.0<1>:d    -r17.0<1;1,0>:d   -2139095040:d              
        add3 (8|M0)              r14.0<1>:d    r8.0<1;0>:d       r10.1<4;2>:d      r9.0<1>:d        {I@4}
        mul (8|M0)               acc2.0<1>:f   r6.0<1;1,0>:f     r17.0<1;1,0>:f   {Compacted,I@2}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r1.2<1>:d     r7.0<0;1,0>:d                   
        rnde (8|M0)              acc0.0<1>:f   acc2.0<1;1,0>:f                  {I@2}
        add3 (1|M0)              r1.3<1>:d     r8.0<0;0>:d       r7.3<0;0>:d       0:w              
        mov (8|M0)               r12.0<2>:d    r5.0<1;1,0>:d                   
        mov (8|M0)               r15.0<1>:d    r4.8<1;1,0>:uw                  
        mov (8|M0)               r10.0<2>:ud   r1.2<0;1,0>:ud                   {I@4}
        mov (8|M0)               r12.1<2>:d    r14.0<1;1,0>:d                  
        mul (8|M0)               acc0.0<1>:f   acc0.0<1;1,0>:f   r18.0<1;1,0>:f   {Compacted}
        mov (8|M0)               r10.1<2>:ud   r1.3<0;1,0>:ud                   {I@5}
        send.ugm (8|M0)          null     r12     r15:1   0x0            0x04000B84           {A@2,$6} // wr:2+1, rd:0; store.ugm.d16u32.a64
        mov (8|M0)               r5.0<1>:f     (abs)acc0.0<1;1,0>:f             {Compacted}
        sync.nop                             null                             {Compacted,$6.src}
        addc (8|M0)              r12.0<1>:ud   r10.0<2;1,0>:ud   r82.0<2;1,0>:ud  {AccWrEn,Compacted,A@1}
(f1.0)  or (8|M0)                r5.0<1>:d     r5.0<1;1,0>:d     -2147483648:d              
        mov (8|M0)               r6.0<1>:ud    acc0.0<1;1,0>:ud                 {Compacted}
        mov (8|M0)               r4.8<1>:hf    r5.0<1;1,0>:f                    {I@2}
        add3 (8|M0)              r15.0<1>:d    r6.0<1;0>:d       r10.1<4;2>:d      r9.0<1>:d        {I@1}
        mov (8|M0)               r13.0<2>:d    r12.0<1;1,0>:d                  
        mov (8|M0)               r5.0<1>:d     r4.8<1;1,0>:uw                   {F@1}
        mov (8|M0)               r13.1<2>:d    r15.0<1;1,0>:d                   {I@3}
        send.ugm (8|M0)          null     r13     r5:1    0x0            0x04000B84           {A@1,$7} // wr:2+1, rd:0; store.ugm.d16u32.a64
L20672:
        join (16|M0)                         L20688                                
L20688:
(W)     mov (8|M0)               r127.0<1>:f   r0.0<1;1,0>:f                    {Compacted}
        sync.allrd                           ($2,$5,$7)                
(W)     send.ugm (1|M0)          r5       r0      null:0  0x0            0x0210641F           {$8} // wr:1+0, rd:1; fence invalid flush type scoped to tile
(W)     mov (8|M0)               null<1>:ud    r5.0<1;1,0>:ud                   {$8.dst}
(W)     send.gtwy (1|M0)         null     r127    null:0  0x0            0x02000010           {EOT,A@1} // wr:1+0, rd:0; end of thread
L20760:
        mov (1|M0)               r1.2<1>:d     cr0.0<0;1,0>:ud                  {A@1}
        and (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   -1265:w               {A@1}
        or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   1264:w               {A@1}
        mov (1|M0)               r1.3<1>:f     (abs)r86.5<0;1,0>:d              {A@1}
        mov (1|M0)               r4.4<1>:f     0xB4C00000:f                               {Compacted}
        math.inv (1|M0)          r4.3<1>:f     r1.3<0;1,0>:f                    {@2,$9}
        mov (1|M0)               r2.4<1>:f     (abs)r86.4<0;1,0>:d             
        sync.nop                             null                             {Compacted,$9.dst}
        mad (1|M0)               r4.3<1>:f     r4.3<0;0>:f       r4.4<0;0>:f       r4.3<0>:f        {F@2}
        mov (2|M0)               r1.4<1>:d     (abs)r86.4<1;1,0>:d             
        mov (1|M0)               r1.6<1>:ud    r1.3<0;1,0>:f                   
        mov (1|M0)               r2.5<1>:ud    r2.4<0;1,0>:f                    {F@2}
        mul (1|M0)               r5.0<1>:f     r4.3<0;1,0>:f     r2.4<0;1,0>:f    {A@1}
        add (1|M0)               r1.6<1>:ud    r1.5<0;1,0>:ud    -r1.6<0;1,0>:ud  {I@2}
        add (1|M0)               r2.5<1>:ud    r1.4<0;1,0>:ud    -r2.5<0;1,0>:ud  {I@2}
        mov (1|M0)               r6.0<1>:ud    r5.0<0;1,0>:f                    {F@1}
        mov (1|M0)               r2.3<1>:f     r1.6<0;1,0>:ud                   {I@3}
        mov (1|M0)               r3.7<1>:f     r2.5<0;1,0>:ud                   {I@2}
        mov (1|M0)               r6.1<1>:f     r6.0<0;1,0>:ud                   {Compacted,I@1}
        xor (1|M0)               r86.5<1>:d    r86.5<0;1,0>:d    r86.4<0;1,0>:d  
        mad (1|M0)               r2.4<1>:f     r2.4<0;0>:f       r6.1<0;0>:f       -r1.3<0>:f       {F@1}
        mad (1|M0)               r6.1<1>:f     r3.7<0;0>:f       r6.1<0;0>:f       -r2.3<0>:f      
(W)     mov (1|M0)               r5.0<1>:hf    0x1:hf                             
        add (1|M0)               r2.4<1>:f     r2.4<0;1,0>:f     r6.1<0;1,0>:f    {F@2}
        asr (1|M0)               r86.5<1>:d    r86.5<0;1,0>:d    31:w               {I@1}
        mul (1|M0)               r4.3<1>:f     r4.3<0;1,0>:f     r2.4<0;1,0>:f    {F@1}
        mov (1|M0)               r7.0<1>:ud    r4.3<0;1,0>:f                    {F@1}
        add (1|M0)               r6.0<1>:ud    r6.0<0;1,0>:ud    r7.0<0;1,0>:ud   {Compacted,I@1}
(W)     mul (1|M0)               acc0.0<1>:ud  r6.0<0;1,0>:ud    r1.10<0;1,0>:uw  {I@1}
        mach (1|M0)              r8.0<1>:ud    r6.0<0;1,0>:ud    r1.5<0;1,0>:ud   {Compacted}
        add (1|M0)               r1.4<1>:ud    r1.4<0;1,0>:ud    -r8.0<0;1,0>:ud  {I@1}
        cmp (1|M0)    (ge)f0.0   null<1>:ud    r1.4<0;1,0>:ud    r1.5<0;1,0>:ud   {I@1}
(f0.0)  sel (1|M0)               r3.7<1>:d     r5.0<0;1,0>:w     0:w              
        add3 (1|M0)              r6.0<1>:d     r6.0<0;0>:d       r86.5<0;0>:d      r3.7<0>:d        {I@1}
        xor (1|M0)               r46.0<1>:d    r6.0<0;1,0>:d     r86.5<0;1,0>:d   {Compacted,I@1}
        mov (1|M0)               cr0.0<1>:ud   r1.2<0;1,0>:d                    {A@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        ret (16|M0)                          r86.2                            {A@1}
L21336:
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
