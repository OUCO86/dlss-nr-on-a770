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
        asr (1|M0)               r75.1<1>:d    r2.2<0;1,0>:d     31:w               {A@1}
        mov (1|M0)               r75.0<1>:d    r0.1<0;1,0>:ud                  
        shr (1|M0)               r75.1<1>:ud   r75.1<0;1,0>:ud   0x1A:uw              {I@2}
        and (1|M0)               r87.0<2>:b    r4.24<0;1,0>:b    1:w              
        add (1|M0)               r75.1<1>:d    r2.2<0;1,0>:d     r75.1<0;1,0>:d   {I@2}
        and (1|M0)               r87.2<2>:b    r5.12<0;1,0>:b    1:w              
        asr (1|M0)               r75.1<1>:d    r75.1<0;1,0>:d    6:w               {Compacted,I@2}
        mov (1|M0)               r75.2<1>:d    r1.0<0;1,0>:uw                   {$0.dst}
        mov (2|M0)               r75.4<1>:d    r75.0<1;1,0>:d                   {I@2}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r87.2         L12296                                 {A@1}
L408:
        asr (1|M0)               r4.6<1>:d     r2.6<0;1,0>:d     31:w              
(W)     mul (1|M0)               acc0.0<1>:d   r87.1<0;1,0>:d    r75.2<0;1,0>:uw 
        shr (1|M0)               r4.6<1>:ud    r4.6<0;1,0>:ud    0x1B:uw              {I@2}
(W)     mach (1|M0)              r2.0<1>:d     r87.1<0;1,0>:d    r75.1<0;1,0>:d  
        add (1|M0)               r4.6<1>:d     r2.6<0;1,0>:d     r4.6<0;1,0>:d    {I@2}
        mov (1|M0)               r75.1<1>:d    r2.0<0;1,0>:d                    {I@2}
        asr (1|M0)               r4.6<1>:d     r4.6<0;1,0>:d     5:w               {I@2}
        add (1|M0)               r9.0<1>:d     r75.0<0;1,0>:d    -r75.1<0;1,0>:d  {Compacted,I@2}
(W)     mul (1|M0)               acc0.0<1>:d   r87.1<0;1,0>:d    r4.12<0;1,0>:uw  {I@2}
        mach (1|M0)              r6.0<1>:d     r87.1<0;1,0>:d    r4.6<0;1,0>:d   
(W)     mul (1|M0)               acc0.0<1>:d   r87.1<0;1,0>:d    r4.12<0;1,0>:uw 
        mach (1|M0)              r7.0<1>:d     r87.1<0;1,0>:d    r4.6<0;1,0>:d   
        shl (1|M0)               r10.0<1>:d    r9.0<0;1,0>:d     11:w               {Compacted,I@5}
        shl (1|M0)               r1.4<1>:d     r7.0<0;1,0>:d     12:w               {Compacted,I@2}
        asr (1|M0)               r7.1<1>:d     r6.0<0;1,0>:d     31:w               {Compacted}
        addc (1|M0)              r2.0<1>:ud    r2.4<0;1,0>:ud    r1.4<0;1,0>:ud   {AccWrEn,I@2}
        shr (1|M0)               r1.3<1>:ud    r7.0<0;1,0>:ud    0x14:uw             
        shl (1|M0)               r1.2<1>:d     r7.1<0;1,0>:d     12:w               {I@3}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        shl (1|M0)               r7.0<1>:ud    r75.2<0;1,0>:ud   0x7:uw             
        addc (1|M0)              r6.0<1>:ud    r3.0<0;1,0>:ud    r10.0<0;1,0>:ud  {AccWrEn}
        shr (1|M0)               r2.1<1>:ud    r9.0<0;1,0>:ud    0x15:uw             
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@5}
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        shl (1|M0)               r1.2<1>:ud    r75.2<0;1,0>:ud   0x6:uw             
        addc (1|M0)              r12.0<1>:ud   r2.0<0;1,0>:ud    r7.0<0;1,0>:ud   {AccWrEn,I@6}
        or (1|M0)                r10.1<1>:d    r2.1<0;1,0>:d     0:w               {Compacted,I@5}
        add3 (1|M0)              r5.7<1>:d     r8.0<0;0>:d       r2.5<0;0>:d       r1.5<0>:d        {I@5}
        mov (1|M0)               r13.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r8.0<1>:ud    r6.0<0;1,0>:ud    r1.2<0;1,0>:ud   {AccWrEn,I@5}
        add3 (1|M0)              r6.2<1>:d     r11.0<0;0>:d      r3.1<0;0>:d       r10.1<0>:d       {I@4}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        add (1|M0)               r87.6<1>:d    r75.0<0;1,0>:d    -r75.1<0;1,0>:d 
        mov (1|M0)               r76.0<1>:f    r8.0<0;1,0>:f                    {Compacted,I@4}
        mov (1|M0)               r75.0<1>:f    r12.0<0;1,0>:f                   {Compacted,I@1}
        add3 (1|M0)              r75.1<1>:d    r13.0<0;0>:d      r5.7<0;0>:d       0:w              
        add3 (1|M0)              r76.1<1>:d    r9.0<0;0>:d       r6.2<0;0>:d       0:w              
        send.ugm (1|M0)          r14      r75     null:0  0x0            0x0240D780           {A@1,$2} // wr:1+0, rd:4; load.ugm.d64x16t.a64
        send.ugm (1|M0)          r10      r76     null:0  0x0            0x0220C780           {A@1,$3} // wr:1+0, rd:2; load.ugm.d64x8t.a64
        add (1|M0)               r77.0<1>:ud   r1.2<0;1,0>:ud    0x2000:uw             
        shr (1|M0)               r87.2<1>:ud   r75.2<0;1,0>:ud   0x2:uw             
        and (1|M0)               r87.5<1>:d    r1.0<0;1,0>:uw    3:w              
        send.slm (1|M0)          null     r7      r14:4   0x0            0x0200D704           {$2} // wr:1+4, rd:0; store.slm.d64x16t.a32
        send.slm (1|M0)          null     r77     r10:2   0x0            0x0200C704           {A@3,$3} // wr:1+2, rd:0; store.slm.d64x8t.a32
(W)     send.slm (1|M0)          r12      r0      null:0  0x0            0x0210001F           {$4} // wr:1+0, rd:1; fence.slm.none.group
(W)     mov (1|M0)               r13.2<1>:f    0.0:f                               {Compacted}
(W)     mov (2|M0)               r13.10<1>:ub  r0.11<0;1,0>:ub                  {F@1}
(W)     mov (8|M0)               null<1>:ud    r12.0<1;1,0>:ud                  {$4.dst}
(W)     send.gtwy (1|M0)         null     r13     null:0  0x0            0x02000004           {A@2,$5} // wr:1+0, rd:0; signal barrier
(W)     sync.bar                             null                            
        cmp (1|M0)    (gt)f0.1   null<1>:d     r2.6<0;1,0>:d     31:w              
        shl (1|M0)               r5.6<1>:ud    r87.2<0;1,0>:ud   0x9:uw             
        shl (1|M0)               r5.3<1>:d     r87.5<0;1,0>:d    9:w              
        mov (1|M0)               r87.3<1>:d    r2.2<0;1,0>:d                   
(W)     and (1|M0)               f0.1<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
        asr (1|M0)               r87.4<1>:d    r2.2<0;1,0>:d     31:w              
        mov (16|M0)              r67.0<1>:d    0:w                              
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
(~f0.1.any16h) goto (16|M0)                  L2792                  L2792                
L1480:
        shl (1|M0)               r1.2<1>:d     r87.4<0;1,0>:d    5:w              
        shr (1|M0)               r1.3<1>:ud    r87.3<0;1,0>:ud   0x1B:uw             
        mov (1|M0)               r75.2<1>:d    r4.6<0;1,0>:d                   
        shl (1|M0)               r75.4<1>:d    r87.3<0;1,0>:d    5:w              
        mov (1|M0)               r76.4<2>:f    0.0:f                              
        mov (1|M0)               r76.5<2>:f    0.0:f                              
        or (1|M0)                r75.5<1>:d    r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@3}
        mov (2|M0)               r75.6<1>:d    r75.2<1;1,0>:d                   {I@3}
        asr (1|M0)               r75.7<1>:d    r4.6<0;1,0>:d     31:w              
        mov (1|M0)               r75.3<1>:d    0:w                              
L1640:
        addc (1|M0)              r2.0<1>:ud    r76.4<0;1,0>:ud   0x1:ud              {AccWrEn,F@2}
(W)     mov (1|M0)               r1.3<1>:hf    0x1:hf                             
        mov (1|M0)               r76.2<1>:d    r2.0<0;1,0>:d                    {I@1}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        cmp (1|M0)    (lt)f1.1   null<1>:ud    r76.2<0;1,0>:ud   r75.6<0;1,0>:ud  {I@2}
        add3 (1|M0)              r76.3<1>:d    r6.0<0;0>:d       r76.5<0;0>:d      0:w               {A@2}
        and (1|M0)               r5.7<1>:d     r76.4<0;1,0>:d    1:w              
        cmp (1|M0)    (lt)f0.0   null<1>:d     r76.3<0;1,0>:d    r75.7<0;1,0>:d   {I@2}
(f1.1)  cmp (1|M0)    (eq)f1.1   null<1>:d     r76.3<0;1,0>:d    r75.7<0;1,0>:d  
(f0.0)  sel (1|M0)               r4.13<1>:uw   r1.3<0;1,0>:uw    0x0:uw              {F@1}
(f1.1)  sel (1|M0)               r1.4<1>:uw    r1.3<0;1,0>:uw    0x0:uw             
        or (1|M0)     (ne)f0.0   null<1>:uw    r1.4<0;1,0>:uw    r4.13<0;1,0>:uw  {I@1}
(W)     and (1|M0)               f0.0<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
(~f0.0.any16h) goto (16|M0)                  L2312                  L2312                
L1856:
        shl (1|M0)               r1.5<1>:d     r76.2<0;1,0>:d    12:w              
        shl (1|M0)               r1.3<1>:d     r76.3<0;1,0>:d    12:w               {Compacted}
        shr (1|M0)               r1.4<1>:ud    r76.2<0;1,0>:ud   0x14:uw             
        addc (1|M0)              r2.0<1>:ud    r75.0<0;1,0>:ud   r1.5<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r1.6<1>:d     r1.3<0;1,0>:d     r1.4<0;1,0>:d    {I@2}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        sync.allrd                           ($2,$6)                
        mov (1|M0)               r7.0<1>:f     r2.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r7.1<1>:d     r6.0<0;0>:d       r75.1<0;0>:d      r1.6<0>:d        {I@1}
        mul (1|M0)               acc0.0<1>:ud  r75.4<0;1,0>:ud   r76.4<0;1,0>:uw 
        sync.allrd                           ($3,$8)                
        send.ugm (1|M0)          r8       r7      null:0  0x0            0x0240D780           {A@1,$9} // wr:1+0, rd:4; load.ugm.d64x16t.a64
        mach (1|M0)              r14.0<1>:ud   r75.4<0;1,0>:ud   r76.2<0;1,0>:ud  {AccWrEn}
        xor (1|M0)               r1.2<1>:d     r5.7<0;1,0>:d     1:w              
        mov (1|M0)               r13.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,$5.src}
(W)     mul (1|M0)               acc0.0<1>:d   r75.4<0;1,0>:d    r76.6<0;1,0>:uw 
        mach (1|M0)              r15.0<1>:d    r75.4<0;1,0>:d    r76.3<0;1,0>:d  
(W)     mul (1|M0)               acc0.0<1>:d   r75.5<0;1,0>:d    r76.4<0;1,0>:uw 
        mach (1|M0)              r2.0<1>:d     r75.5<0;1,0>:d    r76.2<0;1,0>:d  
        addc (1|M0)              r6.0<1>:ud    r76.0<0;1,0>:ud   r13.0<0;1,0>:ud  {AccWrEn,I@5}
        shl (1|M0)               r4.7<1>:d     r1.2<0;1,0>:d     12:w              
        add3 (1|M0)              r1.4<1>:d     r2.0<0;0>:d       r14.0<0;0>:d      r15.0<0>:d       {I@3}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$9.src}
        mov (1|M0)               r16.0<1>:f    r6.0<0;1,0>:f                    {Compacted,I@4}
        mad (1|M0)               r12.0<1>:d    r4.7<0;0>:d       r1.0<0;0>:uw      128:w               {I@3}
        add3 (1|M0)              r16.1<1>:d    r7.0<0;0>:d       r76.1<0;0>:d      r1.4<0>:d        {I@2}
        shl (1|M0)               r1.2<1>:d     r1.2<0;1,0>:d     11:w              
        send.slm (1|M0)          null     r12     r8:4    0x0            0x0200D704           {A@3,$9} // wr:1+4, rd:0; store.slm.d64x16t.a32
        sync.nop                             null                             {Compacted,$9.src}
        send.ugm (1|M0)          r8       r16     null:0  0x0            0x0220C780           {A@1,$10} // wr:1+0, rd:2; load.ugm.d64x8t.a64
        add (1|M0)               r10.0<1>:d    r1.2<0;1,0>:d     r77.0<0;1,0>:d   {Compacted,I@1}
        sync.nop                             null                             {Compacted,$10.dst}
        send.slm (1|M0)          null     r10     r8:2    0x0            0x0200C704           {A@1,$8} // wr:1+2, rd:0; store.slm.d64x8t.a32
L2312:
        join (16|M0)                         L2792                                
L2328:
        shl (1|M0)               r1.2<1>:d     r5.7<0;1,0>:d     12:w              
        shl (1|M0)               r5.7<1>:d     r5.7<0;1,0>:d     11:w              
        add (1|M0)               r2.0<1>:d     r1.2<0;1,0>:d     r5.6<0;1,0>:d    {I@2}
        bfn.0xFE (1|M0)          r6.0<1>:ud    0x2000:uw               r5.7<0;0>:ud      r5.3<0>:ud       {I@2} // s0|s1|s2
        bfn.0xFE (1|M0)          r32.0<1>:ud   0x2100:uw               r5.7<0;0>:ud      r5.3<0>:ud       // s0|s1|s2
        sync.nop                             null                             {Compacted,$2.src}
        or (1|M0)                r15.0<1>:ud   r2.0<0;1,0>:ud    0x100:uw              {I@3}
        sync.allrd                           ($5,$6)                
        send.slm (1|M0)          r7       r2      null:0  0x0            0x0280E700           {$11} // wr:1+0, rd:8; load.slm.d64x32t.a32
        send.slm (1|M0)          r24      r6      null:0  0x0            0x0280E700           {A@3,$12} // wr:1+0, rd:8; load.slm.d64x32t.a32
        send.slm (1|M0)          r33      r32     null:0  0x0            0x0280E700           {A@2,$13} // wr:1+0, rd:8; load.slm.d64x32t.a32
        send.slm (1|M0)          r16      r15     null:0  0x0            0x0280E700           {A@1,$14} // wr:1+0, rd:8; load.slm.d64x32t.a32
        sync.allwr                           ($6,$11,$12,$13,$14)                
        dpas.8x8 (8|M0)          r43:d         null:d            r43:b             r43.0:b          {Atomic}
        dpas.8x8 (8|M0)          r43:d         r43:d             r24:b             r7.0:b           {Atomic}
        dpas.8x8 (8|M0)          r51:d         r51:d             r33:b             r7.0:b           {Atomic}
        dpas.8x8 (8|M0)          r59:d         r59:d             r24:b             r16.0:b          {Atomic}
        dpas.8x8 (8|M0)          r67:d         r67:d             r33:b             r16.0:b          {$6}
(W)     send.slm (1|M0)          r41      r0      null:0  0x0            0x0210001F           {$15} // wr:1+0, rd:1; fence.slm.none.group
(W)     mov (1|M0)               r42.2<1>:f    0.0:f                               {Compacted,$7.src}
(W)     mov (2|M0)               r42.10<1>:ub  r0.11<0;1,0>:ub                  {F@1}
(W)     mov (8|M0)               null<1>:ud    r41.0<1;1,0>:ud                  {$15.dst}
(W)     send.gtwy (1|M0)         null     r42     null:0  0x0            0x02000004           {A@2,$7} // wr:1+0, rd:0; signal barrier
(W)     sync.bar                             null                            
        cmp (1|M0)    (eq)f1.0   null<1>:d     r76.3<0;1,0>:d    r75.3<0;1,0>:d  
(f1.0)  cmp (1|M0)    (eq)f1.0   null<1>:d     r76.2<0;1,0>:d    r75.2<0;1,0>:d  
(W)     and (1|M0)               f1.1<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
(f1.1.any16h) goto (16|M0)                   L2792                  L2792                
L2760:
(W)     mov (2|M0)               r76.4<1>:ud   r76.2<1;1,0>:ud                 
        goto.b (16|M0)                       L2792                  L1640                
L2792:
        join (16|M0)                         L2808                                
L2808:
        shl (1|M0)               r87.6<1>:d    r87.6<0;1,0>:d    6:w              
        shl (1|M0)               r87.5<1>:d    r87.5<0;1,0>:d    4:w              
        shl (1|M0)               r87.1<1>:d    r87.1<0;1,0>:d    7:w               {Compacted}
        or (1|M0)                r87.5<1>:d    r87.6<0;1,0>:d    r87.5<0;1,0>:d   {I@2}
        mov (1|M0)               r87.6<1>:d    0:w                              
        shr (1|M0)               r2.1<1>:ud    r87.5<0;1,0>:ud   0x1E:uw              {I@2}
        shl (1|M0)               r5.6<1>:d     r87.5<0;1,0>:d    2:w              
        shl (1|M0)               r2.0<1>:d     r87.6<0;1,0>:d    2:w               {Compacted,I@3}
        addc (1|M0)              r6.0<1>:ud    r3.2<0;1,0>:ud    r5.6<0;1,0>:ud   {AccWrEn,I@2}
        or (1|M0)                r5.7<1>:d     r2.0<0;1,0>:d     r2.1<0;1,0>:d    {I@2}
        mov (4|M0)               r2.0<1>:w     0x64206420:v                              
        sync.allrd                           ($6,$8)                
        mov (1|M0)               r8.0<1>:f     r6.0<0;1,0>:f                    {Compacted,I@3}
        mov (4|M0)               r6.0<4>:uw    r2.0<1;1,0>:uw                   {A@1}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$2.src}
        mov (4|M0)               r83.0<2>:d    r6.0<4;1,0>:w                    {I@2}
        addc (1|M0)              r9.0<1>:ud    r3.4<0;1,0>:ud    r5.6<0;1,0>:ud   {AccWrEn}
        asr (4|M0)               r83.1<2>:d    r83.0<2;1,0>:d    31:w               {I@2}
        add3 (1|M0)              r8.1<1>:d     r7.0<0;0>:d       r3.3<0;0>:d       r5.7<0>:d       
        mov (4|M0)               r7.0<2>:ud    r83.0<2;1,0>:ud                  {I@2}
        mov (4|M0)               r7.1<2>:ud    r83.1<2;1,0>:ud                 
        send.ugm (1|M0)          r75      r8      null:0  0x0            0x0220C780           {A@3,$0} // wr:1+0, rd:2; load.ugm.d64x8t.a64
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,$3.src}
        sync.nop                             null                             {Compacted,$0.src}
        addc (4|M0)              r8.0<1>:ud    r7.0<2;1,0>:ud    0x8:ud              {AccWrEn,I@2}
        mov (1|M0)               r11.0<1>:f    r9.0<0;1,0>:f                    {Compacted}
        add3 (1|M0)              r11.1<1>:d    r10.0<0;0>:d      r3.5<0;0>:d       r5.7<0>:d        {I@2}
        mov (4|M0)               r9.0<1>:ud    acc0.0<1;1,0>:ud                 {F@1}
        addc (4|M0)              r10.0<1>:ud   r7.0<2;1,0>:ud    0x10:ud              {AccWrEn}
        send.ugm (1|M0)          r85      r11     null:0  0x0            0x0220C780           {A@3,$1} // wr:1+0, rd:2; load.ugm.d64x8t.a64
        shl (1|M0)               r1.2<1>:ud    r87.2<0;1,0>:ud   0x4:uw             
        mov (4|M0)               r11.0<1>:ud   acc0.0<1;1,0>:ud                 {$1.src}
        addc (4|M0)              r6.0<1>:ud    r7.0<2;1,0>:ud    0x18:ud              {AccWrEn}
        add (1|M0)               r87.1<1>:d    r87.1<0;1,0>:d    r1.2<0;1,0>:d    {I@3}
        mov (4|M0)               r12.0<1>:ud   acc0.0<1;1,0>:ud                
        and (1|M0)               r23.4<1>:d    r5.2<0;1,0>:d     -2:w              
        and (1|M0)               r23.3<1>:d    r5.2<0;1,0>:d     -3:w              
        mov (1|M0)               r23.2<1>:d    0:w                              
        mov (4|M0)               r84.0<2>:d    r8.0<1;1,0>:d                   
        mov (4|M0)               r81.0<2>:d    r10.0<1;1,0>:d                  
        shl (1|M0)               r87.2<1>:ud   r87.2<0;1,0>:ud   0x1:uw             
        mov (4|M0)               r82.0<2>:d    r6.0<1;1,0>:d                    {I@7}
        shr (1|M0)               r23.5<1>:ud   r87.1<0;1,0>:ud   0x6:uw              {I@7}
        add3 (4|M0)              r84.1<2>:d    r9.0<1;0>:d       r7.1<4;2>:d       0:w              
        add3 (4|M0)              r81.1<2>:d    r11.0<1;0>:d      r7.1<4;2>:d       0:w              
        add3 (4|M0)              r82.1<2>:d    r12.0<1;0>:d      r7.1<4;2>:d       0:w               {I@7}
L3488:
        or (1|M0)                r24.2<1>:ud   r23.2<0;1,0>:ud   r87.1<0;1,0>:ud  {I@7}
        cmp (1|M0)    (eq)f0.1   null<1>:w     r87.2<0;1,0>:b    0:w              
        cmp (1|M0)    (lt)f1.0   null<1>:d     r24.2<0;1,0>:d    r3.6<0;1,0>:d    {I@2}
        cmp (1|M0)    (eq)f0.0   null<1>:d     r5.2<0;1,0>:d     4:w              
        cmp (1|M0)    (eq)f1.1   null<1>:w     r87.0<0;1,0>:b    0:w              
        or (1|M0)                r24.1<1>:ud   r24.2<0;1,0>:ud   0x8:uw             
(W)     and (1|M0)               f1.0<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
(W)     mov (1|M0)               r87.14<1>:uw  f0.1<0;1,0>:uw                   {Compacted}
(W)     mov (1|M0)               r87.15<1>:uw  f0.0<0;1,0>:uw                  
        cmp (1|M0)    (eq)f0.1   null<1>:d     r23.3<0;1,0>:d    1:w              
(W)     mov (1|M0)               r24.0<1>:uw   f1.1<0;1,0>:uw                   {Compacted}
        cmp (1|M0)    (eq)f0.0   null<1>:d     r23.4<0;1,0>:d    2:w              
(~f1.0.any16h) goto (16|M0)                  L7872                  L7872                
L3680:
        mov (1|M0)               r23.1<1>:d    r23.5<0;1,0>:d                  
        mov (1|M0)               r24.3<1>:d    r3.7<0;1,0>:d                   
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r23.6         L12880                                 {A@1}
L3760:
        shl (1|M0)               r4.6<1>:d     r9.0<0;1,0>:d     3:w               {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r9.0<0;1,0>:d     r3.14<0;1,0>:uw  {Compacted}
        bfn.0xEA (1|M0)          r4.6<1>:ud    r4.6<0;0>:ud      r87.2<0;0>:ud     0x6:uw              {I@2} // s0|s1&s2
(W)     mov (1|M0)               r1.3<1>:hf    0x1:hf                             
        cmp (1|M0)    (lt)f1.1   null<1>:ud    r4.6<0;1,0>:ud    r4.0<0;1,0>:ud   {I@1}
        mach (1|M0)              r9.0<1>:d     r9.0<0;1,0>:d     r3.7<0;1,0>:d    {Compacted}
(W)     mov (1|M0)               r24.1<1>:hf   0.0:hf                             
        add (1|M0)               r9.0<1>:d     r23.5<0;1,0>:d    -r9.0<0;1,0>:d   {Compacted,I@1}
(f1.1)  sel (1|M0)               r1.4<1>:uw    r1.3<0;1,0>:uw    0x0:uw              {F@2}
        shl (1|M0)               r9.0<1>:d     r9.0<0;1,0>:d     3:w               {Compacted,I@2}
        xor (1|M0)    (ne)f1.0   null<1>:uw    r1.4<0;1,0>:uw    0x1:uw              {I@2}
        or (1|M0)                r9.0<1>:d     r9.0<0;1,0>:d     r23.2<0;1,0>:d   {Compacted,I@2}
(f1.1)  sel (1|M0)               r2.0<1>:uw    r1.3<0;1,0>:uw    0x0:uw             
        mov (1|M0)               r23.6<2>:f    0.0:f                              
(f1.0)  cmp (1|M0)    (lt)f1.0   null<1>:ud    r9.0<0;1,0>:ud    r4.1<0;1,0>:ud   {I@2}
        mov (1|M0)               r23.7<2>:f    0.0:f                              
(f1.0)  sel (1|M0)               r2.1<1>:uw    r1.3<0;1,0>:uw    0x0:uw             
        or (1|M0)     (ne)f1.1   null<1>:uw    r2.0<0;1,0>:uw    r2.1<0;1,0>:uw   {I@1}
(W)     and (1|M0)               f1.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(f1.1.any16h) goto (16|M0)                   L4440                  L4440                
L4032:
        add (1|M0)               r4.6<1>:ud    r4.6<0;1,0>:ud    -r4.0<0;1,0>:ud 
        cmp (1|M0)    (lt)f1.0   null<1>:ud    r4.6<0;1,0>:ud    r4.2<0;1,0>:ud   {I@1}
(W)     and (1|M0)               f1.0<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
(~f1.0.any16h) goto (16|M0)                  L4440                  L4440                
L4096:
        add (1|M0)               r9.0<1>:ud    r9.0<0;1,0>:ud    -r4.1<0;1,0>:ud  {Compacted}
        cmp (1|M0)    (lt)f1.1   null<1>:ud    r9.0<0;1,0>:ud    r4.3<0;1,0>:ud   {I@1}
(W)     and (1|M0)               f1.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(~f1.1.any16h) goto (16|M0)                  L4440                  L4440                
L4152:
        mul (1|M0)               acc0.0<1>:ud  r4.6<0;1,0>:ud    r4.6<0;1,0>:uw  
        mach (1|M0)              r7.0<1>:ud    r4.6<0;1,0>:ud    r4.3<0;1,0>:ud   {AccWrEn}
(W)     mov (1|M0)               r24.1<1>:hf   0x1:hf                             
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r2.0<1>:ud    r6.0<0;1,0>:ud    r9.0<0;1,0>:ud   {AccWrEn,I@1}
        mov (1|M0)               r1.2<1>:d     r2.0<0;1,0>:d                    {I@1}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mul (1|M0)               acc0.0<1>:ud  r1.2<0;1,0>:ud    r87.6<0;1,0>:uw  {I@2}
        mach (1|M0)              r10.0<1>:ud   r1.2<0;1,0>:ud    r87.3<0;1,0>:ud  {AccWrEn}
        add3 (1|M0)              r1.3<1>:d     r8.0<0;0>:d       r7.0<0;0>:d       0:w               {I@3}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r1.2<0;1,0>:d     r87.8<0;1,0>:uw 
        mach (1|M0)              r11.0<1>:d    r1.2<0;1,0>:d     r87.4<0;1,0>:d  
(W)     mul (1|M0)               acc0.0<1>:d   r1.3<0;1,0>:d     r87.6<0;1,0>:uw  {I@4}
        mach (1|M0)              r12.0<1>:d    r1.3<0;1,0>:d     r87.3<0;1,0>:d  
        addc (1|M0)              r13.0<1>:ud   r9.0<0;1,0>:ud    r87.5<0;1,0>:ud  {AccWrEn,I@5}
        add3 (1|M0)              r5.7<1>:d     r12.0<0;0>:d      r10.0<0;0>:d      r11.0<0>:d       {I@2}
        mov (1|M0)               r14.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r23.6<1>:d    r13.0<0;1,0>:d                   {A@3}
        add3 (1|M0)              r23.7<1>:d    r14.0<0;0>:d      r5.7<0;0>:d       r87.6<0>:d       {A@2}
L4440:
        join (16|M0)                         L7872                                
L4456:
        asr (1|M0)               r1.3<1>:d     r24.2<0;1,0>:d    31:w              
        shl (1|M0)               r5.6<1>:d     r24.2<0;1,0>:d    2:w              
        shr (1|M0)               r2.1<1>:ud    r24.2<0;1,0>:ud   0x1E:uw             
        shl (1|M0)               r2.0<1>:d     r1.3<0;1,0>:d     2:w               {Compacted,I@3}
        addc (1|M0)              r6.0<1>:ud    r4.4<0;1,0>:ud    r5.6<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r5.7<1>:d     r2.0<0;1,0>:d     r2.1<0;1,0>:d    {I@2}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r8.0<1>:f     r6.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r8.1<1>:d     r7.0<0;0>:d       r4.5<0;0>:d       r5.7<0>:d        {I@1}
        shl (1|M0)               r4.13<1>:w    r23.4<0;1,0>:w    5:w              
        send.ugm (1|M0)          r9       r8      null:0  0x0            0x04100580           {A@1,$9} // wr:2+0, rd:1; load.ugm.d32.a64
        add (1|M0)               a0.0<1>:uw    r4.13<0;1,0>:uw   0x560:uw              {A@1}
(W)     and (1|M0)               f1.0<1>:uw    r24.0<0;1,0>:uw   0x1:uw             
        mov (8|M0)               r10.0<1>:ud   r[a0.0]<1;1,0>:ud               
        add (1|M0)               a0.0<1>:uw    r4.13<0;1,0>:uw   0x660:uw              {A@1}
        mov (8|M0)               r92.0<1>:f    r10.0<1;1,0>:d                   {Compacted,I@2}
        mov (8|M0)               r11.0<1>:ud   r[a0.0]<1;1,0>:ud               
        mov (8|M0)               r88.0<1>:f    r11.0<1;1,0>:d                   {Compacted,A@1}
        sync.nop                             null                             {Compacted,$9.dst}
        mul (8|M0)               r92.0<1>:f    r9.0<0;1,0>:f     r92.0<1;1,0>:f   {Compacted,F@2}
        mul (8|M0)               r88.0<1>:f    r9.0<0;1,0>:f     r88.0<1;1,0>:f   {Compacted,F@2}
        mul (8|M0)               r92.0<1>:f    r75.0<1;1,0>:f    r92.0<1;1,0>:f   {Compacted,F@2}
        mul (8|M0)               r88.0<1>:f    r76.0<1;1,0>:f    r88.0<1;1,0>:f   {Compacted,F@2}
(f1.0.any16h) goto (16|M0)                   L4936                  L4936                
L4760:
        shl (1|M0)               r1.4<1>:d     r23.6<0;1,0>:d    1:w              
        shl (1|M0)               r1.2<1>:d     r23.7<0;1,0>:d    1:w              
        shr (1|M0)               r1.3<1>:ud    r23.6<0;1,0>:ud   0x1F:uw             
        addc (1|M0)              r2.0<1>:ud    r5.0<0;1,0>:ud    r1.4<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r7.0<1>:f     r2.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r7.1<1>:d     r6.0<0;0>:d       r5.1<0;0>:d       r1.5<0>:d        {I@1}
        send.ugm (1|M0)          r8       r7      null:0  0x0            0x0210B780           {A@1,$10} // wr:1+0, rd:1; load.ugm.d64x4t.a64
        mov (8|M0)               r94.0<1>:f    r8.0<1;1,0>:hf                   {$10.dst}
        mov (8|M0)               r90.0<1>:f    r8.8<1;1,0>:hf                  
        goto (16|M0)                         L4936                  L5096                
L4936:
        join (16|M0)                         L5096                                
L4952:
        shl (1|M0)               r1.4<1>:d     r23.6<0;1,0>:d    2:w              
        shl (1|M0)               r1.2<1>:d     r23.7<0;1,0>:d    2:w              
        shr (1|M0)               r1.3<1>:ud    r23.6<0;1,0>:ud   0x1E:uw             
        addc (1|M0)              r2.0<1>:ud    r5.0<0;1,0>:ud    r1.4<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r7.0<1>:f     r2.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r7.1<1>:d     r6.0<0;0>:d       r5.1<0;0>:d       r1.5<0>:d        {I@1}
        send.ugm (1|M0)          r8       r7      null:0  0x0            0x0220C780           {A@1,$11} // wr:1+0, rd:2; load.ugm.d64x8t.a64
        mov (8|M0)               r94.0<1>:f    r8.0<1;1,0>:f                    {Compacted,$11.dst}
        mov (8|M0)               r90.0<1>:f    r9.0<1;1,0>:f                    {Compacted}
L5096:
        join (16|M0)                         L7872                                
L5112:
        mov (1|M0)               r24.4<1>:d    0:w                              
L5128:
        shl (1|M0)               r24.6<1>:w    r24.8<0;1,0>:w    2:w               {I@1}
(W)     and (1|M0)               f1.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
        add (1|M0)               a0.1<1>:uw    r24.6<0;1,0>:uw   0xBC0:uw              {A@1}
        add (1|M0)               a0.0<1>:uw    r24.6<0;1,0>:uw   0xAA0:uw              {A@1}
        mul (1|M0)               r24.2<1>:f    r[a0.1]<0;1,0>:f  r[a0.0]<0;1,0>:f {F@2}
        add (1|M0)               a0.0<1>:uw    r24.6<0;1,0>:uw   0xB80:uw              {A@1}
        add (1|M0)               r24.2<1>:f    r24.2<0;1,0>:f    r[a0.0]<0;1,0>:f {F@1}
(~f1.1.any16h) goto (16|M0)                  L5496                  L5496                 {A@1}
L5256:
        mov (1|M0)               r1.4<2>:hf    r24.2<0;1,0>:f                   {F@1}
        cmp (1|M0)    (lt)f1.0   null<1>:f     r24.2<0;1,0>:f    -4.001953e+00:f              
        mov (1|M0)               r1.3<1>:f     r1.4<0;1,0>:hf                   {F@2}
        mov (1|M0)               r2.1<1>:ud    0xBD650000:ud                             
        sel (1|M0)    (lt)f0.0   r1.3<1>:f     r1.3<0;1,0>:f     4.0:f               {F@1}
        mov (1|M0)               r2.3<1>:ud    0x3EE50000:ud                             
(~f1.0) sel (1|M0)               r2.0<1>:f     r1.3<0;1,0>:f     -4.0:f               {F@1}
        mov (1|M0)               r5.7<1>:ud    0x3F650000:ud                             
        mad (1|M0)               r2.1<1>:f     r2.3<0;0>:f       r2.1<0;0>:f       (abs)r2.0<0>:f   {A@1}
        mov (1|M0)               r4.14<2>:hf   r2.1<0;1,0>:f                    {F@1}
        mov (1|M0)               r5.6<1>:f     r4.14<0;1,0>:hf                  {F@1}
        mad (1|M0)               r2.0<1>:f     r5.7<0;0>:f       r5.6<0;0>:f       r2.0<0>:f        {A@1}
        mov (1|M0)               r6.0<2>:hf    r2.0<0;1,0>:f                    {F@1}
        mul (1|M0)               r1.4<1>:hf    r1.4<0;1,0>:hf    r6.0<0;1,0>:hf   {F@1}
        mov (1|M0)               r24.2<1>:f    r1.4<0;1,0>:hf                   {F@1}
L5496:
        join (16|M0)                         L6168                                
L5512:
(W)     and (1|M0)               f1.0<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(f1.0.any16h) goto (16|M0)                   L5624                  L5624                
L5544:
(W)     mov (1|M0)               f1.0<1>:uw    r87.15<0;1,0>:uw                
        mov (1|M0)               r1.4<2>:hf    r24.2<0;1,0>:f                   {F@1}
        mov (1|M0)               r4.6<1>:f     r1.4<0;1,0>:hf                   {F@1}
(~f1.0) mov (1|M0)               r4.6<1>:f     r24.2<0;1,0>:f                  
        goto (16|M0)                         L5624                  L6056                
L5624:
        join (16|M0)                         L6056                                
L5640:
        cmp (1|M0)    (lt)f1.0   null<1>:f     r24.2<0;1,0>:f    0.0:f               {I@3}
(f1.0)  mov (1|M0)               r24.2<1>:f    -r24.2<0;1,0>:f                 
        sel (1|M0)    (lt)f0.0   r24.2<1>:f    r24.2<0;1,0>:f    448.0:f               {F@1}
        shr (1|M0)               r4.7<1>:ud    r24.2<0;1,0>:ud   0x17:uw              {F@1}
        and (1|M0)               r4.7<1>:ud    r4.7<0;1,0>:ud    0xFF:uw              {I@1}
        sel (1|M0)    (ge)f0.0   r4.7<1>:ud    r4.7<0;1,0>:ud    0x79:uw              {I@1}
        shl (1|M0)               r4.7<1>:ud    r4.7<0;1,0>:ud    0x17:uw              {I@1}
        add (1|M0)               r1.2<1>:ud    -r4.7<0;1,0>:ud   0x80800000:ud              {I@1}
        mul (1|M0)               r1.3<1>:f     r24.2<0;1,0>:f    r1.2<0;1,0>:f    {I@1}
        mov (1|M0)               r5.3<1>:d     r1.3<0;1,0>:f                    {Compacted,F@1}
        mov (1|M0)               r4.6<1>:f     r5.3<0;1,0>:d                    {I@1}
        mad (1|M0)               r24.2<1>:f    -r4.6<0;0>:f      r1.2<0;0>:f       r24.2<0>:f       {F@1}
        cmp (1|M0)    (gt)f1.1   null<1>:f     r24.2<0;1,0>:f    0.5:f               {F@1}
(W)     and (1|M0)               f1.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw              {F@1}
(f1.1.any16h) goto (16|M0)                   L5960                  L5960                
L5872:
        cmp (1|M0)    (lt)f1.1   null<1>:f     r24.2<0;1,0>:f    0.5:f               {A@1}
        and (1|M0)               r5.3<1>:d     r5.3<0;1,0>:d     1:w               {Compacted}
        add (1|M0)               r1.2<1>:f     r4.6<0;1,0>:f     1.0:f              
(~f1.1) cmp (1|M0)    (eq)f1.1   null<1>:d     r5.3<0;1,0>:d     0:w               {A@1}
(~f1.1) mov (1|M0)               r4.6<1>:f     r1.2<0;1,0>:f                    {F@1}
        goto (16|M0)                         L5960                  L5992                
L5960:
        join (16|M0)                         L5992                                
L5976:
        add (1|M0)               r4.6<1>:f     r4.6<0;1,0>:f     1.0:f               {F@1}
L5992:
        join (16|M0)                         L6056                                
L6008:
        add (1|M0)               r4.7<1>:ud    r4.7<0;1,0>:ud    0xFE800000:ud             
        mul (1|M0)               r4.6<1>:f     r4.6<0;1,0>:f     r4.7<0;1,0>:f    {A@1}
(f1.0)  mov (1|M0)               r4.6<1>:f     -r4.6<0;1,0>:f                   {F@1}
L6056:
        join (16|M0)                         L6168                                
L6072:
        add (1|M0)               r24.4<1>:d    r24.4<0;1,0>:d    1:w              
        add (1|M0)               a0.0<1>:uw    r24.6<0;1,0>:uw   0x9A0:uw              {A@1}
        cmp (1|M0)    (eq)f1.0   null<1>:d     r24.4<0;1,0>:d    8:w               {A@1}
        mov (1|M0)               r[a0.0]<1>:f  r4.6<0;1,0>:f                   
(W)     and (1|M0)               f1.1<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
(~f1.1.any16h) goto.b (16|M0)                L6168                  L5128                
L6168:
        join (16|M0)                         L7872                                
L6184:
        mov (1|M0)               r24.4<1>:d    0:w                              
L6200:
        shl (1|M0)               r24.6<1>:w    r24.8<0;1,0>:w    2:w               {I@1}
(W)     and (1|M0)               f1.0<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
        add (1|M0)               a0.1<1>:uw    r24.6<0;1,0>:uw   0xB40:uw              {A@1}
        add (1|M0)               a0.0<1>:uw    r24.6<0;1,0>:uw   0xAA0:uw              {A@1}
        mul (1|M0)               r24.2<1>:f    r[a0.1]<0;1,0>:f  r[a0.0,32]<0;1,0>:f
        add (1|M0)               a0.0<1>:uw    r24.6<0;1,0>:uw   0xB00:uw              {A@1}
        add (1|M0)               r24.2<1>:f    r24.2<0;1,0>:f    r[a0.0]<0;1,0>:f {F@1}
(~f1.0.any16h) goto (16|M0)                  L6568                  L6568                 {A@1}
L6328:
        mov (1|M0)               r1.4<2>:hf    r24.2<0;1,0>:f                   {F@1}
        cmp (1|M0)    (lt)f1.1   null<1>:f     r24.2<0;1,0>:f    -4.001953e+00:f              
        mov (1|M0)               r1.3<1>:f     r1.4<0;1,0>:hf                   {F@2}
        mov (1|M0)               r2.1<1>:ud    0xBD650000:ud                             
        sel (1|M0)    (lt)f0.0   r1.3<1>:f     r1.3<0;1,0>:f     4.0:f               {F@1}
        mov (1|M0)               r2.3<1>:ud    0x3EE50000:ud                             
(~f1.1) sel (1|M0)               r2.0<1>:f     r1.3<0;1,0>:f     -4.0:f               {F@1}
        mov (1|M0)               r5.7<1>:ud    0x3F650000:ud                             
        mad (1|M0)               r2.1<1>:f     r2.3<0;0>:f       r2.1<0;0>:f       (abs)r2.0<0>:f   {A@1}
        mov (1|M0)               r4.14<2>:hf   r2.1<0;1,0>:f                    {F@1}
        mov (1|M0)               r5.6<1>:f     r4.14<0;1,0>:hf                  {F@1}
        mad (1|M0)               r2.0<1>:f     r5.7<0;0>:f       r5.6<0;0>:f       r2.0<0>:f        {A@1}
        mov (1|M0)               r6.0<2>:hf    r2.0<0;1,0>:f                    {F@1}
        mul (1|M0)               r1.4<1>:hf    r1.4<0;1,0>:hf    r6.0<0;1,0>:hf   {F@1}
        mov (1|M0)               r24.2<1>:f    r1.4<0;1,0>:hf                   {F@1}
L6568:
        join (16|M0)                         L7256                                
L6584:
(W)     and (1|M0)               f1.1<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(f1.1.any16h) goto (16|M0)                   L6696                  L6696                
L6616:
(W)     mov (1|M0)               f1.1<1>:uw    r87.15<0;1,0>:uw                
        mov (1|M0)               r1.4<2>:hf    r24.2<0;1,0>:f                   {F@1}
        mov (1|M0)               r4.6<1>:f     r1.4<0;1,0>:hf                   {F@1}
(~f1.1) mov (1|M0)               r4.6<1>:f     r24.2<0;1,0>:f                  
        goto (16|M0)                         L6696                  L7128                
L6696:
        join (16|M0)                         L7128                                
L6712:
        cmp (1|M0)    (lt)f1.1   null<1>:f     r24.2<0;1,0>:f    0.0:f               {I@3}
(f1.1)  mov (1|M0)               r24.2<1>:f    -r24.2<0;1,0>:f                 
        sel (1|M0)    (lt)f0.0   r24.2<1>:f    r24.2<0;1,0>:f    448.0:f               {F@1}
        shr (1|M0)               r4.7<1>:ud    r24.2<0;1,0>:ud   0x17:uw              {F@1}
        and (1|M0)               r4.7<1>:ud    r4.7<0;1,0>:ud    0xFF:uw              {I@1}
        sel (1|M0)    (ge)f0.0   r4.7<1>:ud    r4.7<0;1,0>:ud    0x79:uw              {I@1}
        shl (1|M0)               r4.7<1>:ud    r4.7<0;1,0>:ud    0x17:uw              {I@1}
        add (1|M0)               r1.2<1>:ud    -r4.7<0;1,0>:ud   0x80800000:ud              {I@1}
        mul (1|M0)               r1.3<1>:f     r24.2<0;1,0>:f    r1.2<0;1,0>:f    {I@1}
        mov (1|M0)               r5.3<1>:d     r1.3<0;1,0>:f                    {Compacted,F@1}
        mov (1|M0)               r4.6<1>:f     r5.3<0;1,0>:d                    {I@1}
        mad (1|M0)               r24.2<1>:f    -r4.6<0;0>:f      r1.2<0;0>:f       r24.2<0>:f       {F@1}
        cmp (1|M0)    (gt)f1.0   null<1>:f     r24.2<0;1,0>:f    0.5:f               {F@1}
(W)     and (1|M0)               f1.0<1>:uw    f1.0<0;1,0>:uw    0x1:uw              {F@1}
(f1.0.any16h) goto (16|M0)                   L7032                  L7032                
L6944:
        cmp (1|M0)    (lt)f1.0   null<1>:f     r24.2<0;1,0>:f    0.5:f               {A@1}
        and (1|M0)               r5.3<1>:d     r5.3<0;1,0>:d     1:w               {Compacted}
        add (1|M0)               r1.2<1>:f     r4.6<0;1,0>:f     1.0:f              
(~f1.0) cmp (1|M0)    (eq)f1.0   null<1>:d     r5.3<0;1,0>:d     0:w               {A@1}
(~f1.0) mov (1|M0)               r4.6<1>:f     r1.2<0;1,0>:f                    {F@1}
        goto (16|M0)                         L7032                  L7064                
L7032:
        join (16|M0)                         L7064                                
L7048:
        add (1|M0)               r4.6<1>:f     r4.6<0;1,0>:f     1.0:f               {F@1}
L7064:
        join (16|M0)                         L7128                                
L7080:
        add (1|M0)               r4.7<1>:ud    r4.7<0;1,0>:ud    0xFE800000:ud             
        mul (1|M0)               r4.6<1>:f     r4.6<0;1,0>:f     r4.7<0;1,0>:f    {A@1}
(f1.1)  mov (1|M0)               r4.6<1>:f     -r4.6<0;1,0>:f                   {F@1}
L7128:
        join (16|M0)                         L7256                                
L7144:
        add (1|M0)               r24.4<1>:d    r24.4<0;1,0>:d    1:w              
        or (1|M0)                r1.3<1>:uw    r24.6<0;1,0>:uw   0x20:uw             
        cmp (1|M0)    (eq)f1.1   null<1>:d     r24.4<0;1,0>:d    8:w               {A@1}
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0x9A0:uw              {A@1}
        mov (1|M0)               r[a0.0]<1>:f  r4.6<0;1,0>:f                   
(W)     and (1|M0)               f1.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(~f1.1.any16h) goto.b (16|M0)                L7256                  L6200                
L7256:
        join (16|M0)                         L7872                                
L7272:
(W)     and (1|M0)               f1.0<1>:uw    r24.1<0;1,0>:uw   0x1:uw             
(~f1.0.any16h) goto (16|M0)                  L7872                  L7872                
L7304:
(W)     and (1|M0)               f1.1<1>:uw    r87.14<0;1,0>:uw  0x1:uw             
(f1.1.any16h) goto (16|M0)                   L7728                  L7728                
L7336:
        shl (1|M0)               r1.4<1>:d     r23.6<0;1,0>:d    1:w              
        shl (1|M0)               r1.2<1>:d     r23.7<0;1,0>:d    1:w              
        shr (1|M0)               r1.3<1>:ud    r23.6<0;1,0>:ud   0x1F:uw             
        addc (1|M0)              r2.0<1>:ud    r5.4<0;1,0>:ud    r1.4<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r5.6<1>:d     r2.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r5.7<1>:d     r7.0<0;0>:d       r5.5<0;0>:d       r1.5<0>:d        {I@2}
        mov (8|M0)               r8.0<2>:ud    r5.6<0;1,0>:ud                   {I@2}
        mov (8|M0)               r8.1<2>:ud    r5.7<0;1,0>:ud                   {I@2}
        mov (8|M0)               r16.0<1>:d    r83.1<2;1,0>:d                  
        addc (8|M0)              r10.0<1>:ud   r8.0<2;1,0>:ud    r83.0<2;1,0>:ud  {AccWrEn,Compacted,I@2}
        mov (8|M0)               r7.0<1>:d     r81.1<2;1,0>:d                  
        mov (8|M0)               r11.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        addc (8|M0)              r18.0<1>:ud   r8.0<2;1,0>:ud    r81.0<2;1,0>:ud  {AccWrEn,Compacted}
        mov (8|M0)               r6.0<1>:hf    r77.0<1;1,0>:f                   {F@1}
        mov (8|M0)               r19.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mov (8|M0)               r6.8<1>:hf    r78.0<1;1,0>:f                  
        add3 (8|M0)              r17.0<1>:d    r11.0<1;0>:d      r8.1<4;2>:d       r16.0<1>:d       {I@3}
        add3 (8|M0)              r20.0<1>:d    r19.0<1;0>:d      r8.1<4;2>:d       r7.0<1>:d        {I@2}
        mov (8|M0)               r12.0<2>:d    r10.0<1;1,0>:d                  
        mov (8|M0)               r14.0<2>:d    r18.0<1;1,0>:d                  
        mov (16|M0)              r21.0<1>:d    r6.0<1;1,0>:uw                   {A@1}
        mov (8|M0)               r12.1<2>:d    r17.0<1;1,0>:d                   {I@5}
        mov (8|M0)               r14.1<2>:d    r20.0<1;1,0>:d                   {I@5}
        send.ugm (16|M0)         null     r12     r21:2   0x0            0x08000B84           {A@1,$2} // wr:4+2, rd:0; store.ugm.d16u32.a64
        goto (16|M0)                         L7728                  L7872                
L7728:
        join (16|M0)                         L7872                                
L7744:
        shl (1|M0)               r1.4<1>:d     r23.6<0;1,0>:d    2:w              
        shl (1|M0)               r1.2<1>:d     r23.7<0;1,0>:d    2:w              
        shr (1|M0)               r1.3<1>:ud    r23.6<0;1,0>:ud   0x1E:uw             
        addc (1|M0)              r2.0<1>:ud    r5.4<0;1,0>:ud    r1.4<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r7.0<1>:f     r2.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r7.1<1>:d     r6.0<0;0>:d       r5.5<0;0>:d       r1.5<0>:d        {I@1}
        send.ugm (1|M0)          null     r7      r77:2   0x0            0x0200D584           {A@1,$3} // wr:1+2, rd:0; store.ugm.d32x16t.a64
L7872:
        join (16|M0)                         L12224                                
L7888:
        cmp (1|M0)    (lt)f1.0   null<1>:d     r24.1<0;1,0>:d    r3.6<0;1,0>:d   
(W)     and (1|M0)               f1.0<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
(~f1.0.any16h) goto (16|M0)                  L12144                  L12144                
L7936:
        mov (1|M0)               r23.1<1>:d    r23.5<0;1,0>:d                  
        mov (1|M0)               r24.3<1>:d    r3.7<0;1,0>:d                   
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r23.6         L12880                                 {A@1}
L8016:
        shl (1|M0)               r4.6<1>:d     r9.0<0;1,0>:d     3:w               {Compacted}
        shr (1|M0)               r1.2<1>:ud    r24.1<0;1,0>:ud   0x3:uw             
(W)     mul (1|M0)               acc0.0<1>:d   r9.0<0;1,0>:d     r3.14<0;1,0>:uw  {Compacted}
        bfn.0xEA (1|M0)          r4.6<1>:ud    r4.6<0;0>:ud      r1.2<0;0>:ud      0x7:uw              {I@2} // s0|s1&s2
(W)     mov (1|M0)               r2.0<1>:hf    0x1:hf                             
        cmp (1|M0)    (lt)f1.1   null<1>:ud    r4.6<0;1,0>:ud    r4.0<0;1,0>:ud   {I@1}
        mach (1|M0)              r9.0<1>:d     r9.0<0;1,0>:d     r3.7<0;1,0>:d    {Compacted}
(W)     mov (1|M0)               r24.1<1>:hf   0.0:hf                             
        add (1|M0)               r9.0<1>:d     r23.5<0;1,0>:d    -r9.0<0;1,0>:d   {Compacted,I@1}
(f1.1)  sel (1|M0)               r2.1<1>:uw    r2.0<0;1,0>:uw    0x0:uw              {F@2}
        shl (1|M0)               r9.0<1>:d     r9.0<0;1,0>:d     3:w               {Compacted,I@2}
        xor (1|M0)    (ne)f1.0   null<1>:uw    r2.1<0;1,0>:uw    0x1:uw              {I@2}
        or (1|M0)                r9.0<1>:d     r9.0<0;1,0>:d     r23.2<0;1,0>:d   {Compacted,I@2}
(f1.1)  sel (1|M0)               r1.3<1>:uw    r2.0<0;1,0>:uw    0x0:uw             
        mov (1|M0)               r23.6<2>:f    0.0:f                              
(f1.0)  cmp (1|M0)    (lt)f1.0   null<1>:ud    r9.0<0;1,0>:ud    r4.1<0;1,0>:ud   {I@2}
        mov (1|M0)               r23.7<2>:f    0.0:f                              
(f1.0)  sel (1|M0)               r1.4<1>:uw    r2.0<0;1,0>:uw    0x0:uw             
        or (1|M0)     (ne)f1.1   null<1>:uw    r1.3<0;1,0>:uw    r1.4<0;1,0>:uw   {I@1}
(W)     and (1|M0)               f1.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(f1.1.any16h) goto (16|M0)                   L8712                  L8712                
L8304:
        add (1|M0)               r4.6<1>:ud    r4.6<0;1,0>:ud    -r4.0<0;1,0>:ud 
        cmp (1|M0)    (lt)f1.0   null<1>:ud    r4.6<0;1,0>:ud    r4.2<0;1,0>:ud   {I@1}
(W)     and (1|M0)               f1.0<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
(~f1.0.any16h) goto (16|M0)                  L8712                  L8712                
L8368:
        add (1|M0)               r9.0<1>:ud    r9.0<0;1,0>:ud    -r4.1<0;1,0>:ud  {Compacted}
        cmp (1|M0)    (lt)f1.1   null<1>:ud    r9.0<0;1,0>:ud    r4.3<0;1,0>:ud   {I@1}
(W)     and (1|M0)               f1.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(~f1.1.any16h) goto (16|M0)                  L8712                  L8712                
L8424:
        mul (1|M0)               acc0.0<1>:ud  r4.6<0;1,0>:ud    r4.6<0;1,0>:uw  
        mach (1|M0)              r7.0<1>:ud    r4.6<0;1,0>:ud    r4.3<0;1,0>:ud   {AccWrEn}
(W)     mov (1|M0)               r24.1<1>:hf   0x1:hf                             
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r2.0<1>:ud    r6.0<0;1,0>:ud    r9.0<0;1,0>:ud   {AccWrEn,I@1}
        mov (1|M0)               r1.2<1>:d     r2.0<0;1,0>:d                    {I@1}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mul (1|M0)               acc0.0<1>:ud  r1.2<0;1,0>:ud    r87.6<0;1,0>:uw  {I@2}
        mach (1|M0)              r10.0<1>:ud   r1.2<0;1,0>:ud    r87.3<0;1,0>:ud  {AccWrEn}
        add3 (1|M0)              r1.3<1>:d     r8.0<0;0>:d       r7.0<0;0>:d       0:w               {I@3}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r1.2<0;1,0>:d     r87.8<0;1,0>:uw 
        mach (1|M0)              r11.0<1>:d    r1.2<0;1,0>:d     r87.4<0;1,0>:d  
(W)     mul (1|M0)               acc0.0<1>:d   r1.3<0;1,0>:d     r87.6<0;1,0>:uw  {I@4}
        mach (1|M0)              r12.0<1>:d    r1.3<0;1,0>:d     r87.3<0;1,0>:d  
        addc (1|M0)              r13.0<1>:ud   r9.0<0;1,0>:ud    r87.5<0;1,0>:ud  {AccWrEn,I@5}
        add3 (1|M0)              r5.7<1>:d     r12.0<0;0>:d      r10.0<0;0>:d      r11.0<0>:d       {I@2}
        mov (1|M0)               r14.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r23.6<1>:d    r13.0<0;1,0>:d                   {A@3}
        add3 (1|M0)              r23.7<1>:d    r14.0<0;0>:d      r5.7<0;0>:d       r87.6<0>:d       {A@2}
L8712:
        join (16|M0)                         L12144                                
L8728:
        asr (1|M0)               r1.3<1>:d     r24.1<0;1,0>:d    31:w              
        shl (1|M0)               r5.6<1>:d     r24.1<0;1,0>:d    2:w              
        shr (1|M0)               r2.1<1>:ud    r24.1<0;1,0>:ud   0x1E:uw             
        shl (1|M0)               r2.0<1>:d     r1.3<0;1,0>:d     2:w               {Compacted,I@3}
        addc (1|M0)              r6.0<1>:ud    r4.4<0;1,0>:ud    r5.6<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r5.7<1>:d     r2.0<0;1,0>:d     r2.1<0;1,0>:d    {I@2}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r8.0<1>:f     r6.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r8.1<1>:d     r7.0<0;0>:d       r4.5<0;0>:d       r5.7<0>:d        {I@1}
        shl (1|M0)               r4.13<1>:w    r23.4<0;1,0>:w    5:w              
        send.ugm (1|M0)          r9       r8      null:0  0x0            0x04100580           {A@1,$12} // wr:2+0, rd:1; load.ugm.d32.a64
        add (1|M0)               a0.0<1>:uw    r4.13<0;1,0>:uw   0x760:uw              {A@1}
(W)     and (1|M0)               f1.0<1>:uw    r24.0<0;1,0>:uw   0x1:uw             
        mov (8|M0)               r10.0<1>:ud   r[a0.0]<1;1,0>:ud               
        add (1|M0)               a0.0<1>:uw    r4.13<0;1,0>:uw   0x860:uw              {A@1}
        mov (8|M0)               r93.0<1>:f    r10.0<1;1,0>:d                   {Compacted,I@2}
        mov (8|M0)               r11.0<1>:ud   r[a0.0]<1;1,0>:ud               
        mov (8|M0)               r89.0<1>:f    r11.0<1;1,0>:d                   {Compacted,A@1}
        sync.nop                             null                             {Compacted,$12.dst}
        mul (8|M0)               r93.0<1>:f    r9.0<0;1,0>:f     r93.0<1;1,0>:f   {Compacted,F@2}
        mul (8|M0)               r89.0<1>:f    r9.0<0;1,0>:f     r89.0<1;1,0>:f   {Compacted,F@2}
        mul (8|M0)               r93.0<1>:f    r75.0<1;1,0>:f    r93.0<1;1,0>:f   {Compacted,F@2}
        mul (8|M0)               r89.0<1>:f    r76.0<1;1,0>:f    r89.0<1;1,0>:f   {Compacted,F@2}
(f1.0.any16h) goto (16|M0)                   L9208                  L9208                
L9032:
        shl (1|M0)               r1.4<1>:d     r23.6<0;1,0>:d    1:w              
        shl (1|M0)               r1.2<1>:d     r23.7<0;1,0>:d    1:w              
        shr (1|M0)               r1.3<1>:ud    r23.6<0;1,0>:ud   0x1F:uw             
        addc (1|M0)              r2.0<1>:ud    r5.0<0;1,0>:ud    r1.4<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r7.0<1>:f     r2.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r7.1<1>:d     r6.0<0;0>:d       r5.1<0;0>:d       r1.5<0>:d        {I@1}
        send.ugm (1|M0)          r8       r7      null:0  0x0            0x0210B780           {A@1,$13} // wr:1+0, rd:1; load.ugm.d64x4t.a64
        mov (8|M0)               r95.0<1>:f    r8.0<1;1,0>:hf                   {$13.dst}
        mov (8|M0)               r91.0<1>:f    r8.8<1;1,0>:hf                  
        goto (16|M0)                         L9208                  L9368                
L9208:
        join (16|M0)                         L9368                                
L9224:
        shl (1|M0)               r1.4<1>:d     r23.6<0;1,0>:d    2:w              
        shl (1|M0)               r1.2<1>:d     r23.7<0;1,0>:d    2:w              
        shr (1|M0)               r1.3<1>:ud    r23.6<0;1,0>:ud   0x1E:uw             
        addc (1|M0)              r2.0<1>:ud    r5.0<0;1,0>:ud    r1.4<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r7.0<1>:f     r2.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r7.1<1>:d     r6.0<0;0>:d       r5.1<0;0>:d       r1.5<0>:d        {I@1}
        send.ugm (1|M0)          r8       r7      null:0  0x0            0x0220C780           {A@1,$14} // wr:1+0, rd:2; load.ugm.d64x8t.a64
        mov (8|M0)               r95.0<1>:f    r8.0<1;1,0>:f                    {Compacted,$14.dst}
        mov (8|M0)               r91.0<1>:f    r9.0<1;1,0>:f                    {Compacted}
L9368:
        join (16|M0)                         L12144                                
L9384:
        mov (1|M0)               r24.2<1>:d    0:w                              
L9400:
        shl (1|M0)               r24.0<1>:w    r24.4<0;1,0>:w    2:w               {I@1}
(W)     and (1|M0)               f1.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
        add (1|M0)               a0.1<1>:uw    r24.0<0;1,0>:uw   0xBE0:uw              {A@1}
        add (1|M0)               a0.0<1>:uw    r24.0<0;1,0>:uw   0xAA0:uw              {A@1}
        mul (1|M0)               r24.1<1>:f    r[a0.1]<0;1,0>:f  r[a0.0]<0;1,0>:f {F@2}
        add (1|M0)               a0.0<1>:uw    r24.0<0;1,0>:uw   0xBA0:uw              {A@1}
        add (1|M0)               r24.1<1>:f    r24.1<0;1,0>:f    r[a0.0]<0;1,0>:f {F@1}
(~f1.1.any16h) goto (16|M0)                  L9768                  L9768                 {A@1}
L9528:
        mov (1|M0)               r1.4<2>:hf    r24.1<0;1,0>:f                   {F@1}
        cmp (1|M0)    (lt)f1.0   null<1>:f     r24.1<0;1,0>:f    -4.001953e+00:f              
        mov (1|M0)               r1.3<1>:f     r1.4<0;1,0>:hf                   {F@2}
        mov (1|M0)               r2.1<1>:ud    0xBD650000:ud                             
        sel (1|M0)    (lt)f0.0   r1.3<1>:f     r1.3<0;1,0>:f     4.0:f               {F@1}
        mov (1|M0)               r2.3<1>:ud    0x3EE50000:ud                             
(~f1.0) sel (1|M0)               r2.0<1>:f     r1.3<0;1,0>:f     -4.0:f               {F@1}
        mov (1|M0)               r5.7<1>:ud    0x3F650000:ud                             
        mad (1|M0)               r2.1<1>:f     r2.3<0;0>:f       r2.1<0;0>:f       (abs)r2.0<0>:f   {A@1}
        mov (1|M0)               r4.14<2>:hf   r2.1<0;1,0>:f                    {F@1}
        mov (1|M0)               r5.6<1>:f     r4.14<0;1,0>:hf                  {F@1}
        mad (1|M0)               r2.0<1>:f     r5.7<0;0>:f       r5.6<0;0>:f       r2.0<0>:f        {A@1}
        mov (1|M0)               r6.0<2>:hf    r2.0<0;1,0>:f                    {F@1}
        mul (1|M0)               r1.4<1>:hf    r1.4<0;1,0>:hf    r6.0<0;1,0>:hf   {F@1}
        mov (1|M0)               r24.1<1>:f    r1.4<0;1,0>:hf                   {F@1}
L9768:
        join (16|M0)                         L10440                                
L9784:
(W)     and (1|M0)               f1.0<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(f1.0.any16h) goto (16|M0)                   L9896                  L9896                
L9816:
(W)     mov (1|M0)               f1.0<1>:uw    r87.15<0;1,0>:uw                
        mov (1|M0)               r1.4<2>:hf    r24.1<0;1,0>:f                   {F@1}
        mov (1|M0)               r4.6<1>:f     r1.4<0;1,0>:hf                   {F@1}
(~f1.0) mov (1|M0)               r4.6<1>:f     r24.1<0;1,0>:f                  
        goto (16|M0)                         L9896                  L10328                
L9896:
        join (16|M0)                         L10328                                
L9912:
        cmp (1|M0)    (lt)f1.0   null<1>:f     r24.1<0;1,0>:f    0.0:f               {I@3}
(f1.0)  mov (1|M0)               r24.1<1>:f    -r24.1<0;1,0>:f                 
        sel (1|M0)    (lt)f0.0   r24.1<1>:f    r24.1<0;1,0>:f    448.0:f               {F@1}
        shr (1|M0)               r4.7<1>:ud    r24.1<0;1,0>:ud   0x17:uw              {F@1}
        and (1|M0)               r4.7<1>:ud    r4.7<0;1,0>:ud    0xFF:uw              {I@1}
        sel (1|M0)    (ge)f0.0   r4.7<1>:ud    r4.7<0;1,0>:ud    0x79:uw              {I@1}
        shl (1|M0)               r4.7<1>:ud    r4.7<0;1,0>:ud    0x17:uw              {I@1}
        add (1|M0)               r1.2<1>:ud    -r4.7<0;1,0>:ud   0x80800000:ud              {I@1}
        mul (1|M0)               r1.3<1>:f     r24.1<0;1,0>:f    r1.2<0;1,0>:f    {I@1}
        mov (1|M0)               r5.3<1>:d     r1.3<0;1,0>:f                    {Compacted,F@1}
        mov (1|M0)               r4.6<1>:f     r5.3<0;1,0>:d                    {I@1}
        mad (1|M0)               r24.1<1>:f    -r4.6<0;0>:f      r1.2<0;0>:f       r24.1<0>:f       {F@1}
        cmp (1|M0)    (gt)f1.1   null<1>:f     r24.1<0;1,0>:f    0.5:f               {F@1}
(W)     and (1|M0)               f1.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw              {F@1}
(f1.1.any16h) goto (16|M0)                   L10232                  L10232                
L10144:
        cmp (1|M0)    (lt)f1.1   null<1>:f     r24.1<0;1,0>:f    0.5:f               {A@1}
        and (1|M0)               r5.3<1>:d     r5.3<0;1,0>:d     1:w               {Compacted}
        add (1|M0)               r1.2<1>:f     r4.6<0;1,0>:f     1.0:f              
(~f1.1) cmp (1|M0)    (eq)f1.1   null<1>:d     r5.3<0;1,0>:d     0:w               {A@1}
(~f1.1) mov (1|M0)               r4.6<1>:f     r1.2<0;1,0>:f                    {F@1}
        goto (16|M0)                         L10232                  L10264                
L10232:
        join (16|M0)                         L10264                                
L10248:
        add (1|M0)               r4.6<1>:f     r4.6<0;1,0>:f     1.0:f               {F@1}
L10264:
        join (16|M0)                         L10328                                
L10280:
        add (1|M0)               r4.7<1>:ud    r4.7<0;1,0>:ud    0xFE800000:ud             
        mul (1|M0)               r4.6<1>:f     r4.6<0;1,0>:f     r4.7<0;1,0>:f    {A@1}
(f1.0)  mov (1|M0)               r4.6<1>:f     -r4.6<0;1,0>:f                   {F@1}
L10328:
        join (16|M0)                         L10440                                
L10344:
        add (1|M0)               r24.2<1>:d    r24.2<0;1,0>:d    1:w              
        add (1|M0)               a0.0<1>:uw    r24.0<0;1,0>:uw   0x9E0:uw              {A@1}
        cmp (1|M0)    (eq)f1.0   null<1>:d     r24.2<0;1,0>:d    8:w               {A@1}
        mov (1|M0)               r[a0.0]<1>:f  r4.6<0;1,0>:f                   
(W)     and (1|M0)               f1.1<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
(~f1.1.any16h) goto.b (16|M0)                L10440                  L9400                
L10440:
        join (16|M0)                         L12144                                
L10456:
        mov (1|M0)               r24.2<1>:d    0:w                              
L10472:
        shl (1|M0)               r24.0<1>:w    r24.4<0;1,0>:w    2:w               {I@1}
(W)     and (1|M0)               f1.0<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
        add (1|M0)               a0.1<1>:uw    r24.0<0;1,0>:uw   0xB60:uw              {A@1}
        add (1|M0)               a0.0<1>:uw    r24.0<0;1,0>:uw   0xAA0:uw              {A@1}
        mul (1|M0)               r24.1<1>:f    r[a0.1]<0;1,0>:f  r[a0.0,32]<0;1,0>:f
        add (1|M0)               a0.0<1>:uw    r24.0<0;1,0>:uw   0xB20:uw              {A@1}
        add (1|M0)               r24.1<1>:f    r24.1<0;1,0>:f    r[a0.0]<0;1,0>:f {F@1}
(~f1.0.any16h) goto (16|M0)                  L10840                  L10840                 {A@1}
L10600:
        mov (1|M0)               r1.4<2>:hf    r24.1<0;1,0>:f                   {F@1}
        cmp (1|M0)    (lt)f1.1   null<1>:f     r24.1<0;1,0>:f    -4.001953e+00:f              
        mov (1|M0)               r1.3<1>:f     r1.4<0;1,0>:hf                   {F@2}
        mov (1|M0)               r2.1<1>:ud    0xBD650000:ud                             
        sel (1|M0)    (lt)f0.0   r1.3<1>:f     r1.3<0;1,0>:f     4.0:f               {F@1}
        mov (1|M0)               r2.3<1>:ud    0x3EE50000:ud                             
(~f1.1) sel (1|M0)               r2.0<1>:f     r1.3<0;1,0>:f     -4.0:f               {F@1}
        mov (1|M0)               r5.7<1>:ud    0x3F650000:ud                             
        mad (1|M0)               r2.1<1>:f     r2.3<0;0>:f       r2.1<0;0>:f       (abs)r2.0<0>:f   {A@1}
        mov (1|M0)               r4.14<2>:hf   r2.1<0;1,0>:f                    {F@1}
        mov (1|M0)               r5.6<1>:f     r4.14<0;1,0>:hf                  {F@1}
        mad (1|M0)               r2.0<1>:f     r5.7<0;0>:f       r5.6<0;0>:f       r2.0<0>:f        {A@1}
        mov (1|M0)               r6.0<2>:hf    r2.0<0;1,0>:f                    {F@1}
        mul (1|M0)               r1.4<1>:hf    r1.4<0;1,0>:hf    r6.0<0;1,0>:hf   {F@1}
        mov (1|M0)               r24.1<1>:f    r1.4<0;1,0>:hf                   {F@1}
L10840:
        join (16|M0)                         L11528                                
L10856:
(W)     and (1|M0)               f1.1<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(f1.1.any16h) goto (16|M0)                   L10968                  L10968                
L10888:
(W)     mov (1|M0)               f1.1<1>:uw    r87.15<0;1,0>:uw                
        mov (1|M0)               r1.4<2>:hf    r24.1<0;1,0>:f                   {F@1}
        mov (1|M0)               r4.6<1>:f     r1.4<0;1,0>:hf                   {F@1}
(~f1.1) mov (1|M0)               r4.6<1>:f     r24.1<0;1,0>:f                  
        goto (16|M0)                         L10968                  L11400                
L10968:
        join (16|M0)                         L11400                                
L10984:
        cmp (1|M0)    (lt)f1.1   null<1>:f     r24.1<0;1,0>:f    0.0:f               {I@3}
(f1.1)  mov (1|M0)               r24.1<1>:f    -r24.1<0;1,0>:f                 
        sel (1|M0)    (lt)f0.0   r24.1<1>:f    r24.1<0;1,0>:f    448.0:f               {F@1}
        shr (1|M0)               r4.7<1>:ud    r24.1<0;1,0>:ud   0x17:uw              {F@1}
        and (1|M0)               r4.7<1>:ud    r4.7<0;1,0>:ud    0xFF:uw              {I@1}
        sel (1|M0)    (ge)f0.0   r4.7<1>:ud    r4.7<0;1,0>:ud    0x79:uw              {I@1}
        shl (1|M0)               r4.7<1>:ud    r4.7<0;1,0>:ud    0x17:uw              {I@1}
        add (1|M0)               r1.2<1>:ud    -r4.7<0;1,0>:ud   0x80800000:ud              {I@1}
        mul (1|M0)               r1.3<1>:f     r24.1<0;1,0>:f    r1.2<0;1,0>:f    {I@1}
        mov (1|M0)               r5.3<1>:d     r1.3<0;1,0>:f                    {Compacted,F@1}
        mov (1|M0)               r4.6<1>:f     r5.3<0;1,0>:d                    {I@1}
        mad (1|M0)               r24.1<1>:f    -r4.6<0;0>:f      r1.2<0;0>:f       r24.1<0>:f       {F@1}
        cmp (1|M0)    (gt)f1.0   null<1>:f     r24.1<0;1,0>:f    0.5:f               {F@1}
(W)     and (1|M0)               f1.0<1>:uw    f1.0<0;1,0>:uw    0x1:uw              {F@1}
(f1.0.any16h) goto (16|M0)                   L11304                  L11304                
L11216:
        cmp (1|M0)    (lt)f1.0   null<1>:f     r24.1<0;1,0>:f    0.5:f               {A@1}
        and (1|M0)               r5.3<1>:d     r5.3<0;1,0>:d     1:w               {Compacted}
        add (1|M0)               r1.2<1>:f     r4.6<0;1,0>:f     1.0:f              
(~f1.0) cmp (1|M0)    (eq)f1.0   null<1>:d     r5.3<0;1,0>:d     0:w               {A@1}
(~f1.0) mov (1|M0)               r4.6<1>:f     r1.2<0;1,0>:f                    {F@1}
        goto (16|M0)                         L11304                  L11336                
L11304:
        join (16|M0)                         L11336                                
L11320:
        add (1|M0)               r4.6<1>:f     r4.6<0;1,0>:f     1.0:f               {F@1}
L11336:
        join (16|M0)                         L11400                                
L11352:
        add (1|M0)               r4.7<1>:ud    r4.7<0;1,0>:ud    0xFE800000:ud             
        mul (1|M0)               r4.6<1>:f     r4.6<0;1,0>:f     r4.7<0;1,0>:f    {A@1}
(f1.1)  mov (1|M0)               r4.6<1>:f     -r4.6<0;1,0>:f                   {F@1}
L11400:
        join (16|M0)                         L11528                                
L11416:
        add (1|M0)               r24.2<1>:d    r24.2<0;1,0>:d    1:w              
        or (1|M0)                r1.3<1>:uw    r24.0<0;1,0>:uw   0x20:uw             
        cmp (1|M0)    (eq)f1.1   null<1>:d     r24.2<0;1,0>:d    8:w               {A@1}
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0x9E0:uw              {A@1}
        mov (1|M0)               r[a0.0]<1>:f  r4.6<0;1,0>:f                   
(W)     and (1|M0)               f1.0<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(~f1.0.any16h) goto.b (16|M0)                L11528                  L10472                
L11528:
        join (16|M0)                         L12144                                
L11544:
(W)     and (1|M0)               f0.0<1>:uw    r24.1<0;1,0>:uw   0x1:uw             
(~f0.0.any16h) goto (16|M0)                  L12144                  L12144                
L11576:
(W)     and (1|M0)               f1.1<1>:uw    r87.14<0;1,0>:uw  0x1:uw             
(f1.1.any16h) goto (16|M0)                   L12000                  L12000                
L11608:
        shl (1|M0)               r1.4<1>:d     r23.6<0;1,0>:d    1:w              
        shl (1|M0)               r1.2<1>:d     r23.7<0;1,0>:d    1:w              
        shr (1|M0)               r1.3<1>:ud    r23.6<0;1,0>:ud   0x1F:uw             
        addc (1|M0)              r2.0<1>:ud    r5.4<0;1,0>:ud    r1.4<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r5.6<1>:d     r2.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r5.7<1>:d     r7.0<0;0>:d       r5.5<0;0>:d       r1.5<0>:d        {I@2}
        mov (8|M0)               r8.0<2>:ud    r5.6<0;1,0>:ud                   {I@2}
        mov (8|M0)               r8.1<2>:ud    r5.7<0;1,0>:ud                   {I@2}
        mov (8|M0)               r16.0<1>:d    r83.1<2;1,0>:d                  
        addc (8|M0)              r10.0<1>:ud   r8.0<2;1,0>:ud    r83.0<2;1,0>:ud  {AccWrEn,Compacted,I@2}
        mov (8|M0)               r7.0<1>:d     r81.1<2;1,0>:d                  
        mov (8|M0)               r11.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        addc (8|M0)              r18.0<1>:ud   r8.0<2;1,0>:ud    r81.0<2;1,0>:ud  {AccWrEn,Compacted}
        mov (8|M0)               r6.0<1>:hf    r79.0<1;1,0>:f                   {F@1}
        mov (8|M0)               r19.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mov (8|M0)               r6.8<1>:hf    r80.0<1;1,0>:f                  
        add3 (8|M0)              r17.0<1>:d    r11.0<1;0>:d      r8.1<4;2>:d       r16.0<1>:d       {I@3}
        add3 (8|M0)              r20.0<1>:d    r19.0<1;0>:d      r8.1<4;2>:d       r7.0<1>:d        {I@2}
        mov (8|M0)               r12.0<2>:d    r10.0<1;1,0>:d                  
        mov (8|M0)               r14.0<2>:d    r18.0<1;1,0>:d                  
        mov (16|M0)              r21.0<1>:d    r6.0<1;1,0>:uw                   {A@1}
        mov (8|M0)               r12.1<2>:d    r17.0<1;1,0>:d                   {I@5}
        mov (8|M0)               r14.1<2>:d    r20.0<1;1,0>:d                   {I@5}
        send.ugm (16|M0)         null     r12     r21:2   0x0            0x08000B84           {A@1,$4} // wr:4+2, rd:0; store.ugm.d16u32.a64
        goto (16|M0)                         L12000                  L12144                
L12000:
        join (16|M0)                         L12144                                
L12016:
        shl (1|M0)               r1.4<1>:d     r23.6<0;1,0>:d    2:w              
        shl (1|M0)               r1.2<1>:d     r23.7<0;1,0>:d    2:w              
        shr (1|M0)               r1.3<1>:ud    r23.6<0;1,0>:ud   0x1E:uw             
        addc (1|M0)              r2.0<1>:ud    r5.4<0;1,0>:ud    r1.4<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r7.0<1>:f     r2.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r7.1<1>:d     r6.0<0;0>:d       r5.5<0;0>:d       r1.5<0>:d        {I@1}
        send.ugm (1|M0)          null     r7      r79:2   0x0            0x0200D584           {A@1,$8} // wr:1+2, rd:0; store.ugm.d32x16t.a64
L12144:
        join (16|M0)                         L12224                                
L12160:
        add (1|M0)               r23.2<1>:d    r23.2<0;1,0>:d    1:w              
        cmp (1|M0)    (eq)f1.0   null<1>:d     r23.2<0;1,0>:d    8:w               {I@1}
(W)     and (1|M0)               f1.0<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
(~f1.0.any16h) goto.b (16|M0)                L12224                  L3488                
L12224:
        join (16|M0)                         L12240                                
L12240:
(W)     mov (8|M0)               r127.0<1>:f   r0.0<1;1,0>:f                    {Compacted}
(W)     send.ugm (1|M0)          r6       r0      null:0  0x0            0x0210641F           {$15} // wr:1+0, rd:1; fence invalid flush type scoped to tile
(W)     mov (8|M0)               null<1>:ud    r6.0<1;1,0>:ud                   {$15.dst}
(W)     send.gtwy (1|M0)         null     r127    null:0  0x0            0x02000010           {EOT,A@1} // wr:1+0, rd:0; end of thread
L12296:
        mov (1|M0)               r1.2<1>:d     cr0.0<0;1,0>:ud                  {A@1}
        and (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   -1265:w               {A@1}
        or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   1264:w               {A@1}
        mov (1|M0)               r1.5<1>:f     (abs)r75.5<0;1,0>:d              {A@1}
        mov (1|M0)               r5.7<1>:f     0xB4C00000:f                               {Compacted}
        math.inv (1|M0)          r5.6<1>:f     r1.5<0;1,0>:f                    {@2,$0}
        mov (1|M0)               r2.1<1>:f     (abs)r75.4<0;1,0>:d             
        sync.nop                             null                             {Compacted,$0.dst}
        mad (1|M0)               r5.6<1>:f     r5.6<0;0>:f       r5.7<0;0>:f       r5.6<0>:f        {F@2}
        mov (1|M0)               r1.3<1>:d     (abs)r75.4<0;1,0>:d             
        mov (1|M0)               r1.4<1>:d     (abs)r75.5<0;1,0>:d             
        mov (1|M0)               r1.6<1>:ud    r1.5<0;1,0>:f                   
        mov (1|M0)               r2.3<1>:ud    r2.1<0;1,0>:f                    {F@2}
        mul (1|M0)               r6.0<1>:f     r5.6<0;1,0>:f     r2.1<0;1,0>:f    {A@1}
        add (1|M0)               r1.6<1>:ud    r1.4<0;1,0>:ud    -r1.6<0;1,0>:ud  {I@2}
        add (1|M0)               r2.3<1>:ud    r1.3<0;1,0>:ud    -r2.3<0;1,0>:ud  {I@2}
        mov (1|M0)               r7.0<1>:ud    r6.0<0;1,0>:f                    {F@1}
        mov (1|M0)               r2.0<1>:f     r1.6<0;1,0>:ud                   {Compacted,I@3}
        mov (1|M0)               r4.7<1>:f     r2.3<0;1,0>:ud                   {I@2}
        mov (1|M0)               r7.1<1>:f     r7.0<0;1,0>:ud                   {Compacted,I@1}
        xor (1|M0)               r75.5<1>:d    r75.5<0;1,0>:d    r75.4<0;1,0>:d  
        mad (1|M0)               r2.1<1>:f     r2.1<0;0>:f       r7.1<0;0>:f       -r1.5<0>:f       {F@1}
        mad (1|M0)               r7.1<1>:f     r4.7<0;0>:f       r7.1<0;0>:f       -r2.0<0>:f      
(W)     mov (1|M0)               r6.0<1>:hf    0x1:hf                             
        add (1|M0)               r2.1<1>:f     r2.1<0;1,0>:f     r7.1<0;1,0>:f    {F@2}
        asr (1|M0)               r75.5<1>:d    r75.5<0;1,0>:d    31:w               {I@1}
        mul (1|M0)               r5.6<1>:f     r5.6<0;1,0>:f     r2.1<0;1,0>:f    {F@1}
        mov (1|M0)               r8.0<1>:ud    r5.6<0;1,0>:f                    {F@1}
        add (1|M0)               r7.0<1>:ud    r7.0<0;1,0>:ud    r8.0<0;1,0>:ud   {Compacted,I@1}
(W)     mul (1|M0)               acc0.0<1>:ud  r7.0<0;1,0>:ud    r1.8<0;1,0>:uw   {I@1}
        mach (1|M0)              r9.0<1>:ud    r7.0<0;1,0>:ud    r1.4<0;1,0>:ud   {Compacted}
        add (1|M0)               r1.3<1>:ud    r1.3<0;1,0>:ud    -r9.0<0;1,0>:ud  {Compacted,I@1}
        cmp (1|M0)    (ge)f0.0   null<1>:ud    r1.3<0;1,0>:ud    r1.4<0;1,0>:ud   {I@1}
(f0.0)  sel (1|M0)               r4.7<1>:d     r6.0<0;1,0>:w     0:w              
        add3 (1|M0)              r7.0<1>:d     r7.0<0;0>:d       r75.5<0;0>:d      r4.7<0>:d        {I@1}
        xor (1|M0)               r87.1<1>:d    r7.0<0;1,0>:d     r75.5<0;1,0>:d   {I@1}
        mov (1|M0)               cr0.0<1>:ud   r1.2<0;1,0>:d                    {A@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        ret (16|M0)                          r87.2                            {A@1}
L12880:
        mov (1|M0)               r1.2<1>:d     cr0.0<0;1,0>:ud                  {A@1}
        and (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   -1265:w               {A@1}
        or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   1264:w               {A@1}
        mov (1|M0)               r1.3<1>:f     r24.3<0;1,0>:ud                  {Compacted,A@1}
        mov (1|M0)               r2.3<1>:f     0xB4C00000:f                               {Compacted}
        math.inv (1|M0)          r2.1<1>:f     r1.3<0;1,0>:f                    {@2,$1}
        mov (1|M0)               r1.5<1>:f     r23.1<0;1,0>:ud                 
        sync.nop                             null                             {Compacted,$1.dst}
        mad (1|M0)               r2.1<1>:f     r2.1<0;0>:f       r2.3<0;0>:f       r2.1<0>:f        {F@2}
        mov (1|M0)               r23.0<1>:ud   r1.3<0;1,0>:f                   
        mov (1|M0)               r1.6<1>:ud    r1.5<0;1,0>:f                    {F@2}
        mul (1|M0)               r4.7<1>:f     r2.1<0;1,0>:f     r1.5<0;1,0>:f    {F@1}
        add (1|M0)               r23.0<1>:ud   r24.3<0;1,0>:ud   -r23.0<0;1,0>:ud {Compacted,I@2}
        add (1|M0)               r1.6<1>:ud    r23.1<0;1,0>:ud   -r1.6<0;1,0>:ud  {I@2}
        mov (1|M0)               r5.6<1>:ud    r4.7<0;1,0>:f                    {F@1}
        mov (1|M0)               r1.4<1>:f     r23.0<0;1,0>:ud                  {Compacted,I@3}
        mov (1|M0)               r2.0<1>:f     r1.6<0;1,0>:ud                   {Compacted,I@2}
        mov (1|M0)               r5.7<1>:f     r5.6<0;1,0>:ud                   {I@1}
(W)     mov (1|M0)               r4.13<1>:hf   0x1:hf                             
        mad (1|M0)               r1.5<1>:f     r1.5<0;0>:f       r5.7<0;0>:f       -r1.3<0>:f       {F@2}
        mad (1|M0)               r5.7<1>:f     r2.0<0;0>:f       r5.7<0;0>:f       -r1.4<0>:f      
        add (1|M0)               r1.5<1>:f     r1.5<0;1,0>:f     r5.7<0;1,0>:f    {F@1}
        mul (1|M0)               r2.1<1>:f     r2.1<0;1,0>:f     r1.5<0;1,0>:f    {F@1}
        mov (1|M0)               r6.0<1>:ud    r2.1<0;1,0>:f                    {F@1}
        add (1|M0)               r5.6<1>:ud    r5.6<0;1,0>:ud    r6.0<0;1,0>:ud   {I@1}
(W)     mul (1|M0)               acc0.0<1>:ud  r5.6<0;1,0>:ud    r24.6<0;1,0>:uw  {I@1}
        mach (1|M0)              r7.0<1>:ud    r5.6<0;1,0>:ud    r24.3<0;1,0>:ud 
        add (1|M0)               r23.1<1>:ud   r23.1<0;1,0>:ud   -r7.0<0;1,0>:ud  {Compacted,I@1}
        cmp (1|M0)    (ge)f1.0   null<1>:ud    r23.1<0;1,0>:ud   r24.3<0;1,0>:ud  {I@1}
(f1.0)  sel (1|M0)               r8.0<1>:d     r4.13<0;1,0>:w    0:w              
        add (1|M0)               r9.0<1>:ud    r5.6<0;1,0>:ud    r8.0<0;1,0>:ud   {Compacted,I@1}
        mov (1|M0)               cr0.0<1>:ud   r1.2<0;1,0>:d                    {A@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        ret (16|M0)                          r23.6                            {A@1}
L13376:
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
