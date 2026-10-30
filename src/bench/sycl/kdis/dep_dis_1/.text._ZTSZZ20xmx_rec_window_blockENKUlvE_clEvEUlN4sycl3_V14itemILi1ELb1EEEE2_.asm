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
        and (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   -1265:w               {A@1}
        or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   1216:w               {A@1}
        sync.nop                             null                             {Compacted,A@1}
        sync.nop                             null                             {Compacted,$1.dst}
        mul (1|M0)               acc0.0<1>:ud  r2.0<0;1,0>:ud    r0.2<0;1,0>:uw   {A@1}
        mach (1|M0)              r6.0<1>:ud    r2.0<0;1,0>:ud    r0.1<0;1,0>:ud   {AccWrEn}
        mov (1|M0)               r1.2<1>:d     r1.0<0;1,0>:uw                   {$0.dst}
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        and (1|M0)               r1.6<2>:b     r3.12<0;1,0>:b    1:w              
        addc (1|M0)              r7.0<1>:ud    r5.0<0;1,0>:ud    r1.2<0;1,0>:ud   {AccWrEn,I@2}
        mov (1|M0)               r8.7<1>:d     r2.6<0;1,0>:d                   
        mov (1|M0)               r1.4<1>:d     r7.0<0;1,0>:d                    {I@2}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        shr (1|M0)               r2.4<1>:ud    r1.4<0;1,0>:ud    0x6:uw              {I@2}
        add3 (1|M0)              r1.5<1>:d     r8.0<0;0>:d       r6.0<0;0>:d       0:w               {I@2}
        mov (1|M0)               r14.5<1>:d    r2.4<0;1,0>:d                    {I@2}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r13.6         L2096                                 {A@1}
L480:
(W)     mul (1|M0)               acc0.0<1>:d   r52.0<0;1,0>:d    r2.12<0;1,0>:uw  {Compacted}
        shl (1|M0)               r1.6<1>:d     r52.0<0;1,0>:d    3:w               {Compacted}
        mach (1|M0)              r52.0<1>:d    r52.0<0;1,0>:d    r2.6<0;1,0>:d    {Compacted}
        and (1|M0)               r2.3<1>:d     r1.4<0;1,0>:d     7:w              
        add (1|M0)               r2.4<1>:d     r2.4<0;1,0>:d     -r52.0<0;1,0>:d  {I@2}
        shr (1|M0)               r1.7<1>:ud    r1.4<0;1,0>:ud    0x3:uw             
        shl (1|M0)               r2.4<1>:d     r2.4<0;1,0>:d     3:w               {I@2}
        and (1|M0)               r1.7<1>:ud    r1.7<0;1,0>:ud    0x7:uw              {I@2}
        add3 (1|M0)              r2.4<1>:d     r2.4<0;0>:d       r2.3<0;0>:d       -r3.0<0>:d       {I@2}
        add3 (1|M0)              r1.7<1>:d     r1.7<0;0>:d       r1.6<0;0>:d       -r2.7<0>:d       {I@2}
        cmp (1|M0)    (gt)f1.1   null<1>:d     r2.4<0;1,0>:d     -1:w               {I@2}
        cmp (1|M0)    (lt)f0.1   null<1>:d     r1.7<0;1,0>:d     r3.1<0;1,0>:d    {I@2}
(W)     mov (1|M0)               r13.4<1>:hf   0x1:hf                             
        cmp (1|M0)    (lt)f0.0   null<1>:d     r2.4<0;1,0>:d     r3.2<0;1,0>:d   
(f1.1)  cmp (1|M0)    (gt)f1.1   null<1>:d     r1.7<0;1,0>:d     -1:w              
(f0.1)  sel (1|M0)               r13.3<1>:uw   r13.4<0;1,0>:uw   0x0:uw              {F@1}
(f0.0)  sel (1|M0)               r12.14<1>:uw  r13.4<0;1,0>:uw   0x0:uw             
(f1.1)  sel (1|M0)               r13.2<1>:uw   r13.4<0;1,0>:uw   0x0:uw             
        and (1|M0)    (ne)f1.0   null<1>:uw    r13.2<0;1,0>:uw   r13.3<0;1,0>:uw  {I@1}
(f1.0)  sel (1|M0)               r3.7<1>:uw    r13.4<0;1,0>:uw   0x0:uw             
        and (1|M0)    (ne)f0.1   null<1>:uw    r3.7<0;1,0>:uw    r12.14<0;1,0>:uw {I@1}
(W)     and (1|M0)               f0.1<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(f0.1.any16h) goto (16|M0)                   L872                  L872                
L824:
        mov (8|M0)               r47.0<2>:f    0.0:f                              
        mov (8|M0)               r47.1<2>:d    0:d                               {F@1}
        goto (16|M0)                         L872                  L1832                
L872:
        join (16|M0)                         L1832                                
L888:
        mul (1|M0)               acc0.0<1>:ud  r1.7<0;1,0>:ud    r3.4<0;1,0>:uw  
        mach (1|M0)              r10.0<1>:ud   r1.7<0;1,0>:ud    r3.2<0;1,0>:ud   {AccWrEn}
        cmp (1|M0)    (eq)f0.0   null<1>:w     r1.6<0;1,0>:b     0:w              
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r11.0<1>:ud   r9.0<0;1,0>:ud    r2.4<0;1,0>:ud   {AccWrEn,I@1}
(W)     and (1|M0)               f0.0<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
        mov (1|M0)               r12.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        shr (1|M0)               r4.4<1>:ud    r11.0<0;1,0>:ud   0x1B:uw              {I@3}
        add3 (1|M0)              r4.3<1>:d     r12.0<0;0>:d      r10.0<0;0>:d      0:w               {I@2}
        shl (1|M0)               r4.5<1>:d     r11.0<0;1,0>:d    5:w               {Compacted}
        shl (1|M0)               r2.5<1>:d     r4.3<0;1,0>:d     5:w               {I@2}
        or (1|M0)                r4.6<1>:d     r2.5<0;1,0>:d     r4.4<0;1,0>:d    {I@1}
(f0.0.any16h) goto (16|M0)                   L1280                  L1280                
L1072:
        shl (1|M0)               r7.2<1>:d     r4.5<0;1,0>:d     1:w              
        shl (1|M0)               r4.7<1>:d     r4.6<0;1,0>:d     1:w               {I@3}
        shr (1|M0)               r7.1<1>:ud    r4.5<0;1,0>:ud    0x1F:uw             
        addc (1|M0)              r13.0<1>:ud   r3.4<0;1,0>:ud    r7.2<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r7.3<1>:d     r4.7<0;1,0>:d     r7.1<0;1,0>:d    {I@2}
        mov (1|M0)               r14.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r15.0<1>:f    r13.0<0;1,0>:f                   {Compacted,I@3}
        add3 (1|M0)              r15.1<1>:d    r14.0<0;0>:d      r3.5<0;0>:d       r7.3<0>:d        {I@1}
        send.ugm (1|M0)          r16      r15     null:0  0x0            0x0220C780           {A@1,$3} // wr:1+0, rd:2; load.ugm.d64x8t.a64
        mov (8|M0)               r21.0<1>:f    r16.0<1;1,0>:hf                  {$3.dst}
        mov (8|M0)               r22.0<1>:f    r16.8<1;1,0>:hf                 
        mov (8|M0)               r23.0<1>:f    r17.0<1;1,0>:hf                 
        mov (8|M0)               r24.0<1>:f    r17.8<1;1,0>:hf                 
        goto (16|M0)                         L1280                  L1424                
L1280:
        join (16|M0)                         L1424                                
L1296:
        shl (1|M0)               r7.6<1>:d     r4.5<0;1,0>:d     2:w              
        shl (1|M0)               r7.4<1>:d     r4.6<0;1,0>:d     2:w              
        shr (1|M0)               r7.5<1>:ud    r4.5<0;1,0>:ud    0x1E:uw             
        addc (1|M0)              r18.0<1>:ud   r3.6<0;1,0>:ud    r7.6<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r7.7<1>:d     r7.4<0;1,0>:d     r7.5<0;1,0>:d    {I@2}
        mov (1|M0)               r19.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r20.0<1>:f    r18.0<0;1,0>:f                   {Compacted,I@3}
        add3 (1|M0)              r20.1<1>:d    r19.0<0;0>:d      r3.7<0;0>:d       r7.7<0>:d        {I@1}
        send.ugm (1|M0)          r21      r20     null:0  0x0            0x0240D780           {A@1,$4} // wr:1+0, rd:4; load.ugm.d64x16t.a64
L1424:
        join (16|M0)                         L1832                                
L1440:
        sel (16|M0)   (lt)f0.0   r39.0<1>:f    (abs)r21.0<1;1,0>:f  448.0:f            {Compacted,$4.dst}
        sel (16|M0)   (lt)f0.0   r41.0<1>:f    (abs)r23.0<1;1,0>:f  448.0:f            {Compacted}
        shr (16|M0)              r25.0<1>:ud   r39.0<1;1,0>:ud   0x17:uw              {F@2}
        shr (16|M0)              r27.0<1>:ud   r41.0<1;1,0>:ud   0x17:uw              {F@1}
        sel (16|M0)   (ge)f0.0   r29.0<2>:ub   r25.0<4;1,0>:ub   0x79:uw              {I@2}
        sel (16|M0)   (ge)f0.0   r30.0<2>:ub   r27.0<4;1,0>:ub   0x79:uw              {I@2}
        mov (16|M0)              r35.0<1>:d    r29.0<2;1,0>:ub                  {I@2}
        mov (16|M0)              r37.0<1>:d    r30.0<2;1,0>:ub                  {I@2}
        shl (16|M0)              r35.0<1>:d    r35.0<1;1,0>:d    23:w               {Compacted,I@2}
        shl (16|M0)              r37.0<1>:d    r37.0<1;1,0>:d    23:w               {Compacted,I@2}
        add (16|M0)              r31.0<1>:d    r35.0<1;1,0>:d    -25165824:d               {I@2}
        add (16|M0)              r33.0<1>:d    r37.0<1;1,0>:d    -25165824:d               {I@2}
        add (16|M0)              r35.0<1>:d    -r35.0<1;1,0>:d   -2139095040:d              
        add (16|M0)              r37.0<1>:d    -r37.0<1;1,0>:d   -2139095040:d              
        mul (16|M0)              acc0.0<1>:f   r39.0<1;1,0>:f    r35.0<1;1,0>:f   {Compacted,I@2}
        mul (16|M0)              acc2.0<1>:f   r41.0<1;1,0>:f    r37.0<1;1,0>:f   {Compacted,I@1}
        rnde (16|M0)             acc0.0<1>:f   acc0.0<1;1,0>:f                 
        rnde (16|M0)             acc2.0<1>:f   acc2.0<1;1,0>:f                 
        cmp (16|M0)   (lt)f1.1   null<1>:f     r21.0<1;1,0>:f    0.0:f              
        cmp (16|M0)   (lt)f1.0   null<1>:f     r23.0<1;1,0>:f    0.0:f               {Compacted}
        mul (16|M0)              acc0.0<1>:f   acc0.0<1;1,0>:f   r31.0<1;1,0>:f   {Compacted}
        mul (16|M0)              acc2.0<1>:f   acc2.0<1;1,0>:f   r33.0<1;1,0>:f   {Compacted}
        mov (16|M0)              r43.0<1>:f    (abs)acc0.0<1;1,0>:f             {Compacted}
        mov (16|M0)              r45.0<1>:f    (abs)acc2.0<1;1,0>:f             {Compacted}
(f1.1)  or (16|M0)               r43.0<1>:d    r43.0<1;1,0>:d    -2147483648:d               {F@2}
(f1.0)  or (16|M0)               r45.0<1>:d    r45.0<1;1,0>:d    -2147483648:d               {F@1}
        mov (8|M0)               r47.0<1>:hf   r43.0<1;1,0>:f                   {I@2}
        mov (8|M0)               r47.8<1>:hf   r44.0<1;1,0>:f                  
        mov (8|M0)               r48.0<1>:hf   r45.0<1;1,0>:f                   {I@1}
        mov (8|M0)               r48.8<1>:hf   r46.0<1;1,0>:f                  
L1832:
        join (16|M0)                         L1848                                
L1848:
        shl (1|M0)               r8.1<1>:d     r1.5<0;1,0>:d     5:w              
        shr (1|M0)               r8.2<1>:ud    r1.4<0;1,0>:ud    0x1B:uw             
        shl (1|M0)               r8.3<1>:d     r1.4<0;1,0>:d     5:w              
        or (1|M0)                r8.4<1>:d     r8.1<0;1,0>:d     r8.2<0;1,0>:d    {I@2}
        shl (1|M0)               r11.1<1>:d    r8.3<0;1,0>:d     1:w               {I@2}
        shr (1|M0)               r8.6<1>:ud    r8.3<0;1,0>:ud    0x1F:uw             
        shl (1|M0)               r8.5<1>:d     r8.4<0;1,0>:d     1:w               {I@3}
        addc (1|M0)              r49.0<1>:ud   r4.0<0;1,0>:ud    r11.1<0;1,0>:ud  {AccWrEn,I@3}
        or (1|M0)                r11.2<1>:d    r8.5<0;1,0>:d     r8.6<0;1,0>:d    {I@2}
        mov (1|M0)               r50.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r51.0<1>:f    r49.0<0;1,0>:f                   {Compacted,I@3}
        add3 (1|M0)              r51.1<1>:d    r50.0<0;0>:d      r4.1<0;0>:d       r11.2<0>:d       {I@1}
(W)     mov (8|M0)               r127.0<1>:f   r0.0<1;1,0>:f                    {Compacted}
        send.ugm (1|M0)          null     r51     r47:2   0x0            0x0200C784           {A@1,$5} // wr:1+2, rd:0; store.ugm.d64x8t.a64
(W)     send.ugm (1|M0)          r54      r0      null:0  0x0            0x0210641F           {$6} // wr:1+0, rd:1; fence invalid flush type scoped to tile
(W)     mov (8|M0)               null<1>:ud    r54.0<1;1,0>:ud                  {$6.dst}
(W)     send.gtwy (1|M0)         null     r127    null:0  0x0            0x02000010           {EOT,A@1} // wr:1+0, rd:0; end of thread
L2096:
        mov (1|M0)               r11.3<1>:d    cr0.0<0;1,0>:ud                  {A@1}
        and (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   -1265:w               {A@1}
        or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   1264:w               {A@1}
        mov (1|M0)               r11.4<1>:f    r8.7<0;1,0>:ud                   {A@1}
        mov (1|M0)               r11.7<1>:f    0xB4C00000:f                               {Compacted}
        math.inv (1|M0)          r12.3<1>:f    r11.4<0;1,0>:f                   {@2,$7}
        mov (1|M0)               r13.5<1>:f    r14.5<0;1,0>:ud                 
        sync.nop                             null                             {Compacted,$7.dst}
        mad (1|M0)               r12.3<1>:f    r12.3<0;0>:f      r11.7<0;0>:f      r12.3<0>:f       {F@2}
        mov (1|M0)               r14.4<1>:ud   r11.4<0;1,0>:f                  
        mov (1|M0)               r11.5<1>:ud   r13.5<0;1,0>:f                   {F@2}
        mul (1|M0)               r12.1<1>:f    r12.3<0;1,0>:f    r13.5<0;1,0>:f   {F@1}
        add (1|M0)               r14.4<1>:ud   r8.7<0;1,0>:ud    -r14.4<0;1,0>:ud {I@2}
        add (1|M0)               r11.5<1>:ud   r14.5<0;1,0>:ud   -r11.5<0;1,0>:ud {I@2}
        mov (1|M0)               r12.5<1>:ud   r12.1<0;1,0>:f                   {F@1}
        mov (1|M0)               r13.4<1>:f    r14.4<0;1,0>:ud                  {I@3}
        mov (1|M0)               r11.6<1>:f    r11.5<0;1,0>:ud                  {I@2}
        mov (1|M0)               r12.2<1>:f    r12.5<0;1,0>:ud                  {I@1}
(W)     mov (1|M0)               r13.5<1>:hf   0x1:hf                             
        mad (1|M0)               r13.5<1>:f    r13.5<0;0>:f      r12.2<0;0>:f      -r11.4<0>:f      {F@2}
        mad (1|M0)               r12.2<1>:f    r11.6<0;0>:f      r12.2<0;0>:f      -r13.4<0>:f     
        add (1|M0)               r13.5<1>:f    r13.5<0;1,0>:f    r12.2<0;1,0>:f   {F@1}
        mul (1|M0)               r12.3<1>:f    r12.3<0;1,0>:f    r13.5<0;1,0>:f   {F@1}
        mov (1|M0)               r12.4<1>:ud   r12.3<0;1,0>:f                   {F@1}
        add (1|M0)               r12.5<1>:ud   r12.5<0;1,0>:ud   r12.4<0;1,0>:ud  {I@1}
(W)     mul (1|M0)               acc0.0<1>:ud  r12.5<0;1,0>:ud   r8.14<0;1,0>:uw  {I@1}
        mach (1|M0)              r53.0<1>:ud   r12.5<0;1,0>:ud   r8.7<0;1,0>:ud  
        add (1|M0)               r14.5<1>:ud   r14.5<0;1,0>:ud   -r53.0<0;1,0>:ud {I@1}
        cmp (1|M0)    (ge)f0.0   null<1>:ud    r14.5<0;1,0>:ud   r8.7<0;1,0>:ud   {I@1}
(f0.0)  sel (1|M0)               r12.6<1>:d    r13.5<0;1,0>:w    0:w              
        add (1|M0)               r52.0<1>:ud   r12.5<0;1,0>:ud   r12.6<0;1,0>:ud  {I@1}
        mov (1|M0)               cr0.0<1>:ud   r11.3<0;1,0>:d                   {A@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        ret (16|M0)                          r13.6                            {A@1}
L2640:
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
