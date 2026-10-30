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
        mov (1|M0)               r76.0<1>:d    r0.1<0;1,0>:ud                   {A@1}
        mov (1|M0)               r76.2<1>:d    r1.0<0;1,0>:uw                   {$0.dst}
        mov (1|M0)               r10.5<1>:d    r2.2<0;1,0>:d                    {$1.dst}
        mov (1|M0)               r10.4<1>:d    r76.0<0;1,0>:d                   {I@3}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r10.0         L23448                                 {A@1}
L320:
        asr (1|M0)               r76.1<1>:d    r2.3<0;1,0>:d     31:w              
        mov (1|M0)               r10.2<1>:d    r75.1<0;1,0>:d                  
        shr (1|M0)               r76.1<1>:ud   r76.1<0;1,0>:ud   0x19:uw              {I@2}
(W)     mul (1|M0)               acc0.0<1>:d   r10.2<0;1,0>:d    r2.4<0;1,0>:uw   {I@2}
        mach (1|M0)              r2.0<1>:d     r10.2<0;1,0>:d    r2.2<0;1,0>:d   
        add (1|M0)               r76.1<1>:d    r2.3<0;1,0>:d     r76.1<0;1,0>:d   {I@3}
        add (1|M0)               r76.0<1>:d    r76.0<0;1,0>:d    -r2.0<0;1,0>:d   {Compacted,I@2}
        asr (1|M0)               r76.1<1>:d    r76.1<0;1,0>:d    7:w               {Compacted,I@2}
        mov (2|M0)               r10.4<1>:d    r76.0<1;1,0>:d                   {I@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r10.0         L23448                                 {A@1}
L496:
        mov (1|M0)               r77.5<1>:d    r10.2<0;1,0>:d                  
(W)     mul (1|M0)               acc0.0<1>:d   r75.1<0;1,0>:d    r76.2<0;1,0>:uw 
(W)     mach (1|M0)              r2.0<1>:d     r75.1<0;1,0>:d    r76.1<0;1,0>:d  
        mul (1|M0)               acc0.0<1>:ud  r77.5<0;1,0>:ud   r2.12<0;1,0>:uw  {I@3}
        mach (1|M0)              r10.0<1>:ud   r77.5<0;1,0>:ud   r2.6<0;1,0>:ud   {AccWrEn}
        asr (1|M0)               r77.6<1>:d    r10.2<0;1,0>:d    31:w              
        shl (1|M0)               r1.2<1>:ud    r76.2<0;1,0>:ud   0x2:uw             
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r77.5<0;1,0>:d    r2.14<0;1,0>:uw 
        mov (1|M0)               r76.1<1>:d    r2.0<0;1,0>:d                    {I@7}
        mach (1|M0)              r2.0<1>:d     r77.5<0;1,0>:d    r2.7<0;1,0>:d   
(W)     mul (1|M0)               acc0.0<1>:d   r77.6<0;1,0>:d    r2.12<0;1,0>:uw  {Compacted,I@6}
        mov (1|M0)               r7.0<1>:f     0.0:f                               {Compacted}
        add (1|M0)               r6.0<1>:ud    r1.2<0;1,0>:ud    0x3000:uw              {I@6}
        add (1|M0)               r8.0<1>:ud    r1.2<0;1,0>:ud    0x3080:uw             
        mach (1|M0)              r11.0<1>:d    r77.6<0;1,0>:d    r2.6<0;1,0>:d    {Compacted}
        addc (1|M0)              r12.0<1>:ud   r2.4<0;1,0>:ud    r9.0<0;1,0>:ud   {AccWrEn,I@7}
        asr (1|M0)               r75.7<1>:d    r3.4<0;1,0>:d     31:w              
        send.slm (1|M0)          null     r6      r7:1    0x0            0x02000504           {A@1,$2} // wr:1+1, rd:0; store.slm.d32.a32
        send.slm (1|M0)          null     r8      r7:1    0x0            0x02000504           {A@4,$3} // wr:1+1, rd:0; store.slm.d32.a32
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$3.src}
        mul (1|M0)               acc0.0<1>:ud  r77.5<0;1,0>:ud   r3.4<0;1,0>:uw  
        shr (1|M0)               r75.7<1>:ud   r75.7<0;1,0>:ud   0x1B:uw              {I@3}
        mach (1|M0)              r14.0<1>:ud   r77.5<0;1,0>:ud   r3.2<0;1,0>:ud   {AccWrEn}
        add (1|M0)               r75.7<1>:d    r3.4<0;1,0>:d     r75.7<0;1,0>:d   {I@2}
        mov (1|M0)               r13.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r77.5<0;1,0>:d    r3.6<0;1,0>:uw  
        mach (1|M0)              r8.0<1>:d     r77.5<0;1,0>:d    r3.3<0;1,0>:d   
(W)     mul (1|M0)               acc0.0<1>:d   r77.6<0;1,0>:d    r3.4<0;1,0>:uw  
        add3 (1|M0)              r6.1<1>:d     r11.0<0;0>:d      r10.0<0;0>:d      r2.0<0>:d        {$2.src}
        asr (1|M0)               r75.7<1>:d    r75.7<0;1,0>:d    5:w               {I@6}
        mach (1|M0)              r15.0<1>:d    r77.6<0;1,0>:d    r3.2<0;1,0>:d   
        addc (1|M0)              r2.0<1>:ud    r3.0<0;1,0>:ud    r13.0<0;1,0>:ud  {AccWrEn,I@7}
        add3 (1|M0)              r1.3<1>:d     r7.0<0;0>:d       r2.5<0;0>:d       r6.1<0>:d        {I@4}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r75.1<0;1,0>:d    r75.14<0;1,0>:uw {I@5}
        mach (1|M0)              r6.0<1>:d     r75.1<0;1,0>:d    r75.7<0;1,0>:d  
(W)     mul (1|M0)               acc0.0<1>:d   r75.1<0;1,0>:d    r75.14<0;1,0>:uw
        mach (1|M0)              r7.0<1>:d     r75.1<0;1,0>:d    r75.7<0;1,0>:d  
        add (1|M0)               r8.3<1>:d     r76.0<0;1,0>:d    -r76.1<0;1,0>:d 
        shl (1|M0)               r1.4<1>:d     r7.0<0;1,0>:d     11:w               {Compacted,I@2}
        add3 (1|M0)              r1.5<1>:d     r15.0<0;0>:d      r14.0<0;0>:d      r8.0<0>:d       
        asr (1|M0)               r7.1<1>:d     r6.0<0;1,0>:d     31:w               {Compacted}
        shl (1|M0)               r10.2<1>:d    r8.3<0;1,0>:d     12:w               {I@4}
        addc (1|M0)              r8.0<1>:ud    r12.0<0;1,0>:ud   r1.4<0;1,0>:ud   {AccWrEn,I@4}
        shr (1|M0)               r3.5<1>:ud    r7.0<0;1,0>:ud    0x15:uw             
        add3 (1|M0)              r10.1<1>:d    r9.0<0;0>:d       r3.1<0;0>:d       r1.5<0>:d        {I@5}
        shl (1|M0)               r2.1<1>:d     r7.1<0;1,0>:d     11:w               {Compacted,I@5}
        shl (1|M0)               r7.0<1>:ud    r76.2<0;1,0>:ud   0x6:uw             
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r6.0<1>:ud    r2.0<0;1,0>:ud    r10.2<0;1,0>:ud  {AccWrEn,I@7}
        shl (1|M0)               r1.2<1>:ud    r76.2<0;1,0>:ud   0x7:uw             
        shr (1|M0)               r4.1<1>:ud    r8.3<0;1,0>:ud    0x14:uw             
        or (1|M0)                r1.5<1>:d     r2.1<0;1,0>:d     r3.5<0;1,0>:d    {I@6}
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r13.0<1>:ud   r8.0<0;1,0>:ud    r7.0<0;1,0>:ud   {AccWrEn,I@7}
        or (1|M0)                r10.3<1>:d    r4.1<0;1,0>:d     0:w               {I@4}
        add3 (1|M0)              r8.2<1>:d     r9.0<0;0>:d       r1.3<0;0>:d       r1.5<0>:d        {I@4}
        mov (1|M0)               r12.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r9.0<1>:ud    r6.0<0;1,0>:ud    r1.2<0;1,0>:ud   {AccWrEn}
        add3 (1|M0)              r6.2<1>:d     r11.0<0;0>:d      r10.1<0;0>:d      r10.3<0>:d       {I@4}
        mov (1|M0)               r2.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        add (1|M0)               r75.2<1>:d    r76.0<0;1,0>:d    -r76.1<0;1,0>:d 
        mov (1|M0)               r78.0<1>:f    r9.0<0;1,0>:f                    {Compacted,I@4}
        mov (1|M0)               r76.0<1>:f    r13.0<0;1,0>:f                   {Compacted,I@1}
        add3 (1|M0)              r76.1<1>:d    r12.0<0;0>:d      r8.2<0;0>:d       0:w              
        add3 (1|M0)              r78.1<1>:d    r2.0<0;0>:d       r6.2<0;0>:d       0:w              
        send.ugm (1|M0)          r14      r76     null:0  0x0            0x0220C780           {A@1,$4} // wr:1+0, rd:2; load.ugm.d64x8t.a64
        send.ugm (1|M0)          r16      r78     null:0  0x0            0x0240D780           {A@1,$5} // wr:1+0, rd:4; load.ugm.d64x16t.a64
        add (1|M0)               r79.0<1>:ud   r1.2<0;1,0>:ud    0x1000:uw             
        shr (1|M0)               r75.0<1>:ud   r76.2<0;1,0>:ud   0x3:uw             
        and (1|M0)               r77.0<1>:d    r1.0<0;1,0>:uw    7:w              
        send.slm (1|M0)          null     r7      r14:2   0x0            0x0200C704           {$4} // wr:1+2, rd:0; store.slm.d64x8t.a32
        send.slm (1|M0)          null     r79     r16:4   0x0            0x0200D704           {A@3,$5} // wr:1+4, rd:0; store.slm.d64x16t.a32
(W)     send.slm (1|M0)          r10      r0      null:0  0x0            0x0210001F           {$6} // wr:1+0, rd:1; fence.slm.none.group
(W)     mov (1|M0)               r8.2<1>:f     0.0:f                               {Compacted}
(W)     mov (2|M0)               r8.10<1>:ub   r0.11<0;1,0>:ub                  {F@1}
(W)     mov (8|M0)               null<1>:ud    r10.0<1;1,0>:ud                  {$6.dst}
(W)     send.gtwy (1|M0)         null     r8      null:0  0x0            0x02000004           {A@2,$7} // wr:1+0, rd:0; signal barrier
(W)     sync.bar                             null                            
        cmp (1|M0)    (gt)f0.0   null<1>:d     r3.4<0;1,0>:d     31:w              
        shl (1|M0)               r75.4<1>:ud   r75.0<0;1,0>:ud   0x9:uw             
        shl (1|M0)               r75.3<1>:d    r77.0<0;1,0>:d    9:w               {Compacted}
        mov (16|M0)              r67.0<1>:d    0:w                              
(W)     and (1|M0)               f0.0<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
        mov (16|M0)              r69.0<1>:d    0:w                              
        mov (16|M0)              r71.0<1>:d    0:w                              
        mov (16|M0)              r73.0<1>:d    0:w                              
        mov (16|M0)              r59.0<1>:d    0:w                              
        mov (16|M0)              r61.0<1>:d    0:w                              
        mov (16|M0)              r63.0<1>:d    0:w                              
        mov (16|M0)              r65.0<1>:d    0:w                              
        mov (16|M0)              r51.0<1>:d    0:w                              
        mov (16|M0)              r53.0<1>:d    0:w                              
        mov (16|M0)              r55.0<1>:d    0:w                              
        mov (16|M0)              r57.0<1>:d    0:w                              
        mov (16|M0)              r43.0<1>:d    0:w                              
        mov (16|M0)              r45.0<1>:d    0:w                              
        mov (16|M0)              r47.0<1>:d    0:w                              
        mov (16|M0)              r49.0<1>:d    0:w                              
(~f0.0.any16h) goto (16|M0)                  L3264                  L3264                
L1968:
        asr (1|M0)               r1.3<1>:d     r2.3<0;1,0>:d     31:w               {Compacted}
        shr (1|M0)               r2.1<1>:ud    r2.3<0;1,0>:ud    0x1B:uw             
        mov (1|M0)               r75.5<1>:d    r75.7<0;1,0>:d                  
        shl (1|M0)               r2.0<1>:d     r1.3<0;1,0>:d     5:w               {Compacted,I@3}
        shl (1|M0)               r76.2<1>:d    r2.3<0;1,0>:d     5:w              
        mov (1|M0)               r77.2<2>:f    0.0:f                              
        mov (1|M0)               r77.3<2>:f    0.0:f                              
        mov (2|M0)               r76.4<1>:d    r75.5<1;1,0>:d                   {I@3}
        or (1|M0)                r76.3<1>:d    r2.0<0;1,0>:d     r2.1<0;1,0>:d    {I@3}
        asr (1|M0)               r76.5<1>:d    r75.7<0;1,0>:d    31:w              
        mov (1|M0)               r75.6<1>:d    0:w                              
L2128:
        addc (1|M0)              r2.0<1>:ud    r77.2<0;1,0>:ud   0x1:ud              {AccWrEn,F@2}
(W)     mov (1|M0)               r1.3<1>:hf    0x1:hf                             
        mov (1|M0)               r76.6<1>:d    r2.0<0;1,0>:d                    {I@1}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        cmp (1|M0)    (lt)f0.1   null<1>:ud    r76.6<0;1,0>:ud   r76.4<0;1,0>:ud  {I@2}
        add3 (1|M0)              r76.7<1>:d    r6.0<0;0>:d       r77.3<0;0>:d      0:w               {A@2}
        and (1|M0)               r75.7<1>:d    r77.2<0;1,0>:d    1:w              
        cmp (1|M0)    (lt)f1.0   null<1>:d     r76.7<0;1,0>:d    r76.5<0;1,0>:d   {I@2}
(f0.1)  cmp (1|M0)    (eq)f0.1   null<1>:d     r76.7<0;1,0>:d    r76.5<0;1,0>:d  
(f1.0)  sel (1|M0)               r3.10<1>:uw   r1.3<0;1,0>:uw    0x0:uw              {F@1}
(f0.1)  sel (1|M0)               r1.4<1>:uw    r1.3<0;1,0>:uw    0x0:uw             
        or (1|M0)     (ne)f1.1   null<1>:uw    r1.4<0;1,0>:uw    r3.10<0;1,0>:uw  {I@1}
(W)     and (1|M0)               f1.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(~f1.1.any16h) goto (16|M0)                  L2776                  L2776                
L2344:
        shl (1|M0)               r1.5<1>:d     r76.6<0;1,0>:d    11:w              
        shl (1|M0)               r1.3<1>:d     r76.7<0;1,0>:d    11:w              
        addc (1|M0)              r2.0<1>:ud    r76.0<0;1,0>:ud   r1.5<0;1,0>:ud   {AccWrEn,I@2}
        shr (1|M0)               r1.4<1>:ud    r76.6<0;1,0>:ud   0x15:uw             
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mul (1|M0)               acc0.0<1>:ud  r76.2<0;1,0>:ud   r76.12<0;1,0>:uw
        mach (1|M0)              r12.0<1>:ud   r76.2<0;1,0>:ud   r76.6<0;1,0>:ud  {AccWrEn,$8.src}
        or (1|M0)                r1.6<1>:d     r1.3<0;1,0>:d     r1.4<0;1,0>:d    {I@4}
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r76.2<0;1,0>:d    r76.14<0;1,0>:uw
        mach (1|M0)              r13.0<1>:d    r76.2<0;1,0>:d    r76.7<0;1,0>:d  
(W)     mul (1|M0)               acc0.0<1>:d   r76.3<0;1,0>:d    r76.12<0;1,0>:uw
        mov (1|M0)               r7.0<1>:f     r2.0<0;1,0>:f                    {Compacted,$4.src}
        add3 (1|M0)              r7.1<1>:d     r6.0<0;0>:d       r76.1<0;0>:d      r1.6<0>:d        {I@5}
        mach (1|M0)              r2.0<1>:d     r76.3<0;1,0>:d    r76.6<0;1,0>:d   {F@1}
        addc (1|M0)              r6.0<1>:ud    r78.0<0;1,0>:ud   r11.0<0;1,0>:ud  {AccWrEn,I@6}
        sync.nop                             null                             {Compacted,$7.src}
        send.ugm (1|M0)          r8       r7      null:0  0x0            0x0220C780           {A@3,$10} // wr:1+0, rd:2; load.ugm.d64x8t.a64
        add3 (1|M0)              r1.4<1>:d     r2.0<0;0>:d       r12.0<0;0>:d      r13.0<0>:d       {I@2}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$10.src}
        mov (1|M0)               r14.0<1>:f    r6.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r14.1<1>:d    r7.0<0;0>:d       r78.1<0;0>:d      r1.4<0>:d        {I@1}
        xor (1|M0)               r1.2<1>:d     r75.7<0;1,0>:d    1:w              
        sync.nop                             null                             {Compacted,$5.src}
        send.ugm (1|M0)          r15      r14     null:0  0x0            0x0240D780           {A@1,$11} // wr:1+0, rd:4; load.ugm.d64x16t.a64
        shl (1|M0)               r3.5<1>:d     r1.2<0;1,0>:d     11:w               {I@1}
        shl (1|M0)               r1.2<1>:d     r1.2<0;1,0>:d     12:w              
        mad (1|M0)               r10.0<1>:d    r3.5<0;0>:d       r1.0<0;0>:uw      64:w               {I@2}
        send.slm (1|M0)          null     r10     r8:2    0x0            0x0200C704           {A@1,$10} // wr:1+2, rd:0; store.slm.d64x8t.a32
        add (1|M0)               r8.0<1>:d     r1.2<0;1,0>:d     r79.0<0;1,0>:d   {Compacted,$10.src}
        send.slm (1|M0)          null     r8      r15:4   0x0            0x0200D704           {A@1,$11} // wr:1+4, rd:0; store.slm.d64x16t.a32
L2776:
        join (16|M0)                         L3264                                
L2792:
        shl (1|M0)               r1.2<1>:d     r75.7<0;1,0>:d    11:w              
        shl (1|M0)               r75.7<1>:d    r75.7<0;1,0>:d    12:w              
        add (1|M0)               r2.0<1>:d     r1.2<0;1,0>:d     r75.4<0;1,0>:d   {I@2}
        add (1|M0)               r75.7<1>:d    r75.7<0;1,0>:d    4096:w               {I@2}
        sync.allrd                           ($4,$11)                
        or (1|M0)                r15.0<1>:ud   r2.0<0;1,0>:ud    0x100:uw              {I@2}
        or (1|M0)                r6.0<1>:d     r75.7<0;1,0>:d    r75.3<0;1,0>:d   {I@2}
        bfn.0xFE (1|M0)          r32.0<1>:ud   0x100:uw               r75.7<0;0>:ud     r75.3<0>:ud      // s0|s1|s2
        sync.allrd                           ($7,$8)                
        send.slm (1|M0)          r7       r2      null:0  0x0            0x0280E700           {$12} // wr:1+0, rd:8; load.slm.d64x32t.a32
        send.slm (1|M0)          r16      r15     null:0  0x0            0x0280E700           {A@3,$13} // wr:1+0, rd:8; load.slm.d64x32t.a32
        send.slm (1|M0)          r24      r6      null:0  0x0            0x0280E700           {A@2,$14} // wr:1+0, rd:8; load.slm.d64x32t.a32
        send.slm (1|M0)          r33      r32     null:0  0x0            0x0280E700           {A@1,$15} // wr:1+0, rd:8; load.slm.d64x32t.a32
        sync.allwr                           ($8,$12,$13,$14,$15)                
        dpas.8x8 (8|M0)          r43:d         r43:d             r24:b             r7.0:b           {Atomic}
        dpas.8x8 (8|M0)          r59:d         r59:d             r24:b             r16.0:b          {Atomic}
        dpas.8x8 (8|M0)          r51:d         r51:d             r33:b             r7.0:b           {Atomic}
        dpas.8x8 (8|M0)          r67:d         r67:d             r33:b             r16.0:b          {$8}
(W)     send.slm (1|M0)          r41      r0      null:0  0x0            0x0210001F           {$0} // wr:1+0, rd:1; fence.slm.none.group
(W)     mov (1|M0)               r42.2<1>:f    0.0:f                               {Compacted,$9.src}
(W)     mov (2|M0)               r42.10<1>:ub  r0.11<0;1,0>:ub                  {F@1}
(W)     mov (8|M0)               null<1>:ud    r41.0<1;1,0>:ud                  {$0.dst}
(W)     send.gtwy (1|M0)         null     r42     null:0  0x0            0x02000004           {A@2,$9} // wr:1+0, rd:0; signal barrier
(W)     sync.bar                             null                            
        cmp (1|M0)    (eq)f0.1   null<1>:d     r76.7<0;1,0>:d    r75.6<0;1,0>:d  
(f0.1)  cmp (1|M0)    (eq)f0.1   null<1>:d     r76.6<0;1,0>:d    r75.5<0;1,0>:d  
(W)     and (1|M0)               f1.0<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(f1.0.any16h) goto (16|M0)                   L3264                  L3264                
L3232:
(W)     mov (2|M0)               r77.2<1>:ud   r76.6<1;1,0>:ud                 
        goto.b (16|M0)                       L3264                  L2128                
L3264:
        join (16|M0)                         L3280                                
L3280:
        mov (1|M0)               r1.3<1>:d     r4.0<0;1,0>:d                   
        mov (1|M0)               r11.0<1>:d    r4.4<0;1,0>:d                    {$8.src}
        mul (1|M0)               acc0.0<1>:ud  r77.5<0;1,0>:ud   r1.6<0;1,0>:uw   {I@2}
        mach (1|M0)              r7.0<1>:ud    r77.5<0;1,0>:ud   r1.3<0;1,0>:ud   {AccWrEn,$4.src}
        shl (1|M0)               r75.2<1>:d    r75.2<0;1,0>:d    7:w              
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r77.6<0;1,0>:d    r1.6<0;1,0>:uw  
        sync.nop                             null                             {Compacted,$11.src}
        shl (1|M0)               r15.0<1>:d    r6.0<0;1,0>:d     2:w               {Compacted,I@2}
        mach (1|M0)              r2.0<1>:d     r77.6<0;1,0>:d    r1.3<0;1,0>:d   
        addc (1|M0)              r9.0<1>:ud    r3.6<0;1,0>:ud    r15.0<0;1,0>:ud  {AccWrEn,I@2}
        shl (1|M0)               r1.2<1>:d     r77.0<0;1,0>:d    4:w               {Compacted}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mul (1|M0)               acc0.0<1>:ud  r77.5<0;1,0>:ud   r11.0<0;1,0>:uw 
        mach (1|M0)              r13.0<1>:ud   r77.5<0;1,0>:ud   r11.0<0;1,0>:ud  {AccWrEn}
        shr (1|M0)               r4.1<1>:ud    r6.0<0;1,0>:ud    0x1E:uw             
        mov (1|M0)               r12.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r77.6<0;1,0>:d    r11.0<0;1,0>:uw  {Compacted}
        sync.nop                             null                             {Compacted,$7.src}
        add3 (1|M0)              r8.1<1>:d     r2.0<0;0>:d       r7.0<0;0>:d       0:w               {I@7}
        or (1|M0)                r15.2<1>:d    r75.2<0;1,0>:d    r1.2<0;1,0>:d    {I@7}
        shl (1|M0)               r6.0<1>:d     r12.0<0;1,0>:d    2:w               {Compacted,I@4}
        mach (1|M0)              r2.0<1>:d     r77.6<0;1,0>:d    r11.0<0;1,0>:d   {Compacted}
        shl (1|M0)               r3.5<1>:d     r8.1<0;1,0>:d     2:w               {I@4}
        addc (1|M0)              r7.0<1>:ud    r4.2<0;1,0>:ud    r6.0<0;1,0>:ud   {AccWrEn,I@3}
        add3 (1|M0)              r1.4<1>:d     r2.0<0;0>:d       r13.0<0;0>:d      0:w               {I@3}
        shl (1|M0)               r2.0<1>:d     r15.2<0;1,0>:d    2:w               {Compacted}
        mov (1|M0)               r15.3<1>:d    0:w                              
        mov (1|M0)               r77.2<1>:d    r9.0<0;1,0>:d                   
        or (1|M0)                r15.1<1>:d    r3.5<0;1,0>:d     r4.1<0;1,0>:d    {I@6}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        shl (1|M0)               r3.5<1>:d     r1.4<0;1,0>:d     2:w               {I@6}
        shr (1|M0)               r4.1<1>:ud    r12.0<0;1,0>:ud   0x1E:uw             
        addc (1|M0)              r9.0<1>:ud    r7.0<0;1,0>:ud    r2.0<0;1,0>:ud   {AccWrEn,I@7}
        shr (1|M0)               r7.3<1>:ud    r15.2<0;1,0>:ud   0x1E:uw             
        shl (1|M0)               r5.5<1>:d     r15.3<0;1,0>:d    2:w               {I@7}
        or (1|M0)                r6.1<1>:d     r3.5<0;1,0>:d     r4.1<0;1,0>:d    {I@4}
        mov (1|M0)               r11.0<1>:f    r9.0<0;1,0>:f                    {Compacted,I@4}
        add3 (1|M0)              r77.3<1>:d    r10.0<0;0>:d      r3.7<0;0>:d       r15.1<0>:d      
        or (1|M0)                r2.1<1>:d     r5.5<0;1,0>:d     r7.3<0;1,0>:d    {I@3}
        add3 (1|M0)              r7.2<1>:d     r8.0<0;0>:d       r4.3<0;0>:d       r6.1<0>:d        {I@3}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r6.0<1>:ud    r11.0<0;1,0>:ud   0x20:ud              {AccWrEn,F@1}
        add3 (1|M0)              r11.1<1>:d    r10.0<0;0>:d      r7.2<0;0>:d       r2.1<0>:d        {I@2}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        shl (1|M0)               r75.1<1>:d    r75.1<0;1,0>:d    6:w               {Compacted}
        shl (1|M0)               r77.1<1>:ud   r75.0<0;1,0>:ud   0x4:uw             
        mov (1|M0)               r12.0<1>:f    r6.0<0;1,0>:f                    {Compacted,I@5}
        add3 (1|M0)              r12.1<1>:d    r8.0<0;0>:d       r11.1<0;0>:d      0:w               {I@3}
        sync.nop                             null                             {Compacted,$5.src}
        send.ugm (1|M0)          r79      r11     null:0  0x0            0x0210B780           {$1} // wr:1+0, rd:1; load.ugm.d64x4t.a64
        send.ugm (1|M0)          r78      r12     null:0  0x0            0x0210B780           {A@1,$2} // wr:1+0, rd:1; load.ugm.d64x4t.a64
        mov (1|M0)               r15.6<2>:f    0.0:f                              
        mov (1|M0)               r15.7<2>:f    0.0:f                              
        mov (1|M0)               r15.4<1>:d    0:w                              
        and (1|M0)               r75.2<1>:d    r4.6<0;1,0>:d     -2:w              
        add (1|M0)               r77.1<1>:d    r75.1<0;1,0>:d    r77.1<0;1,0>:d  
        and (1|M0)               r75.1<1>:d    r4.6<0;1,0>:d     -3:w              
L4064:
        or (1|M0)                r3.0<1>:d     r77.1<0;1,0>:d    r15.6<0;1,0>:d   {A@2}
        cmp (1|M0)    (lt)f1.0   null<1>:d     r3.0<0;1,0>:d     r4.5<0;1,0>:d    {I@1}
        or (1|M0)                r3.1<1>:d     r3.0<0;1,0>:d     8:w               {Compacted}
(W)     and (1|M0)               f0.1<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
(f0.1.any16h) goto (16|M0)                   L4160                  L4160                
L4136:
        mov (1|M0)               r3.0<1>:f     0.0:f                               {Compacted,I@3}
        goto (16|M0)                         L4160                  L4296                
L4160:
        join (16|M0)                         L4296                                
L4176:
        asr (1|M0)               r1.3<1>:d     r3.0<0;1,0>:d     31:w               {Compacted,F@1}
        shl (1|M0)               r6.0<1>:d     r3.0<0;1,0>:d     2:w               {Compacted}
        shr (1|M0)               r2.1<1>:ud    r3.0<0;1,0>:ud    0x1E:uw             
        shl (1|M0)               r2.0<1>:d     r1.3<0;1,0>:d     2:w               {Compacted,I@3}
        addc (1|M0)              r7.0<1>:ud    r77.2<0;1,0>:ud   r6.0<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r6.1<1>:d     r2.0<0;1,0>:d     r2.1<0;1,0>:d    {I@2}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r10.0<1>:f    r7.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r10.1<1>:d    r8.0<0;0>:d       r77.3<0;0>:d      r6.1<0>:d        {I@1}
        send.ugm (1|M0)          r3       r10     null:0  0x0            0x04100580           {A@1,$3} // wr:2+0, rd:1; load.ugm.d32.a64
L4296:
        join (16|M0)                         L9064                                
L4312:
        cmp (1|M0)    (lt)f0.1   null<1>:d     r3.1<0;1,0>:d     r4.5<0;1,0>:d    {$3.dst}
(W)     and (1|M0)               f0.0<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(f0.0.any16h) goto (16|M0)                   L4384                  L4384                
L4360:
        mov (1|M0)               r2.0<1>:f     0.0:f                               {Compacted}
        goto (16|M0)                         L4384                  L4528                
L4384:
        join (16|M0)                         L4528                                
L4400:
        asr (1|M0)               r1.3<1>:d     r3.1<0;1,0>:d     31:w              
        shl (1|M0)               r6.0<1>:d     r3.1<0;1,0>:d     2:w               {Compacted}
        shr (1|M0)               r2.1<1>:ud    r3.1<0;1,0>:ud    0x1E:uw             
        shl (1|M0)               r2.0<1>:d     r1.3<0;1,0>:d     2:w               {Compacted,A@1}
        addc (1|M0)              r7.0<1>:ud    r77.2<0;1,0>:ud   r6.0<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r6.1<1>:d     r2.0<0;1,0>:d     r2.1<0;1,0>:d    {I@2}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r10.0<1>:f    r7.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r10.1<1>:d    r8.0<0;0>:d       r77.3<0;0>:d      r6.1<0>:d        {I@1}
        send.ugm (1|M0)          r2       r10     null:0  0x0            0x04100580           {A@1,$4} // wr:2+0, rd:1; load.ugm.d32.a64
L4528:
        join (16|M0)                         L9064                                
L4544:
        shl (1|M0)               r1.3<1>:w     r15.8<0;1,0>:w    5:w              
        mov (2|M0)               r75.4<1>:ud   0x0:ud                             
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0x560:uw              {A@1}
        mov (1|M0)               r75.6<1>:d    0:w                              
        mov (8|M0)               r6.0<1>:ud    r[a0.0]<1;1,0>:ud                {$8.dst}
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0x660:uw              {A@1}
        mov (8|M0)               r95.0<1>:f    r6.0<1;1,0>:d                    {Compacted,I@2}
        mul (8|M0)               r95.0<1>:f    r3.0<0;1,0>:f     r95.0<1;1,0>:f   {Compacted,F@1}
        mov (8|M0)               r7.0<1>:ud    r[a0.0]<1;1,0>:ud               
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0x760:uw              {A@1}
        mov (8|M0)               r94.0<1>:f    r7.0<1;1,0>:d                    {Compacted,I@2}
        sync.nop                             null                             {Compacted,$1.dst}
        mul (8|M0)               r95.0<1>:f    r95.0<1;1,0>:f    r79.0<1;1,0>:f   {Compacted,F@2}
        mul (8|M0)               r94.0<1>:f    r3.0<0;1,0>:f     r94.0<1;1,0>:f   {Compacted,F@2}
        mov (8|M0)               r8.0<1>:ud    r[a0.0]<1;1,0>:ud               
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0x860:uw              {A@1}
        mov (8|M0)               r97.0<1>:f    r8.0<1;1,0>:d                    {Compacted,I@2}
        sync.nop                             null                             {Compacted,$2.dst}
        mul (8|M0)               r94.0<1>:f    r94.0<1;1,0>:f    r78.0<1;1,0>:f   {Compacted,F@2}
        sync.nop                             null                             {Compacted,$4.dst}
        mul (8|M0)               r97.0<1>:f    r2.0<0;1,0>:f     r97.0<1;1,0>:f   {Compacted,F@2}
        mov (8|M0)               r6.0<1>:ud    r[a0.0]<1;1,0>:ud               
        mul (8|M0)               r97.0<1>:f    r97.0<1;1,0>:f    r79.0<1;1,0>:f   {Compacted,A@1}
        mov (8|M0)               r96.0<1>:f    r6.0<1;1,0>:d                    {Compacted,I@1}
        mul (8|M0)               r96.0<1>:f    r2.0<0;1,0>:f     r96.0<1;1,0>:f   {Compacted,F@1}
        mul (8|M0)               r96.0<1>:f    r96.0<1;1,0>:f    r78.0<1;1,0>:f   {Compacted,F@1}
L4840:
        cmp (1|M0)    (eq)f0.1   null<1>:d     r75.2<0;1,0>:d    2:w              
        shl (1|M0)               r8.0<1>:w     r75.12<0;1,0>:w   2:w              
        add (1|M0)               a0.0<1>:uw    r8.0<0;1,0>:uw    0xBE0:uw              {A@1}
(W)     and (1|M0)               f1.1<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
        mov (1|M0)               r8.3<1>:f     r[a0.0]<0;1,0>:f                
(~f1.1.any16h) goto (16|M0)                  L5176                  L5176                 {A@1}
L4936:
        mov (1|M0)               r1.4<2>:hf    r[a0.0]<0;1,0>:f                
        cmp (1|M0)    (lt)f0.0   null<1>:f     r[a0.0]<0;1,0>:f  -4.001953e+00:f               {A@1}
        mov (1|M0)               r1.3<1>:f     r1.4<0;1,0>:hf                   {A@1}
        mov (1|M0)               r2.1<1>:ud    0xBD650000:ud                             
        sel (1|M0)    (lt)f0.0   r1.3<1>:f     r1.3<0;1,0>:f     4.0:f               {F@1}
        mov (1|M0)               r3.5<1>:ud    0x3EE50000:ud                             
(~f0.0) sel (1|M0)               r2.0<1>:f     r1.3<0;1,0>:f     -4.0:f               {F@1}
        mov (1|M0)               r6.0<1>:ud    0x3F650000:ud                             
        mad (1|M0)               r2.1<1>:f     r3.5<0;0>:f       r2.1<0;0>:f       (abs)r2.0<0>:f   {A@1}
        mov (1|M0)               r4.2<2>:hf    r2.1<0;1,0>:f                    {F@1}
        mov (1|M0)               r5.5<1>:f     r4.2<0;1,0>:hf                   {F@1}
        mad (1|M0)               r2.0<1>:f     r6.0<0;0>:f       r5.5<0;0>:f       r2.0<0>:f        {A@1}
        mov (1|M0)               r7.0<2>:hf    r2.0<0;1,0>:f                    {F@1}
        mul (1|M0)               r1.4<1>:hf    r1.4<0;1,0>:hf    r7.0<0;1,0>:hf   {F@1}
        mov (1|M0)               r8.3<1>:f     r1.4<0;1,0>:hf                   {F@1}
L5176:
        join (16|M0)                         L8776                                
L5192:
        cmp (1|M0)    (eq)f0.0   null<1>:d     r75.1<0;1,0>:d    1:w              
        cmp (1|M0)    (eq)f1.1   null<1>:d     r4.6<0;1,0>:d     4:w              
(W)     and (1|M0)               f1.0<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
(W)     mov (1|M0)               r77.8<1>:uw   f1.1<0;1,0>:uw                  
(f1.0.any16h) goto (16|M0)                   L5352                  L5352                
L5272:
(W)     mov (1|M0)               f1.0<1>:uw    r77.8<0;1,0>:uw                  {I@2}
        mov (1|M0)               r1.4<2>:hf    r8.3<0;1,0>:f                    {F@1}
        mov (1|M0)               r75.3<1>:f    r1.4<0;1,0>:hf                   {F@1}
(~f1.0) mov (1|M0)               r75.3<1>:ud   r8.3<0;1,0>:ud                   {F@1}
        goto (16|M0)                         L5352                  L5792                
L5352:
        join (16|M0)                         L5792                                
L5368:
        cmp (1|M0)    (lt)f1.0   null<1>:f     r8.3<0;1,0>:f     0.0:f               {A@3}
(f1.0)  mov (1|M0)               r8.3<1>:f     -r8.3<0;1,0>:f                  
        sel (1|M0)    (lt)f0.0   r8.3<1>:f     r8.3<0;1,0>:f     448.0:f               {F@1}
        shr (1|M0)               r8.1<1>:ud    r8.3<0;1,0>:ud    0x17:uw              {F@1}
        and (1|M0)               r8.1<1>:ud    r8.1<0;1,0>:ud    0xFF:uw              {I@1}
        sel (1|M0)    (ge)f0.0   r8.1<1>:ud    r8.1<0;1,0>:ud    0x79:uw              {I@1}
        shl (1|M0)               r8.1<1>:ud    r8.1<0;1,0>:ud    0x17:uw              {I@1}
        add (1|M0)               r1.2<1>:ud    -r8.1<0;1,0>:ud   0x80800000:ud              {I@1}
        mul (1|M0)               r1.3<1>:f     r8.3<0;1,0>:f     r1.2<0;1,0>:f    {I@1}
        mov (1|M0)               r8.2<1>:d     r1.3<0;1,0>:f                    {F@1}
        mov (1|M0)               r75.3<1>:f    r8.2<0;1,0>:d                    {I@1}
        mad (1|M0)               r8.3<1>:f     -r75.3<0;0>:f     r1.2<0;0>:f       r8.3<0>:f        {F@1}
        cmp (1|M0)    (gt)f1.1   null<1>:f     r8.3<0;1,0>:f     0.5:f               {F@1}
(W)     and (1|M0)               f1.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw              {F@1}
(f1.1.any16h) goto (16|M0)                   L5704                  L5704                
L5608:
        cmp (1|M0)    (lt)f1.1   null<1>:f     r8.3<0;1,0>:f     0.5:f               {A@1}
        and (1|M0)               r8.2<1>:d     r8.2<0;1,0>:d     1:w              
        add (1|M0)               r1.2<1>:f     r75.3<0;1,0>:f    1.0:f              
(~f1.1) cmp (1|M0)    (eq)f1.1   null<1>:d     r8.2<0;1,0>:d     0:w               {A@1}
(~f1.1) mov (1|M0)               r75.3<1>:f    r1.2<0;1,0>:f                    {F@1}
        goto (16|M0)                         L5704                  L5728                
L5704:
        join (16|M0)                         L5728                                
L5720:
        add (1|M0)               r75.3<1>:f    r75.3<0;1,0>:f    1.0:f               {Compacted,F@1}
L5728:
        join (16|M0)                         L5792                                
L5744:
        add (1|M0)               r8.1<1>:ud    r8.1<0;1,0>:ud    0xFE800000:ud             
        mul (1|M0)               r75.3<1>:f    r75.3<0;1,0>:f    r8.1<0;1,0>:f    {A@1}
(f1.0)  mov (1|M0)               r75.3<1>:f    -r75.3<0;1,0>:f                  {F@1}
L5792:
        join (16|M0)                         L8776                                
L5808:
        add (1|M0)               a0.0<1>:uw    r8.0<0;1,0>:uw    0xBC0:uw              {A@1}
(W)     and (1|M0)               f1.0<1>:uw    f0.1<0;1,0>:uw    0x1:uw              {F@1}
        mov (1|M0)               r8.3<1>:f     r[a0.0]<0;1,0>:f                
(~f1.0.any16h) goto (16|M0)                  L6112                  L6112                 {A@1}
L5872:
        mov (1|M0)               r1.4<2>:hf    r[a0.0]<0;1,0>:f                
        cmp (1|M0)    (lt)f1.1   null<1>:f     r[a0.0]<0;1,0>:f  -4.001953e+00:f               {A@1}
        mov (1|M0)               r1.3<1>:f     r1.4<0;1,0>:hf                   {A@1}
        mov (1|M0)               r2.1<1>:ud    0xBD650000:ud                             
        sel (1|M0)    (lt)f0.0   r1.3<1>:f     r1.3<0;1,0>:f     4.0:f               {F@1}
        mov (1|M0)               r3.5<1>:ud    0x3EE50000:ud                             
(~f1.1) sel (1|M0)               r2.0<1>:f     r1.3<0;1,0>:f     -4.0:f               {F@1}
        mov (1|M0)               r6.0<1>:ud    0x3F650000:ud                             
        mad (1|M0)               r2.1<1>:f     r3.5<0;0>:f       r2.1<0;0>:f       (abs)r2.0<0>:f   {A@1}
        mov (1|M0)               r4.2<2>:hf    r2.1<0;1,0>:f                    {F@1}
        mov (1|M0)               r5.5<1>:f     r4.2<0;1,0>:hf                   {F@1}
        mad (1|M0)               r2.0<1>:f     r6.0<0;0>:f       r5.5<0;0>:f       r2.0<0>:f        {A@1}
        mov (1|M0)               r7.0<2>:hf    r2.0<0;1,0>:f                    {F@1}
        mul (1|M0)               r1.4<1>:hf    r1.4<0;1,0>:hf    r7.0<0;1,0>:hf   {F@1}
        mov (1|M0)               r8.3<1>:f     r1.4<0;1,0>:hf                   {F@1}
L6112:
        join (16|M0)                         L8776                                
L6128:
(W)     and (1|M0)               f1.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
(f1.1.any16h) goto (16|M0)                   L6240                  L6240                
L6160:
(W)     mov (1|M0)               f1.1<1>:uw    r77.8<0;1,0>:uw                 
        mov (1|M0)               r1.4<2>:hf    r8.3<0;1,0>:f                    {F@1}
        mov (1|M0)               r75.7<1>:f    r1.4<0;1,0>:hf                   {F@1}
(~f1.1) mov (1|M0)               r75.7<1>:f    r8.3<0;1,0>:f                   
        goto (16|M0)                         L6240                  L6688                
L6240:
        join (16|M0)                         L6688                                
L6256:
        cmp (1|M0)    (lt)f1.1   null<1>:f     r8.3<0;1,0>:f     0.0:f               {I@3}
(f1.1)  mov (1|M0)               r8.3<1>:f     -r8.3<0;1,0>:f                  
        sel (1|M0)    (lt)f0.0   r8.3<1>:f     r8.3<0;1,0>:f     448.0:f               {F@1}
        shr (1|M0)               r8.1<1>:ud    r8.3<0;1,0>:ud    0x17:uw              {F@1}
        and (1|M0)               r8.1<1>:ud    r8.1<0;1,0>:ud    0xFF:uw              {I@1}
        sel (1|M0)    (ge)f0.0   r8.1<1>:ud    r8.1<0;1,0>:ud    0x79:uw              {I@1}
        shl (1|M0)               r8.1<1>:ud    r8.1<0;1,0>:ud    0x17:uw              {I@1}
        add (1|M0)               r1.2<1>:ud    -r8.1<0;1,0>:ud   0x80800000:ud              {I@1}
        mul (1|M0)               r1.3<1>:f     r8.3<0;1,0>:f     r1.2<0;1,0>:f    {I@1}
        mov (1|M0)               r8.2<1>:d     r1.3<0;1,0>:f                    {F@1}
        mov (1|M0)               r75.7<1>:f    r8.2<0;1,0>:d                    {I@1}
        mad (1|M0)               r8.3<1>:f     -r75.7<0;0>:f     r1.2<0;0>:f       r8.3<0>:f        {F@1}
        cmp (1|M0)    (gt)f1.0   null<1>:f     r8.3<0;1,0>:f     0.5:f               {F@1}
(W)     and (1|M0)               f1.0<1>:uw    f1.0<0;1,0>:uw    0x1:uw              {F@1}
(f1.0.any16h) goto (16|M0)                   L6592                  L6592                
L6496:
        cmp (1|M0)    (lt)f1.0   null<1>:f     r8.3<0;1,0>:f     0.5:f               {A@1}
        and (1|M0)               r8.2<1>:d     r8.2<0;1,0>:d     1:w              
        add (1|M0)               r1.2<1>:f     r75.7<0;1,0>:f    1.0:f              
(~f1.0) cmp (1|M0)    (eq)f1.0   null<1>:d     r8.2<0;1,0>:d     0:w               {A@1}
(~f1.0) mov (1|M0)               r75.7<1>:f    r1.2<0;1,0>:f                    {F@1}
        goto (16|M0)                         L6592                  L6624                
L6592:
        join (16|M0)                         L6624                                
L6608:
        add (1|M0)               r75.7<1>:f    r75.7<0;1,0>:f    1.0:f               {F@1}
L6624:
        join (16|M0)                         L6688                                
L6640:
        add (1|M0)               r8.1<1>:ud    r8.1<0;1,0>:ud    0xFE800000:ud             
        mul (1|M0)               r75.7<1>:f    r75.7<0;1,0>:f    r8.1<0;1,0>:f    {A@1}
(f1.1)  mov (1|M0)               r75.7<1>:f    -r75.7<0;1,0>:f                  {F@1}
L6688:
        join (16|M0)                         L8776                                
L6704:
        add (1|M0)               a0.0<1>:uw    r8.0<0;1,0>:uw    0xC20:uw              {A@1}
(W)     and (1|M0)               f1.1<1>:uw    f0.1<0;1,0>:uw    0x1:uw              {F@1}
        mov (1|M0)               r8.3<1>:f     r[a0.0]<0;1,0>:f                
(~f1.1.any16h) goto (16|M0)                  L7008                  L7008                 {A@1}
L6768:
        mov (1|M0)               r1.4<2>:hf    r[a0.0]<0;1,0>:f                
        cmp (1|M0)    (lt)f1.0   null<1>:f     r[a0.0]<0;1,0>:f  -4.001953e+00:f               {A@1}
        mov (1|M0)               r1.3<1>:f     r1.4<0;1,0>:hf                   {A@1}
        mov (1|M0)               r2.1<1>:ud    0xBD650000:ud                             
        sel (1|M0)    (lt)f0.0   r1.3<1>:f     r1.3<0;1,0>:f     4.0:f               {F@1}
        mov (1|M0)               r3.5<1>:ud    0x3EE50000:ud                             
(~f1.0) sel (1|M0)               r2.0<1>:f     r1.3<0;1,0>:f     -4.0:f               {F@1}
        mov (1|M0)               r6.0<1>:ud    0x3F650000:ud                             
        mad (1|M0)               r2.1<1>:f     r3.5<0;0>:f       r2.1<0;0>:f       (abs)r2.0<0>:f   {A@1}
        mov (1|M0)               r4.2<2>:hf    r2.1<0;1,0>:f                    {F@1}
        mov (1|M0)               r5.5<1>:f     r4.2<0;1,0>:hf                   {F@1}
        mad (1|M0)               r2.0<1>:f     r6.0<0;0>:f       r5.5<0;0>:f       r2.0<0>:f        {A@1}
        mov (1|M0)               r7.0<2>:hf    r2.0<0;1,0>:f                    {F@1}
        mul (1|M0)               r1.4<1>:hf    r1.4<0;1,0>:hf    r7.0<0;1,0>:hf   {F@1}
        mov (1|M0)               r8.3<1>:f     r1.4<0;1,0>:hf                   {F@1}
L7008:
        join (16|M0)                         L8776                                
L7024:
(W)     and (1|M0)               f1.0<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
(f1.0.any16h) goto (16|M0)                   L7136                  L7136                
L7056:
(W)     mov (1|M0)               f1.0<1>:uw    r77.8<0;1,0>:uw                 
        mov (1|M0)               r1.4<2>:hf    r8.3<0;1,0>:f                    {F@1}
        mov (1|M0)               r77.7<1>:f    r1.4<0;1,0>:hf                   {F@1}
(~f1.0) mov (1|M0)               r77.7<1>:f    r8.3<0;1,0>:f                   
        goto (16|M0)                         L7136                  L7584                
L7136:
        join (16|M0)                         L7584                                
L7152:
        cmp (1|M0)    (lt)f1.0   null<1>:f     r8.3<0;1,0>:f     0.0:f               {I@3}
(f1.0)  mov (1|M0)               r8.3<1>:f     -r8.3<0;1,0>:f                  
        sel (1|M0)    (lt)f0.0   r8.3<1>:f     r8.3<0;1,0>:f     448.0:f               {F@1}
        shr (1|M0)               r8.1<1>:ud    r8.3<0;1,0>:ud    0x17:uw              {F@1}
        and (1|M0)               r8.1<1>:ud    r8.1<0;1,0>:ud    0xFF:uw              {I@1}
        sel (1|M0)    (ge)f0.0   r8.1<1>:ud    r8.1<0;1,0>:ud    0x79:uw              {I@1}
        shl (1|M0)               r8.1<1>:ud    r8.1<0;1,0>:ud    0x17:uw              {I@1}
        add (1|M0)               r1.2<1>:ud    -r8.1<0;1,0>:ud   0x80800000:ud              {I@1}
        mul (1|M0)               r1.3<1>:f     r8.3<0;1,0>:f     r1.2<0;1,0>:f    {I@1}
        mov (1|M0)               r8.2<1>:d     r1.3<0;1,0>:f                    {F@1}
        mov (1|M0)               r77.7<1>:f    r8.2<0;1,0>:d                    {I@1}
        mad (1|M0)               r8.3<1>:f     -r77.7<0;0>:f     r1.2<0;0>:f       r8.3<0>:f        {F@1}
        cmp (1|M0)    (gt)f1.1   null<1>:f     r8.3<0;1,0>:f     0.5:f               {F@1}
(W)     and (1|M0)               f1.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw              {F@1}
(f1.1.any16h) goto (16|M0)                   L7488                  L7488                
L7392:
        cmp (1|M0)    (lt)f1.1   null<1>:f     r8.3<0;1,0>:f     0.5:f               {A@1}
        and (1|M0)               r8.2<1>:d     r8.2<0;1,0>:d     1:w              
        add (1|M0)               r1.2<1>:f     r77.7<0;1,0>:f    1.0:f              
(~f1.1) cmp (1|M0)    (eq)f1.1   null<1>:d     r8.2<0;1,0>:d     0:w               {A@1}
(~f1.1) mov (1|M0)               r77.7<1>:f    r1.2<0;1,0>:f                    {F@1}
        goto (16|M0)                         L7488                  L7520                
L7488:
        join (16|M0)                         L7520                                
L7504:
        add (1|M0)               r77.7<1>:f    r77.7<0;1,0>:f    1.0:f               {F@1}
L7520:
        join (16|M0)                         L7584                                
L7536:
        add (1|M0)               r8.1<1>:ud    r8.1<0;1,0>:ud    0xFE800000:ud             
        mul (1|M0)               r77.7<1>:f    r77.7<0;1,0>:f    r8.1<0;1,0>:f    {A@1}
(f1.0)  mov (1|M0)               r77.7<1>:f    -r77.7<0;1,0>:f                  {F@1}
L7584:
        join (16|M0)                         L8776                                
L7600:
        add (1|M0)               a0.0<1>:uw    r8.0<0;1,0>:uw    0xC00:uw              {A@1}
(W)     and (1|M0)               f1.1<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
        mov (1|M0)               r2.1<1>:f     r[a0.0]<0;1,0>:f                
(~f1.1.any16h) goto (16|M0)                  L7904                  L7904                 {A@1}
L7664:
        mov (1|M0)               r1.4<2>:hf    r[a0.0]<0;1,0>:f                
        cmp (1|M0)    (lt)f0.1   null<1>:f     r[a0.0]<0;1,0>:f  -4.001953e+00:f               {A@1}
        mov (1|M0)               r1.3<1>:f     r1.4<0;1,0>:hf                   {A@1}
        mov (1|M0)               r2.1<1>:ud    0xBD650000:ud                             
        sel (1|M0)    (lt)f0.0   r1.3<1>:f     r1.3<0;1,0>:f     4.0:f               {F@1}
        mov (1|M0)               r3.5<1>:ud    0x3EE50000:ud                             
(~f0.1) sel (1|M0)               r2.0<1>:f     r1.3<0;1,0>:f     -4.0:f               {F@1}
        mov (1|M0)               r6.0<1>:ud    0x3F650000:ud                             
        mad (1|M0)               r2.1<1>:f     r3.5<0;0>:f       r2.1<0;0>:f       (abs)r2.0<0>:f   {A@1}
        mov (1|M0)               r4.2<2>:hf    r2.1<0;1,0>:f                    {F@1}
        mov (1|M0)               r5.5<1>:f     r4.2<0;1,0>:hf                   {F@1}
        mad (1|M0)               r2.0<1>:f     r6.0<0;0>:f       r5.5<0;0>:f       r2.0<0>:f        {A@1}
        mov (1|M0)               r7.0<2>:hf    r2.0<0;1,0>:f                    {F@1}
        mul (1|M0)               r1.4<1>:hf    r1.4<0;1,0>:hf    r7.0<0;1,0>:hf   {F@1}
        mov (1|M0)               r2.1<1>:f     r1.4<0;1,0>:hf                   {F@1}
L7904:
        join (16|M0)                         L8776                                
L7920:
(W)     and (1|M0)               f1.0<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
(f1.0.any16h) goto (16|M0)                   L8032                  L8032                
L7952:
(W)     mov (1|M0)               f1.1<1>:uw    r77.8<0;1,0>:uw                 
        mov (1|M0)               r1.4<2>:hf    r2.1<0;1,0>:f                    {F@1}
        mov (1|M0)               r2.0<1>:f     r1.4<0;1,0>:hf                   {F@1}
(~f1.1) mov (1|M0)               r2.0<1>:f     r2.1<0;1,0>:f                   
        goto (16|M0)                         L8032                  L8432                
L8032:
        join (16|M0)                         L8432                                
L8048:
        cmp (1|M0)    (lt)f1.0   null<1>:f     r2.1<0;1,0>:f     0.0:f               {A@4}
(f1.0)  mov (1|M0)               r2.1<1>:f     -r2.1<0;1,0>:f                  
        sel (1|M0)    (lt)f0.0   r2.1<1>:f     r2.1<0;1,0>:f     448.0:f               {F@1}
        shr (1|M0)               r2.2<1>:ud    r2.1<0;1,0>:ud    0x17:uw              {F@1}
        and (1|M0)               r2.2<1>:ud    r2.2<0;1,0>:ud    0xFF:uw              {I@1}
        sel (1|M0)    (ge)f0.0   r2.2<1>:ud    r2.2<0;1,0>:ud    0x79:uw              {I@1}
        shl (1|M0)               r2.2<1>:ud    r2.2<0;1,0>:ud    0x17:uw              {I@1}
        add (1|M0)               r1.2<1>:ud    -r2.2<0;1,0>:ud   0x80800000:ud              {I@1}
        mul (1|M0)               r1.3<1>:f     r2.1<0;1,0>:f     r1.2<0;1,0>:f    {I@1}
        mov (1|M0)               r2.3<1>:d     r1.3<0;1,0>:f                    {Compacted,F@1}
        mov (1|M0)               r2.0<1>:f     r2.3<0;1,0>:d                    {Compacted,I@1}
        mad (1|M0)               r2.1<1>:f     -r2.0<0;0>:f      r1.2<0;0>:f       r2.1<0>:f        {F@1}
        cmp (1|M0)    (gt)f0.0   null<1>:f     r2.1<0;1,0>:f     0.5:f               {F@1}
(W)     and (1|M0)               f0.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
(f0.1.any16h) goto (16|M0)                   L8352                  L8352                
L8272:
        cmp (1|M0)    (lt)f0.0   null<1>:f     r2.1<0;1,0>:f     0.5:f               {I@2}
        and (1|M0)               r2.3<1>:d     r2.3<0;1,0>:d     1:w               {Compacted}
        add (1|M0)               r1.2<1>:f     r2.0<0;1,0>:f     1.0:f               {Compacted}
(~f0.0) cmp (1|M0)    (eq)f0.0   null<1>:d     r2.3<0;1,0>:d     0:w               {A@1}
(~f0.0) mov (1|M0)               r2.0<1>:f     r1.2<0;1,0>:f                    {F@1}
        goto (16|M0)                         L8352                  L8376                
L8352:
        join (16|M0)                         L8376                                
L8368:
        add (1|M0)               r2.0<1>:f     r2.0<0;1,0>:f     1.0:f               {Compacted,F@1}
L8376:
        join (16|M0)                         L8432                                
L8392:
        add (1|M0)               r2.2<1>:ud    r2.2<0;1,0>:ud    0xFE800000:ud             
        mul (1|M0)               r2.0<1>:f     r2.0<0;1,0>:f     r2.2<0;1,0>:f    {Compacted,A@1}
(f1.0)  mov (1|M0)               r2.0<1>:f     -r2.0<0;1,0>:f                   {F@1}
L8432:
        join (16|M0)                         L8776                                
L8448:
        cmp (1|M0)    (lt)f1.1   null<1>:f     r75.3<0;1,0>:f    0.0:f              
        add (1|M0)               r75.6<1>:d    r75.6<0;1,0>:d    1:w              
        cmp (1|M0)    (lt)f1.0   null<1>:f     r75.7<0;1,0>:f    0.0:f              
        cmp (1|M0)    (lt)f0.1   null<1>:f     r77.7<0;1,0>:f    0.0:f              
        cmp (1|M0)    (lt)f0.0   null<1>:f     r2.0<0;1,0>:f     0.0:f               {F@4}
(f1.1)  mov (1|M0)               r75.3<1>:f    -r75.3<0;1,0>:f                 
        cmp (1|M0)    (eq)f1.1   null<1>:d     r75.6<0;1,0>:d    8:w               {A@1}
(f1.0)  mov (1|M0)               r75.7<1>:f    -r75.7<0;1,0>:f                 
(f0.1)  mov (1|M0)               r77.7<1>:f    -r77.7<0;1,0>:f                 
(f0.0)  mov (1|M0)               r2.0<1>:f     -r2.0<0;1,0>:f                  
        cmp (1|M0)    (eq)f1.0   null<1>:d     r4.6<0;1,0>:d     4:w               {F@3}
        cmp (1|M0)    (eq)f0.1   null<1>:d     r75.1<0;1,0>:d    1:w               {F@2}
(W)     and (1|M0)               f0.0<1>:uw    f1.1<0;1,0>:uw    0x1:uw              {F@1}
        sel (1|M0)    (ge)f0.0   r75.4<1>:f    r75.4<0;1,0>:f    r75.3<0;1,0>:f  
        sel (1|M0)    (ge)f0.0   r75.5<1>:f    r75.5<0;1,0>:f    r77.7<0;1,0>:f  
(W)     mov (1|M0)               r77.8<1>:uw   f1.0<0;1,0>:uw                   {Compacted}
(W)     mov (1|M0)               r77.9<1>:uw   f0.1<0;1,0>:uw                  
        sel (1|M0)    (ge)f0.0   r75.4<1>:f    r75.4<0;1,0>:f    r75.7<0;1,0>:f   {F@2}
        cmp (1|M0)    (eq)f1.0   null<1>:d     r75.2<0;1,0>:d    2:w              
        sel (1|M0)    (ge)f0.0   r75.5<1>:f    r75.5<0;1,0>:f    r2.0<0;1,0>:f    {F@2}
(~f0.0.any16h) goto.b (16|M0)                L8776                  L4840                
L8776:
        join (16|M0)                         L9064                                
L8792:
        or (1|M0)                r2.0<1>:d     r15.6<0;1,0>:d    8:w               {Compacted,F@1}
        addc (1|M0)              r6.0<1>:ud    r15.6<0;1,0>:ud   0x1:ud              {AccWrEn}
        shl (1|M0)               r1.3<1>:w     r15.12<0;1,0>:w   2:w              
        shl (1|M0)               r3.10<1>:w    r2.0<0;1,0>:w     2:w               {I@3}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0xA00:uw              {A@1}
        mov (1|M0)               r[a0.0]<1>:f  r75.4<0;1,0>:f                  
        add (1|M0)               a0.0<1>:uw    r3.10<0;1,0>:uw   0xA00:uw              {A@1}
        mov (1|M0)               r[a0.0]<1>:f  r75.5<0;1,0>:f                  
        add3 (1|M0)              r75.5<1>:d    r7.0<0;0>:d       r15.7<0;0>:d      0:w               {A@1}
        mov (1|M0)               r75.4<1>:d    r6.0<0;1,0>:d                   
        cmp (1|M0)    (eq)f1.1   null<1>:d     r75.5<0;1,0>:d    0:w               {I@2}
        add (1|M0)               r15.4<1>:d    r15.4<0;1,0>:d    1:w              
(f1.1)  cmp (1|M0)    (eq)f1.1   null<1>:d     r75.4<0;1,0>:d    8:w               {I@3}
(W)     and (1|M0)               f1.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(f1.1.any16h) goto (16|M0)                   L9064                  L9064                
L9032:
(W)     mov (2|M0)               r15.6<1>:ud   r75.4<1;1,0>:ud                 
        goto.b (16|M0)                       L9064                  L4064                
L9064:
        join (16|M0)                         L9080                                
L9080:
        shl (1|M0)               r75.0<1>:ud   r75.0<0;1,0>:ud   0x6:uw             
        mov (1|M0)               r7.0<1>:f     r80.1<0;1,0>:f                   {Compacted}
        mov (1|M0)               r9.0<1>:f     r81.1<0;1,0>:f                   {Compacted}
        sync.allrd                           ($3,$4)                
        mov (1|M0)               r11.0<1>:f    r80.2<0;1,0>:f                   {Compacted,$1.src}
        mov (1|M0)               r13.0<1>:f    r81.2<0;1,0>:f                   {Compacted}
        sync.nop                             null                             {Compacted,$3.dst}
        add (1|M0)               r3.0<1>:ud    r75.0<0;1,0>:ud   0x3000:uw              {I@1}
        add (1|M0)               r2.0<1>:ud    r75.0<0;1,0>:ud   0x3020:uw              {$4.dst}
        add (1|M0)               r6.0<1>:ud    r75.0<0;1,0>:ud   0x3004:uw             
        add (1|M0)               r8.0<1>:ud    r75.0<0;1,0>:ud   0x3024:uw             
        add (1|M0)               r10.0<1>:ud   r75.0<0;1,0>:ud   0x3008:uw             
        add (1|M0)               r12.0<1>:ud   r75.0<0;1,0>:ud   0x3028:uw              {$2.src}
        send.slm (1|M0)          null     r3      r80:1   0x0            0x02000516           {A@6,$5} // wr:1+1, rd:0; atomic_fmax.slm.d32.a32
        send.slm (1|M0)          null     r2      r81:1   0x0            0x02000516           {A@5,$6} // wr:1+1, rd:0; atomic_fmax.slm.d32.a32
        send.slm (1|M0)          null     r6      r7:1    0x0            0x02000516           {A@4,$7} // wr:1+1, rd:0; atomic_fmax.slm.d32.a32
        send.slm (1|M0)          null     r8      r9:1    0x0            0x02000516           {A@3,$8} // wr:1+1, rd:0; atomic_fmax.slm.d32.a32
        send.slm (1|M0)          null     r10     r11:1   0x0            0x02000516           {A@2,$10} // wr:1+1, rd:0; atomic_fmax.slm.d32.a32
        send.slm (1|M0)          null     r12     r13:1   0x0            0x02000516           {A@1,$11} // wr:1+1, rd:0; atomic_fmax.slm.d32.a32
        mov (1|M0)               r14.0<1>:f    r80.3<0;1,0>:f                   {Compacted}
        add (1|M0)               r2.0<1>:ud    r75.0<0;1,0>:ud   0x300C:uw              {$6.src}
        add (1|M0)               r6.0<1>:ud    r75.0<0;1,0>:ud   0x302C:uw              {$7.src}
        mov (1|M0)               r7.0<1>:f     r81.3<0;1,0>:f                   {Compacted}
        add (1|M0)               r8.0<1>:ud    r75.0<0;1,0>:ud   0x3010:uw              {$8.src}
        mov (1|M0)               r9.0<1>:f     r80.4<0;1,0>:f                   {Compacted}
        add (1|M0)               r10.0<1>:ud   r75.0<0;1,0>:ud   0x3030:uw              {$10.src}
        mov (1|M0)               r11.0<1>:f    r81.4<0;1,0>:f                   {Compacted}
        add (1|M0)               r12.0<1>:ud   r75.0<0;1,0>:ud   0x3014:uw              {$11.src}
        mov (1|M0)               r13.0<1>:f    r80.5<0;1,0>:f                   {Compacted}
        send.slm (1|M0)          null     r2      r14:1   0x0            0x02000516           {A@5,$12} // wr:1+1, rd:0; atomic_fmax.slm.d32.a32
        send.slm (1|M0)          null     r6      r7:1    0x0            0x02000516           {A@4,$13} // wr:1+1, rd:0; atomic_fmax.slm.d32.a32
        send.slm (1|M0)          null     r8      r9:1    0x0            0x02000516           {A@3,$14} // wr:1+1, rd:0; atomic_fmax.slm.d32.a32
        send.slm (1|M0)          null     r10     r11:1   0x0            0x02000516           {A@2,$15} // wr:1+1, rd:0; atomic_fmax.slm.d32.a32
        send.slm (1|M0)          null     r12     r13:1   0x0            0x02000516           {A@1,$0} // wr:1+1, rd:0; atomic_fmax.slm.d32.a32
        add (1|M0)               r2.0<1>:ud    r75.0<0;1,0>:ud   0x3034:uw              {$12.src}
        mov (1|M0)               r14.0<1>:f    r81.5<0;1,0>:f                   {Compacted}
        add (1|M0)               r6.0<1>:ud    r75.0<0;1,0>:ud   0x3018:uw              {$13.src}
        mov (1|M0)               r7.0<1>:f     r80.6<0;1,0>:f                   {Compacted}
        add (1|M0)               r8.0<1>:ud    r75.0<0;1,0>:ud   0x3038:uw              {$14.src}
        mov (1|M0)               r9.0<1>:f     r81.6<0;1,0>:f                   {Compacted}
        add (1|M0)               r10.0<1>:ud   r75.0<0;1,0>:ud   0x301C:uw              {$15.src}
        mov (1|M0)               r11.0<1>:f    r80.7<0;1,0>:f                   {Compacted}
        mov (1|M0)               r12.0<1>:f    r81.7<0;1,0>:f                   {Compacted,$0.src}
        add (1|M0)               r75.0<1>:ud   r75.0<0;1,0>:ud   0x303C:uw             
        send.slm (1|M0)          null     r2      r14:1   0x0            0x02000516           {A@5,$1} // wr:1+1, rd:0; atomic_fmax.slm.d32.a32
        send.slm (1|M0)          null     r6      r7:1    0x0            0x02000516           {A@4,$2} // wr:1+1, rd:0; atomic_fmax.slm.d32.a32
        send.slm (1|M0)          null     r8      r9:1    0x0            0x02000516           {A@3,$3} // wr:1+1, rd:0; atomic_fmax.slm.d32.a32
        send.slm (1|M0)          null     r10     r11:1   0x0            0x02000516           {A@2,$4} // wr:1+1, rd:0; atomic_fmax.slm.d32.a32
        send.slm (1|M0)          null     r75     r12:1   0x0            0x02000516           {A@1,$6} // wr:1+1, rd:0; atomic_fmax.slm.d32.a32
(W)     send.slm (1|M0)          r13      r0      null:0  0x0            0x0210001F           {$7} // wr:1+0, rd:1; fence.slm.none.group
(W)     mov (1|M0)               r14.2<1>:f    0.0:f                               {Compacted,$1.src}
(W)     mov (2|M0)               r14.10<1>:ub  r0.11<0;1,0>:ub                  {F@1}
(W)     mov (8|M0)               null<1>:ud    r13.0<1;1,0>:ud                  {$7.dst}
(W)     send.gtwy (1|M0)         null     r14     null:0  0x0            0x02000004           {A@2,$8} // wr:1+0, rd:0; signal barrier
(W)     sync.bar                             null                            
        cmp (1|M0)    (eq)f0.1   null<1>:d     r4.7<0;1,0>:d     0:w              
(W)     and (1|M0)               f0.1<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(f0.1.any16h) goto (16|M0)                   L16776                  L16776                
L9880:
        addc (1|M0)              r2.0<1>:ud    r5.6<0;1,0>:ud    r15.0<0;1,0>:ud  {AccWrEn}
        send.slm (1|M0)          r75      r3      null:0  0x0            0x0220C700           {$10} // wr:1+0, rd:2; load.slm.d64x8t.a32
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$2.src}
        mul (1|M0)               acc0.0<1>:ud  r77.5<0;1,0>:ud   r5.4<0;1,0>:uw  
        mach (1|M0)              r8.0<1>:ud    r77.5<0;1,0>:ud   r5.2<0;1,0>:ud   {AccWrEn,$3.src}
        sync.nop                             null                             {Compacted,$8.src}
        add3 (1|M0)              r14.2<1>:d    r6.0<0;0>:d       r5.7<0;0>:d       r15.1<0>:d       {I@3}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r77.5<0;1,0>:d    r5.6<0;1,0>:uw  
        mach (1|M0)              r9.0<1>:d     r77.5<0;1,0>:d    r5.3<0;1,0>:d   
(W)     mul (1|M0)               acc0.0<1>:d   r77.6<0;1,0>:d    r5.4<0;1,0>:uw  
        mach (1|M0)              r10.0<1>:d    r77.6<0;1,0>:d    r5.2<0;1,0>:d    {$4.src}
        addc (1|M0)              r11.0<1>:ud   r5.0<0;1,0>:ud    r7.0<0;1,0>:ud   {AccWrEn,I@5}
        add3 (1|M0)              r1.3<1>:d     r10.0<0;0>:d      r8.0<0;0>:d       r9.0<0>:d        {I@2}
        mov (1|M0)               r12.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,$6.src}
        addc (1|M0)              r6.0<1>:ud    r11.0<0;1,0>:ud   r15.2<0;1,0>:ud  {AccWrEn,I@3}
        add3 (1|M0)              r2.1<1>:d     r12.0<0;0>:d      r5.1<0;0>:d       r1.3<0>:d        {I@2}
        mov (1|M0)               r13.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        add (1|M0)               r14.5<1>:d    r4.5<0;1,0>:d     -1:w              
        mov (1|M0)               r13.5<1>:d    r5.4<0;1,0>:d                   
        mov (1|M0)               r13.6<1>:d    0:w                              
        mov (1|M0)               r13.4<1>:d    0:w                              
        mov (1|M0)               r14.1<1>:d    r2.0<0;1,0>:d                   
        mov (1|M0)               r14.3<1>:d    r6.0<0;1,0>:d                    {I@7}
        add3 (1|M0)              r14.4<1>:d    r13.0<0;0>:d      r2.1<0;0>:d       r15.3<0>:d       {I@7}
L10240:
        or (1|M0)                r13.3<1>:d    r13.4<0;1,0>:d    r77.1<0;1,0>:d   {I@4}
(W)     mov (1|M0)               r1.3<1>:hf    0x1:hf                             
        or (1|M0)                r13.2<1>:d    r13.3<0;1,0>:d    8:w               {I@1}
        cmp (1|M0)    (lt)f1.1   null<1>:d     r13.3<0;1,0>:d    r4.5<0;1,0>:d   
        cmp (1|M0)    (lt)f0.0   null<1>:d     r13.2<0;1,0>:d    r4.5<0;1,0>:d    {I@2}
        sync.allrd                           ($13,$14)                
(W)     mov (1|M0)               r12.2<1>:uw   f1.1<0;1,0>:uw                   {$12.src}
(W)     mov (1|M0)               r14.12<1>:uw  f0.0<0;1,0>:uw                   {Compacted,$11.src}
(W)     mov (1|M0)               f0.1<1>:uw    r12.2<0;1,0>:uw                  {I@2}
(W)     mov (1|M0)               f0.0<1>:uw    r14.12<0;1,0>:uw                 {I@2}
(f0.1)  sel (1|M0)               r1.4<1>:uw    r1.3<0;1,0>:uw    0x0:uw              {F@1}
(f0.0)  sel (1|M0)               r2.0<1>:uw    r1.3<0;1,0>:uw    0x0:uw             
        or (1|M0)     (ne)f0.0   null<1>:uw    r1.4<0;1,0>:uw    r2.0<0;1,0>:uw   {I@1}
(W)     and (1|M0)               f0.0<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
(~f0.0.any16h) goto (16|M0)                  L16680                  L16680                
L10472:
        shl (1|M0)               r1.3<1>:w     r13.8<0;1,0>:w    2:w              
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0x960:uw              {A@1}
        or (1|M0)                r2.0<1>:uw    r1.3<0;1,0>:uw    0x20:uw             
        add (1|M0)               a0.1<1>:uw    r2.0<0;1,0>:uw    0x960:uw              {A@1}
        cmp (1|M0)    (eq)f1.1   null<1>:f     r[a0.0]<0;1,0>:f  0.0:f               {$10.dst}
        mov (1|M0)               r13.0<1>:f    r[a0.0]<0;1,0>:f                 {A@1}
        mov (1|M0)               r13.7<1>:f    r[a0.1]<0;1,0>:f                 {A@1}
(W)     and (1|M0)               f1.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw              {A@1}
(f1.1.any16h) goto (16|M0)                   L10704                  L10704                
L10616:
        mov (1|M0)               r13.1<1>:f    127.0:f                              
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r12.2         L24032                                 {A@1}
L10680:
        mov (1|M0)               r14.0<1>:f    r15.4<0;1,0>:f                   {Compacted}
        goto (16|M0)                         L10704                  L10728                
L10704:
        join (16|M0)                         L10728                                
L10720:
        mov (1|M0)               r14.0<1>:f    1.0:f                               {Compacted}
L10728:
        join (16|M0)                         L16680                                
L10744:
        cmp (1|M0)    (eq)f0.1   null<1>:f     r[a0.1]<0;1,0>:f  0.0:f              
(W)     and (1|M0)               f0.1<1>:uw    f0.1<0;1,0>:uw    0x1:uw              {A@1}
(f0.1.any16h) goto (16|M0)                   L10888                  L10888                
L10792:
        mov (1|M0)               r13.1<1>:f    127.0:f                              
        mov (1|M0)               r13.0<1>:f    r13.7<0;1,0>:f                   {Compacted}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r12.2         L24032                                 {A@1}
L10864:
        mov (1|M0)               r12.0<1>:f    r15.4<0;1,0>:f                   {Compacted}
        goto (16|M0)                         L10888                  L10912                
L10888:
        join (16|M0)                         L10912                                
L10904:
        mov (1|M0)               r12.0<1>:f    1.0:f                               {Compacted}
L10912:
        join (16|M0)                         L16680                                
L10928:
        cmp (1|M0)    (eq)f0.0   null<1>:d     r77.0<0;1,0>:d    0:w              
(W)     and (1|M0)               f0.0<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
(~f0.0.any16h) goto (16|M0)                  L11312                  L11312                
L10976:
(W)     and (1|M0)               f1.1<1>:uw    r12.2<0;1,0>:uw   0x1:uw             
(~f1.1.any16h) goto (16|M0)                  L11128                  L11128                
L11008:
        asr (1|M0)               r1.3<1>:d     r13.3<0;1,0>:d    31:w               {Compacted}
        shl (1|M0)               r6.0<1>:d     r13.3<0;1,0>:d    2:w               {Compacted}
        shr (1|M0)               r2.1<1>:ud    r13.3<0;1,0>:ud   0x1E:uw             
        shl (1|M0)               r2.0<1>:d     r1.3<0;1,0>:d     2:w               {Compacted,I@3}
        addc (1|M0)              r7.0<1>:ud    r14.1<0;1,0>:ud   r6.0<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r6.1<1>:d     r2.0<0;1,0>:d     r2.1<0;1,0>:d    {I@2}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r10.0<1>:f    r7.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r10.1<1>:d    r8.0<0;0>:d       r14.2<0;0>:d      r6.1<0>:d        {I@1}
        send.ugm (1|M0)          null     r10     r14:1   0x0            0x04000584           {A@1,$11} // wr:2+1, rd:0; store.ugm.d32.a64
L11128:
        join (16|M0)                         L11312                                
L11144:
(W)     and (1|M0)               f0.1<1>:uw    r14.12<0;1,0>:uw  0x1:uw             
(~f0.1.any16h) goto (16|M0)                  L11312                  L11312                
L11176:
        asr (1|M0)               r1.3<1>:d     r13.2<0;1,0>:d    31:w              
        shl (1|M0)               r6.0<1>:d     r13.2<0;1,0>:d    2:w               {Compacted}
        shr (1|M0)               r2.1<1>:ud    r13.2<0;1,0>:ud   0x1E:uw             
        shl (1|M0)               r2.0<1>:d     r1.3<0;1,0>:d     2:w               {Compacted,I@3}
        addc (1|M0)              r7.0<1>:ud    r14.1<0;1,0>:ud   r6.0<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r6.1<1>:d     r2.0<0;1,0>:d     r2.1<0;1,0>:d    {I@2}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        sync.nop                             null                             {Compacted,$11.src}
        mov (1|M0)               r10.0<1>:f    r7.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r10.1<1>:d    r8.0<0;0>:d       r14.2<0;0>:d      r6.1<0>:d        {I@1}
        send.ugm (1|M0)          null     r10     r12:1   0x0            0x04000584           {A@1,$12} // wr:2+1, rd:0; store.ugm.d32.a64
L11312:
        join (16|M0)                         L16680                                
L11328:
        sel (1|M0)    (lt)f0.0   r1.2<1>:d     r13.3<0;1,0>:d    r14.5<0;1,0>:d  
        sel (1|M0)    (lt)f0.0   r1.3<1>:d     r13.3<0;1,0>:d    r14.5<0;1,0>:d  
        sel (1|M0)    (lt)f0.0   r3.5<1>:d     r13.2<0;1,0>:d    r14.5<0;1,0>:d   {$5.src}
        sel (1|M0)    (lt)f0.0   r9.1<1>:d     r13.2<0;1,0>:d    r14.5<0;1,0>:d  
        asr (1|M0)               r1.4<1>:d     r1.2<0;1,0>:d     31:w               {I@4}
        shl (1|M0)               r6.0<1>:d     r1.3<0;1,0>:d     2:w               {Compacted,I@4}
        shr (1|M0)               r2.1<1>:ud    r1.3<0;1,0>:ud    0x1E:uw             
        asr (1|M0)               r9.2<1>:d     r3.5<0;1,0>:d     31:w               {I@5}
        shl (1|M0)               r2.0<1>:d     r1.4<0;1,0>:d     2:w               {Compacted,I@4}
        addc (1|M0)              r7.0<1>:ud    r77.2<0;1,0>:ud   r6.0<0;1,0>:ud   {AccWrEn,I@4}
        shl (1|M0)               r1.3<1>:d     r9.1<0;1,0>:d     2:w              
        shr (1|M0)               r1.2<1>:ud    r9.1<0;1,0>:ud    0x1E:uw             
        shl (1|M0)               r4.1<1>:d     r9.2<0;1,0>:d     2:w               {I@5}
        or (1|M0)                r6.1<1>:d     r2.0<0;1,0>:d     r2.1<0;1,0>:d    {I@5}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r2.0<1>:ud    r77.2<0;1,0>:ud   r1.3<0;1,0>:ud   {AccWrEn,I@5}
        sync.nop                             null                             {Compacted,$12.src}
        mov (1|M0)               r10.0<1>:f    r7.0<0;1,0>:f                    {Compacted,$11.src}
        or (1|M0)                r1.4<1>:d     r4.1<0;1,0>:d     r1.2<0;1,0>:d    {I@4}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,F@1}
        add3 (1|M0)              r10.1<1>:d    r8.0<0;0>:d       r77.3<0;0>:d      r6.1<0>:d        {I@4}
        mov (1|M0)               r6.0<1>:f     r2.0<0;1,0>:f                    {Compacted,I@4}
        add3 (1|M0)              r6.1<1>:d     r7.0<0;0>:d       r77.3<0;0>:d      r1.4<0>:d        {I@2}
        send.ugm (1|M0)          r9       r10     null:0  0x0            0x04100580           {A@2,$15} // wr:2+0, rd:1; load.ugm.d32.a64
        send.ugm (1|M0)          r8       r6      null:0  0x0            0x04100580           {A@1,$0} // wr:2+0, rd:1; load.ugm.d32.a64
        shl (1|M0)               r5.10<1>:w    r13.8<0;1,0>:w    5:w              
        mov (1|M0)               r12.4<1>:d    0:w                              
        add (1|M0)               a0.0<1>:uw    r5.10<0;1,0>:uw   0x560:uw              {A@1}
        mov (8|M0)               r10.0<1>:ud   r[a0.0]<1;1,0>:ud                {$15.src}
        add (1|M0)               a0.0<1>:uw    r5.10<0;1,0>:uw   0x660:uw              {A@1}
        mov (8|M0)               r93.0<1>:f    r10.0<1;1,0>:d                   {Compacted,I@2}
        mov (8|M0)               r11.0<1>:ud   r[a0.0]<1;1,0>:ud               
        add (1|M0)               a0.0<1>:uw    r5.10<0;1,0>:uw   0x760:uw              {A@1}
        mov (8|M0)               r92.0<1>:f    r11.0<1;1,0>:d                   {Compacted,I@2}
        mov (8|M0)               r6.0<1>:ud    r[a0.0]<1;1,0>:ud                {$0.src}
        add (1|M0)               a0.0<1>:uw    r5.10<0;1,0>:uw   0x860:uw              {A@1}
        mov (8|M0)               r91.0<1>:f    r6.0<1;1,0>:d                    {Compacted,I@2}
        mov (8|M0)               r7.0<1>:ud    r[a0.0]<1;1,0>:ud               
        mov (8|M0)               r90.0<1>:f    r7.0<1;1,0>:d                    {Compacted,A@1}
        sync.nop                             null                             {Compacted,$15.dst}
        mul (8|M0)               r93.0<1>:f    r9.0<0;1,0>:f     r93.0<1;1,0>:f   {Compacted,F@4}
        mul (8|M0)               r92.0<1>:f    r9.0<0;1,0>:f     r92.0<1;1,0>:f   {Compacted,F@4}
        sync.nop                             null                             {Compacted,$0.dst}
        mul (8|M0)               r91.0<1>:f    r8.0<0;1,0>:f     r91.0<1;1,0>:f   {Compacted,F@4}
        mul (8|M0)               r90.0<1>:f    r8.0<0;1,0>:f     r90.0<1;1,0>:f   {Compacted,F@4}
        mul (8|M0)               r93.0<1>:f    r93.0<1;1,0>:f    r79.0<1;1,0>:f   {Compacted,F@4}
        mul (8|M0)               r92.0<1>:f    r92.0<1;1,0>:f    r78.0<1;1,0>:f   {Compacted,F@4}
        mul (8|M0)               r91.0<1>:f    r91.0<1;1,0>:f    r79.0<1;1,0>:f   {Compacted,F@4}
        mul (8|M0)               r90.0<1>:f    r90.0<1;1,0>:f    r78.0<1;1,0>:f   {Compacted,F@4}
L11944:
        shl (1|M0)               r12.3<1>:w    r12.8<0;1,0>:w    2:w              
(W)     and (1|M0)               f0.0<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
        add (1|M0)               a0.0<1>:uw    r12.3<0;1,0>:uw   0xBA0:uw              {A@1}
        mov (1|M0)               r4.2<1>:f     r[a0.0]<0;1,0>:f                 {F@4}
(~f0.0.any16h) goto (16|M0)                  L12264                  L12264                 {A@1}
L12024:
        mov (1|M0)               r1.4<2>:hf    r[a0.0]<0;1,0>:f                
        cmp (1|M0)    (lt)f1.1   null<1>:f     r[a0.0]<0;1,0>:f  -4.001953e+00:f               {A@1}
        mov (1|M0)               r1.3<1>:f     r1.4<0;1,0>:hf                   {A@1}
        mov (1|M0)               r2.1<1>:ud    0xBD650000:ud                             
        sel (1|M0)    (lt)f0.0   r1.3<1>:f     r1.3<0;1,0>:f     4.0:f               {F@1}
        mov (1|M0)               r3.5<1>:ud    0x3EE50000:ud                             
(~f1.1) sel (1|M0)               r2.0<1>:f     r1.3<0;1,0>:f     -4.0:f               {F@1}
        mov (1|M0)               r6.0<1>:ud    0x3F650000:ud                             
        mad (1|M0)               r2.1<1>:f     r3.5<0;0>:f       r2.1<0;0>:f       (abs)r2.0<0>:f   {A@1}
        mov (1|M0)               r4.2<2>:hf    r2.1<0;1,0>:f                    {F@1}
        mov (1|M0)               r5.5<1>:f     r4.2<0;1,0>:hf                   {F@1}
        mad (1|M0)               r2.0<1>:f     r6.0<0;0>:f       r5.5<0;0>:f       r2.0<0>:f        {A@1}
        mov (1|M0)               r7.0<2>:hf    r2.0<0;1,0>:f                    {F@1}
        mul (1|M0)               r1.4<1>:hf    r1.4<0;1,0>:hf    r7.0<0;1,0>:hf   {F@1}
        mov (1|M0)               r4.2<1>:f     r1.4<0;1,0>:hf                   {F@1}
L12264:
        join (16|M0)                         L16152                                
L12280:
(W)     and (1|M0)               f1.1<1>:uw    r77.9<0;1,0>:uw   0x1:uw             
(f1.1.any16h) goto (16|M0)                   L12392                  L12392                
L12312:
(W)     mov (1|M0)               f1.1<1>:uw    r77.8<0;1,0>:uw                 
        mov (1|M0)               r1.4<2>:hf    r4.2<0;1,0>:f                    {F@1}
        mov (1|M0)               r13.0<1>:f    r1.4<0;1,0>:hf                   {F@1}
(~f1.1) mov (1|M0)               r13.0<1>:f    r4.2<0;1,0>:f                   
        goto (16|M0)                         L12392                  L12800                
L12392:
        join (16|M0)                         L12800                                
L12408:
        cmp (1|M0)    (lt)f0.0   null<1>:f     r4.2<0;1,0>:f     0.0:f              
(f0.0)  mov (1|M0)               r4.2<1>:f     -r4.2<0;1,0>:f                  
        sel (1|M0)    (lt)f0.0   r4.2<1>:f     r4.2<0;1,0>:f     448.0:f               {F@1}
        shr (1|M0)               r4.0<1>:ud    r4.2<0;1,0>:ud    0x17:uw              {F@1}
        and (1|M0)               r4.0<1>:ud    r4.0<0;1,0>:ud    0xFF:uw              {I@1}
        sel (1|M0)    (ge)f0.0   r4.0<1>:ud    r4.0<0;1,0>:ud    0x79:uw              {I@1}
        shl (1|M0)               r4.0<1>:ud    r4.0<0;1,0>:ud    0x17:uw              {I@1}
        add (1|M0)               r1.2<1>:ud    -r4.0<0;1,0>:ud   0x80800000:ud              {I@1}
        mul (1|M0)               r1.3<1>:f     r4.2<0;1,0>:f     r1.2<0;1,0>:f    {I@1}
        mov (1|M0)               r4.1<1>:d     r1.3<0;1,0>:f                    {F@1}
        mov (1|M0)               r13.0<1>:f    r4.1<0;1,0>:d                    {Compacted,I@1}
        mad (1|M0)               r4.2<1>:f     -r13.0<0;0>:f     r1.2<0;0>:f       r4.2<0>:f        {F@1}
        cmp (1|M0)    (gt)f0.1   null<1>:f     r4.2<0;1,0>:f     0.5:f               {F@1}
(W)     and (1|M0)               f0.1<1>:uw    f0.1<0;1,0>:uw    0x1:uw              {F@1}
(f0.1.any16h) goto (16|M0)                   L12720                  L12720                
L12640:
        cmp (1|M0)    (lt)f0.1   null<1>:f     r4.2<0;1,0>:f     0.5:f               {A@1}
        and (1|M0)               r4.1<1>:d     r4.1<0;1,0>:d     1:w               {Compacted}
        add (1|M0)               r1.2<1>:f     r13.0<0;1,0>:f    1.0:f               {Compacted}
(~f0.1) cmp (1|M0)    (eq)f0.1   null<1>:d     r4.1<0;1,0>:d     0:w               {A@1}
(~f0.1) mov (1|M0)               r13.0<1>:f    r1.2<0;1,0>:f                    {F@1}
        goto (16|M0)                         L12720                  L12744                
L12720:
        join (16|M0)                         L12744                                
L12736:
        add (1|M0)               r13.0<1>:f    r13.0<0;1,0>:f    1.0:f               {Compacted,F@1}
L12744:
        join (16|M0)                         L12800                                
L12760:
        add (1|M0)               r4.0<1>:ud    r4.0<0;1,0>:ud    0xFE800000:ud             
        mul (1|M0)               r13.0<1>:f    r13.0<0;1,0>:f    r4.0<0;1,0>:f    {Compacted,A@1}
(f0.0)  mov (1|M0)               r13.0<1>:f    -r13.0<0;1,0>:f                  {F@1}
L12800:
        join (16|M0)                         L16152                                
L12816:
        add (1|M0)               a0.0<1>:uw    r12.3<0;1,0>:uw   0xB80:uw              {A@1}
(W)     and (1|M0)               f1.1<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
        mov (1|M0)               r4.2<1>:f     r[a0.0]<0;1,0>:f                
(~f1.1.any16h) goto (16|M0)                  L13120                  L13120                 {A@1}
L12880:
        mov (1|M0)               r1.4<2>:hf    r[a0.0]<0;1,0>:f                
        cmp (1|M0)    (lt)f1.1   null<1>:f     r[a0.0]<0;1,0>:f  -4.001953e+00:f               {A@1}
        mov (1|M0)               r1.3<1>:f     r1.4<0;1,0>:hf                   {A@1}
        mov (1|M0)               r2.1<1>:ud    0xBD650000:ud                             
        sel (1|M0)    (lt)f0.0   r1.3<1>:f     r1.3<0;1,0>:f     4.0:f               {F@1}
        mov (1|M0)               r3.5<1>:ud    0x3EE50000:ud                             
(~f1.1) sel (1|M0)               r2.0<1>:f     r1.3<0;1,0>:f     -4.0:f               {F@1}
        mov (1|M0)               r6.0<1>:ud    0x3F650000:ud                             
        mad (1|M0)               r2.1<1>:f     r3.5<0;0>:f       r2.1<0;0>:f       (abs)r2.0<0>:f   {A@1}
        mov (1|M0)               r4.2<2>:hf    r2.1<0;1,0>:f                    {F@1}
        mov (1|M0)               r5.5<1>:f     r4.2<0;1,0>:hf                   {F@1}
        mad (1|M0)               r2.0<1>:f     r6.0<0;0>:f       r5.5<0;0>:f       r2.0<0>:f        {A@1}
        mov (1|M0)               r7.0<2>:hf    r2.0<0;1,0>:f                    {F@1}
        mul (1|M0)               r1.4<1>:hf    r1.4<0;1,0>:hf    r7.0<0;1,0>:hf   {F@1}
        mov (1|M0)               r4.2<1>:f     r1.4<0;1,0>:hf                   {F@1}
L13120:
        join (16|M0)                         L16152                                
L13136:
(W)     and (1|M0)               f0.1<1>:uw    r77.9<0;1,0>:uw   0x1:uw             
(f0.1.any16h) goto (16|M0)                   L13248                  L13248                
L13168:
(W)     mov (1|M0)               f0.1<1>:uw    r77.8<0;1,0>:uw                 
        mov (1|M0)               r1.4<2>:hf    r4.2<0;1,0>:f                    {F@1}
        mov (1|M0)               r13.7<1>:f    r1.4<0;1,0>:hf                   {F@1}
(~f0.1) mov (1|M0)               r13.7<1>:f    r4.2<0;1,0>:f                   
        goto (16|M0)                         L13248                  L13688                
L13248:
        join (16|M0)                         L13688                                
L13264:
        cmp (1|M0)    (lt)f1.1   null<1>:f     r4.2<0;1,0>:f     0.0:f              
(f1.1)  mov (1|M0)               r4.2<1>:f     -r4.2<0;1,0>:f                  
        sel (1|M0)    (lt)f0.0   r4.2<1>:f     r4.2<0;1,0>:f     448.0:f               {F@1}
        shr (1|M0)               r4.0<1>:ud    r4.2<0;1,0>:ud    0x17:uw              {F@1}
        and (1|M0)               r4.0<1>:ud    r4.0<0;1,0>:ud    0xFF:uw              {I@1}
        sel (1|M0)    (ge)f0.0   r4.0<1>:ud    r4.0<0;1,0>:ud    0x79:uw              {I@1}
        shl (1|M0)               r4.0<1>:ud    r4.0<0;1,0>:ud    0x17:uw              {I@1}
        add (1|M0)               r1.2<1>:ud    -r4.0<0;1,0>:ud   0x80800000:ud              {I@1}
        mul (1|M0)               r1.3<1>:f     r4.2<0;1,0>:f     r1.2<0;1,0>:f    {I@1}
        mov (1|M0)               r4.1<1>:d     r1.3<0;1,0>:f                    {F@1}
        mov (1|M0)               r13.7<1>:f    r4.1<0;1,0>:d                    {I@1}
        mad (1|M0)               r4.2<1>:f     -r13.7<0;0>:f     r1.2<0;0>:f       r4.2<0>:f        {F@1}
        cmp (1|M0)    (gt)f0.1   null<1>:f     r4.2<0;1,0>:f     0.5:f               {F@1}
(W)     and (1|M0)               f0.0<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(f0.0.any16h) goto (16|M0)                   L13592                  L13592                
L13504:
        cmp (1|M0)    (lt)f0.0   null<1>:f     r4.2<0;1,0>:f     0.5:f               {A@1}
        and (1|M0)               r4.1<1>:d     r4.1<0;1,0>:d     1:w               {Compacted}
        add (1|M0)               r1.2<1>:f     r13.7<0;1,0>:f    1.0:f              
(~f0.0) cmp (1|M0)    (eq)f0.0   null<1>:d     r4.1<0;1,0>:d     0:w               {A@1}
(~f0.0) mov (1|M0)               r13.7<1>:f    r1.2<0;1,0>:f                    {F@1}
        goto (16|M0)                         L13592                  L13624                
L13592:
        join (16|M0)                         L13624                                
L13608:
        add (1|M0)               r13.7<1>:f    r13.7<0;1,0>:f    1.0:f               {F@1}
L13624:
        join (16|M0)                         L13688                                
L13640:
        add (1|M0)               r4.0<1>:ud    r4.0<0;1,0>:ud    0xFE800000:ud             
        mul (1|M0)               r13.7<1>:f    r13.7<0;1,0>:f    r4.0<0;1,0>:f    {A@1}
(f1.1)  mov (1|M0)               r13.7<1>:f    -r13.7<0;1,0>:f                  {F@1}
L13688:
        join (16|M0)                         L16152                                
L13704:
        mov (1|M0)               r13.1<1>:f    r14.0<0;1,0>:f                   {Compacted}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r12.2         L24032                                 {A@1}
L13760:
        rnde (1|M0)              r15.4<1>:f    r15.4<0;1,0>:f                  
        mov (1|M0)               r13.0<1>:f    r13.7<0;1,0>:f                   {Compacted,F@3}
        mov (1|M0)               r13.1<1>:f    r14.0<0;1,0>:f                   {Compacted}
        mov (1|M0)               r14.7<1>:d    r15.4<0;1,0>:f                   {F@3}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r12.2         L24032                                 {A@1}
L13856:
        rnde (1|M0)              r15.4<1>:f    r15.4<0;1,0>:f                   {I@2}
        sel (1|M0)    (ge)f0.0   r14.7<1>:d    r14.7<0;1,0>:d    -127:w              
        mov (1|M0)               r1.2<1>:d     r15.4<0;1,0>:f                   {F@1}
        or (1|M0)                r12.10<1>:w   r12.8<0;1,0>:w    8:w              
        sel (1|M0)    (ge)f0.0   r1.2<1>:d     r1.2<0;1,0>:d     -127:w               {I@2}
        sel (1|M0)    (lt)f0.0   r14.7<1>:d    r14.7<0;1,0>:d    127:w              
        sel (1|M0)    (lt)f0.0   r1.2<1>:d     r1.2<0;1,0>:d     127:w               {I@2}
        add (1|M0)               a0.0<1>:uw    r12.8<0;1,0>:uw   0x200:uw              {A@1}
(W)     and (1|M0)               f0.1<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
        mov (1|M0)               r[a0.0]<2>:b  r14.28<0;1,0>:b                  {I@4}
        add (1|M0)               a0.0<1>:uw    r12.10<0;1,0>:uw  0x200:uw              {A@1}
        mov (1|M0)               r[a0.0]<2>:b  r1.8<0;1,0>:b                    {I@5}
        add (1|M0)               a0.0<1>:uw    r12.3<0;1,0>:uw   0xB60:uw              {A@1}
        mov (1|M0)               r4.2<1>:f     r[a0.0]<0;1,0>:f                
(~f0.1.any16h) goto (16|M0)                  L14336                  L14336                 {A@1}
L14096:
        mov (1|M0)               r1.4<2>:hf    r[a0.0]<0;1,0>:f                 {I@3}
        cmp (1|M0)    (lt)f0.0   null<1>:f     r[a0.0]<0;1,0>:f  -4.001953e+00:f               {A@1}
        mov (1|M0)               r1.3<1>:f     r1.4<0;1,0>:hf                   {A@1}
        mov (1|M0)               r2.1<1>:ud    0xBD650000:ud                             
        sel (1|M0)    (lt)f0.0   r1.3<1>:f     r1.3<0;1,0>:f     4.0:f               {F@1}
        mov (1|M0)               r3.5<1>:ud    0x3EE50000:ud                             
(~f0.0) sel (1|M0)               r2.0<1>:f     r1.3<0;1,0>:f     -4.0:f               {F@1}
        mov (1|M0)               r6.0<1>:ud    0x3F650000:ud                             
        mad (1|M0)               r2.1<1>:f     r3.5<0;0>:f       r2.1<0;0>:f       (abs)r2.0<0>:f   {A@1}
        mov (1|M0)               r4.2<2>:hf    r2.1<0;1,0>:f                    {F@1}
        mov (1|M0)               r5.5<1>:f     r4.2<0;1,0>:hf                   {F@1}
        mad (1|M0)               r2.0<1>:f     r6.0<0;0>:f       r5.5<0;0>:f       r2.0<0>:f        {A@1}
        mov (1|M0)               r7.0<2>:hf    r2.0<0;1,0>:f                    {F@1}
        mul (1|M0)               r1.4<1>:hf    r1.4<0;1,0>:hf    r7.0<0;1,0>:hf   {F@1}
        mov (1|M0)               r4.2<1>:f     r1.4<0;1,0>:hf                   {F@1}
L14336:
        join (16|M0)                         L16152                                
L14352:
(W)     and (1|M0)               f0.0<1>:uw    r77.9<0;1,0>:uw   0x1:uw             
(f0.0.any16h) goto (16|M0)                   L14464                  L14464                
L14384:
(W)     mov (1|M0)               f0.0<1>:uw    r77.8<0;1,0>:uw                 
        mov (1|M0)               r1.4<2>:hf    r4.2<0;1,0>:f                    {F@1}
        mov (1|M0)               r13.0<1>:f    r1.4<0;1,0>:hf                   {F@1}
(~f0.0) mov (1|M0)               r13.0<1>:f    r4.2<0;1,0>:f                   
        goto (16|M0)                         L14464                  L14872                
L14464:
        join (16|M0)                         L14872                                
L14480:
        cmp (1|M0)    (lt)f0.1   null<1>:f     r4.2<0;1,0>:f     0.0:f              
(f0.1)  mov (1|M0)               r4.2<1>:f     -r4.2<0;1,0>:f                  
        sel (1|M0)    (lt)f0.0   r4.2<1>:f     r4.2<0;1,0>:f     448.0:f               {F@1}
        shr (1|M0)               r4.0<1>:ud    r4.2<0;1,0>:ud    0x17:uw              {F@1}
        and (1|M0)               r4.0<1>:ud    r4.0<0;1,0>:ud    0xFF:uw              {I@1}
        sel (1|M0)    (ge)f0.0   r4.0<1>:ud    r4.0<0;1,0>:ud    0x79:uw              {I@1}
        shl (1|M0)               r4.0<1>:ud    r4.0<0;1,0>:ud    0x17:uw              {I@1}
        add (1|M0)               r1.2<1>:ud    -r4.0<0;1,0>:ud   0x80800000:ud              {I@1}
        mul (1|M0)               r1.3<1>:f     r4.2<0;1,0>:f     r1.2<0;1,0>:f    {I@1}
        mov (1|M0)               r4.1<1>:d     r1.3<0;1,0>:f                    {F@1}
        mov (1|M0)               r13.0<1>:f    r4.1<0;1,0>:d                    {Compacted,I@1}
        mad (1|M0)               r4.2<1>:f     -r13.0<0;0>:f     r1.2<0;0>:f       r4.2<0>:f        {F@1}
        cmp (1|M0)    (gt)f1.1   null<1>:f     r4.2<0;1,0>:f     0.5:f               {F@1}
(W)     and (1|M0)               f1.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw              {F@1}
(f1.1.any16h) goto (16|M0)                   L14792                  L14792                
L14712:
        cmp (1|M0)    (lt)f1.1   null<1>:f     r4.2<0;1,0>:f     0.5:f               {A@1}
        and (1|M0)               r4.1<1>:d     r4.1<0;1,0>:d     1:w               {Compacted}
        add (1|M0)               r1.2<1>:f     r13.0<0;1,0>:f    1.0:f               {Compacted}
(~f1.1) cmp (1|M0)    (eq)f1.1   null<1>:d     r4.1<0;1,0>:d     0:w               {A@1}
(~f1.1) mov (1|M0)               r13.0<1>:f    r1.2<0;1,0>:f                    {F@1}
        goto (16|M0)                         L14792                  L14816                
L14792:
        join (16|M0)                         L14816                                
L14808:
        add (1|M0)               r13.0<1>:f    r13.0<0;1,0>:f    1.0:f               {Compacted,F@1}
L14816:
        join (16|M0)                         L14872                                
L14832:
        add (1|M0)               r4.0<1>:ud    r4.0<0;1,0>:ud    0xFE800000:ud             
        mul (1|M0)               r13.0<1>:f    r13.0<0;1,0>:f    r4.0<0;1,0>:f    {Compacted,A@1}
(f0.1)  mov (1|M0)               r13.0<1>:f    -r13.0<0;1,0>:f                  {F@1}
L14872:
        join (16|M0)                         L16152                                
L14888:
        add (1|M0)               a0.0<1>:uw    r12.3<0;1,0>:uw   0xB40:uw              {A@1}
(W)     and (1|M0)               f0.0<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
        mov (1|M0)               r4.2<1>:f     r[a0.0]<0;1,0>:f                
(~f0.0.any16h) goto (16|M0)                  L15192                  L15192                 {A@1}
L14952:
        mov (1|M0)               r1.4<2>:hf    r[a0.0]<0;1,0>:f                
        cmp (1|M0)    (lt)f0.0   null<1>:f     r[a0.0]<0;1,0>:f  -4.001953e+00:f               {A@1}
        mov (1|M0)               r1.3<1>:f     r1.4<0;1,0>:hf                   {A@1}
        mov (1|M0)               r2.1<1>:ud    0xBD650000:ud                             
        sel (1|M0)    (lt)f0.0   r1.3<1>:f     r1.3<0;1,0>:f     4.0:f               {F@1}
        mov (1|M0)               r3.5<1>:ud    0x3EE50000:ud                             
(~f0.0) sel (1|M0)               r2.0<1>:f     r1.3<0;1,0>:f     -4.0:f               {F@1}
        mov (1|M0)               r6.0<1>:ud    0x3F650000:ud                             
        mad (1|M0)               r2.1<1>:f     r3.5<0;0>:f       r2.1<0;0>:f       (abs)r2.0<0>:f   {A@1}
        mov (1|M0)               r4.2<2>:hf    r2.1<0;1,0>:f                    {F@1}
        mov (1|M0)               r5.5<1>:f     r4.2<0;1,0>:hf                   {F@1}
        mad (1|M0)               r2.0<1>:f     r6.0<0;0>:f       r5.5<0;0>:f       r2.0<0>:f        {A@1}
        mov (1|M0)               r7.0<2>:hf    r2.0<0;1,0>:f                    {F@1}
        mul (1|M0)               r1.4<1>:hf    r1.4<0;1,0>:hf    r7.0<0;1,0>:hf   {F@1}
        mov (1|M0)               r4.2<1>:f     r1.4<0;1,0>:hf                   {F@1}
L15192:
        join (16|M0)                         L16152                                
L15208:
(W)     and (1|M0)               f1.1<1>:uw    r77.9<0;1,0>:uw   0x1:uw             
(f1.1.any16h) goto (16|M0)                   L15320                  L15320                
L15240:
(W)     mov (1|M0)               f1.1<1>:uw    r77.8<0;1,0>:uw                 
        mov (1|M0)               r1.4<2>:hf    r4.2<0;1,0>:f                    {F@1}
        mov (1|M0)               r13.7<1>:f    r1.4<0;1,0>:hf                   {F@1}
(~f1.1) mov (1|M0)               r13.7<1>:f    r4.2<0;1,0>:f                   
        goto (16|M0)                         L15320                  L15760                
L15320:
        join (16|M0)                         L15760                                
L15336:
        cmp (1|M0)    (lt)f0.0   null<1>:f     r4.2<0;1,0>:f     0.0:f              
(f0.0)  mov (1|M0)               r4.2<1>:f     -r4.2<0;1,0>:f                  
        sel (1|M0)    (lt)f0.0   r4.2<1>:f     r4.2<0;1,0>:f     448.0:f               {F@1}
        shr (1|M0)               r4.0<1>:ud    r4.2<0;1,0>:ud    0x17:uw              {F@1}
        and (1|M0)               r4.0<1>:ud    r4.0<0;1,0>:ud    0xFF:uw              {I@1}
        sel (1|M0)    (ge)f0.0   r4.0<1>:ud    r4.0<0;1,0>:ud    0x79:uw              {I@1}
        shl (1|M0)               r4.0<1>:ud    r4.0<0;1,0>:ud    0x17:uw              {I@1}
        add (1|M0)               r1.2<1>:ud    -r4.0<0;1,0>:ud   0x80800000:ud              {I@1}
        mul (1|M0)               r1.3<1>:f     r4.2<0;1,0>:f     r1.2<0;1,0>:f    {I@1}
        mov (1|M0)               r4.1<1>:d     r1.3<0;1,0>:f                    {F@1}
        mov (1|M0)               r13.7<1>:f    r4.1<0;1,0>:d                    {I@1}
        mad (1|M0)               r4.2<1>:f     -r13.7<0;0>:f     r1.2<0;0>:f       r4.2<0>:f        {F@1}
        cmp (1|M0)    (gt)f1.1   null<1>:f     r4.2<0;1,0>:f     0.5:f               {F@1}
(W)     and (1|M0)               f0.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(f0.1.any16h) goto (16|M0)                   L15664                  L15664                
L15576:
        cmp (1|M0)    (lt)f0.1   null<1>:f     r4.2<0;1,0>:f     0.5:f               {A@1}
        and (1|M0)               r4.1<1>:d     r4.1<0;1,0>:d     1:w               {Compacted}
        add (1|M0)               r1.2<1>:f     r13.7<0;1,0>:f    1.0:f              
(~f0.1) cmp (1|M0)    (eq)f0.1   null<1>:d     r4.1<0;1,0>:d     0:w               {A@1}
(~f0.1) mov (1|M0)               r13.7<1>:f    r1.2<0;1,0>:f                    {F@1}
        goto (16|M0)                         L15664                  L15696                
L15664:
        join (16|M0)                         L15696                                
L15680:
        add (1|M0)               r13.7<1>:f    r13.7<0;1,0>:f    1.0:f               {F@1}
L15696:
        join (16|M0)                         L15760                                
L15712:
        add (1|M0)               r4.0<1>:ud    r4.0<0;1,0>:ud    0xFE800000:ud             
        mul (1|M0)               r13.7<1>:f    r13.7<0;1,0>:f    r4.0<0;1,0>:f    {A@1}
(f0.0)  mov (1|M0)               r13.7<1>:f    -r13.7<0;1,0>:f                  {F@1}
L15760:
        join (16|M0)                         L16152                                
L15776:
        mov (1|M0)               r13.1<1>:f    r12.0<0;1,0>:f                   {Compacted}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r12.2         L24032                                 {A@1}
L15832:
        rnde (1|M0)              r15.4<1>:f    r15.4<0;1,0>:f                  
        mov (1|M0)               r13.0<1>:f    r13.7<0;1,0>:f                   {Compacted,F@3}
        mov (1|M0)               r13.1<1>:f    r12.0<0;1,0>:f                   {Compacted}
        mov (1|M0)               r14.7<1>:d    r15.4<0;1,0>:f                   {F@3}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r12.2         L24032                                 {A@1}
L15928:
        add (1|M0)               a0.0<1>:uw    r12.8<0;1,0>:uw   0x1E0:uw              {A@1}
        add (1|M0)               r12.4<1>:d    r12.4<0;1,0>:d    1:w              
        rnde (1|M0)              r15.4<1>:f    r15.4<0;1,0>:f                   {I@4}
        cmp (1|M0)    (eq)f0.1   null<1>:d     r12.4<0;1,0>:d    8:w               {I@1}
        mov (1|M0)               r1.2<1>:d     r15.4<0;1,0>:f                   {F@1}
        sel (1|M0)    (ge)f0.0   r14.7<1>:d    r14.7<0;1,0>:d    -127:w              
        sel (1|M0)    (ge)f0.0   r1.2<1>:d     r1.2<0;1,0>:d     -127:w               {I@2}
(W)     and (1|M0)               f1.1<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
        sel (1|M0)    (lt)f0.0   r14.7<1>:d    r14.7<0;1,0>:d    127:w               {I@3}
        sel (1|M0)    (lt)f0.0   r1.2<1>:d     r1.2<0;1,0>:d     127:w               {I@3}
        mov (1|M0)               r[a0.0]<2>:b  r14.28<0;1,0>:b                  {I@2}
        add (1|M0)               a0.0<1>:uw    r12.10<0;1,0>:uw  0x1E0:uw              {A@1}
        mov (1|M0)               r[a0.0]<2>:b  r1.8<0;1,0>:b                    {I@3}
(~f1.1.any16h) goto.b (16|M0)                L16152                  L11944                
L16152:
        join (16|M0)                         L16680                                
L16168:
(W)     and (1|M0)               f0.1<1>:uw    r12.2<0;1,0>:uw   0x1:uw             
(~f0.1.any16h) goto (16|M0)                  L16408                  L16408                
L16200:
        mov (1|M0)               r1.2<1>:d     r13.3<0;1,0>:d                  
        asr (1|M0)               r1.3<1>:d     r13.3<0;1,0>:d    31:w               {Compacted}
        mul (1|M0)               acc0.0<1>:ud  r1.2<0;1,0>:ud    r13.10<0;1,0>:uw {I@2}
        mach (1|M0)              r7.0<1>:ud    r1.2<0;1,0>:ud    r13.5<0;1,0>:ud  {AccWrEn}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r1.2<0;1,0>:d     r13.12<0;1,0>:uw
        mach (1|M0)              r2.0<1>:d     r1.2<0;1,0>:d     r13.6<0;1,0>:d  
(W)     mul (1|M0)               acc0.0<1>:d   r1.3<0;1,0>:d     r13.10<0;1,0>:uw {I@6}
        mach (1|M0)              r8.0<1>:d     r1.3<0;1,0>:d     r13.5<0;1,0>:d  
        addc (1|M0)              r10.0<1>:ud   r14.3<0;1,0>:ud   r6.0<0;1,0>:ud   {AccWrEn,I@5}
        add3 (1|M0)              r9.1<1>:d     r8.0<0;0>:d       r7.0<0;0>:d       r2.0<0>:d        {I@2}
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r12.0<1>:f    r10.0<0;1,0>:f                   {Compacted,I@3}
        add3 (1|M0)              r12.1<1>:d    r11.0<0;0>:d      r14.4<0;0>:d      r9.1<0>:d        {I@1}
        send.ugm (1|M0)          null     r12     r16:1   0x0            0x02009784           {A@1,$13} // wr:1+1, rd:0; store.ugm.d64x2t.a64
L16408:
        join (16|M0)                         L16680                                
L16424:
(W)     and (1|M0)               f0.0<1>:uw    r14.12<0;1,0>:uw  0x1:uw             
(~f0.0.any16h) goto (16|M0)                  L16680                  L16680                
L16456:
        mov (1|M0)               r1.2<1>:f     r13.2<0;1,0>:f                  
        asr (1|M0)               r1.3<1>:d     r13.2<0;1,0>:d    31:w              
        mul (1|M0)               acc0.0<1>:ud  r1.2<0;1,0>:ud    r13.10<0;1,0>:uw {F@1}
        mach (1|M0)              r7.0<1>:ud    r1.2<0;1,0>:ud    r13.5<0;1,0>:ud  {AccWrEn}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r1.2<0;1,0>:d     r13.12<0;1,0>:uw
        mach (1|M0)              r2.0<1>:d     r1.2<0;1,0>:d     r13.6<0;1,0>:d  
(W)     mul (1|M0)               acc0.0<1>:d   r1.3<0;1,0>:d     r13.10<0;1,0>:uw {I@6}
        mach (1|M0)              r8.0<1>:d     r1.3<0;1,0>:d     r13.5<0;1,0>:d  
        addc (1|M0)              r10.0<1>:ud   r14.3<0;1,0>:ud   r6.0<0;1,0>:ud   {AccWrEn,I@5}
        add3 (1|M0)              r9.1<1>:d     r8.0<0;0>:d       r7.0<0;0>:d       r2.0<0>:d        {I@2}
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        sync.nop                             null                             {Compacted,$13.src}
        mov (1|M0)               r12.0<1>:f    r10.0<0;1,0>:f                   {Compacted,I@3}
        add3 (1|M0)              r12.1<1>:d    r11.0<0;0>:d      r14.4<0;0>:d      r9.1<0>:d        {I@1}
        send.ugm (1|M0)          null     r12     r15:1   0x0            0x02009784           {A@1,$14} // wr:1+1, rd:0; store.ugm.d64x2t.a64
L16680:
        join (16|M0)                         L16776                                
L16696:
        add (1|M0)               r13.4<1>:d    r13.4<0;1,0>:d    1:w              
        cmp (1|M0)    (eq)f0.0   null<1>:d     r13.4<0;1,0>:d    8:w               {I@1}
(W)     and (1|M0)               f1.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
(f1.1.any16h) goto (16|M0)                   L16776                  L23368                
L16760:
        goto.b (16|M0)                       L16776                  L10240                
L16776:
        join (16|M0)                         L23368                                
L16792:
        mul (1|M0)               acc0.0<1>:ud  r77.5<0;1,0>:ud   r5.4<0;1,0>:uw  
        mach (1|M0)              r7.0<1>:ud    r77.5<0;1,0>:ud   r5.2<0;1,0>:ud   {AccWrEn,$2.src}
        shl (1|M0)               r9.2<1>:d     r15.2<0;1,0>:d    1:w               {$3.src}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r77.5<0;1,0>:d    r5.6<0;1,0>:uw  
        mach (1|M0)              r2.0<1>:d     r77.5<0;1,0>:d    r5.3<0;1,0>:d   
(W)     mul (1|M0)               acc0.0<1>:d   r77.6<0;1,0>:d    r5.4<0;1,0>:uw  
        sync.nop                             null                             {Compacted,$10.src}
        shl (1|M0)               r3.5<1>:d     r15.3<0;1,0>:d    1:w               {$5.src}
        shr (1|M0)               r4.1<1>:ud    r15.2<0;1,0>:ud   0x1F:uw             
        mach (1|M0)              r8.0<1>:d     r77.6<0;1,0>:d    r5.2<0;1,0>:d   
        sync.allrd                           ($4,$11,$12)                
        addc (1|M0)              r10.0<1>:ud   r5.0<0;1,0>:ud    r9.2<0;1,0>:ud   {AccWrEn,I@7}
        or (1|M0)                r9.3<1>:d     r3.5<0;1,0>:d     r4.1<0;1,0>:d    {I@3}
        add3 (1|M0)              r1.3<1>:d     r8.0<0;0>:d       r7.0<0;0>:d       r2.0<0>:d        {I@3}
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (4|M0)               r8.0<1>:w     0x64206420:v                              
        shr (1|M0)               r1.4<1>:ud    r6.0<0;1,0>:ud    0x1:uw             
        shl (1|M0)               r1.5<1>:d     r1.3<0;1,0>:d     31:w               {I@4}
        add3 (1|M0)              r10.2<1>:d    r11.0<0;0>:d      r5.1<0;0>:d       r9.3<0>:d        {I@4}
        mov (4|M0)               r11.0<4>:uw   r8.0<1;1,0>:uw                   {I@4}
        or (1|M0)                r9.0<1>:d     r1.4<0;1,0>:d     r1.5<0;1,0>:d    {I@3}
        mov (4|M0)               r88.0<2>:d    r11.0<4;1,0>:w                   {I@2}
        shl (1|M0)               r1.2<1>:d     r9.0<0;1,0>:d     1:w               {Compacted,I@2}
        asr (4|M0)               r88.1<2>:d    r88.0<2;1,0>:d    31:w               {I@2}
        shr (1|M0)               r9.1<1>:ud    r1.3<0;1,0>:ud    0x1:uw             
        addc (1|M0)              r6.0<1>:ud    r10.0<0;1,0>:ud   r1.2<0;1,0>:ud   {AccWrEn,I@3}
        sync.allrd                           ($6,$13,$14)                
        mov (4|M0)               r12.0<2>:ud   r88.0<2;1,0>:ud                  {I@3}
        mov (4|M0)               r12.1<2>:ud   r88.1<2;1,0>:ud                 
        shr (1|M0)               r2.1<1>:ud    r9.0<0;1,0>:ud    0x1F:uw             
        shl (1|M0)               r2.0<1>:d     r9.1<0;1,0>:d     1:w               {Compacted,I@5}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (4|M0)              r9.0<1>:ud    r12.0<2;1,0>:ud   0x8:ud              {AccWrEn,I@4}
        mov (1|M0)               r77.5<1>:d    r6.0<0;1,0>:d                   
        or (1|M0)                r1.3<1>:d     r2.0<0;1,0>:d     r2.1<0;1,0>:d    {I@4}
        mov (4|M0)               r13.0<1>:ud   acc0.0<1;1,0>:ud                
        addc (4|M0)              r6.0<1>:ud    r12.0<2;1,0>:ud   0x10:ud              {AccWrEn}
        add3 (1|M0)              r77.6<1>:d    r7.0<0;0>:d       r10.2<0;0>:d      r1.3<0>:d        {I@3}
        mov (4|M0)               r7.0<1>:ud    acc0.0<1;1,0>:ud                
        addc (4|M0)              r8.0<1>:ud    r12.0<2;1,0>:ud   0x18:ud              {AccWrEn}
        mov (1|M0)               r23.0<1>:d    r5.4<0;1,0>:d                   
        mov (4|M0)               r10.0<1>:ud   acc0.0<1;1,0>:ud                
        mov (1|M0)               r23.1<1>:d    0:w                              
        mov (1|M0)               r77.0<1>:d    0:w                              
        mov (4|M0)               r89.0<2>:d    r9.0<1;1,0>:d                   
        mov (4|M0)               r86.0<2>:d    r6.0<1;1,0>:d                    {I@7}
        mov (4|M0)               r87.0<2>:d    r8.0<1;1,0>:d                    {I@7}
        add3 (4|M0)              r89.1<2>:d    r13.0<1;0>:d      r12.1<4;2>:d      0:w              
        add3 (4|M0)              r86.1<2>:d    r7.0<1;0>:d       r12.1<4;2>:d      0:w              
        add3 (4|M0)              r87.1<2>:d    r10.0<1;0>:d      r12.1<4;2>:d      0:w               {I@7}
L17560:
        or (1|M0)                r4.0<1>:d     r77.0<0;1,0>:d    r77.1<0;1,0>:d   {Compacted,I@7}
        cmp (1|M0)    (lt)f1.1   null<1>:d     r4.0<0;1,0>:d     r4.5<0;1,0>:d    {I@1}
        or (1|M0)                r23.2<1>:d    r4.0<0;1,0>:d     8:w               {Compacted}
(W)     and (1|M0)               f0.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(~f0.1.any16h) goto (16|M0)                  L20424                  L20424                
L17624:
        mov (1|M0)               r23.3<1>:d    r4.0<0;1,0>:d                   
        asr (1|M0)               r23.4<1>:d    r4.0<0;1,0>:d     31:w               {Compacted}
        shl (1|M0)               r1.4<1>:d     r23.3<0;1,0>:d    2:w               {I@2}
        shr (1|M0)               r1.3<1>:ud    r23.3<0;1,0>:ud   0x1E:uw             
        shl (1|M0)               r1.2<1>:d     r23.4<0;1,0>:d    2:w               {I@3}
        addc (1|M0)              r2.0<1>:ud    r77.2<0;1,0>:ud   r1.4<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r8.0<1>:f     r2.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r8.1<1>:d     r6.0<0;0>:d       r77.3<0;0>:d      r1.5<0>:d        {I@1}
        shl (1|M0)               r3.10<1>:w    r77.0<0;1,0>:w    5:w              
        send.ugm (1|M0)          r10      r8      null:0  0x0            0x04100580           {A@1,$4} // wr:2+0, rd:1; load.ugm.d32.a64
        add (1|M0)               a0.0<1>:uw    r3.10<0;1,0>:uw   0x560:uw              {A@1}
        mov (1|M0)               r10.2<1>:d    0:w                               {$4.dst}
        mov (8|M0)               r7.0<1>:ud    r[a0.0]<1;1,0>:ud               
        add (1|M0)               a0.0<1>:uw    r3.10<0;1,0>:uw   0x660:uw              {A@1}
        mov (8|M0)               r100.0<1>:f   r7.0<1;1,0>:d                    {Compacted,I@2}
        mov (8|M0)               r9.0<1>:ud    r[a0.0]<1;1,0>:ud               
        mov (8|M0)               r98.0<1>:f    r9.0<1;1,0>:d                    {Compacted,A@1}
        mul (8|M0)               r100.0<1>:f   r10.0<0;1,0>:f    r100.0<1;1,0>:f  {Compacted,F@2}
        mul (8|M0)               r100.0<1>:f   r100.0<1;1,0>:f   r79.0<1;1,0>:f   {Compacted,F@1}
L17904:
        shl (1|M0)               r10.2<1>:w    r10.4<0;1,0>:w    2:w              
(W)     and (1|M0)               f0.0<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
        add (1|M0)               a0.0<1>:uw    r10.2<0;1,0>:uw   0xC80:uw              {A@1}
        mov (1|M0)               r4.3<1>:f     r[a0.0]<0;1,0>:f                 {F@1}
(~f0.0.any16h) goto (16|M0)                  L18224                  L18224                 {A@1}
L17984:
        mov (1|M0)               r1.4<2>:hf    r[a0.0]<0;1,0>:f                
        cmp (1|M0)    (lt)f0.1   null<1>:f     r[a0.0]<0;1,0>:f  -4.001953e+00:f               {A@1}
        mov (1|M0)               r1.3<1>:f     r1.4<0;1,0>:hf                   {A@1}
        mov (1|M0)               r2.1<1>:ud    0xBD650000:ud                             
        sel (1|M0)    (lt)f0.0   r1.3<1>:f     r1.3<0;1,0>:f     4.0:f               {F@1}
        mov (1|M0)               r3.5<1>:ud    0x3EE50000:ud                             
(~f0.1) sel (1|M0)               r2.0<1>:f     r1.3<0;1,0>:f     -4.0:f               {F@1}
        mov (1|M0)               r6.0<1>:ud    0x3F650000:ud                             
        mad (1|M0)               r2.1<1>:f     r3.5<0;0>:f       r2.1<0;0>:f       (abs)r2.0<0>:f   {A@1}
        mov (1|M0)               r4.2<2>:hf    r2.1<0;1,0>:f                    {F@1}
        mov (1|M0)               r5.5<1>:f     r4.2<0;1,0>:hf                   {F@1}
        mad (1|M0)               r2.0<1>:f     r6.0<0;0>:f       r5.5<0;0>:f       r2.0<0>:f        {A@1}
        mov (1|M0)               r7.0<2>:hf    r2.0<0;1,0>:f                    {F@1}
        mul (1|M0)               r1.4<1>:hf    r1.4<0;1,0>:hf    r7.0<0;1,0>:hf   {F@1}
        mov (1|M0)               r4.3<1>:f     r1.4<0;1,0>:hf                   {F@1}
L18224:
        join (16|M0)                         L18880                                
L18240:
(W)     and (1|M0)               f1.1<1>:uw    r77.9<0;1,0>:uw   0x1:uw             
(f1.1.any16h) goto (16|M0)                   L18352                  L18352                
L18272:
(W)     mov (1|M0)               f0.1<1>:uw    r77.8<0;1,0>:uw                 
        mov (1|M0)               r1.4<2>:hf    r4.3<0;1,0>:f                    {F@1}
        mov (1|M0)               r4.0<1>:f     r1.4<0;1,0>:hf                   {F@1}
(~f0.1) mov (1|M0)               r4.0<1>:f     r4.3<0;1,0>:f                   
        goto (16|M0)                         L18352                  L18768                
L18352:
        join (16|M0)                         L18768                                
L18368:
        cmp (1|M0)    (lt)f1.1   null<1>:f     r4.3<0;1,0>:f     0.0:f               {A@4}
(f1.1)  mov (1|M0)               r4.3<1>:f     -r4.3<0;1,0>:f                  
        sel (1|M0)    (lt)f0.0   r4.3<1>:f     r4.3<0;1,0>:f     448.0:f               {F@1}
        shr (1|M0)               r4.1<1>:ud    r4.3<0;1,0>:ud    0x17:uw              {F@1}
        and (1|M0)               r4.1<1>:ud    r4.1<0;1,0>:ud    0xFF:uw              {I@1}
        sel (1|M0)    (ge)f0.0   r4.1<1>:ud    r4.1<0;1,0>:ud    0x79:uw              {I@1}
        shl (1|M0)               r4.1<1>:ud    r4.1<0;1,0>:ud    0x17:uw              {I@1}
        add (1|M0)               r1.2<1>:ud    -r4.1<0;1,0>:ud   0x80800000:ud              {I@1}
        mul (1|M0)               r1.3<1>:f     r4.3<0;1,0>:f     r1.2<0;1,0>:f    {I@1}
        mov (1|M0)               r4.2<1>:d     r1.3<0;1,0>:f                    {F@1}
        mov (1|M0)               r4.0<1>:f     r4.2<0;1,0>:d                    {Compacted,I@1}
        mad (1|M0)               r4.3<1>:f     -r4.0<0;0>:f      r1.2<0;0>:f       r4.3<0>:f        {F@1}
        cmp (1|M0)    (gt)f0.0   null<1>:f     r4.3<0;1,0>:f     0.5:f               {F@1}
(W)     and (1|M0)               f0.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
(f0.1.any16h) goto (16|M0)                   L18688                  L18688                
L18600:
        cmp (1|M0)    (lt)f0.0   null<1>:f     r4.3<0;1,0>:f     0.5:f               {I@2}
        and (1|M0)               r4.2<1>:d     r4.2<0;1,0>:d     1:w              
        add (1|M0)               r1.2<1>:f     r4.0<0;1,0>:f     1.0:f               {Compacted}
(~f0.0) cmp (1|M0)    (eq)f0.0   null<1>:d     r4.2<0;1,0>:d     0:w               {A@1}
(~f0.0) mov (1|M0)               r4.0<1>:f     r1.2<0;1,0>:f                    {F@1}
        goto (16|M0)                         L18688                  L18712                
L18688:
        join (16|M0)                         L18712                                
L18704:
        add (1|M0)               r4.0<1>:f     r4.0<0;1,0>:f     1.0:f               {Compacted,F@1}
L18712:
        join (16|M0)                         L18768                                
L18728:
        add (1|M0)               r4.1<1>:ud    r4.1<0;1,0>:ud    0xFE800000:ud             
        mul (1|M0)               r4.0<1>:f     r4.0<0;1,0>:f     r4.1<0;1,0>:f    {Compacted,A@1}
(f1.1)  mov (1|M0)               r4.0<1>:f     -r4.0<0;1,0>:f                   {F@1}
L18768:
        join (16|M0)                         L18880                                
L18784:
        add (1|M0)               r10.2<1>:d    r10.2<0;1,0>:d    1:w              
        add (1|M0)               a0.0<1>:uw    r10.2<0;1,0>:uw   0xA80:uw              {A@1}
        cmp (1|M0)    (eq)f0.1   null<1>:d     r10.2<0;1,0>:d    8:w               {I@2}
        mov (1|M0)               r[a0.0]<1>:f  r4.0<0;1,0>:f                    {F@1}
(W)     and (1|M0)               f0.0<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(~f0.0.any16h) goto.b (16|M0)                L18880                  L17904                
L18880:
        join (16|M0)                         L20424                                
L18896:
        mul (8|M0)               r98.0<1>:f    r10.0<0;1,0>:f    r98.0<1;1,0>:f   {Compacted}
        mov (1|M0)               r23.6<1>:d    0:w                              
        mul (8|M0)               r98.0<1>:f    r98.0<1;1,0>:f    r78.0<1;1,0>:f   {Compacted,F@1}
L18928:
        shl (1|M0)               r23.10<1>:w   r23.12<0;1,0>:w   2:w               {I@1}
(W)     and (1|M0)               f1.1<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
        add (1|M0)               a0.0<1>:uw    r23.10<0;1,0>:uw  0xC40:uw              {A@1}
        mov (1|M0)               r4.3<1>:f     r[a0.0]<0;1,0>:f                 {F@1}
(~f1.1.any16h) goto (16|M0)                  L19248                  L19248                 {A@1}
L19008:
        mov (1|M0)               r1.4<2>:hf    r[a0.0]<0;1,0>:f                
        cmp (1|M0)    (lt)f0.0   null<1>:f     r[a0.0]<0;1,0>:f  -4.001953e+00:f               {A@1}
        mov (1|M0)               r1.3<1>:f     r1.4<0;1,0>:hf                   {A@1}
        mov (1|M0)               r2.1<1>:ud    0xBD650000:ud                             
        sel (1|M0)    (lt)f0.0   r1.3<1>:f     r1.3<0;1,0>:f     4.0:f               {F@1}
        mov (1|M0)               r3.5<1>:ud    0x3EE50000:ud                             
(~f0.0) sel (1|M0)               r2.0<1>:f     r1.3<0;1,0>:f     -4.0:f               {F@1}
        mov (1|M0)               r6.0<1>:ud    0x3F650000:ud                             
        mad (1|M0)               r2.1<1>:f     r3.5<0;0>:f       r2.1<0;0>:f       (abs)r2.0<0>:f   {A@1}
        mov (1|M0)               r4.2<2>:hf    r2.1<0;1,0>:f                    {F@1}
        mov (1|M0)               r5.5<1>:f     r4.2<0;1,0>:hf                   {F@1}
        mad (1|M0)               r2.0<1>:f     r6.0<0;0>:f       r5.5<0;0>:f       r2.0<0>:f        {A@1}
        mov (1|M0)               r7.0<2>:hf    r2.0<0;1,0>:f                    {F@1}
        mul (1|M0)               r1.4<1>:hf    r1.4<0;1,0>:hf    r7.0<0;1,0>:hf   {F@1}
        mov (1|M0)               r4.3<1>:f     r1.4<0;1,0>:hf                   {F@1}
L19248:
        join (16|M0)                         L19920                                
L19264:
(W)     and (1|M0)               f0.1<1>:uw    r77.9<0;1,0>:uw   0x1:uw             
(f0.1.any16h) goto (16|M0)                   L19376                  L19376                
L19296:
(W)     mov (1|M0)               f0.0<1>:uw    r77.8<0;1,0>:uw                 
        mov (1|M0)               r1.4<2>:hf    r4.3<0;1,0>:f                    {F@1}
        mov (1|M0)               r4.0<1>:f     r1.4<0;1,0>:hf                   {F@1}
(~f0.0) mov (1|M0)               r4.0<1>:f     r4.3<0;1,0>:f                   
        goto (16|M0)                         L19376                  L19792                
L19376:
        join (16|M0)                         L19792                                
L19392:
        cmp (1|M0)    (lt)f0.1   null<1>:f     r4.3<0;1,0>:f     0.0:f               {A@4}
(f0.1)  mov (1|M0)               r4.3<1>:f     -r4.3<0;1,0>:f                  
        sel (1|M0)    (lt)f0.0   r4.3<1>:f     r4.3<0;1,0>:f     448.0:f               {F@1}
        shr (1|M0)               r4.1<1>:ud    r4.3<0;1,0>:ud    0x17:uw              {F@1}
        and (1|M0)               r4.1<1>:ud    r4.1<0;1,0>:ud    0xFF:uw              {I@1}
        sel (1|M0)    (ge)f0.0   r4.1<1>:ud    r4.1<0;1,0>:ud    0x79:uw              {I@1}
        shl (1|M0)               r4.1<1>:ud    r4.1<0;1,0>:ud    0x17:uw              {I@1}
        add (1|M0)               r1.2<1>:ud    -r4.1<0;1,0>:ud   0x80800000:ud              {I@1}
        mul (1|M0)               r1.3<1>:f     r4.3<0;1,0>:f     r1.2<0;1,0>:f    {I@1}
        mov (1|M0)               r4.2<1>:d     r1.3<0;1,0>:f                    {F@1}
        mov (1|M0)               r4.0<1>:f     r4.2<0;1,0>:d                    {Compacted,I@1}
        mad (1|M0)               r4.3<1>:f     -r4.0<0;0>:f      r1.2<0;0>:f       r4.3<0>:f        {F@1}
        cmp (1|M0)    (gt)f1.1   null<1>:f     r4.3<0;1,0>:f     0.5:f               {F@1}
(W)     and (1|M0)               f0.0<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(f0.0.any16h) goto (16|M0)                   L19712                  L19712                
L19624:
        cmp (1|M0)    (lt)f1.1   null<1>:f     r4.3<0;1,0>:f     0.5:f               {I@2}
        and (1|M0)               r4.2<1>:d     r4.2<0;1,0>:d     1:w              
        add (1|M0)               r1.2<1>:f     r4.0<0;1,0>:f     1.0:f               {Compacted}
(~f1.1) cmp (1|M0)    (eq)f1.1   null<1>:d     r4.2<0;1,0>:d     0:w               {A@1}
(~f1.1) mov (1|M0)               r4.0<1>:f     r1.2<0;1,0>:f                    {F@1}
        goto (16|M0)                         L19712                  L19736                
L19712:
        join (16|M0)                         L19736                                
L19728:
        add (1|M0)               r4.0<1>:f     r4.0<0;1,0>:f     1.0:f               {Compacted,F@1}
L19736:
        join (16|M0)                         L19792                                
L19752:
        add (1|M0)               r4.1<1>:ud    r4.1<0;1,0>:ud    0xFE800000:ud             
        mul (1|M0)               r4.0<1>:f     r4.0<0;1,0>:f     r4.1<0;1,0>:f    {Compacted,A@1}
(f0.1)  mov (1|M0)               r4.0<1>:f     -r4.0<0;1,0>:f                   {F@1}
L19792:
        join (16|M0)                         L19920                                
L19808:
        add (1|M0)               r23.6<1>:d    r23.6<0;1,0>:d    1:w              
        or (1|M0)                r1.3<1>:uw    r23.10<0;1,0>:uw  0x20:uw             
        cmp (1|M0)    (eq)f0.1   null<1>:d     r23.6<0;1,0>:d    8:w               {A@1}
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0xA80:uw              {A@1}
        mov (1|M0)               r[a0.0]<1>:f  r4.0<0;1,0>:f                   
(W)     and (1|M0)               f1.1<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(~f1.1.any16h) goto.b (16|M0)                L19920                  L18928                
L19920:
        join (16|M0)                         L20424                                
L19936:
        mul (1|M0)               acc0.0<1>:ud  r23.3<0;1,0>:ud   r23.0<0;1,0>:uw 
        mach (1|M0)              r8.0<1>:ud    r23.3<0;1,0>:ud   r23.0<0;1,0>:ud  {AccWrEn}
        mov (8|M0)               r6.0<1>:hf    r84.0<1;1,0>:f                   {F@1}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r23.3<0;1,0>:d    r23.2<0;1,0>:uw 
        mach (1|M0)              r2.0<1>:d     r23.3<0;1,0>:d    r23.1<0;1,0>:d  
(W)     mul (1|M0)               acc0.0<1>:d   r23.4<0;1,0>:d    r23.0<0;1,0>:uw  {Compacted}
        mach (1|M0)              r9.0<1>:d     r23.4<0;1,0>:d    r23.0<0;1,0>:d   {Compacted}
        shl (1|M0)               r10.0<1>:d    r7.0<0;1,0>:d     1:w               {Compacted,I@5}
        add3 (1|M0)              r1.3<1>:d     r9.0<0;0>:d       r8.0<0;0>:d       r2.0<0>:d        {I@2}
        shr (1|M0)               r4.1<1>:ud    r7.0<0;1,0>:ud    0x1F:uw             
        addc (1|M0)              r11.0<1>:ud   r77.5<0;1,0>:ud   r10.0<0;1,0>:ud  {AccWrEn,I@3}
        shl (1|M0)               r3.5<1>:d     r1.3<0;1,0>:d     1:w               {I@3}
        mov (1|M0)               r12.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        or (1|M0)                r10.1<1>:d    r3.5<0;1,0>:d     r4.1<0;1,0>:d    {I@2}
        mov (1|M0)               r10.2<1>:d    r11.0<0;1,0>:d                  
        add3 (1|M0)              r10.3<1>:d    r12.0<0;0>:d      r77.6<0;0>:d      r10.1<0>:d       {I@2}
        sync.nop                             null                             {Compacted,$8.src}
        mov (8|M0)               r13.0<2>:ud   r10.2<0;1,0>:ud                  {I@2}
        mov (8|M0)               r13.1<2>:ud   r10.3<0;1,0>:ud                  {I@2}
        mov (8|M0)               r7.0<1>:d     r88.1<2;1,0>:d                  
        addc (8|M0)              r15.0<1>:ud   r13.0<2;1,0>:ud   r88.0<2;1,0>:ud  {AccWrEn,Compacted,I@2}
        mov (8|M0)               r12.0<1>:d    r86.1<2;1,0>:d                  
        mov (8|M0)               r9.0<1>:ud    acc0.0<1;1,0>:ud                 {Compacted}
        addc (8|M0)              r20.0<1>:ud   r13.0<2;1,0>:ud   r86.0<2;1,0>:ud  {AccWrEn,Compacted}
        mov (8|M0)               r6.8<1>:hf    r85.0<1;1,0>:f                  
        mov (8|M0)               r11.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        add3 (8|M0)              r8.0<1>:d     r9.0<1;0>:d       r13.1<4;2>:d      r7.0<1>:d        {I@3}
        add3 (8|M0)              r10.0<1>:d    r11.0<1;0>:d      r13.1<4;2>:d      r12.0<1>:d       {I@2}
        sync.nop                             null                             {Compacted,$3.src}
        mov (8|M0)               r16.0<2>:d    r15.0<1;1,0>:d                   {$1.src}
        mov (8|M0)               r18.0<2>:d    r20.0<1;1,0>:d                  
        mov (16|M0)              r21.0<1>:d    r6.0<1;1,0>:uw                   {A@1}
        mov (8|M0)               r16.1<2>:d    r8.0<1;1,0>:d                    {I@5}
        mov (8|M0)               r18.1<2>:d    r10.0<1;1,0>:d                   {I@5}
        send.ugm (16|M0)         null     r16     r21:2   0x0            0x08000B84           {A@1,$1} // wr:4+2, rd:0; store.ugm.d16u32.a64
L20424:
        join (16|M0)                         L23368                                
L20440:
        cmp (1|M0)    (lt)f0.0   null<1>:d     r23.2<0;1,0>:d    r4.5<0;1,0>:d   
(W)     and (1|M0)               f0.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
(~f0.1.any16h) goto (16|M0)                  L23296                  L23296                
L20488:
        mov (1|M0)               r23.3<1>:d    r23.2<0;1,0>:d                  
        asr (1|M0)               r23.4<1>:d    r23.2<0;1,0>:d    31:w              
        shl (1|M0)               r1.4<1>:d     r23.3<0;1,0>:d    2:w               {I@2}
        shr (1|M0)               r1.3<1>:ud    r23.3<0;1,0>:ud   0x1E:uw             
        shl (1|M0)               r1.2<1>:d     r23.4<0;1,0>:d    2:w               {I@3}
        addc (1|M0)              r2.0<1>:ud    r77.2<0;1,0>:ud   r1.4<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r8.0<1>:f     r2.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r8.1<1>:d     r6.0<0;0>:d       r77.3<0;0>:d      r1.5<0>:d        {I@1}
        shl (1|M0)               r3.10<1>:w    r77.0<0;1,0>:w    5:w              
        send.ugm (1|M0)          r10      r8      null:0  0x0            0x04100580           {A@1,$5} // wr:2+0, rd:1; load.ugm.d32.a64
        add (1|M0)               a0.0<1>:uw    r3.10<0;1,0>:uw   0x760:uw              {A@1}
        mov (1|M0)               r10.2<1>:d    0:w                               {$5.dst}
        mov (8|M0)               r7.0<1>:ud    r[a0.0]<1;1,0>:ud               
        add (1|M0)               a0.0<1>:uw    r3.10<0;1,0>:uw   0x860:uw              {A@1}
        mov (8|M0)               r101.0<1>:f   r7.0<1;1,0>:d                    {Compacted,I@2}
        mov (8|M0)               r9.0<1>:ud    r[a0.0]<1;1,0>:ud               
        mov (8|M0)               r99.0<1>:f    r9.0<1;1,0>:d                    {Compacted,A@1}
        mul (8|M0)               r101.0<1>:f   r10.0<0;1,0>:f    r101.0<1;1,0>:f  {Compacted,F@2}
        mul (8|M0)               r101.0<1>:f   r101.0<1;1,0>:f   r79.0<1;1,0>:f   {Compacted,F@1}
L20776:
        shl (1|M0)               r10.2<1>:w    r10.4<0;1,0>:w    2:w              
(W)     and (1|M0)               f0.0<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
        add (1|M0)               a0.0<1>:uw    r10.2<0;1,0>:uw   0xCA0:uw              {A@1}
        mov (1|M0)               r4.3<1>:f     r[a0.0]<0;1,0>:f                 {F@1}
(~f0.0.any16h) goto (16|M0)                  L21096                  L21096                 {A@1}
L20856:
        mov (1|M0)               r1.4<2>:hf    r[a0.0]<0;1,0>:f                
        cmp (1|M0)    (lt)f1.1   null<1>:f     r[a0.0]<0;1,0>:f  -4.001953e+00:f               {A@1}
        mov (1|M0)               r1.3<1>:f     r1.4<0;1,0>:hf                   {A@1}
        mov (1|M0)               r2.1<1>:ud    0xBD650000:ud                             
        sel (1|M0)    (lt)f0.0   r1.3<1>:f     r1.3<0;1,0>:f     4.0:f               {F@1}
        mov (1|M0)               r3.5<1>:ud    0x3EE50000:ud                             
(~f1.1) sel (1|M0)               r2.0<1>:f     r1.3<0;1,0>:f     -4.0:f               {F@1}
        mov (1|M0)               r6.0<1>:ud    0x3F650000:ud                             
        mad (1|M0)               r2.1<1>:f     r3.5<0;0>:f       r2.1<0;0>:f       (abs)r2.0<0>:f   {A@1}
        mov (1|M0)               r4.2<2>:hf    r2.1<0;1,0>:f                    {F@1}
        mov (1|M0)               r5.5<1>:f     r4.2<0;1,0>:hf                   {F@1}
        mad (1|M0)               r2.0<1>:f     r6.0<0;0>:f       r5.5<0;0>:f       r2.0<0>:f        {A@1}
        mov (1|M0)               r7.0<2>:hf    r2.0<0;1,0>:f                    {F@1}
        mul (1|M0)               r1.4<1>:hf    r1.4<0;1,0>:hf    r7.0<0;1,0>:hf   {F@1}
        mov (1|M0)               r4.3<1>:f     r1.4<0;1,0>:hf                   {F@1}
L21096:
        join (16|M0)                         L21752                                
L21112:
(W)     and (1|M0)               f1.1<1>:uw    r77.9<0;1,0>:uw   0x1:uw             
(f1.1.any16h) goto (16|M0)                   L21224                  L21224                
L21144:
(W)     mov (1|M0)               f1.1<1>:uw    r77.8<0;1,0>:uw                 
        mov (1|M0)               r1.4<2>:hf    r4.3<0;1,0>:f                    {F@1}
        mov (1|M0)               r4.0<1>:f     r1.4<0;1,0>:hf                   {F@1}
(~f1.1) mov (1|M0)               r4.0<1>:f     r4.3<0;1,0>:f                   
        goto (16|M0)                         L21224                  L21640                
L21224:
        join (16|M0)                         L21640                                
L21240:
        cmp (1|M0)    (lt)f0.0   null<1>:f     r4.3<0;1,0>:f     0.0:f              
(f0.0)  mov (1|M0)               r4.3<1>:f     -r4.3<0;1,0>:f                  
        sel (1|M0)    (lt)f0.0   r4.3<1>:f     r4.3<0;1,0>:f     448.0:f               {F@1}
        shr (1|M0)               r4.1<1>:ud    r4.3<0;1,0>:ud    0x17:uw              {F@1}
        and (1|M0)               r4.1<1>:ud    r4.1<0;1,0>:ud    0xFF:uw              {I@1}
        sel (1|M0)    (ge)f0.0   r4.1<1>:ud    r4.1<0;1,0>:ud    0x79:uw              {I@1}
        shl (1|M0)               r4.1<1>:ud    r4.1<0;1,0>:ud    0x17:uw              {I@1}
        add (1|M0)               r1.2<1>:ud    -r4.1<0;1,0>:ud   0x80800000:ud              {I@1}
        mul (1|M0)               r1.3<1>:f     r4.3<0;1,0>:f     r1.2<0;1,0>:f    {I@1}
        mov (1|M0)               r4.2<1>:d     r1.3<0;1,0>:f                    {F@1}
        mov (1|M0)               r4.0<1>:f     r4.2<0;1,0>:d                    {Compacted,I@1}
        mad (1|M0)               r4.3<1>:f     -r4.0<0;0>:f      r1.2<0;0>:f       r4.3<0>:f        {F@1}
        cmp (1|M0)    (gt)f0.1   null<1>:f     r4.3<0;1,0>:f     0.5:f               {F@1}
(W)     and (1|M0)               f0.1<1>:uw    f0.1<0;1,0>:uw    0x1:uw              {F@1}
(f0.1.any16h) goto (16|M0)                   L21560                  L21560                
L21472:
        cmp (1|M0)    (lt)f0.1   null<1>:f     r4.3<0;1,0>:f     0.5:f               {A@1}
        and (1|M0)               r4.2<1>:d     r4.2<0;1,0>:d     1:w              
        add (1|M0)               r1.2<1>:f     r4.0<0;1,0>:f     1.0:f               {Compacted}
(~f0.1) cmp (1|M0)    (eq)f0.1   null<1>:d     r4.2<0;1,0>:d     0:w               {A@1}
(~f0.1) mov (1|M0)               r4.0<1>:f     r1.2<0;1,0>:f                    {F@1}
        goto (16|M0)                         L21560                  L21584                
L21560:
        join (16|M0)                         L21584                                
L21576:
        add (1|M0)               r4.0<1>:f     r4.0<0;1,0>:f     1.0:f               {Compacted,F@1}
L21584:
        join (16|M0)                         L21640                                
L21600:
        add (1|M0)               r4.1<1>:ud    r4.1<0;1,0>:ud    0xFE800000:ud             
        mul (1|M0)               r4.0<1>:f     r4.0<0;1,0>:f     r4.1<0;1,0>:f    {Compacted,A@1}
(f0.0)  mov (1|M0)               r4.0<1>:f     -r4.0<0;1,0>:f                   {F@1}
L21640:
        join (16|M0)                         L21752                                
L21656:
        add (1|M0)               r10.2<1>:d    r10.2<0;1,0>:d    1:w              
        add (1|M0)               a0.0<1>:uw    r10.2<0;1,0>:uw   0xA40:uw              {A@1}
        cmp (1|M0)    (eq)f1.1   null<1>:d     r10.2<0;1,0>:d    8:w               {I@2}
        mov (1|M0)               r[a0.0]<1>:f  r4.0<0;1,0>:f                    {F@1}
(W)     and (1|M0)               f0.0<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(~f0.0.any16h) goto.b (16|M0)                L21752                  L20776                
L21752:
        join (16|M0)                         L23296                                
L21768:
        mul (8|M0)               r99.0<1>:f    r10.0<0;1,0>:f    r99.0<1;1,0>:f   {Compacted}
        mov (1|M0)               r23.5<1>:d    0:w                              
        mul (8|M0)               r99.0<1>:f    r99.0<1;1,0>:f    r78.0<1;1,0>:f   {Compacted,F@1}
L21800:
        shl (1|M0)               r23.4<1>:w    r23.10<0;1,0>:w   2:w               {I@1}
(W)     and (1|M0)               f1.1<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
        add (1|M0)               a0.0<1>:uw    r23.4<0;1,0>:uw   0xC60:uw              {A@1}
        mov (1|M0)               r4.3<1>:f     r[a0.0]<0;1,0>:f                 {F@1}
(~f1.1.any16h) goto (16|M0)                  L22120                  L22120                 {A@1}
L21880:
        mov (1|M0)               r1.4<2>:hf    r[a0.0]<0;1,0>:f                
        cmp (1|M0)    (lt)f0.1   null<1>:f     r[a0.0]<0;1,0>:f  -4.001953e+00:f               {A@1}
        mov (1|M0)               r1.3<1>:f     r1.4<0;1,0>:hf                   {A@1}
        mov (1|M0)               r2.1<1>:ud    0xBD650000:ud                             
        sel (1|M0)    (lt)f0.0   r1.3<1>:f     r1.3<0;1,0>:f     4.0:f               {F@1}
        mov (1|M0)               r3.5<1>:ud    0x3EE50000:ud                             
(~f0.1) sel (1|M0)               r2.0<1>:f     r1.3<0;1,0>:f     -4.0:f               {F@1}
        mov (1|M0)               r6.0<1>:ud    0x3F650000:ud                             
        mad (1|M0)               r2.1<1>:f     r3.5<0;0>:f       r2.1<0;0>:f       (abs)r2.0<0>:f   {A@1}
        mov (1|M0)               r4.2<2>:hf    r2.1<0;1,0>:f                    {F@1}
        mov (1|M0)               r5.5<1>:f     r4.2<0;1,0>:hf                   {F@1}
        mad (1|M0)               r2.0<1>:f     r6.0<0;0>:f       r5.5<0;0>:f       r2.0<0>:f        {A@1}
        mov (1|M0)               r7.0<2>:hf    r2.0<0;1,0>:f                    {F@1}
        mul (1|M0)               r1.4<1>:hf    r1.4<0;1,0>:hf    r7.0<0;1,0>:hf   {F@1}
        mov (1|M0)               r4.3<1>:f     r1.4<0;1,0>:hf                   {F@1}
L22120:
        join (16|M0)                         L22792                                
L22136:
(W)     and (1|M0)               f0.1<1>:uw    r77.9<0;1,0>:uw   0x1:uw             
(f0.1.any16h) goto (16|M0)                   L22248                  L22248                
L22168:
(W)     mov (1|M0)               f0.1<1>:uw    r77.8<0;1,0>:uw                 
        mov (1|M0)               r1.4<2>:hf    r4.3<0;1,0>:f                    {F@1}
        mov (1|M0)               r4.0<1>:f     r1.4<0;1,0>:hf                   {F@1}
(~f0.1) mov (1|M0)               r4.0<1>:f     r4.3<0;1,0>:f                   
        goto (16|M0)                         L22248                  L22664                
L22248:
        join (16|M0)                         L22664                                
L22264:
        cmp (1|M0)    (lt)f1.1   null<1>:f     r4.3<0;1,0>:f     0.0:f              
(f1.1)  mov (1|M0)               r4.3<1>:f     -r4.3<0;1,0>:f                  
        sel (1|M0)    (lt)f0.0   r4.3<1>:f     r4.3<0;1,0>:f     448.0:f               {F@1}
        shr (1|M0)               r4.1<1>:ud    r4.3<0;1,0>:ud    0x17:uw              {F@1}
        and (1|M0)               r4.1<1>:ud    r4.1<0;1,0>:ud    0xFF:uw              {I@1}
        sel (1|M0)    (ge)f0.0   r4.1<1>:ud    r4.1<0;1,0>:ud    0x79:uw              {I@1}
        shl (1|M0)               r4.1<1>:ud    r4.1<0;1,0>:ud    0x17:uw              {I@1}
        add (1|M0)               r1.2<1>:ud    -r4.1<0;1,0>:ud   0x80800000:ud              {I@1}
        mul (1|M0)               r1.3<1>:f     r4.3<0;1,0>:f     r1.2<0;1,0>:f    {I@1}
        mov (1|M0)               r4.2<1>:d     r1.3<0;1,0>:f                    {F@1}
        mov (1|M0)               r4.0<1>:f     r4.2<0;1,0>:d                    {Compacted,I@1}
        mad (1|M0)               r4.3<1>:f     -r4.0<0;0>:f      r1.2<0;0>:f       r4.3<0>:f        {F@1}
        cmp (1|M0)    (gt)f0.0   null<1>:f     r4.3<0;1,0>:f     0.5:f               {F@1}
(W)     and (1|M0)               f0.0<1>:uw    f0.0<0;1,0>:uw    0x1:uw              {F@1}
(f0.0.any16h) goto (16|M0)                   L22584                  L22584                
L22496:
        cmp (1|M0)    (lt)f0.0   null<1>:f     r4.3<0;1,0>:f     0.5:f               {A@1}
        and (1|M0)               r4.2<1>:d     r4.2<0;1,0>:d     1:w              
        add (1|M0)               r1.2<1>:f     r4.0<0;1,0>:f     1.0:f               {Compacted}
(~f0.0) cmp (1|M0)    (eq)f0.0   null<1>:d     r4.2<0;1,0>:d     0:w               {A@1}
(~f0.0) mov (1|M0)               r4.0<1>:f     r1.2<0;1,0>:f                    {F@1}
        goto (16|M0)                         L22584                  L22608                
L22584:
        join (16|M0)                         L22608                                
L22600:
        add (1|M0)               r4.0<1>:f     r4.0<0;1,0>:f     1.0:f               {Compacted,F@1}
L22608:
        join (16|M0)                         L22664                                
L22624:
        add (1|M0)               r4.1<1>:ud    r4.1<0;1,0>:ud    0xFE800000:ud             
        mul (1|M0)               r4.0<1>:f     r4.0<0;1,0>:f     r4.1<0;1,0>:f    {Compacted,A@1}
(f1.1)  mov (1|M0)               r4.0<1>:f     -r4.0<0;1,0>:f                   {F@1}
L22664:
        join (16|M0)                         L22792                                
L22680:
        add (1|M0)               r23.5<1>:d    r23.5<0;1,0>:d    1:w              
        or (1|M0)                r1.3<1>:uw    r23.4<0;1,0>:uw   0x20:uw             
        cmp (1|M0)    (eq)f0.1   null<1>:d     r23.5<0;1,0>:d    8:w               {I@2}
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0xA40:uw              {A@1}
        mov (1|M0)               r[a0.0]<1>:f  r4.0<0;1,0>:f                    {F@1}
(W)     and (1|M0)               f0.1<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(~f0.1.any16h) goto.b (16|M0)                L22792                  L21800                
L22792:
        join (16|M0)                         L23296                                
L22808:
        mul (1|M0)               acc0.0<1>:ud  r23.3<0;1,0>:ud   r23.0<0;1,0>:uw 
        mach (1|M0)              r8.0<1>:ud    r23.3<0;1,0>:ud   r23.0<0;1,0>:ud  {AccWrEn}
        mov (8|M0)               r6.0<1>:hf    r82.0<1;1,0>:f                   {F@1}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r23.3<0;1,0>:d    r23.2<0;1,0>:uw 
        mach (1|M0)              r2.0<1>:d     r23.3<0;1,0>:d    r23.1<0;1,0>:d  
(W)     mul (1|M0)               acc0.0<1>:d   r23.4<0;1,0>:d    r23.0<0;1,0>:uw  {Compacted}
        mach (1|M0)              r9.0<1>:d     r23.4<0;1,0>:d    r23.0<0;1,0>:d   {Compacted}
        shl (1|M0)               r10.0<1>:d    r7.0<0;1,0>:d     1:w               {Compacted,I@5}
        add3 (1|M0)              r1.3<1>:d     r9.0<0;0>:d       r8.0<0;0>:d       r2.0<0>:d        {I@2}
        shr (1|M0)               r4.1<1>:ud    r7.0<0;1,0>:ud    0x1F:uw             
        addc (1|M0)              r11.0<1>:ud   r77.5<0;1,0>:ud   r10.0<0;1,0>:ud  {AccWrEn,I@3}
        shl (1|M0)               r3.5<1>:d     r1.3<0;1,0>:d     1:w               {I@3}
        mov (1|M0)               r12.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        or (1|M0)                r10.1<1>:d    r3.5<0;1,0>:d     r4.1<0;1,0>:d    {I@2}
        mov (1|M0)               r10.2<1>:d    r11.0<0;1,0>:d                  
        add3 (1|M0)              r10.3<1>:d    r12.0<0;0>:d      r77.6<0;0>:d      r10.1<0>:d       {I@2}
        sync.nop                             null                             {Compacted,$8.src}
        mov (8|M0)               r13.0<2>:ud   r10.2<0;1,0>:ud                  {I@2}
        mov (8|M0)               r13.1<2>:ud   r10.3<0;1,0>:ud                  {I@2}
        mov (8|M0)               r7.0<1>:d     r88.1<2;1,0>:d                  
        addc (8|M0)              r15.0<1>:ud   r13.0<2;1,0>:ud   r88.0<2;1,0>:ud  {AccWrEn,Compacted,I@2}
        mov (8|M0)               r12.0<1>:d    r86.1<2;1,0>:d                  
        mov (8|M0)               r9.0<1>:ud    acc0.0<1;1,0>:ud                 {Compacted}
        addc (8|M0)              r20.0<1>:ud   r13.0<2;1,0>:ud   r86.0<2;1,0>:ud  {AccWrEn,Compacted}
        mov (8|M0)               r6.8<1>:hf    r83.0<1;1,0>:f                  
        mov (8|M0)               r11.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        add3 (8|M0)              r8.0<1>:d     r9.0<1;0>:d       r13.1<4;2>:d      r7.0<1>:d        {I@3}
        add3 (8|M0)              r10.0<1>:d    r11.0<1;0>:d      r13.1<4;2>:d      r12.0<1>:d       {I@2}
        sync.nop                             null                             {Compacted,$3.src}
        mov (8|M0)               r16.0<2>:d    r15.0<1;1,0>:d                   {$1.src}
        mov (8|M0)               r18.0<2>:d    r20.0<1;1,0>:d                  
        mov (16|M0)              r21.0<1>:d    r6.0<1;1,0>:uw                   {A@1}
        mov (8|M0)               r16.1<2>:d    r8.0<1;1,0>:d                    {I@5}
        mov (8|M0)               r18.1<2>:d    r10.0<1;1,0>:d                   {I@5}
        send.ugm (16|M0)         null     r16     r21:2   0x0            0x08000B84           {A@1,$3} // wr:4+2, rd:0; store.ugm.d16u32.a64
L23296:
        join (16|M0)                         L23368                                
L23312:
        add (1|M0)               r77.0<1>:d    r77.0<0;1,0>:d    1:w               {Compacted}
        cmp (1|M0)    (eq)f0.0   null<1>:d     r77.0<0;1,0>:d    8:w               {I@1}
(W)     and (1|M0)               f0.0<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
(~f0.0.any16h) goto.b (16|M0)                L23368                  L17560                
L23368:
        join (16|M0)                         L23384                                
L23384:
(W)     mov (8|M0)               r127.0<1>:f   r0.0<1;1,0>:f                    {Compacted}
        sync.nop                             null                             {Compacted,$2.src}
(W)     send.ugm (1|M0)          r6       r0      null:0  0x0            0x0210641F           {$6} // wr:1+0, rd:1; fence invalid flush type scoped to tile
(W)     mov (8|M0)               null<1>:ud    r6.0<1;1,0>:ud                   {$6.dst}
(W)     send.gtwy (1|M0)         null     r127    null:0  0x0            0x02000010           {EOT,A@1} // wr:1+0, rd:0; end of thread
L23448:
        mov (1|M0)               r1.2<1>:d     cr0.0<0;1,0>:ud                  {A@1}
        and (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   -1265:w               {A@1}
        or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   1264:w               {A@1}
        mov (1|M0)               r1.5<1>:f     (abs)r10.5<0;1,0>:d              {A@1}
        mov (1|M0)               r6.0<1>:f     0xB4C00000:f                               {Compacted,I@4}
        math.inv (1|M0)          r5.5<1>:f     r1.5<0;1,0>:f                    {@2,$7}
        mov (1|M0)               r2.1<1>:f     (abs)r10.4<0;1,0>:d             
        sync.nop                             null                             {Compacted,$7.dst}
        mad (1|M0)               r5.5<1>:f     r5.5<0;0>:f       r6.0<0;0>:f       r5.5<0>:f        {F@2}
        mov (1|M0)               r1.3<1>:d     (abs)r10.4<0;1,0>:d             
        mov (1|M0)               r1.4<1>:d     (abs)r10.5<0;1,0>:d             
        mov (1|M0)               r1.6<1>:ud    r1.5<0;1,0>:f                   
        mov (1|M0)               r3.5<1>:ud    r2.1<0;1,0>:f                    {F@2}
        mul (1|M0)               r7.0<1>:f     r5.5<0;1,0>:f     r2.1<0;1,0>:f    {F@1}
        add (1|M0)               r1.6<1>:ud    r1.4<0;1,0>:ud    -r1.6<0;1,0>:ud  {I@2}
        add (1|M0)               r3.5<1>:ud    r1.3<0;1,0>:ud    -r3.5<0;1,0>:ud  {I@2}
        mov (1|M0)               r8.0<1>:ud    r7.0<0;1,0>:f                    {F@1}
        mov (1|M0)               r2.0<1>:f     r1.6<0;1,0>:ud                   {Compacted,I@3}
        mov (1|M0)               r4.1<1>:f     r3.5<0;1,0>:ud                   {I@2}
        mov (1|M0)               r8.1<1>:f     r8.0<0;1,0>:ud                   {Compacted,I@1}
        xor (1|M0)               r10.5<1>:d    r10.5<0;1,0>:d    r10.4<0;1,0>:d  
        mad (1|M0)               r2.1<1>:f     r2.1<0;0>:f       r8.1<0;0>:f       -r1.5<0>:f       {F@1}
        mad (1|M0)               r8.1<1>:f     r4.1<0;0>:f       r8.1<0;0>:f       -r2.0<0>:f      
(W)     mov (1|M0)               r3.10<1>:hf   0x1:hf                             
        add (1|M0)               r2.1<1>:f     r2.1<0;1,0>:f     r8.1<0;1,0>:f    {F@2}
        asr (1|M0)               r10.5<1>:d    r10.5<0;1,0>:d    31:w               {I@1}
        mul (1|M0)               r5.5<1>:f     r5.5<0;1,0>:f     r2.1<0;1,0>:f    {F@1}
        mov (1|M0)               r9.0<1>:ud    r5.5<0;1,0>:f                    {F@1}
        add (1|M0)               r8.0<1>:ud    r8.0<0;1,0>:ud    r9.0<0;1,0>:ud   {Compacted,I@1}
(W)     mul (1|M0)               acc0.0<1>:ud  r8.0<0;1,0>:ud    r1.8<0;1,0>:uw   {I@1}
        mach (1|M0)              r6.0<1>:ud    r8.0<0;1,0>:ud    r1.4<0;1,0>:ud   {Compacted}
        add (1|M0)               r1.3<1>:ud    r1.3<0;1,0>:ud    -r6.0<0;1,0>:ud  {Compacted,I@1}
        cmp (1|M0)    (ge)f0.0   null<1>:ud    r1.3<0;1,0>:ud    r1.4<0;1,0>:ud   {I@1}
(f0.0)  sel (1|M0)               r4.1<1>:d     r3.10<0;1,0>:w    0:w              
        add3 (1|M0)              r8.0<1>:d     r8.0<0;0>:d       r10.5<0;0>:d      r4.1<0>:d        {I@1}
        xor (1|M0)               r75.1<1>:d    r8.0<0;1,0>:d     r10.5<0;1,0>:d   {I@1}
        mov (1|M0)               cr0.0<1>:ud   r1.2<0;1,0>:d                    {A@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        ret (16|M0)                          r10.0                            {A@1}
L24032:
        shr (1|M0)               r15.7<1>:ud   r13.1<0;1,0>:ud   0x17:uw             
        shr (1|M0)               r12.6<1>:ud   r13.0<0;1,0>:ud   0x17:uw             
        and (1|M0)               r15.7<1>:ud   r15.7<0;1,0>:ud   0xFF:uw              {I@2}
        and (1|M0)               r12.6<1>:ud   r12.6<0;1,0>:ud   0xFF:uw              {I@2}
        add (1|M0)               r1.3<1>:ud    r15.7<0;1,0>:ud   0xFFFFFF41:ud              {I@2}
        add (1|M0)               r1.2<1>:ud    r12.6<0;1,0>:ud   0xFFFFFF41:ud              {I@2}
        cmp (1|M0)    (lt)f0.1   null<1>:ud    r1.3<0;1,0>:ud    0xFFFFFF81:ud              {I@2}
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                             
(~f0.1) cmp (1|M0)    (lt)f0.1   null<1>:ud    r1.2<0;1,0>:ud    0xFFFFFF82:ud              {I@2}
(f0.1)  sel (1|M0)               r12.22<2>:b   r2.0<0;1,0>:w     0:w               {F@1}
        cmp (1|M0)    (ne)f1.1   null<1>:uw    r12.22<0;1,0>:ub  0x0:uw              {I@1}
(W)     and (1|M0)               f1.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(~f1.1.any16h) goto (16|M0)                  L27736                  L27736                
L24240:
        add (1|M0)               r1.3<1>:ud    r15.7<0;1,0>:ud   0xFFFFFF01:ud             
        add (1|M0)               r1.2<1>:ud    r12.6<0;1,0>:ud   0xFFFFFF01:ud             
        cmp (1|M0)    (lt)f0.0   null<1>:ud    r1.3<0;1,0>:ud    0xFFFFFF02:ud              {I@2}
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                             
        mov (1|M0)               r16.6<1>:f    (abs)r13.0<0;1,0>:f              {Compacted}
(~f0.0) cmp (1|M0)    (lt)f0.0   null<1>:ud    r1.2<0;1,0>:ud    0xFFFFFF02:ud              {I@2}
(f0.0)  sel (1|M0)               r16.20<2>:b   r2.0<0;1,0>:w     0:w               {F@2}
        cmp (1|M0)    (ne)f0.1   null<1>:uw    r16.20<0;1,0>:ub  0x0:uw              {I@1}
(W)     and (1|M0)               f0.1<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(f0.1.any16h) goto (16|M0)                   L24488                  L24488                
L24392:
        mov (1|M0)               r1.2<1>:f     (abs)r13.1<0;1,0>:f             
        mov (1|M0)               r15.24<2>:b   0:w                              
        add (1|M0)               r16.6<1>:d    r16.6<0;1,0>:d    -r1.2<0;1,0>:d   {A@1}
        mov (2|M0)               r15.4<1>:d    r13.0<1;1,0>:ud                 
        asr (1|M0)               r16.6<1>:d    r16.6<0;1,0>:d    23:w               {I@2}
        goto (16|M0)                         L24488                  L26200                
L24488:
        join (16|M0)                         L26200                                
L24504:
        cmp (1|M0)    (gt)f0.0   null<1>:ud    r16.6<0;1,0>:ud   0x7F800000:ud              {I@3}
(W)     mov (1|M0)               r1.3<1>:hf    0xFF:hf                             
        mov (1|M0)               r16.4<1>:f    (abs)r13.1<0;1,0>:f             
(W)     mov (1|M0)               r2.1<1>:hf    -qnan(0x1FF):hf                             
(f0.0)  sel (1|M0)               r2.0<1>:w     r1.3<0;1,0>:w     0:w               {F@3}
        add (1|M0)               r12.7<1>:f    r13.0<0;1,0>:f    r13.1<0;1,0>:f  
        cmp (1|M0)    (eq)f1.1   null<1>:w     r2.0<0;1,0>:b     0:w               {I@1}
(W)     mov (1|M0)               r3.10<1>:uw   r2.0<0;1,0>:ub                  
        and (1|M0)               r16.7<1>:ud   r13.0<0;1,0>:ud   0x7F800000:ud             
(W)     mov (1|M0)               r6.0<1>:f     -0.0:f                               {Compacted}
(f1.1)  cmp (1|M0)    (gt)f1.1   null<1>:ud    r16.4<0;1,0>:ud   0x7F800000:ud              {F@4}
        bfn.0x6A (1|M0)          r1.2<1>:ud    r13.0<0;0>:ud     r13.1<0;0>:ud     r6.0<0>:ud       {F@1} // s0^s1&s2
        bfn.0x6A (1|M0)          r1.3<1>:ud    r13.1<0;0>:ud     r13.0<0;0>:ud     r6.0<0>:ud       // s0^s1&s2
        and (1|M0)               r16.6<1>:ud   r13.1<0;1,0>:ud   0x7F800000:ud             
(f1.1)  sel (1|M0)               r2.4<2>:b     r2.1<0;1,0>:w     0:w              
        and (1|M0)               r4.1<1>:ud    r13.1<0;1,0>:ud   0x80000000:ud             
        and (1|M0)    (ne)f0.1   null<1>:w     r2.4<0;1,0>:ub    1:w               {I@2}
        and (1|M0)               r77.5<1>:ud   r13.0<0;1,0>:ud   0x80000000:ud             
(f0.1)  add (1|M0)               r12.7<1>:f    r13.1<0;1,0>:f    r13.1<0;1,0>:f  
        or (1|M0)     (eq)f0.1   r2.4<2>:ub    r2.4<0;1,0>:ub    r3.10<0;1,0>:uw  {F@1}
(f0.1)  cmp (1|M0)    (eq)f0.1   null<1>:d     r16.7<0;1,0>:d    2139095040:d              
(W)     mov (1|M0)               r5.10<1>:uw   r2.4<0;1,0>:ub                   {I@2}
(f0.1)  sel (1|M0)               r1.6<2>:b     r2.1<0;1,0>:w     0:w              
        and (1|M0)    (ne)f0.0   null<1>:w     r1.6<0;1,0>:ub    1:w               {I@1}
(f0.0)  add (1|M0)               r12.7<1>:f    r1.2<0;1,0>:f     -r1.3<0;1,0>:f  
        or (1|M0)     (eq)f0.0   r1.6<2>:ub    r1.6<0;1,0>:ub    r5.10<0;1,0>:uw  {F@1}
(f0.0)  cmp (1|M0)    (eq)f0.0   null<1>:d     r16.6<0;1,0>:d    2139095040:d              
(W)     mov (1|M0)               r3.10<1>:uw   r1.6<0;1,0>:ub                   {I@2}
(f0.0)  sel (1|M0)               r77.24<2>:b   r2.1<0;1,0>:w     0:w              
        and (1|M0)    (ne)f1.1   null<1>:w     r77.24<0;1,0>:ub  1:w               {I@1}
(f1.1)  mul (1|M0)               r12.7<1>:f    r4.1<0;1,0>:f     r13.0<0;1,0>:f  
        or (1|M0)     (eq)f1.1   r77.24<2>:ub  r77.24<0;1,0>:ub  r3.10<0;1,0>:uw  {F@1}
(f1.1)  cmp (1|M0)    (eq)f1.1   null<1>:f     r13.1<0;1,0>:f    0.0:f               {I@1}
(f1.1)  sel (1|M0)               r4.0<2>:b     r2.1<0;1,0>:w     0:w              
        cmp (1|M0)    (ne)f0.1   null<1>:uw    r4.0<0;1,0>:ub    0x0:uw              {I@1}
(W)     and (1|M0)               f0.0<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(f0.0.any16h) goto (16|M0)                   L25120                  L25120                
L25088:
        mov (1|M0)               r4.0<2>:b     r77.24<0;1,0>:b                 
        goto (16|M0)                         L25120                  L25304                
L25120:
        join (16|M0)                         L25304                                
L25136:
(W)     mov (1|M0)               r2.0<1>:f     inf:f                               {Compacted}
        cmp (1|M0)    (eq)f1.1   null<1>:f     r13.0<0;1,0>:f    0.0:f              
        bfn.0x96 (1|M0)          r77.5<1>:ud   r77.5<0;0>:ud     r13.1<0;0>:ud     r2.0<0>:ud       {F@2} // s0^s1^s2
        xor (1|M0)               r1.2<1>:ud    r13.1<0;1,0>:ud   0x7F800000:ud             
        and (1|M0)    (ne)f0.0   null<1>:w     r4.0<0;1,0>:ub    1:w               {I@5}
(W)     mov (1|M0)               r3.10<1>:uw   r77.24<0;1,0>:ub                
(~f1.1) mov (1|M0)               r1.2<1>:f     r77.5<0;1,0>:f                   {A@3}
        or (1|M0)                r77.24<2>:ub  r4.0<0;1,0>:ub    r3.10<0;1,0>:uw  {I@1}
(f1.1)  mul (1|M0)               r77.5<1>:f    r1.2<0;1,0>:f     r13.0<0;1,0>:f   {F@1}
        mov (1|M0)               r4.0<2>:b     r77.24<0;1,0>:b                  {I@1}
(f0.0)  mov (1|M0)               r12.7<1>:f    r77.5<0;1,0>:f                   {F@1}
L25304:
        join (16|M0)                         L26200                                
L25320:
        cmp (1|M0)    (eq)f0.1   null<1>:w     r77.24<0;1,0>:b   0:w              
(W)     mov (1|M0)               r1.3<1>:hf    -qnan(0x1FF):hf                             
(W)     mov (1|M0)               r2.0<1>:uw    r4.0<0;1,0>:ub                   {I@3}
(f0.1)  cmp (1|M0)    (eq)f0.1   null<1>:f     r13.0<0;1,0>:f    0.0:f               {I@2}
(f0.1)  sel (1|M0)               r15.24<2>:b   r1.3<0;1,0>:w     0:w               {F@2}
        and (1|M0)    (ne)f1.1   null<1>:w     r15.24<0;1,0>:ub  1:w               {I@1}
        or (1|M0)     (ne)f0.1   r15.24<2>:ub  r15.24<0;1,0>:ub  r2.0<0;1,0>:uw   {F@1}
(f1.1)  mul (1|M0)               r12.7<1>:f    r13.0<0;1,0>:f    r13.1<0;1,0>:f  
(W)     and (1|M0)               f1.1<1>:uw    f0.1<0;1,0>:uw    0x1:uw              {F@1}
(f1.1.any16h) goto (16|M0)                   L26200                  L27704                
L25480:
        cmp (1|M0)    (eq)f0.0   null<1>:uw    r15.24<0;1,0>:ub  0x0:uw              {I@3}
        cmp (1|M0)    (eq)f1.1   null<1>:d     r16.7<0;1,0>:d    0:w              
(~f0.0) mov (1|M0)               r16.20<2>:b   0:w                              
(f1.1)  sel (1|M0)               r4.0<1>:d     r16.20<0;1,0>:b   0:w               {I@1}
        cmp (1|M0)    (ne)f0.1   null<1>:d     r4.0<0;1,0>:d     0:w               {I@1}
(W)     and (1|M0)               f0.1<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(f0.1.any16h) goto (16|M0)                   L25632                  L25632                
L25592:
        mov (1|M0)               r4.0<1>:d     0:w                              
        mov (1|M0)               r15.4<1>:f    r13.0<0;1,0>:f                   {Compacted}
        goto (16|M0)                         L25632                  L25784                
L25632:
        join (16|M0)                         L25784                                
L25648:
        and (1|M0)    (ne)f0.0   r4.0<1>:d     r4.0<0;1,0>:d     1:w               {I@3}
        mov (1|M0)               r15.4<1>:f    r13.0<0;1,0>:f                   {Compacted}
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1E0):hf                             
(f0.0)  mul (1|M0)               r15.4<1>:f    r13.0<0;1,0>:f    0x4F800000:f              
(f0.0)  sel (1|M0)               r4.0<1>:d     r2.0<0;1,0>:w     0:w               {F@2}
        shr (1|M0)               r1.2<1>:ud    r15.4<0;1,0>:ud   0x17:uw              {F@1}
        and (1|M0)               r1.2<1>:ud    r1.2<0;1,0>:ud    0xFF:uw              {I@1}
        add (1|M0)               r1.2<1>:ud    r1.2<0;1,0>:ud    0xFFFFFFE0:ud              {I@1}
(f0.0)  mov (1|M0)               r12.6<1>:d    r1.2<0;1,0>:d                    {I@1}
L25784:
        join (16|M0)                         L26200                                
L25800:
        cmp (1|M0)    (eq)f0.0   null<1>:d     r16.6<0;1,0>:d    0:w              
(f0.0)  sel (1|M0)               r4.1<1>:d     r16.20<0;1,0>:b   0:w              
        cmp (1|M0)    (ne)f1.1   null<1>:d     r4.1<0;1,0>:d     0:w               {I@1}
(W)     and (1|M0)               f0.0<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(f0.0.any16h) goto (16|M0)                   L25928                  L25928                
L25880:
        mov (1|M0)               r16.7<1>:d    0:w                              
        mov (1|M0)               r15.5<1>:d    r13.1<0;1,0>:ud                 
        goto (16|M0)                         L25928                  L26104                
L25928:
        join (16|M0)                         L26104                                
L25944:
        and (1|M0)    (ne)f1.1   r4.1<1>:d     r4.1<0;1,0>:d     1:w              
        mov (1|M0)               r15.5<1>:f    r13.1<0;1,0>:f                   {I@4}
(W)     mov (1|M0)               r2.0<1>:hf    0x20:hf                             
(f1.1)  mul (1|M0)               r15.5<1>:f    r13.1<0;1,0>:f    0x4F800000:f              
(f1.1)  sel (1|M0)               r16.7<1>:d    r2.0<0;1,0>:w     0:w               {F@2}
        shr (1|M0)               r1.2<1>:ud    r15.5<0;1,0>:ud   0x17:uw              {F@1}
        mov (1|M0)               r16.4<1>:f    (abs)r15.5<0;1,0>:f             
        and (1|M0)               r1.2<1>:ud    r1.2<0;1,0>:ud    0xFF:uw              {I@1}
        add (1|M0)               r1.2<1>:ud    r1.2<0;1,0>:ud    0xFFFFFFE0:ud              {I@1}
(f1.1)  mov (1|M0)               r15.7<1>:d    r1.2<0;1,0>:d                    {I@1}
L26104:
        join (16|M0)                         L26200                                
L26120:
        mov (1|M0)               r16.6<1>:f    (abs)r15.4<0;1,0>:f             
        add (1|M0)               r16.7<1>:d    r16.7<0;1,0>:d    r4.0<0;1,0>:d   
        add (1|M0)               r16.6<1>:d    r16.6<0;1,0>:d    -r16.4<0;1,0>:d  {F@1}
        asr (1|M0)               r16.6<1>:d    r16.6<0;1,0>:d    23:w               {I@1}
        add (1|M0)               r16.7<1>:d    r16.7<0;1,0>:d    r16.6<0;1,0>:d   {I@1}
L26200:
        join (16|M0)                         L27704                                
L26216:
        cmp (1|M0)    (eq)f0.1   null<1>:uw    r16.20<0;1,0>:ub  0x0:uw             
(W)     mov (1|M0)               r1.2<1>:f     1.0:f                               {Compacted}
(W)     mov (1|M0)               r2.0<1>:f     0x807FFFFF:f                              
        cmp (1|M0)    (eq)f0.0   null<1>:w     r15.24<0;1,0>:b   0:w              
(~f0.1) mov (1|M0)               r16.6<1>:d    r16.7<0;1,0>:d                   {I@4}
        bfn.0xEA (1|M0)          r15.5<1>:ud   r1.2<0;0>:ud      r15.5<0;0>:ud     r2.0<0>:ud       {A@1} // s0|s1&s2
        add (1|M0)               r7.4<1>:d     r16.6<0;1,0>:d    126:w               {I@2}
        add (1|M0)               r7.3<1>:d     -r16.6<0;1,0>:d   -152:w              
        sync.nop                             null                             {Compacted,I@3}
        math.inv (1|M0)          r3.5<1>:f     r15.5<0;1,0>:f                   {$8}
        and (1|M0)               r7.3<1>:d     r7.3<0;1,0>:d     r7.4<0;1,0>:d    {I@1}
        mov (1|M0)               r7.0<1>:f     1.0:f                               {Compacted}
        asr (1|M0)               r7.3<1>:d     r7.3<0;1,0>:d     31:w               {Compacted,I@1}
(~f0.0) mov (1|M0)               r7.3<1>:d     0:w                              
        bfn.0xEA (1|M0)          r15.4<1>:ud   r1.2<0;0>:ud      r15.4<0;0>:ud     r2.0<0>:ud       // s0|s1&s2
        cmp (1|M0)    (ne)f1.1   null<1>:d     r7.3<0;1,0>:d     0:w               {I@2}
        sync.nop                             null                             {Compacted,$8.dst}
        mad (1|M0)               r7.0<1>:f     r7.0<0;0>:f       r3.5<0;0>:f       -r15.5<0>:f      {F@1}
        mul (1|M0)               r4.1<1>:f     r3.5<0;1,0>:f     r15.4<0;1,0>:f   {I@2}
        mad (1|M0)               r7.0<1>:f     r3.5<0;0>:f       r3.5<0;0>:f       r7.0<0>:f        {F@2}
        mad (1|M0)               r7.1<1>:f     r15.4<0;0>:f      r4.1<0;0>:f       -r15.5<0>:f      {F@2}
(W)     and (1|M0)               f1.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
        mad (1|M0)               r7.1<1>:f     r4.1<0;0>:f       r7.0<0;0>:f       r7.1<0>:f        {F@1}
        add (1|M0)               r12.6<1>:d    r12.6<0;1,0>:d    -r15.7<0;1,0>:d 
        mad (1|M0)               r15.4<1>:f    r15.4<0;0>:f      r7.1<0;0>:f       -r15.5<0>:f      {F@1}
(~f1.1.any16h) goto (16|M0)                  L27360                  L27360                
L26592:
        mov (1|M0)               r7.2<1>:f     r15.4<0;1,0>:f                   {F@1}
        mov (2|M0)               r2.0<1>:f     r7.0<1;1,0>:f                   
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r4.0          L27960                                 {A@1}
L26672:
        cmp (1|M0)    (eq)f0.0   null<1>:f     r15.4<0;1,0>:f    0.0:f              
(W)     mov (1|M0)               r1.3<1>:hf    0x1:hf                             
        add (1|M0)               r16.6<1>:d    r16.6<0;1,0>:d    125:w              
(W)     mov (1|M0)               r3.10<1>:hf   0x1:hf                             
(f0.0)  sel (1|M0)               r2.0<1>:w     r1.3<0;1,0>:w     0:w               {F@2}
        cmp (1|M0)    (lt)f0.1   null<1>:d     r16.6<0;1,0>:d    -2:w               {I@2}
        cmp (1|M0)    (ne)f1.1   null<1>:w     r2.0<0;1,0>:w     0:w               {I@2}
(W)     mov (1|M0)               r5.10<1>:hf   -qnan(0x1FF):hf                             
(f0.1)  sel (1|M0)               r3.11<1>:uw   r3.10<0;1,0>:uw   0x0:uw              {F@2}
(f1.1)  sel (1|M0)               r4.2<1>:uw    r3.10<0;1,0>:uw   0x0:uw             
        or (1|M0)     (ne)f0.1   null<1>:uw    r3.11<0;1,0>:uw   r4.2<0;1,0>:uw   {I@1}
(f0.1)  sel (1|M0)               r7.20<2>:b    r5.10<0;1,0>:w    0:w               {F@1}
        cmp (1|M0)    (ne)f0.1   null<1>:uw    r7.20<0;1,0>:ub   0x0:uw              {I@1}
(W)     and (1|M0)               f0.1<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(~f0.1.any16h) goto (16|M0)                  L27032                  L27032                
L26912:
(W)     mov (1|M0)               r1.3<1>:hf    0x1:hf                             
        and (1|M0)               r1.2<1>:d     r7.2<0;1,0>:d     -2139095041:d              
(W)     mov (1|M0)               r6.0<1>:f     0x800000:f                               {Compacted}
        shl (1|M0)               r7.4<1>:d     r7.4<0;1,0>:d     23:w              
(f0.0)  sel (1|M0)               r2.0<1>:d     r1.3<0;1,0>:w     0:w               {F@2}
        add (1|M0)               r7.4<1>:d     r7.4<0;1,0>:d     1065353216:d               {I@2}
        bfn.0xFE (1|M0)          r1.2<1>:ud    r1.2<0;0>:ud      r2.0<0;0>:ud      r6.0<0>:ud       {A@1} // s0|s1|s2
        mul (1|M0)               r7.4<1>:f     r7.4<0;1,0>:f     r1.2<0;1,0>:f    {A@1}
L27032:
        join (16|M0)                         L27360                                
L27048:
        and (1|M0)               r1.2<1>:d     r7.2<0;1,0>:d     -2147483648:d               {F@1}
(W)     mov (1|M0)               r1.3<1>:hf    0x1:hf                             
        shl (1|M0)               r7.2<1>:d     r7.2<0;1,0>:d     1:w              
(f1.1)  sel (1|M0)               r2.0<1>:d     r1.3<0;1,0>:w     0:w               {F@1}
        and (1|M0)               r1.3<1>:d     r7.2<0;1,0>:d     8388606:d               {I@2}
        and (1|M0)    (eq)f1.1   r7.2<1>:d     r7.2<0;1,0>:d     8388608:d              
(W)     mov (1|M0)               r3.5<1>:f     1.469368e-38:f                               {Compacted}
(W)     mov (1|M0)               r5.5<1>:f     0x800000:f                               {Compacted}
        or (1|M0)                r2.0<1>:d     r1.2<0;1,0>:d     r2.0<0;1,0>:d    {Compacted,I@3}
(f1.1)  sel (1|M0)               r4.1<1>:d     r3.5<0;1,0>:d     12582912:d               {F@2}
        mov (1|M0)               r6.0<1>:f     0.25:f                               {Compacted}
        bfn.0xFE (1|M0)          r2.0<1>:ud    r5.5<0;0>:ud      r2.0<0;0>:ud      r1.3<0>:ud       {A@2} // s0|s1|s2
        or (1|M0)                r4.1<1>:d     r4.1<0;1,0>:d     r1.2<0;1,0>:d    {I@2}
        or (1|M0)                r2.1<1>:d     r1.2<0;1,0>:d     8388608:d              
        mad (1|M0)               r2.0<1>:f     r4.1<0;0>:f       r6.0<0;0>:f       r2.0<0>:f        {A@1}
        cmp (1|M0)    (eq)f0.1   null<1>:uw    r7.20<0;1,0>:ub   0x0:uw             
        add (1|M0)               r2.0<1>:f     r2.0<0;1,0>:f     -r2.1<0;1,0>:f   {Compacted,A@1}
        mul (1|M0)               r2.1<1>:f     r2.1<0;1,0>:f     r2.1<0;1,0>:f   
        and (1|M0)    (ne)f0.0   null<1>:d     r7.3<0;1,0>:d     1:w              
        and (1|M0)               r2.1<1>:d     r2.1<0;1,0>:d     -2:w               {Compacted,F@1}
        or (1|M0)                r2.1<1>:d     r2.1<0;1,0>:d     r2.0<0;1,0>:d    {Compacted,I@1}
(~f0.1) mov (1|M0)               r2.1<1>:f     r7.4<0;1,0>:f                    {I@1}
(f0.0)  mov (1|M0)               r12.7<1>:f    r2.1<0;1,0>:f                    {F@1}
L27360:
        join (16|M0)                         L27704                                
L27376:
        add (1|M0)               r2.0<1>:d     r12.6<0;1,0>:d    126:w               {Compacted}
(W)     mov (1|M0)               r1.3<1>:uw    r7.12<0;1,0>:ub                 
        cmp (1|M0)    (gt)f1.1   null<1>:ud    r2.0<0;1,0>:ud    0x17A:uw              {I@2}
        mad (1|M0)               r15.4<1>:f    r7.1<0;0>:f       r7.0<0;0>:f       r15.4<0>:f      
        or (1|M0)                r4.0<1>:w     r15.24<0;1,0>:ub  r1.3<0;1,0>:uw   {I@2}
(W)     and (1|M0)               f0.0<1>:uw    f1.1<0;1,0>:uw    0x1:uw              {F@2}
(~f0.0.any16h) goto (16|M0)                  L27560                  L27560                
L27480:
(f1.1)  sel (1|M0)               r1.2<1>:d     r12.6<0;1,0>:d    0:w              
        asr (1|M0)               r1.2<1>:d     r1.2<0;1,0>:d     11:w               {I@1}
        add (1|M0)               r1.3<1>:d     r1.2<0;1,0>:d     248:w               {I@1}
        xor (1|M0)               r1.3<1>:d     r1.3<0;1,0>:d     r1.2<0;1,0>:d    {I@1}
(f1.1)  mov (1|M0)               r12.6<1>:d    r1.3<0;1,0>:d                    {I@1}
L27560:
        join (16|M0)                         L27704                                
L27576:
        asr (1|M0)               r1.2<1>:d     r12.6<0;1,0>:d    1:w               {I@2}
        cmp (1|M0)    (eq)f1.1   null<1>:w     r4.0<0;1,0>:w     0:w              
        add (1|M0)               r12.6<1>:d    r12.6<0;1,0>:d    -r1.2<0;1,0>:d   {I@2}
        shl (1|M0)               r1.2<1>:d     r1.2<0;1,0>:d     23:w              
        shl (1|M0)               r12.6<1>:d    r12.6<0;1,0>:d    23:w               {I@2}
        add (1|M0)               r1.2<1>:d     r1.2<0;1,0>:d     r15.4<0;1,0>:d   {A@1}
        add (1|M0)               r12.6<1>:d    r12.6<0;1,0>:d    1065353216:d               {I@2}
(f1.1)  mul (1|M0)               r12.7<1>:f    r12.6<0;1,0>:f    r1.2<0;1,0>:f    {I@1}
L27704:
        join (16|M0)                         L27736                                
L27720:
        mov (1|M0)               r15.4<1>:f    r12.7<0;1,0>:f                   {F@1}
L27736:
        join (16|M0)                         L27752                                
L27752:
        math.inv (1|M0)          r1.2<1>:f     r13.1<0;1,0>:f                   {$9}
        mov (1|M0)               r1.4<1>:ud    0x3F800000:ud                             
        mul (1|M0)               r1.3<1>:f     r1.2<0;1,0>:f     r13.0<0;1,0>:f   {$9.dst}
        mad (1|M0)               r1.4<1>:f     r1.4<0;0>:f       r1.2<0;0>:f       -r13.1<0>:f      {I@1}
        mad (1|M0)               r2.0<1>:f     r13.0<0;0>:f      r1.3<0;0>:f       -r13.1<0>:f      {F@2}
        mad (1|M0)               r1.4<1>:f     r1.2<0;0>:f       r1.2<0;0>:f       r1.4<0>:f        {F@2}
        cmp (1|M0)    (eq)f0.1   null<1>:uw    r12.22<0;1,0>:ub  0x0:uw             
        mad (1|M0)               r2.0<1>:f     r1.3<0;0>:f       r1.4<0;0>:f       r2.0<0>:f        {F@1}
        mad (1|M0)               r2.1<1>:f     r13.0<0;0>:f      r2.0<0;0>:f       -r13.1<0>:f      {F@1}
(f0.1)  mad (1|M0)               r15.4<1>:f    r2.0<0;0>:f       r1.4<0;0>:f       r2.1<0>:f        {F@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        ret (16|M0)                          r12.2                            {A@1}
L27960:
        mov (1|M0)               r1.2<1>:d     cr0.0<0;1,0>:ud                  {A@1}
        and (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   -1265:w               {A@1}
        or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   1264:w               {A@1}
        mad (1|M0)               r7.2<1>:f     r2.1<0;0>:f       r2.0<0;0>:f       r7.2<0>:f        {A@1}
        mov (1|M0)               cr0.0<1>:ud   r1.2<0;1,0>:d                    {A@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        ret (16|M0)                          r4.0                             {A@1}
L28088:
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
