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
        mov (1|M0)               r86.0<1>:d    r0.1<0;1,0>:ud                   {A@1}
        mov (1|M0)               r87.5<1>:d    r2.6<0;1,0>:d                    {$1.dst}
(W)     mul (1|M0)               acc0.0<1>:d   r86.0<0;1,0>:d    r2.0<0;1,0>:uw   {Compacted,I@2}
        mach (1|M0)              r86.0<1>:d    r86.0<0;1,0>:d    r2.0<0;1,0>:d    {Compacted}
        sync.nop                             null                             {Compacted,$0.dst}
        add (1|M0)               r86.0<1>:d    r86.0<0;1,0>:d    r1.0<0;1,0>:uw   {I@1}
        mov (1|M0)               r87.4<1>:d    r86.0<0;1,0>:d                   {I@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r86.6         L5168                                 {A@1}
L344:
        cmp (1|M0)    (gt)f1.0   null<1>:d     r2.7<0;1,0>:d     0:w              
(W)     mul (1|M0)               acc0.0<1>:d   r85.0<0;1,0>:d    r2.12<0;1,0>:uw  {Compacted}
        mach (1|M0)              r4.0<1>:d     r85.0<0;1,0>:d    r2.6<0;1,0>:d    {Compacted}
        mov (16|M0)              r88.0<1>:ud   0x0:ud                             
(W)     and (1|M0)               f0.1<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
        mov (16|M0)              r90.0<1>:ud   0x0:ud                             
        mov (16|M0)              r92.0<1>:ud   0x0:ud                             
        mov (16|M0)              r94.0<1>:ud   0x0:ud                             
        mov (16|M0)              r96.0<1>:ud   0x0:ud                             
        mov (16|M0)              r98.0<1>:ud   0x0:ud                             
        mov (16|M0)              r100.0<1>:ud  0x0:ud                             
        mov (16|M0)              r102.0<1>:f   0.0:f                               {Compacted}
        mov (16|M0)              r104.0<1>:f   0.0:f                               {Compacted}
        mov (16|M0)              r106.0<1>:f   0.0:f                               {Compacted}
        mov (16|M0)              r108.0<1>:f   0.0:f                               {Compacted}
        mov (16|M0)              r110.0<1>:f   0.0:f                               {Compacted}
        mov (16|M0)              r112.0<1>:f   0.0:f                               {Compacted}
        mov (16|M0)              r114.0<1>:f   0.0:f                               {Compacted}
        mov (16|M0)              r116.0<1>:f   0.0:f                               {Compacted}
        mov (16|M0)              r118.0<1>:f   0.0:f                               {Compacted}
        add (1|M0)               r86.0<1>:d    r86.0<0;1,0>:d    -r4.0<0;1,0>:d   {Compacted,I@7}
(~f0.1.any16h) goto (16|M0)                  L1632                  L1632                
L600:
(W)     mul (1|M0)               acc0.0<1>:d   r85.0<0;1,0>:d    r2.14<0;1,0>:uw  {Compacted}
        mach (1|M0)              r4.0<1>:d     r85.0<0;1,0>:d    r2.7<0;1,0>:d    {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r85.0<0;1,0>:d    r2.14<0;1,0>:uw  {Compacted}
        mov (1|M0)               r85.1<1>:d    r2.6<0;1,0>:d                   
        asr (1|M0)               r85.2<1>:d    r2.6<0;1,0>:d     31:w              
        mov (1|M0)               r85.3<1>:d    r86.0<0;1,0>:d                   {I@7}
        asr (1|M0)               r85.4<1>:d    r86.0<0;1,0>:d    31:w               {Compacted}
        mov (1|M0)               r85.5<1>:d    r2.7<0;1,0>:d                   
        mov (1|M0)               r85.6<1>:d    0:w                              
        mov (1|M0)               r86.2<2>:f    0.0:f                              
        mov (1|M0)               r86.3<2>:f    0.0:f                              
        mach (1|M0)              r87.0<1>:d    r85.0<0;1,0>:d    r2.7<0;1,0>:d    {Compacted}
        asr (1|M0)               r87.1<1>:d    r4.0<0;1,0>:d     31:w               {Compacted,I@7}
L760:
        addc (1|M0)              r4.0<1>:ud    r86.2<0;1,0>:ud   r87.0<0;1,0>:ud  {AccWrEn,A@2}
        shl (1|M0)               r9.0<1>:d     r4.0<0;1,0>:d     8:w               {Compacted,I@1}
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        shl (1|M0)               r12.0<1>:d    r9.0<0;1,0>:d     1:w               {Compacted,I@2}
        add3 (1|M0)              r6.1<1>:d     r5.0<0;0>:d       r86.3<0;0>:d      r87.1<0>:d       {A@1}
        addc (1|M0)              r13.0<1>:ud   r3.0<0;1,0>:ud    r12.0<0;1,0>:ud  {AccWrEn,I@2}
        shr (1|M0)               r8.0<1>:ud    r4.0<0;1,0>:ud    0x18:uw             
        mov (1|M0)               r14.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mul (1|M0)               acc0.0<1>:ud  r86.2<0;1,0>:ud   r85.2<0;1,0>:uw 
        mach (1|M0)              r17.0<1>:ud   r86.2<0;1,0>:ud   r85.1<0;1,0>:ud  {AccWrEn}
        shl (1|M0)               r7.0<1>:d     r6.1<0;1,0>:d     8:w               {Compacted,I@6}
        mov (1|M0)               r16.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r86.2<0;1,0>:d    r85.4<0;1,0>:uw 
        mach (1|M0)              r18.0<1>:d    r86.2<0;1,0>:d    r85.2<0;1,0>:d  
(W)     mul (1|M0)               acc0.0<1>:d   r86.3<0;1,0>:d    r85.2<0;1,0>:uw 
        mach (1|M0)              r19.0<1>:d    r86.3<0;1,0>:d    r85.1<0;1,0>:d  
        addc (1|M0)              r21.0<1>:ud   r16.0<0;1,0>:ud   r85.3<0;1,0>:ud  {AccWrEn,I@5}
        add3 (1|M0)              r20.1<1>:d    r19.0<0;0>:d      r17.0<0;0>:d      r18.0<0>:d       {I@2}
        mov (1|M0)               r22.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        shl (1|M0)               r26.0<1>:d    r21.0<0;1,0>:d    8:w               {Compacted,I@3}
        add3 (1|M0)              r23.1<1>:d    r22.0<0;0>:d      r20.1<0;0>:d      r85.4<0>:d       {I@2}
        shr (1|M0)               r25.0<1>:ud   r21.0<0;1,0>:ud   0x18:uw             
        shl (1|M0)               r29.0<1>:d    r26.0<0;1,0>:d    1:w               {Compacted,I@3}
        shl (1|M0)               r24.0<1>:d    r23.1<0;1,0>:d    8:w               {Compacted,I@3}
        mov (1|M0)               r15.0<1>:f    r13.0<0;1,0>:f                   {Compacted}
        or (1|M0)                r9.1<1>:d     r7.0<0;1,0>:d     r8.0<0;1,0>:d    {Compacted}
        addc (1|M0)              r30.0<1>:ud   r3.2<0;1,0>:ud    r29.0<0;1,0>:ud  {AccWrEn,I@3}
        or (1|M0)                r26.1<1>:d    r24.0<0;1,0>:d    r25.0<0;1,0>:d   {Compacted,I@3}
        shr (1|M0)               r11.0<1>:ud   r9.0<0;1,0>:ud    0x1F:uw             
        shr (1|M0)               r28.0<1>:ud   r26.0<0;1,0>:ud   0x1F:uw             
        shl (1|M0)               r10.0<1>:d    r9.1<0;1,0>:d     1:w               {Compacted,I@5}
        mov (1|M0)               r31.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r32.0<1>:f    r30.0<0;1,0>:f                   {Compacted,I@6}
        shl (1|M0)               r27.0<1>:d    r26.1<0;1,0>:d    1:w               {Compacted,I@5}
        addc (1|M0)              r41.0<1>:ud   r15.0<0;1,0>:ud   0x100:ud              {AccWrEn,F@2}
        or (1|M0)                r12.1<1>:d    r10.0<0;1,0>:d    r11.0<0;1,0>:d   {Compacted,I@4}
        or (1|M0)                r29.1<1>:d    r27.0<0;1,0>:d    r28.0<0;1,0>:d   {Compacted,I@3}
        mov (1|M0)               r42.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r60.0<1>:ud   r32.0<0;1,0>:ud   0x100:ud              {AccWrEn,F@1}
        add3 (1|M0)              r15.1<1>:d    r14.0<0;0>:d      r3.1<0;0>:d       r12.1<0>:d       {I@4}
        add3 (1|M0)              r32.1<1>:d    r31.0<0;0>:d      r3.3<0;0>:d       r29.1<0>:d       {I@4}
        mov (1|M0)               r61.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r43.0<1>:f    r41.0<0;1,0>:f                   {Compacted}
        mov (1|M0)               r62.0<1>:f    r60.0<0;1,0>:f                   {Compacted,I@4}
        add3 (1|M0)              r43.1<1>:d    r42.0<0;0>:d      r15.1<0;0>:d      0:w               {I@3}
        add3 (1|M0)              r62.1<1>:d    r61.0<0;0>:d      r32.1<0;0>:d      0:w               {I@2}
        sync.nop                             null                             {Compacted,$2.src}
        send.ugm (1|M0)          r33      r15     null:0  0x0            0x0280E780           {$3} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        send.ugm (1|M0)          r52      r32     null:0  0x0            0x0280E780           {$4} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        send.ugm (1|M0)          r44      r43     null:0  0x0            0x0280E780           {A@2,$5} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        send.ugm (1|M0)          r63      r62     null:0  0x0            0x0280E780           {A@1,$6} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        addc (1|M0)              r71.0<1>:ud   r86.2<0;1,0>:ud   0x1:ud              {AccWrEn}
        mov (1|M0)               r72.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r86.4<1>:d    r71.0<0;1,0>:d                   {I@2}
        add3 (1|M0)              r86.5<1>:d    r72.0<0;0>:d      r86.3<0;0>:d      0:w               {I@2}
        cmp (1|M0)    (eq)f1.1   null<1>:d     r86.5<0;1,0>:d    r85.6<0;1,0>:d   {I@1}
(f1.1)  cmp (1|M0)    (eq)f1.1   null<1>:d     r86.4<0;1,0>:d    r85.5<0;1,0>:d  
(W)     and (1|M0)               f0.0<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
        sync.allwr                           ($2,$3,$4,$5,$6)                
        dpas.8x8 (8|M0)          r112:f        null:f            r112:hf           r112.0:hf        {Atomic}
        dpas.8x8 (8|M0)          r112:f        r112:f            r52:hf            r33.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r96:f         r96:f             r52:hf            r44.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r104:f        r104:f            r63:hf            r33.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r88:f         r88:f             r63:hf            r44.0:hf         {$2}
(f0.0.any16h) goto (16|M0)                   L1632                  L1632                
L1600:
(W)     mov (2|M0)               r86.2<1>:ud   r86.4<1;1,0>:ud                 
        goto.b (16|M0)                       L1632                  L760                
L1632:
        join (16|M0)                         L1648                                
L1648:
        shl (1|M0)               r85.0<1>:d    r85.0<0;1,0>:d    4:w               {Compacted}
        shl (1|M0)               r12.0<1>:d    r86.0<0;1,0>:d    4:w               {Compacted}
        mul (1|M0)               acc0.0<1>:d   r85.0<0;1,0>:d    r3.12<0;1,0>:uw  {Compacted,I@2}
        mach (1|M0)              r5.0<1>:d     r85.0<0;1,0>:d    r3.6<0;1,0>:d    {AccWrEn}
        shl (1|M0)               r14.0<1>:d    r12.0<0;1,0>:d    2:w               {Compacted,I@3}
        mov (1|M0)               r4.0<1>:d     acc0.0<0;1,0>:d                 
        shl (1|M0)               r23.0<1>:d    r3.6<0;1,0>:d     3:w               {Compacted}
        shl (1|M0)               r8.0<1>:d     r4.0<0;1,0>:d     2:w               {Compacted,I@2}
        shl (1|M0)               r26.0<1>:d    r23.0<0;1,0>:d    2:w               {Compacted,I@2}
        addc (1|M0)              r9.0<1>:ud    r3.4<0;1,0>:ud    r8.0<0;1,0>:ud   {AccWrEn,I@2}
        shl (1|M0)               r35.0<1>:d    r3.6<0;1,0>:d     2:w               {Compacted,$2.src}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r15.0<1>:ud   r9.0<0;1,0>:ud    r14.0<0;1,0>:ud  {AccWrEn,I@3}
        shl (1|M0)               r55.0<1>:d    r3.6<0;1,0>:d     1:w               {Compacted}
        mov (1|M0)               r17.0<1>:f    r15.0<0;1,0>:f                   {Compacted,I@2}
        mov (1|M0)               r16.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r18.0<1>:ud   r17.0<0;1,0>:ud   0x20:ud              {AccWrEn,F@1}
        shl (1|M0)               r58.0<1>:d    r55.0<0;1,0>:d    2:w               {Compacted,I@3}
        mov (1|M0)               r19.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r27.0<1>:ud   r17.0<0;1,0>:ud   r26.0<0;1,0>:ud  {AccWrEn}
        shr (1|M0)               r7.0<1>:ud    r4.0<0;1,0>:ud    0x1E:uw             
        mov (1|M0)               r29.0<1>:f    r27.0<0;1,0>:f                   {Compacted,I@2}
        mov (1|M0)               r28.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r30.0<1>:ud   r29.0<0;1,0>:ud   0x20:ud              {AccWrEn,F@1}
        shl (1|M0)               r6.0<1>:d     r5.0<0;1,0>:d     2:w               {Compacted}
        mov (1|M0)               r31.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r36.0<1>:ud   r17.0<0;1,0>:ud   r35.0<0;1,0>:ud  {AccWrEn}
        or (1|M0)                r8.1<1>:d     r6.0<0;1,0>:d     r7.0<0;1,0>:d    {Compacted,I@3}
        mov (1|M0)               r38.0<1>:f    r36.0<0;1,0>:f                   {Compacted,I@2}
        mov (1|M0)               r37.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r39.0<1>:ud   r38.0<0;1,0>:ud   0x20:ud              {AccWrEn,F@1}
        asr (1|M0)               r1.3<1>:d     r3.6<0;1,0>:d     31:w              
        mov (1|M0)               r40.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mul (1|M0)               acc0.0<1>:d   r3.6<0;1,0>:d     0x9:uw             
        mach (1|M0)              r43.0<1>:d    r3.6<0;1,0>:d     9:d               {AccWrEn}
        shr (1|M0)               r13.0<1>:ud   r12.0<0;1,0>:ud   0x1E:uw             
        mov (1|M0)               r42.0<1>:d    acc0.0<0;1,0>:d                 
        shr (1|M0)               r22.0<1>:ud   r3.6<0;1,0>:ud    0x1D:uw             
        shl (1|M0)               r46.0<1>:d    r42.0<0;1,0>:d    2:w               {Compacted,I@2}
        shl (1|M0)               r21.0<1>:d    r1.3<0;1,0>:d     3:w               {Compacted}
        addc (1|M0)              r47.0<1>:ud   r17.0<0;1,0>:ud   r46.0<0;1,0>:ud  {AccWrEn,I@2}
        add3 (1|M0)              r11.1<1>:d    r10.0<0;0>:d      r3.5<0;0>:d       r8.1<0>:d       
        mov (1|M0)               r49.0<1>:f    r47.0<0;1,0>:f                   {Compacted,I@2}
        mov (1|M0)               r48.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r50.0<1>:ud   r49.0<0;1,0>:ud   0x20:ud              {AccWrEn,F@1}
        or (1|M0)                r14.1<1>:d    r13.0<0;1,0>:d    0:w               {Compacted}
        mov (1|M0)               r51.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r59.0<1>:ud   r17.0<0;1,0>:ud   r58.0<0;1,0>:ud  {AccWrEn}
        or (1|M0)                r23.1<1>:d    r21.0<0;1,0>:d    r22.0<0;1,0>:d   {Compacted}
        mov (1|M0)               r61.0<1>:f    r59.0<0;1,0>:f                   {Compacted,I@2}
        mov (1|M0)               r60.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r62.0<1>:ud   r61.0<0;1,0>:ud   0x20:ud              {AccWrEn,F@1}
        shl (1|M0)               r21.0<1>:d    r35.0<0;1,0>:d    2:w               {Compacted}
        mov (1|M0)               r63.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mul (1|M0)               acc0.0<1>:d   r3.6<0;1,0>:d     0xA:uw             
        mach (1|M0)              r66.0<1>:d    r3.6<0;1,0>:d     10:d               {AccWrEn}
        shr (1|M0)               r25.0<1>:ud   r23.0<0;1,0>:ud   0x1E:uw             
        mov (1|M0)               r65.0<1>:d    acc0.0<0;1,0>:d                 
        add3 (1|M0)              r17.1<1>:d    r16.0<0;0>:d      r11.1<0;0>:d      r14.1<0>:d      
        shl (1|M0)               r69.0<1>:d    r65.0<0;1,0>:d    2:w               {Compacted,I@2}
        shl (1|M0)               r24.0<1>:d    r23.1<0;1,0>:d    2:w               {Compacted}
        addc (1|M0)              r70.0<1>:ud   r17.0<0;1,0>:ud   r69.0<0;1,0>:ud  {AccWrEn,I@2}
        or (1|M0)                r26.1<1>:d    r24.0<0;1,0>:d    r25.0<0;1,0>:d   {Compacted,I@2}
        mov (1|M0)               r72.0<1>:f    r70.0<0;1,0>:f                   {Compacted,I@2}
        mov (1|M0)               r71.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r73.0<1>:ud   r72.0<0;1,0>:ud   0x20:ud              {AccWrEn,F@1}
        mov (1|M0)               r20.0<1>:f    r18.0<0;1,0>:f                   {Compacted}
        mov (1|M0)               r74.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mul (1|M0)               acc0.0<1>:d   r3.6<0;1,0>:d     0x3:uw             
        mach (1|M0)              r77.0<1>:d    r3.6<0;1,0>:d     3:d               {AccWrEn}
        add3 (1|M0)              r20.1<1>:d    r19.0<0;0>:d      r17.1<0;0>:d      0:w              
        mov (1|M0)               r76.0<1>:d    acc0.0<0;1,0>:d                 
        add3 (1|M0)              r29.1<1>:d    r28.0<0;0>:d      r17.1<0;0>:d      r26.1<0>:d       {I@7}
        shl (1|M0)               r80.0<1>:d    r76.0<0;1,0>:d    2:w               {Compacted,I@2}
        send.ugm (1|M0)          null     r17     r112:1  0x0            0x0200C584           {$2} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        addc (1|M0)              r81.0<1>:ud   r17.0<0;1,0>:ud   r80.0<0;1,0>:ud  {AccWrEn,I@1}
        sync.nop                             null                             {Compacted,F@1}
        send.ugm (1|M0)          null     r20     r104:1  0x0            0x0200C584           {$7} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        mov (1|M0)               r83.0<1>:f    r81.0<0;1,0>:f                   {Compacted,I@1}
        mov (1|M0)               r82.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r4.0<1>:ud    r83.0<0;1,0>:ud   0x20:ud              {AccWrEn,F@1}
        send.ugm (1|M0)          null     r29     r96:1   0x0            0x0200C584           {$8} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mul (1|M0)               acc0.0<1>:d   r3.6<0;1,0>:d     0xB:uw             
        mach (1|M0)              r8.0<1>:d     r3.6<0;1,0>:d     11:d               {AccWrEn}
        mov (1|M0)               r32.0<1>:f    r30.0<0;1,0>:f                   {Compacted}
        mov (1|M0)               r7.0<1>:d     acc0.0<0;1,0>:d                 
        add3 (1|M0)              r32.1<1>:d    r31.0<0;0>:d      r29.1<0;0>:d      0:w              
        shl (1|M0)               r11.0<1>:d    r7.0<0;1,0>:d     2:w               {Compacted,I@2}
        send.ugm (1|M0)          null     r32     r88:1   0x0            0x0200C584           {A@1,$9} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        addc (1|M0)              r12.0<1>:ud   r17.0<0;1,0>:ud   r11.0<0;1,0>:ud  {AccWrEn,I@1}
        shr (1|M0)               r34.0<1>:ud   r3.6<0;1,0>:ud    0x1E:uw             
        mov (1|M0)               r14.0<1>:f    r12.0<0;1,0>:f                   {Compacted,I@2}
        mov (1|M0)               r13.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r15.0<1>:ud   r14.0<0;1,0>:ud   0x20:ud              {AccWrEn,F@1}
        shl (1|M0)               r33.0<1>:d    r1.3<0;1,0>:d     2:w               {Compacted}
        mov (1|M0)               r16.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r22.0<1>:ud   r17.0<0;1,0>:ud   r21.0<0;1,0>:ud  {AccWrEn}
        or (1|M0)                r35.1<1>:d    r33.0<0;1,0>:d    r34.0<0;1,0>:d   {Compacted,I@3}
        mov (1|M0)               r24.0<1>:f    r22.0<0;1,0>:f                   {Compacted,I@2}
        mov (1|M0)               r23.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r25.0<1>:ud   r24.0<0;1,0>:ud   0x20:ud              {AccWrEn,F@1}
        shr (1|M0)               r20.0<1>:ud   r35.0<0;1,0>:ud   0x1E:uw              {$7.src}
        mov (1|M0)               r26.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mul (1|M0)               acc0.0<1>:d   r3.6<0;1,0>:d     0xC:uw             
        mach (1|M0)              r29.0<1>:d    r3.6<0;1,0>:d     12:d               {AccWrEn,$8.src}
        add3 (1|M0)              r38.1<1>:d    r37.0<0;0>:d      r17.1<0;0>:d      r35.1<0>:d       {I@7}
        mov (1|M0)               r28.0<1>:d    acc0.0<0;1,0>:d                 
        add3 (1|M0)              r41.1<1>:d    r40.0<0;0>:d      r38.1<0;0>:d      0:w               {I@2}
        sync.nop                             null                             {Compacted,$9.src}
        shl (1|M0)               r32.0<1>:d    r28.0<0;1,0>:d    2:w               {Compacted,I@2}
        mov (1|M0)               r41.0<1>:f    r39.0<0;1,0>:f                   {Compacted}
        addc (1|M0)              r33.0<1>:ud   r17.0<0;1,0>:ud   r32.0<0;1,0>:ud  {AccWrEn,I@1}
        shl (1|M0)               r44.0<1>:d    r43.0<0;1,0>:d    2:w               {Compacted}
        mov (1|M0)               r35.0<1>:f    r33.0<0;1,0>:f                   {Compacted,I@2}
        mov (1|M0)               r34.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r36.0<1>:ud   r35.0<0;1,0>:ud   0x20:ud              {AccWrEn,F@1}
        shr (1|M0)               r45.0<1>:ud   r42.0<0;1,0>:ud   0x1E:uw             
        mov (1|M0)               r37.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mul (1|M0)               acc0.0<1>:d   r3.6<0;1,0>:d     0x5:uw             
        mach (1|M0)              r40.0<1>:d    r3.6<0;1,0>:d     5:d               {AccWrEn}
        or (1|M0)                r46.1<1>:d    r44.0<0;1,0>:d    r45.0<0;1,0>:d   {Compacted,I@4}
        mov (1|M0)               r39.0<1>:d    acc0.0<0;1,0>:d                 
        add3 (1|M0)              r49.1<1>:d    r48.0<0;0>:d      r17.1<0;0>:d      r46.1<0>:d       {I@2}
        shl (1|M0)               r43.0<1>:d    r39.0<0;1,0>:d    2:w               {Compacted,I@2}
        add3 (1|M0)              r52.1<1>:d    r51.0<0;0>:d      r49.1<0;0>:d      0:w               {I@2}
        addc (1|M0)              r44.0<1>:ud   r17.0<0;1,0>:ud   r43.0<0;1,0>:ud  {AccWrEn,I@2}
        shr (1|M0)               r54.0<1>:ud   r3.6<0;1,0>:ud    0x1F:uw             
        mov (1|M0)               r46.0<1>:f    r44.0<0;1,0>:f                   {Compacted,I@2}
        mov (1|M0)               r45.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r47.0<1>:ud   r46.0<0;1,0>:ud   0x20:ud              {AccWrEn,F@1}
        shl (1|M0)               r53.0<1>:d    r1.3<0;1,0>:d     1:w               {Compacted}
        mov (1|M0)               r48.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mul (1|M0)               acc0.0<1>:d   r3.6<0;1,0>:d     0xD:uw             
        mach (1|M0)              r51.0<1>:d    r3.6<0;1,0>:d     13:d               {AccWrEn}
        mov (1|M0)               r52.0<1>:f    r50.0<0;1,0>:f                   {Compacted}
        mov (1|M0)               r50.0<1>:d    acc0.0<0;1,0>:d                  {F@1}
        or (1|M0)                r55.1<1>:d    r53.0<0;1,0>:d    r54.0<0;1,0>:d   {Compacted,I@5}
        shl (1|M0)               r54.0<1>:d    r50.0<0;1,0>:d    2:w               {Compacted,I@2}
        shr (1|M0)               r57.0<1>:ud   r55.0<0;1,0>:ud   0x1E:uw             
        shl (1|M0)               r56.0<1>:d    r55.1<0;1,0>:d    2:w               {Compacted,I@3}
        addc (1|M0)              r55.0<1>:ud   r17.0<0;1,0>:ud   r54.0<0;1,0>:ud  {AccWrEn,I@3}
        or (1|M0)                r58.1<1>:d    r56.0<0;1,0>:d    r57.0<0;1,0>:d   {Compacted,I@2}
        mov (1|M0)               r57.0<1>:f    r55.0<0;1,0>:f                   {Compacted,A@1}
        mov (1|M0)               r56.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r58.0<1>:ud   r57.0<0;1,0>:ud   0x20:ud              {AccWrEn,F@1}
        mov (1|M0)               r64.0<1>:f    r62.0<0;1,0>:f                   {Compacted}
        mov (1|M0)               r59.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mul (1|M0)               acc0.0<1>:d   r3.6<0;1,0>:d     0x6:uw             
        add3 (1|M0)              r61.1<1>:d    r60.0<0;0>:d      r17.1<0;0>:d      r58.1<0>:d      
        mach (1|M0)              r62.0<1>:d    r3.6<0;1,0>:d     6:d               {AccWrEn,F@1}
        send.ugm (1|M0)          null     r38     r113:1  0x0            0x0200C584           {$10} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r41     r105:1  0x0            0x0200C584           {$11} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r49     r97:1   0x0            0x0200C584           {$12} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r52     r89:1   0x0            0x0200C584           {$13} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r61     r114:1  0x0            0x0200C584           {A@2,$14} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        mov (1|M0)               r61.0<1>:d    acc0.0<0;1,0>:d                  {$14.src}
        shr (1|M0)               r68.0<1>:ud   r65.0<0;1,0>:ud   0x1E:uw             
        shl (1|M0)               r65.0<1>:d    r61.0<0;1,0>:d    2:w               {Compacted,I@2}
        shl (1|M0)               r67.0<1>:d    r66.0<0;1,0>:d    2:w               {Compacted}
        addc (1|M0)              r66.0<1>:ud   r17.0<0;1,0>:ud   r65.0<0;1,0>:ud  {AccWrEn,I@2}
        or (1|M0)                r69.1<1>:d    r67.0<0;1,0>:d    r68.0<0;1,0>:d   {Compacted,I@2}
        mov (1|M0)               r68.0<1>:f    r66.0<0;1,0>:f                   {Compacted,A@1}
        mov (1|M0)               r67.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r69.0<1>:ud   r68.0<0;1,0>:ud   0x20:ud              {AccWrEn,F@1}
        mov (1|M0)               r75.0<1>:f    r73.0<0;1,0>:f                   {Compacted}
        mov (1|M0)               r70.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mul (1|M0)               acc0.0<1>:d   r3.6<0;1,0>:d     0xE:uw             
        add3 (1|M0)              r64.1<1>:d    r63.0<0;0>:d      r61.1<0;0>:d      0:w              
        add3 (1|M0)              r72.1<1>:d    r71.0<0;0>:d      r17.1<0;0>:d      r69.1<0>:d      
        mach (1|M0)              r73.0<1>:d    r3.6<0;1,0>:d     14:d               {AccWrEn,F@1}
        send.ugm (1|M0)          null     r64     r106:1  0x0            0x0200C584           {A@3,$15} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r72     r98:1   0x0            0x0200C584           {A@2,$0} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        mov (1|M0)               r72.0<1>:d    acc0.0<0;1,0>:d                  {$0.src}
        shr (1|M0)               r79.0<1>:ud   r76.0<0;1,0>:ud   0x1E:uw             
        shl (1|M0)               r76.0<1>:d    r72.0<0;1,0>:d    2:w               {Compacted,I@2}
        shl (1|M0)               r78.0<1>:d    r77.0<0;1,0>:d    2:w               {Compacted}
        addc (1|M0)              r77.0<1>:ud   r17.0<0;1,0>:ud   r76.0<0;1,0>:ud  {AccWrEn,I@2}
        or (1|M0)                r80.1<1>:d    r78.0<0;1,0>:d    r79.0<0;1,0>:d   {Compacted,I@2}
        mov (1|M0)               r79.0<1>:f    r77.0<0;1,0>:f                   {Compacted,A@1}
        mov (1|M0)               r78.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r80.0<1>:ud   r79.0<0;1,0>:ud   0x20:ud              {AccWrEn,F@1}
        add3 (1|M0)              r75.1<1>:d    r74.0<0;0>:d      r72.1<0;0>:d      0:w              
        mov (1|M0)               r81.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mul (1|M0)               acc0.0<1>:d   r3.6<0;1,0>:d     0x7:uw             
        add3 (1|M0)              r83.1<1>:d    r82.0<0;0>:d      r17.1<0;0>:d      r80.1<0>:d      
        mach (1|M0)              r84.0<1>:d    r3.6<0;1,0>:d     7:d               {AccWrEn}
        send.ugm (1|M0)          null     r75     r90:1   0x0            0x0200C584           {A@5,$1} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r83     r115:1  0x0            0x0200C584           {A@2,$2} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        mov (1|M0)               r83.0<1>:d    acc0.0<0;1,0>:d                  {$2.src}
        mov (1|M0)               r6.0<1>:f     r4.0<0;1,0>:f                    {Compacted}
        shl (1|M0)               r4.0<1>:d     r83.0<0;1,0>:d    2:w               {Compacted,A@1}
        add3 (1|M0)              r6.1<1>:d     r5.0<0;0>:d       r83.1<0;0>:d      0:w              
        addc (1|M0)              r5.0<1>:ud    r17.0<0;1,0>:ud   r4.0<0;1,0>:ud   {AccWrEn,I@2}
        shr (1|M0)               r10.0<1>:ud   r7.0<0;1,0>:ud    0x1E:uw             
        mov (1|M0)               r7.0<1>:f     r5.0<0;1,0>:f                    {Compacted,A@1}
        send.ugm (1|M0)          null     r6      r107:1  0x0            0x0200C584           {$3} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        shl (1|M0)               r9.0<1>:d     r8.0<0;1,0>:d     2:w               {Compacted}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$3.src}
        addc (1|M0)              r8.0<1>:ud    r7.0<0;1,0>:ud    0x20:ud              {AccWrEn,F@1}
        or (1|M0)                r11.1<1>:d    r9.0<0;1,0>:d     r10.0<0;1,0>:d   {Compacted,I@3}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mul (1|M0)               acc0.0<1>:d   r3.6<0;1,0>:d     0xF:uw             
        mach (1|M0)              r12.0<1>:d    r3.6<0;1,0>:d     15:d               {AccWrEn}
        mov (1|M0)               r18.0<1>:f    r15.0<0;1,0>:f                   {Compacted}
        mov (1|M0)               r11.0<1>:d    acc0.0<0;1,0>:d                 
        add3 (1|M0)              r14.1<1>:d    r13.0<0;0>:d      r17.1<0;0>:d      r11.1<0>:d       {I@5}
        shl (1|M0)               r15.0<1>:d    r11.0<0;1,0>:d    2:w               {Compacted,A@1}
        shl (1|M0)               r19.0<1>:d    r35.1<0;1,0>:d    2:w               {Compacted}
        add3 (1|M0)              r18.1<1>:d    r16.0<0;0>:d      r14.1<0;0>:d      0:w               {I@3}
        addc (1|M0)              r16.0<1>:ud   r17.0<0;1,0>:ud   r15.0<0;1,0>:ud  {AccWrEn,I@3}
        send.ugm (1|M0)          null     r14     r99:1   0x0            0x0200C584           {$4} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        shl (1|M0)               r30.0<1>:d    r29.0<0;1,0>:d    2:w               {Compacted}
        shr (1|M0)               r31.0<1>:ud   r28.0<0;1,0>:ud   0x1E:uw             
        shr (1|M0)               r42.0<1>:ud   r39.0<0;1,0>:ud   0x1E:uw             
        shr (1|M0)               r53.0<1>:ud   r50.0<0;1,0>:ud   0x1E:uw             
        shl (1|M0)               r41.0<1>:d    r40.0<0;1,0>:d    2:w               {Compacted,$11.src}
        shl (1|M0)               r52.0<1>:d    r51.0<0;1,0>:d    2:w               {Compacted,$13.src}
        shl (1|M0)               r63.0<1>:d    r62.0<0;1,0>:d    2:w               {Compacted}
        shr (1|M0)               r64.0<1>:ud   r61.0<0;1,0>:ud   0x1E:uw              {$15.src}
        shl (1|M0)               r74.0<1>:d    r73.0<0;1,0>:d    2:w               {Compacted}
        shr (1|M0)               r75.0<1>:ud   r72.0<0;1,0>:ud   0x1E:uw              {$1.src}
        shl (1|M0)               r1.2<1>:d     r84.0<0;1,0>:d    2:w               {Compacted}
        shr (1|M0)               r2.3<1>:ud    r83.0<0;1,0>:ud   0x1E:uw             
        shl (1|M0)               r13.0<1>:d    r12.0<0;1,0>:d    2:w               {Compacted}
        or (1|M0)                r21.1<1>:d    r19.0<0;1,0>:d    r20.0<0;1,0>:d   {Compacted}
        shr (1|M0)               r14.0<1>:ud   r11.0<0;1,0>:ud   0x1E:uw              {$4.src}
        mov (1|M0)               r19.0<1>:f    r16.0<0;1,0>:f                   {Compacted,I@2}
        send.ugm (1|M0)          null     r18     r91:1   0x0            0x0200C584           {$5} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        or (1|M0)                r32.1<1>:d    r30.0<0;1,0>:d    r31.0<0;1,0>:d   {Compacted}
        or (1|M0)                r43.1<1>:d    r41.0<0;1,0>:d    r42.0<0;1,0>:d   {Compacted}
        or (1|M0)                r54.1<1>:d    r52.0<0;1,0>:d    r53.0<0;1,0>:d   {Compacted}
        or (1|M0)                r65.1<1>:d    r63.0<0;1,0>:d    r64.0<0;1,0>:d   {Compacted}
        or (1|M0)                r76.1<1>:d    r74.0<0;1,0>:d    r75.0<0;1,0>:d   {Compacted}
        or (1|M0)                r4.1<1>:d     r1.2<0;1,0>:d     r2.3<0;1,0>:d   
        or (1|M0)                r15.1<1>:d    r13.0<0;1,0>:d    r14.0<0;1,0>:d   {Compacted,I@7}
        mov (1|M0)               r18.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,$5.src}
        addc (1|M0)              r20.0<1>:ud   r19.0<0;1,0>:ud   0x20:ud              {AccWrEn,F@1}
        add3 (1|M0)              r24.1<1>:d    r23.0<0;0>:d      r17.1<0;0>:d      r21.1<0>:d      
        add3 (1|M0)              r35.1<1>:d    r34.0<0;0>:d      r17.1<0;0>:d      r32.1<0>:d       {I@7}
        add3 (1|M0)              r46.1<1>:d    r45.0<0;0>:d      r17.1<0;0>:d      r43.1<0>:d       {I@7}
        add3 (1|M0)              r57.1<1>:d    r56.0<0;0>:d      r17.1<0;0>:d      r54.1<0>:d       {I@7}
        add3 (1|M0)              r68.1<1>:d    r67.0<0;0>:d      r17.1<0;0>:d      r65.1<0>:d       {I@7}
        add3 (1|M0)              r79.1<1>:d    r78.0<0;0>:d      r17.1<0;0>:d      r76.1<0>:d       {I@7}
        add3 (1|M0)              r7.1<1>:d     r6.0<0;0>:d       r17.1<0;0>:d      r4.1<0>:d        {I@7}
        add3 (1|M0)              r19.1<1>:d    r18.0<0;0>:d      r17.1<0;0>:d      r15.1<0>:d       {I@7}
        mov (1|M0)               r21.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r27.0<1>:f    r25.0<0;1,0>:f                   {Compacted}
        mov (1|M0)               r60.0<1>:f    r58.0<0;1,0>:f                   {Compacted}
        mov (1|M0)               r38.0<1>:f    r36.0<0;1,0>:f                   {Compacted,$10.src}
        mov (1|M0)               r49.0<1>:f    r47.0<0;1,0>:f                   {Compacted,$12.src}
        mov (1|M0)               r71.0<1>:f    r69.0<0;1,0>:f                   {Compacted}
        mov (1|M0)               r82.0<1>:f    r80.0<0;1,0>:f                   {Compacted}
        mov (1|M0)               r10.0<1>:f    r8.0<0;1,0>:f                    {Compacted}
        mov (1|M0)               r22.0<1>:f    r20.0<0;1,0>:f                   {Compacted,I@7}
        add3 (1|M0)              r27.1<1>:d    r26.0<0;0>:d      r24.1<0;0>:d      0:w               {I@7}
        add3 (1|M0)              r38.1<1>:d    r37.0<0;0>:d      r35.1<0;0>:d      0:w               {I@7}
        add3 (1|M0)              r49.1<1>:d    r48.0<0;0>:d      r46.1<0;0>:d      0:w               {I@7}
        add3 (1|M0)              r60.1<1>:d    r59.0<0;0>:d      r57.1<0;0>:d      0:w               {I@7}
        add3 (1|M0)              r71.1<1>:d    r70.0<0;0>:d      r68.1<0;0>:d      0:w               {I@7}
        add3 (1|M0)              r82.1<1>:d    r81.0<0;0>:d      r79.1<0;0>:d      0:w               {I@7}
        add3 (1|M0)              r10.1<1>:d    r9.0<0;0>:d       r7.1<0;0>:d       0:w               {I@7}
        add3 (1|M0)              r22.1<1>:d    r21.0<0;0>:d      r19.1<0;0>:d      0:w               {I@7}
        send.ugm (1|M0)          null     r24     r116:1  0x0            0x0200C584           {$6} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r27     r108:1  0x0            0x0200C584           {A@7,$7} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r35     r100:1  0x0            0x0200C584           {$8} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r38     r92:1   0x0            0x0200C584           {A@6,$9} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r46     r117:1  0x0            0x0200C584           {$11} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r49     r109:1  0x0            0x0200C584           {A@5,$13} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r57     r101:1  0x0            0x0200C584           {$14} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r60     r93:1   0x0            0x0200C584           {A@5,$15} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r68     r118:1  0x0            0x0200C584           {$0} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r71     r110:1  0x0            0x0200C584           {A@4,$1} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r79     r102:1  0x0            0x0200C584           {$2} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r82     r94:1   0x0            0x0200C584           {A@3,$3} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r7      r119:1  0x0            0x0200C584           {$4} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r10     r111:1  0x0            0x0200C584           {A@2,$10} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r19     r103:1  0x0            0x0200C584           {$12} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r22     r95:1   0x0            0x0200C584           {A@1,$5} // wr:1+1, rd:0; store.ugm.d32x8t.a64
(W)     mov (8|M0)               r127.0<1>:f   r0.0<1;1,0>:f                    {Compacted}
(W)     send.ugm (1|M0)          r23      r0      null:0  0x0            0x0210641F           {$6} // wr:1+0, rd:1; fence invalid flush type scoped to tile
(W)     mov (8|M0)               null<1>:ud    r23.0<1;1,0>:ud                  {$6.dst}
(W)     send.gtwy (1|M0)         null     r127    null:0  0x0            0x02000010           {EOT,A@1} // wr:1+0, rd:0; end of thread
L5168:
        mov (1|M0)               r1.2<1>:d     cr0.0<0;1,0>:ud                  {A@1}
        and (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   -1265:w               {A@1}
        or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   1264:w               {A@1}
        mov (1|M0)               r3.7<1>:f     (abs)r87.5<0;1,0>:d              {A@1}
        mov (1|M0)               r10.0<1>:f    0xB4C00000:f                               {Compacted}
        math.inv (1|M0)          r9.0<1>:f     r3.7<0;1,0>:f                    {@2,$7}
        mov (1|M0)               r6.0<1>:f     (abs)r87.4<0;1,0>:d              {Compacted}
        sync.nop                             null                             {Compacted,$7.dst}
        mad (1|M0)               r9.0<1>:f     r9.0<0;0>:f       r10.0<0;0>:f      r9.0<0>:f        {F@2}
        mov (2|M0)               r2.4<1>:d     (abs)r87.4<1;1,0>:d             
        mov (1|M0)               r4.0<1>:ud    r3.7<0;1,0>:f                   
        mov (1|M0)               r7.0<1>:ud    r6.0<0;1,0>:f                    {F@2}
        mul (1|M0)               r11.0<1>:f    r9.0<0;1,0>:f     r6.0<0;1,0>:f    {Compacted,F@1}
        add (1|M0)               r4.0<1>:ud    r2.5<0;1,0>:ud    -r4.0<0;1,0>:ud  {Compacted,I@2}
        add (1|M0)               r7.0<1>:ud    r2.4<0;1,0>:ud    -r7.0<0;1,0>:ud  {Compacted,I@2}
        mov (1|M0)               r12.0<1>:ud   r11.0<0;1,0>:f                   {F@1}
        mov (1|M0)               r5.0<1>:f     r4.0<0;1,0>:ud                   {Compacted,I@3}
        mov (1|M0)               r8.0<1>:f     r7.0<0;1,0>:ud                   {Compacted,I@2}
        mov (1|M0)               r13.0<1>:f    r12.0<0;1,0>:ud                  {Compacted,I@1}
(W)     mov (1|M0)               r16.0<1>:hf   0x1:hf                             
        mad (1|M0)               r6.0<1>:f     r6.0<0;0>:f       r13.0<0;0>:f      -r3.7<0>:f       {F@2}
        mad (1|M0)               r13.0<1>:f    r8.0<0;0>:f       r13.0<0;0>:f      -r5.0<0>:f      
        xor (1|M0)               r87.5<1>:d    r87.5<0;1,0>:d    r87.4<0;1,0>:d  
        add (1|M0)               r6.0<1>:f     r6.0<0;1,0>:f     r13.0<0;1,0>:f   {Compacted,F@1}
        asr (1|M0)               r87.5<1>:d    r87.5<0;1,0>:d    31:w               {I@1}
        mul (1|M0)               r9.0<1>:f     r9.0<0;1,0>:f     r6.0<0;1,0>:f    {Compacted,F@1}
        mov (1|M0)               r14.0<1>:ud   r9.0<0;1,0>:f                    {F@1}
        add (1|M0)               r12.0<1>:ud   r12.0<0;1,0>:ud   r14.0<0;1,0>:ud  {Compacted,I@1}
(W)     mul (1|M0)               acc0.0<1>:ud  r12.0<0;1,0>:ud   r2.10<0;1,0>:uw  {I@1}
        mach (1|M0)              r15.0<1>:ud   r12.0<0;1,0>:ud   r2.5<0;1,0>:ud   {Compacted}
        add (1|M0)               r2.4<1>:ud    r2.4<0;1,0>:ud    -r15.0<0;1,0>:ud {I@1}
        cmp (1|M0)    (ge)f0.0   null<1>:ud    r2.4<0;1,0>:ud    r2.5<0;1,0>:ud   {I@1}
(f0.0)  sel (1|M0)               r17.0<1>:d    r16.0<0;1,0>:w    0:w              
        add3 (1|M0)              r12.0<1>:d    r12.0<0;0>:d      r87.5<0;0>:d      r17.0<0>:d       {I@1}
        xor (1|M0)               r85.0<1>:d    r12.0<0;1,0>:d    r87.5<0;1,0>:d   {Compacted,I@1}
        mov (1|M0)               cr0.0<1>:ud   r1.2<0;1,0>:d                    {A@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        ret (16|M0)                          r86.6                            {A@1}
L5680:
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
