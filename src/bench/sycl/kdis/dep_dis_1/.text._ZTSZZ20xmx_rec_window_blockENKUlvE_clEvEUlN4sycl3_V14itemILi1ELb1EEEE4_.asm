L0:
(W)     mov (8|M0)               r127.0<1>:ud  0x0:ud                              {A@1}
(W)     and (1|M0)               r127.2<1>:ud  r0.0<0;1,0>:ud    0xFFFFFFC0:ud             
(W)     and (1|M0)               r127.0<1>:uw  r0.4<0;1,0>:uw    0xFF:uw             
(W)     add (1|M0)               r127.2<1>:ud  r127.2<0;1,0>:ud  0x40:ud              {I@2}
(W)     mad (1|M0)               r127.2<1>:ud  r127.2<0;0>:ud    r127.0<0;0>:uw    0x20:uw              {I@1}
(W)     send.dc0 (8|M0)          r1       r127    null:0  0x0            0x021842FD           {A@1,$0} // wr:1h+0, rd:1; oword aligned block read x2
        nop                    
        nop                    
(W)     mov (8|M0)               r127.0<1>:ud  0x0:ud                              {$0.src}
(W)     and (1|M0)               r127.2<1>:ud  r0.0<0;1,0>:ud    0xFFFFFFC0:ud             
(W)     send.dc0 (8|M0)          r2       r127    null:0  0x0            0x022843FD           {A@1,$1} // wr:1h+0, rd:2; oword aligned block read x4
        and (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   -1265:w               {A@1}
        or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   1216:w               {A@1}
        sync.nop                             null                             {Compacted,A@1}
        sync.nop                             null                             {Compacted,$1.dst}
        mul (1|M0)               acc0.0<1>:ud  r2.0<0;1,0>:ud    r0.2<0;1,0>:uw   {A@1}
        mach (1|M0)              r5.0<1>:ud    r2.0<0;1,0>:ud    r0.1<0;1,0>:ud   {AccWrEn}
        mov (1|M0)               r1.2<1>:d     r1.0<0;1,0>:uw                   {$0.dst}
        mov (1|M0)               r4.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
(W)     mov (8|M0)               r127.0<1>:f   r0.0<1;1,0>:f                    {Compacted}
        addc (1|M0)              r6.0<1>:ud    r4.0<0;1,0>:ud    r1.2<0;1,0>:ud   {AccWrEn,I@1}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        shr (1|M0)               r1.7<1>:ud    r6.0<0;1,0>:ud    0x1B:uw              {I@2}
        add3 (1|M0)              r1.5<1>:d     r7.0<0;0>:d       r5.0<0;0>:d       0:w               {I@2}
        shl (1|M0)               r2.3<1>:d     r6.0<0;1,0>:d     5:w               {Compacted}
        shl (1|M0)               r1.6<1>:d     r1.5<0;1,0>:d     5:w               {I@2}
        shl (1|M0)               r3.3<1>:d     r2.3<0;1,0>:d     2:w               {Compacted,I@2}
        or (1|M0)                r2.4<1>:d     r1.6<0;1,0>:d     r1.7<0;1,0>:d    {I@2}
        shr (1|M0)               r3.2<1>:ud    r2.3<0;1,0>:ud    0x1E:uw             
        addc (1|M0)              r8.0<1>:ud    r2.6<0;1,0>:ud    r3.3<0;1,0>:ud   {AccWrEn,I@3}
        shl (1|M0)               r2.5<1>:d     r2.4<0;1,0>:d     2:w               {I@3}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        or (1|M0)                r3.4<1>:d     r2.5<0;1,0>:d     r3.2<0;1,0>:d    {I@2}
        mov (1|M0)               r10.0<1>:f    r8.0<0;1,0>:f                    {Compacted}
        add3 (1|M0)              r10.1<1>:d    r9.0<0;0>:d       r2.7<0;0>:d       r3.4<0>:d        {I@1}
        shl (1|M0)               r6.1<1>:d     r2.3<0;1,0>:d     1:w              
        send.ugm (1|M0)          r11      r10     null:0  0x0            0x0240D780           {A@1,$2} // wr:1+0, rd:4; load.ugm.d64x16t.a64
        shr (1|M0)               r3.6<1>:ud    r2.3<0;1,0>:ud    0x1F:uw             
        shl (1|M0)               r3.5<1>:d     r2.4<0;1,0>:d     1:w              
        addc (1|M0)              r15.0<1>:ud   r3.0<0;1,0>:ud    r6.1<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r6.2<1>:d     r3.5<0;1,0>:d     r3.6<0;1,0>:d    {I@2}
        mov (1|M0)               r16.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r17.0<1>:f    r15.0<0;1,0>:f                   {Compacted,I@3}
        add3 (1|M0)              r17.1<1>:d    r16.0<0;0>:d      r3.1<0;0>:d       r6.2<0>:d        {I@1}
        sel (16|M0)   (lt)f0.0   r32.0<1>:f    (abs)r11.0<1;1,0>:f  448.0:f            {Compacted,$2.dst}
        sel (16|M0)   (lt)f0.0   r34.0<1>:f    (abs)r13.0<1;1,0>:f  448.0:f            {Compacted}
        shr (16|M0)              r18.0<1>:ud   r32.0<1;1,0>:ud   0x17:uw              {F@2}
        shr (16|M0)              r20.0<1>:ud   r34.0<1;1,0>:ud   0x17:uw              {F@1}
        sel (16|M0)   (ge)f0.0   r22.0<2>:ub   r18.0<4;1,0>:ub   0x79:uw              {I@2}
        sel (16|M0)   (ge)f0.0   r23.0<2>:ub   r20.0<4;1,0>:ub   0x79:uw              {I@2}
        mov (16|M0)              r28.0<1>:d    r22.0<2;1,0>:ub                  {I@2}
        mov (16|M0)              r30.0<1>:d    r23.0<2;1,0>:ub                  {I@2}
        shl (16|M0)              r28.0<1>:d    r28.0<1;1,0>:d    23:w               {Compacted,I@2}
        shl (16|M0)              r30.0<1>:d    r30.0<1;1,0>:d    23:w               {Compacted,I@2}
        add (16|M0)              r24.0<1>:d    r28.0<1;1,0>:d    -25165824:d               {I@2}
        add (16|M0)              r26.0<1>:d    r30.0<1;1,0>:d    -25165824:d               {I@2}
        add (16|M0)              r28.0<1>:d    -r28.0<1;1,0>:d   -2139095040:d              
        add (16|M0)              r30.0<1>:d    -r30.0<1;1,0>:d   -2139095040:d              
        mul (16|M0)              acc0.0<1>:f   r32.0<1;1,0>:f    r28.0<1;1,0>:f   {Compacted,I@2}
        mul (16|M0)              acc2.0<1>:f   r34.0<1;1,0>:f    r30.0<1;1,0>:f   {Compacted,I@1}
        rnde (16|M0)             acc0.0<1>:f   acc0.0<1;1,0>:f                 
        rnde (16|M0)             acc2.0<1>:f   acc2.0<1;1,0>:f                 
        cmp (16|M0)   (lt)f0.1   null<1>:f     r11.0<1;1,0>:f    0.0:f              
        cmp (16|M0)   (lt)f0.0   null<1>:f     r13.0<1;1,0>:f    0.0:f               {Compacted}
        mul (16|M0)              acc0.0<1>:f   acc0.0<1;1,0>:f   r24.0<1;1,0>:f   {Compacted}
        mul (16|M0)              acc2.0<1>:f   acc2.0<1;1,0>:f   r26.0<1;1,0>:f   {Compacted}
        mov (16|M0)              r36.0<1>:f    (abs)acc0.0<1;1,0>:f             {Compacted}
        mov (16|M0)              r38.0<1>:f    (abs)acc2.0<1;1,0>:f             {Compacted}
(f0.1)  or (16|M0)               r36.0<1>:d    r36.0<1;1,0>:d    -2147483648:d               {F@2}
(f0.0)  or (16|M0)               r38.0<1>:d    r38.0<1;1,0>:d    -2147483648:d               {F@1}
        mov (8|M0)               r40.0<1>:hf   r36.0<1;1,0>:f                   {I@2}
        mov (8|M0)               r40.8<1>:hf   r37.0<1;1,0>:f                  
        mov (8|M0)               r41.0<1>:hf   r38.0<1;1,0>:f                   {I@1}
        mov (8|M0)               r41.8<1>:hf   r39.0<1;1,0>:f                  
        send.ugm (1|M0)          null     r17     r40:2   0x0            0x0200C784           {A@1,$3} // wr:1+2, rd:0; store.ugm.d64x8t.a64
(W)     send.ugm (1|M0)          r42      r0      null:0  0x0            0x0210641F           {$4} // wr:1+0, rd:1; fence invalid flush type scoped to tile
(W)     mov (8|M0)               null<1>:ud    r42.0<1;1,0>:ud                  {$4.dst}
(W)     send.gtwy (1|M0)         null     r127    null:0  0x0            0x02000010           {EOT,A@1} // wr:1+0, rd:0; end of thread
L1072:
        nop                    
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
