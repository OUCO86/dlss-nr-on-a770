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
        mov (1|M0)               r103.4<1>:d   r0.1<0;1,0>:ud                   {A@1}
        and (1|M0)               r43.0<2>:b    r5.12<0;1,0>:b    1:w               {$1.dst}
        mov (1|M0)               r43.1<1>:d    r1.0<0;1,0>:uw                   {$0.dst}
        mov (1|M0)               r103.1<1>:d   r2.2<0;1,0>:d                   
        mov (1|M0)               r103.0<1>:d   r103.4<0;1,0>:d                  {I@4}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r103.2        L9560                                 {A@1}
L336:
        asr (1|M0)               r103.5<1>:d   r2.3<0;1,0>:d     31:w              
        mov (1|M0)               r43.4<1>:d    r90.6<0;1,0>:d                  
        shr (1|M0)               r103.5<1>:ud  r103.5<0;1,0>:ud  0x1A:uw              {I@2}
(W)     mul (1|M0)               acc0.0<1>:d   r43.4<0;1,0>:d    r2.4<0;1,0>:uw   {I@2}
        mach (1|M0)              r2.0<1>:d     r43.4<0;1,0>:d    r2.2<0;1,0>:d   
        add (1|M0)               r103.5<1>:d   r2.3<0;1,0>:d     r103.5<0;1,0>:d  {I@3}
        add (1|M0)               r103.4<1>:d   r103.4<0;1,0>:d   -r2.0<0;1,0>:d   {I@2}
        asr (1|M0)               r103.5<1>:d   r103.5<0;1,0>:d   6:w               {I@2}
        mov (2|M0)               r103.0<1>:d   r103.4<1;1,0>:d                  {I@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r103.2        L9560                                 {A@1}
L528:
        mov (1|M0)               r43.5<1>:d    r43.4<0;1,0>:d                  
(W)     mul (1|M0)               acc0.0<1>:d   r90.6<0;1,0>:d    r103.10<0;1,0>:uw
(W)     mach (1|M0)              r2.0<1>:d     r90.6<0;1,0>:d    r103.5<0;1,0>:d 
        mul (1|M0)               acc0.0<1>:ud  r43.5<0;1,0>:ud   r2.12<0;1,0>:uw  {I@3}
        mach (1|M0)              r7.0<1>:ud    r43.5<0;1,0>:ud   r2.6<0;1,0>:ud   {AccWrEn}
        asr (1|M0)               r43.6<1>:d    r43.4<0;1,0>:d    31:w              
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r43.5<0;1,0>:d    r2.14<0;1,0>:uw 
        mach (1|M0)              r8.0<1>:d     r43.5<0;1,0>:d    r2.7<0;1,0>:d   
(W)     mul (1|M0)               acc0.0<1>:d   r43.6<0;1,0>:d    r2.12<0;1,0>:uw  {Compacted,I@4}
        mov (1|M0)               r103.5<1>:d   r2.0<0;1,0>:d                   
        mach (1|M0)              r2.0<1>:d     r43.6<0;1,0>:d    r2.6<0;1,0>:d    {Compacted}
        addc (1|M0)              r9.0<1>:ud    r2.4<0;1,0>:ud    r6.0<0;1,0>:ud   {AccWrEn,I@6}
        asr (1|M0)               r43.7<1>:d    r3.4<0;1,0>:d     31:w              
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mul (1|M0)               acc0.0<1>:ud  r43.5<0;1,0>:ud   r3.4<0;1,0>:uw  
        shr (1|M0)               r43.7<1>:ud   r43.7<0;1,0>:ud   0x1B:uw              {I@3}
        mach (1|M0)              r12.0<1>:ud   r43.5<0;1,0>:ud   r3.2<0;1,0>:ud   {AccWrEn}
        add (1|M0)               r43.7<1>:d    r3.4<0;1,0>:d     r43.7<0;1,0>:d   {I@2}
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r43.5<0;1,0>:d    r3.6<0;1,0>:uw  
        mach (1|M0)              r13.0<1>:d    r43.5<0;1,0>:d    r3.3<0;1,0>:d   
(W)     mul (1|M0)               acc0.0<1>:d   r43.6<0;1,0>:d    r3.4<0;1,0>:uw  
        add3 (1|M0)              r1.3<1>:d     r2.0<0;0>:d       r7.0<0;0>:d       r8.0<0>:d       
        asr (1|M0)               r43.7<1>:d    r43.7<0;1,0>:d    5:w               {I@6}
        mach (1|M0)              r14.0<1>:d    r43.6<0;1,0>:d    r3.2<0;1,0>:d   
        addc (1|M0)              r2.0<1>:ud    r3.0<0;1,0>:ud    r11.0<0;1,0>:ud  {AccWrEn,I@7}
        add3 (1|M0)              r5.7<1>:d     r10.0<0;0>:d      r2.5<0;0>:d       r1.3<0>:d        {I@4}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r90.6<0;1,0>:d    r43.14<0;1,0>:uw {I@5}
        mach (1|M0)              r8.0<1>:d     r90.6<0;1,0>:d    r43.7<0;1,0>:d  
(W)     mul (1|M0)               acc0.0<1>:d   r90.6<0;1,0>:d    r43.14<0;1,0>:uw
        mach (1|M0)              r10.0<1>:d    r90.6<0;1,0>:d    r43.7<0;1,0>:d  
        add (1|M0)               r6.3<1>:d     r103.4<0;1,0>:d   -r103.5<0;1,0>:d
        add3 (1|M0)              r9.2<1>:d     r14.0<0;0>:d      r12.0<0;0>:d      r13.0<0>:d       {I@7}
        shl (1|M0)               r1.4<1>:d     r10.0<0;1,0>:d    12:w               {Compacted,I@3}
        asr (1|M0)               r10.1<1>:d    r8.0<0;1,0>:d     31:w               {Compacted}
        shl (1|M0)               r7.2<1>:d     r6.3<0;1,0>:d     11:w               {I@4}
        add3 (1|M0)              r7.1<1>:d     r6.0<0;0>:d       r3.1<0;0>:d       r9.2<0>:d        {I@4}
        addc (1|M0)              r6.0<1>:ud    r9.0<0;1,0>:ud    r1.4<0;1,0>:ud   {AccWrEn,I@4}
        shr (1|M0)               r1.3<1>:ud    r10.0<0;1,0>:ud   0x14:uw             
        shl (1|M0)               r1.2<1>:d     r10.1<0;1,0>:d    12:w               {I@5}
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        shl (1|M0)               r10.0<1>:ud   r43.1<0;1,0>:ud   0x7:uw             
        addc (1|M0)              r8.0<1>:ud    r2.0<0;1,0>:ud    r7.2<0;1,0>:ud   {AccWrEn,I@7}
        shr (1|M0)               r2.1<1>:ud    r6.3<0;1,0>:ud    0x15:uw             
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@5}
        mov (1|M0)               r12.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        shl (1|M0)               r1.2<1>:ud    r43.1<0;1,0>:ud   0x6:uw             
        addc (1|M0)              r13.0<1>:ud   r6.0<0;1,0>:ud    r10.0<0;1,0>:ud  {AccWrEn,I@6}
        or (1|M0)                r7.3<1>:d     r2.1<0;1,0>:d     0:w               {I@5}
        add3 (1|M0)              r6.2<1>:d     r11.0<0;0>:d      r5.7<0;0>:d       r1.5<0>:d        {I@5}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r11.0<1>:ud   r8.0<0;1,0>:ud    r1.2<0;1,0>:ud   {AccWrEn,I@5}
        add3 (1|M0)              r8.2<1>:d     r12.0<0;0>:d      r7.1<0;0>:d       r7.3<0>:d        {I@4}
        mov (1|M0)               r2.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r45.0<1>:f    r13.0<0;1,0>:f                   {Compacted}
        add3 (1|M0)              r45.1<1>:d    r9.0<0;0>:d       r6.2<0;0>:d       0:w               {I@4}
        mov (1|M0)               r46.0<1>:f    r11.0<0;1,0>:f                   {Compacted,I@4}
        add3 (1|M0)              r46.1<1>:d    r2.0<0;0>:d       r8.2<0;0>:d       0:w               {I@2}
        send.ugm (1|M0)          r14      r45     null:0  0x0            0x0240D780           {A@2,$2} // wr:1+0, rd:4; load.ugm.d64x16t.a64
        send.ugm (1|M0)          r18      r46     null:0  0x0            0x0220C780           {A@1,$3} // wr:1+0, rd:2; load.ugm.d64x8t.a64
        add (1|M0)               r44.0<1>:ud   r1.2<0;1,0>:ud    0x2000:uw             
        shr (1|M0)               r46.3<1>:ud   r43.1<0;1,0>:ud   0x2:uw              {$3.src}
        and (1|M0)               r43.3<1>:d    r1.0<0;1,0>:uw    3:w              
        add (1|M0)               r43.2<1>:d    r103.4<0;1,0>:d   -r103.5<0;1,0>:d
        send.slm (1|M0)          null     r10     r14:4   0x0            0x0200D704           {$2} // wr:1+4, rd:0; store.slm.d64x16t.a32
        send.slm (1|M0)          null     r44     r18:2   0x0            0x0200C704           {A@4,$3} // wr:1+2, rd:0; store.slm.d64x8t.a32
(W)     send.slm (1|M0)          r7       r0      null:0  0x0            0x0210001F           {$4} // wr:1+0, rd:1; fence.slm.none.group
(W)     mov (1|M0)               r6.2<1>:f     0.0:f                               {Compacted}
(W)     mov (2|M0)               r6.10<1>:ub   r0.11<0;1,0>:ub                  {F@1}
(W)     mov (8|M0)               null<1>:ud    r7.0<1;1,0>:ud                   {$4.dst}
(W)     send.gtwy (1|M0)         null     r6      null:0  0x0            0x02000004           {A@2,$5} // wr:1+0, rd:0; signal barrier
(W)     sync.bar                             null                            
        cmp (1|M0)    (gt)f1.0   null<1>:d     r3.4<0;1,0>:d     31:w              
        shl (1|M0)               r44.1<1>:ud   r46.3<0;1,0>:ud   0x9:uw              {$3.src}
        shl (1|M0)               r44.2<1>:d    r43.3<0;1,0>:d    9:w              
        mov (16|M0)              r47.0<1>:d    0:w                              
(W)     and (1|M0)               f1.1<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
        mov (16|M0)              r49.0<1>:d    0:w                              
        mov (16|M0)              r51.0<1>:d    0:w                              
        mov (16|M0)              r53.0<1>:d    0:w                              
        mov (16|M0)              r55.0<1>:d    0:w                              
        mov (16|M0)              r57.0<1>:d    0:w                              
        mov (16|M0)              r59.0<1>:d    0:w                              
        mov (16|M0)              r61.0<1>:d    0:w                              
        mov (16|M0)              r63.0<1>:d    0:w                              
        mov (16|M0)              r65.0<1>:d    0:w                              
        mov (16|M0)              r67.0<1>:d    0:w                              
        mov (16|M0)              r69.0<1>:d    0:w                              
        mov (16|M0)              r71.0<1>:d    0:w                              
        mov (16|M0)              r73.0<1>:d    0:w                              
        mov (16|M0)              r75.0<1>:d    0:w                              
        mov (16|M0)              r77.0<1>:d    0:w                              
(~f1.1.any16h) goto (16|M0)                  L3200                  L3200                
L1928:
        asr (1|M0)               r1.3<1>:d     r2.3<0;1,0>:d     31:w               {Compacted}
        shr (1|M0)               r2.1<1>:ud    r2.3<0;1,0>:ud    0x1B:uw             
        mov (1|M0)               r45.2<1>:d    r43.7<0;1,0>:d                  
        shl (1|M0)               r2.0<1>:d     r1.3<0;1,0>:d     5:w               {Compacted,I@3}
        shl (1|M0)               r44.5<1>:d    r2.3<0;1,0>:d     5:w              
        mov (1|M0)               r45.4<2>:f    0.0:f                              
        mov (1|M0)               r45.5<2>:f    0.0:f                              
        mov (2|M0)               r44.3<1>:d    r45.2<1;1,0>:d                   {I@3}
        or (1|M0)                r44.6<1>:d    r2.0<0;1,0>:d     r2.1<0;1,0>:d    {I@3}
        asr (1|M0)               r44.4<1>:d    r43.7<0;1,0>:d    31:w              
        mov (1|M0)               r45.3<1>:d    0:w                              
L2088:
        addc (1|M0)              r2.0<1>:ud    r45.4<0;1,0>:ud   0x1:ud              {AccWrEn,F@2}
(W)     mov (1|M0)               r1.3<1>:hf    0x1:hf                             
        mov (1|M0)               r45.6<1>:d    r2.0<0;1,0>:d                    {I@1}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$5.src}
        cmp (1|M0)    (lt)f0.0   null<1>:ud    r45.6<0;1,0>:ud   r44.3<0;1,0>:ud  {I@2}
        add3 (1|M0)              r45.7<1>:d    r6.0<0;0>:d       r45.5<0;0>:d      0:w               {A@2}
        and (1|M0)               r44.7<1>:d    r45.4<0;1,0>:d    1:w              
        cmp (1|M0)    (lt)f1.0   null<1>:d     r45.7<0;1,0>:d    r44.4<0;1,0>:d   {I@2}
(f0.0)  cmp (1|M0)    (eq)f0.0   null<1>:d     r45.7<0;1,0>:d    r44.4<0;1,0>:d  
(f1.0)  sel (1|M0)               r3.10<1>:uw   r1.3<0;1,0>:uw    0x0:uw              {F@1}
(f0.0)  sel (1|M0)               r1.4<1>:uw    r1.3<0;1,0>:uw    0x0:uw             
        or (1|M0)     (ne)f0.1   null<1>:uw    r1.4<0;1,0>:uw    r3.10<0;1,0>:uw  {I@1}
(W)     and (1|M0)               f1.0<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(~f1.0.any16h) goto (16|M0)                  L2744                  L2744                
L2304:
        shl (1|M0)               r1.5<1>:d     r45.6<0;1,0>:d    12:w              
        shl (1|M0)               r1.3<1>:d     r45.7<0;1,0>:d    12:w              
        shr (1|M0)               r1.4<1>:ud    r45.6<0;1,0>:ud   0x14:uw             
        addc (1|M0)              r2.0<1>:ud    r45.0<0;1,0>:ud   r1.5<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r1.6<1>:d     r1.3<0;1,0>:d     r1.4<0;1,0>:d    {I@2}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        sync.nop                             null                             {Compacted,$6.src}
        mov (1|M0)               r7.0<1>:f     r2.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r7.1<1>:d     r6.0<0;0>:d       r45.1<0;0>:d      r1.6<0>:d        {I@1}
        mul (1|M0)               acc0.0<1>:ud  r44.5<0;1,0>:ud   r45.12<0;1,0>:uw
        sync.allrd                           ($2,$8)                
        send.ugm (1|M0)          r8       r7      null:0  0x0            0x0240D780           {A@1,$9} // wr:1+0, rd:4; load.ugm.d64x16t.a64
        mach (1|M0)              r14.0<1>:ud   r44.5<0;1,0>:ud   r45.6<0;1,0>:ud  {AccWrEn}
        xor (1|M0)               r1.2<1>:d     r44.7<0;1,0>:d    1:w              
        mov (1|M0)               r13.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r44.5<0;1,0>:d    r45.14<0;1,0>:uw
        mach (1|M0)              r15.0<1>:d    r44.5<0;1,0>:d    r45.7<0;1,0>:d  
(W)     mul (1|M0)               acc0.0<1>:d   r44.6<0;1,0>:d    r45.12<0;1,0>:uw {Compacted}
        mach (1|M0)              r2.0<1>:d     r44.6<0;1,0>:d    r45.6<0;1,0>:d   {Compacted}
        addc (1|M0)              r6.0<1>:ud    r46.0<0;1,0>:ud   r13.0<0;1,0>:ud  {AccWrEn,I@5}
        shl (1|M0)               r3.5<1>:d     r1.2<0;1,0>:d     12:w              
        add3 (1|M0)              r1.4<1>:d     r2.0<0;0>:d       r14.0<0;0>:d      r15.0<0>:d       {I@3}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$9.src}
        mov (1|M0)               r16.0<1>:f    r6.0<0;1,0>:f                    {Compacted,I@4}
        mad (1|M0)               r12.0<1>:d    r3.5<0;0>:d       r1.0<0;0>:uw      128:w               {I@3}
        add3 (1|M0)              r16.1<1>:d    r7.0<0;0>:d       r46.1<0;0>:d      r1.4<0>:d        {I@2}
        shl (1|M0)               r1.2<1>:d     r1.2<0;1,0>:d     11:w              
        send.slm (1|M0)          null     r12     r8:4    0x0            0x0200D704           {A@3,$9} // wr:1+4, rd:0; store.slm.d64x16t.a32
        sync.nop                             null                             {Compacted,$9.src}
        send.ugm (1|M0)          r8       r16     null:0  0x0            0x0220C780           {A@1,$10} // wr:1+0, rd:2; load.ugm.d64x8t.a64
        add (1|M0)               r10.0<1>:d    r1.2<0;1,0>:d     r44.0<0;1,0>:d   {Compacted,I@1}
        sync.nop                             null                             {Compacted,$10.dst}
        send.slm (1|M0)          null     r10     r8:2    0x0            0x0200C704           {A@1,$8} // wr:1+2, rd:0; store.slm.d64x8t.a32
L2744:
        join (16|M0)                         L3200                                
L2760:
        shl (1|M0)               r1.2<1>:d     r44.7<0;1,0>:d    12:w              
        shl (1|M0)               r44.7<1>:d    r44.7<0;1,0>:d    11:w              
        add (1|M0)               r2.0<1>:d     r1.2<0;1,0>:d     r44.1<0;1,0>:d   {I@2}
        bfn.0xFE (1|M0)          r6.0<1>:ud    0x2000:uw               r44.7<0;0>:ud     r44.2<0>:ud      {I@2} // s0|s1|s2
        bfn.0xFE (1|M0)          r32.0<1>:ud   0x2100:uw               r44.7<0;0>:ud     r44.2<0>:ud      // s0|s1|s2
        sync.nop                             null                             {Compacted,$2.src}
        or (1|M0)                r15.0<1>:ud   r2.0<0;1,0>:ud    0x100:uw              {I@3}
        sync.nop                             null                             {Compacted,$6.src}
        send.slm (1|M0)          r7       r2      null:0  0x0            0x0280E700           {$11} // wr:1+0, rd:8; load.slm.d64x32t.a32
        send.slm (1|M0)          r24      r6      null:0  0x0            0x0280E700           {A@3,$12} // wr:1+0, rd:8; load.slm.d64x32t.a32
        send.slm (1|M0)          r33      r32     null:0  0x0            0x0280E700           {A@2,$13} // wr:1+0, rd:8; load.slm.d64x32t.a32
        send.slm (1|M0)          r16      r15     null:0  0x0            0x0280E700           {A@1,$14} // wr:1+0, rd:8; load.slm.d64x32t.a32
        sync.allwr                           ($6,$11,$12,$13,$14)                
        dpas.8x8 (8|M0)          r71:d         r71:d             r24:b             r7.0:b           {Atomic}
        dpas.8x8 (8|M0)          r63:d         r63:d             r33:b             r7.0:b           {Atomic}
        dpas.8x8 (8|M0)          r55:d         r55:d             r24:b             r16.0:b          {Atomic}
        dpas.8x8 (8|M0)          r47:d         r47:d             r33:b             r16.0:b          {$6}
(W)     send.slm (1|M0)          r41      r0      null:0  0x0            0x0210001F           {$15} // wr:1+0, rd:1; fence.slm.none.group
(W)     mov (1|M0)               r42.2<1>:f    0.0:f                               {Compacted,$7.src}
(W)     mov (2|M0)               r42.10<1>:ub  r0.11<0;1,0>:ub                  {F@1}
(W)     mov (8|M0)               null<1>:ud    r41.0<1;1,0>:ud                  {$15.dst}
(W)     send.gtwy (1|M0)         null     r42     null:0  0x0            0x02000004           {A@2,$7} // wr:1+0, rd:0; signal barrier
(W)     sync.bar                             null                            
        cmp (1|M0)    (eq)f1.1   null<1>:d     r45.7<0;1,0>:d    r45.3<0;1,0>:d  
(f1.1)  cmp (1|M0)    (eq)f1.1   null<1>:d     r45.6<0;1,0>:d    r45.2<0;1,0>:d  
(W)     and (1|M0)               f0.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(f0.1.any16h) goto (16|M0)                   L3200                  L3200                
L3168:
(W)     mov (2|M0)               r45.4<1>:ud   r45.6<1;1,0>:ud                 
        goto.b (16|M0)                       L3200                  L2088                
L3200:
        join (16|M0)                         L3216                                
L3216:
        shl (1|M0)               r1.2<1>:ud    r46.3<0;1,0>:ud   0xC:uw             
        shl (1|M0)               r46.2<1>:d    r43.3<0;1,0>:d    6:w              
        shl (1|M0)               r43.2<1>:d    r43.2<0;1,0>:d    6:w              
        or (1|M0)                r2.0<1>:d     r46.2<0;1,0>:d    r1.2<0;1,0>:d    {I@2}
        mov (1|M0)               r1.2<1>:d     r4.0<0;1,0>:d                   
        sync.nop                             null                             {Compacted,$5.src}
        or (1|M0)                r6.0<1>:ud    r2.0<0;1,0>:ud    0x20:uw              {I@2}
        or (1|M0)                r7.0<1>:ud    r2.0<0;1,0>:ud    0x800:uw              {$6.src}
        or (1|M0)                r8.0<1>:ud    r2.0<0;1,0>:ud    0x820:uw              {$8.src}
        or (1|M0)                r9.0<1>:ud    r2.0<0;1,0>:ud    0x100:uw             
        or (1|M0)                r10.0<1>:ud   r2.0<0;1,0>:ud    0x120:uw              {$2.src}
        send.slm (1|M0)          null     r2      r71:1   0x0            0x0200B704           {$6} // wr:1+1, rd:0; store.slm.d64x4t.a32
        send.slm (1|M0)          null     r6      r63:1   0x0            0x0200B704           {A@5,$0} // wr:1+1, rd:0; store.slm.d64x4t.a32
        send.slm (1|M0)          null     r7      r55:1   0x0            0x0200B704           {A@4,$1} // wr:1+1, rd:0; store.slm.d64x4t.a32
        send.slm (1|M0)          null     r8      r47:1   0x0            0x0200B704           {A@3,$2} // wr:1+1, rd:0; store.slm.d64x4t.a32
        send.slm (1|M0)          null     r9      r72:1   0x0            0x0200B704           {A@2,$3} // wr:1+1, rd:0; store.slm.d64x4t.a32
        send.slm (1|M0)          null     r10     r64:1   0x0            0x0200B704           {A@1,$4} // wr:1+1, rd:0; store.slm.d64x4t.a32
        or (1|M0)                r11.0<1>:ud   r2.0<0;1,0>:ud    0x900:uw             
        or (1|M0)                r12.0<1>:ud   r2.0<0;1,0>:ud    0x920:uw             
        or (1|M0)                r6.0<1>:ud    r2.0<0;1,0>:ud    0x200:uw              {$0.src}
        or (1|M0)                r7.0<1>:ud    r2.0<0;1,0>:ud    0x220:uw              {$1.src}
        or (1|M0)                r8.0<1>:ud    r2.0<0;1,0>:ud    0xA00:uw              {$2.src}
        or (1|M0)                r9.0<1>:ud    r2.0<0;1,0>:ud    0xA20:uw              {$3.src}
        or (1|M0)                r10.0<1>:ud   r2.0<0;1,0>:ud    0x300:uw              {$4.src}
        send.slm (1|M0)          null     r11     r56:1   0x0            0x0200B704           {A@7,$5} // wr:1+1, rd:0; store.slm.d64x4t.a32
        send.slm (1|M0)          null     r12     r48:1   0x0            0x0200B704           {A@6,$8} // wr:1+1, rd:0; store.slm.d64x4t.a32
        send.slm (1|M0)          null     r6      r73:1   0x0            0x0200B704           {A@5,$9} // wr:1+1, rd:0; store.slm.d64x4t.a32
        send.slm (1|M0)          null     r7      r65:1   0x0            0x0200B704           {A@4,$10} // wr:1+1, rd:0; store.slm.d64x4t.a32
        send.slm (1|M0)          null     r8      r57:1   0x0            0x0200B704           {A@3,$11} // wr:1+1, rd:0; store.slm.d64x4t.a32
        send.slm (1|M0)          null     r9      r49:1   0x0            0x0200B704           {A@2,$12} // wr:1+1, rd:0; store.slm.d64x4t.a32
        send.slm (1|M0)          null     r10     r74:1   0x0            0x0200B704           {A@1,$13} // wr:1+1, rd:0; store.slm.d64x4t.a32
        or (1|M0)                r11.0<1>:ud   r2.0<0;1,0>:ud    0x320:uw              {$5.src}
        or (1|M0)                r12.0<1>:ud   r2.0<0;1,0>:ud    0xB00:uw              {$8.src}
        or (1|M0)                r6.0<1>:ud    r2.0<0;1,0>:ud    0xB20:uw              {$9.src}
        or (1|M0)                r7.0<1>:ud    r2.0<0;1,0>:ud    0x400:uw              {$10.src}
        or (1|M0)                r8.0<1>:ud    r2.0<0;1,0>:ud    0x420:uw              {$11.src}
        or (1|M0)                r9.0<1>:ud    r2.0<0;1,0>:ud    0xC00:uw              {$12.src}
        or (1|M0)                r10.0<1>:ud   r2.0<0;1,0>:ud    0xC20:uw              {$13.src}
        send.slm (1|M0)          null     r11     r66:1   0x0            0x0200B704           {A@7,$14} // wr:1+1, rd:0; store.slm.d64x4t.a32
        send.slm (1|M0)          null     r12     r58:1   0x0            0x0200B704           {A@6,$15} // wr:1+1, rd:0; store.slm.d64x4t.a32
        send.slm (1|M0)          null     r6      r50:1   0x0            0x0200B704           {A@5,$0} // wr:1+1, rd:0; store.slm.d64x4t.a32
        send.slm (1|M0)          null     r7      r75:1   0x0            0x0200B704           {A@4,$1} // wr:1+1, rd:0; store.slm.d64x4t.a32
        send.slm (1|M0)          null     r8      r67:1   0x0            0x0200B704           {A@3,$2} // wr:1+1, rd:0; store.slm.d64x4t.a32
        send.slm (1|M0)          null     r9      r59:1   0x0            0x0200B704           {A@2,$3} // wr:1+1, rd:0; store.slm.d64x4t.a32
        send.slm (1|M0)          null     r10     r51:1   0x0            0x0200B704           {A@1,$4} // wr:1+1, rd:0; store.slm.d64x4t.a32
        or (1|M0)                r11.0<1>:ud   r2.0<0;1,0>:ud    0x500:uw              {$14.src}
        or (1|M0)                r12.0<1>:ud   r2.0<0;1,0>:ud    0x520:uw              {$15.src}
        or (1|M0)                r6.0<1>:ud    r2.0<0;1,0>:ud    0xD00:uw              {$0.src}
        or (1|M0)                r7.0<1>:ud    r2.0<0;1,0>:ud    0xD20:uw              {$1.src}
        or (1|M0)                r8.0<1>:ud    r2.0<0;1,0>:ud    0x600:uw              {$2.src}
        or (1|M0)                r9.0<1>:ud    r2.0<0;1,0>:ud    0x620:uw              {$3.src}
        or (1|M0)                r10.0<1>:ud   r2.0<0;1,0>:ud    0xE00:uw              {$4.src}
        mul (1|M0)               acc0.0<1>:ud  r43.5<0;1,0>:ud   r1.4<0;1,0>:uw  
        send.slm (1|M0)          null     r11     r76:1   0x0            0x0200B704           {A@7,$5} // wr:1+1, rd:0; store.slm.d64x4t.a32
        send.slm (1|M0)          null     r12     r68:1   0x0            0x0200B704           {A@7,$8} // wr:1+1, rd:0; store.slm.d64x4t.a32
        send.slm (1|M0)          null     r6      r60:1   0x0            0x0200B704           {A@6,$9} // wr:1+1, rd:0; store.slm.d64x4t.a32
        send.slm (1|M0)          null     r7      r52:1   0x0            0x0200B704           {A@5,$10} // wr:1+1, rd:0; store.slm.d64x4t.a32
        send.slm (1|M0)          null     r8      r77:1   0x0            0x0200B704           {A@4,$11} // wr:1+1, rd:0; store.slm.d64x4t.a32
        send.slm (1|M0)          null     r9      r69:1   0x0            0x0200B704           {A@3,$12} // wr:1+1, rd:0; store.slm.d64x4t.a32
        send.slm (1|M0)          null     r10     r61:1   0x0            0x0200B704           {A@2,$13} // wr:1+1, rd:0; store.slm.d64x4t.a32
        mach (1|M0)              r10.0<1>:ud   r43.5<0;1,0>:ud   r1.2<0;1,0>:ud   {AccWrEn,$13.src}
        or (1|M0)                r11.0<1>:ud   r2.0<0;1,0>:ud    0xE20:uw              {$5.src}
        or (1|M0)                r12.0<1>:ud   r2.0<0;1,0>:ud    0x700:uw              {$8.src}
        or (1|M0)                r6.0<1>:ud    r2.0<0;1,0>:ud    0x720:uw              {$9.src}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$12.src}
        send.slm (1|M0)          null     r11     r53:1   0x0            0x0200B704           {A@4,$14} // wr:1+1, rd:0; store.slm.d64x4t.a32
        send.slm (1|M0)          null     r12     r78:1   0x0            0x0200B704           {A@3,$15} // wr:1+1, rd:0; store.slm.d64x4t.a32
        send.slm (1|M0)          null     r6      r70:1   0x0            0x0200B704           {A@2,$0} // wr:1+1, rd:0; store.slm.d64x4t.a32
        or (1|M0)                r7.0<1>:ud    r2.0<0;1,0>:ud    0xF00:uw              {$10.src}
        sync.nop                             null                             {Compacted,$0.src}
        shl (1|M0)               r6.0<1>:d     r9.0<0;1,0>:d     2:w               {Compacted,I@2}
(W)     mul (1|M0)               acc0.0<1>:d   r43.6<0;1,0>:d    r1.4<0;1,0>:uw  
        send.slm (1|M0)          null     r7      r62:1   0x0            0x0200B704           {A@3,$1} // wr:1+1, rd:0; store.slm.d64x4t.a32
        or (1|M0)                r8.0<1>:ud    r2.0<0;1,0>:ud    0xF20:uw              {$11.src}
        mov (1|M0)               r11.0<1>:d    r4.4<0;1,0>:d                    {$14.src}
        mach (1|M0)              r2.0<1>:d     r43.6<0;1,0>:d    r1.2<0;1,0>:d    {$6.src}
        sync.nop                             null                             {Compacted,$1.src}
        addc (1|M0)              r7.0<1>:ud    r3.6<0;1,0>:ud    r6.0<0;1,0>:ud   {AccWrEn,I@5}
        send.slm (1|M0)          null     r8      r54:1   0x0            0x0200B704           {A@4,$2} // wr:1+1, rd:0; store.slm.d64x4t.a32
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$2.src}
        mul (1|M0)               acc0.0<1>:ud  r43.5<0;1,0>:ud   r11.0<0;1,0>:uw  {I@4}
        mach (1|M0)              r13.0<1>:ud   r43.5<0;1,0>:ud   r11.0<0;1,0>:ud  {AccWrEn}
        shl (1|M0)               r43.3<1>:d    r43.3<0;1,0>:d    4:w               {Compacted}
        mov (1|M0)               r12.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,$15.src}
(W)     mul (1|M0)               acc0.0<1>:d   r43.6<0;1,0>:d    r11.0<0;1,0>:uw  {Compacted}
        add3 (1|M0)              r5.7<1>:d     r2.0<0;0>:d       r10.0<0;0>:d      0:w               {I@7}
        mach (1|M0)              r2.0<1>:d     r43.6<0;1,0>:d    r11.0<0;1,0>:d   {Compacted}
        shr (1|M0)               r4.1<1>:ud    r9.0<0;1,0>:ud    0x1E:uw             
        or (1|M0)                r6.3<1>:d     r43.2<0;1,0>:d    r43.3<0;1,0>:d   {I@6}
        shl (1|M0)               r5.6<1>:d     r12.0<0;1,0>:d    2:w               {Compacted,I@6}
        shl (1|M0)               r3.5<1>:d     r5.7<0;1,0>:d     2:w               {I@5}
        add3 (1|M0)              r1.3<1>:d     r2.0<0;0>:d       r13.0<0;0>:d      0:w               {I@5}
        shl (1|M0)               r6.6<1>:d     r6.3<0;1,0>:d     2:w               {I@4}
        addc (1|M0)              r6.0<1>:ud    r4.2<0;1,0>:ud    r5.6<0;1,0>:ud   {AccWrEn,I@4}
        or (1|M0)                r6.1<1>:d     r3.5<0;1,0>:d     r4.1<0;1,0>:d    {I@4}
        shl (1|M0)               r3.5<1>:d     r1.3<0;1,0>:d     2:w               {I@4}
        shr (1|M0)               r4.1<1>:ud    r12.0<0;1,0>:ud   0x1E:uw             
        mov (1|M0)               r46.6<1>:d    r7.0<0;1,0>:d                   
        shr (1|M0)               r6.5<1>:ud    r6.3<0;1,0>:ud    0x1E:uw             
        or (1|M0)                r5.7<1>:d     r3.5<0;1,0>:d     r4.1<0;1,0>:d    {I@3}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r2.0<1>:ud    r6.0<0;1,0>:ud    r6.6<0;1,0>:ud   {AccWrEn}
        add3 (1|M0)              r46.7<1>:d    r8.0<0;0>:d       r3.7<0;0>:d       r6.1<0>:d       
        or (1|M0)                r6.7<1>:d     r6.5<0;1,0>:d     0:w               {I@5}
        add3 (1|M0)              r6.2<1>:d     r7.0<0;0>:d       r4.3<0;0>:d       r5.7<0>:d        {I@4}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r9.0<1>:f     r2.0<0;1,0>:f                    {Compacted,I@5}
        add3 (1|M0)              r9.1<1>:d     r8.0<0;0>:d       r6.2<0;0>:d       r6.7<0>:d        {I@1}
        mul (1|M0)               acc0.0<1>:ud  r43.5<0;1,0>:ud   r5.0<0;1,0>:uw  
        send.ugm (1|M0)          r79      r9      null:0  0x0            0x0220C780           {A@1,$3} // wr:1+0, rd:2; load.ugm.d64x8t.a64
        mov (4|M0)               r9.0<1>:w     0x64206420:v                               {$3.src}
        mach (1|M0)              r11.0<1>:ud   r43.5<0;1,0>:ud   r5.0<0;1,0>:ud   {AccWrEn}
        mov (4|M0)               r13.0<4>:uw   r9.0<1;1,0>:uw                   {I@2}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r43.5<0;1,0>:d    r5.2<0;1,0>:uw  
        mov (4|M0)               r81.0<2>:d    r13.0<4;1,0>:w                   {I@3}
        mach (1|M0)              r7.0<1>:d     r43.5<0;1,0>:d    r5.1<0;1,0>:d   
(W)     mul (1|M0)               acc0.0<1>:d   r43.6<0;1,0>:d    r5.0<0;1,0>:uw   {Compacted}
        asr (4|M0)               r81.1<2>:d    r81.0<2;1,0>:d    31:w               {I@3}
        mach (1|M0)              r12.0<1>:d    r43.6<0;1,0>:d    r5.0<0;1,0>:d    {Compacted}
        addc (1|M0)              r2.0<1>:ud    r10.0<0;1,0>:ud   r6.3<0;1,0>:ud   {AccWrEn}
        add3 (1|M0)              r1.3<1>:d     r12.0<0;0>:d      r11.0<0;0>:d      r7.0<0>:d        {I@2}
        mov (4|M0)               r7.0<2>:ud    r81.0<2;1,0>:ud                 
        mov (4|M0)               r7.1<2>:ud    r81.1<2;1,0>:ud                 
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (4|M0)              r6.0<1>:ud    r7.0<2;1,0>:ud    0x8:ud              {AccWrEn,I@2}
        add3 (1|M0)              r85.3<1>:d    r8.0<0;0>:d       r1.3<0;0>:d       0:w               {I@2}
        mov (4|M0)               r10.0<1>:ud   acc0.0<1;1,0>:ud                
        addc (4|M0)              r8.0<1>:ud    r7.0<2;1,0>:ud    0x10:ud              {AccWrEn}
        shl (1|M0)               r90.6<1>:d    r90.6<0;1,0>:d    7:w              
        mov (4|M0)               r11.0<1>:ud   acc0.0<1;1,0>:ud                
        addc (4|M0)              r9.0<1>:ud    r7.0<2;1,0>:ud    0x18:ud              {AccWrEn}
        shl (1|M0)               r46.3<1>:ud   r46.3<0;1,0>:ud   0x4:uw             
        mov (4|M0)               r12.0<1>:ud   acc0.0<1;1,0>:ud                
        mov (1|M0)               r85.0<1>:d    r5.2<0;1,0>:d                   
        mov (1|M0)               r85.1<1>:d    0:w                              
        and (1|M0)               r46.4<1>:d    r4.6<0;1,0>:d     -2:w              
        and (1|M0)               r46.5<1>:d    r4.6<0;1,0>:d     -3:w              
        mov (1|M0)               r85.4<1>:d    0:w                              
        mov (1|M0)               r85.2<1>:d    r2.0<0;1,0>:d                   
        mov (4|M0)               r82.0<2>:d    r6.0<1;1,0>:d                   
        mov (4|M0)               r83.0<2>:d    r8.0<1;1,0>:d                   
        mov (4|M0)               r84.0<2>:d    r9.0<1;1,0>:d                    {I@7}
        add (1|M0)               r90.6<1>:d    r90.6<0;1,0>:d    r46.3<0;1,0>:d   {I@7}
        add3 (4|M0)              r82.1<2>:d    r10.0<1;0>:d      r7.1<4;2>:d       0:w              
        add3 (4|M0)              r83.1<2>:d    r11.0<1;0>:d      r7.1<4;2>:d       0:w              
        add3 (4|M0)              r84.1<2>:d    r12.0<1;0>:d      r7.1<4;2>:d       0:w              
L5424:
        or (1|M0)                r85.7<1>:d    r85.4<0;1,0>:d    r90.6<0;1,0>:d   {I@4}
        cmp (1|M0)    (eq)f1.1   null<1>:d     r4.6<0;1,0>:d     4:w              
        cmp (1|M0)    (lt)f0.0   null<1>:d     r85.7<0;1,0>:d    r4.5<0;1,0>:d    {I@2}
        cmp (1|M0)    (eq)f0.1   null<1>:d     r46.5<0;1,0>:d    1:w              
        cmp (1|M0)    (eq)f1.0   null<1>:d     r46.4<0;1,0>:d    2:w              
(W)     mov (1|M0)               r90.14<1>:uw  f1.1<0;1,0>:uw                   {Compacted}
        cmp (1|M0)    (eq)f1.1   null<1>:w     r43.0<0;1,0>:b    0:w              
(W)     and (1|M0)               f0.0<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
(W)     mov (1|M0)               r43.1<1>:uw   f1.1<0;1,0>:uw                   {Compacted}
(~f0.0.any16h) goto (16|M0)                  L7432                  L7432                
L5568:
        mov (1|M0)               r85.5<1>:d    r85.7<0;1,0>:d                  
        asr (1|M0)               r85.6<1>:d    r85.7<0;1,0>:d    31:w              
        shl (1|M0)               r1.4<1>:d     r85.5<0;1,0>:d    2:w               {I@2}
        shr (1|M0)               r1.3<1>:ud    r85.5<0;1,0>:ud   0x1E:uw             
        shl (1|M0)               r1.2<1>:d     r85.6<0;1,0>:d    2:w               {I@3}
        addc (1|M0)              r2.0<1>:ud    r46.6<0;1,0>:ud   r1.4<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r8.0<1>:f     r2.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r8.1<1>:d     r6.0<0;0>:d       r46.7<0;0>:d      r1.5<0>:d        {I@1}
        or (1|M0)                r3.5<1>:d     r85.4<0;1,0>:d    r46.3<0;1,0>:d  
        send.ugm (1|M0)          r7       r8      null:0  0x0            0x04100580           {A@1,$9} // wr:2+0, rd:1; load.ugm.d32.a64
        shl (1|M0)               r3.5<1>:d     r3.5<0;1,0>:d     8:w               {I@1}
(W)     and (1|M0)               f1.1<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
        sync.nop                             null                             {Compacted,$9.src}
        or (1|M0)                r9.0<1>:d     r3.5<0;1,0>:d     r46.2<0;1,0>:d   {I@2}
        sync.allrd                           ($5,$8)                
        send.slm (1|M0)          r10      r9      null:0  0x0            0x0220C700           {A@1,$10} // wr:1+0, rd:2; load.slm.d64x8t.a32
        mov (16|M0)              r86.0<1>:f    r10.0<1;1,0>:d                   {Compacted,$10.dst}
        sync.nop                             null                             {Compacted,$9.dst}
        mul (16|M0)              r86.0<1>:f    r7.0<0;1,0>:f     r86.0<1;1,0>:f   {Compacted,F@1}
        sync.nop                             null                             {Compacted,$3.dst}
        mul (16|M0)              r86.0<1>:f    r86.0<1;1,0>:f    r79.0<1;1,0>:f   {Compacted,F@1}
(~f1.1.any16h) goto (16|M0)                  L6200                  L6200                
L5888:
        mov (8|M0)               r6.0<1>:hf    r86.0<1;1,0>:f                   {F@1}
        mov (8|M0)               r6.8<1>:hf    r87.0<1;1,0>:f                  
        mov (8|M0)               r7.0<1>:f     r6.0<1;1,0>:hf                   {F@2}
        mov (8|M0)               r8.0<1>:f     r6.8<1;1,0>:hf                   {F@2}
        mov (1|M0)               r1.2<1>:ud    0xBD650000:ud                             
        sel (16|M0)   (ge)f0.0   acc0.0<1>:f   r7.0<1;1,0>:f     -4.0:f               {Compacted,F@1}
        mov (1|M0)               r1.3<1>:ud    0x3EE50000:ud                             
        sel (16|M0)   (lt)f0.0   acc0.0<1>:f   acc0.0<1;1,0>:f   4.0:f               {Compacted}
        mad (16|M0)              r11.0<1>:f    r1.3<0;0>:f       (abs)acc0.0<1;0>:f  r1.2<0>:f      {I@1}
        mov (8|M0)               r13.0<1>:hf   r11.0<1;1,0>:f                   {F@1}
        mov (8|M0)               r13.8<1>:hf   r12.0<1;1,0>:f                  
        mov (1|M0)               r2.0<1>:ud    0x3F650000:ud                             
        sync.allrd                           ($4,$6)                
        mov (8|M0)               r14.0<1>:f    r13.0<1;1,0>:hf                  {F@2}
        mov (8|M0)               r15.0<1>:f    r13.8<1;1,0>:hf                  {F@2}
        mad (16|M0)              r9.0<1>:f     r2.0<0;0>:f       acc0.0<1;0>:f     r14.0<1>:f       {Compacted,A@1}
        mov (8|M0)               r16.0<1>:hf   r9.0<1;1,0>:f                    {F@1}
        mov (8|M0)               r16.8<1>:hf   r10.0<1;1,0>:f                  
        mul (16|M0)              r6.0<1>:hf    r6.0<1;1,0>:hf    r16.0<1;1,0>:hf  {F@1}
        mov (8|M0)               r86.0<1>:f    r6.0<1;1,0>:hf                   {F@1}
        mov (8|M0)               r87.0<1>:f    r6.8<1;1,0>:hf                  
L6200:
        join (16|M0)                         L7432                                
L6216:
(W)     and (1|M0)               f0.0<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(~f0.0.any16h) goto (16|M0)                  L6440                  L6440                
L6248:
        sel (16|M0)   (lt)f0.0   r6.0<1>:f     (abs)r86.0<1;1,0>:f  448.0:f            {Compacted,F@1}
        shr (16|M0)              r8.0<1>:ud    r6.0<1;1,0>:ud    0x17:uw              {F@1}
        sel (16|M0)   (ge)f0.0   r10.0<2>:ub   r8.0<4;1,0>:ub    0x79:uw              {I@1}
        mov (16|M0)              r11.0<1>:d    r10.0<2;1,0>:ub                  {I@1}
        shl (16|M0)              r11.0<1>:d    r11.0<1;1,0>:d    23:w               {Compacted,I@1}
        sync.allrd                           ($4,$6)                
        add (16|M0)              r13.0<1>:d    r11.0<1;1,0>:d    -25165824:d               {I@1}
        add (16|M0)              r11.0<1>:d    -r11.0<1;1,0>:d   -2139095040:d              
        mul (16|M0)              acc0.0<1>:f   r6.0<1;1,0>:f     r11.0<1;1,0>:f   {Compacted,I@1}
        rnde (16|M0)             acc0.0<1>:f   acc0.0<1;1,0>:f                 
        cmp (16|M0)   (lt)f0.0   null<1>:f     r86.0<1;1,0>:f    0.0:f               {Compacted}
        mul (16|M0)              r88.0<1>:f    acc0.0<1;1,0>:f   r13.0<1;1,0>:f   {Compacted}
        mov (16|M0)              r88.0<1>:f    (abs)r88.0<1;1,0>:f              {Compacted,F@1}
(f0.0)  or (16|M0)               r88.0<1>:d    r88.0<1;1,0>:d    -2147483648:d               {F@1}
        goto (16|M0)                         L6440                  L6552                
L6440:
        join (16|M0)                         L6552                                
L6456:
(W)     and (1|M0)               f1.1<1>:uw    r90.14<0;1,0>:uw  0x1:uw             
(f1.1.any16h) mov (8|M0)         r6.0<1>:hf    r86.0<1;1,0>:f                  
(f1.1.any16h) mov (8|M0)         r6.8<1>:hf    r87.0<1;1,0>:f                  
(~f1.1.any16h) mov (16|M0)       r88.0<1>:ud   r86.0<1;1,0>:ud                 
(f1.1.any16h) mov (8|M0)         r88.0<1>:f    r6.0<1;1,0>:hf                   {A@1}
(f1.1.any16h) mov (8|M0)         r89.0<1>:f    r6.8<1;1,0>:hf                   {F@2}
L6552:
        join (16|M0)                         L7432                                
L6568:
        mul (1|M0)               acc0.0<1>:ud  r85.5<0;1,0>:ud   r85.0<0;1,0>:uw 
        mach (1|M0)              r7.0<1>:ud    r85.5<0;1,0>:ud   r85.0<0;1,0>:ud  {AccWrEn}
(W)     and (1|M0)               f0.0<1>:uw    r43.1<0;1,0>:uw   0x1:uw             
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,F@2}
(W)     mul (1|M0)               acc0.0<1>:d   r85.5<0;1,0>:d    r85.2<0;1,0>:uw 
        mach (1|M0)              r2.0<1>:d     r85.5<0;1,0>:d    r85.1<0;1,0>:d  
(W)     mul (1|M0)               acc0.0<1>:d   r85.6<0;1,0>:d    r85.0<0;1,0>:uw  {Compacted}
        mach (1|M0)              r8.0<1>:d     r85.6<0;1,0>:d    r85.0<0;1,0>:d   {Compacted}
        mov (1|M0)               r90.0<1>:f    r6.0<0;1,0>:f                    {Compacted,I@5}
        add3 (1|M0)              r90.1<1>:d    r8.0<0;0>:d       r7.0<0;0>:d       r2.0<0>:d        {I@1}
(f0.0.any16h) goto (16|M0)                   L7200                  L7200                
L6712:
        shl (1|M0)               r1.4<1>:d     r85.2<0;1,0>:d    1:w              
        shl (1|M0)               r1.2<1>:d     r85.3<0;1,0>:d    1:w              
        shr (1|M0)               r1.3<1>:ud    r85.2<0;1,0>:ud   0x1F:uw             
        shl (1|M0)               r8.0<1>:d     r90.0<0;1,0>:d    1:w               {Compacted,F@1}
        addc (1|M0)              r2.0<1>:ud    r5.4<0;1,0>:ud    r1.4<0;1,0>:ud   {AccWrEn,I@4}
        shl (1|M0)               r2.1<1>:d     r90.1<0;1,0>:d    1:w               {Compacted}
        shr (1|M0)               r3.5<1>:ud    r90.0<0;1,0>:ud   0x1F:uw             
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@5}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r9.0<1>:ud    r2.0<0;1,0>:ud    r8.0<0;1,0>:ud   {AccWrEn,I@5}
        or (1|M0)                r8.1<1>:d     r2.1<0;1,0>:d     r3.5<0;1,0>:d    {I@4}
        add3 (1|M0)              r5.7<1>:d     r7.0<0;0>:d       r5.5<0;0>:d       r1.5<0>:d        {I@3}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r8.2<1>:d     r9.0<0;1,0>:d                    {I@4}
        add3 (1|M0)              r8.3<1>:d     r10.0<0;0>:d      r5.7<0;0>:d       r8.1<0>:d        {I@2}
        mov (8|M0)               r11.0<2>:ud   r8.2<0;1,0>:ud                   {I@2}
        mov (8|M0)               r11.1<2>:ud   r8.3<0;1,0>:ud                   {I@2}
        mov (8|M0)               r18.0<1>:d    r81.1<2;1,0>:d                  
        addc (8|M0)              r13.0<1>:ud   r11.0<2;1,0>:ud   r81.0<2;1,0>:ud  {AccWrEn,Compacted,I@2}
        mov (8|M0)               r10.0<1>:d    r83.1<2;1,0>:d                  
        mov (8|M0)               r7.0<1>:ud    acc0.0<1;1,0>:ud                 {Compacted}
        addc (8|M0)              r20.0<1>:ud   r11.0<2;1,0>:ud   r83.0<2;1,0>:ud  {AccWrEn,Compacted}
        mov (8|M0)               r6.0<1>:hf    r88.0<1;1,0>:f                  
        mov (8|M0)               r9.0<1>:ud    acc0.0<1;1,0>:ud                 {Compacted}
        mov (8|M0)               r6.8<1>:hf    r89.0<1;1,0>:f                  
        add3 (8|M0)              r19.0<1>:d    r7.0<1;0>:d       r11.1<4;2>:d      r18.0<1>:d       {I@3}
        add3 (8|M0)              r8.0<1>:d     r9.0<1;0>:d       r11.1<4;2>:d      r10.0<1>:d       {I@2}
        sync.nop                             null                             {Compacted,$6.src}
        mov (8|M0)               r14.0<2>:d    r13.0<1;1,0>:d                   {$4.src}
        mov (8|M0)               r16.0<2>:d    r20.0<1;1,0>:d                  
        mov (16|M0)              r21.0<1>:d    r6.0<1;1,0>:uw                   {A@1}
        mov (8|M0)               r14.1<2>:d    r19.0<1;1,0>:d                   {I@5}
        mov (8|M0)               r16.1<2>:d    r8.0<1;1,0>:d                    {I@5}
        send.ugm (16|M0)         null     r14     r21:2   0x0            0x08000B84           {A@1,$4} // wr:4+2, rd:0; store.ugm.d16u32.a64
        goto (16|M0)                         L7200                  L7432                
L7200:
        join (16|M0)                         L7432                                
L7216:
        shl (1|M0)               r1.4<1>:d     r85.2<0;1,0>:d    2:w              
        shl (1|M0)               r1.2<1>:d     r85.3<0;1,0>:d    2:w              
        shr (1|M0)               r1.3<1>:ud    r85.2<0;1,0>:ud   0x1E:uw             
        shl (1|M0)               r7.0<1>:d     r90.0<0;1,0>:d    2:w               {Compacted}
        addc (1|M0)              r2.0<1>:ud    r5.4<0;1,0>:ud    r1.4<0;1,0>:ud   {AccWrEn,I@4}
        shl (1|M0)               r2.1<1>:d     r90.1<0;1,0>:d    2:w               {Compacted}
        shr (1|M0)               r3.5<1>:ud    r90.0<0;1,0>:ud   0x1E:uw             
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@5}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r8.0<1>:ud    r2.0<0;1,0>:ud    r7.0<0;1,0>:ud   {AccWrEn,I@5}
        or (1|M0)                r7.1<1>:d     r2.1<0;1,0>:d     r3.5<0;1,0>:d    {I@4}
        add3 (1|M0)              r5.7<1>:d     r6.0<0;0>:d       r5.5<0;0>:d       r1.5<0>:d        {I@3}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r10.0<1>:f    r8.0<0;1,0>:f                    {Compacted,I@4}
        add3 (1|M0)              r10.1<1>:d    r9.0<0;0>:d       r5.7<0;0>:d       r7.1<0>:d        {I@1}
        send.ugm (1|M0)          null     r10     r88:2   0x0            0x0200D584           {A@1,$5} // wr:1+2, rd:0; store.ugm.d32x16t.a64
L7432:
        join (16|M0)                         L9488                                
L7448:
        or (1|M0)                r85.7<1>:d    r85.7<0;1,0>:d    8:w              
        cmp (1|M0)    (lt)f1.1   null<1>:d     r85.7<0;1,0>:d    r4.5<0;1,0>:d    {I@1}
(W)     and (1|M0)               f1.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(~f1.1.any16h) goto (16|M0)                  L9408                  L9408                
L7512:
        mov (1|M0)               r90.2<1>:d    r85.7<0;1,0>:d                  
        asr (1|M0)               r90.3<1>:d    r85.7<0;1,0>:d    31:w              
        shl (1|M0)               r1.4<1>:d     r90.2<0;1,0>:d    2:w               {I@2}
        shr (1|M0)               r1.3<1>:ud    r90.2<0;1,0>:ud   0x1E:uw             
        shl (1|M0)               r1.2<1>:d     r90.3<0;1,0>:d    2:w               {I@3}
        addc (1|M0)              r2.0<1>:ud    r46.6<0;1,0>:ud   r1.4<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r8.0<1>:f     r2.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r8.1<1>:d     r6.0<0;0>:d       r46.7<0;0>:d      r1.5<0>:d        {I@1}
        or (1|M0)                r3.5<1>:d     r85.4<0;1,0>:d    r46.3<0;1,0>:d  
        send.ugm (1|M0)          r7       r8      null:0  0x0            0x04100580           {A@1,$11} // wr:2+0, rd:1; load.ugm.d32.a64
        shl (1|M0)               r3.5<1>:d     r3.5<0;1,0>:d     8:w               {I@1}
(W)     and (1|M0)               f0.0<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
        sync.nop                             null                             {Compacted,$11.src}
        bfn.0xFE (1|M0)          r9.0<1>:ud    0x800:uw               r3.5<0;0>:ud      r46.2<0>:ud      {I@2} // s0|s1|s2
        sync.allrd                           ($5,$8)                
        send.slm (1|M0)          r10      r9      null:0  0x0            0x0220C700           {A@1,$12} // wr:1+0, rd:2; load.slm.d64x8t.a32
        mov (16|M0)              r95.0<1>:f    r10.0<1;1,0>:d                   {Compacted,$12.dst}
        sync.nop                             null                             {Compacted,$11.dst}
        mul (16|M0)              r95.0<1>:f    r7.0<0;1,0>:f     r95.0<1;1,0>:f   {Compacted,F@1}
        sync.nop                             null                             {Compacted,$3.dst}
        mul (16|M0)              r95.0<1>:f    r95.0<1;1,0>:f    r79.0<1;1,0>:f   {Compacted,F@1}
(~f0.0.any16h) goto (16|M0)                  L8144                  L8144                
L7832:
        mov (8|M0)               r6.0<1>:hf    r95.0<1;1,0>:f                   {F@1}
        mov (8|M0)               r6.8<1>:hf    r96.0<1;1,0>:f                  
        mov (8|M0)               r7.0<1>:f     r6.0<1;1,0>:hf                   {F@2}
        mov (8|M0)               r8.0<1>:f     r6.8<1;1,0>:hf                   {F@2}
        mov (1|M0)               r1.2<1>:ud    0xBD650000:ud                             
        sel (16|M0)   (ge)f0.0   acc0.0<1>:f   r7.0<1;1,0>:f     -4.0:f               {Compacted,F@1}
        mov (1|M0)               r1.3<1>:ud    0x3EE50000:ud                             
        sel (16|M0)   (lt)f0.0   acc0.0<1>:f   acc0.0<1;1,0>:f   4.0:f               {Compacted}
        mad (16|M0)              r11.0<1>:f    r1.3<0;0>:f       (abs)acc0.0<1;0>:f  r1.2<0>:f      {I@1}
        mov (8|M0)               r13.0<1>:hf   r11.0<1;1,0>:f                   {F@1}
        mov (8|M0)               r13.8<1>:hf   r12.0<1;1,0>:f                  
        mov (1|M0)               r2.0<1>:ud    0x3F650000:ud                             
        sync.allrd                           ($4,$6)                
        mov (8|M0)               r14.0<1>:f    r13.0<1;1,0>:hf                  {F@2}
        mov (8|M0)               r15.0<1>:f    r13.8<1;1,0>:hf                  {F@2}
        mad (16|M0)              r9.0<1>:f     r2.0<0;0>:f       acc0.0<1;0>:f     r14.0<1>:f       {Compacted,A@1}
        mov (8|M0)               r16.0<1>:hf   r9.0<1;1,0>:f                    {F@1}
        mov (8|M0)               r16.8<1>:hf   r10.0<1;1,0>:f                  
        mul (16|M0)              r6.0<1>:hf    r6.0<1;1,0>:hf    r16.0<1;1,0>:hf  {F@1}
        mov (8|M0)               r95.0<1>:f    r6.0<1;1,0>:hf                   {F@1}
        mov (8|M0)               r96.0<1>:f    r6.8<1;1,0>:hf                  
L8144:
        join (16|M0)                         L9408                                
L8160:
(W)     and (1|M0)               f1.1<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(~f1.1.any16h) goto (16|M0)                  L8392                  L8392                
L8192:
        sel (16|M0)   (lt)f0.0   r6.0<1>:f     (abs)r95.0<1;1,0>:f  448.0:f            {Compacted,F@1}
        shr (16|M0)              r8.0<1>:ud    r6.0<1;1,0>:ud    0x17:uw              {F@1}
        sel (16|M0)   (ge)f0.0   r10.0<2>:ub   r8.0<4;1,0>:ub    0x79:uw              {I@1}
        mov (16|M0)              r11.0<1>:d    r10.0<2;1,0>:ub                  {I@1}
        shl (16|M0)              r11.0<1>:d    r11.0<1;1,0>:d    23:w               {Compacted,I@1}
        sync.allrd                           ($4,$6)                
        add (16|M0)              r13.0<1>:d    r11.0<1;1,0>:d    -25165824:d               {I@1}
        add (16|M0)              r11.0<1>:d    -r11.0<1;1,0>:d   -2139095040:d              
        mul (16|M0)              acc0.0<1>:f   r6.0<1;1,0>:f     r11.0<1;1,0>:f   {Compacted,I@1}
        rnde (16|M0)             acc0.0<1>:f   acc0.0<1;1,0>:f                 
        cmp (16|M0)   (lt)f0.1   null<1>:f     r95.0<1;1,0>:f    0.0:f              
        mul (16|M0)              r97.0<1>:f    acc0.0<1;1,0>:f   r13.0<1;1,0>:f   {Compacted}
        mov (16|M0)              r97.0<1>:f    (abs)r97.0<1;1,0>:f              {Compacted,F@1}
(f0.1)  or (16|M0)               r97.0<1>:d    r97.0<1;1,0>:d    -2147483648:d               {F@1}
        goto (16|M0)                         L8392                  L8504                
L8392:
        join (16|M0)                         L8504                                
L8408:
(W)     and (1|M0)               f1.0<1>:uw    r90.14<0;1,0>:uw  0x1:uw             
(f1.0.any16h) mov (8|M0)         r6.0<1>:hf    r95.0<1;1,0>:f                  
(f1.0.any16h) mov (8|M0)         r6.8<1>:hf    r96.0<1;1,0>:f                  
(~f1.0.any16h) mov (16|M0)       r97.0<1>:ud   r95.0<1;1,0>:ud                 
(f1.0.any16h) mov (8|M0)         r97.0<1>:f    r6.0<1;1,0>:hf                   {A@1}
(f1.0.any16h) mov (8|M0)         r98.0<1>:f    r6.8<1;1,0>:hf                   {F@2}
L8504:
        join (16|M0)                         L9408                                
L8520:
        mul (1|M0)               acc0.0<1>:ud  r90.2<0;1,0>:ud   r85.0<0;1,0>:uw 
        mach (1|M0)              r7.0<1>:ud    r90.2<0;1,0>:ud   r85.0<0;1,0>:ud  {AccWrEn}
(W)     and (1|M0)               f0.1<1>:uw    r43.1<0;1,0>:uw   0x1:uw             
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,F@2}
(W)     mul (1|M0)               acc0.0<1>:d   r90.2<0;1,0>:d    r85.2<0;1,0>:uw 
        mach (1|M0)              r2.0<1>:d     r90.2<0;1,0>:d    r85.1<0;1,0>:d  
(W)     mul (1|M0)               acc0.0<1>:d   r90.3<0;1,0>:d    r85.0<0;1,0>:uw  {Compacted}
        mach (1|M0)              r8.0<1>:d     r90.3<0;1,0>:d    r85.0<0;1,0>:d   {Compacted}
        mov (1|M0)               r90.4<1>:d    r6.0<0;1,0>:d                    {I@5}
        add3 (1|M0)              r90.5<1>:d    r8.0<0;0>:d       r7.0<0;0>:d       r2.0<0>:d        {I@2}
(f0.1.any16h) goto (16|M0)                   L9168                  L9168                
L8672:
        shl (1|M0)               r1.4<1>:d     r85.2<0;1,0>:d    1:w              
        shl (1|M0)               r1.2<1>:d     r85.3<0;1,0>:d    1:w              
        shr (1|M0)               r1.3<1>:ud    r85.2<0;1,0>:ud   0x1F:uw             
        shl (1|M0)               r8.0<1>:d     r90.4<0;1,0>:d    1:w               {Compacted,I@6}
        addc (1|M0)              r2.0<1>:ud    r5.4<0;1,0>:ud    r1.4<0;1,0>:ud   {AccWrEn,I@4}
        shl (1|M0)               r2.1<1>:d     r90.5<0;1,0>:d    1:w              
        shr (1|M0)               r3.5<1>:ud    r90.4<0;1,0>:ud   0x1F:uw             
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@5}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r9.0<1>:ud    r2.0<0;1,0>:ud    r8.0<0;1,0>:ud   {AccWrEn,I@5}
        or (1|M0)                r8.1<1>:d     r2.1<0;1,0>:d     r3.5<0;1,0>:d    {I@4}
        add3 (1|M0)              r5.7<1>:d     r7.0<0;0>:d       r5.5<0;0>:d       r1.5<0>:d        {I@3}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r8.2<1>:d     r9.0<0;1,0>:d                    {I@4}
        add3 (1|M0)              r8.3<1>:d     r10.0<0;0>:d      r5.7<0;0>:d       r8.1<0>:d        {I@2}
        mov (8|M0)               r11.0<2>:ud   r8.2<0;1,0>:ud                   {I@2}
        mov (8|M0)               r11.1<2>:ud   r8.3<0;1,0>:ud                   {I@2}
        mov (8|M0)               r18.0<1>:d    r81.1<2;1,0>:d                  
        addc (8|M0)              r13.0<1>:ud   r11.0<2;1,0>:ud   r81.0<2;1,0>:ud  {AccWrEn,Compacted,I@2}
        mov (8|M0)               r10.0<1>:d    r83.1<2;1,0>:d                  
        mov (8|M0)               r7.0<1>:ud    acc0.0<1;1,0>:ud                 {Compacted}
        addc (8|M0)              r20.0<1>:ud   r11.0<2;1,0>:ud   r83.0<2;1,0>:ud  {AccWrEn,Compacted}
        mov (8|M0)               r6.0<1>:hf    r97.0<1;1,0>:f                  
        mov (8|M0)               r9.0<1>:ud    acc0.0<1;1,0>:ud                 {Compacted}
        mov (8|M0)               r6.8<1>:hf    r98.0<1;1,0>:f                   {F@2}
        add3 (8|M0)              r19.0<1>:d    r7.0<1;0>:d       r11.1<4;2>:d      r18.0<1>:d       {I@3}
        add3 (8|M0)              r8.0<1>:d     r9.0<1;0>:d       r11.1<4;2>:d      r10.0<1>:d       {I@2}
        sync.nop                             null                             {Compacted,$6.src}
        mov (8|M0)               r14.0<2>:d    r13.0<1;1,0>:d                   {$4.src}
        mov (8|M0)               r16.0<2>:d    r20.0<1;1,0>:d                  
        mov (16|M0)              r21.0<1>:d    r6.0<1;1,0>:uw                   {A@1}
        mov (8|M0)               r14.1<2>:d    r19.0<1;1,0>:d                   {I@5}
        mov (8|M0)               r16.1<2>:d    r8.0<1;1,0>:d                    {I@5}
        send.ugm (16|M0)         null     r14     r21:2   0x0            0x08000B84           {A@1,$6} // wr:4+2, rd:0; store.ugm.d16u32.a64
        goto (16|M0)                         L9168                  L9408                
L9168:
        join (16|M0)                         L9408                                
L9184:
        shl (1|M0)               r1.4<1>:d     r85.2<0;1,0>:d    2:w              
        shl (1|M0)               r1.2<1>:d     r85.3<0;1,0>:d    2:w              
        shr (1|M0)               r1.3<1>:ud    r85.2<0;1,0>:ud   0x1E:uw             
        shl (1|M0)               r7.0<1>:d     r90.4<0;1,0>:d    2:w               {Compacted}
        addc (1|M0)              r2.0<1>:ud    r5.4<0;1,0>:ud    r1.4<0;1,0>:ud   {AccWrEn,I@4}
        shl (1|M0)               r2.1<1>:d     r90.5<0;1,0>:d    2:w              
        shr (1|M0)               r3.5<1>:ud    r90.4<0;1,0>:ud   0x1E:uw             
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@5}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r8.0<1>:ud    r2.0<0;1,0>:ud    r7.0<0;1,0>:ud   {AccWrEn,I@5}
        or (1|M0)                r7.1<1>:d     r2.1<0;1,0>:d     r3.5<0;1,0>:d    {I@4}
        add3 (1|M0)              r5.7<1>:d     r6.0<0;0>:d       r5.5<0;0>:d       r1.5<0>:d        {I@3}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r10.0<1>:f    r8.0<0;1,0>:f                    {Compacted,I@4}
        add3 (1|M0)              r10.1<1>:d    r9.0<0;0>:d       r5.7<0;0>:d       r7.1<0>:d        {I@1}
        send.ugm (1|M0)          null     r10     r97:2   0x0            0x0200D584           {A@1,$8} // wr:1+2, rd:0; store.ugm.d32x16t.a64
L9408:
        join (16|M0)                         L9488                                
L9424:
        add (1|M0)               r85.4<1>:d    r85.4<0;1,0>:d    1:w              
        cmp (1|M0)    (eq)f0.0   null<1>:d     r85.4<0;1,0>:d    8:w               {I@1}
(W)     and (1|M0)               f0.0<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
(~f0.0.any16h) goto.b (16|M0)                L9488                  L5424                
L9488:
        join (16|M0)                         L9504                                
L9504:
(W)     mov (8|M0)               r127.0<1>:f   r0.0<1;1,0>:f                    {Compacted}
(W)     send.ugm (1|M0)          r6       r0      null:0  0x0            0x0210641F           {$13} // wr:1+0, rd:1; fence invalid flush type scoped to tile
(W)     mov (8|M0)               null<1>:ud    r6.0<1;1,0>:ud                   {$13.dst}
(W)     send.gtwy (1|M0)         null     r127    null:0  0x0            0x02000010           {EOT,A@1} // wr:1+0, rd:0; end of thread
L9560:
        mov (1|M0)               r1.2<1>:d     cr0.0<0;1,0>:ud                  {A@1}
        and (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   -1265:w               {A@1}
        or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   1264:w               {A@1}
        mov (1|M0)               r1.5<1>:f     (abs)r103.1<0;1,0>:d             {A@1}
        mov (1|M0)               r5.6<1>:f     0xB4C00000:f                               {Compacted}
        math.inv (1|M0)          r4.7<1>:f     r1.5<0;1,0>:f                    {@2,$14}
        mov (1|M0)               r2.1<1>:f     (abs)r103.0<0;1,0>:d             {Compacted}
        sync.nop                             null                             {Compacted,$14.dst}
        mad (1|M0)               r4.7<1>:f     r4.7<0;0>:f       r5.6<0;0>:f       r4.7<0>:f        {F@2}
        mov (1|M0)               r1.3<1>:d     (abs)r103.0<0;1,0>:d            
        mov (1|M0)               r1.4<1>:d     (abs)r103.1<0;1,0>:d            
        mov (1|M0)               r1.6<1>:ud    r1.5<0;1,0>:f                   
        mov (1|M0)               r3.5<1>:ud    r2.1<0;1,0>:f                    {F@2}
        mul (1|M0)               r6.0<1>:f     r4.7<0;1,0>:f     r2.1<0;1,0>:f    {A@1}
        add (1|M0)               r1.6<1>:ud    r1.4<0;1,0>:ud    -r1.6<0;1,0>:ud  {I@2}
        add (1|M0)               r3.5<1>:ud    r1.3<0;1,0>:ud    -r3.5<0;1,0>:ud  {I@2}
        mov (1|M0)               r7.0<1>:ud    r6.0<0;1,0>:f                    {F@1}
        mov (1|M0)               r2.0<1>:f     r1.6<0;1,0>:ud                   {Compacted,I@3}
        mov (1|M0)               r4.1<1>:f     r3.5<0;1,0>:ud                   {I@2}
        mov (1|M0)               r7.1<1>:f     r7.0<0;1,0>:ud                   {Compacted,I@1}
        xor (1|M0)               r103.1<1>:d   r103.1<0;1,0>:d   r103.0<0;1,0>:d  {Compacted}
        mad (1|M0)               r2.1<1>:f     r2.1<0;0>:f       r7.1<0;0>:f       -r1.5<0>:f       {F@1}
        mad (1|M0)               r7.1<1>:f     r4.1<0;0>:f       r7.1<0;0>:f       -r2.0<0>:f      
(W)     mov (1|M0)               r3.10<1>:hf   0x1:hf                             
        add (1|M0)               r2.1<1>:f     r2.1<0;1,0>:f     r7.1<0;1,0>:f    {F@2}
        asr (1|M0)               r103.1<1>:d   r103.1<0;1,0>:d   31:w               {Compacted,I@1}
        mul (1|M0)               r4.7<1>:f     r4.7<0;1,0>:f     r2.1<0;1,0>:f    {F@1}
        mov (1|M0)               r8.0<1>:ud    r4.7<0;1,0>:f                    {F@1}
        add (1|M0)               r7.0<1>:ud    r7.0<0;1,0>:ud    r8.0<0;1,0>:ud   {Compacted,I@1}
(W)     mul (1|M0)               acc0.0<1>:ud  r7.0<0;1,0>:ud    r1.8<0;1,0>:uw   {I@1}
        mach (1|M0)              r9.0<1>:ud    r7.0<0;1,0>:ud    r1.4<0;1,0>:ud   {Compacted}
        add (1|M0)               r1.3<1>:ud    r1.3<0;1,0>:ud    -r9.0<0;1,0>:ud  {Compacted,I@1}
        cmp (1|M0)    (ge)f0.1   null<1>:ud    r1.3<0;1,0>:ud    r1.4<0;1,0>:ud   {I@1}
(f0.1)  sel (1|M0)               r5.6<1>:d     r3.10<0;1,0>:w    0:w              
        add3 (1|M0)              r7.0<1>:d     r7.0<0;0>:d       r103.1<0;0>:d     r5.6<0>:d        {I@1}
        xor (1|M0)               r90.6<1>:d    r7.0<0;1,0>:d     r103.1<0;1,0>:d  {I@1}
        mov (1|M0)               cr0.0<1>:ud   r1.2<0;1,0>:d                    {A@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        ret (16|M0)                          r103.2                           {A@1}
L10120:
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
