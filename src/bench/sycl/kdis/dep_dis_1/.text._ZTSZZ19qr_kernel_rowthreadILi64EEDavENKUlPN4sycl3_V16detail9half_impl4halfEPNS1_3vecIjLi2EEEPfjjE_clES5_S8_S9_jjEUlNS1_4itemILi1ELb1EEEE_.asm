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
        mov (1|M0)               r2.3<1>:d     r2.6<0;1,0>:d                   
        addc (1|M0)              r6.0<1>:ud    r4.0<0;1,0>:ud    r1.2<0;1,0>:ud   {AccWrEn,I@2}
        mov (1|M0)               r18.0<1>:f    r6.0<0;1,0>:f                    {Compacted,I@1}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mul (1|M0)               acc0.0<1>:ud  r18.0<0;1,0>:ud   r2.6<0;1,0>:uw   {F@1}
        mach (1|M0)              r9.0<1>:ud    r18.0<0;1,0>:ud   r2.3<0;1,0>:ud   {AccWrEn}
        add3 (1|M0)              r18.1<1>:d    r7.0<0;0>:d       r5.0<0;0>:d       0:w               {I@3}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r18.1<0;1,0>:d    r2.6<0;1,0>:uw   {I@2}
        mach (1|M0)              r10.0<1>:d    r18.1<0;1,0>:d    r2.3<0;1,0>:d   
        mov (1|M0)               r18.2<1>:d    r8.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r18.3<1>:d    r10.0<0;0>:d      r9.0<0;0>:d       0:w               {I@2}
        shl (1|M0)               r1.4<1>:d     r18.2<0;1,0>:d    1:w               {I@2}
        shr (1|M0)               r1.3<1>:ud    r18.2<0;1,0>:ud   0x1F:uw             
        shl (1|M0)               r1.2<1>:d     r18.3<0;1,0>:d    1:w               {I@3}
        addc (1|M0)              r4.0<1>:ud    r3.0<0;1,0>:ud    r1.4<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r6.0<1>:f     r4.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r6.1<1>:d     r5.0<0;0>:d       r3.1<0;0>:d       r1.5<0>:d        {I@1}
        send.ugm (1|M0)          r11      r6      null:0  0x0            0x0240D780           {A@1,$2} // wr:1+0, rd:4; load.ugm.d64x16t.a64
        mov (8|M0)               r33.0<1>:f    r11.0<1;1,0>:hf                  {$2.dst}
        mov (8|M0)               r34.0<1>:f    r11.8<1;1,0>:hf                 
        mov (8|M0)               r19.0<1>:f    r12.0<1;1,0>:hf                 
        mov (8|M0)               r20.0<1>:f    r12.8<1;1,0>:hf                 
        mov (8|M0)               r21.0<1>:f    r13.0<1;1,0>:hf                 
        mov (8|M0)               r22.0<1>:f    r13.8<1;1,0>:hf                 
        mov (8|M0)               r23.0<1>:f    r14.0<1;1,0>:hf                 
        mov (8|M0)               r24.0<1>:f    r14.8<1;1,0>:hf                 
        sel (16|M0)   (ge)f0.0   acc0.0<1>:f   (abs)r33.0<1;1,0>:f  (abs)r21.0<1;1,0>:f {Compacted,F@3}
        sel (16|M0)   (ge)f0.0   acc2.0<1>:f   (abs)r19.0<1;1,0>:f  (abs)r23.0<1;1,0>:f {Compacted,F@2}
        sel (16|M0)   (ge)f0.0   r7.0<1>:f     acc0.0<1;1,0>:f   acc2.0<1;1,0>:f 
        sel (8|M0)    (ge)f0.0   r4.0<1>:f     r7.0<1;1,0>:f     r8.0<1;1,0>:f    {Compacted,F@1}
        mov (4|M0)               r5.0<1>:ud    r4.4<1;1,0>:ud                   {F@1}
        sel (4|M0)    (ge)f0.0   r6.0<1>:f     r4.0<1;1,0>:f     r5.0<1;1,0>:f    {I@1}
        mov (2|M0)               r15.0<1>:ud   r6.2<1;1,0>:ud                   {F@1}
        sel (2|M0)    (ge)f0.0   r16.0<1>:f    r6.0<1;1,0>:f     r15.0<1;1,0>:f   {I@1}
        sel (1|M0)    (ge)f0.0   r85.0<1>:f    r16.0<0;1,0>:f    r16.1<0;1,0>:f   {F@1}
        cmp (1|M0)    (eq)f1.0   null<1>:f     r85.0<0;1,0>:f    0.0:f               {F@1}
(W)     and (1|M0)               f0.0<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
(f0.0.any16h) goto (16|M0)                   L952                  L952                
L872:
        mov (1|M0)               r85.1<1>:f    127.0:f                              
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r84.6         L4952                                 {A@1}
L936:
        goto (16|M0)                         L952                  L976                
L952:
        join (16|M0)                         L976                                
L968:
        mov (1|M0)               r86.0<1>:f    1.0:f                               {Compacted}
L976:
        join (16|M0)                         L992                                
L992:
        shl (1|M0)               r1.4<1>:d     r18.0<0;1,0>:d    2:w               {Compacted}
        shl (1|M0)               r1.2<1>:d     r18.1<0;1,0>:d    2:w              
        shr (1|M0)               r1.3<1>:ud    r18.0<0;1,0>:ud   0x1E:uw             
        addc (1|M0)              r4.0<1>:ud    r3.2<0;1,0>:ud    r1.4<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (16|M0)              r25.0<1>:f    r86.0<0;1,0>:f                   {Compacted,F@1}
        mov (1|M0)               r6.0<1>:f     r4.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r6.1<1>:d     r5.0<0;0>:d       r3.3<0;0>:d       r1.5<0>:d        {I@1}
        mov (16|M0)              r35.0<1>:f    r25.0<1;1,0>:f                   {Compacted,F@2}
        send.ugm (1|M0)          null     r6      r86:1   0x0            0x04000584           {A@1,$3} // wr:2+1, rd:0; store.ugm.d32.a64
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r85.2         L1808                                 {A@1}
L1176:
        mov (16|M0)              r27.0<1>:ud   r37.0<1;1,0>:ud                 
        mov (16|M0)              r33.0<1>:f    r19.0<1;1,0>:f                   {Compacted}
        mov (16|M0)              r35.0<1>:f    r25.0<1;1,0>:f                   {Compacted}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r85.2         L1808                                 {A@1}
L1256:
        mov (16|M0)              r29.0<1>:ud   r37.0<1;1,0>:ud                 
        mov (16|M0)              r33.0<1>:f    r21.0<1;1,0>:f                   {Compacted}
        mov (16|M0)              r35.0<1>:f    r25.0<1;1,0>:f                   {Compacted}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r85.2         L1808                                 {A@1}
L1336:
        mov (16|M0)              r31.0<1>:ud   r37.0<1;1,0>:ud                 
        mov (16|M0)              r33.0<1>:f    r23.0<1;1,0>:f                   {Compacted}
        mov (16|M0)              r35.0<1>:f    r25.0<1;1,0>:f                   {Compacted}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r85.2         L1808                                 {A@1}
L1416:
        rnde (16|M0)             r27.0<1>:f    r27.0<1;1,0>:f                   {Compacted,I@6}
        rnde (16|M0)             r29.0<1>:f    r29.0<1;1,0>:f                   {Compacted,I@4}
        rnde (16|M0)             r31.0<1>:f    r31.0<1;1,0>:f                   {Compacted,I@2}
        rnde (16|M0)             r37.0<1>:f    r37.0<1;1,0>:f                   {Compacted}
        sel (16|M0)   (ge)f0.0   r27.0<1>:f    r27.0<1;1,0>:f    -127.0:f               {F@4}
        sel (16|M0)   (ge)f0.0   r29.0<1>:f    r29.0<1;1,0>:f    -127.0:f               {F@4}
        sel (16|M0)   (ge)f0.0   r31.0<1>:f    r31.0<1;1,0>:f    -127.0:f               {F@4}
        sel (16|M0)   (ge)f0.0   r37.0<1>:f    r37.0<1;1,0>:f    -127.0:f               {F@4}
        addc (1|M0)              r14.0<1>:ud   r3.4<0;1,0>:ud    r18.2<0;1,0>:ud  {AccWrEn}
        sel (16|M0)   (lt)f0.0   r27.0<1>:f    r27.0<1;1,0>:f    127.0:f               {F@4}
        sel (16|M0)   (lt)f0.0   r29.0<1>:f    r29.0<1;1,0>:f    127.0:f               {F@4}
        sel (16|M0)   (lt)f0.0   r31.0<1>:f    r31.0<1;1,0>:f    127.0:f               {F@4}
        sel (16|M0)   (lt)f0.0   r37.0<1>:f    r37.0<1;1,0>:f    127.0:f               {F@4}
        mov (1|M0)               r15.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (16|M0)              r4.0<1>:d     r27.0<1;1,0>:f                   {Compacted,F@4}
        mov (16|M0)              r6.0<1>:d     r29.0<1;1,0>:f                   {Compacted,F@3}
        mov (16|M0)              r8.0<1>:d     r31.0<1;1,0>:f                   {Compacted,F@2}
        mov (16|M0)              r10.0<1>:d    r37.0<1;1,0>:f                   {Compacted,F@1}
        mov (1|M0)               r16.0<1>:d    r14.0<0;1,0>:d                   {I@6}
        add3 (1|M0)              r16.1<1>:d    r15.0<0;0>:d      r3.5<0;0>:d       r18.3<0>:d       {I@6}
        mov (16|M0)              r12.0<1>:b    r4.0<4;1,0>:b                    {I@6}
        mov (16|M0)              r12.16<1>:b   r6.0<4;1,0>:b                    {I@6}
        mov (16|M0)              r13.0<1>:b    r8.0<4;1,0>:b                    {I@6}
        mov (16|M0)              r13.16<1>:b   r10.0<4;1,0>:b                   {I@6}
        send.ugm (1|M0)          null     r16     r12:2   0x0            0x0200C784           {A@1,$4} // wr:1+2, rd:0; store.ugm.d64x8t.a64
(W)     mov (8|M0)               r127.0<1>:ud  r0.0<1;1,0>:ud                  
(W)     send.ugm (1|M0)          r17      r0      null:0  0x0            0x0210641F           {$5} // wr:1+0, rd:1; fence invalid flush type scoped to tile
(W)     mov (8|M0)               null<1>:ud    r17.0<1;1,0>:ud                  {$5.dst}
(W)     send.gtwy (1|M0)         null     r127    null:0  0x0            0x02000010           {EOT,A@1} // wr:1+0, rd:0; end of thread
L1808:
(W)     shr (16|M0)              r4.0<1>:ud    r33.0<1;1,0>:ud   0x17:uw             
(W)     and (16|M0)              r39.0<1>:w    r4.0<2;1,0>:w     255:w               {I@1}
(W)     add (16|M0)              r8.0<1>:d     r39.0<1;1,0>:uw   -191:w               {I@1}
(W)     cmp (16|M0)   (lt)f1.0   null<1>:d     r8.0<1;1,0>:ud    0xFFFFFF82:ud              {I@1}
(W)     shr (16|M0)              r6.0<1>:ud    r35.0<1;1,0>:ud   0x17:uw             
(W)     mov (1|M0)               r84.3<1>:uw   f1.0<0;1,0>:uw                  
(W)     and (16|M0)              r44.0<1>:w    r6.0<2;1,0>:w     255:w               {I@2}
(W)     mov (1|M0)               f0.1<1>:uw    r84.3<0;1,0>:uw                  {I@2}
(W)     add (16|M0)              r10.0<1>:d    r44.0<1;1,0>:uw   -191:w               {I@2}
(W)     mov (16|M0)              r40.0<1>:d    r39.0<1;1,0>:uw                 
(W&~f0.1) cmp (16|M0) (lt)f0.1   null<1>:d     r10.0<1;1,0>:ud   0xFFFFFF81:ud              {I@2}
(W)     mov (16|M0)              r42.0<1>:d    r39.0<1;1,0>:uw                 
(W)     mov (1|M0)               r84.3<1>:uw   f0.1<0;1,0>:uw                  
(W)     mov (16|M0)              r45.0<1>:d    r44.0<1;1,0>:uw                 
(W)     mov (1|M0)               f0.0<1>:uw    r84.3<0;1,0>:uw                  {I@2}
(W)     mov (16|M0)              r47.0<1>:d    r44.0<1;1,0>:uw                 
(~f0.0.any16h) goto (16|M0)                  L4624                  L4624                
L2080:
(W)     add (16|M0)              r4.0<1>:d     r39.0<1;1,0>:uw   -255:w              
(W)     cmp (16|M0)   (lt)f0.0   null<1>:d     r4.0<1;1,0>:ud    0xFFFFFF02:ud              {I@1}
(W)     add (16|M0)              r6.0<1>:d     r44.0<1;1,0>:uw   -255:w              
(W&~f0.0) cmp (16|M0) (lt)f0.0   null<1>:d     r6.0<1;1,0>:ud    0xFFFFFF02:ud              {I@1}
(W)     mov (16|M0)              r59.0<1>:f    (abs)r33.0<1;1,0>:f              {Compacted}
(f0.0.any16h) goto (16|M0)                   L2240                  L2240                
L2168:
(W)     mov (16|M0)              r4.0<1>:f     (abs)r35.0<1;1,0>:f              {Compacted}
(W)     add (16|M0)              r59.0<1>:d    r59.0<1;1,0>:d    -r4.0<1;1,0>:d   {Compacted,A@1}
(W)     mov (4|M0)               r18.4<1>:d    0:w                              
(W)     mov (16|M0)              r71.0<1>:f    r33.0<1;1,0>:f                   {Compacted}
(W)     mov (16|M0)              r61.0<1>:f    r35.0<1;1,0>:f                   {Compacted}
(W)     asr (16|M0)              r59.0<1>:d    r59.0<1;1,0>:d    23:w               {Compacted,I@2}
        goto (16|M0)                         L2240                  L3496                
L2240:
        join (16|M0)                         L3496                                
L2256:
(W)     mov (16|M0)              r57.0<1>:f    (abs)r35.0<1;1,0>:f              {Compacted}
(W)     cmp (16|M0)   (gt)f1.1   null<1>:d     r59.0<1;1,0>:ud   0x7F800000:ud              {I@3}
(W)     cmp (16|M0)   (lt)f1.0   null<1>:d     r57.0<1;1,0>:ud   0x7F800001:ud              {F@1}
(W)     and (16|M0)              r49.0<1>:ud   r33.0<1;1,0>:ud   0x7F800000:ud             
(W)     mov (1|M0)               r1.3<1>:uw    f1.1<0;1,0>:uw                  
(W)     mov (1|M0)               r2.6<1>:uw    f1.0<0;1,0>:uw                   {Compacted}
(W)     or (1|M0)                f0.1<1>:uw    f1.0<0;1,0>:uw    r1.3<0;1,0>:uw   {I@2}
(W)     cmp (16|M0)   (ne)f1.0   null<1>:d     r49.0<1;1,0>:d    2139095040:d              
(W)     or (1|M0)                r3.12<1>:uw   f1.1<0;1,0>:uw    ~r2.6<0;1,0>:uw  {I@3}
(W)     mov (1|M0)               r8.0<1>:f     -0.0:f                               {Compacted}
(W)     or (1|M0)                r3.13<1>:uw   f1.0<0;1,0>:uw    r3.12<0;1,0>:uw  {I@1}
(W&f0.1) sel (16|M0)             acc0.0<1>:f   r33.0<1;1,0>:f    r35.0<1;1,0>:f  
(W)     mov (1|M0)               f0.1<1>:uw    r3.13<0;1,0>:uw                  {A@1}
(W)     and (16|M0)              r51.0<1>:ud   r35.0<1;1,0>:ud   0x7F800000:ud             
(W)     bfn.0x6A (16|M0)         r37.0<1>:ud   r33.0<1;0>:ud     r35.0<1;0>:ud     r8.0<0>:ud       // s0^s1&s2
(W)     bfn.0x6A (16|M0)         r9.0<1>:ud    r35.0<1;0>:ud     r33.0<1;0>:ud     r8.0<0>:ud       // s0^s1&s2
(W)     add (16|M0)              r37.0<1>:f    r37.0<1;1,0>:f    -r9.0<1;1,0>:f   {Compacted,A@1}
(W&f0.1) add (16|M0)             r37.0<1>:f    acc0.0<1;1,0>:f   r35.0<1;1,0>:f  
(W)     cmp (16|M0)   (ne)f0.1   null<1>:d     r51.0<1;1,0>:d    2139095040:d               {F@1}
(W)     or (1|M0)                r3.12<1>:uw   ~f1.0<0;1,0>:uw   r3.12<0;1,0>:uw 
(W)     cmp (16|M0)   (eq)f1.0   null<1>:f     r35.0<1;1,0>:f    0.0:f               {I@1}
(W)     or (1|M0)                r1.3<1>:uw    f0.1<0;1,0>:uw    r3.12<0;1,0>:uw 
(W)     or (1|M0)                r3.12<1>:uw   ~f0.1<0;1,0>:uw   r3.12<0;1,0>:uw 
(W)     mov (1|M0)               r2.6<1>:hf    -qnan(0x1FF):hf                             
(W)     mov (1|M0)               f0.1<1>:uw    r3.12<0;1,0>:uw                  {I@1}
(W)     and (1|M0)               r4.0<1>:uw    f1.0<0;1,0>:uw    ~r3.12<0;1,0>:uw
(W)     mov (1|M0)               f1.1<1>:uw    r1.3<0;1,0>:uw                  
(W)     and (16|M0)              r6.0<1>:ud    r35.0<1;1,0>:ud   0x80000000:ud             
(W&f0.1) sel (16|M0)             r11.0<2>:b    r2.6<0;1,0>:w     0:w               {F@1}
(W)     mov (1|M0)               f0.1<1>:uw    r4.0<0;1,0>:uw                   {I@4}
(W)     and (16|M0)              r53.0<1>:ud   r33.0<1;1,0>:ud   0x80000000:ud             
(W&~f1.1) mul (16|M0)            r37.0<1>:f    r6.0<1;1,0>:f     r33.0<1;1,0>:f   {I@4}
(W)     mov (16|M0)              r18.16<1>:b   r11.0<2;1,0>:b                   {I@3}
(~f0.1) goto (16|M0)                         L2888                  L2888                
L2768:
(W)     cmp (16|M0)   (eq)f1.0   null<1>:f     r33.0<1;1,0>:f    0.0:f              
(W)     mov (1|M0)               r1.2<1>:ud    0x7F800000:ud                             
(W)     mov (1|M0)               r2.12<2>:b    -1:w                              
(W&f1.0) mov (16|M0)             r53.0<1>:ud   0:w                              
(W)     bfn.0x96 (16|M0)         r53.0<1>:ud   r1.2<0;0>:ud      r53.0<1;0>:ud     r35.0<1>:ud      {I@1} // s0^s1^s2
(W&f1.0) mul (16|M0)             r53.0<1>:f    r53.0<1;1,0>:f    r33.0<1;1,0>:f   {I@1}
        mov (16|M0)              r18.16<1>:b   r2.12<0;1,0>:b                  
        mov (16|M0)              r37.0<1>:f    r53.0<1;1,0>:f                   {Compacted,F@1}
L2888:
        join (16|M0)                         L3496                                
L2904:
(W)     cmp (16|M0)   (eq)f0.1   null<1>:f     r33.0<1;1,0>:f    0.0:f              
(W&f0.1) cmp (16|M0)  (eq)f0.1   null<1>:w     r18.16<1;1,0>:ub  0x0:uw              {A@1}
(W&~f0.1) sel (16|M0)            r4.0<2>:b     r18.16<1;1,0>:b   -1:w              
(W)     mov (16|M0)              r18.16<1>:b   r4.0<2;1,0>:b                    {I@1}
(W)     cmp (16|M0)   (ne)f1.1   null<1>:w     r18.16<1;1,0>:ub  0x0:uw              {I@1}
(W&f0.1) mul (16|M0)             r37.0<1>:f    r33.0<1;1,0>:f    r35.0<1;1,0>:f  
(f1.1.all16h) goto (16|M0)                   L3496                  L4624                
L3016:
(W)     cmp (16|M0)   (eq)f1.1   null<1>:w     r18.16<1;1,0>:ub  0x0:uw             
(W)     mov (1|M0)               r1.3<1>:uw    f0.0<0;1,0>:uw                  
(W)     cmp (16|M0)   (eq)f1.0   null<1>:d     r49.0<1;1,0>:d    0:w              
(W)     and (1|M0)               f0.0<1>:uw    f1.1<0;1,0>:uw    r1.3<0;1,0>:uw   {I@2}
(W)     mov (16|M0)              r63.0<1>:d    0:w                              
(W)     mov (1|M0)               r2.6<1>:uw    f1.0<0;1,0>:uw                   {Compacted}
(W)     mov (16|M0)              r71.0<1>:f    r33.0<1;1,0>:f                   {Compacted}
(W)     and (1|M0)               f1.0<1>:uw    f0.0<0;1,0>:uw    r2.6<0;1,0>:uw   {I@1}
(W)     mov (16|M0)              r55.0<1>:f    r63.0<1;1,0>:f                   {Compacted}
(~f1.0) goto (16|M0)                         L3248                  L3248                
L3152:
        mul (16|M0)              r71.0<1>:f    r33.0<1;1,0>:f    0x4F800000:f               {Compacted}
(W)     shr (16|M0)              r4.0<1>:ud    r71.0<1;1,0>:ud   0x17:uw              {F@1}
(W)     and (16|M0)              r6.0<1>:w     r4.0<2;1,0>:w     255:w               {I@1}
        add (16|M0)              r42.0<1>:d    r6.0<1;1,0>:uw    -32:w               {I@1}
(W)     mov (16|M0)              r55.0<1>:d    0:w                              
(W)     mov (16|M0)              r40.0<1>:f    r42.0<1;1,0>:f                   {Compacted,I@2}
        mov (16|M0)              r55.0<1>:d    -32:w                              
L3248:
        join (16|M0)                         L3496                                
L3264:
(W)     cmp (16|M0)   (eq)f0.1   null<1>:d     r51.0<1;1,0>:d    0:w              
(W)     mov (16|M0)              r61.0<1>:f    r35.0<1;1,0>:f                   {Compacted}
(W)     mov (1|M0)               r1.3<1>:uw    f0.1<0;1,0>:uw                  
(W)     and (1|M0)               f0.1<1>:uw    f0.0<0;1,0>:uw    r1.3<0;1,0>:uw   {I@1}
(~f0.1) goto (16|M0)                         L3440                  L3440                
L3336:
        mul (16|M0)              r61.0<1>:f    r35.0<1;1,0>:f    0x4F800000:f               {Compacted}
(W)     shr (16|M0)              r4.0<1>:ud    r61.0<1;1,0>:ud   0x17:uw              {F@1}
(W)     and (16|M0)              r6.0<1>:w     r4.0<2;1,0>:w     255:w               {I@1}
        add (16|M0)              r47.0<1>:d    r6.0<1;1,0>:uw    -32:w               {I@1}
(W)     mov (16|M0)              r63.0<1>:d    0:w                              
(W)     mov (16|M0)              r57.0<1>:f    (abs)r61.0<1;1,0>:f              {Compacted}
(W)     mov (16|M0)              r45.0<1>:f    r47.0<1;1,0>:f                   {Compacted,I@2}
        mov (16|M0)              r63.0<1>:d    32:w                              
L3440:
        join (16|M0)                         L3496                                
L3456:
(W)     mov (16|M0)              r59.0<1>:f    (abs)r71.0<1;1,0>:f              {Compacted}
(W)     add (16|M0)              r59.0<1>:d    r59.0<1;1,0>:d    -r57.0<1;1,0>:d  {Compacted,F@1}
(W)     asr (16|M0)              r59.0<1>:d    r59.0<1;1,0>:d    23:w               {Compacted,I@1}
(W)     add3 (16|M0)             r63.0<1>:d    r63.0<1;0>:d      r55.0<1;0>:d      r59.0<1>:d       {I@1}
L3496:
        join (16|M0)                         L4624                                
L3512:
(W)     mov (1|M0)               r1.2<1>:f     1.0:f                               {Compacted}
(W)     mov (1|M0)               r4.0<1>:f     0x807FFFFF:f                              
(W&~f0.0) mov (16|M0)            r63.0<1>:f    r59.0<1;1,0>:f                   {I@2}
(W)     bfn.0xEA (16|M0)         r61.0<1>:ud   r1.2<0;0>:ud      r61.0<1;0>:ud     r4.0<0>:ud       {A@2} // s0|s1&s2
(W)     add (16|M0)              r65.0<1>:d    r63.0<1;1,0>:d    126:w               {Compacted,F@1}
(W)     add (16|M0)              r5.0<1>:d     -r63.0<1;1,0>:d   -152:w               {Compacted}
        sync.nop                             null                             {Compacted,I@3}
(W)     math.inv (16|M0)         r7.0<1>:f     r61.0<1;1,0>:f                   {$6}
(W)     cmp (16|M0)   (eq)f0.0   null<1>:w     r18.16<1;1,0>:ub  0x0:uw             
(W)     and (16|M0)              r5.0<1>:d     r5.0<1;1,0>:d     r65.0<1;1,0>:d   {Compacted,I@2}
(W)     mov (1|M0)               r2.3<1>:f     1.0:f                               {Compacted}
(W)     bfn.0xEA (16|M0)         r71.0<1>:ud   r1.2<0;0>:ud      r71.0<1;0>:ud     r4.0<0>:ud       // s0|s1&s2
(W)     asr (16|M0)              r5.0<1>:d     r5.0<1;1,0>:d     31:w               {Compacted,I@2}
        sync.nop                             null                             {Compacted,$6.dst}
(W)     mad (16|M0)              r67.0<1>:f    r2.3<0;0>:f       r7.0<1;0>:f       -r61.0<1>:f      {F@1}
(W)     mul (16|M0)              acc0.0<1>:f   r7.0<1;1,0>:f     r71.0<1;1,0>:f   {Compacted,I@2}
(W&f0.0) sel (16|M0)             r73.0<1>:w    r5.0<4;1,0>:ub    0:w               {I@1}
(W)     mad (16|M0)              r67.0<1>:f    r7.0<1;0>:f       r7.0<1;0>:f       r67.0<1>:f       {Compacted,F@2}
(W)     mad (16|M0)              r69.0<1>:f    r71.0<1;0>:f      acc0.0<1;0>:f     -r61.0<1>:f     
(W)     cmp (16|M0)   (ne)f1.1   null<1>:w     r73.0<2;1,0>:ub   0x0:uw              {I@1}
(W)     mad (16|M0)              r69.0<1>:f    acc0.0<1;0>:f     r67.0<1;0>:f      r69.0<1>:f       {F@1}
(W)     add (16|M0)              r40.0<1>:d    r40.0<1;1,0>:d    -r45.0<1;1,0>:d  {Compacted}
(W)     mad (16|M0)              r71.0<1>:f    r71.0<1;0>:f      r69.0<1;0>:f      -r61.0<1>:f      {Compacted,F@1}
(~f1.1.any16h) goto (16|M0)                  L4368                  L4368                
L3800:
(W)     mov (16|M0)              r80.0<1>:ud   r71.0<1;1,0>:ud                  {F@1}
(W)     mov (16|M0)              r76.0<1>:f    r67.0<1;1,0>:f                   {Compacted}
(W)     mov (16|M0)              r78.0<1>:f    r69.0<1;1,0>:f                   {Compacted}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r85.4         L4832                                 {A@1}
L3880:
(W)     add (16|M0)              r63.0<1>:d    r63.0<1;1,0>:d    125:w               {Compacted}
(W)     cmp (16|M0)   (lt)f0.0   null<1>:d     r63.0<1;1,0>:d    -2:w               {Compacted,I@1}
(W)     cmp (16|M0)   (eq)f0.1   null<1>:f     r71.0<1;1,0>:f    0.0:f              
(W)     mov (1|M0)               r1.3<1>:uw    f0.0<0;1,0>:uw                  
(W)     or (1|M0)                f1.0<1>:uw    f0.1<0;1,0>:uw    r1.3<0;1,0>:uw   {I@1}
(f1.0.any16h) goto (16|M0)                   L4008                  L4008                
L3960:
(W)     mov (1|M0)               r1.3<1>:hf    0x1:hf                              {I@2}
(W&f0.1) sel (16|M0)             r74.0<1>:d    r1.3<0;1,0>:w     0:w               {F@1}
        goto (16|M0)                         L4008                  L4128                
L4008:
        join (16|M0)                         L4128                                
L4024:
(W)     mov (1|M0)               r1.3<1>:hf    0x1:hf                              {I@3}
(W)     and (16|M0)              r4.0<1>:d     r80.0<1;1,0>:d    -2139095041:d              
(W)     mov (1|M0)               r6.0<1>:f     0x800000:f                               {Compacted}
(W)     shl (16|M0)              r65.0<1>:d    r65.0<1;1,0>:d    23:w               {Compacted}
(W&f0.1) sel (16|M0)             r74.0<1>:d    r1.3<0;1,0>:w     0:w               {F@2}
(W)     add (16|M0)              r65.0<1>:d    r65.0<1;1,0>:d    1065353216:d               {I@2}
(W)     bfn.0xFE (16|M0)         r4.0<1>:ud    r4.0<1;0>:ud      r74.0<1;0>:ud     r6.0<0>:ud       {A@1} // s0|s1|s2
(W)     mul (16|M0)              r65.0<1>:f    r65.0<1;1,0>:f    r4.0<1;1,0>:f    {Compacted,A@1}
L4128:
        join (16|M0)                         L4368                                
L4144:
(W)     and (16|M0)   (eq)f1.1   null<1>:ud    r80.0<1;1,0>:ud   0x400000:ud             
(W)     shl (16|M0)              r4.0<1>:d     r80.0<1;1,0>:d    1:w               {Compacted,F@1}
(W)     mov (1|M0)               r1.2<1>:f     0x800000:f                               {Compacted}
(W)     mov (1|M0)               r6.0<1>:f     -0.0:f                               {Compacted}
(W)     mov (1|M0)               r2.3<1>:f     1.469368e-38:f                               {Compacted}
(W)     and (16|M0)              r4.0<1>:d     r4.0<1;1,0>:d     8388606:d               {I@1}
(W)     bfn.0xEA (16|M0)         r7.0<1>:ud    r1.2<0;0>:ud      r80.0<1;0>:ud     r6.0<0>:ud       {A@2} // s0|s1&s2
(W&f1.1) sel (16|M0)             r9.0<1>:d     r2.3<0;1,0>:d     12582912:d               {F@1}
(W)     mov (1|M0)               r3.6<1>:f     0.25:f                               {Compacted}
(W)     bfn.0xFE (16|M0)         r74.0<1>:ud   r74.0<1;0>:ud     r7.0<1;0>:ud      r4.0<1>:ud       {I@2} // s0|s1|s2
(W)     bfn.0xEA (16|M0)         r9.0<1>:ud    r9.0<1;0>:ud      r80.0<1;0>:ud     r6.0<0>:ud       {I@2} // s0|s1&s2
(W)     mad (16|M0)              r74.0<1>:f    r9.0<1;0>:f       r74.0<1;0>:f      r3.6<0>:f        {Compacted,A@1}
(W)     add (16|M0)              r74.0<1>:f    r74.0<1;1,0>:f    -r7.0<1;1,0>:f   {Compacted,F@1}
(W)     mul (16|M0)              r7.0<1>:f     r7.0<1;1,0>:f     r7.0<1;1,0>:f    {Compacted}
(W)     bfn.0xAE (16|M0)         r74.0<1>:ud   r74.0<1;0>:ud     r7.0<1;0>:ud      0x1:uw              {A@1} // s0|s1&~s2
(W&~f1.0) mov (16|M0)            r65.0<1>:f    r74.0<1;1,0>:f                   {I@1}
(W)     and (16|M0)   (ne)f1.0   null<1>:w     r73.0<2;1,0>:ub   1:w               {F@1}
(W&f1.0) mov (16|M0)             r37.0<1>:f    r65.0<1;1,0>:f                  
L4368:
        join (16|M0)                         L4624                                
L4384:
(W)     add (16|M0)              r4.0<1>:d     r40.0<1;1,0>:d    -253:w               {Compacted}
(W)     cmp (16|M0)   (lt)f1.1   null<1>:d     r4.0<1;1,0>:ud    0xFFFFFE85:ud              {I@1}
(W)     mov (1|M0)               r1.3<1>:hf    -qnan(0x1FF):hf                             
(W)     asr (16|M0)              r6.0<1>:d     r40.0<1;1,0>:d    11:w               {Compacted}
(W&f1.1.any16h) sel (1|M0)       r2.6<1>:w     r1.3<0;1,0>:w     0:w               {F@1}
(W)     add (16|M0)              r8.0<1>:d     r6.0<1;1,0>:d     248:w               {Compacted,I@2}
(W)     mov (1|M0)               f0.1<1>:uw    r2.6<0;1,0>:uw                   {I@2}
(W)     mov (16|M0)              r10.0<1>:f    r40.0<1;1,0>:f                   {Compacted}
(W&f1.1) xor (16|M0)             r10.0<1>:d    r8.0<1;1,0>:d     r6.0<1;1,0>:d    {A@1}
(W&~f0.1) mov (16|M0)            r10.0<1>:f    r40.0<1;1,0>:f                   {I@1}
(W)     asr (16|M0)              r12.0<1>:d    r10.0<1;1,0>:d    1:w               {Compacted,F@1}
(W)     mov (16|M0)              r4.0<1>:uw    r18.16<1;1,0>:ub                
(W)     add (16|M0)              r10.0<1>:d    r10.0<1;1,0>:d    -r12.0<1;1,0>:d  {Compacted,I@2}
(W)     mad (16|M0)              r71.0<1>:f    r69.0<1;0>:f      r67.0<1;0>:f      r71.0<1>:f       {Compacted}
(W)     or (16|M0)    (eq)f0.0   null<1>:w     r73.0<2;1,0>:ub   r4.0<1;1,0>:uw   {I@2}
(W)     shl (16|M0)              r12.0<1>:d    r12.0<1;1,0>:d    23:w               {Compacted}
(W)     shl (16|M0)              r10.0<1>:d    r10.0<1;1,0>:d    23:w               {Compacted,I@3}
(W)     add (16|M0)              r12.0<1>:d    r12.0<1;1,0>:d    r71.0<1;1,0>:d   {Compacted,A@1}
(W)     add (16|M0)              r10.0<1>:d    r10.0<1;1,0>:d    1065353216:d               {I@2}
(W&f0.0) mul (16|M0)             r37.0<1>:f    r12.0<1;1,0>:f    r10.0<1;1,0>:f   {A@1}
L4624:
        join (16|M0)                         L4640                                
L4640:
(W)     math.inv (16|M0)         r4.0<1>:f     r35.0<1;1,0>:f                   {$7}
(W)     mov (1|M0)               r1.2<1>:ud    0x3F800000:ud                             
(W)     mul (16|M0)              acc0.0<1>:f   r4.0<1;1,0>:f     r33.0<1;1,0>:f   {Compacted,$7.dst}
(W)     mad (16|M0)              acc2.0<1>:f   r1.2<0;0>:f       r4.0<1;0>:f       -r35.0<1>:f      {I@1}
(W)     mad (16|M0)              r10.0<1>:f    r33.0<1;0>:f      acc0.0<1;0>:f     -r35.0<1>:f     
(W)     mad (16|M0)              acc2.0<1>:f   r4.0<1;0>:f       acc2.0<1;0>:f     r4.0<1>:f        {Compacted}
(W)     mov (1|M0)               f1.1<1>:uw    r84.3<0;1,0>:uw                 
(W)     mad (16|M0)              acc0.0<1>:f   acc0.0<1;0>:f     acc2.0<1;0>:f     r10.0<1>:f       {F@2}
(W)     mad (16|M0)              r33.0<1>:f    r33.0<1;0>:f      acc0.0<1;0>:f     -r35.0<1>:f     
(W&~f1.1) mad (16|M0)            r37.0<1>:f    acc0.0<1;0>:f     acc2.0<1;0>:f     r33.0<1>:f       {F@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        ret (16|M0)                          r85.2                            {A@1}
L4832:
(W)     mov (1|M0)               r1.2<1>:d     cr0.0<0;1,0>:ud                  {A@1}
(W)     and (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   -1265:w               {A@1}
(W)     or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   1264:w               {A@1}
(W)     mad (16|M0)              r80.0<1>:f    r78.0<1;0>:f      r76.0<1;0>:f      r80.0<1>:f       {Compacted,A@1}
(W)     mov (1|M0)               cr0.0<1>:ud   r1.2<0;1,0>:d                    {A@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        ret (16|M0)                          r85.4                            {A@1}
L4952:
        shr (1|M0)               r82.2<1>:ud   r85.1<0;1,0>:ud   0x17:uw             
        shr (1|M0)               r82.1<1>:ud   r85.0<0;1,0>:ud   0x17:uw             
        and (1|M0)               r82.2<1>:ud   r82.2<0;1,0>:ud   0xFF:uw              {I@2}
        and (1|M0)               r82.1<1>:ud   r82.1<0;1,0>:ud   0xFF:uw              {I@2}
        add (1|M0)               r1.3<1>:ud    r82.2<0;1,0>:ud   0xFFFFFF41:ud              {I@2}
        add (1|M0)               r1.2<1>:ud    r82.1<0;1,0>:ud   0xFFFFFF41:ud              {I@2}
        cmp (1|M0)    (lt)f1.1   null<1>:ud    r1.3<0;1,0>:ud    0xFFFFFF81:ud              {A@2}
(W)     mov (1|M0)               r2.6<1>:hf    -qnan(0x1FF):hf                             
(~f1.1) cmp (1|M0)    (lt)f1.1   null<1>:ud    r1.2<0;1,0>:ud    0xFFFFFF82:ud              {I@2}
(f1.1)  sel (1|M0)               r82.0<2>:b    r2.6<0;1,0>:w     0:w               {F@1}
        cmp (1|M0)    (ne)f1.1   null<1>:uw    r82.0<0;1,0>:ub   0x0:uw              {I@1}
(W)     and (1|M0)               f1.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(~f1.1.any16h) goto (16|M0)                  L8632                  L8632                
L5160:
        add (1|M0)               r1.3<1>:ud    r82.2<0;1,0>:ud   0xFFFFFF01:ud             
        add (1|M0)               r1.2<1>:ud    r82.1<0;1,0>:ud   0xFFFFFF01:ud             
        cmp (1|M0)    (lt)f1.0   null<1>:ud    r1.3<0;1,0>:ud    0xFFFFFF02:ud              {I@2}
(W)     mov (1|M0)               r2.6<1>:hf    -qnan(0x1FF):hf                             
        mov (1|M0)               r83.6<1>:f    (abs)r85.0<0;1,0>:f              {Compacted}
(~f1.0) cmp (1|M0)    (lt)f1.0   null<1>:ud    r1.2<0;1,0>:ud    0xFFFFFF02:ud              {I@2}
(f1.0)  sel (1|M0)               r82.2<2>:b    r2.6<0;1,0>:w     0:w               {F@2}
        cmp (1|M0)    (ne)f0.1   null<1>:uw    r82.2<0;1,0>:ub   0x0:uw              {I@1}
(W)     and (1|M0)               f1.0<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(f1.0.any16h) goto (16|M0)                   L5408                  L5408                
L5312:
        mov (1|M0)               r1.2<1>:f     (abs)r85.1<0;1,0>:f             
        mov (1|M0)               r83.16<2>:b   0:w                              
        add (1|M0)               r83.6<1>:d    r83.6<0;1,0>:d    -r1.2<0;1,0>:d   {A@1}
        mov (2|M0)               r84.4<1>:d    r85.0<1;1,0>:ud                 
        asr (1|M0)               r83.6<1>:d    r83.6<0;1,0>:d    23:w               {I@2}
        goto (16|M0)                         L5408                  L7112                
L5408:
        join (16|M0)                         L7112                                
L5424:
        cmp (1|M0)    (gt)f0.0   null<1>:ud    r83.6<0;1,0>:ud   0x7F800000:ud              {I@3}
(W)     mov (1|M0)               r1.3<1>:hf    0xFF:hf                             
        mov (1|M0)               r83.3<1>:f    (abs)r85.1<0;1,0>:f             
(W)     mov (1|M0)               r2.7<1>:hf    -qnan(0x1FF):hf                             
(f0.0)  sel (1|M0)               r2.6<1>:w     r1.3<0;1,0>:w     0:w               {F@3}
        and (1|M0)               r82.4<1>:ud   r85.0<0;1,0>:ud   0x7F800000:ud             
        cmp (1|M0)    (eq)f0.1   null<1>:w     r2.12<0;1,0>:b    0:w               {I@2}
(W)     mov (1|M0)               r3.12<1>:uw   r2.12<0;1,0>:ub                 
        and (1|M0)               r82.5<1>:ud   r85.1<0;1,0>:ud   0x7F800000:ud             
        add (1|M0)               r86.0<1>:f    r85.0<0;1,0>:f    r85.1<0;1,0>:f   {Compacted}
(f0.1)  cmp (1|M0)    (gt)f0.1   null<1>:ud    r83.3<0;1,0>:ud   0x7F800000:ud              {F@3}
(W)     mov (1|M0)               r5.0<1>:f     -0.0:f                               {Compacted}
        and (1|M0)               r4.0<1>:ud    r85.1<0;1,0>:ud   0x80000000:ud             
        bfn.0x6A (1|M0)          r1.2<1>:ud    r85.0<0;0>:ud     r85.1<0;0>:ud     r5.0<0>:ud       {F@1} // s0^s1&s2
(f0.1)  sel (1|M0)               r2.16<2>:b    r2.7<0;1,0>:w     0:w              
        bfn.0x6A (1|M0)          r1.3<1>:ud    r85.1<0;0>:ud     r85.0<0;0>:ud     r5.0<0>:ud       // s0^s1&s2
        and (1|M0)    (ne)f1.0   null<1>:w     r2.16<0;1,0>:ub   1:w               {I@2}
        or (1|M0)     (eq)f0.0   r2.16<2>:ub   r2.16<0;1,0>:ub   r3.12<0;1,0>:uw 
        and (1|M0)               r82.3<1>:ud   r85.0<0;1,0>:ud   0x80000000:ud             
(f1.0)  add (1|M0)               r86.0<1>:f    r85.1<0;1,0>:f    r85.1<0;1,0>:f  
(f0.0)  cmp (1|M0)    (eq)f0.0   null<1>:d     r82.4<0;1,0>:d    2139095040:d              
(W)     mov (1|M0)               r4.2<1>:uw    r2.16<0;1,0>:ub                  {I@3}
(f0.0)  sel (1|M0)               r1.6<2>:b     r2.7<0;1,0>:w     0:w              
        and (1|M0)    (ne)f0.1   null<1>:w     r1.6<0;1,0>:ub    1:w               {I@1}
        or (1|M0)     (eq)f1.1   r1.6<2>:ub    r1.6<0;1,0>:ub    r4.2<0;1,0>:uw  
(f0.1)  add (1|M0)               r86.0<1>:f    r1.2<0;1,0>:f     -r1.3<0;1,0>:f  
(f1.1)  cmp (1|M0)    (eq)f1.1   null<1>:d     r82.5<0;1,0>:d    2139095040:d              
(W)     mov (1|M0)               r3.12<1>:uw   r1.6<0;1,0>:ub                   {I@2}
(f1.1)  sel (1|M0)               r82.26<2>:b   r2.7<0;1,0>:w     0:w              
        and (1|M0)    (ne)f0.0   null<1>:w     r82.26<0;1,0>:ub  1:w               {I@1}
        or (1|M0)     (eq)f1.0   r82.26<2>:ub  r82.26<0;1,0>:ub  r3.12<0;1,0>:uw  {F@2}
(f0.0)  mul (1|M0)               r86.0<1>:f    r4.0<0;1,0>:f     r85.0<0;1,0>:f  
(f1.0)  cmp (1|M0)    (eq)f1.0   null<1>:f     r85.1<0;1,0>:f    0.0:f               {I@1}
(f1.0)  sel (1|M0)               r82.24<2>:b   r2.7<0;1,0>:w     0:w              
        cmp (1|M0)    (ne)f1.1   null<1>:uw    r82.24<0;1,0>:ub  0x0:uw              {I@1}
(W)     and (1|M0)               f0.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw              {F@3}
(f0.1.any16h) goto (16|M0)                   L6032                  L6032                
L6000:
        mov (1|M0)               r82.28<2>:b   r82.26<0;1,0>:b                 
        goto (16|M0)                         L6032                  L6216                
L6032:
        join (16|M0)                         L6216                                
L6048:
(W)     mov (1|M0)               r4.0<1>:f     inf:f                               {Compacted}
        cmp (1|M0)    (eq)f1.0   null<1>:f     r85.0<0;1,0>:f    0.0:f              
        bfn.0x96 (1|M0)          r82.3<1>:ud   r82.3<0;0>:ud     r85.1<0;0>:ud     r4.0<0>:ud       {F@2} // s0^s1^s2
        xor (1|M0)               r1.2<1>:ud    r85.1<0;1,0>:ud   0x7F800000:ud             
(W)     mov (1|M0)               r2.6<1>:uw    r82.26<0;1,0>:ub                
(~f1.0) mov (1|M0)               r1.2<1>:f     r82.3<0;1,0>:f                   {A@2}
        or (1|M0)                r82.26<2>:ub  r82.24<0;1,0>:ub  r2.6<0;1,0>:uw   {I@1}
(f1.0)  mul (1|M0)               r82.3<1>:f    r1.2<0;1,0>:f     r85.0<0;1,0>:f   {F@1}
        and (1|M0)    (ne)f1.0   null<1>:w     r82.24<0;1,0>:ub  1:w               {F@1}
        mov (1|M0)               r82.28<2>:b   r82.26<0;1,0>:b                  {I@2}
(f1.0)  mov (1|M0)               r86.0<1>:f    r82.3<0;1,0>:f                  
L6216:
        join (16|M0)                         L7112                                
L6232:
        cmp (1|M0)    (eq)f0.1   null<1>:w     r82.26<0;1,0>:b   0:w              
(W)     mov (1|M0)               r1.3<1>:hf    -qnan(0x1FF):hf                             
(W)     mov (1|M0)               r2.6<1>:uw    r82.28<0;1,0>:ub                 {I@3}
(f0.1)  cmp (1|M0)    (eq)f0.1   null<1>:f     r85.0<0;1,0>:f    0.0:f               {I@2}
(f0.1)  sel (1|M0)               r83.16<2>:b   r1.3<0;1,0>:w     0:w               {F@2}
        and (1|M0)    (ne)f0.1   null<1>:w     r83.16<0;1,0>:ub  1:w               {A@1}
        or (1|M0)     (ne)f0.0   r83.16<2>:ub  r83.16<0;1,0>:ub  r2.6<0;1,0>:uw  
(f0.1)  mul (1|M0)               r86.0<1>:f    r85.0<0;1,0>:f    r85.1<0;1,0>:f  
(W)     and (1|M0)               f0.0<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
(f0.0.any16h) goto (16|M0)                   L7112                  L8632                
L6392:
        cmp (1|M0)    (eq)f1.1   null<1>:uw    r83.16<0;1,0>:ub  0x0:uw              {I@3}
        cmp (1|M0)    (eq)f1.0   null<1>:d     r82.4<0;1,0>:d    0:w              
(~f1.1) mov (1|M0)               r82.2<2>:b    0:w                              
(f1.0)  sel (1|M0)               r83.0<1>:d    r82.2<0;1,0>:b    0:w               {I@1}
        cmp (1|M0)    (ne)f0.1   null<1>:d     r83.0<0;1,0>:d    0:w               {A@1}
(W)     and (1|M0)               f1.1<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(f1.1.any16h) goto (16|M0)                   L6544                  L6544                
L6504:
        mov (1|M0)               r83.1<1>:d    0:w                              
        mov (1|M0)               r84.4<1>:f    r85.0<0;1,0>:f                   {Compacted}
        goto (16|M0)                         L6544                  L6696                
L6544:
        join (16|M0)                         L6696                                
L6560:
        and (1|M0)    (ne)f0.0   r83.0<1>:d    r83.0<0;1,0>:d    1:w              
        mov (1|M0)               r84.4<1>:f    r85.0<0;1,0>:f                   {Compacted}
(W)     mov (1|M0)               r2.6<1>:hf    -qnan(0x1E0):hf                             
(f0.0)  mul (1|M0)               r84.4<1>:f    r85.0<0;1,0>:f    0x4F800000:f              
(f0.0)  sel (1|M0)               r83.1<1>:d    r2.6<0;1,0>:w     0:w               {F@2}
        shr (1|M0)               r1.2<1>:ud    r84.4<0;1,0>:ud   0x17:uw              {F@1}
        and (1|M0)               r1.2<1>:ud    r1.2<0;1,0>:ud    0xFF:uw              {I@1}
        add (1|M0)               r1.2<1>:ud    r1.2<0;1,0>:ud    0xFFFFFFE0:ud              {I@1}
(f0.0)  mov (1|M0)               r82.1<1>:d    r1.2<0;1,0>:d                    {I@1}
L6696:
        join (16|M0)                         L7112                                
L6712:
        cmp (1|M0)    (eq)f0.0   null<1>:d     r82.5<0;1,0>:d    0:w              
(f0.0)  sel (1|M0)               r83.2<1>:d    r82.2<0;1,0>:b    0:w              
        cmp (1|M0)    (ne)f1.1   null<1>:d     r83.2<0;1,0>:d    0:w               {I@1}
(W)     and (1|M0)               f1.0<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(f1.0.any16h) goto (16|M0)                   L6840                  L6840                
L6792:
        mov (1|M0)               r83.5<1>:d    0:w                              
        mov (1|M0)               r84.5<1>:d    r85.1<0;1,0>:ud                 
        goto (16|M0)                         L6840                  L7016                
L6840:
        join (16|M0)                         L7016                                
L6856:
        and (1|M0)    (ne)f1.1   r83.2<1>:d    r83.2<0;1,0>:d    1:w              
        mov (1|M0)               r84.5<1>:f    r85.1<0;1,0>:f                   {I@4}
(W)     mov (1|M0)               r2.6<1>:hf    0x20:hf                             
(f1.1)  mul (1|M0)               r84.5<1>:f    r85.1<0;1,0>:f    0x4F800000:f              
(f1.1)  sel (1|M0)               r83.5<1>:d    r2.6<0;1,0>:w     0:w               {F@2}
        shr (1|M0)               r1.2<1>:ud    r84.5<0;1,0>:ud   0x17:uw              {F@1}
        mov (1|M0)               r83.3<1>:f    (abs)r84.5<0;1,0>:f             
        and (1|M0)               r1.2<1>:ud    r1.2<0;1,0>:ud    0xFF:uw              {I@1}
        add (1|M0)               r1.2<1>:ud    r1.2<0;1,0>:ud    0xFFFFFFE0:ud              {I@1}
(f1.1)  mov (1|M0)               r82.2<1>:f    r1.2<0;1,0>:f                    {I@1}
L7016:
        join (16|M0)                         L7112                                
L7032:
        mov (1|M0)               r83.6<1>:f    (abs)r84.4<0;1,0>:f             
        add (1|M0)               r83.5<1>:d    r83.5<0;1,0>:d    r83.1<0;1,0>:d  
        add (1|M0)               r83.6<1>:d    r83.6<0;1,0>:d    -r83.3<0;1,0>:d  {F@1}
        asr (1|M0)               r83.6<1>:d    r83.6<0;1,0>:d    23:w               {I@1}
        add (1|M0)               r83.5<1>:d    r83.5<0;1,0>:d    r83.6<0;1,0>:d   {I@1}
L7112:
        join (16|M0)                         L8632                                
L7128:
        cmp (1|M0)    (eq)f1.0   null<1>:uw    r82.2<0;1,0>:ub   0x0:uw             
(W)     mov (1|M0)               r1.2<1>:f     1.0:f                               {Compacted}
(W)     mov (1|M0)               r4.0<1>:f     0x807FFFFF:f                              
        cmp (1|M0)    (eq)f0.1   null<1>:w     r83.16<0;1,0>:b   0:w              
(~f1.0) mov (1|M0)               r83.6<1>:d    r83.5<0;1,0>:d                   {I@4}
        bfn.0xEA (1|M0)          r84.5<1>:ud   r1.2<0;0>:ud      r84.5<0;0>:ud     r4.0<0>:ud       {A@1} // s0|s1&s2
        add (1|M0)               r83.7<1>:d    r83.6<0;1,0>:d    126:w               {I@2}
        add (1|M0)               r84.0<1>:d    -r83.6<0;1,0>:d   -152:w               {Compacted}
        sync.nop                             null                             {Compacted,I@3}
        math.inv (1|M0)          r2.3<1>:f     r84.5<0;1,0>:f                   {$8}
        and (1|M0)               r84.0<1>:d    r84.0<0;1,0>:d    r83.7<0;1,0>:d   {Compacted,I@1}
        mov (1|M0)               r88.0<1>:f    1.0:f                               {Compacted}
        asr (1|M0)               r84.0<1>:d    r84.0<0;1,0>:d    31:w               {Compacted,I@1}
(~f0.1) mov (1|M0)               r84.0<1>:d    0:w                              
        bfn.0xEA (1|M0)          r84.4<1>:ud   r1.2<0;0>:ud      r84.4<0;0>:ud     r4.0<0>:ud       // s0|s1&s2
        cmp (1|M0)    (ne)f0.0   null<1>:d     r84.0<0;1,0>:d    0:w               {I@2}
        sync.nop                             null                             {Compacted,$8.dst}
        mad (1|M0)               r88.0<1>:f    r88.0<0;0>:f      r2.3<0;0>:f       -r84.5<0>:f      {F@1}
        mul (1|M0)               r2.4<1>:f     r2.3<0;1,0>:f     r84.4<0;1,0>:f   {I@2}
        mad (1|M0)               r88.0<1>:f    r2.3<0;0>:f       r2.3<0;0>:f       r88.0<0>:f       {F@2}
        mad (1|M0)               r88.1<1>:f    r84.4<0;0>:f      r2.4<0;0>:f       -r84.5<0>:f      {F@2}
(W)     and (1|M0)               f0.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
        mad (1|M0)               r88.1<1>:f    r2.4<0;0>:f       r88.0<0;0>:f      r88.1<0>:f       {F@1}
        add (1|M0)               r82.1<1>:d    r82.1<0;1,0>:d    -r82.2<0;1,0>:d 
        mad (1|M0)               r84.4<1>:f    r84.4<0;0>:f      r88.1<0;0>:f      -r84.5<0>:f      {F@1}
(~f0.1.any16h) goto (16|M0)                  L8288                  L8288                
L7488:
        mov (1|M0)               r84.2<1>:f    r84.4<0;1,0>:f                   {F@1}
        mov (2|M0)               r87.0<1>:f    r88.0<1;1,0>:f                  
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r85.6         L8864                                 {A@1}
L7568:
        cmp (1|M0)    (eq)f1.0   null<1>:f     r84.4<0;1,0>:f    0.0:f              
(W)     mov (1|M0)               r1.3<1>:hf    0x1:hf                             
        add (1|M0)               r83.6<1>:d    r83.6<0;1,0>:d    125:w              
(W)     mov (1|M0)               r3.12<1>:hf   0x1:hf                             
(f1.0)  sel (1|M0)               r2.6<1>:w     r1.3<0;1,0>:w     0:w               {F@2}
        cmp (1|M0)    (lt)f0.0   null<1>:d     r83.6<0;1,0>:d    -2:w               {I@2}
        cmp (1|M0)    (ne)f0.1   null<1>:w     r2.6<0;1,0>:w     0:w               {I@2}
(W)     mov (1|M0)               r5.0<1>:hf    -qnan(0x1FF):hf                             
(f0.0)  sel (1|M0)               r3.13<1>:uw   r3.12<0;1,0>:uw   0x0:uw              {F@2}
(f0.1)  sel (1|M0)               r4.0<1>:uw    r3.12<0;1,0>:uw   0x0:uw             
        or (1|M0)     (ne)f1.1   null<1>:uw    r3.13<0;1,0>:uw   r4.0<0;1,0>:uw   {I@1}
(f1.1)  sel (1|M0)               r83.18<2>:b   r5.0<0;1,0>:w     0:w               {F@1}
        cmp (1|M0)    (ne)f1.1   null<1>:uw    r83.18<0;1,0>:ub  0x0:uw              {I@1}
(W)     and (1|M0)               f0.0<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(~f0.0.any16h) goto (16|M0)                  L7928                  L7928                
L7808:
(W)     mov (1|M0)               r1.3<1>:hf    0x1:hf                             
        and (1|M0)               r1.2<1>:d     r84.2<0;1,0>:d    -2139095041:d              
(W)     mov (1|M0)               r4.0<1>:f     0x800000:f                               {Compacted}
        shl (1|M0)               r83.7<1>:d    r83.7<0;1,0>:d    23:w              
(f1.0)  sel (1|M0)               r2.3<1>:d     r1.3<0;1,0>:w     0:w               {F@2}
        add (1|M0)               r83.7<1>:d    r83.7<0;1,0>:d    1065353216:d               {I@2}
        bfn.0xFE (1|M0)          r1.2<1>:ud    r1.2<0;0>:ud      r2.3<0;0>:ud      r4.0<0>:ud       {A@1} // s0|s1|s2
        mul (1|M0)               r83.7<1>:f    r83.7<0;1,0>:f    r1.2<0;1,0>:f    {A@1}
L7928:
        join (16|M0)                         L8288                                
L7944:
        and (1|M0)               r1.2<1>:d     r84.2<0;1,0>:d    -2147483648:d               {F@1}
        shl (1|M0)               r84.2<1>:d    r84.2<0;1,0>:d    1:w              
(W)     mov (1|M0)               r1.3<1>:hf    0x1:hf                             
        and (1|M0)               r1.3<1>:d     r84.2<0;1,0>:d    8388606:d               {I@1}
        and (1|M0)    (eq)f1.1   r84.2<1>:d    r84.2<0;1,0>:d    8388608:d              
(W)     mov (1|M0)               r2.5<1>:f     1.469368e-38:f                               {Compacted}
(f0.1)  sel (1|M0)               r2.3<1>:d     r1.3<0;1,0>:w     0:w               {F@2}
(W)     mov (1|M0)               r3.7<1>:f     0x800000:f                               {Compacted}
        or (1|M0)                r2.3<1>:d     r1.2<0;1,0>:d     r2.3<0;1,0>:d    {I@1}
(f1.1)  sel (1|M0)               r3.6<1>:d     r2.5<0;1,0>:d     12582912:d               {F@2}
        mov (1|M0)               r4.0<1>:f     0.25:f                               {Compacted}
        bfn.0xFE (1|M0)          r2.3<1>:ud    r3.7<0;0>:ud      r2.3<0;0>:ud      r1.3<0>:ud       {A@2} // s0|s1|s2
        or (1|M0)                r3.6<1>:d     r3.6<0;1,0>:d     r1.2<0;1,0>:d    {I@2}
        or (1|M0)                r2.4<1>:d     r1.2<0;1,0>:d     8388608:d              
        mad (1|M0)               r2.3<1>:f     r3.6<0;0>:f       r4.0<0;0>:f       r2.3<0>:f        {A@1}
        cmp (1|M0)    (eq)f0.0   null<1>:uw    r83.18<0;1,0>:ub  0x0:uw             
        add (1|M0)               r2.3<1>:f     r2.3<0;1,0>:f     -r2.4<0;1,0>:f   {A@1}
        mul (1|M0)               r2.4<1>:f     r2.4<0;1,0>:f     r2.4<0;1,0>:f   
        and (1|M0)    (ne)f1.1   null<1>:d     r84.0<0;1,0>:d    1:w              
        and (1|M0)               r2.4<1>:d     r2.4<0;1,0>:d     -2:w               {F@1}
        or (1|M0)                r2.4<1>:d     r2.4<0;1,0>:d     r2.3<0;1,0>:d    {I@1}
(~f0.0) mov (1|M0)               r2.4<1>:f     r83.7<0;1,0>:f                   {I@1}
(f1.1)  mov (1|M0)               r86.0<1>:f    r2.4<0;1,0>:f                    {F@1}
L8288:
        join (16|M0)                         L8632                                
L8304:
        add (1|M0)               r2.3<1>:d     r82.1<0;1,0>:d    126:w              
(W)     mov (1|M0)               r1.3<1>:uw    r84.0<0;1,0>:ub                 
        cmp (1|M0)    (gt)f0.0   null<1>:ud    r2.3<0;1,0>:ud    0x17A:uw              {I@2}
        mad (1|M0)               r84.4<1>:f    r88.1<0;0>:f      r88.0<0;0>:f      r84.4<0>:f      
        or (1|M0)                r84.2<1>:w    r83.16<0;1,0>:ub  r1.3<0;1,0>:uw   {I@2}
(W)     and (1|M0)               f1.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw              {F@2}
(~f1.1.any16h) goto (16|M0)                  L8496                  L8496                
L8416:
(f0.0)  sel (1|M0)               r1.2<1>:d     r82.1<0;1,0>:d    0:w              
        asr (1|M0)               r1.2<1>:d     r1.2<0;1,0>:d     11:w               {I@1}
        add (1|M0)               r1.3<1>:d     r1.2<0;1,0>:d     248:w               {I@1}
        xor (1|M0)               r1.3<1>:d     r1.3<0;1,0>:d     r1.2<0;1,0>:d    {I@1}
(f0.0)  mov (1|M0)               r82.1<1>:d    r1.3<0;1,0>:d                    {I@1}
L8496:
        join (16|M0)                         L8632                                
L8512:
        asr (1|M0)               r1.2<1>:d     r82.1<0;1,0>:d    1:w               {I@2}
        cmp (1|M0)    (eq)f1.0   null<1>:w     r84.2<0;1,0>:w    0:w              
        add (1|M0)               r82.1<1>:d    r82.1<0;1,0>:d    -r1.2<0;1,0>:d   {I@2}
        shl (1|M0)               r1.2<1>:d     r1.2<0;1,0>:d     23:w              
        shl (1|M0)               r82.1<1>:d    r82.1<0;1,0>:d    23:w               {Compacted,I@2}
        add (1|M0)               r1.2<1>:d     r1.2<0;1,0>:d     r84.4<0;1,0>:d   {A@1}
        add (1|M0)               r82.1<1>:d    r82.1<0;1,0>:d    1065353216:d               {I@2}
(f1.0)  mul (1|M0)               r86.0<1>:f    r82.1<0;1,0>:f    r1.2<0;1,0>:f    {I@1}
L8632:
        join (16|M0)                         L8648                                
L8648:
        sync.nop                             null                             {Compacted,F@1}
        math.inv (1|M0)          r1.2<1>:f     r85.1<0;1,0>:f                   {$9}
        mov (1|M0)               r1.4<1>:ud    0x3F800000:ud                             
        mul (1|M0)               r1.3<1>:f     r1.2<0;1,0>:f     r85.0<0;1,0>:f   {$9.dst}
        mad (1|M0)               r1.4<1>:f     r1.4<0;0>:f       r1.2<0;0>:f       -r85.1<0>:f      {I@1}
        mad (1|M0)               r2.3<1>:f     r85.0<0;0>:f      r1.3<0;0>:f       -r85.1<0>:f      {F@2}
        mad (1|M0)               r1.4<1>:f     r1.2<0;0>:f       r1.2<0;0>:f       r1.4<0>:f        {F@2}
        cmp (1|M0)    (eq)f0.1   null<1>:uw    r82.0<0;1,0>:ub   0x0:uw             
        mad (1|M0)               r2.3<1>:f     r1.3<0;0>:f       r1.4<0;0>:f       r2.3<0>:f        {F@1}
        mad (1|M0)               r85.0<1>:f    r85.0<0;0>:f      r2.3<0;0>:f       -r85.1<0>:f      {F@1}
(f0.1)  mad (1|M0)               r86.0<1>:f    r2.3<0;0>:f       r1.4<0;0>:f       r85.0<0>:f       {F@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        ret (16|M0)                          r84.6                            {A@1}
L8864:
        mov (1|M0)               r1.2<1>:d     cr0.0<0;1,0>:ud                  {A@1}
        and (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   -1265:w               {A@1}
        or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   1264:w               {A@1}
        mad (1|M0)               r84.2<1>:f    r87.1<0;0>:f      r87.0<0;0>:f      r84.2<0>:f       {A@1}
        mov (1|M0)               cr0.0<1>:ud   r1.2<0;1,0>:d                    {A@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        ret (16|M0)                          r85.6                            {A@1}
L8992:
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
