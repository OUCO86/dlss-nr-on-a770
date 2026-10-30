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
        mov (1|M0)               r79.4<1>:d    r0.1<0;1,0>:ud                   {A@1}
        mov (1|M0)               r42.0<1>:d    r1.0<0;1,0>:uw                   {$0.dst}
        mov (1|M0)               r79.1<1>:d    r2.2<0;1,0>:d                    {$1.dst}
        mov (1|M0)               r79.0<1>:d    r79.4<0;1,0>:d                   {I@3}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r46.6         L19272                                 {A@1}
L352:
        asr (1|M0)               r79.5<1>:d    r2.3<0;1,0>:d     31:w              
        mov (1|M0)               r42.1<1>:d    r42.2<0;1,0>:d                  
        shr (1|M0)               r79.5<1>:ud   r79.5<0;1,0>:ud   0x1B:uw              {I@2}
(W)     mul (1|M0)               acc0.0<1>:d   r42.1<0;1,0>:d    r2.4<0;1,0>:uw   {I@2}
        mach (1|M0)              r2.0<1>:d     r42.1<0;1,0>:d    r2.2<0;1,0>:d   
        add (1|M0)               r79.5<1>:d    r2.3<0;1,0>:d     r79.5<0;1,0>:d   {I@3}
        add (1|M0)               r79.4<1>:d    r79.4<0;1,0>:d    -r2.0<0;1,0>:d   {I@2}
        asr (1|M0)               r79.5<1>:d    r79.5<0;1,0>:d    5:w               {I@2}
        mov (2|M0)               r79.0<1>:d    r79.4<1;1,0>:d                   {I@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r46.6         L19272                                 {A@1}
L544:
        mov (1|M0)               r1.2<1>:d     r42.1<0;1,0>:d                  
(W)     mul (1|M0)               acc0.0<1>:d   r42.2<0;1,0>:d    r79.10<0;1,0>:uw
        asr (1|M0)               r1.3<1>:d     r42.1<0;1,0>:d    31:w              
(W)     mach (1|M0)              r2.0<1>:d     r42.2<0;1,0>:d    r79.5<0;1,0>:d  
(W)     mul (1|M0)               acc0.0<1>:d   r1.2<0;1,0>:d     r2.14<0;1,0>:uw  {I@4}
        mach (1|M0)              r5.0<1>:d     r1.2<0;1,0>:d     r2.7<0;1,0>:d   
(W)     mul (1|M0)               acc0.0<1>:d   r1.3<0;1,0>:d     r2.12<0;1,0>:uw  {I@4}
        mach (1|M0)              r6.0<1>:d     r1.3<0;1,0>:d     r2.6<0;1,0>:d   
        mul (1|M0)               acc0.0<1>:ud  r1.2<0;1,0>:ud    r2.12<0;1,0>:uw 
        mach (1|M0)              r8.0<1>:ud    r1.2<0;1,0>:ud    r2.6<0;1,0>:ud   {AccWrEn}
        shr (1|M0)               r42.7<1>:ud   r42.0<0;1,0>:ud   0x1:uw             
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        shl (1|M0)               r42.2<1>:d    r42.2<0;1,0>:d    2:w              
        shl (1|M0)               r4.2<1>:d     r7.0<0;1,0>:d     1:w               {Compacted,I@2}
        add3 (1|M0)              r1.5<1>:d     r6.0<0;0>:d       r8.0<0;0>:d       r5.0<0>:d       
        addc (1|M0)              r9.0<1>:ud    r2.4<0;1,0>:ud    r4.2<0;1,0>:ud   {AccWrEn,I@2}
        add (1|M0)               r42.2<1>:d    r42.2<0;1,0>:d    r42.7<0;1,0>:d  
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r1.2<0;1,0>:d     r3.6<0;1,0>:uw  
        mach (1|M0)              r11.0<1>:d    r1.2<0;1,0>:d     r3.3<0;1,0>:d   
(W)     mul (1|M0)               acc0.0<1>:d   r1.3<0;1,0>:d     r3.4<0;1,0>:uw  
        mach (1|M0)              r5.0<1>:d     r1.3<0;1,0>:d     r3.2<0;1,0>:d   
        mul (1|M0)               acc0.0<1>:ud  r1.2<0;1,0>:ud    r3.4<0;1,0>:uw  
        mach (1|M0)              r13.0<1>:ud   r1.2<0;1,0>:ud    r3.2<0;1,0>:ud   {AccWrEn}
        shr (1|M0)               r2.1<1>:ud    r7.0<0;1,0>:ud    0x1F:uw             
        mov (1|M0)               r12.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r42.2<0;1,0>:d    r3.8<0;1,0>:uw   {I@7}
        mach (1|M0)              r7.0<1>:d     r42.2<0;1,0>:d    r3.4<0;1,0>:d   
(W)     mul (1|M0)               acc0.0<1>:d   r42.2<0;1,0>:d    r3.8<0;1,0>:uw  
        mach (1|M0)              r43.0<1>:d    r42.2<0;1,0>:d    r3.4<0;1,0>:d   
        asr (1|M0)               r43.1<1>:d    r7.0<0;1,0>:d     31:w               {Compacted,I@3}
        mov (1|M0)               r79.5<1>:d    r2.0<0;1,0>:d                   
        mul (1|M0)               r6.1<1>:d     r42.7<0;1,0>:d    -256:w              
        shr (1|M0)               r1.3<1>:ud    r43.0<0;1,0>:ud   0x18:uw              {I@4}
        shl (1|M0)               r1.4<1>:d     r43.0<0;1,0>:d    8:w               {Compacted}
        shl (1|M0)               r2.0<1>:d     r1.5<0;1,0>:d     1:w               {Compacted}
        shl (1|M0)               r1.2<1>:d     r43.1<0;1,0>:d    8:w               {I@6}
        mov (1|M0)               r42.3<1>:d    r9.0<0;1,0>:d                   
        mad (1|M0)               r4.2<1>:d     r6.1<0;0>:d       r1.0<0;0>:uw      128:w               {I@6}
        mad (1|M0)               r5.3<1>:d     r6.1<0;0>:d       r1.0<0;0>:uw      128:w              
        shl (1|M0)               r4.5<1>:d     r1.4<0;1,0>:d     1:w               {I@6}
        or (1|M0)                r4.3<1>:d     r2.0<0;1,0>:d     r2.1<0;1,0>:d    {I@6}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@6}
        shr (1|M0)               r4.4<1>:ud    r1.4<0;1,0>:ud    0x1F:uw             
        asr (1|M0)               r5.4<1>:d     r4.2<0;1,0>:d     31:w               {I@6}
        shl (1|M0)               r42.5<1>:d    r5.3<0;1,0>:d     1:w               {I@6}
        add3 (1|M0)              r2.1<1>:d     r5.0<0;0>:d       r13.0<0;0>:d      r11.0<0>:d      
        add3 (1|M0)              r42.4<1>:d    r10.0<0;0>:d      r2.5<0;0>:d       r4.3<0>:d        {I@6}
        addc (1|M0)              r5.0<1>:ud    r42.3<0;1,0>:ud   r4.5<0;1,0>:ud   {AccWrEn}
        shl (1|M0)               r4.3<1>:d     r1.5<0;1,0>:d     1:w               {I@7}
        shr (1|M0)               r5.6<1>:ud    r5.3<0;1,0>:ud    0x1F:uw             
        shl (1|M0)               r5.5<1>:d     r5.4<0;1,0>:d     1:w               {I@7}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        or (1|M0)                r4.6<1>:d     r4.3<0;1,0>:d     r4.4<0;1,0>:d    {I@4}
        addc (1|M0)              r7.0<1>:ud    r5.0<0;1,0>:ud    r42.5<0;1,0>:ud  {AccWrEn}
        or (1|M0)                r42.6<1>:d    r5.5<0;1,0>:d     r5.6<0;1,0>:d    {I@4}
        add3 (1|M0)              r5.2<1>:d     r8.0<0;0>:d       r42.4<0;0>:d      r4.6<0>:d        {I@3}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r10.0<1>:f    r7.0<0;1,0>:f                    {Compacted,I@4}
        add3 (1|M0)              r10.1<1>:d    r9.0<0;0>:d       r5.2<0;0>:d       r42.6<0>:d       {I@1}
        shl (1|M0)               r6.0<1>:ud    r42.0<0;1,0>:ud   0x7:uw             
        send.ugm (1|M0)          r14      r10     null:0  0x0            0x0240D780           {A@1,$3} // wr:1+0, rd:4; load.ugm.d64x16t.a64
        or (1|M0)                r1.2<1>:ud    r6.0<0;1,0>:ud    0x40:uw              {I@1}
        shl (1|M0)               r8.0<1>:ud    r42.0<0;1,0>:ud   0x8:uw             
        add (1|M0)               r1.3<1>:d     r6.1<0;1,0>:d     r1.2<0;1,0>:d    {I@2}
        add (1|M0)               r1.4<1>:d     r6.1<0;1,0>:d     r1.2<0;1,0>:d   
        asr (1|M0)               r1.5<1>:d     r1.3<0;1,0>:d     31:w               {I@2}
        shl (1|M0)               r43.2<1>:d    r1.4<0;1,0>:d     1:w               {I@2}
        shr (1|M0)               r4.3<1>:ud    r1.4<0;1,0>:ud    0x1F:uw             
        shl (1|M0)               r4.2<1>:d     r1.5<0;1,0>:d     1:w               {I@3}
        addc (1|M0)              r7.0<1>:ud    r5.0<0;1,0>:ud    r43.2<0;1,0>:ud  {AccWrEn,I@3}
        or (1|M0)                r43.3<1>:d    r4.2<0;1,0>:d     r4.3<0;1,0>:d    {I@2}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        sync.nop                             null                             {Compacted,$3.src}
        mov (1|M0)               r10.0<1>:f    r7.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r10.1<1>:d    r9.0<0;0>:d       r5.2<0;0>:d       r43.3<0>:d       {I@1}
        add (1|M0)               r79.4<1>:d    r79.4<0;1,0>:d    -r79.5<0;1,0>:d 
        shr (1|M0)               r1.3<1>:ud    r42.0<0;1,0>:ud   0x2:uw             
        shl (1|M0)               r79.4<1>:d    r79.4<0;1,0>:d    1:w               {I@2}
        shl (1|M0)               r4.2<1>:d     r12.0<0;1,0>:d    1:w               {Compacted}
        add (1|M0)               r1.4<1>:d     r79.4<0;1,0>:d    r1.3<0;1,0>:d    {I@2}
        shr (1|M0)               r6.2<1>:ud    r12.0<0;1,0>:ud   0x1F:uw             
        shl (1|M0)               r6.1<1>:d     r2.1<0;1,0>:d     1:w               {Compacted}
        add (1|M0)               r43.4<1>:d    r79.4<0;1,0>:d    r1.3<0;1,0>:d   
        asr (1|M0)               r43.5<1>:d    r1.4<0;1,0>:d     31:w               {I@4}
        shl (1|M0)               r44.0<1>:d    r1.2<0;1,0>:d     1:w               {Compacted}
        or (1|M0)                r4.3<1>:d     r6.1<0;1,0>:d     r6.2<0;1,0>:d    {I@4}
        shr (1|M0)               r2.1<1>:ud    r43.4<0;1,0>:ud   0x18:uw              {I@4}
        shl (1|M0)               r5.0<1>:d     r43.4<0;1,0>:d    8:w               {Compacted}
        shl (1|M0)               r1.2<1>:ud    r42.0<0;1,0>:ud   0x6:uw             
        shl (1|M0)               r2.0<1>:d     r43.5<0;1,0>:d    8:w               {Compacted,I@6}
        and (1|M0)               r6.3<1>:ud    r1.2<0;1,0>:ud    0xC0:uw              {I@2}
        or (1|M0)                r5.1<1>:d     r2.0<0;1,0>:d     r2.1<0;1,0>:d    {I@2}
        shl (1|M0)               r44.1<1>:d    r6.3<0;1,0>:d     1:w               {I@2}
        shl (1|M0)               r5.2<1>:d     r5.1<0;1,0>:d     1:w               {I@2}
        shr (1|M0)               r6.5<1>:ud    r6.3<0;1,0>:ud    0x1F:uw             
        add (1|M0)               r45.0<1>:ud   r6.0<0;1,0>:ud    0x1000:uw             
        or (1|M0)                r44.2<1>:d    r6.5<0;1,0>:d     0:w               {I@2}
        and (1|M0)               r44.3<1>:d    r1.0<0;1,0>:uw    1:w              
        send.slm (1|M0)          null     r8      r14:4   0x0            0x0200D704           {$3} // wr:1+4, rd:0; store.slm.d64x16t.a32
        sync.nop                             null                             {Compacted,F@1}
        sync.nop                             null                             {Compacted,$3.src}
        send.ugm (1|M0)          r14      r10     null:0  0x0            0x0240D780           {$4} // wr:1+0, rd:4; load.ugm.d64x16t.a64
        addc (1|M0)              r8.0<1>:ud    r3.0<0;1,0>:ud    r4.2<0;1,0>:ud   {AccWrEn}
        shr (1|M0)               r4.2<1>:ud    r5.0<0;1,0>:ud    0x1F:uw             
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r43.6<1>:d    r8.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r43.7<1>:d    r7.0<0;0>:d       r3.1<0;0>:d       r4.3<0>:d        {I@2}
        shl (1|M0)               r4.3<1>:d     r5.0<0;1,0>:d     1:w               {Compacted}
        or (1|M0)                r4.4<1>:d     r5.2<0;1,0>:d     r4.2<0;1,0>:d   
        addc (1|M0)              r7.0<1>:ud    r43.6<0;1,0>:ud   r4.3<0;1,0>:ud   {AccWrEn,I@2}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r2.0<1>:ud    r7.0<0;1,0>:ud    r44.1<0;1,0>:ud  {AccWrEn,I@2}
        add3 (1|M0)              r6.2<1>:d     r8.0<0;0>:d       r43.7<0;0>:d      r4.4<0>:d        {I@2}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        sync.nop                             null                             {Compacted,$4.src}
        mov (1|M0)               r10.0<1>:f    r2.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r10.1<1>:d    r9.0<0;0>:d       r6.2<0;0>:d       r44.2<0>:d       {I@1}
        send.slm (1|M0)          null     r44     r14:4   0x0            0x0200D704           {$4} // wr:1+4, rd:0; store.slm.d64x16t.a32
        sync.nop                             null                             {Compacted,$4.src}
        send.ugm (1|M0)          r11      r10     null:0  0x0            0x0240D780           {A@1,$5} // wr:1+0, rd:4; load.ugm.d64x16t.a64
        send.slm (1|M0)          null     r45     r11:4   0x0            0x0200D704           {$5} // wr:1+4, rd:0; store.slm.d64x16t.a32
(W)     send.slm (1|M0)          r5       r0      null:0  0x0            0x0210001F           {$6} // wr:1+0, rd:1; fence.slm.none.group
(W)     mov (1|M0)               r8.2<1>:f     0.0:f                               {Compacted}
(W)     mov (2|M0)               r8.10<1>:ub   r0.11<0;1,0>:ub                  {F@1}
(W)     mov (8|M0)               null<1>:ud    r5.0<1;1,0>:ud                   {$6.dst}
(W)     send.gtwy (1|M0)         null     r8      null:0  0x0            0x02000004           {A@2,$7} // wr:1+0, rd:0; signal barrier
(W)     sync.bar                             null                            
        cmp (1|M0)    (gt)f1.1   null<1>:d     r3.4<0;1,0>:d     0:w              
        shl (1|M0)               r42.7<1>:d    r42.7<0;1,0>:d    9:w              
        shl (1|M0)               r44.3<1>:d    r44.3<0;1,0>:d    9:w               {Compacted}
        mov (16|M0)              r47.0<1>:f    0.0:f                               {Compacted}
(W)     and (1|M0)               f1.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
        mov (16|M0)              r49.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r51.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r53.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r55.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r57.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r59.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r61.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r63.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r65.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r67.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r69.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r71.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r73.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r75.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r77.0<1>:f    0.0:f                               {Compacted}
(~f1.1.any16h) goto (16|M0)                  L4368                  L4368                
L2568:
        addc (1|M0)              r2.0<1>:ud    r43.6<0;1,0>:ud   r44.1<0;1,0>:ud  {AccWrEn}
        mov (1|M0)               r44.4<1>:f    r3.4<0;1,0>:f                   
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r6.0<1>:ud    r42.3<0;1,0>:ud   r42.5<0;1,0>:ud  {AccWrEn}
        mov (1|M0)               r44.5<1>:d    0:w                              
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r8.0<1>:ud    r42.3<0;1,0>:ud   r43.2<0;1,0>:ud  {AccWrEn,$7.src}
        mov (1|M0)               r45.3<1>:d    r3.5<0;1,0>:d                    {$5.src}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        asr (1|M0)               r45.4<1>:d    r3.5<0;1,0>:d     31:w              
        mov (1|M0)               r46.0<2>:f    0.0:f                              
        mov (1|M0)               r46.1<2>:f    0.0:f                              
        mov (1|M0)               r45.5<1>:d    r2.0<0;1,0>:d                    {I@7}
        add3 (1|M0)              r45.6<1>:d    r5.0<0;0>:d       r43.7<0;0>:d      r44.2<0>:d       {I@7}
        mov (1|M0)               r44.6<1>:d    r6.0<0;1,0>:d                    {I@7}
        add3 (1|M0)              r44.7<1>:d    r7.0<0;0>:d       r42.4<0;0>:d      r42.6<0>:d       {I@7}
        mov (1|M0)               r45.1<1>:d    r8.0<0;1,0>:d                    {I@7}
        add3 (1|M0)              r45.2<1>:d    r9.0<0;0>:d       r42.4<0;0>:d      r43.3<0>:d       {I@7}
L2832:
        addc (1|M0)              r2.0<1>:ud    r46.0<0;1,0>:ud   0x1:ud              {AccWrEn,F@2}
(W)     mov (1|M0)               r1.3<1>:hf    0x1:hf                             
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r46.2<1>:d    r2.0<0;1,0>:d                    {I@2}
        add3 (1|M0)              r46.3<1>:d    r5.0<0;0>:d       r46.1<0;0>:d      0:w               {A@2}
        cmp (1|M0)    (lt)f1.1   null<1>:ud    r46.2<0;1,0>:ud   r44.4<0;1,0>:ud  {I@2}
        cmp (1|M0)    (eq)f0.0   null<1>:d     r46.3<0;1,0>:d    r44.5<0;1,0>:d   {I@2}
        cmp (1|M0)    (lt)f0.1   null<1>:ud    r46.3<0;1,0>:ud   r44.5<0;1,0>:ud 
        and (1|M0)               r45.7<1>:d    r46.0<0;1,0>:d    1:w               {Compacted}
(f1.1)  sel (1|M0)               r1.5<1>:uw    r1.3<0;1,0>:uw    0x0:uw              {F@1}
(f0.0)  sel (1|M0)               r1.4<1>:uw    r1.3<0;1,0>:uw    0x0:uw             
(f0.1)  sel (1|M0)               r4.5<1>:uw    r1.3<0;1,0>:uw    0x0:uw             
        and (1|M0)    (ne)f1.0   null<1>:uw    r1.4<0;1,0>:uw    r1.5<0;1,0>:uw   {I@2}
(f1.0)  sel (1|M0)               r4.4<1>:uw    r1.3<0;1,0>:uw    0x0:uw             
        or (1|M0)     (ne)f0.1   null<1>:uw    r4.4<0;1,0>:uw    r4.5<0;1,0>:uw   {I@1}
(W)     and (1|M0)               f1.0<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(~f1.0.any16h) goto (16|M0)                  L3848                  L3848                
L3088:
        addc (1|M0)              r2.0<1>:ud    r46.2<0;1,0>:ud   r43.0<0;1,0>:ud  {AccWrEn}
        xor (1|M0)               r1.2<1>:d     r45.7<0;1,0>:d    1:w              
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        shr (1|M0)               r4.2<1>:ud    r2.0<0;1,0>:ud    0x18:uw              {I@3}
        add3 (1|M0)              r1.5<1>:d     r5.0<0;0>:d       r46.3<0;0>:d      r43.1<0>:d       {I@2}
        shl (1|M0)               r4.3<1>:d     r2.0<0;1,0>:d     8:w               {Compacted}
        shl (1|M0)               r2.1<1>:d     r1.5<0;1,0>:d     8:w               {I@2}
        sync.nop                             null                             {Compacted,$8.src}
        shl (1|M0)               r6.2<1>:d     r4.3<0;1,0>:d     1:w               {I@2}
        or (1|M0)                r4.4<1>:d     r2.1<0;1,0>:d     r4.2<0;1,0>:d    {I@2}
        shr (1|M0)               r6.1<1>:ud    r4.3<0;1,0>:ud    0x1F:uw             
        addc (1|M0)              r7.0<1>:ud    r44.6<0;1,0>:ud   r6.2<0;1,0>:ud   {AccWrEn,I@3}
        shl (1|M0)               r6.0<1>:d     r4.4<0;1,0>:d     1:w               {Compacted,I@3}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        or (1|M0)                r6.3<1>:d     r6.0<0;1,0>:d     r6.1<0;1,0>:d    {I@2}
        mov (1|M0)               r9.0<1>:f     r7.0<0;1,0>:f                    {Compacted}
        add3 (1|M0)              r9.1<1>:d     r8.0<0;0>:d       r44.7<0;0>:d      r6.3<0>:d        {I@1}
        addc (1|M0)              r2.0<1>:ud    r45.1<0;1,0>:ud   r6.2<0;1,0>:ud   {AccWrEn}
        send.ugm (1|M0)          r10      r9      null:0  0x0            0x0240D780           {A@1,$10} // wr:1+0, rd:4; load.ugm.d64x16t.a64
        mov (1|M0)               r14.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r15.0<1>:f    r2.0<0;1,0>:f                    {Compacted,I@2}
        add3 (1|M0)              r15.1<1>:d    r14.0<0;0>:d      r45.2<0;0>:d      r6.3<0>:d        {I@1}
        shl (1|M0)               r1.3<1>:d     r1.2<0;1,0>:d     11:w              
        send.ugm (1|M0)          r16      r15     null:0  0x0            0x0240D780           {A@1,$11} // wr:1+0, rd:4; load.ugm.d64x16t.a64
(W)     mul (1|M0)               acc0.0<1>:d   r46.2<0;1,0>:d    r45.8<0;1,0>:uw 
        mad (1|M0)               r5.0<1>:d     r1.3<0;0>:d       r1.0<0;0>:uw      256:w               {I@2}
        mach (1|M0)              r8.0<1>:d     r46.2<0;1,0>:d    r45.4<0;1,0>:d  
(W)     mul (1|M0)               acc0.0<1>:d   r46.3<0;1,0>:d    r45.6<0;1,0>:uw 
        add (1|M0)               r7.0<1>:d     r1.3<0;1,0>:d     r44.0<0;1,0>:d   {Compacted}
        shl (1|M0)               r1.2<1>:d     r1.2<0;1,0>:d     10:w              
        add (1|M0)               r2.0<1>:d     r1.2<0;1,0>:d     r45.0<0;1,0>:d   {Compacted,I@1}
        send.slm (1|M0)          null     r5      r10:4   0x0            0x0200D704           {$10} // wr:1+4, rd:0; store.slm.d64x16t.a32
        mach (1|M0)              r5.0<1>:d     r46.3<0;1,0>:d    r45.3<0;1,0>:d   {$10.src}
        mul (1|M0)               acc0.0<1>:ud  r46.2<0;1,0>:ud   r45.6<0;1,0>:uw 
        mach (1|M0)              r10.0<1>:ud   r46.2<0;1,0>:ud   r45.3<0;1,0>:ud  {AccWrEn}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        add3 (1|M0)              r2.1<1>:d     r5.0<0;0>:d       r10.0<0;0>:d      r8.0<0>:d        {I@2}
        addc (1|M0)              r6.0<1>:ud    r9.0<0;1,0>:ud    r43.4<0;1,0>:ud  {AccWrEn,I@2}
        send.slm (1|M0)          null     r7      r16:4   0x0            0x0200D704           {$11} // wr:1+4, rd:0; store.slm.d64x16t.a32
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        shr (1|M0)               r4.3<1>:ud    r6.0<0;1,0>:ud    0x18:uw              {I@2}
        add3 (1|M0)              r1.4<1>:d     r11.0<0;0>:d      r2.1<0;0>:d       r43.5<0>:d       {I@2}
        shl (1|M0)               r4.4<1>:d     r6.0<0;1,0>:d     8:w               {Compacted}
        shl (1|M0)               r4.2<1>:d     r1.4<0;1,0>:d     8:w               {I@2}
        sync.nop                             null                             {Compacted,$11.src}
        shl (1|M0)               r7.2<1>:d     r4.4<0;1,0>:d     1:w               {I@2}
        or (1|M0)                r4.5<1>:d     r4.2<0;1,0>:d     r4.3<0;1,0>:d    {I@2}
        shr (1|M0)               r7.1<1>:ud    r4.4<0;1,0>:ud    0x1F:uw             
        addc (1|M0)              r5.0<1>:ud    r45.5<0;1,0>:ud   r7.2<0;1,0>:ud   {AccWrEn,I@3}
        shl (1|M0)               r7.0<1>:d     r4.5<0;1,0>:d     1:w               {Compacted,I@3}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        or (1|M0)                r7.3<1>:d     r7.0<0;1,0>:d     r7.1<0;1,0>:d    {I@2}
        mov (1|M0)               r9.0<1>:f     r5.0<0;1,0>:f                    {Compacted}
        add3 (1|M0)              r9.1<1>:d     r8.0<0;0>:d       r45.6<0;0>:d      r7.3<0>:d        {I@1}
        send.ugm (1|M0)          r10      r9      null:0  0x0            0x0240D780           {A@1,$12} // wr:1+0, rd:4; load.ugm.d64x16t.a64
        send.slm (1|M0)          null     r2      r10:4   0x0            0x0200D704           {$12} // wr:1+4, rd:0; store.slm.d64x16t.a32
L3848:
        join (16|M0)                         L4368                                
L3864:
        shl (1|M0)               r1.2<1>:d     r45.7<0;1,0>:d    11:w              
        shl (1|M0)               r45.7<1>:d    r45.7<0;1,0>:d    10:w              
        sync.nop                             null                             {Compacted,$12.src}
        add (1|M0)               r2.0<1>:d     r1.2<0;1,0>:d     r42.7<0;1,0>:d   {I@2}
        bfn.0xFE (1|M0)          r5.0<1>:ud    0x1000:uw               r45.7<0;0>:ud     r44.3<0>:ud      {I@2} // s0|s1|s2
        bfn.0xFE (1|M0)          r31.0<1>:ud   0x1100:uw               r45.7<0;0>:ud     r44.3<0>:ud      // s0|s1|s2
        or (1|M0)                r14.0<1>:ud   r2.0<0;1,0>:ud    0x100:uw              {I@3}
        sync.nop                             null                             {Compacted,$8.src}
        send.slm (1|M0)          r6       r2      null:0  0x0            0x0280E700           {$13} // wr:1+0, rd:8; load.slm.d64x32t.a32
        send.slm (1|M0)          r23      r5      null:0  0x0            0x0280E700           {A@3,$14} // wr:1+0, rd:8; load.slm.d64x32t.a32
        send.slm (1|M0)          r32      r31     null:0  0x0            0x0280E700           {A@2,$15} // wr:1+0, rd:8; load.slm.d64x32t.a32
        send.slm (1|M0)          r15      r14     null:0  0x0            0x0280E700           {A@1,$0} // wr:1+0, rd:8; load.slm.d64x32t.a32
        sync.allwr                           ($0,$8,$13,$14,$15)                
        dpas.8x8 (8|M0)          r71:f         null:f            r71:hf            r71.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r71:f         r71:f             r23:hf            r6.0:hf          {Atomic}
        dpas.8x8 (8|M0)          r63:f         r63:f             r32:hf            r6.0:hf          {Atomic}
        dpas.8x8 (8|M0)          r55:f         r55:f             r23:hf            r15.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r47:f         r47:f             r32:hf            r15.0:hf         {$8}
(W)     send.slm (1|M0)          r40      r0      null:0  0x0            0x0210001F           {$1} // wr:1+0, rd:1; fence.slm.none.group
(W)     mov (1|M0)               r41.2<1>:f    0.0:f                               {Compacted,$9.src}
(W)     mov (2|M0)               r41.10<1>:ub  r0.11<0;1,0>:ub                  {F@1}
(W)     mov (8|M0)               null<1>:ud    r40.0<1;1,0>:ud                  {$1.dst}
(W)     send.gtwy (1|M0)         null     r41     null:0  0x0            0x02000004           {A@2,$9} // wr:1+0, rd:0; signal barrier
(W)     sync.bar                             null                            
        cmp (1|M0)    (eq)f1.0   null<1>:d     r46.2<0;1,0>:d    r44.4<0;1,0>:d  
(W)     mov (1|M0)               r1.3<1>:hf    0x1:hf                             
(f0.0)  sel (1|M0)               r2.0<1>:uw    r1.3<0;1,0>:uw    0x0:uw              {F@1}
(f1.0)  sel (1|M0)               r1.4<1>:uw    r1.3<0;1,0>:uw    0x0:uw             
        and (1|M0)    (ne)f0.0   null<1>:uw    r1.4<0;1,0>:uw    r2.0<0;1,0>:uw   {I@1}
(W)     and (1|M0)               f0.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
(f0.1.any16h) goto (16|M0)                   L4368                  L4368                
L4336:
(W)     mov (2|M0)               r46.0<1>:ud   r46.2<1;1,0>:ud                 
        goto.b (16|M0)                       L4368                  L2832                
L4368:
        join (16|M0)                         L4384                                
L4384:
        mov (1|M0)               r80.1<1>:f    r42.1<0;1,0>:f                   {Compacted}
        mov (1|M0)               r46.4<1>:d    r3.6<0;1,0>:d                   
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r79.2         L19824                                 {A@1}
L4456:
(W)     mul (1|M0)               acc0.0<1>:d   r46.5<0;1,0>:d    r3.12<0;1,0>:uw 
        mach (1|M0)              r2.0<1>:d     r46.5<0;1,0>:d    r3.6<0;1,0>:d   
        shl (1|M0)               r1.3<1>:d     r46.5<0;1,0>:d    6:w              
        add (1|M0)               r42.1<1>:d    r42.1<0;1,0>:d    -r2.0<0;1,0>:d   {Compacted,A@1}
        asr (1|M0)               r4.3<1>:d     r42.2<0;1,0>:d    31:w              
        shl (1|M0)               r5.2<1>:d     r42.2<0;1,0>:d    4:w              
        bfn.0xEA (1|M0)          r79.4<1>:ud   r79.4<0;0>:ud     r42.0<0;0>:ud     0x1:uw              // s0|s1&s2
        shl (1|M0)               r2.0<1>:d     r42.1<0;1,0>:d    5:w               {Compacted,I@4}
        shr (1|M0)               r1.2<1>:ud    r46.5<0;1,0>:ud   0x1A:uw             
        shl (1|M0)               r5.0<1>:d     r4.3<0;1,0>:d     4:w               {Compacted,I@5}
        addc (1|M0)              r6.0<1>:ud    r1.3<0;1,0>:ud    r5.2<0;1,0>:ud   {AccWrEn,I@5}
        shl (1|M0)               r8.0<1>:ud    r79.4<0;1,0>:ud   0x4:uw              {I@5}
        shl (1|M0)               r4.3<1>:d     r2.0<0;1,0>:d     1:w               {Compacted,I@5}
        shr (1|M0)               r5.1<1>:ud    r42.2<0;1,0>:ud   0x1C:uw             
        sel (8|M0)    (lt)f0.0   r11.0<1>:f    (abs)r71.0<1;1,0>:f  448.0:f            {Compacted}
        or (1|M0)                r1.4<1>:d     r1.2<0;1,0>:d     0:w               {I@6}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        shl (1|M0)               r1.2<1>:d     r8.0<0;1,0>:d     1:w               {Compacted,I@5}
        addc (1|M0)              r9.0<1>:ud    r4.0<0;1,0>:ud    r4.3<0;1,0>:ud   {AccWrEn,I@5}
        shr (1|M0)               r4.2<1>:ud    r2.0<0;1,0>:ud    0x1F:uw             
        or (1|M0)                r5.3<1>:d     r5.0<0;1,0>:d     r5.1<0;1,0>:d    {I@6}
        shr (8|M0)               r12.0<1>:ud   r11.0<1;1,0>:ud   0x17:uw              {F@1}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r5.0<1>:ud    r9.0<0;1,0>:ud    r1.2<0;1,0>:ud   {AccWrEn,I@5}
        sel (8|M0)    (lt)f0.0   r9.0<1>:f     (abs)r63.0<1;1,0>:f  448.0:f            {Compacted,I@1}
        or (1|M0)                r4.4<1>:d     r4.2<0;1,0>:d     0:w              
        add3 (1|M0)              r7.2<1>:d     r7.0<0;0>:d       r1.4<0;0>:d       r5.3<0>:d       
        sel (8|M0)    (ge)f0.0   r5.12<2>:ub   r12.0<4;1,0>:ub   0x79:uw             
        shr (8|M0)               r12.0<1>:ud   r9.0<1;1,0>:ud    0x17:uw              {F@1}
        add3 (1|M0)              r8.5<1>:d     r10.0<0;0>:d      r4.1<0;0>:d       r4.4<0>:d        {I@4}
        mov (8|M0)               r13.0<1>:d    r5.12<2;1,0>:ub                  {I@3}
        sel (8|M0)    (ge)f0.0   r4.8<2>:ub    r12.0<4;1,0>:ub   0x79:uw              {I@3}
        shl (8|M0)               r13.0<1>:d    r13.0<1;1,0>:d    23:w               {Compacted,I@2}
        mov (8|M0)               r14.0<1>:d    r4.8<2;1,0>:ub                   {I@2}
        add (8|M0)               r10.0<1>:d    r13.0<1;1,0>:d    -25165824:d               {I@2}
        add (8|M0)               r13.0<1>:d    -r13.0<1;1,0>:d   -2139095040:d              
        shl (8|M0)               r14.0<1>:d    r14.0<1;1,0>:d    23:w               {Compacted,I@3}
        mul (8|M0)               acc2.0<1>:f   r11.0<1;1,0>:f    r13.0<1;1,0>:f   {Compacted,I@2}
        add (8|M0)               r13.0<1>:d    r14.0<1;1,0>:d    -25165824:d               {A@1}
        add (8|M0)               r14.0<1>:d    -r14.0<1;1,0>:d   -2139095040:d              
        mov (1|M0)               r7.1<1>:d     r6.0<0;1,0>:d                   
        rnde (8|M0)              acc2.0<1>:f   acc2.0<1;1,0>:f                 
        shr (1|M0)               r6.0<1>:ud    r8.0<0;1,0>:ud    0x1F:uw             
        mul (8|M0)               acc3.0<1>:f   r9.0<1;1,0>:f     r14.0<1;1,0>:f   {Compacted,I@3}
        cmp (8|M0)    (lt)f1.1   null<1>:f     r71.0<1;1,0>:f    0.0:f              
        or (1|M0)                r1.3<1>:d     r6.0<0;1,0>:d     0:w               {Compacted,I@1}
        rnde (8|M0)              acc3.0<1>:f   acc3.0<1;1,0>:f                 
        mul (8|M0)               acc2.0<1>:f   acc2.0<1;1,0>:f   r10.0<1;1,0>:f   {Compacted}
        cmp (8|M0)    (lt)f1.0   null<1>:f     r63.0<1;1,0>:f    0.0:f              
        mul (8|M0)               acc3.0<1>:f   acc3.0<1;1,0>:f   r13.0<1;1,0>:f   {Compacted}
        mov (8|M0)               r6.0<1>:f     (abs)acc2.0<1;1,0>:f             {Compacted,I@1}
        mov (8|M0)               r10.0<1>:f    (abs)acc3.0<1;1,0>:f             {Compacted}
(f1.1)  or (8|M0)                r6.0<1>:d     r6.0<1;1,0>:d     -2147483648:d               {F@2}
(f1.0)  or (8|M0)                r10.0<1>:d    r10.0<1;1,0>:d    -2147483648:d               {F@1}
        mov (8|M0)               r1.8<1>:hf    r6.0<1;1,0>:f                    {I@2}
        sel (8|M0)    (lt)f0.0   r6.0<1>:f     (abs)r55.0<1;1,0>:f  448.0:f            {Compacted}
        mov (8|M0)               r5.8<1>:hf    r10.0<1;1,0>:f                   {I@1}
        shr (8|M0)               r11.0<1>:ud   r6.0<1;1,0>:ud    0x17:uw              {F@2}
        sel (8|M0)    (lt)f0.0   r10.0<1>:f    (abs)r47.0<1;1,0>:f  448.0:f            {Compacted}
        sel (8|M0)    (ge)f0.0   r4.8<2>:ub    r11.0<4;1,0>:ub   0x79:uw              {I@1}
        shr (8|M0)               r11.0<1>:ud   r10.0<1;1,0>:ud   0x17:uw              {F@1}
        mov (8|M0)               r12.0<1>:d    r4.8<2;1,0>:ub                   {I@2}
        sel (8|M0)    (ge)f0.0   r4.8<2>:ub    r11.0<4;1,0>:ub   0x79:uw              {I@2}
        shl (8|M0)               r12.0<1>:d    r12.0<1;1,0>:d    23:w               {Compacted,I@2}
        mov (8|M0)               r13.0<1>:d    r4.8<2;1,0>:ub                   {I@2}
        add (8|M0)               r14.0<1>:d    r12.0<1;1,0>:d    -25165824:d               {I@2}
        add (8|M0)               r12.0<1>:d    -r12.0<1;1,0>:d   -2139095040:d              
        shl (8|M0)               r13.0<1>:d    r13.0<1;1,0>:d    23:w               {Compacted,I@3}
        mov (1|M0)               r8.2<1>:d     r3.7<0;1,0>:d                   
        mul (8|M0)               acc2.0<1>:f   r6.0<1;1,0>:f     r12.0<1;1,0>:f   {Compacted,I@3}
        add (8|M0)               r12.0<1>:d    r13.0<1;1,0>:d    -25165824:d               {A@1}
        add (8|M0)               r13.0<1>:d    -r13.0<1;1,0>:d   -2139095040:d              
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mul (8|M0)               r10.0<1>:f    r10.0<1;1,0>:f    r13.0<1;1,0>:f   {Compacted,I@2}
(W)     mul (1|M0)               acc0.0<1>:d   r7.2<0;1,0>:d     r8.4<0;1,0>:uw  
        mach (1|M0)              r2.0<1>:d     r7.2<0;1,0>:d     r8.2<0;1,0>:d   
        mul (1|M0)               acc0.0<1>:ud  r7.1<0;1,0>:ud    r8.4<0;1,0>:uw  
        rnde (8|M0)              acc2.0<1>:f   acc2.0<1;1,0>:f                 
        rnde (8|M0)              acc3.0<1>:f   r10.0<1;1,0>:f                   {F@2}
        mach (1|M0)              r15.0<1>:ud   r7.1<0;1,0>:ud    r8.2<0;1,0>:ud   {AccWrEn}
        cmp (8|M0)    (lt)f0.0   null<1>:f     r47.0<1;1,0>:f    0.0:f               {Compacted}
        mul (8|M0)               acc2.0<1>:f   acc2.0<1;1,0>:f   r14.0<1;1,0>:f   {Compacted}
        mul (8|M0)               acc3.0<1>:f   acc3.0<1;1,0>:f   r12.0<1;1,0>:f   {Compacted}
        mov (1|M0)               r14.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,F@2}
        add3 (1|M0)              r5.2<1>:d     r7.0<0;0>:d       r8.5<0;0>:d       r1.3<0>:d        {I@6}
        mov (8|M0)               r6.0<1>:f     (abs)acc3.0<1;1,0>:f             {Compacted}
        add3 (1|M0)              r1.3<1>:d     r2.0<0;0>:d       r15.0<0;0>:d      0:w               {I@3}
        shl (1|M0)               r4.4<1>:d     r14.0<0;1,0>:d    1:w               {Compacted,I@3}
        cmp (8|M0)    (lt)f0.1   null<1>:f     r55.0<1;1,0>:f    0.0:f              
        shr (1|M0)               r4.3<1>:ud    r14.0<0;1,0>:ud   0x1F:uw             
(f0.0)  or (8|M0)                r6.0<1>:d     r6.0<1;1,0>:d     -2147483648:d               {F@2}
        shl (1|M0)               r4.2<1>:d     r1.3<0;1,0>:d     1:w               {I@4}
        addc (1|M0)              r7.0<1>:ud    r5.0<0;1,0>:ud    r4.4<0;1,0>:ud   {AccWrEn,I@4}
        mov (8|M0)               r11.0<1>:uw   0xECA86420:uv                             
        mov (8|M0)               r9.0<1>:f     (abs)acc2.0<1;1,0>:f             {Compacted}
        mov (8|M0)               r8.8<1>:hf    r6.0<1;1,0>:f                    {I@4}
        or (1|M0)                r4.5<1>:d     r4.2<0;1,0>:d     r4.3<0;1,0>:d    {I@3}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,F@1}
        mov (8|M0)               r12.0<4>:uw   r11.0<1;1,0>:uw                  {I@3}
(f0.1)  or (8|M0)                r9.0<1>:d     r9.0<1;1,0>:d     -2147483648:d              
        mov (1|M0)               r6.2<1>:d     r7.0<0;1,0>:d                   
        add3 (1|M0)              r6.3<1>:d     r6.0<0;0>:d       r5.2<0;0>:d       r4.5<0>:d        {I@4}
        mov (8|M0)               r16.0<2>:ud   r12.0<4;1,0>:uw                  {I@4}
        mov (8|M0)               r7.8<1>:hf    r9.0<1;1,0>:f                    {I@4}
        mov (8|M0)               r16.1<2>:ud   0.0:f                              
        mov (8|M0)               r9.0<2>:ud    r6.2<0;1,0>:ud                   {A@1}
        mov (8|M0)               r9.1<2>:ud    r6.3<0;1,0>:ud                   {I@4}
        mov (8|M0)               r22.0<1>:d    r1.8<1;1,0>:uw                  
        addc (8|M0)              r14.0<1>:ud   r9.0<2;1,0>:ud    r16.0<2;1,0>:ud  {AccWrEn,Compacted,I@2}
        mov (8|M0)               r20.0<1>:d    r16.1<2;1,0>:d                  
        mov (8|M0)               r15.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        addc (1|M0)              r2.0<1>:ud    r6.2<0;1,0>:ud    0x10:ud              {AccWrEn}
        mov (2|M0)               r1.8<1>:w     0x8080808:uv                             
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r4.2<1>:d     r2.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r4.3<1>:d     r6.0<0;0>:d       r6.3<0;0>:d       0:w               {I@2}
        mov (8|M0)               r11.0<2>:ud   r4.2<0;1,0>:ud                   {I@2}
        mov (8|M0)               r11.1<2>:ud   r4.3<0;1,0>:ud                   {I@2}
        add3 (8|M0)              r21.0<1>:d    r15.0<1;0>:d      r9.1<4;2>:d       r20.0<1>:d      
        or (2|M0)                r2.0<1>:ud    r7.1<1;1,0>:ud    r1.8<1;1,0>:w   
        addc (8|M0)              r13.0<1>:ud   r11.0<2;1,0>:ud   r16.0<2;1,0>:ud  {AccWrEn,Compacted,I@3}
        mov (8|M0)               r18.0<2>:d    r14.0<1;1,0>:d                  
        mov (8|M0)               r18.1<2>:d    r21.0<1;1,0>:d                   {I@4}
        mov (8|M0)               r14.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r2.1<0;1,0>:d     r8.4<0;1,0>:uw   {I@5}
        mach (1|M0)              r6.0<1>:d     r2.1<0;1,0>:d     r8.2<0;1,0>:d   
        mul (1|M0)               acc0.0<1>:ud  r2.0<0;1,0>:ud    r8.4<0;1,0>:uw  
        send.ugm (8|M0)          null     r18     r22:1   0x0            0x04000B84           {A@5,$2} // wr:2+1, rd:0; store.ugm.d16u32.a64
        mach (1|M0)              r19.0<1>:ud   r2.0<0;1,0>:ud    r8.2<0;1,0>:ud   {AccWrEn,$2.src}
        add3 (8|M0)              r9.0<1>:d     r14.0<1;0>:d      r11.1<4;2>:d      r20.0<1>:d       {I@5}
        mov (1|M0)               r18.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        add3 (1|M0)              r4.3<1>:d     r6.0<0;0>:d       r19.0<0;0>:d      0:w               {I@3}
        shl (1|M0)               r5.3<1>:d     r18.0<0;1,0>:d    1:w               {Compacted,I@2}
        shr (1|M0)               r7.3<1>:ud    r18.0<0;1,0>:ud   0x1F:uw             
        shl (1|M0)               r7.0<1>:d     r4.3<0;1,0>:d     1:w               {Compacted,I@3}
        addc (1|M0)              r8.0<1>:ud    r5.0<0;1,0>:ud    r5.3<0;1,0>:ud   {AccWrEn,I@3}
        mov (8|M0)               r10.0<1>:d    r5.8<1;1,0>:uw                  
        mov (8|M0)               r23.0<2>:d    r13.0<1;1,0>:d                  
        or (1|M0)                r5.4<1>:d     r7.0<0;1,0>:d     r7.3<0;1,0>:d    {I@4}
        mov (8|M0)               r23.1<2>:d    r9.0<1;1,0>:d                   
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r1.2<1>:d     r8.0<0;1,0>:d                    {I@6}
        add3 (1|M0)              r1.3<1>:d     r9.0<0;0>:d       r5.2<0;0>:d       r5.4<0>:d        {I@2}
        send.ugm (8|M0)          null     r23     r10:1   0x0            0x04000B84           {$3} // wr:2+1, rd:0; store.ugm.d16u32.a64
        sync.nop                             null                             {Compacted,$3.src}
        mov (8|M0)               r10.0<2>:ud   r1.2<0;1,0>:ud                   {I@2}
        mov (8|M0)               r10.1<2>:ud   r1.3<0;1,0>:ud                   {I@2}
        mov (8|M0)               r18.0<1>:d    r7.8<1;1,0>:uw                  
        addc (8|M0)              r12.0<1>:ud   r10.0<2;1,0>:ud   r16.0<2;1,0>:ud  {AccWrEn,Compacted,I@2}
        cmp (8|M0)    (lt)f1.1   null<1>:f     r72.0<1;1,0>:f    0.0:f              
        mov (8|M0)               r6.0<1>:ud    acc0.0<1;1,0>:ud                 {Compacted}
        addc (1|M0)              r2.0<1>:ud    r1.2<0;1,0>:ud    0x10:ud              {AccWrEn}
        add3 (8|M0)              r15.0<1>:d    r6.0<1;0>:d       r10.1<4;2>:d      r20.0<1>:d       {I@2}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r1.4<1>:d     r2.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r1.5<1>:d     r8.0<0;0>:d       r1.3<0;0>:d       0:w               {I@2}
        sel (8|M0)    (lt)f0.0   r11.0<1>:f    (abs)r72.0<1;1,0>:f  448.0:f            {Compacted}
        mov (8|M0)               r21.0<2>:ud   r1.4<0;1,0>:ud                   {I@2}
        mov (8|M0)               r21.1<2>:ud   r1.5<0;1,0>:ud                   {I@2}
        mov (8|M0)               r13.0<2>:d    r12.0<1;1,0>:d                  
        addc (8|M0)              r9.0<1>:ud    r21.0<2;1,0>:ud   r16.0<2;1,0>:ud  {AccWrEn,Compacted,I@2}
        shr (8|M0)               r12.0<1>:ud   r11.0<1;1,0>:ud   0x17:uw              {F@1}
        mov (8|M0)               r13.1<2>:d    r15.0<1;1,0>:d                  
        mov (8|M0)               r19.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        sel (8|M0)    (ge)f0.0   r4.8<2>:ub    r12.0<4;1,0>:ub   0x79:uw              {I@3}
        send.ugm (8|M0)          null     r13     r18:1   0x0            0x04000B84           {A@3,$4} // wr:2+1, rd:0; store.ugm.d16u32.a64
        add3 (8|M0)              r6.0<1>:d     r19.0<1;0>:d      r21.1<4;2>:d      r20.0<1>:d       {I@2}
        sync.nop                             null                             {Compacted,$4.src}
        mov (8|M0)               r13.0<1>:d    r4.8<2;1,0>:ub                   {I@2}
        mov (8|M0)               r10.0<1>:d    r8.8<1;1,0>:uw                  
        mov (8|M0)               r23.0<2>:d    r9.0<1;1,0>:d                   
        shl (8|M0)               r13.0<1>:d    r13.0<1;1,0>:d    23:w               {Compacted,I@3}
        mov (8|M0)               r23.1<2>:d    r6.0<1;1,0>:d                   
        sel (8|M0)    (lt)f0.0   r6.0<1>:f     (abs)r64.0<1;1,0>:f  448.0:f            {Compacted,I@1}
        send.ugm (8|M0)          null     r23     r10:1   0x0            0x04000B84           {$5} // wr:2+1, rd:0; store.ugm.d16u32.a64
        add (8|M0)               r14.0<1>:d    r13.0<1;1,0>:d    -25165824:d              
        sync.nop                             null                             {Compacted,$5.src}
        shr (8|M0)               r10.0<1>:ud   r6.0<1;1,0>:ud    0x17:uw              {F@1}
        add (8|M0)               r13.0<1>:d    -r13.0<1;1,0>:d   -2139095040:d              
        sel (8|M0)    (ge)f0.0   r4.8<2>:ub    r10.0<4;1,0>:ub   0x79:uw              {I@2}
        mul (8|M0)               acc0.0<1>:f   r11.0<1;1,0>:f    r13.0<1;1,0>:f   {Compacted,I@2}
        mov (8|M0)               r12.0<1>:d    r4.8<2;1,0>:ub                   {I@1}
        rnde (8|M0)              acc0.0<1>:f   acc0.0<1;1,0>:f                 
        shl (8|M0)               r12.0<1>:d    r12.0<1;1,0>:d    23:w               {Compacted,I@1}
        mul (8|M0)               acc0.0<1>:f   acc0.0<1;1,0>:f   r14.0<1;1,0>:f   {Compacted}
        add (8|M0)               r13.0<1>:d    r12.0<1;1,0>:d    -25165824:d               {A@1}
        mov (8|M0)               r9.0<1>:f     (abs)acc0.0<1;1,0>:f             {Compacted}
        add (8|M0)               r12.0<1>:d    -r12.0<1;1,0>:d   -2139095040:d              
(f1.1)  or (8|M0)                r9.0<1>:d     r9.0<1;1,0>:d     -2147483648:d               {F@1}
        mul (8|M0)               acc0.0<1>:f   r6.0<1;1,0>:f     r12.0<1;1,0>:f   {Compacted,I@2}
        mov (8|M0)               r1.8<1>:hf    r9.0<1;1,0>:f                    {I@1}
        rnde (8|M0)              acc0.0<1>:f   acc0.0<1;1,0>:f                 
        sel (8|M0)    (lt)f0.0   r9.0<1>:f     (abs)r56.0<1;1,0>:f  448.0:f            {Compacted}
        cmp (8|M0)    (lt)f1.0   null<1>:f     r64.0<1;1,0>:f    0.0:f              
        mul (8|M0)               acc0.0<1>:f   acc0.0<1;1,0>:f   r13.0<1;1,0>:f   {Compacted}
        shr (8|M0)               r10.0<1>:ud   r9.0<1;1,0>:ud    0x17:uw              {F@3}
        mov (8|M0)               r11.0<1>:f    (abs)acc0.0<1;1,0>:f             {Compacted}
        sel (8|M0)    (ge)f0.0   r4.8<2>:ub    r10.0<4;1,0>:ub   0x79:uw              {I@1}
(f1.0)  or (8|M0)                r11.0<1>:d    r11.0<1;1,0>:d    -2147483648:d               {F@1}
        sel (8|M0)    (lt)f0.0   r10.0<1>:f    (abs)r48.0<1;1,0>:f  448.0:f            {Compacted,I@2}
        mov (8|M0)               r14.0<1>:d    r4.8<2;1,0>:ub                  
        mov (8|M0)               r5.8<1>:hf    r11.0<1;1,0>:f                   {I@2}
        shl (8|M0)               r14.0<1>:d    r14.0<1;1,0>:d    23:w               {Compacted,I@1}
        shr (8|M0)               r11.0<1>:ud   r10.0<1;1,0>:ud   0x17:uw              {A@1}
        add (8|M0)               r12.0<1>:d    r14.0<1;1,0>:d    -25165824:d               {I@2}
        add (8|M0)               r14.0<1>:d    -r14.0<1;1,0>:d   -2139095040:d              
        sel (8|M0)    (ge)f0.0   r4.8<2>:ub    r11.0<4;1,0>:ub   0x79:uw              {I@3}
        mov (2|M0)               r2.0<1>:w     0x1010101:v                              
        mul (8|M0)               acc0.0<1>:f   r9.0<1;1,0>:f     r14.0<1;1,0>:f   {Compacted,I@3}
        mov (8|M0)               r13.0<1>:d    r4.8<2;1,0>:ub                   {I@2}
        or (2|M0)                r1.2<1>:ud    r7.1<1;1,0>:ud    r2.0<1;1,0>:w    {I@2}
        rnde (8|M0)              r9.0<1>:f     acc0.0<1;1,0>:f                  {Compacted}
        shl (8|M0)               r13.0<1>:d    r13.0<1;1,0>:d    23:w               {Compacted,I@2}
        cmp (8|M0)    (lt)f0.1   null<1>:f     r56.0<1;1,0>:f    0.0:f              
(W)     mul (1|M0)               acc0.0<1>:d   r1.3<0;1,0>:d     r8.4<0;1,0>:uw   {A@2}
        mul (8|M0)               acc2.0<1>:f   r9.0<1;1,0>:f     r12.0<1;1,0>:f   {Compacted}
        add (8|M0)               r14.0<1>:d    r13.0<1;1,0>:d    -25165824:d               {I@2}
        add (8|M0)               r13.0<1>:d    -r13.0<1;1,0>:d   -2139095040:d              
        mach (1|M0)              r7.0<1>:d     r1.3<0;1,0>:d     r8.2<0;1,0>:d   
        mul (1|M0)               acc0.0<1>:ud  r1.2<0;1,0>:ud    r8.4<0;1,0>:uw  
        mov (8|M0)               r6.0<1>:f     (abs)acc2.0<1;1,0>:f             {Compacted}
        mul (8|M0)               acc2.0<1>:f   r10.0<1;1,0>:f    r13.0<1;1,0>:f   {Compacted,I@3}
        mach (1|M0)              r12.0<1>:ud   r1.2<0;1,0>:ud    r8.2<0;1,0>:ud   {AccWrEn,F@3}
(f0.1)  or (8|M0)                r6.0<1>:d     r6.0<1;1,0>:d     -2147483648:d               {F@2}
        rnde (8|M0)              acc2.0<1>:f   acc2.0<1;1,0>:f                 
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        cmp (8|M0)    (lt)f0.0   null<1>:f     r48.0<1;1,0>:f    0.0:f               {Compacted}
        add3 (1|M0)              r4.3<1>:d     r7.0<0;0>:d       r12.0<0;0>:d      0:w               {I@3}
        mov (8|M0)               r7.8<1>:hf    r6.0<1;1,0>:f                    {I@3}
        mul (8|M0)               acc0.0<1>:f   acc2.0<1;1,0>:f   r14.0<1;1,0>:f   {Compacted,I@2}
        shl (1|M0)               r6.5<1>:d     r11.0<0;1,0>:d    1:w               {Compacted,F@2}
        shl (1|M0)               r5.3<1>:d     r4.3<0;1,0>:d     1:w               {Compacted,I@2}
        shr (1|M0)               r6.4<1>:ud    r11.0<0;1,0>:ud   0x1F:uw             
        mov (8|M0)               r9.0<1>:f     (abs)acc0.0<1;1,0>:f             {Compacted}
        addc (1|M0)              r8.0<1>:ud    r5.0<0;1,0>:ud    r6.5<0;1,0>:ud   {AccWrEn,A@1}
        or (1|M0)                r6.6<1>:d     r5.3<0;1,0>:d     r6.4<0;1,0>:d    {I@2}
(f0.0)  or (8|M0)                r9.0<1>:d     r9.0<1;1,0>:d     -2147483648:d              
        mov (1|M0)               r2.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (8|M0)               r6.0<1>:hf    r9.0<1;1,0>:f                    {I@2}
        mov (1|M0)               r9.0<1>:f     r8.0<0;1,0>:f                    {Compacted}
        add3 (1|M0)              r9.1<1>:d     r2.0<0;0>:d       r5.2<0;0>:d       r6.6<0>:d        {A@1}
        mov (8|M0)               r13.0<2>:f    r9.0<0;1,0>:f                    {Compacted,F@1}
        mov (8|M0)               r13.1<2>:f    r9.1<0;1,0>:f                    {Compacted,I@1}
        mov (8|M0)               r11.0<1>:d    r1.8<1;1,0>:uw                  
        addc (8|M0)              r10.0<1>:ud   r13.0<2;1,0>:ud   r16.0<2;1,0>:ud  {AccWrEn,Compacted,A@1}
        mov (2|M0)               r1.8<1>:w     0x9090909:uv                             
        mov (8|M0)               r15.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        addc (1|M0)              r7.0<1>:ud    r9.0<0;1,0>:ud    0x10:ud              {AccWrEn}
        or (2|M0)                r4.2<1>:ud    r7.1<1;1,0>:ud    r1.8<1;1,0>:w    {I@3}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r2.0<1>:f     r7.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r2.1<1>:d     r8.0<0;0>:d       r9.1<0;0>:d       0:w               {I@1}
        mov (8|M0)               r22.0<2>:f    r2.0<0;1,0>:f                    {Compacted,F@1}
        mov (8|M0)               r22.1<2>:f    r2.1<0;1,0>:f                    {Compacted,I@1}
        add3 (8|M0)              r21.0<1>:d    r15.0<1;0>:d      r13.1<4;2>:d      r20.0<1>:d      
        addc (8|M0)              r12.0<1>:ud   r22.0<2;1,0>:ud   r16.0<2;1,0>:ud  {AccWrEn,Compacted,A@1}
        mov (8|M0)               r18.0<2>:d    r10.0<1;1,0>:d                  
        mov (8|M0)               r24.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r4.3<0;1,0>:d     r8.4<0;1,0>:uw  
        mach (1|M0)              r7.0<1>:d     r4.3<0;1,0>:d     r8.2<0;1,0>:d   
        mul (1|M0)               acc0.0<1>:ud  r4.2<0;1,0>:ud    r8.4<0;1,0>:uw  
        mach (1|M0)              r14.0<1>:ud   r4.2<0;1,0>:ud    r8.2<0;1,0>:ud   {AccWrEn}
        mov (8|M0)               r18.1<2>:d    r21.0<1;1,0>:d                   {I@7}
        mov (1|M0)               r13.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        add3 (1|M0)              r2.1<1>:d     r7.0<0;0>:d       r14.0<0;0>:d      0:w               {I@3}
        shl (1|M0)               r5.3<1>:d     r13.0<0;1,0>:d    1:w               {Compacted,I@2}
        shr (1|M0)               r6.5<1>:ud    r13.0<0;1,0>:ud   0x1F:uw             
        shl (1|M0)               r6.4<1>:d     r2.1<0;1,0>:d     1:w               {I@3}
        addc (1|M0)              r8.0<1>:ud    r5.0<0;1,0>:ud    r5.3<0;1,0>:ud   {AccWrEn,I@3}
        send.ugm (8|M0)          null     r18     r11:1   0x0            0x04000B84           {$6} // wr:2+1, rd:0; store.ugm.d16u32.a64
        add3 (8|M0)              r10.0<1>:d    r24.0<1;0>:d      r22.1<4;2>:d      r20.0<1>:d      
        mov (8|M0)               r11.0<1>:d    r5.8<1;1,0>:uw                   {$6.src}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        or (1|M0)                r5.4<1>:d     r6.4<0;1,0>:d     r6.5<0;1,0>:d    {I@5}
        mov (8|M0)               r25.0<2>:d    r12.0<1;1,0>:d                  
        mov (1|M0)               r1.2<1>:d     r8.0<0;1,0>:d                    {I@6}
        mov (8|M0)               r25.1<2>:d    r10.0<1;1,0>:d                   {I@6}
        add3 (1|M0)              r1.3<1>:d     r9.0<0;0>:d       r5.2<0;0>:d       r5.4<0>:d        {I@4}
        send.ugm (8|M0)          null     r25     r11:1   0x0            0x04000B84           {A@2,$7} // wr:2+1, rd:0; store.ugm.d16u32.a64
        mov (8|M0)               r10.0<2>:ud   r1.2<0;1,0>:ud                   {$7.src}
        mov (8|M0)               r10.1<2>:ud   r1.3<0;1,0>:ud                   {I@2}
        mov (8|M0)               r13.0<1>:d    r7.8<1;1,0>:uw                  
        addc (8|M0)              r12.0<1>:ud   r10.0<2;1,0>:ud   r16.0<2;1,0>:ud  {AccWrEn,Compacted,I@2}
        cmp (8|M0)    (lt)f1.1   null<1>:f     r73.0<1;1,0>:f    0.0:f              
        mov (8|M0)               r15.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        addc (1|M0)              r2.0<1>:ud    r1.2<0;1,0>:ud    0x10:ud              {AccWrEn}
        add3 (8|M0)              r21.0<1>:d    r15.0<1;0>:d      r10.1<4;2>:d      r20.0<1>:d       {I@2}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (8|M0)               r18.0<2>:d    r12.0<1;1,0>:d                  
        mov (1|M0)               r1.4<1>:d     r2.0<0;1,0>:d                    {I@4}
        mov (8|M0)               r18.1<2>:d    r21.0<1;1,0>:d                   {I@4}
        add3 (1|M0)              r1.5<1>:d     r8.0<0;0>:d       r1.3<0;0>:d       0:w               {I@4}
        sel (8|M0)    (lt)f0.0   r12.0<1>:f    (abs)r73.0<1;1,0>:f  448.0:f            {Compacted,I@4}
        send.ugm (8|M0)          null     r18     r13:1   0x0            0x04000B84           {A@2,$8} // wr:2+1, rd:0; store.ugm.d16u32.a64
        mov (8|M0)               r22.0<2>:ud   r1.4<0;1,0>:ud                  
        sync.nop                             null                             {Compacted,$8.src}
        shr (8|M0)               r13.0<1>:ud   r12.0<1;1,0>:ud   0x17:uw              {F@1}
        mov (8|M0)               r22.1<2>:ud   r1.5<0;1,0>:ud                   {I@3}
        sel (8|M0)    (ge)f0.0   r4.8<2>:ub    r13.0<4;1,0>:ub   0x79:uw              {I@2}
        addc (8|M0)              r9.0<1>:ud    r22.0<2;1,0>:ud   r16.0<2;1,0>:ud  {AccWrEn,Compacted,I@2}
        mov (8|M0)               r15.0<1>:d    r4.8<2;1,0>:ub                   {I@2}
        mov (8|M0)               r14.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mov (8|M0)               r11.0<1>:d    r6.0<1;1,0>:uw                  
        shl (8|M0)               r15.0<1>:d    r15.0<1;1,0>:d    23:w               {Compacted,I@3}
        add3 (8|M0)              r10.0<1>:d    r14.0<1;0>:d      r22.1<4;2>:d      r20.0<1>:d       {I@3}
        sel (8|M0)    (lt)f0.0   r6.0<1>:f     (abs)r65.0<1;1,0>:f  448.0:f            {Compacted,I@3}
        mov (8|M0)               r24.0<2>:d    r9.0<1;1,0>:d                   
        add (8|M0)               r18.0<1>:d    r15.0<1;1,0>:d    -25165824:d               {I@3}
        mov (8|M0)               r24.1<2>:d    r10.0<1;1,0>:d                   {I@3}
        add (8|M0)               r15.0<1>:d    -r15.0<1;1,0>:d   -2139095040:d              
        shr (8|M0)               r10.0<1>:ud   r6.0<1;1,0>:ud    0x17:uw              {F@1}
        mul (8|M0)               acc0.0<1>:f   r12.0<1;1,0>:f    r15.0<1;1,0>:f   {Compacted,I@2}
        sel (8|M0)    (ge)f0.0   r4.8<2>:ub    r10.0<4;1,0>:ub   0x79:uw              {I@1}
        send.ugm (8|M0)          null     r24     r11:1   0x0            0x04000B84           {$9} // wr:2+1, rd:0; store.ugm.d16u32.a64
        rnde (8|M0)              acc0.0<1>:f   acc0.0<1;1,0>:f                 
        sync.nop                             null                             {Compacted,$9.src}
        mov (8|M0)               r11.0<1>:d    r4.8<2;1,0>:ub                   {I@1}
        mul (8|M0)               acc0.0<1>:f   acc0.0<1;1,0>:f   r18.0<1;1,0>:f   {Compacted}
        shl (8|M0)               r11.0<1>:d    r11.0<1;1,0>:d    23:w               {Compacted,I@1}
        mov (8|M0)               r9.0<1>:f     (abs)acc0.0<1;1,0>:f             {Compacted}
        add (8|M0)               r13.0<1>:d    r11.0<1;1,0>:d    -25165824:d               {I@1}
        add (8|M0)               r11.0<1>:d    -r11.0<1;1,0>:d   -2139095040:d              
(f1.1)  or (8|M0)                r9.0<1>:d     r9.0<1;1,0>:d     -2147483648:d               {F@1}
        mul (8|M0)               acc0.0<1>:f   r6.0<1;1,0>:f     r11.0<1;1,0>:f   {Compacted,I@2}
        mov (8|M0)               r1.8<1>:hf    r9.0<1;1,0>:f                    {I@1}
        rnde (8|M0)              acc0.0<1>:f   acc0.0<1;1,0>:f                 
        sel (8|M0)    (lt)f0.0   r9.0<1>:f     (abs)r57.0<1;1,0>:f  448.0:f            {Compacted}
        cmp (8|M0)    (lt)f1.0   null<1>:f     r65.0<1;1,0>:f    0.0:f              
        mul (8|M0)               acc0.0<1>:f   acc0.0<1;1,0>:f   r13.0<1;1,0>:f   {Compacted}
        shr (8|M0)               r10.0<1>:ud   r9.0<1;1,0>:ud    0x17:uw              {F@3}
        mov (8|M0)               r12.0<1>:f    (abs)acc0.0<1;1,0>:f             {Compacted}
        sel (8|M0)    (ge)f0.0   r4.8<2>:ub    r10.0<4;1,0>:ub   0x79:uw              {I@1}
(f1.0)  or (8|M0)                r12.0<1>:d    r12.0<1;1,0>:d    -2147483648:d               {F@1}
        sel (8|M0)    (lt)f0.0   r10.0<1>:f    (abs)r49.0<1;1,0>:f  448.0:f            {Compacted,I@2}
        mov (8|M0)               r14.0<1>:d    r4.8<2;1,0>:ub                  
        mov (8|M0)               r5.8<1>:hf    r12.0<1;1,0>:f                   {I@2}
        shl (8|M0)               r14.0<1>:d    r14.0<1;1,0>:d    23:w               {Compacted,I@1}
        shr (8|M0)               r12.0<1>:ud   r10.0<1;1,0>:ud   0x17:uw              {A@1}
        add (8|M0)               r11.0<1>:d    r14.0<1;1,0>:d    -25165824:d               {I@2}
        add (8|M0)               r14.0<1>:d    -r14.0<1;1,0>:d   -2139095040:d              
        sel (8|M0)    (ge)f0.0   r4.8<2>:ub    r12.0<4;1,0>:ub   0x79:uw              {I@3}
        mov (2|M0)               r2.0<1>:w     0x2020202:v                              
        mul (8|M0)               acc0.0<1>:f   r9.0<1;1,0>:f     r14.0<1;1,0>:f   {Compacted,I@3}
        mov (8|M0)               r13.0<1>:d    r4.8<2;1,0>:ub                   {I@2}
        or (2|M0)                r1.2<1>:ud    r7.1<1;1,0>:ud    r2.0<1;1,0>:w    {I@2}
        rnde (8|M0)              r9.0<1>:f     acc0.0<1;1,0>:f                  {Compacted}
        shl (8|M0)               r13.0<1>:d    r13.0<1;1,0>:d    23:w               {Compacted,I@2}
        cmp (8|M0)    (lt)f0.1   null<1>:f     r57.0<1;1,0>:f    0.0:f              
(W)     mul (1|M0)               acc0.0<1>:d   r1.3<0;1,0>:d     r8.4<0;1,0>:uw   {A@2}
        mul (8|M0)               acc2.0<1>:f   r9.0<1;1,0>:f     r11.0<1;1,0>:f   {Compacted}
        add (8|M0)               r14.0<1>:d    r13.0<1;1,0>:d    -25165824:d               {I@2}
        add (8|M0)               r13.0<1>:d    -r13.0<1;1,0>:d   -2139095040:d              
        mach (1|M0)              r7.0<1>:d     r1.3<0;1,0>:d     r8.2<0;1,0>:d   
        mul (1|M0)               acc0.0<1>:ud  r1.2<0;1,0>:ud    r8.4<0;1,0>:uw  
        mov (8|M0)               r6.0<1>:f     (abs)acc2.0<1;1,0>:f             {Compacted}
        mul (8|M0)               acc2.0<1>:f   r10.0<1;1,0>:f    r13.0<1;1,0>:f   {Compacted,I@3}
        mach (1|M0)              r12.0<1>:ud   r1.2<0;1,0>:ud    r8.2<0;1,0>:ud   {AccWrEn}
(f0.1)  or (8|M0)                r6.0<1>:d     r6.0<1;1,0>:d     -2147483648:d               {F@2}
        rnde (8|M0)              acc2.0<1>:f   acc2.0<1;1,0>:f                 
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        cmp (8|M0)    (lt)f0.0   null<1>:f     r49.0<1;1,0>:f    0.0:f               {Compacted}
        add3 (1|M0)              r4.3<1>:d     r7.0<0;0>:d       r12.0<0;0>:d      0:w               {I@3}
        mov (8|M0)               r7.8<1>:hf    r6.0<1;1,0>:f                    {I@3}
        mul (8|M0)               acc0.0<1>:f   acc2.0<1;1,0>:f   r14.0<1;1,0>:f   {Compacted,I@2}
        shl (1|M0)               r6.5<1>:d     r11.0<0;1,0>:d    1:w               {Compacted,F@2}
        shl (1|M0)               r5.3<1>:d     r4.3<0;1,0>:d     1:w               {Compacted,I@2}
        shr (1|M0)               r6.4<1>:ud    r11.0<0;1,0>:ud   0x1F:uw             
        mov (8|M0)               r9.0<1>:f     (abs)acc0.0<1;1,0>:f             {Compacted}
        addc (1|M0)              r8.0<1>:ud    r5.0<0;1,0>:ud    r6.5<0;1,0>:ud   {AccWrEn,A@1}
        or (1|M0)                r6.6<1>:d     r5.3<0;1,0>:d     r6.4<0;1,0>:d    {I@2}
(f0.0)  or (8|M0)                r9.0<1>:d     r9.0<1;1,0>:d     -2147483648:d              
        mov (1|M0)               r2.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (8|M0)               r6.0<1>:hf    r9.0<1;1,0>:f                    {I@2}
        mov (1|M0)               r9.0<1>:f     r8.0<0;1,0>:f                    {Compacted}
        add3 (1|M0)              r9.1<1>:d     r2.0<0;0>:d       r5.2<0;0>:d       r6.6<0>:d        {A@1}
        mov (8|M0)               r13.0<2>:f    r9.0<0;1,0>:f                    {Compacted,F@1}
        mov (8|M0)               r13.1<2>:f    r9.1<0;1,0>:f                    {Compacted,I@1}
        mov (8|M0)               r12.0<1>:d    r1.8<1;1,0>:uw                  
        addc (8|M0)              r10.0<1>:ud   r13.0<2;1,0>:ud   r16.0<2;1,0>:ud  {AccWrEn,Compacted,A@1}
        mov (2|M0)               r1.8<1>:w     0xA0A0A0A:uv                             
        mov (8|M0)               r15.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        addc (1|M0)              r7.0<1>:ud    r9.0<0;1,0>:ud    0x10:ud              {AccWrEn}
        or (2|M0)                r6.4<1>:ud    r7.1<1;1,0>:ud    r1.8<1;1,0>:w    {I@3}
        mov (1|M0)               r2.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r4.2<1>:d     r7.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r4.3<1>:d     r2.0<0;0>:d       r9.1<0;0>:d       0:w               {I@2}
        mov (8|M0)               r21.0<2>:ud   r4.2<0;1,0>:ud                   {I@2}
        mov (8|M0)               r21.1<2>:ud   r4.3<0;1,0>:ud                   {I@2}
        mov (8|M0)               r20.0<1>:d    r16.1<2;1,0>:d                  
        addc (8|M0)              r23.0<1>:ud   r21.0<2;1,0>:ud   r16.0<2;1,0>:ud  {AccWrEn,Compacted,I@2}
        mov (8|M0)               r18.0<2>:d    r10.0<1;1,0>:d                  
        mov (8|M0)               r10.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r6.5<0;1,0>:d     r8.4<0;1,0>:uw  
        mach (1|M0)              r2.0<1>:d     r6.5<0;1,0>:d     r8.2<0;1,0>:d   
        mul (1|M0)               acc0.0<1>:ud  r6.4<0;1,0>:ud    r8.4<0;1,0>:uw  
        add3 (8|M0)              r11.0<1>:d    r15.0<1;0>:d      r13.1<4;2>:d      r20.0<1>:d       {I@7}
        mach (1|M0)              r15.0<1>:ud   r6.4<0;1,0>:ud    r8.2<0;1,0>:ud   {AccWrEn}
        add3 (8|M0)              r13.0<1>:d    r10.0<1;0>:d      r21.1<4;2>:d      r20.0<1>:d       {I@6}
        mov (1|M0)               r14.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        add3 (1|M0)              r4.3<1>:d     r2.0<0;0>:d       r15.0<0;0>:d      0:w               {I@3}
        shl (1|M0)               r5.3<1>:d     r14.0<0;1,0>:d    1:w               {Compacted,I@2}
        shr (1|M0)               r7.3<1>:ud    r14.0<0;1,0>:ud   0x1F:uw             
        shl (1|M0)               r7.0<1>:d     r4.3<0;1,0>:d     1:w               {Compacted,I@3}
        addc (1|M0)              r8.0<1>:ud    r5.0<0;1,0>:ud    r5.3<0;1,0>:ud   {AccWrEn,I@3}
        mov (8|M0)               r18.1<2>:d    r11.0<1;1,0>:d                  
        mov (8|M0)               r11.0<1>:d    r5.8<1;1,0>:uw                  
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        or (1|M0)                r5.4<1>:d     r7.0<0;1,0>:d     r7.3<0;1,0>:d    {I@5}
        mov (8|M0)               r24.0<2>:d    r23.0<1;1,0>:d                  
        mov (1|M0)               r1.2<1>:d     r8.0<0;1,0>:d                    {I@6}
        mov (8|M0)               r24.1<2>:d    r13.0<1;1,0>:d                  
        add3 (1|M0)              r1.3<1>:d     r9.0<0;0>:d       r5.2<0;0>:d       r5.4<0>:d        {I@4}
        send.ugm (8|M0)          null     r18     r12:1   0x0            0x04000B84           {$10} // wr:2+1, rd:0; store.ugm.d16u32.a64
        send.ugm (8|M0)          null     r24     r11:1   0x0            0x04000B84           {A@2,$11} // wr:2+1, rd:0; store.ugm.d16u32.a64
        mov (8|M0)               r10.0<2>:ud   r1.2<0;1,0>:ud                   {$11.src}
        mov (8|M0)               r10.1<2>:ud   r1.3<0;1,0>:ud                   {I@2}
        mov (8|M0)               r14.0<1>:d    r7.8<1;1,0>:uw                  
        sync.nop                             null                             {Compacted,$10.src}
        addc (8|M0)              r12.0<1>:ud   r10.0<2;1,0>:ud   r16.0<2;1,0>:ud  {AccWrEn,Compacted,I@2}
        cmp (8|M0)    (lt)f1.1   null<1>:f     r74.0<1;1,0>:f    0.0:f              
        mov (8|M0)               r13.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mov (8|M0)               r18.0<2>:d    r12.0<1;1,0>:d                   {I@2}
        add3 (8|M0)              r21.0<1>:d    r13.0<1;0>:d      r10.1<4;2>:d      r20.0<1>:d       {I@2}
        addc (1|M0)              r2.0<1>:ud    r1.2<0;1,0>:ud    0x10:ud              {AccWrEn}
        mov (8|M0)               r18.1<2>:d    r21.0<1;1,0>:d                   {I@2}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        send.ugm (8|M0)          null     r18     r14:1   0x0            0x04000B84           {A@2,$12} // wr:2+1, rd:0; store.ugm.d16u32.a64
        sel (8|M0)    (lt)f0.0   r14.0<1>:f    (abs)r74.0<1;1,0>:f  448.0:f            {Compacted,$12.src}
        mov (1|M0)               r1.4<1>:d     r2.0<0;1,0>:d                   
        shr (8|M0)               r18.0<1>:ud   r14.0<1;1,0>:ud   0x17:uw              {F@1}
        add3 (1|M0)              r1.5<1>:d     r8.0<0;0>:d       r1.3<0;0>:d       0:w               {I@3}
        sel (8|M0)    (ge)f0.0   r4.8<2>:ub    r18.0<4;1,0>:ub   0x79:uw              {I@2}
        mov (8|M0)               r22.0<2>:ud   r1.4<0;1,0>:ud                  
        mov (8|M0)               r22.1<2>:ud   r1.5<0;1,0>:ud                   {I@3}
        mov (8|M0)               r19.0<1>:d    r4.8<2;1,0>:ub                   {I@3}
        addc (8|M0)              r9.0<1>:ud    r22.0<2;1,0>:ud   r16.0<2;1,0>:ud  {AccWrEn,Compacted,I@2}
        shl (8|M0)               r19.0<1>:d    r19.0<1;1,0>:d    23:w               {Compacted,I@2}
        mov (8|M0)               r15.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        add (8|M0)               r21.0<1>:d    r19.0<1;1,0>:d    -25165824:d               {I@2}
        add (8|M0)               r19.0<1>:d    -r19.0<1;1,0>:d   -2139095040:d              
        mov (8|M0)               r11.0<1>:d    r6.0<1;1,0>:uw                  
        add3 (8|M0)              r10.0<1>:d    r15.0<1;0>:d      r22.1<4;2>:d      r20.0<1>:d       {I@4}
        mul (8|M0)               acc0.0<1>:f   r14.0<1;1,0>:f    r19.0<1;1,0>:f   {Compacted,I@3}
        sel (8|M0)    (lt)f0.0   r6.0<1>:f     (abs)r66.0<1;1,0>:f  448.0:f            {Compacted,I@2}
        mov (8|M0)               r12.0<2>:d    r9.0<1;1,0>:d                   
        rnde (8|M0)              acc0.0<1>:f   acc0.0<1;1,0>:f                 
        mov (8|M0)               r12.1<2>:d    r10.0<1;1,0>:d                   {I@2}
        shr (8|M0)               r10.0<1>:ud   r6.0<1;1,0>:ud    0x17:uw              {F@2}
        mul (8|M0)               acc0.0<1>:f   acc0.0<1;1,0>:f   r21.0<1;1,0>:f   {Compacted}
        sel (8|M0)    (ge)f0.0   r4.8<2>:ub    r10.0<4;1,0>:ub   0x79:uw              {I@1}
        send.ugm (8|M0)          null     r12     r11:1   0x0            0x04000B84           {$13} // wr:2+1, rd:0; store.ugm.d16u32.a64
        mov (8|M0)               r9.0<1>:f     (abs)acc0.0<1;1,0>:f             {Compacted}
        sync.nop                             null                             {Compacted,$13.src}
        mov (8|M0)               r11.0<1>:d    r4.8<2;1,0>:ub                   {I@1}
(f1.1)  or (8|M0)                r9.0<1>:d     r9.0<1;1,0>:d     -2147483648:d               {F@1}
        shl (8|M0)               r11.0<1>:d    r11.0<1;1,0>:d    23:w               {Compacted,I@2}
        mov (8|M0)               r1.8<1>:hf    r9.0<1;1,0>:f                    {I@2}
        add (8|M0)               r12.0<1>:d    r11.0<1;1,0>:d    -25165824:d               {I@1}
        sel (8|M0)    (lt)f0.0   r9.0<1>:f     (abs)r58.0<1;1,0>:f  448.0:f            {Compacted}
        add (8|M0)               r11.0<1>:d    -r11.0<1;1,0>:d   -2139095040:d              
        shr (8|M0)               r10.0<1>:ud   r9.0<1;1,0>:ud    0x17:uw              {F@1}
        mul (8|M0)               acc0.0<1>:f   r6.0<1;1,0>:f     r11.0<1;1,0>:f   {Compacted,I@2}
        sel (8|M0)    (ge)f0.0   r4.8<2>:ub    r10.0<4;1,0>:ub   0x79:uw              {I@1}
        rnde (8|M0)              acc0.0<1>:f   acc0.0<1;1,0>:f                 
        cmp (8|M0)    (lt)f1.0   null<1>:f     r66.0<1;1,0>:f    0.0:f              
        sel (8|M0)    (lt)f0.0   r10.0<1>:f    (abs)r50.0<1;1,0>:f  448.0:f            {Compacted,I@1}
        mov (8|M0)               r14.0<1>:d    r4.8<2;1,0>:ub                  
        mul (8|M0)               acc0.0<1>:f   acc0.0<1;1,0>:f   r12.0<1;1,0>:f   {Compacted}
        shl (8|M0)               r14.0<1>:d    r14.0<1;1,0>:d    23:w               {Compacted,I@1}
        shr (8|M0)               r12.0<1>:ud   r10.0<1;1,0>:ud   0x17:uw              {A@1}
        mov (8|M0)               r13.0<1>:f    (abs)acc0.0<1;1,0>:f             {Compacted}
        add (8|M0)               r11.0<1>:d    r14.0<1;1,0>:d    -25165824:d               {I@2}
        sel (8|M0)    (ge)f0.0   r4.8<2>:ub    r12.0<4;1,0>:ub   0x79:uw              {I@2}
(f1.0)  or (8|M0)                r13.0<1>:d    r13.0<1;1,0>:d    -2147483648:d               {F@1}
        add (8|M0)               r14.0<1>:d    -r14.0<1;1,0>:d   -2139095040:d              
        mov (2|M0)               r2.0<1>:w     0x3030303:v                              
        mov (8|M0)               r5.8<1>:hf    r13.0<1;1,0>:f                   {I@3}
        mul (8|M0)               acc0.0<1>:f   r9.0<1;1,0>:f     r14.0<1;1,0>:f   {Compacted,I@2}
        mov (8|M0)               r13.0<1>:d    r4.8<2;1,0>:ub                   {F@2}
        or (2|M0)                r1.2<1>:ud    r7.1<1;1,0>:ud    r2.0<1;1,0>:w    {I@2}
        rnde (8|M0)              r9.0<1>:f     acc0.0<1;1,0>:f                  {Compacted}
        shl (8|M0)               r13.0<1>:d    r13.0<1;1,0>:d    23:w               {Compacted,I@2}
        cmp (8|M0)    (lt)f0.1   null<1>:f     r58.0<1;1,0>:f    0.0:f              
(W)     mul (1|M0)               acc0.0<1>:d   r1.3<0;1,0>:d     r8.4<0;1,0>:uw   {A@2}
        mul (8|M0)               acc2.0<1>:f   r9.0<1;1,0>:f     r11.0<1;1,0>:f   {Compacted}
        add (8|M0)               r14.0<1>:d    r13.0<1;1,0>:d    -25165824:d               {I@2}
        add (8|M0)               r13.0<1>:d    -r13.0<1;1,0>:d   -2139095040:d              
        mach (1|M0)              r7.0<1>:d     r1.3<0;1,0>:d     r8.2<0;1,0>:d   
        mul (1|M0)               acc0.0<1>:ud  r1.2<0;1,0>:ud    r8.4<0;1,0>:uw  
        mov (8|M0)               r6.0<1>:f     (abs)acc2.0<1;1,0>:f             {Compacted}
        mul (8|M0)               acc2.0<1>:f   r10.0<1;1,0>:f    r13.0<1;1,0>:f   {Compacted,I@3}
        mach (1|M0)              r12.0<1>:ud   r1.2<0;1,0>:ud    r8.2<0;1,0>:ud   {AccWrEn}
(f0.1)  or (8|M0)                r6.0<1>:d     r6.0<1;1,0>:d     -2147483648:d               {F@2}
        rnde (8|M0)              acc2.0<1>:f   acc2.0<1;1,0>:f                 
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        cmp (8|M0)    (lt)f0.0   null<1>:f     r50.0<1;1,0>:f    0.0:f               {Compacted}
        add3 (1|M0)              r4.3<1>:d     r7.0<0;0>:d       r12.0<0;0>:d      0:w               {I@3}
        mov (8|M0)               r7.8<1>:hf    r6.0<1;1,0>:f                    {I@3}
        mul (8|M0)               acc0.0<1>:f   acc2.0<1;1,0>:f   r14.0<1;1,0>:f   {Compacted,I@2}
        shl (1|M0)               r6.5<1>:d     r11.0<0;1,0>:d    1:w               {Compacted,F@2}
        shl (1|M0)               r5.3<1>:d     r4.3<0;1,0>:d     1:w               {Compacted,I@2}
        shr (1|M0)               r6.4<1>:ud    r11.0<0;1,0>:ud   0x1F:uw             
        mov (8|M0)               r9.0<1>:f     (abs)acc0.0<1;1,0>:f             {Compacted}
        addc (1|M0)              r8.0<1>:ud    r5.0<0;1,0>:ud    r6.5<0;1,0>:ud   {AccWrEn,A@1}
        or (1|M0)                r6.6<1>:d     r5.3<0;1,0>:d     r6.4<0;1,0>:d    {I@2}
(f0.0)  or (8|M0)                r9.0<1>:d     r9.0<1;1,0>:d     -2147483648:d              
        mov (1|M0)               r2.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (8|M0)               r6.0<1>:hf    r9.0<1;1,0>:f                    {I@2}
        mov (1|M0)               r9.0<1>:f     r8.0<0;1,0>:f                    {Compacted}
        add3 (1|M0)              r9.1<1>:d     r2.0<0;0>:d       r5.2<0;0>:d       r6.6<0>:d        {A@1}
        mov (8|M0)               r13.0<2>:f    r9.0<0;1,0>:f                    {Compacted,F@1}
        mov (8|M0)               r13.1<2>:f    r9.1<0;1,0>:f                    {Compacted,I@1}
        mov (8|M0)               r11.0<1>:d    r1.8<1;1,0>:uw                  
        addc (8|M0)              r10.0<1>:ud   r13.0<2;1,0>:ud   r16.0<2;1,0>:ud  {AccWrEn,Compacted,A@1}
        mov (2|M0)               r1.8<1>:w     0xB0B0B0B:uv                             
        mov (8|M0)               r15.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        addc (1|M0)              r7.0<1>:ud    r9.0<0;1,0>:ud    0x10:ud              {AccWrEn}
        or (2|M0)                r4.2<1>:ud    r7.1<1;1,0>:ud    r1.8<1;1,0>:w    {I@3}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r2.0<1>:f     r7.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r2.1<1>:d     r8.0<0;0>:d       r9.1<0;0>:d       0:w               {I@1}
        mov (8|M0)               r22.0<2>:f    r2.0<0;1,0>:f                    {Compacted,F@1}
        mov (8|M0)               r22.1<2>:f    r2.1<0;1,0>:f                    {Compacted,I@1}
        add3 (8|M0)              r21.0<1>:d    r15.0<1;0>:d      r13.1<4;2>:d      r20.0<1>:d      
        addc (8|M0)              r12.0<1>:ud   r22.0<2;1,0>:ud   r16.0<2;1,0>:ud  {AccWrEn,Compacted,A@1}
        mov (8|M0)               r18.0<2>:d    r10.0<1;1,0>:d                  
        mov (8|M0)               r24.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mul (1|M0)               acc0.0<1>:ud  r4.2<0;1,0>:ud    r8.4<0;1,0>:uw  
        mach (1|M0)              r14.0<1>:ud   r4.2<0;1,0>:ud    r8.2<0;1,0>:ud   {AccWrEn}
        mov (8|M0)               r18.1<2>:d    r21.0<1;1,0>:d                   {I@6}
        mov (1|M0)               r13.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r4.3<0;1,0>:d     r8.4<0;1,0>:uw  
        mach (1|M0)              r2.0<1>:d     r4.3<0;1,0>:d     r8.2<0;1,0>:d   
        shl (1|M0)               r5.3<1>:d     r13.0<0;1,0>:d    1:w               {Compacted,I@3}
        add3 (1|M0)              r6.5<1>:d     r2.0<0;0>:d       r14.0<0;0>:d      0:w               {I@2}
        shr (1|M0)               r7.3<1>:ud    r13.0<0;1,0>:ud   0x1F:uw             
        addc (1|M0)              r8.0<1>:ud    r5.0<0;1,0>:ud    r5.3<0;1,0>:ud   {AccWrEn,I@3}
        shl (1|M0)               r7.0<1>:d     r6.5<0;1,0>:d     1:w               {Compacted,I@3}
        send.ugm (8|M0)          null     r18     r11:1   0x0            0x04000B84           {$14} // wr:2+1, rd:0; store.ugm.d16u32.a64
        add3 (8|M0)              r10.0<1>:d    r24.0<1;0>:d      r22.1<4;2>:d      r20.0<1>:d      
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (8|M0)               r11.0<1>:d    r5.8<1;1,0>:uw                   {$14.src}
        or (1|M0)                r5.4<1>:d     r7.0<0;1,0>:d     r7.3<0;1,0>:d    {I@4}
        mov (8|M0)               r25.0<2>:d    r12.0<1;1,0>:d                  
        mov (1|M0)               r1.2<1>:d     r8.0<0;1,0>:d                   
        mov (8|M0)               r25.1<2>:d    r10.0<1;1,0>:d                   {I@6}
        add3 (1|M0)              r1.3<1>:d     r9.0<0;0>:d       r5.2<0;0>:d       r5.4<0>:d        {I@4}
        send.ugm (8|M0)          null     r25     r11:1   0x0            0x04000B84           {A@2,$15} // wr:2+1, rd:0; store.ugm.d16u32.a64
        mov (8|M0)               r10.0<2>:ud   r1.2<0;1,0>:ud                   {$15.src}
        mov (8|M0)               r10.1<2>:ud   r1.3<0;1,0>:ud                   {I@2}
        mov (8|M0)               r13.0<1>:d    r7.8<1;1,0>:uw                  
        addc (8|M0)              r12.0<1>:ud   r10.0<2;1,0>:ud   r16.0<2;1,0>:ud  {AccWrEn,Compacted,I@2}
        cmp (8|M0)    (lt)f1.1   null<1>:f     r75.0<1;1,0>:f    0.0:f              
        mov (8|M0)               r15.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        addc (1|M0)              r2.0<1>:ud    r1.2<0;1,0>:ud    0x10:ud              {AccWrEn}
        add3 (8|M0)              r21.0<1>:d    r15.0<1;0>:d      r10.1<4;2>:d      r20.0<1>:d       {I@2}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (8|M0)               r18.0<2>:d    r12.0<1;1,0>:d                  
        mov (1|M0)               r1.4<1>:d     r2.0<0;1,0>:d                    {I@4}
        mov (8|M0)               r18.1<2>:d    r21.0<1;1,0>:d                   {I@4}
        add3 (1|M0)              r1.5<1>:d     r8.0<0;0>:d       r1.3<0;0>:d       0:w               {I@4}
        sel (8|M0)    (lt)f0.0   r12.0<1>:f    (abs)r75.0<1;1,0>:f  448.0:f            {Compacted,I@4}
        send.ugm (8|M0)          null     r18     r13:1   0x0            0x04000B84           {A@2,$0} // wr:2+1, rd:0; store.ugm.d16u32.a64
        mov (8|M0)               r22.0<2>:ud   r1.4<0;1,0>:ud                  
        sync.nop                             null                             {Compacted,$0.src}
        shr (8|M0)               r13.0<1>:ud   r12.0<1;1,0>:ud   0x17:uw              {F@1}
        mov (8|M0)               r22.1<2>:ud   r1.5<0;1,0>:ud                   {I@3}
        sel (8|M0)    (ge)f0.0   r4.8<2>:ub    r13.0<4;1,0>:ub   0x79:uw              {I@2}
        addc (8|M0)              r9.0<1>:ud    r22.0<2;1,0>:ud   r16.0<2;1,0>:ud  {AccWrEn,Compacted,I@2}
        mov (8|M0)               r15.0<1>:d    r4.8<2;1,0>:ub                   {I@2}
        mov (8|M0)               r14.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mov (8|M0)               r11.0<1>:d    r6.0<1;1,0>:uw                  
        shl (8|M0)               r15.0<1>:d    r15.0<1;1,0>:d    23:w               {Compacted,I@3}
        add3 (8|M0)              r10.0<1>:d    r14.0<1;0>:d      r22.1<4;2>:d      r20.0<1>:d       {I@3}
        sel (8|M0)    (lt)f0.0   r6.0<1>:f     (abs)r67.0<1;1,0>:f  448.0:f            {Compacted,I@3}
        mov (8|M0)               r24.0<2>:d    r9.0<1;1,0>:d                   
        add (8|M0)               r18.0<1>:d    r15.0<1;1,0>:d    -25165824:d               {I@3}
        mov (8|M0)               r24.1<2>:d    r10.0<1;1,0>:d                   {I@3}
        add (8|M0)               r15.0<1>:d    -r15.0<1;1,0>:d   -2139095040:d              
        shr (8|M0)               r10.0<1>:ud   r6.0<1;1,0>:ud    0x17:uw              {F@1}
        mul (8|M0)               acc0.0<1>:f   r12.0<1;1,0>:f    r15.0<1;1,0>:f   {Compacted,I@2}
        sel (8|M0)    (ge)f0.0   r4.8<2>:ub    r10.0<4;1,0>:ub   0x79:uw              {I@1}
        send.ugm (8|M0)          null     r24     r11:1   0x0            0x04000B84           {$1} // wr:2+1, rd:0; store.ugm.d16u32.a64
        rnde (8|M0)              acc0.0<1>:f   acc0.0<1;1,0>:f                 
        sync.nop                             null                             {Compacted,$1.src}
        mov (8|M0)               r11.0<1>:d    r4.8<2;1,0>:ub                   {I@1}
        mul (8|M0)               acc0.0<1>:f   acc0.0<1;1,0>:f   r18.0<1;1,0>:f   {Compacted}
        shl (8|M0)               r11.0<1>:d    r11.0<1;1,0>:d    23:w               {Compacted,I@1}
        mov (8|M0)               r9.0<1>:f     (abs)acc0.0<1;1,0>:f             {Compacted}
        add (8|M0)               r13.0<1>:d    r11.0<1;1,0>:d    -25165824:d               {I@1}
        add (8|M0)               r11.0<1>:d    -r11.0<1;1,0>:d   -2139095040:d              
(f1.1)  or (8|M0)                r9.0<1>:d     r9.0<1;1,0>:d     -2147483648:d               {F@1}
        mul (8|M0)               acc0.0<1>:f   r6.0<1;1,0>:f     r11.0<1;1,0>:f   {Compacted,I@2}
        mov (8|M0)               r1.8<1>:hf    r9.0<1;1,0>:f                    {I@1}
        rnde (8|M0)              acc0.0<1>:f   acc0.0<1;1,0>:f                 
        sel (8|M0)    (lt)f0.0   r9.0<1>:f     (abs)r59.0<1;1,0>:f  448.0:f            {Compacted}
        cmp (8|M0)    (lt)f1.0   null<1>:f     r67.0<1;1,0>:f    0.0:f              
        mul (8|M0)               acc0.0<1>:f   acc0.0<1;1,0>:f   r13.0<1;1,0>:f   {Compacted}
        shr (8|M0)               r10.0<1>:ud   r9.0<1;1,0>:ud    0x17:uw              {F@3}
        mov (8|M0)               r12.0<1>:f    (abs)acc0.0<1;1,0>:f             {Compacted}
        sel (8|M0)    (ge)f0.0   r4.8<2>:ub    r10.0<4;1,0>:ub   0x79:uw              {I@1}
(f1.0)  or (8|M0)                r12.0<1>:d    r12.0<1;1,0>:d    -2147483648:d               {F@1}
        sel (8|M0)    (lt)f0.0   r10.0<1>:f    (abs)r51.0<1;1,0>:f  448.0:f            {Compacted,I@2}
        mov (8|M0)               r14.0<1>:d    r4.8<2;1,0>:ub                  
        mov (8|M0)               r5.8<1>:hf    r12.0<1;1,0>:f                   {I@2}
        shl (8|M0)               r14.0<1>:d    r14.0<1;1,0>:d    23:w               {Compacted,I@1}
        shr (8|M0)               r12.0<1>:ud   r10.0<1;1,0>:ud   0x17:uw              {A@1}
        add (8|M0)               r11.0<1>:d    r14.0<1;1,0>:d    -25165824:d               {I@2}
        add (8|M0)               r14.0<1>:d    -r14.0<1;1,0>:d   -2139095040:d              
        sel (8|M0)    (ge)f0.0   r4.8<2>:ub    r12.0<4;1,0>:ub   0x79:uw              {I@3}
        mov (2|M0)               r2.0<1>:w     0x4040404:v                              
        mul (8|M0)               acc0.0<1>:f   r9.0<1;1,0>:f     r14.0<1;1,0>:f   {Compacted,I@3}
        mov (8|M0)               r13.0<1>:d    r4.8<2;1,0>:ub                   {I@2}
        or (2|M0)                r1.2<1>:ud    r7.1<1;1,0>:ud    r2.0<1;1,0>:w    {I@2}
        rnde (8|M0)              r9.0<1>:f     acc0.0<1;1,0>:f                  {Compacted}
        shl (8|M0)               r13.0<1>:d    r13.0<1;1,0>:d    23:w               {Compacted,I@2}
        cmp (8|M0)    (lt)f0.1   null<1>:f     r59.0<1;1,0>:f    0.0:f              
        mul (1|M0)               acc0.0<1>:ud  r1.2<0;1,0>:ud    r8.4<0;1,0>:uw   {A@2}
        mul (8|M0)               acc2.0<1>:f   r9.0<1;1,0>:f     r11.0<1;1,0>:f   {Compacted}
        add (8|M0)               r14.0<1>:d    r13.0<1;1,0>:d    -25165824:d               {I@2}
        add (8|M0)               r13.0<1>:d    -r13.0<1;1,0>:d   -2139095040:d              
        mach (1|M0)              r12.0<1>:ud   r1.2<0;1,0>:ud    r8.2<0;1,0>:ud   {AccWrEn}
        mov (8|M0)               r6.0<1>:f     (abs)acc2.0<1;1,0>:f             {Compacted}
        mul (8|M0)               acc2.0<1>:f   r10.0<1;1,0>:f    r13.0<1;1,0>:f   {Compacted,I@2}
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,F@3}
(W)     mul (1|M0)               acc0.0<1>:d   r1.3<0;1,0>:d     r8.4<0;1,0>:uw  
(f0.1)  or (8|M0)                r6.0<1>:d     r6.0<1;1,0>:d     -2147483648:d               {F@2}
        rnde (8|M0)              acc2.0<1>:f   acc2.0<1;1,0>:f                 
        mach (1|M0)              r7.0<1>:d     r1.3<0;1,0>:d     r8.2<0;1,0>:d   
        cmp (8|M0)    (lt)f0.0   null<1>:f     r51.0<1;1,0>:f    0.0:f               {Compacted}
        mov (8|M0)               r7.8<1>:hf    r6.0<1;1,0>:f                    {I@2}
        mul (8|M0)               acc0.0<1>:f   acc2.0<1;1,0>:f   r14.0<1;1,0>:f   {Compacted,I@1}
        add3 (1|M0)              r4.3<1>:d     r7.0<0;0>:d       r12.0<0;0>:d      0:w              
        shl (1|M0)               r6.5<1>:d     r11.0<0;1,0>:d    1:w               {Compacted,F@2}
        shr (1|M0)               r6.4<1>:ud    r11.0<0;1,0>:ud   0x1F:uw             
        mov (8|M0)               r9.0<1>:f     (abs)acc0.0<1;1,0>:f             {Compacted}
        shl (1|M0)               r5.3<1>:d     r4.3<0;1,0>:d     1:w               {Compacted,I@3}
        addc (1|M0)              r8.0<1>:ud    r5.0<0;1,0>:ud    r6.5<0;1,0>:ud   {AccWrEn,A@1}
(f0.0)  or (8|M0)                r9.0<1>:d     r9.0<1;1,0>:d     -2147483648:d              
        or (1|M0)                r6.6<1>:d     r5.3<0;1,0>:d     r6.4<0;1,0>:d    {I@3}
        mov (1|M0)               r2.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (8|M0)               r6.0<1>:hf    r9.0<1;1,0>:f                    {I@3}
        mov (1|M0)               r9.0<1>:f     r8.0<0;1,0>:f                    {Compacted}
        add3 (1|M0)              r9.1<1>:d     r2.0<0;0>:d       r5.2<0;0>:d       r6.6<0>:d        {A@1}
        mov (8|M0)               r13.0<2>:f    r9.0<0;1,0>:f                    {Compacted,F@1}
        mov (8|M0)               r13.1<2>:f    r9.1<0;1,0>:f                    {Compacted,I@1}
        mov (8|M0)               r12.0<1>:d    r1.8<1;1,0>:uw                  
        addc (8|M0)              r10.0<1>:ud   r13.0<2;1,0>:ud   r16.0<2;1,0>:ud  {AccWrEn,Compacted,A@1}
        mov (2|M0)               r1.8<1>:w     0xC0C0C0C:uv                             
        mov (8|M0)               r15.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        addc (1|M0)              r7.0<1>:ud    r9.0<0;1,0>:ud    0x10:ud              {AccWrEn}
        or (2|M0)                r6.4<1>:ud    r7.1<1;1,0>:ud    r1.8<1;1,0>:w    {I@3}
        mov (1|M0)               r2.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r4.2<1>:d     r7.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r4.3<1>:d     r2.0<0;0>:d       r9.1<0;0>:d       0:w               {I@2}
        mov (8|M0)               r21.0<2>:ud   r4.2<0;1,0>:ud                   {I@2}
        mov (8|M0)               r21.1<2>:ud   r4.3<0;1,0>:ud                   {I@2}
        mov (8|M0)               r20.0<1>:d    r16.1<2;1,0>:d                  
        addc (8|M0)              r23.0<1>:ud   r21.0<2;1,0>:ud   r16.0<2;1,0>:ud  {AccWrEn,Compacted,I@2}
        mov (8|M0)               r18.0<2>:d    r10.0<1;1,0>:d                  
        mov (8|M0)               r10.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mul (1|M0)               acc0.0<1>:ud  r6.4<0;1,0>:ud    r8.4<0;1,0>:uw  
        add3 (8|M0)              r11.0<1>:d    r15.0<1;0>:d      r13.1<4;2>:d      r20.0<1>:d       {I@5}
        mach (1|M0)              r15.0<1>:ud   r6.4<0;1,0>:ud    r8.2<0;1,0>:ud   {AccWrEn}
        add3 (8|M0)              r13.0<1>:d    r10.0<1;0>:d      r21.1<4;2>:d      r20.0<1>:d       {I@4}
        mov (1|M0)               r14.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r6.5<0;1,0>:d     r8.4<0;1,0>:uw  
        mach (1|M0)              r2.0<1>:d     r6.5<0;1,0>:d     r8.2<0;1,0>:d   
        shl (1|M0)               r5.3<1>:d     r14.0<0;1,0>:d    1:w               {Compacted,I@3}
        add3 (1|M0)              r4.3<1>:d     r2.0<0;0>:d       r15.0<0;0>:d      0:w               {I@2}
        shr (1|M0)               r7.3<1>:ud    r14.0<0;1,0>:ud   0x1F:uw             
        addc (1|M0)              r8.0<1>:ud    r5.0<0;1,0>:ud    r5.3<0;1,0>:ud   {AccWrEn,I@3}
        shl (1|M0)               r7.0<1>:d     r4.3<0;1,0>:d     1:w               {Compacted,I@3}
        mov (8|M0)               r18.1<2>:d    r11.0<1;1,0>:d                  
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (8|M0)               r11.0<1>:d    r5.8<1;1,0>:uw                  
        or (1|M0)                r5.4<1>:d     r7.0<0;1,0>:d     r7.3<0;1,0>:d    {I@4}
        mov (8|M0)               r24.0<2>:d    r23.0<1;1,0>:d                  
        mov (1|M0)               r1.2<1>:d     r8.0<0;1,0>:d                   
        mov (8|M0)               r24.1<2>:d    r13.0<1;1,0>:d                  
        add3 (1|M0)              r1.3<1>:d     r9.0<0;0>:d       r5.2<0;0>:d       r5.4<0>:d        {I@4}
        send.ugm (8|M0)          null     r18     r12:1   0x0            0x04000B84           {$2} // wr:2+1, rd:0; store.ugm.d16u32.a64
        send.ugm (8|M0)          null     r24     r11:1   0x0            0x04000B84           {A@2,$3} // wr:2+1, rd:0; store.ugm.d16u32.a64
        mov (8|M0)               r10.0<2>:ud   r1.2<0;1,0>:ud                   {$3.src}
        mov (8|M0)               r10.1<2>:ud   r1.3<0;1,0>:ud                   {I@2}
        mov (8|M0)               r14.0<1>:d    r7.8<1;1,0>:uw                  
        sync.nop                             null                             {Compacted,$2.src}
        addc (8|M0)              r12.0<1>:ud   r10.0<2;1,0>:ud   r16.0<2;1,0>:ud  {AccWrEn,Compacted,I@2}
        cmp (8|M0)    (lt)f1.1   null<1>:f     r76.0<1;1,0>:f    0.0:f              
        mov (8|M0)               r13.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mov (8|M0)               r18.0<2>:d    r12.0<1;1,0>:d                   {I@2}
        add3 (8|M0)              r21.0<1>:d    r13.0<1;0>:d      r10.1<4;2>:d      r20.0<1>:d       {I@2}
        addc (1|M0)              r2.0<1>:ud    r1.2<0;1,0>:ud    0x10:ud              {AccWrEn}
        mov (8|M0)               r18.1<2>:d    r21.0<1;1,0>:d                   {I@2}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        send.ugm (8|M0)          null     r18     r14:1   0x0            0x04000B84           {A@2,$4} // wr:2+1, rd:0; store.ugm.d16u32.a64
        sel (8|M0)    (lt)f0.0   r14.0<1>:f    (abs)r76.0<1;1,0>:f  448.0:f            {Compacted,$4.src}
        mov (1|M0)               r1.4<1>:d     r2.0<0;1,0>:d                   
        shr (8|M0)               r18.0<1>:ud   r14.0<1;1,0>:ud   0x17:uw              {F@1}
        add3 (1|M0)              r1.5<1>:d     r8.0<0;0>:d       r1.3<0;0>:d       0:w               {I@3}
        sel (8|M0)    (ge)f0.0   r4.8<2>:ub    r18.0<4;1,0>:ub   0x79:uw              {I@2}
        mov (8|M0)               r22.0<2>:ud   r1.4<0;1,0>:ud                  
        mov (8|M0)               r22.1<2>:ud   r1.5<0;1,0>:ud                   {I@3}
        mov (8|M0)               r19.0<1>:d    r4.8<2;1,0>:ub                   {I@3}
        addc (8|M0)              r9.0<1>:ud    r22.0<2;1,0>:ud   r16.0<2;1,0>:ud  {AccWrEn,Compacted,I@2}
        shl (8|M0)               r19.0<1>:d    r19.0<1;1,0>:d    23:w               {Compacted,I@2}
        mov (8|M0)               r15.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        add (8|M0)               r21.0<1>:d    r19.0<1;1,0>:d    -25165824:d               {I@2}
        add (8|M0)               r19.0<1>:d    -r19.0<1;1,0>:d   -2139095040:d              
        mov (8|M0)               r11.0<1>:d    r6.0<1;1,0>:uw                  
        add3 (8|M0)              r10.0<1>:d    r15.0<1;0>:d      r22.1<4;2>:d      r20.0<1>:d       {I@4}
        mul (8|M0)               acc0.0<1>:f   r14.0<1;1,0>:f    r19.0<1;1,0>:f   {Compacted,I@3}
        sel (8|M0)    (lt)f0.0   r6.0<1>:f     (abs)r68.0<1;1,0>:f  448.0:f            {Compacted,I@2}
        mov (8|M0)               r12.0<2>:d    r9.0<1;1,0>:d                   
        rnde (8|M0)              acc0.0<1>:f   acc0.0<1;1,0>:f                 
        mov (8|M0)               r12.1<2>:d    r10.0<1;1,0>:d                   {I@2}
        shr (8|M0)               r10.0<1>:ud   r6.0<1;1,0>:ud    0x17:uw              {F@2}
        mul (8|M0)               acc0.0<1>:f   acc0.0<1;1,0>:f   r21.0<1;1,0>:f   {Compacted}
        sel (8|M0)    (ge)f0.0   r4.8<2>:ub    r10.0<4;1,0>:ub   0x79:uw              {I@1}
        send.ugm (8|M0)          null     r12     r11:1   0x0            0x04000B84           {$5} // wr:2+1, rd:0; store.ugm.d16u32.a64
        mov (8|M0)               r9.0<1>:f     (abs)acc0.0<1;1,0>:f             {Compacted}
        sync.nop                             null                             {Compacted,$5.src}
        mov (8|M0)               r11.0<1>:d    r4.8<2;1,0>:ub                   {I@1}
(f1.1)  or (8|M0)                r9.0<1>:d     r9.0<1;1,0>:d     -2147483648:d               {F@1}
        shl (8|M0)               r11.0<1>:d    r11.0<1;1,0>:d    23:w               {Compacted,I@2}
        mov (8|M0)               r1.8<1>:hf    r9.0<1;1,0>:f                    {I@2}
        add (8|M0)               r12.0<1>:d    r11.0<1;1,0>:d    -25165824:d               {I@1}
        sel (8|M0)    (lt)f0.0   r9.0<1>:f     (abs)r60.0<1;1,0>:f  448.0:f            {Compacted}
        add (8|M0)               r11.0<1>:d    -r11.0<1;1,0>:d   -2139095040:d              
        shr (8|M0)               r10.0<1>:ud   r9.0<1;1,0>:ud    0x17:uw              {F@1}
        mul (8|M0)               acc0.0<1>:f   r6.0<1;1,0>:f     r11.0<1;1,0>:f   {Compacted,I@2}
        sel (8|M0)    (ge)f0.0   r4.8<2>:ub    r10.0<4;1,0>:ub   0x79:uw              {I@1}
        rnde (8|M0)              acc0.0<1>:f   acc0.0<1;1,0>:f                 
        cmp (8|M0)    (lt)f1.0   null<1>:f     r68.0<1;1,0>:f    0.0:f              
        sel (8|M0)    (lt)f0.0   r10.0<1>:f    (abs)r52.0<1;1,0>:f  448.0:f            {Compacted,I@1}
        mov (8|M0)               r14.0<1>:d    r4.8<2;1,0>:ub                  
        mul (8|M0)               acc0.0<1>:f   acc0.0<1;1,0>:f   r12.0<1;1,0>:f   {Compacted}
        shl (8|M0)               r14.0<1>:d    r14.0<1;1,0>:d    23:w               {Compacted,I@1}
        shr (8|M0)               r12.0<1>:ud   r10.0<1;1,0>:ud   0x17:uw              {A@1}
        mov (8|M0)               r13.0<1>:f    (abs)acc0.0<1;1,0>:f             {Compacted}
        add (8|M0)               r11.0<1>:d    r14.0<1;1,0>:d    -25165824:d               {I@2}
        sel (8|M0)    (ge)f0.0   r4.8<2>:ub    r12.0<4;1,0>:ub   0x79:uw              {I@2}
(f1.0)  or (8|M0)                r13.0<1>:d    r13.0<1;1,0>:d    -2147483648:d               {F@1}
        add (8|M0)               r14.0<1>:d    -r14.0<1;1,0>:d   -2139095040:d              
        mov (2|M0)               r2.0<1>:w     0x5050505:v                              
        mov (8|M0)               r5.8<1>:hf    r13.0<1;1,0>:f                   {I@3}
        mul (8|M0)               acc0.0<1>:f   r9.0<1;1,0>:f     r14.0<1;1,0>:f   {Compacted,I@2}
        mov (8|M0)               r13.0<1>:d    r4.8<2;1,0>:ub                   {F@2}
        or (2|M0)                r1.2<1>:ud    r7.1<1;1,0>:ud    r2.0<1;1,0>:w    {I@2}
        rnde (8|M0)              r9.0<1>:f     acc0.0<1;1,0>:f                  {Compacted}
        shl (8|M0)               r13.0<1>:d    r13.0<1;1,0>:d    23:w               {Compacted,I@2}
        cmp (8|M0)    (lt)f0.1   null<1>:f     r60.0<1;1,0>:f    0.0:f              
        mul (1|M0)               acc0.0<1>:ud  r1.2<0;1,0>:ud    r8.4<0;1,0>:uw   {A@2}
        mul (8|M0)               acc2.0<1>:f   r9.0<1;1,0>:f     r11.0<1;1,0>:f   {Compacted}
        add (8|M0)               r14.0<1>:d    r13.0<1;1,0>:d    -25165824:d               {I@2}
        add (8|M0)               r13.0<1>:d    -r13.0<1;1,0>:d   -2139095040:d              
        mach (1|M0)              r12.0<1>:ud   r1.2<0;1,0>:ud    r8.2<0;1,0>:ud   {AccWrEn}
        mov (8|M0)               r6.0<1>:f     (abs)acc2.0<1;1,0>:f             {Compacted}
        mul (8|M0)               acc2.0<1>:f   r10.0<1;1,0>:f    r13.0<1;1,0>:f   {Compacted,I@2}
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,F@3}
(W)     mul (1|M0)               acc0.0<1>:d   r1.3<0;1,0>:d     r8.4<0;1,0>:uw  
(f0.1)  or (8|M0)                r6.0<1>:d     r6.0<1;1,0>:d     -2147483648:d               {F@2}
        rnde (8|M0)              acc2.0<1>:f   acc2.0<1;1,0>:f                 
        mach (1|M0)              r7.0<1>:d     r1.3<0;1,0>:d     r8.2<0;1,0>:d   
        cmp (8|M0)    (lt)f0.0   null<1>:f     r52.0<1;1,0>:f    0.0:f               {Compacted}
        mov (8|M0)               r7.8<1>:hf    r6.0<1;1,0>:f                    {I@2}
        mul (8|M0)               acc0.0<1>:f   acc2.0<1;1,0>:f   r14.0<1;1,0>:f   {Compacted,I@1}
        add3 (1|M0)              r4.3<1>:d     r7.0<0;0>:d       r12.0<0;0>:d      0:w              
        shl (1|M0)               r6.5<1>:d     r11.0<0;1,0>:d    1:w               {Compacted,F@2}
        shr (1|M0)               r6.4<1>:ud    r11.0<0;1,0>:ud   0x1F:uw             
        mov (8|M0)               r9.0<1>:f     (abs)acc0.0<1;1,0>:f             {Compacted}
        shl (1|M0)               r5.3<1>:d     r4.3<0;1,0>:d     1:w               {Compacted,I@3}
        addc (1|M0)              r8.0<1>:ud    r5.0<0;1,0>:ud    r6.5<0;1,0>:ud   {AccWrEn,A@1}
(f0.0)  or (8|M0)                r9.0<1>:d     r9.0<1;1,0>:d     -2147483648:d              
        or (1|M0)                r6.6<1>:d     r5.3<0;1,0>:d     r6.4<0;1,0>:d    {I@3}
        mov (1|M0)               r2.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (8|M0)               r6.0<1>:hf    r9.0<1;1,0>:f                    {I@3}
        mov (1|M0)               r9.0<1>:f     r8.0<0;1,0>:f                    {Compacted}
        add3 (1|M0)              r9.1<1>:d     r2.0<0;0>:d       r5.2<0;0>:d       r6.6<0>:d        {A@1}
        mov (8|M0)               r13.0<2>:f    r9.0<0;1,0>:f                    {Compacted,F@1}
        mov (8|M0)               r13.1<2>:f    r9.1<0;1,0>:f                    {Compacted,I@1}
        mov (8|M0)               r11.0<1>:d    r1.8<1;1,0>:uw                  
        addc (8|M0)              r10.0<1>:ud   r13.0<2;1,0>:ud   r16.0<2;1,0>:ud  {AccWrEn,Compacted,A@1}
        mov (2|M0)               r1.8<1>:w     0xD0D0D0D:uv                             
        mov (8|M0)               r15.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        addc (1|M0)              r7.0<1>:ud    r9.0<0;1,0>:ud    0x10:ud              {AccWrEn}
        or (2|M0)                r4.2<1>:ud    r7.1<1;1,0>:ud    r1.8<1;1,0>:w    {I@3}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r2.0<1>:f     r7.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r2.1<1>:d     r8.0<0;0>:d       r9.1<0;0>:d       0:w               {I@1}
        mov (8|M0)               r22.0<2>:f    r2.0<0;1,0>:f                    {Compacted,F@1}
        mov (8|M0)               r22.1<2>:f    r2.1<0;1,0>:f                    {Compacted,I@1}
        add3 (8|M0)              r21.0<1>:d    r15.0<1;0>:d      r13.1<4;2>:d      r20.0<1>:d      
        addc (8|M0)              r12.0<1>:ud   r22.0<2;1,0>:ud   r16.0<2;1,0>:ud  {AccWrEn,Compacted,A@1}
        mov (8|M0)               r18.0<2>:d    r10.0<1;1,0>:d                  
        mov (8|M0)               r24.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mul (1|M0)               acc0.0<1>:ud  r4.2<0;1,0>:ud    r8.4<0;1,0>:uw  
        mach (1|M0)              r14.0<1>:ud   r4.2<0;1,0>:ud    r8.2<0;1,0>:ud   {AccWrEn}
        mov (8|M0)               r18.1<2>:d    r21.0<1;1,0>:d                   {I@6}
        mov (1|M0)               r13.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r4.3<0;1,0>:d     r8.4<0;1,0>:uw  
        mach (1|M0)              r2.0<1>:d     r4.3<0;1,0>:d     r8.2<0;1,0>:d   
        shl (1|M0)               r5.3<1>:d     r13.0<0;1,0>:d    1:w               {Compacted,I@3}
        add3 (1|M0)              r6.5<1>:d     r2.0<0;0>:d       r14.0<0;0>:d      0:w               {I@2}
        shr (1|M0)               r7.3<1>:ud    r13.0<0;1,0>:ud   0x1F:uw             
        addc (1|M0)              r8.0<1>:ud    r5.0<0;1,0>:ud    r5.3<0;1,0>:ud   {AccWrEn,I@3}
        shl (1|M0)               r7.0<1>:d     r6.5<0;1,0>:d     1:w               {Compacted,I@3}
        send.ugm (8|M0)          null     r18     r11:1   0x0            0x04000B84           {$6} // wr:2+1, rd:0; store.ugm.d16u32.a64
        add3 (8|M0)              r10.0<1>:d    r24.0<1;0>:d      r22.1<4;2>:d      r20.0<1>:d      
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (8|M0)               r11.0<1>:d    r5.8<1;1,0>:uw                   {$6.src}
        or (1|M0)                r5.4<1>:d     r7.0<0;1,0>:d     r7.3<0;1,0>:d    {I@4}
        mov (8|M0)               r25.0<2>:d    r12.0<1;1,0>:d                  
        mov (1|M0)               r1.2<1>:d     r8.0<0;1,0>:d                   
        mov (8|M0)               r25.1<2>:d    r10.0<1;1,0>:d                   {I@6}
        add3 (1|M0)              r1.3<1>:d     r9.0<0;0>:d       r5.2<0;0>:d       r5.4<0>:d        {I@4}
        send.ugm (8|M0)          null     r25     r11:1   0x0            0x04000B84           {A@2,$7} // wr:2+1, rd:0; store.ugm.d16u32.a64
        mov (8|M0)               r10.0<2>:ud   r1.2<0;1,0>:ud                   {$7.src}
        mov (8|M0)               r10.1<2>:ud   r1.3<0;1,0>:ud                   {I@2}
        mov (8|M0)               r13.0<1>:d    r7.8<1;1,0>:uw                  
        addc (8|M0)              r12.0<1>:ud   r10.0<2;1,0>:ud   r16.0<2;1,0>:ud  {AccWrEn,Compacted,I@2}
        cmp (8|M0)    (lt)f1.1   null<1>:f     r77.0<1;1,0>:f    0.0:f              
        mov (8|M0)               r15.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        addc (1|M0)              r2.0<1>:ud    r1.2<0;1,0>:ud    0x10:ud              {AccWrEn}
        add3 (8|M0)              r21.0<1>:d    r15.0<1;0>:d      r10.1<4;2>:d      r20.0<1>:d       {I@2}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (8|M0)               r18.0<2>:d    r12.0<1;1,0>:d                  
        mov (1|M0)               r1.4<1>:d     r2.0<0;1,0>:d                    {I@4}
        mov (8|M0)               r18.1<2>:d    r21.0<1;1,0>:d                   {I@4}
        add3 (1|M0)              r1.5<1>:d     r8.0<0;0>:d       r1.3<0;0>:d       0:w               {I@4}
        sel (8|M0)    (lt)f0.0   r12.0<1>:f    (abs)r77.0<1;1,0>:f  448.0:f            {Compacted,I@4}
        send.ugm (8|M0)          null     r18     r13:1   0x0            0x04000B84           {A@2,$8} // wr:2+1, rd:0; store.ugm.d16u32.a64
        mov (8|M0)               r22.0<2>:ud   r1.4<0;1,0>:ud                  
        sync.nop                             null                             {Compacted,$8.src}
        shr (8|M0)               r13.0<1>:ud   r12.0<1;1,0>:ud   0x17:uw              {F@1}
        mov (8|M0)               r22.1<2>:ud   r1.5<0;1,0>:ud                   {I@3}
        sel (8|M0)    (ge)f0.0   r4.8<2>:ub    r13.0<4;1,0>:ub   0x79:uw              {I@2}
        addc (8|M0)              r9.0<1>:ud    r22.0<2;1,0>:ud   r16.0<2;1,0>:ud  {AccWrEn,Compacted,I@2}
        mov (8|M0)               r15.0<1>:d    r4.8<2;1,0>:ub                   {I@2}
        mov (8|M0)               r14.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mov (8|M0)               r11.0<1>:d    r6.0<1;1,0>:uw                  
        shl (8|M0)               r15.0<1>:d    r15.0<1;1,0>:d    23:w               {Compacted,I@3}
        add3 (8|M0)              r10.0<1>:d    r14.0<1;0>:d      r22.1<4;2>:d      r20.0<1>:d       {I@3}
        sel (8|M0)    (lt)f0.0   r6.0<1>:f     (abs)r69.0<1;1,0>:f  448.0:f            {Compacted,I@3}
        mov (8|M0)               r24.0<2>:d    r9.0<1;1,0>:d                   
        add (8|M0)               r18.0<1>:d    r15.0<1;1,0>:d    -25165824:d               {I@3}
        mov (8|M0)               r24.1<2>:d    r10.0<1;1,0>:d                   {I@3}
        add (8|M0)               r15.0<1>:d    -r15.0<1;1,0>:d   -2139095040:d              
        shr (8|M0)               r10.0<1>:ud   r6.0<1;1,0>:ud    0x17:uw              {F@1}
        mul (8|M0)               acc0.0<1>:f   r12.0<1;1,0>:f    r15.0<1;1,0>:f   {Compacted,I@2}
        sel (8|M0)    (ge)f0.0   r4.8<2>:ub    r10.0<4;1,0>:ub   0x79:uw              {I@1}
        send.ugm (8|M0)          null     r24     r11:1   0x0            0x04000B84           {$9} // wr:2+1, rd:0; store.ugm.d16u32.a64
        rnde (8|M0)              acc0.0<1>:f   acc0.0<1;1,0>:f                 
        sync.nop                             null                             {Compacted,$9.src}
        mov (8|M0)               r11.0<1>:d    r4.8<2;1,0>:ub                   {I@1}
        mul (8|M0)               acc0.0<1>:f   acc0.0<1;1,0>:f   r18.0<1;1,0>:f   {Compacted}
        shl (8|M0)               r11.0<1>:d    r11.0<1;1,0>:d    23:w               {Compacted,I@1}
        mov (8|M0)               r9.0<1>:f     (abs)acc0.0<1;1,0>:f             {Compacted}
        add (8|M0)               r13.0<1>:d    r11.0<1;1,0>:d    -25165824:d               {I@1}
        add (8|M0)               r11.0<1>:d    -r11.0<1;1,0>:d   -2139095040:d              
(f1.1)  or (8|M0)                r9.0<1>:d     r9.0<1;1,0>:d     -2147483648:d               {F@1}
        mul (8|M0)               acc0.0<1>:f   r6.0<1;1,0>:f     r11.0<1;1,0>:f   {Compacted,I@2}
        mov (8|M0)               r1.8<1>:hf    r9.0<1;1,0>:f                    {I@1}
        rnde (8|M0)              acc0.0<1>:f   acc0.0<1;1,0>:f                 
        sel (8|M0)    (lt)f0.0   r9.0<1>:f     (abs)r61.0<1;1,0>:f  448.0:f            {Compacted}
        cmp (8|M0)    (lt)f1.0   null<1>:f     r69.0<1;1,0>:f    0.0:f              
        mul (8|M0)               acc0.0<1>:f   acc0.0<1;1,0>:f   r13.0<1;1,0>:f   {Compacted}
        shr (8|M0)               r10.0<1>:ud   r9.0<1;1,0>:ud    0x17:uw              {F@3}
        mov (8|M0)               r12.0<1>:f    (abs)acc0.0<1;1,0>:f             {Compacted}
        sel (8|M0)    (ge)f0.0   r4.8<2>:ub    r10.0<4;1,0>:ub   0x79:uw              {I@1}
(f1.0)  or (8|M0)                r12.0<1>:d    r12.0<1;1,0>:d    -2147483648:d               {F@1}
        sel (8|M0)    (lt)f0.0   r10.0<1>:f    (abs)r53.0<1;1,0>:f  448.0:f            {Compacted,I@2}
        mov (8|M0)               r14.0<1>:d    r4.8<2;1,0>:ub                  
        mov (8|M0)               r5.8<1>:hf    r12.0<1;1,0>:f                   {I@2}
        shl (8|M0)               r14.0<1>:d    r14.0<1;1,0>:d    23:w               {Compacted,I@1}
        shr (8|M0)               r12.0<1>:ud   r10.0<1;1,0>:ud   0x17:uw              {A@1}
        add (8|M0)               r11.0<1>:d    r14.0<1;1,0>:d    -25165824:d               {I@2}
        add (8|M0)               r14.0<1>:d    -r14.0<1;1,0>:d   -2139095040:d              
        sel (8|M0)    (ge)f0.0   r4.8<2>:ub    r12.0<4;1,0>:ub   0x79:uw              {I@3}
        mov (2|M0)               r2.0<1>:w     0x6060606:v                              
        mul (8|M0)               acc0.0<1>:f   r9.0<1;1,0>:f     r14.0<1;1,0>:f   {Compacted,I@3}
        mov (8|M0)               r13.0<1>:d    r4.8<2;1,0>:ub                   {I@2}
        or (2|M0)                r1.2<1>:ud    r7.1<1;1,0>:ud    r2.0<1;1,0>:w    {I@2}
        rnde (8|M0)              r9.0<1>:f     acc0.0<1;1,0>:f                  {Compacted}
        shl (8|M0)               r13.0<1>:d    r13.0<1;1,0>:d    23:w               {Compacted,I@2}
        cmp (8|M0)    (lt)f0.1   null<1>:f     r61.0<1;1,0>:f    0.0:f              
        mul (1|M0)               acc0.0<1>:ud  r1.2<0;1,0>:ud    r8.4<0;1,0>:uw   {A@2}
        mul (8|M0)               acc2.0<1>:f   r9.0<1;1,0>:f     r11.0<1;1,0>:f   {Compacted}
        add (8|M0)               r14.0<1>:d    r13.0<1;1,0>:d    -25165824:d               {I@2}
        add (8|M0)               r13.0<1>:d    -r13.0<1;1,0>:d   -2139095040:d              
        mach (1|M0)              r12.0<1>:ud   r1.2<0;1,0>:ud    r8.2<0;1,0>:ud   {AccWrEn}
        mov (8|M0)               r6.0<1>:f     (abs)acc2.0<1;1,0>:f             {Compacted}
        mul (8|M0)               acc2.0<1>:f   r10.0<1;1,0>:f    r13.0<1;1,0>:f   {Compacted,I@2}
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,F@3}
(W)     mul (1|M0)               acc0.0<1>:d   r1.3<0;1,0>:d     r8.4<0;1,0>:uw  
(f0.1)  or (8|M0)                r6.0<1>:d     r6.0<1;1,0>:d     -2147483648:d               {F@2}
        rnde (8|M0)              acc2.0<1>:f   acc2.0<1;1,0>:f                 
        mach (1|M0)              r7.0<1>:d     r1.3<0;1,0>:d     r8.2<0;1,0>:d   
        cmp (8|M0)    (lt)f0.0   null<1>:f     r53.0<1;1,0>:f    0.0:f               {Compacted}
        mov (8|M0)               r7.8<1>:hf    r6.0<1;1,0>:f                    {I@2}
        mul (8|M0)               acc0.0<1>:f   acc2.0<1;1,0>:f   r14.0<1;1,0>:f   {Compacted,I@1}
        add3 (1|M0)              r4.3<1>:d     r7.0<0;0>:d       r12.0<0;0>:d      0:w              
        shl (1|M0)               r6.5<1>:d     r11.0<0;1,0>:d    1:w               {Compacted,F@2}
        shr (1|M0)               r6.4<1>:ud    r11.0<0;1,0>:ud   0x1F:uw             
        mov (8|M0)               r9.0<1>:f     (abs)acc0.0<1;1,0>:f             {Compacted}
        shl (1|M0)               r5.3<1>:d     r4.3<0;1,0>:d     1:w               {Compacted,I@3}
        addc (1|M0)              r8.0<1>:ud    r5.0<0;1,0>:ud    r6.5<0;1,0>:ud   {AccWrEn,A@1}
(f0.0)  or (8|M0)                r9.0<1>:d     r9.0<1;1,0>:d     -2147483648:d              
        or (1|M0)                r6.6<1>:d     r5.3<0;1,0>:d     r6.4<0;1,0>:d    {I@3}
        mov (1|M0)               r2.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (8|M0)               r6.0<1>:hf    r9.0<1;1,0>:f                    {I@3}
        mov (1|M0)               r9.0<1>:f     r8.0<0;1,0>:f                    {Compacted}
        add3 (1|M0)              r9.1<1>:d     r2.0<0;0>:d       r5.2<0;0>:d       r6.6<0>:d        {A@1}
        mov (8|M0)               r13.0<2>:f    r9.0<0;1,0>:f                    {Compacted,F@1}
        mov (8|M0)               r13.1<2>:f    r9.1<0;1,0>:f                    {Compacted,I@1}
        mov (8|M0)               r12.0<1>:d    r1.8<1;1,0>:uw                  
        addc (8|M0)              r10.0<1>:ud   r13.0<2;1,0>:ud   r16.0<2;1,0>:ud  {AccWrEn,Compacted,A@1}
        mov (2|M0)               r1.8<1>:w     0xE0E0E0E:uv                             
        mov (8|M0)               r15.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        addc (1|M0)              r7.0<1>:ud    r9.0<0;1,0>:ud    0x10:ud              {AccWrEn}
        or (2|M0)                r6.4<1>:ud    r7.1<1;1,0>:ud    r1.8<1;1,0>:w    {I@3}
        mov (1|M0)               r2.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r4.2<1>:d     r7.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r4.3<1>:d     r2.0<0;0>:d       r9.1<0;0>:d       0:w               {I@2}
        mov (8|M0)               r21.0<2>:ud   r4.2<0;1,0>:ud                   {I@2}
        mov (8|M0)               r21.1<2>:ud   r4.3<0;1,0>:ud                   {I@2}
        mov (8|M0)               r20.0<1>:d    r16.1<2;1,0>:d                  
        addc (8|M0)              r23.0<1>:ud   r21.0<2;1,0>:ud   r16.0<2;1,0>:ud  {AccWrEn,Compacted,I@2}
        mov (8|M0)               r18.0<2>:d    r10.0<1;1,0>:d                  
        mov (8|M0)               r10.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mul (1|M0)               acc0.0<1>:ud  r6.4<0;1,0>:ud    r8.4<0;1,0>:uw  
        add3 (8|M0)              r11.0<1>:d    r15.0<1;0>:d      r13.1<4;2>:d      r20.0<1>:d       {I@5}
        mach (1|M0)              r15.0<1>:ud   r6.4<0;1,0>:ud    r8.2<0;1,0>:ud   {AccWrEn}
        add3 (8|M0)              r13.0<1>:d    r10.0<1;0>:d      r21.1<4;2>:d      r20.0<1>:d       {I@4}
        mov (1|M0)               r14.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r6.5<0;1,0>:d     r8.4<0;1,0>:uw  
        mach (1|M0)              r2.0<1>:d     r6.5<0;1,0>:d     r8.2<0;1,0>:d   
        shl (1|M0)               r5.3<1>:d     r14.0<0;1,0>:d    1:w               {Compacted,I@3}
        add3 (1|M0)              r4.3<1>:d     r2.0<0;0>:d       r15.0<0;0>:d      0:w               {I@2}
        shr (1|M0)               r7.3<1>:ud    r14.0<0;1,0>:ud   0x1F:uw             
        addc (1|M0)              r8.0<1>:ud    r5.0<0;1,0>:ud    r5.3<0;1,0>:ud   {AccWrEn,I@3}
        shl (1|M0)               r7.0<1>:d     r4.3<0;1,0>:d     1:w               {Compacted,I@3}
        mov (8|M0)               r18.1<2>:d    r11.0<1;1,0>:d                  
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (8|M0)               r11.0<1>:d    r5.8<1;1,0>:uw                  
        or (1|M0)                r5.4<1>:d     r7.0<0;1,0>:d     r7.3<0;1,0>:d    {I@4}
        mov (8|M0)               r24.0<2>:d    r23.0<1;1,0>:d                  
        mov (1|M0)               r1.2<1>:d     r8.0<0;1,0>:d                   
        mov (8|M0)               r24.1<2>:d    r13.0<1;1,0>:d                  
        add3 (1|M0)              r1.3<1>:d     r9.0<0;0>:d       r5.2<0;0>:d       r5.4<0>:d        {I@4}
        send.ugm (8|M0)          null     r18     r12:1   0x0            0x04000B84           {$10} // wr:2+1, rd:0; store.ugm.d16u32.a64
        send.ugm (8|M0)          null     r24     r11:1   0x0            0x04000B84           {A@2,$11} // wr:2+1, rd:0; store.ugm.d16u32.a64
        mov (8|M0)               r10.0<2>:ud   r1.2<0;1,0>:ud                   {$11.src}
        mov (8|M0)               r10.1<2>:ud   r1.3<0;1,0>:ud                   {I@2}
        mov (8|M0)               r14.0<1>:d    r7.8<1;1,0>:uw                  
        sync.nop                             null                             {Compacted,$10.src}
        addc (8|M0)              r12.0<1>:ud   r10.0<2;1,0>:ud   r16.0<2;1,0>:ud  {AccWrEn,Compacted,I@2}
        cmp (8|M0)    (lt)f1.1   null<1>:f     r78.0<1;1,0>:f    0.0:f              
        mov (8|M0)               r13.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mov (8|M0)               r18.0<2>:d    r12.0<1;1,0>:d                   {I@2}
        add3 (8|M0)              r21.0<1>:d    r13.0<1;0>:d      r10.1<4;2>:d      r20.0<1>:d       {I@2}
        addc (1|M0)              r2.0<1>:ud    r1.2<0;1,0>:ud    0x10:ud              {AccWrEn}
        mov (8|M0)               r18.1<2>:d    r21.0<1;1,0>:d                   {I@2}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        send.ugm (8|M0)          null     r18     r14:1   0x0            0x04000B84           {A@2,$12} // wr:2+1, rd:0; store.ugm.d16u32.a64
        sel (8|M0)    (lt)f0.0   r14.0<1>:f    (abs)r78.0<1;1,0>:f  448.0:f            {Compacted,$12.src}
        mov (1|M0)               r1.4<1>:d     r2.0<0;1,0>:d                   
        shr (8|M0)               r18.0<1>:ud   r14.0<1;1,0>:ud   0x17:uw              {F@1}
        add3 (1|M0)              r1.5<1>:d     r8.0<0;0>:d       r1.3<0;0>:d       0:w               {I@3}
        sel (8|M0)    (ge)f0.0   r4.8<2>:ub    r18.0<4;1,0>:ub   0x79:uw              {I@2}
        mov (8|M0)               r22.0<2>:ud   r1.4<0;1,0>:ud                  
        mov (8|M0)               r22.1<2>:ud   r1.5<0;1,0>:ud                   {I@3}
        mov (8|M0)               r19.0<1>:d    r4.8<2;1,0>:ub                   {I@3}
        addc (8|M0)              r9.0<1>:ud    r22.0<2;1,0>:ud   r16.0<2;1,0>:ud  {AccWrEn,Compacted,I@2}
        shl (8|M0)               r19.0<1>:d    r19.0<1;1,0>:d    23:w               {Compacted,I@2}
        mov (8|M0)               r15.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        add (8|M0)               r21.0<1>:d    r19.0<1;1,0>:d    -25165824:d               {I@2}
        add (8|M0)               r19.0<1>:d    -r19.0<1;1,0>:d   -2139095040:d              
        mov (8|M0)               r11.0<1>:d    r6.0<1;1,0>:uw                  
        add3 (8|M0)              r10.0<1>:d    r15.0<1;0>:d      r22.1<4;2>:d      r20.0<1>:d       {I@4}
        mul (8|M0)               acc0.0<1>:f   r14.0<1;1,0>:f    r19.0<1;1,0>:f   {Compacted,I@3}
        sel (8|M0)    (lt)f0.0   r6.0<1>:f     (abs)r70.0<1;1,0>:f  448.0:f            {Compacted,I@2}
        mov (8|M0)               r12.0<2>:d    r9.0<1;1,0>:d                   
        rnde (8|M0)              acc0.0<1>:f   acc0.0<1;1,0>:f                 
        mov (8|M0)               r12.1<2>:d    r10.0<1;1,0>:d                   {I@2}
        shr (8|M0)               r10.0<1>:ud   r6.0<1;1,0>:ud    0x17:uw              {F@2}
        mul (8|M0)               acc0.0<1>:f   acc0.0<1;1,0>:f   r21.0<1;1,0>:f   {Compacted}
        sel (8|M0)    (ge)f0.0   r4.8<2>:ub    r10.0<4;1,0>:ub   0x79:uw              {I@1}
        send.ugm (8|M0)          null     r12     r11:1   0x0            0x04000B84           {$13} // wr:2+1, rd:0; store.ugm.d16u32.a64
        mov (8|M0)               r9.0<1>:f     (abs)acc0.0<1;1,0>:f             {Compacted}
        sync.nop                             null                             {Compacted,$13.src}
        mov (8|M0)               r11.0<1>:d    r4.8<2;1,0>:ub                   {I@1}
(f1.1)  or (8|M0)                r9.0<1>:d     r9.0<1;1,0>:d     -2147483648:d               {F@1}
        shl (8|M0)               r11.0<1>:d    r11.0<1;1,0>:d    23:w               {Compacted,I@2}
        mov (8|M0)               r1.8<1>:hf    r9.0<1;1,0>:f                    {I@2}
        add (8|M0)               r12.0<1>:d    r11.0<1;1,0>:d    -25165824:d               {I@1}
        sel (8|M0)    (lt)f0.0   r9.0<1>:f     (abs)r62.0<1;1,0>:f  448.0:f            {Compacted}
        add (8|M0)               r11.0<1>:d    -r11.0<1;1,0>:d   -2139095040:d              
        shr (8|M0)               r10.0<1>:ud   r9.0<1;1,0>:ud    0x17:uw              {F@1}
        mul (8|M0)               acc0.0<1>:f   r6.0<1;1,0>:f     r11.0<1;1,0>:f   {Compacted,I@2}
        sel (8|M0)    (ge)f0.0   r4.8<2>:ub    r10.0<4;1,0>:ub   0x79:uw              {I@1}
        rnde (8|M0)              acc0.0<1>:f   acc0.0<1;1,0>:f                 
        cmp (8|M0)    (lt)f1.0   null<1>:f     r70.0<1;1,0>:f    0.0:f              
        sel (8|M0)    (lt)f0.0   r10.0<1>:f    (abs)r54.0<1;1,0>:f  448.0:f            {Compacted,I@1}
        mov (8|M0)               r14.0<1>:d    r4.8<2;1,0>:ub                  
        mul (8|M0)               acc0.0<1>:f   acc0.0<1;1,0>:f   r12.0<1;1,0>:f   {Compacted}
        shl (8|M0)               r14.0<1>:d    r14.0<1;1,0>:d    23:w               {Compacted,I@1}
        shr (8|M0)               r12.0<1>:ud   r10.0<1;1,0>:ud   0x17:uw              {A@1}
        mov (8|M0)               r13.0<1>:f    (abs)acc0.0<1;1,0>:f             {Compacted}
        add (8|M0)               r11.0<1>:d    r14.0<1;1,0>:d    -25165824:d               {I@2}
        sel (8|M0)    (ge)f0.0   r4.8<2>:ub    r12.0<4;1,0>:ub   0x79:uw              {I@2}
(f1.0)  or (8|M0)                r13.0<1>:d    r13.0<1;1,0>:d    -2147483648:d               {F@1}
        add (8|M0)               r14.0<1>:d    -r14.0<1;1,0>:d   -2139095040:d              
        mov (2|M0)               r2.0<1>:w     0x7070707:v                              
        mov (8|M0)               r5.8<1>:hf    r13.0<1;1,0>:f                   {I@3}
        mul (8|M0)               acc0.0<1>:f   r9.0<1;1,0>:f     r14.0<1;1,0>:f   {Compacted,I@2}
        mov (8|M0)               r13.0<1>:d    r4.8<2;1,0>:ub                   {F@2}
        or (2|M0)                r1.2<1>:ud    r7.1<1;1,0>:ud    r2.0<1;1,0>:w    {I@2}
        rnde (8|M0)              r9.0<1>:f     acc0.0<1;1,0>:f                  {Compacted}
        shl (8|M0)               r13.0<1>:d    r13.0<1;1,0>:d    23:w               {Compacted,I@2}
        cmp (8|M0)    (lt)f0.1   null<1>:f     r62.0<1;1,0>:f    0.0:f              
        mul (1|M0)               acc0.0<1>:ud  r1.2<0;1,0>:ud    r8.4<0;1,0>:uw   {A@2}
        mul (8|M0)               acc2.0<1>:f   r9.0<1;1,0>:f     r11.0<1;1,0>:f   {Compacted}
        add (8|M0)               r14.0<1>:d    r13.0<1;1,0>:d    -25165824:d               {I@2}
        add (8|M0)               r13.0<1>:d    -r13.0<1;1,0>:d   -2139095040:d              
        mach (1|M0)              r12.0<1>:ud   r1.2<0;1,0>:ud    r8.2<0;1,0>:ud   {AccWrEn}
        mov (8|M0)               r6.0<1>:f     (abs)acc2.0<1;1,0>:f             {Compacted}
        mul (8|M0)               acc2.0<1>:f   r10.0<1;1,0>:f    r13.0<1;1,0>:f   {Compacted,I@2}
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,F@3}
(W)     mul (1|M0)               acc0.0<1>:d   r1.3<0;1,0>:d     r8.4<0;1,0>:uw  
(f0.1)  or (8|M0)                r6.0<1>:d     r6.0<1;1,0>:d     -2147483648:d               {F@2}
        rnde (8|M0)              acc2.0<1>:f   acc2.0<1;1,0>:f                 
        mach (1|M0)              r7.0<1>:d     r1.3<0;1,0>:d     r8.2<0;1,0>:d   
        cmp (8|M0)    (lt)f0.0   null<1>:f     r54.0<1;1,0>:f    0.0:f               {Compacted}
        mov (8|M0)               r7.8<1>:hf    r6.0<1;1,0>:f                    {I@2}
        mul (8|M0)               acc0.0<1>:f   acc2.0<1;1,0>:f   r14.0<1;1,0>:f   {Compacted,I@1}
        add3 (1|M0)              r4.3<1>:d     r7.0<0;0>:d       r12.0<0;0>:d      0:w              
        shl (1|M0)               r6.5<1>:d     r11.0<0;1,0>:d    1:w               {Compacted,F@2}
        shr (1|M0)               r6.4<1>:ud    r11.0<0;1,0>:ud   0x1F:uw             
        mov (8|M0)               r9.0<1>:f     (abs)acc0.0<1;1,0>:f             {Compacted}
        shl (1|M0)               r5.3<1>:d     r4.3<0;1,0>:d     1:w               {Compacted,I@3}
        addc (1|M0)              r8.0<1>:ud    r5.0<0;1,0>:ud    r6.5<0;1,0>:ud   {AccWrEn,A@1}
(f0.0)  or (8|M0)                r9.0<1>:d     r9.0<1;1,0>:d     -2147483648:d              
        or (1|M0)                r6.6<1>:d     r5.3<0;1,0>:d     r6.4<0;1,0>:d    {I@3}
        mov (1|M0)               r2.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (8|M0)               r6.0<1>:hf    r9.0<1;1,0>:f                    {I@3}
        mov (1|M0)               r9.0<1>:f     r8.0<0;1,0>:f                    {Compacted}
        add3 (1|M0)              r9.1<1>:d     r2.0<0;0>:d       r5.2<0;0>:d       r6.6<0>:d        {A@1}
        mov (8|M0)               r13.0<2>:f    r9.0<0;1,0>:f                    {Compacted,F@1}
        mov (8|M0)               r13.1<2>:f    r9.1<0;1,0>:f                    {Compacted,I@1}
        mov (8|M0)               r11.0<1>:d    r1.8<1;1,0>:uw                  
        addc (8|M0)              r10.0<1>:ud   r13.0<2;1,0>:ud   r16.0<2;1,0>:ud  {AccWrEn,Compacted,A@1}
        mov (2|M0)               r1.8<1>:w     0xF0F0F0F:uv                             
        mov (8|M0)               r15.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        addc (1|M0)              r7.0<1>:ud    r9.0<0;1,0>:ud    0x10:ud              {AccWrEn}
        or (2|M0)                r7.1<1>:ud    r7.1<1;1,0>:ud    r1.8<1;1,0>:w    {I@3}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r2.0<1>:f     r7.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r2.1<1>:d     r8.0<0;0>:d       r9.1<0;0>:d       0:w               {I@1}
        mov (8|M0)               r22.0<2>:f    r2.0<0;1,0>:f                    {Compacted,F@1}
        mov (8|M0)               r22.1<2>:f    r2.1<0;1,0>:f                    {Compacted,I@1}
        add3 (8|M0)              r21.0<1>:d    r15.0<1;0>:d      r13.1<4;2>:d      r20.0<1>:d      
        addc (8|M0)              r12.0<1>:ud   r22.0<2;1,0>:ud   r16.0<2;1,0>:ud  {AccWrEn,Compacted,A@1}
        mov (8|M0)               r18.0<2>:d    r10.0<1;1,0>:d                  
        mov (8|M0)               r24.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mul (1|M0)               acc0.0<1>:ud  r7.1<0;1,0>:ud    r8.4<0;1,0>:uw  
        mach (1|M0)              r14.0<1>:ud   r7.1<0;1,0>:ud    r8.2<0;1,0>:ud   {AccWrEn}
        mov (8|M0)               r18.1<2>:d    r21.0<1;1,0>:d                   {I@6}
        mov (1|M0)               r13.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r7.2<0;1,0>:d     r8.4<0;1,0>:uw  
        mach (1|M0)              r2.0<1>:d     r7.2<0;1,0>:d     r8.2<0;1,0>:d   
        shl (1|M0)               r5.3<1>:d     r13.0<0;1,0>:d    1:w               {Compacted,I@3}
        add3 (1|M0)              r4.3<1>:d     r2.0<0;0>:d       r14.0<0;0>:d      0:w               {I@2}
        add3 (8|M0)              r10.0<1>:d    r24.0<1;0>:d      r22.1<4;2>:d      r20.0<1>:d      
        shr (1|M0)               r6.5<1>:ud    r13.0<0;1,0>:ud   0x1F:uw             
        addc (1|M0)              r9.0<1>:ud    r5.0<0;1,0>:ud    r5.3<0;1,0>:ud   {AccWrEn,I@4}
        shl (1|M0)               r6.4<1>:d     r4.3<0;1,0>:d     1:w               {I@4}
        send.ugm (8|M0)          null     r18     r11:1   0x0            0x04000B84           {$14} // wr:2+1, rd:0; store.ugm.d16u32.a64
        mov (8|M0)               r25.0<2>:d    r12.0<1;1,0>:d                  
        mov (8|M0)               r11.0<1>:d    r5.8<1;1,0>:uw                   {$14.src}
        mov (8|M0)               r25.1<2>:d    r10.0<1;1,0>:d                   {I@6}
        or (1|M0)                r5.4<1>:d     r6.4<0;1,0>:d     r6.5<0;1,0>:d    {I@4}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r1.2<1>:d     r9.0<0;1,0>:d                   
        add3 (1|M0)              r1.3<1>:d     r10.0<0;0>:d      r5.2<0;0>:d       r5.4<0>:d        {I@2}
        send.ugm (8|M0)          null     r25     r11:1   0x0            0x04000B84           {$15} // wr:2+1, rd:0; store.ugm.d16u32.a64
        sync.nop                             null                             {Compacted,$15.src}
        mov (8|M0)               r11.0<2>:ud   r1.2<0;1,0>:ud                   {I@2}
        mov (8|M0)               r11.1<2>:ud   r1.3<0;1,0>:ud                   {I@2}
        mov (8|M0)               r13.0<1>:d    r7.8<1;1,0>:uw                  
        addc (8|M0)              r8.0<1>:ud    r11.0<2;1,0>:ud   r16.0<2;1,0>:ud  {AccWrEn,Compacted,I@2}
        mov (8|M0)               r7.0<1>:d     r6.0<1;1,0>:uw                  
        mov (8|M0)               r15.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        addc (1|M0)              r2.0<1>:ud    r1.2<0;1,0>:ud    0x10:ud              {AccWrEn}
        mov (8|M0)               r18.0<2>:d    r8.0<1;1,0>:d                    {I@4}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r1.4<1>:d     r2.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r1.5<1>:d     r9.0<0;0>:d       r1.3<0;0>:d       0:w               {I@2}
        mov (8|M0)               r22.0<2>:ud   r1.4<0;1,0>:ud                   {I@2}
        mov (8|M0)               r22.1<2>:ud   r1.5<0;1,0>:ud                   {I@2}
        add3 (8|M0)              r21.0<1>:d    r15.0<1;0>:d      r11.1<4;2>:d      r20.0<1>:d      
        addc (8|M0)              r5.0<1>:ud    r22.0<2;1,0>:ud   r16.0<2;1,0>:ud  {AccWrEn,Compacted,I@2}
        mov (8|M0)               r18.1<2>:d    r21.0<1;1,0>:d                   {I@2}
        mov (8|M0)               r10.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mov (8|M0)               r14.0<2>:d    r5.0<1;1,0>:d                    {I@3}
        add3 (8|M0)              r8.0<1>:d     r10.0<1;0>:d      r22.1<4;2>:d      r20.0<1>:d       {I@2}
        send.ugm (8|M0)          null     r18     r13:1   0x0            0x04000B84           {$0} // wr:2+1, rd:0; store.ugm.d16u32.a64
        mov (8|M0)               r14.1<2>:d    r8.0<1;1,0>:d                    {I@1}
(W)     mov (8|M0)               r127.0<1>:f   r0.0<1;1,0>:f                    {Compacted}
        sync.nop                             null                             {Compacted,I@1}
        send.ugm (8|M0)          null     r14     r7:1    0x0            0x04000B84           {$1} // wr:2+1, rd:0; store.ugm.d16u32.a64
(W)     send.ugm (1|M0)          r11      r0      null:0  0x0            0x0210641F           {$2} // wr:1+0, rd:1; fence invalid flush type scoped to tile
(W)     mov (8|M0)               null<1>:ud    r11.0<1;1,0>:ud                  {$2.dst}
(W)     send.gtwy (1|M0)         null     r127    null:0  0x0            0x02000010           {EOT,A@1} // wr:1+0, rd:0; end of thread
L19272:
        mov (1|M0)               r1.2<1>:d     cr0.0<0;1,0>:ud                  {A@1}
        and (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   -1265:w               {A@1}
        or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   1264:w               {A@1}
        mov (1|M0)               r1.5<1>:f     (abs)r79.1<0;1,0>:d              {A@1}
        mov (1|M0)               r5.2<1>:f     0xB4C00000:f                               {Compacted}
        math.inv (1|M0)          r5.1<1>:f     r1.5<0;1,0>:f                    {@2,$3}
        mov (1|M0)               r2.1<1>:f     (abs)r79.0<0;1,0>:d              {Compacted}
        sync.nop                             null                             {Compacted,$3.dst}
        mad (1|M0)               r5.1<1>:f     r5.1<0;0>:f       r5.2<0;0>:f       r5.1<0>:f        {F@2}
        mov (1|M0)               r1.3<1>:d     (abs)r79.0<0;1,0>:d             
        mov (1|M0)               r1.4<1>:d     (abs)r79.1<0;1,0>:d             
        mov (1|M0)               r1.6<1>:ud    r1.5<0;1,0>:f                   
        mov (1|M0)               r4.2<1>:ud    r2.1<0;1,0>:f                    {F@2}
        mul (1|M0)               r6.0<1>:f     r5.1<0;1,0>:f     r2.1<0;1,0>:f    {F@1}
        add (1|M0)               r1.6<1>:ud    r1.4<0;1,0>:ud    -r1.6<0;1,0>:ud  {I@2}
        add (1|M0)               r4.2<1>:ud    r1.3<0;1,0>:ud    -r4.2<0;1,0>:ud  {I@2}
        mov (1|M0)               r7.0<1>:ud    r6.0<0;1,0>:f                    {F@1}
        mov (1|M0)               r2.0<1>:f     r1.6<0;1,0>:ud                   {Compacted,I@3}
        mov (1|M0)               r5.0<1>:f     r4.2<0;1,0>:ud                   {Compacted,I@2}
        mov (1|M0)               r7.1<1>:f     r7.0<0;1,0>:ud                   {Compacted,I@1}
        xor (1|M0)               r79.1<1>:d    r79.1<0;1,0>:d    r79.0<0;1,0>:d   {Compacted}
        mad (1|M0)               r2.1<1>:f     r2.1<0;0>:f       r7.1<0;0>:f       -r1.5<0>:f       {F@1}
        mad (1|M0)               r7.1<1>:f     r5.0<0;0>:f       r7.1<0;0>:f       -r2.0<0>:f      
(W)     mov (1|M0)               r4.4<1>:hf    0x1:hf                             
        add (1|M0)               r2.1<1>:f     r2.1<0;1,0>:f     r7.1<0;1,0>:f    {F@2}
        asr (1|M0)               r79.1<1>:d    r79.1<0;1,0>:d    31:w               {Compacted,I@1}
        mul (1|M0)               r5.1<1>:f     r5.1<0;1,0>:f     r2.1<0;1,0>:f    {F@1}
        mov (1|M0)               r8.0<1>:ud    r5.1<0;1,0>:f                    {F@1}
        add (1|M0)               r7.0<1>:ud    r7.0<0;1,0>:ud    r8.0<0;1,0>:ud   {Compacted,I@1}
(W)     mul (1|M0)               acc0.0<1>:ud  r7.0<0;1,0>:ud    r1.8<0;1,0>:uw   {I@1}
        mach (1|M0)              r9.0<1>:ud    r7.0<0;1,0>:ud    r1.4<0;1,0>:ud   {Compacted}
        add (1|M0)               r1.3<1>:ud    r1.3<0;1,0>:ud    -r9.0<0;1,0>:ud  {Compacted,I@1}
        cmp (1|M0)    (ge)f0.1   null<1>:ud    r1.3<0;1,0>:ud    r1.4<0;1,0>:ud   {I@1}
(f0.1)  sel (1|M0)               r6.0<1>:d     r4.4<0;1,0>:w     0:w              
        add3 (1|M0)              r7.0<1>:d     r7.0<0;0>:d       r79.1<0;0>:d      r6.0<0>:d        {I@1}
        xor (1|M0)               r42.2<1>:d    r7.0<0;1,0>:d     r79.1<0;1,0>:d   {I@1}
        mov (1|M0)               cr0.0<1>:ud   r1.2<0;1,0>:d                    {A@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        ret (16|M0)                          r46.6                            {A@1}
L19824:
        mov (1|M0)               r1.2<1>:d     cr0.0<0;1,0>:ud                  {A@1}
        and (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   -1265:w               {A@1}
        or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   1264:w               {A@1}
        mov (1|M0)               r1.3<1>:f     r46.4<0;1,0>:ud                  {A@1}
        mov (1|M0)               r4.2<1>:f     0xB4C00000:f                               {Compacted}
        math.inv (1|M0)          r2.1<1>:f     r1.3<0;1,0>:f                    {@2,$4}
        mov (1|M0)               r1.5<1>:f     r80.1<0;1,0>:ud                 
        sync.nop                             null                             {Compacted,$4.dst}
        mad (1|M0)               r2.1<1>:f     r2.1<0;0>:f       r4.2<0;0>:f       r2.1<0>:f        {F@2}
        mov (1|M0)               r80.0<1>:ud   r1.3<0;1,0>:f                   
        mov (1|M0)               r1.6<1>:ud    r1.5<0;1,0>:f                    {F@2}
        mul (1|M0)               r5.0<1>:f     r2.1<0;1,0>:f     r1.5<0;1,0>:f    {F@1}
        add (1|M0)               r80.0<1>:ud   r46.4<0;1,0>:ud   -r80.0<0;1,0>:ud {Compacted,I@2}
        add (1|M0)               r1.6<1>:ud    r80.1<0;1,0>:ud   -r1.6<0;1,0>:ud  {I@2}
        mov (1|M0)               r6.0<1>:ud    r5.0<0;1,0>:f                    {F@1}
        mov (1|M0)               r1.4<1>:f     r80.0<0;1,0>:ud                  {Compacted,I@3}
        mov (1|M0)               r2.0<1>:f     r1.6<0;1,0>:ud                   {Compacted,I@2}
        mov (1|M0)               r6.1<1>:f     r6.0<0;1,0>:ud                   {Compacted,I@1}
(W)     mov (1|M0)               r4.4<1>:hf    0x1:hf                             
        mad (1|M0)               r1.5<1>:f     r1.5<0;0>:f       r6.1<0;0>:f       -r1.3<0>:f       {F@2}
        mad (1|M0)               r6.1<1>:f     r2.0<0;0>:f       r6.1<0;0>:f       -r1.4<0>:f      
        add (1|M0)               r1.5<1>:f     r1.5<0;1,0>:f     r6.1<0;1,0>:f    {F@1}
        mul (1|M0)               r2.1<1>:f     r2.1<0;1,0>:f     r1.5<0;1,0>:f    {F@1}
        mov (1|M0)               r7.0<1>:ud    r2.1<0;1,0>:f                    {F@1}
        add (1|M0)               r6.0<1>:ud    r6.0<0;1,0>:ud    r7.0<0;1,0>:ud   {Compacted,I@1}
(W)     mul (1|M0)               acc0.0<1>:ud  r6.0<0;1,0>:ud    r46.8<0;1,0>:uw  {I@1}
        mach (1|M0)              r8.0<1>:ud    r6.0<0;1,0>:ud    r46.4<0;1,0>:ud  {Compacted}
        add (1|M0)               r80.1<1>:ud   r80.1<0;1,0>:ud   -r8.0<0;1,0>:ud  {Compacted,I@1}
        cmp (1|M0)    (ge)f0.0   null<1>:ud    r80.1<0;1,0>:ud   r46.4<0;1,0>:ud  {I@1}
(f0.0)  sel (1|M0)               r5.0<1>:d     r4.4<0;1,0>:w     0:w              
        add (1|M0)               r46.5<1>:ud   r6.0<0;1,0>:ud    r5.0<0;1,0>:ud   {Compacted,I@1}
        mov (1|M0)               cr0.0<1>:ud   r1.2<0;1,0>:d                    {A@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        ret (16|M0)                          r79.2                            {A@1}
L20304:
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
