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
(W)     mul (1|M0)               acc0.0<1>:ud  r4.3<0;1,0>:ud    r2.2<0;1,0>:uw   {A@1}
(W)     mach (1|M0)              r8.0<1>:ud    r4.3<0;1,0>:ud    r2.1<0;1,0>:ud   {AccWrEn}
        mov (16|M0)              r9.0<1>:d     r1.0<1;1,0>:uw                  
(W)     mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
(W)     mov (2|M0)               r3.0<1>:d     r4.6<1;1,0>:d                    {$1.dst}
        addc (8|M0)              r11.0<1>:ud   r7.0<0;1,0>:ud    r9.0<1;1,0>:ud   {AccWrEn,Compacted,I@2}
        add (8|M0)               r13.0<1>:ud   acc0.0<1;1,0>:ud  r8.0<0;1,0>:ud  
        addc (8|M8)              r12.0<1>:ud   r7.0<0;1,0>:ud    r10.0<1;1,0>:ud  {AccWrEn}
        add (8|M8)               r14.0<1>:ud   acc0.0<1;1,0>:ud  r8.0<0;1,0>:ud  
        addc (8|M0)              r15.0<1>:ud   r11.0<1;1,0>:ud   r4.0<0;1,0>:ud   {AccWrEn,Compacted,I@4}
        add (8|M0)               r17.0<1>:ud   acc0.0<1;1,0>:ud  r13.0<1;1,0>:ud  {I@4}
        addc (8|M8)              r16.0<1>:ud   r12.0<1;1,0>:ud   r4.0<0;1,0>:ud   {AccWrEn,I@4}
        cmp (16|M0)   (lt)f0.1   null<1>:d     r15.0<1;1,0>:ud   r3.0<0;1,0>:ud   {I@1}
        add (8|M8)               r18.0<1>:ud   acc0.0<1;1,0>:ud  r14.0<1;1,0>:ud 
(f0.1)  cmp (16|M0)   (eq)f0.1   null<1>:d     r17.0<1;1,0>:d    r3.1<0;1,0>:d    {I@1}
(~f0.1) cmp (16|M0)   (lt)f0.1   null<1>:d     r17.0<1;1,0>:ud   r3.1<0;1,0>:ud  
(~f0.1) goto (16|M0)                         L1152                  L1152                
L536:
        mov (16|M0)              r19.0<1>:f    r15.0<1;1,0>:f                   {Compacted}
        mov (16|M0)              r21.0<1>:f    r17.0<1;1,0>:f                   {Compacted}
(W)     mov (2|M0)               r3.2<1>:d     r5.0<1;1,0>:d                    {$2.dst}
(W)     mov (2|M0)               r3.4<1>:d     r5.2<1;1,0>:d                   
(W)     mov (1|M0)               r3.6<1>:d     7:w                              
L600:
        shl (16|M0)              r23.0<1>:d    r19.0<1;1,0>:d    4:w               {Compacted,F@2}
        shr (16|M0)              r25.0<1>:ud   r19.0<1;1,0>:ud   28:w              
        shl (16|M0)              r27.0<1>:d    r21.0<1;1,0>:d    4:w               {Compacted,F@1}
        and (16|M0)              r23.0<1>:d    r23.0<1;1,0>:d    -64:w               {Compacted,I@3}
        shl (16|M0)              r35.0<1>:d    r19.0<1;1,0>:d    2:w               {Compacted}
        bfn.0xE0 (16|M0)         r29.0<1>:ud   r27.0<1;0>:ud     r25.0<1;0>:ud     r3.6<0>:ud       {I@3} // (s0|s1)&s2
        addc (8|M0)              r31.0<1>:ud   r23.0<1;1,0>:ud   r3.4<0;1,0>:ud   {AccWrEn,Compacted,I@3}
        and (16|M0)              r43.0<1>:d    r35.0<1;1,0>:d    12:w               {Compacted,I@3}
        add3 (8|M0)              r33.0<1>:ud   acc0.0<1;0>:ud    r29.0<1;0>:ud     r3.5<0>:ud       {I@3}
        addc (8|M8)              r32.0<1>:ud   r24.0<1;1,0>:ud   r3.4<0;1,0>:ud   {AccWrEn}
        shr (16|M0)              r37.0<1>:ud   r19.0<1;1,0>:ud   30:w              
        add3 (8|M8)              r34.0<1>:ud   acc0.0<1;0>:ud    r30.0<1;0>:ud     r3.5<0>:ud      
        addc (8|M0)              r45.0<1>:ud   r31.0<1;1,0>:ud   r43.0<1;1,0>:ud  {AccWrEn,Compacted,I@5}
        shl (16|M0)              r39.0<1>:d    r21.0<1;1,0>:d    2:w               {Compacted}
        mov (8|M0)               r47.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        addc (8|M8)              r46.0<1>:ud   r32.0<1;1,0>:ud   r44.0<1;1,0>:ud  {AccWrEn,I@6}
        add (8|M0)               r49.1<2>:ud   r47.0<1;1,0>:ud   r33.0<1;1,0>:ud  {Compacted,I@2}
        mov (8|M8)               r48.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        addc (8|M0)              r55.0<1>:ud   r35.0<1;1,0>:ud   r3.2<0;1,0>:ud   {AccWrEn,Compacted}
        mov (8|M0)               r49.0<2>:d    r45.0<1;1,0>:d                  
        mov (8|M0)               r57.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        addc (8|M8)              r56.0<1>:ud   r36.0<1;1,0>:ud   r3.2<0;1,0>:ud   {AccWrEn}
        add (8|M8)               r51.1<2>:ud   r48.0<1;1,0>:ud   r34.0<1;1,0>:ud  {Compacted,I@5}
        mov (8|M8)               r58.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        addc (8|M0)              r63.0<1>:ud   r19.0<1;1,0>:ud   r6.0<0;1,0>:ud   {AccWrEn,Compacted}
        mov (8|M8)               r51.0<2>:d    r46.0<1;1,0>:d                  
        add (8|M0)               r65.0<1>:ud   acc0.0<1;1,0>:ud  r21.0<1;1,0>:ud 
        addc (8|M8)              r64.0<1>:ud   r20.0<1;1,0>:ud   r6.0<0;1,0>:ud   {AccWrEn}
        send.ugm (16|M0)         r53      r49     null:0  0x0            0x08280580           {A@3,$4} // wr:4+0, rd:2; load.ugm.d32.a64.ca.ca
        cmp (16|M0)   (lt)f0.0   null<1>:d     r63.0<1;1,0>:ud   r3.0<0;1,0>:ud   {I@1}
        add (8|M8)               r66.0<1>:ud   acc0.0<1;1,0>:ud  r22.0<1;1,0>:ud 
        or (16|M0)               r41.0<1>:d    r39.0<1;1,0>:d    r37.0<1;1,0>:d   {Compacted}
(f0.0)  cmp (16|M0)   (eq)f0.0   null<1>:d     r65.0<1;1,0>:d    r3.1<0;1,0>:d    {I@2}
        sync.nop                             null                             {Compacted,$3.src}
        add3 (8|M0)              r59.1<2>:ud   r57.0<1;0>:ud     r41.0<1;0>:ud     r3.3<0>:ud       {I@2}
        add3 (8|M8)              r61.1<2>:ud   r58.0<1;0>:ud     r42.0<1;0>:ud     r3.3<0>:ud      
(~f0.0) cmp (16|M0)   (lt)f0.0   null<1>:d     r65.0<1;1,0>:ud   r3.1<0;1,0>:ud  
        mov (8|M0)               r59.0<2>:d    r55.0<1;1,0>:d                  
        mov (8|M8)               r61.0<2>:d    r56.0<1;1,0>:d                  
        sync.nop                             null                             {Compacted,$4.dst}
        send.ugm (16|M0)         null     r59     r53:2   0x0            0x080E0584           {A@1,$3} // wr:4+2, rd:0; store.ugm.d32.a64.wb.wb
(~f0.0) goto (16|M0)                         L1152                  L1152                
L1120:
(f0.0)  sel (16|M0)              r19.0<1>:d    r63.0<1;1,0>:d    r15.0<1;1,0>:d   {Compacted}
(f0.0)  sel (16|M0)              r21.0<1>:d    r65.0<1;1,0>:d    r17.0<1;1,0>:d   {Compacted}
(W)     jmpi                                 L600                                
L1152:
        join (16|M0)                         L1168                                
L1168:
(W)     mov (8|M0)               r127.0<1>:f   r2.0<1;1,0>:f                    {Compacted,$2.src}
(W)     send.gtwy (1|M0)         null     r127    null:0  0x0            0x02000010           {EOT,A@1} // wr:1+0, rd:0; end of thread
L1192:
        nop                    
(W)     mov (16|M0)              null<1>:ud    0x6F9278B:ud                             
(W)     mov (16|M0)              null<1>:ud    0x6180031B:ud                             
(W)     mov (16|M0)              null<1>:ud    0x0:ud                             
(W)     mov (16|M0)              null<1>:ud    0x1D:ud                             
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
