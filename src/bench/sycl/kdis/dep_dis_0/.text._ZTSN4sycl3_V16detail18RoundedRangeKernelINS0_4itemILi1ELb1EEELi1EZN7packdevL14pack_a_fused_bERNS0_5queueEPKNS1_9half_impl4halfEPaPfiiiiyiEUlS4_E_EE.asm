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
        mov (1|M0)               r18.4<1>:d    r8.0<0;1,0>:d                    {I@1}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        cmp (1|M0)    (lt)f0.0   null<1>:ud    r18.4<0;1,0>:ud   r3.0<0;1,0>:ud   {I@2}
        add3 (1|M0)              r18.5<1>:d    r9.0<0;0>:d       r7.0<0;0>:d       0:w               {I@2}
        mul (1|M0)               acc0.0<1>:ud  r2.0<0;1,0>:ud    r2.6<0;1,0>:uw  
        cmp (1|M0)    (lt)f1.0   null<1>:ud    r18.5<0;1,0>:ud   r3.1<0;1,0>:ud   {I@2}
(f0.0)  cmp (1|M0)    (eq)f0.0   null<1>:d     r18.5<0;1,0>:d    r3.1<0;1,0>:d   
        mach (1|M0)              r11.0<1>:ud   r2.0<0;1,0>:ud    r2.3<0;1,0>:ud   {AccWrEn}
(f1.0)  sel (1|M0)               r2.12<1>:uw   r1.3<0;1,0>:uw    0x0:uw              {F@1}
(f0.0)  sel (1|M0)               r1.4<1>:uw    r1.3<0;1,0>:uw    0x0:uw             
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        or (1|M0)     (ne)f1.1   null<1>:uw    r1.4<0;1,0>:uw    r2.12<0;1,0>:uw  {I@2}
        mov (1|M0)               r17.1<1>:d    r11.0<0;1,0>:d                  
        mov (1|M0)               r17.0<1>:f    r10.0<0;1,0>:f                   {Compacted,I@3}
(W)     and (1|M0)               f1.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(~f1.1.any16h) goto (16|M0)                  L5000                  L5000                
L544:
        asr (1|M0)               r1.2<1>:d     r4.7<0;1,0>:d     31:w              
        mov (1|M0)               r17.6<1>:d    r4.1<0;1,0>:d                   
        shr (1|M0)               r1.2<1>:ud    r1.2<0;1,0>:ud    0x1B:uw              {I@2}
        mov (1|M0)               r17.2<1>:d    r4.0<0;1,0>:d                   
        add (1|M0)               r1.2<1>:d     r4.7<0;1,0>:d     r1.2<0;1,0>:d    {I@2}
        asr (1|M0)               r17.3<1>:d    r4.0<0;1,0>:d     31:w               {Compacted}
        mov (1|M0)               r18.0<1>:d    r4.7<0;1,0>:d                   
        asr (1|M0)               r18.1<1>:d    r4.7<0;1,0>:d     31:w              
        mov (1|M0)               r18.3<1>:d    0:w                              
        mov (2|M0)               r17.4<1>:d    r17.6<1;1,0>:d                  
        asr (1|M0)               r18.2<1>:d    r1.2<0;1,0>:d     5:w               {I@6}
        asr (1|M0)               r17.5<1>:d    r4.1<0;1,0>:d     31:w              
        mov (1|M0)               r17.7<1>:d    0:w                              
L744:
(W)     mov (2|M0)               r33.2<1>:ud   r18.4<1;1,0>:ud                 
(W)     mov (2|M0)               r33.4<1>:ud   r17.2<1;1,0>:ud                  {I@7}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r36.6         L5072                                 {A@1}
L824:
        mul (1|M0)               acc0.0<1>:ud  r18.6<0;1,0>:ud   r17.4<0;1,0>:uw 
        mach (1|M0)              r7.0<1>:ud    r18.6<0;1,0>:ud   r17.2<0;1,0>:ud  {AccWrEn}
        cmp (1|M0)    (gt)f0.0   null<1>:d     r4.1<0;1,0>:d     0:w              
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r18.6<0;1,0>:d    r17.6<0;1,0>:uw 
        mach (1|M0)              r8.0<1>:d     r18.6<0;1,0>:d    r17.3<0;1,0>:d  
(W)     mul (1|M0)               acc0.0<1>:d   r18.7<0;1,0>:d    r17.4<0;1,0>:uw 
        mach (1|M0)              r9.0<1>:d     r18.7<0;1,0>:d    r17.2<0;1,0>:d  
        subb (1|M0)              r10.0<1>:ud   r18.4<0;1,0>:ud   r6.0<0;1,0>:ud   {AccWrEn,A@1}
        add3 (1|M0)              r1.3<1>:d     r9.0<0;0>:d       r7.0<0;0>:d       r8.0<0>:d        {I@2}
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r19.0<1>:f    r10.0<0;1,0>:f                   {Compacted,I@3}
        add3 (1|M0)              r19.1<1>:d    r18.5<0;0>:d      -r11.0<0;0>:d     -r1.3<0>:d       {I@1}
        shr (1|M0)               r2.6<1>:ud    r19.0<0;1,0>:ud   0x7:uw              {F@1}
        shl (1|M0)               r2.7<1>:d     r19.1<0;1,0>:d    25:w               {I@2}
        shr (1|M0)               r3.3<1>:ud    r19.1<0;1,0>:ud   0x7:uw             
        or (1|M0)                r3.2<1>:d     r2.6<0;1,0>:d     r2.7<0;1,0>:d    {I@2}
        shr (1|M0)               r3.4<1>:ud    r19.0<0;1,0>:ud   0x4:uw             
        mul (1|M0)               acc0.0<1>:ud  r3.2<0;1,0>:ud    r17.8<0;1,0>:uw  {I@2}
        mach (1|M0)              r8.0<1>:ud    r3.2<0;1,0>:ud    r17.4<0;1,0>:ud  {AccWrEn}
        shl (1|M0)               r3.5<1>:d     r19.1<0;1,0>:d    28:w              
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r3.2<0;1,0>:d     r17.10<0;1,0>:uw
        mach (1|M0)              r9.0<1>:d     r3.2<0;1,0>:d     r17.5<0;1,0>:d  
(W)     mul (1|M0)               acc0.0<1>:d   r3.3<0;1,0>:d     r17.8<0;1,0>:uw 
        mach (1|M0)              r10.0<1>:d    r3.3<0;1,0>:d     r17.4<0;1,0>:d  
        mul (1|M0)               acc0.0<1>:ud  r18.6<0;1,0>:ud   r4.8<0;1,0>:uw  
        cmp (1|M0)    (lt)f0.1   null<1>:d     r19.0<0;1,0>:d    r4.6<0;1,0>:d   
        mach (1|M0)              r12.0<1>:ud   r18.6<0;1,0>:ud   r4.4<0;1,0>:ud   {AccWrEn}
        mov (2|M0)               r6.0<1>:w     0x7070707:v                              
        shr (1|M0)               r19.3<1>:ud   r19.1<0;1,0>:ud   0x4:uw             
        or (1|M0)                r19.2<1>:d    r3.4<0;1,0>:d     r3.5<0;1,0>:d    {I@7}
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r18.6<0;1,0>:d    r4.10<0;1,0>:uw 
        and (2|M0)               r19.2<1>:d    r19.2<1;1,0>:d    r6.0<1;1,0>:w    {I@3}
        mach (1|M0)              r6.0<1>:d     r18.6<0;1,0>:d    r4.5<0;1,0>:d   
(W)     mul (1|M0)               acc0.0<1>:d   r18.7<0;1,0>:d    r4.8<0;1,0>:uw  
(W)     and (1|M0)               f1.0<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
        mach (1|M0)              r13.0<1>:d    r18.7<0;1,0>:d    r4.4<0;1,0>:d   
        addc (1|M0)              r14.0<1>:ud   r4.2<0;1,0>:ud    r11.0<0;1,0>:ud  {AccWrEn,I@7}
        add3 (1|M0)              r1.3<1>:d     r13.0<0;0>:d      r12.0<0;0>:d      r6.0<0>:d        {I@2}
        mov (1|M0)               r15.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        and (1|M0)               r19.4<1>:d    r19.0<0;1,0>:d    15:w               {Compacted}
        mov (1|M0)               r19.5<1>:d    r7.0<0;1,0>:d                   
        add3 (1|M0)              r19.6<1>:d    r10.0<0;0>:d      r8.0<0;0>:d       r9.0<0>:d       
        mov (1|M0)               r20.0<1>:f    r14.0<0;1,0>:f                   {Compacted,I@6}
        add3 (1|M0)              r20.1<1>:d    r15.0<0;0>:d      r4.3<0;0>:d       r1.3<0>:d        {I@4}
(f1.0.any16h) goto (16|M0)                   L2112                  L2112                
L1528:
        shl (1|M0)               r1.4<1>:d     r19.2<0;1,0>:d    9:w              
        shl (1|M0)               r1.2<1>:d     r19.3<0;1,0>:d    9:w              
        shr (1|M0)               r1.3<1>:ud    r19.2<0;1,0>:ud   0x17:uw             
        shl (1|M0)               r3.2<1>:d     r19.4<0;1,0>:d    5:w               {I@7}
        addc (1|M0)              r6.0<1>:ud    r20.0<0;1,0>:ud   r1.4<0;1,0>:ud   {AccWrEn,A@1}
(W)     and (1|M0)               f0.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@4}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r8.0<1>:ud    r6.0<0;1,0>:ud    r3.2<0;1,0>:ud   {AccWrEn,I@4}
        add3 (1|M0)              r2.7<1>:d     r7.0<0;0>:d       r20.1<0;0>:d      r1.5<0>:d        {I@2}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r20.2<1>:d    r8.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r20.3<1>:d    r9.0<0;0>:d       r2.7<0;0>:d       0:w               {I@2}
(~f0.1.any16h) goto (16|M0)                  L2112                  L4760                
L1736:
        mov (1|M0)               r20.4<2>:f    0.0:f                              
        mov (1|M0)               r20.5<2>:d    0:d                              
L1768:
        addc (1|M0)              r6.0<1>:ud    r20.4<0;1,0>:ud   r19.5<0;1,0>:ud  {AccWrEn,F@1}
        mov (4|M0)               r11.0<2>:f    0.0:f                               {$2.src}
        shl (1|M0)               r3.2<1>:d     r6.0<0;1,0>:d     12:w               {Compacted,I@1}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r8.0<1>:ud    r20.2<0;1,0>:ud   r3.2<0;1,0>:ud   {AccWrEn,I@2}
        add3 (1|M0)              r1.3<1>:d     r7.0<0;0>:d       r20.5<0;0>:d      r19.6<0>:d       {I@2}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r7.0<1>:ud    r20.4<0;1,0>:ud   0x1:ud              {AccWrEn}
        shr (1|M0)               r2.7<1>:ud    r6.0<0;1,0>:ud    0x14:uw             
        mov (1|M0)               r12.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r20.6<1>:d    r7.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r20.7<1>:d    r12.0<0;0>:d      r20.5<0;0>:d      0:w               {I@2}
        shl (1|M0)               r2.6<1>:d     r1.3<0;1,0>:d     12:w              
        cmp (1|M0)    (eq)f1.1   null<1>:d     r20.7<0;1,0>:d    r17.7<0;1,0>:d   {I@2}
        or (1|M0)                r3.3<1>:d     r2.6<0;1,0>:d     r2.7<0;1,0>:d    {I@2}
        mov (4|M0)               r11.1<2>:f    0.0:f                              
        mov (1|M0)               r10.0<1>:f    r8.0<0;1,0>:f                    {Compacted}
(f1.1)  cmp (1|M0)    (eq)f1.1   null<1>:d     r20.6<0;1,0>:d    r17.6<0;1,0>:d  
        add3 (1|M0)              r10.1<1>:d    r9.0<0;0>:d       r20.3<0;0>:d      r3.3<0>:d        {I@2}
        send.ugm (1|M0)          null     r10     r11:1   0x0            0x0200B784           {A@1,$2} // wr:1+1, rd:0; store.ugm.d64x4t.a64
(W)     and (1|M0)               f1.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(f1.1.any16h) goto (16|M0)                   L2112                  L4760                
L2080:
(W)     mov (2|M0)               r20.4<1>:ud   r20.6<1;1,0>:ud                 
        goto.b (16|M0)                       L2112                  L1768                
L2112:
        join (16|M0)                         L4760                                
L2128:
        cmp (1|M0)    (gt)f1.0   null<1>:d     r4.7<0;1,0>:d     31:w              
        mov (16|M0)              r22.0<1>:ud   0x0:ud                             
        mov (16|M0)              r24.0<1>:f    0.0:f                               {Compacted}
(W)     and (1|M0)               f1.0<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
(~f1.0.any16h) goto (16|M0)                  L2856                  L2856                
L2200:
        mul (1|M0)               acc0.0<1>:ud  r19.0<0;1,0>:ud   r18.0<0;1,0>:uw 
        mach (1|M0)              r7.0<1>:ud    r19.0<0;1,0>:ud   r18.0<0;1,0>:ud  {AccWrEn}
        mov (1|M0)               r21.2<2>:f    0.0:f                              
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r19.0<0;1,0>:d    r18.2<0;1,0>:uw  {Compacted}
        mach (1|M0)              r8.0<1>:d     r19.0<0;1,0>:d    r18.1<0;1,0>:d   {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r19.1<0;1,0>:d    r18.0<0;1,0>:uw  {Compacted}
        mach (1|M0)              r9.0<1>:d     r19.1<0;1,0>:d    r18.0<0;1,0>:d   {Compacted}
        shl (1|M0)               r3.2<1>:d     r6.0<0;1,0>:d     1:w               {Compacted,I@5}
        add3 (1|M0)              r1.3<1>:d     r9.0<0;0>:d       r7.0<0;0>:d       r8.0<0>:d        {I@2}
        shr (1|M0)               r2.7<1>:ud    r6.0<0;1,0>:ud    0x1F:uw             
        sync.nop                             null                             {Compacted,$2.src}
        addc (1|M0)              r10.0<1>:ud   r5.0<0;1,0>:ud    r3.2<0;1,0>:ud   {AccWrEn,I@3}
        shl (1|M0)               r2.6<1>:d     r1.3<0;1,0>:d     1:w               {I@3}
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        or (1|M0)                r3.3<1>:d     r2.6<0;1,0>:d     r2.7<0;1,0>:d    {I@2}
        mov (1|M0)               r21.3<2>:f    0.0:f                              
        mov (1|M0)               r21.0<1>:f    r10.0<0;1,0>:f                   {Compacted}
        add3 (1|M0)              r21.1<1>:d    r11.0<0;0>:d      r5.1<0;0>:d       r3.3<0>:d        {I@1}
L2432:
        shl (1|M0)               r1.2<1>:d     r21.3<0;1,0>:d    5:w               {F@2}
        shr (1|M0)               r1.3<1>:ud    r21.2<0;1,0>:ud   0x1B:uw             
        shl (1|M0)               r1.4<1>:d     r21.2<0;1,0>:d    5:w              
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        shl (1|M0)               r3.2<1>:d     r1.4<0;1,0>:d     1:w               {I@2}
        shr (1|M0)               r2.7<1>:ud    r1.4<0;1,0>:ud    0x1F:uw             
        shl (1|M0)               r2.6<1>:d     r1.5<0;1,0>:d     1:w               {I@3}
        addc (1|M0)              r6.0<1>:ud    r21.0<0;1,0>:ud   r3.2<0;1,0>:ud   {AccWrEn,A@1}
        or (1|M0)                r3.3<1>:d     r2.6<0;1,0>:d     r2.7<0;1,0>:d    {I@2}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r8.0<1>:f     r6.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r8.1<1>:d     r7.0<0;0>:d       r21.1<0;0>:d      r3.3<0>:d        {I@1}
        addc (1|M0)              r15.0<1>:ud   r21.2<0;1,0>:ud   0x1:ud              {AccWrEn}
        send.ugm (1|M0)          r9       r8      null:0  0x0            0x0220C780           {A@1,$4} // wr:1+0, rd:2; load.ugm.d64x8t.a64
        mov (1|M0)               r16.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r21.4<1>:d    r15.0<0;1,0>:d                   {I@2}
        add3 (1|M0)              r21.5<1>:d    r16.0<0;0>:d      r21.3<0;0>:d      0:w               {I@2}
        cmp (1|M0)    (eq)f1.0   null<1>:d     r21.5<0;1,0>:d    r18.3<0;1,0>:d   {I@1}
(f1.0)  cmp (1|M0)    (eq)f1.0   null<1>:d     r21.4<0;1,0>:d    r18.2<0;1,0>:d  
(W)     and (1|M0)               f0.1<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
        mov (8|M0)               r11.0<1>:f    (abs)r9.0<1;1,0>:hf              {$4.dst}
        mov (8|M0)               r12.0<1>:f    (abs)r9.8<1;1,0>:hf             
        mov (8|M0)               r13.0<1>:f    (abs)r10.0<1;1,0>:hf            
        mov (8|M0)               r14.0<1>:f    (abs)r10.8<1;1,0>:hf            
        sel (16|M0)   (ge)f0.0   r22.0<1>:f    r22.0<1;1,0>:f    r11.0<1;1,0>:f   {Compacted,F@3}
        sel (16|M0)   (ge)f0.0   r24.0<1>:f    r24.0<1;1,0>:f    r13.0<1;1,0>:f   {Compacted,F@2}
(f0.1.any16h) goto (16|M0)                   L2856                  L2856                
L2824:
(W)     mov (2|M0)               r21.2<1>:ud   r21.4<1;1,0>:ud                 
        goto.b (16|M0)                       L2856                  L2432                
L2856:
        join (16|M0)                         L4760                                
L2872:
        sel (16|M0)   (ge)f0.0   r22.0<1>:f    r22.0<1;1,0>:f    r24.0<1;1,0>:f   {Compacted,F@1}
        sel (8|M0)    (ge)f0.0   r6.0<1>:f     r22.0<1;1,0>:f    r23.0<1;1,0>:f   {Compacted,F@1}
        mov (4|M0)               r7.0<1>:ud    r6.4<1;1,0>:ud                   {F@1}
        sel (4|M0)    (ge)f0.0   r8.0<1>:f     r6.0<1;1,0>:f     r7.0<1;1,0>:f    {I@1}
        mov (2|M0)               r9.0<1>:ud    r8.2<1;1,0>:ud                   {F@1}
        sync.nop                             null                             {Compacted,$2.src}
        sel (2|M0)    (ge)f0.0   r10.0<1>:f    r8.0<1;1,0>:f     r9.0<1;1,0>:f    {I@1}
        sel (1|M0)    (ge)f0.0   r87.0<1>:f    r10.0<0;1,0>:f    r10.1<0;1,0>:f   {F@1}
        cmp (1|M0)    (eq)f0.1   null<1>:f     r87.0<0;1,0>:f    0.0:f               {F@1}
(W)     and (1|M0)               f1.1<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(f1.1.any16h) goto (16|M0)                   L3104                  L3104                
L3024:
        mov (1|M0)               r87.1<1>:f    127.0:f                              
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r65.6         L6040                                 {A@1}
L3088:
        goto (16|M0)                         L3104                  L3128                
L3104:
        join (16|M0)                         L3128                                
L3120:
        mov (1|M0)               r26.0<1>:f    1.0:f                               {Compacted}
L3128:
        join (16|M0)                         L4760                                
L3144:
        shl (1|M0)               r1.4<1>:d     r19.0<0;1,0>:d    2:w               {Compacted}
        shl (1|M0)               r1.2<1>:d     r19.1<0;1,0>:d    2:w              
        addc (1|M0)              r6.0<1>:ud    r5.2<0;1,0>:ud    r1.4<0;1,0>:ud   {AccWrEn,I@2}
        shr (1|M0)               r1.3<1>:ud    r19.0<0;1,0>:ud   0x1E:uw             
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mul (1|M0)               acc0.0<1>:ud  r19.0<0;1,0>:ud   r18.0<0;1,0>:uw 
        mach (1|M0)              r10.0<1>:ud   r19.0<0;1,0>:ud   r18.0<0;1,0>:ud  {AccWrEn}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@4}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r19.0<0;1,0>:d    r18.2<0;1,0>:uw  {Compacted}
        shl (1|M0)               r1.2<1>:d     r9.0<0;1,0>:d     1:w               {Compacted,I@2}
        mach (1|M0)              r11.0<1>:d    r19.0<0;1,0>:d    r18.1<0;1,0>:d   {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r19.1<0;1,0>:d    r18.0<0;1,0>:uw  {Compacted}
        mov (1|M0)               r8.0<1>:f     r6.0<0;1,0>:f                    {Compacted}
        mach (1|M0)              r12.0<1>:d    r19.1<0;1,0>:d    r18.0<0;1,0>:d   {Compacted}
        addc (1|M0)              r6.0<1>:ud    r5.0<0;1,0>:ud    r1.2<0;1,0>:ud   {AccWrEn,A@1}
        add3 (1|M0)              r8.1<1>:d     r7.0<0;0>:d       r5.3<0;0>:d       r1.5<0>:d       
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mul (1|M0)               acc0.0<1>:ud  r18.6<0;1,0>:ud   r5.8<0;1,0>:uw  
        add3 (1|M0)              r2.7<1>:d     r12.0<0;0>:d      r10.0<0;0>:d      r11.0<0>:d       {I@5}
        mach (1|M0)              r14.0<1>:ud   r18.6<0;1,0>:ud   r5.4<0;1,0>:ud   {AccWrEn}
        shr (1|M0)               r3.3<1>:ud    r9.0<0;1,0>:ud    0x1F:uw             
        shl (1|M0)               r3.2<1>:d     r2.7<0;1,0>:d     1:w               {I@3}
        mov (1|M0)               r13.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        or (1|M0)                r1.3<1>:d     r3.2<0;1,0>:d     r3.3<0;1,0>:d    {I@2}
(W)     mul (1|M0)               acc0.0<1>:d   r18.6<0;1,0>:d    r5.10<0;1,0>:uw 
        shl (1|M0)               r3.4<1>:d     r13.0<0;1,0>:d    1:w               {Compacted,I@3}
        send.ugm (1|M0)          null     r8      r26:1   0x0            0x04000584           {$5} // wr:2+1, rd:0; store.ugm.d32.a64
        mach (1|M0)              r8.0<1>:d     r18.6<0;1,0>:d    r5.5<0;1,0>:d    {$5.src}
(W)     mul (1|M0)               acc0.0<1>:d   r18.7<0;1,0>:d    r5.8<0;1,0>:uw  
        shl (1|M0)               r1.4<1>:d     r19.2<0;1,0>:d    9:w              
        add3 (1|M0)              r5.7<1>:d     r7.0<0;0>:d       r5.1<0;0>:d       r1.3<0>:d        {I@6}
        mach (1|M0)              r11.0<1>:d    r18.7<0;1,0>:d    r5.4<0;1,0>:d   
        addc (1|M0)              r7.0<1>:ud    r6.0<0;1,0>:ud    r3.4<0;1,0>:ud   {AccWrEn,I@6}
        shl (1|M0)               r1.2<1>:d     r19.3<0;1,0>:d    9:w              
        shl (1|M0)               r8.1<1>:d     r19.4<0;1,0>:d    5:w              
        shr (1|M0)               r1.3<1>:ud    r19.2<0;1,0>:ud   0x17:uw             
        add3 (1|M0)              r2.7<1>:d     r11.0<0;0>:d      r14.0<0;0>:d      r8.0<0>:d        {I@5}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r8.0<1>:ud    r20.0<0;1,0>:ud   r1.4<0;1,0>:ud   {AccWrEn}
(W)     and (1|M0)               f1.0<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
        shr (1|M0)               r3.3<1>:ud    r13.0<0;1,0>:ud   0x1F:uw             
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@6}
        shl (1|M0)               r3.2<1>:d     r2.7<0;1,0>:d     1:w               {I@6}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r6.0<1>:ud    r8.0<0;1,0>:ud    r8.1<0;1,0>:ud   {AccWrEn,I@6}
        or (1|M0)                r3.5<1>:d     r3.2<0;1,0>:d     r3.3<0;1,0>:d    {I@3}
        add3 (1|M0)              r2.7<1>:d     r10.0<0;0>:d      r20.1<0;0>:d      r1.5<0>:d        {I@3}
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r21.6<1>:d    r7.0<0;1,0>:d                   
        mov (1|M0)               r26.1<1>:d    r6.0<0;1,0>:d                    {I@5}
        add3 (1|M0)              r21.7<1>:d    r9.0<0;0>:d       r5.7<0;0>:d       r3.5<0>:d        {I@5}
        add3 (1|M0)              r26.2<1>:d    r11.0<0;0>:d      r2.7<0;0>:d       0:w               {I@4}
(~f1.0.any16h) goto (16|M0)                  L4760                  L4760                
L3888:
        mov (16|M0)              r27.0<1>:f    r26.0<0;1,0>:f                   {Compacted}
        mov (1|M0)               r26.4<2>:d    0:d                              
        mov (1|M0)               r26.5<2>:d    0:d                              
L3928:
        shl (1|M0)               r1.2<1>:d     r26.5<0;1,0>:d    5:w               {I@1}
        shr (1|M0)               r1.3<1>:ud    r26.4<0;1,0>:ud   0x1B:uw             
        shl (1|M0)               r1.4<1>:d     r26.4<0;1,0>:d    5:w              
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        shl (1|M0)               r3.2<1>:d     r1.4<0;1,0>:d     1:w               {I@2}
        shr (1|M0)               r2.7<1>:ud    r1.4<0;1,0>:ud    0x1F:uw             
        shl (1|M0)               r2.6<1>:d     r1.5<0;1,0>:d     1:w               {I@3}
        addc (1|M0)              r6.0<1>:ud    r21.6<0;1,0>:ud   r3.2<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r3.3<1>:d     r2.6<0;1,0>:d     r2.7<0;1,0>:d    {I@2}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r8.0<1>:f     r6.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r8.1<1>:d     r7.0<0;0>:d       r21.7<0;0>:d      r3.3<0>:d        {I@1}
        mov (16|M0)              r44.0<1>:f    r27.0<1;1,0>:f                   {Compacted,F@2}
        send.ugm (1|M0)          r9       r8      null:0  0x0            0x0220C780           {A@1,$6} // wr:1+0, rd:2; load.ugm.d64x8t.a64
        mov (8|M0)               r37.0<1>:f    r9.0<1;1,0>:hf                   {$6.dst}
        mov (8|M0)               r38.0<1>:f    r9.8<1;1,0>:hf                  
        mov (8|M0)               r29.0<1>:f    r10.0<1;1,0>:hf                 
        mov (8|M0)               r30.0<1>:f    r10.8<1;1,0>:hf                 
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r87.2         L10064                                 {A@1}
L4240:
        mov (16|M0)              r31.0<1>:ud   r79.0<1;1,0>:ud                 
        mov (16|M0)              r37.0<1>:f    r29.0<1;1,0>:f                   {Compacted,F@1}
        mov (16|M0)              r44.0<1>:f    r27.0<1;1,0>:f                   {Compacted}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r87.2         L10064                                 {A@1}
L4320:
        addc (1|M0)              r6.0<1>:ud    r26.4<0;1,0>:ud   r19.5<0;1,0>:ud  {AccWrEn}
        rnde (16|M0)             r31.0<1>:f    r31.0<1;1,0>:f                   {Compacted,I@3}
        shl (1|M0)               r3.2<1>:d     r6.0<0;1,0>:d     12:w               {Compacted,I@1}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r8.0<1>:ud    r26.1<0;1,0>:ud   r3.2<0;1,0>:ud   {AccWrEn,I@2}
        add3 (1|M0)              r1.3<1>:d     r7.0<0;0>:d       r26.5<0;0>:d      r19.6<0>:d       {I@2}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r7.0<1>:ud    r26.4<0;1,0>:ud   0x1:ud              {AccWrEn}
        shr (1|M0)               r2.7<1>:ud    r6.0<0;1,0>:ud    0x14:uw             
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        rnde (16|M0)             r79.0<1>:f    r79.0<1;1,0>:f                   {Compacted}
        add3 (1|M0)              r26.7<1>:d    r6.0<0;0>:d       r26.5<0;0>:d      0:w               {I@1}
        mov (1|M0)               r26.6<1>:d    r7.0<0;1,0>:d                   
        cmp (1|M0)    (eq)f0.1   null<1>:d     r26.7<0;1,0>:d    r17.7<0;1,0>:d   {I@2}
        sel (16|M0)   (ge)f0.0   r31.0<1>:f    r31.0<1;1,0>:f    -127.0:f               {F@2}
        sel (16|M0)   (ge)f0.0   r79.0<1>:f    r79.0<1;1,0>:f    -127.0:f               {F@2}
(f0.1)  cmp (1|M0)    (eq)f0.1   null<1>:d     r26.6<0;1,0>:d    r17.6<0;1,0>:d   {I@2}
        shl (1|M0)               r2.6<1>:d     r1.3<0;1,0>:d     12:w              
        sel (16|M0)   (lt)f0.0   r31.0<1>:f    r31.0<1;1,0>:f    127.0:f               {F@2}
        sel (16|M0)   (lt)f0.0   r79.0<1>:f    r79.0<1;1,0>:f    127.0:f               {F@2}
        or (1|M0)                r3.3<1>:d     r2.6<0;1,0>:d     r2.7<0;1,0>:d    {I@1}
        mov (16|M0)              r11.0<1>:d    r31.0<1;1,0>:f                   {Compacted,F@2}
(W)     and (1|M0)               f0.1<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
        mov (16|M0)              r13.0<1>:d    r79.0<1;1,0>:f                   {Compacted,F@1}
        mov (1|M0)               r10.0<1>:f    r8.0<0;1,0>:f                    {Compacted}
        add3 (1|M0)              r10.1<1>:d    r9.0<0;0>:d       r26.2<0;0>:d      r3.3<0>:d        {I@4}
        mov (16|M0)              r15.0<1>:b    r11.0<4;1,0>:b                   {I@4}
        mov (16|M0)              r15.16<1>:b   r13.0<4;1,0>:b                   {I@3}
        send.ugm (1|M0)          null     r10     r15:1   0x0            0x0200B784           {A@1,$3} // wr:1+1, rd:0; store.ugm.d64x4t.a64
(f0.1.any16h) goto (16|M0)                   L4760                  L4760                
L4728:
(W)     mov (2|M0)               r26.4<1>:ud   r26.6<1;1,0>:ud                 
        goto.b (16|M0)                       L4760                  L3928                
L4760:
        join (16|M0)                         L5000                                
L4776:
        addc (1|M0)              r6.0<1>:ud    r18.4<0;1,0>:ud   r17.0<0;1,0>:ud  {AccWrEn}
(W)     mov (1|M0)               r1.3<1>:hf    0x1:hf                             
        mov (1|M0)               r33.0<1>:f    r6.0<0;1,0>:f                    {Compacted,I@1}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        cmp (1|M0)    (lt)f0.1   null<1>:ud    r33.0<0;1,0>:ud   r3.0<0;1,0>:ud   {F@1}
        add3 (1|M0)              r33.1<1>:d    r7.0<0;0>:d       r18.5<0;0>:d      r17.1<0>:d       {I@2}
        cmp (1|M0)    (lt)f0.0   null<1>:ud    r33.1<0;1,0>:ud   r3.1<0;1,0>:ud   {I@1}
(f0.1)  cmp (1|M0)    (eq)f0.1   null<1>:d     r33.1<0;1,0>:d    r3.1<0;1,0>:d   
(f0.0)  sel (1|M0)               r2.12<1>:uw   r1.3<0;1,0>:uw    0x0:uw             
(f0.1)  sel (1|M0)               r1.4<1>:uw    r1.3<0;1,0>:uw    0x0:uw             
        or (1|M0)     (ne)f0.0   null<1>:uw    r1.4<0;1,0>:uw    r2.12<0;1,0>:uw  {I@1}
(W)     and (1|M0)               f0.0<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
(~f0.0.any16h) goto (16|M0)                  L5000                  L5000                
L4968:
(W)     mov (2|M0)               r18.4<1>:ud   r33.0<1;1,0>:ud                 
        goto.b (16|M0)                       L5000                  L744                
L5000:
        join (16|M0)                         L5016                                
L5016:
(W)     mov (8|M0)               r127.0<1>:f   r0.0<1;1,0>:f                    {Compacted}
(W)     send.ugm (1|M0)          r6       r0      null:0  0x0            0x0210641F           {$7} // wr:1+0, rd:1; fence invalid flush type scoped to tile
(W)     mov (8|M0)               null<1>:ud    r6.0<1;1,0>:ud                   {$7.dst}
(W)     send.gtwy (1|M0)         null     r127    null:0  0x0            0x02000010           {EOT,A@1} // wr:1+0, rd:0; end of thread
L5072:
        mov (2|M0)               r34.0<1>:d    0x1:v                              
        mov (1|M0)               r33.6<2>:f    0.0:f                              
        mov (1|M0)               r33.7<2>:f    0.0:f                              
        mov (1|M0)               r34.2<2>:f    0.0:f                              
        mov (1|M0)               r34.3<2>:d    0:d                              
        mov (1|M0)               r19.7<1>:d    63:w                              
L5168:
        and (1|M0)    (eq)f1.0   r2.6<1>:d     r19.7<0;1,0>:d    63:w               {I@1}
(W)     mov (1|M0)               r3.4<1>:hf    0.0:hf                             
        mov (1|M0)               r1.3<1>:d     0:w                              
        shr (1|M0)               r3.4<1>:ud    r34.2<0;1,0>:ud   0x1F:uw              {F@2}
        cmp (1|M0)    (ge)f1.1   null<1>:ud    r2.6<0;1,0>:ud    0x20:uw              {I@3}
(f1.0)  sel (1|M0)               r5.6<1>:d     r3.4<0;1,0>:w     -1:w               {F@1}
        add (1|M0)               r2.7<1>:d     -r2.6<0;1,0>:d    32:w              
        add (1|M0)               r6.0<1>:d     r2.6<0;1,0>:d     -32:w               {Compacted}
        and (1|M0)               r5.7<1>:d     r33.3<0;1,0>:d    r5.6<0;1,0>:d    {I@3}
        shr (1|M0)               r1.2<1>:ud    r33.2<0;1,0>:ud   r2.6<0;1,0>:ud  
(f1.1)  sel (1|M0)               r3.3<1>:d     r3.4<0;1,0>:w     -1:w              
        shr (1|M0)               r6.0<1>:ud    r33.3<0;1,0>:ud   r6.0<0;1,0>:ud   {Compacted,I@4}
        shl (1|M0)               r5.7<1>:d     r5.7<0;1,0>:d     r2.7<0;1,0>:d    {I@4}
        shr (1|M0)               r1.3<1>:ud    r33.3<0;1,0>:ud   r2.6<0;1,0>:ud  
        shl (1|M0)               r3.2<1>:d     r34.3<0;1,0>:d    1:w              
        and (1|M0)               r1.2<1>:ud    r1.2<0;1,0>:ud    r3.3<0;1,0>:ud   {I@5}
        and (1|M0)               r6.0<1>:ud    r6.0<0;1,0>:ud    ~r3.3<0;1,0>:ud  {Compacted,I@5}
        and (1|M0)               r5.7<1>:d     r5.7<0;1,0>:d     r3.3<0;1,0>:d    {I@5}
        shl (1|M0)               r8.0<1>:d     r34.2<0;1,0>:d    1:w               {Compacted}
        and (1|M0)               r7.1<1>:ud    r1.3<0;1,0>:ud    r3.3<0;1,0>:ud   {I@6}
        or (1|M0)                r8.1<1>:d     r3.2<0;1,0>:d     r3.4<0;1,0>:d    {I@6}
        bfn.0xFE (1|M0)          r7.0<1>:ud    r6.0<0;0>:ud      r1.2<0;0>:ud      r5.7<0>:ud       {I@4} // s0|s1|s2
(W)     mov (1|M0)               r1.3<1>:hf    0x1:hf                             
        bfn.0xEA (2|M0)          r8.0<1>:ud    r8.0<1;0>:ud      r7.0<1;0>:ud      r34.0<1>:ud      {I@1} // s0|s1&s2
        cmp (1|M0)    (eq)f1.1   null<1>:d     r19.7<0;1,0>:d    0:w              
        cmp (1|M0)    (lt)f0.0   null<1>:ud    r8.0<0;1,0>:ud    r33.4<0;1,0>:ud  {I@2}
        cmp (1|M0)    (lt)f0.1   null<1>:ud    r8.1<0;1,0>:ud    r33.5<0;1,0>:ud 
        and (1|M0)               r5.6<1>:d     r5.6<0;1,0>:d     1:w              
(W)     mov (1|M0)               r3.4<1>:hf    0x1:hf                             
(f0.0)  cmp (1|M0)    (eq)f0.0   null<1>:d     r8.1<0;1,0>:d     r33.5<0;1,0>:d  
(f0.1)  sel (1|M0)               r1.5<1>:uw    r1.3<0;1,0>:uw    0x0:uw              {F@2}
        shl (1|M0)               r2.6<1>:ud    r1.3<0;1,0>:uw    r2.6<0;1,0>:ud  
        subb (1|M0)              r9.0<1>:ud    r8.0<0;1,0>:ud    r33.4<0;1,0>:ud  {AccWrEn}
(f0.0)  sel (1|M0)               r1.4<1>:uw    r1.3<0;1,0>:uw    0x0:uw             
(W)     and (1|M0)               f1.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
        shr (1|M0)               r5.6<1>:ud    r5.6<0;1,0>:ud    r2.7<0;1,0>:ud   {I@7}
        shl (1|M0)               r5.7<1>:d     r3.4<0;1,0>:w     -r2.7<0;1,0>:d   {F@1}
        or (1|M0)     (ne)f0.0   null<1>:uw    r1.4<0;1,0>:uw    r1.5<0;1,0>:uw   {I@4}
        and (1|M0)               r18.6<1>:ud   r2.6<0;1,0>:ud    r3.3<0;1,0>:ud  
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        bfn.0xCA (1|M0)          r18.7<1>:ud   r5.7<0;0>:ud      r5.6<0;0>:ud      r3.3<0>:ud       {I@4} // s0&~s2|s1&s2
        add (1|M0)               r26.3<1>:d    r19.7<0;1,0>:d    -1:w              
        mov (1|M0)               r34.2<1>:d    r9.0<0;1,0>:d                   
        add3 (1|M0)              r34.3<1>:d    r8.1<0;0>:d       -r10.0<0;0>:d     -r33.5<0>:d      {I@4}
        or (2|M0)                r18.6<1>:d    r18.6<1;1,0>:d    r33.6<1;1,0>:d   {I@4}
(f0.0)  mov (1|M0)               r34.2<1>:d    r8.0<0;1,0>:d                   
(f0.0)  mov (1|M0)               r34.3<1>:d    r8.1<0;1,0>:d                   
(f0.0)  mov (1|M0)               r18.6<1>:f    r33.6<0;1,0>:f                   {I@3}
(f0.0)  mov (1|M0)               r18.7<1>:f    r33.7<0;1,0>:f                  
(f1.1.any16h) goto (16|M0)                   L5976                  L5976                
L5928:
(W)     mov (2|M0)               r33.6<1>:f    r18.6<1;1,0>:f                   {F@1}
        mov (1|M0)               r19.7<1>:d    r26.3<0;1,0>:d                  
        goto.b (16|M0)                       L5976                  L5168                
L5976:
        join (16|M0)                         L5992                                
L5992:
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        ret (16|M0)                          r36.6                            {A@1}
L6040:
        shr (1|M0)               r34.6<1>:ud   r87.1<0;1,0>:ud   0x17:uw             
        shr (1|M0)               r34.5<1>:ud   r87.0<0;1,0>:ud   0x17:uw             
        and (1|M0)               r34.6<1>:ud   r34.6<0;1,0>:ud   0xFF:uw              {I@2}
        and (1|M0)               r34.5<1>:ud   r34.5<0;1,0>:ud   0xFF:uw              {I@2}
        add (1|M0)               r1.3<1>:ud    r34.6<0;1,0>:ud   0xFFFFFF41:ud              {I@2}
        add (1|M0)               r1.2<1>:ud    r34.5<0;1,0>:ud   0xFFFFFF41:ud              {I@2}
        cmp (1|M0)    (lt)f1.1   null<1>:ud    r1.3<0;1,0>:ud    0xFFFFFF81:ud              {I@2}
(W)     mov (1|M0)               r2.12<1>:hf   -qnan(0x1FF):hf                             
(~f1.1) cmp (1|M0)    (lt)f1.1   null<1>:ud    r1.2<0;1,0>:ud    0xFFFFFF82:ud              {I@2}
(f1.1)  sel (1|M0)               r34.16<2>:b   r2.12<0;1,0>:w    0:w               {F@1}
        cmp (1|M0)    (ne)f1.0   null<1>:uw    r34.16<0;1,0>:ub  0x0:uw              {I@1}
(W)     and (1|M0)               f1.0<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
(~f1.0.any16h) goto (16|M0)                  L9704                  L9704                
L6248:
        add (1|M0)               r1.3<1>:ud    r34.6<0;1,0>:ud   0xFFFFFF01:ud             
        add (1|M0)               r1.2<1>:ud    r34.5<0;1,0>:ud   0xFFFFFF01:ud             
        cmp (1|M0)    (lt)f1.0   null<1>:ud    r1.3<0;1,0>:ud    0xFFFFFF02:ud              {I@2}
(W)     mov (1|M0)               r2.12<1>:hf   -qnan(0x1FF):hf                             
        mov (1|M0)               r36.1<1>:f    (abs)r87.0<0;1,0>:f              {Compacted}
(~f1.0) cmp (1|M0)    (lt)f1.0   null<1>:ud    r1.2<0;1,0>:ud    0xFFFFFF02:ud              {I@2}
(f1.0)  sel (1|M0)               r34.18<2>:b   r2.12<0;1,0>:w    0:w               {F@2}
        cmp (1|M0)    (ne)f1.1   null<1>:uw    r34.18<0;1,0>:ub  0x0:uw              {I@1}
(W)     and (1|M0)               f0.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(f0.1.any16h) goto (16|M0)                   L6488                  L6488                
L6400:
        mov (1|M0)               r1.2<1>:f     (abs)r87.1<0;1,0>:f             
        mov (1|M0)               r35.14<2>:b   0:w                              
        add (1|M0)               r36.1<1>:d    r36.1<0;1,0>:d    -r1.2<0;1,0>:d   {A@1}
        mov (2|M0)               r65.4<1>:d    r87.0<1;1,0>:ud                 
        asr (1|M0)               r36.1<1>:d    r36.1<0;1,0>:d    23:w               {Compacted,I@2}
        goto (16|M0)                         L6488                  L8168                
L6488:
        join (16|M0)                         L8168                                
L6504:
        cmp (1|M0)    (gt)f1.0   null<1>:ud    r36.1<0;1,0>:ud   0x7F800000:ud              {I@3}
(W)     mov (1|M0)               r1.3<1>:hf    0xFF:hf                             
        mov (1|M0)               r35.7<1>:f    (abs)r87.1<0;1,0>:f             
(W)     mov (1|M0)               r2.13<1>:hf   -qnan(0x1FF):hf                             
(f1.0)  sel (1|M0)               r2.12<1>:w    r1.3<0;1,0>:w     0:w               {F@3}
        and (1|M0)               r35.0<1>:ud   r87.0<0;1,0>:ud   0x7F800000:ud             
        cmp (1|M0)    (eq)f0.1   null<1>:w     r2.24<0;1,0>:b    0:w               {I@2}
(W)     mov (1|M0)               r3.4<1>:uw    r2.24<0;1,0>:ub                 
        and (1|M0)               r35.1<1>:ud   r87.1<0;1,0>:ud   0x7F800000:ud             
        add (1|M0)               r26.0<1>:f    r87.0<0;1,0>:f    r87.1<0;1,0>:f   {Compacted}
(f0.1)  cmp (1|M0)    (gt)f0.1   null<1>:ud    r35.7<0;1,0>:ud   0x7F800000:ud              {F@3}
(W)     mov (1|M0)               r6.0<1>:f     -0.0:f                               {Compacted}
        and (1|M0)               r5.6<1>:ud    r87.1<0;1,0>:ud   0x80000000:ud             
        bfn.0x6A (1|M0)          r1.2<1>:ud    r87.0<0;0>:ud     r87.1<0;0>:ud     r6.0<0>:ud       {F@1} // s0^s1&s2
(f0.1)  sel (1|M0)               r2.28<2>:b    r2.13<0;1,0>:w    0:w              
        bfn.0x6A (1|M0)          r1.3<1>:ud    r87.1<0;0>:ud     r87.0<0;0>:ud     r6.0<0>:ud       // s0^s1&s2
        and (1|M0)    (ne)f0.1   null<1>:w     r2.28<0;1,0>:ub   1:w               {I@2}
        or (1|M0)     (eq)f1.1   r2.28<2>:ub   r2.28<0;1,0>:ub   r3.4<0;1,0>:uw  
        and (1|M0)               r34.7<1>:ud   r87.0<0;1,0>:ud   0x80000000:ud             
(f0.1)  add (1|M0)               r26.0<1>:f    r87.1<0;1,0>:f    r87.1<0;1,0>:f  
(f1.1)  cmp (1|M0)    (eq)f1.1   null<1>:d     r35.0<0;1,0>:d    2139095040:d              
(W)     mov (1|M0)               r5.14<1>:uw   r2.28<0;1,0>:ub                  {I@3}
(f1.1)  sel (1|M0)               r1.6<2>:b     r2.13<0;1,0>:w    0:w              
        and (1|M0)    (ne)f1.1   null<1>:w     r1.6<0;1,0>:ub    1:w               {I@1}
        or (1|M0)     (eq)f1.0   r1.6<2>:ub    r1.6<0;1,0>:ub    r5.14<0;1,0>:uw 
(f1.1)  add (1|M0)               r26.0<1>:f    r1.2<0;1,0>:f     -r1.3<0;1,0>:f  
(f1.0)  cmp (1|M0)    (eq)f1.0   null<1>:d     r35.1<0;1,0>:d    2139095040:d              
(W)     mov (1|M0)               r3.4<1>:uw    r1.6<0;1,0>:ub                   {I@2}
(f1.0)  sel (1|M0)               r35.10<2>:b   r2.13<0;1,0>:w    0:w              
        and (1|M0)    (ne)f1.0   null<1>:w     r35.10<0;1,0>:ub  1:w               {I@1}
        or (1|M0)     (eq)f0.1   r35.10<2>:ub  r35.10<0;1,0>:ub  r3.4<0;1,0>:uw   {F@2}
(f1.0)  mul (1|M0)               r26.0<1>:f    r5.6<0;1,0>:f     r87.0<0;1,0>:f  
(f0.1)  cmp (1|M0)    (eq)f0.1   null<1>:f     r87.1<0;1,0>:f    0.0:f               {I@1}
(f0.1)  sel (1|M0)               r35.8<2>:b    r2.13<0;1,0>:w    0:w              
        cmp (1|M0)    (ne)f0.1   null<1>:uw    r35.8<0;1,0>:ub   0x0:uw              {A@1}
(W)     and (1|M0)               f1.1<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(f1.1.any16h) goto (16|M0)                   L7112                  L7112                
L7080:
        mov (1|M0)               r35.12<2>:b   r35.10<0;1,0>:b                 
        goto (16|M0)                         L7112                  L7296                
L7112:
        join (16|M0)                         L7296                                
L7128:
(W)     mov (1|M0)               r6.0<1>:f     inf:f                               {Compacted}
        cmp (1|M0)    (eq)f0.1   null<1>:f     r87.0<0;1,0>:f    0.0:f               {A@5}
        bfn.0x96 (1|M0)          r34.7<1>:ud   r34.7<0;0>:ud     r87.1<0;0>:ud     r6.0<0>:ud       {F@2} // s0^s1^s2
        xor (1|M0)               r1.2<1>:ud    r87.1<0;1,0>:ud   0x7F800000:ud             
        and (1|M0)    (ne)f1.1   null<1>:w     r35.8<0;1,0>:ub   1:w              
(W)     mov (1|M0)               r2.12<1>:uw   r35.10<0;1,0>:ub                
(~f0.1) mov (1|M0)               r1.2<1>:f     r34.7<0;1,0>:f                   {A@3}
        or (1|M0)                r35.10<2>:ub  r35.8<0;1,0>:ub   r2.12<0;1,0>:uw  {I@1}
(f0.1)  mul (1|M0)               r34.7<1>:f    r1.2<0;1,0>:f     r87.0<0;1,0>:f   {F@1}
        mov (1|M0)               r35.12<2>:b   r35.10<0;1,0>:b                  {I@1}
(f1.1)  mov (1|M0)               r26.0<1>:f    r34.7<0;1,0>:f                   {F@1}
L7296:
        join (16|M0)                         L8168                                
L7312:
        cmp (1|M0)    (eq)f1.1   null<1>:w     r35.10<0;1,0>:b   0:w               {F@1}
(W)     mov (1|M0)               r1.3<1>:hf    -qnan(0x1FF):hf                             
(W)     mov (1|M0)               r2.12<1>:uw   r35.12<0;1,0>:ub                 {I@3}
(f1.1)  cmp (1|M0)    (eq)f1.1   null<1>:f     r87.0<0;1,0>:f    0.0:f               {I@2}
(f1.1)  sel (1|M0)               r35.14<2>:b   r1.3<0;1,0>:w     0:w               {F@2}
        and (1|M0)    (ne)f1.0   null<1>:w     r35.14<0;1,0>:ub  1:w               {I@1}
        or (1|M0)     (ne)f0.1   r35.14<2>:ub  r35.14<0;1,0>:ub  r2.12<0;1,0>:uw 
(f1.0)  mul (1|M0)               r26.0<1>:f    r87.0<0;1,0>:f    r87.1<0;1,0>:f  
(W)     and (1|M0)               f1.0<1>:uw    f0.1<0;1,0>:uw    0x1:uw              {F@1}
(f1.0.any16h) goto (16|M0)                   L8168                  L9704                
L7472:
        cmp (1|M0)    (eq)f1.1   null<1>:uw    r35.14<0;1,0>:ub  0x0:uw              {I@3}
        cmp (1|M0)    (eq)f1.0   null<1>:d     r35.0<0;1,0>:d    0:w              
(~f1.1) mov (1|M0)               r34.18<2>:b   0:w                              
(f1.0)  sel (1|M0)               r35.4<1>:d    r34.18<0;1,0>:b   0:w               {I@1}
        cmp (1|M0)    (ne)f0.1   null<1>:d     r35.4<0;1,0>:d    0:w               {I@1}
(W)     and (1|M0)               f0.1<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(f0.1.any16h) goto (16|M0)                   L7624                  L7624                
L7584:
        mov (1|M0)               r35.5<1>:d    0:w                              
        mov (1|M0)               r65.4<1>:f    r87.0<0;1,0>:f                   {Compacted}
        goto (16|M0)                         L7624                  L7776                
L7624:
        join (16|M0)                         L7776                                
L7640:
        and (1|M0)    (ne)f1.0   r35.4<1>:d    r35.4<0;1,0>:d    1:w              
        mov (1|M0)               r65.4<1>:f    r87.0<0;1,0>:f                   {Compacted}
(W)     mov (1|M0)               r2.12<1>:hf   -qnan(0x1E0):hf                             
(f1.0)  mul (1|M0)               r65.4<1>:f    r87.0<0;1,0>:f    0x4F800000:f              
(f1.0)  sel (1|M0)               r35.5<1>:d    r2.12<0;1,0>:w    0:w               {F@2}
        shr (1|M0)               r1.2<1>:ud    r65.4<0;1,0>:ud   0x17:uw              {F@1}
        and (1|M0)               r1.2<1>:ud    r1.2<0;1,0>:ud    0xFF:uw              {I@1}
        add (1|M0)               r1.2<1>:ud    r1.2<0;1,0>:ud    0xFFFFFFE0:ud              {I@1}
(f1.0)  mov (1|M0)               r34.5<1>:d    r1.2<0;1,0>:d                    {I@1}
L7776:
        join (16|M0)                         L8168                                
L7792:
        cmp (1|M0)    (eq)f1.1   null<1>:d     r35.1<0;1,0>:d    0:w              
(f1.1)  sel (1|M0)               r35.6<1>:d    r34.18<0;1,0>:b   0:w              
        cmp (1|M0)    (ne)f1.0   null<1>:d     r35.6<0;1,0>:d    0:w               {I@1}
(W)     and (1|M0)               f1.1<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
(f1.1.any16h) goto (16|M0)                   L7920                  L7920                
L7872:
        mov (1|M0)               r36.0<1>:d    0:w                              
        mov (1|M0)               r65.5<1>:d    r87.1<0;1,0>:ud                 
        goto (16|M0)                         L7920                  L8096                
L7920:
        join (16|M0)                         L8096                                
L7936:
        and (1|M0)    (ne)f0.1   r35.6<1>:d    r35.6<0;1,0>:d    1:w              
        mov (1|M0)               r65.5<1>:f    r87.1<0;1,0>:f                   {I@4}
(W)     mov (1|M0)               r2.12<1>:hf   0x20:hf                             
(f0.1)  mul (1|M0)               r65.5<1>:f    r87.1<0;1,0>:f    0x4F800000:f              
(f0.1)  sel (1|M0)               r36.0<1>:d    r2.12<0;1,0>:w    0:w               {F@2}
        shr (1|M0)               r1.2<1>:ud    r65.5<0;1,0>:ud   0x17:uw              {F@1}
        mov (1|M0)               r35.7<1>:f    (abs)r65.5<0;1,0>:f             
        and (1|M0)               r1.2<1>:ud    r1.2<0;1,0>:ud    0xFF:uw              {I@1}
        add (1|M0)               r1.2<1>:ud    r1.2<0;1,0>:ud    0xFFFFFFE0:ud              {I@1}
(f0.1)  mov (1|M0)               r34.6<1>:d    r1.2<0;1,0>:d                    {I@1}
L8096:
        join (16|M0)                         L8168                                
L8112:
        mov (1|M0)               r36.1<1>:f    (abs)r65.4<0;1,0>:f             
        add (1|M0)               r36.0<1>:d    r36.0<0;1,0>:d    r35.5<0;1,0>:d   {Compacted}
        add (1|M0)               r36.1<1>:d    r36.1<0;1,0>:d    -r35.7<0;1,0>:d  {F@1}
        asr (1|M0)               r36.1<1>:d    r36.1<0;1,0>:d    23:w               {Compacted,I@1}
        add (1|M0)               r36.0<1>:d    r36.0<0;1,0>:d    r36.1<0;1,0>:d   {Compacted,I@1}
L8168:
        join (16|M0)                         L9704                                
L8184:
        cmp (1|M0)    (eq)f0.1   null<1>:uw    r34.18<0;1,0>:ub  0x0:uw             
(W)     mov (1|M0)               r1.2<1>:f     1.0:f                               {Compacted}
(W)     mov (1|M0)               r6.0<1>:f     0x807FFFFF:f                              
        cmp (1|M0)    (eq)f1.1   null<1>:w     r35.14<0;1,0>:b   0:w              
(~f0.1) mov (1|M0)               r36.1<1>:d    r36.0<0;1,0>:d                   {I@4}
        bfn.0xEA (1|M0)          r65.5<1>:ud   r1.2<0;0>:ud      r65.5<0;0>:ud     r6.0<0>:ud       {A@1} // s0|s1&s2
        add (1|M0)               r36.2<1>:d    r36.1<0;1,0>:d    126:w               {I@2}
        add (1|M0)               r36.3<1>:d    -r36.1<0;1,0>:d   -152:w              
        sync.nop                             null                             {Compacted,I@3}
        math.inv (1|M0)          r2.6<1>:f     r65.5<0;1,0>:f                   {$8}
        and (1|M0)               r36.3<1>:d    r36.3<0;1,0>:d    r36.2<0;1,0>:d   {I@1}
        mov (1|M0)               r89.0<1>:f    1.0:f                               {Compacted}
        asr (1|M0)               r36.3<1>:d    r36.3<0;1,0>:d    31:w               {Compacted,I@1}
(~f1.1) mov (1|M0)               r36.3<1>:d    0:w                              
        bfn.0xEA (1|M0)          r65.4<1>:ud   r1.2<0;0>:ud      r65.4<0;0>:ud     r6.0<0>:ud       // s0|s1&s2
        cmp (1|M0)    (ne)f1.0   null<1>:d     r36.3<0;1,0>:d    0:w               {I@2}
        sync.nop                             null                             {Compacted,$8.dst}
        mad (1|M0)               r89.0<1>:f    r89.0<0;0>:f      r2.6<0;0>:f       -r65.5<0>:f      {F@1}
        mul (1|M0)               r2.7<1>:f     r2.6<0;1,0>:f     r65.4<0;1,0>:f   {I@2}
        mad (1|M0)               r89.0<1>:f    r2.6<0;0>:f       r2.6<0;0>:f       r89.0<0>:f       {F@2}
        mad (1|M0)               r89.1<1>:f    r65.4<0;0>:f      r2.7<0;0>:f       -r65.5<0>:f      {F@2}
(W)     and (1|M0)               f1.0<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
        mad (1|M0)               r89.1<1>:f    r2.7<0;0>:f       r89.0<0;0>:f      r89.1<0>:f       {F@1}
        add (1|M0)               r34.5<1>:d    r34.5<0;1,0>:d    -r34.6<0;1,0>:d 
        mad (1|M0)               r65.4<1>:f    r65.4<0;0>:f      r89.1<0;0>:f      -r65.5<0>:f      {F@1}
(~f1.0.any16h) goto (16|M0)                  L9352                  L9352                
L8560:
        mov (1|M0)               r36.5<1>:f    r65.4<0;1,0>:f                   {F@1}
        mov (2|M0)               r88.0<1>:f    r89.0<1;1,0>:f                  
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r87.4         L9936                                 {A@1}
L8640:
        cmp (1|M0)    (eq)f1.1   null<1>:f     r65.4<0;1,0>:f    0.0:f              
(W)     mov (1|M0)               r1.3<1>:hf    0x1:hf                             
        add (1|M0)               r36.1<1>:d    r36.1<0;1,0>:d    125:w               {Compacted}
(W)     mov (1|M0)               r3.4<1>:hf    0x1:hf                             
(f1.1)  sel (1|M0)               r2.12<1>:w    r1.3<0;1,0>:w     0:w               {F@2}
        cmp (1|M0)    (lt)f0.1   null<1>:d     r36.1<0;1,0>:d    -2:w               {I@2}
        cmp (1|M0)    (ne)f1.0   null<1>:w     r2.12<0;1,0>:w    0:w               {I@2}
(W)     mov (1|M0)               r6.0<1>:hf    -qnan(0x1FF):hf                             
(f0.1)  sel (1|M0)               r3.5<1>:uw    r3.4<0;1,0>:uw    0x0:uw              {F@2}
(f1.0)  sel (1|M0)               r5.12<1>:uw   r3.4<0;1,0>:uw    0x0:uw             
        or (1|M0)     (ne)f0.1   null<1>:uw    r3.5<0;1,0>:uw    r5.12<0;1,0>:uw  {I@1}
(f0.1)  sel (1|M0)               r36.16<2>:b   r6.0<0;1,0>:w     0:w               {F@1}
        cmp (1|M0)    (ne)f0.1   null<1>:uw    r36.16<0;1,0>:ub  0x0:uw              {I@1}
(W)     and (1|M0)               f0.1<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(~f0.1.any16h) goto (16|M0)                  L8992                  L8992                
L8872:
(W)     mov (1|M0)               r1.3<1>:hf    0x1:hf                             
        and (1|M0)               r1.2<1>:d     r36.5<0;1,0>:d    -2139095041:d              
(W)     mov (1|M0)               r6.0<1>:f     0x800000:f                               {Compacted}
        shl (1|M0)               r36.2<1>:d    r36.2<0;1,0>:d    23:w              
(f1.1)  sel (1|M0)               r2.6<1>:d     r1.3<0;1,0>:w     0:w               {F@2}
        add (1|M0)               r36.2<1>:d    r36.2<0;1,0>:d    1065353216:d               {I@2}
        bfn.0xFE (1|M0)          r1.2<1>:ud    r1.2<0;0>:ud      r2.6<0;0>:ud      r6.0<0>:ud       {A@1} // s0|s1|s2
        mul (1|M0)               r36.2<1>:f    r36.2<0;1,0>:f    r1.2<0;1,0>:f    {A@1}
L8992:
        join (16|M0)                         L9352                                
L9008:
        and (1|M0)               r1.2<1>:d     r36.5<0;1,0>:d    -2147483648:d               {F@1}
        shl (1|M0)               r36.5<1>:d    r36.5<0;1,0>:d    1:w              
(W)     mov (1|M0)               r1.3<1>:hf    0x1:hf                             
        and (1|M0)               r1.3<1>:d     r36.5<0;1,0>:d    8388606:d               {I@1}
        and (1|M0)    (eq)f0.1   r36.5<1>:d    r36.5<0;1,0>:d    8388608:d              
(W)     mov (1|M0)               r3.2<1>:f     1.469368e-38:f                               {Compacted}
(f1.0)  sel (1|M0)               r2.6<1>:d     r1.3<0;1,0>:w     0:w               {F@2}
(W)     mov (1|M0)               r5.7<1>:f     0x800000:f                               {Compacted}
        or (1|M0)                r2.6<1>:d     r1.2<0;1,0>:d     r2.6<0;1,0>:d    {I@1}
(f0.1)  sel (1|M0)               r5.6<1>:d     r3.2<0;1,0>:d     12582912:d               {F@2}
        mov (1|M0)               r6.0<1>:f     0.25:f                               {Compacted}
        bfn.0xFE (1|M0)          r2.6<1>:ud    r5.7<0;0>:ud      r2.6<0;0>:ud      r1.3<0>:ud       {A@2} // s0|s1|s2
        or (1|M0)                r5.6<1>:d     r5.6<0;1,0>:d     r1.2<0;1,0>:d    {I@2}
        or (1|M0)                r2.7<1>:d     r1.2<0;1,0>:d     8388608:d              
        mad (1|M0)               r2.6<1>:f     r5.6<0;0>:f       r6.0<0;0>:f       r2.6<0>:f        {A@1}
        cmp (1|M0)    (eq)f1.1   null<1>:uw    r36.16<0;1,0>:ub  0x0:uw             
        add (1|M0)               r2.6<1>:f     r2.6<0;1,0>:f     -r2.7<0;1,0>:f   {A@1}
        mul (1|M0)               r2.7<1>:f     r2.7<0;1,0>:f     r2.7<0;1,0>:f   
        and (1|M0)    (ne)f1.0   null<1>:d     r36.3<0;1,0>:d    1:w              
        and (1|M0)               r2.7<1>:d     r2.7<0;1,0>:d     -2:w               {F@1}
        or (1|M0)                r2.7<1>:d     r2.7<0;1,0>:d     r2.6<0;1,0>:d    {I@1}
(~f1.1) mov (1|M0)               r2.7<1>:f     r36.2<0;1,0>:f                   {I@1}
(f1.0)  mov (1|M0)               r26.0<1>:f    r2.7<0;1,0>:f                    {F@1}
L9352:
        join (16|M0)                         L9704                                
L9368:
        add (1|M0)               r2.6<1>:d     r34.5<0;1,0>:d    126:w              
(W)     mov (1|M0)               r1.3<1>:uw    r36.12<0;1,0>:ub                
        cmp (1|M0)    (gt)f1.0   null<1>:ud    r2.6<0;1,0>:ud    0x17A:uw              {A@1}
        mad (1|M0)               r65.4<1>:f    r89.1<0;0>:f      r89.0<0;0>:f      r65.4<0>:f      
        or (1|M0)                r36.9<1>:w    r35.14<0;1,0>:ub  r1.3<0;1,0>:uw   {I@2}
(W)     and (1|M0)               f0.1<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
(~f0.1.any16h) goto (16|M0)                  L9560                  L9560                
L9480:
(f1.0)  sel (1|M0)               r1.2<1>:d     r34.5<0;1,0>:d    0:w              
        asr (1|M0)               r1.2<1>:d     r1.2<0;1,0>:d     11:w               {I@1}
        add (1|M0)               r1.3<1>:d     r1.2<0;1,0>:d     248:w               {I@1}
        xor (1|M0)               r1.3<1>:d     r1.3<0;1,0>:d     r1.2<0;1,0>:d    {I@1}
(f1.0)  mov (1|M0)               r34.5<1>:d    r1.3<0;1,0>:d                    {I@1}
L9560:
        join (16|M0)                         L9704                                
L9576:
        asr (1|M0)               r1.2<1>:d     r34.5<0;1,0>:d    1:w               {I@2}
        cmp (1|M0)    (eq)f0.1   null<1>:w     r36.9<0;1,0>:w    0:w              
        add (1|M0)               r34.5<1>:d    r34.5<0;1,0>:d    -r1.2<0;1,0>:d   {I@2}
        shl (1|M0)               r1.2<1>:d     r1.2<0;1,0>:d     23:w              
        shl (1|M0)               r34.5<1>:d    r34.5<0;1,0>:d    23:w               {I@2}
        add (1|M0)               r1.2<1>:d     r1.2<0;1,0>:d     r65.4<0;1,0>:d   {A@1}
        add (1|M0)               r34.5<1>:d    r34.5<0;1,0>:d    1065353216:d               {I@2}
(f0.1)  mul (1|M0)               r26.0<1>:f    r34.5<0;1,0>:f    r1.2<0;1,0>:f    {I@1}
L9704:
        join (16|M0)                         L9720                                
L9720:
        sync.nop                             null                             {Compacted,F@1}
        math.inv (1|M0)          r1.2<1>:f     r87.1<0;1,0>:f                   {$9}
        mov (1|M0)               r1.4<1>:ud    0x3F800000:ud                             
        mul (1|M0)               r1.3<1>:f     r1.2<0;1,0>:f     r87.0<0;1,0>:f   {$9.dst}
        mad (1|M0)               r1.4<1>:f     r1.4<0;0>:f       r1.2<0;0>:f       -r87.1<0>:f      {I@1}
        mad (1|M0)               r2.6<1>:f     r87.0<0;0>:f      r1.3<0;0>:f       -r87.1<0>:f      {F@2}
        mad (1|M0)               r1.4<1>:f     r1.2<0;0>:f       r1.2<0;0>:f       r1.4<0>:f        {F@2}
        cmp (1|M0)    (eq)f1.1   null<1>:uw    r34.16<0;1,0>:ub  0x0:uw             
        mad (1|M0)               r2.6<1>:f     r1.3<0;0>:f       r1.4<0;0>:f       r2.6<0>:f        {F@1}
        mad (1|M0)               r87.0<1>:f    r87.0<0;0>:f      r2.6<0;0>:f       -r87.1<0>:f      {F@1}
(f1.1)  mad (1|M0)               r26.0<1>:f    r2.6<0;0>:f       r1.4<0;0>:f       r87.0<0>:f       {F@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        ret (16|M0)                          r65.6                            {A@1}
L9936:
        mov (1|M0)               r1.2<1>:d     cr0.0<0;1,0>:ud                  {A@1}
        and (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   -1265:w               {A@1}
        or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   1264:w               {A@1}
        mad (1|M0)               r36.5<1>:f    r88.1<0;0>:f      r88.0<0;0>:f      r36.5<0>:f       {A@1}
        mov (1|M0)               cr0.0<1>:ud   r1.2<0;1,0>:d                    {A@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        ret (16|M0)                          r87.4                            {A@1}
L10064:
(W)     shr (16|M0)              r6.0<1>:ud    r37.0<1;1,0>:ud   0x17:uw             
(W)     and (16|M0)              r39.0<1>:w    r6.0<2;1,0>:w     255:w               {I@1}
(W)     add (16|M0)              r10.0<1>:d    r39.0<1;1,0>:uw   -191:w               {I@1}
(W)     cmp (16|M0)   (lt)f1.1   null<1>:d     r10.0<1;1,0>:ud   0xFFFFFF82:ud              {A@1}
(W)     shr (16|M0)              r8.0<1>:ud    r44.0<1;1,0>:ud   0x17:uw             
(W)     mov (1|M0)               r88.4<1>:uw   f1.1<0;1,0>:uw                  
(W)     and (16|M0)              r46.0<1>:w    r8.0<2;1,0>:w     255:w               {I@2}
(W)     mov (1|M0)               f1.0<1>:uw    r88.4<0;1,0>:uw                  {I@2}
(W)     add (16|M0)              r12.0<1>:d    r46.0<1;1,0>:uw   -191:w               {I@2}
(W)     mov (16|M0)              r40.0<1>:d    r39.0<1;1,0>:uw                 
(W&~f1.0) cmp (16|M0) (lt)f1.0   null<1>:d     r12.0<1;1,0>:ud   0xFFFFFF81:ud              {I@2}
(W)     mov (16|M0)              r42.0<1>:d    r39.0<1;1,0>:uw                 
(W)     mov (1|M0)               r88.4<1>:uw   f1.0<0;1,0>:uw                   {Compacted}
(W)     mov (16|M0)              r47.0<1>:d    r46.0<1;1,0>:uw                 
(W)     mov (1|M0)               f0.1<1>:uw    r88.4<0;1,0>:uw                  {I@2}
(W)     mov (16|M0)              r49.0<1>:d    r46.0<1;1,0>:uw                 
(~f0.1.any16h) goto (16|M0)                  L12888                  L12888                
L10328:
(W)     add (16|M0)              r6.0<1>:d     r39.0<1;1,0>:uw   -255:w              
(W)     cmp (16|M0)   (lt)f0.1   null<1>:d     r6.0<1;1,0>:ud    0xFFFFFF02:ud              {I@1}
(W)     add (16|M0)              r8.0<1>:d     r46.0<1;1,0>:uw   -255:w              
(W&~f0.1) cmp (16|M0) (lt)f0.1   null<1>:d     r8.0<1;1,0>:ud    0xFFFFFF02:ud              {I@1}
(W)     mov (16|M0)              r61.0<1>:f    (abs)r37.0<1;1,0>:f              {Compacted}
(f0.1.any16h) goto (16|M0)                   L10488                  L10488                
L10416:
(W)     mov (16|M0)              r6.0<1>:f     (abs)r44.0<1;1,0>:f              {Compacted}
(W)     add (16|M0)              r61.0<1>:d    r61.0<1;1,0>:d    -r6.0<1;1,0>:d   {Compacted,A@1}
(W)     mov (4|M0)               r65.0<1>:d    0:w                              
(W)     mov (16|M0)              r74.0<1>:f    r37.0<1;1,0>:f                   {Compacted}
(W)     mov (16|M0)              r63.0<1>:f    r44.0<1;1,0>:f                   {Compacted}
(W)     asr (16|M0)              r61.0<1>:d    r61.0<1;1,0>:d    23:w               {Compacted,I@2}
        goto (16|M0)                         L10488                  L11752                
L10488:
        join (16|M0)                         L11752                                
L10504:
(W)     mov (16|M0)              r59.0<1>:f    (abs)r44.0<1;1,0>:f              {Compacted}
(W)     cmp (16|M0)   (gt)f1.1   null<1>:d     r61.0<1;1,0>:ud   0x7F800000:ud              {I@3}
(W)     cmp (16|M0)   (lt)f0.0   null<1>:d     r59.0<1;1,0>:ud   0x7F800001:ud              {F@1}
(W)     and (16|M0)              r51.0<1>:ud   r37.0<1;1,0>:ud   0x7F800000:ud             
(W)     mov (1|M0)               r1.3<1>:uw    f1.1<0;1,0>:uw                  
(W)     mov (1|M0)               r2.12<1>:uw   f0.0<0;1,0>:uw                   {Compacted}
(W)     or (1|M0)                f1.0<1>:uw    f0.0<0;1,0>:uw    r1.3<0;1,0>:uw   {I@2}
(W)     cmp (16|M0)   (ne)f0.0   null<1>:d     r51.0<1;1,0>:d    2139095040:d              
(W)     or (1|M0)                r3.4<1>:uw    f1.1<0;1,0>:uw    ~r2.12<0;1,0>:uw {I@3}
(W)     mov (1|M0)               r10.0<1>:f    -0.0:f                               {Compacted}
(W)     or (1|M0)                r3.5<1>:uw    f0.0<0;1,0>:uw    r3.4<0;1,0>:uw   {I@1}
(W)     and (16|M0)              r53.0<1>:ud   r44.0<1;1,0>:ud   0x7F800000:ud             
(W)     mov (1|M0)               f1.1<1>:uw    r3.5<0;1,0>:uw                   {I@2}
(W&f1.0) sel (16|M0)             acc0.0<1>:f   r37.0<1;1,0>:f    r44.0<1;1,0>:f  
(W)     bfn.0x6A (16|M0)         r79.0<1>:ud   r37.0<1;0>:ud     r44.0<1;0>:ud     r10.0<0>:ud      {F@2} // s0^s1&s2
(W)     bfn.0x6A (16|M0)         r11.0<1>:ud   r44.0<1;0>:ud     r37.0<1;0>:ud     r10.0<0>:ud      // s0^s1&s2
(W)     add (16|M0)              r79.0<1>:f    r79.0<1;1,0>:f    -r11.0<1;1,0>:f  {Compacted,A@1}
(W&f1.1) add (16|M0)             r79.0<1>:f    acc0.0<1;1,0>:f   r44.0<1;1,0>:f  
(W)     cmp (16|M0)   (ne)f1.1   null<1>:d     r53.0<1;1,0>:d    2139095040:d               {F@1}
(W)     or (1|M0)                r3.4<1>:uw    ~f0.0<0;1,0>:uw   r3.4<0;1,0>:uw  
(W)     mov (1|M0)               r2.12<1>:hf   -qnan(0x1FF):hf                             
(W)     or (1|M0)                r1.3<1>:uw    f1.1<0;1,0>:uw    r3.4<0;1,0>:uw   {I@1}
(W)     or (1|M0)                r3.4<1>:uw    ~f1.1<0;1,0>:uw   r3.4<0;1,0>:uw  
(W)     mov (1|M0)               f0.0<1>:uw    r1.3<0;1,0>:uw                   {I@2}
(W)     mov (1|M0)               f1.1<1>:uw    r3.4<0;1,0>:uw                   {I@2}
(W)     and (16|M0)              r8.0<1>:ud    r44.0<1;1,0>:ud   0x80000000:ud             
(W)     and (16|M0)              r55.0<1>:ud   r37.0<1;1,0>:ud   0x80000000:ud             
(W&f1.1) sel (16|M0)             r13.0<2>:b    r2.12<0;1,0>:w    0:w               {F@1}
(W)     cmp (16|M0)   (eq)f1.1   null<1>:f     r44.0<1;1,0>:f    0.0:f               {A@1}
(W&~f0.0) mul (16|M0)            r79.0<1>:f    r8.0<1;1,0>:f     r37.0<1;1,0>:f  
(W)     and (1|M0)               r5.12<1>:uw   f1.1<0;1,0>:uw    ~r3.4<0;1,0>:uw 
(W)     mov (16|M0)              r65.0<1>:b    r13.0<2;1,0>:b                  
(W)     mov (1|M0)               f1.0<1>:uw    r5.12<0;1,0>:uw                  {I@2}
(~f1.0) goto (16|M0)                         L11136                  L11136                
L11016:
(W)     cmp (16|M0)   (eq)f1.1   null<1>:f     r37.0<1;1,0>:f    0.0:f              
(W)     mov (1|M0)               r1.2<1>:ud    0x7F800000:ud                             
(W)     mov (1|M0)               r2.24<2>:b    -1:w                              
(W&f1.1) mov (16|M0)             r55.0<1>:ud   0:w                              
(W)     bfn.0x96 (16|M0)         r55.0<1>:ud   r1.2<0;0>:ud      r55.0<1;0>:ud     r44.0<1>:ud      {I@1} // s0^s1^s2
(W&f1.1) mul (16|M0)             r55.0<1>:f    r55.0<1;1,0>:f    r37.0<1;1,0>:f   {I@1}
        mov (16|M0)              r65.0<1>:b    r2.24<0;1,0>:b                  
        mov (16|M0)              r79.0<1>:f    r55.0<1;1,0>:f                   {Compacted,F@1}
L11136:
        join (16|M0)                         L11752                                
L11152:
(W)     cmp (16|M0)   (eq)f1.0   null<1>:f     r37.0<1;1,0>:f    0.0:f              
(W&f1.0) cmp (16|M0)  (eq)f1.0   null<1>:w     r65.0<1;1,0>:ub   0x0:uw              {A@1}
(W&~f1.0) sel (16|M0)            r6.0<2>:b     r65.0<1;1,0>:b    -1:w              
(W)     mov (16|M0)              r65.0<1>:b    r6.0<2;1,0>:b                    {I@1}
(W)     cmp (16|M0)   (ne)f0.0   null<1>:w     r65.0<1;1,0>:ub   0x0:uw              {I@1}
(W&f1.0) mul (16|M0)             r79.0<1>:f    r37.0<1;1,0>:f    r44.0<1;1,0>:f  
(f0.0.all16h) goto (16|M0)                   L11752                  L12888                
L11264:
(W)     cmp (16|M0)   (eq)f1.0   null<1>:w     r65.0<1;1,0>:ub   0x0:uw              {F@1}
(W)     mov (1|M0)               r1.3<1>:uw    f0.1<0;1,0>:uw                  
(W)     cmp (16|M0)   (eq)f1.1   null<1>:d     r51.0<1;1,0>:d    0:w              
(W)     and (1|M0)               f0.1<1>:uw    f1.0<0;1,0>:uw    r1.3<0;1,0>:uw   {I@2}
(W)     mov (16|M0)              r66.0<1>:d    0:w                              
(W)     mov (1|M0)               r2.12<1>:uw   f1.1<0;1,0>:uw                  
(W)     mov (16|M0)              r74.0<1>:f    r37.0<1;1,0>:f                   {Compacted}
(W)     and (1|M0)               f0.0<1>:uw    f0.1<0;1,0>:uw    r2.12<0;1,0>:uw  {I@1}
(W)     mov (16|M0)              r57.0<1>:f    r66.0<1;1,0>:f                   {Compacted}
(~f0.0) goto (16|M0)                         L11504                  L11504                
L11408:
        mul (16|M0)              r74.0<1>:f    r37.0<1;1,0>:f    0x4F800000:f               {Compacted}
(W)     shr (16|M0)              r6.0<1>:ud    r74.0<1;1,0>:ud   0x17:uw              {F@1}
(W)     and (16|M0)              r8.0<1>:w     r6.0<2;1,0>:w     255:w               {I@1}
        add (16|M0)              r42.0<1>:d    r8.0<1;1,0>:uw    -32:w               {I@1}
(W)     mov (16|M0)              r57.0<1>:d    0:w                              
(W)     mov (16|M0)              r40.0<1>:f    r42.0<1;1,0>:f                   {Compacted,I@2}
        mov (16|M0)              r57.0<1>:d    -32:w                              
L11504:
        join (16|M0)                         L11752                                
L11520:
(W)     cmp (16|M0)   (eq)f1.0   null<1>:d     r53.0<1;1,0>:d    0:w              
(W)     mov (16|M0)              r63.0<1>:f    r44.0<1;1,0>:f                   {Compacted}
(W)     mov (1|M0)               r1.3<1>:uw    f1.0<0;1,0>:uw                  
(W)     and (1|M0)               f1.1<1>:uw    f0.1<0;1,0>:uw    r1.3<0;1,0>:uw   {I@1}
(~f1.1) goto (16|M0)                         L11696                  L11696                
L11592:
        mul (16|M0)              r63.0<1>:f    r44.0<1;1,0>:f    0x4F800000:f               {Compacted}
(W)     shr (16|M0)              r6.0<1>:ud    r63.0<1;1,0>:ud   0x17:uw              {F@1}
(W)     and (16|M0)              r8.0<1>:w     r6.0<2;1,0>:w     255:w               {I@1}
        add (16|M0)              r49.0<1>:d    r8.0<1;1,0>:uw    -32:w               {I@1}
(W)     mov (16|M0)              r66.0<1>:d    0:w                              
(W)     mov (16|M0)              r59.0<1>:f    (abs)r63.0<1;1,0>:f              {Compacted}
(W)     mov (16|M0)              r47.0<1>:f    r49.0<1;1,0>:f                   {Compacted,I@2}
        mov (16|M0)              r66.0<1>:d    32:w                              
L11696:
        join (16|M0)                         L11752                                
L11712:
(W)     mov (16|M0)              r61.0<1>:f    (abs)r74.0<1;1,0>:f              {Compacted}
(W)     add (16|M0)              r61.0<1>:d    r61.0<1;1,0>:d    -r59.0<1;1,0>:d  {Compacted,F@1}
(W)     asr (16|M0)              r61.0<1>:d    r61.0<1;1,0>:d    23:w               {Compacted,I@1}
(W)     add3 (16|M0)             r66.0<1>:d    r66.0<1;0>:d      r57.0<1;0>:d      r61.0<1>:d       {I@1}
L11752:
        join (16|M0)                         L12888                                
L11768:
(W)     mov (1|M0)               r1.2<1>:f     1.0:f                               {Compacted}
(W)     mov (1|M0)               r6.0<1>:f     0x807FFFFF:f                              
(W&~f0.1) mov (16|M0)            r66.0<1>:f    r61.0<1;1,0>:f                   {I@2}
(W)     bfn.0xEA (16|M0)         r63.0<1>:ud   r1.2<0;0>:ud      r63.0<1;0>:ud     r6.0<0>:ud       {A@2} // s0|s1&s2
(W)     add (16|M0)              r68.0<1>:d    r66.0<1;1,0>:d    126:w               {Compacted,F@1}
(W)     add (16|M0)              r7.0<1>:d     -r66.0<1;1,0>:d   -152:w               {Compacted}
        sync.nop                             null                             {Compacted,I@3}
(W)     math.inv (16|M0)         r9.0<1>:f     r63.0<1;1,0>:f                   {$10}
(W)     cmp (16|M0)   (eq)f0.0   null<1>:w     r65.0<1;1,0>:ub   0x0:uw             
(W)     and (16|M0)              r7.0<1>:d     r7.0<1;1,0>:d     r68.0<1;1,0>:d   {Compacted,I@2}
(W)     mov (1|M0)               r2.6<1>:f     1.0:f                               {Compacted}
(W)     bfn.0xEA (16|M0)         r74.0<1>:ud   r1.2<0;0>:ud      r74.0<1;0>:ud     r6.0<0>:ud       // s0|s1&s2
(W)     asr (16|M0)              r7.0<1>:d     r7.0<1;1,0>:d     31:w               {Compacted,I@2}
        sync.nop                             null                             {Compacted,$10.dst}
(W)     mad (16|M0)              r70.0<1>:f    r2.6<0;0>:f       r9.0<1;0>:f       -r63.0<1>:f      {F@1}
(W)     mul (16|M0)              acc0.0<1>:f   r9.0<1;1,0>:f     r74.0<1;1,0>:f   {Compacted,I@2}
(W&f0.0) sel (16|M0)             r76.0<1>:w    r7.0<4;1,0>:ub    0:w               {I@1}
(W)     mad (16|M0)              r70.0<1>:f    r9.0<1;0>:f       r9.0<1;0>:f       r70.0<1>:f       {Compacted,F@2}
(W)     mad (16|M0)              r72.0<1>:f    r74.0<1;0>:f      acc0.0<1;0>:f     -r63.0<1>:f     
(W)     cmp (16|M0)   (ne)f1.1   null<1>:w     r76.0<2;1,0>:ub   0x0:uw              {I@1}
(W)     mad (16|M0)              r72.0<1>:f    acc0.0<1;0>:f     r70.0<1;0>:f      r72.0<1>:f       {F@1}
(W)     add (16|M0)              r40.0<1>:d    r40.0<1;1,0>:d    -r47.0<1;1,0>:d  {Compacted}
(W)     mad (16|M0)              r74.0<1>:f    r74.0<1;0>:f      r72.0<1;0>:f      -r63.0<1>:f      {Compacted,F@1}
(~f1.1.any16h) goto (16|M0)                  L12632                  L12632                
L12056:
(W)     mov (16|M0)              r85.0<1>:ud   r74.0<1;1,0>:ud                  {F@1}
(W)     mov (16|M0)              r81.0<1>:f    r70.0<1;1,0>:f                   {Compacted}
(W)     mov (16|M0)              r83.0<1>:f    r72.0<1;1,0>:f                   {Compacted}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r87.6         L13096                                 {A@1}
L12136:
(W)     add (16|M0)              r66.0<1>:d    r66.0<1;1,0>:d    125:w               {Compacted}
(W)     cmp (16|M0)   (lt)f1.0   null<1>:d     r66.0<1;1,0>:d    -2:w               {I@1}
(W)     cmp (16|M0)   (eq)f0.1   null<1>:f     r74.0<1;1,0>:f    0.0:f              
(W)     mov (1|M0)               r1.3<1>:uw    f1.0<0;1,0>:uw                  
(W)     or (1|M0)                f1.0<1>:uw    f0.1<0;1,0>:uw    r1.3<0;1,0>:uw   {I@1}
(f1.0.any16h) goto (16|M0)                   L12272                  L12272                
L12224:
(W)     mov (1|M0)               r1.3<1>:hf    0x1:hf                              {I@2}
(W&f0.1) sel (16|M0)             r77.0<1>:d    r1.3<0;1,0>:w     0:w               {F@1}
        goto (16|M0)                         L12272                  L12392                
L12272:
        join (16|M0)                         L12392                                
L12288:
(W)     mov (1|M0)               r1.3<1>:hf    0x1:hf                              {I@3}
(W)     and (16|M0)              r6.0<1>:d     r85.0<1;1,0>:d    -2139095041:d              
(W)     mov (1|M0)               r8.0<1>:f     0x800000:f                               {Compacted}
(W)     shl (16|M0)              r68.0<1>:d    r68.0<1;1,0>:d    23:w               {Compacted}
(W&f0.1) sel (16|M0)             r77.0<1>:d    r1.3<0;1,0>:w     0:w               {F@2}
(W)     add (16|M0)              r68.0<1>:d    r68.0<1;1,0>:d    1065353216:d               {I@2}
(W)     bfn.0xFE (16|M0)         r6.0<1>:ud    r6.0<1;0>:ud      r77.0<1;0>:ud     r8.0<0>:ud       {A@1} // s0|s1|s2
(W)     mul (16|M0)              r68.0<1>:f    r68.0<1;1,0>:f    r6.0<1;1,0>:f    {Compacted,A@1}
L12392:
        join (16|M0)                         L12632                                
L12408:
(W)     and (16|M0)   (eq)f0.1   null<1>:ud    r85.0<1;1,0>:ud   0x400000:ud             
(W)     shl (16|M0)              r6.0<1>:d     r85.0<1;1,0>:d    1:w               {Compacted,F@1}
(W)     mov (1|M0)               r1.2<1>:f     0x800000:f                               {Compacted}
(W)     mov (1|M0)               r8.0<1>:f     -0.0:f                               {Compacted}
(W)     mov (1|M0)               r2.6<1>:f     1.469368e-38:f                               {Compacted}
(W)     and (16|M0)              r6.0<1>:d     r6.0<1;1,0>:d     8388606:d               {I@1}
(W)     bfn.0xEA (16|M0)         r9.0<1>:ud    r1.2<0;0>:ud      r85.0<1;0>:ud     r8.0<0>:ud       {A@2} // s0|s1&s2
(W&f0.1) sel (16|M0)             r11.0<1>:d    r2.6<0;1,0>:d     12582912:d               {F@1}
(W)     mov (1|M0)               r3.2<1>:f     0.25:f                               {Compacted}
(W)     bfn.0xFE (16|M0)         r77.0<1>:ud   r77.0<1;0>:ud     r9.0<1;0>:ud      r6.0<1>:ud       {I@2} // s0|s1|s2
(W)     bfn.0xEA (16|M0)         r11.0<1>:ud   r11.0<1;0>:ud     r85.0<1;0>:ud     r8.0<0>:ud       {I@2} // s0|s1&s2
(W)     mad (16|M0)              r77.0<1>:f    r11.0<1;0>:f      r77.0<1;0>:f      r3.2<0>:f        {Compacted,A@1}
(W)     add (16|M0)              r77.0<1>:f    r77.0<1;1,0>:f    -r9.0<1;1,0>:f   {Compacted,F@1}
(W)     mul (16|M0)              r9.0<1>:f     r9.0<1;1,0>:f     r9.0<1;1,0>:f    {Compacted}
(W)     bfn.0xAE (16|M0)         r77.0<1>:ud   r77.0<1;0>:ud     r9.0<1;0>:ud      0x1:uw              {A@1} // s0|s1&~s2
(W&~f1.0) mov (16|M0)            r68.0<1>:f    r77.0<1;1,0>:f                   {I@1}
(W)     and (16|M0)   (ne)f1.0   null<1>:w     r76.0<2;1,0>:ub   1:w               {F@1}
(W&f1.0) mov (16|M0)             r79.0<1>:f    r68.0<1;1,0>:f                  
L12632:
        join (16|M0)                         L12888                                
L12648:
(W)     add (16|M0)              r6.0<1>:d     r40.0<1;1,0>:d    -253:w               {Compacted}
(W)     cmp (16|M0)   (lt)f1.1   null<1>:d     r6.0<1;1,0>:ud    0xFFFFFE85:ud              {I@1}
(W)     mov (1|M0)               r1.3<1>:hf    -qnan(0x1FF):hf                             
(W)     asr (16|M0)              r8.0<1>:d     r40.0<1;1,0>:d    11:w               {Compacted}
(W&f1.1.any16h) sel (1|M0)       r2.12<1>:w    r1.3<0;1,0>:w     0:w               {F@1}
(W)     add (16|M0)              r10.0<1>:d    r8.0<1;1,0>:d     248:w               {Compacted,I@2}
(W)     mov (1|M0)               f0.1<1>:uw    r2.12<0;1,0>:uw                  {I@2}
(W)     mov (16|M0)              r12.0<1>:f    r40.0<1;1,0>:f                   {Compacted}
(W&f1.1) xor (16|M0)             r12.0<1>:d    r10.0<1;1,0>:d    r8.0<1;1,0>:d    {A@1}
(W&~f0.1) mov (16|M0)            r12.0<1>:f    r40.0<1;1,0>:f                   {I@1}
(W)     asr (16|M0)              r14.0<1>:d    r12.0<1;1,0>:d    1:w               {Compacted,F@1}
(W)     mov (16|M0)              r6.0<1>:uw    r65.0<1;1,0>:ub                 
(W)     add (16|M0)              r12.0<1>:d    r12.0<1;1,0>:d    -r14.0<1;1,0>:d  {Compacted,I@2}
(W)     mad (16|M0)              r74.0<1>:f    r72.0<1;0>:f      r70.0<1;0>:f      r74.0<1>:f       {Compacted}
(W)     or (16|M0)    (eq)f0.0   null<1>:w     r76.0<2;1,0>:ub   r6.0<1;1,0>:uw   {I@2}
(W)     shl (16|M0)              r14.0<1>:d    r14.0<1;1,0>:d    23:w               {Compacted}
(W)     shl (16|M0)              r12.0<1>:d    r12.0<1;1,0>:d    23:w               {Compacted,I@3}
(W)     add (16|M0)              r14.0<1>:d    r14.0<1;1,0>:d    r74.0<1;1,0>:d   {Compacted,A@1}
(W)     add (16|M0)              r12.0<1>:d    r12.0<1;1,0>:d    1065353216:d               {I@2}
(W&f0.0) mul (16|M0)             r79.0<1>:f    r14.0<1;1,0>:f    r12.0<1;1,0>:f   {A@1}
L12888:
        join (16|M0)                         L12904                                
L12904:
(W)     math.inv (16|M0)         r6.0<1>:f     r44.0<1;1,0>:f                   {$11}
(W)     mov (1|M0)               r1.2<1>:ud    0x3F800000:ud                             
(W)     mul (16|M0)              acc0.0<1>:f   r6.0<1;1,0>:f     r37.0<1;1,0>:f   {Compacted,$11.dst}
(W)     mad (16|M0)              acc2.0<1>:f   r1.2<0;0>:f       r6.0<1;0>:f       -r44.0<1>:f      {I@1}
(W)     mad (16|M0)              r12.0<1>:f    r37.0<1;0>:f      acc0.0<1;0>:f     -r44.0<1>:f     
(W)     mad (16|M0)              acc2.0<1>:f   r6.0<1;0>:f       acc2.0<1;0>:f     r6.0<1>:f        {Compacted}
(W)     mov (1|M0)               f0.0<1>:uw    r88.4<0;1,0>:uw                  {F@5}
(W)     mad (16|M0)              acc0.0<1>:f   acc0.0<1;0>:f     acc2.0<1;0>:f     r12.0<1>:f       {F@2}
(W)     mad (16|M0)              r37.0<1>:f    r37.0<1;0>:f      acc0.0<1;0>:f     -r44.0<1>:f     
(W&~f0.0) mad (16|M0)            r79.0<1>:f    acc0.0<1;0>:f     acc2.0<1;0>:f     r37.0<1>:f       {F@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        ret (16|M0)                          r87.2                            {A@1}
L13096:
(W)     mov (1|M0)               r1.2<1>:d     cr0.0<0;1,0>:ud                  {A@1}
(W)     and (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   -1265:w               {A@1}
(W)     or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   1264:w               {A@1}
(W)     mad (16|M0)              r85.0<1>:f    r83.0<1;0>:f      r81.0<1;0>:f      r85.0<1>:f       {Compacted,A@1}
(W)     mov (1|M0)               cr0.0<1>:ud   r1.2<0;1,0>:d                    {A@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        ret (16|M0)                          r87.6                            {A@1}
L13216:
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
