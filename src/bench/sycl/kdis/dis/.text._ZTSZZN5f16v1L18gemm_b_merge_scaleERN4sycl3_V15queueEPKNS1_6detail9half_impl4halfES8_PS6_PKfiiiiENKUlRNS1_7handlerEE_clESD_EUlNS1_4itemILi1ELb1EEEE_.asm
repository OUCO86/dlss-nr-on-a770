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
        mul (1|M0)               acc0.0<1>:ud  r2.0<0;1,0>:ud    r0.2<0;1,0>:uw   {A@1}
        mach (1|M0)              r6.0<1>:ud    r2.0<0;1,0>:ud    r0.1<0;1,0>:ud   {AccWrEn}
        mov (1|M0)               r1.2<1>:d     r1.0<0;1,0>:uw                   {$0.dst}
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r46.2<1>:d    r2.7<0;1,0>:d                   
        addc (1|M0)              r7.0<1>:ud    r5.0<0;1,0>:ud    r1.2<0;1,0>:ud   {AccWrEn,I@2}
        asr (1|M0)               r46.3<1>:d    r2.7<0;1,0>:d     31:w              
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mul (1|M0)               acc0.0<1>:d   r2.7<0;1,0>:d     r2.12<0;1,0>:uw 
        mach (1|M0)              r10.0<1>:d    r2.7<0;1,0>:d     r2.6<0;1,0>:d    {AccWrEn}
        mov (1|M0)               r46.0<1>:f    r7.0<0;1,0>:f                    {Compacted,I@5}
        mov (1|M0)               r9.0<1>:d     acc0.0<0;1,0>:d                 
        add3 (1|M0)              r46.1<1>:d    r8.0<0;0>:d       r6.0<0;0>:d       0:w               {I@4}
        mov (1|M0)               r46.5<1>:d    r10.0<0;1,0>:d                   {I@3}
        mov (1|M0)               r46.4<1>:d    r9.0<0;1,0>:d                    {I@3}
(W)     mov (2|M0)               r50.4<1>:ud   r46.0<1;1,0>:ud                  {A@1}
(W)     mov (2|M0)               r50.6<1>:ud   r46.4<1;1,0>:ud                  {I@2}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r86.2         L5968                                 {A@1}
L552:
        mul (1|M0)               acc0.0<1>:ud  r46.6<0;1,0>:ud   r46.8<0;1,0>:uw 
        mach (1|M0)              r6.0<1>:ud    r46.6<0;1,0>:ud   r46.4<0;1,0>:ud  {AccWrEn}
        shl (1|M0)               r2.3<1>:d     r46.7<0;1,0>:d    5:w              
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r46.6<0;1,0>:d    r46.10<0;1,0>:uw
        mach (1|M0)              r7.0<1>:d     r46.6<0;1,0>:d    r46.5<0;1,0>:d  
(W)     mul (1|M0)               acc0.0<1>:d   r46.7<0;1,0>:d    r46.8<0;1,0>:uw 
        mach (1|M0)              r8.0<1>:d     r46.7<0;1,0>:d    r46.4<0;1,0>:d  
        subb (1|M0)              r9.0<1>:ud    r46.0<0;1,0>:ud   r5.0<0;1,0>:ud   {AccWrEn,I@5}
        add3 (1|M0)              r1.3<1>:d     r8.0<0;0>:d       r6.0<0;0>:d       r7.0<0>:d        {I@2}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mul (1|M0)               acc0.0<1>:ud  r46.6<0;1,0>:ud   r3.4<0;1,0>:uw  
        mach (1|M0)              r12.0<1>:ud   r46.6<0;1,0>:ud   r3.2<0;1,0>:ud   {AccWrEn}
        mov (1|M0)               r47.6<1>:d    r9.0<0;1,0>:d                    {I@5}
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r46.6<0;1,0>:d    r3.6<0;1,0>:uw  
        shl (1|M0)               r7.1<1>:d     r11.0<0;1,0>:d    1:w               {Compacted,I@2}
        mach (1|M0)              r5.0<1>:d     r46.6<0;1,0>:d    r3.3<0;1,0>:d   
(W)     mul (1|M0)               acc0.0<1>:d   r46.7<0;1,0>:d    r3.4<0;1,0>:uw  
        mach (1|M0)              r6.0<1>:d     r46.7<0;1,0>:d    r3.2<0;1,0>:d   
        addc (1|M0)              r8.0<1>:ud    r3.0<0;1,0>:ud    r7.1<0;1,0>:ud   {AccWrEn,I@4}
        add3 (1|M0)              r47.7<1>:d    r46.1<0;0>:d      -r10.0<0;0>:d     -r1.3<0>:d      
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mul (1|M0)               acc0.0<1>:ud  r46.6<0;1,0>:ud   r3.12<0;1,0>:uw 
        mach (1|M0)              r14.0<1>:ud   r46.6<0;1,0>:ud   r3.6<0;1,0>:ud   {AccWrEn}
        add3 (1|M0)              r1.3<1>:d     r6.0<0;0>:d       r12.0<0;0>:d      r5.0<0>:d        {I@6}
        mov (1|M0)               r13.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r46.6<0;1,0>:d    r3.14<0;1,0>:uw 
        mach (1|M0)              r5.0<1>:d     r46.6<0;1,0>:d    r3.7<0;1,0>:d   
(W)     mul (1|M0)               acc0.0<1>:d   r46.7<0;1,0>:d    r3.12<0;1,0>:uw 
        mach (1|M0)              r6.0<1>:d     r46.7<0;1,0>:d    r3.6<0;1,0>:d   
        shr (1|M0)               r2.4<1>:ud    r46.6<0;1,0>:ud   0x1B:uw             
        shr (1|M0)               r7.0<1>:ud    r11.0<0;1,0>:ud   0x1F:uw             
        mov (1|M0)               r47.2<1>:d    r8.0<0;1,0>:d                   
        shl (1|M0)               r4.1<1>:d     r1.3<0;1,0>:d     1:w               {I@7}
        shl (1|M0)               r8.0<1>:d     r13.0<0;1,0>:d    1:w               {Compacted,I@7}
        add3 (1|M0)              r1.3<1>:d     r6.0<0;0>:d       r14.0<0;0>:d      r5.0<0>:d        {I@6}
        or (1|M0)                r47.1<1>:d    r2.3<0;1,0>:d     r2.4<0;1,0>:d    {I@6}
        or (1|M0)                r7.2<1>:d     r4.1<0;1,0>:d     r7.0<0;1,0>:d    {I@4}
        shl (1|M0)               r2.3<1>:d     r1.3<0;1,0>:d     1:w               {Compacted,I@3}
        shr (1|M0)               r2.4<1>:ud    r13.0<0;1,0>:ud   0x1F:uw             
        addc (1|M0)              r7.0<1>:ud    r3.4<0;1,0>:ud    r8.0<0;1,0>:ud   {AccWrEn}
        add3 (1|M0)              r47.3<1>:d    r9.0<0;0>:d       r3.1<0;0>:d       r7.2<0>:d        {I@4}
        or (1|M0)                r8.1<1>:d     r2.3<0;1,0>:d     r2.4<0;1,0>:d    {I@3}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        shl (1|M0)               r47.0<1>:d    r46.6<0;1,0>:d    5:w               {Compacted}
        mov (1|M0)               r86.1<1>:d    r2.7<0;1,0>:d                   
        mov (1|M0)               r86.0<1>:d    r47.6<0;1,0>:d                  
        mov (1|M0)               r47.4<1>:d    r7.0<0;1,0>:d                    {I@7}
        add3 (1|M0)              r47.5<1>:d    r9.0<0;0>:d       r3.5<0;0>:d       r8.1<0>:d        {I@5}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r86.4         L6944                                 {A@1}
L1320:
        cmp (1|M0)    (gt)f1.0   null<1>:d     r4.0<0;1,0>:d     0:w              
(W)     mul (1|M0)               acc0.0<1>:d   r48.0<0;1,0>:d    r2.14<0;1,0>:uw  {Compacted}
        mach (1|M0)              r49.0<1>:d    r48.0<0;1,0>:d    r2.7<0;1,0>:d    {Compacted}
        mov (16|M0)              r51.0<1>:ud   0x0:ud                             
(W)     and (1|M0)               f1.1<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
        mov (16|M0)              r53.0<1>:ud   0x0:ud                             
        mov (16|M0)              r55.0<1>:ud   0x0:ud                             
        mov (16|M0)              r57.0<1>:ud   0x0:ud                             
        mov (16|M0)              r59.0<1>:ud   0x0:ud                             
        mov (16|M0)              r61.0<1>:ud   0x0:ud                             
        mov (16|M0)              r63.0<1>:ud   0x0:ud                             
        mov (16|M0)              r65.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r67.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r69.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r71.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r73.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r75.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r77.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r79.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r81.0<1>:f    0.0:f                               {Compacted}
        add (1|M0)               r49.0<1>:d    r47.6<0;1,0>:d    -r49.0<0;1,0>:d  {Compacted,I@7}
(~f1.1.any16h) goto (16|M0)                  L2600                  L2600                
L1576:
(W)     mul (1|M0)               acc0.0<1>:d   r48.0<0;1,0>:d    r4.0<0;1,0>:uw   {Compacted}
        mach (1|M0)              r5.0<1>:d     r48.0<0;1,0>:d    r4.0<0;1,0>:d    {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r48.0<0;1,0>:d    r4.0<0;1,0>:uw   {Compacted}
        mov (1|M0)               r48.1<1>:d    r49.0<0;1,0>:d                   {I@5}
        asr (1|M0)               r48.2<1>:d    r49.0<0;1,0>:d    31:w               {Compacted}
        mov (1|M0)               r48.3<1>:d    r4.0<0;1,0>:d                   
        mov (1|M0)               r48.4<1>:d    0:w                              
        mov (1|M0)               r48.6<2>:f    0.0:f                              
        mov (1|M0)               r48.7<2>:f    0.0:f                              
        mach (1|M0)              r50.0<1>:d    r48.0<0;1,0>:d    r4.0<0;1,0>:d    {Compacted}
        asr (1|M0)               r50.1<1>:d    r5.0<0;1,0>:d     31:w               {Compacted,I@7}
L1704:
        addc (1|M0)              r5.0<1>:ud    r48.6<0;1,0>:ud   r50.0<0;1,0>:ud  {AccWrEn,A@2}
        shl (1|M0)               r7.0<1>:d     r5.0<0;1,0>:d     8:w               {Compacted,I@1}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        shl (1|M0)               r8.0<1>:d     r7.0<0;1,0>:d     1:w               {Compacted,I@2}
        add3 (1|M0)              r1.3<1>:d     r6.0<0;0>:d       r48.7<0;0>:d      r50.1<0>:d       {A@1}
        addc (1|M0)              r9.0<1>:ud    r47.2<0;1,0>:ud   r8.0<0;1,0>:ud   {AccWrEn,I@2}
        shr (1|M0)               r2.4<1>:ud    r5.0<0;1,0>:ud    0x18:uw             
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mul (1|M0)               acc0.0<1>:ud  r48.6<0;1,0>:ud   r46.4<0;1,0>:uw 
        mach (1|M0)              r13.0<1>:ud   r48.6<0;1,0>:ud   r46.2<0;1,0>:ud  {AccWrEn,$3.src}
        shr (1|M0)               r7.2<1>:ud    r7.0<0;1,0>:ud    0x1F:uw             
        mov (1|M0)               r12.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r48.6<0;1,0>:d    r46.6<0;1,0>:uw 
        mach (1|M0)              r5.0<1>:d     r48.6<0;1,0>:d    r46.3<0;1,0>:d  
(W)     mul (1|M0)               acc0.0<1>:d   r48.7<0;1,0>:d    r46.4<0;1,0>:uw 
        shl (1|M0)               r2.3<1>:d     r1.3<0;1,0>:d     8:w               {Compacted,I@7}
        mach (1|M0)              r6.0<1>:d     r48.7<0;1,0>:d    r46.2<0;1,0>:d  
        addc (1|M0)              r7.0<1>:ud    r12.0<0;1,0>:ud   r48.1<0;1,0>:ud  {AccWrEn,I@6}
        or (1|M0)                r7.1<1>:d     r2.3<0;1,0>:d     r2.4<0;1,0>:d    {I@3}
        add3 (1|M0)              r1.3<1>:d     r6.0<0;0>:d       r13.0<0;0>:d      r5.0<0>:d        {I@3}
        mov (1|M0)               r14.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        shl (1|M0)               r8.0<1>:d     r7.0<0;1,0>:d     8:w               {Compacted,I@4}
        shl (1|M0)               r4.1<1>:d     r7.1<0;1,0>:d     1:w               {Compacted,I@4}
        add3 (1|M0)              r2.4<1>:d     r14.0<0;0>:d      r1.3<0;0>:d       r48.2<0>:d       {I@3}
        mov (1|M0)               r11.0<1>:f    r9.0<0;1,0>:f                    {Compacted}
        shr (1|M0)               r7.1<1>:ud    r7.0<0;1,0>:ud    0x18:uw             
        or (1|M0)                r8.1<1>:d     r4.1<0;1,0>:d     r7.2<0;1,0>:d    {I@3}
        shl (1|M0)               r9.0<1>:d     r8.0<0;1,0>:d     1:w               {Compacted,F@1}
        shl (1|M0)               r4.1<1>:d     r2.4<0;1,0>:d     8:w               {I@4}
        add3 (1|M0)              r11.1<1>:d    r10.0<0;0>:d      r47.3<0;0>:d      r8.1<0>:d        {I@3}
        addc (1|M0)              r5.0<1>:ud    r47.4<0;1,0>:ud   r9.0<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r8.1<1>:d     r4.1<0;1,0>:d     r7.1<0;1,0>:d    {I@3}
        shr (1|M0)               r8.3<1>:ud    r8.0<0;1,0>:ud    0x1F:uw             
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r10.0<1>:f    r5.0<0;1,0>:f                    {Compacted,I@4}
        shl (1|M0)               r8.2<1>:d     r8.1<0;1,0>:d     1:w               {I@3}
        addc (1|M0)              r20.0<1>:ud   r11.0<0;1,0>:ud   0x100:ud              {AccWrEn}
        or (1|M0)                r9.1<1>:d     r8.2<0;1,0>:d     r8.3<0;1,0>:d    {I@2}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r5.0<1>:ud    r10.0<0;1,0>:ud   0x100:ud              {AccWrEn,F@1}
        add3 (1|M0)              r10.1<1>:d    r6.0<0;0>:d       r47.5<0;0>:d      r9.1<0>:d        {I@3}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r21.0<1>:f    r20.0<0;1,0>:f                   {Compacted}
        add3 (1|M0)              r21.1<1>:d    r7.0<0;0>:d       r11.1<0;0>:d      0:w               {I@4}
        mov (1|M0)               r8.0<1>:f     r5.0<0;1,0>:f                    {Compacted,I@4}
        add3 (1|M0)              r8.1<1>:d     r6.0<0;0>:d       r10.1<0;0>:d      0:w               {I@2}
        send.ugm (1|M0)          r12      r11     null:0  0x0            0x0280E780           {$4} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        send.ugm (1|M0)          r30      r10     null:0  0x0            0x0280E780           {$5} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        send.ugm (1|M0)          r22      r21     null:0  0x0            0x0280E780           {A@2,$6} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        send.ugm (1|M0)          r38      r8      null:0  0x0            0x0280E780           {A@1,$7} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        addc (1|M0)              r7.0<1>:ud    r48.6<0;1,0>:ud   0x1:ud              {AccWrEn}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r49.2<1>:d    r7.0<0;1,0>:d                    {I@2}
        add3 (1|M0)              r49.3<1>:d    r9.0<0;0>:d       r48.7<0;0>:d      0:w               {I@2}
        cmp (1|M0)    (eq)f0.0   null<1>:d     r49.3<0;1,0>:d    r48.4<0;1,0>:d   {I@1}
(f0.0)  cmp (1|M0)    (eq)f0.0   null<1>:d     r49.2<0;1,0>:d    r48.3<0;1,0>:d  
(W)     and (1|M0)               f1.0<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
        sync.allwr                           ($3,$4,$5,$6,$7)                
        dpas.8x8 (8|M0)          r75:f         r75:f             r30:hf            r12.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r59:f         r59:f             r30:hf            r22.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r67:f         r67:f             r38:hf            r12.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r51:f         r51:f             r38:hf            r22.0:hf         {$3}
(f1.0.any16h) goto (16|M0)                   L2600                  L2600                
L2568:
(W)     mov (2|M0)               r48.6<1>:ud   r49.2<1;1,0>:ud                 
        goto.b (16|M0)                       L2600                  L1704                
L2600:
        join (16|M0)                         L2616                                
L2616:
        shl (1|M0)               r1.2<1>:d     r49.0<0;1,0>:d    4:w               {Compacted}
        mov (1|M0)               r5.1<1>:d     r4.4<0;1,0>:d                   
        addc (1|M0)              r5.0<1>:ud    r47.0<0;1,0>:ud   r1.2<0;1,0>:ud   {AccWrEn,I@2}
        asr (1|M0)               r5.2<1>:d     r4.4<0;1,0>:d     31:w              
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mul (1|M0)               acc0.0<1>:ud  r46.6<0;1,0>:ud   r5.2<0;1,0>:uw   {I@4}
        mach (1|M0)              r8.0<1>:ud    r46.6<0;1,0>:ud   r5.1<0;1,0>:ud   {AccWrEn}
        add3 (1|M0)              r2.4<1>:d     r6.0<0;0>:d       r47.1<0;0>:d      0:w               {I@3}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r46.6<0;1,0>:d    r5.4<0;1,0>:uw  
        mach (1|M0)              r9.0<1>:d     r46.6<0;1,0>:d    r5.2<0;1,0>:d   
(W)     mul (1|M0)               acc0.0<1>:d   r46.7<0;1,0>:d    r5.2<0;1,0>:uw  
        shl (1|M0)               r6.0<1>:d     r7.0<0;1,0>:d     2:w               {Compacted,I@4}
        mach (1|M0)              r10.0<1>:d    r46.7<0;1,0>:d    r5.1<0;1,0>:d   
        shl (1|M0)               r1.2<1>:d     r5.0<0;1,0>:d     1:w               {Compacted}
        addc (1|M0)              r11.0<1>:ud   r4.2<0;1,0>:ud    r6.0<0;1,0>:ud   {AccWrEn,I@3}
        add3 (1|M0)              r1.3<1>:d     r10.0<0;0>:d      r8.0<0;0>:d       r9.0<0>:d        {I@3}
        shr (1|M0)               r4.1<1>:ud    r7.0<0;1,0>:ud    0x1E:uw             
        shr (1|M0)               r5.2<1>:ud    r5.0<0;1,0>:ud    0x1F:uw             
        shl (1|M0)               r5.1<1>:d     r2.4<0;1,0>:d     1:w              
        mov (1|M0)               r12.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,$3.src}
        mov (8|M0)               r9.0<1>:uw    0xECA86420:uv                             
        shl (1|M0)               r2.5<1>:d     r1.3<0;1,0>:d     2:w               {I@6}
        addc (1|M0)              r7.0<1>:ud    r4.6<0;1,0>:ud    r1.2<0;1,0>:ud   {AccWrEn}
        mov (1|M0)               r49.4<1>:d    r11.0<0;1,0>:d                  
        or (1|M0)                r1.3<1>:d     r5.1<0;1,0>:d     r5.2<0;1,0>:d    {I@6}
        or (1|M0)                r6.1<1>:d     r2.5<0;1,0>:d     r4.1<0;1,0>:d    {I@4}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (8|M0)               r10.0<4>:uw   r9.0<1;1,0>:uw                  
        shl (1|M0)               r48.0<1>:d    r48.0<0;1,0>:d    4:w               {Compacted}
        mov (1|M0)               r49.6<1>:d    r4.5<0;1,0>:d                   
        mov (1|M0)               r49.7<1>:d    0:w                              
        mov (1|M0)               r48.5<1>:d    0:w                              
        mov (1|M0)               r50.2<1>:d    r7.0<0;1,0>:d                    {I@7}
        add3 (1|M0)              r49.5<1>:d    r12.0<0;0>:d      r4.3<0;0>:d       r6.1<0>:d        {I@7}
        add3 (1|M0)              r50.3<1>:d    r8.0<0;0>:d       r4.7<0;0>:d       r1.3<0>:d        {I@7}
        mov (8|M0)               r83.0<2>:ud   r10.0<4;1,0>:uw                  {I@7}
        mov (8|M0)               r83.1<2>:ud   0.0:f                              
L3160:
        or (1|M0)                r1.2<1>:d     r48.5<0;1,0>:d    r48.0<0;1,0>:d   {I@6}
        or (1|M0)                r1.4<1>:ud    r48.5<0;1,0>:ud   r48.0<0;1,0>:ud 
        asr (1|M0)               r1.5<1>:d     r1.2<0;1,0>:d     31:w               {I@2}
        shl (1|M0)               r5.0<1>:d     r1.4<0;1,0>:d     2:w               {Compacted,I@2}
        shr (1|M0)               r2.4<1>:ud    r1.4<0;1,0>:ud    0x1E:uw             
        shl (1|M0)               r2.3<1>:d     r1.5<0;1,0>:d     2:w               {I@3}
        addc (1|M0)              r6.0<1>:ud    r49.4<0;1,0>:ud   r5.0<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r5.1<1>:d     r2.3<0;1,0>:d     r2.4<0;1,0>:d    {I@2}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r8.0<1>:f     r6.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r8.1<1>:d     r7.0<0;0>:d       r49.5<0;0>:d      r5.1<0>:d        {I@1}
        bfn.0xFE (1|M0)          r1.3<1>:ud    0x8:uw               r48.5<0;0>:ud     r48.0<0>:ud      // s0|s1|s2
        sync.nop                             null                             {Compacted,$9.src}
        send.ugm (1|M0)          r9       r8      null:0  0x0            0x04100580           {A@1,$10} // wr:2+0, rd:1; load.ugm.d32.a64
        bfn.0xFE (1|M0)          r9.1<1>:ud    0x8:uw               r48.5<0;0>:ud     r48.0<0>:ud      {$10.dst} // s0|s1|s2
        asr (1|M0)               r9.2<1>:d     r1.3<0;1,0>:d     31:w               {I@2}
        shl (1|M0)               r9.4<1>:d     r9.1<0;1,0>:d     2:w               {I@2}
        shr (1|M0)               r9.3<1>:ud    r9.1<0;1,0>:ud    0x1E:uw             
        shl (1|M0)               r4.1<1>:d     r9.2<0;1,0>:d     2:w               {I@3}
        addc (1|M0)              r10.0<1>:ud   r49.4<0;1,0>:ud   r9.4<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r9.5<1>:d     r4.1<0;1,0>:d     r9.3<0;1,0>:d    {I@2}
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,$8.src}
        mov (1|M0)               r6.0<1>:f     r10.0<0;1,0>:f                   {Compacted,I@3}
        add3 (1|M0)              r6.1<1>:d     r11.0<0;0>:d      r49.5<0;0>:d      r9.5<0>:d        {I@1}
        shl (1|M0)               r2.6<1>:w     r48.10<0;1,0>:w   5:w              
        send.ugm (1|M0)          r5       r6      null:0  0x0            0x04100580           {A@1,$11} // wr:2+0, rd:1; load.ugm.d32.a64
        add (1|M0)               a0.3<1>:uw    r2.6<0;1,0>:uw    0x960:uw              {A@1}
        add (1|M0)               a0.2<1>:uw    r2.6<0;1,0>:uw    0x860:uw              {A@1}
        add (1|M0)               a0.1<1>:uw    r2.6<0;1,0>:uw    0x760:uw              {A@1}
        add (1|M0)               a0.0<1>:uw    r2.6<0;1,0>:uw    0x660:uw              {A@1}
        sync.nop                             null                             {Compacted,$11.src}
        mov (8|M0)               r7.0<1>:ud    r[a0.3]<1;1,0>:ud                {$3.dst}
        mul (1|M0)               acc0.0<1>:ud  r1.4<0;1,0>:ud    r49.12<0;1,0>:uw {A@1}
        sync.nop                             null                             {Compacted,$11.dst}
        mov (8|M0)               r5.8<1>:hf    r7.0<1;1,0>:f                    {I@2}
        mach (1|M0)              r17.0<1>:ud   r1.4<0;1,0>:ud    r49.6<0;1,0>:ud  {AccWrEn}
        mov (8|M0)               acc2.0<1>:f   r5.8<1;1,0>:hf                   {F@1}
        mov (1|M0)               r16.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r1.4<0;1,0>:d     r49.14<0;1,0>:uw
        shl (1|M0)               r1.2<1>:d     r16.0<0;1,0>:d    1:w               {Compacted,I@2}
        add (1|M0)               r48.5<1>:ud   r48.5<0;1,0>:ud   0x1:uw             
        mul (8|M0)               r8.0<1>:f     r9.0<0;1,0>:f     acc2.0<1;1,0>:f 
        mov (8|M0)               r9.8<1>:hf    r8.0<1;1,0>:f                    {F@1}
        cmp (8|M0)    (lt)f0.1   null<1>:f     r8.0<1;1,0>:f     0xB3000000:f              
        mov (8|M0)               acc2.0<1>:f   (abs)r9.8<1;1,0>:hf              {F@2}
        sel (8|M0)    (lt)f0.0   r10.0<1>:f    acc2.0<1;1,0>:f   448.0:f               {Compacted}
        shr (8|M0)               r6.0<1>:ud    r10.0<1;1,0>:ud   0x17:uw              {F@1}
        sel (8|M0)    (ge)f0.0   r11.0<2>:ub   r6.0<4;1,0>:ub    0x79:uw              {I@1}
        mov (8|M0)               r6.0<1>:ud    r[a0.2]<1;1,0>:ud               
        mov (8|M0)               r12.0<1>:d    r11.0<2;1,0>:ub                  {A@1}
        mov (8|M0)               r9.8<1>:hf    r6.0<1;1,0>:f                    {I@2}
        shl (8|M0)               r12.0<1>:d    r12.0<1;1,0>:d    23:w               {Compacted,I@1}
        mov (8|M0)               acc2.0<1>:f   r9.8<1;1,0>:hf                   {F@1}
        add (8|M0)               r13.0<1>:d    r12.0<1;1,0>:d    -25165824:d               {I@1}
        mul (8|M0)               r11.0<1>:f    r9.0<0;1,0>:f     acc2.0<1;1,0>:f 
        add (8|M0)               r12.0<1>:d    -r12.0<1;1,0>:d   -2139095040:d              
        mov (8|M0)               r14.0<1>:hf   r11.0<1;1,0>:f                   {F@1}
        mul (8|M0)               acc2.0<1>:f   r10.0<1;1,0>:f    r12.0<1;1,0>:f   {Compacted,I@1}
        mov (8|M0)               acc3.0<1>:f   (abs)r14.0<1;1,0>:hf             {F@2}
        rnde (8|M0)              acc2.0<1>:f   acc2.0<1;1,0>:f                 
        sel (8|M0)    (lt)f0.0   r12.0<1>:f    acc3.0<1;1,0>:f   448.0:f               {Compacted}
        mul (8|M0)               acc2.0<1>:f   acc2.0<1;1,0>:f   r13.0<1;1,0>:f   {Compacted}
        shr (8|M0)               r10.0<1>:ud   r12.0<1;1,0>:ud   0x17:uw              {F@2}
        mov (8|M0)               r7.0<1>:f     (abs)acc2.0<1;1,0>:f             {Compacted}
        sel (8|M0)    (ge)f0.0   r13.0<2>:ub   r10.0<4;1,0>:ub   0x79:uw              {A@1}
        mov (8|M0)               r10.0<1>:ud   r[a0.1]<1;1,0>:ud               
        mov (8|M0)               r8.0<1>:d     r13.0<2;1,0>:ub                  {A@1}
        mov (8|M0)               r13.0<1>:hf   r10.0<1;1,0>:f                   {A@1}
(f0.1)  or (8|M0)                r7.0<1>:d     r7.0<1;1,0>:d     -2147483648:d               {F@2}
        mov (8|M0)               acc2.0<1>:f   r13.0<1;1,0>:hf                  {F@1}
        shl (8|M0)               r8.0<1>:d     r8.0<1;1,0>:d     23:w               {Compacted}
        mul (8|M0)               r14.0<1>:f    r5.0<0;1,0>:f     acc2.0<1;1,0>:f 
        mov (8|M0)               r5.8<1>:hf    r7.0<1;1,0>:f                    {I@2}
        add (8|M0)               r7.0<1>:d     r8.0<1;1,0>:d     -25165824:d               {A@1}
        mov (8|M0)               r15.0<1>:hf   r14.0<1;1,0>:f                  
        add (8|M0)               r8.0<1>:d     -r8.0<1;1,0>:d    -2139095040:d              
        cmp (8|M0)    (lt)f0.0   null<1>:f     r11.0<1;1,0>:f    0xB3000000:f               {Compacted}
        mul (8|M0)               acc2.0<1>:f   r12.0<1;1,0>:f    r8.0<1;1,0>:f    {Compacted,I@1}
        mov (8|M0)               acc3.0<1>:f   (abs)r15.0<1;1,0>:hf             {F@3}
        rnde (8|M0)              acc2.0<1>:f   acc2.0<1;1,0>:f                 
        sel (8|M0)    (lt)f0.0   r8.0<1>:f     acc3.0<1;1,0>:f   448.0:f               {Compacted}
        mul (8|M0)               acc2.0<1>:f   acc2.0<1;1,0>:f   r7.0<1;1,0>:f    {Compacted}
        shr (8|M0)               r7.0<1>:ud    r8.0<1;1,0>:ud    0x17:uw              {A@1}
        mov (8|M0)               r6.0<1>:f     (abs)acc2.0<1;1,0>:f             {Compacted}
        sel (8|M0)    (ge)f0.0   r12.0<2>:ub   r7.0<4;1,0>:ub    0x79:uw              {I@1}
        mov (8|M0)               r7.0<1>:ud    r[a0.0]<1;1,0>:ud               
        mov (8|M0)               r11.0<1>:d    r12.0<2;1,0>:ub                  {A@1}
        mov (8|M0)               r12.0<1>:hf   r7.0<1;1,0>:f                    {A@1}
(f0.0)  or (8|M0)                r6.0<1>:d     r6.0<1;1,0>:d     -2147483648:d               {F@2}
        mov (8|M0)               acc2.0<1>:f   r12.0<1;1,0>:hf                  {F@1}
        shl (8|M0)               r11.0<1>:d    r11.0<1;1,0>:d    23:w               {Compacted}
        mul (8|M0)               r15.0<1>:f    r5.0<0;1,0>:f     acc2.0<1;1,0>:f 
        mov (8|M0)               r9.8<1>:hf    r6.0<1;1,0>:f                    {I@2}
        add (8|M0)               r6.0<1>:d     r11.0<1;1,0>:d    -25165824:d               {A@1}
        mov (8|M0)               r13.8<1>:hf   r15.0<1;1,0>:f                  
        add (8|M0)               r11.0<1>:d    -r11.0<1;1,0>:d   -2139095040:d              
        cmp (8|M0)    (lt)f1.1   null<1>:f     r14.0<1;1,0>:f    0xB3000000:f              
        mul (8|M0)               acc2.0<1>:f   r8.0<1;1,0>:f     r11.0<1;1,0>:f   {Compacted,I@1}
        mov (8|M0)               acc3.0<1>:f   (abs)r13.8<1;1,0>:hf             {F@3}
        rnde (8|M0)              acc2.0<1>:f   acc2.0<1;1,0>:f                 
        sel (8|M0)    (lt)f0.0   r11.0<1>:f    acc3.0<1;1,0>:f   448.0:f               {Compacted}
        mul (8|M0)               acc2.0<1>:f   acc2.0<1;1,0>:f   r6.0<1;1,0>:f    {Compacted}
        shr (8|M0)               r6.0<1>:ud    r11.0<1;1,0>:ud   0x17:uw              {A@1}
        mov (8|M0)               r10.0<1>:f    (abs)acc2.0<1;1,0>:f             {Compacted}
        sel (8|M0)    (ge)f0.0   r8.0<2>:ub    r6.0<4;1,0>:ub    0x79:uw              {I@1}
(f1.1)  or (8|M0)                r10.0<1>:d    r10.0<1;1,0>:d    -2147483648:d               {F@1}
        mov (8|M0)               r14.0<1>:d    r8.0<2;1,0>:ub                   {I@2}
        mov (8|M0)               r13.0<1>:hf   r10.0<1;1,0>:f                   {I@2}
        shl (8|M0)               r14.0<1>:d    r14.0<1;1,0>:d    23:w               {Compacted,I@1}
        cmp (8|M0)    (lt)f1.0   null<1>:f     r15.0<1;1,0>:f    0xB3000000:f              
        add (8|M0)               r10.0<1>:d    r14.0<1;1,0>:d    -25165824:d               {A@1}
        add (8|M0)               r14.0<1>:d    -r14.0<1;1,0>:d   -2139095040:d              
        mach (1|M0)              r6.0<1>:d     r1.4<0;1,0>:d     r49.7<0;1,0>:d  
        mul (8|M0)               r11.0<1>:f    r11.0<1;1,0>:f    r14.0<1;1,0>:f   {Compacted,I@2}
(W)     mul (1|M0)               acc0.0<1>:d   r1.5<0;1,0>:d     r49.12<0;1,0>:uw
        rnde (8|M0)              acc2.0<1>:f   r11.0<1;1,0>:f                   {F@1}
        mach (1|M0)              r8.0<1>:d     r1.5<0;1,0>:d     r49.6<0;1,0>:d  
        mul (8|M0)               r7.0<1>:f     acc2.0<1;1,0>:f   r10.0<1;1,0>:f   {Compacted}
        mul (1|M0)               acc0.0<1>:ud  r9.1<0;1,0>:ud    r49.12<0;1,0>:uw
        mov (8|M0)               r7.0<1>:f     (abs)r7.0<1;1,0>:f               {Compacted,F@1}
        mach (1|M0)              r11.0<1>:ud   r9.1<0;1,0>:ud    r49.6<0;1,0>:ud  {AccWrEn}
(f1.0)  or (8|M0)                r7.0<1>:d     r7.0<1;1,0>:d     -2147483648:d               {F@1}
        add3 (1|M0)              r2.4<1>:d     r8.0<0;0>:d       r17.0<0;0>:d      r6.0<0>:d        {I@4}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r9.1<0;1,0>:d     r49.14<0;1,0>:uw
        mov (8|M0)               r5.0<1>:hf    r7.0<1;1,0>:f                    {I@4}
        mach (1|M0)              r7.0<1>:d     r9.1<0;1,0>:d     r49.7<0;1,0>:d   {F@1}
(W)     mul (1|M0)               acc0.0<1>:d   r9.2<0;1,0>:d     r49.12<0;1,0>:uw
        shr (1|M0)               r13.6<1>:ud   r16.0<0;1,0>:ud   0x1F:uw             
        shl (1|M0)               r4.1<1>:d     r2.4<0;1,0>:d     1:w               {I@6}
        mach (1|M0)              r12.0<1>:d    r9.2<0;1,0>:d     r49.6<0;1,0>:d  
        addc (1|M0)              r6.0<1>:ud    r50.2<0;1,0>:ud   r1.2<0;1,0>:ud   {AccWrEn}
        or (1|M0)                r1.3<1>:d     r4.1<0;1,0>:d     r13.6<0;1,0>:d   {I@3}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r1.4<1>:d     r6.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r1.5<1>:d     r8.0<0;0>:d       r50.3<0;0>:d      r1.3<0>:d        {I@2}
        mov (8|M0)               r14.0<2>:ud   r1.4<0;1,0>:ud                   {I@2}
        mov (8|M0)               r14.1<2>:ud   r1.5<0;1,0>:ud                   {I@2}
        add3 (1|M0)              r13.5<1>:d    r12.0<0;0>:d      r11.0<0;0>:d      r7.0<0>:d       
        addc (8|M0)              r18.0<1>:ud   r14.0<2;1,0>:ud   r83.0<2;1,0>:ud  {AccWrEn,Compacted,I@2}
        mov (8|M0)               r17.0<1>:d    r5.8<1;1,0>:uw                  
        mov (8|M0)               r7.0<1>:ud    acc0.0<1;1,0>:ud                 {Compacted}
        addc (1|M0)              r6.0<1>:ud    r1.4<0;1,0>:ud    0x10:ud              {AccWrEn}
        shl (1|M0)               r5.4<1>:d     r10.0<0;1,0>:d    1:w               {Compacted}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r1.2<1>:d     r6.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r1.3<1>:d     r8.0<0;0>:d       r1.5<0;0>:d       0:w               {I@2}
        mov (8|M0)               r21.0<2>:ud   r1.2<0;1,0>:ud                   {I@2}
        mov (8|M0)               r21.1<2>:ud   r1.3<0;1,0>:ud                   {I@2}
        shr (1|M0)               r2.4<1>:ud    r10.0<0;1,0>:ud   0x1F:uw             
        addc (8|M0)              r23.0<1>:ud   r21.0<2;1,0>:ud   r83.0<2;1,0>:ud  {AccWrEn,Compacted,I@2}
        mov (8|M0)               r12.0<1>:d    r83.1<2;1,0>:d                  
        shl (1|M0)               r2.3<1>:d     r13.5<0;1,0>:d    1:w              
        mov (8|M0)               r19.0<2>:d    r18.0<1;1,0>:d                  
        mov (8|M0)               r18.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        addc (1|M0)              r6.0<1>:ud    r50.2<0;1,0>:ud   r5.4<0;1,0>:ud   {AccWrEn}
        add3 (8|M0)              r16.0<1>:d    r7.0<1;0>:d       r14.1<4;2>:d      r12.0<1>:d       {I@5}
        or (1|M0)                r5.5<1>:d     r2.3<0;1,0>:d     r2.4<0;1,0>:d    {I@5}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r1.2<1>:d     r6.0<0;1,0>:d                    {I@4}
        mov (8|M0)               r19.1<2>:d    r16.0<1;1,0>:d                   {I@4}
        add3 (1|M0)              r1.3<1>:d     r8.0<0;0>:d       r50.3<0;0>:d      r5.5<0>:d        {I@3}
        send.ugm (8|M0)          null     r19     r17:1   0x0            0x04000B84           {A@2,$12} // wr:2+1, rd:0; store.ugm.d16u32.a64
        add3 (8|M0)              r7.0<1>:d     r18.0<1;0>:d      r21.1<4;2>:d      r12.0<1>:d      
        mov (8|M0)               r17.0<2>:ud   r1.2<0;1,0>:ud                   {$12.src}
        mov (8|M0)               r17.1<2>:ud   r1.3<0;1,0>:ud                   {I@3}
        mov (8|M0)               r14.0<2>:d    r23.0<1;1,0>:d                  
        mov (8|M0)               r14.1<2>:d    r7.0<1;1,0>:d                    {I@4}
        addc (8|M0)              r7.0<1>:ud    r17.0<2;1,0>:ud   r83.0<2;1,0>:ud  {AccWrEn,Compacted,I@3}
        mov (8|M0)               r16.0<1>:d    r9.8<1;1,0>:uw                  
        mov (8|M0)               r9.0<1>:ud    acc0.0<1;1,0>:ud                 {Compacted}
        addc (1|M0)              r6.0<1>:ud    r1.2<0;1,0>:ud    0x10:ud              {AccWrEn}
        send.ugm (8|M0)          null     r14     r16:1   0x0            0x04000B84           {A@3,$13} // wr:2+1, rd:0; store.ugm.d16u32.a64
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r1.4<1>:d     r6.0<0;1,0>:d                    {I@2}
        add3 (1|M0)              r1.5<1>:d     r8.0<0;0>:d       r1.3<0;0>:d       0:w               {I@2}
        mov (8|M0)               r19.0<2>:ud   r1.4<0;1,0>:ud                   {I@2}
        mov (8|M0)               r19.1<2>:ud   r1.5<0;1,0>:ud                   {I@2}
        cmp (1|M0)    (eq)f0.1   null<1>:d     r48.5<0;1,0>:d    8:w              
        sync.nop                             null                             {Compacted,$13.src}
        addc (8|M0)              r16.0<1>:ud   r19.0<2;1,0>:ud   r83.0<2;1,0>:ud  {AccWrEn,Compacted,I@2}
        add3 (8|M0)              r10.0<1>:d    r9.0<1;0>:d       r17.1<4;2>:d      r12.0<1>:d      
        mov (8|M0)               r21.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mov (8|M0)               r14.0<2>:d    r7.0<1;1,0>:d                   
(W)     and (1|M0)               f0.1<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
        add3 (8|M0)              r7.0<1>:d     r21.0<1;0>:d      r19.1<4;2>:d      r12.0<1>:d       {I@3}
        mov (8|M0)               r11.0<1>:d    r13.0<1;1,0>:uw                 
        mov (8|M0)               r17.0<2>:d    r16.0<1;1,0>:d                  
        mov (8|M0)               r9.0<1>:d     r5.0<1;1,0>:uw                  
        mov (8|M0)               r14.1<2>:d    r10.0<1;1,0>:d                  
        mov (8|M0)               r17.1<2>:d    r7.0<1;1,0>:d                    {I@5}
        send.ugm (8|M0)          null     r14     r11:1   0x0            0x04000B84           {A@2,$8} // wr:2+1, rd:0; store.ugm.d16u32.a64
        send.ugm (8|M0)          null     r17     r9:1    0x0            0x04000B84           {A@1,$9} // wr:2+1, rd:0; store.ugm.d16u32.a64
(~f0.1.any16h) goto.b (16|M0)                L5896                  L3160                
L5896:
        join (16|M0)                         L5912                                
L5912:
(W)     mov (8|M0)               r127.0<1>:f   r0.0<1;1,0>:f                    {Compacted}
(W)     send.ugm (1|M0)          r5       r0      null:0  0x0            0x0210641F           {$14} // wr:1+0, rd:1; fence invalid flush type scoped to tile
(W)     mov (8|M0)               null<1>:ud    r5.0<1;1,0>:ud                   {$14.dst}
(W)     send.gtwy (1|M0)         null     r127    null:0  0x0            0x02000010           {EOT,A@1} // wr:1+0, rd:0; end of thread
L5968:
        mov (2|M0)               r85.0<1>:d    0x1:v                              
        mov (1|M0)               r85.2<2>:f    0.0:f                              
        mov (1|M0)               r85.3<2>:f    0.0:f                              
        mov (1|M0)               r85.4<2>:f    0.0:f                              
        mov (1|M0)               r85.5<2>:d    0:d                              
        mov (1|M0)               r49.1<1>:d    63:w                              
L6064:
        and (1|M0)    (eq)f0.0   r2.3<1>:d     r49.1<0;1,0>:d    63:w               {I@1}
(W)     mov (1|M0)               r2.10<1>:hf   0.0:hf                             
        mov (1|M0)               r1.3<1>:d     0:w                              
        shr (1|M0)               r6.2<1>:ud    r85.4<0;1,0>:ud   0x1F:uw              {F@2}
        cmp (1|M0)    (ge)f0.1   null<1>:ud    r2.3<0;1,0>:ud    0x20:uw              {I@3}
(f0.0)  sel (1|M0)               r5.0<1>:d     r2.10<0;1,0>:w    -1:w               {F@1}
        add (1|M0)               r2.4<1>:d     -r2.3<0;1,0>:d    32:w              
        add (1|M0)               r5.2<1>:d     r2.3<0;1,0>:d     -32:w              
        and (1|M0)               r5.1<1>:d     r50.5<0;1,0>:d    r5.0<0;1,0>:d    {I@3}
        shr (1|M0)               r1.2<1>:ud    r50.4<0;1,0>:ud   r2.3<0;1,0>:ud  
(f0.1)  sel (1|M0)               r4.1<1>:d     r2.10<0;1,0>:w    -1:w              
        shr (1|M0)               r5.2<1>:ud    r50.5<0;1,0>:ud   r5.2<0;1,0>:ud   {I@4}
        shl (1|M0)               r5.1<1>:d     r5.1<0;1,0>:d     r2.4<0;1,0>:d    {I@4}
        shr (1|M0)               r1.3<1>:ud    r50.5<0;1,0>:ud   r2.3<0;1,0>:ud  
        shl (1|M0)               r2.5<1>:d     r85.5<0;1,0>:d    1:w              
        and (1|M0)               r1.2<1>:ud    r1.2<0;1,0>:ud    r4.1<0;1,0>:ud   {I@5}
        and (1|M0)               r5.2<1>:ud    r5.2<0;1,0>:ud    ~r4.1<0;1,0>:ud  {I@5}
        and (1|M0)               r5.1<1>:d     r5.1<0;1,0>:d     r4.1<0;1,0>:d    {I@5}
        shl (1|M0)               r7.0<1>:d     r85.4<0;1,0>:d    1:w               {Compacted}
        and (1|M0)               r6.1<1>:ud    r1.3<0;1,0>:ud    r4.1<0;1,0>:ud   {I@6}
        or (1|M0)                r7.1<1>:d     r2.5<0;1,0>:d     r6.2<0;1,0>:d    {I@6}
        bfn.0xFE (1|M0)          r6.0<1>:ud    r5.2<0;0>:ud      r1.2<0;0>:ud      r5.1<0>:ud       {I@4} // s0|s1|s2
(W)     mov (1|M0)               r1.3<1>:hf    0x1:hf                             
        bfn.0xEA (2|M0)          r7.0<1>:ud    r7.0<1;0>:ud      r6.0<1;0>:ud      r85.0<1>:ud      {I@1} // s0|s1&s2
        cmp (1|M0)    (eq)f0.0   null<1>:d     r49.1<0;1,0>:d    0:w              
        cmp (1|M0)    (lt)f0.1   null<1>:ud    r7.0<0;1,0>:ud    r50.6<0;1,0>:ud  {I@2}
        cmp (1|M0)    (lt)f1.1   null<1>:ud    r7.1<0;1,0>:ud    r50.7<0;1,0>:ud 
        and (1|M0)               r5.0<1>:d     r5.0<0;1,0>:d     1:w               {Compacted}
(W)     mov (1|M0)               r2.10<1>:hf   0x1:hf                             
(f0.1)  cmp (1|M0)    (eq)f0.1   null<1>:d     r7.1<0;1,0>:d     r50.7<0;1,0>:d  
(f1.1)  sel (1|M0)               r1.5<1>:uw    r1.3<0;1,0>:uw    0x0:uw              {F@2}
        shl (1|M0)               r2.3<1>:ud    r1.3<0;1,0>:uw    r2.3<0;1,0>:ud  
        subb (1|M0)              r8.0<1>:ud    r7.0<0;1,0>:ud    r50.6<0;1,0>:ud  {AccWrEn}
(f0.1)  sel (1|M0)               r1.4<1>:uw    r1.3<0;1,0>:uw    0x0:uw             
(W)     and (1|M0)               f0.0<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
        shr (1|M0)               r5.0<1>:ud    r5.0<0;1,0>:ud    r2.4<0;1,0>:ud   {Compacted,I@7}
        shl (1|M0)               r5.1<1>:d     r2.10<0;1,0>:w    -r2.4<0;1,0>:d   {F@1}
        or (1|M0)     (ne)f1.1   null<1>:uw    r1.4<0;1,0>:uw    r1.5<0;1,0>:uw   {I@4}
        and (1|M0)               r46.6<1>:ud   r2.3<0;1,0>:ud    r4.1<0;1,0>:ud  
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        bfn.0xCA (1|M0)          r46.7<1>:ud   r5.1<0;0>:ud      r5.0<0;0>:ud      r4.1<0>:ud       {I@4} // s0&~s2|s1&s2
        add (1|M0)               r85.6<1>:d    r49.1<0;1,0>:d    -1:w              
        mov (1|M0)               r85.4<1>:d    r8.0<0;1,0>:d                   
        add3 (1|M0)              r85.5<1>:d    r7.1<0;0>:d       -r9.0<0;0>:d      -r50.7<0>:d      {I@4}
        or (2|M0)                r46.6<1>:d    r46.6<1;1,0>:d    r85.2<1;1,0>:d   {I@4}
(f1.1)  mov (1|M0)               r85.4<1>:d    r7.0<0;1,0>:d                   
(f1.1)  mov (1|M0)               r85.5<1>:d    r7.1<0;1,0>:d                   
(f1.1)  mov (1|M0)               r46.6<1>:d    r85.2<0;1,0>:d                  
(f1.1)  mov (1|M0)               r46.7<1>:d    r85.3<0;1,0>:d                  
(f0.0.any16h) goto (16|M0)                   L6880                  L6880                
L6832:
(W)     mov (2|M0)               r85.2<1>:ud   r46.6<1;1,0>:ud                  {I@2}
        mov (1|M0)               r49.1<1>:d    r85.6<0;1,0>:d                  
        goto.b (16|M0)                       L6880                  L6064                
L6880:
        join (16|M0)                         L6896                                
L6896:
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        ret (16|M0)                          r86.2                            {A@1}
L6944:
        mov (1|M0)               r1.2<1>:d     cr0.0<0;1,0>:ud                  {A@1}
        and (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   -1265:w               {A@1}
        or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   1264:w               {A@1}
        mov (1|M0)               r1.3<1>:f     (abs)r86.1<0;1,0>:d              {A@1}
        mov (1|M0)               r5.1<1>:f     0xB4C00000:f                               {Compacted}
        math.inv (1|M0)          r5.0<1>:f     r1.3<0;1,0>:f                    {@2,$15}
        mov (1|M0)               r2.4<1>:f     (abs)r86.0<0;1,0>:d              {Compacted}
        sync.nop                             null                             {Compacted,$15.dst}
        mad (1|M0)               r5.0<1>:f     r5.0<0;0>:f       r5.1<0;0>:f       r5.0<0>:f        {F@2}
        mov (2|M0)               r1.4<1>:d     (abs)r86.0<1;1,0>:d             
        mov (1|M0)               r1.6<1>:ud    r1.3<0;1,0>:f                   
        mov (1|M0)               r2.5<1>:ud    r2.4<0;1,0>:f                    {F@2}
        mul (1|M0)               r6.0<1>:f     r5.0<0;1,0>:f     r2.4<0;1,0>:f    {Compacted,F@1}
        add (1|M0)               r1.6<1>:ud    r1.5<0;1,0>:ud    -r1.6<0;1,0>:ud  {I@2}
        add (1|M0)               r2.5<1>:ud    r1.4<0;1,0>:ud    -r2.5<0;1,0>:ud  {I@2}
        mov (1|M0)               r7.0<1>:ud    r6.0<0;1,0>:f                    {F@1}
        mov (1|M0)               r2.3<1>:f     r1.6<0;1,0>:ud                   {I@3}
        mov (1|M0)               r4.1<1>:f     r2.5<0;1,0>:ud                   {I@2}
        mov (1|M0)               r7.1<1>:f     r7.0<0;1,0>:ud                   {Compacted,I@1}
        xor (1|M0)               r86.1<1>:d    r86.1<0;1,0>:d    r86.0<0;1,0>:d   {Compacted}
        mad (1|M0)               r2.4<1>:f     r2.4<0;0>:f       r7.1<0;0>:f       -r1.3<0>:f       {F@1}
        mad (1|M0)               r7.1<1>:f     r4.1<0;0>:f       r7.1<0;0>:f       -r2.3<0>:f      
(W)     mov (1|M0)               r6.0<1>:hf    0x1:hf                             
        add (1|M0)               r2.4<1>:f     r2.4<0;1,0>:f     r7.1<0;1,0>:f    {F@2}
        asr (1|M0)               r86.1<1>:d    r86.1<0;1,0>:d    31:w               {Compacted,I@1}
        mul (1|M0)               r5.0<1>:f     r5.0<0;1,0>:f     r2.4<0;1,0>:f    {Compacted,F@1}
        mov (1|M0)               r8.0<1>:ud    r5.0<0;1,0>:f                    {F@1}
        add (1|M0)               r7.0<1>:ud    r7.0<0;1,0>:ud    r8.0<0;1,0>:ud   {Compacted,I@1}
(W)     mul (1|M0)               acc0.0<1>:ud  r7.0<0;1,0>:ud    r1.10<0;1,0>:uw  {I@1}
        mach (1|M0)              r9.0<1>:ud    r7.0<0;1,0>:ud    r1.5<0;1,0>:ud   {Compacted}
        add (1|M0)               r1.4<1>:ud    r1.4<0;1,0>:ud    -r9.0<0;1,0>:ud  {I@1}
        cmp (1|M0)    (ge)f1.0   null<1>:ud    r1.4<0;1,0>:ud    r1.5<0;1,0>:ud   {I@1}
(f1.0)  sel (1|M0)               r4.1<1>:d     r6.0<0;1,0>:w     0:w              
        add3 (1|M0)              r7.0<1>:d     r7.0<0;0>:d       r86.1<0;0>:d      r4.1<0>:d        {I@1}
        xor (1|M0)               r48.0<1>:d    r7.0<0;1,0>:d     r86.1<0;1,0>:d   {Compacted,I@1}
        mov (1|M0)               cr0.0<1>:ud   r1.2<0;1,0>:d                    {A@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        ret (16|M0)                          r86.4                            {A@1}
L7480:
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
