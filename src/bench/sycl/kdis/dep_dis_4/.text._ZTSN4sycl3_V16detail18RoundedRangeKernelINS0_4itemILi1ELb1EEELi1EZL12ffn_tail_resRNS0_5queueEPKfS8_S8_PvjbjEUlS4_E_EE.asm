L0:
(W)     mov (8|M0)               r127.0<1>:ud  0x0:ud                              {A@1}
(W)     and (1|M0)               r127.2<1>:ud  r0.0<0;1,0>:ud    0xFFFFFFC0:ud             
(W)     and (1|M0)               r127.0<1>:uw  r0.4<0;1,0>:uw    0xFF:uw             
(W)     add (1|M0)               r127.2<1>:ud  r127.2<0;1,0>:ud  0x60:ud              {I@2}
(W)     mad (1|M0)               r127.2<1>:ud  r127.2<0;0>:ud    r127.0<0;0>:uw    0x20:uw              {I@1}
(W)     send.dc0 (8|M0)          r1       r127    null:0  0x0            0x021842FD           {A@1,$0} // wr:1h+0, rd:1; oword aligned block read x2
        nop                    
        nop                    
(W)     mov (8|M0)               r127.0<1>:ud  0x0:ud                              {$0.src}
(W)     and (1|M0)               r127.2<1>:ud  r0.0<0;1,0>:ud    0xFFFFFFC0:ud             
(W)     send.dc0 (8|M0)          r2       r127    null:0  0x0            0x022843FD           {A@1,$1} // wr:1h+0, rd:2; oword aligned block read x4
(W)     add (1|M0)               r127.2<1>:ud  r127.2<0;1,0>:ud  0x40:uw              {$1.src}
(W)     send.dc0 (8|M0)          r4       r127    null:0  0x0            0x021842FD           {A@1,$2} // wr:1h+0, rd:1; oword aligned block read x2
(W)     mov (2|M0)               r5.0<1>:ud    r4.4<1;1,0>:ud                   {$2.dst}
        and (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   -1265:w               {A@1}
        or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   1216:w               {A@1}
        sync.nop                             null                             {Compacted,A@1}
        sync.nop                             null                             {Compacted,$1.dst}
        mul (1|M0)               acc0.0<1>:ud  r2.3<0;1,0>:ud    r0.2<0;1,0>:uw   {A@1}
        mach (1|M0)              r7.0<1>:ud    r2.3<0;1,0>:ud    r0.1<0;1,0>:ud   {AccWrEn}
        mov (1|M0)               r1.2<1>:d     r1.0<0;1,0>:uw                   {$0.dst}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
(W)     mov (1|M0)               r5.11<1>:hf   0x1:hf                             
        addc (1|M0)              r8.0<1>:ud    r6.0<0;1,0>:ud    r1.2<0;1,0>:ud   {AccWrEn,I@1}
        mov (1|M0)               r1.6<1>:d     r8.0<0;1,0>:d                    {I@1}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        cmp (1|M0)    (lt)f0.1   null<1>:ud    r1.6<0;1,0>:ud    r3.0<0;1,0>:ud   {I@2}
        add3 (1|M0)              r1.7<1>:d     r9.0<0;0>:d       r7.0<0;0>:d       0:w               {I@2}
        mul (1|M0)               acc0.0<1>:ud  r2.0<0;1,0>:ud    r2.6<0;1,0>:uw  
        cmp (1|M0)    (lt)f1.1   null<1>:ud    r1.7<0;1,0>:ud    r3.1<0;1,0>:ud   {I@2}
(f0.1)  cmp (1|M0)    (eq)f0.1   null<1>:d     r1.7<0;1,0>:d     r3.1<0;1,0>:d   
        mach (1|M0)              r11.0<1>:ud   r2.0<0;1,0>:ud    r2.3<0;1,0>:ud   {AccWrEn}
(f1.1)  sel (1|M0)               r5.8<1>:uw    r5.11<0;1,0>:uw   0x0:uw              {F@1}
(f0.1)  sel (1|M0)               r1.3<1>:uw    r5.11<0;1,0>:uw   0x0:uw             
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        or (1|M0)     (ne)f1.1   null<1>:uw    r1.3<0;1,0>:uw    r5.8<0;1,0>:uw   {I@2}
        mov (1|M0)               r1.5<1>:d     r11.0<0;1,0>:d                  
        mov (1|M0)               r1.4<1>:d     r10.0<0;1,0>:d                   {I@3}
(W)     and (1|M0)               f0.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(~f0.1.any16h) goto (16|M0)                  L1208                  L1208                
L600:
        shl (1|M0)               r3.2<1>:d     r1.6<0;1,0>:d     5:w              
        shl (1|M0)               r2.6<1>:d     r1.7<0;1,0>:d     5:w              
        shr (1|M0)               r2.7<1>:ud    r1.6<0;1,0>:ud    0x1B:uw             
        shl (1|M0)               r3.6<1>:d     r3.2<0;1,0>:d     2:w               {I@3}
        or (1|M0)                r3.3<1>:d     r2.6<0;1,0>:d     r2.7<0;1,0>:d    {I@2}
        addc (1|M0)              r12.0<1>:ud   r4.0<0;1,0>:ud    r3.6<0;1,0>:ud   {AccWrEn,I@2}
        shr (1|M0)               r3.5<1>:ud    r3.2<0;1,0>:ud    0x1E:uw             
        shl (1|M0)               r3.4<1>:d     r3.3<0;1,0>:d     2:w               {I@3}
        mov (1|M0)               r13.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r19.0<1>:ud   r4.2<0;1,0>:ud    r3.6<0;1,0>:ud   {AccWrEn}
        or (1|M0)                r3.7<1>:d     r3.4<0;1,0>:d     r3.5<0;1,0>:d    {I@3}
        mov (1|M0)               r20.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r14.0<1>:f    r12.0<0;1,0>:f                   {Compacted}
        mov (1|M0)               r21.0<1>:f    r19.0<0;1,0>:f                   {Compacted,I@3}
        add3 (1|M0)              r14.1<1>:d    r13.0<0;0>:d      r4.1<0;0>:d       r3.7<0>:d        {I@2}
        add3 (1|M0)              r21.1<1>:d    r20.0<0;0>:d      r4.3<0;0>:d       r3.7<0>:d        {I@2}
        send.ugm (1|M0)          r22      r5      null:0  0x0            0x0240D780           {$4} // wr:1+0, rd:4; load.ugm.d64x16t.a64
        send.ugm (1|M0)          r15      r14     null:0  0x0            0x0240D780           {A@2,$5} // wr:1+0, rd:4; load.ugm.d64x16t.a64
        send.ugm (1|M0)          r29      r21     null:0  0x0            0x0240D780           {A@1,$6} // wr:1+0, rd:4; load.ugm.d64x16t.a64
        addc (1|M0)              r26.0<1>:ud   r4.6<0;1,0>:ud    r3.6<0;1,0>:ud   {AccWrEn}
(W)     mov (1|M0)               r5.12<1>:hf   0x1:hf                              {$4.src}
        mov (1|M0)               r27.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r33.0<1>:ud   r1.6<0;1,0>:ud    r1.4<0;1,0>:ud   {AccWrEn}
        sync.nop                             null                             {Compacted,$3.src}
        mov (1|M0)               r28.0<1>:f    r26.0<0;1,0>:f                   {Compacted,I@3}
        mov (1|M0)               r5.2<1>:d     r33.0<0;1,0>:d                   {I@1}
        mov (1|M0)               r34.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        cmp (1|M0)    (lt)f0.0   null<1>:ud    r5.2<0;1,0>:ud    r3.0<0;1,0>:ud   {I@2}
        add3 (1|M0)              r5.3<1>:d     r34.0<0;0>:d      r1.7<0;0>:d       r1.5<0>:d        {I@2}
        add3 (1|M0)              r28.1<1>:d    r27.0<0;0>:d      r4.7<0;0>:d       r3.7<0>:d       
        cmp (1|M0)    (lt)f1.0   null<1>:ud    r5.3<0;1,0>:ud    r3.1<0;1,0>:ud   {I@2}
(f0.0)  cmp (1|M0)    (eq)f0.0   null<1>:d     r5.3<0;1,0>:d     r3.1<0;1,0>:d   
(f1.0)  sel (1|M0)               r5.10<1>:uw   r5.12<0;1,0>:uw   0x0:uw              {F@2}
(f0.0)  sel (1|M0)               r5.9<1>:uw    r5.12<0;1,0>:uw   0x0:uw             
        or (1|M0)     (ne)f1.0   null<1>:uw    r5.9<0;1,0>:uw    r5.10<0;1,0>:uw  {I@1}
(W)     and (1|M0)               f0.0<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
        sync.allwr                           ($5,$6)                
        mad (16|M0)              r29.0<1>:f    r29.0<1;0>:f      r22.0<1;0>:f      r15.0<1>:f       {Compacted,$4.dst}
        mad (16|M0)              r31.0<1>:f    r31.0<1;0>:f      r24.0<1;0>:f      r17.0<1>:f       {Compacted}
        send.ugm (1|M0)          null     r28     r29:4   0x0            0x0200D784           {A@1,$3} // wr:1+4, rd:0; store.ugm.d64x16t.a64
(~f0.0.any16h) goto (16|M0)                  L1208                  L1208                
L1176:
(W)     mov (2|M0)               r1.6<1>:ud    r5.2<1;1,0>:ud                  
        goto.b (16|M0)                       L1208                  L600                
L1208:
        join (16|M0)                         L1224                                
L1224:
(W)     mov (8|M0)               r127.0<1>:f   r0.0<1;1,0>:f                    {Compacted}
(W)     send.ugm (1|M0)          r35      r0      null:0  0x0            0x0210641F           {$7} // wr:1+0, rd:1; fence invalid flush type scoped to tile
(W)     mov (8|M0)               null<1>:ud    r35.0<1;1,0>:ud                  {$7.dst}
(W)     send.gtwy (1|M0)         null     r127    null:0  0x0            0x02000010           {EOT,A@1} // wr:1+0, rd:0; end of thread
L1280:
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
        illegal                
        illegal                
