L0:
(W)     mov (8|M0)               r127.0<1>:ud  0x0:ud                             
(W)     and (1|M0)               r127.2<1>:ud  r0.0<0;1,0>:ud    0xFFFFFFC0:ud             
(W)     and (1|M0)               r127.0<1>:uw  r0.4<0;1,0>:uw    0xFF:uw             
(W)     add (1|M0)               r127.2<1>:ud  r127.2<0;1,0>:ud  0x40:ud              {I@2}
(W)     add (1|M0)               r127.2<1>:ud  r127.2<0;1,0>:ud  0x0:ud              {I@1}
(W)     mad (1|M0)               r127.2<1>:ud  r127.2<0;0>:ud    r127.0<0;0>:uw    0x60:uw              {I@1}
(W)     mov (8|M0)               r4.0<1>:ud    r1.0<1;1,0>:ud                  
(W)     send.dc0 (8|M0)          r1       r127    null:0  0x0            0x022843FD           {A@1,$0} // wr:1h+0, rd:2; oword aligned block read x4
(W)     add (1|M0)               r127.2<1>:ud  r127.2<0;1,0>:ud  0x40:uw              {$0.src}
(W)     send.dc0 (8|M0)          r3       r127    null:0  0x0            0x021842FD           {A@1,$1} // wr:1h+0, rd:1; oword aligned block read x2
        nop                    
        nop                    
(W)     mov (8|M0)               r127.0<1>:ud  0x0:ud                              {$1.src}
(W)     and (1|M0)               r127.2<1>:ud  r0.0<0;1,0>:ud    0xFFFFFFC0:ud             
(W)     add (1|M0)               r127.2<1>:ud  r127.2<0;1,0>:ud  0x0:ud              {I@1}
(W)     send.dc0 (8|M0)          r5       r127    null:0  0x0            0x022843FD           {A@1,$2} // wr:1h+0, rd:2; oword aligned block read x4
(W)     mov (8|M0)               r2.0<1>:ud    r0.0<1;1,0>:ud                   {$0.dst}
(W)     or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x4C0:uw              {A@1}
(W)     mul (1|M0)               acc0.0<1>:d   r4.3<0;1,0>:d     r2.2<0;1,0>:uw   {A@1}
(W)     mach (1|M0)              r6.0<1>:d     r4.3<0;1,0>:d     r2.1<0;1,0>:d    {$2.dst}
(W)     mov (1|M0)               a0.0<1>:ud    r6.3<0;1,0>:d                    {A@1}
        add3 (8|M0)              r4.0<1>:d     r6.0<0;0>:d       r1.0<1;0>:uw      r4.0<0>:d        {I@2}
(W)     and (1|M0)               r6.0<1>:d     r5.7<0;1,0>:d     -2:w               {Compacted}
        sync.nop                             null                             {Compacted,$1.dst}
        shl (8|M0)               r3.0<1>:d     r4.0<1;1,0>:d     2:w               {Compacted,I@2}
(W)     cmp (8|M0)    (eq)f0.0   null<1>:d     r6.0<0;1,0>:d     2:w               {I@2}
        send.ugm (8|M0)          r56      r3      null:0  a0.0        0x22180500           {ExBSO,A@2,$3} // wr:1+0, rd:1; load.ugm.d32.a32.ca.ca.bss[a0.0]
(W)     mov (1|M0)               a0.0<1>:ud    r6.4<0;1,0>:d                    {A@1}
        and (8|M0)               r34.0<1>:d    r3.0<1;1,0>:d     124:w               {Compacted}
(W)     mov (1|M0)               r6.1<1>:f     -0.0:f                               {Compacted}
(W)     mov (1|M0)               r6.3<1>:d     -1:w                              
        send.ugm (8|M0)          r33      r34     null:0  a0.0        0x22180500           {ExBSO,A@2,$4} // wr:1+0, rd:1; load.ugm.d32.a32.ca.ca.bss[a0.0]
(W)     mov (1|M0)               a0.0<1>:ud    r6.5<0;1,0>:d                    {A@1}
(W)     mov (1|M0)               r6.0<1>:f     inf:f                               {Compacted}
        send.ugm (8|M0)          r32      r3      null:0  a0.0        0x22180500           {ExBSO,$5} // wr:1+0, rd:1; load.ugm.d32.a32.ca.ca.bss[a0.0]
        sync.allwr                           ($4,$5)                
        mad (8|M0)               r7.0<1>:f     r32.0<1;0>:f      r33.0<1;0>:f      r56.0<1>:f       {Compacted,$3.dst}
(~f0.0) goto (8|M0)                          L28712                  L28712                
L552:
        mov (8|M0)               r8.0<1>:hf    r7.0<1;1,0>:f                    {F@1}
        mov (8|M0)               r8.0<1>:f     r8.0<1;1,0>:hf                   {F@1}
        sel (8|M0)    (ge)f0.0   acc0.0<1>:f   r8.0<1;1,0>:f     -4.0:f               {Compacted,F@1}
        sel (8|M0)    (lt)f0.0   r12.0<1>:f    acc0.0<1;1,0>:f   4.0:f               {Compacted}
        and (8|M0)    (ne)f0.0   r9.0<1>:d     r12.0<1;1,0>:d    8388607:d               {F@1}
        shr (8|M0)               r11.0<1>:ud   r12.0<1;1,0>:ud   23:w              
        and (8|M0)               r10.0<1>:d    r11.0<1;1,0>:d    255:w               {Compacted,I@1}
        cmp (8|M0)    (ne)f1.1   null<1>:d     r9.0<1;1,0>:d     0:w              
(f0.0)  cmp (8|M0)    (eq)f0.0   null<1>:d     r10.0<1;1,0>:d    255:w               {I@2}
(f1.1)  cmp (8|M0)    (eq)f1.1   null<1>:d     r10.0<1;1,0>:d    255:w              
(~f1.1) goto (8|M0)                          L728                  L728                
L704:
        mov (8|M0)               r101.0<1>:f   qnan(0x0):f                               {Compacted}
        goto (8|M0)                          L728                  L6488                
L728:
        join (8|M0)                          L6488                                
L744:
        cmp (8|M0)    (eq)f1.0   null<1>:d     r9.0<1;1,0>:d     0:w              
(f1.0)  cmp (8|M0)    (eq)f1.0   null<1>:d     r10.0<1;1,0>:d    255:w              
(~f1.0) goto (8|M0)                          L816                  L816                
L792:
        mov (8|M0)               r101.0<1>:f   -inf:f                               {Compacted}
        goto (8|M0)                          L816                  L6488                
L816:
        join (8|M0)                          L6488                                
L832:
        or (8|M0)     (eq)f1.0   null<1>:d     r10.0<1;1,0>:d    r9.0<1;1,0>:d   
(~f1.0) goto (8|M0)                          L888                  L888                
L864:
        mov (8|M0)               r101.0<1>:f   0.0:f                               {Compacted}
        goto (8|M0)                          L888                  L6488                
L888:
        join (8|M0)                          L6488                                
L904:
        cmp (8|M0)    (eq)f1.1   null<1>:d     r10.0<1;1,0>:d    0:w              
(W)     mov (1|M0)               r6.8<1>:hf    0.0:hf                             
        add (8|M0)               r30.0<1>:d    r10.0<1;1,0>:d    -132:w               {Compacted}
(W)     mov (1|M0)               r13.5<1>:d    0:w                              
(f1.1)  sel (8|M0)               acc0.0<1>:d   r6.8<0;1,0>:w     8388608:d               {F@1}
(W)     mov (1|M0)               r13.4<1>:f    -0.0:f                               {Compacted}
        or (8|M0)                r96.0<1>:d    acc0.0<1;1,0>:d   r9.0<1;1,0>:d   
(W)     mov (2|M0)               r6.4<1>:d     0:w                              
        mul (8|M0)               acc0.0<1>:ud  r96.0<1;1,0>:ud   0x0:uw              {I@2}
        mach (8|M0)              r92.0<1>:ud   r96.0<1;1,0>:ud   0xE50000:ud              {AccWrEn}
        mov (8|M0)               acc0.0<1>:ud  acc0.0<1;1,0>:ud                
        mov (8|M0)               r112.0<1>:f   r92.0<1;1,0>:f                   {Compacted,I@2}
        mov (8|M0)               r104.0<1>:ud  acc0.0<1;1,0>:ud                 {Compacted}
L1080:
(W)     shl (1|M0)               r13.2<1>:d    r13.4<0;1,0>:d    31:w               {F@2}
(W)     shr (1|M0)               r13.1<1>:ud   r13.5<0;1,0>:ud   1:w              
(W)     cmp (8|M0)    (gt)f0.1   null<1>:ud    r6.4<0;1,0>:ud    0x3E:uw             
(W)     or (1|M0)                r13.5<1>:d    r13.1<0;1,0>:d    r13.2<0;1,0>:d   {I@2}
        bfn.0xA8 (8|M0)          r36.0<1>:ud   r104.0<1;0>:ud    r13.1<0;0>:ud     r13.2<0>:ud      // s0&(s1|s2)
(W)     shr (1|M0)               r6.7<1>:ud    r13.4<0;1,0>:ud   1:w              
(W&f0.1) cmp (8|M0)   (eq)f0.1   null<1>:d     r6.5<0;1,0>:d     0:w              
        cmp (8|M0)    (eq)f1.0   null<1>:d     r36.0<1;1,0>:d    r13.5<0;1,0>:d   {I@3}
(W)     addc (1|M0)              r15.0<1>:ud   r6.4<0;1,0>:ud    0x1:ud              {AccWrEn}
        and (8|M0)               r35.0<1>:d    r112.0<1;1,0>:d   r6.7<0;1,0>:d    {Compacted,A@1}
(W)     mov (1|M0)               r13.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
(W&~f0.1) cmp (8|M0)  (gt)f0.1   null<1>:ud    r6.5<0;1,0>:ud    0x0:uw             
(f1.0)  cmp (8|M0)    (eq)f1.0   null<1>:d     r35.0<1;1,0>:d    r6.7<0;1,0>:d    {I@3}
(W)     add (1|M0)               r13.6<1>:ud   r13.0<0;1,0>:ud   r6.5<0;1,0>:ud   {I@3}
(W)     mov (1|M0)               r13.0<1>:hf   0x1:hf                              {I@1}
        mov (8|M0)               r127.0<1>:d   r6.4<0;1,0>:d                   
(f0.1)  sel (8|M0)               r14.0<1>:uw   r13.0<0;1,0>:uw   0x0:uw              {F@1}
(f1.0)  sel (8|M0)               r13.0<1>:uw   r13.0<0;1,0>:uw   0x0:uw             
        mov (8|M0)               r17.0<1>:d    r6.5<0;1,0>:d                   
        or (8|M0)     (ne)f0.1   null<1>:uw    r14.0<1;1,0>:uw   r13.0<1;1,0>:uw  {I@2}
        mov (8|M0)               r24.0<1>:f    r15.0<0;1,0>:f                   {Compacted}
        mov (8|M0)               r86.0<1>:d    r13.6<0;1,0>:d                  
(f0.1)  goto (8|M0)                          L1488                  L1488                
L1424:
(W)     mov (1|M0)               r13.4<1>:d    r6.7<0;1,0>:d                   
(W)     mov (1|M0)               r6.4<1>:d     r15.0<0;1,0>:d                  
(W)     mov (1|M0)               r6.5<1>:d     r13.6<0;1,0>:d                  
(W)     jmpi                                 L1080                                
L1488:
        join (8|M0)                          L6488                                
L1504:
(W)     mov (1|M0)               r6.4<1>:f     8.68805e-44:f                               {I@4}
(~f1.1) sel (8|M0)               r74.0<1>:d    r30.0<1;1,0>:d    -131:w              
        subb (8|M0)              r39.0<1>:ud   r6.4<0;1,0>:ud    r127.0<1;1,0>:ud {AccWrEn,Compacted,F@1}
(W)     mov (1|M0)               r13.0<1>:hf   0.0:hf                             
        add3 (8|M0)              r82.0<1>:d    r74.0<1;0>:d      r39.0<1;0>:d      -46:w               {I@1}
        add (8|M0)               r16.0<1>:d    r74.0<1;1,0>:d    r39.0<1;1,0>:d   {Compacted}
        cmp (8|M0)    (gt)f0.1   null<1>:d     r82.0<1;1,0>:d    127:w               {I@2}
        add3 (8|M0)              r29.0<1>:ud   -acc0.0<1;0>:ud   r13.0<0;0>:uw     -r17.0<1>:ud     {F@1}
(~f0.1) goto (8|M0)                          L1656                  L1656                
L1632:
        mov (8|M0)               r101.0<1>:f   -inf:f                               {Compacted}
        goto (8|M0)                          L1656                  L6488                
L1656:
        join (8|M0)                          L6488                                
L1672:
        cmp (8|M0)    (gt)f1.1   null<1>:d     r82.0<1;1,0>:d    -127:w              
(f1.1)  goto (8|M0)                          L4128                  L4128                
L1704:
        cmp (8|M0)    (lt)f1.0   null<1>:ud    r82.0<1;1,0>:ud   0xFFFFFF6B:ud             
(f1.0)  goto (8|M0)                          L3704                  L3704                
L1736:
(W)     mov (1|M0)               r6.4<1>:f     8.82818e-44:f                              
        add3 (8|M0)              r31.0<1>:d    r74.0<1;0>:d      r39.0<1;0>:d      104:w              
        subb (8|M0)              r89.0<1>:ud   r6.4<0;1,0>:ud    r127.0<1;1,0>:ud {AccWrEn,Compacted,F@1}
(W)     mov (1|M0)               r13.0<1>:hf   0.0:hf                              {I@7}
        cmp (8|M0)    (gt)f0.1   null<1>:ud    r89.0<1;1,0>:ud   r31.0<1;1,0>:ud  {I@1}
        add3 (8|M0)              r98.0<1>:ud   -acc0.0<1;0>:ud   r13.0<0;0>:uw     -r17.0<1>:ud     {F@1}
(f0.1)  cmp (8|M0)    (eq)f0.1   null<1>:d     r98.0<1;1,0>:d    0:w               {I@1}
(~f0.1) cmp (8|M0)    (gt)f0.1   null<1>:ud    r98.0<1;1,0>:ud   0x0:uw             
(f0.1)  goto (8|M0)                          L1936                  L1936                
L1872:
        add3 (8|M0)              acc0.0<1>:d   r16.0<1;0>:d      -r89.0<1;0>:d     104:w              
        mov (8|M0)               r103.0<1>:d   0:w                              
        shl (8|M0)               r104.0<1>:d   r104.0<1;1,0>:d   acc0.0<1;1,0>:d 
        goto (8|M0)                          L1936                  L3656                
L1936:
        join (8|M0)                          L3656                                
L1952:
        add3 (8|M0)              r120.0<1>:d   r89.0<1;0>:d      -r16.0<1;0>:d     -104:w              
        cmp (8|M0)    (lt)f0.1   null<1>:d     r120.0<1;1,0>:d   2:w               {I@1}
(f0.1)  goto (8|M0)                          L2104                  L2104                
L2000:
        cmp (8|M0)    (eq)f1.1   null<1>:d     r120.0<1;1,0>:d   2:w              
(~f1.1) goto (8|M0)                          L2104                  L2208                
L2032:
        shr (8|M0)               r94.0<1>:ud   r104.0<1;1,0>:ud  1:w              
        mov (8|M0)               r26.0<1>:d    0:w                              
        mov (8|M0)               r41.0<1>:d    0:w                              
        mov (8|M0)               r19.0<1>:f    r94.0<1;1,0>:f                   {Compacted,I@3}
        goto (8|M0)                          L2104                  L3088                
L2104:
        join (8|M0)                          L2208                                
L2120:
        cmp (8|M0)    (eq)f1.0   null<1>:d     r120.0<1;1,0>:d   1:w              
(~f1.0) goto (8|M0)                          L2208                  L2208                
L2152:
        mov (8|M0)               r26.0<1>:d    0:w                              
        mov (8|M0)               r41.0<1>:d    0:w                              
        mov (8|M0)               r19.0<1>:f    r104.0<1;1,0>:f                  {Compacted}
        goto (8|M0)                          L2208                  L3088                
L2208:
        join (8|M0)                          L3088                                
L2224:
        add3 (8|M0)              acc0.0<1>:d   r89.0<1;0>:d      -r31.0<1;0>:d     -1:w              
        and (8|M0)    (ne)f0.1   r27.0<1>:d    acc0.0<1;1,0>:d   63:w              
(f0.1)  goto (8|M0)                          L2304                  L2304                
L2272:
        mov (8|M0)               r24.0<1>:d    r104.0<1;1,0>:d                 
        goto (8|M0)                          L2304                  L2440                
L2304:
        join (8|M0)                          L2440                                
L2320:
        cmp (8|M0)    (lt)f1.1   null<1>:ud    r27.0<1;1,0>:ud   0x20:uw              {I@5}
(f1.1)  add (8|M0)               acc0.0<1>:d   -r27.0<1;1,0>:d   32:w              
(~f1.1) add (8|M0)               acc2.0<1>:d   r27.0<1;1,0>:d    -32:w              
(f1.1)  shr (8|M0)               r84.0<1>:ud   r104.0<1;1,0>:ud  r27.0<1;1,0>:d  
(f1.1)  shl (8|M0)               r95.0<1>:d    r112.0<1;1,0>:d   acc0.0<1;1,0>:d 
(~f1.1) shr (8|M0)               r94.0<1>:ud   r112.0<1;1,0>:ud  acc2.0<1;1,0>:d  {F@2}
(f1.1)  or (8|M0)                r94.0<1>:d    r84.0<1;1,0>:d    r95.0<1;1,0>:d   {I@2}
        mov (8|M0)               r24.0<1>:f    r94.0<1;1,0>:f                   {Compacted,I@1}
L2440:
        join (8|M0)                          L3088                                
L2456:
        add3 (8|M0)              r123.0<1>:d   r89.0<1;0>:d      -r31.0<1;0>:d     -2:w              
        and (8|M0)    (ne)f1.0   r26.0<1>:d    r123.0<1;1,0>:d   63:w               {I@1}
(f1.0)  goto (8|M0)                          L2536                  L2536                
L2504:
        mov (8|M0)               r94.0<1>:d    r104.0<1;1,0>:d                  {F@1}
        goto (8|M0)                          L2536                  L2664                
L2536:
        join (8|M0)                          L2664                                
L2552:
        cmp (8|M0)    (lt)f0.1   null<1>:ud    r26.0<1;1,0>:ud   0x20:uw              {I@5}
(~f0.1) add (8|M0)               acc0.0<1>:d   r26.0<1;1,0>:d    -32:w              
(f0.1)  shr (8|M0)               r82.0<1>:ud   r104.0<1;1,0>:ud  r26.0<1;1,0>:d  
(~f0.1) shr (8|M0)               r94.0<1>:ud   r112.0<1;1,0>:ud  acc0.0<1;1,0>:d 
(f0.1)  add (8|M0)               acc0.0<1>:d   -r26.0<1;1,0>:d   32:w              
(f0.1)  shl (8|M0)               r94.0<1>:d    r112.0<1;1,0>:d   acc0.0<1;1,0>:d 
(f0.1)  or (8|M0)                r94.0<1>:d    r82.0<1;1,0>:d    r94.0<1;1,0>:d   {I@1}
L2664:
        join (8|M0)                          L3088                                
L2680:
        and (8|M0)    (ne)f1.1   r93.0<1>:d    r123.0<1;1,0>:d   63:w              
        and (8|M0)               r41.0<1>:d    r94.0<1;1,0>:d    1:w               {Compacted,I@3}
(f1.1)  goto (8|M0)                          L2768                  L2768                
L2720:
        mov (8|M0)               r105.0<1>:d   -1:w                              
        mov (8|M0)               r114.0<1>:d   -1:w                              
        goto (8|M0)                          L2768                  L2952                
L2768:
        join (8|M0)                          L2952                                
L2784:
        cmp (8|M0)    (lt)f1.0   null<1>:ud    r93.0<1;1,0>:ud   0x20:uw              {I@7}
(f1.0)  goto (8|M0)                          L2888                  L2888                
L2816:
        add (8|M0)               acc0.0<1>:d   r93.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r6.8<1>:hf    -qnan(0x1FF):hf                             
        mov (8|M0)               r105.0<1>:d   0:w                              
        shl (8|M0)               r114.0<1>:d   r6.8<0;1,0>:w     acc0.0<1;1,0>:d  {F@1}
        goto (8|M0)                          L2888                  L2952                
L2888:
        join (8|M0)                          L2952                                
L2904:
(W)     mov (1|M0)               r6.8<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (8|M0)               r114.0<1>:d   -1:w                              
        shl (8|M0)               r105.0<1>:d   r6.8<0;1,0>:w     r93.0<1;1,0>:d   {F@1}
L2952:
        join (8|M0)                          L3088                                
L2968:
        bfn.0x28 (8|M0)          r81.0<1>:ud   r104.0<1;0>:ud    r105.0<1;0>:ud    r6.3<0>:ud       {I@2} // s0&(s1^s2)
        bfn.0x28 (8|M0)          r80.0<1>:ud   r112.0<1;0>:ud    r114.0<1;0>:ud    r6.3<0>:ud       // s0&(s1^s2)
        cmp (8|M0)    (ne)f0.1   null<1>:d     r81.0<1;1,0>:d    0:w               {I@2}
(W)     mov (1|M0)               r6.8<1>:hf    -qnan(0x1FF):hf                             
        mov (8|M0)               r19.0<1>:f    r24.0<1;1,0>:f                   {Compacted}
(~f0.1) cmp (8|M0)    (ne)f0.1   null<1>:d     r80.0<1;1,0>:d    0:w               {I@2}
(f0.1)  sel (8|M0)               acc0.0<1>:d   r6.8<0;1,0>:w     0:w               {F@2}
        mov (8|M0)               r26.0<1>:d    -acc0.0<1;1,0>:d                
L3088:
        join (8|M0)                          L3656                                
L3104:
        and (8|M0)    (ne)f0.1   r25.0<1>:d    r120.0<1;1,0>:d   63:w              
(f0.1)  goto (8|M0)                          L3168                  L3168                
L3136:
        mov (8|M0)               r94.0<1>:d    r104.0<1;1,0>:d                 
        goto (8|M0)                          L3168                  L3296                
L3168:
        join (8|M0)                          L3296                                
L3184:
        cmp (8|M0)    (lt)f1.1   null<1>:ud    r25.0<1;1,0>:ud   0x20:uw              {I@5}
(f1.1)  add (8|M0)               acc0.0<1>:d   -r25.0<1;1,0>:d   32:w              
(~f1.1) add (8|M0)               acc2.0<1>:d   r25.0<1;1,0>:d    -32:w              
(f1.1)  shr (8|M0)               r77.0<1>:ud   r104.0<1;1,0>:ud  r25.0<1;1,0>:d  
(f1.1)  shl (8|M0)               r92.0<1>:d    r112.0<1;1,0>:d   acc0.0<1;1,0>:d 
(~f1.1) shr (8|M0)               r94.0<1>:ud   r112.0<1;1,0>:ud  acc2.0<1;1,0>:d 
(f1.1)  or (8|M0)                r94.0<1>:d    r77.0<1;1,0>:d    r92.0<1;1,0>:d   {I@2}
L3296:
        join (8|M0)                          L3656                                
L3312:
        shl (8|M0)               r48.0<1>:d    r19.0<1;1,0>:d    2:w               {Compacted,F@1}
        shl (8|M0)               r76.0<1>:d    r41.0<1;1,0>:d    1:w               {Compacted}
        and (8|M0)               r48.0<1>:d    r48.0<1;1,0>:d    4:w               {Compacted,I@2}
        bfn.0xFE (8|M0)          r97.0<1>:ud   r48.0<1;0>:ud     r76.0<1;0>:ud     r26.0<1>:ud      {I@1} // s0|s1|s2
        cmp (8|M0)    (eq)f1.0   null<1>:d     r97.0<1;1,0>:d    0:w               {I@1}
(~f1.0) goto (8|M0)                          L3416                  L3416                
L3384:
        mov (8|M0)               r117.0<1>:d   0:w                              
        goto (8|M0)                          L3416                  L3576                
L3416:
        join (8|M0)                          L3576                                
L3432:
        cmp (8|M0)    (gt)f0.1   null<1>:ud    r97.0<1;1,0>:ud   0x4:uw             
(~f0.1) goto (8|M0)                          L3496                  L3496                
L3464:
        mov (8|M0)               r117.0<1>:d   1:w                              
        goto (8|M0)                          L3496                  L3576                
L3496:
        join (8|M0)                          L3576                                
L3512:
        and (8|M0)    (ne)f1.1   null<1>:d     r94.0<1;1,0>:d    1:w              
(W)     mov (1|M0)               r6.8<1>:hf    0x1:hf                             
(f1.1)  cmp (8|M0)    (eq)f1.1   null<1>:d     r97.0<1;1,0>:d    4:w              
(f1.1)  sel (8|M0)               r117.0<1>:d   r6.8<0;1,0>:w     0:w               {F@1}
L3576:
        join (8|M0)                          L3656                                
L3592:
        add (8|M0)               r60.0<1>:d    r117.0<1;1,0>:d   r94.0<1;1,0>:d   {Compacted,I@2}
(W)     mov (1|M0)               r6.4<1>:f     0x800000:f                               {Compacted}
        cmp (8|M0)    (gt)f1.0   null<1>:ud    r60.0<1;1,0>:ud   0x7FFFFF:ud              {I@1}
(~f1.0) sel (8|M0)               r104.0<1>:d   r60.0<1;1,0>:d    0:w              
(f1.0)  sel (8|M0)               r103.0<1>:d   r6.4<0;1,0>:d     0:w               {F@1}
L3656:
        join (8|M0)                          L3704                                
L3672:
        bfn.0xFE (8|M0)          r101.0<1>:ud  r103.0<1;0>:ud    r104.0<1;0>:ud    r6.1<0>:ud       {I@2} // s0|s1|s2
        goto (8|M0)                          L3704                  L6488                
L3704:
        join (8|M0)                          L4128                                
L3720:
        and (8|M0)    (ne)f1.1   r65.0<1>:d    r39.0<1;1,0>:d    63:w              
(f1.1)  goto (8|M0)                          L3800                  L3800                
L3752:
        mov (8|M0)               r79.0<1>:d    -1:w                              
        mov (8|M0)               r91.0<1>:d    -1:w                              
        goto (8|M0)                          L3800                  L3984                
L3800:
        join (8|M0)                          L3984                                
L3816:
        cmp (8|M0)    (lt)f1.0   null<1>:ud    r65.0<1;1,0>:ud   0x20:uw              {I@6}
(f1.0)  goto (8|M0)                          L3920                  L3920                
L3848:
        add (8|M0)               acc0.0<1>:d   r65.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r6.8<1>:hf    -qnan(0x1FF):hf                             
        mov (8|M0)               r79.0<1>:d    0:w                              
        shl (8|M0)               r91.0<1>:d    r6.8<0;1,0>:w     acc0.0<1;1,0>:d  {F@1}
        goto (8|M0)                          L3920                  L3984                
L3920:
        join (8|M0)                          L3984                                
L3936:
(W)     mov (1|M0)               r6.8<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (8|M0)               r91.0<1>:d    -1:w                              
        shl (8|M0)               r79.0<1>:d    r6.8<0;1,0>:w     r65.0<1;1,0>:d   {F@1}
L3984:
        join (8|M0)                          L4128                                
L4000:
        bfn.0x28 (8|M0)          r75.0<1>:ud   r104.0<1;0>:ud    r79.0<1;0>:ud     r6.3<0>:ud       {I@2} // s0&(s1^s2)
        bfn.0x28 (8|M0)          r74.0<1>:ud   r112.0<1;0>:ud    r91.0<1;0>:ud     r6.3<0>:ud       // s0&(s1^s2)
        cmp (8|M0)    (ne)f1.1   null<1>:d     r75.0<1;1,0>:d    0:w               {I@2}
(W)     mov (1|M0)               r6.4<1>:f     -1.4013e-45:f                              
(~f1.1) cmp (8|M0)    (ne)f1.1   null<1>:d     r74.0<1;1,0>:d    0:w               {I@2}
(f1.1)  cmp (8|M0)    (eq)f1.1   null<1>:d     r82.0<1;1,0>:d    -150:w              
(f1.1)  sel (8|M0)               r101.0<1>:f   r6.4<0;1,0>:f     -0.0:f               {F@1}
        goto (8|M0)                          L4128                  L6488                
L4128:
        join (8|M0)                          L6488                                
L4144:
        cmp (8|M0)    (lt)f1.0   null<1>:ud    r39.0<1;1,0>:ud   0x18:uw             
        add3 (8|M0)              r50.0<1>:d    r74.0<1;0>:d      r39.0<1;0>:d      81:w              
(f1.0)  cmp (8|M0)    (eq)f1.0   null<1>:d     r29.0<1;1,0>:d    0:w              
(f1.0)  goto (8|M0)                          L6200                  L6200                
L4208:
        shl (8|M0)               r14.0<1>:d    r24.0<1;1,0>:d    1:w               {Compacted}
        shr (8|M0)               r13.0<1>:ud   r24.0<1;1,0>:ud   31:w              
        shl (8|M0)               r34.0<1>:d    r86.0<1;1,0>:d    1:w               {Compacted}
        cmp (8|M0)    (lt)f1.0   null<1>:ud    r14.0<1;1,0>:ud   0x4E:uw              {I@3}
        or (8|M0)                r34.0<1>:d    r34.0<1;1,0>:d    r13.0<1;1,0>:d   {Compacted,I@2}
(f1.0)  cmp (8|M0)    (eq)f1.0   null<1>:d     r34.0<1;1,0>:d    0:w               {I@1}
(~f1.0) cmp (8|M0)    (lt)f1.0   null<1>:d     r34.0<1;1,0>:d    0:w              
(f1.0)  goto (8|M0)                          L4440                  L4440                
L4312:
        cmp (8|M0)    (eq)f0.1   null<1>:d     r24.0<1;1,0>:d    39:w              
(f0.1)  cmp (8|M0)    (eq)f0.1   null<1>:d     r86.0<1;1,0>:d    0:w              
(~f0.1) goto (8|M0)                          L4440                  L4504                
L4360:
        shr (8|M0)               r94.0<1>:ud   r104.0<1;1,0>:ud  1:w              
        mov (8|M0)               r35.0<1>:d    0:w                              
        mov (8|M0)               r46.0<1>:d    0:w                              
        mov (8|M0)               r44.0<1>:f    r94.0<1;1,0>:f                   {Compacted,I@3}
        mov (8|M0)               r94.0<1>:f    r104.0<1;1,0>:f                  {Compacted}
        goto (8|M0)                          L4440                  L5704                
L4440:
        join (8|M0)                          L4504                                
L4456:
        cmp (8|M0)    (eq)f1.1   null<1>:d     r24.0<1;1,0>:d    38:w               {F@3}
(f1.1)  cmp (8|M0)    (eq)f1.1   null<1>:d     r86.0<1;1,0>:d    0:w              
(f1.1)  goto (8|M0)                          L4504                  L5616                
L4504:
        join (8|M0)                          L5616                                
L4520:
        add (8|M0)               acc0.0<1>:d   -r24.0<1;1,0>:d   39:w               {Compacted}
        add (8|M0)               r36.0<1>:d    -r24.0<1;1,0>:d   40:w               {Compacted}
        and (8|M0)    (ne)f0.1   r29.0<1>:d    acc0.0<1;1,0>:d   63:w              
(f0.1)  goto (8|M0)                          L4600                  L4600                
L4568:
        mov (8|M0)               r31.0<1>:d    r104.0<1;1,0>:d                 
        goto (8|M0)                          L4600                  L4736                
L4600:
        join (8|M0)                          L4736                                
L4616:
        cmp (8|M0)    (lt)f1.1   null<1>:ud    r29.0<1;1,0>:ud   0x20:uw              {I@5}
(f1.1)  add (8|M0)               acc0.0<1>:d   -r29.0<1;1,0>:d   32:w              
(~f1.1) add (8|M0)               acc2.0<1>:d   r29.0<1;1,0>:d    -32:w              
(f1.1)  shr (8|M0)               r71.0<1>:ud   r104.0<1;1,0>:ud  r29.0<1;1,0>:d  
(f1.1)  shl (8|M0)               r113.0<1>:d   r112.0<1;1,0>:d   acc0.0<1;1,0>:d 
(~f1.1) shr (8|M0)               r94.0<1>:ud   r112.0<1;1,0>:ud  acc2.0<1;1,0>:d  {F@1}
(f1.1)  or (8|M0)                r94.0<1>:d    r71.0<1;1,0>:d    r113.0<1;1,0>:d  {I@2}
        mov (8|M0)               r31.0<1>:f    r94.0<1;1,0>:f                   {Compacted,I@1}
L4736:
        join (8|M0)                          L5616                                
L4752:
        add (8|M0)               r13.0<1>:d    -r24.0<1;1,0>:d   38:w               {Compacted}
        and (8|M0)    (ne)f1.0   r33.0<1>:d    r13.0<1;1,0>:d    63:w               {I@1}
(f1.0)  goto (8|M0)                          L4824                  L4824                
L4792:
        mov (8|M0)               r94.0<1>:d    r104.0<1;1,0>:d                  {F@1}
        goto (8|M0)                          L4824                  L4952                
L4824:
        join (8|M0)                          L4952                                
L4840:
        cmp (8|M0)    (lt)f0.1   null<1>:ud    r33.0<1;1,0>:ud   0x20:uw              {I@5}
(f0.1)  add (8|M0)               acc0.0<1>:d   -r33.0<1;1,0>:d   32:w              
(~f0.1) add (8|M0)               acc2.0<1>:d   r33.0<1;1,0>:d    -32:w              
(f0.1)  shr (8|M0)               r69.0<1>:ud   r104.0<1;1,0>:ud  r33.0<1;1,0>:d  
(f0.1)  shl (8|M0)               r120.0<1>:d   r112.0<1;1,0>:d   acc0.0<1;1,0>:d 
(~f0.1) shr (8|M0)               r94.0<1>:ud   r112.0<1;1,0>:ud  acc2.0<1;1,0>:d 
(f0.1)  or (8|M0)                r94.0<1>:d    r69.0<1;1,0>:d    r120.0<1;1,0>:d  {I@2}
L4952:
        join (8|M0)                          L5616                                
L4968:
        and (8|M0)    (ne)f1.1   r119.0<1>:d   r13.0<1;1,0>:d    63:w              
        and (8|M0)               r46.0<1>:d    r94.0<1;1,0>:d    1:w               {Compacted,I@3}
(f1.1)  goto (8|M0)                          L5056                  L5056                
L5008:
        mov (8|M0)               r122.0<1>:d   -1:w                              
        mov (8|M0)               r13.0<1>:d    -1:w                              
        goto (8|M0)                          L5056                  L5240                
L5056:
        join (8|M0)                          L5240                                
L5072:
        cmp (8|M0)    (lt)f1.0   null<1>:ud    r119.0<1;1,0>:ud  0x20:uw              {I@7}
(f1.0)  goto (8|M0)                          L5176                  L5176                
L5104:
        add (8|M0)               acc0.0<1>:d   r119.0<1;1,0>:d   -32:w               {Compacted}
(W)     mov (1|M0)               r6.8<1>:hf    -qnan(0x1FF):hf                             
        mov (8|M0)               r122.0<1>:d   0:w                              
        shl (8|M0)               r13.0<1>:d    r6.8<0;1,0>:w     acc0.0<1;1,0>:d  {F@1}
        goto (8|M0)                          L5176                  L5240                
L5176:
        join (8|M0)                          L5240                                
L5192:
(W)     mov (1|M0)               r6.8<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (8|M0)               r13.0<1>:d    -1:w                              
        shl (8|M0)               r122.0<1>:d   r6.8<0;1,0>:w     r119.0<1;1,0>:d  {F@1}
L5240:
        join (8|M0)                          L5616                                
L5256:
        bfn.0x28 (8|M0)          r68.0<1>:ud   r104.0<1;0>:ud    r122.0<1;0>:ud    r6.3<0>:ud       {I@2} // s0&(s1^s2)
        bfn.0x28 (8|M0)          r67.0<1>:ud   r112.0<1;0>:ud    r13.0<1;0>:ud     r6.3<0>:ud       // s0&(s1^s2)
        cmp (8|M0)    (ne)f1.0   null<1>:d     r68.0<1;1,0>:d    0:w               {I@2}
(W)     mov (1|M0)               r6.8<1>:hf    -qnan(0x1FF):hf                             
        and (8|M0)    (ne)f0.1   r32.0<1>:d    r36.0<1;1,0>:d    63:w              
(~f1.0) cmp (8|M0)    (ne)f1.0   null<1>:d     r67.0<1;1,0>:d    0:w               {I@3}
(f1.0)  sel (8|M0)               acc0.0<1>:d   r6.8<0;1,0>:w     0:w               {F@1}
        mov (8|M0)               r35.0<1>:d    -acc0.0<1;1,0>:d                
(f0.1)  goto (8|M0)                          L5432                  L5432                
L5400:
        mov (8|M0)               r94.0<1>:d    r104.0<1;1,0>:d                 
        goto (8|M0)                          L5432                  L5560                
L5432:
        join (8|M0)                          L5560                                
L5448:
        cmp (8|M0)    (lt)f1.1   null<1>:ud    r32.0<1;1,0>:ud   0x20:uw              {I@7}
(f1.1)  add (8|M0)               acc0.0<1>:d   -r32.0<1;1,0>:d   32:w              
(~f1.1) add (8|M0)               acc2.0<1>:d   r32.0<1;1,0>:d    -32:w              
(f1.1)  shr (8|M0)               r64.0<1>:ud   r104.0<1;1,0>:ud  r32.0<1;1,0>:d  
(f1.1)  shl (8|M0)               r118.0<1>:d   r112.0<1;1,0>:d   acc0.0<1;1,0>:d 
(~f1.1) shr (8|M0)               r94.0<1>:ud   r112.0<1;1,0>:ud  acc2.0<1;1,0>:d 
(f1.1)  or (8|M0)                r94.0<1>:d    r64.0<1;1,0>:d    r118.0<1;1,0>:d  {I@2}
L5560:
        join (8|M0)                          L5616                                
L5576:
        mov (8|M0)               r44.0<1>:f    r94.0<1;1,0>:f                   {Compacted,I@2}
        mov (8|M0)               r94.0<1>:d    r31.0<1;1,0>:d                   {F@1}
        goto (8|M0)                          L5616                  L5704                
L5616:
        join (8|M0)                          L5704                                
L5632:
        shr (8|M0)               r94.0<1>:ud   r104.0<1;1,0>:ud  2:w              
        mov (8|M0)               r35.0<1>:d    0:w                              
        mov (8|M0)               r46.0<1>:d    0:w                              
        mov (8|M0)               r44.0<1>:f    r94.0<1;1,0>:f                   {Compacted,I@3}
        shr (8|M0)               r94.0<1>:ud   r104.0<1;1,0>:ud  1:w               {F@1}
L5704:
        join (8|M0)                          L6200                                
L5720:
        shl (8|M0)               r103.0<1>:d   r94.0<1;1,0>:d    2:w               {Compacted,I@2}
        shl (8|M0)               r63.0<1>:d    r46.0<1;1,0>:d    1:w               {Compacted}
        and (8|M0)               r103.0<1>:d   r103.0<1;1,0>:d   4:w               {Compacted,I@2}
        and (8|M0)               r19.0<1>:d    r44.0<1;1,0>:d    8388607:d              
        bfn.0xFE (8|M0)          r64.0<1>:ud   r103.0<1;0>:ud    r63.0<1;0>:ud     r35.0<1>:ud      {I@2} // s0|s1|s2
        cmp (8|M0)    (eq)f1.0   null<1>:d     r64.0<1;1,0>:d    0:w               {I@1}
(~f1.0) goto (8|M0)                          L5840                  L5840                
L5808:
        mov (8|M0)               r63.0<1>:d    0:w                              
        goto (8|M0)                          L5840                  L6000                
L5840:
        join (8|M0)                          L6000                                
L5856:
        cmp (8|M0)    (gt)f0.1   null<1>:ud    r64.0<1;1,0>:ud   0x4:uw             
(~f0.1) goto (8|M0)                          L5920                  L5920                
L5888:
        mov (8|M0)               r63.0<1>:d    1:w                              
        goto (8|M0)                          L5920                  L6000                
L5920:
        join (8|M0)                          L6000                                
L5936:
        and (8|M0)    (ne)f0.1   null<1>:d     r44.0<1;1,0>:d    1:w              
(W)     mov (1|M0)               r6.8<1>:hf    0x1:hf                             
(f0.1)  cmp (8|M0)    (eq)f0.1   null<1>:d     r64.0<1;1,0>:d    4:w              
(f0.1)  sel (8|M0)               r63.0<1>:d    r6.8<0;1,0>:w     0:w               {F@1}
L6000:
        join (8|M0)                          L6200                                
L6016:
        add (8|M0)               r97.0<1>:d    r19.0<1;1,0>:d    r63.0<1;1,0>:d   {Compacted,I@2}
        add3 (8|M0)              r84.0<1>:d    r74.0<1;0>:d      r39.0<1;0>:d      82:w              
        cmp (8|M0)    (gt)f0.1   null<1>:ud    r97.0<1;1,0>:ud   0x7FFFFF:ud              {I@2}
(f0.1)  sel (8|M0)               r75.0<1>:d    r84.0<1;1,0>:d    r50.0<1;1,0>:d   {I@2}
        cmp (8|M0)    (eq)f1.1   null<1>:d     r75.0<1;1,0>:d    255:w               {I@1}
(~f1.1) goto (8|M0)                          L6128                  L6128                
L6104:
        mov (8|M0)               r101.0<1>:f   -inf:f                               {Compacted}
        goto (8|M0)                          L6128                  L6488                
L6128:
        join (8|M0)                          L6200                                
L6144:
(~f0.1) sel (8|M0)               r83.0<1>:d    r97.0<1;1,0>:d    0:w              
        shl (8|M0)               r62.0<1>:d    r75.0<1;1,0>:d    23:w               {Compacted}
        bfn.0xFE (8|M0)          r101.0<1>:ud  r62.0<1;0>:ud     r83.0<1;0>:ud     r6.1<0>:ud       {A@1} // s0|s1|s2
        goto (8|M0)                          L6200                  L6488                
L6200:
        join (8|M0)                          L6488                                
L6216:
        and (8|M0)    (ne)f1.0   r92.0<1>:d    r39.0<1;1,0>:d    63:w              
(f1.0)  goto (8|M0)                          L6280                  L6280                
L6248:
        mov (8|M0)               r47.0<1>:d    -1:w                              
        goto (8|M0)                          L6280                  L6408                
L6280:
        join (8|M0)                          L6408                                
L6296:
        cmp (8|M0)    (lt)f0.1   null<1>:ud    r92.0<1;1,0>:ud   0x20:uw              {I@5}
(f0.1)  goto (8|M0)                          L6360                  L6360                
L6328:
        mov (8|M0)               r47.0<1>:d    0:w                              
        goto (8|M0)                          L6360                  L6408                
L6360:
        join (8|M0)                          L6408                                
L6376:
(W)     mov (1|M0)               r6.8<1>:hf    -qnan(0x1FF):hf                             
        shl (8|M0)               r47.0<1>:d    r6.8<0;1,0>:w     r92.0<1;1,0>:d   {F@1}
L6408:
        join (8|M0)                          L6488                                
L6424:
        bfn.0x28 (8|M0)          r46.0<1>:ud   r104.0<1;0>:ud    r47.0<1;0>:ud     r6.3<0>:ud       {I@2} // s0&(s1^s2)
        add (8|M0)               acc0.0<1>:d   -r39.0<1;1,0>:d   23:w               {Compacted}
        shl (8|M0)               r60.0<1>:d    r50.0<1;1,0>:d    23:w               {Compacted}
        shl (8|M0)               r46.0<1>:d    r46.0<1;1,0>:d    acc0.0<1;1,0>:d  {I@3}
        bfn.0xFE (8|M0)          r101.0<1>:ud  r60.0<1;0>:ud     r46.0<1;0>:ud     r6.1<0>:ud       {I@1} // s0|s1|s2
L6488:
        join (8|M0)                          L28712                                
L6504:
        shr (8|M0)               r29.0<1>:ud   r101.0<1;1,0>:ud  23:w               {I@2}
        and (8|M0)    (ne)f1.1   r120.0<1>:d   r101.0<1;1,0>:d   8388607:d              
        and (8|M0)               r114.0<1>:d   r29.0<1;1,0>:d    255:w               {Compacted,I@2}
(f1.1)  cmp (8|M0)    (eq)f1.1   null<1>:d     r114.0<1;1,0>:d   255:w               {I@1}
(~f1.1) goto (8|M0)                          L6600                  L6600                
L6576:
        mov (8|M0)               r101.0<1>:f   qnan(0x0):f                               {Compacted}
        goto (8|M0)                          L6600                  L11000                
L6600:
        join (8|M0)                          L11000                                
L6616:
        cmp (8|M0)    (eq)f1.0   null<1>:d     r120.0<1;1,0>:d   0:w              
(f1.0)  cmp (8|M0)    (eq)f1.0   null<1>:d     r114.0<1;1,0>:d   255:w              
(f1.0)  goto (8|M0)                          L11000                  L11000                
L6664:
        or (8|M0)     (eq)f1.1   null<1>:d     r114.0<1;1,0>:d   r120.0<1;1,0>:d 
(~f1.1) goto (8|M0)                          L6728                  L6728                
L6696:
        mov (8|M0)               r101.0<1>:f   0x3EE50000:f                              
        goto (8|M0)                          L6728                  L11000                
L6728:
        join (8|M0)                          L11000                                
L6744:
        cmp (8|M0)    (gt)f1.0   null<1>:d     r101.0<1;1,0>:d   -1:w               {F@1}
        cmp (8|M0)    (gt)f1.1   null<1>:ud    r114.0<1;1,0>:ud  0x7D:uw             
(f1.0)  goto (8|M0)                          L7016                  L7016                
L6792:
(f1.1)  goto (8|M0)                          L6904                  L6904                
L6808:
        mov (8|M0)               r19.0<1>:f    0x3EE50000:f                              
        mov (8|M0)               r125.0<1>:f   r101.0<1;1,0>:f                  {Compacted}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        call (8|M0)              r6.4          L41880                                 {A@1}
L6880:
        mov (8|M0)               r101.0<1>:f   r43.0<1;1,0>:f                   {Compacted,I@5}
        goto (8|M0)                          L6904                  L11000                
L6904:
        join (8|M0)                          L7016                                
L6920:
        mov (8|M0)               r19.0<1>:f    r101.0<1;1,0>:f                  {Compacted,F@1}
        mov (8|M0)               r125.0<1>:f   0x3EE50000:f                              
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        call (8|M0)              r6.4          L41880                                 {A@1}
L6992:
        mov (8|M0)               r101.0<1>:f   r43.0<1;1,0>:f                   {Compacted}
        goto (8|M0)                          L7016                  L11000                
L7016:
        join (8|M0)                          L11000                                
L7032:
(f1.1)  goto (8|M0)                          L9152                  L9152                
L7048:
        cmp (8|M0)    (ne)f1.0   null<1>:d     r114.0<1;1,0>:d   0:w              
        add (8|M0)               r95.0<1>:d    -r114.0<1;1,0>:d  125:w               {Compacted}
(f1.0)  sel (8|M0)               r15.0<1>:d    r95.0<1;1,0>:d    124:w               {I@1}
        cmp (8|M0)    (lt)f0.1   null<1>:d     r15.0<1;1,0>:d    1:w               {I@1}
(f0.1)  goto (8|M0)                          L8240                  L8240                
L7120:
        cmp (8|M0)    (eq)f1.1   null<1>:d     r15.0<1;1,0>:d    1:w              
(f1.1)  goto (8|M0)                          L7824                  L7824                
L7152:
        cmp (8|M0)    (lt)f0.1   null<1>:ud    r15.0<1;1,0>:ud   0x18:uw             
(f0.1)  goto (8|M0)                          L7584                  L7584                
L7184:
        cmp (8|M0)    (ne)f0.1   r91.0<1>:d    r114.0<1;1,0>:d   0:w              
        cmp (8|M0)    (lt)f1.1   null<1>:d     r15.0<1;1,0>:d    25:w              
        mov (8|M0)               r7.0<1>:d     -r91.0<1;1,0>:d                  {I@2}
(f1.1)  goto (8|M0)                          L7392                  L7392                
L7248:
        cmp (8|M0)    (eq)f1.0   null<1>:d     r15.0<1;1,0>:d    25:w              
        cmp (8|M0)    (ne)f0.1   r94.0<1>:d    r120.0<1;1,0>:d   0:w              
        cmp (8|M0)    (ne)f1.1   r59.0<1>:d    r101.0<1;1,0>:d   0:w               {F@1}
(f1.0)  sel (8|M0)               r7.0<1>:d     -r91.0<1;1,0>:d   0:w              
(f1.0)  sel (8|M0)               acc0.0<1>:d   -r94.0<1;1,0>:d   -r59.0<1;1,0>:d  {I@2}
        mov (8|M0)               r112.0<1>:f   r7.0<1;1,0>:f                    {Compacted,I@2}
        shl (8|M0)               r96.0<1>:d    acc0.0<1;1,0>:d   31:w              
        mov (8|M0)               r7.0<1>:d     0:w                               {F@1}
        asr (8|M0)               r74.0<1>:d    r96.0<1;1,0>:d    31:w               {Compacted,I@2}
        goto (8|M0)                          L7392                  L7464                
L7392:
        join (8|M0)                          L7464                                
L7408:
        shr (8|M0)               r58.0<1>:ud   r101.0<1;1,0>:ud  22:w              
        and (8|M0)               r57.0<1>:d    r101.0<1;1,0>:d   4194303:d              
        and (8|M0)               r112.0<1>:d   r58.0<1;1,0>:d    1:w               {Compacted,I@2}
        cmp (8|M0)    (ne)f1.1   r74.0<1>:d    r57.0<1;1,0>:d    0:w               {I@2}
L7464:
        join (8|M0)                          L7584                                
L7480:
        cmp (8|M0)    (ne)f1.0   r56.0<1>:d    r74.0<1;1,0>:d    0:w               {I@2}
(W)     mov (1|M0)               r6.16<2>:b    125:w                              
        mov (8|M0)               r124.0<1>:f   9.275385e-39:f                              
        mov (8|M0)               r81.0<1>:f    r112.0<1;1,0>:f                  {Compacted}
        mov (8|M0)               r13.0<1>:b    r6.16<0;1,0>:b                   {I@1}
        mov (8|M0)               r50.0<1>:d    -r56.0<1;1,0>:d                 
        goto (8|M0)                          L7584                  L8736                
L7584:
        join (8|M0)                          L7824                                
L7600:
        add (8|M0)               acc0.0<1>:d   r15.0<1;1,0>:d    -2:w               {Compacted}
(W)     mov (1|M0)               r6.8<1>:hf    -qnan(0x1FF):hf                              {I@5}
        add (8|M0)               acc2.0<1>:d   r15.0<1;1,0>:d    -1:w               {Compacted}
        add (8|M0)               r64.0<1>:d    -r15.0<1;1,0>:d   23:w               {Compacted}
        shr (8|M0)               r55.0<1>:ud   r120.0<1;1,0>:ud  acc0.0<1;1,0>:d 
        shl (8|M0)               r28.0<1>:d    r6.8<0;1,0>:w     acc0.0<1;1,0>:d  {F@1}
(W)     mov (1|M0)               r6.8<1>:hf    0x1:hf                              {I@1}
        shr (8|M0)               r122.0<1>:ud  r120.0<1;1,0>:ud  r15.0<1;1,0>:d  
        shr (8|M0)               r18.0<1>:ud   r120.0<1;1,0>:ud  acc2.0<1;1,0>:d 
        bfn.0x60 (8|M0)          r127.0<1>:ud  r28.0<1;0>:ud     r6.3<0;0>:ud      r120.0<1>:ud     // (s0^s1)&s2
        shl (8|M0)               r64.0<1>:d    r6.8<0;1,0>:w     r64.0<1;1,0>:d   {F@1}
(~f1.0) mov (8|M0)               r64.0<1>:d    0:w                              
        and (8|M0)               r24.0<1>:d    r55.0<1;1,0>:d    1:w               {Compacted}
        and (8|M0)               r7.0<1>:d     r18.0<1;1,0>:d    1:w               {Compacted,I@5}
        cmp (8|M0)    (ne)f0.1   r90.0<1>:d    r127.0<1;1,0>:d   0:w               {I@5}
        or (8|M0)                r31.0<1>:d    r122.0<1;1,0>:d   r64.0<1;1,0>:d   {Compacted,I@4}
        goto (8|M0)                          L7824                  L7912                
L7824:
        join (8|M0)                          L7912                                
L7840:
        and (8|M0)               r7.0<1>:d     r101.0<1;1,0>:d   1:w               {Compacted}
        shr (8|M0)               r31.0<1>:ud   r120.0<1;1,0>:ud  1:w              
(f1.0)  goto (8|M0)                          L7912                  L8128                
L7880:
        mov (8|M0)               r24.0<1>:d    0:w                              
        mov (8|M0)               r90.0<1>:d    0:w                              
L7912:
        join (8|M0)                          L8128                                
L7928:
        cmp (8|M0)    (ne)f1.1   r111.0<1>:d   r90.0<1;1,0>:d    0:w               {I@2}
        cmp (8|M0)    (gt)f1.0   null<1>:ud    r31.0<1;1,0>:ud   0x1AFFFF:ud             
        add (8|M0)               r124.0<1>:d   r31.0<1;1,0>:d    6619136:d              
        mov (8|M0)               r50.0<1>:d    -r111.0<1;1,0>:d                 {I@3}
(f1.0)  goto (8|M0)                          L8064                  L8064                
L8008:
(W)     mov (1|M0)               r6.16<2>:b    125:w                              
        mov (8|M0)               r81.0<1>:f    r24.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r13.0<1>:b    r6.16<0;1,0>:b                   {I@1}
        goto (8|M0)                          L8064                  L8736                
L8064:
        join (8|M0)                          L8128                                
L8080:
        cmp (8|M0)    (eq)f0.1   null<1>:d     r24.0<1;1,0>:d    1:w              
(~f0.1) sel (8|M0)               r50.0<1>:d    -r111.0<1;1,0>:d  1:w              
        goto (8|M0)                          L8128                  L8176                
L8128:
        join (8|M0)                          L8176                                
L8144:
        add (8|M0)               r124.0<1>:d   r31.0<1;1,0>:d    10813440:d              
        mov (8|M0)               r50.0<1>:d    0:w                              
L8176:
        join (8|M0)                          L8240                                
L8192:
        shr (8|M0)               r54.0<1>:ud   r124.0<1;1,0>:ud  1:w               {I@3}
        and (8|M0)               r110.0<1>:d   r54.0<1;1,0>:d    4194303:d               {I@1}
        goto (8|M0)                          L8240                  L8648                
L8240:
        join (8|M0)                          L8648                                
L8256:
        cmp (8|M0)    (gt)f1.1   null<1>:ud    r120.0<1;1,0>:ud  0x1AFFFF:ud             
        add (8|M0)               r124.0<1>:d   r120.0<1;1,0>:d   6619136:d              
(f1.1)  goto (8|M0)                          L8536                  L8536                
L8304:
(f1.0)  goto (8|M0)                          L8416                  L8416                
L8320:
(W)     mov (1|M0)               r6.16<2>:b    125:w                              
        mov (8|M0)               r7.0<1>:d     0:w                              
        mov (8|M0)               r81.0<1>:d    0:w                               {F@1}
        mov (8|M0)               r50.0<1>:d    0:w                              
        mov (8|M0)               r13.0<1>:b    r6.16<0;1,0>:b                   {I@4}
        goto (8|M0)                          L8416                  L8736                
L8416:
        join (8|M0)                          L8536                                
L8432:
(W)     mov (1|M0)               r6.16<2>:b    126:w                              
        and (8|M0)               r7.0<1>:d     r101.0<1;1,0>:d   1:w               {Compacted}
        shr (8|M0)               r124.0<1>:ud  r124.0<1;1,0>:ud  1:w              
        mov (8|M0)               r81.0<1>:d    0:w                              
        mov (8|M0)               r50.0<1>:d    0:w                              
        mov (8|M0)               r13.0<1>:b    r6.16<0;1,0>:b                   {I@5}
        goto (8|M0)                          L8536                  L8736                
L8536:
        join (8|M0)                          L8648                                
L8552:
        shr (8|M0)               r115.0<1>:ud  r124.0<1;1,0>:ud  1:w               {I@6}
        mov (8|M0)               r50.0<1>:d    0:w                              
        and (8|M0)               r93.0<1>:d    r115.0<1;1,0>:d   4194303:d               {I@2}
        or (8|M0)                r115.0<1>:d   r115.0<1;1,0>:d   4194304:d              
        mov (8|M0)               r7.0<1>:d     0:w                              
(f1.0)  sel (8|M0)               r110.0<1>:d   r115.0<1;1,0>:d   r93.0<1;1,0>:d   {I@2}
L8648:
        join (8|M0)                          L8736                                
L8664:
        and (8|M0)               acc0.0<1>:d   r124.0<1;1,0>:d   1:w               {Compacted}
(W)     mov (1|M0)               r6.16<2>:b    126:w                              
        mov (8|M0)               r81.0<1>:f    r7.0<1;1,0>:f                    {Compacted,I@5}
        mov (8|M0)               r124.0<1>:f   r110.0<1;1,0>:f                  {Compacted,A@2}
        mov (8|M0)               r7.0<1>:d     acc0.0<1;1,0>:d                  {F@2}
        mov (8|M0)               r13.0<1>:b    r6.16<0;1,0>:b                   {I@2}
L8736:
        join (8|M0)                          L9152                                
L8752:
        shl (8|M0)               r106.0<1>:d   r7.0<1;1,0>:d     2:w               {Compacted,I@3}
        shl (8|M0)               r53.0<1>:d    r81.0<1;1,0>:d    1:w               {Compacted}
        bfn.0xFE (8|M0)          r116.0<1>:ud  r106.0<1;0>:ud    r53.0<1;0>:ud     r50.0<1>:ud      {I@1} // s0|s1|s2
        cmp (8|M0)    (eq)f0.1   null<1>:d     r116.0<1;1,0>:d   0:w               {I@1}
(~f0.1) goto (8|M0)                          L8848                  L8848                
L8816:
        mov (8|M0)               r17.0<1>:d    0:w                              
        goto (8|M0)                          L8848                  L9008                
L8848:
        join (8|M0)                          L9008                                
L8864:
        cmp (8|M0)    (gt)f1.1   null<1>:ud    r116.0<1;1,0>:ud  0x4:uw             
(~f1.1) goto (8|M0)                          L8928                  L8928                
L8896:
        mov (8|M0)               r17.0<1>:d    1:w                              
        goto (8|M0)                          L8928                  L9008                
L8928:
        join (8|M0)                          L9008                                
L8944:
        and (8|M0)    (ne)f0.1   null<1>:d     r124.0<1;1,0>:d   1:w               {F@1}
(W)     mov (1|M0)               r6.8<1>:hf    0x1:hf                             
(f0.1)  cmp (8|M0)    (eq)f0.1   null<1>:d     r116.0<1;1,0>:d   4:w              
(f0.1)  sel (8|M0)               r17.0<1>:d    r6.8<0;1,0>:w     0:w               {F@1}
L9008:
        join (8|M0)                          L9152                                
L9024:
        add (8|M0)               r60.0<1>:d    r124.0<1;1,0>:d   r17.0<1;1,0>:d   {Compacted,I@2}
        mov (8|M0)               r59.0<1>:d    r13.0<1;1,0>:ub                 
        cmp (8|M0)    (eq)f1.0   r92.0<1>:d    r60.0<1;1,0>:d    8388608:d               {I@2}
        cmp (8|M0)    (eq)f0.1   null<1>:d     r60.0<1;1,0>:d    8388608:d              
        add3 (8|M0)              acc0.0<1>:d   r59.0<1;0>:d      -r92.0<1;0>:d     0:w               {I@2}
(f0.1)  mov (8|M0)               r60.0<1>:d    0:w                              
        shl (8|M0)               r59.0<1>:d    acc0.0<1;1,0>:d   23:w              
        or (8|M0)                r101.0<1>:d   r59.0<1;1,0>:d    r60.0<1;1,0>:d   {Compacted,I@1}
        goto (8|M0)                          L9152                  L11000                
L9152:
        join (8|M0)                          L11000                                
L9168:
        mov (8|M0)               r13.0<1>:b    r29.0<4;1,0>:b                  
        cmp (8|M0)    (lt)f1.0   null<1>:w     r13.0<1;1,0>:b    126:w               {I@1}
(f1.0)  goto (8|M0)                          L9328                  L9328                
L9216:
        cmp (8|M0)    (eq)f0.1   null<1>:w     r13.0<1;1,0>:b    126:w              
(~f0.1) goto (8|M0)                          L9328                  L9376                
L9248:
        mov (8|M0)               r18.0<1>:d    0:w                              
        mov (8|M0)               r57.0<1>:d    0:w                              
        mov (8|M0)               r69.0<1>:d    0:w                              
        mov (8|M0)               r80.0<1>:f    0x728000:f                              
        goto (8|M0)                          L9328                  L10024                
L9328:
        join (8|M0)                          L9376                                
L9344:
        cmp (8|M0)    (eq)f1.1   null<1>:w     r13.0<1;1,0>:b    125:w              
(f1.1)  goto (8|M0)                          L9376                  L10240                
L9376:
        join (8|M0)                          L10024                                
L9392:
        add (8|M0)               r127.0<1>:d   r114.0<1;1,0>:d   -125:w               {Compacted}
        cmp (8|M0)    (lt)f1.0   null<1>:ud    r127.0<1;1,0>:ud  0x18:uw              {I@1}
(f1.0)  goto (8|M0)                          L9800                  L9800                
L9432:
        cmp (8|M0)    (lt)f0.1   null<1>:w     r13.0<1;1,0>:b    -106:w              
(f0.1)  goto (8|M0)                          L9576                  L9576                
L9464:
        cmp (8|M0)    (eq)f1.1   null<1>:w     r13.0<1;1,0>:b    -106:w              
(~f1.1) goto (8|M0)                          L9576                  L9704                
L9496:
        mov (8|M0)               r18.0<1>:d    0:w                              
        mov (8|M0)               r57.0<1>:d    1:w                              
        mov (8|M0)               r69.0<1>:d    -1:w                              
        mov (8|M0)               r80.0<1>:d    0:w                               {F@1}
        goto (8|M0)                          L9576                  L10024                
L9576:
        join (8|M0)                          L9704                                
L9592:
        cmp (8|M0)    (eq)f1.0   null<1>:w     r13.0<1;1,0>:b    -107:w              
(~f1.0) goto (8|M0)                          L9704                  L9704                
L9624:
        mov (8|M0)               r18.0<1>:d    1:w                              
        mov (8|M0)               r57.0<1>:d    1:w                              
        mov (8|M0)               r69.0<1>:d    -1:w                              
        mov (8|M0)               r80.0<1>:d    0:w                              
        goto (8|M0)                          L9704                  L10024                
L9704:
        join (8|M0)                          L9800                                
L9720:
        mov (8|M0)               r18.0<1>:d    0:w                              
        mov (8|M0)               r57.0<1>:d    0:w                              
        mov (8|M0)               r69.0<1>:d    -1:w                              
        mov (8|M0)               r80.0<1>:d    0:w                              
        goto (8|M0)                          L9800                  L10024                
L9800:
        join (8|M0)                          L10024                                
L9816:
(W)     mov (1|M0)               r6.5<1>:f     9.275385e-39:f                              
        add (8|M0)               acc0.0<1>:d   r114.0<1;1,0>:d   -127:w               {Compacted}
(W)     mov (1|M0)               r6.8<1>:hf    -qnan(0x1FF):hf                             
        add (8|M0)               acc2.0<1>:d   r114.0<1;1,0>:d   -126:w               {Compacted}
        add (8|M0)               r102.0<1>:d   -r114.0<1;1,0>:d  148:w               {Compacted}
        shr (8|M0)               r52.0<1>:ud   r6.5<0;1,0>:ud    acc0.0<1;1,0>:d  {F@2}
        shl (8|M0)               r55.0<1>:d    r6.8<0;1,0>:w     acc0.0<1;1,0>:d  {F@1}
(W)     mov (1|M0)               r6.8<1>:hf    0x1:hf                              {I@1}
        shr (8|M0)               r124.0<1>:ud  r6.5<0;1,0>:ud    r127.0<1;1,0>:d 
        shr (8|M0)               r62.0<1>:ud   r6.5<0;1,0>:ud    acc2.0<1;1,0>:d 
        and (8|M0)               r55.0<1>:d    r55.0<1;1,0>:d    6619136:d              
        shl (8|M0)               r102.0<1>:d   r6.8<0;1,0>:w     r102.0<1;1,0>:d  {F@1}
        and (8|M0)               r57.0<1>:d    r52.0<1;1,0>:d    1:w               {Compacted}
        and (8|M0)               r18.0<1>:d    r62.0<1;1,0>:d    1:w               {Compacted,I@4}
        cmp (8|M0)    (ne)f1.0   r69.0<1>:d    r55.0<1;1,0>:d    6619136:d               {I@4}
        or (8|M0)                r80.0<1>:d    r124.0<1;1,0>:d   r102.0<1;1,0>:d  {Compacted,I@4}
L10024:
        join (8|M0)                          L10240                                
L10040:
        add (8|M0)               r126.0<1>:d   r120.0<1;1,0>:d   r80.0<1;1,0>:d   {Compacted,I@2}
        cmp (8|M0)    (ne)f0.1   r115.0<1>:d   r69.0<1;1,0>:d    0:w              
        cmp (8|M0)    (gt)f0.1   null<1>:ud    r126.0<1;1,0>:ud  0x7FFFFF:ud              {I@2}
        mov (8|M0)               r42.0<1>:d    -r115.0<1;1,0>:d                 {I@2}
(f0.1)  goto (8|M0)                          L10144                  L10144                
L10112:
        mov (8|M0)               r90.0<1>:d    r57.0<1;1,0>:d                  
        goto (8|M0)                          L10144                  L10528                
L10144:
        join (8|M0)                          L10240                                
L10160:
        cmp (8|M0)    (eq)f1.1   null<1>:d     r57.0<1;1,0>:d    1:w              
        shr (8|M0)               r51.0<1>:ud   r126.0<1;1,0>:ud  1:w              
        and (8|M0)               r102.0<1>:d   r51.0<1;1,0>:d    4194303:d               {I@1}
(~f1.1) sel (8|M0)               r42.0<1>:d    -r115.0<1;1,0>:d  1:w              
        goto (8|M0)                          L10240                  L10464                
L10240:
        join (8|M0)                          L10464                                
L10256:
        cmp (8|M0)    (gt)f1.0   null<1>:ud    r120.0<1;1,0>:ud  0x1AFFFF:ud             
        add (8|M0)               r126.0<1>:d   r120.0<1;1,0>:d   6619136:d              
(f1.0)  goto (8|M0)                          L10384                  L10384                
L10304:
        and (8|M0)               r18.0<1>:d    r101.0<1;1,0>:d   1:w               {Compacted}
        shr (8|M0)               r126.0<1>:ud  r126.0<1;1,0>:ud  1:w               {I@3}
        add (8|M0)               r114.0<1>:d   r114.0<1;1,0>:d   1:w               {Compacted}
        mov (8|M0)               r90.0<1>:d    0:w                              
        mov (8|M0)               r42.0<1>:d    0:w                              
        goto (8|M0)                          L10384                  L10528                
L10384:
        join (8|M0)                          L10464                                
L10400:
        shr (8|M0)               r50.0<1>:ud   r126.0<1;1,0>:ud  1:w               {I@6}
        mov (8|M0)               r42.0<1>:d    0:w                              
        mov (8|M0)               r18.0<1>:d    0:w                              
        or (8|M0)                r102.0<1>:d   r50.0<1;1,0>:d    4194304:d               {I@3}
L10464:
        join (8|M0)                          L10528                                
L10480:
        and (8|M0)               acc0.0<1>:d   r126.0<1;1,0>:d   1:w               {Compacted}
        add (8|M0)               r114.0<1>:d   r114.0<1;1,0>:d   1:w               {Compacted}
        mov (8|M0)               r90.0<1>:f    r18.0<1;1,0>:f                   {Compacted,I@5}
        mov (8|M0)               r126.0<1>:f   r102.0<1;1,0>:f                  {Compacted,A@2}
        mov (8|M0)               r18.0<1>:d    acc0.0<1;1,0>:d                  {F@2}
L10528:
        join (8|M0)                          L11000                                
L10544:
        shl (8|M0)               r115.0<1>:d   r18.0<1;1,0>:d    2:w               {Compacted,I@2}
        shl (8|M0)               r49.0<1>:d    r90.0<1;1,0>:d    1:w               {Compacted}
        bfn.0xFE (8|M0)          r16.0<1>:ud   r115.0<1;0>:ud    r49.0<1;0>:ud     r42.0<1>:ud      {I@1} // s0|s1|s2
        cmp (8|M0)    (eq)f0.1   null<1>:d     r16.0<1;1,0>:d    0:w               {I@1}
(~f0.1) goto (8|M0)                          L10640                  L10640                
L10608:
        mov (8|M0)               r45.0<1>:d    0:w                              
        goto (8|M0)                          L10640                  L10800                
L10640:
        join (8|M0)                          L10800                                
L10656:
        cmp (8|M0)    (gt)f1.1   null<1>:ud    r16.0<1;1,0>:ud   0x4:uw             
(~f1.1) goto (8|M0)                          L10720                  L10720                
L10688:
        mov (8|M0)               r45.0<1>:d    1:w                              
        goto (8|M0)                          L10720                  L10800                
L10720:
        join (8|M0)                          L10800                                
L10736:
        and (8|M0)    (ne)f1.1   null<1>:d     r126.0<1;1,0>:d   1:w               {F@1}
(W)     mov (1|M0)               r6.8<1>:hf    0x1:hf                             
(f1.1)  cmp (8|M0)    (eq)f1.1   null<1>:d     r16.0<1;1,0>:d    4:w              
(f1.1)  sel (8|M0)               r45.0<1>:d    r6.8<0;1,0>:w     0:w               {F@1}
L10800:
        join (8|M0)                          L11000                                
L10816:
        add (8|M0)               r44.0<1>:d    r126.0<1;1,0>:d   r45.0<1;1,0>:d   {Compacted,I@2}
        cmp (8|M0)    (eq)f0.1   r48.0<1>:d    r44.0<1;1,0>:d    8388608:d               {I@1}
        cmp (8|M0)    (eq)f1.1   null<1>:d     r44.0<1;1,0>:d    8388608:d              
        add3 (8|M0)              r89.0<1>:d    r114.0<1;0>:d     -r48.0<1;0>:d     0:w               {I@2}
        cmp (8|M0)    (eq)f1.0   null<1>:d     r89.0<1;1,0>:d    255:w               {I@1}
(~f1.0) goto (8|M0)                          L10928                  L10928                
L10904:
        mov (8|M0)               r101.0<1>:f   inf:f                               {Compacted}
        goto (8|M0)                          L10928                  L11000                
L10928:
        join (8|M0)                          L11000                                
L10944:
(~f1.1) sel (8|M0)               r97.0<1>:d    r44.0<1;1,0>:d    0:w              
        and (8|M0)               r91.0<1>:d    r101.0<1;1,0>:d   -2147483648:d               {F@1}
        shl (8|M0)               r47.0<1>:d    r89.0<1;1,0>:d    23:w               {Compacted}
        bfn.0xFE (8|M0)          r101.0<1>:ud  r91.0<1;0>:ud     r47.0<1;0>:ud     r97.0<1>:ud      {I@1} // s0|s1|s2
L11000:
        join (8|M0)                          L28712                                
L11016:
        mov (8|M0)               r13.0<1>:hf   r101.0<1;1,0>:f                  {I@2}
(W)     mov (1|M0)               r6.8<1>:hf    0x1:hf                             
        mov (8|M0)               r78.0<1>:f    r13.0<1;1,0>:hf                  {F@2}
(f0.0)  sel (8|M0)               r13.0<1>:uw   r6.8<0;1,0>:uw    0x0:uw              {A@1}
        shr (8|M0)               r15.0<1>:ud   r78.0<1;1,0>:ud   23:w              
        and (8|M0)    (ne)f1.0   r30.0<1>:d    r78.0<1;1,0>:d    8388607:d              
        and (8|M0)               r77.0<1>:d    r15.0<1;1,0>:d    255:w               {Compacted,I@2}
(f1.0)  cmp (8|M0)    (eq)f1.0   null<1>:d     r77.0<1;1,0>:d    255:w               {I@1}
(f1.0)  sel (8|M0)               r14.0<1>:uw   r6.8<0;1,0>:uw    0x0:uw             
        or (8|M0)     (ne)f0.1   null<1>:uw    r14.0<1;1,0>:uw   r13.0<1;1,0>:uw  {I@1}
(~f0.1) goto (8|M0)                          L11208                  L11208                
L11184:
        mov (8|M0)               r98.0<1>:f    qnan(0x0):f                               {Compacted}
        goto (8|M0)                          L11208                  L17584                
L11208:
        join (8|M0)                          L17584                                
L11224:
        cmp (8|M0)    (eq)f0.1   null<1>:d     r30.0<1;1,0>:d    0:w              
        cmp (8|M0)    (eq)f1.1   null<1>:d     r9.0<1;1,0>:d     0:w              
(W)     mov (1|M0)               r6.8<1>:hf    0x1:hf                             
        xor (8|M0)               r14.0<1>:d    r78.0<1;1,0>:d    r12.0<1;1,0>:d   {Compacted}
(f0.1)  cmp (8|M0)    (eq)f0.1   null<1>:d     r77.0<1;1,0>:d    255:w              
(f1.1)  cmp (8|M0)    (eq)f1.1   null<1>:d     r10.0<1;1,0>:d    255:w              
(f0.1)  sel (8|M0)               r13.0<1>:uw   r6.8<0;1,0>:uw    0x0:uw              {F@1}
(f1.1)  sel (8|M0)               r12.0<1>:uw   r6.8<0;1,0>:uw    0x0:uw             
        or (8|M0)     (ne)f1.1   null<1>:uw    r13.0<1;1,0>:uw   r12.0<1;1,0>:uw  {I@1}
(f1.1)  goto (8|M0)                          L17552                  L17552                
L11376:
        or (8|M0)     (eq)f0.1   null<1>:d     r10.0<1;1,0>:d    r9.0<1;1,0>:d   
        or (8|M0)                r46.0<1>:d    r77.0<1;1,0>:d    r30.0<1;1,0>:d   {Compacted}
(~f0.1) cmp (8|M0)    (eq)f0.1   null<1>:d     r46.0<1;1,0>:d    0:w               {I@1}
(~f0.1) goto (8|M0)                          L11456                  L11456                
L11432:
        mov (8|M0)               r98.0<1>:f    0.0:f                               {Compacted}
        goto (8|M0)                          L11456                  L17584                
L11456:
        join (8|M0)                          L17552                                
L11472:
        cmp (8|M0)    (eq)f0.1   null<1>:d     r77.0<1;1,0>:d    0:w              
        cmp (8|M0)    (eq)f1.1   null<1>:d     r10.0<1;1,0>:d    0:w              
        add (8|M0)               r52.0<1>:d    r77.0<1;1,0>:d    -127:w               {Compacted}
        add (8|M0)               r50.0<1>:d    r10.0<1;1,0>:d    -127:w               {Compacted}
(f0.1)  mov (8|M0)               r52.0<1>:d    -126:w                              
(f1.1)  mov (8|M0)               r50.0<1>:d    -126:w                              
        add (8|M0)               r51.0<1>:d    r52.0<1;1,0>:d    r50.0<1;1,0>:d   {Compacted,I@1}
        cmp (8|M0)    (gt)f1.0   null<1>:d     r51.0<1;1,0>:d    127:w               {I@1}
(f1.0)  goto (8|M0)                          L17480                  L17480                
L11592:
        or (8|M0)     (eq)f1.0   null<4>:b     r15.0<1;1,0>:d    r11.0<1;1,0>:d  
(f1.0)  goto (8|M0)                          L17408                  L17408                
L11624:
(W)     mov (1|M0)               r6.8<1>:hf    0.0:hf                             
(f0.1)  sel (8|M0)               acc0.0<1>:d   r6.8<0;1,0>:w     8388608:d               {F@1}
(f1.1)  sel (8|M0)               acc2.0<1>:d   r6.8<0;1,0>:w     8388608:d              
        or (8|M0)                r122.0<1>:d   acc0.0<1;1,0>:d   r30.0<1;1,0>:d  
        or (8|M0)                r114.0<1>:d   acc2.0<1;1,0>:d   r9.0<1;1,0>:d   
(W)     mov (2|M0)               r6.4<1>:d     0:w                              
        mul (8|M0)               acc0.0<1>:ud  r122.0<1;1,0>:ud  r114.0<2;1,0>:uw {I@2}
        mach (8|M0)              r85.0<1>:ud   r122.0<1;1,0>:ud  r114.0<1;1,0>:ud {AccWrEn,Compacted}
(W)     mov (1|M0)               r9.5<1>:d     0:w                              
        mov (8|M0)               acc0.0<1>:ud  acc0.0<1;1,0>:ud                
(W)     mov (1|M0)               r9.4<1>:f     -0.0:f                               {Compacted}
        mov (8|M0)               r111.0<1>:f   r85.0<1;1,0>:f                   {Compacted,I@3}
        mov (8|M0)               r100.0<1>:ud  acc0.0<1;1,0>:ud                 {Compacted}
L11800:
(W)     shl (1|M0)               r9.2<1>:d     r9.4<0;1,0>:d     31:w               {F@2}
(W)     shr (1|M0)               r9.1<1>:ud    r9.5<0;1,0>:ud    1:w               {I@4}
(W)     cmp (8|M0)    (gt)f1.0   null<1>:ud    r6.4<0;1,0>:ud    0x3E:uw             
(W)     or (1|M0)                r9.5<1>:d     r9.1<0;1,0>:d     r9.2<0;1,0>:d    {I@2}
        bfn.0xA8 (8|M0)          r34.0<1>:ud   r100.0<1;0>:ud    r9.1<0;0>:ud      r9.2<0>:ud       // s0&(s1|s2)
(W)     shr (1|M0)               r6.7<1>:ud    r9.4<0;1,0>:ud    1:w              
(W&f1.0) cmp (8|M0)   (eq)f1.0   null<1>:d     r6.5<0;1,0>:d     0:w              
        cmp (8|M0)    (eq)f0.1   null<1>:d     r34.0<1;1,0>:d    r9.5<0;1,0>:d    {I@3}
(W)     addc (1|M0)              r11.0<1>:ud   r6.4<0;1,0>:ud    0x1:ud              {AccWrEn}
        and (8|M0)               r33.0<1>:d    r111.0<1;1,0>:d   r6.7<0;1,0>:d    {Compacted,A@1}
(W)     mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
(W&~f1.0) cmp (8|M0)  (gt)f1.0   null<1>:ud    r6.5<0;1,0>:ud    0x0:uw             
(f0.1)  cmp (8|M0)    (eq)f0.1   null<1>:d     r33.0<1;1,0>:d    r6.7<0;1,0>:d    {I@3}
(W)     add (1|M0)               r9.6<1>:ud    r9.0<0;1,0>:ud    r6.5<0;1,0>:ud   {I@3}
(W)     mov (1|M0)               r9.0<1>:hf    0x1:hf                              {I@1}
        mov (8|M0)               r119.0<1>:d   r6.4<0;1,0>:d                   
(f1.0)  sel (8|M0)               r10.0<1>:uw   r9.0<0;1,0>:uw    0x0:uw              {F@1}
(f0.1)  sel (8|M0)               r9.0<1>:uw    r9.0<0;1,0>:uw    0x0:uw             
        mov (8|M0)               r126.0<1>:d   r6.5<0;1,0>:d                   
        or (8|M0)     (ne)f1.0   null<1>:uw    r10.0<1;1,0>:uw   r9.0<1;1,0>:uw   {I@2}
        mov (8|M0)               r23.0<1>:f    r11.0<0;1,0>:f                   {Compacted}
        mov (8|M0)               r83.0<1>:d    r9.6<0;1,0>:d                   
(f1.0)  goto (8|M0)                          L12208                  L12208                
L12144:
(W)     mov (1|M0)               r9.4<1>:d     r6.7<0;1,0>:d                   
(W)     mov (1|M0)               r6.4<1>:d     r11.0<0;1,0>:d                  
(W)     mov (1|M0)               r6.5<1>:d     r9.6<0;1,0>:d                   
(W)     jmpi                                 L11800                                
L12208:
        join (8|M0)                          L17408                                
L12224:
(W)     mov (1|M0)               r6.4<1>:f     8.68805e-44:f                               {I@4}
(W)     mov (1|M0)               r9.0<1>:hf    0.0:hf                             
        subb (8|M0)              r48.0<1>:ud   r6.4<0;1,0>:ud    r119.0<1;1,0>:ud {AccWrEn,Compacted,F@2}
        add3 (8|M0)              r62.0<1>:d    r51.0<1;0>:d      r48.0<1;0>:d      -46:w               {I@1}
        add3 (8|M0)              r28.0<1>:ud   -acc0.0<1;0>:ud   r9.0<0;0>:uw      -r126.0<1>:ud    {F@1}
        cmp (8|M0)    (gt)f0.1   null<1>:d     r62.0<1;1,0>:d    127:w               {I@2}
        add3 (8|M0)              r11.0<1>:d    r52.0<1;0>:d      r50.0<1;0>:d      r48.0<1>:d      
(f0.1)  goto (8|M0)                          L17336                  L17336                
L12344:
        cmp (8|M0)    (gt)f1.1   null<1>:d     r62.0<1;1,0>:d    -127:w              
(f1.1)  goto (8|M0)                          L14904                  L14904                
L12376:
        cmp (8|M0)    (lt)f1.0   null<1>:ud    r62.0<1;1,0>:ud   0xFFFFFF6B:ud             
(f1.0)  goto (8|M0)                          L14384                  L14384                
L12408:
(W)     mov (1|M0)               r6.4<1>:f     8.82818e-44:f                              
        add3 (8|M0)              r21.0<1>:d    r51.0<1;0>:d      r48.0<1;0>:d      104:w              
        subb (8|M0)              r76.0<1>:ud   r6.4<0;1,0>:ud    r119.0<1;1,0>:ud {AccWrEn,Compacted,F@1}
(W)     mov (1|M0)               r9.0<1>:hf    0.0:hf                              {I@7}
        cmp (8|M0)    (gt)f0.1   null<1>:ud    r76.0<1;1,0>:ud   r21.0<1;1,0>:ud  {I@1}
        add3 (8|M0)              r73.0<1>:ud   -acc0.0<1;0>:ud   r9.0<0;0>:uw      -r126.0<1>:ud    {F@1}
(f0.1)  cmp (8|M0)    (eq)f0.1   null<1>:d     r73.0<1;1,0>:d    0:w               {I@1}
(~f0.1) cmp (8|M0)    (gt)f0.1   null<1>:ud    r73.0<1;1,0>:ud   0x0:uw             
(f0.1)  goto (8|M0)                          L12608                  L12608                
L12544:
        add3 (8|M0)              acc0.0<1>:d   r11.0<1;0>:d      -r76.0<1;0>:d     104:w              
        mov (8|M0)               r87.0<1>:d    0:w                              
        shl (8|M0)               r88.0<1>:d    r100.0<1;1,0>:d   acc0.0<1;1,0>:d 
        goto (8|M0)                          L12608                  L14320                
L12608:
        join (8|M0)                          L14320                                
L12624:
        add3 (8|M0)              r102.0<1>:d   r76.0<1;0>:d      -r11.0<1;0>:d     -104:w              
        cmp (8|M0)    (lt)f0.1   null<1>:d     r102.0<1;1,0>:d   2:w               {I@1}
(f0.1)  goto (8|M0)                          L12768                  L12768                
L12672:
        cmp (8|M0)    (eq)f1.1   null<1>:d     r102.0<1;1,0>:d   2:w              
(~f1.1) goto (8|M0)                          L12768                  L12872                
L12704:
        shr (8|M0)               r93.0<1>:ud   r100.0<1;1,0>:ud  1:w              
        and (8|M0)               r34.0<1>:d    r100.0<1;1,0>:d   1:w               {Compacted}
        mov (8|M0)               r18.0<1>:d    0:w                              
        mov (8|M0)               r117.0<1>:f   r93.0<1;1,0>:f                   {Compacted,I@3}
        goto (8|M0)                          L12768                  L13752                
L12768:
        join (8|M0)                          L12872                                
L12784:
        cmp (8|M0)    (eq)f1.0   null<1>:d     r102.0<1;1,0>:d   1:w              
(~f1.0) goto (8|M0)                          L12872                  L12872                
L12816:
        mov (8|M0)               r18.0<1>:d    0:w                              
        mov (8|M0)               r34.0<1>:d    0:w                              
        mov (8|M0)               r117.0<1>:f   r100.0<1;1,0>:f                  {Compacted}
        goto (8|M0)                          L12872                  L13752                
L12872:
        join (8|M0)                          L13752                                
L12888:
        add3 (8|M0)              acc0.0<1>:d   r76.0<1;0>:d      -r21.0<1;0>:d     -1:w              
        and (8|M0)    (ne)f0.1   r113.0<1>:d   acc0.0<1;1,0>:d   63:w              
(f0.1)  goto (8|M0)                          L12968                  L12968                
L12936:
        mov (8|M0)               r22.0<1>:d    r100.0<1;1,0>:d                 
        goto (8|M0)                          L12968                  L13104                
L12968:
        join (8|M0)                          L13104                                
L12984:
        cmp (8|M0)    (lt)f1.1   null<1>:ud    r113.0<1;1,0>:ud  0x20:uw              {I@5}
(~f1.1) add (8|M0)               acc0.0<1>:d   r113.0<1;1,0>:d   -32:w              
(f1.1)  shr (8|M0)               r42.0<1>:ud   r100.0<1;1,0>:ud  r113.0<1;1,0>:d 
(~f1.1) shr (8|M0)               r93.0<1>:ud   r111.0<1;1,0>:ud  acc0.0<1;1,0>:d  {F@2}
(f1.1)  add (8|M0)               acc0.0<1>:d   -r113.0<1;1,0>:d  32:w              
(f1.1)  shl (8|M0)               r43.0<1>:d    r111.0<1;1,0>:d   acc0.0<1;1,0>:d 
(f1.1)  or (8|M0)                r93.0<1>:d    r42.0<1;1,0>:d    r43.0<1;1,0>:d   {I@1}
        mov (8|M0)               r22.0<1>:f    r93.0<1;1,0>:f                   {Compacted,I@1}
L13104:
        join (8|M0)                          L13752                                
L13120:
        add3 (8|M0)              r109.0<1>:d   r76.0<1;0>:d      -r21.0<1;0>:d     -2:w              
        and (8|M0)    (ne)f1.0   r112.0<1>:d   r109.0<1;1,0>:d   63:w               {I@1}
(f1.0)  goto (8|M0)                          L13200                  L13200                
L13168:
        mov (8|M0)               r93.0<1>:d    r100.0<1;1,0>:d                  {F@1}
        goto (8|M0)                          L13200                  L13328                
L13200:
        join (8|M0)                          L13328                                
L13216:
        cmp (8|M0)    (lt)f0.1   null<1>:ud    r112.0<1;1,0>:ud  0x20:uw              {I@5}
(~f0.1) add (8|M0)               acc0.0<1>:d   r112.0<1;1,0>:d   -32:w              
(f0.1)  shr (8|M0)               r40.0<1>:ud   r100.0<1;1,0>:ud  r112.0<1;1,0>:d 
(~f0.1) shr (8|M0)               r93.0<1>:ud   r111.0<1;1,0>:ud  acc0.0<1;1,0>:d 
(f0.1)  add (8|M0)               acc0.0<1>:d   -r112.0<1;1,0>:d  32:w              
(f0.1)  shl (8|M0)               r41.0<1>:d    r111.0<1;1,0>:d   acc0.0<1;1,0>:d 
(f0.1)  or (8|M0)                r93.0<1>:d    r40.0<1;1,0>:d    r41.0<1;1,0>:d   {I@1}
L13328:
        join (8|M0)                          L13752                                
L13344:
        and (8|M0)    (ne)f1.1   r40.0<1>:d    r109.0<1;1,0>:d   63:w              
        and (8|M0)               r34.0<1>:d    r93.0<1;1,0>:d    1:w               {Compacted,I@3}
(f1.1)  goto (8|M0)                          L13432                  L13432                
L13384:
        mov (8|M0)               r61.0<1>:d    -1:w                              
        mov (8|M0)               r77.0<1>:d    -1:w                              
        goto (8|M0)                          L13432                  L13616                
L13432:
        join (8|M0)                          L13616                                
L13448:
        cmp (8|M0)    (lt)f1.0   null<1>:ud    r40.0<1;1,0>:ud   0x20:uw              {I@7}
(f1.0)  goto (8|M0)                          L13552                  L13552                
L13480:
        add (8|M0)               acc0.0<1>:d   r40.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r6.8<1>:hf    -qnan(0x1FF):hf                             
        mov (8|M0)               r61.0<1>:d    0:w                              
        shl (8|M0)               r77.0<1>:d    r6.8<0;1,0>:w     acc0.0<1;1,0>:d  {F@1}
        goto (8|M0)                          L13552                  L13616                
L13552:
        join (8|M0)                          L13616                                
L13568:
(W)     mov (1|M0)               r6.8<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (8|M0)               r77.0<1>:d    -1:w                              
        shl (8|M0)               r61.0<1>:d    r6.8<0;1,0>:w     r40.0<1;1,0>:d   {F@1}
L13616:
        join (8|M0)                          L13752                                
L13632:
        bfn.0x28 (8|M0)          r39.0<1>:ud   r100.0<1;0>:ud    r61.0<1;0>:ud     r6.3<0>:ud       {I@2} // s0&(s1^s2)
        bfn.0x28 (8|M0)          r38.0<1>:ud   r111.0<1;0>:ud    r77.0<1;0>:ud     r6.3<0>:ud       // s0&(s1^s2)
        cmp (8|M0)    (ne)f1.1   null<1>:d     r39.0<1;1,0>:d    0:w               {I@2}
(W)     mov (1|M0)               r6.8<1>:hf    -qnan(0x1FF):hf                             
        mov (8|M0)               r117.0<1>:f   r22.0<1;1,0>:f                   {Compacted}
(~f1.1) cmp (8|M0)    (ne)f1.1   null<1>:d     r38.0<1;1,0>:d    0:w               {I@2}
(f1.1)  sel (8|M0)               acc0.0<1>:d   r6.8<0;1,0>:w     0:w               {F@2}
        mov (8|M0)               r18.0<1>:d    -acc0.0<1;1,0>:d                
L13752:
        join (8|M0)                          L14320                                
L13768:
        and (8|M0)    (ne)f0.1   r110.0<1>:d   r102.0<1;1,0>:d   63:w              
(f0.1)  goto (8|M0)                          L13832                  L13832                
L13800:
        mov (8|M0)               r93.0<1>:d    r100.0<1;1,0>:d                 
        goto (8|M0)                          L13832                  L13960                
L13832:
        join (8|M0)                          L13960                                
L13848:
        cmp (8|M0)    (lt)f1.1   null<1>:ud    r110.0<1;1,0>:ud  0x20:uw              {I@5}
(f1.1)  add (8|M0)               acc0.0<1>:d   -r110.0<1;1,0>:d  32:w              
(~f1.1) add (8|M0)               acc2.0<1>:d   r110.0<1;1,0>:d   -32:w              
(f1.1)  shr (8|M0)               r35.0<1>:ud   r100.0<1;1,0>:ud  r110.0<1;1,0>:d 
(f1.1)  shl (8|M0)               r39.0<1>:d    r111.0<1;1,0>:d   acc0.0<1;1,0>:d 
(~f1.1) shr (8|M0)               r93.0<1>:ud   r111.0<1;1,0>:ud  acc2.0<1;1,0>:d 
(f1.1)  or (8|M0)                r93.0<1>:d    r35.0<1;1,0>:d    r39.0<1;1,0>:d   {I@2}
L13960:
        join (8|M0)                          L14320                                
L13976:
        shl (8|M0)               r95.0<1>:d    r117.0<1;1,0>:d   2:w               {Compacted,F@1}
        shl (8|M0)               r34.0<1>:d    r34.0<1;1,0>:d    1:w               {Compacted}
        and (8|M0)               r95.0<1>:d    r95.0<1;1,0>:d    4:w               {Compacted,I@2}
        bfn.0xFE (8|M0)          r52.0<1>:ud   r95.0<1;0>:ud     r34.0<1;0>:ud     r18.0<1>:ud      {I@1} // s0|s1|s2
        cmp (8|M0)    (eq)f1.0   null<1>:d     r52.0<1;1,0>:d    0:w               {I@1}
(~f1.0) goto (8|M0)                          L14080                  L14080                
L14048:
        mov (8|M0)               r58.0<1>:d    0:w                              
        goto (8|M0)                          L14080                  L14240                
L14080:
        join (8|M0)                          L14240                                
L14096:
        cmp (8|M0)    (gt)f0.1   null<1>:ud    r52.0<1;1,0>:ud   0x4:uw             
(~f0.1) goto (8|M0)                          L14160                  L14160                
L14128:
        mov (8|M0)               r58.0<1>:d    1:w                              
        goto (8|M0)                          L14160                  L14240                
L14160:
        join (8|M0)                          L14240                                
L14176:
        and (8|M0)    (ne)f1.0   null<1>:d     r93.0<1;1,0>:d    1:w              
(W)     mov (1|M0)               r6.8<1>:hf    0x1:hf                             
(f1.0)  cmp (8|M0)    (eq)f1.0   null<1>:d     r52.0<1;1,0>:d    4:w              
(f1.0)  sel (8|M0)               r58.0<1>:d    r6.8<0;1,0>:w     0:w               {F@1}
L14240:
        join (8|M0)                          L14320                                
L14256:
        add (8|M0)               r45.0<1>:d    r58.0<1;1,0>:d    r93.0<1;1,0>:d   {Compacted,I@2}
(W)     mov (1|M0)               r6.4<1>:f     0x800000:f                               {Compacted}
        cmp (8|M0)    (gt)f0.1   null<1>:ud    r45.0<1;1,0>:ud   0x7FFFFF:ud              {I@1}
(~f0.1) sel (8|M0)               r88.0<1>:d    r45.0<1;1,0>:d    0:w              
(f0.1)  sel (8|M0)               r87.0<1>:d    r6.4<0;1,0>:d     0:w               {F@1}
L14320:
        join (8|M0)                          L14384                                
L14336:
        and (8|M0)               r33.0<1>:d    r14.0<1;1,0>:d    -2147483648:d              
        bfn.0xFE (8|M0)          r98.0<1>:ud   r33.0<1;0>:ud     r87.0<1;0>:ud     r88.0<1>:ud      {I@1} // s0|s1|s2
        goto (8|M0)                          L14384                  L17584                
L14384:
        join (8|M0)                          L14904                                
L14400:
        and (8|M0)    (ne)f1.1   r115.0<1>:d   r48.0<1;1,0>:d    63:w              
(f1.1)  goto (8|M0)                          L14480                  L14480                
L14432:
        mov (8|M0)               r15.0<1>:d    -1:w                              
        mov (8|M0)               r38.0<1>:d    -1:w                              
        goto (8|M0)                          L14480                  L14664                
L14480:
        join (8|M0)                          L14664                                
L14496:
        cmp (8|M0)    (lt)f1.0   null<1>:ud    r115.0<1;1,0>:ud  0x20:uw              {I@6}
(f1.0)  goto (8|M0)                          L14600                  L14600                
L14528:
        add (8|M0)               acc0.0<1>:d   r115.0<1;1,0>:d   -32:w               {Compacted}
(W)     mov (1|M0)               r6.8<1>:hf    -qnan(0x1FF):hf                             
        mov (8|M0)               r15.0<1>:d    0:w                              
        shl (8|M0)               r38.0<1>:d    r6.8<0;1,0>:w     acc0.0<1;1,0>:d  {F@1}
        goto (8|M0)                          L14600                  L14664                
L14600:
        join (8|M0)                          L14664                                
L14616:
(W)     mov (1|M0)               r6.8<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (8|M0)               r38.0<1>:d    -1:w                              
        shl (8|M0)               r15.0<1>:d    r6.8<0;1,0>:w     r115.0<1;1,0>:d  {F@1}
L14664:
        join (8|M0)                          L14904                                
L14680:
        bfn.0x28 (8|M0)          r32.0<1>:ud   r100.0<1;0>:ud    r15.0<1;0>:ud     r6.3<0>:ud       {I@2} // s0&(s1^s2)
        bfn.0x28 (8|M0)          r31.0<1>:ud   r111.0<1;0>:ud    r38.0<1;0>:ud     r6.3<0>:ud       // s0&(s1^s2)
        cmp (8|M0)    (ne)f1.0   null<1>:d     r32.0<1;1,0>:d    0:w               {I@2}
        cmp (8|M0)    (gt)f0.1   null<1>:d     r14.0<1;1,0>:d    -1:w              
(~f1.0) cmp (8|M0)    (ne)f1.0   null<1>:d     r31.0<1;1,0>:d    0:w               {I@3}
(f1.0)  cmp (8|M0)    (eq)f1.0   null<1>:d     r62.0<1;1,0>:d    -150:w              
(f0.1)  goto (8|M0)                          L14840                  L14840                
L14792:
(W)     mov (1|M0)               r6.4<1>:ud    0x80000001:ud                             
(f1.0)  sel (8|M0)               r98.0<1>:f    r6.4<0;1,0>:f     -0.0:f               {I@1}
        goto (8|M0)                          L14840                  L17584                
L14840:
        join (8|M0)                          L14904                                
L14856:
(W)     mov (1|M0)               r6.4<1>:ud    0x1:ud                              {F@1}
(f1.0)  sel (8|M0)               r98.0<1>:f    r6.4<0;1,0>:f     0.0:f               {I@1}
        goto (8|M0)                          L14904                  L17584                
L14904:
        join (8|M0)                          L17336                                
L14920:
        cmp (8|M0)    (lt)f0.1   null<1>:ud    r48.0<1;1,0>:ud   0x18:uw             
        add3 (8|M0)              r49.0<1>:d    r51.0<1;0>:d      r48.0<1;0>:d      81:w              
(f0.1)  cmp (8|M0)    (eq)f0.1   null<1>:d     r28.0<1;1,0>:d    0:w              
(f0.1)  goto (8|M0)                          L17016                  L17016                
L14984:
        shl (8|M0)               r114.0<1>:d   r23.0<1;1,0>:d    1:w               {Compacted}
        shr (8|M0)               r113.0<1>:ud  r23.0<1;1,0>:ud   31:w              
        shl (8|M0)               r24.0<1>:d    r83.0<1;1,0>:d    1:w               {Compacted}
        cmp (8|M0)    (lt)f1.1   null<1>:ud    r114.0<1;1,0>:ud  0x4E:uw              {I@3}
        or (8|M0)                r24.0<1>:d    r24.0<1;1,0>:d    r113.0<1;1,0>:d  {Compacted,I@2}
(f1.1)  cmp (8|M0)    (eq)f1.1   null<1>:d     r24.0<1;1,0>:d    0:w               {I@1}
(~f1.1) cmp (8|M0)    (lt)f1.1   null<1>:d     r24.0<1;1,0>:d    0:w              
(f1.1)  goto (8|M0)                          L15216                  L15216                
L15088:
        cmp (8|M0)    (eq)f1.1   null<1>:d     r23.0<1;1,0>:d    39:w              
(f1.1)  cmp (8|M0)    (eq)f1.1   null<1>:d     r83.0<1;1,0>:d    0:w              
(~f1.1) goto (8|M0)                          L15216                  L15280                
L15136:
        shr (8|M0)               r93.0<1>:ud   r100.0<1;1,0>:ud  1:w              
        mov (8|M0)               r29.0<1>:d    0:w                              
        mov (8|M0)               r43.0<1>:d    0:w                              
        mov (8|M0)               r41.0<1>:f    r93.0<1;1,0>:f                   {Compacted,I@3}
        mov (8|M0)               r93.0<1>:f    r100.0<1;1,0>:f                  {Compacted}
        goto (8|M0)                          L15216                  L16472                
L15216:
        join (8|M0)                          L15280                                
L15232:
        cmp (8|M0)    (eq)f1.0   null<1>:d     r23.0<1;1,0>:d    38:w               {F@3}
(f1.0)  cmp (8|M0)    (eq)f1.0   null<1>:d     r83.0<1;1,0>:d    0:w              
(f1.0)  goto (8|M0)                          L15280                  L16392                
L15280:
        join (8|M0)                          L16392                                
L15296:
        add (8|M0)               acc0.0<1>:d   -r23.0<1;1,0>:d   39:w               {Compacted}
        add (8|M0)               r34.0<1>:d    -r23.0<1;1,0>:d   40:w               {Compacted}
        and (8|M0)    (ne)f1.1   r16.0<1>:d    acc0.0<1;1,0>:d   63:w              
(f1.1)  goto (8|M0)                          L15376                  L15376                
L15344:
        mov (8|M0)               r28.0<1>:d    r100.0<1;1,0>:d                 
        goto (8|M0)                          L15376                  L15512                
L15376:
        join (8|M0)                          L15512                                
L15392:
        cmp (8|M0)    (lt)f1.0   null<1>:ud    r16.0<1;1,0>:ud   0x20:uw              {I@5}
(f1.0)  add (8|M0)               acc0.0<1>:d   -r16.0<1;1,0>:d   32:w              
(~f1.0) add (8|M0)               acc2.0<1>:d   r16.0<1;1,0>:d    -32:w              
(f1.0)  shr (8|M0)               r28.0<1>:ud   r100.0<1;1,0>:ud  r16.0<1;1,0>:d  
(f1.0)  shl (8|M0)               r76.0<1>:d    r111.0<1;1,0>:d   acc0.0<1;1,0>:d 
(~f1.0) shr (8|M0)               r93.0<1>:ud   r111.0<1;1,0>:ud  acc2.0<1;1,0>:d  {F@1}
(f1.0)  or (8|M0)                r93.0<1>:d    r28.0<1;1,0>:d    r76.0<1;1,0>:d   {I@2}
        mov (8|M0)               r28.0<1>:f    r93.0<1;1,0>:f                   {Compacted,I@1}
L15512:
        join (8|M0)                          L16392                                
L15528:
        add (8|M0)               r122.0<1>:d   -r23.0<1;1,0>:d   38:w               {Compacted}
        and (8|M0)    (ne)f0.1   r22.0<1>:d    r122.0<1;1,0>:d   63:w               {I@1}
(f0.1)  goto (8|M0)                          L15600                  L15600                
L15568:
        mov (8|M0)               r93.0<1>:d    r100.0<1;1,0>:d                  {F@1}
        goto (8|M0)                          L15600                  L15728                
L15600:
        join (8|M0)                          L15728                                
L15616:
        cmp (8|M0)    (lt)f1.1   null<1>:ud    r22.0<1;1,0>:ud   0x20:uw              {I@5}
(f1.1)  add (8|M0)               acc0.0<1>:d   -r22.0<1;1,0>:d   32:w              
(~f1.1) add (8|M0)               acc2.0<1>:d   r22.0<1;1,0>:d    -32:w              
(f1.1)  shr (8|M0)               r26.0<1>:ud   r100.0<1;1,0>:ud  r22.0<1;1,0>:d  
(f1.1)  shl (8|M0)               r89.0<1>:d    r111.0<1;1,0>:d   acc0.0<1;1,0>:d 
(~f1.1) shr (8|M0)               r93.0<1>:ud   r111.0<1;1,0>:ud  acc2.0<1;1,0>:d 
(f1.1)  or (8|M0)                r93.0<1>:d    r26.0<1;1,0>:d    r89.0<1;1,0>:d   {I@2}
L15728:
        join (8|M0)                          L16392                                
L15744:
        and (8|M0)    (ne)f1.0   r88.0<1>:d    r122.0<1;1,0>:d   63:w              
        and (8|M0)               r43.0<1>:d    r93.0<1;1,0>:d    1:w               {Compacted,I@3}
(f1.0)  goto (8|M0)                          L15832                  L15832                
L15784:
        mov (8|M0)               r101.0<1>:d   -1:w                              
        mov (8|M0)               r112.0<1>:d   -1:w                              
        goto (8|M0)                          L15832                  L16016                
L15832:
        join (8|M0)                          L16016                                
L15848:
        cmp (8|M0)    (lt)f0.1   null<1>:ud    r88.0<1;1,0>:ud   0x20:uw              {I@7}
(f0.1)  goto (8|M0)                          L15952                  L15952                
L15880:
        add (8|M0)               acc0.0<1>:d   r88.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r6.8<1>:hf    -qnan(0x1FF):hf                             
        mov (8|M0)               r101.0<1>:d   0:w                              
        shl (8|M0)               r112.0<1>:d   r6.8<0;1,0>:w     acc0.0<1;1,0>:d  {F@1}
        goto (8|M0)                          L15952                  L16016                
L15952:
        join (8|M0)                          L16016                                
L15968:
(W)     mov (1|M0)               r6.8<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (8|M0)               r112.0<1>:d   -1:w                              
        shl (8|M0)               r101.0<1>:d   r6.8<0;1,0>:w     r88.0<1;1,0>:d   {F@1}
L16016:
        join (8|M0)                          L16392                                
L16032:
        bfn.0x28 (8|M0)          r25.0<1>:ud   r100.0<1;0>:ud    r101.0<1;0>:ud    r6.3<0>:ud       {I@2} // s0&(s1^s2)
        bfn.0x28 (8|M0)          r24.0<1>:ud   r111.0<1;0>:ud    r112.0<1;0>:ud    r6.3<0>:ud       // s0&(s1^s2)
        cmp (8|M0)    (ne)f0.1   null<1>:d     r25.0<1;1,0>:d    0:w               {I@2}
(W)     mov (1|M0)               r6.8<1>:hf    -qnan(0x1FF):hf                             
        and (8|M0)    (ne)f1.1   r21.0<1>:d    r34.0<1;1,0>:d    63:w              
(~f0.1) cmp (8|M0)    (ne)f0.1   null<1>:d     r24.0<1;1,0>:d    0:w               {I@3}
(f0.1)  sel (8|M0)               acc0.0<1>:d   r6.8<0;1,0>:w     0:w               {F@1}
        mov (8|M0)               r29.0<1>:d    -acc0.0<1;1,0>:d                
(f1.1)  goto (8|M0)                          L16208                  L16208                
L16176:
        mov (8|M0)               r93.0<1>:d    r100.0<1;1,0>:d                 
        goto (8|M0)                          L16208                  L16336                
L16208:
        join (8|M0)                          L16336                                
L16224:
        cmp (8|M0)    (lt)f1.0   null<1>:ud    r21.0<1;1,0>:ud   0x20:uw              {I@7}
(f1.0)  add (8|M0)               acc0.0<1>:d   -r21.0<1;1,0>:d   32:w              
(~f1.0) add (8|M0)               acc2.0<1>:d   r21.0<1;1,0>:d    -32:w              
(f1.0)  shl (8|M0)               r87.0<1>:d    r111.0<1;1,0>:d   acc0.0<1;1,0>:d 
(f1.0)  shr (8|M0)               r21.0<1>:ud   r100.0<1;1,0>:ud  r21.0<1;1,0>:d  
(~f1.0) shr (8|M0)               r93.0<1>:ud   r111.0<1;1,0>:ud  acc2.0<1;1,0>:d 
(f1.0)  or (8|M0)                r93.0<1>:d    r21.0<1;1,0>:d    r87.0<1;1,0>:d   {I@2}
L16336:
        join (8|M0)                          L16392                                
L16352:
        mov (8|M0)               r41.0<1>:f    r93.0<1;1,0>:f                   {Compacted,I@2}
        mov (8|M0)               r93.0<1>:d    r28.0<1;1,0>:d                   {F@1}
        goto (8|M0)                          L16392                  L16472                
L16392:
        join (8|M0)                          L16472                                
L16408:
        shr (8|M0)               r93.0<1>:ud   r100.0<1;1,0>:ud  2:w              
        and (8|M0)               r43.0<1>:d    r100.0<1;1,0>:d   1:w               {Compacted}
        mov (8|M0)               r29.0<1>:d    0:w                              
        mov (8|M0)               r41.0<1>:f    r93.0<1;1,0>:f                   {Compacted,I@3}
        shr (8|M0)               r93.0<1>:ud   r100.0<1;1,0>:ud  1:w               {F@1}
L16472:
        join (8|M0)                          L17016                                
L16488:
        shl (8|M0)               r60.0<1>:d    r93.0<1;1,0>:d    2:w               {Compacted,I@2}
        shl (8|M0)               r20.0<1>:d    r43.0<1;1,0>:d    1:w               {Compacted}
        and (8|M0)               r60.0<1>:d    r60.0<1;1,0>:d    4:w               {Compacted,I@2}
        and (8|M0)               r126.0<1>:d   r41.0<1;1,0>:d    8388607:d              
        bfn.0xFE (8|M0)          r114.0<1>:ud  r60.0<1;0>:ud     r20.0<1;0>:ud     r29.0<1>:ud      {I@2} // s0|s1|s2
        cmp (8|M0)    (eq)f0.1   null<1>:d     r114.0<1;1,0>:d   0:w               {I@1}
(~f0.1) goto (8|M0)                          L16608                  L16608                
L16576:
        mov (8|M0)               r113.0<1>:d   0:w                              
        goto (8|M0)                          L16608                  L16768                
L16608:
        join (8|M0)                          L16768                                
L16624:
        cmp (8|M0)    (gt)f1.1   null<1>:ud    r114.0<1;1,0>:ud  0x4:uw             
(~f1.1) goto (8|M0)                          L16688                  L16688                
L16656:
        mov (8|M0)               r113.0<1>:d   1:w                              
        goto (8|M0)                          L16688                  L16768                
L16688:
        join (8|M0)                          L16768                                
L16704:
        and (8|M0)    (ne)f1.1   null<1>:d     r41.0<1;1,0>:d    1:w              
(W)     mov (1|M0)               r6.8<1>:hf    0x1:hf                             
(f1.1)  cmp (8|M0)    (eq)f1.1   null<1>:d     r114.0<1;1,0>:d   4:w              
(f1.1)  sel (8|M0)               r113.0<1>:d   r6.8<0;1,0>:w     0:w               {F@1}
L16768:
        join (8|M0)                          L17016                                
L16784:
        add (8|M0)               r72.0<1>:d    r126.0<1;1,0>:d   r113.0<1;1,0>:d  {Compacted,I@2}
        add3 (8|M0)              r69.0<1>:d    r51.0<1;0>:d      r48.0<1;0>:d      82:w              
        cmp (8|M0)    (gt)f0.1   null<1>:ud    r72.0<1;1,0>:ud   0x7FFFFF:ud              {I@2}
(f0.1)  sel (8|M0)               r59.0<1>:d    r69.0<1;1,0>:d    r49.0<1;1,0>:d   {I@2}
        cmp (8|M0)    (eq)f1.0   null<1>:d     r59.0<1;1,0>:d    255:w               {I@1}
(f1.0)  goto (8|M0)                          L16944                  L16944                
L16872:
(~f0.1) sel (8|M0)               r74.0<1>:d    r72.0<1;1,0>:d    0:w              
        and (8|M0)               r68.0<1>:d    r14.0<1;1,0>:d    -2147483648:d              
        shl (8|M0)               r19.0<1>:d    r59.0<1;1,0>:d    23:w               {Compacted}
        bfn.0xFE (8|M0)          r98.0<1>:ud   r68.0<1;0>:ud     r19.0<1;0>:ud     r74.0<1>:ud      {I@1} // s0|s1|s2
        goto (8|M0)                          L16944                  L17584                
L16944:
        join (8|M0)                          L17016                                
L16960:
        cmp (8|M0)    (gt)f0.1   null<1>:d     r14.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r6.4<1>:f     inf:f                               {Compacted}
(f0.1)  sel (8|M0)               r98.0<1>:f    r6.4<0;1,0>:f     -inf:f               {A@1}
        goto (8|M0)                          L17016                  L17584                
L17016:
        join (8|M0)                          L17336                                
L17032:
        and (8|M0)    (ne)f0.1   r68.0<1>:d    r48.0<1;1,0>:d    63:w               {F@1}
(f0.1)  goto (8|M0)                          L17096                  L17096                
L17064:
        mov (8|M0)               r94.0<1>:d    -1:w                              
        goto (8|M0)                          L17096                  L17224                
L17096:
        join (8|M0)                          L17224                                
L17112:
        cmp (8|M0)    (lt)f1.1   null<1>:ud    r68.0<1;1,0>:ud   0x20:uw              {I@5}
(f1.1)  goto (8|M0)                          L17176                  L17176                
L17144:
        mov (8|M0)               r94.0<1>:d    0:w                              
        goto (8|M0)                          L17176                  L17224                
L17176:
        join (8|M0)                          L17224                                
L17192:
(W)     mov (1|M0)               r6.8<1>:hf    -qnan(0x1FF):hf                             
        shl (8|M0)               r94.0<1>:d    r6.8<0;1,0>:w     r68.0<1;1,0>:d   {F@1}
L17224:
        join (8|M0)                          L17336                                
L17240:
        bfn.0x28 (8|M0)          r112.0<1>:ud  r100.0<1;0>:ud    r94.0<1;0>:ud     r6.3<0>:ud       {I@2} // s0&(s1^s2)
        add (8|M0)               acc0.0<1>:d   -r48.0<1;1,0>:d   23:w               {Compacted}
        and (8|M0)               r67.0<1>:d    r14.0<1;1,0>:d    -2147483648:d              
        shl (8|M0)               r17.0<1>:d    r49.0<1;1,0>:d    23:w               {Compacted}
        shl (8|M0)               r112.0<1>:d   r112.0<1;1,0>:d   acc0.0<1;1,0>:d  {I@4}
        bfn.0xFE (8|M0)          r98.0<1>:ud   r67.0<1;0>:ud     r17.0<1;0>:ud     r112.0<1>:ud     {I@1} // s0|s1|s2
        goto (8|M0)                          L17336                  L17584                
L17336:
        join (8|M0)                          L17408                                
L17352:
        cmp (8|M0)    (gt)f1.1   null<1>:d     r14.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r6.4<1>:f     inf:f                               {Compacted}
(f1.1)  sel (8|M0)               r98.0<1>:f    r6.4<0;1,0>:f     -inf:f               {A@1}
        goto (8|M0)                          L17408                  L17584                
L17408:
        join (8|M0)                          L17480                                
L17424:
        cmp (8|M0)    (lt)f1.0   null<1>:d     r14.0<1;1,0>:d    0:w              
(W)     mov (1|M0)               r6.4<1>:f     -0.0:f                               {Compacted}
(f1.0)  sel (8|M0)               r98.0<1>:f    r6.4<0;1,0>:f     0.0:f               {F@1}
        goto (8|M0)                          L17480                  L17584                
L17480:
        join (8|M0)                          L17552                                
L17496:
        cmp (8|M0)    (gt)f0.1   null<1>:d     r14.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r6.4<1>:f     inf:f                               {Compacted}
(f0.1)  sel (8|M0)               r98.0<1>:f    r6.4<0;1,0>:f     -inf:f               {F@1}
        goto (8|M0)                          L17552                  L17584                
L17552:
        join (8|M0)                          L17584                                
L17568:
        bfn.0xF8 (8|M0)          r98.0<1>:ud   r14.0<1;0>:ud     r6.1<0;0>:ud      r6.0<0>:ud       {F@1} // s0&s1|s2
L17584:
        join (8|M0)                          L28712                                
L17600:
        shr (8|M0)               r23.0<1>:ud   r98.0<1;1,0>:ud   23:w               {I@2}
        and (8|M0)    (ne)f1.0   r119.0<1>:d   r98.0<1;1,0>:d    8388607:d              
        and (8|M0)               r113.0<1>:d   r23.0<1;1,0>:d    255:w               {Compacted,I@2}
(f1.0)  cmp (8|M0)    (eq)f1.0   null<1>:d     r113.0<1;1,0>:d   255:w               {I@1}
(~f1.0) goto (8|M0)                          L17696                  L17696                
L17672:
        mov (8|M0)               r98.0<1>:f    qnan(0x0):f                               {Compacted}
        goto (8|M0)                          L17696                  L22040                
L17696:
        join (8|M0)                          L22040                                
L17712:
        cmp (8|M0)    (eq)f0.1   null<1>:d     r119.0<1;1,0>:d   0:w              
(f0.1)  cmp (8|M0)    (eq)f0.1   null<1>:d     r113.0<1;1,0>:d   255:w              
(f0.1)  goto (8|M0)                          L22040                  L22040                
L17760:
        or (8|M0)     (eq)f1.0   null<1>:d     r113.0<1;1,0>:d   r119.0<1;1,0>:d 
(~f1.0) goto (8|M0)                          L17824                  L17824                
L17792:
        mov (8|M0)               r98.0<1>:f    0x3F650000:f                              
        goto (8|M0)                          L17824                  L22040                
L17824:
        join (8|M0)                          L22040                                
L17840:
        cmp (8|M0)    (gt)f0.1   null<1>:d     r98.0<1;1,0>:d    -1:w               {F@1}
        cmp (8|M0)    (gt)f1.1   null<1>:ud    r113.0<1;1,0>:ud  0x7E:uw             
(f0.1)  goto (8|M0)                          L18112                  L18112                
L17888:
(f1.1)  goto (8|M0)                          L18000                  L18000                
L17904:
        mov (8|M0)               r19.0<1>:f    0x3F650000:f                              
        mov (8|M0)               r125.0<1>:f   r98.0<1;1,0>:f                   {Compacted}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        call (8|M0)              r6.4          L41880                                 {A@1}
L17976:
        mov (8|M0)               r98.0<1>:f    r43.0<1;1,0>:f                   {Compacted,I@5}
        goto (8|M0)                          L18000                  L22040                
L18000:
        join (8|M0)                          L18112                                
L18016:
        mov (8|M0)               r19.0<1>:f    r98.0<1;1,0>:f                   {Compacted,F@1}
        mov (8|M0)               r125.0<1>:f   0x3F650000:f                              
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        call (8|M0)              r6.4          L41880                                 {A@1}
L18088:
        mov (8|M0)               r98.0<1>:f    r43.0<1;1,0>:f                   {Compacted}
        goto (8|M0)                          L18112                  L22040                
L18112:
        join (8|M0)                          L22040                                
L18128:
(f1.1)  goto (8|M0)                          L20248                  L20248                
L18144:
        cmp (8|M0)    (ne)f1.0   null<1>:d     r113.0<1;1,0>:d   0:w              
        add (8|M0)               r66.0<1>:d    -r113.0<1;1,0>:d  126:w               {Compacted}
(f1.0)  sel (8|M0)               r9.0<1>:d     r66.0<1;1,0>:d    125:w               {I@1}
        cmp (8|M0)    (lt)f1.1   null<1>:d     r9.0<1;1,0>:d     1:w               {I@1}
(f1.1)  goto (8|M0)                          L19336                  L19336                
L18216:
        cmp (8|M0)    (eq)f0.1   null<1>:d     r9.0<1;1,0>:d     1:w              
(f0.1)  goto (8|M0)                          L18920                  L18920                
L18248:
        cmp (8|M0)    (lt)f0.0   null<1>:ud    r9.0<1;1,0>:ud    0x18:uw             
(f0.0)  goto (8|M0)                          L18680                  L18680                
L18280:
        cmp (8|M0)    (ne)f1.0   r58.0<1>:d    r113.0<1;1,0>:d   0:w              
        cmp (8|M0)    (lt)f1.1   null<1>:d     r9.0<1;1,0>:d     25:w              
        mov (8|M0)               r127.0<1>:d   -r58.0<1;1,0>:d                  {I@2}
(f1.1)  goto (8|M0)                          L18488                  L18488                
L18344:
        cmp (8|M0)    (eq)f1.0   null<1>:d     r9.0<1;1,0>:d     25:w              
        cmp (8|M0)    (ne)f0.0   r65.0<1>:d    r119.0<1;1,0>:d   0:w              
        cmp (8|M0)    (ne)f1.1   r16.0<1>:d    r98.0<1;1,0>:d    0:w               {F@1}
(f1.0)  sel (8|M0)               r127.0<1>:d   -r58.0<1;1,0>:d   0:w              
(f1.0)  sel (8|M0)               acc0.0<1>:d   -r65.0<1;1,0>:d   -r16.0<1;1,0>:d  {I@2}
        mov (8|M0)               r82.0<1>:f    r127.0<1;1,0>:f                  {Compacted,I@2}
        shl (8|M0)               r47.0<1>:d    acc0.0<1;1,0>:d   31:w              
        mov (8|M0)               r127.0<1>:d   0:w                               {F@1}
        asr (8|M0)               r49.0<1>:d    r47.0<1;1,0>:d    31:w               {Compacted,I@2}
        goto (8|M0)                          L18488                  L18560                
L18488:
        join (8|M0)                          L18560                                
L18504:
        shr (8|M0)               r15.0<1>:ud   r98.0<1;1,0>:ud   22:w              
        and (8|M0)               r14.0<1>:d    r98.0<1;1,0>:d    4194303:d              
        and (8|M0)               r82.0<1>:d    r15.0<1;1,0>:d    1:w               {Compacted,I@2}
        cmp (8|M0)    (ne)f0.1   r49.0<1>:d    r14.0<1;1,0>:d    0:w               {I@2}
L18560:
        join (8|M0)                          L18680                                
L18576:
        cmp (8|M0)    (ne)f0.0   r13.0<1>:d    r49.0<1;1,0>:d    0:w               {I@2}
(W)     mov (1|M0)               r6.16<2>:b    126:w                              
        mov (8|M0)               r121.0<1>:f   9.275385e-39:f                              
        mov (8|M0)               r67.0<1>:f    r82.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r37.0<1>:d    -r13.0<1;1,0>:d                  {I@2}
        mov (8|M0)               r13.0<1>:b    r6.16<0;1,0>:b                   {I@2}
        goto (8|M0)                          L18680                  L19832                
L18680:
        join (8|M0)                          L18920                                
L18696:
        add (8|M0)               acc0.0<1>:d   r9.0<1;1,0>:d     -2:w               {Compacted}
(W)     mov (1|M0)               r6.8<1>:hf    -qnan(0x1FF):hf                              {I@4}
        add (8|M0)               acc2.0<1>:d   r9.0<1;1,0>:d     -1:w               {Compacted}
        add (8|M0)               r58.0<1>:d    -r9.0<1;1,0>:d    23:w               {Compacted}
        shr (8|M0)               r12.0<1>:ud   r119.0<1;1,0>:ud  acc0.0<1;1,0>:d 
        shl (8|M0)               r109.0<1>:d   r6.8<0;1,0>:w     acc0.0<1;1,0>:d  {F@1}
(W)     mov (1|M0)               r6.8<1>:hf    0x1:hf                              {I@1}
        shr (8|M0)               r89.0<1>:ud   r119.0<1;1,0>:ud  r9.0<1;1,0>:d   
        shr (8|M0)               r57.0<1>:ud   r119.0<1;1,0>:ud  acc2.0<1;1,0>:d 
        bfn.0x60 (8|M0)          r105.0<1>:ud  r109.0<1;0>:ud    r6.3<0;0>:ud      r119.0<1>:ud     // (s0^s1)&s2
        shl (8|M0)               r58.0<1>:d    r6.8<0;1,0>:w     r58.0<1;1,0>:d   {F@1}
(~f1.0) mov (8|M0)               r58.0<1>:d    0:w                              
        and (8|M0)               r7.0<1>:d     r12.0<1;1,0>:d    1:w               {Compacted}
        and (8|M0)               r127.0<1>:d   r57.0<1;1,0>:d    1:w               {Compacted,I@5}
        or (8|M0)                r15.0<1>:d    r89.0<1;1,0>:d    r58.0<1;1,0>:d   {Compacted,I@3}
        cmp (8|M0)    (ne)f1.1   r57.0<1>:d    r105.0<1;1,0>:d   0:w              
        goto (8|M0)                          L18920                  L19008                
L18920:
        join (8|M0)                          L19008                                
L18936:
        and (8|M0)               r127.0<1>:d   r98.0<1;1,0>:d    1:w               {Compacted}
        shr (8|M0)               r15.0<1>:ud   r119.0<1;1,0>:ud  1:w              
(f1.0)  goto (8|M0)                          L19008                  L19224                
L18976:
        mov (8|M0)               r7.0<1>:d     0:w                              
        mov (8|M0)               r57.0<1>:d    0:w                              
L19008:
        join (8|M0)                          L19224                                
L19024:
        cmp (8|M0)    (ne)f1.0   r81.0<1>:d    r57.0<1;1,0>:d    0:w               {I@2}
        cmp (8|M0)    (gt)f1.0   null<1>:ud    r15.0<1;1,0>:ud   0x1AFFFF:ud             
        add (8|M0)               r121.0<1>:d   r15.0<1;1,0>:d    6619136:d              
        mov (8|M0)               r37.0<1>:d    -r81.0<1;1,0>:d                  {I@3}
(f1.0)  goto (8|M0)                          L19160                  L19160                
L19104:
(W)     mov (1|M0)               r6.16<2>:b    126:w                              
        mov (8|M0)               r67.0<1>:f    r7.0<1;1,0>:f                    {Compacted}
        mov (8|M0)               r13.0<1>:b    r6.16<0;1,0>:b                   {I@1}
        goto (8|M0)                          L19160                  L19832                
L19160:
        join (8|M0)                          L19224                                
L19176:
        cmp (8|M0)    (eq)f0.1   null<1>:d     r7.0<1;1,0>:d     1:w              
(~f0.1) sel (8|M0)               r37.0<1>:d    -r81.0<1;1,0>:d   1:w              
        goto (8|M0)                          L19224                  L19272                
L19224:
        join (8|M0)                          L19272                                
L19240:
        add (8|M0)               r121.0<1>:d   r15.0<1;1,0>:d    10813440:d              
        mov (8|M0)               r37.0<1>:d    0:w                              
L19272:
        join (8|M0)                          L19336                                
L19288:
        shr (8|M0)               r11.0<1>:ud   r121.0<1;1,0>:ud  1:w               {I@3}
        and (8|M0)               r80.0<1>:d    r11.0<1;1,0>:d    4194303:d               {I@1}
        goto (8|M0)                          L19336                  L19744                
L19336:
        join (8|M0)                          L19744                                
L19352:
        cmp (8|M0)    (gt)f0.0   null<1>:ud    r119.0<1;1,0>:ud  0x1AFFFF:ud             
        add (8|M0)               r121.0<1>:d   r119.0<1;1,0>:d   6619136:d              
(f0.0)  goto (8|M0)                          L19632                  L19632                
L19400:
(f1.0)  goto (8|M0)                          L19512                  L19512                
L19416:
(W)     mov (1|M0)               r6.16<2>:b    126:w                              
        mov (8|M0)               r127.0<1>:d   0:w                              
        mov (8|M0)               r67.0<1>:d    0:w                               {F@1}
        mov (8|M0)               r37.0<1>:d    0:w                              
        mov (8|M0)               r13.0<1>:b    r6.16<0;1,0>:b                   {I@4}
        goto (8|M0)                          L19512                  L19832                
L19512:
        join (8|M0)                          L19632                                
L19528:
(W)     mov (1|M0)               r6.16<2>:b    127:w                              
        and (8|M0)               r127.0<1>:d   r98.0<1;1,0>:d    1:w               {Compacted}
        shr (8|M0)               r121.0<1>:ud  r121.0<1;1,0>:ud  1:w              
        mov (8|M0)               r67.0<1>:d    0:w                              
        mov (8|M0)               r37.0<1>:d    0:w                              
        mov (8|M0)               r13.0<1>:b    r6.16<0;1,0>:b                   {I@5}
        goto (8|M0)                          L19632                  L19832                
L19632:
        join (8|M0)                          L19744                                
L19648:
        shr (8|M0)               r90.0<1>:ud   r121.0<1;1,0>:ud  1:w               {I@6}
        mov (8|M0)               r37.0<1>:d    0:w                              
        and (8|M0)               r64.0<1>:d    r90.0<1;1,0>:d    4194303:d               {I@2}
        or (8|M0)                r90.0<1>:d    r90.0<1;1,0>:d    4194304:d              
        mov (8|M0)               r127.0<1>:d   0:w                              
(f1.0)  sel (8|M0)               r80.0<1>:d    r90.0<1;1,0>:d    r64.0<1;1,0>:d   {I@2}
L19744:
        join (8|M0)                          L19832                                
L19760:
        and (8|M0)               acc0.0<1>:d   r121.0<1;1,0>:d   1:w               {Compacted}
(W)     mov (1|M0)               r6.16<2>:b    127:w                              
        mov (8|M0)               r67.0<1>:f    r127.0<1;1,0>:f                  {Compacted,I@5}
        mov (8|M0)               r121.0<1>:f   r80.0<1;1,0>:f                   {Compacted,A@2}
        mov (8|M0)               r127.0<1>:d   acc0.0<1;1,0>:d                  {F@2}
        mov (8|M0)               r13.0<1>:b    r6.16<0;1,0>:b                   {I@2}
L19832:
        join (8|M0)                          L20248                                
L19848:
        shl (8|M0)               r76.0<1>:d    r127.0<1;1,0>:d   2:w               {Compacted,I@3}
        shl (8|M0)               r10.0<1>:d    r67.0<1;1,0>:d    1:w               {Compacted}
        bfn.0xFE (8|M0)          r51.0<1>:ud   r76.0<1;0>:ud     r10.0<1;0>:ud     r37.0<1>:ud      {I@1} // s0|s1|s2
        cmp (8|M0)    (eq)f1.1   null<1>:d     r51.0<1;1,0>:d    0:w               {I@1}
(~f1.1) goto (8|M0)                          L19944                  L19944                
L19912:
        mov (8|M0)               r56.0<1>:d    0:w                              
        goto (8|M0)                          L19944                  L20104                
L19944:
        join (8|M0)                          L20104                                
L19960:
        cmp (8|M0)    (gt)f1.0   null<1>:ud    r51.0<1;1,0>:ud   0x4:uw             
(~f1.0) goto (8|M0)                          L20024                  L20024                
L19992:
        mov (8|M0)               r56.0<1>:d    1:w                              
        goto (8|M0)                          L20024                  L20104                
L20024:
        join (8|M0)                          L20104                                
L20040:
        and (8|M0)    (ne)f1.1   null<1>:d     r121.0<1;1,0>:d   1:w               {F@1}
(W)     mov (1|M0)               r6.8<1>:hf    0x1:hf                             
(f1.1)  cmp (8|M0)    (eq)f1.1   null<1>:d     r51.0<1;1,0>:d    4:w              
(f1.1)  sel (8|M0)               r56.0<1>:d    r6.8<0;1,0>:w     0:w               {F@1}
L20104:
        join (8|M0)                          L20248                                
L20120:
        add (8|M0)               r53.0<1>:d    r121.0<1;1,0>:d   r56.0<1;1,0>:d   {Compacted,I@2}
        mov (8|M0)               r52.0<1>:d    r13.0<1;1,0>:ub                 
        cmp (8|M0)    (eq)f0.1   r63.0<1>:d    r53.0<1;1,0>:d    8388608:d               {I@2}
        cmp (8|M0)    (eq)f1.1   null<1>:d     r53.0<1;1,0>:d    8388608:d              
        add3 (8|M0)              acc0.0<1>:d   r52.0<1;0>:d      -r63.0<1;0>:d     0:w               {I@2}
(f1.1)  mov (8|M0)               r53.0<1>:d    0:w                              
        shl (8|M0)               r52.0<1>:d    acc0.0<1;1,0>:d   23:w              
        or (8|M0)                r98.0<1>:d    r52.0<1;1,0>:d    r53.0<1;1,0>:d   {Compacted,I@1}
        goto (8|M0)                          L20248                  L22040                
L20248:
        join (8|M0)                          L22040                                
L20264:
        mov (8|M0)               r9.0<1>:b     r23.0<4;1,0>:b                  
        cmp (8|M0)    (eq)f0.1   null<1>:w     r9.0<1;1,0>:b     127:w               {I@1}
(~f0.1) goto (8|M0)                          L20392                  L20392                
L20312:
        mov (8|M0)               r17.0<1>:d    0:w                              
        mov (8|M0)               r54.0<1>:d    0:w                              
        mov (8|M0)               r63.0<1>:d    0:w                              
        mov (8|M0)               r66.0<1>:f    0x728000:f                              
        goto (8|M0)                          L20392                  L21072                
L20392:
        join (8|M0)                          L21072                                
L20408:
        cmp (8|M0)    (eq)f0.0   null<1>:w     r9.0<1;1,0>:b     126:w              
(f0.0)  goto (8|M0)                          L21072                  L21288                
L20440:
        add (8|M0)               r108.0<1>:d   r113.0<1;1,0>:d   -126:w               {Compacted}
        cmp (8|M0)    (lt)f1.1   null<1>:ud    r108.0<1;1,0>:ud  0x18:uw              {I@1}
(f1.1)  goto (8|M0)                          L20848                  L20848                
L20480:
        cmp (8|M0)    (lt)f1.0   null<1>:w     r9.0<1;1,0>:b     -105:w              
(f1.0)  goto (8|M0)                          L20624                  L20624                
L20512:
        cmp (8|M0)    (eq)f0.1   null<1>:w     r9.0<1;1,0>:b     -105:w              
(~f0.1) goto (8|M0)                          L20624                  L20752                
L20544:
        mov (8|M0)               r17.0<1>:d    0:w                              
        mov (8|M0)               r54.0<1>:d    1:w                              
        mov (8|M0)               r63.0<1>:d    -1:w                              
        mov (8|M0)               r66.0<1>:d    0:w                               {F@1}
        goto (8|M0)                          L20624                  L21072                
L20624:
        join (8|M0)                          L20752                                
L20640:
        cmp (8|M0)    (eq)f0.0   null<1>:w     r9.0<1;1,0>:b     -106:w              
(~f0.0) goto (8|M0)                          L20752                  L20752                
L20672:
        mov (8|M0)               r17.0<1>:d    1:w                              
        mov (8|M0)               r54.0<1>:d    1:w                              
        mov (8|M0)               r63.0<1>:d    -1:w                              
        mov (8|M0)               r66.0<1>:d    0:w                              
        goto (8|M0)                          L20752                  L21072                
L20752:
        join (8|M0)                          L20848                                
L20768:
        mov (8|M0)               r17.0<1>:d    0:w                              
        mov (8|M0)               r54.0<1>:d    0:w                              
        mov (8|M0)               r63.0<1>:d    -1:w                              
        mov (8|M0)               r66.0<1>:d    0:w                              
        goto (8|M0)                          L20848                  L21072                
L20848:
        join (8|M0)                          L21072                                
L20864:
(W)     mov (1|M0)               r6.5<1>:f     9.275385e-39:f                              
        add (8|M0)               acc0.0<1>:d   r113.0<1;1,0>:d   -128:w               {Compacted}
(W)     mov (1|M0)               r6.8<1>:hf    -qnan(0x1FF):hf                             
        add (8|M0)               acc2.0<1>:d   r113.0<1;1,0>:d   -127:w               {Compacted}
        add (8|M0)               r37.0<1>:d    -r113.0<1;1,0>:d  149:w               {Compacted}
        shr (8|M0)               r9.0<1>:ud    r6.5<0;1,0>:ud    acc0.0<1;1,0>:d  {F@2}
        shl (8|M0)               r51.0<1>:d    r6.8<0;1,0>:w     acc0.0<1;1,0>:d  {F@1}
(W)     mov (1|M0)               r6.8<1>:hf    0x1:hf                              {I@1}
        shr (8|M0)               r96.0<1>:ud   r6.5<0;1,0>:ud    r108.0<1;1,0>:d 
        shr (8|M0)               r93.0<1>:ud   r6.5<0;1,0>:ud    acc2.0<1;1,0>:d 
        and (8|M0)               r51.0<1>:d    r51.0<1;1,0>:d    6619136:d              
        shl (8|M0)               r37.0<1>:d    r6.8<0;1,0>:w     r37.0<1;1,0>:d   {F@1}
        and (8|M0)               r54.0<1>:d    r9.0<1;1,0>:d     1:w               {Compacted}
        and (8|M0)               r17.0<1>:d    r93.0<1;1,0>:d    1:w               {Compacted,I@4}
        cmp (8|M0)    (ne)f0.1   r63.0<1>:d    r51.0<1;1,0>:d    6619136:d               {I@4}
        or (8|M0)                r66.0<1>:d    r96.0<1;1,0>:d    r37.0<1;1,0>:d   {Compacted,I@4}
L21072:
        join (8|M0)                          L21288                                
L21088:
        add (8|M0)               r123.0<1>:d   r119.0<1;1,0>:d   r66.0<1;1,0>:d   {Compacted,I@2}
        cmp (8|M0)    (ne)f0.0   r86.0<1>:d    r63.0<1;1,0>:d    0:w              
        cmp (8|M0)    (gt)f1.1   null<1>:ud    r123.0<1;1,0>:ud  0x7FFFFF:ud              {I@2}
        mov (8|M0)               r36.0<1>:d    -r86.0<1;1,0>:d                  {I@2}
(f1.1)  goto (8|M0)                          L21192                  L21192                
L21160:
        mov (8|M0)               r14.0<1>:d    r54.0<1;1,0>:d                  
        goto (8|M0)                          L21192                  L21576                
L21192:
        join (8|M0)                          L21288                                
L21208:
        cmp (8|M0)    (eq)f1.0   null<1>:d     r54.0<1;1,0>:d    1:w              
        shr (8|M0)               r7.0<1>:ud    r123.0<1;1,0>:ud  1:w              
        and (8|M0)               r71.0<1>:d    r7.0<1;1,0>:d     4194303:d               {I@1}
(~f1.0) sel (8|M0)               r36.0<1>:d    -r86.0<1;1,0>:d   1:w              
        goto (8|M0)                          L21288                  L21512                
L21288:
        join (8|M0)                          L21512                                
L21304:
        cmp (8|M0)    (gt)f0.1   null<1>:ud    r119.0<1;1,0>:ud  0x1AFFFF:ud             
        add (8|M0)               r123.0<1>:d   r119.0<1;1,0>:d   6619136:d              
(f0.1)  goto (8|M0)                          L21432                  L21432                
L21352:
        and (8|M0)               r17.0<1>:d    r98.0<1;1,0>:d    1:w               {Compacted}
        shr (8|M0)               r123.0<1>:ud  r123.0<1;1,0>:ud  1:w               {I@3}
        add (8|M0)               r113.0<1>:d   r113.0<1;1,0>:d   1:w               {Compacted}
        mov (8|M0)               r14.0<1>:d    0:w                              
        mov (8|M0)               r36.0<1>:d    0:w                              
        goto (8|M0)                          L21432                  L21576                
L21432:
        join (8|M0)                          L21512                                
L21448:
        shr (8|M0)               r127.0<1>:ud  r123.0<1;1,0>:ud  1:w               {I@6}
        mov (8|M0)               r36.0<1>:d    0:w                              
        mov (8|M0)               r17.0<1>:d    0:w                              
        or (8|M0)                r71.0<1>:d    r127.0<1;1,0>:d   4194304:d               {I@3}
L21512:
        join (8|M0)                          L21576                                
L21528:
        and (8|M0)               acc0.0<1>:d   r123.0<1;1,0>:d   1:w               {Compacted}
        add (8|M0)               r113.0<1>:d   r113.0<1;1,0>:d   1:w               {Compacted}
        mov (8|M0)               r14.0<1>:f    r17.0<1;1,0>:f                   {Compacted,I@5}
        mov (8|M0)               r123.0<1>:f   r71.0<1;1,0>:f                   {Compacted,A@2}
        mov (8|M0)               r17.0<1>:d    acc0.0<1;1,0>:d                  {F@2}
L21576:
        join (8|M0)                          L22040                                
L21592:
        shl (8|M0)               r81.0<1>:d    r17.0<1;1,0>:d    2:w               {Compacted,I@2}
        shl (8|M0)               r126.0<1>:d   r14.0<1;1,0>:d    1:w               {Compacted}
        bfn.0xFE (8|M0)          r55.0<1>:ud   r81.0<1;0>:ud     r126.0<1;0>:ud    r36.0<1>:ud      {I@1} // s0|s1|s2
        cmp (8|M0)    (eq)f0.0   null<1>:d     r55.0<1;1,0>:d    0:w               {Compacted,I@1}
(~f0.0) goto (8|M0)                          L21680                  L21680                
L21648:
        mov (8|M0)               r80.0<1>:d    0:w                              
        goto (8|M0)                          L21680                  L21840                
L21680:
        join (8|M0)                          L21840                                
L21696:
        cmp (8|M0)    (gt)f1.1   null<1>:ud    r55.0<1;1,0>:ud   0x4:uw             
(~f1.1) goto (8|M0)                          L21760                  L21760                
L21728:
        mov (8|M0)               r80.0<1>:d    1:w                              
        goto (8|M0)                          L21760                  L21840                
L21760:
        join (8|M0)                          L21840                                
L21776:
        and (8|M0)    (ne)f1.0   null<1>:d     r123.0<1;1,0>:d   1:w               {F@1}
(W)     mov (1|M0)               r6.8<1>:hf    0x1:hf                             
(f1.0)  cmp (8|M0)    (eq)f1.0   null<1>:d     r55.0<1;1,0>:d    4:w              
(f1.0)  sel (8|M0)               r80.0<1>:d    r6.8<0;1,0>:w     0:w               {F@1}
L21840:
        join (8|M0)                          L22040                                
L21856:
        add (8|M0)               r79.0<1>:d    r123.0<1;1,0>:d   r80.0<1;1,0>:d   {Compacted,I@2}
        cmp (8|M0)    (eq)f0.0   r125.0<1>:d   r79.0<1;1,0>:d    8388608:d               {I@1}
        cmp (8|M0)    (eq)f1.1   null<1>:d     r79.0<1;1,0>:d    8388608:d              
        add3 (8|M0)              r56.0<1>:d    r113.0<1;0>:d     -r125.0<1;0>:d    0:w               {I@2}
        cmp (8|M0)    (eq)f1.0   null<1>:d     r56.0<1;1,0>:d    255:w               {I@1}
(~f1.0) goto (8|M0)                          L21968                  L21968                
L21944:
        mov (8|M0)               r98.0<1>:f    inf:f                               {Compacted}
        goto (8|M0)                          L21968                  L22040                
L21968:
        join (8|M0)                          L22040                                
L21984:
(~f1.1) sel (8|M0)               r73.0<1>:d    r79.0<1;1,0>:d    0:w              
        and (8|M0)               r62.0<1>:d    r98.0<1;1,0>:d    -2147483648:d               {F@1}
        shl (8|M0)               r124.0<1>:d   r56.0<1;1,0>:d    23:w               {Compacted}
        bfn.0xFE (8|M0)          r98.0<1>:ud   r62.0<1;0>:ud     r124.0<1;0>:ud    r73.0<1>:ud      {I@1} // s0|s1|s2
L22040:
        join (8|M0)                          L28712                                
L22056:
        shr (8|M0)               r10.0<1>:ud   r8.0<1;1,0>:ud    23:w              
        and (8|M0)    (ne)f0.1   r22.0<1>:d    r8.0<1;1,0>:d     8388607:d              
        and (8|M0)               r68.0<1>:d    r10.0<1;1,0>:d    255:w               {Compacted,I@2}
(f0.1)  cmp (8|M0)    (eq)f0.1   null<1>:d     r68.0<1;1,0>:d    255:w               {I@1}
(~f0.1) goto (8|M0)                          L22152                  L22152                
L22128:
        mov (8|M0)               r117.0<1>:f   qnan(0x0):f                               {Compacted}
        goto (8|M0)                          L22152                  L28664                
L22152:
        join (8|M0)                          L28664                                
L22168:
        mov (8|M0)               r9.0<1>:hf    r98.0<1;1,0>:f                  
        mov (8|M0)               r111.0<1>:f   r9.0<1;1,0>:hf                   {F@1}
        shr (8|M0)               r121.0<1>:ud  r111.0<1;1,0>:ud  23:w               {F@1}
        and (8|M0)    (ne)f0.0   r17.0<1>:d    r111.0<1;1,0>:d   8388607:d              
        and (8|M0)               r65.0<1>:d    r121.0<1;1,0>:d   255:w               {Compacted,I@2}
(f0.0)  cmp (8|M0)    (eq)f0.0   null<1>:d     r65.0<1;1,0>:d    255:w               {I@1}
(~f0.0) goto (8|M0)                          L22296                  L22296                
L22272:
        mov (8|M0)               r117.0<1>:f   qnan(0x0):f                               {Compacted}
        goto (8|M0)                          L22296                  L28664                
L22296:
        join (8|M0)                          L28664                                
L22312:
        cmp (8|M0)    (eq)f1.1   null<1>:d     r22.0<1;1,0>:d    0:w              
        cmp (8|M0)    (eq)f1.0   null<1>:d     r17.0<1;1,0>:d    0:w              
(W)     mov (1|M0)               r6.8<1>:hf    0x1:hf                             
        xor (8|M0)               r15.0<1>:d    r8.0<1;1,0>:d     r111.0<1;1,0>:d  {Compacted}
(f1.1)  cmp (8|M0)    (eq)f1.1   null<1>:d     r68.0<1;1,0>:d    255:w              
(f1.0)  cmp (8|M0)    (eq)f1.0   null<1>:d     r65.0<1;1,0>:d    255:w              
(f1.1)  sel (8|M0)               r9.0<1>:uw    r6.8<0;1,0>:uw    0x0:uw              {F@1}
(f1.0)  sel (8|M0)               r8.0<1>:uw    r6.8<0;1,0>:uw    0x0:uw             
        or (8|M0)     (ne)f0.1   null<1>:uw    r9.0<1;1,0>:uw    r8.0<1;1,0>:uw   {I@1}
(f0.1)  goto (8|M0)                          L28632                  L28632                
L22464:
        or (8|M0)     (eq)f1.1   null<1>:d     r65.0<1;1,0>:d    r17.0<1;1,0>:d  
        or (8|M0)                r123.0<1>:d   r68.0<1;1,0>:d    r22.0<1;1,0>:d   {Compacted}
(~f1.1) cmp (8|M0)    (eq)f1.1   null<1>:d     r123.0<1;1,0>:d   0:w               {I@1}
(~f1.1) goto (8|M0)                          L22544                  L22544                
L22520:
        mov (8|M0)               r117.0<1>:f   0.0:f                               {Compacted}
        goto (8|M0)                          L22544                  L28664                
L22544:
        join (8|M0)                          L28632                                
L22560:
        cmp (8|M0)    (eq)f0.1   null<1>:d     r68.0<1;1,0>:d    0:w              
        cmp (8|M0)    (eq)f1.0   null<1>:d     r65.0<1;1,0>:d    0:w              
        add (8|M0)               r49.0<1>:d    r68.0<1;1,0>:d    -127:w               {Compacted}
        add (8|M0)               r24.0<1>:d    r65.0<1;1,0>:d    -127:w               {Compacted}
(f0.1)  mov (8|M0)               r49.0<1>:d    -126:w                              
(f1.0)  mov (8|M0)               r24.0<1>:d    -126:w                              
        add (8|M0)               r25.0<1>:d    r49.0<1;1,0>:d    r24.0<1;1,0>:d   {Compacted,I@1}
        cmp (8|M0)    (gt)f0.0   null<1>:d     r25.0<1;1,0>:d    127:w               {I@1}
(f0.0)  goto (8|M0)                          L28560                  L28560                
L22680:
        or (8|M0)     (eq)f1.1   null<4>:b     r10.0<1;1,0>:d    r121.0<1;1,0>:d 
(f1.1)  goto (8|M0)                          L28488                  L28488                
L22712:
(W)     mov (1|M0)               r6.8<1>:hf    0.0:hf                             
(W)     mov (1|M0)               r8.5<1>:d     0:w                              
(f0.1)  sel (8|M0)               acc0.0<1>:d   r6.8<0;1,0>:w     8388608:d               {F@1}
(f1.0)  sel (8|M0)               acc2.0<1>:d   r6.8<0;1,0>:w     8388608:d              
        or (8|M0)                r108.0<1>:d   acc0.0<1;1,0>:d   r22.0<1;1,0>:d  
        or (8|M0)                r104.0<1>:d   acc2.0<1;1,0>:d   r17.0<1;1,0>:d  
(W)     mov (1|M0)               r8.4<1>:f     -0.0:f                               {Compacted}
        mul (8|M0)               acc0.0<1>:ud  r108.0<1;1,0>:ud  r104.0<2;1,0>:uw {I@1}
        mach (8|M0)              r74.0<1>:ud   r108.0<1;1,0>:ud  r104.0<1;1,0>:ud {AccWrEn,Compacted}
(W)     mov (2|M0)               r6.4<1>:d     0:w                              
        mov (8|M0)               acc0.0<1>:ud  acc0.0<1;1,0>:ud                
        mov (8|M0)               r108.0<1>:f   r74.0<1;1,0>:f                   {Compacted,I@3}
        mov (8|M0)               r99.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
L22888:
(W)     shl (1|M0)               r8.2<1>:d     r8.4<0;1,0>:d     31:w               {F@2}
(W)     shr (1|M0)               r8.1<1>:ud    r8.5<0;1,0>:ud    1:w              
(W)     cmp (8|M0)    (gt)f0.1   null<1>:ud    r6.4<0;1,0>:ud    0x3E:uw              {I@5}
(W)     or (1|M0)                r8.5<1>:d     r8.1<0;1,0>:d     r8.2<0;1,0>:d    {I@2}
        bfn.0xA8 (8|M0)          r30.0<1>:ud   r99.0<1;0>:ud     r8.1<0;0>:ud      r8.2<0>:ud       // s0&(s1|s2)
(W)     shr (1|M0)               r6.7<1>:ud    r8.4<0;1,0>:ud    1:w              
(W&f0.1) cmp (8|M0)   (eq)f0.1   null<1>:d     r6.5<0;1,0>:d     0:w              
        cmp (8|M0)    (eq)f0.0   null<1>:d     r30.0<1;1,0>:d    r8.5<0;1,0>:d    {I@3}
(W)     addc (1|M0)              r10.0<1>:ud   r6.4<0;1,0>:ud    0x1:ud              {AccWrEn}
        and (8|M0)               r29.0<1>:d    r108.0<1;1,0>:d   r6.7<0;1,0>:d    {Compacted,A@1}
(W)     mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
(W&~f0.1) cmp (8|M0)  (gt)f0.1   null<1>:ud    r6.5<0;1,0>:ud    0x0:uw             
(f0.0)  cmp (8|M0)    (eq)f0.0   null<1>:d     r29.0<1;1,0>:d    r6.7<0;1,0>:d    {I@3}
(W)     add (1|M0)               r8.6<1>:ud    r8.0<0;1,0>:ud    r6.5<0;1,0>:ud   {I@3}
(W)     mov (1|M0)               r8.0<1>:hf    0x1:hf                              {I@1}
        mov (8|M0)               r117.0<1>:d   r6.4<0;1,0>:d                   
(f0.1)  sel (8|M0)               r9.0<1>:uw    r8.0<0;1,0>:uw    0x0:uw              {F@1}
(f0.0)  sel (8|M0)               r8.0<1>:uw    r8.0<0;1,0>:uw    0x0:uw             
        mov (8|M0)               r124.0<1>:d   r6.5<0;1,0>:d                   
        or (8|M0)     (ne)f0.1   null<1>:uw    r9.0<1;1,0>:uw    r8.0<1;1,0>:uw   {I@2}
        mov (8|M0)               r21.0<1>:f    r10.0<0;1,0>:f                   {Compacted}
        mov (8|M0)               r79.0<1>:d    r8.6<0;1,0>:d                   
(f0.1)  goto (8|M0)                          L23296                  L23296                
L23232:
(W)     mov (1|M0)               r8.4<1>:d     r6.7<0;1,0>:d                   
(W)     mov (1|M0)               r6.4<1>:d     r10.0<0;1,0>:d                  
(W)     mov (1|M0)               r6.5<1>:d     r8.6<0;1,0>:d                   
(W)     jmpi                                 L22888                                
L23296:
        join (8|M0)                          L28488                                
L23312:
(W)     mov (1|M0)               r6.4<1>:f     8.68805e-44:f                               {I@4}
(W)     mov (1|M0)               r8.0<1>:hf    0.0:hf                             
        subb (8|M0)              r38.0<1>:ud   r6.4<0;1,0>:ud    r117.0<1;1,0>:ud {AccWrEn,Compacted,F@2}
        add3 (8|M0)              r60.0<1>:d    r25.0<1;0>:d      r38.0<1;0>:d      -46:w               {I@1}
        add3 (8|M0)              r26.0<1>:ud   -acc0.0<1;0>:ud   r8.0<0;0>:uw      -r124.0<1>:ud    {F@1}
        cmp (8|M0)    (gt)f1.0   null<1>:d     r60.0<1;1,0>:d    127:w               {I@2}
        add3 (8|M0)              r126.0<1>:d   r49.0<1;0>:d      r24.0<1;0>:d      r38.0<1>:d      
(f1.0)  goto (8|M0)                          L28416                  L28416                
L23432:
        cmp (8|M0)    (gt)f0.1   null<1>:d     r60.0<1;1,0>:d    -127:w              
(f0.1)  goto (8|M0)                          L25984                  L25984                
L23464:
        cmp (8|M0)    (lt)f0.0   null<1>:ud    r60.0<1;1,0>:ud   0xFFFFFF6B:ud             
(f0.0)  goto (8|M0)                          L25464                  L25464                
L23496:
(W)     mov (1|M0)               r6.4<1>:f     8.82818e-44:f                              
        add3 (8|M0)              r16.0<1>:d    r25.0<1;0>:d      r38.0<1;0>:d      104:w              
        subb (8|M0)              r72.0<1>:ud   r6.4<0;1,0>:ud    r117.0<1;1,0>:ud {AccWrEn,Compacted,F@1}
(W)     mov (1|M0)               r8.0<1>:hf    0.0:hf                              {I@7}
        cmp (8|M0)    (gt)f0.0   null<1>:ud    r72.0<1;1,0>:ud   r16.0<1;1,0>:ud  {I@1}
        add3 (8|M0)              r67.0<1>:ud   -acc0.0<1;0>:ud   r8.0<0;0>:uw      -r124.0<1>:ud    {F@1}
(f0.0)  cmp (8|M0)    (eq)f0.0   null<1>:d     r67.0<1;1,0>:d    0:w               {I@1}
(~f0.0) cmp (8|M0)    (gt)f0.0   null<1>:ud    r67.0<1;1,0>:ud   0x0:uw             
(f0.0)  goto (8|M0)                          L23696                  L23696                
L23632:
        add3 (8|M0)              acc0.0<1>:d   r126.0<1;0>:d     -r72.0<1;0>:d     104:w              
        mov (8|M0)               r78.0<1>:d    0:w                              
        shl (8|M0)               r79.0<1>:d    r99.0<1;1,0>:d    acc0.0<1;1,0>:d 
        goto (8|M0)                          L23696                  L25400                
L23696:
        join (8|M0)                          L25400                                
L23712:
        add3 (8|M0)              r81.0<1>:d    r72.0<1;0>:d      -r126.0<1;0>:d    -104:w              
        cmp (8|M0)    (lt)f1.1   null<1>:d     r81.0<1;1,0>:d    2:w               {I@1}
(f1.1)  goto (8|M0)                          L23856                  L23856                
L23760:
        cmp (8|M0)    (eq)f1.0   null<1>:d     r81.0<1;1,0>:d    2:w              
(~f1.0) goto (8|M0)                          L23856                  L23960                
L23792:
        shr (8|M0)               r91.0<1>:ud   r99.0<1;1,0>:ud   1:w              
        and (8|M0)               r32.0<1>:d    r99.0<1;1,0>:d    1:w               {Compacted}
        mov (8|M0)               r127.0<1>:d   0:w                              
        mov (8|M0)               r110.0<1>:f   r91.0<1;1,0>:f                   {Compacted,I@3}
        goto (8|M0)                          L23856                  L24840                
L23856:
        join (8|M0)                          L23960                                
L23872:
        cmp (8|M0)    (eq)f0.1   null<1>:d     r81.0<1;1,0>:d    1:w              
(~f0.1) goto (8|M0)                          L23960                  L23960                
L23904:
        mov (8|M0)               r127.0<1>:d   0:w                              
        mov (8|M0)               r32.0<1>:d    0:w                              
        mov (8|M0)               r110.0<1>:f   r99.0<1;1,0>:f                   {Compacted}
        goto (8|M0)                          L23960                  L24840                
L23960:
        join (8|M0)                          L24840                                
L23976:
        add3 (8|M0)              acc0.0<1>:d   r72.0<1;0>:d      -r16.0<1;0>:d     -1:w              
        and (8|M0)    (ne)f0.0   r103.0<1>:d   acc0.0<1;1,0>:d   63:w              
(f0.0)  goto (8|M0)                          L24056                  L24056                
L24024:
        mov (8|M0)               r17.0<1>:d    r99.0<1;1,0>:d                  
        goto (8|M0)                          L24056                  L24192                
L24056:
        join (8|M0)                          L24192                                
L24072:
        cmp (8|M0)    (lt)f1.1   null<1>:ud    r103.0<1;1,0>:ud  0x20:uw              {I@5}
(f1.1)  add (8|M0)               acc0.0<1>:d   -r103.0<1;1,0>:d  32:w              
(~f1.1) add (8|M0)               acc2.0<1>:d   r103.0<1;1,0>:d   -32:w              
(f1.1)  shr (8|M0)               r119.0<1>:ud  r99.0<1;1,0>:ud   r103.0<1;1,0>:d 
(f1.1)  shl (8|M0)               r13.0<1>:d    r108.0<1;1,0>:d   acc0.0<1;1,0>:d 
(~f1.1) shr (8|M0)               r91.0<1>:ud   r108.0<1;1,0>:ud  acc2.0<1;1,0>:d  {F@2}
(f1.1)  or (8|M0)                r91.0<1>:d    r119.0<1;1,0>:d   r13.0<1;1,0>:d   {I@2}
        mov (8|M0)               r17.0<1>:f    r91.0<1;1,0>:f                   {Compacted,I@1}
L24192:
        join (8|M0)                          L24840                                
L24208:
        add3 (8|M0)              r101.0<1>:d   r72.0<1;0>:d      -r16.0<1;0>:d     -2:w              
        and (8|M0)    (ne)f1.0   r102.0<1>:d   r101.0<1;1,0>:d   63:w               {I@1}
(f1.0)  goto (8|M0)                          L24288                  L24288                
L24256:
        mov (8|M0)               r91.0<1>:d    r99.0<1;1,0>:d                   {F@1}
        goto (8|M0)                          L24288                  L24416                
L24288:
        join (8|M0)                          L24416                                
L24304:
        cmp (8|M0)    (lt)f0.1   null<1>:ud    r102.0<1;1,0>:ud  0x20:uw              {I@5}
(f0.1)  add (8|M0)               acc0.0<1>:d   -r102.0<1;1,0>:d  32:w              
(~f0.1) add (8|M0)               acc2.0<1>:d   r102.0<1;1,0>:d   -32:w              
(f0.1)  shr (8|M0)               r117.0<1>:ud  r99.0<1;1,0>:ud   r102.0<1;1,0>:d 
(f0.1)  shl (8|M0)               r12.0<1>:d    r108.0<1;1,0>:d   acc0.0<1;1,0>:d 
(~f0.1) shr (8|M0)               r91.0<1>:ud   r108.0<1;1,0>:ud  acc2.0<1;1,0>:d 
(f0.1)  or (8|M0)                r91.0<1>:d    r117.0<1;1,0>:d   r12.0<1;1,0>:d   {I@2}
L24416:
        join (8|M0)                          L24840                                
L24432:
        and (8|M0)    (ne)f0.0   r11.0<1>:d    r101.0<1;1,0>:d   63:w              
        and (8|M0)               r32.0<1>:d    r91.0<1;1,0>:d    1:w               {Compacted,I@3}
(f0.0)  goto (8|M0)                          L24520                  L24520                
L24472:
        mov (8|M0)               r36.0<1>:d    -1:w                              
        mov (8|M0)               r59.0<1>:d    -1:w                              
        goto (8|M0)                          L24520                  L24704                
L24520:
        join (8|M0)                          L24704                                
L24536:
        cmp (8|M0)    (lt)f1.1   null<1>:ud    r11.0<1;1,0>:ud   0x20:uw              {I@7}
(f1.1)  goto (8|M0)                          L24640                  L24640                
L24568:
        add (8|M0)               acc0.0<1>:d   r11.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r6.8<1>:hf    -qnan(0x1FF):hf                             
        mov (8|M0)               r36.0<1>:d    0:w                              
        shl (8|M0)               r59.0<1>:d    r6.8<0;1,0>:w     acc0.0<1;1,0>:d  {F@1}
        goto (8|M0)                          L24640                  L24704                
L24640:
        join (8|M0)                          L24704                                
L24656:
(W)     mov (1|M0)               r6.8<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (8|M0)               r59.0<1>:d    -1:w                              
        shl (8|M0)               r36.0<1>:d    r6.8<0;1,0>:w     r11.0<1;1,0>:d   {F@1}
L24704:
        join (8|M0)                          L24840                                
L24720:
        bfn.0x28 (8|M0)          r116.0<1>:ud  r99.0<1;0>:ud     r36.0<1;0>:ud     r6.3<0>:ud       {I@2} // s0&(s1^s2)
        bfn.0x28 (8|M0)          r115.0<1>:ud  r108.0<1;0>:ud    r59.0<1;0>:ud     r6.3<0>:ud       // s0&(s1^s2)
        cmp (8|M0)    (ne)f1.0   null<1>:d     r116.0<1;1,0>:d   0:w               {I@2}
(W)     mov (1|M0)               r6.8<1>:hf    -qnan(0x1FF):hf                             
        mov (8|M0)               r110.0<1>:f   r17.0<1;1,0>:f                   {Compacted}
(~f1.0) cmp (8|M0)    (ne)f1.0   null<1>:d     r115.0<1;1,0>:d   0:w               {I@2}
(f1.0)  sel (8|M0)               acc0.0<1>:d   r6.8<0;1,0>:w     0:w               {F@2}
        mov (8|M0)               r127.0<1>:d   -acc0.0<1;1,0>:d                
L24840:
        join (8|M0)                          L25400                                
L24856:
        and (8|M0)    (ne)f1.0   r101.0<1>:d   r81.0<1;1,0>:d    63:w              
(f1.0)  goto (8|M0)                          L24920                  L24920                
L24888:
        mov (8|M0)               r91.0<1>:d    r99.0<1;1,0>:d                  
        goto (8|M0)                          L24920                  L25048                
L24920:
        join (8|M0)                          L25048                                
L24936:
        cmp (8|M0)    (lt)f0.1   null<1>:ud    r101.0<1;1,0>:ud  0x20:uw              {I@5}
(f0.1)  add (8|M0)               acc0.0<1>:d   -r101.0<1;1,0>:d  32:w              
(~f0.1) add (8|M0)               acc2.0<1>:d   r101.0<1;1,0>:d   -32:w              
(f0.1)  shr (8|M0)               r112.0<1>:ud  r99.0<1;1,0>:ud   r101.0<1;1,0>:d 
(f0.1)  shl (8|M0)               r10.0<1>:d    r108.0<1;1,0>:d   acc0.0<1;1,0>:d 
(~f0.1) shr (8|M0)               r91.0<1>:ud   r108.0<1;1,0>:ud  acc2.0<1;1,0>:d 
(f0.1)  or (8|M0)                r91.0<1>:d    r112.0<1;1,0>:d   r10.0<1;1,0>:d   {I@2}
L25048:
        join (8|M0)                          L25400                                
L25064:
        shl (8|M0)               r78.0<1>:d    r110.0<1;1,0>:d   2:w               {Compacted,F@1}
        shl (8|M0)               r111.0<1>:d   r32.0<1;1,0>:d    1:w               {Compacted}
        and (8|M0)               r78.0<1>:d    r78.0<1;1,0>:d    4:w               {Compacted,I@2}
        bfn.0xFE (8|M0)          r46.0<1>:ud   r78.0<1;0>:ud     r111.0<1;0>:ud    r127.0<1>:ud     {I@1} // s0|s1|s2
        cmp (8|M0)    (eq)f0.0   null<1>:d     r46.0<1;1,0>:d    0:w               {Compacted,I@1}
(~f0.0) goto (8|M0)                          L25160                  L25160                
L25128:
        mov (8|M0)               r50.0<1>:d    0:w                              
        goto (8|M0)                          L25160                  L25320                
L25160:
        join (8|M0)                          L25320                                
L25176:
        cmp (8|M0)    (gt)f1.1   null<1>:ud    r46.0<1;1,0>:ud   0x4:uw             
(~f1.1) goto (8|M0)                          L25240                  L25240                
L25208:
        mov (8|M0)               r50.0<1>:d    1:w                              
        goto (8|M0)                          L25240                  L25320                
L25240:
        join (8|M0)                          L25320                                
L25256:
        and (8|M0)    (ne)f0.1   null<1>:d     r91.0<1;1,0>:d    1:w              
(W)     mov (1|M0)               r6.8<1>:hf    0x1:hf                             
(f0.1)  cmp (8|M0)    (eq)f0.1   null<1>:d     r46.0<1;1,0>:d    4:w              
(f0.1)  sel (8|M0)               r50.0<1>:d    r6.8<0;1,0>:w     0:w               {F@1}
L25320:
        join (8|M0)                          L25400                                
L25336:
        add (8|M0)               r37.0<1>:d    r50.0<1;1,0>:d    r91.0<1;1,0>:d   {Compacted,I@2}
(W)     mov (1|M0)               r6.4<1>:f     0x800000:f                               {Compacted}
        cmp (8|M0)    (gt)f0.0   null<1>:ud    r37.0<1;1,0>:ud   0x7FFFFF:ud              {I@1}
(~f0.0) sel (8|M0)               r79.0<1>:d    r37.0<1;1,0>:d    0:w              
(f0.0)  sel (8|M0)               r78.0<1>:d    r6.4<0;1,0>:d     0:w               {F@1}
L25400:
        join (8|M0)                          L25464                                
L25416:
        and (8|M0)               r110.0<1>:d   r15.0<1;1,0>:d    -2147483648:d              
        bfn.0xFE (8|M0)          r117.0<1>:ud  r110.0<1;0>:ud    r78.0<1;0>:ud     r79.0<1>:ud      {I@1} // s0|s1|s2
        goto (8|M0)                          L25464                  L28664                
L25464:
        join (8|M0)                          L25984                                
L25480:
        and (8|M0)    (ne)f1.0   r92.0<1>:d    r38.0<1;1,0>:d    63:w              
(f1.0)  goto (8|M0)                          L25560                  L25560                
L25512:
        mov (8|M0)               r110.0<1>:d   -1:w                              
        mov (8|M0)               r9.0<1>:d     -1:w                              
        goto (8|M0)                          L25560                  L25744                
L25560:
        join (8|M0)                          L25744                                
L25576:
        cmp (8|M0)    (lt)f0.1   null<1>:ud    r92.0<1;1,0>:ud   0x20:uw              {I@6}
(f0.1)  goto (8|M0)                          L25680                  L25680                
L25608:
        add (8|M0)               acc0.0<1>:d   r92.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r6.8<1>:hf    -qnan(0x1FF):hf                             
        mov (8|M0)               r110.0<1>:d   0:w                              
        shl (8|M0)               r9.0<1>:d     r6.8<0;1,0>:w     acc0.0<1;1,0>:d  {F@1}
        goto (8|M0)                          L25680                  L25744                
L25680:
        join (8|M0)                          L25744                                
L25696:
(W)     mov (1|M0)               r6.8<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (8|M0)               r9.0<1>:d     -1:w                              
        shl (8|M0)               r110.0<1>:d   r6.8<0;1,0>:w     r92.0<1;1,0>:d   {F@1}
L25744:
        join (8|M0)                          L25984                                
L25760:
        bfn.0x28 (8|M0)          r109.0<1>:ud  r99.0<1;0>:ud     r110.0<1;0>:ud    r6.3<0>:ud       {I@2} // s0&(s1^s2)
        bfn.0x28 (8|M0)          r108.0<1>:ud  r108.0<1;0>:ud    r9.0<1;0>:ud      r6.3<0>:ud       // s0&(s1^s2)
        cmp (8|M0)    (ne)f1.1   null<1>:d     r109.0<1;1,0>:d   0:w               {I@2}
        cmp (8|M0)    (gt)f0.0   null<1>:d     r15.0<1;1,0>:d    -1:w              
(~f1.1) cmp (8|M0)    (ne)f1.1   null<1>:d     r108.0<1;1,0>:d   0:w               {I@3}
(f1.1)  cmp (8|M0)    (eq)f1.1   null<1>:d     r60.0<1;1,0>:d    -150:w              
(f0.0)  goto (8|M0)                          L25920                  L25920                
L25872:
(W)     mov (1|M0)               r6.4<1>:ud    0x80000001:ud                             
(f1.1)  sel (8|M0)               r117.0<1>:f   r6.4<0;1,0>:f     -0.0:f               {I@1}
        goto (8|M0)                          L25920                  L28664                
L25920:
        join (8|M0)                          L25984                                
L25936:
(W)     mov (1|M0)               r6.4<1>:ud    0x1:ud                              {F@1}
(f1.1)  sel (8|M0)               r117.0<1>:f   r6.4<0;1,0>:f     0.0:f               {I@1}
        goto (8|M0)                          L25984                  L28664                
L25984:
        join (8|M0)                          L28416                                
L26000:
        cmp (8|M0)    (lt)f0.0   null<1>:ud    r38.0<1;1,0>:ud   0x18:uw             
        add3 (8|M0)              r36.0<1>:d    r25.0<1;0>:d      r38.0<1;0>:d      81:w              
(f0.0)  cmp (8|M0)    (eq)f0.0   null<1>:d     r26.0<1;1,0>:d    0:w              
(f0.0)  goto (8|M0)                          L28096                  L28096                
L26064:
        shl (8|M0)               r104.0<1>:d   r21.0<1;1,0>:d    1:w               {Compacted}
        shr (8|M0)               r103.0<1>:ud  r21.0<1;1,0>:ud   31:w              
        shl (8|M0)               r14.0<1>:d    r79.0<1;1,0>:d    1:w               {Compacted}
        cmp (8|M0)    (lt)f1.1   null<1>:ud    r104.0<1;1,0>:ud  0x4E:uw              {A@1}
        or (8|M0)                r14.0<1>:d    r14.0<1;1,0>:d    r103.0<1;1,0>:d  {Compacted,I@2}
(f1.1)  cmp (8|M0)    (eq)f1.1   null<1>:d     r14.0<1;1,0>:d    0:w               {I@1}
(~f1.1) cmp (8|M0)    (lt)f1.1   null<1>:d     r14.0<1;1,0>:d    0:w              
(f1.1)  goto (8|M0)                          L26296                  L26296                
L26168:
        cmp (8|M0)    (eq)f1.1   null<1>:d     r21.0<1;1,0>:d    39:w              
(f1.1)  cmp (8|M0)    (eq)f1.1   null<1>:d     r79.0<1;1,0>:d    0:w              
(~f1.1) goto (8|M0)                          L26296                  L26360                
L26216:
        shr (8|M0)               r91.0<1>:ud   r99.0<1;1,0>:ud   1:w              
        mov (8|M0)               r23.0<1>:d    0:w                              
        mov (8|M0)               r40.0<1>:d    0:w                              
        mov (8|M0)               r39.0<1>:f    r91.0<1;1,0>:f                   {Compacted,I@3}
        mov (8|M0)               r91.0<1>:f    r99.0<1;1,0>:f                   {Compacted}
        goto (8|M0)                          L26296                  L27552                
L26296:
        join (8|M0)                          L26360                                
L26312:
        cmp (8|M0)    (eq)f1.0   null<1>:d     r21.0<1;1,0>:d    38:w              
(f1.0)  cmp (8|M0)    (eq)f1.0   null<1>:d     r79.0<1;1,0>:d    0:w              
(f1.0)  goto (8|M0)                          L26360                  L27472                
L26360:
        join (8|M0)                          L27472                                
L26376:
        add (8|M0)               acc0.0<1>:d   -r21.0<1;1,0>:d   39:w               {Compacted}
        add (8|M0)               r32.0<1>:d    -r21.0<1;1,0>:d   40:w               {Compacted}
        and (8|M0)    (ne)f1.1   r121.0<1>:d   acc0.0<1;1,0>:d   63:w              
(f1.1)  goto (8|M0)                          L26456                  L26456                
L26424:
        mov (8|M0)               r26.0<1>:d    r99.0<1;1,0>:d                  
        goto (8|M0)                          L26456                  L26592                
L26456:
        join (8|M0)                          L26592                                
L26472:
        cmp (8|M0)    (lt)f1.0   null<1>:ud    r121.0<1;1,0>:ud  0x20:uw              {I@5}
(f1.0)  add (8|M0)               acc0.0<1>:d   -r121.0<1;1,0>:d  32:w              
(~f1.0) add (8|M0)               acc2.0<1>:d   r121.0<1;1,0>:d   -32:w              
(f1.0)  shr (8|M0)               r105.0<1>:ud  r99.0<1;1,0>:ud   r121.0<1;1,0>:d 
(f1.0)  shl (8|M0)               r58.0<1>:d    r108.0<1;1,0>:d   acc0.0<1;1,0>:d 
(~f1.0) shr (8|M0)               r91.0<1>:ud   r108.0<1;1,0>:ud  acc2.0<1;1,0>:d  {F@1}
(f1.0)  or (8|M0)                r91.0<1>:d    r105.0<1;1,0>:d   r58.0<1;1,0>:d   {I@2}
        mov (8|M0)               r26.0<1>:f    r91.0<1;1,0>:f                   {Compacted,I@1}
L26592:
        join (8|M0)                          L27472                                
L26608:
        add (8|M0)               r117.0<1>:d   -r21.0<1;1,0>:d   38:w               {Compacted}
        and (8|M0)    (ne)f0.1   r13.0<1>:d    r117.0<1;1,0>:d   63:w               {I@1}
(f0.1)  goto (8|M0)                          L26680                  L26680                
L26648:
        mov (8|M0)               r91.0<1>:d    r99.0<1;1,0>:d                   {F@1}
        goto (8|M0)                          L26680                  L26808                
L26680:
        join (8|M0)                          L26808                                
L26696:
        cmp (8|M0)    (lt)f0.0   null<1>:ud    r13.0<1;1,0>:ud   0x20:uw              {I@5}
(f0.0)  add (8|M0)               acc0.0<1>:d   -r13.0<1;1,0>:d   32:w              
(~f0.0) add (8|M0)               acc2.0<1>:d   r13.0<1;1,0>:d    -32:w              
(f0.0)  shr (8|M0)               r103.0<1>:ud  r99.0<1;1,0>:ud   r13.0<1;1,0>:d  
(f0.0)  shl (8|M0)               r75.0<1>:d    r108.0<1;1,0>:d   acc0.0<1;1,0>:d 
(~f0.0) shr (8|M0)               r91.0<1>:ud   r108.0<1;1,0>:ud  acc2.0<1;1,0>:d 
(f0.0)  or (8|M0)                r91.0<1>:d    r103.0<1;1,0>:d   r75.0<1;1,0>:d   {I@2}
L26808:
        join (8|M0)                          L27472                                
L26824:
        and (8|M0)    (ne)f1.1   r74.0<1>:d    r117.0<1;1,0>:d   63:w              
        and (8|M0)               r40.0<1>:d    r91.0<1;1,0>:d    1:w               {Compacted,I@3}
(f1.1)  goto (8|M0)                          L26912                  L26912                
L26864:
        mov (8|M0)               r86.0<1>:d    -1:w                              
        mov (8|M0)               r100.0<1>:d   -1:w                              
        goto (8|M0)                          L26912                  L27096                
L26912:
        join (8|M0)                          L27096                                
L26928:
        cmp (8|M0)    (lt)f1.0   null<1>:ud    r74.0<1;1,0>:ud   0x20:uw              {I@7}
(f1.0)  goto (8|M0)                          L27032                  L27032                
L26960:
        add (8|M0)               acc0.0<1>:d   r74.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r6.8<1>:hf    -qnan(0x1FF):hf                             
        mov (8|M0)               r86.0<1>:d    0:w                              
        shl (8|M0)               r100.0<1>:d   r6.8<0;1,0>:w     acc0.0<1;1,0>:d  {F@1}
        goto (8|M0)                          L27032                  L27096                
L27032:
        join (8|M0)                          L27096                                
L27048:
(W)     mov (1|M0)               r6.8<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (8|M0)               r100.0<1>:d   -1:w                              
        shl (8|M0)               r86.0<1>:d    r6.8<0;1,0>:w     r74.0<1;1,0>:d   {F@1}
L27096:
        join (8|M0)                          L27472                                
L27112:
        bfn.0x28 (8|M0)          r102.0<1>:ud  r99.0<1;0>:ud     r86.0<1;0>:ud     r6.3<0>:ud       {I@2} // s0&(s1^s2)
        bfn.0x28 (8|M0)          r101.0<1>:ud  r108.0<1;0>:ud    r100.0<1;0>:ud    r6.3<0>:ud       // s0&(s1^s2)
        cmp (8|M0)    (ne)f0.1   null<1>:d     r102.0<1;1,0>:d   0:w               {I@2}
(W)     mov (1|M0)               r6.8<1>:hf    -qnan(0x1FF):hf                             
(~f0.1) cmp (8|M0)    (ne)f0.1   null<1>:d     r101.0<1;1,0>:d   0:w               {I@2}
(f0.1)  sel (8|M0)               acc0.0<1>:d   r6.8<0;1,0>:w     0:w               {F@1}
        and (8|M0)    (ne)f0.1   r12.0<1>:d    r32.0<1;1,0>:d    63:w              
        mov (8|M0)               r23.0<1>:d    -acc0.0<1;1,0>:d                
(f0.1)  goto (8|M0)                          L27288                  L27288                
L27256:
        mov (8|M0)               r91.0<1>:d    r99.0<1;1,0>:d                  
        goto (8|M0)                          L27288                  L27416                
L27288:
        join (8|M0)                          L27416                                
L27304:
        cmp (8|M0)    (lt)f0.0   null<1>:ud    r12.0<1;1,0>:ud   0x20:uw              {I@6}
(~f0.0) add (8|M0)               acc0.0<1>:d   r12.0<1;1,0>:d    -32:w              
(f0.0)  add (8|M0)               acc2.0<1>:d   -r12.0<1;1,0>:d   32:w              
(f0.0)  shr (8|M0)               r98.0<1>:ud   r99.0<1;1,0>:ud   r12.0<1;1,0>:d  
(f0.0)  shl (8|M0)               r73.0<1>:d    r108.0<1;1,0>:d   acc2.0<1;1,0>:d 
(~f0.0) shr (8|M0)               r91.0<1>:ud   r108.0<1;1,0>:ud  acc0.0<1;1,0>:d 
(f0.0)  or (8|M0)                r91.0<1>:d    r98.0<1;1,0>:d    r73.0<1;1,0>:d   {I@2}
L27416:
        join (8|M0)                          L27472                                
L27432:
        mov (8|M0)               r39.0<1>:f    r91.0<1;1,0>:f                   {Compacted,I@2}
        mov (8|M0)               r91.0<1>:d    r26.0<1;1,0>:d                   {F@1}
        goto (8|M0)                          L27472                  L27552                
L27472:
        join (8|M0)                          L27552                                
L27488:
        shr (8|M0)               r91.0<1>:ud   r99.0<1;1,0>:ud   2:w              
        and (8|M0)               r40.0<1>:d    r99.0<1;1,0>:d    1:w               {Compacted}
        mov (8|M0)               r23.0<1>:d    0:w                              
        mov (8|M0)               r39.0<1>:f    r91.0<1;1,0>:f                   {Compacted,I@3}
        shr (8|M0)               r91.0<1>:ud   r99.0<1;1,0>:ud   1:w               {F@1}
L27552:
        join (8|M0)                          L28096                                
L27568:
        shl (8|M0)               r35.0<1>:d    r91.0<1;1,0>:d    2:w               {Compacted,I@2}
        shl (8|M0)               r97.0<1>:d    r40.0<1;1,0>:d    1:w               {Compacted}
        and (8|M0)               r35.0<1>:d    r35.0<1;1,0>:d    4:w               {Compacted,I@2}
        and (8|M0)               r123.0<1>:d   r39.0<1;1,0>:d    8388607:d              
        bfn.0xFE (8|M0)          r91.0<1>:ud   r35.0<1;0>:ud     r97.0<1;0>:ud     r23.0<1>:ud      {I@2} // s0|s1|s2
        cmp (8|M0)    (eq)f1.1   null<1>:d     r91.0<1;1,0>:d    0:w               {I@1}
(~f1.1) goto (8|M0)                          L27688                  L27688                
L27656:
        mov (8|M0)               r90.0<1>:d    0:w                              
        goto (8|M0)                          L27688                  L27848                
L27688:
        join (8|M0)                          L27848                                
L27704:
        cmp (8|M0)    (gt)f1.0   null<1>:ud    r91.0<1;1,0>:ud   0x4:uw             
(~f1.0) goto (8|M0)                          L27768                  L27768                
L27736:
        mov (8|M0)               r90.0<1>:d    1:w                              
        goto (8|M0)                          L27768                  L27848                
L27768:
        join (8|M0)                          L27848                                
L27784:
        and (8|M0)    (ne)f0.0   null<1>:d     r39.0<1;1,0>:d    1:w              
(W)     mov (1|M0)               r6.8<1>:hf    0x1:hf                             
(f0.0)  cmp (8|M0)    (eq)f0.0   null<1>:d     r91.0<1;1,0>:d    4:w              
(f0.0)  sel (8|M0)               r90.0<1>:d    r6.8<0;1,0>:w     0:w               {F@1}
L27848:
        join (8|M0)                          L28096                                
L27864:
        add (8|M0)               r66.0<1>:d    r123.0<1;1,0>:d   r90.0<1;1,0>:d   {Compacted,I@2}
        add3 (8|M0)              r55.0<1>:d    r25.0<1;0>:d      r38.0<1;0>:d      82:w              
        cmp (8|M0)    (gt)f1.1   null<1>:ud    r66.0<1;1,0>:ud   0x7FFFFF:ud              {I@2}
(f1.1)  sel (8|M0)               r51.0<1>:d    r55.0<1;1,0>:d    r36.0<1;1,0>:d   {I@2}
        cmp (8|M0)    (eq)f0.1   null<1>:d     r51.0<1;1,0>:d    255:w               {I@1}
(f0.1)  goto (8|M0)                          L28024                  L28024                
L27952:
(~f1.1) sel (8|M0)               r61.0<1>:d    r66.0<1;1,0>:d    0:w              
        and (8|M0)               r54.0<1>:d    r15.0<1;1,0>:d    -2147483648:d              
        shl (8|M0)               r96.0<1>:d    r51.0<1;1,0>:d    23:w               {Compacted}
        bfn.0xFE (8|M0)          r117.0<1>:ud  r54.0<1;0>:ud     r96.0<1;0>:ud     r61.0<1>:ud      {I@1} // s0|s1|s2
        goto (8|M0)                          L28024                  L28664                
L28024:
        join (8|M0)                          L28096                                
L28040:
        cmp (8|M0)    (gt)f1.1   null<1>:d     r15.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r6.4<1>:f     inf:f                               {Compacted}
(f1.1)  sel (8|M0)               r117.0<1>:f   r6.4<0;1,0>:f     -inf:f               {A@1}
        goto (8|M0)                          L28096                  L28664                
L28096:
        join (8|M0)                          L28416                                
L28112:
        and (8|M0)    (ne)f0.0   r55.0<1>:d    r38.0<1;1,0>:d    63:w              
(f0.0)  goto (8|M0)                          L28176                  L28176                
L28144:
        mov (8|M0)               r77.0<1>:d    -1:w                              
        goto (8|M0)                          L28176                  L28304                
L28176:
        join (8|M0)                          L28304                                
L28192:
        cmp (8|M0)    (lt)f1.1   null<1>:ud    r55.0<1;1,0>:ud   0x20:uw              {A@1}
(f1.1)  goto (8|M0)                          L28256                  L28256                
L28224:
        mov (8|M0)               r77.0<1>:d    0:w                              
        goto (8|M0)                          L28256                  L28304                
L28256:
        join (8|M0)                          L28304                                
L28272:
(W)     mov (1|M0)               r6.8<1>:hf    -qnan(0x1FF):hf                             
        shl (8|M0)               r77.0<1>:d    r6.8<0;1,0>:w     r55.0<1;1,0>:d   {F@1}
L28304:
        join (8|M0)                          L28416                                
L28320:
        bfn.0x28 (8|M0)          r89.0<1>:ud   r99.0<1;0>:ud     r77.0<1;0>:ud     r6.3<0>:ud       {I@2} // s0&(s1^s2)
        add (8|M0)               acc0.0<1>:d   -r38.0<1;1,0>:d   23:w               {Compacted}
        and (8|M0)               r53.0<1>:d    r15.0<1;1,0>:d    -2147483648:d              
        shl (8|M0)               r94.0<1>:d    r36.0<1;1,0>:d    23:w               {Compacted}
        shl (8|M0)               r89.0<1>:d    r89.0<1;1,0>:d    acc0.0<1;1,0>:d  {I@4}
        bfn.0xFE (8|M0)          r117.0<1>:ud  r53.0<1;0>:ud     r94.0<1;0>:ud     r89.0<1>:ud      {I@1} // s0|s1|s2
        goto (8|M0)                          L28416                  L28664                
L28416:
        join (8|M0)                          L28488                                
L28432:
        cmp (8|M0)    (gt)f1.0   null<1>:d     r15.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r6.4<1>:f     inf:f                               {Compacted}
(f1.0)  sel (8|M0)               r117.0<1>:f   r6.4<0;1,0>:f     -inf:f               {A@1}
        goto (8|M0)                          L28488                  L28664                
L28488:
        join (8|M0)                          L28560                                
L28504:
        cmp (8|M0)    (lt)f0.1   null<1>:d     r15.0<1;1,0>:d    0:w              
(W)     mov (1|M0)               r6.4<1>:f     -0.0:f                               {Compacted}
(f0.1)  sel (8|M0)               r117.0<1>:f   r6.4<0;1,0>:f     0.0:f               {F@1}
        goto (8|M0)                          L28560                  L28664                
L28560:
        join (8|M0)                          L28632                                
L28576:
        cmp (8|M0)    (gt)f0.0   null<1>:d     r15.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r6.4<1>:f     inf:f                               {Compacted}
(f0.0)  sel (8|M0)               r117.0<1>:f   r6.4<0;1,0>:f     -inf:f               {F@1}
        goto (8|M0)                          L28632                  L28664                
L28632:
        join (8|M0)                          L28664                                
L28648:
        bfn.0xF8 (8|M0)          r117.0<1>:ud  r15.0<1;0>:ud     r6.1<0;0>:ud      r6.0<0>:ud       {F@1} // s0&s1|s2
L28664:
        join (8|M0)                          L28712                                
L28680:
        mov (8|M0)               r8.0<1>:hf    r117.0<1;1,0>:f                  {I@2}
        mov (8|M0)               r7.0<1>:f     r8.0<1;1,0>:hf                   {F@1}
L28712:
        join (8|M0)                          L28728                                
L28728:
(W)     and (1|M0)               r6.4<1>:d     r5.7<0;1,0>:d     -3:w              
(W)     cmp (8|M0)    (eq)f1.0   null<1>:d     r6.4<0;1,0>:d     1:w               {I@1}
(f1.0)  goto (8|M0)                          L28856                  L28856                
L28776:
        mov (8|M0)               r8.0<1>:hf    r7.0<1;1,0>:f                    {F@1}
(W)     cmp (8|M0)    (eq)f1.1   null<1>:d     r5.7<0;1,0>:d     4:w              
        mov (8|M0)               acc0.0<1>:f   r8.0<1;1,0>:hf                   {F@1}
(f1.1)  sel (8|M0)               r124.0<1>:f   acc0.0<1;1,0>:f   r7.0<1;1,0>:f   
        goto (8|M0)                          L28856                  L41560                
L28856:
        join (8|M0)                          L41560                                
L28872:
        and (8|M0)               r92.0<1>:d    r7.0<1;1,0>:d     2147483647:d              
        sel (8|M0)    (lt)f0.0   r88.0<1>:f    r92.0<1;1,0>:f    448.0:f               {Compacted,I@1}
        shr (8|M0)               r96.0<1>:ud   r88.0<1;1,0>:ud   23:w               {F@1}
        and (8|M0)    (ne)f1.1   r72.0<1>:d    r88.0<1;1,0>:d    8388607:d              
        and (8|M0)               r49.0<1>:d    r96.0<1;1,0>:d    255:w               {Compacted,I@2}
        sel (8|M0)    (ge)f0.0   r91.0<1>:ud   r49.0<1;1,0>:ud   0x79:uw              {I@1}
(f1.1)  cmp (8|M0)    (eq)f1.1   null<1>:d     r49.0<1;1,0>:d    255:w              
        shl (8|M0)               r13.0<1>:d    r91.0<1;1,0>:d    23:w               {Compacted,I@2}
(~f1.1) goto (8|M0)                          L29016                  L29016                
L28992:
        mov (8|M0)               r118.0<1>:f   qnan(0x0):f                               {Compacted}
        goto (8|M0)                          L29016                  L35192                
L29016:
        join (8|M0)                          L35192                                
L29032:
        cmp (8|M0)    (eq)f1.0   null<1>:d     r72.0<1;1,0>:d    0:w              
        add (8|M0)               r65.0<1>:d    -r13.0<1;1,0>:d   -2139095040:d               {I@5}
        xor (8|M0)               r16.0<1>:d    r65.0<1;1,0>:d    r88.0<1;1,0>:d   {Compacted,I@1}
(f1.0)  cmp (8|M0)    (eq)f1.0   null<1>:d     r49.0<1;1,0>:d    255:w              
(f1.0)  goto (8|M0)                          L35160                  L35160                
L29104:
        or (8|M0)     (eq)f0.1   null<1>:d     r49.0<1;1,0>:d    r72.0<1;1,0>:d  
(~f0.1) goto (8|M0)                          L29160                  L29160                
L29136:
        mov (8|M0)               r118.0<1>:f   0.0:f                               {Compacted}
        goto (8|M0)                          L29160                  L35192                
L29160:
        join (8|M0)                          L35160                                
L29176:
        cmp (8|M0)    (eq)f0.1   null<1>:d     r49.0<1;1,0>:d    0:w              
        shr (8|M0)               r48.0<1>:ud   r65.0<1;1,0>:ud   23:w              
        add (8|M0)               r119.0<1>:d   r49.0<1;1,0>:d    -127:w               {Compacted}
(f0.1)  mov (8|M0)               r119.0<1>:d   -126:w                              
        add (8|M0)               r21.0<1>:d    r48.0<1;1,0>:d    r119.0<1;1,0>:d  {Compacted,I@1}
        cmp (8|M0)    (gt)f0.0   null<1>:d     r21.0<1;1,0>:d    254:w               {I@1}
(f0.0)  goto (8|M0)                          L35088                  L35088                
L29272:
        or (8|M0)     (eq)f1.1   null<4>:b     r96.0<1;1,0>:d    r48.0<1;1,0>:d  
(f1.1)  goto (8|M0)                          L35024                  L35024                
L29304:
(W)     mov (1|M0)               r5.0<1>:hf    0.0:hf                             
(W)     mov (1|M0)               r6.5<1>:d     0:w                              
(f0.1)  sel (8|M0)               acc0.0<1>:d   r5.0<0;1,0>:w     8388608:d               {F@1}
(W)     mov (1|M0)               r6.4<1>:f     -0.0:f                               {Compacted}
        or (8|M0)                r100.0<1>:d   acc0.0<1;1,0>:d   r72.0<1;1,0>:d  
(W)     mov (2|M0)               r5.4<1>:d     0:w                              
        shl (8|M0)               r102.0<1>:d   r100.0<1;1,0>:d   23:w               {Compacted,I@2}
        shr (8|M0)               r110.0<1>:ud  r100.0<1;1,0>:ud  9:w              
L29416:
(W)     shl (1|M0)               r8.0<1>:d     r6.4<0;1,0>:d     31:w               {Compacted,F@1}
(W)     shr (1|M0)               r6.7<1>:ud    r6.5<0;1,0>:ud    1:w              
(W)     cmp (8|M0)    (gt)f0.0   null<1>:ud    r5.4<0;1,0>:ud    0x3E:uw              {I@5}
(W)     or (1|M0)                r6.5<1>:d     r6.7<0;1,0>:d     r8.0<0;1,0>:d    {I@2}
        bfn.0xE0 (8|M0)          r32.0<1>:ud   r6.7<0;0>:ud      r8.0<0;0>:ud      r102.0<1>:ud     // (s0|s1)&s2
(W)     shr (1|M0)               r5.7<1>:ud    r6.4<0;1,0>:ud    1:w              
(W&f0.0) cmp (8|M0)   (eq)f0.0   null<1>:d     r5.5<0;1,0>:d     0:w              
        cmp (8|M0)    (eq)f1.1   null<1>:d     r32.0<1;1,0>:d    r6.5<0;1,0>:d    {I@3}
        and (8|M0)               r31.0<1>:d    r5.7<0;1,0>:d     r110.0<1;1,0>:d  {Compacted,I@3}
(W)     addc (1|M0)              r9.0<1>:ud    r5.4<0;1,0>:ud    0x1:ud              {AccWrEn}
(W&~f0.0) cmp (8|M0)  (gt)f0.0   null<1>:ud    r5.5<0;1,0>:ud    0x0:uw             
(f1.1)  cmp (8|M0)    (eq)f1.1   null<1>:d     r31.0<1;1,0>:d    r5.7<0;1,0>:d    {I@3}
(W)     mov (1|M0)               r6.14<1>:hf   0x1:hf                             
(W)     mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
(f0.0)  sel (8|M0)               r8.0<1>:uw    r6.14<0;1,0>:uw   0x0:uw              {F@1}
(W)     add (1|M0)               r8.4<1>:ud    r5.0<0;1,0>:ud    r5.5<0;1,0>:ud   {I@2}
(f1.1)  sel (8|M0)               r5.0<1>:uw    r6.14<0;1,0>:uw   0x0:uw             
        mov (8|M0)               r118.0<1>:d   r5.4<0;1,0>:d                   
        or (8|M0)     (ne)f0.0   null<1>:uw    r8.0<1;1,0>:uw    r5.0<1;1,0>:uw   {I@2}
        mov (8|M0)               r125.0<1>:d   r5.5<0;1,0>:d                   
        mov (8|M0)               r22.0<1>:f    r9.0<0;1,0>:f                    {Compacted}
        mov (8|M0)               r82.0<1>:d    r8.4<0;1,0>:d                   
(f0.0)  goto (8|M0)                          L29816                  L29816                
L29752:
(W)     mov (1|M0)               r6.4<1>:d     r5.7<0;1,0>:d                   
(W)     mov (1|M0)               r5.4<1>:d     r9.0<0;1,0>:d                   
(W)     mov (1|M0)               r5.5<1>:d     r8.4<0;1,0>:d                   
(W)     jmpi                                 L29416                                
L29816:
        join (8|M0)                          L35024                                
L29832:
(W)     mov (1|M0)               r5.0<1>:f     8.68805e-44:f                               {I@7}
        subb (8|M0)              r47.0<1>:ud   r5.0<0;1,0>:ud    r118.0<1;1,0>:ud {AccWrEn,Compacted,F@1}
(W)     mov (1|M0)               r5.0<1>:hf    0.0:hf                              {I@1}
        add3 (8|M0)              r61.0<1>:d    r21.0<1;0>:d      r47.0<1;0>:d      -173:w              
        add3 (8|M0)              r8.0<1>:d     r48.0<1;0>:d      r119.0<1;0>:d     r47.0<1>:d      
        cmp (8|M0)    (gt)f1.0   null<1>:d     r61.0<1;1,0>:d    127:w               {I@2}
        add3 (8|M0)              r27.0<1>:ud   -acc0.0<1;0>:ud   r5.0<0;0>:uw      -r125.0<1>:ud    {F@1}
(f1.0)  goto (8|M0)                          L34952                  L34952                
L29952:
        cmp (8|M0)    (gt)f0.1   null<1>:d     r61.0<1;1,0>:d    -127:w              
(f0.1)  goto (8|M0)                          L32512                  L32512                
L29984:
        cmp (8|M0)    (lt)f0.0   null<1>:ud    r61.0<1;1,0>:ud   0xFFFFFF6B:ud             
(f0.0)  goto (8|M0)                          L31992                  L31992                
L30016:
(W)     mov (1|M0)               r5.0<1>:f     8.82818e-44:f                               {I@6}
        add3 (8|M0)              r20.0<1>:d    r21.0<1;0>:d      r47.0<1;0>:d      -23:w              
        subb (8|M0)              r75.0<1>:ud   r5.0<0;1,0>:ud    r118.0<1;1,0>:ud {AccWrEn,Compacted,F@1}
(W)     mov (1|M0)               r5.0<1>:hf    0.0:hf                              {I@1}
        cmp (8|M0)    (gt)f1.0   null<1>:ud    r75.0<1;1,0>:ud   r20.0<1;1,0>:ud 
        add3 (8|M0)              r70.0<1>:ud   -acc0.0<1;0>:ud   r5.0<0;0>:uw      -r125.0<1>:ud    {F@1}
(f1.0)  cmp (8|M0)    (eq)f1.0   null<1>:d     r70.0<1;1,0>:d    0:w               {I@1}
(~f1.0) cmp (8|M0)    (gt)f1.0   null<1>:ud    r70.0<1;1,0>:ud   0x0:uw             
(f1.0)  goto (8|M0)                          L30216                  L30216                
L30152:
        add3 (8|M0)              acc0.0<1>:d   r8.0<1;0>:d       -r75.0<1;0>:d     -23:w              
        mov (8|M0)               r84.0<1>:d    0:w                              
        shl (8|M0)               r85.0<1>:d    r102.0<1;1,0>:d   acc0.0<1;1,0>:d 
        goto (8|M0)                          L30216                  L31928                
L30216:
        join (8|M0)                          L31928                                
L30232:
        add3 (8|M0)              r101.0<1>:d   r75.0<1;0>:d      -r8.0<1;0>:d      23:w              
        cmp (8|M0)    (lt)f1.1   null<1>:d     r101.0<1;1,0>:d   2:w               {I@1}
(f1.1)  goto (8|M0)                          L30384                  L30384                
L30280:
        cmp (8|M0)    (eq)f1.0   null<1>:d     r101.0<1;1,0>:d   2:w              
(~f1.0) goto (8|M0)                          L30384                  L30488                
L30312:
        shr (8|M0)               r92.0<1>:ud   r102.0<1;1,0>:ud  1:w              
        mov (8|M0)               r15.0<1>:d    0:w                              
        mov (8|M0)               r33.0<1>:d    0:w                              
        mov (8|M0)               r116.0<1>:f   r92.0<1;1,0>:f                   {Compacted,I@3}
        goto (8|M0)                          L30384                  L31368                
L30384:
        join (8|M0)                          L30488                                
L30400:
        cmp (8|M0)    (eq)f0.1   null<1>:d     r101.0<1;1,0>:d   1:w              
(~f0.1) goto (8|M0)                          L30488                  L30488                
L30432:
        mov (8|M0)               r15.0<1>:d    0:w                              
        mov (8|M0)               r33.0<1>:d    0:w                              
        mov (8|M0)               r116.0<1>:f   r102.0<1;1,0>:f                  {Compacted}
        goto (8|M0)                          L30488                  L31368                
L30488:
        join (8|M0)                          L31368                                
L30504:
        add3 (8|M0)              acc0.0<1>:d   r75.0<1;0>:d      -r20.0<1;0>:d     -1:w              
        and (8|M0)    (ne)f0.0   r107.0<1>:d   acc0.0<1;1,0>:d   63:w              
(f0.0)  goto (8|M0)                          L30584                  L30584                
L30552:
        mov (8|M0)               r21.0<1>:d    r102.0<1;1,0>:d                 
        goto (8|M0)                          L30584                  L30720                
L30584:
        join (8|M0)                          L30720                                
L30600:
        cmp (8|M0)    (lt)f1.1   null<1>:ud    r107.0<1;1,0>:ud  0x20:uw              {I@5}
(f1.1)  add (8|M0)               acc0.0<1>:d   -r107.0<1;1,0>:d  32:w              
(~f1.1) add (8|M0)               acc2.0<1>:d   r107.0<1;1,0>:d   -32:w              
(f1.1)  shr (8|M0)               r87.0<1>:ud   r102.0<1;1,0>:ud  r107.0<1;1,0>:d 
(f1.1)  shl (8|M0)               r34.0<1>:d    r110.0<1;1,0>:d   acc0.0<1;1,0>:d 
(~f1.1) shr (8|M0)               r92.0<1>:ud   r110.0<1;1,0>:ud  acc2.0<1;1,0>:d  {F@2}
(f1.1)  or (8|M0)                r92.0<1>:d    r87.0<1;1,0>:d    r34.0<1;1,0>:d   {I@2}
        mov (8|M0)               r21.0<1>:f    r92.0<1;1,0>:f                   {Compacted,I@1}
L30720:
        join (8|M0)                          L31368                                
L30736:
        add3 (8|M0)              r107.0<1>:d   r75.0<1;0>:d      -r20.0<1;0>:d     -2:w              
        and (8|M0)    (ne)f1.0   r106.0<1>:d   r107.0<1;1,0>:d   63:w               {I@1}
(f1.0)  goto (8|M0)                          L30816                  L30816                
L30784:
        mov (8|M0)               r92.0<1>:d    r102.0<1;1,0>:d                  {F@1}
        goto (8|M0)                          L30816                  L30944                
L30816:
        join (8|M0)                          L30944                                
L30832:
        cmp (8|M0)    (lt)f0.1   null<1>:ud    r106.0<1;1,0>:ud  0x20:uw              {I@5}
(f0.1)  add (8|M0)               acc0.0<1>:d   -r106.0<1;1,0>:d  32:w              
(~f0.1) add (8|M0)               acc2.0<1>:d   r106.0<1;1,0>:d   -32:w              
(f0.1)  shr (8|M0)               r85.0<1>:ud   r102.0<1;1,0>:ud  r106.0<1;1,0>:d 
(f0.1)  shl (8|M0)               r33.0<1>:d    r110.0<1;1,0>:d   acc0.0<1;1,0>:d 
(~f0.1) shr (8|M0)               r92.0<1>:ud   r110.0<1;1,0>:ud  acc2.0<1;1,0>:d 
(f0.1)  or (8|M0)                r92.0<1>:d    r85.0<1;1,0>:d    r33.0<1;1,0>:d   {I@2}
L30944:
        join (8|M0)                          L31368                                
L30960:
        and (8|M0)    (ne)f0.0   r32.0<1>:d    r107.0<1;1,0>:d   63:w              
        and (8|M0)               r33.0<1>:d    r92.0<1;1,0>:d    1:w               {Compacted,I@3}
(f0.0)  goto (8|M0)                          L31048                  L31048                
L31000:
        mov (8|M0)               r57.0<1>:d    -1:w                              
        mov (8|M0)               r71.0<1>:d    -1:w                              
        goto (8|M0)                          L31048                  L31232                
L31048:
        join (8|M0)                          L31232                                
L31064:
        cmp (8|M0)    (lt)f1.1   null<1>:ud    r32.0<1;1,0>:ud   0x20:uw              {I@7}
(f1.1)  goto (8|M0)                          L31168                  L31168                
L31096:
        add (8|M0)               acc0.0<1>:d   r32.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r5.0<1>:hf    -qnan(0x1FF):hf                             
        mov (8|M0)               r57.0<1>:d    0:w                              
        shl (8|M0)               r71.0<1>:d    r5.0<0;1,0>:w     acc0.0<1;1,0>:d  {F@1}
        goto (8|M0)                          L31168                  L31232                
L31168:
        join (8|M0)                          L31232                                
L31184:
(W)     mov (1|M0)               r5.0<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (8|M0)               r71.0<1>:d    -1:w                              
        shl (8|M0)               r57.0<1>:d    r5.0<0;1,0>:w     r32.0<1;1,0>:d   {F@1}
L31232:
        join (8|M0)                          L31368                                
L31248:
        bfn.0x60 (8|M0)          r84.0<1>:ud   r57.0<1;0>:ud     r6.3<0;0>:ud      r102.0<1>:ud     {I@2} // (s0^s1)&s2
        bfn.0x60 (8|M0)          r83.0<1>:ud   r71.0<1;0>:ud     r6.3<0;0>:ud      r110.0<1>:ud     // (s0^s1)&s2
        cmp (8|M0)    (ne)f0.1   null<1>:d     r84.0<1;1,0>:d    0:w               {I@2}
(W)     mov (1|M0)               r5.0<1>:hf    -qnan(0x1FF):hf                             
        mov (8|M0)               r116.0<1>:f   r21.0<1;1,0>:f                   {Compacted}
(~f0.1) cmp (8|M0)    (ne)f0.1   null<1>:d     r83.0<1;1,0>:d    0:w               {I@2}
(f0.1)  sel (8|M0)               acc0.0<1>:d   r5.0<0;1,0>:w     0:w               {F@2}
        mov (8|M0)               r15.0<1>:d    -acc0.0<1;1,0>:d                
L31368:
        join (8|M0)                          L31928                                
L31384:
        and (8|M0)    (ne)f1.0   r105.0<1>:d   r101.0<1;1,0>:d   63:w              
(f1.0)  goto (8|M0)                          L31448                  L31448                
L31416:
        mov (8|M0)               r92.0<1>:d    r102.0<1;1,0>:d                 
        goto (8|M0)                          L31448                  L31576                
L31448:
        join (8|M0)                          L31576                                
L31464:
        cmp (8|M0)    (lt)f0.1   null<1>:ud    r105.0<1;1,0>:ud  0x20:uw              {I@5}
(f0.1)  add (8|M0)               acc0.0<1>:d   -r105.0<1;1,0>:d  32:w              
(~f0.1) add (8|M0)               acc2.0<1>:d   r105.0<1;1,0>:d   -32:w              
(f0.1)  shr (8|M0)               r80.0<1>:ud   r102.0<1;1,0>:ud  r105.0<1;1,0>:d 
(f0.1)  shl (8|M0)               r31.0<1>:d    r110.0<1;1,0>:d   acc0.0<1;1,0>:d 
(~f0.1) shr (8|M0)               r92.0<1>:ud   r110.0<1;1,0>:ud  acc2.0<1;1,0>:d 
(f0.1)  or (8|M0)                r92.0<1>:d    r80.0<1;1,0>:d    r31.0<1;1,0>:d   {I@2}
L31576:
        join (8|M0)                          L31928                                
L31592:
        shl (8|M0)               r87.0<1>:d    r116.0<1;1,0>:d   2:w               {Compacted,F@1}
        shl (8|M0)               r79.0<1>:d    r33.0<1;1,0>:d    1:w               {Compacted}
        and (8|M0)               r87.0<1>:d    r87.0<1;1,0>:d    4:w               {Compacted,I@2}
        bfn.0xFE (8|M0)          r49.0<1>:ud   r87.0<1;0>:ud     r79.0<1;0>:ud     r15.0<1>:ud      {I@1} // s0|s1|s2
        cmp (8|M0)    (eq)f0.0   null<1>:d     r49.0<1;1,0>:d    0:w               {Compacted,I@1}
(~f0.0) goto (8|M0)                          L31688                  L31688                
L31656:
        mov (8|M0)               r54.0<1>:d    0:w                              
        goto (8|M0)                          L31688                  L31848                
L31688:
        join (8|M0)                          L31848                                
L31704:
        cmp (8|M0)    (gt)f1.1   null<1>:ud    r49.0<1;1,0>:ud   0x4:uw             
(~f1.1) goto (8|M0)                          L31768                  L31768                
L31736:
        mov (8|M0)               r54.0<1>:d    1:w                              
        goto (8|M0)                          L31768                  L31848                
L31768:
        join (8|M0)                          L31848                                
L31784:
        and (8|M0)    (ne)f0.0   null<1>:d     r92.0<1;1,0>:d    1:w              
(W)     mov (1|M0)               r5.0<1>:hf    0x1:hf                             
(f0.0)  cmp (8|M0)    (eq)f0.0   null<1>:d     r49.0<1;1,0>:d    4:w              
(f0.0)  sel (8|M0)               r54.0<1>:d    r5.0<0;1,0>:w     0:w               {F@1}
L31848:
        join (8|M0)                          L31928                                
L31864:
        add (8|M0)               r44.0<1>:d    r54.0<1;1,0>:d    r92.0<1;1,0>:d   {Compacted,I@2}
(W)     mov (1|M0)               r5.0<1>:f     0x800000:f                               {Compacted}
        cmp (8|M0)    (gt)f1.1   null<1>:ud    r44.0<1;1,0>:ud   0x7FFFFF:ud              {I@1}
(~f1.1) sel (8|M0)               r85.0<1>:d    r44.0<1;1,0>:d    0:w              
(f1.1)  sel (8|M0)               r84.0<1>:d    r5.0<0;1,0>:d     0:w               {F@1}
L31928:
        join (8|M0)                          L31992                                
L31944:
        and (8|M0)               r78.0<1>:d    r16.0<1;1,0>:d    -2147483648:d              
        bfn.0xFE (8|M0)          r118.0<1>:ud  r78.0<1;0>:ud     r84.0<1;0>:ud     r85.0<1>:ud      {I@1} // s0|s1|s2
        goto (8|M0)                          L31992                  L35192                
L31992:
        join (8|M0)                          L32512                                
L32008:
        and (8|M0)    (ne)f1.0   r109.0<1>:d   r47.0<1;1,0>:d    63:w              
(f1.0)  goto (8|M0)                          L32088                  L32088                
L32040:
        mov (8|M0)               r8.0<1>:d     -1:w                              
        mov (8|M0)               r30.0<1>:d    -1:w                              
        goto (8|M0)                          L32088                  L32272                
L32088:
        join (8|M0)                          L32272                                
L32104:
        cmp (8|M0)    (lt)f0.1   null<1>:ud    r109.0<1;1,0>:ud  0x20:uw              {I@6}
(f0.1)  goto (8|M0)                          L32208                  L32208                
L32136:
        add (8|M0)               acc0.0<1>:d   r109.0<1;1,0>:d   -32:w               {Compacted}
(W)     mov (1|M0)               r5.0<1>:hf    -qnan(0x1FF):hf                             
        mov (8|M0)               r8.0<1>:d     0:w                              
        shl (8|M0)               r30.0<1>:d    r5.0<0;1,0>:w     acc0.0<1;1,0>:d  {F@1}
        goto (8|M0)                          L32208                  L32272                
L32208:
        join (8|M0)                          L32272                                
L32224:
(W)     mov (1|M0)               r5.0<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (8|M0)               r30.0<1>:d    -1:w                              
        shl (8|M0)               r8.0<1>:d     r5.0<0;1,0>:w     r109.0<1;1,0>:d  {F@1}
L32272:
        join (8|M0)                          L32512                                
L32288:
        bfn.0x60 (8|M0)          r77.0<1>:ud   r8.0<1;0>:ud      r6.3<0;0>:ud      r102.0<1>:ud     {I@2} // (s0^s1)&s2
        bfn.0x60 (8|M0)          r76.0<1>:ud   r30.0<1;0>:ud     r6.3<0;0>:ud      r110.0<1>:ud     // (s0^s1)&s2
        cmp (8|M0)    (ne)f1.0   null<1>:d     r77.0<1;1,0>:d    0:w               {I@2}
        cmp (8|M0)    (gt)f0.0   null<1>:d     r16.0<1;1,0>:d    -1:w              
(~f1.0) cmp (8|M0)    (ne)f1.0   null<1>:d     r76.0<1;1,0>:d    0:w               {I@3}
(f1.0)  cmp (8|M0)    (eq)f1.0   null<1>:d     r61.0<1;1,0>:d    -150:w              
(f0.0)  goto (8|M0)                          L32448                  L32448                
L32400:
(W)     mov (1|M0)               r5.0<1>:ud    0x80000001:ud                             
(f1.0)  sel (8|M0)               r118.0<1>:f   r5.0<0;1,0>:f     -0.0:f               {I@1}
        goto (8|M0)                          L32448                  L35192                
L32448:
        join (8|M0)                          L32512                                
L32464:
(W)     mov (1|M0)               r5.0<1>:ud    0x1:ud                              {F@1}
(f1.0)  sel (8|M0)               r118.0<1>:f   r5.0<0;1,0>:f     0.0:f               {I@1}
        goto (8|M0)                          L32512                  L35192                
L32512:
        join (8|M0)                          L34952                                
L32528:
        cmp (8|M0)    (lt)f1.1   null<1>:ud    r47.0<1;1,0>:ud   0x18:uw             
        add3 (8|M0)              r48.0<1>:d    r21.0<1;0>:d      r47.0<1;0>:d      -46:w              
(f1.1)  cmp (8|M0)    (eq)f1.1   null<1>:d     r27.0<1;1,0>:d    0:w              
(f1.1)  goto (8|M0)                          L34632                  L34632                
L32592:
        shl (8|M0)               r111.0<1>:d   r22.0<1;1,0>:d    1:w               {Compacted}
        shr (8|M0)               r109.0<1>:ud  r22.0<1;1,0>:ud   31:w              
        shl (8|M0)               r20.0<1>:d    r82.0<1;1,0>:d    1:w               {Compacted}
        cmp (8|M0)    (lt)f0.1   null<1>:ud    r111.0<1;1,0>:ud  0x4E:uw              {I@3}
        or (8|M0)                r20.0<1>:d    r20.0<1;1,0>:d    r109.0<1;1,0>:d  {Compacted,I@2}
(f0.1)  cmp (8|M0)    (eq)f0.1   null<1>:d     r20.0<1;1,0>:d    0:w               {I@1}
(~f0.1) cmp (8|M0)    (lt)f0.1   null<1>:d     r20.0<1;1,0>:d    0:w              
(f0.1)  goto (8|M0)                          L32824                  L32824                
L32696:
        cmp (8|M0)    (eq)f1.0   null<1>:d     r22.0<1;1,0>:d    39:w               {F@1}
(f1.0)  cmp (8|M0)    (eq)f1.0   null<1>:d     r82.0<1;1,0>:d    0:w              
(~f1.0) goto (8|M0)                          L32824                  L32888                
L32744:
        shr (8|M0)               r92.0<1>:ud   r102.0<1;1,0>:ud  1:w              
        mov (8|M0)               r28.0<1>:d    0:w                              
        mov (8|M0)               r42.0<1>:d    0:w                              
        mov (8|M0)               r40.0<1>:f    r92.0<1;1,0>:f                   {Compacted,I@3}
        mov (8|M0)               r92.0<1>:f    r102.0<1;1,0>:f                  {Compacted}
        goto (8|M0)                          L32824                  L34088                
L32824:
        join (8|M0)                          L32888                                
L32840:
        cmp (8|M0)    (eq)f0.1   null<1>:d     r22.0<1;1,0>:d    38:w              
(f0.1)  cmp (8|M0)    (eq)f0.1   null<1>:d     r82.0<1;1,0>:d    0:w              
(f0.1)  goto (8|M0)                          L32888                  L34000                
L32888:
        join (8|M0)                          L34000                                
L32904:
        add (8|M0)               acc0.0<1>:d   -r22.0<1;1,0>:d   39:w               {Compacted}
        add (8|M0)               r33.0<1>:d    -r22.0<1;1,0>:d   40:w               {Compacted}
        and (8|M0)    (ne)f1.1   r11.0<1>:d    acc0.0<1;1,0>:d   63:w              
(f1.1)  goto (8|M0)                          L32984                  L32984                
L32952:
        mov (8|M0)               r27.0<1>:d    r102.0<1;1,0>:d                 
        goto (8|M0)                          L32984                  L33120                
L32984:
        join (8|M0)                          L33120                                
L33000:
        cmp (8|M0)    (lt)f1.0   null<1>:ud    r11.0<1;1,0>:ud   0x20:uw              {I@5}
(f1.0)  add (8|M0)               acc0.0<1>:d   -r11.0<1;1,0>:d   32:w              
(~f1.0) add (8|M0)               acc2.0<1>:d   r11.0<1;1,0>:d    -32:w              
(f1.0)  shr (8|M0)               r73.0<1>:ud   r102.0<1;1,0>:ud  r11.0<1;1,0>:d  
(f1.0)  shl (8|M0)               r70.0<1>:d    r110.0<1;1,0>:d   acc0.0<1;1,0>:d 
(~f1.0) shr (8|M0)               r92.0<1>:ud   r110.0<1;1,0>:ud  acc2.0<1;1,0>:d  {F@1}
(f1.0)  or (8|M0)                r92.0<1>:d    r73.0<1;1,0>:d    r70.0<1;1,0>:d   {I@2}
        mov (8|M0)               r27.0<1>:f    r92.0<1;1,0>:f                   {Compacted,I@1}
L33120:
        join (8|M0)                          L34000                                
L33136:
        add (8|M0)               r120.0<1>:d   -r22.0<1;1,0>:d   38:w               {Compacted}
        and (8|M0)    (ne)f0.1   r19.0<1>:d    r120.0<1;1,0>:d   63:w               {I@1}
(f0.1)  goto (8|M0)                          L33208                  L33208                
L33176:
        mov (8|M0)               r92.0<1>:d    r102.0<1;1,0>:d                  {F@1}
        goto (8|M0)                          L33208                  L33336                
L33208:
        join (8|M0)                          L33336                                
L33224:
        cmp (8|M0)    (lt)f0.0   null<1>:ud    r19.0<1;1,0>:ud   0x20:uw              {I@5}
(f0.0)  add (8|M0)               acc0.0<1>:d   -r19.0<1;1,0>:d   32:w              
(~f0.0) add (8|M0)               acc2.0<1>:d   r19.0<1;1,0>:d    -32:w              
(f0.0)  shr (8|M0)               r71.0<1>:ud   r102.0<1;1,0>:ud  r19.0<1;1,0>:d  
(f0.0)  shl (8|M0)               r85.0<1>:d    r110.0<1;1,0>:d   acc0.0<1;1,0>:d 
(~f0.0) shr (8|M0)               r92.0<1>:ud   r110.0<1;1,0>:ud  acc2.0<1;1,0>:d 
(f0.0)  or (8|M0)                r92.0<1>:d    r71.0<1;1,0>:d    r85.0<1;1,0>:d   {I@2}
L33336:
        join (8|M0)                          L34000                                
L33352:
        and (8|M0)    (ne)f1.1   r84.0<1>:d    r120.0<1;1,0>:d   63:w              
        and (8|M0)               r42.0<1>:d    r92.0<1;1,0>:d    1:w               {Compacted,I@3}
(f1.1)  goto (8|M0)                          L33440                  L33440                
L33392:
        mov (8|M0)               r98.0<1>:d    -1:w                              
        mov (8|M0)               r109.0<1>:d   -1:w                              
        goto (8|M0)                          L33440                  L33624                
L33440:
        join (8|M0)                          L33624                                
L33456:
        cmp (8|M0)    (lt)f1.0   null<1>:ud    r84.0<1;1,0>:ud   0x20:uw              {I@7}
(f1.0)  goto (8|M0)                          L33560                  L33560                
L33488:
        add (8|M0)               acc0.0<1>:d   r84.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r5.0<1>:hf    -qnan(0x1FF):hf                             
        mov (8|M0)               r98.0<1>:d    0:w                              
        shl (8|M0)               r109.0<1>:d   r5.0<0;1,0>:w     acc0.0<1;1,0>:d  {F@1}
        goto (8|M0)                          L33560                  L33624                
L33560:
        join (8|M0)                          L33624                                
L33576:
(W)     mov (1|M0)               r5.0<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (8|M0)               r109.0<1>:d   -1:w                              
        shl (8|M0)               r98.0<1>:d    r5.0<0;1,0>:w     r84.0<1;1,0>:d   {F@1}
L33624:
        join (8|M0)                          L34000                                
L33640:
        bfn.0x60 (8|M0)          r70.0<1>:ud   r98.0<1;0>:ud     r6.3<0;0>:ud      r102.0<1>:ud     {I@2} // (s0^s1)&s2
        bfn.0x60 (8|M0)          r69.0<1>:ud   r109.0<1;0>:ud    r6.3<0;0>:ud      r110.0<1>:ud     // (s0^s1)&s2
        cmp (8|M0)    (ne)f0.0   null<1>:d     r70.0<1;1,0>:d    0:w               {I@2}
(W)     mov (1|M0)               r5.0<1>:hf    -qnan(0x1FF):hf                             
        and (8|M0)    (ne)f0.1   r18.0<1>:d    r33.0<1;1,0>:d    63:w              
(~f0.0) cmp (8|M0)    (ne)f0.0   null<1>:d     r69.0<1;1,0>:d    0:w               {I@3}
(f0.0)  sel (8|M0)               acc0.0<1>:d   r5.0<0;1,0>:w     0:w               {F@1}
        mov (8|M0)               r28.0<1>:d    -acc0.0<1;1,0>:d                
(f0.1)  goto (8|M0)                          L33816                  L33816                
L33784:
        mov (8|M0)               r92.0<1>:d    r102.0<1;1,0>:d                 
        goto (8|M0)                          L33816                  L33944                
L33816:
        join (8|M0)                          L33944                                
L33832:
        cmp (8|M0)    (lt)f0.0   null<1>:ud    r18.0<1;1,0>:ud   0x20:uw              {I@7}
(f0.0)  add (8|M0)               acc0.0<1>:d   -r18.0<1;1,0>:d   32:w              
(~f0.0) add (8|M0)               acc2.0<1>:d   r18.0<1;1,0>:d    -32:w              
(f0.0)  shr (8|M0)               r66.0<1>:ud   r102.0<1;1,0>:ud  r18.0<1;1,0>:d  
(f0.0)  shl (8|M0)               r83.0<1>:d    r110.0<1;1,0>:d   acc0.0<1;1,0>:d 
(~f0.0) shr (8|M0)               r92.0<1>:ud   r110.0<1;1,0>:ud  acc2.0<1;1,0>:d 
(f0.0)  or (8|M0)                r92.0<1>:d    r66.0<1;1,0>:d    r83.0<1;1,0>:d   {I@2}
L33944:
        join (8|M0)                          L34000                                
L33960:
        mov (8|M0)               r40.0<1>:f    r92.0<1;1,0>:f                   {Compacted,I@2}
        mov (8|M0)               r92.0<1>:d    r27.0<1;1,0>:d                   {F@1}
        goto (8|M0)                          L34000                  L34088                
L34000:
        join (8|M0)                          L34088                                
L34016:
        shr (8|M0)               r92.0<1>:ud   r102.0<1;1,0>:ud  2:w              
        mov (8|M0)               r28.0<1>:d    0:w                              
        mov (8|M0)               r42.0<1>:d    0:w                              
        mov (8|M0)               r40.0<1>:f    r92.0<1;1,0>:f                   {Compacted,I@3}
        shr (8|M0)               r92.0<1>:ud   r102.0<1;1,0>:ud  1:w               {F@1}
L34088:
        join (8|M0)                          L34632                                
L34104:
        shl (8|M0)               r56.0<1>:d    r92.0<1;1,0>:d    2:w               {Compacted,I@2}
        shl (8|M0)               r65.0<1>:d    r42.0<1;1,0>:d    1:w               {Compacted}
        and (8|M0)               r56.0<1>:d    r56.0<1;1,0>:d    4:w               {Compacted,I@2}
        and (8|M0)               r125.0<1>:d   r40.0<1;1,0>:d    8388607:d              
        bfn.0xFE (8|M0)          r108.0<1>:ud  r56.0<1;0>:ud     r65.0<1;0>:ud     r28.0<1>:ud      {I@2} // s0|s1|s2
        cmp (8|M0)    (eq)f1.1   null<1>:d     r108.0<1;1,0>:d   0:w               {I@1}
(~f1.1) goto (8|M0)                          L34224                  L34224                
L34192:
        mov (8|M0)               r107.0<1>:d   0:w                              
        goto (8|M0)                          L34224                  L34384                
L34224:
        join (8|M0)                          L34384                                
L34240:
        cmp (8|M0)    (gt)f1.0   null<1>:ud    r108.0<1;1,0>:ud  0x4:uw             
(~f1.0) goto (8|M0)                          L34304                  L34304                
L34272:
        mov (8|M0)               r107.0<1>:d   1:w                              
        goto (8|M0)                          L34304                  L34384                
L34304:
        join (8|M0)                          L34384                                
L34320:
        and (8|M0)    (ne)f1.1   null<1>:d     r40.0<1;1,0>:d    1:w              
(W)     mov (1|M0)               r5.0<1>:hf    0x1:hf                             
(f1.1)  cmp (8|M0)    (eq)f1.1   null<1>:d     r108.0<1;1,0>:d   4:w              
(f1.1)  sel (8|M0)               r107.0<1>:d   r5.0<0;1,0>:w     0:w               {F@1}
L34384:
        join (8|M0)                          L34632                                
L34400:
        add (8|M0)               r69.0<1>:d    r125.0<1;1,0>:d   r107.0<1;1,0>:d  {Compacted,I@2}
        add3 (8|M0)              r60.0<1>:d    r21.0<1;0>:d      r47.0<1;0>:d      -45:w              
        cmp (8|M0)    (gt)f1.0   null<1>:ud    r69.0<1;1,0>:ud   0x7FFFFF:ud              {I@2}
(f1.0)  sel (8|M0)               r54.0<1>:d    r60.0<1;1,0>:d    r48.0<1;1,0>:d   {I@2}
        cmp (8|M0)    (eq)f0.1   null<1>:d     r54.0<1;1,0>:d    255:w               {I@1}
(f0.1)  goto (8|M0)                          L34560                  L34560                
L34488:
(~f1.0) sel (8|M0)               r71.0<1>:d    r69.0<1;1,0>:d    0:w              
        and (8|M0)               r59.0<1>:d    r16.0<1;1,0>:d    -2147483648:d              
        shl (8|M0)               r64.0<1>:d    r54.0<1;1,0>:d    23:w               {Compacted}
        bfn.0xFE (8|M0)          r118.0<1>:ud  r59.0<1;0>:ud     r64.0<1;0>:ud     r71.0<1>:ud      {I@1} // s0|s1|s2
        goto (8|M0)                          L34560                  L35192                
L34560:
        join (8|M0)                          L34632                                
L34576:
        cmp (8|M0)    (gt)f1.0   null<1>:d     r16.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r5.0<1>:f     inf:f                               {Compacted}
(f1.0)  sel (8|M0)               r118.0<1>:f   r5.0<0;1,0>:f     -inf:f               {A@1}
        goto (8|M0)                          L34632                  L35192                
L34632:
        join (8|M0)                          L34952                                
L34648:
        and (8|M0)    (ne)f0.0   r64.0<1>:d    r47.0<1;1,0>:d    63:w              
(f0.0)  goto (8|M0)                          L34712                  L34712                
L34680:
        mov (8|M0)               r86.0<1>:d    -1:w                              
        goto (8|M0)                          L34712                  L34840                
L34712:
        join (8|M0)                          L34840                                
L34728:
        cmp (8|M0)    (lt)f1.1   null<1>:ud    r64.0<1;1,0>:ud   0x20:uw              {I@5}
(f1.1)  goto (8|M0)                          L34792                  L34792                
L34760:
        mov (8|M0)               r86.0<1>:d    0:w                              
        goto (8|M0)                          L34792                  L34840                
L34792:
        join (8|M0)                          L34840                                
L34808:
(W)     mov (1|M0)               r5.0<1>:hf    -qnan(0x1FF):hf                             
        shl (8|M0)               r86.0<1>:d    r5.0<0;1,0>:w     r64.0<1;1,0>:d   {F@1}
L34840:
        join (8|M0)                          L34952                                
L34856:
        bfn.0x60 (8|M0)          r106.0<1>:ud  r86.0<1;0>:ud     r6.3<0;0>:ud      r102.0<1>:ud     {I@2} // (s0^s1)&s2
        add (8|M0)               acc0.0<1>:d   -r47.0<1;1,0>:d   23:w               {Compacted}
        and (8|M0)               r58.0<1>:d    r16.0<1;1,0>:d    -2147483648:d              
        shl (8|M0)               r62.0<1>:d    r48.0<1;1,0>:d    23:w               {Compacted}
        shl (8|M0)               r106.0<1>:d   r106.0<1;1,0>:d   acc0.0<1;1,0>:d  {I@4}
        bfn.0xFE (8|M0)          r118.0<1>:ud  r58.0<1;0>:ud     r62.0<1;0>:ud     r106.0<1>:ud     {I@1} // s0|s1|s2
        goto (8|M0)                          L34952                  L35192                
L34952:
        join (8|M0)                          L35024                                
L34968:
        cmp (8|M0)    (gt)f0.1   null<1>:d     r16.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r5.0<1>:f     inf:f                               {Compacted}
(f0.1)  sel (8|M0)               r118.0<1>:f   r5.0<0;1,0>:f     -inf:f               {A@1}
        goto (8|M0)                          L35024                  L35192                
L35024:
        join (8|M0)                          L35088                                
L35040:
        cmp (8|M0)    (lt)f0.0   null<1>:d     r16.0<1;1,0>:d    0:w               {Compacted}
(W)     mov (1|M0)               r5.0<1>:f     -0.0:f                               {Compacted}
(f0.0)  sel (8|M0)               r118.0<1>:f   r5.0<0;1,0>:f     0.0:f               {F@1}
        goto (8|M0)                          L35088                  L35192                
L35088:
        join (8|M0)                          L35160                                
L35104:
        cmp (8|M0)    (gt)f1.1   null<1>:d     r16.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r5.0<1>:f     inf:f                               {Compacted}
(f1.1)  sel (8|M0)               r118.0<1>:f   r5.0<0;1,0>:f     -inf:f               {F@1}
        goto (8|M0)                          L35160                  L35192                
L35160:
        join (8|M0)                          L35192                                
L35176:
        bfn.0xF8 (8|M0)          r118.0<1>:ud  r16.0<1;0>:ud     r6.1<0;0>:ud      r6.0<0>:ud       {F@1} // s0&s1|s2
L35192:
        join (8|M0)                          L41560                                
L35208:
        rnde (8|M0)              r105.0<1>:f   r118.0<1;1,0>:f                  {Compacted,I@2}
        shr (8|M0)               r100.0<1>:ud  r105.0<1;1,0>:ud  23:w               {F@1}
        and (8|M0)    (ne)f1.0   r97.0<1>:d    r105.0<1;1,0>:d   8388607:d              
        and (8|M0)               r62.0<1>:d    r100.0<1;1,0>:d   255:w               {Compacted,I@2}
(f1.0)  cmp (8|M0)    (eq)f1.0   null<1>:d     r62.0<1;1,0>:d    255:w               {I@1}
(~f1.0) goto (8|M0)                          L35312                  L35312                
L35288:
        mov (8|M0)               r116.0<1>:f   qnan(0x0):f                               {Compacted}
        goto (8|M0)                          L35312                  L41520                
L35312:
        join (8|M0)                          L41520                                
L35328:
        cmp (8|M0)    (eq)f0.0   null<1>:d     r97.0<1;1,0>:d    0:w               {Compacted}
        add (8|M0)               r63.0<1>:d    r13.0<1;1,0>:d    -25165824:d              
        shr (8|M0)               r95.0<1>:ud   r63.0<1;1,0>:ud   23:w               {I@1}
(f0.0)  cmp (8|M0)    (eq)f0.0   null<1>:d     r62.0<1;1,0>:d    255:w              
        and (8|M0)               r22.0<1>:d    r95.0<1;1,0>:d    255:w               {Compacted,I@2}
        xor (8|M0)               r17.0<1>:d    r63.0<1;1,0>:d    r105.0<1;1,0>:d  {Compacted}
(~f0.0) cmp (8|M0)    (eq)f0.0   null<1>:d     r22.0<1;1,0>:d    255:w               {I@2}
(f0.0)  goto (8|M0)                          L41488                  L41488                
L35432:
        cmp (8|M0)    (eq)f0.1   null<1>:d     r22.0<1;1,0>:d    0:w              
        or (8|M0)                r61.0<1>:d    r62.0<1;1,0>:d    r97.0<1;1,0>:d   {Compacted}
(~f0.1) cmp (8|M0)    (eq)f0.1   null<1>:d     r61.0<1;1,0>:d    0:w               {I@1}
(~f0.1) goto (8|M0)                          L35512                  L35512                
L35488:
        mov (8|M0)               r116.0<1>:f   0.0:f                               {Compacted}
        goto (8|M0)                          L35512                  L41520                
L35512:
        join (8|M0)                          L41488                                
L35528:
        cmp (8|M0)    (eq)f1.1   null<1>:d     r62.0<1;1,0>:d    0:w              
        add (8|M0)               r118.0<1>:d   r62.0<1;1,0>:d    -127:w               {Compacted}
(f1.1)  mov (8|M0)               r118.0<1>:d   -126:w                              
        add (8|M0)               r23.0<1>:d    r22.0<1;1,0>:d    r118.0<1;1,0>:d  {Compacted,I@1}
        cmp (8|M0)    (gt)f1.0   null<1>:d     r23.0<1;1,0>:d    254:w               {I@1}
(f1.0)  goto (8|M0)                          L41416                  L41416                
L35608:
        or (8|M0)     (eq)f0.1   null<4>:b     r100.0<1;1,0>:d   r95.0<1;1,0>:d  
(f0.1)  goto (8|M0)                          L41352                  L41352                
L35640:
(W)     mov (1|M0)               r5.0<1>:hf    0.0:hf                             
(W)     mov (1|M0)               r6.5<1>:d     0:w                              
(f1.1)  sel (8|M0)               acc0.0<1>:d   r5.0<0;1,0>:w     8388608:d               {F@1}
(W)     mov (1|M0)               r6.4<1>:f     -0.0:f                               {Compacted}
        or (8|M0)                r95.0<1>:d    acc0.0<1;1,0>:d   r97.0<1;1,0>:d  
(W)     mov (2|M0)               r5.4<1>:d     0:w                              
        shl (8|M0)               r103.0<1>:d   r95.0<1;1,0>:d    23:w               {Compacted,I@2}
        shr (8|M0)               r109.0<1>:ud  r95.0<1;1,0>:ud   9:w              
L35752:
(W)     shl (1|M0)               r8.0<1>:d     r6.4<0;1,0>:d     31:w               {Compacted,F@1}
(W)     shr (1|M0)               r6.7<1>:ud    r6.5<0;1,0>:ud    1:w              
(W)     cmp (8|M0)    (gt)f1.1   null<1>:ud    r5.4<0;1,0>:ud    0x3E:uw              {I@5}
(W)     or (1|M0)                r6.5<1>:d     r6.7<0;1,0>:d     r8.0<0;1,0>:d    {I@2}
        bfn.0xE0 (8|M0)          r28.0<1>:ud   r6.7<0;0>:ud      r8.0<0;0>:ud      r103.0<1>:ud     // (s0|s1)&s2
(W)     shr (1|M0)               r5.7<1>:ud    r6.4<0;1,0>:ud    1:w              
(W&f1.1) cmp (8|M0)   (eq)f1.1   null<1>:d     r5.5<0;1,0>:d     0:w              
        cmp (8|M0)    (eq)f1.0   null<1>:d     r28.0<1;1,0>:d    r6.5<0;1,0>:d    {I@3}
        and (8|M0)               r27.0<1>:d    r5.7<0;1,0>:d     r109.0<1;1,0>:d  {Compacted,I@3}
(W)     addc (1|M0)              r9.0<1>:ud    r5.4<0;1,0>:ud    0x1:ud              {AccWrEn}
(W&~f1.1) cmp (8|M0)  (gt)f1.1   null<1>:ud    r5.5<0;1,0>:ud    0x0:uw             
(f1.0)  cmp (8|M0)    (eq)f1.0   null<1>:d     r27.0<1;1,0>:d    r5.7<0;1,0>:d    {I@3}
(W)     mov (1|M0)               r6.14<1>:hf   0x1:hf                             
(W)     mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
(f1.1)  sel (8|M0)               r8.0<1>:uw    r6.14<0;1,0>:uw   0x0:uw              {F@1}
(W)     add (1|M0)               r8.4<1>:ud    r5.0<0;1,0>:ud    r5.5<0;1,0>:ud   {I@2}
(f1.0)  sel (8|M0)               r5.0<1>:uw    r6.14<0;1,0>:uw   0x0:uw             
        mov (8|M0)               r116.0<1>:d   r5.4<0;1,0>:d                   
        or (8|M0)     (ne)f1.1   null<1>:uw    r8.0<1;1,0>:uw    r5.0<1;1,0>:uw   {I@2}
        mov (8|M0)               r123.0<1>:d   r5.5<0;1,0>:d                   
        mov (8|M0)               r20.0<1>:f    r9.0<0;1,0>:f                    {Compacted}
        mov (8|M0)               r78.0<1>:d    r8.4<0;1,0>:d                   
(f1.1)  goto (8|M0)                          L36152                  L36152                
L36088:
(W)     mov (1|M0)               r6.4<1>:d     r5.7<0;1,0>:d                   
(W)     mov (1|M0)               r5.4<1>:d     r9.0<0;1,0>:d                   
(W)     mov (1|M0)               r5.5<1>:d     r8.4<0;1,0>:d                   
(W)     jmpi                                 L35752                                
L36152:
        join (8|M0)                          L41352                                
L36168:
(W)     mov (1|M0)               r5.0<1>:f     8.68805e-44:f                               {I@7}
        subb (8|M0)              r46.0<1>:ud   r5.0<0;1,0>:ud    r116.0<1;1,0>:ud {AccWrEn,Compacted,F@1}
(W)     mov (1|M0)               r5.0<1>:hf    0.0:hf                              {I@1}
        add3 (8|M0)              r59.0<1>:d    r23.0<1;0>:d      r46.0<1;0>:d      -173:w              
        add3 (8|M0)              r125.0<1>:d   r22.0<1;0>:d      r118.0<1;0>:d     r46.0<1>:d      
        cmp (8|M0)    (gt)f0.0   null<1>:d     r59.0<1;1,0>:d    127:w               {I@2}
        add3 (8|M0)              r24.0<1>:ud   -acc0.0<1;0>:ud   r5.0<0;0>:uw      -r123.0<1>:ud    {F@1}
(f0.0)  goto (8|M0)                          L41280                  L41280                
L36288:
        cmp (8|M0)    (gt)f1.1   null<1>:d     r59.0<1;1,0>:d    -127:w              
(f1.1)  goto (8|M0)                          L38848                  L38848                
L36320:
        cmp (8|M0)    (lt)f1.0   null<1>:ud    r59.0<1;1,0>:ud   0xFFFFFF6B:ud             
(f1.0)  goto (8|M0)                          L38328                  L38328                
L36352:
(W)     mov (1|M0)               r5.0<1>:f     8.82818e-44:f                               {I@6}
        add3 (8|M0)              r14.0<1>:d    r23.0<1;0>:d      r46.0<1;0>:d      -23:w              
        subb (8|M0)              r71.0<1>:ud   r5.0<0;1,0>:ud    r116.0<1;1,0>:ud {AccWrEn,Compacted,F@1}
(W)     mov (1|M0)               r5.0<1>:hf    0.0:hf                              {I@1}
        cmp (8|M0)    (gt)f1.1   null<1>:ud    r71.0<1;1,0>:ud   r14.0<1;1,0>:ud 
        add3 (8|M0)              r62.0<1>:ud   -acc0.0<1;0>:ud   r5.0<0;0>:uw      -r123.0<1>:ud    {F@1}
(f1.1)  cmp (8|M0)    (eq)f1.1   null<1>:d     r62.0<1;1,0>:d    0:w               {I@1}
(~f1.1) cmp (8|M0)    (gt)f1.1   null<1>:ud    r62.0<1;1,0>:ud   0x0:uw             
(f1.1)  goto (8|M0)                          L36552                  L36552                
L36488:
        add3 (8|M0)              acc0.0<1>:d   r125.0<1;0>:d     -r71.0<1;0>:d     -23:w              
        mov (8|M0)               r76.0<1>:d    0:w                              
        shl (8|M0)               r77.0<1>:d    r103.0<1;1,0>:d   acc0.0<1;1,0>:d 
        goto (8|M0)                          L36552                  L38264                
L36552:
        join (8|M0)                          L38264                                
L36568:
        add3 (8|M0)              r100.0<1>:d   r71.0<1;0>:d      -r125.0<1;0>:d    23:w              
        cmp (8|M0)    (lt)f0.1   null<1>:d     r100.0<1;1,0>:d   2:w               {I@1}
(f0.1)  goto (8|M0)                          L36712                  L36712                
L36616:
        cmp (8|M0)    (eq)f0.0   null<1>:d     r100.0<1;1,0>:d   2:w               {Compacted}
(~f0.0) goto (8|M0)                          L36712                  L36816                
L36640:
        shr (8|M0)               r96.0<1>:ud   r103.0<1;1,0>:ud  1:w              
        mov (8|M0)               r126.0<1>:d   0:w                              
        mov (8|M0)               r121.0<1>:d   0:w                              
        mov (8|M0)               r108.0<1>:f   r96.0<1;1,0>:f                   {Compacted,I@3}
        goto (8|M0)                          L36712                  L37704                
L36712:
        join (8|M0)                          L36816                                
L36728:
        cmp (8|M0)    (eq)f1.1   null<1>:d     r100.0<1;1,0>:d   1:w              
(~f1.1) goto (8|M0)                          L36816                  L36816                
L36760:
        mov (8|M0)               r126.0<1>:d   0:w                              
        mov (8|M0)               r121.0<1>:d   0:w                              
        mov (8|M0)               r108.0<1>:f   r103.0<1;1,0>:f                  {Compacted}
        goto (8|M0)                          L36816                  L37704                
L36816:
        join (8|M0)                          L37704                                
L36832:
        add3 (8|M0)              acc0.0<1>:d   r71.0<1;0>:d      -r14.0<1;0>:d     -1:w              
        and (8|M0)    (ne)f1.0   r99.0<1>:d    acc0.0<1;1,0>:d   63:w              
(f1.0)  goto (8|M0)                          L36912                  L36912                
L36880:
        mov (8|M0)               r19.0<1>:d    r103.0<1;1,0>:d                 
        goto (8|M0)                          L36912                  L37048                
L36912:
        join (8|M0)                          L37048                                
L36928:
        cmp (8|M0)    (lt)f0.1   null<1>:ud    r99.0<1;1,0>:ud   0x20:uw              {I@5}
(f0.1)  add (8|M0)               acc0.0<1>:d   -r99.0<1;1,0>:d   32:w              
(~f0.1) add (8|M0)               acc2.0<1>:d   r99.0<1;1,0>:d    -32:w              
(f0.1)  shr (8|M0)               r57.0<1>:ud   r103.0<1;1,0>:ud  r99.0<1;1,0>:d  
(f0.1)  shl (8|M0)               r127.0<1>:d   r109.0<1;1,0>:d   acc0.0<1;1,0>:d 
(~f0.1) shr (8|M0)               r96.0<1>:ud   r109.0<1;1,0>:ud  acc2.0<1;1,0>:d  {F@2}
(f0.1)  or (8|M0)                r96.0<1>:d    r57.0<1;1,0>:d    r127.0<1;1,0>:d  {I@2}
        mov (8|M0)               r19.0<1>:f    r96.0<1;1,0>:f                   {Compacted,I@1}
L37048:
        join (8|M0)                          L37704                                
L37064:
        add3 (8|M0)              r94.0<1>:d    r71.0<1;0>:d      -r14.0<1;0>:d     -2:w              
        and (8|M0)    (ne)f0.0   r98.0<1>:d    r94.0<1;1,0>:d    63:w               {I@1}
(f0.0)  goto (8|M0)                          L37144                  L37144                
L37112:
        mov (8|M0)               r96.0<1>:d    r103.0<1;1,0>:d                  {F@1}
        goto (8|M0)                          L37144                  L37272                
L37144:
        join (8|M0)                          L37272                                
L37160:
        cmp (8|M0)    (lt)f1.1   null<1>:ud    r98.0<1;1,0>:ud   0x20:uw              {I@5}
(f1.1)  add (8|M0)               acc0.0<1>:d   -r98.0<1;1,0>:d   32:w              
(~f1.1) add (8|M0)               acc2.0<1>:d   r98.0<1;1,0>:d    -32:w              
(f1.1)  shr (8|M0)               r55.0<1>:ud   r103.0<1;1,0>:ud  r98.0<1;1,0>:d  
(f1.1)  shl (8|M0)               r126.0<1>:d   r109.0<1;1,0>:d   acc0.0<1;1,0>:d 
(~f1.1) shr (8|M0)               r96.0<1>:ud   r109.0<1;1,0>:ud  acc2.0<1;1,0>:d 
(f1.1)  or (8|M0)                r96.0<1>:d    r55.0<1;1,0>:d    r126.0<1;1,0>:d  {I@2}
L37272:
        join (8|M0)                          L37704                                
L37288:
        and (8|M0)    (ne)f1.0   r125.0<1>:d   r94.0<1;1,0>:d    63:w              
(f1.0)  goto (8|M0)                          L37368                  L37368                
L37320:
        mov (8|M0)               r29.0<1>:d    -1:w                              
        mov (8|M0)               r55.0<1>:d    -1:w                              
        goto (8|M0)                          L37368                  L37552                
L37368:
        join (8|M0)                          L37552                                
L37384:
        cmp (8|M0)    (lt)f0.1   null<1>:ud    r125.0<1;1,0>:ud  0x20:uw              {I@6}
(f0.1)  goto (8|M0)                          L37488                  L37488                
L37416:
        add (8|M0)               acc0.0<1>:d   r125.0<1;1,0>:d   -32:w               {Compacted}
(W)     mov (1|M0)               r5.0<1>:hf    -qnan(0x1FF):hf                             
        mov (8|M0)               r29.0<1>:d    0:w                              
        shl (8|M0)               r55.0<1>:d    r5.0<0;1,0>:w     acc0.0<1;1,0>:d  {F@1}
        goto (8|M0)                          L37488                  L37552                
L37488:
        join (8|M0)                          L37552                                
L37504:
(W)     mov (1|M0)               r5.0<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (8|M0)               r55.0<1>:d    -1:w                              
        shl (8|M0)               r29.0<1>:d    r5.0<0;1,0>:w     r125.0<1;1,0>:d  {F@1}
L37552:
        join (8|M0)                          L37704                                
L37568:
        bfn.0x60 (8|M0)          r54.0<1>:ud   r29.0<1;0>:ud     r6.3<0;0>:ud      r103.0<1>:ud     {I@2} // (s0^s1)&s2
        bfn.0x60 (8|M0)          r53.0<1>:ud   r55.0<1;0>:ud     r6.3<0;0>:ud      r109.0<1>:ud     // (s0^s1)&s2
        cmp (8|M0)    (ne)f0.0   null<1>:d     r54.0<1;1,0>:d    0:w               {I@2}
(W)     mov (1|M0)               r5.0<1>:hf    -qnan(0x1FF):hf                             
        shl (8|M0)               r51.0<1>:d    r96.0<1;1,0>:d    1:w               {Compacted}
        mov (8|M0)               r108.0<1>:f   r19.0<1;1,0>:f                   {Compacted}
(~f0.0) cmp (8|M0)    (ne)f0.0   null<1>:d     r53.0<1;1,0>:d    0:w               {I@3}
        and (8|M0)               r121.0<1>:d   r51.0<1;1,0>:d    2:w               {Compacted,I@2}
(f0.0)  sel (8|M0)               acc0.0<1>:d   r5.0<0;1,0>:w     0:w               {F@2}
        mov (8|M0)               r126.0<1>:d   -acc0.0<1;1,0>:d                
L37704:
        join (8|M0)                          L38264                                
L37720:
        and (8|M0)    (ne)f0.0   r97.0<1>:d    r100.0<1;1,0>:d   63:w              
(f0.0)  goto (8|M0)                          L37784                  L37784                
L37752:
        mov (8|M0)               r96.0<1>:d    r103.0<1;1,0>:d                 
        goto (8|M0)                          L37784                  L37912                
L37784:
        join (8|M0)                          L37912                                
L37800:
        cmp (8|M0)    (lt)f1.1   null<1>:ud    r97.0<1;1,0>:ud   0x20:uw              {I@5}
(f1.1)  add (8|M0)               acc0.0<1>:d   -r97.0<1;1,0>:d   32:w              
(~f1.1) add (8|M0)               acc2.0<1>:d   r97.0<1;1,0>:d    -32:w              
(f1.1)  shr (8|M0)               r49.0<1>:ud   r103.0<1;1,0>:ud  r97.0<1;1,0>:d  
(f1.1)  shl (8|M0)               r124.0<1>:d   r109.0<1;1,0>:d   acc0.0<1;1,0>:d 
(~f1.1) shr (8|M0)               r96.0<1>:ud   r109.0<1;1,0>:ud  acc2.0<1;1,0>:d 
(f1.1)  or (8|M0)                r96.0<1>:d    r49.0<1;1,0>:d    r124.0<1;1,0>:d  {I@2}
L37912:
        join (8|M0)                          L38264                                
L37928:
        shl (8|M0)               r53.0<1>:d    r108.0<1;1,0>:d   2:w               {Compacted,F@1}
        and (8|M0)               r53.0<1>:d    r53.0<1;1,0>:d    4:w               {Compacted,I@1}
        bfn.0xFE (8|M0)          r45.0<1>:ud   r53.0<1;0>:ud     r121.0<1;0>:ud    r126.0<1>:ud     {I@1} // s0|s1|s2
        cmp (8|M0)    (eq)f1.0   null<1>:d     r45.0<1;1,0>:d    0:w               {I@1}
(~f1.0) goto (8|M0)                          L38024                  L38024                
L37992:
        mov (8|M0)               r48.0<1>:d    0:w                              
        goto (8|M0)                          L38024                  L38184                
L38024:
        join (8|M0)                          L38184                                
L38040:
        cmp (8|M0)    (gt)f0.1   null<1>:ud    r45.0<1;1,0>:ud   0x4:uw             
(~f0.1) goto (8|M0)                          L38104                  L38104                
L38072:
        mov (8|M0)               r48.0<1>:d    1:w                              
        goto (8|M0)                          L38104                  L38184                
L38104:
        join (8|M0)                          L38184                                
L38120:
        and (8|M0)    (ne)f1.1   null<1>:d     r96.0<1;1,0>:d    1:w              
(W)     mov (1|M0)               r5.0<1>:hf    0x1:hf                             
(f1.1)  cmp (8|M0)    (eq)f1.1   null<1>:d     r45.0<1;1,0>:d    4:w              
(f1.1)  sel (8|M0)               r48.0<1>:d    r5.0<0;1,0>:w     0:w               {F@1}
L38184:
        join (8|M0)                          L38264                                
L38200:
        add (8|M0)               r36.0<1>:d    r48.0<1;1,0>:d    r96.0<1;1,0>:d   {Compacted,I@2}
(W)     mov (1|M0)               r5.0<1>:f     0x800000:f                               {Compacted}
        cmp (8|M0)    (gt)f1.0   null<1>:ud    r36.0<1;1,0>:ud   0x7FFFFF:ud              {I@1}
(~f1.0) sel (8|M0)               r77.0<1>:d    r36.0<1;1,0>:d    0:w              
(f1.0)  sel (8|M0)               r76.0<1>:d    r5.0<0;1,0>:d     0:w               {F@1}
L38264:
        join (8|M0)                          L38328                                
L38280:
        and (8|M0)               r48.0<1>:d    r17.0<1;1,0>:d    -2147483648:d              
        bfn.0xFE (8|M0)          r116.0<1>:ud  r48.0<1;0>:ud     r76.0<1;0>:ud     r77.0<1>:ud      {I@1} // s0|s1|s2
        goto (8|M0)                          L38328                  L41520                
L38328:
        join (8|M0)                          L38848                                
L38344:
        and (8|M0)    (ne)f0.0   r85.0<1>:d    r46.0<1;1,0>:d    63:w              
(f0.0)  goto (8|M0)                          L38424                  L38424                
L38376:
        mov (8|M0)               r104.0<1>:d   -1:w                              
        mov (8|M0)               r123.0<1>:d   -1:w                              
        goto (8|M0)                          L38424                  L38608                
L38424:
        join (8|M0)                          L38608                                
L38440:
        cmp (8|M0)    (lt)f1.1   null<1>:ud    r85.0<1;1,0>:ud   0x20:uw              {I@6}
(f1.1)  goto (8|M0)                          L38544                  L38544                
L38472:
        add (8|M0)               acc0.0<1>:d   r85.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r5.0<1>:hf    -qnan(0x1FF):hf                             
        mov (8|M0)               r104.0<1>:d   0:w                              
        shl (8|M0)               r123.0<1>:d   r5.0<0;1,0>:w     acc0.0<1;1,0>:d  {F@1}
        goto (8|M0)                          L38544                  L38608                
L38544:
        join (8|M0)                          L38608                                
L38560:
(W)     mov (1|M0)               r5.0<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (8|M0)               r123.0<1>:d   -1:w                              
        shl (8|M0)               r104.0<1>:d   r5.0<0;1,0>:w     r85.0<1;1,0>:d   {F@1}
L38608:
        join (8|M0)                          L38848                                
L38624:
        bfn.0x60 (8|M0)          r47.0<1>:ud   r104.0<1;0>:ud    r6.3<0;0>:ud      r103.0<1>:ud     {I@2} // (s0^s1)&s2
        bfn.0x60 (8|M0)          r46.0<1>:ud   r123.0<1;0>:ud    r6.3<0;0>:ud      r109.0<1>:ud     // (s0^s1)&s2
        cmp (8|M0)    (ne)f0.1   null<1>:d     r47.0<1;1,0>:d    0:w               {I@2}
        cmp (8|M0)    (gt)f1.0   null<1>:d     r17.0<1;1,0>:d    -1:w              
(~f0.1) cmp (8|M0)    (ne)f0.1   null<1>:d     r46.0<1;1,0>:d    0:w               {I@3}
(f0.1)  cmp (8|M0)    (eq)f0.1   null<1>:d     r59.0<1;1,0>:d    -150:w              
(f1.0)  goto (8|M0)                          L38784                  L38784                
L38736:
(W)     mov (1|M0)               r5.0<1>:ud    0x80000001:ud                             
(f0.1)  sel (8|M0)               r116.0<1>:f   r5.0<0;1,0>:f     -0.0:f               {I@1}
        goto (8|M0)                          L38784                  L41520                
L38784:
        join (8|M0)                          L38848                                
L38800:
(W)     mov (1|M0)               r5.0<1>:ud    0x1:ud                              {F@1}
(f0.1)  sel (8|M0)               r116.0<1>:f   r5.0<0;1,0>:f     0.0:f               {I@1}
        goto (8|M0)                          L38848                  L41520                
L38848:
        join (8|M0)                          L41280                                
L38864:
        cmp (8|M0)    (lt)f1.0   null<1>:ud    r46.0<1;1,0>:ud   0x18:uw             
        add3 (8|M0)              r47.0<1>:d    r23.0<1;0>:d      r46.0<1;0>:d      -46:w              
(f1.0)  cmp (8|M0)    (eq)f1.0   null<1>:d     r24.0<1;1,0>:d    0:w              
(f1.0)  goto (8|M0)                          L40960                  L40960                
L38928:
        shl (8|M0)               r101.0<1>:d   r20.0<1;1,0>:d    1:w               {Compacted}
        shr (8|M0)               r100.0<1>:ud  r20.0<1;1,0>:ud   31:w              
        shl (8|M0)               r10.0<1>:d    r78.0<1;1,0>:d    1:w               {Compacted}
        cmp (8|M0)    (lt)f1.0   null<1>:ud    r101.0<1;1,0>:ud  0x4E:uw              {I@3}
        or (8|M0)                r10.0<1>:d    r10.0<1;1,0>:d    r100.0<1;1,0>:d  {Compacted,I@2}
(f1.0)  cmp (8|M0)    (eq)f1.0   null<1>:d     r10.0<1;1,0>:d    0:w               {I@1}
(~f1.0) cmp (8|M0)    (lt)f1.0   null<1>:d     r10.0<1;1,0>:d    0:w              
(f1.0)  goto (8|M0)                          L39160                  L39160                
L39032:
        cmp (8|M0)    (eq)f0.1   null<1>:d     r20.0<1;1,0>:d    39:w               {F@1}
(f0.1)  cmp (8|M0)    (eq)f0.1   null<1>:d     r78.0<1;1,0>:d    0:w              
(~f0.1) goto (8|M0)                          L39160                  L39216                
L39080:
        shr (8|M0)               r96.0<1>:ud   r103.0<1;1,0>:ud  1:w              
        mov (8|M0)               r27.0<1>:d    0:w                              
        mov (8|M0)               r107.0<1>:d   0:w                              
        mov (8|M0)               r35.0<1>:f    r96.0<1;1,0>:f                   {Compacted,I@3}
        mov (8|M0)               r96.0<1>:f    r103.0<1;1,0>:f                  {Compacted}
        goto (8|M0)                          L39160                  L40424                
L39160:
        join (8|M0)                          L39216                                
L39176:
        cmp (8|M0)    (eq)f0.0   null<1>:d     r20.0<1;1,0>:d    38:w               {Compacted}
(f0.0)  cmp (8|M0)    (eq)f0.0   null<1>:d     r78.0<1;1,0>:d    0:w              
(f0.0)  goto (8|M0)                          L39216                  L40336                
L39216:
        join (8|M0)                          L40336                                
L39232:
        add (8|M0)               acc0.0<1>:d   -r20.0<1;1,0>:d   39:w               {Compacted}
        add (8|M0)               r31.0<1>:d    -r20.0<1;1,0>:d   40:w               {Compacted}
        and (8|M0)    (ne)f0.1   r120.0<1>:d   acc0.0<1;1,0>:d   63:w              
(f0.1)  goto (8|M0)                          L39312                  L39312                
L39280:
        mov (8|M0)               r30.0<1>:d    r103.0<1;1,0>:d                 
        goto (8|M0)                          L39312                  L39448                
L39312:
        join (8|M0)                          L39448                                
L39328:
        cmp (8|M0)    (lt)f0.0   null<1>:ud    r120.0<1;1,0>:ud  0x20:uw              {I@5}
(f0.0)  add (8|M0)               acc0.0<1>:d   -r120.0<1;1,0>:d  32:w              
(~f0.0) add (8|M0)               acc2.0<1>:d   r120.0<1;1,0>:d   -32:w              
(f0.0)  shr (8|M0)               r43.0<1>:ud   r103.0<1;1,0>:ud  r120.0<1;1,0>:d 
(f0.0)  shl (8|M0)               r54.0<1>:d    r109.0<1;1,0>:d   acc0.0<1;1,0>:d 
(~f0.0) shr (8|M0)               r96.0<1>:ud   r109.0<1;1,0>:ud  acc2.0<1;1,0>:d  {F@1}
(f0.0)  or (8|M0)                r96.0<1>:d    r43.0<1;1,0>:d    r54.0<1;1,0>:d   {I@2}
        mov (8|M0)               r30.0<1>:f    r96.0<1;1,0>:f                   {Compacted,I@1}
L39448:
        join (8|M0)                          L40336                                
L39464:
        add (8|M0)               r116.0<1>:d   -r20.0<1;1,0>:d   38:w               {Compacted}
        and (8|M0)    (ne)f1.1   r9.0<1>:d     r116.0<1;1,0>:d   63:w               {I@1}
(f1.1)  goto (8|M0)                          L39536                  L39536                
L39504:
        mov (8|M0)               r18.0<1>:d    r103.0<1;1,0>:d                 
        goto (8|M0)                          L39536                  L39672                
L39536:
        join (8|M0)                          L39672                                
L39552:
        cmp (8|M0)    (lt)f1.0   null<1>:ud    r9.0<1;1,0>:ud    0x20:uw              {I@5}
(f1.0)  add (8|M0)               acc0.0<1>:d   -r9.0<1;1,0>:d    32:w              
(~f1.0) add (8|M0)               acc2.0<1>:d   r9.0<1;1,0>:d     -32:w              
(f1.0)  shr (8|M0)               r41.0<1>:ud   r103.0<1;1,0>:ud  r9.0<1;1,0>:d   
(f1.0)  shl (8|M0)               r69.0<1>:d    r109.0<1;1,0>:d   acc0.0<1;1,0>:d 
(~f1.0) shr (8|M0)               r96.0<1>:ud   r109.0<1;1,0>:ud  acc2.0<1;1,0>:d  {F@1}
(f1.0)  or (8|M0)                r96.0<1>:d    r41.0<1;1,0>:d    r69.0<1;1,0>:d   {I@2}
        mov (8|M0)               r18.0<1>:f    r96.0<1;1,0>:f                   {Compacted,I@1}
L39672:
        join (8|M0)                          L40336                                
L39688:
        and (8|M0)    (ne)f0.1   r68.0<1>:d    r116.0<1;1,0>:d   63:w              
(f0.1)  goto (8|M0)                          L39768                  L39768                
L39720:
        mov (8|M0)               r82.0<1>:d    -1:w                              
        mov (8|M0)               r96.0<1>:d    -1:w                               {F@1}
        goto (8|M0)                          L39768                  L39952                
L39768:
        join (8|M0)                          L39952                                
L39784:
        cmp (8|M0)    (lt)f0.0   null<1>:ud    r68.0<1;1,0>:ud   0x20:uw              {I@6}
(f0.0)  goto (8|M0)                          L39888                  L39888                
L39816:
        add (8|M0)               acc0.0<1>:d   r68.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r5.0<1>:hf    -qnan(0x1FF):hf                             
        mov (8|M0)               r82.0<1>:d    0:w                              
        shl (8|M0)               r96.0<1>:d    r5.0<0;1,0>:w     acc0.0<1;1,0>:d  {F@1}
        goto (8|M0)                          L39888                  L39952                
L39888:
        join (8|M0)                          L39952                                
L39904:
(W)     mov (1|M0)               r5.0<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (8|M0)               r96.0<1>:d    -1:w                              
        shl (8|M0)               r82.0<1>:d    r5.0<0;1,0>:w     r68.0<1;1,0>:d   {F@1}
L39952:
        join (8|M0)                          L40336                                
L39968:
        bfn.0x60 (8|M0)          r40.0<1>:ud   r82.0<1;0>:ud     r6.3<0;0>:ud      r103.0<1>:ud     {I@2} // (s0^s1)&s2
        bfn.0x60 (8|M0)          r39.0<1>:ud   r96.0<1;0>:ud     r6.3<0;0>:ud      r109.0<1>:ud     // (s0^s1)&s2
        cmp (8|M0)    (ne)f1.1   null<1>:d     r40.0<1;1,0>:d    0:w               {I@2}
(W)     mov (1|M0)               r5.0<1>:hf    -qnan(0x1FF):hf                             
(~f1.1) cmp (8|M0)    (ne)f1.1   null<1>:d     r39.0<1;1,0>:d    0:w               {I@2}
(f1.1)  sel (8|M0)               acc0.0<1>:d   r5.0<0;1,0>:w     0:w               {F@1}
        and (8|M0)    (ne)f1.1   r8.0<1>:d     r31.0<1;1,0>:d    63:w              
        mov (8|M0)               r27.0<1>:d    -acc0.0<1;1,0>:d                
(f1.1)  goto (8|M0)                          L40144                  L40144                
L40112:
        mov (8|M0)               r96.0<1>:d    r103.0<1;1,0>:d                 
        goto (8|M0)                          L40144                  L40272                
L40144:
        join (8|M0)                          L40272                                
L40160:
        cmp (8|M0)    (lt)f1.0   null<1>:ud    r8.0<1;1,0>:ud    0x20:uw              {I@6}
(f1.0)  add (8|M0)               acc0.0<1>:d   -r8.0<1;1,0>:d    32:w              
(~f1.0) add (8|M0)               acc2.0<1>:d   r8.0<1;1,0>:d     -32:w              
(f1.0)  shr (8|M0)               r36.0<1>:ud   r103.0<1;1,0>:ud  r8.0<1;1,0>:d   
(f1.0)  shl (8|M0)               r67.0<1>:d    r109.0<1;1,0>:d   acc0.0<1;1,0>:d 
(~f1.0) shr (8|M0)               r96.0<1>:ud   r109.0<1;1,0>:ud  acc2.0<1;1,0>:d 
(f1.0)  or (8|M0)                r96.0<1>:d    r36.0<1;1,0>:d    r67.0<1;1,0>:d   {I@2}
L40272:
        join (8|M0)                          L40336                                
L40288:
        shl (8|M0)               r35.0<1>:d    r18.0<1;1,0>:d    1:w               {Compacted}
        and (8|M0)               r107.0<1>:d   r35.0<1;1,0>:d    2:w               {Compacted,I@1}
        mov (8|M0)               r35.0<1>:f    r96.0<1;1,0>:f                   {Compacted,I@1}
        mov (8|M0)               r96.0<1>:f    r30.0<1;1,0>:f                   {Compacted}
        goto (8|M0)                          L40336                  L40424                
L40336:
        join (8|M0)                          L40424                                
L40352:
        shr (8|M0)               r96.0<1>:ud   r103.0<1;1,0>:ud  2:w               {F@1}
        mov (8|M0)               r27.0<1>:d    0:w                              
        mov (8|M0)               r107.0<1>:d   0:w                              
        mov (8|M0)               r35.0<1>:f    r96.0<1;1,0>:f                   {Compacted,I@3}
        shr (8|M0)               r96.0<1>:ud   r103.0<1;1,0>:ud  1:w               {F@1}
L40424:
        join (8|M0)                          L40960                                
L40440:
        shl (8|M0)               r122.0<1>:d   r96.0<1;1,0>:d    2:w               {Compacted,I@2}
        and (8|M0)               r120.0<1>:d   r35.0<1;1,0>:d    8388607:d              
        and (8|M0)               r122.0<1>:d   r122.0<1;1,0>:d   4:w               {Compacted,I@2}
        bfn.0xFE (8|M0)          r84.0<1>:ud   r122.0<1;0>:ud    r107.0<1;0>:ud    r27.0<1>:ud      {I@1} // s0|s1|s2
        cmp (8|M0)    (eq)f0.1   null<1>:d     r84.0<1;1,0>:d    0:w               {I@1}
(~f0.1) goto (8|M0)                          L40552                  L40552                
L40520:
        mov (8|M0)               r83.0<1>:d    0:w                              
        goto (8|M0)                          L40552                  L40712                
L40552:
        join (8|M0)                          L40712                                
L40568:
        cmp (8|M0)    (gt)f0.0   null<1>:ud    r84.0<1;1,0>:ud   0x4:uw             
(~f0.0) goto (8|M0)                          L40632                  L40632                
L40600:
        mov (8|M0)               r83.0<1>:d    1:w                              
        goto (8|M0)                          L40632                  L40712                
L40632:
        join (8|M0)                          L40712                                
L40648:
        and (8|M0)    (ne)f1.0   null<1>:d     r35.0<1;1,0>:d    1:w              
(W)     mov (1|M0)               r5.0<1>:hf    0x1:hf                             
(f1.0)  cmp (8|M0)    (eq)f1.0   null<1>:d     r84.0<1;1,0>:d    4:w              
(f1.0)  sel (8|M0)               r83.0<1>:d    r5.0<0;1,0>:w     0:w               {F@1}
L40712:
        join (8|M0)                          L40960                                
L40728:
        add (8|M0)               r61.0<1>:d    r120.0<1;1,0>:d   r83.0<1;1,0>:d   {Compacted,I@2}
        add3 (8|M0)              r52.0<1>:d    r23.0<1;0>:d      r46.0<1;0>:d      -45:w              
        cmp (8|M0)    (gt)f0.0   null<1>:ud    r61.0<1;1,0>:ud   0x7FFFFF:ud              {I@2}
(f0.0)  sel (8|M0)               r50.0<1>:d    r52.0<1;1,0>:d    r47.0<1;1,0>:d   {I@2}
        cmp (8|M0)    (eq)f1.1   null<1>:d     r50.0<1;1,0>:d    255:w               {I@1}
(f1.1)  goto (8|M0)                          L40888                  L40888                
L40816:
(~f0.0) sel (8|M0)               r57.0<1>:d    r61.0<1;1,0>:d    0:w              
        and (8|M0)               r51.0<1>:d    r17.0<1;1,0>:d    -2147483648:d              
        shl (8|M0)               r34.0<1>:d    r50.0<1;1,0>:d    23:w               {Compacted}
        bfn.0xFE (8|M0)          r116.0<1>:ud  r51.0<1;0>:ud     r34.0<1;0>:ud     r57.0<1>:ud      {I@1} // s0|s1|s2
        goto (8|M0)                          L40888                  L41520                
L40888:
        join (8|M0)                          L40960                                
L40904:
        cmp (8|M0)    (gt)f1.0   null<1>:d     r17.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r5.0<1>:f     inf:f                               {Compacted}
(f1.0)  sel (8|M0)               r116.0<1>:f   r5.0<0;1,0>:f     -inf:f               {A@1}
        goto (8|M0)                          L40960                  L41520                
L40960:
        join (8|M0)                          L41280                                
L40976:
        and (8|M0)    (ne)f1.0   r53.0<1>:d    r46.0<1;1,0>:d    63:w               {F@1}
(f1.0)  goto (8|M0)                          L41040                  L41040                
L41008:
        mov (8|M0)               r76.0<1>:d    -1:w                              
        goto (8|M0)                          L41040                  L41168                
L41040:
        join (8|M0)                          L41168                                
L41056:
        cmp (8|M0)    (lt)f0.1   null<1>:ud    r53.0<1;1,0>:ud   0x20:uw              {I@5}
(f0.1)  goto (8|M0)                          L41120                  L41120                
L41088:
        mov (8|M0)               r76.0<1>:d    0:w                              
        goto (8|M0)                          L41120                  L41168                
L41120:
        join (8|M0)                          L41168                                
L41136:
(W)     mov (1|M0)               r5.0<1>:hf    -qnan(0x1FF):hf                             
        shl (8|M0)               r76.0<1>:d    r5.0<0;1,0>:w     r53.0<1;1,0>:d   {F@1}
L41168:
        join (8|M0)                          L41280                                
L41184:
        bfn.0x60 (8|M0)          r75.0<1>:ud   r76.0<1;0>:ud     r6.3<0;0>:ud      r103.0<1>:ud     {I@2} // (s0^s1)&s2
        add (8|M0)               acc0.0<1>:d   -r46.0<1;1,0>:d   23:w               {Compacted}
        and (8|M0)               r35.0<1>:d    r17.0<1;1,0>:d    -2147483648:d              
        shl (8|M0)               r32.0<1>:d    r47.0<1;1,0>:d    23:w               {Compacted}
        shl (8|M0)               r75.0<1>:d    r75.0<1;1,0>:d    acc0.0<1;1,0>:d  {I@4}
        bfn.0xFE (8|M0)          r116.0<1>:ud  r35.0<1;0>:ud     r32.0<1;0>:ud     r75.0<1>:ud      {I@1} // s0|s1|s2
        goto (8|M0)                          L41280                  L41520                
L41280:
        join (8|M0)                          L41352                                
L41296:
        cmp (8|M0)    (gt)f0.1   null<1>:d     r17.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r5.0<1>:f     inf:f                               {Compacted}
(f0.1)  sel (8|M0)               r116.0<1>:f   r5.0<0;1,0>:f     -inf:f               {A@1}
        goto (8|M0)                          L41352                  L41520                
L41352:
        join (8|M0)                          L41416                                
L41368:
        cmp (8|M0)    (lt)f0.0   null<1>:d     r17.0<1;1,0>:d    0:w               {Compacted}
(W)     mov (1|M0)               r5.0<1>:f     -0.0:f                               {Compacted}
(f0.0)  sel (8|M0)               r116.0<1>:f   r5.0<0;1,0>:f     0.0:f               {F@1}
        goto (8|M0)                          L41416                  L41520                
L41416:
        join (8|M0)                          L41488                                
L41432:
        cmp (8|M0)    (gt)f1.1   null<1>:d     r17.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r5.0<1>:f     inf:f                               {Compacted}
(f1.1)  sel (8|M0)               r116.0<1>:f   r5.0<0;1,0>:f     -inf:f               {F@1}
        goto (8|M0)                          L41488                  L41520                
L41488:
        join (8|M0)                          L41520                                
L41504:
        bfn.0xF8 (8|M0)          r116.0<1>:ud  r17.0<1;0>:ud     r6.1<0;0>:ud      r6.0<0>:ud       {F@1} // s0&s1|s2
L41520:
        join (8|M0)                          L41560                                
L41536:
        cmp (8|M0)    (lt)f0.0   null<1>:f     r7.0<1;1,0>:f     0.0:f               {Compacted,I@7}
(f0.0)  sel (8|M0)               r124.0<1>:f   -r116.0<1;1,0>:f  r116.0<1;1,0>:f  {I@2}
L41560:
        join (8|M0)                          L41576                                
L41576:
(W)     and (1|M0)               r6.0<2>:b     r5.24<0;1,0>:b    1:w              
(W)     cmp (8|M0)    (eq)f1.1   null<1>:w     r6.0<0;1,0>:b     0:w               {I@1}
(f1.1)  goto (8|M0)                          L41720                  L41720                
L41624:
        mov (8|M0)               r5.0<1>:hf    r124.0<1;1,0>:f                  {F@1}
        shl (8|M0)               r88.0<1>:d    r4.0<1;1,0>:d     1:w               {Compacted}
(W)     mov (1|M0)               a0.0<1>:ud    r6.6<0;1,0>:d                    {A@1}
        mov (8|M0)               r118.0<1>:ud  r5.0<1;1,0>:uw                   {F@1}
        add (8|M0)               r88.0<1>:d    r88.0<1;1,0>:d    r6.2<0;1,0>:d    {Compacted,I@3}
        send.ugm (8|M0)          null     r88     r118:1  a0.0        0x220E0B04           {ExBSO,A@1,$6} // wr:1+1, rd:0; store.ugm.d16u32.a32.wb.wb.bss[a0.0]
        goto (8|M0)                          L41720                  L41776                
L41720:
        join (8|M0)                          L41776                                
L41736:
(W)     mov (1|M0)               a0.0<1>:ud    r6.6<0;1,0>:d                    {A@1}
        add (8|M0)               r93.0<1>:d    r3.0<1;1,0>:d     r6.2<0;1,0>:d    {Compacted}
        send.ugm (8|M0)          null     r93     r124:1  a0.0        0x220E0504           {ExBSO,A@1,$7} // wr:1+1, rd:0; store.ugm.d32.a32.wb.wb.bss[a0.0]
L41776:
        join (8|M0)                          L41792                                
L41792:
(W)     mov (8|M0)               r112.0<1>:f   r2.0<1;1,0>:f                    {Compacted}
(W)     send.gtwy (1|M0)         null     r112    null:0  0x0            0x02000010           {EOT,A@1} // wr:1+0, rd:0; end of thread
L41816:
(W)     mov (16|M0)              null<1>:ud    0x9E09665A:ud                             
(W)     mov (16|M0)              null<1>:ud    0xA6E09A48:ud                             
(W)     mov (16|M0)              null<1>:ud    0x0:ud                             
(W)     mov (16|M0)              null<1>:ud    0x2C:ud                             
L41880:
        shr (8|M0)               r30.0<1>:ud   r125.0<1;1,0>:ud  23:w              
        shr (8|M0)               r31.0<1>:ud   r19.0<1;1,0>:ud   23:w              
        and (8|M0)    (eq)f0.1   r56.0<1>:d    r30.0<1;1,0>:d    255:w               {I@2}
        and (8|M0)               r26.0<1>:d    r19.0<1;1,0>:d    8388607:d              
        and (8|M0)               r115.0<1>:d   r125.0<1;1,0>:d   8388607:d              
        shr (8|M0)               r52.0<1>:ud   r19.0<1;1,0>:ud   31:w              
        cmp (8|M0)    (eq)f1.0   null<1>:d     r56.0<1;1,0>:d    0:w               {I@4}
        shr (8|M0)               r25.0<1>:ud   r125.0<1;1,0>:ud  31:w              
        and (8|M0)               r14.0<1>:d    r31.0<1;1,0>:d    255:w               {Compacted}
(f1.0)  goto (8|M0)                          L42088                  L42088                
L42032:
(W)     mov (1|M0)               r6.28<2>:b    1:w                              
        add (8|M0)               r122.0<1>:d   r14.0<1;1,0>:d    -r56.0<1;1,0>:d  {Compacted,I@3}
        mov (8|M0)               r13.0<1>:b    r6.28<0;1,0>:b                   {I@2}
        goto (8|M0)                          L42088                  L42176                
L42088:
        join (8|M0)                          L42176                                
L42104:
        cmp (8|M0)    (eq)f1.1   null<1>:d     r14.0<1;1,0>:d    0:w              
(f1.1)  goto (8|M0)                          L42176                  L48648                
L42136:
(W)     mov (1|M0)               r6.28<2>:b    0:w                              
        add (8|M0)               r122.0<1>:d   r14.0<1;1,0>:d    -1:w               {Compacted}
        mov (8|M0)               r13.0<1>:b    r6.28<0;1,0>:b                   {I@2}
L42176:
        join (8|M0)                          L48648                                
L42192:
        cmp (8|M0)    (eq)f1.0   null<1>:d     r122.0<1;1,0>:d   0:w               {I@3}
(f1.0)  goto (8|M0)                          L46136                  L46136                
L42224:
        cmp (8|M0)    (ne)f1.1   null<1>:d     r122.0<1;1,0>:d   1:w              
(f1.1)  goto (8|M0)                          L42384                  L42384                
L42256:
        shr (8|M0)               r119.0<1>:ud  r115.0<1;1,0>:ud  1:w              
        cmp (8|M0)    (eq)f1.1   r29.0<1>:d    r56.0<1;1,0>:d    0:w              
        and (8|M0)               r16.0<1>:d    r125.0<1;1,0>:d   1:w               {Compacted}
        or (8|M0)                r17.0<1>:d    r119.0<1;1,0>:d   4194304:d               {I@3}
        mov (8|M0)               r87.0<1>:d    0:w                              
        mov (8|M0)               r94.0<1>:f    r16.0<1;1,0>:f                   {Compacted,I@3}
        bfn.0xD8 (8|M0)          r93.0<1>:ud   r29.0<1;0>:ud     r119.0<1;0>:ud    r17.0<1>:ud      {I@2} // s0&s1|~s0&s2
        mov (8|M0)               r16.0<1>:d    0:w                               {F@1}
        goto (8|M0)                          L42384                  L43080                
L42384:
        join (8|M0)                          L43080                                
L42400:
        cmp (8|M0)    (lt)f1.0   null<1>:ud    r122.0<1;1,0>:ud  0x18:uw             
(f1.0)  goto (8|M0)                          L42816                  L42816                
L42432:
        cmp (8|M0)    (lt)f1.1   null<1>:d     r122.0<1;1,0>:d   25:w              
        mov (8|M0)               r16.0<1>:d    r13.0<1;1,0>:ub                 
(f1.1)  goto (8|M0)                          L42576                  L42576                
L42480:
        cmp (8|M0)    (eq)f1.0   null<1>:d     r122.0<1;1,0>:d   25:w              
(~f1.0) goto (8|M0)                          L42576                  L42720                
L42512:
        cmp (8|M0)    (ne)f1.0   r87.0<1>:d    r115.0<1;1,0>:d   0:w              
        mov (8|M0)               r94.0<1>:d    0:w                              
        mov (8|M0)               r93.0<1>:d    0:w                              
        goto (8|M0)                          L42576                  L43080                
L42576:
        join (8|M0)                          L42720                                
L42592:
        cmp (8|M0)    (eq)f1.1   null<1>:d     r122.0<1;1,0>:d   24:w              
(~f1.1) goto (8|M0)                          L42720                  L42720                
L42624:
        shr (8|M0)               r15.0<1>:ud   r125.0<1;1,0>:ud  22:w              
        and (8|M0)               r28.0<1>:d    r125.0<1;1,0>:d   4194303:d              
        mov (8|M0)               r94.0<1>:f    r16.0<1;1,0>:f                   {Compacted,I@7}
        mov (8|M0)               r93.0<1>:d    0:w                              
        cmp (8|M0)    (ne)f1.1   r87.0<1>:d    r28.0<1;1,0>:d    0:w               {I@2}
        and (8|M0)               r16.0<1>:d    r15.0<1;1,0>:d    1:w               {Compacted,F@1}
        goto (8|M0)                          L42720                  L43080                
L42720:
        join (8|M0)                          L42816                                
L42736:
        cmp (8|M0)    (ne)f1.0   r87.0<1>:d    r125.0<1;1,0>:d   0:w              
        mov (8|M0)               r16.0<1>:d    0:w                              
        mov (8|M0)               r94.0<1>:d    0:w                              
        mov (8|M0)               r93.0<1>:d    0:w                              
        goto (8|M0)                          L42816                  L43080                
L42816:
        join (8|M0)                          L43080                                
L42832:
        add (8|M0)               acc0.0<1>:d   r122.0<1;1,0>:d   -2:w               {Compacted}
(W)     mov (1|M0)               r6.14<1>:hf   -qnan(0x1FF):hf                             
        add (8|M0)               acc2.0<1>:d   r122.0<1;1,0>:d   -1:w               {Compacted}
        cmp (8|M0)    (eq)f1.0   null<1>:d     r56.0<1;1,0>:d    0:w              
        shr (8|M0)               r21.0<1>:ud   r115.0<1;1,0>:ud  acc0.0<1;1,0>:d 
        shl (8|M0)               r37.0<1>:d    r6.14<0;1,0>:w    acc0.0<1;1,0>:d  {F@1}
(W)     mov (1|M0)               r6.7<1>:d     -1:w                              
        add (8|M0)               acc0.0<1>:d   -r122.0<1;1,0>:d  23:w               {Compacted}
        shr (8|M0)               r81.0<1>:ud   r115.0<1;1,0>:ud  acc2.0<1;1,0>:d 
        bfn.0x60 (8|M0)          r20.0<1>:ud   r37.0<1;0>:ud     r6.7<0;0>:ud      r115.0<1>:ud     {I@3} // (s0^s1)&s2
(W)     mov (1|M0)               r6.14<1>:hf   0x1:hf                              {I@1}
        shr (8|M0)               r18.0<1>:ud   r115.0<1;1,0>:ud  r122.0<1;1,0>:d 
        and (8|M0)               r16.0<1>:d    r81.0<1;1,0>:d    1:w               {Compacted}
        shl (8|M0)               r70.0<1>:d    r6.14<0;1,0>:w    acc0.0<1;1,0>:d  {F@1}
(f1.0)  mov (8|M0)               r70.0<1>:d    0:w                              
        cmp (8|M0)    (ne)f1.1   r87.0<1>:d    r20.0<1;1,0>:d    0:w              
        mov (8|M0)               r94.0<1>:f    r16.0<1;1,0>:f                   {Compacted,I@4}
        or (8|M0)                r93.0<1>:d    r18.0<1;1,0>:d    r70.0<1;1,0>:d   {Compacted,I@2}
        and (8|M0)               r16.0<1>:d    r21.0<1;1,0>:d    1:w               {Compacted,F@1}
L43080:
        join (8|M0)                          L46136                                
L43096:
        cmp (8|M0)    (ne)f1.0   r125.0<1>:d   r87.0<1;1,0>:d    0:w               {I@4}
        shl (8|M0)               r115.0<1>:d   r93.0<1;1,0>:d    3:w               {Compacted,I@4}
        shl (8|M0)               r27.0<1>:d    r94.0<1;1,0>:d    2:w               {Compacted}
        shl (8|M0)               r124.0<1>:d   r26.0<1;1,0>:d    3:w               {Compacted}
        mov (8|M0)               r125.0<1>:d   -r125.0<1;1,0>:d                 {I@4}
        or (8|M0)                r115.0<1>:d   r115.0<1;1,0>:d   r27.0<1;1,0>:d   {Compacted,I@3}
        shl (8|M0)               r26.0<1>:d    r16.0<1;1,0>:d    1:w               {Compacted}
        bfn.0xFE (8|M0)          r66.0<1>:ud   r115.0<1;0>:ud    r26.0<1;0>:ud     r125.0<1>:ud     {I@1} // s0|s1|s2
        cmp (8|M0)    (lt)f1.1   null<1>:ud    r124.0<1;1,0>:ud  r66.0<1;1,0>:ud  {I@1}
(f1.1)  goto (8|M0)                          L43264                  L43264                
L43216:
        add (8|M0)               r83.0<1>:d    r124.0<1;1,0>:d   -r66.0<1;1,0>:d  {Compacted}
        and (8|M0)               r30.0<1>:d    r83.0<1;1,0>:d    7:w               {Compacted,I@1}
        shr (8|M0)               r123.0<1>:ud  r83.0<1;1,0>:ud   3:w              
        goto (8|M0)                          L43264                  L45744                
L43264:
        join (8|M0)                          L45744                                
L43280:
        or (8|M0)                acc0.0<1>:d   r124.0<1;1,0>:d   67108864:d              
        add (8|M0)               r89.0<1>:d    acc0.0<1;1,0>:d   -r66.0<1;1,0>:d 
        and (8|M0)    (eq)f1.0   null<1>:d     r89.0<1;1,0>:d    33554432:d               {I@1}
(~f1.0) goto (8|M0)                          L45328                  L45328                
L43344:
        and (8|M0)    (eq)f1.1   null<1>:d     r89.0<1;1,0>:d    16777216:d              
(~f1.1) goto (8|M0)                          L45280                  L45280                
L43376:
        and (8|M0)    (eq)f1.0   null<1>:d     r89.0<1;1,0>:d    8388608:d              
(~f1.0) goto (8|M0)                          L45232                  L45232                
L43408:
        and (8|M0)    (eq)f1.1   null<1>:d     r89.0<1;1,0>:d    4194304:d              
(~f1.1) goto (8|M0)                          L45184                  L45184                
L43440:
        and (8|M0)    (eq)f1.0   null<1>:d     r89.0<1;1,0>:d    2097152:d              
(~f1.0) goto (8|M0)                          L45136                  L45136                
L43472:
        and (8|M0)    (eq)f1.1   null<1>:d     r89.0<1;1,0>:d    1048576:d              
(~f1.1) goto (8|M0)                          L45088                  L45088                
L43504:
        and (8|M0)    (eq)f1.0   null<1>:d     r89.0<1;1,0>:d    524288:d              
(~f1.0) goto (8|M0)                          L45040                  L45040                
L43536:
        and (8|M0)    (eq)f1.1   null<1>:d     r89.0<1;1,0>:d    262144:d              
(~f1.1) goto (8|M0)                          L44992                  L44992                
L43568:
        and (8|M0)    (eq)f1.0   null<1>:d     r89.0<1;1,0>:d    131072:d              
(~f1.0) goto (8|M0)                          L44944                  L44944                
L43600:
        and (8|M0)    (eq)f1.1   null<1>:d     r89.0<1;1,0>:d    65536:d              
(~f1.1) goto (8|M0)                          L44896                  L44896                
L43632:
        and (8|M0)    (eq)f1.0   null<1>:d     r89.0<1;1,0>:d    0x8000:uw             
(~f1.0) goto (8|M0)                          L44848                  L44848                
L43664:
        and (8|M0)    (eq)f1.1   null<1>:d     r89.0<1;1,0>:d    16384:w              
(~f1.1) goto (8|M0)                          L44800                  L44800                
L43696:
        and (8|M0)    (eq)f1.0   null<1>:d     r89.0<1;1,0>:d    8192:w              
(~f1.0) goto (8|M0)                          L44752                  L44752                
L43728:
        and (8|M0)    (eq)f1.1   null<1>:d     r89.0<1;1,0>:d    4096:w              
(~f1.1) goto (8|M0)                          L44704                  L44704                
L43760:
        and (8|M0)    (eq)f1.0   null<1>:d     r89.0<1;1,0>:d    2048:w              
(~f1.0) goto (8|M0)                          L44656                  L44656                
L43792:
        and (8|M0)    (eq)f1.1   null<1>:d     r89.0<1;1,0>:d    1024:w              
(~f1.1) goto (8|M0)                          L44608                  L44608                
L43824:
        and (8|M0)    (eq)f1.0   null<1>:d     r89.0<1;1,0>:d    512:w              
(~f1.0) goto (8|M0)                          L44560                  L44560                
L43856:
        and (8|M0)    (eq)f1.1   null<1>:d     r89.0<1;1,0>:d    256:w              
(~f1.1) goto (8|M0)                          L44512                  L44512                
L43888:
        and (8|M0)    (eq)f1.0   null<1>:d     r89.0<1;1,0>:d    128:w              
(~f1.0) goto (8|M0)                          L44464                  L44464                
L43920:
        and (8|M0)    (eq)f1.1   null<1>:d     r89.0<1;1,0>:d    64:w              
(~f1.1) goto (8|M0)                          L44416                  L44416                
L43952:
        and (8|M0)    (eq)f1.0   null<1>:d     r89.0<1;1,0>:d    32:w              
(~f1.0) goto (8|M0)                          L44368                  L44368                
L43984:
        and (8|M0)    (eq)f1.1   null<1>:d     r89.0<1;1,0>:d    16:w              
(~f1.1) goto (8|M0)                          L44320                  L44320                
L44016:
        and (8|M0)    (eq)f1.0   null<1>:d     r89.0<1;1,0>:d    8:w              
(~f1.0) goto (8|M0)                          L44272                  L44272                
L44048:
        and (8|M0)    (eq)f1.1   null<1>:d     r89.0<1;1,0>:d    4:w              
(~f1.1) goto (8|M0)                          L44224                  L44224                
L44080:
        and (8|M0)    (eq)f1.0   null<1>:d     r89.0<1;1,0>:d    2:w              
(~f1.0) goto (8|M0)                          L44176                  L44176                
L44112:
        and (8|M0)    (eq)f1.0   null<1>:d     r89.0<1;1,0>:d    1:w              
(W)     mov (1|M0)               r6.14<1>:hf   -qnan(0x1FF):hf                             
(f1.0)  sel (8|M0)               r90.0<1>:d    r6.14<0;1,0>:w    25:w               {F@1}
        goto (8|M0)                          L44176                  L45360                
L44176:
        join (8|M0)                          L44224                                
L44192:
        mov (8|M0)               r90.0<1>:d    24:w                              
        goto (8|M0)                          L44224                  L45360                
L44224:
        join (8|M0)                          L44272                                
L44240:
        mov (8|M0)               r90.0<1>:d    23:w                              
        goto (8|M0)                          L44272                  L45360                
L44272:
        join (8|M0)                          L44320                                
L44288:
        mov (8|M0)               r90.0<1>:d    22:w                              
        goto (8|M0)                          L44320                  L45360                
L44320:
        join (8|M0)                          L44368                                
L44336:
        mov (8|M0)               r90.0<1>:d    21:w                              
        goto (8|M0)                          L44368                  L45360                
L44368:
        join (8|M0)                          L44416                                
L44384:
        mov (8|M0)               r90.0<1>:d    20:w                              
        goto (8|M0)                          L44416                  L45360                
L44416:
        join (8|M0)                          L44464                                
L44432:
        mov (8|M0)               r90.0<1>:d    19:w                              
        goto (8|M0)                          L44464                  L45360                
L44464:
        join (8|M0)                          L44512                                
L44480:
        mov (8|M0)               r90.0<1>:d    18:w                              
        goto (8|M0)                          L44512                  L45360                
L44512:
        join (8|M0)                          L44560                                
L44528:
        mov (8|M0)               r90.0<1>:d    17:w                              
        goto (8|M0)                          L44560                  L45360                
L44560:
        join (8|M0)                          L44608                                
L44576:
        mov (8|M0)               r90.0<1>:d    16:w                              
        goto (8|M0)                          L44608                  L45360                
L44608:
        join (8|M0)                          L44656                                
L44624:
        mov (8|M0)               r90.0<1>:d    15:w                              
        goto (8|M0)                          L44656                  L45360                
L44656:
        join (8|M0)                          L44704                                
L44672:
        mov (8|M0)               r90.0<1>:d    14:w                              
        goto (8|M0)                          L44704                  L45360                
L44704:
        join (8|M0)                          L44752                                
L44720:
        mov (8|M0)               r90.0<1>:d    13:w                              
        goto (8|M0)                          L44752                  L45360                
L44752:
        join (8|M0)                          L44800                                
L44768:
        mov (8|M0)               r90.0<1>:d    12:w                              
        goto (8|M0)                          L44800                  L45360                
L44800:
        join (8|M0)                          L44848                                
L44816:
        mov (8|M0)               r90.0<1>:d    11:w                              
        goto (8|M0)                          L44848                  L45360                
L44848:
        join (8|M0)                          L44896                                
L44864:
        mov (8|M0)               r90.0<1>:d    10:w                              
        goto (8|M0)                          L44896                  L45360                
L44896:
        join (8|M0)                          L44944                                
L44912:
        mov (8|M0)               r90.0<1>:d    9:w                              
        goto (8|M0)                          L44944                  L45360                
L44944:
        join (8|M0)                          L44992                                
L44960:
        mov (8|M0)               r90.0<1>:d    8:w                              
        goto (8|M0)                          L44992                  L45360                
L44992:
        join (8|M0)                          L45040                                
L45008:
        mov (8|M0)               r90.0<1>:d    7:w                              
        goto (8|M0)                          L45040                  L45360                
L45040:
        join (8|M0)                          L45088                                
L45056:
        mov (8|M0)               r90.0<1>:d    6:w                              
        goto (8|M0)                          L45088                  L45360                
L45088:
        join (8|M0)                          L45136                                
L45104:
        mov (8|M0)               r90.0<1>:d    5:w                              
        goto (8|M0)                          L45136                  L45360                
L45136:
        join (8|M0)                          L45184                                
L45152:
        mov (8|M0)               r90.0<1>:d    4:w                              
        goto (8|M0)                          L45184                  L45360                
L45184:
        join (8|M0)                          L45232                                
L45200:
        mov (8|M0)               r90.0<1>:d    3:w                              
        goto (8|M0)                          L45232                  L45360                
L45232:
        join (8|M0)                          L45280                                
L45248:
        mov (8|M0)               r90.0<1>:d    2:w                              
        goto (8|M0)                          L45280                  L45360                
L45280:
        join (8|M0)                          L45328                                
L45296:
        mov (8|M0)               r90.0<1>:d    1:w                              
        goto (8|M0)                          L45328                  L45360                
L45328:
        join (8|M0)                          L45360                                
L45344:
        mov (8|M0)               r90.0<1>:d    0:w                              
L45360:
        join (8|M0)                          L45744                                
L45376:
        cmp (8|M0)    (ne)f1.0   null<1>:d     r122.0<1;1,0>:d   1:w              
(W)     mov (1|M0)               r6.14<1>:hf   0x1:hf                             
(f0.1)  sel (8|M0)               r13.0<1>:uw   r6.14<0;1,0>:uw   0x0:uw              {F@1}
(f1.0)  sel (8|M0)               r15.0<1>:uw   r6.14<0;1,0>:uw   0x0:uw             
        or (8|M0)     (ne)f1.0   null<1>:uw    r15.0<1;1,0>:uw   r13.0<1;1,0>:uw  {I@1}
(f1.0)  goto (8|M0)                          L45672                  L45672                
L45472:
        add (8|M0)               r105.0<1>:d   r90.0<1;1,0>:d    1:w               {Compacted}
        add (8|M0)               acc0.0<1>:d   r14.0<1;1,0>:d    -1:w               {Compacted}
        cmp (8|M0)    (gt)f1.0   null<1>:ud    r14.0<1;1,0>:ud   r105.0<1;1,0>:ud {I@2}
        not (8|M0)               acc2.0<1>:d   r90.0<1;1,0>:d                  
        and (8|M0)               r86.0<1>:d    r19.0<1;1,0>:d    -2147483648:d              
        add (8|M0)               acc2.0<1>:d   r14.0<1;1,0>:d    acc2.0<1;1,0>:d 
(~f1.0) mov (8|M0)               r105.0<1>:d   acc0.0<1;1,0>:d                 
        shl (8|M0)               r25.0<1>:d    acc2.0<1;1,0>:d   23:w              
        shl (8|M0)               r105.0<1>:d   r89.0<1;1,0>:d    r105.0<1;1,0>:d  {Compacted,I@2}
(~f1.0) mov (8|M0)               r25.0<1>:d    0:w                              
        shr (8|M0)               r105.0<1>:ud  r105.0<1;1,0>:ud  3:w               {I@2}
        and (8|M0)               r105.0<1>:d   r105.0<1;1,0>:d   8388607:d               {I@1}
        bfn.0xFE (8|M0)          r105.0<1>:ud  r86.0<1;0>:ud     r25.0<1;0>:ud     r105.0<1>:ud     {I@1} // s0|s1|s2
        goto (8|M0)                          L45672                  L48760                
L45672:
        join (8|M0)                          L45744                                
L45688:
        shr (8|M0)               r24.0<1>:ud   r89.0<1;1,0>:ud   2:w              
        shl (8|M0)               r23.0<1>:d    r89.0<1;1,0>:d    1:w               {Compacted}
        add (8|M0)               r14.0<1>:d    r14.0<1;1,0>:d    -1:w               {Compacted}
        and (8|M0)               r123.0<1>:d   r24.0<1;1,0>:d    8388607:d               {I@3}
        and (8|M0)               r30.0<1>:d    r23.0<1;1,0>:d    6:w               {Compacted,I@3}
L45744:
        join (8|M0)                          L46136                                
L45760:
        cmp (8|M0)    (eq)f1.1   null<1>:d     r30.0<1;1,0>:d    0:w               {I@2}
(f1.1)  goto (8|M0)                          L45952                  L45952                
L45792:
        cmp (8|M0)    (gt)f1.0   null<1>:ud    r30.0<1;1,0>:ud   0x4:uw             
(f1.0)  goto (8|M0)                          L45904                  L45904                
L45824:
        and (8|M0)    (ne)f0.1   null<1>:d     r123.0<1;1,0>:d   1:w              
(W)     mov (1|M0)               r6.14<1>:hf   0x1:hf                             
(f0.1)  cmp (8|M0)    (eq)f0.1   null<1>:d     r30.0<1;1,0>:d    4:w              
(f0.1)  sel (8|M0)               r28.0<1>:d    r6.14<0;1,0>:w    0:w               {F@1}
        goto (8|M0)                          L45904                  L45984                
L45904:
        join (8|M0)                          L45952                                
L45920:
        mov (8|M0)               r28.0<1>:d    1:w                              
        goto (8|M0)                          L45952                  L45984                
L45952:
        join (8|M0)                          L45984                                
L45968:
        mov (8|M0)               r28.0<1>:d    0:w                              
L45984:
        join (8|M0)                          L46136                                
L46000:
        add (8|M0)               r27.0<1>:d    r123.0<1;1,0>:d   r28.0<1;1,0>:d   {Compacted,I@2}
        and (8|M0)               r85.0<1>:d    r19.0<1;1,0>:d    -2147483648:d              
        cmp (8|M0)    (gt)f1.1   r22.0<1>:ud   r27.0<1;1,0>:ud   0x7FFFFF:ud              {I@2}
        cmp (8|M0)    (gt)f0.1   null<1>:ud    r27.0<1;1,0>:ud   0x7FFFFF:ud             
        add3 (8|M0)              acc0.0<1>:d   r14.0<1;0>:d      -r22.0<1;0>:d     0:w               {I@2}
(~f0.1) sel (8|M0)               r119.0<1>:d   r27.0<1;1,0>:d    0:w              
        shl (8|M0)               r26.0<1>:d    acc0.0<1;1,0>:d   23:w              
        bfn.0xFE (8|M0)          r105.0<1>:ud  r85.0<1;0>:ud     r26.0<1;0>:ud     r119.0<1>:ud     {I@1} // s0|s1|s2
        goto (8|M0)                          L46136                  L48760                
L46136:
        join (8|M0)                          L48648                                
L46152:
        cmp (8|M0)    (eq)f1.0   null<1>:d     r26.0<1;1,0>:d    r115.0<1;1,0>:d 
(W)     mov (1|M0)               r13.1<1>:f    -0.0:f                               {Compacted}
(W)     mov (1|M0)               r13.0<1>:d    8388608:d                              
(f1.0)  goto (8|M0)                          L48568                  L48568                
L46208:
        cmp (8|M0)    (gt)f1.1   null<1>:ud    r26.0<1;1,0>:ud   r115.0<1;1,0>:ud
(f1.1)  goto (8|M0)                          L46384                  L46384                
L46240:
        cmp (8|M0)    (eq)f1.0   null<1>:d     r56.0<1;1,0>:d    0:w              
(f1.0)  goto (8|M0)                          L46304                  L46304                
L46272:
        add (8|M0)               r95.0<1>:d    r115.0<1;1,0>:d   -r26.0<1;1,0>:d  {Compacted}
        mov (8|M0)               r52.0<1>:f    r25.0<1;1,0>:f                   {Compacted}
        goto (8|M0)                          L46304                  L46488                
L46304:
        join (8|M0)                          L46384                                
L46320:
        or (8|M0)                acc0.0<1>:d   r26.0<1;1,0>:d    8388608:d              
        add (8|M0)               r53.0<1>:d    acc0.0<1;1,0>:d   -r115.0<1;1,0>:d
        bfn.0xF8 (8|M0)          r105.0<1>:ud  r19.0<1;0>:ud     r13.1<0;0>:ud     r53.0<1>:ud      {A@1} // s0&s1|s2
        goto (8|M0)                          L46384                  L48760                
L46384:
        join (8|M0)                          L46488                                
L46400:
        cmp (8|M0)    (eq)f0.1   null<1>:d     r56.0<1;1,0>:d    0:w              
        add (8|M0)               r95.0<1>:d    r26.0<1;1,0>:d    -r115.0<1;1,0>:d {Compacted}
(~f0.1) goto (8|M0)                          L46488                  L46488                
L46440:
        and (8|M0)               r21.0<1>:d    r19.0<1;1,0>:d    -2147483648:d              
        bfn.0xFE (8|M0)          r105.0<1>:ud  r21.0<1;0>:ud     r95.0<1;0>:ud     r13.0<0>:ud      {I@1} // s0|s1|s2
        goto (8|M0)                          L46488                  L48760                
L46488:
        join (8|M0)                          L48568                                
L46504:
        and (8|M0)    (eq)f1.1   null<1>:d     r95.0<1;1,0>:d    4194304:d              
(~f1.1) goto (8|M0)                          L48280                  L48280                
L46536:
        and (8|M0)    (eq)f1.0   null<1>:d     r95.0<1;1,0>:d    2097152:d              
(~f1.0) goto (8|M0)                          L48232                  L48232                
L46568:
        and (8|M0)    (eq)f0.1   null<1>:d     r95.0<1;1,0>:d    1048576:d              
(~f0.1) goto (8|M0)                          L48184                  L48184                
L46600:
        and (8|M0)    (eq)f1.1   null<1>:d     r95.0<1;1,0>:d    524288:d              
(~f1.1) goto (8|M0)                          L48136                  L48136                
L46632:
        and (8|M0)    (eq)f1.0   null<1>:d     r95.0<1;1,0>:d    262144:d              
(~f1.0) goto (8|M0)                          L48088                  L48088                
L46664:
        and (8|M0)    (eq)f0.1   null<1>:d     r95.0<1;1,0>:d    131072:d              
(~f0.1) goto (8|M0)                          L48040                  L48040                
L46696:
        and (8|M0)    (eq)f1.1   null<1>:d     r95.0<1;1,0>:d    65536:d              
(~f1.1) goto (8|M0)                          L47992                  L47992                
L46728:
        and (8|M0)    (eq)f1.0   null<1>:d     r95.0<1;1,0>:d    0x8000:uw             
(~f1.0) goto (8|M0)                          L47944                  L47944                
L46760:
        and (8|M0)    (eq)f0.1   null<1>:d     r95.0<1;1,0>:d    16384:w              
(~f0.1) goto (8|M0)                          L47896                  L47896                
L46792:
        and (8|M0)    (eq)f1.1   null<1>:d     r95.0<1;1,0>:d    8192:w              
(~f1.1) goto (8|M0)                          L47848                  L47848                
L46824:
        and (8|M0)    (eq)f1.0   null<1>:d     r95.0<1;1,0>:d    4096:w              
(~f1.0) goto (8|M0)                          L47800                  L47800                
L46856:
        and (8|M0)    (eq)f0.1   null<1>:d     r95.0<1;1,0>:d    2048:w              
(~f0.1) goto (8|M0)                          L47752                  L47752                
L46888:
        and (8|M0)    (eq)f1.1   null<1>:d     r95.0<1;1,0>:d    1024:w              
(~f1.1) goto (8|M0)                          L47704                  L47704                
L46920:
        and (8|M0)    (eq)f1.0   null<1>:d     r95.0<1;1,0>:d    512:w              
(~f1.0) goto (8|M0)                          L47656                  L47656                
L46952:
        and (8|M0)    (eq)f0.1   null<1>:d     r95.0<1;1,0>:d    256:w              
(~f0.1) goto (8|M0)                          L47608                  L47608                
L46984:
        and (8|M0)    (eq)f1.1   null<1>:d     r95.0<1;1,0>:d    128:w              
(~f1.1) goto (8|M0)                          L47560                  L47560                
L47016:
        and (8|M0)    (eq)f1.0   null<1>:d     r95.0<1;1,0>:d    64:w              
(~f1.0) goto (8|M0)                          L47512                  L47512                
L47048:
        and (8|M0)    (eq)f0.1   null<1>:d     r95.0<1;1,0>:d    32:w              
(~f0.1) goto (8|M0)                          L47464                  L47464                
L47080:
        and (8|M0)    (eq)f1.1   null<1>:d     r95.0<1;1,0>:d    16:w              
(~f1.1) goto (8|M0)                          L47416                  L47416                
L47112:
        and (8|M0)    (eq)f1.0   null<1>:d     r95.0<1;1,0>:d    8:w              
(~f1.0) goto (8|M0)                          L47368                  L47368                
L47144:
        and (8|M0)    (eq)f0.1   null<1>:d     r95.0<1;1,0>:d    4:w              
(~f0.1) goto (8|M0)                          L47320                  L47320                
L47176:
        and (8|M0)    (eq)f1.1   null<1>:d     r95.0<1;1,0>:d    2:w              
(~f1.1) goto (8|M0)                          L47272                  L47272                
L47208:
        and (8|M0)    (eq)f0.1   null<1>:d     r95.0<1;1,0>:d    1:w              
(W)     mov (1|M0)               r6.14<1>:hf   -qnan(0x1FF):hf                             
(f0.1)  sel (8|M0)               r97.0<1>:d    r6.14<0;1,0>:w    22:w               {F@1}
        goto (8|M0)                          L47272                  L48312                
L47272:
        join (8|M0)                          L47320                                
L47288:
        mov (8|M0)               r97.0<1>:d    21:w                              
        goto (8|M0)                          L47320                  L48312                
L47320:
        join (8|M0)                          L47368                                
L47336:
        mov (8|M0)               r97.0<1>:d    20:w                              
        goto (8|M0)                          L47368                  L48312                
L47368:
        join (8|M0)                          L47416                                
L47384:
        mov (8|M0)               r97.0<1>:d    19:w                              
        goto (8|M0)                          L47416                  L48312                
L47416:
        join (8|M0)                          L47464                                
L47432:
        mov (8|M0)               r97.0<1>:d    18:w                              
        goto (8|M0)                          L47464                  L48312                
L47464:
        join (8|M0)                          L47512                                
L47480:
        mov (8|M0)               r97.0<1>:d    17:w                              
        goto (8|M0)                          L47512                  L48312                
L47512:
        join (8|M0)                          L47560                                
L47528:
        mov (8|M0)               r97.0<1>:d    16:w                              
        goto (8|M0)                          L47560                  L48312                
L47560:
        join (8|M0)                          L47608                                
L47576:
        mov (8|M0)               r97.0<1>:d    15:w                              
        goto (8|M0)                          L47608                  L48312                
L47608:
        join (8|M0)                          L47656                                
L47624:
        mov (8|M0)               r97.0<1>:d    14:w                              
        goto (8|M0)                          L47656                  L48312                
L47656:
        join (8|M0)                          L47704                                
L47672:
        mov (8|M0)               r97.0<1>:d    13:w                              
        goto (8|M0)                          L47704                  L48312                
L47704:
        join (8|M0)                          L47752                                
L47720:
        mov (8|M0)               r97.0<1>:d    12:w                              
        goto (8|M0)                          L47752                  L48312                
L47752:
        join (8|M0)                          L47800                                
L47768:
        mov (8|M0)               r97.0<1>:d    11:w                              
        goto (8|M0)                          L47800                  L48312                
L47800:
        join (8|M0)                          L47848                                
L47816:
        mov (8|M0)               r97.0<1>:d    10:w                              
        goto (8|M0)                          L47848                  L48312                
L47848:
        join (8|M0)                          L47896                                
L47864:
        mov (8|M0)               r97.0<1>:d    9:w                              
        goto (8|M0)                          L47896                  L48312                
L47896:
        join (8|M0)                          L47944                                
L47912:
        mov (8|M0)               r97.0<1>:d    8:w                              
        goto (8|M0)                          L47944                  L48312                
L47944:
        join (8|M0)                          L47992                                
L47960:
        mov (8|M0)               r97.0<1>:d    7:w                              
        goto (8|M0)                          L47992                  L48312                
L47992:
        join (8|M0)                          L48040                                
L48008:
        mov (8|M0)               r97.0<1>:d    6:w                              
        goto (8|M0)                          L48040                  L48312                
L48040:
        join (8|M0)                          L48088                                
L48056:
        mov (8|M0)               r97.0<1>:d    5:w                              
        goto (8|M0)                          L48088                  L48312                
L48088:
        join (8|M0)                          L48136                                
L48104:
        mov (8|M0)               r97.0<1>:d    4:w                              
        goto (8|M0)                          L48136                  L48312                
L48136:
        join (8|M0)                          L48184                                
L48152:
        mov (8|M0)               r97.0<1>:d    3:w                              
        goto (8|M0)                          L48184                  L48312                
L48184:
        join (8|M0)                          L48232                                
L48200:
        mov (8|M0)               r97.0<1>:d    2:w                              
        goto (8|M0)                          L48232                  L48312                
L48232:
        join (8|M0)                          L48280                                
L48248:
        mov (8|M0)               r97.0<1>:d    1:w                              
        goto (8|M0)                          L48280                  L48312                
L48280:
        join (8|M0)                          L48312                                
L48296:
        mov (8|M0)               r97.0<1>:d    0:w                              
L48312:
        join (8|M0)                          L48568                                
L48328:
        add (8|M0)               r113.0<1>:d   r97.0<1;1,0>:d    1:w               {Compacted,I@2}
        cmp (8|M0)    (gt)f1.0   null<1>:ud    r14.0<1;1,0>:ud   r113.0<1;1,0>:ud {I@1}
(f1.0)  goto (8|M0)                          L48424                  L48424                
L48368:
        add (8|M0)               acc0.0<1>:d   r14.0<1;1,0>:d    -1:w               {Compacted}
        mov (8|M0)               r99.0<1>:d    0:w                              
        shl (8|M0)               r105.0<1>:d   r95.0<1;1,0>:d    acc0.0<1;1,0>:d 
        goto (8|M0)                          L48424                  L48512                
L48424:
        join (8|M0)                          L48512                                
L48440:
        not (8|M0)               acc0.0<1>:d   r97.0<1;1,0>:d                  
        shl (8|M0)               r19.0<1>:d    r95.0<1;1,0>:d    r113.0<1;1,0>:d  {Compacted}
        add (8|M0)               acc0.0<1>:d   r14.0<1;1,0>:d    acc0.0<1;1,0>:d 
        and (8|M0)               r105.0<1>:d   r19.0<1;1,0>:d    8388607:d               {I@2}
        shl (8|M0)               r99.0<1>:d    acc0.0<1;1,0>:d   23:w              
L48512:
        join (8|M0)                          L48568                                
L48528:
        shl (8|M0)               r18.0<1>:d    r52.0<1;1,0>:d    31:w               {Compacted}
        bfn.0xFE (8|M0)          r105.0<1>:ud  r18.0<1;0>:ud     r99.0<1;0>:ud     r105.0<1>:ud     {I@1} // s0|s1|s2
        goto (8|M0)                          L48568                  L48760                
L48568:
        join (8|M0)                          L48648                                
L48584:
        cmp (8|M0)    (eq)f0.1   null<1>:d     r56.0<1;1,0>:d    0:w              
        bfn.0xF8 (8|M0)          r78.0<1>:ud   r19.0<1;0>:ud     r13.1<0;0>:ud     r13.0<0>:ud      // s0&s1|s2
(f0.1)  sel (8|M0)               r105.0<1>:f   r78.0<1;1,0>:f    0.0:f               {I@1}
        goto (8|M0)                          L48648                  L48760                
L48648:
        join (8|M0)                          L48760                                
L48664:
        cmp (8|M0)    (gt)f0.1   null<1>:ud    r26.0<1;1,0>:ud   r115.0<1;1,0>:ud {F@1}
        add (8|M0)               acc0.0<1>:d   r115.0<1;1,0>:d   -r26.0<1;1,0>:d 
        add (8|M0)               r80.0<1>:d    r26.0<1;1,0>:d    -r115.0<1;1,0>:d {Compacted}
(f0.1)  sel (8|M0)               acc2.0<1>:d   r52.0<1;1,0>:d    r25.0<1;1,0>:d  
(~f0.1) mov (8|M0)               r80.0<1>:d    acc0.0<1;1,0>:d                 
        shl (8|M0)               r121.0<1>:d   acc2.0<1;1,0>:d   31:w              
        or (8|M0)                r105.0<1>:d   r121.0<1;1,0>:d   r80.0<1;1,0>:d   {Compacted,I@1}
L48760:
        join (8|M0)                          L48776                                
L48776:
        mov (8|M0)               r43.0<1>:f    r105.0<1;1,0>:f                  {Compacted,I@2}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        ret (8|M0)                           r6.4                             {A@1}
L48832:
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
