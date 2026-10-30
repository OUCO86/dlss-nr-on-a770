L0:
(W)     mov (8|M0)               r127.0<1>:ud  0x0:ud                             
(W)     and (1|M0)               r127.2<1>:ud  r0.0<0;1,0>:ud    0xFFFFFFC0:ud             
(W)     and (1|M0)               r127.0<1>:uw  r0.4<0;1,0>:uw    0xFF:uw             
(W)     add (1|M0)               r127.2<1>:ud  r127.2<0;1,0>:ud  0x60:ud              {I@2}
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
(W)     add (1|M0)               r127.2<1>:ud  r127.2<0;1,0>:ud  0x40:uw              {$2.src}
(W)     send.dc0 (8|M0)          r7       r127    null:0  0x0            0x021842FD           {A@1,$3} // wr:1h+0, rd:1; oword aligned block read x2
(W)     mov (8|M0)               r2.0<1>:ud    r0.0<1;1,0>:ud                   {$0.dst}
(W)     or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x4C0:uw              {A@1}
(W)     mul (1|M0)               acc0.0<1>:ud  r4.3<0;1,0>:ud    r2.2<0;1,0>:uw   {A@1}
(W)     mach (1|M0)              r79.0<1>:ud   r4.3<0;1,0>:ud    r2.1<0;1,0>:ud   {AccWrEn}
        mov (8|M0)               r98.0<1>:d    r1.0<1;1,0>:uw                  
(W)     mov (1|M0)               r78.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (8|M0)              r107.0<1>:ud  r78.0<0;1,0>:ud   r98.0<1;1,0>:ud  {AccWrEn,Compacted,I@1}
        add (8|M0)               r106.0<1>:ud  acc0.0<1;1,0>:ud  r79.0<0;1,0>:ud 
        addc (8|M0)              r8.0<1>:ud    r107.0<1;1,0>:ud  r4.0<0;1,0>:ud   {AccWrEn,Compacted,I@2}
        cmp (8|M0)    (lt)f0.0   null<1>:ud    r8.0<1;1,0>:ud    r4.6<0;1,0>:ud   {I@1}
        add (8|M0)               r3.0<1>:ud    acc0.0<1;1,0>:ud  r106.0<1;1,0>:ud {$1.dst}
(f0.0)  cmp (8|M0)    (eq)f0.0   null<1>:d     r3.0<1;1,0>:d     r4.7<0;1,0>:d    {I@1}
(~f0.0) cmp (8|M0)    (lt)f0.0   null<1>:ud    r3.0<1;1,0>:ud    r4.7<0;1,0>:ud  
(~f0.0) goto (8|M0)                          L36616                  L36616                
L488:
(W)     mov (2|M0)               r5.5<1>:d     r6.2<1;1,0>:d                    {$2.dst}
(W)     mov (2|M0)               r6.0<1>:d     r6.4<1;1,0>:d                   
(W)     shr (1|M0)               r7.7<1>:ud    r5.4<0;1,0>:ud    1:w               {$3.dst}
(W)     cmp (8|M0)    (eq)f0.0   null<1>:d     r5.0<0;1,0>:d     0:w              
(W)     mov (1|M0)               r7.6<1>:f     -0.0:f                               {Compacted}
(W)     mov (1|M0)               r7.5<1>:f     inf:f                               {Compacted}
(W)     mov (1|M0)               r7.4<1>:d     -1:w                              
(W)     mov (1|M0)               r7.3<1>:d     48:w                              
(W)     mov (1|M0)               r5.7<1>:d     6:w                              
        mov (8|M0)               r10.0<1>:f    r8.0<1;1,0>:f                    {Compacted}
        mov (8|M0)               r9.0<1>:f     r3.0<1;1,0>:f                    {Compacted}
L632:
        shr (8|M0)               r98.0<1>:ud   r10.0<1;1,0>:ud   5:w               {F@2}
        shl (8|M0)               r75.0<1>:d    r9.0<1;1,0>:d     23:w               {Compacted,F@1}
        shr (8|M0)               r97.0<1>:ud   r10.0<1;1,0>:ud   9:w              
        shl (8|M0)               r56.0<1>:d    r98.0<1;1,0>:d    2:w               {Compacted,I@3}
        shl (8|M0)               r98.0<1>:d    r98.0<1;1,0>:d    1:w               {Compacted}
        or (8|M0)                r57.0<1>:d    r97.0<1;1,0>:d    r75.0<1;1,0>:d   {Compacted,I@3}
        and (8|M0)               r70.0<1>:d    r56.0<1;1,0>:d    48:w               {Compacted,I@3}
        and (8|M0)               r74.0<1>:d    r98.0<1;1,0>:d    6:w               {Compacted,I@3}
(~f0.0) goto (8|M0)                          L760                  L760                
L728:
        mov (8|M0)               r32.0<1>:d    -1:w                              
        goto (8|M0)                          L760                  L1112                
L760:
        join (8|M0)                          L1112                                
L776:
(W)     xor (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x30:uw              {A@1}
(W)     mov (1|M0)               r6.3<1>:f     r5.0<0;1,0>:ud                   {Compacted,A@1}
        mov (8|M0)               r48.0<1>:f    r57.0<1;1,0>:ud                  {Compacted,I@7}
(W)     mov (1|M0)               r6.2<1>:ud    r6.3<0;1,0>:f                    {F@2}
(W)     math.inv (1|M0)          r6.4<1>:f     r6.3<0;1,0>:f                    {$4}
(W)     add (1|M0)               r6.5<1>:d     r5.0<0;1,0>:d     -r6.2<0;1,0>:d   {I@1}
(W)     mov (1|M0)               r6.2<1>:f     0xB4C00000:f                               {Compacted,I@1}
        mov (8|M0)               r125.0<1>:ud  r48.0<1;1,0>:f                   {F@2}
        sync.nop                             null                             {Compacted,$4.dst}
(W)     mad (1|M0)               r6.2<1>:f     r6.4<0;0>:f       r6.2<0;0>:f       r6.4<0>:f        {F@1}
        add (8|M0)               r125.0<1>:d   r57.0<1;1,0>:d    -r125.0<1;1,0>:d {Compacted,I@1}
        mul (8|M0)               r126.0<1>:f   r48.0<1;1,0>:f    r6.2<0;1,0>:f    {Compacted,F@1}
(W)     mov (1|M0)               r6.4<1>:f     r6.5<0;1,0>:ud                  
        mov (8|M0)               r61.0<1>:ud   r126.0<1;1,0>:f                  {F@2}
        mov (8|M0)               r32.0<1>:f    r125.0<1;1,0>:ud                 {Compacted,I@2}
        mov (8|M0)               r24.0<1>:f    r61.0<1;1,0>:ud                  {Compacted,I@1}
        mad (8|M0)               acc0.0<1>:f   r48.0<1;0>:f      r24.0<1;0>:f      -r6.3<0>:f       {Compacted,F@1}
        mad (8|M0)               acc1.0<1>:f   r32.0<1;0>:f      r24.0<1;0>:f      -r6.4<0>:f       {Compacted}
        add (8|M0)               acc0.0<1>:f   acc0.0<1;1,0>:f   acc1.0<1;1,0>:f 
        mul (8|M0)               r87.0<1>:f    r6.2<0;1,0>:f     acc0.0<1;1,0>:f 
(W)     xor (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x30:uw              {A@1}
        mov (8|M0)               r104.0<1>:ud  r87.0<1;1,0>:f                   {A@1}
        add (8|M0)               r41.0<1>:d    r104.0<1;1,0>:d   r61.0<1;1,0>:d   {Compacted,I@1}
(W)     mul (8|M0)               acc0.0<1>:d   r41.0<1;1,0>:d    r5.0<0;1,0>:uw   {Compacted,I@1}
        mach (8|M0)              r41.0<1>:d    r41.0<1;1,0>:d    r5.0<0;1,0>:d    {Compacted}
        add (8|M0)               r41.0<1>:d    r57.0<1;1,0>:d    -r41.0<1;1,0>:d  {Compacted,I@1}
        cmp (8|M0)    (ge)f1.1   r94.0<1>:ud   r41.0<1;1,0>:ud   r5.0<0;1,0>:ud   {I@1}
        add3 (8|M0)              r32.0<1>:d    r104.0<1;0>:d     r61.0<1;0>:d      -r94.0<1>:d      {I@1}
L1112:
        join (8|M0)                          L36616                                
L1128:
(W)     mul (8|M0)               acc0.0<1>:d   r32.0<1;1,0>:d    r5.0<0;1,0>:uw   {Compacted,I@2}
        mach (8|M0)              r53.0<1>:d    r32.0<1;1,0>:d    r5.0<0;1,0>:d    {Compacted}
        shl (8|M0)               r99.0<1>:d    r32.0<1;1,0>:d    3:w               {Compacted}
        add (8|M0)               acc0.0<1>:d   r57.0<1;1,0>:d    -r53.0<1;1,0>:d  {I@2}
        shr (8|M0)               r93.0<1>:ud   r70.0<1;1,0>:ud   3:w              
        shl (8|M0)               r53.0<1>:d    acc0.0<1;1,0>:d   3:w              
        or (8|M0)                r99.0<1>:d    r99.0<1;1,0>:d    r93.0<1;1,0>:d   {Compacted,I@2}
        bfn.0xEA (8|M0)          r94.0<1>:ud   r53.0<1;0>:ud     r98.0<1;0>:ud     r5.7<0>:ud       {I@2} // s0|s1&s2
        cmp (8|M0)    (lt)f1.1   null<1>:ud    r94.0<1;1,0>:ud   r5.2<0;1,0>:ud   {I@1}
(~f1.1) cmp (8|M0)    (lt)f1.1   null<1>:ud    r99.0<1;1,0>:ud   r5.1<0;1,0>:ud  
(f1.1)  goto (8|M0)                          L36464                  L36464                
L1272:
        add (8|M0)               r17.0<1>:d    r99.0<1;1,0>:d    -r5.1<0;1,0>:d   {Compacted}
        cmp (8|M0)    (lt)f0.1   null<1>:ud    r17.0<1;1,0>:ud   r5.3<0;1,0>:ud   {I@1}
(~f0.1) goto (8|M0)                          L36464                  L36464                
L1312:
        add (8|M0)               r16.0<1>:d    r94.0<1;1,0>:d    -r5.2<0;1,0>:d   {Compacted}
        cmp (8|M0)    (lt)f1.1   null<1>:ud    r16.0<1;1,0>:ud   r5.4<0;1,0>:ud   {I@1}
(~f1.1) goto (8|M0)                          L36464                  L36464                
L1352:
        shr (8|M0)               r58.0<1>:ud   r9.0<1;1,0>:ud    9:w              
        bfn.0xF8 (8|M0)          r81.0<1>:ud   r56.0<1;0>:ud     r7.3<0;0>:ud      r74.0<1>:ud      // s0&s1|s2
        shl (8|M0)               r98.0<1>:d    r57.0<1;1,0>:d    13:w               {Compacted}
        shr (8|M0)               r86.0<1>:ud   r57.0<1;1,0>:ud   19:w              
        shl (8|M0)               r58.0<1>:d    r58.0<1;1,0>:d    13:w               {Compacted,I@4}
        and (8|M0)               r11.0<1>:d    r10.0<1;1,0>:d    31:w               {Compacted}
        shl (8|M0)               r81.0<1>:d    r81.0<1;1,0>:d    7:w               {Compacted,I@5}
        addc (8|M0)              r85.0<1>:ud   r98.0<1;1,0>:ud   r5.5<0;1,0>:ud   {AccWrEn,Compacted,I@5}
        or (8|M0)                r58.0<1>:d    r58.0<1;1,0>:d    r86.0<1;1,0>:d   {Compacted,I@4}
        shl (8|M0)               r19.0<1>:d    r11.0<1;1,0>:d    2:w               {Compacted,I@4}
        add3 (8|M0)              r84.0<1>:ud   acc0.0<1;0>:ud    r58.0<1;0>:ud     r5.6<0>:ud       {I@2}
        addc (8|M0)              r21.0<1>:ud   r85.0<1;1,0>:ud   r81.0<1;1,0>:ud  {AccWrEn,Compacted}
        shr (8|M0)               r18.0<1>:ud   r11.0<1;1,0>:ud   30:w              
        add (8|M0)               r20.0<1>:ud   acc0.0<1;1,0>:ud  r84.0<1;1,0>:ud  {I@3}
        addc (8|M0)              r26.0<1>:ud   r21.0<1;1,0>:ud   r19.0<1;1,0>:ud  {AccWrEn,Compacted,I@3}
        mov (8|M0)               r92.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        addc (8|M0)              r113.0<1>:ud  r21.0<1;1,0>:ud   0x400:ud              {AccWrEn,Compacted}
        add3 (8|M0)              r32.0<1>:ud   r92.0<1;0>:ud     r20.0<1;0>:ud     r18.0<1>:ud      {I@2}
        add (8|M0)               r124.0<1>:ud  acc0.0<1;1,0>:ud  r20.0<1;1,0>:ud 
        mov (8|M0)               r78.1<2>:ud   r32.0<1;1,0>:ud                  {I@2}
        mov (8|M0)               r78.0<2>:d    r26.0<1;1,0>:d                  
        addc (8|M0)              r56.0<1>:ud   r113.0<1;1,0>:ud  r19.0<1;1,0>:ud  {AccWrEn,Compacted}
        send.ugm (8|M0)          r15      r78     null:0  0x0            0x04180580           {A@2,$5} // wr:2+0, rd:1; load.ugm.d32.a64.ca.ca
        add3 (8|M0)              r50.0<1>:ud   acc0.0<1;0>:ud    r124.0<1;0>:ud    r18.0<1>:ud     
        shr (8|M0)               r91.0<1>:ud   r15.0<1;1,0>:ud   23:w               {$5.dst}
        and (8|M0)    (ne)f1.0   r23.0<1>:d    r15.0<1;1,0>:d    8388607:d              
        and (8|M0)               r109.0<1>:d   r91.0<1;1,0>:d    255:w               {Compacted,I@2}
(f1.0)  cmp (8|M0)    (eq)f1.0   null<1>:d     r109.0<1;1,0>:d   255:w               {I@1}
(~f1.0) goto (8|M0)                          L1736                  L1736                
L1712:
        mov (8|M0)               r15.0<1>:f    qnan(0x0):f                               {Compacted}
        goto (8|M0)                          L1736                  L6832                
L1736:
        join (8|M0)                          L6832                                
L1752:
        mov (8|M0)               r86.0<2>:d    r56.0<1;1,0>:d                  
        mov (8|M0)               r86.1<2>:d    r50.0<1;1,0>:d                  
        send.ugm (8|M0)          r14      r86     null:0  0x0            0x04180580           {A@1,$6} // wr:2+0, rd:1; load.ugm.d32.a64.ca.ca
        shr (8|M0)               r90.0<1>:ud   r14.0<1;1,0>:ud   23:w               {$6.dst}
        and (8|M0)    (ne)f0.1   r121.0<1>:d   r14.0<1;1,0>:d    8388607:d              
        and (8|M0)               r104.0<1>:d   r90.0<1;1,0>:d    255:w               {Compacted,I@2}
(f0.1)  cmp (8|M0)    (eq)f0.1   null<1>:d     r104.0<1;1,0>:d   255:w               {I@1}
(~f0.1) goto (8|M0)                          L1896                  L1896                
L1872:
        mov (8|M0)               r15.0<1>:f    qnan(0x0):f                               {Compacted}
        goto (8|M0)                          L1896                  L6832                
L1896:
        join (8|M0)                          L6832                                
L1912:
        cmp (8|M0)    (eq)f1.1   null<1>:d     r23.0<1;1,0>:d    0:w              
        shr (8|M0)               r68.0<1>:ud   r15.0<1;1,0>:ud   31:w               {F@1}
        shr (8|M0)               r67.0<1>:ud   r14.0<1;1,0>:ud   31:w              
        cmp (8|M0)    (eq)f0.1   null<1>:d     r121.0<1;1,0>:d   0:w              
(f1.1)  cmp (8|M0)    (eq)f1.1   null<1>:d     r109.0<1;1,0>:d   255:w              
(f1.1)  goto (8|M0)                          L6752                  L6752                
L2008:
        cmp (8|M0)    (eq)f1.1   null<1>:d     r104.0<1;1,0>:d   255:w              
(W)     mov (1|M0)               r6.4<1>:hf    0x1:hf                             
        or (8|M0)                r89.0<1>:d    r109.0<1;1,0>:d   r23.0<1;1,0>:d   {Compacted}
(f0.1)  sel (8|M0)               r12.0<1>:uw   r6.4<0;1,0>:uw    0x0:uw              {F@1}
(f1.1)  sel (8|M0)               r13.0<1>:uw   r6.4<0;1,0>:uw    0x0:uw             
        and (8|M0)    (ne)f1.1   null<1>:uw    r13.0<1;1,0>:uw   r12.0<1;1,0>:uw  {I@1}
(~f1.1) cmp (8|M0)    (eq)f1.1   null<1>:d     r89.0<1;1,0>:d    0:w              
(~f1.1) goto (8|M0)                          L2152                  L2152                
L2128:
        mov (8|M0)               r15.0<1>:f    r14.0<1;1,0>:f                   {Compacted}
        goto (8|M0)                          L2152                  L6832                
L2152:
        join (8|M0)                          L6752                                
L2168:
        or (8|M0)     (eq)f1.0   null<1>:d     r104.0<1;1,0>:d   r121.0<1;1,0>:d 
(f1.0)  goto (8|M0)                          L6752                  L6832                
L2200:
        cmp (8|M0)    (eq)f0.1   null<1>:d     r68.0<1;1,0>:d    r67.0<1;1,0>:d  
        cmp (8|M0)    (lt)f1.0   null<1>:ud    r104.0<1;1,0>:ud  r109.0<1;1,0>:ud
(f0.1)  goto (8|M0)                          L2456                  L2456                
L2248:
(f1.0)  goto (8|M0)                          L2352                  L2352                
L2264:
        mov (8|M0)               r56.0<1>:f    r14.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r42.0<1>:f    r15.0<1;1,0>:f                   {Compacted,F@2}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        call (8|M0)              r6.2          L36720                                 {A@1}
L2328:
        mov (8|M0)               r15.0<1>:f    r76.0<1;1,0>:f                   {Compacted}
        goto (8|M0)                          L2352                  L6832                
L2352:
        join (8|M0)                          L2456                                
L2368:
        mov (8|M0)               r56.0<1>:f    r15.0<1;1,0>:f                   {Compacted,F@1}
        mov (8|M0)               r42.0<1>:f    r14.0<1;1,0>:f                   {Compacted}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        call (8|M0)              r6.2          L36720                                 {A@1}
L2432:
        mov (8|M0)               r15.0<1>:f    r76.0<1;1,0>:f                   {Compacted}
        goto (8|M0)                          L2456                  L6832                
L2456:
        join (8|M0)                          L6752                                
L2472:
(f1.0)  goto (8|M0)                          L4696                  L4696                
L2488:
        cmp (8|M0)    (eq)f0.1   null<1>:d     r109.0<1;1,0>:d   0:w              
(f0.1)  goto (8|M0)                          L2576                  L2576                
L2520:
(W)     mov (1|M0)               r6.8<2>:b     1:w                              
        add (8|M0)               r118.0<1>:d   r104.0<1;1,0>:d   -r109.0<1;1,0>:d {Compacted}
        mov (8|M0)               r12.0<1>:b    r6.8<0;1,0>:b                    {I@2}
        goto (8|M0)                          L2576                  L2664                
L2576:
        join (8|M0)                          L2664                                
L2592:
        cmp (8|M0)    (eq)f1.1   null<1>:d     r104.0<1;1,0>:d   0:w              
(f1.1)  goto (8|M0)                          L2664                  L4640                
L2624:
(W)     mov (1|M0)               r6.8<2>:b     0:w                              
        add (8|M0)               r118.0<1>:d   r104.0<1;1,0>:d   -1:w               {Compacted}
        mov (8|M0)               r12.0<1>:b    r6.8<0;1,0>:b                    {I@2}
L2664:
        join (8|M0)                          L4640                                
L2680:
        cmp (8|M0)    (lt)f1.0   null<1>:d     r118.0<1;1,0>:d   1:w               {I@3}
(f1.0)  goto (8|M0)                          L3392                  L3392                
L2712:
        cmp (8|M0)    (eq)f1.1   null<1>:d     r118.0<1;1,0>:d   1:w              
(f1.1)  goto (8|M0)                          L3272                  L3272                
L2744:
        cmp (8|M0)    (lt)f1.0   null<1>:ud    r118.0<1;1,0>:ud  0x18:uw             
(f1.0)  goto (8|M0)                          L3032                  L3032                
L2776:
        cmp (8|M0)    (lt)f0.1   null<1>:d     r118.0<1;1,0>:d   25:w              
        mov (8|M0)               r126.0<1>:d   r12.0<1;1,0>:ub                  {I@7}
(f0.1)  goto (8|M0)                          L2928                  L2928                
L2824:
        cmp (8|M0)    (eq)f1.1   null<1>:d     r118.0<1;1,0>:d   25:w              
(~f1.1) goto (8|M0)                          L2928                  L3440                
L2856:
        cmp (8|M0)    (ne)f1.0   r74.0<1>:d    r23.0<1;1,0>:d    0:w              
        mov (8|M0)               r50.0<1>:f    r126.0<1;1,0>:f                  {Compacted,I@5}
        mov (8|M0)               r83.0<1>:d    0:w                              
        mov (8|M0)               r126.0<1>:d   0:w                               {F@1}
        goto (8|M0)                          L2928                  L3520                
L2928:
        join (8|M0)                          L3032                                
L2944:
        shr (8|M0)               r88.0<1>:ud   r15.0<1;1,0>:ud   22:w              
        and (8|M0)               r87.0<1>:d    r15.0<1;1,0>:d    4194303:d              
        mov (8|M0)               r83.0<1>:d    0:w                              
        and (8|M0)               r50.0<1>:d    r88.0<1;1,0>:d    1:w               {Compacted,I@3}
        cmp (8|M0)    (ne)f0.1   r74.0<1>:d    r87.0<1;1,0>:d    0:w               {I@3}
        goto (8|M0)                          L3032                  L3520                
L3032:
        join (8|M0)                          L3272                                
L3048:
        add (8|M0)               acc0.0<1>:d   r118.0<1;1,0>:d   -2:w               {Compacted}
(W)     mov (1|M0)               r6.4<1>:hf    -qnan(0x1FF):hf                             
        add (8|M0)               acc2.0<1>:d   r118.0<1;1,0>:d   -1:w               {Compacted}
        add (8|M0)               r73.0<1>:d    -r118.0<1;1,0>:d  23:w               {Compacted}
        shr (8|M0)               r86.0<1>:ud   r23.0<1;1,0>:ud   acc0.0<1;1,0>:d 
        shl (8|M0)               r34.0<1>:d    r6.4<0;1,0>:w     acc0.0<1;1,0>:d  {F@1}
(W)     mov (1|M0)               r6.4<1>:hf    0x1:hf                              {I@1}
        shr (8|M0)               r61.0<1>:ud   r23.0<1;1,0>:ud   r118.0<1;1,0>:d 
        shr (8|M0)               r124.0<1>:ud  r23.0<1;1,0>:ud   acc2.0<1;1,0>:d 
        bfn.0x60 (8|M0)          r65.0<1>:ud   r34.0<1;0>:ud     r7.4<0;0>:ud      r23.0<1>:ud      // (s0^s1)&s2
        shl (8|M0)               r73.0<1>:d    r6.4<0;1,0>:w     r73.0<1;1,0>:d   {F@1}
(f0.1)  mov (8|M0)               r73.0<1>:d    0:w                              
        and (8|M0)               r50.0<1>:d    r86.0<1;1,0>:d    1:w               {Compacted}
        and (8|M0)               r126.0<1>:d   r124.0<1;1,0>:d   1:w               {Compacted,I@5}
        cmp (8|M0)    (ne)f1.1   r74.0<1>:d    r65.0<1;1,0>:d    0:w               {I@5}
        or (8|M0)                r83.0<1>:d    r61.0<1;1,0>:d    r73.0<1;1,0>:d   {Compacted,I@4}
        goto (8|M0)                          L3272                  L3520                
L3272:
        join (8|M0)                          L3392                                
L3288:
        shr (8|M0)               r23.0<1>:ud   r23.0<1;1,0>:ud   1:w              
        and (8|M0)               r126.0<1>:d   r15.0<1;1,0>:d    1:w               {Compacted}
        or (8|M0)                r85.0<1>:d    r23.0<1;1,0>:d    4194304:d               {I@2}
        mov (8|M0)               r50.0<1>:d    0:w                              
        mov (8|M0)               r74.0<1>:d    0:w                              
(f0.1)  sel (8|M0)               r83.0<1>:d    r23.0<1;1,0>:d    r85.0<1;1,0>:d   {I@3}
        goto (8|M0)                          L3392                  L3520                
L3392:
        join (8|M0)                          L3440                                
L3408:
        cmp (8|M0)    (eq)f1.0   null<1>:d     r118.0<1;1,0>:d   0:w              
(f1.0)  goto (8|M0)                          L3440                  L3736                
L3440:
        join (8|M0)                          L3520                                
L3456:
        cmp (8|M0)    (ne)f1.0   r74.0<1>:d    r15.0<1;1,0>:d    0:w              
        mov (8|M0)               r126.0<1>:d   0:w                              
        mov (8|M0)               r50.0<1>:d    0:w                              
        mov (8|M0)               r83.0<1>:d    0:w                              
L3520:
        join (8|M0)                          L3736                                
L3536:
        add (8|M0)               r114.0<1>:d   r121.0<1;1,0>:d   r83.0<1;1,0>:d   {Compacted,I@2}
        cmp (8|M0)    (ne)f0.1   r39.0<1>:d    r74.0<1;1,0>:d    0:w              
        cmp (8|M0)    (gt)f0.1   null<1>:ud    r114.0<1;1,0>:ud  0x7FFFFF:ud              {I@2}
        mov (8|M0)               r90.0<1>:d    -r39.0<1;1,0>:d                  {I@2}
(f0.1)  goto (8|M0)                          L3640                  L3640                
L3608:
        mov (8|M0)               r27.0<1>:d    r50.0<1;1,0>:d                  
        goto (8|M0)                          L3640                  L4144                
L3640:
        join (8|M0)                          L3736                                
L3656:
        cmp (8|M0)    (eq)f1.1   null<1>:d     r50.0<1;1,0>:d    1:w              
        shr (8|M0)               r84.0<1>:ud   r114.0<1;1,0>:ud  1:w              
        and (8|M0)               r30.0<1>:d    r84.0<1;1,0>:d    4194303:d               {I@1}
(~f1.1) sel (8|M0)               r90.0<1>:d    -r39.0<1;1,0>:d   1:w              
        goto (8|M0)                          L3736                  L4080                
L3736:
        join (8|M0)                          L4080                                
L3752:
        add (8|M0)               r114.0<1>:d   r121.0<1;1,0>:d   r23.0<1;1,0>:d   {Compacted}
        cmp (8|M0)    (gt)f1.0   null<1>:ud    r114.0<1;1,0>:ud  0x7FFFFF:ud              {I@1}
(f1.0)  goto (8|M0)                          L3968                  L3968                
L3792:
(~f0.1) goto (8|M0)                          L3872                  L3872                
L3808:
        mov (8|M0)               r126.0<1>:d   0:w                              
        mov (8|M0)               r27.0<1>:d    0:w                              
        mov (8|M0)               r90.0<1>:d    0:w                              
        goto (8|M0)                          L3872                  L4144                
L3872:
        join (8|M0)                          L3968                                
L3888:
        and (8|M0)               r126.0<1>:d   r114.0<1;1,0>:d   1:w               {Compacted}
        add (8|M0)               r104.0<1>:d   r104.0<1;1,0>:d   1:w               {Compacted}
        mov (8|M0)               r27.0<1>:d    0:w                              
        mov (8|M0)               r90.0<1>:d    0:w                              
        shr (8|M0)               r114.0<1>:ud  r114.0<1;1,0>:ud  1:w              
        goto (8|M0)                          L3968                  L4144                
L3968:
        join (8|M0)                          L4080                                
L3984:
        shr (8|M0)               r122.0<1>:ud  r114.0<1;1,0>:ud  1:w               {I@3}
        mov (8|M0)               r90.0<1>:d    0:w                              
        and (8|M0)               r25.0<1>:d    r122.0<1;1,0>:d   4194303:d               {I@2}
        or (8|M0)                r122.0<1>:d   r122.0<1;1,0>:d   4194304:d              
        mov (8|M0)               r126.0<1>:d   0:w                              
(f0.1)  sel (8|M0)               r30.0<1>:d    r25.0<1;1,0>:d    r122.0<1;1,0>:d  {I@2}
L4080:
        join (8|M0)                          L4144                                
L4096:
        and (8|M0)               acc0.0<1>:d   r114.0<1;1,0>:d   1:w               {Compacted}
        add (8|M0)               r104.0<1>:d   r104.0<1;1,0>:d   1:w               {Compacted}
        mov (8|M0)               r27.0<1>:f    r126.0<1;1,0>:f                  {Compacted,I@5}
        mov (8|M0)               r114.0<1>:f   r30.0<1;1,0>:f                   {Compacted,A@2}
        mov (8|M0)               r126.0<1>:d   acc0.0<1;1,0>:d                  {F@2}
L4144:
        join (8|M0)                          L4640                                
L4160:
        shl (8|M0)               r39.0<1>:d    r126.0<1;1,0>:d   2:w               {Compacted,I@2}
        shl (8|M0)               r83.0<1>:d    r27.0<1;1,0>:d    1:w               {Compacted}
        bfn.0xFE (8|M0)          r93.0<1>:ud   r39.0<1;0>:ud     r83.0<1;0>:ud     r90.0<1>:ud      {I@1} // s0|s1|s2
        cmp (8|M0)    (eq)f0.1   null<1>:d     r93.0<1;1,0>:d    0:w               {I@1}
(~f0.1) goto (8|M0)                          L4256                  L4256                
L4224:
        mov (8|M0)               r113.0<1>:d   0:w                              
        goto (8|M0)                          L4256                  L4416                
L4256:
        join (8|M0)                          L4416                                
L4272:
        cmp (8|M0)    (gt)f1.1   null<1>:ud    r93.0<1;1,0>:ud   0x4:uw             
(~f1.1) goto (8|M0)                          L4336                  L4336                
L4304:
        mov (8|M0)               r113.0<1>:d   1:w                              
        goto (8|M0)                          L4336                  L4416                
L4336:
        join (8|M0)                          L4416                                
L4352:
        and (8|M0)    (ne)f1.0   null<1>:d     r114.0<1;1,0>:d   1:w               {F@1}
(W)     mov (1|M0)               r6.4<1>:hf    0x1:hf                             
(f1.0)  cmp (8|M0)    (eq)f1.0   null<1>:d     r93.0<1;1,0>:d    4:w              
(f1.0)  sel (8|M0)               r113.0<1>:d   r6.4<0;1,0>:w     0:w               {F@1}
L4416:
        join (8|M0)                          L4640                                
L4432:
        add (8|M0)               r112.0<1>:d   r114.0<1;1,0>:d   r113.0<1;1,0>:d  {Compacted,I@2}
        cmp (8|M0)    (eq)f1.0   r82.0<1>:d    r112.0<1;1,0>:d   8388608:d               {I@1}
        cmp (8|M0)    (eq)f1.1   null<1>:d     r112.0<1;1,0>:d   8388608:d              
        add3 (8|M0)              r125.0<1>:d   r104.0<1;0>:d     -r82.0<1;0>:d     0:w               {I@2}
        cmp (8|M0)    (eq)f1.0   null<1>:d     r125.0<1;1,0>:d   255:w               {I@1}
(f1.0)  goto (8|M0)                          L4592                  L4592                
L4520:
(~f1.1) sel (8|M0)               r24.0<1>:d    r112.0<1;1,0>:d   0:w              
        and (8|M0)               r123.0<1>:d   r14.0<1;1,0>:d    -2147483648:d              
        shl (8|M0)               r81.0<1>:d    r125.0<1;1,0>:d   23:w               {Compacted}
        bfn.0xFE (8|M0)          r15.0<1>:ud   r123.0<1;0>:ud    r81.0<1;0>:ud     r24.0<1>:ud      {I@1} // s0|s1|s2
        goto (8|M0)                          L4592                  L6832                
L4592:
        join (8|M0)                          L4640                                
L4608:
        bfn.0xEA (8|M0)          r15.0<1>:ud   r7.5<0;0>:ud      r14.0<1;0>:ud     r7.6<0>:ud       // s0|s1&s2
        goto (8|M0)                          L4640                  L6832                
L4640:
        join (8|M0)                          L4696                                
L4656:
        add (8|M0)               r80.0<1>:d    r121.0<1;1,0>:d   r23.0<1;1,0>:d   {Compacted}
        bfn.0xF8 (8|M0)          r15.0<1>:ud   r14.0<1;0>:ud     r7.6<0;0>:ud      r80.0<1>:ud      {I@1} // s0&s1|s2
        goto (8|M0)                          L4696                  L6832                
L4696:
        join (8|M0)                          L6752                                
L4712:
        cmp (8|M0)    (ne)f1.1   null<1>:d     r104.0<1;1,0>:d   0:w              
(f1.1)  sel (8|M0)               r43.0<1>:d    -r104.0<1;1,0>:d  -1:w              
        add (8|M0)               r40.0<1>:d    r109.0<1;1,0>:d   r43.0<1;1,0>:d   {Compacted,I@1}
        cmp (8|M0)    (lt)f0.1   null<1>:d     r40.0<1;1,0>:d    1:w               {I@1}
(f0.1)  goto (8|M0)                          L5504                  L5504                
L4784:
        cmp (8|M0)    (eq)f1.0   null<1>:d     r40.0<1;1,0>:d    1:w              
(f1.0)  goto (8|M0)                          L5384                  L5384                
L4816:
        cmp (8|M0)    (lt)f0.1   null<1>:ud    r40.0<1;1,0>:ud   0x18:uw             
(f0.1)  goto (8|M0)                          L5120                  L5120                
L4848:
        cmp (8|M0)    (ne)f1.1   r79.0<1>:d    r104.0<1;1,0>:d   0:w              
        cmp (8|M0)    (lt)f1.1   null<1>:d     r40.0<1;1,0>:d    25:w              
        mov (8|M0)               r12.0<1>:d    -r79.0<1;1,0>:d                  {I@2}
(f1.1)  goto (8|M0)                          L5016                  L5016                
L4912:
        cmp (8|M0)    (eq)f1.0   null<1>:d     r40.0<1;1,0>:d    25:w              
(~f1.0) goto (8|M0)                          L5016                  L5552                
L4944:
        cmp (8|M0)    (ne)f1.0   r72.0<1>:d    r121.0<1;1,0>:d   0:w              
        mov (8|M0)               r52.0<1>:f    r12.0<1;1,0>:f                   {Compacted,I@5}
        mov (8|M0)               r82.0<1>:d    0:w                              
        mov (8|M0)               r12.0<1>:d    0:w                               {F@1}
        goto (8|M0)                          L5016                  L5632                
L5016:
        join (8|M0)                          L5120                                
L5032:
        shr (8|M0)               r78.0<1>:ud   r14.0<1;1,0>:ud   22:w              
        and (8|M0)               r77.0<1>:d    r14.0<1;1,0>:d    4194303:d              
        mov (8|M0)               r82.0<1>:d    0:w                              
        and (8|M0)               r52.0<1>:d    r78.0<1;1,0>:d    1:w               {Compacted,I@3}
        cmp (8|M0)    (ne)f0.1   r72.0<1>:d    r77.0<1;1,0>:d    0:w               {I@3}
        goto (8|M0)                          L5120                  L5632                
L5120:
        join (8|M0)                          L5384                                
L5136:
        add3 (8|M0)              acc0.0<1>:d   r109.0<1;0>:d     r43.0<1;0>:d      -2:w              
(W)     mov (1|M0)               r6.4<1>:hf    -qnan(0x1FF):hf                             
        add3 (8|M0)              acc2.0<1>:d   r109.0<1;0>:d     r43.0<1;0>:d      -1:w              
        add3 (8|M0)              r71.0<1>:d    23:w                -r109.0<1;0>:d    -r43.0<1>:d     
        shr (8|M0)               r76.0<1>:ud   r121.0<1;1,0>:ud  acc0.0<1;1,0>:d 
        shl (8|M0)               r36.0<1>:d    r6.4<0;1,0>:w     acc0.0<1;1,0>:d  {F@1}
(W)     mov (1|M0)               r6.4<1>:hf    0x1:hf                              {I@1}
        shr (8|M0)               r60.0<1>:ud   r121.0<1;1,0>:ud  r40.0<1;1,0>:d  
        shr (8|M0)               r24.0<1>:ud   r121.0<1;1,0>:ud  acc2.0<1;1,0>:d 
        bfn.0x60 (8|M0)          r67.0<1>:ud   r36.0<1;0>:ud     r7.4<0;0>:ud      r121.0<1>:ud     // (s0^s1)&s2
        shl (8|M0)               r71.0<1>:d    r6.4<0;1,0>:w     r71.0<1;1,0>:d   {F@1}
(~f1.1) mov (8|M0)               r71.0<1>:d    0:w                              
        and (8|M0)               r52.0<1>:d    r76.0<1;1,0>:d    1:w               {Compacted}
        and (8|M0)               r12.0<1>:d    r24.0<1;1,0>:d    1:w               {Compacted,I@5}
        cmp (8|M0)    (ne)f1.1   r72.0<1>:d    r67.0<1;1,0>:d    0:w               {I@5}
        or (8|M0)                r82.0<1>:d    r60.0<1;1,0>:d    r71.0<1;1,0>:d   {Compacted,I@4}
        goto (8|M0)                          L5384                  L5632                
L5384:
        join (8|M0)                          L5504                                
L5400:
        shr (8|M0)               r22.0<1>:ud   r121.0<1;1,0>:ud  1:w              
        and (8|M0)               r12.0<1>:d    r14.0<1;1,0>:d    1:w               {Compacted}
        or (8|M0)                r75.0<1>:d    r22.0<1;1,0>:d    4194304:d               {I@2}
        mov (8|M0)               r52.0<1>:d    0:w                              
        mov (8|M0)               r72.0<1>:d    0:w                              
(f1.1)  sel (8|M0)               r82.0<1>:d    r75.0<1;1,0>:d    r22.0<1;1,0>:d   {I@3}
        goto (8|M0)                          L5504                  L5632                
L5504:
        join (8|M0)                          L5552                                
L5520:
        cmp (8|M0)    (eq)f0.1   null<1>:d     r40.0<1;1,0>:d    0:w              
(f0.1)  goto (8|M0)                          L5552                  L5848                
L5552:
        join (8|M0)                          L5632                                
L5568:
        cmp (8|M0)    (ne)f1.0   r72.0<1>:d    r14.0<1;1,0>:d    0:w              
        mov (8|M0)               r12.0<1>:d    0:w                              
        mov (8|M0)               r52.0<1>:d    0:w                              
        mov (8|M0)               r82.0<1>:d    0:w                              
L5632:
        join (8|M0)                          L5848                                
L5648:
        add (8|M0)               r113.0<1>:d   r23.0<1;1,0>:d    r82.0<1;1,0>:d   {Compacted,I@2}
        cmp (8|M0)    (ne)f0.1   r38.0<1>:d    r72.0<1;1,0>:d    0:w              
        cmp (8|M0)    (gt)f1.1   null<1>:ud    r113.0<1;1,0>:ud  0x7FFFFF:ud              {I@2}
        mov (8|M0)               r89.0<1>:d    -r38.0<1;1,0>:d                  {I@2}
(f1.1)  goto (8|M0)                          L5752                  L5752                
L5720:
        mov (8|M0)               r26.0<1>:d    r52.0<1;1,0>:d                  
        goto (8|M0)                          L5752                  L6256                
L5752:
        join (8|M0)                          L5848                                
L5768:
        cmp (8|M0)    (eq)f1.0   null<1>:d     r52.0<1;1,0>:d    1:w              
        shr (8|M0)               r74.0<1>:ud   r113.0<1;1,0>:ud  1:w              
        and (8|M0)               r29.0<1>:d    r74.0<1;1,0>:d    4194303:d               {I@1}
(~f1.0) sel (8|M0)               r89.0<1>:d    -r38.0<1;1,0>:d   1:w              
        goto (8|M0)                          L5848                  L6192                
L5848:
        join (8|M0)                          L6192                                
L5864:
        add (8|M0)               r113.0<1>:d   r23.0<1;1,0>:d    r121.0<1;1,0>:d  {Compacted}
        cmp (8|M0)    (gt)f0.1   null<1>:ud    r113.0<1;1,0>:ud  0x7FFFFF:ud              {I@1}
(f0.1)  goto (8|M0)                          L6080                  L6080                
L5904:
(f1.1)  goto (8|M0)                          L5984                  L5984                
L5920:
        mov (8|M0)               r12.0<1>:d    0:w                              
        mov (8|M0)               r26.0<1>:d    0:w                              
        mov (8|M0)               r89.0<1>:d    0:w                              
        goto (8|M0)                          L5984                  L6256                
L5984:
        join (8|M0)                          L6080                                
L6000:
        and (8|M0)               r12.0<1>:d    r113.0<1;1,0>:d   1:w               {Compacted}
        add (8|M0)               r109.0<1>:d   r109.0<1;1,0>:d   1:w               {Compacted}
        mov (8|M0)               r26.0<1>:d    0:w                              
        mov (8|M0)               r89.0<1>:d    0:w                              
        shr (8|M0)               r113.0<1>:ud  r113.0<1;1,0>:ud  1:w              
        goto (8|M0)                          L6080                  L6256                
L6080:
        join (8|M0)                          L6192                                
L6096:
        shr (8|M0)               r121.0<1>:ud  r113.0<1;1,0>:ud  1:w               {I@3}
        mov (8|M0)               r89.0<1>:d    0:w                              
        and (8|M0)               r23.0<1>:d    r121.0<1;1,0>:d   4194303:d               {I@2}
        or (8|M0)                r121.0<1>:d   r121.0<1;1,0>:d   4194304:d              
        mov (8|M0)               r12.0<1>:d    0:w                              
(f1.1)  sel (8|M0)               r29.0<1>:d    r121.0<1;1,0>:d   r23.0<1;1,0>:d   {I@2}
L6192:
        join (8|M0)                          L6256                                
L6208:
        and (8|M0)               acc0.0<1>:d   r113.0<1;1,0>:d   1:w               {Compacted}
        add (8|M0)               r109.0<1>:d   r109.0<1;1,0>:d   1:w               {Compacted}
        mov (8|M0)               r26.0<1>:f    r12.0<1;1,0>:f                   {Compacted,I@5}
        mov (8|M0)               r113.0<1>:f   r29.0<1;1,0>:f                   {Compacted,A@2}
        mov (8|M0)               r12.0<1>:d    acc0.0<1;1,0>:d                  {F@2}
L6256:
        join (8|M0)                          L6752                                
L6272:
        shl (8|M0)               r38.0<1>:d    r12.0<1;1,0>:d    2:w               {Compacted,I@2}
        shl (8|M0)               r73.0<1>:d    r26.0<1;1,0>:d    1:w               {Compacted}
        bfn.0xFE (8|M0)          r92.0<1>:ud   r38.0<1;0>:ud     r73.0<1;0>:ud     r89.0<1>:ud      {I@1} // s0|s1|s2
        cmp (8|M0)    (eq)f1.1   null<1>:d     r92.0<1;1,0>:d    0:w               {I@1}
(~f1.1) goto (8|M0)                          L6368                  L6368                
L6336:
        mov (8|M0)               r111.0<1>:d   0:w                              
        goto (8|M0)                          L6368                  L6528                
L6368:
        join (8|M0)                          L6528                                
L6384:
        cmp (8|M0)    (gt)f1.0   null<1>:ud    r92.0<1;1,0>:ud   0x4:uw             
(~f1.0) goto (8|M0)                          L6448                  L6448                
L6416:
        mov (8|M0)               r111.0<1>:d   1:w                              
        goto (8|M0)                          L6448                  L6528                
L6448:
        join (8|M0)                          L6528                                
L6464:
        and (8|M0)    (ne)f0.1   null<1>:d     r113.0<1;1,0>:d   1:w               {F@1}
(W)     mov (1|M0)               r6.4<1>:hf    0x1:hf                             
(f0.1)  cmp (8|M0)    (eq)f0.1   null<1>:d     r92.0<1;1,0>:d    4:w              
(f0.1)  sel (8|M0)               r111.0<1>:d   r6.4<0;1,0>:w     0:w               {F@1}
L6528:
        join (8|M0)                          L6752                                
L6544:
        add (8|M0)               r110.0<1>:d   r113.0<1;1,0>:d   r111.0<1;1,0>:d  {Compacted,I@2}
        cmp (8|M0)    (eq)f0.1   r72.0<1>:d    r110.0<1;1,0>:d   8388608:d               {I@1}
        cmp (8|M0)    (eq)f1.0   null<1>:d     r110.0<1;1,0>:d   8388608:d              
        add3 (8|M0)              r124.0<1>:d   r109.0<1;0>:d     -r72.0<1;0>:d     0:w               {I@2}
        cmp (8|M0)    (eq)f0.1   null<1>:d     r124.0<1;1,0>:d   255:w               {I@1}
(f0.1)  goto (8|M0)                          L6704                  L6704                
L6632:
(~f1.0) sel (8|M0)               r22.0<1>:d    r110.0<1;1,0>:d   0:w              
        and (8|M0)               r122.0<1>:d   r15.0<1;1,0>:d    -2147483648:d              
        shl (8|M0)               r71.0<1>:d    r124.0<1;1,0>:d   23:w               {Compacted}
        bfn.0xFE (8|M0)          r15.0<1>:ud   r122.0<1;0>:ud    r71.0<1;0>:ud     r22.0<1>:ud      {I@1} // s0|s1|s2
        goto (8|M0)                          L6704                  L6832                
L6704:
        join (8|M0)                          L6752                                
L6720:
        bfn.0xEA (8|M0)          r15.0<1>:ud   r7.5<0;0>:ud      r15.0<1;0>:ud     r7.6<0>:ud       {I@3} // s0|s1&s2
        goto (8|M0)                          L6752                  L6832                
L6752:
        join (8|M0)                          L6832                                
L6768:
        cmp (8|M0)    (ne)f1.0   null<1>:d     r68.0<1;1,0>:d    r67.0<1;1,0>:d  
(f1.0)  cmp (8|M0)    (eq)f1.0   null<1>:d     r121.0<1;1,0>:d   0:w              
(f1.0)  cmp (8|M0)    (eq)f1.0   null<1>:d     r104.0<1;1,0>:d   255:w              
(f1.0)  mov (8|M0)               r15.0<1>:f    qnan(0x0):f                               {I@6}
L6832:
        join (8|M0)                          L36464                                
L6848:
        shr (8|M0)               r70.0<1>:ud   r15.0<1;1,0>:ud   23:w               {F@1}
        and (8|M0)    (ne)f1.1   r22.0<1>:d    r15.0<1;1,0>:d    8388607:d              
        and (8|M0)               r108.0<1>:d   r70.0<1;1,0>:d    255:w               {Compacted,I@2}
        addc (8|M0)              r112.0<1>:ud  r21.0<1;1,0>:ud   0x80:ud              {AccWrEn,Compacted}
(f1.1)  cmp (8|M0)    (eq)f1.1   null<1>:d     r108.0<1;1,0>:d   255:w               {I@2}
        add (8|M0)               r121.0<1>:ud  acc0.0<1;1,0>:ud  r20.0<1;1,0>:ud 
        addc (8|M0)              r55.0<1>:ud   r112.0<1;1,0>:ud  r19.0<1;1,0>:ud  {AccWrEn,Compacted,I@3}
        add3 (8|M0)              r47.0<1>:ud   acc0.0<1;0>:ud    r121.0<1;0>:ud    r18.0<1>:ud      {I@2}
(~f1.1) goto (8|M0)                          L6992                  L6992                
L6968:
        mov (8|M0)               r15.0<1>:f    qnan(0x0):f                               {Compacted}
        goto (8|M0)                          L6992                  L12088                
L6992:
        join (8|M0)                          L12088                                
L7008:
        mov (8|M0)               r84.0<2>:d    r55.0<1;1,0>:d                   {I@5}
        mov (8|M0)               r84.1<2>:d    r47.0<1;1,0>:d                   {I@5}
        send.ugm (8|M0)          r13      r84     null:0  0x0            0x04180580           {A@1,$7} // wr:2+0, rd:1; load.ugm.d32.a64.ca.ca
        shr (8|M0)               r69.0<1>:ud   r13.0<1;1,0>:ud   23:w               {$7.dst}
        and (8|M0)    (ne)f1.0   r120.0<1>:d   r13.0<1;1,0>:d    8388607:d              
        and (8|M0)               r103.0<1>:d   r69.0<1;1,0>:d    255:w               {Compacted,I@2}
(f1.0)  cmp (8|M0)    (eq)f1.0   null<1>:d     r103.0<1;1,0>:d   255:w               {I@1}
(~f1.0) goto (8|M0)                          L7152                  L7152                
L7128:
        mov (8|M0)               r15.0<1>:f    qnan(0x0):f                               {Compacted}
        goto (8|M0)                          L7152                  L12088                
L7152:
        join (8|M0)                          L12088                                
L7168:
        cmp (8|M0)    (eq)f1.0   null<1>:d     r22.0<1;1,0>:d    0:w              
        shr (8|M0)               r66.0<1>:ud   r15.0<1;1,0>:ud   31:w               {F@1}
        shr (8|M0)               r65.0<1>:ud   r13.0<1;1,0>:ud   31:w              
        cmp (8|M0)    (eq)f1.1   null<1>:d     r120.0<1;1,0>:d   0:w              
(f1.0)  cmp (8|M0)    (eq)f1.0   null<1>:d     r108.0<1;1,0>:d   255:w              
(f1.0)  goto (8|M0)                          L12008                  L12008                
L7264:
        cmp (8|M0)    (eq)f1.0   null<1>:d     r103.0<1;1,0>:d   255:w              
(W)     mov (1|M0)               r6.4<1>:hf    0x1:hf                             
        or (8|M0)                r68.0<1>:d    r108.0<1;1,0>:d   r22.0<1;1,0>:d   {Compacted}
(f1.1)  sel (8|M0)               r12.0<1>:uw   r6.4<0;1,0>:uw    0x0:uw              {F@1}
(f1.0)  sel (8|M0)               r14.0<1>:uw   r6.4<0;1,0>:uw    0x0:uw             
        and (8|M0)    (ne)f0.1   null<1>:uw    r14.0<1;1,0>:uw   r12.0<1;1,0>:uw  {I@1}
(~f0.1) cmp (8|M0)    (eq)f0.1   null<1>:d     r68.0<1;1,0>:d    0:w              
(~f0.1) goto (8|M0)                          L7408                  L7408                
L7384:
        mov (8|M0)               r15.0<1>:f    r13.0<1;1,0>:f                   {Compacted}
        goto (8|M0)                          L7408                  L12088                
L7408:
        join (8|M0)                          L12008                                
L7424:
        or (8|M0)     (eq)f1.1   null<1>:d     r103.0<1;1,0>:d   r120.0<1;1,0>:d 
(f1.1)  goto (8|M0)                          L12008                  L12088                
L7456:
        cmp (8|M0)    (eq)f1.0   null<1>:d     r66.0<1;1,0>:d    r65.0<1;1,0>:d  
        cmp (8|M0)    (lt)f1.1   null<1>:ud    r103.0<1;1,0>:ud  r108.0<1;1,0>:ud
(f1.0)  goto (8|M0)                          L7712                  L7712                
L7504:
(f1.1)  goto (8|M0)                          L7608                  L7608                
L7520:
        mov (8|M0)               r56.0<1>:f    r13.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r42.0<1>:f    r15.0<1;1,0>:f                   {Compacted,F@2}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        call (8|M0)              r6.2          L36720                                 {A@1}
L7584:
        mov (8|M0)               r15.0<1>:f    r76.0<1;1,0>:f                   {Compacted}
        goto (8|M0)                          L7608                  L12088                
L7608:
        join (8|M0)                          L7712                                
L7624:
        mov (8|M0)               r56.0<1>:f    r15.0<1;1,0>:f                   {Compacted,F@1}
        mov (8|M0)               r42.0<1>:f    r13.0<1;1,0>:f                   {Compacted}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        call (8|M0)              r6.2          L36720                                 {A@1}
L7688:
        mov (8|M0)               r15.0<1>:f    r76.0<1;1,0>:f                   {Compacted}
        goto (8|M0)                          L7712                  L12088                
L7712:
        join (8|M0)                          L12008                                
L7728:
(f1.1)  goto (8|M0)                          L9952                  L9952                
L7744:
        cmp (8|M0)    (eq)f1.0   null<1>:d     r108.0<1;1,0>:d   0:w              
(f1.0)  goto (8|M0)                          L7832                  L7832                
L7776:
(W)     mov (1|M0)               r6.8<2>:b     1:w                              
        add (8|M0)               r117.0<1>:d   r103.0<1;1,0>:d   -r108.0<1;1,0>:d {Compacted}
        mov (8|M0)               r12.0<1>:b    r6.8<0;1,0>:b                    {I@2}
        goto (8|M0)                          L7832                  L7920                
L7832:
        join (8|M0)                          L7920                                
L7848:
        cmp (8|M0)    (eq)f0.1   null<1>:d     r103.0<1;1,0>:d   0:w              
(f0.1)  goto (8|M0)                          L7920                  L9896                
L7880:
(W)     mov (1|M0)               r6.8<2>:b     0:w                              
        add (8|M0)               r117.0<1>:d   r103.0<1;1,0>:d   -1:w               {Compacted}
        mov (8|M0)               r12.0<1>:b    r6.8<0;1,0>:b                    {I@2}
L7920:
        join (8|M0)                          L9896                                
L7936:
        cmp (8|M0)    (lt)f1.1   null<1>:d     r117.0<1;1,0>:d   1:w               {I@3}
(f1.1)  goto (8|M0)                          L8648                  L8648                
L7968:
        cmp (8|M0)    (eq)f0.1   null<1>:d     r117.0<1;1,0>:d   1:w              
(f0.1)  goto (8|M0)                          L8528                  L8528                
L8000:
        cmp (8|M0)    (lt)f1.1   null<1>:ud    r117.0<1;1,0>:ud  0x18:uw             
(f1.1)  goto (8|M0)                          L8288                  L8288                
L8032:
        cmp (8|M0)    (lt)f1.0   null<1>:d     r117.0<1;1,0>:d   25:w              
        mov (8|M0)               r125.0<1>:d   r12.0<1;1,0>:ub                  {I@7}
(f1.0)  goto (8|M0)                          L8184                  L8184                
L8080:
        cmp (8|M0)    (eq)f0.1   null<1>:d     r117.0<1;1,0>:d   25:w              
(~f0.1) goto (8|M0)                          L8184                  L8696                
L8112:
        cmp (8|M0)    (ne)f1.1   r70.0<1>:d    r22.0<1;1,0>:d    0:w              
        mov (8|M0)               r49.0<1>:f    r125.0<1;1,0>:f                  {Compacted,I@5}
        mov (8|M0)               r81.0<1>:d    0:w                              
        mov (8|M0)               r125.0<1>:d   0:w                               {F@1}
        goto (8|M0)                          L8184                  L8776                
L8184:
        join (8|M0)                          L8288                                
L8200:
        shr (8|M0)               r67.0<1>:ud   r15.0<1;1,0>:ud   22:w              
        and (8|M0)               r66.0<1>:d    r15.0<1;1,0>:d    4194303:d              
        mov (8|M0)               r81.0<1>:d    0:w                              
        and (8|M0)               r49.0<1>:d    r67.0<1;1,0>:d    1:w               {Compacted,I@3}
        cmp (8|M0)    (ne)f1.0   r70.0<1>:d    r66.0<1;1,0>:d    0:w               {I@3}
        goto (8|M0)                          L8288                  L8776                
L8288:
        join (8|M0)                          L8528                                
L8304:
        add (8|M0)               acc0.0<1>:d   r117.0<1;1,0>:d   -2:w               {Compacted}
(W)     mov (1|M0)               r6.4<1>:hf    -qnan(0x1FF):hf                             
        add (8|M0)               acc2.0<1>:d   r117.0<1;1,0>:d   -1:w               {Compacted}
        add (8|M0)               r69.0<1>:d    -r117.0<1;1,0>:d  23:w               {Compacted}
        shr (8|M0)               r65.0<1>:ud   r22.0<1;1,0>:ud   acc0.0<1;1,0>:d 
        shl (8|M0)               r33.0<1>:d    r6.4<0;1,0>:w     acc0.0<1;1,0>:d  {F@1}
(W)     mov (1|M0)               r6.4<1>:hf    0x1:hf                              {I@1}
        shr (8|M0)               r59.0<1>:ud   r22.0<1;1,0>:ud   r117.0<1;1,0>:d 
        shr (8|M0)               r123.0<1>:ud  r22.0<1;1,0>:ud   acc2.0<1;1,0>:d 
        bfn.0x60 (8|M0)          r64.0<1>:ud   r33.0<1;0>:ud     r7.4<0;0>:ud      r22.0<1>:ud      // (s0^s1)&s2
        shl (8|M0)               r69.0<1>:d    r6.4<0;1,0>:w     r69.0<1;1,0>:d   {F@1}
(f1.0)  mov (8|M0)               r69.0<1>:d    0:w                              
        and (8|M0)               r49.0<1>:d    r65.0<1;1,0>:d    1:w               {Compacted}
        and (8|M0)               r125.0<1>:d   r123.0<1;1,0>:d   1:w               {Compacted,I@5}
        cmp (8|M0)    (ne)f0.1   r70.0<1>:d    r64.0<1;1,0>:d    0:w               {I@5}
        or (8|M0)                r81.0<1>:d    r59.0<1;1,0>:d    r69.0<1;1,0>:d   {Compacted,I@4}
        goto (8|M0)                          L8528                  L8776                
L8528:
        join (8|M0)                          L8648                                
L8544:
        shr (8|M0)               r14.0<1>:ud   r22.0<1;1,0>:ud   1:w              
        and (8|M0)               r125.0<1>:d   r15.0<1;1,0>:d    1:w               {Compacted}
        or (8|M0)                r64.0<1>:d    r14.0<1;1,0>:d    4194304:d               {I@2}
        mov (8|M0)               r49.0<1>:d    0:w                              
        mov (8|M0)               r70.0<1>:d    0:w                              
(f1.0)  sel (8|M0)               r81.0<1>:d    r14.0<1;1,0>:d    r64.0<1;1,0>:d   {I@3}
        goto (8|M0)                          L8648                  L8776                
L8648:
        join (8|M0)                          L8696                                
L8664:
        cmp (8|M0)    (eq)f1.1   null<1>:d     r117.0<1;1,0>:d   0:w              
(f1.1)  goto (8|M0)                          L8696                  L8992                
L8696:
        join (8|M0)                          L8776                                
L8712:
        cmp (8|M0)    (ne)f1.1   r70.0<1>:d    r15.0<1;1,0>:d    0:w              
        mov (8|M0)               r125.0<1>:d   0:w                              
        mov (8|M0)               r49.0<1>:d    0:w                              
        mov (8|M0)               r81.0<1>:d    0:w                              
L8776:
        join (8|M0)                          L8992                                
L8792:
        add (8|M0)               r112.0<1>:d   r120.0<1;1,0>:d   r81.0<1;1,0>:d   {Compacted,I@2}
        cmp (8|M0)    (ne)f1.0   r37.0<1>:d    r70.0<1;1,0>:d    0:w              
        cmp (8|M0)    (gt)f1.0   null<1>:ud    r112.0<1;1,0>:ud  0x7FFFFF:ud              {I@2}
        mov (8|M0)               r88.0<1>:d    -r37.0<1;1,0>:d                  {I@2}
(f1.0)  goto (8|M0)                          L8896                  L8896                
L8864:
        mov (8|M0)               r25.0<1>:d    r49.0<1;1,0>:d                  
        goto (8|M0)                          L8896                  L9400                
L8896:
        join (8|M0)                          L8992                                
L8912:
        cmp (8|M0)    (eq)f0.1   null<1>:d     r49.0<1;1,0>:d    1:w              
        shr (8|M0)               r63.0<1>:ud   r112.0<1;1,0>:ud  1:w              
        and (8|M0)               r28.0<1>:d    r63.0<1;1,0>:d    4194303:d               {I@1}
(~f0.1) sel (8|M0)               r88.0<1>:d    -r37.0<1;1,0>:d   1:w              
        goto (8|M0)                          L8992                  L9336                
L8992:
        join (8|M0)                          L9336                                
L9008:
        add (8|M0)               r112.0<1>:d   r120.0<1;1,0>:d   r22.0<1;1,0>:d   {Compacted}
        cmp (8|M0)    (gt)f1.1   null<1>:ud    r112.0<1;1,0>:ud  0x7FFFFF:ud              {I@1}
(f1.1)  goto (8|M0)                          L9224                  L9224                
L9048:
(~f1.0) goto (8|M0)                          L9128                  L9128                
L9064:
        mov (8|M0)               r125.0<1>:d   0:w                              
        mov (8|M0)               r25.0<1>:d    0:w                              
        mov (8|M0)               r88.0<1>:d    0:w                              
        goto (8|M0)                          L9128                  L9400                
L9128:
        join (8|M0)                          L9224                                
L9144:
        and (8|M0)               r125.0<1>:d   r112.0<1;1,0>:d   1:w               {Compacted}
        add (8|M0)               r103.0<1>:d   r103.0<1;1,0>:d   1:w               {Compacted}
        mov (8|M0)               r25.0<1>:d    0:w                              
        mov (8|M0)               r88.0<1>:d    0:w                              
        shr (8|M0)               r112.0<1>:ud  r112.0<1;1,0>:ud  1:w              
        goto (8|M0)                          L9224                  L9400                
L9224:
        join (8|M0)                          L9336                                
L9240:
        shr (8|M0)               r120.0<1>:ud  r112.0<1;1,0>:ud  1:w               {I@3}
        mov (8|M0)               r88.0<1>:d    0:w                              
        and (8|M0)               r15.0<1>:d    r120.0<1;1,0>:d   4194303:d               {I@2}
        or (8|M0)                r120.0<1>:d   r120.0<1;1,0>:d   4194304:d              
        mov (8|M0)               r125.0<1>:d   0:w                              
(f1.0)  sel (8|M0)               r28.0<1>:d    r15.0<1;1,0>:d    r120.0<1;1,0>:d  {I@2}
L9336:
        join (8|M0)                          L9400                                
L9352:
        and (8|M0)               acc0.0<1>:d   r112.0<1;1,0>:d   1:w               {Compacted}
        add (8|M0)               r103.0<1>:d   r103.0<1;1,0>:d   1:w               {Compacted}
        mov (8|M0)               r25.0<1>:f    r125.0<1;1,0>:f                  {Compacted,I@5}
        mov (8|M0)               r112.0<1>:f   r28.0<1;1,0>:f                   {Compacted,A@2}
        mov (8|M0)               r125.0<1>:d   acc0.0<1;1,0>:d                  {F@2}
L9400:
        join (8|M0)                          L9896                                
L9416:
        shl (8|M0)               r37.0<1>:d    r125.0<1;1,0>:d   2:w               {Compacted,I@2}
        shl (8|M0)               r62.0<1>:d    r25.0<1;1,0>:d    1:w               {Compacted}
        bfn.0xFE (8|M0)          r91.0<1>:ud   r37.0<1;0>:ud     r62.0<1;0>:ud     r88.0<1>:ud      {I@1} // s0|s1|s2
        cmp (8|M0)    (eq)f1.0   null<1>:d     r91.0<1;1,0>:d    0:w               {I@1}
(~f1.0) goto (8|M0)                          L9512                  L9512                
L9480:
        mov (8|M0)               r108.0<1>:d   0:w                              
        goto (8|M0)                          L9512                  L9672                
L9512:
        join (8|M0)                          L9672                                
L9528:
        cmp (8|M0)    (gt)f0.1   null<1>:ud    r91.0<1;1,0>:ud   0x4:uw             
(~f0.1) goto (8|M0)                          L9592                  L9592                
L9560:
        mov (8|M0)               r108.0<1>:d   1:w                              
        goto (8|M0)                          L9592                  L9672                
L9592:
        join (8|M0)                          L9672                                
L9608:
        and (8|M0)    (ne)f1.1   null<1>:d     r112.0<1;1,0>:d   1:w               {F@1}
(W)     mov (1|M0)               r6.4<1>:hf    0x1:hf                             
(f1.1)  cmp (8|M0)    (eq)f1.1   null<1>:d     r91.0<1;1,0>:d    4:w              
(f1.1)  sel (8|M0)               r108.0<1>:d   r6.4<0;1,0>:w     0:w               {F@1}
L9672:
        join (8|M0)                          L9896                                
L9688:
        add (8|M0)               r107.0<1>:d   r112.0<1;1,0>:d   r108.0<1;1,0>:d  {Compacted,I@2}
        cmp (8|M0)    (eq)f1.1   r61.0<1>:d    r107.0<1;1,0>:d   8388608:d               {I@1}
        cmp (8|M0)    (eq)f1.0   null<1>:d     r107.0<1;1,0>:d   8388608:d              
        add3 (8|M0)              r123.0<1>:d   r103.0<1;0>:d     -r61.0<1;0>:d     0:w               {I@2}
        cmp (8|M0)    (eq)f1.1   null<1>:d     r123.0<1;1,0>:d   255:w               {I@1}
(f1.1)  goto (8|M0)                          L9848                  L9848                
L9776:
(~f1.0) sel (8|M0)               r14.0<1>:d    r107.0<1;1,0>:d   0:w              
        and (8|M0)               r120.0<1>:d   r13.0<1;1,0>:d    -2147483648:d              
        shl (8|M0)               r60.0<1>:d    r123.0<1;1,0>:d   23:w               {Compacted}
        bfn.0xFE (8|M0)          r15.0<1>:ud   r120.0<1;0>:ud    r60.0<1;0>:ud     r14.0<1>:ud      {I@1} // s0|s1|s2
        goto (8|M0)                          L9848                  L12088                
L9848:
        join (8|M0)                          L9896                                
L9864:
        bfn.0xEA (8|M0)          r15.0<1>:ud   r7.5<0;0>:ud      r13.0<1;0>:ud     r7.6<0>:ud       // s0|s1&s2
        goto (8|M0)                          L9896                  L12088                
L9896:
        join (8|M0)                          L9952                                
L9912:
        add (8|M0)               r59.0<1>:d    r120.0<1;1,0>:d   r22.0<1;1,0>:d   {Compacted}
        bfn.0xF8 (8|M0)          r15.0<1>:ud   r13.0<1;0>:ud     r7.6<0;0>:ud      r59.0<1>:ud      {I@1} // s0&s1|s2
        goto (8|M0)                          L9952                  L12088                
L9952:
        join (8|M0)                          L12008                                
L9968:
        cmp (8|M0)    (ne)f0.1   null<1>:d     r103.0<1;1,0>:d   0:w              
(f0.1)  sel (8|M0)               r42.0<1>:d    -r103.0<1;1,0>:d  -1:w              
        add (8|M0)               r39.0<1>:d    r108.0<1;1,0>:d   r42.0<1;1,0>:d   {Compacted,I@1}
        cmp (8|M0)    (lt)f1.0   null<1>:d     r39.0<1;1,0>:d    1:w               {I@1}
(f1.0)  goto (8|M0)                          L10760                  L10760                
L10040:
        cmp (8|M0)    (eq)f1.1   null<1>:d     r39.0<1;1,0>:d    1:w              
(f1.1)  goto (8|M0)                          L10640                  L10640                
L10072:
        cmp (8|M0)    (lt)f1.0   null<1>:ud    r39.0<1;1,0>:ud   0x18:uw             
(f1.0)  goto (8|M0)                          L10376                  L10376                
L10104:
        cmp (8|M0)    (ne)f0.1   r58.0<1>:d    r103.0<1;1,0>:d   0:w              
        cmp (8|M0)    (lt)f0.1   null<1>:d     r39.0<1;1,0>:d    25:w              
        mov (8|M0)               r127.0<1>:d   -r58.0<1;1,0>:d                  {I@2}
(f0.1)  goto (8|M0)                          L10272                  L10272                
L10168:
        cmp (8|M0)    (eq)f1.1   null<1>:d     r39.0<1;1,0>:d    25:w              
(~f1.1) goto (8|M0)                          L10272                  L10808                
L10200:
        cmp (8|M0)    (ne)f1.1   r68.0<1>:d    r120.0<1;1,0>:d   0:w              
        mov (8|M0)               r51.0<1>:f    r127.0<1;1,0>:f                  {Compacted,I@5}
        mov (8|M0)               r80.0<1>:d    0:w                              
        mov (8|M0)               r127.0<1>:d   0:w                               {F@1}
        goto (8|M0)                          L10272                  L10888                
L10272:
        join (8|M0)                          L10376                                
L10288:
        shr (8|M0)               r57.0<1>:ud   r13.0<1;1,0>:ud   22:w              
        and (8|M0)               r56.0<1>:d    r13.0<1;1,0>:d    4194303:d              
        mov (8|M0)               r80.0<1>:d    0:w                              
        and (8|M0)               r51.0<1>:d    r57.0<1;1,0>:d    1:w               {Compacted,I@3}
        cmp (8|M0)    (ne)f1.0   r68.0<1>:d    r56.0<1;1,0>:d    0:w               {I@3}
        goto (8|M0)                          L10376                  L10888                
L10376:
        join (8|M0)                          L10640                                
L10392:
        add3 (8|M0)              acc0.0<1>:d   r108.0<1;0>:d     r42.0<1;0>:d      -2:w              
(W)     mov (1|M0)               r6.4<1>:hf    -qnan(0x1FF):hf                             
        add3 (8|M0)              acc2.0<1>:d   r108.0<1;0>:d     r42.0<1;0>:d      -1:w              
        add3 (8|M0)              r67.0<1>:d    23:w                -r108.0<1;0>:d    -r42.0<1>:d     
        shr (8|M0)               r55.0<1>:ud   r120.0<1;1,0>:ud  acc0.0<1;1,0>:d 
        shl (8|M0)               r35.0<1>:d    r6.4<0;1,0>:w     acc0.0<1;1,0>:d  {F@1}
(W)     mov (1|M0)               r6.4<1>:hf    0x1:hf                              {I@1}
        shr (8|M0)               r58.0<1>:ud   r120.0<1;1,0>:ud  r39.0<1;1,0>:d  
        shr (8|M0)               r23.0<1>:ud   r120.0<1;1,0>:ud  acc2.0<1;1,0>:d 
        bfn.0x60 (8|M0)          r66.0<1>:ud   r35.0<1;0>:ud     r7.4<0;0>:ud      r120.0<1>:ud     // (s0^s1)&s2
        shl (8|M0)               r67.0<1>:d    r6.4<0;1,0>:w     r67.0<1;1,0>:d   {F@1}
(~f0.1) mov (8|M0)               r67.0<1>:d    0:w                              
        and (8|M0)               r51.0<1>:d    r55.0<1;1,0>:d    1:w               {Compacted}
        and (8|M0)               r127.0<1>:d   r23.0<1;1,0>:d    1:w               {Compacted,I@5}
        cmp (8|M0)    (ne)f0.1   r68.0<1>:d    r66.0<1;1,0>:d    0:w               {I@5}
        or (8|M0)                r80.0<1>:d    r58.0<1;1,0>:d    r67.0<1;1,0>:d   {Compacted,I@4}
        goto (8|M0)                          L10640                  L10888                
L10640:
        join (8|M0)                          L10760                                
L10656:
        shr (8|M0)               r12.0<1>:ud   r120.0<1;1,0>:ud  1:w              
        and (8|M0)               r127.0<1>:d   r13.0<1;1,0>:d    1:w               {Compacted}
        or (8|M0)                r54.0<1>:d    r12.0<1;1,0>:d    4194304:d               {I@2}
        mov (8|M0)               r51.0<1>:d    0:w                              
        mov (8|M0)               r68.0<1>:d    0:w                              
(f0.1)  sel (8|M0)               r80.0<1>:d    r54.0<1;1,0>:d    r12.0<1;1,0>:d   {I@3}
        goto (8|M0)                          L10760                  L10888                
L10760:
        join (8|M0)                          L10808                                
L10776:
        cmp (8|M0)    (eq)f1.0   null<1>:d     r39.0<1;1,0>:d    0:w              
(f1.0)  goto (8|M0)                          L10808                  L11104                
L10808:
        join (8|M0)                          L10888                                
L10824:
        cmp (8|M0)    (ne)f1.1   r68.0<1>:d    r13.0<1;1,0>:d    0:w              
        mov (8|M0)               r127.0<1>:d   0:w                              
        mov (8|M0)               r51.0<1>:d    0:w                              
        mov (8|M0)               r80.0<1>:d    0:w                              
L10888:
        join (8|M0)                          L11104                                
L10904:
        add (8|M0)               r111.0<1>:d   r22.0<1;1,0>:d    r80.0<1;1,0>:d   {Compacted,I@2}
        cmp (8|M0)    (ne)f1.0   r36.0<1>:d    r68.0<1;1,0>:d    0:w              
        cmp (8|M0)    (gt)f0.1   null<1>:ud    r111.0<1;1,0>:ud  0x7FFFFF:ud              {I@2}
        mov (8|M0)               r87.0<1>:d    -r36.0<1;1,0>:d                  {I@2}
(f0.1)  goto (8|M0)                          L11008                  L11008                
L10976:
        mov (8|M0)               r24.0<1>:d    r51.0<1;1,0>:d                  
        goto (8|M0)                          L11008                  L11512                
L11008:
        join (8|M0)                          L11104                                
L11024:
        cmp (8|M0)    (eq)f1.1   null<1>:d     r51.0<1;1,0>:d    1:w              
        shr (8|M0)               r53.0<1>:ud   r111.0<1;1,0>:ud  1:w              
        and (8|M0)               r27.0<1>:d    r53.0<1;1,0>:d    4194303:d               {I@1}
(~f1.1) sel (8|M0)               r87.0<1>:d    -r36.0<1;1,0>:d   1:w              
        goto (8|M0)                          L11104                  L11448                
L11104:
        join (8|M0)                          L11448                                
L11120:
        add (8|M0)               r111.0<1>:d   r22.0<1;1,0>:d    r120.0<1;1,0>:d  {Compacted}
        cmp (8|M0)    (gt)f1.0   null<1>:ud    r111.0<1;1,0>:ud  0x7FFFFF:ud              {I@1}
(f1.0)  goto (8|M0)                          L11336                  L11336                
L11160:
(f0.1)  goto (8|M0)                          L11240                  L11240                
L11176:
        mov (8|M0)               r127.0<1>:d   0:w                              
        mov (8|M0)               r24.0<1>:d    0:w                              
        mov (8|M0)               r87.0<1>:d    0:w                              
        goto (8|M0)                          L11240                  L11512                
L11240:
        join (8|M0)                          L11336                                
L11256:
        and (8|M0)               r127.0<1>:d   r111.0<1;1,0>:d   1:w               {Compacted}
        add (8|M0)               r108.0<1>:d   r108.0<1;1,0>:d   1:w               {Compacted}
        mov (8|M0)               r24.0<1>:d    0:w                              
        mov (8|M0)               r87.0<1>:d    0:w                              
        shr (8|M0)               r111.0<1>:ud  r111.0<1;1,0>:ud  1:w              
        goto (8|M0)                          L11336                  L11512                
L11336:
        join (8|M0)                          L11448                                
L11352:
        shr (8|M0)               r119.0<1>:ud  r111.0<1;1,0>:ud  1:w               {I@3}
        mov (8|M0)               r87.0<1>:d    0:w                              
        and (8|M0)               r13.0<1>:d    r119.0<1;1,0>:d   4194303:d               {I@2}
        or (8|M0)                r119.0<1>:d   r119.0<1;1,0>:d   4194304:d              
        mov (8|M0)               r127.0<1>:d   0:w                              
(f0.1)  sel (8|M0)               r27.0<1>:d    r119.0<1;1,0>:d   r13.0<1;1,0>:d   {I@2}
L11448:
        join (8|M0)                          L11512                                
L11464:
        and (8|M0)               acc0.0<1>:d   r111.0<1;1,0>:d   1:w               {Compacted}
        add (8|M0)               r108.0<1>:d   r108.0<1;1,0>:d   1:w               {Compacted}
        mov (8|M0)               r24.0<1>:f    r127.0<1;1,0>:f                  {Compacted,I@5}
        mov (8|M0)               r111.0<1>:f   r27.0<1;1,0>:f                   {Compacted,A@2}
        mov (8|M0)               r127.0<1>:d   acc0.0<1;1,0>:d                  {F@2}
L11512:
        join (8|M0)                          L12008                                
L11528:
        shl (8|M0)               r36.0<1>:d    r127.0<1;1,0>:d   2:w               {Compacted,I@2}
        shl (8|M0)               r52.0<1>:d    r24.0<1;1,0>:d    1:w               {Compacted}
        bfn.0xFE (8|M0)          r90.0<1>:ud   r36.0<1;0>:ud     r52.0<1;0>:ud     r87.0<1>:ud      {I@1} // s0|s1|s2
        cmp (8|M0)    (eq)f0.1   null<1>:d     r90.0<1;1,0>:d    0:w               {I@1}
(~f0.1) goto (8|M0)                          L11624                  L11624                
L11592:
        mov (8|M0)               r106.0<1>:d   0:w                              
        goto (8|M0)                          L11624                  L11784                
L11624:
        join (8|M0)                          L11784                                
L11640:
        cmp (8|M0)    (gt)f1.1   null<1>:ud    r90.0<1;1,0>:ud   0x4:uw             
(~f1.1) goto (8|M0)                          L11704                  L11704                
L11672:
        mov (8|M0)               r106.0<1>:d   1:w                              
        goto (8|M0)                          L11704                  L11784                
L11704:
        join (8|M0)                          L11784                                
L11720:
        and (8|M0)    (ne)f1.0   null<1>:d     r111.0<1;1,0>:d   1:w               {F@1}
(W)     mov (1|M0)               r6.4<1>:hf    0x1:hf                             
(f1.0)  cmp (8|M0)    (eq)f1.0   null<1>:d     r90.0<1;1,0>:d    4:w              
(f1.0)  sel (8|M0)               r106.0<1>:d   r6.4<0;1,0>:w     0:w               {F@1}
L11784:
        join (8|M0)                          L12008                                
L11800:
        add (8|M0)               r105.0<1>:d   r111.0<1;1,0>:d   r106.0<1;1,0>:d  {Compacted,I@2}
        cmp (8|M0)    (eq)f1.0   r51.0<1>:d    r105.0<1;1,0>:d   8388608:d               {I@1}
        cmp (8|M0)    (eq)f0.1   null<1>:d     r105.0<1;1,0>:d   8388608:d              
        add3 (8|M0)              r122.0<1>:d   r108.0<1;0>:d     -r51.0<1;0>:d     0:w               {I@2}
        cmp (8|M0)    (eq)f1.0   null<1>:d     r122.0<1;1,0>:d   255:w               {I@1}
(f1.0)  goto (8|M0)                          L11960                  L11960                
L11888:
(~f0.1) sel (8|M0)               r12.0<1>:d    r105.0<1;1,0>:d   0:w              
        and (8|M0)               r119.0<1>:d   r15.0<1;1,0>:d    -2147483648:d              
        shl (8|M0)               r50.0<1>:d    r122.0<1;1,0>:d   23:w               {Compacted}
        bfn.0xFE (8|M0)          r15.0<1>:ud   r119.0<1;0>:ud    r50.0<1;0>:ud     r12.0<1>:ud      {I@1} // s0|s1|s2
        goto (8|M0)                          L11960                  L12088                
L11960:
        join (8|M0)                          L12008                                
L11976:
        bfn.0xEA (8|M0)          r15.0<1>:ud   r7.5<0;0>:ud      r15.0<1;0>:ud     r7.6<0>:ud       {I@3} // s0|s1&s2
        goto (8|M0)                          L12008                  L12088                
L12008:
        join (8|M0)                          L12088                                
L12024:
        cmp (8|M0)    (ne)f0.1   null<1>:d     r66.0<1;1,0>:d    r65.0<1;1,0>:d  
(f0.1)  cmp (8|M0)    (eq)f0.1   null<1>:d     r120.0<1;1,0>:d   0:w              
(f0.1)  cmp (8|M0)    (eq)f0.1   null<1>:d     r103.0<1;1,0>:d   255:w              
(f0.1)  mov (8|M0)               r15.0<1>:f    qnan(0x0):f                               {I@6}
L12088:
        join (8|M0)                          L36464                                
L12104:
        addc (8|M0)              r107.0<1>:ud  r21.0<1;1,0>:ud   0x480:ud              {AccWrEn,Compacted}
        shr (8|M0)               r49.0<1>:ud   r15.0<1;1,0>:ud   23:w               {F@1}
        add (8|M0)               r106.0<1>:ud  acc0.0<1;1,0>:ud  r20.0<1;1,0>:ud 
        addc (8|M0)              r31.0<1>:ud   r107.0<1;1,0>:ud  r19.0<1;1,0>:ud  {AccWrEn,Compacted,I@3}
        and (8|M0)               r107.0<1>:d   r49.0<1;1,0>:d    255:w               {Compacted,I@3}
        add3 (8|M0)              r118.0<1>:ud  acc0.0<1;0>:ud    r106.0<1;0>:ud    r18.0<1>:ud      {I@3}
        and (8|M0)    (ne)f0.1   r18.0<1>:d    r15.0<1;1,0>:d    8388607:d              
(f0.1)  cmp (8|M0)    (eq)f0.1   null<1>:d     r107.0<1;1,0>:d   255:w               {I@3}
(~f0.1) goto (8|M0)                          L12248                  L12248                
L12224:
        mov (8|M0)               r15.0<1>:f    qnan(0x0):f                               {Compacted,I@3}
        goto (8|M0)                          L12248                  L17344                
L12248:
        join (8|M0)                          L17344                                
L12264:
        mov (8|M0)               r74.0<2>:d    r31.0<1;1,0>:d                  
        mov (8|M0)               r74.1<2>:d    r118.0<1;1,0>:d                 
        send.ugm (8|M0)          r124     r74     null:0  0x0            0x04180580           {A@1,$8} // wr:2+0, rd:1; load.ugm.d32.a64.ca.ca
        shr (8|M0)               r48.0<1>:ud   r124.0<1;1,0>:ud  23:w               {$8.dst}
        and (8|M0)    (ne)f1.1   r119.0<1>:d   r124.0<1;1,0>:d   8388607:d              
        and (8|M0)               r102.0<1>:d   r48.0<1;1,0>:d    255:w               {Compacted,I@2}
(f1.1)  cmp (8|M0)    (eq)f1.1   null<1>:d     r102.0<1;1,0>:d   255:w               {I@1}
(~f1.1) goto (8|M0)                          L12408                  L12408                
L12384:
        mov (8|M0)               r15.0<1>:f    qnan(0x0):f                               {Compacted}
        goto (8|M0)                          L12408                  L17344                
L12408:
        join (8|M0)                          L17344                                
L12424:
        cmp (8|M0)    (eq)f0.1   null<1>:d     r18.0<1;1,0>:d    0:w              
        shr (8|M0)               r64.0<1>:ud   r15.0<1;1,0>:ud   31:w               {F@1}
        shr (8|M0)               r63.0<1>:ud   r124.0<1;1,0>:ud  31:w              
        cmp (8|M0)    (eq)f1.1   null<1>:d     r119.0<1;1,0>:d   0:w              
(f0.1)  cmp (8|M0)    (eq)f0.1   null<1>:d     r107.0<1;1,0>:d   255:w              
(f0.1)  goto (8|M0)                          L17264                  L17264                
L12520:
        cmp (8|M0)    (eq)f0.1   null<1>:d     r102.0<1;1,0>:d   255:w              
(W)     mov (1|M0)               r6.4<1>:hf    0x1:hf                             
        or (8|M0)                r47.0<1>:d    r107.0<1;1,0>:d   r18.0<1;1,0>:d   {Compacted}
(f1.1)  sel (8|M0)               r12.0<1>:uw   r6.4<0;1,0>:uw    0x0:uw              {F@1}
(f0.1)  sel (8|M0)               r13.0<1>:uw   r6.4<0;1,0>:uw    0x0:uw             
        and (8|M0)    (ne)f1.0   null<1>:uw    r13.0<1;1,0>:uw   r12.0<1;1,0>:uw  {I@1}
(~f1.0) cmp (8|M0)    (eq)f1.0   null<1>:d     r47.0<1;1,0>:d    0:w              
(~f1.0) goto (8|M0)                          L12664                  L12664                
L12640:
        mov (8|M0)               r15.0<1>:f    r124.0<1;1,0>:f                  {Compacted}
        goto (8|M0)                          L12664                  L17344                
L12664:
        join (8|M0)                          L17264                                
L12680:
        or (8|M0)     (eq)f0.1   null<1>:d     r102.0<1;1,0>:d   r119.0<1;1,0>:d 
(f0.1)  goto (8|M0)                          L17264                  L17344                
L12712:
        cmp (8|M0)    (eq)f1.1   null<1>:d     r64.0<1;1,0>:d    r63.0<1;1,0>:d  
        cmp (8|M0)    (lt)f0.1   null<1>:ud    r102.0<1;1,0>:ud  r107.0<1;1,0>:ud
(f1.1)  goto (8|M0)                          L12968                  L12968                
L12760:
(f0.1)  goto (8|M0)                          L12864                  L12864                
L12776:
        mov (8|M0)               r56.0<1>:f    r124.0<1;1,0>:f                  {Compacted}
        mov (8|M0)               r42.0<1>:f    r15.0<1;1,0>:f                   {Compacted,F@2}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        call (8|M0)              r6.2          L36720                                 {A@1}
L12840:
        mov (8|M0)               r15.0<1>:f    r76.0<1;1,0>:f                   {Compacted}
        goto (8|M0)                          L12864                  L17344                
L12864:
        join (8|M0)                          L12968                                
L12880:
        mov (8|M0)               r56.0<1>:f    r15.0<1;1,0>:f                   {Compacted,F@1}
        mov (8|M0)               r42.0<1>:f    r124.0<1;1,0>:f                  {Compacted}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        call (8|M0)              r6.2          L36720                                 {A@1}
L12944:
        mov (8|M0)               r15.0<1>:f    r76.0<1;1,0>:f                   {Compacted}
        goto (8|M0)                          L12968                  L17344                
L12968:
        join (8|M0)                          L17264                                
L12984:
(f0.1)  goto (8|M0)                          L15208                  L15208                
L13000:
        cmp (8|M0)    (eq)f1.1   null<1>:d     r107.0<1;1,0>:d   0:w              
(f1.1)  goto (8|M0)                          L13088                  L13088                
L13032:
(W)     mov (1|M0)               r6.8<2>:b     1:w                              
        add (8|M0)               r115.0<1>:d   r102.0<1;1,0>:d   -r107.0<1;1,0>:d {Compacted}
        mov (8|M0)               r12.0<1>:b    r6.8<0;1,0>:b                    {I@2}
        goto (8|M0)                          L13088                  L13176                
L13088:
        join (8|M0)                          L13176                                
L13104:
        cmp (8|M0)    (eq)f1.0   null<1>:d     r102.0<1;1,0>:d   0:w              
(f1.0)  goto (8|M0)                          L13176                  L15152                
L13136:
(W)     mov (1|M0)               r6.8<2>:b     0:w                              
        add (8|M0)               r115.0<1>:d   r102.0<1;1,0>:d   -1:w               {Compacted}
        mov (8|M0)               r12.0<1>:b    r6.8<0;1,0>:b                    {I@2}
L13176:
        join (8|M0)                          L15152                                
L13192:
        cmp (8|M0)    (lt)f0.1   null<1>:d     r115.0<1;1,0>:d   1:w               {I@3}
(f0.1)  goto (8|M0)                          L13904                  L13904                
L13224:
        cmp (8|M0)    (eq)f1.0   null<1>:d     r115.0<1;1,0>:d   1:w              
(f1.0)  goto (8|M0)                          L13784                  L13784                
L13256:
        cmp (8|M0)    (lt)f0.1   null<1>:ud    r115.0<1;1,0>:ud  0x18:uw             
(f0.1)  goto (8|M0)                          L13544                  L13544                
L13288:
        cmp (8|M0)    (lt)f1.1   null<1>:d     r115.0<1;1,0>:d   25:w              
        mov (8|M0)               r122.0<1>:d   r12.0<1;1,0>:ub                  {I@7}
(f1.1)  goto (8|M0)                          L13440                  L13440                
L13336:
        cmp (8|M0)    (eq)f1.0   null<1>:d     r115.0<1;1,0>:d   25:w              
(~f1.0) goto (8|M0)                          L13440                  L13952                
L13368:
        cmp (8|M0)    (ne)f0.1   r62.0<1>:d    r18.0<1;1,0>:d    0:w              
        mov (8|M0)               r47.0<1>:f    r122.0<1;1,0>:f                  {Compacted,I@5}
        mov (8|M0)               r65.0<1>:d    0:w                              
        mov (8|M0)               r122.0<1>:d   0:w                               {F@1}
        goto (8|M0)                          L13440                  L14032                
L13440:
        join (8|M0)                          L13544                                
L13456:
        shr (8|M0)               r46.0<1>:ud   r15.0<1;1,0>:ud   22:w              
        and (8|M0)               r45.0<1>:d    r15.0<1;1,0>:d    4194303:d              
        mov (8|M0)               r65.0<1>:d    0:w                              
        and (8|M0)               r47.0<1>:d    r46.0<1;1,0>:d    1:w               {Compacted,I@3}
        cmp (8|M0)    (ne)f1.1   r62.0<1>:d    r45.0<1;1,0>:d    0:w               {I@3}
        goto (8|M0)                          L13544                  L14032                
L13544:
        join (8|M0)                          L13784                                
L13560:
        add (8|M0)               acc0.0<1>:d   r115.0<1;1,0>:d   -2:w               {Compacted}
(W)     mov (1|M0)               r6.4<1>:hf    -qnan(0x1FF):hf                             
        add (8|M0)               acc2.0<1>:d   r115.0<1;1,0>:d   -1:w               {Compacted}
        add (8|M0)               r61.0<1>:d    -r115.0<1;1,0>:d  23:w               {Compacted}
        shr (8|M0)               r44.0<1>:ud   r18.0<1;1,0>:ud   acc0.0<1;1,0>:d 
        shl (8|M0)               r127.0<1>:d   r6.4<0;1,0>:w     acc0.0<1;1,0>:d  {F@1}
(W)     mov (1|M0)               r6.4<1>:hf    0x1:hf                              {I@1}
        shr (8|M0)               r30.0<1>:ud   r18.0<1;1,0>:ud   r115.0<1;1,0>:d 
        shr (8|M0)               r73.0<1>:ud   r18.0<1;1,0>:ud   acc2.0<1;1,0>:d 
        and (8|M0)               r47.0<1>:d    r44.0<1;1,0>:d    1:w               {Compacted}
        shl (8|M0)               r61.0<1>:d    r6.4<0;1,0>:w     r61.0<1;1,0>:d   {F@1}
        bfn.0x60 (8|M0)          r44.0<1>:ud   r127.0<1;0>:ud    r7.4<0;0>:ud      r18.0<1>:ud      // (s0^s1)&s2
(f1.1)  mov (8|M0)               r61.0<1>:d    0:w                              
        and (8|M0)               r122.0<1>:d   r73.0<1;1,0>:d    1:w               {Compacted,I@5}
        cmp (8|M0)    (ne)f1.0   r62.0<1>:d    r44.0<1;1,0>:d    0:w               {I@3}
        or (8|M0)                r65.0<1>:d    r30.0<1;1,0>:d    r61.0<1;1,0>:d   {Compacted,I@3}
        goto (8|M0)                          L13784                  L14032                
L13784:
        join (8|M0)                          L13904                                
L13800:
        shr (8|M0)               r103.0<1>:ud  r18.0<1;1,0>:ud   1:w              
        and (8|M0)               r122.0<1>:d   r15.0<1;1,0>:d    1:w               {Compacted}
        or (8|M0)                r43.0<1>:d    r103.0<1;1,0>:d   4194304:d               {I@2}
        mov (8|M0)               r47.0<1>:d    0:w                              
        mov (8|M0)               r62.0<1>:d    0:w                              
(f1.1)  sel (8|M0)               r65.0<1>:d    r103.0<1;1,0>:d   r43.0<1;1,0>:d   {I@3}
        goto (8|M0)                          L13904                  L14032                
L13904:
        join (8|M0)                          L13952                                
L13920:
        cmp (8|M0)    (eq)f0.1   null<1>:d     r115.0<1;1,0>:d   0:w              
(f0.1)  goto (8|M0)                          L13952                  L14248                
L13952:
        join (8|M0)                          L14032                                
L13968:
        cmp (8|M0)    (ne)f0.1   r62.0<1>:d    r15.0<1;1,0>:d    0:w              
        mov (8|M0)               r122.0<1>:d   0:w                              
        mov (8|M0)               r47.0<1>:d    0:w                              
        mov (8|M0)               r65.0<1>:d    0:w                              
L14032:
        join (8|M0)                          L14248                                
L14048:
        add (8|M0)               r106.0<1>:d   r119.0<1;1,0>:d   r65.0<1;1,0>:d   {Compacted,I@2}
        cmp (8|M0)    (ne)f1.1   r121.0<1>:d   r62.0<1;1,0>:d    0:w              
        cmp (8|M0)    (gt)f1.1   null<1>:ud    r106.0<1;1,0>:ud  0x7FFFFF:ud              {I@2}
        mov (8|M0)               r79.0<1>:d    -r121.0<1;1,0>:d                 {I@2}
(f1.1)  goto (8|M0)                          L14152                  L14152                
L14120:
        mov (8|M0)               r114.0<1>:d   r47.0<1;1,0>:d                  
        goto (8|M0)                          L14152                  L14656                
L14152:
        join (8|M0)                          L14248                                
L14168:
        cmp (8|M0)    (eq)f1.0   null<1>:d     r47.0<1;1,0>:d    1:w              
        shr (8|M0)               r42.0<1>:ud   r106.0<1;1,0>:ud  1:w              
        and (8|M0)               r110.0<1>:d   r42.0<1;1,0>:d    4194303:d               {I@1}
(~f1.0) sel (8|M0)               r79.0<1>:d    -r121.0<1;1,0>:d  1:w              
        goto (8|M0)                          L14248                  L14592                
L14248:
        join (8|M0)                          L14592                                
L14264:
        add (8|M0)               r106.0<1>:d   r119.0<1;1,0>:d   r18.0<1;1,0>:d   {Compacted}
        cmp (8|M0)    (gt)f0.1   null<1>:ud    r106.0<1;1,0>:ud  0x7FFFFF:ud              {I@1}
(f0.1)  goto (8|M0)                          L14480                  L14480                
L14304:
(~f1.1) goto (8|M0)                          L14384                  L14384                
L14320:
        mov (8|M0)               r122.0<1>:d   0:w                              
        mov (8|M0)               r114.0<1>:d   0:w                              
        mov (8|M0)               r79.0<1>:d    0:w                              
        goto (8|M0)                          L14384                  L14656                
L14384:
        join (8|M0)                          L14480                                
L14400:
        and (8|M0)               r122.0<1>:d   r106.0<1;1,0>:d   1:w               {Compacted}
        add (8|M0)               r102.0<1>:d   r102.0<1;1,0>:d   1:w               {Compacted}
        mov (8|M0)               r114.0<1>:d   0:w                              
        mov (8|M0)               r79.0<1>:d    0:w                              
        shr (8|M0)               r106.0<1>:ud  r106.0<1;1,0>:ud  1:w              
        goto (8|M0)                          L14480                  L14656                
L14480:
        join (8|M0)                          L14592                                
L14496:
        shr (8|M0)               r107.0<1>:ud  r106.0<1;1,0>:ud  1:w               {I@3}
        mov (8|M0)               r79.0<1>:d    0:w                              
        and (8|M0)               r97.0<1>:d    r107.0<1;1,0>:d   4194303:d               {I@2}
        or (8|M0)                r107.0<1>:d   r107.0<1;1,0>:d   4194304:d              
        mov (8|M0)               r122.0<1>:d   0:w                              
(f1.1)  sel (8|M0)               r110.0<1>:d   r97.0<1;1,0>:d    r107.0<1;1,0>:d  {I@2}
L14592:
        join (8|M0)                          L14656                                
L14608:
        and (8|M0)               acc0.0<1>:d   r106.0<1;1,0>:d   1:w               {Compacted}
        add (8|M0)               r102.0<1>:d   r102.0<1;1,0>:d   1:w               {Compacted}
        mov (8|M0)               r114.0<1>:f   r122.0<1;1,0>:f                  {Compacted,I@5}
        mov (8|M0)               r106.0<1>:f   r110.0<1;1,0>:f                  {Compacted,A@2}
        mov (8|M0)               r122.0<1>:d   acc0.0<1;1,0>:d                  {F@2}
L14656:
        join (8|M0)                          L15152                                
L14672:
        shl (8|M0)               r111.0<1>:d   r122.0<1;1,0>:d   2:w               {Compacted,I@2}
        shl (8|M0)               r41.0<1>:d    r114.0<1;1,0>:d   1:w               {Compacted}
        bfn.0xFE (8|M0)          r62.0<1>:ud   r111.0<1;0>:ud    r41.0<1;0>:ud     r79.0<1>:ud      {I@1} // s0|s1|s2
        cmp (8|M0)    (eq)f1.1   null<1>:d     r62.0<1;1,0>:d    0:w               {I@1}
(~f1.1) goto (8|M0)                          L14768                  L14768                
L14736:
        mov (8|M0)               r68.0<1>:d    0:w                              
        goto (8|M0)                          L14768                  L14928                
L14768:
        join (8|M0)                          L14928                                
L14784:
        cmp (8|M0)    (gt)f1.0   null<1>:ud    r62.0<1;1,0>:ud   0x4:uw             
(~f1.0) goto (8|M0)                          L14848                  L14848                
L14816:
        mov (8|M0)               r68.0<1>:d    1:w                              
        goto (8|M0)                          L14848                  L14928                
L14848:
        join (8|M0)                          L14928                                
L14864:
        and (8|M0)    (ne)f0.1   null<1>:d     r106.0<1;1,0>:d   1:w               {F@1}
(W)     mov (1|M0)               r6.4<1>:hf    0x1:hf                             
(f0.1)  cmp (8|M0)    (eq)f0.1   null<1>:d     r62.0<1;1,0>:d    4:w              
(f0.1)  sel (8|M0)               r68.0<1>:d    r6.4<0;1,0>:w     0:w               {F@1}
L14928:
        join (8|M0)                          L15152                                
L14944:
        add (8|M0)               r67.0<1>:d    r106.0<1;1,0>:d   r68.0<1;1,0>:d   {Compacted,I@2}
        cmp (8|M0)    (eq)f0.1   r40.0<1>:d    r67.0<1;1,0>:d    8388608:d               {I@1}
        cmp (8|M0)    (eq)f1.0   null<1>:d     r67.0<1;1,0>:d    8388608:d              
        add3 (8|M0)              r98.0<1>:d    r102.0<1;0>:d     -r40.0<1;0>:d     0:w               {I@2}
        cmp (8|M0)    (eq)f0.1   null<1>:d     r98.0<1;1,0>:d    255:w               {I@1}
(f0.1)  goto (8|M0)                          L15104                  L15104                
L15032:
(~f1.0) sel (8|M0)               r96.0<1>:d    r67.0<1;1,0>:d    0:w              
        and (8|M0)               r83.0<1>:d    r124.0<1;1,0>:d   -2147483648:d              
        shl (8|M0)               r39.0<1>:d    r98.0<1;1,0>:d    23:w               {Compacted}
        bfn.0xFE (8|M0)          r15.0<1>:ud   r83.0<1;0>:ud     r39.0<1;0>:ud     r96.0<1>:ud      {I@1} // s0|s1|s2
        goto (8|M0)                          L15104                  L17344                
L15104:
        join (8|M0)                          L15152                                
L15120:
        bfn.0xEA (8|M0)          r15.0<1>:ud   r7.5<0;0>:ud      r124.0<1;0>:ud    r7.6<0>:ud       // s0|s1&s2
        goto (8|M0)                          L15152                  L17344                
L15152:
        join (8|M0)                          L15208                                
L15168:
        add (8|M0)               r38.0<1>:d    r119.0<1;1,0>:d   r18.0<1;1,0>:d   {Compacted}
        bfn.0xF8 (8|M0)          r15.0<1>:ud   r124.0<1;0>:ud    r7.6<0;0>:ud      r38.0<1>:ud      {I@1} // s0&s1|s2
        goto (8|M0)                          L15208                  L17344                
L15208:
        join (8|M0)                          L17264                                
L15224:
        cmp (8|M0)    (ne)f1.0   null<1>:d     r102.0<1;1,0>:d   0:w              
(f1.0)  sel (8|M0)               r37.0<1>:d    -r102.0<1;1,0>:d  -1:w              
        add (8|M0)               r38.0<1>:d    r107.0<1;1,0>:d   r37.0<1;1,0>:d   {Compacted,I@1}
        cmp (8|M0)    (lt)f1.1   null<1>:d     r38.0<1;1,0>:d    1:w               {I@1}
(f1.1)  goto (8|M0)                          L16016                  L16016                
L15296:
        cmp (8|M0)    (eq)f0.1   null<1>:d     r38.0<1;1,0>:d    1:w              
(f0.1)  goto (8|M0)                          L15896                  L15896                
L15328:
        cmp (8|M0)    (lt)f1.1   null<1>:ud    r38.0<1;1,0>:ud   0x18:uw             
(f1.1)  goto (8|M0)                          L15632                  L15632                
L15360:
        cmp (8|M0)    (ne)f1.0   r37.0<1>:d    r102.0<1;1,0>:d   0:w              
        cmp (8|M0)    (lt)f1.0   null<1>:d     r38.0<1;1,0>:d    25:w              
        mov (8|M0)               r123.0<1>:d   -r37.0<1;1,0>:d                  {I@2}
(f1.0)  goto (8|M0)                          L15528                  L15528                
L15424:
        cmp (8|M0)    (eq)f0.1   null<1>:d     r38.0<1;1,0>:d    25:w              
(~f0.1) goto (8|M0)                          L15528                  L16064                
L15456:
        cmp (8|M0)    (ne)f0.1   r60.0<1>:d    r119.0<1;1,0>:d   0:w              
        mov (8|M0)               r48.0<1>:f    r123.0<1;1,0>:f                  {Compacted,I@5}
        mov (8|M0)               r64.0<1>:d    0:w                              
        mov (8|M0)               r123.0<1>:d   0:w                               {F@1}
        goto (8|M0)                          L15528                  L16144                
L15528:
        join (8|M0)                          L15632                                
L15544:
        shr (8|M0)               r36.0<1>:ud   r124.0<1;1,0>:ud  22:w              
        and (8|M0)               r35.0<1>:d    r124.0<1;1,0>:d   4194303:d              
        mov (8|M0)               r64.0<1>:d    0:w                              
        and (8|M0)               r48.0<1>:d    r36.0<1;1,0>:d    1:w               {Compacted,I@3}
        cmp (8|M0)    (ne)f1.1   r60.0<1>:d    r35.0<1;1,0>:d    0:w               {I@3}
        goto (8|M0)                          L15632                  L16144                
L15632:
        join (8|M0)                          L15896                                
L15648:
        add3 (8|M0)              acc0.0<1>:d   r107.0<1;0>:d     r37.0<1;0>:d      -2:w              
(W)     mov (1|M0)               r6.4<1>:hf    -qnan(0x1FF):hf                             
        add3 (8|M0)              acc2.0<1>:d   r107.0<1;0>:d     r37.0<1;0>:d      -1:w              
        add3 (8|M0)              r59.0<1>:d    23:w                -r107.0<1;0>:d    -r37.0<1>:d     
        shr (8|M0)               r34.0<1>:ud   r119.0<1;1,0>:ud  acc0.0<1;1,0>:d 
        shl (8|M0)               r19.0<1>:d    r6.4<0;1,0>:w     acc0.0<1;1,0>:d  {F@1}
(W)     mov (1|M0)               r6.4<1>:hf    0x1:hf                              {I@1}
        shr (8|M0)               r29.0<1>:ud   r119.0<1;1,0>:ud  r38.0<1;1,0>:d  
        shr (8|M0)               r80.0<1>:ud   r119.0<1;1,0>:ud  acc2.0<1;1,0>:d 
        bfn.0x60 (8|M0)          r54.0<1>:ud   r19.0<1;0>:ud     r7.4<0;0>:ud      r119.0<1>:ud     // (s0^s1)&s2
        shl (8|M0)               r59.0<1>:d    r6.4<0;1,0>:w     r59.0<1;1,0>:d   {F@1}
(~f1.0) mov (8|M0)               r59.0<1>:d    0:w                              
        and (8|M0)               r48.0<1>:d    r34.0<1;1,0>:d    1:w               {Compacted}
        and (8|M0)               r123.0<1>:d   r80.0<1;1,0>:d    1:w               {Compacted,I@5}
        cmp (8|M0)    (ne)f1.0   r60.0<1>:d    r54.0<1;1,0>:d    0:w               {I@5}
        or (8|M0)                r64.0<1>:d    r29.0<1;1,0>:d    r59.0<1;1,0>:d   {Compacted,I@4}
        goto (8|M0)                          L15896                  L16144                
L15896:
        join (8|M0)                          L16016                                
L15912:
        shr (8|M0)               r102.0<1>:ud  r119.0<1;1,0>:ud  1:w              
        and (8|M0)               r123.0<1>:d   r124.0<1;1,0>:d   1:w               {Compacted}
        or (8|M0)                r33.0<1>:d    r102.0<1;1,0>:d   4194304:d               {I@2}
        mov (8|M0)               r48.0<1>:d    0:w                              
        mov (8|M0)               r60.0<1>:d    0:w                              
(f1.0)  sel (8|M0)               r64.0<1>:d    r33.0<1;1,0>:d    r102.0<1;1,0>:d  {I@3}
        goto (8|M0)                          L16016                  L16144                
L16016:
        join (8|M0)                          L16064                                
L16032:
        cmp (8|M0)    (eq)f1.1   null<1>:d     r38.0<1;1,0>:d    0:w              
(f1.1)  goto (8|M0)                          L16064                  L16360                
L16064:
        join (8|M0)                          L16144                                
L16080:
        cmp (8|M0)    (ne)f0.1   r60.0<1>:d    r124.0<1;1,0>:d   0:w              
        mov (8|M0)               r123.0<1>:d   0:w                              
        mov (8|M0)               r48.0<1>:d    0:w                              
        mov (8|M0)               r64.0<1>:d    0:w                              
L16144:
        join (8|M0)                          L16360                                
L16160:
        add (8|M0)               r105.0<1>:d   r18.0<1;1,0>:d    r64.0<1;1,0>:d   {Compacted,I@2}
        cmp (8|M0)    (ne)f1.1   r120.0<1>:d   r60.0<1;1,0>:d    0:w              
        cmp (8|M0)    (gt)f1.0   null<1>:ud    r105.0<1;1,0>:ud  0x7FFFFF:ud              {I@2}
        mov (8|M0)               r78.0<1>:d    -r120.0<1;1,0>:d                 {I@2}
(f1.0)  goto (8|M0)                          L16264                  L16264                
L16232:
        mov (8|M0)               r113.0<1>:d   r48.0<1;1,0>:d                  
        goto (8|M0)                          L16264                  L16768                
L16264:
        join (8|M0)                          L16360                                
L16280:
        cmp (8|M0)    (eq)f0.1   null<1>:d     r48.0<1;1,0>:d    1:w              
        shr (8|M0)               r32.0<1>:ud   r105.0<1;1,0>:ud  1:w              
        and (8|M0)               r109.0<1>:d   r32.0<1;1,0>:d    4194303:d               {I@1}
(~f0.1) sel (8|M0)               r78.0<1>:d    -r120.0<1;1,0>:d  1:w              
        goto (8|M0)                          L16360                  L16704                
L16360:
        join (8|M0)                          L16704                                
L16376:
        add (8|M0)               r105.0<1>:d   r18.0<1;1,0>:d    r119.0<1;1,0>:d  {Compacted}
        cmp (8|M0)    (gt)f1.1   null<1>:ud    r105.0<1;1,0>:ud  0x7FFFFF:ud              {I@1}
(f1.1)  goto (8|M0)                          L16592                  L16592                
L16416:
(f1.0)  goto (8|M0)                          L16496                  L16496                
L16432:
        mov (8|M0)               r123.0<1>:d   0:w                              
        mov (8|M0)               r113.0<1>:d   0:w                              
        mov (8|M0)               r78.0<1>:d    0:w                              
        goto (8|M0)                          L16496                  L16768                
L16496:
        join (8|M0)                          L16592                                
L16512:
        and (8|M0)               r123.0<1>:d   r105.0<1;1,0>:d   1:w               {Compacted}
        add (8|M0)               r107.0<1>:d   r107.0<1;1,0>:d   1:w               {Compacted}
        mov (8|M0)               r113.0<1>:d   0:w                              
        mov (8|M0)               r78.0<1>:d    0:w                              
        shr (8|M0)               r105.0<1>:ud  r105.0<1;1,0>:ud  1:w              
        goto (8|M0)                          L16592                  L16768                
L16592:
        join (8|M0)                          L16704                                
L16608:
        shr (8|M0)               r106.0<1>:ud  r105.0<1;1,0>:ud  1:w               {I@3}
        mov (8|M0)               r78.0<1>:d    0:w                              
        and (8|M0)               r95.0<1>:d    r106.0<1;1,0>:d   4194303:d               {I@2}
        or (8|M0)                r106.0<1>:d   r106.0<1;1,0>:d   4194304:d              
        mov (8|M0)               r123.0<1>:d   0:w                              
(f1.0)  sel (8|M0)               r109.0<1>:d   r106.0<1;1,0>:d   r95.0<1;1,0>:d   {I@2}
L16704:
        join (8|M0)                          L16768                                
L16720:
        and (8|M0)               acc0.0<1>:d   r105.0<1;1,0>:d   1:w               {Compacted}
        add (8|M0)               r107.0<1>:d   r107.0<1;1,0>:d   1:w               {Compacted}
        mov (8|M0)               r113.0<1>:f   r123.0<1;1,0>:f                  {Compacted,I@5}
        mov (8|M0)               r105.0<1>:f   r109.0<1;1,0>:f                  {Compacted,A@2}
        mov (8|M0)               r123.0<1>:d   acc0.0<1;1,0>:d                  {F@2}
L16768:
        join (8|M0)                          L17264                                
L16784:
        shl (8|M0)               r110.0<1>:d   r123.0<1;1,0>:d   2:w               {Compacted,I@2}
        shl (8|M0)               r31.0<1>:d    r113.0<1;1,0>:d   1:w               {Compacted}
        bfn.0xFE (8|M0)          r61.0<1>:ud   r110.0<1;0>:ud    r31.0<1;0>:ud     r78.0<1>:ud      {I@1} // s0|s1|s2
        cmp (8|M0)    (eq)f0.1   null<1>:d     r61.0<1;1,0>:d    0:w               {I@1}
(~f0.1) goto (8|M0)                          L16880                  L16880                
L16848:
        mov (8|M0)               r66.0<1>:d    0:w                              
        goto (8|M0)                          L16880                  L17040                
L16880:
        join (8|M0)                          L17040                                
L16896:
        cmp (8|M0)    (gt)f1.1   null<1>:ud    r61.0<1;1,0>:ud   0x4:uw             
(~f1.1) goto (8|M0)                          L16960                  L16960                
L16928:
        mov (8|M0)               r66.0<1>:d    1:w                              
        goto (8|M0)                          L16960                  L17040                
L16960:
        join (8|M0)                          L17040                                
L16976:
        and (8|M0)    (ne)f1.1   null<1>:d     r105.0<1;1,0>:d   1:w               {F@1}
(W)     mov (1|M0)               r6.4<1>:hf    0x1:hf                             
(f1.1)  cmp (8|M0)    (eq)f1.1   null<1>:d     r61.0<1;1,0>:d    4:w              
(f1.1)  sel (8|M0)               r66.0<1>:d    r6.4<0;1,0>:w     0:w               {F@1}
L17040:
        join (8|M0)                          L17264                                
L17056:
        add (8|M0)               r65.0<1>:d    r105.0<1;1,0>:d   r66.0<1;1,0>:d   {Compacted,I@2}
        cmp (8|M0)    (eq)f1.1   r30.0<1>:d    r65.0<1;1,0>:d    8388608:d               {I@1}
        cmp (8|M0)    (eq)f0.1   null<1>:d     r65.0<1;1,0>:d    8388608:d              
        add3 (8|M0)              r97.0<1>:d    r107.0<1;0>:d     -r30.0<1;0>:d     0:w               {I@2}
        cmp (8|M0)    (eq)f1.0   null<1>:d     r97.0<1;1,0>:d    255:w               {I@1}
(f1.0)  goto (8|M0)                          L17216                  L17216                
L17144:
(~f0.1) sel (8|M0)               r94.0<1>:d    r65.0<1;1,0>:d    0:w              
        and (8|M0)               r82.0<1>:d    r15.0<1;1,0>:d    -2147483648:d              
        shl (8|M0)               r29.0<1>:d    r97.0<1;1,0>:d    23:w               {Compacted}
        bfn.0xFE (8|M0)          r15.0<1>:ud   r82.0<1;0>:ud     r29.0<1;0>:ud     r94.0<1>:ud      {I@1} // s0|s1|s2
        goto (8|M0)                          L17216                  L17344                
L17216:
        join (8|M0)                          L17264                                
L17232:
        bfn.0xEA (8|M0)          r15.0<1>:ud   r7.5<0;0>:ud      r15.0<1;0>:ud     r7.6<0>:ud       {I@3} // s0|s1&s2
        goto (8|M0)                          L17264                  L17344                
L17264:
        join (8|M0)                          L17344                                
L17280:
        cmp (8|M0)    (ne)f1.1   null<1>:d     r64.0<1;1,0>:d    r63.0<1;1,0>:d  
(f1.1)  cmp (8|M0)    (eq)f1.1   null<1>:d     r119.0<1;1,0>:d   0:w              
(f1.1)  cmp (8|M0)    (eq)f1.1   null<1>:d     r102.0<1;1,0>:d   255:w              
(f1.1)  mov (8|M0)               r15.0<1>:f    qnan(0x0):f                               {I@6}
L17344:
        join (8|M0)                          L36464                                
L17360:
        shr (8|M0)               r90.0<1>:ud   r17.0<1;1,0>:ud   1:w              
        shr (8|M0)               r28.0<1>:ud   r16.0<1;1,0>:ud   1:w              
        mul (8|M0)               acc0.0<1>:ud  r90.0<1;1,0>:ud   r7.14<0;1,0>:uw  {I@2}
        mach (8|M0)              r92.0<1>:ud   r90.0<1;1,0>:ud   r7.7<0;1,0>:ud   {AccWrEn,Compacted}
        shr (8|M0)               r27.0<1>:ud   r15.0<1;1,0>:ud   23:w               {F@1}
        and (8|M0)    (ne)f1.0   r72.0<1>:d    r15.0<1;1,0>:d    8388607:d              
        mov (8|M0)               r91.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        and (8|M0)               r54.0<1>:d    r27.0<1;1,0>:d    255:w               {Compacted,I@3}
        addc (8|M0)              r102.0<1>:ud  r91.0<1;1,0>:ud   r28.0<1;1,0>:ud  {AccWrEn,Compacted,I@2}
(f1.0)  cmp (8|M0)    (eq)f1.0   null<1>:d     r54.0<1;1,0>:d    255:w               {I@2}
        add (8|M0)               r57.0<1>:ud   acc0.0<1;1,0>:ud  r92.0<1;1,0>:ud 
        shl (8|M0)               r13.0<1>:d    r102.0<1;1,0>:d   6:w               {Compacted,I@3}
        shr (8|M0)               r102.0<1>:ud  r102.0<1;1,0>:ud  26:w              
        shl (8|M0)               r57.0<1>:d    r57.0<1;1,0>:d    6:w               {Compacted,I@3}
        or (8|M0)                r12.0<1>:d    r57.0<1;1,0>:d    r102.0<1;1,0>:d  {Compacted,I@1}
(~f1.0) goto (8|M0)                          L17584                  L17584                
L17560:
        mov (8|M0)               r14.0<1>:f    qnan(0x0):f                               {Compacted}
        goto (8|M0)                          L17584                  L23488                
L17584:
        join (8|M0)                          L23488                                
L17600:
        cmp (8|M0)    (eq)f0.1   null<1>:d     r72.0<1;1,0>:d    0:w              
(f0.1)  cmp (8|M0)    (eq)f0.1   null<1>:d     r54.0<1;1,0>:d    255:w              
(f0.1)  goto (8|M0)                          L23456                  L23456                
L17648:
        or (8|M0)     (eq)f0.1   null<1>:d     r54.0<1;1,0>:d    r72.0<1;1,0>:d  
(~f0.1) goto (8|M0)                          L17704                  L17704                
L17680:
        mov (8|M0)               r14.0<1>:f    0.0:f                               {Compacted}
        goto (8|M0)                          L17704                  L23488                
L17704:
        join (8|M0)                          L23456                                
L17720:
        cmp (8|M0)    (eq)f1.0   null<1>:d     r54.0<1;1,0>:d    0:w              
(W)     mov (1|M0)               r6.4<1>:hf    0.0:hf                             
        add (8|M0)               r69.0<1>:d    r54.0<1;1,0>:d    -129:w               {Compacted}
(W)     mov (1|M0)               r6.6<1>:d     0:w                              
(f1.0)  sel (8|M0)               acc0.0<1>:d   r6.4<0;1,0>:w     8388608:d               {F@1}
(W)     mov (1|M0)               r6.3<1>:f     -0.0:f                               {Compacted}
        or (8|M0)                r108.0<1>:d   acc0.0<1;1,0>:d   r72.0<1;1,0>:d  
(W)     mov (2|M0)               r6.4<1>:d     0:w                              
        shl (8|M0)               r27.0<1>:d    r108.0<1;1,0>:d   23:w               {Compacted,I@2}
        shr (8|M0)               r30.0<1>:ud   r108.0<1;1,0>:ud  9:w              
L17856:
(W)     shl (1|M0)               r16.1<1>:d    r6.3<0;1,0>:d     31:w               {F@1}
(W)     shr (1|M0)               r6.7<1>:ud    r6.6<0;1,0>:ud    1:w              
(W)     cmp (8|M0)    (gt)f0.1   null<1>:ud    r6.4<0;1,0>:ud    0x3E:uw              {I@5}
(W)     or (1|M0)                r6.6<1>:d     r6.7<0;1,0>:d     r16.1<0;1,0>:d   {I@2}
        bfn.0xE0 (8|M0)          r29.0<1>:ud   r6.7<0;0>:ud      r16.1<0;0>:ud     r27.0<1>:ud      // (s0|s1)&s2
(W)     shr (1|M0)               r6.2<1>:ud    r6.3<0;1,0>:ud    1:w              
(W&f0.1) cmp (8|M0)   (eq)f0.1   null<1>:d     r6.5<0;1,0>:d     0:w              
        cmp (8|M0)    (eq)f1.1   null<1>:d     r29.0<1;1,0>:d    r6.6<0;1,0>:d    {I@3}
        and (8|M0)               r28.0<1>:d    r6.2<0;1,0>:d     r30.0<1;1,0>:d   {Compacted,I@3}
(W)     addc (1|M0)              r18.0<1>:ud   r6.4<0;1,0>:ud    0x1:ud              {AccWrEn}
(W&~f0.1) cmp (8|M0)  (gt)f0.1   null<1>:ud    r6.5<0;1,0>:ud    0x0:uw             
(f1.1)  cmp (8|M0)    (eq)f1.1   null<1>:d     r28.0<1;1,0>:d    r6.2<0;1,0>:d    {I@3}
(W)     mov (1|M0)               r6.14<1>:hf   0x1:hf                             
(W)     mov (1|M0)               r16.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
(f0.1)  sel (8|M0)               r17.0<1>:uw   r6.14<0;1,0>:uw   0x0:uw              {F@1}
(W)     add (1|M0)               r16.4<1>:ud   r16.0<0;1,0>:ud   r6.5<0;1,0>:ud   {I@2}
(f1.1)  sel (8|M0)               r16.0<1>:uw   r6.14<0;1,0>:uw   0x0:uw             
        mov (8|M0)               r93.0<1>:d    r6.4<0;1,0>:d                   
        or (8|M0)     (ne)f0.1   null<1>:uw    r17.0<1;1,0>:uw   r16.0<1;1,0>:uw  {I@2}
        mov (8|M0)               r100.0<1>:d   r6.5<0;1,0>:d                   
        mov (8|M0)               r24.0<1>:f    r18.0<0;1,0>:f                   {Compacted}
        mov (8|M0)               r66.0<1>:d    r16.4<0;1,0>:d                  
(f0.1)  goto (8|M0)                          L18264                  L18264                
L18200:
(W)     mov (1|M0)               r6.3<1>:d     r6.2<0;1,0>:d                   
(W)     mov (1|M0)               r6.4<1>:d     r18.0<0;1,0>:d                  
(W)     mov (1|M0)               r6.5<1>:d     r16.4<0;1,0>:d                  
(W)     jmpi                                 L17856                                
L18264:
        join (8|M0)                          L23456                                
L18280:
(W)     mov (1|M0)               r6.2<1>:f     8.68805e-44:f                               {I@5}
(~f1.0) sel (8|M0)               r41.0<1>:d    r69.0<1;1,0>:d    -128:w              
        subb (8|M0)              r31.0<1>:ud   r6.2<0;1,0>:ud    r93.0<1;1,0>:ud  {AccWrEn,Compacted,F@1}
(W)     mov (1|M0)               r16.0<1>:hf   0.0:hf                             
        add3 (8|M0)              r45.0<1>:d    r41.0<1;0>:d      r31.0<1;0>:d      -46:w               {I@1}
        add (8|M0)               r46.0<1>:d    r41.0<1;1,0>:d    r31.0<1;1,0>:d   {Compacted}
        cmp (8|M0)    (gt)f1.1   null<1>:d     r45.0<1;1,0>:d    127:w               {I@2}
        add3 (8|M0)              r68.0<1>:ud   -acc0.0<1;0>:ud   r16.0<0;0>:uw     -r100.0<1>:ud    {F@1}
(f1.1)  goto (8|M0)                          L23408                  L23408                
L18408:
        cmp (8|M0)    (gt)f1.0   null<1>:d     r45.0<1;1,0>:d    -127:w              
(f1.0)  goto (8|M0)                          L20992                  L20992                
L18440:
        cmp (8|M0)    (lt)f0.1   null<1>:ud    r45.0<1;1,0>:ud   0xFFFFFF6B:ud             
(f0.1)  goto (8|M0)                          L20472                  L20472                
L18472:
(W)     mov (1|M0)               r6.2<1>:f     8.82818e-44:f                              
        add3 (8|M0)              r63.0<1>:d    r41.0<1;0>:d      r31.0<1;0>:d      104:w              
        subb (8|M0)              r84.0<1>:ud   r6.2<0;1,0>:ud    r93.0<1;1,0>:ud  {AccWrEn,Compacted,F@1}
(W)     mov (1|M0)               r16.0<1>:hf   0.0:hf                              {I@7}
        cmp (8|M0)    (gt)f1.0   null<1>:ud    r84.0<1;1,0>:ud   r63.0<1;1,0>:ud  {I@1}
        add3 (8|M0)              r108.0<1>:ud  -acc0.0<1;0>:ud   r16.0<0;0>:uw     -r100.0<1>:ud    {F@1}
(f1.0)  cmp (8|M0)    (eq)f1.0   null<1>:d     r108.0<1;1,0>:d   0:w               {I@1}
(~f1.0) cmp (8|M0)    (gt)f1.0   null<1>:ud    r108.0<1;1,0>:ud  0x0:uw             
(f1.0)  goto (8|M0)                          L18672                  L18672                
L18608:
        add3 (8|M0)              acc0.0<1>:d   r46.0<1;0>:d      -r84.0<1;0>:d     104:w              
        mov (8|M0)               r118.0<1>:d   0:w                              
        shl (8|M0)               r119.0<1>:d   r27.0<1;1,0>:d    acc0.0<1;1,0>:d 
        goto (8|M0)                          L18672                  L20408                
L18672:
        join (8|M0)                          L20408                                
L18688:
        add3 (8|M0)              r51.0<1>:d    r84.0<1;0>:d      -r46.0<1;0>:d     -104:w              
        cmp (8|M0)    (lt)f1.1   null<1>:d     r51.0<1;1,0>:d    2:w               {I@1}
(f1.1)  goto (8|M0)                          L18840                  L18840                
L18736:
        cmp (8|M0)    (eq)f1.0   null<1>:d     r51.0<1;1,0>:d    2:w              
(~f1.0) goto (8|M0)                          L18840                  L18888                
L18768:
        shr (8|M0)               r99.0<1>:ud   r27.0<1;1,0>:ud   1:w              
        mov (8|M0)               r60.0<1>:d    0:w                              
        mov (8|M0)               r70.0<1>:d    0:w                              
        mov (8|M0)               r53.0<1>:f    r99.0<1;1,0>:f                   {Compacted,I@3}
        goto (8|M0)                          L18840                  L19840                
L18840:
        join (8|M0)                          L18888                                
L18856:
        cmp (8|M0)    (eq)f0.1   null<1>:d     r51.0<1;1,0>:d    1:w              
(f0.1)  goto (8|M0)                          L18888                  L19784                
L18888:
        join (8|M0)                          L19784                                
L18904:
        add3 (8|M0)              acc0.0<1>:d   r84.0<1;0>:d      -r63.0<1;0>:d     -1:w              
        and (8|M0)    (ne)f1.1   r112.0<1>:d   acc0.0<1;1,0>:d   63:w              
(f1.1)  goto (8|M0)                          L18984                  L18984                
L18952:
        mov (8|M0)               r50.0<1>:d    r27.0<1;1,0>:d                  
        goto (8|M0)                          L18984                  L19120                
L18984:
        join (8|M0)                          L19120                                
L19000:
        cmp (8|M0)    (lt)f1.0   null<1>:ud    r112.0<1;1,0>:ud  0x20:uw              {I@5}
(f1.0)  add (8|M0)               acc0.0<1>:d   -r112.0<1;1,0>:d  32:w              
(~f1.0) add (8|M0)               acc2.0<1>:d   r112.0<1;1,0>:d   -32:w              
(f1.0)  shr (8|M0)               r23.0<1>:ud   r27.0<1;1,0>:ud   r112.0<1;1,0>:d 
(f1.0)  shl (8|M0)               r104.0<1>:d   r30.0<1;1,0>:d    acc0.0<1;1,0>:d 
(~f1.0) shr (8|M0)               r99.0<1>:ud   r30.0<1;1,0>:ud   acc2.0<1;1,0>:d  {F@1}
(f1.0)  or (8|M0)                r99.0<1>:d    r23.0<1;1,0>:d    r104.0<1;1,0>:d  {I@2}
        mov (8|M0)               r50.0<1>:f    r99.0<1;1,0>:f                   {Compacted,I@1}
L19120:
        join (8|M0)                          L19784                                
L19136:
        add3 (8|M0)              r33.0<1>:d    r84.0<1;0>:d      -r63.0<1;0>:d     -2:w              
        and (8|M0)    (ne)f0.1   r111.0<1>:d   r33.0<1;1,0>:d    63:w               {I@1}
(f0.1)  goto (8|M0)                          L19216                  L19216                
L19184:
        mov (8|M0)               r99.0<1>:d    r27.0<1;1,0>:d                   {F@1}
        goto (8|M0)                          L19216                  L19344                
L19216:
        join (8|M0)                          L19344                                
L19232:
        cmp (8|M0)    (lt)f1.1   null<1>:ud    r111.0<1;1,0>:ud  0x20:uw              {I@5}
(f1.1)  add (8|M0)               acc0.0<1>:d   -r111.0<1;1,0>:d  32:w              
(~f1.1) add (8|M0)               acc2.0<1>:d   r111.0<1;1,0>:d   -32:w              
(f1.1)  shr (8|M0)               r21.0<1>:ud   r27.0<1;1,0>:ud   r111.0<1;1,0>:d 
(f1.1)  shl (8|M0)               r103.0<1>:d   r30.0<1;1,0>:d    acc0.0<1;1,0>:d 
(~f1.1) shr (8|M0)               r99.0<1>:ud   r30.0<1;1,0>:ud   acc2.0<1;1,0>:d 
(f1.1)  or (8|M0)                r99.0<1>:d    r21.0<1;1,0>:d    r103.0<1;1,0>:d  {I@2}
L19344:
        join (8|M0)                          L19784                                
L19360:
        and (8|M0)    (ne)f1.0   r102.0<1>:d   r33.0<1;1,0>:d    63:w              
        and (8|M0)               r70.0<1>:d    r99.0<1;1,0>:d    1:w               {Compacted,I@3}
(f1.0)  goto (8|M0)                          L19448                  L19448                
L19400:
        mov (8|M0)               r122.0<1>:d   -1:w                              
        mov (8|M0)               r21.0<1>:d    -1:w                              
        goto (8|M0)                          L19448                  L19632                
L19448:
        join (8|M0)                          L19632                                
L19464:
        cmp (8|M0)    (lt)f0.1   null<1>:ud    r102.0<1;1,0>:ud  0x20:uw              {I@7}
(f0.1)  goto (8|M0)                          L19568                  L19568                
L19496:
        add (8|M0)               acc0.0<1>:d   r102.0<1;1,0>:d   -32:w               {Compacted}
(W)     mov (1|M0)               r6.4<1>:hf    -qnan(0x1FF):hf                             
        mov (8|M0)               r122.0<1>:d   0:w                              
        shl (8|M0)               r21.0<1>:d    r6.4<0;1,0>:w     acc0.0<1;1,0>:d  {F@1}
        goto (8|M0)                          L19568                  L19632                
L19568:
        join (8|M0)                          L19632                                
L19584:
(W)     mov (1|M0)               r6.4<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (8|M0)               r21.0<1>:d    -1:w                              
        shl (8|M0)               r122.0<1>:d   r6.4<0;1,0>:w     r102.0<1;1,0>:d  {F@1}
L19632:
        join (8|M0)                          L19784                                
L19648:
        bfn.0x60 (8|M0)          r20.0<1>:ud   r122.0<1;0>:ud    r7.4<0;0>:ud      r27.0<1>:ud      {I@2} // (s0^s1)&s2
        bfn.0x60 (8|M0)          r19.0<1>:ud   r21.0<1;0>:ud     r7.4<0;0>:ud      r30.0<1>:ud      // (s0^s1)&s2
        cmp (8|M0)    (ne)f1.1   null<1>:d     r20.0<1;1,0>:d    0:w               {I@2}
(W)     mov (1|M0)               r6.4<1>:hf    -qnan(0x1FF):hf                             
        mov (8|M0)               r53.0<1>:f    r50.0<1;1,0>:f                   {Compacted}
(~f1.1) cmp (8|M0)    (ne)f1.1   null<1>:d     r19.0<1;1,0>:d    0:w               {I@2}
(f1.1)  sel (8|M0)               acc0.0<1>:d   r6.4<0;1,0>:w     0:w               {F@2}
        mov (8|M0)               r60.0<1>:d    -acc0.0<1;1,0>:d                
        goto (8|M0)                          L19784                  L19840                
L19784:
        join (8|M0)                          L19840                                
L19800:
        mov (8|M0)               r60.0<1>:d    0:w                              
        mov (8|M0)               r70.0<1>:d    0:w                              
        mov (8|M0)               r53.0<1>:f    r27.0<1;1,0>:f                   {Compacted}
L19840:
        join (8|M0)                          L20408                                
L19856:
        and (8|M0)    (ne)f1.1   r110.0<1>:d   r51.0<1;1,0>:d    63:w              
(f1.1)  goto (8|M0)                          L19920                  L19920                
L19888:
        mov (8|M0)               r99.0<1>:d    r27.0<1;1,0>:d                  
        goto (8|M0)                          L19920                  L20048                
L19920:
        join (8|M0)                          L20048                                
L19936:
        cmp (8|M0)    (lt)f1.0   null<1>:ud    r110.0<1;1,0>:ud  0x20:uw              {I@5}
(f1.0)  add (8|M0)               acc0.0<1>:d   -r110.0<1;1,0>:d  32:w              
(~f1.0) add (8|M0)               acc2.0<1>:d   r110.0<1;1,0>:d   -32:w              
(f1.0)  shr (8|M0)               r16.0<1>:ud   r27.0<1;1,0>:ud   r110.0<1;1,0>:d 
(f1.0)  shl (8|M0)               r101.0<1>:d   r30.0<1;1,0>:d    acc0.0<1;1,0>:d 
(~f1.0) shr (8|M0)               r99.0<1>:ud   r30.0<1;1,0>:ud   acc2.0<1;1,0>:d 
(f1.0)  or (8|M0)                r99.0<1>:d    r16.0<1;1,0>:d    r101.0<1;1,0>:d  {I@2}
L20048:
        join (8|M0)                          L20408                                
L20064:
        shl (8|M0)               r71.0<1>:d    r53.0<1;1,0>:d    2:w               {Compacted,F@1}
        shl (8|M0)               r14.0<1>:d    r70.0<1;1,0>:d    1:w               {Compacted}
        and (8|M0)               r71.0<1>:d    r71.0<1;1,0>:d    4:w               {Compacted,I@2}
        bfn.0xFE (8|M0)          r58.0<1>:ud   r71.0<1;0>:ud     r14.0<1;0>:ud     r60.0<1>:ud      {I@1} // s0|s1|s2
        cmp (8|M0)    (eq)f0.1   null<1>:d     r58.0<1;1,0>:d    0:w               {I@1}
(~f0.1) goto (8|M0)                          L20168                  L20168                
L20136:
        mov (8|M0)               r60.0<1>:d    0:w                              
        goto (8|M0)                          L20168                  L20328                
L20168:
        join (8|M0)                          L20328                                
L20184:
        cmp (8|M0)    (gt)f1.1   null<1>:ud    r58.0<1;1,0>:ud   0x4:uw             
(~f1.1) goto (8|M0)                          L20248                  L20248                
L20216:
        mov (8|M0)               r60.0<1>:d    1:w                              
        goto (8|M0)                          L20248                  L20328                
L20248:
        join (8|M0)                          L20328                                
L20264:
        and (8|M0)    (ne)f1.0   null<1>:d     r99.0<1;1,0>:d    1:w              
(W)     mov (1|M0)               r6.4<1>:hf    0x1:hf                             
(f1.0)  cmp (8|M0)    (eq)f1.0   null<1>:d     r58.0<1;1,0>:d    4:w              
(f1.0)  sel (8|M0)               r60.0<1>:d    r6.4<0;1,0>:w     0:w               {F@1}
L20328:
        join (8|M0)                          L20408                                
L20344:
        add (8|M0)               r92.0<1>:d    r60.0<1;1,0>:d    r99.0<1;1,0>:d   {Compacted,I@2}
(W)     mov (1|M0)               r6.2<1>:f     0x800000:f                               {Compacted}
        cmp (8|M0)    (gt)f1.1   null<1>:ud    r92.0<1;1,0>:ud   0x7FFFFF:ud              {I@1}
(~f1.1) sel (8|M0)               r119.0<1>:d   r92.0<1;1,0>:d    0:w              
(f1.1)  sel (8|M0)               r118.0<1>:d   r6.2<0;1,0>:d     0:w               {F@1}
L20408:
        join (8|M0)                          L20472                                
L20424:
        and (8|M0)               r127.0<1>:d   r15.0<1;1,0>:d    -2147483648:d              
        bfn.0xFE (8|M0)          r14.0<1>:ud   r127.0<1;0>:ud    r118.0<1;0>:ud    r119.0<1>:ud     {I@1} // s0|s1|s2
        goto (8|M0)                          L20472                  L23488                
L20472:
        join (8|M0)                          L20992                                
L20488:
        and (8|M0)    (ne)f1.0   r79.0<1>:d    r31.0<1;1,0>:d    63:w              
(f1.0)  goto (8|M0)                          L20568                  L20568                
L20520:
        mov (8|M0)               r89.0<1>:d    -1:w                              
        mov (8|M0)               r100.0<1>:d   -1:w                              
        goto (8|M0)                          L20568                  L20752                
L20568:
        join (8|M0)                          L20752                                
L20584:
        cmp (8|M0)    (lt)f0.1   null<1>:ud    r79.0<1;1,0>:ud   0x20:uw              {I@6}
(f0.1)  goto (8|M0)                          L20688                  L20688                
L20616:
        add (8|M0)               acc0.0<1>:d   r79.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r6.4<1>:hf    -qnan(0x1FF):hf                             
        mov (8|M0)               r89.0<1>:d    0:w                              
        shl (8|M0)               r100.0<1>:d   r6.4<0;1,0>:w     acc0.0<1;1,0>:d  {F@1}
        goto (8|M0)                          L20688                  L20752                
L20688:
        join (8|M0)                          L20752                                
L20704:
(W)     mov (1|M0)               r6.4<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (8|M0)               r100.0<1>:d   -1:w                              
        shl (8|M0)               r89.0<1>:d    r6.4<0;1,0>:w     r79.0<1;1,0>:d   {F@1}
L20752:
        join (8|M0)                          L20992                                
L20768:
        bfn.0x60 (8|M0)          r126.0<1>:ud  r89.0<1;0>:ud     r7.4<0;0>:ud      r27.0<1>:ud      {I@2} // (s0^s1)&s2
        bfn.0x60 (8|M0)          r125.0<1>:ud  r100.0<1;0>:ud    r7.4<0;0>:ud      r30.0<1>:ud      // (s0^s1)&s2
        cmp (8|M0)    (ne)f0.1   null<1>:d     r126.0<1;1,0>:d   0:w               {I@2}
        cmp (8|M0)    (gt)f1.1   null<1>:d     r15.0<1;1,0>:d    -1:w              
(~f0.1) cmp (8|M0)    (ne)f0.1   null<1>:d     r125.0<1;1,0>:d   0:w               {I@3}
(f0.1)  cmp (8|M0)    (eq)f0.1   null<1>:d     r45.0<1;1,0>:d    -150:w              
(f1.1)  goto (8|M0)                          L20928                  L20928                
L20880:
(W)     mov (1|M0)               r6.2<1>:ud    0x80000001:ud                             
(f0.1)  sel (8|M0)               r14.0<1>:f    r6.2<0;1,0>:f     -0.0:f               {I@1}
        goto (8|M0)                          L20928                  L23488                
L20928:
        join (8|M0)                          L20992                                
L20944:
(W)     mov (1|M0)               r6.2<1>:ud    0x1:ud                              {F@1}
(f0.1)  sel (8|M0)               r14.0<1>:f    r6.2<0;1,0>:f     0.0:f               {I@1}
        goto (8|M0)                          L20992                  L23488                
L20992:
        join (8|M0)                          L23408                                
L21008:
        cmp (8|M0)    (lt)f0.1   null<1>:ud    r31.0<1;1,0>:ud   0x18:uw              {F@1}
        add3 (8|M0)              r71.0<1>:d    r41.0<1;0>:d      r31.0<1;0>:d      81:w              
(f0.1)  cmp (8|M0)    (eq)f0.1   null<1>:d     r68.0<1;1,0>:d    0:w              
(f0.1)  goto (8|M0)                          L23088                  L23088                
L21072:
        shl (8|M0)               r35.0<1>:d    r24.0<1;1,0>:d    1:w               {Compacted}
        shr (8|M0)               r34.0<1>:ud   r24.0<1;1,0>:ud   31:w              
        shl (8|M0)               r18.0<1>:d    r66.0<1;1,0>:d    1:w               {Compacted}
        cmp (8|M0)    (lt)f0.1   null<1>:ud    r35.0<1;1,0>:ud   0x4E:uw              {I@3}
        or (8|M0)                r18.0<1>:d    r18.0<1;1,0>:d    r34.0<1;1,0>:d   {Compacted,I@2}
(f0.1)  cmp (8|M0)    (eq)f0.1   null<1>:d     r18.0<1;1,0>:d    0:w               {I@1}
(~f0.1) cmp (8|M0)    (lt)f0.1   null<1>:d     r18.0<1;1,0>:d    0:w              
(f0.1)  goto (8|M0)                          L21304                  L21304                
L21176:
        cmp (8|M0)    (eq)f1.1   null<1>:d     r24.0<1;1,0>:d    39:w              
(f1.1)  cmp (8|M0)    (eq)f1.1   null<1>:d     r66.0<1;1,0>:d    0:w              
(~f1.1) goto (8|M0)                          L21304                  L21368                
L21224:
        shr (8|M0)               r99.0<1>:ud   r27.0<1;1,0>:ud   1:w              
        mov (8|M0)               r67.0<1>:d    0:w                              
        mov (8|M0)               r80.0<1>:d    0:w                              
        mov (8|M0)               r38.0<1>:f    r99.0<1;1,0>:f                   {Compacted,I@3}
        mov (8|M0)               r99.0<1>:f    r27.0<1;1,0>:f                   {Compacted}
        goto (8|M0)                          L21304                  L22568                
L21304:
        join (8|M0)                          L21368                                
L21320:
        cmp (8|M0)    (eq)f1.0   null<1>:d     r24.0<1;1,0>:d    38:w              
(f1.0)  cmp (8|M0)    (eq)f1.0   null<1>:d     r66.0<1;1,0>:d    0:w              
(f1.0)  goto (8|M0)                          L21368                  L22480                
L21368:
        join (8|M0)                          L22480                                
L21384:
        add (8|M0)               acc0.0<1>:d   -r24.0<1;1,0>:d   39:w               {Compacted}
        add (8|M0)               r73.0<1>:d    -r24.0<1;1,0>:d   40:w               {Compacted}
        and (8|M0)    (ne)f1.0   r126.0<1>:d   acc0.0<1;1,0>:d   63:w              
(f1.0)  goto (8|M0)                          L21464                  L21464                
L21432:
        mov (8|M0)               r55.0<1>:d    r27.0<1;1,0>:d                  
        goto (8|M0)                          L21464                  L21600                
L21464:
        join (8|M0)                          L21600                                
L21480:
        cmp (8|M0)    (lt)f0.1   null<1>:ud    r126.0<1;1,0>:ud  0x20:uw              {I@5}
(f0.1)  add (8|M0)               acc0.0<1>:d   -r126.0<1;1,0>:d  32:w              
(~f0.1) add (8|M0)               acc2.0<1>:d   r126.0<1;1,0>:d   -32:w              
(f0.1)  shr (8|M0)               r122.0<1>:ud  r27.0<1;1,0>:ud   r126.0<1;1,0>:d 
(f0.1)  shl (8|M0)               r20.0<1>:d    r30.0<1;1,0>:d    acc0.0<1;1,0>:d 
(~f0.1) shr (8|M0)               r99.0<1>:ud   r30.0<1;1,0>:ud   acc2.0<1;1,0>:d  {F@1}
(f0.1)  or (8|M0)                r99.0<1>:d    r122.0<1;1,0>:d   r20.0<1;1,0>:d   {I@2}
        mov (8|M0)               r55.0<1>:f    r99.0<1;1,0>:f                   {Compacted,I@1}
L21600:
        join (8|M0)                          L22480                                
L21616:
        add (8|M0)               r42.0<1>:d    -r24.0<1;1,0>:d   38:w               {Compacted}
        and (8|M0)    (ne)f1.1   r17.0<1>:d    r42.0<1;1,0>:d    63:w               {I@1}
(f1.1)  goto (8|M0)                          L21688                  L21688                
L21656:
        mov (8|M0)               r99.0<1>:d    r27.0<1;1,0>:d                   {F@1}
        goto (8|M0)                          L21688                  L21816                
L21688:
        join (8|M0)                          L21816                                
L21704:
        cmp (8|M0)    (lt)f1.0   null<1>:ud    r17.0<1;1,0>:ud   0x20:uw              {I@5}
(f1.0)  add (8|M0)               acc0.0<1>:d   -r17.0<1;1,0>:d   32:w              
(~f1.0) add (8|M0)               acc2.0<1>:d   r17.0<1;1,0>:d    -32:w              
(f1.0)  shr (8|M0)               r120.0<1>:ud  r27.0<1;1,0>:ud   r17.0<1;1,0>:d  
(f1.0)  shl (8|M0)               r34.0<1>:d    r30.0<1;1,0>:d    acc0.0<1;1,0>:d 
(~f1.0) shr (8|M0)               r99.0<1>:ud   r30.0<1;1,0>:ud   acc2.0<1;1,0>:d 
(f1.0)  or (8|M0)                r99.0<1>:d    r120.0<1;1,0>:d   r34.0<1;1,0>:d   {I@2}
L21816:
        join (8|M0)                          L22480                                
L21832:
        and (8|M0)    (ne)f0.1   r33.0<1>:d    r42.0<1;1,0>:d    63:w              
        and (8|M0)               r80.0<1>:d    r99.0<1;1,0>:d    1:w               {Compacted,I@3}
(f0.1)  goto (8|M0)                          L21920                  L21920                
L21872:
        mov (8|M0)               r42.0<1>:d    -1:w                              
        mov (8|M0)               r47.0<1>:d    -1:w                              
        goto (8|M0)                          L21920                  L22104                
L21920:
        join (8|M0)                          L22104                                
L21936:
        cmp (8|M0)    (lt)f1.1   null<1>:ud    r33.0<1;1,0>:ud   0x20:uw              {I@7}
(f1.1)  goto (8|M0)                          L22040                  L22040                
L21968:
        add (8|M0)               acc0.0<1>:d   r33.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r6.4<1>:hf    -qnan(0x1FF):hf                             
        mov (8|M0)               r42.0<1>:d    0:w                              
        shl (8|M0)               r47.0<1>:d    r6.4<0;1,0>:w     acc0.0<1;1,0>:d  {F@1}
        goto (8|M0)                          L22040                  L22104                
L22040:
        join (8|M0)                          L22104                                
L22056:
(W)     mov (1|M0)               r6.4<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (8|M0)               r47.0<1>:d    -1:w                              
        shl (8|M0)               r42.0<1>:d    r6.4<0;1,0>:w     r33.0<1;1,0>:d   {F@1}
L22104:
        join (8|M0)                          L22480                                
L22120:
        bfn.0x60 (8|M0)          r119.0<1>:ud  r42.0<1;0>:ud     r7.4<0;0>:ud      r27.0<1>:ud      {I@2} // (s0^s1)&s2
        bfn.0x60 (8|M0)          r118.0<1>:ud  r47.0<1;0>:ud     r7.4<0;0>:ud      r30.0<1>:ud      // (s0^s1)&s2
        cmp (8|M0)    (ne)f0.1   null<1>:d     r119.0<1;1,0>:d   0:w               {I@2}
(W)     mov (1|M0)               r6.4<1>:hf    -qnan(0x1FF):hf                             
        and (8|M0)    (ne)f1.0   r16.0<1>:d    r73.0<1;1,0>:d    63:w              
(~f0.1) cmp (8|M0)    (ne)f0.1   null<1>:d     r118.0<1;1,0>:d   0:w               {I@3}
(f0.1)  sel (8|M0)               acc0.0<1>:d   r6.4<0;1,0>:w     0:w               {F@1}
        mov (8|M0)               r67.0<1>:d    -acc0.0<1;1,0>:d                
(f1.0)  goto (8|M0)                          L22296                  L22296                
L22264:
        mov (8|M0)               r99.0<1>:d    r27.0<1;1,0>:d                  
        goto (8|M0)                          L22296                  L22424                
L22296:
        join (8|M0)                          L22424                                
L22312:
        cmp (8|M0)    (lt)f0.1   null<1>:ud    r16.0<1;1,0>:ud   0x20:uw              {I@7}
(f0.1)  add (8|M0)               acc0.0<1>:d   -r16.0<1;1,0>:d   32:w              
(~f0.1) add (8|M0)               acc2.0<1>:d   r16.0<1;1,0>:d    -32:w              
(f0.1)  shr (8|M0)               r115.0<1>:ud  r27.0<1;1,0>:ud   r16.0<1;1,0>:d  
(f0.1)  shl (8|M0)               r32.0<1>:d    r30.0<1;1,0>:d    acc0.0<1;1,0>:d 
(~f0.1) shr (8|M0)               r99.0<1>:ud   r30.0<1;1,0>:ud   acc2.0<1;1,0>:d 
(f0.1)  or (8|M0)                r99.0<1>:d    r115.0<1;1,0>:d   r32.0<1;1,0>:d   {I@2}
L22424:
        join (8|M0)                          L22480                                
L22440:
        mov (8|M0)               r38.0<1>:f    r99.0<1;1,0>:f                   {Compacted,I@2}
        mov (8|M0)               r99.0<1>:d    r55.0<1;1,0>:d                   {F@1}
        goto (8|M0)                          L22480                  L22568                
L22480:
        join (8|M0)                          L22568                                
L22496:
        shr (8|M0)               r99.0<1>:ud   r27.0<1;1,0>:ud   2:w              
        mov (8|M0)               r67.0<1>:d    0:w                              
        mov (8|M0)               r80.0<1>:d    0:w                              
        mov (8|M0)               r38.0<1>:f    r99.0<1;1,0>:f                   {Compacted,I@3}
        shr (8|M0)               r99.0<1>:ud   r27.0<1;1,0>:ud   1:w               {F@1}
L22568:
        join (8|M0)                          L23088                                
L22584:
        shl (8|M0)               r121.0<1>:d   r99.0<1;1,0>:d    2:w               {Compacted,I@2}
        shl (8|M0)               r114.0<1>:d   r80.0<1;1,0>:d    1:w               {Compacted}
        and (8|M0)               r121.0<1>:d   r121.0<1;1,0>:d   4:w               {Compacted,I@2}
        and (8|M0)               r57.0<1>:d    r38.0<1;1,0>:d    8388607:d              
        bfn.0xFE (8|M0)          r78.0<1>:ud   r121.0<1;0>:ud    r114.0<1;0>:ud    r67.0<1>:ud      {I@2} // s0|s1|s2
        cmp (8|M0)    (eq)f1.1   null<1>:d     r78.0<1;1,0>:d    0:w               {I@1}
(~f1.1) goto (8|M0)                          L22704                  L22704                
L22672:
        mov (8|M0)               r77.0<1>:d    0:w                              
        goto (8|M0)                          L22704                  L22864                
L22704:
        join (8|M0)                          L22864                                
L22720:
        cmp (8|M0)    (gt)f1.0   null<1>:ud    r78.0<1;1,0>:ud   0x4:uw             
(~f1.0) goto (8|M0)                          L22784                  L22784                
L22752:
        mov (8|M0)               r77.0<1>:d    1:w                              
        goto (8|M0)                          L22784                  L22864                
L22784:
        join (8|M0)                          L22864                                
L22800:
        and (8|M0)    (ne)f1.1   null<1>:d     r38.0<1;1,0>:d    1:w              
(W)     mov (1|M0)               r6.4<1>:hf    0x1:hf                             
(f1.1)  cmp (8|M0)    (eq)f1.1   null<1>:d     r78.0<1;1,0>:d    4:w              
(f1.1)  sel (8|M0)               r77.0<1>:d    r6.4<0;1,0>:w     0:w               {F@1}
L22864:
        join (8|M0)                          L23088                                
L22880:
        add (8|M0)               r107.0<1>:d   r57.0<1;1,0>:d    r77.0<1;1,0>:d   {Compacted,I@2}
        add3 (8|M0)              r81.0<1>:d    r41.0<1;0>:d      r31.0<1;0>:d      82:w              
        cmp (8|M0)    (gt)f1.0   null<1>:ud    r107.0<1;1,0>:ud  0x7FFFFF:ud              {I@2}
(f1.0)  sel (8|M0)               r96.0<1>:d    r81.0<1;1,0>:d    r71.0<1;1,0>:d   {I@2}
        cmp (8|M0)    (eq)f0.1   null<1>:d     r96.0<1;1,0>:d    255:w               {I@1}
(f0.1)  goto (8|M0)                          L23040                  L23040                
L22968:
(~f1.0) sel (8|M0)               r93.0<1>:d    r107.0<1;1,0>:d   0:w              
        and (8|M0)               r80.0<1>:d    r15.0<1;1,0>:d    -2147483648:d              
        shl (8|M0)               r113.0<1>:d   r96.0<1;1,0>:d    23:w               {Compacted}
        bfn.0xFE (8|M0)          r14.0<1>:ud   r80.0<1;0>:ud     r113.0<1;0>:ud    r93.0<1>:ud      {I@1} // s0|s1|s2
        goto (8|M0)                          L23040                  L23488                
L23040:
        join (8|M0)                          L23088                                
L23056:
        bfn.0xEA (8|M0)          r14.0<1>:ud   r7.5<0;0>:ud      r15.0<1;0>:ud     r7.6<0>:ud       // s0|s1&s2
        goto (8|M0)                          L23088                  L23488                
L23088:
        join (8|M0)                          L23408                                
L23104:
        and (8|M0)    (ne)f1.1   r101.0<1>:d   r31.0<1;1,0>:d    63:w              
(f1.1)  goto (8|M0)                          L23168                  L23168                
L23136:
        mov (8|M0)               r70.0<1>:d    -1:w                              
        goto (8|M0)                          L23168                  L23296                
L23168:
        join (8|M0)                          L23296                                
L23184:
        cmp (8|M0)    (lt)f1.0   null<1>:ud    r101.0<1;1,0>:ud  0x20:uw              {I@5}
(f1.0)  goto (8|M0)                          L23248                  L23248                
L23216:
        mov (8|M0)               r70.0<1>:d    0:w                              
        goto (8|M0)                          L23248                  L23296                
L23248:
        join (8|M0)                          L23296                                
L23264:
(W)     mov (1|M0)               r6.4<1>:hf    -qnan(0x1FF):hf                             
        shl (8|M0)               r70.0<1>:d    r6.4<0;1,0>:w     r101.0<1;1,0>:d  {F@1}
L23296:
        join (8|M0)                          L23408                                
L23312:
        bfn.0x60 (8|M0)          r76.0<1>:ud   r70.0<1;0>:ud     r7.4<0;0>:ud      r27.0<1>:ud      {I@2} // (s0^s1)&s2
        add (8|M0)               acc0.0<1>:d   -r31.0<1;1,0>:d   23:w               {Compacted}
        and (8|M0)               r79.0<1>:d    r15.0<1;1,0>:d    -2147483648:d              
        shl (8|M0)               r111.0<1>:d   r71.0<1;1,0>:d    23:w               {Compacted}
        shl (8|M0)               r76.0<1>:d    r76.0<1;1,0>:d    acc0.0<1;1,0>:d  {I@4}
        bfn.0xFE (8|M0)          r14.0<1>:ud   r79.0<1;0>:ud     r111.0<1;0>:ud    r76.0<1>:ud      {I@1} // s0|s1|s2
        goto (8|M0)                          L23408                  L23488                
L23408:
        join (8|M0)                          L23456                                
L23424:
        bfn.0xEA (8|M0)          r14.0<1>:ud   r7.5<0;0>:ud      r15.0<1;0>:ud     r7.6<0>:ud       // s0|s1&s2
        goto (8|M0)                          L23456                  L23488                
L23456:
        join (8|M0)                          L23488                                
L23472:
        bfn.0xF8 (8|M0)          r14.0<1>:ud   r15.0<1;0>:ud     r7.6<0;0>:ud      r7.5<0>:ud       // s0&s1|s2
L23488:
        join (8|M0)                          L36464                                
L23504:
        and (8|M0)               r110.0<1>:d   r14.0<1;1,0>:d    2147483647:d               {I@2}
        sel (8|M0)    (lt)f0.0   r88.0<1>:f    r110.0<1;1,0>:f   448.0:f               {Compacted,I@1}
        shr (8|M0)               r32.0<1>:ud   r88.0<1;1,0>:ud   23:w               {F@1}
        and (8|M0)    (ne)f1.0   r41.0<1>:d    r88.0<1;1,0>:d    8388607:d              
        and (8|M0)               r44.0<1>:d    r32.0<1;1,0>:d    255:w               {Compacted,I@2}
        sel (8|M0)    (ge)f0.0   r109.0<1>:ud  r44.0<1;1,0>:ud   0x79:uw              {I@1}
(f1.0)  cmp (8|M0)    (eq)f1.0   null<1>:d     r44.0<1;1,0>:d    255:w              
        shl (8|M0)               r22.0<1>:d    r109.0<1;1,0>:d   23:w               {Compacted,I@2}
(~f1.0) goto (8|M0)                          L23648                  L23648                
L23624:
        mov (8|M0)               r116.0<1>:f   qnan(0x0):f                               {Compacted}
        goto (8|M0)                          L23648                  L29864                
L23648:
        join (8|M0)                          L29864                                
L23664:
        cmp (8|M0)    (eq)f0.1   null<1>:d     r41.0<1;1,0>:d    0:w              
        add (8|M0)               r115.0<1>:d   -r22.0<1;1,0>:d   -2139095040:d               {I@5}
        xor (8|M0)               r24.0<1>:d    r115.0<1;1,0>:d   r88.0<1;1,0>:d   {Compacted,I@1}
(f0.1)  cmp (8|M0)    (eq)f0.1   null<1>:d     r44.0<1;1,0>:d    255:w              
(f0.1)  goto (8|M0)                          L29832                  L29832                
L23736:
        or (8|M0)     (eq)f0.1   null<1>:d     r44.0<1;1,0>:d    r41.0<1;1,0>:d  
(~f0.1) goto (8|M0)                          L23792                  L23792                
L23768:
        mov (8|M0)               r116.0<1>:f   0.0:f                               {Compacted}
        goto (8|M0)                          L23792                  L29864                
L23792:
        join (8|M0)                          L29832                                
L23808:
        cmp (8|M0)    (eq)f0.1   null<1>:d     r44.0<1;1,0>:d    0:w              
        shr (8|M0)               r88.0<1>:ud   r115.0<1;1,0>:ud  23:w              
        add (8|M0)               r55.0<1>:d    r44.0<1;1,0>:d    -127:w               {Compacted}
(f0.1)  mov (8|M0)               r55.0<1>:d    -126:w                              
        add (8|M0)               r50.0<1>:d    r88.0<1;1,0>:d    r55.0<1;1,0>:d   {Compacted,I@1}
        cmp (8|M0)    (gt)f1.1   null<1>:d     r50.0<1;1,0>:d    254:w               {I@1}
(f1.1)  goto (8|M0)                          L29760                  L29760                
L23904:
        or (8|M0)     (eq)f1.0   null<4>:b     r32.0<1;1,0>:d    r88.0<1;1,0>:d  
(f1.0)  goto (8|M0)                          L29688                  L29688                
L23936:
(W)     mov (1|M0)               r6.4<1>:hf    0.0:hf                             
(W)     mov (1|M0)               r6.6<1>:d     0:w                              
(f0.1)  sel (8|M0)               acc0.0<1>:d   r6.4<0;1,0>:w     8388608:d               {F@1}
(W)     mov (1|M0)               r6.3<1>:f     -0.0:f                               {Compacted}
        or (8|M0)                r118.0<1>:d   acc0.0<1;1,0>:d   r41.0<1;1,0>:d  
(W)     mov (2|M0)               r6.4<1>:d     0:w                              
        shl (8|M0)               r26.0<1>:d    r118.0<1;1,0>:d   23:w               {Compacted,I@2}
        shr (8|M0)               r29.0<1>:ud   r118.0<1;1,0>:ud  9:w              
L24048:
(W)     shl (1|M0)               r15.1<1>:d    r6.3<0;1,0>:d     31:w               {F@1}
(W)     shr (1|M0)               r6.7<1>:ud    r6.6<0;1,0>:ud    1:w              
(W)     cmp (8|M0)    (gt)f1.1   null<1>:ud    r6.4<0;1,0>:ud    0x3E:uw              {I@5}
(W)     or (1|M0)                r6.6<1>:d     r6.7<0;1,0>:d     r15.1<0;1,0>:d   {I@2}
        bfn.0xE0 (8|M0)          r35.0<1>:ud   r6.7<0;0>:ud      r15.1<0;0>:ud     r26.0<1>:ud      // (s0|s1)&s2
(W)     shr (1|M0)               r6.2<1>:ud    r6.3<0;1,0>:ud    1:w              
(W&f1.1) cmp (8|M0)   (eq)f1.1   null<1>:d     r6.5<0;1,0>:d     0:w              
        cmp (8|M0)    (eq)f0.1   null<1>:d     r35.0<1;1,0>:d    r6.6<0;1,0>:d    {I@3}
        and (8|M0)               r34.0<1>:d    r6.2<0;1,0>:d     r29.0<1;1,0>:d   {Compacted,I@3}
(W)     addc (1|M0)              r17.0<1>:ud   r6.4<0;1,0>:ud    0x1:ud              {AccWrEn}
(W&~f1.1) cmp (8|M0)  (gt)f1.1   null<1>:ud    r6.5<0;1,0>:ud    0x0:uw             
(f0.1)  cmp (8|M0)    (eq)f0.1   null<1>:d     r34.0<1;1,0>:d    r6.2<0;1,0>:d    {I@3}
(W)     mov (1|M0)               r6.14<1>:hf   0x1:hf                             
(W)     mov (1|M0)               r15.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
(f1.1)  sel (8|M0)               r16.0<1>:uw   r6.14<0;1,0>:uw   0x0:uw              {F@1}
(W)     add (1|M0)               r15.4<1>:ud   r15.0<0;1,0>:ud   r6.5<0;1,0>:ud   {I@2}
(f0.1)  sel (8|M0)               r15.0<1>:uw   r6.14<0;1,0>:uw   0x0:uw             
        mov (8|M0)               r101.0<1>:d   r6.4<0;1,0>:d                   
        or (8|M0)     (ne)f1.1   null<1>:uw    r16.0<1;1,0>:uw   r15.0<1;1,0>:uw  {I@2}
        mov (8|M0)               r104.0<1>:d   r6.5<0;1,0>:d                   
        mov (8|M0)               r27.0<1>:f    r17.0<0;1,0>:f                   {Compacted}
        mov (8|M0)               r77.0<1>:d    r15.4<0;1,0>:d                  
(f1.1)  goto (8|M0)                          L24456                  L24456                
L24392:
(W)     mov (1|M0)               r6.3<1>:d     r6.2<0;1,0>:d                   
(W)     mov (1|M0)               r6.4<1>:d     r17.0<0;1,0>:d                  
(W)     mov (1|M0)               r6.5<1>:d     r15.4<0;1,0>:d                  
(W)     jmpi                                 L24048                                
L24456:
        join (8|M0)                          L29688                                
L24472:
(W)     mov (1|M0)               r6.2<1>:f     8.68805e-44:f                               {I@5}
(W)     mov (1|M0)               r15.0<1>:hf   0.0:hf                             
        subb (8|M0)              r37.0<1>:ud   r6.2<0;1,0>:ud    r101.0<1;1,0>:ud {AccWrEn,Compacted,F@2}
        add3 (8|M0)              r48.0<1>:d    r50.0<1;0>:d      r37.0<1;0>:d      -173:w               {I@1}
        add3 (8|M0)              r72.0<1>:ud   -acc0.0<1;0>:ud   r15.0<0;0>:uw     -r104.0<1>:ud    {F@1}
        cmp (8|M0)    (gt)f0.1   null<1>:d     r48.0<1;1,0>:d    127:w               {I@2}
        add3 (8|M0)              r49.0<1>:d    r88.0<1;0>:d      r55.0<1;0>:d      r37.0<1>:d      
(f0.1)  goto (8|M0)                          L29616                  L29616                
L24592:
        cmp (8|M0)    (gt)f1.1   null<1>:d     r48.0<1;1,0>:d    -127:w              
(f1.1)  goto (8|M0)                          L27176                  L27176                
L24624:
        cmp (8|M0)    (lt)f1.0   null<1>:ud    r48.0<1;1,0>:ud   0xFFFFFF6B:ud             
(f1.0)  goto (8|M0)                          L26656                  L26656                
L24656:
(W)     mov (1|M0)               r6.2<1>:f     8.82818e-44:f                              
        add3 (8|M0)              r66.0<1>:d    r50.0<1;0>:d      r37.0<1;0>:d      -23:w              
        subb (8|M0)              r86.0<1>:ud   r6.2<0;1,0>:ud    r101.0<1;1,0>:ud {AccWrEn,Compacted,F@1}
(W)     mov (1|M0)               r15.0<1>:hf   0.0:hf                              {I@7}
        cmp (8|M0)    (gt)f1.1   null<1>:ud    r86.0<1;1,0>:ud   r66.0<1;1,0>:ud  {I@1}
        add3 (8|M0)              r117.0<1>:ud  -acc0.0<1;0>:ud   r15.0<0;0>:uw     -r104.0<1>:ud    {F@1}
(f1.1)  cmp (8|M0)    (eq)f1.1   null<1>:d     r117.0<1;1,0>:d   0:w               {I@1}
(~f1.1) cmp (8|M0)    (gt)f1.1   null<1>:ud    r117.0<1;1,0>:ud  0x0:uw             
(f1.1)  goto (8|M0)                          L24856                  L24856                
L24792:
        add3 (8|M0)              acc0.0<1>:d   r49.0<1;0>:d      -r86.0<1;0>:d     -23:w              
        mov (8|M0)               r25.0<1>:d    0:w                              
        shl (8|M0)               r26.0<1>:d    r26.0<1;1,0>:d    acc0.0<1;1,0>:d 
        goto (8|M0)                          L24856                  L26592                
L24856:
        join (8|M0)                          L26592                                
L24872:
        add3 (8|M0)              r53.0<1>:d    r86.0<1;0>:d      -r49.0<1;0>:d     23:w              
        cmp (8|M0)    (lt)f0.1   null<1>:d     r53.0<1;1,0>:d    2:w               {I@1}
(f0.1)  goto (8|M0)                          L25024                  L25024                
L24920:
        cmp (8|M0)    (eq)f1.1   null<1>:d     r53.0<1;1,0>:d    2:w              
(~f1.1) goto (8|M0)                          L25024                  L25072                
L24952:
        shr (8|M0)               r101.0<1>:ud  r26.0<1;1,0>:ud   1:w              
        mov (8|M0)               r65.0<1>:d    0:w                              
        mov (8|M0)               r76.0<1>:d    0:w                              
        mov (8|M0)               r56.0<1>:f    r101.0<1;1,0>:f                  {Compacted,I@3}
        goto (8|M0)                          L25024                  L26024                
L25024:
        join (8|M0)                          L25072                                
L25040:
        cmp (8|M0)    (eq)f1.0   null<1>:d     r53.0<1;1,0>:d    1:w              
(f1.0)  goto (8|M0)                          L25072                  L25968                
L25072:
        join (8|M0)                          L25968                                
L25088:
        add3 (8|M0)              acc0.0<1>:d   r86.0<1;0>:d      -r66.0<1;0>:d     -1:w              
        and (8|M0)    (ne)f0.1   r125.0<1>:d   acc0.0<1;1,0>:d   63:w              
(f0.1)  goto (8|M0)                          L25168                  L25168                
L25136:
        mov (8|M0)               r54.0<1>:d    r26.0<1;1,0>:d                  
        goto (8|M0)                          L25168                  L25304                
L25168:
        join (8|M0)                          L25304                                
L25184:
        cmp (8|M0)    (lt)f1.1   null<1>:ud    r125.0<1;1,0>:ud  0x20:uw              {I@5}
(f1.1)  add (8|M0)               acc0.0<1>:d   -r125.0<1;1,0>:d  32:w              
(~f1.1) add (8|M0)               acc2.0<1>:d   r125.0<1;1,0>:d   -32:w              
(f1.1)  shr (8|M0)               r105.0<1>:ud  r26.0<1;1,0>:ud   r125.0<1;1,0>:d 
(f1.1)  shl (8|M0)               r19.0<1>:d    r29.0<1;1,0>:d    acc0.0<1;1,0>:d 
(~f1.1) shr (8|M0)               r101.0<1>:ud  r29.0<1;1,0>:ud   acc2.0<1;1,0>:d  {F@1}
(f1.1)  or (8|M0)                r101.0<1>:d   r105.0<1;1,0>:d   r19.0<1;1,0>:d   {I@2}
        mov (8|M0)               r54.0<1>:f    r101.0<1;1,0>:f                  {Compacted,I@1}
L25304:
        join (8|M0)                          L25968                                
L25320:
        add3 (8|M0)              r40.0<1>:d    r86.0<1;0>:d      -r66.0<1;0>:d     -2:w              
        and (8|M0)    (ne)f1.0   r124.0<1>:d   r40.0<1;1,0>:d    63:w               {I@1}
(f1.0)  goto (8|M0)                          L25400                  L25400                
L25368:
        mov (8|M0)               r101.0<1>:d   r26.0<1;1,0>:d                   {F@1}
        goto (8|M0)                          L25400                  L25528                
L25400:
        join (8|M0)                          L25528                                
L25416:
        cmp (8|M0)    (lt)f0.1   null<1>:ud    r124.0<1;1,0>:ud  0x20:uw              {I@5}
(f0.1)  add (8|M0)               acc0.0<1>:d   -r124.0<1;1,0>:d  32:w              
(~f0.1) add (8|M0)               acc2.0<1>:d   r124.0<1;1,0>:d   -32:w              
(f0.1)  shr (8|M0)               r103.0<1>:ud  r26.0<1;1,0>:ud   r124.0<1;1,0>:d 
(f0.1)  shl (8|M0)               r18.0<1>:d    r29.0<1;1,0>:d    acc0.0<1;1,0>:d 
(~f0.1) shr (8|M0)               r101.0<1>:ud  r29.0<1;1,0>:ud   acc2.0<1;1,0>:d 
(f0.1)  or (8|M0)                r101.0<1>:d   r103.0<1;1,0>:d   r18.0<1;1,0>:d   {I@2}
L25528:
        join (8|M0)                          L25968                                
L25544:
        and (8|M0)    (ne)f1.1   r17.0<1>:d    r40.0<1;1,0>:d    63:w              
        and (8|M0)               r76.0<1>:d    r101.0<1;1,0>:d   1:w               {Compacted,I@3}
(f1.1)  goto (8|M0)                          L25632                  L25632                
L25584:
        mov (8|M0)               r31.0<1>:d    -1:w                              
        mov (8|M0)               r40.0<1>:d    -1:w                              
        goto (8|M0)                          L25632                  L25816                
L25632:
        join (8|M0)                          L25816                                
L25648:
        cmp (8|M0)    (lt)f1.0   null<1>:ud    r17.0<1;1,0>:ud   0x20:uw              {I@7}
(f1.0)  goto (8|M0)                          L25752                  L25752                
L25680:
        add (8|M0)               acc0.0<1>:d   r17.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r6.4<1>:hf    -qnan(0x1FF):hf                             
        mov (8|M0)               r31.0<1>:d    0:w                              
        shl (8|M0)               r40.0<1>:d    r6.4<0;1,0>:w     acc0.0<1;1,0>:d  {F@1}
        goto (8|M0)                          L25752                  L25816                
L25752:
        join (8|M0)                          L25816                                
L25768:
(W)     mov (1|M0)               r6.4<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (8|M0)               r40.0<1>:d    -1:w                              
        shl (8|M0)               r31.0<1>:d    r6.4<0;1,0>:w     r17.0<1;1,0>:d   {F@1}
L25816:
        join (8|M0)                          L25968                                
L25832:
        bfn.0x60 (8|M0)          r102.0<1>:ud  r31.0<1;0>:ud     r7.4<0;0>:ud      r26.0<1>:ud      {I@2} // (s0^s1)&s2
        bfn.0x60 (8|M0)          r101.0<1>:ud  r40.0<1;0>:ud     r7.4<0;0>:ud      r29.0<1>:ud      // (s0^s1)&s2
        cmp (8|M0)    (ne)f1.1   null<1>:d     r102.0<1;1,0>:d   0:w               {I@2}
(W)     mov (1|M0)               r6.4<1>:hf    -qnan(0x1FF):hf                             
        mov (8|M0)               r56.0<1>:f    r54.0<1;1,0>:f                   {Compacted}
(~f1.1) cmp (8|M0)    (ne)f1.1   null<1>:d     r101.0<1;1,0>:d   0:w               {I@2}
(f1.1)  sel (8|M0)               acc0.0<1>:d   r6.4<0;1,0>:w     0:w               {F@2}
        mov (8|M0)               r65.0<1>:d    -acc0.0<1;1,0>:d                
        goto (8|M0)                          L25968                  L26024                
L25968:
        join (8|M0)                          L26024                                
L25984:
        mov (8|M0)               r65.0<1>:d    0:w                              
        mov (8|M0)               r76.0<1>:d    0:w                              
        mov (8|M0)               r56.0<1>:f    r26.0<1;1,0>:f                   {Compacted}
L26024:
        join (8|M0)                          L26592                                
L26040:
        and (8|M0)    (ne)f0.1   r123.0<1>:d   r53.0<1;1,0>:d    63:w              
(f0.1)  goto (8|M0)                          L26104                  L26104                
L26072:
        mov (8|M0)               r101.0<1>:d   r26.0<1;1,0>:d                  
        goto (8|M0)                          L26104                  L26232                
L26104:
        join (8|M0)                          L26232                                
L26120:
        cmp (8|M0)    (lt)f1.1   null<1>:ud    r123.0<1;1,0>:ud  0x20:uw              {I@5}
(f1.1)  add (8|M0)               acc0.0<1>:d   -r123.0<1;1,0>:d  32:w              
(~f1.1) add (8|M0)               acc2.0<1>:d   r123.0<1;1,0>:d   -32:w              
(f1.1)  shr (8|M0)               r98.0<1>:ud   r26.0<1;1,0>:ud   r123.0<1;1,0>:d 
(f1.1)  shl (8|M0)               r16.0<1>:d    r29.0<1;1,0>:d    acc0.0<1;1,0>:d 
(~f1.1) shr (8|M0)               r101.0<1>:ud  r29.0<1;1,0>:ud   acc2.0<1;1,0>:d 
(f1.1)  or (8|M0)                r101.0<1>:d   r98.0<1;1,0>:d    r16.0<1;1,0>:d   {I@2}
L26232:
        join (8|M0)                          L26592                                
L26248:
        shl (8|M0)               r87.0<1>:d    r56.0<1;1,0>:d    2:w               {Compacted,F@1}
        shl (8|M0)               r97.0<1>:d    r76.0<1;1,0>:d    1:w               {Compacted}
        and (8|M0)               r87.0<1>:d    r87.0<1;1,0>:d    4:w               {Compacted,I@2}
        bfn.0xFE (8|M0)          r64.0<1>:ud   r87.0<1;0>:ud     r97.0<1;0>:ud     r65.0<1>:ud      {I@1} // s0|s1|s2
        cmp (8|M0)    (eq)f1.0   null<1>:d     r64.0<1;1,0>:d    0:w               {I@1}
(~f1.0) goto (8|M0)                          L26352                  L26352                
L26320:
        mov (8|M0)               r69.0<1>:d    0:w                              
        goto (8|M0)                          L26352                  L26512                
L26352:
        join (8|M0)                          L26512                                
L26368:
        cmp (8|M0)    (gt)f0.1   null<1>:ud    r64.0<1;1,0>:ud   0x4:uw             
(~f0.1) goto (8|M0)                          L26432                  L26432                
L26400:
        mov (8|M0)               r69.0<1>:d    1:w                              
        goto (8|M0)                          L26432                  L26512                
L26432:
        join (8|M0)                          L26512                                
L26448:
        and (8|M0)    (ne)f1.0   null<1>:d     r101.0<1;1,0>:d   1:w              
(W)     mov (1|M0)               r6.4<1>:hf    0x1:hf                             
(f1.0)  cmp (8|M0)    (eq)f1.0   null<1>:d     r64.0<1;1,0>:d    4:w              
(f1.0)  sel (8|M0)               r69.0<1>:d    r6.4<0;1,0>:w     0:w               {F@1}
L26512:
        join (8|M0)                          L26592                                
L26528:
        add (8|M0)               r95.0<1>:d    r69.0<1;1,0>:d    r101.0<1;1,0>:d  {Compacted,I@2}
(W)     mov (1|M0)               r6.2<1>:f     0x800000:f                               {Compacted}
        cmp (8|M0)    (gt)f1.0   null<1>:ud    r95.0<1;1,0>:ud   0x7FFFFF:ud              {I@1}
(~f1.0) sel (8|M0)               r26.0<1>:d    r95.0<1;1,0>:d    0:w              
(f1.0)  sel (8|M0)               r25.0<1>:d    r6.2<0;1,0>:d     0:w               {F@1}
L26592:
        join (8|M0)                          L26656                                
L26608:
        and (8|M0)               r96.0<1>:d    r24.0<1;1,0>:d    -2147483648:d              
        bfn.0xFE (8|M0)          r116.0<1>:ud  r96.0<1;0>:ud     r25.0<1;0>:ud     r26.0<1>:ud      {I@1} // s0|s1|s2
        goto (8|M0)                          L26656                  L29864                
L26656:
        join (8|M0)                          L27176                                
L26672:
        and (8|M0)    (ne)f1.1   r99.0<1>:d    r37.0<1;1,0>:d    63:w              
(f1.1)  goto (8|M0)                          L26752                  L26752                
L26704:
        mov (8|M0)               r120.0<1>:d   -1:w                              
        mov (8|M0)               r15.0<1>:d    -1:w                              
        goto (8|M0)                          L26752                  L26936                
L26752:
        join (8|M0)                          L26936                                
L26768:
        cmp (8|M0)    (lt)f1.0   null<1>:ud    r99.0<1;1,0>:ud   0x20:uw              {I@6}
(f1.0)  goto (8|M0)                          L26872                  L26872                
L26800:
        add (8|M0)               acc0.0<1>:d   r99.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r6.4<1>:hf    -qnan(0x1FF):hf                             
        mov (8|M0)               r120.0<1>:d   0:w                              
        shl (8|M0)               r15.0<1>:d    r6.4<0;1,0>:w     acc0.0<1;1,0>:d  {F@1}
        goto (8|M0)                          L26872                  L26936                
L26872:
        join (8|M0)                          L26936                                
L26888:
(W)     mov (1|M0)               r6.4<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (8|M0)               r15.0<1>:d    -1:w                              
        shl (8|M0)               r120.0<1>:d   r6.4<0;1,0>:w     r99.0<1;1,0>:d   {F@1}
L26936:
        join (8|M0)                          L27176                                
L26952:
        bfn.0x60 (8|M0)          r95.0<1>:ud   r120.0<1;0>:ud    r7.4<0;0>:ud      r26.0<1>:ud      {I@2} // (s0^s1)&s2
        bfn.0x60 (8|M0)          r94.0<1>:ud   r15.0<1;0>:ud     r7.4<0;0>:ud      r29.0<1>:ud      // (s0^s1)&s2
        cmp (8|M0)    (ne)f1.1   null<1>:d     r95.0<1;1,0>:d    0:w               {I@2}
        cmp (8|M0)    (gt)f0.1   null<1>:d     r24.0<1;1,0>:d    -1:w              
(~f1.1) cmp (8|M0)    (ne)f1.1   null<1>:d     r94.0<1;1,0>:d    0:w               {I@3}
(f1.1)  cmp (8|M0)    (eq)f1.1   null<1>:d     r48.0<1;1,0>:d    -150:w              
(f0.1)  goto (8|M0)                          L27112                  L27112                
L27064:
(W)     mov (1|M0)               r6.2<1>:ud    0x80000001:ud                             
(f1.1)  sel (8|M0)               r116.0<1>:f   r6.2<0;1,0>:f     -0.0:f               {I@1}
        goto (8|M0)                          L27112                  L29864                
L27112:
        join (8|M0)                          L27176                                
L27128:
(W)     mov (1|M0)               r6.2<1>:ud    0x1:ud                              {F@1}
(f1.1)  sel (8|M0)               r116.0<1>:f   r6.2<0;1,0>:f     0.0:f               {I@1}
        goto (8|M0)                          L27176                  L29864                
L27176:
        join (8|M0)                          L29616                                
L27192:
        cmp (8|M0)    (lt)f0.1   null<1>:ud    r37.0<1;1,0>:ud   0x18:uw             
        add3 (8|M0)              r74.0<1>:d    r50.0<1;0>:d      r37.0<1;0>:d      -46:w              
(f0.1)  cmp (8|M0)    (eq)f0.1   null<1>:d     r72.0<1;1,0>:d    0:w              
(f0.1)  goto (8|M0)                          L29296                  L29296                
L27256:
        shl (8|M0)               r53.0<1>:d    r27.0<1;1,0>:d    1:w               {Compacted}
        shr (8|M0)               r52.0<1>:ud   r27.0<1;1,0>:ud   31:w              
        shl (8|M0)               r31.0<1>:d    r77.0<1;1,0>:d    1:w               {Compacted}
        cmp (8|M0)    (lt)f1.0   null<1>:ud    r53.0<1;1,0>:ud   0x4E:uw              {I@3}
        or (8|M0)                r31.0<1>:d    r31.0<1;1,0>:d    r52.0<1;1,0>:d   {Compacted,I@2}
(f1.0)  cmp (8|M0)    (eq)f1.0   null<1>:d     r31.0<1;1,0>:d    0:w               {I@1}
(~f1.0) cmp (8|M0)    (lt)f1.0   null<1>:d     r31.0<1;1,0>:d    0:w              
(f1.0)  goto (8|M0)                          L27488                  L27488                
L27360:
        cmp (8|M0)    (eq)f1.1   null<1>:d     r27.0<1;1,0>:d    39:w               {F@1}
(f1.1)  cmp (8|M0)    (eq)f1.1   null<1>:d     r77.0<1;1,0>:d    0:w              
(~f1.1) goto (8|M0)                          L27488                  L27552                
L27408:
        shr (8|M0)               r101.0<1>:ud  r26.0<1;1,0>:ud   1:w              
        mov (8|M0)               r69.0<1>:d    0:w                              
        mov (8|M0)               r82.0<1>:d    0:w                              
        mov (8|M0)               r40.0<1>:f    r101.0<1;1,0>:f                  {Compacted,I@3}
        mov (8|M0)               r101.0<1>:f   r26.0<1;1,0>:f                   {Compacted}
        goto (8|M0)                          L27488                  L28752                
L27488:
        join (8|M0)                          L27552                                
L27504:
        cmp (8|M0)    (eq)f1.0   null<1>:d     r27.0<1;1,0>:d    38:w              
(f1.0)  cmp (8|M0)    (eq)f1.0   null<1>:d     r77.0<1;1,0>:d    0:w              
(f1.0)  goto (8|M0)                          L27552                  L28664                
L27552:
        join (8|M0)                          L28664                                
L27568:
        add (8|M0)               acc0.0<1>:d   -r27.0<1;1,0>:d   39:w               {Compacted}
        add (8|M0)               r76.0<1>:d    -r27.0<1;1,0>:d   40:w               {Compacted}
        and (8|M0)    (ne)f1.1   r23.0<1>:d    acc0.0<1;1,0>:d   63:w              
(f1.1)  goto (8|M0)                          L27648                  L27648                
L27616:
        mov (8|M0)               r62.0<1>:d    r26.0<1;1,0>:d                  
        goto (8|M0)                          L27648                  L27784                
L27648:
        join (8|M0)                          L27784                                
L27664:
        cmp (8|M0)    (lt)f1.0   null<1>:ud    r23.0<1;1,0>:ud   0x20:uw              {I@5}
(f1.0)  add (8|M0)               acc0.0<1>:d   -r23.0<1;1,0>:d   32:w              
(~f1.0) add (8|M0)               acc2.0<1>:d   r23.0<1;1,0>:d    -32:w              
(f1.0)  shr (8|M0)               r91.0<1>:ud   r26.0<1;1,0>:ud   r23.0<1;1,0>:d  
(f1.0)  shl (8|M0)               r39.0<1>:d    r29.0<1;1,0>:d    acc0.0<1;1,0>:d 
(~f1.0) shr (8|M0)               r101.0<1>:ud  r29.0<1;1,0>:ud   acc2.0<1;1,0>:d  {F@1}
(f1.0)  or (8|M0)                r101.0<1>:d   r91.0<1;1,0>:d    r39.0<1;1,0>:d   {I@2}
        mov (8|M0)               r62.0<1>:f    r101.0<1;1,0>:f                  {Compacted,I@1}
L27784:
        join (8|M0)                          L28664                                
L27800:
        add (8|M0)               r44.0<1>:d    -r27.0<1;1,0>:d   38:w               {Compacted}
        and (8|M0)    (ne)f0.1   r30.0<1>:d    r44.0<1;1,0>:d    63:w               {I@1}
(f0.1)  goto (8|M0)                          L27872                  L27872                
L27840:
        mov (8|M0)               r101.0<1>:d   r26.0<1;1,0>:d                   {F@1}
        goto (8|M0)                          L27872                  L28000                
L27872:
        join (8|M0)                          L28000                                
L27888:
        cmp (8|M0)    (lt)f1.1   null<1>:ud    r30.0<1;1,0>:ud   0x20:uw              {I@5}
(f1.1)  add (8|M0)               acc0.0<1>:d   -r30.0<1;1,0>:d   32:w              
(~f1.1) add (8|M0)               acc2.0<1>:d   r30.0<1;1,0>:d    -32:w              
(f1.1)  shr (8|M0)               r89.0<1>:ud   r26.0<1;1,0>:ud   r30.0<1;1,0>:d  
(f1.1)  shl (8|M0)               r46.0<1>:d    r29.0<1;1,0>:d    acc0.0<1;1,0>:d 
(~f1.1) shr (8|M0)               r101.0<1>:ud  r29.0<1;1,0>:ud   acc2.0<1;1,0>:d 
(f1.1)  or (8|M0)                r101.0<1>:d   r89.0<1;1,0>:d    r46.0<1;1,0>:d   {I@2}
L28000:
        join (8|M0)                          L28664                                
L28016:
        and (8|M0)    (ne)f1.0   r45.0<1>:d    r44.0<1;1,0>:d    63:w              
        and (8|M0)               r82.0<1>:d    r101.0<1;1,0>:d   1:w               {Compacted,I@3}
(f1.0)  goto (8|M0)                          L28104                  L28104                
L28056:
        mov (8|M0)               r52.0<1>:d    -1:w                              
        mov (8|M0)               r55.0<1>:d    -1:w                              
        goto (8|M0)                          L28104                  L28288                
L28104:
        join (8|M0)                          L28288                                
L28120:
        cmp (8|M0)    (lt)f0.1   null<1>:ud    r45.0<1;1,0>:ud   0x20:uw              {I@7}
(f0.1)  goto (8|M0)                          L28224                  L28224                
L28152:
        add (8|M0)               acc0.0<1>:d   r45.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r6.4<1>:hf    -qnan(0x1FF):hf                             
        mov (8|M0)               r52.0<1>:d    0:w                              
        shl (8|M0)               r55.0<1>:d    r6.4<0;1,0>:w     acc0.0<1;1,0>:d  {F@1}
        goto (8|M0)                          L28224                  L28288                
L28224:
        join (8|M0)                          L28288                                
L28240:
(W)     mov (1|M0)               r6.4<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (8|M0)               r55.0<1>:d    -1:w                              
        shl (8|M0)               r52.0<1>:d    r6.4<0;1,0>:w     r45.0<1;1,0>:d   {F@1}
L28288:
        join (8|M0)                          L28664                                
L28304:
        bfn.0x60 (8|M0)          r88.0<1>:ud   r52.0<1;0>:ud     r7.4<0;0>:ud      r26.0<1>:ud      {I@2} // (s0^s1)&s2
        bfn.0x60 (8|M0)          r87.0<1>:ud   r55.0<1;0>:ud     r7.4<0;0>:ud      r29.0<1>:ud      // (s0^s1)&s2
        cmp (8|M0)    (ne)f0.1   null<1>:d     r88.0<1;1,0>:d    0:w               {I@2}
(W)     mov (1|M0)               r6.4<1>:hf    -qnan(0x1FF):hf                             
        and (8|M0)    (ne)f1.1   r28.0<1>:d    r76.0<1;1,0>:d    63:w              
(~f0.1) cmp (8|M0)    (ne)f0.1   null<1>:d     r87.0<1;1,0>:d    0:w               {I@3}
(f0.1)  sel (8|M0)               acc0.0<1>:d   r6.4<0;1,0>:w     0:w               {F@1}
        mov (8|M0)               r69.0<1>:d    -acc0.0<1;1,0>:d                
(f1.1)  goto (8|M0)                          L28480                  L28480                
L28448:
        mov (8|M0)               r101.0<1>:d   r26.0<1;1,0>:d                  
        goto (8|M0)                          L28480                  L28608                
L28480:
        join (8|M0)                          L28608                                
L28496:
        cmp (8|M0)    (lt)f1.0   null<1>:ud    r28.0<1;1,0>:ud   0x20:uw              {I@7}
(f1.0)  add (8|M0)               acc0.0<1>:d   -r28.0<1;1,0>:d   32:w              
(~f1.0) add (8|M0)               acc2.0<1>:d   r28.0<1;1,0>:d    -32:w              
(f1.0)  shr (8|M0)               r84.0<1>:ud   r26.0<1;1,0>:ud   r28.0<1;1,0>:d  
(f1.0)  shl (8|M0)               r44.0<1>:d    r29.0<1;1,0>:d    acc0.0<1;1,0>:d 
(~f1.0) shr (8|M0)               r101.0<1>:ud  r29.0<1;1,0>:ud   acc2.0<1;1,0>:d 
(f1.0)  or (8|M0)                r101.0<1>:d   r84.0<1;1,0>:d    r44.0<1;1,0>:d   {I@2}
L28608:
        join (8|M0)                          L28664                                
L28624:
        mov (8|M0)               r40.0<1>:f    r101.0<1;1,0>:f                  {Compacted,I@2}
        mov (8|M0)               r101.0<1>:d   r62.0<1;1,0>:d                   {F@1}
        goto (8|M0)                          L28664                  L28752                
L28664:
        join (8|M0)                          L28752                                
L28680:
        shr (8|M0)               r101.0<1>:ud  r26.0<1;1,0>:ud   2:w              
        mov (8|M0)               r69.0<1>:d    0:w                              
        mov (8|M0)               r82.0<1>:d    0:w                              
        mov (8|M0)               r40.0<1>:f    r101.0<1;1,0>:f                  {Compacted,I@3}
        shr (8|M0)               r101.0<1>:ud  r26.0<1;1,0>:ud   1:w               {F@1}
L28752:
        join (8|M0)                          L29296                                
L28768:
        shl (8|M0)               r30.0<1>:d    r101.0<1;1,0>:d   2:w               {Compacted,I@2}
        shl (8|M0)               r83.0<1>:d    r82.0<1;1,0>:d    1:w               {Compacted}
        and (8|M0)               r30.0<1>:d    r30.0<1;1,0>:d    4:w               {Compacted,I@2}
        and (8|M0)               r63.0<1>:d    r40.0<1;1,0>:d    8388607:d              
        bfn.0xFE (8|M0)          r98.0<1>:ud   r30.0<1;0>:ud     r83.0<1;0>:ud     r69.0<1>:ud      {I@2} // s0|s1|s2
        cmp (8|M0)    (eq)f0.1   null<1>:d     r98.0<1;1,0>:d    0:w               {I@1}
(~f0.1) goto (8|M0)                          L28888                  L28888                
L28856:
        mov (8|M0)               r97.0<1>:d    0:w                              
        goto (8|M0)                          L28888                  L29048                
L28888:
        join (8|M0)                          L29048                                
L28904:
        cmp (8|M0)    (gt)f1.1   null<1>:ud    r98.0<1;1,0>:ud   0x4:uw             
(~f1.1) goto (8|M0)                          L28968                  L28968                
L28936:
        mov (8|M0)               r97.0<1>:d    1:w                              
        goto (8|M0)                          L28968                  L29048                
L28968:
        join (8|M0)                          L29048                                
L28984:
        and (8|M0)    (ne)f1.1   null<1>:d     r40.0<1;1,0>:d    1:w              
(W)     mov (1|M0)               r6.4<1>:hf    0x1:hf                             
(f1.1)  cmp (8|M0)    (eq)f1.1   null<1>:d     r98.0<1;1,0>:d    4:w              
(f1.1)  sel (8|M0)               r97.0<1>:d    r6.4<0;1,0>:w     0:w               {F@1}
L29048:
        join (8|M0)                          L29296                                
L29064:
        add (8|M0)               r116.0<1>:d   r63.0<1;1,0>:d    r97.0<1;1,0>:d   {Compacted,I@2}
        add3 (8|M0)              r104.0<1>:d   r50.0<1;0>:d      r37.0<1;0>:d      -45:w              
        cmp (8|M0)    (gt)f1.1   null<1>:ud    r116.0<1;1,0>:ud  0x7FFFFF:ud              {I@2}
(f1.1)  sel (8|M0)               r106.0<1>:d   r104.0<1;1,0>:d   r74.0<1;1,0>:d   {I@2}
        cmp (8|M0)    (eq)f1.0   null<1>:d     r106.0<1;1,0>:d   255:w               {I@1}
(f1.0)  goto (8|M0)                          L29224                  L29224                
L29152:
(~f1.1) sel (8|M0)               r109.0<1>:d   r116.0<1;1,0>:d   0:w              
        and (8|M0)               r103.0<1>:d   r24.0<1;1,0>:d    -2147483648:d              
        shl (8|M0)               r82.0<1>:d    r106.0<1;1,0>:d   23:w               {Compacted}
        bfn.0xFE (8|M0)          r116.0<1>:ud  r103.0<1;0>:ud    r82.0<1;0>:ud     r109.0<1>:ud     {I@1} // s0|s1|s2
        goto (8|M0)                          L29224                  L29864                
L29224:
        join (8|M0)                          L29296                                
L29240:
        cmp (8|M0)    (gt)f1.1   null<1>:d     r24.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r6.2<1>:f     inf:f                               {Compacted}
(f1.1)  sel (8|M0)               r116.0<1>:f   r6.2<0;1,0>:f     -inf:f               {A@1}
        goto (8|M0)                          L29296                  L29864                
L29296:
        join (8|M0)                          L29616                                
L29312:
        and (8|M0)    (ne)f0.1   r114.0<1>:d   r37.0<1;1,0>:d    63:w              
(f0.1)  goto (8|M0)                          L29376                  L29376                
L29344:
        mov (8|M0)               r86.0<1>:d    -1:w                              
        goto (8|M0)                          L29376                  L29504                
L29376:
        join (8|M0)                          L29504                                
L29392:
        cmp (8|M0)    (lt)f1.1   null<1>:ud    r114.0<1;1,0>:ud  0x20:uw              {A@1}
(f1.1)  goto (8|M0)                          L29456                  L29456                
L29424:
        mov (8|M0)               r86.0<1>:d    0:w                              
        goto (8|M0)                          L29456                  L29504                
L29456:
        join (8|M0)                          L29504                                
L29472:
(W)     mov (1|M0)               r6.4<1>:hf    -qnan(0x1FF):hf                             
        shl (8|M0)               r86.0<1>:d    r6.4<0;1,0>:w     r114.0<1;1,0>:d  {F@1}
L29504:
        join (8|M0)                          L29616                                
L29520:
        bfn.0x60 (8|M0)          r96.0<1>:ud   r86.0<1;0>:ud     r7.4<0;0>:ud      r26.0<1>:ud      {I@2} // (s0^s1)&s2
        add (8|M0)               acc0.0<1>:d   -r37.0<1;1,0>:d   23:w               {Compacted}
        and (8|M0)               r102.0<1>:d   r24.0<1;1,0>:d    -2147483648:d              
        shl (8|M0)               r80.0<1>:d    r74.0<1;1,0>:d    23:w               {Compacted}
        shl (8|M0)               r96.0<1>:d    r96.0<1;1,0>:d    acc0.0<1;1,0>:d  {I@4}
        bfn.0xFE (8|M0)          r116.0<1>:ud  r102.0<1;0>:ud    r80.0<1;0>:ud     r96.0<1>:ud      {I@1} // s0|s1|s2
        goto (8|M0)                          L29616                  L29864                
L29616:
        join (8|M0)                          L29688                                
L29632:
        cmp (8|M0)    (gt)f1.0   null<1>:d     r24.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r6.2<1>:f     inf:f                               {Compacted}
(f1.0)  sel (8|M0)               r116.0<1>:f   r6.2<0;1,0>:f     -inf:f               {A@1}
        goto (8|M0)                          L29688                  L29864                
L29688:
        join (8|M0)                          L29760                                
L29704:
        cmp (8|M0)    (lt)f0.1   null<1>:d     r24.0<1;1,0>:d    0:w              
(W)     mov (1|M0)               r6.2<1>:f     -0.0:f                               {Compacted}
(f0.1)  sel (8|M0)               r116.0<1>:f   r6.2<0;1,0>:f     0.0:f               {F@1}
        goto (8|M0)                          L29760                  L29864                
L29760:
        join (8|M0)                          L29832                                
L29776:
        cmp (8|M0)    (gt)f1.1   null<1>:d     r24.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r6.2<1>:f     inf:f                               {Compacted}
(f1.1)  sel (8|M0)               r116.0<1>:f   r6.2<0;1,0>:f     -inf:f               {F@1}
        goto (8|M0)                          L29832                  L29864                
L29832:
        join (8|M0)                          L29864                                
L29848:
        bfn.0xF8 (8|M0)          r116.0<1>:ud  r24.0<1;0>:ud     r7.6<0;0>:ud      r7.5<0>:ud       {F@1} // s0&s1|s2
L29864:
        join (8|M0)                          L36464                                
L29880:
        rnde (8|M0)              r95.0<1>:f    r116.0<1;1,0>:f                  {Compacted,I@2}
        shr (8|M0)               r35.0<1>:ud   r95.0<1;1,0>:ud   23:w               {F@1}
        and (8|M0)    (ne)f1.0   r51.0<1>:d    r95.0<1;1,0>:d    8388607:d              
        and (8|M0)               r63.0<1>:d    r35.0<1;1,0>:d    255:w               {Compacted,I@2}
(f1.0)  cmp (8|M0)    (eq)f1.0   null<1>:d     r63.0<1;1,0>:d    255:w               {I@1}
(~f1.0) goto (8|M0)                          L29984                  L29984                
L29960:
        mov (8|M0)               r110.0<1>:f   qnan(0x0):f                               {Compacted}
        goto (8|M0)                          L29984                  L36248                
L29984:
        join (8|M0)                          L36248                                
L30000:
        cmp (8|M0)    (eq)f0.1   null<1>:d     r51.0<1;1,0>:d    0:w              
        add (8|M0)               r113.0<1>:d   r22.0<1;1,0>:d    -25165824:d              
        shr (8|M0)               r31.0<1>:ud   r113.0<1;1,0>:ud  23:w               {I@1}
(f0.1)  cmp (8|M0)    (eq)f0.1   null<1>:d     r63.0<1;1,0>:d    255:w              
        and (8|M0)               r56.0<1>:d    r31.0<1;1,0>:d    255:w               {Compacted,I@2}
        xor (8|M0)               r23.0<1>:d    r113.0<1;1,0>:d   r95.0<1;1,0>:d   {Compacted}
(~f0.1) cmp (8|M0)    (eq)f0.1   null<1>:d     r56.0<1;1,0>:d    255:w               {I@2}
(f0.1)  goto (8|M0)                          L36216                  L36216                
L30112:
        cmp (8|M0)    (eq)f0.1   null<1>:d     r56.0<1;1,0>:d    0:w              
        or (8|M0)                r79.0<1>:d    r63.0<1;1,0>:d    r51.0<1;1,0>:d   {Compacted}
(~f0.1) cmp (8|M0)    (eq)f0.1   null<1>:d     r79.0<1;1,0>:d    0:w               {I@1}
(~f0.1) goto (8|M0)                          L30192                  L30192                
L30168:
        mov (8|M0)               r110.0<1>:f   0.0:f                               {Compacted}
        goto (8|M0)                          L30192                  L36248                
L30192:
        join (8|M0)                          L36216                                
L30208:
        cmp (8|M0)    (eq)f1.1   null<1>:d     r63.0<1;1,0>:d    0:w              
        add (8|M0)               r54.0<1>:d    r63.0<1;1,0>:d    -127:w               {Compacted}
(f1.1)  mov (8|M0)               r54.0<1>:d    -126:w                              
        add (8|M0)               r49.0<1>:d    r56.0<1;1,0>:d    r54.0<1;1,0>:d   {Compacted,I@1}
        cmp (8|M0)    (gt)f1.0   null<1>:d     r49.0<1;1,0>:d    254:w               {I@1}
(f1.0)  goto (8|M0)                          L36144                  L36144                
L30288:
        or (8|M0)     (eq)f0.1   null<4>:b     r35.0<1;1,0>:d    r31.0<1;1,0>:d  
(f0.1)  goto (8|M0)                          L36072                  L36072                
L30320:
(W)     mov (1|M0)               r6.4<1>:hf    0.0:hf                             
(W)     mov (1|M0)               r6.6<1>:d     0:w                              
(f1.1)  sel (8|M0)               acc0.0<1>:d   r6.4<0;1,0>:w     8388608:d               {F@1}
(W)     mov (1|M0)               r6.3<1>:f     -0.0:f                               {Compacted}
        or (8|M0)                r109.0<1>:d   acc0.0<1;1,0>:d   r51.0<1;1,0>:d  
(W)     mov (2|M0)               r6.4<1>:d     0:w                              
        shl (8|M0)               r25.0<1>:d    r109.0<1;1,0>:d   23:w               {Compacted,I@2}
        shr (8|M0)               r28.0<1>:ud   r109.0<1;1,0>:ud  9:w              
L30432:
(W)     shl (1|M0)               r15.1<1>:d    r6.3<0;1,0>:d     31:w               {F@1}
(W)     shr (1|M0)               r6.7<1>:ud    r6.6<0;1,0>:ud    1:w              
(W)     cmp (8|M0)    (gt)f1.0   null<1>:ud    r6.4<0;1,0>:ud    0x3E:uw              {I@5}
(W)     or (1|M0)                r6.6<1>:d     r6.7<0;1,0>:d     r15.1<0;1,0>:d   {I@2}
        bfn.0xE0 (8|M0)          r33.0<1>:ud   r6.7<0;0>:ud      r15.1<0;0>:ud     r25.0<1>:ud      // (s0|s1)&s2
(W)     shr (1|M0)               r6.2<1>:ud    r6.3<0;1,0>:ud    1:w              
(W&f1.0) cmp (8|M0)   (eq)f1.0   null<1>:d     r6.5<0;1,0>:d     0:w              
        cmp (8|M0)    (eq)f1.1   null<1>:d     r33.0<1;1,0>:d    r6.6<0;1,0>:d    {I@3}
        and (8|M0)               r32.0<1>:d    r6.2<0;1,0>:d     r28.0<1;1,0>:d   {Compacted,I@3}
(W)     addc (1|M0)              r17.0<1>:ud   r6.4<0;1,0>:ud    0x1:ud              {AccWrEn}
(W&~f1.0) cmp (8|M0)  (gt)f1.0   null<1>:ud    r6.5<0;1,0>:ud    0x0:uw             
(f1.1)  cmp (8|M0)    (eq)f1.1   null<1>:d     r32.0<1;1,0>:d    r6.2<0;1,0>:d    {I@3}
(W)     mov (1|M0)               r6.14<1>:hf   0x1:hf                             
(W)     mov (1|M0)               r15.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
(f1.0)  sel (8|M0)               r16.0<1>:uw   r6.14<0;1,0>:uw   0x0:uw              {F@1}
(W)     add (1|M0)               r15.4<1>:ud   r15.0<0;1,0>:ud   r6.5<0;1,0>:ud   {I@2}
(f1.1)  sel (8|M0)               r15.0<1>:uw   r6.14<0;1,0>:uw   0x0:uw             
        mov (8|M0)               r99.0<1>:d    r6.4<0;1,0>:d                   
        or (8|M0)     (ne)f1.0   null<1>:uw    r16.0<1;1,0>:uw   r15.0<1;1,0>:uw  {I@2}
        mov (8|M0)               r103.0<1>:d   r6.5<0;1,0>:d                   
        mov (8|M0)               r26.0<1>:f    r17.0<0;1,0>:f                   {Compacted}
        mov (8|M0)               r75.0<1>:d    r15.4<0;1,0>:d                  
(f1.0)  goto (8|M0)                          L30840                  L30840                
L30776:
(W)     mov (1|M0)               r6.3<1>:d     r6.2<0;1,0>:d                   
(W)     mov (1|M0)               r6.4<1>:d     r17.0<0;1,0>:d                  
(W)     mov (1|M0)               r6.5<1>:d     r15.4<0;1,0>:d                  
(W)     jmpi                                 L30432                                
L30840:
        join (8|M0)                          L36072                                
L30856:
(W)     mov (1|M0)               r6.2<1>:f     8.68805e-44:f                               {I@5}
(W)     mov (1|M0)               r15.0<1>:hf   0.0:hf                             
        subb (8|M0)              r36.0<1>:ud   r6.2<0;1,0>:ud    r99.0<1;1,0>:ud  {AccWrEn,Compacted,F@2}
        add3 (8|M0)              r46.0<1>:d    r49.0<1;0>:d      r36.0<1;0>:d      -173:w               {I@1}
        add3 (8|M0)              r71.0<1>:ud   -acc0.0<1;0>:ud   r15.0<0;0>:uw     -r103.0<1>:ud    {F@1}
        cmp (8|M0)    (gt)f1.1   null<1>:d     r46.0<1;1,0>:d    127:w               {I@2}
        add3 (8|M0)              r47.0<1>:d    r56.0<1;0>:d      r54.0<1;0>:d      r36.0<1>:d      
(f1.1)  goto (8|M0)                          L36000                  L36000                
L30976:
        cmp (8|M0)    (gt)f1.0   null<1>:d     r46.0<1;1,0>:d    -127:w              
(f1.0)  goto (8|M0)                          L33560                  L33560                
L31008:
        cmp (8|M0)    (lt)f0.1   null<1>:ud    r46.0<1;1,0>:ud   0xFFFFFF6B:ud             
(f0.1)  goto (8|M0)                          L33040                  L33040                
L31040:
(W)     mov (1|M0)               r6.2<1>:f     8.82818e-44:f                              
        add3 (8|M0)              r64.0<1>:d    r49.0<1;0>:d      r36.0<1;0>:d      -23:w              
        subb (8|M0)              r85.0<1>:ud   r6.2<0;1,0>:ud    r99.0<1;1,0>:ud  {AccWrEn,Compacted,F@1}
(W)     mov (1|M0)               r15.0<1>:hf   0.0:hf                              {I@7}
        cmp (8|M0)    (gt)f1.1   null<1>:ud    r85.0<1;1,0>:ud   r64.0<1;1,0>:ud  {I@1}
        add3 (8|M0)              r112.0<1>:ud  -acc0.0<1;0>:ud   r15.0<0;0>:uw     -r103.0<1>:ud    {F@1}
(f1.1)  cmp (8|M0)    (eq)f1.1   null<1>:d     r112.0<1;1,0>:d   0:w               {I@1}
(~f1.1) cmp (8|M0)    (gt)f1.1   null<1>:ud    r112.0<1;1,0>:ud  0x0:uw             
(f1.1)  goto (8|M0)                          L31240                  L31240                
L31176:
        add3 (8|M0)              acc0.0<1>:d   r47.0<1;0>:d      -r85.0<1;0>:d     -23:w              
        mov (8|M0)               r126.0<1>:d   0:w                              
        shl (8|M0)               r127.0<1>:d   r25.0<1;1,0>:d    acc0.0<1;1,0>:d 
        goto (8|M0)                          L31240                  L32976                
L31240:
        join (8|M0)                          L32976                                
L31256:
        add3 (8|M0)              r52.0<1>:d    r85.0<1;0>:d      -r47.0<1;0>:d     23:w              
        cmp (8|M0)    (lt)f1.1   null<1>:d     r52.0<1;1,0>:d    2:w               {I@1}
(f1.1)  goto (8|M0)                          L31408                  L31408                
L31304:
        cmp (8|M0)    (eq)f1.0   null<1>:d     r52.0<1;1,0>:d    2:w              
(~f1.0) goto (8|M0)                          L31408                  L31456                
L31336:
        shr (8|M0)               r100.0<1>:ud  r25.0<1;1,0>:ud   1:w              
        mov (8|M0)               r62.0<1>:d    0:w                              
        mov (8|M0)               r73.0<1>:d    0:w                              
        mov (8|M0)               r54.0<1>:f    r100.0<1;1,0>:f                  {Compacted,I@3}
        goto (8|M0)                          L31408                  L32408                
L31408:
        join (8|M0)                          L31456                                
L31424:
        cmp (8|M0)    (eq)f0.1   null<1>:d     r52.0<1;1,0>:d    1:w              
(f0.1)  goto (8|M0)                          L31456                  L32352                
L31456:
        join (8|M0)                          L32352                                
L31472:
        add3 (8|M0)              acc0.0<1>:d   r85.0<1;0>:d      -r64.0<1;0>:d     -1:w              
        and (8|M0)    (ne)f1.1   r117.0<1>:d   acc0.0<1;1,0>:d   63:w              
(f1.1)  goto (8|M0)                          L31552                  L31552                
L31520:
        mov (8|M0)               r51.0<1>:d    r25.0<1;1,0>:d                  
        goto (8|M0)                          L31552                  L31688                
L31552:
        join (8|M0)                          L31688                                
L31568:
        cmp (8|M0)    (lt)f1.0   null<1>:ud    r117.0<1;1,0>:ud  0x20:uw              {I@5}
(f1.0)  add (8|M0)               acc0.0<1>:d   -r117.0<1;1,0>:d  32:w              
(~f1.0) add (8|M0)               acc2.0<1>:d   r117.0<1;1,0>:d   -32:w              
(f1.0)  shr (8|M0)               r75.0<1>:ud   r25.0<1;1,0>:ud   r117.0<1;1,0>:d 
(f1.0)  shl (8|M0)               r119.0<1>:d   r28.0<1;1,0>:d    acc0.0<1;1,0>:d 
(~f1.0) shr (8|M0)               r100.0<1>:ud  r28.0<1;1,0>:ud   acc2.0<1;1,0>:d  {F@1}
(f1.0)  or (8|M0)                r100.0<1>:d   r75.0<1;1,0>:d    r119.0<1;1,0>:d  {I@2}
        mov (8|M0)               r51.0<1>:f    r100.0<1;1,0>:f                  {Compacted,I@1}
L31688:
        join (8|M0)                          L32352                                
L31704:
        add3 (8|M0)              r34.0<1>:d    r85.0<1;0>:d      -r64.0<1;0>:d     -2:w              
        and (8|M0)    (ne)f0.1   r116.0<1>:d   r34.0<1;1,0>:d    63:w               {I@1}
(f0.1)  goto (8|M0)                          L31784                  L31784                
L31752:
        mov (8|M0)               r100.0<1>:d   r25.0<1;1,0>:d                   {F@1}
        goto (8|M0)                          L31784                  L31912                
L31784:
        join (8|M0)                          L31912                                
L31800:
        cmp (8|M0)    (lt)f1.1   null<1>:ud    r116.0<1;1,0>:ud  0x20:uw              {I@5}
(f1.1)  add (8|M0)               acc0.0<1>:d   -r116.0<1;1,0>:d  32:w              
(~f1.1) add (8|M0)               acc2.0<1>:d   r116.0<1;1,0>:d   -32:w              
(f1.1)  shr (8|M0)               r73.0<1>:ud   r25.0<1;1,0>:ud   r116.0<1;1,0>:d 
(f1.1)  shl (8|M0)               r118.0<1>:d   r28.0<1;1,0>:d    acc0.0<1;1,0>:d 
(~f1.1) shr (8|M0)               r100.0<1>:ud  r28.0<1;1,0>:ud   acc2.0<1;1,0>:d 
(f1.1)  or (8|M0)                r100.0<1>:d   r73.0<1;1,0>:d    r118.0<1;1,0>:d  {I@2}
L31912:
        join (8|M0)                          L32352                                
L31928:
        and (8|M0)    (ne)f1.0   r117.0<1>:d   r34.0<1;1,0>:d    63:w              
        and (8|M0)               r73.0<1>:d    r100.0<1;1,0>:d   1:w               {Compacted,I@3}
(f1.0)  goto (8|M0)                          L32016                  L32016                
L31968:
        mov (8|M0)               r127.0<1>:d   -1:w                              
        mov (8|M0)               r29.0<1>:d    -1:w                              
        goto (8|M0)                          L32016                  L32200                
L32016:
        join (8|M0)                          L32200                                
L32032:
        cmp (8|M0)    (lt)f0.1   null<1>:ud    r117.0<1;1,0>:ud  0x20:uw              {I@7}
(f0.1)  goto (8|M0)                          L32136                  L32136                
L32064:
        add (8|M0)               acc0.0<1>:d   r117.0<1;1,0>:d   -32:w               {Compacted}
(W)     mov (1|M0)               r6.4<1>:hf    -qnan(0x1FF):hf                             
        shl (8|M0)               r29.0<1>:d    r6.4<0;1,0>:w     acc0.0<1;1,0>:d  {F@1}
        mov (8|M0)               r127.0<1>:d   0:w                              
        goto (8|M0)                          L32136                  L32200                
L32136:
        join (8|M0)                          L32200                                
L32152:
(W)     mov (1|M0)               r6.4<1>:hf    -qnan(0x1FF):hf                              {I@4}
        mov (8|M0)               r29.0<1>:d    -1:w                              
        shl (8|M0)               r127.0<1>:d   r6.4<0;1,0>:w     r117.0<1;1,0>:d  {F@1}
L32200:
        join (8|M0)                          L32352                                
L32216:
        bfn.0x60 (8|M0)          r72.0<1>:ud   r127.0<1;0>:ud    r7.4<0;0>:ud      r25.0<1>:ud      {I@2} // (s0^s1)&s2
        bfn.0x60 (8|M0)          r71.0<1>:ud   r29.0<1;0>:ud     r7.4<0;0>:ud      r28.0<1>:ud      // (s0^s1)&s2
        cmp (8|M0)    (ne)f1.1   null<1>:d     r72.0<1;1,0>:d    0:w               {I@2}
(W)     mov (1|M0)               r6.4<1>:hf    -qnan(0x1FF):hf                             
        mov (8|M0)               r54.0<1>:f    r51.0<1;1,0>:f                   {Compacted}
(~f1.1) cmp (8|M0)    (ne)f1.1   null<1>:d     r71.0<1;1,0>:d    0:w               {I@2}
(f1.1)  sel (8|M0)               acc0.0<1>:d   r6.4<0;1,0>:w     0:w               {F@2}
        mov (8|M0)               r62.0<1>:d    -acc0.0<1;1,0>:d                
        goto (8|M0)                          L32352                  L32408                
L32352:
        join (8|M0)                          L32408                                
L32368:
        mov (8|M0)               r62.0<1>:d    0:w                              
        mov (8|M0)               r73.0<1>:d    0:w                              
        mov (8|M0)               r54.0<1>:f    r25.0<1;1,0>:f                   {Compacted}
L32408:
        join (8|M0)                          L32976                                
L32424:
        and (8|M0)    (ne)f1.1   r115.0<1>:d   r52.0<1;1,0>:d    63:w              
(f1.1)  goto (8|M0)                          L32488                  L32488                
L32456:
        mov (8|M0)               r100.0<1>:d   r25.0<1;1,0>:d                  
        goto (8|M0)                          L32488                  L32616                
L32488:
        join (8|M0)                          L32616                                
L32504:
        cmp (8|M0)    (lt)f1.0   null<1>:ud    r115.0<1;1,0>:ud  0x20:uw              {I@5}
(f1.0)  add (8|M0)               acc0.0<1>:d   -r115.0<1;1,0>:d  32:w              
(~f1.0) add (8|M0)               acc2.0<1>:d   r115.0<1;1,0>:d   -32:w              
(f1.0)  shr (8|M0)               r68.0<1>:ud   r25.0<1;1,0>:ud   r115.0<1;1,0>:d 
(f1.0)  shl (8|M0)               r116.0<1>:d   r28.0<1;1,0>:d    acc0.0<1;1,0>:d 
(~f1.0) shr (8|M0)               r100.0<1>:ud  r28.0<1;1,0>:ud   acc2.0<1;1,0>:d 
(f1.0)  or (8|M0)                r100.0<1>:d   r68.0<1;1,0>:d    r116.0<1;1,0>:d  {I@2}
L32616:
        join (8|M0)                          L32976                                
L32632:
        shl (8|M0)               r75.0<1>:d    r54.0<1;1,0>:d    2:w               {Compacted,F@1}
        shl (8|M0)               r67.0<1>:d    r73.0<1;1,0>:d    1:w               {Compacted}
        and (8|M0)               r75.0<1>:d    r75.0<1;1,0>:d    4:w               {Compacted,I@2}
        bfn.0xFE (8|M0)          r59.0<1>:ud   r75.0<1;0>:ud     r67.0<1;0>:ud     r62.0<1>:ud      {I@1} // s0|s1|s2
        cmp (8|M0)    (eq)f0.1   null<1>:d     r59.0<1;1,0>:d    0:w               {I@1}
(~f0.1) goto (8|M0)                          L32736                  L32736                
L32704:
        mov (8|M0)               r63.0<1>:d    0:w                              
        goto (8|M0)                          L32736                  L32896                
L32736:
        join (8|M0)                          L32896                                
L32752:
        cmp (8|M0)    (gt)f1.1   null<1>:ud    r59.0<1;1,0>:ud   0x4:uw             
(~f1.1) goto (8|M0)                          L32816                  L32816                
L32784:
        mov (8|M0)               r63.0<1>:d    1:w                              
        goto (8|M0)                          L32816                  L32896                
L32816:
        join (8|M0)                          L32896                                
L32832:
        and (8|M0)    (ne)f1.0   null<1>:d     r100.0<1;1,0>:d   1:w              
(W)     mov (1|M0)               r6.4<1>:hf    0x1:hf                             
(f1.0)  cmp (8|M0)    (eq)f1.0   null<1>:d     r59.0<1;1,0>:d    4:w              
(f1.0)  sel (8|M0)               r63.0<1>:d    r6.4<0;1,0>:w     0:w               {F@1}
L32896:
        join (8|M0)                          L32976                                
L32912:
        add (8|M0)               r93.0<1>:d    r63.0<1;1,0>:d    r100.0<1;1,0>:d  {Compacted,I@2}
(W)     mov (1|M0)               r6.2<1>:f     0x800000:f                               {Compacted}
        cmp (8|M0)    (gt)f0.1   null<1>:ud    r93.0<1;1,0>:ud   0x7FFFFF:ud              {I@1}
(~f0.1) sel (8|M0)               r127.0<1>:d   r93.0<1;1,0>:d    0:w              
(f0.1)  sel (8|M0)               r126.0<1>:d   r6.2<0;1,0>:d     0:w               {F@1}
L32976:
        join (8|M0)                          L33040                                
L32992:
        and (8|M0)               r66.0<1>:d    r23.0<1;1,0>:d    -2147483648:d              
        bfn.0xFE (8|M0)          r110.0<1>:ud  r66.0<1;0>:ud     r126.0<1;0>:ud    r127.0<1>:ud     {I@1} // s0|s1|s2
        goto (8|M0)                          L33040                  L36248                
L33040:
        join (8|M0)                          L33560                                
L33056:
        and (8|M0)    (ne)f1.0   r85.0<1>:d    r36.0<1;1,0>:d    63:w              
(f1.0)  goto (8|M0)                          L33136                  L33136                
L33088:
        mov (8|M0)               r94.0<1>:d    -1:w                              
        mov (8|M0)               r114.0<1>:d   -1:w                              
        goto (8|M0)                          L33136                  L33320                
L33136:
        join (8|M0)                          L33320                                
L33152:
        cmp (8|M0)    (lt)f0.1   null<1>:ud    r85.0<1;1,0>:ud   0x20:uw              {I@6}
(f0.1)  goto (8|M0)                          L33256                  L33256                
L33184:
        add (8|M0)               acc0.0<1>:d   r85.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r6.4<1>:hf    -qnan(0x1FF):hf                             
        mov (8|M0)               r94.0<1>:d    0:w                              
        shl (8|M0)               r114.0<1>:d   r6.4<0;1,0>:w     acc0.0<1;1,0>:d  {F@1}
        goto (8|M0)                          L33256                  L33320                
L33256:
        join (8|M0)                          L33320                                
L33272:
(W)     mov (1|M0)               r6.4<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (8|M0)               r114.0<1>:d   -1:w                              
        shl (8|M0)               r94.0<1>:d    r6.4<0;1,0>:w     r85.0<1;1,0>:d   {F@1}
L33320:
        join (8|M0)                          L33560                                
L33336:
        bfn.0x60 (8|M0)          r65.0<1>:ud   r94.0<1;0>:ud     r7.4<0;0>:ud      r25.0<1>:ud      {I@2} // (s0^s1)&s2
        bfn.0x60 (8|M0)          r64.0<1>:ud   r114.0<1;0>:ud    r7.4<0;0>:ud      r28.0<1>:ud      // (s0^s1)&s2
        cmp (8|M0)    (ne)f1.0   null<1>:d     r65.0<1;1,0>:d    0:w               {I@2}
        cmp (8|M0)    (gt)f1.1   null<1>:d     r23.0<1;1,0>:d    -1:w              
(~f1.0) cmp (8|M0)    (ne)f1.0   null<1>:d     r64.0<1;1,0>:d    0:w               {I@3}
(f1.0)  cmp (8|M0)    (eq)f1.0   null<1>:d     r46.0<1;1,0>:d    -150:w              
(f1.1)  goto (8|M0)                          L33496                  L33496                
L33448:
(W)     mov (1|M0)               r6.2<1>:ud    0x80000001:ud                             
(f1.0)  sel (8|M0)               r110.0<1>:f   r6.2<0;1,0>:f     -0.0:f               {I@1}
        goto (8|M0)                          L33496                  L36248                
L33496:
        join (8|M0)                          L33560                                
L33512:
(W)     mov (1|M0)               r6.2<1>:ud    0x1:ud                              {F@1}
(f1.0)  sel (8|M0)               r110.0<1>:f   r6.2<0;1,0>:f     0.0:f               {I@1}
        goto (8|M0)                          L33560                  L36248                
L33560:
        join (8|M0)                          L36000                                
L33576:
        cmp (8|M0)    (lt)f0.1   null<1>:ud    r36.0<1;1,0>:ud   0x18:uw             
        add3 (8|M0)              r73.0<1>:d    r49.0<1;0>:d      r36.0<1;0>:d      -46:w              
(f0.1)  cmp (8|M0)    (eq)f0.1   null<1>:d     r71.0<1;1,0>:d    0:w              
(f0.1)  goto (8|M0)                          L35680                  L35680                
L33640:
        shl (8|M0)               r43.0<1>:d    r26.0<1;1,0>:d    1:w               {Compacted}
        shr (8|M0)               r42.0<1>:ud   r26.0<1;1,0>:ud   31:w              
        shl (8|M0)               r22.0<1>:d    r75.0<1;1,0>:d    1:w               {Compacted}
        cmp (8|M0)    (lt)f1.0   null<1>:ud    r43.0<1;1,0>:ud   0x4E:uw              {A@1}
        or (8|M0)                r22.0<1>:d    r22.0<1;1,0>:d    r42.0<1;1,0>:d   {Compacted,I@2}
(f1.0)  cmp (8|M0)    (eq)f1.0   null<1>:d     r22.0<1;1,0>:d    0:w               {I@1}
(~f1.0) cmp (8|M0)    (lt)f1.0   null<1>:d     r22.0<1;1,0>:d    0:w              
(f1.0)  goto (8|M0)                          L33872                  L33872                
L33744:
        cmp (8|M0)    (eq)f1.1   null<1>:d     r26.0<1;1,0>:d    39:w              
(f1.1)  cmp (8|M0)    (eq)f1.1   null<1>:d     r75.0<1;1,0>:d    0:w              
(~f1.1) goto (8|M0)                          L33872                  L33936                
L33792:
        shr (8|M0)               r100.0<1>:ud  r25.0<1;1,0>:ud   1:w              
        mov (8|M0)               r68.0<1>:d    0:w                              
        mov (8|M0)               r81.0<1>:d    0:w                              
        mov (8|M0)               r39.0<1>:f    r100.0<1;1,0>:f                  {Compacted,I@3}
        mov (8|M0)               r100.0<1>:f   r25.0<1;1,0>:f                   {Compacted}
        goto (8|M0)                          L33872                  L35136                
L33872:
        join (8|M0)                          L33936                                
L33888:
        cmp (8|M0)    (eq)f1.0   null<1>:d     r26.0<1;1,0>:d    38:w              
(f1.0)  cmp (8|M0)    (eq)f1.0   null<1>:d     r75.0<1;1,0>:d    0:w              
(f1.0)  goto (8|M0)                          L33936                  L35048                
L33936:
        join (8|M0)                          L35048                                
L33952:
        add (8|M0)               acc0.0<1>:d   -r26.0<1;1,0>:d   39:w               {Compacted}
        add (8|M0)               r75.0<1>:d    -r26.0<1;1,0>:d   40:w               {Compacted}
        and (8|M0)    (ne)f1.0   r15.0<1>:d    acc0.0<1;1,0>:d   63:w              
(f1.0)  goto (8|M0)                          L34032                  L34032                
L34000:
        mov (8|M0)               r61.0<1>:d    r25.0<1;1,0>:d                  
        goto (8|M0)                          L34032                  L34168                
L34032:
        join (8|M0)                          L34168                                
L34048:
        cmp (8|M0)    (lt)f0.1   null<1>:ud    r15.0<1;1,0>:ud   0x20:uw              {I@5}
(f0.1)  add (8|M0)               acc0.0<1>:d   -r15.0<1;1,0>:d   32:w              
(~f0.1) add (8|M0)               acc2.0<1>:d   r15.0<1;1,0>:d    -32:w              
(f0.1)  shr (8|M0)               r61.0<1>:ud   r25.0<1;1,0>:ud   r15.0<1;1,0>:d  
(f0.1)  shl (8|M0)               r27.0<1>:d    r28.0<1;1,0>:d    acc0.0<1;1,0>:d 
(~f0.1) shr (8|M0)               r100.0<1>:ud  r28.0<1;1,0>:ud   acc2.0<1;1,0>:d  {F@1}
(f0.1)  or (8|M0)                r100.0<1>:d   r61.0<1;1,0>:d    r27.0<1;1,0>:d   {I@2}
        mov (8|M0)               r61.0<1>:f    r100.0<1;1,0>:f                  {Compacted,I@1}
L34168:
        join (8|M0)                          L35048                                
L34184:
        add (8|M0)               r43.0<1>:d    -r26.0<1;1,0>:d   38:w               {Compacted}
        and (8|M0)    (ne)f1.1   r21.0<1>:d    r43.0<1;1,0>:d    63:w               {I@1}
(f1.1)  goto (8|M0)                          L34256                  L34256                
L34224:
        mov (8|M0)               r100.0<1>:d   r25.0<1;1,0>:d                   {F@1}
        goto (8|M0)                          L34256                  L34384                
L34256:
        join (8|M0)                          L34384                                
L34272:
        cmp (8|M0)    (lt)f1.0   null<1>:ud    r21.0<1;1,0>:ud   0x20:uw              {I@5}
(f1.0)  add (8|M0)               acc0.0<1>:d   -r21.0<1;1,0>:d   32:w              
(~f1.0) add (8|M0)               acc2.0<1>:d   r21.0<1;1,0>:d    -32:w              
(f1.0)  shr (8|M0)               r59.0<1>:ud   r25.0<1;1,0>:ud   r21.0<1;1,0>:d  
(f1.0)  shl (8|M0)               r38.0<1>:d    r28.0<1;1,0>:d    acc0.0<1;1,0>:d 
(~f1.0) shr (8|M0)               r100.0<1>:ud  r28.0<1;1,0>:ud   acc2.0<1;1,0>:d 
(f1.0)  or (8|M0)                r100.0<1>:d   r59.0<1;1,0>:d    r38.0<1;1,0>:d   {I@2}
L34384:
        join (8|M0)                          L35048                                
L34400:
        and (8|M0)    (ne)f0.1   r37.0<1>:d    r43.0<1;1,0>:d    63:w              
        and (8|M0)               r81.0<1>:d    r100.0<1;1,0>:d   1:w               {Compacted,I@3}
(f0.1)  goto (8|M0)                          L34488                  L34488                
L34440:
        mov (8|M0)               r43.0<1>:d    -1:w                              
        mov (8|M0)               r50.0<1>:d    -1:w                              
        goto (8|M0)                          L34488                  L34672                
L34488:
        join (8|M0)                          L34672                                
L34504:
        cmp (8|M0)    (lt)f1.1   null<1>:ud    r37.0<1;1,0>:ud   0x20:uw              {I@7}
(f1.1)  goto (8|M0)                          L34608                  L34608                
L34536:
        add (8|M0)               acc0.0<1>:d   r37.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r6.4<1>:hf    -qnan(0x1FF):hf                             
        mov (8|M0)               r43.0<1>:d    0:w                              
        shl (8|M0)               r50.0<1>:d    r6.4<0;1,0>:w     acc0.0<1;1,0>:d  {F@1}
        goto (8|M0)                          L34608                  L34672                
L34608:
        join (8|M0)                          L34672                                
L34624:
(W)     mov (1|M0)               r6.4<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (8|M0)               r50.0<1>:d    -1:w                              
        shl (8|M0)               r43.0<1>:d    r6.4<0;1,0>:w     r37.0<1;1,0>:d   {F@1}
L34672:
        join (8|M0)                          L35048                                
L34688:
        bfn.0x60 (8|M0)          r58.0<1>:ud   r43.0<1;0>:ud     r7.4<0;0>:ud      r25.0<1>:ud      {I@2} // (s0^s1)&s2
        bfn.0x60 (8|M0)          r57.0<1>:ud   r50.0<1;0>:ud     r7.4<0;0>:ud      r28.0<1>:ud      // (s0^s1)&s2
        cmp (8|M0)    (ne)f0.1   null<1>:d     r58.0<1;1,0>:d    0:w               {I@2}
(W)     mov (1|M0)               r6.4<1>:hf    -qnan(0x1FF):hf                             
        and (8|M0)    (ne)f1.0   r20.0<1>:d    r75.0<1;1,0>:d    63:w              
(~f0.1) cmp (8|M0)    (ne)f0.1   null<1>:d     r57.0<1;1,0>:d    0:w               {I@3}
(f0.1)  sel (8|M0)               acc0.0<1>:d   r6.4<0;1,0>:w     0:w               {F@1}
        mov (8|M0)               r68.0<1>:d    -acc0.0<1;1,0>:d                
(f1.0)  goto (8|M0)                          L34864                  L34864                
L34832:
        mov (8|M0)               r100.0<1>:d   r25.0<1;1,0>:d                  
        goto (8|M0)                          L34864                  L34992                
L34864:
        join (8|M0)                          L34992                                
L34880:
        cmp (8|M0)    (lt)f0.1   null<1>:ud    r20.0<1;1,0>:ud   0x20:uw              {I@7}
(f0.1)  add (8|M0)               acc0.0<1>:d   -r20.0<1;1,0>:d   32:w              
(~f0.1) add (8|M0)               acc2.0<1>:d   r20.0<1;1,0>:d    -32:w              
(f0.1)  shr (8|M0)               r54.0<1>:ud   r25.0<1;1,0>:ud   r20.0<1;1,0>:d  
(f0.1)  shl (8|M0)               r35.0<1>:d    r28.0<1;1,0>:d    acc0.0<1;1,0>:d 
(~f0.1) shr (8|M0)               r100.0<1>:ud  r28.0<1;1,0>:ud   acc2.0<1;1,0>:d 
(f0.1)  or (8|M0)                r100.0<1>:d   r54.0<1;1,0>:d    r35.0<1;1,0>:d   {I@2}
L34992:
        join (8|M0)                          L35048                                
L35008:
        mov (8|M0)               r39.0<1>:f    r100.0<1;1,0>:f                  {Compacted,I@2}
        mov (8|M0)               r100.0<1>:d   r61.0<1;1,0>:d                   {F@1}
        goto (8|M0)                          L35048                  L35136                
L35048:
        join (8|M0)                          L35136                                
L35064:
        shr (8|M0)               r100.0<1>:ud  r25.0<1;1,0>:ud   2:w              
        mov (8|M0)               r68.0<1>:d    0:w                              
        mov (8|M0)               r81.0<1>:d    0:w                              
        mov (8|M0)               r39.0<1>:f    r100.0<1;1,0>:f                  {Compacted,I@3}
        shr (8|M0)               r100.0<1>:ud  r25.0<1;1,0>:ud   1:w               {F@1}
L35136:
        join (8|M0)                          L35680                                
L35152:
        shl (8|M0)               r126.0<1>:d   r100.0<1;1,0>:d   2:w               {Compacted,I@2}
        shl (8|M0)               r53.0<1>:d    r81.0<1;1,0>:d    1:w               {Compacted}
        and (8|M0)               r126.0<1>:d   r126.0<1;1,0>:d   4:w               {Compacted,I@2}
        and (8|M0)               r62.0<1>:d    r39.0<1;1,0>:d    8388607:d              
        bfn.0xFE (8|M0)          r84.0<1>:ud   r126.0<1;0>:ud    r53.0<1;0>:ud     r68.0<1>:ud      {I@2} // s0|s1|s2
        cmp (8|M0)    (eq)f1.1   null<1>:d     r84.0<1;1,0>:d    0:w               {I@1}
(~f1.1) goto (8|M0)                          L35272                  L35272                
L35240:
        mov (8|M0)               r83.0<1>:d    0:w                              
        goto (8|M0)                          L35272                  L35432                
L35272:
        join (8|M0)                          L35432                                
L35288:
        cmp (8|M0)    (gt)f1.0   null<1>:ud    r84.0<1;1,0>:ud   0x4:uw             
(~f1.0) goto (8|M0)                          L35352                  L35352                
L35320:
        mov (8|M0)               r83.0<1>:d    1:w                              
        goto (8|M0)                          L35352                  L35432                
L35352:
        join (8|M0)                          L35432                                
L35368:
        and (8|M0)    (ne)f1.1   null<1>:d     r39.0<1;1,0>:d    1:w              
(W)     mov (1|M0)               r6.4<1>:hf    0x1:hf                             
(f1.1)  cmp (8|M0)    (eq)f1.1   null<1>:d     r84.0<1;1,0>:d    4:w              
(f1.1)  sel (8|M0)               r83.0<1>:d    r6.4<0;1,0>:w     0:w               {F@1}
L35432:
        join (8|M0)                          L35680                                
L35448:
        add (8|M0)               r111.0<1>:d   r62.0<1;1,0>:d    r83.0<1;1,0>:d   {Compacted,I@2}
        add3 (8|M0)              r92.0<1>:d    r49.0<1;0>:d      r36.0<1;0>:d      -45:w              
        cmp (8|M0)    (gt)f1.0   null<1>:ud    r111.0<1;1,0>:ud  0x7FFFFF:ud              {I@2}
(f1.0)  sel (8|M0)               r100.0<1>:d   r92.0<1;1,0>:d    r73.0<1;1,0>:d   {I@2}
        cmp (8|M0)    (eq)f0.1   null<1>:d     r100.0<1;1,0>:d   255:w               {I@1}
(f0.1)  goto (8|M0)                          L35608                  L35608                
L35536:
(~f1.0) sel (8|M0)               r101.0<1>:d   r111.0<1;1,0>:d   0:w              
        and (8|M0)               r91.0<1>:d    r23.0<1;1,0>:d    -2147483648:d              
        shl (8|M0)               r52.0<1>:d    r100.0<1;1,0>:d   23:w               {Compacted}
        bfn.0xFE (8|M0)          r110.0<1>:ud  r91.0<1;0>:ud     r52.0<1;0>:ud     r101.0<1>:ud     {I@1} // s0|s1|s2
        goto (8|M0)                          L35608                  L36248                
L35608:
        join (8|M0)                          L35680                                
L35624:
        cmp (8|M0)    (gt)f1.0   null<1>:d     r23.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r6.2<1>:f     inf:f                               {Compacted}
(f1.0)  sel (8|M0)               r110.0<1>:f   r6.2<0;1,0>:f     -inf:f               {A@1}
        goto (8|M0)                          L35680                  L36248                
L35680:
        join (8|M0)                          L36000                                
L35696:
        and (8|M0)    (ne)f1.1   r105.0<1>:d   r36.0<1;1,0>:d    63:w              
(f1.1)  goto (8|M0)                          L35760                  L35760                
L35728:
        mov (8|M0)               r74.0<1>:d    -1:w                              
        goto (8|M0)                          L35760                  L35888                
L35760:
        join (8|M0)                          L35888                                
L35776:
        cmp (8|M0)    (lt)f1.0   null<1>:ud    r105.0<1;1,0>:ud  0x20:uw              {A@1}
(f1.0)  goto (8|M0)                          L35840                  L35840                
L35808:
        mov (8|M0)               r74.0<1>:d    0:w                              
        goto (8|M0)                          L35840                  L35888                
L35840:
        join (8|M0)                          L35888                                
L35856:
(W)     mov (1|M0)               r6.4<1>:hf    -qnan(0x1FF):hf                             
        shl (8|M0)               r74.0<1>:d    r6.4<0;1,0>:w     r105.0<1;1,0>:d  {F@1}
L35888:
        join (8|M0)                          L36000                                
L35904:
        bfn.0x60 (8|M0)          r82.0<1>:ud   r74.0<1;0>:ud     r7.4<0;0>:ud      r25.0<1>:ud      {I@2} // (s0^s1)&s2
        add (8|M0)               acc0.0<1>:d   -r36.0<1;1,0>:d   23:w               {Compacted}
        and (8|M0)               r90.0<1>:d    r23.0<1;1,0>:d    -2147483648:d              
        shl (8|M0)               r50.0<1>:d    r73.0<1;1,0>:d    23:w               {Compacted}
        shl (8|M0)               r82.0<1>:d    r82.0<1;1,0>:d    acc0.0<1;1,0>:d  {I@4}
        bfn.0xFE (8|M0)          r110.0<1>:ud  r90.0<1;0>:ud     r50.0<1;0>:ud     r82.0<1>:ud      {I@1} // s0|s1|s2
        goto (8|M0)                          L36000                  L36248                
L36000:
        join (8|M0)                          L36072                                
L36016:
        cmp (8|M0)    (gt)f0.1   null<1>:d     r23.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r6.2<1>:f     inf:f                               {Compacted}
(f0.1)  sel (8|M0)               r110.0<1>:f   r6.2<0;1,0>:f     -inf:f               {A@1}
        goto (8|M0)                          L36072                  L36248                
L36072:
        join (8|M0)                          L36144                                
L36088:
        cmp (8|M0)    (lt)f1.1   null<1>:d     r23.0<1;1,0>:d    0:w              
(W)     mov (1|M0)               r6.2<1>:f     -0.0:f                               {Compacted}
(f1.1)  sel (8|M0)               r110.0<1>:f   r6.2<0;1,0>:f     0.0:f               {F@1}
        goto (8|M0)                          L36144                  L36248                
L36144:
        join (8|M0)                          L36216                                
L36160:
        cmp (8|M0)    (gt)f1.0   null<1>:d     r23.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r6.2<1>:f     inf:f                               {Compacted}
(f1.0)  sel (8|M0)               r110.0<1>:f   r6.2<0;1,0>:f     -inf:f               {F@1}
        goto (8|M0)                          L36216                  L36248                
L36216:
        join (8|M0)                          L36248                                
L36232:
        bfn.0xF8 (8|M0)          r110.0<1>:ud  r23.0<1;0>:ud     r7.6<0;0>:ud      r7.5<0>:ud       {F@1} // s0&s1|s2
L36248:
        join (8|M0)                          L36464                                
L36264:
        cmp (8|M0)    (lt)f0.1   null<1>:f     r14.0<1;1,0>:f    0.0:f               {I@7}
        addc (8|M0)              r78.0<1>:ud   r13.0<1;1,0>:ud   r6.0<0;1,0>:ud   {AccWrEn,Compacted}
        shl (8|M0)               r76.0<1>:d    r11.0<1;1,0>:d    1:w               {Compacted}
        add3 (8|M0)              r89.0<1>:ud   acc0.0<1;0>:ud    r12.0<1;0>:ud     r6.1<0>:ud      
        addc (8|M0)              r88.0<1>:ud   r78.0<1;1,0>:ud   r76.0<1;1,0>:ud  {AccWrEn,Compacted,I@2}
        shr (8|M0)               r77.0<1>:ud   r11.0<1;1,0>:ud   31:w              
(f0.1)  sel (8|M0)               r49.0<1>:f    -r110.0<1;1,0>:f  r110.0<1;1,0>:f 
        mov (8|M0)               acc0.0<1>:ud  acc0.0<1;1,0>:ud                
        mov (8|M0)               r14.0<1>:hf   r49.0<1;1,0>:f                   {F@1}
        add3 (8|M0)              r31.0<1>:ud   acc0.0<1;0>:ud    r89.0<1;0>:ud     r77.0<1>:ud      {I@2}
        mov (8|M0)               r47.0<1>:ud   r14.0<1;1,0>:uw                  {F@1}
        mov (8|M0)               r58.1<2>:ud   r31.0<1;1,0>:ud                  {I@2}
        mov (8|M0)               r58.0<2>:d    r88.0<1;1,0>:d                  
        send.ugm (8|M0)          null     r58     r47:1   0x0            0x040E0B84           {A@1,$9} // wr:2+1, rd:0; store.ugm.d16u32.a64.wb.wb
L36464:
        join (8|M0)                          L36616                                
L36480:
        addc (8|M0)              r89.0<1>:ud   r10.0<1;1,0>:ud   r7.0<0;1,0>:ud   {AccWrEn,Compacted}
        cmp (8|M0)    (lt)f0.1   null<1>:ud    r89.0<1;1,0>:ud   r4.6<0;1,0>:ud   {I@1}
        add (8|M0)               r47.0<1>:ud   acc0.0<1;1,0>:ud  r9.0<1;1,0>:ud   {$9.src}
(f0.1)  cmp (8|M0)    (eq)f0.1   null<1>:d     r47.0<1;1,0>:d    r4.7<0;1,0>:d    {I@1}
(~f0.1) cmp (8|M0)    (lt)f0.1   null<1>:ud    r47.0<1;1,0>:ud   r4.7<0;1,0>:ud  
(~f0.1) goto (8|M0)                          L36616                  L36616                
L36568:
(f0.1)  sel (8|M0)               r10.0<1>:d    r89.0<1;1,0>:d    r8.0<1;1,0>:d   
(f0.1)  sel (8|M0)               r9.0<1>:d     r47.0<1;1,0>:d    r3.0<1;1,0>:d   
(W)     jmpi                                 L632                                
L36616:
        join (8|M0)                          L36632                                
L36632:
(W)     mov (8|M0)               r112.0<1>:f   r2.0<1;1,0>:f                    {Compacted}
(W)     send.gtwy (1|M0)         null     r112    null:0  0x0            0x02000010           {EOT,A@1} // wr:1+0, rd:0; end of thread
L36656:
(W)     mov (16|M0)              null<1>:ud    0x9E09665A:ud                             
(W)     mov (16|M0)              null<1>:ud    0xA6E09A48:ud                             
(W)     mov (16|M0)              null<1>:ud    0x0:ud                             
(W)     mov (16|M0)              null<1>:ud    0x6C:ud                             
L36720:
        shr (8|M0)               r45.0<1>:ud   r42.0<1;1,0>:ud   23:w              
        shr (8|M0)               r46.0<1>:ud   r56.0<1;1,0>:ud   23:w              
        and (8|M0)    (eq)f0.1   r77.0<1>:d    r45.0<1;1,0>:d    255:w               {I@2}
        and (8|M0)               r100.0<1>:d   r56.0<1;1,0>:d    8388607:d              
        and (8|M0)               r91.0<1>:d    r42.0<1;1,0>:d    8388607:d              
        shr (8|M0)               r99.0<1>:ud   r56.0<1;1,0>:ud   31:w              
        cmp (8|M0)    (eq)f1.1   null<1>:d     r77.0<1;1,0>:d    0:w               {I@4}
        shr (8|M0)               r105.0<1>:ud  r42.0<1;1,0>:ud   31:w              
        and (8|M0)               r69.0<1>:d    r46.0<1;1,0>:d    255:w               {Compacted}
(f1.1)  goto (8|M0)                          L36928                  L36928                
L36872:
(W)     mov (1|M0)               r6.16<2>:b    1:w                              
        add (8|M0)               r52.0<1>:d    r69.0<1;1,0>:d    -r77.0<1;1,0>:d  {Compacted,I@3}
        mov (8|M0)               r12.0<1>:b    r6.16<0;1,0>:b                   {I@2}
        goto (8|M0)                          L36928                  L37016                
L36928:
        join (8|M0)                          L37016                                
L36944:
        cmp (8|M0)    (eq)f1.0   null<1>:d     r69.0<1;1,0>:d    0:w              
(f1.0)  goto (8|M0)                          L37016                  L43488                
L36976:
(W)     mov (1|M0)               r6.16<2>:b    0:w                              
        add (8|M0)               r52.0<1>:d    r69.0<1;1,0>:d    -1:w               {Compacted}
        mov (8|M0)               r12.0<1>:b    r6.16<0;1,0>:b                   {I@2}
L37016:
        join (8|M0)                          L43488                                
L37032:
        cmp (8|M0)    (eq)f1.1   null<1>:d     r52.0<1;1,0>:d    0:w               {I@3}
(f1.1)  goto (8|M0)                          L40976                  L40976                
L37064:
        cmp (8|M0)    (ne)f1.0   null<1>:d     r52.0<1;1,0>:d    1:w              
(f1.0)  goto (8|M0)                          L37224                  L37224                
L37096:
        shr (8|M0)               r104.0<1>:ud  r91.0<1;1,0>:ud   1:w              
        cmp (8|M0)    (eq)f1.1   r44.0<1>:d    r77.0<1;1,0>:d    0:w              
        and (8|M0)               r72.0<1>:d    r42.0<1;1,0>:d    1:w               {Compacted}
        or (8|M0)                r115.0<1>:d   r104.0<1;1,0>:d   4194304:d               {I@3}
        mov (8|M0)               r81.0<1>:d    0:w                              
        mov (8|M0)               r83.0<1>:f    r72.0<1;1,0>:f                   {Compacted,I@3}
        bfn.0xD8 (8|M0)          r82.0<1>:ud   r44.0<1;0>:ud     r104.0<1;0>:ud    r115.0<1>:ud     {I@2} // s0&s1|~s0&s2
        mov (8|M0)               r72.0<1>:d    0:w                               {F@1}
        goto (8|M0)                          L37224                  L37920                
L37224:
        join (8|M0)                          L37920                                
L37240:
        cmp (8|M0)    (lt)f1.1   null<1>:ud    r52.0<1;1,0>:ud   0x18:uw             
(f1.1)  goto (8|M0)                          L37656                  L37656                
L37272:
        cmp (8|M0)    (lt)f1.0   null<1>:d     r52.0<1;1,0>:d    25:w              
        mov (8|M0)               r72.0<1>:d    r12.0<1;1,0>:ub                 
(f1.0)  goto (8|M0)                          L37416                  L37416                
L37320:
        cmp (8|M0)    (eq)f1.1   null<1>:d     r52.0<1;1,0>:d    25:w              
(~f1.1) goto (8|M0)                          L37416                  L37560                
L37352:
        cmp (8|M0)    (ne)f1.0   r81.0<1>:d    r91.0<1;1,0>:d    0:w              
        mov (8|M0)               r83.0<1>:d    0:w                              
        mov (8|M0)               r82.0<1>:d    0:w                              
        goto (8|M0)                          L37416                  L37920                
L37416:
        join (8|M0)                          L37560                                
L37432:
        cmp (8|M0)    (eq)f1.0   null<1>:d     r52.0<1;1,0>:d    24:w              
(~f1.0) goto (8|M0)                          L37560                  L37560                
L37464:
        shr (8|M0)               r114.0<1>:ud  r42.0<1;1,0>:ud   22:w              
        and (8|M0)               r43.0<1>:d    r42.0<1;1,0>:d    4194303:d              
        mov (8|M0)               r83.0<1>:f    r72.0<1;1,0>:f                   {Compacted,I@7}
        mov (8|M0)               r82.0<1>:d    0:w                              
        cmp (8|M0)    (ne)f1.1   r81.0<1>:d    r43.0<1;1,0>:d    0:w               {I@2}
        and (8|M0)               r72.0<1>:d    r114.0<1;1,0>:d   1:w               {Compacted,F@1}
        goto (8|M0)                          L37560                  L37920                
L37560:
        join (8|M0)                          L37656                                
L37576:
        cmp (8|M0)    (ne)f1.0   r81.0<1>:d    r42.0<1;1,0>:d    0:w              
        mov (8|M0)               r72.0<1>:d    0:w                              
        mov (8|M0)               r83.0<1>:d    0:w                              
        mov (8|M0)               r82.0<1>:d    0:w                              
        goto (8|M0)                          L37656                  L37920                
L37656:
        join (8|M0)                          L37920                                
L37672:
        add (8|M0)               acc0.0<1>:d   r52.0<1;1,0>:d    -2:w               {Compacted}
(W)     mov (1|M0)               r6.8<1>:hf    -qnan(0x1FF):hf                             
        add (8|M0)               acc2.0<1>:d   r52.0<1;1,0>:d    -1:w               {Compacted}
        cmp (8|M0)    (eq)f1.1   null<1>:d     r77.0<1;1,0>:d    0:w              
        shr (8|M0)               r118.0<1>:ud  r91.0<1;1,0>:ud   acc0.0<1;1,0>:d 
        shl (8|M0)               r85.0<1>:d    r6.8<0;1,0>:w     acc0.0<1;1,0>:d  {F@1}
(W)     mov (1|M0)               r6.4<1>:d     -1:w                              
        add (8|M0)               acc0.0<1>:d   -r52.0<1;1,0>:d   23:w               {Compacted}
        shr (8|M0)               r93.0<1>:ud   r91.0<1;1,0>:ud   acc2.0<1;1,0>:d 
        bfn.0x60 (8|M0)          r117.0<1>:ud  r85.0<1;0>:ud     r6.4<0;0>:ud      r91.0<1>:ud      {I@3} // (s0^s1)&s2
(W)     mov (1|M0)               r6.8<1>:hf    0x1:hf                              {I@1}
        shr (8|M0)               r116.0<1>:ud  r91.0<1;1,0>:ud   r52.0<1;1,0>:d  
        and (8|M0)               r72.0<1>:d    r93.0<1;1,0>:d    1:w               {Compacted}
        shl (8|M0)               r80.0<1>:d    r6.8<0;1,0>:w     acc0.0<1;1,0>:d  {F@1}
(f1.1)  mov (8|M0)               r80.0<1>:d    0:w                              
        mov (8|M0)               r83.0<1>:f    r72.0<1;1,0>:f                   {Compacted,I@3}
        cmp (8|M0)    (ne)f1.1   r81.0<1>:d    r117.0<1;1,0>:d   0:w              
        or (8|M0)                r82.0<1>:d    r116.0<1;1,0>:d   r80.0<1;1,0>:d   {Compacted,I@2}
        and (8|M0)               r72.0<1>:d    r118.0<1;1,0>:d   1:w               {Compacted,F@1}
L37920:
        join (8|M0)                          L40976                                
L37936:
        cmp (8|M0)    (ne)f1.0   r98.0<1>:d    r81.0<1;1,0>:d    0:w               {I@4}
        shl (8|M0)               r95.0<1>:d    r82.0<1;1,0>:d    3:w               {Compacted,I@4}
        shl (8|M0)               r42.0<1>:d    r83.0<1;1,0>:d    2:w               {Compacted}
        shl (8|M0)               r41.0<1>:d    r72.0<1;1,0>:d    1:w               {Compacted,I@5}
        mov (8|M0)               r98.0<1>:d    -r98.0<1;1,0>:d                  {I@4}
        or (8|M0)                r95.0<1>:d    r95.0<1;1,0>:d    r42.0<1;1,0>:d   {Compacted,I@3}
        shl (8|M0)               r97.0<1>:d    r100.0<1;1,0>:d   3:w               {Compacted}
        bfn.0xFE (8|M0)          r91.0<1>:ud   r95.0<1;0>:ud     r41.0<1;0>:ud     r98.0<1>:ud      {I@2} // s0|s1|s2
        cmp (8|M0)    (lt)f1.0   null<1>:ud    r97.0<1;1,0>:ud   r91.0<1;1,0>:ud  {I@1}
(f1.0)  goto (8|M0)                          L38104                  L38104                
L38056:
        add (8|M0)               r100.0<1>:d   r97.0<1;1,0>:d    -r91.0<1;1,0>:d  {Compacted}
        and (8|M0)               r84.0<1>:d    r100.0<1;1,0>:d   7:w               {Compacted,I@1}
        shr (8|M0)               r96.0<1>:ud   r100.0<1;1,0>:ud  3:w              
        goto (8|M0)                          L38104                  L40584                
L38104:
        join (8|M0)                          L40584                                
L38120:
        or (8|M0)                acc0.0<1>:d   r97.0<1;1,0>:d    67108864:d              
        add (8|M0)               r43.0<1>:d    acc0.0<1;1,0>:d   -r91.0<1;1,0>:d 
        and (8|M0)    (eq)f1.1   null<1>:d     r43.0<1;1,0>:d    33554432:d               {I@1}
(~f1.1) goto (8|M0)                          L40168                  L40168                
L38184:
        and (8|M0)    (eq)f1.0   null<1>:d     r43.0<1;1,0>:d    16777216:d              
(~f1.0) goto (8|M0)                          L40120                  L40120                
L38216:
        and (8|M0)    (eq)f1.1   null<1>:d     r43.0<1;1,0>:d    8388608:d              
(~f1.1) goto (8|M0)                          L40072                  L40072                
L38248:
        and (8|M0)    (eq)f1.0   null<1>:d     r43.0<1;1,0>:d    4194304:d              
(~f1.0) goto (8|M0)                          L40024                  L40024                
L38280:
        and (8|M0)    (eq)f1.1   null<1>:d     r43.0<1;1,0>:d    2097152:d              
(~f1.1) goto (8|M0)                          L39976                  L39976                
L38312:
        and (8|M0)    (eq)f1.0   null<1>:d     r43.0<1;1,0>:d    1048576:d              
(~f1.0) goto (8|M0)                          L39928                  L39928                
L38344:
        and (8|M0)    (eq)f1.1   null<1>:d     r43.0<1;1,0>:d    524288:d              
(~f1.1) goto (8|M0)                          L39880                  L39880                
L38376:
        and (8|M0)    (eq)f1.0   null<1>:d     r43.0<1;1,0>:d    262144:d              
(~f1.0) goto (8|M0)                          L39832                  L39832                
L38408:
        and (8|M0)    (eq)f1.1   null<1>:d     r43.0<1;1,0>:d    131072:d              
(~f1.1) goto (8|M0)                          L39784                  L39784                
L38440:
        and (8|M0)    (eq)f1.0   null<1>:d     r43.0<1;1,0>:d    65536:d              
(~f1.0) goto (8|M0)                          L39736                  L39736                
L38472:
        and (8|M0)    (eq)f1.1   null<1>:d     r43.0<1;1,0>:d    0x8000:uw             
(~f1.1) goto (8|M0)                          L39688                  L39688                
L38504:
        and (8|M0)    (eq)f1.0   null<1>:d     r43.0<1;1,0>:d    16384:w              
(~f1.0) goto (8|M0)                          L39640                  L39640                
L38536:
        and (8|M0)    (eq)f1.1   null<1>:d     r43.0<1;1,0>:d    8192:w              
(~f1.1) goto (8|M0)                          L39592                  L39592                
L38568:
        and (8|M0)    (eq)f1.0   null<1>:d     r43.0<1;1,0>:d    4096:w              
(~f1.0) goto (8|M0)                          L39544                  L39544                
L38600:
        and (8|M0)    (eq)f1.1   null<1>:d     r43.0<1;1,0>:d    2048:w              
(~f1.1) goto (8|M0)                          L39496                  L39496                
L38632:
        and (8|M0)    (eq)f1.0   null<1>:d     r43.0<1;1,0>:d    1024:w              
(~f1.0) goto (8|M0)                          L39448                  L39448                
L38664:
        and (8|M0)    (eq)f1.1   null<1>:d     r43.0<1;1,0>:d    512:w              
(~f1.1) goto (8|M0)                          L39400                  L39400                
L38696:
        and (8|M0)    (eq)f1.0   null<1>:d     r43.0<1;1,0>:d    256:w              
(~f1.0) goto (8|M0)                          L39352                  L39352                
L38728:
        and (8|M0)    (eq)f1.1   null<1>:d     r43.0<1;1,0>:d    128:w              
(~f1.1) goto (8|M0)                          L39304                  L39304                
L38760:
        and (8|M0)    (eq)f1.0   null<1>:d     r43.0<1;1,0>:d    64:w              
(~f1.0) goto (8|M0)                          L39256                  L39256                
L38792:
        and (8|M0)    (eq)f1.1   null<1>:d     r43.0<1;1,0>:d    32:w              
(~f1.1) goto (8|M0)                          L39208                  L39208                
L38824:
        and (8|M0)    (eq)f1.0   null<1>:d     r43.0<1;1,0>:d    16:w              
(~f1.0) goto (8|M0)                          L39160                  L39160                
L38856:
        and (8|M0)    (eq)f1.1   null<1>:d     r43.0<1;1,0>:d    8:w              
(~f1.1) goto (8|M0)                          L39112                  L39112                
L38888:
        and (8|M0)    (eq)f1.0   null<1>:d     r43.0<1;1,0>:d    4:w              
(~f1.0) goto (8|M0)                          L39064                  L39064                
L38920:
        and (8|M0)    (eq)f1.1   null<1>:d     r43.0<1;1,0>:d    2:w              
(~f1.1) goto (8|M0)                          L39016                  L39016                
L38952:
        and (8|M0)    (eq)f1.0   null<1>:d     r43.0<1;1,0>:d    1:w              
(W)     mov (1|M0)               r6.8<1>:hf    -qnan(0x1FF):hf                             
(f1.0)  sel (8|M0)               r45.0<1>:d    r6.8<0;1,0>:w     25:w               {F@1}
        goto (8|M0)                          L39016                  L40200                
L39016:
        join (8|M0)                          L39064                                
L39032:
        mov (8|M0)               r45.0<1>:d    24:w                              
        goto (8|M0)                          L39064                  L40200                
L39064:
        join (8|M0)                          L39112                                
L39080:
        mov (8|M0)               r45.0<1>:d    23:w                              
        goto (8|M0)                          L39112                  L40200                
L39112:
        join (8|M0)                          L39160                                
L39128:
        mov (8|M0)               r45.0<1>:d    22:w                              
        goto (8|M0)                          L39160                  L40200                
L39160:
        join (8|M0)                          L39208                                
L39176:
        mov (8|M0)               r45.0<1>:d    21:w                              
        goto (8|M0)                          L39208                  L40200                
L39208:
        join (8|M0)                          L39256                                
L39224:
        mov (8|M0)               r45.0<1>:d    20:w                              
        goto (8|M0)                          L39256                  L40200                
L39256:
        join (8|M0)                          L39304                                
L39272:
        mov (8|M0)               r45.0<1>:d    19:w                              
        goto (8|M0)                          L39304                  L40200                
L39304:
        join (8|M0)                          L39352                                
L39320:
        mov (8|M0)               r45.0<1>:d    18:w                              
        goto (8|M0)                          L39352                  L40200                
L39352:
        join (8|M0)                          L39400                                
L39368:
        mov (8|M0)               r45.0<1>:d    17:w                              
        goto (8|M0)                          L39400                  L40200                
L39400:
        join (8|M0)                          L39448                                
L39416:
        mov (8|M0)               r45.0<1>:d    16:w                              
        goto (8|M0)                          L39448                  L40200                
L39448:
        join (8|M0)                          L39496                                
L39464:
        mov (8|M0)               r45.0<1>:d    15:w                              
        goto (8|M0)                          L39496                  L40200                
L39496:
        join (8|M0)                          L39544                                
L39512:
        mov (8|M0)               r45.0<1>:d    14:w                              
        goto (8|M0)                          L39544                  L40200                
L39544:
        join (8|M0)                          L39592                                
L39560:
        mov (8|M0)               r45.0<1>:d    13:w                              
        goto (8|M0)                          L39592                  L40200                
L39592:
        join (8|M0)                          L39640                                
L39608:
        mov (8|M0)               r45.0<1>:d    12:w                              
        goto (8|M0)                          L39640                  L40200                
L39640:
        join (8|M0)                          L39688                                
L39656:
        mov (8|M0)               r45.0<1>:d    11:w                              
        goto (8|M0)                          L39688                  L40200                
L39688:
        join (8|M0)                          L39736                                
L39704:
        mov (8|M0)               r45.0<1>:d    10:w                              
        goto (8|M0)                          L39736                  L40200                
L39736:
        join (8|M0)                          L39784                                
L39752:
        mov (8|M0)               r45.0<1>:d    9:w                              
        goto (8|M0)                          L39784                  L40200                
L39784:
        join (8|M0)                          L39832                                
L39800:
        mov (8|M0)               r45.0<1>:d    8:w                              
        goto (8|M0)                          L39832                  L40200                
L39832:
        join (8|M0)                          L39880                                
L39848:
        mov (8|M0)               r45.0<1>:d    7:w                              
        goto (8|M0)                          L39880                  L40200                
L39880:
        join (8|M0)                          L39928                                
L39896:
        mov (8|M0)               r45.0<1>:d    6:w                              
        goto (8|M0)                          L39928                  L40200                
L39928:
        join (8|M0)                          L39976                                
L39944:
        mov (8|M0)               r45.0<1>:d    5:w                              
        goto (8|M0)                          L39976                  L40200                
L39976:
        join (8|M0)                          L40024                                
L39992:
        mov (8|M0)               r45.0<1>:d    4:w                              
        goto (8|M0)                          L40024                  L40200                
L40024:
        join (8|M0)                          L40072                                
L40040:
        mov (8|M0)               r45.0<1>:d    3:w                              
        goto (8|M0)                          L40072                  L40200                
L40072:
        join (8|M0)                          L40120                                
L40088:
        mov (8|M0)               r45.0<1>:d    2:w                              
        goto (8|M0)                          L40120                  L40200                
L40120:
        join (8|M0)                          L40168                                
L40136:
        mov (8|M0)               r45.0<1>:d    1:w                              
        goto (8|M0)                          L40168                  L40200                
L40168:
        join (8|M0)                          L40200                                
L40184:
        mov (8|M0)               r45.0<1>:d    0:w                              
L40200:
        join (8|M0)                          L40584                                
L40216:
        cmp (8|M0)    (ne)f1.0   null<1>:d     r52.0<1;1,0>:d    1:w              
(W)     mov (1|M0)               r6.8<1>:hf    0x1:hf                             
(f0.1)  sel (8|M0)               r12.0<1>:uw   r6.8<0;1,0>:uw    0x0:uw              {F@1}
(f1.0)  sel (8|M0)               r24.0<1>:uw   r6.8<0;1,0>:uw    0x0:uw             
        or (8|M0)     (ne)f1.0   null<1>:uw    r24.0<1;1,0>:uw   r12.0<1;1,0>:uw  {I@1}
(f1.0)  goto (8|M0)                          L40512                  L40512                
L40312:
        add (8|M0)               r44.0<1>:d    r45.0<1;1,0>:d    1:w               {Compacted}
        add (8|M0)               acc0.0<1>:d   r69.0<1;1,0>:d    -1:w               {Compacted}
        cmp (8|M0)    (gt)f0.1   null<1>:ud    r69.0<1;1,0>:ud   r44.0<1;1,0>:ud  {I@2}
        not (8|M0)               acc2.0<1>:d   r45.0<1;1,0>:d                  
        and (8|M0)               r110.0<1>:d   r56.0<1;1,0>:d    -2147483648:d              
        add (8|M0)               acc2.0<1>:d   r69.0<1;1,0>:d    acc2.0<1;1,0>:d 
(~f0.1) mov (8|M0)               r44.0<1>:d    acc0.0<1;1,0>:d                 
        shl (8|M0)               r40.0<1>:d    acc2.0<1;1,0>:d   23:w              
        shl (8|M0)               r44.0<1>:d    r43.0<1;1,0>:d    r44.0<1;1,0>:d   {Compacted,I@2}
(~f0.1) mov (8|M0)               r40.0<1>:d    0:w                              
        shr (8|M0)               r44.0<1>:ud   r44.0<1;1,0>:ud   3:w               {I@2}
        and (8|M0)               r44.0<1>:d    r44.0<1;1,0>:d    8388607:d               {I@1}
        bfn.0xFE (8|M0)          r44.0<1>:ud   r110.0<1;0>:ud    r40.0<1;0>:ud     r44.0<1>:ud      {I@1} // s0|s1|s2
        goto (8|M0)                          L40512                  L43600                
L40512:
        join (8|M0)                          L40584                                
L40528:
        shr (8|M0)               r39.0<1>:ud   r43.0<1;1,0>:ud   2:w              
        shl (8|M0)               r38.0<1>:d    r43.0<1;1,0>:d    1:w               {Compacted}
        add (8|M0)               r69.0<1>:d    r69.0<1;1,0>:d    -1:w               {Compacted}
        and (8|M0)               r96.0<1>:d    r39.0<1;1,0>:d    8388607:d               {I@3}
        and (8|M0)               r84.0<1>:d    r38.0<1;1,0>:d    6:w               {Compacted,I@3}
L40584:
        join (8|M0)                          L40976                                
L40600:
        cmp (8|M0)    (eq)f1.0   null<1>:d     r84.0<1;1,0>:d    0:w               {I@2}
(f1.0)  goto (8|M0)                          L40792                  L40792                
L40632:
        cmp (8|M0)    (gt)f0.1   null<1>:ud    r84.0<1;1,0>:ud   0x4:uw             
(f0.1)  goto (8|M0)                          L40744                  L40744                
L40664:
        and (8|M0)    (ne)f1.0   null<1>:d     r96.0<1;1,0>:d    1:w              
(W)     mov (1|M0)               r6.8<1>:hf    0x1:hf                             
(f1.0)  cmp (8|M0)    (eq)f1.0   null<1>:d     r84.0<1;1,0>:d    4:w              
(f1.0)  sel (8|M0)               r89.0<1>:d    r6.8<0;1,0>:w     0:w               {F@1}
        goto (8|M0)                          L40744                  L40824                
L40744:
        join (8|M0)                          L40792                                
L40760:
        mov (8|M0)               r89.0<1>:d    1:w                              
        goto (8|M0)                          L40792                  L40824                
L40792:
        join (8|M0)                          L40824                                
L40808:
        mov (8|M0)               r89.0<1>:d    0:w                              
L40824:
        join (8|M0)                          L40976                                
L40840:
        add (8|M0)               r88.0<1>:d    r96.0<1;1,0>:d    r89.0<1;1,0>:d   {Compacted,I@2}
        and (8|M0)               r109.0<1>:d   r56.0<1;1,0>:d    -2147483648:d              
        cmp (8|M0)    (gt)f1.1   null<1>:ud    r88.0<1;1,0>:ud   0x7FFFFF:ud              {I@2}
(~f1.1) sel (8|M0)               r113.0<1>:d   r88.0<1;1,0>:d    0:w              
        cmp (8|M0)    (gt)f1.1   r37.0<1>:ud   r88.0<1;1,0>:ud   0x7FFFFF:ud             
        add3 (8|M0)              acc0.0<1>:d   r69.0<1;0>:d      -r37.0<1;0>:d     0:w               {I@1}
        shl (8|M0)               r87.0<1>:d    acc0.0<1;1,0>:d   23:w              
        bfn.0xFE (8|M0)          r44.0<1>:ud   r109.0<1;0>:ud    r87.0<1;0>:ud     r113.0<1>:ud     {I@1} // s0|s1|s2
        goto (8|M0)                          L40976                  L43600                
L40976:
        join (8|M0)                          L43488                                
L40992:
        cmp (8|M0)    (eq)f1.1   null<1>:d     r100.0<1;1,0>:d   r91.0<1;1,0>:d  
(W)     mov (1|M0)               r6.6<1>:f     -0.0:f                               {Compacted}
(W)     mov (1|M0)               r6.5<1>:d     8388608:d                              
(f1.1)  goto (8|M0)                          L43408                  L43408                
L41048:
        cmp (8|M0)    (gt)f1.0   null<1>:ud    r100.0<1;1,0>:ud  r91.0<1;1,0>:ud 
(f1.0)  goto (8|M0)                          L41224                  L41224                
L41080:
        cmp (8|M0)    (eq)f0.1   null<1>:d     r77.0<1;1,0>:d    0:w              
(f0.1)  goto (8|M0)                          L41144                  L41144                
L41112:
        add (8|M0)               r46.0<1>:d    r91.0<1;1,0>:d    -r100.0<1;1,0>:d {Compacted}
        mov (8|M0)               r99.0<1>:f    r105.0<1;1,0>:f                  {Compacted}
        goto (8|M0)                          L41144                  L41328                
L41144:
        join (8|M0)                          L41224                                
L41160:
        or (8|M0)                acc0.0<1>:d   r100.0<1;1,0>:d   8388608:d              
        add (8|M0)               r90.0<1>:d    acc0.0<1;1,0>:d   -r91.0<1;1,0>:d 
        bfn.0xF8 (8|M0)          r44.0<1>:ud   r56.0<1;0>:ud     r6.6<0;0>:ud      r90.0<1>:ud      {A@1} // s0&s1|s2
        goto (8|M0)                          L41224                  L43600                
L41224:
        join (8|M0)                          L41328                                
L41240:
        cmp (8|M0)    (eq)f1.1   null<1>:d     r77.0<1;1,0>:d    0:w              
        add (8|M0)               r46.0<1>:d    r100.0<1;1,0>:d   -r91.0<1;1,0>:d  {Compacted}
(~f1.1) goto (8|M0)                          L41328                  L41328                
L41280:
        and (8|M0)               r36.0<1>:d    r56.0<1;1,0>:d    -2147483648:d              
        bfn.0xFE (8|M0)          r44.0<1>:ud   r36.0<1;0>:ud     r46.0<1;0>:ud     r6.5<0>:ud       {I@1} // s0|s1|s2
        goto (8|M0)                          L41328                  L43600                
L41328:
        join (8|M0)                          L43408                                
L41344:
        and (8|M0)    (eq)f1.0   null<1>:d     r46.0<1;1,0>:d    4194304:d              
(~f1.0) goto (8|M0)                          L43120                  L43120                
L41376:
        and (8|M0)    (eq)f0.1   null<1>:d     r46.0<1;1,0>:d    2097152:d              
(~f0.1) goto (8|M0)                          L43072                  L43072                
L41408:
        and (8|M0)    (eq)f1.1   null<1>:d     r46.0<1;1,0>:d    1048576:d              
(~f1.1) goto (8|M0)                          L43024                  L43024                
L41440:
        and (8|M0)    (eq)f1.0   null<1>:d     r46.0<1;1,0>:d    524288:d              
(~f1.0) goto (8|M0)                          L42976                  L42976                
L41472:
        and (8|M0)    (eq)f0.1   null<1>:d     r46.0<1;1,0>:d    262144:d              
(~f0.1) goto (8|M0)                          L42928                  L42928                
L41504:
        and (8|M0)    (eq)f1.1   null<1>:d     r46.0<1;1,0>:d    131072:d              
(~f1.1) goto (8|M0)                          L42880                  L42880                
L41536:
        and (8|M0)    (eq)f1.0   null<1>:d     r46.0<1;1,0>:d    65536:d              
(~f1.0) goto (8|M0)                          L42832                  L42832                
L41568:
        and (8|M0)    (eq)f0.1   null<1>:d     r46.0<1;1,0>:d    0x8000:uw             
(~f0.1) goto (8|M0)                          L42784                  L42784                
L41600:
        and (8|M0)    (eq)f1.1   null<1>:d     r46.0<1;1,0>:d    16384:w              
(~f1.1) goto (8|M0)                          L42736                  L42736                
L41632:
        and (8|M0)    (eq)f1.0   null<1>:d     r46.0<1;1,0>:d    8192:w              
(~f1.0) goto (8|M0)                          L42688                  L42688                
L41664:
        and (8|M0)    (eq)f0.1   null<1>:d     r46.0<1;1,0>:d    4096:w              
(~f0.1) goto (8|M0)                          L42640                  L42640                
L41696:
        and (8|M0)    (eq)f1.1   null<1>:d     r46.0<1;1,0>:d    2048:w              
(~f1.1) goto (8|M0)                          L42592                  L42592                
L41728:
        and (8|M0)    (eq)f1.0   null<1>:d     r46.0<1;1,0>:d    1024:w              
(~f1.0) goto (8|M0)                          L42544                  L42544                
L41760:
        and (8|M0)    (eq)f0.1   null<1>:d     r46.0<1;1,0>:d    512:w              
(~f0.1) goto (8|M0)                          L42496                  L42496                
L41792:
        and (8|M0)    (eq)f1.1   null<1>:d     r46.0<1;1,0>:d    256:w              
(~f1.1) goto (8|M0)                          L42448                  L42448                
L41824:
        and (8|M0)    (eq)f1.0   null<1>:d     r46.0<1;1,0>:d    128:w              
(~f1.0) goto (8|M0)                          L42400                  L42400                
L41856:
        and (8|M0)    (eq)f0.1   null<1>:d     r46.0<1;1,0>:d    64:w              
(~f0.1) goto (8|M0)                          L42352                  L42352                
L41888:
        and (8|M0)    (eq)f1.1   null<1>:d     r46.0<1;1,0>:d    32:w              
(~f1.1) goto (8|M0)                          L42304                  L42304                
L41920:
        and (8|M0)    (eq)f1.0   null<1>:d     r46.0<1;1,0>:d    16:w              
(~f1.0) goto (8|M0)                          L42256                  L42256                
L41952:
        and (8|M0)    (eq)f0.1   null<1>:d     r46.0<1;1,0>:d    8:w              
(~f0.1) goto (8|M0)                          L42208                  L42208                
L41984:
        and (8|M0)    (eq)f1.1   null<1>:d     r46.0<1;1,0>:d    4:w              
(~f1.1) goto (8|M0)                          L42160                  L42160                
L42016:
        and (8|M0)    (eq)f1.0   null<1>:d     r46.0<1;1,0>:d    2:w              
(~f1.0) goto (8|M0)                          L42112                  L42112                
L42048:
        and (8|M0)    (eq)f1.0   null<1>:d     r46.0<1;1,0>:d    1:w              
(W)     mov (1|M0)               r6.8<1>:hf    -qnan(0x1FF):hf                             
(f1.0)  sel (8|M0)               r55.0<1>:d    r6.8<0;1,0>:w     22:w               {F@1}
        goto (8|M0)                          L42112                  L43152                
L42112:
        join (8|M0)                          L42160                                
L42128:
        mov (8|M0)               r55.0<1>:d    21:w                              
        goto (8|M0)                          L42160                  L43152                
L42160:
        join (8|M0)                          L42208                                
L42176:
        mov (8|M0)               r55.0<1>:d    20:w                              
        goto (8|M0)                          L42208                  L43152                
L42208:
        join (8|M0)                          L42256                                
L42224:
        mov (8|M0)               r55.0<1>:d    19:w                              
        goto (8|M0)                          L42256                  L43152                
L42256:
        join (8|M0)                          L42304                                
L42272:
        mov (8|M0)               r55.0<1>:d    18:w                              
        goto (8|M0)                          L42304                  L43152                
L42304:
        join (8|M0)                          L42352                                
L42320:
        mov (8|M0)               r55.0<1>:d    17:w                              
        goto (8|M0)                          L42352                  L43152                
L42352:
        join (8|M0)                          L42400                                
L42368:
        mov (8|M0)               r55.0<1>:d    16:w                              
        goto (8|M0)                          L42400                  L43152                
L42400:
        join (8|M0)                          L42448                                
L42416:
        mov (8|M0)               r55.0<1>:d    15:w                              
        goto (8|M0)                          L42448                  L43152                
L42448:
        join (8|M0)                          L42496                                
L42464:
        mov (8|M0)               r55.0<1>:d    14:w                              
        goto (8|M0)                          L42496                  L43152                
L42496:
        join (8|M0)                          L42544                                
L42512:
        mov (8|M0)               r55.0<1>:d    13:w                              
        goto (8|M0)                          L42544                  L43152                
L42544:
        join (8|M0)                          L42592                                
L42560:
        mov (8|M0)               r55.0<1>:d    12:w                              
        goto (8|M0)                          L42592                  L43152                
L42592:
        join (8|M0)                          L42640                                
L42608:
        mov (8|M0)               r55.0<1>:d    11:w                              
        goto (8|M0)                          L42640                  L43152                
L42640:
        join (8|M0)                          L42688                                
L42656:
        mov (8|M0)               r55.0<1>:d    10:w                              
        goto (8|M0)                          L42688                  L43152                
L42688:
        join (8|M0)                          L42736                                
L42704:
        mov (8|M0)               r55.0<1>:d    9:w                              
        goto (8|M0)                          L42736                  L43152                
L42736:
        join (8|M0)                          L42784                                
L42752:
        mov (8|M0)               r55.0<1>:d    8:w                              
        goto (8|M0)                          L42784                  L43152                
L42784:
        join (8|M0)                          L42832                                
L42800:
        mov (8|M0)               r55.0<1>:d    7:w                              
        goto (8|M0)                          L42832                  L43152                
L42832:
        join (8|M0)                          L42880                                
L42848:
        mov (8|M0)               r55.0<1>:d    6:w                              
        goto (8|M0)                          L42880                  L43152                
L42880:
        join (8|M0)                          L42928                                
L42896:
        mov (8|M0)               r55.0<1>:d    5:w                              
        goto (8|M0)                          L42928                  L43152                
L42928:
        join (8|M0)                          L42976                                
L42944:
        mov (8|M0)               r55.0<1>:d    4:w                              
        goto (8|M0)                          L42976                  L43152                
L42976:
        join (8|M0)                          L43024                                
L42992:
        mov (8|M0)               r55.0<1>:d    3:w                              
        goto (8|M0)                          L43024                  L43152                
L43024:
        join (8|M0)                          L43072                                
L43040:
        mov (8|M0)               r55.0<1>:d    2:w                              
        goto (8|M0)                          L43072                  L43152                
L43072:
        join (8|M0)                          L43120                                
L43088:
        mov (8|M0)               r55.0<1>:d    1:w                              
        goto (8|M0)                          L43120                  L43152                
L43120:
        join (8|M0)                          L43152                                
L43136:
        mov (8|M0)               r55.0<1>:d    0:w                              
L43152:
        join (8|M0)                          L43408                                
L43168:
        add (8|M0)               r103.0<1>:d   r55.0<1;1,0>:d    1:w               {Compacted,I@2}
        cmp (8|M0)    (gt)f0.1   null<1>:ud    r69.0<1;1,0>:ud   r103.0<1;1,0>:ud {I@1}
(f0.1)  goto (8|M0)                          L43264                  L43264                
L43208:
        add (8|M0)               acc0.0<1>:d   r69.0<1;1,0>:d    -1:w               {Compacted}
        mov (8|M0)               r101.0<1>:d   0:w                              
        shl (8|M0)               r102.0<1>:d   r46.0<1;1,0>:d    acc0.0<1;1,0>:d 
        goto (8|M0)                          L43264                  L43352                
L43264:
        join (8|M0)                          L43352                                
L43280:
        not (8|M0)               acc0.0<1>:d   r55.0<1;1,0>:d                  
        shl (8|M0)               r34.0<1>:d    r46.0<1;1,0>:d    r103.0<1;1,0>:d  {Compacted}
        add (8|M0)               acc0.0<1>:d   r69.0<1;1,0>:d    acc0.0<1;1,0>:d 
        and (8|M0)               r102.0<1>:d   r34.0<1;1,0>:d    8388607:d               {I@2}
        shl (8|M0)               r101.0<1>:d   acc0.0<1;1,0>:d   23:w              
L43352:
        join (8|M0)                          L43408                                
L43368:
        shl (8|M0)               r33.0<1>:d    r99.0<1;1,0>:d    31:w               {Compacted}
        bfn.0xFE (8|M0)          r44.0<1>:ud   r33.0<1;0>:ud     r101.0<1;0>:ud    r102.0<1>:ud     {I@1} // s0|s1|s2
        goto (8|M0)                          L43408                  L43600                
L43408:
        join (8|M0)                          L43488                                
L43424:
        cmp (8|M0)    (eq)f1.1   null<1>:d     r77.0<1;1,0>:d    0:w              
        bfn.0xF8 (8|M0)          r108.0<1>:ud  r56.0<1;0>:ud     r6.6<0;0>:ud      r6.5<0>:ud       // s0&s1|s2
(f1.1)  sel (8|M0)               r44.0<1>:f    r108.0<1;1,0>:f   0.0:f               {I@1}
        goto (8|M0)                          L43488                  L43600                
L43488:
        join (8|M0)                          L43600                                
L43504:
        cmp (8|M0)    (gt)f1.1   null<1>:ud    r100.0<1;1,0>:ud  r91.0<1;1,0>:ud  {F@1}
        add (8|M0)               acc0.0<1>:d   r91.0<1;1,0>:d    -r100.0<1;1,0>:d
        add (8|M0)               r92.0<1>:d    r100.0<1;1,0>:d   -r91.0<1;1,0>:d  {Compacted}
(f1.1)  sel (8|M0)               acc2.0<1>:d   r99.0<1;1,0>:d    r105.0<1;1,0>:d 
(~f1.1) mov (8|M0)               r92.0<1>:d    acc0.0<1;1,0>:d                 
        shl (8|M0)               r86.0<1>:d    acc2.0<1;1,0>:d   31:w              
        or (8|M0)                r44.0<1>:d    r86.0<1;1,0>:d    r92.0<1;1,0>:d   {Compacted,I@1}
L43600:
        join (8|M0)                          L43616                                
L43616:
        mov (8|M0)               r76.0<1>:f    r44.0<1;1,0>:f                   {Compacted,I@2}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        ret (8|M0)                           r6.2                             {A@1}
L43672:
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
