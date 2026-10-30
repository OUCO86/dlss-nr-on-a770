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
(W)     mov (2|M0)               r18.0<1>:ud   r3.2<1;1,0>:ud                   {$1.dst}
        and (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   -1265:w               {A@1}
        or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   1216:w               {A@1}
        mul (1|M0)               acc0.0<1>:ud  r2.0<0;1,0>:ud    r0.2<0;1,0>:uw   {A@1}
        mach (1|M0)              r5.0<1>:ud    r2.0<0;1,0>:ud    r0.1<0;1,0>:ud   {AccWrEn}
        mov (1|M0)               r1.2<1>:d     r1.0<0;1,0>:uw                   {$0.dst}
        mov (1|M0)               r4.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        send.ugm (1|M0)          r19      r18     null:0  0x0            0x0240D780           {A@7,$2} // wr:1+0, rd:4; load.ugm.d64x16t.a64
        addc (1|M0)              r6.0<1>:ud    r4.0<0;1,0>:ud    r1.2<0;1,0>:ud   {AccWrEn,I@1}
(W)     mov (8|M0)               r127.0<1>:f   r0.0<1;1,0>:f                    {Compacted}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        shl (1|M0)               r2.3<1>:d     r6.0<0;1,0>:d     5:w               {Compacted,I@2}
        add3 (1|M0)              r1.5<1>:d     r7.0<0;0>:d       r5.0<0;0>:d       0:w               {I@2}
        shr (1|M0)               r1.7<1>:ud    r6.0<0;1,0>:ud    0x1B:uw             
        shl (1|M0)               r6.1<1>:d     r2.3<0;1,0>:d     2:w               {I@3}
        shl (1|M0)               r1.6<1>:d     r1.5<0;1,0>:d     5:w               {I@3}
        addc (1|M0)              r8.0<1>:ud    r2.6<0;1,0>:ud    r6.1<0;1,0>:ud   {AccWrEn,I@2}
        or (1|M0)                r2.4<1>:d     r1.6<0;1,0>:d     r1.7<0;1,0>:d    {I@2}
        shr (1|M0)               r3.6<1>:ud    r2.3<0;1,0>:ud    0x1E:uw             
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        shl (1|M0)               r2.5<1>:d     r2.4<0;1,0>:d     2:w               {I@3}
        addc (1|M0)              r15.0<1>:ud   r3.0<0;1,0>:ud    r6.1<0;1,0>:ud   {AccWrEn}
        or (1|M0)                r6.2<1>:d     r2.5<0;1,0>:d     r3.6<0;1,0>:d    {I@2}
        mov (1|M0)               r16.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r10.0<1>:f    r8.0<0;1,0>:f                    {Compacted}
        mov (1|M0)               r17.0<1>:f    r15.0<0;1,0>:f                   {Compacted,I@3}
        add3 (1|M0)              r10.1<1>:d    r9.0<0;0>:d       r2.7<0;0>:d       r6.2<0>:d        {I@2}
        add3 (1|M0)              r17.1<1>:d    r16.0<0;0>:d      r3.1<0;0>:d       r6.2<0>:d        {I@2}
        send.ugm (1|M0)          r11      r10     null:0  0x0            0x0240D780           {A@2,$3} // wr:1+0, rd:4; load.ugm.d64x16t.a64
        send.ugm (1|M0)          r26      r17     null:0  0x0            0x0240D780           {A@1,$4} // wr:1+0, rd:4; load.ugm.d64x16t.a64
        addc (1|M0)              r23.0<1>:ud   r3.4<0;1,0>:ud    r6.1<0;1,0>:ud   {AccWrEn}
        mov (1|M0)               r24.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r25.0<1>:f    r23.0<0;1,0>:f                   {Compacted,I@2}
        add3 (1|M0)              r25.1<1>:d    r24.0<0;0>:d      r3.5<0;0>:d       r6.2<0>:d        {I@1}
        sync.allwr                           ($3,$4)                
        mad (16|M0)              r26.0<1>:f    r26.0<1;0>:f      r19.0<1;0>:f      r11.0<1>:f       {Compacted,$2.dst}
        mad (16|M0)              r28.0<1>:f    r28.0<1;0>:f      r21.0<1;0>:f      r13.0<1>:f       {Compacted}
        send.ugm (1|M0)          null     r25     r26:4   0x0            0x0200D784           {A@1,$5} // wr:1+4, rd:0; store.ugm.d64x16t.a64
(W)     send.ugm (1|M0)          r30      r0      null:0  0x0            0x0210641F           {$6} // wr:1+0, rd:1; fence invalid flush type scoped to tile
(W)     mov (8|M0)               null<1>:ud    r30.0<1;1,0>:ud                  {$6.dst}
(W)     send.gtwy (1|M0)         null     r127    null:0  0x0            0x02000010           {EOT,A@1} // wr:1+0, rd:0; end of thread
L736:
        nop                    
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
