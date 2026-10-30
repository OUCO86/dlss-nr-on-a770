L0:
(W)     mov (8|M0)               r127.0<1>:ud  0x0:ud                              {A@1}
(W)     and (1|M0)               r127.2<1>:ud  r0.0<0;1,0>:ud    0xFFFFFFC0:ud             
(W)     and (1|M0)               r127.0<1>:uw  r0.4<0;1,0>:uw    0xFF:uw             
(W)     add (1|M0)               r127.2<1>:ud  r127.2<0;1,0>:ud  0xA0:ud              {I@2}
(W)     mad (1|M0)               r127.2<1>:ud  r127.2<0;0>:ud    r127.0<0;0>:uw    0x20:uw              {I@1}
(W)     send.dc0 (8|M0)          r1       r127    null:0  0x0            0x021842FD           {A@1,$0} // wr:1h+0, rd:1; oword aligned block read x2
        nop                    
        nop                    
(W)     mov (8|M0)               r127.0<1>:ud  0x0:ud                              {$0.src}
(W)     and (1|M0)               r127.2<1>:ud  r0.0<0;1,0>:ud    0xFFFFFFC0:ud             
(W)     send.dc0 (8|M0)          r2       r127    null:0  0x0            0x024844FD           {A@1,$1} // wr:1h+0, rd:4; oword aligned block read x8
(W)     add (1|M0)               r127.2<1>:ud  r127.2<0;1,0>:ud  0x80:uw              {$1.src}
(W)     send.dc0 (8|M0)          r6       r127    null:0  0x0            0x021842FD           {A@1,$2} // wr:1h+0, rd:1; oword aligned block read x2
        and (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   -1265:w               {A@1}
        or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   1216:w               {A@1}
        sync.nop                             null                             {Compacted,A@1}
        sync.nop                             null                             {Compacted,$1.dst}
        mul (1|M0)               acc0.0<1>:ud  r2.3<0;1,0>:ud    r0.2<0;1,0>:uw   {A@1}
        mach (1|M0)              r8.0<1>:ud    r2.3<0;1,0>:ud    r0.1<0;1,0>:ud   {AccWrEn}
        mov (1|M0)               r1.2<1>:d     r1.0<0;1,0>:uw                   {$0.dst}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
(W)     mov (1|M0)               r1.3<1>:hf    0x1:hf                             
        addc (1|M0)              r4.0<1>:ud    r7.0<0;1,0>:ud    r1.2<0;1,0>:ud   {AccWrEn,I@1}
        mov (1|M0)               r18.2<1>:d    r4.0<0;1,0>:d                    {I@1}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        cmp (1|M0)    (lt)f0.1   null<1>:ud    r18.2<0;1,0>:ud   r3.0<0;1,0>:ud   {I@2}
        add3 (1|M0)              r18.3<1>:d    r9.0<0;0>:d       r8.0<0;0>:d       0:w               {I@2}
        mul (1|M0)               acc0.0<1>:ud  r2.0<0;1,0>:ud    r2.6<0;1,0>:uw  
        cmp (1|M0)    (lt)f1.0   null<1>:ud    r18.3<0;1,0>:ud   r3.1<0;1,0>:ud   {I@2}
(f0.1)  cmp (1|M0)    (eq)f0.1   null<1>:d     r18.3<0;1,0>:d    r3.1<0;1,0>:d   
        mach (1|M0)              r11.0<1>:ud   r2.0<0;1,0>:ud    r2.3<0;1,0>:ud   {AccWrEn}
(f1.0)  sel (1|M0)               r2.12<1>:uw   r1.3<0;1,0>:uw    0x0:uw              {F@1}
(f0.1)  sel (1|M0)               r1.4<1>:uw    r1.3<0;1,0>:uw    0x0:uw             
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        or (1|M0)     (ne)f0.1   null<1>:uw    r1.4<0;1,0>:uw    r2.12<0;1,0>:uw  {I@2}
        mov (1|M0)               r18.7<1>:d    r11.0<0;1,0>:d                  
        mov (1|M0)               r18.6<1>:d    r10.0<0;1,0>:d                   {I@3}
(W)     and (1|M0)               f1.0<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(~f1.0.any16h) goto (16|M0)                  L4984                  L4984                
L584:
        mov (1|M0)               r17.0<1>:d    r5.1<0;1,0>:d                   
        mov (1|M0)               r18.4<1>:d    r5.0<0;1,0>:d                   
        asr (1|M0)               r18.5<1>:d    r5.0<0;1,0>:d     31:w               {Compacted}
        mov (1|M0)               r17.2<1>:d    r6.0<0;1,0>:d                    {$2.dst}
        asr (1|M0)               r17.3<1>:d    r6.0<0;1,0>:d     31:w               {Compacted}
        mov (2|M0)               r17.4<1>:d    r17.0<1;1,0>:d                   {I@5}
        asr (1|M0)               r17.5<1>:d    r5.1<0;1,0>:d     31:w              
        mov (1|M0)               r17.1<1>:d    0:w                              
L696:
        sync.nop                             null                             {Compacted,$4.src}
(W)     mov (2|M0)               r10.4<1>:ud   r18.2<1;1,0>:ud                  {$3.src}
(W)     mov (2|M0)               r10.2<1>:ud   r18.4<1;1,0>:ud                  {I@7}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r17.6         L5056                                 {A@1}
L784:
        mul (1|M0)               acc0.0<1>:ud  r45.4<0;1,0>:ud   r18.8<0;1,0>:uw 
        mach (1|M0)              r8.0<1>:ud    r45.4<0;1,0>:ud   r18.4<0;1,0>:ud  {AccWrEn}
        shr (1|M0)               r2.6<1>:ud    r45.4<0;1,0>:ud   0x7:uw             
        shl (1|M0)               r2.7<1>:d     r45.5<0;1,0>:d    25:w              
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r45.4<0;1,0>:d    r18.10<0;1,0>:uw
        mach (1|M0)              r4.0<1>:d     r45.4<0;1,0>:d    r18.5<0;1,0>:d  
(W)     mul (1|M0)               acc0.0<1>:d   r45.5<0;1,0>:d    r18.8<0;1,0>:uw 
        or (1|M0)                r3.2<1>:d     r2.6<0;1,0>:d     r2.7<0;1,0>:d    {I@5}
        mach (1|M0)              r9.0<1>:d     r45.5<0;1,0>:d    r18.4<0;1,0>:d  
        subb (1|M0)              r10.0<1>:ud   r18.2<0;1,0>:ud   r7.0<0;1,0>:ud   {AccWrEn,I@6}
        cmp (1|M0)    (lt)f0.0   null<1>:d     r45.4<0;1,0>:d    r5.2<0;1,0>:d   
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mul (1|M0)               acc0.0<1>:ud  r3.2<0;1,0>:ud    r17.8<0;1,0>:uw  {I@5}
        add3 (1|M0)              r1.3<1>:d     r9.0<0;0>:d       r8.0<0;0>:d       r4.0<0>:d        {I@5}
        mach (1|M0)              r8.0<1>:ud    r3.2<0;1,0>:ud    r17.4<0;1,0>:ud  {AccWrEn}
        shr (1|M0)               r3.3<1>:ud    r45.5<0;1,0>:ud   0x7:uw             
        shr (1|M0)               r3.4<1>:ud    r45.4<0;1,0>:ud   0x4:uw             
        shl (1|M0)               r3.5<1>:d     r45.5<0;1,0>:d    28:w              
(W)     and (1|M0)               f0.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r3.2<0;1,0>:d     r17.10<0;1,0>:uw
        mach (1|M0)              r9.0<1>:d     r3.2<0;1,0>:d     r17.5<0;1,0>:d  
(W)     mul (1|M0)               acc0.0<1>:d   r3.3<0;1,0>:d     r17.8<0;1,0>:uw  {I@7}
        shr (1|M0)               r6.6<1>:ud    r45.5<0;1,0>:ud   0x4:uw             
        mov (1|M0)               r45.2<1>:d    r10.0<0;1,0>:d                  
        mov (2|M0)               r4.0<1>:w     0x7070707:v                              
        or (1|M0)                r6.5<1>:d     r3.4<0;1,0>:d     r3.5<0;1,0>:d    {I@7}
        mach (1|M0)              r10.0<1>:d    r3.3<0;1,0>:d     r17.4<0;1,0>:d  
        and (1|M0)               r6.4<1>:d     r45.4<0;1,0>:d    15:w              
        add3 (1|M0)              r45.3<1>:d    r18.3<0;0>:d      -r11.0<0;0>:d     -r1.3<0>:d      
        mov (1|M0)               r17.6<1>:d    r7.0<0;1,0>:d                    {I@7}
        and (2|M0)               r6.5<1>:d     r6.5<1;1,0>:d     r4.0<1;1,0>:w    {I@5}
        add3 (1|M0)              r17.7<1>:d    r10.0<0;0>:d      r8.0<0;0>:d       r9.0<0>:d        {I@5}
(f0.1.any16h) goto (16|M0)                   L2080                  L2080                
L1320:
        shl (1|M0)               r3.3<1>:d     r45.2<0;1,0>:d    3:w              
        shl (1|M0)               r1.2<1>:d     r6.6<0;1,0>:d     9:w               {I@4}
        cmp (1|M0)    (eq)f1.1   null<1>:d     r3.3<0;1,0>:d     2147483640:d               {I@2}
        shr (1|M0)               r1.3<1>:ud    r6.5<0;1,0>:ud    0x17:uw             
        shl (1|M0)               r3.6<1>:d     r6.5<0;1,0>:d     9:w              
        shl (1|M0)               r3.4<1>:d     r6.4<0;1,0>:d     5:w              
(W)     and (1|M0)               f0.0<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
        mov (1|M0)               r3.5<1>:d     0:w                              
        add (1|M0)               r3.2<1>:d     r3.3<0;1,0>:d     8:w              
        or (1|M0)                r3.7<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@6}
(f0.0.any16h) goto (16|M0)                   L2080                  L4736                
L1496:
        addc (1|M0)              r4.0<1>:ud    r5.4<0;1,0>:ud    r3.6<0;1,0>:ud   {AccWrEn,I@7}
        mov (1|M0)               r45.6<1>:d    r3.3<0;1,0>:d                   
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r8.0<1>:ud    r4.0<0;1,0>:ud    r3.4<0;1,0>:ud   {AccWrEn,I@3}
        add3 (1|M0)              r1.3<1>:d     r7.0<0;0>:d       r5.5<0;0>:d       r3.7<0>:d        {I@2}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        asr (1|M0)               r45.7<1>:d    r3.3<0;1,0>:d     31:w              
        mov (1|M0)               r13.0<1>:d    r3.2<0;1,0>:d                   
        asr (1|M0)               r13.1<1>:d    r3.2<0;1,0>:d     31:w              
        mov (1|M0)               r6.0<1>:f     r8.0<0;1,0>:f                    {Compacted,I@6}
        add3 (1|M0)              r6.1<1>:d     r9.0<0;0>:d       r1.3<0;0>:d       r3.5<0>:d        {I@4}
L1648:
        addc (1|M0)              r4.0<1>:ud    r45.6<0;1,0>:ud   r17.6<0;1,0>:ud  {AccWrEn}
(W)     mov (1|M0)               r1.3<1>:hf    0x1:hf                             
        shl (1|M0)               r3.2<1>:d     r4.0<0;1,0>:d     12:w               {Compacted,I@1}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r8.0<1>:ud    r6.0<0;1,0>:ud    r3.2<0;1,0>:ud   {AccWrEn,A@2}
        add3 (1|M0)              r1.3<1>:d     r7.0<0;0>:d       r45.7<0;0>:d      r17.7<0>:d       {I@2}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r7.0<1>:ud    r45.6<0;1,0>:ud   0x1:ud              {AccWrEn}
        shr (1|M0)               r2.7<1>:ud    r4.0<0;1,0>:ud    0x14:uw             
        shl (1|M0)               r2.6<1>:d     r1.3<0;1,0>:d     12:w               {I@4}
        mov (1|M0)               r3.2<1>:d     r7.0<0;1,0>:d                    {I@3}
        mov (1|M0)               r12.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        or (1|M0)                r3.3<1>:d     r2.6<0;1,0>:d     r2.7<0;1,0>:d    {I@3}
        cmp (1|M0)    (lt)f0.0   null<1>:ud    r3.2<0;1,0>:ud    r13.0<0;1,0>:ud  {I@3}
        sync.nop                             null                             {Compacted,$3.src}
        add3 (1|M0)              r10.1<1>:d    r9.0<0;0>:d       r6.1<0;0>:d       r3.3<0>:d        {I@2}
        add3 (1|M0)              r3.3<1>:d     r12.0<0;0>:d      r45.7<0;0>:d      0:w              
        mov (4|M0)               r11.0<2>:f    0.0:f                              
        cmp (1|M0)    (lt)f0.1   null<1>:d     r3.3<0;1,0>:d     r13.1<0;1,0>:d   {I@1}
(f0.0)  cmp (1|M0)    (eq)f0.0   null<1>:d     r3.3<0;1,0>:d     r13.1<0;1,0>:d  
        mov (1|M0)               r10.0<1>:f    r8.0<0;1,0>:f                    {Compacted}
        mov (4|M0)               r11.1<2>:f    0.0:f                              
(f0.1)  sel (1|M0)               r2.12<1>:uw   r1.3<0;1,0>:uw    0x0:uw              {F@4}
(f0.0)  sel (1|M0)               r1.4<1>:uw    r1.3<0;1,0>:uw    0x0:uw             
        send.ugm (1|M0)          null     r10     r11:1   0x0            0x0200B784           {A@1,$3} // wr:1+1, rd:0; store.ugm.d64x4t.a64
        or (1|M0)     (ne)f1.0   null<1>:uw    r1.4<0;1,0>:uw    r2.12<0;1,0>:uw  {I@1}
(W)     and (1|M0)               f1.1<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
(~f1.1.any16h) goto (16|M0)                  L2080                  L4736                
L2048:
(W)     mov (2|M0)               r45.6<1>:ud   r3.2<1;1,0>:ud                  
        goto.b (16|M0)                       L2080                  L1648                
L2080:
        join (16|M0)                         L4736                                
L2096:
        cmp (1|M0)    (gt)f0.1   null<1>:d     r5.1<0;1,0>:d     0:w              
        mov (16|M0)              r74.0<1>:ud   0x0:ud                             
        mov (16|M0)              r72.0<1>:f    0.0:f                               {Compacted}
(W)     and (1|M0)               f1.0<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(~f1.0.any16h) goto (16|M0)                  L2856                  L2856                
L2168:
        mul (1|M0)               acc0.0<1>:ud  r45.4<0;1,0>:ud   r17.4<0;1,0>:uw 
        mach (1|M0)              r8.0<1>:ud    r45.4<0;1,0>:ud   r17.2<0;1,0>:ud  {AccWrEn}
        mov (1|M0)               r6.0<2>:f     0.0:f                              
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r45.4<0;1,0>:d    r17.6<0;1,0>:uw 
        mach (1|M0)              r4.0<1>:d     r45.4<0;1,0>:d    r17.3<0;1,0>:d  
(W)     mul (1|M0)               acc0.0<1>:d   r45.5<0;1,0>:d    r17.4<0;1,0>:uw 
        mach (1|M0)              r9.0<1>:d     r45.5<0;1,0>:d    r17.2<0;1,0>:d  
        shl (1|M0)               r3.2<1>:d     r7.0<0;1,0>:d     1:w               {Compacted,I@5}
        add3 (1|M0)              r1.3<1>:d     r9.0<0;0>:d       r8.0<0;0>:d       r4.0<0>:d        {I@2}
        shr (1|M0)               r2.7<1>:ud    r7.0<0;1,0>:ud    0x1F:uw             
        sync.nop                             null                             {Compacted,$3.src}
        addc (1|M0)              r10.0<1>:ud   r5.6<0;1,0>:ud    r3.2<0;1,0>:ud   {AccWrEn,I@3}
        shl (1|M0)               r2.6<1>:d     r1.3<0;1,0>:d     1:w               {I@3}
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        or (1|M0)                r3.3<1>:d     r2.6<0;1,0>:d     r2.7<0;1,0>:d    {I@2}
        mov (1|M0)               r6.1<2>:f     0.0:f                              
        mov (1|M0)               r45.6<1>:d    r10.0<0;1,0>:d                  
        add3 (1|M0)              r45.7<1>:d    r11.0<0;0>:d      r5.7<0;0>:d       r3.3<0>:d        {I@2}
L2440:
        shl (1|M0)               r1.2<1>:d     r6.1<0;1,0>:d     5:w               {F@1}
        shr (1|M0)               r1.3<1>:ud    r6.0<0;1,0>:ud    0x1B:uw             
        shl (1|M0)               r1.4<1>:d     r6.0<0;1,0>:d     5:w               {Compacted}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        shl (1|M0)               r3.2<1>:d     r1.4<0;1,0>:d     1:w               {I@2}
        shr (1|M0)               r2.7<1>:ud    r1.4<0;1,0>:ud    0x1F:uw             
        shl (1|M0)               r2.6<1>:d     r1.5<0;1,0>:d     1:w               {I@3}
        addc (1|M0)              r4.0<1>:ud    r45.6<0;1,0>:ud   r3.2<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r3.3<1>:d     r2.6<0;1,0>:d     r2.7<0;1,0>:d    {I@2}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r8.0<1>:f     r4.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r8.1<1>:d     r7.0<0;0>:d       r45.7<0;0>:d      r3.3<0>:d        {I@1}
        addc (1|M0)              r15.0<1>:ud   r6.0<0;1,0>:ud    0x1:ud              {AccWrEn}
        send.ugm (1|M0)          r9       r8      null:0  0x0            0x0220C780           {A@1,$5} // wr:1+0, rd:2; load.ugm.d64x8t.a64
        mov (1|M0)               r16.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r3.2<1>:d     r15.0<0;1,0>:d                   {I@2}
        add3 (1|M0)              r3.3<1>:d     r16.0<0;0>:d      r6.1<0;0>:d       0:w               {I@2}
        cmp (1|M0)    (eq)f0.0   null<1>:d     r3.3<0;1,0>:d     r17.1<0;1,0>:d   {I@1}
(f0.0)  cmp (1|M0)    (eq)f0.0   null<1>:d     r3.2<0;1,0>:d     r17.0<0;1,0>:d  
(W)     and (1|M0)               f0.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
        mov (8|M0)               r11.0<1>:f    (abs)r9.0<1;1,0>:hf              {$5.dst}
        mov (8|M0)               r12.0<1>:f    (abs)r9.8<1;1,0>:hf             
        mov (8|M0)               r13.0<1>:f    (abs)r10.0<1;1,0>:hf            
        mov (8|M0)               r14.0<1>:f    (abs)r10.8<1;1,0>:hf            
        sel (16|M0)   (ge)f0.0   r74.0<1>:f    r74.0<1;1,0>:f    r11.0<1;1,0>:f   {Compacted,F@3}
        sel (16|M0)   (ge)f0.0   r72.0<1>:f    r72.0<1;1,0>:f    r13.0<1;1,0>:f   {Compacted,F@2}
(f0.1.any16h) goto (16|M0)                   L2856                  L2856                
L2824:
(W)     mov (2|M0)               r6.0<1>:ud    r3.2<1;1,0>:ud                  
        goto.b (16|M0)                       L2856                  L2440                
L2856:
        join (16|M0)                         L4736                                
L2872:
        sel (16|M0)   (ge)f0.0   r74.0<1>:f    r74.0<1;1,0>:f    r72.0<1;1,0>:f   {Compacted,F@1}
        sel (8|M0)    (ge)f0.0   r4.0<1>:f     r74.0<1;1,0>:f    r75.0<1;1,0>:f   {Compacted,F@1}
        mov (4|M0)               r7.0<1>:ud    r4.4<1;1,0>:ud                   {F@1}
        sel (4|M0)    (ge)f0.0   r8.0<1>:f     r4.0<1;1,0>:f     r7.0<1;1,0>:f    {I@1}
        mov (2|M0)               r9.0<1>:ud    r8.2<1;1,0>:ud                   {F@1}
        sync.nop                             null                             {Compacted,$3.src}
        sel (2|M0)    (ge)f0.0   r10.0<1>:f    r8.0<1;1,0>:f     r9.0<1;1,0>:f    {I@1}
        sel (1|M0)    (ge)f0.0   r45.0<1>:f    r10.0<0;1,0>:f    r10.1<0;1,0>:f   {F@1}
        cmp (1|M0)    (eq)f0.0   null<1>:f     r45.0<0;1,0>:f    0.0:f               {F@1}
(W)     and (1|M0)               f0.0<1>:uw    f0.0<0;1,0>:uw    0x1:uw              {F@1}
(f0.0.any16h) goto (16|M0)                   L3104                  L3104                
L3024:
        mov (1|M0)               r45.1<1>:f    127.0:f                              
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r6.0          L6032                                 {A@1}
L3088:
        goto (16|M0)                         L3104                  L3128                
L3104:
        join (16|M0)                         L3128                                
L3120:
        mov (1|M0)               r18.0<1>:f    1.0:f                               {Compacted}
L3128:
        join (16|M0)                         L4736                                
L3144:
        shl (1|M0)               r45.2<1>:d    r45.2<0;1,0>:d    3:w              
        shl (1|M0)               r1.4<1>:d     r45.4<0;1,0>:d    2:w              
        cmp (1|M0)    (eq)f1.1   null<1>:d     r45.2<0;1,0>:d    2147483640:d               {I@2}
        shl (1|M0)               r1.2<1>:d     r45.5<0;1,0>:d    2:w              
        shr (1|M0)               r1.3<1>:ud    r45.4<0;1,0>:ud   0x1E:uw             
        addc (1|M0)              r4.0<1>:ud    r6.2<0;1,0>:ud    r1.4<0;1,0>:ud   {AccWrEn,I@4}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
(W)     and (1|M0)               f1.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        shl (1|M0)               r2.6<1>:d     r6.6<0;1,0>:d     9:w              
        shr (1|M0)               r2.7<1>:ud    r6.5<0;1,0>:ud    0x17:uw             
        mov (1|M0)               r8.0<1>:f     r4.0<0;1,0>:f                    {Compacted,I@6}
        add3 (1|M0)              r8.1<1>:d     r7.0<0;0>:d       r6.3<0;0>:d       r1.5<0>:d        {I@3}
        shl (1|M0)               r14.2<1>:d    r6.5<0;1,0>:d     9:w              
        send.ugm (1|M0)          null     r8      r18:1   0x0            0x04000584           {A@1,$6} // wr:2+1, rd:0; store.ugm.d32.a64
        shl (1|M0)               r14.0<1>:d    r6.4<0;1,0>:d     5:w               {Compacted}
        mov (1|M0)               r14.1<1>:d    0:w                              
        add (1|M0)               r45.7<1>:d    r45.2<0;1,0>:d    8:w              
        or (1|M0)                r14.3<1>:d    r2.6<0;1,0>:d     r2.7<0;1,0>:d   
(f1.1.any16h) goto (16|M0)                   L4736                  L4736                
L3440:
        mul (1|M0)               acc0.0<1>:ud  r45.4<0;1,0>:ud   r17.4<0;1,0>:uw 
        mach (1|M0)              r8.0<1>:ud    r45.4<0;1,0>:ud   r17.2<0;1,0>:ud  {AccWrEn,$6.src}
        mov (16|M0)              r31.0<1>:f    r18.0<0;1,0>:f                   {Compacted}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r45.4<0;1,0>:d    r17.6<0;1,0>:uw 
        shl (1|M0)               r3.2<1>:d     r7.0<0;1,0>:d     1:w               {Compacted,I@2}
        mach (1|M0)              r4.0<1>:d     r45.4<0;1,0>:d    r17.3<0;1,0>:d  
(W)     mul (1|M0)               acc0.0<1>:d   r45.5<0;1,0>:d    r17.4<0;1,0>:uw 
        mach (1|M0)              r9.0<1>:d     r45.5<0;1,0>:d    r17.2<0;1,0>:d  
        addc (1|M0)              r10.0<1>:ud   r5.6<0;1,0>:ud    r3.2<0;1,0>:ud   {AccWrEn,I@4}
        add3 (1|M0)              r1.3<1>:d     r9.0<0;0>:d       r8.0<0;0>:d       r4.0<0>:d        {I@2}
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r12.0<1>:ud   r5.4<0;1,0>:ud    r14.2<0;1,0>:ud  {AccWrEn}
        shr (1|M0)               r2.7<1>:ud    r7.0<0;1,0>:ud    0x1F:uw             
        shl (1|M0)               r2.6<1>:d     r1.3<0;1,0>:d     1:w               {I@4}
        mov (1|M0)               r13.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r4.0<1>:ud    r12.0<0;1,0>:ud   r14.0<0;1,0>:ud  {AccWrEn,I@4}
        or (1|M0)                r3.3<1>:d     r2.6<0;1,0>:d     r2.7<0;1,0>:d    {I@3}
        add3 (1|M0)              r6.5<1>:d     r13.0<0;0>:d      r5.5<0;0>:d       r14.3<0>:d       {I@3}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r6.4<1>:d     r45.2<0;1,0>:d                  
        mov (1|M0)               r6.6<1>:d     r45.7<0;1,0>:d                  
        asr (1|M0)               r6.7<1>:d     r45.7<0;1,0>:d    31:w              
        mov (1|M0)               r45.3<1>:d    r10.0<0;1,0>:d                  
        mov (1|M0)               r45.5<1>:d    r4.0<0;1,0>:d                    {I@7}
        add3 (1|M0)              r45.4<1>:d    r11.0<0;0>:d      r5.7<0;0>:d       r3.3<0>:d        {I@7}
        add3 (1|M0)              r45.6<1>:d    r9.0<0;0>:d       r6.5<0;0>:d       r14.1<0>:d       {I@7}
        asr (1|M0)               r6.5<1>:d     r45.2<0;1,0>:d    31:w              
L3840:
        shl (1|M0)               r1.2<1>:d     r45.2<0;1,0>:d    5:w              
        mov (16|M0)              r23.0<1>:f    r31.0<1;1,0>:f                   {Compacted,F@1}
        asr (1|M0)               r1.4<1>:d     r1.2<0;1,0>:d     31:w               {I@1}
        shl (1|M0)               r3.2<1>:d     r1.2<0;1,0>:d     1:w              
        shr (1|M0)               r2.7<1>:ud    r1.2<0;1,0>:ud    0x1F:uw             
        shl (1|M0)               r2.6<1>:d     r1.4<0;1,0>:d     1:w               {I@3}
        addc (1|M0)              r4.0<1>:ud    r45.3<0;1,0>:ud   r3.2<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r3.3<1>:d     r2.6<0;1,0>:d     r2.7<0;1,0>:d    {I@2}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r8.0<1>:f     r4.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r8.1<1>:d     r7.0<0;0>:d       r45.4<0;0>:d      r3.3<0>:d        {I@1}
        send.ugm (1|M0)          r9       r8      null:0  0x0            0x0220C780           {A@1,$7} // wr:1+0, rd:2; load.ugm.d64x8t.a64
        mov (8|M0)               r25.0<1>:f    r9.0<1;1,0>:hf                   {$7.dst}
        mov (8|M0)               r26.0<1>:f    r9.8<1;1,0>:hf                  
        mov (8|M0)               r29.0<1>:f    r10.0<1;1,0>:hf                 
        mov (8|M0)               r30.0<1>:f    r10.8<1;1,0>:hf                 
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r6.0          L10024                                 {A@1}
L4120:
        mov (16|M0)              r27.0<1>:ud   r19.0<1;1,0>:ud                 
        mov (16|M0)              r25.0<1>:f    r29.0<1;1,0>:f                   {Compacted,F@1}
        mov (16|M0)              r23.0<1>:f    r31.0<1;1,0>:f                   {Compacted}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r6.0          L10024                                 {A@1}
L4200:
        addc (1|M0)              r4.0<1>:ud    r6.4<0;1,0>:ud    r17.6<0;1,0>:ud  {AccWrEn}
(W)     mov (1|M0)               r1.3<1>:hf    0x1:hf                             
        shl (1|M0)               r3.2<1>:d     r4.0<0;1,0>:d     12:w               {Compacted,I@1}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r8.0<1>:ud    r45.5<0;1,0>:ud   r3.2<0;1,0>:ud   {AccWrEn,I@2}
        add3 (1|M0)              r1.3<1>:d     r7.0<0;0>:d       r6.5<0;0>:d       r17.7<0>:d       {I@2}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r7.0<1>:ud    r6.4<0;1,0>:ud    0x1:ud              {AccWrEn}
        shr (1|M0)               r2.7<1>:ud    r4.0<0;1,0>:ud    0x14:uw             
        shl (1|M0)               r2.6<1>:d     r1.3<0;1,0>:d     12:w               {I@4}
        mov (1|M0)               r3.2<1>:d     r7.0<0;1,0>:d                    {I@3}
        mov (1|M0)               r4.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        or (1|M0)                r3.3<1>:d     r2.6<0;1,0>:d     r2.7<0;1,0>:d    {I@3}
        cmp (1|M0)    (lt)f1.1   null<1>:ud    r3.2<0;1,0>:ud    r6.6<0;1,0>:ud   {I@3}
        add3 (1|M0)              r10.1<1>:d    r9.0<0;0>:d       r45.6<0;0>:d      r3.3<0>:d        {I@2}
        add3 (1|M0)              r3.3<1>:d     r4.0<0;0>:d       r6.5<0;0>:d       0:w              
        rnde (16|M0)             r27.0<1>:f    r27.0<1;1,0>:f                   {Compacted}
        cmp (1|M0)    (lt)f0.0   null<1>:d     r3.3<0;1,0>:d     r6.7<0;1,0>:d    {I@1}
(f1.1)  cmp (1|M0)    (eq)f1.1   null<1>:d     r3.3<0;1,0>:d     r6.7<0;1,0>:d   
        rnde (16|M0)             r19.0<1>:f    r19.0<1;1,0>:f                   {Compacted}
(f0.0)  sel (1|M0)               r2.12<1>:uw   r1.3<0;1,0>:uw    0x0:uw              {F@3}
(f1.1)  sel (1|M0)               r1.4<1>:uw    r1.3<0;1,0>:uw    0x0:uw             
        sel (16|M0)   (ge)f0.0   r27.0<1>:f    r27.0<1;1,0>:f    -127.0:f               {F@2}
        sel (16|M0)   (ge)f0.0   r19.0<1>:f    r19.0<1;1,0>:f    -127.0:f               {F@2}
        or (1|M0)     (ne)f1.0   null<1>:uw    r1.4<0;1,0>:uw    r2.12<0;1,0>:uw  {I@1}
        sel (16|M0)   (lt)f0.0   r27.0<1>:f    r27.0<1;1,0>:f    127.0:f               {F@2}
        sel (16|M0)   (lt)f0.0   r19.0<1>:f    r19.0<1;1,0>:f    127.0:f               {F@2}
        mov (16|M0)              r11.0<1>:d    r27.0<1;1,0>:f                   {Compacted,F@2}
(W)     and (1|M0)               f1.0<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
        mov (16|M0)              r13.0<1>:d    r19.0<1;1,0>:f                   {Compacted,F@1}
        mov (1|M0)               r10.0<1>:f    r8.0<0;1,0>:f                    {Compacted}
        mov (16|M0)              r15.0<1>:b    r11.0<4;1,0>:b                   {I@3}
        mov (16|M0)              r15.16<1>:b   r13.0<4;1,0>:b                   {I@2}
        send.ugm (1|M0)          null     r10     r15:1   0x0            0x0200B784           {A@1,$4} // wr:1+1, rd:0; store.ugm.d64x4t.a64
        add (1|M0)               r45.2<1>:d    r45.2<0;1,0>:d    1:w              
(~f1.0.any16h) goto (16|M0)                  L4736                  L4736                
L4704:
(W)     mov (2|M0)               r6.4<1>:ud    r3.2<1;1,0>:ud                  
        goto.b (16|M0)                       L4736                  L3840                
L4736:
        join (16|M0)                         L4984                                
L4752:
        addc (1|M0)              r4.0<1>:ud    r18.2<0;1,0>:ud   r18.6<0;1,0>:ud  {AccWrEn}
(W)     mov (1|M0)               r1.3<1>:hf    0x1:hf                             
        mov (1|M0)               r3.2<1>:d     r4.0<0;1,0>:d                    {I@1}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        cmp (1|M0)    (lt)f1.0   null<1>:ud    r3.2<0;1,0>:ud    r3.0<0;1,0>:ud   {I@2}
        add3 (1|M0)              r3.3<1>:d     r7.0<0;0>:d       r18.3<0;0>:d      r18.7<0>:d       {I@2}
        cmp (1|M0)    (lt)f1.1   null<1>:ud    r3.3<0;1,0>:ud    r3.1<0;1,0>:ud   {I@1}
(f1.0)  cmp (1|M0)    (eq)f1.0   null<1>:d     r3.3<0;1,0>:d     r3.1<0;1,0>:d   
(f1.1)  sel (1|M0)               r2.12<1>:uw   r1.3<0;1,0>:uw    0x0:uw              {F@1}
(f1.0)  sel (1|M0)               r1.4<1>:uw    r1.3<0;1,0>:uw    0x0:uw             
        or (1|M0)     (ne)f0.1   null<1>:uw    r1.4<0;1,0>:uw    r2.12<0;1,0>:uw  {I@1}
(W)     and (1|M0)               f0.1<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(~f0.1.any16h) goto (16|M0)                  L4984                  L4984                
L4952:
(W)     mov (2|M0)               r18.2<1>:ud   r3.2<1;1,0>:ud                   {$6.src}
        goto.b (16|M0)                       L4984                  L696                
L4984:
        join (16|M0)                         L5000                                
L5000:
(W)     mov (8|M0)               r127.0<1>:f   r0.0<1;1,0>:f                    {Compacted,$2.src}
(W)     send.ugm (1|M0)          r4       r0      null:0  0x0            0x0210641F           {$8} // wr:1+0, rd:1; fence invalid flush type scoped to tile
(W)     mov (8|M0)               null<1>:ud    r4.0<1;1,0>:ud                   {$8.dst}
(W)     send.gtwy (1|M0)         null     r127    null:0  0x0            0x02000010           {EOT,A@1} // wr:1+0, rd:0; end of thread
L5056:
        mov (2|M0)               r11.0<1>:d    0x1:v                              
        mov (1|M0)               r10.0<2>:f    0.0:f                              
        mov (1|M0)               r10.1<2>:f    0.0:f                              
        mov (1|M0)               r45.6<2>:f    0.0:f                              
        mov (1|M0)               r45.7<2>:d    0:d                              
        mov (1|M0)               r45.2<1>:d    63:w                              
L5152:
        and (1|M0)    (eq)f0.0   r2.6<1>:d     r45.2<0;1,0>:d    63:w               {I@1}
(W)     mov (1|M0)               r3.4<1>:hf    0.0:hf                             
        mov (1|M0)               r1.3<1>:d     0:w                              
        shr (1|M0)               r3.4<1>:ud    r45.6<0;1,0>:ud   0x1F:uw              {F@2}
        cmp (1|M0)    (ge)f0.1   null<1>:ud    r2.6<0;1,0>:ud    0x20:uw              {I@3}
(f0.0)  sel (1|M0)               r4.0<1>:d     r3.4<0;1,0>:w     -1:w               {F@1}
        add (1|M0)               r2.7<1>:d     -r2.6<0;1,0>:d    32:w              
        add (1|M0)               r4.2<1>:d     r2.6<0;1,0>:d     -32:w              
        and (1|M0)               r4.1<1>:d     r10.5<0;1,0>:d    r4.0<0;1,0>:d    {I@3}
        shr (1|M0)               r1.2<1>:ud    r10.4<0;1,0>:ud   r2.6<0;1,0>:ud  
(f0.1)  sel (1|M0)               r3.3<1>:d     r3.4<0;1,0>:w     -1:w              
        shr (1|M0)               r4.2<1>:ud    r10.5<0;1,0>:ud   r4.2<0;1,0>:ud   {I@4}
        shl (1|M0)               r4.1<1>:d     r4.1<0;1,0>:d     r2.7<0;1,0>:d    {I@4}
        shr (1|M0)               r1.3<1>:ud    r10.5<0;1,0>:ud   r2.6<0;1,0>:ud  
        shl (1|M0)               r3.2<1>:d     r45.7<0;1,0>:d    1:w              
        and (1|M0)               r1.2<1>:ud    r1.2<0;1,0>:ud    r3.3<0;1,0>:ud   {I@5}
        and (1|M0)               r4.2<1>:ud    r4.2<0;1,0>:ud    ~r3.3<0;1,0>:ud  {I@5}
        and (1|M0)               r4.1<1>:d     r4.1<0;1,0>:d     r3.3<0;1,0>:d    {I@5}
        shl (1|M0)               r7.0<1>:d     r45.6<0;1,0>:d    1:w               {Compacted}
        and (1|M0)               r6.5<1>:ud    r1.3<0;1,0>:ud    r3.3<0;1,0>:ud   {I@6}
        or (1|M0)                r7.1<1>:d     r3.2<0;1,0>:d     r3.4<0;1,0>:d    {I@6}
        bfn.0xFE (1|M0)          r6.4<1>:ud    r4.2<0;0>:ud      r1.2<0;0>:ud      r4.1<0>:ud       {I@4} // s0|s1|s2
(W)     mov (1|M0)               r1.3<1>:hf    0x1:hf                             
        bfn.0xEA (2|M0)          r7.0<1>:ud    r7.0<1;0>:ud      r6.4<1;0>:ud      r11.0<1>:ud      {I@1} // s0|s1&s2
        cmp (1|M0)    (eq)f0.0   null<1>:d     r45.2<0;1,0>:d    0:w              
        cmp (1|M0)    (lt)f0.1   null<1>:ud    r7.0<0;1,0>:ud    r10.2<0;1,0>:ud  {I@2}
        cmp (1|M0)    (lt)f1.1   null<1>:ud    r7.1<0;1,0>:ud    r10.3<0;1,0>:ud 
        and (1|M0)               r4.0<1>:d     r4.0<0;1,0>:d     1:w               {Compacted}
(W)     mov (1|M0)               r3.4<1>:hf    0x1:hf                             
(f0.1)  cmp (1|M0)    (eq)f0.1   null<1>:d     r7.1<0;1,0>:d     r10.3<0;1,0>:d  
(f1.1)  sel (1|M0)               r1.5<1>:uw    r1.3<0;1,0>:uw    0x0:uw              {F@2}
        shl (1|M0)               r2.6<1>:ud    r1.3<0;1,0>:uw    r2.6<0;1,0>:ud  
        subb (1|M0)              r8.0<1>:ud    r7.0<0;1,0>:ud    r10.2<0;1,0>:ud  {AccWrEn}
(f0.1)  sel (1|M0)               r1.4<1>:uw    r1.3<0;1,0>:uw    0x0:uw             
(W)     and (1|M0)               f0.0<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
        shr (1|M0)               r4.0<1>:ud    r4.0<0;1,0>:ud    r2.7<0;1,0>:ud   {Compacted,I@7}
        shl (1|M0)               r4.1<1>:d     r3.4<0;1,0>:w     -r2.7<0;1,0>:d   {F@1}
        or (1|M0)     (ne)f1.0   null<1>:uw    r1.4<0;1,0>:uw    r1.5<0;1,0>:uw   {I@4}
        and (1|M0)               r45.4<1>:ud   r2.6<0;1,0>:ud    r3.3<0;1,0>:ud  
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        bfn.0xCA (1|M0)          r45.5<1>:ud   r4.1<0;0>:ud      r4.0<0;0>:ud      r3.3<0>:ud       {I@4} // s0&~s2|s1&s2
        mov (1|M0)               r45.6<1>:d    r8.0<0;1,0>:d                   
        add (1|M0)               r3.2<1>:d     r45.2<0;1,0>:d    -1:w              
        add3 (1|M0)              r45.7<1>:d    r7.1<0;0>:d       -r9.0<0;0>:d      -r10.3<0>:d      {I@4}
(f1.0)  mov (1|M0)               r45.6<1>:d    r7.0<0;1,0>:d                   
        or (2|M0)                r45.4<1>:d    r45.4<1;1,0>:d    r10.0<1;1,0>:d   {I@5}
(f1.0)  mov (1|M0)               r45.7<1>:d    r7.1<0;1,0>:d                   
(f1.0)  mov (1|M0)               r45.4<1>:d    r10.0<0;1,0>:d                  
(f1.0)  mov (1|M0)               r45.5<1>:d    r10.1<0;1,0>:d                  
(f0.0.any16h) goto (16|M0)                   L5968                  L5968                
L5920:
(W)     mov (2|M0)               r10.0<1>:ud   r45.4<1;1,0>:ud                  {I@2}
        mov (1|M0)               r45.2<1>:f    r3.2<0;1,0>:f                   
        goto.b (16|M0)                       L5968                  L5152                
L5968:
        join (16|M0)                         L5984                                
L5984:
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        ret (16|M0)                          r17.6                            {A@1}
L6032:
        shr (1|M0)               r8.6<1>:ud    r45.1<0;1,0>:ud   0x17:uw             
        shr (1|M0)               r6.7<1>:ud    r45.0<0;1,0>:ud   0x17:uw             
        and (1|M0)               r8.6<1>:ud    r8.6<0;1,0>:ud    0xFF:uw              {I@2}
        and (1|M0)               r6.7<1>:ud    r6.7<0;1,0>:ud    0xFF:uw              {I@2}
        add (1|M0)               r1.3<1>:ud    r8.6<0;1,0>:ud    0xFFFFFF41:ud              {I@2}
        add (1|M0)               r1.2<1>:ud    r6.7<0;1,0>:ud    0xFFFFFF41:ud              {I@2}
        cmp (1|M0)    (lt)f1.1   null<1>:ud    r1.3<0;1,0>:ud    0xFFFFFF81:ud              {I@2}
(W)     mov (1|M0)               r2.12<1>:hf   -qnan(0x1FF):hf                             
(~f1.1) cmp (1|M0)    (lt)f1.1   null<1>:ud    r1.2<0;1,0>:ud    0xFFFFFF82:ud              {I@2}
(f1.1)  sel (1|M0)               r8.8<2>:b     r2.12<0;1,0>:w    0:w               {F@1}
        cmp (1|M0)    (ne)f1.1   null<1>:uw    r8.8<0;1,0>:ub    0x0:uw              {I@1}
(W)     and (1|M0)               f1.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(~f1.1.any16h) goto (16|M0)                  L9664                  L9664                
L6240:
        add (1|M0)               r1.3<1>:ud    r8.6<0;1,0>:ud    0xFFFFFF01:ud             
        add (1|M0)               r1.2<1>:ud    r6.7<0;1,0>:ud    0xFFFFFF01:ud             
        cmp (1|M0)    (lt)f1.0   null<1>:ud    r1.3<0;1,0>:ud    0xFFFFFF02:ud              {I@2}
(W)     mov (1|M0)               r2.12<1>:hf   -qnan(0x1FF):hf                             
        mov (1|M0)               r8.3<1>:f     (abs)r45.0<0;1,0>:f              {Compacted}
(~f1.0) cmp (1|M0)    (lt)f1.0   null<1>:ud    r1.2<0;1,0>:ud    0xFFFFFF02:ud              {I@2}
(f1.0)  sel (1|M0)               r8.20<2>:b    r2.12<0;1,0>:w    0:w               {F@2}
        cmp (1|M0)    (ne)f1.0   null<1>:uw    r8.20<0;1,0>:ub   0x0:uw              {I@1}
(W)     and (1|M0)               f1.0<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
(f1.0.any16h) goto (16|M0)                   L6480                  L6480                
L6392:
        mov (1|M0)               r1.2<1>:f     (abs)r45.1<0;1,0>:f             
        mov (1|M0)               r8.10<2>:b    0:w                              
        add (1|M0)               r8.3<1>:d     r8.3<0;1,0>:d     -r1.2<0;1,0>:d   {A@1}
        mov (2|M0)               r8.0<1>:f     r45.0<1;1,0>:f                  
        asr (1|M0)               r8.3<1>:d     r8.3<0;1,0>:d     23:w               {Compacted,I@1}
        goto (16|M0)                         L6480                  L8152                
L6480:
        join (16|M0)                         L8152                                
L6496:
        cmp (1|M0)    (gt)f0.1   null<1>:ud    r8.3<0;1,0>:ud    0x7F800000:ud              {I@3}
(W)     mov (1|M0)               r1.3<1>:hf    0xFF:hf                             
        mov (1|M0)               r8.4<1>:f     (abs)r45.1<0;1,0>:f             
(W)     mov (1|M0)               r2.13<1>:hf   -qnan(0x1FF):hf                             
(f0.1)  sel (1|M0)               r2.12<1>:w    r1.3<0;1,0>:w     0:w               {F@3}
        and (1|M0)               r45.7<1>:ud   r45.0<0;1,0>:ud   0x7F800000:ud             
        cmp (1|M0)    (eq)f0.1   null<1>:w     r2.24<0;1,0>:b    0:w               {I@2}
(W)     mov (1|M0)               r3.4<1>:uw    r2.24<0;1,0>:ub                 
        and (1|M0)               r45.6<1>:ud   r45.1<0;1,0>:ud   0x7F800000:ud             
        add (1|M0)               r18.0<1>:f    r45.0<0;1,0>:f    r45.1<0;1,0>:f   {Compacted}
(f0.1)  cmp (1|M0)    (gt)f0.1   null<1>:ud    r8.4<0;1,0>:ud    0x7F800000:ud              {F@3}
(W)     mov (1|M0)               r7.0<1>:f     -0.0:f                               {Compacted}
        and (1|M0)               r4.0<1>:ud    r45.1<0;1,0>:ud   0x80000000:ud             
        bfn.0x6A (1|M0)          r1.2<1>:ud    r45.0<0;0>:ud     r45.1<0;0>:ud     r7.0<0>:ud       {F@1} // s0^s1&s2
(f0.1)  sel (1|M0)               r2.28<2>:b    r2.13<0;1,0>:w    0:w              
        bfn.0x6A (1|M0)          r1.3<1>:ud    r45.1<0;0>:ud     r45.0<0;0>:ud     r7.0<0>:ud       // s0^s1&s2
        and (1|M0)    (ne)f1.0   null<1>:w     r2.28<0;1,0>:ub   1:w               {I@2}
        or (1|M0)     (eq)f0.0   r2.28<2>:ub   r2.28<0;1,0>:ub   r3.4<0;1,0>:uw  
        and (1|M0)               r9.0<1>:ud    r45.0<0;1,0>:ud   0x80000000:ud             
(f1.0)  add (1|M0)               r18.0<1>:f    r45.1<0;1,0>:f    r45.1<0;1,0>:f  
(f0.0)  cmp (1|M0)    (eq)f0.0   null<1>:d     r45.7<0;1,0>:d    2139095040:d              
(W)     mov (1|M0)               r4.2<1>:uw    r2.28<0;1,0>:ub                  {I@3}
(f0.0)  sel (1|M0)               r1.6<2>:b     r2.13<0;1,0>:w    0:w              
        and (1|M0)    (ne)f0.1   null<1>:w     r1.6<0;1,0>:ub    1:w               {I@1}
        or (1|M0)     (eq)f1.1   r1.6<2>:ub    r1.6<0;1,0>:ub    r4.2<0;1,0>:uw  
(f0.1)  add (1|M0)               r18.0<1>:f    r1.2<0;1,0>:f     -r1.3<0;1,0>:f  
(f1.1)  cmp (1|M0)    (eq)f1.1   null<1>:d     r45.6<0;1,0>:d    2139095040:d              
(W)     mov (1|M0)               r3.4<1>:uw    r1.6<0;1,0>:ub                   {I@2}
(f1.1)  sel (1|M0)               r9.4<2>:b     r2.13<0;1,0>:w    0:w              
        and (1|M0)    (ne)f0.0   null<1>:w     r9.4<0;1,0>:ub    1:w               {I@1}
        or (1|M0)     (eq)f1.0   r9.4<2>:ub    r9.4<0;1,0>:ub    r3.4<0;1,0>:uw   {F@2}
(f0.0)  mul (1|M0)               r18.0<1>:f    r4.0<0;1,0>:f     r45.0<0;1,0>:f  
(f1.0)  cmp (1|M0)    (eq)f1.0   null<1>:f     r45.1<0;1,0>:f    0.0:f               {I@1}
(f1.0)  sel (1|M0)               r3.10<2>:b    r2.13<0;1,0>:w    0:w              
        cmp (1|M0)    (ne)f1.1   null<1>:uw    r3.10<0;1,0>:ub   0x0:uw              {I@1}
(W)     and (1|M0)               f0.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw              {F@3}
(f0.1.any16h) goto (16|M0)                   L7104                  L7104                
L7072:
        mov (1|M0)               r3.8<2>:b     r9.4<0;1,0>:b                   
        goto (16|M0)                         L7104                  L7288                
L7104:
        join (16|M0)                         L7288                                
L7120:
(W)     mov (1|M0)               r4.0<1>:f     inf:f                               {Compacted}
        cmp (1|M0)    (eq)f1.1   null<1>:f     r45.0<0;1,0>:f    0.0:f               {A@5}
        bfn.0x96 (1|M0)          r9.0<1>:ud    r9.0<0;0>:ud      r45.1<0;0>:ud     r4.0<0>:ud       {F@2} // s0^s1^s2
        xor (1|M0)               r1.2<1>:ud    r45.1<0;1,0>:ud   0x7F800000:ud             
        and (1|M0)    (ne)f1.0   null<1>:w     r3.10<0;1,0>:ub   1:w              
(W)     mov (1|M0)               r2.12<1>:uw   r9.4<0;1,0>:ub                  
(~f1.1) mov (1|M0)               r1.2<1>:f     r9.0<0;1,0>:f                    {A@3}
        or (1|M0)                r9.4<2>:ub    r3.10<0;1,0>:ub   r2.12<0;1,0>:uw  {I@1}
(f1.1)  mul (1|M0)               r9.0<1>:f     r1.2<0;1,0>:f     r45.0<0;1,0>:f   {F@1}
        mov (1|M0)               r3.8<2>:b     r9.4<0;1,0>:b                    {I@1}
(f1.0)  mov (1|M0)               r18.0<1>:f    r9.0<0;1,0>:f                    {F@1}
L7288:
        join (16|M0)                         L8152                                
L7304:
        cmp (1|M0)    (eq)f0.1   null<1>:w     r9.4<0;1,0>:b     0:w              
(W)     mov (1|M0)               r1.3<1>:hf    -qnan(0x1FF):hf                             
(W)     mov (1|M0)               r2.12<1>:uw   r3.8<0;1,0>:ub                   {I@3}
(f0.1)  cmp (1|M0)    (eq)f0.1   null<1>:f     r45.0<0;1,0>:f    0.0:f               {I@2}
(f0.1)  sel (1|M0)               r8.10<2>:b    r1.3<0;1,0>:w     0:w               {F@2}
        and (1|M0)    (ne)f0.1   null<1>:w     r8.10<0;1,0>:ub   1:w               {A@1}
        or (1|M0)     (ne)f0.0   r8.10<2>:ub   r8.10<0;1,0>:ub   r2.12<0;1,0>:uw 
(f0.1)  mul (1|M0)               r18.0<1>:f    r45.0<0;1,0>:f    r45.1<0;1,0>:f  
(W)     and (1|M0)               f0.0<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
(f0.0.any16h) goto (16|M0)                   L8152                  L9664                
L7464:
        cmp (1|M0)    (eq)f1.1   null<1>:uw    r8.10<0;1,0>:ub   0x0:uw              {I@3}
        cmp (1|M0)    (eq)f1.0   null<1>:d     r45.7<0;1,0>:d    0:w              
(~f1.1) mov (1|M0)               r8.20<2>:b    0:w                              
(f1.0)  sel (1|M0)               r3.3<1>:d     r8.20<0;1,0>:b    0:w               {I@1}
        cmp (1|M0)    (ne)f0.1   null<1>:d     r3.3<0;1,0>:d     0:w               {A@1}
(W)     and (1|M0)               f1.1<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(f1.1.any16h) goto (16|M0)                   L7616                  L7616                
L7576:
        mov (1|M0)               r3.2<1>:d     0:w                              
        mov (1|M0)               r8.0<1>:f     r45.0<0;1,0>:f                   {Compacted}
        goto (16|M0)                         L7616                  L7768                
L7616:
        join (16|M0)                         L7768                                
L7632:
        and (1|M0)    (ne)f0.0   r3.3<1>:d     r3.3<0;1,0>:d     1:w              
        mov (1|M0)               r8.0<1>:f     r45.0<0;1,0>:f                   {Compacted}
(W)     mov (1|M0)               r2.12<1>:hf   -qnan(0x1E0):hf                             
(f0.0)  mul (1|M0)               r8.0<1>:f     r45.0<0;1,0>:f    0x4F800000:f              
(f0.0)  sel (1|M0)               r3.2<1>:d     r2.12<0;1,0>:w    0:w               {F@2}
        shr (1|M0)               r1.2<1>:ud    r8.0<0;1,0>:ud    0x17:uw              {F@1}
        and (1|M0)               r1.2<1>:ud    r1.2<0;1,0>:ud    0xFF:uw              {I@1}
        add (1|M0)               r1.2<1>:ud    r1.2<0;1,0>:ud    0xFFFFFFE0:ud              {I@1}
(f0.0)  mov (1|M0)               r6.7<1>:d     r1.2<0;1,0>:d                    {I@1}
L7768:
        join (16|M0)                         L8152                                
L7784:
        cmp (1|M0)    (eq)f0.0   null<1>:d     r45.6<0;1,0>:d    0:w              
(f0.0)  sel (1|M0)               r3.3<1>:d     r8.20<0;1,0>:b    0:w              
        cmp (1|M0)    (ne)f1.1   null<1>:d     r3.3<0;1,0>:d     0:w               {I@1}
(W)     and (1|M0)               f1.0<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(f1.0.any16h) goto (16|M0)                   L7904                  L7904                
L7864:
        mov (1|M0)               r8.7<1>:d     0:w                              
        mov (1|M0)               r8.1<1>:f     r45.1<0;1,0>:f                   {Compacted}
        goto (16|M0)                         L7904                  L8072                
L7904:
        join (16|M0)                         L8072                                
L7920:
        and (1|M0)    (ne)f1.1   r3.3<1>:d     r3.3<0;1,0>:d     1:w              
        mov (1|M0)               r8.1<1>:f     r45.1<0;1,0>:f                   {Compacted}
(W)     mov (1|M0)               r2.12<1>:hf   0x20:hf                             
(f1.1)  mul (1|M0)               r8.1<1>:f     r45.1<0;1,0>:f    0x4F800000:f              
(f1.1)  sel (1|M0)               r8.7<1>:d     r2.12<0;1,0>:w    0:w               {F@2}
        shr (1|M0)               r1.2<1>:ud    r8.1<0;1,0>:ud    0x17:uw              {F@1}
        mov (1|M0)               r8.4<1>:f     (abs)r8.1<0;1,0>:f              
        and (1|M0)               r1.2<1>:ud    r1.2<0;1,0>:ud    0xFF:uw              {I@1}
        add (1|M0)               r1.2<1>:ud    r1.2<0;1,0>:ud    0xFFFFFFE0:ud              {I@1}
(f1.1)  mov (1|M0)               r8.6<1>:d     r1.2<0;1,0>:d                    {I@1}
L8072:
        join (16|M0)                         L8152                                
L8088:
        mov (1|M0)               r8.3<1>:f     (abs)r8.0<0;1,0>:f               {Compacted}
        add (1|M0)               r8.7<1>:d     r8.7<0;1,0>:d     r3.2<0;1,0>:d   
        add (1|M0)               r8.3<1>:d     r8.3<0;1,0>:d     -r8.4<0;1,0>:d   {F@1}
        asr (1|M0)               r8.3<1>:d     r8.3<0;1,0>:d     23:w               {Compacted,I@1}
        add (1|M0)               r8.7<1>:d     r8.7<0;1,0>:d     r8.3<0;1,0>:d    {I@1}
L8152:
        join (16|M0)                         L9664                                
L8168:
        cmp (1|M0)    (eq)f1.0   null<1>:uw    r8.20<0;1,0>:ub   0x0:uw             
(W)     mov (1|M0)               r1.2<1>:f     1.0:f                               {Compacted}
(W)     mov (1|M0)               r4.0<1>:f     0x807FFFFF:f                              
        cmp (1|M0)    (eq)f0.1   null<1>:w     r8.10<0;1,0>:b    0:w              
(~f1.0) mov (1|M0)               r8.3<1>:d     r8.7<0;1,0>:d                    {I@4}
        bfn.0xEA (1|M0)          r8.1<1>:ud    r1.2<0;0>:ud      r8.1<0;0>:ud      r4.0<0>:ud       {A@1} // s0|s1&s2
        add (1|M0)               r7.4<1>:d     r8.3<0;1,0>:d     126:w               {I@2}
        add (1|M0)               r7.3<1>:d     -r8.3<0;1,0>:d    -152:w               {Compacted}
        sync.nop                             null                             {Compacted,I@3}
        math.inv (1|M0)          r2.6<1>:f     r8.1<0;1,0>:f                    {$9}
        and (1|M0)               r7.3<1>:d     r7.3<0;1,0>:d     r7.4<0;1,0>:d    {I@1}
        mov (1|M0)               r7.0<1>:f     1.0:f                               {Compacted}
        asr (1|M0)               r7.3<1>:d     r7.3<0;1,0>:d     31:w               {Compacted,I@1}
(~f0.1) mov (1|M0)               r7.3<1>:d     0:w                              
        bfn.0xEA (1|M0)          r8.0<1>:ud    r1.2<0;0>:ud      r8.0<0;0>:ud      r4.0<0>:ud       // s0|s1&s2
        cmp (1|M0)    (ne)f0.0   null<1>:d     r7.3<0;1,0>:d     0:w               {I@2}
        sync.nop                             null                             {Compacted,$9.dst}
        mad (1|M0)               r7.0<1>:f     r7.0<0;0>:f       r2.6<0;0>:f       -r8.1<0>:f       {F@1}
        mul (1|M0)               r2.7<1>:f     r2.6<0;1,0>:f     r8.0<0;1,0>:f    {I@2}
        mad (1|M0)               r7.0<1>:f     r2.6<0;0>:f       r2.6<0;0>:f       r7.0<0>:f        {F@2}
        mad (1|M0)               r7.1<1>:f     r8.0<0;0>:f       r2.7<0;0>:f       -r8.1<0>:f       {F@2}
(W)     and (1|M0)               f0.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
        mad (1|M0)               r7.1<1>:f     r2.7<0;0>:f       r7.0<0;0>:f       r7.1<0>:f        {F@1}
        add (1|M0)               r6.7<1>:d     r6.7<0;1,0>:d     -r8.6<0;1,0>:d  
        mad (1|M0)               r8.0<1>:f     r8.0<0;0>:f       r7.1<0;0>:f       -r8.1<0>:f       {F@1}
(~f0.1.any16h) goto (16|M0)                  L9312                  L9312                
L8536:
        mov (1|M0)               r7.2<1>:f     r8.0<0;1,0>:f                    {Compacted,F@1}
        mov (2|M0)               r2.0<1>:f     r7.0<1;1,0>:f                   
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r3.2          L9896                                 {A@1}
L8608:
        cmp (1|M0)    (eq)f1.0   null<1>:f     r8.0<0;1,0>:f     0.0:f              
(W)     mov (1|M0)               r1.3<1>:hf    0x1:hf                             
        add (1|M0)               r8.3<1>:d     r8.3<0;1,0>:d     125:w               {Compacted}
(W)     mov (1|M0)               r3.4<1>:hf    0x1:hf                              {I@2}
(f1.0)  sel (1|M0)               r2.12<1>:w    r1.3<0;1,0>:w     0:w               {F@2}
        cmp (1|M0)    (lt)f1.1   null<1>:d     r8.3<0;1,0>:d     -2:w               {I@2}
        cmp (1|M0)    (ne)f0.1   null<1>:w     r2.12<0;1,0>:w    0:w               {I@2}
(W)     mov (1|M0)               r5.6<1>:hf    -qnan(0x1FF):hf                             
(f1.1)  sel (1|M0)               r3.5<1>:uw    r3.4<0;1,0>:uw    0x0:uw              {F@2}
(f0.1)  sel (1|M0)               r4.0<1>:uw    r3.4<0;1,0>:uw    0x0:uw             
        or (1|M0)     (ne)f0.0   null<1>:uw    r3.5<0;1,0>:uw    r4.0<0;1,0>:uw   {I@1}
(f0.0)  sel (1|M0)               r7.20<2>:b    r5.6<0;1,0>:w     0:w               {F@1}
        cmp (1|M0)    (ne)f1.1   null<1>:uw    r7.20<0;1,0>:ub   0x0:uw              {I@1}
(W)     and (1|M0)               f0.0<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(~f0.0.any16h) goto (16|M0)                  L8960                  L8960                
L8840:
(W)     mov (1|M0)               r1.3<1>:hf    0x1:hf                             
        and (1|M0)               r1.2<1>:d     r7.2<0;1,0>:d     -2139095041:d              
(W)     mov (1|M0)               r4.0<1>:f     0x800000:f                               {Compacted}
        shl (1|M0)               r7.4<1>:d     r7.4<0;1,0>:d     23:w              
(f1.0)  sel (1|M0)               r2.6<1>:d     r1.3<0;1,0>:w     0:w               {F@2}
        add (1|M0)               r7.4<1>:d     r7.4<0;1,0>:d     1065353216:d               {I@2}
        bfn.0xFE (1|M0)          r1.2<1>:ud    r1.2<0;0>:ud      r2.6<0;0>:ud      r4.0<0>:ud       {A@1} // s0|s1|s2
        mul (1|M0)               r7.4<1>:f     r7.4<0;1,0>:f     r1.2<0;1,0>:f    {A@1}
L8960:
        join (16|M0)                         L9312                                
L8976:
        and (1|M0)               r1.2<1>:d     r7.2<0;1,0>:d     -2147483648:d               {F@1}
        shl (1|M0)               r7.2<1>:d     r7.2<0;1,0>:d     1:w              
(W)     mov (1|M0)               r1.3<1>:hf    0x1:hf                             
        and (1|M0)               r1.3<1>:d     r7.2<0;1,0>:d     8388606:d               {I@1}
        and (1|M0)    (eq)f0.0   r7.2<1>:d     r7.2<0;1,0>:d     8388608:d              
(W)     mov (1|M0)               r3.2<1>:f     1.469368e-38:f                               {Compacted}
(f0.1)  sel (1|M0)               r2.6<1>:d     r1.3<0;1,0>:w     0:w               {F@2}
(W)     mov (1|M0)               r4.1<1>:f     0x800000:f                               {Compacted}
        or (1|M0)                r2.6<1>:d     r1.2<0;1,0>:d     r2.6<0;1,0>:d    {I@1}
(f0.0)  sel (1|M0)               r4.0<1>:d     r3.2<0;1,0>:d     12582912:d               {F@2}
        mov (1|M0)               r5.3<1>:f     0.25:f                               {Compacted}
        bfn.0xFE (1|M0)          r2.6<1>:ud    r4.1<0;0>:ud      r2.6<0;0>:ud      r1.3<0>:ud       {A@2} // s0|s1|s2
        or (1|M0)                r4.0<1>:d     r4.0<0;1,0>:d     r1.2<0;1,0>:d    {Compacted,I@2}
        or (1|M0)                r2.7<1>:d     r1.2<0;1,0>:d     8388608:d              
        mad (1|M0)               r2.6<1>:f     r4.0<0;0>:f       r5.3<0;0>:f       r2.6<0>:f        {A@1}
        cmp (1|M0)    (eq)f0.1   null<1>:uw    r7.20<0;1,0>:ub   0x0:uw             
        add (1|M0)               r2.6<1>:f     r2.6<0;1,0>:f     -r2.7<0;1,0>:f   {A@1}
        mul (1|M0)               r2.7<1>:f     r2.7<0;1,0>:f     r2.7<0;1,0>:f   
        and (1|M0)    (ne)f0.0   null<1>:d     r7.3<0;1,0>:d     1:w              
        and (1|M0)               r2.7<1>:d     r2.7<0;1,0>:d     -2:w               {F@1}
        or (1|M0)                r2.7<1>:d     r2.7<0;1,0>:d     r2.6<0;1,0>:d    {I@1}
(~f0.1) mov (1|M0)               r2.7<1>:f     r7.4<0;1,0>:f                    {I@1}
(f0.0)  mov (1|M0)               r18.0<1>:f    r2.7<0;1,0>:f                    {F@1}
L9312:
        join (16|M0)                         L9664                                
L9328:
        add (1|M0)               r2.6<1>:d     r6.7<0;1,0>:d     126:w              
(W)     mov (1|M0)               r1.3<1>:uw    r7.12<0;1,0>:ub                 
        cmp (1|M0)    (gt)f0.0   null<1>:ud    r2.6<0;1,0>:ud    0x17A:uw              {A@1}
        mad (1|M0)               r8.0<1>:f     r7.1<0;0>:f       r7.0<0;0>:f       r8.0<0>:f       
        or (1|M0)                r3.4<1>:w     r8.10<0;1,0>:ub   r1.3<0;1,0>:uw   {I@2}
(W)     and (1|M0)               f1.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
(~f1.1.any16h) goto (16|M0)                  L9520                  L9520                
L9440:
(f0.0)  sel (1|M0)               r1.2<1>:d     r6.7<0;1,0>:d     0:w              
        asr (1|M0)               r1.2<1>:d     r1.2<0;1,0>:d     11:w               {I@1}
        add (1|M0)               r1.3<1>:d     r1.2<0;1,0>:d     248:w               {I@1}
        xor (1|M0)               r1.3<1>:d     r1.3<0;1,0>:d     r1.2<0;1,0>:d    {I@1}
(f0.0)  mov (1|M0)               r6.7<1>:d     r1.3<0;1,0>:d                    {I@1}
L9520:
        join (16|M0)                         L9664                                
L9536:
        asr (1|M0)               r1.2<1>:d     r6.7<0;1,0>:d     1:w               {I@2}
        cmp (1|M0)    (eq)f1.1   null<1>:w     r3.4<0;1,0>:w     0:w              
        add (1|M0)               r6.7<1>:d     r6.7<0;1,0>:d     -r1.2<0;1,0>:d   {I@2}
        shl (1|M0)               r1.2<1>:d     r1.2<0;1,0>:d     23:w              
        shl (1|M0)               r6.7<1>:d     r6.7<0;1,0>:d     23:w               {I@2}
        add (1|M0)               r1.2<1>:d     r1.2<0;1,0>:d     r8.0<0;1,0>:d    {A@1}
        add (1|M0)               r6.7<1>:d     r6.7<0;1,0>:d     1065353216:d               {I@2}
(f1.1)  mul (1|M0)               r18.0<1>:f    r6.7<0;1,0>:f     r1.2<0;1,0>:f    {I@1}
L9664:
        join (16|M0)                         L9680                                
L9680:
        sync.nop                             null                             {Compacted,F@1}
        math.inv (1|M0)          r1.2<1>:f     r45.1<0;1,0>:f                   {$10}
        mov (1|M0)               r1.4<1>:ud    0x3F800000:ud                             
        mul (1|M0)               r1.3<1>:f     r1.2<0;1,0>:f     r45.0<0;1,0>:f   {$10.dst}
        mad (1|M0)               r1.4<1>:f     r1.4<0;0>:f       r1.2<0;0>:f       -r45.1<0>:f      {I@1}
        mad (1|M0)               r2.6<1>:f     r45.0<0;0>:f      r1.3<0;0>:f       -r45.1<0>:f      {F@2}
        mad (1|M0)               r1.4<1>:f     r1.2<0;0>:f       r1.2<0;0>:f       r1.4<0>:f        {F@2}
        cmp (1|M0)    (eq)f1.0   null<1>:uw    r8.8<0;1,0>:ub    0x0:uw             
        mad (1|M0)               r2.6<1>:f     r1.3<0;0>:f       r1.4<0;0>:f       r2.6<0>:f        {F@1}
        mad (1|M0)               r45.0<1>:f    r45.0<0;0>:f      r2.6<0;0>:f       -r45.1<0>:f      {F@1}
(f1.0)  mad (1|M0)               r18.0<1>:f    r2.6<0;0>:f       r1.4<0;0>:f       r45.0<0>:f       {F@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        ret (16|M0)                          r6.0                             {A@1}
L9896:
        mov (1|M0)               r1.2<1>:d     cr0.0<0;1,0>:ud                  {A@1}
        and (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   -1265:w               {A@1}
        or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   1264:w               {A@1}
        mad (1|M0)               r7.2<1>:f     r2.1<0;0>:f       r2.0<0;0>:f       r7.2<0>:f        {A@1}
        mov (1|M0)               cr0.0<1>:ud   r1.2<0;1,0>:d                    {A@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        ret (16|M0)                          r3.2                             {A@1}
L10024:
(W)     shr (16|M0)              r7.0<1>:ud    r25.0<1;1,0>:ud   0x17:uw              {F@1}
(W)     and (16|M0)              r78.0<1>:w    r7.0<2;1,0>:w     255:w               {I@1}
(W)     add (16|M0)              r11.0<1>:d    r78.0<1;1,0>:uw   -191:w               {I@1}
(W)     cmp (16|M0)   (lt)f1.0   null<1>:d     r11.0<1;1,0>:ud   0xFFFFFF82:ud              {I@1}
(W)     shr (16|M0)              r9.0<1>:ud    r23.0<1;1,0>:ud   0x17:uw             
(W)     mov (1|M0)               r45.14<1>:uw  f1.0<0;1,0>:uw                   {Compacted}
(W)     and (16|M0)              r77.0<1>:w    r9.0<2;1,0>:w     255:w               {I@2}
(W)     mov (1|M0)               f0.1<1>:uw    r45.14<0;1,0>:uw                 {I@2}
(W)     add (16|M0)              r13.0<1>:d    r77.0<1;1,0>:uw   -191:w               {I@2}
(W)     mov (16|M0)              r33.0<1>:d    r78.0<1;1,0>:uw                 
(W&~f0.1) cmp (16|M0) (lt)f0.1   null<1>:d     r13.0<1;1,0>:ud   0xFFFFFF81:ud              {I@2}
(W)     mov (16|M0)              r43.0<1>:d    r78.0<1;1,0>:uw                 
(W)     mov (1|M0)               r45.14<1>:uw  f0.1<0;1,0>:uw                   {Compacted}
(W)     mov (16|M0)              r41.0<1>:d    r77.0<1;1,0>:uw                 
(W)     mov (1|M0)               f0.0<1>:uw    r45.14<0;1,0>:uw                 {I@2}
(W)     mov (16|M0)              r39.0<1>:d    r77.0<1;1,0>:uw                 
(~f0.0.any16h) goto (16|M0)                  L12832                  L12832                
L10280:
(W)     add (16|M0)              r7.0<1>:d     r78.0<1;1,0>:uw   -255:w              
(W)     cmp (16|M0)   (lt)f0.0   null<1>:d     r7.0<1;1,0>:ud    0xFFFFFF02:ud              {I@1}
(W)     add (16|M0)              r9.0<1>:d     r77.0<1;1,0>:uw   -255:w              
(W&~f0.0) cmp (16|M0) (lt)f0.0   null<1>:d     r9.0<1;1,0>:ud    0xFFFFFF02:ud              {I@1}
(W)     mov (16|M0)              r46.0<1>:f    (abs)r25.0<1;1,0>:f              {Compacted}
(f0.0.any16h) goto (16|M0)                   L10440                  L10440                
L10368:
(W)     mov (16|M0)              r7.0<1>:f     (abs)r23.0<1;1,0>:f              {Compacted}
(W)     add (16|M0)              r46.0<1>:d    r46.0<1;1,0>:d    -r7.0<1;1,0>:d   {Compacted,A@1}
(W)     mov (4|M0)               r72.0<1>:d    0:w                              
(W)     mov (16|M0)              r21.0<1>:f    r25.0<1;1,0>:f                   {Compacted}
(W)     mov (16|M0)              r37.0<1>:f    r23.0<1;1,0>:f                   {Compacted}
(W)     asr (16|M0)              r46.0<1>:d    r46.0<1;1,0>:d    23:w               {Compacted,I@2}
        goto (16|M0)                         L10440                  L11696                
L10440:
        join (16|M0)                         L11696                                
L10456:
(W)     mov (16|M0)              r48.0<1>:f    (abs)r23.0<1;1,0>:f              {Compacted}
(W)     cmp (16|M0)   (gt)f1.1   null<1>:d     r46.0<1;1,0>:ud   0x7F800000:ud              {I@3}
(W)     cmp (16|M0)   (lt)f1.0   null<1>:d     r48.0<1;1,0>:ud   0x7F800001:ud              {F@1}
(W)     mov (1|M0)               r1.3<1>:uw    f1.1<0;1,0>:uw                  
(W)     and (16|M0)              r52.0<1>:ud   r25.0<1;1,0>:ud   0x7F800000:ud             
(W)     or (1|M0)                f0.1<1>:uw    f1.0<0;1,0>:uw    r1.3<0;1,0>:uw   {I@2}
(W)     and (16|M0)              r60.0<1>:ud   r23.0<1;1,0>:ud   0x7F800000:ud             
(W)     mov (1|M0)               r2.12<1>:uw   f1.0<0;1,0>:uw                   {Compacted}
(W)     cmp (16|M0)   (ne)f1.0   null<1>:d     r52.0<1;1,0>:d    2139095040:d               {I@4}
(W&f0.1) sel (16|M0)             acc0.0<1>:f   r25.0<1;1,0>:f    r23.0<1;1,0>:f  
(W)     or (1|M0)                r3.4<1>:uw    f1.1<0;1,0>:uw    ~r2.12<0;1,0>:uw {I@2}
(W)     cmp (16|M0)   (ne)f0.1   null<1>:d     r60.0<1;1,0>:d    2139095040:d               {F@1}
(W)     or (1|M0)                r3.5<1>:uw    f1.0<0;1,0>:uw    r3.4<0;1,0>:uw   {I@2}
(W)     or (1|M0)                r3.4<1>:uw    ~f1.0<0;1,0>:uw   r3.4<0;1,0>:uw  
(W)     mov (1|M0)               r2.12<1>:hf   -qnan(0x1FF):hf                             
(W)     or (1|M0)                r1.3<1>:uw    f0.1<0;1,0>:uw    r3.4<0;1,0>:uw   {I@1}
(W)     or (1|M0)                r3.4<1>:uw    ~f0.1<0;1,0>:uw   r3.4<0;1,0>:uw  
(W)     mov (1|M0)               r4.0<1>:f     -0.0:f                               {Compacted}
(W)     mov (1|M0)               f1.0<1>:uw    r3.4<0;1,0>:uw                   {I@1}
(W)     mov (1|M0)               f1.1<1>:uw    r3.5<0;1,0>:uw                  
(W)     bfn.0x6A (16|M0)         r19.0<1>:ud   r25.0<1;0>:ud     r23.0<1;0>:ud     r4.0<0>:ud       {F@1} // s0^s1&s2
(W&f1.0) sel (16|M0)             r13.0<2>:b    r2.12<0;1,0>:w    0:w              
(W)     cmp (16|M0)   (eq)f1.0   null<1>:f     r23.0<1;1,0>:f    0.0:f               {A@1}
(W)     bfn.0x6A (16|M0)         r11.0<1>:ud   r23.0<1;0>:ud     r25.0<1;0>:ud     r4.0<0>:ud       // s0^s1&s2
(W)     and (1|M0)               r4.0<1>:uw    f1.0<0;1,0>:uw    ~r3.4<0;1,0>:uw 
(W)     add (16|M0)              r19.0<1>:f    r19.0<1;1,0>:f    -r11.0<1;1,0>:f  {Compacted,I@2}
(W)     mov (1|M0)               f0.1<1>:uw    r4.0<0;1,0>:uw                   {I@1}
(W&f1.1) add (16|M0)             r19.0<1>:f    acc0.0<1;1,0>:f   r23.0<1;1,0>:f  
(W)     mov (1|M0)               f1.1<1>:uw    r1.3<0;1,0>:uw                   {F@1}
(W)     and (16|M0)              r9.0<1>:ud    r23.0<1;1,0>:ud   0x80000000:ud             
(W)     and (16|M0)              r50.0<1>:ud   r25.0<1;1,0>:ud   0x80000000:ud             
(W)     mov (16|M0)              r72.0<1>:b    r13.0<2;1,0>:b                  
(W&~f1.1) mul (16|M0)            r19.0<1>:f    r9.0<1;1,0>:f     r25.0<1;1,0>:f   {I@3}
(~f0.1) goto (16|M0)                         L11088                  L11088                
L10968:
(W)     cmp (16|M0)   (eq)f1.1   null<1>:f     r25.0<1;1,0>:f    0.0:f              
(W)     mov (1|M0)               r1.2<1>:ud    0x7F800000:ud                             
(W)     mov (1|M0)               r2.24<2>:b    -1:w                              
(W&f1.1) mov (16|M0)             r50.0<1>:ud   0:w                              
(W)     bfn.0x96 (16|M0)         r50.0<1>:ud   r1.2<0;0>:ud      r50.0<1;0>:ud     r23.0<1>:ud      {I@1} // s0^s1^s2
(W&f1.1) mul (16|M0)             r50.0<1>:f    r50.0<1;1,0>:f    r25.0<1;1,0>:f   {I@1}
        mov (16|M0)              r72.0<1>:b    r2.24<0;1,0>:b                  
        mov (16|M0)              r19.0<1>:f    r50.0<1;1,0>:f                   {Compacted,F@1}
L11088:
        join (16|M0)                         L11696                                
L11104:
(W)     cmp (16|M0)   (eq)f0.1   null<1>:f     r25.0<1;1,0>:f    0.0:f              
(W&f0.1) cmp (16|M0)  (eq)f0.1   null<1>:w     r72.0<1;1,0>:ub   0x0:uw              {A@1}
(W&~f0.1) sel (16|M0)            r4.0<2>:b     r72.0<1;1,0>:b    -1:w              
(W)     mov (16|M0)              r72.0<1>:b    r4.0<2;1,0>:b                    {I@1}
(W)     cmp (16|M0)   (ne)f1.1   null<1>:w     r72.0<1;1,0>:ub   0x0:uw              {I@1}
(W&f0.1) mul (16|M0)             r19.0<1>:f    r25.0<1;1,0>:f    r23.0<1;1,0>:f  
(f1.1.all16h) goto (16|M0)                   L11696                  L12832                
L11216:
(W)     cmp (16|M0)   (eq)f0.1   null<1>:w     r72.0<1;1,0>:ub   0x0:uw              {F@1}
(W)     mov (1|M0)               r1.3<1>:uw    f0.0<0;1,0>:uw                  
(W)     cmp (16|M0)   (eq)f1.0   null<1>:d     r52.0<1;1,0>:d    0:w              
(W)     and (1|M0)               f0.0<1>:uw    f0.1<0;1,0>:uw    r1.3<0;1,0>:uw   {I@2}
(W)     mov (16|M0)              r35.0<1>:d    0:w                              
(W)     mov (1|M0)               r2.12<1>:uw   f1.0<0;1,0>:uw                   {Compacted}
(W)     mov (16|M0)              r21.0<1>:f    r25.0<1;1,0>:f                   {Compacted}
(W)     and (1|M0)               f1.1<1>:uw    f0.0<0;1,0>:uw    r2.12<0;1,0>:uw  {I@1}
(W)     mov (16|M0)              r66.0<1>:f    r35.0<1;1,0>:f                   {Compacted}
(~f1.1) goto (16|M0)                         L11448                  L11448                
L11352:
        mul (16|M0)              r21.0<1>:f    r25.0<1;1,0>:f    0x4F800000:f               {Compacted}
(W)     shr (16|M0)              r7.0<1>:ud    r21.0<1;1,0>:ud   0x17:uw              {F@1}
(W)     and (16|M0)              r4.0<1>:w     r7.0<2;1,0>:w     255:w               {I@1}
        add (16|M0)              r43.0<1>:d    r4.0<1;1,0>:uw    -32:w               {I@1}
(W)     mov (16|M0)              r66.0<1>:d    0:w                              
(W)     mov (16|M0)              r33.0<1>:f    r43.0<1;1,0>:f                   {Compacted,I@2}
        mov (16|M0)              r66.0<1>:d    -32:w                              
L11448:
        join (16|M0)                         L11696                                
L11464:
(W)     cmp (16|M0)   (eq)f0.1   null<1>:d     r60.0<1;1,0>:d    0:w              
(W)     mov (16|M0)              r37.0<1>:f    r23.0<1;1,0>:f                   {Compacted}
(W)     mov (1|M0)               r1.3<1>:uw    f0.1<0;1,0>:uw                  
(W)     and (1|M0)               f1.0<1>:uw    f0.0<0;1,0>:uw    r1.3<0;1,0>:uw   {I@1}
(~f1.0) goto (16|M0)                         L11640                  L11640                
L11536:
        mul (16|M0)              r37.0<1>:f    r23.0<1;1,0>:f    0x4F800000:f               {Compacted}
(W)     shr (16|M0)              r7.0<1>:ud    r37.0<1;1,0>:ud   0x17:uw              {F@1}
(W)     and (16|M0)              r4.0<1>:w     r7.0<2;1,0>:w     255:w               {I@1}
        add (16|M0)              r39.0<1>:d    r4.0<1;1,0>:uw    -32:w               {I@1}
(W)     mov (16|M0)              r35.0<1>:d    0:w                              
(W)     mov (16|M0)              r48.0<1>:f    (abs)r37.0<1;1,0>:f              {Compacted}
(W)     mov (16|M0)              r41.0<1>:f    r39.0<1;1,0>:f                   {Compacted,I@2}
        mov (16|M0)              r35.0<1>:d    32:w                              
L11640:
        join (16|M0)                         L11696                                
L11656:
(W)     mov (16|M0)              r46.0<1>:f    (abs)r21.0<1;1,0>:f              {Compacted}
(W)     add (16|M0)              r46.0<1>:d    r46.0<1;1,0>:d    -r48.0<1;1,0>:d  {Compacted,F@1}
(W)     asr (16|M0)              r46.0<1>:d    r46.0<1;1,0>:d    23:w               {Compacted,I@1}
(W)     add3 (16|M0)             r35.0<1>:d    r35.0<1;0>:d      r66.0<1;0>:d      r46.0<1>:d       {I@1}
L11696:
        join (16|M0)                         L12832                                
L11712:
(W)     mov (1|M0)               r1.2<1>:f     1.0:f                               {Compacted}
(W)     mov (1|M0)               r4.0<1>:f     0x807FFFFF:f                              
(W&~f0.0) mov (16|M0)            r35.0<1>:f    r46.0<1;1,0>:f                   {I@2}
(W)     bfn.0xEA (16|M0)         r37.0<1>:ud   r1.2<0;0>:ud      r37.0<1;0>:ud     r4.0<0>:ud       {A@2} // s0|s1&s2
(W)     add (16|M0)              r58.0<1>:d    r35.0<1;1,0>:d    126:w               {Compacted,F@1}
(W)     add (16|M0)              r7.0<1>:d     -r35.0<1;1,0>:d   -152:w               {Compacted}
        sync.nop                             null                             {Compacted,I@3}
(W)     math.inv (16|M0)         r9.0<1>:f     r37.0<1;1,0>:f                   {$11}
(W)     cmp (16|M0)   (eq)f1.1   null<1>:w     r72.0<1;1,0>:ub   0x0:uw             
(W)     and (16|M0)              r7.0<1>:d     r7.0<1;1,0>:d     r58.0<1;1,0>:d   {Compacted,I@2}
(W)     mov (1|M0)               r2.6<1>:f     1.0:f                               {Compacted}
(W)     bfn.0xEA (16|M0)         r21.0<1>:ud   r1.2<0;0>:ud      r21.0<1;0>:ud     r4.0<0>:ud       // s0|s1&s2
(W)     asr (16|M0)              r7.0<1>:d     r7.0<1;1,0>:d     31:w               {Compacted,I@2}
        sync.nop                             null                             {Compacted,$11.dst}
(W)     mad (16|M0)              r56.0<1>:f    r2.6<0;0>:f       r9.0<1;0>:f       -r37.0<1>:f      {F@1}
(W)     mul (16|M0)              acc0.0<1>:f   r9.0<1;1,0>:f     r21.0<1;1,0>:f   {Compacted,I@2}
(W&f1.1) sel (16|M0)             r76.0<1>:w    r7.0<4;1,0>:ub    0:w               {I@1}
(W)     mad (16|M0)              r56.0<1>:f    r9.0<1;0>:f       r9.0<1;0>:f       r56.0<1>:f       {Compacted,F@2}
(W)     mad (16|M0)              r54.0<1>:f    r21.0<1;0>:f      acc0.0<1;0>:f     -r37.0<1>:f     
(W)     cmp (16|M0)   (ne)f1.0   null<1>:w     r76.0<2;1,0>:ub   0x0:uw              {I@1}
(W)     mad (16|M0)              r54.0<1>:f    acc0.0<1;0>:f     r56.0<1;0>:f      r54.0<1>:f       {F@1}
(W)     add (16|M0)              r33.0<1>:d    r33.0<1;1,0>:d    -r41.0<1;1,0>:d  {Compacted}
(W)     mad (16|M0)              r21.0<1>:f    r21.0<1;0>:f      r54.0<1;0>:f      -r37.0<1>:f      {Compacted,F@1}
(~f1.0.any16h) goto (16|M0)                  L12576                  L12576                
L12000:
(W)     mov (16|M0)              r62.0<1>:ud   r21.0<1;1,0>:ud                  {F@1}
(W)     mov (16|M0)              r70.0<1>:f    r56.0<1;1,0>:f                   {Compacted}
(W)     mov (16|M0)              r68.0<1>:f    r54.0<1;1,0>:f                   {Compacted}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r3.2          L13040                                 {A@1}
L12080:
(W)     add (16|M0)              r35.0<1>:d    r35.0<1;1,0>:d    125:w               {Compacted}
(W)     cmp (16|M0)   (lt)f0.1   null<1>:d     r35.0<1;1,0>:d    -2:w               {I@1}
(W)     cmp (16|M0)   (eq)f1.0   null<1>:f     r21.0<1;1,0>:f    0.0:f              
(W)     mov (1|M0)               r1.3<1>:uw    f0.1<0;1,0>:uw                  
(W)     or (1|M0)                f1.1<1>:uw    f1.0<0;1,0>:uw    r1.3<0;1,0>:uw   {I@1}
(f1.1.any16h) goto (16|M0)                   L12216                  L12216                
L12168:
(W)     mov (1|M0)               r1.3<1>:hf    0x1:hf                              {I@2}
(W&f1.0) sel (16|M0)             r64.0<1>:d    r1.3<0;1,0>:w     0:w               {F@1}
        goto (16|M0)                         L12216                  L12336                
L12216:
        join (16|M0)                         L12336                                
L12232:
(W)     mov (1|M0)               r1.3<1>:hf    0x1:hf                              {I@3}
(W)     and (16|M0)              r7.0<1>:d     r62.0<1;1,0>:d    -2139095041:d              
(W)     mov (1|M0)               r4.0<1>:f     0x800000:f                               {Compacted}
(W)     shl (16|M0)              r58.0<1>:d    r58.0<1;1,0>:d    23:w               {Compacted}
(W&f1.0) sel (16|M0)             r64.0<1>:d    r1.3<0;1,0>:w     0:w               {F@2}
(W)     add (16|M0)              r58.0<1>:d    r58.0<1;1,0>:d    1065353216:d               {I@2}
(W)     bfn.0xFE (16|M0)         r7.0<1>:ud    r7.0<1;0>:ud      r64.0<1;0>:ud     r4.0<0>:ud       {A@1} // s0|s1|s2
(W)     mul (16|M0)              r58.0<1>:f    r58.0<1;1,0>:f    r7.0<1;1,0>:f    {Compacted,A@1}
L12336:
        join (16|M0)                         L12576                                
L12352:
(W)     and (16|M0)   (eq)f0.0   null<1>:ud    r62.0<1;1,0>:ud   0x400000:ud             
(W)     shl (16|M0)              r7.0<1>:d     r62.0<1;1,0>:d    1:w               {Compacted,F@1}
(W)     mov (1|M0)               r1.2<1>:f     0x800000:f                               {Compacted}
(W)     mov (1|M0)               r4.0<1>:f     -0.0:f                               {Compacted}
(W)     mov (1|M0)               r2.6<1>:f     1.469368e-38:f                               {Compacted}
(W)     and (16|M0)              r7.0<1>:d     r7.0<1;1,0>:d     8388606:d               {I@1}
(W)     bfn.0xEA (16|M0)         r9.0<1>:ud    r1.2<0;0>:ud      r62.0<1;0>:ud     r4.0<0>:ud       {A@2} // s0|s1&s2
(W&f0.0) sel (16|M0)             r11.0<1>:d    r2.6<0;1,0>:d     12582912:d               {F@1}
(W)     mov (1|M0)               r3.2<1>:f     0.25:f                               {Compacted}
(W)     bfn.0xFE (16|M0)         r64.0<1>:ud   r64.0<1;0>:ud     r9.0<1;0>:ud      r7.0<1>:ud       {I@2} // s0|s1|s2
(W)     bfn.0xEA (16|M0)         r11.0<1>:ud   r11.0<1;0>:ud     r62.0<1;0>:ud     r4.0<0>:ud       {I@2} // s0|s1&s2
(W)     mad (16|M0)              r64.0<1>:f    r11.0<1;0>:f      r64.0<1;0>:f      r3.2<0>:f        {Compacted,A@1}
(W)     add (16|M0)              r64.0<1>:f    r64.0<1;1,0>:f    -r9.0<1;1,0>:f   {Compacted,F@1}
(W)     mul (16|M0)              r9.0<1>:f     r9.0<1;1,0>:f     r9.0<1;1,0>:f    {Compacted}
(W)     and (16|M0)   (ne)f0.1   null<1>:w     r76.0<2;1,0>:ub   1:w              
(W)     bfn.0xAE (16|M0)         r64.0<1>:ud   r64.0<1;0>:ud     r9.0<1;0>:ud      0x1:uw              {A@1} // s0|s1&~s2
(W&~f1.1) mov (16|M0)            r58.0<1>:f    r64.0<1;1,0>:f                   {I@1}
(W&f0.1) mov (16|M0)             r19.0<1>:f    r58.0<1;1,0>:f                   {F@1}
L12576:
        join (16|M0)                         L12832                                
L12592:
(W)     add (16|M0)              r7.0<1>:d     r33.0<1;1,0>:d    -253:w               {Compacted}
(W)     cmp (16|M0)   (lt)f1.0   null<1>:d     r7.0<1;1,0>:ud    0xFFFFFE85:ud              {I@1}
(W)     mov (1|M0)               r1.3<1>:hf    -qnan(0x1FF):hf                             
(W)     asr (16|M0)              r9.0<1>:d     r33.0<1;1,0>:d    11:w               {Compacted}
(W&f1.0.any16h) sel (1|M0)       r2.12<1>:w    r1.3<0;1,0>:w     0:w               {F@1}
(W)     add (16|M0)              r11.0<1>:d    r9.0<1;1,0>:d     248:w               {Compacted,I@2}
(W)     mov (1|M0)               f0.0<1>:uw    r2.12<0;1,0>:uw                  {I@2}
(W)     mov (16|M0)              r13.0<1>:f    r33.0<1;1,0>:f                   {Compacted}
(W&f1.0) xor (16|M0)             r13.0<1>:d    r11.0<1;1,0>:d    r9.0<1;1,0>:d    {A@1}
(W&~f0.0) mov (16|M0)            r13.0<1>:f    r33.0<1;1,0>:f                   {I@1}
(W)     asr (16|M0)              r15.0<1>:d    r13.0<1;1,0>:d    1:w               {Compacted,F@1}
(W)     mov (16|M0)              r4.0<1>:uw    r72.0<1;1,0>:ub                 
(W)     add (16|M0)              r13.0<1>:d    r13.0<1;1,0>:d    -r15.0<1;1,0>:d  {Compacted,I@2}
(W)     mad (16|M0)              r21.0<1>:f    r54.0<1;0>:f      r56.0<1;0>:f      r21.0<1>:f       {Compacted}
(W)     or (16|M0)    (eq)f1.1   null<1>:w     r76.0<2;1,0>:ub   r4.0<1;1,0>:uw   {I@2}
(W)     shl (16|M0)              r15.0<1>:d    r15.0<1;1,0>:d    23:w               {Compacted}
(W)     shl (16|M0)              r13.0<1>:d    r13.0<1;1,0>:d    23:w               {Compacted,I@3}
(W)     add (16|M0)              r15.0<1>:d    r15.0<1;1,0>:d    r21.0<1;1,0>:d   {Compacted,A@1}
(W)     add (16|M0)              r13.0<1>:d    r13.0<1;1,0>:d    1065353216:d               {I@2}
(W&f1.1) mul (16|M0)             r19.0<1>:f    r15.0<1;1,0>:f    r13.0<1;1,0>:f   {A@1}
L12832:
        join (16|M0)                         L12848                                
L12848:
(W)     math.inv (16|M0)         r7.0<1>:f     r23.0<1;1,0>:f                   {$12}
(W)     mov (1|M0)               r1.2<1>:ud    0x3F800000:ud                             
(W)     mul (16|M0)              acc0.0<1>:f   r7.0<1;1,0>:f     r25.0<1;1,0>:f   {Compacted,$12.dst}
(W)     mad (16|M0)              acc2.0<1>:f   r1.2<0;0>:f       r7.0<1;0>:f       -r23.0<1>:f      {I@1}
(W)     mad (16|M0)              r13.0<1>:f    r25.0<1;0>:f      acc0.0<1;0>:f     -r23.0<1>:f     
(W)     mad (16|M0)              acc2.0<1>:f   r7.0<1;0>:f       acc2.0<1;0>:f     r7.0<1>:f        {Compacted}
(W)     mov (1|M0)               f1.1<1>:uw    r45.14<0;1,0>:uw                 {F@5}
(W)     mad (16|M0)              acc0.0<1>:f   acc0.0<1;0>:f     acc2.0<1;0>:f     r13.0<1>:f       {F@2}
(W)     mad (16|M0)              r25.0<1>:f    r25.0<1;0>:f      acc0.0<1;0>:f     -r23.0<1>:f     
(W&~f1.1) mad (16|M0)            r19.0<1>:f    acc0.0<1;0>:f     acc2.0<1;0>:f     r25.0<1>:f       {F@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        ret (16|M0)                          r6.0                             {A@1}
L13040:
(W)     mov (1|M0)               r1.2<1>:d     cr0.0<0;1,0>:ud                  {A@1}
(W)     and (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   -1265:w               {A@1}
(W)     or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   1264:w               {A@1}
(W)     mad (16|M0)              r62.0<1>:f    r68.0<1;0>:f      r70.0<1;0>:f      r62.0<1>:f       {Compacted,A@1}
(W)     mov (1|M0)               cr0.0<1>:ud   r1.2<0;1,0>:d                    {A@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        ret (16|M0)                          r3.2                             {A@1}
L13160:
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
