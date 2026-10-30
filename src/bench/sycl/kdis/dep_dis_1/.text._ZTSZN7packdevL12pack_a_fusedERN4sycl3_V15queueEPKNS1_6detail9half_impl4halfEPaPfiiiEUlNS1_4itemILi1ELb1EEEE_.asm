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
        mov (1|M0)               r16.2<1>:d    r2.6<0;1,0>:d                   
        addc (1|M0)              r7.0<1>:ud    r5.0<0;1,0>:ud    r1.2<0;1,0>:ud   {AccWrEn,I@2}
        asr (1|M0)               r16.3<1>:d    r2.6<0;1,0>:d     31:w              
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r16.0<1>:f    r7.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r16.1<1>:d    r8.0<0;0>:d       r6.0<0;0>:d       0:w               {I@1}
(W)     mov (2|M0)               r16.4<1>:ud   r16.2<1;1,0>:ud                 
(W)     mov (2|M0)               r16.6<1>:ud   r16.0<1;1,0>:ud                  {A@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r9.0          L4584                                 {A@1}
L472:
        mul (1|M0)               acc0.0<1>:ud  r31.2<0;1,0>:ud   r16.4<0;1,0>:uw 
        mach (1|M0)              r6.0<1>:ud    r31.2<0;1,0>:ud   r16.2<0;1,0>:ud  {AccWrEn}
        shr (1|M0)               r2.3<1>:ud    r31.2<0;1,0>:ud   0x7:uw             
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r31.2<0;1,0>:d    r16.6<0;1,0>:uw 
        mach (1|M0)              r7.0<1>:d     r31.2<0;1,0>:d    r16.3<0;1,0>:d  
(W)     mul (1|M0)               acc0.0<1>:d   r31.3<0;1,0>:d    r16.4<0;1,0>:uw 
        mach (1|M0)              r8.0<1>:d     r31.3<0;1,0>:d    r16.2<0;1,0>:d  
        subb (1|M0)              r9.0<1>:ud    r16.0<0;1,0>:ud   r5.0<0;1,0>:ud   {AccWrEn,I@5}
        shl (1|M0)               r2.4<1>:d     r31.3<0;1,0>:d    25:w              
        mov (1|M0)               r16.4<1>:d    r2.7<0;1,0>:d                   
        add3 (1|M0)              r1.3<1>:d     r8.0<0;0>:d       r6.0<0;0>:d       r7.0<0>:d        {I@4}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        or (1|M0)                r4.2<1>:d     r2.3<0;1,0>:d     r2.4<0;1,0>:d    {I@4}
        add3 (1|M0)              r16.3<1>:d    r16.1<0;0>:d      -r10.0<0;0>:d     -r1.3<0>:d       {I@2}
        mov (2|M0)               r1.2<1>:d     r16.4<1;1,0>:d                  
        cmp (1|M0)    (lt)f0.1   null<1>:d     r31.2<0;1,0>:d    r3.0<0;1,0>:d   
        mul (1|M0)               acc0.0<1>:ud  r4.2<0;1,0>:ud    r1.4<0;1,0>:uw   {I@2}
        asr (1|M0)               r1.3<1>:d     r2.7<0;1,0>:d     31:w              
        mach (1|M0)              r6.0<1>:ud    r4.2<0;1,0>:ud    r1.2<0;1,0>:ud   {AccWrEn}
        shr (1|M0)               r4.3<1>:ud    r31.3<0;1,0>:ud   0x7:uw             
        shr (1|M0)               r3.1<1>:ud    r31.2<0;1,0>:ud   0x4:uw             
        shl (1|M0)               r3.7<1>:d     r31.3<0;1,0>:d    28:w              
(W)     and (1|M0)               f0.0<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r4.2<0;1,0>:d     r1.6<0;1,0>:uw   {I@7}
        mach (1|M0)              r7.0<1>:d     r4.2<0;1,0>:d     r1.3<0;1,0>:d   
(W)     mul (1|M0)               acc0.0<1>:d   r4.3<0;1,0>:d     r1.4<0;1,0>:uw   {I@7}
        mov (2|M0)               r4.8<1>:w     0x7070707:v                              
        shr (1|M0)               r16.1<1>:ud   r31.3<0;1,0>:ud   0x4:uw             
        or (1|M0)                r16.0<1>:d    r3.1<0;1,0>:d     r3.7<0;1,0>:d    {I@7}
        mach (1|M0)              r8.0<1>:d     r4.3<0;1,0>:d     r1.2<0;1,0>:d   
        and (1|M0)               r31.4<1>:d    r31.2<0;1,0>:d    15:w              
        mov (1|M0)               r16.2<1>:d    r9.0<0;1,0>:d                   
        mov (1|M0)               r31.0<1>:f    r5.0<0;1,0>:f                    {Compacted,I@7}
        and (2|M0)               r16.0<1>:d    r16.0<1;1,0>:d    r4.8<1;1,0>:w    {I@4}
        add3 (1|M0)              r31.1<1>:d    r8.0<0;0>:d       r6.0<0;0>:d       r7.0<0>:d        {I@4}
(f0.0.any16h) goto (16|M0)                   L1792                  L1792                
L1048:
        shl (1|M0)               r4.2<1>:d     r16.2<0;1,0>:d    3:w               {I@4}
        shl (1|M0)               r1.2<1>:d     r16.1<0;1,0>:d    9:w               {I@4}
        cmp (1|M0)    (eq)f0.0   null<1>:d     r4.2<0;1,0>:d     2147483640:d               {I@2}
        shr (1|M0)               r1.3<1>:ud    r16.0<0;1,0>:ud   0x17:uw             
        shl (1|M0)               r4.5<1>:d     r16.0<0;1,0>:d    9:w               {Compacted}
        shl (1|M0)               r4.3<1>:d     r31.4<0;1,0>:d    5:w              
(W)     and (1|M0)               f1.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
        mov (1|M0)               r4.4<1>:d     0:w                              
        add (1|M0)               r3.7<1>:d     r4.2<0;1,0>:d     8:w              
        or (1|M0)                r4.6<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@6}
(f1.1.any16h) goto (16|M0)                   L1792                  L4512                
L1216:
        addc (1|M0)              r5.0<1>:ud    r3.2<0;1,0>:ud    r4.5<0;1,0>:ud   {AccWrEn,A@1}
        mov (1|M0)               r16.6<1>:d    r4.2<0;1,0>:d                   
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r7.0<1>:ud    r5.0<0;1,0>:ud    r4.3<0;1,0>:ud   {AccWrEn,I@3}
        add3 (1|M0)              r1.3<1>:d     r6.0<0;0>:d       r3.3<0;0>:d       r4.6<0>:d        {I@2}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        asr (1|M0)               r16.7<1>:d    r4.2<0;1,0>:d     31:w              
        mov (1|M0)               r31.5<1>:d    r3.7<0;1,0>:d                   
        asr (1|M0)               r31.6<1>:d    r3.7<0;1,0>:d     31:w              
        mov (1|M0)               r3.0<1>:f     r7.0<0;1,0>:f                    {Compacted,I@6}
        add3 (1|M0)              r3.1<1>:d     r8.0<0;0>:d       r1.3<0;0>:d       r4.4<0>:d        {I@4}
L1368:
        addc (1|M0)              r5.0<1>:ud    r16.6<0;1,0>:ud   r31.0<0;1,0>:ud  {AccWrEn}
(W)     mov (1|M0)               r1.3<1>:hf    0x1:hf                             
        shl (1|M0)               r4.2<1>:d     r5.0<0;1,0>:d     12:w               {Compacted,I@1}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r7.0<1>:ud    r3.0<0;1,0>:ud    r4.2<0;1,0>:ud   {AccWrEn,A@2}
        add3 (1|M0)              r1.3<1>:d     r6.0<0;0>:d       r16.7<0;0>:d      r31.1<0>:d       {I@2}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r6.0<1>:ud    r16.6<0;1,0>:ud   0x1:ud              {AccWrEn}
        shr (1|M0)               r2.4<1>:ud    r5.0<0;1,0>:ud    0x14:uw             
        shl (1|M0)               r2.3<1>:d     r1.3<0;1,0>:d     12:w               {Compacted,I@4}
        mov (1|M0)               r4.2<1>:d     r6.0<0;1,0>:d                    {I@3}
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        or (1|M0)                r4.3<1>:d     r2.3<0;1,0>:d     r2.4<0;1,0>:d    {I@3}
        cmp (1|M0)    (lt)f1.1   null<1>:ud    r4.2<0;1,0>:ud    r31.5<0;1,0>:ud  {I@3}
        sync.nop                             null                             {Compacted,$3.src}
        add3 (1|M0)              r9.1<1>:d     r8.0<0;0>:d       r3.1<0;0>:d       r4.3<0>:d        {I@2}
        add3 (1|M0)              r4.3<1>:d     r11.0<0;0>:d      r16.7<0;0>:d      0:w              
        mov (4|M0)               r10.0<2>:f    0.0:f                              
        cmp (1|M0)    (lt)f0.0   null<1>:d     r4.3<0;1,0>:d     r31.6<0;1,0>:d   {I@1}
(f1.1)  cmp (1|M0)    (eq)f1.1   null<1>:d     r4.3<0;1,0>:d     r31.6<0;1,0>:d  
        mov (1|M0)               r9.0<1>:f     r7.0<0;1,0>:f                    {Compacted}
        mov (4|M0)               r10.1<2>:f    0.0:f                              
(f0.0)  sel (1|M0)               r2.6<1>:uw    r1.3<0;1,0>:uw    0x0:uw              {F@4}
(f1.1)  sel (1|M0)               r1.4<1>:uw    r1.3<0;1,0>:uw    0x0:uw             
        send.ugm (1|M0)          null     r9      r10:1   0x0            0x0200B784           {A@1,$3} // wr:1+1, rd:0; store.ugm.d64x4t.a64
        or (1|M0)     (ne)f1.1   null<1>:uw    r1.4<0;1,0>:uw    r2.6<0;1,0>:uw   {I@1}
(W)     and (1|M0)               f1.0<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(~f1.0.any16h) goto (16|M0)                  L1792                  L4512                
L1760:
(W)     mov (2|M0)               r16.6<1>:ud   r4.2<1;1,0>:ud                  
        goto.b (16|M0)                       L1792                  L1368                
L1792:
        join (16|M0)                         L4512                                
L1808:
        cmp (1|M0)    (gt)f1.0   null<1>:d     r2.7<0;1,0>:d     0:w              
        mov (16|M0)              r70.0<1>:ud   0x0:ud                             
        mov (16|M0)              r72.0<1>:f    0.0:f                               {Compacted}
(W)     and (1|M0)               f0.1<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
(~f0.1.any16h) goto (16|M0)                  L2616                  L2616                
L1880:
        mov (1|M0)               r1.2<1>:d     r3.6<0;1,0>:d                   
        asr (1|M0)               r1.3<1>:d     r3.6<0;1,0>:d     31:w              
        mul (1|M0)               acc0.0<1>:ud  r31.2<0;1,0>:ud   r1.4<0;1,0>:uw   {I@2}
        mach (1|M0)              r6.0<1>:ud    r31.2<0;1,0>:ud   r1.2<0;1,0>:ud   {AccWrEn}
        mov (1|M0)               r16.5<1>:d    0:w                              
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r31.2<0;1,0>:d    r1.6<0;1,0>:uw   {I@5}
        mach (1|M0)              r7.0<1>:d     r31.2<0;1,0>:d    r1.3<0;1,0>:d   
(W)     mul (1|M0)               acc0.0<1>:d   r31.3<0;1,0>:d    r1.4<0;1,0>:uw  
        mach (1|M0)              r8.0<1>:d     r31.3<0;1,0>:d    r1.2<0;1,0>:d   
        shl (1|M0)               r4.2<1>:d     r5.0<0;1,0>:d     1:w               {Compacted,I@5}
        add3 (1|M0)              r2.4<1>:d     r8.0<0;0>:d       r6.0<0;0>:d       r7.0<0>:d        {I@2}
        shr (1|M0)               r3.7<1>:ud    r5.0<0;1,0>:ud    0x1F:uw             
        sync.nop                             null                             {Compacted,$3.src}
        addc (1|M0)              r9.0<1>:ud    r3.4<0;1,0>:ud    r4.2<0;1,0>:ud   {AccWrEn,I@3}
        shl (1|M0)               r3.1<1>:d     r2.4<0;1,0>:d     1:w               {I@3}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        or (1|M0)                r4.3<1>:d     r3.1<0;1,0>:d     r3.7<0;1,0>:d    {I@2}
        mov (1|M0)               r3.0<2>:f     0.0:f                              
        mov (1|M0)               r16.6<1>:d    r9.0<0;1,0>:d                   
        mov (1|M0)               r3.1<2>:f     0.0:f                               {I@2}
        add3 (1|M0)              r16.7<1>:d    r10.0<0;0>:d      r3.5<0;0>:d       r4.3<0>:d       
L2200:
        shl (1|M0)               r1.2<1>:d     r3.1<0;1,0>:d     5:w               {F@1}
        shr (1|M0)               r1.3<1>:ud    r3.0<0;1,0>:ud    0x1B:uw             
        shl (1|M0)               r1.4<1>:d     r3.0<0;1,0>:d     5:w               {Compacted}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        shl (1|M0)               r4.2<1>:d     r1.4<0;1,0>:d     1:w               {I@2}
        shr (1|M0)               r2.4<1>:ud    r1.4<0;1,0>:ud    0x1F:uw             
        shl (1|M0)               r2.3<1>:d     r1.5<0;1,0>:d     1:w               {I@3}
        addc (1|M0)              r5.0<1>:ud    r16.6<0;1,0>:ud   r4.2<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r4.3<1>:d     r2.3<0;1,0>:d     r2.4<0;1,0>:d    {I@2}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r7.0<1>:f     r5.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r7.1<1>:d     r6.0<0;0>:d       r16.7<0;0>:d      r4.3<0>:d        {I@1}
        addc (1|M0)              r14.0<1>:ud   r3.0<0;1,0>:ud    0x1:ud              {AccWrEn}
        send.ugm (1|M0)          r8       r7      null:0  0x0            0x0220C780           {A@1,$4} // wr:1+0, rd:2; load.ugm.d64x8t.a64
        mov (1|M0)               r15.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r4.2<1>:d     r14.0<0;1,0>:d                   {I@2}
        add3 (1|M0)              r4.3<1>:d     r15.0<0;0>:d      r3.1<0;0>:d       0:w               {I@2}
        cmp (1|M0)    (eq)f0.0   null<1>:d     r4.3<0;1,0>:d     r16.5<0;1,0>:d   {I@1}
(f0.0)  cmp (1|M0)    (eq)f0.0   null<1>:d     r4.2<0;1,0>:d     r16.4<0;1,0>:d  
(W)     and (1|M0)               f0.0<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
        mov (8|M0)               r10.0<1>:f    (abs)r8.0<1;1,0>:hf              {$4.dst}
        mov (8|M0)               r11.0<1>:f    (abs)r8.8<1;1,0>:hf             
        mov (8|M0)               r12.0<1>:f    (abs)r9.0<1;1,0>:hf             
        mov (8|M0)               r13.0<1>:f    (abs)r9.8<1;1,0>:hf             
        sel (16|M0)   (ge)f0.0   r70.0<1>:f    r70.0<1;1,0>:f    r10.0<1;1,0>:f   {Compacted,F@3}
        sel (16|M0)   (ge)f0.0   r72.0<1>:f    r72.0<1;1,0>:f    r12.0<1;1,0>:f   {Compacted,F@2}
(f0.0.any16h) goto (16|M0)                   L2616                  L2616                
L2584:
(W)     mov (2|M0)               r3.0<1>:ud    r4.2<1;1,0>:ud                  
        goto.b (16|M0)                       L2616                  L2200                
L2616:
        join (16|M0)                         L4512                                
L2632:
        sel (16|M0)   (ge)f0.0   r70.0<1>:f    r70.0<1;1,0>:f    r72.0<1;1,0>:f   {Compacted,F@1}
        sel (8|M0)    (ge)f0.0   r5.0<1>:f     r70.0<1;1,0>:f    r71.0<1;1,0>:f   {Compacted,F@1}
        mov (4|M0)               r6.0<1>:ud    r5.4<1;1,0>:ud                   {F@1}
        sel (4|M0)    (ge)f0.0   r7.0<1>:f     r5.0<1;1,0>:f     r6.0<1;1,0>:f    {I@1}
        mov (2|M0)               r8.0<1>:ud    r7.2<1;1,0>:ud                   {F@1}
        sync.nop                             null                             {Compacted,$3.src}
        sel (2|M0)    (ge)f0.0   r9.0<1>:f     r7.0<1;1,0>:f     r8.0<1;1,0>:f    {I@1}
        sel (1|M0)    (ge)f0.0   r14.4<1>:f    r9.0<0;1,0>:f     r9.1<0;1,0>:f    {F@1}
        cmp (1|M0)    (eq)f0.1   null<1>:f     r14.4<0;1,0>:f    0.0:f               {F@1}
(W)     and (1|M0)               f1.1<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(f1.1.any16h) goto (16|M0)                   L2864                  L2864                
L2784:
        mov (1|M0)               r14.5<1>:f    127.0:f                              
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r14.2         L8704                                 {A@1}
L2848:
        goto (16|M0)                         L2864                  L2888                
L2864:
        join (16|M0)                         L2888                                
L2880:
        mov (1|M0)               r14.0<1>:f    1.0:f                               {Compacted}
L2888:
        join (16|M0)                         L4512                                
L2904:
        shl (1|M0)               r31.6<1>:d    r16.2<0;1,0>:d    3:w              
        shl (1|M0)               r1.4<1>:d     r31.2<0;1,0>:d    2:w              
        cmp (1|M0)    (eq)f0.0   null<1>:d     r31.6<0;1,0>:d    2147483640:d               {I@2}
        shl (1|M0)               r1.2<1>:d     r31.3<0;1,0>:d    2:w              
        shr (1|M0)               r1.3<1>:ud    r31.2<0;1,0>:ud   0x1E:uw             
        addc (1|M0)              r5.0<1>:ud    r4.0<0;1,0>:ud    r1.4<0;1,0>:ud   {AccWrEn,I@4}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
(W)     and (1|M0)               f1.0<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        shl (1|M0)               r2.3<1>:d     r16.1<0;1,0>:d    9:w              
        shr (1|M0)               r2.4<1>:ud    r16.0<0;1,0>:ud   0x17:uw             
        mov (1|M0)               r8.0<1>:f     r5.0<0;1,0>:f                    {Compacted,I@6}
        add3 (1|M0)              r8.1<1>:d     r6.0<0;0>:d       r4.1<0;0>:d       r1.5<0>:d        {I@3}
        shl (1|M0)               r14.4<1>:d    r16.0<0;1,0>:d    9:w               {Compacted,F@4}
        send.ugm (1|M0)          null     r8      r14:1   0x0            0x04000584           {A@1,$5} // wr:2+1, rd:0; store.ugm.d32.a64
        shl (1|M0)               r14.2<1>:d    r31.4<0;1,0>:d    5:w               {$5.src}
        mov (1|M0)               r14.3<1>:d    0:w                              
        add (1|M0)               r14.1<1>:d    r31.6<0;1,0>:d    8:w              
        or (1|M0)                r14.5<1>:d    r2.3<0;1,0>:d     r2.4<0;1,0>:d   
(f1.0.any16h) goto (16|M0)                   L4512                  L4512                
L3200:
        mov (1|M0)               r1.2<1>:d     r3.6<0;1,0>:d                   
        asr (1|M0)               r1.3<1>:d     r3.6<0;1,0>:d     31:w              
        mul (1|M0)               acc0.0<1>:ud  r31.2<0;1,0>:ud   r1.4<0;1,0>:uw   {I@2}
        mach (1|M0)              r6.0<1>:ud    r31.2<0;1,0>:ud   r1.2<0;1,0>:ud   {AccWrEn}
        mov (16|M0)              r15.0<1>:f    r14.0<0;1,0>:f                   {Compacted}
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r31.2<0;1,0>:d    r1.6<0;1,0>:uw   {I@4}
        shl (1|M0)               r4.2<1>:d     r5.0<0;1,0>:d     1:w               {Compacted,I@2}
        mach (1|M0)              r7.0<1>:d     r31.2<0;1,0>:d    r1.3<0;1,0>:d   
(W)     mul (1|M0)               acc0.0<1>:d   r31.3<0;1,0>:d    r1.4<0;1,0>:uw  
        mach (1|M0)              r8.0<1>:d     r31.3<0;1,0>:d    r1.2<0;1,0>:d   
        addc (1|M0)              r9.0<1>:ud    r3.4<0;1,0>:ud    r4.2<0;1,0>:ud   {AccWrEn,I@4}
        add3 (1|M0)              r2.4<1>:d     r8.0<0;0>:d       r6.0<0;0>:d       r7.0<0>:d        {I@2}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r11.0<1>:ud   r3.2<0;1,0>:ud    r14.4<0;1,0>:ud  {AccWrEn}
        shr (1|M0)               r3.7<1>:ud    r5.0<0;1,0>:ud    0x1F:uw             
        shl (1|M0)               r3.1<1>:d     r2.4<0;1,0>:d     1:w               {I@4}
        mov (1|M0)               r12.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r7.0<1>:ud    r11.0<0;1,0>:ud   r14.2<0;1,0>:ud  {AccWrEn,I@4}
        or (1|M0)                r4.3<1>:d     r3.1<0;1,0>:d     r3.7<0;1,0>:d    {I@3}
        add3 (1|M0)              r1.3<1>:d     r12.0<0;0>:d      r3.3<0;0>:d       r14.5<0>:d       {I@3}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r60.4<1>:d    r31.6<0;1,0>:d                  
        asr (1|M0)               r60.5<1>:d    r31.6<0;1,0>:d    31:w              
        mov (1|M0)               r60.6<1>:d    r14.1<0;1,0>:d                  
        asr (1|M0)               r60.7<1>:d    r14.1<0;1,0>:d    31:w              
        mov (1|M0)               r60.0<1>:f    r9.0<0;1,0>:f                    {Compacted}
        mov (1|M0)               r60.2<1>:d    r7.0<0;1,0>:d                    {I@7}
        add3 (1|M0)              r60.1<1>:d    r10.0<0;0>:d      r3.5<0;0>:d       r4.3<0>:d        {I@7}
        add3 (1|M0)              r60.3<1>:d    r8.0<0;0>:d       r1.3<0;0>:d       r14.3<0>:d       {I@7}
L3624:
        shl (1|M0)               r1.2<1>:d     r31.6<0;1,0>:d    5:w              
        mov (16|M0)              r21.0<1>:f    r15.0<1;1,0>:f                   {Compacted,F@2}
        asr (1|M0)               r1.4<1>:d     r1.2<0;1,0>:d     31:w               {I@1}
        shl (1|M0)               r4.2<1>:d     r1.2<0;1,0>:d     1:w              
        shr (1|M0)               r2.4<1>:ud    r1.2<0;1,0>:ud    0x1F:uw             
        shl (1|M0)               r2.3<1>:d     r1.4<0;1,0>:d     1:w               {I@3}
        addc (1|M0)              r5.0<1>:ud    r60.0<0;1,0>:ud   r4.2<0;1,0>:ud   {AccWrEn,A@2}
        or (1|M0)                r4.3<1>:d     r2.3<0;1,0>:d     r2.4<0;1,0>:d    {I@2}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r7.0<1>:f     r5.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r7.1<1>:d     r6.0<0;0>:d       r60.1<0;0>:d      r4.3<0>:d        {I@1}
        send.ugm (1|M0)          r8       r7      null:0  0x0            0x0220C780           {A@1,$7} // wr:1+0, rd:2; load.ugm.d64x8t.a64
        mov (8|M0)               r23.0<1>:f    r8.0<1;1,0>:hf                   {$7.dst}
        mov (8|M0)               r24.0<1>:f    r8.8<1;1,0>:hf                  
        mov (8|M0)               r27.0<1>:f    r9.0<1;1,0>:hf                  
        mov (8|M0)               r28.0<1>:f    r9.8<1;1,0>:hf                  
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r31.4         L5568                                 {A@1}
L3904:
        mov (16|M0)              r25.0<1>:ud   r17.0<1;1,0>:ud                 
        mov (16|M0)              r23.0<1>:f    r27.0<1;1,0>:f                   {Compacted,F@1}
        mov (16|M0)              r21.0<1>:f    r15.0<1;1,0>:f                   {Compacted}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r31.4         L5568                                 {A@1}
L3984:
        addc (1|M0)              r5.0<1>:ud    r60.4<0;1,0>:ud   r31.0<0;1,0>:ud  {AccWrEn}
(W)     mov (1|M0)               r1.3<1>:hf    0x1:hf                             
        shl (1|M0)               r4.2<1>:d     r5.0<0;1,0>:d     12:w               {Compacted,I@1}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r7.0<1>:ud    r60.2<0;1,0>:ud   r4.2<0;1,0>:ud   {AccWrEn,I@2}
        add3 (1|M0)              r1.3<1>:d     r6.0<0;0>:d       r60.5<0;0>:d      r31.1<0>:d       {I@2}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r6.0<1>:ud    r60.4<0;1,0>:ud   0x1:ud              {AccWrEn}
        shr (1|M0)               r2.4<1>:ud    r5.0<0;1,0>:ud    0x14:uw             
        mov (1|M0)               r31.2<1>:d    r6.0<0;1,0>:d                    {I@2}
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        cmp (1|M0)    (lt)f1.0   null<1>:ud    r31.2<0;1,0>:ud   r60.6<0;1,0>:ud  {I@2}
        add3 (1|M0)              r31.3<1>:d    r5.0<0;0>:d       r60.5<0;0>:d      0:w               {I@2}
        shl (1|M0)               r2.3<1>:d     r1.3<0;1,0>:d     12:w               {Compacted}
        cmp (1|M0)    (lt)f1.1   null<1>:d     r31.3<0;1,0>:d    r60.7<0;1,0>:d   {I@2}
(f1.0)  cmp (1|M0)    (eq)f1.0   null<1>:d     r31.3<0;1,0>:d    r60.7<0;1,0>:d  
        rnde (16|M0)             r25.0<1>:f    r25.0<1;1,0>:f                   {Compacted}
        rnde (16|M0)             r17.0<1>:f    r17.0<1;1,0>:f                   {Compacted}
        or (1|M0)                r4.3<1>:d     r2.3<0;1,0>:d     r2.4<0;1,0>:d    {I@3}
(f1.0)  sel (1|M0)               r1.4<1>:uw    r1.3<0;1,0>:uw    0x0:uw              {F@3}
(f1.1)  sel (1|M0)               r2.6<1>:uw    r1.3<0;1,0>:uw    0x0:uw             
        sel (16|M0)   (ge)f0.0   r25.0<1>:f    r25.0<1;1,0>:f    -127.0:f               {F@2}
        sel (16|M0)   (ge)f0.0   r17.0<1>:f    r17.0<1;1,0>:f    -127.0:f               {F@2}
        or (1|M0)     (ne)f1.1   null<1>:uw    r1.4<0;1,0>:uw    r2.6<0;1,0>:uw   {I@1}
        sel (16|M0)   (lt)f0.0   r25.0<1>:f    r25.0<1;1,0>:f    127.0:f               {F@2}
        sel (16|M0)   (lt)f0.0   r17.0<1>:f    r17.0<1;1,0>:f    127.0:f               {F@2}
        mov (16|M0)              r10.0<1>:d    r25.0<1;1,0>:f                   {Compacted,F@2}
(W)     and (1|M0)               f0.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
        mov (16|M0)              r12.0<1>:d    r17.0<1;1,0>:f                   {Compacted,F@1}
        mov (1|M0)               r9.0<1>:f     r7.0<0;1,0>:f                    {Compacted}
        add3 (1|M0)              r9.1<1>:d     r8.0<0;0>:d       r60.3<0;0>:d      r4.3<0>:d       
        mov (16|M0)              r14.0<1>:b    r10.0<4;1,0>:b                   {I@4}
        mov (16|M0)              r14.16<1>:b   r12.0<4;1,0>:b                   {I@3}
        send.ugm (1|M0)          null     r9      r14:1   0x0            0x0200B784           {A@1,$6} // wr:1+1, rd:0; store.ugm.d64x4t.a64
        add (1|M0)               r31.6<1>:d    r31.6<0;1,0>:d    1:w              
(~f0.1.any16h) goto (16|M0)                  L4512                  L4512                
L4480:
(W)     mov (2|M0)               r60.4<1>:ud   r31.2<1;1,0>:ud                 
        goto.b (16|M0)                       L4512                  L3624                
L4512:
        join (16|M0)                         L4528                                
L4528:
(W)     mov (8|M0)               r127.0<1>:f   r0.0<1;1,0>:f                    {Compacted}
(W)     send.ugm (1|M0)          r5       r0      null:0  0x0            0x0210641F           {$8} // wr:1+0, rd:1; fence invalid flush type scoped to tile
(W)     mov (8|M0)               null<1>:ud    r5.0<1;1,0>:ud                   {$8.dst}
(W)     send.gtwy (1|M0)         null     r127    null:0  0x0            0x02000010           {EOT,A@1} // wr:1+0, rd:0; end of thread
L4584:
        mov (2|M0)               r31.0<1>:d    0x1:v                              
        mov (1|M0)               r9.6<2>:f     0.0:f                              
        mov (1|M0)               r9.7<2>:f     0.0:f                              
        mov (1|M0)               r9.4<2>:f     0.0:f                              
        mov (1|M0)               r9.5<2>:d     0:d                              
        mov (1|M0)               r9.2<1>:d     63:w                              
L4680:
        and (1|M0)    (eq)f0.0   r2.3<1>:d     r9.2<0;1,0>:d     63:w               {I@1}
(W)     mov (1|M0)               r2.10<1>:hf   0.0:hf                             
        mov (1|M0)               r1.3<1>:d     0:w                              
        shr (1|M0)               r5.2<1>:ud    r9.4<0;1,0>:ud    0x1F:uw              {F@2}
        cmp (1|M0)    (ge)f0.1   null<1>:ud    r2.3<0;1,0>:ud    0x20:uw              {I@3}
(f0.0)  sel (1|M0)               r3.7<1>:d     r2.10<0;1,0>:w    -1:w               {F@1}
        add (1|M0)               r2.4<1>:d     -r2.3<0;1,0>:d    32:w              
        add (1|M0)               r4.3<1>:d     r2.3<0;1,0>:d     -32:w               {Compacted}
        and (1|M0)               r4.2<1>:d     r16.7<0;1,0>:d    r3.7<0;1,0>:d    {I@3}
        shr (1|M0)               r1.2<1>:ud    r16.6<0;1,0>:ud   r2.3<0;1,0>:ud  
(f0.1)  sel (1|M0)               r3.1<1>:d     r2.10<0;1,0>:w    -1:w              
        shr (1|M0)               r4.3<1>:ud    r16.7<0;1,0>:ud   r4.3<0;1,0>:ud   {I@4}
        shl (1|M0)               r4.2<1>:d     r4.2<0;1,0>:d     r2.4<0;1,0>:d    {I@4}
        shr (1|M0)               r1.3<1>:ud    r16.7<0;1,0>:ud   r2.3<0;1,0>:ud  
        shl (1|M0)               r2.5<1>:d     r9.5<0;1,0>:d     1:w              
        and (1|M0)               r1.2<1>:ud    r1.2<0;1,0>:ud    r3.1<0;1,0>:ud   {I@5}
        and (1|M0)               r4.3<1>:ud    r4.3<0;1,0>:ud    ~r3.1<0;1,0>:ud  {I@5}
        and (1|M0)               r4.2<1>:d     r4.2<0;1,0>:d     r3.1<0;1,0>:d    {I@5}
        shl (1|M0)               r6.0<1>:d     r9.4<0;1,0>:d     1:w               {Compacted}
        and (1|M0)               r5.1<1>:ud    r1.3<0;1,0>:ud    r3.1<0;1,0>:ud   {I@6}
        or (1|M0)                r6.1<1>:d     r2.5<0;1,0>:d     r5.2<0;1,0>:d    {I@6}
        bfn.0xFE (1|M0)          r5.0<1>:ud    r4.3<0;0>:ud      r1.2<0;0>:ud      r4.2<0>:ud       {I@4} // s0|s1|s2
(W)     mov (1|M0)               r1.3<1>:hf    0x1:hf                             
        bfn.0xEA (2|M0)          r6.0<1>:ud    r6.0<1;0>:ud      r5.0<1;0>:ud      r31.0<1>:ud      {I@1} // s0|s1&s2
        and (1|M0)               r3.7<1>:d     r3.7<0;1,0>:d     1:w              
        cmp (1|M0)    (lt)f0.1   null<1>:ud    r6.0<0;1,0>:ud    r16.4<0;1,0>:ud  {I@2}
        cmp (1|M0)    (lt)f1.1   null<1>:ud    r6.1<0;1,0>:ud    r16.5<0;1,0>:ud 
(W)     mov (1|M0)               r2.10<1>:hf   0x1:hf                             
        shl (1|M0)               r2.3<1>:ud    r1.3<0;1,0>:uw    r2.3<0;1,0>:ud   {F@2}
(f0.1)  cmp (1|M0)    (eq)f0.1   null<1>:d     r6.1<0;1,0>:d     r16.5<0;1,0>:d  
(f1.1)  sel (1|M0)               r1.5<1>:uw    r1.3<0;1,0>:uw    0x0:uw             
        subb (1|M0)              r7.0<1>:ud    r6.0<0;1,0>:ud    r16.4<0;1,0>:ud  {AccWrEn}
        shr (1|M0)               r3.7<1>:ud    r3.7<0;1,0>:ud    r2.4<0;1,0>:ud   {I@7}
(f0.1)  sel (1|M0)               r1.4<1>:uw    r1.3<0;1,0>:uw    0x0:uw             
        shl (1|M0)               r4.2<1>:d     r2.10<0;1,0>:w    -r2.4<0;1,0>:d   {F@1}
        or (1|M0)     (ne)f1.0   null<1>:uw    r1.4<0;1,0>:uw    r1.5<0;1,0>:uw   {I@2}
        and (1|M0)               r31.2<1>:ud   r2.3<0;1,0>:ud    r3.1<0;1,0>:ud  
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        bfn.0xCA (1|M0)          r31.3<1>:ud   r4.2<0;0>:ud      r3.7<0;0>:ud      r3.1<0>:ud       {I@4} // s0&~s2|s1&s2
        mov (1|M0)               r9.4<1>:d     r7.0<0;1,0>:d                   
        add3 (1|M0)              r9.5<1>:d     r6.1<0;0>:d       -r8.0<0;0>:d      -r16.5<0>:d      {I@3}
(f1.0)  mov (1|M0)               r9.4<1>:d     r6.0<0;1,0>:d                   
        or (2|M0)                r31.2<1>:d    r31.2<1;1,0>:d    r9.6<1;1,0>:d    {I@4}
(f1.0)  mov (1|M0)               r9.5<1>:d     r6.1<0;1,0>:d                   
(f1.0)  mov (1|M0)               r31.2<1>:d    r9.6<0;1,0>:d                   
(f1.0)  mov (1|M0)               r31.3<1>:d    r9.7<0;1,0>:d                   
        cmp (1|M0)    (eq)f1.0   null<1>:d     r9.2<0;1,0>:d     0:w              
        add (1|M0)               r3.1<1>:d     r9.2<0;1,0>:d     -1:w              
(W)     and (1|M0)               f0.0<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
(f0.0.any16h) goto (16|M0)                   L5504                  L5504                
L5456:
(W)     mov (2|M0)               r9.6<1>:ud    r31.2<1;1,0>:ud                  {I@5}
        mov (1|M0)               r9.2<1>:d     r3.1<0;1,0>:d                    {I@4}
        goto.b (16|M0)                       L5504                  L4680                
L5504:
        join (16|M0)                         L5520                                
L5520:
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        ret (16|M0)                          r9.0                             {A@1}
L5568:
(W)     shr (16|M0)              r5.0<1>:ud    r23.0<1;1,0>:ud   0x17:uw             
(W)     and (16|M0)              r76.0<1>:w    r5.0<2;1,0>:w     255:w               {I@1}
(W)     add (16|M0)              r9.0<1>:d     r76.0<1;1,0>:uw   -191:w               {I@1}
(W)     cmp (16|M0)   (lt)f1.0   null<1>:d     r9.0<1;1,0>:ud    0xFFFFFF82:ud              {I@1}
(W)     shr (16|M0)              r7.0<1>:ud    r21.0<1;1,0>:ud   0x17:uw             
(W)     mov (1|M0)               r31.14<1>:uw  f1.0<0;1,0>:uw                   {Compacted}
(W)     and (16|M0)              r75.0<1>:w    r7.0<2;1,0>:w     255:w               {I@2}
(W)     mov (1|M0)               f0.1<1>:uw    r31.14<0;1,0>:uw                 {I@2}
(W)     add (16|M0)              r11.0<1>:d    r75.0<1;1,0>:uw   -191:w               {I@2}
(W)     mov (16|M0)              r29.0<1>:d    r76.0<1;1,0>:uw                 
(W&~f0.1) cmp (16|M0) (lt)f0.1   null<1>:d     r11.0<1;1,0>:ud   0xFFFFFF81:ud              {I@2}
(W)     mov (16|M0)              r40.0<1>:d    r76.0<1;1,0>:uw                 
(W)     mov (1|M0)               r31.14<1>:uw  f0.1<0;1,0>:uw                   {Compacted}
(W)     mov (16|M0)              r38.0<1>:d    r75.0<1;1,0>:uw                 
(W)     mov (1|M0)               f0.0<1>:uw    r31.14<0;1,0>:uw                 {I@2}
(W)     mov (16|M0)              r36.0<1>:d    r75.0<1;1,0>:uw                 
(~f0.0.any16h) goto (16|M0)                  L8376                  L8376                
L5824:
(W)     add (16|M0)              r5.0<1>:d     r76.0<1;1,0>:uw   -255:w              
(W)     cmp (16|M0)   (lt)f0.0   null<1>:d     r5.0<1;1,0>:ud    0xFFFFFF02:ud              {I@1}
(W)     add (16|M0)              r7.0<1>:d     r75.0<1;1,0>:uw   -255:w              
(W&~f0.0) cmp (16|M0) (lt)f0.0   null<1>:d     r7.0<1;1,0>:ud    0xFFFFFF02:ud              {I@1}
(W)     mov (16|M0)              r42.0<1>:f    (abs)r23.0<1;1,0>:f              {Compacted}
(f0.0.any16h) goto (16|M0)                   L5984                  L5984                
L5912:
(W)     mov (16|M0)              r5.0<1>:f     (abs)r21.0<1;1,0>:f              {Compacted}
(W)     add (16|M0)              r42.0<1>:d    r42.0<1;1,0>:d    -r5.0<1;1,0>:d   {Compacted,A@1}
(W)     mov (4|M0)               r63.0<1>:d    0:w                              
(W)     mov (16|M0)              r19.0<1>:f    r23.0<1;1,0>:f                   {Compacted}
(W)     mov (16|M0)              r34.0<1>:f    r21.0<1;1,0>:f                   {Compacted}
(W)     asr (16|M0)              r42.0<1>:d    r42.0<1;1,0>:d    23:w               {Compacted,I@2}
        goto (16|M0)                         L5984                  L7248                
L5984:
        join (16|M0)                         L7248                                
L6000:
(W)     mov (16|M0)              r44.0<1>:f    (abs)r21.0<1;1,0>:f              {Compacted}
(W)     cmp (16|M0)   (gt)f1.0   null<1>:d     r42.0<1;1,0>:ud   0x7F800000:ud              {I@3}
(W)     cmp (16|M0)   (lt)f1.1   null<1>:d     r44.0<1;1,0>:ud   0x7F800001:ud              {F@1}
(W)     and (16|M0)              r48.0<1>:ud   r23.0<1;1,0>:ud   0x7F800000:ud             
(W)     mov (1|M0)               r1.3<1>:uw    f1.0<0;1,0>:uw                  
(W)     and (16|M0)              r56.0<1>:ud   r21.0<1;1,0>:ud   0x7F800000:ud             
(W)     mov (1|M0)               r2.6<1>:uw    f1.1<0;1,0>:uw                  
(W)     or (1|M0)                f0.1<1>:uw    f1.1<0;1,0>:uw    r1.3<0;1,0>:uw   {I@3}
(W)     cmp (16|M0)   (ne)f1.1   null<1>:d     r48.0<1;1,0>:d    2139095040:d              
(W)     or (1|M0)                r3.2<1>:uw    f1.0<0;1,0>:uw    ~r2.6<0;1,0>:uw  {I@3}
(W)     cmp (16|M0)   (ne)f1.0   null<1>:d     r56.0<1;1,0>:d    2139095040:d              
(W)     or (1|M0)                r3.3<1>:uw    f1.1<0;1,0>:uw    r3.2<0;1,0>:uw   {I@2}
(W)     or (1|M0)                r3.2<1>:uw    ~f1.1<0;1,0>:uw   r3.2<0;1,0>:uw  
(W)     mov (1|M0)               r2.6<1>:hf    -qnan(0x1FF):hf                             
(W)     or (1|M0)                r1.3<1>:uw    f1.0<0;1,0>:uw    r3.2<0;1,0>:uw   {I@1}
(W)     or (1|M0)                r3.2<1>:uw    ~f1.0<0;1,0>:uw   r3.2<0;1,0>:uw  
(W)     mov (1|M0)               r9.0<1>:f     -0.0:f                               {Compacted}
(W)     mov (1|M0)               f1.0<1>:uw    r3.2<0;1,0>:uw                   {I@1}
(W&f0.1) sel (16|M0)             acc0.0<1>:f   r23.0<1;1,0>:f    r21.0<1;1,0>:f  
(W)     mov (1|M0)               f0.1<1>:uw    r3.3<0;1,0>:uw                   {F@1}
(W&f1.0) sel (16|M0)             r12.0<2>:b    r2.6<0;1,0>:w     0:w              
(W)     cmp (16|M0)   (eq)f1.0   null<1>:f     r21.0<1;1,0>:f    0.0:f               {A@1}
(W)     bfn.0x6A (16|M0)         r17.0<1>:ud   r23.0<1;0>:ud     r21.0<1;0>:ud     r9.0<0>:ud       // s0^s1&s2
(W)     bfn.0x6A (16|M0)         r10.0<1>:ud   r21.0<1;0>:ud     r23.0<1;0>:ud     r9.0<0>:ud       // s0^s1&s2
(W)     and (1|M0)               r4.4<1>:uw    f1.0<0;1,0>:uw    ~r3.2<0;1,0>:uw 
(W)     mov (1|M0)               f1.1<1>:uw    r1.3<0;1,0>:uw                  
(W)     add (16|M0)              r17.0<1>:f    r17.0<1;1,0>:f    -r10.0<1;1,0>:f  {Compacted,A@3}
(W&f0.1) add (16|M0)             r17.0<1>:f    acc0.0<1;1,0>:f   r21.0<1;1,0>:f  
(W)     mov (1|M0)               f0.1<1>:uw    r4.4<0;1,0>:uw                   {A@1}
(W)     and (16|M0)              r7.0<1>:ud    r21.0<1;1,0>:ud   0x80000000:ud             
(W)     and (16|M0)              r46.0<1>:ud   r23.0<1;1,0>:ud   0x80000000:ud             
(W)     mov (16|M0)              r63.0<1>:b    r12.0<2;1,0>:b                  
(W&~f1.1) mul (16|M0)            r17.0<1>:f    r7.0<1;1,0>:f     r23.0<1;1,0>:f   {I@3}
(~f0.1) goto (16|M0)                         L6640                  L6640                
L6520:
(W)     cmp (16|M0)   (eq)f0.1   null<1>:f     r23.0<1;1,0>:f    0.0:f               {I@1}
(W)     mov (1|M0)               r1.2<1>:ud    0x7F800000:ud                             
(W)     mov (1|M0)               r2.12<2>:b    -1:w                              
(W&f0.1) mov (16|M0)             r46.0<1>:ud   0:w                              
(W)     bfn.0x96 (16|M0)         r46.0<1>:ud   r1.2<0;0>:ud      r46.0<1;0>:ud     r21.0<1>:ud      {I@1} // s0^s1^s2
(W&f0.1) mul (16|M0)             r46.0<1>:f    r46.0<1;1,0>:f    r23.0<1;1,0>:f   {I@1}
        mov (16|M0)              r63.0<1>:b    r2.12<0;1,0>:b                  
        mov (16|M0)              r17.0<1>:f    r46.0<1;1,0>:f                   {Compacted,F@1}
L6640:
        join (16|M0)                         L7248                                
L6656:
(W)     cmp (16|M0)   (eq)f0.1   null<1>:f     r23.0<1;1,0>:f    0.0:f              
(W&f0.1) cmp (16|M0)  (eq)f0.1   null<1>:w     r63.0<1;1,0>:ub   0x0:uw              {A@1}
(W&~f0.1) sel (16|M0)            r5.0<2>:b     r63.0<1;1,0>:b    -1:w              
(W)     mov (16|M0)              r63.0<1>:b    r5.0<2;1,0>:b                    {I@1}
(W)     cmp (16|M0)   (ne)f1.1   null<1>:w     r63.0<1;1,0>:ub   0x0:uw              {I@1}
(W&f0.1) mul (16|M0)             r17.0<1>:f    r23.0<1;1,0>:f    r21.0<1;1,0>:f  
(f1.1.all16h) goto (16|M0)                   L7248                  L8376                
L6768:
(W)     cmp (16|M0)   (eq)f0.1   null<1>:w     r63.0<1;1,0>:ub   0x0:uw              {F@1}
(W)     mov (1|M0)               r1.3<1>:uw    f0.0<0;1,0>:uw                  
(W)     cmp (16|M0)   (eq)f1.0   null<1>:d     r48.0<1;1,0>:d    0:w              
(W)     and (1|M0)               f0.0<1>:uw    f0.1<0;1,0>:uw    r1.3<0;1,0>:uw   {I@2}
(W)     mov (16|M0)              r32.0<1>:d    0:w                              
(W)     mov (1|M0)               r2.6<1>:uw    f1.0<0;1,0>:uw                   {Compacted}
(W)     mov (16|M0)              r19.0<1>:f    r23.0<1;1,0>:f                   {Compacted}
(W)     and (1|M0)               f1.1<1>:uw    f0.0<0;1,0>:uw    r2.6<0;1,0>:uw   {I@1}
(W)     mov (16|M0)              r64.0<1>:f    r32.0<1;1,0>:f                   {Compacted}
(~f1.1) goto (16|M0)                         L7000                  L7000                
L6904:
        mul (16|M0)              r19.0<1>:f    r23.0<1;1,0>:f    0x4F800000:f               {Compacted}
(W)     shr (16|M0)              r5.0<1>:ud    r19.0<1;1,0>:ud   0x17:uw              {F@1}
(W)     and (16|M0)              r7.0<1>:w     r5.0<2;1,0>:w     255:w               {I@1}
        add (16|M0)              r40.0<1>:d    r7.0<1;1,0>:uw    -32:w               {I@1}
(W)     mov (16|M0)              r64.0<1>:d    0:w                              
(W)     mov (16|M0)              r29.0<1>:f    r40.0<1;1,0>:f                   {Compacted,I@2}
        mov (16|M0)              r64.0<1>:d    -32:w                              
L7000:
        join (16|M0)                         L7248                                
L7016:
(W)     cmp (16|M0)   (eq)f0.1   null<1>:d     r56.0<1;1,0>:d    0:w              
(W)     mov (16|M0)              r34.0<1>:f    r21.0<1;1,0>:f                   {Compacted}
(W)     mov (1|M0)               r1.3<1>:uw    f0.1<0;1,0>:uw                  
(W)     and (1|M0)               f1.0<1>:uw    f0.0<0;1,0>:uw    r1.3<0;1,0>:uw   {I@1}
(~f1.0) goto (16|M0)                         L7192                  L7192                
L7088:
        mul (16|M0)              r34.0<1>:f    r21.0<1;1,0>:f    0x4F800000:f               {Compacted}
(W)     shr (16|M0)              r5.0<1>:ud    r34.0<1;1,0>:ud   0x17:uw              {F@1}
(W)     and (16|M0)              r7.0<1>:w     r5.0<2;1,0>:w     255:w               {I@1}
        add (16|M0)              r36.0<1>:d    r7.0<1;1,0>:uw    -32:w               {I@1}
(W)     mov (16|M0)              r32.0<1>:d    0:w                              
(W)     mov (16|M0)              r44.0<1>:f    (abs)r34.0<1;1,0>:f              {Compacted}
(W)     mov (16|M0)              r38.0<1>:f    r36.0<1;1,0>:f                   {Compacted,I@2}
        mov (16|M0)              r32.0<1>:d    32:w                              
L7192:
        join (16|M0)                         L7248                                
L7208:
(W)     mov (16|M0)              r42.0<1>:f    (abs)r19.0<1;1,0>:f              {Compacted}
(W)     add (16|M0)              r42.0<1>:d    r42.0<1;1,0>:d    -r44.0<1;1,0>:d  {Compacted,F@1}
(W)     asr (16|M0)              r42.0<1>:d    r42.0<1;1,0>:d    23:w               {Compacted,I@1}
(W)     add3 (16|M0)             r32.0<1>:d    r32.0<1;0>:d      r64.0<1;0>:d      r42.0<1>:d       {I@1}
L7248:
        join (16|M0)                         L8376                                
L7264:
(W)     mov (1|M0)               r1.2<1>:f     1.0:f                               {Compacted}
(W)     mov (1|M0)               r5.0<1>:f     0x807FFFFF:f                              
(W&~f0.0) mov (16|M0)            r32.0<1>:f    r42.0<1;1,0>:f                   {I@2}
(W)     bfn.0xEA (16|M0)         r34.0<1>:ud   r1.2<0;0>:ud      r34.0<1;0>:ud     r5.0<0>:ud       {A@2} // s0|s1&s2
(W)     add (16|M0)              r54.0<1>:d    r32.0<1;1,0>:d    126:w               {Compacted,F@1}
(W)     add (16|M0)              r6.0<1>:d     -r32.0<1;1,0>:d   -152:w               {Compacted}
        sync.nop                             null                             {Compacted,I@3}
(W)     math.inv (16|M0)         r8.0<1>:f     r34.0<1;1,0>:f                   {$9}
(W)     cmp (16|M0)   (eq)f0.0   null<1>:w     r63.0<1;1,0>:ub   0x0:uw             
(W)     and (16|M0)              r6.0<1>:d     r6.0<1;1,0>:d     r54.0<1;1,0>:d   {Compacted,I@2}
(W)     mov (1|M0)               r2.3<1>:f     1.0:f                               {Compacted}
(W)     bfn.0xEA (16|M0)         r19.0<1>:ud   r1.2<0;0>:ud      r19.0<1;0>:ud     r5.0<0>:ud       // s0|s1&s2
(W)     asr (16|M0)              r6.0<1>:d     r6.0<1;1,0>:d     31:w               {Compacted,I@2}
        sync.nop                             null                             {Compacted,$9.dst}
(W)     mad (16|M0)              r52.0<1>:f    r2.3<0;0>:f       r8.0<1;0>:f       -r34.0<1>:f      {F@1}
(W)     mul (16|M0)              acc0.0<1>:f   r8.0<1;1,0>:f     r19.0<1;1,0>:f   {Compacted,I@2}
(W&f0.0) sel (16|M0)             r74.0<1>:w    r6.0<4;1,0>:ub    0:w               {I@1}
(W)     mad (16|M0)              r52.0<1>:f    r8.0<1;0>:f       r8.0<1;0>:f       r52.0<1>:f       {Compacted,F@2}
(W)     mad (16|M0)              r50.0<1>:f    r19.0<1;0>:f      acc0.0<1;0>:f     -r34.0<1>:f     
(W)     cmp (16|M0)   (ne)f1.1   null<1>:w     r74.0<2;1,0>:ub   0x0:uw              {I@1}
(W)     mad (16|M0)              r50.0<1>:f    acc0.0<1;0>:f     r52.0<1;0>:f      r50.0<1>:f       {F@1}
(W)     add (16|M0)              r29.0<1>:d    r29.0<1;1,0>:d    -r38.0<1;1,0>:d  {Compacted}
(W)     mad (16|M0)              r19.0<1>:f    r19.0<1;0>:f      r50.0<1;0>:f      -r34.0<1>:f      {Compacted,F@1}
(~f1.1.any16h) goto (16|M0)                  L8120                  L8120                
L7552:
(W)     mov (16|M0)              r58.0<1>:ud   r19.0<1;1,0>:ud                  {F@1}
(W)     mov (16|M0)              r68.0<1>:f    r52.0<1;1,0>:f                   {Compacted}
(W)     mov (16|M0)              r66.0<1>:f    r50.0<1;1,0>:f                   {Compacted}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r31.2         L8584                                 {A@1}
L7632:
(W)     add (16|M0)              r32.0<1>:d    r32.0<1;1,0>:d    125:w               {Compacted}
(W)     cmp (16|M0)   (lt)f0.1   null<1>:d     r32.0<1;1,0>:d    -2:w               {I@1}
(W)     cmp (16|M0)   (eq)f0.0   null<1>:f     r19.0<1;1,0>:f    0.0:f               {Compacted}
(W)     mov (1|M0)               r1.3<1>:uw    f0.1<0;1,0>:uw                  
(W)     or (1|M0)                f0.1<1>:uw    f0.0<0;1,0>:uw    r1.3<0;1,0>:uw   {I@1}
(f0.1.any16h) goto (16|M0)                   L7760                  L7760                
L7712:
(W)     mov (1|M0)               r1.3<1>:hf    0x1:hf                              {I@2}
(W&f0.0) sel (16|M0)             r61.0<1>:d    r1.3<0;1,0>:w     0:w               {F@1}
        goto (16|M0)                         L7760                  L7880                
L7760:
        join (16|M0)                         L7880                                
L7776:
(W)     mov (1|M0)               r1.3<1>:hf    0x1:hf                              {I@3}
(W)     and (16|M0)              r5.0<1>:d     r58.0<1;1,0>:d    -2139095041:d              
(W)     mov (1|M0)               r7.0<1>:f     0x800000:f                               {Compacted}
(W)     shl (16|M0)              r54.0<1>:d    r54.0<1;1,0>:d    23:w               {Compacted}
(W&f0.0) sel (16|M0)             r61.0<1>:d    r1.3<0;1,0>:w     0:w               {F@2}
(W)     add (16|M0)              r54.0<1>:d    r54.0<1;1,0>:d    1065353216:d               {I@2}
(W)     bfn.0xFE (16|M0)         r5.0<1>:ud    r5.0<1;0>:ud      r61.0<1;0>:ud     r7.0<0>:ud       {A@1} // s0|s1|s2
(W)     mul (16|M0)              r54.0<1>:f    r54.0<1;1,0>:f    r5.0<1;1,0>:f    {Compacted,A@1}
L7880:
        join (16|M0)                         L8120                                
L7896:
(W)     and (16|M0)   (eq)f0.0   null<1>:ud    r58.0<1;1,0>:ud   0x400000:ud             
(W)     shl (16|M0)              r5.0<1>:d     r58.0<1;1,0>:d    1:w               {Compacted,F@1}
(W)     mov (1|M0)               r1.2<1>:f     0x800000:f                               {Compacted}
(W)     mov (1|M0)               r7.0<1>:f     -0.0:f                               {Compacted}
(W)     mov (1|M0)               r2.3<1>:f     1.469368e-38:f                               {Compacted}
(W)     and (16|M0)              r5.0<1>:d     r5.0<1;1,0>:d     8388606:d               {I@1}
(W)     bfn.0xEA (16|M0)         r8.0<1>:ud    r1.2<0;0>:ud      r58.0<1;0>:ud     r7.0<0>:ud       {A@2} // s0|s1&s2
(W&f0.0) sel (16|M0)             r10.0<1>:d    r2.3<0;1,0>:d     12582912:d               {F@1}
(W)     mov (1|M0)               r3.1<1>:f     0.25:f                               {Compacted}
(W)     bfn.0xFE (16|M0)         r61.0<1>:ud   r61.0<1;0>:ud     r8.0<1;0>:ud      r5.0<1>:ud       {I@2} // s0|s1|s2
(W)     bfn.0xEA (16|M0)         r10.0<1>:ud   r10.0<1;0>:ud     r58.0<1;0>:ud     r7.0<0>:ud       {I@2} // s0|s1&s2
(W)     mad (16|M0)              r61.0<1>:f    r10.0<1;0>:f      r61.0<1;0>:f      r3.1<0>:f        {Compacted,A@1}
(W)     add (16|M0)              r61.0<1>:f    r61.0<1;1,0>:f    -r8.0<1;1,0>:f   {Compacted,F@1}
(W)     mul (16|M0)              r8.0<1>:f     r8.0<1;1,0>:f     r8.0<1;1,0>:f    {Compacted}
(W)     and (16|M0)   (ne)f1.0   null<1>:w     r74.0<2;1,0>:ub   1:w              
(W)     bfn.0xAE (16|M0)         r61.0<1>:ud   r61.0<1;0>:ud     r8.0<1;0>:ud      0x1:uw              {A@1} // s0|s1&~s2
(W&~f0.1) mov (16|M0)            r54.0<1>:f    r61.0<1;1,0>:f                   {I@1}
(W&f1.0) mov (16|M0)             r17.0<1>:f    r54.0<1;1,0>:f                   {F@1}
L8120:
        join (16|M0)                         L8376                                
L8136:
(W)     add (16|M0)              r5.0<1>:d     r29.0<1;1,0>:d    -253:w               {Compacted}
(W)     cmp (16|M0)   (lt)f1.1   null<1>:d     r5.0<1;1,0>:ud    0xFFFFFE85:ud              {I@1}
(W)     mov (1|M0)               r1.3<1>:hf    -qnan(0x1FF):hf                             
(W)     asr (16|M0)              r7.0<1>:d     r29.0<1;1,0>:d    11:w               {Compacted}
(W&f1.1.any16h) sel (1|M0)       r2.6<1>:w     r1.3<0;1,0>:w     0:w               {F@1}
(W)     add (16|M0)              r9.0<1>:d     r7.0<1;1,0>:d     248:w               {Compacted,I@2}
(W)     mov (1|M0)               f0.1<1>:uw    r2.6<0;1,0>:uw                   {I@2}
(W)     mov (16|M0)              r11.0<1>:f    r29.0<1;1,0>:f                   {Compacted}
(W&f1.1) xor (16|M0)             r11.0<1>:d    r9.0<1;1,0>:d     r7.0<1;1,0>:d    {A@1}
(W&~f0.1) mov (16|M0)            r11.0<1>:f    r29.0<1;1,0>:f                   {I@1}
(W)     asr (16|M0)              r13.0<1>:d    r11.0<1;1,0>:d    1:w               {Compacted,F@1}
(W)     mov (16|M0)              r5.0<1>:uw    r63.0<1;1,0>:ub                 
(W)     add (16|M0)              r11.0<1>:d    r11.0<1;1,0>:d    -r13.0<1;1,0>:d  {Compacted,I@2}
(W)     mad (16|M0)              r19.0<1>:f    r50.0<1;0>:f      r52.0<1;0>:f      r19.0<1>:f       {Compacted}
(W)     or (16|M0)    (eq)f0.0   null<1>:w     r74.0<2;1,0>:ub   r5.0<1;1,0>:uw   {I@2}
(W)     shl (16|M0)              r13.0<1>:d    r13.0<1;1,0>:d    23:w               {Compacted}
(W)     shl (16|M0)              r11.0<1>:d    r11.0<1;1,0>:d    23:w               {Compacted,I@3}
(W)     add (16|M0)              r13.0<1>:d    r13.0<1;1,0>:d    r19.0<1;1,0>:d   {Compacted,A@1}
(W)     add (16|M0)              r11.0<1>:d    r11.0<1;1,0>:d    1065353216:d               {I@2}
(W&f0.0) mul (16|M0)             r17.0<1>:f    r13.0<1;1,0>:f    r11.0<1;1,0>:f   {A@1}
L8376:
        join (16|M0)                         L8392                                
L8392:
(W)     math.inv (16|M0)         r5.0<1>:f     r21.0<1;1,0>:f                   {$10}
(W)     mov (1|M0)               r1.2<1>:ud    0x3F800000:ud                             
(W)     mul (16|M0)              acc0.0<1>:f   r5.0<1;1,0>:f     r23.0<1;1,0>:f   {Compacted,$10.dst}
(W)     mad (16|M0)              acc2.0<1>:f   r1.2<0;0>:f       r5.0<1;0>:f       -r21.0<1>:f      {I@1}
(W)     mad (16|M0)              r11.0<1>:f    r23.0<1;0>:f      acc0.0<1;0>:f     -r21.0<1>:f     
(W)     mad (16|M0)              acc2.0<1>:f   r5.0<1;0>:f       acc2.0<1;0>:f     r5.0<1>:f        {Compacted}
(W)     mov (1|M0)               f1.1<1>:uw    r31.14<0;1,0>:uw                
(W)     mad (16|M0)              acc0.0<1>:f   acc0.0<1;0>:f     acc2.0<1;0>:f     r11.0<1>:f       {F@2}
(W)     mad (16|M0)              r23.0<1>:f    r23.0<1;0>:f      acc0.0<1;0>:f     -r21.0<1>:f     
(W&~f1.1) mad (16|M0)            r17.0<1>:f    acc0.0<1;0>:f     acc2.0<1;0>:f     r23.0<1>:f       {F@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        ret (16|M0)                          r31.4                            {A@1}
L8584:
(W)     mov (1|M0)               r1.2<1>:d     cr0.0<0;1,0>:ud                  {A@1}
(W)     and (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   -1265:w               {A@1}
(W)     or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   1264:w               {A@1}
(W)     mad (16|M0)              r58.0<1>:f    r66.0<1;0>:f      r68.0<1;0>:f      r58.0<1>:f       {Compacted,A@1}
(W)     mov (1|M0)               cr0.0<1>:ud   r1.2<0;1,0>:d                    {A@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        ret (16|M0)                          r31.2                            {A@1}
L8704:
        shr (1|M0)               r31.6<1>:ud   r14.5<0;1,0>:ud   0x17:uw             
        shr (1|M0)               r14.1<1>:ud   r14.4<0;1,0>:ud   0x17:uw             
        and (1|M0)               r31.6<1>:ud   r31.6<0;1,0>:ud   0xFF:uw              {I@2}
        and (1|M0)               r14.1<1>:ud   r14.1<0;1,0>:ud   0xFF:uw              {I@2}
        add (1|M0)               r1.3<1>:ud    r31.6<0;1,0>:ud   0xFFFFFF41:ud              {I@2}
        add (1|M0)               r1.2<1>:ud    r14.1<0;1,0>:ud   0xFFFFFF41:ud              {I@2}
        cmp (1|M0)    (lt)f1.1   null<1>:ud    r1.3<0;1,0>:ud    0xFFFFFF81:ud              {A@2}
(W)     mov (1|M0)               r2.6<1>:hf    -qnan(0x1FF):hf                             
(~f1.1) cmp (1|M0)    (lt)f1.1   null<1>:ud    r1.2<0;1,0>:ud    0xFFFFFF82:ud              {I@2}
(f1.1)  sel (1|M0)               r14.24<2>:b   r2.6<0;1,0>:w     0:w               {F@1}
        cmp (1|M0)    (ne)f1.1   null<1>:uw    r14.24<0;1,0>:ub  0x0:uw              {I@1}
(W)     and (1|M0)               f1.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(~f1.1.any16h) goto (16|M0)                  L12424                  L12424                
L8912:
        add (1|M0)               r1.3<1>:ud    r31.6<0;1,0>:ud   0xFFFFFF01:ud             
        add (1|M0)               r1.2<1>:ud    r14.1<0;1,0>:ud   0xFFFFFF01:ud             
        cmp (1|M0)    (lt)f1.0   null<1>:ud    r1.3<0;1,0>:ud    0xFFFFFF02:ud              {I@2}
(W)     mov (1|M0)               r2.6<1>:hf    -qnan(0x1FF):hf                             
        mov (1|M0)               r14.7<1>:f    (abs)r14.4<0;1,0>:f             
(~f1.0) cmp (1|M0)    (lt)f1.0   null<1>:ud    r1.2<0;1,0>:ud    0xFFFFFF02:ud              {I@2}
(f1.0)  sel (1|M0)               r31.20<2>:b   r2.6<0;1,0>:w     0:w               {F@2}
        cmp (1|M0)    (ne)f0.0   null<1>:uw    r31.20<0;1,0>:ub  0x0:uw              {I@1}
(W)     and (1|M0)               f1.0<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
(f1.0.any16h) goto (16|M0)                   L9168                  L9168                
L9072:
        mov (1|M0)               r1.2<1>:f     (abs)r14.5<0;1,0>:f             
        mov (1|M0)               r16.24<2>:b   0:w                              
        add (1|M0)               r14.7<1>:d    r14.7<0;1,0>:d    -r1.2<0;1,0>:d   {A@1}
        mov (2|M0)               r16.4<1>:f    r14.4<1;1,0>:f                  
        asr (1|M0)               r14.7<1>:d    r14.7<0;1,0>:d    23:w               {I@1}
        goto (16|M0)                         L9168                  L10888                
L9168:
        join (16|M0)                         L10888                                
L9184:
        cmp (1|M0)    (gt)f1.1   null<1>:ud    r14.7<0;1,0>:ud   0x7F800000:ud              {I@3}
(W)     mov (1|M0)               r1.3<1>:hf    0xFF:hf                             
        mov (1|M0)               r16.7<1>:f    (abs)r14.5<0;1,0>:f             
(W)     mov (1|M0)               r2.7<1>:hf    -qnan(0x1FF):hf                             
(f1.1)  sel (1|M0)               r2.6<1>:w     r1.3<0;1,0>:w     0:w               {F@3}
        and (1|M0)               r6.0<1>:ud    r14.4<0;1,0>:ud   0x7F800000:ud             
        cmp (1|M0)    (eq)f0.1   null<1>:w     r2.12<0;1,0>:b    0:w               {I@2}
(W)     mov (1|M0)               r3.2<1>:uw    r2.12<0;1,0>:ub                 
        and (1|M0)               r31.7<1>:ud   r14.5<0;1,0>:ud   0x7F800000:ud             
        add (1|M0)               r14.0<1>:f    r14.4<0;1,0>:f    r14.5<0;1,0>:f  
(f0.1)  cmp (1|M0)    (gt)f0.1   null<1>:ud    r16.7<0;1,0>:ud   0x7F800000:ud              {F@3}
(W)     mov (1|M0)               r5.0<1>:f     -0.0:f                               {Compacted}
        and (1|M0)               r4.2<1>:ud    r14.5<0;1,0>:ud   0x80000000:ud             
        bfn.0x6A (1|M0)          r1.2<1>:ud    r14.4<0;0>:ud     r14.5<0;0>:ud     r5.0<0>:ud       {F@1} // s0^s1&s2
(f0.1)  sel (1|M0)               r2.16<2>:b    r2.7<0;1,0>:w     0:w              
        bfn.0x6A (1|M0)          r1.3<1>:ud    r14.5<0;0>:ud     r14.4<0;0>:ud     r5.0<0>:ud       // s0^s1&s2
        and (1|M0)    (ne)f1.0   null<1>:w     r2.16<0;1,0>:ub   1:w               {I@2}
        or (1|M0)     (eq)f0.0   r2.16<2>:ub   r2.16<0;1,0>:ub   r3.2<0;1,0>:uw  
        and (1|M0)               r6.2<1>:ud    r14.4<0;1,0>:ud   0x80000000:ud             
(f1.0)  add (1|M0)               r14.0<1>:f    r14.5<0;1,0>:f    r14.5<0;1,0>:f  
(f0.0)  cmp (1|M0)    (eq)f0.0   null<1>:d     r6.0<0;1,0>:d     2139095040:d              
(W)     mov (1|M0)               r4.6<1>:uw    r2.16<0;1,0>:ub                  {I@3}
(f0.0)  sel (1|M0)               r1.6<2>:b     r2.7<0;1,0>:w     0:w              
        and (1|M0)    (ne)f0.1   null<1>:w     r1.6<0;1,0>:ub    1:w               {I@1}
        or (1|M0)     (eq)f1.1   r1.6<2>:ub    r1.6<0;1,0>:ub    r4.6<0;1,0>:uw  
(f0.1)  add (1|M0)               r14.0<1>:f    r1.2<0;1,0>:f     -r1.3<0;1,0>:f  
(f1.1)  cmp (1|M0)    (eq)f1.1   null<1>:d     r31.7<0;1,0>:d    2139095040:d              
(W)     mov (1|M0)               r3.2<1>:uw    r1.6<0;1,0>:ub                   {I@2}
(f1.1)  sel (1|M0)               r6.4<2>:b     r2.7<0;1,0>:w     0:w              
        and (1|M0)    (ne)f0.0   null<1>:w     r6.4<0;1,0>:ub    1:w               {I@1}
        or (1|M0)     (eq)f1.0   r6.4<2>:ub    r6.4<0;1,0>:ub    r3.2<0;1,0>:uw   {F@2}
(f0.0)  mul (1|M0)               r14.0<1>:f    r4.2<0;1,0>:f     r14.4<0;1,0>:f  
(f1.0)  cmp (1|M0)    (eq)f1.0   null<1>:f     r14.5<0;1,0>:f    0.0:f               {I@1}
(f1.0)  sel (1|M0)               r3.2<2>:b     r2.7<0;1,0>:w     0:w              
        cmp (1|M0)    (ne)f1.1   null<1>:uw    r3.2<0;1,0>:ub    0x0:uw              {I@1}
(W)     and (1|M0)               f0.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw              {F@3}
(f0.1.any16h) goto (16|M0)                   L9800                  L9800                
L9768:
        mov (1|M0)               r3.0<2>:b     r6.4<0;1,0>:b                   
        goto (16|M0)                         L9800                  L9984                
L9800:
        join (16|M0)                         L9984                                
L9816:
(W)     mov (1|M0)               r5.0<1>:f     inf:f                               {Compacted}
        cmp (1|M0)    (eq)f1.0   null<1>:f     r14.4<0;1,0>:f    0.0:f              
        bfn.0x96 (1|M0)          r6.2<1>:ud    r6.2<0;0>:ud      r14.5<0;0>:ud     r5.0<0>:ud       {F@2} // s0^s1^s2
        xor (1|M0)               r1.2<1>:ud    r14.5<0;1,0>:ud   0x7F800000:ud             
(W)     mov (1|M0)               r2.6<1>:uw    r6.4<0;1,0>:ub                  
(~f1.0) mov (1|M0)               r1.2<1>:f     r6.2<0;1,0>:f                    {A@2}
        or (1|M0)                r6.4<2>:ub    r3.2<0;1,0>:ub    r2.6<0;1,0>:uw   {I@1}
(f1.0)  mul (1|M0)               r6.2<1>:f     r1.2<0;1,0>:f     r14.4<0;1,0>:f   {F@1}
        and (1|M0)    (ne)f1.0   null<1>:w     r3.2<0;1,0>:ub    1:w               {F@1}
        mov (1|M0)               r3.0<2>:b     r6.4<0;1,0>:b                    {I@2}
(f1.0)  mov (1|M0)               r14.0<1>:f    r6.2<0;1,0>:f                   
L9984:
        join (16|M0)                         L10888                                
L10000:
        cmp (1|M0)    (eq)f0.1   null<1>:w     r6.4<0;1,0>:b     0:w              
(W)     mov (1|M0)               r1.3<1>:hf    -qnan(0x1FF):hf                             
(W)     mov (1|M0)               r2.6<1>:uw    r3.0<0;1,0>:ub                   {I@3}
(f0.1)  cmp (1|M0)    (eq)f0.1   null<1>:f     r14.4<0;1,0>:f    0.0:f               {I@2}
(f0.1)  sel (1|M0)               r16.24<2>:b   r1.3<0;1,0>:w     0:w               {F@2}
        and (1|M0)    (ne)f0.1   null<1>:w     r16.24<0;1,0>:ub  1:w               {A@1}
        or (1|M0)     (ne)f0.0   r16.24<2>:ub  r16.24<0;1,0>:ub  r2.6<0;1,0>:uw  
(f0.1)  mul (1|M0)               r14.0<1>:f    r14.4<0;1,0>:f    r14.5<0;1,0>:f  
(W)     and (1|M0)               f0.0<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
(f0.0.any16h) goto (16|M0)                   L10888                  L12424                
L10160:
        cmp (1|M0)    (eq)f1.1   null<1>:uw    r16.24<0;1,0>:ub  0x0:uw              {I@3}
        cmp (1|M0)    (eq)f1.0   null<1>:d     r6.0<0;1,0>:d     0:w              
(~f1.1) mov (1|M0)               r31.20<2>:b   0:w                              
(f1.0)  sel (1|M0)               r3.1<1>:d     r31.20<0;1,0>:b   0:w               {I@1}
        cmp (1|M0)    (ne)f0.1   null<1>:d     r3.1<0;1,0>:d     0:w               {A@1}
(W)     and (1|M0)               f1.1<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(f1.1.any16h) goto (16|M0)                   L10320                  L10320                
L10272:
        mov (1|M0)               r3.0<1>:d     0:w                              
        mov (1|M0)               r16.4<1>:f    r14.4<0;1,0>:f                  
        goto (16|M0)                         L10320                  L10480                
L10320:
        join (16|M0)                         L10480                                
L10336:
        and (1|M0)    (ne)f0.0   r3.1<1>:d     r3.1<0;1,0>:d     1:w              
        mov (1|M0)               r16.4<1>:f    r14.4<0;1,0>:f                  
(W)     mov (1|M0)               r2.6<1>:hf    -qnan(0x1E0):hf                             
(f0.0)  mul (1|M0)               r16.4<1>:f    r14.4<0;1,0>:f    0x4F800000:f              
(f0.0)  sel (1|M0)               r3.0<1>:d     r2.6<0;1,0>:w     0:w               {F@2}
        shr (1|M0)               r1.2<1>:ud    r16.4<0;1,0>:ud   0x17:uw              {F@1}
        and (1|M0)               r1.2<1>:ud    r1.2<0;1,0>:ud    0xFF:uw              {I@1}
        add (1|M0)               r1.2<1>:ud    r1.2<0;1,0>:ud    0xFFFFFFE0:ud              {I@1}
(f0.0)  mov (1|M0)               r14.1<1>:d    r1.2<0;1,0>:d                    {I@1}
L10480:
        join (16|M0)                         L10888                                
L10496:
        cmp (1|M0)    (eq)f0.0   null<1>:d     r31.7<0;1,0>:d    0:w              
(f0.0)  sel (1|M0)               r3.7<1>:d     r31.20<0;1,0>:b   0:w              
        cmp (1|M0)    (ne)f1.1   null<1>:d     r3.7<0;1,0>:d     0:w               {I@1}
(W)     and (1|M0)               f1.0<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(f1.0.any16h) goto (16|M0)                   L10624                  L10624                
L10576:
        mov (1|M0)               r3.1<1>:d     0:w                              
        mov (1|M0)               r16.5<1>:f    r14.5<0;1,0>:f                  
        goto (16|M0)                         L10624                  L10800                
L10624:
        join (16|M0)                         L10800                                
L10640:
        and (1|M0)    (ne)f1.1   r3.7<1>:d     r3.7<0;1,0>:d     1:w              
        mov (1|M0)               r16.5<1>:f    r14.5<0;1,0>:f                  
(W)     mov (1|M0)               r2.6<1>:hf    0x20:hf                             
(f1.1)  mul (1|M0)               r16.5<1>:f    r14.5<0;1,0>:f    0x4F800000:f              
(f1.1)  sel (1|M0)               r3.1<1>:d     r2.6<0;1,0>:w     0:w               {F@2}
        shr (1|M0)               r1.2<1>:ud    r16.5<0;1,0>:ud   0x17:uw              {F@1}
        mov (1|M0)               r16.7<1>:f    (abs)r16.5<0;1,0>:f             
        and (1|M0)               r1.2<1>:ud    r1.2<0;1,0>:ud    0xFF:uw              {I@1}
        add (1|M0)               r1.2<1>:ud    r1.2<0;1,0>:ud    0xFFFFFFE0:ud              {I@1}
(f1.1)  mov (1|M0)               r31.6<1>:d    r1.2<0;1,0>:d                    {I@1}
L10800:
        join (16|M0)                         L10888                                
L10816:
        mov (1|M0)               r14.7<1>:f    (abs)r16.4<0;1,0>:f             
        add (1|M0)               r3.1<1>:d     r3.1<0;1,0>:d     r3.0<0;1,0>:d    {Compacted}
        add (1|M0)               r14.7<1>:d    r14.7<0;1,0>:d    -r16.7<0;1,0>:d  {F@1}
        asr (1|M0)               r14.7<1>:d    r14.7<0;1,0>:d    23:w               {I@1}
        add (1|M0)               r3.1<1>:d     r3.1<0;1,0>:d     r14.7<0;1,0>:d   {I@1}
L10888:
        join (16|M0)                         L12424                                
L10904:
        cmp (1|M0)    (eq)f1.0   null<1>:uw    r31.20<0;1,0>:ub  0x0:uw             
(W)     mov (1|M0)               r1.2<1>:f     1.0:f                               {Compacted}
(W)     mov (1|M0)               r5.0<1>:f     0x807FFFFF:f                              
        cmp (1|M0)    (eq)f0.1   null<1>:w     r16.24<0;1,0>:b   0:w              
(~f1.0) mov (1|M0)               r14.7<1>:d    r3.1<0;1,0>:d                    {I@4}
        bfn.0xEA (1|M0)          r16.5<1>:ud   r1.2<0;0>:ud      r16.5<0;0>:ud     r5.0<0>:ud       {A@1} // s0|s1&s2
        add (1|M0)               r6.4<1>:d     r14.7<0;1,0>:d    126:w               {I@2}
        add (1|M0)               r6.3<1>:d     -r14.7<0;1,0>:d   -152:w              
        sync.nop                             null                             {Compacted,I@3}
        math.inv (1|M0)          r2.3<1>:f     r16.5<0;1,0>:f                   {$11}
        and (1|M0)               r6.3<1>:d     r6.3<0;1,0>:d     r6.4<0;1,0>:d    {I@1}
        mov (1|M0)               r6.0<1>:f     1.0:f                               {Compacted}
        asr (1|M0)               r6.3<1>:d     r6.3<0;1,0>:d     31:w               {Compacted,I@1}
(~f0.1) mov (1|M0)               r6.3<1>:d     0:w                              
        bfn.0xEA (1|M0)          r16.4<1>:ud   r1.2<0;0>:ud      r16.4<0;0>:ud     r5.0<0>:ud       // s0|s1&s2
        cmp (1|M0)    (ne)f0.0   null<1>:d     r6.3<0;1,0>:d     0:w               {I@2}
        sync.nop                             null                             {Compacted,$11.dst}
        mad (1|M0)               r6.0<1>:f     r6.0<0;0>:f       r2.3<0;0>:f       -r16.5<0>:f      {F@1}
        mul (1|M0)               r2.4<1>:f     r2.3<0;1,0>:f     r16.4<0;1,0>:f   {I@2}
        mad (1|M0)               r6.0<1>:f     r2.3<0;0>:f       r2.3<0;0>:f       r6.0<0>:f        {F@2}
        mad (1|M0)               r6.1<1>:f     r16.4<0;0>:f      r2.4<0;0>:f       -r16.5<0>:f      {F@2}
(W)     and (1|M0)               f0.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
        mad (1|M0)               r6.1<1>:f     r2.4<0;0>:f       r6.0<0;0>:f       r6.1<0>:f        {F@1}
        add (1|M0)               r14.1<1>:d    r14.1<0;1,0>:d    -r31.6<0;1,0>:d 
        mad (1|M0)               r16.4<1>:f    r16.4<0;0>:f      r6.1<0;0>:f       -r16.5<0>:f      {F@1}
(~f0.1.any16h) goto (16|M0)                  L12080                  L12080                
L11280:
        mov (1|M0)               r6.2<1>:f     r16.4<0;1,0>:f                   {F@1}
        mov (2|M0)               r2.0<1>:f     r6.0<1;1,0>:f                   
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r3.0          L12656                                 {A@1}
L11360:
        cmp (1|M0)    (eq)f1.0   null<1>:f     r16.4<0;1,0>:f    0.0:f              
(W)     mov (1|M0)               r1.3<1>:hf    0x1:hf                             
        add (1|M0)               r14.7<1>:d    r14.7<0;1,0>:d    125:w              
(W)     mov (1|M0)               r3.2<1>:hf    0x1:hf                              {I@2}
(f1.0)  sel (1|M0)               r2.6<1>:w     r1.3<0;1,0>:w     0:w               {F@2}
        cmp (1|M0)    (lt)f0.0   null<1>:d     r14.7<0;1,0>:d    -2:w               {I@2}
        cmp (1|M0)    (ne)f0.1   null<1>:w     r2.6<0;1,0>:w     0:w               {I@2}
(W)     mov (1|M0)               r5.0<1>:hf    -qnan(0x1FF):hf                             
(f0.0)  sel (1|M0)               r3.3<1>:uw    r3.2<0;1,0>:uw    0x0:uw              {F@2}
(f0.1)  sel (1|M0)               r4.4<1>:uw    r3.2<0;1,0>:uw    0x0:uw             
        or (1|M0)     (ne)f1.1   null<1>:uw    r3.3<0;1,0>:uw    r4.4<0;1,0>:uw   {I@1}
(f1.1)  sel (1|M0)               r6.20<2>:b    r5.0<0;1,0>:w     0:w               {F@1}
        cmp (1|M0)    (ne)f1.1   null<1>:uw    r6.20<0;1,0>:ub   0x0:uw              {I@1}
(W)     and (1|M0)               f0.0<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(~f0.0.any16h) goto (16|M0)                  L11720                  L11720                
L11600:
(W)     mov (1|M0)               r1.3<1>:hf    0x1:hf                             
        and (1|M0)               r1.2<1>:d     r6.2<0;1,0>:d     -2139095041:d              
(W)     mov (1|M0)               r5.0<1>:f     0x800000:f                               {Compacted}
        shl (1|M0)               r6.4<1>:d     r6.4<0;1,0>:d     23:w              
(f1.0)  sel (1|M0)               r2.3<1>:d     r1.3<0;1,0>:w     0:w               {F@2}
        add (1|M0)               r6.4<1>:d     r6.4<0;1,0>:d     1065353216:d               {I@2}
        bfn.0xFE (1|M0)          r1.2<1>:ud    r1.2<0;0>:ud      r2.3<0;0>:ud      r5.0<0>:ud       {A@1} // s0|s1|s2
        mul (1|M0)               r6.4<1>:f     r6.4<0;1,0>:f     r1.2<0;1,0>:f    {A@1}
L11720:
        join (16|M0)                         L12080                                
L11736:
        and (1|M0)               r1.2<1>:d     r6.2<0;1,0>:d     -2147483648:d               {F@1}
        shl (1|M0)               r6.2<1>:d     r6.2<0;1,0>:d     1:w              
(W)     mov (1|M0)               r1.3<1>:hf    0x1:hf                             
        and (1|M0)               r1.3<1>:d     r6.2<0;1,0>:d     8388606:d               {I@1}
        and (1|M0)    (eq)f1.0   r6.2<1>:d     r6.2<0;1,0>:d     8388608:d              
(W)     mov (1|M0)               r2.5<1>:f     1.469368e-38:f                               {Compacted}
(f0.1)  sel (1|M0)               r2.3<1>:d     r1.3<0;1,0>:w     0:w               {F@2}
(W)     mov (1|M0)               r3.7<1>:f     0x800000:f                               {Compacted}
        or (1|M0)                r2.3<1>:d     r1.2<0;1,0>:d     r2.3<0;1,0>:d    {I@1}
(f1.0)  sel (1|M0)               r3.1<1>:d     r2.5<0;1,0>:d     12582912:d               {F@2}
        mov (1|M0)               r4.2<1>:f     0.25:f                               {Compacted}
        bfn.0xFE (1|M0)          r2.3<1>:ud    r3.7<0;0>:ud      r2.3<0;0>:ud      r1.3<0>:ud       {A@2} // s0|s1|s2
        or (1|M0)                r3.1<1>:d     r3.1<0;1,0>:d     r1.2<0;1,0>:d    {I@2}
        or (1|M0)                r2.4<1>:d     r1.2<0;1,0>:d     8388608:d              
        mad (1|M0)               r2.3<1>:f     r3.1<0;0>:f       r4.2<0;0>:f       r2.3<0>:f        {A@1}
        cmp (1|M0)    (eq)f0.0   null<1>:uw    r6.20<0;1,0>:ub   0x0:uw             
        add (1|M0)               r2.3<1>:f     r2.3<0;1,0>:f     -r2.4<0;1,0>:f   {A@1}
        mul (1|M0)               r2.4<1>:f     r2.4<0;1,0>:f     r2.4<0;1,0>:f   
        and (1|M0)    (ne)f1.1   null<1>:d     r6.3<0;1,0>:d     1:w              
        and (1|M0)               r2.4<1>:d     r2.4<0;1,0>:d     -2:w               {F@1}
        or (1|M0)                r2.4<1>:d     r2.4<0;1,0>:d     r2.3<0;1,0>:d    {I@1}
(~f0.0) mov (1|M0)               r2.4<1>:f     r6.4<0;1,0>:f                    {I@1}
(f1.1)  mov (1|M0)               r14.0<1>:f    r2.4<0;1,0>:f                    {F@1}
L12080:
        join (16|M0)                         L12424                                
L12096:
        add (1|M0)               r2.3<1>:d     r14.1<0;1,0>:d    126:w              
(W)     mov (1|M0)               r1.3<1>:uw    r6.12<0;1,0>:ub                 
        cmp (1|M0)    (gt)f0.0   null<1>:ud    r2.3<0;1,0>:ud    0x17A:uw              {I@2}
        mad (1|M0)               r16.4<1>:f    r6.1<0;0>:f       r6.0<0;0>:f       r16.4<0>:f      
        or (1|M0)                r3.0<1>:w     r16.24<0;1,0>:ub  r1.3<0;1,0>:uw   {I@2}
(W)     and (1|M0)               f1.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw              {F@2}
(~f1.1.any16h) goto (16|M0)                  L12288                  L12288                
L12208:
(f0.0)  sel (1|M0)               r1.2<1>:d     r14.1<0;1,0>:d    0:w              
        asr (1|M0)               r1.2<1>:d     r1.2<0;1,0>:d     11:w               {I@1}
        add (1|M0)               r1.3<1>:d     r1.2<0;1,0>:d     248:w               {I@1}
        xor (1|M0)               r1.3<1>:d     r1.3<0;1,0>:d     r1.2<0;1,0>:d    {I@1}
(f0.0)  mov (1|M0)               r14.1<1>:d    r1.3<0;1,0>:d                    {I@1}
L12288:
        join (16|M0)                         L12424                                
L12304:
        asr (1|M0)               r1.2<1>:d     r14.1<0;1,0>:d    1:w               {I@2}
        cmp (1|M0)    (eq)f1.0   null<1>:w     r3.0<0;1,0>:w     0:w              
        add (1|M0)               r14.1<1>:d    r14.1<0;1,0>:d    -r1.2<0;1,0>:d   {I@2}
        shl (1|M0)               r1.2<1>:d     r1.2<0;1,0>:d     23:w              
        shl (1|M0)               r14.1<1>:d    r14.1<0;1,0>:d    23:w               {Compacted,I@2}
        add (1|M0)               r1.2<1>:d     r1.2<0;1,0>:d     r16.4<0;1,0>:d   {A@1}
        add (1|M0)               r14.1<1>:d    r14.1<0;1,0>:d    1065353216:d               {I@2}
(f1.0)  mul (1|M0)               r14.0<1>:f    r14.1<0;1,0>:f    r1.2<0;1,0>:f    {I@1}
L12424:
        join (16|M0)                         L12440                                
L12440:
        sync.nop                             null                             {Compacted,F@1}
        math.inv (1|M0)          r1.2<1>:f     r14.5<0;1,0>:f                   {$12}
        mov (1|M0)               r1.4<1>:ud    0x3F800000:ud                             
        mul (1|M0)               r1.3<1>:f     r1.2<0;1,0>:f     r14.4<0;1,0>:f   {$12.dst}
        mad (1|M0)               r1.4<1>:f     r1.4<0;0>:f       r1.2<0;0>:f       -r14.5<0>:f      {I@1}
        mad (1|M0)               r2.3<1>:f     r14.4<0;0>:f      r1.3<0;0>:f       -r14.5<0>:f      {F@2}
        mad (1|M0)               r1.4<1>:f     r1.2<0;0>:f       r1.2<0;0>:f       r1.4<0>:f        {F@2}
        cmp (1|M0)    (eq)f0.1   null<1>:uw    r14.24<0;1,0>:ub  0x0:uw             
        mad (1|M0)               r2.3<1>:f     r1.3<0;0>:f       r1.4<0;0>:f       r2.3<0>:f        {F@1}
        mad (1|M0)               r14.4<1>:f    r14.4<0;0>:f      r2.3<0;0>:f       -r14.5<0>:f      {F@1}
(f0.1)  mad (1|M0)               r14.0<1>:f    r2.3<0;0>:f       r1.4<0;0>:f       r14.4<0>:f       {F@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        ret (16|M0)                          r14.2                            {A@1}
L12656:
        mov (1|M0)               r1.2<1>:d     cr0.0<0;1,0>:ud                  {A@1}
        and (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   -1265:w               {A@1}
        or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   1264:w               {A@1}
        mad (1|M0)               r6.2<1>:f     r2.1<0;0>:f       r2.0<0;0>:f       r6.2<0>:f        {A@1}
        mov (1|M0)               cr0.0<1>:ud   r1.2<0;1,0>:d                    {A@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        ret (16|M0)                          r3.0                             {A@1}
L12784:
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
