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
(W)     mov (8|M0)               r12.0<1>:ud   r0.0<1;1,0>:ud                  
(W)     or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x4C0:uw              {A@1}
(W)     mul (1|M0)               acc0.0<1>:ud  r4.3<0;1,0>:ud    r12.2<0;1,0>:uw  {A@1}
(W)     mach (1|M0)              r115.0<1>:ud  r4.3<0;1,0>:ud    r12.1<0;1,0>:ud  {AccWrEn}
        mov (8|M0)               r36.0<1>:d    r1.0<1;1,0>:uw                   {$0.dst}
(W)     mov (1|M0)               r114.0<1>:ud  acc0.0<0;1,0>:ud                 {Compacted}
        addc (8|M0)              r40.0<1>:ud   r114.0<0;1,0>:ud  r36.0<1;1,0>:ud  {AccWrEn,Compacted,I@1}
        add (8|M0)               r32.0<1>:ud   acc0.0<1;1,0>:ud  r115.0<0;1,0>:ud
        addc (8|M0)              r14.0<1>:ud   r40.0<1;1,0>:ud   r4.0<0;1,0>:ud   {AccWrEn,Compacted,I@2}
        cmp (8|M0)    (lt)f0.1   null<1>:ud    r14.0<1;1,0>:ud   r4.6<0;1,0>:ud   {I@1}
        add (8|M0)               r13.0<1>:ud   acc0.0<1;1,0>:ud  r32.0<1;1,0>:ud 
(f0.1)  cmp (8|M0)    (eq)f0.1   null<1>:d     r13.0<1;1,0>:d    r4.7<0;1,0>:d    {I@1}
(~f0.1) cmp (8|M0)    (lt)f0.1   null<1>:ud    r13.0<1;1,0>:ud   r4.7<0;1,0>:ud  
(~f0.1) goto (8|M0)                          L1240                  L1240                
L488:
(W)     mov (2|M0)               r5.1<1>:d     r5.6<1;1,0>:d                    {$2.dst}
(W)     mov (2|M0)               r6.1<1>:d     r6.6<1;1,0>:d                   
        mov (8|M0)               r21.0<1>:f    r14.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r20.0<1>:f    r13.0<1;1,0>:f                   {Compacted}
L536:
        cmp (8|M0)    (lt)f1.0   null<1>:ud    r21.0<1;1,0>:ud   r5.0<0;1,0>:ud   {F@2}
(f1.0)  cmp (8|M0)    (eq)f1.0   null<1>:d     r20.0<1;1,0>:d    0:w               {F@1}
(~f1.0) goto (8|M0)                          L1088                  L1088                
L584:
        shl (8|M0)               r19.0<1>:d    r21.0<1;1,0>:d    4:w               {Compacted}
        shr (8|M0)               r78.0<1>:ud   r21.0<1;1,0>:ud   28:w              
        shl (8|M0)               r35.0<1>:d    r20.0<1;1,0>:d    4:w               {Compacted}
        addc (8|M0)              r81.0<1>:ud   r19.0<1;1,0>:ud   r5.1<0;1,0>:ud   {AccWrEn,Compacted,I@3}
        or (8|M0)                r18.0<1>:d    r35.0<1;1,0>:d    r78.0<1;1,0>:d   {Compacted,I@2}
        mov (8|M0)               r34.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mov (8|M0)               r24.0<1>:f    r6.0<0;1,0>:f                    {Compacted}
        add3 (8|M0)              r56.1<2>:ud   r34.0<1;0>:ud     r18.0<1;0>:ud     r5.2<0>:ud       {I@1}
        mov (8|M0)               r56.0<2>:d    r81.0<1;1,0>:d                  
        send.ugm (8|M0)          r8       r56     null:0  0x0            0x04483580           {A@1,$5} // wr:2+0, rd:4; load.ugm.d32x4.a64.ca.ca
        mov (8|M0)               r22.0<1>:f    r8.0<1;1,0>:f                    {Compacted,$5.dst}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        call (8|M0)              r5.4          L1344                                 {A@1}
L752:
        mov (8|M0)               r17.0<1>:f    r23.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r24.0<1>:d    r6.0<0;1,0>:d                    {F@3}
        mov (8|M0)               r22.0<1>:f    r9.0<1;1,0>:f                    {Compacted}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        call (8|M0)              r5.4          L1344                                 {A@1}
L832:
        mov (8|M0)               r16.0<1>:f    r23.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r24.0<1>:d    r6.0<0;1,0>:d                   
        mov (8|M0)               r22.0<1>:f    r10.0<1;1,0>:f                   {Compacted}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        call (8|M0)              r5.4          L1344                                 {A@1}
L912:
        mov (8|M0)               r15.0<1>:f    r23.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r24.0<1>:d    r6.0<0;1,0>:d                   
        mov (8|M0)               r22.0<1>:f    r11.0<1;1,0>:f                   {Compacted}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        call (8|M0)              r5.4          L1344                                 {A@1}
L992:
        addc (8|M0)              r91.0<1>:ud   r19.0<1;1,0>:ud   r6.1<0;1,0>:ud   {AccWrEn,Compacted}
        mov (8|M0)               r40.0<1>:f    r23.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r33.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mov (8|M0)               r37.0<1>:f    r17.0<1;1,0>:f                   {Compacted,F@7}
        mov (8|M0)               r38.0<1>:f    r16.0<1;1,0>:f                   {Compacted,F@6}
        mov (8|M0)               r39.0<1>:f    r15.0<1;1,0>:f                   {Compacted,F@5}
        add3 (8|M0)              r58.1<2>:ud   r33.0<1;0>:ud     r18.0<1;0>:ud     r6.2<0>:ud       {I@1}
        mov (8|M0)               r58.0<2>:d    r91.0<1;1,0>:d                  
        send.ugm (8|M0)          null     r58     r37:4   0x0            0x040E3584           {A@1,$4} // wr:2+4, rd:0; store.ugm.d32x4.a64.wb.wb
L1088:
        join (8|M0)                          L1240                                
L1104:
        addc (8|M0)              r60.0<1>:ud   r21.0<1;1,0>:ud   r7.2<0;1,0>:ud   {AccWrEn,Compacted,$3.dst}
        cmp (8|M0)    (lt)f1.1   null<1>:ud    r60.0<1;1,0>:ud   r4.6<0;1,0>:ud   {I@1}
        add (8|M0)               r53.0<1>:ud   acc0.0<1;1,0>:ud  r20.0<1;1,0>:ud 
(f1.1)  cmp (8|M0)    (eq)f1.1   null<1>:d     r53.0<1;1,0>:d    r4.7<0;1,0>:d    {I@1}
(~f1.1) cmp (8|M0)    (lt)f1.1   null<1>:ud    r53.0<1;1,0>:ud   r4.7<0;1,0>:ud  
(~f1.1) goto (8|M0)                          L1240                  L1240                
L1192:
(f1.1)  sel (8|M0)               r21.0<1>:d    r60.0<1;1,0>:d    r14.0<1;1,0>:d  
(f1.1)  sel (8|M0)               r20.0<1>:d    r53.0<1;1,0>:d    r13.0<1;1,0>:d  
(W)     jmpi                                 L536                                
L1240:
        join (8|M0)                          L1256                                
L1256:
(W)     mov (8|M0)               r112.0<1>:f   r12.0<1;1,0>:f                   {Compacted}
(W)     send.gtwy (1|M0)         null     r112    null:0  0x0            0x02000010           {EOT,A@1} // wr:1+0, rd:0; end of thread
L1280:
(W)     mov (16|M0)              null<1>:ud    0x9E09665A:ud                             
(W)     mov (16|M0)              null<1>:ud    0xA6E09A48:ud                             
(W)     mov (16|M0)              null<1>:ud    0x0:ud                             
(W)     mov (16|M0)              null<1>:ud    0x6E:ud                             
L1344:
        and (8|M0)               r32.0<1>:d    r24.0<1;1,0>:d    -2:w               {Compacted}
(W)     mov (1|M0)               r5.6<1>:f     -0.0:f                               {Compacted}
        cmp (8|M0)    (eq)f0.0   null<1>:d     r32.0<1;1,0>:d    2:w               {Compacted,I@1}
(W)     mov (1|M0)               r5.3<1>:f     inf:f                               {Compacted}
(W)     mov (1|M0)               r5.7<1>:d     -1:w                              
(~f0.0) goto (8|M0)                          L29536                  L29536                
L1408:
        mov (8|M0)               r2.0<1>:hf    r22.0<1;1,0>:f                  
        mov (8|M0)               r25.0<1>:f    r2.0<1;1,0>:hf                   {F@1}
        sel (8|M0)    (ge)f0.0   acc0.0<1>:f   r25.0<1;1,0>:f    -4.0:f               {Compacted,F@1}
        sel (8|M0)    (lt)f0.0   r29.0<1>:f    acc0.0<1;1,0>:f   4.0:f               {Compacted}
        and (8|M0)    (ne)f0.0   r26.0<1>:d    r29.0<1;1,0>:d    8388607:d               {F@1}
        shr (8|M0)               r28.0<1>:ud   r29.0<1;1,0>:ud   23:w              
        and (8|M0)               r27.0<1>:d    r28.0<1;1,0>:d    255:w               {Compacted,I@1}
        cmp (8|M0)    (ne)f1.1   null<1>:d     r26.0<1;1,0>:d    0:w              
(f0.0)  cmp (8|M0)    (eq)f0.0   null<1>:d     r27.0<1;1,0>:d    255:w               {I@2}
(f1.1)  cmp (8|M0)    (eq)f1.1   null<1>:d     r27.0<1;1,0>:d    255:w              
(~f1.1) goto (8|M0)                          L1584                  L1584                
L1560:
        mov (8|M0)               r46.0<1>:f    qnan(0x0):f                               {Compacted}
        goto (8|M0)                          L1584                  L7344                
L1584:
        join (8|M0)                          L7344                                
L1600:
        cmp (8|M0)    (eq)f1.0   null<1>:d     r26.0<1;1,0>:d    0:w              
(f1.0)  cmp (8|M0)    (eq)f1.0   null<1>:d     r27.0<1;1,0>:d    255:w              
(~f1.0) goto (8|M0)                          L1672                  L1672                
L1648:
        mov (8|M0)               r46.0<1>:f    -inf:f                               {Compacted}
        goto (8|M0)                          L1672                  L7344                
L1672:
        join (8|M0)                          L7344                                
L1688:
        or (8|M0)     (eq)f1.0   null<1>:d     r27.0<1;1,0>:d    r26.0<1;1,0>:d  
(~f1.0) goto (8|M0)                          L1744                  L1744                
L1720:
        mov (8|M0)               r46.0<1>:f    0.0:f                               {Compacted}
        goto (8|M0)                          L1744                  L7344                
L1744:
        join (8|M0)                          L7344                                
L1760:
        cmp (8|M0)    (eq)f1.1   null<1>:d     r27.0<1;1,0>:d    0:w              
(W)     mov (1|M0)               r6.6<1>:hf    0.0:hf                             
        add (8|M0)               r40.0<1>:d    r27.0<1;1,0>:d    -132:w               {Compacted}
(W)     mov (1|M0)               r3.4<1>:d     0:w                              
(f1.1)  sel (8|M0)               acc0.0<1>:d   r6.6<0;1,0>:w     8388608:d               {F@1}
(W)     mov (1|M0)               r2.7<1>:f     -0.0:f                               {Compacted}
        or (8|M0)                r62.0<1>:d    acc0.0<1;1,0>:d   r26.0<1;1,0>:d  
(W)     mov (2|M0)               r2.4<1>:d     0:w                              
        mul (8|M0)               acc0.0<1>:ud  r62.0<1;1,0>:ud   0x0:uw              {I@2}
        mach (8|M0)              r51.0<1>:ud   r62.0<1;1,0>:ud   0xE50000:ud              {AccWrEn}
        mov (8|M0)               acc0.0<1>:ud  acc0.0<1;1,0>:ud                
        mov (8|M0)               r44.0<1>:f    r51.0<1;1,0>:f                   {Compacted,I@2}
        mov (8|M0)               r39.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
L1936:
(W)     shl (1|M0)               r3.1<1>:d     r2.7<0;1,0>:d     31:w               {F@2}
(W)     shr (1|M0)               r3.0<1>:ud    r3.4<0;1,0>:ud    1:w              
(W)     cmp (8|M0)    (gt)f0.1   null<1>:ud    r2.4<0;1,0>:ud    0x3E:uw             
(W)     or (1|M0)                r3.4<1>:d     r3.0<0;1,0>:d     r3.1<0;1,0>:d    {I@2}
        bfn.0xA8 (8|M0)          r108.0<1>:ud  r39.0<1;0>:ud     r3.0<0;0>:ud      r3.1<0>:ud       // s0&(s1|s2)
(W)     shr (1|M0)               r2.6<1>:ud    r2.7<0;1,0>:ud    1:w              
(W&f0.1) cmp (8|M0)   (eq)f0.1   null<1>:d     r2.5<0;1,0>:d     0:w              
        cmp (8|M0)    (eq)f1.0   null<1>:d     r108.0<1;1,0>:d   r3.4<0;1,0>:d    {I@3}
        and (8|M0)               r107.0<1>:d   r44.0<1;1,0>:d    r2.6<0;1,0>:d    {Compacted,A@1}
(W)     mov (1|M0)               r3.12<1>:hf   0x1:hf                             
(W&~f0.1) cmp (8|M0)  (gt)f0.1   null<1>:ud    r2.5<0;1,0>:ud    0x0:uw             
(f1.0)  cmp (8|M0)    (eq)f1.0   null<1>:d     r107.0<1;1,0>:d   r2.6<0;1,0>:d    {I@2}
(W)     addc (1|M0)              r30.0<1>:ud   r2.4<0;1,0>:ud    0x1:ud              {AccWrEn}
        mov (8|M0)               r58.0<1>:d    r2.4<0;1,0>:d                   
(f0.1)  sel (8|M0)               r3.0<1>:uw    r3.12<0;1,0>:uw   0x0:uw              {F@1}
(f1.0)  sel (8|M0)               r2.0<1>:uw    r3.12<0;1,0>:uw   0x0:uw             
(W)     mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        or (8|M0)     (ne)f0.1   null<1>:uw    r3.0<1;1,0>:uw    r2.0<1;1,0>:uw   {I@2}
(W)     add (1|M0)               r3.5<1>:ud    r7.0<0;1,0>:ud    r2.5<0;1,0>:ud   {I@2}
        mov (8|M0)               r59.0<1>:d    r2.5<0;1,0>:d                   
        mov (8|M0)               r90.0<1>:f    r30.0<0;1,0>:f                   {Compacted}
        mov (8|M0)               r23.0<1>:d    r3.5<0;1,0>:d                    {I@2}
(f0.1)  goto (8|M0)                          L2344                  L2344                
L2280:
(W)     mov (1|M0)               r2.7<1>:d     r2.6<0;1,0>:d                   
(W)     mov (1|M0)               r2.4<1>:d     r30.0<0;1,0>:d                  
(W)     mov (1|M0)               r2.5<1>:f     r3.5<0;1,0>:f                    {I@5}
(W)     jmpi                                 L1936                                
L2344:
        join (8|M0)                          L7344                                
L2360:
(W)     mov (1|M0)               r6.3<1>:f     8.68805e-44:f                              
(~f1.1) sel (8|M0)               r119.0<1>:d   r40.0<1;1,0>:d    -131:w              
        subb (8|M0)              r99.0<1>:ud   r6.3<0;1,0>:ud    r58.0<1;1,0>:ud  {AccWrEn,Compacted,F@1}
(W)     mov (1|M0)               r7.0<1>:hf    0.0:hf                             
        add3 (8|M0)              r35.0<1>:d    r119.0<1;0>:d     r99.0<1;0>:d      -46:w               {I@1}
        add (8|M0)               r22.0<1>:d    r119.0<1;1,0>:d   r99.0<1;1,0>:d   {Compacted}
        cmp (8|M0)    (gt)f0.1   null<1>:d     r35.0<1;1,0>:d    127:w               {I@2}
        add3 (8|M0)              r38.0<1>:ud   -acc0.0<1;0>:ud   r7.0<0;0>:uw      -r59.0<1>:ud     {F@1}
(~f0.1) goto (8|M0)                          L2512                  L2512                
L2488:
        mov (8|M0)               r46.0<1>:f    -inf:f                               {Compacted}
        goto (8|M0)                          L2512                  L7344                
L2512:
        join (8|M0)                          L7344                                
L2528:
        cmp (8|M0)    (gt)f1.1   null<1>:d     r35.0<1;1,0>:d    -127:w              
(f1.1)  goto (8|M0)                          L4984                  L4984                
L2560:
        cmp (8|M0)    (lt)f1.0   null<1>:ud    r35.0<1;1,0>:ud   0xFFFFFF6B:ud             
(f1.0)  goto (8|M0)                          L4560                  L4560                
L2592:
(W)     mov (1|M0)               r6.3<1>:f     8.82818e-44:f                              
        add3 (8|M0)              r30.0<1>:d    r119.0<1;0>:d     r99.0<1;0>:d      104:w              
        subb (8|M0)              r41.0<1>:ud   r6.3<0;1,0>:ud    r58.0<1;1,0>:ud  {AccWrEn,Compacted,F@1}
(W)     mov (1|M0)               r7.0<1>:hf    0.0:hf                              {I@7}
        cmp (8|M0)    (gt)f1.0   null<1>:ud    r41.0<1;1,0>:ud   r30.0<1;1,0>:ud  {I@1}
        add3 (8|M0)              r94.0<1>:ud   -acc0.0<1;0>:ud   r7.0<0;0>:uw      -r59.0<1>:ud     {F@1}
(f1.0)  cmp (8|M0)    (eq)f1.0   null<1>:d     r94.0<1;1,0>:d    0:w               {I@1}
(~f1.0) cmp (8|M0)    (gt)f1.0   null<1>:ud    r94.0<1;1,0>:ud   0x0:uw             
(f1.0)  goto (8|M0)                          L2792                  L2792                
L2728:
        add3 (8|M0)              acc0.0<1>:d   r22.0<1;0>:d      -r41.0<1;0>:d     104:w              
        mov (8|M0)               r99.0<1>:d    0:w                              
        shl (8|M0)               r100.0<1>:d   r39.0<1;1,0>:d    acc0.0<1;1,0>:d 
        goto (8|M0)                          L2792                  L4512                
L2792:
        join (8|M0)                          L4512                                
L2808:
        add3 (8|M0)              r45.0<1>:d    r41.0<1;0>:d      -r22.0<1;0>:d     -104:w              
        cmp (8|M0)    (lt)f0.1   null<1>:d     r45.0<1;1,0>:d    2:w               {I@1}
(f0.1)  goto (8|M0)                          L2960                  L2960                
L2856:
        cmp (8|M0)    (eq)f1.1   null<1>:d     r45.0<1;1,0>:d    2:w              
(~f1.1) goto (8|M0)                          L2960                  L3064                
L2888:
        shr (8|M0)               r46.0<1>:ud   r39.0<1;1,0>:ud   1:w              
        mov (8|M0)               r126.0<1>:d   0:w                              
        mov (8|M0)               r36.0<1>:d    0:w                              
        mov (8|M0)               r120.0<1>:f   r46.0<1;1,0>:f                   {Compacted,I@3}
        goto (8|M0)                          L2960                  L3944                
L2960:
        join (8|M0)                          L3064                                
L2976:
        cmp (8|M0)    (eq)f1.0   null<1>:d     r45.0<1;1,0>:d    1:w              
(~f1.0) goto (8|M0)                          L3064                  L3064                
L3008:
        mov (8|M0)               r126.0<1>:d   0:w                              
        mov (8|M0)               r36.0<1>:d    0:w                              
        mov (8|M0)               r120.0<1>:f   r39.0<1;1,0>:f                   {Compacted}
        goto (8|M0)                          L3064                  L3944                
L3064:
        join (8|M0)                          L3944                                
L3080:
        add3 (8|M0)              acc0.0<1>:d   r41.0<1;0>:d      -r30.0<1;0>:d     -1:w              
        and (8|M0)    (ne)f0.1   r102.0<1>:d   acc0.0<1;1,0>:d   63:w              
(f0.1)  goto (8|M0)                          L3160                  L3160                
L3128:
        mov (8|M0)               r31.0<1>:d    r39.0<1;1,0>:d                  
        goto (8|M0)                          L3160                  L3296                
L3160:
        join (8|M0)                          L3296                                
L3176:
        cmp (8|M0)    (lt)f1.1   null<1>:ud    r102.0<1;1,0>:ud  0x20:uw              {I@5}
(f1.1)  add (8|M0)               acc0.0<1>:d   -r102.0<1;1,0>:d  32:w              
(~f1.1) add (8|M0)               acc2.0<1>:d   r102.0<1;1,0>:d   -32:w              
(f1.1)  shr (8|M0)               r3.0<1>:ud    r39.0<1;1,0>:ud   r102.0<1;1,0>:d 
(f1.1)  shl (8|M0)               r80.0<1>:d    r44.0<1;1,0>:d    acc0.0<1;1,0>:d 
(~f1.1) shr (8|M0)               r46.0<1>:ud   r44.0<1;1,0>:ud   acc2.0<1;1,0>:d  {F@2}
(f1.1)  or (8|M0)                r46.0<1>:d    r3.0<1;1,0>:d     r80.0<1;1,0>:d   {I@2}
        mov (8|M0)               r31.0<1>:f    r46.0<1;1,0>:f                   {Compacted,I@1}
L3296:
        join (8|M0)                          L3944                                
L3312:
        add3 (8|M0)              r117.0<1>:d   r41.0<1;0>:d      -r30.0<1;0>:d     -2:w              
        and (8|M0)    (ne)f1.0   r101.0<1>:d   r117.0<1;1,0>:d   63:w               {I@1}
(f1.0)  goto (8|M0)                          L3392                  L3392                
L3360:
        mov (8|M0)               r46.0<1>:d    r39.0<1;1,0>:d                   {F@1}
        goto (8|M0)                          L3392                  L3520                
L3392:
        join (8|M0)                          L3520                                
L3408:
        cmp (8|M0)    (lt)f0.1   null<1>:ud    r101.0<1;1,0>:ud  0x20:uw              {I@5}
(f0.1)  add (8|M0)               acc0.0<1>:d   -r101.0<1;1,0>:d  32:w              
(~f0.1) add (8|M0)               acc2.0<1>:d   r101.0<1;1,0>:d   -32:w              
(f0.1)  shr (8|M0)               r127.0<1>:ud  r39.0<1;1,0>:ud   r101.0<1;1,0>:d 
(f0.1)  shl (8|M0)               r79.0<1>:d    r44.0<1;1,0>:d    acc0.0<1;1,0>:d 
(~f0.1) shr (8|M0)               r46.0<1>:ud   r44.0<1;1,0>:ud   acc2.0<1;1,0>:d 
(f0.1)  or (8|M0)                r46.0<1>:d    r127.0<1;1,0>:d   r79.0<1;1,0>:d   {I@2}
L3520:
        join (8|M0)                          L3944                                
L3536:
        and (8|M0)    (ne)f1.1   r78.0<1>:d    r117.0<1;1,0>:d   63:w              
        and (8|M0)               r36.0<1>:d    r46.0<1;1,0>:d    1:w               {Compacted,I@3}
(f1.1)  goto (8|M0)                          L3624                  L3624                
L3576:
        mov (8|M0)               r88.0<1>:d    -1:w                              
        mov (8|M0)               r96.0<1>:d    -1:w                              
        goto (8|M0)                          L3624                  L3808                
L3624:
        join (8|M0)                          L3808                                
L3640:
        cmp (8|M0)    (lt)f1.0   null<1>:ud    r78.0<1;1,0>:ud   0x20:uw              {I@7}
(f1.0)  goto (8|M0)                          L3744                  L3744                
L3672:
        add (8|M0)               acc0.0<1>:d   r78.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r6.6<1>:hf    -qnan(0x1FF):hf                             
        mov (8|M0)               r88.0<1>:d    0:w                              
        shl (8|M0)               r96.0<1>:d    r6.6<0;1,0>:w     acc0.0<1;1,0>:d  {F@1}
        goto (8|M0)                          L3744                  L3808                
L3744:
        join (8|M0)                          L3808                                
L3760:
(W)     mov (1|M0)               r6.6<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (8|M0)               r96.0<1>:d    -1:w                              
        shl (8|M0)               r88.0<1>:d    r6.6<0;1,0>:w     r78.0<1;1,0>:d   {F@1}
L3808:
        join (8|M0)                          L3944                                
L3824:
        bfn.0x28 (8|M0)          r126.0<1>:ud  r39.0<1;0>:ud     r88.0<1;0>:ud     r5.7<0>:ud       {I@2} // s0&(s1^s2)
        bfn.0x28 (8|M0)          r125.0<1>:ud  r44.0<1;0>:ud     r96.0<1;0>:ud     r5.7<0>:ud       // s0&(s1^s2)
        cmp (8|M0)    (ne)f0.1   null<1>:d     r126.0<1;1,0>:d   0:w               {I@2}
(W)     mov (1|M0)               r6.6<1>:hf    -qnan(0x1FF):hf                             
        mov (8|M0)               r120.0<1>:f   r31.0<1;1,0>:f                   {Compacted}
(~f0.1) cmp (8|M0)    (ne)f0.1   null<1>:d     r125.0<1;1,0>:d   0:w               {I@2}
(f0.1)  sel (8|M0)               acc0.0<1>:d   r6.6<0;1,0>:w     0:w               {F@2}
        mov (8|M0)               r126.0<1>:d   -acc0.0<1;1,0>:d                
L3944:
        join (8|M0)                          L4512                                
L3960:
        and (8|M0)    (ne)f0.1   r100.0<1>:d   r45.0<1;1,0>:d    63:w              
(f0.1)  goto (8|M0)                          L4024                  L4024                
L3992:
        mov (8|M0)               r46.0<1>:d    r39.0<1;1,0>:d                  
        goto (8|M0)                          L4024                  L4152                
L4024:
        join (8|M0)                          L4152                                
L4040:
        cmp (8|M0)    (lt)f1.1   null<1>:ud    r100.0<1;1,0>:ud  0x20:uw              {I@5}
(f1.1)  add (8|M0)               acc0.0<1>:d   -r100.0<1;1,0>:d  32:w              
(~f1.1) add (8|M0)               acc2.0<1>:d   r100.0<1;1,0>:d   -32:w              
(f1.1)  shr (8|M0)               r122.0<1>:ud  r39.0<1;1,0>:ud   r100.0<1;1,0>:d 
(f1.1)  shl (8|M0)               r77.0<1>:d    r44.0<1;1,0>:d    acc0.0<1;1,0>:d 
(~f1.1) shr (8|M0)               r46.0<1>:ud   r44.0<1;1,0>:ud   acc2.0<1;1,0>:d 
(f1.1)  or (8|M0)                r46.0<1>:d    r122.0<1;1,0>:d   r77.0<1;1,0>:d   {I@2}
L4152:
        join (8|M0)                          L4512                                
L4168:
        shl (8|M0)               r34.0<1>:d    r120.0<1;1,0>:d   2:w               {Compacted,F@1}
        shl (8|M0)               r121.0<1>:d   r36.0<1;1,0>:d    1:w               {Compacted}
        and (8|M0)               r34.0<1>:d    r34.0<1;1,0>:d    4:w               {Compacted,I@2}
        bfn.0xFE (8|M0)          r86.0<1>:ud   r34.0<1;0>:ud     r121.0<1;0>:ud    r126.0<1>:ud     {I@1} // s0|s1|s2
        cmp (8|M0)    (eq)f1.0   null<1>:d     r86.0<1;1,0>:d    0:w               {I@1}
(~f1.0) goto (8|M0)                          L4272                  L4272                
L4240:
        mov (8|M0)               r100.0<1>:d   0:w                              
        goto (8|M0)                          L4272                  L4432                
L4272:
        join (8|M0)                          L4432                                
L4288:
        cmp (8|M0)    (gt)f0.1   null<1>:ud    r86.0<1;1,0>:ud   0x4:uw             
(~f0.1) goto (8|M0)                          L4352                  L4352                
L4320:
        mov (8|M0)               r100.0<1>:d   1:w                              
        goto (8|M0)                          L4352                  L4432                
L4352:
        join (8|M0)                          L4432                                
L4368:
        and (8|M0)    (ne)f1.1   null<1>:d     r46.0<1;1,0>:d    1:w              
(W)     mov (1|M0)               r6.6<1>:hf    0x1:hf                             
(f1.1)  cmp (8|M0)    (eq)f1.1   null<1>:d     r86.0<1;1,0>:d    4:w              
(f1.1)  sel (8|M0)               r100.0<1>:d   r6.6<0;1,0>:w     0:w               {F@1}
L4432:
        join (8|M0)                          L4512                                
L4448:
        add (8|M0)               r57.0<1>:d    r100.0<1;1,0>:d   r46.0<1;1,0>:d   {Compacted,I@2}
(W)     mov (1|M0)               r6.3<1>:f     0x800000:f                               {Compacted}
        cmp (8|M0)    (gt)f0.1   null<1>:ud    r57.0<1;1,0>:ud   0x7FFFFF:ud              {I@1}
(~f0.1) sel (8|M0)               r100.0<1>:d   r57.0<1;1,0>:d    0:w              
(f0.1)  sel (8|M0)               r99.0<1>:d    r6.3<0;1,0>:d     0:w               {F@1}
L4512:
        join (8|M0)                          L4560                                
L4528:
        bfn.0xFE (8|M0)          r46.0<1>:ud   r99.0<1;0>:ud     r100.0<1;0>:ud    r5.6<0>:ud       {I@2} // s0|s1|s2
        goto (8|M0)                          L4560                  L7344                
L4560:
        join (8|M0)                          L4984                                
L4576:
        and (8|M0)    (ne)f1.1   r50.0<1>:d    r99.0<1;1,0>:d    63:w              
(f1.1)  goto (8|M0)                          L4656                  L4656                
L4608:
        mov (8|M0)               r64.0<1>:d    -1:w                              
        mov (8|M0)               r76.0<1>:d    -1:w                              
        goto (8|M0)                          L4656                  L4840                
L4656:
        join (8|M0)                          L4840                                
L4672:
        cmp (8|M0)    (lt)f1.0   null<1>:ud    r50.0<1;1,0>:ud   0x20:uw              {I@6}
(f1.0)  goto (8|M0)                          L4776                  L4776                
L4704:
        add (8|M0)               acc0.0<1>:d   r50.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r6.6<1>:hf    -qnan(0x1FF):hf                             
        mov (8|M0)               r64.0<1>:d    0:w                              
        shl (8|M0)               r76.0<1>:d    r6.6<0;1,0>:w     acc0.0<1;1,0>:d  {F@1}
        goto (8|M0)                          L4776                  L4840                
L4776:
        join (8|M0)                          L4840                                
L4792:
(W)     mov (1|M0)               r6.6<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (8|M0)               r76.0<1>:d    -1:w                              
        shl (8|M0)               r64.0<1>:d    r6.6<0;1,0>:w     r50.0<1;1,0>:d   {F@1}
L4840:
        join (8|M0)                          L4984                                
L4856:
        bfn.0x28 (8|M0)          r120.0<1>:ud  r39.0<1;0>:ud     r64.0<1;0>:ud     r5.7<0>:ud       {I@2} // s0&(s1^s2)
        bfn.0x28 (8|M0)          r119.0<1>:ud  r44.0<1;0>:ud     r76.0<1;0>:ud     r5.7<0>:ud       // s0&(s1^s2)
        cmp (8|M0)    (ne)f0.1   null<1>:d     r120.0<1;1,0>:d   0:w               {I@2}
(W)     mov (1|M0)               r6.3<1>:f     -1.4013e-45:f                              
(~f0.1) cmp (8|M0)    (ne)f0.1   null<1>:d     r119.0<1;1,0>:d   0:w               {I@2}
(f0.1)  cmp (8|M0)    (eq)f0.1   null<1>:d     r35.0<1;1,0>:d    -150:w              
(f0.1)  sel (8|M0)               r46.0<1>:f    r6.3<0;1,0>:f     -0.0:f               {F@1}
        goto (8|M0)                          L4984                  L7344                
L4984:
        join (8|M0)                          L7344                                
L5000:
        cmp (8|M0)    (lt)f1.0   null<1>:ud    r99.0<1;1,0>:ud   0x18:uw             
        add3 (8|M0)              r47.0<1>:d    r119.0<1;0>:d     r99.0<1;0>:d      81:w              
(f1.0)  cmp (8|M0)    (eq)f1.0   null<1>:d     r38.0<1;1,0>:d    0:w              
(f1.0)  goto (8|M0)                          L7056                  L7056                
L5064:
        shl (8|M0)               r127.0<1>:d   r90.0<1;1,0>:d    1:w               {Compacted}
        shr (8|M0)               r126.0<1>:ud  r90.0<1;1,0>:ud   31:w              
        shl (8|M0)               r109.0<1>:d   r23.0<1;1,0>:d    1:w               {Compacted}
        cmp (8|M0)    (lt)f1.1   null<1>:ud    r127.0<1;1,0>:ud  0x4E:uw              {I@3}
        or (8|M0)                r109.0<1>:d   r109.0<1;1,0>:d   r126.0<1;1,0>:d  {Compacted,I@2}
(f1.1)  cmp (8|M0)    (eq)f1.1   null<1>:d     r109.0<1;1,0>:d   0:w               {I@1}
(~f1.1) cmp (8|M0)    (lt)f1.1   null<1>:d     r109.0<1;1,0>:d   0:w              
(f1.1)  goto (8|M0)                          L5296                  L5296                
L5168:
        cmp (8|M0)    (eq)f0.1   null<1>:d     r90.0<1;1,0>:d    39:w               {F@1}
(f0.1)  cmp (8|M0)    (eq)f0.1   null<1>:d     r23.0<1;1,0>:d    0:w              
(~f0.1) goto (8|M0)                          L5296                  L5360                
L5216:
        shr (8|M0)               r46.0<1>:ud   r39.0<1;1,0>:ud   1:w              
        mov (8|M0)               r34.0<1>:d    0:w                              
        mov (8|M0)               r40.0<1>:d    0:w                              
        mov (8|M0)               r121.0<1>:f   r46.0<1;1,0>:f                   {Compacted,I@3}
        mov (8|M0)               r46.0<1>:f    r39.0<1;1,0>:f                   {Compacted}
        goto (8|M0)                          L5296                  L6560                
L5296:
        join (8|M0)                          L5360                                
L5312:
        cmp (8|M0)    (eq)f1.1   null<1>:d     r90.0<1;1,0>:d    38:w              
(f1.1)  cmp (8|M0)    (eq)f1.1   null<1>:d     r23.0<1;1,0>:d    0:w              
(f1.1)  goto (8|M0)                          L5360                  L6472                
L5360:
        join (8|M0)                          L6472                                
L5376:
        add (8|M0)               acc0.0<1>:d   -r90.0<1;1,0>:d   39:w               {Compacted}
        add (8|M0)               r48.0<1>:d    -r90.0<1;1,0>:d   40:w               {Compacted}
        and (8|M0)    (ne)f0.1   r104.0<1>:d   acc0.0<1;1,0>:d   63:w              
(f0.1)  goto (8|M0)                          L5456                  L5456                
L5424:
        mov (8|M0)               r41.0<1>:d    r39.0<1;1,0>:d                  
        goto (8|M0)                          L5456                  L5592                
L5456:
        join (8|M0)                          L5592                                
L5472:
        cmp (8|M0)    (lt)f1.1   null<1>:ud    r104.0<1;1,0>:ud  0x20:uw              {I@5}
(f1.1)  add (8|M0)               acc0.0<1>:d   -r104.0<1;1,0>:d  32:w              
(~f1.1) add (8|M0)               acc2.0<1>:d   r104.0<1;1,0>:d   -32:w              
(f1.1)  shr (8|M0)               r116.0<1>:ud  r39.0<1;1,0>:ud   r104.0<1;1,0>:d 
(f1.1)  shl (8|M0)               r95.0<1>:d    r44.0<1;1,0>:d    acc0.0<1;1,0>:d 
(~f1.1) shr (8|M0)               r46.0<1>:ud   r44.0<1;1,0>:ud   acc2.0<1;1,0>:d  {F@1}
(f1.1)  or (8|M0)                r46.0<1>:d    r116.0<1;1,0>:d   r95.0<1;1,0>:d   {I@2}
        mov (8|M0)               r41.0<1>:f    r46.0<1;1,0>:f                   {Compacted,I@1}
L5592:
        join (8|M0)                          L6472                                
L5608:
        add (8|M0)               r127.0<1>:d   -r90.0<1;1,0>:d   38:w               {Compacted}
        and (8|M0)    (ne)f1.0   r108.0<1>:d   r127.0<1;1,0>:d   63:w               {I@1}
(f1.0)  goto (8|M0)                          L5680                  L5680                
L5648:
        mov (8|M0)               r46.0<1>:d    r39.0<1;1,0>:d                   {F@1}
        goto (8|M0)                          L5680                  L5808                
L5680:
        join (8|M0)                          L5808                                
L5696:
        cmp (8|M0)    (lt)f0.1   null<1>:ud    r108.0<1;1,0>:ud  0x20:uw              {I@5}
(f0.1)  add (8|M0)               acc0.0<1>:d   -r108.0<1;1,0>:d  32:w              
(~f0.1) add (8|M0)               acc2.0<1>:d   r108.0<1;1,0>:d   -32:w              
(f0.1)  shr (8|M0)               r114.0<1>:ud  r39.0<1;1,0>:ud   r108.0<1;1,0>:d 
(f0.1)  shl (8|M0)               r102.0<1>:d   r44.0<1;1,0>:d    acc0.0<1;1,0>:d 
(~f0.1) shr (8|M0)               r46.0<1>:ud   r44.0<1;1,0>:ud   acc2.0<1;1,0>:d 
(f0.1)  or (8|M0)                r46.0<1>:d    r114.0<1;1,0>:d   r102.0<1;1,0>:d  {I@2}
L5808:
        join (8|M0)                          L6472                                
L5824:
        and (8|M0)    (ne)f1.1   r101.0<1>:d   r127.0<1;1,0>:d   63:w              
        and (8|M0)               r40.0<1>:d    r46.0<1;1,0>:d    1:w               {Compacted,I@3}
(f1.1)  goto (8|M0)                          L5912                  L5912                
L5864:
        mov (8|M0)               r104.0<1>:d   -1:w                              
        mov (8|M0)               r114.0<1>:d   -1:w                              
        goto (8|M0)                          L5912                  L6096                
L5912:
        join (8|M0)                          L6096                                
L5928:
        cmp (8|M0)    (lt)f1.0   null<1>:ud    r101.0<1;1,0>:ud  0x20:uw              {I@7}
(f1.0)  goto (8|M0)                          L6032                  L6032                
L5960:
        add (8|M0)               acc0.0<1>:d   r101.0<1;1,0>:d   -32:w               {Compacted}
(W)     mov (1|M0)               r6.6<1>:hf    -qnan(0x1FF):hf                             
        mov (8|M0)               r104.0<1>:d   0:w                              
        shl (8|M0)               r114.0<1>:d   r6.6<0;1,0>:w     acc0.0<1;1,0>:d  {F@1}
        goto (8|M0)                          L6032                  L6096                
L6032:
        join (8|M0)                          L6096                                
L6048:
(W)     mov (1|M0)               r6.6<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (8|M0)               r114.0<1>:d   -1:w                              
        shl (8|M0)               r104.0<1>:d   r6.6<0;1,0>:w     r101.0<1;1,0>:d  {F@1}
L6096:
        join (8|M0)                          L6472                                
L6112:
        bfn.0x28 (8|M0)          r113.0<1>:ud  r39.0<1;0>:ud     r104.0<1;0>:ud    r5.7<0>:ud       {I@2} // s0&(s1^s2)
        bfn.0x28 (8|M0)          r112.0<1>:ud  r44.0<1;0>:ud     r114.0<1;0>:ud    r5.7<0>:ud       // s0&(s1^s2)
        cmp (8|M0)    (ne)f1.0   null<1>:d     r113.0<1;1,0>:d   0:w               {I@2}
(W)     mov (1|M0)               r6.6<1>:hf    -qnan(0x1FF):hf                             
        and (8|M0)    (ne)f0.1   r107.0<1>:d   r48.0<1;1,0>:d    63:w              
(~f1.0) cmp (8|M0)    (ne)f1.0   null<1>:d     r112.0<1;1,0>:d   0:w               {I@3}
(f1.0)  sel (8|M0)               acc0.0<1>:d   r6.6<0;1,0>:w     0:w               {F@1}
        mov (8|M0)               r34.0<1>:d    -acc0.0<1;1,0>:d                
(f0.1)  goto (8|M0)                          L6288                  L6288                
L6256:
        mov (8|M0)               r46.0<1>:d    r39.0<1;1,0>:d                  
        goto (8|M0)                          L6288                  L6416                
L6288:
        join (8|M0)                          L6416                                
L6304:
        cmp (8|M0)    (lt)f1.1   null<1>:ud    r107.0<1;1,0>:ud  0x20:uw              {I@7}
(f1.1)  add (8|M0)               acc0.0<1>:d   -r107.0<1;1,0>:d  32:w              
(~f1.1) add (8|M0)               acc2.0<1>:d   r107.0<1;1,0>:d   -32:w              
(f1.1)  shr (8|M0)               r109.0<1>:ud  r39.0<1;1,0>:ud   r107.0<1;1,0>:d 
(f1.1)  shl (8|M0)               r100.0<1>:d   r44.0<1;1,0>:d    acc0.0<1;1,0>:d 
(~f1.1) shr (8|M0)               r46.0<1>:ud   r44.0<1;1,0>:ud   acc2.0<1;1,0>:d 
(f1.1)  or (8|M0)                r46.0<1>:d    r109.0<1;1,0>:d   r100.0<1;1,0>:d  {I@2}
L6416:
        join (8|M0)                          L6472                                
L6432:
        mov (8|M0)               r121.0<1>:f   r46.0<1;1,0>:f                   {Compacted,I@2}
        mov (8|M0)               r46.0<1>:d    r41.0<1;1,0>:d                   {F@1}
        goto (8|M0)                          L6472                  L6560                
L6472:
        join (8|M0)                          L6560                                
L6488:
        shr (8|M0)               r46.0<1>:ud   r39.0<1;1,0>:ud   2:w              
        mov (8|M0)               r34.0<1>:d    0:w                              
        mov (8|M0)               r40.0<1>:d    0:w                              
        mov (8|M0)               r121.0<1>:f   r46.0<1;1,0>:f                   {Compacted,I@3}
        shr (8|M0)               r46.0<1>:ud   r39.0<1;1,0>:ud   1:w               {F@1}
L6560:
        join (8|M0)                          L7056                                
L6576:
        shl (8|M0)               r87.0<1>:d    r46.0<1;1,0>:d    2:w               {Compacted,I@2}
        shl (8|M0)               r108.0<1>:d   r40.0<1;1,0>:d    1:w               {Compacted}
        and (8|M0)               r87.0<1>:d    r87.0<1;1,0>:d    4:w               {Compacted,I@2}
        and (8|M0)               r23.0<1>:d    r121.0<1;1,0>:d   8388607:d              
        bfn.0xFE (8|M0)          r49.0<1>:ud   r87.0<1;0>:ud     r108.0<1;0>:ud    r34.0<1>:ud      {I@2} // s0|s1|s2
        cmp (8|M0)    (eq)f1.0   null<1>:d     r49.0<1;1,0>:d    0:w               {I@1}
(~f1.0) goto (8|M0)                          L6696                  L6696                
L6664:
        mov (8|M0)               r48.0<1>:d    0:w                              
        goto (8|M0)                          L6696                  L6856                
L6696:
        join (8|M0)                          L6856                                
L6712:
        cmp (8|M0)    (gt)f0.1   null<1>:ud    r49.0<1;1,0>:ud   0x4:uw             
(~f0.1) goto (8|M0)                          L6776                  L6776                
L6744:
        mov (8|M0)               r48.0<1>:d    1:w                              
        goto (8|M0)                          L6776                  L6856                
L6776:
        join (8|M0)                          L6856                                
L6792:
        and (8|M0)    (ne)f0.1   null<1>:d     r121.0<1;1,0>:d   1:w              
(W)     mov (1|M0)               r6.6<1>:hf    0x1:hf                             
(f0.1)  cmp (8|M0)    (eq)f0.1   null<1>:d     r49.0<1;1,0>:d    4:w              
(f0.1)  sel (8|M0)               r48.0<1>:d    r6.6<0;1,0>:w     0:w               {F@1}
L6856:
        join (8|M0)                          L7056                                
L6872:
        add (8|M0)               r93.0<1>:d    r23.0<1;1,0>:d    r48.0<1;1,0>:d   {Compacted,I@2}
        add3 (8|M0)              r82.0<1>:d    r119.0<1;0>:d     r99.0<1;0>:d      82:w              
        cmp (8|M0)    (gt)f0.1   null<1>:ud    r93.0<1;1,0>:ud   0x7FFFFF:ud              {I@2}
(f0.1)  sel (8|M0)               r72.0<1>:d    r82.0<1;1,0>:d    r47.0<1;1,0>:d   {I@2}
        cmp (8|M0)    (eq)f1.1   null<1>:d     r72.0<1;1,0>:d    255:w               {I@1}
(~f1.1) goto (8|M0)                          L6984                  L6984                
L6960:
        mov (8|M0)               r46.0<1>:f    -inf:f                               {Compacted}
        goto (8|M0)                          L6984                  L7344                
L6984:
        join (8|M0)                          L7056                                
L7000:
(~f0.1) sel (8|M0)               r81.0<1>:d    r93.0<1;1,0>:d    0:w              
        shl (8|M0)               r107.0<1>:d   r72.0<1;1,0>:d    23:w               {Compacted}
        bfn.0xFE (8|M0)          r46.0<1>:ud   r107.0<1;0>:ud    r81.0<1;0>:ud     r5.6<0>:ud       {A@1} // s0|s1|s2
        goto (8|M0)                          L7056                  L7344                
L7056:
        join (8|M0)                          L7344                                
L7072:
        and (8|M0)    (ne)f1.0   r89.0<1>:d    r99.0<1;1,0>:d    63:w              
(f1.0)  goto (8|M0)                          L7136                  L7136                
L7104:
        mov (8|M0)               r33.0<1>:d    -1:w                              
        goto (8|M0)                          L7136                  L7264                
L7136:
        join (8|M0)                          L7264                                
L7152:
        cmp (8|M0)    (lt)f0.1   null<1>:ud    r89.0<1;1,0>:ud   0x20:uw              {I@5}
(f0.1)  goto (8|M0)                          L7216                  L7216                
L7184:
        mov (8|M0)               r33.0<1>:d    0:w                              
        goto (8|M0)                          L7216                  L7264                
L7216:
        join (8|M0)                          L7264                                
L7232:
(W)     mov (1|M0)               r6.6<1>:hf    -qnan(0x1FF):hf                             
        shl (8|M0)               r33.0<1>:d    r6.6<0;1,0>:w     r89.0<1;1,0>:d   {F@1}
L7264:
        join (8|M0)                          L7344                                
L7280:
        bfn.0x28 (8|M0)          r32.0<1>:ud   r39.0<1;0>:ud     r33.0<1;0>:ud     r5.7<0>:ud       {I@2} // s0&(s1^s2)
        add (8|M0)               acc0.0<1>:d   -r99.0<1;1,0>:d   23:w               {Compacted}
        shl (8|M0)               r105.0<1>:d   r47.0<1;1,0>:d    23:w               {Compacted}
        shl (8|M0)               r32.0<1>:d    r32.0<1;1,0>:d    acc0.0<1;1,0>:d  {I@3}
        bfn.0xFE (8|M0)          r46.0<1>:ud   r105.0<1;0>:ud    r32.0<1;0>:ud     r5.6<0>:ud       {I@1} // s0|s1|s2
L7344:
        join (8|M0)                          L29536                                
L7360:
        shr (8|M0)               r38.0<1>:ud   r46.0<1;1,0>:ud   23:w               {I@2}
        and (8|M0)    (ne)f1.1   r68.0<1>:d    r46.0<1;1,0>:d    8388607:d              
        and (8|M0)               r62.0<1>:d    r38.0<1;1,0>:d    255:w               {Compacted,I@2}
(f1.1)  cmp (8|M0)    (eq)f1.1   null<1>:d     r62.0<1;1,0>:d    255:w               {I@1}
(~f1.1) goto (8|M0)                          L7456                  L7456                
L7432:
        mov (8|M0)               r46.0<1>:f    qnan(0x0):f                               {Compacted}
        goto (8|M0)                          L7456                  L11856                
L7456:
        join (8|M0)                          L11856                                
L7472:
        cmp (8|M0)    (eq)f1.0   null<1>:d     r68.0<1;1,0>:d    0:w              
(f1.0)  cmp (8|M0)    (eq)f1.0   null<1>:d     r62.0<1;1,0>:d    255:w              
(f1.0)  goto (8|M0)                          L11856                  L11856                
L7520:
        or (8|M0)     (eq)f1.1   null<1>:d     r62.0<1;1,0>:d    r68.0<1;1,0>:d  
(~f1.1) goto (8|M0)                          L7584                  L7584                
L7552:
        mov (8|M0)               r46.0<1>:f    0x3EE50000:f                              
        goto (8|M0)                          L7584                  L11856                
L7584:
        join (8|M0)                          L11856                                
L7600:
        cmp (8|M0)    (gt)f1.0   null<1>:d     r46.0<1;1,0>:d    -1:w               {F@1}
        cmp (8|M0)    (gt)f1.1   null<1>:ud    r62.0<1;1,0>:ud   0x7D:uw             
(f1.0)  goto (8|M0)                          L7872                  L7872                
L7648:
(f1.1)  goto (8|M0)                          L7760                  L7760                
L7664:
        mov (8|M0)               r83.0<1>:f    0x3EE50000:f                              
        mov (8|M0)               r75.0<1>:f    r46.0<1;1,0>:f                   {Compacted}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        call (8|M0)              r6.4          L42456                                 {A@1}
L7736:
        mov (8|M0)               r46.0<1>:f    r120.0<1;1,0>:f                  {Compacted,I@5}
        goto (8|M0)                          L7760                  L11856                
L7760:
        join (8|M0)                          L7872                                
L7776:
        mov (8|M0)               r83.0<1>:f    r46.0<1;1,0>:f                   {Compacted,F@1}
        mov (8|M0)               r75.0<1>:f    0x3EE50000:f                              
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        call (8|M0)              r6.4          L42456                                 {A@1}
L7848:
        mov (8|M0)               r46.0<1>:f    r120.0<1;1,0>:f                  {Compacted}
        goto (8|M0)                          L7872                  L11856                
L7872:
        join (8|M0)                          L11856                                
L7888:
(f1.1)  goto (8|M0)                          L10008                  L10008                
L7904:
        cmp (8|M0)    (ne)f1.0   null<1>:d     r62.0<1;1,0>:d    0:w              
        add (8|M0)               r93.0<1>:d    -r62.0<1;1,0>:d   125:w               {Compacted}
(f1.0)  sel (8|M0)               r82.0<1>:d    r93.0<1;1,0>:d    124:w               {I@1}
        cmp (8|M0)    (lt)f0.1   null<1>:d     r82.0<1;1,0>:d    1:w               {I@1}
(f0.1)  goto (8|M0)                          L9096                  L9096                
L7976:
        cmp (8|M0)    (eq)f1.1   null<1>:d     r82.0<1;1,0>:d    1:w              
(f1.1)  goto (8|M0)                          L8680                  L8680                
L8008:
        cmp (8|M0)    (lt)f0.1   null<1>:ud    r82.0<1;1,0>:ud   0x18:uw             
(f0.1)  goto (8|M0)                          L8440                  L8440                
L8040:
        cmp (8|M0)    (ne)f0.1   r88.0<1>:d    r62.0<1;1,0>:d    0:w              
        cmp (8|M0)    (lt)f1.1   null<1>:d     r82.0<1;1,0>:d    25:w              
        mov (8|M0)               r74.0<1>:d    -r88.0<1;1,0>:d                  {I@2}
(f1.1)  goto (8|M0)                          L8248                  L8248                
L8104:
        cmp (8|M0)    (eq)f1.0   null<1>:d     r82.0<1;1,0>:d    25:w              
        cmp (8|M0)    (ne)f0.1   r92.0<1>:d    r68.0<1;1,0>:d    0:w              
        cmp (8|M0)    (ne)f1.1   r104.0<1>:d   r46.0<1;1,0>:d    0:w               {F@1}
(f1.0)  sel (8|M0)               r74.0<1>:d    -r88.0<1;1,0>:d   0:w              
(f1.0)  sel (8|M0)               acc0.0<1>:d   -r92.0<1;1,0>:d   -r104.0<1;1,0>:d {I@2}
        mov (8|M0)               r108.0<1>:f   r74.0<1;1,0>:f                   {Compacted,I@2}
        shl (8|M0)               r85.0<1>:d    acc0.0<1;1,0>:d   31:w              
        mov (8|M0)               r74.0<1>:d    0:w                               {F@1}
        asr (8|M0)               r71.0<1>:d    r85.0<1;1,0>:d    31:w               {Compacted,I@2}
        goto (8|M0)                          L8248                  L8320                
L8248:
        join (8|M0)                          L8320                                
L8264:
        shr (8|M0)               r103.0<1>:ud  r46.0<1;1,0>:ud   22:w              
        and (8|M0)               r102.0<1>:d   r46.0<1;1,0>:d    4194303:d              
        and (8|M0)               r108.0<1>:d   r103.0<1;1,0>:d   1:w               {Compacted,I@2}
        cmp (8|M0)    (ne)f1.1   r71.0<1>:d    r102.0<1;1,0>:d   0:w               {I@2}
L8320:
        join (8|M0)                          L8440                                
L8336:
        cmp (8|M0)    (ne)f1.0   r101.0<1>:d   r71.0<1;1,0>:d    0:w               {I@2}
(W)     mov (1|M0)               r6.12<2>:b    125:w                              
        mov (8|M0)               r39.0<1>:f    r108.0<1;1,0>:f                  {Compacted}
        mov (8|M0)               r71.0<1>:f    9.275385e-39:f                               {I@2}
        mov (8|M0)               r7.0<1>:b     r6.12<0;1,0>:b                   {I@1}
        mov (8|M0)               r110.0<1>:d   -r101.0<1;1,0>:d                
        goto (8|M0)                          L8440                  L9592                
L8440:
        join (8|M0)                          L8680                                
L8456:
        add (8|M0)               acc0.0<1>:d   r82.0<1;1,0>:d    -2:w               {Compacted}
(W)     mov (1|M0)               r6.6<1>:hf    -qnan(0x1FF):hf                              {I@5}
        add (8|M0)               acc2.0<1>:d   r82.0<1;1,0>:d    -1:w               {Compacted}
        add (8|M0)               r2.0<1>:d     -r82.0<1;1,0>:d   23:w               {Compacted}
        shr (8|M0)               r100.0<1>:ud  r68.0<1;1,0>:ud   acc0.0<1;1,0>:d 
        shl (8|M0)               r103.0<1>:d   r6.6<0;1,0>:w     acc0.0<1;1,0>:d  {F@1}
(W)     mov (1|M0)               r6.6<1>:hf    0x1:hf                              {I@1}
        shr (8|M0)               r119.0<1>:ud  r68.0<1;1,0>:ud   r82.0<1;1,0>:d  
        shr (8|M0)               r118.0<1>:ud  r68.0<1;1,0>:ud   acc2.0<1;1,0>:d 
        bfn.0x60 (8|M0)          r124.0<1>:ud  r103.0<1;0>:ud    r5.7<0;0>:ud      r68.0<1>:ud      // (s0^s1)&s2
        shl (8|M0)               r2.0<1>:d     r6.6<0;1,0>:w     r2.0<1;1,0>:d    {F@1}
(~f1.0) mov (8|M0)               r2.0<1>:d     0:w                              
        and (8|M0)               r125.0<1>:d   r100.0<1;1,0>:d   1:w               {Compacted}
        and (8|M0)               r74.0<1>:d    r118.0<1;1,0>:d   1:w               {Compacted,I@5}
        cmp (8|M0)    (ne)f0.1   r87.0<1>:d    r124.0<1;1,0>:d   0:w               {I@5}
        or (8|M0)                r106.0<1>:d   r119.0<1;1,0>:d   r2.0<1;1,0>:d    {Compacted,I@4}
        goto (8|M0)                          L8680                  L8768                
L8680:
        join (8|M0)                          L8768                                
L8696:
        and (8|M0)               r74.0<1>:d    r46.0<1;1,0>:d    1:w               {Compacted}
        shr (8|M0)               r106.0<1>:ud  r68.0<1;1,0>:ud   1:w              
(f1.0)  goto (8|M0)                          L8768                  L8984                
L8736:
        mov (8|M0)               r125.0<1>:d   0:w                              
        mov (8|M0)               r87.0<1>:d    0:w                              
L8768:
        join (8|M0)                          L8984                                
L8784:
        cmp (8|M0)    (ne)f1.1   r107.0<1>:d   r87.0<1;1,0>:d    0:w               {I@2}
        cmp (8|M0)    (gt)f1.0   null<1>:ud    r106.0<1;1,0>:ud  0x1AFFFF:ud             
        add (8|M0)               r71.0<1>:d    r106.0<1;1,0>:d   6619136:d              
        mov (8|M0)               r110.0<1>:d   -r107.0<1;1,0>:d                 {I@3}
(f1.0)  goto (8|M0)                          L8920                  L8920                
L8864:
(W)     mov (1|M0)               r6.12<2>:b    125:w                              
        mov (8|M0)               r39.0<1>:f    r125.0<1;1,0>:f                  {Compacted}
        mov (8|M0)               r7.0<1>:b     r6.12<0;1,0>:b                   {I@1}
        goto (8|M0)                          L8920                  L9592                
L8920:
        join (8|M0)                          L8984                                
L8936:
        cmp (8|M0)    (eq)f0.1   null<1>:d     r125.0<1;1,0>:d   1:w              
(~f0.1) sel (8|M0)               r110.0<1>:d   -r107.0<1;1,0>:d  1:w              
        goto (8|M0)                          L8984                  L9032                
L8984:
        join (8|M0)                          L9032                                
L9000:
        add (8|M0)               r71.0<1>:d    r106.0<1;1,0>:d   10813440:d              
        mov (8|M0)               r110.0<1>:d   0:w                              
L9032:
        join (8|M0)                          L9096                                
L9048:
        shr (8|M0)               r99.0<1>:ud   r71.0<1;1,0>:ud   1:w               {I@3}
        and (8|M0)               r105.0<1>:d   r99.0<1;1,0>:d    4194303:d               {I@1}
        goto (8|M0)                          L9096                  L9504                
L9096:
        join (8|M0)                          L9504                                
L9112:
        cmp (8|M0)    (gt)f1.1   null<1>:ud    r68.0<1;1,0>:ud   0x1AFFFF:ud             
        add (8|M0)               r71.0<1>:d    r68.0<1;1,0>:d    6619136:d              
(f1.1)  goto (8|M0)                          L9392                  L9392                
L9160:
(f1.0)  goto (8|M0)                          L9272                  L9272                
L9176:
(W)     mov (1|M0)               r6.12<2>:b    125:w                              
        mov (8|M0)               r74.0<1>:d    0:w                              
        mov (8|M0)               r39.0<1>:d    0:w                               {F@1}
        mov (8|M0)               r110.0<1>:d   0:w                              
        mov (8|M0)               r7.0<1>:b     r6.12<0;1,0>:b                   {I@4}
        goto (8|M0)                          L9272                  L9592                
L9272:
        join (8|M0)                          L9392                                
L9288:
(W)     mov (1|M0)               r6.12<2>:b    126:w                              
        and (8|M0)               r74.0<1>:d    r46.0<1;1,0>:d    1:w               {Compacted}
        shr (8|M0)               r71.0<1>:ud   r71.0<1;1,0>:ud   1:w              
        mov (8|M0)               r39.0<1>:d    0:w                              
        mov (8|M0)               r110.0<1>:d   0:w                              
        mov (8|M0)               r7.0<1>:b     r6.12<0;1,0>:b                   {I@5}
        goto (8|M0)                          L9392                  L9592                
L9392:
        join (8|M0)                          L9504                                
L9408:
        shr (8|M0)               r80.0<1>:ud   r71.0<1;1,0>:ud   1:w               {I@6}
        mov (8|M0)               r110.0<1>:d   0:w                              
        and (8|M0)               r91.0<1>:d    r80.0<1;1,0>:d    4194303:d               {I@2}
        or (8|M0)                r80.0<1>:d    r80.0<1;1,0>:d    4194304:d              
        mov (8|M0)               r74.0<1>:d    0:w                              
(f1.0)  sel (8|M0)               r105.0<1>:d   r80.0<1;1,0>:d    r91.0<1;1,0>:d   {I@2}
L9504:
        join (8|M0)                          L9592                                
L9520:
        and (8|M0)               acc0.0<1>:d   r71.0<1;1,0>:d    1:w               {Compacted}
(W)     mov (1|M0)               r6.12<2>:b    126:w                              
        mov (8|M0)               r39.0<1>:f    r74.0<1;1,0>:f                   {Compacted,I@5}
        mov (8|M0)               r71.0<1>:f    r105.0<1;1,0>:f                  {Compacted,A@2}
        mov (8|M0)               r74.0<1>:d    acc0.0<1;1,0>:d                  {F@2}
        mov (8|M0)               r7.0<1>:b     r6.12<0;1,0>:b                   {I@2}
L9592:
        join (8|M0)                          L10008                                
L9608:
        shl (8|M0)               r104.0<1>:d   r74.0<1;1,0>:d    2:w               {Compacted,I@3}
        shl (8|M0)               r98.0<1>:d    r39.0<1;1,0>:d    1:w               {Compacted}
        bfn.0xFE (8|M0)          r99.0<1>:ud   r104.0<1;0>:ud    r98.0<1;0>:ud     r110.0<1>:ud     {I@1} // s0|s1|s2
        cmp (8|M0)    (eq)f0.1   null<1>:d     r99.0<1;1,0>:d    0:w               {I@1}
(~f0.1) goto (8|M0)                          L9704                  L9704                
L9672:
        mov (8|M0)               r117.0<1>:d   0:w                              
        goto (8|M0)                          L9704                  L9864                
L9704:
        join (8|M0)                          L9864                                
L9720:
        cmp (8|M0)    (gt)f1.1   null<1>:ud    r99.0<1;1,0>:ud   0x4:uw             
(~f1.1) goto (8|M0)                          L9784                  L9784                
L9752:
        mov (8|M0)               r117.0<1>:d   1:w                              
        goto (8|M0)                          L9784                  L9864                
L9784:
        join (8|M0)                          L9864                                
L9800:
        and (8|M0)    (ne)f0.1   null<1>:d     r71.0<1;1,0>:d    1:w               {F@1}
(W)     mov (1|M0)               r6.6<1>:hf    0x1:hf                             
(f0.1)  cmp (8|M0)    (eq)f0.1   null<1>:d     r99.0<1;1,0>:d    4:w              
(f0.1)  sel (8|M0)               r117.0<1>:d   r6.6<0;1,0>:w     0:w               {F@1}
L9864:
        join (8|M0)                          L10008                                
L9880:
        add (8|M0)               r123.0<1>:d   r71.0<1;1,0>:d    r117.0<1;1,0>:d  {Compacted,I@2}
        mov (8|M0)               r122.0<1>:d   r7.0<1;1,0>:ub                  
        cmp (8|M0)    (eq)f1.0   r90.0<1>:d    r123.0<1;1,0>:d   8388608:d               {I@2}
        cmp (8|M0)    (eq)f0.1   null<1>:d     r123.0<1;1,0>:d   8388608:d              
        add3 (8|M0)              acc0.0<1>:d   r122.0<1;0>:d     -r90.0<1;0>:d     0:w               {I@2}
(f0.1)  mov (8|M0)               r123.0<1>:d   0:w                              
        shl (8|M0)               r122.0<1>:d   acc0.0<1;1,0>:d   23:w              
        or (8|M0)                r46.0<1>:d    r122.0<1;1,0>:d   r123.0<1;1,0>:d  {Compacted,I@1}
        goto (8|M0)                          L10008                  L11856                
L10008:
        join (8|M0)                          L11856                                
L10024:
        mov (8|M0)               r7.0<1>:b     r38.0<4;1,0>:b                  
        cmp (8|M0)    (lt)f1.0   null<1>:w     r7.0<1;1,0>:b     126:w               {I@1}
(f1.0)  goto (8|M0)                          L10184                  L10184                
L10072:
        cmp (8|M0)    (eq)f0.1   null<1>:w     r7.0<1;1,0>:b     126:w              
(~f0.1) goto (8|M0)                          L10184                  L10232                
L10104:
        mov (8|M0)               r89.0<1>:d    0:w                              
        mov (8|M0)               r118.0<1>:d   0:w                              
        mov (8|M0)               r30.0<1>:d    0:w                              
        mov (8|M0)               r38.0<1>:f    0x728000:f                              
        goto (8|M0)                          L10184                  L10880                
L10184:
        join (8|M0)                          L10232                                
L10200:
        cmp (8|M0)    (eq)f1.1   null<1>:w     r7.0<1;1,0>:b     125:w              
(f1.1)  goto (8|M0)                          L10232                  L11096                
L10232:
        join (8|M0)                          L10880                                
L10248:
        add (8|M0)               r120.0<1>:d   r62.0<1;1,0>:d    -125:w               {Compacted}
        cmp (8|M0)    (lt)f1.0   null<1>:ud    r120.0<1;1,0>:ud  0x18:uw              {I@1}
(f1.0)  goto (8|M0)                          L10656                  L10656                
L10288:
        cmp (8|M0)    (lt)f0.1   null<1>:w     r7.0<1;1,0>:b     -106:w              
(f0.1)  goto (8|M0)                          L10432                  L10432                
L10320:
        cmp (8|M0)    (eq)f1.1   null<1>:w     r7.0<1;1,0>:b     -106:w              
(~f1.1) goto (8|M0)                          L10432                  L10560                
L10352:
        mov (8|M0)               r89.0<1>:d    0:w                              
        mov (8|M0)               r118.0<1>:d   1:w                              
        mov (8|M0)               r30.0<1>:d    -1:w                              
        mov (8|M0)               r38.0<1>:d    0:w                               {F@1}
        goto (8|M0)                          L10432                  L10880                
L10432:
        join (8|M0)                          L10560                                
L10448:
        cmp (8|M0)    (eq)f1.0   null<1>:w     r7.0<1;1,0>:b     -107:w              
(~f1.0) goto (8|M0)                          L10560                  L10560                
L10480:
        mov (8|M0)               r89.0<1>:d    1:w                              
        mov (8|M0)               r118.0<1>:d   1:w                              
        mov (8|M0)               r30.0<1>:d    -1:w                              
        mov (8|M0)               r38.0<1>:d    0:w                              
        goto (8|M0)                          L10560                  L10880                
L10560:
        join (8|M0)                          L10656                                
L10576:
        mov (8|M0)               r89.0<1>:d    0:w                              
        mov (8|M0)               r118.0<1>:d   0:w                              
        mov (8|M0)               r30.0<1>:d    -1:w                              
        mov (8|M0)               r38.0<1>:d    0:w                              
        goto (8|M0)                          L10656                  L10880                
L10656:
        join (8|M0)                          L10880                                
L10672:
(W)     mov (1|M0)               r6.4<1>:f     9.275385e-39:f                              
        add (8|M0)               acc0.0<1>:d   r62.0<1;1,0>:d    -127:w               {Compacted}
(W)     mov (1|M0)               r6.6<1>:hf    -qnan(0x1FF):hf                             
        add (8|M0)               acc2.0<1>:d   r62.0<1;1,0>:d    -126:w               {Compacted}
        add (8|M0)               r86.0<1>:d    -r62.0<1;1,0>:d   148:w               {Compacted}
        shr (8|M0)               r97.0<1>:ud   r6.4<0;1,0>:ud    acc0.0<1;1,0>:d  {F@2}
        shl (8|M0)               r117.0<1>:d   r6.6<0;1,0>:w     acc0.0<1;1,0>:d  {F@1}
(W)     mov (1|M0)               r6.6<1>:hf    0x1:hf                              {I@1}
        shr (8|M0)               r121.0<1>:ud  r6.4<0;1,0>:ud    r120.0<1;1,0>:d 
        shr (8|M0)               r47.0<1>:ud   r6.4<0;1,0>:ud    acc2.0<1;1,0>:d 
        and (8|M0)               r117.0<1>:d   r117.0<1;1,0>:d   6619136:d              
        shl (8|M0)               r86.0<1>:d    r6.6<0;1,0>:w     r86.0<1;1,0>:d   {F@1}
        and (8|M0)               r118.0<1>:d   r97.0<1;1,0>:d    1:w               {Compacted}
        and (8|M0)               r89.0<1>:d    r47.0<1;1,0>:d    1:w               {Compacted,I@4}
        cmp (8|M0)    (ne)f1.0   r30.0<1>:d    r117.0<1;1,0>:d   6619136:d               {I@4}
        or (8|M0)                r38.0<1>:d    r121.0<1;1,0>:d   r86.0<1;1,0>:d   {Compacted,I@4}
L10880:
        join (8|M0)                          L11096                                
L10896:
        add (8|M0)               r76.0<1>:d    r68.0<1;1,0>:d    r38.0<1;1,0>:d   {Compacted,I@2}
        cmp (8|M0)    (ne)f0.1   r110.0<1>:d   r30.0<1;1,0>:d    0:w              
        cmp (8|M0)    (gt)f0.1   null<1>:ud    r76.0<1;1,0>:ud   0x7FFFFF:ud              {I@2}
        mov (8|M0)               r117.0<1>:d   -r110.0<1;1,0>:d                 {I@2}
(f0.1)  goto (8|M0)                          L11000                  L11000                
L10968:
        mov (8|M0)               r75.0<1>:d    r118.0<1;1,0>:d                 
        goto (8|M0)                          L11000                  L11384                
L11000:
        join (8|M0)                          L11096                                
L11016:
        cmp (8|M0)    (eq)f1.1   null<1>:d     r118.0<1;1,0>:d   1:w              
        shr (8|M0)               r96.0<1>:ud   r76.0<1;1,0>:ud   1:w              
        and (8|M0)               r98.0<1>:d    r96.0<1;1,0>:d    4194303:d               {I@1}
(~f1.1) sel (8|M0)               r117.0<1>:d   -r110.0<1;1,0>:d  1:w              
        goto (8|M0)                          L11096                  L11320                
L11096:
        join (8|M0)                          L11320                                
L11112:
        cmp (8|M0)    (gt)f1.0   null<1>:ud    r68.0<1;1,0>:ud   0x1AFFFF:ud             
        add (8|M0)               r76.0<1>:d    r68.0<1;1,0>:d    6619136:d              
(f1.0)  goto (8|M0)                          L11240                  L11240                
L11160:
        and (8|M0)               r89.0<1>:d    r46.0<1;1,0>:d    1:w               {Compacted}
        shr (8|M0)               r76.0<1>:ud   r76.0<1;1,0>:ud   1:w               {I@3}
        add (8|M0)               r62.0<1>:d    r62.0<1;1,0>:d    1:w               {Compacted}
        mov (8|M0)               r75.0<1>:d    0:w                              
        mov (8|M0)               r117.0<1>:d   0:w                              
        goto (8|M0)                          L11240                  L11384                
L11240:
        join (8|M0)                          L11320                                
L11256:
        shr (8|M0)               r95.0<1>:ud   r76.0<1;1,0>:ud   1:w               {I@6}
        mov (8|M0)               r117.0<1>:d   0:w                              
        mov (8|M0)               r89.0<1>:d    0:w                              
        or (8|M0)                r98.0<1>:d    r95.0<1;1,0>:d    4194304:d               {I@3}
L11320:
        join (8|M0)                          L11384                                
L11336:
        and (8|M0)               acc0.0<1>:d   r76.0<1;1,0>:d    1:w               {Compacted}
        add (8|M0)               r62.0<1>:d    r62.0<1;1,0>:d    1:w               {Compacted}
        mov (8|M0)               r75.0<1>:f    r89.0<1;1,0>:f                   {Compacted,I@5}
        mov (8|M0)               r76.0<1>:f    r98.0<1;1,0>:f                   {Compacted,A@2}
        mov (8|M0)               r89.0<1>:d    acc0.0<1;1,0>:d                  {F@2}
L11384:
        join (8|M0)                          L11856                                
L11400:
        shl (8|M0)               r112.0<1>:d   r89.0<1;1,0>:d    2:w               {Compacted,I@2}
        shl (8|M0)               r94.0<1>:d    r75.0<1;1,0>:d    1:w               {Compacted}
        bfn.0xFE (8|M0)          r116.0<1>:ud  r112.0<1;0>:ud    r94.0<1;0>:ud     r117.0<1>:ud     {I@1} // s0|s1|s2
        cmp (8|M0)    (eq)f0.1   null<1>:d     r116.0<1;1,0>:d   0:w               {I@1}
(~f0.1) goto (8|M0)                          L11496                  L11496                
L11464:
        mov (8|M0)               r31.0<1>:d    0:w                              
        goto (8|M0)                          L11496                  L11656                
L11496:
        join (8|M0)                          L11656                                
L11512:
        cmp (8|M0)    (gt)f1.1   null<1>:ud    r116.0<1;1,0>:ud  0x4:uw             
(~f1.1) goto (8|M0)                          L11576                  L11576                
L11544:
        mov (8|M0)               r31.0<1>:d    1:w                              
        goto (8|M0)                          L11576                  L11656                
L11576:
        join (8|M0)                          L11656                                
L11592:
        and (8|M0)    (ne)f1.1   null<1>:d     r76.0<1;1,0>:d    1:w               {F@1}
(W)     mov (1|M0)               r6.6<1>:hf    0x1:hf                             
(f1.1)  cmp (8|M0)    (eq)f1.1   null<1>:d     r116.0<1;1,0>:d   4:w              
(f1.1)  sel (8|M0)               r31.0<1>:d    r6.6<0;1,0>:w     0:w               {F@1}
L11656:
        join (8|M0)                          L11856                                
L11672:
        add (8|M0)               r30.0<1>:d    r76.0<1;1,0>:d    r31.0<1;1,0>:d   {Compacted,I@2}
        cmp (8|M0)    (eq)f0.1   r93.0<1>:d    r30.0<1;1,0>:d    8388608:d               {I@1}
        cmp (8|M0)    (eq)f1.1   null<1>:d     r30.0<1;1,0>:d    8388608:d              
        add3 (8|M0)              r86.0<1>:d    r62.0<1;0>:d      -r93.0<1;0>:d     0:w               {I@2}
        cmp (8|M0)    (eq)f1.0   null<1>:d     r86.0<1;1,0>:d    255:w               {I@1}
(~f1.0) goto (8|M0)                          L11784                  L11784                
L11760:
        mov (8|M0)               r46.0<1>:f    inf:f                               {Compacted}
        goto (8|M0)                          L11784                  L11856                
L11784:
        join (8|M0)                          L11856                                
L11800:
(~f1.1) sel (8|M0)               r95.0<1>:d    r30.0<1;1,0>:d    0:w              
        and (8|M0)               r89.0<1>:d    r46.0<1;1,0>:d    -2147483648:d               {F@1}
        shl (8|M0)               r92.0<1>:d    r86.0<1;1,0>:d    23:w               {Compacted}
        bfn.0xFE (8|M0)          r46.0<1>:ud   r89.0<1;0>:ud     r92.0<1;0>:ud     r95.0<1>:ud      {I@1} // s0|s1|s2
L11856:
        join (8|M0)                          L29536                                
L11872:
        mov (8|M0)               r2.0<1>:hf    r46.0<1;1,0>:f                   {I@2}
(W)     mov (1|M0)               r6.6<1>:hf    0x1:hf                             
        mov (8|M0)               r63.0<1>:f    r2.0<1;1,0>:hf                   {F@2}
(f0.0)  sel (8|M0)               r2.0<1>:uw    r6.6<0;1,0>:uw    0x0:uw              {A@1}
        shr (8|M0)               r3.0<1>:ud    r63.0<1;1,0>:ud   23:w              
        and (8|M0)    (ne)f1.0   r23.0<1>:d    r63.0<1;1,0>:d    8388607:d              
        and (8|M0)               r37.0<1>:d    r3.0<1;1,0>:d     255:w               {Compacted,I@2}
(f1.0)  cmp (8|M0)    (eq)f1.0   null<1>:d     r37.0<1;1,0>:d    255:w               {I@1}
(f1.0)  sel (8|M0)               r30.0<1>:uw   r6.6<0;1,0>:uw    0x0:uw             
        or (8|M0)     (ne)f0.1   null<1>:uw    r30.0<1;1,0>:uw   r2.0<1;1,0>:uw   {I@1}
(~f0.1) goto (8|M0)                          L12064                  L12064                
L12040:
        mov (8|M0)               r45.0<1>:f    qnan(0x0):f                               {Compacted}
        goto (8|M0)                          L12064                  L18440                
L12064:
        join (8|M0)                          L18440                                
L12080:
        cmp (8|M0)    (eq)f0.1   null<1>:d     r23.0<1;1,0>:d    0:w              
        cmp (8|M0)    (eq)f1.1   null<1>:d     r26.0<1;1,0>:d    0:w              
(W)     mov (1|M0)               r6.6<1>:hf    0x1:hf                             
        xor (8|M0)               r30.0<1>:d    r63.0<1;1,0>:d    r29.0<1;1,0>:d   {Compacted}
(f0.1)  cmp (8|M0)    (eq)f0.1   null<1>:d     r37.0<1;1,0>:d    255:w              
(f1.1)  cmp (8|M0)    (eq)f1.1   null<1>:d     r27.0<1;1,0>:d    255:w              
(f0.1)  sel (8|M0)               r29.0<1>:uw   r6.6<0;1,0>:uw    0x0:uw              {F@1}
(f1.1)  sel (8|M0)               r2.0<1>:uw    r6.6<0;1,0>:uw    0x0:uw             
        or (8|M0)     (ne)f1.1   null<1>:uw    r29.0<1;1,0>:uw   r2.0<1;1,0>:uw   {I@1}
(f1.1)  goto (8|M0)                          L18408                  L18408                
L12232:
        or (8|M0)     (eq)f0.1   null<1>:d     r27.0<1;1,0>:d    r26.0<1;1,0>:d  
        or (8|M0)                r91.0<1>:d    r37.0<1;1,0>:d    r23.0<1;1,0>:d   {Compacted}
(~f0.1) cmp (8|M0)    (eq)f0.1   null<1>:d     r91.0<1;1,0>:d    0:w               {I@1}
(~f0.1) goto (8|M0)                          L12312                  L12312                
L12288:
        mov (8|M0)               r45.0<1>:f    0.0:f                               {Compacted}
        goto (8|M0)                          L12312                  L18440                
L12312:
        join (8|M0)                          L18408                                
L12328:
        cmp (8|M0)    (eq)f0.1   null<1>:d     r37.0<1;1,0>:d    0:w              
        cmp (8|M0)    (eq)f1.1   null<1>:d     r27.0<1;1,0>:d    0:w              
        add (8|M0)               r50.0<1>:d    r37.0<1;1,0>:d    -127:w               {Compacted}
        add (8|M0)               r49.0<1>:d    r27.0<1;1,0>:d    -127:w               {Compacted}
(f0.1)  mov (8|M0)               r50.0<1>:d    -126:w                              
(f1.1)  mov (8|M0)               r49.0<1>:d    -126:w                              
        add (8|M0)               r36.0<1>:d    r50.0<1;1,0>:d    r49.0<1;1,0>:d   {Compacted,I@1}
        cmp (8|M0)    (gt)f1.0   null<1>:d     r36.0<1;1,0>:d    127:w               {I@1}
(f1.0)  goto (8|M0)                          L18336                  L18336                
L12448:
        or (8|M0)     (eq)f1.0   null<4>:b     r3.0<1;1,0>:d     r28.0<1;1,0>:d  
(f1.0)  goto (8|M0)                          L18264                  L18264                
L12480:
(W)     mov (1|M0)               r6.6<1>:hf    0.0:hf                             
(W)     mov (1|M0)               r3.4<1>:d     0:w                              
(f0.1)  sel (8|M0)               acc0.0<1>:d   r6.6<0;1,0>:w     8388608:d               {F@1}
(f1.1)  sel (8|M0)               acc2.0<1>:d   r6.6<0;1,0>:w     8388608:d              
        or (8|M0)                r83.0<1>:d    acc0.0<1;1,0>:d   r23.0<1;1,0>:d  
        or (8|M0)                r79.0<1>:d    acc2.0<1;1,0>:d   r26.0<1;1,0>:d  
(W)     mov (1|M0)               r2.7<1>:f     -0.0:f                               {Compacted}
        mul (8|M0)               acc0.0<1>:ud  r83.0<1;1,0>:ud   r79.0<2;1,0>:uw  {I@1}
        mach (8|M0)              r47.0<1>:ud   r83.0<1;1,0>:ud   r79.0<1;1,0>:ud  {AccWrEn,Compacted}
(W)     mov (2|M0)               r2.4<1>:d     0:w                              
        mov (8|M0)               acc0.0<1>:ud  acc0.0<1;1,0>:ud                
        mov (8|M0)               r43.0<1>:f    r47.0<1;1,0>:f                   {Compacted,I@3}
        mov (8|M0)               r38.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
L12656:
(W)     shl (1|M0)               r3.1<1>:d     r2.7<0;1,0>:d     31:w               {F@2}
(W)     shr (1|M0)               r3.0<1>:ud    r3.4<0;1,0>:ud    1:w              
(W)     cmp (8|M0)    (gt)f1.1   null<1>:ud    r2.4<0;1,0>:ud    0x3E:uw              {I@5}
(W)     or (1|M0)                r3.4<1>:d     r3.0<0;1,0>:d     r3.1<0;1,0>:d    {I@2}
        bfn.0xA8 (8|M0)          r103.0<1>:ud  r38.0<1;0>:ud     r3.0<0;0>:ud      r3.1<0>:ud       // s0&(s1|s2)
(W)     shr (1|M0)               r2.6<1>:ud    r2.7<0;1,0>:ud    1:w              
(W&f1.1) cmp (8|M0)   (eq)f1.1   null<1>:d     r2.5<0;1,0>:d     0:w              
        cmp (8|M0)    (eq)f1.0   null<1>:d     r103.0<1;1,0>:d   r3.4<0;1,0>:d    {I@3}
        and (8|M0)               r102.0<1>:d   r43.0<1;1,0>:d    r2.6<0;1,0>:d    {Compacted,A@1}
(W)     mov (1|M0)               r3.12<1>:hf   0x1:hf                             
(W&~f1.1) cmp (8|M0)  (gt)f1.1   null<1>:ud    r2.5<0;1,0>:ud    0x0:uw             
(f1.0)  cmp (8|M0)    (eq)f1.0   null<1>:d     r102.0<1;1,0>:d   r2.6<0;1,0>:d    {I@2}
(W)     addc (1|M0)              r26.0<1>:ud   r2.4<0;1,0>:ud    0x1:ud              {AccWrEn}
        mov (8|M0)               r53.0<1>:d    r2.4<0;1,0>:d                   
(f1.1)  sel (8|M0)               r3.0<1>:uw    r3.12<0;1,0>:uw   0x0:uw              {F@1}
(f1.0)  sel (8|M0)               r2.0<1>:uw    r3.12<0;1,0>:uw   0x0:uw             
(W)     mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        or (8|M0)     (ne)f1.0   null<1>:uw    r3.0<1;1,0>:uw    r2.0<1;1,0>:uw   {I@2}
(W)     add (1|M0)               r3.5<1>:ud    r7.0<0;1,0>:ud    r2.5<0;1,0>:ud   {I@2}
        mov (8|M0)               r57.0<1>:d    r2.5<0;1,0>:d                   
        mov (8|M0)               r88.0<1>:f    r26.0<0;1,0>:f                   {Compacted}
        mov (8|M0)               r22.0<1>:d    r3.5<0;1,0>:d                    {I@2}
(f1.0)  goto (8|M0)                          L13064                  L13064                
L13000:
(W)     mov (1|M0)               r2.7<1>:d     r2.6<0;1,0>:d                   
(W)     mov (1|M0)               r2.4<1>:d     r26.0<0;1,0>:d                  
(W)     mov (1|M0)               r2.5<1>:f     r3.5<0;1,0>:f                    {I@5}
(W)     jmpi                                 L12656                                
L13064:
        join (8|M0)                          L18264                                
L13080:
(W)     mov (1|M0)               r6.3<1>:f     8.68805e-44:f                              
(W)     mov (1|M0)               r7.0<1>:hf    0.0:hf                             
        subb (8|M0)              r106.0<1>:ud  r6.3<0;1,0>:ud    r53.0<1;1,0>:ud  {AccWrEn,Compacted,F@2}
        add3 (8|M0)              r125.0<1>:d   r36.0<1;0>:d      r106.0<1;0>:d     -46:w               {I@1}
        add3 (8|M0)              r37.0<1>:ud   -acc0.0<1;0>:ud   r7.0<0;0>:uw      -r57.0<1>:ud     {F@1}
        cmp (8|M0)    (gt)f1.0   null<1>:d     r125.0<1;1,0>:d   127:w               {I@2}
        add3 (8|M0)              r126.0<1>:d   r50.0<1;0>:d      r49.0<1;0>:d      r106.0<1>:d     
(f1.0)  goto (8|M0)                          L18192                  L18192                
L13200:
        cmp (8|M0)    (gt)f0.1   null<1>:d     r125.0<1;1,0>:d   -127:w              
(f0.1)  goto (8|M0)                          L15760                  L15760                
L13232:
        cmp (8|M0)    (lt)f1.1   null<1>:ud    r125.0<1;1,0>:ud  0xFFFFFF6B:ud             
(f1.1)  goto (8|M0)                          L15240                  L15240                
L13264:
(W)     mov (1|M0)               r6.3<1>:f     8.82818e-44:f                              
        add3 (8|M0)              r122.0<1>:d   r36.0<1;0>:d      r106.0<1;0>:d     104:w              
        subb (8|M0)              r36.0<1>:ud   r6.3<0;1,0>:ud    r53.0<1;1,0>:ud  {AccWrEn,Compacted,F@1}
(W)     mov (1|M0)               r7.0<1>:hf    0.0:hf                              {I@7}
        cmp (8|M0)    (gt)f1.0   null<1>:ud    r36.0<1;1,0>:ud   r122.0<1;1,0>:ud {I@1}
        add3 (8|M0)              r70.0<1>:ud   -acc0.0<1;0>:ud   r7.0<0;0>:uw      -r57.0<1>:ud     {F@1}
(f1.0)  cmp (8|M0)    (eq)f1.0   null<1>:d     r70.0<1;1,0>:d    0:w               {I@1}
(~f1.0) cmp (8|M0)    (gt)f1.0   null<1>:ud    r70.0<1;1,0>:ud   0x0:uw             
(f1.0)  goto (8|M0)                          L13464                  L13464                
L13400:
        add3 (8|M0)              acc0.0<1>:d   r126.0<1;0>:d     -r36.0<1;0>:d     104:w              
        mov (8|M0)               r84.0<1>:d    0:w                              
        shl (8|M0)               r85.0<1>:d    r38.0<1;1,0>:d    acc0.0<1;1,0>:d 
        goto (8|M0)                          L13464                  L15176                
L13464:
        join (8|M0)                          L15176                                
L13480:
        add3 (8|M0)              r39.0<1>:d    r36.0<1;0>:d      -r126.0<1;0>:d    -104:w              
        cmp (8|M0)    (lt)f1.0   null<1>:d     r39.0<1;1,0>:d    2:w               {I@1}
(f1.0)  goto (8|M0)                          L13624                  L13624                
L13528:
        cmp (8|M0)    (eq)f0.1   null<1>:d     r39.0<1;1,0>:d    2:w              
(~f0.1) goto (8|M0)                          L13624                  L13728                
L13560:
        shr (8|M0)               r44.0<1>:ud   r38.0<1;1,0>:ud   1:w              
        and (8|M0)               r33.0<1>:d    r38.0<1;1,0>:d    1:w               {Compacted}
        mov (8|M0)               r119.0<1>:d   0:w                              
        mov (8|M0)               r99.0<1>:f    r44.0<1;1,0>:f                   {Compacted,I@3}
        goto (8|M0)                          L13624                  L14608                
L13624:
        join (8|M0)                          L13728                                
L13640:
        cmp (8|M0)    (eq)f1.1   null<1>:d     r39.0<1;1,0>:d    1:w              
(~f1.1) goto (8|M0)                          L13728                  L13728                
L13672:
        mov (8|M0)               r119.0<1>:d   0:w                              
        mov (8|M0)               r33.0<1>:d    0:w                              
        mov (8|M0)               r99.0<1>:f    r38.0<1;1,0>:f                   {Compacted}
        goto (8|M0)                          L13728                  L14608                
L13728:
        join (8|M0)                          L14608                                
L13744:
        add3 (8|M0)              acc0.0<1>:d   r36.0<1;0>:d      -r122.0<1;0>:d    -1:w              
        and (8|M0)    (ne)f1.0   r78.0<1>:d    acc0.0<1;1,0>:d   63:w              
(f1.0)  goto (8|M0)                          L13824                  L13824                
L13792:
        mov (8|M0)               r29.0<1>:d    r38.0<1;1,0>:d                  
        goto (8|M0)                          L13824                  L13960                
L13824:
        join (8|M0)                          L13960                                
L13840:
        cmp (8|M0)    (lt)f0.1   null<1>:ud    r78.0<1;1,0>:ud   0x20:uw              {I@5}
(f0.1)  add (8|M0)               acc0.0<1>:d   -r78.0<1;1,0>:d   32:w              
(~f0.1) add (8|M0)               acc2.0<1>:d   r78.0<1;1,0>:d    -32:w              
(f0.1)  shr (8|M0)               r87.0<1>:ud   r38.0<1;1,0>:ud   r78.0<1;1,0>:d  
(f0.1)  shl (8|M0)               r29.0<1>:d    r43.0<1;1,0>:d    acc0.0<1;1,0>:d 
(~f0.1) shr (8|M0)               r44.0<1>:ud   r43.0<1;1,0>:ud   acc2.0<1;1,0>:d  {F@2}
(f0.1)  or (8|M0)                r44.0<1>:d    r87.0<1;1,0>:d    r29.0<1;1,0>:d   {I@2}
        mov (8|M0)               r29.0<1>:f    r44.0<1;1,0>:f                   {Compacted,I@1}
L13960:
        join (8|M0)                          L14608                                
L13976:
        add3 (8|M0)              r104.0<1>:d   r36.0<1;0>:d      -r122.0<1;0>:d    -2:w              
        and (8|M0)    (ne)f1.1   r77.0<1>:d    r104.0<1;1,0>:d   63:w               {I@1}
(f1.1)  goto (8|M0)                          L14056                  L14056                
L14024:
        mov (8|M0)               r44.0<1>:d    r38.0<1;1,0>:d                   {F@1}
        goto (8|M0)                          L14056                  L14184                
L14056:
        join (8|M0)                          L14184                                
L14072:
        cmp (8|M0)    (lt)f1.0   null<1>:ud    r77.0<1;1,0>:ud   0x20:uw              {I@5}
(f1.0)  add (8|M0)               acc0.0<1>:d   -r77.0<1;1,0>:d   32:w              
(~f1.0) add (8|M0)               acc2.0<1>:d   r77.0<1;1,0>:d    -32:w              
(f1.0)  shr (8|M0)               r85.0<1>:ud   r38.0<1;1,0>:ud   r77.0<1;1,0>:d  
(f1.0)  shl (8|M0)               r28.0<1>:d    r43.0<1;1,0>:d    acc0.0<1;1,0>:d 
(~f1.0) shr (8|M0)               r44.0<1>:ud   r43.0<1;1,0>:ud   acc2.0<1;1,0>:d 
(f1.0)  or (8|M0)                r44.0<1>:d    r85.0<1;1,0>:d    r28.0<1;1,0>:d   {I@2}
L14184:
        join (8|M0)                          L14608                                
L14200:
        and (8|M0)    (ne)f0.1   r27.0<1>:d    r104.0<1;1,0>:d   63:w              
        and (8|M0)               r33.0<1>:d    r44.0<1;1,0>:d    1:w               {Compacted,I@3}
(f0.1)  goto (8|M0)                          L14288                  L14288                
L14240:
        mov (8|M0)               r45.0<1>:d    -1:w                              
        mov (8|M0)               r62.0<1>:d    -1:w                              
        goto (8|M0)                          L14288                  L14472                
L14288:
        join (8|M0)                          L14472                                
L14304:
        cmp (8|M0)    (lt)f1.1   null<1>:ud    r27.0<1;1,0>:ud   0x20:uw              {I@7}
(f1.1)  goto (8|M0)                          L14408                  L14408                
L14336:
        add (8|M0)               acc0.0<1>:d   r27.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r6.6<1>:hf    -qnan(0x1FF):hf                             
        mov (8|M0)               r45.0<1>:d    0:w                              
        shl (8|M0)               r62.0<1>:d    r6.6<0;1,0>:w     acc0.0<1;1,0>:d  {F@1}
        goto (8|M0)                          L14408                  L14472                
L14408:
        join (8|M0)                          L14472                                
L14424:
(W)     mov (1|M0)               r6.6<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (8|M0)               r62.0<1>:d    -1:w                              
        shl (8|M0)               r45.0<1>:d    r6.6<0;1,0>:w     r27.0<1;1,0>:d   {F@1}
L14472:
        join (8|M0)                          L14608                                
L14488:
        bfn.0x28 (8|M0)          r84.0<1>:ud   r38.0<1;0>:ud     r45.0<1;0>:ud     r5.7<0>:ud       {I@2} // s0&(s1^s2)
        bfn.0x28 (8|M0)          r83.0<1>:ud   r43.0<1;0>:ud     r62.0<1;0>:ud     r5.7<0>:ud       // s0&(s1^s2)
        cmp (8|M0)    (ne)f1.1   null<1>:d     r84.0<1;1,0>:d    0:w               {I@2}
(W)     mov (1|M0)               r6.6<1>:hf    -qnan(0x1FF):hf                             
        mov (8|M0)               r99.0<1>:f    r29.0<1;1,0>:f                   {Compacted}
(~f1.1) cmp (8|M0)    (ne)f1.1   null<1>:d     r83.0<1;1,0>:d    0:w               {I@2}
(f1.1)  sel (8|M0)               acc0.0<1>:d   r6.6<0;1,0>:w     0:w               {F@2}
        mov (8|M0)               r119.0<1>:d   -acc0.0<1;1,0>:d                
L14608:
        join (8|M0)                          L15176                                
L14624:
        and (8|M0)    (ne)f1.0   r76.0<1>:d    r39.0<1;1,0>:d    63:w              
(f1.0)  goto (8|M0)                          L14688                  L14688                
L14656:
        mov (8|M0)               r44.0<1>:d    r38.0<1;1,0>:d                  
        goto (8|M0)                          L14688                  L14816                
L14688:
        join (8|M0)                          L14816                                
L14704:
        cmp (8|M0)    (lt)f0.1   null<1>:ud    r76.0<1;1,0>:ud   0x20:uw              {I@5}
(f0.1)  add (8|M0)               acc0.0<1>:d   -r76.0<1;1,0>:d   32:w              
(~f0.1) add (8|M0)               acc2.0<1>:d   r76.0<1;1,0>:d    -32:w              
(f0.1)  shr (8|M0)               r80.0<1>:ud   r38.0<1;1,0>:ud   r76.0<1;1,0>:d  
(f0.1)  shl (8|M0)               r26.0<1>:d    r43.0<1;1,0>:d    acc0.0<1;1,0>:d 
(~f0.1) shr (8|M0)               r44.0<1>:ud   r43.0<1;1,0>:ud   acc2.0<1;1,0>:d 
(f0.1)  or (8|M0)                r44.0<1>:d    r80.0<1;1,0>:d    r26.0<1;1,0>:d   {I@2}
L14816:
        join (8|M0)                          L15176                                
L14832:
        shl (8|M0)               r84.0<1>:d    r99.0<1;1,0>:d    2:w               {Compacted,F@1}
        shl (8|M0)               r79.0<1>:d    r33.0<1;1,0>:d    1:w               {Compacted}
        and (8|M0)               r84.0<1>:d    r84.0<1;1,0>:d    4:w               {Compacted,I@2}
        bfn.0xFE (8|M0)          r58.0<1>:ud   r84.0<1;0>:ud     r79.0<1;0>:ud     r119.0<1>:ud     {I@1} // s0|s1|s2
        cmp (8|M0)    (eq)f1.1   null<1>:d     r58.0<1;1,0>:d    0:w               {I@1}
(~f1.1) goto (8|M0)                          L14936                  L14936                
L14904:
        mov (8|M0)               r65.0<1>:d    0:w                              
        goto (8|M0)                          L14936                  L15096                
L14936:
        join (8|M0)                          L15096                                
L14952:
        cmp (8|M0)    (gt)f1.0   null<1>:ud    r58.0<1;1,0>:ud   0x4:uw             
(~f1.0) goto (8|M0)                          L15016                  L15016                
L14984:
        mov (8|M0)               r65.0<1>:d    1:w                              
        goto (8|M0)                          L15016                  L15096                
L15016:
        join (8|M0)                          L15096                                
L15032:
        and (8|M0)    (ne)f1.0   null<1>:d     r44.0<1;1,0>:d    1:w              
(W)     mov (1|M0)               r6.6<1>:hf    0x1:hf                             
(f1.0)  cmp (8|M0)    (eq)f1.0   null<1>:d     r58.0<1;1,0>:d    4:w              
(f1.0)  sel (8|M0)               r65.0<1>:d    r6.6<0;1,0>:w     0:w               {F@1}
L15096:
        join (8|M0)                          L15176                                
L15112:
        add (8|M0)               r46.0<1>:d    r65.0<1;1,0>:d    r44.0<1;1,0>:d   {Compacted,I@2}
(W)     mov (1|M0)               r6.3<1>:f     0x800000:f                               {Compacted}
        cmp (8|M0)    (gt)f1.1   null<1>:ud    r46.0<1;1,0>:ud   0x7FFFFF:ud              {I@1}
(~f1.1) sel (8|M0)               r85.0<1>:d    r46.0<1;1,0>:d    0:w              
(f1.1)  sel (8|M0)               r84.0<1>:d    r6.3<0;1,0>:d     0:w               {F@1}
L15176:
        join (8|M0)                          L15240                                
L15192:
        and (8|M0)               r78.0<1>:d    r30.0<1;1,0>:d    -2147483648:d              
        bfn.0xFE (8|M0)          r45.0<1>:ud   r78.0<1;0>:ud     r84.0<1;0>:ud     r85.0<1>:ud      {I@1} // s0|s1|s2
        goto (8|M0)                          L15240                  L18440                
L15240:
        join (8|M0)                          L15760                                
L15256:
        and (8|M0)    (ne)f0.1   r98.0<1>:d    r106.0<1;1,0>:d   63:w              
(f0.1)  goto (8|M0)                          L15336                  L15336                
L15288:
        mov (8|M0)               r115.0<1>:d   -1:w                              
        mov (8|M0)               r23.0<1>:d    -1:w                              
        goto (8|M0)                          L15336                  L15520                
L15336:
        join (8|M0)                          L15520                                
L15352:
        cmp (8|M0)    (lt)f1.1   null<1>:ud    r98.0<1;1,0>:ud   0x20:uw              {I@6}
(f1.1)  goto (8|M0)                          L15456                  L15456                
L15384:
        add (8|M0)               acc0.0<1>:d   r98.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r6.6<1>:hf    -qnan(0x1FF):hf                             
        mov (8|M0)               r115.0<1>:d   0:w                              
        shl (8|M0)               r23.0<1>:d    r6.6<0;1,0>:w     acc0.0<1;1,0>:d  {F@1}
        goto (8|M0)                          L15456                  L15520                
L15456:
        join (8|M0)                          L15520                                
L15472:
(W)     mov (1|M0)               r6.6<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (8|M0)               r23.0<1>:d    -1:w                              
        shl (8|M0)               r115.0<1>:d   r6.6<0;1,0>:w     r98.0<1;1,0>:d   {F@1}
L15520:
        join (8|M0)                          L15760                                
L15536:
        bfn.0x28 (8|M0)          r77.0<1>:ud   r38.0<1;0>:ud     r115.0<1;0>:ud    r5.7<0>:ud       {I@2} // s0&(s1^s2)
        bfn.0x28 (8|M0)          r76.0<1>:ud   r43.0<1;0>:ud     r23.0<1;0>:ud     r5.7<0>:ud       // s0&(s1^s2)
        cmp (8|M0)    (ne)f1.1   null<1>:d     r77.0<1;1,0>:d    0:w               {I@2}
        cmp (8|M0)    (gt)f1.0   null<1>:d     r30.0<1;1,0>:d    -1:w              
(~f1.1) cmp (8|M0)    (ne)f1.1   null<1>:d     r76.0<1;1,0>:d    0:w               {I@3}
(f1.1)  cmp (8|M0)    (eq)f1.1   null<1>:d     r125.0<1;1,0>:d   -150:w              
(f1.0)  goto (8|M0)                          L15696                  L15696                
L15648:
(W)     mov (1|M0)               r6.3<1>:ud    0x80000001:ud                             
(f1.1)  sel (8|M0)               r45.0<1>:f    r6.3<0;1,0>:f     -0.0:f               {I@1}
        goto (8|M0)                          L15696                  L18440                
L15696:
        join (8|M0)                          L15760                                
L15712:
(W)     mov (1|M0)               r6.3<1>:ud    0x1:ud                              {F@1}
(f1.1)  sel (8|M0)               r45.0<1>:f    r6.3<0;1,0>:f     0.0:f               {I@1}
        goto (8|M0)                          L15760                  L18440                
L15760:
        join (8|M0)                          L18192                                
L15776:
        cmp (8|M0)    (lt)f0.1   null<1>:ud    r106.0<1;1,0>:ud  0x18:uw             
        add3 (8|M0)              r46.0<1>:d    r36.0<1;0>:d      r106.0<1;0>:d     81:w              
(f0.1)  cmp (8|M0)    (eq)f0.1   null<1>:d     r37.0<1;1,0>:d    0:w              
(f0.1)  goto (8|M0)                          L17872                  L17872                
L15840:
        shl (8|M0)               r111.0<1>:d   r88.0<1;1,0>:d    1:w               {Compacted}
        shr (8|M0)               r110.0<1>:ud  r88.0<1;1,0>:ud   31:w              
        shl (8|M0)               r99.0<1>:d    r22.0<1;1,0>:d    1:w               {Compacted}
        cmp (8|M0)    (lt)f0.1   null<1>:ud    r111.0<1;1,0>:ud  0x4E:uw              {I@3}
        or (8|M0)                r99.0<1>:d    r99.0<1;1,0>:d    r110.0<1;1,0>:d  {Compacted,I@2}
(f0.1)  cmp (8|M0)    (eq)f0.1   null<1>:d     r99.0<1;1,0>:d    0:w               {I@1}
(~f0.1) cmp (8|M0)    (lt)f0.1   null<1>:d     r99.0<1;1,0>:d    0:w              
(f0.1)  goto (8|M0)                          L16072                  L16072                
L15944:
        cmp (8|M0)    (eq)f1.1   null<1>:d     r88.0<1;1,0>:d    39:w               {F@1}
(f1.1)  cmp (8|M0)    (eq)f1.1   null<1>:d     r22.0<1;1,0>:d    0:w              
(~f1.1) goto (8|M0)                          L16072                  L16136                
L15992:
        shr (8|M0)               r44.0<1>:ud   r38.0<1;1,0>:ud   1:w              
        mov (8|M0)               r22.0<1>:d    0:w                              
        mov (8|M0)               r39.0<1>:d    0:w                              
        mov (8|M0)               r116.0<1>:f   r44.0<1;1,0>:f                   {Compacted,I@3}
        mov (8|M0)               r44.0<1>:f    r38.0<1;1,0>:f                   {Compacted}
        goto (8|M0)                          L16072                  L17328                
L16072:
        join (8|M0)                          L16136                                
L16088:
        cmp (8|M0)    (eq)f1.0   null<1>:d     r88.0<1;1,0>:d    38:w              
(f1.0)  cmp (8|M0)    (eq)f1.0   null<1>:d     r22.0<1;1,0>:d    0:w               {I@5}
(f1.0)  goto (8|M0)                          L16136                  L17248                
L16136:
        join (8|M0)                          L17248                                
L16152:
        add (8|M0)               acc0.0<1>:d   -r88.0<1;1,0>:d   39:w               {Compacted}
        add (8|M0)               r47.0<1>:d    -r88.0<1;1,0>:d   40:w               {Compacted}
        and (8|M0)    (ne)f0.1   r93.0<1>:d    acc0.0<1;1,0>:d   63:w              
(f0.1)  goto (8|M0)                          L16232                  L16232                
L16200:
        mov (8|M0)               r37.0<1>:d    r38.0<1;1,0>:d                  
        goto (8|M0)                          L16232                  L16368                
L16232:
        join (8|M0)                          L16368                                
L16248:
        cmp (8|M0)    (lt)f1.1   null<1>:ud    r93.0<1;1,0>:ud   0x20:uw              {I@5}
(f1.1)  add (8|M0)               acc0.0<1>:d   -r93.0<1;1,0>:d   32:w              
(~f1.1) add (8|M0)               acc2.0<1>:d   r93.0<1;1,0>:d    -32:w              
(f1.1)  shr (8|M0)               r73.0<1>:ud   r38.0<1;1,0>:ud   r93.0<1;1,0>:d  
(f1.1)  shl (8|M0)               r61.0<1>:d    r43.0<1;1,0>:d    acc0.0<1;1,0>:d 
(~f1.1) shr (8|M0)               r44.0<1>:ud   r43.0<1;1,0>:ud   acc2.0<1;1,0>:d  {F@1}
(f1.1)  or (8|M0)                r44.0<1>:d    r73.0<1;1,0>:d    r61.0<1;1,0>:d   {I@2}
        mov (8|M0)               r37.0<1>:f    r44.0<1;1,0>:f                   {Compacted,I@1}
L16368:
        join (8|M0)                          L17248                                
L16384:
        add (8|M0)               r116.0<1>:d   -r88.0<1;1,0>:d   38:w               {Compacted}
        and (8|M0)    (ne)f1.0   r98.0<1>:d    r116.0<1;1,0>:d   63:w               {I@1}
(f1.0)  goto (8|M0)                          L16456                  L16456                
L16424:
        mov (8|M0)               r44.0<1>:d    r38.0<1;1,0>:d                   {F@1}
        goto (8|M0)                          L16456                  L16584                
L16456:
        join (8|M0)                          L16584                                
L16472:
        cmp (8|M0)    (lt)f0.1   null<1>:ud    r98.0<1;1,0>:ud   0x20:uw              {I@5}
(f0.1)  add (8|M0)               acc0.0<1>:d   -r98.0<1;1,0>:d   32:w              
(~f0.1) add (8|M0)               acc2.0<1>:d   r98.0<1;1,0>:d    -32:w              
(f0.1)  shr (8|M0)               r71.0<1>:ud   r38.0<1;1,0>:ud   r98.0<1;1,0>:d  
(f0.1)  shl (8|M0)               r74.0<1>:d    r43.0<1;1,0>:d    acc0.0<1;1,0>:d 
(~f0.1) shr (8|M0)               r44.0<1>:ud   r43.0<1;1,0>:ud   acc2.0<1;1,0>:d 
(f0.1)  or (8|M0)                r44.0<1>:d    r71.0<1;1,0>:d    r74.0<1;1,0>:d   {I@2}
L16584:
        join (8|M0)                          L17248                                
L16600:
        and (8|M0)    (ne)f1.1   r73.0<1>:d    r116.0<1;1,0>:d   63:w              
        and (8|M0)               r39.0<1>:d    r44.0<1;1,0>:d    1:w               {Compacted,I@3}
(f1.1)  goto (8|M0)                          L16688                  L16688                
L16640:
        mov (8|M0)               r85.0<1>:d    -1:w                              
        mov (8|M0)               r94.0<1>:d    -1:w                              
        goto (8|M0)                          L16688                  L16872                
L16688:
        join (8|M0)                          L16872                                
L16704:
        cmp (8|M0)    (lt)f1.0   null<1>:ud    r73.0<1;1,0>:ud   0x20:uw              {I@7}
(f1.0)  goto (8|M0)                          L16808                  L16808                
L16736:
        add (8|M0)               acc0.0<1>:d   r73.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r6.6<1>:hf    -qnan(0x1FF):hf                             
        mov (8|M0)               r85.0<1>:d    0:w                              
        shl (8|M0)               r94.0<1>:d    r6.6<0;1,0>:w     acc0.0<1;1,0>:d  {F@1}
        goto (8|M0)                          L16808                  L16872                
L16808:
        join (8|M0)                          L16872                                
L16824:
(W)     mov (1|M0)               r6.6<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (8|M0)               r94.0<1>:d    -1:w                              
        shl (8|M0)               r85.0<1>:d    r6.6<0;1,0>:w     r73.0<1;1,0>:d   {F@1}
L16872:
        join (8|M0)                          L17248                                
L16888:
        bfn.0x28 (8|M0)          r70.0<1>:ud   r38.0<1;0>:ud     r85.0<1;0>:ud     r5.7<0>:ud       {I@2} // s0&(s1^s2)
        bfn.0x28 (8|M0)          r69.0<1>:ud   r43.0<1;0>:ud     r94.0<1;0>:ud     r5.7<0>:ud       // s0&(s1^s2)
        cmp (8|M0)    (ne)f0.1   null<1>:d     r70.0<1;1,0>:d    0:w               {I@2}
(W)     mov (1|M0)               r6.6<1>:hf    -qnan(0x1FF):hf                             
(~f0.1) cmp (8|M0)    (ne)f0.1   null<1>:d     r69.0<1;1,0>:d    0:w               {I@2}
(f0.1)  sel (8|M0)               acc0.0<1>:d   r6.6<0;1,0>:w     0:w               {F@1}
        and (8|M0)    (ne)f0.1   r97.0<1>:d    r47.0<1;1,0>:d    63:w              
        mov (8|M0)               r22.0<1>:d    -acc0.0<1;1,0>:d                
(f0.1)  goto (8|M0)                          L17064                  L17064                
L17032:
        mov (8|M0)               r44.0<1>:d    r38.0<1;1,0>:d                  
        goto (8|M0)                          L17064                  L17192                
L17064:
        join (8|M0)                          L17192                                
L17080:
        cmp (8|M0)    (lt)f1.1   null<1>:ud    r97.0<1;1,0>:ud   0x20:uw              {I@6}
(f1.1)  add (8|M0)               acc0.0<1>:d   -r97.0<1;1,0>:d   32:w              
(~f1.1) add (8|M0)               acc2.0<1>:d   r97.0<1;1,0>:d    -32:w              
(f1.1)  shr (8|M0)               r66.0<1>:ud   r38.0<1;1,0>:ud   r97.0<1;1,0>:d  
(f1.1)  shl (8|M0)               r72.0<1>:d    r43.0<1;1,0>:d    acc0.0<1;1,0>:d 
(~f1.1) shr (8|M0)               r44.0<1>:ud   r43.0<1;1,0>:ud   acc2.0<1;1,0>:d 
(f1.1)  or (8|M0)                r44.0<1>:d    r66.0<1;1,0>:d    r72.0<1;1,0>:d   {I@2}
L17192:
        join (8|M0)                          L17248                                
L17208:
        mov (8|M0)               r116.0<1>:f   r44.0<1;1,0>:f                   {Compacted,I@2}
        mov (8|M0)               r44.0<1>:d    r37.0<1;1,0>:d                   {F@1}
        goto (8|M0)                          L17248                  L17328                
L17248:
        join (8|M0)                          L17328                                
L17264:
        shr (8|M0)               r44.0<1>:ud   r38.0<1;1,0>:ud   2:w              
        and (8|M0)               r39.0<1>:d    r38.0<1;1,0>:d    1:w               {Compacted}
        mov (8|M0)               r22.0<1>:d    0:w                              
        mov (8|M0)               r116.0<1>:f   r44.0<1;1,0>:f                   {Compacted,I@3}
        shr (8|M0)               r44.0<1>:ud   r38.0<1;1,0>:ud   1:w               {F@1}
L17328:
        join (8|M0)                          L17872                                
L17344:
        shl (8|M0)               r44.0<1>:d    r44.0<1;1,0>:d    2:w               {Compacted,I@2}
        shl (8|M0)               r65.0<1>:d    r39.0<1;1,0>:d    1:w               {Compacted}
        and (8|M0)               r44.0<1>:d    r44.0<1;1,0>:d    4:w               {Compacted,I@2}
        and (8|M0)               r123.0<1>:d   r116.0<1;1,0>:d   8388607:d              
        bfn.0xFE (8|M0)          r97.0<1>:ud   r44.0<1;0>:ud     r65.0<1;0>:ud     r22.0<1>:ud      {I@2} // s0|s1|s2
        cmp (8|M0)    (eq)f1.0   null<1>:d     r97.0<1;1,0>:d    0:w               {I@1}
(~f1.0) goto (8|M0)                          L17464                  L17464                
L17432:
        mov (8|M0)               r96.0<1>:d    0:w                              
        goto (8|M0)                          L17464                  L17624                
L17464:
        join (8|M0)                          L17624                                
L17480:
        cmp (8|M0)    (gt)f0.1   null<1>:ud    r97.0<1;1,0>:ud   0x4:uw             
(~f0.1) goto (8|M0)                          L17544                  L17544                
L17512:
        mov (8|M0)               r96.0<1>:d    1:w                              
        goto (8|M0)                          L17544                  L17624                
L17544:
        join (8|M0)                          L17624                                
L17560:
        and (8|M0)    (ne)f1.1   null<1>:d     r116.0<1;1,0>:d   1:w              
(W)     mov (1|M0)               r6.6<1>:hf    0x1:hf                             
(f1.1)  cmp (8|M0)    (eq)f1.1   null<1>:d     r97.0<1;1,0>:d    4:w              
(f1.1)  sel (8|M0)               r96.0<1>:d    r6.6<0;1,0>:w     0:w               {F@1}
L17624:
        join (8|M0)                          L17872                                
L17640:
        add (8|M0)               r69.0<1>:d    r123.0<1;1,0>:d   r96.0<1;1,0>:d   {Compacted,I@2}
        add3 (8|M0)              r67.0<1>:d    r36.0<1;0>:d      r106.0<1;0>:d     82:w              
        cmp (8|M0)    (gt)f0.1   null<1>:ud    r69.0<1;1,0>:ud   0x7FFFFF:ud              {I@2}
(f0.1)  sel (8|M0)               r56.0<1>:d    r67.0<1;1,0>:d    r46.0<1;1,0>:d   {I@2}
        cmp (8|M0)    (eq)f1.1   null<1>:d     r56.0<1;1,0>:d    255:w               {I@1}
(f1.1)  goto (8|M0)                          L17800                  L17800                
L17728:
(~f0.1) sel (8|M0)               r72.0<1>:d    r69.0<1;1,0>:d    0:w              
        and (8|M0)               r66.0<1>:d    r30.0<1;1,0>:d    -2147483648:d              
        shl (8|M0)               r64.0<1>:d    r56.0<1;1,0>:d    23:w               {Compacted}
        bfn.0xFE (8|M0)          r45.0<1>:ud   r66.0<1;0>:ud     r64.0<1;0>:ud     r72.0<1>:ud      {I@1} // s0|s1|s2
        goto (8|M0)                          L17800                  L18440                
L17800:
        join (8|M0)                          L17872                                
L17816:
        cmp (8|M0)    (gt)f0.1   null<1>:d     r30.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r6.3<1>:f     inf:f                               {Compacted}
(f0.1)  sel (8|M0)               r45.0<1>:f    r6.3<0;1,0>:f     -inf:f               {A@1}
        goto (8|M0)                          L17872                  L18440                
L17872:
        join (8|M0)                          L18192                                
L17888:
        and (8|M0)    (ne)f1.0   r65.0<1>:d    r106.0<1;1,0>:d   63:w              
(f1.0)  goto (8|M0)                          L17952                  L17952                
L17920:
        mov (8|M0)               r83.0<1>:d    -1:w                              
        goto (8|M0)                          L17952                  L18080                
L17952:
        join (8|M0)                          L18080                                
L17968:
        cmp (8|M0)    (lt)f0.1   null<1>:ud    r65.0<1;1,0>:ud   0x20:uw              {A@1}
(f0.1)  goto (8|M0)                          L18032                  L18032                
L18000:
        mov (8|M0)               r83.0<1>:d    0:w                              
        goto (8|M0)                          L18032                  L18080                
L18032:
        join (8|M0)                          L18080                                
L18048:
(W)     mov (1|M0)               r6.6<1>:hf    -qnan(0x1FF):hf                             
        shl (8|M0)               r83.0<1>:d    r6.6<0;1,0>:w     r65.0<1;1,0>:d   {F@1}
L18080:
        join (8|M0)                          L18192                                
L18096:
        bfn.0x28 (8|M0)          r95.0<1>:ud   r38.0<1;0>:ud     r83.0<1;0>:ud     r5.7<0>:ud       {I@2} // s0&(s1^s2)
        add (8|M0)               acc0.0<1>:d   -r106.0<1;1,0>:d  23:w               {Compacted}
        and (8|M0)               r65.0<1>:d    r30.0<1;1,0>:d    -2147483648:d              
        shl (8|M0)               r62.0<1>:d    r46.0<1;1,0>:d    23:w               {Compacted}
        shl (8|M0)               r95.0<1>:d    r95.0<1;1,0>:d    acc0.0<1;1,0>:d  {I@4}
        bfn.0xFE (8|M0)          r45.0<1>:ud   r65.0<1;0>:ud     r62.0<1;0>:ud     r95.0<1>:ud      {I@1} // s0|s1|s2
        goto (8|M0)                          L18192                  L18440                
L18192:
        join (8|M0)                          L18264                                
L18208:
        cmp (8|M0)    (gt)f1.1   null<1>:d     r30.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r6.3<1>:f     inf:f                               {Compacted}
(f1.1)  sel (8|M0)               r45.0<1>:f    r6.3<0;1,0>:f     -inf:f               {A@1}
        goto (8|M0)                          L18264                  L18440                
L18264:
        join (8|M0)                          L18336                                
L18280:
        cmp (8|M0)    (lt)f1.0   null<1>:d     r30.0<1;1,0>:d    0:w              
(W)     mov (1|M0)               r6.3<1>:f     -0.0:f                               {Compacted}
(f1.0)  sel (8|M0)               r45.0<1>:f    r6.3<0;1,0>:f     0.0:f               {F@1}
        goto (8|M0)                          L18336                  L18440                
L18336:
        join (8|M0)                          L18408                                
L18352:
        cmp (8|M0)    (gt)f0.1   null<1>:d     r30.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r6.3<1>:f     inf:f                               {Compacted}
(f0.1)  sel (8|M0)               r45.0<1>:f    r6.3<0;1,0>:f     -inf:f               {F@1}
        goto (8|M0)                          L18408                  L18440                
L18408:
        join (8|M0)                          L18440                                
L18424:
        bfn.0xF8 (8|M0)          r45.0<1>:ud   r30.0<1;0>:ud     r5.6<0;0>:ud      r5.3<0>:ud       {F@1} // s0&s1|s2
L18440:
        join (8|M0)                          L29536                                
L18456:
        shr (8|M0)               r30.0<1>:ud   r45.0<1;1,0>:ud   23:w               {I@2}
        and (8|M0)    (ne)f1.0   r66.0<1>:d    r45.0<1;1,0>:d    8388607:d              
        and (8|M0)               r61.0<1>:d    r30.0<1;1,0>:d    255:w               {Compacted,I@2}
(f1.0)  cmp (8|M0)    (eq)f1.0   null<1>:d     r61.0<1;1,0>:d    255:w               {I@1}
(~f1.0) goto (8|M0)                          L18552                  L18552                
L18528:
        mov (8|M0)               r45.0<1>:f    qnan(0x0):f                               {Compacted}
        goto (8|M0)                          L18552                  L22888                
L18552:
        join (8|M0)                          L22888                                
L18568:
        cmp (8|M0)    (eq)f0.1   null<1>:d     r66.0<1;1,0>:d    0:w              
(f0.1)  cmp (8|M0)    (eq)f0.1   null<1>:d     r61.0<1;1,0>:d    255:w              
(f0.1)  goto (8|M0)                          L22888                  L22888                
L18616:
        or (8|M0)     (eq)f1.1   null<1>:d     r61.0<1;1,0>:d    r66.0<1;1,0>:d  
(~f1.1) goto (8|M0)                          L18680                  L18680                
L18648:
        mov (8|M0)               r45.0<1>:f    0x3F650000:f                              
        goto (8|M0)                          L18680                  L22888                
L18680:
        join (8|M0)                          L22888                                
L18696:
        cmp (8|M0)    (gt)f1.0   null<1>:d     r45.0<1;1,0>:d    -1:w               {F@1}
        cmp (8|M0)    (gt)f1.1   null<1>:ud    r61.0<1;1,0>:ud   0x7E:uw             
(f1.0)  goto (8|M0)                          L18968                  L18968                
L18744:
(f1.1)  goto (8|M0)                          L18856                  L18856                
L18760:
        mov (8|M0)               r83.0<1>:f    0x3F650000:f                              
        mov (8|M0)               r75.0<1>:f    r45.0<1;1,0>:f                   {Compacted}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        call (8|M0)              r6.4          L42456                                 {A@1}
L18832:
        mov (8|M0)               r45.0<1>:f    r120.0<1;1,0>:f                  {Compacted,I@5}
        goto (8|M0)                          L18856                  L22888                
L18856:
        join (8|M0)                          L18968                                
L18872:
        mov (8|M0)               r83.0<1>:f    r45.0<1;1,0>:f                   {Compacted,F@1}
        mov (8|M0)               r75.0<1>:f    0x3F650000:f                              
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        call (8|M0)              r6.4          L42456                                 {A@1}
L18944:
        mov (8|M0)               r45.0<1>:f    r120.0<1;1,0>:f                  {Compacted}
        goto (8|M0)                          L18968                  L22888                
L18968:
        join (8|M0)                          L22888                                
L18984:
(f1.1)  goto (8|M0)                          L21088                  L21088                
L19000:
        cmp (8|M0)    (ne)f1.0   null<1>:d     r61.0<1;1,0>:d    0:w              
        add (8|M0)               r64.0<1>:d    -r61.0<1;1,0>:d   126:w               {Compacted}
(f1.0)  sel (8|M0)               r80.0<1>:d    r64.0<1;1,0>:d    125:w               {I@1}
        cmp (8|M0)    (lt)f0.1   null<1>:d     r80.0<1;1,0>:d    1:w               {I@1}
(f0.1)  goto (8|M0)                          L20176                  L20176                
L19072:
        cmp (8|M0)    (eq)f0.0   null<1>:d     r80.0<1;1,0>:d    1:w               {Compacted}
(f0.0)  goto (8|M0)                          L19768                  L19768                
L19096:
        cmp (8|M0)    (lt)f1.1   null<1>:ud    r80.0<1;1,0>:ud   0x18:uw             
(f1.1)  goto (8|M0)                          L19528                  L19528                
L19128:
        cmp (8|M0)    (ne)f1.0   r55.0<1>:d    r61.0<1;1,0>:d    0:w              
        cmp (8|M0)    (lt)f1.0   null<1>:d     r80.0<1;1,0>:d    25:w              
        mov (8|M0)               r72.0<1>:d    -r55.0<1;1,0>:d                  {I@2}
(f1.0)  goto (8|M0)                          L19336                  L19336                
L19192:
        cmp (8|M0)    (eq)f0.1   null<1>:d     r80.0<1;1,0>:d    25:w              
        cmp (8|M0)    (ne)f1.1   r63.0<1>:d    r66.0<1;1,0>:d    0:w              
        cmp (8|M0)    (ne)f1.0   r61.0<1>:d    r45.0<1;1,0>:d    0:w               {F@1}
(f0.1)  sel (8|M0)               r72.0<1>:d    -r55.0<1;1,0>:d   0:w              
(f0.1)  sel (8|M0)               acc0.0<1>:d   -r63.0<1;1,0>:d   -r61.0<1;1,0>:d  {I@2}
        mov (8|M0)               r79.0<1>:f    r72.0<1;1,0>:f                   {Compacted,I@2}
        shl (8|M0)               r53.0<1>:d    acc0.0<1;1,0>:d   31:w              
        mov (8|M0)               r72.0<1>:d    0:w                               {F@1}
        asr (8|M0)               r47.0<1>:d    r53.0<1;1,0>:d    31:w               {Compacted,I@2}
        goto (8|M0)                          L19336                  L19408                
L19336:
        join (8|M0)                          L19408                                
L19352:
        shr (8|M0)               r60.0<1>:ud   r45.0<1;1,0>:ud   22:w              
        and (8|M0)               r59.0<1>:d    r45.0<1;1,0>:d    4194303:d              
        and (8|M0)               r79.0<1>:d    r60.0<1;1,0>:d    1:w               {Compacted,I@2}
        cmp (8|M0)    (ne)f0.1   r47.0<1>:d    r59.0<1;1,0>:d    0:w               {I@2}
L19408:
        join (8|M0)                          L19528                                
L19424:
        cmp (8|M0)    (ne)f0.0   r58.0<1>:d    r47.0<1;1,0>:d    0:w               {I@2}
(W)     mov (1|M0)               r6.12<2>:b    126:w                              
        mov (8|M0)               r70.0<1>:f    9.275385e-39:f                              
        mov (8|M0)               r28.0<1>:f    r79.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r7.0<1>:b     r6.12<0;1,0>:b                   {I@1}
        mov (8|M0)               r109.0<1>:d   -r58.0<1;1,0>:d                 
        goto (8|M0)                          L19528                  L20672                
L19528:
        join (8|M0)                          L19768                                
L19544:
        add (8|M0)               acc0.0<1>:d   r80.0<1;1,0>:d    -2:w               {Compacted}
(W)     mov (1|M0)               r6.6<1>:hf    -qnan(0x1FF):hf                              {I@5}
        add (8|M0)               acc2.0<1>:d   r80.0<1;1,0>:d    -1:w               {Compacted}
        add (8|M0)               r121.0<1>:d   -r80.0<1;1,0>:d   23:w               {Compacted}
        shr (8|M0)               r57.0<1>:ud   r66.0<1;1,0>:ud   acc0.0<1;1,0>:d 
        shl (8|M0)               r75.0<1>:d    r6.6<0;1,0>:w     acc0.0<1;1,0>:d  {F@1}
(W)     mov (1|M0)               r6.6<1>:hf    0x1:hf                              {I@1}
        shr (8|M0)               r87.0<1>:ud   r66.0<1;1,0>:ud   r80.0<1;1,0>:d  
        shr (8|M0)               r64.0<1>:ud   r66.0<1;1,0>:ud   acc2.0<1;1,0>:d 
        bfn.0x60 (8|M0)          r103.0<1>:ud  r75.0<1;0>:ud     r5.7<0;0>:ud      r66.0<1>:ud      // (s0^s1)&s2
        shl (8|M0)               r121.0<1>:d   r6.6<0;1,0>:w     r121.0<1;1,0>:d  {F@1}
(~f1.0) mov (8|M0)               r121.0<1>:d   0:w                              
        and (8|M0)               r112.0<1>:d   r57.0<1;1,0>:d    1:w               {Compacted}
        and (8|M0)               r72.0<1>:d    r64.0<1;1,0>:d    1:w               {Compacted,I@5}
        cmp (8|M0)    (ne)f1.1   r54.0<1>:d    r103.0<1;1,0>:d   0:w               {I@5}
        or (8|M0)                r92.0<1>:d    r87.0<1;1,0>:d    r121.0<1;1,0>:d  {Compacted,I@4}
        goto (8|M0)                          L19768                  L19856                
L19768:
        join (8|M0)                          L19856                                
L19784:
        and (8|M0)               r72.0<1>:d    r45.0<1;1,0>:d    1:w               {Compacted}
        shr (8|M0)               r92.0<1>:ud   r66.0<1;1,0>:ud   1:w              
(f1.0)  goto (8|M0)                          L19856                  L20064                
L19824:
        mov (8|M0)               r112.0<1>:d   0:w                              
        mov (8|M0)               r54.0<1>:d    0:w                              
L19856:
        join (8|M0)                          L20064                                
L19872:
        cmp (8|M0)    (ne)f1.0   r78.0<1>:d    r54.0<1;1,0>:d    0:w               {I@2}
        cmp (8|M0)    (gt)f0.1   null<1>:ud    r92.0<1;1,0>:ud   0x1AFFFF:ud             
        add (8|M0)               r70.0<1>:d    r92.0<1;1,0>:d    6619136:d              
        mov (8|M0)               r109.0<1>:d   -r78.0<1;1,0>:d                  {I@3}
(f0.1)  goto (8|M0)                          L20008                  L20008                
L19952:
(W)     mov (1|M0)               r6.12<2>:b    126:w                              
        mov (8|M0)               r28.0<1>:f    r112.0<1;1,0>:f                  {Compacted}
        mov (8|M0)               r7.0<1>:b     r6.12<0;1,0>:b                   {I@1}
        goto (8|M0)                          L20008                  L20672                
L20008:
        join (8|M0)                          L20064                                
L20024:
        cmp (8|M0)    (eq)f0.0   null<1>:d     r112.0<1;1,0>:d   1:w               {Compacted}
(~f0.0) sel (8|M0)               r109.0<1>:d   -r78.0<1;1,0>:d   1:w              
        goto (8|M0)                          L20064                  L20112                
L20064:
        join (8|M0)                          L20112                                
L20080:
        add (8|M0)               r70.0<1>:d    r92.0<1;1,0>:d    10813440:d              
        mov (8|M0)               r109.0<1>:d   0:w                              
L20112:
        join (8|M0)                          L20176                                
L20128:
        shr (8|M0)               r56.0<1>:ud   r70.0<1;1,0>:ud   1:w               {I@3}
        and (8|M0)               r77.0<1>:d    r56.0<1;1,0>:d    4194303:d               {I@1}
        goto (8|M0)                          L20176                  L20584                
L20176:
        join (8|M0)                          L20584                                
L20192:
        cmp (8|M0)    (gt)f1.1   null<1>:ud    r66.0<1;1,0>:ud   0x1AFFFF:ud             
        add (8|M0)               r70.0<1>:d    r66.0<1;1,0>:d    6619136:d              
(f1.1)  goto (8|M0)                          L20472                  L20472                
L20240:
(f1.0)  goto (8|M0)                          L20352                  L20352                
L20256:
(W)     mov (1|M0)               r6.12<2>:b    126:w                              
        mov (8|M0)               r72.0<1>:d    0:w                              
        mov (8|M0)               r28.0<1>:d    0:w                               {F@1}
        mov (8|M0)               r109.0<1>:d   0:w                              
        mov (8|M0)               r7.0<1>:b     r6.12<0;1,0>:b                   {I@4}
        goto (8|M0)                          L20352                  L20672                
L20352:
        join (8|M0)                          L20472                                
L20368:
(W)     mov (1|M0)               r6.12<2>:b    127:w                              
        and (8|M0)               r72.0<1>:d    r45.0<1;1,0>:d    1:w               {Compacted}
        shr (8|M0)               r70.0<1>:ud   r70.0<1;1,0>:ud   1:w              
        mov (8|M0)               r28.0<1>:d    0:w                              
        mov (8|M0)               r109.0<1>:d   0:w                              
        mov (8|M0)               r7.0<1>:b     r6.12<0;1,0>:b                   {I@5}
        goto (8|M0)                          L20472                  L20672                
L20472:
        join (8|M0)                          L20584                                
L20488:
        shr (8|M0)               r60.0<1>:ud   r70.0<1;1,0>:ud   1:w               {I@6}
        mov (8|M0)               r109.0<1>:d   0:w                              
        and (8|M0)               r62.0<1>:d    r60.0<1;1,0>:d    4194303:d               {I@2}
        or (8|M0)                r60.0<1>:d    r60.0<1;1,0>:d    4194304:d              
        mov (8|M0)               r72.0<1>:d    0:w                              
(f1.0)  sel (8|M0)               r77.0<1>:d    r60.0<1;1,0>:d    r62.0<1;1,0>:d   {I@2}
L20584:
        join (8|M0)                          L20672                                
L20600:
        and (8|M0)               acc0.0<1>:d   r70.0<1;1,0>:d    1:w               {Compacted}
(W)     mov (1|M0)               r6.12<2>:b    127:w                              
        mov (8|M0)               r28.0<1>:f    r72.0<1;1,0>:f                   {Compacted,I@5}
        mov (8|M0)               r70.0<1>:f    r77.0<1;1,0>:f                   {Compacted,A@2}
        mov (8|M0)               r72.0<1>:d    acc0.0<1;1,0>:d                  {F@2}
        mov (8|M0)               r7.0<1>:b     r6.12<0;1,0>:b                   {I@2}
L20672:
        join (8|M0)                          L21088                                
L20688:
        shl (8|M0)               r74.0<1>:d    r72.0<1;1,0>:d    2:w               {Compacted,I@3}
        shl (8|M0)               r55.0<1>:d    r28.0<1;1,0>:d    1:w               {Compacted}
        bfn.0xFE (8|M0)          r57.0<1>:ud   r74.0<1;0>:ud     r55.0<1;0>:ud     r109.0<1>:ud     {I@1} // s0|s1|s2
        cmp (8|M0)    (eq)f1.0   null<1>:d     r57.0<1;1,0>:d    0:w               {I@1}
(~f1.0) goto (8|M0)                          L20784                  L20784                
L20752:
        mov (8|M0)               r63.0<1>:d    0:w                              
        goto (8|M0)                          L20784                  L20944                
L20784:
        join (8|M0)                          L20944                                
L20800:
        cmp (8|M0)    (gt)f0.1   null<1>:ud    r57.0<1;1,0>:ud   0x4:uw             
(~f0.1) goto (8|M0)                          L20864                  L20864                
L20832:
        mov (8|M0)               r63.0<1>:d    1:w                              
        goto (8|M0)                          L20864                  L20944                
L20864:
        join (8|M0)                          L20944                                
L20880:
        and (8|M0)    (ne)f0.0   null<1>:d     r70.0<1;1,0>:d    1:w               {F@1}
(W)     mov (1|M0)               r6.6<1>:hf    0x1:hf                             
(f0.0)  cmp (8|M0)    (eq)f0.0   null<1>:d     r57.0<1;1,0>:d    4:w              
(f0.0)  sel (8|M0)               r63.0<1>:d    r6.6<0;1,0>:w     0:w               {F@1}
L20944:
        join (8|M0)                          L21088                                
L20960:
        add (8|M0)               r120.0<1>:d   r70.0<1;1,0>:d    r63.0<1;1,0>:d   {Compacted,I@2}
        mov (8|M0)               r119.0<1>:d   r7.0<1;1,0>:ub                  
        cmp (8|M0)    (eq)f0.1   r61.0<1>:d    r120.0<1;1,0>:d   8388608:d               {I@2}
        cmp (8|M0)    (eq)f1.1   null<1>:d     r120.0<1;1,0>:d   8388608:d              
        add3 (8|M0)              acc0.0<1>:d   r119.0<1;0>:d     -r61.0<1;0>:d     0:w               {I@2}
(f1.1)  mov (8|M0)               r120.0<1>:d   0:w                              
        shl (8|M0)               r119.0<1>:d   acc0.0<1;1,0>:d   23:w              
        or (8|M0)                r45.0<1>:d    r119.0<1;1,0>:d   r120.0<1;1,0>:d  {Compacted,I@1}
        goto (8|M0)                          L21088                  L22888                
L21088:
        join (8|M0)                          L22888                                
L21104:
        mov (8|M0)               r7.0<1>:b     r30.0<4;1,0>:b                  
        cmp (8|M0)    (eq)f0.0   null<1>:w     r7.0<1;1,0>:b     127:w               {I@1}
(~f0.0) goto (8|M0)                          L21232                  L21232                
L21152:
        mov (8|M0)               r84.0<1>:d    0:w                              
        mov (8|M0)               r116.0<1>:d   0:w                              
        mov (8|M0)               r127.0<1>:d   0:w                              
        mov (8|M0)               r27.0<1>:f    0x728000:f                              
        goto (8|M0)                          L21232                  L21912                
L21232:
        join (8|M0)                          L21912                                
L21248:
        cmp (8|M0)    (eq)f1.1   null<1>:w     r7.0<1;1,0>:b     126:w              
(f1.1)  goto (8|M0)                          L21912                  L22128                
L21280:
        add (8|M0)               r103.0<1>:d   r61.0<1;1,0>:d    -126:w               {Compacted}
        cmp (8|M0)    (lt)f1.0   null<1>:ud    r103.0<1;1,0>:ud  0x18:uw              {I@1}
(f1.0)  goto (8|M0)                          L21688                  L21688                
L21320:
        cmp (8|M0)    (lt)f0.1   null<1>:w     r7.0<1;1,0>:b     -105:w              
(f0.1)  goto (8|M0)                          L21464                  L21464                
L21352:
        cmp (8|M0)    (eq)f0.0   null<1>:w     r7.0<1;1,0>:b     -105:w              
(~f0.0) goto (8|M0)                          L21464                  L21592                
L21384:
        mov (8|M0)               r84.0<1>:d    0:w                              
        mov (8|M0)               r116.0<1>:d   1:w                              
        mov (8|M0)               r127.0<1>:d   -1:w                              
        mov (8|M0)               r27.0<1>:d    0:w                               {F@1}
        goto (8|M0)                          L21464                  L21912                
L21464:
        join (8|M0)                          L21592                                
L21480:
        cmp (8|M0)    (eq)f1.1   null<1>:w     r7.0<1;1,0>:b     -106:w              
(~f1.1) goto (8|M0)                          L21592                  L21592                
L21512:
        mov (8|M0)               r84.0<1>:d    1:w                              
        mov (8|M0)               r116.0<1>:d   1:w                              
        mov (8|M0)               r127.0<1>:d   -1:w                              
        mov (8|M0)               r27.0<1>:d    0:w                              
        goto (8|M0)                          L21592                  L21912                
L21592:
        join (8|M0)                          L21688                                
L21608:
        mov (8|M0)               r84.0<1>:d    0:w                              
        mov (8|M0)               r116.0<1>:d   0:w                              
        mov (8|M0)               r127.0<1>:d   -1:w                              
        mov (8|M0)               r27.0<1>:d    0:w                              
        goto (8|M0)                          L21688                  L21912                
L21688:
        join (8|M0)                          L21912                                
L21704:
(W)     mov (1|M0)               r6.4<1>:f     9.275385e-39:f                              
        add (8|M0)               acc0.0<1>:d   r61.0<1;1,0>:d    -128:w               {Compacted}
(W)     mov (1|M0)               r6.6<1>:hf    -qnan(0x1FF):hf                             
        add (8|M0)               acc2.0<1>:d   r61.0<1;1,0>:d    -127:w               {Compacted}
        add (8|M0)               r22.0<1>:d    -r61.0<1;1,0>:d   149:w               {Compacted}
        shr (8|M0)               r54.0<1>:ud   r6.4<0;1,0>:ud    acc0.0<1;1,0>:d  {F@2}
        shl (8|M0)               r113.0<1>:d   r6.6<0;1,0>:w     acc0.0<1;1,0>:d  {F@1}
(W)     mov (1|M0)               r6.6<1>:hf    0x1:hf                              {I@1}
        shr (8|M0)               r94.0<1>:ud   r6.4<0;1,0>:ud    r103.0<1;1,0>:d 
        shr (8|M0)               r82.0<1>:ud   r6.4<0;1,0>:ud    acc2.0<1;1,0>:d 
        and (8|M0)               r113.0<1>:d   r113.0<1;1,0>:d   6619136:d              
        shl (8|M0)               r22.0<1>:d    r6.6<0;1,0>:w     r22.0<1;1,0>:d   {F@1}
        and (8|M0)               r116.0<1>:d   r54.0<1;1,0>:d    1:w               {Compacted}
        and (8|M0)               r84.0<1>:d    r82.0<1;1,0>:d    1:w               {Compacted,I@4}
        cmp (8|M0)    (ne)f0.1   r127.0<1>:d   r113.0<1;1,0>:d   6619136:d               {I@4}
        or (8|M0)                r27.0<1>:d    r94.0<1;1,0>:d    r22.0<1;1,0>:d   {Compacted,I@4}
L21912:
        join (8|M0)                          L22128                                
L21928:
        add (8|M0)               r73.0<1>:d    r66.0<1;1,0>:d    r27.0<1;1,0>:d   {Compacted,I@2}
        cmp (8|M0)    (ne)f0.0   r83.0<1>:d    r127.0<1;1,0>:d   0:w              
        cmp (8|M0)    (gt)f1.0   null<1>:ud    r73.0<1;1,0>:ud   0x7FFFFF:ud              {I@2}
        mov (8|M0)               r111.0<1>:d   -r83.0<1;1,0>:d                  {I@2}
(f1.0)  goto (8|M0)                          L22032                  L22032                
L22000:
        mov (8|M0)               r114.0<1>:d   r116.0<1;1,0>:d                 
        goto (8|M0)                          L22032                  L22416                
L22032:
        join (8|M0)                          L22128                                
L22048:
        cmp (8|M0)    (eq)f0.1   null<1>:d     r116.0<1;1,0>:d   1:w              
        shr (8|M0)               r53.0<1>:ud   r73.0<1;1,0>:ud   1:w              
        and (8|M0)               r68.0<1>:d    r53.0<1;1,0>:d    4194303:d               {I@1}
(~f0.1) sel (8|M0)               r111.0<1>:d   -r83.0<1;1,0>:d   1:w              
        goto (8|M0)                          L22128                  L22352                
L22128:
        join (8|M0)                          L22352                                
L22144:
        cmp (8|M0)    (gt)f0.0   null<1>:ud    r66.0<1;1,0>:ud   0x1AFFFF:ud             
        add (8|M0)               r73.0<1>:d    r66.0<1;1,0>:d    6619136:d              
(f0.0)  goto (8|M0)                          L22272                  L22272                
L22192:
        and (8|M0)               r84.0<1>:d    r45.0<1;1,0>:d    1:w               {Compacted}
        shr (8|M0)               r73.0<1>:ud   r73.0<1;1,0>:ud   1:w               {I@3}
        add (8|M0)               r61.0<1>:d    r61.0<1;1,0>:d    1:w               {Compacted}
        mov (8|M0)               r114.0<1>:d   0:w                              
        mov (8|M0)               r111.0<1>:d   0:w                              
        goto (8|M0)                          L22272                  L22416                
L22272:
        join (8|M0)                          L22352                                
L22288:
        shr (8|M0)               r52.0<1>:ud   r73.0<1;1,0>:ud   1:w               {I@6}
        mov (8|M0)               r111.0<1>:d   0:w                              
        mov (8|M0)               r84.0<1>:d    0:w                              
        or (8|M0)                r68.0<1>:d    r52.0<1;1,0>:d    4194304:d               {I@3}
L22352:
        join (8|M0)                          L22416                                
L22368:
        and (8|M0)               acc0.0<1>:d   r73.0<1;1,0>:d    1:w               {Compacted}
        add (8|M0)               r61.0<1>:d    r61.0<1;1,0>:d    1:w               {Compacted}
        mov (8|M0)               r114.0<1>:f   r84.0<1;1,0>:f                   {Compacted,I@5}
        mov (8|M0)               r73.0<1>:f    r68.0<1;1,0>:f                   {Compacted,A@2}
        mov (8|M0)               r84.0<1>:d    acc0.0<1;1,0>:d                  {F@2}
L22416:
        join (8|M0)                          L22888                                
L22432:
        shl (8|M0)               r79.0<1>:d    r84.0<1;1,0>:d    2:w               {Compacted,I@2}
        shl (8|M0)               r51.0<1>:d    r114.0<1;1,0>:d   1:w               {Compacted}
        bfn.0xFE (8|M0)          r62.0<1>:ud   r79.0<1;0>:ud     r51.0<1;0>:ud     r111.0<1>:ud     {I@1} // s0|s1|s2
        cmp (8|M0)    (eq)f1.1   null<1>:d     r62.0<1;1,0>:d    0:w               {I@1}
(~f1.1) goto (8|M0)                          L22528                  L22528                
L22496:
        mov (8|M0)               r71.0<1>:d    0:w                              
        goto (8|M0)                          L22528                  L22688                
L22528:
        join (8|M0)                          L22688                                
L22544:
        cmp (8|M0)    (gt)f1.0   null<1>:ud    r62.0<1;1,0>:ud   0x4:uw             
(~f1.0) goto (8|M0)                          L22608                  L22608                
L22576:
        mov (8|M0)               r71.0<1>:d    1:w                              
        goto (8|M0)                          L22608                  L22688                
L22608:
        join (8|M0)                          L22688                                
L22624:
        and (8|M0)    (ne)f1.1   null<1>:d     r73.0<1;1,0>:d    1:w               {F@1}
(W)     mov (1|M0)               r6.6<1>:hf    0x1:hf                             
(f1.1)  cmp (8|M0)    (eq)f1.1   null<1>:d     r62.0<1;1,0>:d    4:w              
(f1.1)  sel (8|M0)               r71.0<1>:d    r6.6<0;1,0>:w     0:w               {F@1}
L22688:
        join (8|M0)                          L22888                                
L22704:
        add (8|M0)               r70.0<1>:d    r73.0<1;1,0>:d    r71.0<1;1,0>:d   {Compacted,I@2}
        cmp (8|M0)    (eq)f0.0   r50.0<1>:d    r70.0<1;1,0>:d    8388608:d               {I@1}
        cmp (8|M0)    (eq)f1.1   null<1>:d     r70.0<1;1,0>:d    8388608:d              
        add3 (8|M0)              r53.0<1>:d    r61.0<1;0>:d      -r50.0<1;0>:d     0:w               {I@2}
        cmp (8|M0)    (eq)f0.1   null<1>:d     r53.0<1;1,0>:d    255:w               {I@1}
(~f0.1) goto (8|M0)                          L22816                  L22816                
L22792:
        mov (8|M0)               r45.0<1>:f    inf:f                               {Compacted}
        goto (8|M0)                          L22816                  L22888                
L22816:
        join (8|M0)                          L22888                                
L22832:
(~f1.1) sel (8|M0)               r71.0<1>:d    r70.0<1;1,0>:d    0:w              
        and (8|M0)               r60.0<1>:d    r45.0<1;1,0>:d    -2147483648:d               {F@1}
        shl (8|M0)               r49.0<1>:d    r53.0<1;1,0>:d    23:w               {Compacted}
        bfn.0xFE (8|M0)          r45.0<1>:ud   r60.0<1;0>:ud     r49.0<1;0>:ud     r71.0<1>:ud      {I@1} // s0|s1|s2
L22888:
        join (8|M0)                          L29536                                
L22904:
        shr (8|M0)               r124.0<1>:ud  r25.0<1;1,0>:ud   23:w              
        and (8|M0)    (ne)f1.0   r123.0<1>:d   r25.0<1;1,0>:d    8388607:d              
        and (8|M0)               r29.0<1>:d    r124.0<1;1,0>:d   255:w               {Compacted,I@2}
(f1.0)  cmp (8|M0)    (eq)f1.0   null<1>:d     r29.0<1;1,0>:d    255:w               {I@1}
(~f1.0) goto (8|M0)                          L23000                  L23000                
L22976:
        mov (8|M0)               r65.0<1>:f    qnan(0x0):f                               {Compacted}
        goto (8|M0)                          L23000                  L29488                
L23000:
        join (8|M0)                          L29488                                
L23016:
        mov (8|M0)               r2.0<1>:hf    r45.0<1;1,0>:f                  
        mov (8|M0)               r94.0<1>:f    r2.0<1;1,0>:hf                   {F@1}
        shr (8|M0)               r115.0<1>:ud  r94.0<1;1,0>:ud   23:w               {F@1}
        and (8|M0)    (ne)f0.1   r118.0<1>:d   r94.0<1;1,0>:d    8388607:d              
        and (8|M0)               r26.0<1>:d    r115.0<1;1,0>:d   255:w               {Compacted,I@2}
(f0.1)  cmp (8|M0)    (eq)f0.1   null<1>:d     r26.0<1;1,0>:d    255:w               {I@1}
(~f0.1) goto (8|M0)                          L23144                  L23144                
L23120:
        mov (8|M0)               r65.0<1>:f    qnan(0x0):f                               {Compacted}
        goto (8|M0)                          L23144                  L29488                
L23144:
        join (8|M0)                          L29488                                
L23160:
        cmp (8|M0)    (eq)f1.1   null<1>:d     r123.0<1;1,0>:d   0:w              
        cmp (8|M0)    (eq)f1.0   null<1>:d     r118.0<1;1,0>:d   0:w              
(W)     mov (1|M0)               r3.8<1>:hf    0x1:hf                             
        xor (8|M0)               r32.0<1>:d    r25.0<1;1,0>:d    r94.0<1;1,0>:d   {Compacted}
(f1.1)  cmp (8|M0)    (eq)f1.1   null<1>:d     r29.0<1;1,0>:d    255:w              
(f1.0)  cmp (8|M0)    (eq)f1.0   null<1>:d     r26.0<1;1,0>:d    255:w              
(f1.1)  sel (8|M0)               r3.0<1>:uw    r3.8<0;1,0>:uw    0x0:uw              {F@1}
(f1.0)  sel (8|M0)               r2.0<1>:uw    r3.8<0;1,0>:uw    0x0:uw             
        or (8|M0)     (ne)f0.0   null<1>:uw    r3.0<1;1,0>:uw    r2.0<1;1,0>:uw   {I@1}
(f0.0)  goto (8|M0)                          L29456                  L29456                
L23312:
        or (8|M0)     (eq)f0.0   null<1>:d     r26.0<1;1,0>:d    r118.0<1;1,0>:d 
        or (8|M0)                r48.0<1>:d    r29.0<1;1,0>:d    r123.0<1;1,0>:d  {Compacted}
(~f0.0) cmp (8|M0)    (eq)f0.0   null<1>:d     r48.0<1;1,0>:d    0:w               {I@1}
(~f0.0) goto (8|M0)                          L23392                  L23392                
L23368:
        mov (8|M0)               r65.0<1>:f    0.0:f                               {Compacted}
        goto (8|M0)                          L23392                  L29488                
L23392:
        join (8|M0)                          L29456                                
L23408:
        cmp (8|M0)    (eq)f0.1   null<1>:d     r29.0<1;1,0>:d    0:w              
        cmp (8|M0)    (eq)f0.0   null<1>:d     r26.0<1;1,0>:d    0:w               {Compacted}
        add (8|M0)               r48.0<1>:d    r29.0<1;1,0>:d    -127:w               {Compacted}
        add (8|M0)               r47.0<1>:d    r26.0<1;1,0>:d    -127:w               {Compacted}
(f0.1)  mov (8|M0)               r48.0<1>:d    -126:w                              
(f0.0)  mov (8|M0)               r47.0<1>:d    -126:w                              
        add (8|M0)               r31.0<1>:d    r48.0<1;1,0>:d    r47.0<1;1,0>:d   {Compacted,I@1}
        cmp (8|M0)    (gt)f1.1   null<1>:d     r31.0<1;1,0>:d    127:w               {I@1}
(f1.1)  goto (8|M0)                          L29384                  L29384                
L23520:
        or (8|M0)     (eq)f1.0   null<4>:b     r124.0<1;1,0>:d   r115.0<1;1,0>:d 
(f1.0)  goto (8|M0)                          L29312                  L29312                
L23552:
(W)     mov (1|M0)               r6.6<1>:hf    0.0:hf                             
(W)     mov (1|M0)               r3.4<1>:d     0:w                              
(f0.1)  sel (8|M0)               acc0.0<1>:d   r6.6<0;1,0>:w     8388608:d               {F@1}
(f0.0)  sel (8|M0)               acc2.0<1>:d   r6.6<0;1,0>:w     8388608:d              
        or (8|M0)                r74.0<1>:d    acc0.0<1;1,0>:d   r123.0<1;1,0>:d 
        or (8|M0)                r70.0<1>:d    acc2.0<1;1,0>:d   r118.0<1;1,0>:d 
(W)     mov (1|M0)               r2.7<1>:f     -0.0:f                               {Compacted}
        mul (8|M0)               acc0.0<1>:ud  r74.0<1;1,0>:ud   r70.0<2;1,0>:uw  {I@1}
        mach (8|M0)              r45.0<1>:ud   r74.0<1;1,0>:ud   r70.0<1;1,0>:ud  {AccWrEn,Compacted}
(W)     mov (2|M0)               r2.4<1>:d     0:w                              
        mov (8|M0)               acc0.0<1>:ud  acc0.0<1;1,0>:ud                
        mov (8|M0)               r41.0<1>:f    r45.0<1;1,0>:f                   {Compacted,I@3}
        mov (8|M0)               r36.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
L23728:
(W)     shl (1|M0)               r3.1<1>:d     r2.7<0;1,0>:d     31:w               {F@2}
(W)     shr (1|M0)               r3.0<1>:ud    r3.4<0;1,0>:ud    1:w              
(W)     cmp (8|M0)    (gt)f1.0   null<1>:ud    r2.4<0;1,0>:ud    0x3E:uw              {I@5}
(W)     or (1|M0)                r3.4<1>:d     r3.0<0;1,0>:d     r3.1<0;1,0>:d    {I@2}
        bfn.0xA8 (8|M0)          r97.0<1>:ud   r36.0<1;0>:ud     r3.0<0;0>:ud      r3.1<0>:ud       // s0&(s1|s2)
(W)     shr (1|M0)               r2.6<1>:ud    r2.7<0;1,0>:ud    1:w              
(W&f1.0) cmp (8|M0)   (eq)f1.0   null<1>:d     r2.5<0;1,0>:d     0:w              
        cmp (8|M0)    (eq)f0.1   null<1>:d     r97.0<1;1,0>:d    r3.4<0;1,0>:d    {I@3}
        and (8|M0)               r96.0<1>:d    r41.0<1;1,0>:d    r2.6<0;1,0>:d    {Compacted,A@1}
(W)     mov (1|M0)               r3.12<1>:hf   0x1:hf                             
(W&~f1.0) cmp (8|M0)  (gt)f1.0   null<1>:ud    r2.5<0;1,0>:ud    0x0:uw             
(f0.1)  cmp (8|M0)    (eq)f0.1   null<1>:d     r96.0<1;1,0>:d    r2.6<0;1,0>:d    {I@2}
(W)     addc (1|M0)              r25.0<1>:ud   r2.4<0;1,0>:ud    0x1:ud              {AccWrEn}
        mov (8|M0)               r49.0<1>:d    r2.4<0;1,0>:d                   
(f1.0)  sel (8|M0)               r3.0<1>:uw    r3.12<0;1,0>:uw   0x0:uw              {F@1}
(f0.1)  sel (8|M0)               r2.0<1>:uw    r3.12<0;1,0>:uw   0x0:uw             
(W)     mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        or (8|M0)     (ne)f0.1   null<1>:uw    r3.0<1;1,0>:uw    r2.0<1;1,0>:uw   {I@2}
(W)     add (1|M0)               r3.5<1>:ud    r7.0<0;1,0>:ud    r2.5<0;1,0>:ud   {I@2}
        mov (8|M0)               r55.0<1>:d    r2.5<0;1,0>:d                   
        mov (8|M0)               r86.0<1>:f    r25.0<0;1,0>:f                   {Compacted}
        mov (8|M0)               r126.0<1>:d   r3.5<0;1,0>:d                    {I@2}
(f0.1)  goto (8|M0)                          L24136                  L24136                
L24072:
(W)     mov (1|M0)               r2.7<1>:d     r2.6<0;1,0>:d                   
(W)     mov (1|M0)               r2.4<1>:d     r25.0<0;1,0>:d                  
(W)     mov (1|M0)               r2.5<1>:f     r3.5<0;1,0>:f                    {I@5}
(W)     jmpi                                 L23728                                
L24136:
        join (8|M0)                          L29312                                
L24152:
(W)     mov (1|M0)               r6.3<1>:f     8.68805e-44:f                              
(W)     mov (1|M0)               r7.0<1>:hf    0.0:hf                             
        subb (8|M0)              r98.0<1>:ud   r6.3<0;1,0>:ud    r49.0<1;1,0>:ud  {AccWrEn,Compacted,F@2}
        add3 (8|M0)              r123.0<1>:d   r31.0<1;0>:d      r98.0<1;0>:d      -46:w               {I@1}
        add3 (8|M0)              r35.0<1>:ud   -acc0.0<1;0>:ud   r7.0<0;0>:uw      -r55.0<1>:ud     {F@1}
        cmp (8|M0)    (gt)f0.1   null<1>:d     r123.0<1;1,0>:d   127:w               {I@2}
        add3 (8|M0)              r119.0<1>:d   r48.0<1;0>:d      r47.0<1;0>:d      r98.0<1>:d      
(f0.1)  goto (8|M0)                          L29240                  L29240                
L24272:
        cmp (8|M0)    (gt)f0.0   null<1>:d     r123.0<1;1,0>:d   -127:w              
(f0.0)  goto (8|M0)                          L26824                  L26824                
L24304:
        cmp (8|M0)    (lt)f1.1   null<1>:ud    r123.0<1;1,0>:ud  0xFFFFFF6B:ud             
(f1.1)  goto (8|M0)                          L26304                  L26304                
L24336:
(W)     mov (1|M0)               r6.3<1>:f     8.82818e-44:f                              
        add3 (8|M0)              r117.0<1>:d   r31.0<1;0>:d      r98.0<1;0>:d      104:w              
        subb (8|M0)              r33.0<1>:ud   r6.3<0;1,0>:ud    r49.0<1;1,0>:ud  {AccWrEn,Compacted,F@1}
(W)     mov (1|M0)               r7.0<1>:hf    0.0:hf                              {I@7}
        cmp (8|M0)    (gt)f0.0   null<1>:ud    r33.0<1;1,0>:ud   r117.0<1;1,0>:ud {I@1}
        add3 (8|M0)              r64.0<1>:ud   -acc0.0<1;0>:ud   r7.0<0;0>:uw      -r55.0<1>:ud     {F@1}
(f0.0)  cmp (8|M0)    (eq)f0.0   null<1>:d     r64.0<1;1,0>:d    0:w               {I@1}
(~f0.0) cmp (8|M0)    (gt)f0.0   null<1>:ud    r64.0<1;1,0>:ud   0x0:uw             
(f0.0)  goto (8|M0)                          L24536                  L24536                
L24472:
        add3 (8|M0)              acc0.0<1>:d   r119.0<1;0>:d     -r33.0<1;0>:d     104:w              
        mov (8|M0)               r75.0<1>:d    0:w                              
        shl (8|M0)               r76.0<1>:d    r36.0<1;1,0>:d    acc0.0<1;1,0>:d 
        goto (8|M0)                          L24536                  L26240                
L24536:
        join (8|M0)                          L26240                                
L24552:
        add3 (8|M0)              r34.0<1>:d    r33.0<1;0>:d      -r119.0<1;0>:d    -104:w              
        cmp (8|M0)    (lt)f1.0   null<1>:d     r34.0<1;1,0>:d    2:w               {I@1}
(f1.0)  goto (8|M0)                          L24696                  L24696                
L24600:
        cmp (8|M0)    (eq)f0.1   null<1>:d     r34.0<1;1,0>:d    2:w              
(~f0.1) goto (8|M0)                          L24696                  L24792                
L24632:
        shr (8|M0)               r42.0<1>:ud   r36.0<1;1,0>:ud   1:w              
        and (8|M0)               r31.0<1>:d    r36.0<1;1,0>:d    1:w               {Compacted}
        mov (8|M0)               r111.0<1>:d   0:w                              
        mov (8|M0)               r93.0<1>:f    r42.0<1;1,0>:f                   {Compacted,I@3}
        goto (8|M0)                          L24696                  L25672                
L24696:
        join (8|M0)                          L24792                                
L24712:
        cmp (8|M0)    (eq)f0.0   null<1>:d     r34.0<1;1,0>:d    1:w               {Compacted}
(~f0.0) goto (8|M0)                          L24792                  L24792                
L24736:
        mov (8|M0)               r111.0<1>:d   0:w                              
        mov (8|M0)               r31.0<1>:d    0:w                              
        mov (8|M0)               r93.0<1>:f    r36.0<1;1,0>:f                   {Compacted}
        goto (8|M0)                          L24792                  L25672                
L24792:
        join (8|M0)                          L25672                                
L24808:
        add3 (8|M0)              acc0.0<1>:d   r33.0<1;0>:d      -r117.0<1;0>:d    -1:w              
        and (8|M0)    (ne)f1.1   r69.0<1>:d    acc0.0<1;1,0>:d   63:w              
(f1.1)  goto (8|M0)                          L24888                  L24888                
L24856:
        mov (8|M0)               r23.0<1>:d    r36.0<1;1,0>:d                  
        goto (8|M0)                          L24888                  L25024                
L24888:
        join (8|M0)                          L25024                                
L24904:
        cmp (8|M0)    (lt)f1.0   null<1>:ud    r69.0<1;1,0>:ud   0x20:uw              {I@5}
(f1.0)  add (8|M0)               acc0.0<1>:d   -r69.0<1;1,0>:d   32:w              
(~f1.0) add (8|M0)               acc2.0<1>:d   r69.0<1;1,0>:d    -32:w              
(f1.0)  shr (8|M0)               r44.0<1>:ud   r36.0<1;1,0>:ud   r69.0<1;1,0>:d  
(f1.0)  shl (8|M0)               r113.0<1>:d   r41.0<1;1,0>:d    acc0.0<1;1,0>:d 
(~f1.0) shr (8|M0)               r42.0<1>:ud   r41.0<1;1,0>:ud   acc2.0<1;1,0>:d  {F@2}
(f1.0)  or (8|M0)                r42.0<1>:d    r44.0<1;1,0>:d    r113.0<1;1,0>:d  {I@2}
        mov (8|M0)               r23.0<1>:f    r42.0<1;1,0>:f                   {Compacted,I@1}
L25024:
        join (8|M0)                          L25672                                
L25040:
        add3 (8|M0)              r97.0<1>:d    r33.0<1;0>:d      -r117.0<1;0>:d    -2:w              
        and (8|M0)    (ne)f0.1   r68.0<1>:d    r97.0<1;1,0>:d    63:w               {I@1}
(f0.1)  goto (8|M0)                          L25120                  L25120                
L25088:
        mov (8|M0)               r42.0<1>:d    r36.0<1;1,0>:d                   {F@1}
        goto (8|M0)                          L25120                  L25248                
L25120:
        join (8|M0)                          L25248                                
L25136:
        cmp (8|M0)    (lt)f0.0   null<1>:ud    r68.0<1;1,0>:ud   0x20:uw              {I@5}
(~f0.0) add (8|M0)               acc0.0<1>:d   r68.0<1;1,0>:d    -32:w              
(f0.0)  add (8|M0)               acc2.0<1>:d   -r68.0<1;1,0>:d   32:w              
(~f0.0) shr (8|M0)               r42.0<1>:ud   r41.0<1;1,0>:ud   acc0.0<1;1,0>:d 
(f0.0)  shl (8|M0)               r112.0<1>:d   r41.0<1;1,0>:d    acc2.0<1;1,0>:d 
(f0.0)  shr (8|M0)               r42.0<1>:ud   r36.0<1;1,0>:ud   r68.0<1;1,0>:d  
(f0.0)  or (8|M0)                r42.0<1>:d    r42.0<1;1,0>:d    r112.0<1;1,0>:d  {I@1}
L25248:
        join (8|M0)                          L25672                                
L25264:
        and (8|M0)    (ne)f1.1   r111.0<1>:d   r97.0<1;1,0>:d    63:w              
        and (8|M0)               r31.0<1>:d    r42.0<1;1,0>:d    1:w               {Compacted,I@3}
(f1.1)  goto (8|M0)                          L25352                  L25352                
L25304:
        mov (8|M0)               r3.0<1>:d     -1:w                              
        mov (8|M0)               r43.0<1>:d    -1:w                              
        goto (8|M0)                          L25352                  L25536                
L25352:
        join (8|M0)                          L25536                                
L25368:
        cmp (8|M0)    (lt)f1.0   null<1>:ud    r111.0<1;1,0>:ud  0x20:uw              {I@7}
(f1.0)  goto (8|M0)                          L25472                  L25472                
L25400:
        add (8|M0)               acc0.0<1>:d   r111.0<1;1,0>:d   -32:w               {Compacted}
(W)     mov (1|M0)               r6.6<1>:hf    -qnan(0x1FF):hf                             
        mov (8|M0)               r3.0<1>:d     0:w                              
        shl (8|M0)               r43.0<1>:d    r6.6<0;1,0>:w     acc0.0<1;1,0>:d  {F@1}
        goto (8|M0)                          L25472                  L25536                
L25472:
        join (8|M0)                          L25536                                
L25488:
(W)     mov (1|M0)               r6.6<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (8|M0)               r43.0<1>:d    -1:w                              
        shl (8|M0)               r3.0<1>:d     r6.6<0;1,0>:w     r111.0<1;1,0>:d  {F@1}
L25536:
        join (8|M0)                          L25672                                
L25552:
        bfn.0x28 (8|M0)          r40.0<1>:ud   r36.0<1;0>:ud     r3.0<1;0>:ud      r5.7<0>:ud       {I@2} // s0&(s1^s2)
        bfn.0x28 (8|M0)          r39.0<1>:ud   r41.0<1;0>:ud     r43.0<1;0>:ud     r5.7<0>:ud       // s0&(s1^s2)
        cmp (8|M0)    (ne)f1.1   null<1>:d     r40.0<1;1,0>:d    0:w               {I@2}
(W)     mov (1|M0)               r6.6<1>:hf    -qnan(0x1FF):hf                             
        mov (8|M0)               r93.0<1>:f    r23.0<1;1,0>:f                   {Compacted}
(~f1.1) cmp (8|M0)    (ne)f1.1   null<1>:d     r39.0<1;1,0>:d    0:w               {I@2}
(f1.1)  sel (8|M0)               acc0.0<1>:d   r6.6<0;1,0>:w     0:w               {F@2}
        mov (8|M0)               r111.0<1>:d   -acc0.0<1;1,0>:d                
L25672:
        join (8|M0)                          L26240                                
L25688:
        and (8|M0)    (ne)f0.1   r67.0<1>:d    r34.0<1;1,0>:d    63:w              
(f0.1)  goto (8|M0)                          L25752                  L25752                
L25720:
        mov (8|M0)               r42.0<1>:d    r36.0<1;1,0>:d                  
        goto (8|M0)                          L25752                  L25880                
L25752:
        join (8|M0)                          L25880                                
L25768:
        cmp (8|M0)    (lt)f0.0   null<1>:ud    r67.0<1;1,0>:ud   0x20:uw              {I@5}
(f0.0)  add (8|M0)               acc0.0<1>:d   -r67.0<1;1,0>:d   32:w              
(~f0.0) add (8|M0)               acc2.0<1>:d   r67.0<1;1,0>:d    -32:w              
(f0.0)  shr (8|M0)               r36.0<1>:ud   r36.0<1;1,0>:ud   r67.0<1;1,0>:d  
(f0.0)  shl (8|M0)               r110.0<1>:d   r41.0<1;1,0>:d    acc0.0<1;1,0>:d 
(~f0.0) shr (8|M0)               r42.0<1>:ud   r41.0<1;1,0>:ud   acc2.0<1;1,0>:d 
(f0.0)  or (8|M0)                r42.0<1>:d    r36.0<1;1,0>:d    r110.0<1;1,0>:d  {I@2}
L25880:
        join (8|M0)                          L26240                                
L25896:
        shl (8|M0)               r69.0<1>:d    r93.0<1;1,0>:d    2:w               {Compacted,F@1}
        shl (8|M0)               r35.0<1>:d    r31.0<1;1,0>:d    1:w               {Compacted}
        and (8|M0)               r69.0<1>:d    r69.0<1;1,0>:d    4:w               {Compacted,I@2}
        bfn.0xFE (8|M0)          r52.0<1>:ud   r69.0<1;0>:ud     r35.0<1;0>:ud     r111.0<1>:ud     {I@1} // s0|s1|s2
        cmp (8|M0)    (eq)f1.1   null<1>:d     r52.0<1;1,0>:d    0:w               {I@1}
(~f1.1) goto (8|M0)                          L26000                  L26000                
L25968:
        mov (8|M0)               r56.0<1>:d    0:w                              
        goto (8|M0)                          L26000                  L26160                
L26000:
        join (8|M0)                          L26160                                
L26016:
        cmp (8|M0)    (gt)f1.0   null<1>:ud    r52.0<1;1,0>:ud   0x4:uw             
(~f1.0) goto (8|M0)                          L26080                  L26080                
L26048:
        mov (8|M0)               r56.0<1>:d    1:w                              
        goto (8|M0)                          L26080                  L26160                
L26080:
        join (8|M0)                          L26160                                
L26096:
        and (8|M0)    (ne)f1.0   null<1>:d     r42.0<1;1,0>:d    1:w              
(W)     mov (1|M0)               r6.6<1>:hf    0x1:hf                             
(f1.0)  cmp (8|M0)    (eq)f1.0   null<1>:d     r52.0<1;1,0>:d    4:w              
(f1.0)  sel (8|M0)               r56.0<1>:d    r6.6<0;1,0>:w     0:w               {F@1}
L26160:
        join (8|M0)                          L26240                                
L26176:
        add (8|M0)               r44.0<1>:d    r56.0<1;1,0>:d    r42.0<1;1,0>:d   {Compacted,I@2}
(W)     mov (1|M0)               r6.3<1>:f     0x800000:f                               {Compacted}
        cmp (8|M0)    (gt)f0.0   null<1>:ud    r44.0<1;1,0>:ud   0x7FFFFF:ud              {I@1}
(~f0.0) sel (8|M0)               r76.0<1>:d    r44.0<1;1,0>:d    0:w              
(f0.0)  sel (8|M0)               r75.0<1>:d    r6.3<0;1,0>:d     0:w               {F@1}
L26240:
        join (8|M0)                          L26304                                
L26256:
        and (8|M0)               r34.0<1>:d    r32.0<1;1,0>:d    -2147483648:d              
        bfn.0xFE (8|M0)          r65.0<1>:ud   r34.0<1;0>:ud     r75.0<1;0>:ud     r76.0<1>:ud      {I@1} // s0|s1|s2
        goto (8|M0)                          L26304                  L29488                
L26304:
        join (8|M0)                          L26824                                
L26320:
        and (8|M0)    (ne)f0.1   r81.0<1>:d    r98.0<1;1,0>:d    63:w              
(f0.1)  goto (8|M0)                          L26400                  L26400                
L26352:
        mov (8|M0)               r93.0<1>:d    -1:w                              
        mov (8|M0)               r109.0<1>:d   -1:w                              
        goto (8|M0)                          L26400                  L26584                
L26400:
        join (8|M0)                          L26584                                
L26416:
        cmp (8|M0)    (lt)f0.0   null<1>:ud    r81.0<1;1,0>:ud   0x20:uw              {I@6}
(f0.0)  goto (8|M0)                          L26520                  L26520                
L26448:
        add (8|M0)               acc0.0<1>:d   r81.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r6.6<1>:hf    -qnan(0x1FF):hf                             
        mov (8|M0)               r93.0<1>:d    0:w                              
        shl (8|M0)               r109.0<1>:d   r6.6<0;1,0>:w     acc0.0<1;1,0>:d  {F@1}
        goto (8|M0)                          L26520                  L26584                
L26520:
        join (8|M0)                          L26584                                
L26536:
(W)     mov (1|M0)               r6.6<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (8|M0)               r109.0<1>:d   -1:w                              
        shl (8|M0)               r93.0<1>:d    r6.6<0;1,0>:w     r81.0<1;1,0>:d   {F@1}
L26584:
        join (8|M0)                          L26824                                
L26600:
        bfn.0x28 (8|M0)          r33.0<1>:ud   r36.0<1;0>:ud     r93.0<1;0>:ud     r5.7<0>:ud       {I@2} // s0&(s1^s2)
        bfn.0x28 (8|M0)          r31.0<1>:ud   r41.0<1;0>:ud     r109.0<1;0>:ud    r5.7<0>:ud       // s0&(s1^s2)
        cmp (8|M0)    (ne)f0.1   null<1>:d     r33.0<1;1,0>:d    0:w               {I@2}
        cmp (8|M0)    (gt)f1.1   null<1>:d     r32.0<1;1,0>:d    -1:w              
(~f0.1) cmp (8|M0)    (ne)f0.1   null<1>:d     r31.0<1;1,0>:d    0:w               {I@3}
(f0.1)  cmp (8|M0)    (eq)f0.1   null<1>:d     r123.0<1;1,0>:d   -150:w              
(f1.1)  goto (8|M0)                          L26760                  L26760                
L26712:
(W)     mov (1|M0)               r6.3<1>:ud    0x80000001:ud                             
(f0.1)  sel (8|M0)               r65.0<1>:f    r6.3<0;1,0>:f     -0.0:f               {I@1}
        goto (8|M0)                          L26760                  L29488                
L26760:
        join (8|M0)                          L26824                                
L26776:
(W)     mov (1|M0)               r6.3<1>:ud    0x1:ud                              {F@1}
(f0.1)  sel (8|M0)               r65.0<1>:f    r6.3<0;1,0>:f     0.0:f               {I@1}
        goto (8|M0)                          L26824                  L29488                
L26824:
        join (8|M0)                          L29240                                
L26840:
        cmp (8|M0)    (lt)f0.1   null<1>:ud    r98.0<1;1,0>:ud   0x18:uw              {F@1}
        add3 (8|M0)              r43.0<1>:d    r31.0<1;0>:d      r98.0<1;0>:d      81:w              
(f0.1)  cmp (8|M0)    (eq)f0.1   null<1>:d     r35.0<1;1,0>:d    0:w              
(f0.1)  goto (8|M0)                          L28920                  L28920                
L26904:
        shl (8|M0)               r102.0<1>:d   r86.0<1;1,0>:d    1:w               {Compacted}
        shr (8|M0)               r101.0<1>:ud  r86.0<1;1,0>:ud   31:w              
        shl (8|M0)               r91.0<1>:d    r126.0<1;1,0>:d   1:w               {Compacted}
        cmp (8|M0)    (lt)f1.1   null<1>:ud    r102.0<1;1,0>:ud  0x4E:uw              {I@3}
        or (8|M0)                r91.0<1>:d    r91.0<1;1,0>:d    r101.0<1;1,0>:d  {Compacted,I@2}
(f1.1)  cmp (8|M0)    (eq)f1.1   null<1>:d     r91.0<1;1,0>:d    0:w               {I@1}
(~f1.1) cmp (8|M0)    (lt)f1.1   null<1>:d     r91.0<1;1,0>:d    0:w              
(f1.1)  goto (8|M0)                          L27128                  L27128                
L27008:
        cmp (8|M0)    (eq)f0.0   null<1>:d     r86.0<1;1,0>:d    39:w               {Compacted}
(f0.0)  cmp (8|M0)    (eq)f0.0   null<1>:d     r126.0<1;1,0>:d   0:w              
(~f0.0) goto (8|M0)                          L27128                  L27192                
L27048:
        shr (8|M0)               r42.0<1>:ud   r36.0<1;1,0>:ud   1:w              
        mov (8|M0)               r124.0<1>:d   0:w                              
        mov (8|M0)               r35.0<1>:d    0:w                              
        mov (8|M0)               r114.0<1>:f   r42.0<1;1,0>:f                   {Compacted,I@3}
        mov (8|M0)               r42.0<1>:f    r36.0<1;1,0>:f                   {Compacted}
        goto (8|M0)                          L27128                  L28384                
L27128:
        join (8|M0)                          L27192                                
L27144:
        cmp (8|M0)    (eq)f1.1   null<1>:d     r86.0<1;1,0>:d    38:w              
(f1.1)  cmp (8|M0)    (eq)f1.1   null<1>:d     r126.0<1;1,0>:d   0:w              
(f1.1)  goto (8|M0)                          L27192                  L28304                
L27192:
        join (8|M0)                          L28304                                
L27208:
        add (8|M0)               acc0.0<1>:d   -r86.0<1;1,0>:d   39:w               {Compacted}
        add (8|M0)               r44.0<1>:d    -r86.0<1;1,0>:d   40:w               {Compacted}
        and (8|M0)    (ne)f1.0   r82.0<1>:d    acc0.0<1;1,0>:d   63:w              
(f1.0)  goto (8|M0)                          L27288                  L27288                
L27256:
        mov (8|M0)               r34.0<1>:d    r36.0<1;1,0>:d                  
        goto (8|M0)                          L27288                  L27424                
L27288:
        join (8|M0)                          L27424                                
L27304:
        cmp (8|M0)    (lt)f0.1   null<1>:ud    r82.0<1;1,0>:ud   0x20:uw              {I@5}
(~f0.1) add (8|M0)               acc0.0<1>:d   r82.0<1;1,0>:d    -32:w              
(f0.1)  shr (8|M0)               r28.0<1>:ud   r36.0<1;1,0>:ud   r82.0<1;1,0>:d  
(~f0.1) shr (8|M0)               r42.0<1>:ud   r41.0<1;1,0>:ud   acc0.0<1;1,0>:d  {F@1}
(f0.1)  add (8|M0)               acc0.0<1>:d   -r82.0<1;1,0>:d   32:w              
(f0.1)  shl (8|M0)               r42.0<1>:d    r41.0<1;1,0>:d    acc0.0<1;1,0>:d 
(f0.1)  or (8|M0)                r42.0<1>:d    r28.0<1;1,0>:d    r42.0<1;1,0>:d   {I@1}
        mov (8|M0)               r34.0<1>:f    r42.0<1;1,0>:f                   {Compacted,I@1}
L27424:
        join (8|M0)                          L28304                                
L27440:
        add (8|M0)               r112.0<1>:d   -r86.0<1;1,0>:d   38:w               {Compacted}
        and (8|M0)    (ne)f0.0   r90.0<1>:d    r112.0<1;1,0>:d   63:w               {I@1}
(f0.0)  goto (8|M0)                          L27512                  L27512                
L27480:
        mov (8|M0)               r42.0<1>:d    r36.0<1;1,0>:d                   {F@1}
        goto (8|M0)                          L27512                  L27640                
L27512:
        join (8|M0)                          L27640                                
L27528:
        cmp (8|M0)    (lt)f1.1   null<1>:ud    r90.0<1;1,0>:ud   0x20:uw              {I@5}
(f1.1)  add (8|M0)               acc0.0<1>:d   -r90.0<1;1,0>:d   32:w              
(~f1.1) add (8|M0)               acc2.0<1>:d   r90.0<1;1,0>:d    -32:w              
(f1.1)  shr (8|M0)               r26.0<1>:ud   r36.0<1;1,0>:ud   r90.0<1;1,0>:d  
(f1.1)  shl (8|M0)               r60.0<1>:d    r41.0<1;1,0>:d    acc0.0<1;1,0>:d 
(~f1.1) shr (8|M0)               r42.0<1>:ud   r41.0<1;1,0>:ud   acc2.0<1;1,0>:d 
(f1.1)  or (8|M0)                r42.0<1>:d    r26.0<1;1,0>:d    r60.0<1;1,0>:d   {I@2}
L27640:
        join (8|M0)                          L28304                                
L27656:
        and (8|M0)    (ne)f1.0   r59.0<1>:d    r112.0<1;1,0>:d   63:w              
        and (8|M0)               r35.0<1>:d    r42.0<1;1,0>:d    1:w               {Compacted,I@3}
(f1.0)  goto (8|M0)                          L27744                  L27744                
L27696:
        mov (8|M0)               r71.0<1>:d    -1:w                              
        mov (8|M0)               r84.0<1>:d    -1:w                              
        goto (8|M0)                          L27744                  L27928                
L27744:
        join (8|M0)                          L27928                                
L27760:
        cmp (8|M0)    (lt)f0.1   null<1>:ud    r59.0<1;1,0>:ud   0x20:uw              {I@7}
(f0.1)  goto (8|M0)                          L27864                  L27864                
L27792:
        add (8|M0)               acc0.0<1>:d   r59.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r6.6<1>:hf    -qnan(0x1FF):hf                             
        mov (8|M0)               r71.0<1>:d    0:w                              
        shl (8|M0)               r84.0<1>:d    r6.6<0;1,0>:w     acc0.0<1;1,0>:d  {F@1}
        goto (8|M0)                          L27864                  L27928                
L27864:
        join (8|M0)                          L27928                                
L27880:
(W)     mov (1|M0)               r6.6<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (8|M0)               r84.0<1>:d    -1:w                              
        shl (8|M0)               r71.0<1>:d    r6.6<0;1,0>:w     r59.0<1;1,0>:d   {F@1}
L27928:
        join (8|M0)                          L28304                                
L27944:
        bfn.0x28 (8|M0)          r25.0<1>:ud   r36.0<1;0>:ud     r71.0<1;0>:ud     r5.7<0>:ud       {I@2} // s0&(s1^s2)
        bfn.0x28 (8|M0)          r23.0<1>:ud   r41.0<1;0>:ud     r84.0<1;0>:ud     r5.7<0>:ud       // s0&(s1^s2)
        cmp (8|M0)    (ne)f1.0   null<1>:d     r25.0<1;1,0>:d    0:w               {I@2}
(W)     mov (1|M0)               r6.6<1>:hf    -qnan(0x1FF):hf                             
        and (8|M0)    (ne)f0.0   r89.0<1>:d    r44.0<1;1,0>:d    63:w              
(~f1.0) cmp (8|M0)    (ne)f1.0   null<1>:d     r23.0<1;1,0>:d    0:w               {I@3}
(f1.0)  sel (8|M0)               acc0.0<1>:d   r6.6<0;1,0>:w     0:w               {F@1}
        mov (8|M0)               r124.0<1>:d   -acc0.0<1;1,0>:d                
(f0.0)  goto (8|M0)                          L28120                  L28120                
L28088:
        mov (8|M0)               r42.0<1>:d    r36.0<1;1,0>:d                  
        goto (8|M0)                          L28120                  L28248                
L28120:
        join (8|M0)                          L28248                                
L28136:
        cmp (8|M0)    (lt)f1.1   null<1>:ud    r89.0<1;1,0>:ud   0x20:uw              {I@7}
(f1.1)  add (8|M0)               acc0.0<1>:d   -r89.0<1;1,0>:d   32:w              
(~f1.1) add (8|M0)               acc2.0<1>:d   r89.0<1;1,0>:d    -32:w              
(f1.1)  shr (8|M0)               r2.0<1>:ud    r36.0<1;1,0>:ud   r89.0<1;1,0>:d  
(f1.1)  shl (8|M0)               r58.0<1>:d    r41.0<1;1,0>:d    acc0.0<1;1,0>:d 
(~f1.1) shr (8|M0)               r42.0<1>:ud   r41.0<1;1,0>:ud   acc2.0<1;1,0>:d 
(f1.1)  or (8|M0)                r42.0<1>:d    r2.0<1;1,0>:d     r58.0<1;1,0>:d   {I@2}
L28248:
        join (8|M0)                          L28304                                
L28264:
        mov (8|M0)               r114.0<1>:f   r42.0<1;1,0>:f                   {Compacted,I@2}
        mov (8|M0)               r42.0<1>:d    r34.0<1;1,0>:d                   {F@1}
        goto (8|M0)                          L28304                  L28384                
L28304:
        join (8|M0)                          L28384                                
L28320:
        shr (8|M0)               r42.0<1>:ud   r36.0<1;1,0>:ud   2:w              
        and (8|M0)               r35.0<1>:d    r36.0<1;1,0>:d    1:w               {Compacted}
        mov (8|M0)               r124.0<1>:d   0:w                              
        mov (8|M0)               r114.0<1>:f   r42.0<1;1,0>:f                   {Compacted,I@3}
        shr (8|M0)               r42.0<1>:ud   r36.0<1;1,0>:ud   1:w               {F@1}
L28384:
        join (8|M0)                          L28920                                
L28400:
        shl (8|M0)               r2.0<1>:d     r42.0<1;1,0>:d    2:w               {Compacted,I@2}
        shl (8|M0)               r127.0<1>:d   r35.0<1;1,0>:d    1:w               {Compacted}
        and (8|M0)               r2.0<1>:d     r2.0<1;1,0>:d     4:w               {Compacted,I@2}
        and (8|M0)               r120.0<1>:d   r114.0<1;1,0>:d   8388607:d              
        bfn.0xFE (8|M0)          r80.0<1>:ud   r2.0<1;0>:ud      r127.0<1;0>:ud    r124.0<1>:ud     {I@2} // s0|s1|s2
        cmp (8|M0)    (eq)f1.0   null<1>:d     r80.0<1;1,0>:d    0:w               {I@1}
(~f1.0) goto (8|M0)                          L28520                  L28520                
L28488:
        mov (8|M0)               r79.0<1>:d    0:w                              
        goto (8|M0)                          L28520                  L28680                
L28520:
        join (8|M0)                          L28680                                
L28536:
        cmp (8|M0)    (gt)f0.1   null<1>:ud    r80.0<1;1,0>:ud   0x4:uw             
(~f0.1) goto (8|M0)                          L28600                  L28600                
L28568:
        mov (8|M0)               r79.0<1>:d    1:w                              
        goto (8|M0)                          L28600                  L28680                
L28600:
        join (8|M0)                          L28680                                
L28616:
        and (8|M0)    (ne)f0.1   null<1>:d     r114.0<1;1,0>:d   1:w              
(W)     mov (1|M0)               r6.6<1>:hf    0x1:hf                             
(f0.1)  cmp (8|M0)    (eq)f0.1   null<1>:d     r80.0<1;1,0>:d    4:w              
(f0.1)  sel (8|M0)               r79.0<1>:d    r6.6<0;1,0>:w     0:w               {F@1}
L28680:
        join (8|M0)                          L28920                                
L28696:
        add (8|M0)               r63.0<1>:d    r120.0<1;1,0>:d   r79.0<1;1,0>:d   {Compacted,I@2}
        add3 (8|M0)              r54.0<1>:d    r31.0<1;0>:d      r98.0<1;0>:d      82:w              
        cmp (8|M0)    (gt)f1.0   null<1>:ud    r63.0<1;1,0>:ud   0x7FFFFF:ud              {I@2}
(f1.0)  sel (8|M0)               r49.0<1>:d    r54.0<1;1,0>:d    r43.0<1;1,0>:d   {I@2}
        cmp (8|M0)    (eq)f0.0   null<1>:d     r49.0<1;1,0>:d    255:w               {Compacted,I@1}
(f0.0)  goto (8|M0)                          L28848                  L28848                
L28776:
(~f1.0) sel (8|M0)               r59.0<1>:d    r63.0<1;1,0>:d    0:w              
        and (8|M0)               r53.0<1>:d    r32.0<1;1,0>:d    -2147483648:d              
        shl (8|M0)               r126.0<1>:d   r49.0<1;1,0>:d    23:w               {Compacted}
        bfn.0xFE (8|M0)          r65.0<1>:ud   r53.0<1;0>:ud     r126.0<1;0>:ud    r59.0<1>:ud      {I@1} // s0|s1|s2
        goto (8|M0)                          L28848                  L29488                
L28848:
        join (8|M0)                          L28920                                
L28864:
        cmp (8|M0)    (gt)f1.1   null<1>:d     r32.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r6.3<1>:f     inf:f                               {Compacted}
(f1.1)  sel (8|M0)               r65.0<1>:f    r6.3<0;1,0>:f     -inf:f               {A@1}
        goto (8|M0)                          L28920                  L29488                
L28920:
        join (8|M0)                          L29240                                
L28936:
        and (8|M0)    (ne)f1.1   r52.0<1>:d    r98.0<1;1,0>:d    63:w               {F@1}
(f1.1)  goto (8|M0)                          L29000                  L29000                
L28968:
        mov (8|M0)               r68.0<1>:d    -1:w                              
        goto (8|M0)                          L29000                  L29128                
L29000:
        join (8|M0)                          L29128                                
L29016:
        cmp (8|M0)    (lt)f1.0   null<1>:ud    r52.0<1;1,0>:ud   0x20:uw              {I@5}
(f1.0)  goto (8|M0)                          L29080                  L29080                
L29048:
        mov (8|M0)               r68.0<1>:d    0:w                              
        goto (8|M0)                          L29080                  L29128                
L29080:
        join (8|M0)                          L29128                                
L29096:
(W)     mov (1|M0)               r6.6<1>:hf    -qnan(0x1FF):hf                             
        shl (8|M0)               r68.0<1>:d    r6.6<0;1,0>:w     r52.0<1;1,0>:d   {F@1}
L29128:
        join (8|M0)                          L29240                                
L29144:
        bfn.0x28 (8|M0)          r78.0<1>:ud   r36.0<1;0>:ud     r68.0<1;0>:ud     r5.7<0>:ud       {I@2} // s0&(s1^s2)
        add (8|M0)               acc0.0<1>:d   -r98.0<1;1,0>:d   23:w               {Compacted}
        and (8|M0)               r52.0<1>:d    r32.0<1;1,0>:d    -2147483648:d              
        shl (8|M0)               r124.0<1>:d   r43.0<1;1,0>:d    23:w               {Compacted}
        shl (8|M0)               r78.0<1>:d    r78.0<1;1,0>:d    acc0.0<1;1,0>:d  {I@4}
        bfn.0xFE (8|M0)          r65.0<1>:ud   r52.0<1;0>:ud     r124.0<1;0>:ud    r78.0<1>:ud      {I@1} // s0|s1|s2
        goto (8|M0)                          L29240                  L29488                
L29240:
        join (8|M0)                          L29312                                
L29256:
        cmp (8|M0)    (gt)f1.0   null<1>:d     r32.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r6.3<1>:f     inf:f                               {Compacted}
(f1.0)  sel (8|M0)               r65.0<1>:f    r6.3<0;1,0>:f     -inf:f               {A@1}
        goto (8|M0)                          L29312                  L29488                
L29312:
        join (8|M0)                          L29384                                
L29328:
        cmp (8|M0)    (lt)f0.1   null<1>:d     r32.0<1;1,0>:d    0:w              
(W)     mov (1|M0)               r6.3<1>:f     -0.0:f                               {Compacted}
(f0.1)  sel (8|M0)               r65.0<1>:f    r6.3<0;1,0>:f     0.0:f               {F@1}
        goto (8|M0)                          L29384                  L29488                
L29384:
        join (8|M0)                          L29456                                
L29400:
        cmp (8|M0)    (gt)f0.0   null<1>:d     r32.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r6.3<1>:f     inf:f                               {Compacted}
(f0.0)  sel (8|M0)               r65.0<1>:f    r6.3<0;1,0>:f     -inf:f               {F@1}
        goto (8|M0)                          L29456                  L29488                
L29456:
        join (8|M0)                          L29488                                
L29472:
        bfn.0xF8 (8|M0)          r65.0<1>:ud   r32.0<1;0>:ud     r5.6<0;0>:ud      r5.3<0>:ud       {F@1} // s0&s1|s2
L29488:
        join (8|M0)                          L29536                                
L29504:
        mov (8|M0)               r2.0<1>:hf    r65.0<1;1,0>:f                   {I@2}
        mov (8|M0)               r22.0<1>:f    r2.0<1;1,0>:hf                   {F@1}
L29536:
        join (8|M0)                          L29552                                
L29552:
        and (8|M0)               r123.0<1>:d   r24.0<1;1,0>:d    -3:w               {Compacted}
        cmp (8|M0)    (eq)f0.1   null<1>:d     r123.0<1;1,0>:d   1:w               {I@1}
(f0.1)  goto (8|M0)                          L29672                  L29672                
L29592:
        mov (8|M0)               r2.0<1>:hf    r22.0<1;1,0>:f                   {F@1}
        cmp (8|M0)    (eq)f1.1   null<1>:d     r24.0<1;1,0>:d    4:w              
        mov (8|M0)               acc0.0<1>:f   r2.0<1;1,0>:hf                   {F@1}
(f1.1)  sel (8|M0)               r48.0<1>:f    acc0.0<1;1,0>:f   r22.0<1;1,0>:f  
        goto (8|M0)                          L29672                  L42384                
L29672:
        join (8|M0)                          L42384                                
L29688:
        and (8|M0)               r121.0<1>:d   r22.0<1;1,0>:d    2147483647:d              
        sel (8|M0)    (lt)f0.0   r77.0<1>:f    r121.0<1;1,0>:f   448.0:f               {Compacted,I@1}
        shr (8|M0)               r92.0<1>:ud   r77.0<1;1,0>:ud   23:w               {F@1}
        and (8|M0)    (ne)f0.0   r57.0<1>:d    r77.0<1;1,0>:d    8388607:d              
        and (8|M0)               r111.0<1>:d   r92.0<1;1,0>:d    255:w               {Compacted,I@2}
        sel (8|M0)    (ge)f0.0   r120.0<1>:ud  r111.0<1;1,0>:ud  0x79:uw              {I@1}
(f0.0)  cmp (8|M0)    (eq)f0.0   null<1>:d     r111.0<1;1,0>:d   255:w              
        shl (8|M0)               r31.0<1>:d    r120.0<1;1,0>:d   23:w               {Compacted,I@2}
(~f0.0) goto (8|M0)                          L29832                  L29832                
L29808:
        mov (8|M0)               r67.0<1>:f    qnan(0x0):f                               {Compacted}
        goto (8|M0)                          L29832                  L36000                
L29832:
        join (8|M0)                          L36000                                
L29848:
        cmp (8|M0)    (eq)f1.1   null<1>:d     r57.0<1;1,0>:d    0:w              
        add (8|M0)               r62.0<1>:d    -r31.0<1;1,0>:d   -2139095040:d               {I@5}
        xor (8|M0)               r34.0<1>:d    r62.0<1;1,0>:d    r77.0<1;1,0>:d   {Compacted,I@1}
(f1.1)  cmp (8|M0)    (eq)f1.1   null<1>:d     r111.0<1;1,0>:d   255:w              
(f1.1)  goto (8|M0)                          L35968                  L35968                
L29920:
        or (8|M0)     (eq)f0.0   null<1>:d     r111.0<1;1,0>:d   r57.0<1;1,0>:d  
(~f0.0) goto (8|M0)                          L29976                  L29976                
L29952:
        mov (8|M0)               r67.0<1>:f    0.0:f                               {Compacted}
        goto (8|M0)                          L29976                  L36000                
L29976:
        join (8|M0)                          L35968                                
L29992:
        cmp (8|M0)    (eq)f0.0   null<1>:d     r111.0<1;1,0>:d   0:w               {Compacted}
        shr (8|M0)               r41.0<1>:ud   r62.0<1;1,0>:ud   23:w              
        add (8|M0)               r43.0<1>:d    r111.0<1;1,0>:d   -127:w               {Compacted}
(f0.0)  mov (8|M0)               r43.0<1>:d    -126:w                              
        add (8|M0)               r126.0<1>:d   r41.0<1;1,0>:d    r43.0<1;1,0>:d   {Compacted,I@1}
        cmp (8|M0)    (gt)f1.1   null<1>:d     r126.0<1;1,0>:d   254:w               {I@1}
(f1.1)  goto (8|M0)                          L35896                  L35896                
L30080:
        or (8|M0)     (eq)f1.0   null<4>:b     r92.0<1;1,0>:d    r41.0<1;1,0>:d  
(f1.0)  goto (8|M0)                          L35832                  L35832                
L30112:
(W)     mov (1|M0)               r6.6<1>:hf    0.0:hf                             
(W)     mov (1|M0)               r2.7<1>:f     -0.0:f                               {Compacted}
(f0.0)  sel (8|M0)               acc0.0<1>:d   r6.6<0;1,0>:w     8388608:d               {F@2}
(W)     mov (2|M0)               r2.4<1>:d     0:w                              
        or (8|M0)                r66.0<1>:d    acc0.0<1;1,0>:d   r57.0<1;1,0>:d  
(W)     mov (1|M0)               r6.3<1>:d     0:w                              
        shl (8|M0)               r37.0<1>:d    r66.0<1;1,0>:d    23:w               {Compacted,I@2}
        shr (8|M0)               r42.0<1>:ud   r66.0<1;1,0>:ud   9:w              
L30224:
(W)     shl (1|M0)               r6.5<1>:d     r2.7<0;1,0>:d     31:w               {F@1}
(W)     shr (1|M0)               r6.4<1>:ud    r6.3<0;1,0>:ud    1:w               {I@4}
(W)     cmp (8|M0)    (gt)f0.1   null<1>:ud    r2.4<0;1,0>:ud    0x3E:uw             
(W)     or (1|M0)                r6.3<1>:d     r6.4<0;1,0>:d     r6.5<0;1,0>:d    {I@2}
        bfn.0xE0 (8|M0)          r101.0<1>:ud  r6.4<0;0>:ud      r6.5<0;0>:ud      r37.0<1>:ud      // (s0|s1)&s2
(W)     shr (1|M0)               r2.6<1>:ud    r2.7<0;1,0>:ud    1:w              
(W&f0.1) cmp (8|M0)   (eq)f0.1   null<1>:d     r2.5<0;1,0>:d     0:w              
        cmp (8|M0)    (eq)f0.0   null<1>:d     r101.0<1;1,0>:d   r6.3<0;1,0>:d    {I@3}
        and (8|M0)               r100.0<1>:d   r2.6<0;1,0>:d     r42.0<1;1,0>:d   {Compacted,I@3}
(W)     mov (1|M0)               r6.8<1>:hf    0x1:hf                             
(W&~f0.1) cmp (8|M0)  (gt)f0.1   null<1>:ud    r2.5<0;1,0>:ud    0x0:uw             
(f0.0)  cmp (8|M0)    (eq)f0.0   null<1>:d     r100.0<1;1,0>:d   r2.6<0;1,0>:d    {I@2}
(W)     addc (1|M0)              r25.0<1>:ud   r2.4<0;1,0>:ud    0x1:ud              {AccWrEn}
        mov (8|M0)               r52.0<1>:d    r2.4<0;1,0>:d                   
(f0.1)  sel (8|M0)               r24.0<1>:uw   r6.8<0;1,0>:uw    0x0:uw              {F@1}
(f0.0)  sel (8|M0)               r2.0<1>:uw    r6.8<0;1,0>:uw    0x0:uw             
(W)     mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        or (8|M0)     (ne)f0.0   null<1>:uw    r24.0<1;1,0>:uw   r2.0<1;1,0>:uw   {I@2}
(W)     add (1|M0)               r6.6<1>:ud    r7.0<0;1,0>:ud    r2.5<0;1,0>:ud   {I@2}
        mov (8|M0)               r56.0<1>:d    r2.5<0;1,0>:d                   
        mov (8|M0)               r87.0<1>:f    r25.0<0;1,0>:f                   {Compacted}
        mov (8|M0)               r3.0<1>:d     r6.6<0;1,0>:d                    {I@2}
(f0.0)  goto (8|M0)                          L30632                  L30632                
L30568:
(W)     mov (1|M0)               r2.7<1>:d     r2.6<0;1,0>:d                   
(W)     mov (1|M0)               r2.4<1>:d     r25.0<0;1,0>:d                  
(W)     mov (1|M0)               r2.5<1>:d     r6.6<0;1,0>:d                   
(W)     jmpi                                 L30224                                
L30632:
        join (8|M0)                          L35832                                
L30648:
(W)     mov (1|M0)               r6.3<1>:f     8.68805e-44:f                              
(W)     mov (1|M0)               r7.0<1>:hf    0.0:hf                             
        subb (8|M0)              r105.0<1>:ud  r6.3<0;1,0>:ud    r52.0<1;1,0>:ud  {AccWrEn,Compacted,F@2}
        add3 (8|M0)              r124.0<1>:d   r126.0<1;0>:d     r105.0<1;0>:d     -173:w               {I@1}
        add3 (8|M0)              r36.0<1>:ud   -acc0.0<1;0>:ud   r7.0<0;0>:uw      -r56.0<1>:ud     {F@1}
        cmp (8|M0)    (gt)f0.1   null<1>:d     r124.0<1;1,0>:d   127:w               {I@2}
        add3 (8|M0)              r122.0<1>:d   r41.0<1;0>:d      r43.0<1;0>:d      r105.0<1>:d     
(f0.1)  goto (8|M0)                          L35760                  L35760                
L30768:
        cmp (8|M0)    (gt)f0.0   null<1>:d     r124.0<1;1,0>:d   -127:w              
(f0.0)  goto (8|M0)                          L33328                  L33328                
L30800:
        cmp (8|M0)    (lt)f1.1   null<1>:ud    r124.0<1;1,0>:ud  0xFFFFFF6B:ud             
(f1.1)  goto (8|M0)                          L32808                  L32808                
L30832:
(W)     mov (1|M0)               r6.3<1>:f     8.82818e-44:f                              
        add3 (8|M0)              r121.0<1>:d   r126.0<1;0>:d     r105.0<1;0>:d     -23:w              
        subb (8|M0)              r35.0<1>:ud   r6.3<0;1,0>:ud    r52.0<1;1,0>:ud  {AccWrEn,Compacted,F@1}
(W)     mov (1|M0)               r7.0<1>:hf    0.0:hf                              {I@7}
        cmp (8|M0)    (gt)f1.0   null<1>:ud    r35.0<1;1,0>:ud   r121.0<1;1,0>:ud {I@1}
        add3 (8|M0)              r67.0<1>:ud   -acc0.0<1;0>:ud   r7.0<0;0>:uw      -r56.0<1>:ud     {F@1}
(f1.0)  cmp (8|M0)    (eq)f1.0   null<1>:d     r67.0<1;1,0>:d    0:w               {I@1}
(~f1.0) cmp (8|M0)    (gt)f1.0   null<1>:ud    r67.0<1;1,0>:ud   0x0:uw             
(f1.0)  goto (8|M0)                          L31032                  L31032                
L30968:
        add3 (8|M0)              acc0.0<1>:d   r122.0<1;0>:d     -r35.0<1;0>:d     -23:w              
        mov (8|M0)               r81.0<1>:d    0:w                              
        shl (8|M0)               r82.0<1>:d    r37.0<1;1,0>:d    acc0.0<1;1,0>:d 
        goto (8|M0)                          L31032                  L32744                
L31032:
        join (8|M0)                          L32744                                
L31048:
        add3 (8|M0)              r38.0<1>:d    r35.0<1;0>:d      -r122.0<1;0>:d    23:w              
        cmp (8|M0)    (lt)f1.0   null<1>:d     r38.0<1;1,0>:d    2:w               {I@1}
(f1.0)  goto (8|M0)                          L31200                  L31200                
L31096:
        cmp (8|M0)    (eq)f0.1   null<1>:d     r38.0<1;1,0>:d    2:w              
(~f0.1) goto (8|M0)                          L31200                  L31296                
L31128:
        shr (8|M0)               r43.0<1>:ud   r37.0<1;1,0>:ud   1:w              
        mov (8|M0)               r116.0<1>:d   0:w                              
        mov (8|M0)               r32.0<1>:d    0:w                              
        mov (8|M0)               r98.0<1>:f    r43.0<1;1,0>:f                   {Compacted,I@3}
        goto (8|M0)                          L31200                  L32176                
L31200:
        join (8|M0)                          L31296                                
L31216:
        cmp (8|M0)    (eq)f0.0   null<1>:d     r38.0<1;1,0>:d    1:w               {Compacted}
(~f0.0) goto (8|M0)                          L31296                  L31296                
L31240:
        mov (8|M0)               r116.0<1>:d   0:w                              
        mov (8|M0)               r32.0<1>:d    0:w                              
        mov (8|M0)               r98.0<1>:f    r37.0<1;1,0>:f                   {Compacted}
        goto (8|M0)                          L31296                  L32176                
L31296:
        join (8|M0)                          L32176                                
L31312:
        add3 (8|M0)              acc0.0<1>:d   r35.0<1;0>:d      -r121.0<1;0>:d    -1:w              
        and (8|M0)    (ne)f1.1   r73.0<1>:d    acc0.0<1;1,0>:d   63:w              
(f1.1)  goto (8|M0)                          L31392                  L31392                
L31360:
        mov (8|M0)               r26.0<1>:d    r37.0<1;1,0>:d                  
        goto (8|M0)                          L31392                  L31528                
L31392:
        join (8|M0)                          L31528                                
L31408:
        cmp (8|M0)    (lt)f1.0   null<1>:ud    r73.0<1;1,0>:ud   0x20:uw              {I@5}
(f1.0)  add (8|M0)               acc0.0<1>:d   -r73.0<1;1,0>:d   32:w              
(~f1.0) add (8|M0)               acc2.0<1>:d   r73.0<1;1,0>:d    -32:w              
(f1.0)  shr (8|M0)               r116.0<1>:ud  r37.0<1;1,0>:ud   r73.0<1;1,0>:d  
(f1.0)  shl (8|M0)               r127.0<1>:d   r42.0<1;1,0>:d    acc0.0<1;1,0>:d 
(~f1.0) shr (8|M0)               r43.0<1>:ud   r42.0<1;1,0>:ud   acc2.0<1;1,0>:d  {F@2}
(f1.0)  or (8|M0)                r43.0<1>:d    r116.0<1;1,0>:d   r127.0<1;1,0>:d  {I@2}
        mov (8|M0)               r26.0<1>:f    r43.0<1;1,0>:f                   {Compacted,I@1}
L31528:
        join (8|M0)                          L32176                                
L31544:
        add3 (8|M0)              r102.0<1>:d   r35.0<1;0>:d      -r121.0<1;0>:d    -2:w              
        and (8|M0)    (ne)f0.1   r72.0<1>:d    r102.0<1;1,0>:d   63:w               {I@1}
(f0.1)  goto (8|M0)                          L31624                  L31624                
L31592:
        mov (8|M0)               r43.0<1>:d    r37.0<1;1,0>:d                   {F@1}
        goto (8|M0)                          L31624                  L31752                
L31624:
        join (8|M0)                          L31752                                
L31640:
        cmp (8|M0)    (lt)f0.0   null<1>:ud    r72.0<1;1,0>:ud   0x20:uw              {I@5}
(f0.0)  add (8|M0)               acc0.0<1>:d   -r72.0<1;1,0>:d   32:w              
(~f0.0) add (8|M0)               acc2.0<1>:d   r72.0<1;1,0>:d    -32:w              
(f0.0)  shr (8|M0)               r114.0<1>:ud  r37.0<1;1,0>:ud   r72.0<1;1,0>:d  
(f0.0)  shl (8|M0)               r126.0<1>:d   r42.0<1;1,0>:d    acc0.0<1;1,0>:d 
(~f0.0) shr (8|M0)               r43.0<1>:ud   r42.0<1;1,0>:ud   acc2.0<1;1,0>:d 
(f0.0)  or (8|M0)                r43.0<1>:d    r114.0<1;1,0>:d   r126.0<1;1,0>:d  {I@2}
L31752:
        join (8|M0)                          L32176                                
L31768:
        and (8|M0)    (ne)f1.1   r125.0<1>:d   r102.0<1;1,0>:d   63:w              
        and (8|M0)               r32.0<1>:d    r43.0<1;1,0>:d    1:w               {Compacted,I@3}
(f1.1)  goto (8|M0)                          L31856                  L31856                
L31808:
        mov (8|M0)               r40.0<1>:d    -1:w                              
        mov (8|M0)               r56.0<1>:d    -1:w                              
        goto (8|M0)                          L31856                  L32040                
L31856:
        join (8|M0)                          L32040                                
L31872:
        cmp (8|M0)    (lt)f1.0   null<1>:ud    r125.0<1;1,0>:ud  0x20:uw              {I@7}
(f1.0)  goto (8|M0)                          L31976                  L31976                
L31904:
        add (8|M0)               acc0.0<1>:d   r125.0<1;1,0>:d   -32:w               {Compacted}
(W)     mov (1|M0)               r6.6<1>:hf    -qnan(0x1FF):hf                             
        mov (8|M0)               r40.0<1>:d    0:w                              
        shl (8|M0)               r56.0<1>:d    r6.6<0;1,0>:w     acc0.0<1;1,0>:d  {F@1}
        goto (8|M0)                          L31976                  L32040                
L31976:
        join (8|M0)                          L32040                                
L31992:
(W)     mov (1|M0)               r6.6<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (8|M0)               r56.0<1>:d    -1:w                              
        shl (8|M0)               r40.0<1>:d    r6.6<0;1,0>:w     r125.0<1;1,0>:d  {F@1}
L32040:
        join (8|M0)                          L32176                                
L32056:
        bfn.0x60 (8|M0)          r113.0<1>:ud  r40.0<1;0>:ud     r5.7<0;0>:ud      r37.0<1>:ud      {I@2} // (s0^s1)&s2
        bfn.0x60 (8|M0)          r112.0<1>:ud  r56.0<1;0>:ud     r5.7<0;0>:ud      r42.0<1>:ud      // (s0^s1)&s2
        cmp (8|M0)    (ne)f1.0   null<1>:d     r113.0<1;1,0>:d   0:w               {I@2}
(W)     mov (1|M0)               r6.6<1>:hf    -qnan(0x1FF):hf                             
        mov (8|M0)               r98.0<1>:f    r26.0<1;1,0>:f                   {Compacted}
(~f1.0) cmp (8|M0)    (ne)f1.0   null<1>:d     r112.0<1;1,0>:d   0:w               {I@2}
(f1.0)  sel (8|M0)               acc0.0<1>:d   r6.6<0;1,0>:w     0:w               {F@2}
        mov (8|M0)               r116.0<1>:d   -acc0.0<1;1,0>:d                
L32176:
        join (8|M0)                          L32744                                
L32192:
        and (8|M0)    (ne)f0.1   r71.0<1>:d    r38.0<1;1,0>:d    63:w              
(f0.1)  goto (8|M0)                          L32256                  L32256                
L32224:
        mov (8|M0)               r43.0<1>:d    r37.0<1;1,0>:d                  
        goto (8|M0)                          L32256                  L32384                
L32256:
        join (8|M0)                          L32384                                
L32272:
        cmp (8|M0)    (lt)f0.0   null<1>:ud    r71.0<1;1,0>:ud   0x20:uw              {I@5}
(f0.0)  add (8|M0)               acc0.0<1>:d   -r71.0<1;1,0>:d   32:w              
(~f0.0) add (8|M0)               acc2.0<1>:d   r71.0<1;1,0>:d    -32:w              
(f0.0)  shr (8|M0)               r109.0<1>:ud  r37.0<1;1,0>:ud   r71.0<1;1,0>:d  
(f0.0)  shl (8|M0)               r124.0<1>:d   r42.0<1;1,0>:d    acc0.0<1;1,0>:d 
(~f0.0) shr (8|M0)               r43.0<1>:ud   r42.0<1;1,0>:ud   acc2.0<1;1,0>:d 
(f0.0)  or (8|M0)                r43.0<1>:d    r109.0<1;1,0>:d   r124.0<1;1,0>:d  {I@2}
L32384:
        join (8|M0)                          L32744                                
L32400:
        shl (8|M0)               r76.0<1>:d    r98.0<1;1,0>:d    2:w               {Compacted,F@1}
        shl (8|M0)               r108.0<1>:d   r32.0<1;1,0>:d    1:w               {Compacted}
        and (8|M0)               r76.0<1>:d    r76.0<1;1,0>:d    4:w               {Compacted,I@2}
        bfn.0xFE (8|M0)          r55.0<1>:ud   r76.0<1;0>:ud     r108.0<1;0>:ud    r116.0<1>:ud     {I@1} // s0|s1|s2
        cmp (8|M0)    (eq)f1.1   null<1>:d     r55.0<1;1,0>:d    0:w               {I@1}
(~f1.1) goto (8|M0)                          L32504                  L32504                
L32472:
        mov (8|M0)               r60.0<1>:d    0:w                              
        goto (8|M0)                          L32504                  L32664                
L32504:
        join (8|M0)                          L32664                                
L32520:
        cmp (8|M0)    (gt)f1.0   null<1>:ud    r55.0<1;1,0>:ud   0x4:uw             
(~f1.0) goto (8|M0)                          L32584                  L32584                
L32552:
        mov (8|M0)               r60.0<1>:d    1:w                              
        goto (8|M0)                          L32584                  L32664                
L32584:
        join (8|M0)                          L32664                                
L32600:
        and (8|M0)    (ne)f0.1   null<1>:d     r43.0<1;1,0>:d    1:w              
(W)     mov (1|M0)               r6.6<1>:hf    0x1:hf                             
(f0.1)  cmp (8|M0)    (eq)f0.1   null<1>:d     r55.0<1;1,0>:d    4:w              
(f0.1)  sel (8|M0)               r60.0<1>:d    r6.6<0;1,0>:w     0:w               {F@1}
L32664:
        join (8|M0)                          L32744                                
L32680:
        add (8|M0)               r45.0<1>:d    r60.0<1;1,0>:d    r43.0<1;1,0>:d   {Compacted,I@2}
(W)     mov (1|M0)               r6.3<1>:f     0x800000:f                               {Compacted}
        cmp (8|M0)    (gt)f1.1   null<1>:ud    r45.0<1;1,0>:ud   0x7FFFFF:ud              {I@1}
(~f1.1) sel (8|M0)               r82.0<1>:d    r45.0<1;1,0>:d    0:w              
(f1.1)  sel (8|M0)               r81.0<1>:d    r6.3<0;1,0>:d     0:w               {F@1}
L32744:
        join (8|M0)                          L32808                                
L32760:
        and (8|M0)               r107.0<1>:d   r34.0<1;1,0>:d    -2147483648:d              
        bfn.0xFE (8|M0)          r67.0<1>:ud   r107.0<1;0>:ud    r81.0<1;0>:ud     r82.0<1>:ud      {I@1} // s0|s1|s2
        goto (8|M0)                          L32808                  L36000                
L32808:
        join (8|M0)                          L33328                                
L32824:
        and (8|M0)    (ne)f0.1   r92.0<1>:d    r105.0<1;1,0>:d   63:w              
(f0.1)  goto (8|M0)                          L32904                  L32904                
L32856:
        mov (8|M0)               r108.0<1>:d   -1:w                              
        mov (8|M0)               r123.0<1>:d   -1:w                              
        goto (8|M0)                          L32904                  L33088                
L32904:
        join (8|M0)                          L33088                                
L32920:
        cmp (8|M0)    (lt)f0.0   null<1>:ud    r92.0<1;1,0>:ud   0x20:uw              {I@6}
(f0.0)  goto (8|M0)                          L33024                  L33024                
L32952:
        add (8|M0)               acc0.0<1>:d   r92.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r6.6<1>:hf    -qnan(0x1FF):hf                             
        mov (8|M0)               r108.0<1>:d   0:w                              
        shl (8|M0)               r123.0<1>:d   r6.6<0;1,0>:w     acc0.0<1;1,0>:d  {F@1}
        goto (8|M0)                          L33024                  L33088                
L33024:
        join (8|M0)                          L33088                                
L33040:
(W)     mov (1|M0)               r6.6<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (8|M0)               r123.0<1>:d   -1:w                              
        shl (8|M0)               r108.0<1>:d   r6.6<0;1,0>:w     r92.0<1;1,0>:d   {F@1}
L33088:
        join (8|M0)                          L33328                                
L33104:
        bfn.0x60 (8|M0)          r106.0<1>:ud  r108.0<1;0>:ud    r5.7<0;0>:ud      r37.0<1>:ud      {I@2} // (s0^s1)&s2
        bfn.0x60 (8|M0)          r105.0<1>:ud  r123.0<1;0>:ud    r5.7<0;0>:ud      r42.0<1>:ud      // (s0^s1)&s2
        cmp (8|M0)    (ne)f0.0   null<1>:d     r106.0<1;1,0>:d   0:w               {I@2}
        cmp (8|M0)    (gt)f1.1   null<1>:d     r34.0<1;1,0>:d    -1:w              
(~f0.0) cmp (8|M0)    (ne)f0.0   null<1>:d     r105.0<1;1,0>:d   0:w               {I@3}
(f0.0)  cmp (8|M0)    (eq)f0.0   null<1>:d     r124.0<1;1,0>:d   -150:w              
(f1.1)  goto (8|M0)                          L33264                  L33264                
L33216:
(W)     mov (1|M0)               r6.3<1>:ud    0x80000001:ud                             
(f0.0)  sel (8|M0)               r67.0<1>:f    r6.3<0;1,0>:f     -0.0:f               {I@1}
        goto (8|M0)                          L33264                  L36000                
L33264:
        join (8|M0)                          L33328                                
L33280:
(W)     mov (1|M0)               r6.3<1>:ud    0x1:ud                              {F@1}
(f0.0)  sel (8|M0)               r67.0<1>:f    r6.3<0;1,0>:f     0.0:f               {I@1}
        goto (8|M0)                          L33328                  L36000                
L33328:
        join (8|M0)                          L35760                                
L33344:
        cmp (8|M0)    (lt)f0.0   null<1>:ud    r105.0<1;1,0>:ud  0x18:uw              {F@1}
        add3 (8|M0)              r45.0<1>:d    r126.0<1;0>:d     r105.0<1;0>:d     -46:w              
(f0.0)  cmp (8|M0)    (eq)f0.0   null<1>:d     r36.0<1;1,0>:d    0:w              
(f0.0)  goto (8|M0)                          L35440                  L35440                
L33408:
        shl (8|M0)               r108.0<1>:d   r87.0<1;1,0>:d    1:w               {Compacted}
        shr (8|M0)               r107.0<1>:ud  r87.0<1;1,0>:ud   31:w              
        shl (8|M0)               r96.0<1>:d    r3.0<1;1,0>:d     1:w               {Compacted}
        cmp (8|M0)    (lt)f0.1   null<1>:ud    r108.0<1;1,0>:ud  0x4E:uw              {I@3}
        or (8|M0)                r96.0<1>:d    r96.0<1;1,0>:d    r107.0<1;1,0>:d  {Compacted,I@2}
(f0.1)  cmp (8|M0)    (eq)f0.1   null<1>:d     r96.0<1;1,0>:d    0:w               {I@1}
(~f0.1) cmp (8|M0)    (lt)f0.1   null<1>:d     r96.0<1;1,0>:d    0:w              
(f0.1)  goto (8|M0)                          L33640                  L33640                
L33512:
        cmp (8|M0)    (eq)f1.1   null<1>:d     r87.0<1;1,0>:d    39:w              
(f1.1)  cmp (8|M0)    (eq)f1.1   null<1>:d     r3.0<1;1,0>:d     0:w              
(~f1.1) goto (8|M0)                          L33640                  L33704                
L33560:
        shr (8|M0)               r43.0<1>:ud   r37.0<1;1,0>:ud   1:w              
        mov (8|M0)               r3.0<1>:d     0:w                              
        mov (8|M0)               r38.0<1>:d    0:w                              
        mov (8|M0)               r115.0<1>:f   r43.0<1;1,0>:f                   {Compacted,I@3}
        mov (8|M0)               r43.0<1>:f    r37.0<1;1,0>:f                   {Compacted}
        goto (8|M0)                          L33640                  L34904                
L33640:
        join (8|M0)                          L33704                                
L33656:
        cmp (8|M0)    (eq)f1.0   null<1>:d     r87.0<1;1,0>:d    38:w              
(f1.0)  cmp (8|M0)    (eq)f1.0   null<1>:d     r3.0<1;1,0>:d     0:w               {I@5}
(f1.0)  goto (8|M0)                          L33704                  L34816                
L33704:
        join (8|M0)                          L34816                                
L33720:
        add (8|M0)               acc0.0<1>:d   -r87.0<1;1,0>:d   39:w               {Compacted}
        add (8|M0)               r46.0<1>:d    -r87.0<1;1,0>:d   40:w               {Compacted}
        and (8|M0)    (ne)f1.0   r88.0<1>:d    acc0.0<1;1,0>:d   63:w              
(f1.0)  goto (8|M0)                          L33800                  L33800                
L33768:
        mov (8|M0)               r35.0<1>:d    r37.0<1;1,0>:d                  
        goto (8|M0)                          L33800                  L33936                
L33800:
        join (8|M0)                          L33936                                
L33816:
        cmp (8|M0)    (lt)f0.1   null<1>:ud    r88.0<1;1,0>:ud   0x20:uw              {I@5}
(f0.1)  add (8|M0)               acc0.0<1>:d   -r88.0<1;1,0>:d   32:w              
(~f0.1) add (8|M0)               acc2.0<1>:d   r88.0<1;1,0>:d    -32:w              
(f0.1)  shr (8|M0)               r102.0<1>:ud  r37.0<1;1,0>:ud   r88.0<1;1,0>:d  
(f0.1)  shl (8|M0)               r55.0<1>:d    r42.0<1;1,0>:d    acc0.0<1;1,0>:d 
(~f0.1) shr (8|M0)               r43.0<1>:ud   r42.0<1;1,0>:ud   acc2.0<1;1,0>:d  {F@1}
(f0.1)  or (8|M0)                r43.0<1>:d    r102.0<1;1,0>:d   r55.0<1;1,0>:d   {I@2}
        mov (8|M0)               r35.0<1>:f    r43.0<1;1,0>:f                   {Compacted,I@1}
L33936:
        join (8|M0)                          L34816                                
L33952:
        add (8|M0)               r114.0<1>:d   -r87.0<1;1,0>:d   38:w               {Compacted}
        and (8|M0)    (ne)f0.0   r95.0<1>:d    r114.0<1;1,0>:d   63:w               {I@1}
(f0.0)  goto (8|M0)                          L34024                  L34024                
L33992:
        mov (8|M0)               r43.0<1>:d    r37.0<1;1,0>:d                   {F@1}
        goto (8|M0)                          L34024                  L34152                
L34024:
        join (8|M0)                          L34152                                
L34040:
        cmp (8|M0)    (lt)f1.1   null<1>:ud    r95.0<1;1,0>:ud   0x20:uw              {I@5}
(f1.1)  add (8|M0)               acc0.0<1>:d   -r95.0<1;1,0>:d   32:w              
(~f1.1) add (8|M0)               acc2.0<1>:d   r95.0<1;1,0>:d    -32:w              
(f1.1)  shr (8|M0)               r100.0<1>:ud  r37.0<1;1,0>:ud   r95.0<1;1,0>:d  
(f1.1)  shl (8|M0)               r70.0<1>:d    r42.0<1;1,0>:d    acc0.0<1;1,0>:d 
(~f1.1) shr (8|M0)               r43.0<1>:ud   r42.0<1;1,0>:ud   acc2.0<1;1,0>:d 
(f1.1)  or (8|M0)                r43.0<1>:d    r100.0<1;1,0>:d   r70.0<1;1,0>:d   {I@2}
L34152:
        join (8|M0)                          L34816                                
L34168:
        and (8|M0)    (ne)f1.0   r69.0<1>:d    r114.0<1;1,0>:d   63:w              
        and (8|M0)               r38.0<1>:d    r43.0<1;1,0>:d    1:w               {Compacted,I@3}
(f1.0)  goto (8|M0)                          L34256                  L34256                
L34208:
        mov (8|M0)               r83.0<1>:d    -1:w                              
        mov (8|M0)               r92.0<1>:d    -1:w                              
        goto (8|M0)                          L34256                  L34440                
L34256:
        join (8|M0)                          L34440                                
L34272:
        cmp (8|M0)    (lt)f0.1   null<1>:ud    r69.0<1;1,0>:ud   0x20:uw              {I@7}
(f0.1)  goto (8|M0)                          L34376                  L34376                
L34304:
        add (8|M0)               acc0.0<1>:d   r69.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r6.6<1>:hf    -qnan(0x1FF):hf                             
        mov (8|M0)               r83.0<1>:d    0:w                              
        shl (8|M0)               r92.0<1>:d    r6.6<0;1,0>:w     acc0.0<1;1,0>:d  {F@1}
        goto (8|M0)                          L34376                  L34440                
L34376:
        join (8|M0)                          L34440                                
L34392:
(W)     mov (1|M0)               r6.6<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (8|M0)               r92.0<1>:d    -1:w                              
        shl (8|M0)               r83.0<1>:d    r6.6<0;1,0>:w     r69.0<1;1,0>:d   {F@1}
L34440:
        join (8|M0)                          L34816                                
L34456:
        bfn.0x60 (8|M0)          r99.0<1>:ud   r83.0<1;0>:ud     r5.7<0;0>:ud      r37.0<1>:ud      {I@2} // (s0^s1)&s2
        bfn.0x60 (8|M0)          r98.0<1>:ud   r92.0<1;0>:ud     r5.7<0;0>:ud      r42.0<1>:ud      // (s0^s1)&s2
        cmp (8|M0)    (ne)f0.1   null<1>:d     r99.0<1;1,0>:d    0:w               {I@2}
(W)     mov (1|M0)               r6.6<1>:hf    -qnan(0x1FF):hf                             
        and (8|M0)    (ne)f0.0   r94.0<1>:d    r46.0<1;1,0>:d    63:w              
(~f0.1) cmp (8|M0)    (ne)f0.1   null<1>:d     r98.0<1;1,0>:d    0:w               {I@3}
(f0.1)  sel (8|M0)               acc0.0<1>:d   r6.6<0;1,0>:w     0:w               {F@1}
        mov (8|M0)               r3.0<1>:d     -acc0.0<1;1,0>:d                
(f0.0)  goto (8|M0)                          L34632                  L34632                
L34600:
        mov (8|M0)               r43.0<1>:d    r37.0<1;1,0>:d                  
        goto (8|M0)                          L34632                  L34760                
L34632:
        join (8|M0)                          L34760                                
L34648:
        cmp (8|M0)    (lt)f1.1   null<1>:ud    r94.0<1;1,0>:ud   0x20:uw              {I@7}
(f1.1)  add (8|M0)               acc0.0<1>:d   -r94.0<1;1,0>:d   32:w              
(~f1.1) add (8|M0)               acc2.0<1>:d   r94.0<1;1,0>:d    -32:w              
(f1.1)  shr (8|M0)               r95.0<1>:ud   r37.0<1;1,0>:ud   r94.0<1;1,0>:d  
(f1.1)  shl (8|M0)               r68.0<1>:d    r42.0<1;1,0>:d    acc0.0<1;1,0>:d 
(~f1.1) shr (8|M0)               r43.0<1>:ud   r42.0<1;1,0>:ud   acc2.0<1;1,0>:d 
(f1.1)  or (8|M0)                r43.0<1>:d    r95.0<1;1,0>:d    r68.0<1;1,0>:d   {I@2}
L34760:
        join (8|M0)                          L34816                                
L34776:
        mov (8|M0)               r115.0<1>:f   r43.0<1;1,0>:f                   {Compacted,I@2}
        mov (8|M0)               r43.0<1>:d    r35.0<1;1,0>:d                   {F@1}
        goto (8|M0)                          L34816                  L34904                
L34816:
        join (8|M0)                          L34904                                
L34832:
        shr (8|M0)               r43.0<1>:ud   r37.0<1;1,0>:ud   2:w              
        mov (8|M0)               r3.0<1>:d     0:w                              
        mov (8|M0)               r38.0<1>:d    0:w                              
        mov (8|M0)               r115.0<1>:f   r43.0<1;1,0>:f                   {Compacted,I@3}
        shr (8|M0)               r43.0<1>:ud   r37.0<1;1,0>:ud   1:w               {F@1}
L34904:
        join (8|M0)                          L35440                                
L34920:
        shl (8|M0)               r39.0<1>:d    r43.0<1;1,0>:d    2:w               {Compacted,I@2}
        shl (8|M0)               r94.0<1>:d    r38.0<1;1,0>:d    1:w               {Compacted}
        and (8|M0)               r39.0<1>:d    r39.0<1;1,0>:d    4:w               {Compacted,I@2}
        and (8|M0)               r122.0<1>:d   r115.0<1;1,0>:d   8388607:d              
        bfn.0xFE (8|M0)          r91.0<1>:ud   r39.0<1;0>:ud     r94.0<1;0>:ud     r3.0<1>:ud       {I@2} // s0|s1|s2
        cmp (8|M0)    (eq)f1.0   null<1>:d     r91.0<1;1,0>:d    0:w               {I@1}
(~f1.0) goto (8|M0)                          L35040                  L35040                
L35008:
        mov (8|M0)               r90.0<1>:d    0:w                              
        goto (8|M0)                          L35040                  L35200                
L35040:
        join (8|M0)                          L35200                                
L35056:
        cmp (8|M0)    (gt)f0.1   null<1>:ud    r91.0<1;1,0>:ud   0x4:uw             
(~f0.1) goto (8|M0)                          L35120                  L35120                
L35088:
        mov (8|M0)               r90.0<1>:d    1:w                              
        goto (8|M0)                          L35120                  L35200                
L35120:
        join (8|M0)                          L35200                                
L35136:
        and (8|M0)    (ne)f0.0   null<1>:d     r115.0<1;1,0>:d   1:w              
(W)     mov (1|M0)               r6.6<1>:hf    0x1:hf                             
(f0.0)  cmp (8|M0)    (eq)f0.0   null<1>:d     r91.0<1;1,0>:d    4:w              
(f0.0)  sel (8|M0)               r90.0<1>:d    r6.6<0;1,0>:w     0:w               {F@1}
L35200:
        join (8|M0)                          L35440                                
L35216:
        add (8|M0)               r66.0<1>:d    r122.0<1;1,0>:d   r90.0<1;1,0>:d   {Compacted,I@2}
        add3 (8|M0)              r58.0<1>:d    r126.0<1;0>:d     r105.0<1;0>:d     -45:w              
        cmp (8|M0)    (gt)f0.1   null<1>:ud    r66.0<1;1,0>:ud   0x7FFFFF:ud              {I@2}
(f0.1)  sel (8|M0)               r51.0<1>:d    r58.0<1;1,0>:d    r45.0<1;1,0>:d   {I@2}
        cmp (8|M0)    (eq)f0.0   null<1>:d     r51.0<1;1,0>:d    255:w               {Compacted,I@1}
(f0.0)  goto (8|M0)                          L35368                  L35368                
L35296:
(~f0.1) sel (8|M0)               r69.0<1>:d    r66.0<1;1,0>:d    0:w              
        and (8|M0)               r57.0<1>:d    r34.0<1;1,0>:d    -2147483648:d              
        shl (8|M0)               r93.0<1>:d    r51.0<1;1,0>:d    23:w               {Compacted}
        bfn.0xFE (8|M0)          r67.0<1>:ud   r57.0<1;0>:ud     r93.0<1;0>:ud     r69.0<1>:ud      {I@1} // s0|s1|s2
        goto (8|M0)                          L35368                  L36000                
L35368:
        join (8|M0)                          L35440                                
L35384:
        cmp (8|M0)    (gt)f1.0   null<1>:d     r34.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r6.3<1>:f     inf:f                               {Compacted}
(f1.0)  sel (8|M0)               r67.0<1>:f    r6.3<0;1,0>:f     -inf:f               {A@1}
        goto (8|M0)                          L35440                  L36000                
L35440:
        join (8|M0)                          L35760                                
L35456:
        and (8|M0)    (ne)f1.1   r61.0<1>:d    r105.0<1;1,0>:d   63:w              
(f1.1)  goto (8|M0)                          L35520                  L35520                
L35488:
        mov (8|M0)               r75.0<1>:d    -1:w                              
        goto (8|M0)                          L35520                  L35648                
L35520:
        join (8|M0)                          L35648                                
L35536:
        cmp (8|M0)    (lt)f1.0   null<1>:ud    r61.0<1;1,0>:ud   0x20:uw              {A@1}
(f1.0)  goto (8|M0)                          L35600                  L35600                
L35568:
        mov (8|M0)               r75.0<1>:d    0:w                              
        goto (8|M0)                          L35600                  L35648                
L35600:
        join (8|M0)                          L35648                                
L35616:
(W)     mov (1|M0)               r6.6<1>:hf    -qnan(0x1FF):hf                             
        shl (8|M0)               r75.0<1>:d    r6.6<0;1,0>:w     r61.0<1;1,0>:d   {F@1}
L35648:
        join (8|M0)                          L35760                                
L35664:
        bfn.0x60 (8|M0)          r89.0<1>:ud   r75.0<1;0>:ud     r5.7<0;0>:ud      r37.0<1>:ud      {I@2} // (s0^s1)&s2
        add (8|M0)               acc0.0<1>:d   -r105.0<1;1,0>:d  23:w               {Compacted}
        and (8|M0)               r56.0<1>:d    r34.0<1;1,0>:d    -2147483648:d              
        shl (8|M0)               r91.0<1>:d    r45.0<1;1,0>:d    23:w               {Compacted}
        shl (8|M0)               r89.0<1>:d    r89.0<1;1,0>:d    acc0.0<1;1,0>:d  {I@4}
        bfn.0xFE (8|M0)          r67.0<1>:ud   r56.0<1;0>:ud     r91.0<1;0>:ud     r89.0<1>:ud      {I@1} // s0|s1|s2
        goto (8|M0)                          L35760                  L36000                
L35760:
        join (8|M0)                          L35832                                
L35776:
        cmp (8|M0)    (gt)f0.1   null<1>:d     r34.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r6.3<1>:f     inf:f                               {Compacted}
(f0.1)  sel (8|M0)               r67.0<1>:f    r6.3<0;1,0>:f     -inf:f               {A@1}
        goto (8|M0)                          L35832                  L36000                
L35832:
        join (8|M0)                          L35896                                
L35848:
        cmp (8|M0)    (lt)f0.0   null<1>:d     r34.0<1;1,0>:d    0:w               {Compacted}
(W)     mov (1|M0)               r6.3<1>:f     -0.0:f                               {Compacted}
(f0.0)  sel (8|M0)               r67.0<1>:f    r6.3<0;1,0>:f     0.0:f               {F@1}
        goto (8|M0)                          L35896                  L36000                
L35896:
        join (8|M0)                          L35968                                
L35912:
        cmp (8|M0)    (gt)f1.1   null<1>:d     r34.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r6.3<1>:f     inf:f                               {Compacted}
(f1.1)  sel (8|M0)               r67.0<1>:f    r6.3<0;1,0>:f     -inf:f               {F@1}
        goto (8|M0)                          L35968                  L36000                
L35968:
        join (8|M0)                          L36000                                
L35984:
        bfn.0xF8 (8|M0)          r67.0<1>:ud   r34.0<1;0>:ud     r5.6<0;0>:ud      r5.3<0>:ud       {F@1} // s0&s1|s2
L36000:
        join (8|M0)                          L42384                                
L36016:
        rnde (8|M0)              r88.0<1>:f    r67.0<1;1,0>:f                   {Compacted,I@2}
        shr (8|M0)               r96.0<1>:ud   r88.0<1;1,0>:ud   23:w               {F@1}
        and (8|M0)    (ne)f1.1   r82.0<1>:d    r88.0<1;1,0>:d    8388607:d              
        and (8|M0)               r124.0<1>:d   r96.0<1;1,0>:d    255:w               {Compacted,I@2}
(f1.1)  cmp (8|M0)    (eq)f1.1   null<1>:d     r124.0<1;1,0>:d   255:w               {I@1}
(~f1.1) goto (8|M0)                          L36120                  L36120                
L36096:
        mov (8|M0)               r64.0<1>:f    qnan(0x0):f                               {Compacted}
        goto (8|M0)                          L36120                  L42336                
L36120:
        join (8|M0)                          L42336                                
L36136:
        cmp (8|M0)    (eq)f0.0   null<1>:d     r82.0<1;1,0>:d    0:w               {Compacted}
        add (8|M0)               r60.0<1>:d    r31.0<1;1,0>:d    -25165824:d              
        shr (8|M0)               r91.0<1>:ud   r60.0<1;1,0>:ud   23:w               {I@1}
(f0.0)  cmp (8|M0)    (eq)f0.0   null<1>:d     r124.0<1;1,0>:d   255:w              
        and (8|M0)               r46.0<1>:d    r91.0<1;1,0>:d    255:w               {Compacted,I@2}
        xor (8|M0)               r33.0<1>:d    r60.0<1;1,0>:d    r88.0<1;1,0>:d   {Compacted}
(~f0.0) cmp (8|M0)    (eq)f0.0   null<1>:d     r46.0<1;1,0>:d    255:w               {I@2}
(f0.0)  goto (8|M0)                          L42304                  L42304                
L36240:
        cmp (8|M0)    (eq)f1.0   null<1>:d     r46.0<1;1,0>:d    0:w              
        or (8|M0)                r90.0<1>:d    r124.0<1;1,0>:d   r82.0<1;1,0>:d   {Compacted}
(~f1.0) cmp (8|M0)    (eq)f1.0   null<1>:d     r90.0<1;1,0>:d    0:w               {I@1}
(~f1.0) goto (8|M0)                          L36320                  L36320                
L36296:
        mov (8|M0)               r64.0<1>:f    0.0:f                               {Compacted}
        goto (8|M0)                          L36320                  L42336                
L36320:
        join (8|M0)                          L42304                                
L36336:
        cmp (8|M0)    (eq)f1.0   null<1>:d     r124.0<1;1,0>:d   0:w              
        add (8|M0)               r41.0<1>:d    r124.0<1;1,0>:d   -127:w               {Compacted}
(f1.0)  mov (8|M0)               r41.0<1>:d    -126:w                              
        add (8|M0)               r127.0<1>:d   r46.0<1;1,0>:d    r41.0<1;1,0>:d   {Compacted,I@1}
        cmp (8|M0)    (gt)f0.1   null<1>:d     r127.0<1;1,0>:d   254:w               {I@1}
(f0.1)  goto (8|M0)                          L42232                  L42232                
L36416:
        or (8|M0)     (eq)f0.0   null<4>:b     r96.0<1;1,0>:d    r91.0<1;1,0>:d  
(f0.0)  goto (8|M0)                          L42168                  L42168                
L36448:
(W)     mov (1|M0)               r6.6<1>:hf    0.0:hf                             
(W)     mov (1|M0)               r3.4<1>:d     0:w                              
(f1.0)  sel (8|M0)               acc0.0<1>:d   r6.6<0;1,0>:w     8388608:d               {F@1}
(W)     mov (1|M0)               r2.7<1>:f     -0.0:f                               {Compacted}
        or (8|M0)                r61.0<1>:d    acc0.0<1;1,0>:d   r82.0<1;1,0>:d  
(W)     mov (2|M0)               r2.4<1>:d     0:w                              
        shl (8|M0)               r35.0<1>:d    r61.0<1;1,0>:d    23:w               {Compacted,I@2}
        shr (8|M0)               r40.0<1>:ud   r61.0<1;1,0>:ud   9:w              
L36560:
(W)     shl (1|M0)               r3.1<1>:d     r2.7<0;1,0>:d     31:w               {F@1}
(W)     shr (1|M0)               r3.0<1>:ud    r3.4<0;1,0>:ud    1:w              
(W)     cmp (8|M0)    (gt)f0.0   null<1>:ud    r2.4<0;1,0>:ud    0x3E:uw              {I@5}
(W)     or (1|M0)                r3.4<1>:d     r3.0<0;1,0>:d     r3.1<0;1,0>:d    {I@2}
        bfn.0xE0 (8|M0)          r95.0<1>:ud   r3.0<0;0>:ud      r3.1<0;0>:ud      r35.0<1>:ud      // (s0|s1)&s2
(W)     shr (1|M0)               r2.6<1>:ud    r2.7<0;1,0>:ud    1:w              
(W&f0.0) cmp (8|M0)   (eq)f0.0   null<1>:d     r2.5<0;1,0>:d     0:w              
        cmp (8|M0)    (eq)f1.1   null<1>:d     r95.0<1;1,0>:d    r3.4<0;1,0>:d    {I@3}
        and (8|M0)               r94.0<1>:d    r2.6<0;1,0>:d     r40.0<1;1,0>:d   {Compacted,I@3}
(W)     mov (1|M0)               r3.12<1>:hf   0x1:hf                             
(W&~f0.0) cmp (8|M0)  (gt)f0.0   null<1>:ud    r2.5<0;1,0>:ud    0x0:uw             
(f1.1)  cmp (8|M0)    (eq)f1.1   null<1>:d     r94.0<1;1,0>:d    r2.6<0;1,0>:d    {I@2}
(W)     addc (1|M0)              r24.0<1>:ud   r2.4<0;1,0>:ud    0x1:ud              {AccWrEn}
        mov (8|M0)               r48.0<1>:d    r2.4<0;1,0>:d                   
(f0.0)  sel (8|M0)               r3.0<1>:uw    r3.12<0;1,0>:uw   0x0:uw              {F@1}
(f1.1)  sel (8|M0)               r2.0<1>:uw    r3.12<0;1,0>:uw   0x0:uw             
(W)     mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        or (8|M0)     (ne)f1.1   null<1>:uw    r3.0<1;1,0>:uw    r2.0<1;1,0>:uw   {I@2}
(W)     add (1|M0)               r3.5<1>:ud    r7.0<0;1,0>:ud    r2.5<0;1,0>:ud   {I@2}
        mov (8|M0)               r54.0<1>:d    r2.5<0;1,0>:d                   
        mov (8|M0)               r85.0<1>:f    r24.0<0;1,0>:f                   {Compacted}
        mov (8|M0)               r125.0<1>:d   r3.5<0;1,0>:d                    {I@2}
(f1.1)  goto (8|M0)                          L36968                  L36968                
L36904:
(W)     mov (1|M0)               r2.7<1>:d     r2.6<0;1,0>:d                   
(W)     mov (1|M0)               r2.4<1>:d     r24.0<0;1,0>:d                  
(W)     mov (1|M0)               r2.5<1>:f     r3.5<0;1,0>:f                    {I@5}
(W)     jmpi                                 L36560                                
L36968:
        join (8|M0)                          L42168                                
L36984:
(W)     mov (1|M0)               r6.3<1>:f     8.68805e-44:f                              
(W)     mov (1|M0)               r7.0<1>:hf    0.0:hf                             
        subb (8|M0)              r104.0<1>:ud  r6.3<0;1,0>:ud    r48.0<1;1,0>:ud  {AccWrEn,Compacted,F@2}
        add3 (8|M0)              r122.0<1>:d   r127.0<1;0>:d     r104.0<1;0>:d     -173:w               {I@1}
        add3 (8|M0)              r34.0<1>:ud   -acc0.0<1;0>:ud   r7.0<0;0>:uw      -r54.0<1>:ud     {F@1}
        cmp (8|M0)    (gt)f1.1   null<1>:d     r122.0<1;1,0>:d   127:w               {I@2}
        add3 (8|M0)              r118.0<1>:d   r46.0<1;0>:d      r41.0<1;0>:d      r104.0<1>:d     
(f1.1)  goto (8|M0)                          L42096                  L42096                
L37104:
        cmp (8|M0)    (gt)f1.0   null<1>:d     r122.0<1;1,0>:d   -127:w              
(f1.0)  goto (8|M0)                          L39664                  L39664                
L37136:
        cmp (8|M0)    (lt)f0.1   null<1>:ud    r122.0<1;1,0>:ud  0xFFFFFF6B:ud             
(f0.1)  goto (8|M0)                          L39144                  L39144                
L37168:
(W)     mov (1|M0)               r6.3<1>:f     8.82818e-44:f                              
        add3 (8|M0)              r115.0<1>:d   r127.0<1;0>:d     r104.0<1;0>:d     -23:w              
        subb (8|M0)              r32.0<1>:ud   r6.3<0;1,0>:ud    r48.0<1;1,0>:ud  {AccWrEn,Compacted,F@1}
(W)     mov (1|M0)               r7.0<1>:hf    0.0:hf                              {I@7}
        cmp (8|M0)    (gt)f1.1   null<1>:ud    r32.0<1;1,0>:ud   r115.0<1;1,0>:ud {I@1}
        add3 (8|M0)              r59.0<1>:ud   -acc0.0<1;0>:ud   r7.0<0;0>:uw      -r54.0<1>:ud     {F@1}
(f1.1)  cmp (8|M0)    (eq)f1.1   null<1>:d     r59.0<1;1,0>:d    0:w               {I@1}
(~f1.1) cmp (8|M0)    (gt)f1.1   null<1>:ud    r59.0<1;1,0>:ud   0x0:uw             
(f1.1)  goto (8|M0)                          L37368                  L37368                
L37304:
        add3 (8|M0)              acc0.0<1>:d   r118.0<1;0>:d     -r32.0<1;0>:d     -23:w              
        mov (8|M0)               r73.0<1>:d    0:w                              
        shl (8|M0)               r74.0<1>:d    r35.0<1;1,0>:d    acc0.0<1;1,0>:d 
        goto (8|M0)                          L37368                  L39080                
L37368:
        join (8|M0)                          L39080                                
L37384:
        add3 (8|M0)              r37.0<1>:d    r32.0<1;0>:d      -r118.0<1;0>:d    23:w              
        cmp (8|M0)    (lt)f0.0   null<1>:d     r37.0<1;1,0>:d    2:w               {Compacted,I@1}
(f0.0)  goto (8|M0)                          L37528                  L37528                
L37424:
        cmp (8|M0)    (eq)f1.1   null<1>:d     r37.0<1;1,0>:d    2:w              
(~f1.1) goto (8|M0)                          L37528                  L37632                
L37456:
        shr (8|M0)               r48.0<1>:ud   r35.0<1;1,0>:ud   1:w              
        mov (8|M0)               r109.0<1>:d   0:w                              
        mov (8|M0)               r103.0<1>:d   0:w                              
        mov (8|M0)               r91.0<1>:f    r48.0<1;1,0>:f                   {Compacted,I@3}
        goto (8|M0)                          L37528                  L38520                
L37528:
        join (8|M0)                          L37632                                
L37544:
        cmp (8|M0)    (eq)f1.0   null<1>:d     r37.0<1;1,0>:d    1:w              
(~f1.0) goto (8|M0)                          L37632                  L37632                
L37576:
        mov (8|M0)               r109.0<1>:d   0:w                              
        mov (8|M0)               r103.0<1>:d   0:w                              
        mov (8|M0)               r91.0<1>:f    r35.0<1;1,0>:f                   {Compacted}
        goto (8|M0)                          L37632                  L38520                
L37632:
        join (8|M0)                          L38520                                
L37648:
        add3 (8|M0)              acc0.0<1>:d   r32.0<1;0>:d      -r115.0<1;0>:d    -1:w              
        and (8|M0)    (ne)f0.1   r65.0<1>:d    acc0.0<1;1,0>:d   63:w              
(f0.1)  goto (8|M0)                          L37728                  L37728                
L37696:
        mov (8|M0)               r25.0<1>:d    r35.0<1;1,0>:d                  
        goto (8|M0)                          L37728                  L37864                
L37728:
        join (8|M0)                          L37864                                
L37744:
        cmp (8|M0)    (lt)f0.0   null<1>:ud    r65.0<1;1,0>:ud   0x20:uw              {I@5}
(f0.0)  add (8|M0)               acc0.0<1>:d   -r65.0<1;1,0>:d   32:w              
(~f0.0) add (8|M0)               acc2.0<1>:d   r65.0<1;1,0>:d    -32:w              
(f0.0)  shr (8|M0)               r86.0<1>:ud   r35.0<1;1,0>:ud   r65.0<1;1,0>:d  
(f0.0)  shl (8|M0)               r107.0<1>:d   r40.0<1;1,0>:d    acc0.0<1;1,0>:d 
(~f0.0) shr (8|M0)               r48.0<1>:ud   r40.0<1;1,0>:ud   acc2.0<1;1,0>:d  {F@2}
(f0.0)  or (8|M0)                r48.0<1>:d    r86.0<1;1,0>:d    r107.0<1;1,0>:d  {I@2}
        mov (8|M0)               r25.0<1>:f    r48.0<1;1,0>:f                   {Compacted,I@1}
L37864:
        join (8|M0)                          L38520                                
L37880:
        add3 (8|M0)              r90.0<1>:d    r32.0<1;0>:d      -r115.0<1;0>:d    -2:w              
        and (8|M0)    (ne)f1.1   r64.0<1>:d    r90.0<1;1,0>:d    63:w               {I@1}
(f1.1)  goto (8|M0)                          L37960                  L37960                
L37928:
        mov (8|M0)               r48.0<1>:d    r35.0<1;1,0>:d                   {F@1}
        goto (8|M0)                          L37960                  L38088                
L37960:
        join (8|M0)                          L38088                                
L37976:
        cmp (8|M0)    (lt)f1.0   null<1>:ud    r64.0<1;1,0>:ud   0x20:uw              {I@5}
(f1.0)  add (8|M0)               acc0.0<1>:d   -r64.0<1;1,0>:d   32:w              
(~f1.0) add (8|M0)               acc2.0<1>:d   r64.0<1;1,0>:d    -32:w              
(f1.0)  shr (8|M0)               r84.0<1>:ud   r35.0<1;1,0>:ud   r64.0<1;1,0>:d  
(f1.0)  shl (8|M0)               r106.0<1>:d   r40.0<1;1,0>:d    acc0.0<1;1,0>:d 
(~f1.0) shr (8|M0)               r48.0<1>:ud   r40.0<1;1,0>:ud   acc2.0<1;1,0>:d 
(f1.0)  or (8|M0)                r48.0<1>:d    r84.0<1;1,0>:d    r106.0<1;1,0>:d  {I@2}
L38088:
        join (8|M0)                          L38520                                
L38104:
        and (8|M0)    (ne)f0.1   r105.0<1>:d   r90.0<1;1,0>:d    63:w              
(f0.1)  goto (8|M0)                          L38184                  L38184                
L38136:
        mov (8|M0)               r122.0<1>:d   -1:w                              
        mov (8|M0)               r38.0<1>:d    -1:w                              
        goto (8|M0)                          L38184                  L38368                
L38184:
        join (8|M0)                          L38368                                
L38200:
        cmp (8|M0)    (lt)f0.0   null<1>:ud    r105.0<1;1,0>:ud  0x20:uw              {I@6}
(f0.0)  goto (8|M0)                          L38304                  L38304                
L38232:
        add (8|M0)               acc0.0<1>:d   r105.0<1;1,0>:d   -32:w               {Compacted}
(W)     mov (1|M0)               r6.6<1>:hf    -qnan(0x1FF):hf                             
        mov (8|M0)               r122.0<1>:d   0:w                              
        shl (8|M0)               r38.0<1>:d    r6.6<0;1,0>:w     acc0.0<1;1,0>:d  {F@1}
        goto (8|M0)                          L38304                  L38368                
L38304:
        join (8|M0)                          L38368                                
L38320:
(W)     mov (1|M0)               r6.6<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (8|M0)               r38.0<1>:d    -1:w                              
        shl (8|M0)               r122.0<1>:d   r6.6<0;1,0>:w     r105.0<1;1,0>:d  {F@1}
L38368:
        join (8|M0)                          L38520                                
L38384:
        bfn.0x60 (8|M0)          r83.0<1>:ud   r122.0<1;0>:ud    r5.7<0;0>:ud      r35.0<1>:ud      {I@2} // (s0^s1)&s2
        bfn.0x60 (8|M0)          r82.0<1>:ud   r38.0<1;0>:ud     r5.7<0;0>:ud      r40.0<1>:ud      // (s0^s1)&s2
        cmp (8|M0)    (ne)f0.1   null<1>:d     r83.0<1;1,0>:d    0:w               {I@2}
(W)     mov (1|M0)               r6.6<1>:hf    -qnan(0x1FF):hf                             
        shl (8|M0)               r80.0<1>:d    r48.0<1;1,0>:d    1:w               {Compacted}
        mov (8|M0)               r91.0<1>:f    r25.0<1;1,0>:f                   {Compacted}
(~f0.1) cmp (8|M0)    (ne)f0.1   null<1>:d     r82.0<1;1,0>:d    0:w               {I@3}
        and (8|M0)               r103.0<1>:d   r80.0<1;1,0>:d    2:w               {Compacted,I@2}
(f0.1)  sel (8|M0)               acc0.0<1>:d   r6.6<0;1,0>:w     0:w               {F@2}
        mov (8|M0)               r109.0<1>:d   -acc0.0<1;1,0>:d                
L38520:
        join (8|M0)                          L39080                                
L38536:
        and (8|M0)    (ne)f1.1   r63.0<1>:d    r37.0<1;1,0>:d    63:w              
(f1.1)  goto (8|M0)                          L38600                  L38600                
L38568:
        mov (8|M0)               r48.0<1>:d    r35.0<1;1,0>:d                  
        goto (8|M0)                          L38600                  L38728                
L38600:
        join (8|M0)                          L38728                                
L38616:
        cmp (8|M0)    (lt)f1.0   null<1>:ud    r63.0<1;1,0>:ud   0x20:uw              {I@5}
(f1.0)  add (8|M0)               acc0.0<1>:d   -r63.0<1;1,0>:d   32:w              
(~f1.0) add (8|M0)               acc2.0<1>:d   r63.0<1;1,0>:d    -32:w              
(f1.0)  shr (8|M0)               r78.0<1>:ud   r35.0<1;1,0>:ud   r63.0<1;1,0>:d  
(f1.0)  shl (8|M0)               r104.0<1>:d   r40.0<1;1,0>:d    acc0.0<1;1,0>:d 
(~f1.0) shr (8|M0)               r48.0<1>:ud   r40.0<1;1,0>:ud   acc2.0<1;1,0>:d 
(f1.0)  or (8|M0)                r48.0<1>:d    r78.0<1;1,0>:d    r104.0<1;1,0>:d  {I@2}
L38728:
        join (8|M0)                          L39080                                
L38744:
        shl (8|M0)               r59.0<1>:d    r91.0<1;1,0>:d    2:w               {Compacted,F@1}
        and (8|M0)               r59.0<1>:d    r59.0<1;1,0>:d    4:w               {Compacted,I@1}
        bfn.0xFE (8|M0)          r51.0<1>:ud   r59.0<1;0>:ud     r103.0<1;0>:ud    r109.0<1>:ud     {I@1} // s0|s1|s2
        cmp (8|M0)    (eq)f0.1   null<1>:d     r51.0<1;1,0>:d    0:w               {I@1}
(~f0.1) goto (8|M0)                          L38840                  L38840                
L38808:
        mov (8|M0)               r54.0<1>:d    0:w                              
        goto (8|M0)                          L38840                  L39000                
L38840:
        join (8|M0)                          L39000                                
L38856:
        cmp (8|M0)    (gt)f0.0   null<1>:ud    r51.0<1;1,0>:ud   0x4:uw             
(~f0.0) goto (8|M0)                          L38920                  L38920                
L38888:
        mov (8|M0)               r54.0<1>:d    1:w                              
        goto (8|M0)                          L38920                  L39000                
L38920:
        join (8|M0)                          L39000                                
L38936:
        and (8|M0)    (ne)f0.0   null<1>:d     r48.0<1;1,0>:d    1:w              
(W)     mov (1|M0)               r6.6<1>:hf    0x1:hf                             
(f0.0)  cmp (8|M0)    (eq)f0.0   null<1>:d     r51.0<1;1,0>:d    4:w              
(f0.0)  sel (8|M0)               r54.0<1>:d    r6.6<0;1,0>:w     0:w               {F@1}
L39000:
        join (8|M0)                          L39080                                
L39016:
        add (8|M0)               r43.0<1>:d    r54.0<1;1,0>:d    r48.0<1;1,0>:d   {Compacted,I@2}
(W)     mov (1|M0)               r6.3<1>:f     0x800000:f                               {Compacted}
        cmp (8|M0)    (gt)f1.0   null<1>:ud    r43.0<1;1,0>:ud   0x7FFFFF:ud              {I@1}
(~f1.0) sel (8|M0)               r74.0<1>:d    r43.0<1;1,0>:d    0:w              
(f1.0)  sel (8|M0)               r73.0<1>:d    r6.3<0;1,0>:d     0:w               {F@1}
L39080:
        join (8|M0)                          L39144                                
L39096:
        and (8|M0)               r77.0<1>:d    r33.0<1;1,0>:d    -2147483648:d              
        bfn.0xFE (8|M0)          r64.0<1>:ud   r77.0<1;0>:ud     r73.0<1;0>:ud     r74.0<1>:ud      {I@1} // s0|s1|s2
        goto (8|M0)                          L39144                  L42336                
L39144:
        join (8|M0)                          L39664                                
L39160:
        and (8|M0)    (ne)f1.1   r74.0<1>:d    r104.0<1;1,0>:d   63:w              
(f1.1)  goto (8|M0)                          L39240                  L39240                
L39192:
        mov (8|M0)               r87.0<1>:d    -1:w                              
        mov (8|M0)               r103.0<1>:d   -1:w                              
        goto (8|M0)                          L39240                  L39424                
L39240:
        join (8|M0)                          L39424                                
L39256:
        cmp (8|M0)    (lt)f1.0   null<1>:ud    r74.0<1;1,0>:ud   0x20:uw              {I@6}
(f1.0)  goto (8|M0)                          L39360                  L39360                
L39288:
        add (8|M0)               acc0.0<1>:d   r74.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r6.6<1>:hf    -qnan(0x1FF):hf                             
        mov (8|M0)               r87.0<1>:d    0:w                              
        shl (8|M0)               r103.0<1>:d   r6.6<0;1,0>:w     acc0.0<1;1,0>:d  {F@1}
        goto (8|M0)                          L39360                  L39424                
L39360:
        join (8|M0)                          L39424                                
L39376:
(W)     mov (1|M0)               r6.6<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (8|M0)               r103.0<1>:d   -1:w                              
        shl (8|M0)               r87.0<1>:d    r6.6<0;1,0>:w     r74.0<1;1,0>:d   {F@1}
L39424:
        join (8|M0)                          L39664                                
L39440:
        bfn.0x60 (8|M0)          r76.0<1>:ud   r87.0<1;0>:ud     r5.7<0;0>:ud      r35.0<1>:ud      {I@2} // (s0^s1)&s2
        bfn.0x60 (8|M0)          r75.0<1>:ud   r103.0<1;0>:ud    r5.7<0;0>:ud      r40.0<1>:ud      // (s0^s1)&s2
        cmp (8|M0)    (ne)f1.0   null<1>:d     r76.0<1;1,0>:d    0:w               {I@2}
        cmp (8|M0)    (gt)f0.1   null<1>:d     r33.0<1;1,0>:d    -1:w              
(~f1.0) cmp (8|M0)    (ne)f1.0   null<1>:d     r75.0<1;1,0>:d    0:w               {I@3}
(f1.0)  cmp (8|M0)    (eq)f1.0   null<1>:d     r122.0<1;1,0>:d   -150:w              
(f0.1)  goto (8|M0)                          L39600                  L39600                
L39552:
(W)     mov (1|M0)               r6.3<1>:ud    0x80000001:ud                             
(f1.0)  sel (8|M0)               r64.0<1>:f    r6.3<0;1,0>:f     -0.0:f               {I@1}
        goto (8|M0)                          L39600                  L42336                
L39600:
        join (8|M0)                          L39664                                
L39616:
(W)     mov (1|M0)               r6.3<1>:ud    0x1:ud                              {F@1}
(f1.0)  sel (8|M0)               r64.0<1>:f    r6.3<0;1,0>:f     0.0:f               {I@1}
        goto (8|M0)                          L39664                  L42336                
L39664:
        join (8|M0)                          L42096                                
L39680:
        cmp (8|M0)    (lt)f1.1   null<1>:ud    r104.0<1;1,0>:ud  0x18:uw             
        add3 (8|M0)              r44.0<1>:d    r127.0<1;0>:d     r104.0<1;0>:d     -46:w              
(f1.1)  cmp (8|M0)    (eq)f1.1   null<1>:d     r34.0<1;1,0>:d    0:w              
(f1.1)  goto (8|M0)                          L41776                  L41776                
L39744:
        shl (8|M0)               r99.0<1>:d    r85.0<1;1,0>:d    1:w               {Compacted}
        shr (8|M0)               r98.0<1>:ud   r85.0<1;1,0>:ud   31:w              
        shl (8|M0)               r86.0<1>:d    r125.0<1;1,0>:d   1:w               {Compacted}
        cmp (8|M0)    (lt)f1.0   null<1>:ud    r99.0<1;1,0>:ud   0x4E:uw              {A@1}
        or (8|M0)                r86.0<1>:d    r86.0<1;1,0>:d    r98.0<1;1,0>:d   {Compacted,I@2}
(f1.0)  cmp (8|M0)    (eq)f1.0   null<1>:d     r86.0<1;1,0>:d    0:w               {I@1}
(~f1.0) cmp (8|M0)    (lt)f1.0   null<1>:d     r86.0<1;1,0>:d    0:w              
(f1.0)  goto (8|M0)                          L39976                  L39976                
L39848:
        cmp (8|M0)    (eq)f1.0   null<1>:d     r85.0<1;1,0>:d    39:w              
(f1.0)  cmp (8|M0)    (eq)f1.0   null<1>:d     r125.0<1;1,0>:d   0:w              
(~f1.0) goto (8|M0)                          L39976                  L40040                
L39896:
        shr (8|M0)               r48.0<1>:ud   r35.0<1;1,0>:ud   1:w              
        mov (8|M0)               r2.0<1>:d     0:w                              
        mov (8|M0)               r90.0<1>:d    0:w                              
        mov (8|M0)               r110.0<1>:f   r48.0<1;1,0>:f                   {Compacted,I@3}
        mov (8|M0)               r48.0<1>:f    r35.0<1;1,0>:f                   {Compacted}
        goto (8|M0)                          L39976                  L41248                
L39976:
        join (8|M0)                          L40040                                
L39992:
        cmp (8|M0)    (eq)f0.1   null<1>:d     r85.0<1;1,0>:d    38:w              
(f0.1)  cmp (8|M0)    (eq)f0.1   null<1>:d     r125.0<1;1,0>:d   0:w              
(f0.1)  goto (8|M0)                          L40040                  L41160                
L40040:
        join (8|M0)                          L41160                                
L40056:
        add (8|M0)               acc0.0<1>:d   -r85.0<1;1,0>:d   39:w               {Compacted}
        add (8|M0)               r41.0<1>:d    -r85.0<1;1,0>:d   40:w               {Compacted}
        and (8|M0)    (ne)f0.0   r81.0<1>:d    acc0.0<1;1,0>:d   63:w              
(f0.0)  goto (8|M0)                          L40136                  L40136                
L40104:
        mov (8|M0)               r39.0<1>:d    r35.0<1;1,0>:d                  
        goto (8|M0)                          L40136                  L40272                
L40136:
        join (8|M0)                          L40272                                
L40152:
        cmp (8|M0)    (lt)f1.1   null<1>:ud    r81.0<1;1,0>:ud   0x20:uw              {I@5}
(f1.1)  add (8|M0)               acc0.0<1>:d   -r81.0<1;1,0>:d   32:w              
(~f1.1) add (8|M0)               acc2.0<1>:d   r81.0<1;1,0>:d    -32:w              
(f1.1)  shr (8|M0)               r72.0<1>:ud   r35.0<1;1,0>:ud   r81.0<1;1,0>:d  
(f1.1)  shl (8|M0)               r36.0<1>:d    r40.0<1;1,0>:d    acc0.0<1;1,0>:d 
(~f1.1) shr (8|M0)               r48.0<1>:ud   r40.0<1;1,0>:ud   acc2.0<1;1,0>:d  {F@1}
(f1.1)  or (8|M0)                r48.0<1>:d    r72.0<1;1,0>:d    r36.0<1;1,0>:d   {I@2}
        mov (8|M0)               r39.0<1>:f    r48.0<1;1,0>:f                   {Compacted,I@1}
L40272:
        join (8|M0)                          L41160                                
L40288:
        add (8|M0)               r111.0<1>:d   -r85.0<1;1,0>:d   38:w               {Compacted}
        and (8|M0)    (ne)f1.0   r85.0<1>:d    r111.0<1;1,0>:d   63:w               {I@1}
(f1.0)  goto (8|M0)                          L40360                  L40360                
L40328:
        mov (8|M0)               r24.0<1>:d    r35.0<1;1,0>:d                  
        goto (8|M0)                          L40360                  L40496                
L40360:
        join (8|M0)                          L40496                                
L40376:
        cmp (8|M0)    (lt)f0.1   null<1>:ud    r85.0<1;1,0>:ud   0x20:uw              {I@5}
(f0.1)  add (8|M0)               acc0.0<1>:d   -r85.0<1;1,0>:d   32:w              
(~f0.1) add (8|M0)               acc2.0<1>:d   r85.0<1;1,0>:d    -32:w              
(f0.1)  shr (8|M0)               r70.0<1>:ud   r35.0<1;1,0>:ud   r85.0<1;1,0>:d  
(f0.1)  shl (8|M0)               r54.0<1>:d    r40.0<1;1,0>:d    acc0.0<1;1,0>:d 
(~f0.1) shr (8|M0)               r48.0<1>:ud   r40.0<1;1,0>:ud   acc2.0<1;1,0>:d  {F@1}
(f0.1)  or (8|M0)                r48.0<1>:d    r70.0<1;1,0>:d    r54.0<1;1,0>:d   {I@2}
        mov (8|M0)               r24.0<1>:f    r48.0<1;1,0>:f                   {Compacted,I@1}
L40496:
        join (8|M0)                          L41160                                
L40512:
        and (8|M0)    (ne)f0.0   r53.0<1>:d    r111.0<1;1,0>:d   63:w              
(f0.0)  goto (8|M0)                          L40592                  L40592                
L40544:
        mov (8|M0)               r67.0<1>:d    -1:w                              
        mov (8|M0)               r81.0<1>:d    -1:w                              
        goto (8|M0)                          L40592                  L40776                
L40592:
        join (8|M0)                          L40776                                
L40608:
        cmp (8|M0)    (lt)f1.1   null<1>:ud    r53.0<1;1,0>:ud   0x20:uw              {I@6}
(f1.1)  goto (8|M0)                          L40712                  L40712                
L40640:
        add (8|M0)               acc0.0<1>:d   r53.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r6.6<1>:hf    -qnan(0x1FF):hf                             
        mov (8|M0)               r67.0<1>:d    0:w                              
        shl (8|M0)               r81.0<1>:d    r6.6<0;1,0>:w     acc0.0<1;1,0>:d  {F@1}
        goto (8|M0)                          L40712                  L40776                
L40712:
        join (8|M0)                          L40776                                
L40728:
(W)     mov (1|M0)               r6.6<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (8|M0)               r81.0<1>:d    -1:w                              
        shl (8|M0)               r67.0<1>:d    r6.6<0;1,0>:w     r53.0<1;1,0>:d   {F@1}
L40776:
        join (8|M0)                          L41160                                
L40792:
        bfn.0x60 (8|M0)          r69.0<1>:ud   r67.0<1;0>:ud     r5.7<0;0>:ud      r35.0<1>:ud      {I@2} // (s0^s1)&s2
        bfn.0x60 (8|M0)          r68.0<1>:ud   r81.0<1;0>:ud     r5.7<0;0>:ud      r40.0<1>:ud      // (s0^s1)&s2
        cmp (8|M0)    (ne)f0.0   null<1>:d     r69.0<1;1,0>:d    0:w               {I@2}
(W)     mov (1|M0)               r6.6<1>:hf    -qnan(0x1FF):hf                             
        and (8|M0)    (ne)f1.0   r84.0<1>:d    r41.0<1;1,0>:d    63:w              
(~f0.0) cmp (8|M0)    (ne)f0.0   null<1>:d     r68.0<1;1,0>:d    0:w               {I@3}
(f0.0)  sel (8|M0)               acc0.0<1>:d   r6.6<0;1,0>:w     0:w               {F@1}
        mov (8|M0)               r2.0<1>:d     -acc0.0<1;1,0>:d                
(f1.0)  goto (8|M0)                          L40968                  L40968                
L40936:
        mov (8|M0)               r48.0<1>:d    r35.0<1;1,0>:d                  
        goto (8|M0)                          L40968                  L41096                
L40968:
        join (8|M0)                          L41096                                
L40984:
        cmp (8|M0)    (lt)f0.1   null<1>:ud    r84.0<1;1,0>:ud   0x20:uw              {I@7}
(f0.1)  add (8|M0)               acc0.0<1>:d   -r84.0<1;1,0>:d   32:w              
(~f0.1) add (8|M0)               acc2.0<1>:d   r84.0<1;1,0>:d    -32:w              
(f0.1)  shr (8|M0)               r65.0<1>:ud   r35.0<1;1,0>:ud   r84.0<1;1,0>:d  
(f0.1)  shl (8|M0)               r52.0<1>:d    r40.0<1;1,0>:d    acc0.0<1;1,0>:d 
(~f0.1) shr (8|M0)               r48.0<1>:ud   r40.0<1;1,0>:ud   acc2.0<1;1,0>:d 
(f0.1)  or (8|M0)                r48.0<1>:d    r65.0<1;1,0>:d    r52.0<1;1,0>:d   {I@2}
L41096:
        join (8|M0)                          L41160                                
L41112:
        shl (8|M0)               r64.0<1>:d    r24.0<1;1,0>:d    1:w               {Compacted}
        mov (8|M0)               r110.0<1>:f   r48.0<1;1,0>:f                   {Compacted,I@3}
        and (8|M0)               r90.0<1>:d    r64.0<1;1,0>:d    2:w               {Compacted,I@1}
        mov (8|M0)               r48.0<1>:f    r39.0<1;1,0>:f                   {Compacted}
        goto (8|M0)                          L41160                  L41248                
L41160:
        join (8|M0)                          L41248                                
L41176:
        shr (8|M0)               r48.0<1>:ud   r35.0<1;1,0>:ud   2:w               {F@1}
        mov (8|M0)               r2.0<1>:d     0:w                              
        mov (8|M0)               r90.0<1>:d    0:w                              
        mov (8|M0)               r110.0<1>:f   r48.0<1;1,0>:f                   {Compacted,I@3}
        shr (8|M0)               r48.0<1>:ud   r35.0<1;1,0>:ud   1:w               {F@1}
L41248:
        join (8|M0)                          L41776                                
L41264:
        shl (8|M0)               r102.0<1>:d   r48.0<1;1,0>:d    2:w               {Compacted,I@2}
        and (8|M0)               r117.0<1>:d   r110.0<1;1,0>:d   8388607:d              
        and (8|M0)               r102.0<1>:d   r102.0<1;1,0>:d   4:w               {Compacted,I@2}
        bfn.0xFE (8|M0)          r73.0<1>:ud   r102.0<1;0>:ud    r90.0<1;0>:ud     r2.0<1>:ud       {I@1} // s0|s1|s2
        cmp (8|M0)    (eq)f0.0   null<1>:d     r73.0<1;1,0>:d    0:w               {Compacted,I@1}
(~f0.0) goto (8|M0)                          L41368                  L41368                
L41336:
        mov (8|M0)               r72.0<1>:d    0:w                              
        goto (8|M0)                          L41368                  L41528                
L41368:
        join (8|M0)                          L41528                                
L41384:
        cmp (8|M0)    (gt)f1.1   null<1>:ud    r73.0<1;1,0>:ud   0x4:uw             
(~f1.1) goto (8|M0)                          L41448                  L41448                
L41416:
        mov (8|M0)               r72.0<1>:d    1:w                              
        goto (8|M0)                          L41448                  L41528                
L41448:
        join (8|M0)                          L41528                                
L41464:
        and (8|M0)    (ne)f1.1   null<1>:d     r110.0<1;1,0>:d   1:w              
(W)     mov (1|M0)               r6.6<1>:hf    0x1:hf                             
(f1.1)  cmp (8|M0)    (eq)f1.1   null<1>:d     r73.0<1;1,0>:d    4:w              
(f1.1)  sel (8|M0)               r72.0<1>:d    r6.6<0;1,0>:w     0:w               {F@1}
L41528:
        join (8|M0)                          L41776                                
L41544:
        add (8|M0)               r58.0<1>:d    r117.0<1;1,0>:d   r72.0<1;1,0>:d   {Compacted,I@2}
        add3 (8|M0)              r51.0<1>:d    r127.0<1;0>:d     r104.0<1;0>:d     -45:w              
        cmp (8|M0)    (gt)f1.1   null<1>:ud    r58.0<1;1,0>:ud   0x7FFFFF:ud              {I@2}
(f1.1)  sel (8|M0)               r48.0<1>:d    r51.0<1;1,0>:d    r44.0<1;1,0>:d   {I@2}
        cmp (8|M0)    (eq)f1.0   null<1>:d     r48.0<1;1,0>:d    255:w               {I@1}
(f1.0)  goto (8|M0)                          L41704                  L41704                
L41632:
(~f1.1) sel (8|M0)               r55.0<1>:d    r58.0<1;1,0>:d    0:w              
        and (8|M0)               r50.0<1>:d    r33.0<1;1,0>:d    -2147483648:d              
        shl (8|M0)               r63.0<1>:d    r48.0<1;1,0>:d    23:w               {Compacted}
        bfn.0xFE (8|M0)          r64.0<1>:ud   r50.0<1;0>:ud     r63.0<1;0>:ud     r55.0<1>:ud      {I@1} // s0|s1|s2
        goto (8|M0)                          L41704                  L42336                
L41704:
        join (8|M0)                          L41776                                
L41720:
        cmp (8|M0)    (gt)f1.0   null<1>:d     r33.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r6.3<1>:f     inf:f                               {Compacted}
(f1.0)  sel (8|M0)               r64.0<1>:f    r6.3<0;1,0>:f     -inf:f               {A@1}
        goto (8|M0)                          L41776                  L42336                
L41776:
        join (8|M0)                          L42096                                
L41792:
        and (8|M0)    (ne)f0.1   r50.0<1>:d    r104.0<1;1,0>:d   63:w              
(f0.1)  goto (8|M0)                          L41856                  L41856                
L41824:
        mov (8|M0)               r67.0<1>:d    -1:w                              
        goto (8|M0)                          L41856                  L41984                
L41856:
        join (8|M0)                          L41984                                
L41872:
        cmp (8|M0)    (lt)f0.0   null<1>:ud    r50.0<1;1,0>:ud   0x20:uw              {I@5}
(f0.0)  goto (8|M0)                          L41936                  L41936                
L41904:
        mov (8|M0)               r67.0<1>:d    0:w                              
        goto (8|M0)                          L41936                  L41984                
L41936:
        join (8|M0)                          L41984                                
L41952:
(W)     mov (1|M0)               r6.6<1>:hf    -qnan(0x1FF):hf                             
        shl (8|M0)               r67.0<1>:d    r6.6<0;1,0>:w     r50.0<1;1,0>:d   {F@1}
L41984:
        join (8|M0)                          L42096                                
L42000:
        bfn.0x60 (8|M0)          r66.0<1>:ud   r67.0<1;0>:ud     r5.7<0;0>:ud      r35.0<1>:ud      {I@2} // (s0^s1)&s2
        add (8|M0)               acc0.0<1>:d   -r104.0<1;1,0>:d  23:w               {Compacted}
        and (8|M0)               r49.0<1>:d    r33.0<1;1,0>:d    -2147483648:d              
        shl (8|M0)               r61.0<1>:d    r44.0<1;1,0>:d    23:w               {Compacted}
        shl (8|M0)               r66.0<1>:d    r66.0<1;1,0>:d    acc0.0<1;1,0>:d  {I@4}
        bfn.0xFE (8|M0)          r64.0<1>:ud   r49.0<1;0>:ud     r61.0<1;0>:ud     r66.0<1>:ud      {I@1} // s0|s1|s2
        goto (8|M0)                          L42096                  L42336                
L42096:
        join (8|M0)                          L42168                                
L42112:
        cmp (8|M0)    (gt)f0.1   null<1>:d     r33.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r5.7<1>:f     inf:f                               {Compacted}
(f0.1)  sel (8|M0)               r64.0<1>:f    r5.7<0;1,0>:f     -inf:f               {A@1}
        goto (8|M0)                          L42168                  L42336                
L42168:
        join (8|M0)                          L42232                                
L42184:
        cmp (8|M0)    (lt)f0.0   null<1>:d     r33.0<1;1,0>:d    0:w               {Compacted}
(W)     mov (1|M0)               r5.7<1>:f     -0.0:f                               {Compacted}
(f0.0)  sel (8|M0)               r64.0<1>:f    r5.7<0;1,0>:f     0.0:f               {F@1}
        goto (8|M0)                          L42232                  L42336                
L42232:
        join (8|M0)                          L42304                                
L42248:
        cmp (8|M0)    (gt)f1.1   null<1>:d     r33.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r5.7<1>:f     inf:f                               {Compacted}
(f1.1)  sel (8|M0)               r64.0<1>:f    r5.7<0;1,0>:f     -inf:f               {F@1}
        goto (8|M0)                          L42304                  L42336                
L42304:
        join (8|M0)                          L42336                                
L42320:
        bfn.0xF8 (8|M0)          r64.0<1>:ud   r33.0<1;0>:ud     r5.6<0;0>:ud      r5.3<0>:ud       {F@1} // s0&s1|s2
L42336:
        join (8|M0)                          L42384                                
L42352:
        cmp (8|M0)    (lt)f1.1   null<1>:f     r22.0<1;1,0>:f    0.0:f               {I@5}
(f1.1)  sel (8|M0)               r48.0<1>:f    -r64.0<1;1,0>:f   r64.0<1;1,0>:f   {I@2}
L42384:
        join (8|M0)                          L42400                                
L42400:
        mov (8|M0)               r23.0<1>:f    r48.0<1;1,0>:f                   {Compacted,F@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        ret (8|M0)                           r5.4                             {A@1}
L42456:
        shr (8|M0)               r59.0<1>:ud   r75.0<1;1,0>:ud   23:w              
        shr (8|M0)               r60.0<1>:ud   r83.0<1;1,0>:ud   23:w              
        and (8|M0)    (eq)f0.1   r112.0<1>:d   r59.0<1;1,0>:d    255:w               {I@2}
        and (8|M0)               r92.0<1>:d    r83.0<1;1,0>:d    8388607:d              
        and (8|M0)               r63.0<1>:d    r75.0<1;1,0>:d    8388607:d              
        shr (8|M0)               r42.0<1>:ud   r83.0<1;1,0>:ud   31:w              
        cmp (8|M0)    (eq)f1.0   null<1>:d     r112.0<1;1,0>:d   0:w               {I@4}
        shr (8|M0)               r33.0<1>:ud   r75.0<1;1,0>:ud   31:w              
        and (8|M0)               r77.0<1>:d    r60.0<1;1,0>:d    255:w               {Compacted}
(f1.0)  goto (8|M0)                          L42664                  L42664                
L42608:
(W)     mov (1|M0)               r6.12<2>:b    1:w                              
        add (8|M0)               r69.0<1>:d    r77.0<1;1,0>:d    -r112.0<1;1,0>:d {Compacted,I@3}
        mov (8|M0)               r7.0<1>:b     r6.12<0;1,0>:b                   {I@2}
        goto (8|M0)                          L42664                  L42752                
L42664:
        join (8|M0)                          L42752                                
L42680:
        cmp (8|M0)    (eq)f1.1   null<1>:d     r77.0<1;1,0>:d    0:w              
(f1.1)  goto (8|M0)                          L42752                  L49224                
L42712:
(W)     mov (1|M0)               r6.12<2>:b    0:w                              
        add (8|M0)               r69.0<1>:d    r77.0<1;1,0>:d    -1:w               {Compacted}
        mov (8|M0)               r7.0<1>:b     r6.12<0;1,0>:b                   {I@2}
L42752:
        join (8|M0)                          L49224                                
L42768:
        cmp (8|M0)    (eq)f1.0   null<1>:d     r69.0<1;1,0>:d    0:w               {I@3}
(f1.0)  goto (8|M0)                          L46712                  L46712                
L42800:
        cmp (8|M0)    (ne)f1.1   null<1>:d     r69.0<1;1,0>:d    1:w              
(f1.1)  goto (8|M0)                          L42960                  L42960                
L42832:
        shr (8|M0)               r113.0<1>:ud  r63.0<1;1,0>:ud   1:w              
        cmp (8|M0)    (eq)f1.1   r58.0<1>:d    r112.0<1;1,0>:d   0:w              
        and (8|M0)               r79.0<1>:d    r75.0<1;1,0>:d    1:w               {Compacted}
        or (8|M0)                r3.0<1>:d     r113.0<1;1,0>:d   4194304:d               {I@3}
        mov (8|M0)               r40.0<1>:d    0:w                              
        mov (8|M0)               r43.0<1>:f    r79.0<1;1,0>:f                   {Compacted,I@3}
        bfn.0xD8 (8|M0)          r42.0<1>:ud   r58.0<1;0>:ud     r113.0<1;0>:ud    r3.0<1>:ud       {I@2} // s0&s1|~s0&s2
        mov (8|M0)               r79.0<1>:d    0:w                               {F@1}
        goto (8|M0)                          L42960                  L43656                
L42960:
        join (8|M0)                          L43656                                
L42976:
        cmp (8|M0)    (lt)f1.0   null<1>:ud    r69.0<1;1,0>:ud   0x18:uw             
(f1.0)  goto (8|M0)                          L43392                  L43392                
L43008:
        cmp (8|M0)    (lt)f1.1   null<1>:d     r69.0<1;1,0>:d    25:w              
        mov (8|M0)               r79.0<1>:d    r7.0<1;1,0>:ub                  
(f1.1)  goto (8|M0)                          L43152                  L43152                
L43056:
        cmp (8|M0)    (eq)f1.0   null<1>:d     r69.0<1;1,0>:d    25:w              
(~f1.0) goto (8|M0)                          L43152                  L43296                
L43088:
        cmp (8|M0)    (ne)f1.0   r40.0<1>:d    r63.0<1;1,0>:d    0:w              
        mov (8|M0)               r43.0<1>:d    0:w                              
        mov (8|M0)               r42.0<1>:d    0:w                              
        goto (8|M0)                          L43152                  L43656                
L43152:
        join (8|M0)                          L43296                                
L43168:
        cmp (8|M0)    (eq)f1.1   null<1>:d     r69.0<1;1,0>:d    24:w              
(~f1.1) goto (8|M0)                          L43296                  L43296                
L43200:
        shr (8|M0)               r2.0<1>:ud    r75.0<1;1,0>:ud   22:w              
        and (8|M0)               r57.0<1>:d    r75.0<1;1,0>:d    4194303:d              
        mov (8|M0)               r43.0<1>:f    r79.0<1;1,0>:f                   {Compacted,I@7}
        mov (8|M0)               r42.0<1>:d    0:w                              
        cmp (8|M0)    (ne)f1.1   r40.0<1>:d    r57.0<1;1,0>:d    0:w               {I@2}
        and (8|M0)               r79.0<1>:d    r2.0<1;1,0>:d     1:w               {Compacted,F@1}
        goto (8|M0)                          L43296                  L43656                
L43296:
        join (8|M0)                          L43392                                
L43312:
        cmp (8|M0)    (ne)f1.0   r40.0<1>:d    r75.0<1;1,0>:d    0:w              
        mov (8|M0)               r79.0<1>:d    0:w                              
        mov (8|M0)               r43.0<1>:d    0:w                              
        mov (8|M0)               r42.0<1>:d    0:w                              
        goto (8|M0)                          L43392                  L43656                
L43392:
        join (8|M0)                          L43656                                
L43408:
        add (8|M0)               acc0.0<1>:d   r69.0<1;1,0>:d    -2:w               {Compacted}
(W)     mov (1|M0)               r6.6<1>:hf    -qnan(0x1FF):hf                             
        add (8|M0)               acc2.0<1>:d   r69.0<1;1,0>:d    -1:w               {Compacted}
        cmp (8|M0)    (eq)f1.0   null<1>:d     r112.0<1;1,0>:d   0:w              
        shr (8|M0)               r32.0<1>:ud   r63.0<1;1,0>:ud   acc0.0<1;1,0>:d 
        shl (8|M0)               r113.0<1>:d   r6.6<0;1,0>:w     acc0.0<1;1,0>:d  {F@1}
(W)     mov (1|M0)               r6.3<1>:d     -1:w                              
        add (8|M0)               acc0.0<1>:d   -r69.0<1;1,0>:d   23:w               {Compacted}
        shr (8|M0)               r66.0<1>:ud   r63.0<1;1,0>:ud   acc2.0<1;1,0>:d 
        bfn.0x60 (8|M0)          r30.0<1>:ud   r113.0<1;0>:ud    r6.3<0;0>:ud      r63.0<1>:ud      {I@3} // (s0^s1)&s2
(W)     mov (1|M0)               r6.6<1>:hf    0x1:hf                              {I@1}
        shr (8|M0)               r22.0<1>:ud   r63.0<1;1,0>:ud   r69.0<1;1,0>:d  
        and (8|M0)               r79.0<1>:d    r66.0<1;1,0>:d    1:w               {Compacted}
        shl (8|M0)               r31.0<1>:d    r6.6<0;1,0>:w     acc0.0<1;1,0>:d  {F@1}
(f1.0)  mov (8|M0)               r31.0<1>:d    0:w                              
        cmp (8|M0)    (ne)f1.1   r40.0<1>:d    r30.0<1;1,0>:d    0:w              
        mov (8|M0)               r43.0<1>:f    r79.0<1;1,0>:f                   {Compacted,I@4}
        or (8|M0)                r42.0<1>:d    r22.0<1;1,0>:d    r31.0<1;1,0>:d   {Compacted,I@2}
        and (8|M0)               r79.0<1>:d    r32.0<1;1,0>:d    1:w               {Compacted,F@1}
L43656:
        join (8|M0)                          L46712                                
L43672:
        cmp (8|M0)    (ne)f1.0   r108.0<1>:d   r40.0<1;1,0>:d    0:w               {I@4}
        shl (8|M0)               r97.0<1>:d    r42.0<1;1,0>:d    3:w               {Compacted,I@4}
        shl (8|M0)               r56.0<1>:d    r43.0<1;1,0>:d    2:w               {Compacted}
        shl (8|M0)               r55.0<1>:d    r79.0<1;1,0>:d    1:w               {Compacted,I@5}
        mov (8|M0)               r108.0<1>:d   -r108.0<1;1,0>:d                 {I@4}
        or (8|M0)                r97.0<1>:d    r97.0<1;1,0>:d    r56.0<1;1,0>:d   {Compacted,I@3}
        shl (8|M0)               r107.0<1>:d   r92.0<1;1,0>:d    3:w               {Compacted}
        bfn.0xFE (8|M0)          r51.0<1>:ud   r97.0<1;0>:ud     r55.0<1;0>:ud     r108.0<1>:ud     {I@2} // s0|s1|s2
        cmp (8|M0)    (lt)f1.1   null<1>:ud    r107.0<1;1,0>:ud  r51.0<1;1,0>:ud  {I@1}
(f1.1)  goto (8|M0)                          L43840                  L43840                
L43792:
        add (8|M0)               r80.0<1>:d    r107.0<1;1,0>:d   -r51.0<1;1,0>:d  {Compacted}
        and (8|M0)               r105.0<1>:d   r80.0<1;1,0>:d    7:w               {Compacted,I@1}
        shr (8|M0)               r106.0<1>:ud  r80.0<1;1,0>:ud   3:w              
        goto (8|M0)                          L43840                  L46320                
L43840:
        join (8|M0)                          L46320                                
L43856:
        or (8|M0)                acc0.0<1>:d   r107.0<1;1,0>:d   67108864:d              
        add (8|M0)               r45.0<1>:d    acc0.0<1;1,0>:d   -r51.0<1;1,0>:d 
        and (8|M0)    (eq)f1.0   null<1>:d     r45.0<1;1,0>:d    33554432:d               {I@1}
(~f1.0) goto (8|M0)                          L45904                  L45904                
L43920:
        and (8|M0)    (eq)f1.1   null<1>:d     r45.0<1;1,0>:d    16777216:d              
(~f1.1) goto (8|M0)                          L45856                  L45856                
L43952:
        and (8|M0)    (eq)f1.0   null<1>:d     r45.0<1;1,0>:d    8388608:d              
(~f1.0) goto (8|M0)                          L45808                  L45808                
L43984:
        and (8|M0)    (eq)f1.1   null<1>:d     r45.0<1;1,0>:d    4194304:d              
(~f1.1) goto (8|M0)                          L45760                  L45760                
L44016:
        and (8|M0)    (eq)f1.0   null<1>:d     r45.0<1;1,0>:d    2097152:d              
(~f1.0) goto (8|M0)                          L45712                  L45712                
L44048:
        and (8|M0)    (eq)f1.1   null<1>:d     r45.0<1;1,0>:d    1048576:d              
(~f1.1) goto (8|M0)                          L45664                  L45664                
L44080:
        and (8|M0)    (eq)f1.0   null<1>:d     r45.0<1;1,0>:d    524288:d              
(~f1.0) goto (8|M0)                          L45616                  L45616                
L44112:
        and (8|M0)    (eq)f1.1   null<1>:d     r45.0<1;1,0>:d    262144:d              
(~f1.1) goto (8|M0)                          L45568                  L45568                
L44144:
        and (8|M0)    (eq)f1.0   null<1>:d     r45.0<1;1,0>:d    131072:d              
(~f1.0) goto (8|M0)                          L45520                  L45520                
L44176:
        and (8|M0)    (eq)f1.1   null<1>:d     r45.0<1;1,0>:d    65536:d              
(~f1.1) goto (8|M0)                          L45472                  L45472                
L44208:
        and (8|M0)    (eq)f1.0   null<1>:d     r45.0<1;1,0>:d    0x8000:uw             
(~f1.0) goto (8|M0)                          L45424                  L45424                
L44240:
        and (8|M0)    (eq)f1.1   null<1>:d     r45.0<1;1,0>:d    16384:w              
(~f1.1) goto (8|M0)                          L45376                  L45376                
L44272:
        and (8|M0)    (eq)f1.0   null<1>:d     r45.0<1;1,0>:d    8192:w              
(~f1.0) goto (8|M0)                          L45328                  L45328                
L44304:
        and (8|M0)    (eq)f1.1   null<1>:d     r45.0<1;1,0>:d    4096:w              
(~f1.1) goto (8|M0)                          L45280                  L45280                
L44336:
        and (8|M0)    (eq)f1.0   null<1>:d     r45.0<1;1,0>:d    2048:w              
(~f1.0) goto (8|M0)                          L45232                  L45232                
L44368:
        and (8|M0)    (eq)f1.1   null<1>:d     r45.0<1;1,0>:d    1024:w              
(~f1.1) goto (8|M0)                          L45184                  L45184                
L44400:
        and (8|M0)    (eq)f1.0   null<1>:d     r45.0<1;1,0>:d    512:w              
(~f1.0) goto (8|M0)                          L45136                  L45136                
L44432:
        and (8|M0)    (eq)f1.1   null<1>:d     r45.0<1;1,0>:d    256:w              
(~f1.1) goto (8|M0)                          L45088                  L45088                
L44464:
        and (8|M0)    (eq)f1.0   null<1>:d     r45.0<1;1,0>:d    128:w              
(~f1.0) goto (8|M0)                          L45040                  L45040                
L44496:
        and (8|M0)    (eq)f1.1   null<1>:d     r45.0<1;1,0>:d    64:w              
(~f1.1) goto (8|M0)                          L44992                  L44992                
L44528:
        and (8|M0)    (eq)f1.0   null<1>:d     r45.0<1;1,0>:d    32:w              
(~f1.0) goto (8|M0)                          L44944                  L44944                
L44560:
        and (8|M0)    (eq)f1.1   null<1>:d     r45.0<1;1,0>:d    16:w              
(~f1.1) goto (8|M0)                          L44896                  L44896                
L44592:
        and (8|M0)    (eq)f1.0   null<1>:d     r45.0<1;1,0>:d    8:w              
(~f1.0) goto (8|M0)                          L44848                  L44848                
L44624:
        and (8|M0)    (eq)f1.1   null<1>:d     r45.0<1;1,0>:d    4:w              
(~f1.1) goto (8|M0)                          L44800                  L44800                
L44656:
        and (8|M0)    (eq)f1.0   null<1>:d     r45.0<1;1,0>:d    2:w              
(~f1.0) goto (8|M0)                          L44752                  L44752                
L44688:
        and (8|M0)    (eq)f1.0   null<1>:d     r45.0<1;1,0>:d    1:w              
(W)     mov (1|M0)               r6.6<1>:hf    -qnan(0x1FF):hf                             
(f1.0)  sel (8|M0)               r47.0<1>:d    r6.6<0;1,0>:w     25:w               {F@1}
        goto (8|M0)                          L44752                  L45936                
L44752:
        join (8|M0)                          L44800                                
L44768:
        mov (8|M0)               r47.0<1>:d    24:w                              
        goto (8|M0)                          L44800                  L45936                
L44800:
        join (8|M0)                          L44848                                
L44816:
        mov (8|M0)               r47.0<1>:d    23:w                              
        goto (8|M0)                          L44848                  L45936                
L44848:
        join (8|M0)                          L44896                                
L44864:
        mov (8|M0)               r47.0<1>:d    22:w                              
        goto (8|M0)                          L44896                  L45936                
L44896:
        join (8|M0)                          L44944                                
L44912:
        mov (8|M0)               r47.0<1>:d    21:w                              
        goto (8|M0)                          L44944                  L45936                
L44944:
        join (8|M0)                          L44992                                
L44960:
        mov (8|M0)               r47.0<1>:d    20:w                              
        goto (8|M0)                          L44992                  L45936                
L44992:
        join (8|M0)                          L45040                                
L45008:
        mov (8|M0)               r47.0<1>:d    19:w                              
        goto (8|M0)                          L45040                  L45936                
L45040:
        join (8|M0)                          L45088                                
L45056:
        mov (8|M0)               r47.0<1>:d    18:w                              
        goto (8|M0)                          L45088                  L45936                
L45088:
        join (8|M0)                          L45136                                
L45104:
        mov (8|M0)               r47.0<1>:d    17:w                              
        goto (8|M0)                          L45136                  L45936                
L45136:
        join (8|M0)                          L45184                                
L45152:
        mov (8|M0)               r47.0<1>:d    16:w                              
        goto (8|M0)                          L45184                  L45936                
L45184:
        join (8|M0)                          L45232                                
L45200:
        mov (8|M0)               r47.0<1>:d    15:w                              
        goto (8|M0)                          L45232                  L45936                
L45232:
        join (8|M0)                          L45280                                
L45248:
        mov (8|M0)               r47.0<1>:d    14:w                              
        goto (8|M0)                          L45280                  L45936                
L45280:
        join (8|M0)                          L45328                                
L45296:
        mov (8|M0)               r47.0<1>:d    13:w                              
        goto (8|M0)                          L45328                  L45936                
L45328:
        join (8|M0)                          L45376                                
L45344:
        mov (8|M0)               r47.0<1>:d    12:w                              
        goto (8|M0)                          L45376                  L45936                
L45376:
        join (8|M0)                          L45424                                
L45392:
        mov (8|M0)               r47.0<1>:d    11:w                              
        goto (8|M0)                          L45424                  L45936                
L45424:
        join (8|M0)                          L45472                                
L45440:
        mov (8|M0)               r47.0<1>:d    10:w                              
        goto (8|M0)                          L45472                  L45936                
L45472:
        join (8|M0)                          L45520                                
L45488:
        mov (8|M0)               r47.0<1>:d    9:w                              
        goto (8|M0)                          L45520                  L45936                
L45520:
        join (8|M0)                          L45568                                
L45536:
        mov (8|M0)               r47.0<1>:d    8:w                              
        goto (8|M0)                          L45568                  L45936                
L45568:
        join (8|M0)                          L45616                                
L45584:
        mov (8|M0)               r47.0<1>:d    7:w                              
        goto (8|M0)                          L45616                  L45936                
L45616:
        join (8|M0)                          L45664                                
L45632:
        mov (8|M0)               r47.0<1>:d    6:w                              
        goto (8|M0)                          L45664                  L45936                
L45664:
        join (8|M0)                          L45712                                
L45680:
        mov (8|M0)               r47.0<1>:d    5:w                              
        goto (8|M0)                          L45712                  L45936                
L45712:
        join (8|M0)                          L45760                                
L45728:
        mov (8|M0)               r47.0<1>:d    4:w                              
        goto (8|M0)                          L45760                  L45936                
L45760:
        join (8|M0)                          L45808                                
L45776:
        mov (8|M0)               r47.0<1>:d    3:w                              
        goto (8|M0)                          L45808                  L45936                
L45808:
        join (8|M0)                          L45856                                
L45824:
        mov (8|M0)               r47.0<1>:d    2:w                              
        goto (8|M0)                          L45856                  L45936                
L45856:
        join (8|M0)                          L45904                                
L45872:
        mov (8|M0)               r47.0<1>:d    1:w                              
        goto (8|M0)                          L45904                  L45936                
L45904:
        join (8|M0)                          L45936                                
L45920:
        mov (8|M0)               r47.0<1>:d    0:w                              
L45936:
        join (8|M0)                          L46320                                
L45952:
        cmp (8|M0)    (ne)f1.0   null<1>:d     r69.0<1;1,0>:d    1:w              
(W)     mov (1|M0)               r3.8<1>:hf    0x1:hf                             
(f0.1)  sel (8|M0)               r2.0<1>:uw    r3.8<0;1,0>:uw    0x0:uw              {F@1}
(f1.0)  sel (8|M0)               r3.0<1>:uw    r3.8<0;1,0>:uw    0x0:uw             
        or (8|M0)     (ne)f1.0   null<1>:uw    r3.0<1;1,0>:uw    r2.0<1;1,0>:uw   {I@1}
(f1.0)  goto (8|M0)                          L46248                  L46248                
L46048:
        add (8|M0)               r54.0<1>:d    r47.0<1;1,0>:d    1:w               {Compacted}
        add (8|M0)               acc0.0<1>:d   r77.0<1;1,0>:d    -1:w               {Compacted}
        cmp (8|M0)    (gt)f1.0   null<1>:ud    r77.0<1;1,0>:ud   r54.0<1;1,0>:ud  {I@2}
        not (8|M0)               acc2.0<1>:d   r47.0<1;1,0>:d                  
        and (8|M0)               r84.0<1>:d    r83.0<1;1,0>:d    -2147483648:d              
        add (8|M0)               acc2.0<1>:d   r77.0<1;1,0>:d    acc2.0<1;1,0>:d 
(~f1.0) mov (8|M0)               r54.0<1>:d    acc0.0<1;1,0>:d                 
        shl (8|M0)               r93.0<1>:d    acc2.0<1;1,0>:d   23:w              
        shl (8|M0)               r54.0<1>:d    r45.0<1;1,0>:d    r54.0<1;1,0>:d   {Compacted,I@2}
(~f1.0) mov (8|M0)               r93.0<1>:d    0:w                              
        shr (8|M0)               r54.0<1>:ud   r54.0<1;1,0>:ud   3:w               {I@2}
        and (8|M0)               r54.0<1>:d    r54.0<1;1,0>:d    8388607:d               {I@1}
        bfn.0xFE (8|M0)          r54.0<1>:ud   r84.0<1;0>:ud     r93.0<1;0>:ud     r54.0<1>:ud      {I@1} // s0|s1|s2
        goto (8|M0)                          L46248                  L49336                
L46248:
        join (8|M0)                          L46320                                
L46264:
        shr (8|M0)               r53.0<1>:ud   r45.0<1;1,0>:ud   2:w              
        shl (8|M0)               r52.0<1>:d    r45.0<1;1,0>:d    1:w               {Compacted}
        add (8|M0)               r77.0<1>:d    r77.0<1;1,0>:d    -1:w               {Compacted}
        and (8|M0)               r106.0<1>:d   r53.0<1;1,0>:d    8388607:d               {I@3}
        and (8|M0)               r105.0<1>:d   r52.0<1;1,0>:d    6:w               {Compacted,I@3}
L46320:
        join (8|M0)                          L46712                                
L46336:
        cmp (8|M0)    (eq)f1.1   null<1>:d     r105.0<1;1,0>:d   0:w               {I@2}
(f1.1)  goto (8|M0)                          L46528                  L46528                
L46368:
        cmp (8|M0)    (gt)f1.0   null<1>:ud    r105.0<1;1,0>:ud  0x4:uw             
(f1.0)  goto (8|M0)                          L46480                  L46480                
L46400:
        and (8|M0)    (ne)f0.1   null<1>:d     r106.0<1;1,0>:d   1:w              
(W)     mov (1|M0)               r6.6<1>:hf    0x1:hf                             
(f0.1)  cmp (8|M0)    (eq)f0.1   null<1>:d     r105.0<1;1,0>:d   4:w              
(f0.1)  sel (8|M0)               r121.0<1>:d   r6.6<0;1,0>:w     0:w               {F@1}
        goto (8|M0)                          L46480                  L46560                
L46480:
        join (8|M0)                          L46528                                
L46496:
        mov (8|M0)               r121.0<1>:d   1:w                              
        goto (8|M0)                          L46528                  L46560                
L46528:
        join (8|M0)                          L46560                                
L46544:
        mov (8|M0)               r121.0<1>:d   0:w                              
L46560:
        join (8|M0)                          L46712                                
L46576:
        add (8|M0)               r120.0<1>:d   r106.0<1;1,0>:d   r121.0<1;1,0>:d  {Compacted,I@2}
        and (8|M0)               r83.0<1>:d    r83.0<1;1,0>:d    -2147483648:d              
        cmp (8|M0)    (gt)f1.1   r51.0<1>:ud   r120.0<1;1,0>:ud  0x7FFFFF:ud              {I@2}
        cmp (8|M0)    (gt)f0.1   null<1>:ud    r120.0<1;1,0>:ud  0x7FFFFF:ud             
        add3 (8|M0)              acc0.0<1>:d   r77.0<1;0>:d      -r51.0<1;0>:d     0:w               {I@2}
(~f0.1) sel (8|M0)               r116.0<1>:d   r120.0<1;1,0>:d   0:w              
        shl (8|M0)               r119.0<1>:d   acc0.0<1;1,0>:d   23:w              
        bfn.0xFE (8|M0)          r54.0<1>:ud   r83.0<1;0>:ud     r119.0<1;0>:ud    r116.0<1>:ud     {I@1} // s0|s1|s2
        goto (8|M0)                          L46712                  L49336                
L46712:
        join (8|M0)                          L49224                                
L46728:
        cmp (8|M0)    (eq)f1.0   null<1>:d     r92.0<1;1,0>:d    r63.0<1;1,0>:d  
(W)     mov (1|M0)               r6.7<1>:f     -0.0:f                               {Compacted}
(W)     mov (1|M0)               r6.6<1>:d     8388608:d                              
(f1.0)  goto (8|M0)                          L49144                  L49144                
L46784:
        cmp (8|M0)    (gt)f1.1   null<1>:ud    r92.0<1;1,0>:ud   r63.0<1;1,0>:ud 
(f1.1)  goto (8|M0)                          L46960                  L46960                
L46816:
        cmp (8|M0)    (eq)f1.0   null<1>:d     r112.0<1;1,0>:d   0:w              
(f1.0)  goto (8|M0)                          L46880                  L46880                
L46848:
        add (8|M0)               r51.0<1>:d    r63.0<1;1,0>:d    -r92.0<1;1,0>:d  {Compacted}
        mov (8|M0)               r42.0<1>:f    r33.0<1;1,0>:f                   {Compacted}
        goto (8|M0)                          L46880                  L47064                
L46880:
        join (8|M0)                          L46960                                
L46896:
        or (8|M0)                acc0.0<1>:d   r92.0<1;1,0>:d    8388608:d              
        add (8|M0)               r35.0<1>:d    acc0.0<1;1,0>:d   -r63.0<1;1,0>:d 
        bfn.0xF8 (8|M0)          r54.0<1>:ud   r83.0<1;0>:ud     r6.7<0;0>:ud      r35.0<1>:ud      {A@1} // s0&s1|s2
        goto (8|M0)                          L46960                  L49336                
L46960:
        join (8|M0)                          L47064                                
L46976:
        cmp (8|M0)    (eq)f0.1   null<1>:d     r112.0<1;1,0>:d   0:w              
        add (8|M0)               r51.0<1>:d    r92.0<1;1,0>:d    -r63.0<1;1,0>:d  {Compacted}
(~f0.1) goto (8|M0)                          L47064                  L47064                
L47016:
        and (8|M0)               r50.0<1>:d    r83.0<1;1,0>:d    -2147483648:d              
        bfn.0xFE (8|M0)          r54.0<1>:ud   r50.0<1;0>:ud     r51.0<1;0>:ud     r6.6<0>:ud       {I@1} // s0|s1|s2
        goto (8|M0)                          L47064                  L49336                
L47064:
        join (8|M0)                          L49144                                
L47080:
        and (8|M0)    (eq)f1.1   null<1>:d     r51.0<1;1,0>:d    4194304:d              
(~f1.1) goto (8|M0)                          L48856                  L48856                
L47112:
        and (8|M0)    (eq)f1.0   null<1>:d     r51.0<1;1,0>:d    2097152:d              
(~f1.0) goto (8|M0)                          L48808                  L48808                
L47144:
        and (8|M0)    (eq)f0.1   null<1>:d     r51.0<1;1,0>:d    1048576:d              
(~f0.1) goto (8|M0)                          L48760                  L48760                
L47176:
        and (8|M0)    (eq)f1.1   null<1>:d     r51.0<1;1,0>:d    524288:d              
(~f1.1) goto (8|M0)                          L48712                  L48712                
L47208:
        and (8|M0)    (eq)f1.0   null<1>:d     r51.0<1;1,0>:d    262144:d              
(~f1.0) goto (8|M0)                          L48664                  L48664                
L47240:
        and (8|M0)    (eq)f0.1   null<1>:d     r51.0<1;1,0>:d    131072:d              
(~f0.1) goto (8|M0)                          L48616                  L48616                
L47272:
        and (8|M0)    (eq)f1.1   null<1>:d     r51.0<1;1,0>:d    65536:d              
(~f1.1) goto (8|M0)                          L48568                  L48568                
L47304:
        and (8|M0)    (eq)f1.0   null<1>:d     r51.0<1;1,0>:d    0x8000:uw             
(~f1.0) goto (8|M0)                          L48520                  L48520                
L47336:
        and (8|M0)    (eq)f0.1   null<1>:d     r51.0<1;1,0>:d    16384:w              
(~f0.1) goto (8|M0)                          L48472                  L48472                
L47368:
        and (8|M0)    (eq)f1.1   null<1>:d     r51.0<1;1,0>:d    8192:w              
(~f1.1) goto (8|M0)                          L48424                  L48424                
L47400:
        and (8|M0)    (eq)f1.0   null<1>:d     r51.0<1;1,0>:d    4096:w              
(~f1.0) goto (8|M0)                          L48376                  L48376                
L47432:
        and (8|M0)    (eq)f0.1   null<1>:d     r51.0<1;1,0>:d    2048:w              
(~f0.1) goto (8|M0)                          L48328                  L48328                
L47464:
        and (8|M0)    (eq)f1.1   null<1>:d     r51.0<1;1,0>:d    1024:w              
(~f1.1) goto (8|M0)                          L48280                  L48280                
L47496:
        and (8|M0)    (eq)f1.0   null<1>:d     r51.0<1;1,0>:d    512:w              
(~f1.0) goto (8|M0)                          L48232                  L48232                
L47528:
        and (8|M0)    (eq)f0.1   null<1>:d     r51.0<1;1,0>:d    256:w              
(~f0.1) goto (8|M0)                          L48184                  L48184                
L47560:
        and (8|M0)    (eq)f1.1   null<1>:d     r51.0<1;1,0>:d    128:w              
(~f1.1) goto (8|M0)                          L48136                  L48136                
L47592:
        and (8|M0)    (eq)f1.0   null<1>:d     r51.0<1;1,0>:d    64:w              
(~f1.0) goto (8|M0)                          L48088                  L48088                
L47624:
        and (8|M0)    (eq)f0.1   null<1>:d     r51.0<1;1,0>:d    32:w              
(~f0.1) goto (8|M0)                          L48040                  L48040                
L47656:
        and (8|M0)    (eq)f1.1   null<1>:d     r51.0<1;1,0>:d    16:w              
(~f1.1) goto (8|M0)                          L47992                  L47992                
L47688:
        and (8|M0)    (eq)f1.0   null<1>:d     r51.0<1;1,0>:d    8:w              
(~f1.0) goto (8|M0)                          L47944                  L47944                
L47720:
        and (8|M0)    (eq)f0.1   null<1>:d     r51.0<1;1,0>:d    4:w              
(~f0.1) goto (8|M0)                          L47896                  L47896                
L47752:
        and (8|M0)    (eq)f1.1   null<1>:d     r51.0<1;1,0>:d    2:w              
(~f1.1) goto (8|M0)                          L47848                  L47848                
L47784:
        and (8|M0)    (eq)f0.1   null<1>:d     r51.0<1;1,0>:d    1:w              
(W)     mov (1|M0)               r6.6<1>:hf    -qnan(0x1FF):hf                             
(f0.1)  sel (8|M0)               r52.0<1>:d    r6.6<0;1,0>:w     22:w               {F@1}
        goto (8|M0)                          L47848                  L48888                
L47848:
        join (8|M0)                          L47896                                
L47864:
        mov (8|M0)               r52.0<1>:d    21:w                              
        goto (8|M0)                          L47896                  L48888                
L47896:
        join (8|M0)                          L47944                                
L47912:
        mov (8|M0)               r52.0<1>:d    20:w                              
        goto (8|M0)                          L47944                  L48888                
L47944:
        join (8|M0)                          L47992                                
L47960:
        mov (8|M0)               r52.0<1>:d    19:w                              
        goto (8|M0)                          L47992                  L48888                
L47992:
        join (8|M0)                          L48040                                
L48008:
        mov (8|M0)               r52.0<1>:d    18:w                              
        goto (8|M0)                          L48040                  L48888                
L48040:
        join (8|M0)                          L48088                                
L48056:
        mov (8|M0)               r52.0<1>:d    17:w                              
        goto (8|M0)                          L48088                  L48888                
L48088:
        join (8|M0)                          L48136                                
L48104:
        mov (8|M0)               r52.0<1>:d    16:w                              
        goto (8|M0)                          L48136                  L48888                
L48136:
        join (8|M0)                          L48184                                
L48152:
        mov (8|M0)               r52.0<1>:d    15:w                              
        goto (8|M0)                          L48184                  L48888                
L48184:
        join (8|M0)                          L48232                                
L48200:
        mov (8|M0)               r52.0<1>:d    14:w                              
        goto (8|M0)                          L48232                  L48888                
L48232:
        join (8|M0)                          L48280                                
L48248:
        mov (8|M0)               r52.0<1>:d    13:w                              
        goto (8|M0)                          L48280                  L48888                
L48280:
        join (8|M0)                          L48328                                
L48296:
        mov (8|M0)               r52.0<1>:d    12:w                              
        goto (8|M0)                          L48328                  L48888                
L48328:
        join (8|M0)                          L48376                                
L48344:
        mov (8|M0)               r52.0<1>:d    11:w                              
        goto (8|M0)                          L48376                  L48888                
L48376:
        join (8|M0)                          L48424                                
L48392:
        mov (8|M0)               r52.0<1>:d    10:w                              
        goto (8|M0)                          L48424                  L48888                
L48424:
        join (8|M0)                          L48472                                
L48440:
        mov (8|M0)               r52.0<1>:d    9:w                              
        goto (8|M0)                          L48472                  L48888                
L48472:
        join (8|M0)                          L48520                                
L48488:
        mov (8|M0)               r52.0<1>:d    8:w                              
        goto (8|M0)                          L48520                  L48888                
L48520:
        join (8|M0)                          L48568                                
L48536:
        mov (8|M0)               r52.0<1>:d    7:w                              
        goto (8|M0)                          L48568                  L48888                
L48568:
        join (8|M0)                          L48616                                
L48584:
        mov (8|M0)               r52.0<1>:d    6:w                              
        goto (8|M0)                          L48616                  L48888                
L48616:
        join (8|M0)                          L48664                                
L48632:
        mov (8|M0)               r52.0<1>:d    5:w                              
        goto (8|M0)                          L48664                  L48888                
L48664:
        join (8|M0)                          L48712                                
L48680:
        mov (8|M0)               r52.0<1>:d    4:w                              
        goto (8|M0)                          L48712                  L48888                
L48712:
        join (8|M0)                          L48760                                
L48728:
        mov (8|M0)               r52.0<1>:d    3:w                              
        goto (8|M0)                          L48760                  L48888                
L48760:
        join (8|M0)                          L48808                                
L48776:
        mov (8|M0)               r52.0<1>:d    2:w                              
        goto (8|M0)                          L48808                  L48888                
L48808:
        join (8|M0)                          L48856                                
L48824:
        mov (8|M0)               r52.0<1>:d    1:w                              
        goto (8|M0)                          L48856                  L48888                
L48856:
        join (8|M0)                          L48888                                
L48872:
        mov (8|M0)               r52.0<1>:d    0:w                              
L48888:
        join (8|M0)                          L49144                                
L48904:
        add (8|M0)               r109.0<1>:d   r52.0<1;1,0>:d    1:w               {Compacted,I@2}
        cmp (8|M0)    (gt)f1.0   null<1>:ud    r77.0<1;1,0>:ud   r109.0<1;1,0>:ud {I@1}
(f1.0)  goto (8|M0)                          L49000                  L49000                
L48944:
        add (8|M0)               acc0.0<1>:d   r77.0<1;1,0>:d    -1:w               {Compacted}
        mov (8|M0)               r95.0<1>:d    0:w                              
        shl (8|M0)               r101.0<1>:d   r51.0<1;1,0>:d    acc0.0<1;1,0>:d 
        goto (8|M0)                          L49000                  L49088                
L49000:
        join (8|M0)                          L49088                                
L49016:
        not (8|M0)               acc0.0<1>:d   r52.0<1;1,0>:d                  
        shl (8|M0)               r48.0<1>:d    r51.0<1;1,0>:d    r109.0<1;1,0>:d  {Compacted}
        add (8|M0)               acc0.0<1>:d   r77.0<1;1,0>:d    acc0.0<1;1,0>:d 
        and (8|M0)               r101.0<1>:d   r48.0<1;1,0>:d    8388607:d               {I@2}
        shl (8|M0)               r95.0<1>:d    acc0.0<1;1,0>:d   23:w              
L49088:
        join (8|M0)                          L49144                                
L49104:
        shl (8|M0)               r47.0<1>:d    r42.0<1;1,0>:d    31:w               {Compacted}
        bfn.0xFE (8|M0)          r54.0<1>:ud   r47.0<1;0>:ud     r95.0<1;0>:ud     r101.0<1>:ud     {I@1} // s0|s1|s2
        goto (8|M0)                          L49144                  L49336                
L49144:
        join (8|M0)                          L49224                                
L49160:
        cmp (8|M0)    (eq)f0.1   null<1>:d     r112.0<1;1,0>:d   0:w              
        bfn.0xF8 (8|M0)          r76.0<1>:ud   r83.0<1;0>:ud     r6.7<0;0>:ud      r6.6<0>:ud       // s0&s1|s2
(f0.1)  sel (8|M0)               r54.0<1>:f    r76.0<1;1,0>:f    0.0:f               {I@1}
        goto (8|M0)                          L49224                  L49336                
L49224:
        join (8|M0)                          L49336                                
L49240:
        cmp (8|M0)    (gt)f0.1   null<1>:ud    r92.0<1;1,0>:ud   r63.0<1;1,0>:ud  {F@1}
        add (8|M0)               acc0.0<1>:d   r63.0<1;1,0>:d    -r92.0<1;1,0>:d 
        add (8|M0)               r65.0<1>:d    r92.0<1;1,0>:d    -r63.0<1;1,0>:d  {Compacted}
(f0.1)  sel (8|M0)               acc2.0<1>:d   r42.0<1;1,0>:d    r33.0<1;1,0>:d  
(~f0.1) mov (8|M0)               r65.0<1>:d    acc0.0<1;1,0>:d                 
        shl (8|M0)               r101.0<1>:d   acc2.0<1;1,0>:d   31:w              
        or (8|M0)                r54.0<1>:d    r101.0<1;1,0>:d   r65.0<1;1,0>:d   {Compacted,I@1}
L49336:
        join (8|M0)                          L49352                                
L49352:
        mov (8|M0)               r120.0<1>:f   r54.0<1;1,0>:f                   {Compacted,I@2}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        ret (8|M0)                           r6.4                             {A@1}
L49408:
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
