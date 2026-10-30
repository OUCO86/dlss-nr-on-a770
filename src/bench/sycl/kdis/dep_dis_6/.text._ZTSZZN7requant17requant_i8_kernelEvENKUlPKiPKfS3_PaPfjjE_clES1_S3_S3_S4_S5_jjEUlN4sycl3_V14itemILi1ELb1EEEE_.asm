L0:
(W)     mov (8|M0)               r127.0<1>:ud  0x0:ud                             
(W)     and (1|M0)               r127.2<1>:ud  r0.0<0;1,0>:ud    0xFFFFFFC0:ud             
(W)     and (1|M0)               r127.0<1>:uw  r0.4<0;1,0>:uw    0xFF:uw             
(W)     add (1|M0)               r127.2<1>:ud  r127.2<0;1,0>:ud  0x60:ud              {I@2}
(W)     add (1|M0)               r127.2<1>:ud  r127.2<0;1,0>:ud  0x0:ud              {I@1}
(W)     mad (1|M0)               r127.2<1>:ud  r127.2<0;0>:ud    r127.0<0;0>:uw    0xC0:uw              {I@1}
(W)     mov (8|M0)               r7.0<1>:ud    r1.0<1;1,0>:ud                  
(W)     send.dc0 (8|M0)          r1       r127    null:0  0x0            0x024844FD           {A@1,$0} // wr:1h+0, rd:4; oword aligned block read x8
(W)     add (1|M0)               r127.2<1>:ud  r127.2<0;1,0>:ud  0x80:uw              {$0.src}
(W)     send.dc0 (8|M0)          r5       r127    null:0  0x0            0x022843FD           {A@1,$1} // wr:1h+0, rd:2; oword aligned block read x4
        nop                    
        nop                    
(W)     mov (8|M0)               r127.0<1>:ud  0x0:ud                              {$1.src}
(W)     and (1|M0)               r127.2<1>:ud  r0.0<0;1,0>:ud    0xFFFFFFC0:ud             
(W)     add (1|M0)               r127.2<1>:ud  r127.2<0;1,0>:ud  0x0:ud              {I@1}
(W)     send.dc0 (8|M0)          r8       r127    null:0  0x0            0x022843FD           {A@1,$2} // wr:1h+0, rd:2; oword aligned block read x4
(W)     add (1|M0)               r127.2<1>:ud  r127.2<0;1,0>:ud  0x40:uw              {$2.src}
(W)     send.dc0 (8|M0)          r10      r127    null:0  0x0            0x021842FD           {A@1,$3} // wr:1h+0, rd:1; oword aligned block read x2
(W)     mov (8|M0)               r62.0<1>:ud   r0.0<1;1,0>:ud                  
(W)     or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x4C0:uw              {A@1}
(W)     mul (1|M0)               acc0.0<1>:d   r7.3<0;1,0>:d     r62.2<0;1,0>:uw  {A@1}
(W)     mach (1|M0)              r3.0<1>:d     r7.3<0;1,0>:d     r62.1<0;1,0>:d   {$0.dst}
        add3 (16|M0)             r12.0<1>:d    r3.0<0;0>:d       r1.0<1;0>:uw      r7.0<0>:d        {I@1}
        add3 (16|M16)            r4.0<1>:d     r3.0<0;0>:d       r2.0<1;0>:uw      r7.0<0>:d        {$1.dst}
        sync.nop                             null                             {Compacted,$2.dst}
        cmp (16|M0)   (lt)f1.0   null<1>:d     r12.0<1;1,0>:ud   r9.0<0;1,0>:ud   {I@2}
        cmp (16|M16)  (lt)f1.0   null<1>:d     r4.0<1;1,0>:ud    r9.0<0;1,0>:ud   {I@2}
(~f1.0) goto (32|M0)                         L46320                  L46320                
L440:
(W)     mul (8|M0)               acc0.0<1>:ud  r12.0<1;1,0>:ud   r9.2<0;1,0>:uw  
(W)     cmp (16|M0)   (eq)f0.0   null<1>:d     r9.1<0;1,0>:d     0:w               {Compacted}
(W)     cmp (16|M16)  (eq)f0.0   null<1>:d     r9.1<0;1,0>:d     0:w              
        mach (8|M0)              r92.0<1>:ud   r12.0<1;1,0>:ud   r9.1<0;1,0>:ud   {Compacted}
(W)     mul (8|M8)               acc0.0<1>:ud  r13.0<1;1,0>:ud   r9.2<0;1,0>:uw  
        mach (8|M8)              r93.0<1>:ud   r13.0<1;1,0>:ud   r9.1<0;1,0>:ud   {Compacted}
(W)     mul (8|M16)              acc0.0<1>:ud  r4.0<1;1,0>:ud    r9.2<0;1,0>:uw  
        mach (8|M16)             r90.0<1>:ud   r4.0<1;1,0>:ud    r9.1<0;1,0>:ud   {Compacted}
(W)     mul (8|M24)              acc0.0<1>:ud  r5.0<1;1,0>:ud    r9.2<0;1,0>:uw  
        shl (16|M0)              r112.0<1>:d   r12.0<1;1,0>:d    2:w               {Compacted}
        shl (16|M16)             r110.0<1>:d   r4.0<1;1,0>:d     2:w               {Compacted}
        mach (8|M24)             r91.0<1>:ud   r5.0<1;1,0>:ud    r9.1<0;1,0>:ud   {Compacted}
(~f0.0) goto (32|M0)                         L632                  L632                
L592:
        mov (16|M0)              r106.0<1>:ud  0x0:ud                             
        mov (16|M16)             r108.0<1>:f   0.0:f                               {Compacted}
        goto (32|M0)                         L632                  L46248                
L632:
        join (32|M0)                         L46248                                
L648:
(W)     mov (1|M0)               a0.0<1>:ud    r9.7<0;1,0>:d                    {A@1}
(W)     mov (1|M0)               r3.0<1>:hf    0.0:hf                             
        mov (16|M0)              r88.0<1>:f    0.0:f                               {Compacted}
        send.ugm (16|M0)         r96      r112    null:0  a0.0        0x24280500           {ExBSO,A@7,$4} // wr:2+0, rd:2; load.ugm.d32.a32.ca.ca.bss[a0.0]
        send.ugm (16|M16)        r94      r110    null:0  a0.0        0x24280500           {ExBSO,A@7,$5} // wr:2+0, rd:2; load.ugm.d32.a32.ca.ca.bss[a0.0]
        mov (16|M16)             r86.0<1>:f    0.0:f                               {Compacted}
(W)     mov (1|M0)               r9.3<1>:f     inf:f                               {Compacted}
(W)     mov (1|M0)               r9.0<1>:d     -1:w                              
(W)     mov (1|M0)               r9.2<1>:d     0:w                              
(W)     mov (1|M0)               r9.7<1>:f     -0.0:f                               {Compacted,I@3}
        and (16|M0)   (ne)f0.0   r4.0<1>:d     r96.0<1;1,0>:d    8388607:d               {$4.dst}
        shr (16|M0)              r100.0<1>:ud  r96.0<1;1,0>:ud   23:w              
(W)     mov (1|M0)               r10.2<1>:ud   f0.0<0;1,0>:ud                   {Compacted,$3.dst}
        cmp (16|M0)   (eq)f0.0   null<1>:d     r4.0<1;1,0>:d     0:w               {Compacted,I@3}
(W)     mov (1|M0)               f1.0<1>:ud    r10.2<0;1,0>:ud                  {I@2}
        and (16|M16)  (ne)f1.0   r12.0<1>:d    r94.0<1;1,0>:d    8388607:d               {$5.dst}
(W)     mov (1|M0)               r10.3<1>:ud   f0.0<0;1,0>:ud                   {Compacted}
        shr (16|M16)             r98.0<1>:ud   r94.0<1;1,0>:ud   23:w              
(W)     mov (1|M0)               f0.0<1>:ud    r10.3<0;1,0>:ud                  {I@2}
        cmp (16|M16)  (eq)f0.0   null<1>:d     r12.0<1;1,0>:d    0:w              
(W)     mov (1|M0)               r10.2<1>:ud   f1.0<0;1,0>:ud                   {Compacted}
        and (16|M0)   (eq)f1.0   r14.0<1>:d    r100.0<1;1,0>:d   255:w              
(W)     mov (1|M0)               r10.3<1>:ud   f0.0<0;1,0>:ud                   {Compacted}
(W)     mov (1|M0)               f0.0<1>:ud    r10.2<0;1,0>:ud                  {I@3}
        and (16|M16)  (eq)f1.0   r16.0<1>:d    r98.0<1;1,0>:d    255:w              
        add (16|M0)              r18.0<1>:d    r14.0<1;1,0>:d    -127:w               {Compacted,I@4}
(f0.0)  cmp (16|M0)   (eq)f0.0   null<1>:d     r14.0<1;1,0>:d    255:w              
(f1.0)  sel (16|M0)              r22.0<1>:d    r3.0<0;1,0>:w     8388608:d               {F@5}
(W)     mov (1|M0)               r10.2<1>:ud   f0.0<0;1,0>:ud                   {Compacted}
        add (16|M16)             r20.0<1>:d    r16.0<1;1,0>:d    -127:w               {Compacted,I@5}
(W)     mov (1|M0)               f0.0<1>:ud    r10.2<0;1,0>:ud                  {I@2}
(f1.0)  sel (16|M16)             r24.0<1>:d    r3.0<0;1,0>:w     8388608:d              
(~f1.0) sel (16|M0)              r84.0<1>:d    r18.0<1;1,0>:d    -126:w              
(f0.0)  cmp (16|M16)  (eq)f0.0   null<1>:d     r16.0<1;1,0>:d    255:w              
        or (16|M0)               r38.0<1>:d    r22.0<1;1,0>:d    r4.0<1;1,0>:d    {Compacted}
(W)     mov (1|M0)               r10.2<1>:ud   f0.0<0;1,0>:ud                   {Compacted}
(W)     mov (1|M0)               f0.0<1>:ud    r10.3<0;1,0>:ud                 
(~f1.0) sel (16|M16)             r82.0<1>:d    r20.0<1;1,0>:d    -126:w               {I@7}
        or (16|M16)              r36.0<1>:d    r24.0<1;1,0>:d    r12.0<1;1,0>:d   {Compacted,I@7}
(f0.0)  cmp (16|M0)   (eq)f0.0   null<1>:d     r14.0<1;1,0>:d    255:w              
(W)     mov (1|M0)               r10.3<1>:ud   f0.0<0;1,0>:ud                   {Compacted}
(W)     mov (1|M0)               f0.0<1>:ud    r10.3<0;1,0>:ud                  {I@1}
(f0.0)  cmp (16|M16)  (eq)f0.0   null<1>:d     r16.0<1;1,0>:d    255:w              
(W)     mov (1|M0)               r10.3<1>:ud   f0.0<0;1,0>:ud                   {Compacted}
        or (16|M0)    (eq)f0.0   r104.0<1>:d   r14.0<1;1,0>:d    r4.0<1;1,0>:d    {Compacted}
(W)     mov (1|M0)               r10.5<1>:ud   f0.0<0;1,0>:ud                   {Compacted}
(W)     mov (1|M0)               f0.0<1>:ud    r10.5<0;1,0>:ud                  {I@1}
        or (16|M16)   (eq)f0.0   r102.0<1>:d   r16.0<1;1,0>:d    r12.0<1;1,0>:d  
(W)     mov (1|M0)               r10.5<1>:ud   f0.0<0;1,0>:ud                   {Compacted}
L1272:
        add (16|M0)              r4.0<1>:d     r9.2<0;1,0>:d     r92.0<1;1,0>:d   {Compacted}
        add (16|M16)             r12.0<1>:d    r9.2<0;1,0>:d     r90.0<1;1,0>:d   {Compacted}
(W)     mov (1|M0)               a0.0<1>:ud    r9.5<0;1,0>:d                    {A@1}
        shl (16|M0)              r4.0<1>:d     r4.0<1;1,0>:d     2:w               {Compacted,I@3}
        shl (16|M16)             r12.0<1>:d    r12.0<1;1,0>:d    2:w               {Compacted,I@3}
        send.ugm (16|M0)         r14      r4      null:0  a0.0        0x24280500           {ExBSO,A@2,$6} // wr:2+0, rd:2; load.ugm.d32.a32.ca.ca.bss[a0.0]
        send.ugm (16|M16)        r16      r12     null:0  a0.0        0x24280500           {ExBSO,A@1,$7} // wr:2+0, rd:2; load.ugm.d32.a32.ca.ca.bss[a0.0]
(W)     mov (1|M0)               r3.0<1>:hf    0x1:hf                             
(W)     mov (1|M0)               f1.0<1>:ud    r10.2<0;1,0>:ud                 
        sync.nop                             null                             {Compacted,$6.src}
(f1.0)  sel (16|M0)              r5.0<1>:uw    r3.0<0;1,0>:uw    0x0:uw              {Compacted,F@1}
        mov (16|M0)              r22.0<1>:f    r14.0<1;1,0>:d                   {Compacted,$6.dst}
        mov (16|M16)             r26.0<1>:f    r16.0<1;1,0>:d                   {Compacted,$7.dst}
        shr (16|M0)              r18.0<1>:ud   r22.0<1;1,0>:ud   23:w               {F@2}
        shr (16|M16)             r12.0<1>:ud   r26.0<1;1,0>:ud   23:w               {F@1}
        and (16|M0)   (ne)f0.0   r16.0<1>:d    r22.0<1;1,0>:d    8388607:d              
        and (16|M16)  (ne)f0.0   r14.0<1>:d    r26.0<1;1,0>:d    8388607:d              
        and (16|M0)              r24.0<1>:d    r18.0<1;1,0>:d    255:w               {Compacted,I@4}
        and (16|M16)             r20.0<1>:d    r12.0<1;1,0>:d    255:w               {Compacted,I@4}
(f0.0)  cmp (16|M0)   (eq)f0.0   null<1>:d     r24.0<1;1,0>:d    255:w               {I@2}
(f0.0)  cmp (16|M16)  (eq)f0.0   null<1>:d     r20.0<1;1,0>:d    255:w               {I@2}
(f0.0)  sel (16|M0)              acc2.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw             
(f0.0)  sel (16|M16)             acc0.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw             
(W)     mov (1|M0)               f0.0<1>:ud    r10.2<0;1,0>:ud                 
        or (16|M0)    (ne)f1.0   null<1>:uw    acc2.0<1;1,0>:uw  r5.0<1;1,0>:uw  
(f0.0)  sel (16|M16)             acc2.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw             
        or (16|M16)   (ne)f1.0   null<1>:uw    acc0.0<1;1,0>:uw  acc2.0<1;1,0>:uw
(~f1.0) goto (32|M0)                         L1680                  L1680                
L1640:
        mov (16|M0)              r22.0<1>:ud   0x7FC00000:ud                             
        mov (16|M16)             r28.0<1>:f    qnan(0x0):f                               {Compacted}
        goto (32|M0)                         L1680                  L12112                
L1680:
        join (32|M0)                         L12112                                
L1696:
        cmp (16|M0)   (eq)f0.0   null<1>:d     r16.0<1;1,0>:d    0:w               {Compacted}
        cmp (16|M16)  (eq)f0.0   null<1>:d     r14.0<1;1,0>:d    0:w              
(f0.0)  cmp (16|M0)   (eq)f0.0   null<1>:d     r24.0<1;1,0>:d    255:w              
(f0.0)  cmp (16|M16)  (eq)f0.0   null<1>:d     r20.0<1;1,0>:d    255:w              
(W)     mov (1|M0)               r3.0<1>:hf    0x1:hf                              {I@7}
(W)     mov (1|M0)               f1.0<1>:ud    r10.3<0;1,0>:ud                 
(f0.0)  sel (16|M0)              acc0.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw              {F@1}
(f0.0)  sel (16|M16)             r6.0<1>:uw    r3.0<0;1,0>:uw    0x0:uw             
(W)     mov (1|M0)               f0.0<1>:ud    r10.3<0;1,0>:ud                 
(f1.0)  sel (16|M0)              acc2.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw             
        or (16|M0)    (ne)f1.0   null<1>:uw    acc0.0<1;1,0>:uw  acc2.0<1;1,0>:uw
(f0.0)  sel (16|M16)             acc0.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw             
        or (16|M16)   (ne)f1.0   null<1>:uw    r6.0<1;1,0>:uw    acc0.0<1;1,0>:uw {I@5}
        xor (16|M0)              r22.0<1>:d    r96.0<1;1,0>:d    r22.0<1;1,0>:d   {Compacted}
        xor (16|M16)             r26.0<1>:d    r94.0<1;1,0>:d    r26.0<1;1,0>:d   {Compacted}
(f1.0)  goto (32|M0)                         L12064                  L12064                
L1928:
(W)     mov (1|M0)               f1.0<1>:ud    r10.5<0;1,0>:ud                 
(W)     mov (1|M0)               r3.0<1>:hf    0x1:hf                              {I@6}
        or (16|M0)    (eq)f0.0   null<1>:d     r24.0<1;1,0>:d    r16.0<1;1,0>:d  
        or (16|M16)   (eq)f0.0   null<1>:d     r20.0<1;1,0>:d    r14.0<1;1,0>:d  
(f1.0)  sel (16|M0)              r5.0<1>:uw    r3.0<0;1,0>:uw    0x0:uw              {Compacted,F@1}
(W)     mov (1|M0)               f1.0<1>:ud    r10.5<0;1,0>:ud                 
(f0.0)  sel (16|M0)              r4.0<1>:uw    r3.0<0;1,0>:uw    0x0:uw              {Compacted}
(f0.0)  sel (16|M16)             acc0.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw             
(f1.0)  sel (16|M16)             acc2.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw             
        or (16|M0)    (ne)f0.0   null<1>:uw    r4.0<1;1,0>:uw    r5.0<1;1,0>:uw   {I@3}
        or (16|M16)   (ne)f0.0   null<1>:uw    acc0.0<1;1,0>:uw  acc2.0<1;1,0>:uw
(~f0.0) goto (32|M0)                         L2144                  L2144                
L2104:
        mov (16|M0)              r22.0<1>:ud   0x0:ud                             
        mov (16|M16)             r28.0<1>:f    0.0:f                               {Compacted}
        goto (32|M0)                         L2144                  L12112                
L2144:
        join (32|M0)                         L12064                                
L2160:
        cmp (16|M0)   (eq)f1.0   null<1>:d     r24.0<1;1,0>:d    0:w              
        cmp (16|M16)  (eq)f1.0   null<1>:d     r20.0<1;1,0>:d    0:w              
        add (16|M0)              r52.0<1>:d    r24.0<1;1,0>:d    -127:w               {Compacted}
        add (16|M16)             r64.0<1>:d    r20.0<1;1,0>:d    -127:w               {Compacted}
(f1.0)  mov (16|M0)              r52.0<1>:d    -126:w                              
(f1.0)  mov (16|M16)             r64.0<1>:d    -126:w                              
        add (16|M0)              r50.0<1>:d    r52.0<1;1,0>:d    r84.0<1;1,0>:d   {Compacted,I@2}
        add (16|M16)             r48.0<1>:d    r64.0<1;1,0>:d    r82.0<1;1,0>:d   {Compacted,I@2}
        cmp (16|M0)   (gt)f0.0   null<1>:d     r50.0<1;1,0>:d    127:w               {Compacted,I@2}
        cmp (16|M16)  (gt)f0.0   null<1>:d     r48.0<1;1,0>:d    127:w               {I@2}
(f0.0)  goto (32|M0)                         L11976                  L11976                
L2296:
        or (16|M0)    (eq)f0.0   null<4>:b     r18.0<1;1,0>:d    r100.0<1;1,0>:d 
        or (16|M16)   (eq)f0.0   null<4>:b     r12.0<1;1,0>:d    r98.0<1;1,0>:d  
(f0.0)  goto (32|M0)                         L11888                  L11888                
L2344:
(W)     mov (1|M0)               r3.0<1>:hf    0.0:hf                             
(W)     mov (1|M0)               r2.3<1>:d     0:w                              
(f1.0)  sel (16|M0)              r4.0<1>:d     r3.0<0;1,0>:w     8388608:d               {F@1}
        or (16|M0)               r4.0<1>:d     r4.0<1;1,0>:d     r16.0<1;1,0>:d   {Compacted,I@1}
(f1.0)  sel (16|M16)             r12.0<1>:d    r3.0<0;1,0>:w     8388608:d              
        mul (8|M0)               acc0.0<1>:ud  r4.0<1;1,0>:ud    r38.0<2;1,0>:uw  {I@2}
        or (16|M16)              r12.0<1>:d    r12.0<1;1,0>:d    r14.0<1;1,0>:d   {Compacted,I@2}
        mach (8|M0)              r14.0<1>:ud   r4.0<1;1,0>:ud    r38.0<1;1,0>:ud  {AccWrEn,Compacted}
(W)     mov (1|M0)               r2.5<1>:f     -0.0:f                               {Compacted}
        mov (8|M0)               r16.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mul (8|M8)               acc0.0<1>:ud  r5.0<1;1,0>:ud    r39.0<2;1,0>:uw 
        mach (8|M8)              r15.0<1>:ud   r5.0<1;1,0>:ud    r39.0<1;1,0>:ud  {AccWrEn}
(W)     mov (2|M0)               r2.0<1>:d     0:w                              
        mov (8|M8)               r17.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mul (8|M16)              acc0.0<1>:ud  r12.0<1;1,0>:ud   r36.0<2;1,0>:uw  {I@7}
        mach (8|M16)             r18.0<1>:ud   r12.0<1;1,0>:ud   r36.0<1;1,0>:ud  {AccWrEn}
        mov (16|M0)              r42.0<1>:f    r14.0<1;1,0>:f                   {Compacted,A@5}
        mov (8|M16)              r20.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mul (8|M24)              acc0.0<1>:ud  r13.0<1;1,0>:ud   r37.0<2;1,0>:uw 
        mach (8|M24)             r19.0<1>:ud   r13.0<1;1,0>:ud   r37.0<1;1,0>:ud  {AccWrEn}
        mov (16|M0)              r46.0<1>:f    r16.0<1;1,0>:f                   {Compacted,I@6}
        mov (8|M24)              r21.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mov (16|M16)             r40.0<1>:f    r18.0<1;1,0>:f                   {Compacted,A@2}
        mov (16|M16)             r44.0<1>:f    r20.0<1;1,0>:f                   {Compacted,I@1}
L2632:
(W)     shl (1|M0)               r3.0<1>:d     r2.5<0;1,0>:d     31:w               {Compacted,F@5}
(W)     shr (1|M0)               r3.1<1>:ud    r2.3<0;1,0>:ud    1:w              
(W)     addc (1|M0)              r7.0<1>:ud    r2.0<0;1,0>:ud    0x1:ud              {AccWrEn}
(W)     or (1|M0)                r2.3<1>:d     r3.1<0;1,0>:d     r3.0<0;1,0>:d    {I@2}
        bfn.0xA8 (16|M0)         r12.0<1>:ud   r46.0<1;0>:ud     r3.1<0;0>:ud      r3.0<0>:ud       {F@3} // s0&(s1|s2)
        cmp (16|M0)   (eq)f0.0   null<1>:d     r12.0<1;1,0>:d    r2.3<0;1,0>:d    {I@1}
(W)     mov (1|M0)               r4.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        bfn.0xA8 (16|M16)        r14.0<1>:ud   r44.0<1;0>:ud     r3.1<0;0>:ud      r3.0<0>:ud       {F@1} // s0&(s1|s2)
(W)     add (1|M0)               r2.4<1>:ud    r4.0<0;1,0>:ud    r2.1<0;1,0>:ud   {I@2}
(W)     mov (1|M0)               r4.0<1>:ud    f0.0<0;1,0>:ud                   {Compacted}
(W)     shr (1|M0)               r2.2<1>:ud    r2.5<0;1,0>:ud    1:w              
(W)     mov (1|M0)               f0.0<1>:ud    r4.0<0;1,0>:ud                   {I@2}
        cmp (16|M16)  (eq)f0.0   null<1>:d     r14.0<1;1,0>:d    r2.3<0;1,0>:d   
        and (16|M0)              r16.0<1>:d    r42.0<1;1,0>:d    r2.2<0;1,0>:d    {Compacted,I@3}
(W)     mov (1|M0)               r4.0<1>:ud    f0.0<0;1,0>:ud                   {Compacted}
(W)     cmp (16|M0)   (gt)f1.0   null<1>:d     r2.0<0;1,0>:ud    0x3E:uw             
(W)     mov (1|M0)               f0.0<1>:ud    r4.0<0;1,0>:ud                   {I@2}
        and (16|M16)             r18.0<1>:d    r40.0<1;1,0>:d    r2.2<0;1,0>:d    {Compacted}
(W&f1.0) cmp (16|M0)  (eq)f1.0   null<1>:d     r2.1<0;1,0>:d     0:w              
(f0.0)  cmp (16|M0)   (eq)f0.0   null<1>:d     r16.0<1;1,0>:d    r2.2<0;1,0>:d   
(W&~f1.0) cmp (16|M0) (gt)f1.0   null<1>:d     r2.1<0;1,0>:ud    0x0:uw             
(W)     mov (1|M0)               r4.0<1>:ud    f0.0<0;1,0>:ud                   {Compacted}
(W)     cmp (16|M16)  (gt)f1.0   null<1>:d     r2.0<0;1,0>:ud    0x3E:uw             
(W)     mov (1|M0)               f0.0<1>:ud    r4.0<0;1,0>:ud                   {I@2}
(W)     mov (1|M0)               r3.0<1>:hf    0x1:hf                             
(W&f1.0) cmp (16|M16) (eq)f1.0   null<1>:d     r2.1<0;1,0>:d     0:w              
(f0.0)  cmp (16|M16)  (eq)f0.0   null<1>:d     r18.0<1;1,0>:d    r2.2<0;1,0>:d   
(f1.0)  sel (16|M0)              acc0.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw              {F@1}
(f0.0)  sel (16|M0)              acc2.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw             
(W)     mov (1|M0)               r4.0<1>:ud    f0.0<0;1,0>:ud                   {Compacted}
        or (16|M0)    (ne)f0.0   null<1>:uw    acc0.0<1;1,0>:uw  acc2.0<1;1,0>:uw
(W&~f1.0) cmp (16|M16) (gt)f1.0  null<1>:d     r2.1<0;1,0>:ud    0x0:uw             
(W)     mov (1|M0)               r3.1<1>:ud    f0.0<0;1,0>:ud                   {Compacted}
(W)     mov (1|M0)               f0.0<1>:ud    r4.0<0;1,0>:ud                   {I@4}
(f1.0)  sel (16|M16)             acc0.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw             
(W)     mov (1|M0)               f1.0<1>:ud    r3.1<0;1,0>:ud                   {I@3}
(f0.0)  sel (16|M16)             acc2.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw             
        or (16|M16)   (ne)f1.0   null<1>:uw    acc0.0<1;1,0>:uw  acc2.0<1;1,0>:uw
        mov (16|M0)              r60.0<1>:f    r2.0<0;1,0>:f                    {Compacted}
(W)     mov (1|M0)               r3.1<1>:ud    f1.0<0;1,0>:ud                   {Compacted}
        mov (16|M16)             r58.0<1>:f    r2.0<0;1,0>:f                    {Compacted}
(W)     mov (1|M0)               f0.0<1>:ud    r3.1<0;1,0>:ud                   {I@1}
        mov (16|M16)             r20.0<1>:d    r2.1<0;1,0>:d                   
        mov (16|M0)              r34.0<1>:f    r7.0<0;1,0>:f                    {Compacted}
        mov (16|M16)             r32.0<1>:f    r7.0<0;1,0>:f                    {Compacted}
        mov (16|M0)              r30.0<1>:d    r2.4<0;1,0>:d                   
        mov (16|M16)             r24.0<1>:d    r2.4<0;1,0>:d                   
        mov (16|M0)              r16.0<1>:d    r2.1<0;1,0>:d                   
(f0.0)  goto (32|M0)                         L3360                  L3360                
L3304:
(W)     mov (1|M0)               r2.5<1>:d     r2.2<0;1,0>:d                   
(W)     mov (1|M0)               r2.0<1>:f     r7.0<0;1,0>:f                    {Compacted}
(W)     mov (1|M0)               r2.1<1>:d     r2.4<0;1,0>:d                   
(W)     jmpi                                 L2632                                
L3360:
        join (32|M0)                         L11888                                
L3376:
(W)     mov (1|M0)               r3.0<1>:f     8.68805e-44:f                              
(W)     mov (1|M0)               r4.0<1>:hf    0.0:hf                             
        subb (8|M0)              r56.0<1>:ud   r3.0<0;1,0>:ud    r60.0<1;1,0>:ud  {AccWrEn,Compacted,F@2}
        add3 (8|M0)              r72.0<1>:ud   -acc0.0<1;0>:ud   r4.0<0;0>:uw      -r16.0<1>:ud     {A@1}
        subb (8|M8)              r57.0<1>:ud   r3.0<0;1,0>:ud    r61.0<1;1,0>:ud  {AccWrEn}
        add3 (8|M8)              r73.0<1>:ud   -acc0.0<1;0>:ud   r4.0<0;0>:uw      -r17.0<1>:ud    
        subb (8|M16)             r54.0<1>:ud   r3.0<0;1,0>:ud    r58.0<1;1,0>:ud  {AccWrEn}
        add3 (16|M0)             r18.0<1>:d    r50.0<1;0>:d      r56.0<1;0>:d      -46:w               {I@3}
        add3 (8|M16)             r80.0<1>:ud   -acc0.0<1;0>:ud   r4.0<0;0>:uw      -r20.0<1>:ud    
        subb (8|M24)             r55.0<1>:ud   r3.0<0;1,0>:ud    r59.0<1;1,0>:ud  {AccWrEn}
        cmp (16|M0)   (gt)f0.0   null<1>:d     r18.0<1;1,0>:d    127:w               {Compacted,I@3}
        add3 (16|M16)            r68.0<1>:d    r64.0<1;0>:d      r82.0<1;0>:d      r54.0<1>:d       {I@2}
        add3 (16|M16)            r64.0<1>:d    r48.0<1;0>:d      r54.0<1;0>:d      -46:w              
        cmp (16|M16)  (gt)f0.0   null<1>:d     r64.0<1;1,0>:d    127:w               {I@1}
        add3 (16|M0)             r52.0<1>:d    r52.0<1;0>:d      r84.0<1;0>:d      r56.0<1>:d      
        add3 (8|M24)             r81.0<1>:ud   -acc0.0<1;0>:ud   r4.0<0;0>:uw      -r21.0<1>:ud    
(f0.0)  goto (32|M0)                         L11800                  L11800                
L3632:
        cmp (16|M0)   (gt)f1.0   null<1>:d     r18.0<1;1,0>:d    -127:w              
        cmp (16|M16)  (gt)f1.0   null<1>:d     r64.0<1;1,0>:d    -127:w              
(f1.0)  goto (32|M0)                         L7720                  L7720                
L3680:
        cmp (16|M0)   (lt)f0.0   null<1>:d     r18.0<1;1,0>:ud   0xFFFFFF6B:ud             
        cmp (16|M16)  (lt)f0.0   null<1>:d     r64.0<1;1,0>:ud   0xFFFFFF6B:ud             
(f0.0)  goto (32|M0)                         L6968                  L6968                
L3728:
(W)     mov (1|M0)               r3.0<1>:f     8.82818e-44:f                              
(W)     mov (1|M0)               r4.0<1>:hf    0.0:hf                              {I@7}
        subb (8|M0)              r30.0<1>:ud   r3.0<0;1,0>:ud    r60.0<1;1,0>:ud  {AccWrEn,Compacted,F@2}
        add3 (16|M16)            r66.0<1>:d    r48.0<1;0>:d      r54.0<1;0>:d      104:w              
        add3 (8|M0)              r12.0<1>:ud   -acc0.0<1;0>:ud   r4.0<0;0>:uw      -r16.0<1>:ud     {F@1}
        subb (8|M8)              r31.0<1>:ud   r3.0<0;1,0>:ud    r61.0<1;1,0>:ud  {AccWrEn}
        add3 (16|M0)             r34.0<1>:d    r50.0<1;0>:d      r56.0<1;0>:d      104:w              
        add3 (8|M8)              r13.0<1>:ud   -acc0.0<1;0>:ud   r4.0<0;0>:uw      -r17.0<1>:ud    
        subb (8|M16)             r60.0<1>:ud   r3.0<0;1,0>:ud    r58.0<1;1,0>:ud  {AccWrEn}
        cmp (16|M0)   (gt)f0.0   null<1>:d     r30.0<1;1,0>:ud   r34.0<1;1,0>:ud  {I@3}
        add3 (8|M16)             r14.0<1>:ud   -acc0.0<1;0>:ud   r4.0<0;0>:uw      -r20.0<1>:ud    
        subb (8|M24)             r61.0<1>:ud   r3.0<0;1,0>:ud    r59.0<1;1,0>:ud  {AccWrEn}
(W)     mov (1|M0)               r5.0<1>:hf    0x1:hf                             
        cmp (16|M16)  (gt)f1.0   null<1>:d     r60.0<1;1,0>:ud   r66.0<1;1,0>:ud  {I@1}
        add3 (8|M24)             r15.0<1>:ud   -acc0.0<1;0>:ud   r4.0<0;0>:uw      -r21.0<1>:ud    
(f0.0)  cmp (16|M0)   (eq)f0.0   null<1>:d     r12.0<1;1,0>:d    0:w              
(f1.0)  cmp (16|M16)  (eq)f1.0   null<1>:d     r14.0<1;1,0>:d    0:w               {I@2}
        cmp (16|M16)  (gt)f0.0   null<1>:d     r14.0<1;1,0>:ud   0x0:uw             
(f1.0)  sel (16|M16)             acc0.0<1>:uw  r5.0<0;1,0>:uw    0x0:uw              {F@1}
(f0.0)  sel (16|M16)             acc2.0<1>:uw  r5.0<0;1,0>:uw    0x0:uw             
(~f0.0) cmp (16|M0)   (gt)f0.0   null<1>:d     r12.0<1;1,0>:ud   0x0:uw             
        or (16|M16)   (ne)f0.0   null<1>:uw    acc2.0<1;1,0>:uw  acc0.0<1;1,0>:uw
(f0.0)  goto (32|M0)                         L4184                  L4184                
L4088:
        add3 (16|M0)             r4.0<1>:d     r52.0<1;0>:d      -r30.0<1;0>:d     104:w              
        add3 (16|M16)            r12.0<1>:d    r68.0<1;0>:d      -r60.0<1;0>:d     104:w              
        mov (16|M0)              r18.0<1>:d    0:w                              
        mov (16|M16)             r76.0<1>:d    0:w                              
        shl (16|M0)              r30.0<1>:d    r46.0<1;1,0>:d    r4.0<1;1,0>:d    {Compacted,I@4}
        shl (16|M16)             r78.0<1>:d    r44.0<1;1,0>:d    r12.0<1;1,0>:d   {Compacted,I@4}
        goto (32|M0)                         L4184                  L6872                
L4184:
        join (32|M0)                         L6872                                
L4200:
        add3 (16|M0)             r50.0<1>:d    r30.0<1;0>:d      -r52.0<1;0>:d     -104:w               {I@4}
        add3 (16|M16)            r6.0<1>:d     r60.0<1;0>:d      -r68.0<1;0>:d     -104:w              
        cmp (16|M0)   (lt)f1.0   null<1>:d     r50.0<1;1,0>:d    2:w               {Compacted,I@2}
        cmp (16|M16)  (lt)f1.0   null<1>:d     r6.0<1;1,0>:d     2:w               {I@2}
(f1.0)  goto (32|M0)                         L4424                  L4424                
L4272:
        cmp (16|M0)   (eq)f0.0   null<1>:d     r50.0<1;1,0>:d    2:w               {Compacted}
        cmp (16|M16)  (eq)f0.0   null<1>:d     r6.0<1;1,0>:d     2:w              
(~f0.0) goto (32|M0)                         L4424                  L4488                
L4312:
        shr (16|M0)              r18.0<1>:ud   r46.0<1;1,0>:ud   1:w              
        shr (16|M16)             r52.0<1>:ud   r44.0<1;1,0>:ud   1:w              
        and (16|M0)              r56.0<1>:d    r46.0<1;1,0>:d    1:w               {Compacted}
        and (16|M16)             r68.0<1>:d    r44.0<1;1,0>:d    1:w               {Compacted}
        mov (16|M0)              r34.0<1>:d    0:w                              
        mov (16|M16)             r70.0<1>:d    0:w                              
        mov (16|M0)              r30.0<1>:f    r18.0<1;1,0>:f                   {Compacted,I@6}
        mov (16|M16)             r58.0<1>:f    r52.0<1;1,0>:f                   {Compacted,I@5}
        goto (32|M0)                         L4424                  L6000                
L4424:
        join (32|M0)                         L4488                                
L4440:
        cmp (16|M0)   (eq)f1.0   null<1>:d     r50.0<1;1,0>:d    1:w              
        cmp (16|M16)  (eq)f1.0   null<1>:d     r6.0<1;1,0>:d     1:w              
(f1.0)  goto (32|M0)                         L4488                  L5904                
L4488:
        join (32|M0)                         L5904                                
L4504:
        add3 (16|M0)             r4.0<1>:d     r30.0<1;0>:d      -r34.0<1;0>:d     -1:w               {A@2}
        add3 (16|M16)            r12.0<1>:d    r60.0<1;0>:d      -r66.0<1;0>:d     -1:w              
        and (16|M0)   (ne)f0.0   r14.0<1>:d    r4.0<1;1,0>:d     63:w               {Compacted,I@2}
        and (16|M16)  (ne)f0.0   r2.0<1>:d     r12.0<1;1,0>:d    63:w               {I@2}
(f0.0)  goto (32|M0)                         L4616                  L4616                
L4576:
        mov (16|M0)              r72.0<1>:f    r46.0<1;1,0>:f                   {Compacted}
        mov (16|M16)             r74.0<1>:d    r44.0<1;1,0>:d                  
        goto (32|M0)                         L4616                  L4880                
L4616:
        join (32|M0)                         L4880                                
L4632:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r14.0<1;1,0>:ud   0x20:uw              {I@6}
        cmp (16|M16)  (lt)f1.0   null<1>:d     r2.0<1;1,0>:ud    0x20:uw              {I@6}
(f1.0)  goto (32|M0)                         L4744                  L4744                
L4680:
        add (16|M0)              r4.0<1>:d     r14.0<1;1,0>:d    -32:w               {Compacted}
        add (16|M16)             r12.0<1>:d    r2.0<1;1,0>:d     -32:w               {Compacted}
        shr (16|M0)              r18.0<1>:ud   r42.0<1;1,0>:ud   r4.0<1;1,0>:d    {I@2}
        shr (16|M16)             r52.0<1>:ud   r40.0<1;1,0>:ud   r12.0<1;1,0>:d   {A@2}
        goto (32|M0)                         L4744                  L4840                
L4744:
        join (32|M0)                         L4840                                
L4760:
        add (16|M0)              r4.0<1>:d     -r14.0<1;1,0>:d   32:w               {Compacted}
        add (16|M16)             r12.0<1>:d    -r2.0<1;1,0>:d    32:w               {Compacted}
        shr (16|M16)             r16.0<1>:ud   r44.0<1;1,0>:ud   r2.0<1;1,0>:d   
        shl (16|M0)              r4.0<1>:d     r42.0<1;1,0>:d    r4.0<1;1,0>:d    {Compacted,I@3}
        shr (16|M0)              r14.0<1>:ud   r46.0<1;1,0>:ud   r14.0<1;1,0>:d  
        shl (16|M16)             r12.0<1>:d    r40.0<1;1,0>:d    r12.0<1;1,0>:d   {Compacted,I@4}
        or (16|M0)               r18.0<1>:d    r14.0<1;1,0>:d    r4.0<1;1,0>:d    {Compacted,I@2}
        or (16|M16)              r52.0<1>:d    r16.0<1;1,0>:d    r12.0<1;1,0>:d   {Compacted,I@2}
L4840:
        join (32|M0)                         L4880                                
L4856:
        mov (16|M0)              r72.0<1>:f    r18.0<1;1,0>:f                   {Compacted,I@3}
        mov (16|M16)             r74.0<1>:d    r52.0<1;1,0>:d                   {I@2}
L4880:
        join (32|M0)                         L5904                                
L4896:
        add3 (16|M0)             r20.0<1>:d    r30.0<1;0>:d      -r34.0<1;0>:d     -2:w              
        add3 (16|M16)            r60.0<1>:d    r60.0<1;0>:d      -r66.0<1;0>:d     -2:w              
        and (16|M0)   (ne)f0.0   r14.0<1>:d    r20.0<1;1,0>:d    63:w               {Compacted,I@2}
        and (16|M16)  (ne)f0.0   r2.0<1>:d     r60.0<1;1,0>:d    63:w               {I@2}
(f0.0)  goto (32|M0)                         L5008                  L5008                
L4968:
        mov (16|M0)              r18.0<1>:f    r46.0<1;1,0>:f                   {Compacted}
        mov (16|M16)             r52.0<1>:d    r44.0<1;1,0>:d                  
        goto (32|M0)                         L5008                  L5232                
L5008:
        join (32|M0)                         L5232                                
L5024:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r14.0<1;1,0>:ud   0x20:uw              {I@6}
        cmp (16|M16)  (lt)f1.0   null<1>:d     r2.0<1;1,0>:ud    0x20:uw              {I@6}
(f1.0)  goto (32|M0)                         L5136                  L5136                
L5072:
        add (16|M0)              r4.0<1>:d     r14.0<1;1,0>:d    -32:w               {Compacted}
        add (16|M16)             r12.0<1>:d    r2.0<1;1,0>:d     -32:w               {Compacted}
        shr (16|M0)              r18.0<1>:ud   r42.0<1;1,0>:ud   r4.0<1;1,0>:d    {A@1}
        shr (16|M16)             r52.0<1>:ud   r40.0<1;1,0>:ud   r12.0<1;1,0>:d   {I@2}
        goto (32|M0)                         L5136                  L5232                
L5136:
        join (32|M0)                         L5232                                
L5152:
        add (16|M0)              r4.0<1>:d     -r14.0<1;1,0>:d   32:w               {Compacted}
        add (16|M16)             r12.0<1>:d    -r2.0<1;1,0>:d    32:w               {Compacted}
        shr (16|M16)             r16.0<1>:ud   r44.0<1;1,0>:ud   r2.0<1;1,0>:d   
        shl (16|M0)              r4.0<1>:d     r42.0<1;1,0>:d    r4.0<1;1,0>:d    {Compacted,I@3}
        shr (16|M0)              r14.0<1>:ud   r46.0<1;1,0>:ud   r14.0<1;1,0>:d  
        shl (16|M16)             r12.0<1>:d    r40.0<1;1,0>:d    r12.0<1;1,0>:d   {Compacted,I@4}
        or (16|M0)               r18.0<1>:d    r14.0<1;1,0>:d    r4.0<1;1,0>:d    {Compacted,I@2}
        or (16|M16)              r52.0<1>:d    r16.0<1;1,0>:d    r12.0<1;1,0>:d   {Compacted,I@2}
L5232:
        join (32|M0)                         L5904                                
L5248:
        and (16|M0)   (ne)f0.0   r4.0<1>:d     r20.0<1;1,0>:d    63:w               {Compacted}
        and (16|M16)  (ne)f0.0   r20.0<1>:d    r60.0<1;1,0>:d    63:w              
        and (16|M0)              r56.0<1>:d    r18.0<1;1,0>:d    1:w               {Compacted,I@5}
        and (16|M16)             r68.0<1>:d    r52.0<1;1,0>:d    1:w               {Compacted,I@5}
(f0.0)  goto (32|M0)                         L5384                  L5384                
L5304:
        mov (16|M0)              r4.0<1>:d     -1:w                              
        mov (16|M16)             r14.0<1>:d    -1:w                              
        mov (16|M0)              r18.0<1>:d    -1:w                              
        mov (16|M16)             r16.0<1>:d    -1:w                              
        goto (32|M0)                         L5384                  L5656                
L5384:
        join (32|M0)                         L5656                                
L5400:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r4.0<1;1,0>:ud    0x20:uw              {I@6}
        cmp (16|M16)  (lt)f1.0   null<1>:d     r20.0<1;1,0>:ud   0x20:uw             
(f1.0)  goto (32|M0)                         L5560                  L5560                
L5448:
        add (16|M0)              r4.0<1>:d     r4.0<1;1,0>:d     -32:w               {Compacted}
        add (16|M16)             r12.0<1>:d    r20.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r3.0<1>:hf    -qnan(0x1FF):hf                             
        mov (16|M16)             r14.0<1>:d    0:w                              
        shl (16|M0)              r18.0<1>:d    r3.0<0;1,0>:w     r4.0<1;1,0>:d    {A@1}
        shl (16|M16)             r16.0<1>:d    r3.0<0;1,0>:w     r12.0<1;1,0>:d   {I@3}
        mov (16|M0)              r4.0<1>:d     0:w                              
        goto (32|M0)                         L5560                  L5656                
L5560:
        join (32|M0)                         L5656                                
L5576:
(W)     mov (1|M0)               r3.0<1>:hf    -qnan(0x1FF):hf                              {I@4}
        mov (16|M0)              r18.0<1>:d    -1:w                              
        mov (16|M16)             r16.0<1>:d    -1:w                              
        shl (16|M0)              r4.0<1>:d     r3.0<0;1,0>:w     r4.0<1;1,0>:d    {A@1}
        shl (16|M16)             r14.0<1>:d    r3.0<0;1,0>:w     r20.0<1;1,0>:d  
L5656:
        join (32|M0)                         L5904                                
L5672:
        bfn.0x28 (16|M0)         r4.0<1>:ud    r46.0<1;0>:ud     r4.0<1;0>:ud      r9.0<0>:ud       {I@3} // s0&(s1^s2)
        bfn.0x28 (16|M16)        r12.0<1>:ud   r44.0<1;0>:ud     r14.0<1;0>:ud     r9.0<0>:ud       {I@3} // s0&(s1^s2)
        cmp (16|M0)   (ne)f0.0   null<1>:d     r4.0<1;1,0>:d     0:w               {Compacted,I@2}
        cmp (16|M16)  (ne)f0.0   null<1>:d     r12.0<1;1,0>:d    0:w               {I@2}
        bfn.0x28 (16|M16)        r16.0<1>:ud   r40.0<1;0>:ud     r16.0<1;0>:ud     r9.0<0>:ud       // s0&(s1^s2)
        bfn.0x28 (16|M0)         r14.0<1>:ud   r42.0<1;0>:ud     r18.0<1;0>:ud     r9.0<0>:ud       // s0&(s1^s2)
(~f0.0) cmp (16|M16)  (ne)f0.0   null<1>:d     r16.0<1;1,0>:d    0:w               {I@2}
(~f0.0) cmp (16|M0)   (ne)f0.0   null<1>:d     r14.0<1;1,0>:d    0:w               {I@2}
(W)     mov (1|M0)               r3.0<1>:hf    -qnan(0x1FF):hf                             
        mov (16|M0)              r30.0<1>:f    r72.0<1;1,0>:f                   {Compacted}
(f0.0)  sel (16|M0)              r18.0<1>:d    r3.0<0;1,0>:w     0:w               {F@2}
(f0.0)  sel (16|M16)             r20.0<1>:d    r3.0<0;1,0>:w     0:w              
        mov (16|M16)             r58.0<1>:f    r74.0<1;1,0>:f                   {Compacted}
        mov (16|M0)              r34.0<1>:d    -r18.0<1;1,0>:d                  {I@2}
        mov (16|M16)             r70.0<1>:d    -r20.0<1;1,0>:d                  {I@2}
        goto (32|M0)                         L5904                  L6000                
L5904:
        join (32|M0)                         L6000                                
L5920:
        mov (16|M0)              r34.0<1>:d    0:w                              
        mov (16|M16)             r70.0<1>:d    0:w                              
        mov (16|M0)              r56.0<1>:d    0:w                              
        mov (16|M16)             r68.0<1>:d    0:w                              
        mov (16|M0)              r30.0<1>:f    r46.0<1;1,0>:f                   {Compacted}
        mov (16|M16)             r58.0<1>:f    r44.0<1;1,0>:f                   {Compacted}
L6000:
        join (32|M0)                         L6872                                
L6016:
        and (16|M0)   (ne)f0.0   r14.0<1>:d    r50.0<1;1,0>:d    63:w               {Compacted}
        and (16|M16)  (ne)f0.0   r2.0<1>:d     r6.0<1;1,0>:d     63:w              
(f0.0)  goto (32|M0)                         L6096                  L6096                
L6056:
        mov (16|M0)              r18.0<1>:f    r46.0<1;1,0>:f                   {Compacted}
        mov (16|M16)             r52.0<1>:d    r44.0<1;1,0>:d                  
        goto (32|M0)                         L6096                  L6320                
L6096:
        join (32|M0)                         L6320                                
L6112:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r14.0<1;1,0>:ud   0x20:uw              {I@6}
        cmp (16|M16)  (lt)f1.0   null<1>:d     r2.0<1;1,0>:ud    0x20:uw              {I@6}
(f1.0)  goto (32|M0)                         L6224                  L6224                
L6160:
        add (16|M0)              r4.0<1>:d     r14.0<1;1,0>:d    -32:w               {Compacted}
        add (16|M16)             r12.0<1>:d    r2.0<1;1,0>:d     -32:w               {Compacted}
        shr (16|M0)              r18.0<1>:ud   r42.0<1;1,0>:ud   r4.0<1;1,0>:d    {A@1}
        shr (16|M16)             r52.0<1>:ud   r40.0<1;1,0>:ud   r12.0<1;1,0>:d   {I@2}
        goto (32|M0)                         L6224                  L6320                
L6224:
        join (32|M0)                         L6320                                
L6240:
        add (16|M0)              r4.0<1>:d     -r14.0<1;1,0>:d   32:w               {Compacted}
        add (16|M16)             r12.0<1>:d    -r2.0<1;1,0>:d    32:w               {Compacted}
        shr (16|M16)             r16.0<1>:ud   r44.0<1;1,0>:ud   r2.0<1;1,0>:d   
        shl (16|M0)              r4.0<1>:d     r42.0<1;1,0>:d    r4.0<1;1,0>:d    {Compacted,I@3}
        shr (16|M0)              r14.0<1>:ud   r46.0<1;1,0>:ud   r14.0<1;1,0>:d  
        shl (16|M16)             r12.0<1>:d    r40.0<1;1,0>:d    r12.0<1;1,0>:d   {Compacted,I@4}
        or (16|M0)               r18.0<1>:d    r14.0<1;1,0>:d    r4.0<1;1,0>:d    {Compacted,I@2}
        or (16|M16)              r52.0<1>:d    r16.0<1;1,0>:d    r12.0<1;1,0>:d   {Compacted,I@2}
L6320:
        join (32|M0)                         L6872                                
L6336:
        shl (16|M0)              r4.0<1>:d     r30.0<1;1,0>:d    2:w               {Compacted}
        shl (16|M16)             r12.0<1>:d    r58.0<1;1,0>:d    2:w               {Compacted}
        shl (16|M0)              r14.0<1>:d    r56.0<1;1,0>:d    1:w               {Compacted}
        shl (16|M16)             r16.0<1>:d    r68.0<1;1,0>:d    1:w               {Compacted}
        and (16|M0)              r4.0<1>:d     r4.0<1;1,0>:d     4:w               {Compacted,I@4}
        and (16|M16)             r12.0<1>:d    r12.0<1;1,0>:d    4:w               {Compacted,I@4}
        bfn.0xFE (16|M0)         r14.0<1>:ud   r4.0<1;0>:ud      r14.0<1;0>:ud     r34.0<1>:ud      {I@2} // s0|s1|s2
        bfn.0xFE (16|M16)        r4.0<1>:ud    r12.0<1;0>:ud     r16.0<1;0>:ud     r70.0<1>:ud      {I@2} // s0|s1|s2
        cmp (16|M0)   (eq)f0.0   null<1>:d     r14.0<1;1,0>:d    0:w               {Compacted,I@2}
        cmp (16|M16)  (eq)f0.0   null<1>:d     r4.0<1;1,0>:d     0:w               {I@2}
(~f0.0) goto (32|M0)                         L6504                  L6504                
L6456:
        mov (16|M0)              r12.0<1>:d    0:w                              
        mov (16|M16)             r6.0<1>:d     0:w                              
        goto (32|M0)                         L6504                  L6744                
L6504:
        join (32|M0)                         L6744                                
L6520:
        cmp (16|M0)   (gt)f1.0   null<1>:d     r14.0<1;1,0>:ud   0x4:uw             
        cmp (16|M16)  (gt)f1.0   null<1>:d     r4.0<1;1,0>:ud    0x4:uw             
(~f1.0) goto (32|M0)                         L6616                  L6616                
L6568:
        mov (16|M0)              r12.0<1>:d    1:w                              
        mov (16|M16)             r6.0<1>:d     1:w                              
        goto (32|M0)                         L6616                  L6744                
L6616:
        join (32|M0)                         L6744                                
L6632:
        and (16|M0)   (ne)f1.0   null<1>:d     r18.0<1;1,0>:d    1:w              
        and (16|M16)  (ne)f1.0   null<1>:d     r52.0<1;1,0>:d    1:w              
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r14.0<1;1,0>:d    4:w              
(f1.0)  cmp (16|M16)  (eq)f1.0   null<1>:d     r4.0<1;1,0>:d     4:w              
(W)     mov (1|M0)               r3.0<1>:hf    0x1:hf                             
(f1.0)  sel (16|M0)              r12.0<1>:d    r3.0<0;1,0>:w     0:w               {F@1}
(f1.0)  sel (16|M16)             r6.0<1>:d     r3.0<0;1,0>:w     0:w              
L6744:
        join (32|M0)                         L6872                                
L6760:
        add (16|M0)              r4.0<1>:d     r12.0<1;1,0>:d    r18.0<1;1,0>:d   {Compacted,I@3}
        add (16|M16)             r12.0<1>:d    r6.0<1;1,0>:d     r52.0<1;1,0>:d   {Compacted,I@3}
        cmp (16|M0)   (gt)f0.0   null<1>:d     r4.0<1;1,0>:ud    0x7FFFFF:ud              {I@2}
        cmp (16|M16)  (gt)f0.0   null<1>:d     r12.0<1;1,0>:ud   0x7FFFFF:ud              {I@2}
(W)     mov (1|M0)               r3.0<1>:f     0x800000:f                               {Compacted}
(~f0.0) sel (16|M0)              r30.0<1>:d    r4.0<1;1,0>:d     0:w              
(~f0.0) sel (16|M16)             r78.0<1>:d    r12.0<1;1,0>:d    0:w              
(f0.0)  sel (16|M0)              r18.0<1>:d    r3.0<0;1,0>:d     0:w               {Compacted,F@1}
(f0.0)  sel (16|M16)             r76.0<1>:d    r3.0<0;1,0>:d     0:w              
L6872:
        join (32|M0)                         L6968                                
L6888:
        and (16|M0)              r4.0<1>:d     r22.0<1;1,0>:d    -2147483648:d              
        and (16|M16)             r12.0<1>:d    r26.0<1;1,0>:d    -2147483648:d              
        bfn.0xFE (16|M0)         r22.0<1>:ud   r4.0<1;0>:ud      r18.0<1;0>:ud     r30.0<1>:ud      {I@2} // s0|s1|s2
        bfn.0xFE (16|M16)        r28.0<1>:ud   r12.0<1;0>:ud     r76.0<1;0>:ud     r78.0<1>:ud      {I@2} // s0|s1|s2
        goto (32|M0)                         L6968                  L12112                
L6968:
        join (32|M0)                         L7720                                
L6984:
        and (16|M0)   (ne)f0.0   r4.0<1>:d     r56.0<1;1,0>:d    63:w               {Compacted}
        and (16|M16)  (ne)f0.0   r16.0<1>:d    r54.0<1;1,0>:d    63:w              
(f0.0)  goto (32|M0)                         L7104                  L7104                
L7024:
        mov (16|M0)              r4.0<1>:d     -1:w                              
        mov (16|M16)             r14.0<1>:d    -1:w                              
        mov (16|M0)              r20.0<1>:d    -1:w                              
        mov (16|M16)             r6.0<1>:d     -1:w                              
        goto (32|M0)                         L7104                  L7376                
L7104:
        join (32|M0)                         L7376                                
L7120:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r4.0<1;1,0>:ud    0x20:uw              {I@6}
        cmp (16|M16)  (lt)f1.0   null<1>:d     r16.0<1;1,0>:ud   0x20:uw             
(f1.0)  goto (32|M0)                         L7280                  L7280                
L7168:
        add (16|M0)              r4.0<1>:d     r4.0<1;1,0>:d     -32:w               {Compacted}
        add (16|M16)             r12.0<1>:d    r16.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r3.0<1>:hf    -qnan(0x1FF):hf                             
        mov (16|M16)             r14.0<1>:d    0:w                              
        shl (16|M0)              r20.0<1>:d    r3.0<0;1,0>:w     r4.0<1;1,0>:d    {A@1}
        shl (16|M16)             r6.0<1>:d     r3.0<0;1,0>:w     r12.0<1;1,0>:d   {I@3}
        mov (16|M0)              r4.0<1>:d     0:w                              
        goto (32|M0)                         L7280                  L7376                
L7280:
        join (32|M0)                         L7376                                
L7296:
(W)     mov (1|M0)               r3.0<1>:hf    -qnan(0x1FF):hf                              {I@4}
        mov (16|M0)              r20.0<1>:d    -1:w                              
        mov (16|M16)             r6.0<1>:d     -1:w                              
        shl (16|M0)              r4.0<1>:d     r3.0<0;1,0>:w     r4.0<1;1,0>:d    {A@1}
        shl (16|M16)             r14.0<1>:d    r3.0<0;1,0>:w     r16.0<1;1,0>:d  
L7376:
        join (32|M0)                         L7720                                
L7392:
        bfn.0x28 (16|M0)         r4.0<1>:ud    r46.0<1;0>:ud     r4.0<1;0>:ud      r9.0<0>:ud       {I@3} // s0&(s1^s2)
        bfn.0x28 (16|M16)        r12.0<1>:ud   r44.0<1;0>:ud     r14.0<1;0>:ud     r9.0<0>:ud       {I@3} // s0&(s1^s2)
        cmp (16|M0)   (ne)f0.0   null<1>:d     r4.0<1;1,0>:d     0:w               {Compacted,I@2}
        cmp (16|M16)  (ne)f0.0   null<1>:d     r12.0<1;1,0>:d    0:w               {I@2}
        bfn.0x28 (16|M16)        r16.0<1>:ud   r40.0<1;0>:ud     r6.0<1;0>:ud      r9.0<0>:ud       // s0&(s1^s2)
        bfn.0x28 (16|M0)         r14.0<1>:ud   r42.0<1;0>:ud     r20.0<1;0>:ud     r9.0<0>:ud       // s0&(s1^s2)
        cmp (16|M0)   (gt)f1.0   null<1>:d     r22.0<1;1,0>:d    -1:w              
        cmp (16|M16)  (gt)f1.0   null<1>:d     r26.0<1;1,0>:d    -1:w              
(~f0.0) cmp (16|M16)  (ne)f0.0   null<1>:d     r16.0<1;1,0>:d    0:w               {I@4}
(~f0.0) cmp (16|M0)   (ne)f0.0   null<1>:d     r14.0<1;1,0>:d    0:w               {I@4}
(f0.0)  cmp (16|M16)  (eq)f0.0   null<1>:d     r64.0<1;1,0>:d    -150:w              
(f0.0)  cmp (16|M0)   (eq)f0.0   null<1>:d     r18.0<1;1,0>:d    -150:w              
(f1.0)  goto (32|M0)                         L7648                  L7648                
L7592:
(W)     mov (1|M0)               r3.0<1>:ud    0x80000001:ud                             
(f0.0)  sel (16|M0)              r22.0<1>:f    r3.0<0;1,0>:f     -0.0:f               {Compacted,I@1}
(f0.0)  sel (16|M16)             r28.0<1>:f    r3.0<0;1,0>:f     -0.0:f              
        goto (32|M0)                         L7648                  L12112                
L7648:
        join (32|M0)                         L7720                                
L7664:
(W)     mov (1|M0)               r3.0<1>:ud    0x1:ud                              {F@1}
(f0.0)  sel (16|M0)              r22.0<1>:f    r3.0<0;1,0>:f     0.0:f               {Compacted,I@1}
(f0.0)  sel (16|M16)             r28.0<1>:f    r3.0<0;1,0>:f     0.0:f              
        goto (32|M0)                         L7720                  L12112                
L7720:
        join (32|M0)                         L11800                                
L7736:
        cmp (16|M16)  (lt)f0.0   null<1>:d     r54.0<1;1,0>:ud   0x18:uw              {F@1}
        cmp (16|M16)  (eq)f1.0   null<1>:d     r80.0<1;1,0>:d    0:w              
        cmp (16|M0)   (lt)f1.0   null<1>:d     r56.0<1;1,0>:ud   0x18:uw             
(W)     mov (1|M0)               r3.0<1>:hf    0x1:hf                             
        add3 (16|M0)             r66.0<1>:d    r50.0<1;0>:d      r56.0<1;0>:d      81:w              
(f1.0)  sel (16|M16)             acc0.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw              {F@1}
(f0.0)  sel (16|M16)             acc2.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw             
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r72.0<1;1,0>:d    0:w              
        and (16|M16)  (ne)f1.0   null<1>:uw    acc0.0<1;1,0>:uw  acc2.0<1;1,0>:uw
        add3 (16|M16)            r68.0<1>:d    r48.0<1;0>:d      r54.0<1;0>:d      81:w              
(f1.0)  goto (32|M0)                         L11344                  L11344                
L7912:
        shl (16|M16)             r12.0<1>:d    r32.0<1;1,0>:d    1:w               {Compacted}
        shl (16|M0)              r4.0<1>:d     r34.0<1;1,0>:d    1:w               {Compacted}
        shr (16|M16)             r16.0<1>:ud   r32.0<1;1,0>:ud   31:w              
        shl (16|M16)             r20.0<1>:d    r24.0<1;1,0>:d    1:w               {Compacted}
        cmp (16|M16)  (lt)f0.0   null<1>:d     r12.0<1;1,0>:ud   0x4E:uw              {I@4}
        shr (16|M0)              r14.0<1>:ud   r34.0<1;1,0>:ud   31:w              
        shl (16|M0)              r18.0<1>:d    r30.0<1;1,0>:d    1:w               {Compacted}
        cmp (16|M0)   (lt)f1.0   null<1>:d     r4.0<1;1,0>:ud    0x4E:uw              {I@6}
        or (16|M16)              r20.0<1>:d    r20.0<1;1,0>:d    r16.0<1;1,0>:d   {Compacted,I@5}
        or (16|M0)               r18.0<1>:d    r18.0<1;1,0>:d    r14.0<1;1,0>:d   {Compacted,I@3}
(f0.0)  cmp (16|M16)  (eq)f0.0   null<1>:d     r20.0<1;1,0>:d    0:w               {I@2}
        cmp (16|M16)  (lt)f1.0   null<1>:d     r20.0<1;1,0>:d    0:w              
(W)     mov (1|M0)               r3.0<1>:hf    0x1:hf                             
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r18.0<1;1,0>:d    0:w               {I@3}
(f1.0)  sel (16|M16)             acc0.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw              {F@1}
(f0.0)  sel (16|M16)             acc2.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw             
(~f1.0) cmp (16|M0)   (lt)f1.0   null<1>:d     r18.0<1;1,0>:d    0:w              
        or (16|M16)   (ne)f1.0   null<1>:uw    acc0.0<1;1,0>:uw  acc2.0<1;1,0>:uw
(f1.0)  goto (32|M0)                         L8448                  L8448                
L8168:
        cmp (16|M16)  (eq)f1.0   null<1>:d     r32.0<1;1,0>:d    39:w              
        cmp (16|M16)  (eq)f0.0   null<1>:d     r24.0<1;1,0>:d    0:w              
        cmp (16|M0)   (eq)f0.0   null<1>:d     r34.0<1;1,0>:d    39:w               {Compacted}
(W)     mov (1|M0)               r3.0<1>:hf    0x1:hf                              {I@7}
(f0.0)  sel (16|M16)             acc0.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw              {F@1}
(f1.0)  sel (16|M16)             acc2.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw             
(f0.0)  cmp (16|M0)   (eq)f0.0   null<1>:d     r30.0<1;1,0>:d    0:w              
        and (16|M16)  (ne)f0.0   null<1>:uw    acc0.0<1;1,0>:uw  acc2.0<1;1,0>:uw
(~f0.0) goto (32|M0)                         L8448                  L8608                
L8304:
        shr (16|M0)              r18.0<1>:ud   r46.0<1;1,0>:ud   1:w              
        shr (16|M16)             r52.0<1>:ud   r44.0<1;1,0>:ud   1:w              
        mov (16|M0)              r34.0<1>:d    0:w                              
        mov (16|M16)             r60.0<1>:d    0:w                              
        mov (16|M0)              r30.0<1>:d    0:w                              
        mov (16|M16)             r58.0<1>:d    0:w                              
        mov (16|M0)              r42.0<1>:f    r18.0<1;1,0>:f                   {Compacted,I@6}
        mov (16|M16)             r6.0<1>:f     r52.0<1;1,0>:f                   {Compacted,I@5}
        mov (16|M0)              r18.0<1>:f    r46.0<1;1,0>:f                   {Compacted}
        mov (16|M16)             r52.0<1>:f    r44.0<1;1,0>:f                   {Compacted}
        goto (32|M0)                         L8448                  L10504                
L8448:
        join (32|M0)                         L8608                                
L8464:
        cmp (16|M16)  (eq)f0.0   null<1>:d     r32.0<1;1,0>:d    38:w              
        cmp (16|M16)  (eq)f1.0   null<1>:d     r24.0<1;1,0>:d    0:w              
        cmp (16|M0)   (eq)f1.0   null<1>:d     r34.0<1;1,0>:d    38:w               {I@7}
(W)     mov (1|M0)               r3.0<1>:hf    0x1:hf                             
(f1.0)  sel (16|M16)             acc0.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw              {F@1}
(f0.0)  sel (16|M16)             acc2.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw             
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r30.0<1;1,0>:d    0:w               {I@7}
        and (16|M16)  (ne)f1.0   null<1>:uw    acc0.0<1;1,0>:uw  acc2.0<1;1,0>:uw
(f1.0)  goto (32|M0)                         L8608                  L10360                
L8608:
        join (32|M0)                         L10360                                
L8624:
        add (16|M0)              r4.0<1>:d     -r34.0<1;1,0>:d   39:w               {Compacted}
        add (16|M16)             r12.0<1>:d    -r32.0<1;1,0>:d   39:w               {Compacted}
        and (16|M0)   (ne)f0.0   r14.0<1>:d    r4.0<1;1,0>:d     63:w               {Compacted,I@2}
        and (16|M16)  (ne)f0.0   r2.0<1>:d     r12.0<1;1,0>:d    63:w               {I@2}
        add (16|M0)              r70.0<1>:d    -r34.0<1;1,0>:d   40:w               {Compacted}
        add (16|M16)             r72.0<1>:d    -r32.0<1;1,0>:d   40:w               {Compacted}
(f0.0)  goto (32|M0)                         L8736                  L8736                
L8696:
        mov (16|M0)              r24.0<1>:f    r46.0<1;1,0>:f                   {Compacted}
        mov (16|M16)             r64.0<1>:d    r44.0<1;1,0>:d                  
        goto (32|M0)                         L8736                  L9000                
L8736:
        join (32|M0)                         L9000                                
L8752:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r14.0<1;1,0>:ud   0x20:uw              {I@7}
        cmp (16|M16)  (lt)f1.0   null<1>:d     r2.0<1;1,0>:ud    0x20:uw              {I@7}
(f1.0)  goto (32|M0)                         L8864                  L8864                
L8800:
        add (16|M0)              r4.0<1>:d     r14.0<1;1,0>:d    -32:w               {Compacted}
        add (16|M16)             r12.0<1>:d    r2.0<1;1,0>:d     -32:w               {Compacted}
        shr (16|M0)              r18.0<1>:ud   r42.0<1;1,0>:ud   r4.0<1;1,0>:d    {I@2}
        shr (16|M16)             r52.0<1>:ud   r40.0<1;1,0>:ud   r12.0<1;1,0>:d   {I@2}
        goto (32|M0)                         L8864                  L8960                
L8864:
        join (32|M0)                         L8960                                
L8880:
        add (16|M0)              r4.0<1>:d     -r14.0<1;1,0>:d   32:w               {Compacted}
        add (16|M16)             r12.0<1>:d    -r2.0<1;1,0>:d    32:w               {Compacted}
        shr (16|M16)             r16.0<1>:ud   r44.0<1;1,0>:ud   r2.0<1;1,0>:d   
        shl (16|M0)              r4.0<1>:d     r42.0<1;1,0>:d    r4.0<1;1,0>:d    {Compacted,I@3}
        shr (16|M0)              r14.0<1>:ud   r46.0<1;1,0>:ud   r14.0<1;1,0>:d  
        shl (16|M16)             r12.0<1>:d    r40.0<1;1,0>:d    r12.0<1;1,0>:d   {Compacted,I@4}
        or (16|M0)               r18.0<1>:d    r14.0<1;1,0>:d    r4.0<1;1,0>:d    {Compacted,I@2}
        or (16|M16)              r52.0<1>:d    r16.0<1;1,0>:d    r12.0<1;1,0>:d   {Compacted,I@2}
L8960:
        join (32|M0)                         L9000                                
L8976:
        mov (16|M0)              r24.0<1>:f    r18.0<1;1,0>:f                   {Compacted,I@3}
        mov (16|M16)             r64.0<1>:d    r52.0<1;1,0>:d                   {I@2}
L9000:
        join (32|M0)                         L10360                                
L9016:
        add (16|M0)              r20.0<1>:d    -r34.0<1;1,0>:d   38:w               {Compacted}
        add (16|M16)             r2.0<1>:d     -r32.0<1;1,0>:d   38:w               {Compacted}
        and (16|M0)   (ne)f0.0   r14.0<1>:d    r20.0<1;1,0>:d    63:w               {Compacted,I@2}
        and (16|M16)  (ne)f0.0   r16.0<1>:d    r2.0<1;1,0>:d     63:w               {I@2}
(f0.0)  goto (32|M0)                         L9112                  L9112                
L9072:
        mov (16|M0)              r18.0<1>:f    r46.0<1;1,0>:f                   {Compacted}
        mov (16|M16)             r52.0<1>:d    r44.0<1;1,0>:d                  
        goto (32|M0)                         L9112                  L9336                
L9112:
        join (32|M0)                         L9336                                
L9128:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r14.0<1;1,0>:ud   0x20:uw              {I@6}
        cmp (16|M16)  (lt)f1.0   null<1>:d     r16.0<1;1,0>:ud   0x20:uw              {I@6}
(f1.0)  goto (32|M0)                         L9240                  L9240                
L9176:
        add (16|M0)              r4.0<1>:d     r14.0<1;1,0>:d    -32:w               {Compacted}
        add (16|M16)             r12.0<1>:d    r16.0<1;1,0>:d    -32:w               {Compacted}
        shr (16|M0)              r18.0<1>:ud   r42.0<1;1,0>:ud   r4.0<1;1,0>:d    {A@1}
        shr (16|M16)             r52.0<1>:ud   r40.0<1;1,0>:ud   r12.0<1;1,0>:d   {I@2}
        goto (32|M0)                         L9240                  L9336                
L9240:
        join (32|M0)                         L9336                                
L9256:
        add (16|M0)              r4.0<1>:d     -r14.0<1;1,0>:d   32:w               {Compacted}
        add (16|M16)             r12.0<1>:d    -r16.0<1;1,0>:d   32:w               {Compacted}
        shl (16|M0)              r4.0<1>:d     r42.0<1;1,0>:d    r4.0<1;1,0>:d    {Compacted,I@2}
        shr (16|M0)              r14.0<1>:ud   r46.0<1;1,0>:ud   r14.0<1;1,0>:d  
        shl (16|M16)             r12.0<1>:d    r40.0<1;1,0>:d    r12.0<1;1,0>:d   {Compacted,I@3}
        shr (16|M16)             r16.0<1>:ud   r44.0<1;1,0>:ud   r16.0<1;1,0>:d  
        or (16|M0)               r18.0<1>:d    r14.0<1;1,0>:d    r4.0<1;1,0>:d    {Compacted,I@3}
        or (16|M16)              r52.0<1>:d    r16.0<1;1,0>:d    r12.0<1;1,0>:d   {Compacted,I@2}
L9336:
        join (32|M0)                         L10360                                
L9352:
        and (16|M0)   (ne)f0.0   r4.0<1>:d     r20.0<1;1,0>:d    63:w               {Compacted}
        and (16|M16)  (ne)f0.0   r20.0<1>:d    r2.0<1;1,0>:d     63:w              
        and (16|M0)              r30.0<1>:d    r18.0<1;1,0>:d    1:w               {Compacted,I@5}
        and (16|M16)             r58.0<1>:d    r52.0<1;1,0>:d    1:w               {Compacted,I@5}
(f0.0)  goto (32|M0)                         L9488                  L9488                
L9408:
        mov (16|M0)              r4.0<1>:d     -1:w                              
        mov (16|M16)             r14.0<1>:d    -1:w                              
        mov (16|M0)              r18.0<1>:d    -1:w                              
        mov (16|M16)             r16.0<1>:d    -1:w                              
        goto (32|M0)                         L9488                  L9760                
L9488:
        join (32|M0)                         L9760                                
L9504:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r4.0<1;1,0>:ud    0x20:uw              {I@6}
        cmp (16|M16)  (lt)f1.0   null<1>:d     r20.0<1;1,0>:ud   0x20:uw             
(f1.0)  goto (32|M0)                         L9664                  L9664                
L9552:
        add (16|M0)              r4.0<1>:d     r4.0<1;1,0>:d     -32:w               {Compacted}
        add (16|M16)             r12.0<1>:d    r20.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r3.0<1>:hf    -qnan(0x1FF):hf                             
        mov (16|M16)             r14.0<1>:d    0:w                              
        shl (16|M0)              r18.0<1>:d    r3.0<0;1,0>:w     r4.0<1;1,0>:d    {A@1}
        shl (16|M16)             r16.0<1>:d    r3.0<0;1,0>:w     r12.0<1;1,0>:d   {I@3}
        mov (16|M0)              r4.0<1>:d     0:w                              
        goto (32|M0)                         L9664                  L9760                
L9664:
        join (32|M0)                         L9760                                
L9680:
(W)     mov (1|M0)               r3.0<1>:hf    -qnan(0x1FF):hf                              {I@4}
        mov (16|M0)              r18.0<1>:d    -1:w                              
        mov (16|M16)             r16.0<1>:d    -1:w                              
        shl (16|M0)              r4.0<1>:d     r3.0<0;1,0>:w     r4.0<1;1,0>:d    {A@1}
        shl (16|M16)             r14.0<1>:d    r3.0<0;1,0>:w     r20.0<1;1,0>:d  
L9760:
        join (32|M0)                         L10360                                
L9776:
        bfn.0x28 (16|M0)         r4.0<1>:ud    r46.0<1;0>:ud     r4.0<1;0>:ud      r9.0<0>:ud       {I@3} // s0&(s1^s2)
        bfn.0x28 (16|M16)        r12.0<1>:ud   r44.0<1;0>:ud     r14.0<1;0>:ud     r9.0<0>:ud       {I@3} // s0&(s1^s2)
        cmp (16|M0)   (ne)f0.0   null<1>:d     r4.0<1;1,0>:d     0:w               {Compacted,I@2}
        cmp (16|M16)  (ne)f0.0   null<1>:d     r12.0<1;1,0>:d    0:w               {I@2}
        bfn.0x28 (16|M16)        r16.0<1>:ud   r40.0<1;0>:ud     r16.0<1;0>:ud     r9.0<0>:ud       // s0&(s1^s2)
        bfn.0x28 (16|M0)         r14.0<1>:ud   r42.0<1;0>:ud     r18.0<1;0>:ud     r9.0<0>:ud       // s0&(s1^s2)
(~f0.0) cmp (16|M16)  (ne)f0.0   null<1>:d     r16.0<1;1,0>:d    0:w               {I@2}
(~f0.0) cmp (16|M0)   (ne)f0.0   null<1>:d     r14.0<1;1,0>:d    0:w               {I@2}
(W)     mov (1|M0)               r3.0<1>:hf    -qnan(0x1FF):hf                             
(f0.0)  sel (16|M0)              r18.0<1>:d    r3.0<0;1,0>:w     0:w               {F@1}
(f0.0)  sel (16|M16)             r20.0<1>:d    r3.0<0;1,0>:w     0:w              
        and (16|M0)   (ne)f0.0   r14.0<1>:d    r70.0<1;1,0>:d    63:w               {Compacted}
        and (16|M16)  (ne)f0.0   r2.0<1>:d     r72.0<1;1,0>:d    63:w              
        mov (16|M0)              r34.0<1>:d    -r18.0<1;1,0>:d                  {I@4}
        mov (16|M16)             r60.0<1>:d    -r20.0<1;1,0>:d                  {I@4}
(f0.0)  goto (32|M0)                         L10056                  L10056                
L10016:
        mov (16|M0)              r18.0<1>:f    r46.0<1;1,0>:f                   {Compacted,I@3}
        mov (16|M16)             r52.0<1>:d    r44.0<1;1,0>:d                  
        goto (32|M0)                         L10056                  L10280                
L10056:
        join (32|M0)                         L10280                                
L10072:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r14.0<1;1,0>:ud   0x20:uw             
        cmp (16|M16)  (lt)f1.0   null<1>:d     r2.0<1;1,0>:ud    0x20:uw             
(f1.0)  goto (32|M0)                         L10184                  L10184                
L10120:
        add (16|M0)              r4.0<1>:d     r14.0<1;1,0>:d    -32:w               {Compacted}
        add (16|M16)             r12.0<1>:d    r2.0<1;1,0>:d     -32:w               {Compacted}
        shr (16|M0)              r18.0<1>:ud   r42.0<1;1,0>:ud   r4.0<1;1,0>:d    {A@1}
        shr (16|M16)             r52.0<1>:ud   r40.0<1;1,0>:ud   r12.0<1;1,0>:d   {I@2}
        goto (32|M0)                         L10184                  L10280                
L10184:
        join (32|M0)                         L10280                                
L10200:
        add (16|M0)              r4.0<1>:d     -r14.0<1;1,0>:d   32:w               {Compacted}
        add (16|M16)             r12.0<1>:d    -r2.0<1;1,0>:d    32:w               {Compacted}
        shr (16|M16)             r16.0<1>:ud   r44.0<1;1,0>:ud   r2.0<1;1,0>:d   
        shl (16|M0)              r4.0<1>:d     r42.0<1;1,0>:d    r4.0<1;1,0>:d    {Compacted,I@3}
        shr (16|M0)              r14.0<1>:ud   r46.0<1;1,0>:ud   r14.0<1;1,0>:d  
        shl (16|M16)             r12.0<1>:d    r40.0<1;1,0>:d    r12.0<1;1,0>:d   {Compacted,I@4}
        or (16|M0)               r18.0<1>:d    r14.0<1;1,0>:d    r4.0<1;1,0>:d    {Compacted,I@2}
        or (16|M16)              r52.0<1>:d    r16.0<1;1,0>:d    r12.0<1;1,0>:d   {Compacted,I@2}
L10280:
        join (32|M0)                         L10360                                
L10296:
        mov (16|M0)              r42.0<1>:f    r18.0<1;1,0>:f                   {Compacted,I@3}
        mov (16|M16)             r6.0<1>:f     r52.0<1;1,0>:f                   {Compacted,I@2}
        mov (16|M0)              r18.0<1>:d    r24.0<1;1,0>:d                   {F@2}
        mov (16|M16)             r52.0<1>:d    r64.0<1;1,0>:d                   {F@1}
        goto (32|M0)                         L10360                  L10504                
L10360:
        join (32|M0)                         L10504                                
L10376:
        shr (16|M0)              r18.0<1>:ud   r46.0<1;1,0>:ud   2:w              
        shr (16|M16)             r52.0<1>:ud   r44.0<1;1,0>:ud   2:w              
        and (16|M0)              r30.0<1>:d    r46.0<1;1,0>:d    1:w               {Compacted}
        and (16|M16)             r58.0<1>:d    r44.0<1;1,0>:d    1:w               {Compacted}
        mov (16|M0)              r34.0<1>:d    0:w                              
        mov (16|M16)             r60.0<1>:d    0:w                              
        mov (16|M0)              r42.0<1>:f    r18.0<1;1,0>:f                   {Compacted,I@6}
        mov (16|M16)             r6.0<1>:f     r52.0<1;1,0>:f                   {Compacted,I@5}
        shr (16|M0)              r18.0<1>:ud   r46.0<1;1,0>:ud   1:w               {F@2}
        shr (16|M16)             r52.0<1>:ud   r44.0<1;1,0>:ud   1:w               {F@1}
L10504:
        join (32|M0)                         L11344                                
L10520:
        shl (16|M0)              r4.0<1>:d     r18.0<1;1,0>:d    2:w               {Compacted,I@3}
        shl (16|M16)             r12.0<1>:d    r52.0<1;1,0>:d    2:w               {Compacted,I@3}
        shl (16|M0)              r14.0<1>:d    r30.0<1;1,0>:d    1:w               {Compacted}
        shl (16|M16)             r16.0<1>:d    r58.0<1;1,0>:d    1:w               {Compacted}
        and (16|M0)              r4.0<1>:d     r4.0<1;1,0>:d     4:w               {Compacted,I@4}
        and (16|M16)             r12.0<1>:d    r12.0<1;1,0>:d    4:w               {Compacted,I@4}
        bfn.0xFE (16|M0)         r4.0<1>:ud    r4.0<1;0>:ud      r14.0<1;0>:ud     r34.0<1>:ud      {I@2} // s0|s1|s2
        bfn.0xFE (16|M16)        r14.0<1>:ud   r12.0<1;0>:ud     r16.0<1;0>:ud     r60.0<1>:ud      {I@2} // s0|s1|s2
        cmp (16|M0)   (eq)f0.0   null<1>:d     r4.0<1;1,0>:d     0:w               {Compacted,I@2}
        cmp (16|M16)  (eq)f0.0   null<1>:d     r14.0<1;1,0>:d    0:w               {I@2}
        and (16|M0)              r20.0<1>:d    r42.0<1;1,0>:d    8388607:d              
        and (16|M16)             r24.0<1>:d    r6.0<1;1,0>:d     8388607:d              
(~f0.0) goto (32|M0)                         L10720                  L10720                
L10672:
        mov (16|M0)              r4.0<1>:d     0:w                              
        mov (16|M16)             r12.0<1>:d    0:w                              
        goto (32|M0)                         L10720                  L10960                
L10720:
        join (32|M0)                         L10960                                
L10736:
        cmp (16|M0)   (gt)f1.0   null<1>:d     r4.0<1;1,0>:ud    0x4:uw              {I@4}
        cmp (16|M16)  (gt)f1.0   null<1>:d     r14.0<1;1,0>:ud   0x4:uw             
(~f1.0) goto (32|M0)                         L10832                  L10832                
L10784:
        mov (16|M0)              r4.0<1>:d     1:w                              
        mov (16|M16)             r12.0<1>:d    1:w                              
        goto (32|M0)                         L10832                  L10960                
L10832:
        join (32|M0)                         L10960                                
L10848:
        and (16|M0)   (ne)f1.0   null<1>:d     r42.0<1;1,0>:d    1:w              
        and (16|M16)  (ne)f1.0   null<1>:d     r6.0<1;1,0>:d     1:w              
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r4.0<1;1,0>:d     4:w               {I@6}
(f1.0)  cmp (16|M16)  (eq)f1.0   null<1>:d     r14.0<1;1,0>:d    4:w              
(W)     mov (1|M0)               r3.0<1>:hf    0x1:hf                             
(f1.0)  sel (16|M0)              r4.0<1>:d     r3.0<0;1,0>:w     0:w               {F@1}
(f1.0)  sel (16|M16)             r12.0<1>:d    r3.0<0;1,0>:w     0:w              
L10960:
        join (32|M0)                         L11344                                
L10976:
        add (16|M0)              r14.0<1>:d    r20.0<1;1,0>:d    r4.0<1;1,0>:d    {Compacted,I@3}
        add (16|M16)             r6.0<1>:d     r24.0<1;1,0>:d    r12.0<1;1,0>:d   {Compacted,I@3}
        cmp (16|M0)   (gt)f1.0   null<1>:d     r14.0<1;1,0>:ud   0x7FFFFF:ud              {I@2}
        cmp (16|M16)  (gt)f1.0   null<1>:d     r6.0<1;1,0>:ud    0x7FFFFF:ud              {I@2}
        add3 (16|M0)             r4.0<1>:d     r50.0<1;0>:d      r56.0<1;0>:d      82:w              
        add3 (16|M16)            r12.0<1>:d    r48.0<1;0>:d      r54.0<1;0>:d      82:w              
(f1.0)  sel (16|M0)              r18.0<1>:d    r4.0<1;1,0>:d     r66.0<1;1,0>:d   {Compacted,I@2}
(f1.0)  sel (16|M16)             r2.0<1>:d     r12.0<1;1,0>:d    r68.0<1;1,0>:d   {I@2}
        cmp (16|M0)   (eq)f0.0   null<1>:d     r18.0<1;1,0>:d    255:w               {Compacted,I@2}
        cmp (16|M16)  (eq)f0.0   null<1>:d     r2.0<1;1,0>:d     255:w               {I@2}
(f0.0)  goto (32|M0)                         L11248                  L11248                
L11120:
(~f1.0) sel (16|M0)              r4.0<1>:d     r14.0<1;1,0>:d    0:w              
(~f1.0) sel (16|M16)             r12.0<1>:d    r6.0<1;1,0>:d     0:w              
        and (16|M16)             r16.0<1>:d    r26.0<1;1,0>:d    -2147483648:d              
        shl (16|M0)              r18.0<1>:d    r18.0<1;1,0>:d    23:w               {Compacted}
        shl (16|M16)             r20.0<1>:d    r2.0<1;1,0>:d     23:w               {Compacted}
        and (16|M0)              r14.0<1>:d    r22.0<1;1,0>:d    -2147483648:d              
        bfn.0xFE (16|M16)        r28.0<1>:ud   r16.0<1;0>:ud     r20.0<1;0>:ud     r12.0<1>:ud      {I@2} // s0|s1|s2
        bfn.0xFE (16|M0)         r22.0<1>:ud   r14.0<1;0>:ud     r18.0<1;0>:ud     r4.0<1>:ud       {I@2} // s0|s1|s2
        goto (32|M0)                         L11248                  L12112                
L11248:
        join (32|M0)                         L11344                                
L11264:
        cmp (16|M0)   (gt)f1.0   null<1>:d     r22.0<1;1,0>:d    -1:w               {I@3}
        cmp (16|M16)  (gt)f1.0   null<1>:d     r26.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r3.0<1>:f     inf:f                               {Compacted}
(f1.0)  sel (16|M0)              r22.0<1>:f    r3.0<0;1,0>:f     -inf:f               {Compacted,A@1}
(f1.0)  sel (16|M16)             r28.0<1>:f    r3.0<0;1,0>:f     -inf:f              
        goto (32|M0)                         L11344                  L12112                
L11344:
        join (32|M0)                         L11800                                
L11360:
        and (16|M0)   (ne)f0.0   r12.0<1>:d    r56.0<1;1,0>:d    63:w               {Compacted}
        and (16|M16)  (ne)f0.0   r4.0<1>:d     r54.0<1;1,0>:d    63:w              
(f0.0)  goto (32|M0)                         L11448                  L11448                
L11400:
        mov (16|M0)              r12.0<1>:d    -1:w                              
        mov (16|M16)             r6.0<1>:d     -1:w                              
        goto (32|M0)                         L11448                  L11624                
L11448:
        join (32|M0)                         L11624                                
L11464:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r12.0<1;1,0>:ud   0x20:uw              {A@1}
        cmp (16|M16)  (lt)f1.0   null<1>:d     r4.0<1;1,0>:ud    0x20:uw             
(f1.0)  goto (32|M0)                         L11560                  L11560                
L11512:
        mov (16|M0)              r12.0<1>:d    0:w                              
        mov (16|M16)             r6.0<1>:d     0:w                              
        goto (32|M0)                         L11560                  L11624                
L11560:
        join (32|M0)                         L11624                                
L11576:
(W)     mov (1|M0)               r3.0<1>:hf    -qnan(0x1FF):hf                             
        shl (16|M0)              r12.0<1>:d    r3.0<0;1,0>:w     r12.0<1;1,0>:d   {A@1}
        shl (16|M16)             r6.0<1>:d     r3.0<0;1,0>:w     r4.0<1;1,0>:d   
L11624:
        join (32|M0)                         L11800                                
L11640:
        bfn.0x28 (16|M0)         r4.0<1>:ud    r46.0<1;0>:ud     r12.0<1;0>:ud     r9.0<0>:ud       {I@3} // s0&(s1^s2)
        add (16|M0)              r14.0<1>:d    -r56.0<1;1,0>:d   23:w               {Compacted}
        add (16|M16)             r16.0<1>:d    -r54.0<1;1,0>:d   23:w               {Compacted}
        bfn.0x28 (16|M16)        r12.0<1>:ud   r44.0<1;0>:ud     r6.0<1;0>:ud      r9.0<0>:ud       {I@5} // s0&(s1^s2)
        and (16|M0)              r18.0<1>:d    r22.0<1;1,0>:d    -2147483648:d              
        and (16|M16)             r20.0<1>:d    r26.0<1;1,0>:d    -2147483648:d              
        shl (16|M16)             r24.0<1>:d    r68.0<1;1,0>:d    23:w               {Compacted}
        shl (16|M0)              r4.0<1>:d     r4.0<1;1,0>:d     r14.0<1;1,0>:d   {Compacted,I@6}
        shl (16|M16)             r12.0<1>:d    r12.0<1;1,0>:d    r16.0<1;1,0>:d   {Compacted,I@5}
        shl (16|M0)              r22.0<1>:d    r66.0<1;1,0>:d    23:w               {Compacted}
        bfn.0xFE (16|M16)        r28.0<1>:ud   r20.0<1;0>:ud     r24.0<1;0>:ud     r12.0<1>:ud      {I@2} // s0|s1|s2
        bfn.0xFE (16|M0)         r22.0<1>:ud   r18.0<1;0>:ud     r22.0<1;0>:ud     r4.0<1>:ud       {I@2} // s0|s1|s2
        goto (32|M0)                         L11800                  L12112                
L11800:
        join (32|M0)                         L11888                                
L11816:
        cmp (16|M0)   (gt)f0.0   null<1>:d     r22.0<1;1,0>:d    -1:w               {Compacted,I@3}
        cmp (16|M16)  (gt)f0.0   null<1>:d     r26.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r3.0<1>:f     inf:f                               {Compacted}
(f0.0)  sel (16|M0)              r22.0<1>:f    r3.0<0;1,0>:f     -inf:f               {Compacted,A@1}
(f0.0)  sel (16|M16)             r28.0<1>:f    r3.0<0;1,0>:f     -inf:f              
        goto (32|M0)                         L11888                  L12112                
L11888:
        join (32|M0)                         L11976                                
L11904:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r22.0<1;1,0>:d    0:w               {Compacted,F@2}
        cmp (16|M16)  (lt)f1.0   null<1>:d     r26.0<1;1,0>:d    0:w              
(W)     mov (1|M0)               r3.0<1>:f     -0.0:f                               {Compacted}
(f1.0)  sel (16|M0)              r22.0<1>:f    r3.0<0;1,0>:f     0.0:f               {Compacted,A@1}
(f1.0)  sel (16|M16)             r28.0<1>:f    r3.0<0;1,0>:f     0.0:f              
        goto (32|M0)                         L11976                  L12112                
L11976:
        join (32|M0)                         L12064                                
L11992:
        cmp (16|M0)   (gt)f0.0   null<1>:d     r22.0<1;1,0>:d    -1:w               {Compacted,F@2}
        cmp (16|M16)  (gt)f0.0   null<1>:d     r26.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r3.0<1>:f     inf:f                               {Compacted}
(f0.0)  sel (16|M0)              r22.0<1>:f    r3.0<0;1,0>:f     -inf:f               {Compacted,A@1}
(f0.0)  sel (16|M16)             r28.0<1>:f    r3.0<0;1,0>:f     -inf:f              
        goto (32|M0)                         L12064                  L12112                
L12064:
        join (32|M0)                         L12112                                
L12080:
        bfn.0xF8 (16|M0)         r22.0<1>:ud   r22.0<1;0>:ud     r9.7<0;0>:ud      r9.3<0>:ud       {F@2} // s0&s1|s2
        bfn.0xF8 (16|M16)        r28.0<1>:ud   r26.0<1;0>:ud     r9.7<0;0>:ud      r9.3<0>:ud       {F@1} // s0&s1|s2
L12112:
        join (32|M0)                         L23552                                
L12128:
        shr (16|M16)             r18.0<1>:ud   r28.0<1;1,0>:ud   23:w               {I@2}
        and (16|M16)             r24.0<1>:d    r18.0<1;1,0>:d    255:w               {Compacted,I@1}
        and (16|M16)  (ne)f1.0   r14.0<1>:d    r28.0<1;1,0>:d    8388607:d              
        cmp (16|M16)  (eq)f0.0   null<1>:d     r24.0<1;1,0>:d    255:w               {I@2}
        shr (16|M0)              r20.0<1>:ud   r22.0<1;1,0>:ud   23:w              
        and (16|M0)   (ne)f0.0   r16.0<1>:d    r22.0<1;1,0>:d    8388607:d              
(W)     mov (1|M0)               r3.0<1>:hf    0x1:hf                             
        and (16|M0)              r30.0<1>:d    r20.0<1;1,0>:d    255:w               {Compacted,I@2}
(f0.0)  sel (16|M16)             acc0.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw              {F@1}
(f1.0)  sel (16|M16)             acc2.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw             
(f0.0)  cmp (16|M0)   (eq)f0.0   null<1>:d     r30.0<1;1,0>:d    255:w               {I@3}
        and (16|M16)  (ne)f0.0   null<1>:uw    acc0.0<1;1,0>:uw  acc2.0<1;1,0>:uw
(~f0.0) goto (32|M0)                         L12360                  L12360                
L12320:
        mov (16|M0)              r22.0<1>:ud   0x7FC00000:ud                             
        mov (16|M16)             r26.0<1>:f    qnan(0x0):f                               {Compacted}
        goto (32|M0)                         L12360                  L23448                
L12360:
        join (32|M0)                         L23448                                
L12376:
(W)     mov (1|M0)               a0.0<1>:ud    r10.0<0;1,0>:d                   {A@1}
(W)     shl (1|M0)               r3.0<1>:ud    r9.2<0;1,0>:d     2:w              
(W)     send.ugm (1|M0)          r4       r3      null:0  a0.0        0x22188500           {ExBSO,A@1,$8} // wr:1+0, rd:1; load.ugm.d32x1t.a32.ca.ca.bss[a0.0]
(W)     mov (1|M0)               r10.7<1>:d    r4.0<0;1,0>:d                    {$8.dst}
(W)     shr (1|M0)               r2.0<1>:ud    r10.7<0;1,0>:ud   23:w               {I@1}
(W)     and (1|M0)               r10.6<1>:d    r10.7<0;1,0>:d    8388607:d              
(W)     and (1|M0)               r10.4<1>:d    r2.0<0;1,0>:d     255:w               {Compacted,I@2}
(W)     cmp (16|M16)  (ne)f0.0   null<1>:d     r10.6<0;1,0>:d    0:w               {I@2}
(W)     cmp (16|M0)   (ne)f1.0   null<1>:d     r10.6<0;1,0>:d    0:w              
(W)     cmp (16|M16)  (eq)f1.0   null<1>:d     r10.4<0;1,0>:d    255:w               {I@3}
(W)     mov (1|M0)               r5.0<1>:uw    f0.1<0;1,0>:uw                   {Compacted}
(W&f1.0) cmp (16|M0)  (eq)f1.0   null<1>:d     r10.4<0;1,0>:d    255:w              
(W)     and (1|M16)              f1.1<1>:uw    f1.1<0;1,0>:uw    r5.0<0;1,0>:uw   {I@2}
(~f1.0) goto (32|M0)                         L12624                  L12624                
L12584:
        mov (16|M0)              r22.0<1>:ud   0x7FC00000:ud                             
        mov (16|M16)             r26.0<1>:f    qnan(0x0):f                               {Compacted}
        goto (32|M0)                         L12624                  L23448                
L12624:
        join (32|M0)                         L23448                                
L12640:
        cmp (16|M0)   (eq)f1.0   null<1>:d     r16.0<1;1,0>:d    0:w              
(W)     mov (1|M0)               r3.2<1>:hf    0x1:hf                             
        xor (16|M0)              r22.0<1>:d    r10.7<0;1,0>:d    r22.0<1;1,0>:d   {Compacted,I@4}
(W)     mov (1|M0)               r3.0<1>:ud    f1.0<0;1,0>:ud                   {Compacted}
        xor (16|M16)             r28.0<1>:d    r10.7<0;1,0>:d    r28.0<1;1,0>:d   {Compacted}
(W)     mov (1|M0)               f0.0<1>:ud    r3.0<0;1,0>:ud                   {I@2}
        cmp (16|M16)  (eq)f0.0   null<1>:d     r14.0<1;1,0>:d    0:w              
(W)     mov (1|M0)               r3.0<1>:ud    f0.0<0;1,0>:ud                   {Compacted}
(W)     mov (1|M0)               f1.0<1>:ud    r3.0<0;1,0>:ud                   {I@1}
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r30.0<1;1,0>:d    255:w              
(W)     mov (1|M0)               r3.0<1>:ud    f1.0<0;1,0>:ud                   {Compacted}
(W)     mov (1|M0)               f0.0<1>:ud    r3.0<0;1,0>:ud                   {I@1}
(f0.0)  cmp (16|M16)  (eq)f0.0   null<1>:d     r24.0<1;1,0>:d    255:w              
(W)     mov (1|M0)               r3.0<1>:ud    f0.0<0;1,0>:ud                   {Compacted}
(W)     cmp (16|M0)   (eq)f0.0   null<1>:d     r10.6<0;1,0>:d    0:w               {Compacted}
(W)     mov (1|M0)               f1.0<1>:ud    r3.0<0;1,0>:ud                   {I@2}
(W)     cmp (16|M16)  (eq)f0.0   null<1>:d     r10.6<0;1,0>:d    0:w              
(W&f0.0) cmp (16|M0)  (eq)f0.0   null<1>:d     r10.4<0;1,0>:d    255:w              
(f1.0)  sel (16|M0)              acc0.0<1>:uw  r3.2<0;1,0>:uw    0x0:uw              {F@1}
(f0.0)  sel (16|M0)              acc2.0<1>:uw  r3.2<0;1,0>:uw    0x0:uw             
        or (16|M0)    (ne)f1.0   null<1>:uw    acc0.0<1;1,0>:uw  acc2.0<1;1,0>:uw
(W&f0.0) cmp (16|M16) (eq)f0.0   null<1>:d     r10.4<0;1,0>:d    255:w              
(W)     mov (1|M0)               r3.2<1>:ud    f1.0<0;1,0>:ud                   {Compacted}
(W)     mov (1|M0)               f1.0<1>:ud    r3.0<0;1,0>:ud                  
(f0.0)  sel (16|M16)             acc0.0<1>:uw  r3.2<0;1,0>:uw    0x0:uw             
(W)     mov (1|M0)               f0.0<1>:ud    r3.2<0;1,0>:ud                   {I@3}
(f1.0)  sel (16|M16)             acc2.0<1>:uw  r3.2<0;1,0>:uw    0x0:uw             
        or (16|M16)   (ne)f0.0   null<1>:uw    acc2.0<1;1,0>:uw  acc0.0<1;1,0>:uw
(W)     mov (1|M0)               r3.2<1>:ud    f0.0<0;1,0>:ud                   {Compacted}
(W)     mov (1|M0)               f1.0<1>:ud    r3.2<0;1,0>:ud                   {I@1}
(f1.0)  goto (32|M0)                         L23400                  L23400                
L13064:
(W)     or (1|M0)                r4.0<1>:d     r10.4<0;1,0>:d    r10.6<0;1,0>:d  
(W)     or (1|M0)                r3.0<1>:d     r10.4<0;1,0>:d    r10.6<0;1,0>:d  
        or (16|M16)   (eq)f0.0   null<1>:d     r24.0<1;1,0>:d    r14.0<1;1,0>:d  
(W)     cmp (16|M16)  (eq)f1.0   null<1>:d     r4.0<0;1,0>:d     0:w               {I@3}
(W)     mov (1|M0)               r5.0<1>:hf    0x1:hf                             
(W)     cmp (16|M0)   (eq)f0.0   null<1>:d     r3.0<0;1,0>:d     0:w               {Compacted,I@3}
        or (16|M0)               r12.0<1>:d    r30.0<1;1,0>:d    r16.0<1;1,0>:d   {Compacted}
(f0.0)  sel (16|M16)             acc0.0<1>:uw  r5.0<0;1,0>:uw    0x0:uw              {F@1}
(f1.0)  sel (16|M16)             acc2.0<1>:uw  r5.0<0;1,0>:uw    0x0:uw             
(~f0.0) cmp (16|M0)   (eq)f0.0   null<1>:d     r12.0<1;1,0>:d    0:w               {I@3}
        or (16|M16)   (ne)f0.0   null<1>:uw    acc0.0<1;1,0>:uw  acc2.0<1;1,0>:uw
(~f0.0) goto (32|M0)                         L13280                  L13280                
L13240:
        mov (16|M0)              r22.0<1>:ud   0x0:ud                             
        mov (16|M16)             r26.0<1>:f    0.0:f                               {Compacted}
        goto (32|M0)                         L13280                  L23448                
L13280:
        join (32|M0)                         L23400                                
L13296:
(W)     cmp (16|M0)   (eq)f0.0   null<1>:d     r10.4<0;1,0>:d    0:w               {Compacted}
        cmp (16|M0)   (eq)f1.0   null<1>:d     r30.0<1;1,0>:d    0:w              
(W)     mov (1|M0)               r10.7<1>:ud   f0.0<0;1,0>:ud                   {Compacted}
(W)     add (1|M0)               r3.0<1>:d     r10.4<0;1,0>:d    -127:w               {Compacted}
(W)     mov (1|M0)               f0.0<1>:ud    r10.7<0;1,0>:ud                  {I@2}
        add (16|M0)              r40.0<1>:d    r30.0<1;1,0>:d    -127:w               {Compacted}
(W)     cmp (16|M16)  (eq)f0.0   null<1>:d     r10.4<0;1,0>:d    0:w              
(f1.0)  mov (16|M0)              r40.0<1>:d    -126:w                              
(W&~f0.0) sel (1|M0)             r10.4<1>:d    r3.0<0;1,0>:d     -126:w               {I@5}
        cmp (16|M16)  (eq)f1.0   null<1>:d     r24.0<1;1,0>:d    0:w              
        add (16|M0)              r34.0<1>:d    r40.0<1;1,0>:d    r10.4<0;1,0>:d   {Compacted,I@2}
(W)     mov (1|M0)               r10.7<1>:ud   f0.0<0;1,0>:ud                   {Compacted}
        cmp (16|M0)   (gt)f0.0   null<1>:d     r34.0<1;1,0>:d    127:w               {Compacted,I@2}
        add (16|M16)             r64.0<1>:d    r24.0<1;1,0>:d    -127:w               {Compacted}
(f1.0)  mov (16|M16)             r64.0<1>:d    -126:w                              
(W)     mov (1|M0)               r4.0<1>:ud    f0.0<0;1,0>:ud                   {Compacted}
        add (16|M16)             r32.0<1>:d    r64.0<1;1,0>:d    r10.4<0;1,0>:d   {Compacted,I@2}
(W)     mov (1|M0)               f0.0<1>:ud    r4.0<0;1,0>:ud                   {I@2}
        cmp (16|M16)  (gt)f0.0   null<1>:d     r32.0<1;1,0>:d    127:w               {I@2}
(W)     mov (1|M0)               r4.0<1>:ud    f0.0<0;1,0>:ud                   {Compacted}
(f0.0)  goto (32|M0)                         L23312                  L23312                
L13544:
        or (16|M0)    (eq)f0.0   null<4>:b     r20.0<1;1,0>:d    r2.0<0;1,0>:d   
(W)     mov (1|M0)               r3.0<1>:ud    f0.0<0;1,0>:ud                   {Compacted}
(W)     mov (1|M0)               f0.0<1>:ud    r3.0<0;1,0>:ud                   {I@1}
        or (16|M16)   (eq)f0.0   null<4>:b     r18.0<1;1,0>:d    r2.0<0;1,0>:d   
(W)     mov (1|M0)               r3.0<1>:ud    f0.0<0;1,0>:ud                   {Compacted}
(f0.0)  goto (32|M0)                         L23224                  L23224                
L13624:
(W)     mov (1|M0)               f0.0<1>:ud    r10.7<0;1,0>:ud                 
(W)     mov (1|M0)               r3.0<1>:hf    0.0:hf                              {I@3}
(W)     mov (1|M0)               r2.3<1>:d     0:w                              
(f1.0)  sel (16|M0)              r4.0<1>:d     r3.0<0;1,0>:w     8388608:d               {F@1}
(W&f0.0) sel (1|M0)              r6.0<1>:d     r3.0<0;1,0>:w     8388608:d              
        or (16|M0)               r4.0<1>:d     r4.0<1;1,0>:d     r16.0<1;1,0>:d   {Compacted,I@2}
(W)     or (1|M0)                r7.6<1>:d     r6.0<0;1,0>:d     r10.6<0;1,0>:d   {I@2}
(f1.0)  sel (16|M16)             r12.0<1>:d    r3.0<0;1,0>:w     8388608:d              
        mul (8|M0)               acc0.0<1>:ud  r4.0<1;1,0>:ud    r7.12<0;1,0>:uw  {I@2}
        or (16|M16)              r12.0<1>:d    r12.0<1;1,0>:d    r14.0<1;1,0>:d   {Compacted,I@2}
        mach (8|M0)              r14.0<1>:ud   r4.0<1;1,0>:ud    r7.6<0;1,0>:ud   {AccWrEn,Compacted}
(W)     mov (1|M0)               r2.5<1>:f     -0.0:f                               {Compacted}
        mov (8|M0)               r16.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mul (8|M8)               acc0.0<1>:ud  r5.0<1;1,0>:ud    r7.12<0;1,0>:uw 
        mach (8|M8)              r15.0<1>:ud   r5.0<1;1,0>:ud    r7.6<0;1,0>:ud   {AccWrEn}
(W)     mov (2|M0)               r2.0<1>:d     0:w                              
        mov (8|M8)               r17.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mul (8|M16)              acc0.0<1>:ud  r12.0<1;1,0>:ud   r7.12<0;1,0>:uw  {I@7}
        mach (8|M16)             r18.0<1>:ud   r12.0<1;1,0>:ud   r7.6<0;1,0>:ud   {AccWrEn}
        mov (16|M0)              r24.0<1>:f    r14.0<1;1,0>:f                   {Compacted,A@5}
        mov (8|M16)              r20.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mul (8|M24)              acc0.0<1>:ud  r13.0<1;1,0>:ud   r7.12<0;1,0>:uw 
        mach (8|M24)             r19.0<1>:ud   r13.0<1;1,0>:ud   r7.6<0;1,0>:ud   {AccWrEn}
        mov (16|M0)              r30.0<1>:f    r16.0<1;1,0>:f                   {Compacted,I@6}
        mov (8|M24)              r21.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mov (16|M16)             r50.0<1>:f    r18.0<1;1,0>:f                   {Compacted,A@2}
        mov (16|M16)             r52.0<1>:f    r20.0<1;1,0>:f                   {Compacted,I@1}
L13960:
(W)     shl (1|M0)               r3.0<1>:d     r2.5<0;1,0>:d     31:w               {Compacted,F@5}
(W)     shr (1|M0)               r3.1<1>:ud    r2.3<0;1,0>:ud    1:w              
(W)     addc (1|M0)              r7.0<1>:ud    r2.0<0;1,0>:ud    0x1:ud              {AccWrEn}
(W)     or (1|M0)                r2.3<1>:d     r3.1<0;1,0>:d     r3.0<0;1,0>:d    {I@2}
        bfn.0xA8 (16|M0)         r12.0<1>:ud   r30.0<1;0>:ud     r3.1<0;0>:ud      r3.0<0>:ud       {F@3} // s0&(s1|s2)
        cmp (16|M0)   (eq)f1.0   null<1>:d     r12.0<1;1,0>:d    r2.3<0;1,0>:d    {I@1}
(W)     mov (1|M0)               r4.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        bfn.0xA8 (16|M16)        r14.0<1>:ud   r52.0<1;0>:ud     r3.1<0;0>:ud      r3.0<0>:ud       {F@1} // s0&(s1|s2)
(W)     add (1|M0)               r2.4<1>:ud    r4.0<0;1,0>:ud    r2.1<0;1,0>:ud   {I@2}
(W)     mov (1|M0)               r4.0<1>:ud    f1.0<0;1,0>:ud                   {Compacted}
(W)     shr (1|M0)               r2.2<1>:ud    r2.5<0;1,0>:ud    1:w              
(W)     mov (1|M0)               f1.0<1>:ud    r4.0<0;1,0>:ud                   {I@2}
        cmp (16|M16)  (eq)f1.0   null<1>:d     r14.0<1;1,0>:d    r2.3<0;1,0>:d   
        and (16|M0)              r16.0<1>:d    r24.0<1;1,0>:d    r2.2<0;1,0>:d    {Compacted,I@3}
(W)     mov (1|M0)               r4.0<1>:ud    f1.0<0;1,0>:ud                   {Compacted}
(W)     cmp (16|M0)   (gt)f0.0   null<1>:d     r2.0<0;1,0>:ud    0x3E:uw             
(W)     mov (1|M0)               f1.0<1>:ud    r4.0<0;1,0>:ud                   {I@2}
        and (16|M16)             r18.0<1>:d    r50.0<1;1,0>:d    r2.2<0;1,0>:d    {Compacted}
(W&f0.0) cmp (16|M0)  (eq)f0.0   null<1>:d     r2.1<0;1,0>:d     0:w              
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r16.0<1;1,0>:d    r2.2<0;1,0>:d   
(W&~f0.0) cmp (16|M0) (gt)f0.0   null<1>:d     r2.1<0;1,0>:ud    0x0:uw             
(W)     mov (1|M0)               r4.0<1>:ud    f1.0<0;1,0>:ud                   {Compacted}
(W)     cmp (16|M16)  (gt)f0.0   null<1>:d     r2.0<0;1,0>:ud    0x3E:uw             
(W)     mov (1|M0)               f1.0<1>:ud    r4.0<0;1,0>:ud                   {I@2}
(W)     mov (1|M0)               r3.0<1>:hf    0x1:hf                             
(W&f0.0) cmp (16|M16) (eq)f0.0   null<1>:d     r2.1<0;1,0>:d     0:w              
(f1.0)  cmp (16|M16)  (eq)f1.0   null<1>:d     r18.0<1;1,0>:d    r2.2<0;1,0>:d   
(f0.0)  sel (16|M0)              acc0.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw              {F@1}
(f1.0)  sel (16|M0)              acc2.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw             
(W)     mov (1|M0)               r4.0<1>:ud    f1.0<0;1,0>:ud                   {Compacted}
        or (16|M0)    (ne)f1.0   null<1>:uw    acc0.0<1;1,0>:uw  acc2.0<1;1,0>:uw
(W&~f0.0) cmp (16|M16) (gt)f0.0  null<1>:d     r2.1<0;1,0>:ud    0x0:uw             
(W)     mov (1|M0)               r3.1<1>:ud    f1.0<0;1,0>:ud                   {Compacted}
(W)     mov (1|M0)               f1.0<1>:ud    r4.0<0;1,0>:ud                   {I@4}
(f0.0)  sel (16|M16)             acc0.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw             
(W)     mov (1|M0)               f0.0<1>:ud    r3.1<0;1,0>:ud                   {I@3}
(f1.0)  sel (16|M16)             acc2.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw             
        or (16|M16)   (ne)f0.0   null<1>:uw    acc0.0<1;1,0>:uw  acc2.0<1;1,0>:uw
        mov (16|M0)              r60.0<1>:f    r2.0<0;1,0>:f                    {Compacted}
(W)     mov (1|M0)               r3.1<1>:ud    f0.0<0;1,0>:ud                   {Compacted}
        mov (16|M16)             r58.0<1>:f    r2.0<0;1,0>:f                    {Compacted}
(W)     mov (1|M0)               f1.0<1>:ud    r3.1<0;1,0>:ud                   {I@1}
        mov (16|M16)             r20.0<1>:d    r2.1<0;1,0>:d                   
        mov (16|M0)              r48.0<1>:f    r7.0<0;1,0>:f                    {Compacted}
        mov (16|M16)             r46.0<1>:f    r7.0<0;1,0>:f                    {Compacted}
        mov (16|M0)              r44.0<1>:d    r2.4<0;1,0>:d                   
        mov (16|M16)             r42.0<1>:d    r2.4<0;1,0>:d                   
        mov (16|M0)              r16.0<1>:d    r2.1<0;1,0>:d                   
(f1.0)  goto (32|M0)                         L14688                  L14688                
L14632:
(W)     mov (1|M0)               r2.5<1>:d     r2.2<0;1,0>:d                   
(W)     mov (1|M0)               r2.0<1>:f     r7.0<0;1,0>:f                    {Compacted}
(W)     mov (1|M0)               r2.1<1>:d     r2.4<0;1,0>:d                   
(W)     jmpi                                 L13960                                
L14688:
        join (32|M0)                         L23224                                
L14704:
(W)     mov (1|M0)               r3.0<1>:f     8.68805e-44:f                              
(W)     mov (1|M0)               r4.0<1>:hf    0.0:hf                             
        subb (8|M0)              r56.0<1>:ud   r3.0<0;1,0>:ud    r60.0<1;1,0>:ud  {AccWrEn,Compacted,F@2}
        add3 (8|M0)              r72.0<1>:ud   -acc0.0<1;0>:ud   r4.0<0;0>:uw      -r16.0<1>:ud     {A@1}
        subb (8|M8)              r57.0<1>:ud   r3.0<0;1,0>:ud    r61.0<1;1,0>:ud  {AccWrEn}
        add3 (8|M8)              r73.0<1>:ud   -acc0.0<1;0>:ud   r4.0<0;0>:uw      -r17.0<1>:ud    
        subb (8|M16)             r54.0<1>:ud   r3.0<0;1,0>:ud    r58.0<1;1,0>:ud  {AccWrEn}
        add3 (16|M0)             r18.0<1>:d    r34.0<1;0>:d      r56.0<1;0>:d      -46:w               {I@3}
        add3 (8|M16)             r80.0<1>:ud   -acc0.0<1;0>:ud   r4.0<0;0>:uw      -r20.0<1>:ud    
        subb (8|M24)             r55.0<1>:ud   r3.0<0;1,0>:ud    r59.0<1;1,0>:ud  {AccWrEn}
        cmp (16|M0)   (gt)f0.0   null<1>:d     r18.0<1;1,0>:d    127:w               {Compacted,I@3}
        add3 (16|M16)            r68.0<1>:d    r64.0<1;0>:d      r10.4<0;0>:d      r54.0<1>:d       {I@2}
        add3 (16|M16)            r64.0<1>:d    r32.0<1;0>:d      r54.0<1;0>:d      -46:w              
        cmp (16|M16)  (gt)f0.0   null<1>:d     r64.0<1;1,0>:d    127:w               {I@1}
        add3 (16|M0)             r40.0<1>:d    r40.0<1;0>:d      r10.4<0;0>:d      r56.0<1>:d      
        add3 (8|M24)             r81.0<1>:ud   -acc0.0<1;0>:ud   r4.0<0;0>:uw      -r21.0<1>:ud    
(f0.0)  goto (32|M0)                         L23136                  L23136                
L14960:
        cmp (16|M0)   (gt)f1.0   null<1>:d     r18.0<1;1,0>:d    -127:w              
        cmp (16|M16)  (gt)f1.0   null<1>:d     r64.0<1;1,0>:d    -127:w              
(f1.0)  goto (32|M0)                         L19048                  L19048                
L15008:
        cmp (16|M0)   (lt)f0.0   null<1>:d     r18.0<1;1,0>:ud   0xFFFFFF6B:ud             
        cmp (16|M16)  (lt)f0.0   null<1>:d     r64.0<1;1,0>:ud   0xFFFFFF6B:ud             
(f0.0)  goto (32|M0)                         L18296                  L18296                
L15056:
(W)     mov (1|M0)               r3.0<1>:f     8.82818e-44:f                              
        add3 (16|M0)             r44.0<1>:d    r34.0<1;0>:d      r56.0<1;0>:d      104:w              
(W)     mov (1|M0)               r4.0<1>:hf    0.0:hf                              {I@7}
        subb (8|M0)              r34.0<1>:ud   r3.0<0;1,0>:ud    r60.0<1;1,0>:ud  {AccWrEn,Compacted,F@2}
        add3 (16|M16)            r66.0<1>:d    r32.0<1;0>:d      r54.0<1;0>:d      104:w              
        add3 (8|M0)              r12.0<1>:ud   -acc0.0<1;0>:ud   r4.0<0;0>:uw      -r16.0<1>:ud     {F@1}
        subb (8|M8)              r35.0<1>:ud   r3.0<0;1,0>:ud    r61.0<1;1,0>:ud  {AccWrEn}
(W)     mov (1|M0)               r5.0<1>:hf    0x1:hf                             
        add3 (8|M8)              r13.0<1>:ud   -acc0.0<1;0>:ud   r4.0<0;0>:uw      -r17.0<1>:ud    
        subb (8|M16)             r60.0<1>:ud   r3.0<0;1,0>:ud    r58.0<1;1,0>:ud  {AccWrEn}
        cmp (16|M0)   (gt)f0.0   null<1>:d     r34.0<1;1,0>:ud   r44.0<1;1,0>:ud  {I@3}
        add3 (8|M16)             r14.0<1>:ud   -acc0.0<1;0>:ud   r4.0<0;0>:uw      -r20.0<1>:ud    
        subb (8|M24)             r61.0<1>:ud   r3.0<0;1,0>:ud    r59.0<1;1,0>:ud  {AccWrEn}
(f0.0)  cmp (16|M0)   (eq)f0.0   null<1>:d     r12.0<1;1,0>:d    0:w               {I@5}
        cmp (16|M16)  (gt)f1.0   null<1>:d     r60.0<1;1,0>:ud   r66.0<1;1,0>:ud  {I@2}
        add3 (8|M24)             r15.0<1>:ud   -acc0.0<1;0>:ud   r4.0<0;0>:uw      -r21.0<1>:ud    
(~f0.0) cmp (16|M0)   (gt)f0.0   null<1>:d     r12.0<1;1,0>:ud   0x0:uw             
(f1.0)  cmp (16|M16)  (eq)f1.0   null<1>:d     r14.0<1;1,0>:d    0:w               {I@2}
        cmp (16|M16)  (gt)f0.0   null<1>:d     r14.0<1;1,0>:ud   0x0:uw             
(f1.0)  sel (16|M16)             acc0.0<1>:uw  r5.0<0;1,0>:uw    0x0:uw              {F@1}
(f0.0)  sel (16|M16)             acc2.0<1>:uw  r5.0<0;1,0>:uw    0x0:uw             
        or (16|M16)   (ne)f0.0   null<1>:uw    acc2.0<1;1,0>:uw  acc0.0<1;1,0>:uw
(f0.0)  goto (32|M0)                         L15512                  L15512                
L15416:
        add3 (16|M0)             r4.0<1>:d     r40.0<1;0>:d      -r34.0<1;0>:d     104:w              
        add3 (16|M16)            r12.0<1>:d    r68.0<1;0>:d      -r60.0<1;0>:d     104:w              
        mov (16|M0)              r18.0<1>:d    0:w                              
        mov (16|M16)             r76.0<1>:d    0:w                              
        shl (16|M0)              r24.0<1>:d    r30.0<1;1,0>:d    r4.0<1;1,0>:d    {Compacted,I@4}
        shl (16|M16)             r78.0<1>:d    r52.0<1;1,0>:d    r12.0<1;1,0>:d   {Compacted,I@4}
        goto (32|M0)                         L15512                  L18200                
L15512:
        join (32|M0)                         L18200                                
L15528:
        add3 (16|M0)             r48.0<1>:d    r34.0<1;0>:d      -r40.0<1;0>:d     -104:w              
        add3 (16|M16)            r6.0<1>:d     r60.0<1;0>:d      -r68.0<1;0>:d     -104:w              
        cmp (16|M0)   (lt)f1.0   null<1>:d     r48.0<1;1,0>:d    2:w               {Compacted,I@2}
        cmp (16|M16)  (lt)f1.0   null<1>:d     r6.0<1;1,0>:d     2:w               {I@2}
(f1.0)  goto (32|M0)                         L15752                  L15752                
L15600:
        cmp (16|M0)   (eq)f0.0   null<1>:d     r48.0<1;1,0>:d    2:w               {Compacted}
        cmp (16|M16)  (eq)f0.0   null<1>:d     r6.0<1;1,0>:d     2:w              
(~f0.0) goto (32|M0)                         L15752                  L15816                
L15640:
        shr (16|M0)              r18.0<1>:ud   r30.0<1;1,0>:ud   1:w              
        shr (16|M16)             r40.0<1>:ud   r52.0<1;1,0>:ud   1:w              
        and (16|M0)              r56.0<1>:d    r30.0<1;1,0>:d    1:w               {Compacted}
        and (16|M16)             r68.0<1>:d    r52.0<1;1,0>:d    1:w               {Compacted}
        mov (16|M0)              r44.0<1>:d    0:w                              
        mov (16|M16)             r70.0<1>:d    0:w                              
        mov (16|M0)              r34.0<1>:f    r18.0<1;1,0>:f                   {Compacted,I@6}
        mov (16|M16)             r58.0<1>:f    r40.0<1;1,0>:f                   {Compacted,I@5}
        goto (32|M0)                         L15752                  L17328                
L15752:
        join (32|M0)                         L15816                                
L15768:
        cmp (16|M0)   (eq)f1.0   null<1>:d     r48.0<1;1,0>:d    1:w              
        cmp (16|M16)  (eq)f1.0   null<1>:d     r6.0<1;1,0>:d     1:w              
(f1.0)  goto (32|M0)                         L15816                  L17232                
L15816:
        join (32|M0)                         L17232                                
L15832:
        add3 (16|M0)             r4.0<1>:d     r34.0<1;0>:d      -r44.0<1;0>:d     -1:w               {A@2}
        add3 (16|M16)            r12.0<1>:d    r60.0<1;0>:d      -r66.0<1;0>:d     -1:w              
        and (16|M0)   (ne)f0.0   r14.0<1>:d    r4.0<1;1,0>:d     63:w               {Compacted,I@2}
        and (16|M16)  (ne)f0.0   r2.0<1>:d     r12.0<1;1,0>:d    63:w               {I@2}
(f0.0)  goto (32|M0)                         L15944                  L15944                
L15904:
        mov (16|M0)              r72.0<1>:f    r30.0<1;1,0>:f                   {Compacted}
        mov (16|M16)             r74.0<1>:d    r52.0<1;1,0>:d                  
        goto (32|M0)                         L15944                  L16208                
L15944:
        join (32|M0)                         L16208                                
L15960:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r14.0<1;1,0>:ud   0x20:uw              {I@6}
        cmp (16|M16)  (lt)f1.0   null<1>:d     r2.0<1;1,0>:ud    0x20:uw              {I@6}
(f1.0)  goto (32|M0)                         L16072                  L16072                
L16008:
        add (16|M0)              r4.0<1>:d     r14.0<1;1,0>:d    -32:w               {Compacted}
        add (16|M16)             r12.0<1>:d    r2.0<1;1,0>:d     -32:w               {Compacted}
        shr (16|M0)              r18.0<1>:ud   r24.0<1;1,0>:ud   r4.0<1;1,0>:d    {I@2}
        shr (16|M16)             r40.0<1>:ud   r50.0<1;1,0>:ud   r12.0<1;1,0>:d   {A@2}
        goto (32|M0)                         L16072                  L16168                
L16072:
        join (32|M0)                         L16168                                
L16088:
        add (16|M0)              r4.0<1>:d     -r14.0<1;1,0>:d   32:w               {Compacted}
        add (16|M16)             r12.0<1>:d    -r2.0<1;1,0>:d    32:w               {Compacted}
        shr (16|M16)             r16.0<1>:ud   r52.0<1;1,0>:ud   r2.0<1;1,0>:d   
        shl (16|M0)              r4.0<1>:d     r24.0<1;1,0>:d    r4.0<1;1,0>:d    {Compacted,I@3}
        shr (16|M0)              r14.0<1>:ud   r30.0<1;1,0>:ud   r14.0<1;1,0>:d  
        shl (16|M16)             r12.0<1>:d    r50.0<1;1,0>:d    r12.0<1;1,0>:d   {Compacted,I@4}
        or (16|M0)               r18.0<1>:d    r14.0<1;1,0>:d    r4.0<1;1,0>:d    {Compacted,I@2}
        or (16|M16)              r40.0<1>:d    r16.0<1;1,0>:d    r12.0<1;1,0>:d   {Compacted,I@2}
L16168:
        join (32|M0)                         L16208                                
L16184:
        mov (16|M0)              r72.0<1>:f    r18.0<1;1,0>:f                   {Compacted,I@3}
        mov (16|M16)             r74.0<1>:d    r40.0<1;1,0>:d                   {I@2}
L16208:
        join (32|M0)                         L17232                                
L16224:
        add3 (16|M0)             r20.0<1>:d    r34.0<1;0>:d      -r44.0<1;0>:d     -2:w              
        add3 (16|M16)            r60.0<1>:d    r60.0<1;0>:d      -r66.0<1;0>:d     -2:w              
        and (16|M0)   (ne)f0.0   r14.0<1>:d    r20.0<1;1,0>:d    63:w               {Compacted,I@2}
        and (16|M16)  (ne)f0.0   r2.0<1>:d     r60.0<1;1,0>:d    63:w               {I@2}
(f0.0)  goto (32|M0)                         L16336                  L16336                
L16296:
        mov (16|M0)              r18.0<1>:f    r30.0<1;1,0>:f                   {Compacted}
        mov (16|M16)             r40.0<1>:d    r52.0<1;1,0>:d                  
        goto (32|M0)                         L16336                  L16560                
L16336:
        join (32|M0)                         L16560                                
L16352:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r14.0<1;1,0>:ud   0x20:uw              {I@6}
        cmp (16|M16)  (lt)f1.0   null<1>:d     r2.0<1;1,0>:ud    0x20:uw              {I@6}
(f1.0)  goto (32|M0)                         L16464                  L16464                
L16400:
        add (16|M0)              r4.0<1>:d     r14.0<1;1,0>:d    -32:w               {Compacted}
        add (16|M16)             r12.0<1>:d    r2.0<1;1,0>:d     -32:w               {Compacted}
        shr (16|M0)              r18.0<1>:ud   r24.0<1;1,0>:ud   r4.0<1;1,0>:d    {A@1}
        shr (16|M16)             r40.0<1>:ud   r50.0<1;1,0>:ud   r12.0<1;1,0>:d   {I@2}
        goto (32|M0)                         L16464                  L16560                
L16464:
        join (32|M0)                         L16560                                
L16480:
        add (16|M0)              r4.0<1>:d     -r14.0<1;1,0>:d   32:w               {Compacted}
        add (16|M16)             r12.0<1>:d    -r2.0<1;1,0>:d    32:w               {Compacted}
        shr (16|M16)             r16.0<1>:ud   r52.0<1;1,0>:ud   r2.0<1;1,0>:d   
        shl (16|M0)              r4.0<1>:d     r24.0<1;1,0>:d    r4.0<1;1,0>:d    {Compacted,I@3}
        shr (16|M0)              r14.0<1>:ud   r30.0<1;1,0>:ud   r14.0<1;1,0>:d  
        shl (16|M16)             r12.0<1>:d    r50.0<1;1,0>:d    r12.0<1;1,0>:d   {Compacted,I@4}
        or (16|M0)               r18.0<1>:d    r14.0<1;1,0>:d    r4.0<1;1,0>:d    {Compacted,I@2}
        or (16|M16)              r40.0<1>:d    r16.0<1;1,0>:d    r12.0<1;1,0>:d   {Compacted,I@2}
L16560:
        join (32|M0)                         L17232                                
L16576:
        and (16|M0)   (ne)f0.0   r4.0<1>:d     r20.0<1;1,0>:d    63:w               {Compacted}
        and (16|M16)  (ne)f0.0   r20.0<1>:d    r60.0<1;1,0>:d    63:w              
        and (16|M0)              r56.0<1>:d    r18.0<1;1,0>:d    1:w               {Compacted,I@5}
        and (16|M16)             r68.0<1>:d    r40.0<1;1,0>:d    1:w               {Compacted,I@5}
(f0.0)  goto (32|M0)                         L16712                  L16712                
L16632:
        mov (16|M0)              r4.0<1>:d     -1:w                              
        mov (16|M16)             r14.0<1>:d    -1:w                              
        mov (16|M0)              r18.0<1>:d    -1:w                              
        mov (16|M16)             r16.0<1>:d    -1:w                              
        goto (32|M0)                         L16712                  L16984                
L16712:
        join (32|M0)                         L16984                                
L16728:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r4.0<1;1,0>:ud    0x20:uw              {I@6}
        cmp (16|M16)  (lt)f1.0   null<1>:d     r20.0<1;1,0>:ud   0x20:uw             
(f1.0)  goto (32|M0)                         L16888                  L16888                
L16776:
        add (16|M0)              r4.0<1>:d     r4.0<1;1,0>:d     -32:w               {Compacted}
        add (16|M16)             r12.0<1>:d    r20.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r3.0<1>:hf    -qnan(0x1FF):hf                             
        mov (16|M16)             r14.0<1>:d    0:w                              
        shl (16|M0)              r18.0<1>:d    r3.0<0;1,0>:w     r4.0<1;1,0>:d    {A@1}
        shl (16|M16)             r16.0<1>:d    r3.0<0;1,0>:w     r12.0<1;1,0>:d   {I@3}
        mov (16|M0)              r4.0<1>:d     0:w                              
        goto (32|M0)                         L16888                  L16984                
L16888:
        join (32|M0)                         L16984                                
L16904:
(W)     mov (1|M0)               r3.0<1>:hf    -qnan(0x1FF):hf                              {I@4}
        mov (16|M0)              r18.0<1>:d    -1:w                              
        mov (16|M16)             r16.0<1>:d    -1:w                              
        shl (16|M0)              r4.0<1>:d     r3.0<0;1,0>:w     r4.0<1;1,0>:d    {A@1}
        shl (16|M16)             r14.0<1>:d    r3.0<0;1,0>:w     r20.0<1;1,0>:d  
L16984:
        join (32|M0)                         L17232                                
L17000:
        bfn.0x28 (16|M0)         r4.0<1>:ud    r30.0<1;0>:ud     r4.0<1;0>:ud      r9.0<0>:ud       {I@3} // s0&(s1^s2)
        bfn.0x28 (16|M16)        r12.0<1>:ud   r52.0<1;0>:ud     r14.0<1;0>:ud     r9.0<0>:ud       {I@3} // s0&(s1^s2)
        cmp (16|M0)   (ne)f0.0   null<1>:d     r4.0<1;1,0>:d     0:w               {Compacted,I@2}
        cmp (16|M16)  (ne)f0.0   null<1>:d     r12.0<1;1,0>:d    0:w               {I@2}
        bfn.0x28 (16|M16)        r16.0<1>:ud   r50.0<1;0>:ud     r16.0<1;0>:ud     r9.0<0>:ud       // s0&(s1^s2)
        bfn.0x28 (16|M0)         r14.0<1>:ud   r24.0<1;0>:ud     r18.0<1;0>:ud     r9.0<0>:ud       // s0&(s1^s2)
(~f0.0) cmp (16|M16)  (ne)f0.0   null<1>:d     r16.0<1;1,0>:d    0:w               {I@2}
(~f0.0) cmp (16|M0)   (ne)f0.0   null<1>:d     r14.0<1;1,0>:d    0:w               {I@2}
(W)     mov (1|M0)               r3.0<1>:hf    -qnan(0x1FF):hf                             
        mov (16|M0)              r34.0<1>:f    r72.0<1;1,0>:f                   {Compacted}
(f0.0)  sel (16|M0)              r18.0<1>:d    r3.0<0;1,0>:w     0:w               {F@2}
(f0.0)  sel (16|M16)             r20.0<1>:d    r3.0<0;1,0>:w     0:w              
        mov (16|M16)             r58.0<1>:f    r74.0<1;1,0>:f                   {Compacted}
        mov (16|M0)              r44.0<1>:d    -r18.0<1;1,0>:d                  {I@2}
        mov (16|M16)             r70.0<1>:d    -r20.0<1;1,0>:d                  {I@2}
        goto (32|M0)                         L17232                  L17328                
L17232:
        join (32|M0)                         L17328                                
L17248:
        mov (16|M0)              r44.0<1>:d    0:w                              
        mov (16|M16)             r70.0<1>:d    0:w                              
        mov (16|M0)              r56.0<1>:d    0:w                              
        mov (16|M16)             r68.0<1>:d    0:w                              
        mov (16|M0)              r34.0<1>:f    r30.0<1;1,0>:f                   {Compacted}
        mov (16|M16)             r58.0<1>:f    r52.0<1;1,0>:f                   {Compacted}
L17328:
        join (32|M0)                         L18200                                
L17344:
        and (16|M0)   (ne)f0.0   r14.0<1>:d    r48.0<1;1,0>:d    63:w               {Compacted}
        and (16|M16)  (ne)f0.0   r2.0<1>:d     r6.0<1;1,0>:d     63:w              
(f0.0)  goto (32|M0)                         L17424                  L17424                
L17384:
        mov (16|M0)              r18.0<1>:f    r30.0<1;1,0>:f                   {Compacted}
        mov (16|M16)             r40.0<1>:d    r52.0<1;1,0>:d                  
        goto (32|M0)                         L17424                  L17648                
L17424:
        join (32|M0)                         L17648                                
L17440:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r14.0<1;1,0>:ud   0x20:uw              {I@6}
        cmp (16|M16)  (lt)f1.0   null<1>:d     r2.0<1;1,0>:ud    0x20:uw              {I@6}
(f1.0)  goto (32|M0)                         L17552                  L17552                
L17488:
        add (16|M0)              r4.0<1>:d     r14.0<1;1,0>:d    -32:w               {Compacted}
        add (16|M16)             r12.0<1>:d    r2.0<1;1,0>:d     -32:w               {Compacted}
        shr (16|M0)              r18.0<1>:ud   r24.0<1;1,0>:ud   r4.0<1;1,0>:d    {A@1}
        shr (16|M16)             r40.0<1>:ud   r50.0<1;1,0>:ud   r12.0<1;1,0>:d   {I@2}
        goto (32|M0)                         L17552                  L17648                
L17552:
        join (32|M0)                         L17648                                
L17568:
        add (16|M0)              r4.0<1>:d     -r14.0<1;1,0>:d   32:w               {Compacted}
        add (16|M16)             r12.0<1>:d    -r2.0<1;1,0>:d    32:w               {Compacted}
        shr (16|M16)             r16.0<1>:ud   r52.0<1;1,0>:ud   r2.0<1;1,0>:d   
        shl (16|M0)              r4.0<1>:d     r24.0<1;1,0>:d    r4.0<1;1,0>:d    {Compacted,I@3}
        shr (16|M0)              r14.0<1>:ud   r30.0<1;1,0>:ud   r14.0<1;1,0>:d  
        shl (16|M16)             r12.0<1>:d    r50.0<1;1,0>:d    r12.0<1;1,0>:d   {Compacted,I@4}
        or (16|M0)               r18.0<1>:d    r14.0<1;1,0>:d    r4.0<1;1,0>:d    {Compacted,I@2}
        or (16|M16)              r40.0<1>:d    r16.0<1;1,0>:d    r12.0<1;1,0>:d   {Compacted,I@2}
L17648:
        join (32|M0)                         L18200                                
L17664:
        shl (16|M0)              r4.0<1>:d     r34.0<1;1,0>:d    2:w               {Compacted}
        shl (16|M16)             r12.0<1>:d    r58.0<1;1,0>:d    2:w               {Compacted}
        shl (16|M0)              r14.0<1>:d    r56.0<1;1,0>:d    1:w               {Compacted}
        shl (16|M16)             r16.0<1>:d    r68.0<1;1,0>:d    1:w               {Compacted}
        and (16|M0)              r4.0<1>:d     r4.0<1;1,0>:d     4:w               {Compacted,I@4}
        and (16|M16)             r12.0<1>:d    r12.0<1;1,0>:d    4:w               {Compacted,I@4}
        bfn.0xFE (16|M0)         r14.0<1>:ud   r4.0<1;0>:ud      r14.0<1;0>:ud     r44.0<1>:ud      {I@2} // s0|s1|s2
        bfn.0xFE (16|M16)        r4.0<1>:ud    r12.0<1;0>:ud     r16.0<1;0>:ud     r70.0<1>:ud      {I@2} // s0|s1|s2
        cmp (16|M0)   (eq)f0.0   null<1>:d     r14.0<1;1,0>:d    0:w               {Compacted,I@2}
        cmp (16|M16)  (eq)f0.0   null<1>:d     r4.0<1;1,0>:d     0:w               {I@2}
(~f0.0) goto (32|M0)                         L17832                  L17832                
L17784:
        mov (16|M0)              r12.0<1>:d    0:w                              
        mov (16|M16)             r6.0<1>:d     0:w                              
        goto (32|M0)                         L17832                  L18072                
L17832:
        join (32|M0)                         L18072                                
L17848:
        cmp (16|M0)   (gt)f1.0   null<1>:d     r14.0<1;1,0>:ud   0x4:uw             
        cmp (16|M16)  (gt)f1.0   null<1>:d     r4.0<1;1,0>:ud    0x4:uw             
(~f1.0) goto (32|M0)                         L17944                  L17944                
L17896:
        mov (16|M0)              r12.0<1>:d    1:w                              
        mov (16|M16)             r6.0<1>:d     1:w                              
        goto (32|M0)                         L17944                  L18072                
L17944:
        join (32|M0)                         L18072                                
L17960:
        and (16|M0)   (ne)f1.0   null<1>:d     r18.0<1;1,0>:d    1:w              
        and (16|M16)  (ne)f1.0   null<1>:d     r40.0<1;1,0>:d    1:w              
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r14.0<1;1,0>:d    4:w              
(f1.0)  cmp (16|M16)  (eq)f1.0   null<1>:d     r4.0<1;1,0>:d     4:w              
(W)     mov (1|M0)               r3.0<1>:hf    0x1:hf                             
(f1.0)  sel (16|M0)              r12.0<1>:d    r3.0<0;1,0>:w     0:w               {F@1}
(f1.0)  sel (16|M16)             r6.0<1>:d     r3.0<0;1,0>:w     0:w              
L18072:
        join (32|M0)                         L18200                                
L18088:
        add (16|M0)              r4.0<1>:d     r12.0<1;1,0>:d    r18.0<1;1,0>:d   {Compacted,I@3}
        add (16|M16)             r12.0<1>:d    r6.0<1;1,0>:d     r40.0<1;1,0>:d   {Compacted,I@3}
        cmp (16|M0)   (gt)f1.0   null<1>:d     r4.0<1;1,0>:ud    0x7FFFFF:ud              {I@2}
        cmp (16|M16)  (gt)f1.0   null<1>:d     r12.0<1;1,0>:ud   0x7FFFFF:ud              {I@2}
(W)     mov (1|M0)               r3.0<1>:f     0x800000:f                               {Compacted}
(~f1.0) sel (16|M0)              r24.0<1>:d    r4.0<1;1,0>:d     0:w              
(~f1.0) sel (16|M16)             r78.0<1>:d    r12.0<1;1,0>:d    0:w              
(f1.0)  sel (16|M0)              r18.0<1>:d    r3.0<0;1,0>:d     0:w               {Compacted,F@1}
(f1.0)  sel (16|M16)             r76.0<1>:d    r3.0<0;1,0>:d     0:w              
L18200:
        join (32|M0)                         L18296                                
L18216:
        and (16|M0)              r4.0<1>:d     r22.0<1;1,0>:d    -2147483648:d              
        and (16|M16)             r12.0<1>:d    r28.0<1;1,0>:d    -2147483648:d              
        bfn.0xFE (16|M0)         r22.0<1>:ud   r4.0<1;0>:ud      r18.0<1;0>:ud     r24.0<1>:ud      {I@2} // s0|s1|s2
        bfn.0xFE (16|M16)        r26.0<1>:ud   r12.0<1;0>:ud     r76.0<1;0>:ud     r78.0<1>:ud      {I@2} // s0|s1|s2
        goto (32|M0)                         L18296                  L23448                
L18296:
        join (32|M0)                         L19048                                
L18312:
        and (16|M0)   (ne)f0.0   r4.0<1>:d     r56.0<1;1,0>:d    63:w               {Compacted}
        and (16|M16)  (ne)f0.0   r16.0<1>:d    r54.0<1;1,0>:d    63:w              
(f0.0)  goto (32|M0)                         L18432                  L18432                
L18352:
        mov (16|M0)              r4.0<1>:d     -1:w                              
        mov (16|M16)             r14.0<1>:d    -1:w                              
        mov (16|M0)              r20.0<1>:d    -1:w                              
        mov (16|M16)             r6.0<1>:d     -1:w                              
        goto (32|M0)                         L18432                  L18704                
L18432:
        join (32|M0)                         L18704                                
L18448:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r4.0<1;1,0>:ud    0x20:uw              {I@6}
        cmp (16|M16)  (lt)f1.0   null<1>:d     r16.0<1;1,0>:ud   0x20:uw             
(f1.0)  goto (32|M0)                         L18608                  L18608                
L18496:
        add (16|M0)              r4.0<1>:d     r4.0<1;1,0>:d     -32:w               {Compacted}
        add (16|M16)             r12.0<1>:d    r16.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r3.0<1>:hf    -qnan(0x1FF):hf                             
        mov (16|M16)             r14.0<1>:d    0:w                              
        shl (16|M0)              r20.0<1>:d    r3.0<0;1,0>:w     r4.0<1;1,0>:d    {A@1}
        shl (16|M16)             r6.0<1>:d     r3.0<0;1,0>:w     r12.0<1;1,0>:d   {I@3}
        mov (16|M0)              r4.0<1>:d     0:w                              
        goto (32|M0)                         L18608                  L18704                
L18608:
        join (32|M0)                         L18704                                
L18624:
(W)     mov (1|M0)               r3.0<1>:hf    -qnan(0x1FF):hf                              {I@4}
        mov (16|M0)              r20.0<1>:d    -1:w                              
        mov (16|M16)             r6.0<1>:d     -1:w                              
        shl (16|M0)              r4.0<1>:d     r3.0<0;1,0>:w     r4.0<1;1,0>:d    {A@1}
        shl (16|M16)             r14.0<1>:d    r3.0<0;1,0>:w     r16.0<1;1,0>:d  
L18704:
        join (32|M0)                         L19048                                
L18720:
        bfn.0x28 (16|M0)         r4.0<1>:ud    r30.0<1;0>:ud     r4.0<1;0>:ud      r9.0<0>:ud       {I@3} // s0&(s1^s2)
        bfn.0x28 (16|M16)        r12.0<1>:ud   r52.0<1;0>:ud     r14.0<1;0>:ud     r9.0<0>:ud       {I@3} // s0&(s1^s2)
        cmp (16|M0)   (ne)f1.0   null<1>:d     r4.0<1;1,0>:d     0:w               {I@2}
        cmp (16|M16)  (ne)f1.0   null<1>:d     r12.0<1;1,0>:d    0:w               {I@2}
        bfn.0x28 (16|M16)        r16.0<1>:ud   r50.0<1;0>:ud     r6.0<1;0>:ud      r9.0<0>:ud       // s0&(s1^s2)
        bfn.0x28 (16|M0)         r14.0<1>:ud   r24.0<1;0>:ud     r20.0<1;0>:ud     r9.0<0>:ud       // s0&(s1^s2)
        cmp (16|M0)   (gt)f0.0   null<1>:d     r22.0<1;1,0>:d    -1:w               {Compacted}
        cmp (16|M16)  (gt)f0.0   null<1>:d     r28.0<1;1,0>:d    -1:w              
(~f1.0) cmp (16|M16)  (ne)f1.0   null<1>:d     r16.0<1;1,0>:d    0:w               {I@4}
(~f1.0) cmp (16|M0)   (ne)f1.0   null<1>:d     r14.0<1;1,0>:d    0:w               {I@4}
(f1.0)  cmp (16|M16)  (eq)f1.0   null<1>:d     r64.0<1;1,0>:d    -150:w              
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r18.0<1;1,0>:d    -150:w              
(f0.0)  goto (32|M0)                         L18976                  L18976                
L18920:
(W)     mov (1|M0)               r3.0<1>:ud    0x80000001:ud                             
(f1.0)  sel (16|M0)              r22.0<1>:f    r3.0<0;1,0>:f     -0.0:f               {Compacted,I@1}
(f1.0)  sel (16|M16)             r26.0<1>:f    r3.0<0;1,0>:f     -0.0:f              
        goto (32|M0)                         L18976                  L23448                
L18976:
        join (32|M0)                         L19048                                
L18992:
(W)     mov (1|M0)               r3.0<1>:ud    0x1:ud                              {F@1}
(f1.0)  sel (16|M0)              r22.0<1>:f    r3.0<0;1,0>:f     0.0:f               {Compacted,I@1}
(f1.0)  sel (16|M16)             r26.0<1>:f    r3.0<0;1,0>:f     0.0:f              
        goto (32|M0)                         L19048                  L23448                
L19048:
        join (32|M0)                         L23136                                
L19064:
        cmp (16|M16)  (lt)f0.0   null<1>:d     r54.0<1;1,0>:ud   0x18:uw             
        cmp (16|M16)  (eq)f1.0   null<1>:d     r80.0<1;1,0>:d    0:w               {F@1}
        cmp (16|M0)   (lt)f1.0   null<1>:d     r56.0<1;1,0>:ud   0x18:uw             
(W)     mov (1|M0)               r3.0<1>:hf    0x1:hf                             
        add3 (16|M0)             r66.0<1>:d    r34.0<1;0>:d      r56.0<1;0>:d      81:w              
(f1.0)  sel (16|M16)             acc0.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw              {F@1}
(f0.0)  sel (16|M16)             acc2.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw             
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r72.0<1;1,0>:d    0:w              
        and (16|M16)  (ne)f1.0   null<1>:uw    acc0.0<1;1,0>:uw  acc2.0<1;1,0>:uw
        add3 (16|M16)            r68.0<1>:d    r32.0<1;0>:d      r54.0<1;0>:d      81:w              
(f1.0)  goto (32|M0)                         L22680                  L22680                
L19240:
        shl (16|M16)             r12.0<1>:d    r46.0<1;1,0>:d    1:w               {Compacted}
        shl (16|M0)              r4.0<1>:d     r48.0<1;1,0>:d    1:w               {Compacted}
        shr (16|M16)             r16.0<1>:ud   r46.0<1;1,0>:ud   31:w              
        shl (16|M16)             r20.0<1>:d    r42.0<1;1,0>:d    1:w               {Compacted}
        cmp (16|M16)  (lt)f0.0   null<1>:d     r12.0<1;1,0>:ud   0x4E:uw              {I@4}
        shr (16|M0)              r14.0<1>:ud   r48.0<1;1,0>:ud   31:w              
        shl (16|M0)              r18.0<1>:d    r44.0<1;1,0>:d    1:w               {Compacted}
        cmp (16|M0)   (lt)f1.0   null<1>:d     r4.0<1;1,0>:ud    0x4E:uw              {I@6}
        or (16|M16)              r20.0<1>:d    r20.0<1;1,0>:d    r16.0<1;1,0>:d   {Compacted,I@5}
        or (16|M0)               r18.0<1>:d    r18.0<1;1,0>:d    r14.0<1;1,0>:d   {Compacted,I@3}
(f0.0)  cmp (16|M16)  (eq)f0.0   null<1>:d     r20.0<1;1,0>:d    0:w               {I@2}
        cmp (16|M16)  (lt)f1.0   null<1>:d     r20.0<1;1,0>:d    0:w              
(W)     mov (1|M0)               r3.0<1>:hf    0x1:hf                             
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r18.0<1;1,0>:d    0:w               {I@3}
(f1.0)  sel (16|M16)             acc0.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw              {F@1}
(f0.0)  sel (16|M16)             acc2.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw             
(~f1.0) cmp (16|M0)   (lt)f1.0   null<1>:d     r18.0<1;1,0>:d    0:w              
        or (16|M16)   (ne)f1.0   null<1>:uw    acc0.0<1;1,0>:uw  acc2.0<1;1,0>:uw
(f1.0)  goto (32|M0)                         L19776                  L19776                
L19496:
        cmp (16|M16)  (eq)f1.0   null<1>:d     r46.0<1;1,0>:d    39:w              
        cmp (16|M16)  (eq)f0.0   null<1>:d     r42.0<1;1,0>:d    0:w              
        cmp (16|M0)   (eq)f0.0   null<1>:d     r48.0<1;1,0>:d    39:w               {Compacted}
(W)     mov (1|M0)               r3.0<1>:hf    0x1:hf                              {I@7}
(f0.0)  sel (16|M16)             acc0.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw              {F@1}
(f1.0)  sel (16|M16)             acc2.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw             
(f0.0)  cmp (16|M0)   (eq)f0.0   null<1>:d     r44.0<1;1,0>:d    0:w              
        and (16|M16)  (ne)f0.0   null<1>:uw    acc0.0<1;1,0>:uw  acc2.0<1;1,0>:uw
(~f0.0) goto (32|M0)                         L19776                  L19936                
L19632:
        shr (16|M0)              r18.0<1>:ud   r30.0<1;1,0>:ud   1:w              
        shr (16|M16)             r40.0<1>:ud   r52.0<1;1,0>:ud   1:w              
        mov (16|M0)              r48.0<1>:d    0:w                              
        mov (16|M16)             r60.0<1>:d    0:w                              
        mov (16|M0)              r44.0<1>:d    0:w                              
        mov (16|M16)             r58.0<1>:d    0:w                              
        mov (16|M0)              r24.0<1>:f    r18.0<1;1,0>:f                   {Compacted,I@6}
        mov (16|M16)             r6.0<1>:f     r40.0<1;1,0>:f                   {Compacted,I@5}
        mov (16|M0)              r18.0<1>:f    r30.0<1;1,0>:f                   {Compacted}
        mov (16|M16)             r40.0<1>:f    r52.0<1;1,0>:f                   {Compacted}
        goto (32|M0)                         L19776                  L21832                
L19776:
        join (32|M0)                         L19936                                
L19792:
        cmp (16|M16)  (eq)f0.0   null<1>:d     r46.0<1;1,0>:d    38:w              
        cmp (16|M16)  (eq)f1.0   null<1>:d     r42.0<1;1,0>:d    0:w              
        cmp (16|M0)   (eq)f1.0   null<1>:d     r48.0<1;1,0>:d    38:w               {I@7}
(W)     mov (1|M0)               r3.0<1>:hf    0x1:hf                             
(f1.0)  sel (16|M16)             acc0.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw              {F@1}
(f0.0)  sel (16|M16)             acc2.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw             
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r44.0<1;1,0>:d    0:w               {I@7}
        and (16|M16)  (ne)f1.0   null<1>:uw    acc0.0<1;1,0>:uw  acc2.0<1;1,0>:uw
(f1.0)  goto (32|M0)                         L19936                  L21688                
L19936:
        join (32|M0)                         L21688                                
L19952:
        add (16|M0)              r4.0<1>:d     -r48.0<1;1,0>:d   39:w               {Compacted}
        add (16|M16)             r12.0<1>:d    -r46.0<1;1,0>:d   39:w               {Compacted}
        and (16|M0)   (ne)f0.0   r14.0<1>:d    r4.0<1;1,0>:d     63:w               {Compacted,I@2}
        and (16|M16)  (ne)f0.0   r2.0<1>:d     r12.0<1;1,0>:d    63:w               {I@2}
        add (16|M0)              r70.0<1>:d    -r48.0<1;1,0>:d   40:w               {Compacted}
        add (16|M16)             r72.0<1>:d    -r46.0<1;1,0>:d   40:w               {Compacted}
(f0.0)  goto (32|M0)                         L20064                  L20064                
L20024:
        mov (16|M0)              r42.0<1>:f    r30.0<1;1,0>:f                   {Compacted}
        mov (16|M16)             r64.0<1>:d    r52.0<1;1,0>:d                  
        goto (32|M0)                         L20064                  L20328                
L20064:
        join (32|M0)                         L20328                                
L20080:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r14.0<1;1,0>:ud   0x20:uw              {I@7}
        cmp (16|M16)  (lt)f1.0   null<1>:d     r2.0<1;1,0>:ud    0x20:uw              {I@7}
(f1.0)  goto (32|M0)                         L20192                  L20192                
L20128:
        add (16|M0)              r4.0<1>:d     r14.0<1;1,0>:d    -32:w               {Compacted}
        add (16|M16)             r12.0<1>:d    r2.0<1;1,0>:d     -32:w               {Compacted}
        shr (16|M0)              r18.0<1>:ud   r24.0<1;1,0>:ud   r4.0<1;1,0>:d    {I@2}
        shr (16|M16)             r40.0<1>:ud   r50.0<1;1,0>:ud   r12.0<1;1,0>:d   {I@2}
        goto (32|M0)                         L20192                  L20288                
L20192:
        join (32|M0)                         L20288                                
L20208:
        add (16|M0)              r4.0<1>:d     -r14.0<1;1,0>:d   32:w               {Compacted}
        add (16|M16)             r12.0<1>:d    -r2.0<1;1,0>:d    32:w               {Compacted}
        shr (16|M16)             r16.0<1>:ud   r52.0<1;1,0>:ud   r2.0<1;1,0>:d   
        shl (16|M0)              r4.0<1>:d     r24.0<1;1,0>:d    r4.0<1;1,0>:d    {Compacted,I@3}
        shr (16|M0)              r14.0<1>:ud   r30.0<1;1,0>:ud   r14.0<1;1,0>:d  
        shl (16|M16)             r12.0<1>:d    r50.0<1;1,0>:d    r12.0<1;1,0>:d   {Compacted,I@4}
        or (16|M0)               r18.0<1>:d    r14.0<1;1,0>:d    r4.0<1;1,0>:d    {Compacted,I@2}
        or (16|M16)              r40.0<1>:d    r16.0<1;1,0>:d    r12.0<1;1,0>:d   {Compacted,I@2}
L20288:
        join (32|M0)                         L20328                                
L20304:
        mov (16|M0)              r42.0<1>:f    r18.0<1;1,0>:f                   {Compacted,I@3}
        mov (16|M16)             r64.0<1>:d    r40.0<1;1,0>:d                   {I@2}
L20328:
        join (32|M0)                         L21688                                
L20344:
        add (16|M0)              r20.0<1>:d    -r48.0<1;1,0>:d   38:w               {Compacted}
        add (16|M16)             r2.0<1>:d     -r46.0<1;1,0>:d   38:w               {Compacted}
        and (16|M0)   (ne)f0.0   r14.0<1>:d    r20.0<1;1,0>:d    63:w               {Compacted,I@2}
        and (16|M16)  (ne)f0.0   r16.0<1>:d    r2.0<1;1,0>:d     63:w               {I@2}
(f0.0)  goto (32|M0)                         L20440                  L20440                
L20400:
        mov (16|M0)              r18.0<1>:f    r30.0<1;1,0>:f                   {Compacted}
        mov (16|M16)             r40.0<1>:d    r52.0<1;1,0>:d                  
        goto (32|M0)                         L20440                  L20664                
L20440:
        join (32|M0)                         L20664                                
L20456:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r14.0<1;1,0>:ud   0x20:uw              {I@6}
        cmp (16|M16)  (lt)f1.0   null<1>:d     r16.0<1;1,0>:ud   0x20:uw              {I@6}
(f1.0)  goto (32|M0)                         L20568                  L20568                
L20504:
        add (16|M0)              r4.0<1>:d     r14.0<1;1,0>:d    -32:w               {Compacted}
        add (16|M16)             r12.0<1>:d    r16.0<1;1,0>:d    -32:w               {Compacted}
        shr (16|M0)              r18.0<1>:ud   r24.0<1;1,0>:ud   r4.0<1;1,0>:d    {A@1}
        shr (16|M16)             r40.0<1>:ud   r50.0<1;1,0>:ud   r12.0<1;1,0>:d   {I@2}
        goto (32|M0)                         L20568                  L20664                
L20568:
        join (32|M0)                         L20664                                
L20584:
        add (16|M0)              r4.0<1>:d     -r14.0<1;1,0>:d   32:w               {Compacted}
        add (16|M16)             r12.0<1>:d    -r16.0<1;1,0>:d   32:w               {Compacted}
        shl (16|M0)              r4.0<1>:d     r24.0<1;1,0>:d    r4.0<1;1,0>:d    {Compacted,I@2}
        shr (16|M0)              r14.0<1>:ud   r30.0<1;1,0>:ud   r14.0<1;1,0>:d  
        shl (16|M16)             r12.0<1>:d    r50.0<1;1,0>:d    r12.0<1;1,0>:d   {Compacted,I@3}
        shr (16|M16)             r16.0<1>:ud   r52.0<1;1,0>:ud   r16.0<1;1,0>:d  
        or (16|M0)               r18.0<1>:d    r14.0<1;1,0>:d    r4.0<1;1,0>:d    {Compacted,I@3}
        or (16|M16)              r40.0<1>:d    r16.0<1;1,0>:d    r12.0<1;1,0>:d   {Compacted,I@2}
L20664:
        join (32|M0)                         L21688                                
L20680:
        and (16|M0)   (ne)f0.0   r4.0<1>:d     r20.0<1;1,0>:d    63:w               {Compacted}
        and (16|M16)  (ne)f0.0   r20.0<1>:d    r2.0<1;1,0>:d     63:w              
        and (16|M0)              r44.0<1>:d    r18.0<1;1,0>:d    1:w               {Compacted,I@5}
        and (16|M16)             r58.0<1>:d    r40.0<1;1,0>:d    1:w               {Compacted,I@5}
(f0.0)  goto (32|M0)                         L20816                  L20816                
L20736:
        mov (16|M0)              r4.0<1>:d     -1:w                              
        mov (16|M16)             r14.0<1>:d    -1:w                              
        mov (16|M0)              r18.0<1>:d    -1:w                              
        mov (16|M16)             r16.0<1>:d    -1:w                              
        goto (32|M0)                         L20816                  L21088                
L20816:
        join (32|M0)                         L21088                                
L20832:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r4.0<1;1,0>:ud    0x20:uw              {I@6}
        cmp (16|M16)  (lt)f1.0   null<1>:d     r20.0<1;1,0>:ud   0x20:uw             
(f1.0)  goto (32|M0)                         L20992                  L20992                
L20880:
        add (16|M0)              r4.0<1>:d     r4.0<1;1,0>:d     -32:w               {Compacted}
        add (16|M16)             r12.0<1>:d    r20.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r3.0<1>:hf    -qnan(0x1FF):hf                             
        mov (16|M16)             r14.0<1>:d    0:w                              
        shl (16|M0)              r18.0<1>:d    r3.0<0;1,0>:w     r4.0<1;1,0>:d    {A@1}
        shl (16|M16)             r16.0<1>:d    r3.0<0;1,0>:w     r12.0<1;1,0>:d   {I@3}
        mov (16|M0)              r4.0<1>:d     0:w                              
        goto (32|M0)                         L20992                  L21088                
L20992:
        join (32|M0)                         L21088                                
L21008:
(W)     mov (1|M0)               r3.0<1>:hf    -qnan(0x1FF):hf                              {I@4}
        mov (16|M0)              r18.0<1>:d    -1:w                              
        mov (16|M16)             r16.0<1>:d    -1:w                              
        shl (16|M0)              r4.0<1>:d     r3.0<0;1,0>:w     r4.0<1;1,0>:d    {A@1}
        shl (16|M16)             r14.0<1>:d    r3.0<0;1,0>:w     r20.0<1;1,0>:d  
L21088:
        join (32|M0)                         L21688                                
L21104:
        bfn.0x28 (16|M0)         r4.0<1>:ud    r30.0<1;0>:ud     r4.0<1;0>:ud      r9.0<0>:ud       {I@3} // s0&(s1^s2)
        bfn.0x28 (16|M16)        r12.0<1>:ud   r52.0<1;0>:ud     r14.0<1;0>:ud     r9.0<0>:ud       {I@3} // s0&(s1^s2)
        cmp (16|M0)   (ne)f0.0   null<1>:d     r4.0<1;1,0>:d     0:w               {Compacted,I@2}
        cmp (16|M16)  (ne)f0.0   null<1>:d     r12.0<1;1,0>:d    0:w               {I@2}
        bfn.0x28 (16|M16)        r16.0<1>:ud   r50.0<1;0>:ud     r16.0<1;0>:ud     r9.0<0>:ud       // s0&(s1^s2)
        bfn.0x28 (16|M0)         r14.0<1>:ud   r24.0<1;0>:ud     r18.0<1;0>:ud     r9.0<0>:ud       // s0&(s1^s2)
(~f0.0) cmp (16|M16)  (ne)f0.0   null<1>:d     r16.0<1;1,0>:d    0:w               {I@2}
(~f0.0) cmp (16|M0)   (ne)f0.0   null<1>:d     r14.0<1;1,0>:d    0:w               {I@2}
(W)     mov (1|M0)               r3.0<1>:hf    -qnan(0x1FF):hf                             
(f0.0)  sel (16|M0)              r18.0<1>:d    r3.0<0;1,0>:w     0:w               {F@1}
(f0.0)  sel (16|M16)             r20.0<1>:d    r3.0<0;1,0>:w     0:w              
        and (16|M0)   (ne)f0.0   r14.0<1>:d    r70.0<1;1,0>:d    63:w               {Compacted}
        and (16|M16)  (ne)f0.0   r2.0<1>:d     r72.0<1;1,0>:d    63:w              
        mov (16|M0)              r48.0<1>:d    -r18.0<1;1,0>:d                  {I@4}
        mov (16|M16)             r60.0<1>:d    -r20.0<1;1,0>:d                  {I@4}
(f0.0)  goto (32|M0)                         L21384                  L21384                
L21344:
        mov (16|M0)              r18.0<1>:f    r30.0<1;1,0>:f                   {Compacted,I@3}
        mov (16|M16)             r40.0<1>:d    r52.0<1;1,0>:d                  
        goto (32|M0)                         L21384                  L21608                
L21384:
        join (32|M0)                         L21608                                
L21400:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r14.0<1;1,0>:ud   0x20:uw             
        cmp (16|M16)  (lt)f1.0   null<1>:d     r2.0<1;1,0>:ud    0x20:uw             
(f1.0)  goto (32|M0)                         L21512                  L21512                
L21448:
        add (16|M0)              r4.0<1>:d     r14.0<1;1,0>:d    -32:w               {Compacted}
        add (16|M16)             r12.0<1>:d    r2.0<1;1,0>:d     -32:w               {Compacted}
        shr (16|M0)              r18.0<1>:ud   r24.0<1;1,0>:ud   r4.0<1;1,0>:d    {A@1}
        shr (16|M16)             r40.0<1>:ud   r50.0<1;1,0>:ud   r12.0<1;1,0>:d   {I@2}
        goto (32|M0)                         L21512                  L21608                
L21512:
        join (32|M0)                         L21608                                
L21528:
        add (16|M0)              r4.0<1>:d     -r14.0<1;1,0>:d   32:w               {Compacted}
        add (16|M16)             r12.0<1>:d    -r2.0<1;1,0>:d    32:w               {Compacted}
        shr (16|M16)             r16.0<1>:ud   r52.0<1;1,0>:ud   r2.0<1;1,0>:d   
        shl (16|M0)              r4.0<1>:d     r24.0<1;1,0>:d    r4.0<1;1,0>:d    {Compacted,I@3}
        shr (16|M0)              r14.0<1>:ud   r30.0<1;1,0>:ud   r14.0<1;1,0>:d  
        shl (16|M16)             r12.0<1>:d    r50.0<1;1,0>:d    r12.0<1;1,0>:d   {Compacted,I@4}
        or (16|M0)               r18.0<1>:d    r14.0<1;1,0>:d    r4.0<1;1,0>:d    {Compacted,I@2}
        or (16|M16)              r40.0<1>:d    r16.0<1;1,0>:d    r12.0<1;1,0>:d   {Compacted,I@2}
L21608:
        join (32|M0)                         L21688                                
L21624:
        mov (16|M0)              r24.0<1>:f    r18.0<1;1,0>:f                   {Compacted,I@3}
        mov (16|M16)             r6.0<1>:f     r40.0<1;1,0>:f                   {Compacted,I@2}
        mov (16|M0)              r18.0<1>:d    r42.0<1;1,0>:d                   {F@2}
        mov (16|M16)             r40.0<1>:d    r64.0<1;1,0>:d                   {F@1}
        goto (32|M0)                         L21688                  L21832                
L21688:
        join (32|M0)                         L21832                                
L21704:
        shr (16|M0)              r18.0<1>:ud   r30.0<1;1,0>:ud   2:w              
        shr (16|M16)             r40.0<1>:ud   r52.0<1;1,0>:ud   2:w              
        and (16|M0)              r44.0<1>:d    r30.0<1;1,0>:d    1:w               {Compacted}
        and (16|M16)             r58.0<1>:d    r52.0<1;1,0>:d    1:w               {Compacted}
        mov (16|M0)              r48.0<1>:d    0:w                              
        mov (16|M16)             r60.0<1>:d    0:w                              
        mov (16|M0)              r24.0<1>:f    r18.0<1;1,0>:f                   {Compacted,I@6}
        mov (16|M16)             r6.0<1>:f     r40.0<1;1,0>:f                   {Compacted,I@5}
        shr (16|M0)              r18.0<1>:ud   r30.0<1;1,0>:ud   1:w               {F@2}
        shr (16|M16)             r40.0<1>:ud   r52.0<1;1,0>:ud   1:w               {F@1}
L21832:
        join (32|M0)                         L22680                                
L21848:
        shl (16|M0)              r4.0<1>:d     r18.0<1;1,0>:d    2:w               {Compacted,I@3}
        shl (16|M16)             r12.0<1>:d    r40.0<1;1,0>:d    2:w               {Compacted,I@3}
        shl (16|M0)              r14.0<1>:d    r44.0<1;1,0>:d    1:w               {Compacted}
        shl (16|M16)             r16.0<1>:d    r58.0<1;1,0>:d    1:w               {Compacted}
        and (16|M0)              r4.0<1>:d     r4.0<1;1,0>:d     4:w               {Compacted,I@4}
        and (16|M16)             r12.0<1>:d    r12.0<1;1,0>:d    4:w               {Compacted,I@4}
        bfn.0xFE (16|M0)         r4.0<1>:ud    r4.0<1;0>:ud      r14.0<1;0>:ud     r48.0<1>:ud      {I@2} // s0|s1|s2
        bfn.0xFE (16|M16)        r14.0<1>:ud   r12.0<1;0>:ud     r16.0<1;0>:ud     r60.0<1>:ud      {I@2} // s0|s1|s2
        cmp (16|M0)   (eq)f0.0   null<1>:d     r4.0<1;1,0>:d     0:w               {Compacted,I@2}
        cmp (16|M16)  (eq)f0.0   null<1>:d     r14.0<1;1,0>:d    0:w               {I@2}
        and (16|M0)              r20.0<1>:d    r24.0<1;1,0>:d    8388607:d              
        and (16|M16)             r42.0<1>:d    r6.0<1;1,0>:d     8388607:d              
(~f0.0) goto (32|M0)                         L22048                  L22048                
L22000:
        mov (16|M0)              r4.0<1>:d     0:w                              
        mov (16|M16)             r12.0<1>:d    0:w                              
        goto (32|M0)                         L22048                  L22288                
L22048:
        join (32|M0)                         L22288                                
L22064:
        cmp (16|M0)   (gt)f1.0   null<1>:d     r4.0<1;1,0>:ud    0x4:uw              {I@4}
        cmp (16|M16)  (gt)f1.0   null<1>:d     r14.0<1;1,0>:ud   0x4:uw             
(~f1.0) goto (32|M0)                         L22160                  L22160                
L22112:
        mov (16|M0)              r4.0<1>:d     1:w                              
        mov (16|M16)             r12.0<1>:d    1:w                              
        goto (32|M0)                         L22160                  L22288                
L22160:
        join (32|M0)                         L22288                                
L22176:
        and (16|M0)   (ne)f1.0   null<1>:d     r24.0<1;1,0>:d    1:w              
        and (16|M16)  (ne)f1.0   null<1>:d     r6.0<1;1,0>:d     1:w              
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r4.0<1;1,0>:d     4:w               {I@6}
(f1.0)  cmp (16|M16)  (eq)f1.0   null<1>:d     r14.0<1;1,0>:d    4:w              
(W)     mov (1|M0)               r3.0<1>:hf    0x1:hf                             
(f1.0)  sel (16|M0)              r4.0<1>:d     r3.0<0;1,0>:w     0:w               {F@1}
(f1.0)  sel (16|M16)             r12.0<1>:d    r3.0<0;1,0>:w     0:w              
L22288:
        join (32|M0)                         L22680                                
L22304:
        add (16|M0)              r14.0<1>:d    r20.0<1;1,0>:d    r4.0<1;1,0>:d    {Compacted,I@3}
        add (16|M16)             r6.0<1>:d     r42.0<1;1,0>:d    r12.0<1;1,0>:d   {Compacted,I@3}
        cmp (16|M0)   (gt)f0.0   null<1>:d     r14.0<1;1,0>:ud   0x7FFFFF:ud              {I@2}
        cmp (16|M16)  (gt)f0.0   null<1>:d     r6.0<1;1,0>:ud    0x7FFFFF:ud              {I@2}
        add3 (16|M0)             r4.0<1>:d     r34.0<1;0>:d      r56.0<1;0>:d      82:w              
        add3 (16|M16)            r12.0<1>:d    r32.0<1;0>:d      r54.0<1;0>:d      82:w              
(f0.0)  sel (16|M0)              r18.0<1>:d    r4.0<1;1,0>:d     r66.0<1;1,0>:d   {Compacted,I@2}
(f0.0)  sel (16|M16)             r2.0<1>:d     r12.0<1;1,0>:d    r68.0<1;1,0>:d   {I@2}
        cmp (16|M0)   (eq)f1.0   null<1>:d     r18.0<1;1,0>:d    255:w               {I@2}
        cmp (16|M16)  (eq)f1.0   null<1>:d     r2.0<1;1,0>:d     255:w               {I@2}
(f1.0)  goto (32|M0)                         L22584                  L22584                
L22456:
(~f0.0) sel (16|M0)              r4.0<1>:d     r14.0<1;1,0>:d    0:w              
(~f0.0) sel (16|M16)             r12.0<1>:d    r6.0<1;1,0>:d     0:w              
        and (16|M16)             r16.0<1>:d    r28.0<1;1,0>:d    -2147483648:d              
        shl (16|M0)              r18.0<1>:d    r18.0<1;1,0>:d    23:w               {Compacted}
        shl (16|M16)             r20.0<1>:d    r2.0<1;1,0>:d     23:w               {Compacted}
        and (16|M0)              r14.0<1>:d    r22.0<1;1,0>:d    -2147483648:d              
        bfn.0xFE (16|M16)        r26.0<1>:ud   r16.0<1;0>:ud     r20.0<1;0>:ud     r12.0<1>:ud      {I@2} // s0|s1|s2
        bfn.0xFE (16|M0)         r22.0<1>:ud   r14.0<1;0>:ud     r18.0<1;0>:ud     r4.0<1>:ud       {I@2} // s0|s1|s2
        goto (32|M0)                         L22584                  L23448                
L22584:
        join (32|M0)                         L22680                                
L22600:
        cmp (16|M0)   (gt)f1.0   null<1>:d     r22.0<1;1,0>:d    -1:w               {I@3}
        cmp (16|M16)  (gt)f1.0   null<1>:d     r28.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r3.0<1>:f     inf:f                               {Compacted}
(f1.0)  sel (16|M0)              r22.0<1>:f    r3.0<0;1,0>:f     -inf:f               {Compacted,A@1}
(f1.0)  sel (16|M16)             r26.0<1>:f    r3.0<0;1,0>:f     -inf:f              
        goto (32|M0)                         L22680                  L23448                
L22680:
        join (32|M0)                         L23136                                
L22696:
        and (16|M0)   (ne)f0.0   r12.0<1>:d    r56.0<1;1,0>:d    63:w               {Compacted}
        and (16|M16)  (ne)f0.0   r4.0<1>:d     r54.0<1;1,0>:d    63:w              
(f0.0)  goto (32|M0)                         L22784                  L22784                
L22736:
        mov (16|M0)              r12.0<1>:d    -1:w                              
        mov (16|M16)             r6.0<1>:d     -1:w                              
        goto (32|M0)                         L22784                  L22960                
L22784:
        join (32|M0)                         L22960                                
L22800:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r12.0<1;1,0>:ud   0x20:uw              {A@1}
        cmp (16|M16)  (lt)f1.0   null<1>:d     r4.0<1;1,0>:ud    0x20:uw             
(f1.0)  goto (32|M0)                         L22896                  L22896                
L22848:
        mov (16|M0)              r12.0<1>:d    0:w                              
        mov (16|M16)             r6.0<1>:d     0:w                              
        goto (32|M0)                         L22896                  L22960                
L22896:
        join (32|M0)                         L22960                                
L22912:
(W)     mov (1|M0)               r3.0<1>:hf    -qnan(0x1FF):hf                             
        shl (16|M0)              r12.0<1>:d    r3.0<0;1,0>:w     r12.0<1;1,0>:d   {A@1}
        shl (16|M16)             r6.0<1>:d     r3.0<0;1,0>:w     r4.0<1;1,0>:d   
L22960:
        join (32|M0)                         L23136                                
L22976:
        bfn.0x28 (16|M0)         r4.0<1>:ud    r30.0<1;0>:ud     r12.0<1;0>:ud     r9.0<0>:ud       {I@3} // s0&(s1^s2)
        add (16|M0)              r14.0<1>:d    -r56.0<1;1,0>:d   23:w               {Compacted}
        add (16|M16)             r16.0<1>:d    -r54.0<1;1,0>:d   23:w               {Compacted}
        bfn.0x28 (16|M16)        r12.0<1>:ud   r52.0<1;0>:ud     r6.0<1;0>:ud      r9.0<0>:ud       {I@5} // s0&(s1^s2)
        and (16|M0)              r18.0<1>:d    r22.0<1;1,0>:d    -2147483648:d              
        and (16|M16)             r20.0<1>:d    r28.0<1;1,0>:d    -2147483648:d              
        shl (16|M16)             r24.0<1>:d    r68.0<1;1,0>:d    23:w               {Compacted}
        shl (16|M0)              r4.0<1>:d     r4.0<1;1,0>:d     r14.0<1;1,0>:d   {Compacted,I@6}
        shl (16|M16)             r12.0<1>:d    r12.0<1;1,0>:d    r16.0<1;1,0>:d   {Compacted,I@5}
        shl (16|M0)              r22.0<1>:d    r66.0<1;1,0>:d    23:w               {Compacted}
        bfn.0xFE (16|M16)        r26.0<1>:ud   r20.0<1;0>:ud     r24.0<1;0>:ud     r12.0<1>:ud      {I@2} // s0|s1|s2
        bfn.0xFE (16|M0)         r22.0<1>:ud   r18.0<1;0>:ud     r22.0<1;0>:ud     r4.0<1>:ud       {I@2} // s0|s1|s2
        goto (32|M0)                         L23136                  L23448                
L23136:
        join (32|M0)                         L23224                                
L23152:
        cmp (16|M0)   (gt)f0.0   null<1>:d     r22.0<1;1,0>:d    -1:w               {Compacted,I@3}
        cmp (16|M16)  (gt)f0.0   null<1>:d     r28.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r3.0<1>:f     inf:f                               {Compacted}
(f0.0)  sel (16|M0)              r22.0<1>:f    r3.0<0;1,0>:f     -inf:f               {Compacted,A@1}
(f0.0)  sel (16|M16)             r26.0<1>:f    r3.0<0;1,0>:f     -inf:f              
        goto (32|M0)                         L23224                  L23448                
L23224:
        join (32|M0)                         L23312                                
L23240:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r22.0<1;1,0>:d    0:w               {Compacted,F@2}
        cmp (16|M16)  (lt)f1.0   null<1>:d     r28.0<1;1,0>:d    0:w              
(W)     mov (1|M0)               r3.0<1>:f     -0.0:f                               {Compacted}
(f1.0)  sel (16|M0)              r22.0<1>:f    r3.0<0;1,0>:f     0.0:f               {Compacted,A@1}
(f1.0)  sel (16|M16)             r26.0<1>:f    r3.0<0;1,0>:f     0.0:f              
        goto (32|M0)                         L23312                  L23448                
L23312:
        join (32|M0)                         L23400                                
L23328:
        cmp (16|M0)   (gt)f0.0   null<1>:d     r22.0<1;1,0>:d    -1:w               {Compacted,F@2}
        cmp (16|M16)  (gt)f0.0   null<1>:d     r28.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r3.0<1>:f     inf:f                               {Compacted}
(f0.0)  sel (16|M0)              r22.0<1>:f    r3.0<0;1,0>:f     -inf:f               {Compacted,A@1}
(f0.0)  sel (16|M16)             r26.0<1>:f    r3.0<0;1,0>:f     -inf:f              
        goto (32|M0)                         L23400                  L23448                
L23400:
        join (32|M0)                         L23448                                
L23416:
        bfn.0xF8 (16|M0)         r22.0<1>:ud   r22.0<1;0>:ud     r9.7<0;0>:ud      r9.3<0>:ud       {F@2} // s0&s1|s2
        bfn.0xF8 (16|M16)        r26.0<1>:ud   r28.0<1;0>:ud     r9.7<0;0>:ud      r9.3<0>:ud       {F@1} // s0&s1|s2
L23448:
        join (32|M0)                         L23552                                
L23464:
(W)     add (1|M0)               r9.2<1>:d     r9.2<0;1,0>:d     1:w              
        sel (16|M0)   (gt)f0.0   r88.0<1>:f    (abs)r22.0<1;1,0>:f  r88.0<1;1,0>:f {Compacted,I@4}
(W)     cmp (16|M0)   (lt)f0.0   null<1>:d     r9.2<0;1,0>:ud    r9.1<0;1,0>:ud   {I@1}
(W)     cmp (16|M16)  (lt)f0.0   null<1>:d     r9.2<0;1,0>:ud    r9.1<0;1,0>:ud  
        sel (16|M16)  (gt)f0.0   r86.0<1>:f    (abs)r26.0<1;1,0>:f  r86.0<1;1,0>:f
(f0.0)  goto.b (32|M0)                       L23552                  L1272                
L23552:
        join (32|M0)                         L46248                                
L23568:
        sync.nop                             null                             {Compacted,F@2}
        math.inv (16|M0)         r4.0<1>:f     r88.0<1;1,0>:f                   {$9}
        cmp (16|M0)   (gt)f1.0   null<1>:f     r88.0<1;1,0>:f    0.0:f              
        sync.nop                             null                             {Compacted,F@2}
        math.inv (16|M16)        r12.0<1>:f    r86.0<1;1,0>:f                   {$10}
        cmp (16|M16)  (gt)f1.0   null<1>:f     r86.0<1;1,0>:f    0.0:f              
        mul (16|M0)              acc0.0<1>:f   r4.0<1;1,0>:f     127.0:f               {$9.dst}
        mul (16|M16)             acc2.0<1>:f   r12.0<1;1,0>:f    127.0:f               {$10.dst}
        mul (16|M0)              r106.0<1>:f   r88.0<1;1,0>:f    7.874016e-03:f              
        mul (16|M16)             r108.0<1>:f   r86.0<1;1,0>:f    7.874016e-03:f              
(f1.0)  sel (16|M0)              r88.0<1>:f    acc0.0<1;1,0>:f   0.0:f               {Compacted}
(f1.0)  sel (16|M16)             r86.0<1>:f    acc2.0<1;1,0>:f   0.0:f              
(W)     mov (1|M0)               r9.2<1>:d     0:w                              
L23752:
        sync.nop                             null                             {Compacted,$11.src}
        add (16|M0)              r4.0<1>:d     r9.2<0;1,0>:d     r92.0<1;1,0>:d   {Compacted,A@1}
        add (16|M16)             r12.0<1>:d    r9.2<0;1,0>:d     r90.0<1;1,0>:d   {Compacted,F@5}
(W)     mov (1|M0)               a0.0<1>:ud    r9.5<0;1,0>:d                    {A@1}
        shl (16|M0)              r4.0<1>:d     r4.0<1;1,0>:d     2:w               {Compacted,I@3}
        shl (16|M16)             r12.0<1>:d    r12.0<1;1,0>:d    2:w               {Compacted,I@3}
        send.ugm (16|M0)         r14      r4      null:0  a0.0        0x24280500           {ExBSO,A@2,$13} // wr:2+0, rd:2; load.ugm.d32.a32.ca.ca.bss[a0.0]
        send.ugm (16|M16)        r16      r12     null:0  a0.0        0x24280500           {ExBSO,A@1,$14} // wr:2+0, rd:2; load.ugm.d32.a32.ca.ca.bss[a0.0]
(W)     mov (1|M0)               r3.0<1>:hf    0x1:hf                             
(W)     mov (1|M0)               f0.0<1>:ud    r10.2<0;1,0>:ud                 
        sync.nop                             null                             {Compacted,$13.src}
(f0.0)  sel (16|M0)              r5.0<1>:uw    r3.0<0;1,0>:uw    0x0:uw              {Compacted,F@1}
        mov (16|M0)              r22.0<1>:f    r14.0<1;1,0>:d                   {Compacted,$13.dst}
        mov (16|M16)             r26.0<1>:f    r16.0<1;1,0>:d                   {Compacted,$14.dst}
        shr (16|M0)              r18.0<1>:ud   r22.0<1;1,0>:ud   23:w               {F@2}
        shr (16|M16)             r12.0<1>:ud   r26.0<1;1,0>:ud   23:w               {F@1}
        and (16|M0)   (ne)f1.0   r16.0<1>:d    r22.0<1;1,0>:d    8388607:d              
        and (16|M16)  (ne)f1.0   r14.0<1>:d    r26.0<1;1,0>:d    8388607:d              
        and (16|M0)              r24.0<1>:d    r18.0<1;1,0>:d    255:w               {Compacted,I@4}
        and (16|M16)             r20.0<1>:d    r12.0<1;1,0>:d    255:w               {Compacted,I@4}
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r24.0<1;1,0>:d    255:w               {I@2}
(f1.0)  cmp (16|M16)  (eq)f1.0   null<1>:d     r20.0<1;1,0>:d    255:w               {I@2}
(f1.0)  sel (16|M0)              acc2.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw             
(f1.0)  sel (16|M16)             acc0.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw             
(W)     mov (1|M0)               f1.0<1>:ud    r10.2<0;1,0>:ud                 
        or (16|M0)    (ne)f1.0   null<1>:uw    acc2.0<1;1,0>:uw  r5.0<1;1,0>:uw  
(f1.0)  sel (16|M16)             acc2.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw             
        or (16|M16)   (ne)f1.0   null<1>:uw    acc0.0<1;1,0>:uw  acc2.0<1;1,0>:uw
(~f1.0) goto (32|M0)                         L24168                  L24168                
L24128:
        mov (16|M0)              r22.0<1>:ud   0x7FC00000:ud                             
        mov (16|M16)             r28.0<1>:f    qnan(0x0):f                               {Compacted}
        goto (32|M0)                         L24168                  L34576                
L24168:
        join (32|M0)                         L34576                                
L24184:
        cmp (16|M0)   (eq)f1.0   null<1>:d     r16.0<1;1,0>:d    0:w              
        cmp (16|M16)  (eq)f1.0   null<1>:d     r14.0<1;1,0>:d    0:w              
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r24.0<1;1,0>:d    255:w              
(f1.0)  cmp (16|M16)  (eq)f1.0   null<1>:d     r20.0<1;1,0>:d    255:w              
(W)     mov (1|M0)               r3.0<1>:hf    0x1:hf                              {I@7}
(W)     mov (1|M0)               f0.0<1>:ud    r10.3<0;1,0>:ud                 
(f1.0)  sel (16|M0)              acc0.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw              {F@1}
(f1.0)  sel (16|M16)             r6.0<1>:uw    r3.0<0;1,0>:uw    0x0:uw             
(W)     mov (1|M0)               f1.0<1>:ud    r10.3<0;1,0>:ud                 
(f0.0)  sel (16|M0)              acc2.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw             
        or (16|M0)    (ne)f0.0   null<1>:uw    acc0.0<1;1,0>:uw  acc2.0<1;1,0>:uw
(f1.0)  sel (16|M16)             acc0.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw             
        or (16|M16)   (ne)f0.0   null<1>:uw    r6.0<1;1,0>:uw    acc0.0<1;1,0>:uw {I@5}
        xor (16|M0)              r22.0<1>:d    r96.0<1;1,0>:d    r22.0<1;1,0>:d   {Compacted}
        xor (16|M16)             r26.0<1>:d    r94.0<1;1,0>:d    r26.0<1;1,0>:d   {Compacted}
(f0.0)  goto (32|M0)                         L34528                  L34528                
L24424:
        cmp (16|M16)  (eq)f1.0   null<1>:d     r102.0<1;1,0>:d   0:w              
        or (16|M16)   (eq)f0.0   null<1>:d     r20.0<1;1,0>:d    r14.0<1;1,0>:d  
        cmp (16|M0)   (eq)f0.0   null<1>:d     r104.0<1;1,0>:d   0:w               {Compacted}
(W)     mov (1|M0)               r3.0<1>:hf    0x1:hf                              {I@7}
        or (16|M0)               r4.0<1>:d     r24.0<1;1,0>:d    r16.0<1;1,0>:d   {Compacted}
(f0.0)  sel (16|M16)             acc0.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw              {F@1}
(f1.0)  sel (16|M16)             acc2.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw             
(~f0.0) cmp (16|M0)   (eq)f0.0   null<1>:d     r4.0<1;1,0>:d     0:w               {I@3}
        or (16|M16)   (ne)f0.0   null<1>:uw    acc0.0<1;1,0>:uw  acc2.0<1;1,0>:uw
(~f0.0) goto (32|M0)                         L24608                  L24608                
L24568:
        mov (16|M0)              r22.0<1>:ud   0x0:ud                             
        mov (16|M16)             r28.0<1>:f    0.0:f                               {Compacted}
        goto (32|M0)                         L24608                  L34576                
L24608:
        join (32|M0)                         L34528                                
L24624:
        cmp (16|M0)   (eq)f0.0   null<1>:d     r24.0<1;1,0>:d    0:w               {Compacted}
        cmp (16|M16)  (eq)f0.0   null<1>:d     r20.0<1;1,0>:d    0:w              
        add (16|M0)              r54.0<1>:d    r24.0<1;1,0>:d    -127:w               {Compacted}
        add (16|M16)             r52.0<1>:d    r20.0<1;1,0>:d    -127:w               {Compacted}
(f0.0)  mov (16|M0)              r54.0<1>:d    -126:w                              
(f0.0)  mov (16|M16)             r52.0<1>:d    -126:w                              
        add (16|M0)              r50.0<1>:d    r54.0<1;1,0>:d    r84.0<1;1,0>:d   {Compacted,I@2}
        add (16|M16)             r48.0<1>:d    r52.0<1;1,0>:d    r82.0<1;1,0>:d   {Compacted,I@2}
        cmp (16|M0)   (gt)f1.0   null<1>:d     r50.0<1;1,0>:d    127:w               {I@2}
        cmp (16|M16)  (gt)f1.0   null<1>:d     r48.0<1;1,0>:d    127:w               {I@2}
(f1.0)  goto (32|M0)                         L34440                  L34440                
L24760:
        or (16|M0)    (eq)f1.0   null<4>:b     r18.0<1;1,0>:d    r100.0<1;1,0>:d 
        or (16|M16)   (eq)f1.0   null<4>:b     r12.0<1;1,0>:d    r98.0<1;1,0>:d  
(f1.0)  goto (32|M0)                         L34352                  L34352                
L24808:
(W)     mov (1|M0)               r3.0<1>:hf    0.0:hf                             
(W)     mov (1|M0)               r10.7<1>:d    0:w                              
(f0.0)  sel (16|M0)              r4.0<1>:d     r3.0<0;1,0>:w     8388608:d               {F@1}
        or (16|M0)               r4.0<1>:d     r4.0<1;1,0>:d     r16.0<1;1,0>:d   {Compacted,I@1}
(f0.0)  sel (16|M16)             r12.0<1>:d    r3.0<0;1,0>:w     8388608:d              
        mul (8|M0)               acc0.0<1>:ud  r4.0<1;1,0>:ud    r38.0<2;1,0>:uw  {I@2}
        or (16|M16)              r12.0<1>:d    r12.0<1;1,0>:d    r14.0<1;1,0>:d   {Compacted,I@2}
        mach (8|M0)              r14.0<1>:ud   r4.0<1;1,0>:ud    r38.0<1;1,0>:ud  {AccWrEn,Compacted}
(W)     mov (1|M0)               r2.1<1>:f     -0.0:f                               {Compacted}
        mov (8|M0)               r16.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mul (8|M8)               acc0.0<1>:ud  r5.0<1;1,0>:ud    r39.0<2;1,0>:uw 
        mach (8|M8)              r15.0<1>:ud   r5.0<1;1,0>:ud    r39.0<1;1,0>:ud  {AccWrEn}
(W)     mov (2|M0)               r10.4<1>:d    0:w                              
        mov (8|M8)               r17.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mul (8|M16)              acc0.0<1>:ud  r12.0<1;1,0>:ud   r36.0<2;1,0>:uw  {I@7}
        mach (8|M16)             r18.0<1>:ud   r12.0<1;1,0>:ud   r36.0<1;1,0>:ud  {AccWrEn}
        mov (16|M0)              r42.0<1>:f    r14.0<1;1,0>:f                   {Compacted,A@5}
        mov (8|M16)              r20.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mul (8|M24)              acc0.0<1>:ud  r13.0<1;1,0>:ud   r37.0<2;1,0>:uw 
        mach (8|M24)             r19.0<1>:ud   r13.0<1;1,0>:ud   r37.0<1;1,0>:ud  {AccWrEn}
        mov (16|M0)              r46.0<1>:f    r16.0<1;1,0>:f                   {Compacted,I@6}
        mov (8|M24)              r21.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mov (16|M16)             r40.0<1>:f    r18.0<1;1,0>:f                   {Compacted,A@2}
        mov (16|M16)             r44.0<1>:f    r20.0<1;1,0>:f                   {Compacted,I@1}
L25096:
(W)     shl (1|M0)               r3.0<1>:d     r2.1<0;1,0>:d     31:w               {Compacted,F@5}
(W)     shr (1|M0)               r3.1<1>:ud    r10.7<0;1,0>:ud   1:w              
(W)     addc (1|M0)              r7.0<1>:ud    r10.4<0;1,0>:ud   0x1:ud              {AccWrEn}
(W)     or (1|M0)                r10.7<1>:d    r3.1<0;1,0>:d     r3.0<0;1,0>:d    {I@2}
        bfn.0xA8 (16|M0)         r12.0<1>:ud   r46.0<1;0>:ud     r3.1<0;0>:ud      r3.0<0>:ud       {F@3} // s0&(s1|s2)
        cmp (16|M0)   (eq)f0.0   null<1>:d     r12.0<1;1,0>:d    r10.7<0;1,0>:d   {I@1}
(W)     mov (1|M0)               r4.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        bfn.0xA8 (16|M16)        r14.0<1>:ud   r44.0<1;0>:ud     r3.1<0;0>:ud      r3.0<0>:ud       {F@1} // s0&(s1|s2)
(W)     add (1|M0)               r2.0<1>:ud    r4.0<0;1,0>:ud    r10.5<0;1,0>:ud  {Compacted,I@2}
(W)     mov (1|M0)               r4.0<1>:ud    f0.0<0;1,0>:ud                   {Compacted}
(W)     shr (1|M0)               r10.6<1>:ud   r2.1<0;1,0>:ud    1:w              
(W)     mov (1|M0)               f0.0<1>:ud    r4.0<0;1,0>:ud                   {I@2}
        cmp (16|M16)  (eq)f0.0   null<1>:d     r14.0<1;1,0>:d    r10.7<0;1,0>:d  
        and (16|M0)              r16.0<1>:d    r42.0<1;1,0>:d    r10.6<0;1,0>:d   {Compacted,I@3}
(W)     mov (1|M0)               r4.0<1>:ud    f0.0<0;1,0>:ud                   {Compacted}
(W)     cmp (16|M0)   (gt)f1.0   null<1>:d     r10.4<0;1,0>:ud   0x3E:uw             
(W)     mov (1|M0)               f0.0<1>:ud    r4.0<0;1,0>:ud                   {I@2}
        and (16|M16)             r18.0<1>:d    r40.0<1;1,0>:d    r10.6<0;1,0>:d   {Compacted}
(W&f1.0) cmp (16|M0)  (eq)f1.0   null<1>:d     r10.5<0;1,0>:d    0:w              
(f0.0)  cmp (16|M0)   (eq)f0.0   null<1>:d     r16.0<1;1,0>:d    r10.6<0;1,0>:d  
(W&~f1.0) cmp (16|M0) (gt)f1.0   null<1>:d     r10.5<0;1,0>:ud   0x0:uw             
(W)     mov (1|M0)               r4.0<1>:ud    f0.0<0;1,0>:ud                   {Compacted}
(W)     cmp (16|M16)  (gt)f1.0   null<1>:d     r10.4<0;1,0>:ud   0x3E:uw             
(W)     mov (1|M0)               f0.0<1>:ud    r4.0<0;1,0>:ud                   {I@2}
(W)     mov (1|M0)               r3.0<1>:hf    0x1:hf                             
(W&f1.0) cmp (16|M16) (eq)f1.0   null<1>:d     r10.5<0;1,0>:d    0:w              
(f0.0)  cmp (16|M16)  (eq)f0.0   null<1>:d     r18.0<1;1,0>:d    r10.6<0;1,0>:d  
(f1.0)  sel (16|M0)              acc0.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw              {F@1}
(f0.0)  sel (16|M0)              acc2.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw             
(W)     mov (1|M0)               r4.0<1>:ud    f0.0<0;1,0>:ud                   {Compacted}
        or (16|M0)    (ne)f0.0   null<1>:uw    acc0.0<1;1,0>:uw  acc2.0<1;1,0>:uw
(W&~f1.0) cmp (16|M16) (gt)f1.0  null<1>:d     r10.5<0;1,0>:ud   0x0:uw             
(W)     mov (1|M0)               r3.1<1>:ud    f0.0<0;1,0>:ud                   {Compacted}
(W)     mov (1|M0)               f0.0<1>:ud    r4.0<0;1,0>:ud                   {I@4}
(f1.0)  sel (16|M16)             acc0.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw             
(W)     mov (1|M0)               f1.0<1>:ud    r3.1<0;1,0>:ud                   {I@3}
(f0.0)  sel (16|M16)             acc2.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw             
        or (16|M16)   (ne)f1.0   null<1>:uw    acc0.0<1;1,0>:uw  acc2.0<1;1,0>:uw
        mov (16|M0)              r64.0<1>:d    r10.4<0;1,0>:d                  
(W)     mov (1|M0)               r3.1<1>:ud    f1.0<0;1,0>:ud                   {Compacted}
        mov (16|M16)             r60.0<1>:d    r10.4<0;1,0>:d                  
(W)     mov (1|M0)               f0.0<1>:ud    r3.1<0;1,0>:ud                   {I@2}
        mov (16|M16)             r20.0<1>:d    r10.5<0;1,0>:d                  
        mov (16|M0)              r34.0<1>:f    r7.0<0;1,0>:f                    {Compacted,$12.src}
        mov (16|M16)             r32.0<1>:f    r7.0<0;1,0>:f                    {Compacted}
        mov (16|M0)              r30.0<1>:f    r2.0<0;1,0>:f                    {Compacted}
        mov (16|M16)             r24.0<1>:f    r2.0<0;1,0>:f                    {Compacted}
        mov (16|M0)              r16.0<1>:d    r10.5<0;1,0>:d                  
(f0.0)  goto (32|M0)                         L25824                  L25824                
L25760:
(W)     mov (1|M0)               r2.1<1>:d     r10.6<0;1,0>:d                  
(W)     mov (1|M0)               r10.4<1>:d    r7.0<0;1,0>:d                   
(W)     mov (1|M0)               r10.5<1>:d    r2.0<0;1,0>:d                   
(W)     jmpi                                 L25096                                
L25824:
        join (32|M0)                         L34352                                
L25840:
(W)     mov (1|M0)               r3.0<1>:f     8.68805e-44:f                              
(W)     mov (1|M0)               r4.0<1>:hf    0.0:hf                             
        subb (8|M0)              r58.0<1>:ud   r3.0<0;1,0>:ud    r64.0<1;1,0>:ud  {AccWrEn,Compacted,F@2}
        add3 (8|M0)              r72.0<1>:ud   -acc0.0<1;0>:ud   r4.0<0;0>:uw      -r16.0<1>:ud     {A@1}
        subb (8|M8)              r59.0<1>:ud   r3.0<0;1,0>:ud    r65.0<1;1,0>:ud  {AccWrEn}
        add3 (8|M8)              r73.0<1>:ud   -acc0.0<1;0>:ud   r4.0<0;0>:uw      -r17.0<1>:ud    
        subb (8|M16)             r56.0<1>:ud   r3.0<0;1,0>:ud    r60.0<1;1,0>:ud  {AccWrEn}
        add3 (16|M0)             r18.0<1>:d    r50.0<1;0>:d      r58.0<1;0>:d      -46:w               {I@3}
        add3 (8|M16)             r80.0<1>:ud   -acc0.0<1;0>:ud   r4.0<0;0>:uw      -r20.0<1>:ud    
        subb (8|M24)             r57.0<1>:ud   r3.0<0;1,0>:ud    r61.0<1;1,0>:ud  {AccWrEn}
        cmp (16|M0)   (gt)f0.0   null<1>:d     r18.0<1;1,0>:d    127:w               {Compacted,I@3}
        add3 (16|M16)            r66.0<1>:d    r48.0<1;0>:d      r56.0<1;0>:d      -46:w               {I@2}
        cmp (16|M16)  (gt)f0.0   null<1>:d     r66.0<1;1,0>:d    127:w               {I@1}
        add3 (16|M0)             r70.0<1>:d    r54.0<1;0>:d      r84.0<1;0>:d      r58.0<1>:d      
        add3 (8|M24)             r81.0<1>:ud   -acc0.0<1;0>:ud   r4.0<0;0>:uw      -r21.0<1>:ud    
        add3 (16|M16)            r52.0<1>:d    r52.0<1;0>:d      r82.0<1;0>:d      r56.0<1>:d      
(f0.0)  goto (32|M0)                         L34264                  L34264                
L26096:
        cmp (16|M0)   (gt)f1.0   null<1>:d     r18.0<1;1,0>:d    -127:w              
        cmp (16|M16)  (gt)f1.0   null<1>:d     r66.0<1;1,0>:d    -127:w              
(f1.0)  goto (32|M0)                         L30184                  L30184                
L26144:
        cmp (16|M0)   (lt)f0.0   null<1>:d     r18.0<1;1,0>:ud   0xFFFFFF6B:ud             
        cmp (16|M16)  (lt)f0.0   null<1>:d     r66.0<1;1,0>:ud   0xFFFFFF6B:ud             
(f0.0)  goto (32|M0)                         L29432                  L29432                
L26192:
(W)     mov (1|M0)               r3.0<1>:f     8.82818e-44:f                              
(W)     mov (1|M0)               r4.0<1>:hf    0.0:hf                              {I@7}
        subb (8|M0)              r30.0<1>:ud   r3.0<0;1,0>:ud    r64.0<1;1,0>:ud  {AccWrEn,Compacted,F@2}
        add3 (16|M16)            r68.0<1>:d    r48.0<1;0>:d      r56.0<1;0>:d      104:w              
        add3 (8|M0)              r12.0<1>:ud   -acc0.0<1;0>:ud   r4.0<0;0>:uw      -r16.0<1>:ud     {F@1}
        subb (8|M8)              r31.0<1>:ud   r3.0<0;1,0>:ud    r65.0<1;1,0>:ud  {AccWrEn}
        add3 (16|M0)             r34.0<1>:d    r50.0<1;0>:d      r58.0<1;0>:d      104:w              
        add3 (8|M8)              r13.0<1>:ud   -acc0.0<1;0>:ud   r4.0<0;0>:uw      -r17.0<1>:ud    
        subb (8|M16)             r54.0<1>:ud   r3.0<0;1,0>:ud    r60.0<1;1,0>:ud  {AccWrEn}
        cmp (16|M0)   (gt)f0.0   null<1>:d     r30.0<1;1,0>:ud   r34.0<1;1,0>:ud  {I@3}
        add3 (8|M16)             r14.0<1>:ud   -acc0.0<1;0>:ud   r4.0<0;0>:uw      -r20.0<1>:ud    
        subb (8|M24)             r55.0<1>:ud   r3.0<0;1,0>:ud    r61.0<1;1,0>:ud  {AccWrEn}
(W)     mov (1|M0)               r5.0<1>:hf    0x1:hf                             
        cmp (16|M16)  (gt)f1.0   null<1>:d     r54.0<1;1,0>:ud   r68.0<1;1,0>:ud  {I@1}
        add3 (8|M24)             r15.0<1>:ud   -acc0.0<1;0>:ud   r4.0<0;0>:uw      -r21.0<1>:ud    
(f0.0)  cmp (16|M0)   (eq)f0.0   null<1>:d     r12.0<1;1,0>:d    0:w              
(f1.0)  cmp (16|M16)  (eq)f1.0   null<1>:d     r14.0<1;1,0>:d    0:w               {I@2}
        cmp (16|M16)  (gt)f0.0   null<1>:d     r14.0<1;1,0>:ud   0x0:uw             
(f1.0)  sel (16|M16)             acc0.0<1>:uw  r5.0<0;1,0>:uw    0x0:uw              {F@1}
(f0.0)  sel (16|M16)             acc2.0<1>:uw  r5.0<0;1,0>:uw    0x0:uw             
(~f0.0) cmp (16|M0)   (gt)f0.0   null<1>:d     r12.0<1;1,0>:ud   0x0:uw             
        or (16|M16)   (ne)f0.0   null<1>:uw    acc2.0<1;1,0>:uw  acc0.0<1;1,0>:uw
(f0.0)  goto (32|M0)                         L26648                  L26648                
L26552:
        add3 (16|M0)             r4.0<1>:d     r70.0<1;0>:d      -r30.0<1;0>:d     104:w              
        add3 (16|M16)            r12.0<1>:d    r52.0<1;0>:d      -r54.0<1;0>:d     104:w              
        mov (16|M0)              r18.0<1>:d    0:w                              
        mov (16|M16)             r76.0<1>:d    0:w                              
        shl (16|M0)              r30.0<1>:d    r46.0<1;1,0>:d    r4.0<1;1,0>:d    {Compacted,I@4}
        shl (16|M16)             r78.0<1>:d    r44.0<1;1,0>:d    r12.0<1;1,0>:d   {Compacted,I@4}
        goto (32|M0)                         L26648                  L29336                
L26648:
        join (32|M0)                         L29336                                
L26664:
        add3 (16|M0)             r50.0<1>:d    r30.0<1;0>:d      -r70.0<1;0>:d     -104:w               {I@4}
        add3 (16|M16)            r6.0<1>:d     r54.0<1;0>:d      -r52.0<1;0>:d     -104:w              
        cmp (16|M0)   (lt)f1.0   null<1>:d     r50.0<1;1,0>:d    2:w               {Compacted,I@2}
        cmp (16|M16)  (lt)f1.0   null<1>:d     r6.0<1;1,0>:d     2:w               {I@2}
(f1.0)  goto (32|M0)                         L26888                  L26888                
L26736:
        cmp (16|M0)   (eq)f0.0   null<1>:d     r50.0<1;1,0>:d    2:w               {Compacted}
        cmp (16|M16)  (eq)f0.0   null<1>:d     r6.0<1;1,0>:d     2:w              
(~f0.0) goto (32|M0)                         L26888                  L26952                
L26776:
        shr (16|M0)              r18.0<1>:ud   r46.0<1;1,0>:ud   1:w              
        shr (16|M16)             r52.0<1>:ud   r44.0<1;1,0>:ud   1:w              
        and (16|M0)              r58.0<1>:d    r46.0<1;1,0>:d    1:w               {Compacted}
        and (16|M16)             r64.0<1>:d    r44.0<1;1,0>:d    1:w               {Compacted}
        mov (16|M0)              r34.0<1>:d    0:w                              
        mov (16|M16)             r70.0<1>:d    0:w                              
        mov (16|M0)              r30.0<1>:f    r18.0<1;1,0>:f                   {Compacted,I@6}
        mov (16|M16)             r60.0<1>:f    r52.0<1;1,0>:f                   {Compacted,I@5}
        goto (32|M0)                         L26888                  L28464                
L26888:
        join (32|M0)                         L26952                                
L26904:
        cmp (16|M0)   (eq)f1.0   null<1>:d     r50.0<1;1,0>:d    1:w              
        cmp (16|M16)  (eq)f1.0   null<1>:d     r6.0<1;1,0>:d     1:w              
(f1.0)  goto (32|M0)                         L26952                  L28368                
L26952:
        join (32|M0)                         L28368                                
L26968:
        add3 (16|M0)             r4.0<1>:d     r30.0<1;0>:d      -r34.0<1;0>:d     -1:w               {A@2}
        add3 (16|M16)            r12.0<1>:d    r54.0<1;0>:d      -r68.0<1;0>:d     -1:w              
        and (16|M0)   (ne)f0.0   r14.0<1>:d    r4.0<1;1,0>:d     63:w               {Compacted,I@2}
        and (16|M16)  (ne)f0.0   r2.0<1>:d     r12.0<1;1,0>:d    63:w               {I@2}
(f0.0)  goto (32|M0)                         L27080                  L27080                
L27040:
        mov (16|M0)              r72.0<1>:f    r46.0<1;1,0>:f                   {Compacted}
        mov (16|M16)             r74.0<1>:d    r44.0<1;1,0>:d                  
        goto (32|M0)                         L27080                  L27344                
L27080:
        join (32|M0)                         L27344                                
L27096:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r14.0<1;1,0>:ud   0x20:uw              {I@6}
        cmp (16|M16)  (lt)f1.0   null<1>:d     r2.0<1;1,0>:ud    0x20:uw              {I@6}
(f1.0)  goto (32|M0)                         L27208                  L27208                
L27144:
        add (16|M0)              r4.0<1>:d     r14.0<1;1,0>:d    -32:w               {Compacted}
        add (16|M16)             r12.0<1>:d    r2.0<1;1,0>:d     -32:w               {Compacted}
        shr (16|M0)              r18.0<1>:ud   r42.0<1;1,0>:ud   r4.0<1;1,0>:d    {I@2}
        shr (16|M16)             r52.0<1>:ud   r40.0<1;1,0>:ud   r12.0<1;1,0>:d   {A@2}
        goto (32|M0)                         L27208                  L27304                
L27208:
        join (32|M0)                         L27304                                
L27224:
        add (16|M0)              r4.0<1>:d     -r14.0<1;1,0>:d   32:w               {Compacted}
        add (16|M16)             r12.0<1>:d    -r2.0<1;1,0>:d    32:w               {Compacted}
        shr (16|M16)             r16.0<1>:ud   r44.0<1;1,0>:ud   r2.0<1;1,0>:d   
        shl (16|M0)              r4.0<1>:d     r42.0<1;1,0>:d    r4.0<1;1,0>:d    {Compacted,I@3}
        shr (16|M0)              r14.0<1>:ud   r46.0<1;1,0>:ud   r14.0<1;1,0>:d  
        shl (16|M16)             r12.0<1>:d    r40.0<1;1,0>:d    r12.0<1;1,0>:d   {Compacted,I@4}
        or (16|M0)               r18.0<1>:d    r14.0<1;1,0>:d    r4.0<1;1,0>:d    {Compacted,I@2}
        or (16|M16)              r52.0<1>:d    r16.0<1;1,0>:d    r12.0<1;1,0>:d   {Compacted,I@2}
L27304:
        join (32|M0)                         L27344                                
L27320:
        mov (16|M0)              r72.0<1>:f    r18.0<1;1,0>:f                   {Compacted,I@3}
        mov (16|M16)             r74.0<1>:d    r52.0<1;1,0>:d                   {I@2}
L27344:
        join (32|M0)                         L28368                                
L27360:
        add3 (16|M0)             r20.0<1>:d    r30.0<1;0>:d      -r34.0<1;0>:d     -2:w              
        add3 (16|M16)            r54.0<1>:d    r54.0<1;0>:d      -r68.0<1;0>:d     -2:w              
        and (16|M0)   (ne)f0.0   r14.0<1>:d    r20.0<1;1,0>:d    63:w               {Compacted,I@2}
        and (16|M16)  (ne)f0.0   r2.0<1>:d     r54.0<1;1,0>:d    63:w               {I@2}
(f0.0)  goto (32|M0)                         L27472                  L27472                
L27432:
        mov (16|M0)              r18.0<1>:f    r46.0<1;1,0>:f                   {Compacted}
        mov (16|M16)             r52.0<1>:d    r44.0<1;1,0>:d                  
        goto (32|M0)                         L27472                  L27696                
L27472:
        join (32|M0)                         L27696                                
L27488:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r14.0<1;1,0>:ud   0x20:uw              {I@6}
        cmp (16|M16)  (lt)f1.0   null<1>:d     r2.0<1;1,0>:ud    0x20:uw              {I@6}
(f1.0)  goto (32|M0)                         L27600                  L27600                
L27536:
        add (16|M0)              r4.0<1>:d     r14.0<1;1,0>:d    -32:w               {Compacted}
        add (16|M16)             r12.0<1>:d    r2.0<1;1,0>:d     -32:w               {Compacted}
        shr (16|M0)              r18.0<1>:ud   r42.0<1;1,0>:ud   r4.0<1;1,0>:d    {A@1}
        shr (16|M16)             r52.0<1>:ud   r40.0<1;1,0>:ud   r12.0<1;1,0>:d   {I@2}
        goto (32|M0)                         L27600                  L27696                
L27600:
        join (32|M0)                         L27696                                
L27616:
        add (16|M0)              r4.0<1>:d     -r14.0<1;1,0>:d   32:w               {Compacted}
        add (16|M16)             r12.0<1>:d    -r2.0<1;1,0>:d    32:w               {Compacted}
        shr (16|M16)             r16.0<1>:ud   r44.0<1;1,0>:ud   r2.0<1;1,0>:d   
        shl (16|M0)              r4.0<1>:d     r42.0<1;1,0>:d    r4.0<1;1,0>:d    {Compacted,I@3}
        shr (16|M0)              r14.0<1>:ud   r46.0<1;1,0>:ud   r14.0<1;1,0>:d  
        shl (16|M16)             r12.0<1>:d    r40.0<1;1,0>:d    r12.0<1;1,0>:d   {Compacted,I@4}
        or (16|M0)               r18.0<1>:d    r14.0<1;1,0>:d    r4.0<1;1,0>:d    {Compacted,I@2}
        or (16|M16)              r52.0<1>:d    r16.0<1;1,0>:d    r12.0<1;1,0>:d   {Compacted,I@2}
L27696:
        join (32|M0)                         L28368                                
L27712:
        and (16|M0)   (ne)f0.0   r4.0<1>:d     r20.0<1;1,0>:d    63:w               {Compacted}
        and (16|M16)  (ne)f0.0   r20.0<1>:d    r54.0<1;1,0>:d    63:w              
        and (16|M0)              r58.0<1>:d    r18.0<1;1,0>:d    1:w               {Compacted,I@5}
        and (16|M16)             r64.0<1>:d    r52.0<1;1,0>:d    1:w               {Compacted,I@5}
(f0.0)  goto (32|M0)                         L27848                  L27848                
L27768:
        mov (16|M0)              r4.0<1>:d     -1:w                              
        mov (16|M16)             r14.0<1>:d    -1:w                              
        mov (16|M0)              r18.0<1>:d    -1:w                              
        mov (16|M16)             r16.0<1>:d    -1:w                              
        goto (32|M0)                         L27848                  L28120                
L27848:
        join (32|M0)                         L28120                                
L27864:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r4.0<1;1,0>:ud    0x20:uw              {I@6}
        cmp (16|M16)  (lt)f1.0   null<1>:d     r20.0<1;1,0>:ud   0x20:uw             
(f1.0)  goto (32|M0)                         L28024                  L28024                
L27912:
        add (16|M0)              r4.0<1>:d     r4.0<1;1,0>:d     -32:w               {Compacted}
        add (16|M16)             r12.0<1>:d    r20.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r3.0<1>:hf    -qnan(0x1FF):hf                             
        mov (16|M16)             r14.0<1>:d    0:w                              
        shl (16|M0)              r18.0<1>:d    r3.0<0;1,0>:w     r4.0<1;1,0>:d    {A@1}
        shl (16|M16)             r16.0<1>:d    r3.0<0;1,0>:w     r12.0<1;1,0>:d   {I@3}
        mov (16|M0)              r4.0<1>:d     0:w                              
        goto (32|M0)                         L28024                  L28120                
L28024:
        join (32|M0)                         L28120                                
L28040:
(W)     mov (1|M0)               r3.0<1>:hf    -qnan(0x1FF):hf                              {I@4}
        mov (16|M0)              r18.0<1>:d    -1:w                              
        mov (16|M16)             r16.0<1>:d    -1:w                              
        shl (16|M0)              r4.0<1>:d     r3.0<0;1,0>:w     r4.0<1;1,0>:d    {A@1}
        shl (16|M16)             r14.0<1>:d    r3.0<0;1,0>:w     r20.0<1;1,0>:d  
L28120:
        join (32|M0)                         L28368                                
L28136:
        bfn.0x28 (16|M0)         r4.0<1>:ud    r46.0<1;0>:ud     r4.0<1;0>:ud      r9.0<0>:ud       {I@3} // s0&(s1^s2)
        bfn.0x28 (16|M16)        r12.0<1>:ud   r44.0<1;0>:ud     r14.0<1;0>:ud     r9.0<0>:ud       {I@3} // s0&(s1^s2)
        cmp (16|M0)   (ne)f0.0   null<1>:d     r4.0<1;1,0>:d     0:w               {Compacted,I@2}
        cmp (16|M16)  (ne)f0.0   null<1>:d     r12.0<1;1,0>:d    0:w               {I@2}
        bfn.0x28 (16|M16)        r16.0<1>:ud   r40.0<1;0>:ud     r16.0<1;0>:ud     r9.0<0>:ud       // s0&(s1^s2)
        bfn.0x28 (16|M0)         r14.0<1>:ud   r42.0<1;0>:ud     r18.0<1;0>:ud     r9.0<0>:ud       // s0&(s1^s2)
(~f0.0) cmp (16|M16)  (ne)f0.0   null<1>:d     r16.0<1;1,0>:d    0:w               {I@2}
(~f0.0) cmp (16|M0)   (ne)f0.0   null<1>:d     r14.0<1;1,0>:d    0:w               {I@2}
(W)     mov (1|M0)               r3.0<1>:hf    -qnan(0x1FF):hf                             
        mov (16|M0)              r30.0<1>:f    r72.0<1;1,0>:f                   {Compacted}
(f0.0)  sel (16|M0)              r18.0<1>:d    r3.0<0;1,0>:w     0:w               {F@2}
(f0.0)  sel (16|M16)             r20.0<1>:d    r3.0<0;1,0>:w     0:w              
        mov (16|M16)             r60.0<1>:f    r74.0<1;1,0>:f                   {Compacted}
        mov (16|M0)              r34.0<1>:d    -r18.0<1;1,0>:d                  {I@2}
        mov (16|M16)             r70.0<1>:d    -r20.0<1;1,0>:d                  {I@2}
        goto (32|M0)                         L28368                  L28464                
L28368:
        join (32|M0)                         L28464                                
L28384:
        mov (16|M0)              r34.0<1>:d    0:w                              
        mov (16|M16)             r70.0<1>:d    0:w                              
        mov (16|M0)              r58.0<1>:d    0:w                              
        mov (16|M16)             r64.0<1>:d    0:w                              
        mov (16|M0)              r30.0<1>:f    r46.0<1;1,0>:f                   {Compacted}
        mov (16|M16)             r60.0<1>:f    r44.0<1;1,0>:f                   {Compacted}
L28464:
        join (32|M0)                         L29336                                
L28480:
        and (16|M0)   (ne)f0.0   r14.0<1>:d    r50.0<1;1,0>:d    63:w               {Compacted}
        and (16|M16)  (ne)f0.0   r2.0<1>:d     r6.0<1;1,0>:d     63:w              
(f0.0)  goto (32|M0)                         L28560                  L28560                
L28520:
        mov (16|M0)              r18.0<1>:f    r46.0<1;1,0>:f                   {Compacted}
        mov (16|M16)             r52.0<1>:d    r44.0<1;1,0>:d                  
        goto (32|M0)                         L28560                  L28784                
L28560:
        join (32|M0)                         L28784                                
L28576:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r14.0<1;1,0>:ud   0x20:uw              {I@6}
        cmp (16|M16)  (lt)f1.0   null<1>:d     r2.0<1;1,0>:ud    0x20:uw              {I@6}
(f1.0)  goto (32|M0)                         L28688                  L28688                
L28624:
        add (16|M0)              r4.0<1>:d     r14.0<1;1,0>:d    -32:w               {Compacted}
        add (16|M16)             r12.0<1>:d    r2.0<1;1,0>:d     -32:w               {Compacted}
        shr (16|M0)              r18.0<1>:ud   r42.0<1;1,0>:ud   r4.0<1;1,0>:d    {A@1}
        shr (16|M16)             r52.0<1>:ud   r40.0<1;1,0>:ud   r12.0<1;1,0>:d   {I@2}
        goto (32|M0)                         L28688                  L28784                
L28688:
        join (32|M0)                         L28784                                
L28704:
        add (16|M0)              r4.0<1>:d     -r14.0<1;1,0>:d   32:w               {Compacted}
        add (16|M16)             r12.0<1>:d    -r2.0<1;1,0>:d    32:w               {Compacted}
        shr (16|M16)             r16.0<1>:ud   r44.0<1;1,0>:ud   r2.0<1;1,0>:d   
        shl (16|M0)              r4.0<1>:d     r42.0<1;1,0>:d    r4.0<1;1,0>:d    {Compacted,I@3}
        shr (16|M0)              r14.0<1>:ud   r46.0<1;1,0>:ud   r14.0<1;1,0>:d  
        shl (16|M16)             r12.0<1>:d    r40.0<1;1,0>:d    r12.0<1;1,0>:d   {Compacted,I@4}
        or (16|M0)               r18.0<1>:d    r14.0<1;1,0>:d    r4.0<1;1,0>:d    {Compacted,I@2}
        or (16|M16)              r52.0<1>:d    r16.0<1;1,0>:d    r12.0<1;1,0>:d   {Compacted,I@2}
L28784:
        join (32|M0)                         L29336                                
L28800:
        shl (16|M0)              r4.0<1>:d     r30.0<1;1,0>:d    2:w               {Compacted}
        shl (16|M16)             r12.0<1>:d    r60.0<1;1,0>:d    2:w               {Compacted}
        shl (16|M0)              r14.0<1>:d    r58.0<1;1,0>:d    1:w               {Compacted}
        shl (16|M16)             r16.0<1>:d    r64.0<1;1,0>:d    1:w               {Compacted}
        and (16|M0)              r4.0<1>:d     r4.0<1;1,0>:d     4:w               {Compacted,I@4}
        and (16|M16)             r12.0<1>:d    r12.0<1;1,0>:d    4:w               {Compacted,I@4}
        bfn.0xFE (16|M0)         r14.0<1>:ud   r4.0<1;0>:ud      r14.0<1;0>:ud     r34.0<1>:ud      {I@2} // s0|s1|s2
        bfn.0xFE (16|M16)        r4.0<1>:ud    r12.0<1;0>:ud     r16.0<1;0>:ud     r70.0<1>:ud      {I@2} // s0|s1|s2
        cmp (16|M0)   (eq)f0.0   null<1>:d     r14.0<1;1,0>:d    0:w               {Compacted,I@2}
        cmp (16|M16)  (eq)f0.0   null<1>:d     r4.0<1;1,0>:d     0:w               {I@2}
(~f0.0) goto (32|M0)                         L28968                  L28968                
L28920:
        mov (16|M0)              r12.0<1>:d    0:w                              
        mov (16|M16)             r6.0<1>:d     0:w                              
        goto (32|M0)                         L28968                  L29208                
L28968:
        join (32|M0)                         L29208                                
L28984:
        cmp (16|M0)   (gt)f1.0   null<1>:d     r14.0<1;1,0>:ud   0x4:uw             
        cmp (16|M16)  (gt)f1.0   null<1>:d     r4.0<1;1,0>:ud    0x4:uw             
(~f1.0) goto (32|M0)                         L29080                  L29080                
L29032:
        mov (16|M0)              r12.0<1>:d    1:w                              
        mov (16|M16)             r6.0<1>:d     1:w                              
        goto (32|M0)                         L29080                  L29208                
L29080:
        join (32|M0)                         L29208                                
L29096:
        and (16|M0)   (ne)f1.0   null<1>:d     r18.0<1;1,0>:d    1:w              
        and (16|M16)  (ne)f1.0   null<1>:d     r52.0<1;1,0>:d    1:w              
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r14.0<1;1,0>:d    4:w              
(f1.0)  cmp (16|M16)  (eq)f1.0   null<1>:d     r4.0<1;1,0>:d     4:w              
(W)     mov (1|M0)               r3.0<1>:hf    0x1:hf                             
(f1.0)  sel (16|M0)              r12.0<1>:d    r3.0<0;1,0>:w     0:w               {F@1}
(f1.0)  sel (16|M16)             r6.0<1>:d     r3.0<0;1,0>:w     0:w              
L29208:
        join (32|M0)                         L29336                                
L29224:
        add (16|M0)              r4.0<1>:d     r12.0<1;1,0>:d    r18.0<1;1,0>:d   {Compacted,I@3}
        add (16|M16)             r12.0<1>:d    r6.0<1;1,0>:d     r52.0<1;1,0>:d   {Compacted,I@3}
        cmp (16|M0)   (gt)f0.0   null<1>:d     r4.0<1;1,0>:ud    0x7FFFFF:ud              {I@2}
        cmp (16|M16)  (gt)f0.0   null<1>:d     r12.0<1;1,0>:ud   0x7FFFFF:ud              {I@2}
(W)     mov (1|M0)               r3.0<1>:f     0x800000:f                               {Compacted}
(~f0.0) sel (16|M0)              r30.0<1>:d    r4.0<1;1,0>:d     0:w              
(~f0.0) sel (16|M16)             r78.0<1>:d    r12.0<1;1,0>:d    0:w              
(f0.0)  sel (16|M0)              r18.0<1>:d    r3.0<0;1,0>:d     0:w               {Compacted,F@1}
(f0.0)  sel (16|M16)             r76.0<1>:d    r3.0<0;1,0>:d     0:w              
L29336:
        join (32|M0)                         L29432                                
L29352:
        and (16|M0)              r4.0<1>:d     r22.0<1;1,0>:d    -2147483648:d              
        and (16|M16)             r12.0<1>:d    r26.0<1;1,0>:d    -2147483648:d              
        bfn.0xFE (16|M0)         r22.0<1>:ud   r4.0<1;0>:ud      r18.0<1;0>:ud     r30.0<1>:ud      {I@2} // s0|s1|s2
        bfn.0xFE (16|M16)        r28.0<1>:ud   r12.0<1;0>:ud     r76.0<1;0>:ud     r78.0<1>:ud      {I@2} // s0|s1|s2
        goto (32|M0)                         L29432                  L34576                
L29432:
        join (32|M0)                         L30184                                
L29448:
        and (16|M0)   (ne)f0.0   r4.0<1>:d     r58.0<1;1,0>:d    63:w               {Compacted}
        and (16|M16)  (ne)f0.0   r16.0<1>:d    r56.0<1;1,0>:d    63:w              
(f0.0)  goto (32|M0)                         L29568                  L29568                
L29488:
        mov (16|M0)              r4.0<1>:d     -1:w                              
        mov (16|M16)             r14.0<1>:d    -1:w                              
        mov (16|M0)              r20.0<1>:d    -1:w                              
        mov (16|M16)             r6.0<1>:d     -1:w                              
        goto (32|M0)                         L29568                  L29840                
L29568:
        join (32|M0)                         L29840                                
L29584:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r4.0<1;1,0>:ud    0x20:uw              {I@6}
        cmp (16|M16)  (lt)f1.0   null<1>:d     r16.0<1;1,0>:ud   0x20:uw             
(f1.0)  goto (32|M0)                         L29744                  L29744                
L29632:
        add (16|M0)              r4.0<1>:d     r4.0<1;1,0>:d     -32:w               {Compacted}
        add (16|M16)             r12.0<1>:d    r16.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r3.0<1>:hf    -qnan(0x1FF):hf                             
        mov (16|M16)             r14.0<1>:d    0:w                              
        shl (16|M0)              r20.0<1>:d    r3.0<0;1,0>:w     r4.0<1;1,0>:d    {A@1}
        shl (16|M16)             r6.0<1>:d     r3.0<0;1,0>:w     r12.0<1;1,0>:d   {I@3}
        mov (16|M0)              r4.0<1>:d     0:w                              
        goto (32|M0)                         L29744                  L29840                
L29744:
        join (32|M0)                         L29840                                
L29760:
(W)     mov (1|M0)               r3.0<1>:hf    -qnan(0x1FF):hf                              {I@4}
        mov (16|M0)              r20.0<1>:d    -1:w                              
        mov (16|M16)             r6.0<1>:d     -1:w                              
        shl (16|M0)              r4.0<1>:d     r3.0<0;1,0>:w     r4.0<1;1,0>:d    {A@1}
        shl (16|M16)             r14.0<1>:d    r3.0<0;1,0>:w     r16.0<1;1,0>:d  
L29840:
        join (32|M0)                         L30184                                
L29856:
        bfn.0x28 (16|M0)         r4.0<1>:ud    r46.0<1;0>:ud     r4.0<1;0>:ud      r9.0<0>:ud       {I@3} // s0&(s1^s2)
        bfn.0x28 (16|M16)        r12.0<1>:ud   r44.0<1;0>:ud     r14.0<1;0>:ud     r9.0<0>:ud       {I@3} // s0&(s1^s2)
        cmp (16|M0)   (ne)f0.0   null<1>:d     r4.0<1;1,0>:d     0:w               {Compacted,I@2}
        cmp (16|M16)  (ne)f0.0   null<1>:d     r12.0<1;1,0>:d    0:w               {I@2}
        bfn.0x28 (16|M16)        r16.0<1>:ud   r40.0<1;0>:ud     r6.0<1;0>:ud      r9.0<0>:ud       // s0&(s1^s2)
        bfn.0x28 (16|M0)         r14.0<1>:ud   r42.0<1;0>:ud     r20.0<1;0>:ud     r9.0<0>:ud       // s0&(s1^s2)
        cmp (16|M0)   (gt)f1.0   null<1>:d     r22.0<1;1,0>:d    -1:w              
        cmp (16|M16)  (gt)f1.0   null<1>:d     r26.0<1;1,0>:d    -1:w              
(~f0.0) cmp (16|M16)  (ne)f0.0   null<1>:d     r16.0<1;1,0>:d    0:w               {I@4}
(~f0.0) cmp (16|M0)   (ne)f0.0   null<1>:d     r14.0<1;1,0>:d    0:w               {I@4}
(f0.0)  cmp (16|M16)  (eq)f0.0   null<1>:d     r66.0<1;1,0>:d    -150:w              
(f0.0)  cmp (16|M0)   (eq)f0.0   null<1>:d     r18.0<1;1,0>:d    -150:w              
(f1.0)  goto (32|M0)                         L30112                  L30112                
L30056:
(W)     mov (1|M0)               r3.0<1>:ud    0x80000001:ud                             
(f0.0)  sel (16|M0)              r22.0<1>:f    r3.0<0;1,0>:f     -0.0:f               {Compacted,I@1}
(f0.0)  sel (16|M16)             r28.0<1>:f    r3.0<0;1,0>:f     -0.0:f              
        goto (32|M0)                         L30112                  L34576                
L30112:
        join (32|M0)                         L30184                                
L30128:
(W)     mov (1|M0)               r3.0<1>:ud    0x1:ud                              {F@1}
(f0.0)  sel (16|M0)              r22.0<1>:f    r3.0<0;1,0>:f     0.0:f               {Compacted,I@1}
(f0.0)  sel (16|M16)             r28.0<1>:f    r3.0<0;1,0>:f     0.0:f              
        goto (32|M0)                         L30184                  L34576                
L30184:
        join (32|M0)                         L34264                                
L30200:
        cmp (16|M16)  (lt)f0.0   null<1>:d     r56.0<1;1,0>:ud   0x18:uw              {F@1}
        cmp (16|M16)  (eq)f1.0   null<1>:d     r80.0<1;1,0>:d    0:w              
        cmp (16|M0)   (lt)f1.0   null<1>:d     r58.0<1;1,0>:ud   0x18:uw             
(W)     mov (1|M0)               r3.0<1>:hf    0x1:hf                             
        add3 (16|M0)             r66.0<1>:d    r50.0<1;0>:d      r58.0<1;0>:d      81:w              
(f1.0)  sel (16|M16)             acc0.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw              {F@1}
(f0.0)  sel (16|M16)             acc2.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw             
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r72.0<1;1,0>:d    0:w              
        and (16|M16)  (ne)f1.0   null<1>:uw    acc0.0<1;1,0>:uw  acc2.0<1;1,0>:uw
        add3 (16|M16)            r68.0<1>:d    r48.0<1;0>:d      r56.0<1;0>:d      81:w              
(f1.0)  goto (32|M0)                         L33808                  L33808                
L30376:
        shl (16|M16)             r12.0<1>:d    r32.0<1;1,0>:d    1:w               {Compacted}
        shl (16|M0)              r4.0<1>:d     r34.0<1;1,0>:d    1:w               {Compacted}
        shr (16|M16)             r16.0<1>:ud   r32.0<1;1,0>:ud   31:w              
        shl (16|M16)             r20.0<1>:d    r24.0<1;1,0>:d    1:w               {Compacted}
        cmp (16|M16)  (lt)f0.0   null<1>:d     r12.0<1;1,0>:ud   0x4E:uw              {I@4}
        shr (16|M0)              r14.0<1>:ud   r34.0<1;1,0>:ud   31:w              
        shl (16|M0)              r18.0<1>:d    r30.0<1;1,0>:d    1:w               {Compacted}
        cmp (16|M0)   (lt)f1.0   null<1>:d     r4.0<1;1,0>:ud    0x4E:uw              {I@6}
        or (16|M16)              r20.0<1>:d    r20.0<1;1,0>:d    r16.0<1;1,0>:d   {Compacted,I@5}
        or (16|M0)               r18.0<1>:d    r18.0<1;1,0>:d    r14.0<1;1,0>:d   {Compacted,I@3}
(f0.0)  cmp (16|M16)  (eq)f0.0   null<1>:d     r20.0<1;1,0>:d    0:w               {I@2}
        cmp (16|M16)  (lt)f1.0   null<1>:d     r20.0<1;1,0>:d    0:w              
(W)     mov (1|M0)               r3.0<1>:hf    0x1:hf                             
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r18.0<1;1,0>:d    0:w               {I@3}
(f1.0)  sel (16|M16)             acc0.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw              {F@1}
(f0.0)  sel (16|M16)             acc2.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw             
(~f1.0) cmp (16|M0)   (lt)f1.0   null<1>:d     r18.0<1;1,0>:d    0:w              
        or (16|M16)   (ne)f1.0   null<1>:uw    acc0.0<1;1,0>:uw  acc2.0<1;1,0>:uw
(f1.0)  goto (32|M0)                         L30912                  L30912                
L30632:
        cmp (16|M16)  (eq)f1.0   null<1>:d     r32.0<1;1,0>:d    39:w              
        cmp (16|M16)  (eq)f0.0   null<1>:d     r24.0<1;1,0>:d    0:w              
        cmp (16|M0)   (eq)f0.0   null<1>:d     r34.0<1;1,0>:d    39:w               {Compacted}
(W)     mov (1|M0)               r3.0<1>:hf    0x1:hf                              {I@7}
(f0.0)  sel (16|M16)             acc0.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw              {F@1}
(f1.0)  sel (16|M16)             acc2.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw             
(f0.0)  cmp (16|M0)   (eq)f0.0   null<1>:d     r30.0<1;1,0>:d    0:w              
        and (16|M16)  (ne)f0.0   null<1>:uw    acc0.0<1;1,0>:uw  acc2.0<1;1,0>:uw
(~f0.0) goto (32|M0)                         L30912                  L31072                
L30768:
        shr (16|M0)              r18.0<1>:ud   r46.0<1;1,0>:ud   1:w              
        shr (16|M16)             r52.0<1>:ud   r44.0<1;1,0>:ud   1:w              
        mov (16|M0)              r34.0<1>:d    0:w                              
        mov (16|M16)             r60.0<1>:d    0:w                              
        mov (16|M0)              r30.0<1>:d    0:w                              
        mov (16|M16)             r54.0<1>:d    0:w                              
        mov (16|M0)              r42.0<1>:f    r18.0<1;1,0>:f                   {Compacted,I@6}
        mov (16|M16)             r6.0<1>:f     r52.0<1;1,0>:f                   {Compacted,I@5}
        mov (16|M0)              r18.0<1>:f    r46.0<1;1,0>:f                   {Compacted}
        mov (16|M16)             r52.0<1>:f    r44.0<1;1,0>:f                   {Compacted}
        goto (32|M0)                         L30912                  L32968                
L30912:
        join (32|M0)                         L31072                                
L30928:
        cmp (16|M16)  (eq)f0.0   null<1>:d     r32.0<1;1,0>:d    38:w              
        cmp (16|M16)  (eq)f1.0   null<1>:d     r24.0<1;1,0>:d    0:w              
        cmp (16|M0)   (eq)f1.0   null<1>:d     r34.0<1;1,0>:d    38:w               {I@7}
(W)     mov (1|M0)               r3.0<1>:hf    0x1:hf                             
(f1.0)  sel (16|M16)             acc0.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw              {F@1}
(f0.0)  sel (16|M16)             acc2.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw             
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r30.0<1;1,0>:d    0:w               {I@7}
        and (16|M16)  (ne)f1.0   null<1>:uw    acc0.0<1;1,0>:uw  acc2.0<1;1,0>:uw
(f1.0)  goto (32|M0)                         L31072                  L32824                
L31072:
        join (32|M0)                         L32824                                
L31088:
        add (16|M0)              r4.0<1>:d     -r34.0<1;1,0>:d   39:w               {Compacted}
        add (16|M16)             r12.0<1>:d    -r32.0<1;1,0>:d   39:w               {Compacted}
        and (16|M0)   (ne)f0.0   r14.0<1>:d    r4.0<1;1,0>:d     63:w               {Compacted,I@2}
        and (16|M16)  (ne)f0.0   r2.0<1>:d     r12.0<1;1,0>:d    63:w               {I@2}
        add (16|M0)              r70.0<1>:d    -r34.0<1;1,0>:d   40:w               {Compacted}
        add (16|M16)             r72.0<1>:d    -r32.0<1;1,0>:d   40:w               {Compacted}
(f0.0)  goto (32|M0)                         L31200                  L31200                
L31160:
        mov (16|M0)              r24.0<1>:f    r46.0<1;1,0>:f                   {Compacted}
        mov (16|M16)             r64.0<1>:d    r44.0<1;1,0>:d                  
        goto (32|M0)                         L31200                  L31464                
L31200:
        join (32|M0)                         L31464                                
L31216:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r14.0<1;1,0>:ud   0x20:uw              {I@7}
        cmp (16|M16)  (lt)f1.0   null<1>:d     r2.0<1;1,0>:ud    0x20:uw              {I@7}
(f1.0)  goto (32|M0)                         L31328                  L31328                
L31264:
        add (16|M0)              r4.0<1>:d     r14.0<1;1,0>:d    -32:w               {Compacted}
        add (16|M16)             r12.0<1>:d    r2.0<1;1,0>:d     -32:w               {Compacted}
        shr (16|M0)              r18.0<1>:ud   r42.0<1;1,0>:ud   r4.0<1;1,0>:d    {I@2}
        shr (16|M16)             r52.0<1>:ud   r40.0<1;1,0>:ud   r12.0<1;1,0>:d   {I@2}
        goto (32|M0)                         L31328                  L31424                
L31328:
        join (32|M0)                         L31424                                
L31344:
        add (16|M0)              r4.0<1>:d     -r14.0<1;1,0>:d   32:w               {Compacted}
        add (16|M16)             r12.0<1>:d    -r2.0<1;1,0>:d    32:w               {Compacted}
        shr (16|M16)             r16.0<1>:ud   r44.0<1;1,0>:ud   r2.0<1;1,0>:d   
        shl (16|M0)              r4.0<1>:d     r42.0<1;1,0>:d    r4.0<1;1,0>:d    {Compacted,I@3}
        shr (16|M0)              r14.0<1>:ud   r46.0<1;1,0>:ud   r14.0<1;1,0>:d  
        shl (16|M16)             r12.0<1>:d    r40.0<1;1,0>:d    r12.0<1;1,0>:d   {Compacted,I@4}
        or (16|M0)               r18.0<1>:d    r14.0<1;1,0>:d    r4.0<1;1,0>:d    {Compacted,I@2}
        or (16|M16)              r52.0<1>:d    r16.0<1;1,0>:d    r12.0<1;1,0>:d   {Compacted,I@2}
L31424:
        join (32|M0)                         L31464                                
L31440:
        mov (16|M0)              r24.0<1>:f    r18.0<1;1,0>:f                   {Compacted,I@3}
        mov (16|M16)             r64.0<1>:d    r52.0<1;1,0>:d                   {I@2}
L31464:
        join (32|M0)                         L32824                                
L31480:
        add (16|M0)              r20.0<1>:d    -r34.0<1;1,0>:d   38:w               {Compacted}
        add (16|M16)             r2.0<1>:d     -r32.0<1;1,0>:d   38:w               {Compacted}
        and (16|M0)   (ne)f0.0   r14.0<1>:d    r20.0<1;1,0>:d    63:w               {Compacted,I@2}
        and (16|M16)  (ne)f0.0   r16.0<1>:d    r2.0<1;1,0>:d     63:w               {I@2}
(f0.0)  goto (32|M0)                         L31576                  L31576                
L31536:
        mov (16|M0)              r18.0<1>:f    r46.0<1;1,0>:f                   {Compacted}
        mov (16|M16)             r52.0<1>:d    r44.0<1;1,0>:d                  
        goto (32|M0)                         L31576                  L31800                
L31576:
        join (32|M0)                         L31800                                
L31592:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r14.0<1;1,0>:ud   0x20:uw              {I@6}
        cmp (16|M16)  (lt)f1.0   null<1>:d     r16.0<1;1,0>:ud   0x20:uw              {I@6}
(f1.0)  goto (32|M0)                         L31704                  L31704                
L31640:
        add (16|M0)              r4.0<1>:d     r14.0<1;1,0>:d    -32:w               {Compacted}
        add (16|M16)             r12.0<1>:d    r16.0<1;1,0>:d    -32:w               {Compacted}
        shr (16|M0)              r18.0<1>:ud   r42.0<1;1,0>:ud   r4.0<1;1,0>:d    {A@1}
        shr (16|M16)             r52.0<1>:ud   r40.0<1;1,0>:ud   r12.0<1;1,0>:d   {I@2}
        goto (32|M0)                         L31704                  L31800                
L31704:
        join (32|M0)                         L31800                                
L31720:
        add (16|M0)              r4.0<1>:d     -r14.0<1;1,0>:d   32:w               {Compacted}
        add (16|M16)             r12.0<1>:d    -r16.0<1;1,0>:d   32:w               {Compacted}
        shl (16|M0)              r4.0<1>:d     r42.0<1;1,0>:d    r4.0<1;1,0>:d    {Compacted,I@2}
        shr (16|M0)              r14.0<1>:ud   r46.0<1;1,0>:ud   r14.0<1;1,0>:d  
        shl (16|M16)             r12.0<1>:d    r40.0<1;1,0>:d    r12.0<1;1,0>:d   {Compacted,I@3}
        shr (16|M16)             r16.0<1>:ud   r44.0<1;1,0>:ud   r16.0<1;1,0>:d  
        or (16|M0)               r18.0<1>:d    r14.0<1;1,0>:d    r4.0<1;1,0>:d    {Compacted,I@3}
        or (16|M16)              r52.0<1>:d    r16.0<1;1,0>:d    r12.0<1;1,0>:d   {Compacted,I@2}
L31800:
        join (32|M0)                         L32824                                
L31816:
        and (16|M0)   (ne)f0.0   r4.0<1>:d     r20.0<1;1,0>:d    63:w               {Compacted}
        and (16|M16)  (ne)f0.0   r20.0<1>:d    r2.0<1;1,0>:d     63:w              
        and (16|M0)              r30.0<1>:d    r18.0<1;1,0>:d    1:w               {Compacted,I@5}
        and (16|M16)             r54.0<1>:d    r52.0<1;1,0>:d    1:w               {Compacted,I@5}
(f0.0)  goto (32|M0)                         L31952                  L31952                
L31872:
        mov (16|M0)              r4.0<1>:d     -1:w                              
        mov (16|M16)             r14.0<1>:d    -1:w                              
        mov (16|M0)              r18.0<1>:d    -1:w                              
        mov (16|M16)             r16.0<1>:d    -1:w                              
        goto (32|M0)                         L31952                  L32224                
L31952:
        join (32|M0)                         L32224                                
L31968:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r4.0<1;1,0>:ud    0x20:uw              {I@6}
        cmp (16|M16)  (lt)f1.0   null<1>:d     r20.0<1;1,0>:ud   0x20:uw             
(f1.0)  goto (32|M0)                         L32128                  L32128                
L32016:
        add (16|M0)              r4.0<1>:d     r4.0<1;1,0>:d     -32:w               {Compacted}
        add (16|M16)             r12.0<1>:d    r20.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r3.0<1>:hf    -qnan(0x1FF):hf                             
        mov (16|M16)             r14.0<1>:d    0:w                              
        shl (16|M0)              r18.0<1>:d    r3.0<0;1,0>:w     r4.0<1;1,0>:d    {A@1}
        shl (16|M16)             r16.0<1>:d    r3.0<0;1,0>:w     r12.0<1;1,0>:d   {I@3}
        mov (16|M0)              r4.0<1>:d     0:w                              
        goto (32|M0)                         L32128                  L32224                
L32128:
        join (32|M0)                         L32224                                
L32144:
(W)     mov (1|M0)               r3.0<1>:hf    -qnan(0x1FF):hf                              {I@4}
        mov (16|M0)              r18.0<1>:d    -1:w                              
        mov (16|M16)             r16.0<1>:d    -1:w                              
        shl (16|M0)              r4.0<1>:d     r3.0<0;1,0>:w     r4.0<1;1,0>:d    {A@1}
        shl (16|M16)             r14.0<1>:d    r3.0<0;1,0>:w     r20.0<1;1,0>:d  
L32224:
        join (32|M0)                         L32824                                
L32240:
        bfn.0x28 (16|M0)         r4.0<1>:ud    r46.0<1;0>:ud     r4.0<1;0>:ud      r9.0<0>:ud       {I@3} // s0&(s1^s2)
        bfn.0x28 (16|M16)        r12.0<1>:ud   r44.0<1;0>:ud     r14.0<1;0>:ud     r9.0<0>:ud       {I@3} // s0&(s1^s2)
        cmp (16|M0)   (ne)f0.0   null<1>:d     r4.0<1;1,0>:d     0:w               {Compacted,I@2}
        cmp (16|M16)  (ne)f0.0   null<1>:d     r12.0<1;1,0>:d    0:w               {I@2}
        bfn.0x28 (16|M16)        r16.0<1>:ud   r40.0<1;0>:ud     r16.0<1;0>:ud     r9.0<0>:ud       // s0&(s1^s2)
        bfn.0x28 (16|M0)         r14.0<1>:ud   r42.0<1;0>:ud     r18.0<1;0>:ud     r9.0<0>:ud       // s0&(s1^s2)
(~f0.0) cmp (16|M16)  (ne)f0.0   null<1>:d     r16.0<1;1,0>:d    0:w               {I@2}
(~f0.0) cmp (16|M0)   (ne)f0.0   null<1>:d     r14.0<1;1,0>:d    0:w               {I@2}
(W)     mov (1|M0)               r3.0<1>:hf    -qnan(0x1FF):hf                             
(f0.0)  sel (16|M0)              r18.0<1>:d    r3.0<0;1,0>:w     0:w               {F@1}
(f0.0)  sel (16|M16)             r20.0<1>:d    r3.0<0;1,0>:w     0:w              
        and (16|M0)   (ne)f0.0   r14.0<1>:d    r70.0<1;1,0>:d    63:w               {Compacted}
        and (16|M16)  (ne)f0.0   r2.0<1>:d     r72.0<1;1,0>:d    63:w              
        mov (16|M0)              r34.0<1>:d    -r18.0<1;1,0>:d                  {I@4}
        mov (16|M16)             r60.0<1>:d    -r20.0<1;1,0>:d                  {I@4}
(f0.0)  goto (32|M0)                         L32520                  L32520                
L32480:
        mov (16|M0)              r18.0<1>:f    r46.0<1;1,0>:f                   {Compacted,I@3}
        mov (16|M16)             r52.0<1>:d    r44.0<1;1,0>:d                  
        goto (32|M0)                         L32520                  L32744                
L32520:
        join (32|M0)                         L32744                                
L32536:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r14.0<1;1,0>:ud   0x20:uw             
        cmp (16|M16)  (lt)f1.0   null<1>:d     r2.0<1;1,0>:ud    0x20:uw             
(f1.0)  goto (32|M0)                         L32648                  L32648                
L32584:
        add (16|M0)              r4.0<1>:d     r14.0<1;1,0>:d    -32:w               {Compacted}
        add (16|M16)             r12.0<1>:d    r2.0<1;1,0>:d     -32:w               {Compacted}
        shr (16|M0)              r18.0<1>:ud   r42.0<1;1,0>:ud   r4.0<1;1,0>:d    {A@1}
        shr (16|M16)             r52.0<1>:ud   r40.0<1;1,0>:ud   r12.0<1;1,0>:d   {I@2}
        goto (32|M0)                         L32648                  L32744                
L32648:
        join (32|M0)                         L32744                                
L32664:
        add (16|M0)              r4.0<1>:d     -r14.0<1;1,0>:d   32:w               {Compacted}
        add (16|M16)             r12.0<1>:d    -r2.0<1;1,0>:d    32:w               {Compacted}
        shr (16|M16)             r16.0<1>:ud   r44.0<1;1,0>:ud   r2.0<1;1,0>:d   
        shl (16|M0)              r4.0<1>:d     r42.0<1;1,0>:d    r4.0<1;1,0>:d    {Compacted,I@3}
        shr (16|M0)              r14.0<1>:ud   r46.0<1;1,0>:ud   r14.0<1;1,0>:d  
        shl (16|M16)             r12.0<1>:d    r40.0<1;1,0>:d    r12.0<1;1,0>:d   {Compacted,I@4}
        or (16|M0)               r18.0<1>:d    r14.0<1;1,0>:d    r4.0<1;1,0>:d    {Compacted,I@2}
        or (16|M16)              r52.0<1>:d    r16.0<1;1,0>:d    r12.0<1;1,0>:d   {Compacted,I@2}
L32744:
        join (32|M0)                         L32824                                
L32760:
        mov (16|M0)              r42.0<1>:f    r18.0<1;1,0>:f                   {Compacted,I@3}
        mov (16|M16)             r6.0<1>:f     r52.0<1;1,0>:f                   {Compacted,I@2}
        mov (16|M0)              r18.0<1>:d    r24.0<1;1,0>:d                   {F@2}
        mov (16|M16)             r52.0<1>:d    r64.0<1;1,0>:d                   {F@1}
        goto (32|M0)                         L32824                  L32968                
L32824:
        join (32|M0)                         L32968                                
L32840:
        shr (16|M0)              r18.0<1>:ud   r46.0<1;1,0>:ud   2:w              
        shr (16|M16)             r52.0<1>:ud   r44.0<1;1,0>:ud   2:w              
        and (16|M0)              r30.0<1>:d    r46.0<1;1,0>:d    1:w               {Compacted}
        and (16|M16)             r54.0<1>:d    r44.0<1;1,0>:d    1:w               {Compacted}
        mov (16|M0)              r34.0<1>:d    0:w                              
        mov (16|M16)             r60.0<1>:d    0:w                              
        mov (16|M0)              r42.0<1>:f    r18.0<1;1,0>:f                   {Compacted,I@6}
        mov (16|M16)             r6.0<1>:f     r52.0<1;1,0>:f                   {Compacted,I@5}
        shr (16|M0)              r18.0<1>:ud   r46.0<1;1,0>:ud   1:w               {F@2}
        shr (16|M16)             r52.0<1>:ud   r44.0<1;1,0>:ud   1:w               {F@1}
L32968:
        join (32|M0)                         L33808                                
L32984:
        shl (16|M0)              r4.0<1>:d     r18.0<1;1,0>:d    2:w               {Compacted,I@3}
        shl (16|M16)             r12.0<1>:d    r52.0<1;1,0>:d    2:w               {Compacted,I@3}
        shl (16|M0)              r14.0<1>:d    r30.0<1;1,0>:d    1:w               {Compacted}
        shl (16|M16)             r16.0<1>:d    r54.0<1;1,0>:d    1:w               {Compacted}
        and (16|M0)              r4.0<1>:d     r4.0<1;1,0>:d     4:w               {Compacted,I@4}
        and (16|M16)             r12.0<1>:d    r12.0<1;1,0>:d    4:w               {Compacted,I@4}
        bfn.0xFE (16|M0)         r4.0<1>:ud    r4.0<1;0>:ud      r14.0<1;0>:ud     r34.0<1>:ud      {I@2} // s0|s1|s2
        bfn.0xFE (16|M16)        r14.0<1>:ud   r12.0<1;0>:ud     r16.0<1;0>:ud     r60.0<1>:ud      {I@2} // s0|s1|s2
        cmp (16|M0)   (eq)f0.0   null<1>:d     r4.0<1;1,0>:d     0:w               {Compacted,I@2}
        cmp (16|M16)  (eq)f0.0   null<1>:d     r14.0<1;1,0>:d    0:w               {I@2}
        and (16|M0)              r20.0<1>:d    r42.0<1;1,0>:d    8388607:d              
        and (16|M16)             r24.0<1>:d    r6.0<1;1,0>:d     8388607:d              
(~f0.0) goto (32|M0)                         L33184                  L33184                
L33136:
        mov (16|M0)              r4.0<1>:d     0:w                              
        mov (16|M16)             r12.0<1>:d    0:w                              
        goto (32|M0)                         L33184                  L33424                
L33184:
        join (32|M0)                         L33424                                
L33200:
        cmp (16|M0)   (gt)f1.0   null<1>:d     r4.0<1;1,0>:ud    0x4:uw              {I@4}
        cmp (16|M16)  (gt)f1.0   null<1>:d     r14.0<1;1,0>:ud   0x4:uw             
(~f1.0) goto (32|M0)                         L33296                  L33296                
L33248:
        mov (16|M0)              r4.0<1>:d     1:w                              
        mov (16|M16)             r12.0<1>:d    1:w                              
        goto (32|M0)                         L33296                  L33424                
L33296:
        join (32|M0)                         L33424                                
L33312:
        and (16|M0)   (ne)f1.0   null<1>:d     r42.0<1;1,0>:d    1:w              
        and (16|M16)  (ne)f1.0   null<1>:d     r6.0<1;1,0>:d     1:w              
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r4.0<1;1,0>:d     4:w               {I@6}
(f1.0)  cmp (16|M16)  (eq)f1.0   null<1>:d     r14.0<1;1,0>:d    4:w              
(W)     mov (1|M0)               r3.0<1>:hf    0x1:hf                             
(f1.0)  sel (16|M0)              r4.0<1>:d     r3.0<0;1,0>:w     0:w               {F@1}
(f1.0)  sel (16|M16)             r12.0<1>:d    r3.0<0;1,0>:w     0:w              
L33424:
        join (32|M0)                         L33808                                
L33440:
        add (16|M0)              r14.0<1>:d    r20.0<1;1,0>:d    r4.0<1;1,0>:d    {Compacted,I@3}
        add (16|M16)             r6.0<1>:d     r24.0<1;1,0>:d    r12.0<1;1,0>:d   {Compacted,I@3}
        cmp (16|M0)   (gt)f1.0   null<1>:d     r14.0<1;1,0>:ud   0x7FFFFF:ud              {I@2}
        cmp (16|M16)  (gt)f1.0   null<1>:d     r6.0<1;1,0>:ud    0x7FFFFF:ud              {I@2}
        add3 (16|M0)             r4.0<1>:d     r50.0<1;0>:d      r58.0<1;0>:d      82:w              
        add3 (16|M16)            r12.0<1>:d    r48.0<1;0>:d      r56.0<1;0>:d      82:w              
(f1.0)  sel (16|M0)              r18.0<1>:d    r4.0<1;1,0>:d     r66.0<1;1,0>:d   {Compacted,I@2}
(f1.0)  sel (16|M16)             r2.0<1>:d     r12.0<1;1,0>:d    r68.0<1;1,0>:d   {I@2}
        cmp (16|M0)   (eq)f0.0   null<1>:d     r18.0<1;1,0>:d    255:w               {Compacted,I@2}
        cmp (16|M16)  (eq)f0.0   null<1>:d     r2.0<1;1,0>:d     255:w               {I@2}
(f0.0)  goto (32|M0)                         L33712                  L33712                
L33584:
(~f1.0) sel (16|M0)              r4.0<1>:d     r14.0<1;1,0>:d    0:w              
(~f1.0) sel (16|M16)             r12.0<1>:d    r6.0<1;1,0>:d     0:w              
        and (16|M16)             r16.0<1>:d    r26.0<1;1,0>:d    -2147483648:d              
        shl (16|M0)              r18.0<1>:d    r18.0<1;1,0>:d    23:w               {Compacted}
        shl (16|M16)             r20.0<1>:d    r2.0<1;1,0>:d     23:w               {Compacted}
        and (16|M0)              r14.0<1>:d    r22.0<1;1,0>:d    -2147483648:d              
        bfn.0xFE (16|M16)        r28.0<1>:ud   r16.0<1;0>:ud     r20.0<1;0>:ud     r12.0<1>:ud      {I@2} // s0|s1|s2
        bfn.0xFE (16|M0)         r22.0<1>:ud   r14.0<1;0>:ud     r18.0<1;0>:ud     r4.0<1>:ud       {I@2} // s0|s1|s2
        goto (32|M0)                         L33712                  L34576                
L33712:
        join (32|M0)                         L33808                                
L33728:
        cmp (16|M0)   (gt)f1.0   null<1>:d     r22.0<1;1,0>:d    -1:w               {I@3}
        cmp (16|M16)  (gt)f1.0   null<1>:d     r26.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r3.0<1>:f     inf:f                               {Compacted}
(f1.0)  sel (16|M0)              r22.0<1>:f    r3.0<0;1,0>:f     -inf:f               {Compacted,A@1}
(f1.0)  sel (16|M16)             r28.0<1>:f    r3.0<0;1,0>:f     -inf:f              
        goto (32|M0)                         L33808                  L34576                
L33808:
        join (32|M0)                         L34264                                
L33824:
        and (16|M0)   (ne)f0.0   r12.0<1>:d    r58.0<1;1,0>:d    63:w               {Compacted}
        and (16|M16)  (ne)f0.0   r4.0<1>:d     r56.0<1;1,0>:d    63:w              
(f0.0)  goto (32|M0)                         L33912                  L33912                
L33864:
        mov (16|M0)              r12.0<1>:d    -1:w                              
        mov (16|M16)             r6.0<1>:d     -1:w                              
        goto (32|M0)                         L33912                  L34088                
L33912:
        join (32|M0)                         L34088                                
L33928:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r12.0<1;1,0>:ud   0x20:uw              {A@1}
        cmp (16|M16)  (lt)f1.0   null<1>:d     r4.0<1;1,0>:ud    0x20:uw             
(f1.0)  goto (32|M0)                         L34024                  L34024                
L33976:
        mov (16|M0)              r12.0<1>:d    0:w                              
        mov (16|M16)             r6.0<1>:d     0:w                              
        goto (32|M0)                         L34024                  L34088                
L34024:
        join (32|M0)                         L34088                                
L34040:
(W)     mov (1|M0)               r3.0<1>:hf    -qnan(0x1FF):hf                             
        shl (16|M0)              r12.0<1>:d    r3.0<0;1,0>:w     r12.0<1;1,0>:d   {A@1}
        shl (16|M16)             r6.0<1>:d     r3.0<0;1,0>:w     r4.0<1;1,0>:d   
L34088:
        join (32|M0)                         L34264                                
L34104:
        bfn.0x28 (16|M0)         r4.0<1>:ud    r46.0<1;0>:ud     r12.0<1;0>:ud     r9.0<0>:ud       {I@3} // s0&(s1^s2)
        add (16|M0)              r14.0<1>:d    -r58.0<1;1,0>:d   23:w               {Compacted}
        add (16|M16)             r16.0<1>:d    -r56.0<1;1,0>:d   23:w               {Compacted}
        bfn.0x28 (16|M16)        r12.0<1>:ud   r44.0<1;0>:ud     r6.0<1;0>:ud      r9.0<0>:ud       {I@5} // s0&(s1^s2)
        and (16|M0)              r18.0<1>:d    r22.0<1;1,0>:d    -2147483648:d              
        and (16|M16)             r20.0<1>:d    r26.0<1;1,0>:d    -2147483648:d              
        shl (16|M16)             r24.0<1>:d    r68.0<1;1,0>:d    23:w               {Compacted}
        shl (16|M0)              r4.0<1>:d     r4.0<1;1,0>:d     r14.0<1;1,0>:d   {Compacted,I@6}
        shl (16|M16)             r12.0<1>:d    r12.0<1;1,0>:d    r16.0<1;1,0>:d   {Compacted,I@5}
        shl (16|M0)              r22.0<1>:d    r66.0<1;1,0>:d    23:w               {Compacted}
        bfn.0xFE (16|M16)        r28.0<1>:ud   r20.0<1;0>:ud     r24.0<1;0>:ud     r12.0<1>:ud      {I@2} // s0|s1|s2
        bfn.0xFE (16|M0)         r22.0<1>:ud   r18.0<1;0>:ud     r22.0<1;0>:ud     r4.0<1>:ud       {I@2} // s0|s1|s2
        goto (32|M0)                         L34264                  L34576                
L34264:
        join (32|M0)                         L34352                                
L34280:
        cmp (16|M0)   (gt)f0.0   null<1>:d     r22.0<1;1,0>:d    -1:w               {Compacted,I@3}
        cmp (16|M16)  (gt)f0.0   null<1>:d     r26.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r3.0<1>:f     inf:f                               {Compacted}
(f0.0)  sel (16|M0)              r22.0<1>:f    r3.0<0;1,0>:f     -inf:f               {Compacted,A@1}
(f0.0)  sel (16|M16)             r28.0<1>:f    r3.0<0;1,0>:f     -inf:f              
        goto (32|M0)                         L34352                  L34576                
L34352:
        join (32|M0)                         L34440                                
L34368:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r22.0<1;1,0>:d    0:w               {Compacted,F@2}
        cmp (16|M16)  (lt)f1.0   null<1>:d     r26.0<1;1,0>:d    0:w              
(W)     mov (1|M0)               r3.0<1>:f     -0.0:f                               {Compacted}
(f1.0)  sel (16|M0)              r22.0<1>:f    r3.0<0;1,0>:f     0.0:f               {Compacted,A@1}
(f1.0)  sel (16|M16)             r28.0<1>:f    r3.0<0;1,0>:f     0.0:f              
        goto (32|M0)                         L34440                  L34576                
L34440:
        join (32|M0)                         L34528                                
L34456:
        cmp (16|M0)   (gt)f0.0   null<1>:d     r22.0<1;1,0>:d    -1:w               {Compacted,F@2}
        cmp (16|M16)  (gt)f0.0   null<1>:d     r26.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r3.0<1>:f     inf:f                               {Compacted}
(f0.0)  sel (16|M0)              r22.0<1>:f    r3.0<0;1,0>:f     -inf:f               {Compacted,A@1}
(f0.0)  sel (16|M16)             r28.0<1>:f    r3.0<0;1,0>:f     -inf:f              
        goto (32|M0)                         L34528                  L34576                
L34528:
        join (32|M0)                         L34576                                
L34544:
        bfn.0xF8 (16|M0)         r22.0<1>:ud   r22.0<1;0>:ud     r9.7<0;0>:ud      r9.3<0>:ud       {F@2} // s0&s1|s2
        bfn.0xF8 (16|M16)        r28.0<1>:ud   r26.0<1;0>:ud     r9.7<0;0>:ud      r9.3<0>:ud       {F@1} // s0&s1|s2
L34576:
        join (32|M0)                         L46248                                
L34592:
        shr (16|M16)             r18.0<1>:ud   r28.0<1;1,0>:ud   23:w               {I@2}
        and (16|M16)             r24.0<1>:d    r18.0<1;1,0>:d    255:w               {Compacted,I@1}
        and (16|M16)  (ne)f1.0   r14.0<1>:d    r28.0<1;1,0>:d    8388607:d              
        cmp (16|M16)  (eq)f0.0   null<1>:d     r24.0<1;1,0>:d    255:w               {I@2}
        shr (16|M0)              r20.0<1>:ud   r22.0<1;1,0>:ud   23:w              
        and (16|M0)   (ne)f0.0   r16.0<1>:d    r22.0<1;1,0>:d    8388607:d              
(W)     mov (1|M0)               r3.0<1>:hf    0x1:hf                             
        sync.nop                             null                             {Compacted,$12.src}
        and (16|M0)              r30.0<1>:d    r20.0<1;1,0>:d    255:w               {Compacted,I@2}
(f0.0)  sel (16|M16)             acc0.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw              {F@1}
(f1.0)  sel (16|M16)             acc2.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw             
(f0.0)  cmp (16|M0)   (eq)f0.0   null<1>:d     r30.0<1;1,0>:d    255:w               {I@3}
        and (16|M16)  (ne)f0.0   null<1>:uw    acc0.0<1;1,0>:uw  acc2.0<1;1,0>:uw
(~f0.0) goto (32|M0)                         L34832                  L34832                
L34792:
        mov (16|M0)              r22.0<1>:ud   0x7FC00000:ud                             
        mov (16|M16)             r26.0<1>:f    qnan(0x0):f                               {Compacted}
        goto (32|M0)                         L34832                  L45928                
L34832:
        join (32|M0)                         L45928                                
L34848:
(W)     mov (1|M0)               a0.0<1>:ud    r10.0<0;1,0>:d                   {A@1}
(W)     shl (1|M0)               r3.0<1>:ud    r9.2<0;1,0>:d     2:w              
(W)     send.ugm (1|M0)          r4       r3      null:0  a0.0        0x22188500           {ExBSO,A@1,$15} // wr:1+0, rd:1; load.ugm.d32x1t.a32.ca.ca.bss[a0.0]
(W)     mov (1|M0)               r10.6<1>:d    r4.0<0;1,0>:d                    {$15.dst}
(W)     shr (1|M0)               r10.7<1>:ud   r10.6<0;1,0>:ud   23:w               {I@1}
(W)     and (1|M0)               r10.5<1>:d    r10.6<0;1,0>:d    8388607:d              
(W)     and (1|M0)               r10.4<1>:d    r10.7<0;1,0>:d    255:w               {I@2}
(W)     cmp (16|M16)  (ne)f0.0   null<1>:d     r10.5<0;1,0>:d    0:w               {I@2}
(W)     cmp (16|M0)   (ne)f1.0   null<1>:d     r10.5<0;1,0>:d    0:w              
(W)     cmp (16|M16)  (eq)f1.0   null<1>:d     r10.4<0;1,0>:d    255:w               {I@3}
(W)     mov (1|M0)               r5.0<1>:uw    f0.1<0;1,0>:uw                   {Compacted}
(W&f1.0) cmp (16|M0)  (eq)f1.0   null<1>:d     r10.4<0;1,0>:d    255:w              
(W)     and (1|M16)              f1.1<1>:uw    f1.1<0;1,0>:uw    r5.0<0;1,0>:uw   {I@2}
(~f1.0) goto (32|M0)                         L35104                  L35104                
L35064:
        mov (16|M0)              r22.0<1>:ud   0x7FC00000:ud                             
        mov (16|M16)             r26.0<1>:f    qnan(0x0):f                               {Compacted}
        goto (32|M0)                         L35104                  L45928                
L35104:
        join (32|M0)                         L45928                                
L35120:
        cmp (16|M0)   (eq)f1.0   null<1>:d     r16.0<1;1,0>:d    0:w              
(W)     mov (1|M0)               r3.2<1>:hf    0x1:hf                             
        xor (16|M0)              r22.0<1>:d    r10.6<0;1,0>:d    r22.0<1;1,0>:d   {Compacted,I@4}
(W)     mov (1|M0)               r3.0<1>:ud    f1.0<0;1,0>:ud                   {Compacted}
        xor (16|M16)             r28.0<1>:d    r10.6<0;1,0>:d    r28.0<1;1,0>:d   {Compacted}
(W)     mov (1|M0)               f0.0<1>:ud    r3.0<0;1,0>:ud                   {I@2}
        cmp (16|M16)  (eq)f0.0   null<1>:d     r14.0<1;1,0>:d    0:w              
(W)     mov (1|M0)               r3.0<1>:ud    f0.0<0;1,0>:ud                   {Compacted}
(W)     mov (1|M0)               f1.0<1>:ud    r3.0<0;1,0>:ud                   {I@1}
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r30.0<1;1,0>:d    255:w              
(W)     mov (1|M0)               r3.0<1>:ud    f1.0<0;1,0>:ud                   {Compacted}
(W)     mov (1|M0)               f0.0<1>:ud    r3.0<0;1,0>:ud                   {I@1}
(f0.0)  cmp (16|M16)  (eq)f0.0   null<1>:d     r24.0<1;1,0>:d    255:w              
(W)     mov (1|M0)               r3.0<1>:ud    f0.0<0;1,0>:ud                   {Compacted}
(W)     cmp (16|M0)   (eq)f0.0   null<1>:d     r10.5<0;1,0>:d    0:w               {Compacted}
(W)     mov (1|M0)               f1.0<1>:ud    r3.0<0;1,0>:ud                   {I@2}
(W)     cmp (16|M16)  (eq)f0.0   null<1>:d     r10.5<0;1,0>:d    0:w              
(W&f0.0) cmp (16|M0)  (eq)f0.0   null<1>:d     r10.4<0;1,0>:d    255:w              
(f1.0)  sel (16|M0)              acc0.0<1>:uw  r3.2<0;1,0>:uw    0x0:uw              {F@1}
(f0.0)  sel (16|M0)              acc2.0<1>:uw  r3.2<0;1,0>:uw    0x0:uw             
        or (16|M0)    (ne)f1.0   null<1>:uw    acc0.0<1;1,0>:uw  acc2.0<1;1,0>:uw
(W&f0.0) cmp (16|M16) (eq)f0.0   null<1>:d     r10.4<0;1,0>:d    255:w              
(W)     mov (1|M0)               r3.2<1>:ud    f1.0<0;1,0>:ud                   {Compacted}
(W)     mov (1|M0)               f1.0<1>:ud    r3.0<0;1,0>:ud                  
(f0.0)  sel (16|M16)             acc0.0<1>:uw  r3.2<0;1,0>:uw    0x0:uw             
(W)     mov (1|M0)               f0.0<1>:ud    r3.2<0;1,0>:ud                   {I@3}
(f1.0)  sel (16|M16)             acc2.0<1>:uw  r3.2<0;1,0>:uw    0x0:uw             
        or (16|M16)   (ne)f0.0   null<1>:uw    acc2.0<1;1,0>:uw  acc0.0<1;1,0>:uw
(W)     mov (1|M0)               r3.2<1>:ud    f0.0<0;1,0>:ud                   {Compacted}
(W)     mov (1|M0)               f1.0<1>:ud    r3.2<0;1,0>:ud                   {I@1}
(f1.0)  goto (32|M0)                         L45880                  L45880                
L35544:
(W)     or (1|M0)                r4.0<1>:d     r10.4<0;1,0>:d    r10.5<0;1,0>:d  
(W)     or (1|M0)                r3.0<1>:d     r10.4<0;1,0>:d    r10.5<0;1,0>:d  
        or (16|M16)   (eq)f0.0   null<1>:d     r24.0<1;1,0>:d    r14.0<1;1,0>:d  
(W)     cmp (16|M16)  (eq)f1.0   null<1>:d     r4.0<0;1,0>:d     0:w               {I@3}
(W)     mov (1|M0)               r5.0<1>:hf    0x1:hf                             
(W)     cmp (16|M0)   (eq)f0.0   null<1>:d     r3.0<0;1,0>:d     0:w               {Compacted,I@3}
        or (16|M0)               r12.0<1>:d    r30.0<1;1,0>:d    r16.0<1;1,0>:d   {Compacted}
(f0.0)  sel (16|M16)             acc0.0<1>:uw  r5.0<0;1,0>:uw    0x0:uw              {F@1}
(f1.0)  sel (16|M16)             acc2.0<1>:uw  r5.0<0;1,0>:uw    0x0:uw             
(~f0.0) cmp (16|M0)   (eq)f0.0   null<1>:d     r12.0<1;1,0>:d    0:w               {I@3}
        or (16|M16)   (ne)f0.0   null<1>:uw    acc0.0<1;1,0>:uw  acc2.0<1;1,0>:uw
(~f0.0) goto (32|M0)                         L35760                  L35760                
L35720:
        mov (16|M0)              r22.0<1>:ud   0x0:ud                             
        mov (16|M16)             r26.0<1>:f    0.0:f                               {Compacted}
        goto (32|M0)                         L35760                  L45928                
L35760:
        join (32|M0)                         L45880                                
L35776:
(W)     cmp (16|M0)   (eq)f0.0   null<1>:d     r10.4<0;1,0>:d    0:w               {Compacted}
        cmp (16|M0)   (eq)f1.0   null<1>:d     r30.0<1;1,0>:d    0:w              
(W)     mov (1|M0)               r10.6<1>:ud   f0.0<0;1,0>:ud                   {Compacted}
(W)     add (1|M0)               r3.0<1>:d     r10.4<0;1,0>:d    -127:w               {Compacted}
(W)     mov (1|M0)               f0.0<1>:ud    r10.6<0;1,0>:ud                  {I@2}
        add (16|M0)              r40.0<1>:d    r30.0<1;1,0>:d    -127:w               {Compacted}
(W)     cmp (16|M16)  (eq)f0.0   null<1>:d     r10.4<0;1,0>:d    0:w              
(f1.0)  mov (16|M0)              r40.0<1>:d    -126:w                              
(W&~f0.0) sel (1|M0)             r10.4<1>:d    r3.0<0;1,0>:d     -126:w               {I@5}
        cmp (16|M16)  (eq)f1.0   null<1>:d     r24.0<1;1,0>:d    0:w              
        add (16|M0)              r34.0<1>:d    r40.0<1;1,0>:d    r10.4<0;1,0>:d   {Compacted,I@2}
(W)     mov (1|M0)               r10.6<1>:ud   f0.0<0;1,0>:ud                   {Compacted}
        cmp (16|M0)   (gt)f0.0   null<1>:d     r34.0<1;1,0>:d    127:w               {Compacted,I@2}
        add (16|M16)             r64.0<1>:d    r24.0<1;1,0>:d    -127:w               {Compacted}
(f1.0)  mov (16|M16)             r64.0<1>:d    -126:w                              
(W)     mov (1|M0)               r4.0<1>:ud    f0.0<0;1,0>:ud                   {Compacted}
        add (16|M16)             r32.0<1>:d    r64.0<1;1,0>:d    r10.4<0;1,0>:d   {Compacted,I@2}
(W)     mov (1|M0)               f0.0<1>:ud    r4.0<0;1,0>:ud                   {I@2}
        cmp (16|M16)  (gt)f0.0   null<1>:d     r32.0<1;1,0>:d    127:w               {I@2}
(W)     mov (1|M0)               r4.0<1>:ud    f0.0<0;1,0>:ud                   {Compacted}
(f0.0)  goto (32|M0)                         L45792                  L45792                
L36024:
        or (16|M0)    (eq)f0.0   null<4>:b     r20.0<1;1,0>:d    r10.7<0;1,0>:d  
(W)     mov (1|M0)               r3.0<1>:ud    f0.0<0;1,0>:ud                   {Compacted}
(W)     mov (1|M0)               f0.0<1>:ud    r3.0<0;1,0>:ud                   {I@1}
        or (16|M16)   (eq)f0.0   null<4>:b     r18.0<1;1,0>:d    r10.7<0;1,0>:d  
(W)     mov (1|M0)               r3.0<1>:ud    f0.0<0;1,0>:ud                   {Compacted}
(f0.0)  goto (32|M0)                         L45704                  L45704                
L36104:
(W)     mov (1|M0)               f0.0<1>:ud    r10.6<0;1,0>:ud                 
(W)     mov (1|M0)               r3.0<1>:hf    0.0:hf                              {I@3}
(W)     mov (1|M0)               r2.3<1>:d     0:w                              
(f1.0)  sel (16|M0)              r4.0<1>:d     r3.0<0;1,0>:w     8388608:d               {F@1}
(W&f0.0) sel (1|M0)              r6.0<1>:d     r3.0<0;1,0>:w     8388608:d              
        or (16|M0)               r4.0<1>:d     r4.0<1;1,0>:d     r16.0<1;1,0>:d   {Compacted,I@2}
(W)     or (1|M0)                r7.6<1>:d     r6.0<0;1,0>:d     r10.5<0;1,0>:d   {I@2}
(f1.0)  sel (16|M16)             r12.0<1>:d    r3.0<0;1,0>:w     8388608:d              
        mul (8|M0)               acc0.0<1>:ud  r4.0<1;1,0>:ud    r7.12<0;1,0>:uw  {I@2}
        or (16|M16)              r12.0<1>:d    r12.0<1;1,0>:d    r14.0<1;1,0>:d   {Compacted,I@2}
        mach (8|M0)              r14.0<1>:ud   r4.0<1;1,0>:ud    r7.6<0;1,0>:ud   {AccWrEn,Compacted}
(W)     mov (1|M0)               r2.5<1>:f     -0.0:f                               {Compacted}
        mov (8|M0)               r16.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mul (8|M8)               acc0.0<1>:ud  r5.0<1;1,0>:ud    r7.12<0;1,0>:uw 
        mach (8|M8)              r15.0<1>:ud   r5.0<1;1,0>:ud    r7.6<0;1,0>:ud   {AccWrEn}
(W)     mov (2|M0)               r2.0<1>:d     0:w                              
        mov (8|M8)               r17.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mul (8|M16)              acc0.0<1>:ud  r12.0<1;1,0>:ud   r7.12<0;1,0>:uw  {I@7}
        mach (8|M16)             r18.0<1>:ud   r12.0<1;1,0>:ud   r7.6<0;1,0>:ud   {AccWrEn}
        mov (16|M0)              r24.0<1>:f    r14.0<1;1,0>:f                   {Compacted,A@5}
        mov (8|M16)              r20.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mul (8|M24)              acc0.0<1>:ud  r13.0<1;1,0>:ud   r7.12<0;1,0>:uw 
        mach (8|M24)             r19.0<1>:ud   r13.0<1;1,0>:ud   r7.6<0;1,0>:ud   {AccWrEn}
        mov (16|M0)              r30.0<1>:f    r16.0<1;1,0>:f                   {Compacted,I@6}
        mov (8|M24)              r21.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mov (16|M16)             r50.0<1>:f    r18.0<1;1,0>:f                   {Compacted,A@2}
        mov (16|M16)             r52.0<1>:f    r20.0<1;1,0>:f                   {Compacted,I@1}
L36440:
(W)     shl (1|M0)               r3.0<1>:d     r2.5<0;1,0>:d     31:w               {Compacted,F@5}
(W)     shr (1|M0)               r3.1<1>:ud    r2.3<0;1,0>:ud    1:w              
(W)     addc (1|M0)              r7.0<1>:ud    r2.0<0;1,0>:ud    0x1:ud              {AccWrEn}
(W)     or (1|M0)                r2.3<1>:d     r3.1<0;1,0>:d     r3.0<0;1,0>:d    {I@2}
        bfn.0xA8 (16|M0)         r12.0<1>:ud   r30.0<1;0>:ud     r3.1<0;0>:ud      r3.0<0>:ud       {F@3} // s0&(s1|s2)
        cmp (16|M0)   (eq)f1.0   null<1>:d     r12.0<1;1,0>:d    r2.3<0;1,0>:d    {I@1}
(W)     mov (1|M0)               r4.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        bfn.0xA8 (16|M16)        r14.0<1>:ud   r52.0<1;0>:ud     r3.1<0;0>:ud      r3.0<0>:ud       {F@1} // s0&(s1|s2)
(W)     add (1|M0)               r2.4<1>:ud    r4.0<0;1,0>:ud    r2.1<0;1,0>:ud   {I@2}
(W)     mov (1|M0)               r4.0<1>:ud    f1.0<0;1,0>:ud                   {Compacted}
(W)     shr (1|M0)               r2.2<1>:ud    r2.5<0;1,0>:ud    1:w              
(W)     mov (1|M0)               f1.0<1>:ud    r4.0<0;1,0>:ud                   {I@2}
        cmp (16|M16)  (eq)f1.0   null<1>:d     r14.0<1;1,0>:d    r2.3<0;1,0>:d   
        and (16|M0)              r16.0<1>:d    r24.0<1;1,0>:d    r2.2<0;1,0>:d    {Compacted,I@3}
(W)     mov (1|M0)               r4.0<1>:ud    f1.0<0;1,0>:ud                   {Compacted}
(W)     cmp (16|M0)   (gt)f0.0   null<1>:d     r2.0<0;1,0>:ud    0x3E:uw             
(W)     mov (1|M0)               f1.0<1>:ud    r4.0<0;1,0>:ud                   {I@2}
(W)     cmp (16|M16)  (gt)f0.0   null<1>:d     r2.0<0;1,0>:ud    0x3E:uw             
(W&f0.0) cmp (16|M0)  (eq)f0.0   null<1>:d     r2.1<0;1,0>:d     0:w              
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r16.0<1;1,0>:d    r2.2<0;1,0>:d   
        and (16|M16)             r18.0<1>:d    r50.0<1;1,0>:d    r2.2<0;1,0>:d    {Compacted}
(W)     mov (1|M0)               r4.0<1>:ud    f1.0<0;1,0>:ud                   {Compacted}
(W&f0.0) cmp (16|M16) (eq)f0.0   null<1>:d     r2.1<0;1,0>:d     0:w              
(W)     mov (1|M0)               f1.0<1>:ud    r4.0<0;1,0>:ud                   {I@2}
(W&~f0.0) cmp (16|M0) (gt)f0.0   null<1>:d     r2.1<0;1,0>:ud    0x0:uw             
(W)     mov (1|M0)               r3.0<1>:hf    0x1:hf                             
(f1.0)  cmp (16|M16)  (eq)f1.0   null<1>:d     r18.0<1;1,0>:d    r2.2<0;1,0>:d   
(W&~f0.0) cmp (16|M16) (gt)f0.0  null<1>:d     r2.1<0;1,0>:ud    0x0:uw             
(f0.0)  sel (16|M0)              acc0.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw              {F@1}
(f1.0)  sel (16|M0)              acc2.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw             
(W)     mov (1|M0)               r4.0<1>:ud    f1.0<0;1,0>:ud                   {Compacted}
(f0.0)  sel (16|M16)             r8.0<1>:uw    r3.0<0;1,0>:uw    0x0:uw             
        or (16|M0)    (ne)f1.0   null<1>:uw    acc0.0<1;1,0>:uw  acc2.0<1;1,0>:uw
(W)     mov (1|M0)               f0.0<1>:ud    r4.0<0;1,0>:ud                   {I@3}
        mov (16|M0)              r60.0<1>:f    r2.0<0;1,0>:f                    {Compacted}
(W)     mov (1|M0)               r3.1<1>:ud    f1.0<0;1,0>:ud                   {Compacted}
(f0.0)  sel (16|M16)             acc0.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw             
(W)     mov (1|M0)               f0.0<1>:ud    r3.1<0;1,0>:ud                   {I@2}
        or (16|M16)   (ne)f0.0   null<1>:uw    r8.0<1;1,0>:uw    acc0.0<1;1,0>:uw
        mov (16|M16)             r58.0<1>:f    r2.0<0;1,0>:f                    {Compacted}
(W)     mov (1|M0)               r3.1<1>:ud    f0.0<0;1,0>:ud                   {Compacted}
        mov (16|M16)             r20.0<1>:d    r2.1<0;1,0>:d                   
(W)     mov (1|M0)               f1.0<1>:ud    r3.1<0;1,0>:ud                   {I@2}
        mov (16|M0)              r48.0<1>:f    r7.0<0;1,0>:f                    {Compacted}
        mov (16|M16)             r46.0<1>:f    r7.0<0;1,0>:f                    {Compacted}
        mov (16|M0)              r44.0<1>:d    r2.4<0;1,0>:d                   
        mov (16|M16)             r42.0<1>:d    r2.4<0;1,0>:d                   
        mov (16|M0)              r16.0<1>:d    r2.1<0;1,0>:d                   
(f1.0)  goto (32|M0)                         L37168                  L37168                
L37112:
(W)     mov (1|M0)               r2.5<1>:d     r2.2<0;1,0>:d                   
(W)     mov (1|M0)               r2.0<1>:f     r7.0<0;1,0>:f                    {Compacted}
(W)     mov (1|M0)               r2.1<1>:d     r2.4<0;1,0>:d                   
(W)     jmpi                                 L36440                                
L37168:
        join (32|M0)                         L45704                                
L37184:
(W)     mov (1|M0)               r3.0<1>:f     8.68805e-44:f                              
(W)     mov (1|M0)               r4.0<1>:hf    0.0:hf                             
        subb (8|M0)              r56.0<1>:ud   r3.0<0;1,0>:ud    r60.0<1;1,0>:ud  {AccWrEn,Compacted,F@2}
        add3 (8|M0)              r72.0<1>:ud   -acc0.0<1;0>:ud   r4.0<0;0>:uw      -r16.0<1>:ud     {A@1}
        subb (8|M8)              r57.0<1>:ud   r3.0<0;1,0>:ud    r61.0<1;1,0>:ud  {AccWrEn}
        add3 (8|M8)              r73.0<1>:ud   -acc0.0<1;0>:ud   r4.0<0;0>:uw      -r17.0<1>:ud    
        subb (8|M16)             r54.0<1>:ud   r3.0<0;1,0>:ud    r58.0<1;1,0>:ud  {AccWrEn}
        add3 (16|M0)             r18.0<1>:d    r34.0<1;0>:d      r56.0<1;0>:d      -46:w               {I@3}
        add3 (8|M16)             r80.0<1>:ud   -acc0.0<1;0>:ud   r4.0<0;0>:uw      -r20.0<1>:ud    
        subb (8|M24)             r55.0<1>:ud   r3.0<0;1,0>:ud    r59.0<1;1,0>:ud  {AccWrEn}
        cmp (16|M0)   (gt)f0.0   null<1>:d     r18.0<1;1,0>:d    127:w               {Compacted,I@3}
        add3 (16|M16)            r68.0<1>:d    r64.0<1;0>:d      r10.4<0;0>:d      r54.0<1>:d       {I@2}
        add3 (16|M16)            r64.0<1>:d    r32.0<1;0>:d      r54.0<1;0>:d      -46:w              
        cmp (16|M16)  (gt)f0.0   null<1>:d     r64.0<1;1,0>:d    127:w               {I@1}
        add3 (16|M0)             r40.0<1>:d    r40.0<1;0>:d      r10.4<0;0>:d      r56.0<1>:d      
        add3 (8|M24)             r81.0<1>:ud   -acc0.0<1;0>:ud   r4.0<0;0>:uw      -r21.0<1>:ud    
(f0.0)  goto (32|M0)                         L45616                  L45616                
L37440:
        cmp (16|M0)   (gt)f1.0   null<1>:d     r18.0<1;1,0>:d    -127:w              
        cmp (16|M16)  (gt)f1.0   null<1>:d     r64.0<1;1,0>:d    -127:w              
(f1.0)  goto (32|M0)                         L41528                  L41528                
L37488:
        cmp (16|M0)   (lt)f0.0   null<1>:d     r18.0<1;1,0>:ud   0xFFFFFF6B:ud             
        cmp (16|M16)  (lt)f0.0   null<1>:d     r64.0<1;1,0>:ud   0xFFFFFF6B:ud             
(f0.0)  goto (32|M0)                         L40776                  L40776                
L37536:
(W)     mov (1|M0)               r3.0<1>:f     8.82818e-44:f                              
        add3 (16|M0)             r44.0<1>:d    r34.0<1;0>:d      r56.0<1;0>:d      104:w              
(W)     mov (1|M0)               r4.0<1>:hf    0.0:hf                              {I@7}
        subb (8|M0)              r34.0<1>:ud   r3.0<0;1,0>:ud    r60.0<1;1,0>:ud  {AccWrEn,Compacted,F@2}
        add3 (16|M16)            r66.0<1>:d    r32.0<1;0>:d      r54.0<1;0>:d      104:w              
        add3 (8|M0)              r12.0<1>:ud   -acc0.0<1;0>:ud   r4.0<0;0>:uw      -r16.0<1>:ud     {F@1}
        subb (8|M8)              r35.0<1>:ud   r3.0<0;1,0>:ud    r61.0<1;1,0>:ud  {AccWrEn}
(W)     mov (1|M0)               r5.0<1>:hf    0x1:hf                             
        add3 (8|M8)              r13.0<1>:ud   -acc0.0<1;0>:ud   r4.0<0;0>:uw      -r17.0<1>:ud    
        subb (8|M16)             r60.0<1>:ud   r3.0<0;1,0>:ud    r58.0<1;1,0>:ud  {AccWrEn}
        cmp (16|M0)   (gt)f0.0   null<1>:d     r34.0<1;1,0>:ud   r44.0<1;1,0>:ud  {I@3}
        add3 (8|M16)             r14.0<1>:ud   -acc0.0<1;0>:ud   r4.0<0;0>:uw      -r20.0<1>:ud    
        subb (8|M24)             r61.0<1>:ud   r3.0<0;1,0>:ud    r59.0<1;1,0>:ud  {AccWrEn}
(f0.0)  cmp (16|M0)   (eq)f0.0   null<1>:d     r12.0<1;1,0>:d    0:w               {I@5}
        cmp (16|M16)  (gt)f1.0   null<1>:d     r60.0<1;1,0>:ud   r66.0<1;1,0>:ud  {I@2}
        add3 (8|M24)             r15.0<1>:ud   -acc0.0<1;0>:ud   r4.0<0;0>:uw      -r21.0<1>:ud    
(~f0.0) cmp (16|M0)   (gt)f0.0   null<1>:d     r12.0<1;1,0>:ud   0x0:uw             
(f1.0)  cmp (16|M16)  (eq)f1.0   null<1>:d     r14.0<1;1,0>:d    0:w               {I@2}
        cmp (16|M16)  (gt)f0.0   null<1>:d     r14.0<1;1,0>:ud   0x0:uw             
(f1.0)  sel (16|M16)             acc0.0<1>:uw  r5.0<0;1,0>:uw    0x0:uw              {F@1}
(f0.0)  sel (16|M16)             acc2.0<1>:uw  r5.0<0;1,0>:uw    0x0:uw             
        or (16|M16)   (ne)f0.0   null<1>:uw    acc2.0<1;1,0>:uw  acc0.0<1;1,0>:uw
(f0.0)  goto (32|M0)                         L37992                  L37992                
L37896:
        add3 (16|M0)             r4.0<1>:d     r40.0<1;0>:d      -r34.0<1;0>:d     104:w              
        add3 (16|M16)            r12.0<1>:d    r68.0<1;0>:d      -r60.0<1;0>:d     104:w              
        mov (16|M0)              r18.0<1>:d    0:w                              
        mov (16|M16)             r76.0<1>:d    0:w                              
        shl (16|M0)              r24.0<1>:d    r30.0<1;1,0>:d    r4.0<1;1,0>:d    {Compacted,I@4}
        shl (16|M16)             r78.0<1>:d    r52.0<1;1,0>:d    r12.0<1;1,0>:d   {Compacted,I@4}
        goto (32|M0)                         L37992                  L40680                
L37992:
        join (32|M0)                         L40680                                
L38008:
        add3 (16|M0)             r48.0<1>:d    r34.0<1;0>:d      -r40.0<1;0>:d     -104:w              
        add3 (16|M16)            r6.0<1>:d     r60.0<1;0>:d      -r68.0<1;0>:d     -104:w              
        cmp (16|M0)   (lt)f1.0   null<1>:d     r48.0<1;1,0>:d    2:w               {Compacted,I@2}
        cmp (16|M16)  (lt)f1.0   null<1>:d     r6.0<1;1,0>:d     2:w               {I@2}
(f1.0)  goto (32|M0)                         L38232                  L38232                
L38080:
        cmp (16|M0)   (eq)f0.0   null<1>:d     r48.0<1;1,0>:d    2:w               {Compacted}
        cmp (16|M16)  (eq)f0.0   null<1>:d     r6.0<1;1,0>:d     2:w              
(~f0.0) goto (32|M0)                         L38232                  L38296                
L38120:
        shr (16|M0)              r18.0<1>:ud   r30.0<1;1,0>:ud   1:w              
        shr (16|M16)             r40.0<1>:ud   r52.0<1;1,0>:ud   1:w              
        and (16|M0)              r56.0<1>:d    r30.0<1;1,0>:d    1:w               {Compacted}
        and (16|M16)             r68.0<1>:d    r52.0<1;1,0>:d    1:w               {Compacted}
        mov (16|M0)              r44.0<1>:d    0:w                              
        mov (16|M16)             r70.0<1>:d    0:w                              
        mov (16|M0)              r34.0<1>:f    r18.0<1;1,0>:f                   {Compacted,I@6}
        mov (16|M16)             r58.0<1>:f    r40.0<1;1,0>:f                   {Compacted,I@5}
        goto (32|M0)                         L38232                  L39808                
L38232:
        join (32|M0)                         L38296                                
L38248:
        cmp (16|M0)   (eq)f1.0   null<1>:d     r48.0<1;1,0>:d    1:w              
        cmp (16|M16)  (eq)f1.0   null<1>:d     r6.0<1;1,0>:d     1:w              
(f1.0)  goto (32|M0)                         L38296                  L39712                
L38296:
        join (32|M0)                         L39712                                
L38312:
        add3 (16|M0)             r4.0<1>:d     r34.0<1;0>:d      -r44.0<1;0>:d     -1:w               {A@2}
        add3 (16|M16)            r12.0<1>:d    r60.0<1;0>:d      -r66.0<1;0>:d     -1:w              
        and (16|M0)   (ne)f0.0   r14.0<1>:d    r4.0<1;1,0>:d     63:w               {Compacted,I@2}
        and (16|M16)  (ne)f0.0   r2.0<1>:d     r12.0<1;1,0>:d    63:w               {I@2}
(f0.0)  goto (32|M0)                         L38424                  L38424                
L38384:
        mov (16|M0)              r72.0<1>:f    r30.0<1;1,0>:f                   {Compacted}
        mov (16|M16)             r74.0<1>:d    r52.0<1;1,0>:d                  
        goto (32|M0)                         L38424                  L38688                
L38424:
        join (32|M0)                         L38688                                
L38440:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r14.0<1;1,0>:ud   0x20:uw              {I@6}
        cmp (16|M16)  (lt)f1.0   null<1>:d     r2.0<1;1,0>:ud    0x20:uw              {I@6}
(f1.0)  goto (32|M0)                         L38552                  L38552                
L38488:
        add (16|M0)              r4.0<1>:d     r14.0<1;1,0>:d    -32:w               {Compacted}
        add (16|M16)             r12.0<1>:d    r2.0<1;1,0>:d     -32:w               {Compacted}
        shr (16|M0)              r18.0<1>:ud   r24.0<1;1,0>:ud   r4.0<1;1,0>:d    {I@2}
        shr (16|M16)             r40.0<1>:ud   r50.0<1;1,0>:ud   r12.0<1;1,0>:d   {A@2}
        goto (32|M0)                         L38552                  L38648                
L38552:
        join (32|M0)                         L38648                                
L38568:
        add (16|M0)              r4.0<1>:d     -r14.0<1;1,0>:d   32:w               {Compacted}
        add (16|M16)             r12.0<1>:d    -r2.0<1;1,0>:d    32:w               {Compacted}
        shr (16|M16)             r16.0<1>:ud   r52.0<1;1,0>:ud   r2.0<1;1,0>:d   
        shl (16|M0)              r4.0<1>:d     r24.0<1;1,0>:d    r4.0<1;1,0>:d    {Compacted,I@3}
        shr (16|M0)              r14.0<1>:ud   r30.0<1;1,0>:ud   r14.0<1;1,0>:d  
        shl (16|M16)             r12.0<1>:d    r50.0<1;1,0>:d    r12.0<1;1,0>:d   {Compacted,I@4}
        or (16|M0)               r18.0<1>:d    r14.0<1;1,0>:d    r4.0<1;1,0>:d    {Compacted,I@2}
        or (16|M16)              r40.0<1>:d    r16.0<1;1,0>:d    r12.0<1;1,0>:d   {Compacted,I@2}
L38648:
        join (32|M0)                         L38688                                
L38664:
        mov (16|M0)              r72.0<1>:f    r18.0<1;1,0>:f                   {Compacted,I@3}
        mov (16|M16)             r74.0<1>:d    r40.0<1;1,0>:d                   {I@2}
L38688:
        join (32|M0)                         L39712                                
L38704:
        add3 (16|M0)             r20.0<1>:d    r34.0<1;0>:d      -r44.0<1;0>:d     -2:w              
        add3 (16|M16)            r60.0<1>:d    r60.0<1;0>:d      -r66.0<1;0>:d     -2:w              
        and (16|M0)   (ne)f0.0   r14.0<1>:d    r20.0<1;1,0>:d    63:w               {Compacted,I@2}
        and (16|M16)  (ne)f0.0   r2.0<1>:d     r60.0<1;1,0>:d    63:w               {I@2}
(f0.0)  goto (32|M0)                         L38816                  L38816                
L38776:
        mov (16|M0)              r18.0<1>:f    r30.0<1;1,0>:f                   {Compacted}
        mov (16|M16)             r40.0<1>:d    r52.0<1;1,0>:d                  
        goto (32|M0)                         L38816                  L39040                
L38816:
        join (32|M0)                         L39040                                
L38832:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r14.0<1;1,0>:ud   0x20:uw              {I@6}
        cmp (16|M16)  (lt)f1.0   null<1>:d     r2.0<1;1,0>:ud    0x20:uw              {I@6}
(f1.0)  goto (32|M0)                         L38944                  L38944                
L38880:
        add (16|M0)              r4.0<1>:d     r14.0<1;1,0>:d    -32:w               {Compacted}
        add (16|M16)             r12.0<1>:d    r2.0<1;1,0>:d     -32:w               {Compacted}
        shr (16|M0)              r18.0<1>:ud   r24.0<1;1,0>:ud   r4.0<1;1,0>:d    {A@1}
        shr (16|M16)             r40.0<1>:ud   r50.0<1;1,0>:ud   r12.0<1;1,0>:d   {I@2}
        goto (32|M0)                         L38944                  L39040                
L38944:
        join (32|M0)                         L39040                                
L38960:
        add (16|M0)              r4.0<1>:d     -r14.0<1;1,0>:d   32:w               {Compacted}
        add (16|M16)             r12.0<1>:d    -r2.0<1;1,0>:d    32:w               {Compacted}
        shr (16|M16)             r16.0<1>:ud   r52.0<1;1,0>:ud   r2.0<1;1,0>:d   
        shl (16|M0)              r4.0<1>:d     r24.0<1;1,0>:d    r4.0<1;1,0>:d    {Compacted,I@3}
        shr (16|M0)              r14.0<1>:ud   r30.0<1;1,0>:ud   r14.0<1;1,0>:d  
        shl (16|M16)             r12.0<1>:d    r50.0<1;1,0>:d    r12.0<1;1,0>:d   {Compacted,I@4}
        or (16|M0)               r18.0<1>:d    r14.0<1;1,0>:d    r4.0<1;1,0>:d    {Compacted,I@2}
        or (16|M16)              r40.0<1>:d    r16.0<1;1,0>:d    r12.0<1;1,0>:d   {Compacted,I@2}
L39040:
        join (32|M0)                         L39712                                
L39056:
        and (16|M0)   (ne)f0.0   r4.0<1>:d     r20.0<1;1,0>:d    63:w               {Compacted}
        and (16|M16)  (ne)f0.0   r20.0<1>:d    r60.0<1;1,0>:d    63:w              
        and (16|M0)              r56.0<1>:d    r18.0<1;1,0>:d    1:w               {Compacted,I@5}
        and (16|M16)             r68.0<1>:d    r40.0<1;1,0>:d    1:w               {Compacted,I@5}
(f0.0)  goto (32|M0)                         L39192                  L39192                
L39112:
        mov (16|M0)              r4.0<1>:d     -1:w                              
        mov (16|M16)             r14.0<1>:d    -1:w                              
        mov (16|M0)              r18.0<1>:d    -1:w                              
        mov (16|M16)             r16.0<1>:d    -1:w                              
        goto (32|M0)                         L39192                  L39464                
L39192:
        join (32|M0)                         L39464                                
L39208:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r4.0<1;1,0>:ud    0x20:uw              {I@6}
        cmp (16|M16)  (lt)f1.0   null<1>:d     r20.0<1;1,0>:ud   0x20:uw             
(f1.0)  goto (32|M0)                         L39368                  L39368                
L39256:
        add (16|M0)              r4.0<1>:d     r4.0<1;1,0>:d     -32:w               {Compacted}
        add (16|M16)             r12.0<1>:d    r20.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r3.0<1>:hf    -qnan(0x1FF):hf                             
        mov (16|M16)             r14.0<1>:d    0:w                              
        shl (16|M0)              r18.0<1>:d    r3.0<0;1,0>:w     r4.0<1;1,0>:d    {A@1}
        shl (16|M16)             r16.0<1>:d    r3.0<0;1,0>:w     r12.0<1;1,0>:d   {I@3}
        mov (16|M0)              r4.0<1>:d     0:w                              
        goto (32|M0)                         L39368                  L39464                
L39368:
        join (32|M0)                         L39464                                
L39384:
(W)     mov (1|M0)               r3.0<1>:hf    -qnan(0x1FF):hf                              {I@4}
        mov (16|M0)              r18.0<1>:d    -1:w                              
        mov (16|M16)             r16.0<1>:d    -1:w                              
        shl (16|M0)              r4.0<1>:d     r3.0<0;1,0>:w     r4.0<1;1,0>:d    {A@1}
        shl (16|M16)             r14.0<1>:d    r3.0<0;1,0>:w     r20.0<1;1,0>:d  
L39464:
        join (32|M0)                         L39712                                
L39480:
        bfn.0x28 (16|M0)         r4.0<1>:ud    r30.0<1;0>:ud     r4.0<1;0>:ud      r9.0<0>:ud       {I@3} // s0&(s1^s2)
        bfn.0x28 (16|M16)        r12.0<1>:ud   r52.0<1;0>:ud     r14.0<1;0>:ud     r9.0<0>:ud       {I@3} // s0&(s1^s2)
        cmp (16|M0)   (ne)f0.0   null<1>:d     r4.0<1;1,0>:d     0:w               {Compacted,I@2}
        cmp (16|M16)  (ne)f0.0   null<1>:d     r12.0<1;1,0>:d    0:w               {I@2}
        bfn.0x28 (16|M16)        r16.0<1>:ud   r50.0<1;0>:ud     r16.0<1;0>:ud     r9.0<0>:ud       // s0&(s1^s2)
        bfn.0x28 (16|M0)         r14.0<1>:ud   r24.0<1;0>:ud     r18.0<1;0>:ud     r9.0<0>:ud       // s0&(s1^s2)
(~f0.0) cmp (16|M16)  (ne)f0.0   null<1>:d     r16.0<1;1,0>:d    0:w               {I@2}
(~f0.0) cmp (16|M0)   (ne)f0.0   null<1>:d     r14.0<1;1,0>:d    0:w               {I@2}
(W)     mov (1|M0)               r3.0<1>:hf    -qnan(0x1FF):hf                             
        mov (16|M0)              r34.0<1>:f    r72.0<1;1,0>:f                   {Compacted}
(f0.0)  sel (16|M0)              r18.0<1>:d    r3.0<0;1,0>:w     0:w               {F@2}
(f0.0)  sel (16|M16)             r20.0<1>:d    r3.0<0;1,0>:w     0:w              
        mov (16|M16)             r58.0<1>:f    r74.0<1;1,0>:f                   {Compacted}
        mov (16|M0)              r44.0<1>:d    -r18.0<1;1,0>:d                  {I@2}
        mov (16|M16)             r70.0<1>:d    -r20.0<1;1,0>:d                  {I@2}
        goto (32|M0)                         L39712                  L39808                
L39712:
        join (32|M0)                         L39808                                
L39728:
        mov (16|M0)              r44.0<1>:d    0:w                              
        mov (16|M16)             r70.0<1>:d    0:w                              
        mov (16|M0)              r56.0<1>:d    0:w                              
        mov (16|M16)             r68.0<1>:d    0:w                              
        mov (16|M0)              r34.0<1>:f    r30.0<1;1,0>:f                   {Compacted}
        mov (16|M16)             r58.0<1>:f    r52.0<1;1,0>:f                   {Compacted}
L39808:
        join (32|M0)                         L40680                                
L39824:
        and (16|M0)   (ne)f0.0   r14.0<1>:d    r48.0<1;1,0>:d    63:w               {Compacted}
        and (16|M16)  (ne)f0.0   r2.0<1>:d     r6.0<1;1,0>:d     63:w              
(f0.0)  goto (32|M0)                         L39904                  L39904                
L39864:
        mov (16|M0)              r18.0<1>:f    r30.0<1;1,0>:f                   {Compacted}
        mov (16|M16)             r40.0<1>:d    r52.0<1;1,0>:d                  
        goto (32|M0)                         L39904                  L40128                
L39904:
        join (32|M0)                         L40128                                
L39920:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r14.0<1;1,0>:ud   0x20:uw              {I@6}
        cmp (16|M16)  (lt)f1.0   null<1>:d     r2.0<1;1,0>:ud    0x20:uw              {I@6}
(f1.0)  goto (32|M0)                         L40032                  L40032                
L39968:
        add (16|M0)              r4.0<1>:d     r14.0<1;1,0>:d    -32:w               {Compacted}
        add (16|M16)             r12.0<1>:d    r2.0<1;1,0>:d     -32:w               {Compacted}
        shr (16|M0)              r18.0<1>:ud   r24.0<1;1,0>:ud   r4.0<1;1,0>:d    {A@1}
        shr (16|M16)             r40.0<1>:ud   r50.0<1;1,0>:ud   r12.0<1;1,0>:d   {I@2}
        goto (32|M0)                         L40032                  L40128                
L40032:
        join (32|M0)                         L40128                                
L40048:
        add (16|M0)              r4.0<1>:d     -r14.0<1;1,0>:d   32:w               {Compacted}
        add (16|M16)             r12.0<1>:d    -r2.0<1;1,0>:d    32:w               {Compacted}
        shr (16|M16)             r16.0<1>:ud   r52.0<1;1,0>:ud   r2.0<1;1,0>:d   
        shl (16|M0)              r4.0<1>:d     r24.0<1;1,0>:d    r4.0<1;1,0>:d    {Compacted,I@3}
        shr (16|M0)              r14.0<1>:ud   r30.0<1;1,0>:ud   r14.0<1;1,0>:d  
        shl (16|M16)             r12.0<1>:d    r50.0<1;1,0>:d    r12.0<1;1,0>:d   {Compacted,I@4}
        or (16|M0)               r18.0<1>:d    r14.0<1;1,0>:d    r4.0<1;1,0>:d    {Compacted,I@2}
        or (16|M16)              r40.0<1>:d    r16.0<1;1,0>:d    r12.0<1;1,0>:d   {Compacted,I@2}
L40128:
        join (32|M0)                         L40680                                
L40144:
        shl (16|M0)              r4.0<1>:d     r34.0<1;1,0>:d    2:w               {Compacted}
        shl (16|M16)             r12.0<1>:d    r58.0<1;1,0>:d    2:w               {Compacted}
        shl (16|M0)              r14.0<1>:d    r56.0<1;1,0>:d    1:w               {Compacted}
        shl (16|M16)             r16.0<1>:d    r68.0<1;1,0>:d    1:w               {Compacted}
        and (16|M0)              r4.0<1>:d     r4.0<1;1,0>:d     4:w               {Compacted,I@4}
        and (16|M16)             r12.0<1>:d    r12.0<1;1,0>:d    4:w               {Compacted,I@4}
        bfn.0xFE (16|M0)         r14.0<1>:ud   r4.0<1;0>:ud      r14.0<1;0>:ud     r44.0<1>:ud      {I@2} // s0|s1|s2
        bfn.0xFE (16|M16)        r4.0<1>:ud    r12.0<1;0>:ud     r16.0<1;0>:ud     r70.0<1>:ud      {I@2} // s0|s1|s2
        cmp (16|M0)   (eq)f0.0   null<1>:d     r14.0<1;1,0>:d    0:w               {Compacted,I@2}
        cmp (16|M16)  (eq)f0.0   null<1>:d     r4.0<1;1,0>:d     0:w               {I@2}
(~f0.0) goto (32|M0)                         L40312                  L40312                
L40264:
        mov (16|M0)              r12.0<1>:d    0:w                              
        mov (16|M16)             r6.0<1>:d     0:w                              
        goto (32|M0)                         L40312                  L40552                
L40312:
        join (32|M0)                         L40552                                
L40328:
        cmp (16|M0)   (gt)f1.0   null<1>:d     r14.0<1;1,0>:ud   0x4:uw             
        cmp (16|M16)  (gt)f1.0   null<1>:d     r4.0<1;1,0>:ud    0x4:uw             
(~f1.0) goto (32|M0)                         L40424                  L40424                
L40376:
        mov (16|M0)              r12.0<1>:d    1:w                              
        mov (16|M16)             r6.0<1>:d     1:w                              
        goto (32|M0)                         L40424                  L40552                
L40424:
        join (32|M0)                         L40552                                
L40440:
        and (16|M0)   (ne)f1.0   null<1>:d     r18.0<1;1,0>:d    1:w              
        and (16|M16)  (ne)f1.0   null<1>:d     r40.0<1;1,0>:d    1:w              
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r14.0<1;1,0>:d    4:w              
(f1.0)  cmp (16|M16)  (eq)f1.0   null<1>:d     r4.0<1;1,0>:d     4:w              
(W)     mov (1|M0)               r3.0<1>:hf    0x1:hf                             
(f1.0)  sel (16|M0)              r12.0<1>:d    r3.0<0;1,0>:w     0:w               {F@1}
(f1.0)  sel (16|M16)             r6.0<1>:d     r3.0<0;1,0>:w     0:w              
L40552:
        join (32|M0)                         L40680                                
L40568:
        add (16|M0)              r4.0<1>:d     r12.0<1;1,0>:d    r18.0<1;1,0>:d   {Compacted,I@3}
        add (16|M16)             r12.0<1>:d    r6.0<1;1,0>:d     r40.0<1;1,0>:d   {Compacted,I@3}
        cmp (16|M0)   (gt)f1.0   null<1>:d     r4.0<1;1,0>:ud    0x7FFFFF:ud              {I@2}
        cmp (16|M16)  (gt)f1.0   null<1>:d     r12.0<1;1,0>:ud   0x7FFFFF:ud              {I@2}
(W)     mov (1|M0)               r3.0<1>:f     0x800000:f                               {Compacted}
(~f1.0) sel (16|M0)              r24.0<1>:d    r4.0<1;1,0>:d     0:w              
(~f1.0) sel (16|M16)             r78.0<1>:d    r12.0<1;1,0>:d    0:w              
(f1.0)  sel (16|M0)              r18.0<1>:d    r3.0<0;1,0>:d     0:w               {Compacted,F@1}
(f1.0)  sel (16|M16)             r76.0<1>:d    r3.0<0;1,0>:d     0:w              
L40680:
        join (32|M0)                         L40776                                
L40696:
        and (16|M0)              r4.0<1>:d     r22.0<1;1,0>:d    -2147483648:d              
        and (16|M16)             r12.0<1>:d    r28.0<1;1,0>:d    -2147483648:d              
        bfn.0xFE (16|M0)         r22.0<1>:ud   r4.0<1;0>:ud      r18.0<1;0>:ud     r24.0<1>:ud      {I@2} // s0|s1|s2
        bfn.0xFE (16|M16)        r26.0<1>:ud   r12.0<1;0>:ud     r76.0<1;0>:ud     r78.0<1>:ud      {I@2} // s0|s1|s2
        goto (32|M0)                         L40776                  L45928                
L40776:
        join (32|M0)                         L41528                                
L40792:
        and (16|M0)   (ne)f0.0   r4.0<1>:d     r56.0<1;1,0>:d    63:w               {Compacted}
        and (16|M16)  (ne)f0.0   r16.0<1>:d    r54.0<1;1,0>:d    63:w              
(f0.0)  goto (32|M0)                         L40912                  L40912                
L40832:
        mov (16|M0)              r4.0<1>:d     -1:w                              
        mov (16|M16)             r14.0<1>:d    -1:w                              
        mov (16|M0)              r20.0<1>:d    -1:w                              
        mov (16|M16)             r6.0<1>:d     -1:w                              
        goto (32|M0)                         L40912                  L41184                
L40912:
        join (32|M0)                         L41184                                
L40928:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r4.0<1;1,0>:ud    0x20:uw              {I@6}
        cmp (16|M16)  (lt)f1.0   null<1>:d     r16.0<1;1,0>:ud   0x20:uw             
(f1.0)  goto (32|M0)                         L41088                  L41088                
L40976:
        add (16|M0)              r4.0<1>:d     r4.0<1;1,0>:d     -32:w               {Compacted}
        add (16|M16)             r12.0<1>:d    r16.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r3.0<1>:hf    -qnan(0x1FF):hf                             
        mov (16|M16)             r14.0<1>:d    0:w                              
        shl (16|M0)              r20.0<1>:d    r3.0<0;1,0>:w     r4.0<1;1,0>:d    {A@1}
        shl (16|M16)             r6.0<1>:d     r3.0<0;1,0>:w     r12.0<1;1,0>:d   {I@3}
        mov (16|M0)              r4.0<1>:d     0:w                              
        goto (32|M0)                         L41088                  L41184                
L41088:
        join (32|M0)                         L41184                                
L41104:
(W)     mov (1|M0)               r3.0<1>:hf    -qnan(0x1FF):hf                              {I@4}
        mov (16|M0)              r20.0<1>:d    -1:w                              
        mov (16|M16)             r6.0<1>:d     -1:w                              
        shl (16|M0)              r4.0<1>:d     r3.0<0;1,0>:w     r4.0<1;1,0>:d    {A@1}
        shl (16|M16)             r14.0<1>:d    r3.0<0;1,0>:w     r16.0<1;1,0>:d  
L41184:
        join (32|M0)                         L41528                                
L41200:
        bfn.0x28 (16|M0)         r4.0<1>:ud    r30.0<1;0>:ud     r4.0<1;0>:ud      r9.0<0>:ud       {I@3} // s0&(s1^s2)
        bfn.0x28 (16|M16)        r12.0<1>:ud   r52.0<1;0>:ud     r14.0<1;0>:ud     r9.0<0>:ud       {I@3} // s0&(s1^s2)
        cmp (16|M0)   (ne)f1.0   null<1>:d     r4.0<1;1,0>:d     0:w               {I@2}
        cmp (16|M16)  (ne)f1.0   null<1>:d     r12.0<1;1,0>:d    0:w               {I@2}
        bfn.0x28 (16|M16)        r16.0<1>:ud   r50.0<1;0>:ud     r6.0<1;0>:ud      r9.0<0>:ud       // s0&(s1^s2)
        bfn.0x28 (16|M0)         r14.0<1>:ud   r24.0<1;0>:ud     r20.0<1;0>:ud     r9.0<0>:ud       // s0&(s1^s2)
        cmp (16|M0)   (gt)f0.0   null<1>:d     r22.0<1;1,0>:d    -1:w               {Compacted}
        cmp (16|M16)  (gt)f0.0   null<1>:d     r28.0<1;1,0>:d    -1:w              
(~f1.0) cmp (16|M16)  (ne)f1.0   null<1>:d     r16.0<1;1,0>:d    0:w               {I@4}
(~f1.0) cmp (16|M0)   (ne)f1.0   null<1>:d     r14.0<1;1,0>:d    0:w               {I@4}
(f1.0)  cmp (16|M16)  (eq)f1.0   null<1>:d     r64.0<1;1,0>:d    -150:w              
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r18.0<1;1,0>:d    -150:w              
(f0.0)  goto (32|M0)                         L41456                  L41456                
L41400:
(W)     mov (1|M0)               r3.0<1>:ud    0x80000001:ud                             
(f1.0)  sel (16|M0)              r22.0<1>:f    r3.0<0;1,0>:f     -0.0:f               {Compacted,I@1}
(f1.0)  sel (16|M16)             r26.0<1>:f    r3.0<0;1,0>:f     -0.0:f              
        goto (32|M0)                         L41456                  L45928                
L41456:
        join (32|M0)                         L41528                                
L41472:
(W)     mov (1|M0)               r3.0<1>:ud    0x1:ud                              {F@1}
(f1.0)  sel (16|M0)              r22.0<1>:f    r3.0<0;1,0>:f     0.0:f               {Compacted,I@1}
(f1.0)  sel (16|M16)             r26.0<1>:f    r3.0<0;1,0>:f     0.0:f              
        goto (32|M0)                         L41528                  L45928                
L41528:
        join (32|M0)                         L45616                                
L41544:
        cmp (16|M16)  (lt)f0.0   null<1>:d     r54.0<1;1,0>:ud   0x18:uw             
        cmp (16|M16)  (eq)f1.0   null<1>:d     r80.0<1;1,0>:d    0:w               {F@1}
        cmp (16|M0)   (lt)f1.0   null<1>:d     r56.0<1;1,0>:ud   0x18:uw             
(W)     mov (1|M0)               r3.0<1>:hf    0x1:hf                             
        add3 (16|M0)             r66.0<1>:d    r34.0<1;0>:d      r56.0<1;0>:d      81:w              
(f1.0)  sel (16|M16)             acc0.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw              {F@1}
(f0.0)  sel (16|M16)             acc2.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw             
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r72.0<1;1,0>:d    0:w              
        and (16|M16)  (ne)f1.0   null<1>:uw    acc0.0<1;1,0>:uw  acc2.0<1;1,0>:uw
        add3 (16|M16)            r68.0<1>:d    r32.0<1;0>:d      r54.0<1;0>:d      81:w              
(f1.0)  goto (32|M0)                         L45160                  L45160                
L41720:
        shl (16|M16)             r12.0<1>:d    r46.0<1;1,0>:d    1:w               {Compacted}
        shl (16|M0)              r4.0<1>:d     r48.0<1;1,0>:d    1:w               {Compacted}
        shr (16|M16)             r16.0<1>:ud   r46.0<1;1,0>:ud   31:w              
        shl (16|M16)             r20.0<1>:d    r42.0<1;1,0>:d    1:w               {Compacted}
        cmp (16|M16)  (lt)f0.0   null<1>:d     r12.0<1;1,0>:ud   0x4E:uw              {I@4}
        shr (16|M0)              r14.0<1>:ud   r48.0<1;1,0>:ud   31:w              
        shl (16|M0)              r18.0<1>:d    r44.0<1;1,0>:d    1:w               {Compacted}
        cmp (16|M0)   (lt)f1.0   null<1>:d     r4.0<1;1,0>:ud    0x4E:uw              {I@6}
        or (16|M16)              r20.0<1>:d    r20.0<1;1,0>:d    r16.0<1;1,0>:d   {Compacted,I@5}
        or (16|M0)               r18.0<1>:d    r18.0<1;1,0>:d    r14.0<1;1,0>:d   {Compacted,I@3}
(f0.0)  cmp (16|M16)  (eq)f0.0   null<1>:d     r20.0<1;1,0>:d    0:w               {I@2}
        cmp (16|M16)  (lt)f1.0   null<1>:d     r20.0<1;1,0>:d    0:w              
(W)     mov (1|M0)               r3.0<1>:hf    0x1:hf                             
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r18.0<1;1,0>:d    0:w               {I@3}
(f1.0)  sel (16|M16)             acc0.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw              {F@1}
(f0.0)  sel (16|M16)             acc2.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw             
(~f1.0) cmp (16|M0)   (lt)f1.0   null<1>:d     r18.0<1;1,0>:d    0:w              
        or (16|M16)   (ne)f1.0   null<1>:uw    acc0.0<1;1,0>:uw  acc2.0<1;1,0>:uw
(f1.0)  goto (32|M0)                         L42256                  L42256                
L41976:
        cmp (16|M16)  (eq)f1.0   null<1>:d     r46.0<1;1,0>:d    39:w              
        cmp (16|M16)  (eq)f0.0   null<1>:d     r42.0<1;1,0>:d    0:w              
        cmp (16|M0)   (eq)f0.0   null<1>:d     r48.0<1;1,0>:d    39:w               {Compacted}
(W)     mov (1|M0)               r3.0<1>:hf    0x1:hf                              {I@7}
(f0.0)  sel (16|M16)             acc0.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw              {F@1}
(f1.0)  sel (16|M16)             acc2.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw             
(f0.0)  cmp (16|M0)   (eq)f0.0   null<1>:d     r44.0<1;1,0>:d    0:w              
        and (16|M16)  (ne)f0.0   null<1>:uw    acc0.0<1;1,0>:uw  acc2.0<1;1,0>:uw
(~f0.0) goto (32|M0)                         L42256                  L42416                
L42112:
        shr (16|M0)              r18.0<1>:ud   r30.0<1;1,0>:ud   1:w              
        shr (16|M16)             r40.0<1>:ud   r52.0<1;1,0>:ud   1:w              
        mov (16|M0)              r48.0<1>:d    0:w                              
        mov (16|M16)             r60.0<1>:d    0:w                              
        mov (16|M0)              r44.0<1>:d    0:w                              
        mov (16|M16)             r58.0<1>:d    0:w                              
        mov (16|M0)              r24.0<1>:f    r18.0<1;1,0>:f                   {Compacted,I@6}
        mov (16|M16)             r6.0<1>:f     r40.0<1;1,0>:f                   {Compacted,I@5}
        mov (16|M0)              r18.0<1>:f    r30.0<1;1,0>:f                   {Compacted}
        mov (16|M16)             r40.0<1>:f    r52.0<1;1,0>:f                   {Compacted}
        goto (32|M0)                         L42256                  L44312                
L42256:
        join (32|M0)                         L42416                                
L42272:
        cmp (16|M16)  (eq)f0.0   null<1>:d     r46.0<1;1,0>:d    38:w              
        cmp (16|M16)  (eq)f1.0   null<1>:d     r42.0<1;1,0>:d    0:w              
        cmp (16|M0)   (eq)f1.0   null<1>:d     r48.0<1;1,0>:d    38:w               {I@7}
(W)     mov (1|M0)               r3.0<1>:hf    0x1:hf                             
(f1.0)  sel (16|M16)             acc0.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw              {F@1}
(f0.0)  sel (16|M16)             acc2.0<1>:uw  r3.0<0;1,0>:uw    0x0:uw             
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r44.0<1;1,0>:d    0:w               {I@7}
        and (16|M16)  (ne)f1.0   null<1>:uw    acc0.0<1;1,0>:uw  acc2.0<1;1,0>:uw
(f1.0)  goto (32|M0)                         L42416                  L44168                
L42416:
        join (32|M0)                         L44168                                
L42432:
        add (16|M0)              r4.0<1>:d     -r48.0<1;1,0>:d   39:w               {Compacted}
        add (16|M16)             r12.0<1>:d    -r46.0<1;1,0>:d   39:w               {Compacted}
        and (16|M0)   (ne)f0.0   r14.0<1>:d    r4.0<1;1,0>:d     63:w               {Compacted,I@2}
        and (16|M16)  (ne)f0.0   r2.0<1>:d     r12.0<1;1,0>:d    63:w               {I@2}
        add (16|M0)              r70.0<1>:d    -r48.0<1;1,0>:d   40:w               {Compacted}
        add (16|M16)             r72.0<1>:d    -r46.0<1;1,0>:d   40:w               {Compacted}
(f0.0)  goto (32|M0)                         L42544                  L42544                
L42504:
        mov (16|M0)              r42.0<1>:f    r30.0<1;1,0>:f                   {Compacted}
        mov (16|M16)             r64.0<1>:d    r52.0<1;1,0>:d                  
        goto (32|M0)                         L42544                  L42808                
L42544:
        join (32|M0)                         L42808                                
L42560:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r14.0<1;1,0>:ud   0x20:uw              {I@7}
        cmp (16|M16)  (lt)f1.0   null<1>:d     r2.0<1;1,0>:ud    0x20:uw              {I@7}
(f1.0)  goto (32|M0)                         L42672                  L42672                
L42608:
        add (16|M0)              r4.0<1>:d     r14.0<1;1,0>:d    -32:w               {Compacted}
        add (16|M16)             r12.0<1>:d    r2.0<1;1,0>:d     -32:w               {Compacted}
        shr (16|M0)              r18.0<1>:ud   r24.0<1;1,0>:ud   r4.0<1;1,0>:d    {I@2}
        shr (16|M16)             r40.0<1>:ud   r50.0<1;1,0>:ud   r12.0<1;1,0>:d   {I@2}
        goto (32|M0)                         L42672                  L42768                
L42672:
        join (32|M0)                         L42768                                
L42688:
        add (16|M0)              r4.0<1>:d     -r14.0<1;1,0>:d   32:w               {Compacted}
        add (16|M16)             r12.0<1>:d    -r2.0<1;1,0>:d    32:w               {Compacted}
        shr (16|M16)             r16.0<1>:ud   r52.0<1;1,0>:ud   r2.0<1;1,0>:d   
        shl (16|M0)              r4.0<1>:d     r24.0<1;1,0>:d    r4.0<1;1,0>:d    {Compacted,I@3}
        shr (16|M0)              r14.0<1>:ud   r30.0<1;1,0>:ud   r14.0<1;1,0>:d  
        shl (16|M16)             r12.0<1>:d    r50.0<1;1,0>:d    r12.0<1;1,0>:d   {Compacted,I@4}
        or (16|M0)               r18.0<1>:d    r14.0<1;1,0>:d    r4.0<1;1,0>:d    {Compacted,I@2}
        or (16|M16)              r40.0<1>:d    r16.0<1;1,0>:d    r12.0<1;1,0>:d   {Compacted,I@2}
L42768:
        join (32|M0)                         L42808                                
L42784:
        mov (16|M0)              r42.0<1>:f    r18.0<1;1,0>:f                   {Compacted,I@3}
        mov (16|M16)             r64.0<1>:d    r40.0<1;1,0>:d                   {I@2}
L42808:
        join (32|M0)                         L44168                                
L42824:
        add (16|M0)              r20.0<1>:d    -r48.0<1;1,0>:d   38:w               {Compacted}
        add (16|M16)             r2.0<1>:d     -r46.0<1;1,0>:d   38:w               {Compacted}
        and (16|M0)   (ne)f0.0   r14.0<1>:d    r20.0<1;1,0>:d    63:w               {Compacted,I@2}
        and (16|M16)  (ne)f0.0   r16.0<1>:d    r2.0<1;1,0>:d     63:w               {I@2}
(f0.0)  goto (32|M0)                         L42920                  L42920                
L42880:
        mov (16|M0)              r18.0<1>:f    r30.0<1;1,0>:f                   {Compacted}
        mov (16|M16)             r40.0<1>:d    r52.0<1;1,0>:d                  
        goto (32|M0)                         L42920                  L43144                
L42920:
        join (32|M0)                         L43144                                
L42936:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r14.0<1;1,0>:ud   0x20:uw              {I@6}
        cmp (16|M16)  (lt)f1.0   null<1>:d     r16.0<1;1,0>:ud   0x20:uw              {I@6}
(f1.0)  goto (32|M0)                         L43048                  L43048                
L42984:
        add (16|M0)              r4.0<1>:d     r14.0<1;1,0>:d    -32:w               {Compacted}
        add (16|M16)             r12.0<1>:d    r16.0<1;1,0>:d    -32:w               {Compacted}
        shr (16|M0)              r18.0<1>:ud   r24.0<1;1,0>:ud   r4.0<1;1,0>:d    {A@1}
        shr (16|M16)             r40.0<1>:ud   r50.0<1;1,0>:ud   r12.0<1;1,0>:d   {I@2}
        goto (32|M0)                         L43048                  L43144                
L43048:
        join (32|M0)                         L43144                                
L43064:
        add (16|M0)              r4.0<1>:d     -r14.0<1;1,0>:d   32:w               {Compacted}
        add (16|M16)             r12.0<1>:d    -r16.0<1;1,0>:d   32:w               {Compacted}
        shl (16|M0)              r4.0<1>:d     r24.0<1;1,0>:d    r4.0<1;1,0>:d    {Compacted,I@2}
        shr (16|M0)              r14.0<1>:ud   r30.0<1;1,0>:ud   r14.0<1;1,0>:d  
        shl (16|M16)             r12.0<1>:d    r50.0<1;1,0>:d    r12.0<1;1,0>:d   {Compacted,I@3}
        shr (16|M16)             r16.0<1>:ud   r52.0<1;1,0>:ud   r16.0<1;1,0>:d  
        or (16|M0)               r18.0<1>:d    r14.0<1;1,0>:d    r4.0<1;1,0>:d    {Compacted,I@3}
        or (16|M16)              r40.0<1>:d    r16.0<1;1,0>:d    r12.0<1;1,0>:d   {Compacted,I@2}
L43144:
        join (32|M0)                         L44168                                
L43160:
        and (16|M0)   (ne)f0.0   r4.0<1>:d     r20.0<1;1,0>:d    63:w               {Compacted}
        and (16|M16)  (ne)f0.0   r20.0<1>:d    r2.0<1;1,0>:d     63:w              
        and (16|M0)              r44.0<1>:d    r18.0<1;1,0>:d    1:w               {Compacted,I@5}
        and (16|M16)             r58.0<1>:d    r40.0<1;1,0>:d    1:w               {Compacted,I@5}
(f0.0)  goto (32|M0)                         L43296                  L43296                
L43216:
        mov (16|M0)              r4.0<1>:d     -1:w                              
        mov (16|M16)             r14.0<1>:d    -1:w                              
        mov (16|M0)              r18.0<1>:d    -1:w                              
        mov (16|M16)             r16.0<1>:d    -1:w                              
        goto (32|M0)                         L43296                  L43568                
L43296:
        join (32|M0)                         L43568                                
L43312:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r4.0<1;1,0>:ud    0x20:uw              {I@6}
        cmp (16|M16)  (lt)f1.0   null<1>:d     r20.0<1;1,0>:ud   0x20:uw             
(f1.0)  goto (32|M0)                         L43472                  L43472                
L43360:
        add (16|M0)              r4.0<1>:d     r4.0<1;1,0>:d     -32:w               {Compacted}
        add (16|M16)             r12.0<1>:d    r20.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r3.0<1>:hf    -qnan(0x1FF):hf                             
        mov (16|M16)             r14.0<1>:d    0:w                              
        shl (16|M0)              r18.0<1>:d    r3.0<0;1,0>:w     r4.0<1;1,0>:d    {A@1}
        shl (16|M16)             r16.0<1>:d    r3.0<0;1,0>:w     r12.0<1;1,0>:d   {I@3}
        mov (16|M0)              r4.0<1>:d     0:w                              
        goto (32|M0)                         L43472                  L43568                
L43472:
        join (32|M0)                         L43568                                
L43488:
(W)     mov (1|M0)               r3.0<1>:hf    -qnan(0x1FF):hf                              {I@4}
        mov (16|M0)              r18.0<1>:d    -1:w                              
        mov (16|M16)             r16.0<1>:d    -1:w                              
        shl (16|M0)              r4.0<1>:d     r3.0<0;1,0>:w     r4.0<1;1,0>:d    {A@1}
        shl (16|M16)             r14.0<1>:d    r3.0<0;1,0>:w     r20.0<1;1,0>:d  
L43568:
        join (32|M0)                         L44168                                
L43584:
        bfn.0x28 (16|M0)         r4.0<1>:ud    r30.0<1;0>:ud     r4.0<1;0>:ud      r9.0<0>:ud       {I@3} // s0&(s1^s2)
        bfn.0x28 (16|M16)        r12.0<1>:ud   r52.0<1;0>:ud     r14.0<1;0>:ud     r9.0<0>:ud       {I@3} // s0&(s1^s2)
        cmp (16|M0)   (ne)f0.0   null<1>:d     r4.0<1;1,0>:d     0:w               {Compacted,I@2}
        cmp (16|M16)  (ne)f0.0   null<1>:d     r12.0<1;1,0>:d    0:w               {I@2}
        bfn.0x28 (16|M16)        r16.0<1>:ud   r50.0<1;0>:ud     r16.0<1;0>:ud     r9.0<0>:ud       // s0&(s1^s2)
        bfn.0x28 (16|M0)         r14.0<1>:ud   r24.0<1;0>:ud     r18.0<1;0>:ud     r9.0<0>:ud       // s0&(s1^s2)
(~f0.0) cmp (16|M16)  (ne)f0.0   null<1>:d     r16.0<1;1,0>:d    0:w               {I@2}
(~f0.0) cmp (16|M0)   (ne)f0.0   null<1>:d     r14.0<1;1,0>:d    0:w               {I@2}
(W)     mov (1|M0)               r3.0<1>:hf    -qnan(0x1FF):hf                             
(f0.0)  sel (16|M0)              r18.0<1>:d    r3.0<0;1,0>:w     0:w               {F@1}
(f0.0)  sel (16|M16)             r20.0<1>:d    r3.0<0;1,0>:w     0:w              
        and (16|M0)   (ne)f0.0   r14.0<1>:d    r70.0<1;1,0>:d    63:w               {Compacted}
        and (16|M16)  (ne)f0.0   r2.0<1>:d     r72.0<1;1,0>:d    63:w              
        mov (16|M0)              r48.0<1>:d    -r18.0<1;1,0>:d                  {I@4}
        mov (16|M16)             r60.0<1>:d    -r20.0<1;1,0>:d                  {I@4}
(f0.0)  goto (32|M0)                         L43864                  L43864                
L43824:
        mov (16|M0)              r18.0<1>:f    r30.0<1;1,0>:f                   {Compacted,I@3}
        mov (16|M16)             r40.0<1>:d    r52.0<1;1,0>:d                  
        goto (32|M0)                         L43864                  L44088                
L43864:
        join (32|M0)                         L44088                                
L43880:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r14.0<1;1,0>:ud   0x20:uw             
        cmp (16|M16)  (lt)f1.0   null<1>:d     r2.0<1;1,0>:ud    0x20:uw             
(f1.0)  goto (32|M0)                         L43992                  L43992                
L43928:
        add (16|M0)              r4.0<1>:d     r14.0<1;1,0>:d    -32:w               {Compacted}
        add (16|M16)             r12.0<1>:d    r2.0<1;1,0>:d     -32:w               {Compacted}
        shr (16|M0)              r18.0<1>:ud   r24.0<1;1,0>:ud   r4.0<1;1,0>:d    {A@1}
        shr (16|M16)             r40.0<1>:ud   r50.0<1;1,0>:ud   r12.0<1;1,0>:d   {I@2}
        goto (32|M0)                         L43992                  L44088                
L43992:
        join (32|M0)                         L44088                                
L44008:
        add (16|M0)              r4.0<1>:d     -r14.0<1;1,0>:d   32:w               {Compacted}
        add (16|M16)             r12.0<1>:d    -r2.0<1;1,0>:d    32:w               {Compacted}
        shr (16|M16)             r16.0<1>:ud   r52.0<1;1,0>:ud   r2.0<1;1,0>:d   
        shl (16|M0)              r4.0<1>:d     r24.0<1;1,0>:d    r4.0<1;1,0>:d    {Compacted,I@3}
        shr (16|M0)              r14.0<1>:ud   r30.0<1;1,0>:ud   r14.0<1;1,0>:d  
        shl (16|M16)             r12.0<1>:d    r50.0<1;1,0>:d    r12.0<1;1,0>:d   {Compacted,I@4}
        or (16|M0)               r18.0<1>:d    r14.0<1;1,0>:d    r4.0<1;1,0>:d    {Compacted,I@2}
        or (16|M16)              r40.0<1>:d    r16.0<1;1,0>:d    r12.0<1;1,0>:d   {Compacted,I@2}
L44088:
        join (32|M0)                         L44168                                
L44104:
        mov (16|M0)              r24.0<1>:f    r18.0<1;1,0>:f                   {Compacted,I@3}
        mov (16|M16)             r6.0<1>:f     r40.0<1;1,0>:f                   {Compacted,I@2}
        mov (16|M0)              r18.0<1>:d    r42.0<1;1,0>:d                   {F@2}
        mov (16|M16)             r40.0<1>:d    r64.0<1;1,0>:d                   {F@1}
        goto (32|M0)                         L44168                  L44312                
L44168:
        join (32|M0)                         L44312                                
L44184:
        shr (16|M0)              r18.0<1>:ud   r30.0<1;1,0>:ud   2:w              
        shr (16|M16)             r40.0<1>:ud   r52.0<1;1,0>:ud   2:w              
        and (16|M0)              r44.0<1>:d    r30.0<1;1,0>:d    1:w               {Compacted}
        and (16|M16)             r58.0<1>:d    r52.0<1;1,0>:d    1:w               {Compacted}
        mov (16|M0)              r48.0<1>:d    0:w                              
        mov (16|M16)             r60.0<1>:d    0:w                              
        mov (16|M0)              r24.0<1>:f    r18.0<1;1,0>:f                   {Compacted,I@6}
        mov (16|M16)             r6.0<1>:f     r40.0<1;1,0>:f                   {Compacted,I@5}
        shr (16|M0)              r18.0<1>:ud   r30.0<1;1,0>:ud   1:w               {F@2}
        shr (16|M16)             r40.0<1>:ud   r52.0<1;1,0>:ud   1:w               {F@1}
L44312:
        join (32|M0)                         L45160                                
L44328:
        shl (16|M0)              r4.0<1>:d     r18.0<1;1,0>:d    2:w               {Compacted,I@3}
        shl (16|M16)             r12.0<1>:d    r40.0<1;1,0>:d    2:w               {Compacted,I@3}
        shl (16|M0)              r14.0<1>:d    r44.0<1;1,0>:d    1:w               {Compacted}
        shl (16|M16)             r16.0<1>:d    r58.0<1;1,0>:d    1:w               {Compacted}
        and (16|M0)              r4.0<1>:d     r4.0<1;1,0>:d     4:w               {Compacted,I@4}
        and (16|M16)             r12.0<1>:d    r12.0<1;1,0>:d    4:w               {Compacted,I@4}
        bfn.0xFE (16|M0)         r4.0<1>:ud    r4.0<1;0>:ud      r14.0<1;0>:ud     r48.0<1>:ud      {I@2} // s0|s1|s2
        bfn.0xFE (16|M16)        r14.0<1>:ud   r12.0<1;0>:ud     r16.0<1;0>:ud     r60.0<1>:ud      {I@2} // s0|s1|s2
        cmp (16|M0)   (eq)f0.0   null<1>:d     r4.0<1;1,0>:d     0:w               {Compacted,I@2}
        cmp (16|M16)  (eq)f0.0   null<1>:d     r14.0<1;1,0>:d    0:w               {I@2}
        and (16|M0)              r20.0<1>:d    r24.0<1;1,0>:d    8388607:d              
        and (16|M16)             r42.0<1>:d    r6.0<1;1,0>:d     8388607:d              
(~f0.0) goto (32|M0)                         L44528                  L44528                
L44480:
        mov (16|M0)              r4.0<1>:d     0:w                              
        mov (16|M16)             r12.0<1>:d    0:w                              
        goto (32|M0)                         L44528                  L44768                
L44528:
        join (32|M0)                         L44768                                
L44544:
        cmp (16|M0)   (gt)f1.0   null<1>:d     r4.0<1;1,0>:ud    0x4:uw              {I@4}
        cmp (16|M16)  (gt)f1.0   null<1>:d     r14.0<1;1,0>:ud   0x4:uw             
(~f1.0) goto (32|M0)                         L44640                  L44640                
L44592:
        mov (16|M0)              r4.0<1>:d     1:w                              
        mov (16|M16)             r12.0<1>:d    1:w                              
        goto (32|M0)                         L44640                  L44768                
L44640:
        join (32|M0)                         L44768                                
L44656:
        and (16|M0)   (ne)f1.0   null<1>:d     r24.0<1;1,0>:d    1:w              
        and (16|M16)  (ne)f1.0   null<1>:d     r6.0<1;1,0>:d     1:w              
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r4.0<1;1,0>:d     4:w               {I@6}
(f1.0)  cmp (16|M16)  (eq)f1.0   null<1>:d     r14.0<1;1,0>:d    4:w              
(W)     mov (1|M0)               r3.0<1>:hf    0x1:hf                             
(f1.0)  sel (16|M0)              r4.0<1>:d     r3.0<0;1,0>:w     0:w               {F@1}
(f1.0)  sel (16|M16)             r12.0<1>:d    r3.0<0;1,0>:w     0:w              
L44768:
        join (32|M0)                         L45160                                
L44784:
        add (16|M0)              r14.0<1>:d    r20.0<1;1,0>:d    r4.0<1;1,0>:d    {Compacted,I@3}
        add (16|M16)             r6.0<1>:d     r42.0<1;1,0>:d    r12.0<1;1,0>:d   {Compacted,I@3}
        cmp (16|M0)   (gt)f0.0   null<1>:d     r14.0<1;1,0>:ud   0x7FFFFF:ud              {I@2}
        cmp (16|M16)  (gt)f0.0   null<1>:d     r6.0<1;1,0>:ud    0x7FFFFF:ud              {I@2}
        add3 (16|M0)             r4.0<1>:d     r34.0<1;0>:d      r56.0<1;0>:d      82:w              
        add3 (16|M16)            r12.0<1>:d    r32.0<1;0>:d      r54.0<1;0>:d      82:w              
(f0.0)  sel (16|M0)              r18.0<1>:d    r4.0<1;1,0>:d     r66.0<1;1,0>:d   {Compacted,I@2}
(f0.0)  sel (16|M16)             r2.0<1>:d     r12.0<1;1,0>:d    r68.0<1;1,0>:d   {I@2}
        cmp (16|M0)   (eq)f1.0   null<1>:d     r18.0<1;1,0>:d    255:w               {I@2}
        cmp (16|M16)  (eq)f1.0   null<1>:d     r2.0<1;1,0>:d     255:w               {I@2}
(f1.0)  goto (32|M0)                         L45064                  L45064                
L44936:
(~f0.0) sel (16|M0)              r4.0<1>:d     r14.0<1;1,0>:d    0:w              
(~f0.0) sel (16|M16)             r12.0<1>:d    r6.0<1;1,0>:d     0:w              
        and (16|M16)             r16.0<1>:d    r28.0<1;1,0>:d    -2147483648:d              
        shl (16|M0)              r18.0<1>:d    r18.0<1;1,0>:d    23:w               {Compacted}
        shl (16|M16)             r20.0<1>:d    r2.0<1;1,0>:d     23:w               {Compacted}
        and (16|M0)              r14.0<1>:d    r22.0<1;1,0>:d    -2147483648:d              
        bfn.0xFE (16|M16)        r26.0<1>:ud   r16.0<1;0>:ud     r20.0<1;0>:ud     r12.0<1>:ud      {I@2} // s0|s1|s2
        bfn.0xFE (16|M0)         r22.0<1>:ud   r14.0<1;0>:ud     r18.0<1;0>:ud     r4.0<1>:ud       {I@2} // s0|s1|s2
        goto (32|M0)                         L45064                  L45928                
L45064:
        join (32|M0)                         L45160                                
L45080:
        cmp (16|M0)   (gt)f1.0   null<1>:d     r22.0<1;1,0>:d    -1:w               {I@3}
        cmp (16|M16)  (gt)f1.0   null<1>:d     r28.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r3.0<1>:f     inf:f                               {Compacted}
(f1.0)  sel (16|M0)              r22.0<1>:f    r3.0<0;1,0>:f     -inf:f               {Compacted,A@1}
(f1.0)  sel (16|M16)             r26.0<1>:f    r3.0<0;1,0>:f     -inf:f              
        goto (32|M0)                         L45160                  L45928                
L45160:
        join (32|M0)                         L45616                                
L45176:
        and (16|M0)   (ne)f0.0   r12.0<1>:d    r56.0<1;1,0>:d    63:w               {Compacted}
        and (16|M16)  (ne)f0.0   r4.0<1>:d     r54.0<1;1,0>:d    63:w              
(f0.0)  goto (32|M0)                         L45264                  L45264                
L45216:
        mov (16|M0)              r12.0<1>:d    -1:w                              
        mov (16|M16)             r6.0<1>:d     -1:w                              
        goto (32|M0)                         L45264                  L45440                
L45264:
        join (32|M0)                         L45440                                
L45280:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r12.0<1;1,0>:ud   0x20:uw              {A@1}
        cmp (16|M16)  (lt)f1.0   null<1>:d     r4.0<1;1,0>:ud    0x20:uw             
(f1.0)  goto (32|M0)                         L45376                  L45376                
L45328:
        mov (16|M0)              r12.0<1>:d    0:w                              
        mov (16|M16)             r6.0<1>:d     0:w                              
        goto (32|M0)                         L45376                  L45440                
L45376:
        join (32|M0)                         L45440                                
L45392:
(W)     mov (1|M0)               r3.0<1>:hf    -qnan(0x1FF):hf                             
        shl (16|M0)              r12.0<1>:d    r3.0<0;1,0>:w     r12.0<1;1,0>:d   {A@1}
        shl (16|M16)             r6.0<1>:d     r3.0<0;1,0>:w     r4.0<1;1,0>:d   
L45440:
        join (32|M0)                         L45616                                
L45456:
        bfn.0x28 (16|M0)         r4.0<1>:ud    r30.0<1;0>:ud     r12.0<1;0>:ud     r9.0<0>:ud       {I@3} // s0&(s1^s2)
        add (16|M0)              r14.0<1>:d    -r56.0<1;1,0>:d   23:w               {Compacted}
        add (16|M16)             r16.0<1>:d    -r54.0<1;1,0>:d   23:w               {Compacted}
        bfn.0x28 (16|M16)        r12.0<1>:ud   r52.0<1;0>:ud     r6.0<1;0>:ud      r9.0<0>:ud       {I@5} // s0&(s1^s2)
        and (16|M0)              r18.0<1>:d    r22.0<1;1,0>:d    -2147483648:d              
        and (16|M16)             r20.0<1>:d    r28.0<1;1,0>:d    -2147483648:d              
        shl (16|M16)             r24.0<1>:d    r68.0<1;1,0>:d    23:w               {Compacted}
        shl (16|M0)              r4.0<1>:d     r4.0<1;1,0>:d     r14.0<1;1,0>:d   {Compacted,I@6}
        shl (16|M16)             r12.0<1>:d    r12.0<1;1,0>:d    r16.0<1;1,0>:d   {Compacted,I@5}
        shl (16|M0)              r22.0<1>:d    r66.0<1;1,0>:d    23:w               {Compacted}
        bfn.0xFE (16|M16)        r26.0<1>:ud   r20.0<1;0>:ud     r24.0<1;0>:ud     r12.0<1>:ud      {I@2} // s0|s1|s2
        bfn.0xFE (16|M0)         r22.0<1>:ud   r18.0<1;0>:ud     r22.0<1;0>:ud     r4.0<1>:ud       {I@2} // s0|s1|s2
        goto (32|M0)                         L45616                  L45928                
L45616:
        join (32|M0)                         L45704                                
L45632:
        cmp (16|M0)   (gt)f0.0   null<1>:d     r22.0<1;1,0>:d    -1:w               {Compacted,I@3}
        cmp (16|M16)  (gt)f0.0   null<1>:d     r28.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r3.0<1>:f     inf:f                               {Compacted}
(f0.0)  sel (16|M0)              r22.0<1>:f    r3.0<0;1,0>:f     -inf:f               {Compacted,A@1}
(f0.0)  sel (16|M16)             r26.0<1>:f    r3.0<0;1,0>:f     -inf:f              
        goto (32|M0)                         L45704                  L45928                
L45704:
        join (32|M0)                         L45792                                
L45720:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r22.0<1;1,0>:d    0:w               {Compacted,F@2}
        cmp (16|M16)  (lt)f1.0   null<1>:d     r28.0<1;1,0>:d    0:w              
(W)     mov (1|M0)               r3.0<1>:f     -0.0:f                               {Compacted}
(f1.0)  sel (16|M0)              r22.0<1>:f    r3.0<0;1,0>:f     0.0:f               {Compacted,A@1}
(f1.0)  sel (16|M16)             r26.0<1>:f    r3.0<0;1,0>:f     0.0:f              
        goto (32|M0)                         L45792                  L45928                
L45792:
        join (32|M0)                         L45880                                
L45808:
        cmp (16|M0)   (gt)f0.0   null<1>:d     r22.0<1;1,0>:d    -1:w               {Compacted,F@2}
        cmp (16|M16)  (gt)f0.0   null<1>:d     r28.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r3.0<1>:f     inf:f                               {Compacted}
(f0.0)  sel (16|M0)              r22.0<1>:f    r3.0<0;1,0>:f     -inf:f               {Compacted,A@1}
(f0.0)  sel (16|M16)             r26.0<1>:f    r3.0<0;1,0>:f     -inf:f              
        goto (32|M0)                         L45880                  L45928                
L45880:
        join (32|M0)                         L45928                                
L45896:
        bfn.0xF8 (16|M0)         r22.0<1>:ud   r22.0<1;0>:ud     r9.7<0;0>:ud      r9.3<0>:ud       {F@2} // s0&s1|s2
        bfn.0xF8 (16|M16)        r26.0<1>:ud   r28.0<1;0>:ud     r9.7<0;0>:ud      r9.3<0>:ud       {F@1} // s0&s1|s2
L45928:
        join (32|M0)                         L46248                                
L45944:
        mul (16|M0)              acc0.0<1>:f   r22.0<1;1,0>:f    r88.0<1;1,0>:f   {Compacted,I@3}
        mul (16|M16)             acc2.0<1>:f   r26.0<1;1,0>:f    r86.0<1;1,0>:f   {Compacted,I@2}
        rnde (16|M0)             acc0.0<1>:f   acc0.0<1;1,0>:f                 
        rnde (16|M16)            acc2.0<1>:f   acc2.0<1;1,0>:f                 
        sel (16|M0)   (ge)f0.0   acc0.0<1>:f   acc0.0<1;1,0>:f   -127.0:f              
        sel (16|M16)  (ge)f0.0   acc2.0<1>:f   acc2.0<1;1,0>:f   -127.0:f              
        add3 (16|M0)             r30.0<1>:d    r92.0<1;0>:d      r9.4<0;0>:d       r9.2<0>:d       
        add3 (16|M16)            r32.0<1>:d    r90.0<1;0>:d      r9.4<0;0>:d       r9.2<0>:d       
        sel (16|M0)   (lt)f0.0   r22.0<1>:f    acc0.0<1;1,0>:f   127.0:f              
        sel (16|M16)  (lt)f0.0   r24.0<1>:f    acc2.0<1;1,0>:f   127.0:f              
(W)     add (1|M0)               r9.2<1>:d     r9.2<0;1,0>:d     1:w              
(W)     mov (1|M0)               a0.0<1>:ud    r9.6<0;1,0>:d                    {A@1}
        mov (16|M0)              r26.0<1>:d    r22.0<1;1,0>:f                   {Compacted,F@2}
        mov (16|M16)             r28.0<1>:d    r24.0<1;1,0>:f                   {Compacted,F@1}
(W)     cmp (16|M0)   (lt)f0.0   null<1>:d     r9.2<0;1,0>:ud    r9.1<0;1,0>:ud   {I@4}
(W)     cmp (16|M16)  (lt)f0.0   null<1>:d     r9.2<0;1,0>:ud    r9.1<0;1,0>:ud  
        mov (16|M0)              r34.0<1>:ud   r26.0<4;1,0>:ub                  {I@4}
        mov (16|M16)             r4.0<1>:ud    r28.0<4;1,0>:ub                  {I@4}
        send.ugm (16|M0)         null     r30     r34:2   a0.0        0x240E0904           {ExBSO,A@2,$12} // wr:2+2, rd:0; store.ugm.d8u32.a32.wb.wb.bss[a0.0]
        send.ugm (16|M16)        null     r32     r4:2    a0.0        0x240E0904           {ExBSO,A@1,$11} // wr:2+2, rd:0; store.ugm.d8u32.a32.wb.wb.bss[a0.0]
(f0.0)  goto.b (32|M0)                       L46248                  L23752                
L46248:
        join (32|M0)                         L46320                                
L46264:
        sync.nop                             null                             {Compacted,$3.dst}
(W)     mov (1|M0)               a0.0<1>:ud    r10.1<0;1,0>:d                   {A@1}
        send.ugm (16|M0)         null     r112    r106:2  a0.0        0x240E0504           {ExBSO,$0} // wr:2+2, rd:0; store.ugm.d32.a32.wb.wb.bss[a0.0]
        send.ugm (16|M16)        null     r110    r108:2  a0.0        0x240E0504           {ExBSO,$1} // wr:2+2, rd:0; store.ugm.d32.a32.wb.wb.bss[a0.0]
L46320:
        join (32|M0)                         L46336                                
L46336:
(W)     mov (8|M0)               r127.0<1>:f   r62.0<1;1,0>:f                   {Compacted,$3.src}
(W)     send.gtwy (1|M0)         null     r127    null:0  0x0            0x02000010           {EOT,A@1} // wr:1+0, rd:0; end of thread
L46360:
        nop                    
(W)     mov (16|M0)              null<1>:ud    0x6F9278B:ud                             
(W)     mov (16|M0)              null<1>:ud    0x6180031B:ud                             
(W)     mov (16|M0)              null<1>:ud    0x0:ud                             
(W)     mov (16|M0)              null<1>:ud    0x20:ud                             
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
