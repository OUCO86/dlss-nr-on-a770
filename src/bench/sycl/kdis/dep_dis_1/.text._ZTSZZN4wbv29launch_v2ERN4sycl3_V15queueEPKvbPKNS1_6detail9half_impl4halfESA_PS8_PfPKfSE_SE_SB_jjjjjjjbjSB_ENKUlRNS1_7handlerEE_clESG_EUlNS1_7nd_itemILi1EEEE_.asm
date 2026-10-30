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
(W)     mov (2|M0)               r94.0<1>:ud   r4.2<1;1,0>:ud                   {$1.dst}
        and (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   -1265:w               {A@1}
        or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   1216:w               {A@1}
        mov (1|M0)               r122.6<1>:d   r0.1<0;1,0>:ud                   {A@1}
        and (1|M0)               r3.3<1>:d     r2.6<0;1,0>:d     -2:w              
        mul (1|M0)               acc0.0<1>:ud  r122.6<0;1,0>:ud  0xD800:uw              {I@2}
        mach (1|M0)              r7.0<1>:ud    r122.6<0;1,0>:ud  0xD800:ud              {AccWrEn}
        cmp (1|M0)    (eq)f1.1   null<1>:d     r3.3<0;1,0>:d     0xFFFE:uw              {I@3}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        sync.nop                             null                             {Compacted,$0.dst}
        shl (1|M0)               r1.2<1>:d     r7.0<0;1,0>:d     1:w               {Compacted,I@3}
        shl (1|M0)               r1.4<1>:d     r6.0<0;1,0>:d     1:w               {Compacted,I@2}
        shr (1|M0)               r1.3<1>:ud    r6.0<0;1,0>:ud    0x1F:uw             
(W)     and (1|M0)               f1.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
        addc (1|M0)              r2.0<1>:ud    r2.2<0;1,0>:ud    r1.4<0;1,0>:ud   {AccWrEn,I@3}
        mov (1|M0)               r110.0<1>:d   r1.0<0;1,0>:uw                  
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@4}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        and (1|M0)               r122.10<2>:b  r3.8<0;1,0>:b     1:w              
        and (1|M0)               r122.8<2>:b   r5.12<0;1,0>:b    1:w              
        mov (1|M0)               r122.4<1>:d   r0.1<0;1,0>:ud                  
        mov (1|M0)               r122.5<1>:d   0:w                              
        mov (1|M0)               r94.2<1>:d    r1.0<0;1,0>:uw                  
        mov (1|M0)               r94.3<1>:d    0:w                              
        mov (1|M0)               r122.0<1>:f   r2.0<0;1,0>:f                    {Compacted,I@7}
        shr (1|M0)               r122.3<1>:ud  r110.0<0;1,0>:ud  0x4:uw              {I@7}
        add3 (1|M0)              r122.1<1>:d   r8.0<0;0>:d       r2.3<0;0>:d       r1.5<0>:d        {I@7}
(f1.1.any16h) goto (16|M0)                   L42064                  L42064                
L576:
        mov (1|M0)               r110.5<1>:d   r122.6<0;1,0>:d                 
        mov (1|M0)               r94.6<1>:d    r2.7<0;1,0>:d                   
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r94.4         L42136                                 {A@1}
L656:
        shl (1|M0)               r122.7<1>:d   r6.0<0;1,0>:d     3:w               {Compacted}
        shr (1|M0)               r94.6<1>:ud   r110.0<0;1,0>:ud  0x3:uw             
(W)     mul (1|M0)               acc0.0<1>:d   r6.0<0;1,0>:d     r2.14<0;1,0>:uw  {Compacted}
        add3 (1|M0)              r122.7<1>:ud  r122.7<0;0>:ud    r94.6<0;0>:ud     -r2.4<0>:ud      {I@2}
        mach (1|M0)              r6.0<1>:d     r6.0<0;1,0>:d     r2.7<0;1,0>:d    {Compacted}
        cmp (1|M0)    (gt)f0.0   null<1>:d     r122.7<0;1,0>:d   -1:w               {I@2}
        add (1|M0)               r122.6<1>:d   r122.6<0;1,0>:d   -r6.0<0;1,0>:d   {I@2}
        and (1|M0)               r94.4<1>:d    r1.0<0;1,0>:uw    7:w              
        shl (1|M0)               r110.1<1>:ud  r122.3<0;1,0>:ud  0x9:uw             
(W)     and (1|M0)               f1.0<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
        shl (1|M0)               r94.5<1>:ud   r94.6<0;1,0>:ud   0x7:uw             
        shl (1|M0)               r122.6<1>:d   r122.6<0;1,0>:d   3:w               {I@5}
        mov (16|M0)              r44.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r46.0<1>:f    0.0:f                               {Compacted}
        bfn.0xEA (1|M0)          r110.1<1>:ud  r110.1<0;0>:ud    r94.5<0;0>:ud     0x80:uw              {I@2} // s0|s1&s2
        add3 (1|M0)              r122.6<1>:d   r122.6<0;0>:d     r94.4<0;0>:d      -r2.5<0>:d       {I@2}
        shl (1|M0)               r94.4<1>:d    r94.4<0;1,0>:d    4:w              
(~f1.0.any16h) goto (16|M0)                  L1520                  L1520                
L904:
        cmp (1|M0)    (lt)f0.1   null<1>:d     r122.7<0;1,0>:d   r3.0<0;1,0>:d   
(f0.1)  cmp (1|M0)    (gt)f0.1   null<1>:d     r122.6<0;1,0>:d   -1:w               {I@4}
(f0.1)  cmp (1|M0)    (lt)f0.1   null<1>:d     r122.6<0;1,0>:d   r3.1<0;1,0>:d   
(W)     and (1|M0)               f0.1<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(~f0.1.any16h) goto (16|M0)                  L1520                  L1520                
L984:
        mul (1|M0)               acc0.0<1>:ud  r122.7<0;1,0>:ud  r3.2<0;1,0>:uw  
        mach (1|M0)              r7.0<1>:ud    r122.7<0;1,0>:ud  r3.1<0;1,0>:ud   {AccWrEn}
        cmp (1|M0)    (eq)f1.0   null<1>:w     r122.10<0;1,0>:b  0:w              
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r2.0<1>:ud    r6.0<0;1,0>:ud    r122.6<0;1,0>:ud {AccWrEn,A@1}
(W)     and (1|M0)               f1.1<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        shr (1|M0)               r3.3<1>:ud    r2.0<0;1,0>:ud    0x1B:uw              {I@3}
        add3 (1|M0)              r1.3<1>:d     r8.0<0;0>:d       r7.0<0;0>:d       0:w               {I@2}
        shl (1|M0)               r110.2<1>:d   r2.0<0;1,0>:d     5:w               {Compacted}
        shl (1|M0)               r2.1<1>:d     r1.3<0;1,0>:d     5:w               {I@2}
        or (1|M0)                r110.3<1>:d   r2.1<0;1,0>:d     r3.3<0;1,0>:d    {I@1}
(f1.1.any16h) goto (16|M0)                   L1376                  L1376                
L1168:
        shl (1|M0)               r1.4<1>:d     r110.2<0;1,0>:d   1:w              
        shl (1|M0)               r1.2<1>:d     r110.3<0;1,0>:d   1:w               {I@3}
        shr (1|M0)               r1.3<1>:ud    r110.2<0;1,0>:ud  0x1F:uw             
        addc (1|M0)              r2.0<1>:ud    r3.4<0;1,0>:ud    r1.4<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r7.0<1>:f     r2.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r7.1<1>:d     r6.0<0;0>:d       r3.5<0;0>:d       r1.5<0>:d        {I@1}
        send.ugm (1|M0)          r8       r7      null:0  0x0            0x0220C780           {A@1,$2} // wr:1+0, rd:2; load.ugm.d64x8t.a64
        mov (8|M0)               r44.0<1>:f    r8.0<1;1,0>:hf                   {$2.dst}
        mov (8|M0)               r45.0<1>:f    r8.8<1;1,0>:hf                  
        mov (8|M0)               r46.0<1>:f    r9.0<1;1,0>:hf                  
        mov (8|M0)               r47.0<1>:f    r9.8<1;1,0>:hf                  
        goto (16|M0)                         L1376                  L1520                
L1376:
        join (16|M0)                         L1520                                
L1392:
        shl (1|M0)               r1.4<1>:d     r110.2<0;1,0>:d   2:w              
        shl (1|M0)               r1.2<1>:d     r110.3<0;1,0>:d   2:w              
        shr (1|M0)               r1.3<1>:ud    r110.2<0;1,0>:ud  0x1E:uw             
        addc (1|M0)              r2.0<1>:ud    r3.4<0;1,0>:ud    r1.4<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r7.0<1>:f     r2.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r7.1<1>:d     r6.0<0;0>:d       r3.5<0;0>:d       r1.5<0>:d        {I@1}
        send.ugm (1|M0)          r44      r7      null:0  0x0            0x0240D780           {A@1,$3} // wr:1+0, rd:4; load.ugm.d64x16t.a64
L1520:
        join (16|M0)                         L42064                                
L1536:
        sel (16|M0)   (lt)f0.0   r6.0<1>:f     (abs)r44.0<1;1,0>:f  448.0:f            {Compacted,$3.dst}
        sel (16|M0)   (lt)f0.0   r8.0<1>:f     (abs)r46.0<1;1,0>:f  448.0:f            {Compacted}
        shr (16|M0)              r10.0<1>:ud   r6.0<1;1,0>:ud    0x17:uw              {F@2}
        shr (16|M0)              r12.0<1>:ud   r8.0<1;1,0>:ud    0x17:uw              {F@1}
        sel (16|M0)   (ge)f0.0   r14.0<2>:ub   r10.0<4;1,0>:ub   0x79:uw              {I@2}
        sel (16|M0)   (ge)f0.0   r15.0<2>:ub   r12.0<4;1,0>:ub   0x79:uw              {I@2}
        mov (16|M0)              r16.0<1>:d    r14.0<2;1,0>:ub                  {I@2}
        mov (16|M0)              r18.0<1>:d    r15.0<2;1,0>:ub                  {I@2}
        shl (16|M0)              r16.0<1>:d    r16.0<1;1,0>:d    23:w               {Compacted,I@2}
        shl (16|M0)              r18.0<1>:d    r18.0<1;1,0>:d    23:w               {Compacted,I@2}
        add (16|M0)              r20.0<1>:d    r16.0<1;1,0>:d    -25165824:d               {I@2}
        add (16|M0)              r16.0<1>:d    -r16.0<1;1,0>:d   -2139095040:d              
        add (16|M0)              r22.0<1>:d    r18.0<1;1,0>:d    -25165824:d               {I@3}
        mul (16|M0)              acc0.0<1>:f   r6.0<1;1,0>:f     r16.0<1;1,0>:f   {Compacted,I@2}
        add (16|M0)              r18.0<1>:d    -r18.0<1;1,0>:d   -2139095040:d              
        rnde (16|M0)             acc0.0<1>:f   acc0.0<1;1,0>:f                 
        mul (16|M0)              acc2.0<1>:f   r8.0<1;1,0>:f     r18.0<1;1,0>:f   {Compacted,I@1}
        mul (16|M0)              acc0.0<1>:f   acc0.0<1;1,0>:f   r20.0<1;1,0>:f   {Compacted}
        rnde (16|M0)             acc2.0<1>:f   acc2.0<1;1,0>:f                 
        mov (4|M0)               r7.0<1>:w     0x64206420:v                               {F@5}
        mul (16|M0)              acc2.0<1>:f   acc2.0<1;1,0>:f   r22.0<1;1,0>:f   {Compacted}
        mov (4|M0)               r8.0<4>:uw    r7.0<1;1,0>:uw                   {A@1}
        or (1|M0)                r1.2<1>:d     r110.1<0;1,0>:d   r94.4<0;1,0>:d  
        mov (4|M0)               r120.0<2>:d   r8.0<4;1,0>:w                    {I@2}
        cmp (16|M0)   (lt)f1.0   null<1>:f     r44.0<1;1,0>:f    0.0:f               {Compacted}
        shl (1|M0)               r110.4<1>:d   r1.2<0;1,0>:d     1:w               {I@2}
        asr (4|M0)               r120.1<2>:d   r120.0<2;1,0>:d   31:w               {I@2}
        cmp (16|M0)   (lt)f0.1   null<1>:f     r46.0<1;1,0>:f    0.0:f              
        mov (16|M0)              r10.0<1>:f    (abs)acc0.0<1;1,0>:f             {Compacted}
        addc (1|M0)              r2.0<1>:ud    r122.0<0;1,0>:ud  r110.4<0;1,0>:ud {AccWrEn,A@1}
        mov (4|M0)               r127.0<2>:ud  r120.0<2;1,0>:ud                 {I@2}
        mov (4|M0)               r127.1<2>:ud  r120.1<2;1,0>:ud                
        mov (16|M0)              r12.0<1>:f    (abs)acc2.0<1;1,0>:f             {Compacted}
        shr (1|M0)               r1.4<1>:ud    r1.2<0;1,0>:ud    0x1F:uw             
(f1.0)  or (16|M0)               r10.0<1>:d    r10.0<1;1,0>:d    -2147483648:d              
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (4|M0)              r9.0<1>:ud    r127.0<2;1,0>:ud  0x8:ud              {AccWrEn,I@4}
(f0.1)  or (16|M0)               r12.0<1>:d    r12.0<1;1,0>:d    -2147483648:d               {F@1}
        or (1|M0)                r110.5<1>:d   r1.4<0;1,0>:d     0:w               {I@5}
        mov (8|M0)               r14.0<1>:hf   r10.0<1;1,0>:f                   {I@5}
        mov (8|M0)               r14.8<1>:hf   r11.0<1;1,0>:f                  
        mov (4|M0)               r10.0<1>:ud   acc0.0<1;1,0>:ud                 {F@2}
        addc (4|M0)              r11.0<1>:ud   r127.0<2;1,0>:ud  0x10:ud              {AccWrEn,F@1}
        mov (1|M0)               r6.2<1>:d     r2.0<0;1,0>:d                   
        mov (8|M0)               r15.0<1>:hf   r12.0<1;1,0>:f                   {I@5}
        add3 (1|M0)              r6.3<1>:d     r6.0<0;0>:d       r122.1<0;0>:d     r110.5<0>:d      {I@4}
        mov (4|M0)               r12.0<1>:ud   acc0.0<1;1,0>:ud                 {F@1}
        addc (4|M0)              r7.0<1>:ud    r127.0<2;1,0>:ud  0x18:ud              {AccWrEn}
        mov (4|M0)               r121.0<2>:d   r9.0<1;1,0>:d                   
        mov (8|M0)               r16.0<2>:ud   r6.2<0;1,0>:ud                   {I@5}
        add3 (4|M0)              r121.1<2>:d   r10.0<1;0>:d      r127.1<4;2>:d     0:w              
        mov (4|M0)               r8.0<1>:ud    acc0.0<1;1,0>:ud                
        mov (8|M0)               r16.1<2>:ud   r6.3<0;1,0>:ud                   {I@7}
        bfn.0xFE (1|M0)          r1.2<1>:ud    r94.4<0;0>:ud     r110.1<0;0>:ud    0x100:uw              // s0|s1|s2
        mov (4|M0)               r118.0<2>:d   r11.0<1;1,0>:d                  
        mov (4|M0)               r119.0<2>:d   r7.0<1;1,0>:d                    {I@7}
        addc (8|M0)              r9.0<1>:ud    r16.0<2;1,0>:ud   r120.0<2;1,0>:ud {AccWrEn,Compacted,I@4}
        add3 (4|M0)              r118.1<2>:d   r12.0<1;0>:d      r127.1<4;2>:d     0:w              
        add3 (4|M0)              r119.1<2>:d   r8.0<1;0>:d       r127.1<4;2>:d     0:w              
        shl (1|M0)               r110.2<1>:d   r1.2<0;1,0>:d     1:w               {I@6}
        mov (8|M0)               r10.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        addc (8|M0)              r12.0<1>:ud   r16.0<2;1,0>:ud   r118.0<2;1,0>:ud {AccWrEn,Compacted,I@3}
        shr (1|M0)               r1.4<1>:ud    r1.2<0;1,0>:ud    0x1F:uw             
        mov (8|M0)               r22.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        addc (1|M0)              r2.0<1>:ud    r122.0<0;1,0>:ud  r110.2<0;1,0>:ud {AccWrEn,I@5}
        or (1|M0)                r110.3<1>:d   r1.4<0;1,0>:d     0:w               {I@3}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (8|M0)               r15.8<1>:hf   r13.0<1;1,0>:f                  
        mov (8|M0)               r7.0<1>:d     r118.1<2;1,0>:d                 
        mov (1|M0)               r6.2<1>:d     r2.0<0;1,0>:d                    {I@4}
        mov (8|M0)               r13.0<1>:d    r120.1<2;1,0>:d                  {F@1}
        add3 (1|M0)              r6.3<1>:d     r6.0<0;0>:d       r122.1<0;0>:d     r110.3<0>:d      {I@4}
        mov (8|M0)               r18.0<2>:d    r9.0<1;1,0>:d                   
        add3 (8|M0)              r8.0<1>:d     r22.0<1;0>:d      r16.1<4;2>:d      r7.0<1>:d        {I@5}
        add3 (8|M0)              r11.0<1>:d    r10.0<1;0>:d      r16.1<4;2>:d      r13.0<1>:d       {I@4}
        mov (8|M0)               r9.0<2>:ud    r6.2<0;1,0>:ud                  
        mov (8|M0)               r9.1<2>:ud    r6.3<0;1,0>:ud                   {I@5}
        mov (8|M0)               r20.0<2>:d    r12.0<1;1,0>:d                  
        mov (8|M0)               r20.1<2>:d    r8.0<1;1,0>:d                    {I@5}
        addc (8|M0)              r8.0<1>:ud    r9.0<2;1,0>:ud    r120.0<2;1,0>:ud {AccWrEn,Compacted,I@3}
        mov (16|M0)              r23.0<1>:d    r14.0<1;1,0>:uw                 
        mov (8|M0)               r18.1<2>:d    r11.0<1;1,0>:d                  
        mov (8|M0)               r11.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        addc (8|M0)              r14.0<1>:ud   r9.0<2;1,0>:ud    r118.0<2;1,0>:ud {AccWrEn,Compacted}
        send.ugm (16|M0)         null     r18     r23:2   0x0            0x08000B84           {A@3,$4} // wr:4+2, rd:0; store.ugm.d16u32.a64
        mov (8|M0)               r20.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted,$4.src}
        add3 (8|M0)              r12.0<1>:d    r11.0<1;0>:d      r9.1<4;2>:d       r13.0<1>:d       {I@3}
        add3 (8|M0)              r21.0<1>:d    r20.0<1;0>:d      r9.1<4;2>:d       r7.0<1>:d        {I@2}
        mov (8|M0)               r16.0<2>:d    r8.0<1;1,0>:d                   
        mov (8|M0)               r18.0<2>:d    r14.0<1;1,0>:d                  
        mov (16|M0)              r22.0<1>:d    r15.0<1;1,0>:uw                 
        mov (8|M0)               r16.1<2>:d    r12.0<1;1,0>:d                   {I@5}
        mov (8|M0)               r18.1<2>:d    r21.0<1;1,0>:d                   {I@5}
        send.ugm (16|M0)         null     r16     r22:2   0x0            0x08000B84           {A@1,$5} // wr:4+2, rd:0; store.ugm.d16u32.a64
(W)     send.slm (1|M0)          r6       r0      null:0  0x0            0x0210001F           {$6} // wr:1+0, rd:1; fence.slm.none.group
(W)     mov (1|M0)               r24.2<1>:f    0.0:f                               {Compacted}
(W)     mov (2|M0)               r24.10<1>:ub  r0.11<0;1,0>:ub                  {F@1}
(W)     mov (8|M0)               null<1>:ud    r6.0<1;1,0>:ud                   {$6.dst}
(W)     send.gtwy (1|M0)         null     r24     null:0  0x0            0x02000004           {A@2,$7} // wr:1+0, rd:0; signal barrier
(W)     sync.bar                             null                            
        cmp (1|M0)    (eq)f0.1   null<1>:d     r2.6<0;1,0>:d     1:w              
(W)     and (1|M0)               f1.0<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(f1.0.any16h) goto (16|M0)                   L41192                  L41192                
L3008:
        cmp (1|M0)    (lt)f1.1   null<1>:uw    r1.0<0;1,0>:uw    0x180:uw             
        addc (1|M0)              r2.0<1>:ud    r122.0<0;1,0>:ud  0x1000:ud              {AccWrEn}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
(W)     and (1|M0)               f0.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
        mov (1|M0)               r110.6<1>:d   r2.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r110.7<1>:d   r6.0<0;0>:d       r122.1<0;0>:d     0:w               {I@3}
(~f0.1.any16h) goto (16|M0)                  L6520                  L6520                
L3112:
        mov (16|M0)              r86.0<1>:ud   0x0:ud                             
        mov (16|M0)              r88.0<1>:ud   0x0:ud                             
        mov (16|M0)              r90.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r92.0<1>:f    0.0:f                               {Compacted}
        mov (1|M0)               r94.7<1>:d    r122.3<0;1,0>:d                 
L3176:
        mov (1|M0)               r95.2<2>:b    r94.28<0;1,0>:b                  {I@1}
        mov (1|M0)               r95.0<2>:b    6:w                              
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r95.2         L42640                                 {A@1}
L3256:
        mov (1|M0)               r1.6<2>:b     -6:w                              
        mov (1|M0)               r1.2<1>:d     r95.0<0;1,0>:ub                  {I@3}
(W)     mov (1|M0)               r1.6<1>:w     r1.6<0;1,0>:b                    {I@2}
        shl (1|M0)               r6.0<1>:d     r1.2<0;1,0>:d     9:w               {Compacted,I@2}
        mul (1|M0)               r2.0<1>:w     r95.0<0;1,0>:b    r1.6<0;1,0>:w    {I@2}
        shl (1|M0)               r7.0<1>:d     r6.0<0;1,0>:d     1:w               {Compacted,I@2}
        add (1|M0)               r1.6<2>:b     r94.28<0;1,0>:b   r2.0<0;1,0>:w    {I@2}
        addc (1|M0)              r8.0<1>:ud    r122.0<0;1,0>:ud  r7.0<0;1,0>:ud   {AccWrEn,I@2}
        mov (1|M0)               r3.3<1>:d     r1.6<0;1,0>:ub                   {I@2}
        shr (1|M0)               r6.2<1>:ud    r6.0<0;1,0>:ud    0x1F:uw             
        shl (1|M0)               r10.2<1>:d    r3.3<0;1,0>:d     8:w               {I@2}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        shl (1|M0)               r2.0<1>:d     r10.2<0;1,0>:d    1:w               {Compacted,I@2}
        mov (1|M0)               r10.0<1>:f    r8.0<0;1,0>:f                    {Compacted}
        addc (1|M0)              r11.0<1>:ud   r4.0<0;1,0>:ud    r2.0<0;1,0>:ud   {AccWrEn,I@1}
        or (1|M0)                r7.1<1>:d     r6.2<0;1,0>:d     0:w              
        shr (1|M0)               r10.4<1>:ud   r10.2<0;1,0>:ud   0x1F:uw             
        mov (1|M0)               r12.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r13.0<1>:f    r11.0<0;1,0>:f                   {Compacted,I@4}
        addc (1|M0)              r6.0<1>:ud    r10.0<0;1,0>:ud   0x100:ud              {AccWrEn,F@2}
        add3 (1|M0)              r10.1<1>:d    r9.0<0;0>:d       r122.1<0;0>:d     r7.1<0>:d        {I@4}
        or (1|M0)                r2.1<1>:d     r10.4<0;1,0>:d    0:w               {I@4}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r9.0<1>:ud    r13.0<0;1,0>:ud   0x100:ud              {AccWrEn,F@1}
        add3 (1|M0)              r13.1<1>:d    r12.0<0;0>:d      r4.1<0;0>:d       r2.1<0>:d        {I@3}
        mov (1|M0)               r2.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r8.0<1>:f     r6.0<0;1,0>:f                    {Compacted}
        add3 (1|M0)              r8.1<1>:d     r7.0<0;0>:d       r10.1<0;0>:d      0:w               {I@4}
        mov (1|M0)               r11.0<1>:f    r9.0<0;1,0>:f                    {Compacted,I@4}
        add3 (1|M0)              r11.1<1>:d    r2.0<0;0>:d       r13.1<0;0>:d      0:w               {I@2}
        send.ugm (1|M0)          r14      r10     null:0  0x0            0x0280E780           {$13} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        send.ugm (1|M0)          r30      r13     null:0  0x0            0x0280E780           {$14} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        send.ugm (1|M0)          r22      r8      null:0  0x0            0x0280E780           {A@2,$15} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        send.ugm (1|M0)          r38      r11     null:0  0x0            0x0280E780           {A@1,$0} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        addc (1|M0)              r6.0<1>:ud    r10.0<0;1,0>:ud   0x200:ud              {AccWrEn}
        mul (1|M0)               r1.2<1>:d     r95.0<0;1,0>:ub   1536:w              
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        sync.nop                             null                             {Compacted,$15.src}
        mov (1|M0)               r8.0<1>:f     r6.0<0;1,0>:f                    {Compacted,I@3}
        addc (1|M0)              r9.0<1>:ud    r13.0<0;1,0>:ud   0xC00:ud              {AccWrEn}
        add3 (1|M0)              r8.1<1>:d     r7.0<0;0>:d       r10.1<0;0>:d      0:w               {I@2}
        mov (1|M0)               r2.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r12.0<1>:f    r9.0<0;1,0>:f                    {Compacted,I@3}
        sync.nop                             null                             {Compacted,$0.src}
        addc (1|M0)              r11.0<1>:ud   r8.0<0;1,0>:ud    0x100:ud              {AccWrEn,F@2}
        add3 (1|M0)              r12.1<1>:d    r2.0<0;0>:d       r13.1<0;0>:d      0:w               {I@2}
        send.ugm (1|M0)          r78      r8      null:0  0x0            0x0280E780           {$1} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        shl (1|M0)               r6.3<1>:d     r3.3<0;1,0>:d     4:w               {Compacted}
        shl (1|M0)               r8.0<1>:d     r1.2<0;1,0>:d     2:w               {Compacted,$1.src}
        shr (1|M0)               r1.4<1>:ud    r1.2<0;1,0>:ud    0x1E:uw             
        shr (1|M0)               r6.5<1>:ud    r6.3<0;1,0>:ud    0x1E:uw              {I@3}
        cmp (1|M0)    (lt)f1.0   null<1>:ud    r94.7<0;1,0>:ud   0x14:uw             
        add (1|M0)               r1.2<1>:d     r94.7<0;1,0>:d    4:w              
(W)     and (1|M0)               f1.1<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
        sync.allwr                           ($0,$13,$14,$15)                
        dpas.8x8 (8|M0)          r54:f         null:f            r54:hf            r54.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r54:f         r86:f             r30:hf            r14.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r62:f         r86:f             r30:hf            r22.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r46:f         r86:f             r38:hf            r14.0:hf         {$13}
        mov (1|M0)               r14.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,$13.src}
        addc (1|M0)              r6.0<1>:ud    r12.0<0;1,0>:ud   0x100:ud              {AccWrEn,F@1}
        dpas.8x8 (8|M0)          r70:f         r86:f             r38:hf            r22.0:hf         {$2}
        mov (1|M0)               r2.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r7.0<1>:f     r6.0<0;1,0>:f                    {Compacted,I@2}
        add3 (1|M0)              r7.1<1>:d     r2.0<0;0>:d       r12.1<0;0>:d      0:w               {I@1}
        sync.nop                             null                             {Compacted,$2.src}
        send.ugm (1|M0)          r24      r12     null:0  0x0            0x0280E780           {$3} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        send.ugm (1|M0)          r32      r7      null:0  0x0            0x0280E780           {A@1,$4} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        mov (1|M0)               r15.0<1>:f    r11.0<0;1,0>:f                   {Compacted}
        add3 (1|M0)              r15.1<1>:d    r14.0<0;0>:d      r8.1<0;0>:d       0:w              
        addc (1|M0)              r6.0<1>:ud    r110.6<0;1,0>:ud  r8.0<0;1,0>:ud   {AccWrEn}
        send.ugm (1|M0)          r16      r15     null:0  0x0            0x0280E780           {A@1,$6} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        shl (1|M0)               r7.0<1>:d     r6.3<0;1,0>:d     2:w               {Compacted,$4.src}
        mov (1|M0)               r2.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r9.0<1>:ud    r6.0<0;1,0>:ud    r7.0<0;1,0>:ud   {AccWrEn,I@2}
        or (1|M0)                r8.1<1>:d     r1.4<0;1,0>:d     0:w              
        mov (1|M0)               r11.0<1>:f    r9.0<0;1,0>:f                    {Compacted,I@2}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        sync.nop                             null                             {Compacted,$3.src}
        addc (1|M0)              r12.0<1>:ud   r11.0<0;1,0>:ud   0x20:ud              {AccWrEn,F@1}
        or (1|M0)                r7.1<1>:d     r6.5<0;1,0>:d     0:w              
        mov (1|M0)               r13.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r8.0<1>:ud    r11.0<0;1,0>:ud   0xC00:ud              {AccWrEn}
        add3 (1|M0)              r6.2<1>:d     r2.0<0;0>:d       r110.7<0;0>:d     r8.1<0>:d        {I@6}
        mov (1|M0)               r14.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r6.0<1>:ud    r11.0<0;1,0>:ud   0xC20:ud              {AccWrEn}
        add3 (1|M0)              r11.1<1>:d    r10.0<0;0>:d      r6.2<0;0>:d       r7.1<0>:d        {I@3}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r10.0<1>:ud   r11.0<0;1,0>:ud   0x180:ud              {AccWrEn}
        mov (1|M0)               r2.0<1>:f     r12.0<0;1,0>:f                   {Compacted}
        add3 (1|M0)              r2.1<1>:d     r13.0<0;0>:d      r11.1<0;0>:d      0:w               {I@3}
        mov (1|M0)               r12.0<1>:f    r10.0<0;1,0>:f                   {Compacted,I@2}
        mov (1|M0)               r15.0<1>:f    r8.0<0;1,0>:f                    {Compacted,$6.src}
        mov (1|M0)               r9.0<1>:f     r6.0<0;1,0>:f                    {Compacted}
        add3 (1|M0)              r9.1<1>:d     r7.0<0;0>:d       r11.1<0;0>:d      0:w              
        add3 (1|M0)              r15.1<1>:d    r14.0<0;0>:d      r11.1<0;0>:d      0:w              
        sync.allwr                           ($1,$2,$3,$4,$6,$13)                
        dpas.8x8 (8|M0)          r54:f         r54:f             r24:hf            r78.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r46:f         r46:f             r32:hf            r78.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r62:f         r62:f             r24:hf            r16.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r70:f         r70:f             r32:hf            r16.0:hf         {$1}
        send.ugm (1|M0)          null     r11     r54:1   0x0            0x0200C584           {$1} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r2      r46:1   0x0            0x0200C584           {A@3,$14} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        mov (1|M0)               r2.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$14.src}
        addc (1|M0)              r8.0<1>:ud    r12.0<0;1,0>:ud   0x20:ud              {AccWrEn,A@2}
        add3 (1|M0)              r12.1<1>:d    r2.0<0;0>:d       r11.1<0;0>:d      0:w               {I@2}
        mov (1|M0)               r13.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r6.0<1>:ud    r12.0<0;1,0>:ud   0xC00:ud              {AccWrEn,F@1}
        mov (1|M0)               r14.0<1>:f    r8.0<0;1,0>:f                    {Compacted,I@4}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r2.0<1>:ud    r12.0<0;1,0>:ud   0xC20:ud              {AccWrEn}
        add3 (1|M0)              r14.1<1>:d    r13.0<0;0>:d      r12.1<0;0>:d      0:w               {I@4}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r8.0<1>:ud    r11.0<0;1,0>:ud   0x300:ud              {AccWrEn,F@1}
        send.ugm (1|M0)          null     r15     r62:1   0x0            0x0200C584           {$15} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r9      r70:1   0x0            0x0200C584           {$0} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r12     r55:1   0x0            0x0200C584           {$2} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r14     r47:1   0x0            0x0200C584           {A@3,$3} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        sync.nop                             null                             {Compacted,$3.src}
        mov (1|M0)               r14.0<1>:f    r8.0<0;1,0>:f                    {Compacted,I@1}
        mov (1|M0)               r13.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r9.0<1>:f     r6.0<0;1,0>:f                    {Compacted,$0.src}
        addc (1|M0)              r6.0<1>:ud    r14.0<0;1,0>:ud   0x20:ud              {AccWrEn,A@1}
        mov (1|M0)               r15.0<1>:f    r2.0<0;1,0>:f                    {Compacted,$15.src}
        add3 (1|M0)              r9.1<1>:d     r7.0<0;0>:d       r12.1<0;0>:d      0:w              
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r2.0<1>:ud    r14.0<0;1,0>:ud   0xC00:ud              {AccWrEn,F@1}
        add3 (1|M0)              r15.1<1>:d    r10.0<0;0>:d      r12.1<0;0>:d      0:w              
        add3 (1|M0)              r14.1<1>:d    r13.0<0;0>:d      r11.1<0;0>:d      0:w               {I@6}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r8.0<1>:ud    r14.0<0;1,0>:ud   0xC20:ud              {AccWrEn}
        send.ugm (1|M0)          null     r9      r63:1   0x0            0x0200C584           {A@7,$4} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        mov (1|M0)               r9.0<1>:f     r6.0<0;1,0>:f                    {Compacted,$4.src}
        add3 (1|M0)              r9.1<1>:d     r7.0<0;0>:d       r14.1<0;0>:d      0:w               {I@3}
        mov (1|M0)               r13.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r6.0<1>:ud    r11.0<0;1,0>:ud   0x480:ud              {AccWrEn,F@1}
        send.ugm (1|M0)          null     r15     r71:1   0x0            0x0200C584           {$6} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r14     r56:1   0x0            0x0200C584           {$13} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r9      r48:1   0x0            0x0200C584           {A@3,$5} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        sync.nop                             null                             {Compacted,$5.src}
        mov (1|M0)               r9.0<1>:f     r6.0<0;1,0>:f                    {Compacted,I@1}
        mov (1|M0)               r12.0<1>:f    r2.0<0;1,0>:f                    {Compacted,$2.src}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r2.0<1>:ud    r9.0<0;1,0>:ud    0x20:ud              {AccWrEn,A@1}
        add3 (1|M0)              r12.1<1>:d    r10.0<0;0>:d      r14.1<0;0>:d      0:w              
        mov (1|M0)               r15.0<1>:f    r8.0<0;1,0>:f                    {Compacted,$6.src}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r8.0<1>:ud    r9.0<0;1,0>:ud    0xC00:ud              {AccWrEn,F@1}
        add3 (1|M0)              r15.1<1>:d    r13.0<0;0>:d      r14.1<0;0>:d      0:w              
        add3 (1|M0)              r9.1<1>:d     r7.0<0;0>:d       r11.1<0;0>:d      0:w               {I@6}
        mov (1|M0)               r13.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r6.0<1>:ud    r9.0<0;1,0>:ud    0xC20:ud              {AccWrEn}
        send.ugm (1|M0)          null     r12     r64:1   0x0            0x0200C584           {A@7,$7} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        mov (1|M0)               r12.0<1>:f    r2.0<0;1,0>:f                    {Compacted,$7.src}
        add3 (1|M0)              r12.1<1>:d    r10.0<0;0>:d      r9.1<0;0>:d       0:w               {I@3}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r2.0<1>:ud    r11.0<0;1,0>:ud   0x600:ud              {AccWrEn,F@1}
        send.ugm (1|M0)          null     r15     r72:1   0x0            0x0200C584           {$14} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r9      r57:1   0x0            0x0200C584           {$11} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r12     r49:1   0x0            0x0200C584           {A@3,$12} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        sync.nop                             null                             {Compacted,$12.src}
        mov (1|M0)               r12.0<1>:f    r2.0<0;1,0>:f                    {Compacted,I@1}
        mov (1|M0)               r14.0<1>:f    r8.0<0;1,0>:f                    {Compacted,$13.src}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r8.0<1>:ud    r12.0<0;1,0>:ud   0x20:ud              {AccWrEn,A@1}
        add3 (1|M0)              r14.1<1>:d    r13.0<0;0>:d      r9.1<0;0>:d       0:w              
        mov (1|M0)               r15.0<1>:f    r6.0<0;1,0>:f                    {Compacted,$14.src}
        mov (1|M0)               r13.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r6.0<1>:ud    r12.0<0;1,0>:ud   0xC00:ud              {AccWrEn,F@1}
        add3 (1|M0)              r15.1<1>:d    r7.0<0;0>:d       r9.1<0;0>:d       0:w              
        add3 (1|M0)              r12.1<1>:d    r10.0<0;0>:d      r11.1<0;0>:d      0:w               {I@6}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r2.0<1>:ud    r12.0<0;1,0>:ud   0xC20:ud              {AccWrEn}
        send.ugm (1|M0)          null     r14     r65:1   0x0            0x0200C584           {A@7,$3} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        mov (1|M0)               r14.0<1>:f    r8.0<0;1,0>:f                    {Compacted,$3.src}
        add3 (1|M0)              r14.1<1>:d    r13.0<0;0>:d      r12.1<0;0>:d      0:w               {I@3}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r8.0<1>:ud    r11.0<0;1,0>:ud   0x780:ud              {AccWrEn,F@1}
        send.ugm (1|M0)          null     r15     r73:1   0x0            0x0200C584           {$15} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r12     r58:1   0x0            0x0200C584           {$0} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r14     r50:1   0x0            0x0200C584           {A@3,$1} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        sync.nop                             null                             {Compacted,$1.src}
        mov (1|M0)               r14.0<1>:f    r8.0<0;1,0>:f                    {Compacted,I@1}
        mov (1|M0)               r9.0<1>:f     r6.0<0;1,0>:f                    {Compacted,$11.src}
        mov (1|M0)               r13.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r6.0<1>:ud    r14.0<0;1,0>:ud   0x20:ud              {AccWrEn,A@1}
        add3 (1|M0)              r9.1<1>:d     r7.0<0;0>:d       r12.1<0;0>:d      0:w              
        mov (1|M0)               r15.0<1>:f    r2.0<0;1,0>:f                    {Compacted,$15.src}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r2.0<1>:ud    r14.0<0;1,0>:ud   0xC00:ud              {AccWrEn,F@1}
        add3 (1|M0)              r15.1<1>:d    r10.0<0;0>:d      r12.1<0;0>:d      0:w              
        add3 (1|M0)              r14.1<1>:d    r13.0<0;0>:d      r11.1<0;0>:d      0:w               {I@6}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r8.0<1>:ud    r14.0<0;1,0>:ud   0xC20:ud              {AccWrEn}
        send.ugm (1|M0)          null     r9      r66:1   0x0            0x0200C584           {A@7,$4} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        mov (1|M0)               r9.0<1>:f     r6.0<0;1,0>:f                    {Compacted,$4.src}
        add3 (1|M0)              r9.1<1>:d     r7.0<0;0>:d       r14.1<0;0>:d      0:w               {I@3}
        mov (1|M0)               r13.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r6.0<1>:ud    r11.0<0;1,0>:ud   0x900:ud              {AccWrEn,F@1}
        send.ugm (1|M0)          null     r15     r74:1   0x0            0x0200C584           {$6} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r14     r59:1   0x0            0x0200C584           {$13} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r9      r51:1   0x0            0x0200C584           {A@3,$2} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        sync.nop                             null                             {Compacted,$2.src}
        mov (1|M0)               r9.0<1>:f     r6.0<0;1,0>:f                    {Compacted,I@1}
        mov (1|M0)               r12.0<1>:f    r2.0<0;1,0>:f                    {Compacted,$0.src}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r2.0<1>:ud    r9.0<0;1,0>:ud    0x20:ud              {AccWrEn,A@1}
        add3 (1|M0)              r12.1<1>:d    r10.0<0;0>:d      r14.1<0;0>:d      0:w              
        mov (1|M0)               r15.0<1>:f    r8.0<0;1,0>:f                    {Compacted,$6.src}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r8.0<1>:ud    r9.0<0;1,0>:ud    0xC00:ud              {AccWrEn,F@1}
        add3 (1|M0)              r15.1<1>:d    r13.0<0;0>:d      r14.1<0;0>:d      0:w              
        add3 (1|M0)              r9.1<1>:d     r7.0<0;0>:d       r11.1<0;0>:d      0:w               {I@6}
        mov (1|M0)               r13.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r6.0<1>:ud    r9.0<0;1,0>:ud    0xC20:ud              {AccWrEn}
        send.ugm (1|M0)          null     r12     r67:1   0x0            0x0200C584           {A@7,$14} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        mov (1|M0)               r12.0<1>:f    r2.0<0;1,0>:f                    {Compacted,$14.src}
        add3 (1|M0)              r12.1<1>:d    r10.0<0;0>:d      r9.1<0;0>:d       0:w               {I@3}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r2.0<1>:ud    r11.0<0;1,0>:ud   0xA80:ud              {AccWrEn,F@1}
        send.ugm (1|M0)          null     r15     r75:1   0x0            0x0200C584           {$5} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r9      r60:1   0x0            0x0200C584           {$7} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r12     r52:1   0x0            0x0200C584           {A@3,$3} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        sync.nop                             null                             {Compacted,$3.src}
        mov (1|M0)               r12.0<1>:f    r2.0<0;1,0>:f                    {Compacted,I@1}
        mov (1|M0)               r14.0<1>:f    r8.0<0;1,0>:f                    {Compacted,$13.src}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r8.0<1>:ud    r12.0<0;1,0>:ud   0x20:ud              {AccWrEn,A@1}
        add3 (1|M0)              r14.1<1>:d    r13.0<0;0>:d      r9.1<0;0>:d       0:w              
        mov (1|M0)               r15.0<1>:f    r6.0<0;1,0>:f                    {Compacted,$5.src}
        mov (1|M0)               r13.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r6.0<1>:ud    r12.0<0;1,0>:ud   0xC00:ud              {AccWrEn,F@1}
        add3 (1|M0)              r15.1<1>:d    r7.0<0;0>:d       r9.1<0;0>:d       0:w              
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r2.0<1>:ud    r12.0<0;1,0>:ud   0xC20:ud              {AccWrEn}
        add3 (1|M0)              r12.1<1>:d    r10.0<0;0>:d      r11.1<0;0>:d      0:w               {I@7}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        send.ugm (1|M0)          null     r14     r68:1   0x0            0x0200C584           {A@7,$15} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        sync.nop                             null                             {Compacted,$7.src}
        mov (1|M0)               r9.0<1>:f     r6.0<0;1,0>:f                    {Compacted,I@6}
        mov (1|M0)               r11.0<1>:f    r2.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r9.1<1>:d     r7.0<0;0>:d       r12.1<0;0>:d      0:w               {I@2}
        mov (1|M0)               r14.0<1>:f    r8.0<0;1,0>:f                    {Compacted,$15.src}
        add3 (1|M0)              r14.1<1>:d    r13.0<0;0>:d      r12.1<0;0>:d      0:w              
        add3 (1|M0)              r11.1<1>:d    r10.0<0;0>:d      r12.1<0;0>:d      0:w               {I@3}
        send.ugm (1|M0)          null     r15     r76:1   0x0            0x0200C584           {$9} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r12     r61:1   0x0            0x0200C584           {$8} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r14     r53:1   0x0            0x0200C584           {A@1,$10} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r9      r69:1   0x0            0x0200C584           {$12} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r11     r77:1   0x0            0x0200C584           {A@1,$11} // wr:1+1, rd:0; store.ugm.d32x8t.a64
(~f1.1.any16h) goto (16|M0)                  L6520                  L6520                
L6488:
        mov (1|M0)               r94.7<1>:d    r1.2<0;1,0>:d                   
        goto.b (16|M0)                       L6520                  L3176                
L6520:
        join (16|M0)                         L41192                                
L6536:
(W)     send.slm (1|M0)          r6       r0      null:0  0x0            0x0210001F           {$4} // wr:1+0, rd:1; fence.slm.none.group
(W)     mov (1|M0)               r7.2<1>:f     0.0:f                               {Compacted}
(W)     mov (2|M0)               r7.10<1>:ub   r0.11<0;1,0>:ub                  {F@1}
(W)     mov (8|M0)               null<1>:ud    r6.0<1;1,0>:ud                   {$4.dst}
(W)     send.gtwy (1|M0)         null     r7      null:0  0x0            0x02000004           {A@2,$6} // wr:1+0, rd:0; signal barrier
(W)     sync.bar                             null                            
        cmp (1|M0)    (eq)f0.1   null<1>:d     r2.6<0;1,0>:d     2:w              
(W)     and (1|M0)               f1.0<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(f1.0.any16h) goto (16|M0)                   L40224                  L40224                
L6672:
        mul (1|M0)               acc0.0<1>:ud  r110.0<0;1,0>:ud  0x60:uw             
        mach (1|M0)              r7.0<1>:ud    r110.0<0;1,0>:ud  0x60:ud              {AccWrEn,$6.src}
        shl (1|M0)               r86.2<1>:ud   r110.0<0;1,0>:ud  0x4:uw             
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        shl (1|M0)               r1.2<1>:d     r7.0<0;1,0>:d     2:w               {Compacted,I@3}
        shl (1|M0)               r1.4<1>:d     r6.0<0;1,0>:d     2:w               {Compacted,I@2}
        shr (1|M0)               r1.3<1>:ud    r6.0<0;1,0>:ud    0x1E:uw             
        addc (1|M0)              r2.0<1>:ud    r110.6<0;1,0>:ud  r1.4<0;1,0>:ud   {AccWrEn,I@2}
        shl (1|M0)               r94.7<1>:ud   r110.0<0;1,0>:ud  0x3:uw             
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r9.0<1>:ud    r122.0<0;1,0>:ud  0x7000:ud              {AccWrEn,$12.src}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@5}
        mov (1|M0)               r86.0<1>:f    r9.0<0;1,0>:f                    {Compacted,I@2}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r6.0<1>:ud    r86.0<0;1,0>:ud   r110.4<0;1,0>:ud {AccWrEn,F@1}
        mov (1|M0)               r86.4<1>:d    r2.0<0;1,0>:d                   
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r2.0<1>:ud    r86.0<0;1,0>:ud   r110.2<0;1,0>:ud {AccWrEn}
        shl (1|M0)               r3.3<1>:ud    r110.0<0;1,0>:ud  0x1:uw             
        and (1|M0)               r86.3<1>:ud   r86.2<0;1,0>:ud   0x80:uw             
        and (1|M0)               r94.7<1>:ud   r94.7<0;1,0>:ud   0x70:uw             
        add3 (1|M0)              r86.5<1>:d    r8.0<0;0>:d       r110.7<0;0>:d     r1.5<0>:d        {I@7}
        add3 (1|M0)              r86.1<1>:d    r10.0<0;0>:d      r122.1<0;0>:d     0:w               {I@7}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r86.6<1>:d    r6.0<0;1,0>:d                    {I@7}
        mov (1|M0)               r110.2<2>:f   0.0:f                               {I@7}
        mov (1|M0)               r110.4<1>:d   r2.0<0;1,0>:d                   
        bfn.0xEA (1|M0)          r86.3<1>:ud   r86.3<0;0>:ud     r3.3<0;0>:ud      0xE:uw              {I@7} // s0|s1&s2
        bfn.0xEA (1|M0)          r94.7<1>:ud   r94.7<0;0>:ud     r110.0<0;0>:ud    0x1:uw              {I@7} // s0|s1&s2
        add3 (1|M0)              r86.7<1>:d    r7.0<0;0>:d       r86.1<0;0>:d      r110.5<0>:d      {I@6}
        add3 (1|M0)              r110.5<1>:d   r8.0<0;0>:d       r86.1<0;0>:d      r110.3<0>:d      {I@6}
        mov (1|M0)               r110.3<2>:f   0.0:f                               {I@1}
L7120:
        shl (1|M0)               r1.2<1>:d     r110.3<0;1,0>:d   5:w               {F@1}
        shr (1|M0)               r1.3<1>:ud    r110.2<0;1,0>:ud  0x1B:uw             
        shl (1|M0)               r1.4<1>:d     r110.2<0;1,0>:d   5:w              
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        shl (1|M0)               r6.0<1>:d     r1.4<0;1,0>:d     2:w               {Compacted,I@2}
        shr (1|M0)               r2.1<1>:ud    r1.4<0;1,0>:ud    0x1E:uw             
        shl (1|M0)               r2.0<1>:d     r1.5<0;1,0>:d     2:w               {Compacted,I@3}
        sync.nop                             null                             {Compacted,$0.src}
        addc (1|M0)              r7.0<1>:ud    r86.4<0;1,0>:ud   r6.0<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r6.1<1>:d     r2.0<0;1,0>:d     r2.1<0;1,0>:d    {I@2}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        sync.nop                             null                             {Compacted,$1.src}
        mov (1|M0)               r9.0<1>:f     r7.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r9.1<1>:d     r8.0<0;0>:d       r86.5<0;0>:d      r6.1<0>:d        {I@1}
        cmp (1|M0)    (eq)f1.1   null<1>:d     r110.2<0;1,0>:d   2:w              
        sync.allrd                           ($3,$7)                
        send.ugm (1|M0)          r24      r9      null:0  0x0            0x0240E580           {A@1,$1} // wr:1+0, rd:4; load.ugm.d32x32t.a64
        cmp (1|M0)    (eq)f1.0   null<1>:d     r110.3<0;1,0>:d   0:w              
(W)     mov (1|M0)               r3.5<1>:hf    0x1:hf                             
(f1.1)  sel (1|M0)               r3.6<1>:uw    r3.5<0;1,0>:uw    0x0:uw              {F@1}
(f1.0)  sel (1|M0)               r1.3<1>:uw    r3.5<0;1,0>:uw    0x0:uw             
        and (1|M0)    (ne)f1.1   null<1>:uw    r3.6<0;1,0>:uw    r1.3<0;1,0>:uw   {I@1}
(W)     and (1|M0)               f0.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(f0.1.any16h) goto (16|M0)                   L11472                  L11472                
L7456:
        mov (8|M0)               r6.0<1>:hf    r26.0<1;1,0>:f                   {$1.dst}
        mov (8|M0)               r7.0<1>:hf    r24.0<1;1,0>:f                  
        mov (8|M0)               r48.0<1>:f    r6.0<1;1,0>:hf                   {F@2}
        mov (8|M0)               r50.0<1>:f    r7.0<1;1,0>:hf                   {F@2}
        mul (1|M0)               r8.1<1>:f     r48.0<0;1,0>:f    r48.0<0;1,0>:f   {Compacted,F@2}
        mul (1|M0)               r1.2<1>:f     r50.0<0;1,0>:f    r50.0<0;1,0>:f   {Compacted,F@2}
        mov (8|M0)               r6.8<1>:hf    r27.0<1;1,0>:f                  
        mov (8|M0)               r7.8<1>:hf    r25.0<1;1,0>:f                  
        mul (1|M0)               r6.0<1>:f     r48.1<0;1,0>:f    r48.1<0;1,0>:f  
        mov (1|M0)               r9.0<2>:hf    r8.1<0;1,0>:f                    {F@5}
        mov (1|M0)               r2.0<2>:hf    r1.2<0;1,0>:f                    {F@5}
        mul (1|M0)               r1.2<1>:f     r50.1<0;1,0>:f    r50.1<0;1,0>:f  
        mov (8|M0)               r49.0<1>:f    r6.8<1;1,0>:hf                   {F@6}
        mov (8|M0)               r51.0<1>:f    r7.8<1;1,0>:hf                   {F@6}
        sync.allrd                           ($2,$4,$8)                
        mov (1|M0)               r12.0<2>:hf   r6.0<0;1,0>:f                    {F@6}
        mov (1|M0)               r10.0<1>:f    r9.0<0;1,0>:hf                   {F@6}
        mov (1|M0)               r3.3<1>:f     r2.0<0;1,0>:hf                   {A@3}
        mov (1|M0)               r2.0<2>:hf    r1.2<0;1,0>:f                    {F@6}
        mov (1|M0)               r8.1<1>:f     r12.0<0;1,0>:hf                  {F@4}
        mad (1|M0)               r10.0<1>:f    r10.0<0;0>:f      r49.0<0;0>:f      r49.0<0>:f       {F@4}
        mad (1|M0)               r3.3<1>:f     r3.3<0;0>:f       r51.0<0;0>:f      r51.0<0>:f       {F@4}
        sync.nop                             null                             {Compacted,$11.src}
        mov (1|M0)               r11.0<1>:f    r2.0<0;1,0>:hf                   {F@4}
        mad (1|M0)               r8.1<1>:f     r8.1<0;0>:f       r49.1<0;0>:f      r49.1<0>:f       {F@4}
        mov (1|M0)               r7.0<2>:hf    r10.0<0;1,0>:f                   {F@4}
        mov (1|M0)               r8.0<2>:hf    r3.3<0;1,0>:f                    {F@4}
        mad (1|M0)               r11.0<1>:f    r11.0<0;0>:f      r51.1<0;0>:f      r51.1<0>:f       {F@4}
        mul (1|M0)               r2.1<1>:f     r48.2<0;1,0>:f    r48.2<0;1,0>:f  
        mov (1|M0)               r9.0<2>:hf    r8.1<0;1,0>:f                    {F@5}
        add (1|M0)               r8.0<1>:hf    r8.0<0;1,0>:hf    r7.0<0;1,0>:hf   {F@4}
        mov (1|M0)               r3.6<2>:hf    r11.0<0;1,0>:f                   {F@4}
        mul (1|M0)               r8.1<1>:f     r50.3<0;1,0>:f    r50.3<0;1,0>:f  
        mul (1|M0)               r7.0<1>:f     r50.2<0;1,0>:f    r50.2<0;1,0>:f  
        mov (1|M0)               r11.0<2>:hf   r2.1<0;1,0>:f                    {F@6}
        add (1|M0)               r3.6<1>:hf    r3.6<0;1,0>:hf    r9.0<0;1,0>:hf   {F@4}
        mov (1|M0)               r10.0<2>:hf   r7.0<0;1,0>:f                    {F@3}
        mov (1|M0)               r9.0<2>:hf    r8.1<0;1,0>:f                   
        mov (1|M0)               r6.0<1>:f     r11.0<0;1,0>:hf                  {F@4}
        mov (1|M0)               r1.2<1>:f     r10.0<0;1,0>:hf                  {F@3}
        mov (1|M0)               r7.0<1>:f     r9.0<0;1,0>:hf                   {F@3}
        mad (1|M0)               r6.0<1>:f     r6.0<0;0>:f       r49.2<0;0>:f      r49.2<0>:f       {F@3}
        mad (1|M0)               r1.2<1>:f     r1.2<0;0>:f       r51.2<0;0>:f      r51.2<0>:f       {F@3}
        mad (1|M0)               r7.0<1>:f     r7.0<0;0>:f       r51.3<0;0>:f      r51.3<0>:f       {F@3}
        mov (1|M0)               r12.0<2>:hf   r6.0<0;1,0>:f                    {F@3}
        mov (1|M0)               r2.0<2>:hf    r1.2<0;1,0>:f                    {F@3}
        mov (1|M0)               r10.0<2>:hf   r7.0<0;1,0>:f                    {F@3}
        mul (1|M0)               r6.0<1>:f     r50.4<0;1,0>:f    r50.4<0;1,0>:f  
        mul (1|M0)               r1.2<1>:f     r48.3<0;1,0>:f    r48.3<0;1,0>:f  
        mul (1|M0)               r7.0<1>:f     r48.4<0;1,0>:f    r48.4<0;1,0>:f  
        add (1|M0)               r2.0<1>:hf    r2.0<0;1,0>:hf    r12.0<0;1,0>:hf  {F@5}
        mov (1|M0)               r10.2<2>:hf   r1.2<0;1,0>:f                    {F@3}
        mov (1|M0)               r12.0<2>:hf   r6.0<0;1,0>:f                   
        mov (1|M0)               r9.2<2>:hf    r7.0<0;1,0>:f                    {F@4}
        mov (1|M0)               r2.1<1>:f     r10.2<0;1,0>:hf                  {F@3}
        mov (1|M0)               r8.1<1>:f     r12.0<0;1,0>:hf                  {F@3}
        mov (1|M0)               r1.2<1>:f     r9.2<0;1,0>:hf                   {F@3}
        mad (1|M0)               r2.1<1>:f     r2.1<0;0>:f       r49.3<0;0>:f      r49.3<0>:f       {F@3}
        mad (1|M0)               r8.1<1>:f     r8.1<0;0>:f       r51.4<0;0>:f      r51.4<0>:f       {F@3}
        mad (1|M0)               r1.2<1>:f     r1.2<0;0>:f       r49.4<0;0>:f      r49.4<0>:f       {F@3}
        mov (1|M0)               r11.0<2>:hf   r2.1<0;1,0>:f                    {F@3}
        mov (1|M0)               r9.0<2>:hf    r8.1<0;1,0>:f                    {F@3}
        mov (1|M0)               r10.2<2>:hf   r1.2<0;1,0>:f                    {F@3}
        mul (1|M0)               r2.1<1>:f     r50.5<0;1,0>:f    r50.5<0;1,0>:f  
        mul (1|M0)               r8.1<1>:f     r48.5<0;1,0>:f    r48.5<0;1,0>:f  
        mul (1|M0)               r1.2<1>:f     r50.6<0;1,0>:f    r50.6<0;1,0>:f  
        add (1|M0)               r10.0<1>:hf   r10.0<0;1,0>:hf   r11.0<0;1,0>:hf  {F@6}
        add (1|M0)               r9.0<1>:hf    r9.0<0;1,0>:hf    r10.2<0;1,0>:hf  {F@5}
        mov (1|M0)               r12.2<2>:hf   r8.1<0;1,0>:f                    {F@4}
        mov (1|M0)               r11.0<2>:hf   r2.1<0;1,0>:f                   
        mov (1|M0)               r10.2<2>:hf   r1.2<0;1,0>:f                    {F@5}
        mov (1|M0)               r7.0<1>:f     r12.2<0;1,0>:hf                  {F@3}
        mov (1|M0)               r6.0<1>:f     r11.0<0;1,0>:hf                  {F@3}
        mov (1|M0)               r2.1<1>:f     r10.2<0;1,0>:hf                  {F@3}
        mad (1|M0)               r7.0<1>:f     r7.0<0;0>:f       r49.5<0;0>:f      r49.5<0>:f       {F@3}
        mad (1|M0)               r6.0<1>:f     r6.0<0;0>:f       r51.5<0;0>:f      r51.5<0>:f       {F@3}
        mad (1|M0)               r2.1<1>:f     r2.1<0;0>:f       r51.6<0;0>:f      r51.6<0>:f       {F@3}
        mov (1|M0)               r9.2<2>:hf    r7.0<0;1,0>:f                    {F@3}
        mov (1|M0)               r12.0<2>:hf   r6.0<0;1,0>:f                    {F@3}
        mov (1|M0)               r11.0<2>:hf   r2.1<0;1,0>:f                    {F@3}
        mul (1|M0)               r7.0<1>:f     r50.7<0;1,0>:f    r50.7<0;1,0>:f  
        mul (1|M0)               r6.0<1>:f     r48.6<0;1,0>:f    r48.6<0;1,0>:f   {Compacted}
        mul (1|M0)               r2.1<1>:f     r48.7<0;1,0>:f    r48.7<0;1,0>:f  
        add (1|M0)               r12.0<1>:hf   r12.0<0;1,0>:hf   r9.2<0;1,0>:hf   {F@5}
        mov (1|M0)               r11.2<2>:hf   r6.0<0;1,0>:f                    {F@3}
        mov (1|M0)               r9.2<2>:hf    r7.0<0;1,0>:f                   
        mov (1|M0)               r10.4<2>:hf   r2.1<0;1,0>:f                    {F@4}
        mov (1|M0)               r8.1<1>:f     r11.2<0;1,0>:hf                  {F@3}
        mov (1|M0)               r1.2<1>:f     r9.2<0;1,0>:hf                   {F@3}
        mov (1|M0)               r6.0<1>:f     r10.4<0;1,0>:hf                  {F@3}
        mad (1|M0)               r8.1<1>:f     r8.1<0;0>:f       r49.6<0;0>:f      r49.6<0>:f       {F@3}
        mad (1|M0)               r1.2<1>:f     r1.2<0;0>:f       r51.7<0;0>:f      r51.7<0>:f       {F@3}
        mad (1|M0)               r6.0<1>:f     r6.0<0;0>:f       r49.7<0;0>:f      r49.7<0>:f       {F@3}
        mov (1|M0)               r12.2<2>:hf   r8.1<0;1,0>:f                    {F@3}
        mov (1|M0)               r10.2<2>:hf   r1.2<0;1,0>:f                    {F@3}
        mov (1|M0)               r11.2<2>:hf   r6.0<0;1,0>:f                    {F@3}
        add (1|M0)               r11.0<1>:hf   r11.0<0;1,0>:hf   r12.2<0;1,0>:hf  {F@3}
        add (1|M0)               r10.2<1>:hf   r10.2<0;1,0>:hf   r11.2<0;1,0>:hf  {F@2}
        add (1|M0)               r8.0<1>:hf    r8.0<0;1,0>:hf    r9.0<0;1,0>:hf  
        add (1|M0)               r3.6<1>:hf    r3.6<0;1,0>:hf    r12.0<0;1,0>:hf 
        add (1|M0)               r2.0<1>:hf    r2.0<0;1,0>:hf    r11.0<0;1,0>:hf  {F@4}
        add (1|M0)               r10.0<1>:hf   r10.0<0;1,0>:hf   r10.2<0;1,0>:hf  {F@4}
        add (1|M0)               r8.0<1>:hf    r8.0<0;1,0>:hf    r2.0<0;1,0>:hf   {F@2}
        add (1|M0)               r3.6<1>:hf    r3.6<0;1,0>:hf    r10.0<0;1,0>:hf  {F@2}
        cmp (1|M0)    (eq)f0.1   null<1>:d     r110.2<0;1,0>:d   0:w              
        add (1|M0)               r8.0<1>:hf    r8.0<0;1,0>:hf    r3.6<0;1,0>:hf   {F@1}
(W)     mov (1|M0)               r5.7<1>:uw    0x1:uw                             
        mov (1|M0)               r1.2<1>:f     r8.0<0;1,0>:hf                   {F@1}
(f0.1)  sel (1|M0)               r7.0<1>:uw    r5.7<0;1,0>:uw    0x0:uw              {I@1}
        sel (1|M0)    (ge)f0.0   r1.2<1>:f     r1.2<0;1,0>:f     6.198883e-05:f               {F@1}
(f1.0)  sel (1|M0)               r2.0<1>:uw    r5.7<0;1,0>:uw    0x0:uw             
        sync.nop                             null                             {Compacted,F@1}
        math.sqt (1|M0)          r1.2<1>:f     r1.2<0;1,0>:f                    {$13}
        and (1|M0)    (ne)f0.1   null<1>:uw    r7.0<0;1,0>:uw    r2.0<0;1,0>:uw   {I@1}
        math.inv (1|M0)          r1.2<1>:f     r1.2<0;1,0>:f                    {$13}
(W)     and (1|M0)               f1.1<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
        mov (1|M0)               r6.0<2>:hf    r1.2<0;1,0>:f                    {$13.dst}
        mov (1|M0)               r110.6<1>:f   r6.0<0;1,0>:hf                   {F@1}
(f1.1.any16h) goto (16|M0)                   L10264                  L10264                
L9320:
        mul (16|M0)              r50.0<1>:f    r110.6<0;1,0>:f   r50.0<1;1,0>:f   {Compacted,F@1}
        mul (16|M0)              r48.0<1>:f    r110.6<0;1,0>:f   r48.0<1;1,0>:f   {Compacted}
        mov (8|M0)               r6.0<1>:hf    r50.0<1;1,0>:f                   {F@2}
        mov (8|M0)               r6.8<1>:hf    r51.0<1;1,0>:f                  
        mov (8|M0)               r9.0<1>:hf    r48.0<1;1,0>:f                   {F@3}
        mov (8|M0)               r9.8<1>:hf    r49.0<1;1,0>:f                  
        mov (8|M0)               r7.0<1>:f     (abs)r6.0<1;1,0>:hf              {A@3}
        mov (8|M0)               r8.0<1>:f     (abs)r6.8<1;1,0>:hf              {F@4}
        mov (8|M0)               r10.0<1>:f    (abs)r9.0<1;1,0>:hf              {F@4}
        mov (8|M0)               r11.0<1>:f    (abs)r9.8<1;1,0>:hf              {F@4}
        sel (16|M0)   (lt)f0.0   r7.0<1>:f     r7.0<1;1,0>:f     448.0:f               {Compacted,F@3}
        sel (16|M0)   (lt)f0.0   r10.0<1>:f    r10.0<1;1,0>:f    448.0:f               {Compacted,F@2}
        shr (16|M0)              r12.0<1>:ud   r7.0<1;1,0>:ud    0x17:uw              {F@2}
        sync.allrd                           ($9,$10)                
        shr (16|M0)              r14.0<1>:ud   r10.0<1;1,0>:ud   0x17:uw              {F@1}
        sync.nop                             null                             {Compacted,$5.src}
        sel (16|M0)   (ge)f0.0   r16.0<2>:ub   r12.0<4;1,0>:ub   0x79:uw              {I@2}
        sel (16|M0)   (ge)f0.0   r17.0<2>:ub   r14.0<4;1,0>:ub   0x79:uw              {I@2}
        mov (16|M0)              r18.0<1>:d    r16.0<2;1,0>:ub                  {I@2}
        mov (16|M0)              r20.0<1>:d    r17.0<2;1,0>:ub                  {I@2}
        shl (16|M0)              r18.0<1>:d    r18.0<1;1,0>:d    23:w               {Compacted,I@2}
        shl (16|M0)              r20.0<1>:d    r20.0<1;1,0>:d    23:w               {Compacted,I@2}
        add (16|M0)              r22.0<1>:d    r18.0<1;1,0>:d    -25165824:d               {I@2}
        add (16|M0)              r24.0<1>:d    r20.0<1;1,0>:d    -25165824:d               {I@2}
        add (16|M0)              r18.0<1>:d    -r18.0<1;1,0>:d   -2139095040:d              
        add (16|M0)              r20.0<1>:d    -r20.0<1;1,0>:d   -2139095040:d              
        mul (16|M0)              acc0.0<1>:f   r7.0<1;1,0>:f     r18.0<1;1,0>:f   {Compacted,I@2}
        mul (16|M0)              acc2.0<1>:f   r10.0<1;1,0>:f    r20.0<1;1,0>:f   {Compacted,I@1}
        rnde (16|M0)             acc0.0<1>:f   acc0.0<1;1,0>:f                 
        rnde (16|M0)             acc2.0<1>:f   acc2.0<1;1,0>:f                 
        cmp (16|M0)   (lt)f1.1   null<1>:f     r50.0<1;1,0>:f    0xB3000000:f              
        cmp (16|M0)   (lt)f1.0   null<1>:f     r48.0<1;1,0>:f    0xB3000000:f               {Compacted}
        mul (16|M0)              acc0.0<1>:f   acc0.0<1;1,0>:f   r22.0<1;1,0>:f   {Compacted}
        mul (16|M0)              acc2.0<1>:f   acc2.0<1;1,0>:f   r24.0<1;1,0>:f   {Compacted}
        mov (16|M0)              r12.0<1>:f    (abs)acc0.0<1;1,0>:f             {Compacted}
        mov (16|M0)              r14.0<1>:f    (abs)acc2.0<1;1,0>:f             {Compacted}
(f1.1)  or (16|M0)               r12.0<1>:d    r12.0<1;1,0>:d    -2147483648:d               {F@2}
(f1.0)  or (16|M0)               r14.0<1>:d    r14.0<1;1,0>:d    -2147483648:d               {F@1}
        mov (1|M0)               r110.6<1>:d   0:w                              
        mov (8|M0)               r52.0<1>:hf   r12.0<1;1,0>:f                   {I@3}
        mov (8|M0)               r52.8<1>:hf   r13.0<1;1,0>:f                  
        mov (8|M0)               r53.0<1>:hf   r14.0<1;1,0>:f                   {I@2}
        mov (8|M0)               r53.8<1>:hf   r15.0<1;1,0>:f                  
L9896:
        shr (1|M0)               r2.0<1>:ud    r110.6<0;1,0>:ud  0x2:uw              {I@1}
        shl (1|M0)               r2.1<1>:ud    r110.6<0;1,0>:ud  0x3:uw             
        and (1|M0)               r2.0<1>:ud    r2.0<0;1,0>:ud    0x4:uw              {I@2}
        bfn.0xEA (1|M0)          r3.3<1>:ud    r86.3<0;0>:ud     r110.6<0;0>:ud    0x1:uw              // s0|s1&s2
        and (1|M0)               r2.1<1>:ud    r2.1<0;1,0>:ud    0x70:uw              {I@3}
        add (1|M0)               r2.0<1>:ud    r2.0<0;1,0>:ud    r122.3<0;1,0>:ud {Compacted,I@3}
        bfn.0xFE (1|M0)          r3.3<1>:ud    0x4000:uw               r3.3<0;0>:ud      r2.1<0>:ud       {I@2} // s0|s1|s2
        shl (1|M0)               r2.0<1>:ud    r2.0<0;1,0>:ud    0x8:uw              {I@2}
        shl (1|M0)               r1.3<1>:w     r110.12<0;1,0>:w  1:w              
        add (1|M0)               r6.0<1>:ud    r3.3<0;1,0>:ud    r2.0<0;1,0>:ud   {Compacted,I@2}
        add (1|M0)               r110.6<1>:ud  r110.6<0;1,0>:ud  0x1:uw             
        shl (1|M0)               r7.0<1>:d     r6.0<0;1,0>:d     1:w               {Compacted,I@2}
        cmp (1|M0)    (eq)f0.1   null<1>:d     r110.6<0;1,0>:d   32:w               {I@2}
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0x680:uw              {A@1}
        shr (1|M0)               r6.2<1>:ud    r6.0<0;1,0>:ud    0x1F:uw             
        addc (1|M0)              r8.0<1>:ud    r122.0<0;1,0>:ud  r7.0<0;1,0>:ud   {AccWrEn,I@4}
        or (1|M0)                r7.1<1>:d     r6.2<0;1,0>:d     0:w               {I@2}
(W)     and (1|M0)               f1.0<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        sync.nop                             null                             {Compacted,$2.src}
        mov (1|M0)               r10.0<1>:f    r8.0<0;1,0>:f                    {Compacted,I@4}
        mov (1|M0)               r12.0<1>:d    r[a0.0]<0;1,0>:uw                {A@2}
        add3 (1|M0)              r10.1<1>:d    r9.0<0;0>:d       r122.1<0;0>:d     r7.1<0>:d        {A@1}
        send.ugm (1|M0)          null     r10     r12:1   0x0            0x04000B84           {A@1,$2} // wr:2+1, rd:0; store.ugm.d16u32.a64
(f1.0.any16h) goto (16|M0)                   L10264                  L12320                
L10248:
        goto.b (16|M0)                       L10264                  L9896                
L10264:
        join (16|M0)                         L11472                                
L10280:
        send.ugm (1|M0)          r2       r94     null:0  0x0            0x04100580           {$14} // wr:2+0, rd:1; load.ugm.d32.a64
        mul (16|M0)              r50.0<1>:f    r110.6<0;1,0>:f   r50.0<1;1,0>:f   {Compacted}
        mul (16|M0)              r48.0<1>:f    r110.6<0;1,0>:f   r48.0<1;1,0>:f   {Compacted}
        mov (8|M0)               r6.0<1>:hf    r50.0<1;1,0>:f                   {F@2}
        mov (8|M0)               r6.8<1>:hf    r51.0<1;1,0>:f                  
        mov (8|M0)               r7.0<1>:hf    r48.0<1;1,0>:f                   {F@3}
        mov (8|M0)               r7.8<1>:hf    r49.0<1;1,0>:f                  
        mov (8|M0)               r8.0<1>:f     r6.0<1;1,0>:hf                   {F@4}
        mov (8|M0)               r9.0<1>:f     r6.8<1;1,0>:hf                   {F@4}
        sync.nop                             null                             {Compacted,$2.src}
        mov (8|M0)               r10.0<1>:f    r7.0<1;1,0>:hf                   {F@4}
        mov (8|M0)               r11.0<1>:f    r7.8<1;1,0>:hf                   {F@4}
        mov (1|M0)               r1.4<2>:hf    r2.0<0;1,0>:f                    {$14.dst}
        mov (1|M0)               r3.3<1>:f     r1.4<0;1,0>:hf                   {F@1}
        mul (16|M0)              r8.0<1>:f     r3.3<0;1,0>:f     r8.0<1;1,0>:f    {Compacted,F@1}
        mul (16|M0)              r10.0<1>:f    r3.3<0;1,0>:f     r10.0<1;1,0>:f   {Compacted}
        mov (8|M0)               r12.0<1>:hf   r8.0<1;1,0>:f                    {F@2}
        mov (8|M0)               r12.8<1>:hf   r9.0<1;1,0>:f                   
        sync.nop                             null                             {Compacted,$9.src}
        mov (8|M0)               r15.0<1>:hf   r10.0<1;1,0>:f                   {F@3}
        mov (8|M0)               r15.8<1>:hf   r11.0<1;1,0>:f                  
        mov (8|M0)               r13.0<1>:f    (abs)r12.0<1;1,0>:hf             {F@4}
        sync.nop                             null                             {Compacted,$10.src}
        mov (8|M0)               r14.0<1>:f    (abs)r12.8<1;1,0>:hf             {F@4}
        sync.nop                             null                             {Compacted,$5.src}
        mov (8|M0)               r16.0<1>:f    (abs)r15.0<1;1,0>:hf             {F@4}
        mov (8|M0)               r17.0<1>:f    (abs)r15.8<1;1,0>:hf             {F@4}
        sel (16|M0)   (lt)f0.0   r13.0<1>:f    r13.0<1;1,0>:f    448.0:f               {Compacted,F@3}
        sel (16|M0)   (lt)f0.0   r16.0<1>:f    r16.0<1;1,0>:f    448.0:f               {Compacted,F@2}
        shr (16|M0)              r6.0<1>:ud    r13.0<1;1,0>:ud   0x17:uw              {F@2}
        shr (16|M0)              r18.0<1>:ud   r16.0<1;1,0>:ud   0x17:uw              {F@1}
        sel (16|M0)   (ge)f0.0   r20.0<2>:ub   r6.0<4;1,0>:ub    0x79:uw              {I@2}
        sel (16|M0)   (ge)f0.0   r21.0<2>:ub   r18.0<4;1,0>:ub   0x79:uw              {I@2}
        mov (16|M0)              r22.0<1>:d    r20.0<2;1,0>:ub                  {I@2}
        mov (16|M0)              r24.0<1>:d    r21.0<2;1,0>:ub                  {I@2}
        shl (16|M0)              r22.0<1>:d    r22.0<1;1,0>:d    23:w               {Compacted,I@2}
        shl (16|M0)              r24.0<1>:d    r24.0<1;1,0>:d    23:w               {Compacted,I@2}
        add (16|M0)              r26.0<1>:d    r22.0<1;1,0>:d    -25165824:d               {I@2}
        add (16|M0)              r28.0<1>:d    r24.0<1;1,0>:d    -25165824:d               {I@2}
        add (16|M0)              r22.0<1>:d    -r22.0<1;1,0>:d   -2139095040:d              
        add (16|M0)              r24.0<1>:d    -r24.0<1;1,0>:d   -2139095040:d              
        mul (16|M0)              acc0.0<1>:f   r13.0<1;1,0>:f    r22.0<1;1,0>:f   {Compacted,I@2}
        mul (16|M0)              acc2.0<1>:f   r16.0<1;1,0>:f    r24.0<1;1,0>:f   {Compacted,I@1}
        rnde (16|M0)             acc0.0<1>:f   acc0.0<1;1,0>:f                 
        rnde (16|M0)             acc2.0<1>:f   acc2.0<1;1,0>:f                 
        cmp (16|M0)   (lt)f1.1   null<1>:f     r8.0<1;1,0>:f     0xB3000000:f              
        cmp (16|M0)   (lt)f1.0   null<1>:f     r10.0<1;1,0>:f    0xB3000000:f               {Compacted}
        mul (16|M0)              acc0.0<1>:f   acc0.0<1;1,0>:f   r26.0<1;1,0>:f   {Compacted}
        mul (16|M0)              acc2.0<1>:f   acc2.0<1;1,0>:f   r28.0<1;1,0>:f   {Compacted}
        mov (8|M0)               r20.0<2>:ud   r86.6<0;1,0>:ud                 
        mov (16|M0)              r6.0<1>:f     (abs)acc0.0<1;1,0>:f             {Compacted}
        mov (16|M0)              r18.0<1>:f    (abs)acc2.0<1;1,0>:f             {Compacted}
        mov (8|M0)               r20.1<2>:ud   r86.7<0;1,0>:ud                 
(f1.1)  or (16|M0)               r6.0<1>:d     r6.0<1;1,0>:d     -2147483648:d               {F@2}
(f1.0)  or (16|M0)               r18.0<1>:d    r18.0<1;1,0>:d    -2147483648:d               {F@1}
        addc (8|M0)              r13.0<1>:ud   r20.0<2;1,0>:ud   r120.0<2;1,0>:ud {AccWrEn,Compacted,I@3}
        mov (8|M0)               r8.0<1>:d     r120.1<2;1,0>:d                 
        mov (8|M0)               r12.0<1>:hf   r6.0<1;1,0>:f                    {I@4}
        mov (8|M0)               r15.0<1>:hf   r18.0<1;1,0>:f                   {I@3}
        mov (8|M0)               r15.8<1>:hf   r19.0<1;1,0>:f                  
        mov (8|M0)               r14.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mov (8|M0)               r18.0<2>:ud   r110.4<0;1,0>:ud                 {A@1}
        addc (8|M0)              r6.0<1>:ud    r20.0<2;1,0>:ud   r118.0<2;1,0>:ud {AccWrEn,Compacted}
        mov (8|M0)               r18.1<2>:ud   r110.5<0;1,0>:ud                
        mov (8|M0)               r12.8<1>:hf   r7.0<1;1,0>:f                   
        mov (8|M0)               r22.0<2>:d    r13.0<1;1,0>:d                   {I@6}
        add3 (8|M0)              r9.0<1>:d     r14.0<1;0>:d      r20.1<4;2>:d      r8.0<1>:d        {I@5}
        mov (8|M0)               r7.0<1>:ud    acc0.0<1;1,0>:ud                 {Compacted,F@1}
        addc (8|M0)              r13.0<1>:ud   r18.0<2;1,0>:ud   r120.0<2;1,0>:ud {AccWrEn,Compacted,I@4}
        mov (8|M0)               r10.0<1>:d    r118.1<2;1,0>:d                 
        mov (8|M0)               r24.0<2>:d    r6.0<1;1,0>:d                   
        mov (8|M0)               r22.1<2>:d    r9.0<1;1,0>:d                    {I@5}
        mov (8|M0)               r9.0<1>:ud    acc0.0<1;1,0>:ud                 {Compacted}
        addc (8|M0)              r6.0<1>:ud    r18.0<2;1,0>:ud   r118.0<2;1,0>:ud {AccWrEn,Compacted}
        add3 (8|M0)              r11.0<1>:d    r7.0<1;0>:d       r20.1<4;2>:d      r10.0<1>:d       {I@5}
        mov (8|M0)               r7.0<1>:ud    acc0.0<1;1,0>:ud                 {Compacted}
        mov (16|M0)              r16.0<1>:d    r12.0<1;1,0>:uw                 
        add3 (8|M0)              r14.0<1>:d    r9.0<1;0>:d       r18.1<4;2>:d      r8.0<1>:d        {I@5}
        mov (8|M0)               r24.1<2>:d    r11.0<1;1,0>:d                   {I@4}
        add3 (8|M0)              r11.0<1>:d    r7.0<1;0>:d       r18.1<4;2>:d      r10.0<1>:d       {I@4}
        send.ugm (16|M0)         null     r22     r16:2   0x0            0x08000B84           {A@2,$15} // wr:4+2, rd:0; store.ugm.d16u32.a64
        mov (8|M0)               r26.0<2>:d    r13.0<1;1,0>:d                  
        mov (8|M0)               r28.0<2>:d    r6.0<1;1,0>:d                   
        mov (16|M0)              r16.0<1>:d    r15.0<1;1,0>:uw                  {$15.src}
        mov (8|M0)               r26.1<2>:d    r14.0<1;1,0>:d                  
        mov (8|M0)               r28.1<2>:d    r11.0<1;1,0>:d                   {I@5}
        send.ugm (16|M0)         null     r26     r16:2   0x0            0x08000B84           {A@1,$3} // wr:4+2, rd:0; store.ugm.d16u32.a64
        goto (16|M0)                         L11472                  L12320                
L11472:
        join (16|M0)                         L12320                                
L11488:
        sel (16|M0)   (lt)f0.0   r6.0<1>:f     (abs)r24.0<1;1,0>:f  448.0:f            {Compacted,$1.dst}
        sel (16|M0)   (lt)f0.0   r8.0<1>:f     (abs)r26.0<1;1,0>:f  448.0:f            {Compacted}
        sync.allrd                           ($2,$4,$11)                
        shr (16|M0)              r10.0<1>:ud   r6.0<1;1,0>:ud    0x17:uw              {F@2}
        sync.nop                             null                             {Compacted,$8.src}
        shr (16|M0)              r12.0<1>:ud   r8.0<1;1,0>:ud    0x17:uw              {F@1}
        sync.nop                             null                             {Compacted,$10.src}
        sel (16|M0)   (ge)f0.0   r14.0<2>:ub   r10.0<4;1,0>:ub   0x79:uw              {I@2}
        sync.nop                             null                             {Compacted,$9.src}
        sel (16|M0)   (ge)f0.0   r15.0<2>:ub   r12.0<4;1,0>:ub   0x79:uw              {I@2}
        sync.allrd                           ($3,$5)                
        mov (16|M0)              r16.0<1>:d    r14.0<2;1,0>:ub                  {I@2}
        mov (16|M0)              r18.0<1>:d    r15.0<2;1,0>:ub                  {I@2}
        shl (16|M0)              r16.0<1>:d    r16.0<1;1,0>:d    23:w               {Compacted,I@2}
        shl (16|M0)              r18.0<1>:d    r18.0<1;1,0>:d    23:w               {Compacted,I@2}
        add (16|M0)              r20.0<1>:d    r16.0<1;1,0>:d    -25165824:d               {I@2}
        add (16|M0)              r22.0<1>:d    r18.0<1;1,0>:d    -25165824:d               {I@2}
        add (16|M0)              r16.0<1>:d    -r16.0<1;1,0>:d   -2139095040:d              
        add (16|M0)              r18.0<1>:d    -r18.0<1;1,0>:d   -2139095040:d              
        mul (16|M0)              acc0.0<1>:f   r6.0<1;1,0>:f     r16.0<1;1,0>:f   {Compacted,I@2}
        mul (16|M0)              acc2.0<1>:f   r8.0<1;1,0>:f     r18.0<1;1,0>:f   {Compacted,I@1}
        rnde (16|M0)             acc0.0<1>:f   acc0.0<1;1,0>:f                 
        rnde (16|M0)             acc2.0<1>:f   acc2.0<1;1,0>:f                 
        cmp (16|M0)   (lt)f0.1   null<1>:f     r24.0<1;1,0>:f    0.0:f              
        cmp (16|M0)   (lt)f1.1   null<1>:f     r26.0<1;1,0>:f    0.0:f              
        mul (16|M0)              acc0.0<1>:f   acc0.0<1;1,0>:f   r20.0<1;1,0>:f   {Compacted}
        mul (16|M0)              acc2.0<1>:f   acc2.0<1;1,0>:f   r22.0<1;1,0>:f   {Compacted}
        mov (16|M0)              r10.0<1>:f    (abs)acc0.0<1;1,0>:f             {Compacted}
        mov (16|M0)              r12.0<1>:f    (abs)acc2.0<1;1,0>:f             {Compacted}
(f0.1)  or (16|M0)               r10.0<1>:d    r10.0<1;1,0>:d    -2147483648:d               {F@2}
(f1.1)  or (16|M0)               r12.0<1>:d    r12.0<1;1,0>:d    -2147483648:d               {F@1}
        mov (1|M0)               r110.6<1>:d   0:w                              
        mov (8|M0)               r54.0<1>:hf   r10.0<1;1,0>:f                   {I@3}
        mov (8|M0)               r54.8<1>:hf   r11.0<1;1,0>:f                  
        mov (8|M0)               r55.0<1>:hf   r12.0<1;1,0>:f                   {I@2}
        mov (8|M0)               r55.8<1>:hf   r13.0<1;1,0>:f                  
L11960:
        shr (1|M0)               r2.0<1>:ud    r110.6<0;1,0>:ud  0x4:uw              {I@1}
        shl (1|M0)               r2.1<1>:ud    r110.6<0;1,0>:ud  0x4:uw             
        shl (1|M0)               r3.3<1>:ud    r110.6<0;1,0>:ud  0x1:uw             
        bfn.0xEA (1|M0)          r2.0<1>:ud    r2.0<0;0>:ud      r94.6<0;0>:ud     0x1FFE:uw              {I@3} // s0|s1&s2
        bfn.0xEA (1|M0)          r2.1<1>:ud    r94.7<0;0>:ud     r2.1<0;0>:ud      0x80:uw              {I@3} // s0|s1&s2
        and (1|M0)               r3.3<1>:ud    r3.3<0;1,0>:ud    0xE:uw              {I@3}
        shl (1|M0)               r2.0<1>:ud    r2.0<0;1,0>:ud    0x8:uw              {I@3}
        bfn.0xFE (1|M0)          r2.1<1>:ud    0x4800:uw               r2.1<0;0>:ud      r3.3<0>:ud       {I@2} // s0|s1|s2
        shl (1|M0)               r1.3<1>:w     r110.12<0;1,0>:w  1:w              
        add (1|M0)               r6.0<1>:ud    r2.1<0;1,0>:ud    r2.0<0;1,0>:ud   {Compacted,I@2}
        add (1|M0)               r110.6<1>:ud  r110.6<0;1,0>:ud  0x1:uw             
        shl (1|M0)               r7.0<1>:d     r6.0<0;1,0>:d     1:w               {Compacted,I@2}
        cmp (1|M0)    (eq)f1.0   null<1>:d     r110.6<0;1,0>:d   32:w               {I@2}
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0x6C0:uw              {A@1}
        shr (1|M0)               r6.2<1>:ud    r6.0<0;1,0>:ud    0x1F:uw             
        addc (1|M0)              r8.0<1>:ud    r122.0<0;1,0>:ud  r7.0<0;1,0>:ud   {AccWrEn,I@4}
        or (1|M0)                r7.1<1>:d     r6.2<0;1,0>:d     0:w               {I@2}
(W)     and (1|M0)               f0.1<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        sync.nop                             null                             {Compacted,$4.src}
        mov (1|M0)               r10.0<1>:f    r8.0<0;1,0>:f                    {Compacted,I@4}
        mov (1|M0)               r12.0<1>:d    r[a0.0]<0;1,0>:uw                {A@2}
        add3 (1|M0)              r10.1<1>:d    r9.0<0;0>:d       r122.1<0;0>:d     r7.1<0>:d        {A@1}
        send.ugm (1|M0)          null     r10     r12:1   0x0            0x04000B84           {A@1,$4} // wr:2+1, rd:0; store.ugm.d16u32.a64
(~f0.1.any16h) goto.b (16|M0)                L12320                  L11960                
L12320:
        join (16|M0)                         L12576                                
L12336:
(W)     send.slm (1|M0)          r6       r0      null:0  0x0            0x0210001F           {$13} // wr:1+0, rd:1; fence.slm.none.group
(W)     mov (1|M0)               r7.2<1>:f     0.0:f                               {Compacted}
(W)     mov (2|M0)               r7.10<1>:ub   r0.11<0;1,0>:ub                  {F@1}
(W)     mov (8|M0)               null<1>:ud    r6.0<1;1,0>:ud                   {$13.dst}
(W)     send.gtwy (1|M0)         null     r7      null:0  0x0            0x02000004           {A@2,$0} // wr:1+0, rd:0; signal barrier
(W)     sync.bar                             null                            
        addc (1|M0)              r2.0<1>:ud    r110.2<0;1,0>:ud  0x1:ud              {AccWrEn}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r1.2<1>:d     r2.0<0;1,0>:d                    {I@2}
        add3 (1|M0)              r1.3<1>:d     r8.0<0;0>:d       r110.3<0;0>:d     0:w               {I@2}
        cmp (1|M0)    (eq)f1.0   null<1>:d     r1.3<0;1,0>:d     0:w               {I@1}
(f1.0)  cmp (1|M0)    (eq)f1.0   null<1>:d     r1.2<0;1,0>:d     3:w              
(W)     and (1|M0)               f1.1<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
(f1.1.any16h) goto (16|M0)                   L12576                  L12576                
L12544:
(W)     mov (2|M0)               r110.2<1>:ud  r1.2<1;1,0>:ud                  
        goto.b (16|M0)                       L12576                  L7120                
L12576:
        join (16|M0)                         L40224                                
L12592:
        cmp (1|M0)    (eq)f0.1   null<1>:d     r2.6<0;1,0>:d     3:w              
(W)     and (1|M0)               f1.0<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(f1.0.any16h) goto (16|M0)                   L39176                  L39176                
L12640:
        cmp (1|M0)    (lt)f1.1   null<1>:uw    r1.0<0;1,0>:uw    0x100:uw             
        addc (1|M0)              r2.0<1>:ud    r122.0<0;1,0>:ud  0x8000:ud              {AccWrEn}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r7.0<1>:ud    r122.0<0;1,0>:ud  0xA000:ud              {AccWrEn,$0.src}
(W)     and (1|M0)               f0.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r86.6<1>:d    r2.0<0;1,0>:d                    {I@5}
        add3 (1|M0)              r86.7<1>:d    r6.0<0;0>:d       r122.1<0;0>:d     0:w               {I@5}
        mov (1|M0)               r94.6<1>:d    r7.0<0;1,0>:d                    {I@5}
        add3 (1|M0)              r94.7<1>:d    r8.0<0;0>:d       r122.1<0;0>:d     0:w               {I@4}
(~f0.1.any16h) goto (16|M0)                  L16400                  L16400                
L12800:
        and (1|M0)               r1.2<1>:ud    r122.3<0;1,0>:ud  0x3:uw             
        shr (1|M0)               r1.3<1>:ud    r94.2<0;1,0>:ud   0x4:uw             
        shl (1|M0)               r2.0<1>:ud    r1.2<0;1,0>:ud    0x8:uw              {I@2}
        shl (1|M0)               r1.4<1>:d     r94.3<0;1,0>:d    28:w              
        shl (1|M0)               r6.0<1>:d     r2.0<0;1,0>:d     1:w               {Compacted,I@2}
        shr (1|M0)               r3.3<1>:ud    r2.0<0;1,0>:ud    0x1F:uw             
        addc (1|M0)              r7.0<1>:ud    r86.6<0;1,0>:ud   r6.0<0;1,0>:ud   {AccWrEn,I@2}
        shl (1|M0)               r6.0<1>:ud    r1.2<0;1,0>:ud    0x4:uw             
        mov (1|M0)               r94.0<1>:f    r7.0<0;1,0>:f                    {Compacted,I@2}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        sync.nop                             null                             {Compacted,$1.src}
        addc (1|M0)              r9.0<1>:ud    r94.0<0;1,0>:ud   0x100:ud              {AccWrEn,F@1}
        or (1|M0)                r6.1<1>:d     r3.3<0;1,0>:d     0:w              
        sync.nop                             null                             {Compacted,$4.src}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,$2.src}
        addc (1|M0)              r11.0<1>:ud   r94.0<0;1,0>:ud   0x800:ud              {AccWrEn,$11.src}
        shl (1|M0)               r7.0<1>:d     r6.0<0;1,0>:d     2:w               {Compacted,I@6}
        mov (1|M0)               r88.0<1>:f    r11.0<0;1,0>:f                   {Compacted,I@2}
        mov (1|M0)               r12.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,$8.src}
        addc (1|M0)              r2.0<1>:ud    r88.0<0;1,0>:ud   0x100:ud              {AccWrEn,F@1}
        shr (1|M0)               r3.3<1>:ud    r6.0<0;1,0>:ud    0x1E:uw             
        add3 (1|M0)              r94.1<1>:d    r8.0<0;0>:d       r86.7<0;0>:d      r6.1<0>:d       
        mov (1|M0)               r13.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r8.0<1>:ud    r94.6<0;1,0>:ud   r7.0<0;1,0>:ud   {AccWrEn,I@6}
        mov (1|M0)               r89.0<1>:f    r9.0<0;1,0>:f                    {Compacted}
        or (1|M0)                r7.1<1>:d     r3.3<0;1,0>:d     0:w               {I@4}
        add3 (1|M0)              r88.1<1>:d    r12.0<0;0>:d      r94.1<0;0>:d      0:w               {I@4}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,F@1}
        mov (16|M0)              r102.0<1>:f   0.0:f                               {Compacted}
        mov (16|M0)              r104.0<1>:f   0.0:f                               {Compacted}
        mov (16|M0)              r106.0<1>:f   0.0:f                               {Compacted}
        mov (16|M0)              r108.0<1>:f   0.0:f                               {Compacted}
        shr (1|M0)               r86.5<1>:ud   r94.3<0;1,0>:ud   0x4:uw             
        or (1|M0)                r86.4<1>:d    r1.3<0;1,0>:d     r1.4<0;1,0>:d   
        mov (1|M0)               r87.0<1>:f    r2.0<0;1,0>:f                    {Compacted}
        add3 (1|M0)              r89.1<1>:d    r10.0<0;0>:d      r94.1<0;0>:d      0:w              
        mov (1|M0)               r86.6<1>:d    r8.0<0;1,0>:d                    {I@7}
        add3 (1|M0)              r87.1<1>:d    r13.0<0;0>:d      r88.1<0;0>:d      0:w               {I@6}
        add3 (1|M0)              r86.7<1>:d    r9.0<0;0>:d       r94.7<0;0>:d      r7.1<0>:d        {I@6}
L13288:
        shr (1|M0)               r1.2<1>:ud    r86.4<0;1,0>:ud   0x2:uw              {I@5}
        shl (1|M0)               r1.3<1>:d     r86.5<0;1,0>:d    30:w              
        shr (1|M0)               r2.1<1>:ud    r86.5<0;1,0>:ud   0x2:uw             
        or (1|M0)                r2.0<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {A@1}
        shl (1|M0)               r3.3<1>:d     r2.1<0;1,0>:d     9:w               {I@2}
        shl (1|M0)               r6.1<1>:d     r2.0<0;1,0>:d     9:w               {Compacted,I@2}
        shr (1|M0)               r6.0<1>:ud    r2.0<0;1,0>:ud    0x17:uw             
        shl (1|M0)               r7.2<1>:d     r6.1<0;1,0>:d     1:w               {I@2}
        or (1|M0)                r6.2<1>:d     r3.3<0;1,0>:d     r6.0<0;1,0>:d    {I@2}
        sync.nop                             null                             {Compacted,$5.src}
        addc (1|M0)              r8.0<1>:ud    r86.0<0;1,0>:ud   r7.2<0;1,0>:ud   {AccWrEn,I@2}
        shr (1|M0)               r7.1<1>:ud    r6.1<0;1,0>:ud    0x1F:uw             
        shl (1|M0)               r7.0<1>:d     r6.2<0;1,0>:d     1:w               {Compacted,I@3}
        sync.nop                             null                             {Compacted,$7.src}
        mov (1|M0)               r10.0<1>:f    r8.0<0;1,0>:f                    {Compacted,I@3}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        or (1|M0)                r7.3<1>:d     r7.0<0;1,0>:d     r7.1<0;1,0>:d    {I@2}
        addc (1|M0)              r19.0<1>:ud   r10.0<0;1,0>:ud   0x100:ud              {AccWrEn,F@1}
        add3 (1|M0)              r10.1<1>:d    r9.0<0;0>:d       r86.1<0;0>:d      r7.3<0>:d        {I@2}
        mov (1|M0)               r20.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r21.0<1>:f    r19.0<0;1,0>:f                   {Compacted,I@3}
        add3 (1|M0)              r21.1<1>:d    r20.0<0;0>:d      r10.1<0;0>:d      0:w               {I@1}
        send.ugm (1|M0)          r30      r94     null:0  0x0            0x0280E780           {$9} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        send.ugm (1|M0)          r38      r89     null:0  0x0            0x0280E780           {$8} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        sync.nop                             null                             {Compacted,$3.src}
        send.ugm (1|M0)          r11      r10     null:0  0x0            0x0280E780           {$10} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        send.ugm (1|M0)          r22      r21     null:0  0x0            0x0280E780           {A@1,$1} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        addc (1|M0)              r6.0<1>:ud    r10.0<0;1,0>:ud   0x200:ud              {AccWrEn}
        shl (1|M0)               r1.4<1>:d     r2.0<0;1,0>:d     10:w               {Compacted}
        mov (1|M0)               r8.0<1>:f     r6.0<0;1,0>:f                    {Compacted,I@2}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r9.0<1>:ud    r8.0<0;1,0>:ud    0x100:ud              {AccWrEn,F@1}
        add3 (1|M0)              r8.1<1>:d     r7.0<0;0>:d       r10.1<0;0>:d      0:w               {I@2}
        mov (1|M0)               r19.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        send.ugm (1|M0)          r78      r8      null:0  0x0            0x0280E780           {A@2,$12} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        mov (1|M0)               r20.0<1>:f    r9.0<0;1,0>:f                    {Compacted}
        add3 (1|M0)              r20.1<1>:d    r19.0<0;0>:d      r8.1<0;0>:d       0:w               {I@1}
        shl (1|M0)               r6.1<1>:d     r1.4<0;1,0>:d     2:w              
        shl (1|M0)               r1.2<1>:d     r2.1<0;1,0>:d     10:w              
        shr (1|M0)               r1.3<1>:ud    r2.0<0;1,0>:ud    0x16:uw             
        addc (1|M0)              r7.0<1>:ud    r86.6<0;1,0>:ud   r6.1<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        mov (1|M0)               r9.0<1>:f     r7.0<0;1,0>:f                    {Compacted,I@2}
        shr (1|M0)               r6.0<1>:ud    r1.4<0;1,0>:ud    0x1E:uw             
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$12.src}
        shl (1|M0)               r3.3<1>:d     r1.5<0;1,0>:d     2:w               {I@3}
        sync.nop                             null                             {Compacted,$10.src}
        addc (1|M0)              r10.0<1>:ud   r9.0<0;1,0>:ud    0x20:ud              {AccWrEn,F@1}
        or (1|M0)                r6.2<1>:d     r3.3<0;1,0>:d     r6.0<0;1,0>:d    {I@2}
        mov (1|M0)               r2.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        add3 (1|M0)              r9.1<1>:d     r8.0<0;0>:d       r86.7<0;0>:d      r6.2<0>:d        {I@2}
        cmp (1|M0)    (lt)f0.1   null<1>:ud    r86.4<0;1,0>:ud   0xC:uw             
(f0.1)  cmp (1|M0)    (eq)f0.1   null<1>:d     r86.5<0;1,0>:d    0:w              
(W)     and (1|M0)               f1.1<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
        sync.allwr                           ($1,$8,$9,$10)                
        sync.allrd                           ($13,$14,$15)                
        dpas.8x8 (8|M0)          r46:f         null:f            r46:hf            r46.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r46:f         r102:f            r38:hf            r11.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r54:f         r102:f            r30:hf            r11.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r62:f         r102:f            r30:hf            r22.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r70:f         r102:f            r38:hf            r22.0:hf         {$9}
        sync.nop                             null                             {Compacted,$9.src}
        send.ugm (1|M0)          r21      r88     null:0  0x0            0x0280E780           {$11} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        send.ugm (1|M0)          r29      r87     null:0  0x0            0x0280E780           {$6} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        send.ugm (1|M0)          r11      r20     null:0  0x0            0x0280E780           {$2} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        sync.allwr                           ($2,$6,$9,$11,$12)                
        dpas.8x8 (8|M0)          r54:f         r54:f             r21:hf            r78.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r46:f         r46:f             r29:hf            r78.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r62:f         r62:f             r21:hf            r11.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r70:f         r70:f             r29:hf            r11.0:hf         {$12}
        addc (1|M0)              r12.0<1>:ud   r9.0<0;1,0>:ud    0x800:ud              {AccWrEn,$12.src}
        mov (1|M0)               r11.0<1>:f    r10.0<0;1,0>:f                   {Compacted}
        mov (1|M0)               r13.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r6.0<1>:ud    r9.0<0;1,0>:ud    0x820:ud              {AccWrEn}
        add3 (1|M0)              r11.1<1>:d    r2.0<0;0>:d       r9.1<0;0>:d       0:w               {I@7}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r2.0<1>:ud    r9.0<0;1,0>:ud    0x100:ud              {AccWrEn}
        send.ugm (1|M0)          null     r9      r54:1   0x0            0x0200C584           {$12} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r11     r46:1   0x0            0x0200C584           {A@1,$3} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        sync.nop                             null                             {Compacted,$3.src}
        mov (1|M0)               r11.0<1>:f    r2.0<0;1,0>:f                    {Compacted,I@1}
        mov (1|M0)               r14.0<1>:f    r12.0<0;1,0>:f                   {Compacted}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r12.0<1>:ud   r11.0<0;1,0>:ud   0x20:ud              {AccWrEn,A@1}
        add3 (1|M0)              r14.1<1>:d    r13.0<0;0>:d      r9.1<0;0>:d       0:w              
        mov (1|M0)               r8.0<1>:f     r6.0<0;1,0>:f                    {Compacted}
        mov (1|M0)               r13.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r6.0<1>:ud    r11.0<0;1,0>:ud   0x800:ud              {AccWrEn,F@1}
        add3 (1|M0)              r8.1<1>:d     r7.0<0;0>:d       r9.1<0;0>:d       0:w              
        add3 (1|M0)              r11.1<1>:d    r10.0<0;0>:d      r9.1<0;0>:d       0:w               {I@6}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r2.0<1>:ud    r11.0<0;1,0>:ud   0x820:ud              {AccWrEn}
        send.ugm (1|M0)          null     r14     r62:1   0x0            0x0200C584           {A@7,$4} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        mov (1|M0)               r14.0<1>:f    r12.0<0;1,0>:f                   {Compacted,$4.src}
        add3 (1|M0)              r14.1<1>:d    r13.0<0;0>:d      r11.1<0;0>:d      0:w               {I@3}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r12.0<1>:ud   r9.0<0;1,0>:ud    0x200:ud              {AccWrEn,F@1}
        send.ugm (1|M0)          null     r8      r70:1   0x0            0x0200C584           {$0} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r11     r55:1   0x0            0x0200C584           {$7} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r14     r47:1   0x0            0x0200C584           {A@3,$5} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        sync.nop                             null                             {Compacted,$5.src}
        mov (1|M0)               r14.0<1>:f    r12.0<0;1,0>:f                   {Compacted,I@1}
        mov (1|M0)               r8.0<1>:f     r6.0<0;1,0>:f                    {Compacted,$0.src}
        mov (1|M0)               r13.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r6.0<1>:ud    r14.0<0;1,0>:ud   0x20:ud              {AccWrEn,A@1}
        mov (1|M0)               r15.0<1>:f    r2.0<0;1,0>:f                    {Compacted}
        add3 (1|M0)              r8.1<1>:d     r7.0<0;0>:d       r11.1<0;0>:d      0:w              
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r2.0<1>:ud    r14.0<0;1,0>:ud   0x800:ud              {AccWrEn,F@1}
        add3 (1|M0)              r15.1<1>:d    r10.0<0;0>:d      r11.1<0;0>:d      0:w              
        add3 (1|M0)              r14.1<1>:d    r13.0<0;0>:d      r9.1<0;0>:d       0:w               {I@6}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r12.0<1>:ud   r14.0<0;1,0>:ud   0x820:ud              {AccWrEn}
        send.ugm (1|M0)          null     r8      r63:1   0x0            0x0200C584           {A@7,$13} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        mov (1|M0)               r8.0<1>:f     r6.0<0;1,0>:f                    {Compacted,$13.src}
        add3 (1|M0)              r8.1<1>:d     r7.0<0;0>:d       r14.1<0;0>:d      0:w               {I@3}
        mov (1|M0)               r13.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r6.0<1>:ud    r9.0<0;1,0>:ud    0x300:ud              {AccWrEn,F@1}
        send.ugm (1|M0)          null     r15     r71:1   0x0            0x0200C584           {$15} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r14     r56:1   0x0            0x0200C584           {$14} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r8      r48:1   0x0            0x0200C584           {A@3,$8} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        sync.nop                             null                             {Compacted,$8.src}
        mov (1|M0)               r8.0<1>:f     r6.0<0;1,0>:f                    {Compacted,I@1}
        mov (1|M0)               r11.0<1>:f    r2.0<0;1,0>:f                    {Compacted,$7.src}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r2.0<1>:ud    r8.0<0;1,0>:ud    0x20:ud              {AccWrEn,A@1}
        add3 (1|M0)              r11.1<1>:d    r10.0<0;0>:d      r14.1<0;0>:d      0:w              
        mov (1|M0)               r15.0<1>:f    r12.0<0;1,0>:f                   {Compacted,$15.src}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r12.0<1>:ud   r8.0<0;1,0>:ud    0x800:ud              {AccWrEn,F@1}
        add3 (1|M0)              r15.1<1>:d    r13.0<0;0>:d      r14.1<0;0>:d      0:w              
        add3 (1|M0)              r8.1<1>:d     r7.0<0;0>:d       r9.1<0;0>:d       0:w               {I@6}
        mov (1|M0)               r13.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r6.0<1>:ud    r8.0<0;1,0>:ud    0x820:ud              {AccWrEn}
        send.ugm (1|M0)          null     r11     r64:1   0x0            0x0200C584           {A@7,$10} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        mov (1|M0)               r11.0<1>:f    r2.0<0;1,0>:f                    {Compacted,$10.src}
        add3 (1|M0)              r11.1<1>:d    r10.0<0;0>:d      r8.1<0;0>:d       0:w               {I@3}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r2.0<1>:ud    r9.0<0;1,0>:ud    0x400:ud              {AccWrEn,F@1}
        send.ugm (1|M0)          null     r15     r72:1   0x0            0x0200C584           {$1} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r8      r57:1   0x0            0x0200C584           {$9} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r11     r49:1   0x0            0x0200C584           {A@3,$11} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        sync.nop                             null                             {Compacted,$11.src}
        mov (1|M0)               r11.0<1>:f    r2.0<0;1,0>:f                    {Compacted,I@1}
        mov (1|M0)               r14.0<1>:f    r12.0<0;1,0>:f                   {Compacted,$14.src}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r12.0<1>:ud   r11.0<0;1,0>:ud   0x20:ud              {AccWrEn,A@1}
        add3 (1|M0)              r14.1<1>:d    r13.0<0;0>:d      r8.1<0;0>:d       0:w              
        mov (1|M0)               r15.0<1>:f    r6.0<0;1,0>:f                    {Compacted,$1.src}
        mov (1|M0)               r13.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r6.0<1>:ud    r11.0<0;1,0>:ud   0x800:ud              {AccWrEn,F@1}
        add3 (1|M0)              r15.1<1>:d    r7.0<0;0>:d       r8.1<0;0>:d       0:w              
        add3 (1|M0)              r11.1<1>:d    r10.0<0;0>:d      r9.1<0;0>:d       0:w               {I@6}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r2.0<1>:ud    r11.0<0;1,0>:ud   0x820:ud              {AccWrEn}
        send.ugm (1|M0)          null     r14     r65:1   0x0            0x0200C584           {A@7,$6} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        mov (1|M0)               r14.0<1>:f    r12.0<0;1,0>:f                   {Compacted,$6.src}
        add3 (1|M0)              r14.1<1>:d    r13.0<0;0>:d      r11.1<0;0>:d      0:w               {I@3}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r12.0<1>:ud   r9.0<0;1,0>:ud    0x500:ud              {AccWrEn,F@1}
        send.ugm (1|M0)          null     r15     r73:1   0x0            0x0200C584           {$2} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r11     r58:1   0x0            0x0200C584           {$12} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r14     r50:1   0x0            0x0200C584           {A@3,$3} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        sync.nop                             null                             {Compacted,$3.src}
        mov (1|M0)               r14.0<1>:f    r12.0<0;1,0>:f                   {Compacted,I@1}
        mov (1|M0)               r8.0<1>:f     r6.0<0;1,0>:f                    {Compacted,$9.src}
        mov (1|M0)               r13.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r6.0<1>:ud    r14.0<0;1,0>:ud   0x20:ud              {AccWrEn,A@1}
        add3 (1|M0)              r8.1<1>:d     r7.0<0;0>:d       r11.1<0;0>:d      0:w              
        mov (1|M0)               r15.0<1>:f    r2.0<0;1,0>:f                    {Compacted,$2.src}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r2.0<1>:ud    r14.0<0;1,0>:ud   0x800:ud              {AccWrEn,F@1}
        add3 (1|M0)              r15.1<1>:d    r10.0<0;0>:d      r11.1<0;0>:d      0:w              
        add3 (1|M0)              r14.1<1>:d    r13.0<0;0>:d      r9.1<0;0>:d       0:w               {I@6}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r12.0<1>:ud   r14.0<0;1,0>:ud   0x820:ud              {AccWrEn}
        send.ugm (1|M0)          null     r8      r66:1   0x0            0x0200C584           {A@7,$4} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        mov (1|M0)               r8.0<1>:f     r6.0<0;1,0>:f                    {Compacted,$4.src}
        add3 (1|M0)              r8.1<1>:d     r7.0<0;0>:d       r14.1<0;0>:d      0:w               {I@3}
        mov (1|M0)               r13.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r6.0<1>:ud    r9.0<0;1,0>:ud    0x600:ud              {AccWrEn,F@1}
        send.ugm (1|M0)          null     r15     r74:1   0x0            0x0200C584           {$0} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r14     r59:1   0x0            0x0200C584           {$8} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r8      r51:1   0x0            0x0200C584           {A@3,$10} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        sync.nop                             null                             {Compacted,$10.src}
        mov (1|M0)               r8.0<1>:f     r6.0<0;1,0>:f                    {Compacted,I@1}
        mov (1|M0)               r11.0<1>:f    r2.0<0;1,0>:f                    {Compacted,$12.src}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r2.0<1>:ud    r8.0<0;1,0>:ud    0x20:ud              {AccWrEn,A@1}
        add3 (1|M0)              r11.1<1>:d    r10.0<0;0>:d      r14.1<0;0>:d      0:w              
        mov (1|M0)               r15.0<1>:f    r12.0<0;1,0>:f                   {Compacted,$0.src}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r12.0<1>:ud   r8.0<0;1,0>:ud    0x800:ud              {AccWrEn,F@1}
        add3 (1|M0)              r15.1<1>:d    r13.0<0;0>:d      r14.1<0;0>:d      0:w              
        add3 (1|M0)              r8.1<1>:d     r7.0<0;0>:d       r9.1<0;0>:d       0:w               {I@6}
        mov (1|M0)               r13.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r6.0<1>:ud    r8.0<0;1,0>:ud    0x820:ud              {AccWrEn}
        send.ugm (1|M0)          null     r11     r67:1   0x0            0x0200C584           {A@7,$1} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        mov (1|M0)               r11.0<1>:f    r2.0<0;1,0>:f                    {Compacted,$1.src}
        add3 (1|M0)              r11.1<1>:d    r10.0<0;0>:d      r8.1<0;0>:d       0:w               {I@3}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r2.0<1>:ud    r9.0<0;1,0>:ud    0x700:ud              {AccWrEn,F@1}
        send.ugm (1|M0)          null     r15     r75:1   0x0            0x0200C584           {$9} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r8      r60:1   0x0            0x0200C584           {$11} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r11     r52:1   0x0            0x0200C584           {A@3,$6} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        sync.nop                             null                             {Compacted,$6.src}
        mov (1|M0)               r11.0<1>:f    r2.0<0;1,0>:f                    {Compacted,I@1}
        mov (1|M0)               r14.0<1>:f    r12.0<0;1,0>:f                   {Compacted,$8.src}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r12.0<1>:ud   r11.0<0;1,0>:ud   0x20:ud              {AccWrEn,A@1}
        add3 (1|M0)              r14.1<1>:d    r13.0<0;0>:d      r8.1<0;0>:d       0:w              
        mov (1|M0)               r15.0<1>:f    r6.0<0;1,0>:f                    {Compacted,$9.src}
        mov (1|M0)               r13.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r6.0<1>:ud    r11.0<0;1,0>:ud   0x800:ud              {AccWrEn,F@1}
        add3 (1|M0)              r15.1<1>:d    r7.0<0;0>:d       r8.1<0;0>:d       0:w              
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r2.0<1>:ud    r11.0<0;1,0>:ud   0x820:ud              {AccWrEn}
        send.ugm (1|M0)          null     r14     r68:1   0x0            0x0200C584           {A@6,$2} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        add3 (1|M0)              r11.1<1>:d    r10.0<0;0>:d      r9.1<0;0>:d       0:w              
        mov (1|M0)               r14.0<1>:f    r12.0<0;1,0>:f                   {Compacted,$2.src}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$12.src}
        addc (1|M0)              r12.0<1>:ud   r86.4<0;1,0>:ud   0x4:ud              {AccWrEn,F@1}
        sync.nop                             null                             {Compacted,$11.src}
        mov (1|M0)               r8.0<1>:f     r6.0<0;1,0>:f                    {Compacted,I@7}
        mov (1|M0)               r10.0<1>:f    r2.0<0;1,0>:f                    {Compacted,A@3}
        add3 (1|M0)              r14.1<1>:d    r13.0<0;0>:d      r11.1<0;0>:d      0:w              
        add3 (1|M0)              r8.1<1>:d     r7.0<0;0>:d       r11.1<0;0>:d      0:w              
        add3 (1|M0)              r10.1<1>:d    r9.0<0;0>:d       r11.1<0;0>:d      0:w               {I@4}
        mov (1|M0)               r13.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        send.ugm (1|M0)          null     r15     r76:1   0x0            0x0200C584           {$14} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r11     r61:1   0x0            0x0200C584           {$15} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r14     r53:1   0x0            0x0200C584           {A@4,$13} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r8      r69:1   0x0            0x0200C584           {A@2,$5} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r10     r77:1   0x0            0x0200C584           {A@1,$7} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        mov (1|M0)               r1.2<1>:d     r12.0<0;1,0>:d                  
        add3 (1|M0)              r1.3<1>:d     r13.0<0;0>:d      r86.5<0;0>:d      0:w               {I@2}
(~f1.1.any16h) goto (16|M0)                  L16400                  L16400                
L16368:
(W)     mov (2|M0)               r86.4<1>:ud   r1.2<1;1,0>:ud                   {I@2}
        goto.b (16|M0)                       L16400                  L13288                
L16400:
        join (16|M0)                         L39176                                
L16416:
(W)     send.slm (1|M0)          r6       r0      null:0  0x0            0x0210001F           {$12} // wr:1+0, rd:1; fence.slm.none.group
(W)     mov (1|M0)               r7.2<1>:f     0.0:f                               {Compacted}
(W)     mov (2|M0)               r7.10<1>:ub   r0.11<0;1,0>:ub                  {F@1}
(W)     mov (8|M0)               null<1>:ud    r6.0<1;1,0>:ud                   {$12.dst}
(W)     send.gtwy (1|M0)         null     r7      null:0  0x0            0x02000004           {A@2,$3} // wr:1+0, rd:0; signal barrier
(W)     sync.bar                             null                            
        cmp (1|M0)    (eq)f1.0   null<1>:d     r2.6<0;1,0>:d     5:w              
(W)     and (1|M0)               f1.0<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
(f1.0.any16h) goto (16|M0)                   L38232                  L38232                
L16552:
        shl (1|M0)               r110.2<1>:d   r94.2<0;1,0>:d    6:w              
        shl (1|M0)               r1.2<1>:d     r94.3<0;1,0>:d    6:w              
        shl (1|M0)               r6.0<1>:d     r110.2<0;1,0>:d   2:w               {Compacted,I@2}
        shr (1|M0)               r1.3<1>:ud    r94.2<0;1,0>:ud   0x1A:uw             
        sync.nop                             null                             {Compacted,$3.src}
        addc (1|M0)              r7.0<1>:ud    r94.6<0;1,0>:ud   r6.0<0;1,0>:ud   {AccWrEn,I@2}
        or (1|M0)                r110.3<1>:d   r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$5.src}
        sync.allrd                           ($4,$7)                
        addc (1|M0)              r10.0<1>:ud   r122.0<0;1,0>:ud  0x17000:ud              {AccWrEn,$2.src}
        shr (1|M0)               r2.1<1>:ud    r110.2<0;1,0>:ud  0x1E:uw             
        sync.nop                             null                             {Compacted,$1.src}
        mov (1|M0)               r9.0<1>:d     r7.0<0;1,0>:d                    {I@5}
        shl (1|M0)               r2.0<1>:d     r110.3<0;1,0>:d   2:w               {Compacted,I@5}
        sync.nop                             null                             {Compacted,$15.src}
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,$11.src}
        sync.nop                             null                             {Compacted,$8.src}
        addc (1|M0)              r12.0<1>:ud   r10.0<0;1,0>:ud   r6.0<0;1,0>:ud   {AccWrEn,I@5}
        or (1|M0)                r6.1<1>:d     r2.0<0;1,0>:d     r2.1<0;1,0>:d    {I@3}
        mov (1|M0)               r13.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r2.0<1>:ud    r9.0<0;1,0>:ud    0x80:ud              {AccWrEn}
        add3 (1|M0)              r9.1<1>:d     r8.0<0;0>:d       r94.7<0;0>:d      r6.1<0>:d        {I@3}
        mov (1|M0)               r18.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,$5.src}
        addc (1|M0)              r8.0<1>:ud    r4.4<0;1,0>:ud    r6.0<0;1,0>:ud   {AccWrEn}
        add3 (1|M0)              r6.3<1>:d     r11.0<0;0>:d      r122.1<0;0>:d     0:w              
        mov (1|M0)               r10.0<1>:d    r8.0<0;1,0>:d                    {I@2}
        mov (1|M0)               r86.0<1>:d    r12.0<0;1,0>:d                  
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r12.0<1>:ud   r10.0<0;1,0>:ud   0x80:ud              {AccWrEn,I@3}
        add3 (1|M0)              r86.1<1>:d    r13.0<0;0>:d      r6.3<0;0>:d       r6.1<0>:d       
        add3 (1|M0)              r10.1<1>:d    r11.0<0;0>:d      r4.5<0;0>:d       r6.1<0>:d        {I@3}
        mov (1|M0)               r13.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        send.ugm (1|M0)          r14      r9      null:0  0x0            0x0240E580           {$4} // wr:1+0, rd:4; load.ugm.d32x32t.a64
        sync.nop                             null                             {Compacted,$1.dst}
        send.ugm (1|M0)          r23      r10     null:0  0x0            0x0240E580           {A@2,$0} // wr:1+0, rd:4; load.ugm.d32x32t.a64
        mov (1|M0)               r7.0<1>:d     r2.0<0;1,0>:d                   
        add3 (1|M0)              r7.1<1>:d     r18.0<0;0>:d      r9.1<0;0>:d       0:w              
        mov (1|M0)               r27.0<1>:d    r12.0<0;1,0>:d                  
        add3 (1|M0)              r27.1<1>:d    r13.0<0;0>:d      r10.1<0;0>:d      0:w               {I@4}
        send.ugm (1|M0)          r19      r7      null:0  0x0            0x0240E580           {A@3,$8} // wr:1+0, rd:4; load.ugm.d32x32t.a64
        send.ugm (1|M0)          r28      r27     null:0  0x0            0x0240E580           {A@1,$10} // wr:1+0, rd:4; load.ugm.d32x32t.a64
        mov (1|M0)               r1.2<1>:f     0x3D380000:f                              
        mov (1|M0)               r1.3<1>:f     0x3FA68000:f                              
        addc (1|M0)              r2.0<1>:ud    r86.0<0;1,0>:ud   0x80:ud              {AccWrEn}
        mov (1|M0)               r86.6<2>:d    0:d                              
        mov (1|M0)               r86.7<2>:d    0:d                              
        mov (1|M0)               r86.3<1>:f    0.0:f                               {Compacted}
        sync.nop                             null                             {Compacted,$0.dst}
        add (16|M0)              r32.0<1>:f    r16.0<1;1,0>:f    r25.0<1;1,0>:f   {Compacted,$4.dst}
        add (16|M0)              r34.0<1>:f    r14.0<1;1,0>:f    r23.0<1;1,0>:f   {Compacted}
        mov (8|M0)               r8.0<1>:hf    r32.0<1;1,0>:f                   {F@2}
        mov (8|M0)               r8.8<1>:hf    r33.0<1;1,0>:f                  
        sync.nop                             null                             {Compacted,$10.dst}
        add (16|M0)              r36.0<1>:f    r21.0<1;1,0>:f    r30.0<1;1,0>:f   {Compacted,$8.dst}
        mov (8|M0)               r7.0<1>:hf    r34.0<1;1,0>:f                   {F@4}
        mov (8|M0)               r7.8<1>:hf    r35.0<1;1,0>:f                  
        add (16|M0)              r38.0<1>:f    r19.0<1;1,0>:f    r28.0<1;1,0>:f   {Compacted}
        mov (8|M0)               r12.0<1>:f    r8.0<1;1,0>:hf                   {F@6}
        mov (8|M0)               r13.0<1>:f    r8.8<1;1,0>:hf                   {F@6}
        mov (8|M0)               r9.0<1>:hf    r36.0<1;1,0>:f                   {F@6}
        mov (8|M0)               r9.8<1>:hf    r37.0<1;1,0>:f                  
        mov (8|M0)               r10.0<1>:f    r7.0<1;1,0>:hf                   {F@7}
        mov (8|M0)               r11.0<1>:f    r7.8<1;1,0>:hf                   {F@7}
        mov (8|M0)               r6.0<1>:hf    r38.0<1;1,0>:f                   {F@7}
        mov (8|M0)               r6.8<1>:hf    r39.0<1;1,0>:f                  
        mad (16|M0)              r12.0<1>:f    r1.3<0;0>:f       r12.0<1;0>:f      r1.2<0>:f        {Compacted,F@7}
        mov (8|M0)               r18.0<1>:f    r9.0<1;1,0>:hf                   {F@7}
        mov (8|M0)               r19.0<1>:f    r9.8<1;1,0>:hf                   {F@7}
        mad (16|M0)              r10.0<1>:f    r1.3<0;0>:f       r10.0<1;0>:f      r1.2<0>:f        {Compacted,F@6}
        mov (8|M0)               r16.0<1>:f    r6.0<1;1,0>:hf                   {F@6}
        mov (8|M0)               r17.0<1>:f    r6.8<1;1,0>:hf                   {F@6}
        mov (8|M0)               r15.0<1>:hf   r12.0<1;1,0>:f                   {F@6}
        mov (8|M0)               r15.8<1>:hf   r13.0<1;1,0>:f                  
        mad (16|M0)              r18.0<1>:f    r1.3<0;0>:f       r18.0<1;0>:f      r1.2<0>:f        {Compacted,F@6}
        mov (8|M0)               r14.0<1>:hf   r10.0<1;1,0>:f                   {F@6}
        mov (8|M0)               r14.8<1>:hf   r11.0<1;1,0>:f                  
        mad (16|M0)              r16.0<1>:f    r1.3<0;0>:f       r16.0<1;0>:f      r1.2<0>:f        {Compacted,F@6}
        mov (8|M0)               r12.0<1>:f    r15.0<1;1,0>:hf                  {F@6}
        mov (8|M0)               r13.0<1>:f    r15.8<1;1,0>:hf                  {F@6}
        mov (8|M0)               r8.0<1>:hf    r18.0<1;1,0>:f                   {F@6}
        mov (8|M0)               r8.8<1>:hf    r19.0<1;1,0>:f                  
        mov (8|M0)               r10.0<1>:f    r14.0<1;1,0>:hf                  {F@7}
        mov (8|M0)               r11.0<1>:f    r14.8<1;1,0>:hf                  {F@7}
        mov (8|M0)               r7.0<1>:hf    r16.0<1;1,0>:f                   {F@7}
        mov (8|M0)               r7.8<1>:hf    r17.0<1;1,0>:f                  
        sel (16|M0)   (ge)f0.0   r12.0<1>:f    r12.0<1;1,0>:f    1.03125:f               {F@7}
        mov (8|M0)               r16.0<1>:f    r8.0<1;1,0>:hf                   {F@7}
        mov (8|M0)               r17.0<1>:f    r8.8<1;1,0>:hf                   {F@7}
        sel (16|M0)   (ge)f0.0   r10.0<1>:f    r10.0<1;1,0>:f    1.03125:f               {F@6}
        mov (8|M0)               r20.0<1>:f    r7.0<1;1,0>:hf                   {F@6}
        mov (8|M0)               r21.0<1>:f    r7.8<1;1,0>:hf                   {F@6}
        sel (16|M0)   (lt)f0.0   r12.0<1>:f    r12.0<1;1,0>:f    0x3FC8E000:f               {F@6}
        sel (16|M0)   (ge)f0.0   acc2.0<1>:f   r16.0<1;1,0>:f    1.03125:f               {F@5}
        sel (16|M0)   (lt)f0.0   r10.0<1>:f    r10.0<1;1,0>:f    0x3FC8E000:f               {F@5}
        sel (16|M0)   (ge)f0.0   r20.0<1>:f    r20.0<1;1,0>:f    1.03125:f               {F@4}
        mov (8|M0)               r18.0<1>:ud   r12.0<2;1,0>:ud                  {F@4}
        sel (16|M0)   (lt)f0.0   r16.0<1>:f    acc2.0<1;1,0>:f   0x3FC8E000:f              
        mov (8|M0)               r19.0<1>:ud   r12.1<2;1,0>:ud                 
        mov (8|M0)               r6.0<1>:ud    r10.1<2;1,0>:ud                  {F@3}
        mov (8|M0)               r14.0<1>:ud   r10.0<2;1,0>:ud                 
        sel (16|M0)   (lt)f0.0   r20.0<1>:f    r20.0<1;1,0>:f    0x3FC8E000:f               {F@2}
        mov (8|M0)               r7.0<2>:hf    r18.0<1;1,0>:f                   {I@4}
        mov (8|M0)               r25.0<1>:ud   r16.0<2;1,0>:ud                  {F@3}
        mov (8|M0)               r11.0<1>:ud   r16.1<2;1,0>:ud                 
        mov (8|M0)               r8.0<2>:hf    r19.0<1;1,0>:f                   {I@5}
        mov (8|M0)               r22.0<1>:ud   r20.1<2;1,0>:ud                  {F@3}
        mov (8|M0)               r24.0<1>:ud   r20.0<2;1,0>:ud                 
        mov (8|M0)               r15.8<1>:uw   r7.0<2;1,0>:uw                   {F@2}
        mov (8|M0)               r10.0<2>:hf   r25.0<1;1,0>:f                   {I@5}
        mov (8|M0)               r7.0<2>:hf    r11.0<1;1,0>:f                   {A@1}
        mov (8|M0)               r9.0<1>:hf    r6.0<1;1,0>:f                   
        mov (8|M0)               r15.0<1>:hf   r14.0<1;1,0>:f                  
        mov (8|M0)               r9.8<1>:uw    r8.0<2;1,0>:uw                   {F@5}
        mov (8|M0)               r23.0<1>:hf   r22.0<1;1,0>:f                  
        mov (8|M0)               r6.0<1>:hf    r24.0<1;1,0>:f                  
        mov (8|M0)               r6.8<1>:uw    r10.0<2;1,0>:uw                  {A@4}
        mov (8|M0)               r23.8<1>:uw   r7.0<2;1,0>:uw                  
        shl (16|M0)              r18.0<1>:d    r15.0<1;1,0>:uw   5:w               {F@3}
        mov (16|M0)              r12.0<1>:d    r9.0<1;1,0>:uw                   {I@4}
        shl (16|M0)              r24.0<1>:d    r6.0<1;1,0>:uw    5:w               {A@1}
        mov (16|M0)              r20.0<1>:d    r23.0<1;1,0>:uw                  {I@4}
        add (16|M0)              r18.0<1>:d    r18.0<1;1,0>:d    2146992128:d               {I@4}
        shl (16|M0)              r12.0<1>:d    r12.0<1;1,0>:d    21:w               {Compacted,I@4}
        add (16|M0)              r24.0<1>:d    r24.0<1;1,0>:d    2146992128:d               {I@4}
        shl (16|M0)              r20.0<1>:d    r20.0<1;1,0>:d    21:w               {Compacted,I@4}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        add (16|M0)              r18.0<1>:d    r18.0<1;1,0>:d    r12.0<1;1,0>:d   {Compacted,I@4}
        add (16|M0)              r24.0<1>:d    r24.0<1;1,0>:d    r20.0<1;1,0>:d   {Compacted,I@3}
        mov (1|M0)               r8.0<1>:d     r2.0<0;1,0>:d                   
        add3 (1|M0)              r8.1<1>:d     r7.0<0;0>:d       r86.1<0;0>:d      0:w               {I@4}
        mov (8|M0)               r40.0<1>:f    r18.0<1;1,0>:hf                  {I@4}
        mov (8|M0)               r41.0<1>:f    r18.8<1;1,0>:hf                 
        mov (8|M0)               r42.0<1>:f    r19.0<1;1,0>:hf                 
        mov (8|M0)               r43.0<1>:f    r19.8<1;1,0>:hf                 
        mov (8|M0)               r123.0<1>:f   r24.0<1;1,0>:hf                  {I@3}
        mov (8|M0)               r124.0<1>:f   r24.8<1;1,0>:hf                 
        mov (8|M0)               r125.0<1>:f   r25.0<1;1,0>:hf                 
        mov (8|M0)               r126.0<1>:f   r25.8<1;1,0>:hf                 
        send.ugm (1|M0)          null     r86     r40:4   0x0            0x0200E584           {A@5,$1} // wr:1+4, rd:0; store.ugm.d32x32t.a64
        send.ugm (1|M0)          null     r8      r123:4  0x0            0x0200E584           {A@1,$9} // wr:1+4, rd:0; store.ugm.d32x32t.a64
        mov (1|M0)               r94.0<1>:f    r40.0<0;1,0>:f                   {Compacted}
L18568:
        addc (1|M0)              r2.0<1>:ud    r86.6<0;1,0>:ud   0x1:ud              {AccWrEn}
        sync.nop                             null                             {Compacted,$11.dst}
        sync.nop                             null                             {Compacted,$1.src}
        add (1|M0)               r86.3<1>:f    r86.3<0;1,0>:f    r94.0<0;1,0>:f   {Compacted,F@1}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r86.4<1>:d    r2.0<0;1,0>:d                    {I@2}
        add3 (1|M0)              r86.5<1>:d    r6.0<0;0>:d       r86.7<0;0>:d      0:w               {I@2}
        cmp (1|M0)    (eq)f1.1   null<1>:d     r86.5<0;1,0>:d    0:w               {I@1}
(f1.1)  cmp (1|M0)    (eq)f1.1   null<1>:d     r86.4<0;1,0>:d    64:w              
(W)     and (1|M0)               f0.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(f0.1.any16h) goto (16|M0)                   L18912                  L18912                
L18712:
        addc (1|M0)              r2.0<1>:ud    r86.0<0;1,0>:ud   0x4:ud              {AccWrEn}
        shl (1|M0)               r1.6<1>:d     r86.6<0;1,0>:d    2:w              
        shl (1|M0)               r1.4<1>:d     r86.7<0;1,0>:d    2:w              
        shr (1|M0)               r1.5<1>:ud    r86.6<0;1,0>:ud   0x1E:uw             
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r7.0<1>:ud    r2.0<0;1,0>:ud    r1.6<0;1,0>:ud   {AccWrEn,I@4}
        or (1|M0)                r1.7<1>:d     r1.4<0;1,0>:d     r1.5<0;1,0>:d    {I@3}
        add3 (1|M0)              r1.3<1>:d     r6.0<0;0>:d       r86.1<0;0>:d      0:w               {I@3}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$9.src}
        mov (1|M0)               r10.0<1>:f    r7.0<0;1,0>:f                    {Compacted,I@4}
        add3 (1|M0)              r10.1<1>:d    r8.0<0;0>:d       r1.3<0;0>:d       r1.7<0>:d        {I@1}
(W)     mov (2|M0)               r86.6<1>:ud   r86.4<1;1,0>:ud                 
        send.ugm (1|M0)          r94      r10     null:0  0x0            0x04100580           {A@1,$11} // wr:2+0, rd:1; load.ugm.d32.a64
        goto.b (16|M0)                       L18912                  L18568                
L18912:
        join (16|M0)                         L38232                                
L18928:
        mov (1|M0)               r1.4<2>:hf    r86.3<0;1,0>:f                  
        shl (1|M0)               r86.5<1>:d    r94.4<0;1,0>:d    1:w              
        sync.nop                             null                             {Compacted,F@1}
        math.inv (8|M0)          r6.0<1>:hf    r1.4<0;1,0>:hf                   {$6}
        mov (1|M0)               r1.4<1>:hf    r6.0<0;1,0>:hf                   {$6.dst}
        mov (1|M0)               r2.0<1>:f     r1.4<0;1,0>:hf                   {F@1}
        shl (1|M0)               r1.2<1>:ud    r122.3<0;1,0>:ud  0xA:uw              {F@1}
        mul (16|M0)              r9.0<1>:f     r2.0<0;1,0>:f     r40.0<1;1,0>:f   {Compacted,$11.src}
        mov (8|M0)               r11.0<1>:hf   r9.0<1;1,0>:f                    {F@1}
        mov (8|M0)               r11.8<1>:hf   r10.0<1;1,0>:f                  
        mov (8|M0)               r12.0<1>:f    (abs)r11.0<1;1,0>:hf             {F@2}
        mov (8|M0)               r13.0<1>:f    (abs)r11.8<1;1,0>:hf             {F@2}
        mul (16|M0)              r7.0<1>:f     r2.0<0;1,0>:f     r42.0<1;1,0>:f   {Compacted,$9.src}
        sel (16|M0)   (lt)f0.0   r12.0<1>:f    r12.0<1;1,0>:f    448.0:f               {Compacted,F@2}
        shr (16|M0)              r17.0<1>:ud   r12.0<1;1,0>:ud   0x17:uw              {F@1}
        sel (16|M0)   (ge)f0.0   r21.0<2>:ub   r17.0<4;1,0>:ub   0x79:uw              {I@1}
        mov (16|M0)              r23.0<1>:d    r21.0<2;1,0>:ub                  {I@1}
        shl (16|M0)              r23.0<1>:d    r23.0<1;1,0>:d    23:w               {Compacted,I@1}
        mov (8|M0)               r14.0<1>:hf   r7.0<1;1,0>:f                   
        mov (8|M0)               r14.8<1>:hf   r8.0<1;1,0>:f                   
        add (16|M0)              r27.0<1>:d    r23.0<1;1,0>:d    -25165824:d               {I@1}
        add (16|M0)              r23.0<1>:d    -r23.0<1;1,0>:d   -2139095040:d              
        mov (8|M0)               r15.0<1>:f    (abs)r14.0<1;1,0>:hf             {F@2}
        mov (8|M0)               r16.0<1>:f    (abs)r14.8<1;1,0>:hf             {F@2}
        mul (16|M0)              acc0.0<1>:f   r12.0<1;1,0>:f    r23.0<1;1,0>:f   {Compacted,I@1}
        sel (16|M0)   (lt)f0.0   r15.0<1>:f    r15.0<1;1,0>:f    448.0:f               {Compacted,F@2}
        rnde (16|M0)             acc0.0<1>:f   acc0.0<1;1,0>:f                 
        shr (16|M0)              r19.0<1>:ud   r15.0<1;1,0>:ud   0x17:uw              {F@2}
        mul (16|M0)              acc0.0<1>:f   acc0.0<1;1,0>:f   r27.0<1;1,0>:f   {Compacted}
        mul (16|M0)              r12.0<1>:f    r2.0<0;1,0>:f     r123.0<1;1,0>:f  {Compacted}
        cmp (16|M0)   (lt)f0.1   null<1>:f     r9.0<1;1,0>:f     0xB3000000:f              
        sel (16|M0)   (ge)f0.0   r22.0<2>:ub   r19.0<4;1,0>:ub   0x79:uw              {I@1}
        mov (8|M0)               r14.0<1>:hf   r12.0<1;1,0>:f                   {F@2}
        mov (8|M0)               r14.8<1>:hf   r13.0<1;1,0>:f                  
        mov (16|M0)              r17.0<1>:f    (abs)acc0.0<1;1,0>:f             {Compacted}
        mov (16|M0)              r25.0<1>:d    r22.0<2;1,0>:ub                  {I@1}
        mov (8|M0)               r9.0<1>:f     (abs)r14.0<1;1,0>:hf             {F@3}
        mov (8|M0)               r10.0<1>:f    (abs)r14.8<1;1,0>:hf             {F@3}
(f0.1)  or (16|M0)               r17.0<1>:d    r17.0<1;1,0>:d    -2147483648:d               {F@3}
        shl (16|M0)              r25.0<1>:d    r25.0<1;1,0>:d    23:w               {Compacted,I@2}
        sel (16|M0)   (lt)f0.0   r9.0<1>:f     r9.0<1;1,0>:f     448.0:f               {Compacted,F@1}
        mov (8|M0)               r6.0<1>:hf    r17.0<1;1,0>:f                   {I@2}
        mov (8|M0)               r6.8<1>:hf    r18.0<1;1,0>:f                  
        add (16|M0)              r29.0<1>:d    r25.0<1;1,0>:d    -25165824:d               {I@1}
        shr (16|M0)              r17.0<1>:ud   r9.0<1;1,0>:ud    0x17:uw              {A@1}
        add (16|M0)              r25.0<1>:d    -r25.0<1;1,0>:d   -2139095040:d              
        sel (16|M0)   (ge)f0.0   r23.0<2>:ub   r17.0<4;1,0>:ub   0x79:uw              {I@2}
        mul (16|M0)              acc0.0<1>:f   r15.0<1;1,0>:f    r25.0<1;1,0>:f   {Compacted,I@2}
        mul (16|M0)              r21.0<1>:f    r2.0<0;1,0>:f     r125.0<1;1,0>:f  {Compacted}
        rnde (16|M0)             acc0.0<1>:f   acc0.0<1;1,0>:f                 
        mov (16|M0)              r25.0<1>:d    r23.0<2;1,0>:ub                  {A@1}
        cmp (16|M0)   (lt)f1.1   null<1>:f     r7.0<1;1,0>:f     0xB3000000:f              
        mul (16|M0)              acc0.0<1>:f   acc0.0<1;1,0>:f   r29.0<1;1,0>:f   {Compacted}
        shl (16|M0)              r25.0<1>:d    r25.0<1;1,0>:d    23:w               {Compacted,I@1}
        mov (8|M0)               r7.0<1>:hf    r21.0<1;1,0>:f                   {F@4}
        mov (8|M0)               r7.8<1>:hf    r22.0<1;1,0>:f                  
        mov (16|M0)              r19.0<1>:f    (abs)acc0.0<1;1,0>:f             {Compacted}
        add (16|M0)              r29.0<1>:d    r25.0<1;1,0>:d    -25165824:d               {A@1}
        mov (8|M0)               r15.0<1>:f    (abs)r7.0<1;1,0>:hf              {F@3}
        mov (8|M0)               r16.0<1>:f    (abs)r7.8<1;1,0>:hf              {F@3}
        add (16|M0)              r25.0<1>:d    -r25.0<1;1,0>:d   -2139095040:d              
(f1.1)  or (16|M0)               r19.0<1>:d    r19.0<1;1,0>:d    -2147483648:d               {F@3}
        sel (16|M0)   (lt)f0.0   r15.0<1>:f    r15.0<1;1,0>:f    448.0:f               {Compacted,F@1}
        mul (16|M0)              acc0.0<1>:f   r9.0<1;1,0>:f     r25.0<1;1,0>:f   {Compacted,I@2}
        mov (8|M0)               r11.0<1>:hf   r19.0<1;1,0>:f                   {I@1}
        mov (8|M0)               r11.8<1>:hf   r20.0<1;1,0>:f                  
        rnde (16|M0)             acc0.0<1>:f   acc0.0<1;1,0>:f                 
        shr (16|M0)              r19.0<1>:ud   r15.0<1;1,0>:ud   0x17:uw              {A@2}
        cmp (16|M0)   (lt)f1.0   null<1>:f     r12.0<1;1,0>:f    0xB3000000:f               {Compacted}
        mul (16|M0)              r7.0<1>:f     acc0.0<1;1,0>:f   r29.0<1;1,0>:f   {Compacted}
        sel (16|M0)   (ge)f0.0   r24.0<2>:ub   r19.0<4;1,0>:ub   0x79:uw              {I@1}
        addc (1|M0)              r2.0<1>:ud    r122.0<0;1,0>:ud  0xE000:ud              {AccWrEn,A@1}
        mov (16|M0)              r7.0<1>:f     (abs)r7.0<1;1,0>:f               {Compacted}
        bfn.0xEA (1|M0)          r10.0<1>:ud   r1.2<0;0>:ud      r94.5<0;0>:ud     0x80:uw              // s0|s1&s2
        mov (16|M0)              r27.0<1>:d    r24.0<2;1,0>:ub                  {I@3}
        mov (1|M0)               r86.3<1>:d    r2.0<0;1,0>:d                    {I@3}
(f1.0)  or (16|M0)               r7.0<1>:d     r7.0<1;1,0>:d     -2147483648:d               {F@1}
        shl (1|M0)               r12.0<1>:d    r10.0<0;1,0>:d    1:w               {Compacted,I@4}
        shl (16|M0)              r27.0<1>:d    r27.0<1;1,0>:d    23:w               {Compacted,I@4}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        shr (1|M0)               r3.3<1>:ud    r10.0<0;1,0>:ud   0x1F:uw             
        mov (8|M0)               r14.0<1>:hf   r7.0<1;1,0>:f                    {I@5}
        add (16|M0)              r31.0<1>:d    r27.0<1;1,0>:d    -25165824:d               {I@3}
        addc (1|M0)              r7.0<1>:ud    r86.3<0;1,0>:ud   r12.0<0;1,0>:ud  {AccWrEn,F@1}
        add (16|M0)              r27.0<1>:d    -r27.0<1;1,0>:d   -2139095040:d              
        mov (8|M0)               r14.8<1>:hf   r8.0<1;1,0>:f                   
        add3 (1|M0)              r86.4<1>:d    r9.0<0;0>:d       r122.1<0;0>:d     0:w               {I@5}
        or (1|M0)                r12.1<1>:d    r3.3<0;1,0>:d     0:w               {I@5}
        shr (1|M0)               r7.3<1>:ud    r94.4<0;1,0>:ud   0x1F:uw             
        mul (16|M0)              acc2.0<1>:f   r15.0<1;1,0>:f    r27.0<1;1,0>:f   {Compacted,I@4}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,F@2}
        addc (1|M0)              r2.0<1>:ud    r7.0<0;1,0>:ud    r86.5<0;1,0>:ud  {AccWrEn}
        or (1|M0)                r86.6<1>:d    r7.3<0;1,0>:d     0:w               {I@3}
        rnde (16|M0)             acc2.0<1>:f   acc2.0<1;1,0>:f                 
        add3 (1|M0)              r7.2<1>:d     r8.0<0;0>:d       r86.4<0;0>:d      r12.1<0>:d       {I@3}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        cmp (16|M0)   (lt)f0.1   null<1>:f     r21.0<1;1,0>:f    0xB3000000:f              
        mov (1|M0)               r1.4<1>:d     r2.0<0;1,0>:d                    {I@4}
        mul (16|M0)              acc0.0<1>:f   acc2.0<1;1,0>:f   r31.0<1;1,0>:f   {Compacted,I@2}
        add3 (1|M0)              r1.5<1>:d     r9.0<0;0>:d       r7.2<0;0>:d       r86.6<0>:d      
        bfn.0xEA (1|M0)          r1.3<1>:ud    r1.2<0;0>:ud      r94.5<0;0>:ud     0x80:uw              // s0|s1&s2
        mov (16|M0)              r17.0<1>:f    (abs)acc0.0<1;1,0>:f             {Compacted}
        mov (8|M0)               r15.0<2>:ud   r1.4<0;1,0>:ud                   {A@3}
        mov (8|M0)               r15.1<2>:ud   r1.5<0;1,0>:ud                   {I@3}
(f0.1)  or (16|M0)               r17.0<1>:d    r17.0<1;1,0>:d    -2147483648:d               {F@1}
        or (1|M0)                r1.4<1>:ud    r1.3<0;1,0>:ud    0x100:uw              {I@4}
        addc (8|M0)              r10.0<1>:ud   r15.0<2;1,0>:ud   r120.0<2;1,0>:ud {AccWrEn,Compacted,I@3}
        mov (8|M0)               r8.0<1>:d     r120.1<2;1,0>:d                 
        mov (8|M0)               r19.0<1>:hf   r17.0<1;1,0>:f                   {I@4}
        shl (1|M0)               r2.0<1>:d     r1.4<0;1,0>:d     1:w               {Compacted,I@3}
        mov (8|M0)               r13.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        addc (8|M0)              r17.0<1>:ud   r15.0<2;1,0>:ud   r118.0<2;1,0>:ud {AccWrEn,Compacted,F@1}
        mov (8|M0)               r19.8<1>:hf   r18.0<1;1,0>:f                  
        shr (1|M0)               r1.2<1>:ud    r1.4<0;1,0>:ud    0x1F:uw             
        mov (8|M0)               r20.0<2>:d    r10.0<1;1,0>:d                   {I@6}
        add3 (8|M0)              r12.0<1>:d    r13.0<1;0>:d      r15.1<4;2>:d      r8.0<1>:d        {I@4}
        mov (8|M0)               r18.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted,F@1}
        addc (1|M0)              r10.0<1>:ud   r86.3<0;1,0>:ud   r2.0<0;1,0>:ud   {AccWrEn}
        mov (8|M0)               r7.0<1>:d     r118.1<2;1,0>:d                 
        or (1|M0)                r2.1<1>:d     r1.2<0;1,0>:d     0:w               {I@6}
        mov (8|M0)               r20.1<2>:d    r12.0<1;1,0>:d                   {I@5}
        mov (1|M0)               r12.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r13.0<1>:ud   r10.0<0;1,0>:ud   r86.5<0;1,0>:ud  {AccWrEn,I@5}
        mov (8|M0)               r22.0<2>:d    r17.0<1;1,0>:d                  
        add3 (8|M0)              r9.0<1>:d     r18.0<1;0>:d      r15.1<4;2>:d      r7.0<1>:d        {I@6}
        add3 (1|M0)              r10.2<1>:d    r12.0<0;0>:d      r86.4<0;0>:d      r2.1<0>:d        {I@4}
        mov (1|M0)               r17.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (16|M0)              r24.0<1>:d    r6.0<1;1,0>:uw                  
        mov (1|M0)               r15.0<1>:f    r13.0<0;1,0>:f                   {Compacted,I@6}
        mov (8|M0)               r22.1<2>:d    r9.0<1;1,0>:d                    {I@4}
        add3 (1|M0)              r15.1<1>:d    r17.0<0;0>:d      r10.2<0;0>:d      r86.6<0>:d       {I@3}
        send.ugm (16|M0)         null     r20     r24:2   0x0            0x08000B84           {A@2,$2} // wr:4+2, rd:0; store.ugm.d16u32.a64
        sync.nop                             null                             {Compacted,$2.src}
        mov (8|M0)               r20.0<2>:f    r15.0<0;1,0>:f                   {Compacted,F@1}
        mov (8|M0)               r20.1<2>:f    r15.1<0;1,0>:f                   {Compacted,I@1}
        or (1|M0)                r1.4<1>:ud    r1.3<0;1,0>:ud    0x200:uw             
        addc (8|M0)              r6.0<1>:ud    r20.0<2;1,0>:ud   r120.0<2;1,0>:ud {AccWrEn,Compacted,A@1}
        shl (1|M0)               r2.0<1>:d     r1.4<0;1,0>:d     1:w               {Compacted,I@2}
        mov (8|M0)               r9.0<1>:ud    acc0.0<1;1,0>:ud                 {Compacted}
        addc (8|M0)              r12.0<1>:ud   r20.0<2;1,0>:ud   r118.0<2;1,0>:ud {AccWrEn,Compacted}
        shr (1|M0)               r1.2<1>:ud    r1.4<0;1,0>:ud    0x1F:uw             
        mov (8|M0)               r22.0<2>:d    r6.0<1;1,0>:d                    {I@5}
        mov (8|M0)               r18.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        addc (1|M0)              r6.0<1>:ud    r86.3<0;1,0>:ud   r2.0<0;1,0>:ud   {AccWrEn,I@6}
        add3 (8|M0)              r16.0<1>:d    r9.0<1;0>:d       r20.1<4;2>:d      r8.0<1>:d        {I@6}
        or (1|M0)                r2.1<1>:d     r1.2<0;1,0>:d     0:w               {I@5}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r10.0<1>:ud   r6.0<0;1,0>:ud    r86.5<0;1,0>:ud  {AccWrEn,I@4}
        mov (8|M0)               r24.0<2>:d    r12.0<1;1,0>:d                  
        add3 (1|M0)              r6.2<1>:d     r9.0<0;0>:d       r86.4<0;0>:d      r2.1<0>:d        {I@3}
        mov (1|M0)               r12.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r12.2<1>:d    r10.0<0;1,0>:d                   {I@4}
        add3 (1|M0)              r12.3<1>:d    r12.0<0;0>:d      r6.2<0;0>:d       r86.6<0>:d       {I@2}
        mov (8|M0)               r22.1<2>:d    r16.0<1;1,0>:d                  
        mov (8|M0)               r15.0<2>:ud   r12.2<0;1,0>:ud                  {I@3}
        mov (8|M0)               r15.1<2>:ud   r12.3<0;1,0>:ud                  {I@3}
        mov (16|M0)              r26.0<1>:d    r11.0<1;1,0>:uw                 
        add3 (8|M0)              r13.0<1>:d    r18.0<1;0>:d      r20.1<4;2>:d      r7.0<1>:d       
        or (1|M0)                r2.0<1>:ud    r1.3<0;1,0>:ud    0x300:uw             
        addc (8|M0)              r11.0<1>:ud   r15.0<2;1,0>:ud   r120.0<2;1,0>:ud {AccWrEn,Compacted,I@4}
        mov (8|M0)               r24.1<2>:d    r13.0<1;1,0>:d                   {I@3}
        shl (1|M0)               r6.0<1>:d     r2.0<0;1,0>:d     1:w               {Compacted,I@3}
        mov (8|M0)               r13.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        addc (8|M0)              r9.0<1>:ud    r15.0<2;1,0>:ud   r118.0<2;1,0>:ud {AccWrEn,Compacted}
        shr (1|M0)               r3.3<1>:ud    r2.0<0;1,0>:ud    0x1F:uw             
        mov (8|M0)               r20.0<2>:d    r11.0<1;1,0>:d                   {I@6}
        mov (8|M0)               r18.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        addc (1|M0)              r11.0<1>:ud   r86.3<0;1,0>:ud   r6.0<0;1,0>:ud   {AccWrEn,I@6}
        add3 (8|M0)              r17.0<1>:d    r13.0<1;0>:d      r15.1<4;2>:d      r8.0<1>:d        {I@6}
        or (1|M0)                r6.1<1>:d     r3.3<0;1,0>:d     0:w               {I@5}
        mov (1|M0)               r12.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r13.0<1>:ud   r11.0<0;1,0>:ud   r86.5<0;1,0>:ud  {AccWrEn,I@4}
        send.ugm (16|M0)         null     r22     r26:2   0x0            0x08000B84           {$14} // wr:4+2, rd:0; store.ugm.d16u32.a64
        add3 (1|M0)              r11.2<1>:d    r12.0<0;0>:d      r86.4<0;0>:d      r6.1<0>:d        {I@2}
        mov (8|M0)               r22.0<2>:d    r9.0<1;1,0>:d                    {$14.src}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r9.2<1>:d     r13.0<0;1,0>:d                   {I@4}
        add3 (1|M0)              r9.3<1>:d     r9.0<0;0>:d       r11.2<0;0>:d      r86.6<0>:d       {I@2}
        add3 (8|M0)              r10.0<1>:d    r18.0<1;0>:d      r15.1<4;2>:d      r7.0<1>:d       
        mov (16|M0)              r24.0<1>:d    r14.0<1;1,0>:uw                 
        mov (8|M0)               r14.0<2>:ud   r9.2<0;1,0>:ud                   {I@4}
        mov (8|M0)               r14.1<2>:ud   r9.3<0;1,0>:ud                   {I@4}
        mov (8|M0)               r22.1<2>:d    r10.0<1;1,0>:d                   {I@4}
        addc (8|M0)              r10.0<1>:ud   r14.0<2;1,0>:ud   r120.0<2;1,0>:ud {AccWrEn,Compacted,I@2}
        mov (8|M0)               r20.1<2>:d    r17.0<1;1,0>:d                  
        mov (8|M0)               r16.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        addc (8|M0)              r6.0<1>:ud    r14.0<2;1,0>:ud   r118.0<2;1,0>:ud {AccWrEn,Compacted}
        add3 (8|M0)              r17.0<1>:d    r16.0<1;0>:d      r14.1<4;2>:d      r8.0<1>:d        {I@2}
        mov (8|M0)               r12.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        send.ugm (16|M0)         null     r20     r24:2   0x0            0x08000B84           {$15} // wr:4+2, rd:0; store.ugm.d16u32.a64
        add3 (8|M0)              r13.0<1>:d    r12.0<1;0>:d      r14.1<4;2>:d      r7.0<1>:d        {I@1}
        mov (8|M0)               r20.0<2>:d    r10.0<1;1,0>:d                   {$15.src}
        mov (8|M0)               r22.0<2>:d    r6.0<1;1,0>:d                   
        mov (16|M0)              r24.0<1>:d    r19.0<1;1,0>:uw                 
        mov (8|M0)               r20.1<2>:d    r17.0<1;1,0>:d                  
        mov (8|M0)               r22.1<2>:d    r13.0<1;1,0>:d                   {I@5}
        send.ugm (16|M0)         null     r20     r24:2   0x0            0x08000B84           {A@1,$13} // wr:4+2, rd:0; store.ugm.d16u32.a64
(W)     send.slm (1|M0)          r9       r0      null:0  0x0            0x0210001F           {$5} // wr:1+0, rd:1; fence.slm.none.group
(W)     mov (1|M0)               r11.2<1>:f    0.0:f                               {Compacted}
(W)     mov (2|M0)               r11.10<1>:ub  r0.11<0;1,0>:ub                  {F@1}
(W)     mov (8|M0)               null<1>:ud    r9.0<1;1,0>:ud                   {$5.dst}
(W)     send.gtwy (1|M0)         null     r11     null:0  0x0            0x02000004           {A@2,$7} // wr:1+0, rd:0; signal barrier
(W)     sync.bar                             null                            
        cmp (1|M0)    (eq)f1.1   null<1>:d     r2.6<0;1,0>:d     6:w              
(W)     and (1|M0)               f1.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(f1.1.any16h) goto (16|M0)                   L37288                  L37288                
L21744:
        cmp (1|M0)    (lt)f0.1   null<1>:uw    r1.0<0;1,0>:uw    0x80:uw             
        addc (1|M0)              r2.0<1>:ud    r122.0<0;1,0>:ud  0x9000:ud              {AccWrEn}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r7.0<1>:ud    r122.0<0;1,0>:ud  0x10000:ud              {AccWrEn}
(W)     and (1|M0)               f1.0<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r91.2<1>:d    r2.0<0;1,0>:d                    {I@5}
        add3 (1|M0)              r91.3<1>:d    r6.0<0;0>:d       r122.1<0;0>:d     0:w               {I@5}
        mov (1|M0)               r110.2<1>:d   r7.0<0;1,0>:d                    {I@5}
        add3 (1|M0)              r110.3<1>:d   r8.0<0;0>:d       r122.1<0;0>:d     0:w               {I@4}
(~f1.0.any16h) goto (16|M0)                  L26248                  L26248                
L21904:
        and (1|M0)               r1.2<1>:ud    r122.3<0;1,0>:ud  0x1:uw             
        shr (1|M0)               r1.3<1>:ud    r94.2<0;1,0>:ud   0x4:uw             
        shl (1|M0)               r2.0<1>:ud    r1.2<0;1,0>:ud    0x8:uw              {I@2}
        shl (1|M0)               r1.4<1>:d     r94.3<0;1,0>:d    28:w              
        shl (1|M0)               r6.0<1>:d     r2.0<0;1,0>:d     1:w               {Compacted,I@2}
        shr (1|M0)               r3.3<1>:ud    r2.0<0;1,0>:ud    0x1F:uw             
        addc (1|M0)              r7.0<1>:ud    r91.2<0;1,0>:ud   r6.0<0;1,0>:ud   {AccWrEn,I@2}
        or (1|M0)                r6.1<1>:d     r3.3<0;1,0>:d     0:w               {I@2}
        mov (1|M0)               r91.0<1>:f    r7.0<0;1,0>:f                    {Compacted,I@2}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r9.0<1>:ud    r91.0<0;1,0>:ud   0x100:ud              {AccWrEn,F@1}
        add3 (1|M0)              r91.1<1>:d    r8.0<0;0>:d       r91.3<0;0>:d      r6.1<0>:d        {I@2}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r11.0<1>:ud   r91.0<0;1,0>:ud   0x400:ud              {AccWrEn,$7.src}
        mov (1|M0)               r102.0<1>:f   r9.0<0;1,0>:f                    {Compacted,I@4}
        mov (1|M0)               r93.0<1>:f    r11.0<0;1,0>:f                   {Compacted,I@1}
        mov (1|M0)               r12.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r2.0<1>:ud    r93.0<0;1,0>:ud   0x100:ud              {AccWrEn,F@1}
        add3 (1|M0)              r102.1<1>:d   r10.0<0;0>:d      r91.1<0;0>:d      0:w              
        mov (1|M0)               r13.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r6.0<1>:ud    r91.0<0;1,0>:ud   0x800:ud              {AccWrEn}
        mov (1|M0)               r92.0<1>:f    r2.0<0;1,0>:f                    {Compacted,I@4}
        mov (1|M0)               r90.0<1>:f    r6.0<0;1,0>:f                    {Compacted,I@1}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r8.0<1>:ud    r90.0<0;1,0>:ud   0x100:ud              {AccWrEn,F@1}
        shl (1|M0)               r6.0<1>:ud    r1.2<0;1,0>:ud    0x4:uw             
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r10.0<1>:ud   r91.0<0;1,0>:ud   0xC00:ud              {AccWrEn}
        add3 (1|M0)              r90.1<1>:d    r7.0<0;0>:d       r91.1<0;0>:d      0:w               {I@5}
        mov (1|M0)               r88.0<1>:f    r10.0<0;1,0>:f                   {Compacted,I@2}
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        shl (1|M0)               r7.0<1>:d     r6.0<0;1,0>:d     2:w               {Compacted}
        addc (1|M0)              r2.0<1>:ud    r88.0<0;1,0>:ud   0x100:ud              {AccWrEn,F@1}
        add3 (1|M0)              r93.1<1>:d    r12.0<0;0>:d      r91.1<0;0>:d      0:w              
        mov (1|M0)               r89.0<1>:f    r8.0<0;1,0>:f                    {Compacted}
        shr (1|M0)               r3.3<1>:ud    r6.0<0;1,0>:ud    0x1E:uw             
        mov (1|M0)               r12.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r8.0<1>:ud    r110.2<0;1,0>:ud  r7.0<0;1,0>:ud   {AccWrEn,A@1}
        add3 (1|M0)              r89.1<1>:d    r9.0<0;0>:d       r90.1<0;0>:d      0:w              
        add3 (1|M0)              r88.1<1>:d    r11.0<0;0>:d      r91.1<0;0>:d      0:w              
        or (1|M0)                r7.1<1>:d     r3.3<0;1,0>:d     0:w               {I@5}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        shr (1|M0)               r110.5<1>:ud  r94.3<0;1,0>:ud   0x4:uw             
        mov (16|M0)              r96.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r98.0<1>:f    0.0:f                               {Compacted}
        mov (16|M0)              r100.0<1>:f   0.0:f                               {Compacted}
        sync.nop                             null                             {Compacted,$11.dst}
        mov (16|M0)              r94.0<1>:f    0.0:f                               {Compacted,I@1}
        or (1|M0)                r110.4<1>:d   r1.3<0;1,0>:d     r1.4<0;1,0>:d   
        mov (1|M0)               r87.0<1>:f    r2.0<0;1,0>:f                    {Compacted}
        add3 (1|M0)              r92.1<1>:d    r13.0<0;0>:d      r93.1<0;0>:d      0:w              
        mov (1|M0)               r110.6<1>:d   r8.0<0;1,0>:d                   
        add3 (1|M0)              r87.1<1>:d    r12.0<0;0>:d      r88.1<0;0>:d      0:w              
        add3 (1|M0)              r110.7<1>:d   r9.0<0;0>:d       r110.3<0;0>:d     r7.1<0>:d       
L22576:
        shr (1|M0)               r1.2<1>:ud    r110.4<0;1,0>:ud  0x1:uw              {I@5}
        shl (1|M0)               r1.3<1>:d     r110.5<0;1,0>:d   31:w              
        shr (1|M0)               r2.1<1>:ud    r110.5<0;1,0>:ud  0x1:uw             
        or (1|M0)                r2.0<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {A@1}
        shl (1|M0)               r3.3<1>:d     r2.1<0;1,0>:d     10:w               {I@2}
        shl (1|M0)               r6.1<1>:d     r2.0<0;1,0>:d     10:w               {Compacted,I@2}
        shr (1|M0)               r6.0<1>:ud    r2.0<0;1,0>:ud    0x16:uw             
        shl (1|M0)               r7.2<1>:d     r6.1<0;1,0>:d     1:w               {I@2}
        or (1|M0)                r6.2<1>:d     r3.3<0;1,0>:d     r6.0<0;1,0>:d    {I@2}
        sync.nop                             null                             {Compacted,$0.src}
        addc (1|M0)              r8.0<1>:ud    r86.3<0;1,0>:ud   r7.2<0;1,0>:ud   {AccWrEn,I@2}
        shr (1|M0)               r7.1<1>:ud    r6.1<0;1,0>:ud    0x1F:uw             
        shl (1|M0)               r7.0<1>:d     r6.2<0;1,0>:d     1:w               {Compacted,I@3}
        sync.nop                             null                             {Compacted,$8.src}
        mov (1|M0)               r10.0<1>:f    r8.0<0;1,0>:f                    {Compacted,I@3}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        or (1|M0)                r7.3<1>:d     r7.0<0;1,0>:d     r7.1<0;1,0>:d    {I@2}
        addc (1|M0)              r19.0<1>:ud   r10.0<0;1,0>:ud   0x100:ud              {AccWrEn,F@1}
        add3 (1|M0)              r10.1<1>:d    r9.0<0;0>:d       r86.4<0;0>:d      r7.3<0>:d        {I@2}
        mov (1|M0)               r20.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,$13.src}
        mov (1|M0)               r21.0<1>:f    r19.0<0;1,0>:f                   {Compacted,I@3}
        add3 (1|M0)              r21.1<1>:d    r20.0<0;0>:d      r10.1<0;0>:d      0:w               {I@1}
        send.ugm (1|M0)          r30      r91     null:0  0x0            0x0280E780           {$10} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        send.ugm (1|M0)          r38      r102    null:0  0x0            0x0280E780           {$1} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        send.ugm (1|M0)          r11      r10     null:0  0x0            0x0280E780           {$9} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        send.ugm (1|M0)          r22      r21     null:0  0x0            0x0280E780           {A@1,$11} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        addc (1|M0)              r6.0<1>:ud    r10.0<0;1,0>:ud   0x200:ud              {AccWrEn}
        shl (1|M0)               r1.4<1>:d     r2.0<0;1,0>:d     9:w               {Compacted}
        mov (1|M0)               r8.0<1>:f     r6.0<0;1,0>:f                    {Compacted,I@2}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r9.0<1>:ud    r8.0<0;1,0>:ud    0x100:ud              {AccWrEn,F@1}
        add3 (1|M0)              r8.1<1>:d     r7.0<0;0>:d       r10.1<0;0>:d      0:w               {I@2}
        mov (1|M0)               r19.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r20.0<1>:f    r9.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r20.1<1>:d    r19.0<0;0>:d      r8.1<0;0>:d       0:w               {I@1}
        send.ugm (1|M0)          r78      r8      null:0  0x0            0x0280E780           {$6} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        addc (1|M0)              r6.0<1>:ud    r10.0<0;1,0>:ud   0x400:ud              {AccWrEn}
        shl (1|M0)               r6.1<1>:d     r1.4<0;1,0>:d     2:w              
        sync.nop                             null                             {Compacted,$6.src}
        mov (1|M0)               r8.0<1>:f     r6.0<0;1,0>:f                    {Compacted,I@2}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r9.0<1>:ud    r8.0<0;1,0>:ud    0x100:ud              {AccWrEn,F@1}
        add3 (1|M0)              r8.1<1>:d     r7.0<0;0>:d       r10.1<0;0>:d      0:w               {I@2}
        mov (1|M0)               r19.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r6.0<1>:ud    r10.0<0;1,0>:ud   0x600:ud              {AccWrEn}
        shl (1|M0)               r1.2<1>:d     r2.1<0;1,0>:d     9:w              
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        shr (1|M0)               r1.3<1>:ud    r2.0<0;1,0>:ud    0x17:uw             
        cmp (1|M0)    (lt)f1.1   null<1>:ud    r110.4<0;1,0>:ud  0x4:uw             
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        shl (1|M0)               r3.3<1>:d     r1.5<0;1,0>:d     2:w               {I@1}
(f1.1)  cmp (1|M0)    (eq)f1.1   null<1>:d     r110.5<0;1,0>:d   0:w              
(W)     and (1|M0)               f1.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
        sync.allwr                           ($1,$9,$10,$11)                
        sync.allrd                           ($3,$4)                
        dpas.8x8 (8|M0)          r46:f         null:f            r46:hf            r46.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r46:f         r94:f             r38:hf            r11.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r54:f         r94:f             r30:hf            r11.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r62:f         r94:f             r30:hf            r22.0:hf         {$10}
        sync.nop                             null                             {Compacted,$10.src}
        send.ugm (1|M0)          r11      r20     null:0  0x0            0x0280E780           {$2} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        sync.nop                             null                             {Compacted,$12.src}
        dpas.8x8 (8|M0)          r70:f         r94:f             r38:hf            r22.0:hf         {$8}
        sync.nop                             null                             {Compacted,$8.src}
        send.ugm (1|M0)          r21      r93     null:0  0x0            0x0280E780           {$0} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        send.ugm (1|M0)          r29      r92     null:0  0x0            0x0280E780           {$4} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        mov (1|M0)               r20.0<1>:f    r9.0<0;1,0>:f                    {Compacted,$2.src}
        add3 (1|M0)              r20.1<1>:d    r19.0<0;0>:d      r8.1<0;0>:d       0:w              
        send.ugm (1|M0)          r37      r8      null:0  0x0            0x0280E780           {$3} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        mov (1|M0)               r8.0<1>:f     r6.0<0;1,0>:f                    {Compacted,$3.src}
        add3 (1|M0)              r8.1<1>:d     r7.0<0;0>:d       r10.1<0;0>:d      0:w              
        addc (1|M0)              r9.0<1>:ud    r8.0<0;1,0>:ud    0x100:ud              {AccWrEn,F@1}
        shr (1|M0)               r6.0<1>:ud    r1.4<0;1,0>:ud    0x1E:uw             
        mov (1|M0)               r19.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r7.0<1>:ud    r110.6<0;1,0>:ud  r6.1<0;1,0>:ud   {AccWrEn}
        or (1|M0)                r6.2<1>:d     r3.3<0;1,0>:d     r6.0<0;1,0>:d    {I@3}
        sync.allwr                           ($0,$2,$6,$10)                
        dpas.8x8 (8|M0)          r54:f         null:f            r54:hf            r54.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r54:f         r54:f             r21:hf            r78.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r62:f         r62:f             r21:hf            r11.0:hf         {$6}
        sync.nop                             null                             {Compacted,$6.src}
        send.ugm (1|M0)          r21      r20     null:0  0x0            0x0280E780           {$12} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        sync.allwr                           ($4,$8)                
        dpas.8x8 (8|M0)          r46:f         null:f            r46:hf            r46.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r46:f         r46:f             r29:hf            r78.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r70:f         r70:f             r29:hf            r11.0:hf         {$8}
        sync.nop                             null                             {Compacted,$8.src}
        send.ugm (1|M0)          r11      r90     null:0  0x0            0x0280E780           {$14} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        send.ugm (1|M0)          r29      r89     null:0  0x0            0x0280E780           {$15} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        send.ugm (1|M0)          r78      r8      null:0  0x0            0x0280E780           {$13} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        mov (1|M0)               r20.0<1>:f    r9.0<0;1,0>:f                    {Compacted,$12.src}
        add3 (1|M0)              r20.1<1>:d    r19.0<0;0>:d      r8.1<0;0>:d       0:w               {I@3}
        mov (1|M0)               r9.0<1>:f     r7.0<0;1,0>:f                    {Compacted,I@3}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$13.src}
        addc (1|M0)              r10.0<1>:ud   r9.0<0;1,0>:ud    0x20:ud              {AccWrEn,F@1}
        add3 (1|M0)              r9.1<1>:d     r8.0<0;0>:d       r110.7<0;0>:d     r6.2<0>:d        {I@2}
        mov (1|M0)               r2.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        sync.allwr                           ($3,$6,$8,$12,$14,$15)                
        dpas.8x8 (8|M0)          r62:f         r62:f             r11:hf            r21.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r46:f         r46:f             r29:hf            r37.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r70:f         r70:f             r29:hf            r21.0:hf         {$3}
        sync.nop                             null                             {Compacted,$3.src}
        send.ugm (1|M0)          r21      r88     null:0  0x0            0x0280E780           {$5} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        send.ugm (1|M0)          r29      r87     null:0  0x0            0x0280E780           {$7} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        dpas.8x8 (8|M0)          r54:f         r54:f             r11:hf            r37.0:hf         {$1}
        sync.nop                             null                             {Compacted,$1.src}
        send.ugm (1|M0)          r11      r20     null:0  0x0            0x0280E780           {$9} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        sync.allwr                           ($1,$3,$5,$7,$9,$13)                
        dpas.8x8 (8|M0)          r54:f         r54:f             r21:hf            r78.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r46:f         r46:f             r29:hf            r78.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r62:f         r62:f             r21:hf            r11.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r70:f         r70:f             r29:hf            r11.0:hf         {$13}
        addc (1|M0)              r12.0<1>:ud   r9.0<0;1,0>:ud    0x400:ud              {AccWrEn,$13.src}
        mov (1|M0)               r11.0<1>:f    r10.0<0;1,0>:f                   {Compacted,I@4}
        mov (1|M0)               r13.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r6.0<1>:ud    r9.0<0;1,0>:ud    0x420:ud              {AccWrEn}
        add3 (1|M0)              r11.1<1>:d    r2.0<0;0>:d       r9.1<0;0>:d       0:w               {I@4}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r2.0<1>:ud    r9.0<0;1,0>:ud    0x80:ud              {AccWrEn}
        send.ugm (1|M0)          null     r9      r54:1   0x0            0x0200C584           {$13} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r11     r46:1   0x0            0x0200C584           {A@1,$11} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        sync.nop                             null                             {Compacted,$11.src}
        mov (1|M0)               r11.0<1>:f    r2.0<0;1,0>:f                    {Compacted,I@1}
        mov (1|M0)               r14.0<1>:f    r12.0<0;1,0>:f                   {Compacted}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r12.0<1>:ud   r11.0<0;1,0>:ud   0x20:ud              {AccWrEn,A@1}
        add3 (1|M0)              r14.1<1>:d    r13.0<0;0>:d      r9.1<0;0>:d       0:w              
        mov (1|M0)               r8.0<1>:f     r6.0<0;1,0>:f                    {Compacted}
        mov (1|M0)               r13.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r6.0<1>:ud    r11.0<0;1,0>:ud   0x400:ud              {AccWrEn,F@1}
        add3 (1|M0)              r8.1<1>:d     r7.0<0;0>:d       r9.1<0;0>:d       0:w              
        add3 (1|M0)              r11.1<1>:d    r10.0<0;0>:d      r9.1<0;0>:d       0:w               {I@6}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r2.0<1>:ud    r11.0<0;1,0>:ud   0x420:ud              {AccWrEn}
        send.ugm (1|M0)          null     r14     r62:1   0x0            0x0200C584           {A@7,$10} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        mov (1|M0)               r14.0<1>:f    r12.0<0;1,0>:f                   {Compacted,$10.src}
        add3 (1|M0)              r14.1<1>:d    r13.0<0;0>:d      r11.1<0;0>:d      0:w               {I@3}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r12.0<1>:ud   r9.0<0;1,0>:ud    0x100:ud              {AccWrEn,F@1}
        send.ugm (1|M0)          null     r8      r70:1   0x0            0x0200C584           {$2} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r11     r55:1   0x0            0x0200C584           {$0} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r14     r47:1   0x0            0x0200C584           {A@3,$4} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        sync.nop                             null                             {Compacted,$4.src}
        mov (1|M0)               r14.0<1>:f    r12.0<0;1,0>:f                   {Compacted,I@1}
        mov (1|M0)               r8.0<1>:f     r6.0<0;1,0>:f                    {Compacted,$2.src}
        mov (1|M0)               r13.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r6.0<1>:ud    r14.0<0;1,0>:ud   0x20:ud              {AccWrEn,A@1}
        mov (1|M0)               r15.0<1>:f    r2.0<0;1,0>:f                    {Compacted}
        add3 (1|M0)              r8.1<1>:d     r7.0<0;0>:d       r11.1<0;0>:d      0:w              
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r2.0<1>:ud    r14.0<0;1,0>:ud   0x400:ud              {AccWrEn,F@1}
        add3 (1|M0)              r15.1<1>:d    r10.0<0;0>:d      r11.1<0;0>:d      0:w              
        add3 (1|M0)              r14.1<1>:d    r13.0<0;0>:d      r9.1<0;0>:d       0:w               {I@6}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r12.0<1>:ud   r14.0<0;1,0>:ud   0x420:ud              {AccWrEn}
        send.ugm (1|M0)          null     r8      r63:1   0x0            0x0200C584           {A@7,$6} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        mov (1|M0)               r8.0<1>:f     r6.0<0;1,0>:f                    {Compacted,$6.src}
        add3 (1|M0)              r8.1<1>:d     r7.0<0;0>:d       r14.1<0;0>:d      0:w               {I@3}
        mov (1|M0)               r13.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r6.0<1>:ud    r9.0<0;1,0>:ud    0x180:ud              {AccWrEn,F@1}
        send.ugm (1|M0)          null     r15     r71:1   0x0            0x0200C584           {$12} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r14     r56:1   0x0            0x0200C584           {$8} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r8      r48:1   0x0            0x0200C584           {A@3,$14} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        sync.nop                             null                             {Compacted,$14.src}
        mov (1|M0)               r8.0<1>:f     r6.0<0;1,0>:f                    {Compacted,I@1}
        mov (1|M0)               r11.0<1>:f    r2.0<0;1,0>:f                    {Compacted,$0.src}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r2.0<1>:ud    r8.0<0;1,0>:ud    0x20:ud              {AccWrEn,A@1}
        add3 (1|M0)              r11.1<1>:d    r10.0<0;0>:d      r14.1<0;0>:d      0:w              
        mov (1|M0)               r15.0<1>:f    r12.0<0;1,0>:f                   {Compacted,$12.src}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r12.0<1>:ud   r8.0<0;1,0>:ud    0x400:ud              {AccWrEn,F@1}
        add3 (1|M0)              r15.1<1>:d    r13.0<0;0>:d      r14.1<0;0>:d      0:w              
        add3 (1|M0)              r8.1<1>:d     r7.0<0;0>:d       r9.1<0;0>:d       0:w               {I@6}
        mov (1|M0)               r13.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r6.0<1>:ud    r8.0<0;1,0>:ud    0x420:ud              {AccWrEn}
        send.ugm (1|M0)          null     r11     r64:1   0x0            0x0200C584           {A@7,$15} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        mov (1|M0)               r11.0<1>:f    r2.0<0;1,0>:f                    {Compacted,$15.src}
        add3 (1|M0)              r11.1<1>:d    r10.0<0;0>:d      r8.1<0;0>:d       0:w               {I@3}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r2.0<1>:ud    r9.0<0;1,0>:ud    0x200:ud              {AccWrEn,F@1}
        send.ugm (1|M0)          null     r15     r72:1   0x0            0x0200C584           {$3} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r8      r57:1   0x0            0x0200C584           {$5} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r11     r49:1   0x0            0x0200C584           {A@3,$7} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        sync.nop                             null                             {Compacted,$7.src}
        mov (1|M0)               r11.0<1>:f    r2.0<0;1,0>:f                    {Compacted,I@1}
        mov (1|M0)               r14.0<1>:f    r12.0<0;1,0>:f                   {Compacted,$8.src}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r12.0<1>:ud   r11.0<0;1,0>:ud   0x20:ud              {AccWrEn,A@1}
        add3 (1|M0)              r14.1<1>:d    r13.0<0;0>:d      r8.1<0;0>:d       0:w              
        mov (1|M0)               r15.0<1>:f    r6.0<0;1,0>:f                    {Compacted,$3.src}
        mov (1|M0)               r13.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r6.0<1>:ud    r11.0<0;1,0>:ud   0x400:ud              {AccWrEn,F@1}
        add3 (1|M0)              r15.1<1>:d    r7.0<0;0>:d       r8.1<0;0>:d       0:w              
        add3 (1|M0)              r11.1<1>:d    r10.0<0;0>:d      r9.1<0;0>:d       0:w               {I@6}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r2.0<1>:ud    r11.0<0;1,0>:ud   0x420:ud              {AccWrEn}
        send.ugm (1|M0)          null     r14     r65:1   0x0            0x0200C584           {A@7,$1} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        mov (1|M0)               r14.0<1>:f    r12.0<0;1,0>:f                   {Compacted,$1.src}
        add3 (1|M0)              r14.1<1>:d    r13.0<0;0>:d      r11.1<0;0>:d      0:w               {I@3}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r12.0<1>:ud   r9.0<0;1,0>:ud    0x280:ud              {AccWrEn,F@1}
        send.ugm (1|M0)          null     r15     r73:1   0x0            0x0200C584           {$9} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r11     r58:1   0x0            0x0200C584           {$13} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r14     r50:1   0x0            0x0200C584           {A@3,$11} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        sync.nop                             null                             {Compacted,$11.src}
        mov (1|M0)               r14.0<1>:f    r12.0<0;1,0>:f                   {Compacted,I@1}
        mov (1|M0)               r8.0<1>:f     r6.0<0;1,0>:f                    {Compacted,$5.src}
        mov (1|M0)               r13.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r6.0<1>:ud    r14.0<0;1,0>:ud   0x20:ud              {AccWrEn,A@1}
        add3 (1|M0)              r8.1<1>:d     r7.0<0;0>:d       r11.1<0;0>:d      0:w              
        mov (1|M0)               r15.0<1>:f    r2.0<0;1,0>:f                    {Compacted,$9.src}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r2.0<1>:ud    r14.0<0;1,0>:ud   0x400:ud              {AccWrEn,F@1}
        add3 (1|M0)              r15.1<1>:d    r10.0<0;0>:d      r11.1<0;0>:d      0:w              
        add3 (1|M0)              r14.1<1>:d    r13.0<0;0>:d      r9.1<0;0>:d       0:w               {I@6}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r12.0<1>:ud   r14.0<0;1,0>:ud   0x420:ud              {AccWrEn}
        send.ugm (1|M0)          null     r8      r66:1   0x0            0x0200C584           {A@7,$10} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        mov (1|M0)               r8.0<1>:f     r6.0<0;1,0>:f                    {Compacted,$10.src}
        add3 (1|M0)              r8.1<1>:d     r7.0<0;0>:d       r14.1<0;0>:d      0:w               {I@3}
        mov (1|M0)               r13.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r6.0<1>:ud    r9.0<0;1,0>:ud    0x300:ud              {AccWrEn,F@1}
        send.ugm (1|M0)          null     r15     r74:1   0x0            0x0200C584           {$2} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r14     r59:1   0x0            0x0200C584           {$6} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r8      r51:1   0x0            0x0200C584           {A@3,$14} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        sync.nop                             null                             {Compacted,$14.src}
        mov (1|M0)               r8.0<1>:f     r6.0<0;1,0>:f                    {Compacted,I@1}
        mov (1|M0)               r11.0<1>:f    r2.0<0;1,0>:f                    {Compacted,$13.src}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r2.0<1>:ud    r8.0<0;1,0>:ud    0x20:ud              {AccWrEn,A@1}
        add3 (1|M0)              r11.1<1>:d    r10.0<0;0>:d      r14.1<0;0>:d      0:w              
        mov (1|M0)               r15.0<1>:f    r12.0<0;1,0>:f                   {Compacted,$2.src}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r12.0<1>:ud   r8.0<0;1,0>:ud    0x400:ud              {AccWrEn,F@1}
        add3 (1|M0)              r15.1<1>:d    r13.0<0;0>:d      r14.1<0;0>:d      0:w              
        add3 (1|M0)              r8.1<1>:d     r7.0<0;0>:d       r9.1<0;0>:d       0:w               {I@6}
        mov (1|M0)               r13.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r6.0<1>:ud    r8.0<0;1,0>:ud    0x420:ud              {AccWrEn}
        send.ugm (1|M0)          null     r11     r67:1   0x0            0x0200C584           {A@7,$15} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        mov (1|M0)               r11.0<1>:f    r2.0<0;1,0>:f                    {Compacted,$15.src}
        add3 (1|M0)              r11.1<1>:d    r10.0<0;0>:d      r8.1<0;0>:d       0:w               {I@3}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r2.0<1>:ud    r9.0<0;1,0>:ud    0x380:ud              {AccWrEn,F@1}
        send.ugm (1|M0)          null     r15     r75:1   0x0            0x0200C584           {$5} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r8      r60:1   0x0            0x0200C584           {$7} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r11     r52:1   0x0            0x0200C584           {A@3,$1} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        sync.nop                             null                             {Compacted,$1.src}
        mov (1|M0)               r11.0<1>:f    r2.0<0;1,0>:f                    {Compacted,I@1}
        mov (1|M0)               r14.0<1>:f    r12.0<0;1,0>:f                   {Compacted,$6.src}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r12.0<1>:ud   r11.0<0;1,0>:ud   0x20:ud              {AccWrEn,A@1}
        add3 (1|M0)              r14.1<1>:d    r13.0<0;0>:d      r8.1<0;0>:d       0:w              
        mov (1|M0)               r15.0<1>:f    r6.0<0;1,0>:f                    {Compacted,$5.src}
        mov (1|M0)               r13.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r6.0<1>:ud    r11.0<0;1,0>:ud   0x400:ud              {AccWrEn,F@1}
        add3 (1|M0)              r15.1<1>:d    r7.0<0;0>:d       r8.1<0;0>:d       0:w              
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r2.0<1>:ud    r11.0<0;1,0>:ud   0x420:ud              {AccWrEn}
        send.ugm (1|M0)          null     r14     r68:1   0x0            0x0200C584           {A@6,$9} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        add3 (1|M0)              r11.1<1>:d    r10.0<0;0>:d      r9.1<0;0>:d       0:w              
        mov (1|M0)               r14.0<1>:f    r12.0<0;1,0>:f                   {Compacted,$9.src}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$13.src}
        addc (1|M0)              r12.0<1>:ud   r110.4<0;1,0>:ud  0x4:ud              {AccWrEn,F@1}
        sync.nop                             null                             {Compacted,$7.src}
        mov (1|M0)               r8.0<1>:f     r6.0<0;1,0>:f                    {Compacted,I@7}
        mov (1|M0)               r10.0<1>:f    r2.0<0;1,0>:f                    {Compacted,A@3}
        add3 (1|M0)              r14.1<1>:d    r13.0<0;0>:d      r11.1<0;0>:d      0:w              
        add3 (1|M0)              r8.1<1>:d     r7.0<0;0>:d       r11.1<0;0>:d      0:w              
        add3 (1|M0)              r10.1<1>:d    r9.0<0;0>:d       r11.1<0;0>:d      0:w               {I@4}
        mov (1|M0)               r13.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        send.ugm (1|M0)          null     r15     r76:1   0x0            0x0200C584           {$12} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r11     r61:1   0x0            0x0200C584           {$3} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r14     r53:1   0x0            0x0200C584           {A@4,$4} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r8      r69:1   0x0            0x0200C584           {A@2,$0} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r10     r77:1   0x0            0x0200C584           {A@1,$8} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        mov (1|M0)               r2.0<1>:f     r12.0<0;1,0>:f                   {Compacted}
        add3 (1|M0)              r2.1<1>:d     r13.0<0;0>:d      r110.5<0;0>:d     0:w               {I@1}
(~f1.1.any16h) goto (16|M0)                  L26248                  L26248                
L26216:
(W)     mov (2|M0)               r110.4<1>:ud  r2.0<1;1,0>:ud                   {A@1}
        goto.b (16|M0)                       L26248                  L22576                
L26248:
        join (16|M0)                         L37288                                
L26264:
(W)     send.slm (1|M0)          r6       r0      null:0  0x0            0x0210001F           {$13} // wr:1+0, rd:1; fence.slm.none.group
(W)     mov (1|M0)               r7.2<1>:f     0.0:f                               {Compacted}
(W)     mov (2|M0)               r7.10<1>:ub   r0.11<0;1,0>:ub                  {F@1}
(W)     mov (8|M0)               null<1>:ud    r6.0<1;1,0>:ud                   {$13.dst}
(W)     send.gtwy (1|M0)         null     r7      null:0  0x0            0x02000004           {A@2,$11} // wr:1+0, rd:0; signal barrier
(W)     sync.bar                             null                            
        cmp (1|M0)    (eq)f1.0   null<1>:d     r2.6<0;1,0>:d     8:w              
(W)     and (1|M0)               f1.0<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
(f1.0.any16h) goto (16|M0)                   L36400                  L36400                
L26400:
        shl (1|M0)               r85.2<1>:ud   r110.0<0;1,0>:ud  0x5:uw             
        mov (1|M0)               r85.3<1>:d    0:w                              
        shl (1|M0)               r85.0<1>:d    r85.2<0;1,0>:d    2:w               {Compacted,I@2}
        shr (1|M0)               r1.3<1>:ud    r85.2<0;1,0>:ud   0x1E:uw             
        shl (1|M0)               r1.2<1>:d     r85.3<0;1,0>:d    2:w               {I@3}
        addc (1|M0)              r2.0<1>:ud    r110.2<0;1,0>:ud  r85.0<0;1,0>:ud  {AccWrEn,I@3}
        or (1|M0)                r85.1<1>:d    r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        sync.nop                             null                             {Compacted,$11.src}
        mov (1|M0)               r7.0<1>:f     r2.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r7.1<1>:d     r6.0<0;0>:d       r110.3<0;0>:d     r85.1<0>:d       {I@1}
        addc (1|M0)              r2.0<1>:ud    r122.0<0;1,0>:ud  0x12000:ud              {AccWrEn,F@1}
        sync.nop                             null                             {Compacted,$7.src}
        send.ugm (1|M0)          r8       r7      null:0  0x0            0x0240E580           {A@2,$10} // wr:1+0, rd:4; load.ugm.d32x32t.a64
        shl (1|M0)               r1.3<1>:d     r110.1<0;1,0>:d   1:w              
        mov (1|M0)               r85.4<1>:d    r2.0<0;1,0>:d                    {I@2}
        shr (1|M0)               r1.2<1>:ud    r110.1<0;1,0>:ud  0x1F:uw             
        shl (1|M0)               r86.2<1>:ud   r110.0<0;1,0>:ud  0x5:uw             
        or (1|M0)                r1.4<1>:d     r1.2<0;1,0>:d     0:w               {I@2}
        or (1|M0)                r1.2<1>:d     r110.1<0;1,0>:d   256:w              
        shl (1|M0)               r2.0<1>:d     r1.2<0;1,0>:d     1:w               {Compacted,I@1}
        sel (16|M0)   (lt)f0.0   r12.0<1>:f    (abs)r8.0<1;1,0>:f  448.0:f             {Compacted,$10.dst}
        shr (16|M0)              r16.0<1>:ud   r12.0<1;1,0>:ud   0x17:uw              {F@1}
        sync.nop                             null                             {Compacted,$13.src}
        sel (16|M0)   (ge)f0.0   r20.0<2>:ub   r16.0<4;1,0>:ub   0x79:uw              {I@1}
        mov (16|M0)              r22.0<1>:d    r20.0<2;1,0>:ub                  {I@1}
        shl (16|M0)              r22.0<1>:d    r22.0<1;1,0>:d    23:w               {Compacted,I@1}
        add (16|M0)              r26.0<1>:d    r22.0<1;1,0>:d    -25165824:d               {I@1}
        add (16|M0)              r22.0<1>:d    -r22.0<1;1,0>:d   -2139095040:d              
        sync.nop                             null                             {Compacted,$4.src}
        sel (16|M0)   (lt)f0.0   r14.0<1>:f    (abs)r10.0<1;1,0>:f  448.0:f            {Compacted,$12.src}
        mul (16|M0)              acc2.0<1>:f   r12.0<1;1,0>:f    r22.0<1;1,0>:f   {Compacted,I@1}
        shr (16|M0)              r18.0<1>:ud   r14.0<1;1,0>:ud   0x17:uw              {F@2}
        rnde (16|M0)             acc2.0<1>:f   acc2.0<1;1,0>:f                 
        cmp (16|M0)   (lt)f1.1   null<1>:f     r8.0<1;1,0>:f     0.0:f              
        sel (16|M0)   (ge)f0.0   r21.0<2>:ub   r18.0<4;1,0>:ub   0x79:uw              {I@1}
        mul (16|M0)              acc2.0<1>:f   acc2.0<1;1,0>:f   r26.0<1;1,0>:f   {Compacted}
        mov (16|M0)              r24.0<1>:d    r21.0<2;1,0>:ub                  {I@1}
        mov (16|M0)              r6.0<1>:f     (abs)acc2.0<1;1,0>:f             {Compacted}
        mov (1|M0)               r12.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,F@5}
        shl (16|M0)              r24.0<1>:d    r24.0<1;1,0>:d    23:w               {Compacted,I@2}
(f1.1)  or (16|M0)               r6.0<1>:d     r6.0<1;1,0>:d     -2147483648:d               {F@1}
        addc (1|M0)              r8.0<1>:ud    r85.4<0;1,0>:ud   r1.3<0;1,0>:ud   {AccWrEn}
        add3 (1|M0)              r85.5<1>:d    r12.0<0;0>:d      r122.1<0;0>:d     0:w               {I@4}
        add (16|M0)              r28.0<1>:d    r24.0<1;1,0>:d    -25165824:d               {I@4}
        mov (8|M0)               r18.8<1>:hf   r7.0<1;1,0>:f                    {I@4}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        add (16|M0)              r24.0<1>:d    -r24.0<1;1,0>:d   -2139095040:d              
        addc (1|M0)              r7.0<1>:ud    r8.0<0;1,0>:ud    r86.5<0;1,0>:ud  {AccWrEn,A@1}
        cmp (16|M0)   (lt)f1.0   null<1>:f     r10.0<1;1,0>:f    0.0:f               {Compacted}
        mov (8|M0)               r18.0<1>:hf   r6.0<1;1,0>:f                   
        mul (16|M0)              acc2.0<1>:f   r14.0<1;1,0>:f    r24.0<1;1,0>:f   {Compacted,I@2}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,F@3}
        add3 (1|M0)              r6.1<1>:d     r9.0<0;0>:d       r85.5<0;0>:d      r1.4<0>:d        {F@2}
        mov (1|M0)               r6.2<1>:d     r7.0<0;1,0>:d                    {I@3}
        rnde (16|M0)             acc0.0<1>:f   acc2.0<1;1,0>:f                  {I@3}
        add3 (1|M0)              r6.3<1>:d     r10.0<0;0>:d      r6.1<0;0>:d       r86.6<0>:d       {I@2}
        mul (16|M0)              r16.0<1>:f    acc0.0<1;1,0>:f   r28.0<1;1,0>:f   {Compacted}
        mov (8|M0)               r13.0<2>:ud   r6.2<0;1,0>:ud                   {A@2}
        mov (8|M0)               r13.1<2>:ud   r6.3<0;1,0>:ud                   {I@2}
        shr (1|M0)               r1.4<1>:ud    r1.2<0;1,0>:ud    0x1F:uw             
        addc (8|M0)              r11.0<1>:ud   r13.0<2;1,0>:ud   r120.0<2;1,0>:ud {AccWrEn,Compacted,A@1}
        mov (8|M0)               r7.0<1>:d     r118.1<2;1,0>:d                 
        mov (8|M0)               r12.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        addc (8|M0)              r8.0<1>:ud    r13.0<2;1,0>:ud   r118.0<2;1,0>:ud {AccWrEn,Compacted}
        or (1|M0)                r2.1<1>:d     r1.4<0;1,0>:d     0:w               {I@5}
        mov (8|M0)               r9.0<1>:ud    acc0.0<1;1,0>:ud                 {Compacted}
        addc (1|M0)              r6.0<1>:ud    r85.4<0;1,0>:ud   r2.0<0;1,0>:ud   {AccWrEn}
        mov (8|M0)               r20.0<2>:d    r11.0<1;1,0>:d                   {I@7}
        mov (8|M0)               r22.0<2>:d    r8.0<1;1,0>:d                    {I@5}
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r8.0<1>:ud    r6.0<0;1,0>:ud    r86.5<0;1,0>:ud  {AccWrEn,I@4}
        mov (16|M0)              r16.0<1>:f    (abs)r16.0<1;1,0>:f              {Compacted}
        add3 (8|M0)              r10.0<1>:d    r9.0<1;0>:d       r13.1<4;2>:d      r7.0<1>:d       
        add3 (1|M0)              r6.2<1>:d     r11.0<0;0>:d      r85.5<0;0>:d      r2.1<0>:d        {I@3}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (8|M0)               r15.0<1>:d    r120.1<2;1,0>:d                 
(f1.0)  or (16|M0)               r16.0<1>:d    r16.0<1;1,0>:d    -2147483648:d               {F@1}
        mov (1|M0)               r9.2<1>:d     r8.0<0;1,0>:d                    {I@6}
        add3 (1|M0)              r9.3<1>:d     r9.0<0;0>:d       r6.2<0;0>:d       r86.6<0>:d       {I@4}
        mov (8|M0)               r19.0<1>:hf   r16.0<1;1,0>:f                   {I@3}
        add3 (8|M0)              r16.0<1>:d    r12.0<1;0>:d      r13.1<4;2>:d      r15.0<1>:d       {F@1}
        mov (8|M0)               r12.0<2>:ud   r9.2<0;1,0>:ud                   {I@3}
        mov (8|M0)               r12.1<2>:ud   r9.3<0;1,0>:ud                   {I@3}
        mov (8|M0)               r22.1<2>:d    r10.0<1;1,0>:d                  
        addc (8|M0)              r10.0<1>:ud   r12.0<2;1,0>:ud   r120.0<2;1,0>:ud {AccWrEn,Compacted,I@2}
        mov (8|M0)               r19.8<1>:hf   r17.0<1;1,0>:f                  
        mov (8|M0)               r14.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        addc (8|M0)              r11.0<1>:ud   r12.0<2;1,0>:ud   r118.0<2;1,0>:ud {AccWrEn,Compacted}
        mov (16|M0)              r24.0<1>:d    r18.0<1;1,0>:uw                 
        mov (8|M0)               r17.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted,F@1}
        mov (8|M0)               r20.1<2>:d    r16.0<1;1,0>:d                  
        add3 (8|M0)              r16.0<1>:d    r14.0<1;0>:d      r12.1<4;2>:d      r15.0<1>:d       {I@5}
        add3 (8|M0)              r8.0<1>:d     r17.0<1;0>:d      r12.1<4;2>:d      r7.0<1>:d        {I@3}
        send.ugm (16|M0)         null     r20     r24:2   0x0            0x08000B84           {A@3,$2} // wr:4+2, rd:0; store.ugm.d16u32.a64
        mov (8|M0)               r20.0<2>:d    r10.0<1;1,0>:d                   {$2.src}
        mov (8|M0)               r22.0<2>:d    r11.0<1;1,0>:d                  
        mov (16|M0)              r24.0<1>:d    r19.0<1;1,0>:uw                 
        mov (8|M0)               r20.1<2>:d    r16.0<1;1,0>:d                   {I@5}
        mov (8|M0)               r22.1<2>:d    r8.0<1;1,0>:d                    {I@5}
        send.ugm (16|M0)         null     r20     r24:2   0x0            0x08000B84           {A@1,$6} // wr:4+2, rd:0; store.ugm.d16u32.a64
(W)     send.slm (1|M0)          r6       r0      null:0  0x0            0x0210001F           {$14} // wr:1+0, rd:1; fence.slm.none.group
(W)     mov (1|M0)               r9.2<1>:f     0.0:f                               {Compacted}
(W)     mov (2|M0)               r9.10<1>:ub   r0.11<0;1,0>:ub                  {F@1}
(W)     mov (8|M0)               null<1>:ud    r6.0<1;1,0>:ud                   {$14.dst}
(W)     send.gtwy (1|M0)         null     r9      null:0  0x0            0x02000004           {A@2,$15} // wr:1+0, rd:0; signal barrier
(W)     sync.bar                             null                            
        addc (1|M0)              r2.0<1>:ud    r122.0<0;1,0>:ud  0x13000:ud              {AccWrEn}
(W)     and (1|M0)               f0.1<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r86.3<1>:d    r2.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r86.4<1>:d    r10.0<0;0>:d      r122.1<0;0>:d     0:w               {I@2}
(~f0.1.any16h) goto (16|M0)                  L31216                  L31216                
L27936:
        and (1|M0)               r1.2<1>:ud    r122.3<0;1,0>:ud  0x1:uw             
        mov (16|M0)              r110.0<1>:f   0.0:f                               {Compacted}
        shl (1|M0)               r1.3<1>:ud    r1.2<0;1,0>:ud    0x8:uw              {I@1}
        mov (16|M0)              r112.0<1>:f   0.0:f                               {Compacted}
        shl (1|M0)               r2.0<1>:d     r1.3<0;1,0>:d     1:w               {Compacted,I@1}
        shr (1|M0)               r1.5<1>:ud    r1.3<0;1,0>:ud    0x1F:uw             
        addc (1|M0)              r6.0<1>:ud    r4.6<0;1,0>:ud    r2.0<0;1,0>:ud   {AccWrEn,I@2}
        shl (1|M0)               r2.0<1>:ud    r1.2<0;1,0>:ud    0x4:uw             
        mov (1|M0)               r87.0<1>:f    r6.0<0;1,0>:f                    {Compacted,I@2}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r8.0<1>:ud    r87.0<0;1,0>:ud   0x100:ud              {AccWrEn,F@1}
        or (1|M0)                r2.1<1>:d     r1.5<0;1,0>:d     0:w              
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$15.src}
        addc (1|M0)              r10.0<1>:ud   r87.0<0;1,0>:ud   0x400:ud              {AccWrEn}
        shl (1|M0)               r6.0<1>:d     r2.0<0;1,0>:d     2:w               {Compacted,I@6}
        mov (1|M0)               r88.0<1>:f    r10.0<0;1,0>:f                   {Compacted,I@2}
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r12.0<1>:ud   r88.0<0;1,0>:ud   0x100:ud              {AccWrEn,F@1}
        shr (1|M0)               r3.3<1>:ud    r2.0<0;1,0>:ud    0x1E:uw             
        add3 (1|M0)              r87.1<1>:d    r7.0<0;0>:d       r4.7<0;0>:d       r2.1<0>:d       
        mov (1|M0)               r13.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r7.0<1>:ud    r86.3<0;1,0>:ud   r6.0<0;1,0>:ud   {AccWrEn,I@6}
        mov (1|M0)               r89.0<1>:f    r8.0<0;1,0>:f                    {Compacted}
        or (1|M0)                r6.1<1>:d     r3.3<0;1,0>:d     0:w               {I@4}
        add3 (1|M0)              r88.1<1>:d    r11.0<0;0>:d      r87.1<0;0>:d      0:w               {I@4}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,F@1}
        mov (16|M0)              r114.0<1>:f   0.0:f                               {Compacted}
        mov (16|M0)              r116.0<1>:f   0.0:f                               {Compacted}
        mov (1|M0)               r4.0<1>:f     r12.0<0;1,0>:f                   {Compacted}
        add3 (1|M0)              r89.1<1>:d    r9.0<0;0>:d       r87.1<0;0>:d      0:w              
        mov (1|M0)               r85.6<1>:d    r7.0<0;1,0>:d                    {I@5}
        add3 (1|M0)              r4.1<1>:d     r13.0<0;0>:d      r88.1<0;0>:d      0:w               {I@4}
        add3 (1|M0)              r85.7<1>:d    r8.0<0;0>:d       r86.4<0;0>:d      r6.1<0>:d        {I@4}
L28344:
        shl (1|M0)               r1.2<1>:d     r122.3<0;1,0>:d   8:w              
        send.ugm (1|M0)          r29      r87     null:0  0x0            0x0280E780           {$7} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        and (1|M0)               r2.0<1>:d     r1.2<0;1,0>:d     1536:w               {Compacted,I@1}
        send.ugm (1|M0)          r37      r89     null:0  0x0            0x0280E780           {$1} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        shl (1|M0)               r6.0<1>:d     r2.0<0;1,0>:d     1:w               {Compacted,I@1}
        shr (1|M0)               r3.3<1>:ud    r2.0<0;1,0>:ud    0x1F:uw             
        addc (1|M0)              r7.0<1>:ud    r85.4<0;1,0>:ud   r6.0<0;1,0>:ud   {AccWrEn,I@2}
        or (1|M0)                r6.1<1>:d     r3.3<0;1,0>:d     0:w               {I@2}
        mov (1|M0)               r9.0<1>:f     r7.0<0;1,0>:f                    {Compacted,I@2}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r18.0<1>:ud   r9.0<0;1,0>:ud    0x100:ud              {AccWrEn,F@1}
        add3 (1|M0)              r9.1<1>:d     r8.0<0;0>:d       r85.5<0;0>:d      r6.1<0>:d        {I@2}
        mov (1|M0)               r19.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,$5.src}
        sync.nop                             null                             {Compacted,$6.src}
        mov (1|M0)               r20.0<1>:f    r18.0<0;1,0>:f                   {Compacted,I@3}
        add3 (1|M0)              r20.1<1>:d    r19.0<0;0>:d      r9.1<0;0>:d       0:w               {I@1}
        send.ugm (1|M0)          r10      r9      null:0  0x0            0x0280E780           {$9} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        send.ugm (1|M0)          r21      r20     null:0  0x0            0x0280E780           {A@1,$12} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        addc (1|M0)              r6.0<1>:ud    r9.0<0;1,0>:ud    0x200:ud              {AccWrEn}
        shl (1|M0)               r1.3<1>:d     r2.0<0;1,0>:d     2:w               {Compacted}
        mov (1|M0)               r8.0<1>:f     r6.0<0;1,0>:f                    {Compacted,I@2}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r18.0<1>:ud   r8.0<0;1,0>:ud    0x100:ud              {AccWrEn,F@1}
        add3 (1|M0)              r8.1<1>:d     r7.0<0;0>:d       r9.1<0;0>:d       0:w               {I@2}
        mov (1|M0)               r19.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        sync.nop                             null                             {Compacted,$12.src}
        mov (1|M0)               r20.0<1>:f    r18.0<0;1,0>:f                   {Compacted,I@3}
        add3 (1|M0)              r20.1<1>:d    r19.0<0;0>:d      r8.1<0;0>:d       0:w               {I@1}
        send.ugm (1|M0)          r77      r8      null:0  0x0            0x0280E780           {$4} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        addc (1|M0)              r6.0<1>:ud    r85.6<0;1,0>:ud   r1.3<0;1,0>:ud   {AccWrEn}
        shr (1|M0)               r1.2<1>:ud    r2.0<0;1,0>:ud    0x1E:uw             
        sync.nop                             null                             {Compacted,$4.src}
        mov (1|M0)               r8.0<1>:f     r6.0<0;1,0>:f                    {Compacted,I@2}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        sync.nop                             null                             {Compacted,$9.src}
        addc (1|M0)              r9.0<1>:ud    r8.0<0;1,0>:ud    0x20:ud              {AccWrEn,F@1}
        or (1|M0)                r1.4<1>:d     r1.2<0;1,0>:d     0:w               {I@3}
        mov (1|M0)               r18.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r2.0<1>:ud    r8.0<0;1,0>:ud    0x400:ud              {AccWrEn}
        mov (1|M0)               r19.0<1>:f    r9.0<0;1,0>:f                    {Compacted,I@4}
        add3 (1|M0)              r8.1<1>:d     r7.0<0;0>:d       r85.7<0;0>:d      r1.4<0>:d        {I@3}
        cmp (1|M0)    (lt)f0.1   null<1>:ud    r122.3<0;1,0>:ud  0x4:uw             
        add3 (1|M0)              r19.1<1>:d    r18.0<0;0>:d      r8.1<0;0>:d       0:w               {I@2}
(W)     and (1|M0)               f1.1<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
        sync.allwr                           ($1,$7,$9,$12)                
        dpas.8x8 (8|M0)          r45:f         null:f            r45:hf            r45.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r45:f         r110:f            r37:hf            r10.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r53:f         r110:f            r29:hf            r10.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r61:f         r110:f            r29:hf            r21.0:hf         {$7}
        sync.nop                             null                             {Compacted,$7.src}
        send.ugm (1|M0)          r10      r20     null:0  0x0            0x0280E780           {$0} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        send.ugm (1|M0)          r29      r4      null:0  0x0            0x0280E780           {$8} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        sync.nop                             null                             {Compacted,$3.src}
        dpas.8x8 (8|M0)          r69:f         r110:f            r37:hf            r21.0:hf         {$13}
        sync.nop                             null                             {Compacted,$13.src}
        send.ugm (1|M0)          r21      r88     null:0  0x0            0x0280E780           {$11} // wr:1+0, rd:8; load.ugm.d64x32t.a64
        sync.allwr                           ($0,$4,$7,$8,$11,$13)                
        dpas.8x8 (8|M0)          r69:f         null:f            r69:hf            r69.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r69:f         r69:f             r29:hf            r10.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r45:f         r45:f             r29:hf            r77.0:hf         {Atomic}
        dpas.8x8 (8|M0)          r61:f         r61:f             r21:hf            r10.0:hf         {$4}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,$4.src}
        addc (1|M0)              r6.0<1>:ud    r8.0<0;1,0>:ud    0x420:ud              {AccWrEn}
        dpas.8x8 (8|M0)          r53:f         r53:f             r21:hf            r77.0:hf         {$10}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r9.0<1>:ud    r8.0<0;1,0>:ud    0x80:ud              {AccWrEn,F@1}
        mov (1|M0)               r11.0<1>:f    r2.0<0;1,0>:f                    {Compacted}
        mov (1|M0)               r14.0<1>:f    r9.0<0;1,0>:f                    {Compacted,I@1}
        mov (1|M0)               r13.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r2.0<1>:ud    r14.0<0;1,0>:ud   0x20:ud              {AccWrEn,F@1}
        add3 (1|M0)              r11.1<1>:d    r10.0<0;0>:d      r8.1<0;0>:d       0:w              
        mov (1|M0)               r12.0<1>:f    r6.0<0;1,0>:f                    {Compacted}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r6.0<1>:ud    r14.0<0;1,0>:ud   0x400:ud              {AccWrEn,F@1}
        add3 (1|M0)              r12.1<1>:d    r7.0<0;0>:d       r8.1<0;0>:d       0:w              
        add3 (1|M0)              r14.1<1>:d    r13.0<0;0>:d      r8.1<0;0>:d       0:w               {I@6}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r9.0<1>:ud    r14.0<0;1,0>:ud   0x420:ud              {AccWrEn}
        send.ugm (1|M0)          null     r8      r53:1   0x0            0x0200C584           {$10} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        sync.nop                             null                             {Compacted,$4.dst}
        send.ugm (1|M0)          null     r19     r45:1   0x0            0x0200C584           {$5} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r11     r61:1   0x0            0x0200C584           {A@7,$3} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        mov (1|M0)               r13.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r11.0<1>:f    r2.0<0;1,0>:f                    {Compacted,$3.src}
        add3 (1|M0)              r11.1<1>:d    r10.0<0;0>:d      r14.1<0;0>:d      0:w               {I@4}
        addc (1|M0)              r2.0<1>:ud    r8.0<0;1,0>:ud    0x100:ud              {AccWrEn,F@1}
        send.ugm (1|M0)          null     r12     r69:1   0x0            0x0200C584           {$2} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r14     r54:1   0x0            0x0200C584           {$6} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r11     r46:1   0x0            0x0200C584           {A@2,$14} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        sync.nop                             null                             {Compacted,$14.src}
        mov (1|M0)               r11.0<1>:f    r2.0<0;1,0>:f                    {Compacted,I@1}
        mov (1|M0)               r12.0<1>:f    r6.0<0;1,0>:f                    {Compacted,$2.src}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r6.0<1>:ud    r11.0<0;1,0>:ud   0x20:ud              {AccWrEn,A@1}
        mov (1|M0)               r15.0<1>:f    r9.0<0;1,0>:f                    {Compacted}
        add3 (1|M0)              r12.1<1>:d    r7.0<0;0>:d       r14.1<0;0>:d      0:w              
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r9.0<1>:ud    r11.0<0;1,0>:ud   0x400:ud              {AccWrEn,F@1}
        add3 (1|M0)              r15.1<1>:d    r13.0<0;0>:d      r14.1<0;0>:d      0:w              
        add3 (1|M0)              r11.1<1>:d    r10.0<0;0>:d      r8.1<0;0>:d       0:w               {I@6}
        mov (1|M0)               r13.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r2.0<1>:ud    r11.0<0;1,0>:ud   0x420:ud              {AccWrEn}
        send.ugm (1|M0)          null     r12     r62:1   0x0            0x0200C584           {A@7,$15} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        mov (1|M0)               r12.0<1>:f    r6.0<0;1,0>:f                    {Compacted,$15.src}
        add3 (1|M0)              r12.1<1>:d    r7.0<0;0>:d       r11.1<0;0>:d      0:w               {I@3}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r6.0<1>:ud    r8.0<0;1,0>:ud    0x180:ud              {AccWrEn,F@1}
        send.ugm (1|M0)          null     r15     r70:1   0x0            0x0200C584           {$1} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r11     r55:1   0x0            0x0200C584           {$9} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r12     r47:1   0x0            0x0200C584           {A@3,$12} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        sync.nop                             null                             {Compacted,$12.src}
        mov (1|M0)               r12.0<1>:f    r6.0<0;1,0>:f                    {Compacted,I@1}
        mov (1|M0)               r14.0<1>:f    r9.0<0;1,0>:f                    {Compacted,$6.src}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r9.0<1>:ud    r12.0<0;1,0>:ud   0x20:ud              {AccWrEn,A@1}
        add3 (1|M0)              r14.1<1>:d    r13.0<0;0>:d      r11.1<0;0>:d      0:w              
        mov (1|M0)               r15.0<1>:f    r2.0<0;1,0>:f                    {Compacted,$1.src}
        mov (1|M0)               r13.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r2.0<1>:ud    r12.0<0;1,0>:ud   0x400:ud              {AccWrEn,F@1}
        add3 (1|M0)              r15.1<1>:d    r10.0<0;0>:d      r11.1<0;0>:d      0:w              
        add3 (1|M0)              r12.1<1>:d    r7.0<0;0>:d       r8.1<0;0>:d       0:w               {I@6}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r6.0<1>:ud    r12.0<0;1,0>:ud   0x420:ud              {AccWrEn}
        send.ugm (1|M0)          null     r14     r63:1   0x0            0x0200C584           {A@7,$7} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        mov (1|M0)               r14.0<1>:f    r9.0<0;1,0>:f                    {Compacted,$7.src}
        add3 (1|M0)              r14.1<1>:d    r13.0<0;0>:d      r12.1<0;0>:d      0:w               {I@3}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r9.0<1>:ud    r8.0<0;1,0>:ud    0x200:ud              {AccWrEn,F@1}
        send.ugm (1|M0)          null     r15     r71:1   0x0            0x0200C584           {$0} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r12     r56:1   0x0            0x0200C584           {$8} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r14     r48:1   0x0            0x0200C584           {A@3,$13} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        sync.nop                             null                             {Compacted,$13.src}
        mov (1|M0)               r14.0<1>:f    r9.0<0;1,0>:f                    {Compacted,I@1}
        mov (1|M0)               r11.0<1>:f    r2.0<0;1,0>:f                    {Compacted,$9.src}
        mov (1|M0)               r13.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r2.0<1>:ud    r14.0<0;1,0>:ud   0x20:ud              {AccWrEn,A@1}
        add3 (1|M0)              r11.1<1>:d    r10.0<0;0>:d      r12.1<0;0>:d      0:w              
        mov (1|M0)               r15.0<1>:f    r6.0<0;1,0>:f                    {Compacted,$0.src}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r6.0<1>:ud    r14.0<0;1,0>:ud   0x400:ud              {AccWrEn,F@1}
        add3 (1|M0)              r15.1<1>:d    r7.0<0;0>:d       r12.1<0;0>:d      0:w              
        add3 (1|M0)              r14.1<1>:d    r13.0<0;0>:d      r8.1<0;0>:d       0:w               {I@6}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r9.0<1>:ud    r14.0<0;1,0>:ud   0x420:ud              {AccWrEn}
        send.ugm (1|M0)          null     r11     r64:1   0x0            0x0200C584           {A@7,$11} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        mov (1|M0)               r11.0<1>:f    r2.0<0;1,0>:f                    {Compacted,$11.src}
        add3 (1|M0)              r11.1<1>:d    r10.0<0;0>:d      r14.1<0;0>:d      0:w               {I@3}
        mov (1|M0)               r13.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r2.0<1>:ud    r8.0<0;1,0>:ud    0x280:ud              {AccWrEn,F@1}
        send.ugm (1|M0)          null     r15     r72:1   0x0            0x0200C584           {$4} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r14     r57:1   0x0            0x0200C584           {$10} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r11     r49:1   0x0            0x0200C584           {A@3,$5} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        sync.nop                             null                             {Compacted,$5.src}
        mov (1|M0)               r11.0<1>:f    r2.0<0;1,0>:f                    {Compacted,I@1}
        mov (1|M0)               r12.0<1>:f    r6.0<0;1,0>:f                    {Compacted,$8.src}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r6.0<1>:ud    r11.0<0;1,0>:ud   0x20:ud              {AccWrEn,A@1}
        add3 (1|M0)              r12.1<1>:d    r7.0<0;0>:d       r14.1<0;0>:d      0:w              
        mov (1|M0)               r15.0<1>:f    r9.0<0;1,0>:f                    {Compacted,$4.src}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r9.0<1>:ud    r11.0<0;1,0>:ud   0x400:ud              {AccWrEn,F@1}
        add3 (1|M0)              r15.1<1>:d    r13.0<0;0>:d      r14.1<0;0>:d      0:w              
        add3 (1|M0)              r11.1<1>:d    r10.0<0;0>:d      r8.1<0;0>:d       0:w               {I@6}
        mov (1|M0)               r13.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r2.0<1>:ud    r11.0<0;1,0>:ud   0x420:ud              {AccWrEn}
        send.ugm (1|M0)          null     r12     r65:1   0x0            0x0200C584           {A@7,$2} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        mov (1|M0)               r12.0<1>:f    r6.0<0;1,0>:f                    {Compacted,$2.src}
        add3 (1|M0)              r12.1<1>:d    r7.0<0;0>:d       r11.1<0;0>:d      0:w               {I@3}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r6.0<1>:ud    r8.0<0;1,0>:ud    0x300:ud              {AccWrEn,F@1}
        send.ugm (1|M0)          null     r15     r73:1   0x0            0x0200C584           {$6} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r11     r58:1   0x0            0x0200C584           {$14} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r12     r50:1   0x0            0x0200C584           {A@3,$15} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        sync.nop                             null                             {Compacted,$15.src}
        mov (1|M0)               r12.0<1>:f    r6.0<0;1,0>:f                    {Compacted,I@1}
        mov (1|M0)               r14.0<1>:f    r9.0<0;1,0>:f                    {Compacted,$10.src}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r9.0<1>:ud    r12.0<0;1,0>:ud   0x20:ud              {AccWrEn,A@1}
        add3 (1|M0)              r14.1<1>:d    r13.0<0;0>:d      r11.1<0;0>:d      0:w              
        mov (1|M0)               r15.0<1>:f    r2.0<0;1,0>:f                    {Compacted,$6.src}
        mov (1|M0)               r13.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r2.0<1>:ud    r12.0<0;1,0>:ud   0x400:ud              {AccWrEn,F@1}
        add3 (1|M0)              r15.1<1>:d    r10.0<0;0>:d      r11.1<0;0>:d      0:w              
        add3 (1|M0)              r12.1<1>:d    r7.0<0;0>:d       r8.1<0;0>:d       0:w               {I@6}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r6.0<1>:ud    r12.0<0;1,0>:ud   0x420:ud              {AccWrEn}
        send.ugm (1|M0)          null     r14     r66:1   0x0            0x0200C584           {A@7,$0} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        mov (1|M0)               r14.0<1>:f    r9.0<0;1,0>:f                    {Compacted,$0.src}
        add3 (1|M0)              r14.1<1>:d    r13.0<0;0>:d      r12.1<0;0>:d      0:w               {I@3}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r9.0<1>:ud    r8.0<0;1,0>:ud    0x380:ud              {AccWrEn,F@1}
        send.ugm (1|M0)          null     r15     r74:1   0x0            0x0200C584           {$8} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r12     r59:1   0x0            0x0200C584           {$13} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r14     r51:1   0x0            0x0200C584           {A@3,$11} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        sync.nop                             null                             {Compacted,$11.src}
        mov (1|M0)               r14.0<1>:f    r9.0<0;1,0>:f                    {Compacted,I@1}
        mov (1|M0)               r11.0<1>:f    r2.0<0;1,0>:f                    {Compacted,$14.src}
        mov (1|M0)               r13.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r2.0<1>:ud    r14.0<0;1,0>:ud   0x20:ud              {AccWrEn,A@1}
        add3 (1|M0)              r11.1<1>:d    r10.0<0;0>:d      r12.1<0;0>:d      0:w              
        mov (1|M0)               r15.0<1>:f    r6.0<0;1,0>:f                    {Compacted,$8.src}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r6.0<1>:ud    r14.0<0;1,0>:ud   0x400:ud              {AccWrEn,F@1}
        add3 (1|M0)              r15.1<1>:d    r7.0<0;0>:d       r12.1<0;0>:d      0:w              
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r8.0<1>:ud    r14.0<0;1,0>:ud   0x420:ud              {AccWrEn,$10.src}
        add3 (1|M0)              r14.1<1>:d    r13.0<0;0>:d      r8.1<0;0>:d       0:w               {I@7}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        send.ugm (1|M0)          null     r11     r67:1   0x0            0x0200C584           {A@7,$4} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        sync.nop                             null                             {Compacted,$13.src}
        mov (1|M0)               r12.0<1>:f    r6.0<0;1,0>:f                    {Compacted,I@6}
        mov (1|M0)               r13.0<1>:f    r8.0<0;1,0>:f                    {Compacted,A@2}
        add3 (1|M0)              r12.1<1>:d    r7.0<0;0>:d       r14.1<0;0>:d      0:w              
        mov (1|M0)               r11.0<1>:f    r2.0<0;1,0>:f                    {Compacted,$4.src}
        add3 (1|M0)              r11.1<1>:d    r10.0<0;0>:d      r14.1<0;0>:d      0:w              
        add3 (1|M0)              r13.1<1>:d    r9.0<0;0>:d       r14.1<0;0>:d      0:w               {I@3}
        send.ugm (1|M0)          null     r15     r75:1   0x0            0x0200C584           {$7} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r14     r60:1   0x0            0x0200C584           {$1} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r11     r52:1   0x0            0x0200C584           {A@1,$9} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r12     r68:1   0x0            0x0200C584           {$12} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        send.ugm (1|M0)          null     r13     r76:1   0x0            0x0200C584           {A@1,$3} // wr:1+1, rd:0; store.ugm.d32x8t.a64
        add (1|M0)               r2.0<1>:d     r122.3<0;1,0>:d   4:w               {Compacted}
(~f1.1.any16h) goto (16|M0)                  L31216                  L31216                
L31184:
        mov (1|M0)               r122.3<1>:d   r2.0<0;1,0>:d                    {I@2}
        goto.b (16|M0)                       L31216                  L28344                
L31216:
        join (16|M0)                         L36400                                
L31232:
(W)     send.slm (1|M0)          r6       r0      null:0  0x0            0x0210001F           {$10} // wr:1+0, rd:1; fence.slm.none.group
(W)     mov (1|M0)               r7.2<1>:f     0.0:f                               {Compacted}
(W)     mov (2|M0)               r7.10<1>:ub   r0.11<0;1,0>:ub                  {F@1}
(W)     mov (8|M0)               null<1>:ud    r6.0<1;1,0>:ud                   {$10.dst}
(W)     send.gtwy (1|M0)         null     r7      null:0  0x0            0x02000004           {A@2,$5} // wr:1+0, rd:0; signal barrier
(W)     sync.bar                             null                            
        cmp (1|M0)    (eq)f1.1   null<1>:d     r2.6<0;1,0>:d     9:w              
(W)     and (1|M0)               f1.0<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(~f1.0.any16h) goto (16|M0)                  L32176                  L32176                
L31368:
        cmp (1|M0)    (eq)f0.0   null<1>:d     r3.7<0;1,0>:d     0:w              
(f0.0)  cmp (1|M0)    (eq)f0.0   null<1>:d     r3.6<0;1,0>:d     0:w              
(W)     and (1|M0)               f0.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
(f0.1.any16h) goto (16|M0)                   L32176                  L42064                
L31432:
        shl (1|M0)               r1.2<1>:d     r122.5<0;1,0>:d   12:w              
        shr (1|M0)               r1.3<1>:ud    r122.4<0;1,0>:ud  0x14:uw             
        shl (1|M0)               r1.4<1>:d     r122.4<0;1,0>:d   12:w              
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        shl (1|M0)               r6.0<1>:d     r1.4<0;1,0>:d     1:w               {Compacted,I@2}
        shl (1|M0)               r7.4<1>:d     r85.2<0;1,0>:d    1:w               {$5.src}
        shr (1|M0)               r2.1<1>:ud    r1.4<0;1,0>:ud    0x1F:uw             
        shl (1|M0)               r2.0<1>:d     r1.5<0;1,0>:d     1:w               {Compacted,I@4}
        addc (1|M0)              r7.0<1>:ud    r3.6<0;1,0>:ud    r6.0<0;1,0>:ud   {AccWrEn,I@4}
        shl (1|M0)               r3.3<1>:d     r85.3<0;1,0>:d    1:w               {Compacted}
        shr (1|M0)               r7.3<1>:ud    r85.2<0;1,0>:ud   0x1F:uw             
        or (1|M0)                r6.1<1>:d     r2.0<0;1,0>:d     r2.1<0;1,0>:d    {I@4}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        sync.nop                             null                             {Compacted,$15.src}
        addc (1|M0)              r9.0<1>:ud    r7.0<0;1,0>:ud    r7.4<0;1,0>:ud   {AccWrEn,I@5}
        or (1|M0)                r7.5<1>:d     r3.3<0;1,0>:d     r7.3<0;1,0>:d    {I@4}
        add3 (1|M0)              r7.2<1>:d     r8.0<0;0>:d       r3.7<0;0>:d       r6.1<0>:d        {I@3}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        add (1|M0)               r86.2<1>:ud   r86.2<0;1,0>:ud   0x4C00:uw             
        mov (1|M0)               r86.0<2>:f    0.0:f                              
        mov (1|M0)               r86.1<2>:f    0.0:f                              
        mov (1|M0)               r86.3<1>:d    r9.0<0;1,0>:d                    {I@5}
        add3 (1|M0)              r86.4<1>:d    r10.0<0;0>:d      r7.2<0;0>:d       r7.5<0>:d        {I@3}
L31752:
        or (1|M0)                r1.2<1>:ud    r86.2<0;1,0>:ud   r86.0<0;1,0>:ud  {A@2}
        shl (1|M0)               r10.2<1>:d    r86.0<0;1,0>:d    1:w               {Compacted}
        sync.nop                             null                             {Compacted,$2.src}
        shl (1|M0)               r2.0<1>:d     r1.2<0;1,0>:d     2:w               {Compacted,I@2}
        shr (1|M0)               r1.4<1>:ud    r1.2<0;1,0>:ud    0x1E:uw             
        addc (1|M0)              r6.0<1>:ud    r122.0<0;1,0>:ud  r2.0<0;1,0>:ud   {AccWrEn,I@2}
        or (1|M0)                r2.1<1>:d     r1.4<0;1,0>:d     0:w               {I@2}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r8.0<1>:f     r6.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r8.1<1>:d     r7.0<0;0>:d       r122.1<0;0>:d     r2.1<0>:d        {I@1}
        addc (1|M0)              r11.0<1>:ud   r86.3<0;1,0>:ud   r10.2<0;1,0>:ud  {AccWrEn,$9.src}
        send.ugm (1|M0)          r9       r8      null:0  0x0            0x04100580           {A@1,$6} // wr:2+0, rd:1; load.ugm.d32.a64
        mov (1|M0)               r12.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,$12.src}
        addc (1|M0)              r6.0<1>:ud    r86.0<0;1,0>:ud   0x1:ud              {AccWrEn}
        shl (1|M0)               r10.0<1>:d    r86.1<0;1,0>:d    1:w               {Compacted}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r86.6<1>:d    r6.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r86.7<1>:d    r7.0<0;0>:d       r86.1<0;0>:d      0:w               {I@2}
        shr (1|M0)               r10.1<1>:ud   r86.0<0;1,0>:ud   0x1F:uw             
        cmp (1|M0)    (eq)f1.1   null<1>:d     r86.7<0;1,0>:d    0:w               {I@2}
        or (1|M0)                r10.3<1>:d    r10.0<0;1,0>:d    r10.1<0;1,0>:d   {I@2}
        mov (1|M0)               r14.0<1>:f    r11.0<0;1,0>:f                   {Compacted,$1.src}
        add3 (1|M0)              r14.1<1>:d    r12.0<0;0>:d      r86.4<0;0>:d      r10.3<0>:d       {I@1}
(f1.1)  cmp (1|M0)    (eq)f1.1   null<1>:d     r86.6<0;1,0>:d    32:w              
(W)     and (1|M0)               f0.0<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
        mov (1|M0)               r3.6<2>:hf    r9.0<0;1,0>:f                    {$6.dst}
        mov (1|M0)               r2.0<1>:d     r3.6<0;1,0>:uw                   {F@1}
        send.ugm (1|M0)          null     r14     r2:1    0x0            0x04000B84           {A@1,$2} // wr:2+1, rd:0; store.ugm.d16u32.a64
(f0.0.any16h) goto (16|M0)                   L32176                  L42064                
L32144:
(W)     mov (2|M0)               r86.0<1>:ud   r86.6<1;1,0>:ud                 
        goto.b (16|M0)                       L32176                  L31752                
L32176:
        join (16|M0)                         L36400                                
L32192:
(W)     and (1|M0)               f1.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
(~f1.1.any16h) goto (16|M0)                  L36400                  L42064                
L32224:
        cmp (1|M0)    (gt)f1.0   null<1>:d     r122.6<0;1,0>:d   -1:w              
        cmp (1|M0)    (lt)f1.1   null<1>:d     r122.6<0;1,0>:d   r3.1<0;1,0>:d   
(W)     mov (1|M0)               r1.3<1>:hf    0x1:hf                             
(f1.0)  cmp (1|M0)    (lt)f1.0   null<1>:d     r122.7<0;1,0>:d   r3.0<0;1,0>:d   
        sync.nop                             null                             {Compacted,$2.src}
(f1.1)  sel (1|M0)               r2.0<1>:uw    r1.3<0;1,0>:uw    0x0:uw              {F@1}
(f1.0)  sel (1|M0)               r1.4<1>:uw    r1.3<0;1,0>:uw    0x0:uw             
        and (1|M0)    (ne)f1.0   null<1>:uw    r1.4<0;1,0>:uw    r2.0<0;1,0>:uw   {I@1}
(W)     and (1|M0)               f1.0<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
(~f1.0.any16h) goto (16|M0)                  L36400                  L42064                
L32376:
        mul (1|M0)               acc0.0<1>:ud  r122.7<0;1,0>:ud  r3.2<0;1,0>:uw  
        mach (1|M0)              r7.0<1>:ud    r122.7<0;1,0>:ud  r3.1<0;1,0>:ud   {AccWrEn,$5.src}
        cmp (1|M0)    (eq)f0.1   null<1>:w     r122.10<0;1,0>:b  0:w              
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r2.0<1>:ud    r6.0<0;1,0>:ud    r122.6<0;1,0>:ud {AccWrEn,I@1}
(W)     and (1|M0)               f0.1<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        shr (1|M0)               r3.3<1>:ud    r2.0<0;1,0>:ud    0x1B:uw              {I@3}
        add3 (1|M0)              r1.3<1>:d     r8.0<0;0>:d       r7.0<0;0>:d       0:w               {I@2}
        shl (1|M0)               r85.2<1>:d    r2.0<0;1,0>:d     5:w               {Compacted}
        shl (1|M0)               r2.1<1>:d     r1.3<0;1,0>:d     5:w               {I@2}
        or (1|M0)                r85.3<1>:d    r2.1<0;1,0>:d     r3.3<0;1,0>:d    {I@1}
(f0.1.any16h) goto (16|M0)                   L32776                  L32776                
L32560:
        shl (1|M0)               r1.4<1>:d     r85.2<0;1,0>:d    1:w              
        shl (1|M0)               r1.2<1>:d     r85.3<0;1,0>:d    1:w               {I@3}
        shr (1|M0)               r1.3<1>:ud    r85.2<0;1,0>:ud   0x1F:uw             
        addc (1|M0)              r2.0<1>:ud    r3.4<0;1,0>:ud    r1.4<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r7.0<1>:f     r2.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r7.1<1>:d     r6.0<0;0>:d       r3.5<0;0>:d       r1.5<0>:d        {I@1}
        sync.nop                             null                             {Compacted,$15.src}
        send.ugm (1|M0)          r8       r7      null:0  0x0            0x0220C780           {A@1,$14} // wr:1+0, rd:2; load.ugm.d64x8t.a64
        mov (8|M0)               r56.0<1>:f    r8.0<1;1,0>:hf                   {$14.dst}
        mov (8|M0)               r57.0<1>:f    r8.8<1;1,0>:hf                  
        mov (8|M0)               r58.0<1>:f    r9.0<1;1,0>:hf                  
        mov (8|M0)               r59.0<1>:f    r9.8<1;1,0>:hf                  
        goto (16|M0)                         L32776                  L32920                
L32776:
        join (16|M0)                         L32920                                
L32792:
        shl (1|M0)               r1.4<1>:d     r85.2<0;1,0>:d    2:w              
        shl (1|M0)               r1.2<1>:d     r85.3<0;1,0>:d    2:w              
        shr (1|M0)               r1.3<1>:ud    r85.2<0;1,0>:ud   0x1E:uw             
        addc (1|M0)              r2.0<1>:ud    r3.4<0;1,0>:ud    r1.4<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r7.0<1>:f     r2.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r7.1<1>:d     r6.0<0;0>:d       r3.5<0;0>:d       r1.5<0>:d        {I@1}
        send.ugm (1|M0)          r56      r7      null:0  0x0            0x0240E580           {A@1,$15} // wr:1+0, rd:4; load.ugm.d32x32t.a64
L32920:
        join (16|M0)                         L36400                                
L32936:
        addc (1|M0)              r2.0<1>:ud    r86.3<0;1,0>:ud   r85.0<0;1,0>:ud  {AccWrEn}
        sync.nop                             null                             {Compacted,$15.src}
        send.ugm (1|M0)          r6       r5      null:0  0x0            0x0240E580           {$0} // wr:1+0, rd:4; load.ugm.d32x32t.a64
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        sync.nop                             null                             {Compacted,$9.src}
        mov (1|M0)               r11.0<1>:f    r2.0<0;1,0>:f                    {Compacted,I@2}
        add3 (1|M0)              r11.1<1>:d    r10.0<0;0>:d      r86.4<0;0>:d      r85.1<0>:d       {I@1}
        cmp (1|M0)    (lt)f0.0   null<1>:d     r5.2<0;1,0>:d     1:w              
        send.ugm (1|M0)          r36      r11     null:0  0x0            0x0240E580           {A@1,$8} // wr:1+0, rd:4; load.ugm.d32x32t.a64
(W)     and (1|M0)               f0.0<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
        sync.allwr                           ($0,$8)                
        mad (16|M0)              r36.0<1>:f    r36.0<1;0>:f      r6.0<1;0>:f       r56.0<1>:f       {Compacted,$15.dst}
        mad (16|M0)              r38.0<1>:f    r38.0<1;0>:f      r8.0<1;0>:f       r58.0<1>:f       {Compacted}
(f0.0.any16h) goto (16|M0)                   L33824                  L33824                
L33112:
        cmp (1|M0)    (lt)f1.1   null<1>:d     r5.2<0;1,0>:d     4:w              
(W)     and (1|M0)               f1.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(f1.1.any16h) goto (16|M0)                   L33352                  L33352                
L33160:
        cmp (1|M0)    (eq)f1.0   null<1>:d     r5.2<0;1,0>:d     4:w              
(W)     and (1|M0)               f1.0<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
(~f1.0.any16h) goto (16|M0)                  L33352                  L33888                
L33208:
        mov (8|M0)               r6.0<1>:hf    r36.0<1;1,0>:f                   {F@2}
        mov (8|M0)               r6.8<1>:hf    r37.0<1;1,0>:f                  
        mov (8|M0)               r7.0<1>:hf    r38.0<1;1,0>:f                   {F@3}
        mov (8|M0)               r7.8<1>:hf    r39.0<1;1,0>:f                  
        mov (8|M0)               r36.0<1>:f    r6.0<1;1,0>:hf                   {F@4}
        mov (8|M0)               r37.0<1>:f    r6.8<1;1,0>:hf                   {F@4}
        mov (8|M0)               r38.0<1>:f    r7.0<1;1,0>:hf                   {F@4}
        mov (8|M0)               r39.0<1>:f    r7.8<1;1,0>:hf                   {F@4}
        goto (16|M0)                         L33352                  L35304                
L33352:
        join (16|M0)                         L33824                                
L33368:
        cmp (1|M0)    (eq)f0.1   null<1>:d     r5.2<0;1,0>:d     1:w              
(W)     and (1|M0)               f0.1<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(~f0.1.any16h) goto (16|M0)                  L33824                  L33888                
L33416:
        sel (16|M0)   (lt)f0.0   r6.0<1>:f     (abs)r36.0<1;1,0>:f  448.0:f            {Compacted,F@3}
        sel (16|M0)   (lt)f0.0   r8.0<1>:f     (abs)r38.0<1;1,0>:f  448.0:f            {Compacted,F@2}
        shr (16|M0)              r10.0<1>:ud   r6.0<1;1,0>:ud    0x17:uw              {F@2}
        sync.allrd                           ($3,$12)                
        shr (16|M0)              r12.0<1>:ud   r8.0<1;1,0>:ud    0x17:uw              {F@1}
        sync.nop                             null                             {Compacted,$1.src}
        sel (16|M0)   (ge)f0.0   r14.0<2>:ub   r10.0<4;1,0>:ub   0x79:uw              {I@2}
        sync.nop                             null                             {Compacted,$7.src}
        sel (16|M0)   (ge)f0.0   r15.0<2>:ub   r12.0<4;1,0>:ub   0x79:uw              {I@2}
        mov (16|M0)              r16.0<1>:d    r14.0<2;1,0>:ub                  {I@2}
        sync.nop                             null                             {Compacted,$5.src}
        mov (16|M0)              r18.0<1>:d    r15.0<2;1,0>:ub                  {I@2}
        shl (16|M0)              r16.0<1>:d    r16.0<1;1,0>:d    23:w               {Compacted,I@2}
        shl (16|M0)              r18.0<1>:d    r18.0<1;1,0>:d    23:w               {Compacted,I@2}
        sync.nop                             null                             {Compacted,$6.src}
        add (16|M0)              r20.0<1>:d    r16.0<1;1,0>:d    -25165824:d               {I@2}
        add (16|M0)              r22.0<1>:d    r18.0<1;1,0>:d    -25165824:d               {I@2}
        add (16|M0)              r16.0<1>:d    -r16.0<1;1,0>:d   -2139095040:d              
        add (16|M0)              r18.0<1>:d    -r18.0<1;1,0>:d   -2139095040:d              
        mul (16|M0)              acc0.0<1>:f   r6.0<1;1,0>:f     r16.0<1;1,0>:f   {Compacted,I@2}
        mul (16|M0)              acc2.0<1>:f   r8.0<1;1,0>:f     r18.0<1;1,0>:f   {Compacted,I@1}
        rnde (16|M0)             acc0.0<1>:f   acc0.0<1;1,0>:f                 
        rnde (16|M0)             acc2.0<1>:f   acc2.0<1;1,0>:f                 
        cmp (16|M0)   (lt)f0.0   null<1>:f     r36.0<1;1,0>:f    0.0:f               {Compacted}
        cmp (16|M0)   (lt)f1.1   null<1>:f     r38.0<1;1,0>:f    0.0:f              
        mul (16|M0)              acc0.0<1>:f   acc0.0<1;1,0>:f   r20.0<1;1,0>:f   {Compacted}
        mul (16|M0)              acc2.0<1>:f   acc2.0<1;1,0>:f   r22.0<1;1,0>:f   {Compacted}
        mov (16|M0)              r10.0<1>:f    (abs)acc0.0<1;1,0>:f             {Compacted}
        mov (16|M0)              r12.0<1>:f    (abs)acc2.0<1;1,0>:f             {Compacted}
(f0.0)  or (16|M0)               r10.0<1>:d    r10.0<1;1,0>:d    -2147483648:d               {F@2}
(f1.1)  or (16|M0)               r12.0<1>:d    r12.0<1;1,0>:d    -2147483648:d               {F@1}
        mov (16|M0)              r36.0<1>:f    r10.0<1;1,0>:f                   {Compacted,I@2}
        mov (16|M0)              r38.0<1>:f    r12.0<1;1,0>:f                   {Compacted,I@1}
        goto (16|M0)                         L33824                  L35304                
L33824:
        join (16|M0)                         L33888                                
L33840:
        cmp (1|M0)    (eq)f1.0   null<1>:d     r5.2<0;1,0>:d     0:w              
(W)     and (1|M0)               f0.0<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
(f0.0.any16h) goto (16|M0)                   L33888                  L35304                
L33888:
        join (16|M0)                         L35304                                
L33904:
        send.ugm (1|M0)          null     r86     r36:4   0x0            0x0200E584           {A@1,$13} // wr:1+4, rd:0; store.ugm.d32x32t.a64
        and (1|M0)               r85.6<1>:d    r5.2<0;1,0>:d     -2:w              
        and (1|M0)               r85.1<1>:d    r5.2<0;1,0>:d     -3:w              
        mov (1|M0)               r122.0<1>:f   r36.0<0;1,0>:f                   {Compacted}
        mov (1|M0)               r85.4<2>:f    0.0:f                              
        mov (1|M0)               r85.5<2>:f    0.0:f                              
        mov (1|M0)               r85.0<1>:d    0:w                              
L34008:
        cmp (1|M0)    (eq)f0.1   null<1>:d     r85.6<0;1,0>:d    2:w               {I@3}
(W)     and (1|M0)               f1.1<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(~f1.1.any16h) goto (16|M0)                  L34296                  L34296                
L34056:
        sync.nop                             null                             {Compacted,$11.dst}
        mov (1|M0)               r1.4<2>:hf    r122.0<0;1,0>:f                  {F@3}
        cmp (1|M0)    (lt)f0.0   null<1>:f     r122.0<0;1,0>:f   -4.001953e+00:f              
        mov (1|M0)               r1.3<1>:f     r1.4<0;1,0>:hf                   {F@2}
        mov (1|M0)               r2.1<1>:ud    0xBD650000:ud                             
        sel (1|M0)    (lt)f0.0   r1.3<1>:f     r1.3<0;1,0>:f     4.0:f               {F@1}
        mov (1|M0)               r3.3<1>:ud    0x3EE50000:ud                             
(~f0.0) sel (1|M0)               r2.0<1>:f     r1.3<0;1,0>:f     -4.0:f               {F@1}
        mad (1|M0)               r2.1<1>:f     r3.3<0;0>:f       r2.1<0;0>:f       (abs)r2.0<0>:f   {A@1}
        mov (1|M0)               r6.0<2>:hf    r2.1<0;1,0>:f                    {F@1}
        mov (1|M0)               r7.0<1>:f     r6.0<0;1,0>:hf                   {F@1}
        mul (1|M0)               r2.0<1>:f     r2.0<0;1,0>:f     r7.0<0;1,0>:f    {Compacted,F@1}
        mov (1|M0)               r8.0<2>:hf    r2.0<0;1,0>:f                    {F@1}
        add (1|M0)               r8.0<1>:hf    r8.0<0;1,0>:hf    0x3B28:hf              {F@1}
        mul (1|M0)               r8.0<1>:hf    r8.0<0;1,0>:hf    r1.4<0;1,0>:hf   {F@1}
        mov (1|M0)               r122.0<1>:f   r8.0<0;1,0>:hf                   {F@1}
L34296:
        join (16|M0)                         L35304                                
L34312:
        cmp (1|M0)    (eq)f1.1   null<1>:d     r85.1<0;1,0>:d    1:w              
(W)     and (1|M0)               f1.0<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(f1.0.any16h) goto (16|M0)                   L34448                  L34448                
L34360:
        cmp (1|M0)    (eq)f1.0   null<1>:d     r5.2<0;1,0>:d     4:w              
        sync.nop                             null                             {Compacted,$11.dst}
        mov (1|M0)               r1.4<2>:hf    r122.0<0;1,0>:f                  {F@1}
        mov (1|M0)               r85.7<1>:f    r1.4<0;1,0>:hf                   {F@1}
(~f1.0) mov (1|M0)               r85.7<1>:f    r122.0<0;1,0>:f                 
        goto (16|M0)                         L34448                  L34896                
L34448:
        join (16|M0)                         L34896                                
L34464:
        sync.nop                             null                             {Compacted,$11.dst}
        cmp (1|M0)    (lt)f1.0   null<1>:f     r122.0<0;1,0>:f   0.0:f               {A@3}
(f1.0)  mov (1|M0)               r122.0<1>:f   -r122.0<0;1,0>:f                
        sel (1|M0)    (lt)f0.0   r122.0<1>:f   r122.0<0;1,0>:f   448.0:f               {F@1}
        sync.nop                             null                             {Compacted,$13.src}
        shr (1|M0)               r86.2<1>:ud   r122.0<0;1,0>:ud  0x17:uw              {F@1}
        and (1|M0)               r86.2<1>:ud   r86.2<0;1,0>:ud   0xFF:uw              {I@1}
        sel (1|M0)    (ge)f0.0   r86.2<1>:ud   r86.2<0;1,0>:ud   0x79:uw              {I@1}
        shl (1|M0)               r86.2<1>:ud   r86.2<0;1,0>:ud   0x17:uw              {I@1}
        add (1|M0)               r1.2<1>:ud    -r86.2<0;1,0>:ud  0x80800000:ud              {I@1}
        mul (1|M0)               r1.3<1>:f     r122.0<0;1,0>:f   r1.2<0;1,0>:f    {I@1}
        mov (1|M0)               r86.3<1>:d    r1.3<0;1,0>:f                    {Compacted,F@1}
        mov (1|M0)               r85.7<1>:f    r86.3<0;1,0>:d                   {I@1}
        mad (1|M0)               r122.0<1>:f   -r85.7<0;0>:f     r1.2<0;0>:f       r122.0<0>:f      {F@1}
        cmp (1|M0)    (gt)f0.1   null<1>:f     r122.0<0;1,0>:f   0.5:f               {F@1}
(W)     and (1|M0)               f0.1<1>:uw    f0.1<0;1,0>:uw    0x1:uw              {F@1}
(f0.1.any16h) goto (16|M0)                   L34800                  L34800                
L34712:
        cmp (1|M0)    (lt)f0.1   null<1>:f     r122.0<0;1,0>:f   0.5:f               {A@1}
        and (1|M0)               r86.3<1>:d    r86.3<0;1,0>:d    1:w               {Compacted}
        add (1|M0)               r1.2<1>:f     r85.7<0;1,0>:f    1.0:f              
(~f0.1) cmp (1|M0)    (eq)f0.1   null<1>:d     r86.3<0;1,0>:d    0:w               {A@1}
(~f0.1) mov (1|M0)               r85.7<1>:f    r1.2<0;1,0>:f                    {F@1}
        goto (16|M0)                         L34800                  L34832                
L34800:
        join (16|M0)                         L34832                                
L34816:
        add (1|M0)               r85.7<1>:f    r85.7<0;1,0>:f    1.0:f               {F@1}
L34832:
        join (16|M0)                         L34896                                
L34848:
        add (1|M0)               r86.2<1>:ud   r86.2<0;1,0>:ud   0xFE800000:ud             
        mul (1|M0)               r85.7<1>:f    r85.7<0;1,0>:f    r86.2<0;1,0>:f   {A@1}
(f1.0)  mov (1|M0)               r85.7<1>:f    -r85.7<0;1,0>:f                  {F@1}
L34896:
        join (16|M0)                         L35304                                
L34912:
        addc (1|M0)              r2.0<1>:ud    r85.4<0;1,0>:ud   0x1:ud              {AccWrEn}
        shl (1|M0)               r1.3<1>:w     r85.0<0;1,0>:w    2:w              
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        sync.nop                             null                             {Compacted,$13.src}
        mov (1|M0)               r86.2<1>:d    r2.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r86.3<1>:d    r6.0<0;0>:d       r85.5<0;0>:d      0:w               {I@2}
        add (1|M0)               r85.0<1>:d    r85.0<0;1,0>:d    1:w               {Compacted}
        cmp (1|M0)    (eq)f1.0   null<1>:d     r86.3<0;1,0>:d    0:w               {A@1}
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0x480:uw              {A@1}
        mov (1|M0)               r[a0.0]<1>:f  r85.7<0;1,0>:f                  
(f1.0)  cmp (1|M0)    (eq)f1.0   null<1>:d     r86.2<0;1,0>:d    32:w              
(W)     and (1|M0)               f0.0<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
(f0.0.any16h) goto (16|M0)                   L35304                  L35304                
L35096:
        addc (1|M0)              r2.0<1>:ud    r86.0<0;1,0>:ud   0x4:ud              {AccWrEn}
        shl (1|M0)               r1.6<1>:d     r85.4<0;1,0>:d    2:w              
        shl (1|M0)               r1.4<1>:d     r85.5<0;1,0>:d    2:w              
        shr (1|M0)               r1.5<1>:ud    r85.4<0;1,0>:ud   0x1E:uw             
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r7.0<1>:ud    r2.0<0;1,0>:ud    r1.6<0;1,0>:ud   {AccWrEn,I@4}
        or (1|M0)                r1.7<1>:d     r1.4<0;1,0>:d     r1.5<0;1,0>:d    {I@3}
        add3 (1|M0)              r1.3<1>:d     r6.0<0;0>:d       r86.1<0;0>:d      0:w               {I@3}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        sync.nop                             null                             {Compacted,$11.src}
        mov (1|M0)               r10.0<1>:f    r7.0<0;1,0>:f                    {Compacted,I@4}
        add3 (1|M0)              r10.1<1>:d    r8.0<0;0>:d       r1.3<0;0>:d       r1.7<0>:d        {I@1}
(W)     mov (2|M0)               r85.4<1>:ud   r86.2<1;1,0>:ud                 
        send.ugm (1|M0)          r122     r10     null:0  0x0            0x04100580           {A@1,$11} // wr:2+0, rd:1; load.ugm.d32.a64
        goto.b (16|M0)                       L35304                  L34008                
L35304:
        join (16|M0)                         L36400                                
L35320:
        cmp (1|M0)    (eq)f0.0   null<1>:w     r122.8<0;1,0>:b   0:w              
(W)     and (1|M0)               f1.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
(f1.1.any16h) goto (16|M0)                   L36240                  L36240                
L35368:
        shl (1|M0)               r1.4<1>:d     r85.2<0;1,0>:d    1:w              
        shl (1|M0)               r1.2<1>:d     r85.3<0;1,0>:d    1:w              
        addc (1|M0)              r2.0<1>:ud    r5.4<0;1,0>:ud    r1.4<0;1,0>:ud   {AccWrEn,I@2}
        shr (1|M0)               r1.3<1>:ud    r85.2<0;1,0>:ud   0x1F:uw             
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (4|M0)              r9.0<1>:ud    r127.0<2;1,0>:ud  0x20:ud              {AccWrEn}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@3}
        mov (4|M0)               r10.0<1>:ud   acc0.0<1;1,0>:ud                 {$11.src}
        addc (4|M0)              r13.0<1>:ud   r127.0<2;1,0>:ud  0x28:ud              {AccWrEn,$3.src}
        mov (1|M0)               r8.2<1>:d     r2.0<0;1,0>:d                   
        add3 (1|M0)              r8.3<1>:d     r8.0<0;0>:d       r5.5<0;0>:d       r1.5<0>:d        {I@4}
        mov (4|M0)               r14.0<1>:ud   acc0.0<1;1,0>:ud                 {$1.src}
        addc (4|M0)              r15.0<1>:ud   r127.0<2;1,0>:ud  0x30:ud              {AccWrEn,$7.src}
        mov (4|M0)               r11.0<2>:d    r9.0<1;1,0>:d                   
        add3 (4|M0)              r11.1<2>:d    r10.0<1;0>:d      r127.1<4;2>:d     0:w               {I@7}
        mov (4|M0)               r16.0<1>:ud   acc0.0<1;1,0>:ud                
        mov (8|M0)               r9.0<2>:ud    r8.2<0;1,0>:ud                   {I@7}
        addc (4|M0)              r19.0<1>:ud   r127.0<2;1,0>:ud  0x38:ud              {AccWrEn,$5.src}
        mov (8|M0)               r9.1<2>:ud    r8.3<0;1,0>:ud                   {I@7}
        mov (4|M0)               r12.0<2>:d    r13.0<1;1,0>:d                   {$12.src}
        mov (4|M0)               r20.0<1>:ud   acc0.0<1;1,0>:ud                 {$6.src}
        addc (8|M0)              r13.0<1>:ud   r9.0<2;1,0>:ud    r120.0<2;1,0>:ud {AccWrEn,Compacted,I@3}
        mov (8|M0)               r25.0<1>:d    r120.1<2;1,0>:d                 
        mov (4|M0)               r17.0<2>:d    r15.0<1;1,0>:d                  
        add3 (4|M0)              r12.1<2>:d    r14.0<1;0>:d      r127.1<4;2>:d     0:w              
        add3 (4|M0)              r17.1<2>:d    r16.0<1;0>:d      r127.1<4;2>:d     0:w              
        mov (8|M0)               r14.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        addc (8|M0)              r16.0<1>:ud   r9.0<2;1,0>:ud    r118.0<2;1,0>:ud {AccWrEn,Compacted}
        mov (4|M0)               r18.0<2>:d    r19.0<1;1,0>:d                  
        add3 (8|M0)              r15.0<1>:d    r14.0<1;0>:d      r9.1<4;2>:d       r25.0<1>:d       {I@3}
        add3 (4|M0)              r18.1<2>:d    r20.0<1;0>:d      r127.1<4;2>:d     0:w              
        mov (8|M0)               r26.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        addc (8|M0)              r8.0<1>:ud    r9.0<2;1,0>:ud    r11.0<2;1,0>:ud  {AccWrEn,Compacted}
        mov (8|M0)               r21.0<2>:d    r13.0<1;1,0>:d                  
        mov (8|M0)               r21.1<2>:d    r15.0<1;1,0>:d                   {I@5}
        mov (8|M0)               r27.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        addc (8|M0)              r15.0<1>:ud   r9.0<2;1,0>:ud    r17.0<2;1,0>:ud  {AccWrEn,Compacted,I@6}
        mov (8|M0)               r23.0<2>:d    r16.0<1;1,0>:d                  
        mov (8|M0)               r19.0<1>:d    r118.1<2;1,0>:d                 
        mov (8|M0)               r13.0<1>:d    r11.1<2;1,0>:d                  
        mov (8|M0)               r25.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mov (8|M0)               r16.0<1>:d    r17.1<2;1,0>:d                  
        mov (8|M0)               r6.0<1>:hf    r36.0<1;1,0>:f                  
        mov (8|M0)               r6.8<1>:hf    r37.0<1;1,0>:f                  
        mov (8|M0)               r7.0<1>:hf    r38.0<1;1,0>:f                  
        mov (8|M0)               r7.8<1>:hf    r39.0<1;1,0>:f                  
        add3 (8|M0)              r20.0<1>:d    r26.0<1;0>:d      r9.1<4;2>:d       r19.0<1>:d       {I@4}
        add3 (8|M0)              r14.0<1>:d    r27.0<1;0>:d      r9.1<4;2>:d       r13.0<1>:d       {I@4}
        add3 (8|M0)              r19.0<1>:d    r25.0<1;0>:d      r9.1<4;2>:d       r16.0<1>:d       {I@3}
        mov (8|M0)               r28.0<2>:d    r8.0<1;1,0>:d                   
        mov (8|M0)               r30.0<2>:d    r15.0<1;1,0>:d                  
        mov (16|M0)              r32.0<1>:d    r6.0<1;1,0>:uw                   {A@3}
        mov (16|M0)              r34.0<1>:d    r7.0<1;1,0>:uw                   {A@1}
        mov (8|M0)               r23.1<2>:d    r20.0<1;1,0>:d                   {I@7}
        mov (8|M0)               r28.1<2>:d    r14.0<1;1,0>:d                   {I@7}
        mov (8|M0)               r30.1<2>:d    r19.0<1;1,0>:d                   {I@7}
        send.ugm (16|M0)         null     r21     r32:2   0x0            0x08000B84           {A@3,$4} // wr:4+2, rd:0; store.ugm.d16u32.a64
        send.ugm (16|M0)         null     r28     r34:2   0x0            0x08000B84           {A@1,$7} // wr:4+2, rd:0; store.ugm.d16u32.a64
        goto (16|M0)                         L36240                  L42064                
L36240:
        join (16|M0)                         L36400                                
L36256:
        shl (1|M0)               r1.4<1>:d     r85.2<0;1,0>:d    2:w              
        shl (1|M0)               r1.2<1>:d     r85.3<0;1,0>:d    2:w              
        shr (1|M0)               r1.3<1>:ud    r85.2<0;1,0>:ud   0x1E:uw             
        addc (1|M0)              r2.0<1>:ud    r5.6<0;1,0>:ud    r1.4<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r7.0<1>:f     r2.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r7.1<1>:d     r6.0<0;0>:d       r5.7<0;0>:d       r1.5<0>:d        {I@1}
        send.ugm (1|M0)          null     r7      r36:4   0x0            0x0200E584           {A@1,$1} // wr:1+4, rd:0; store.ugm.d32x32t.a64
        goto (16|M0)                         L36400                  L42064                
L36400:
        join (16|M0)                         L37288                                
L36416:
        cmp (1|M0)    (eq)f0.1   null<1>:d     r3.7<0;1,0>:d     0:w              
(f0.1)  cmp (1|M0)    (eq)f0.1   null<1>:d     r3.6<0;1,0>:d     0:w              
(W)     and (1|M0)               f1.0<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(f1.0.any16h) goto (16|M0)                   L37288                  L42064                
L36480:
        shl (1|M0)               r1.2<1>:d     r122.5<0;1,0>:d   12:w              
        shr (1|M0)               r1.3<1>:ud    r122.4<0;1,0>:ud  0x14:uw             
        shl (1|M0)               r1.4<1>:d     r122.4<0;1,0>:d   12:w              
        shl (1|M0)               r2.0<1>:ud    r110.0<0;1,0>:ud  0x5:uw              {$2.src}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@3}
        shl (1|M0)               r6.1<1>:d     r1.4<0;1,0>:d     1:w               {I@3}
        shr (1|M0)               r6.0<1>:ud    r1.4<0;1,0>:ud    0x1F:uw             
        sync.allrd                           ($1,$5,$11,$15)                
        shl (1|M0)               r7.4<1>:d     r2.0<0;1,0>:d     1:w               {Compacted,I@4}
        shl (1|M0)               r3.3<1>:d     r1.5<0;1,0>:d     1:w               {I@4}
        addc (1|M0)              r7.0<1>:ud    r3.6<0;1,0>:ud    r6.1<0;1,0>:ud   {AccWrEn,I@4}
        shr (1|M0)               r7.3<1>:ud    r2.0<0;1,0>:ud    0x1F:uw             
        or (1|M0)                r6.2<1>:d     r3.3<0;1,0>:d     r6.0<0;1,0>:d    {I@3}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$0.src}
        addc (1|M0)              r9.0<1>:ud    r7.0<0;1,0>:ud    r7.4<0;1,0>:ud   {AccWrEn,I@4}
        shl (1|M0)               r110.1<1>:ud  r110.0<0;1,0>:ud  0x5:uw             
        or (1|M0)                r7.5<1>:d     r7.3<0;1,0>:d     0:w               {I@5}
        add3 (1|M0)              r7.2<1>:d     r8.0<0;0>:d       r3.7<0;0>:d       r6.2<0>:d        {I@4}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,$8.src}
        mov (1|M0)               r110.2<2>:f   0.0:f                              
        mov (1|M0)               r110.3<2>:f   0.0:f                              
        mov (1|M0)               r110.4<1>:d   r9.0<0;1,0>:d                    {I@5}
        add (1|M0)               r110.1<1>:ud  r110.1<0;1,0>:ud  0x4000:uw              {I@5}
        add3 (1|M0)              r110.5<1>:d   r10.0<0;0>:d      r7.2<0;0>:d       r7.5<0>:d        {I@3}
L36840:
        or (1|M0)                r1.2<1>:ud    r110.1<0;1,0>:ud  r110.2<0;1,0>:ud {A@2}
        shl (1|M0)               r10.2<1>:d    r110.2<0;1,0>:d   1:w              
        sync.nop                             null                             {Compacted,$9.src}
        shl (1|M0)               r2.0<1>:d     r1.2<0;1,0>:d     2:w               {Compacted,I@2}
        shr (1|M0)               r1.4<1>:ud    r1.2<0;1,0>:ud    0x1E:uw             
        addc (1|M0)              r6.0<1>:ud    r122.0<0;1,0>:ud  r2.0<0;1,0>:ud   {AccWrEn,I@2}
        or (1|M0)                r2.1<1>:d     r1.4<0;1,0>:d     0:w               {I@2}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r8.0<1>:f     r6.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r8.1<1>:d     r7.0<0;0>:d       r122.1<0;0>:d     r2.1<0>:d        {I@1}
        sync.nop                             null                             {Compacted,$3.src}
        addc (1|M0)              r11.0<1>:ud   r110.4<0;1,0>:ud  r10.2<0;1,0>:ud  {AccWrEn,$7.src}
        send.ugm (1|M0)          r9       r8      null:0  0x0            0x04100580           {A@1,$12} // wr:2+0, rd:1; load.ugm.d32.a64
        mov (1|M0)               r12.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,$12.src}
        addc (1|M0)              r6.0<1>:ud    r110.2<0;1,0>:ud  0x1:ud              {AccWrEn}
        shl (1|M0)               r10.0<1>:d    r110.3<0;1,0>:d   1:w               {Compacted}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r110.6<1>:d   r6.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r110.7<1>:d   r7.0<0;0>:d       r110.3<0;0>:d     0:w               {I@2}
        shr (1|M0)               r10.1<1>:ud   r110.2<0;1,0>:ud  0x1F:uw             
        cmp (1|M0)    (eq)f0.0   null<1>:d     r110.7<0;1,0>:d   0:w               {I@2}
        or (1|M0)                r10.3<1>:d    r10.0<0;1,0>:d    r10.1<0;1,0>:d   {I@2}
        sync.nop                             null                             {Compacted,$1.src}
        mov (1|M0)               r14.0<1>:f    r11.0<0;1,0>:f                   {Compacted,$4.src}
        add3 (1|M0)              r14.1<1>:d    r12.0<0;0>:d      r110.5<0;0>:d     r10.3<0>:d       {I@1}
(f0.0)  cmp (1|M0)    (eq)f0.0   null<1>:d     r110.6<0;1,0>:d   32:w              
(W)     and (1|M0)               f0.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
        mov (1|M0)               r3.6<2>:hf    r9.0<0;1,0>:f                    {$12.dst}
        mov (1|M0)               r2.0<1>:d     r3.6<0;1,0>:uw                   {F@1}
        send.ugm (1|M0)          null     r14     r2:1    0x0            0x04000B84           {A@1,$9} // wr:2+1, rd:0; store.ugm.d16u32.a64
(f0.1.any16h) goto (16|M0)                   L37288                  L42064                
L37256:
(W)     mov (2|M0)               r110.2<1>:ud  r110.6<1;1,0>:ud                
        goto.b (16|M0)                       L37288                  L36840                
L37288:
        join (16|M0)                         L38232                                
L37304:
        cmp (1|M0)    (eq)f1.1   null<1>:d     r3.7<0;1,0>:d     0:w              
(f1.1)  cmp (1|M0)    (eq)f1.1   null<1>:d     r3.6<0;1,0>:d     0:w              
(W)     and (1|M0)               f0.0<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(f0.0.any16h) goto (16|M0)                   L38232                  L42064                
L37368:
        shl (1|M0)               r1.2<1>:d     r122.5<0;1,0>:d   12:w              
        shr (1|M0)               r1.3<1>:ud    r122.4<0;1,0>:ud  0x14:uw             
        shl (1|M0)               r1.4<1>:d     r122.4<0;1,0>:d   12:w              
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        shl (1|M0)               r6.0<1>:d     r1.4<0;1,0>:d     1:w               {Compacted,I@2}
        sync.allrd                           ($1,$5,$15)                
        shl (1|M0)               r7.4<1>:d     r110.2<0;1,0>:d   1:w               {$11.src}
        sync.nop                             null                             {Compacted,$9.src}
        shr (1|M0)               r2.1<1>:ud    r1.4<0;1,0>:ud    0x1F:uw              {$2.src}
        shl (1|M0)               r2.0<1>:d     r1.5<0;1,0>:d     1:w               {Compacted,I@4}
        addc (1|M0)              r7.0<1>:ud    r3.6<0;1,0>:ud    r6.0<0;1,0>:ud   {AccWrEn,I@4}
        shl (1|M0)               r3.3<1>:d     r110.3<0;1,0>:d   1:w               {Compacted}
        shr (1|M0)               r7.3<1>:ud    r110.2<0;1,0>:ud  0x1F:uw             
        or (1|M0)                r6.1<1>:d     r2.0<0;1,0>:d     r2.1<0;1,0>:d    {I@4}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$0.src}
        addc (1|M0)              r9.0<1>:ud    r7.0<0;1,0>:ud    r7.4<0;1,0>:ud   {AccWrEn,I@5}
        or (1|M0)                r7.5<1>:d     r3.3<0;1,0>:d     r7.3<0;1,0>:d    {I@4}
        add3 (1|M0)              r7.2<1>:d     r8.0<0;0>:d       r3.7<0;0>:d       r6.1<0>:d        {I@3}
        sync.nop                             null                             {Compacted,$11.src}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,$8.src}
        shr (1|M0)               r110.0<1>:ud  r110.0<0;1,0>:ud  0x2:uw             
        and (1|M0)               r86.2<1>:ud   r86.2<0;1,0>:ud   0xF0:uw              {$13.src}
        mov (1|M0)               r86.0<2>:f    0.0:f                              
        mov (1|M0)               r86.1<2>:f    0.0:f                              
        mov (1|M0)               r86.3<1>:d    r9.0<0;1,0>:d                    {I@6}
        add3 (1|M0)              r86.4<1>:d    r10.0<0;0>:d      r7.2<0;0>:d       r7.5<0>:d        {I@4}
L37728:
        shr (1|M0)               r1.2<1>:ud    r86.0<0;1,0>:ud   0x4:uw              {F@2}
        and (1|M0)               r1.3<1>:d     r86.0<0;1,0>:d    15:w               {Compacted}
        bfn.0xEA (1|M0)          r1.2<1>:ud    r1.2<0;0>:ud      r110.0<0;0>:ud    0x3FFC:uw              {I@2} // s0|s1&s2
        bfn.0xFE (1|M0)          r1.3<1>:ud    0x7000:uw               r86.2<0;0>:ud     r1.3<0>:ud       {I@2} // s0|s1|s2
        shl (1|M0)               r1.2<1>:ud    r1.2<0;1,0>:ud    0x8:uw              {I@2}
        shl (1|M0)               r9.2<1>:d     r86.0<0;1,0>:d    1:w               {Compacted}
        sync.nop                             null                             {Compacted,$3.src}
        add (1|M0)               r2.0<1>:ud    r1.3<0;1,0>:ud    r1.2<0;1,0>:ud   {I@2}
        shl (1|M0)               r9.0<1>:d     r86.1<0;1,0>:d    1:w               {Compacted,F@1}
        shl (1|M0)               r6.0<1>:d     r2.0<0;1,0>:d     1:w               {Compacted,I@2}
        shr (1|M0)               r3.3<1>:ud    r2.0<0;1,0>:ud    0x1F:uw             
        addc (1|M0)              r7.0<1>:ud    r122.0<0;1,0>:ud  r6.0<0;1,0>:ud   {AccWrEn,I@2}
        or (1|M0)                r6.1<1>:d     r3.3<0;1,0>:d     0:w               {I@2}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r10.0<1>:f    r7.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r10.1<1>:d    r8.0<0;0>:d       r122.1<0;0>:d     r6.1<0>:d        {I@1}
        sync.nop                             null                             {Compacted,$9.src}
        addc (1|M0)              r11.0<1>:ud   r86.3<0;1,0>:ud   r9.2<0;1,0>:ud   {AccWrEn,$7.src}
        send.ugm (1|M0)          r13      r10     null:0  0x0            0x04100B80           {A@1,$10} // wr:2+0, rd:1; load.ugm.d16u32.a64
        mov (1|M0)               r12.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,$12.src}
        addc (1|M0)              r6.0<1>:ud    r86.0<0;1,0>:ud   0x1:ud              {AccWrEn}
        shr (1|M0)               r9.1<1>:ud    r86.0<0;1,0>:ud   0x1F:uw             
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r86.6<1>:d    r6.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r86.7<1>:d    r7.0<0;0>:d       r86.1<0;0>:d      0:w               {I@2}
        or (1|M0)                r9.3<1>:d     r9.0<0;1,0>:d     r9.1<0;1,0>:d   
        cmp (1|M0)    (eq)f1.0   null<1>:d     r86.7<0;1,0>:d    0:w               {I@2}
        mov (1|M0)               r2.0<1>:f     r11.0<0;1,0>:f                   {Compacted}
        add3 (1|M0)              r2.1<1>:d     r12.0<0;0>:d      r86.4<0;0>:d      r9.3<0>:d        {I@2}
(f1.0)  cmp (1|M0)    (eq)f1.0   null<1>:d     r86.6<0;1,0>:d    64:w              
(W)     and (1|M0)               f1.1<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
        sync.nop                             null                             {Compacted,$10.dst}
        sync.nop                             null                             {Compacted,$1.src}
        mov (1|M0)               r14.0<1>:d    r13.0<0;1,0>:uw                  {$4.src}
        send.ugm (1|M0)          null     r2      r14:1   0x0            0x04000B84           {A@1,$3} // wr:2+1, rd:0; store.ugm.d16u32.a64
(f1.1.any16h) goto (16|M0)                   L38232                  L42064                
L38200:
(W)     mov (2|M0)               r86.0<1>:ud   r86.6<1;1,0>:ud                 
        goto.b (16|M0)                       L38232                  L37728                
L38232:
        join (16|M0)                         L39176                                
L38248:
        cmp (1|M0)    (eq)f0.1   null<1>:d     r3.7<0;1,0>:d     0:w              
(f0.1)  cmp (1|M0)    (eq)f0.1   null<1>:d     r3.6<0;1,0>:d     0:w              
(W)     and (1|M0)               f1.0<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(f1.0.any16h) goto (16|M0)                   L39176                  L42064                
L38312:
        shl (1|M0)               r1.2<1>:d     r122.5<0;1,0>:d   12:w              
        shr (1|M0)               r1.3<1>:ud    r122.4<0;1,0>:ud  0x14:uw             
        shl (1|M0)               r1.4<1>:d     r122.4<0;1,0>:d   12:w              
        sync.allrd                           ($3,$9)                
        shl (1|M0)               r2.0<1>:ud    r110.0<0;1,0>:ud  0x6:uw              {$2.src}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@3}
        shl (1|M0)               r6.1<1>:d     r1.4<0;1,0>:d     1:w               {I@3}
        shr (1|M0)               r6.0<1>:ud    r1.4<0;1,0>:ud    0x1F:uw             
        sync.allrd                           ($1,$5,$11,$15)                
        shl (1|M0)               r7.4<1>:d     r2.0<0;1,0>:d     1:w               {Compacted,I@4}
        shl (1|M0)               r3.3<1>:d     r1.5<0;1,0>:d     1:w               {I@4}
        addc (1|M0)              r7.0<1>:ud    r3.6<0;1,0>:ud    r6.1<0;1,0>:ud   {AccWrEn,I@4}
        shr (1|M0)               r7.3<1>:ud    r2.0<0;1,0>:ud    0x1F:uw             
        or (1|M0)                r6.2<1>:d     r3.3<0;1,0>:d     r6.0<0;1,0>:d    {I@3}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$0.src}
        addc (1|M0)              r9.0<1>:ud    r7.0<0;1,0>:ud    r7.4<0;1,0>:ud   {AccWrEn,I@4}
        shl (1|M0)               r110.1<1>:ud  r110.0<0;1,0>:ud  0x6:uw             
        or (1|M0)                r7.5<1>:d     r7.3<0;1,0>:d     0:w               {I@5}
        add3 (1|M0)              r7.2<1>:d     r8.0<0;0>:d       r3.7<0;0>:d       r6.2<0>:d        {I@4}
        sync.allrd                           ($4,$7,$8)                
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,$2.src}
        mov (1|M0)               r110.2<2>:f   0.0:f                              
        mov (1|M0)               r110.3<2>:f   0.0:f                              
        mov (1|M0)               r110.4<1>:d   r9.0<0;1,0>:d                    {I@5}
        add (1|M0)               r110.1<1>:ud  r110.1<0;1,0>:ud  0x2800:uw              {I@5}
        add3 (1|M0)              r110.5<1>:d   r10.0<0;0>:d      r7.2<0;0>:d       r7.5<0>:d        {I@3}
L38704:
        or (1|M0)                r1.2<1>:ud    r110.1<0;1,0>:ud  r110.2<0;1,0>:ud {A@2}
        shl (1|M0)               r10.2<1>:d    r110.2<0;1,0>:d   1:w              
        sync.nop                             null                             {Compacted,$5.src}
        shl (1|M0)               r2.0<1>:d     r1.2<0;1,0>:d     2:w               {Compacted,I@2}
        shr (1|M0)               r1.4<1>:ud    r1.2<0;1,0>:ud    0x1E:uw             
        addc (1|M0)              r6.0<1>:ud    r122.0<0;1,0>:ud  r2.0<0;1,0>:ud   {AccWrEn,I@2}
        or (1|M0)                r2.1<1>:d     r1.4<0;1,0>:d     0:w               {I@2}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r8.0<1>:f     r6.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r8.1<1>:d     r7.0<0;0>:d       r122.1<0;0>:d     r2.1<0>:d        {I@1}
        sync.allrd                           ($3,$7,$9,$15)                
        addc (1|M0)              r11.0<1>:ud   r110.4<0;1,0>:ud  r10.2<0;1,0>:ud  {AccWrEn,$11.src}
        send.ugm (1|M0)          r9       r8      null:0  0x0            0x04100580           {A@1,$6} // wr:2+0, rd:1; load.ugm.d32.a64
        sync.nop                             null                             {Compacted,$12.src}
        mov (1|M0)               r12.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,$8.src}
        addc (1|M0)              r6.0<1>:ud    r110.2<0;1,0>:ud  0x1:ud              {AccWrEn}
        shl (1|M0)               r10.0<1>:d    r110.3<0;1,0>:d   1:w               {Compacted}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r110.6<1>:d   r6.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r110.7<1>:d   r7.0<0;0>:d       r110.3<0;0>:d     0:w               {I@2}
        shr (1|M0)               r10.1<1>:ud   r110.2<0;1,0>:ud  0x1F:uw             
        cmp (1|M0)    (eq)f0.0   null<1>:d     r110.7<0;1,0>:d   0:w               {I@2}
        or (1|M0)                r10.3<1>:d    r10.0<0;1,0>:d    r10.1<0;1,0>:d   {I@2}
        sync.allrd                           ($1,$4,$13)                
        mov (1|M0)               r14.0<1>:f    r11.0<0;1,0>:f                   {Compacted,$10.src}
        add3 (1|M0)              r14.1<1>:d    r12.0<0;0>:d      r110.5<0;0>:d     r10.3<0>:d       {I@1}
(f0.0)  cmp (1|M0)    (eq)f0.0   null<1>:d     r110.6<0;1,0>:d   64:w              
(W)     and (1|M0)               f0.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
        mov (1|M0)               r3.6<2>:hf    r9.0<0;1,0>:f                    {$6.dst}
        mov (1|M0)               r2.0<1>:d     r3.6<0;1,0>:uw                   {F@1}
        send.ugm (1|M0)          null     r14     r2:1    0x0            0x04000B84           {A@1,$5} // wr:2+1, rd:0; store.ugm.d16u32.a64
(f0.1.any16h) goto (16|M0)                   L39176                  L42064                
L39144:
(W)     mov (2|M0)               r110.2<1>:ud  r110.6<1;1,0>:ud                
        goto.b (16|M0)                       L39176                  L38704                
L39176:
        join (16|M0)                         L40224                                
L39192:
        cmp (1|M0)    (eq)f1.1   null<1>:d     r3.7<0;1,0>:d     0:w              
(f1.1)  cmp (1|M0)    (eq)f1.1   null<1>:d     r3.6<0;1,0>:d     0:w              
(W)     and (1|M0)               f0.0<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(f0.0.any16h) goto (16|M0)                   L40224                  L42064                
L39256:
        shl (1|M0)               r1.2<1>:d     r122.5<0;1,0>:d   12:w              
        shr (1|M0)               r1.3<1>:ud    r122.4<0;1,0>:ud  0x14:uw             
        shl (1|M0)               r1.4<1>:d     r122.4<0;1,0>:d   12:w              
        sync.allrd                           ($3,$5,$9)                
        shl (1|M0)               r2.0<1>:d     r94.3<0;1,0>:d    5:w               {Compacted,$2.src}
        shr (1|M0)               r2.1<1>:ud    r94.2<0;1,0>:ud   0x1B:uw             
        shl (1|M0)               r6.0<1>:d     r94.2<0;1,0>:d    5:w               {Compacted}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@5}
        shl (1|M0)               r6.3<1>:d     r1.4<0;1,0>:d     1:w               {I@5}
        shr (1|M0)               r6.2<1>:ud    r1.4<0;1,0>:ud    0x1F:uw             
        or (1|M0)                r6.1<1>:d     r2.0<0;1,0>:d     r2.1<0;1,0>:d    {I@5}
        sync.allrd                           ($0,$1,$11,$15)                
        shl (1|M0)               r7.5<1>:d     r6.0<0;1,0>:d     1:w               {Compacted,I@5}
        shl (1|M0)               r3.3<1>:d     r1.5<0;1,0>:d     1:w               {I@5}
        addc (1|M0)              r7.0<1>:ud    r3.6<0;1,0>:ud    r6.3<0;1,0>:ud   {AccWrEn,I@5}
        shr (1|M0)               r7.4<1>:ud    r6.0<0;1,0>:ud    0x1F:uw             
        shl (1|M0)               r7.3<1>:d     r6.1<0;1,0>:d     1:w               {I@5}
        or (1|M0)                r6.4<1>:d     r3.3<0;1,0>:d     r6.2<0;1,0>:d    {I@4}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r2.0<1>:ud    r7.0<0;1,0>:ud    r7.5<0;1,0>:ud   {AccWrEn,I@5}
        or (1|M0)                r7.6<1>:d     r7.3<0;1,0>:d     r7.4<0;1,0>:d    {I@4}
        add3 (1|M0)              r7.2<1>:d     r8.0<0;0>:d       r3.7<0;0>:d       r6.4<0>:d        {I@3}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r86.0<2>:f    0.0:f                               {$13.src}
        mov (1|M0)               r86.1<2>:f    0.0:f                              
        mov (1|M0)               r86.4<1>:d    r2.0<0;1,0>:d                    {I@4}
        add3 (1|M0)              r86.5<1>:d    r9.0<0;0>:d       r7.2<0;0>:d       r7.6<0>:d        {I@2}
L39648:
        shr (1|M0)               r1.2<1>:ud    r86.0<0;1,0>:ud   0x2:uw              {F@2}
        shl (1|M0)               r1.3<1>:d     r86.0<0;1,0>:d    3:w               {Compacted}
        and (1|M0)               r1.2<1>:ud    r1.2<0;1,0>:ud    0x4:uw              {I@2}
        bfn.0xEA (1|M0)          r1.4<1>:ud    r86.3<0;0>:ud     r86.0<0;0>:ud     0x1:uw              // s0|s1&s2
        and (1|M0)               r1.3<1>:d     r1.3<0;1,0>:d     112:w               {Compacted,I@3}
        add (1|M0)               r1.2<1>:ud    r1.2<0;1,0>:ud    r122.3<0;1,0>:ud {I@3}
        bfn.0xFE (1|M0)          r1.4<1>:ud    0x4000:uw               r1.4<0;0>:ud      r1.3<0>:ud       {I@2} // s0|s1|s2
        shl (1|M0)               r1.2<1>:ud    r1.2<0;1,0>:ud    0x8:uw              {I@2}
        shl (1|M0)               r9.2<1>:d     r86.0<0;1,0>:d    1:w               {Compacted}
        sync.nop                             null                             {Compacted,$2.src}
        add (1|M0)               r2.0<1>:ud    r1.4<0;1,0>:ud    r1.2<0;1,0>:ud   {I@2}
        shl (1|M0)               r9.0<1>:d     r86.1<0;1,0>:d    1:w               {Compacted,F@1}
        shl (1|M0)               r6.0<1>:d     r2.0<0;1,0>:d     1:w               {Compacted,I@2}
        shr (1|M0)               r3.3<1>:ud    r2.0<0;1,0>:ud    0x1F:uw             
        addc (1|M0)              r7.0<1>:ud    r122.0<0;1,0>:ud  r6.0<0;1,0>:ud   {AccWrEn,I@2}
        or (1|M0)                r6.1<1>:d     r3.3<0;1,0>:d     0:w               {I@2}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        sync.allrd                           ($4,$7,$8,$11)                
        mov (1|M0)               r10.0<1>:f    r7.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r10.1<1>:d    r8.0<0;0>:d       r122.1<0;0>:d     r6.1<0>:d        {I@1}
        sync.allrd                           ($3,$9)                
        addc (1|M0)              r11.0<1>:ud   r86.4<0;1,0>:ud   r9.2<0;1,0>:ud   {AccWrEn,$15.src}
        send.ugm (1|M0)          r13      r10     null:0  0x0            0x04100B80           {A@1,$14} // wr:2+0, rd:1; load.ugm.d16u32.a64
        mov (1|M0)               r12.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,$12.src}
        addc (1|M0)              r6.0<1>:ud    r86.0<0;1,0>:ud   0x1:ud              {AccWrEn}
        shr (1|M0)               r9.1<1>:ud    r86.0<0;1,0>:ud   0x1F:uw             
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r86.6<1>:d    r6.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r86.7<1>:d    r7.0<0;0>:d       r86.1<0;0>:d      0:w               {I@2}
        or (1|M0)                r9.3<1>:d     r9.0<0;1,0>:d     r9.1<0;1,0>:d   
        cmp (1|M0)    (eq)f1.0   null<1>:d     r86.7<0;1,0>:d    0:w               {I@2}
        mov (1|M0)               r2.0<1>:f     r11.0<0;1,0>:f                   {Compacted}
        add3 (1|M0)              r2.1<1>:d     r12.0<0;0>:d      r86.5<0;0>:d      r9.3<0>:d        {I@2}
(f1.0)  cmp (1|M0)    (eq)f1.0   null<1>:d     r86.6<0;1,0>:d    32:w              
(W)     and (1|M0)               f1.1<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
        sync.nop                             null                             {Compacted,$14.dst}
        sync.allrd                           ($1,$13)                
        mov (1|M0)               r14.0<1>:d    r13.0<0;1,0>:uw                  {$10.src}
        send.ugm (1|M0)          null     r2      r14:1   0x0            0x04000B84           {A@1,$2} // wr:2+1, rd:0; store.ugm.d16u32.a64
(f1.1.any16h) goto (16|M0)                   L40224                  L42064                
L40192:
(W)     mov (2|M0)               r86.0<1>:ud   r86.6<1;1,0>:ud                 
        goto.b (16|M0)                       L40224                  L39648                
L40224:
        join (16|M0)                         L41192                                
L40240:
        cmp (1|M0)    (eq)f0.1   null<1>:d     r3.7<0;1,0>:d     0:w              
(f0.1)  cmp (1|M0)    (eq)f0.1   null<1>:d     r3.6<0;1,0>:d     0:w              
(W)     and (1|M0)               f1.0<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(f1.0.any16h) goto (16|M0)                   L41192                  L42064                
L40304:
        shl (1|M0)               r1.2<1>:d     r122.5<0;1,0>:d   12:w              
        shr (1|M0)               r1.3<1>:ud    r122.4<0;1,0>:ud  0x14:uw             
        shl (1|M0)               r1.4<1>:d     r122.4<0;1,0>:d   12:w              
        sync.allrd                           ($3,$5,$9)                
        shl (1|M0)               r2.0<1>:d     r94.3<0;1,0>:d    5:w               {Compacted,$2.src}
        shr (1|M0)               r2.1<1>:ud    r94.2<0;1,0>:ud   0x1B:uw             
        shl (1|M0)               r6.0<1>:d     r94.2<0;1,0>:d    5:w               {Compacted}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@5}
        shl (1|M0)               r6.3<1>:d     r1.4<0;1,0>:d     1:w               {I@5}
        shr (1|M0)               r6.2<1>:ud    r1.4<0;1,0>:ud    0x1F:uw             
        or (1|M0)                r6.1<1>:d     r2.0<0;1,0>:d     r2.1<0;1,0>:d    {I@5}
        sync.allrd                           ($0,$1,$6,$11,$15)                
        shl (1|M0)               r7.5<1>:d     r6.0<0;1,0>:d     1:w               {Compacted,I@5}
        shl (1|M0)               r3.3<1>:d     r1.5<0;1,0>:d     1:w               {I@5}
        addc (1|M0)              r7.0<1>:ud    r3.6<0;1,0>:ud    r6.3<0;1,0>:ud   {AccWrEn,I@5}
        shr (1|M0)               r7.4<1>:ud    r6.0<0;1,0>:ud    0x1F:uw             
        shl (1|M0)               r7.3<1>:d     r6.1<0;1,0>:d     1:w               {I@5}
        or (1|M0)                r6.4<1>:d     r3.3<0;1,0>:d     r6.2<0;1,0>:d    {I@4}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r2.0<1>:ud    r7.0<0;1,0>:ud    r7.5<0;1,0>:ud   {AccWrEn,I@5}
        mul (1|M0)               r94.0<1>:d    r1.0<0;1,0>:uw    96:w               {$11.dst}
        or (1|M0)                r7.6<1>:d     r7.3<0;1,0>:d     r7.4<0;1,0>:d    {I@5}
        add3 (1|M0)              r7.2<1>:d     r8.0<0;0>:d       r3.7<0;0>:d       r6.4<0>:d        {I@4}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$12.src}
        mov (1|M0)               r94.3<2>:f    0.0:f                              
        mov (1|M0)               r94.2<2>:f    0.0:f                              
        mov (1|M0)               r94.4<1>:d    r2.0<0;1,0>:d                    {I@5}
        add (1|M0)               r94.0<1>:d    r94.0<0;1,0>:d    1056:w               {Compacted,I@5}
        add3 (1|M0)              r94.5<1>:d    r9.0<0;0>:d       r7.2<0;0>:d       r7.6<0>:d        {I@3}
L40720:
        or (1|M0)                r1.2<1>:d     r94.0<0;1,0>:d    r94.2<0;1,0>:d   {A@1}
        sync.allrd                           ($4,$7,$8,$11)                
        shl (1|M0)               r10.2<1>:d    r94.2<0;1,0>:d    1:w               {$2.src}
        sync.nop                             null                             {Compacted,$15.src}
        shl (1|M0)               r2.0<1>:d     r1.2<0;1,0>:d     2:w               {Compacted,I@2}
        shr (1|M0)               r1.4<1>:ud    r1.2<0;1,0>:ud    0x1E:uw             
        addc (1|M0)              r6.0<1>:ud    r122.0<0;1,0>:ud  r2.0<0;1,0>:ud   {AccWrEn,I@2}
        or (1|M0)                r2.1<1>:d     r1.4<0;1,0>:d     0:w               {I@2}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r8.0<1>:f     r6.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r8.1<1>:d     r7.0<0;0>:d       r122.1<0;0>:d     r2.1<0>:d        {I@1}
        sync.nop                             null                             {Compacted,$9.src}
        addc (1|M0)              r11.0<1>:ud   r94.4<0;1,0>:ud   r10.2<0;1,0>:ud  {AccWrEn,$3.src}
        send.ugm (1|M0)          r9       r8      null:0  0x0            0x04100580           {A@1,$0} // wr:2+0, rd:1; load.ugm.d32.a64
        mov (1|M0)               r12.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,$12.src}
        addc (1|M0)              r6.0<1>:ud    r94.2<0;1,0>:ud   0x1:ud              {AccWrEn}
        shl (1|M0)               r10.0<1>:d    r94.3<0;1,0>:d    1:w               {Compacted}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r94.6<1>:d    r6.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r94.7<1>:d    r7.0<0;0>:d       r94.3<0;0>:d      0:w               {I@2}
        shr (1|M0)               r10.1<1>:ud   r94.2<0;1,0>:ud   0x1F:uw             
        cmp (1|M0)    (eq)f0.0   null<1>:d     r94.7<0;1,0>:d    0:w               {I@2}
        or (1|M0)                r10.3<1>:d    r10.0<0;1,0>:d    r10.1<0;1,0>:d   {I@2}
        sync.allrd                           ($1,$13)                
        mov (1|M0)               r14.0<1>:f    r11.0<0;1,0>:f                   {Compacted,$10.src}
        add3 (1|M0)              r14.1<1>:d    r12.0<0;0>:d      r94.5<0;0>:d      r10.3<0>:d       {I@1}
(f0.0)  cmp (1|M0)    (eq)f0.0   null<1>:d     r94.6<0;1,0>:d    32:w              
(W)     and (1|M0)               f0.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
        mov (1|M0)               r3.6<2>:hf    r9.0<0;1,0>:f                    {$0.dst}
        mov (1|M0)               r2.0<1>:d     r3.6<0;1,0>:uw                   {F@1}
        send.ugm (1|M0)          null     r14     r2:1    0x0            0x04000B84           {A@1,$15} // wr:2+1, rd:0; store.ugm.d16u32.a64
(f0.1.any16h) goto (16|M0)                   L41192                  L42064                
L41160:
(W)     mov (2|M0)               r94.2<1>:ud   r94.6<1;1,0>:ud                 
        goto.b (16|M0)                       L41192                  L40720                
L41192:
        join (16|M0)                         L42064                                
L41208:
        cmp (1|M0)    (eq)f1.1   null<1>:d     r3.7<0;1,0>:d     0:w              
(f1.1)  cmp (1|M0)    (eq)f1.1   null<1>:d     r3.6<0;1,0>:d     0:w              
(W)     and (1|M0)               f0.0<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(f0.0.any16h) goto (16|M0)                   L42064                  L42064                
L41272:
        shl (1|M0)               r1.4<1>:d     r122.4<0;1,0>:d   12:w              
        shl (1|M0)               r1.2<1>:d     r122.5<0;1,0>:d   12:w              
        shr (1|M0)               r1.3<1>:ud    r122.4<0;1,0>:ud  0x14:uw             
        shl (1|M0)               r6.0<1>:d     r1.4<0;1,0>:d     1:w               {Compacted,I@3}
        sync.allrd                           ($0,$1,$3,$5,$11,$15)                
        shl (1|M0)               r7.4<1>:d     r94.2<0;1,0>:d    1:w               {$6.src}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@3}
        addc (1|M0)              r7.0<1>:ud    r3.6<0;1,0>:ud    r6.0<0;1,0>:ud   {AccWrEn,I@3}
        sync.nop                             null                             {Compacted,$9.src}
        shr (1|M0)               r2.1<1>:ud    r1.4<0;1,0>:ud    0x1F:uw              {$2.src}
        shl (1|M0)               r2.0<1>:d     r1.5<0;1,0>:d     1:w               {Compacted,I@3}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        sync.nop                             null                             {Compacted,$12.src}
        addc (1|M0)              r9.0<1>:ud    r7.0<0;1,0>:ud    r7.4<0;1,0>:ud   {AccWrEn,I@4}
        shl (1|M0)               r3.3<1>:d     r94.3<0;1,0>:d    1:w               {Compacted}
        shr (1|M0)               r7.3<1>:ud    r94.2<0;1,0>:ud   0x1F:uw             
        or (1|M0)                r6.1<1>:d     r2.0<0;1,0>:d     r2.1<0;1,0>:d    {I@5}
        sync.allrd                           ($4,$7,$8)                
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,$2.src}
        addc (1|M0)              r2.0<1>:ud    r122.0<0;1,0>:ud  r7.4<0;1,0>:ud   {AccWrEn}
        or (1|M0)                r7.5<1>:d     r3.3<0;1,0>:d     r7.3<0;1,0>:d    {I@4}
        add3 (1|M0)              r7.2<1>:d     r8.0<0;0>:d       r3.7<0;0>:d       r6.1<0>:d        {I@4}
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r122.2<1>:d   r9.0<0;1,0>:d                    {$11.dst}
        mov (1|M0)               r122.0<2>:f   0.0:f                               {I@5}
        mov (1|M0)               r122.4<1>:d   r2.0<0;1,0>:d                   
        add3 (1|M0)              r122.3<1>:d   r10.0<0;0>:d      r7.2<0;0>:d       r7.5<0>:d        {I@4}
        add3 (1|M0)              r122.5<1>:d   r11.0<0;0>:d      r122.1<0;0>:d     r7.5<0>:d        {I@4}
        mov (1|M0)               r122.1<2>:f   0.0:f                               {I@1}
L41672:
        shl (1|M0)               r1.4<1>:d     r122.0<0;1,0>:d   1:w               {Compacted,F@2}
        shl (1|M0)               r1.2<1>:d     r122.1<0;1,0>:d   1:w               {F@1}
        shr (1|M0)               r1.3<1>:ud    r122.0<0;1,0>:ud  0x1F:uw             
        addc (1|M0)              r2.0<1>:ud    r122.4<0;1,0>:ud  r1.4<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r8.0<1>:f     r2.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r8.1<1>:d     r6.0<0;0>:d       r122.5<0;0>:d     r1.5<0>:d        {I@1}
        cmp (1|M0)    (lt)f1.0   null<1>:ud    r122.0<0;1,0>:ud  0x7C0:uw             
        send.ugm (1|M0)          r11      r8      null:0  0x0            0x04100B80           {A@1,$2} // wr:2+0, rd:1; load.ugm.d16u32.a64
        addc (1|M0)              r7.0<1>:ud    r122.2<0;1,0>:ud  r1.4<0;1,0>:ud   {AccWrEn}
(f1.0)  cmp (1|M0)    (eq)f1.0   null<1>:d     r122.1<0;1,0>:d   0:w              
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$2.src}
        addc (1|M0)              r13.0<1>:ud   r122.0<0;1,0>:ud  0x40:ud              {AccWrEn,$3.src}
        sync.nop                             null                             {Compacted,$0.src}
        mov (1|M0)               r10.0<1>:f    r7.0<0;1,0>:f                    {Compacted,I@4}
(W)     and (1|M0)               f1.1<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
        add3 (1|M0)              r10.1<1>:d    r9.0<0;0>:d       r122.3<0;0>:d     r1.5<0>:d        {I@3}
        sync.allrd                           ($1,$4,$13)                
        mov (1|M0)               r14.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,$10.src}
        mov (1|M0)               r122.6<1>:d   r13.0<0;1,0>:d                   {I@4}
        add3 (1|M0)              r122.7<1>:d   r14.0<0;0>:d      r122.1<0;0>:d     0:w               {I@2}
        sync.nop                             null                             {Compacted,$2.dst}
        sync.nop                             null                             {Compacted,$12.src}
        mov (1|M0)               r12.0<1>:d    r11.0<0;1,0>:uw                  {$8.src}
        send.ugm (1|M0)          null     r10     r12:1   0x0            0x04000B84           {A@1,$0} // wr:2+1, rd:0; store.ugm.d16u32.a64
(~f1.1.any16h) goto (16|M0)                  L42064                  L42064                
L42032:
(W)     mov (2|M0)               r122.0<1>:ud  r122.6<1;1,0>:ud                
        goto.b (16|M0)                       L42064                  L41672                
L42064:
        join (16|M0)                         L42080                                
L42080:
(W)     mov (8|M0)               r127.0<1>:f   r0.0<1;1,0>:f                    {Compacted}
(W)     send.ugm (1|M0)          r6       r0      null:0  0x0            0x0210641F           {$11} // wr:1+0, rd:1; fence invalid flush type scoped to tile
(W)     mov (8|M0)               null<1>:ud    r6.0<1;1,0>:ud                   {$11.dst}
(W)     send.gtwy (1|M0)         null     r127    null:0  0x0            0x02000010           {EOT,A@1} // wr:1+0, rd:0; end of thread
L42136:
        mov (1|M0)               r1.2<1>:d     cr0.0<0;1,0>:ud                  {A@1}
        and (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   -1265:w               {A@1}
        or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   1264:w               {A@1}
        mov (1|M0)               r1.3<1>:f     r94.6<0;1,0>:ud                  {A@1}
        mov (1|M0)               r3.3<1>:f     0xB4C00000:f                               {Compacted}
        math.inv (1|M0)          r2.1<1>:f     r1.3<0;1,0>:f                    {@2,$12}
        mov (1|M0)               r1.5<1>:f     r110.5<0;1,0>:ud                
        sync.nop                             null                             {Compacted,$12.dst}
        mad (1|M0)               r2.1<1>:f     r2.1<0;0>:f       r3.3<0;0>:f       r2.1<0>:f        {F@2}
        mov (1|M0)               r110.4<1>:ud  r1.3<0;1,0>:f                   
        mov (1|M0)               r1.6<1>:ud    r1.5<0;1,0>:f                    {F@2}
        mul (1|M0)               r6.0<1>:f     r2.1<0;1,0>:f     r1.5<0;1,0>:f    {A@1}
        add (1|M0)               r110.4<1>:ud  r94.6<0;1,0>:ud   -r110.4<0;1,0>:ud {I@2}
        add (1|M0)               r1.6<1>:ud    r110.5<0;1,0>:ud  -r1.6<0;1,0>:ud  {I@2}
        mov (1|M0)               r7.0<1>:ud    r6.0<0;1,0>:f                    {F@1}
        mov (1|M0)               r1.4<1>:f     r110.4<0;1,0>:ud                 {I@3}
        mov (1|M0)               r2.0<1>:f     r1.6<0;1,0>:ud                   {Compacted,I@2}
        mov (1|M0)               r7.1<1>:f     r7.0<0;1,0>:ud                   {Compacted,I@1}
(W)     mov (1|M0)               r3.5<1>:hf    0x1:hf                             
        mad (1|M0)               r1.5<1>:f     r1.5<0;0>:f       r7.1<0;0>:f       -r1.3<0>:f       {F@2}
        mad (1|M0)               r7.1<1>:f     r2.0<0;0>:f       r7.1<0;0>:f       -r1.4<0>:f      
        add (1|M0)               r1.5<1>:f     r1.5<0;1,0>:f     r7.1<0;1,0>:f    {F@1}
        mul (1|M0)               r2.1<1>:f     r2.1<0;1,0>:f     r1.5<0;1,0>:f    {F@1}
        mov (1|M0)               r8.0<1>:ud    r2.1<0;1,0>:f                    {F@1}
        add (1|M0)               r7.0<1>:ud    r7.0<0;1,0>:ud    r8.0<0;1,0>:ud   {Compacted,I@1}
(W)     mul (1|M0)               acc0.0<1>:ud  r7.0<0;1,0>:ud    r94.12<0;1,0>:uw {I@1}
        mach (1|M0)              r9.0<1>:ud    r7.0<0;1,0>:ud    r94.6<0;1,0>:ud  {Compacted}
        add (1|M0)               r110.5<1>:ud  r110.5<0;1,0>:ud  -r9.0<0;1,0>:ud  {I@1}
        cmp (1|M0)    (ge)f0.0   null<1>:ud    r110.5<0;1,0>:ud  r94.6<0;1,0>:ud  {I@1}
(f0.0)  sel (1|M0)               r6.0<1>:d     r3.5<0;1,0>:w     0:w              
        add (1|M0)               r6.0<1>:ud    r7.0<0;1,0>:ud    r6.0<0;1,0>:ud   {Compacted,I@1}
        mov (1|M0)               cr0.0<1>:ud   r1.2<0;1,0>:d                    {A@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        ret (16|M0)                          r94.4                            {A@1}
L42640:
(W)     mov (1|M0)               r2.2<1>:w     r95.0<0;1,0>:ub                 
(W)     mov (1|M0)               r1.3<1>:w     r95.2<0;1,0>:ub                 
        mov (1|M0)               r3.3<1>:f     r2.2<0;1,0>:w                    {I@2}
        mov (1|M0)               r2.0<1>:f     r1.3<0;1,0>:w                    {I@1}
        math.inv (1|M0)          r3.3<1>:f     r3.3<0;1,0>:f                    {@2,$13}
        mul (1|M0)               r2.0<1>:f     r2.0<0;1,0>:f     1.000001e+00:f               {F@1}
        sync.nop                             null                             {Compacted,$13.dst}
        mul (1|M0)               r3.3<1>:f     r3.3<0;1,0>:f     r2.0<0;1,0>:f    {Compacted,F@1}
        mov (1|M0)               r6.0<2>:uw    r3.3<0;1,0>:f                    {F@1}
        mov (1|M0)               r95.0<2>:b    r6.0<0;1,0>:b                    {I@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        ret (16|M0)                          r95.2                            {A@1}
L42832:
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
