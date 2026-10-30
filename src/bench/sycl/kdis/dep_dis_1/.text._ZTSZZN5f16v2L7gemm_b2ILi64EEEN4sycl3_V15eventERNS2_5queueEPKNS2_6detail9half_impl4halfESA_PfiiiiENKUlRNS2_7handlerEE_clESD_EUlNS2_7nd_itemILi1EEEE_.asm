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
        mov (1|M0)               r78.4<1>:d    r0.1<0;1,0>:ud                   {A@1}
        mov (1|M0)               r42.0<1>:d    r1.0<0;1,0>:uw                   {$0.dst}
        mov (1|M0)               r78.1<1>:d    r2.2<0;1,0>:d                    {$1.dst}
        mov (1|M0)               r78.0<1>:d    r78.4<0;1,0>:d                   {I@3}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r78.2         L7920                                 {A@1}
L352:
        asr (1|M0)               r78.5<1>:d    r2.3<0;1,0>:d     31:w              
        mov (1|M0)               r42.1<1>:d    r45.6<0;1,0>:d                  
        shr (1|M0)               r78.5<1>:ud   r78.5<0;1,0>:ud   0x1A:uw              {I@2}
(W)     mul (1|M0)               acc0.0<1>:d   r42.1<0;1,0>:d    r2.4<0;1,0>:uw   {I@2}
        mach (1|M0)              r2.0<1>:d     r42.1<0;1,0>:d    r2.2<0;1,0>:d   
        add (1|M0)               r78.5<1>:d    r2.3<0;1,0>:d     r78.5<0;1,0>:d   {I@3}
        add (1|M0)               r78.4<1>:d    r78.4<0;1,0>:d    -r2.0<0;1,0>:d   {I@2}
        asr (1|M0)               r78.5<1>:d    r78.5<0;1,0>:d    6:w               {I@2}
        mov (2|M0)               r78.0<1>:d    r78.4<1;1,0>:d                   {I@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r78.2         L7920                                 {A@1}
L544:
        mov (1|M0)               r1.2<1>:d     r42.1<0;1,0>:d                  
(W)     mul (1|M0)               acc0.0<1>:d   r45.6<0;1,0>:d    r78.10<0;1,0>:uw
(W)     mach (1|M0)              r2.0<1>:d     r45.6<0;1,0>:d    r78.5<0;1,0>:d  
        mul (1|M0)               acc0.0<1>:ud  r1.2<0;1,0>:ud    r2.12<0;1,0>:uw  {I@3}
        mach (1|M0)              r6.0<1>:ud    r1.2<0;1,0>:ud    r2.6<0;1,0>:ud   {AccWrEn}
        asr (1|M0)               r1.3<1>:d     r42.1<0;1,0>:d    31:w              
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r1.2<0;1,0>:d     r2.14<0;1,0>:uw 
        shl (1|M0)               r4.4<1>:d     r5.0<0;1,0>:d     1:w               {Compacted,I@2}
        mach (1|M0)              r7.0<1>:d     r1.2<0;1,0>:d     r2.7<0;1,0>:d   
(W)     mul (1|M0)               acc0.0<1>:d   r1.3<0;1,0>:d     r2.12<0;1,0>:uw 
        mov (1|M0)               r78.5<1>:d    r2.0<0;1,0>:d                   
        mach (1|M0)              r2.0<1>:d     r1.3<0;1,0>:d     r2.6<0;1,0>:d   
        addc (1|M0)              r8.0<1>:ud    r2.4<0;1,0>:ud    r4.4<0;1,0>:ud   {AccWrEn,I@5}
        add3 (1|M0)              r1.5<1>:d     r2.0<0;0>:d       r6.0<0;0>:d       r7.0<0>:d        {I@2}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mul (1|M0)               acc0.0<1>:ud  r1.2<0;1,0>:ud    r3.4<0;1,0>:uw  
        mach (1|M0)              r11.0<1>:ud   r1.2<0;1,0>:ud    r3.2<0;1,0>:ud   {AccWrEn}
        shr (1|M0)               r4.3<1>:ud    r5.0<0;1,0>:ud    0x1F:uw             
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r1.2<0;1,0>:d     r3.6<0;1,0>:uw  
        shl (1|M0)               r6.2<1>:d     r10.0<0;1,0>:d    1:w               {Compacted,I@2}
        mach (1|M0)              r2.0<1>:d     r1.2<0;1,0>:d     r3.3<0;1,0>:d   
(W)     mul (1|M0)               acc0.0<1>:d   r1.3<0;1,0>:d     r3.4<0;1,0>:uw  
        mach (1|M0)              r5.0<1>:d     r1.3<0;1,0>:d     r3.2<0;1,0>:d   
        addc (1|M0)              r7.0<1>:ud    r3.0<0;1,0>:ud    r6.2<0;1,0>:ud   {AccWrEn,I@4}
        mov (1|M0)               r42.4<1>:d    r8.0<0;1,0>:d                   
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mul (1|M0)               acc0.0<1>:ud  r1.2<0;1,0>:ud    r3.12<0;1,0>:uw 
        mach (1|M0)              r13.0<1>:ud   r1.2<0;1,0>:ud    r3.6<0;1,0>:ud   {AccWrEn}
        shl (1|M0)               r4.2<1>:d     r1.5<0;1,0>:d     1:w              
        add3 (1|M0)              r1.5<1>:d     r5.0<0;0>:d       r11.0<0;0>:d      r2.0<0>:d        {I@7}
        mov (1|M0)               r12.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        shr (1|M0)               r43.6<1>:ud   r42.0<0;1,0>:ud   0x2:uw             
        shl (1|M0)               r45.6<1>:d    r45.6<0;1,0>:d    2:w              
        shr (1|M0)               r6.1<1>:ud    r10.0<0;1,0>:ud   0x1F:uw             
        mov (1|M0)               r43.4<1>:d    r7.0<0;1,0>:d                    {I@7}
        shl (1|M0)               r6.0<1>:d     r1.5<0;1,0>:d     1:w               {Compacted,I@6}
(W)     mul (1|M0)               acc0.0<1>:d   r1.2<0;1,0>:d     r3.14<0;1,0>:uw 
        shl (1|M0)               r7.0<1>:d     r12.0<0;1,0>:d    2:w               {Compacted,I@7}
        mach (1|M0)              r2.0<1>:d     r1.2<0;1,0>:d     r3.7<0;1,0>:d   
(W)     mul (1|M0)               acc0.0<1>:d   r1.3<0;1,0>:d     r3.12<0;1,0>:uw 
        add (1|M0)               r45.6<1>:d    r45.6<0;1,0>:d    r43.6<0;1,0>:d   {I@7}
        or (1|M0)                r6.3<1>:d     r6.0<0;1,0>:d     r6.1<0;1,0>:d    {I@6}
        mach (1|M0)              r5.0<1>:d     r1.3<0;1,0>:d     r3.6<0;1,0>:d   
        addc (1|M0)              r6.0<1>:ud    r3.4<0;1,0>:ud    r7.0<0;1,0>:ud   {AccWrEn,I@6}
        add3 (1|M0)              r43.5<1>:d    r8.0<0;0>:d       r3.1<0;0>:d       r6.3<0>:d        {I@3}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r45.6<0;1,0>:d    r4.0<0;1,0>:uw   {Compacted}
        or (1|M0)                r4.5<1>:d     r4.2<0;1,0>:d     r4.3<0;1,0>:d   
        add3 (1|M0)              r4.3<1>:d     r5.0<0;0>:d       r13.0<0;0>:d      r2.0<0>:d        {I@6}
        mach (1|M0)              r2.0<1>:d     r45.6<0;1,0>:d    r4.0<0;1,0>:d    {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r45.6<0;1,0>:d    r4.0<0;1,0>:uw   {Compacted}
        mach (1|M0)              r43.0<1>:d    r45.6<0;1,0>:d    r4.0<0;1,0>:d    {Compacted}
        asr (1|M0)               r43.1<1>:d    r2.0<0;1,0>:d     31:w               {Compacted,I@3}
        shl (1|M0)               r1.2<1>:ud    r42.0<0;1,0>:ud   0x6:uw             
        shr (1|M0)               r1.4<1>:ud    r43.0<0;1,0>:ud   0x18:uw              {I@3}
        shl (1|M0)               r1.5<1>:d     r43.0<0;1,0>:d    8:w               {Compacted}
        shl (1|M0)               r1.3<1>:d     r43.1<0;1,0>:d    8:w               {I@4}
        and (1|M0)               r2.0<1>:ud    r1.2<0;1,0>:ud    0xC0:uw              {I@4}
        shl (1|M0)               r4.4<1>:d     r1.5<0;1,0>:d     1:w               {I@3}
        or (1|M0)                r1.6<1>:d     r1.3<0;1,0>:d     r1.4<0;1,0>:d    {I@3}
        shr (1|M0)               r9.1<1>:ud    r12.0<0;1,0>:ud   0x1E:uw             
        add3 (1|M0)              r42.5<1>:d    r9.0<0;0>:d       r2.5<0;0>:d       r4.5<0>:d       
        shl (1|M0)               r42.6<1>:d    r2.0<0;1,0>:d     1:w               {Compacted,I@5}
        addc (1|M0)              r5.0<1>:ud    r42.4<0;1,0>:ud   r4.4<0;1,0>:ud   {AccWrEn,I@5}
        shl (1|M0)               r4.2<1>:d     r1.6<0;1,0>:d     1:w               {I@5}
        shl (1|M0)               r9.0<1>:d     r4.3<0;1,0>:d     2:w               {Compacted}
        shr (1|M0)               r4.3<1>:ud    r1.5<0;1,0>:ud    0x1F:uw             
        mov (1|M0)               r42.2<1>:d    r6.0<0;1,0>:d                   
        shr (1|M0)               r5.3<1>:ud    r2.0<0;1,0>:ud    0x1F:uw             
        or (1|M0)                r7.1<1>:d     r9.0<0;1,0>:d     r9.1<0;1,0>:d    {I@4}
        or (1|M0)                r4.5<1>:d     r4.2<0;1,0>:d     r4.3<0;1,0>:d    {I@4}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r7.0<1>:ud    r5.0<0;1,0>:ud    r42.6<0;1,0>:ud  {AccWrEn}
        or (1|M0)                r42.7<1>:d    r5.3<0;1,0>:d     0:w               {I@5}
        add3 (1|M0)              r42.3<1>:d    r8.0<0;0>:d       r3.5<0;0>:d       r7.1<0>:d        {I@5}
        add3 (1|M0)              r5.2<1>:d     r6.0<0;0>:d       r42.5<0;0>:d      r4.5<0>:d        {I@4}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r9.0<1>:f     r7.0<0;1,0>:f                    {Compacted,I@5}
        add3 (1|M0)              r9.1<1>:d     r8.0<0;0>:d       r5.2<0;0>:d       r42.7<0>:d       {I@1}
        add (1|M0)               r78.4<1>:d    r78.4<0;1,0>:d    -r78.5<0;1,0>:d 
        send.ugm (1|M0)          r10      r9      null:0  0x0            0x0240D780           {A@1,$3} // wr:1+0, rd:4; load.ugm.d64x16t.a64
        shl (1|M0)               r78.4<1>:d    r78.4<0;1,0>:d    2:w               {I@1}
        shl (1|M0)               r14.0<1>:ud   r42.0<0;1,0>:ud   0x7:uw             
        add (1|M0)               r4.2<1>:d     r78.4<0;1,0>:d    r43.6<0;1,0>:d   {I@2}
        add (1|M0)               r43.2<1>:d    r78.4<0;1,0>:d    r43.6<0;1,0>:d  
        asr (1|M0)               r43.3<1>:d    r4.2<0;1,0>:d     31:w               {I@2}
        shr (1|M0)               r1.3<1>:ud    r43.2<0;1,0>:ud   0x18:uw              {I@2}
        shl (1|M0)               r1.4<1>:d     r43.2<0;1,0>:d    8:w              
        shl (1|M0)               r1.2<1>:d     r43.3<0;1,0>:d    8:w               {I@3}
        shl (1|M0)               r5.0<1>:d     r1.4<0;1,0>:d     1:w               {Compacted,I@2}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        shr (1|M0)               r2.1<1>:ud    r1.4<0;1,0>:ud    0x1F:uw             
        addc (1|M0)              r6.0<1>:ud    r43.4<0;1,0>:ud   r5.0<0;1,0>:ud   {AccWrEn,I@3}
        shl (1|M0)               r2.0<1>:d     r1.5<0;1,0>:d     1:w               {Compacted,I@3}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        or (1|M0)                r5.1<1>:d     r2.0<0;1,0>:d     r2.1<0;1,0>:d    {I@2}
        addc (1|M0)              r8.0<1>:ud    r6.0<0;1,0>:ud    r42.6<0;1,0>:ud  {AccWrEn}
        add3 (1|M0)              r6.2<1>:d     r7.0<0;0>:d       r43.5<0;0>:d      r5.1<0>:d        {I@2}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$3.src}
        add (1|M0)               r44.0<1>:ud   r14.0<0;1,0>:ud   0x1000:uw             
        and (1|M0)               r43.7<1>:d    r1.0<0;1,0>:uw    3:w              
        send.slm (1|M0)          null     r14     r10:4   0x0            0x0200D704           {$3} // wr:1+4, rd:0; store.slm.d64x16t.a32
        sync.nop                             null                             {Compacted,$3.src}
        mov (1|M0)               r10.0<1>:f    r8.0<0;1,0>:f                    {Compacted,I@5}
        add3 (1|M0)              r10.1<1>:d    r9.0<0;0>:d       r6.2<0;0>:d       r42.7<0>:d       {I@3}
        send.ugm (1|M0)          r15      r10     null:0  0x0            0x0240D780           {A@1,$4} // wr:1+0, rd:4; load.ugm.d64x16t.a64
        send.slm (1|M0)          null     r44     r15:4   0x0            0x0200D704           {$4} // wr:1+4, rd:0; store.slm.d64x16t.a32
(W)     send.slm (1|M0)          r11      r0      null:0  0x0            0x0210001F           {$5} // wr:1+0, rd:1; fence.slm.none.group
(W)     mov (1|M0)               r12.2<1>:f    0.0:f                               {Compacted}
(W)     mov (2|M0)               r12.10<1>:ub  r0.11<0;1,0>:ub                  {F@1}
(W)     mov (8|M0)               null<1>:ud    r11.0<1;1,0>:ud                  {$5.dst}
(W)     send.gtwy (1|M0)         null     r12     null:0  0x0            0x02000004           {A@2,$6} // wr:1+0, rd:0; signal barrier
(W)     sync.bar                             null                            
        cmp (1|M0)    (gt)f1.1   null<1>:d     r4.0<0;1,0>:d     0:w              
        shl (1|M0)               r43.6<1>:d    r43.6<0;1,0>:d    9:w              
        shl (1|M0)               r43.7<1>:d    r43.7<0;1,0>:d    9:w              
        mov (16|M0)              r46.0<1>:f    0.0:f                               {Compacted}
(W)     and (1|M0)               f1.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
        mov (16|M0)              r48.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r50.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r52.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r54.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r56.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r58.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r60.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r62.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r64.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r66.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r68.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r70.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r72.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r74.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r76.0<1>:f    0.0:f                               {Compacted}
(~f1.1.any16h) goto (16|M0)                  L4008                  L4008                
L2368:
        addc (1|M0)              r2.0<1>:ud    r42.4<0;1,0>:ud   r42.6<0;1,0>:ud  {AccWrEn}
        mov (1|M0)               r44.1<1>:d    r4.0<0;1,0>:d                    {$4.src}
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r6.0<1>:ud    r43.4<0;1,0>:ud   r42.6<0;1,0>:ud  {AccWrEn}
        mov (1|M0)               r44.2<1>:d    0:w                              
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r44.5<1>:d    r4.1<0;1,0>:d                   
        asr (1|M0)               r44.6<1>:d    r4.1<0;1,0>:d     31:w              
        mov (1|M0)               r45.2<2>:f    0.0:f                              
        mov (1|M0)               r45.3<2>:f    0.0:f                              
        mov (1|M0)               r44.3<1>:d    r2.0<0;1,0>:d                    {I@7}
        add3 (1|M0)              r44.4<1>:d    r5.0<0;0>:d       r42.5<0;0>:d      r42.7<0>:d       {I@7}
        mov (1|M0)               r45.0<1>:f    r6.0<0;1,0>:f                    {Compacted,I@7}
        add3 (1|M0)              r45.1<1>:d    r7.0<0;0>:d       r43.5<0;0>:d      r42.7<0>:d       {I@5}
L2568:
        addc (1|M0)              r2.0<1>:ud    r45.2<0;1,0>:ud   0x1:ud              {AccWrEn,F@3}
(W)     mov (1|M0)               r1.3<1>:hf    0x1:hf                             
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r45.4<1>:d    r2.0<0;1,0>:d                    {I@2}
        add3 (1|M0)              r45.5<1>:d    r5.0<0;0>:d       r45.3<0;0>:d      0:w               {A@2}
        cmp (1|M0)    (lt)f1.0   null<1>:ud    r45.4<0;1,0>:ud   r44.1<0;1,0>:ud  {I@2}
        cmp (1|M0)    (eq)f0.0   null<1>:d     r45.5<0;1,0>:d    r44.2<0;1,0>:d   {I@2}
        cmp (1|M0)    (lt)f1.1   null<1>:ud    r45.5<0;1,0>:ud   r44.2<0;1,0>:ud 
        and (1|M0)               r44.7<1>:d    r45.2<0;1,0>:d    1:w              
(f1.0)  sel (1|M0)               r1.5<1>:uw    r1.3<0;1,0>:uw    0x0:uw              {F@1}
(f0.0)  sel (1|M0)               r1.4<1>:uw    r1.3<0;1,0>:uw    0x0:uw             
(f1.1)  sel (1|M0)               r4.5<1>:uw    r1.3<0;1,0>:uw    0x0:uw             
        and (1|M0)    (ne)f1.0   null<1>:uw    r1.4<0;1,0>:uw    r1.5<0;1,0>:uw   {I@2}
(f1.0)  sel (1|M0)               r4.4<1>:uw    r1.3<0;1,0>:uw    0x0:uw             
        or (1|M0)     (ne)f0.1   null<1>:uw    r4.4<0;1,0>:uw    r4.5<0;1,0>:uw   {I@1}
(W)     and (1|M0)               f1.0<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(f1.0.any16h) goto (16|M0)                   L2864                  L2864                
L2832:
        shl (1|M0)               r44.7<1>:d    r44.7<0;1,0>:d    11:w              
        goto (16|M0)                         L2864                  L3528                
L2864:
        join (16|M0)                         L3528                                
L2880:
        addc (1|M0)              r2.0<1>:ud    r45.4<0;1,0>:ud   r43.0<0;1,0>:ud  {AccWrEn}
        shl (1|M0)               r44.7<1>:d    r44.7<0;1,0>:d    11:w               {I@4}
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        shr (1|M0)               r4.2<1>:ud    r2.0<0;1,0>:ud    0x18:uw              {I@3}
        add3 (1|M0)              r1.3<1>:d     r5.0<0;0>:d       r45.5<0;0>:d      r43.1<0>:d       {I@2}
        shl (1|M0)               r4.3<1>:d     r2.0<0;1,0>:d     8:w               {Compacted}
        shl (1|M0)               r2.1<1>:d     r1.3<0;1,0>:d     8:w               {I@2}
        sync.nop                             null                             {Compacted,$8.src}
        shl (1|M0)               r6.2<1>:d     r4.3<0;1,0>:d     1:w               {I@2}
        or (1|M0)                r4.4<1>:d     r2.1<0;1,0>:d     r4.2<0;1,0>:d    {I@2}
        shr (1|M0)               r6.1<1>:ud    r4.3<0;1,0>:ud    0x1F:uw             
        addc (1|M0)              r7.0<1>:ud    r44.3<0;1,0>:ud   r6.2<0;1,0>:ud   {AccWrEn,I@3}
        shl (1|M0)               r6.0<1>:d     r4.4<0;1,0>:d     1:w               {Compacted,I@3}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        or (1|M0)                r6.3<1>:d     r6.0<0;1,0>:d     r6.1<0;1,0>:d    {I@2}
        mov (1|M0)               r9.0<1>:f     r7.0<0;1,0>:f                    {Compacted}
        add3 (1|M0)              r9.1<1>:d     r8.0<0;0>:d       r44.4<0;0>:d      r6.3<0>:d        {I@1}
        mul (1|M0)               acc0.0<1>:ud  r45.4<0;1,0>:ud   r44.10<0;1,0>:uw
        sync.nop                             null                             {Compacted,$6.src}
        send.ugm (1|M0)          r10      r9      null:0  0x0            0x0240D780           {A@1,$9} // wr:1+0, rd:4; load.ugm.d64x16t.a64
        mach (1|M0)              r15.0<1>:ud   r45.4<0;1,0>:ud   r44.5<0;1,0>:ud  {AccWrEn}
        xor (1|M0)               r1.2<1>:d     r44.7<0;1,0>:d    2048:w              
        mov (1|M0)               r14.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r45.4<0;1,0>:d    r44.12<0;1,0>:uw
        mach (1|M0)              r5.0<1>:d     r45.4<0;1,0>:d    r44.6<0;1,0>:d  
(W)     mul (1|M0)               acc0.0<1>:d   r45.5<0;1,0>:d    r44.10<0;1,0>:uw
        mach (1|M0)              r6.0<1>:d     r45.5<0;1,0>:d    r44.5<0;1,0>:d  
        addc (1|M0)              r7.0<1>:ud    r14.0<0;1,0>:ud   r43.2<0;1,0>:ud  {AccWrEn,I@5}
        add3 (1|M0)              r1.4<1>:d     r6.0<0;0>:d       r15.0<0;0>:d      r5.0<0>:d        {I@2}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mad (1|M0)               r2.0<1>:d     r1.2<0;0>:d       r1.0<0;0>:uw      128:w              
        add3 (1|M0)              r4.3<1>:d     r8.0<0;0>:d       r1.4<0;0>:d       r43.3<0>:d       {I@2}
        shr (1|M0)               r2.1<1>:ud    r7.0<0;1,0>:ud    0x18:uw             
        shl (1|M0)               r9.0<1>:d     r7.0<0;1,0>:d     8:w               {Compacted,$9.src}
        add (1|M0)               r7.0<1>:d     r1.2<0;1,0>:d     r44.0<0;1,0>:d   {Compacted}
        shr (1|M0)               r9.3<1>:ud    r9.0<0;1,0>:ud    0x1F:uw              {I@2}
        send.slm (1|M0)          null     r2      r10:4   0x0            0x0200D704           {$9} // wr:1+4, rd:0; store.slm.d64x16t.a32
        shl (1|M0)               r2.0<1>:d     r4.3<0;1,0>:d     8:w               {Compacted,$9.src}
        shl (1|M0)               r10.0<1>:d    r9.0<0;1,0>:d     1:w               {Compacted}
        or (1|M0)                r9.1<1>:d     r2.0<0;1,0>:d     r2.1<0;1,0>:d    {I@2}
        addc (1|M0)              r5.0<1>:ud    r45.0<0;1,0>:ud   r10.0<0;1,0>:ud  {AccWrEn,I@2}
        shl (1|M0)               r9.2<1>:d     r9.1<0;1,0>:d     1:w               {I@2}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        or (1|M0)                r10.1<1>:d    r9.2<0;1,0>:d     r9.3<0;1,0>:d    {I@2}
        mov (1|M0)               r11.0<1>:f    r5.0<0;1,0>:f                    {Compacted}
        add3 (1|M0)              r11.1<1>:d    r6.0<0;0>:d       r45.1<0;0>:d      r10.1<0>:d       {I@1}
        send.ugm (1|M0)          r12      r11     null:0  0x0            0x0240D780           {A@1,$10} // wr:1+0, rd:4; load.ugm.d64x16t.a64
        send.slm (1|M0)          null     r7      r12:4   0x0            0x0200D704           {$10} // wr:1+4, rd:0; store.slm.d64x16t.a32
L3528:
        join (16|M0)                         L4008                                
L3544:
        add (1|M0)               r2.0<1>:d     r44.7<0;1,0>:d    r43.6<0;1,0>:d  
        bfn.0xFE (1|M0)          r5.0<1>:ud    0x1000:uw               r44.7<0;0>:ud     r43.7<0>:ud      // s0|s1|s2
        bfn.0xFE (1|M0)          r31.0<1>:ud   0x1100:uw               r44.7<0;0>:ud     r43.7<0>:ud      // s0|s1|s2
        sync.nop                             null                             {Compacted,$10.src}
        or (1|M0)                r14.0<1>:ud   r2.0<0;1,0>:ud    0x100:uw              {I@3}
        sync.allrd                           ($6,$8)                
        send.slm (1|M0)          r6       r2      null:0  0x0            0x0280E700           {$11} // wr:1+0, rd:8; load.slm.d64x32t.a32
        send.slm (1|M0)          r23      r5      null:0  0x0            0x0280E700           {A@3,$12} // wr:1+0, rd:8; load.slm.d64x32t.a32
        send.slm (1|M0)          r32      r31     null:0  0x0            0x0280E700           {A@2,$13} // wr:1+0, rd:8; load.slm.d64x32t.a32
        send.slm (1|M0)          r15      r14     null:0  0x0            0x0280E700           {A@1,$14} // wr:1+0, rd:8; load.slm.d64x32t.a32
        sync.allwr                           ($8,$11,$12,$13,$14)                
        dpas.8x8 (8|M0)          r70:f         r70:f             r23:hf            r6.0:hf          {Atomic}
        dpas.8x8 (8|M0)          r62:f         r62:f             r32:hf            r6.0:hf          {Atomic}
        dpas.8x8 (8|M0)          r54:f         r54:f             r23:hf            r15.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r46:f         r46:f             r32:hf            r15.0:hf         {$8}
(W)     send.slm (1|M0)          r40      r0      null:0  0x0            0x0210001F           {$15} // wr:1+0, rd:1; fence.slm.none.group
(W)     mov (1|M0)               r41.2<1>:f    0.0:f                               {Compacted,$7.src}
(W)     mov (2|M0)               r41.10<1>:ub  r0.11<0;1,0>:ub                  {F@1}
(W)     mov (8|M0)               null<1>:ud    r40.0<1;1,0>:ud                  {$15.dst}
(W)     send.gtwy (1|M0)         null     r41     null:0  0x0            0x02000004           {A@2,$7} // wr:1+0, rd:0; signal barrier
(W)     sync.bar                             null                            
        cmp (1|M0)    (eq)f0.1   null<1>:d     r45.4<0;1,0>:d    r44.1<0;1,0>:d  
(W)     mov (1|M0)               r1.3<1>:hf    0x1:hf                             
(f0.0)  sel (1|M0)               r2.0<1>:uw    r1.3<0;1,0>:uw    0x0:uw              {F@1}
(f0.1)  sel (1|M0)               r1.4<1>:uw    r1.3<0;1,0>:uw    0x0:uw             
        and (1|M0)    (ne)f0.0   null<1>:uw    r1.4<0;1,0>:uw    r2.0<0;1,0>:uw   {I@1}
(W)     and (1|M0)               f0.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
(f0.1.any16h) goto (16|M0)                   L4008                  L4008                
L3976:
(W)     mov (2|M0)               r45.2<1>:ud   r45.4<1;1,0>:ud                 
        goto.b (16|M0)                       L4008                  L2568                
L4008:
        join (16|M0)                         L4024                                
L4024:
        shl (1|M0)               r45.6<1>:d    r45.6<0;1,0>:d    4:w              
        bfn.0xEA (1|M0)          r78.4<1>:ud   r78.4<0;0>:ud     r42.0<0;0>:ud     0x3:uw              // s0|s1&s2
        mul (1|M0)               acc0.0<1>:d   r45.6<0;1,0>:d    r2.6<0;1,0>:uw   {I@2}
        mach (1|M0)              r6.0<1>:d     r45.6<0;1,0>:d    r2.3<0;1,0>:d    {AccWrEn,$8.src}
        shl (1|M0)               r4.4<1>:ud    r78.4<0;1,0>:ud   0x4:uw              {I@3}
        mov (1|M0)               r5.0<1>:d     acc0.0<0;1,0>:d                 
        shl (1|M0)               r8.0<1>:d     r4.4<0;1,0>:d     2:w               {Compacted,I@2}
        shl (1|M0)               r1.6<1>:d     r5.0<0;1,0>:d     2:w               {Compacted,I@2}
        shl (1|M0)               r1.4<1>:d     r6.0<0;1,0>:d     2:w               {Compacted}
        addc (1|M0)              r2.0<1>:ud    r42.2<0;1,0>:ud   r1.6<0;1,0>:ud   {AccWrEn,I@2}
        shr (1|M0)               r1.5<1>:ud    r5.0<0;1,0>:ud    0x1E:uw             
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$10.src}
        addc (1|M0)              r9.0<1>:ud    r2.0<0;1,0>:ud    r8.0<0;1,0>:ud   {AccWrEn,I@3}
        shr (1|M0)               r2.1<1>:ud    r4.4<0;1,0>:ud    0x1E:uw             
        shl (1|M0)               r1.6<1>:d     r2.3<0;1,0>:d     3:w              
        or (1|M0)                r1.7<1>:d     r1.4<0;1,0>:d     r1.5<0;1,0>:d    {I@5}
        mov (1|M0)               r5.0<1>:f     r9.0<0;1,0>:f                    {Compacted,I@4}
        asr (1|M0)               r1.3<1>:d     r2.3<0;1,0>:d     31:w               {Compacted}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        or (1|M0)                r8.1<1>:d     r2.1<0;1,0>:d     0:w               {Compacted,I@5}
        shl (1|M0)               r4.2<1>:d     r1.6<0;1,0>:d     2:w               {I@5}
        add3 (1|M0)              r4.3<1>:d     r7.0<0;0>:d       r42.3<0;0>:d      r1.7<0>:d        {I@5}
        addc (1|M0)              r6.0<1>:ud    r5.0<0;1,0>:ud    0x20:ud              {AccWrEn,F@1}
        shr (1|M0)               r1.5<1>:ud    r2.3<0;1,0>:ud    0x1D:uw             
        shl (1|M0)               r1.4<1>:d     r1.3<0;1,0>:d     3:w               {I@7}
        add3 (1|M0)              r5.1<1>:d     r10.0<0;0>:d      r4.3<0;0>:d       r8.1<0>:d        {I@4}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r8.0<1>:ud    r5.0<0;1,0>:ud    r4.2<0;1,0>:ud   {AccWrEn}
        or (1|M0)                r1.7<1>:d     r1.4<0;1,0>:d     r1.5<0;1,0>:d    {I@4}
        add3 (1|M0)              r11.1<1>:d    r7.0<0;0>:d       r5.1<0;0>:d       0:w               {I@3}
        mov (1|M0)               r7.0<1>:f     r8.0<0;1,0>:f                    {Compacted,A@1}
        shr (1|M0)               r2.1<1>:ud    r1.6<0;1,0>:ud    0x1E:uw             
        mov (1|M0)               r11.0<1>:f    r6.0<0;1,0>:f                    {Compacted}
        shl (1|M0)               r2.0<1>:d     r1.7<0;1,0>:d     2:w               {Compacted}
        shl (1|M0)               r1.6<1>:d     r2.3<0;1,0>:d     2:w              
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,F@1}
        addc (1|M0)              r9.0<1>:ud    r7.0<0;1,0>:ud    0x20:ud              {AccWrEn}
        or (1|M0)                r4.3<1>:d     r2.0<0;1,0>:d     r2.1<0;1,0>:d    {I@4}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r2.0<1>:ud    r5.0<0;1,0>:ud    r1.6<0;1,0>:ud   {AccWrEn,I@5}
        send.ugm (1|M0)          null     r5      r70:1   0x0            0x0200C584           {$8} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        mov (1|M0)               r8.0<1>:f     r2.0<0;1,0>:f                    {Compacted,I@1}
        send.ugm (1|M0)          null     r11     r62:1   0x0            0x0200C584           {$0} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        add3 (1|M0)              r7.1<1>:d     r6.0<0;0>:d       r5.1<0;0>:d       r4.3<0>:d       
        mov (1|M0)               r11.0<1>:f    r9.0<0;1,0>:f                    {Compacted,$0.src}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r9.0<1>:ud    r8.0<0;1,0>:ud    0x20:ud              {AccWrEn,A@1}
        send.ugm (1|M0)          null     r7      r54:1   0x0            0x0200C584           {A@3,$1} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$1.src}
        mul (1|M0)               acc0.0<1>:d   r2.3<0;1,0>:d     0x9:uw             
        add3 (1|M0)              r11.1<1>:d    r10.0<0;0>:d      r7.1<0;0>:d       0:w              
        mach (1|M0)              r12.0<1>:d    r2.3<0;1,0>:d     9:d               {AccWrEn,$6.src}
        send.ugm (1|M0)          null     r11     r46:1   0x0            0x0200C584           {A@2,$2} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        shl (1|M0)               r1.4<1>:d     r1.3<0;1,0>:d     2:w              
        shr (1|M0)               r1.5<1>:ud    r2.3<0;1,0>:ud    0x1E:uw             
        mov (1|M0)               r11.0<1>:d    acc0.0<0;1,0>:d                  {$2.src}
        or (1|M0)                r1.7<1>:d     r1.4<0;1,0>:d     r1.5<0;1,0>:d    {I@2}
        shl (1|M0)               r2.0<1>:d     r11.0<0;1,0>:d    2:w               {Compacted,I@2}
        add3 (1|M0)              r8.1<1>:d     r6.0<0;0>:d       r5.1<0;0>:d       r1.7<0>:d        {I@2}
        addc (1|M0)              r6.0<1>:ud    r5.0<0;1,0>:ud    r2.0<0;1,0>:ud   {AccWrEn,I@2}
        shl (1|M0)               r4.4<1>:d     r2.3<0;1,0>:d     1:w              
        mov (1|M0)               r10.0<1>:f    r9.0<0;1,0>:f                    {Compacted}
        shl (1|M0)               r1.4<1>:d     r12.0<0;1,0>:d    2:w               {Compacted}
        shr (1|M0)               r1.5<1>:ud    r11.0<0;1,0>:ud   0x1E:uw             
        mov (1|M0)               r9.0<1>:f     r6.0<0;1,0>:f                    {Compacted,I@4}
        add3 (1|M0)              r10.1<1>:d    r7.0<0;0>:d       r8.1<0;0>:d       0:w              
        mov (1|M0)               r13.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        sync.nop                             null                             {Compacted,$8.src}
        shl (1|M0)               r5.3<1>:d     r4.4<0;1,0>:d     2:w               {I@5}
        or (1|M0)                r2.1<1>:d     r1.4<0;1,0>:d     r1.5<0;1,0>:d    {I@4}
        addc (1|M0)              r7.0<1>:ud    r9.0<0;1,0>:ud    0x20:ud              {AccWrEn,F@1}
        send.ugm (1|M0)          null     r8      r71:1   0x0            0x0200C584           {$3} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        add3 (1|M0)              r9.1<1>:d     r13.0<0;0>:d      r5.1<0;0>:d       r2.1<0>:d        {I@2}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$3.src}
        addc (1|M0)              r6.0<1>:ud    r5.0<0;1,0>:ud    r5.3<0;1,0>:ud   {AccWrEn}
        send.ugm (1|M0)          null     r10     r63:1   0x0            0x0200C584           {$4} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        sync.nop                             null                             {Compacted,$4.src}
        add3 (1|M0)              r10.1<1>:d    r8.0<0;0>:d       r9.1<0;0>:d       0:w               {I@2}
        mov (1|M0)               r8.0<1>:f     r6.0<0;1,0>:f                    {Compacted,A@1}
        send.ugm (1|M0)          null     r9      r55:1   0x0            0x0200C584           {$5} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        mov (1|M0)               r10.0<1>:f    r7.0<0;1,0>:f                    {Compacted}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,F@1}
        addc (1|M0)              r9.0<1>:ud    r8.0<0;1,0>:ud    0x20:ud              {AccWrEn,$5.src}
        send.ugm (1|M0)          null     r10     r47:1   0x0            0x0200C584           {$7} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,$7.src}
        mul (1|M0)               acc0.0<1>:d   r2.3<0;1,0>:d     0xA:uw             
        shl (1|M0)               r4.2<1>:d     r1.3<0;1,0>:d     1:w              
        shr (1|M0)               r4.3<1>:ud    r2.3<0;1,0>:ud    0x1F:uw             
        mach (1|M0)              r13.0<1>:d    r2.3<0;1,0>:d     10:d               {AccWrEn}
        or (1|M0)                r4.5<1>:d     r4.2<0;1,0>:d     r4.3<0;1,0>:d    {I@2}
        mov (1|M0)               r12.0<1>:d    acc0.0<0;1,0>:d                 
        shr (1|M0)               r2.0<1>:ud    r4.4<0;1,0>:ud    0x1E:uw             
        shl (1|M0)               r5.2<1>:d     r4.5<0;1,0>:d     2:w               {I@3}
        shl (1|M0)               r1.4<1>:d     r12.0<0;1,0>:d    2:w               {Compacted,I@3}
        or (1|M0)                r5.4<1>:d     r5.2<0;1,0>:d     r2.0<0;1,0>:d    {I@2}
        addc (1|M0)              r2.0<1>:ud    r5.0<0;1,0>:ud    r1.4<0;1,0>:ud   {AccWrEn,I@2}
        add3 (1|M0)              r8.1<1>:d     r7.0<0;0>:d       r5.1<0;0>:d       r5.4<0>:d        {I@2}
        mov (1|M0)               r7.0<1>:f     r2.0<0;1,0>:f                    {Compacted,A@1}
        send.ugm (1|M0)          null     r8      r72:1   0x0            0x0200C584           {$9} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        sync.nop                             null                             {Compacted,$9.src}
        addc (1|M0)              r8.0<1>:ud    r7.0<0;1,0>:ud    0x20:ud              {AccWrEn,F@1}
        mov (1|M0)               r11.0<1>:f    r9.0<0;1,0>:f                    {Compacted}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,F@1}
        mul (1|M0)               acc0.0<1>:d   r2.3<0;1,0>:d     0x3:uw             
        shr (1|M0)               r1.3<1>:ud    r12.0<0;1,0>:ud   0x1E:uw             
        add3 (1|M0)              r11.1<1>:d    r10.0<0;0>:d      r8.1<0;0>:d       0:w              
        mach (1|M0)              r12.0<1>:d    r2.3<0;1,0>:d     3:d               {AccWrEn}
        send.ugm (1|M0)          null     r11     r64:1   0x0            0x0200C584           {A@2,$10} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        shl (1|M0)               r1.2<1>:d     r13.0<0;1,0>:d    2:w               {Compacted}
        mov (1|M0)               r11.0<1>:d    acc0.0<0;1,0>:d                  {$10.src}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        shl (1|M0)               r1.2<1>:d     r11.0<0;1,0>:d    2:w               {Compacted,I@2}
        add3 (1|M0)              r7.1<1>:d     r6.0<0;0>:d       r5.1<0;0>:d       r1.5<0>:d        {I@2}
        addc (1|M0)              r6.0<1>:ud    r5.0<0;1,0>:ud    r1.2<0;1,0>:ud   {AccWrEn,I@2}
        mov (1|M0)               r10.0<1>:f    r8.0<0;1,0>:f                    {Compacted}
        mov (1|M0)               r8.0<1>:f     r6.0<0;1,0>:f                    {Compacted,I@1}
        send.ugm (1|M0)          null     r7      r56:1   0x0            0x0200C584           {$11} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        mov (1|M0)               r13.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        sync.nop                             null                             {Compacted,$11.src}
        addc (1|M0)              r7.0<1>:ud    r8.0<0;1,0>:ud    0x20:ud              {AccWrEn,F@1}
        add3 (1|M0)              r10.1<1>:d    r9.0<0;0>:d       r7.1<0;0>:d       0:w              
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mul (1|M0)               acc0.0<1>:d   r2.3<0;1,0>:d     0xB:uw             
        shl (1|M0)               r4.2<1>:d     r12.0<0;1,0>:d    2:w               {Compacted}
        mach (1|M0)              r12.0<1>:d    r2.3<0;1,0>:d     11:d               {AccWrEn}
        shr (1|M0)               r2.0<1>:ud    r11.0<0;1,0>:ud   0x1E:uw             
        mov (1|M0)               r11.0<1>:d    acc0.0<0;1,0>:d                 
        or (1|M0)                r1.3<1>:d     r4.2<0;1,0>:d     r2.0<0;1,0>:d    {I@2}
        shl (1|M0)               r1.2<1>:d     r11.0<0;1,0>:d    2:w               {Compacted,I@2}
        send.ugm (1|M0)          null     r10     r48:1   0x0            0x0200C584           {$12} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        addc (1|M0)              r6.0<1>:ud    r5.0<0;1,0>:ud    r1.2<0;1,0>:ud   {AccWrEn,I@1}
        add3 (1|M0)              r8.1<1>:d     r13.0<0;0>:d      r5.1<0;0>:d       r1.3<0>:d       
        mov (1|M0)               r10.0<1>:f    r7.0<0;1,0>:f                    {Compacted,$12.src}
        mov (1|M0)               r7.0<1>:f     r6.0<0;1,0>:f                    {Compacted,I@2}
        sync.nop                             null                             {Compacted,I@1}
        send.ugm (1|M0)          null     r8      r73:1   0x0            0x0200C584           {$13} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        shl (1|M0)               r4.3<1>:d     r1.6<0;1,0>:d     2:w              
        mov (1|M0)               r13.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        sync.nop                             null                             {Compacted,$13.src}
        addc (1|M0)              r8.0<1>:ud    r7.0<0;1,0>:ud    0x20:ud              {AccWrEn,F@1}
        shl (1|M0)               r2.0<1>:d     r12.0<0;1,0>:d    2:w               {Compacted}
        shr (1|M0)               r2.1<1>:ud    r11.0<0;1,0>:ud   0x1E:uw             
        add3 (1|M0)              r10.1<1>:d    r9.0<0;0>:d       r8.1<0;0>:d       0:w              
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r6.0<1>:ud    r5.0<0;1,0>:ud    r4.3<0;1,0>:ud   {AccWrEn,I@7}
        or (1|M0)                r1.3<1>:d     r2.0<0;1,0>:d     r2.1<0;1,0>:d    {I@4}
        mov (1|M0)               r12.0<1>:f    r6.0<0;1,0>:f                    {Compacted,I@2}
        send.ugm (1|M0)          null     r10     r65:1   0x0            0x0200C584           {$14} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        add3 (1|M0)              r7.1<1>:d     r13.0<0;0>:d      r5.1<0;0>:d       r1.3<0>:d        {I@2}
        mov (1|M0)               r10.0<1>:f    r8.0<0;1,0>:f                    {Compacted,$14.src}
        addc (1|M0)              r8.0<1>:ud    r12.0<0;1,0>:ud   0x20:ud              {AccWrEn,A@1}
        send.ugm (1|M0)          null     r7      r57:1   0x0            0x0200C584           {A@2,$15} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$15.src}
        mul (1|M0)               acc0.0<1>:d   r2.3<0;1,0>:d     0xC:uw             
        mach (1|M0)              r14.0<1>:d    r2.3<0;1,0>:d     12:d               {AccWrEn}
        shl (1|M0)               r4.2<1>:d     r1.7<0;1,0>:d     2:w              
        mov (1|M0)               r13.0<1>:d    acc0.0<0;1,0>:d                 
        shr (1|M0)               r2.0<1>:ud    r1.6<0;1,0>:ud    0x1E:uw             
        shl (1|M0)               r1.4<1>:d     r13.0<0;1,0>:d    2:w               {Compacted,I@2}
        or (1|M0)                r4.4<1>:d     r4.2<0;1,0>:d     r2.0<0;1,0>:d    {I@2}
        addc (1|M0)              r2.0<1>:ud    r5.0<0;1,0>:ud    r1.4<0;1,0>:ud   {AccWrEn,I@2}
        add3 (1|M0)              r10.1<1>:d    r9.0<0;0>:d       r7.1<0;0>:d       0:w              
        add3 (1|M0)              r12.1<1>:d    r11.0<0;0>:d      r5.1<0;0>:d       r4.4<0>:d        {I@3}
        mov (1|M0)               r9.0<1>:f     r8.0<0;1,0>:f                    {Compacted,I@2}
        mov (1|M0)               r8.0<1>:f     r2.0<0;1,0>:f                    {Compacted}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        add3 (1|M0)              r9.1<1>:d     r7.0<0;0>:d       r12.1<0;0>:d      0:w               {I@2}
        addc (1|M0)              r7.0<1>:ud    r8.0<0;1,0>:ud    0x20:ud              {AccWrEn,F@1}
        send.ugm (1|M0)          null     r10     r49:1   0x0            0x0200C584           {$0} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r12     r74:1   0x0            0x0200C584           {$1} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r9      r66:1   0x0            0x0200C584           {A@2,$2} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$2.src}
        mul (1|M0)               acc0.0<1>:d   r2.3<0;1,0>:d     0x5:uw             
        mach (1|M0)              r12.0<1>:d    r2.3<0;1,0>:d     5:d               {AccWrEn,$1.src}
        shl (1|M0)               r1.2<1>:d     r14.0<0;1,0>:d    2:w               {Compacted}
        shr (1|M0)               r1.3<1>:ud    r13.0<0;1,0>:ud   0x1E:uw             
        mov (1|M0)               r11.0<1>:d    acc0.0<0;1,0>:d                 
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        shl (1|M0)               r1.2<1>:d     r11.0<0;1,0>:d    2:w               {Compacted,I@2}
        add3 (1|M0)              r8.1<1>:d     r6.0<0;0>:d       r5.1<0;0>:d       r1.5<0>:d        {I@2}
        addc (1|M0)              r6.0<1>:ud    r5.0<0;1,0>:ud    r1.2<0;1,0>:ud   {AccWrEn,I@2}
        mov (1|M0)               r10.0<1>:f    r7.0<0;1,0>:f                    {Compacted,$0.src}
        mov (1|M0)               r7.0<1>:f     r6.0<0;1,0>:f                    {Compacted,I@1}
        send.ugm (1|M0)          null     r8      r58:1   0x0            0x0200C584           {$3} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        mov (1|M0)               r13.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        sync.nop                             null                             {Compacted,$3.src}
        addc (1|M0)              r8.0<1>:ud    r7.0<0;1,0>:ud    0x20:ud              {AccWrEn,F@1}
        add3 (1|M0)              r10.1<1>:d    r9.0<0;0>:d       r8.1<0;0>:d       0:w              
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mul (1|M0)               acc0.0<1>:d   r2.3<0;1,0>:d     0xD:uw             
        shl (1|M0)               r4.2<1>:d     r12.0<0;1,0>:d    2:w               {Compacted}
        mach (1|M0)              r12.0<1>:d    r2.3<0;1,0>:d     13:d               {AccWrEn}
        shr (1|M0)               r2.0<1>:ud    r11.0<0;1,0>:ud   0x1E:uw             
        mov (1|M0)               r11.0<1>:d    acc0.0<0;1,0>:d                 
        or (1|M0)                r1.3<1>:d     r4.2<0;1,0>:d     r2.0<0;1,0>:d    {I@2}
        shl (1|M0)               r1.2<1>:d     r11.0<0;1,0>:d    2:w               {Compacted,I@2}
        send.ugm (1|M0)          null     r10     r50:1   0x0            0x0200C584           {$4} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        addc (1|M0)              r6.0<1>:ud    r5.0<0;1,0>:ud    r1.2<0;1,0>:ud   {AccWrEn,I@1}
        add3 (1|M0)              r7.1<1>:d     r13.0<0;0>:d      r5.1<0;0>:d       r1.3<0>:d       
        mov (1|M0)               r10.0<1>:f    r8.0<0;1,0>:f                    {Compacted,$4.src}
        mov (1|M0)               r8.0<1>:f     r6.0<0;1,0>:f                    {Compacted,I@2}
        sync.nop                             null                             {Compacted,I@1}
        send.ugm (1|M0)          null     r7      r75:1   0x0            0x0200C584           {$5} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        mov (1|M0)               r13.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        sync.nop                             null                             {Compacted,$5.src}
        addc (1|M0)              r7.0<1>:ud    r8.0<0;1,0>:ud    0x20:ud              {AccWrEn,F@1}
        add3 (1|M0)              r10.1<1>:d    r9.0<0;0>:d       r7.1<0;0>:d       0:w              
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mul (1|M0)               acc0.0<1>:d   r2.3<0;1,0>:d     0x6:uw             
        shl (1|M0)               r2.0<1>:d     r12.0<0;1,0>:d    2:w               {Compacted}
        mach (1|M0)              r12.0<1>:d    r2.3<0;1,0>:d     6:d               {AccWrEn}
        shr (1|M0)               r2.1<1>:ud    r11.0<0;1,0>:ud   0x1E:uw             
        mov (1|M0)               r11.0<1>:d    acc0.0<0;1,0>:d                 
        or (1|M0)                r1.3<1>:d     r2.0<0;1,0>:d     r2.1<0;1,0>:d    {I@2}
        shl (1|M0)               r1.2<1>:d     r11.0<0;1,0>:d    2:w               {Compacted,I@2}
        send.ugm (1|M0)          null     r10     r67:1   0x0            0x0200C584           {$6} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        addc (1|M0)              r6.0<1>:ud    r5.0<0;1,0>:ud    r1.2<0;1,0>:ud   {AccWrEn,I@1}
        add3 (1|M0)              r8.1<1>:d     r13.0<0;0>:d      r5.1<0;0>:d       r1.3<0>:d       
        mov (1|M0)               r10.0<1>:f    r7.0<0;1,0>:f                    {Compacted,$6.src}
        mov (1|M0)               r7.0<1>:f     r6.0<0;1,0>:f                    {Compacted,I@2}
        sync.nop                             null                             {Compacted,I@1}
        send.ugm (1|M0)          null     r8      r59:1   0x0            0x0200C584           {$7} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        mov (1|M0)               r13.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        sync.nop                             null                             {Compacted,$7.src}
        addc (1|M0)              r8.0<1>:ud    r7.0<0;1,0>:ud    0x20:ud              {AccWrEn,F@1}
        add3 (1|M0)              r10.1<1>:d    r9.0<0;0>:d       r8.1<0;0>:d       0:w              
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mul (1|M0)               acc0.0<1>:d   r2.3<0;1,0>:d     0xE:uw             
        shl (1|M0)               r2.0<1>:d     r12.0<0;1,0>:d    2:w               {Compacted}
        mach (1|M0)              r12.0<1>:d    r2.3<0;1,0>:d     14:d               {AccWrEn}
        shr (1|M0)               r2.1<1>:ud    r11.0<0;1,0>:ud   0x1E:uw             
        mov (1|M0)               r11.0<1>:d    acc0.0<0;1,0>:d                 
        or (1|M0)                r1.3<1>:d     r2.0<0;1,0>:d     r2.1<0;1,0>:d    {I@2}
        shl (1|M0)               r1.2<1>:d     r11.0<0;1,0>:d    2:w               {Compacted,I@2}
        send.ugm (1|M0)          null     r10     r51:1   0x0            0x0200C584           {$8} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        addc (1|M0)              r6.0<1>:ud    r5.0<0;1,0>:ud    r1.2<0;1,0>:ud   {AccWrEn,I@1}
        add3 (1|M0)              r7.1<1>:d     r13.0<0;0>:d      r5.1<0;0>:d       r1.3<0>:d       
        mov (1|M0)               r10.0<1>:f    r8.0<0;1,0>:f                    {Compacted,$8.src}
        mov (1|M0)               r8.0<1>:f     r6.0<0;1,0>:f                    {Compacted,I@2}
        sync.nop                             null                             {Compacted,I@1}
        send.ugm (1|M0)          null     r7      r76:1   0x0            0x0200C584           {$9} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        mov (1|M0)               r13.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        sync.nop                             null                             {Compacted,$9.src}
        addc (1|M0)              r7.0<1>:ud    r8.0<0;1,0>:ud    0x20:ud              {AccWrEn,F@1}
        add3 (1|M0)              r10.1<1>:d    r9.0<0;0>:d       r7.1<0;0>:d       0:w              
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mul (1|M0)               acc0.0<1>:d   r2.3<0;1,0>:d     0x7:uw             
        shl (1|M0)               r2.0<1>:d     r12.0<0;1,0>:d    2:w               {Compacted}
        mach (1|M0)              r12.0<1>:d    r2.3<0;1,0>:d     7:d               {AccWrEn}
        shr (1|M0)               r2.1<1>:ud    r11.0<0;1,0>:ud   0x1E:uw             
        mov (1|M0)               r11.0<1>:d    acc0.0<0;1,0>:d                 
        or (1|M0)                r1.3<1>:d     r2.0<0;1,0>:d     r2.1<0;1,0>:d    {I@2}
        shl (1|M0)               r1.2<1>:d     r11.0<0;1,0>:d    2:w               {Compacted,I@2}
        send.ugm (1|M0)          null     r10     r68:1   0x0            0x0200C584           {$10} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        addc (1|M0)              r6.0<1>:ud    r5.0<0;1,0>:ud    r1.2<0;1,0>:ud   {AccWrEn,I@1}
        add3 (1|M0)              r8.1<1>:d     r13.0<0;0>:d      r5.1<0;0>:d       r1.3<0>:d       
        mov (1|M0)               r10.0<1>:f    r7.0<0;1,0>:f                    {Compacted,$10.src}
        mov (1|M0)               r7.0<1>:f     r6.0<0;1,0>:f                    {Compacted,I@2}
        sync.nop                             null                             {Compacted,I@1}
        send.ugm (1|M0)          null     r8      r60:1   0x0            0x0200C584           {$11} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        mov (1|M0)               r13.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        sync.nop                             null                             {Compacted,$11.src}
        addc (1|M0)              r8.0<1>:ud    r7.0<0;1,0>:ud    0x20:ud              {AccWrEn,F@1}
        add3 (1|M0)              r10.1<1>:d    r9.0<0;0>:d       r8.1<0;0>:d       0:w              
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mul (1|M0)               acc0.0<1>:d   r2.3<0;1,0>:d     0xF:uw             
        shl (1|M0)               r2.0<1>:d     r12.0<0;1,0>:d    2:w               {Compacted}
        mach (1|M0)              r12.0<1>:d    r2.3<0;1,0>:d     15:d               {AccWrEn}
        shr (1|M0)               r2.1<1>:ud    r11.0<0;1,0>:ud   0x1E:uw             
        mov (1|M0)               r11.0<1>:d    acc0.0<0;1,0>:d                 
        or (1|M0)                r1.3<1>:d     r2.0<0;1,0>:d     r2.1<0;1,0>:d    {I@2}
        shl (1|M0)               r1.2<1>:d     r11.0<0;1,0>:d    2:w               {Compacted,I@2}
        send.ugm (1|M0)          null     r10     r52:1   0x0            0x0200C584           {$12} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        addc (1|M0)              r6.0<1>:ud    r5.0<0;1,0>:ud    r1.2<0;1,0>:ud   {AccWrEn,I@1}
        shl (1|M0)               r2.0<1>:d     r12.0<0;1,0>:d    2:w               {Compacted}
        shr (1|M0)               r2.1<1>:ud    r11.0<0;1,0>:ud   0x1E:uw             
        add3 (1|M0)              r7.1<1>:d     r13.0<0;0>:d      r5.1<0;0>:d       r1.3<0>:d       
        mov (1|M0)               r10.0<1>:f    r8.0<0;1,0>:f                    {Compacted,$12.src}
        mov (1|M0)               r8.0<1>:f     r6.0<0;1,0>:f                    {Compacted,I@4}
        sync.nop                             null                             {Compacted,I@1}
        send.ugm (1|M0)          null     r7      r77:1   0x0            0x0200C584           {$13} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        or (1|M0)                r1.3<1>:d     r2.0<0;1,0>:d     r2.1<0;1,0>:d   
        mov (1|M0)               r13.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        sync.nop                             null                             {Compacted,$13.src}
        addc (1|M0)              r7.0<1>:ud    r8.0<0;1,0>:ud    0x20:ud              {AccWrEn,F@1}
        add3 (1|M0)              r10.1<1>:d    r9.0<0;0>:d       r7.1<0;0>:d       0:w              
        add3 (1|M0)              r8.1<1>:d     r13.0<0;0>:d      r5.1<0;0>:d       r1.3<0>:d        {I@3}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        send.ugm (1|M0)          null     r10     r69:1   0x0            0x0200C584           {A@3,$14} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        mov (1|M0)               r10.0<1>:f    r7.0<0;1,0>:f                    {Compacted,$14.src}
        add3 (1|M0)              r10.1<1>:d    r9.0<0;0>:d       r8.1<0;0>:d       0:w               {I@1}
        send.ugm (1|M0)          null     r8      r61:1   0x0            0x0200C584           {$15} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r10     r53:1   0x0            0x0200C584           {A@1,$0} // wr:1+1, rd:0; store.ugm.d32x8t.a64
(W)     mov (8|M0)               r127.0<1>:f   r0.0<1;1,0>:f                    {Compacted}
(W)     send.ugm (1|M0)          r11      r0      null:0  0x0            0x0210641F           {$1} // wr:1+0, rd:1; fence invalid flush type scoped to tile
(W)     mov (8|M0)               null<1>:ud    r11.0<1;1,0>:ud                  {$1.dst}
(W)     send.gtwy (1|M0)         null     r127    null:0  0x0            0x02000010           {EOT,A@1} // wr:1+0, rd:0; end of thread
L7920:
        mov (1|M0)               r1.2<1>:d     cr0.0<0;1,0>:ud                  {A@1}
        and (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   -1265:w               {A@1}
        or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   1264:w               {A@1}
        mov (1|M0)               r1.5<1>:f     (abs)r78.1<0;1,0>:d              {A@1}
        mov (1|M0)               r5.2<1>:f     0xB4C00000:f                               {Compacted}
        math.inv (1|M0)          r5.1<1>:f     r1.5<0;1,0>:f                    {@2,$2}
        mov (1|M0)               r2.1<1>:f     (abs)r78.0<0;1,0>:d              {Compacted}
        sync.nop                             null                             {Compacted,$2.dst}
        mad (1|M0)               r5.1<1>:f     r5.1<0;0>:f       r5.2<0;0>:f       r5.1<0>:f        {F@2}
        mov (1|M0)               r1.3<1>:d     (abs)r78.0<0;1,0>:d             
        mov (1|M0)               r1.4<1>:d     (abs)r78.1<0;1,0>:d             
        mov (1|M0)               r1.6<1>:ud    r1.5<0;1,0>:f                   
        mov (1|M0)               r4.2<1>:ud    r2.1<0;1,0>:f                    {F@2}
        mul (1|M0)               r6.0<1>:f     r5.1<0;1,0>:f     r2.1<0;1,0>:f    {F@1}
        add (1|M0)               r1.6<1>:ud    r1.4<0;1,0>:ud    -r1.6<0;1,0>:ud  {I@2}
        add (1|M0)               r4.2<1>:ud    r1.3<0;1,0>:ud    -r4.2<0;1,0>:ud  {I@2}
        mov (1|M0)               r7.0<1>:ud    r6.0<0;1,0>:f                    {F@1}
        mov (1|M0)               r2.0<1>:f     r1.6<0;1,0>:ud                   {Compacted,I@3}
        mov (1|M0)               r5.0<1>:f     r4.2<0;1,0>:ud                   {Compacted,I@2}
        mov (1|M0)               r7.1<1>:f     r7.0<0;1,0>:ud                   {Compacted,I@1}
        xor (1|M0)               r78.1<1>:d    r78.1<0;1,0>:d    r78.0<0;1,0>:d   {Compacted}
        mad (1|M0)               r2.1<1>:f     r2.1<0;0>:f       r7.1<0;0>:f       -r1.5<0>:f       {F@1}
        mad (1|M0)               r7.1<1>:f     r5.0<0;0>:f       r7.1<0;0>:f       -r2.0<0>:f      
(W)     mov (1|M0)               r4.4<1>:hf    0x1:hf                             
        add (1|M0)               r2.1<1>:f     r2.1<0;1,0>:f     r7.1<0;1,0>:f    {F@2}
        asr (1|M0)               r78.1<1>:d    r78.1<0;1,0>:d    31:w               {Compacted,I@1}
        mul (1|M0)               r5.1<1>:f     r5.1<0;1,0>:f     r2.1<0;1,0>:f    {F@1}
        mov (1|M0)               r8.0<1>:ud    r5.1<0;1,0>:f                    {F@1}
        add (1|M0)               r7.0<1>:ud    r7.0<0;1,0>:ud    r8.0<0;1,0>:ud   {Compacted,I@1}
(W)     mul (1|M0)               acc0.0<1>:ud  r7.0<0;1,0>:ud    r1.8<0;1,0>:uw   {I@1}
        mach (1|M0)              r9.0<1>:ud    r7.0<0;1,0>:ud    r1.4<0;1,0>:ud   {Compacted}
        add (1|M0)               r1.3<1>:ud    r1.3<0;1,0>:ud    -r9.0<0;1,0>:ud  {Compacted,I@1}
        cmp (1|M0)    (ge)f0.0   null<1>:ud    r1.3<0;1,0>:ud    r1.4<0;1,0>:ud   {I@1}
(f0.0)  sel (1|M0)               r6.0<1>:d     r4.4<0;1,0>:w     0:w              
        add3 (1|M0)              r7.0<1>:d     r7.0<0;0>:d       r78.1<0;0>:d      r6.0<0>:d        {I@1}
        xor (1|M0)               r45.6<1>:d    r7.0<0;1,0>:d     r78.1<0;1,0>:d   {I@1}
        mov (1|M0)               cr0.0<1>:ud   r1.2<0;1,0>:d                    {A@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        ret (16|M0)                          r78.2                            {A@1}
L8472:
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
