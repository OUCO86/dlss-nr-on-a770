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
(W)     mov (2|M0)               r49.4<1>:ud   r46.0<1;1,0>:ud                  {A@1}
(W)     mov (2|M0)               r49.6<1>:ud   r46.4<1;1,0>:ud                  {I@2}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r82.6         L7280                                 {A@1}
L552:
        mul (1|M0)               acc0.0<1>:ud  r82.0<0;1,0>:ud   r46.8<0;1,0>:uw 
        mach (1|M0)              r6.0<1>:ud    r82.0<0;1,0>:ud   r46.4<0;1,0>:ud  {AccWrEn}
        mov (1|M0)               r83.5<1>:d    r2.7<0;1,0>:d                   
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r82.0<0;1,0>:d    r46.10<0;1,0>:uw {Compacted}
        mach (1|M0)              r7.0<1>:d     r82.0<0;1,0>:d    r46.5<0;1,0>:d   {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r82.1<0;1,0>:d    r46.8<0;1,0>:uw 
        mach (1|M0)              r8.0<1>:d     r82.1<0;1,0>:d    r46.4<0;1,0>:d  
        subb (1|M0)              r9.0<1>:ud    r46.0<0;1,0>:ud   r5.0<0;1,0>:ud   {AccWrEn,I@5}
        add3 (1|M0)              r1.3<1>:d     r8.0<0;0>:d       r6.0<0;0>:d       r7.0<0>:d        {I@2}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mul (1|M0)               acc0.0<1>:ud  r82.0<0;1,0>:ud   r3.4<0;1,0>:uw  
        mach (1|M0)              r12.0<1>:ud   r82.0<0;1,0>:ud   r3.2<0;1,0>:ud   {AccWrEn}
        mov (1|M0)               r47.4<1>:d    r9.0<0;1,0>:d                    {I@5}
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r82.0<0;1,0>:d    r3.6<0;1,0>:uw   {Compacted}
        shl (1|M0)               r5.0<1>:d     r11.0<0;1,0>:d    1:w               {Compacted,I@2}
        mach (1|M0)              r13.0<1>:d    r82.0<0;1,0>:d    r3.3<0;1,0>:d    {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r82.1<0;1,0>:d    r3.4<0;1,0>:uw  
        mach (1|M0)              r14.0<1>:d    r82.1<0;1,0>:d    r3.2<0;1,0>:d   
        addc (1|M0)              r6.0<1>:ud    r3.0<0;1,0>:ud    r5.0<0;1,0>:ud   {AccWrEn,I@4}
        add3 (1|M0)              r2.4<1>:d     r14.0<0;0>:d      r12.0<0;0>:d      r13.0<0>:d       {I@2}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mul (1|M0)               acc0.0<1>:ud  r82.0<0;1,0>:ud   r3.12<0;1,0>:uw 
        mach (1|M0)              r9.0<1>:ud    r82.0<0;1,0>:ud   r3.6<0;1,0>:ud   {AccWrEn}
        shr (1|M0)               r4.7<1>:ud    r11.0<0;1,0>:ud   0x1F:uw             
        shl (1|M0)               r4.6<1>:d     r2.4<0;1,0>:d     1:w               {I@5}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        or (1|M0)                r5.1<1>:d     r4.6<0;1,0>:d     r4.7<0;1,0>:d    {I@2}
(W)     mul (1|M0)               acc0.0<1>:d   r82.0<0;1,0>:d    r3.14<0;1,0>:uw  {Compacted}
        shl (1|M0)               r4.6<1>:d     r8.0<0;1,0>:d     1:w               {Compacted,I@3}
        add3 (1|M0)              r47.5<1>:d    r46.1<0;0>:d      -r10.0<0;0>:d     -r1.3<0>:d      
        mach (1|M0)              r10.0<1>:d    r82.0<0;1,0>:d    r3.7<0;1,0>:d    {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r82.1<0;1,0>:d    r3.12<0;1,0>:uw 
        mach (1|M0)              r11.0<1>:d    r82.1<0;1,0>:d    r3.6<0;1,0>:d   
        addc (1|M0)              r5.0<1>:ud    r3.4<0;1,0>:ud    r4.6<0;1,0>:ud   {AccWrEn,I@5}
        mov (1|M0)               r46.6<1>:d    r6.0<0;1,0>:d                   
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mul (1|M0)               acc0.0<1>:ud  r82.0<0;1,0>:ud   r4.4<0;1,0>:uw  
        mach (1|M0)              r13.0<1>:ud   r82.0<0;1,0>:ud   r4.2<0;1,0>:ud   {AccWrEn}
        add3 (1|M0)              r1.3<1>:d     r11.0<0;0>:d      r9.0<0;0>:d       r10.0<0>:d       {I@6}
        mov (1|M0)               r12.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r82.0<0;1,0>:d    r4.6<0;1,0>:uw   {Compacted}
        add3 (1|M0)              r46.7<1>:d    r7.0<0;0>:d       r3.1<0;0>:d       r5.1<0>:d       
        mach (1|M0)              r7.0<1>:d     r82.0<0;1,0>:d    r4.3<0;1,0>:d    {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r82.1<0;1,0>:d    r4.4<0;1,0>:uw  
        shr (1|M0)               r2.4<1>:ud    r8.0<0;1,0>:ud    0x1F:uw             
        shl (1|M0)               r2.3<1>:d     r1.3<0;1,0>:d     1:w               {Compacted,I@7}
        mach (1|M0)              r8.0<1>:d     r82.1<0;1,0>:d    r4.2<0;1,0>:d   
        mov (1|M0)               r47.0<1>:f    r5.0<0;1,0>:f                    {Compacted}
        or (1|M0)                r4.7<1>:d     r2.3<0;1,0>:d     r2.4<0;1,0>:d    {I@2}
        add3 (1|M0)              r1.3<1>:d     r8.0<0;0>:d       r13.0<0;0>:d      r7.0<0>:d        {I@2}
        shl (1|M0)               r5.0<1>:d     r12.0<0;1,0>:d    2:w               {Compacted,F@1}
        shr (1|M0)               r2.4<1>:ud    r12.0<0;1,0>:ud   0x1E:uw             
        add3 (1|M0)              r47.1<1>:d    r6.0<0;0>:d       r3.5<0;0>:d       r4.7<0>:d        {I@4}
        shl (1|M0)               r2.3<1>:d     r1.3<0;1,0>:d     2:w               {Compacted,I@4}
        addc (1|M0)              r6.0<1>:ud    r4.0<0;1,0>:ud    r5.0<0;1,0>:ud   {AccWrEn,I@4}
        or (1|M0)                r5.1<1>:d     r2.3<0;1,0>:d     r2.4<0;1,0>:d    {I@2}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r83.4<1>:f    r47.4<0;1,0>:f                  
        mov (1|M0)               r47.2<1>:d    r6.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r47.3<1>:d    r9.0<0;0>:d       r4.1<0;0>:d       r5.1<0>:d        {I@2}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r83.2         L6696                                 {A@1}
L1416:
        cmp (1|M0)    (gt)f0.0   null<1>:d     r4.4<0;1,0>:d     0:w              
(W)     mul (1|M0)               acc0.0<1>:d   r47.6<0;1,0>:d    r2.14<0;1,0>:uw 
        mach (1|M0)              r48.0<1>:d    r47.6<0;1,0>:d    r2.7<0;1,0>:d   
        mov (16|M0)              r50.0<1>:ud   0x0:ud                             
(W)     and (1|M0)               f1.0<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
        mov (16|M0)              r52.0<1>:ud   0x0:ud                             
        mov (16|M0)              r54.0<1>:ud   0x0:ud                             
        mov (16|M0)              r56.0<1>:ud   0x0:ud                             
        mov (16|M0)              r58.0<1>:ud   0x0:ud                             
        mov (16|M0)              r60.0<1>:ud   0x0:ud                             
        mov (16|M0)              r62.0<1>:ud   0x0:ud                             
        mov (16|M0)              r64.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r66.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r68.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r70.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r72.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r74.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r76.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r78.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r80.0<1>:f    0.0:f                               {Compacted}
        add (1|M0)               r48.0<1>:d    r47.4<0;1,0>:d    -r48.0<0;1,0>:d  {Compacted,I@7}
(~f1.0.any16h) goto (16|M0)                  L2752                  L2752                
L1688:
(W)     mul (1|M0)               acc0.0<1>:d   r47.6<0;1,0>:d    r4.8<0;1,0>:uw  
        mach (1|M0)              r5.0<1>:d     r47.6<0;1,0>:d    r4.4<0;1,0>:d   
(W)     mul (1|M0)               acc0.0<1>:d   r47.6<0;1,0>:d    r4.8<0;1,0>:uw  
        mov (1|M0)               r48.1<1>:d    r48.0<0;1,0>:d                   {I@5}
        asr (1|M0)               r48.2<1>:d    r48.0<0;1,0>:d    31:w               {Compacted}
        mov (1|M0)               r48.3<1>:d    r4.4<0;1,0>:d                   
        mov (1|M0)               r48.4<1>:d    0:w                              
        mov (1|M0)               r48.6<2>:f    0.0:f                              
        mov (1|M0)               r48.7<2>:f    0.0:f                              
        mach (1|M0)              r49.0<1>:d    r47.6<0;1,0>:d    r4.4<0;1,0>:d   
        asr (1|M0)               r49.1<1>:d    r5.0<0;1,0>:d     31:w               {Compacted,I@7}
L1848:
        addc (1|M0)              r5.0<1>:ud    r48.6<0;1,0>:ud   r49.0<0;1,0>:ud  {AccWrEn,A@2}
        shl (1|M0)               r4.6<1>:d     r5.0<0;1,0>:d     8:w               {Compacted,I@1}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        shl (1|M0)               r7.2<1>:d     r4.6<0;1,0>:d     1:w               {I@2}
        add3 (1|M0)              r1.3<1>:d     r6.0<0;0>:d       r48.7<0;0>:d      r49.1<0>:d       {A@1}
        addc (1|M0)              r8.0<1>:ud    r46.6<0;1,0>:ud   r7.2<0;1,0>:ud   {AccWrEn,I@2}
        shr (1|M0)               r2.4<1>:ud    r5.0<0;1,0>:ud    0x18:uw             
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mul (1|M0)               acc0.0<1>:ud  r48.6<0;1,0>:ud   r46.4<0;1,0>:uw 
        mach (1|M0)              r12.0<1>:ud   r48.6<0;1,0>:ud   r46.2<0;1,0>:ud  {AccWrEn}
        shl (1|M0)               r2.3<1>:d     r1.3<0;1,0>:d     8:w               {Compacted,I@6}
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r48.6<0;1,0>:d    r46.6<0;1,0>:uw 
        mach (1|M0)              r5.0<1>:d     r48.6<0;1,0>:d    r46.3<0;1,0>:d  
(W)     mul (1|M0)               acc0.0<1>:d   r48.7<0;1,0>:d    r46.4<0;1,0>:uw 
        or (1|M0)                r4.7<1>:d     r2.3<0;1,0>:d     r2.4<0;1,0>:d    {I@5}
        mach (1|M0)              r6.0<1>:d     r48.7<0;1,0>:d    r46.2<0;1,0>:d  
        addc (1|M0)              r13.0<1>:ud   r11.0<0;1,0>:ud   r48.1<0;1,0>:ud  {AccWrEn,I@6}
        shr (1|M0)               r7.1<1>:ud    r4.6<0;1,0>:ud    0x1F:uw             
        shl (1|M0)               r7.0<1>:d     r4.7<0;1,0>:d     1:w               {Compacted,I@4}
        add3 (1|M0)              r1.3<1>:d     r6.0<0;0>:d       r12.0<0;0>:d      r5.0<0>:d        {I@4}
        mov (1|M0)               r14.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,$3.src}
        or (1|M0)                r7.3<1>:d     r7.0<0;1,0>:d     r7.1<0;1,0>:d    {I@3}
        add3 (1|M0)              r2.4<1>:d     r14.0<0;0>:d      r1.3<0;0>:d       r48.2<0>:d       {I@2}
        shl (1|M0)               r7.0<1>:d     r13.0<0;1,0>:d    8:w               {Compacted}
        mov (1|M0)               r10.0<1>:f    r8.0<0;1,0>:f                    {Compacted}
        shr (1|M0)               r4.7<1>:ud    r13.0<0;1,0>:ud   0x18:uw             
        shl (1|M0)               r4.6<1>:d     r2.4<0;1,0>:d     8:w               {I@3}
        shl (1|M0)               r8.0<1>:d     r7.0<0;1,0>:d     1:w               {Compacted,A@1}
        or (1|M0)                r7.1<1>:d     r4.6<0;1,0>:d     r4.7<0;1,0>:d    {I@2}
        addc (1|M0)              r5.0<1>:ud    r47.0<0;1,0>:ud   r8.0<0;1,0>:ud   {AccWrEn,I@2}
        add3 (1|M0)              r10.1<1>:d    r9.0<0;0>:d       r46.7<0;0>:d      r7.3<0>:d       
        shl (1|M0)               r7.2<1>:d     r7.1<0;1,0>:d     1:w               {I@3}
        shr (1|M0)               r7.3<1>:ud    r7.0<0;1,0>:ud    0x1F:uw             
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r9.0<1>:f     r5.0<0;1,0>:f                    {Compacted,A@4}
        addc (1|M0)              r11.0<1>:ud   r10.0<0;1,0>:ud   0x100:ud              {AccWrEn}
        or (1|M0)                r8.1<1>:d     r7.2<0;1,0>:d     r7.3<0;1,0>:d    {I@3}
        mov (1|M0)               r12.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r5.0<1>:ud    r9.0<0;1,0>:ud    0x100:ud              {AccWrEn,F@1}
        add3 (1|M0)              r9.1<1>:d     r6.0<0;0>:d       r47.1<0;0>:d      r8.1<0>:d        {I@3}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r13.0<1>:f    r11.0<0;1,0>:f                   {Compacted}
        add3 (1|M0)              r13.1<1>:d    r12.0<0;0>:d      r10.1<0;0>:d      0:w               {I@4}
        mov (1|M0)               r7.0<1>:f     r5.0<0;1,0>:f                    {Compacted,I@4}
        add3 (1|M0)              r7.1<1>:d     r6.0<0;0>:d       r9.1<0;0>:d       0:w               {I@2}
        send.ugm (1|M0)          r14      r10     null:0  0x0            0x0280E780           {$4} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        send.ugm (1|M0)          r30      r9      null:0  0x0            0x0280E780           {$5} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        send.ugm (1|M0)          r22      r13     null:0  0x0            0x0280E780           {A@2,$6} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        send.ugm (1|M0)          r38      r7      null:0  0x0            0x0280E780           {A@1,$7} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        addc (1|M0)              r8.0<1>:ud    r48.6<0;1,0>:ud   0x1:ud              {AccWrEn}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,$4.src}
        mov (1|M0)               r49.2<1>:d    r8.0<0;1,0>:d                    {I@2}
        add3 (1|M0)              r49.3<1>:d    r10.0<0;0>:d      r48.7<0;0>:d      0:w               {I@2}
        cmp (1|M0)    (eq)f1.0   null<1>:d     r49.3<0;1,0>:d    r48.4<0;1,0>:d   {I@1}
(f1.0)  cmp (1|M0)    (eq)f1.0   null<1>:d     r49.2<0;1,0>:d    r48.3<0;1,0>:d  
(W)     and (1|M0)               f0.1<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
        sync.allwr                           ($3,$4,$5,$6,$7)                
        dpas.8x8 (8|M0)          r74:f         r74:f             r30:hf            r14.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r58:f         r58:f             r30:hf            r22.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r66:f         r66:f             r38:hf            r14.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r50:f         r50:f             r38:hf            r22.0:hf         {$3}
(f0.1.any16h) goto (16|M0)                   L2752                  L2752                
L2720:
(W)     mov (2|M0)               r48.6<1>:ud   r49.2<1;1,0>:ud                 
        goto.b (16|M0)                       L2752                  L1848                
L2752:
        join (16|M0)                         L2768                                
L2768:
        shl (1|M0)               r47.6<1>:d    r47.6<0;1,0>:d    4:w              
        shl (1|M0)               r4.6<1>:d     r48.0<0;1,0>:d    4:w               {Compacted}
        mul (1|M0)               acc0.0<1>:d   r47.6<0;1,0>:d    r4.10<0;1,0>:uw  {I@2}
        mach (1|M0)              r6.0<1>:d     r47.6<0;1,0>:d    r4.5<0;1,0>:d    {AccWrEn}
        shl (1|M0)               r7.1<1>:d     r4.6<0;1,0>:d     2:w               {I@3}
        mov (1|M0)               r5.0<1>:d     acc0.0<0;1,0>:d                 
        shl (1|M0)               r1.4<1>:d     r6.0<0;1,0>:d     2:w               {Compacted,I@3}
        shl (1|M0)               r1.6<1>:d     r5.0<0;1,0>:d     2:w               {Compacted,I@2}
        shr (1|M0)               r1.5<1>:ud    r5.0<0;1,0>:ud    0x1E:uw             
        addc (1|M0)              r7.0<1>:ud    r47.2<0;1,0>:ud   r1.6<0;1,0>:ud   {AccWrEn,I@2}
        shr (1|M0)               r2.5<1>:ud    r4.6<0;1,0>:ud    0x1E:uw             
        or (1|M0)                r1.7<1>:d     r1.4<0;1,0>:d     r1.5<0;1,0>:d    {I@3}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r9.0<1>:ud    r7.0<0;1,0>:ud    r7.1<0;1,0>:ud   {AccWrEn,I@4}
        shl (1|M0)               r1.6<1>:d     r4.5<0;1,0>:d     3:w              
        or (1|M0)                r7.2<1>:d     r2.5<0;1,0>:d     0:w               {I@5}
        add3 (1|M0)              r2.4<1>:d     r8.0<0;0>:d       r47.3<0;0>:d      r1.7<0>:d        {I@4}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r11.0<1>:f    r9.0<0;1,0>:f                    {Compacted,I@5}
        add3 (1|M0)              r11.1<1>:d    r10.0<0;0>:d      r2.4<0;0>:d       r7.2<0>:d        {I@1}
        addc (1|M0)              r5.0<1>:ud    r11.0<0;1,0>:ud   0x20:ud              {AccWrEn,F@1}
        shl (1|M0)               r2.4<1>:d     r1.6<0;1,0>:d     2:w              
        asr (1|M0)               r1.3<1>:d     r4.5<0;1,0>:d     31:w              
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r7.0<1>:ud    r11.0<0;1,0>:ud   r2.4<0;1,0>:ud   {AccWrEn,I@3}
        shr (1|M0)               r1.5<1>:ud    r4.5<0;1,0>:ud    0x1D:uw             
        mov (1|M0)               r8.0<1>:f     r5.0<0;1,0>:f                    {Compacted}
        shl (1|M0)               r1.4<1>:d     r1.3<0;1,0>:d     3:w               {I@4}
        add3 (1|M0)              r8.1<1>:d     r6.0<0;0>:d       r11.1<0;0>:d      0:w               {I@4}
        mov (1|M0)               r6.0<1>:f     r7.0<0;1,0>:f                    {Compacted,A@1}
        send.ugm (1|M0)          null     r11     r74:1   0x0            0x0200C584           {$3} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        sync.nop                             null                             {Compacted,F@2}
        send.ugm (1|M0)          null     r8      r66:1   0x0            0x0200C584           {$8} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        shr (1|M0)               r2.3<1>:ud    r1.6<0;1,0>:ud    0x1E:uw             
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        or (1|M0)                r1.7<1>:d     r1.4<0;1,0>:d     r1.5<0;1,0>:d   
        shl (1|M0)               r1.6<1>:d     r4.5<0;1,0>:d     2:w              
        sync.nop                             null                             {Compacted,$8.src}
        addc (1|M0)              r8.0<1>:ud    r6.0<0;1,0>:ud    0x20:ud              {AccWrEn,F@1}
        shl (1|M0)               r4.6<1>:d     r1.7<0;1,0>:d     2:w               {I@3}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r7.0<1>:ud    r11.0<0;1,0>:ud   r1.6<0;1,0>:ud   {AccWrEn,I@4}
        or (1|M0)                r2.5<1>:d     r4.6<0;1,0>:d     r2.3<0;1,0>:d    {I@3}
        mov (1|M0)               r12.0<1>:f    r7.0<0;1,0>:f                    {Compacted,I@2}
        mov (1|M0)               r10.0<1>:f    r8.0<0;1,0>:f                    {Compacted}
        add3 (1|M0)              r6.1<1>:d     r5.0<0;0>:d       r11.1<0;0>:d      r2.5<0>:d        {I@1}
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r8.0<1>:ud    r12.0<0;1,0>:ud   0x20:ud              {AccWrEn,A@1}
        send.ugm (1|M0)          null     r6      r58:1   0x0            0x0200C584           {A@3,$9} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$9.src}
        mul (1|M0)               acc0.0<1>:d   r4.5<0;1,0>:d     0x9:uw             
        mach (1|M0)              r14.0<1>:d    r4.5<0;1,0>:d     9:d               {AccWrEn}
        shl (1|M0)               r1.4<1>:d     r1.3<0;1,0>:d     2:w              
        shr (1|M0)               r1.5<1>:ud    r4.5<0;1,0>:ud    0x1E:uw             
        mov (1|M0)               r13.0<1>:d    acc0.0<0;1,0>:d                 
        or (1|M0)                r1.7<1>:d     r1.4<0;1,0>:d     r1.5<0;1,0>:d    {I@2}
        shl (1|M0)               r2.3<1>:d     r13.0<0;1,0>:d    2:w               {Compacted,I@2}
        shl (1|M0)               r1.4<1>:d     r14.0<0;1,0>:d    2:w               {Compacted}
        shr (1|M0)               r1.5<1>:ud    r13.0<0;1,0>:ud   0x1E:uw             
        add3 (1|M0)              r12.1<1>:d    r5.0<0;0>:d       r11.1<0;0>:d      r1.7<0>:d        {I@4}
        addc (1|M0)              r5.0<1>:ud    r11.0<0;1,0>:ud   r2.3<0;1,0>:ud   {AccWrEn,I@4}
        shl (1|M0)               r11.2<1>:d    r4.5<0;1,0>:d     1:w               {$3.src}
        add3 (1|M0)              r10.1<1>:d    r9.0<0;0>:d       r6.1<0;0>:d       0:w              
        or (1|M0)                r2.4<1>:d     r1.4<0;1,0>:d     r1.5<0;1,0>:d    {I@5}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r9.0<1>:f     r8.0<0;1,0>:f                    {Compacted,I@3}
        mov (1|M0)               r8.0<1>:f     r5.0<0;1,0>:f                    {Compacted}
        add3 (1|M0)              r9.1<1>:d     r6.0<0;0>:d       r12.1<0;0>:d      0:w              
        add3 (1|M0)              r8.1<1>:d     r7.0<0;0>:d       r11.1<0;0>:d      r2.4<0>:d        {I@2}
        addc (1|M0)              r6.0<1>:ud    r8.0<0;1,0>:ud    0x20:ud              {AccWrEn,F@1}
        shl (1|M0)               r2.4<1>:d     r11.2<0;1,0>:d    2:w              
        send.ugm (1|M0)          null     r10     r50:1   0x0            0x0200C584           {$10} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r12     r75:1   0x0            0x0200C584           {$11} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r9      r67:1   0x0            0x0200C584           {A@4,$12} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$12.src}
        addc (1|M0)              r7.0<1>:ud    r11.0<0;1,0>:ud   r2.4<0;1,0>:ud   {AccWrEn,I@2}
        send.ugm (1|M0)          null     r8      r59:1   0x0            0x0200C584           {$13} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        sync.nop                             null                             {Compacted,$13.src}
        mov (1|M0)               r8.0<1>:f     r7.0<0;1,0>:f                    {Compacted,I@1}
        mov (1|M0)               r10.0<1>:f    r6.0<0;1,0>:f                    {Compacted,$10.src}
        add3 (1|M0)              r10.1<1>:d    r9.0<0;0>:d       r8.1<0;0>:d       0:w              
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,F@1}
        addc (1|M0)              r9.0<1>:ud    r8.0<0;1,0>:ud    0x20:ud              {AccWrEn}
        send.ugm (1|M0)          null     r10     r51:1   0x0            0x0200C584           {A@3,$14} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,$14.src}
        mul (1|M0)               acc0.0<1>:d   r4.5<0;1,0>:d     0xA:uw             
        shr (1|M0)               r4.7<1>:ud    r4.5<0;1,0>:ud    0x1F:uw             
        shl (1|M0)               r4.6<1>:d     r1.3<0;1,0>:d     1:w              
        mach (1|M0)              r14.0<1>:d    r4.5<0;1,0>:d     10:d               {AccWrEn}
        or (1|M0)                r11.3<1>:d    r4.6<0;1,0>:d     r4.7<0;1,0>:d    {I@2}
        mov (1|M0)               r13.0<1>:d    acc0.0<0;1,0>:d                 
        shr (1|M0)               r2.3<1>:ud    r11.2<0;1,0>:ud   0x1E:uw             
        shl (1|M0)               r5.0<1>:d     r11.3<0;1,0>:d    2:w               {Compacted,I@3}
        shl (1|M0)               r1.4<1>:d     r13.0<0;1,0>:d    2:w               {Compacted,I@3}
        or (1|M0)                r2.5<1>:d     r5.0<0;1,0>:d     r2.3<0;1,0>:d    {I@2}
        addc (1|M0)              r5.0<1>:ud    r11.0<0;1,0>:ud   r1.4<0;1,0>:ud   {AccWrEn,I@2}
        add3 (1|M0)              r8.1<1>:d     r6.0<0;0>:d       r11.1<0;0>:d      r2.5<0>:d        {I@2}
        mov (1|M0)               r7.0<1>:f     r5.0<0;1,0>:f                    {Compacted,I@2}
        sync.nop                             null                             {Compacted,I@1}
        send.ugm (1|M0)          null     r8      r76:1   0x0            0x0200C584           {$15} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        sync.nop                             null                             {Compacted,$15.src}
        addc (1|M0)              r8.0<1>:ud    r7.0<0;1,0>:ud    0x20:ud              {AccWrEn,F@1}
        mov (1|M0)               r12.0<1>:f    r9.0<0;1,0>:f                    {Compacted,$11.src}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,F@1}
        mul (1|M0)               acc0.0<1>:d   r4.5<0;1,0>:d     0x3:uw             
        shr (1|M0)               r1.3<1>:ud    r13.0<0;1,0>:ud   0x1E:uw             
        add3 (1|M0)              r12.1<1>:d    r10.0<0;0>:d      r8.1<0;0>:d       0:w              
        mach (1|M0)              r13.0<1>:d    r4.5<0;1,0>:d     3:d               {AccWrEn}
        send.ugm (1|M0)          null     r12     r68:1   0x0            0x0200C584           {A@2,$0} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        shl (1|M0)               r1.2<1>:d     r14.0<0;1,0>:d    2:w               {Compacted}
        mov (1|M0)               r12.0<1>:d    acc0.0<0;1,0>:d                  {$0.src}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        shl (1|M0)               r1.2<1>:d     r12.0<0;1,0>:d    2:w               {Compacted,I@2}
        mov (1|M0)               r10.0<1>:f    r8.0<0;1,0>:f                    {Compacted}
        addc (1|M0)              r5.0<1>:ud    r11.0<0;1,0>:ud   r1.2<0;1,0>:ud   {AccWrEn,I@1}
        add3 (1|M0)              r7.1<1>:d     r6.0<0;0>:d       r11.1<0;0>:d      r1.5<0>:d       
        mov (1|M0)               r8.0<1>:f     r5.0<0;1,0>:f                    {Compacted,I@2}
        sync.nop                             null                             {Compacted,I@1}
        send.ugm (1|M0)          null     r7      r60:1   0x0            0x0200C584           {$1} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        sync.nop                             null                             {Compacted,$1.src}
        addc (1|M0)              r7.0<1>:ud    r8.0<0;1,0>:ud    0x20:ud              {AccWrEn,F@1}
        add3 (1|M0)              r10.1<1>:d    r9.0<0;0>:d       r7.1<0;0>:d       0:w              
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mul (1|M0)               acc0.0<1>:d   r4.5<0;1,0>:d     0xB:uw             
        shl (1|M0)               r2.3<1>:d     r13.0<0;1,0>:d    2:w               {Compacted}
        mach (1|M0)              r13.0<1>:d    r4.5<0;1,0>:d     11:d               {AccWrEn}
        shr (1|M0)               r2.4<1>:ud    r12.0<0;1,0>:ud   0x1E:uw             
        mov (1|M0)               r12.0<1>:d    acc0.0<0;1,0>:d                 
        or (1|M0)                r1.3<1>:d     r2.3<0;1,0>:d     r2.4<0;1,0>:d    {I@2}
        shl (1|M0)               r1.2<1>:d     r12.0<0;1,0>:d    2:w               {Compacted,I@2}
        send.ugm (1|M0)          null     r10     r52:1   0x0            0x0200C584           {$2} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        addc (1|M0)              r5.0<1>:ud    r11.0<0;1,0>:ud   r1.2<0;1,0>:ud   {AccWrEn,I@1}
        shl (1|M0)               r2.3<1>:d     r13.0<0;1,0>:d    2:w               {Compacted}
        shr (1|M0)               r2.4<1>:ud    r12.0<0;1,0>:ud   0x1E:uw             
        add3 (1|M0)              r8.1<1>:d     r6.0<0;0>:d       r11.1<0;0>:d      r1.3<0>:d       
        mov (1|M0)               r10.0<1>:f    r7.0<0;1,0>:f                    {Compacted,$2.src}
        mov (1|M0)               r7.0<1>:f     r5.0<0;1,0>:f                    {Compacted,I@4}
        sync.nop                             null                             {Compacted,I@1}
        send.ugm (1|M0)          null     r8      r77:1   0x0            0x0200C584           {$3} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        or (1|M0)                r1.3<1>:d     r2.3<0;1,0>:d     r2.4<0;1,0>:d   
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        shl (1|M0)               r2.4<1>:d     r1.6<0;1,0>:d     2:w              
        sync.nop                             null                             {Compacted,$3.src}
        addc (1|M0)              r8.0<1>:ud    r7.0<0;1,0>:ud    0x20:ud              {AccWrEn,F@1}
        add3 (1|M0)              r10.1<1>:d    r9.0<0;0>:d       r8.1<0;0>:d       0:w              
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r5.0<1>:ud    r11.0<0;1,0>:ud   r2.4<0;1,0>:ud   {AccWrEn,I@4}
        send.ugm (1|M0)          null     r10     r69:1   0x0            0x0200C584           {A@3,$4} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        mov (1|M0)               r12.0<1>:f    r5.0<0;1,0>:f                    {Compacted,I@1}
        add3 (1|M0)              r7.1<1>:d     r6.0<0;0>:d       r11.1<0;0>:d      r1.3<0>:d       
        mov (1|M0)               r10.0<1>:f    r8.0<0;1,0>:f                    {Compacted,$4.src}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r8.0<1>:ud    r12.0<0;1,0>:ud   0x20:ud              {AccWrEn,A@1}
        send.ugm (1|M0)          null     r7      r61:1   0x0            0x0200C584           {A@3,$5} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$5.src}
        mul (1|M0)               acc0.0<1>:d   r4.5<0;1,0>:d     0xC:uw             
        mach (1|M0)              r14.0<1>:d    r4.5<0;1,0>:d     12:d               {AccWrEn}
        shl (1|M0)               r4.6<1>:d     r1.7<0;1,0>:d     2:w              
        mov (1|M0)               r13.0<1>:d    acc0.0<0;1,0>:d                 
        shr (1|M0)               r2.3<1>:ud    r1.6<0;1,0>:ud    0x1E:uw             
        shl (1|M0)               r1.4<1>:d     r13.0<0;1,0>:d    2:w               {Compacted,I@2}
        or (1|M0)                r2.5<1>:d     r4.6<0;1,0>:d     r2.3<0;1,0>:d    {I@2}
        addc (1|M0)              r5.0<1>:ud    r11.0<0;1,0>:ud   r1.4<0;1,0>:ud   {AccWrEn,I@2}
        add3 (1|M0)              r10.1<1>:d    r9.0<0;0>:d       r7.1<0;0>:d       0:w              
        add3 (1|M0)              r12.1<1>:d    r6.0<0;0>:d       r11.1<0;0>:d      r2.5<0>:d        {I@3}
        mov (1|M0)               r9.0<1>:f     r8.0<0;1,0>:f                    {Compacted,I@2}
        mov (1|M0)               r8.0<1>:f     r5.0<0;1,0>:f                    {Compacted}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        add3 (1|M0)              r9.1<1>:d     r7.0<0;0>:d       r12.1<0;0>:d      0:w               {I@2}
        addc (1|M0)              r7.0<1>:ud    r8.0<0;1,0>:ud    0x20:ud              {AccWrEn,F@1}
        send.ugm (1|M0)          null     r10     r53:1   0x0            0x0200C584           {$6} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r12     r78:1   0x0            0x0200C584           {$7} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r9      r70:1   0x0            0x0200C584           {A@2,$8} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$8.src}
        mul (1|M0)               acc0.0<1>:d   r4.5<0;1,0>:d     0x5:uw             
        shr (1|M0)               r1.3<1>:ud    r13.0<0;1,0>:ud   0x1E:uw             
        mach (1|M0)              r13.0<1>:d    r4.5<0;1,0>:d     5:d               {AccWrEn}
        shl (1|M0)               r1.2<1>:d     r14.0<0;1,0>:d    2:w               {Compacted}
        mov (1|M0)               r12.0<1>:d    acc0.0<0;1,0>:d                  {$7.src}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        shl (1|M0)               r1.2<1>:d     r12.0<0;1,0>:d    2:w               {Compacted,I@2}
        mov (1|M0)               r10.0<1>:f    r7.0<0;1,0>:f                    {Compacted,$6.src}
        addc (1|M0)              r5.0<1>:ud    r11.0<0;1,0>:ud   r1.2<0;1,0>:ud   {AccWrEn,I@1}
        add3 (1|M0)              r8.1<1>:d     r6.0<0;0>:d       r11.1<0;0>:d      r1.5<0>:d       
        mov (1|M0)               r7.0<1>:f     r5.0<0;1,0>:f                    {Compacted,I@2}
        sync.nop                             null                             {Compacted,I@1}
        send.ugm (1|M0)          null     r8      r62:1   0x0            0x0200C584           {$9} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        sync.nop                             null                             {Compacted,$9.src}
        addc (1|M0)              r8.0<1>:ud    r7.0<0;1,0>:ud    0x20:ud              {AccWrEn,F@1}
        add3 (1|M0)              r10.1<1>:d    r9.0<0;0>:d       r8.1<0;0>:d       0:w              
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mul (1|M0)               acc0.0<1>:d   r4.5<0;1,0>:d     0xD:uw             
        shl (1|M0)               r2.3<1>:d     r13.0<0;1,0>:d    2:w               {Compacted}
        mach (1|M0)              r13.0<1>:d    r4.5<0;1,0>:d     13:d               {AccWrEn}
        shr (1|M0)               r2.4<1>:ud    r12.0<0;1,0>:ud   0x1E:uw             
        mov (1|M0)               r12.0<1>:d    acc0.0<0;1,0>:d                 
        or (1|M0)                r1.3<1>:d     r2.3<0;1,0>:d     r2.4<0;1,0>:d    {I@2}
        shl (1|M0)               r1.2<1>:d     r12.0<0;1,0>:d    2:w               {Compacted,I@2}
        send.ugm (1|M0)          null     r10     r54:1   0x0            0x0200C584           {$10} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        addc (1|M0)              r5.0<1>:ud    r11.0<0;1,0>:ud   r1.2<0;1,0>:ud   {AccWrEn,I@1}
        add3 (1|M0)              r7.1<1>:d     r6.0<0;0>:d       r11.1<0;0>:d      r1.3<0>:d       
        mov (1|M0)               r10.0<1>:f    r8.0<0;1,0>:f                    {Compacted,$10.src}
        mov (1|M0)               r8.0<1>:f     r5.0<0;1,0>:f                    {Compacted,I@2}
        sync.nop                             null                             {Compacted,I@1}
        send.ugm (1|M0)          null     r7      r79:1   0x0            0x0200C584           {$11} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        sync.nop                             null                             {Compacted,$11.src}
        addc (1|M0)              r7.0<1>:ud    r8.0<0;1,0>:ud    0x20:ud              {AccWrEn,F@1}
        add3 (1|M0)              r10.1<1>:d    r9.0<0;0>:d       r7.1<0;0>:d       0:w              
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mul (1|M0)               acc0.0<1>:d   r4.5<0;1,0>:d     0x6:uw             
        shl (1|M0)               r2.3<1>:d     r13.0<0;1,0>:d    2:w               {Compacted}
        mach (1|M0)              r13.0<1>:d    r4.5<0;1,0>:d     6:d               {AccWrEn}
        shr (1|M0)               r2.4<1>:ud    r12.0<0;1,0>:ud   0x1E:uw             
        mov (1|M0)               r12.0<1>:d    acc0.0<0;1,0>:d                 
        or (1|M0)                r1.3<1>:d     r2.3<0;1,0>:d     r2.4<0;1,0>:d    {I@2}
        shl (1|M0)               r1.2<1>:d     r12.0<0;1,0>:d    2:w               {Compacted,I@2}
        send.ugm (1|M0)          null     r10     r71:1   0x0            0x0200C584           {$12} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        addc (1|M0)              r5.0<1>:ud    r11.0<0;1,0>:ud   r1.2<0;1,0>:ud   {AccWrEn,I@1}
        add3 (1|M0)              r8.1<1>:d     r6.0<0;0>:d       r11.1<0;0>:d      r1.3<0>:d       
        mov (1|M0)               r10.0<1>:f    r7.0<0;1,0>:f                    {Compacted,$12.src}
        mov (1|M0)               r7.0<1>:f     r5.0<0;1,0>:f                    {Compacted,I@2}
        sync.nop                             null                             {Compacted,I@1}
        send.ugm (1|M0)          null     r8      r63:1   0x0            0x0200C584           {$13} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        sync.nop                             null                             {Compacted,$13.src}
        addc (1|M0)              r8.0<1>:ud    r7.0<0;1,0>:ud    0x20:ud              {AccWrEn,F@1}
        add3 (1|M0)              r10.1<1>:d    r9.0<0;0>:d       r8.1<0;0>:d       0:w              
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mul (1|M0)               acc0.0<1>:d   r4.5<0;1,0>:d     0xE:uw             
        shl (1|M0)               r2.3<1>:d     r13.0<0;1,0>:d    2:w               {Compacted}
        mach (1|M0)              r13.0<1>:d    r4.5<0;1,0>:d     14:d               {AccWrEn}
        shr (1|M0)               r2.4<1>:ud    r12.0<0;1,0>:ud   0x1E:uw             
        mov (1|M0)               r12.0<1>:d    acc0.0<0;1,0>:d                 
        or (1|M0)                r1.3<1>:d     r2.3<0;1,0>:d     r2.4<0;1,0>:d    {I@2}
        shl (1|M0)               r1.2<1>:d     r12.0<0;1,0>:d    2:w               {Compacted,I@2}
        send.ugm (1|M0)          null     r10     r55:1   0x0            0x0200C584           {$14} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        addc (1|M0)              r5.0<1>:ud    r11.0<0;1,0>:ud   r1.2<0;1,0>:ud   {AccWrEn,I@1}
        add3 (1|M0)              r7.1<1>:d     r6.0<0;0>:d       r11.1<0;0>:d      r1.3<0>:d       
        mov (1|M0)               r10.0<1>:f    r8.0<0;1,0>:f                    {Compacted,$14.src}
        mov (1|M0)               r8.0<1>:f     r5.0<0;1,0>:f                    {Compacted,I@2}
        sync.nop                             null                             {Compacted,I@1}
        send.ugm (1|M0)          null     r7      r80:1   0x0            0x0200C584           {$15} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        sync.nop                             null                             {Compacted,$15.src}
        addc (1|M0)              r7.0<1>:ud    r8.0<0;1,0>:ud    0x20:ud              {AccWrEn,F@1}
        add3 (1|M0)              r10.1<1>:d    r9.0<0;0>:d       r7.1<0;0>:d       0:w              
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mul (1|M0)               acc0.0<1>:d   r4.5<0;1,0>:d     0x7:uw             
        shl (1|M0)               r2.3<1>:d     r13.0<0;1,0>:d    2:w               {Compacted}
        mach (1|M0)              r13.0<1>:d    r4.5<0;1,0>:d     7:d               {AccWrEn}
        shr (1|M0)               r2.4<1>:ud    r12.0<0;1,0>:ud   0x1E:uw             
        mov (1|M0)               r12.0<1>:d    acc0.0<0;1,0>:d                 
        or (1|M0)                r1.3<1>:d     r2.3<0;1,0>:d     r2.4<0;1,0>:d    {I@2}
        shl (1|M0)               r1.2<1>:d     r12.0<0;1,0>:d    2:w               {Compacted,I@2}
        send.ugm (1|M0)          null     r10     r72:1   0x0            0x0200C584           {$0} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        addc (1|M0)              r5.0<1>:ud    r11.0<0;1,0>:ud   r1.2<0;1,0>:ud   {AccWrEn,I@1}
        add3 (1|M0)              r8.1<1>:d     r6.0<0;0>:d       r11.1<0;0>:d      r1.3<0>:d       
        mov (1|M0)               r10.0<1>:f    r7.0<0;1,0>:f                    {Compacted,$0.src}
        mov (1|M0)               r7.0<1>:f     r5.0<0;1,0>:f                    {Compacted,I@2}
        sync.nop                             null                             {Compacted,I@1}
        send.ugm (1|M0)          null     r8      r64:1   0x0            0x0200C584           {$1} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        sync.nop                             null                             {Compacted,$1.src}
        addc (1|M0)              r8.0<1>:ud    r7.0<0;1,0>:ud    0x20:ud              {AccWrEn,F@1}
        add3 (1|M0)              r10.1<1>:d    r9.0<0;0>:d       r8.1<0;0>:d       0:w              
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mul (1|M0)               acc0.0<1>:d   r4.5<0;1,0>:d     0xF:uw             
        shl (1|M0)               r2.3<1>:d     r13.0<0;1,0>:d    2:w               {Compacted}
        mach (1|M0)              r13.0<1>:d    r4.5<0;1,0>:d     15:d               {AccWrEn}
        shr (1|M0)               r2.4<1>:ud    r12.0<0;1,0>:ud   0x1E:uw             
        mov (1|M0)               r12.0<1>:d    acc0.0<0;1,0>:d                 
        or (1|M0)                r1.3<1>:d     r2.3<0;1,0>:d     r2.4<0;1,0>:d    {I@2}
        shl (1|M0)               r1.2<1>:d     r12.0<0;1,0>:d    2:w               {Compacted,I@2}
        send.ugm (1|M0)          null     r10     r56:1   0x0            0x0200C584           {$2} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        addc (1|M0)              r5.0<1>:ud    r11.0<0;1,0>:ud   r1.2<0;1,0>:ud   {AccWrEn,I@1}
        shl (1|M0)               r2.3<1>:d     r13.0<0;1,0>:d    2:w               {Compacted}
        shr (1|M0)               r2.4<1>:ud    r12.0<0;1,0>:ud   0x1E:uw             
        add3 (1|M0)              r7.1<1>:d     r6.0<0;0>:d       r11.1<0;0>:d      r1.3<0>:d       
        mov (1|M0)               r10.0<1>:f    r8.0<0;1,0>:f                    {Compacted,$2.src}
        mov (1|M0)               r8.0<1>:f     r5.0<0;1,0>:f                    {Compacted,I@4}
        sync.nop                             null                             {Compacted,I@1}
        send.ugm (1|M0)          null     r7      r81:1   0x0            0x0200C584           {$3} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        or (1|M0)                r1.3<1>:d     r2.3<0;1,0>:d     r2.4<0;1,0>:d   
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        sync.nop                             null                             {Compacted,$3.src}
        addc (1|M0)              r7.0<1>:ud    r8.0<0;1,0>:ud    0x20:ud              {AccWrEn,F@1}
        add3 (1|M0)              r10.1<1>:d    r9.0<0;0>:d       r7.1<0;0>:d       0:w              
        add3 (1|M0)              r8.1<1>:d     r6.0<0;0>:d       r11.1<0;0>:d      r1.3<0>:d        {I@3}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        send.ugm (1|M0)          null     r10     r73:1   0x0            0x0200C584           {A@3,$4} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        mov (1|M0)               r10.0<1>:f    r7.0<0;1,0>:f                    {Compacted,$4.src}
        add3 (1|M0)              r10.1<1>:d    r9.0<0;0>:d       r8.1<0;0>:d       0:w               {I@1}
        send.ugm (1|M0)          null     r8      r65:1   0x0            0x0200C584           {$5} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r10     r57:1   0x0            0x0200C584           {A@1,$6} // wr:1+1, rd:0; store.ugm.d32x8t.a64
(W)     mov (8|M0)               r127.0<1>:f   r0.0<1;1,0>:f                    {Compacted}
(W)     send.ugm (1|M0)          r12      r0      null:0  0x0            0x0210641F           {$7} // wr:1+0, rd:1; fence invalid flush type scoped to tile
(W)     mov (8|M0)               null<1>:ud    r12.0<1;1,0>:ud                  {$7.dst}
(W)     send.gtwy (1|M0)         null     r127    null:0  0x0            0x02000010           {EOT,A@1} // wr:1+0, rd:0; end of thread
L6696:
        mov (1|M0)               r1.2<1>:d     cr0.0<0;1,0>:ud                  {A@1}
        and (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   -1265:w               {A@1}
        or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   1264:w               {A@1}
        mov (1|M0)               r1.3<1>:f     (abs)r83.5<0;1,0>:d              {A@1}
        mov (1|M0)               r5.0<1>:f     0xB4C00000:f                               {Compacted}
        math.inv (1|M0)          r4.7<1>:f     r1.3<0;1,0>:f                    {@2,$8}
        mov (1|M0)               r2.4<1>:f     (abs)r83.4<0;1,0>:d             
        sync.nop                             null                             {Compacted,$8.dst}
        mad (1|M0)               r4.7<1>:f     r4.7<0;0>:f       r5.0<0;0>:f       r4.7<0>:f        {F@2}
        mov (2|M0)               r1.4<1>:d     (abs)r83.4<1;1,0>:d             
        mov (1|M0)               r1.6<1>:ud    r1.3<0;1,0>:f                   
        mov (1|M0)               r2.5<1>:ud    r2.4<0;1,0>:f                    {F@2}
        mul (1|M0)               r6.0<1>:f     r4.7<0;1,0>:f     r2.4<0;1,0>:f    {F@1}
        add (1|M0)               r1.6<1>:ud    r1.5<0;1,0>:ud    -r1.6<0;1,0>:ud  {I@2}
        add (1|M0)               r2.5<1>:ud    r1.4<0;1,0>:ud    -r2.5<0;1,0>:ud  {I@2}
        mov (1|M0)               r7.0<1>:ud    r6.0<0;1,0>:f                    {F@1}
        mov (1|M0)               r2.3<1>:f     r1.6<0;1,0>:ud                   {I@3}
        mov (1|M0)               r4.6<1>:f     r2.5<0;1,0>:ud                   {I@2}
        mov (1|M0)               r7.1<1>:f     r7.0<0;1,0>:ud                   {Compacted,I@1}
        xor (1|M0)               r83.5<1>:d    r83.5<0;1,0>:d    r83.4<0;1,0>:d  
        mad (1|M0)               r2.4<1>:f     r2.4<0;0>:f       r7.1<0;0>:f       -r1.3<0>:f       {F@1}
        mad (1|M0)               r7.1<1>:f     r4.6<0;0>:f       r7.1<0;0>:f       -r2.3<0>:f      
(W)     mov (1|M0)               r6.0<1>:hf    0x1:hf                             
        add (1|M0)               r2.4<1>:f     r2.4<0;1,0>:f     r7.1<0;1,0>:f    {F@2}
        asr (1|M0)               r83.5<1>:d    r83.5<0;1,0>:d    31:w               {I@1}
        mul (1|M0)               r4.7<1>:f     r4.7<0;1,0>:f     r2.4<0;1,0>:f    {F@1}
        mov (1|M0)               r8.0<1>:ud    r4.7<0;1,0>:f                    {F@1}
        add (1|M0)               r7.0<1>:ud    r7.0<0;1,0>:ud    r8.0<0;1,0>:ud   {Compacted,I@1}
(W)     mul (1|M0)               acc0.0<1>:ud  r7.0<0;1,0>:ud    r1.10<0;1,0>:uw  {I@1}
        mach (1|M0)              r5.0<1>:ud    r7.0<0;1,0>:ud    r1.5<0;1,0>:ud   {Compacted}
        add (1|M0)               r1.4<1>:ud    r1.4<0;1,0>:ud    -r5.0<0;1,0>:ud  {I@1}
        cmp (1|M0)    (ge)f0.0   null<1>:ud    r1.4<0;1,0>:ud    r1.5<0;1,0>:ud   {I@1}
(f0.0)  sel (1|M0)               r9.0<1>:d     r6.0<0;1,0>:w     0:w              
        add3 (1|M0)              r7.0<1>:d     r7.0<0;0>:d       r83.5<0;0>:d      r9.0<0>:d        {I@1}
        xor (1|M0)               r47.6<1>:d    r7.0<0;1,0>:d     r83.5<0;1,0>:d   {I@1}
        mov (1|M0)               cr0.0<1>:ud   r1.2<0;1,0>:d                    {A@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        ret (16|M0)                          r83.2                            {A@1}
L7280:
        mov (2|M0)               r83.0<1>:d    0x1:v                              
        mov (1|M0)               r82.2<2>:f    0.0:f                              
        mov (1|M0)               r82.3<2>:f    0.0:f                              
        mov (1|M0)               r82.4<2>:f    0.0:f                              
        mov (1|M0)               r82.5<2>:d    0:d                              
        mov (1|M0)               r47.7<1>:d    63:w                              
L7376:
        and (1|M0)    (eq)f1.0   r2.3<1>:d     r47.7<0;1,0>:d    63:w               {I@1}
(W)     mov (1|M0)               r2.10<1>:hf   0.0:hf                             
        mov (1|M0)               r1.3<1>:d     0:w                              
        shr (1|M0)               r6.2<1>:ud    r82.4<0;1,0>:ud   0x1F:uw              {F@2}
        cmp (1|M0)    (ge)f1.1   null<1>:ud    r2.3<0;1,0>:ud    0x20:uw              {I@3}
(f1.0)  sel (1|M0)               r4.7<1>:d     r2.10<0;1,0>:w    -1:w               {F@1}
        add (1|M0)               r2.4<1>:d     -r2.3<0;1,0>:d    32:w              
        add (1|M0)               r5.1<1>:d     r2.3<0;1,0>:d     -32:w              
        and (1|M0)               r5.0<1>:d     r49.5<0;1,0>:d    r4.7<0;1,0>:d    {I@3}
        shr (1|M0)               r1.2<1>:ud    r49.4<0;1,0>:ud   r2.3<0;1,0>:ud  
(f1.1)  sel (1|M0)               r4.6<1>:d     r2.10<0;1,0>:w    -1:w              
        shr (1|M0)               r5.1<1>:ud    r49.5<0;1,0>:ud   r5.1<0;1,0>:ud   {I@4}
        shl (1|M0)               r5.0<1>:d     r5.0<0;1,0>:d     r2.4<0;1,0>:d    {Compacted,I@4}
        shr (1|M0)               r1.3<1>:ud    r49.5<0;1,0>:ud   r2.3<0;1,0>:ud  
        shl (1|M0)               r2.5<1>:d     r82.5<0;1,0>:d    1:w              
        and (1|M0)               r1.2<1>:ud    r1.2<0;1,0>:ud    r4.6<0;1,0>:ud   {I@5}
        and (1|M0)               r5.1<1>:ud    r5.1<0;1,0>:ud    ~r4.6<0;1,0>:ud  {I@5}
        and (1|M0)               r5.0<1>:d     r5.0<0;1,0>:d     r4.6<0;1,0>:d    {Compacted,I@5}
        shl (1|M0)               r7.0<1>:d     r82.4<0;1,0>:d    1:w               {Compacted}
        and (1|M0)               r6.1<1>:ud    r1.3<0;1,0>:ud    r4.6<0;1,0>:ud   {I@6}
        or (1|M0)                r7.1<1>:d     r2.5<0;1,0>:d     r6.2<0;1,0>:d    {I@6}
        bfn.0xFE (1|M0)          r6.0<1>:ud    r5.1<0;0>:ud      r1.2<0;0>:ud      r5.0<0>:ud       {I@4} // s0|s1|s2
(W)     mov (1|M0)               r1.3<1>:hf    0x1:hf                             
        bfn.0xEA (2|M0)          r7.0<1>:ud    r7.0<1;0>:ud      r6.0<1;0>:ud      r83.0<1>:ud      {I@1} // s0|s1&s2
        and (1|M0)               r4.7<1>:d     r4.7<0;1,0>:d     1:w              
        cmp (1|M0)    (lt)f1.1   null<1>:ud    r7.0<0;1,0>:ud    r49.6<0;1,0>:ud  {I@2}
        cmp (1|M0)    (lt)f0.1   null<1>:ud    r7.1<0;1,0>:ud    r49.7<0;1,0>:ud 
(W)     mov (1|M0)               r2.10<1>:hf   0x1:hf                             
        shl (1|M0)               r2.3<1>:ud    r1.3<0;1,0>:uw    r2.3<0;1,0>:ud   {F@2}
(f1.1)  cmp (1|M0)    (eq)f1.1   null<1>:d     r7.1<0;1,0>:d     r49.7<0;1,0>:d  
(f0.1)  sel (1|M0)               r1.5<1>:uw    r1.3<0;1,0>:uw    0x0:uw             
        subb (1|M0)              r8.0<1>:ud    r7.0<0;1,0>:ud    r49.6<0;1,0>:ud  {AccWrEn}
        shr (1|M0)               r4.7<1>:ud    r4.7<0;1,0>:ud    r2.4<0;1,0>:ud   {I@7}
(f1.1)  sel (1|M0)               r1.4<1>:uw    r1.3<0;1,0>:uw    0x0:uw             
        cmp (1|M0)    (eq)f1.1   null<1>:d     r47.7<0;1,0>:d    0:w              
        shl (1|M0)               r5.0<1>:d     r2.10<0;1,0>:w    -r2.4<0;1,0>:d   {F@1}
        or (1|M0)     (ne)f0.1   null<1>:uw    r1.4<0;1,0>:uw    r1.5<0;1,0>:uw   {I@3}
        and (1|M0)               r82.0<1>:ud   r2.3<0;1,0>:ud    r4.6<0;1,0>:ud  
(W)     and (1|M0)               f0.0<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        bfn.0xCA (1|M0)          r82.1<1>:ud   r5.0<0;0>:ud      r4.7<0;0>:ud      r4.6<0>:ud       {I@5} // s0&~s2|s1&s2
        add (1|M0)               r48.5<1>:d    r47.7<0;1,0>:d    -1:w              
        mov (1|M0)               r82.4<1>:d    r8.0<0;1,0>:d                   
        add3 (1|M0)              r82.5<1>:d    r7.1<0;0>:d       -r9.0<0;0>:d      -r49.7<0>:d      {I@4}
        or (2|M0)                r82.0<1>:d    r82.0<1;1,0>:d    r82.2<1;1,0>:d   {I@4}
(f0.1)  mov (1|M0)               r82.4<1>:d    r7.0<0;1,0>:d                   
(f0.1)  mov (1|M0)               r82.5<1>:d    r7.1<0;1,0>:d                   
(f0.1)  mov (1|M0)               r82.0<1>:ud   r82.2<0;1,0>:d                  
(f0.1)  mov (1|M0)               r82.1<1>:ud   r82.3<0;1,0>:d                  
(f0.0.any16h) goto (16|M0)                   L8192                  L8192                
L8144:
(W)     mov (2|M0)               r82.2<1>:ud   r82.0<1;1,0>:ud                  {I@2}
        mov (1|M0)               r47.7<1>:d    r48.5<0;1,0>:d                  
        goto.b (16|M0)                       L8192                  L7376                
L8192:
        join (16|M0)                         L8208                                
L8208:
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        ret (16|M0)                          r82.6                            {A@1}
L8256:
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
