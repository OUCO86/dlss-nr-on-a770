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
        mov (1|M0)               r78.0<1>:d    r0.1<0;1,0>:ud                   {A@1}
        mov (1|M0)               r42.0<1>:d    r1.0<0;1,0>:uw                   {$0.dst}
        mov (1|M0)               r45.5<1>:d    r2.2<0;1,0>:d                    {$1.dst}
        mov (1|M0)               r45.4<1>:d    r78.0<0;1,0>:d                   {I@3}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r45.6         L6728                                 {A@1}
L352:
        asr (1|M0)               r78.1<1>:d    r2.3<0;1,0>:d     31:w              
        mov (1|M0)               r42.4<1>:d    r45.2<0;1,0>:d                  
        shr (1|M0)               r78.1<1>:ud   r78.1<0;1,0>:ud   0x1A:uw              {I@2}
(W)     mul (1|M0)               acc0.0<1>:d   r42.4<0;1,0>:d    r2.4<0;1,0>:uw   {I@2}
        mach (1|M0)              r2.0<1>:d     r42.4<0;1,0>:d    r2.2<0;1,0>:d   
        add (1|M0)               r78.1<1>:d    r2.3<0;1,0>:d     r78.1<0;1,0>:d   {I@3}
        add (1|M0)               r78.0<1>:d    r78.0<0;1,0>:d    -r2.0<0;1,0>:d   {Compacted,I@2}
        asr (1|M0)               r78.1<1>:d    r78.1<0;1,0>:d    6:w               {Compacted,I@2}
        mov (2|M0)               r45.4<1>:d    r78.0<1;1,0>:d                   {I@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r45.6         L6728                                 {A@1}
L528:
        mov (1|M0)               r1.2<1>:d     r42.4<0;1,0>:d                  
(W)     mul (1|M0)               acc0.0<1>:d   r45.2<0;1,0>:d    r78.2<0;1,0>:uw 
(W)     mach (1|M0)              r2.0<1>:d     r45.2<0;1,0>:d    r78.1<0;1,0>:d  
        mul (1|M0)               acc0.0<1>:ud  r1.2<0;1,0>:ud    r2.12<0;1,0>:uw  {I@3}
        mach (1|M0)              r6.0<1>:ud    r1.2<0;1,0>:ud    r2.6<0;1,0>:ud   {AccWrEn}
        asr (1|M0)               r1.3<1>:d     r42.4<0;1,0>:d    31:w              
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r1.2<0;1,0>:d     r2.14<0;1,0>:uw 
        mach (1|M0)              r7.0<1>:d     r1.2<0;1,0>:d     r2.7<0;1,0>:d   
(W)     mul (1|M0)               acc0.0<1>:d   r1.3<0;1,0>:d     r2.12<0;1,0>:uw  {I@4}
        mov (1|M0)               r78.1<1>:d    r2.0<0;1,0>:d                   
        mach (1|M0)              r2.0<1>:d     r1.3<0;1,0>:d     r2.6<0;1,0>:d   
        addc (1|M0)              r8.0<1>:ud    r2.4<0;1,0>:ud    r5.0<0;1,0>:ud   {AccWrEn,I@6}
        add3 (1|M0)              r1.5<1>:d     r2.0<0;0>:d       r6.0<0;0>:d       r7.0<0>:d        {I@2}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mul (1|M0)               acc0.0<1>:ud  r1.2<0;1,0>:ud    r3.4<0;1,0>:uw  
        mach (1|M0)              r11.0<1>:ud   r1.2<0;1,0>:ud    r3.2<0;1,0>:ud   {AccWrEn}
        asr (1|M0)               r42.7<1>:d    r4.0<0;1,0>:d     31:w               {Compacted}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r1.2<0;1,0>:d     r3.6<0;1,0>:uw  
        mach (1|M0)              r12.0<1>:d    r1.2<0;1,0>:d     r3.3<0;1,0>:d   
(W)     mul (1|M0)               acc0.0<1>:d   r1.3<0;1,0>:d     r3.4<0;1,0>:uw  
        mach (1|M0)              r13.0<1>:d    r1.3<0;1,0>:d     r3.2<0;1,0>:d   
        addc (1|M0)              r2.0<1>:ud    r3.0<0;1,0>:ud    r10.0<0;1,0>:ud  {AccWrEn,I@5}
        shr (1|M0)               r42.7<1>:ud   r42.7<0;1,0>:ud   0x1B:uw             
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mul (1|M0)               acc0.0<1>:ud  r1.2<0;1,0>:ud    r3.12<0;1,0>:uw 
        mach (1|M0)              r15.0<1>:ud   r1.2<0;1,0>:ud    r3.6<0;1,0>:ud   {AccWrEn}
        add3 (1|M0)              r4.4<1>:d     r13.0<0;0>:d      r11.0<0;0>:d      r12.0<0>:d       {I@6}
        mov (1|M0)               r14.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        add (1|M0)               r42.7<1>:d    r4.0<0;1,0>:d     r42.7<0;1,0>:d   {I@6}
(W)     mul (1|M0)               acc0.0<1>:d   r1.2<0;1,0>:d     r3.14<0;1,0>:uw 
        shl (1|M0)               r8.2<1>:d     r14.0<0;1,0>:d    2:w               {Compacted,I@3}
        mach (1|M0)              r7.0<1>:d     r1.2<0;1,0>:d     r3.7<0;1,0>:d   
(W)     mul (1|M0)               acc0.0<1>:d   r1.3<0;1,0>:d     r3.12<0;1,0>:uw 
        add3 (1|M0)              r4.2<1>:d     r9.0<0;0>:d       r2.5<0;0>:d       r1.5<0>:d       
        add3 (1|M0)              r6.1<1>:d     r5.0<0;0>:d       r3.1<0;0>:d       r4.4<0>:d       
        asr (1|M0)               r42.7<1>:d    r42.7<0;1,0>:d    5:w               {I@7}
        mach (1|M0)              r9.0<1>:d     r1.3<0;1,0>:d     r3.6<0;1,0>:d   
        addc (1|M0)              r5.0<1>:ud    r3.4<0;1,0>:ud    r8.2<0;1,0>:ud   {AccWrEn,I@7}
        add3 (1|M0)              r6.3<1>:d     r9.0<0;0>:d       r15.0<0;0>:d      r7.0<0>:d        {I@2}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r45.2<0;1,0>:d    r42.14<0;1,0>:uw
        mach (1|M0)              r7.0<1>:d     r45.2<0;1,0>:d    r42.7<0;1,0>:d  
(W)     mul (1|M0)               acc0.0<1>:d   r45.2<0;1,0>:d    r42.14<0;1,0>:uw
        mach (1|M0)              r9.0<1>:d     r45.2<0;1,0>:d    r42.7<0;1,0>:d  
        add (1|M0)               r5.3<1>:d     r78.0<0;1,0>:d    -r78.1<0;1,0>:d 
        shr (1|M0)               r8.1<1>:ud    r14.0<0;1,0>:ud   0x1E:uw             
        shl (1|M0)               r2.1<1>:d     r6.3<0;1,0>:d     2:w               {I@7}
        shl (1|M0)               r1.4<1>:d     r9.0<0;1,0>:d     12:w               {Compacted,I@4}
        mov (1|M0)               r42.5<1>:d    r5.0<0;1,0>:d                   
        asr (1|M0)               r9.1<1>:d     r7.0<0;1,0>:d     31:w               {Compacted}
        shl (1|M0)               r6.2<1>:d     r5.3<0;1,0>:d     11:w               {I@6}
        or (1|M0)                r8.3<1>:d     r2.1<0;1,0>:d     r8.1<0;1,0>:d    {I@5}
        addc (1|M0)              r5.0<1>:ud    r8.0<0;1,0>:ud    r1.4<0;1,0>:ud   {AccWrEn,I@5}
        shr (1|M0)               r1.3<1>:ud    r9.0<0;1,0>:ud    0x14:uw             
        shl (1|M0)               r1.2<1>:d     r9.1<0;1,0>:d     12:w               {I@5}
        add3 (1|M0)              r42.6<1>:d    r10.0<0;0>:d      r3.5<0;0>:d       r8.3<0>:d        {I@4}
        shl (1|M0)               r9.0<1>:ud    r42.0<0;1,0>:ud   0x7:uw             
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r7.0<1>:ud    r2.0<0;1,0>:ud    r6.2<0;1,0>:ud   {AccWrEn}
        shr (1|M0)               r2.1<1>:ud    r5.3<0;1,0>:ud    0x15:uw             
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@6}
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        shl (1|M0)               r1.2<1>:ud    r42.0<0;1,0>:ud   0x6:uw             
        addc (1|M0)              r12.0<1>:ud   r5.0<0;1,0>:ud    r9.0<0;1,0>:ud   {AccWrEn,I@7}
        or (1|M0)                r6.3<1>:d     r2.1<0;1,0>:d     0:w               {I@5}
        add3 (1|M0)              r5.2<1>:d     r10.0<0;0>:d      r4.2<0;0>:d       r1.5<0>:d        {I@5}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r10.0<1>:ud   r7.0<0;1,0>:ud    r1.2<0;1,0>:ud   {AccWrEn,I@5}
        add3 (1|M0)              r7.2<1>:d     r11.0<0;0>:d      r6.1<0;0>:d       r6.3<0>:d        {I@4}
        mov (1|M0)               r2.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r44.0<1>:f    r12.0<0;1,0>:f                   {Compacted}
        add3 (1|M0)              r44.1<1>:d    r8.0<0;0>:d       r5.2<0;0>:d       0:w               {I@4}
        mov (1|M0)               r45.0<1>:f    r10.0<0;1,0>:f                   {Compacted,I@4}
        add3 (1|M0)              r45.1<1>:d    r2.0<0;0>:d       r7.2<0;0>:d       0:w               {I@2}
        send.ugm (1|M0)          r13      r44     null:0  0x0            0x0240D780           {A@2,$3} // wr:1+0, rd:4; load.ugm.d64x16t.a64
        send.ugm (1|M0)          r17      r45     null:0  0x0            0x0220C780           {A@1,$4} // wr:1+0, rd:2; load.ugm.d64x8t.a64
        add (1|M0)               r43.0<1>:ud   r1.2<0;1,0>:ud    0x2000:uw             
        shr (1|M0)               r42.2<1>:ud   r42.0<0;1,0>:ud   0x2:uw             
        and (1|M0)               r42.3<1>:d    r1.0<0;1,0>:uw    3:w              
        add (1|M0)               r42.1<1>:d    r78.0<0;1,0>:d    -r78.1<0;1,0>:d 
        send.slm (1|M0)          null     r9      r13:4   0x0            0x0200D704           {$3} // wr:1+4, rd:0; store.slm.d64x16t.a32
        send.slm (1|M0)          null     r43     r17:2   0x0            0x0200C704           {A@4,$4} // wr:1+2, rd:0; store.slm.d64x8t.a32
(W)     send.slm (1|M0)          r6       r0      null:0  0x0            0x0210001F           {$5} // wr:1+0, rd:1; fence.slm.none.group
(W)     mov (1|M0)               r5.2<1>:f     0.0:f                               {Compacted}
(W)     mov (2|M0)               r5.10<1>:ub   r0.11<0;1,0>:ub                  {F@1}
(W)     mov (8|M0)               null<1>:ud    r6.0<1;1,0>:ud                   {$5.dst}
(W)     send.gtwy (1|M0)         null     r5      null:0  0x0            0x02000004           {A@2,$6} // wr:1+0, rd:0; signal barrier
(W)     sync.bar                             null                            
        cmp (1|M0)    (gt)f0.0   null<1>:d     r4.0<0;1,0>:d     31:w              
        shl (1|M0)               r43.1<1>:ud   r42.2<0;1,0>:ud   0x9:uw              {$4.src}
        shl (1|M0)               r43.2<1>:d    r42.3<0;1,0>:d    9:w              
        mov (16|M0)              r46.0<1>:d    0:w                              
(W)     and (1|M0)               f1.0<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
        mov (16|M0)              r48.0<1>:d    0:w                              
        mov (16|M0)              r50.0<1>:d    0:w                              
        mov (16|M0)              r52.0<1>:d    0:w                              
        mov (16|M0)              r54.0<1>:d    0:w                              
        mov (16|M0)              r56.0<1>:d    0:w                              
        mov (16|M0)              r58.0<1>:d    0:w                              
        mov (16|M0)              r60.0<1>:d    0:w                              
        mov (16|M0)              r62.0<1>:d    0:w                              
        mov (16|M0)              r64.0<1>:d    0:w                              
        mov (16|M0)              r66.0<1>:d    0:w                              
        mov (16|M0)              r68.0<1>:d    0:w                              
        mov (16|M0)              r70.0<1>:d    0:w                              
        mov (16|M0)              r72.0<1>:d    0:w                              
        mov (16|M0)              r74.0<1>:d    0:w                              
        mov (16|M0)              r76.0<1>:d    0:w                              
(~f1.0.any16h) goto (16|M0)                  L3440                  L3440                
L2168:
        asr (1|M0)               r1.3<1>:d     r2.3<0;1,0>:d     31:w               {Compacted}
        shr (1|M0)               r2.1<1>:ud    r2.3<0;1,0>:ud    0x1B:uw             
        mov (1|M0)               r44.2<1>:d    r42.7<0;1,0>:d                  
        shl (1|M0)               r2.0<1>:d     r1.3<0;1,0>:d     5:w               {Compacted,I@3}
        shl (1|M0)               r43.5<1>:d    r2.3<0;1,0>:d     5:w              
        mov (1|M0)               r44.4<2>:f    0.0:f                              
        mov (1|M0)               r44.5<2>:f    0.0:f                              
        mov (2|M0)               r43.3<1>:d    r44.2<1;1,0>:d                   {I@3}
        or (1|M0)                r43.6<1>:d    r2.0<0;1,0>:d     r2.1<0;1,0>:d    {I@3}
        asr (1|M0)               r43.4<1>:d    r42.7<0;1,0>:d    31:w              
        mov (1|M0)               r44.3<1>:d    0:w                              
L2328:
        addc (1|M0)              r2.0<1>:ud    r44.4<0;1,0>:ud   0x1:ud              {AccWrEn,F@2}
(W)     mov (1|M0)               r1.3<1>:hf    0x1:hf                             
        mov (1|M0)               r44.6<1>:d    r2.0<0;1,0>:d                    {I@1}
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$6.src}
        cmp (1|M0)    (lt)f1.0   null<1>:ud    r44.6<0;1,0>:ud   r43.3<0;1,0>:ud  {I@2}
        add3 (1|M0)              r44.7<1>:d    r5.0<0;0>:d       r44.5<0;0>:d      0:w               {A@2}
        and (1|M0)               r43.7<1>:d    r44.4<0;1,0>:d    1:w              
        cmp (1|M0)    (lt)f0.0   null<1>:d     r44.7<0;1,0>:d    r43.4<0;1,0>:d   {I@2}
(f1.0)  cmp (1|M0)    (eq)f1.0   null<1>:d     r44.7<0;1,0>:d    r43.4<0;1,0>:d  
(f0.0)  sel (1|M0)               r4.2<1>:uw    r1.3<0;1,0>:uw    0x0:uw              {F@1}
(f1.0)  sel (1|M0)               r1.4<1>:uw    r1.3<0;1,0>:uw    0x0:uw             
        or (1|M0)     (ne)f1.1   null<1>:uw    r1.4<0;1,0>:uw    r4.2<0;1,0>:uw   {I@1}
(W)     and (1|M0)               f0.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(~f0.1.any16h) goto (16|M0)                  L2984                  L2984                
L2544:
        shl (1|M0)               r1.5<1>:d     r44.6<0;1,0>:d    12:w              
        shl (1|M0)               r1.3<1>:d     r44.7<0;1,0>:d    12:w              
        shr (1|M0)               r1.4<1>:ud    r44.6<0;1,0>:ud   0x14:uw             
        addc (1|M0)              r2.0<1>:ud    r44.0<0;1,0>:ud   r1.5<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r1.6<1>:d     r1.3<0;1,0>:d     r1.4<0;1,0>:d    {I@2}
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        sync.nop                             null                             {Compacted,$8.src}
        mov (1|M0)               r6.0<1>:f     r2.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r6.1<1>:d     r5.0<0;0>:d       r44.1<0;0>:d      r1.6<0>:d        {I@1}
        mul (1|M0)               acc0.0<1>:ud  r43.5<0;1,0>:ud   r44.12<0;1,0>:uw
        sync.allrd                           ($3,$9)                
        send.ugm (1|M0)          r7       r6      null:0  0x0            0x0240D780           {A@1,$10} // wr:1+0, rd:4; load.ugm.d64x16t.a64
        mach (1|M0)              r13.0<1>:ud   r43.5<0;1,0>:ud   r44.6<0;1,0>:ud  {AccWrEn}
        xor (1|M0)               r1.2<1>:d     r43.7<0;1,0>:d    1:w              
        mov (1|M0)               r12.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r43.5<0;1,0>:d    r44.14<0;1,0>:uw
        mach (1|M0)              r14.0<1>:d    r43.5<0;1,0>:d    r44.7<0;1,0>:d  
(W)     mul (1|M0)               acc0.0<1>:d   r43.6<0;1,0>:d    r44.12<0;1,0>:uw {Compacted}
        mach (1|M0)              r2.0<1>:d     r43.6<0;1,0>:d    r44.6<0;1,0>:d   {Compacted}
        addc (1|M0)              r5.0<1>:ud    r45.0<0;1,0>:ud   r12.0<0;1,0>:ud  {AccWrEn,I@5}
        shl (1|M0)               r4.1<1>:d     r1.2<0;1,0>:d     12:w              
        add3 (1|M0)              r1.4<1>:d     r2.0<0;0>:d       r13.0<0;0>:d      r14.0<0>:d       {I@3}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$10.src}
        mov (1|M0)               r15.0<1>:f    r5.0<0;1,0>:f                    {Compacted,I@4}
        mad (1|M0)               r11.0<1>:d    r4.1<0;0>:d       r1.0<0;0>:uw      128:w               {I@3}
        add3 (1|M0)              r15.1<1>:d    r6.0<0;0>:d       r45.1<0;0>:d      r1.4<0>:d        {I@2}
        shl (1|M0)               r1.2<1>:d     r1.2<0;1,0>:d     11:w              
        send.slm (1|M0)          null     r11     r7:4    0x0            0x0200D704           {A@3,$10} // wr:1+4, rd:0; store.slm.d64x16t.a32
        sync.nop                             null                             {Compacted,$10.src}
        send.ugm (1|M0)          r7       r15     null:0  0x0            0x0220C780           {A@1,$11} // wr:1+0, rd:2; load.ugm.d64x8t.a64
        add (1|M0)               r9.0<1>:d     r1.2<0;1,0>:d     r43.0<0;1,0>:d   {Compacted,I@1}
        sync.nop                             null                             {Compacted,$11.dst}
        send.slm (1|M0)          null     r9      r7:2    0x0            0x0200C704           {A@1,$9} // wr:1+2, rd:0; store.slm.d64x8t.a32
L2984:
        join (16|M0)                         L3440                                
L3000:
        shl (1|M0)               r1.2<1>:d     r43.7<0;1,0>:d    12:w              
        shl (1|M0)               r43.7<1>:d    r43.7<0;1,0>:d    11:w              
        add (1|M0)               r2.0<1>:d     r1.2<0;1,0>:d     r43.1<0;1,0>:d   {I@2}
        bfn.0xFE (1|M0)          r5.0<1>:ud    0x2000:uw               r43.7<0;0>:ud     r43.2<0>:ud      {I@2} // s0|s1|s2
        bfn.0xFE (1|M0)          r31.0<1>:ud   0x2100:uw               r43.7<0;0>:ud     r43.2<0>:ud      // s0|s1|s2
        sync.nop                             null                             {Compacted,$3.src}
        or (1|M0)                r14.0<1>:ud   r2.0<0;1,0>:ud    0x100:uw              {I@3}
        sync.nop                             null                             {Compacted,$8.src}
        send.slm (1|M0)          r6       r2      null:0  0x0            0x0280E700           {$12} // wr:1+0, rd:8; load.slm.d64x32t.a32
        send.slm (1|M0)          r23      r5      null:0  0x0            0x0280E700           {A@3,$13} // wr:1+0, rd:8; load.slm.d64x32t.a32
        send.slm (1|M0)          r32      r31     null:0  0x0            0x0280E700           {A@2,$14} // wr:1+0, rd:8; load.slm.d64x32t.a32
        send.slm (1|M0)          r15      r14     null:0  0x0            0x0280E700           {A@1,$15} // wr:1+0, rd:8; load.slm.d64x32t.a32
        sync.allwr                           ($8,$12,$13,$14,$15)                
        dpas.8x8 (8|M0)          r70:d         r70:d             r23:b             r6.0:b           {Atomic}
        dpas.8x8 (8|M0)          r62:d         r62:d             r32:b             r6.0:b           {Atomic}
        dpas.8x8 (8|M0)          r54:d         r54:d             r23:b             r15.0:b          {Atomic}
        dpas.8x8 (8|M0)          r46:d         r46:d             r32:b             r15.0:b          {$8}
(W)     send.slm (1|M0)          r40      r0      null:0  0x0            0x0210001F           {$0} // wr:1+0, rd:1; fence.slm.none.group
(W)     mov (1|M0)               r41.2<1>:f    0.0:f                               {Compacted,$7.src}
(W)     mov (2|M0)               r41.10<1>:ub  r0.11<0;1,0>:ub                  {F@1}
(W)     mov (8|M0)               null<1>:ud    r40.0<1;1,0>:ud                  {$0.dst}
(W)     send.gtwy (1|M0)         null     r41     null:0  0x0            0x02000004           {A@2,$7} // wr:1+0, rd:0; signal barrier
(W)     sync.bar                             null                            
        cmp (1|M0)    (eq)f0.1   null<1>:d     r44.7<0;1,0>:d    r44.3<0;1,0>:d  
(f0.1)  cmp (1|M0)    (eq)f0.1   null<1>:d     r44.6<0;1,0>:d    r44.2<0;1,0>:d  
(W)     and (1|M0)               f0.0<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(f0.0.any16h) goto (16|M0)                   L3440                  L3440                
L3408:
(W)     mov (2|M0)               r44.4<1>:ud   r44.6<1;1,0>:ud                 
        goto.b (16|M0)                       L3440                  L2328                
L3440:
        join (16|M0)                         L3456                                
L3456:
        shl (1|M0)               r42.1<1>:d    r42.1<0;1,0>:d    6:w               {Compacted}
        shl (1|M0)               r42.3<1>:d    r42.3<0;1,0>:d    4:w               {Compacted}
        shl (1|M0)               r45.2<1>:d    r45.2<0;1,0>:d    7:w              
        or (1|M0)                r1.2<1>:d     r42.1<0;1,0>:d    r42.3<0;1,0>:d   {I@2}
        shl (1|M0)               r42.2<1>:ud   r42.2<0;1,0>:ud   0x4:uw             
        shl (1|M0)               r2.0<1>:d     r1.2<0;1,0>:d     2:w               {Compacted,I@2}
        add (1|M0)               r45.2<1>:d    r45.2<0;1,0>:d    r42.2<0;1,0>:d   {I@2}
        sync.nop                             null                             {Compacted,$6.src}
        addc (1|M0)              r5.0<1>:ud    r42.5<0;1,0>:ud   r2.0<0;1,0>:ud   {AccWrEn,I@2}
        shr (1|M0)               r1.4<1>:ud    r1.2<0;1,0>:ud    0x1E:uw             
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$8.src}
        mul (1|M0)               acc0.0<1>:d   r45.2<0;1,0>:d    r2.6<0;1,0>:uw   {I@4}
        mach (1|M0)              r12.0<1>:d    r45.2<0;1,0>:d    r2.3<0;1,0>:d    {AccWrEn}
        or (1|M0)                r5.1<1>:d     r45.2<0;1,0>:d    8:w              
        mov (1|M0)               r11.0<1>:d    acc0.0<0;1,0>:d                 
        or (1|M0)                r2.1<1>:d     r1.4<0;1,0>:d     0:w               {I@6}
        shl (1|M0)               r1.3<1>:d     r11.0<0;1,0>:d    2:w               {Compacted,I@2}
        add3 (1|M0)              r4.2<1>:d     r6.0<0;0>:d       r42.6<0;0>:d      r2.1<0>:d        {I@2}
        addc (1|M0)              r2.0<1>:ud    r5.0<0;1,0>:ud    r1.3<0;1,0>:ud   {AccWrEn,I@2}
        shl (1|M0)               r4.3<1>:d     r12.0<0;1,0>:d    2:w               {Compacted}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mul (1|M0)               acc0.0<1>:d   r5.1<0;1,0>:d     r2.6<0;1,0>:uw  
        mach (1|M0)              r15.0<1>:d    r5.1<0;1,0>:d     r2.3<0;1,0>:d    {AccWrEn,$3.src}
        shr (1|M0)               r1.2<1>:ud    r11.0<0;1,0>:ud   0x1E:uw             
        mov (1|M0)               r14.0<1>:d    acc0.0<0;1,0>:d                 
        or (1|M0)                r1.4<1>:d     r4.3<0;1,0>:d     r1.2<0;1,0>:d    {I@2}
        shl (1|M0)               r4.3<1>:d     r14.0<0;1,0>:d    2:w               {Compacted,I@2}
        or (1|M0)                r1.2<1>:d     r45.2<0;1,0>:d    1:w              
        addc (1|M0)              r12.0<1>:ud   r5.0<0;1,0>:ud    r4.3<0;1,0>:ud   {AccWrEn,I@2}
        mov (1|M0)               r13.0<1>:f    r2.0<0;1,0>:f                    {Compacted}
        mov (1|M0)               r2.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,F@1}
        mul (1|M0)               acc0.0<1>:d   r1.2<0;1,0>:d     r2.6<0;1,0>:uw   {I@3}
        sync.nop                             null                             {Compacted,$8.dst}
        mov (8|M0)               r7.0<1>:f     r70.0<1;1,0>:f                   {Compacted,$9.src}
        mov (8|M0)               r8.0<1>:f     r62.0<1;1,0>:f                   {Compacted}
        shl (1|M0)               r16.0<1>:d    r15.0<0;1,0>:d    2:w               {Compacted}
        shr (1|M0)               r11.0<1>:ud   r14.0<0;1,0>:ud   0x1E:uw             
        add3 (1|M0)              r13.1<1>:d    r6.0<0;0>:d       r4.2<0;0>:d       r1.4<0>:d       
        mach (1|M0)              r14.0<1>:d    r1.2<0;1,0>:d     r2.3<0;1,0>:d    {AccWrEn}
        send.ugm (1|M0)          null     r13     r7:2    0x0            0x0200C784           {A@1,$1} // wr:1+2, rd:0; store.ugm.d64x8t.a64
        or (1|M0)                r4.4<1>:d     r16.0<0;1,0>:d    r11.0<0;1,0>:d   {Compacted}
        mov (1|M0)               r13.0<1>:d    acc0.0<0;1,0>:d                  {$1.src}
        mov (8|M0)               r9.0<1>:f     r54.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r10.0<1>:f    r46.0<1;1,0>:f                   {Compacted}
        mov (1|M0)               r6.0<1>:f     r12.0<0;1,0>:f                   {Compacted}
        add3 (1|M0)              r6.1<1>:d     r2.0<0;0>:d       r4.2<0;0>:d       r4.4<0>:d        {I@2}
        shl (1|M0)               r2.0<1>:d     r13.0<0;1,0>:d    2:w               {Compacted,I@2}
        send.ugm (1|M0)          null     r6      r9:2    0x0            0x0200C784           {A@1,$2} // wr:1+2, rd:0; store.ugm.d64x8t.a64
        or (1|M0)                r4.3<1>:d     r45.2<0;1,0>:d    9:w              
        sync.nop                             null                             {Compacted,$2.src}
        addc (1|M0)              r6.0<1>:ud    r5.0<0;1,0>:ud    r2.0<0;1,0>:ud   {AccWrEn,I@2}
        shr (1|M0)               r5.2<1>:ud    r13.0<0;1,0>:ud   0x1E:uw             
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mul (1|M0)               acc0.0<1>:d   r4.3<0;1,0>:d     r2.6<0;1,0>:uw   {I@4}
        mach (1|M0)              r12.0<1>:d    r4.3<0;1,0>:d     r2.3<0;1,0>:d    {AccWrEn}
        or (1|M0)                r4.3<1>:d     r45.2<0;1,0>:d    2:w              
        mov (1|M0)               r11.0<1>:d    acc0.0<0;1,0>:d                 
        mov (1|M0)               r10.0<1>:f    r6.0<0;1,0>:f                    {Compacted,I@7}
        shl (1|M0)               r1.4<1>:d     r11.0<0;1,0>:d    2:w               {Compacted,I@1}
        shl (1|M0)               r5.1<1>:d     r14.0<0;1,0>:d    2:w               {Compacted}
        addc (1|M0)              r13.0<1>:ud   r5.0<0;1,0>:ud    r1.4<0;1,0>:ud   {AccWrEn,I@2}
        shl (1|M0)               r1.2<1>:d     r12.0<0;1,0>:d    2:w               {Compacted}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,F@1}
        mul (1|M0)               acc0.0<1>:d   r4.3<0;1,0>:d     r2.6<0;1,0>:uw  
        shr (1|M0)               r1.3<1>:ud    r11.0<0;1,0>:ud   0x1E:uw             
        mach (1|M0)              r12.0<1>:d    r4.3<0;1,0>:d     r2.3<0;1,0>:d    {AccWrEn}
        or (1|M0)                r2.1<1>:d     r5.1<0;1,0>:d     r5.2<0;1,0>:d    {I@7}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@3}
        mov (1|M0)               r11.0<1>:d    acc0.0<0;1,0>:d                 
        mov (8|M0)               r17.0<1>:f    r55.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r18.0<1>:f    r47.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r7.0<1>:f     r71.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r8.0<1>:f     r63.0<1;1,0>:f                   {Compacted}
        mov (1|M0)               r2.0<1>:f     r13.0<0;1,0>:f                   {Compacted}
        add3 (1|M0)              r10.1<1>:d    r9.0<0;0>:d       r4.2<0;0>:d       r2.1<0>:d        {I@3}
        shl (1|M0)               r1.2<1>:d     r11.0<0;1,0>:d    2:w               {Compacted,I@2}
        add3 (1|M0)              r2.1<1>:d     r6.0<0;0>:d       r4.2<0;0>:d       r1.5<0>:d       
        send.ugm (1|M0)          null     r10     r7:2    0x0            0x0200C784           {A@2,$3} // wr:1+2, rd:0; store.ugm.d64x8t.a64
        send.ugm (1|M0)          null     r2      r17:2   0x0            0x0200C784           {A@1,$4} // wr:1+2, rd:0; store.ugm.d64x8t.a64
        or (1|M0)                r14.0<1>:d    r45.2<0;1,0>:d    10:w               {Compacted}
        addc (1|M0)              r2.0<1>:ud    r5.0<0;1,0>:ud    r1.2<0;1,0>:ud   {AccWrEn,$4.src}
        shr (1|M0)               r5.2<1>:ud    r11.0<0;1,0>:ud   0x1E:uw             
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mul (1|M0)               acc0.0<1>:d   r14.0<0;1,0>:d    r2.6<0;1,0>:uw   {Compacted,I@4}
        mach (1|M0)              r16.0<1>:d    r14.0<0;1,0>:d    r2.3<0;1,0>:d    {AccWrEn}
        or (1|M0)                r1.2<1>:d     r45.2<0;1,0>:d    3:w              
        mov (1|M0)               r15.0<1>:d    acc0.0<0;1,0>:d                 
        mov (1|M0)               r13.0<1>:f    r2.0<0;1,0>:f                    {Compacted,I@7}
        shl (1|M0)               r4.5<1>:d     r15.0<0;1,0>:d    2:w               {Compacted,I@1}
        shl (1|M0)               r5.1<1>:d     r12.0<0;1,0>:d    2:w               {Compacted}
        addc (1|M0)              r11.0<1>:ud   r5.0<0;1,0>:ud    r4.5<0;1,0>:ud   {AccWrEn,I@2}
        shl (1|M0)               r4.3<1>:d     r16.0<0;1,0>:d    2:w               {Compacted}
        mov (1|M0)               r2.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,F@1}
        mul (1|M0)               acc0.0<1>:d   r1.2<0;1,0>:d     r2.6<0;1,0>:uw  
        shr (1|M0)               r4.4<1>:ud    r15.0<0;1,0>:ud   0x1E:uw             
        mach (1|M0)              r15.0<1>:d    r1.2<0;1,0>:d     r2.3<0;1,0>:d    {AccWrEn}
        or (1|M0)                r1.3<1>:d     r5.1<0;1,0>:d     r5.2<0;1,0>:d    {I@7}
        or (1|M0)                r4.6<1>:d     r4.3<0;1,0>:d     r4.4<0;1,0>:d    {I@3}
        mov (1|M0)               r14.0<1>:d    acc0.0<0;1,0>:d                 
        mov (8|M0)               r9.0<1>:f     r56.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r7.0<1>:f     r72.0<1;1,0>:f                   {Compacted,$3.src}
        mov (8|M0)               r8.0<1>:f     r64.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r10.0<1>:f    r48.0<1;1,0>:f                   {Compacted}
        add3 (1|M0)              r13.1<1>:d    r6.0<0;0>:d       r4.2<0;0>:d       r1.3<0>:d        {I@3}
        add3 (1|M0)              r6.1<1>:d     r2.0<0;0>:d       r4.2<0;0>:d       r4.6<0>:d        {I@3}
        mov (1|M0)               r6.0<1>:f     r11.0<0;1,0>:f                   {Compacted,I@2}
        shl (1|M0)               r2.0<1>:d     r14.0<0;1,0>:d    2:w               {Compacted}
        send.ugm (1|M0)          null     r13     r7:2    0x0            0x0200C784           {A@3,$5} // wr:1+2, rd:0; store.ugm.d64x8t.a64
        send.ugm (1|M0)          null     r6      r9:2    0x0            0x0200C784           {A@1,$6} // wr:1+2, rd:0; store.ugm.d64x8t.a64
        or (1|M0)                r4.3<1>:d     r45.2<0;1,0>:d    11:w              
        sync.nop                             null                             {Compacted,$6.src}
        addc (1|M0)              r6.0<1>:ud    r5.0<0;1,0>:ud    r2.0<0;1,0>:ud   {AccWrEn,I@2}
        shl (1|M0)               r5.1<1>:d     r15.0<0;1,0>:d    2:w               {Compacted}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mul (1|M0)               acc0.0<1>:d   r4.3<0;1,0>:d     r2.6<0;1,0>:uw   {I@4}
        mach (1|M0)              r17.0<1>:d    r4.3<0;1,0>:d     r2.3<0;1,0>:d    {AccWrEn}
        or (1|M0)                r4.3<1>:d     r45.2<0;1,0>:d    4:w              
        mov (1|M0)               r16.0<1>:d    acc0.0<0;1,0>:d                 
        mov (1|M0)               r10.0<1>:f    r6.0<0;1,0>:f                    {Compacted,I@7}
        shl (1|M0)               r1.4<1>:d     r16.0<0;1,0>:d    2:w               {Compacted,I@1}
        shr (1|M0)               r5.2<1>:ud    r14.0<0;1,0>:ud   0x1E:uw             
        addc (1|M0)              r11.0<1>:ud   r5.0<0;1,0>:ud    r1.4<0;1,0>:ud   {AccWrEn,I@2}
        shl (1|M0)               r1.2<1>:d     r17.0<0;1,0>:d    2:w               {Compacted}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,F@1}
        mul (1|M0)               acc0.0<1>:d   r4.3<0;1,0>:d     r2.6<0;1,0>:uw  
        shr (1|M0)               r1.3<1>:ud    r16.0<0;1,0>:ud   0x1E:uw             
        mach (1|M0)              r15.0<1>:d    r4.3<0;1,0>:d     r2.3<0;1,0>:d    {AccWrEn}
        or (1|M0)                r2.1<1>:d     r5.1<0;1,0>:d     r5.2<0;1,0>:d    {I@7}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@3}
        mov (1|M0)               r14.0<1>:d    acc0.0<0;1,0>:d                 
        mov (8|M0)               r12.0<1>:f    r57.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r7.0<1>:f     r73.0<1;1,0>:f                   {Compacted,$5.src}
        mov (8|M0)               r8.0<1>:f     r65.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r13.0<1>:f    r49.0<1;1,0>:f                   {Compacted}
        mov (1|M0)               r2.0<1>:f     r11.0<0;1,0>:f                   {Compacted}
        add3 (1|M0)              r10.1<1>:d    r9.0<0;0>:d       r4.2<0;0>:d       r2.1<0>:d        {I@3}
        shl (1|M0)               r1.2<1>:d     r14.0<0;1,0>:d    2:w               {Compacted,I@2}
        add3 (1|M0)              r2.1<1>:d     r6.0<0;0>:d       r4.2<0;0>:d       r1.5<0>:d       
        send.ugm (1|M0)          null     r10     r7:2    0x0            0x0200C784           {A@3,$7} // wr:1+2, rd:0; store.ugm.d64x8t.a64
        send.ugm (1|M0)          null     r2      r12:2   0x0            0x0200C784           {A@1,$8} // wr:1+2, rd:0; store.ugm.d64x8t.a64
        addc (1|M0)              r2.0<1>:ud    r5.0<0;1,0>:ud    r1.2<0;1,0>:ud   {AccWrEn,$8.src}
        or (1|M0)                r12.0<1>:d    r45.2<0;1,0>:d    12:w               {Compacted}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mul (1|M0)               acc0.0<1>:d   r12.0<0;1,0>:d    r2.6<0;1,0>:uw   {Compacted,I@2}
        mach (1|M0)              r17.0<1>:d    r12.0<0;1,0>:d    r2.3<0;1,0>:d    {AccWrEn}
        or (1|M0)                r1.2<1>:d     r45.2<0;1,0>:d    5:w              
        mov (1|M0)               r16.0<1>:d    acc0.0<0;1,0>:d                 
        mov (1|M0)               r11.0<1>:f    r2.0<0;1,0>:f                    {Compacted}
        shl (1|M0)               r4.5<1>:d     r16.0<0;1,0>:d    2:w               {Compacted,I@1}
        shl (1|M0)               r5.1<1>:d     r15.0<0;1,0>:d    2:w               {Compacted}
        addc (1|M0)              r13.0<1>:ud   r5.0<0;1,0>:ud    r4.5<0;1,0>:ud   {AccWrEn,I@2}
        shr (1|M0)               r5.2<1>:ud    r14.0<0;1,0>:ud   0x1E:uw             
        mov (1|M0)               r2.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,F@1}
        mul (1|M0)               acc0.0<1>:d   r1.2<0;1,0>:d     r2.6<0;1,0>:uw  
        shl (1|M0)               r4.3<1>:d     r17.0<0;1,0>:d    2:w               {Compacted}
        shr (1|M0)               r4.4<1>:ud    r16.0<0;1,0>:ud   0x1E:uw             
        mach (1|M0)              r15.0<1>:d    r1.2<0;1,0>:d     r2.3<0;1,0>:d    {AccWrEn}
        or (1|M0)                r1.3<1>:d     r5.1<0;1,0>:d     r5.2<0;1,0>:d    {I@6}
        or (1|M0)                r4.6<1>:d     r4.3<0;1,0>:d     r4.4<0;1,0>:d    {I@3}
        mov (1|M0)               r14.0<1>:d    acc0.0<0;1,0>:d                 
        mov (8|M0)               r9.0<1>:f     r58.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r7.0<1>:f     r74.0<1;1,0>:f                   {Compacted,$7.src}
        mov (8|M0)               r8.0<1>:f     r66.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r10.0<1>:f    r50.0<1;1,0>:f                   {Compacted}
        add3 (1|M0)              r11.1<1>:d    r6.0<0;0>:d       r4.2<0;0>:d       r1.3<0>:d        {I@3}
        add3 (1|M0)              r6.1<1>:d     r2.0<0;0>:d       r4.2<0;0>:d       r4.6<0>:d        {I@3}
        mov (1|M0)               r6.0<1>:f     r13.0<0;1,0>:f                   {Compacted,I@2}
        shl (1|M0)               r2.0<1>:d     r14.0<0;1,0>:d    2:w               {Compacted}
        send.ugm (1|M0)          null     r11     r7:2    0x0            0x0200C784           {A@3,$9} // wr:1+2, rd:0; store.ugm.d64x8t.a64
        send.ugm (1|M0)          null     r6      r9:2    0x0            0x0200C784           {A@1,$10} // wr:1+2, rd:0; store.ugm.d64x8t.a64
        or (1|M0)                r4.3<1>:d     r45.2<0;1,0>:d    13:w              
        sync.nop                             null                             {Compacted,$10.src}
        addc (1|M0)              r6.0<1>:ud    r5.0<0;1,0>:ud    r2.0<0;1,0>:ud   {AccWrEn,I@2}
        shl (1|M0)               r5.1<1>:d     r15.0<0;1,0>:d    2:w               {Compacted}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mul (1|M0)               acc0.0<1>:d   r4.3<0;1,0>:d     r2.6<0;1,0>:uw   {I@4}
        mach (1|M0)              r17.0<1>:d    r4.3<0;1,0>:d     r2.3<0;1,0>:d    {AccWrEn}
        or (1|M0)                r4.3<1>:d     r45.2<0;1,0>:d    6:w              
        mov (1|M0)               r16.0<1>:d    acc0.0<0;1,0>:d                 
        mov (1|M0)               r10.0<1>:f    r6.0<0;1,0>:f                    {Compacted,I@7}
        shl (1|M0)               r1.4<1>:d     r16.0<0;1,0>:d    2:w               {Compacted,I@1}
        shr (1|M0)               r5.2<1>:ud    r14.0<0;1,0>:ud   0x1E:uw             
        addc (1|M0)              r13.0<1>:ud   r5.0<0;1,0>:ud    r1.4<0;1,0>:ud   {AccWrEn,I@2}
        shl (1|M0)               r1.2<1>:d     r17.0<0;1,0>:d    2:w               {Compacted}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,F@1}
        mul (1|M0)               acc0.0<1>:d   r4.3<0;1,0>:d     r2.6<0;1,0>:uw  
        shr (1|M0)               r1.3<1>:ud    r16.0<0;1,0>:ud   0x1E:uw             
        mach (1|M0)              r15.0<1>:d    r4.3<0;1,0>:d     r2.3<0;1,0>:d    {AccWrEn}
        or (1|M0)                r2.1<1>:d     r5.1<0;1,0>:d     r5.2<0;1,0>:d    {I@7}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@3}
        mov (1|M0)               r14.0<1>:d    acc0.0<0;1,0>:d                 
        mov (8|M0)               r12.0<1>:f    r51.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r7.0<1>:f     r75.0<1;1,0>:f                   {Compacted,$9.src}
        mov (8|M0)               r8.0<1>:f     r67.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r11.0<1>:f    r59.0<1;1,0>:f                   {Compacted}
        mov (1|M0)               r2.0<1>:f     r13.0<0;1,0>:f                   {Compacted}
        add3 (1|M0)              r10.1<1>:d    r9.0<0;0>:d       r4.2<0;0>:d       r2.1<0>:d        {I@3}
        shl (1|M0)               r1.2<1>:d     r14.0<0;1,0>:d    2:w               {Compacted,I@2}
        add3 (1|M0)              r2.1<1>:d     r6.0<0;0>:d       r4.2<0;0>:d       r1.5<0>:d       
        send.ugm (1|M0)          null     r10     r7:2    0x0            0x0200C784           {A@3,$11} // wr:1+2, rd:0; store.ugm.d64x8t.a64
        send.ugm (1|M0)          null     r2      r11:2   0x0            0x0200C784           {A@1,$12} // wr:1+2, rd:0; store.ugm.d64x8t.a64
        addc (1|M0)              r2.0<1>:ud    r5.0<0;1,0>:ud    r1.2<0;1,0>:ud   {AccWrEn,$12.src}
        or (1|M0)                r12.0<1>:d    r45.2<0;1,0>:d    14:w               {Compacted}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mul (1|M0)               acc0.0<1>:d   r12.0<0;1,0>:d    r2.6<0;1,0>:uw   {Compacted,I@2}
        mach (1|M0)              r17.0<1>:d    r12.0<0;1,0>:d    r2.3<0;1,0>:d    {AccWrEn}
        or (1|M0)                r1.2<1>:d     r45.2<0;1,0>:d    7:w              
        mov (1|M0)               r16.0<1>:d    acc0.0<0;1,0>:d                 
        mov (1|M0)               r11.0<1>:f    r2.0<0;1,0>:f                    {Compacted}
        shl (1|M0)               r4.5<1>:d     r16.0<0;1,0>:d    2:w               {Compacted,I@1}
        shl (1|M0)               r5.1<1>:d     r15.0<0;1,0>:d    2:w               {Compacted}
        addc (1|M0)              r13.0<1>:ud   r5.0<0;1,0>:ud    r4.5<0;1,0>:ud   {AccWrEn,I@2}
        shr (1|M0)               r5.2<1>:ud    r14.0<0;1,0>:ud   0x1E:uw             
        mov (1|M0)               r2.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,F@1}
        mul (1|M0)               acc0.0<1>:d   r1.2<0;1,0>:d     r2.6<0;1,0>:uw  
        shl (1|M0)               r4.3<1>:d     r17.0<0;1,0>:d    2:w               {Compacted}
        shr (1|M0)               r4.4<1>:ud    r16.0<0;1,0>:ud   0x1E:uw             
        mach (1|M0)              r15.0<1>:d    r1.2<0;1,0>:d     r2.3<0;1,0>:d    {AccWrEn}
        or (1|M0)                r1.3<1>:d     r5.1<0;1,0>:d     r5.2<0;1,0>:d    {I@6}
        or (1|M0)                r4.6<1>:d     r4.3<0;1,0>:d     r4.4<0;1,0>:d    {I@3}
        mov (1|M0)               r14.0<1>:d    acc0.0<0;1,0>:d                 
        mov (8|M0)               r9.0<1>:f     r60.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r7.0<1>:f     r76.0<1;1,0>:f                   {Compacted,$11.src}
        mov (8|M0)               r8.0<1>:f     r68.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r10.0<1>:f    r52.0<1;1,0>:f                   {Compacted}
        add3 (1|M0)              r11.1<1>:d    r6.0<0;0>:d       r4.2<0;0>:d       r1.3<0>:d        {I@3}
        add3 (1|M0)              r6.1<1>:d     r2.0<0;0>:d       r4.2<0;0>:d       r4.6<0>:d        {I@3}
        mov (1|M0)               r6.0<1>:f     r13.0<0;1,0>:f                   {Compacted,I@2}
        shl (1|M0)               r2.0<1>:d     r14.0<0;1,0>:d    2:w               {Compacted}
        send.ugm (1|M0)          null     r11     r7:2    0x0            0x0200C784           {A@3,$13} // wr:1+2, rd:0; store.ugm.d64x8t.a64
        send.ugm (1|M0)          null     r6      r9:2    0x0            0x0200C784           {A@1,$14} // wr:1+2, rd:0; store.ugm.d64x8t.a64
        or (1|M0)                r45.2<1>:d    r45.2<0;1,0>:d    15:w              
        sync.nop                             null                             {Compacted,$14.src}
        addc (1|M0)              r6.0<1>:ud    r5.0<0;1,0>:ud    r2.0<0;1,0>:ud   {AccWrEn,I@2}
        shl (1|M0)               r5.1<1>:d     r15.0<0;1,0>:d    2:w               {Compacted}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mul (1|M0)               acc0.0<1>:d   r45.2<0;1,0>:d    r2.6<0;1,0>:uw   {I@4}
        mach (1|M0)              r17.0<1>:d    r45.2<0;1,0>:d    r2.3<0;1,0>:d    {AccWrEn}
        shr (1|M0)               r5.2<1>:ud    r14.0<0;1,0>:ud   0x1E:uw             
        mov (1|M0)               r16.0<1>:d    acc0.0<0;1,0>:d                 
        shl (1|M0)               r1.2<1>:d     r17.0<0;1,0>:d    2:w               {Compacted,I@3}
        shl (1|M0)               r1.4<1>:d     r16.0<0;1,0>:d    2:w               {Compacted,I@2}
        shr (1|M0)               r1.3<1>:ud    r16.0<0;1,0>:ud   0x1E:uw             
        addc (1|M0)              r13.0<1>:ud   r5.0<0;1,0>:ud    r1.4<0;1,0>:ud   {AccWrEn,I@2}
        mov (1|M0)               r10.0<1>:f    r6.0<0;1,0>:f                    {Compacted}
        or (1|M0)                r2.1<1>:d     r5.1<0;1,0>:d     r5.2<0;1,0>:d   
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@3}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,F@1}
        mov (8|M0)               r12.0<1>:f    r53.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r7.0<1>:f     r77.0<1;1,0>:f                   {Compacted,$13.src}
        mov (8|M0)               r8.0<1>:f     r69.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r11.0<1>:f    r61.0<1;1,0>:f                   {Compacted}
        mov (1|M0)               r2.0<1>:f     r13.0<0;1,0>:f                   {Compacted,I@4}
        add3 (1|M0)              r10.1<1>:d    r9.0<0;0>:d       r4.2<0;0>:d       r2.1<0>:d        {I@3}
        add3 (1|M0)              r2.1<1>:d     r6.0<0;0>:d       r4.2<0;0>:d       r1.5<0>:d        {I@2}
        send.ugm (1|M0)          null     r10     r7:2    0x0            0x0200C784           {A@2,$15} // wr:1+2, rd:0; store.ugm.d64x8t.a64
        send.ugm (1|M0)          null     r2      r11:2   0x0            0x0200C784           {A@1,$0} // wr:1+2, rd:0; store.ugm.d64x8t.a64
(W)     mov (8|M0)               r127.0<1>:f   r0.0<1;1,0>:f                    {Compacted}
        sync.nop                             null                             {Compacted,$15.src}
(W)     send.ugm (1|M0)          r7       r0      null:0  0x0            0x0210641F           {$1} // wr:1+0, rd:1; fence invalid flush type scoped to tile
(W)     mov (8|M0)               null<1>:ud    r7.0<1;1,0>:ud                   {$1.dst}
(W)     send.gtwy (1|M0)         null     r127    null:0  0x0            0x02000010           {EOT,A@1} // wr:1+0, rd:0; end of thread
L6728:
        mov (1|M0)               r1.2<1>:d     cr0.0<0;1,0>:ud                  {A@1}
        and (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   -1265:w               {A@1}
        or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   1264:w               {A@1}
        mov (1|M0)               r1.5<1>:f     (abs)r45.5<0;1,0>:d              {A@1}
        mov (1|M0)               r5.2<1>:f     0xB4C00000:f                               {Compacted}
        math.inv (1|M0)          r5.1<1>:f     r1.5<0;1,0>:f                    {@2,$2}
        mov (1|M0)               r2.1<1>:f     (abs)r45.4<0;1,0>:d             
        sync.nop                             null                             {Compacted,$2.dst}
        mad (1|M0)               r5.1<1>:f     r5.1<0;0>:f       r5.2<0;0>:f       r5.1<0>:f        {F@2}
        mov (1|M0)               r1.3<1>:d     (abs)r45.4<0;1,0>:d             
        mov (1|M0)               r1.4<1>:d     (abs)r45.5<0;1,0>:d             
        mov (1|M0)               r1.6<1>:ud    r1.5<0;1,0>:f                   
        mov (1|M0)               r4.1<1>:ud    r2.1<0;1,0>:f                    {F@2}
        mul (1|M0)               r6.0<1>:f     r5.1<0;1,0>:f     r2.1<0;1,0>:f    {F@1}
        add (1|M0)               r1.6<1>:ud    r1.4<0;1,0>:ud    -r1.6<0;1,0>:ud  {I@2}
        add (1|M0)               r4.1<1>:ud    r1.3<0;1,0>:ud    -r4.1<0;1,0>:ud  {I@2}
        mov (1|M0)               r7.0<1>:ud    r6.0<0;1,0>:f                    {F@1}
        mov (1|M0)               r2.0<1>:f     r1.6<0;1,0>:ud                   {Compacted,I@3}
        mov (1|M0)               r5.0<1>:f     r4.1<0;1,0>:ud                   {Compacted,I@2}
        mov (1|M0)               r7.1<1>:f     r7.0<0;1,0>:ud                   {Compacted,I@1}
        xor (1|M0)               r45.5<1>:d    r45.5<0;1,0>:d    r45.4<0;1,0>:d  
        mad (1|M0)               r2.1<1>:f     r2.1<0;0>:f       r7.1<0;0>:f       -r1.5<0>:f       {F@1}
        mad (1|M0)               r7.1<1>:f     r5.0<0;0>:f       r7.1<0;0>:f       -r2.0<0>:f      
(W)     mov (1|M0)               r4.2<1>:hf    0x1:hf                             
        add (1|M0)               r2.1<1>:f     r2.1<0;1,0>:f     r7.1<0;1,0>:f    {F@2}
        asr (1|M0)               r45.5<1>:d    r45.5<0;1,0>:d    31:w               {I@1}
        mul (1|M0)               r5.1<1>:f     r5.1<0;1,0>:f     r2.1<0;1,0>:f    {F@1}
        mov (1|M0)               r8.0<1>:ud    r5.1<0;1,0>:f                    {F@1}
        add (1|M0)               r7.0<1>:ud    r7.0<0;1,0>:ud    r8.0<0;1,0>:ud   {Compacted,I@1}
(W)     mul (1|M0)               acc0.0<1>:ud  r7.0<0;1,0>:ud    r1.8<0;1,0>:uw   {I@1}
        mach (1|M0)              r9.0<1>:ud    r7.0<0;1,0>:ud    r1.4<0;1,0>:ud   {Compacted}
        add (1|M0)               r1.3<1>:ud    r1.3<0;1,0>:ud    -r9.0<0;1,0>:ud  {Compacted,I@1}
        cmp (1|M0)    (ge)f1.1   null<1>:ud    r1.3<0;1,0>:ud    r1.4<0;1,0>:ud   {I@1}
(f1.1)  sel (1|M0)               r6.0<1>:d     r4.2<0;1,0>:w     0:w              
        add3 (1|M0)              r7.0<1>:d     r7.0<0;0>:d       r45.5<0;0>:d      r6.0<0>:d        {I@1}
        xor (1|M0)               r45.2<1>:d    r7.0<0;1,0>:d     r45.5<0;1,0>:d   {I@1}
        mov (1|M0)               cr0.0<1>:ud   r1.2<0;1,0>:d                    {A@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        ret (16|M0)                          r45.6                            {A@1}
L7304:
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
