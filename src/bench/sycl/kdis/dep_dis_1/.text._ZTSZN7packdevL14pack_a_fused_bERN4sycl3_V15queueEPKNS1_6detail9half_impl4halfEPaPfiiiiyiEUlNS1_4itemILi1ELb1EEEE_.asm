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
(W)     mov (2|M0)               r31.4<1>:ud   r16.2<1;1,0>:ud                 
(W)     mov (2|M0)               r31.2<1>:ud   r16.0<1;1,0>:ud                  {A@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r84.6         L4704                                 {A@1}
L472:
        mul (1|M0)               acc0.0<1>:ud  r16.4<0;1,0>:ud   r16.4<0;1,0>:uw 
        mach (1|M0)              r6.0<1>:ud    r16.4<0;1,0>:ud   r16.2<0;1,0>:ud  {AccWrEn}
        mov (1|M0)               r17.3<1>:d    r2.7<0;1,0>:d                   
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r16.4<0;1,0>:d    r16.6<0;1,0>:uw 
        mach (1|M0)              r7.0<1>:d     r16.4<0;1,0>:d    r16.3<0;1,0>:d  
(W)     mul (1|M0)               acc0.0<1>:d   r16.5<0;1,0>:d    r16.4<0;1,0>:uw 
        mach (1|M0)              r8.0<1>:d     r16.5<0;1,0>:d    r16.2<0;1,0>:d  
        subb (1|M0)              r9.0<1>:ud    r16.0<0;1,0>:ud   r5.0<0;1,0>:ud   {AccWrEn,I@5}
        add3 (1|M0)              r1.3<1>:d     r8.0<0;0>:d       r6.0<0;0>:d       r7.0<0>:d        {I@2}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r16.6<1>:d    r9.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r16.7<1>:d    r16.1<0;0>:d      -r10.0<0;0>:d     -r1.3<0>:d       {I@2}
        shr (1|M0)               r2.3<1>:ud    r16.6<0;1,0>:ud   0x7:uw              {I@2}
        shl (1|M0)               r2.4<1>:d     r16.7<0;1,0>:d    25:w               {I@2}
        mov (2|M0)               r1.2<1>:d     r17.3<1;1,0>:d                  
        or (1|M0)                r4.4<1>:d     r2.3<0;1,0>:d     r2.4<0;1,0>:d    {I@2}
        asr (1|M0)               r1.3<1>:d     r2.7<0;1,0>:d     31:w              
        mul (1|M0)               acc0.0<1>:ud  r4.4<0;1,0>:ud    r1.4<0;1,0>:uw   {I@2}
        mach (1|M0)              r7.0<1>:ud    r4.4<0;1,0>:ud    r1.2<0;1,0>:ud   {AccWrEn}
        shr (1|M0)               r4.5<1>:ud    r16.7<0;1,0>:ud   0x7:uw             
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r4.4<0;1,0>:d     r1.6<0;1,0>:uw   {I@5}
        mach (1|M0)              r8.0<1>:d     r4.4<0;1,0>:d     r1.3<0;1,0>:d   
(W)     mul (1|M0)               acc0.0<1>:d   r4.5<0;1,0>:d     r1.4<0;1,0>:uw   {I@4}
        shr (1|M0)               r4.6<1>:ud    r16.6<0;1,0>:ud   0x4:uw             
        shl (1|M0)               r4.7<1>:d     r16.7<0;1,0>:d    28:w              
        mach (1|M0)              r9.0<1>:d     r4.5<0;1,0>:d     r1.2<0;1,0>:d   
        mul (1|M0)               acc0.0<1>:ud  r16.4<0;1,0>:ud   r3.4<0;1,0>:uw  
        cmp (1|M0)    (lt)f1.1   null<1>:d     r16.6<0;1,0>:d    r3.4<0;1,0>:d   
        mach (1|M0)              r11.0<1>:ud   r16.4<0;1,0>:ud   r3.2<0;1,0>:ud   {AccWrEn}
        mov (2|M0)               r5.0<1>:w     0x7070707:v                              
        shr (1|M0)               r17.1<1>:ud   r16.7<0;1,0>:ud   0x4:uw             
        or (1|M0)                r17.0<1>:d    r4.6<0;1,0>:d     r4.7<0;1,0>:d    {I@7}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r16.4<0;1,0>:d    r3.6<0;1,0>:uw  
        and (2|M0)               r17.0<1>:d    r17.0<1;1,0>:d    r5.0<1;1,0>:w    {I@3}
        mach (1|M0)              r5.0<1>:d     r16.4<0;1,0>:d    r3.3<0;1,0>:d   
(W)     mul (1|M0)               acc0.0<1>:d   r16.5<0;1,0>:d    r3.4<0;1,0>:uw  
(W)     and (1|M0)               f0.0<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
        mach (1|M0)              r12.0<1>:d    r16.5<0;1,0>:d    r3.2<0;1,0>:d   
        addc (1|M0)              r13.0<1>:ud   r3.0<0;1,0>:ud    r10.0<0;1,0>:ud  {AccWrEn,I@7}
        add3 (1|M0)              r2.4<1>:d     r12.0<0;0>:d      r11.0<0;0>:d      r5.0<0>:d        {I@2}
        mov (1|M0)               r14.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        and (1|M0)               r17.2<1>:d    r16.6<0;1,0>:d    15:w              
        mov (1|M0)               r17.5<1>:d    r6.0<0;1,0>:d                   
        add3 (1|M0)              r17.6<1>:d    r9.0<0;0>:d       r7.0<0;0>:d       r8.0<0>:d       
        mov (1|M0)               r18.0<1>:f    r13.0<0;1,0>:f                   {Compacted,I@6}
        add3 (1|M0)              r18.1<1>:d    r14.0<0;0>:d      r3.1<0;0>:d       r2.4<0>:d        {I@4}
(f0.0.any16h) goto (16|M0)                   L1824                  L1824                
L1224:
        shl (1|M0)               r1.4<1>:d     r17.0<0;1,0>:d    9:w               {Compacted}
        cmp (1|M0)    (gt)f1.0   null<1>:d     r2.7<0;1,0>:d     0:w              
        shl (1|M0)               r1.2<1>:d     r17.1<0;1,0>:d    9:w              
        shr (1|M0)               r1.3<1>:ud    r17.0<0;1,0>:ud   0x17:uw             
        shl (1|M0)               r4.4<1>:d     r17.2<0;1,0>:d    5:w               {I@7}
        addc (1|M0)              r5.0<1>:ud    r18.0<0;1,0>:ud   r1.4<0;1,0>:ud   {AccWrEn,A@1}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@3}
(W)     and (1|M0)               f1.1<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r7.0<1>:ud    r5.0<0;1,0>:ud    r4.4<0;1,0>:ud   {AccWrEn,I@4}
        add3 (1|M0)              r2.4<1>:d     r6.0<0;0>:d       r18.1<0;0>:d      r1.5<0>:d        {I@2}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r18.2<1>:d    r7.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r18.3<1>:d    r8.0<0;0>:d       r2.4<0;0>:d       0:w               {I@2}
(~f1.1.any16h) goto (16|M0)                  L1824                  L4632                
L1440:
        mov (1|M0)               r17.4<1>:d    0:w                              
        mov (1|M0)               r18.4<2>:f    0.0:f                              
        mov (1|M0)               r18.5<2>:d    0:d                              
L1488:
        addc (1|M0)              r5.0<1>:ud    r18.4<0;1,0>:ud   r17.5<0;1,0>:ud  {AccWrEn,F@1}
        mov (4|M0)               r10.0<2>:f    0.0:f                               {$3.src}
        shl (1|M0)               r4.4<1>:d     r5.0<0;1,0>:d     12:w               {Compacted,I@1}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r7.0<1>:ud    r18.2<0;1,0>:ud   r4.4<0;1,0>:ud   {AccWrEn,I@2}
        add3 (1|M0)              r1.3<1>:d     r6.0<0;0>:d       r18.5<0;0>:d      r17.6<0>:d       {I@2}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r6.0<1>:ud    r18.4<0;1,0>:ud   0x1:ud              {AccWrEn}
        shr (1|M0)               r2.4<1>:ud    r5.0<0;1,0>:ud    0x14:uw             
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r18.6<1>:d    r6.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r18.7<1>:d    r11.0<0;0>:d      r18.5<0;0>:d      0:w               {I@2}
        shl (1|M0)               r2.3<1>:d     r1.3<0;1,0>:d     12:w               {Compacted}
        cmp (1|M0)    (eq)f0.0   null<1>:d     r18.7<0;1,0>:d    r17.4<0;1,0>:d   {I@2}
        or (1|M0)                r4.5<1>:d     r2.3<0;1,0>:d     r2.4<0;1,0>:d    {I@2}
        mov (4|M0)               r10.1<2>:f    0.0:f                              
        mov (1|M0)               r9.0<1>:f     r7.0<0;1,0>:f                    {Compacted}
(f0.0)  cmp (1|M0)    (eq)f0.0   null<1>:d     r18.6<0;1,0>:d    r17.3<0;1,0>:d  
        add3 (1|M0)              r9.1<1>:d     r8.0<0;0>:d       r18.3<0;0>:d      r4.5<0>:d        {I@2}
        send.ugm (1|M0)          null     r9      r10:1   0x0            0x0200B784           {A@1,$3} // wr:1+1, rd:0; store.ugm.d64x4t.a64
(W)     and (1|M0)               f1.0<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
(f1.0.any16h) goto (16|M0)                   L1824                  L4632                
L1792:
(W)     mov (2|M0)               r18.4<1>:ud   r18.6<1;1,0>:ud                 
        goto.b (16|M0)                       L1824                  L1488                
L1824:
        join (16|M0)                         L4632                                
L1840:
        cmp (1|M0)    (gt)f0.1   null<1>:d     r3.5<0;1,0>:d     31:w              
        asr (1|M0)               r17.7<1>:d    r3.5<0;1,0>:d     31:w              
        mov (16|M0)              r20.0<1>:f    0.0:f                               {Compacted}
(W)     and (1|M0)               f0.1<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
        shr (1|M0)               r17.7<1>:ud   r17.7<0;1,0>:ud   0x1B:uw              {I@2}
        mov (16|M0)              r22.0<1>:f    0.0:f                               {Compacted}
        add (1|M0)               r17.7<1>:d    r3.5<0;1,0>:d     r17.7<0;1,0>:d   {I@1}
(~f0.1.any16h) goto (16|M0)                  L2648                  L2648                
L1952:
        mov (1|M0)               r1.2<1>:d     r3.5<0;1,0>:d                   
        asr (1|M0)               r19.2<1>:d    r17.7<0;1,0>:d    5:w               {I@3}
        mul (1|M0)               acc0.0<1>:ud  r16.6<0;1,0>:ud   r1.4<0;1,0>:uw   {I@2}
        mach (1|M0)              r6.0<1>:ud    r16.6<0;1,0>:ud   r1.2<0;1,0>:ud   {AccWrEn}
        mov (1|M0)               r19.3<1>:d    0:w                              
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r16.7<0;1,0>:d    r1.4<0;1,0>:uw  
        mach (1|M0)              r7.0<1>:d     r16.7<0;1,0>:d    r1.2<0;1,0>:d   
        shl (1|M0)               r4.6<1>:d     r5.0<0;1,0>:d     1:w               {Compacted,I@3}
        add3 (1|M0)              r2.4<1>:d     r7.0<0;0>:d       r6.0<0;0>:d       0:w               {I@2}
        shr (1|M0)               r4.5<1>:ud    r5.0<0;1,0>:ud    0x1F:uw             
        addc (1|M0)              r8.0<1>:ud    r3.6<0;1,0>:ud    r4.6<0;1,0>:ud   {AccWrEn,I@3}
        shl (1|M0)               r4.4<1>:d     r2.4<0;1,0>:d     1:w               {I@3}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$3.src}
        or (1|M0)                r4.7<1>:d     r4.4<0;1,0>:d     r4.5<0;1,0>:d    {I@2}
        mov (1|M0)               r19.4<2>:f    0.0:f                              
        mov (1|M0)               r19.5<2>:f    0.0:f                              
        mov (1|M0)               r19.0<1>:f    r8.0<0;1,0>:f                    {Compacted}
        add3 (1|M0)              r19.1<1>:d    r9.0<0;0>:d       r3.7<0;0>:d       r4.7<0>:d        {I@1}
L2224:
        shl (1|M0)               r1.2<1>:d     r19.5<0;1,0>:d    5:w               {F@2}
        shr (1|M0)               r1.3<1>:ud    r19.4<0;1,0>:ud   0x1B:uw             
        shl (1|M0)               r1.4<1>:d     r19.4<0;1,0>:d    5:w              
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        shl (1|M0)               r4.4<1>:d     r1.4<0;1,0>:d     1:w               {I@2}
        shr (1|M0)               r2.4<1>:ud    r1.4<0;1,0>:ud    0x1F:uw             
        shl (1|M0)               r2.3<1>:d     r1.5<0;1,0>:d     1:w               {I@3}
        addc (1|M0)              r5.0<1>:ud    r19.0<0;1,0>:ud   r4.4<0;1,0>:ud   {AccWrEn,A@1}
        or (1|M0)                r4.5<1>:d     r2.3<0;1,0>:d     r2.4<0;1,0>:d    {I@2}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r7.0<1>:f     r5.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r7.1<1>:d     r6.0<0;0>:d       r19.1<0;0>:d      r4.5<0>:d        {I@1}
        addc (1|M0)              r14.0<1>:ud   r19.4<0;1,0>:ud   0x1:ud              {AccWrEn}
        send.ugm (1|M0)          r8       r7      null:0  0x0            0x0220C780           {A@1,$4} // wr:1+0, rd:2; load.ugm.d64x8t.a64
        mov (1|M0)               r15.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r19.6<1>:d    r14.0<0;1,0>:d                   {I@2}
        add3 (1|M0)              r19.7<1>:d    r15.0<0;0>:d      r19.5<0;0>:d      0:w               {I@2}
        cmp (1|M0)    (eq)f1.1   null<1>:d     r19.7<0;1,0>:d    r19.3<0;1,0>:d   {I@1}
(f1.1)  cmp (1|M0)    (eq)f1.1   null<1>:d     r19.6<0;1,0>:d    r19.2<0;1,0>:d  
(W)     and (1|M0)               f0.0<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
        mov (8|M0)               r10.0<1>:f    (abs)r8.0<1;1,0>:hf              {$4.dst}
        mov (8|M0)               r11.0<1>:f    (abs)r8.8<1;1,0>:hf             
        mov (8|M0)               r12.0<1>:f    (abs)r9.0<1;1,0>:hf             
        mov (8|M0)               r13.0<1>:f    (abs)r9.8<1;1,0>:hf             
        sel (16|M0)   (ge)f0.0   r20.0<1>:f    r20.0<1;1,0>:f    r10.0<1;1,0>:f   {Compacted,F@3}
        sel (16|M0)   (ge)f0.0   r22.0<1>:f    r22.0<1;1,0>:f    r12.0<1;1,0>:f   {Compacted,F@2}
(f0.0.any16h) goto (16|M0)                   L2648                  L2648                
L2616:
(W)     mov (2|M0)               r19.4<1>:ud   r19.6<1;1,0>:ud                 
        goto.b (16|M0)                       L2648                  L2224                
L2648:
        join (16|M0)                         L4632                                
L2664:
        sel (16|M0)   (ge)f0.0   r20.0<1>:f    r20.0<1;1,0>:f    r22.0<1;1,0>:f   {Compacted,F@1}
        sel (8|M0)    (ge)f0.0   r5.0<1>:f     r20.0<1;1,0>:f    r21.0<1;1,0>:f   {Compacted,F@1}
        mov (4|M0)               r6.0<1>:ud    r5.4<1;1,0>:ud                   {F@1}
        sel (4|M0)    (ge)f0.0   r7.0<1>:f     r5.0<1;1,0>:f     r6.0<1;1,0>:f    {I@1}
        mov (2|M0)               r8.0<1>:ud    r7.2<1;1,0>:ud                   {F@1}
        sync.nop                             null                             {Compacted,$3.src}
        sel (2|M0)    (ge)f0.0   r9.0<1>:f     r7.0<1;1,0>:f     r8.0<1;1,0>:f    {I@1}
        sel (1|M0)    (ge)f0.0   r85.0<1>:f    r9.0<0;1,0>:f     r9.1<0;1,0>:f    {F@1}
        cmp (1|M0)    (eq)f0.0   null<1>:f     r85.0<0;1,0>:f    0.0:f               {F@1}
(W)     and (1|M0)               f1.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
(f1.1.any16h) goto (16|M0)                   L2896                  L2896                
L2816:
        mov (1|M0)               r85.1<1>:f    127.0:f                              
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r85.2         L8848                                 {A@1}
L2880:
        goto (16|M0)                         L2896                  L2920                
L2896:
        join (16|M0)                         L2920                                
L2912:
        mov (1|M0)               r24.0<1>:f    1.0:f                               {Compacted}
L2920:
        join (16|M0)                         L4632                                
L2936:
        shl (1|M0)               r1.4<1>:d     r16.6<0;1,0>:d    2:w              
        mov (1|M0)               r2.3<1>:d     r3.5<0;1,0>:d                   
        addc (1|M0)              r5.0<1>:ud    r4.0<0;1,0>:ud    r1.4<0;1,0>:ud   {AccWrEn,I@2}
        asr (1|M0)               r2.4<1>:d     r3.5<0;1,0>:d     31:w              
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mul (1|M0)               acc0.0<1>:ud  r16.6<0;1,0>:ud   r2.6<0;1,0>:uw   {I@4}
        mach (1|M0)              r10.0<1>:ud   r16.6<0;1,0>:ud   r2.3<0;1,0>:ud   {AccWrEn}
        shl (1|M0)               r1.2<1>:d     r16.7<0;1,0>:d    2:w              
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        shr (1|M0)               r1.3<1>:ud    r16.6<0;1,0>:ud   0x1E:uw             
(W)     mul (1|M0)               acc0.0<1>:d   r16.6<0;1,0>:d    r2.8<0;1,0>:uw   {I@7}
        shl (1|M0)               r1.4<1>:d     r9.0<0;1,0>:d     1:w               {Compacted,I@3}
        mach (1|M0)              r7.0<1>:d     r16.6<0;1,0>:d    r2.4<0;1,0>:d   
(W)     mul (1|M0)               acc0.0<1>:d   r16.7<0;1,0>:d    r2.6<0;1,0>:uw  
        mov (1|M0)               r8.0<1>:f     r5.0<0;1,0>:f                    {Compacted}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@5}
        mach (1|M0)              r11.0<1>:d    r16.7<0;1,0>:d    r2.3<0;1,0>:d   
        addc (1|M0)              r5.0<1>:ud    r3.6<0;1,0>:ud    r1.4<0;1,0>:ud   {AccWrEn,A@1}
        add3 (1|M0)              r8.1<1>:d     r6.0<0;0>:d       r4.1<0;0>:d       r1.5<0>:d        {I@3}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mul (1|M0)               acc0.0<1>:ud  r16.4<0;1,0>:ud   r4.4<0;1,0>:uw  
        add3 (1|M0)              r4.5<1>:d     r11.0<0;0>:d      r10.0<0;0>:d      r7.0<0>:d        {I@5}
        mach (1|M0)              r13.0<1>:ud   r16.4<0;1,0>:ud   r4.2<0;1,0>:ud   {AccWrEn}
        shr (1|M0)               r1.3<1>:ud    r9.0<0;1,0>:ud    0x1F:uw             
        shl (1|M0)               r1.2<1>:d     r4.5<0;1,0>:d     1:w               {I@3}
        mov (1|M0)               r12.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
(W)     mul (1|M0)               acc0.0<1>:d   r16.4<0;1,0>:d    r4.6<0;1,0>:uw  
        shl (1|M0)               r4.6<1>:d     r12.0<0;1,0>:d    1:w               {Compacted,I@3}
        mach (1|M0)              r7.0<1>:d     r16.4<0;1,0>:d    r4.3<0;1,0>:d   
(W)     mul (1|M0)               acc0.0<1>:d   r16.5<0;1,0>:d    r4.4<0;1,0>:uw  
        send.ugm (1|M0)          null     r8      r24:1   0x0            0x04000584           {$5} // wr:2+1, rd:0; store.ugm.d32.a64
        cmp (1|M0)    (gt)f1.1   null<1>:d     r2.7<0;1,0>:d     0:w              
        shl (1|M0)               r1.4<1>:d     r17.0<0;1,0>:d    9:w               {Compacted}
        add3 (1|M0)              r5.2<1>:d     r6.0<0;0>:d       r3.7<0;0>:d       r1.5<0>:d        {I@7}
        mach (1|M0)              r8.0<1>:d     r16.5<0;1,0>:d    r4.2<0;1,0>:d    {$5.src}
        addc (1|M0)              r6.0<1>:ud    r5.0<0;1,0>:ud    r4.6<0;1,0>:ud   {AccWrEn,I@7}
        shl (1|M0)               r7.1<1>:d     r17.2<0;1,0>:d    5:w              
        shl (1|M0)               r1.2<1>:d     r17.1<0;1,0>:d    9:w              
        shr (1|M0)               r1.3<1>:ud    r17.0<0;1,0>:ud   0x17:uw             
        add3 (1|M0)              r2.4<1>:d     r8.0<0;0>:d       r13.0<0;0>:d      r7.0<0>:d        {I@5}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r7.0<1>:ud    r18.0<0;1,0>:ud   r1.4<0;1,0>:ud   {AccWrEn}
        shr (1|M0)               r4.5<1>:ud    r12.0<0;1,0>:ud   0x1F:uw             
(W)     and (1|M0)               f1.0<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@6}
        shl (1|M0)               r4.4<1>:d     r2.4<0;1,0>:d     1:w               {I@6}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r10.0<1>:ud   r7.0<0;1,0>:ud    r7.1<0;1,0>:ud   {AccWrEn,I@6}
        or (1|M0)                r4.7<1>:d     r4.4<0;1,0>:d     r4.5<0;1,0>:d    {I@3}
        add3 (1|M0)              r2.4<1>:d     r8.0<0;0>:d       r18.1<0;0>:d      r1.5<0>:d        {I@3}
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r24.1<1>:d    r6.0<0;1,0>:d                   
        mov (1|M0)               r24.3<1>:d    r10.0<0;1,0>:d                   {I@5}
        add3 (1|M0)              r24.2<1>:d    r9.0<0;0>:d       r5.2<0;0>:d       r4.7<0>:d        {I@5}
        add3 (1|M0)              r24.4<1>:d    r11.0<0;0>:d      r2.4<0;0>:d       0:w               {I@4}
(~f1.0.any16h) goto (16|M0)                  L4632                  L4632                
L3760:
        mov (16|M0)              r25.0<1>:f    r24.0<0;1,0>:f                   {Compacted}
        mov (1|M0)               r17.4<1>:d    0:w                              
        mov (1|M0)               r24.6<2>:d    0:d                              
        mov (1|M0)               r24.7<2>:d    0:d                              
L3816:
        shl (1|M0)               r1.2<1>:d     r24.7<0;1,0>:d    5:w               {I@1}
        shr (1|M0)               r1.3<1>:ud    r24.6<0;1,0>:ud   0x1B:uw             
        shl (1|M0)               r1.4<1>:d     r24.6<0;1,0>:d    5:w              
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        shl (1|M0)               r4.4<1>:d     r1.4<0;1,0>:d     1:w               {I@2}
        shr (1|M0)               r2.4<1>:ud    r1.4<0;1,0>:ud    0x1F:uw             
        shl (1|M0)               r2.3<1>:d     r1.5<0;1,0>:d     1:w               {I@3}
        addc (1|M0)              r5.0<1>:ud    r24.1<0;1,0>:ud   r4.4<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r4.5<1>:d     r2.3<0;1,0>:d     r2.4<0;1,0>:d    {I@2}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r7.0<1>:f     r5.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r7.1<1>:d     r6.0<0;0>:d       r24.2<0;0>:d      r4.5<0>:d        {I@1}
        mov (16|M0)              r40.0<1>:f    r25.0<1;1,0>:f                   {Compacted,F@2}
        send.ugm (1|M0)          r8       r7      null:0  0x0            0x0220C780           {A@1,$7} // wr:1+0, rd:2; load.ugm.d64x8t.a64
        mov (8|M0)               r33.0<1>:f    r8.0<1;1,0>:hf                   {$7.dst}
        mov (8|M0)               r34.0<1>:f    r8.8<1;1,0>:hf                  
        mov (8|M0)               r27.0<1>:f    r9.0<1;1,0>:hf                  
        mov (8|M0)               r28.0<1>:f    r9.8<1;1,0>:hf                  
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r85.4         L5696                                 {A@1}
L4128:
        mov (16|M0)              r29.0<1>:ud   r75.0<1;1,0>:ud                 
        mov (16|M0)              r33.0<1>:f    r27.0<1;1,0>:f                   {Compacted,F@1}
        mov (16|M0)              r40.0<1>:f    r25.0<1;1,0>:f                   {Compacted}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r85.4         L5696                                 {A@1}
L4208:
        addc (1|M0)              r5.0<1>:ud    r24.6<0;1,0>:ud   r17.5<0;1,0>:ud  {AccWrEn}
        rnde (16|M0)             r29.0<1>:f    r29.0<1;1,0>:f                   {Compacted,I@3}
        shl (1|M0)               r4.4<1>:d     r5.0<0;1,0>:d     12:w               {Compacted,I@1}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r7.0<1>:ud    r24.3<0;1,0>:ud   r4.4<0;1,0>:ud   {AccWrEn,I@2}
        add3 (1|M0)              r1.3<1>:d     r6.0<0;0>:d       r24.7<0;0>:d      r17.6<0>:d       {I@2}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r6.0<1>:ud    r24.6<0;1,0>:ud   0x1:ud              {AccWrEn}
        shr (1|M0)               r2.4<1>:ud    r5.0<0;1,0>:ud    0x14:uw             
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        rnde (16|M0)             r75.0<1>:f    r75.0<1;1,0>:f                   {Compacted}
        add3 (1|M0)              r31.1<1>:d    r5.0<0;0>:d       r24.7<0;0>:d      0:w               {I@1}
        mov (1|M0)               r31.0<1>:f    r6.0<0;1,0>:f                    {Compacted}
        cmp (1|M0)    (eq)f1.0   null<1>:d     r31.1<0;1,0>:d    r17.4<0;1,0>:d   {I@1}
        sel (16|M0)   (ge)f0.0   r29.0<1>:f    r29.0<1;1,0>:f    -127.0:f               {F@3}
        sel (16|M0)   (ge)f0.0   r75.0<1>:f    r75.0<1;1,0>:f    -127.0:f               {F@3}
(f1.0)  cmp (1|M0)    (eq)f1.0   null<1>:d     r31.0<0;1,0>:d    r17.3<0;1,0>:d   {F@3}
        shl (1|M0)               r2.3<1>:d     r1.3<0;1,0>:d     12:w               {Compacted}
        sel (16|M0)   (lt)f0.0   r29.0<1>:f    r29.0<1;1,0>:f    127.0:f               {F@2}
        sel (16|M0)   (lt)f0.0   r75.0<1>:f    r75.0<1;1,0>:f    127.0:f               {F@2}
        or (1|M0)                r4.5<1>:d     r2.3<0;1,0>:d     r2.4<0;1,0>:d    {I@1}
        mov (16|M0)              r10.0<1>:d    r29.0<1;1,0>:f                   {Compacted,F@2}
(W)     and (1|M0)               f0.1<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
        mov (16|M0)              r12.0<1>:d    r75.0<1;1,0>:f                   {Compacted,F@1}
        mov (1|M0)               r9.0<1>:f     r7.0<0;1,0>:f                    {Compacted}
        add3 (1|M0)              r9.1<1>:d     r8.0<0;0>:d       r24.4<0;0>:d      r4.5<0>:d        {I@4}
        mov (16|M0)              r14.0<1>:b    r10.0<4;1,0>:b                   {I@4}
        mov (16|M0)              r14.16<1>:b   r12.0<4;1,0>:b                   {I@3}
        send.ugm (1|M0)          null     r9      r14:1   0x0            0x0200B784           {A@1,$6} // wr:1+1, rd:0; store.ugm.d64x4t.a64
(f0.1.any16h) goto (16|M0)                   L4632                  L4632                
L4600:
(W)     mov (2|M0)               r24.6<1>:ud   r31.0<1;1,0>:ud                 
        goto.b (16|M0)                       L4632                  L3816                
L4632:
        join (16|M0)                         L4648                                
L4648:
(W)     mov (8|M0)               r127.0<1>:f   r0.0<1;1,0>:f                    {Compacted}
(W)     send.ugm (1|M0)          r5       r0      null:0  0x0            0x0210641F           {$8} // wr:1+0, rd:1; fence invalid flush type scoped to tile
(W)     mov (8|M0)               null<1>:ud    r5.0<1;1,0>:ud                   {$8.dst}
(W)     send.gtwy (1|M0)         null     r127    null:0  0x0            0x02000010           {EOT,A@1} // wr:1+0, rd:0; end of thread
L4704:
        mov (2|M0)               r32.0<1>:d    0x1:v                              
        mov (1|M0)               r31.6<2>:f    0.0:f                              
        mov (1|M0)               r31.7<2>:f    0.0:f                              
        mov (1|M0)               r32.2<2>:f    0.0:f                              
        mov (1|M0)               r32.3<2>:d    0:d                              
        mov (1|M0)               r24.5<1>:d    63:w                              
L4800:
        and (1|M0)    (eq)f0.0   r2.3<1>:d     r24.5<0;1,0>:d    63:w               {I@1}
(W)     mov (1|M0)               r2.10<1>:hf   0.0:hf                             
        mov (1|M0)               r1.3<1>:d     0:w                              
        shr (1|M0)               r5.2<1>:ud    r32.2<0;1,0>:ud   0x1F:uw              {F@2}
        cmp (1|M0)    (ge)f0.1   null<1>:ud    r2.3<0;1,0>:ud    0x20:uw              {I@3}
(f0.0)  sel (1|M0)               r4.5<1>:d     r2.10<0;1,0>:w    -1:w               {F@1}
        add (1|M0)               r2.4<1>:d     -r2.3<0;1,0>:d    32:w              
        add (1|M0)               r4.7<1>:d     r2.3<0;1,0>:d     -32:w              
        and (1|M0)               r4.6<1>:d     r31.3<0;1,0>:d    r4.5<0;1,0>:d    {I@3}
        shr (1|M0)               r1.2<1>:ud    r31.2<0;1,0>:ud   r2.3<0;1,0>:ud  
(f0.1)  sel (1|M0)               r4.4<1>:d     r2.10<0;1,0>:w    -1:w              
        shr (1|M0)               r4.7<1>:ud    r31.3<0;1,0>:ud   r4.7<0;1,0>:ud   {I@4}
        shl (1|M0)               r4.6<1>:d     r4.6<0;1,0>:d     r2.4<0;1,0>:d    {I@4}
        shr (1|M0)               r1.3<1>:ud    r31.3<0;1,0>:ud   r2.3<0;1,0>:ud  
        shl (1|M0)               r2.5<1>:d     r32.3<0;1,0>:d    1:w              
        and (1|M0)               r1.2<1>:ud    r1.2<0;1,0>:ud    r4.4<0;1,0>:ud   {I@5}
        and (1|M0)               r4.7<1>:ud    r4.7<0;1,0>:ud    ~r4.4<0;1,0>:ud  {I@5}
        and (1|M0)               r4.6<1>:d     r4.6<0;1,0>:d     r4.4<0;1,0>:d    {I@5}
        shl (1|M0)               r6.0<1>:d     r32.2<0;1,0>:d    1:w               {Compacted}
        and (1|M0)               r5.1<1>:ud    r1.3<0;1,0>:ud    r4.4<0;1,0>:ud   {I@6}
        or (1|M0)                r6.1<1>:d     r2.5<0;1,0>:d     r5.2<0;1,0>:d    {I@6}
        bfn.0xFE (1|M0)          r5.0<1>:ud    r4.7<0;0>:ud      r1.2<0;0>:ud      r4.6<0>:ud       {I@4} // s0|s1|s2
(W)     mov (1|M0)               r1.3<1>:hf    0x1:hf                             
        bfn.0xEA (2|M0)          r6.0<1>:ud    r6.0<1;0>:ud      r5.0<1;0>:ud      r32.0<1>:ud      {I@1} // s0|s1&s2
        and (1|M0)               r4.5<1>:d     r4.5<0;1,0>:d     1:w              
        cmp (1|M0)    (lt)f0.1   null<1>:ud    r6.0<0;1,0>:ud    r31.4<0;1,0>:ud  {I@2}
        cmp (1|M0)    (lt)f1.1   null<1>:ud    r6.1<0;1,0>:ud    r31.5<0;1,0>:ud 
(W)     mov (1|M0)               r2.10<1>:hf   0x1:hf                             
        cmp (1|M0)    (eq)f1.0   null<1>:d     r24.5<0;1,0>:d    0:w              
(f0.1)  cmp (1|M0)    (eq)f0.1   null<1>:d     r6.1<0;1,0>:d     r31.5<0;1,0>:d  
(f1.1)  sel (1|M0)               r1.5<1>:uw    r1.3<0;1,0>:uw    0x0:uw              {F@2}
        shl (1|M0)               r2.3<1>:ud    r1.3<0;1,0>:uw    r2.3<0;1,0>:ud  
        subb (1|M0)              r7.0<1>:ud    r6.0<0;1,0>:ud    r31.4<0;1,0>:ud  {AccWrEn}
(f0.1)  sel (1|M0)               r1.4<1>:uw    r1.3<0;1,0>:uw    0x0:uw             
        shr (1|M0)               r4.5<1>:ud    r4.5<0;1,0>:ud    r2.4<0;1,0>:ud   {I@7}
        shl (1|M0)               r4.6<1>:d     r2.10<0;1,0>:w    -r2.4<0;1,0>:d   {F@1}
        or (1|M0)     (ne)f0.0   null<1>:uw    r1.4<0;1,0>:uw    r1.5<0;1,0>:uw   {I@3}
        and (1|M0)               r16.4<1>:ud   r2.3<0;1,0>:ud    r4.4<0;1,0>:ud  
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        bfn.0xCA (1|M0)          r16.5<1>:ud   r4.6<0;0>:ud      r4.5<0;0>:ud      r4.4<0>:ud       {I@4} // s0&~s2|s1&s2
        mov (1|M0)               r32.2<1>:d    r7.0<0;1,0>:d                   
        add3 (1|M0)              r32.3<1>:d    r6.1<0;0>:d       -r8.0<0;0>:d      -r31.5<0>:d      {I@3}
(f0.0)  mov (1|M0)               r32.2<1>:d    r6.0<0;1,0>:d                   
        or (2|M0)                r16.4<1>:d    r16.4<1;1,0>:d    r31.6<1;1,0>:d   {I@4}
(f0.0)  mov (1|M0)               r32.3<1>:d    r6.1<0;1,0>:d                   
(f0.0)  mov (1|M0)               r16.4<1>:d    r31.6<0;1,0>:d                  
(f0.0)  mov (1|M0)               r16.5<1>:d    r31.7<0;1,0>:d                  
(W)     and (1|M0)               f0.0<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
        add (1|M0)               r32.4<1>:d    r24.5<0;1,0>:d    -1:w              
(f0.0.any16h) goto (16|M0)                   L5632                  L5632                
L5584:
(W)     mov (2|M0)               r31.6<1>:ud   r16.4<1;1,0>:ud                  {I@4}
        mov (1|M0)               r24.5<1>:d    r32.4<0;1,0>:d                   {I@3}
        goto.b (16|M0)                       L5632                  L4800                
L5632:
        join (16|M0)                         L5648                                
L5648:
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        ret (16|M0)                          r84.6                            {A@1}
L5696:
(W)     shr (16|M0)              r5.0<1>:ud    r33.0<1;1,0>:ud   0x17:uw             
(W)     and (16|M0)              r35.0<1>:w    r5.0<2;1,0>:w     255:w               {I@1}
(W)     add (16|M0)              r9.0<1>:d     r35.0<1;1,0>:uw   -191:w               {I@1}
(W)     cmp (16|M0)   (lt)f1.0   null<1>:d     r9.0<1;1,0>:ud    0xFFFFFF82:ud              {I@1}
(W)     shr (16|M0)              r7.0<1>:ud    r40.0<1;1,0>:ud   0x17:uw             
(W)     mov (1|M0)               r84.5<1>:uw   f1.0<0;1,0>:uw                  
(W)     and (16|M0)              r42.0<1>:w    r7.0<2;1,0>:w     255:w               {I@2}
(W)     mov (1|M0)               f0.1<1>:uw    r84.5<0;1,0>:uw                  {I@2}
(W)     add (16|M0)              r11.0<1>:d    r42.0<1;1,0>:uw   -191:w               {I@2}
(W)     mov (16|M0)              r36.0<1>:d    r35.0<1;1,0>:uw                 
(W&~f0.1) cmp (16|M0) (lt)f0.1   null<1>:d     r11.0<1;1,0>:ud   0xFFFFFF81:ud              {I@2}
(W)     mov (16|M0)              r38.0<1>:d    r35.0<1;1,0>:uw                 
(W)     mov (1|M0)               r84.5<1>:uw   f0.1<0;1,0>:uw                  
(W)     mov (16|M0)              r43.0<1>:d    r42.0<1;1,0>:uw                 
(W)     mov (1|M0)               f0.0<1>:uw    r84.5<0;1,0>:uw                  {I@2}
(W)     mov (16|M0)              r45.0<1>:d    r42.0<1;1,0>:uw                 
(~f0.0.any16h) goto (16|M0)                  L8520                  L8520                
L5968:
(W)     add (16|M0)              r5.0<1>:d     r35.0<1;1,0>:uw   -255:w              
(W)     cmp (16|M0)   (lt)f0.0   null<1>:d     r5.0<1;1,0>:ud    0xFFFFFF02:ud              {I@1}
(W)     add (16|M0)              r7.0<1>:d     r42.0<1;1,0>:uw   -255:w              
(W&~f0.0) cmp (16|M0) (lt)f0.0   null<1>:d     r7.0<1;1,0>:ud    0xFFFFFF02:ud              {I@1}
(W)     mov (16|M0)              r57.0<1>:f    (abs)r33.0<1;1,0>:f              {Compacted}
(f0.0.any16h) goto (16|M0)                   L6128                  L6128                
L6056:
(W)     mov (16|M0)              r5.0<1>:f     (abs)r40.0<1;1,0>:f              {Compacted}
(W)     add (16|M0)              r57.0<1>:d    r57.0<1;1,0>:d    -r5.0<1;1,0>:d   {Compacted,A@1}
(W)     mov (4|M0)               r61.0<1>:d    0:w                              
(W)     mov (16|M0)              r70.0<1>:f    r33.0<1;1,0>:f                   {Compacted}
(W)     mov (16|M0)              r59.0<1>:f    r40.0<1;1,0>:f                   {Compacted}
(W)     asr (16|M0)              r57.0<1>:d    r57.0<1;1,0>:d    23:w               {Compacted,I@2}
        goto (16|M0)                         L6128                  L7384                
L6128:
        join (16|M0)                         L7384                                
L6144:
(W)     mov (16|M0)              r55.0<1>:f    (abs)r40.0<1;1,0>:f              {Compacted}
(W)     cmp (16|M0)   (gt)f1.1   null<1>:d     r57.0<1;1,0>:ud   0x7F800000:ud              {I@3}
(W)     cmp (16|M0)   (lt)f1.0   null<1>:d     r55.0<1;1,0>:ud   0x7F800001:ud              {F@1}
(W)     and (16|M0)              r47.0<1>:ud   r33.0<1;1,0>:ud   0x7F800000:ud             
(W)     mov (1|M0)               r1.3<1>:uw    f1.1<0;1,0>:uw                  
(W)     mov (1|M0)               r2.6<1>:uw    f1.0<0;1,0>:uw                   {Compacted}
(W)     or (1|M0)                f0.1<1>:uw    f1.0<0;1,0>:uw    r1.3<0;1,0>:uw   {I@2}
(W)     cmp (16|M0)   (ne)f1.0   null<1>:d     r47.0<1;1,0>:d    2139095040:d              
(W)     or (1|M0)                r4.8<1>:uw    f1.1<0;1,0>:uw    ~r2.6<0;1,0>:uw  {I@3}
(W)     mov (1|M0)               r9.0<1>:f     -0.0:f                               {Compacted}
(W)     or (1|M0)                r4.9<1>:uw    f1.0<0;1,0>:uw    r4.8<0;1,0>:uw   {I@1}
(W&f0.1) sel (16|M0)             acc0.0<1>:f   r33.0<1;1,0>:f    r40.0<1;1,0>:f  
(W)     mov (1|M0)               f0.1<1>:uw    r4.9<0;1,0>:uw                   {A@1}
(W)     and (16|M0)              r49.0<1>:ud   r40.0<1;1,0>:ud   0x7F800000:ud             
(W)     bfn.0x6A (16|M0)         r75.0<1>:ud   r33.0<1;0>:ud     r40.0<1;0>:ud     r9.0<0>:ud       // s0^s1&s2
(W)     bfn.0x6A (16|M0)         r10.0<1>:ud   r40.0<1;0>:ud     r33.0<1;0>:ud     r9.0<0>:ud       // s0^s1&s2
(W)     add (16|M0)              r75.0<1>:f    r75.0<1;1,0>:f    -r10.0<1;1,0>:f  {Compacted,A@1}
(W&f0.1) add (16|M0)             r75.0<1>:f    acc0.0<1;1,0>:f   r40.0<1;1,0>:f  
(W)     cmp (16|M0)   (ne)f0.1   null<1>:d     r49.0<1;1,0>:d    2139095040:d               {F@1}
(W)     or (1|M0)                r4.8<1>:uw    ~f1.0<0;1,0>:uw   r4.8<0;1,0>:uw  
(W)     mov (1|M0)               r2.6<1>:hf    -qnan(0x1FF):hf                             
(W)     or (1|M0)                r1.3<1>:uw    f0.1<0;1,0>:uw    r4.8<0;1,0>:uw   {I@1}
(W)     or (1|M0)                r4.8<1>:uw    ~f0.1<0;1,0>:uw   r4.8<0;1,0>:uw  
(W)     mov (1|M0)               f1.1<1>:uw    r1.3<0;1,0>:uw                   {I@2}
(W)     mov (1|M0)               f1.0<1>:uw    r4.8<0;1,0>:uw                   {I@2}
(W)     and (16|M0)              r7.0<1>:ud    r40.0<1;1,0>:ud   0x80000000:ud             
(W)     and (16|M0)              r51.0<1>:ud   r33.0<1;1,0>:ud   0x80000000:ud             
(W&f1.0) sel (16|M0)             r12.0<2>:b    r2.6<0;1,0>:w     0:w               {F@1}
(W)     cmp (16|M0)   (eq)f1.0   null<1>:f     r40.0<1;1,0>:f    0.0:f               {A@1}
(W&~f1.1) mul (16|M0)            r75.0<1>:f    r7.0<1;1,0>:f     r33.0<1;1,0>:f  
(W)     and (1|M0)               r5.0<1>:uw    f1.0<0;1,0>:uw    ~r4.8<0;1,0>:uw 
(W)     mov (16|M0)              r61.0<1>:b    r12.0<2;1,0>:b                  
(W)     mov (1|M0)               f0.1<1>:uw    r5.0<0;1,0>:uw                   {I@2}
(~f0.1) goto (16|M0)                         L6776                  L6776                
L6656:
(W)     cmp (16|M0)   (eq)f1.1   null<1>:f     r33.0<1;1,0>:f    0.0:f              
(W)     mov (1|M0)               r1.2<1>:ud    0x7F800000:ud                             
(W)     mov (1|M0)               r2.12<2>:b    -1:w                              
(W&f1.1) mov (16|M0)             r51.0<1>:ud   0:w                              
(W)     bfn.0x96 (16|M0)         r51.0<1>:ud   r1.2<0;0>:ud      r51.0<1;0>:ud     r40.0<1>:ud      {I@1} // s0^s1^s2
(W&f1.1) mul (16|M0)             r51.0<1>:f    r51.0<1;1,0>:f    r33.0<1;1,0>:f   {I@1}
        mov (16|M0)              r61.0<1>:b    r2.12<0;1,0>:b                  
        mov (16|M0)              r75.0<1>:f    r51.0<1;1,0>:f                   {Compacted,F@1}
L6776:
        join (16|M0)                         L7384                                
L6792:
(W)     cmp (16|M0)   (eq)f0.1   null<1>:f     r33.0<1;1,0>:f    0.0:f              
(W&f0.1) cmp (16|M0)  (eq)f0.1   null<1>:w     r61.0<1;1,0>:ub   0x0:uw              {A@1}
(W&~f0.1) sel (16|M0)            r5.0<2>:b     r61.0<1;1,0>:b    -1:w              
(W)     mov (16|M0)              r61.0<1>:b    r5.0<2;1,0>:b                    {I@1}
(W)     cmp (16|M0)   (ne)f1.1   null<1>:w     r61.0<1;1,0>:ub   0x0:uw              {I@1}
(W&f0.1) mul (16|M0)             r75.0<1>:f    r33.0<1;1,0>:f    r40.0<1;1,0>:f  
(f1.1.all16h) goto (16|M0)                   L7384                  L8520                
L6904:
(W)     cmp (16|M0)   (eq)f0.1   null<1>:w     r61.0<1;1,0>:ub   0x0:uw              {F@1}
(W)     mov (1|M0)               r1.3<1>:uw    f0.0<0;1,0>:uw                  
(W)     cmp (16|M0)   (eq)f1.0   null<1>:d     r47.0<1;1,0>:d    0:w              
(W)     and (1|M0)               f0.0<1>:uw    f0.1<0;1,0>:uw    r1.3<0;1,0>:uw   {I@2}
(W)     mov (16|M0)              r62.0<1>:d    0:w                              
(W)     mov (1|M0)               r2.6<1>:uw    f1.0<0;1,0>:uw                   {Compacted}
(W)     mov (16|M0)              r70.0<1>:f    r33.0<1;1,0>:f                   {Compacted}
(W)     and (1|M0)               f1.1<1>:uw    f0.0<0;1,0>:uw    r2.6<0;1,0>:uw   {I@1}
(W)     mov (16|M0)              r53.0<1>:f    r62.0<1;1,0>:f                   {Compacted}
(~f1.1) goto (16|M0)                         L7136                  L7136                
L7040:
        mul (16|M0)              r70.0<1>:f    r33.0<1;1,0>:f    0x4F800000:f               {Compacted}
(W)     shr (16|M0)              r5.0<1>:ud    r70.0<1;1,0>:ud   0x17:uw              {F@1}
(W)     and (16|M0)              r7.0<1>:w     r5.0<2;1,0>:w     255:w               {I@1}
        add (16|M0)              r38.0<1>:d    r7.0<1;1,0>:uw    -32:w               {I@1}
(W)     mov (16|M0)              r53.0<1>:d    0:w                              
(W)     mov (16|M0)              r36.0<1>:f    r38.0<1;1,0>:f                   {Compacted,I@2}
        mov (16|M0)              r53.0<1>:d    -32:w                              
L7136:
        join (16|M0)                         L7384                                
L7152:
(W)     cmp (16|M0)   (eq)f0.1   null<1>:d     r49.0<1;1,0>:d    0:w              
(W)     mov (16|M0)              r59.0<1>:f    r40.0<1;1,0>:f                   {Compacted}
(W)     mov (1|M0)               r1.3<1>:uw    f0.1<0;1,0>:uw                  
(W)     and (1|M0)               f1.0<1>:uw    f0.0<0;1,0>:uw    r1.3<0;1,0>:uw   {I@1}
(~f1.0) goto (16|M0)                         L7328                  L7328                
L7224:
        mul (16|M0)              r59.0<1>:f    r40.0<1;1,0>:f    0x4F800000:f               {Compacted}
(W)     shr (16|M0)              r5.0<1>:ud    r59.0<1;1,0>:ud   0x17:uw              {F@1}
(W)     and (16|M0)              r7.0<1>:w     r5.0<2;1,0>:w     255:w               {I@1}
        add (16|M0)              r45.0<1>:d    r7.0<1;1,0>:uw    -32:w               {I@1}
(W)     mov (16|M0)              r62.0<1>:d    0:w                              
(W)     mov (16|M0)              r55.0<1>:f    (abs)r59.0<1;1,0>:f              {Compacted}
(W)     mov (16|M0)              r43.0<1>:f    r45.0<1;1,0>:f                   {Compacted,I@2}
        mov (16|M0)              r62.0<1>:d    32:w                              
L7328:
        join (16|M0)                         L7384                                
L7344:
(W)     mov (16|M0)              r57.0<1>:f    (abs)r70.0<1;1,0>:f              {Compacted}
(W)     add (16|M0)              r57.0<1>:d    r57.0<1;1,0>:d    -r55.0<1;1,0>:d  {Compacted,F@1}
(W)     asr (16|M0)              r57.0<1>:d    r57.0<1;1,0>:d    23:w               {Compacted,I@1}
(W)     add3 (16|M0)             r62.0<1>:d    r62.0<1;0>:d      r53.0<1;0>:d      r57.0<1>:d       {I@1}
L7384:
        join (16|M0)                         L8520                                
L7400:
(W)     mov (1|M0)               r1.2<1>:f     1.0:f                               {Compacted}
(W)     mov (1|M0)               r5.0<1>:f     0x807FFFFF:f                              
(W&~f0.0) mov (16|M0)            r62.0<1>:f    r57.0<1;1,0>:f                   {I@2}
(W)     bfn.0xEA (16|M0)         r59.0<1>:ud   r1.2<0;0>:ud      r59.0<1;0>:ud     r5.0<0>:ud       {A@2} // s0|s1&s2
(W)     add (16|M0)              r64.0<1>:d    r62.0<1;1,0>:d    126:w               {Compacted,F@1}
(W)     add (16|M0)              r6.0<1>:d     -r62.0<1;1,0>:d   -152:w               {Compacted}
        sync.nop                             null                             {Compacted,I@3}
(W)     math.inv (16|M0)         r8.0<1>:f     r59.0<1;1,0>:f                   {$9}
(W)     cmp (16|M0)   (eq)f0.0   null<1>:w     r61.0<1;1,0>:ub   0x0:uw             
(W)     and (16|M0)              r6.0<1>:d     r6.0<1;1,0>:d     r64.0<1;1,0>:d   {Compacted,I@2}
(W)     mov (1|M0)               r2.3<1>:f     1.0:f                               {Compacted}
(W)     bfn.0xEA (16|M0)         r70.0<1>:ud   r1.2<0;0>:ud      r70.0<1;0>:ud     r5.0<0>:ud       // s0|s1&s2
(W)     asr (16|M0)              r6.0<1>:d     r6.0<1;1,0>:d     31:w               {Compacted,I@2}
        sync.nop                             null                             {Compacted,$9.dst}
(W)     mad (16|M0)              r66.0<1>:f    r2.3<0;0>:f       r8.0<1;0>:f       -r59.0<1>:f      {F@1}
(W)     mul (16|M0)              acc0.0<1>:f   r8.0<1;1,0>:f     r70.0<1;1,0>:f   {Compacted,I@2}
(W&f0.0) sel (16|M0)             r72.0<1>:w    r6.0<4;1,0>:ub    0:w               {I@1}
(W)     mad (16|M0)              r66.0<1>:f    r8.0<1;0>:f       r8.0<1;0>:f       r66.0<1>:f       {Compacted,F@2}
(W)     mad (16|M0)              r68.0<1>:f    r70.0<1;0>:f      acc0.0<1;0>:f     -r59.0<1>:f     
(W)     cmp (16|M0)   (ne)f1.1   null<1>:w     r72.0<2;1,0>:ub   0x0:uw              {I@1}
(W)     mad (16|M0)              r68.0<1>:f    acc0.0<1;0>:f     r66.0<1;0>:f      r68.0<1>:f       {F@1}
(W)     add (16|M0)              r36.0<1>:d    r36.0<1;1,0>:d    -r43.0<1;1,0>:d  {Compacted}
(W)     mad (16|M0)              r70.0<1>:f    r70.0<1;0>:f      r68.0<1;0>:f      -r59.0<1>:f      {Compacted,F@1}
(~f1.1.any16h) goto (16|M0)                  L8264                  L8264                
L7688:
(W)     mov (16|M0)              r81.0<1>:ud   r70.0<1;1,0>:ud                  {F@1}
(W)     mov (16|M0)              r77.0<1>:f    r66.0<1;1,0>:f                   {Compacted}
(W)     mov (16|M0)              r79.0<1>:f    r68.0<1;1,0>:f                   {Compacted}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r85.6         L8728                                 {A@1}
L7768:
(W)     add (16|M0)              r62.0<1>:d    r62.0<1;1,0>:d    125:w               {Compacted}
(W)     cmp (16|M0)   (lt)f0.1   null<1>:d     r62.0<1;1,0>:d    -2:w               {I@1}
(W)     cmp (16|M0)   (eq)f1.0   null<1>:f     r70.0<1;1,0>:f    0.0:f              
(W)     mov (1|M0)               r1.3<1>:uw    f0.1<0;1,0>:uw                  
(W)     or (1|M0)                f1.1<1>:uw    f1.0<0;1,0>:uw    r1.3<0;1,0>:uw   {I@1}
(f1.1.any16h) goto (16|M0)                   L7904                  L7904                
L7856:
(W)     mov (1|M0)               r1.3<1>:hf    0x1:hf                              {I@2}
(W&f1.0) sel (16|M0)             r73.0<1>:d    r1.3<0;1,0>:w     0:w               {F@1}
        goto (16|M0)                         L7904                  L8024                
L7904:
        join (16|M0)                         L8024                                
L7920:
(W)     mov (1|M0)               r1.3<1>:hf    0x1:hf                              {I@3}
(W)     and (16|M0)              r5.0<1>:d     r81.0<1;1,0>:d    -2139095041:d              
(W)     mov (1|M0)               r7.0<1>:f     0x800000:f                               {Compacted}
(W)     shl (16|M0)              r64.0<1>:d    r64.0<1;1,0>:d    23:w               {Compacted}
(W&f1.0) sel (16|M0)             r73.0<1>:d    r1.3<0;1,0>:w     0:w               {F@2}
(W)     add (16|M0)              r64.0<1>:d    r64.0<1;1,0>:d    1065353216:d               {I@2}
(W)     bfn.0xFE (16|M0)         r5.0<1>:ud    r5.0<1;0>:ud      r73.0<1;0>:ud     r7.0<0>:ud       {A@1} // s0|s1|s2
(W)     mul (16|M0)              r64.0<1>:f    r64.0<1;1,0>:f    r5.0<1;1,0>:f    {Compacted,A@1}
L8024:
        join (16|M0)                         L8264                                
L8040:
(W)     and (16|M0)   (eq)f0.0   null<1>:ud    r81.0<1;1,0>:ud   0x400000:ud             
(W)     shl (16|M0)              r5.0<1>:d     r81.0<1;1,0>:d    1:w               {Compacted,F@1}
(W)     mov (1|M0)               r1.2<1>:f     0x800000:f                               {Compacted}
(W)     mov (1|M0)               r7.0<1>:f     -0.0:f                               {Compacted}
(W)     mov (1|M0)               r2.3<1>:f     1.469368e-38:f                               {Compacted}
(W)     and (16|M0)              r5.0<1>:d     r5.0<1;1,0>:d     8388606:d               {I@1}
(W)     bfn.0xEA (16|M0)         r8.0<1>:ud    r1.2<0;0>:ud      r81.0<1;0>:ud     r7.0<0>:ud       {A@2} // s0|s1&s2
(W&f0.0) sel (16|M0)             r10.0<1>:d    r2.3<0;1,0>:d     12582912:d               {F@1}
(W)     mov (1|M0)               r4.4<1>:f     0.25:f                               {Compacted}
(W)     bfn.0xFE (16|M0)         r73.0<1>:ud   r73.0<1;0>:ud     r8.0<1;0>:ud      r5.0<1>:ud       {I@2} // s0|s1|s2
(W)     bfn.0xEA (16|M0)         r10.0<1>:ud   r10.0<1;0>:ud     r81.0<1;0>:ud     r7.0<0>:ud       {I@2} // s0|s1&s2
(W)     mad (16|M0)              r73.0<1>:f    r10.0<1;0>:f      r73.0<1;0>:f      r4.4<0>:f        {Compacted,A@1}
(W)     add (16|M0)              r73.0<1>:f    r73.0<1;1,0>:f    -r8.0<1;1,0>:f   {Compacted,F@1}
(W)     mul (16|M0)              r8.0<1>:f     r8.0<1;1,0>:f     r8.0<1;1,0>:f    {Compacted}
(W)     and (16|M0)   (ne)f1.0   null<1>:w     r72.0<2;1,0>:ub   1:w              
(W)     bfn.0xAE (16|M0)         r73.0<1>:ud   r73.0<1;0>:ud     r8.0<1;0>:ud      0x1:uw              {A@1} // s0|s1&~s2
(W&~f1.1) mov (16|M0)            r64.0<1>:f    r73.0<1;1,0>:f                   {I@1}
(W&f1.0) mov (16|M0)             r75.0<1>:f    r64.0<1;1,0>:f                   {F@1}
L8264:
        join (16|M0)                         L8520                                
L8280:
(W)     add (16|M0)              r5.0<1>:d     r36.0<1;1,0>:d    -253:w               {Compacted}
(W)     cmp (16|M0)   (lt)f1.1   null<1>:d     r5.0<1;1,0>:ud    0xFFFFFE85:ud              {I@1}
(W)     mov (1|M0)               r1.3<1>:hf    -qnan(0x1FF):hf                             
(W)     asr (16|M0)              r7.0<1>:d     r36.0<1;1,0>:d    11:w               {Compacted}
(W&f1.1.any16h) sel (1|M0)       r2.6<1>:w     r1.3<0;1,0>:w     0:w               {F@1}
(W)     add (16|M0)              r9.0<1>:d     r7.0<1;1,0>:d     248:w               {Compacted,I@2}
(W)     mov (1|M0)               f0.1<1>:uw    r2.6<0;1,0>:uw                   {I@2}
(W)     mov (16|M0)              r11.0<1>:f    r36.0<1;1,0>:f                   {Compacted}
(W&f1.1) xor (16|M0)             r11.0<1>:d    r9.0<1;1,0>:d     r7.0<1;1,0>:d    {A@1}
(W&~f0.1) mov (16|M0)            r11.0<1>:f    r36.0<1;1,0>:f                   {I@1}
(W)     asr (16|M0)              r13.0<1>:d    r11.0<1;1,0>:d    1:w               {Compacted,F@1}
(W)     mov (16|M0)              r5.0<1>:uw    r61.0<1;1,0>:ub                 
(W)     add (16|M0)              r11.0<1>:d    r11.0<1;1,0>:d    -r13.0<1;1,0>:d  {Compacted,I@2}
(W)     mad (16|M0)              r70.0<1>:f    r68.0<1;0>:f      r66.0<1;0>:f      r70.0<1>:f       {Compacted}
(W)     or (16|M0)    (eq)f0.0   null<1>:w     r72.0<2;1,0>:ub   r5.0<1;1,0>:uw   {I@2}
(W)     shl (16|M0)              r13.0<1>:d    r13.0<1;1,0>:d    23:w               {Compacted}
(W)     shl (16|M0)              r11.0<1>:d    r11.0<1;1,0>:d    23:w               {Compacted,I@3}
(W)     add (16|M0)              r13.0<1>:d    r13.0<1;1,0>:d    r70.0<1;1,0>:d   {Compacted,A@1}
(W)     add (16|M0)              r11.0<1>:d    r11.0<1;1,0>:d    1065353216:d               {I@2}
(W&f0.0) mul (16|M0)             r75.0<1>:f    r13.0<1;1,0>:f    r11.0<1;1,0>:f   {A@1}
L8520:
        join (16|M0)                         L8536                                
L8536:
(W)     math.inv (16|M0)         r5.0<1>:f     r40.0<1;1,0>:f                   {$10}
(W)     mov (1|M0)               r1.2<1>:ud    0x3F800000:ud                             
(W)     mul (16|M0)              acc0.0<1>:f   r5.0<1;1,0>:f     r33.0<1;1,0>:f   {Compacted,$10.dst}
(W)     mad (16|M0)              acc2.0<1>:f   r1.2<0;0>:f       r5.0<1;0>:f       -r40.0<1>:f      {I@1}
(W)     mad (16|M0)              r11.0<1>:f    r33.0<1;0>:f      acc0.0<1;0>:f     -r40.0<1>:f     
(W)     mad (16|M0)              acc2.0<1>:f   r5.0<1;0>:f       acc2.0<1;0>:f     r5.0<1>:f        {Compacted}
(W)     mov (1|M0)               f1.1<1>:uw    r84.5<0;1,0>:uw                 
(W)     mad (16|M0)              acc0.0<1>:f   acc0.0<1;0>:f     acc2.0<1;0>:f     r11.0<1>:f       {F@2}
(W)     mad (16|M0)              r33.0<1>:f    r33.0<1;0>:f      acc0.0<1;0>:f     -r40.0<1>:f     
(W&~f1.1) mad (16|M0)            r75.0<1>:f    acc0.0<1;0>:f     acc2.0<1;0>:f     r33.0<1>:f       {F@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        ret (16|M0)                          r85.4                            {A@1}
L8728:
(W)     mov (1|M0)               r1.2<1>:d     cr0.0<0;1,0>:ud                  {A@1}
(W)     and (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   -1265:w               {A@1}
(W)     or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   1264:w               {A@1}
(W)     mad (16|M0)              r81.0<1>:f    r79.0<1;0>:f      r77.0<1;0>:f      r81.0<1>:f       {Compacted,A@1}
(W)     mov (1|M0)               cr0.0<1>:ud   r1.2<0;1,0>:d                    {A@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        ret (16|M0)                          r85.6                            {A@1}
L8848:
        shr (1|M0)               r32.7<1>:ud   r85.1<0;1,0>:ud   0x17:uw             
        shr (1|M0)               r32.6<1>:ud   r85.0<0;1,0>:ud   0x17:uw             
        and (1|M0)               r32.7<1>:ud   r32.7<0;1,0>:ud   0xFF:uw              {I@2}
        and (1|M0)               r32.6<1>:ud   r32.6<0;1,0>:ud   0xFF:uw              {I@2}
        add (1|M0)               r1.3<1>:ud    r32.7<0;1,0>:ud   0xFFFFFF41:ud              {I@2}
        add (1|M0)               r1.2<1>:ud    r32.6<0;1,0>:ud   0xFFFFFF41:ud              {I@2}
        cmp (1|M0)    (lt)f0.1   null<1>:ud    r1.3<0;1,0>:ud    0xFFFFFF81:ud              {I@2}
(W)     mov (1|M0)               r2.6<1>:hf    -qnan(0x1FF):hf                             
(~f0.1) cmp (1|M0)    (lt)f0.1   null<1>:ud    r1.2<0;1,0>:ud    0xFFFFFF82:ud              {I@2}
(f0.1)  sel (1|M0)               r32.20<2>:b   r2.6<0;1,0>:w     0:w               {F@1}
        cmp (1|M0)    (ne)f1.1   null<1>:uw    r32.20<0;1,0>:ub  0x0:uw              {I@1}
(W)     and (1|M0)               f1.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(~f1.1.any16h) goto (16|M0)                  L12512                  L12512                
L9056:
        add (1|M0)               r1.3<1>:ud    r32.7<0;1,0>:ud   0xFFFFFF01:ud             
        add (1|M0)               r1.2<1>:ud    r32.6<0;1,0>:ud   0xFFFFFF01:ud             
        cmp (1|M0)    (lt)f0.0   null<1>:ud    r1.3<0;1,0>:ud    0xFFFFFF02:ud              {I@2}
(W)     mov (1|M0)               r2.6<1>:hf    -qnan(0x1FF):hf                             
        mov (1|M0)               r83.7<1>:f    (abs)r85.0<0;1,0>:f              {Compacted}
(~f0.0) cmp (1|M0)    (lt)f0.0   null<1>:ud    r1.2<0;1,0>:ud    0xFFFFFF02:ud              {I@2}
(f0.0)  sel (1|M0)               r32.22<2>:b   r2.6<0;1,0>:w     0:w               {F@2}
        cmp (1|M0)    (ne)f1.0   null<1>:uw    r32.22<0;1,0>:ub  0x0:uw              {I@1}
(W)     and (1|M0)               f1.0<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
(f1.0.any16h) goto (16|M0)                   L9304                  L9304                
L9208:
        mov (1|M0)               r1.2<1>:f     (abs)r85.1<0;1,0>:f             
        mov (1|M0)               r83.20<2>:b   0:w                              
        add (1|M0)               r83.7<1>:d    r83.7<0;1,0>:d    -r1.2<0;1,0>:d   {A@1}
        mov (2|M0)               r84.4<1>:d    r85.0<1;1,0>:ud                 
        asr (1|M0)               r83.7<1>:d    r83.7<0;1,0>:d    23:w               {I@2}
        goto (16|M0)                         L9304                  L11008                
L9304:
        join (16|M0)                         L11008                                
L9320:
        cmp (1|M0)    (gt)f0.1   null<1>:ud    r83.7<0;1,0>:ud   0x7F800000:ud              {I@3}
(W)     mov (1|M0)               r1.3<1>:hf    0xFF:hf                             
        mov (1|M0)               r83.4<1>:f    (abs)r85.1<0;1,0>:f             
(W)     mov (1|M0)               r2.7<1>:hf    -qnan(0x1FF):hf                             
(f0.1)  sel (1|M0)               r2.6<1>:w     r1.3<0;1,0>:w     0:w               {F@3}
        add (1|M0)               r24.0<1>:f    r85.0<0;1,0>:f    r85.1<0;1,0>:f   {Compacted}
        cmp (1|M0)    (eq)f1.1   null<1>:w     r2.12<0;1,0>:b    0:w               {I@1}
(W)     mov (1|M0)               r4.8<1>:uw    r2.12<0;1,0>:ub                 
        and (1|M0)               r61.5<1>:ud   r85.0<0;1,0>:ud   0x7F800000:ud             
(W)     mov (1|M0)               r6.0<1>:f     -0.0:f                               {Compacted}
(f1.1)  cmp (1|M0)    (gt)f1.1   null<1>:ud    r83.4<0;1,0>:ud   0x7F800000:ud              {F@4}
        bfn.0x6A (1|M0)          r1.2<1>:ud    r85.0<0;0>:ud     r85.1<0;0>:ud     r6.0<0>:ud       {F@1} // s0^s1&s2
        bfn.0x6A (1|M0)          r1.3<1>:ud    r85.1<0;0>:ud     r85.0<0;0>:ud     r6.0<0>:ud       // s0^s1&s2
        and (1|M0)               r61.6<1>:ud   r85.1<0;1,0>:ud   0x7F800000:ud             
(f1.1)  sel (1|M0)               r2.16<2>:b    r2.7<0;1,0>:w     0:w              
        and (1|M0)               r5.0<1>:ud    r85.1<0;1,0>:ud   0x80000000:ud             
        and (1|M0)    (ne)f1.0   null<1>:w     r2.16<0;1,0>:ub   1:w               {I@2}
        and (1|M0)               r61.4<1>:ud   r85.0<0;1,0>:ud   0x80000000:ud             
(f1.0)  add (1|M0)               r24.0<1>:f    r85.1<0;1,0>:f    r85.1<0;1,0>:f  
        or (1|M0)     (eq)f1.0   r2.16<2>:ub   r2.16<0;1,0>:ub   r4.8<0;1,0>:uw   {F@1}
(f1.0)  cmp (1|M0)    (eq)f1.0   null<1>:d     r61.5<0;1,0>:d    2139095040:d              
(W)     mov (1|M0)               r5.2<1>:uw    r2.16<0;1,0>:ub                  {I@2}
(f1.0)  sel (1|M0)               r1.6<2>:b     r2.7<0;1,0>:w     0:w              
        and (1|M0)    (ne)f0.1   null<1>:w     r1.6<0;1,0>:ub    1:w               {I@1}
(f0.1)  add (1|M0)               r24.0<1>:f    r1.2<0;1,0>:f     -r1.3<0;1,0>:f  
        or (1|M0)     (eq)f0.1   r1.6<2>:ub    r1.6<0;1,0>:ub    r5.2<0;1,0>:uw   {F@1}
(f0.1)  cmp (1|M0)    (eq)f0.1   null<1>:d     r61.6<0;1,0>:d    2139095040:d              
(W)     mov (1|M0)               r4.8<1>:uw    r1.6<0;1,0>:ub                   {I@2}
(f0.1)  sel (1|M0)               r83.0<2>:b    r2.7<0;1,0>:w     0:w              
        and (1|M0)    (ne)f0.0   null<1>:w     r83.0<0;1,0>:ub   1:w               {I@1}
(f0.0)  mul (1|M0)               r24.0<1>:f    r5.0<0;1,0>:f     r85.0<0;1,0>:f  
        or (1|M0)     (eq)f0.0   r83.0<2>:ub   r83.0<0;1,0>:ub   r4.8<0;1,0>:uw   {F@1}
(f0.0)  cmp (1|M0)    (eq)f0.0   null<1>:f     r85.1<0;1,0>:f    0.0:f               {I@1}
(f0.0)  sel (1|M0)               r61.28<2>:b   r2.7<0;1,0>:w     0:w              
        cmp (1|M0)    (ne)f1.1   null<1>:uw    r61.28<0;1,0>:ub  0x0:uw              {I@1}
(W)     and (1|M0)               f0.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(f0.1.any16h) goto (16|M0)                   L9928                  L9928                
L9896:
        mov (1|M0)               r83.2<2>:b    r83.0<0;1,0>:b                  
        goto (16|M0)                         L9928                  L10112                
L9928:
        join (16|M0)                         L10112                                
L9944:
(W)     mov (1|M0)               r5.0<1>:f     inf:f                               {Compacted}
        cmp (1|M0)    (eq)f1.0   null<1>:f     r85.0<0;1,0>:f    0.0:f              
        bfn.0x96 (1|M0)          r61.4<1>:ud   r61.4<0;0>:ud     r85.1<0;0>:ud     r5.0<0>:ud       {F@2} // s0^s1^s2
        xor (1|M0)               r1.2<1>:ud    r85.1<0;1,0>:ud   0x7F800000:ud             
(W)     mov (1|M0)               r2.6<1>:uw    r83.0<0;1,0>:ub                 
(~f1.0) mov (1|M0)               r1.2<1>:f     r61.4<0;1,0>:f                   {A@2}
        or (1|M0)                r83.0<2>:ub   r61.28<0;1,0>:ub  r2.6<0;1,0>:uw   {I@1}
(f1.0)  mul (1|M0)               r61.4<1>:f    r1.2<0;1,0>:f     r85.0<0;1,0>:f   {F@1}
        and (1|M0)    (ne)f1.0   null<1>:w     r61.28<0;1,0>:ub  1:w               {F@1}
        mov (1|M0)               r83.2<2>:b    r83.0<0;1,0>:b                   {I@2}
(f1.0)  mov (1|M0)               r24.0<1>:f    r61.4<0;1,0>:f                  
L10112:
        join (16|M0)                         L11008                                
L10128:
        cmp (1|M0)    (eq)f1.1   null<1>:w     r83.0<0;1,0>:b    0:w              
(W)     mov (1|M0)               r1.3<1>:hf    -qnan(0x1FF):hf                             
(W)     mov (1|M0)               r2.6<1>:uw    r83.2<0;1,0>:ub                  {I@3}
(f1.1)  cmp (1|M0)    (eq)f1.1   null<1>:f     r85.0<0;1,0>:f    0.0:f               {I@2}
(f1.1)  sel (1|M0)               r83.20<2>:b   r1.3<0;1,0>:w     0:w               {F@2}
        and (1|M0)    (ne)f0.1   null<1>:w     r83.20<0;1,0>:ub  1:w               {I@1}
        or (1|M0)     (ne)f0.0   r83.20<2>:ub  r83.20<0;1,0>:ub  r2.6<0;1,0>:uw  
(f0.1)  mul (1|M0)               r24.0<1>:f    r85.0<0;1,0>:f    r85.1<0;1,0>:f  
(W)     and (1|M0)               f0.0<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
(f0.0.any16h) goto (16|M0)                   L11008                  L12512                
L10288:
        cmp (1|M0)    (eq)f1.1   null<1>:uw    r83.20<0;1,0>:ub  0x0:uw              {A@2}
        cmp (1|M0)    (eq)f1.0   null<1>:d     r61.5<0;1,0>:d    0:w              
(~f1.1) mov (1|M0)               r32.22<2>:b   0:w                              
(f1.0)  sel (1|M0)               r83.1<1>:d    r32.22<0;1,0>:b   0:w               {I@1}
        cmp (1|M0)    (ne)f0.1   null<1>:d     r83.1<0;1,0>:d    0:w               {A@1}
(W)     and (1|M0)               f1.1<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(f1.1.any16h) goto (16|M0)                   L10440                  L10440                
L10400:
        mov (1|M0)               r83.2<1>:d    0:w                              
        mov (1|M0)               r84.4<1>:f    r85.0<0;1,0>:f                   {Compacted}
        goto (16|M0)                         L10440                  L10592                
L10440:
        join (16|M0)                         L10592                                
L10456:
        and (1|M0)    (ne)f1.0   r83.1<1>:d    r83.1<0;1,0>:d    1:w              
        mov (1|M0)               r84.4<1>:f    r85.0<0;1,0>:f                   {Compacted}
(W)     mov (1|M0)               r2.6<1>:hf    -qnan(0x1E0):hf                             
(f1.0)  mul (1|M0)               r84.4<1>:f    r85.0<0;1,0>:f    0x4F800000:f              
(f1.0)  sel (1|M0)               r83.2<1>:d    r2.6<0;1,0>:w     0:w               {F@2}
        shr (1|M0)               r1.2<1>:ud    r84.4<0;1,0>:ud   0x17:uw              {F@1}
        and (1|M0)               r1.2<1>:ud    r1.2<0;1,0>:ud    0xFF:uw              {I@1}
        add (1|M0)               r1.2<1>:ud    r1.2<0;1,0>:ud    0xFFFFFFE0:ud              {I@1}
(f1.0)  mov (1|M0)               r32.6<1>:d    r1.2<0;1,0>:d                    {I@1}
L10592:
        join (16|M0)                         L11008                                
L10608:
        cmp (1|M0)    (eq)f0.0   null<1>:d     r61.6<0;1,0>:d    0:w              
(f0.0)  sel (1|M0)               r83.3<1>:d    r32.22<0;1,0>:b   0:w              
        cmp (1|M0)    (ne)f1.1   null<1>:d     r83.3<0;1,0>:d    0:w               {I@1}
(W)     and (1|M0)               f1.0<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(f1.0.any16h) goto (16|M0)                   L10736                  L10736                
L10688:
        mov (1|M0)               r83.6<1>:d    0:w                              
        mov (1|M0)               r84.5<1>:d    r85.1<0;1,0>:ud                 
        goto (16|M0)                         L10736                  L10912                
L10736:
        join (16|M0)                         L10912                                
L10752:
        and (1|M0)    (ne)f0.1   r83.3<1>:d    r83.3<0;1,0>:d    1:w              
        mov (1|M0)               r84.5<1>:f    r85.1<0;1,0>:f                   {I@4}
(W)     mov (1|M0)               r2.6<1>:hf    0x20:hf                             
(f0.1)  mul (1|M0)               r84.5<1>:f    r85.1<0;1,0>:f    0x4F800000:f              
(f0.1)  sel (1|M0)               r83.6<1>:d    r2.6<0;1,0>:w     0:w               {F@2}
        shr (1|M0)               r1.2<1>:ud    r84.5<0;1,0>:ud   0x17:uw              {F@1}
        mov (1|M0)               r83.4<1>:f    (abs)r84.5<0;1,0>:f             
        and (1|M0)               r1.2<1>:ud    r1.2<0;1,0>:ud    0xFF:uw              {I@1}
        add (1|M0)               r1.2<1>:ud    r1.2<0;1,0>:ud    0xFFFFFFE0:ud              {I@1}
(f0.1)  mov (1|M0)               r32.7<1>:d    r1.2<0;1,0>:d                    {I@1}
L10912:
        join (16|M0)                         L11008                                
L10928:
        mov (1|M0)               r83.7<1>:f    (abs)r84.4<0;1,0>:f             
        add (1|M0)               r83.6<1>:d    r83.6<0;1,0>:d    r83.2<0;1,0>:d  
        add (1|M0)               r83.7<1>:d    r83.7<0;1,0>:d    -r83.4<0;1,0>:d  {F@1}
        asr (1|M0)               r83.7<1>:d    r83.7<0;1,0>:d    23:w               {I@1}
        add (1|M0)               r83.6<1>:d    r83.6<0;1,0>:d    r83.7<0;1,0>:d   {I@1}
L11008:
        join (16|M0)                         L12512                                
L11024:
        cmp (1|M0)    (eq)f1.0   null<1>:uw    r32.22<0;1,0>:ub  0x0:uw             
(W)     mov (1|M0)               r1.2<1>:f     1.0:f                               {Compacted}
(W)     mov (1|M0)               r5.0<1>:f     0x807FFFFF:f                              
        cmp (1|M0)    (eq)f0.1   null<1>:w     r83.20<0;1,0>:b   0:w              
(~f1.0) mov (1|M0)               r83.7<1>:d    r83.6<0;1,0>:d                   {I@4}
        bfn.0xEA (1|M0)          r84.5<1>:ud   r1.2<0;0>:ud      r84.5<0;0>:ud     r5.0<0>:ud       {A@1} // s0|s1&s2
        add (1|M0)               r84.0<1>:d    r83.7<0;1,0>:d    126:w               {Compacted,I@2}
        add (1|M0)               r84.1<1>:d    -r83.7<0;1,0>:d   -152:w              
        sync.nop                             null                             {Compacted,I@3}
        math.inv (1|M0)          r2.3<1>:f     r84.5<0;1,0>:f                   {$11}
        and (1|M0)               r84.1<1>:d    r84.1<0;1,0>:d    r84.0<0;1,0>:d   {Compacted,I@1}
        mov (1|M0)               r87.0<1>:f    1.0:f                               {Compacted}
        asr (1|M0)               r84.1<1>:d    r84.1<0;1,0>:d    31:w               {Compacted,I@1}
(~f0.1) mov (1|M0)               r84.1<1>:d    0:w                              
        bfn.0xEA (1|M0)          r84.4<1>:ud   r1.2<0;0>:ud      r84.4<0;0>:ud     r5.0<0>:ud       // s0|s1&s2
        cmp (1|M0)    (ne)f0.0   null<1>:d     r84.1<0;1,0>:d    0:w               {I@2}
        sync.nop                             null                             {Compacted,$11.dst}
        mad (1|M0)               r87.0<1>:f    r87.0<0;0>:f      r2.3<0;0>:f       -r84.5<0>:f      {F@1}
        mul (1|M0)               r2.4<1>:f     r2.3<0;1,0>:f     r84.4<0;1,0>:f   {I@2}
        mad (1|M0)               r87.0<1>:f    r2.3<0;0>:f       r2.3<0;0>:f       r87.0<0>:f       {F@2}
        mad (1|M0)               r87.1<1>:f    r84.4<0;0>:f      r2.4<0;0>:f       -r84.5<0>:f      {F@2}
(W)     and (1|M0)               f0.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
        mad (1|M0)               r87.1<1>:f    r2.4<0;0>:f       r87.0<0;0>:f      r87.1<0>:f       {F@1}
        add (1|M0)               r32.6<1>:d    r32.6<0;1,0>:d    -r32.7<0;1,0>:d 
        mad (1|M0)               r84.4<1>:f    r84.4<0;0>:f      r87.1<0;0>:f      -r84.5<0>:f      {F@1}
(~f0.1.any16h) goto (16|M0)                  L12160                  L12160                
L11384:
        mov (1|M0)               r84.3<1>:f    r84.4<0;1,0>:f                   {F@1}
        mov (2|M0)               r86.0<1>:f    r87.0<1;1,0>:f                  
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r86.2         L12744                                 {A@1}
L11464:
        cmp (1|M0)    (eq)f1.0   null<1>:f     r84.4<0;1,0>:f    0.0:f              
(W)     mov (1|M0)               r1.3<1>:hf    0x1:hf                             
        add (1|M0)               r83.7<1>:d    r83.7<0;1,0>:d    125:w              
(W)     mov (1|M0)               r4.8<1>:hf    0x1:hf                             
(f1.0)  sel (1|M0)               r2.6<1>:w     r1.3<0;1,0>:w     0:w               {F@2}
        cmp (1|M0)    (lt)f0.0   null<1>:d     r83.7<0;1,0>:d    -2:w               {I@2}
        cmp (1|M0)    (ne)f0.1   null<1>:w     r2.6<0;1,0>:w     0:w               {I@2}
(W)     mov (1|M0)               r6.0<1>:hf    -qnan(0x1FF):hf                             
(f0.0)  sel (1|M0)               r4.9<1>:uw    r4.8<0;1,0>:uw    0x0:uw              {F@2}
(f0.1)  sel (1|M0)               r5.0<1>:uw    r4.8<0;1,0>:uw    0x0:uw             
        or (1|M0)     (ne)f1.1   null<1>:uw    r4.9<0;1,0>:uw    r5.0<0;1,0>:uw   {I@1}
(f1.1)  sel (1|M0)               r83.22<2>:b   r6.0<0;1,0>:w     0:w               {F@1}
        cmp (1|M0)    (ne)f1.1   null<1>:uw    r83.22<0;1,0>:ub  0x0:uw              {I@1}
(W)     and (1|M0)               f0.0<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(~f0.0.any16h) goto (16|M0)                  L11808                  L11808                
L11704:
(W)     mov (1|M0)               r1.3<1>:hf    0x1:hf                             
        and (1|M0)               r1.2<1>:d     r84.3<0;1,0>:d    -2139095041:d              
(W)     mov (1|M0)               r5.0<1>:f     0x800000:f                               {Compacted}
        shl (1|M0)               r84.0<1>:d    r84.0<0;1,0>:d    23:w               {Compacted}
(f1.0)  sel (1|M0)               r2.3<1>:d     r1.3<0;1,0>:w     0:w               {F@2}
        add (1|M0)               r84.0<1>:d    r84.0<0;1,0>:d    1065353216:d               {I@2}
        bfn.0xFE (1|M0)          r1.2<1>:ud    r1.2<0;0>:ud      r2.3<0;0>:ud      r5.0<0>:ud       {A@1} // s0|s1|s2
        mul (1|M0)               r84.0<1>:f    r84.0<0;1,0>:f    r1.2<0;1,0>:f    {Compacted,A@1}
L11808:
        join (16|M0)                         L12160                                
L11824:
        and (1|M0)               r1.2<1>:d     r84.3<0;1,0>:d    -2147483648:d               {F@1}
        shl (1|M0)               r84.3<1>:d    r84.3<0;1,0>:d    1:w               {Compacted}
(W)     mov (1|M0)               r1.3<1>:hf    0x1:hf                             
        and (1|M0)               r1.3<1>:d     r84.3<0;1,0>:d    8388606:d               {I@1}
        and (1|M0)    (eq)f0.0   r84.3<1>:d    r84.3<0;1,0>:d    8388608:d              
(W)     mov (1|M0)               r2.5<1>:f     1.469368e-38:f                               {Compacted}
(f0.1)  sel (1|M0)               r2.3<1>:d     r1.3<0;1,0>:w     0:w               {F@2}
(W)     mov (1|M0)               r4.5<1>:f     0x800000:f                               {Compacted}
        or (1|M0)                r2.3<1>:d     r1.2<0;1,0>:d     r2.3<0;1,0>:d    {I@1}
(f0.0)  sel (1|M0)               r4.4<1>:d     r2.5<0;1,0>:d     12582912:d               {F@2}
        mov (1|M0)               r5.0<1>:f     0.25:f                               {Compacted}
        bfn.0xFE (1|M0)          r2.3<1>:ud    r4.5<0;0>:ud      r2.3<0;0>:ud      r1.3<0>:ud       {A@2} // s0|s1|s2
        or (1|M0)                r4.4<1>:d     r4.4<0;1,0>:d     r1.2<0;1,0>:d    {I@2}
        or (1|M0)                r2.4<1>:d     r1.2<0;1,0>:d     8388608:d              
        mad (1|M0)               r2.3<1>:f     r4.4<0;0>:f       r5.0<0;0>:f       r2.3<0>:f        {A@1}
        cmp (1|M0)    (eq)f0.0   null<1>:uw    r83.22<0;1,0>:ub  0x0:uw             
        add (1|M0)               r2.3<1>:f     r2.3<0;1,0>:f     -r2.4<0;1,0>:f   {A@1}
        mul (1|M0)               r2.4<1>:f     r2.4<0;1,0>:f     r2.4<0;1,0>:f   
        and (1|M0)    (ne)f1.1   null<1>:d     r84.1<0;1,0>:d    1:w              
        and (1|M0)               r2.4<1>:d     r2.4<0;1,0>:d     -2:w               {F@1}
        or (1|M0)                r2.4<1>:d     r2.4<0;1,0>:d     r2.3<0;1,0>:d    {I@1}
(~f0.0) mov (1|M0)               r2.4<1>:f     r84.0<0;1,0>:f                   {I@1}
(f1.1)  mov (1|M0)               r24.0<1>:f    r2.4<0;1,0>:f                    {F@1}
L12160:
        join (16|M0)                         L12512                                
L12176:
        add (1|M0)               r2.3<1>:d     r32.6<0;1,0>:d    126:w              
(W)     mov (1|M0)               r1.3<1>:uw    r84.4<0;1,0>:ub                 
        cmp (1|M0)    (gt)f0.0   null<1>:ud    r2.3<0;1,0>:ud    0x17A:uw              {I@2}
        mad (1|M0)               r84.4<1>:f    r87.1<0;0>:f      r87.0<0;0>:f      r84.4<0>:f      
        or (1|M0)                r84.4<1>:w    r83.20<0;1,0>:ub  r1.3<0;1,0>:uw   {I@2}
(W)     and (1|M0)               f1.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw              {F@2}
(~f1.1.any16h) goto (16|M0)                  L12368                  L12368                
L12288:
(f0.0)  sel (1|M0)               r1.2<1>:d     r32.6<0;1,0>:d    0:w              
        asr (1|M0)               r1.2<1>:d     r1.2<0;1,0>:d     11:w               {I@1}
        add (1|M0)               r1.3<1>:d     r1.2<0;1,0>:d     248:w               {I@1}
        xor (1|M0)               r1.3<1>:d     r1.3<0;1,0>:d     r1.2<0;1,0>:d    {I@1}
(f0.0)  mov (1|M0)               r32.6<1>:d    r1.3<0;1,0>:d                    {I@1}
L12368:
        join (16|M0)                         L12512                                
L12384:
        asr (1|M0)               r1.2<1>:d     r32.6<0;1,0>:d    1:w               {I@2}
        cmp (1|M0)    (eq)f1.0   null<1>:w     r84.4<0;1,0>:w    0:w              
        add (1|M0)               r32.6<1>:d    r32.6<0;1,0>:d    -r1.2<0;1,0>:d   {I@2}
        shl (1|M0)               r1.2<1>:d     r1.2<0;1,0>:d     23:w              
        shl (1|M0)               r32.6<1>:d    r32.6<0;1,0>:d    23:w               {I@2}
        add (1|M0)               r1.2<1>:d     r1.2<0;1,0>:d     r84.4<0;1,0>:d   {A@1}
        add (1|M0)               r32.6<1>:d    r32.6<0;1,0>:d    1065353216:d               {I@2}
(f1.0)  mul (1|M0)               r24.0<1>:f    r32.6<0;1,0>:f    r1.2<0;1,0>:f    {I@1}
L12512:
        join (16|M0)                         L12528                                
L12528:
        sync.nop                             null                             {Compacted,F@1}
        math.inv (1|M0)          r1.2<1>:f     r85.1<0;1,0>:f                   {$12}
        mov (1|M0)               r1.4<1>:ud    0x3F800000:ud                             
        mul (1|M0)               r1.3<1>:f     r1.2<0;1,0>:f     r85.0<0;1,0>:f   {$12.dst}
        mad (1|M0)               r1.4<1>:f     r1.4<0;0>:f       r1.2<0;0>:f       -r85.1<0>:f      {I@1}
        mad (1|M0)               r2.3<1>:f     r85.0<0;0>:f      r1.3<0;0>:f       -r85.1<0>:f      {F@2}
        mad (1|M0)               r1.4<1>:f     r1.2<0;0>:f       r1.2<0;0>:f       r1.4<0>:f        {F@2}
        cmp (1|M0)    (eq)f0.1   null<1>:uw    r32.20<0;1,0>:ub  0x0:uw             
        mad (1|M0)               r2.3<1>:f     r1.3<0;0>:f       r1.4<0;0>:f       r2.3<0>:f        {F@1}
        mad (1|M0)               r85.0<1>:f    r85.0<0;0>:f      r2.3<0;0>:f       -r85.1<0>:f      {F@1}
(f0.1)  mad (1|M0)               r24.0<1>:f    r2.3<0;0>:f       r1.4<0;0>:f       r85.0<0>:f       {F@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        ret (16|M0)                          r85.2                            {A@1}
L12744:
        mov (1|M0)               r1.2<1>:d     cr0.0<0;1,0>:ud                  {A@1}
        and (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   -1265:w               {A@1}
        or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   1264:w               {A@1}
        mad (1|M0)               r84.3<1>:f    r86.1<0;0>:f      r86.0<0;0>:f      r84.3<0>:f       {A@1}
        mov (1|M0)               cr0.0<1>:ud   r1.2<0;1,0>:d                    {A@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        ret (16|M0)                          r86.2                            {A@1}
L12872:
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
