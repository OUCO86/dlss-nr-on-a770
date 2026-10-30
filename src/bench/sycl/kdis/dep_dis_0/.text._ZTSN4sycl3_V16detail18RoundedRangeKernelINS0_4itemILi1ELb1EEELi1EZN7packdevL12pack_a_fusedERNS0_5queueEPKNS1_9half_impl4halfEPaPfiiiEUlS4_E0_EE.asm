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
        mov (1|M0)               r18.2<1>:d    r8.0<0;1,0>:d                    {I@1}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        cmp (1|M0)    (lt)f1.0   null<1>:ud    r18.2<0;1,0>:ud   r3.0<0;1,0>:ud   {I@2}
        add3 (1|M0)              r18.3<1>:d    r9.0<0;0>:d       r7.0<0;0>:d       0:w               {I@2}
        mul (1|M0)               acc0.0<1>:ud  r2.0<0;1,0>:ud    r2.6<0;1,0>:uw  
        cmp (1|M0)    (lt)f1.1   null<1>:ud    r18.3<0;1,0>:ud   r3.1<0;1,0>:ud   {I@2}
(f1.0)  cmp (1|M0)    (eq)f1.0   null<1>:d     r18.3<0;1,0>:d    r3.1<0;1,0>:d   
        mach (1|M0)              r11.0<1>:ud   r2.0<0;1,0>:ud    r2.3<0;1,0>:ud   {AccWrEn}
(f1.1)  sel (1|M0)               r2.12<1>:uw   r1.3<0;1,0>:uw    0x0:uw              {F@1}
(f1.0)  sel (1|M0)               r1.4<1>:uw    r1.3<0;1,0>:uw    0x0:uw             
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        or (1|M0)     (ne)f1.0   null<1>:uw    r1.4<0;1,0>:uw    r2.12<0;1,0>:uw  {I@2}
        mov (1|M0)               r17.1<1>:d    r11.0<0;1,0>:d                  
        mov (1|M0)               r17.0<1>:f    r10.0<0;1,0>:f                   {Compacted,I@3}
(W)     and (1|M0)               f1.0<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
(~f1.0.any16h) goto (16|M0)                  L4312                  L4312                
L544:
        mov (1|M0)               r17.6<1>:d    r4.0<0;1,0>:d                   
        mov (1|M0)               r18.0<1>:d    r4.6<0;1,0>:d                   
        asr (1|M0)               r18.1<1>:d    r4.6<0;1,0>:d     31:w              
        mov (2|M0)               r17.4<1>:d    0x7:v                              
        mov (2|M0)               r17.2<1>:d    r17.6<1;1,0>:d                   {I@4}
        asr (1|M0)               r17.3<1>:d    r4.0<0;1,0>:d     31:w               {Compacted}
        mov (1|M0)               r17.7<1>:d    0:w                              
L648:
        shr (1|M0)               r1.2<1>:ud    r18.2<0;1,0>:ud   0x7:uw             
        shl (1|M0)               r1.3<1>:d     r18.3<0;1,0>:d    25:w               {Compacted}
        cmp (1|M0)    (lt)f0.1   null<1>:d     r18.2<0;1,0>:d    r4.1<0;1,0>:d   
        or (1|M0)                r2.6<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        shr (1|M0)               r2.7<1>:ud    r18.3<0;1,0>:ud   0x7:uw             
        mul (1|M0)               acc0.0<1>:ud  r2.6<0;1,0>:ud    r17.4<0;1,0>:uw  {I@2}
        mach (1|M0)              r7.0<1>:ud    r2.6<0;1,0>:ud    r17.2<0;1,0>:ud  {AccWrEn}
        shr (1|M0)               r3.2<1>:ud    r18.2<0;1,0>:ud   0x4:uw             
        shl (1|M0)               r3.3<1>:d     r18.3<0;1,0>:d    28:w               {Compacted}
(W)     and (1|M0)               f0.1<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r2.6<0;1,0>:d     r17.6<0;1,0>:uw 
        mach (1|M0)              r8.0<1>:d     r2.6<0;1,0>:d     r17.3<0;1,0>:d   {$2.src}
(W)     mul (1|M0)               acc0.0<1>:d   r2.7<0;1,0>:d     r17.4<0;1,0>:uw  {I@7}
        shr (1|M0)               r18.5<1>:ud   r18.3<0;1,0>:ud   0x4:uw             
        or (1|M0)                r18.4<1>:d    r3.2<0;1,0>:d     r3.3<0;1,0>:d    {I@7}
        mach (1|M0)              r9.0<1>:d     r2.7<0;1,0>:d     r17.2<0;1,0>:d  
        and (1|M0)               r18.6<1>:d    r18.2<0;1,0>:d    15:w              
        cmp (1|M0)    (gt)f0.0   null<1>:d     r4.0<0;1,0>:d     0:w              
        mov (1|M0)               r19.0<1>:f    r6.0<0;1,0>:f                    {Compacted,I@7}
        and (2|M0)               r18.4<1>:d    r18.4<1;1,0>:d    r17.4<1;1,0>:d   {I@4}
        add3 (1|M0)              r19.1<1>:d    r9.0<0;0>:d       r7.0<0;0>:d       r8.0<0>:d        {I@4}
(f0.1.any16h) goto (16|M0)                   L1584                  L1584                
L984:
(W)     and (1|M0)               f1.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
        shl (1|M0)               r1.2<1>:d     r18.5<0;1,0>:d    9:w               {I@4}
        shr (1|M0)               r1.3<1>:ud    r18.4<0;1,0>:ud   0x17:uw             
        shl (1|M0)               r19.2<1>:d    r18.4<0;1,0>:d    9:w              
        shl (1|M0)               r19.4<1>:d    r18.6<0;1,0>:d    5:w              
        mov (1|M0)               r19.5<1>:d    0:w                              
        or (1|M0)                r19.3<1>:d    r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@4}
(~f1.1.any16h) goto (16|M0)                  L1584                  L4072                
L1112:
        addc (1|M0)              r6.0<1>:ud    r4.2<0;1,0>:ud    r19.2<0;1,0>:ud  {AccWrEn,A@1}
        mov (1|M0)               r20.0<2>:f    0.0:f                              
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r8.0<1>:ud    r6.0<0;1,0>:ud    r19.4<0;1,0>:ud  {AccWrEn,I@2}
        add3 (1|M0)              r1.3<1>:d     r7.0<0;0>:d       r4.3<0;0>:d       r19.3<0>:d       {I@2}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r20.1<2>:f    0.0:f                              
        mov (1|M0)               r19.6<1>:d    r8.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r19.7<1>:d    r9.0<0;0>:d       r1.3<0;0>:d       r19.5<0>:d       {I@2}
L1240:
        addc (1|M0)              r6.0<1>:ud    r20.0<0;1,0>:ud   r19.0<0;1,0>:ud  {AccWrEn,F@2}
        mov (4|M0)               r11.0<2>:f    0.0:f                               {$3.src}
        shl (1|M0)               r3.2<1>:d     r6.0<0;1,0>:d     12:w               {Compacted,I@1}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r8.0<1>:ud    r19.6<0;1,0>:ud   r3.2<0;1,0>:ud   {AccWrEn,I@2}
        add3 (1|M0)              r1.3<1>:d     r7.0<0;0>:d       r20.1<0;0>:d      r19.1<0>:d       {A@2}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r7.0<1>:ud    r20.0<0;1,0>:ud   0x1:ud              {AccWrEn}
        shr (1|M0)               r2.7<1>:ud    r6.0<0;1,0>:ud    0x14:uw             
        mov (1|M0)               r12.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r20.2<1>:d    r7.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r20.3<1>:d    r12.0<0;0>:d      r20.1<0;0>:d      0:w               {I@2}
        shl (1|M0)               r2.6<1>:d     r1.3<0;1,0>:d     12:w              
        cmp (1|M0)    (eq)f0.1   null<1>:d     r20.3<0;1,0>:d    r17.7<0;1,0>:d   {I@2}
        or (1|M0)                r3.3<1>:d     r2.6<0;1,0>:d     r2.7<0;1,0>:d    {I@2}
        mov (4|M0)               r11.1<2>:f    0.0:f                              
        mov (1|M0)               r10.0<1>:f    r8.0<0;1,0>:f                    {Compacted,$4.src}
(f0.1)  cmp (1|M0)    (eq)f0.1   null<1>:d     r20.2<0;1,0>:d    r17.6<0;1,0>:d  
        add3 (1|M0)              r10.1<1>:d    r9.0<0;0>:d       r19.7<0;0>:d      r3.3<0>:d        {I@2}
        send.ugm (1|M0)          null     r10     r11:1   0x0            0x0200B784           {A@1,$3} // wr:1+1, rd:0; store.ugm.d64x4t.a64
(W)     and (1|M0)               f1.0<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(f1.0.any16h) goto (16|M0)                   L1584                  L4072                
L1552:
(W)     mov (2|M0)               r20.0<1>:ud   r20.2<1;1,0>:ud                 
        goto.b (16|M0)                       L1584                  L1240                
L1584:
        join (16|M0)                         L4072                                
L1600:
(W)     and (1|M0)               f0.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
        mov (16|M0)              r22.0<1>:ud   0x0:ud                             
        mov (16|M0)              r24.0<1>:f    0.0:f                               {Compacted}
(~f0.1.any16h) goto (16|M0)                  L2336                  L2336                
L1656:
        mul (1|M0)               acc0.0<1>:ud  r18.2<0;1,0>:ud   r18.0<0;1,0>:uw 
        mach (1|M0)              r7.0<1>:ud    r18.2<0;1,0>:ud   r18.0<0;1,0>:ud  {AccWrEn}
        mov (1|M0)               r20.6<2>:f    0.0:f                              
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r18.2<0;1,0>:d    r18.2<0;1,0>:uw 
        mach (1|M0)              r8.0<1>:d     r18.2<0;1,0>:d    r18.1<0;1,0>:d  
(W)     mul (1|M0)               acc0.0<1>:d   r18.3<0;1,0>:d    r18.0<0;1,0>:uw  {Compacted}
        mach (1|M0)              r9.0<1>:d     r18.3<0;1,0>:d    r18.0<0;1,0>:d   {Compacted}
        shl (1|M0)               r3.2<1>:d     r6.0<0;1,0>:d     1:w               {Compacted,I@5}
        add3 (1|M0)              r1.3<1>:d     r9.0<0;0>:d       r7.0<0;0>:d       r8.0<0>:d        {I@2}
        shr (1|M0)               r2.7<1>:ud    r6.0<0;1,0>:ud    0x1F:uw             
        sync.allrd                           ($3,$4)                
        addc (1|M0)              r10.0<1>:ud   r4.4<0;1,0>:ud    r3.2<0;1,0>:ud   {AccWrEn,I@3}
        shl (1|M0)               r2.6<1>:d     r1.3<0;1,0>:d     1:w               {I@3}
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        or (1|M0)                r3.3<1>:d     r2.6<0;1,0>:d     r2.7<0;1,0>:d    {I@2}
        mov (1|M0)               r20.7<2>:f    0.0:f                              
        mov (1|M0)               r20.4<1>:d    r10.0<0;1,0>:d                  
        add3 (1|M0)              r20.5<1>:d    r11.0<0;0>:d      r4.5<0;0>:d       r3.3<0>:d        {I@2}
L1920:
        shl (1|M0)               r1.2<1>:d     r20.7<0;1,0>:d    5:w               {F@1}
        shr (1|M0)               r1.3<1>:ud    r20.6<0;1,0>:ud   0x1B:uw             
        shl (1|M0)               r1.4<1>:d     r20.6<0;1,0>:d    5:w              
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        shl (1|M0)               r3.2<1>:d     r1.4<0;1,0>:d     1:w               {I@2}
        shr (1|M0)               r2.7<1>:ud    r1.4<0;1,0>:ud    0x1F:uw             
        shl (1|M0)               r2.6<1>:d     r1.5<0;1,0>:d     1:w               {I@3}
        addc (1|M0)              r6.0<1>:ud    r20.4<0;1,0>:ud   r3.2<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r3.3<1>:d     r2.6<0;1,0>:d     r2.7<0;1,0>:d    {I@2}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r8.0<1>:f     r6.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r8.1<1>:d     r7.0<0;0>:d       r20.5<0;0>:d      r3.3<0>:d        {I@1}
        addc (1|M0)              r15.0<1>:ud   r20.6<0;1,0>:ud   0x1:ud              {AccWrEn}
        send.ugm (1|M0)          r9       r8      null:0  0x0            0x0220C780           {A@1,$5} // wr:1+0, rd:2; load.ugm.d64x8t.a64
        mov (1|M0)               r16.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r21.0<1>:f    r15.0<0;1,0>:f                   {Compacted,I@2}
        add3 (1|M0)              r21.1<1>:d    r16.0<0;0>:d      r20.7<0;0>:d      0:w               {I@1}
        cmp (1|M0)    (eq)f1.1   null<1>:d     r21.1<0;1,0>:d    r17.7<0;1,0>:d   {I@1}
(f1.1)  cmp (1|M0)    (eq)f1.1   null<1>:d     r21.0<0;1,0>:d    r17.6<0;1,0>:d   {F@1}
(W)     and (1|M0)               f1.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
        mov (8|M0)               r11.0<1>:f    (abs)r9.0<1;1,0>:hf              {$5.dst}
        mov (8|M0)               r12.0<1>:f    (abs)r9.8<1;1,0>:hf             
        mov (8|M0)               r13.0<1>:f    (abs)r10.0<1;1,0>:hf            
        mov (8|M0)               r14.0<1>:f    (abs)r10.8<1;1,0>:hf            
        sel (16|M0)   (ge)f0.0   r22.0<1>:f    r22.0<1;1,0>:f    r11.0<1;1,0>:f   {Compacted,F@3}
        sel (16|M0)   (ge)f0.0   r24.0<1>:f    r24.0<1;1,0>:f    r13.0<1;1,0>:f   {Compacted,F@2}
(f1.1.any16h) goto (16|M0)                   L2336                  L2336                
L2304:
(W)     mov (2|M0)               r20.6<1>:ud   r21.0<1;1,0>:ud                 
        goto.b (16|M0)                       L2336                  L1920                
L2336:
        join (16|M0)                         L4072                                
L2352:
        sel (16|M0)   (ge)f0.0   r22.0<1>:f    r22.0<1;1,0>:f    r24.0<1;1,0>:f   {Compacted,F@1}
        sel (8|M0)    (ge)f0.0   r6.0<1>:f     r22.0<1;1,0>:f    r23.0<1;1,0>:f   {Compacted,F@1}
        mov (4|M0)               r7.0<1>:ud    r6.4<1;1,0>:ud                   {F@1}
        sel (4|M0)    (ge)f0.0   r8.0<1>:f     r6.0<1;1,0>:f     r7.0<1;1,0>:f    {I@1}
        mov (2|M0)               r9.0<1>:ud    r8.2<1;1,0>:ud                   {F@1}
        sync.allrd                           ($3,$4)                
        sel (2|M0)    (ge)f0.0   r10.0<1>:f    r8.0<1;1,0>:f     r9.0<1;1,0>:f    {I@1}
        sel (1|M0)    (ge)f0.0   r85.4<1>:f    r10.0<0;1,0>:f    r10.1<0;1,0>:f   {F@1}
        cmp (1|M0)    (eq)f0.1   null<1>:f     r85.4<0;1,0>:f    0.0:f               {F@1}
(W)     and (1|M0)               f1.0<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(f1.0.any16h) goto (16|M0)                   L2592                  L2592                
L2512:
        mov (1|M0)               r85.5<1>:f    127.0:f                              
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r85.2         L4384                                 {A@1}
L2576:
        goto (16|M0)                         L2592                  L2616                
L2592:
        join (16|M0)                         L2616                                
L2608:
        mov (1|M0)               r26.0<1>:f    1.0:f                               {Compacted}
L2616:
        join (16|M0)                         L4072                                
L2632:
        shl (1|M0)               r1.4<1>:d     r18.2<0;1,0>:d    2:w              
        shl (1|M0)               r1.2<1>:d     r18.3<0;1,0>:d    2:w              
        shr (1|M0)               r1.3<1>:ud    r18.2<0;1,0>:ud   0x1E:uw             
        addc (1|M0)              r6.0<1>:ud    r5.0<0;1,0>:ud    r1.4<0;1,0>:ud   {AccWrEn,I@3}
(W)     and (1|M0)               f0.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw              {F@3}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@3}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        shl (1|M0)               r2.6<1>:d     r18.5<0;1,0>:d    9:w              
        shr (1|M0)               r2.7<1>:ud    r18.4<0;1,0>:ud   0x17:uw             
        mov (1|M0)               r8.0<1>:f     r6.0<0;1,0>:f                    {Compacted,I@6}
        add3 (1|M0)              r8.1<1>:d     r7.0<0;0>:d       r5.1<0;0>:d       r1.5<0>:d        {I@3}
        shl (1|M0)               r21.2<1>:d    r18.4<0;1,0>:d    9:w              
        send.ugm (1|M0)          null     r8      r26:1   0x0            0x04000584           {A@1,$2} // wr:2+1, rd:0; store.ugm.d32.a64
        shl (1|M0)               r21.4<1>:d    r18.6<0;1,0>:d    5:w              
        mov (1|M0)               r21.5<1>:d    0:w                              
        or (1|M0)                r21.3<1>:d    r2.6<0;1,0>:d     r2.7<0;1,0>:d   
(~f0.1.any16h) goto (16|M0)                  L4072                  L4072                
L2888:
        mul (1|M0)               acc0.0<1>:ud  r18.2<0;1,0>:ud   r18.0<0;1,0>:uw 
        mach (1|M0)              r7.0<1>:ud    r18.2<0;1,0>:ud   r18.0<0;1,0>:ud  {AccWrEn}
        mov (16|M0)              r27.0<1>:f    r26.0<0;1,0>:f                   {Compacted}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r18.2<0;1,0>:d    r18.2<0;1,0>:uw 
        shl (1|M0)               r3.2<1>:d     r6.0<0;1,0>:d     1:w               {Compacted,I@2}
        mach (1|M0)              r8.0<1>:d     r18.2<0;1,0>:d    r18.1<0;1,0>:d   {$2.src}
(W)     mul (1|M0)               acc0.0<1>:d   r18.3<0;1,0>:d    r18.0<0;1,0>:uw  {Compacted}
        mach (1|M0)              r9.0<1>:d     r18.3<0;1,0>:d    r18.0<0;1,0>:d   {Compacted}
        addc (1|M0)              r10.0<1>:ud   r4.4<0;1,0>:ud    r3.2<0;1,0>:ud   {AccWrEn,I@4}
        add3 (1|M0)              r1.3<1>:d     r9.0<0;0>:d       r7.0<0;0>:d       r8.0<0>:d        {I@2}
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r12.0<1>:ud   r4.2<0;1,0>:ud    r21.2<0;1,0>:ud  {AccWrEn}
        shr (1|M0)               r2.7<1>:ud    r6.0<0;1,0>:ud    0x1F:uw             
        shl (1|M0)               r2.6<1>:d     r1.3<0;1,0>:d     1:w               {I@4}
        mov (1|M0)               r13.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r8.0<1>:ud    r12.0<0;1,0>:ud   r21.4<0;1,0>:ud  {AccWrEn,I@4}
        or (1|M0)                r3.3<1>:d     r2.6<0;1,0>:d     r2.7<0;1,0>:d    {I@3}
        add3 (1|M0)              r5.3<1>:d     r13.0<0;0>:d      r4.3<0;0>:d       r21.3<0>:d       {I@3}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r26.4<2>:f    0.0:f                              
        mov (1|M0)               r26.5<2>:f    0.0:f                              
        mov (1|M0)               r21.6<1>:d    r10.0<0;1,0>:d                  
        mov (1|M0)               r26.1<1>:d    r8.0<0;1,0>:d                    {I@5}
        add3 (1|M0)              r21.7<1>:d    r11.0<0;0>:d      r4.5<0;0>:d       r3.3<0>:d        {I@5}
        add3 (1|M0)              r26.2<1>:d    r9.0<0;0>:d       r5.3<0;0>:d       r21.5<0>:d       {I@4}
L3240:
        shl (1|M0)               r1.2<1>:d     r26.5<0;1,0>:d    5:w               {F@1}
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
        mov (16|M0)              r43.0<1>:f    r27.0<1;1,0>:f                   {Compacted}
        send.ugm (1|M0)          r9       r8      null:0  0x0            0x0220C780           {A@1,$6} // wr:1+0, rd:2; load.ugm.d64x8t.a64
        mov (8|M0)               r36.0<1>:f    r9.0<1;1,0>:hf                   {$6.dst}
        mov (8|M0)               r37.0<1>:f    r9.8<1;1,0>:hf                  
        mov (8|M0)               r29.0<1>:f    r10.0<1;1,0>:hf                 
        mov (8|M0)               r30.0<1>:f    r10.8<1;1,0>:hf                 
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r85.6         L8424                                 {A@1}
L3552:
        mov (16|M0)              r31.0<1>:ud   r77.0<1;1,0>:ud                 
        mov (16|M0)              r36.0<1>:f    r29.0<1;1,0>:f                   {Compacted,F@1}
        mov (16|M0)              r43.0<1>:f    r27.0<1;1,0>:f                   {Compacted}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r85.6         L8424                                 {A@1}
L3632:
        addc (1|M0)              r6.0<1>:ud    r26.4<0;1,0>:ud   r19.0<0;1,0>:ud  {AccWrEn}
        rnde (16|M0)             r31.0<1>:f    r31.0<1;1,0>:f                   {Compacted,I@3}
        shl (1|M0)               r3.2<1>:d     r6.0<0;1,0>:d     12:w               {Compacted,I@1}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r8.0<1>:ud    r26.1<0;1,0>:ud   r3.2<0;1,0>:ud   {AccWrEn,I@2}
        add3 (1|M0)              r1.3<1>:d     r7.0<0;0>:d       r26.5<0;0>:d      r19.1<0>:d       {I@2}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r7.0<1>:ud    r26.4<0;1,0>:ud   0x1:ud              {AccWrEn}
        shr (1|M0)               r2.7<1>:ud    r6.0<0;1,0>:ud    0x14:uw             
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        rnde (16|M0)             r77.0<1>:f    r77.0<1;1,0>:f                   {Compacted}
        add3 (1|M0)              r26.7<1>:d    r6.0<0;0>:d       r26.5<0;0>:d      0:w               {I@1}
        mov (1|M0)               r26.6<1>:d    r7.0<0;1,0>:d                   
        cmp (1|M0)    (eq)f1.1   null<1>:d     r26.7<0;1,0>:d    r17.7<0;1,0>:d   {I@2}
        sel (16|M0)   (ge)f0.0   r31.0<1>:f    r31.0<1;1,0>:f    -127.0:f               {F@2}
        sel (16|M0)   (ge)f0.0   r77.0<1>:f    r77.0<1;1,0>:f    -127.0:f               {F@2}
(f1.1)  cmp (1|M0)    (eq)f1.1   null<1>:d     r26.6<0;1,0>:d    r17.6<0;1,0>:d   {I@2}
        shl (1|M0)               r2.6<1>:d     r1.3<0;1,0>:d     12:w              
        sel (16|M0)   (lt)f0.0   r31.0<1>:f    r31.0<1;1,0>:f    127.0:f               {F@2}
        sel (16|M0)   (lt)f0.0   r77.0<1>:f    r77.0<1;1,0>:f    127.0:f               {F@2}
        or (1|M0)                r3.3<1>:d     r2.6<0;1,0>:d     r2.7<0;1,0>:d    {I@1}
        mov (16|M0)              r11.0<1>:d    r31.0<1;1,0>:f                   {Compacted,F@2}
(W)     and (1|M0)               f0.0<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
        mov (16|M0)              r13.0<1>:d    r77.0<1;1,0>:f                   {Compacted,F@1}
        mov (1|M0)               r10.0<1>:f    r8.0<0;1,0>:f                    {Compacted}
        add3 (1|M0)              r10.1<1>:d    r9.0<0;0>:d       r26.2<0;0>:d      r3.3<0>:d        {I@4}
        mov (16|M0)              r15.0<1>:b    r11.0<4;1,0>:b                   {I@4}
        mov (16|M0)              r15.16<1>:b   r13.0<4;1,0>:b                   {I@3}
        send.ugm (1|M0)          null     r10     r15:1   0x0            0x0200B784           {A@1,$4} // wr:1+1, rd:0; store.ugm.d64x4t.a64
(f0.0.any16h) goto (16|M0)                   L4072                  L4072                
L4040:
(W)     mov (2|M0)               r26.4<1>:ud   r26.6<1;1,0>:ud                 
        goto.b (16|M0)                       L4072                  L3240                
L4072:
        join (16|M0)                         L4312                                
L4088:
        addc (1|M0)              r6.0<1>:ud    r18.2<0;1,0>:ud   r17.0<0;1,0>:ud  {AccWrEn}
(W)     mov (1|M0)               r1.3<1>:hf    0x1:hf                             
        mov (1|M0)               r33.0<1>:f    r6.0<0;1,0>:f                    {Compacted,I@1}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        cmp (1|M0)    (lt)f1.0   null<1>:ud    r33.0<0;1,0>:ud   r3.0<0;1,0>:ud   {F@1}
        add3 (1|M0)              r33.1<1>:d    r7.0<0;0>:d       r18.3<0;0>:d      r17.1<0>:d       {I@2}
        cmp (1|M0)    (lt)f1.1   null<1>:ud    r33.1<0;1,0>:ud   r3.1<0;1,0>:ud   {I@1}
(f1.0)  cmp (1|M0)    (eq)f1.0   null<1>:d     r33.1<0;1,0>:d    r3.1<0;1,0>:d   
(f1.1)  sel (1|M0)               r2.12<1>:uw   r1.3<0;1,0>:uw    0x0:uw             
(f1.0)  sel (1|M0)               r1.4<1>:uw    r1.3<0;1,0>:uw    0x0:uw             
        or (1|M0)     (ne)f1.1   null<1>:uw    r1.4<0;1,0>:uw    r2.12<0;1,0>:uw  {I@1}
(W)     and (1|M0)               f1.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(~f1.1.any16h) goto (16|M0)                  L4312                  L4312                
L4280:
(W)     mov (2|M0)               r18.2<1>:ud   r33.0<1;1,0>:ud                 
        goto.b (16|M0)                       L4312                  L648                
L4312:
        join (16|M0)                         L4328                                
L4328:
(W)     mov (8|M0)               r127.0<1>:f   r0.0<1;1,0>:f                    {Compacted}
(W)     send.ugm (1|M0)          r6       r0      null:0  0x0            0x0210641F           {$7} // wr:1+0, rd:1; fence invalid flush type scoped to tile
(W)     mov (8|M0)               null<1>:ud    r6.0<1;1,0>:ud                   {$7.dst}
(W)     send.gtwy (1|M0)         null     r127    null:0  0x0            0x02000010           {EOT,A@1} // wr:1+0, rd:0; end of thread
L4384:
        shr (1|M0)               r33.2<1>:ud   r85.5<0;1,0>:ud   0x17:uw             
        shr (1|M0)               r26.3<1>:ud   r85.4<0;1,0>:ud   0x17:uw             
        and (1|M0)               r33.2<1>:ud   r33.2<0;1,0>:ud   0xFF:uw              {I@2}
        and (1|M0)               r26.3<1>:ud   r26.3<0;1,0>:ud   0xFF:uw              {I@2}
        add (1|M0)               r1.3<1>:ud    r33.2<0;1,0>:ud   0xFFFFFF41:ud              {I@2}
        add (1|M0)               r1.2<1>:ud    r26.3<0;1,0>:ud   0xFFFFFF41:ud              {I@2}
        cmp (1|M0)    (lt)f0.1   null<1>:ud    r1.3<0;1,0>:ud    0xFFFFFF81:ud              {I@2}
(W)     mov (1|M0)               r2.12<1>:hf   -qnan(0x1FF):hf                             
(~f0.1) cmp (1|M0)    (lt)f0.1   null<1>:ud    r1.2<0;1,0>:ud    0xFFFFFF82:ud              {I@2}
(f0.1)  sel (1|M0)               r18.28<2>:b   r2.12<0;1,0>:w    0:w               {F@1}
        cmp (1|M0)    (ne)f1.0   null<1>:uw    r18.28<0;1,0>:ub  0x0:uw              {I@1}
(W)     and (1|M0)               f1.0<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
(~f1.0.any16h) goto (16|M0)                  L8064                  L8064                
L4592:
        add (1|M0)               r1.3<1>:ud    r33.2<0;1,0>:ud   0xFFFFFF01:ud             
        add (1|M0)               r1.2<1>:ud    r26.3<0;1,0>:ud   0xFFFFFF01:ud             
        cmp (1|M0)    (lt)f1.1   null<1>:ud    r1.3<0;1,0>:ud    0xFFFFFF02:ud              {I@2}
(W)     mov (1|M0)               r2.12<1>:hf   -qnan(0x1FF):hf                             
        mov (1|M0)               r34.6<1>:f    (abs)r85.4<0;1,0>:f             
(~f1.1) cmp (1|M0)    (lt)f1.1   null<1>:ud    r1.2<0;1,0>:ud    0xFFFFFF02:ud              {I@2}
(f1.1)  sel (1|M0)               r33.12<2>:b   r2.12<0;1,0>:w    0:w               {F@2}
        cmp (1|M0)    (ne)f1.0   null<1>:uw    r33.12<0;1,0>:ub  0x0:uw              {I@1}
(W)     and (1|M0)               f0.1<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
(f0.1.any16h) goto (16|M0)                   L4848                  L4848                
L4752:
        mov (1|M0)               r1.2<1>:f     (abs)r85.5<0;1,0>:f             
        mov (1|M0)               r34.2<2>:b    0:w                              
        add (1|M0)               r34.6<1>:d    r34.6<0;1,0>:d    -r1.2<0;1,0>:d   {A@1}
        mov (2|M0)               r85.0<1>:d    r85.4<1;1,0>:ud                 
        asr (1|M0)               r34.6<1>:d    r34.6<0;1,0>:d    23:w               {I@2}
        goto (16|M0)                         L4848                  L6552                
L4848:
        join (16|M0)                         L6552                                
L4864:
        cmp (1|M0)    (gt)f0.1   null<1>:ud    r34.6<0;1,0>:ud   0x7F800000:ud              {I@3}
(W)     mov (1|M0)               r1.3<1>:hf    0xFF:hf                             
        mov (1|M0)               r34.4<1>:f    (abs)r85.5<0;1,0>:f             
(W)     mov (1|M0)               r2.13<1>:hf   -qnan(0x1FF):hf                             
(f0.1)  sel (1|M0)               r2.12<1>:w    r1.3<0;1,0>:w     0:w               {F@3}
        add (1|M0)               r26.0<1>:f    r85.4<0;1,0>:f    r85.5<0;1,0>:f  
        cmp (1|M0)    (eq)f1.0   null<1>:w     r2.24<0;1,0>:b    0:w               {I@1}
(W)     mov (1|M0)               r3.4<1>:uw    r2.24<0;1,0>:ub                 
        and (1|M0)               r33.5<1>:ud   r85.4<0;1,0>:ud   0x7F800000:ud             
(W)     mov (1|M0)               r6.0<1>:f     -0.0:f                               {Compacted}
(f1.0)  cmp (1|M0)    (gt)f1.0   null<1>:ud    r34.4<0;1,0>:ud   0x7F800000:ud              {F@4}
        bfn.0x6A (1|M0)          r1.2<1>:ud    r85.4<0;0>:ud     r85.5<0;0>:ud     r6.0<0>:ud       {F@1} // s0^s1&s2
        bfn.0x6A (1|M0)          r1.3<1>:ud    r85.5<0;0>:ud     r85.4<0;0>:ud     r6.0<0>:ud       // s0^s1&s2
        and (1|M0)               r33.6<1>:ud   r85.5<0;1,0>:ud   0x7F800000:ud             
(f1.0)  sel (1|M0)               r2.28<2>:b    r2.13<0;1,0>:w    0:w              
        and (1|M0)               r4.7<1>:ud    r85.5<0;1,0>:ud   0x80000000:ud             
        and (1|M0)    (ne)f0.1   null<1>:w     r2.28<0;1,0>:ub   1:w               {I@2}
        and (1|M0)               r33.4<1>:ud   r85.4<0;1,0>:ud   0x80000000:ud             
(f0.1)  add (1|M0)               r26.0<1>:f    r85.5<0;1,0>:f    r85.5<0;1,0>:f  
        or (1|M0)     (eq)f0.1   r2.28<2>:ub   r2.28<0;1,0>:ub   r3.4<0;1,0>:uw   {F@1}
(f0.1)  cmp (1|M0)    (eq)f0.1   null<1>:d     r33.5<0;1,0>:d    2139095040:d              
(W)     mov (1|M0)               r5.4<1>:uw    r2.28<0;1,0>:ub                  {I@2}
(f0.1)  sel (1|M0)               r1.6<2>:b     r2.13<0;1,0>:w    0:w              
        and (1|M0)    (ne)f1.1   null<1>:w     r1.6<0;1,0>:ub    1:w               {I@1}
(f1.1)  add (1|M0)               r26.0<1>:f    r1.2<0;1,0>:f     -r1.3<0;1,0>:f  
        or (1|M0)     (eq)f1.1   r1.6<2>:ub    r1.6<0;1,0>:ub    r5.4<0;1,0>:uw   {F@1}
(f1.1)  cmp (1|M0)    (eq)f1.1   null<1>:d     r33.6<0;1,0>:d    2139095040:d              
(W)     mov (1|M0)               r3.4<1>:uw    r1.6<0;1,0>:ub                   {I@2}
(f1.1)  sel (1|M0)               r33.28<2>:b   r2.13<0;1,0>:w    0:w              
        and (1|M0)    (ne)f1.0   null<1>:w     r33.28<0;1,0>:ub  1:w               {I@1}
(f1.0)  mul (1|M0)               r26.0<1>:f    r4.7<0;1,0>:f     r85.4<0;1,0>:f  
        or (1|M0)     (eq)f1.0   r33.28<2>:ub  r33.28<0;1,0>:ub  r3.4<0;1,0>:uw   {F@1}
(f1.0)  cmp (1|M0)    (eq)f1.0   null<1>:f     r85.5<0;1,0>:f    0.0:f               {I@1}
(f1.0)  sel (1|M0)               r33.14<2>:b   r2.13<0;1,0>:w    0:w              
        cmp (1|M0)    (ne)f0.1   null<1>:uw    r33.14<0;1,0>:ub  0x0:uw              {I@1}
(W)     and (1|M0)               f1.1<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(f1.1.any16h) goto (16|M0)                   L5480                  L5480                
L5448:
        mov (1|M0)               r34.0<2>:b    r33.28<0;1,0>:b                 
        goto (16|M0)                         L5480                  L5664                
L5480:
        join (16|M0)                         L5664                                
L5496:
(W)     mov (1|M0)               r6.0<1>:f     inf:f                               {Compacted}
        cmp (1|M0)    (eq)f0.1   null<1>:f     r85.4<0;1,0>:f    0.0:f               {A@5}
        bfn.0x96 (1|M0)          r33.4<1>:ud   r33.4<0;0>:ud     r85.5<0;0>:ud     r6.0<0>:ud       {F@2} // s0^s1^s2
        xor (1|M0)               r1.2<1>:ud    r85.5<0;1,0>:ud   0x7F800000:ud             
        and (1|M0)    (ne)f1.1   null<1>:w     r33.14<0;1,0>:ub  1:w              
(W)     mov (1|M0)               r2.12<1>:uw   r33.28<0;1,0>:ub                
(~f0.1) mov (1|M0)               r1.2<1>:f     r33.4<0;1,0>:f                   {A@3}
        or (1|M0)                r33.28<2>:ub  r33.14<0;1,0>:ub  r2.12<0;1,0>:uw  {I@1}
(f0.1)  mul (1|M0)               r33.4<1>:f    r1.2<0;1,0>:f     r85.4<0;1,0>:f   {F@1}
        mov (1|M0)               r34.0<2>:b    r33.28<0;1,0>:b                  {I@1}
(f1.1)  mov (1|M0)               r26.0<1>:f    r33.4<0;1,0>:f                   {F@1}
L5664:
        join (16|M0)                         L6552                                
L5680:
        cmp (1|M0)    (eq)f0.1   null<1>:w     r33.28<0;1,0>:b   0:w              
(W)     mov (1|M0)               r1.3<1>:hf    -qnan(0x1FF):hf                             
(W)     mov (1|M0)               r2.12<1>:uw   r34.0<0;1,0>:ub                  {I@3}
(f0.1)  cmp (1|M0)    (eq)f0.1   null<1>:f     r85.4<0;1,0>:f    0.0:f               {I@2}
(f0.1)  sel (1|M0)               r34.2<2>:b    r1.3<0;1,0>:w     0:w               {F@2}
        and (1|M0)    (ne)f1.0   null<1>:w     r34.2<0;1,0>:ub   1:w               {I@1}
        or (1|M0)     (ne)f0.1   r34.2<2>:ub   r34.2<0;1,0>:ub   r2.12<0;1,0>:uw  {F@1}
(f1.0)  mul (1|M0)               r26.0<1>:f    r85.4<0;1,0>:f    r85.5<0;1,0>:f  
(W)     and (1|M0)               f1.0<1>:uw    f0.1<0;1,0>:uw    0x1:uw              {F@1}
(f1.0.any16h) goto (16|M0)                   L6552                  L8064                
L5840:
        cmp (1|M0)    (eq)f1.1   null<1>:uw    r34.2<0;1,0>:ub   0x0:uw              {I@3}
        cmp (1|M0)    (eq)f1.0   null<1>:d     r33.5<0;1,0>:d    0:w              
(~f1.1) mov (1|M0)               r33.12<2>:b   0:w                              
(f1.0)  sel (1|M0)               r34.1<1>:d    r33.12<0;1,0>:b   0:w               {I@1}
        cmp (1|M0)    (ne)f0.1   null<1>:d     r34.1<0;1,0>:d    0:w               {I@1}
(W)     and (1|M0)               f0.1<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(f0.1.any16h) goto (16|M0)                   L5992                  L5992                
L5952:
        mov (1|M0)               r34.2<1>:d    0:w                              
        mov (1|M0)               r85.0<1>:f    r85.4<0;1,0>:f                   {Compacted}
        goto (16|M0)                         L5992                  L6144                
L5992:
        join (16|M0)                         L6144                                
L6008:
        and (1|M0)    (ne)f1.1   r34.1<1>:d    r34.1<0;1,0>:d    1:w              
        mov (1|M0)               r85.0<1>:f    r85.4<0;1,0>:f                   {Compacted}
(W)     mov (1|M0)               r2.12<1>:hf   -qnan(0x1E0):hf                             
(f1.1)  mul (1|M0)               r85.0<1>:f    r85.4<0;1,0>:f    0x4F800000:f              
(f1.1)  sel (1|M0)               r34.2<1>:d    r2.12<0;1,0>:w    0:w               {F@2}
        shr (1|M0)               r1.2<1>:ud    r85.0<0;1,0>:ud   0x17:uw              {F@1}
        and (1|M0)               r1.2<1>:ud    r1.2<0;1,0>:ud    0xFF:uw              {I@1}
        add (1|M0)               r1.2<1>:ud    r1.2<0;1,0>:ud    0xFFFFFFE0:ud              {I@1}
(f1.1)  mov (1|M0)               r26.3<1>:d    r1.2<0;1,0>:d                    {I@1}
L6144:
        join (16|M0)                         L6552                                
L6160:
        cmp (1|M0)    (eq)f1.1   null<1>:d     r33.6<0;1,0>:d    0:w              
(f1.1)  sel (1|M0)               r34.3<1>:d    r33.12<0;1,0>:b   0:w              
        cmp (1|M0)    (ne)f1.0   null<1>:d     r34.3<0;1,0>:d    0:w               {I@1}
(W)     and (1|M0)               f1.1<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
(f1.1.any16h) goto (16|M0)                   L6288                  L6288                
L6240:
        mov (1|M0)               r34.5<1>:d    0:w                              
        mov (1|M0)               r85.1<1>:d    r85.5<0;1,0>:ud                 
        goto (16|M0)                         L6288                  L6464                
L6288:
        join (16|M0)                         L6464                                
L6304:
        and (1|M0)    (ne)f1.0   r34.3<1>:d    r34.3<0;1,0>:d    1:w              
        mov (1|M0)               r85.1<1>:f    r85.5<0;1,0>:f                   {I@4}
(W)     mov (1|M0)               r2.12<1>:hf   0x20:hf                             
(f1.0)  mul (1|M0)               r85.1<1>:f    r85.5<0;1,0>:f    0x4F800000:f              
(f1.0)  sel (1|M0)               r34.5<1>:d    r2.12<0;1,0>:w    0:w               {F@2}
        shr (1|M0)               r1.2<1>:ud    r85.1<0;1,0>:ud   0x17:uw              {F@1}
        mov (1|M0)               r34.4<1>:f    (abs)r85.1<0;1,0>:f             
        and (1|M0)               r1.2<1>:ud    r1.2<0;1,0>:ud    0xFF:uw              {I@1}
        add (1|M0)               r1.2<1>:ud    r1.2<0;1,0>:ud    0xFFFFFFE0:ud              {I@1}
(f1.0)  mov (1|M0)               r33.2<1>:f    r1.2<0;1,0>:f                    {I@1}
L6464:
        join (16|M0)                         L6552                                
L6480:
        mov (1|M0)               r34.6<1>:f    (abs)r85.0<0;1,0>:f              {Compacted}
        add (1|M0)               r34.5<1>:d    r34.5<0;1,0>:d    r34.2<0;1,0>:d  
        add (1|M0)               r34.6<1>:d    r34.6<0;1,0>:d    -r34.4<0;1,0>:d  {F@1}
        asr (1|M0)               r34.6<1>:d    r34.6<0;1,0>:d    23:w               {I@1}
        add (1|M0)               r34.5<1>:d    r34.5<0;1,0>:d    r34.6<0;1,0>:d   {I@1}
L6552:
        join (16|M0)                         L8064                                
L6568:
        cmp (1|M0)    (eq)f0.1   null<1>:uw    r33.12<0;1,0>:ub  0x0:uw             
(W)     mov (1|M0)               r1.2<1>:f     1.0:f                               {Compacted}
(W)     mov (1|M0)               r6.0<1>:f     0x807FFFFF:f                              
        cmp (1|M0)    (eq)f1.1   null<1>:w     r34.2<0;1,0>:b    0:w              
(~f0.1) mov (1|M0)               r34.6<1>:d    r34.5<0;1,0>:d                   {I@4}
        bfn.0xEA (1|M0)          r85.1<1>:ud   r1.2<0;0>:ud      r85.1<0;0>:ud     r6.0<0>:ud       {A@1} // s0|s1&s2
        add (1|M0)               r34.7<1>:d    r34.6<0;1,0>:d    126:w               {I@2}
        add (1|M0)               r35.0<1>:d    -r34.6<0;1,0>:d   -152:w               {Compacted}
        sync.nop                             null                             {Compacted,I@3}
        math.inv (1|M0)          r2.6<1>:f     r85.1<0;1,0>:f                   {$8}
        and (1|M0)               r35.0<1>:d    r35.0<0;1,0>:d    r34.7<0;1,0>:d   {Compacted,I@1}
        mov (1|M0)               r87.0<1>:f    1.0:f                               {Compacted}
        asr (1|M0)               r35.0<1>:d    r35.0<0;1,0>:d    31:w               {Compacted,I@1}
(~f1.1) mov (1|M0)               r35.0<1>:d    0:w                              
        bfn.0xEA (1|M0)          r85.0<1>:ud   r1.2<0;0>:ud      r85.0<0;0>:ud     r6.0<0>:ud       // s0|s1&s2
        cmp (1|M0)    (ne)f1.0   null<1>:d     r35.0<0;1,0>:d    0:w               {I@2}
        sync.nop                             null                             {Compacted,$8.dst}
        mad (1|M0)               r87.0<1>:f    r87.0<0;0>:f      r2.6<0;0>:f       -r85.1<0>:f      {F@1}
        mul (1|M0)               r2.7<1>:f     r2.6<0;1,0>:f     r85.0<0;1,0>:f   {I@2}
        mad (1|M0)               r87.0<1>:f    r2.6<0;0>:f       r2.6<0;0>:f       r87.0<0>:f       {F@2}
        mad (1|M0)               r87.1<1>:f    r85.0<0;0>:f      r2.7<0;0>:f       -r85.1<0>:f      {F@2}
(W)     and (1|M0)               f1.0<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
        mad (1|M0)               r87.1<1>:f    r2.7<0;0>:f       r87.0<0;0>:f      r87.1<0>:f       {F@1}
        add (1|M0)               r26.3<1>:d    r26.3<0;1,0>:d    -r33.2<0;1,0>:d 
        mad (1|M0)               r85.0<1>:f    r85.0<0;0>:f      r87.1<0;0>:f      -r85.1<0>:f      {F@1}
(~f1.0.any16h) goto (16|M0)                  L7720                  L7720                
L6928:
        mov (1|M0)               r35.2<1>:f    r85.0<0;1,0>:f                   {Compacted,F@1}
        mov (2|M0)               r86.0<1>:f    r87.0<1;1,0>:f                  
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r86.2         L8296                                 {A@1}
L7000:
        cmp (1|M0)    (eq)f1.1   null<1>:f     r85.0<0;1,0>:f    0.0:f              
(W)     mov (1|M0)               r1.3<1>:hf    0x1:hf                             
        add (1|M0)               r34.6<1>:d    r34.6<0;1,0>:d    125:w              
(W)     mov (1|M0)               r3.4<1>:hf    0x1:hf                             
(f1.1)  sel (1|M0)               r2.12<1>:w    r1.3<0;1,0>:w     0:w               {F@2}
        cmp (1|M0)    (lt)f0.1   null<1>:d     r34.6<0;1,0>:d    -2:w               {I@2}
        cmp (1|M0)    (ne)f1.0   null<1>:w     r2.12<0;1,0>:w    0:w               {I@2}
(W)     mov (1|M0)               r5.4<1>:hf    -qnan(0x1FF):hf                             
(f0.1)  sel (1|M0)               r3.5<1>:uw    r3.4<0;1,0>:uw    0x0:uw              {F@2}
(f1.0)  sel (1|M0)               r4.14<1>:uw   r3.4<0;1,0>:uw    0x0:uw             
        or (1|M0)     (ne)f0.1   null<1>:uw    r3.5<0;1,0>:uw    r4.14<0;1,0>:uw  {I@1}
(f0.1)  sel (1|M0)               r35.4<2>:b    r5.4<0;1,0>:w     0:w               {F@1}
        cmp (1|M0)    (ne)f0.1   null<1>:uw    r35.4<0;1,0>:ub   0x0:uw              {I@1}
(W)     and (1|M0)               f0.1<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(~f0.1.any16h) goto (16|M0)                  L7360                  L7360                
L7240:
(W)     mov (1|M0)               r1.3<1>:hf    0x1:hf                             
        and (1|M0)               r1.2<1>:d     r35.2<0;1,0>:d    -2139095041:d              
(W)     mov (1|M0)               r6.0<1>:f     0x800000:f                               {Compacted}
        shl (1|M0)               r34.7<1>:d    r34.7<0;1,0>:d    23:w              
(f1.1)  sel (1|M0)               r2.6<1>:d     r1.3<0;1,0>:w     0:w               {F@2}
        add (1|M0)               r34.7<1>:d    r34.7<0;1,0>:d    1065353216:d               {I@2}
        bfn.0xFE (1|M0)          r1.2<1>:ud    r1.2<0;0>:ud      r2.6<0;0>:ud      r6.0<0>:ud       {A@1} // s0|s1|s2
        mul (1|M0)               r34.7<1>:f    r34.7<0;1,0>:f    r1.2<0;1,0>:f    {A@1}
L7360:
        join (16|M0)                         L7720                                
L7376:
        and (1|M0)               r1.2<1>:d     r35.2<0;1,0>:d    -2147483648:d               {F@1}
        shl (1|M0)               r35.2<1>:d    r35.2<0;1,0>:d    1:w              
(W)     mov (1|M0)               r1.3<1>:hf    0x1:hf                             
        and (1|M0)               r1.3<1>:d     r35.2<0;1,0>:d    8388606:d               {I@1}
        and (1|M0)    (eq)f1.1   r35.2<1>:d    r35.2<0;1,0>:d    8388608:d              
(W)     mov (1|M0)               r3.2<1>:f     1.469368e-38:f                               {Compacted}
(f1.0)  sel (1|M0)               r2.6<1>:d     r1.3<0;1,0>:w     0:w               {F@2}
(W)     mov (1|M0)               r5.2<1>:f     0x800000:f                               {Compacted}
        or (1|M0)                r2.6<1>:d     r1.2<0;1,0>:d     r2.6<0;1,0>:d    {I@1}
(f1.1)  sel (1|M0)               r4.7<1>:d     r3.2<0;1,0>:d     12582912:d               {F@2}
        mov (1|M0)               r6.0<1>:f     0.25:f                               {Compacted}
        bfn.0xFE (1|M0)          r2.6<1>:ud    r5.2<0;0>:ud      r2.6<0;0>:ud      r1.3<0>:ud       {A@2} // s0|s1|s2
        or (1|M0)                r4.7<1>:d     r4.7<0;1,0>:d     r1.2<0;1,0>:d    {I@2}
        or (1|M0)                r2.7<1>:d     r1.2<0;1,0>:d     8388608:d              
        mad (1|M0)               r2.6<1>:f     r4.7<0;0>:f       r6.0<0;0>:f       r2.6<0>:f        {A@1}
        cmp (1|M0)    (eq)f0.1   null<1>:uw    r35.4<0;1,0>:ub   0x0:uw             
        add (1|M0)               r2.6<1>:f     r2.6<0;1,0>:f     -r2.7<0;1,0>:f   {A@1}
        mul (1|M0)               r2.7<1>:f     r2.7<0;1,0>:f     r2.7<0;1,0>:f   
        and (1|M0)    (ne)f1.1   null<1>:d     r35.0<0;1,0>:d    1:w              
        and (1|M0)               r2.7<1>:d     r2.7<0;1,0>:d     -2:w               {F@1}
        or (1|M0)                r2.7<1>:d     r2.7<0;1,0>:d     r2.6<0;1,0>:d    {I@1}
(~f0.1) mov (1|M0)               r2.7<1>:f     r34.7<0;1,0>:f                   {I@1}
(f1.1)  mov (1|M0)               r26.0<1>:f    r2.7<0;1,0>:f                    {F@1}
L7720:
        join (16|M0)                         L8064                                
L7736:
        add (1|M0)               r2.6<1>:d     r26.3<0;1,0>:d    126:w              
(W)     mov (1|M0)               r1.3<1>:uw    r35.0<0;1,0>:ub                 
        cmp (1|M0)    (gt)f1.0   null<1>:ud    r2.6<0;1,0>:ud    0x17A:uw              {I@2}
        mad (1|M0)               r85.0<1>:f    r87.1<0;0>:f      r87.0<0;0>:f      r85.0<0>:f      
        or (1|M0)                r35.3<1>:w    r34.2<0;1,0>:ub   r1.3<0;1,0>:uw   {I@2}
(W)     and (1|M0)               f0.1<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
(~f0.1.any16h) goto (16|M0)                  L7928                  L7928                
L7848:
(f1.0)  sel (1|M0)               r1.2<1>:d     r26.3<0;1,0>:d    0:w              
        asr (1|M0)               r1.2<1>:d     r1.2<0;1,0>:d     11:w               {I@1}
        add (1|M0)               r1.3<1>:d     r1.2<0;1,0>:d     248:w               {I@1}
        xor (1|M0)               r1.3<1>:d     r1.3<0;1,0>:d     r1.2<0;1,0>:d    {I@1}
(f1.0)  mov (1|M0)               r26.3<1>:f    r1.3<0;1,0>:f                    {I@1}
L7928:
        join (16|M0)                         L8064                                
L7944:
        asr (1|M0)               r1.2<1>:d     r26.3<0;1,0>:d    1:w               {F@1}
        cmp (1|M0)    (eq)f1.0   null<1>:w     r35.3<0;1,0>:w    0:w              
        add (1|M0)               r26.3<1>:d    r26.3<0;1,0>:d    -r1.2<0;1,0>:d   {I@2}
        shl (1|M0)               r1.2<1>:d     r1.2<0;1,0>:d     23:w              
        shl (1|M0)               r26.3<1>:d    r26.3<0;1,0>:d    23:w               {Compacted,I@2}
        add (1|M0)               r1.2<1>:d     r1.2<0;1,0>:d     r85.0<0;1,0>:d   {I@2}
        add (1|M0)               r26.3<1>:d    r26.3<0;1,0>:d    1065353216:d               {I@2}
(f1.0)  mul (1|M0)               r26.0<1>:f    r26.3<0;1,0>:f    r1.2<0;1,0>:f    {I@1}
L8064:
        join (16|M0)                         L8080                                
L8080:
        sync.nop                             null                             {Compacted,F@1}
        math.inv (1|M0)          r1.2<1>:f     r85.5<0;1,0>:f                   {$9}
        mov (1|M0)               r1.4<1>:ud    0x3F800000:ud                             
        mul (1|M0)               r1.3<1>:f     r1.2<0;1,0>:f     r85.4<0;1,0>:f   {$9.dst}
        mad (1|M0)               r1.4<1>:f     r1.4<0;0>:f       r1.2<0;0>:f       -r85.5<0>:f      {I@1}
        mad (1|M0)               r2.6<1>:f     r85.4<0;0>:f      r1.3<0;0>:f       -r85.5<0>:f      {F@2}
        mad (1|M0)               r1.4<1>:f     r1.2<0;0>:f       r1.2<0;0>:f       r1.4<0>:f        {F@2}
        cmp (1|M0)    (eq)f0.1   null<1>:uw    r18.28<0;1,0>:ub  0x0:uw             
        mad (1|M0)               r2.6<1>:f     r1.3<0;0>:f       r1.4<0;0>:f       r2.6<0>:f        {F@1}
        mad (1|M0)               r85.4<1>:f    r85.4<0;0>:f      r2.6<0;0>:f       -r85.5<0>:f      {F@1}
(f0.1)  mad (1|M0)               r26.0<1>:f    r2.6<0;0>:f       r1.4<0;0>:f       r85.4<0>:f       {F@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        ret (16|M0)                          r85.2                            {A@1}
L8296:
        mov (1|M0)               r1.2<1>:d     cr0.0<0;1,0>:ud                  {A@1}
        and (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   -1265:w               {A@1}
        or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   1264:w               {A@1}
        mad (1|M0)               r35.2<1>:f    r86.1<0;0>:f      r86.0<0;0>:f      r35.2<0>:f       {A@1}
        mov (1|M0)               cr0.0<1>:ud   r1.2<0;1,0>:d                    {A@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        ret (16|M0)                          r86.2                            {A@1}
L8424:
(W)     shr (16|M0)              r6.0<1>:ud    r36.0<1;1,0>:ud   0x17:uw             
(W)     and (16|M0)              r38.0<1>:w    r6.0<2;1,0>:w     255:w               {I@1}
(W)     add (16|M0)              r10.0<1>:d    r38.0<1;1,0>:uw   -191:w               {I@1}
(W)     cmp (16|M0)   (lt)f1.1   null<1>:d     r10.0<1;1,0>:ud   0xFFFFFF82:ud              {I@1}
(W)     shr (16|M0)              r8.0<1>:ud    r43.0<1;1,0>:ud   0x17:uw             
(W)     mov (1|M0)               r35.14<1>:uw  f1.1<0;1,0>:uw                   {Compacted}
(W)     and (16|M0)              r45.0<1>:w    r8.0<2;1,0>:w     255:w               {I@2}
(W)     mov (1|M0)               f1.0<1>:uw    r35.14<0;1,0>:uw                 {I@2}
(W)     add (16|M0)              r12.0<1>:d    r45.0<1;1,0>:uw   -191:w               {I@2}
(W)     mov (16|M0)              r39.0<1>:d    r38.0<1;1,0>:uw                 
(W&~f1.0) cmp (16|M0) (lt)f1.0   null<1>:d     r12.0<1;1,0>:ud   0xFFFFFF81:ud              {I@2}
(W)     mov (16|M0)              r41.0<1>:d    r38.0<1;1,0>:uw                 
(W)     mov (1|M0)               r35.14<1>:uw  f1.0<0;1,0>:uw                   {Compacted}
(W)     mov (16|M0)              r46.0<1>:d    r45.0<1;1,0>:uw                 
(W)     mov (1|M0)               f0.1<1>:uw    r35.14<0;1,0>:uw                 {A@2}
(W)     mov (16|M0)              r48.0<1>:d    r45.0<1;1,0>:uw                 
(~f0.1.any16h) goto (16|M0)                  L11208                  L11208                
L8680:
(W)     add (16|M0)              r6.0<1>:d     r38.0<1;1,0>:uw   -255:w              
(W)     cmp (16|M0)   (lt)f0.1   null<1>:d     r6.0<1;1,0>:ud    0xFFFFFF02:ud              {I@1}
(W)     add (16|M0)              r8.0<1>:d     r45.0<1;1,0>:uw   -255:w              
(W&~f0.1) cmp (16|M0) (lt)f0.1   null<1>:d     r8.0<1;1,0>:ud    0xFFFFFF02:ud              {I@1}
(W)     mov (16|M0)              r60.0<1>:f    (abs)r36.0<1;1,0>:f              {Compacted}
(f0.1.any16h) goto (16|M0)                   L8840                  L8840                
L8768:
(W)     mov (16|M0)              r6.0<1>:f     (abs)r43.0<1;1,0>:f              {Compacted}
(W)     add (16|M0)              r60.0<1>:d    r60.0<1;1,0>:d    -r6.0<1;1,0>:d   {Compacted,A@1}
(W)     mov (4|M0)               r35.3<1>:d    0:w                              
(W)     mov (16|M0)              r72.0<1>:f    r36.0<1;1,0>:f                   {Compacted}
(W)     mov (16|M0)              r62.0<1>:f    r43.0<1;1,0>:f                   {Compacted}
(W)     asr (16|M0)              r60.0<1>:d    r60.0<1;1,0>:d    23:w               {Compacted,I@2}
        goto (16|M0)                         L8840                  L10080                
L8840:
        join (16|M0)                         L10080                                
L8856:
(W)     mov (16|M0)              r58.0<1>:f    (abs)r43.0<1;1,0>:f              {Compacted}
(W)     cmp (16|M0)   (gt)f1.1   null<1>:d     r60.0<1;1,0>:ud   0x7F800000:ud              {I@3}
(W)     cmp (16|M0)   (lt)f1.0   null<1>:d     r58.0<1;1,0>:ud   0x7F800001:ud              {F@1}
(W)     and (16|M0)              r50.0<1>:ud   r36.0<1;1,0>:ud   0x7F800000:ud             
(W)     mov (1|M0)               r1.3<1>:uw    f1.1<0;1,0>:uw                  
(W)     mov (1|M0)               r2.12<1>:uw   f1.0<0;1,0>:uw                   {Compacted}
(W)     or (1|M0)                f0.0<1>:uw    f1.0<0;1,0>:uw    r1.3<0;1,0>:uw   {I@2}
(W)     cmp (16|M0)   (ne)f1.0   null<1>:d     r50.0<1;1,0>:d    2139095040:d              
(W)     or (1|M0)                r3.4<1>:uw    f1.1<0;1,0>:uw    ~r2.12<0;1,0>:uw {I@3}
(W)     mov (1|M0)               r10.0<1>:f    -0.0:f                               {Compacted}
(W)     or (1|M0)                r3.5<1>:uw    f1.0<0;1,0>:uw    r3.4<0;1,0>:uw   {I@1}
(W&f0.0) sel (16|M0)             acc0.0<1>:f   r36.0<1;1,0>:f    r43.0<1;1,0>:f  
(W)     mov (1|M0)               f0.0<1>:uw    r3.5<0;1,0>:uw                   {A@1}
(W)     and (16|M0)              r52.0<1>:ud   r43.0<1;1,0>:ud   0x7F800000:ud             
(W)     bfn.0x6A (16|M0)         r77.0<1>:ud   r36.0<1;0>:ud     r43.0<1;0>:ud     r10.0<0>:ud      // s0^s1&s2
(W)     bfn.0x6A (16|M0)         r11.0<1>:ud   r43.0<1;0>:ud     r36.0<1;0>:ud     r10.0<0>:ud      // s0^s1&s2
(W)     add (16|M0)              r77.0<1>:f    r77.0<1;1,0>:f    -r11.0<1;1,0>:f  {Compacted,A@1}
(W&f0.0) add (16|M0)             r77.0<1>:f    acc0.0<1;1,0>:f   r43.0<1;1,0>:f  
(W)     cmp (16|M0)   (ne)f0.0   null<1>:d     r52.0<1;1,0>:d    2139095040:d               {F@1}
(W)     or (1|M0)                r3.4<1>:uw    ~f1.0<0;1,0>:uw   r3.4<0;1,0>:uw  
(W)     mov (1|M0)               r2.12<1>:hf   -qnan(0x1FF):hf                             
(W)     or (1|M0)                r1.3<1>:uw    f0.0<0;1,0>:uw    r3.4<0;1,0>:uw   {I@1}
(W)     or (1|M0)                r3.4<1>:uw    ~f0.0<0;1,0>:uw   r3.4<0;1,0>:uw  
(W)     mov (1|M0)               f1.1<1>:uw    r1.3<0;1,0>:uw                   {I@2}
(W)     mov (1|M0)               f1.0<1>:uw    r3.4<0;1,0>:uw                   {I@2}
(W)     and (16|M0)              r8.0<1>:ud    r43.0<1;1,0>:ud   0x80000000:ud             
(W)     and (16|M0)              r54.0<1>:ud   r36.0<1;1,0>:ud   0x80000000:ud             
(W&f1.0) sel (16|M0)             r13.0<2>:b    r2.12<0;1,0>:w    0:w               {F@1}
(W)     cmp (16|M0)   (eq)f1.0   null<1>:f     r43.0<1;1,0>:f    0.0:f               {A@1}
(W&~f1.1) mul (16|M0)            r77.0<1>:f    r8.0<1;1,0>:f     r36.0<1;1,0>:f  
(W)     and (1|M0)               r4.14<1>:uw   f1.0<0;1,0>:uw    ~r3.4<0;1,0>:uw 
(W)     mov (16|M0)              r35.12<1>:b   r13.0<2;1,0>:b                  
(W)     mov (1|M0)               f0.0<1>:uw    r4.14<0;1,0>:uw                  {I@2}
(~f0.0) goto (16|M0)                         L9488                  L9488                
L9368:
(W)     cmp (16|M0)   (eq)f1.1   null<1>:f     r36.0<1;1,0>:f    0.0:f              
(W)     mov (1|M0)               r1.2<1>:ud    0x7F800000:ud                             
(W)     mov (1|M0)               r2.24<2>:b    -1:w                              
(W&f1.1) mov (16|M0)             r54.0<1>:ud   0:w                              
(W)     bfn.0x96 (16|M0)         r54.0<1>:ud   r1.2<0;0>:ud      r54.0<1;0>:ud     r43.0<1>:ud      {I@1} // s0^s1^s2
(W&f1.1) mul (16|M0)             r54.0<1>:f    r54.0<1;1,0>:f    r36.0<1;1,0>:f   {I@1}
        mov (16|M0)              r35.12<1>:b   r2.24<0;1,0>:b                  
        mov (16|M0)              r77.0<1>:f    r54.0<1;1,0>:f                   {Compacted,F@1}
L9488:
        join (16|M0)                         L10080                                
L9504:
(W)     cmp (16|M0)   (eq)f0.0   null<1>:f     r36.0<1;1,0>:f    0.0:f               {Compacted}
(W&f0.0) cmp (16|M0)  (eq)f0.0   null<1>:w     r35.12<1;1,0>:ub  0x0:uw              {A@1}
(W&~f0.0) sel (16|M0)            r6.0<2>:b     r35.12<1;1,0>:b   -1:w              
(W)     mov (16|M0)              r35.12<1>:b   r6.0<2;1,0>:b                    {I@1}
(W)     cmp (16|M0)   (ne)f1.1   null<1>:w     r35.12<1;1,0>:ub  0x0:uw              {I@1}
(W&f0.0) mul (16|M0)             r77.0<1>:f    r36.0<1;1,0>:f    r43.0<1;1,0>:f  
(f1.1.all16h) goto (16|M0)                   L10080                  L11208                
L9608:
(W)     cmp (16|M0)   (eq)f0.0   null<1>:w     r35.12<1;1,0>:ub  0x0:uw              {F@1}
(W)     mov (1|M0)               r1.3<1>:uw    f0.1<0;1,0>:uw                  
(W)     cmp (16|M0)   (eq)f1.0   null<1>:d     r50.0<1;1,0>:d    0:w              
(W)     and (1|M0)               f0.1<1>:uw    f0.0<0;1,0>:uw    r1.3<0;1,0>:uw   {I@2}
(W)     mov (16|M0)              r64.0<1>:d    0:w                              
(W)     mov (1|M0)               r2.12<1>:uw   f1.0<0;1,0>:uw                   {Compacted}
(W)     mov (16|M0)              r72.0<1>:f    r36.0<1;1,0>:f                   {Compacted}
(W)     and (1|M0)               f1.1<1>:uw    f0.1<0;1,0>:uw    r2.12<0;1,0>:uw  {I@1}
(W)     mov (16|M0)              r56.0<1>:f    r64.0<1;1,0>:f                   {Compacted}
(~f1.1) goto (16|M0)                         L9840                  L9840                
L9744:
        mul (16|M0)              r72.0<1>:f    r36.0<1;1,0>:f    0x4F800000:f               {Compacted}
(W)     shr (16|M0)              r6.0<1>:ud    r72.0<1;1,0>:ud   0x17:uw              {F@1}
(W)     and (16|M0)              r8.0<1>:w     r6.0<2;1,0>:w     255:w               {I@1}
        add (16|M0)              r41.0<1>:d    r8.0<1;1,0>:uw    -32:w               {I@1}
(W)     mov (16|M0)              r56.0<1>:d    0:w                              
(W)     mov (16|M0)              r39.0<1>:f    r41.0<1;1,0>:f                   {Compacted,I@2}
        mov (16|M0)              r56.0<1>:d    -32:w                              
L9840:
        join (16|M0)                         L10080                                
L9856:
(W)     cmp (16|M0)   (eq)f0.0   null<1>:d     r52.0<1;1,0>:d    0:w               {Compacted}
(W)     mov (16|M0)              r62.0<1>:f    r43.0<1;1,0>:f                   {Compacted}
(W)     mov (1|M0)               r1.3<1>:uw    f0.0<0;1,0>:uw                  
(W)     and (1|M0)               f1.0<1>:uw    f0.1<0;1,0>:uw    r1.3<0;1,0>:uw   {I@1}
(~f1.0) goto (16|M0)                         L10024                  L10024                
L9920:
        mul (16|M0)              r62.0<1>:f    r43.0<1;1,0>:f    0x4F800000:f               {Compacted}
(W)     shr (16|M0)              r6.0<1>:ud    r62.0<1;1,0>:ud   0x17:uw              {F@1}
(W)     and (16|M0)              r8.0<1>:w     r6.0<2;1,0>:w     255:w               {I@1}
        add (16|M0)              r48.0<1>:d    r8.0<1;1,0>:uw    -32:w               {I@1}
(W)     mov (16|M0)              r64.0<1>:d    0:w                              
(W)     mov (16|M0)              r58.0<1>:f    (abs)r62.0<1;1,0>:f              {Compacted}
(W)     mov (16|M0)              r46.0<1>:f    r48.0<1;1,0>:f                   {Compacted,I@2}
        mov (16|M0)              r64.0<1>:d    32:w                              
L10024:
        join (16|M0)                         L10080                                
L10040:
(W)     mov (16|M0)              r60.0<1>:f    (abs)r72.0<1;1,0>:f              {Compacted}
(W)     add (16|M0)              r60.0<1>:d    r60.0<1;1,0>:d    -r58.0<1;1,0>:d  {Compacted,F@1}
(W)     asr (16|M0)              r60.0<1>:d    r60.0<1;1,0>:d    23:w               {Compacted,I@1}
(W)     add3 (16|M0)             r64.0<1>:d    r64.0<1;0>:d      r56.0<1;0>:d      r60.0<1>:d       {I@1}
L10080:
        join (16|M0)                         L11208                                
L10096:
(W)     mov (1|M0)               r1.2<1>:f     1.0:f                               {Compacted}
(W)     mov (1|M0)               r6.0<1>:f     0x807FFFFF:f                              
(W&~f0.1) mov (16|M0)            r64.0<1>:f    r60.0<1;1,0>:f                   {I@2}
(W)     bfn.0xEA (16|M0)         r62.0<1>:ud   r1.2<0;0>:ud      r62.0<1;0>:ud     r6.0<0>:ud       {A@2} // s0|s1&s2
(W)     add (16|M0)              r66.0<1>:d    r64.0<1;1,0>:d    126:w               {Compacted,F@1}
(W)     add (16|M0)              r7.0<1>:d     -r64.0<1;1,0>:d   -152:w               {Compacted}
        sync.nop                             null                             {Compacted,I@3}
(W)     math.inv (16|M0)         r9.0<1>:f     r62.0<1;1,0>:f                   {$10}
(W)     cmp (16|M0)   (eq)f1.1   null<1>:w     r35.12<1;1,0>:ub  0x0:uw             
(W)     and (16|M0)              r7.0<1>:d     r7.0<1;1,0>:d     r66.0<1;1,0>:d   {Compacted,I@2}
(W)     mov (1|M0)               r2.6<1>:f     1.0:f                               {Compacted}
(W)     bfn.0xEA (16|M0)         r72.0<1>:ud   r1.2<0;0>:ud      r72.0<1;0>:ud     r6.0<0>:ud       // s0|s1&s2
(W)     asr (16|M0)              r7.0<1>:d     r7.0<1;1,0>:d     31:w               {Compacted,I@2}
        sync.nop                             null                             {Compacted,$10.dst}
(W)     mad (16|M0)              r68.0<1>:f    r2.6<0;0>:f       r9.0<1;0>:f       -r62.0<1>:f      {F@1}
(W)     mul (16|M0)              acc0.0<1>:f   r9.0<1;1,0>:f     r72.0<1;1,0>:f   {Compacted,I@2}
(W&f1.1) sel (16|M0)             r74.0<1>:w    r7.0<4;1,0>:ub    0:w               {I@1}
(W)     mad (16|M0)              r68.0<1>:f    r9.0<1;0>:f       r9.0<1;0>:f       r68.0<1>:f       {Compacted,F@2}
(W)     mad (16|M0)              r70.0<1>:f    r72.0<1;0>:f      acc0.0<1;0>:f     -r62.0<1>:f     
(W)     cmp (16|M0)   (ne)f1.0   null<1>:w     r74.0<2;1,0>:ub   0x0:uw              {I@1}
(W)     mad (16|M0)              r70.0<1>:f    acc0.0<1;0>:f     r68.0<1;0>:f      r70.0<1>:f       {F@1}
(W)     add (16|M0)              r39.0<1>:d    r39.0<1;1,0>:d    -r46.0<1;1,0>:d  {Compacted}
(W)     mad (16|M0)              r72.0<1>:f    r72.0<1;0>:f      r70.0<1;0>:f      -r62.0<1>:f      {Compacted,F@1}
(~f1.0.any16h) goto (16|M0)                  L10952                  L10952                
L10384:
(W)     mov (16|M0)              r83.0<1>:ud   r72.0<1;1,0>:ud                  {F@1}
(W)     mov (16|M0)              r79.0<1>:f    r68.0<1;1,0>:f                   {Compacted}
(W)     mov (16|M0)              r81.0<1>:f    r70.0<1;1,0>:f                   {Compacted}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r86.4         L11416                                 {A@1}
L10464:
(W)     add (16|M0)              r64.0<1>:d    r64.0<1;1,0>:d    125:w               {Compacted}
(W)     cmp (16|M0)   (lt)f0.0   null<1>:d     r64.0<1;1,0>:d    -2:w               {Compacted,I@1}
(W)     cmp (16|M0)   (eq)f1.1   null<1>:f     r72.0<1;1,0>:f    0.0:f              
(W)     mov (1|M0)               r1.3<1>:uw    f0.0<0;1,0>:uw                  
(W)     or (1|M0)                f1.0<1>:uw    f1.1<0;1,0>:uw    r1.3<0;1,0>:uw   {I@1}
(f1.0.any16h) goto (16|M0)                   L10592                  L10592                
L10544:
(W)     mov (1|M0)               r1.3<1>:hf    0x1:hf                              {I@2}
(W&f1.1) sel (16|M0)             r75.0<1>:d    r1.3<0;1,0>:w     0:w               {F@1}
        goto (16|M0)                         L10592                  L10712                
L10592:
        join (16|M0)                         L10712                                
L10608:
(W)     mov (1|M0)               r1.3<1>:hf    0x1:hf                              {I@3}
(W)     and (16|M0)              r6.0<1>:d     r83.0<1;1,0>:d    -2139095041:d              
(W)     mov (1|M0)               r8.0<1>:f     0x800000:f                               {Compacted}
(W)     shl (16|M0)              r66.0<1>:d    r66.0<1;1,0>:d    23:w               {Compacted}
(W&f1.1) sel (16|M0)             r75.0<1>:d    r1.3<0;1,0>:w     0:w               {F@2}
(W)     add (16|M0)              r66.0<1>:d    r66.0<1;1,0>:d    1065353216:d               {I@2}
(W)     bfn.0xFE (16|M0)         r6.0<1>:ud    r6.0<1;0>:ud      r75.0<1;0>:ud     r8.0<0>:ud       {A@1} // s0|s1|s2
(W)     mul (16|M0)              r66.0<1>:f    r66.0<1;1,0>:f    r6.0<1;1,0>:f    {Compacted,A@1}
L10712:
        join (16|M0)                         L10952                                
L10728:
(W)     and (16|M0)   (eq)f1.1   null<1>:ud    r83.0<1;1,0>:ud   0x400000:ud             
(W)     shl (16|M0)              r6.0<1>:d     r83.0<1;1,0>:d    1:w               {Compacted,F@1}
(W)     mov (1|M0)               r1.2<1>:f     0x800000:f                               {Compacted}
(W)     mov (1|M0)               r8.0<1>:f     -0.0:f                               {Compacted}
(W)     mov (1|M0)               r2.6<1>:f     1.469368e-38:f                               {Compacted}
(W)     and (16|M0)              r6.0<1>:d     r6.0<1;1,0>:d     8388606:d               {I@1}
(W)     bfn.0xEA (16|M0)         r9.0<1>:ud    r1.2<0;0>:ud      r83.0<1;0>:ud     r8.0<0>:ud       {A@2} // s0|s1&s2
(W&f1.1) sel (16|M0)             r11.0<1>:d    r2.6<0;1,0>:d     12582912:d               {F@1}
(W)     mov (1|M0)               r3.2<1>:f     0.25:f                               {Compacted}
(W)     bfn.0xFE (16|M0)         r75.0<1>:ud   r75.0<1;0>:ud     r9.0<1;0>:ud      r6.0<1>:ud       {I@2} // s0|s1|s2
(W)     bfn.0xEA (16|M0)         r11.0<1>:ud   r11.0<1;0>:ud     r83.0<1;0>:ud     r8.0<0>:ud       {I@2} // s0|s1&s2
(W)     mad (16|M0)              r75.0<1>:f    r11.0<1;0>:f      r75.0<1;0>:f      r3.2<0>:f        {Compacted,A@1}
(W)     add (16|M0)              r75.0<1>:f    r75.0<1;1,0>:f    -r9.0<1;1,0>:f   {Compacted,F@1}
(W)     mul (16|M0)              r9.0<1>:f     r9.0<1;1,0>:f     r9.0<1;1,0>:f    {Compacted}
(W)     and (16|M0)   (ne)f0.1   null<1>:w     r74.0<2;1,0>:ub   1:w              
(W)     bfn.0xAE (16|M0)         r75.0<1>:ud   r75.0<1;0>:ud     r9.0<1;0>:ud      0x1:uw              {A@1} // s0|s1&~s2
(W&~f1.0) mov (16|M0)            r66.0<1>:f    r75.0<1;1,0>:f                   {I@1}
(W&f0.1) mov (16|M0)             r77.0<1>:f    r66.0<1;1,0>:f                   {F@1}
L10952:
        join (16|M0)                         L11208                                
L10968:
(W)     add (16|M0)              r6.0<1>:d     r39.0<1;1,0>:d    -253:w               {Compacted}
(W)     cmp (16|M0)   (lt)f0.1   null<1>:d     r6.0<1;1,0>:ud    0xFFFFFE85:ud              {A@1}
(W)     mov (1|M0)               r1.3<1>:hf    -qnan(0x1FF):hf                             
(W)     asr (16|M0)              r8.0<1>:d     r39.0<1;1,0>:d    11:w               {Compacted}
(W&f0.1.any16h) sel (1|M0)       r2.12<1>:w    r1.3<0;1,0>:w     0:w               {F@1}
(W)     add (16|M0)              r10.0<1>:d    r8.0<1;1,0>:d     248:w               {Compacted,I@2}
(W)     mov (1|M0)               f0.0<1>:uw    r2.12<0;1,0>:uw                  {I@2}
(W)     mov (16|M0)              r12.0<1>:f    r39.0<1;1,0>:f                   {Compacted}
(W&f0.1) xor (16|M0)             r12.0<1>:d    r10.0<1;1,0>:d    r8.0<1;1,0>:d    {A@1}
(W&~f0.0) mov (16|M0)            r12.0<1>:f    r39.0<1;1,0>:f                   {I@1}
(W)     asr (16|M0)              r14.0<1>:d    r12.0<1;1,0>:d    1:w               {Compacted,F@1}
(W)     mov (16|M0)              r6.0<1>:uw    r35.12<1;1,0>:ub                
(W)     add (16|M0)              r12.0<1>:d    r12.0<1;1,0>:d    -r14.0<1;1,0>:d  {Compacted,I@2}
(W)     mad (16|M0)              r72.0<1>:f    r70.0<1;0>:f      r68.0<1;0>:f      r72.0<1>:f       {Compacted}
(W)     or (16|M0)    (eq)f1.1   null<1>:w     r74.0<2;1,0>:ub   r6.0<1;1,0>:uw   {I@2}
(W)     shl (16|M0)              r14.0<1>:d    r14.0<1;1,0>:d    23:w               {Compacted}
(W)     shl (16|M0)              r12.0<1>:d    r12.0<1;1,0>:d    23:w               {Compacted,I@3}
(W)     add (16|M0)              r14.0<1>:d    r14.0<1;1,0>:d    r72.0<1;1,0>:d   {Compacted,A@1}
(W)     add (16|M0)              r12.0<1>:d    r12.0<1;1,0>:d    1065353216:d               {I@2}
(W&f1.1) mul (16|M0)             r77.0<1>:f    r14.0<1;1,0>:f    r12.0<1;1,0>:f   {A@1}
L11208:
        join (16|M0)                         L11224                                
L11224:
(W)     math.inv (16|M0)         r6.0<1>:f     r43.0<1;1,0>:f                   {$11}
(W)     mov (1|M0)               r1.2<1>:ud    0x3F800000:ud                             
(W)     mul (16|M0)              acc0.0<1>:f   r6.0<1;1,0>:f     r36.0<1;1,0>:f   {Compacted,$11.dst}
(W)     mad (16|M0)              acc2.0<1>:f   r1.2<0;0>:f       r6.0<1;0>:f       -r43.0<1>:f      {I@1}
(W)     mad (16|M0)              r12.0<1>:f    r36.0<1;0>:f      acc0.0<1;0>:f     -r43.0<1>:f     
(W)     mad (16|M0)              acc2.0<1>:f   r6.0<1;0>:f       acc2.0<1;0>:f     r6.0<1>:f        {Compacted}
(W)     mov (1|M0)               f0.0<1>:uw    r35.14<0;1,0>:uw                
(W)     mad (16|M0)              acc0.0<1>:f   acc0.0<1;0>:f     acc2.0<1;0>:f     r12.0<1>:f       {F@2}
(W)     mad (16|M0)              r36.0<1>:f    r36.0<1;0>:f      acc0.0<1;0>:f     -r43.0<1>:f     
(W&~f0.0) mad (16|M0)            r77.0<1>:f    acc0.0<1;0>:f     acc2.0<1;0>:f     r36.0<1>:f       {F@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        ret (16|M0)                          r85.6                            {A@1}
L11416:
(W)     mov (1|M0)               r1.2<1>:d     cr0.0<0;1,0>:ud                  {A@1}
(W)     and (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   -1265:w               {A@1}
(W)     or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   1264:w               {A@1}
(W)     mad (16|M0)              r83.0<1>:f    r81.0<1;0>:f      r79.0<1;0>:f      r83.0<1>:f       {Compacted,A@1}
(W)     mov (1|M0)               cr0.0<1>:ud   r1.2<0;1,0>:d                    {A@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        ret (16|M0)                          r86.4                            {A@1}
L11536:
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
