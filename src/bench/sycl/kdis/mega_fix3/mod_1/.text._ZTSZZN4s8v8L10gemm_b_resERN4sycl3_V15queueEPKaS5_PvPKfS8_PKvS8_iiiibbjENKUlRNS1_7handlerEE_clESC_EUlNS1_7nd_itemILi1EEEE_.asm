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
        asr (1|M0)               r111.5<1>:d   r2.2<0;1,0>:d     31:w               {A@1}
        mov (1|M0)               r111.4<1>:d   r0.1<0;1,0>:ud                  
        shr (1|M0)               r111.5<1>:ud  r111.5<0;1,0>:ud  0x1A:uw              {I@2}
        and (1|M0)               r43.0<2>:b    r4.8<0;1,0>:b     1:w              
        add (1|M0)               r111.5<1>:d   r2.2<0;1,0>:d     r111.5<0;1,0>:d  {I@2}
        and (1|M0)               r43.2<2>:b    r4.28<0;1,0>:b    1:w              
        asr (1|M0)               r111.5<1>:d   r111.5<0;1,0>:d   6:w               {I@2}
        mov (1|M0)               r43.1<1>:d    r1.0<0;1,0>:uw                   {$0.dst}
        mov (2|M0)               r111.0<1>:d   r111.4<1;1,0>:d                  {I@2}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r111.2        L11152                                 {A@1}
L416:
        asr (1|M0)               r43.6<1>:d    r2.6<0;1,0>:d     31:w              
(W)     mul (1|M0)               acc0.0<1>:d   r43.2<0;1,0>:d    r111.10<0;1,0>:uw
        shr (1|M0)               r43.6<1>:ud   r43.6<0;1,0>:ud   0x1B:uw              {I@2}
(W)     mach (1|M0)              r2.0<1>:d     r43.2<0;1,0>:d    r111.5<0;1,0>:d 
        add (1|M0)               r43.6<1>:d    r2.6<0;1,0>:d     r43.6<0;1,0>:d   {I@2}
        mov (1|M0)               r111.5<1>:d   r2.0<0;1,0>:d                    {I@2}
        asr (1|M0)               r43.6<1>:d    r43.6<0;1,0>:d    5:w               {I@2}
        add (1|M0)               r5.4<1>:d     r111.4<0;1,0>:d   -r111.5<0;1,0>:d {I@2}
(W)     mul (1|M0)               acc0.0<1>:d   r43.2<0;1,0>:d    r43.12<0;1,0>:uw {I@2}
        mach (1|M0)              r6.0<1>:d     r43.2<0;1,0>:d    r43.6<0;1,0>:d  
(W)     mul (1|M0)               acc0.0<1>:d   r43.2<0;1,0>:d    r43.12<0;1,0>:uw
        mach (1|M0)              r7.0<1>:d     r43.2<0;1,0>:d    r43.6<0;1,0>:d  
        shl (1|M0)               r9.0<1>:d     r5.4<0;1,0>:d     11:w               {Compacted,I@5}
        shl (1|M0)               r1.4<1>:d     r7.0<0;1,0>:d     12:w               {Compacted,I@2}
        asr (1|M0)               r7.1<1>:d     r6.0<0;1,0>:d     31:w               {Compacted}
        addc (1|M0)              r2.0<1>:ud    r2.4<0;1,0>:ud    r1.4<0;1,0>:ud   {AccWrEn,I@2}
        shr (1|M0)               r1.3<1>:ud    r7.0<0;1,0>:ud    0x14:uw             
        shl (1|M0)               r1.2<1>:d     r7.1<0;1,0>:d     12:w               {I@3}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        shl (1|M0)               r7.0<1>:ud    r43.1<0;1,0>:ud   0x7:uw             
        addc (1|M0)              r6.0<1>:ud    r3.0<0;1,0>:ud    r9.0<0;1,0>:ud   {AccWrEn}
        shr (1|M0)               r2.1<1>:ud    r5.4<0;1,0>:ud    0x15:uw             
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@5}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        shl (1|M0)               r1.2<1>:ud    r43.1<0;1,0>:ud   0x6:uw             
        addc (1|M0)              r11.0<1>:ud   r2.0<0;1,0>:ud    r7.0<0;1,0>:ud   {AccWrEn,I@6}
        or (1|M0)                r9.1<1>:d     r2.1<0;1,0>:d     0:w               {Compacted,I@5}
        add3 (1|M0)              r5.3<1>:d     r8.0<0;0>:d       r2.5<0;0>:d       r1.5<0>:d        {I@5}
        mov (1|M0)               r12.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r8.0<1>:ud    r6.0<0;1,0>:ud    r1.2<0;1,0>:ud   {AccWrEn,I@5}
        add3 (1|M0)              r6.2<1>:d     r10.0<0;0>:d      r3.1<0;0>:d       r9.1<0>:d        {I@4}
        mov (1|M0)               r17.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r45.0<1>:f    r11.0<0;1,0>:f                   {Compacted}
        add3 (1|M0)              r45.1<1>:d    r12.0<0;0>:d      r5.3<0;0>:d       0:w               {I@4}
        mov (1|M0)               r46.0<1>:f    r8.0<0;1,0>:f                    {Compacted,I@4}
        add3 (1|M0)              r46.1<1>:d    r17.0<0;0>:d      r6.2<0;0>:d       0:w               {I@2}
        send.ugm (1|M0)          r13      r45     null:0  0x0            0x0240D780           {A@2,$2} // wr:1+0, rd:4; load.ugm.d64x16t.a64
        send.ugm (1|M0)          r9       r46     null:0  0x0            0x0220C780           {A@1,$3} // wr:1+0, rd:2; load.ugm.d64x8t.a64
        add (1|M0)               r44.0<1>:ud   r1.2<0;1,0>:ud    0x2000:uw             
        shr (1|M0)               r43.4<1>:ud   r43.1<0;1,0>:ud   0x2:uw             
        and (1|M0)               r43.5<1>:d    r1.0<0;1,0>:uw    3:w              
        add (1|M0)               r43.3<1>:d    r111.4<0;1,0>:d   -r111.5<0;1,0>:d
        send.slm (1|M0)          null     r7      r13:4   0x0            0x0200D704           {$2} // wr:1+4, rd:0; store.slm.d64x16t.a32
        send.slm (1|M0)          null     r44     r9:2    0x0            0x0200C704           {A@4,$3} // wr:1+2, rd:0; store.slm.d64x8t.a32
(W)     send.slm (1|M0)          r11      r0      null:0  0x0            0x0210001F           {$4} // wr:1+0, rd:1; fence.slm.none.group
(W)     mov (1|M0)               r12.2<1>:f    0.0:f                               {Compacted}
(W)     mov (2|M0)               r12.10<1>:ub  r0.11<0;1,0>:ub                  {F@1}
(W)     mov (8|M0)               null<1>:ud    r11.0<1;1,0>:ud                  {$4.dst}
(W)     send.gtwy (1|M0)         null     r12     null:0  0x0            0x02000004           {A@2,$5} // wr:1+0, rd:0; signal barrier
(W)     sync.bar                             null                            
        cmp (1|M0)    (gt)f0.0   null<1>:d     r2.6<0;1,0>:d     31:w              
        shl (1|M0)               r43.7<1>:ud   r43.4<0;1,0>:ud   0x9:uw             
        shl (1|M0)               r44.1<1>:d    r43.5<0;1,0>:d    9:w               {$3.src}
        mov (16|M0)              r47.0<1>:d    0:w                              
(W)     and (1|M0)               f1.0<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
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
(~f1.0.any16h) goto (16|M0)                  L2776                  L2776                
L1464:
        asr (1|M0)               r1.3<1>:d     r2.2<0;1,0>:d     31:w              
        shr (1|M0)               r2.1<1>:ud    r2.2<0;1,0>:ud    0x1B:uw             
        mov (1|M0)               r44.6<1>:f    r43.6<0;1,0>:f                  
        shl (1|M0)               r2.0<1>:d     r1.3<0;1,0>:d     5:w               {Compacted,I@2}
        shl (1|M0)               r44.4<1>:d    r2.2<0;1,0>:d     5:w              
        mov (1|M0)               r45.2<2>:f    0.0:f                              
        mov (1|M0)               r45.3<2>:f    0.0:f                              
        mov (2|M0)               r44.2<1>:d    r44.6<1;1,0>:d                   {F@3}
        or (1|M0)                r44.5<1>:d    r2.0<0;1,0>:d     r2.1<0;1,0>:d    {I@3}
        asr (1|M0)               r44.3<1>:d    r43.6<0;1,0>:d    31:w              
        mov (1|M0)               r44.7<1>:d    0:w                              
L1632:
        addc (1|M0)              r2.0<1>:ud    r45.2<0;1,0>:ud   0x1:ud              {AccWrEn,F@2}
(W)     mov (1|M0)               r1.3<1>:hf    0x1:hf                             
        mov (1|M0)               r45.4<1>:d    r2.0<0;1,0>:d                    {I@1}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        cmp (1|M0)    (lt)f1.0   null<1>:ud    r45.4<0;1,0>:ud   r44.2<0;1,0>:ud  {I@2}
        add3 (1|M0)              r45.5<1>:d    r6.0<0;0>:d       r45.3<0;0>:d      0:w               {A@2}
        and (1|M0)               r45.6<1>:d    r45.2<0;1,0>:d    1:w              
        cmp (1|M0)    (lt)f0.0   null<1>:d     r45.5<0;1,0>:d    r44.3<0;1,0>:d   {I@2}
(f1.0)  cmp (1|M0)    (eq)f1.0   null<1>:d     r45.5<0;1,0>:d    r44.3<0;1,0>:d  
(f0.0)  sel (1|M0)               r3.14<1>:uw   r1.3<0;1,0>:uw    0x0:uw              {F@1}
(f1.0)  sel (1|M0)               r1.4<1>:uw    r1.3<0;1,0>:uw    0x0:uw             
        or (1|M0)     (ne)f1.1   null<1>:uw    r1.4<0;1,0>:uw    r3.14<0;1,0>:uw  {I@1}
(W)     and (1|M0)               f0.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(~f0.1.any16h) goto (16|M0)                  L2312                  L2312                
L1848:
        shl (1|M0)               r1.5<1>:d     r45.4<0;1,0>:d    12:w              
        shl (1|M0)               r1.3<1>:d     r45.5<0;1,0>:d    12:w              
        shr (1|M0)               r1.4<1>:ud    r45.4<0;1,0>:ud   0x14:uw             
        addc (1|M0)              r2.0<1>:ud    r45.0<0;1,0>:ud   r1.5<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r1.6<1>:d     r1.3<0;1,0>:d     r1.4<0;1,0>:d    {I@2}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        sync.allrd                           ($2,$6)                
        mov (1|M0)               r7.0<1>:f     r2.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r7.1<1>:d     r6.0<0;0>:d       r45.1<0;0>:d      r1.6<0>:d        {I@1}
        mul (1|M0)               acc0.0<1>:ud  r44.4<0;1,0>:ud   r45.8<0;1,0>:uw 
        sync.nop                             null                             {Compacted,$8.src}
        send.ugm (1|M0)          r8       r7      null:0  0x0            0x0240D780           {A@1,$9} // wr:1+0, rd:4; load.ugm.d64x16t.a64
        mach (1|M0)              r14.0<1>:ud   r44.4<0;1,0>:ud   r45.4<0;1,0>:ud  {AccWrEn}
        xor (1|M0)               r1.2<1>:d     r45.6<0;1,0>:d    1:w              
        mov (1|M0)               r13.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r44.4<0;1,0>:d    r45.10<0;1,0>:uw
        mach (1|M0)              r15.0<1>:d    r44.4<0;1,0>:d    r45.5<0;1,0>:d  
(W)     mul (1|M0)               acc0.0<1>:d   r44.5<0;1,0>:d    r45.8<0;1,0>:uw 
        mach (1|M0)              r2.0<1>:d     r44.5<0;1,0>:d    r45.4<0;1,0>:d  
        addc (1|M0)              r6.0<1>:ud    r46.0<0;1,0>:ud   r13.0<0;1,0>:ud  {AccWrEn,I@5}
        shl (1|M0)               r3.7<1>:d     r1.2<0;1,0>:d     12:w              
        add3 (1|M0)              r1.4<1>:d     r2.0<0;0>:d       r14.0<0;0>:d      r15.0<0>:d       {I@3}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$9.src}
        mov (1|M0)               r16.0<1>:f    r6.0<0;1,0>:f                    {Compacted,I@4}
        sync.nop                             null                             {Compacted,$5.src}
        mad (1|M0)               r12.0<1>:d    r3.7<0;0>:d       r1.0<0;0>:uw      128:w               {I@3}
        add3 (1|M0)              r16.1<1>:d    r7.0<0;0>:d       r46.1<0;0>:d      r1.4<0>:d        {I@2}
        shl (1|M0)               r1.2<1>:d     r1.2<0;1,0>:d     11:w              
        send.slm (1|M0)          null     r12     r8:4    0x0            0x0200D704           {A@3,$9} // wr:1+4, rd:0; store.slm.d64x16t.a32
        sync.nop                             null                             {Compacted,$9.src}
        send.ugm (1|M0)          r8       r16     null:0  0x0            0x0220C780           {A@1,$10} // wr:1+0, rd:2; load.ugm.d64x8t.a64
        add (1|M0)               r10.0<1>:d    r1.2<0;1,0>:d     r44.0<0;1,0>:d   {Compacted,I@1}
        sync.nop                             null                             {Compacted,$10.dst}
        send.slm (1|M0)          null     r10     r8:2    0x0            0x0200C704           {A@1,$8} // wr:1+2, rd:0; store.slm.d64x8t.a32
L2312:
        join (16|M0)                         L2776                                
L2328:
        shl (1|M0)               r1.2<1>:d     r45.6<0;1,0>:d    12:w              
        shl (1|M0)               r45.6<1>:d    r45.6<0;1,0>:d    11:w              
        add (1|M0)               r2.0<1>:d     r1.2<0;1,0>:d     r43.7<0;1,0>:d   {I@2}
        bfn.0xFE (1|M0)          r6.0<1>:ud    0x2000:uw               r45.6<0;0>:ud     r44.1<0>:ud      {I@2} // s0|s1|s2
        bfn.0xFE (1|M0)          r32.0<1>:ud   0x2100:uw               r45.6<0;0>:ud     r44.1<0>:ud      // s0|s1|s2
        sync.nop                             null                             {Compacted,$2.src}
        or (1|M0)                r15.0<1>:ud   r2.0<0;1,0>:ud    0x100:uw              {I@3}
        sync.allrd                           ($5,$6)                
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
        cmp (1|M0)    (eq)f0.1   null<1>:d     r45.5<0;1,0>:d    r44.7<0;1,0>:d  
(f0.1)  cmp (1|M0)    (eq)f0.1   null<1>:d     r45.4<0;1,0>:d    r44.6<0;1,0>:d  
(W)     and (1|M0)               f0.0<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(f0.0.any16h) goto (16|M0)                   L2776                  L2776                
L2744:
(W)     mov (2|M0)               r45.2<1>:ud   r45.4<1;1,0>:ud                 
        goto.b (16|M0)                       L2776                  L1632                
L2776:
        join (16|M0)                         L2792                                
L2792:
        shl (1|M0)               r43.3<1>:d    r43.3<0;1,0>:d    6:w               {Compacted}
        shl (1|M0)               r43.5<1>:d    r43.5<0;1,0>:d    4:w              
        shl (1|M0)               r43.2<1>:d    r43.2<0;1,0>:d    7:w              
        or (1|M0)                r1.2<1>:d     r43.3<0;1,0>:d    r43.5<0;1,0>:d   {I@2}
        shl (1|M0)               r43.4<1>:ud   r43.4<0;1,0>:ud   0x4:uw             
        shl (1|M0)               r46.2<1>:d    r1.2<0;1,0>:d     2:w               {I@2}
        shr (1|M0)               r1.4<1>:ud    r1.2<0;1,0>:ud    0x1E:uw             
        addc (1|M0)              r2.0<1>:ud    r3.2<0;1,0>:ud    r46.2<0;1,0>:ud  {AccWrEn,I@2}
        or (1|M0)                r46.3<1>:d    r1.4<0;1,0>:d     0:w               {I@2}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        sync.nop                             null                             {Compacted,$6.src}
        addc (1|M0)              r8.0<1>:ud    r3.4<0;1,0>:ud    r46.2<0;1,0>:ud  {AccWrEn,$8.src}
        shl (1|M0)               r46.4<1>:d    r1.2<0;1,0>:d     1:w              
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r10.0<1>:f    r8.0<0;1,0>:f                    {Compacted,I@3}
        mov (4|M0)               r8.0<1>:w     0x64206420:v                               {F@1}
        add3 (1|M0)              r10.1<1>:d    r9.0<0;0>:d       r3.5<0;0>:d       r46.3<0>:d       {I@2}
        mov (4|M0)               r9.0<4>:uw    r8.0<1;1,0>:uw                   {I@2}
        addc (1|M0)              r11.0<1>:ud   r4.4<0;1,0>:ud    r46.4<0;1,0>:ud  {AccWrEn}
        mov (4|M0)               r83.0<2>:d    r9.0<4;1,0>:w                    {I@2}
        send.ugm (1|M0)          r81      r10     null:0  0x0            0x0220C780           {$0} // wr:1+0, rd:2; load.ugm.d64x8t.a64
        asr (4|M0)               r83.1<2>:d    r83.0<2;1,0>:d    31:w               {I@1}
        mov (1|M0)               r7.0<1>:f     r2.0<0;1,0>:f                    {Compacted,$2.src}
        add3 (1|M0)              r7.1<1>:d     r6.0<0;0>:d       r3.3<0;0>:d       r46.3<0>:d      
        mov (1|M0)               r2.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,F@1}
        sync.nop                             null                             {Compacted,$0.src}
        mov (4|M0)               r10.0<2>:ud   r83.0<2;1,0>:ud                  {I@3}
        addc (1|M0)              r6.0<1>:ud    r4.4<0;1,0>:ud    r46.2<0;1,0>:ud  {AccWrEn}
        mov (4|M0)               r10.1<2>:ud   r83.1<2;1,0>:ud                 
        send.ugm (1|M0)          r79      r7      null:0  0x0            0x0220C780           {A@5,$1} // wr:1+0, rd:2; load.ugm.d64x8t.a64
        mov (1|M0)               r87.0<1>:f    r11.0<0;1,0>:f                   {Compacted}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$1.src}
        addc (4|M0)              r11.0<1>:ud   r10.0<2;1,0>:ud   0x8:ud              {AccWrEn,A@1}
        mov (1|M0)               r87.2<1>:d    r6.0<0;1,0>:d                   
        mov (4|M0)               r12.0<1>:ud   acc0.0<1;1,0>:ud                 {$5.src}
        addc (4|M0)              r6.0<1>:ud    r10.0<2;1,0>:ud   0x10:ud              {AccWrEn}
        shr (1|M0)               r3.7<1>:ud    r1.2<0;1,0>:ud    0x1F:uw             
        add3 (1|M0)              r87.3<1>:d    r7.0<0;0>:d       r4.5<0;0>:d       r46.3<0>:d       {I@6}
        mov (4|M0)               r7.0<1>:ud    acc0.0<1;1,0>:ud                
        addc (4|M0)              r8.0<1>:ud    r10.0<2;1,0>:ud   0x18:ud              {AccWrEn}
        or (1|M0)                r46.5<1>:d    r3.7<0;1,0>:d     0:w               {I@4}
        mov (4|M0)               r9.0<1>:ud    acc0.0<1;1,0>:ud                
        and (1|M0)               r45.7<1>:d    r4.6<0;1,0>:d     -2:w              
        and (1|M0)               r46.6<1>:d    r4.6<0;1,0>:d     -3:w              
        mov (1|M0)               r46.7<1>:d    0:w                              
        add (1|M0)               r43.2<1>:d    r43.2<0;1,0>:d    r43.4<0;1,0>:d  
        mov (4|M0)               r84.0<2>:d    r11.0<1;1,0>:d                  
        mov (4|M0)               r85.0<2>:d    r6.0<1;1,0>:d                   
        mov (4|M0)               r86.0<2>:d    r8.0<1;1,0>:d                    {I@7}
        add3 (1|M0)              r87.1<1>:d    r2.0<0;0>:d       r4.5<0;0>:d       r46.5<0>:d       {I@7}
        add3 (4|M0)              r84.1<2>:d    r12.0<1;0>:d      r10.1<4;2>:d      0:w              
        add3 (4|M0)              r85.1<2>:d    r7.0<1;0>:d       r10.1<4;2>:d      0:w              
        add3 (4|M0)              r86.1<2>:d    r9.0<1;0>:d       r10.1<4;2>:d      0:w               {I@7}
L3560:
        or (1|M0)                r87.4<1>:d    r46.7<0;1,0>:d    r43.2<0;1,0>:d   {I@7}
        cmp (1|M0)    (eq)f1.1   null<1>:w     r43.0<0;1,0>:b    0:w              
        cmp (1|M0)    (lt)f1.0   null<1>:d     r87.4<0;1,0>:d    r3.6<0;1,0>:d    {I@2}
        cmp (1|M0)    (eq)f0.1   null<1>:w     r43.2<0;1,0>:b    0:w              
        cmp (1|M0)    (eq)f0.0   null<1>:d     r4.6<0;1,0>:d     4:w              
(W)     mov (1|M0)               r111.13<1>:uw  f1.1<0;1,0>:uw                 
(W)     and (1|M0)               f1.1<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
        or (1|M0)                r87.5<1>:d    r87.4<0;1,0>:d    8:w              
(W)     mov (1|M0)               r111.14<1>:uw  f0.1<0;1,0>:uw                  {Compacted}
(W)     mov (1|M0)               r111.12<1>:uw  f0.0<0;1,0>:uw                  {Compacted}
        cmp (1|M0)    (eq)f0.1   null<1>:d     r46.6<0;1,0>:d    1:w              
        cmp (1|M0)    (eq)f0.0   null<1>:d     r45.7<0;1,0>:d    2:w              
(~f1.1.any16h) goto (16|M0)                  L7336                  L7336                
L3752:
        asr (1|M0)               r1.3<1>:d     r87.4<0;1,0>:d    31:w              
        shl (1|M0)               r5.2<1>:d     r87.4<0;1,0>:d    2:w              
        shr (1|M0)               r2.1<1>:ud    r87.4<0;1,0>:ud   0x1E:uw             
        shl (1|M0)               r2.0<1>:d     r1.3<0;1,0>:d     2:w               {Compacted,I@3}
        addc (1|M0)              r6.0<1>:ud    r4.0<0;1,0>:ud    r5.2<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r5.3<1>:d     r2.0<0;1,0>:d     r2.1<0;1,0>:d    {I@2}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r8.0<1>:f     r6.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r8.1<1>:d     r7.0<0;0>:d       r4.1<0;0>:d       r5.3<0>:d        {I@1}
        shl (1|M0)               r3.14<1>:w    r46.14<0;1,0>:w   5:w              
        send.ugm (1|M0)          r9       r8      null:0  0x0            0x04100580           {A@1,$8} // wr:2+0, rd:1; load.ugm.d32.a64
        add (1|M0)               a0.0<1>:uw    r3.14<0;1,0>:uw   0x8E0:uw              {A@1}
        mul (1|M0)               acc0.0<1>:d   r87.4<0;1,0>:d    r2.4<0;1,0>:uw  
(W)     and (1|M0)               f1.0<1>:uw    r111.13<0;1,0>:uw  0x1:uw            
        mach (1|M0)              r7.0<1>:d     r87.4<0;1,0>:d    r2.2<0;1,0>:d    {AccWrEn}
        mov (8|M0)               r10.0<1>:ud   r[a0.0]<1;1,0>:ud                {$6.dst}
        add (1|M0)               a0.0<1>:uw    r3.14<0;1,0>:uw   0x7E0:uw              {A@1}
        mov (8|M0)               r92.0<1>:f    r10.0<1;1,0>:d                   {Compacted,I@2}
        mov (1|M0)               r6.0<1>:d     acc0.0<0;1,0>:d                 
        mov (1|M0)               r87.7<1>:d    r7.0<0;1,0>:d                   
        mov (8|M0)               r11.0<1>:ud   r[a0.0]<1;1,0>:ud               
        mov (1|M0)               r87.6<1>:d    r6.0<0;1,0>:d                    {A@1}
        mov (8|M0)               r93.0<1>:f    r11.0<1;1,0>:d                   {Compacted,I@2}
        sync.nop                             null                             {Compacted,$8.dst}
        mul (8|M0)               r92.0<1>:f    r9.0<0;1,0>:f     r92.0<1;1,0>:f   {Compacted,F@2}
        mul (8|M0)               r93.0<1>:f    r9.0<0;1,0>:f     r93.0<1;1,0>:f   {Compacted,F@2}
        sync.nop                             null                             {Compacted,$1.dst}
        mul (8|M0)               r92.0<1>:f    r79.0<1;1,0>:f    r92.0<1;1,0>:f   {Compacted,F@2}
        mul (8|M0)               r93.0<1>:f    r80.0<1;1,0>:f    r93.0<1;1,0>:f   {Compacted,F@2}
(f1.0.any16h) goto (16|M0)                   L4320                  L4320                
L4144:
        shl (1|M0)               r1.4<1>:d     r87.6<0;1,0>:d    1:w               {I@2}
        shl (1|M0)               r1.2<1>:d     r87.7<0;1,0>:d    1:w              
        shr (1|M0)               r1.3<1>:ud    r87.6<0;1,0>:ud   0x1F:uw             
        addc (1|M0)              r2.0<1>:ud    r87.0<0;1,0>:ud   r1.4<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r7.0<1>:f     r2.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r7.1<1>:d     r6.0<0;0>:d       r87.1<0;0>:d      r1.5<0>:d        {I@1}
        send.ugm (1|M0)          r8       r7      null:0  0x0            0x0210B780           {A@1,$9} // wr:1+0, rd:1; load.ugm.d64x4t.a64
        mov (8|M0)               r95.0<1>:f    r8.0<1;1,0>:hf                   {$9.dst}
        mov (8|M0)               r94.0<1>:f    r8.8<1;1,0>:hf                  
        goto (16|M0)                         L4320                  L4480                
L4320:
        join (16|M0)                         L4480                                
L4336:
        shl (1|M0)               r1.4<1>:d     r87.6<0;1,0>:d    2:w              
        shl (1|M0)               r1.2<1>:d     r87.7<0;1,0>:d    2:w              
        shr (1|M0)               r1.3<1>:ud    r87.6<0;1,0>:ud   0x1E:uw             
        addc (1|M0)              r2.0<1>:ud    r87.2<0;1,0>:ud   r1.4<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r7.0<1>:f     r2.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r7.1<1>:d     r6.0<0;0>:d       r87.3<0;0>:d      r1.5<0>:d        {I@1}
        send.ugm (1|M0)          r8       r7      null:0  0x0            0x0220C780           {A@1,$10} // wr:1+0, rd:2; load.ugm.d64x8t.a64
        mov (8|M0)               r95.0<1>:f    r8.0<1;1,0>:f                    {Compacted,$10.dst}
        mov (8|M0)               r94.0<1>:f    r9.0<1;1,0>:f                    {Compacted}
L4480:
        join (16|M0)                         L7336                                
L4496:
        mov (1|M0)               r96.0<1>:d    0:w                              
L4512:
        shl (1|M0)               r96.2<1>:w    r96.0<0;1,0>:w    2:w               {I@1}
(W)     and (1|M0)               f1.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
        add (1|M0)               a0.1<1>:uw    r96.2<0;1,0>:uw   0xBE0:uw              {A@1}
        add (1|M0)               a0.0<1>:uw    r96.2<0;1,0>:uw   0xA20:uw              {A@1}
        sync.nop                             null                             {Compacted,$0.dst}
        mul (1|M0)               r96.2<1>:f    r[a0.1]<0;1,0>:f  r[a0.0]<0;1,0>:f {F@2}
        add (1|M0)               a0.0<1>:uw    r96.2<0;1,0>:uw   0xB80:uw              {A@1}
        add (1|M0)               r96.2<1>:f    r96.2<0;1,0>:f    r[a0.0]<0;1,0>:f {F@1}
(~f1.1.any16h) goto (16|M0)                  L4888                  L4888                 {A@1}
L4648:
        mov (1|M0)               r1.4<2>:hf    r96.2<0;1,0>:f                   {F@1}
        cmp (1|M0)    (lt)f1.0   null<1>:f     r96.2<0;1,0>:f    -4.001953e+00:f              
        mov (1|M0)               r1.3<1>:f     r1.4<0;1,0>:hf                   {F@2}
        mov (1|M0)               r2.1<1>:ud    0xBD650000:ud                             
        sel (1|M0)    (lt)f0.0   r1.3<1>:f     r1.3<0;1,0>:f     4.0:f               {F@1}
        mov (1|M0)               r2.3<1>:ud    0x3EE50000:ud                             
(~f1.0) sel (1|M0)               r2.0<1>:f     r1.3<0;1,0>:f     -4.0:f               {F@1}
        mov (1|M0)               r5.2<1>:ud    0x3F650000:ud                             
        mad (1|M0)               r2.1<1>:f     r2.3<0;0>:f       r2.1<0;0>:f       (abs)r2.0<0>:f   {A@1}
        mov (1|M0)               r3.14<2>:hf   r2.1<0;1,0>:f                    {F@1}
        mov (1|M0)               r4.3<1>:f     r3.14<0;1,0>:hf                  {F@1}
        mad (1|M0)               r2.0<1>:f     r5.2<0;0>:f       r4.3<0;0>:f       r2.0<0>:f        {A@1}
        mov (1|M0)               r6.0<2>:hf    r2.0<0;1,0>:f                    {F@1}
        mul (1|M0)               r1.4<1>:hf    r1.4<0;1,0>:hf    r6.0<0;1,0>:hf   {F@1}
        mov (1|M0)               r96.2<1>:f    r1.4<0;1,0>:hf                   {F@1}
L4888:
        join (16|M0)                         L5552                                
L4904:
(W)     and (1|M0)               f1.0<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(f1.0.any16h) goto (16|M0)                   L5016                  L5016                
L4936:
(W)     mov (1|M0)               f1.0<1>:uw    r111.12<0;1,0>:uw               
        mov (1|M0)               r1.4<2>:hf    r96.2<0;1,0>:f                   {F@1}
        mov (1|M0)               r96.5<1>:f    r1.4<0;1,0>:hf                   {F@1}
(~f1.0) mov (1|M0)               r96.5<1>:f    r96.2<0;1,0>:f                  
        goto (16|M0)                         L5016                  L5448                
L5016:
        join (16|M0)                         L5448                                
L5032:
        cmp (1|M0)    (lt)f1.0   null<1>:f     r96.2<0;1,0>:f    0.0:f               {I@3}
(f1.0)  mov (1|M0)               r96.2<1>:f    -r96.2<0;1,0>:f                 
        sel (1|M0)    (lt)f0.0   r96.2<1>:f    r96.2<0;1,0>:f    448.0:f               {F@1}
        shr (1|M0)               r96.4<1>:ud   r96.2<0;1,0>:ud   0x17:uw              {F@1}
        and (1|M0)               r96.4<1>:ud   r96.4<0;1,0>:ud   0xFF:uw              {I@1}
        sel (1|M0)    (ge)f0.0   r96.4<1>:ud   r96.4<0;1,0>:ud   0x79:uw              {I@1}
        shl (1|M0)               r96.4<1>:ud   r96.4<0;1,0>:ud   0x17:uw              {I@1}
        add (1|M0)               r1.2<1>:ud    -r96.4<0;1,0>:ud  0x80800000:ud              {I@1}
        mul (1|M0)               r1.3<1>:f     r96.2<0;1,0>:f    r1.2<0;1,0>:f    {I@1}
        mov (1|M0)               r96.3<1>:d    r1.3<0;1,0>:f                    {Compacted,F@1}
        mov (1|M0)               r96.5<1>:f    r96.3<0;1,0>:d                   {I@1}
        mad (1|M0)               r96.2<1>:f    -r96.5<0;0>:f     r1.2<0;0>:f       r96.2<0>:f       {F@1}
        cmp (1|M0)    (gt)f1.1   null<1>:f     r96.2<0;1,0>:f    0.5:f               {F@1}
(W)     and (1|M0)               f1.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw              {F@1}
(f1.1.any16h) goto (16|M0)                   L5352                  L5352                
L5264:
        cmp (1|M0)    (lt)f1.1   null<1>:f     r96.2<0;1,0>:f    0.5:f               {A@1}
        and (1|M0)               r96.3<1>:d    r96.3<0;1,0>:d    1:w               {Compacted}
        add (1|M0)               r1.2<1>:f     r96.5<0;1,0>:f    1.0:f              
(~f1.1) cmp (1|M0)    (eq)f1.1   null<1>:d     r96.3<0;1,0>:d    0:w               {A@1}
(~f1.1) mov (1|M0)               r96.5<1>:f    r1.2<0;1,0>:f                    {F@1}
        goto (16|M0)                         L5352                  L5384                
L5352:
        join (16|M0)                         L5384                                
L5368:
        add (1|M0)               r96.5<1>:f    r96.5<0;1,0>:f    1.0:f               {F@1}
L5384:
        join (16|M0)                         L5448                                
L5400:
        add (1|M0)               r96.4<1>:ud   r96.4<0;1,0>:ud   0xFE800000:ud             
        mul (1|M0)               r96.5<1>:f    r96.5<0;1,0>:f    r96.4<0;1,0>:f   {A@1}
(f1.0)  mov (1|M0)               r96.5<1>:f    -r96.5<0;1,0>:f                  {F@1}
L5448:
        join (16|M0)                         L5552                                
L5464:
        add (1|M0)               r96.0<1>:d    r96.0<0;1,0>:d    1:w               {Compacted}
        add (1|M0)               a0.0<1>:uw    r96.2<0;1,0>:uw   0xB00:uw              {A@1}
        cmp (1|M0)    (eq)f1.0   null<1>:d     r96.0<0;1,0>:d    8:w               {A@1}
        mov (1|M0)               r[a0.0]<1>:f  r96.5<0;1,0>:f                   {$3.src}
(W)     and (1|M0)               f1.1<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
(~f1.1.any16h) goto.b (16|M0)                L5552                  L4512                
L5552:
        join (16|M0)                         L7336                                
L5568:
        mov (1|M0)               r96.6<1>:d    0:w                              
L5584:
        shl (1|M0)               r96.3<1>:w    r96.12<0;1,0>:w   2:w               {I@1}
(W)     and (1|M0)               f1.0<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
        add (1|M0)               a0.1<1>:uw    r96.3<0;1,0>:uw   0xBC0:uw              {A@1}
        add (1|M0)               a0.0<1>:uw    r96.3<0;1,0>:uw   0xA20:uw              {A@1}
        mul (1|M0)               r96.7<1>:f    r[a0.1]<0;1,0>:f  r[a0.0,32]<0;1,0>:f
        add (1|M0)               a0.0<1>:uw    r96.3<0;1,0>:uw   0xBA0:uw              {A@1}
        add (1|M0)               r96.7<1>:f    r96.7<0;1,0>:f    r[a0.0]<0;1,0>:f {F@1}
(~f1.0.any16h) goto (16|M0)                  L5952                  L5952                 {A@1}
L5712:
        mov (1|M0)               r1.4<2>:hf    r96.7<0;1,0>:f                   {F@1}
        cmp (1|M0)    (lt)f1.1   null<1>:f     r96.7<0;1,0>:f    -4.001953e+00:f              
        mov (1|M0)               r1.3<1>:f     r1.4<0;1,0>:hf                   {F@2}
        mov (1|M0)               r2.1<1>:ud    0xBD650000:ud                             
        sel (1|M0)    (lt)f0.0   r1.3<1>:f     r1.3<0;1,0>:f     4.0:f               {F@1}
        mov (1|M0)               r2.3<1>:ud    0x3EE50000:ud                             
(~f1.1) sel (1|M0)               r2.0<1>:f     r1.3<0;1,0>:f     -4.0:f               {F@1}
        mov (1|M0)               r5.2<1>:ud    0x3F650000:ud                             
        mad (1|M0)               r2.1<1>:f     r2.3<0;0>:f       r2.1<0;0>:f       (abs)r2.0<0>:f   {A@1}
        mov (1|M0)               r3.14<2>:hf   r2.1<0;1,0>:f                    {F@1}
        mov (1|M0)               r4.3<1>:f     r3.14<0;1,0>:hf                  {F@1}
        mad (1|M0)               r2.0<1>:f     r5.2<0;0>:f       r4.3<0;0>:f       r2.0<0>:f        {A@1}
        mov (1|M0)               r6.0<2>:hf    r2.0<0;1,0>:f                    {F@1}
        mul (1|M0)               r1.4<1>:hf    r1.4<0;1,0>:hf    r6.0<0;1,0>:hf   {F@1}
        mov (1|M0)               r96.7<1>:f    r1.4<0;1,0>:hf                   {F@1}
L5952:
        join (16|M0)                         L6640                                
L5968:
(W)     and (1|M0)               f1.1<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(f1.1.any16h) goto (16|M0)                   L6080                  L6080                
L6000:
(W)     mov (1|M0)               f1.1<1>:uw    r111.12<0;1,0>:uw               
        mov (1|M0)               r1.4<2>:hf    r96.7<0;1,0>:f                   {F@1}
        mov (1|M0)               r97.2<1>:f    r1.4<0;1,0>:hf                   {F@1}
(~f1.1) mov (1|M0)               r97.2<1>:f    r96.7<0;1,0>:f                  
        goto (16|M0)                         L6080                  L6504                
L6080:
        join (16|M0)                         L6504                                
L6096:
        cmp (1|M0)    (lt)f1.1   null<1>:f     r96.7<0;1,0>:f    0.0:f               {I@3}
(f1.1)  mov (1|M0)               r96.7<1>:f    -r96.7<0;1,0>:f                 
        sel (1|M0)    (lt)f0.0   r96.7<1>:f    r96.7<0;1,0>:f    448.0:f               {F@1}
        shr (1|M0)               r97.1<1>:ud   r96.7<0;1,0>:ud   0x17:uw              {F@1}
        and (1|M0)               r97.1<1>:ud   r97.1<0;1,0>:ud   0xFF:uw              {I@1}
        sel (1|M0)    (ge)f0.0   r97.1<1>:ud   r97.1<0;1,0>:ud   0x79:uw              {I@1}
        shl (1|M0)               r97.1<1>:ud   r97.1<0;1,0>:ud   0x17:uw              {I@1}
        add (1|M0)               r1.2<1>:ud    -r97.1<0;1,0>:ud  0x80800000:ud              {I@1}
        mul (1|M0)               r1.3<1>:f     r96.7<0;1,0>:f    r1.2<0;1,0>:f    {I@1}
        mov (1|M0)               r97.0<1>:d    r1.3<0;1,0>:f                    {Compacted,F@1}
        mov (1|M0)               r97.2<1>:f    r97.0<0;1,0>:d                   {Compacted,I@1}
        mad (1|M0)               r96.7<1>:f    -r97.2<0;0>:f     r1.2<0;0>:f       r96.7<0>:f       {F@1}
        cmp (1|M0)    (gt)f1.0   null<1>:f     r96.7<0;1,0>:f    0.5:f               {F@1}
(W)     and (1|M0)               f1.0<1>:uw    f1.0<0;1,0>:uw    0x1:uw              {F@1}
(f1.0.any16h) goto (16|M0)                   L6408                  L6408                
L6320:
        cmp (1|M0)    (lt)f1.0   null<1>:f     r96.7<0;1,0>:f    0.5:f               {A@1}
        and (1|M0)               r97.0<1>:d    r97.0<0;1,0>:d    1:w               {Compacted}
        add (1|M0)               r1.2<1>:f     r97.2<0;1,0>:f    1.0:f              
(~f1.0) cmp (1|M0)    (eq)f1.0   null<1>:d     r97.0<0;1,0>:d    0:w               {A@1}
(~f1.0) mov (1|M0)               r97.2<1>:f    r1.2<0;1,0>:f                    {F@1}
        goto (16|M0)                         L6408                  L6440                
L6408:
        join (16|M0)                         L6440                                
L6424:
        add (1|M0)               r97.2<1>:f    r97.2<0;1,0>:f    1.0:f               {F@1}
L6440:
        join (16|M0)                         L6504                                
L6456:
        add (1|M0)               r97.1<1>:ud   r97.1<0;1,0>:ud   0xFE800000:ud             
        mul (1|M0)               r97.2<1>:f    r97.2<0;1,0>:f    r97.1<0;1,0>:f   {A@1}
(f1.1)  mov (1|M0)               r97.2<1>:f    -r97.2<0;1,0>:f                  {F@1}
L6504:
        join (16|M0)                         L6640                                
L6520:
        add (1|M0)               r96.6<1>:d    r96.6<0;1,0>:d    1:w              
        or (1|M0)                r1.3<1>:uw    r96.3<0;1,0>:uw   0x20:uw             
        cmp (1|M0)    (eq)f1.0   null<1>:d     r96.6<0;1,0>:d    8:w               {I@2}
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0xB00:uw              {A@1}
        sync.nop                             null                             {Compacted,$3.src}
        mov (1|M0)               r[a0.0]<1>:f  r97.2<0;1,0>:f                   {F@1}
(W)     and (1|M0)               f1.1<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
(~f1.1.any16h) goto.b (16|M0)                L6640                  L5584                
L6640:
        join (16|M0)                         L7336                                
L6656:
(W)     and (1|M0)               f1.0<1>:uw    r111.14<0;1,0>:uw  0x1:uw            
(f1.0.any16h) goto (16|M0)                   L7136                  L7136                
L6688:
        addc (1|M0)              r2.0<1>:ud    r5.0<0;1,0>:ud    r46.4<0;1,0>:ud  {AccWrEn}
        shl (1|M0)               r1.6<1>:d     r87.6<0;1,0>:d    1:w              
        shl (1|M0)               r1.4<1>:d     r87.7<0;1,0>:d    1:w              
        shr (1|M0)               r1.5<1>:ud    r87.6<0;1,0>:ud   0x1F:uw             
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r8.0<1>:ud    r2.0<0;1,0>:ud    r1.6<0;1,0>:ud   {AccWrEn,I@4}
        or (1|M0)                r1.7<1>:d     r1.4<0;1,0>:d     r1.5<0;1,0>:d    {I@3}
        add3 (1|M0)              r1.3<1>:d     r7.0<0;0>:d       r5.1<0;0>:d       r46.5<0>:d       {I@3}
        sync.nop                             null                             {Compacted,$5.src}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$3.src}
        mov (1|M0)               r5.2<1>:d     r8.0<0;1,0>:d                    {I@4}
        add3 (1|M0)              r5.3<1>:d     r9.0<0;0>:d       r1.3<0;0>:d       r1.7<0>:d        {I@2}
        mov (8|M0)               r10.0<2>:ud   r5.2<0;1,0>:ud                   {I@2}
        mov (8|M0)               r10.1<2>:ud   r5.3<0;1,0>:ud                   {I@2}
        mov (8|M0)               r17.0<1>:d    r83.1<2;1,0>:d                  
        addc (8|M0)              r12.0<1>:ud   r10.0<2;1,0>:ud   r83.0<2;1,0>:ud  {AccWrEn,Compacted,I@2}
        mov (8|M0)               r9.0<1>:d     r85.1<2;1,0>:d                  
        mov (8|M0)               r7.0<1>:ud    acc0.0<1;1,0>:ud                 {Compacted}
        addc (8|M0)              r19.0<1>:ud   r10.0<2;1,0>:ud   r85.0<2;1,0>:ud  {AccWrEn,Compacted}
        mov (8|M0)               r6.0<1>:hf    r88.0<1;1,0>:f                   {F@1}
        mov (8|M0)               r8.0<1>:ud    acc0.0<1;1,0>:ud                 {Compacted}
        mov (8|M0)               r6.8<1>:hf    r89.0<1;1,0>:f                  
        add3 (8|M0)              r18.0<1>:d    r7.0<1;0>:d       r10.1<4;2>:d      r17.0<1>:d       {I@3}
        add3 (8|M0)              r20.0<1>:d    r8.0<1;0>:d       r10.1<4;2>:d      r9.0<1>:d        {I@2}
        sync.nop                             null                             {Compacted,$4.src}
        mov (8|M0)               r13.0<2>:d    r12.0<1;1,0>:d                   {$2.src}
        mov (8|M0)               r15.0<2>:d    r19.0<1;1,0>:d                  
        mov (16|M0)              r21.0<1>:d    r6.0<1;1,0>:uw                   {A@1}
        mov (8|M0)               r13.1<2>:d    r18.0<1;1,0>:d                   {I@5}
        mov (8|M0)               r15.1<2>:d    r20.0<1;1,0>:d                   {I@5}
        send.ugm (16|M0)         null     r13     r21:2   0x0            0x08000B84           {A@1,$2} // wr:4+2, rd:0; store.ugm.d16u32.a64
        goto (16|M0)                         L7136                  L7336                
L7136:
        join (16|M0)                         L7336                                
L7152:
        addc (1|M0)              r2.0<1>:ud    r5.0<0;1,0>:ud    r46.2<0;1,0>:ud  {AccWrEn}
        shl (1|M0)               r1.6<1>:d     r87.6<0;1,0>:d    2:w              
        shl (1|M0)               r1.4<1>:d     r87.7<0;1,0>:d    2:w              
        shr (1|M0)               r1.5<1>:ud    r87.6<0;1,0>:ud   0x1E:uw             
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r7.0<1>:ud    r2.0<0;1,0>:ud    r1.6<0;1,0>:ud   {AccWrEn,I@4}
        or (1|M0)                r1.7<1>:d     r1.4<0;1,0>:d     r1.5<0;1,0>:d    {I@3}
        add3 (1|M0)              r1.3<1>:d     r6.0<0;0>:d       r5.1<0;0>:d       r46.3<0>:d       {I@3}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        sync.allrd                           ($3,$5)                
        mov (1|M0)               r9.0<1>:f     r7.0<0;1,0>:f                    {Compacted,I@4}
        add3 (1|M0)              r9.1<1>:d     r8.0<0;0>:d       r1.3<0;0>:d       r1.7<0>:d        {I@1}
        send.ugm (1|M0)          null     r9      r88:2   0x0            0x0200D584           {A@1,$3} // wr:1+2, rd:0; store.ugm.d32x16t.a64
L7336:
        join (16|M0)                         L11080                                
L7352:
        cmp (1|M0)    (lt)f1.1   null<1>:d     r87.5<0;1,0>:d    r3.6<0;1,0>:d   
(W)     and (1|M0)               f1.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(~f1.1.any16h) goto (16|M0)                  L11000                  L11000                
L7400:
        asr (1|M0)               r1.3<1>:d     r87.5<0;1,0>:d    31:w              
        shl (1|M0)               r5.2<1>:d     r87.5<0;1,0>:d    2:w              
        shr (1|M0)               r2.1<1>:ud    r87.5<0;1,0>:ud   0x1E:uw             
        shl (1|M0)               r2.0<1>:d     r1.3<0;1,0>:d     2:w               {Compacted,I@3}
        addc (1|M0)              r6.0<1>:ud    r4.0<0;1,0>:ud    r5.2<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r5.3<1>:d     r2.0<0;1,0>:d     r2.1<0;1,0>:d    {I@2}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r8.0<1>:f     r6.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r8.1<1>:d     r7.0<0;0>:d       r4.1<0;0>:d       r5.3<0>:d        {I@1}
        shl (1|M0)               r3.14<1>:w    r46.14<0;1,0>:w   5:w              
        send.ugm (1|M0)          r9       r8      null:0  0x0            0x04100580           {A@1,$11} // wr:2+0, rd:1; load.ugm.d32.a64
        add (1|M0)               a0.0<1>:uw    r3.14<0;1,0>:uw   0x6E0:uw              {A@1}
        mul (1|M0)               acc0.0<1>:d   r87.5<0;1,0>:d    r2.4<0;1,0>:uw  
(W)     and (1|M0)               f1.0<1>:uw    r111.13<0;1,0>:uw  0x1:uw            
        mach (1|M0)              r7.0<1>:d     r87.5<0;1,0>:d    r2.2<0;1,0>:d    {AccWrEn}
        mov (8|M0)               r10.0<1>:ud   r[a0.0]<1;1,0>:ud                {$6.dst}
        add (1|M0)               a0.0<1>:uw    r3.14<0;1,0>:uw   0x5E0:uw              {A@1}
        mov (8|M0)               r102.0<1>:f   r10.0<1;1,0>:d                   {Compacted,I@2}
        mov (1|M0)               r6.0<1>:d     acc0.0<0;1,0>:d                 
        mov (1|M0)               r97.4<1>:d    r7.0<0;1,0>:d                   
        mov (8|M0)               r11.0<1>:ud   r[a0.0]<1;1,0>:ud               
        mov (1|M0)               r97.3<1>:d    r6.0<0;1,0>:d                    {A@1}
        mov (8|M0)               r103.0<1>:f   r11.0<1;1,0>:d                   {Compacted,I@2}
        sync.nop                             null                             {Compacted,$11.dst}
        mul (8|M0)               r102.0<1>:f   r9.0<0;1,0>:f     r102.0<1;1,0>:f  {Compacted,F@2}
        mul (8|M0)               r103.0<1>:f   r9.0<0;1,0>:f     r103.0<1;1,0>:f  {Compacted,F@2}
        sync.nop                             null                             {Compacted,$1.dst}
        mul (8|M0)               r102.0<1>:f   r79.0<1;1,0>:f    r102.0<1;1,0>:f  {Compacted,F@2}
        mul (8|M0)               r103.0<1>:f   r80.0<1;1,0>:f    r103.0<1;1,0>:f  {Compacted,F@2}
(f1.0.any16h) goto (16|M0)                   L7968                  L7968                
L7792:
        shl (1|M0)               r1.4<1>:d     r97.3<0;1,0>:d    1:w               {I@2}
        shl (1|M0)               r1.2<1>:d     r97.4<0;1,0>:d    1:w              
        shr (1|M0)               r1.3<1>:ud    r97.3<0;1,0>:ud   0x1F:uw             
        addc (1|M0)              r2.0<1>:ud    r87.0<0;1,0>:ud   r1.4<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r7.0<1>:f     r2.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r7.1<1>:d     r6.0<0;0>:d       r87.1<0;0>:d      r1.5<0>:d        {I@1}
        send.ugm (1|M0)          r8       r7      null:0  0x0            0x0210B780           {A@1,$12} // wr:1+0, rd:1; load.ugm.d64x4t.a64
        mov (8|M0)               r105.0<1>:f   r8.0<1;1,0>:hf                   {$12.dst}
        mov (8|M0)               r104.0<1>:f   r8.8<1;1,0>:hf                  
        goto (16|M0)                         L7968                  L8128                
L7968:
        join (16|M0)                         L8128                                
L7984:
        shl (1|M0)               r1.4<1>:d     r97.3<0;1,0>:d    2:w              
        shl (1|M0)               r1.2<1>:d     r97.4<0;1,0>:d    2:w              
        shr (1|M0)               r1.3<1>:ud    r97.3<0;1,0>:ud   0x1E:uw             
        addc (1|M0)              r2.0<1>:ud    r87.2<0;1,0>:ud   r1.4<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r7.0<1>:f     r2.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r7.1<1>:d     r6.0<0;0>:d       r87.3<0;0>:d      r1.5<0>:d        {I@1}
        send.ugm (1|M0)          r8       r7      null:0  0x0            0x0220C780           {A@1,$13} // wr:1+0, rd:2; load.ugm.d64x8t.a64
        mov (8|M0)               r105.0<1>:f   r8.0<1;1,0>:f                    {Compacted,$13.dst}
        mov (8|M0)               r104.0<1>:f   r9.0<1;1,0>:f                    {Compacted}
L8128:
        join (16|M0)                         L11000                                
L8144:
        mov (1|M0)               r97.5<1>:d    0:w                              
L8160:
        shl (1|M0)               r97.12<1>:w   r97.10<0;1,0>:w   2:w               {I@1}
(W)     and (1|M0)               f1.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
        add (1|M0)               a0.1<1>:uw    r97.12<0;1,0>:uw  0xD20:uw              {A@1}
        add (1|M0)               a0.0<1>:uw    r97.12<0;1,0>:uw  0xA20:uw              {A@1}
        sync.nop                             null                             {Compacted,$0.dst}
        mul (1|M0)               r97.7<1>:f    r[a0.1]<0;1,0>:f  r[a0.0]<0;1,0>:f {F@2}
        add (1|M0)               a0.0<1>:uw    r97.12<0;1,0>:uw  0xCC0:uw              {A@1}
        add (1|M0)               r97.7<1>:f    r97.7<0;1,0>:f    r[a0.0]<0;1,0>:f {F@1}
(~f1.1.any16h) goto (16|M0)                  L8536                  L8536                 {A@1}
L8296:
        mov (1|M0)               r1.4<2>:hf    r97.7<0;1,0>:f                   {F@1}
        cmp (1|M0)    (lt)f1.0   null<1>:f     r97.7<0;1,0>:f    -4.001953e+00:f              
        mov (1|M0)               r1.3<1>:f     r1.4<0;1,0>:hf                   {F@2}
        mov (1|M0)               r2.1<1>:ud    0xBD650000:ud                             
        sel (1|M0)    (lt)f0.0   r1.3<1>:f     r1.3<0;1,0>:f     4.0:f               {F@1}
        mov (1|M0)               r2.3<1>:ud    0x3EE50000:ud                             
(~f1.0) sel (1|M0)               r2.0<1>:f     r1.3<0;1,0>:f     -4.0:f               {F@1}
        mov (1|M0)               r5.2<1>:ud    0x3F650000:ud                             
        mad (1|M0)               r2.1<1>:f     r2.3<0;0>:f       r2.1<0;0>:f       (abs)r2.0<0>:f   {A@1}
        mov (1|M0)               r3.14<2>:hf   r2.1<0;1,0>:f                    {F@1}
        mov (1|M0)               r4.3<1>:f     r3.14<0;1,0>:hf                  {F@1}
        mad (1|M0)               r2.0<1>:f     r5.2<0;0>:f       r4.3<0;0>:f       r2.0<0>:f        {A@1}
        mov (1|M0)               r6.0<2>:hf    r2.0<0;1,0>:f                    {F@1}
        mul (1|M0)               r1.4<1>:hf    r1.4<0;1,0>:hf    r6.0<0;1,0>:hf   {F@1}
        mov (1|M0)               r97.7<1>:f    r1.4<0;1,0>:hf                   {F@1}
L8536:
        join (16|M0)                         L9200                                
L8552:
(W)     and (1|M0)               f1.0<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(f1.0.any16h) goto (16|M0)                   L8664                  L8664                
L8584:
(W)     mov (1|M0)               f1.0<1>:uw    r111.12<0;1,0>:uw               
        mov (1|M0)               r1.4<2>:hf    r97.7<0;1,0>:f                   {F@1}
        mov (1|M0)               r106.2<1>:f   r1.4<0;1,0>:hf                   {F@1}
(~f1.0) mov (1|M0)               r106.2<1>:f   r97.7<0;1,0>:f                  
        goto (16|M0)                         L8664                  L9088                
L8664:
        join (16|M0)                         L9088                                
L8680:
        cmp (1|M0)    (lt)f1.0   null<1>:f     r97.7<0;1,0>:f    0.0:f               {I@3}
(f1.0)  mov (1|M0)               r97.7<1>:f    -r97.7<0;1,0>:f                 
        sel (1|M0)    (lt)f0.0   r97.7<1>:f    r97.7<0;1,0>:f    448.0:f               {F@1}
        shr (1|M0)               r106.1<1>:ud  r97.7<0;1,0>:ud   0x17:uw              {F@1}
        and (1|M0)               r106.1<1>:ud  r106.1<0;1,0>:ud  0xFF:uw              {I@1}
        sel (1|M0)    (ge)f0.0   r106.1<1>:ud  r106.1<0;1,0>:ud  0x79:uw              {I@1}
        shl (1|M0)               r106.1<1>:ud  r106.1<0;1,0>:ud  0x17:uw              {I@1}
        add (1|M0)               r1.2<1>:ud    -r106.1<0;1,0>:ud  0x80800000:ud             {I@1}
        mul (1|M0)               r1.3<1>:f     r97.7<0;1,0>:f    r1.2<0;1,0>:f    {I@1}
        mov (1|M0)               r106.0<1>:d   r1.3<0;1,0>:f                    {Compacted,F@1}
        mov (1|M0)               r106.2<1>:f   r106.0<0;1,0>:d                  {Compacted,I@1}
        mad (1|M0)               r97.7<1>:f    -r106.2<0;0>:f    r1.2<0;0>:f       r97.7<0>:f       {F@1}
        cmp (1|M0)    (gt)f1.1   null<1>:f     r97.7<0;1,0>:f    0.5:f               {F@1}
(W)     and (1|M0)               f1.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw              {F@1}
(f1.1.any16h) goto (16|M0)                   L8992                  L8992                
L8904:
        cmp (1|M0)    (lt)f1.1   null<1>:f     r97.7<0;1,0>:f    0.5:f               {A@1}
        and (1|M0)               r106.0<1>:d   r106.0<0;1,0>:d   1:w               {Compacted}
        add (1|M0)               r1.2<1>:f     r106.2<0;1,0>:f   1.0:f              
(~f1.1) cmp (1|M0)    (eq)f1.1   null<1>:d     r106.0<0;1,0>:d   0:w               {A@1}
(~f1.1) mov (1|M0)               r106.2<1>:f   r1.2<0;1,0>:f                    {F@1}
        goto (16|M0)                         L8992                  L9024                
L8992:
        join (16|M0)                         L9024                                
L9008:
        add (1|M0)               r106.2<1>:f   r106.2<0;1,0>:f   1.0:f               {F@1}
L9024:
        join (16|M0)                         L9088                                
L9040:
        add (1|M0)               r106.1<1>:ud  r106.1<0;1,0>:ud  0xFE800000:ud             
        mul (1|M0)               r106.2<1>:f   r106.2<0;1,0>:f   r106.1<0;1,0>:f  {A@1}
(f1.0)  mov (1|M0)               r106.2<1>:f   -r106.2<0;1,0>:f                 {F@1}
L9088:
        join (16|M0)                         L9200                                
L9104:
        add (1|M0)               r97.5<1>:d    r97.5<0;1,0>:d    1:w              
        add (1|M0)               a0.0<1>:uw    r97.12<0;1,0>:uw  0xB40:uw              {A@1}
        cmp (1|M0)    (eq)f1.0   null<1>:d     r97.5<0;1,0>:d    8:w               {A@1}
        mov (1|M0)               r[a0.0]<1>:f  r106.2<0;1,0>:f                  {$5.src}
(W)     and (1|M0)               f1.1<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
(~f1.1.any16h) goto.b (16|M0)                L9200                  L8160                
L9200:
        join (16|M0)                         L11000                                
L9216:
        mov (1|M0)               r106.3<1>:d   0:w                              
L9232:
        shl (1|M0)               r97.13<1>:w   r106.6<0;1,0>:w   2:w               {I@1}
(W)     and (1|M0)               f1.0<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
        add (1|M0)               a0.1<1>:uw    r97.13<0;1,0>:uw  0xD00:uw              {A@1}
        add (1|M0)               a0.0<1>:uw    r97.13<0;1,0>:uw  0xA20:uw              {A@1}
        mul (1|M0)               r106.4<1>:f   r[a0.1]<0;1,0>:f  r[a0.0,32]<0;1,0>:f
        add (1|M0)               a0.0<1>:uw    r97.13<0;1,0>:uw  0xCE0:uw              {A@1}
        add (1|M0)               r106.4<1>:f   r106.4<0;1,0>:f   r[a0.0]<0;1,0>:f {F@1}
(~f1.0.any16h) goto (16|M0)                  L9600                  L9600                 {A@1}
L9360:
        mov (1|M0)               r1.4<2>:hf    r106.4<0;1,0>:f                  {F@1}
        cmp (1|M0)    (lt)f1.1   null<1>:f     r106.4<0;1,0>:f   -4.001953e+00:f              
        mov (1|M0)               r1.3<1>:f     r1.4<0;1,0>:hf                   {F@2}
        mov (1|M0)               r2.1<1>:ud    0xBD650000:ud                             
        sel (1|M0)    (lt)f0.0   r1.3<1>:f     r1.3<0;1,0>:f     4.0:f               {F@1}
        mov (1|M0)               r2.3<1>:ud    0x3EE50000:ud                             
(~f1.1) sel (1|M0)               r2.0<1>:f     r1.3<0;1,0>:f     -4.0:f               {F@1}
        mov (1|M0)               r5.2<1>:ud    0x3F650000:ud                             
        mad (1|M0)               r2.1<1>:f     r2.3<0;0>:f       r2.1<0;0>:f       (abs)r2.0<0>:f   {A@1}
        mov (1|M0)               r3.14<2>:hf   r2.1<0;1,0>:f                    {F@1}
        mov (1|M0)               r4.3<1>:f     r3.14<0;1,0>:hf                  {F@1}
        mad (1|M0)               r2.0<1>:f     r5.2<0;0>:f       r4.3<0;0>:f       r2.0<0>:f        {A@1}
        mov (1|M0)               r6.0<2>:hf    r2.0<0;1,0>:f                    {F@1}
        mul (1|M0)               r1.4<1>:hf    r1.4<0;1,0>:hf    r6.0<0;1,0>:hf   {F@1}
        mov (1|M0)               r106.4<1>:f   r1.4<0;1,0>:hf                   {F@1}
L9600:
        join (16|M0)                         L10304                                
L9616:
(W)     and (1|M0)               f1.1<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(f1.1.any16h) goto (16|M0)                   L9728                  L9728                
L9648:
(W)     mov (1|M0)               f1.1<1>:uw    r111.12<0;1,0>:uw               
        mov (1|M0)               r1.4<2>:hf    r106.4<0;1,0>:f                  {F@1}
        mov (1|M0)               r106.7<1>:f   r1.4<0;1,0>:hf                   {F@1}
(~f1.1) mov (1|M0)               r106.7<1>:f   r106.4<0;1,0>:f                 
        goto (16|M0)                         L9728                  L10176                
L9728:
        join (16|M0)                         L10176                                
L9744:
        cmp (1|M0)    (lt)f1.1   null<1>:f     r106.4<0;1,0>:f   0.0:f               {I@3}
(f1.1)  mov (1|M0)               r106.4<1>:f   -r106.4<0;1,0>:f                
        sel (1|M0)    (lt)f0.0   r106.4<1>:f   r106.4<0;1,0>:f   448.0:f               {F@1}
        shr (1|M0)               r106.6<1>:ud  r106.4<0;1,0>:ud  0x17:uw              {F@1}
        and (1|M0)               r106.6<1>:ud  r106.6<0;1,0>:ud  0xFF:uw              {I@1}
        sel (1|M0)    (ge)f0.0   r106.6<1>:ud  r106.6<0;1,0>:ud  0x79:uw              {I@1}
        shl (1|M0)               r106.6<1>:ud  r106.6<0;1,0>:ud  0x17:uw              {I@1}
        add (1|M0)               r1.2<1>:ud    -r106.6<0;1,0>:ud  0x80800000:ud             {I@1}
        mul (1|M0)               r1.3<1>:f     r106.4<0;1,0>:f   r1.2<0;1,0>:f    {I@1}
        mov (1|M0)               r106.5<1>:d   r1.3<0;1,0>:f                    {F@1}
        mov (1|M0)               r106.7<1>:f   r106.5<0;1,0>:d                  {I@1}
        mad (1|M0)               r106.4<1>:f   -r106.7<0;0>:f    r1.2<0;0>:f       r106.4<0>:f      {F@1}
        cmp (1|M0)    (gt)f1.0   null<1>:f     r106.4<0;1,0>:f   0.5:f               {F@1}
(W)     and (1|M0)               f1.0<1>:uw    f1.0<0;1,0>:uw    0x1:uw              {F@1}
(f1.0.any16h) goto (16|M0)                   L10080                  L10080                
L9984:
        cmp (1|M0)    (lt)f1.0   null<1>:f     r106.4<0;1,0>:f   0.5:f               {A@1}
        and (1|M0)               r106.5<1>:d   r106.5<0;1,0>:d   1:w              
        add (1|M0)               r1.2<1>:f     r106.7<0;1,0>:f   1.0:f              
(~f1.0) cmp (1|M0)    (eq)f1.0   null<1>:d     r106.5<0;1,0>:d   0:w               {A@1}
(~f1.0) mov (1|M0)               r106.7<1>:f   r1.2<0;1,0>:f                    {F@1}
        goto (16|M0)                         L10080                  L10112                
L10080:
        join (16|M0)                         L10112                                
L10096:
        add (1|M0)               r106.7<1>:f   r106.7<0;1,0>:f   1.0:f               {F@1}
L10112:
        join (16|M0)                         L10176                                
L10128:
        add (1|M0)               r106.6<1>:ud  r106.6<0;1,0>:ud  0xFE800000:ud             
        mul (1|M0)               r106.7<1>:f   r106.7<0;1,0>:f   r106.6<0;1,0>:f  {A@1}
(f1.1)  mov (1|M0)               r106.7<1>:f   -r106.7<0;1,0>:f                 {F@1}
L10176:
        join (16|M0)                         L10304                                
L10192:
        add (1|M0)               r106.3<1>:d   r106.3<0;1,0>:d   1:w               {Compacted}
        or (1|M0)                r1.3<1>:uw    r97.13<0;1,0>:uw  0x20:uw             
        cmp (1|M0)    (eq)f1.0   null<1>:d     r106.3<0;1,0>:d   8:w               {I@2}
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0xB40:uw              {A@1}
        sync.nop                             null                             {Compacted,$5.src}
        mov (1|M0)               r[a0.0]<1>:f  r106.7<0;1,0>:f                  {F@1}
(W)     and (1|M0)               f1.0<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
(~f1.0.any16h) goto.b (16|M0)                L10304                  L9232                
L10304:
        join (16|M0)                         L11000                                
L10320:
(W)     and (1|M0)               f1.1<1>:uw    r111.14<0;1,0>:uw  0x1:uw            
(f1.1.any16h) goto (16|M0)                   L10800                  L10800                
L10352:
        addc (1|M0)              r2.0<1>:ud    r5.0<0;1,0>:ud    r46.4<0;1,0>:ud  {AccWrEn}
        shl (1|M0)               r1.6<1>:d     r97.3<0;1,0>:d    1:w              
        shl (1|M0)               r1.4<1>:d     r97.4<0;1,0>:d    1:w              
        shr (1|M0)               r1.5<1>:ud    r97.3<0;1,0>:ud   0x1F:uw             
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r8.0<1>:ud    r2.0<0;1,0>:ud    r1.6<0;1,0>:ud   {AccWrEn,I@4}
        or (1|M0)                r1.7<1>:d     r1.4<0;1,0>:d     r1.5<0;1,0>:d    {I@3}
        add3 (1|M0)              r1.3<1>:d     r7.0<0;0>:d       r5.1<0;0>:d       r46.5<0>:d       {I@3}
        sync.nop                             null                             {Compacted,$5.src}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$3.src}
        mov (1|M0)               r5.2<1>:d     r8.0<0;1,0>:d                    {I@4}
        add3 (1|M0)              r5.3<1>:d     r9.0<0;0>:d       r1.3<0;0>:d       r1.7<0>:d        {I@2}
        mov (8|M0)               r10.0<2>:ud   r5.2<0;1,0>:ud                   {I@2}
        mov (8|M0)               r10.1<2>:ud   r5.3<0;1,0>:ud                   {I@2}
        mov (8|M0)               r17.0<1>:d    r83.1<2;1,0>:d                  
        addc (8|M0)              r12.0<1>:ud   r10.0<2;1,0>:ud   r83.0<2;1,0>:ud  {AccWrEn,Compacted,I@2}
        mov (8|M0)               r9.0<1>:d     r85.1<2;1,0>:d                  
        mov (8|M0)               r7.0<1>:ud    acc0.0<1;1,0>:ud                 {Compacted}
        addc (8|M0)              r19.0<1>:ud   r10.0<2;1,0>:ud   r85.0<2;1,0>:ud  {AccWrEn,Compacted}
        mov (8|M0)               r6.0<1>:hf    r90.0<1;1,0>:f                   {F@1}
        mov (8|M0)               r8.0<1>:ud    acc0.0<1;1,0>:ud                 {Compacted}
        mov (8|M0)               r6.8<1>:hf    r91.0<1;1,0>:f                  
        add3 (8|M0)              r18.0<1>:d    r7.0<1;0>:d       r10.1<4;2>:d      r17.0<1>:d       {I@3}
        add3 (8|M0)              r20.0<1>:d    r8.0<1;0>:d       r10.1<4;2>:d      r9.0<1>:d        {I@2}
        sync.nop                             null                             {Compacted,$4.src}
        mov (8|M0)               r13.0<2>:d    r12.0<1;1,0>:d                   {$2.src}
        mov (8|M0)               r15.0<2>:d    r19.0<1;1,0>:d                  
        mov (16|M0)              r21.0<1>:d    r6.0<1;1,0>:uw                   {A@1}
        mov (8|M0)               r13.1<2>:d    r18.0<1;1,0>:d                   {I@5}
        mov (8|M0)               r15.1<2>:d    r20.0<1;1,0>:d                   {I@5}
        send.ugm (16|M0)         null     r13     r21:2   0x0            0x08000B84           {A@1,$4} // wr:4+2, rd:0; store.ugm.d16u32.a64
        goto (16|M0)                         L10800                  L11000                
L10800:
        join (16|M0)                         L11000                                
L10816:
        addc (1|M0)              r2.0<1>:ud    r5.0<0;1,0>:ud    r46.2<0;1,0>:ud  {AccWrEn}
        shl (1|M0)               r1.6<1>:d     r97.3<0;1,0>:d    2:w              
        shl (1|M0)               r1.4<1>:d     r97.4<0;1,0>:d    2:w              
        shr (1|M0)               r1.5<1>:ud    r97.3<0;1,0>:ud   0x1E:uw             
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r7.0<1>:ud    r2.0<0;1,0>:ud    r1.6<0;1,0>:ud   {AccWrEn,I@4}
        or (1|M0)                r1.7<1>:d     r1.4<0;1,0>:d     r1.5<0;1,0>:d    {I@3}
        add3 (1|M0)              r1.3<1>:d     r6.0<0;0>:d       r5.1<0;0>:d       r46.3<0>:d       {I@3}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        sync.allrd                           ($3,$5)                
        mov (1|M0)               r9.0<1>:f     r7.0<0;1,0>:f                    {Compacted,I@4}
        add3 (1|M0)              r9.1<1>:d     r8.0<0;0>:d       r1.3<0;0>:d       r1.7<0>:d        {I@1}
        send.ugm (1|M0)          null     r9      r90:2   0x0            0x0200D584           {A@1,$5} // wr:1+2, rd:0; store.ugm.d32x16t.a64
L11000:
        join (16|M0)                         L11080                                
L11016:
        add (1|M0)               r46.7<1>:d    r46.7<0;1,0>:d    1:w              
        cmp (1|M0)    (eq)f1.1   null<1>:d     r46.7<0;1,0>:d    8:w               {I@1}
(W)     and (1|M0)               f1.0<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(~f1.0.any16h) goto.b (16|M0)                L11080                  L3560                
L11080:
        join (16|M0)                         L11096                                
L11096:
(W)     mov (8|M0)               r127.0<1>:f   r0.0<1;1,0>:f                    {Compacted}
(W)     send.ugm (1|M0)          r6       r0      null:0  0x0            0x0210641F           {$14} // wr:1+0, rd:1; fence invalid flush type scoped to tile
(W)     mov (8|M0)               null<1>:ud    r6.0<1;1,0>:ud                   {$14.dst}
(W)     send.gtwy (1|M0)         null     r127    null:0  0x0            0x02000010           {EOT,A@1} // wr:1+0, rd:0; end of thread
L11152:
        mov (1|M0)               r1.2<1>:d     cr0.0<0;1,0>:ud                  {A@1}
        and (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   -1265:w               {A@1}
        or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   1264:w               {A@1}
        mov (1|M0)               r1.5<1>:f     (abs)r111.1<0;1,0>:d             {A@1}
        mov (1|M0)               r5.2<1>:f     0xB4C00000:f                               {Compacted}
        math.inv (1|M0)          r4.3<1>:f     r1.5<0;1,0>:f                    {@2,$15}
        mov (1|M0)               r2.1<1>:f     (abs)r111.0<0;1,0>:d             {Compacted}
        sync.nop                             null                             {Compacted,$15.dst}
        mad (1|M0)               r4.3<1>:f     r4.3<0;0>:f       r5.2<0;0>:f       r4.3<0>:f        {F@2}
        mov (1|M0)               r1.3<1>:d     (abs)r111.0<0;1,0>:d            
        mov (1|M0)               r1.4<1>:d     (abs)r111.1<0;1,0>:d            
        mov (1|M0)               r1.6<1>:ud    r1.5<0;1,0>:f                   
        mov (1|M0)               r2.3<1>:ud    r2.1<0;1,0>:f                    {F@2}
        mul (1|M0)               r6.0<1>:f     r4.3<0;1,0>:f     r2.1<0;1,0>:f    {A@1}
        add (1|M0)               r1.6<1>:ud    r1.4<0;1,0>:ud    -r1.6<0;1,0>:ud  {I@2}
        add (1|M0)               r2.3<1>:ud    r1.3<0;1,0>:ud    -r2.3<0;1,0>:ud  {I@2}
        mov (1|M0)               r7.0<1>:ud    r6.0<0;1,0>:f                    {F@1}
        mov (1|M0)               r2.0<1>:f     r1.6<0;1,0>:ud                   {Compacted,I@3}
        mov (1|M0)               r3.7<1>:f     r2.3<0;1,0>:ud                   {I@2}
        mov (1|M0)               r7.1<1>:f     r7.0<0;1,0>:ud                   {Compacted,I@1}
(W)     mov (1|M0)               r5.4<1>:hf    0x1:hf                             
        mad (1|M0)               r2.1<1>:f     r2.1<0;0>:f       r7.1<0;0>:f       -r1.5<0>:f       {F@2}
        mad (1|M0)               r7.1<1>:f     r3.7<0;0>:f       r7.1<0;0>:f       -r2.0<0>:f      
        xor (1|M0)               r111.1<1>:d   r111.1<0;1,0>:d   r111.0<0;1,0>:d  {Compacted}
        add (1|M0)               r2.1<1>:f     r2.1<0;1,0>:f     r7.1<0;1,0>:f    {F@1}
        asr (1|M0)               r111.1<1>:d   r111.1<0;1,0>:d   31:w               {Compacted,I@1}
        mul (1|M0)               r4.3<1>:f     r4.3<0;1,0>:f     r2.1<0;1,0>:f    {F@1}
        mov (1|M0)               r8.0<1>:ud    r4.3<0;1,0>:f                    {F@1}
        add (1|M0)               r7.0<1>:ud    r7.0<0;1,0>:ud    r8.0<0;1,0>:ud   {Compacted,I@1}
(W)     mul (1|M0)               acc0.0<1>:ud  r7.0<0;1,0>:ud    r1.8<0;1,0>:uw   {I@1}
        mach (1|M0)              r9.0<1>:ud    r7.0<0;1,0>:ud    r1.4<0;1,0>:ud   {Compacted}
        add (1|M0)               r1.3<1>:ud    r1.3<0;1,0>:ud    -r9.0<0;1,0>:ud  {Compacted,I@1}
        cmp (1|M0)    (ge)f1.1   null<1>:ud    r1.3<0;1,0>:ud    r1.4<0;1,0>:ud   {I@1}
(f1.1)  sel (1|M0)               r3.7<1>:d     r5.4<0;1,0>:w     0:w              
        add3 (1|M0)              r7.0<1>:d     r7.0<0;0>:d       r111.1<0;0>:d     r3.7<0>:d        {I@1}
        xor (1|M0)               r43.2<1>:d    r7.0<0;1,0>:d     r111.1<0;1,0>:d  {I@1}
        mov (1|M0)               cr0.0<1>:ud   r1.2<0;1,0>:d                    {A@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        ret (16|M0)                          r111.2                           {A@1}
L11712:
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
