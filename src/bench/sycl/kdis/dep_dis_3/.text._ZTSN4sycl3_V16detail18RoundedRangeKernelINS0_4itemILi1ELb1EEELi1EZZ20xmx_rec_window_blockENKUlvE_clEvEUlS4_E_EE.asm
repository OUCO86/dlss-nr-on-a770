L0:
(W)     mov (8|M0)               r127.0<1>:ud  0x0:ud                             
(W)     and (1|M0)               r127.2<1>:ud  r0.0<0;1,0>:ud    0xFFFFFFC0:ud             
(W)     and (1|M0)               r127.0<1>:uw  r0.4<0;1,0>:uw    0xFF:uw             
(W)     add (1|M0)               r127.2<1>:ud  r127.2<0;1,0>:ud  0x20:ud              {I@2}
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
(W)     send.dc0 (8|M0)          r5       r127    null:0  0x0            0x021842FD           {A@1,$2} // wr:1h+0, rd:1; oword aligned block read x2
(W)     mov (8|M0)               r2.0<1>:ud    r0.0<1;1,0>:ud                   {$0.dst}
(W)     or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x4C0:uw              {A@1}
(W)     mul (1|M0)               acc0.0<1>:ud  r4.3<0;1,0>:ud    r2.2<0;1,0>:uw   {A@1}
(W)     mach (1|M0)              r7.0<1>:ud    r4.3<0;1,0>:ud    r2.1<0;1,0>:ud   {AccWrEn}
        mov (16|M0)              r8.0<1>:d     r1.0<1;1,0>:uw                  
(W)     mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
(W)     mov (2|M0)               r3.0<1>:d     r4.6<1;1,0>:d                    {$1.dst}
        addc (8|M0)              r10.0<1>:ud   r6.0<0;1,0>:ud    r8.0<1;1,0>:ud   {AccWrEn,Compacted,I@2}
        add (8|M0)               r12.0<1>:ud   acc0.0<1;1,0>:ud  r7.0<0;1,0>:ud  
        addc (8|M8)              r11.0<1>:ud   r6.0<0;1,0>:ud    r9.0<1;1,0>:ud   {AccWrEn}
        add (8|M8)               r13.0<1>:ud   acc0.0<1;1,0>:ud  r7.0<0;1,0>:ud  
        addc (8|M0)              r14.0<1>:ud   r10.0<1;1,0>:ud   r4.0<0;1,0>:ud   {AccWrEn,Compacted,I@4}
        add (8|M0)               r16.0<1>:ud   acc0.0<1;1,0>:ud  r12.0<1;1,0>:ud  {I@4}
        addc (8|M8)              r15.0<1>:ud   r11.0<1;1,0>:ud   r4.0<0;1,0>:ud   {AccWrEn,I@4}
        cmp (16|M0)   (lt)f0.1   null<1>:d     r14.0<1;1,0>:ud   r3.0<0;1,0>:ud   {I@1}
        add (8|M8)               r17.0<1>:ud   acc0.0<1;1,0>:ud  r13.0<1;1,0>:ud 
(f0.1)  cmp (16|M0)   (eq)f0.1   null<1>:d     r16.0<1;1,0>:d    r3.1<0;1,0>:d    {I@1}
(~f0.1) cmp (16|M0)   (lt)f0.1   null<1>:d     r16.0<1;1,0>:ud   r3.1<0;1,0>:ud  
(~f0.1) goto (16|M0)                         L904                  L904                
L536:
        mov (16|M0)              r18.0<1>:f    r14.0<1;1,0>:f                   {Compacted}
        mov (16|M0)              r20.0<1>:d    r16.0<1;1,0>:d                  
(W)     mov (2|M0)               r3.2<1>:d     r5.0<1;1,0>:d                    {$2.dst}
L576:
        shl (16|M0)              r22.0<1>:d    r18.0<1;1,0>:d    1:w               {Compacted,F@1}
        addc (8|M0)              r28.0<1>:ud   r22.0<1;1,0>:ud   r3.2<0;1,0>:ud   {AccWrEn,Compacted,I@1}
        shr (16|M0)              r24.0<1>:ud   r18.0<1;1,0>:ud   31:w              
        mov (8|M0)               r30.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        addc (8|M8)              r29.0<1>:ud   r23.0<1;1,0>:ud   r3.2<0;1,0>:ud   {AccWrEn}
        shl (16|M0)              r26.0<1>:d    r20.0<1;1,0>:d    1:w               {Compacted}
        mov (8|M8)               r31.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        addc (8|M0)              r38.0<1>:ud   r18.0<1;1,0>:ud   r5.4<0;1,0>:ud   {AccWrEn,Compacted}
        or (16|M0)               r26.0<1>:d    r26.0<1;1,0>:d    r24.0<1;1,0>:d   {Compacted,I@3}
        add (8|M0)               r40.0<1>:ud   acc0.0<1;1,0>:ud  r20.0<1;1,0>:ud 
        addc (8|M8)              r39.0<1>:ud   r19.0<1;1,0>:ud   r5.4<0;1,0>:ud   {AccWrEn}
        mov (16|M0)              r36.0<1>:ud   0x0:uw                              {$3.src}
        cmp (16|M0)   (lt)f0.0   null<1>:d     r38.0<1;1,0>:ud   r3.0<0;1,0>:ud   {I@2}
        add (8|M8)               r41.0<1>:ud   acc0.0<1;1,0>:ud  r21.0<1;1,0>:ud 
        add3 (8|M0)              r32.1<2>:ud   r30.0<1;0>:ud     r26.0<1;0>:ud     r3.3<0>:ud      
(f0.0)  cmp (16|M0)   (eq)f0.0   null<1>:d     r40.0<1;1,0>:d    r3.1<0;1,0>:d    {I@2}
        add3 (8|M8)              r34.1<2>:ud   r31.0<1;0>:ud     r27.0<1;0>:ud     r3.3<0>:ud      
        mov (8|M0)               r32.0<2>:d    r28.0<1;1,0>:d                  
(~f0.0) cmp (16|M0)   (lt)f0.0   null<1>:d     r40.0<1;1,0>:ud   r3.1<0;1,0>:ud  
        mov (8|M8)               r34.0<2>:d    r29.0<1;1,0>:d                  
        send.ugm (16|M0)         null     r32     r36:2   0x0            0x080E0B84           {A@1,$3} // wr:4+2, rd:0; store.ugm.d16u32.a64.wb.wb
(~f0.0) goto (16|M0)                         L904                  L904                
L872:
(f0.0)  sel (16|M0)              r18.0<1>:d    r38.0<1;1,0>:d    r14.0<1;1,0>:d   {Compacted}
(f0.0)  sel (16|M0)              r20.0<1>:d    r40.0<1;1,0>:d    r16.0<1;1,0>:d   {Compacted}
(W)     jmpi                                 L576                                
L904:
        join (16|M0)                         L920                                
L920:
(W)     mov (8|M0)               r127.0<1>:f   r2.0<1;1,0>:f                    {Compacted,$2.src}
(W)     send.gtwy (1|M0)         null     r127    null:0  0x0            0x02000010           {EOT,A@1} // wr:1+0, rd:0; end of thread
L944:
        nop                    
(W)     mov (16|M0)              null<1>:ud    0x9E09665A:ud                             
(W)     mov (16|M0)              null<1>:ud    0xA6E09A48:ud                             
(W)     mov (16|M0)              null<1>:ud    0x0:ud                             
(W)     mov (16|M0)              null<1>:ud    0x60:ud                             
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
