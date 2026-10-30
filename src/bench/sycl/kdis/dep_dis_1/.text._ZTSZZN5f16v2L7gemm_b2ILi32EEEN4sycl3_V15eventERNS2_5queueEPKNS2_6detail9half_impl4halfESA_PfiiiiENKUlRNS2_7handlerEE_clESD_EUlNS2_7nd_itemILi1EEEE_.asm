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
(W)     call (16|M0)             r46.6         L8432                                 {A@1}
L352:
        asr (1|M0)               r79.5<1>:d    r2.3<0;1,0>:d     31:w              
        mov (1|M0)               r42.1<1>:d    r45.7<0;1,0>:d                  
        shr (1|M0)               r79.5<1>:ud   r79.5<0;1,0>:ud   0x1B:uw              {I@2}
(W)     mul (1|M0)               acc0.0<1>:d   r42.1<0;1,0>:d    r2.4<0;1,0>:uw   {I@2}
        mach (1|M0)              r2.0<1>:d     r42.1<0;1,0>:d    r2.2<0;1,0>:d   
        add (1|M0)               r79.5<1>:d    r2.3<0;1,0>:d     r79.5<0;1,0>:d   {I@3}
        add (1|M0)               r79.4<1>:d    r79.4<0;1,0>:d    -r2.0<0;1,0>:d   {I@2}
        asr (1|M0)               r79.5<1>:d    r79.5<0;1,0>:d    5:w               {I@2}
        mov (2|M0)               r79.0<1>:d    r79.4<1;1,0>:d                   {I@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r46.6         L8432                                 {A@1}
L544:
        mov (1|M0)               r1.2<1>:d     r42.1<0;1,0>:d                  
(W)     mul (1|M0)               acc0.0<1>:d   r45.7<0;1,0>:d    r79.10<0;1,0>:uw
(W)     mach (1|M0)              r2.0<1>:d     r45.7<0;1,0>:d    r79.5<0;1,0>:d  
        mul (1|M0)               acc0.0<1>:ud  r1.2<0;1,0>:ud    r2.12<0;1,0>:uw  {I@3}
        mach (1|M0)              r6.0<1>:ud    r1.2<0;1,0>:ud    r2.6<0;1,0>:ud   {AccWrEn}
        asr (1|M0)               r1.3<1>:d     r42.1<0;1,0>:d    31:w              
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r1.2<0;1,0>:d     r2.14<0;1,0>:uw 
        shl (1|M0)               r4.2<1>:d     r5.0<0;1,0>:d     1:w               {Compacted,I@2}
        mach (1|M0)              r7.0<1>:d     r1.2<0;1,0>:d     r2.7<0;1,0>:d   
(W)     mul (1|M0)               acc0.0<1>:d   r1.3<0;1,0>:d     r2.12<0;1,0>:uw 
        mach (1|M0)              r8.0<1>:d     r1.3<0;1,0>:d     r2.6<0;1,0>:d   
        addc (1|M0)              r9.0<1>:ud    r2.4<0;1,0>:ud    r4.2<0;1,0>:ud   {AccWrEn,I@4}
        add3 (1|M0)              r1.5<1>:d     r8.0<0;0>:d       r6.0<0;0>:d       r7.0<0>:d        {I@2}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mul (1|M0)               acc0.0<1>:ud  r1.2<0;1,0>:ud    r3.4<0;1,0>:uw  
        mach (1|M0)              r12.0<1>:ud   r1.2<0;1,0>:ud    r3.2<0;1,0>:ud   {AccWrEn}
        shr (1|M0)               r2.1<1>:ud    r5.0<0;1,0>:ud    0x1F:uw             
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r1.2<0;1,0>:d     r3.6<0;1,0>:uw  
        mach (1|M0)              r7.0<1>:d     r1.2<0;1,0>:d     r3.3<0;1,0>:d   
(W)     mul (1|M0)               acc0.0<1>:d   r1.3<0;1,0>:d     r3.4<0;1,0>:uw  
        mach (1|M0)              r5.0<1>:d     r1.3<0;1,0>:d     r3.2<0;1,0>:d   
        mul (1|M0)               acc0.0<1>:ud  r1.2<0;1,0>:ud    r3.12<0;1,0>:uw 
        shr (1|M0)               r44.3<1>:ud   r42.0<0;1,0>:ud   0x1:uw             
        shl (1|M0)               r45.7<1>:d    r45.7<0;1,0>:d    2:w              
        mach (1|M0)              r14.0<1>:ud   r1.2<0;1,0>:ud    r3.6<0;1,0>:ud   {AccWrEn}
        mov (1|M0)               r79.5<1>:d    r2.0<0;1,0>:d                   
        shl (1|M0)               r2.0<1>:d     r1.5<0;1,0>:d     1:w               {Compacted}
        add (1|M0)               r45.7<1>:d    r45.7<0;1,0>:d    r44.3<0;1,0>:d   {I@4}
        mov (1|M0)               r13.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r1.2<0;1,0>:d     r3.14<0;1,0>:uw 
        or (1|M0)                r4.3<1>:d     r2.0<0;1,0>:d     r2.1<0;1,0>:d    {I@4}
        mach (1|M0)              r2.0<1>:d     r1.2<0;1,0>:d     r3.7<0;1,0>:d   
(W)     mul (1|M0)               acc0.0<1>:d   r1.3<0;1,0>:d     r3.12<0;1,0>:uw 
        mach (1|M0)              r6.0<1>:d     r1.3<0;1,0>:d     r3.6<0;1,0>:d   
(W)     mul (1|M0)               acc0.0<1>:d   r45.7<0;1,0>:d    r4.0<0;1,0>:uw   {Compacted,I@7}
        add3 (1|M0)              r1.5<1>:d     r5.0<0;0>:d       r12.0<0;0>:d      r7.0<0>:d       
        mach (1|M0)              r5.0<1>:d     r45.7<0;1,0>:d    r4.0<0;1,0>:d    {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r45.7<0;1,0>:d    r4.0<0;1,0>:uw   {Compacted}
        mach (1|M0)              r43.0<1>:d    r45.7<0;1,0>:d    r4.0<0;1,0>:d    {Compacted}
        asr (1|M0)               r43.1<1>:d    r5.0<0;1,0>:d     31:w               {Compacted,I@3}
        mul (1|M0)               r4.5<1>:d     r44.3<0;1,0>:d    -256:w              
        shr (1|M0)               r1.3<1>:ud    r43.0<0;1,0>:ud   0x18:uw              {I@3}
        shl (1|M0)               r1.6<1>:d     r43.0<0;1,0>:d    8:w               {Compacted}
        shl (1|M0)               r1.2<1>:d     r43.1<0;1,0>:d    8:w               {I@4}
        mov (1|M0)               r42.2<1>:d    r9.0<0;1,0>:d                   
        add3 (1|M0)              r42.3<1>:d    r10.0<0;0>:d      r2.5<0;0>:d       r4.3<0>:d       
        mad (1|M0)               r4.6<1>:d     r4.5<0;0>:d       r1.0<0;0>:uw      128:w               {I@6}
        mad (1|M0)               r5.0<1>:d     r4.5<0;0>:d       r1.0<0;0>:uw      128:w              
        or (1|M0)                r1.7<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@5}
        add3 (1|M0)              r4.3<1>:d     r6.0<0;0>:d       r14.0<0;0>:d      r2.0<0>:d       
        shl (1|M0)               r6.0<1>:d     r1.6<0;1,0>:d     1:w               {Compacted}
        shr (1|M0)               r2.1<1>:ud    r1.6<0;1,0>:ud    0x1F:uw             
        asr (1|M0)               r5.1<1>:d     r4.6<0;1,0>:d     31:w               {I@6}
        shl (1|M0)               r42.4<1>:d    r5.0<0;1,0>:d     1:w               {Compacted,I@6}
        shl (1|M0)               r2.0<1>:d     r1.7<0;1,0>:d     1:w               {Compacted,I@6}
        addc (1|M0)              r7.0<1>:ud    r42.2<0;1,0>:ud   r6.0<0;1,0>:ud   {AccWrEn,I@5}
        shr (1|M0)               r5.3<1>:ud    r5.0<0;1,0>:ud    0x1F:uw             
        shl (1|M0)               r5.2<1>:d     r5.1<0;1,0>:d     1:w               {I@5}
        or (1|M0)                r6.1<1>:d     r2.0<0;1,0>:d     r2.1<0;1,0>:d    {I@4}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r9.0<1>:ud    r7.0<0;1,0>:ud    r42.4<0;1,0>:ud  {AccWrEn,I@5}
        or (1|M0)                r42.5<1>:d    r5.2<0;1,0>:d     r5.3<0;1,0>:d    {I@4}
        add3 (1|M0)              r7.2<1>:d     r8.0<0;0>:d       r42.3<0;0>:d      r6.1<0>:d        {I@3}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r2.0<1>:f     r9.0<0;1,0>:f                    {Compacted,I@4}
        add3 (1|M0)              r2.1<1>:d     r10.0<0;0>:d      r7.2<0;0>:d       r42.5<0>:d       {I@1}
        shl (1|M0)               r4.4<1>:ud    r42.0<0;1,0>:ud   0x7:uw             
        send.ugm (1|M0)          r15      r2      null:0  0x0            0x0240D780           {A@1,$3} // wr:1+0, rd:4; load.ugm.d64x16t.a64
        or (1|M0)                r1.2<1>:ud    r4.4<0;1,0>:ud    0x40:uw              {I@1}
        add (1|M0)               r79.4<1>:d    r79.4<0;1,0>:d    -r79.5<0;1,0>:d 
        add (1|M0)               r1.3<1>:d     r4.5<0;1,0>:d     r1.2<0;1,0>:d    {I@2}
        add (1|M0)               r1.6<1>:d     r4.5<0;1,0>:d     r1.2<0;1,0>:d   
        asr (1|M0)               r1.7<1>:d     r1.3<0;1,0>:d     31:w               {I@2}
        shl (1|M0)               r42.6<1>:d    r1.6<0;1,0>:d     1:w               {I@2}
        shr (1|M0)               r5.1<1>:ud    r1.6<0;1,0>:ud    0x1F:uw             
        shl (1|M0)               r5.0<1>:d     r1.7<0;1,0>:d     1:w               {Compacted,I@3}
        addc (1|M0)              r8.0<1>:ud    r7.0<0;1,0>:ud    r42.6<0;1,0>:ud  {AccWrEn,I@3}
        shl (1|M0)               r79.4<1>:d    r79.4<0;1,0>:d    1:w              
        shr (1|M0)               r1.3<1>:ud    r42.0<0;1,0>:ud   0x2:uw             
        or (1|M0)                r42.7<1>:d    r5.0<0;1,0>:d     r5.1<0;1,0>:d    {I@4}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        shl (1|M0)               r6.0<1>:ud    r42.0<0;1,0>:ud   0x8:uw             
        sync.nop                             null                             {Compacted,$3.src}
        mov (1|M0)               r2.0<1>:f     r8.0<0;1,0>:f                    {Compacted,I@6}
        add (1|M0)               r1.4<1>:d     r79.4<0;1,0>:d    r1.3<0;1,0>:d    {I@4}
        add3 (1|M0)              r2.1<1>:d     r9.0<0;0>:d       r7.2<0;0>:d       r42.7<0>:d       {I@3}
        shr (1|M0)               r4.6<1>:ud    r11.0<0;1,0>:ud   0x1F:uw             
        shl (1|M0)               r4.5<1>:d     r1.5<0;1,0>:d     1:w              
        shl (1|M0)               r5.0<1>:d     r11.0<0;1,0>:d    1:w               {Compacted}
        add (1|M0)               r43.4<1>:d    r79.4<0;1,0>:d    r1.3<0;1,0>:d   
        asr (1|M0)               r43.5<1>:d    r1.4<0;1,0>:d     31:w               {I@6}
        shl (1|M0)               r44.0<1>:d    r1.2<0;1,0>:d     1:w               {Compacted}
        shl (1|M0)               r7.0<1>:d     r13.0<0;1,0>:d    2:w               {Compacted}
        or (1|M0)                r5.1<1>:d     r4.5<0;1,0>:d     r4.6<0;1,0>:d    {I@6}
        shl (1|M0)               r1.2<1>:ud    r42.0<0;1,0>:ud   0x6:uw             
        shl (1|M0)               r4.2<1>:d     r43.5<0;1,0>:d    8:w               {I@5}
        shl (1|M0)               r4.5<1>:d     r43.4<0;1,0>:d    8:w              
        and (1|M0)               r6.3<1>:ud    r1.2<0;1,0>:ud    0xC0:uw              {I@3}
        shl (1|M0)               r5.2<1>:d     r4.5<0;1,0>:d     1:w               {I@2}
        shl (1|M0)               r44.1<1>:d    r6.3<0;1,0>:d     1:w               {I@2}
        shr (1|M0)               r6.5<1>:ud    r6.3<0;1,0>:ud    0x1F:uw             
        add (1|M0)               r45.0<1>:ud   r4.4<0;1,0>:ud    0x1000:uw             
        or (1|M0)                r44.2<1>:d    r6.5<0;1,0>:d     0:w               {I@2}
        and (1|M0)               r44.4<1>:d    r1.0<0;1,0>:uw    1:w              
        send.slm (1|M0)          null     r6      r15:4   0x0            0x0200D704           {$3} // wr:1+4, rd:0; store.slm.d64x16t.a32
        sync.nop                             null                             {Compacted,F@1}
        sync.nop                             null                             {Compacted,$3.src}
        send.ugm (1|M0)          r15      r2      null:0  0x0            0x0240D780           {$4} // wr:1+0, rd:4; load.ugm.d64x16t.a64
        shl (1|M0)               r2.0<1>:d     r4.3<0;1,0>:d     2:w               {Compacted,$4.src}
        shr (1|M0)               r2.1<1>:ud    r13.0<0;1,0>:ud   0x1E:uw             
        addc (1|M0)              r6.0<1>:ud    r3.0<0;1,0>:ud    r5.0<0;1,0>:ud   {AccWrEn}
        or (1|M0)                r7.1<1>:d     r2.0<0;1,0>:d     r2.1<0;1,0>:d    {I@2}
        shr (1|M0)               r2.0<1>:ud    r43.4<0;1,0>:ud   0x18:uw             
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r43.6<1>:d    r6.0<0;1,0>:d                    {I@4}
        addc (1|M0)              r9.0<1>:ud    r3.4<0;1,0>:ud    r7.0<0;1,0>:ud   {AccWrEn}
        or (1|M0)                r4.6<1>:d     r4.2<0;1,0>:d     r2.0<0;1,0>:d    {I@4}
        add3 (1|M0)              r43.7<1>:d    r8.0<0;0>:d       r3.1<0;0>:d       r5.1<0>:d        {I@4}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        shl (1|M0)               r5.0<1>:d     r4.6<0;1,0>:d     1:w               {Compacted,I@3}
        shr (1|M0)               r5.1<1>:ud    r4.5<0;1,0>:ud    0x1F:uw             
        addc (1|M0)              r6.0<1>:ud    r43.6<0;1,0>:ud   r5.2<0;1,0>:ud   {AccWrEn}
        or (1|M0)                r5.3<1>:d     r5.0<0;1,0>:d     r5.1<0;1,0>:d    {I@2}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r2.0<1>:ud    r6.0<0;1,0>:ud    r44.1<0;1,0>:ud  {AccWrEn,I@3}
        add3 (1|M0)              r6.2<1>:d     r7.0<0;0>:d       r43.7<0;0>:d      r5.3<0>:d        {I@2}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r43.2<1>:d    r9.0<0;1,0>:d                   
        mov (1|M0)               r9.0<1>:f     r2.0<0;1,0>:f                    {Compacted,A@1}
        add3 (1|M0)              r9.1<1>:d     r8.0<0;0>:d       r6.2<0;0>:d       r44.2<0>:d      
        add3 (1|M0)              r43.3<1>:d    r10.0<0;0>:d      r3.5<0;0>:d       r7.1<0>:d       
        send.ugm (1|M0)          r10      r9      null:0  0x0            0x0240D780           {A@1,$5} // wr:1+0, rd:4; load.ugm.d64x16t.a64
        send.slm (1|M0)          null     r44     r15:4   0x0            0x0200D704           {$4} // wr:1+4, rd:0; store.slm.d64x16t.a32
        send.slm (1|M0)          null     r45     r10:4   0x0            0x0200D704           {$5} // wr:1+4, rd:0; store.slm.d64x16t.a32
(W)     send.slm (1|M0)          r5       r0      null:0  0x0            0x0210001F           {$6} // wr:1+0, rd:1; fence.slm.none.group
(W)     mov (1|M0)               r7.2<1>:f     0.0:f                               {Compacted}
(W)     mov (2|M0)               r7.10<1>:ub   r0.11<0;1,0>:ub                  {F@1}
(W)     mov (8|M0)               null<1>:ud    r5.0<1;1,0>:ud                   {$6.dst}
(W)     send.gtwy (1|M0)         null     r7      null:0  0x0            0x02000004           {A@2,$7} // wr:1+0, rd:0; signal barrier
(W)     sync.bar                             null                            
        cmp (1|M0)    (gt)f1.1   null<1>:d     r4.0<0;1,0>:d     0:w              
        shl (1|M0)               r44.3<1>:d    r44.3<0;1,0>:d    9:w               {Compacted,$4.src}
        shl (1|M0)               r44.4<1>:d    r44.4<0;1,0>:d    9:w              
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
(~f1.1.any16h) goto (16|M0)                  L4512                  L4512                
L2736:
        addc (1|M0)              r2.0<1>:ud    r43.6<0;1,0>:ud   r44.1<0;1,0>:ud  {AccWrEn}
        mov (1|M0)               r44.5<1>:d    r4.0<0;1,0>:d                   
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r6.0<1>:ud    r42.2<0;1,0>:ud   r42.4<0;1,0>:ud  {AccWrEn}
        mov (1|M0)               r44.6<1>:d    0:w                              
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$7.src}
        addc (1|M0)              r8.0<1>:ud    r42.2<0;1,0>:ud   r42.6<0;1,0>:ud  {AccWrEn}
        mov (1|M0)               r45.5<1>:d    r4.1<0;1,0>:d                    {$5.src}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        asr (1|M0)               r45.6<1>:d    r4.1<0;1,0>:d     31:w              
        mov (1|M0)               r46.2<2>:f    0.0:f                              
        mov (1|M0)               r46.3<2>:f    0.0:f                              
        mov (1|M0)               r46.0<1>:f    r2.0<0;1,0>:f                    {Compacted,I@7}
        add3 (1|M0)              r46.1<1>:d    r5.0<0;0>:d       r43.7<0;0>:d      r44.2<0>:d       {I@7}
        mov (1|M0)               r45.1<1>:d    r6.0<0;1,0>:d                    {I@7}
        add3 (1|M0)              r45.2<1>:d    r7.0<0;0>:d       r42.3<0;0>:d      r42.5<0>:d       {I@7}
        mov (1|M0)               r45.3<1>:d    r8.0<0;1,0>:d                    {I@7}
        add3 (1|M0)              r45.4<1>:d    r9.0<0;0>:d       r42.3<0;0>:d      r42.7<0>:d       {I@6}
L2992:
        addc (1|M0)              r2.0<1>:ud    r46.2<0;1,0>:ud   0x1:ud              {AccWrEn,A@1}
(W)     mov (1|M0)               r1.3<1>:hf    0x1:hf                             
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r46.4<1>:d    r2.0<0;1,0>:d                    {I@2}
        add3 (1|M0)              r46.5<1>:d    r5.0<0;0>:d       r46.3<0;0>:d      0:w               {I@2}
        cmp (1|M0)    (lt)f1.0   null<1>:ud    r46.4<0;1,0>:ud   r44.5<0;1,0>:ud  {I@2}
        cmp (1|M0)    (eq)f0.0   null<1>:d     r46.5<0;1,0>:d    r44.6<0;1,0>:d   {I@2}
        cmp (1|M0)    (lt)f1.1   null<1>:ud    r46.5<0;1,0>:ud   r44.6<0;1,0>:ud 
        and (1|M0)               r44.7<1>:d    r46.2<0;1,0>:d    1:w              
(f1.0)  sel (1|M0)               r1.5<1>:uw    r1.3<0;1,0>:uw    0x0:uw              {F@1}
(f0.0)  sel (1|M0)               r1.4<1>:uw    r1.3<0;1,0>:uw    0x0:uw             
(f1.1)  sel (1|M0)               r4.5<1>:uw    r1.3<0;1,0>:uw    0x0:uw             
        and (1|M0)    (ne)f1.0   null<1>:uw    r1.4<0;1,0>:uw    r1.5<0;1,0>:uw   {I@2}
(f1.0)  sel (1|M0)               r4.4<1>:uw    r1.3<0;1,0>:uw    0x0:uw             
        or (1|M0)     (ne)f0.1   null<1>:uw    r4.4<0;1,0>:uw    r4.5<0;1,0>:uw   {I@1}
(W)     and (1|M0)               f1.0<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(~f1.0.any16h) goto (16|M0)                  L4008                  L4008                
L3256:
        addc (1|M0)              r2.0<1>:ud    r46.4<0;1,0>:ud   r43.0<0;1,0>:ud  {AccWrEn}
        xor (1|M0)               r1.2<1>:d     r44.7<0;1,0>:d    1:w              
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        shr (1|M0)               r4.2<1>:ud    r2.0<0;1,0>:ud    0x18:uw              {I@3}
        add3 (1|M0)              r1.5<1>:d     r5.0<0;0>:d       r46.5<0;0>:d      r43.1<0>:d       {I@2}
        shl (1|M0)               r4.3<1>:d     r2.0<0;1,0>:d     8:w               {Compacted}
        shl (1|M0)               r2.1<1>:d     r1.5<0;1,0>:d     8:w               {I@2}
        sync.nop                             null                             {Compacted,$9.src}
        shl (1|M0)               r6.2<1>:d     r4.3<0;1,0>:d     1:w               {I@2}
        or (1|M0)                r4.4<1>:d     r2.1<0;1,0>:d     r4.2<0;1,0>:d    {I@2}
        shr (1|M0)               r6.1<1>:ud    r4.3<0;1,0>:ud    0x1F:uw             
        addc (1|M0)              r7.0<1>:ud    r45.1<0;1,0>:ud   r6.2<0;1,0>:ud   {AccWrEn,I@3}
        shl (1|M0)               r6.0<1>:d     r4.4<0;1,0>:d     1:w               {Compacted,I@3}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        or (1|M0)                r6.3<1>:d     r6.0<0;1,0>:d     r6.1<0;1,0>:d    {I@2}
        mov (1|M0)               r9.0<1>:f     r7.0<0;1,0>:f                    {Compacted}
        add3 (1|M0)              r9.1<1>:d     r8.0<0;0>:d       r45.2<0;0>:d      r6.3<0>:d        {I@1}
        addc (1|M0)              r2.0<1>:ud    r45.3<0;1,0>:ud   r6.2<0;1,0>:ud   {AccWrEn}
        send.ugm (1|M0)          r10      r9      null:0  0x0            0x0240D780           {A@1,$10} // wr:1+0, rd:4; load.ugm.d64x16t.a64
        mov (1|M0)               r14.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r15.0<1>:f    r2.0<0;1,0>:f                    {Compacted,I@2}
        add3 (1|M0)              r15.1<1>:d    r14.0<0;0>:d      r45.4<0;0>:d      r6.3<0>:d        {I@1}
        shl (1|M0)               r1.3<1>:d     r1.2<0;1,0>:d     11:w              
        send.ugm (1|M0)          r16      r15     null:0  0x0            0x0240D780           {A@1,$11} // wr:1+0, rd:4; load.ugm.d64x16t.a64
        mul (1|M0)               acc0.0<1>:ud  r46.4<0;1,0>:ud   r45.10<0;1,0>:uw
        mach (1|M0)              r21.0<1>:ud   r46.4<0;1,0>:ud   r45.5<0;1,0>:ud  {AccWrEn}
        mad (1|M0)               r5.0<1>:d     r1.3<0;0>:d       r1.0<0;0>:uw      256:w               {I@3}
        mov (1|M0)               r20.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r46.4<0;1,0>:d    r45.12<0;1,0>:uw
        add (1|M0)               r7.0<1>:d     r1.3<0;1,0>:d     r44.0<0;1,0>:d   {Compacted}
        shl (1|M0)               r1.2<1>:d     r1.2<0;1,0>:d     10:w              
        send.slm (1|M0)          null     r5      r10:4   0x0            0x0200D704           {A@5,$10} // wr:1+4, rd:0; store.slm.d64x16t.a32
        mach (1|M0)              r5.0<1>:d     r46.4<0;1,0>:d    r45.6<0;1,0>:d   {$10.src}
(W)     mul (1|M0)               acc0.0<1>:d   r46.5<0;1,0>:d    r45.10<0;1,0>:uw
        mach (1|M0)              r2.0<1>:d     r46.5<0;1,0>:d    r45.5<0;1,0>:d  
        addc (1|M0)              r6.0<1>:ud    r20.0<0;1,0>:ud   r43.4<0;1,0>:ud  {AccWrEn,I@7}
        add3 (1|M0)              r4.3<1>:d     r2.0<0;0>:d       r21.0<0;0>:d      r5.0<0>:d        {I@2}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        send.slm (1|M0)          null     r7      r16:4   0x0            0x0200D704           {$11} // wr:1+4, rd:0; store.slm.d64x16t.a32
        add3 (1|M0)              r1.4<1>:d     r8.0<0;0>:d       r4.3<0;0>:d       r43.5<0>:d       {I@1}
        shr (1|M0)               r6.2<1>:ud    r6.0<0;1,0>:ud    0x18:uw             
        shl (1|M0)               r7.0<1>:d     r6.0<0;1,0>:d     8:w               {Compacted,$11.src}
        shl (1|M0)               r6.1<1>:d     r1.4<0;1,0>:d     8:w               {I@3}
        shl (1|M0)               r9.0<1>:d     r7.0<0;1,0>:d     1:w               {Compacted,I@2}
        or (1|M0)                r7.1<1>:d     r6.1<0;1,0>:d     r6.2<0;1,0>:d    {I@2}
        shr (1|M0)               r7.3<1>:ud    r7.0<0;1,0>:ud    0x1F:uw             
        addc (1|M0)              r2.0<1>:ud    r46.0<0;1,0>:ud   r9.0<0;1,0>:ud   {AccWrEn,I@3}
        shl (1|M0)               r7.2<1>:d     r7.1<0;1,0>:d     1:w               {I@3}
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        or (1|M0)                r9.1<1>:d     r7.2<0;1,0>:d     r7.3<0;1,0>:d    {I@2}
        mov (1|M0)               r10.0<1>:f    r2.0<0;1,0>:f                    {Compacted}
        add3 (1|M0)              r10.1<1>:d    r5.0<0;0>:d       r46.1<0;0>:d      r9.1<0>:d        {I@1}
        add (1|M0)               r6.0<1>:d     r1.2<0;1,0>:d     r45.0<0;1,0>:d   {Compacted}
        send.ugm (1|M0)          r11      r10     null:0  0x0            0x0240D780           {A@1,$12} // wr:1+0, rd:4; load.ugm.d64x16t.a64
        send.slm (1|M0)          null     r6      r11:4   0x0            0x0200D704           {A@1,$12} // wr:1+4, rd:0; store.slm.d64x16t.a32
L4008:
        join (16|M0)                         L4512                                
L4024:
        shl (1|M0)               r1.2<1>:d     r44.7<0;1,0>:d    11:w              
        shl (1|M0)               r44.7<1>:d    r44.7<0;1,0>:d    10:w              
        add (1|M0)               r2.0<1>:d     r1.2<0;1,0>:d     r44.3<0;1,0>:d   {I@2}
        bfn.0xFE (1|M0)          r5.0<1>:ud    0x1000:uw               r44.7<0;0>:ud     r44.4<0>:ud      {I@2} // s0|s1|s2
        bfn.0xFE (1|M0)          r31.0<1>:ud   0x1100:uw               r44.7<0;0>:ud     r44.4<0>:ud      // s0|s1|s2
        sync.nop                             null                             {Compacted,$12.src}
        or (1|M0)                r14.0<1>:ud   r2.0<0;1,0>:ud    0x100:uw              {I@3}
        sync.nop                             null                             {Compacted,$9.src}
        send.slm (1|M0)          r6       r2      null:0  0x0            0x0280E700           {$13} // wr:1+0, rd:8; load.slm.d64x32t.a32
        send.slm (1|M0)          r23      r5      null:0  0x0            0x0280E700           {A@3,$14} // wr:1+0, rd:8; load.slm.d64x32t.a32
        send.slm (1|M0)          r32      r31     null:0  0x0            0x0280E700           {A@2,$15} // wr:1+0, rd:8; load.slm.d64x32t.a32
        send.slm (1|M0)          r15      r14     null:0  0x0            0x0280E700           {A@1,$0} // wr:1+0, rd:8; load.slm.d64x32t.a32
        sync.allwr                           ($0,$9,$13,$14,$15)                
        dpas.8x8 (8|M0)          r71:f         r71:f             r23:hf            r6.0:hf          {Atomic}
        dpas.8x8 (8|M0)          r63:f         r63:f             r32:hf            r6.0:hf          {Atomic}
        dpas.8x8 (8|M0)          r55:f         r55:f             r23:hf            r15.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r47:f         r47:f             r32:hf            r15.0:hf         {$9}
(W)     send.slm (1|M0)          r40      r0      null:0  0x0            0x0210001F           {$1} // wr:1+0, rd:1; fence.slm.none.group
(W)     mov (1|M0)               r41.2<1>:f    0.0:f                               {Compacted,$8.src}
(W)     mov (2|M0)               r41.10<1>:ub  r0.11<0;1,0>:ub                  {F@1}
(W)     mov (8|M0)               null<1>:ud    r40.0<1;1,0>:ud                  {$1.dst}
(W)     send.gtwy (1|M0)         null     r41     null:0  0x0            0x02000004           {A@2,$8} // wr:1+0, rd:0; signal barrier
(W)     sync.bar                             null                            
        cmp (1|M0)    (eq)f0.1   null<1>:d     r46.4<0;1,0>:d    r44.5<0;1,0>:d  
(W)     mov (1|M0)               r1.3<1>:hf    0x1:hf                             
(f0.0)  sel (1|M0)               r2.0<1>:uw    r1.3<0;1,0>:uw    0x0:uw              {F@1}
(f0.1)  sel (1|M0)               r1.4<1>:uw    r1.3<0;1,0>:uw    0x0:uw             
        and (1|M0)    (ne)f0.0   null<1>:uw    r1.4<0;1,0>:uw    r2.0<0;1,0>:uw   {I@1}
(W)     and (1|M0)               f0.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
(f0.1.any16h) goto (16|M0)                   L4512                  L4512                
L4480:
(W)     mov (2|M0)               r46.2<1>:ud   r46.4<1;1,0>:ud                 
        goto.b (16|M0)                       L4512                  L2992                
L4512:
        join (16|M0)                         L4528                                
L4528:
        shl (1|M0)               r45.7<1>:d    r45.7<0;1,0>:d    4:w               {$5.src}
        bfn.0xEA (1|M0)          r79.4<1>:ud   r79.4<0;0>:ud     r42.0<0;0>:ud     0x1:uw              // s0|s1&s2
        mul (1|M0)               acc0.0<1>:d   r45.7<0;1,0>:d    r2.6<0;1,0>:uw   {I@2}
        sync.nop                             null                             {Compacted,$9.src}
        mach (1|M0)              r6.0<1>:d     r45.7<0;1,0>:d    r2.3<0;1,0>:d    {AccWrEn,$12.src}
        shl (1|M0)               r4.4<1>:ud    r79.4<0;1,0>:ud   0x4:uw              {I@3}
        mov (1|M0)               r5.0<1>:d     acc0.0<0;1,0>:d                 
        shl (1|M0)               r8.0<1>:d     r4.4<0;1,0>:d     2:w               {Compacted,I@2}
        shl (1|M0)               r1.6<1>:d     r5.0<0;1,0>:d     2:w               {Compacted,I@2}
        shl (1|M0)               r1.4<1>:d     r6.0<0;1,0>:d     2:w               {Compacted}
        addc (1|M0)              r2.0<1>:ud    r43.2<0;1,0>:ud   r1.6<0;1,0>:ud   {AccWrEn,I@2}
        shr (1|M0)               r1.5<1>:ud    r5.0<0;1,0>:ud    0x1E:uw             
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$7.src}
        addc (1|M0)              r9.0<1>:ud    r2.0<0;1,0>:ud    r8.0<0;1,0>:ud   {AccWrEn,I@3}
        shr (1|M0)               r2.1<1>:ud    r4.4<0;1,0>:ud    0x1E:uw             
        shl (1|M0)               r1.6<1>:d     r2.3<0;1,0>:d     3:w              
        or (1|M0)                r1.7<1>:d     r1.4<0;1,0>:d     r1.5<0;1,0>:d    {I@5}
        mov (1|M0)               r5.0<1>:f     r9.0<0;1,0>:f                    {Compacted,I@4}
        asr (1|M0)               r1.3<1>:d     r2.3<0;1,0>:d     31:w               {Compacted}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        or (1|M0)                r8.1<1>:d     r2.1<0;1,0>:d     0:w               {Compacted,I@5}
        shl (1|M0)               r4.2<1>:d     r1.6<0;1,0>:d     2:w               {I@5}
        add3 (1|M0)              r4.3<1>:d     r7.0<0;0>:d       r43.3<0;0>:d      r1.7<0>:d        {I@5}
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
        send.ugm (1|M0)          null     r5      r71:1   0x0            0x0200C584           {$9} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        mov (1|M0)               r8.0<1>:f     r2.0<0;1,0>:f                    {Compacted,I@1}
        send.ugm (1|M0)          null     r11     r63:1   0x0            0x0200C584           {$2} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        add3 (1|M0)              r7.1<1>:d     r6.0<0;0>:d       r5.1<0;0>:d       r4.3<0>:d       
        mov (1|M0)               r11.0<1>:f    r9.0<0;1,0>:f                    {Compacted,$2.src}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r9.0<1>:ud    r8.0<0;1,0>:ud    0x20:ud              {AccWrEn,A@1}
        send.ugm (1|M0)          null     r7      r55:1   0x0            0x0200C584           {A@3,$3} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$3.src}
        mul (1|M0)               acc0.0<1>:d   r2.3<0;1,0>:d     0x9:uw             
        add3 (1|M0)              r11.1<1>:d    r10.0<0;0>:d      r7.1<0;0>:d       0:w              
        mach (1|M0)              r12.0<1>:d    r2.3<0;1,0>:d     9:d               {AccWrEn}
        send.ugm (1|M0)          null     r11     r47:1   0x0            0x0200C584           {A@2,$4} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        shl (1|M0)               r1.4<1>:d     r1.3<0;1,0>:d     2:w              
        shr (1|M0)               r1.5<1>:ud    r2.3<0;1,0>:ud    0x1E:uw             
        mov (1|M0)               r11.0<1>:d    acc0.0<0;1,0>:d                  {$4.src}
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
        sync.nop                             null                             {Compacted,$9.src}
        shl (1|M0)               r5.3<1>:d     r4.4<0;1,0>:d     2:w               {I@5}
        or (1|M0)                r2.1<1>:d     r1.4<0;1,0>:d     r1.5<0;1,0>:d    {I@4}
        addc (1|M0)              r7.0<1>:ud    r9.0<0;1,0>:ud    0x20:ud              {AccWrEn,F@1}
        send.ugm (1|M0)          null     r8      r72:1   0x0            0x0200C584           {$5} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        add3 (1|M0)              r9.1<1>:d     r13.0<0;0>:d      r5.1<0;0>:d       r2.1<0>:d        {I@2}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$5.src}
        addc (1|M0)              r6.0<1>:ud    r5.0<0;1,0>:ud    r5.3<0;1,0>:ud   {AccWrEn}
        send.ugm (1|M0)          null     r10     r64:1   0x0            0x0200C584           {$6} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        sync.nop                             null                             {Compacted,$6.src}
        add3 (1|M0)              r10.1<1>:d    r8.0<0;0>:d       r9.1<0;0>:d       0:w               {I@2}
        mov (1|M0)               r8.0<1>:f     r6.0<0;1,0>:f                    {Compacted,A@1}
        send.ugm (1|M0)          null     r9      r56:1   0x0            0x0200C584           {$7} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        mov (1|M0)               r10.0<1>:f    r7.0<0;1,0>:f                    {Compacted}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,F@1}
        addc (1|M0)              r9.0<1>:ud    r8.0<0;1,0>:ud    0x20:ud              {AccWrEn,$7.src}
        send.ugm (1|M0)          null     r10     r48:1   0x0            0x0200C584           {$8} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,$8.src}
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
        send.ugm (1|M0)          null     r8      r73:1   0x0            0x0200C584           {$10} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        sync.nop                             null                             {Compacted,$10.src}
        addc (1|M0)              r8.0<1>:ud    r7.0<0;1,0>:ud    0x20:ud              {AccWrEn,F@1}
        mov (1|M0)               r11.0<1>:f    r9.0<0;1,0>:f                    {Compacted}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,F@1}
        mul (1|M0)               acc0.0<1>:d   r2.3<0;1,0>:d     0x3:uw             
        shr (1|M0)               r1.3<1>:ud    r12.0<0;1,0>:ud   0x1E:uw             
        add3 (1|M0)              r11.1<1>:d    r10.0<0;0>:d      r8.1<0;0>:d       0:w              
        mach (1|M0)              r12.0<1>:d    r2.3<0;1,0>:d     3:d               {AccWrEn}
        send.ugm (1|M0)          null     r11     r65:1   0x0            0x0200C584           {A@2,$11} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        shl (1|M0)               r1.2<1>:d     r13.0<0;1,0>:d    2:w               {Compacted}
        mov (1|M0)               r11.0<1>:d    acc0.0<0;1,0>:d                  {$11.src}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        shl (1|M0)               r1.2<1>:d     r11.0<0;1,0>:d    2:w               {Compacted,I@2}
        add3 (1|M0)              r7.1<1>:d     r6.0<0;0>:d       r5.1<0;0>:d       r1.5<0>:d        {I@2}
        addc (1|M0)              r6.0<1>:ud    r5.0<0;1,0>:ud    r1.2<0;1,0>:ud   {AccWrEn,I@2}
        mov (1|M0)               r10.0<1>:f    r8.0<0;1,0>:f                    {Compacted}
        mov (1|M0)               r8.0<1>:f     r6.0<0;1,0>:f                    {Compacted,I@1}
        send.ugm (1|M0)          null     r7      r57:1   0x0            0x0200C584           {$12} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        mov (1|M0)               r13.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        sync.nop                             null                             {Compacted,$12.src}
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
        send.ugm (1|M0)          null     r10     r49:1   0x0            0x0200C584           {$13} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        addc (1|M0)              r6.0<1>:ud    r5.0<0;1,0>:ud    r1.2<0;1,0>:ud   {AccWrEn,I@1}
        add3 (1|M0)              r8.1<1>:d     r13.0<0;0>:d      r5.1<0;0>:d       r1.3<0>:d       
        mov (1|M0)               r10.0<1>:f    r7.0<0;1,0>:f                    {Compacted,$13.src}
        mov (1|M0)               r7.0<1>:f     r6.0<0;1,0>:f                    {Compacted,I@2}
        sync.nop                             null                             {Compacted,I@1}
        send.ugm (1|M0)          null     r8      r74:1   0x0            0x0200C584           {$14} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        shl (1|M0)               r4.3<1>:d     r1.6<0;1,0>:d     2:w              
        mov (1|M0)               r13.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        sync.nop                             null                             {Compacted,$14.src}
        addc (1|M0)              r8.0<1>:ud    r7.0<0;1,0>:ud    0x20:ud              {AccWrEn,F@1}
        shl (1|M0)               r2.0<1>:d     r12.0<0;1,0>:d    2:w               {Compacted}
        shr (1|M0)               r2.1<1>:ud    r11.0<0;1,0>:ud   0x1E:uw             
        add3 (1|M0)              r10.1<1>:d    r9.0<0;0>:d       r8.1<0;0>:d       0:w              
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r6.0<1>:ud    r5.0<0;1,0>:ud    r4.3<0;1,0>:ud   {AccWrEn,I@7}
        or (1|M0)                r1.3<1>:d     r2.0<0;1,0>:d     r2.1<0;1,0>:d    {I@4}
        mov (1|M0)               r12.0<1>:f    r6.0<0;1,0>:f                    {Compacted,I@2}
        send.ugm (1|M0)          null     r10     r66:1   0x0            0x0200C584           {$15} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        add3 (1|M0)              r7.1<1>:d     r13.0<0;0>:d      r5.1<0;0>:d       r1.3<0>:d        {I@2}
        mov (1|M0)               r10.0<1>:f    r8.0<0;1,0>:f                    {Compacted,$15.src}
        addc (1|M0)              r8.0<1>:ud    r12.0<0;1,0>:ud   0x20:ud              {AccWrEn,A@1}
        send.ugm (1|M0)          null     r7      r58:1   0x0            0x0200C584           {A@2,$0} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$0.src}
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
        send.ugm (1|M0)          null     r10     r50:1   0x0            0x0200C584           {$1} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r12     r75:1   0x0            0x0200C584           {$2} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r9      r67:1   0x0            0x0200C584           {A@2,$3} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$3.src}
        mul (1|M0)               acc0.0<1>:d   r2.3<0;1,0>:d     0x5:uw             
        mach (1|M0)              r12.0<1>:d    r2.3<0;1,0>:d     5:d               {AccWrEn,$2.src}
        shl (1|M0)               r1.2<1>:d     r14.0<0;1,0>:d    2:w               {Compacted}
        shr (1|M0)               r1.3<1>:ud    r13.0<0;1,0>:ud   0x1E:uw             
        mov (1|M0)               r11.0<1>:d    acc0.0<0;1,0>:d                 
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        shl (1|M0)               r1.2<1>:d     r11.0<0;1,0>:d    2:w               {Compacted,I@2}
        add3 (1|M0)              r8.1<1>:d     r6.0<0;0>:d       r5.1<0;0>:d       r1.5<0>:d        {I@2}
        addc (1|M0)              r6.0<1>:ud    r5.0<0;1,0>:ud    r1.2<0;1,0>:ud   {AccWrEn,I@2}
        mov (1|M0)               r10.0<1>:f    r7.0<0;1,0>:f                    {Compacted,$1.src}
        mov (1|M0)               r7.0<1>:f     r6.0<0;1,0>:f                    {Compacted,I@1}
        send.ugm (1|M0)          null     r8      r59:1   0x0            0x0200C584           {$4} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        mov (1|M0)               r13.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        sync.nop                             null                             {Compacted,$4.src}
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
        send.ugm (1|M0)          null     r10     r51:1   0x0            0x0200C584           {$5} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        addc (1|M0)              r6.0<1>:ud    r5.0<0;1,0>:ud    r1.2<0;1,0>:ud   {AccWrEn,I@1}
        add3 (1|M0)              r7.1<1>:d     r13.0<0;0>:d      r5.1<0;0>:d       r1.3<0>:d       
        mov (1|M0)               r10.0<1>:f    r8.0<0;1,0>:f                    {Compacted,$5.src}
        mov (1|M0)               r8.0<1>:f     r6.0<0;1,0>:f                    {Compacted,I@2}
        sync.nop                             null                             {Compacted,I@1}
        send.ugm (1|M0)          null     r7      r76:1   0x0            0x0200C584           {$6} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        mov (1|M0)               r13.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        sync.nop                             null                             {Compacted,$6.src}
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
        send.ugm (1|M0)          null     r10     r68:1   0x0            0x0200C584           {$7} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        addc (1|M0)              r6.0<1>:ud    r5.0<0;1,0>:ud    r1.2<0;1,0>:ud   {AccWrEn,I@1}
        add3 (1|M0)              r8.1<1>:d     r13.0<0;0>:d      r5.1<0;0>:d       r1.3<0>:d       
        mov (1|M0)               r10.0<1>:f    r7.0<0;1,0>:f                    {Compacted,$7.src}
        mov (1|M0)               r7.0<1>:f     r6.0<0;1,0>:f                    {Compacted,I@2}
        sync.nop                             null                             {Compacted,I@1}
        send.ugm (1|M0)          null     r8      r60:1   0x0            0x0200C584           {$8} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        mov (1|M0)               r13.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        sync.nop                             null                             {Compacted,$8.src}
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
        send.ugm (1|M0)          null     r10     r52:1   0x0            0x0200C584           {$9} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        addc (1|M0)              r6.0<1>:ud    r5.0<0;1,0>:ud    r1.2<0;1,0>:ud   {AccWrEn,I@1}
        add3 (1|M0)              r7.1<1>:d     r13.0<0;0>:d      r5.1<0;0>:d       r1.3<0>:d       
        mov (1|M0)               r10.0<1>:f    r8.0<0;1,0>:f                    {Compacted,$9.src}
        mov (1|M0)               r8.0<1>:f     r6.0<0;1,0>:f                    {Compacted,I@2}
        sync.nop                             null                             {Compacted,I@1}
        send.ugm (1|M0)          null     r7      r77:1   0x0            0x0200C584           {$10} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        mov (1|M0)               r13.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        sync.nop                             null                             {Compacted,$10.src}
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
        send.ugm (1|M0)          null     r10     r69:1   0x0            0x0200C584           {$11} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        addc (1|M0)              r6.0<1>:ud    r5.0<0;1,0>:ud    r1.2<0;1,0>:ud   {AccWrEn,I@1}
        add3 (1|M0)              r8.1<1>:d     r13.0<0;0>:d      r5.1<0;0>:d       r1.3<0>:d       
        mov (1|M0)               r10.0<1>:f    r7.0<0;1,0>:f                    {Compacted,$11.src}
        mov (1|M0)               r7.0<1>:f     r6.0<0;1,0>:f                    {Compacted,I@2}
        sync.nop                             null                             {Compacted,I@1}
        send.ugm (1|M0)          null     r8      r61:1   0x0            0x0200C584           {$12} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        mov (1|M0)               r13.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        sync.nop                             null                             {Compacted,$12.src}
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
        send.ugm (1|M0)          null     r10     r53:1   0x0            0x0200C584           {$13} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        addc (1|M0)              r6.0<1>:ud    r5.0<0;1,0>:ud    r1.2<0;1,0>:ud   {AccWrEn,I@1}
        shl (1|M0)               r2.0<1>:d     r12.0<0;1,0>:d    2:w               {Compacted}
        shr (1|M0)               r2.1<1>:ud    r11.0<0;1,0>:ud   0x1E:uw             
        add3 (1|M0)              r7.1<1>:d     r13.0<0;0>:d      r5.1<0;0>:d       r1.3<0>:d       
        mov (1|M0)               r10.0<1>:f    r8.0<0;1,0>:f                    {Compacted,$13.src}
        mov (1|M0)               r8.0<1>:f     r6.0<0;1,0>:f                    {Compacted,I@4}
        sync.nop                             null                             {Compacted,I@1}
        send.ugm (1|M0)          null     r7      r78:1   0x0            0x0200C584           {$14} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        or (1|M0)                r1.3<1>:d     r2.0<0;1,0>:d     r2.1<0;1,0>:d   
        mov (1|M0)               r13.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        sync.nop                             null                             {Compacted,$14.src}
        addc (1|M0)              r7.0<1>:ud    r8.0<0;1,0>:ud    0x20:ud              {AccWrEn,F@1}
        add3 (1|M0)              r10.1<1>:d    r9.0<0;0>:d       r7.1<0;0>:d       0:w              
        add3 (1|M0)              r8.1<1>:d     r13.0<0;0>:d      r5.1<0;0>:d       r1.3<0>:d        {I@3}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        send.ugm (1|M0)          null     r10     r70:1   0x0            0x0200C584           {A@3,$15} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        mov (1|M0)               r10.0<1>:f    r7.0<0;1,0>:f                    {Compacted,$15.src}
        add3 (1|M0)              r10.1<1>:d    r9.0<0;0>:d       r8.1<0;0>:d       0:w               {I@1}
        send.ugm (1|M0)          null     r8      r62:1   0x0            0x0200C584           {$0} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r10     r54:1   0x0            0x0200C584           {A@1,$1} // wr:1+1, rd:0; store.ugm.d32x8t.a64
(W)     mov (8|M0)               r127.0<1>:f   r0.0<1;1,0>:f                    {Compacted}
(W)     send.ugm (1|M0)          r11      r0      null:0  0x0            0x0210641F           {$2} // wr:1+0, rd:1; fence invalid flush type scoped to tile
(W)     mov (8|M0)               null<1>:ud    r11.0<1;1,0>:ud                  {$2.dst}
(W)     send.gtwy (1|M0)         null     r127    null:0  0x0            0x02000010           {EOT,A@1} // wr:1+0, rd:0; end of thread
L8432:
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
        cmp (1|M0)    (ge)f0.0   null<1>:ud    r1.3<0;1,0>:ud    r1.4<0;1,0>:ud   {I@1}
(f0.0)  sel (1|M0)               r6.0<1>:d     r4.4<0;1,0>:w     0:w              
        add3 (1|M0)              r7.0<1>:d     r7.0<0;0>:d       r79.1<0;0>:d      r6.0<0>:d        {I@1}
        xor (1|M0)               r45.7<1>:d    r7.0<0;1,0>:d     r79.1<0;1,0>:d   {I@1}
        mov (1|M0)               cr0.0<1>:ud   r1.2<0;1,0>:d                    {A@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        ret (16|M0)                          r46.6                            {A@1}
L8984:
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
