L0:
(W)     mov (8|M0)               r127.0<1>:ud  0x0:ud                             
(W)     and (1|M0)               r127.2<1>:ud  r0.0<0;1,0>:ud    0xFFFFFFC0:ud             
(W)     and (1|M0)               r127.0<1>:uw  r0.4<0;1,0>:uw    0xFF:uw             
(W)     add (1|M0)               r127.2<1>:ud  r127.2<0;1,0>:ud  0x20:ud              {I@2}
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
(W)     send.dc0 (8|M0)          r8       r127    null:0  0x0            0x021842FD           {A@1,$2} // wr:1h+0, rd:1; oword aligned block read x2
(W)     mov (8|M0)               r3.0<1>:ud    r0.0<1;1,0>:ud                   {$0.dst}
(W)     or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x4C0:uw              {A@1}
(W)     mul (1|M0)               acc0.0<1>:d   r7.3<0;1,0>:d     r3.2<0;1,0>:uw   {A@1}
(W)     mach (1|M0)              r4.0<1>:d     r7.3<0;1,0>:d     r3.1<0;1,0>:d   
        sync.nop                             null                             {Compacted,$2.dst}
(W)     mov (1|M0)               a0.0<1>:ud    r8.3<0;1,0>:d                    {A@1}
        sync.nop                             null                             {Compacted,$1.dst}
        add3 (16|M0)             r5.0<1>:d     r4.0<0;0>:d       r1.0<1;0>:uw      r7.0<0>:d        {I@2}
        add3 (16|M16)            r9.0<1>:d     r4.0<0;0>:d       r2.0<1;0>:uw      r7.0<0>:d       
        shl (16|M0)              r5.0<1>:d     r5.0<1;1,0>:d     1:w               {Compacted,I@2}
        shl (16|M16)             r9.0<1>:d     r9.0<1;1,0>:d     1:w               {Compacted,I@2}
        mov (16|M0)              r11.0<1>:ud   0x0:uw                             
        mov (16|M16)             r13.0<1>:ud   0x0:uw                             
        add (16|M0)              r5.0<1>:d     r5.0<1;1,0>:d     r8.2<0;1,0>:d    {Compacted,I@4}
        add (16|M16)             r9.0<1>:d     r9.0<1;1,0>:d     r8.2<0;1,0>:d    {Compacted,I@4}
(W)     mov (8|M0)               r127.0<1>:f   r3.0<1;1,0>:f                    {Compacted}
        send.ugm (16|M0)         null     r5      r11:2   a0.0        0x240E0B04           {ExBSO,A@2,$3} // wr:2+2, rd:0; store.ugm.d16u32.a32.wb.wb.bss[a0.0]
        sync.nop                             null                             {Compacted,I@1}
        send.ugm (16|M16)        null     r9      r13:2   a0.0        0x240E0B04           {ExBSO,$4} // wr:2+2, rd:0; store.ugm.d16u32.a32.wb.wb.bss[a0.0]
(W)     send.gtwy (1|M0)         null     r127    null:0  0x0            0x02000010           {EOT,A@1} // wr:1+0, rd:0; end of thread
L512:
        nop                    
(W)     mov (16|M0)              null<1>:ud    0x9E09665A:ud                             
(W)     mov (16|M0)              null<1>:ud    0xA6E09A48:ud                             
(W)     mov (16|M0)              null<1>:ud    0x0:ud                             
(W)     mov (16|M0)              null<1>:ud    0x61:ud                             
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
