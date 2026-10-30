L0:
(W)     mov (8|M0)               r127.0<1>:ud  0x0:ud                              {A@1}
(W)     and (1|M0)               r127.2<1>:ud  r0.0<0;1,0>:ud    0xFFFFFFC0:ud             
(W)     and (1|M0)               r127.0<1>:uw  r0.4<0;1,0>:uw    0xFF:uw             
(W)     add (1|M0)               r127.2<1>:ud  r127.2<0;1,0>:ud  0x80:ud              {I@2}
(W)     mad (1|M0)               r127.2<1>:ud  r127.2<0;0>:ud    r127.0<0;0>:uw    0x20:uw              {I@1}
(W)     send.dc0 (8|M0)          r1       r127    null:0  0x0            0x021842FD           {A@1,$0} // wr:1h+0, rd:1; oword aligned block read x2
        nop                    
        nop                    
(W)     mov (8|M0)               r127.0<1>:ud  0x0:ud                              {$0.src}
(W)     and (1|M0)               r127.2<1>:ud  r0.0<0;1,0>:ud    0xFFFFFFC0:ud             
(W)     send.dc0 (8|M0)          r2       r127    null:0  0x0            0x024844FD           {A@1,$1} // wr:1h+0, rd:4; oword aligned block read x8
        and (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   -1265:w               {A@1}
        or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   1216:w               {A@1}
        sync.nop                             null                             {Compacted,A@1}
        sync.nop                             null                             {Compacted,$1.dst}
        mul (1|M0)               acc0.0<1>:ud  r2.3<0;1,0>:ud    r0.2<0;1,0>:uw   {A@1}
        mach (1|M0)              r7.0<1>:ud    r2.3<0;1,0>:ud    r0.1<0;1,0>:ud   {AccWrEn}
        mov (1|M0)               r1.2<1>:d     r1.0<0;1,0>:uw                   {$0.dst}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
(W)     mov (1|M0)               r1.3<1>:hf    0x1:hf                             
        addc (1|M0)              r8.0<1>:ud    r6.0<0;1,0>:ud    r1.2<0;1,0>:ud   {AccWrEn,I@1}
        mov (1|M0)               r50.2<1>:d    r8.0<0;1,0>:d                    {I@1}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        cmp (1|M0)    (lt)f0.1   null<1>:ud    r50.2<0;1,0>:ud   r3.0<0;1,0>:ud   {I@2}
        add3 (1|M0)              r50.3<1>:d    r9.0<0;0>:d       r7.0<0;0>:d       0:w               {I@2}
        mul (1|M0)               acc0.0<1>:ud  r2.0<0;1,0>:ud    r2.6<0;1,0>:uw  
        cmp (1|M0)    (lt)f0.0   null<1>:ud    r50.3<0;1,0>:ud   r3.1<0;1,0>:ud   {I@2}
(f0.1)  cmp (1|M0)    (eq)f0.1   null<1>:d     r50.3<0;1,0>:d    r3.1<0;1,0>:d   
        mach (1|M0)              r11.0<1>:ud   r2.0<0;1,0>:ud    r2.3<0;1,0>:ud   {AccWrEn}
(f0.0)  sel (1|M0)               r2.12<1>:uw   r1.3<0;1,0>:uw    0x0:uw              {F@1}
(f0.1)  sel (1|M0)               r1.4<1>:uw    r1.3<0;1,0>:uw    0x0:uw             
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        or (1|M0)     (ne)f1.0   null<1>:uw    r1.4<0;1,0>:uw    r2.12<0;1,0>:uw  {I@2}
        mov (1|M0)               r46.1<1>:d    r11.0<0;1,0>:d                  
        mov (1|M0)               r46.0<1>:f    r10.0<0;1,0>:f                   {Compacted,I@3}
(W)     and (1|M0)               f1.1<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
(~f1.1.any16h) goto (16|M0)                  L6488                  L6488                
L544:
        mul (1|M0)               acc0.0<1>:d   r5.0<0;1,0>:d     0x9:uw             
        mach (1|M0)              r7.0<1>:d     r5.0<0;1,0>:d     9:d               {AccWrEn}
        asr (1|M0)               r1.3<1>:d     r5.0<0;1,0>:d     31:w               {Compacted}
        mov (1|M0)               r6.0<1>:d     acc0.0<0;1,0>:d                 
        mul (1|M0)               acc0.0<1>:d   r5.0<0;1,0>:d     0xA:uw             
        mach (1|M0)              r9.0<1>:d     r5.0<0;1,0>:d     10:d               {AccWrEn}
        mov (1|M0)               r46.3<1>:d    r7.0<0;1,0>:d                    {I@5}
        mov (1|M0)               r8.0<1>:d     acc0.0<0;1,0>:d                 
        mul (1|M0)               acc0.0<1>:d   r5.0<0;1,0>:d     0x3:uw             
        mach (1|M0)              r11.0<1>:d    r5.0<0;1,0>:d     3:d               {AccWrEn}
        mov (1|M0)               r46.2<1>:d    r6.0<0;1,0>:d                    {I@7}
        mov (1|M0)               r10.0<1>:d    acc0.0<0;1,0>:d                  {F@1}
        mul (1|M0)               acc0.0<1>:d   r5.0<0;1,0>:d     0xB:uw             
        mach (1|M0)              r7.0<1>:d     r5.0<0;1,0>:d     11:d               {AccWrEn}
        mov (1|M0)               r46.5<1>:d    r9.0<0;1,0>:d                    {I@7}
        mov (1|M0)               r6.0<1>:d     acc0.0<0;1,0>:d                 
        mul (1|M0)               acc0.0<1>:d   r5.0<0;1,0>:d     0xC:uw             
        mach (1|M0)              r9.0<1>:d     r5.0<0;1,0>:d     12:d               {AccWrEn}
        mov (1|M0)               r46.4<1>:d    r8.0<0;1,0>:d                    {I@7}
        mov (1|M0)               r8.0<1>:d     acc0.0<0;1,0>:d                 
        mul (1|M0)               acc0.0<1>:d   r5.0<0;1,0>:d     0x5:uw             
        mov (1|M0)               r46.7<1>:d    r11.0<0;1,0>:d                  
        mach (1|M0)              r11.0<1>:d    r5.0<0;1,0>:d     5:d               {AccWrEn}
        mov (1|M0)               r46.6<1>:d    r10.0<0;1,0>:d                  
        mov (1|M0)               r10.0<1>:d    acc0.0<0;1,0>:d                 
        mul (1|M0)               acc0.0<1>:d   r5.0<0;1,0>:d     0xD:uw             
        mov (1|M0)               r47.1<1>:d    r7.0<0;1,0>:d                   
        mach (1|M0)              r7.0<1>:d     r5.0<0;1,0>:d     13:d               {AccWrEn}
        mov (1|M0)               r47.0<1>:f    r6.0<0;1,0>:f                    {Compacted}
        mov (1|M0)               r6.0<1>:d     acc0.0<0;1,0>:d                  {F@1}
        mul (1|M0)               acc0.0<1>:d   r5.0<0;1,0>:d     0x6:uw             
        mov (1|M0)               r47.3<1>:d    r9.0<0;1,0>:d                   
        mach (1|M0)              r9.0<1>:d     r5.0<0;1,0>:d     6:d               {AccWrEn}
        mov (1|M0)               r47.2<1>:d    r8.0<0;1,0>:d                   
        mov (1|M0)               r8.0<1>:d     acc0.0<0;1,0>:d                 
        mul (1|M0)               acc0.0<1>:d   r5.0<0;1,0>:d     0xE:uw             
        mov (1|M0)               r47.5<1>:d    r11.0<0;1,0>:d                  
        mach (1|M0)              r11.0<1>:d    r5.0<0;1,0>:d     14:d               {AccWrEn}
        mov (1|M0)               r47.4<1>:d    r10.0<0;1,0>:d                  
        mov (1|M0)               r10.0<1>:d    acc0.0<0;1,0>:d                 
        mul (1|M0)               acc0.0<1>:d   r5.0<0;1,0>:d     0x7:uw             
        mov (1|M0)               r47.7<1>:d    r7.0<0;1,0>:d                   
        mach (1|M0)              r7.0<1>:d     r5.0<0;1,0>:d     7:d               {AccWrEn}
        mov (1|M0)               r47.6<1>:d    r6.0<0;1,0>:d                   
        mov (1|M0)               r6.0<1>:d     acc0.0<0;1,0>:d                 
        mul (1|M0)               acc0.0<1>:d   r5.0<0;1,0>:d     0xF:uw             
        shr (1|M0)               r2.7<1>:ud    r5.0<0;1,0>:ud    0x1F:uw             
        shl (1|M0)               r2.6<1>:d     r1.3<0;1,0>:d     1:w              
        mov (1|M0)               r48.1<1>:d    r9.0<0;1,0>:d                   
        mach (1|M0)              r9.0<1>:d     r5.0<0;1,0>:d     15:d               {AccWrEn}
        shr (1|M0)               r1.5<1>:ud    r5.0<0;1,0>:ud    0x1D:uw             
        shl (1|M0)               r1.4<1>:d     r1.3<0;1,0>:d     3:w              
        mov (1|M0)               r48.0<1>:f    r8.0<0;1,0>:f                    {Compacted}
        or (1|M0)                r50.1<1>:d    r2.6<0;1,0>:d     r2.7<0;1,0>:d    {I@5}
        mov (1|M0)               r8.0<1>:d     acc0.0<0;1,0>:d                  {F@1}
        shl (1|M0)               r2.6<1>:d     r1.3<0;1,0>:d     2:w              
        shr (1|M0)               r2.7<1>:ud    r5.0<0;1,0>:ud    0x1E:uw             
        mov (1|M0)               r49.0<1>:f    r4.0<0;1,0>:f                    {Compacted}
        asr (1|M0)               r49.1<1>:d    r4.0<0;1,0>:d     31:w               {Compacted}
        shl (1|M0)               r49.4<1>:d    r5.0<0;1,0>:d     3:w               {Compacted}
        shl (1|M0)               r50.0<1>:d    r5.0<0;1,0>:d     1:w               {Compacted}
        shl (1|M0)               r49.6<1>:d    r5.0<0;1,0>:d     2:w               {Compacted}
        mov (1|M0)               r49.2<1>:d    r4.1<0;1,0>:d                   
        mov (1|M0)               r49.3<1>:d    0:w                              
        mov (1|M0)               r48.3<1>:d    r11.0<0;1,0>:d                  
        mov (1|M0)               r48.2<1>:d    r10.0<0;1,0>:d                  
        mov (1|M0)               r48.5<1>:d    r7.0<0;1,0>:d                   
        mov (1|M0)               r48.4<1>:d    r6.0<0;1,0>:d                   
        mov (1|M0)               r48.7<1>:d    r9.0<0;1,0>:d                   
        or (1|M0)                r49.5<1>:d    r1.4<0;1,0>:d     r1.5<0;1,0>:d   
        mov (1|M0)               r48.6<1>:d    r8.0<0;1,0>:d                   
        or (1|M0)                r49.7<1>:d    r2.6<0;1,0>:d     r2.7<0;1,0>:d   
L1632:
        mov (1|M0)               r52.4<1>:d    r50.2<0;1,0>:d                  
        mov (1|M0)               r52.5<1>:d    r4.0<0;1,0>:d                   
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r52.2         L6560                                 {A@1}
L1712:
        cmp (1|M0)    (gt)f0.1   null<1>:d     r4.1<0;1,0>:d     0:w              
(W)     mul (1|M0)               acc0.0<1>:d   r50.4<0;1,0>:d    r4.0<0;1,0>:uw   {Compacted}
        mach (1|M0)              r51.0<1>:d    r50.4<0;1,0>:d    r4.0<0;1,0>:d    {Compacted}
        mov (16|M0)              r53.0<1>:ud   0x0:ud                             
(W)     and (1|M0)               f1.0<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
        mov (16|M0)              r55.0<1>:ud   0x0:ud                             
        mov (16|M0)              r57.0<1>:ud   0x0:ud                             
        mov (16|M0)              r59.0<1>:ud   0x0:ud                             
        mov (16|M0)              r61.0<1>:ud   0x0:ud                             
        mov (16|M0)              r63.0<1>:ud   0x0:ud                             
        mov (16|M0)              r65.0<1>:ud   0x0:ud                             
        mov (16|M0)              r67.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r69.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r71.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r73.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r75.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r77.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r79.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r81.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r83.0<1>:f    0.0:f                               {Compacted}
        add (1|M0)               r51.0<1>:d    r50.2<0;1,0>:d    -r51.0<0;1,0>:d  {Compacted,I@7}
(~f1.0.any16h) goto (16|M0)                  L3008                  L3008                
L1968:
(W)     mul (1|M0)               acc0.0<1>:d   r50.4<0;1,0>:d    r4.2<0;1,0>:uw  
        mach (1|M0)              r6.0<1>:d     r50.4<0;1,0>:d    r4.1<0;1,0>:d   
(W)     mul (1|M0)               acc0.0<1>:d   r50.4<0;1,0>:d    r4.2<0;1,0>:uw  
        mov (1|M0)               r50.5<1>:d    r51.0<0;1,0>:d                   {I@5}
        asr (1|M0)               r50.6<1>:d    r51.0<0;1,0>:d    31:w               {Compacted}
        mov (1|M0)               r51.2<2>:f    0.0:f                              
        mov (1|M0)               r51.3<2>:f    0.0:f                              
        mach (1|M0)              r52.0<1>:d    r50.4<0;1,0>:d    r4.1<0;1,0>:d   
        asr (1|M0)               r52.1<1>:d    r6.0<0;1,0>:d     31:w               {Compacted,I@5}
L2096:
        addc (1|M0)              r6.0<1>:ud    r51.2<0;1,0>:ud   r52.0<0;1,0>:ud  {AccWrEn,A@2}
        shl (1|M0)               r3.2<1>:d     r6.0<0;1,0>:d     8:w               {Compacted,I@1}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        shl (1|M0)               r5.1<1>:d     r3.2<0;1,0>:d     1:w               {I@2}
        add3 (1|M0)              r1.3<1>:d     r7.0<0;0>:d       r51.3<0;0>:d      r52.1<0>:d       {A@1}
        addc (1|M0)              r8.0<1>:ud    r4.2<0;1,0>:ud    r5.1<0;1,0>:ud   {AccWrEn,I@2}
        shr (1|M0)               r2.7<1>:ud    r6.0<0;1,0>:ud    0x18:uw             
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mul (1|M0)               acc0.0<1>:ud  r51.2<0;1,0>:ud   r49.0<0;1,0>:uw 
        mach (1|M0)              r12.0<1>:ud   r51.2<0;1,0>:ud   r49.0<0;1,0>:ud  {AccWrEn}
        shl (1|M0)               r2.6<1>:d     r1.3<0;1,0>:d     8:w               {I@6}
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r51.2<0;1,0>:d    r49.2<0;1,0>:uw 
        mach (1|M0)              r6.0<1>:d     r51.2<0;1,0>:d    r49.1<0;1,0>:d  
(W)     mul (1|M0)               acc0.0<1>:d   r51.3<0;1,0>:d    r49.0<0;1,0>:uw  {Compacted}
        or (1|M0)                r3.3<1>:d     r2.6<0;1,0>:d     r2.7<0;1,0>:d    {I@5}
        mach (1|M0)              r7.0<1>:d     r51.3<0;1,0>:d    r49.0<0;1,0>:d   {Compacted}
        addc (1|M0)              r13.0<1>:ud   r11.0<0;1,0>:ud   r50.5<0;1,0>:ud  {AccWrEn,I@6}
        shr (1|M0)               r3.5<1>:ud    r3.2<0;1,0>:ud    0x1F:uw             
        shl (1|M0)               r3.4<1>:d     r3.3<0;1,0>:d     1:w               {I@4}
        add3 (1|M0)              r1.3<1>:d     r7.0<0;0>:d       r12.0<0;0>:d      r6.0<0>:d        {I@4}
        mov (1|M0)               r14.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,$7.src}
        or (1|M0)                r5.2<1>:d     r3.4<0;1,0>:d     r3.5<0;1,0>:d    {I@3}
        add3 (1|M0)              r2.7<1>:d     r14.0<0;0>:d      r1.3<0;0>:d       r50.6<0>:d       {I@2}
        shl (1|M0)               r3.4<1>:d     r13.0<0;1,0>:d    8:w               {Compacted}
        shr (1|M0)               r3.3<1>:ud    r13.0<0;1,0>:ud   0x18:uw             
        shl (1|M0)               r3.2<1>:d     r2.7<0;1,0>:d     8:w               {I@3}
        shl (1|M0)               r5.3<1>:d     r3.4<0;1,0>:d     1:w               {I@3}
        mov (1|M0)               r10.0<1>:f    r8.0<0;1,0>:f                    {Compacted}
        or (1|M0)                r3.5<1>:d     r3.2<0;1,0>:d     r3.3<0;1,0>:d    {I@2}
        addc (1|M0)              r6.0<1>:ud    r4.4<0;1,0>:ud    r5.3<0;1,0>:ud   {AccWrEn,I@2}
        add3 (1|M0)              r10.1<1>:d    r9.0<0;0>:d       r4.3<0;0>:d       r5.2<0>:d       
        shl (1|M0)               r5.1<1>:d     r3.5<0;1,0>:d     1:w               {I@3}
        shr (1|M0)               r5.2<1>:ud    r3.4<0;1,0>:ud    0x1F:uw             
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r8.0<1>:f     r6.0<0;1,0>:f                    {Compacted,I@5}
        addc (1|M0)              r9.0<1>:ud    r10.0<0;1,0>:ud   0x100:ud              {AccWrEn,F@2}
        or (1|M0)                r5.4<1>:d     r5.1<0;1,0>:d     r5.2<0;1,0>:d    {I@3}
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r6.0<1>:ud    r8.0<0;1,0>:ud    0x100:ud              {AccWrEn,F@1}
        add3 (1|M0)              r8.1<1>:d     r7.0<0;0>:d       r4.5<0;0>:d       r5.4<0>:d        {I@3}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r12.0<1>:f    r9.0<0;1,0>:f                    {Compacted}
        add3 (1|M0)              r12.1<1>:d    r11.0<0;0>:d      r10.1<0;0>:d      0:w               {I@4}
        mov (1|M0)               r13.0<1>:f    r6.0<0;1,0>:f                    {Compacted,I@4}
        add3 (1|M0)              r13.1<1>:d    r7.0<0;0>:d       r8.1<0;0>:d       0:w               {I@2}
        send.ugm (1|M0)          r14      r10     null:0  0x0            0x0280E780           {$8} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        send.ugm (1|M0)          r30      r8      null:0  0x0            0x0280E780           {$9} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        send.ugm (1|M0)          r22      r12     null:0  0x0            0x0280E780           {A@2,$10} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        send.ugm (1|M0)          r38      r13     null:0  0x0            0x0280E780           {A@1,$11} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        addc (1|M0)              r9.0<1>:ud    r51.2<0;1,0>:ud   0x1:ud              {AccWrEn}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,$8.src}
        mov (1|M0)               r51.4<1>:d    r9.0<0;1,0>:d                    {I@2}
        add3 (1|M0)              r51.5<1>:d    r10.0<0;0>:d      r51.3<0;0>:d      0:w               {I@2}
        cmp (1|M0)    (eq)f1.1   null<1>:d     r51.5<0;1,0>:d    r49.3<0;1,0>:d   {I@1}
(f1.1)  cmp (1|M0)    (eq)f1.1   null<1>:d     r51.4<0;1,0>:d    r49.2<0;1,0>:d  
(W)     and (1|M0)               f0.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
        sync.allwr                           ($7,$8,$9,$10,$11)                
        dpas.8x8 (8|M0)          r77:f         r77:f             r30:hf            r14.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r61:f         r61:f             r30:hf            r22.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r69:f         r69:f             r38:hf            r14.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r53:f         r53:f             r38:hf            r22.0:hf         {$7}
(f0.1.any16h) goto (16|M0)                   L3008                  L3008                
L2976:
(W)     mov (2|M0)               r51.2<1>:ud   r51.4<1;1,0>:ud                 
        goto.b (16|M0)                       L3008                  L2096                
L3008:
        join (16|M0)                         L6488                                
L3024:
        shl (1|M0)               r50.4<1>:d    r50.4<0;1,0>:d    4:w              
        shl (1|M0)               r3.2<1>:d     r51.0<0;1,0>:d    4:w               {Compacted}
        mul (1|M0)               acc0.0<1>:d   r50.4<0;1,0>:d    r5.0<0;1,0>:uw   {Compacted,I@2}
        mach (1|M0)              r7.0<1>:d     r50.4<0;1,0>:d    r5.0<0;1,0>:d    {AccWrEn}
        shl (1|M0)               r5.1<1>:d     r3.2<0;1,0>:d     2:w               {I@3}
        mov (1|M0)               r6.0<1>:d     acc0.0<0;1,0>:d                 
        shl (1|M0)               r1.2<1>:d     r7.0<0;1,0>:d     2:w               {Compacted,I@3}
        shl (1|M0)               r1.4<1>:d     r6.0<0;1,0>:d     2:w               {Compacted,I@2}
        shr (1|M0)               r1.3<1>:ud    r6.0<0;1,0>:ud    0x1E:uw             
        addc (1|M0)              r8.0<1>:ud    r4.6<0;1,0>:ud    r1.4<0;1,0>:ud   {AccWrEn,I@2}
        shr (1|M0)               r3.4<1>:ud    r3.2<0;1,0>:ud    0x1E:uw             
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r10.0<1>:ud   r8.0<0;1,0>:ud    r5.1<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d   
        mov (1|M0)               r12.0<1>:f    r10.0<0;1,0>:f                   {Compacted,I@2}
        shl (1|M0)               r1.4<1>:d     r49.4<0;1,0>:d    2:w              
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r6.0<1>:ud    r12.0<0;1,0>:ud   0x20:ud              {AccWrEn,F@1}
        or (1|M0)                r5.2<1>:d     r3.4<0;1,0>:d     0:w              
        add3 (1|M0)              r2.7<1>:d     r9.0<0;0>:d       r4.7<0;0>:d       r1.5<0>:d        {I@5}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r8.0<1>:ud    r12.0<0;1,0>:ud   r1.4<0;1,0>:ud   {AccWrEn,I@6}
        add3 (1|M0)              r12.1<1>:d    r11.0<0;0>:d      r2.7<0;0>:d       r5.2<0>:d        {I@3}
        mov (1|M0)               r11.0<1>:f    r8.0<0;1,0>:f                    {Compacted,A@1}
        mov (1|M0)               r9.0<1>:f     r6.0<0;1,0>:f                    {Compacted}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r6.0<1>:ud    r11.0<0;1,0>:ud   0x20:ud              {AccWrEn,A@1}
        shl (1|M0)               r1.2<1>:d     r49.5<0;1,0>:d    2:w              
        shr (1|M0)               r1.3<1>:ud    r49.4<0;1,0>:ud   0x1E:uw             
        add3 (1|M0)              r9.1<1>:d     r7.0<0;0>:d       r12.1<0;0>:d      0:w              
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r13.0<1>:ud   r12.0<0;1,0>:ud   r49.6<0;1,0>:ud  {AccWrEn}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@4}
        sync.nop                             null                             {Compacted,$7.src}
        mov (1|M0)               r15.0<1>:f    r13.0<0;1,0>:f                   {Compacted,I@2}
        shl (1|M0)               r1.4<1>:d     r46.2<0;1,0>:d    2:w              
        mov (1|M0)               r14.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        add3 (1|M0)              r11.1<1>:d    r10.0<0;0>:d      r12.1<0;0>:d      r1.5<0>:d        {I@3}
        addc (1|M0)              r8.0<1>:ud    r15.0<0;1,0>:ud   0x20:ud              {AccWrEn,F@1}
        sync.nop                             null                             {Compacted,$7.dst}
        send.ugm (1|M0)          null     r12     r77:1   0x0            0x0200C584           {$5} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r9      r69:1   0x0            0x0200C584           {$12} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r9.0<1>:f     r6.0<0;1,0>:f                    {Compacted,$12.src}
        add3 (1|M0)              r9.1<1>:d     r7.0<0;0>:d       r11.1<0;0>:d      0:w               {I@3}
        addc (1|M0)              r6.0<1>:ud    r12.0<0;1,0>:ud   r1.4<0;1,0>:ud   {AccWrEn,F@1}
        send.ugm (1|M0)          null     r11     r61:1   0x0            0x0200C584           {$13} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r9      r53:1   0x0            0x0200C584           {A@2,$14} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        sync.nop                             null                             {Compacted,$14.src}
        mov (1|M0)               r9.0<1>:f     r6.0<0;1,0>:f                    {Compacted,I@1}
        shl (1|M0)               r3.2<1>:d     r50.0<0;1,0>:d    2:w               {Compacted}
        add3 (1|M0)              r15.1<1>:d    r14.0<0;0>:d      r12.1<0;0>:d      r49.7<0>:d      
        mov (1|M0)               r16.0<1>:f    r8.0<0;1,0>:f                    {Compacted}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r8.0<1>:ud    r9.0<0;1,0>:ud    0x20:ud              {AccWrEn,A@1}
        shl (1|M0)               r1.2<1>:d     r46.3<0;1,0>:d    2:w              
        shr (1|M0)               r1.3<1>:ud    r46.2<0;1,0>:ud   0x1E:uw             
        add3 (1|M0)              r16.1<1>:d    r10.0<0;0>:d      r15.1<0;0>:d      0:w               {I@5}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r6.0<1>:ud    r12.0<0;1,0>:ud   r3.2<0;1,0>:ud   {AccWrEn}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@4}
        mov (1|M0)               r13.0<1>:f    r6.0<0;1,0>:f                    {Compacted,I@2}
        shl (1|M0)               r1.4<1>:d     r46.4<0;1,0>:d    2:w              
        mov (1|M0)               r11.0<1>:f    r8.0<0;1,0>:f                    {Compacted,$13.src}
        add3 (1|M0)              r9.1<1>:d     r7.0<0;0>:d       r12.1<0;0>:d      r1.5<0>:d        {I@2}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r8.0<1>:ud    r13.0<0;1,0>:ud   0x20:ud              {AccWrEn,A@1}
        send.ugm (1|M0)          null     r15     r78:1   0x0            0x0200C584           {$3} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r16     r70:1   0x0            0x0200C584           {$6} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r9      r62:1   0x0            0x0200C584           {A@3,$15} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        shl (1|M0)               r2.6<1>:d     r50.1<0;1,0>:d    2:w              
        shr (1|M0)               r2.7<1>:ud    r50.0<0;1,0>:ud   0x1E:uw             
        add3 (1|M0)              r11.1<1>:d    r10.0<0;0>:d      r9.1<0;0>:d       0:w              
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$15.src}
        addc (1|M0)              r6.0<1>:ud    r12.0<0;1,0>:ud   r1.4<0;1,0>:ud   {AccWrEn}
        send.ugm (1|M0)          null     r11     r54:1   0x0            0x0200C584           {A@3,$0} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        or (1|M0)                r3.3<1>:d     r2.6<0;1,0>:d     r2.7<0;1,0>:d   
        sync.nop                             null                             {Compacted,$0.src}
        mov (1|M0)               r11.0<1>:f    r6.0<0;1,0>:f                    {Compacted,I@2}
        shl (1|M0)               r3.2<1>:d     r46.6<0;1,0>:d    2:w              
        mov (1|M0)               r10.0<1>:f    r8.0<0;1,0>:f                    {Compacted}
        add3 (1|M0)              r13.1<1>:d    r7.0<0;0>:d       r12.1<0;0>:d      r3.3<0>:d        {I@2}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r8.0<1>:ud    r11.0<0;1,0>:ud   0x20:ud              {AccWrEn,A@1}
        shl (1|M0)               r1.2<1>:d     r46.5<0;1,0>:d    2:w              
        shr (1|M0)               r1.3<1>:ud    r46.4<0;1,0>:ud   0x1E:uw             
        add3 (1|M0)              r10.1<1>:d    r9.0<0;0>:d       r13.1<0;0>:d      0:w               {I@5}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r6.0<1>:ud    r12.0<0;1,0>:ud   r3.2<0;1,0>:ud   {AccWrEn}
        send.ugm (1|M0)          null     r13     r79:1   0x0            0x0200C584           {$1} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@4}
        sync.nop                             null                             {Compacted,$1.src}
        mov (1|M0)               r13.0<1>:f    r6.0<0;1,0>:f                    {Compacted,I@2}
        send.ugm (1|M0)          null     r10     r71:1   0x0            0x0200C584           {$7} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        shl (1|M0)               r1.4<1>:d     r47.0<0;1,0>:d    2:w               {Compacted}
        add3 (1|M0)              r11.1<1>:d    r7.0<0;0>:d       r12.1<0;0>:d      r1.5<0>:d        {I@2}
        mov (1|M0)               r10.0<1>:f    r8.0<0;1,0>:f                    {Compacted,$7.src}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r8.0<1>:ud    r13.0<0;1,0>:ud   0x20:ud              {AccWrEn,A@1}
        shl (1|M0)               r2.6<1>:d     r46.7<0;1,0>:d    2:w              
        shr (1|M0)               r2.7<1>:ud    r46.6<0;1,0>:ud   0x1E:uw             
        add3 (1|M0)              r10.1<1>:d    r9.0<0;0>:d       r11.1<0;0>:d      0:w               {I@5}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r6.0<1>:ud    r12.0<0;1,0>:ud   r1.4<0;1,0>:ud   {AccWrEn}
        send.ugm (1|M0)          null     r11     r63:1   0x0            0x0200C584           {$8} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        or (1|M0)                r3.3<1>:d     r2.6<0;1,0>:d     r2.7<0;1,0>:d    {I@4}
        sync.nop                             null                             {Compacted,$8.src}
        mov (1|M0)               r11.0<1>:f    r6.0<0;1,0>:f                    {Compacted,I@2}
        send.ugm (1|M0)          null     r10     r55:1   0x0            0x0200C584           {$9} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        shl (1|M0)               r3.2<1>:d     r49.6<0;1,0>:d    2:w              
        add3 (1|M0)              r13.1<1>:d    r7.0<0;0>:d       r12.1<0;0>:d      r3.3<0>:d        {I@2}
        mov (1|M0)               r10.0<1>:f    r8.0<0;1,0>:f                    {Compacted,$9.src}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r8.0<1>:ud    r11.0<0;1,0>:ud   0x20:ud              {AccWrEn,A@1}
        shl (1|M0)               r1.2<1>:d     r47.1<0;1,0>:d    2:w              
        shr (1|M0)               r1.3<1>:ud    r47.0<0;1,0>:ud   0x1E:uw             
        add3 (1|M0)              r10.1<1>:d    r9.0<0;0>:d       r13.1<0;0>:d      0:w               {I@5}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r6.0<1>:ud    r12.0<0;1,0>:ud   r3.2<0;1,0>:ud   {AccWrEn}
        send.ugm (1|M0)          null     r13     r80:1   0x0            0x0200C584           {$10} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@4}
        sync.nop                             null                             {Compacted,$10.src}
        mov (1|M0)               r13.0<1>:f    r6.0<0;1,0>:f                    {Compacted,I@2}
        send.ugm (1|M0)          null     r10     r72:1   0x0            0x0200C584           {$11} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        shl (1|M0)               r1.4<1>:d     r47.2<0;1,0>:d    2:w              
        add3 (1|M0)              r11.1<1>:d    r7.0<0;0>:d       r12.1<0;0>:d      r1.5<0>:d        {I@2}
        mov (1|M0)               r10.0<1>:f    r8.0<0;1,0>:f                    {Compacted,$11.src}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r8.0<1>:ud    r13.0<0;1,0>:ud   0x20:ud              {AccWrEn,A@1}
        shl (1|M0)               r2.6<1>:d     r49.7<0;1,0>:d    2:w              
        shr (1|M0)               r2.7<1>:ud    r49.6<0;1,0>:ud   0x1E:uw             
        add3 (1|M0)              r10.1<1>:d    r9.0<0;0>:d       r11.1<0;0>:d      0:w               {I@5}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r6.0<1>:ud    r12.0<0;1,0>:ud   r1.4<0;1,0>:ud   {AccWrEn}
        send.ugm (1|M0)          null     r11     r64:1   0x0            0x0200C584           {$12} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        or (1|M0)                r3.3<1>:d     r2.6<0;1,0>:d     r2.7<0;1,0>:d    {I@4}
        sync.nop                             null                             {Compacted,$12.src}
        mov (1|M0)               r11.0<1>:f    r6.0<0;1,0>:f                    {Compacted,I@2}
        send.ugm (1|M0)          null     r10     r56:1   0x0            0x0200C584           {$13} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        shl (1|M0)               r3.2<1>:d     r47.4<0;1,0>:d    2:w              
        add3 (1|M0)              r13.1<1>:d    r7.0<0;0>:d       r12.1<0;0>:d      r3.3<0>:d        {I@2}
        mov (1|M0)               r10.0<1>:f    r8.0<0;1,0>:f                    {Compacted,$13.src}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r8.0<1>:ud    r11.0<0;1,0>:ud   0x20:ud              {AccWrEn,A@1}
        shl (1|M0)               r1.2<1>:d     r47.3<0;1,0>:d    2:w              
        shr (1|M0)               r1.3<1>:ud    r47.2<0;1,0>:ud   0x1E:uw             
        add3 (1|M0)              r10.1<1>:d    r9.0<0;0>:d       r13.1<0;0>:d      0:w               {I@5}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r6.0<1>:ud    r12.0<0;1,0>:ud   r3.2<0;1,0>:ud   {AccWrEn}
        send.ugm (1|M0)          null     r13     r81:1   0x0            0x0200C584           {$14} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@4}
        sync.nop                             null                             {Compacted,$14.src}
        mov (1|M0)               r13.0<1>:f    r6.0<0;1,0>:f                    {Compacted,I@2}
        send.ugm (1|M0)          null     r10     r73:1   0x0            0x0200C584           {$15} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        shl (1|M0)               r1.4<1>:d     r47.6<0;1,0>:d    2:w              
        add3 (1|M0)              r11.1<1>:d    r7.0<0;0>:d       r12.1<0;0>:d      r1.5<0>:d        {I@2}
        mov (1|M0)               r10.0<1>:f    r8.0<0;1,0>:f                    {Compacted,$15.src}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r8.0<1>:ud    r13.0<0;1,0>:ud   0x20:ud              {AccWrEn,A@1}
        shl (1|M0)               r2.6<1>:d     r47.5<0;1,0>:d    2:w              
        shr (1|M0)               r2.7<1>:ud    r47.4<0;1,0>:ud   0x1E:uw             
        add3 (1|M0)              r10.1<1>:d    r9.0<0;0>:d       r11.1<0;0>:d      0:w               {I@5}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r6.0<1>:ud    r12.0<0;1,0>:ud   r1.4<0;1,0>:ud   {AccWrEn}
        send.ugm (1|M0)          null     r11     r65:1   0x0            0x0200C584           {$0} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        or (1|M0)                r3.3<1>:d     r2.6<0;1,0>:d     r2.7<0;1,0>:d    {I@4}
        sync.nop                             null                             {Compacted,$0.src}
        mov (1|M0)               r11.0<1>:f    r6.0<0;1,0>:f                    {Compacted,I@2}
        send.ugm (1|M0)          null     r10     r57:1   0x0            0x0200C584           {$1} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        shl (1|M0)               r3.2<1>:d     r48.0<0;1,0>:d    2:w               {Compacted}
        add3 (1|M0)              r13.1<1>:d    r7.0<0;0>:d       r12.1<0;0>:d      r3.3<0>:d        {I@2}
        mov (1|M0)               r10.0<1>:f    r8.0<0;1,0>:f                    {Compacted,$1.src}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r8.0<1>:ud    r11.0<0;1,0>:ud   0x20:ud              {AccWrEn,A@1}
        shl (1|M0)               r1.2<1>:d     r47.7<0;1,0>:d    2:w              
        shr (1|M0)               r1.3<1>:ud    r47.6<0;1,0>:ud   0x1E:uw             
        add3 (1|M0)              r10.1<1>:d    r9.0<0;0>:d       r13.1<0;0>:d      0:w               {I@5}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r6.0<1>:ud    r12.0<0;1,0>:ud   r3.2<0;1,0>:ud   {AccWrEn}
        send.ugm (1|M0)          null     r13     r82:1   0x0            0x0200C584           {$7} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@4}
        sync.nop                             null                             {Compacted,$7.src}
        mov (1|M0)               r13.0<1>:f    r6.0<0;1,0>:f                    {Compacted,I@2}
        send.ugm (1|M0)          null     r10     r74:1   0x0            0x0200C584           {$8} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        shl (1|M0)               r1.4<1>:d     r48.2<0;1,0>:d    2:w              
        add3 (1|M0)              r11.1<1>:d    r7.0<0;0>:d       r12.1<0;0>:d      r1.5<0>:d        {I@2}
        mov (1|M0)               r10.0<1>:f    r8.0<0;1,0>:f                    {Compacted,$8.src}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r8.0<1>:ud    r13.0<0;1,0>:ud   0x20:ud              {AccWrEn,A@1}
        shl (1|M0)               r2.6<1>:d     r48.1<0;1,0>:d    2:w              
        shr (1|M0)               r2.7<1>:ud    r48.0<0;1,0>:ud   0x1E:uw             
        add3 (1|M0)              r10.1<1>:d    r9.0<0;0>:d       r11.1<0;0>:d      0:w               {I@5}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r6.0<1>:ud    r12.0<0;1,0>:ud   r1.4<0;1,0>:ud   {AccWrEn}
        send.ugm (1|M0)          null     r11     r66:1   0x0            0x0200C584           {$9} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        or (1|M0)                r3.3<1>:d     r2.6<0;1,0>:d     r2.7<0;1,0>:d    {I@4}
        sync.nop                             null                             {Compacted,$9.src}
        mov (1|M0)               r11.0<1>:f    r6.0<0;1,0>:f                    {Compacted,I@2}
        send.ugm (1|M0)          null     r10     r58:1   0x0            0x0200C584           {$10} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        shl (1|M0)               r3.2<1>:d     r48.4<0;1,0>:d    2:w              
        add3 (1|M0)              r13.1<1>:d    r7.0<0;0>:d       r12.1<0;0>:d      r3.3<0>:d        {I@2}
        mov (1|M0)               r10.0<1>:f    r8.0<0;1,0>:f                    {Compacted,$10.src}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r8.0<1>:ud    r11.0<0;1,0>:ud   0x20:ud              {AccWrEn,A@1}
        shl (1|M0)               r1.2<1>:d     r48.3<0;1,0>:d    2:w              
        shr (1|M0)               r1.3<1>:ud    r48.2<0;1,0>:ud   0x1E:uw             
        add3 (1|M0)              r10.1<1>:d    r9.0<0;0>:d       r13.1<0;0>:d      0:w               {I@5}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r6.0<1>:ud    r12.0<0;1,0>:ud   r3.2<0;1,0>:ud   {AccWrEn}
        send.ugm (1|M0)          null     r13     r83:1   0x0            0x0200C584           {$11} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@4}
        sync.nop                             null                             {Compacted,$11.src}
        mov (1|M0)               r13.0<1>:f    r6.0<0;1,0>:f                    {Compacted,I@2}
        send.ugm (1|M0)          null     r10     r75:1   0x0            0x0200C584           {$12} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        shl (1|M0)               r1.4<1>:d     r48.6<0;1,0>:d    2:w              
        add3 (1|M0)              r11.1<1>:d    r7.0<0;0>:d       r12.1<0;0>:d      r1.5<0>:d        {I@2}
        mov (1|M0)               r10.0<1>:f    r8.0<0;1,0>:f                    {Compacted,$12.src}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r8.0<1>:ud    r13.0<0;1,0>:ud   0x20:ud              {AccWrEn,A@1}
        shl (1|M0)               r2.6<1>:d     r48.5<0;1,0>:d    2:w              
        shr (1|M0)               r2.7<1>:ud    r48.4<0;1,0>:ud   0x1E:uw             
        add3 (1|M0)              r10.1<1>:d    r9.0<0;0>:d       r11.1<0;0>:d      0:w               {I@5}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r6.0<1>:ud    r12.0<0;1,0>:ud   r1.4<0;1,0>:ud   {AccWrEn}
        send.ugm (1|M0)          null     r11     r67:1   0x0            0x0200C584           {$13} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        or (1|M0)                r3.3<1>:d     r2.6<0;1,0>:d     r2.7<0;1,0>:d    {I@4}
        sync.nop                             null                             {Compacted,$13.src}
        mov (1|M0)               r11.0<1>:f    r6.0<0;1,0>:f                    {Compacted,I@2}
        send.ugm (1|M0)          null     r10     r59:1   0x0            0x0200C584           {$14} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        add3 (1|M0)              r13.1<1>:d    r7.0<0;0>:d       r12.1<0;0>:d      r3.3<0>:d        {I@1}
        mov (1|M0)               r10.0<1>:f    r8.0<0;1,0>:f                    {Compacted,$14.src}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r8.0<1>:ud    r11.0<0;1,0>:ud   0x20:ud              {AccWrEn,A@1}
        send.ugm (1|M0)          null     r13     r84:1   0x0            0x0200C584           {A@3,$15} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        add3 (1|M0)              r10.1<1>:d    r9.0<0;0>:d       r13.1<0;0>:d      0:w              
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r13.0<1>:ud   r50.2<0;1,0>:ud   r46.0<0;1,0>:ud  {AccWrEn,$15.src}
(W)     mov (1|M0)               r1.3<1>:hf    0x1:hf                             
        mov (1|M0)               r51.6<1>:d    r13.0<0;1,0>:d                   {I@1}
        mov (1|M0)               r14.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        cmp (1|M0)    (lt)f0.0   null<1>:ud    r51.6<0;1,0>:ud   r3.0<0;1,0>:ud   {I@2}
        add3 (1|M0)              r51.7<1>:d    r14.0<0;0>:d      r50.3<0;0>:d      r46.1<0>:d       {I@2}
        shl (1|M0)               r1.2<1>:d     r48.7<0;1,0>:d    2:w              
        cmp (1|M0)    (lt)f1.1   null<1>:ud    r51.7<0;1,0>:ud   r3.1<0;1,0>:ud   {I@2}
(f0.0)  cmp (1|M0)    (eq)f0.0   null<1>:d     r51.7<0;1,0>:d    r3.1<0;1,0>:d   
        shr (1|M0)               r1.3<1>:ud    r48.6<0;1,0>:ud   0x1E:uw             
        send.ugm (1|M0)          null     r10     r76:1   0x0            0x0200C584           {$0} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@1}
(f1.1)  sel (1|M0)               r2.12<1>:uw   r1.3<0;1,0>:uw    0x0:uw              {F@1}
(f0.0)  sel (1|M0)               r1.4<1>:uw    r1.3<0;1,0>:uw    0x0:uw             
        add3 (1|M0)              r11.1<1>:d    r7.0<0;0>:d       r12.1<0;0>:d      r1.5<0>:d        {I@3}
        or (1|M0)     (ne)f0.0   null<1>:uw    r1.4<0;1,0>:uw    r2.12<0;1,0>:uw  {I@2}
        mov (1|M0)               r10.0<1>:f    r8.0<0;1,0>:f                    {Compacted,$0.src}
        add3 (1|M0)              r10.1<1>:d    r9.0<0;0>:d       r11.1<0;0>:d      0:w               {I@2}
        send.ugm (1|M0)          null     r11     r68:1   0x0            0x0200C584           {$4} // wr:1+1, rd:0; store.ugm.d32x8t.a64
(W)     and (1|M0)               f0.0<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
        send.ugm (1|M0)          null     r10     r60:1   0x0            0x0200C584           {A@1,$2} // wr:1+1, rd:0; store.ugm.d32x8t.a64
(~f0.0.any16h) goto (16|M0)                  L6488                  L6488                
L6456:
(W)     mov (2|M0)               r50.2<1>:ud   r51.6<1;1,0>:ud                 
        goto.b (16|M0)                       L6488                  L1632                
L6488:
        join (16|M0)                         L6504                                
L6504:
(W)     mov (8|M0)               r127.0<1>:f   r0.0<1;1,0>:f                    {Compacted}
(W)     send.ugm (1|M0)          r6       r0      null:0  0x0            0x0210641F           {$1} // wr:1+0, rd:1; fence invalid flush type scoped to tile
(W)     mov (8|M0)               null<1>:ud    r6.0<1;1,0>:ud                   {$1.dst}
(W)     send.gtwy (1|M0)         null     r127    null:0  0x0            0x02000010           {EOT,A@1} // wr:1+0, rd:0; end of thread
L6560:
        mov (1|M0)               r1.2<1>:d     cr0.0<0;1,0>:ud                  {A@1}
        and (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   -1265:w               {A@1}
        or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   1264:w               {A@1}
        mov (1|M0)               r1.3<1>:f     (abs)r52.5<0;1,0>:d              {A@1}
        mov (1|M0)               r5.3<1>:f     0xB4C00000:f                               {Compacted}
        math.inv (1|M0)          r5.2<1>:f     r1.3<0;1,0>:f                    {@2,$7}
        mov (1|M0)               r2.7<1>:f     (abs)r52.4<0;1,0>:d             
        sync.nop                             null                             {Compacted,$7.dst}
        mad (1|M0)               r5.2<1>:f     r5.2<0;0>:f       r5.3<0;0>:f       r5.2<0>:f        {F@2}
        mov (2|M0)               r1.4<1>:d     (abs)r52.4<1;1,0>:d             
        mov (1|M0)               r1.6<1>:ud    r1.3<0;1,0>:f                   
        mov (1|M0)               r3.2<1>:ud    r2.7<0;1,0>:f                    {F@2}
        mul (1|M0)               r6.0<1>:f     r5.2<0;1,0>:f     r2.7<0;1,0>:f    {A@1}
        add (1|M0)               r1.6<1>:ud    r1.5<0;1,0>:ud    -r1.6<0;1,0>:ud  {I@2}
        add (1|M0)               r3.2<1>:ud    r1.4<0;1,0>:ud    -r3.2<0;1,0>:ud  {I@2}
        mov (1|M0)               r7.0<1>:ud    r6.0<0;1,0>:f                    {F@1}
        mov (1|M0)               r2.6<1>:f     r1.6<0;1,0>:ud                   {I@3}
        mov (1|M0)               r5.1<1>:f     r3.2<0;1,0>:ud                   {I@2}
        mov (1|M0)               r7.1<1>:f     r7.0<0;1,0>:ud                   {Compacted,I@1}
        xor (1|M0)               r52.5<1>:d    r52.5<0;1,0>:d    r52.4<0;1,0>:d  
        mad (1|M0)               r2.7<1>:f     r2.7<0;0>:f       r7.1<0;0>:f       -r1.3<0>:f       {F@1}
        mad (1|M0)               r7.1<1>:f     r5.1<0;0>:f       r7.1<0;0>:f       -r2.6<0>:f      
(W)     mov (1|M0)               r3.4<1>:hf    0x1:hf                             
        add (1|M0)               r2.7<1>:f     r2.7<0;1,0>:f     r7.1<0;1,0>:f    {F@2}
        asr (1|M0)               r52.5<1>:d    r52.5<0;1,0>:d    31:w               {I@1}
        mul (1|M0)               r5.2<1>:f     r5.2<0;1,0>:f     r2.7<0;1,0>:f    {F@1}
        mov (1|M0)               r8.0<1>:ud    r5.2<0;1,0>:f                    {F@1}
        add (1|M0)               r7.0<1>:ud    r7.0<0;1,0>:ud    r8.0<0;1,0>:ud   {Compacted,I@1}
(W)     mul (1|M0)               acc0.0<1>:ud  r7.0<0;1,0>:ud    r1.10<0;1,0>:uw  {I@1}
        mach (1|M0)              r9.0<1>:ud    r7.0<0;1,0>:ud    r1.5<0;1,0>:ud   {Compacted}
        add (1|M0)               r1.4<1>:ud    r1.4<0;1,0>:ud    -r9.0<0;1,0>:ud  {I@1}
        cmp (1|M0)    (ge)f1.0   null<1>:ud    r1.4<0;1,0>:ud    r1.5<0;1,0>:ud   {I@1}
(f1.0)  sel (1|M0)               r6.0<1>:d     r3.4<0;1,0>:w     0:w              
        add3 (1|M0)              r7.0<1>:d     r7.0<0;0>:d       r52.5<0;0>:d      r6.0<0>:d        {I@1}
        xor (1|M0)               r50.4<1>:d    r7.0<0;1,0>:d     r52.5<0;1,0>:d   {I@1}
        mov (1|M0)               cr0.0<1>:ud   r1.2<0;1,0>:d                    {A@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        ret (16|M0)                          r52.2                            {A@1}
L7144:
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
