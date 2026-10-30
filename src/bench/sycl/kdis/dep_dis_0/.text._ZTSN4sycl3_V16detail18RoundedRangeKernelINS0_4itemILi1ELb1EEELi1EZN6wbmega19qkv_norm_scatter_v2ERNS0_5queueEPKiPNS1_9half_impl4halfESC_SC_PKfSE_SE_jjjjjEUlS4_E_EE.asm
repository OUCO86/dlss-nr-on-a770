L0:
(W)     mov (8|M0)               r127.0<1>:ud  0x0:ud                              {A@1}
(W)     and (1|M0)               r127.2<1>:ud  r0.0<0;1,0>:ud    0xFFFFFFC0:ud             
(W)     and (1|M0)               r127.0<1>:uw  r0.4<0;1,0>:uw    0xFF:uw             
(W)     add (1|M0)               r127.2<1>:ud  r127.2<0;1,0>:ud  0xE0:ud              {I@2}
(W)     mad (1|M0)               r127.2<1>:ud  r127.2<0;0>:ud    r127.0<0;0>:uw    0x20:uw              {I@1}
(W)     send.dc0 (8|M0)          r1       r127    null:0  0x0            0x021842FD           {A@1,$0} // wr:1h+0, rd:1; oword aligned block read x2
        nop                    
        nop                    
(W)     mov (8|M0)               r127.0<1>:ud  0x0:ud                              {$0.src}
(W)     and (1|M0)               r127.2<1>:ud  r0.0<0;1,0>:ud    0xFFFFFFC0:ud             
(W)     send.dc0 (8|M0)          r2       r127    null:0  0x0            0x024844FD           {A@1,$1} // wr:1h+0, rd:4; oword aligned block read x8
(W)     add (1|M0)               r127.2<1>:ud  r127.2<0;1,0>:ud  0x80:uw              {$1.src}
(W)     send.dc0 (8|M0)          r6       r127    null:0  0x0            0x022843FD           {A@1,$2} // wr:1h+0, rd:2; oword aligned block read x4
(W)     add (1|M0)               r127.2<1>:ud  r127.2<0;1,0>:ud  0x40:uw              {$2.src}
(W)     send.dc0 (8|M0)          r8       r127    null:0  0x0            0x021842FD           {A@1,$3} // wr:1h+0, rd:1; oword aligned block read x2
        and (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   -1265:w               {A@1}
        or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   1216:w               {A@1}
        sync.nop                             null                             {Compacted,A@1}
        sync.nop                             null                             {Compacted,$1.dst}
        mul (1|M0)               acc0.0<1>:ud  r2.3<0;1,0>:ud    r0.2<0;1,0>:uw   {A@1}
        mach (1|M0)              r5.0<1>:ud    r2.3<0;1,0>:ud    r0.1<0;1,0>:ud   {AccWrEn}
        mov (1|M0)               r1.2<1>:d     r1.0<0;1,0>:uw                   {$0.dst}
        mov (1|M0)               r4.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
(W)     mov (1|M0)               r1.3<1>:hf    0x1:hf                             
        addc (1|M0)              r9.0<1>:ud    r4.0<0;1,0>:ud    r1.2<0;1,0>:ud   {AccWrEn,I@1}
        mov (1|M0)               r23.6<1>:d    r9.0<0;1,0>:d                    {I@1}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        cmp (1|M0)    (lt)f0.0   null<1>:ud    r23.6<0;1,0>:ud   r3.0<0;1,0>:ud   {I@2}
        add3 (1|M0)              r23.7<1>:d    r10.0<0;0>:d      r5.0<0;0>:d       0:w               {I@2}
        mul (1|M0)               acc0.0<1>:ud  r2.0<0;1,0>:ud    r2.6<0;1,0>:uw  
        cmp (1|M0)    (lt)f0.1   null<1>:ud    r23.7<0;1,0>:ud   r3.1<0;1,0>:ud   {I@2}
(f0.0)  cmp (1|M0)    (eq)f0.0   null<1>:d     r23.7<0;1,0>:d    r3.1<0;1,0>:d   
        mach (1|M0)              r12.0<1>:ud   r2.0<0;1,0>:ud    r2.3<0;1,0>:ud   {AccWrEn}
(f0.1)  sel (1|M0)               r2.12<1>:uw   r1.3<0;1,0>:uw    0x0:uw              {F@1}
(f0.0)  sel (1|M0)               r1.4<1>:uw    r1.3<0;1,0>:uw    0x0:uw             
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        or (1|M0)     (ne)f0.0   null<1>:uw    r1.4<0;1,0>:uw    r2.12<0;1,0>:uw  {I@2}
        mov (1|M0)               r23.1<1>:d    r12.0<0;1,0>:d                  
        mov (1|M0)               r23.0<1>:f    r11.0<0;1,0>:f                   {Compacted,I@3}
(W)     and (1|M0)               f0.0<1>:ud    f0.0<0;1,0>:uw    0x1:uw             
(~f0.0.any32h) goto (32|M0)                  L6424                  L6424                
L608:
        mul (1|M0)               r23.2<1>:d    r6.0<0;1,0>:d     3:w               {Compacted,$2.dst}
        mov (1|M0)               r23.3<1>:d    r7.4<0;1,0>:d                   
        mov (1|M0)               r23.4<1>:d    0:w                              
L648:
(W)     mul (1|M0)               acc0.0<1>:ud  r23.6<0;1,0>:ud   0xAAAB:uw             
(W)     mach (1|M0)              r4.0<1>:ud    r23.6<0;1,0>:ud   0xAAAAAAAB:ud              {AccWrEn}
        mov (1|M0)               r47.5<1>:d    r23.6<0;1,0>:d                  
        mov (1|M0)               r47.1<1>:ud   r4.0<0;1,0>:ud                   {I@2}
        mov (1|M0)               r43.5<1>:d    r6.0<0;1,0>:d                   
        shr (1|M0)               r47.1<1>:ud   r47.1<0;1,0>:ud   0x1:uw              {I@2}
        mul (1|M0)               r23.5<1>:d    r47.1<0;1,0>:d    -3:w               {I@1}
        add (1|M0)               r23.5<1>:d    r23.5<0;1,0>:d    r23.6<0;1,0>:d   {I@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (32|M0)             r46.6         L6496                                 {A@1}
L824:
        mov (1|M0)               r46.4<1>:d    r23.2<0;1,0>:d                  
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (32|M0)             r47.2         L6976                                 {A@1}
L888:
        mov (1|M0)               r36.1<1>:d    r46.5<0;1,0>:d                  
        shl (1|M0)               r2.6<1>:d     r36.0<0;1,0>:d    5:w               {Compacted}
        shl (1|M0)               r1.3<1>:d     r36.1<0;1,0>:d    2:w               {I@2}
        shr (1|M0)               r1.2<1>:ud    r36.1<0;1,0>:ud   0x1E:uw             
        addc (1|M0)              r4.0<1>:ud    r6.2<0;1,0>:ud    r1.3<0;1,0>:ud   {AccWrEn,I@2}
        or (1|M0)                r1.4<1>:d     r1.2<0;1,0>:d     0:w               {I@2}
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r23.5<0;1,0>:d    r6.8<0;1,0>:uw  
        mach (1|M0)              r11.0<1>:d    r23.5<0;1,0>:d    r6.4<0;1,0>:d    {F@1}
        mul (1|M0)               acc0.0<1>:ud  r36.1<0;1,0>:ud   r7.0<0;1,0>:uw  
        mach (1|M0)              r13.0<1>:ud   r36.1<0;1,0>:ud   r7.0<0;1,0>:ud   {AccWrEn}
        add3 (1|M0)              r10.1<1>:d    r5.0<0;0>:d       r6.3<0;0>:d       r1.4<0>:d        {I@5}
        mov (1|M0)               r12.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        add (1|M0)               r1.4<1>:d     r11.0<0;1,0>:d    r2.6<0;1,0>:d    {I@5}
        shl (1|M0)               r3.3<1>:d     r12.0<0;1,0>:d    2:w               {Compacted,I@2}
        mov (1|M0)               r10.0<1>:f    r4.0<0;1,0>:f                    {Compacted}
        shl (1|M0)               r2.7<1>:d     r13.0<0;1,0>:d    2:w               {Compacted}
        shr (1|M0)               r3.2<1>:ud    r12.0<0;1,0>:ud   0x1E:uw             
        shl (1|M0)               r4.1<1>:d     r1.4<0;1,0>:d     2:w               {I@4}
        addc (1|M0)              r4.0<1>:ud    r6.6<0;1,0>:ud    r3.3<0;1,0>:ud   {AccWrEn,A@1}
        send.ugm (1|M0)          r9       r10     null:0  0x0            0x04100580           {$5} // wr:2+0, rd:1; load.ugm.d32.a64
        shr (1|M0)               r1.6<1>:ud    r1.4<0;1,0>:ud    0x1E:uw             
        or (1|M0)                r3.4<1>:d     r2.7<0;1,0>:d     r3.2<0;1,0>:d    {I@4}
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        sync.nop                             null                             {Compacted,$5.src}
        addc (1|M0)              r10.0<1>:ud   r4.0<0;1,0>:ud    r4.1<0;1,0>:ud   {AccWrEn,I@4}
        or (1|M0)                r4.2<1>:d     r1.6<0;1,0>:d     0:w               {I@4}
        add3 (1|M0)              r1.3<1>:d     r5.0<0;0>:d       r6.7<0;0>:d       r3.4<0>:d        {I@3}
        mov (1|M0)               r14.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r15.0<1>:f    r10.0<0;1,0>:f                   {Compacted,I@4}
        addc (1|M0)              r5.0<1>:ud    r7.2<0;1,0>:ud    r4.1<0;1,0>:ud   {AccWrEn}
        add3 (1|M0)              r15.1<1>:d    r14.0<0;0>:d      r1.3<0;0>:d       r4.2<0>:d        {I@2}
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        send.ugm (1|M0)          r16      r15     null:0  0x0            0x0240D780           {A@1,$6} // wr:1+0, rd:4; load.ugm.d64x16t.a64
        mov (1|M0)               r22.0<1>:f    r5.0<0;1,0>:f                    {Compacted}
        add3 (1|M0)              r22.1<1>:d    r11.0<0;0>:d      r7.3<0;0>:d       r4.2<0>:d        {I@1}
        mov (1|M0)               r46.4<1>:f    r7.4<0;1,0>:f                   
        send.ugm (1|M0)          r37      r22     null:0  0x0            0x0240D780           {A@1,$7} // wr:1+0, rd:4; load.ugm.d64x16t.a64
        mov (1|M0)               r47.5<1>:d    r36.1<0;1,0>:d                  
        mov (16|M0)              r12.0<1>:f    r16.0<1;1,0>:d                   {Compacted,$6.dst}
        mov (16|M0)              r20.0<1>:f    r18.0<1;1,0>:d                   {Compacted}
        sync.nop                             null                             {Compacted,$5.dst}
        mul (16|M0)              acc0.0<1>:f   r9.0<0;1,0>:f     r12.0<1;1,0>:f   {Compacted,F@2}
        mul (16|M0)              acc2.0<1>:f   r9.0<0;1,0>:f     r20.0<1;1,0>:f   {Compacted,F@2}
        mul (16|M0)              r37.0<1>:f    acc0.0<1;1,0>:f   r37.0<1;1,0>:f   {Compacted,$7.dst}
        mul (16|M0)              r39.0<1>:f    acc2.0<1;1,0>:f   r39.0<1;1,0>:f   {Compacted}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (32|M0)             r47.2         L6976                                 {A@1}
L1520:
(W)     mul (1|M0)               acc0.0<1>:d   r46.5<0;1,0>:d    r7.8<0;1,0>:uw   {A@2}
        mach (1|M0)              r4.0<1>:d     r46.5<0;1,0>:d    r7.4<0;1,0>:d   
        mul (1|M0)               acc0.0<1>:ud  r46.5<0;1,0>:ud   r6.0<0;1,0>:uw  
        mach (1|M0)              r10.0<1>:ud   r46.5<0;1,0>:ud   r6.0<0;1,0>:ud   {AccWrEn}
        mov (1|M0)               r36.2<1>:d    r36.0<0;1,0>:d                  
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r36.3<1>:d    0:w                              
        addc (1|M0)              r5.0<1>:ud    r9.0<0;1,0>:ud    r36.2<0;1,0>:ud  {AccWrEn,I@2}
        add (1|M0)               r3.2<1>:d     r36.1<0;1,0>:d    -r4.0<0;1,0>:d  
        mov (1|M0)               r1.2<1>:d     r5.0<0;1,0>:d                    {I@2}
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mul (1|M0)               acc0.0<1>:ud  r1.2<0;1,0>:ud    r23.6<0;1,0>:uw  {I@2}
        mach (1|M0)              r13.0<1>:ud   r1.2<0;1,0>:ud    r23.3<0;1,0>:ud  {AccWrEn}
        add3 (1|M0)              r1.3<1>:d     r11.0<0;0>:d      r10.0<0;0>:d      r36.3<0>:d       {I@3}
        mov (1|M0)               r12.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r1.2<0;1,0>:d     r23.8<0;1,0>:uw 
        mach (1|M0)              r14.0<1>:d    r1.2<0;1,0>:d     r23.4<0;1,0>:d  
(W)     mul (1|M0)               acc0.0<1>:d   r1.3<0;1,0>:d     r23.6<0;1,0>:uw  {I@4}
        cmp (1|M0)    (eq)f0.0   null<1>:d     r23.5<0;1,0>:d    2:w              
        mach (1|M0)              r15.0<1>:d    r1.3<0;1,0>:d     r23.3<0;1,0>:d  
        addc (1|M0)              r16.0<1>:ud   r12.0<0;1,0>:ud   r3.2<0;1,0>:ud   {AccWrEn,I@6}
        add3 (1|M0)              r2.7<1>:d     r15.0<0;0>:d      r13.0<0;0>:d      r14.0<0>:d       {I@2}
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
(W)     and (1|M0)               f0.0<1>:ud    f0.0<0;1,0>:uw    0x1:uw             
        add3 (1|M0)              r8.7<1>:d     r5.0<0;0>:d       r2.7<0;0>:d       0:w               {I@2}
        shr (1|M0)               r6.5<1>:ud    r16.0<0;1,0>:ud   0x1B:uw             
        shl (1|M0)               r6.1<1>:d     r8.7<0;1,0>:d     5:w               {I@2}
        shl (1|M0)               r46.0<1>:d    r16.0<0;1,0>:d    5:w               {Compacted}
        or (1|M0)                r46.1<1>:d    r6.1<0;1,0>:d     r6.5<0;1,0>:d    {I@2}
(f0.0.any32h) goto (32|M0)                   L5368                  L5368                
L1960:
        mov (1|M0)               r36.4<2>:f    0.0:f                              
        mov (1|M0)               r36.5<2>:d    0:d                              
        mov (1|M0)               r36.6<1>:d    0:w                              
L2008:
        addc (1|M0)              r4.0<1>:ud    r36.4<0;1,0>:ud   0x1:ud              {AccWrEn,F@1}
        shl (1|M0)               r1.3<1>:w     r36.12<0;1,0>:w   2:w               {I@2}
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r41.0<1>:f    r4.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r41.1<1>:d    r5.0<0;0>:d       r36.5<0;0>:d      0:w               {I@1}
        add (1|M0)               a0.1<1>:uw    r1.3<0;1,0>:uw    0x4A0:uw              {A@1}
        cmp (1|M0)    (eq)f0.0   null<1>:d     r41.1<0;1,0>:d    0:w               {I@2}
        shl (1|M0)               r2.12<1>:w    r36.8<0;1,0>:w    2:w              
        add (1|M0)               r36.6<1>:d    r36.6<0;1,0>:d    1:w              
        add (1|M0)               a0.0<1>:uw    r2.12<0;1,0>:uw   0x380:uw              {A@1}
(f0.0)  cmp (1|M0)    (eq)f0.0   null<1>:d     r41.0<0;1,0>:d    32:w               {F@1}
        mov (1|M0)               r[a0.0]<1>:f  r[a0.1]<0;1,0>:f                
(W)     and (1|M0)               f0.0<1>:ud    f0.0<0;1,0>:uw    0x1:uw              {A@1}
(f0.0.any32h) goto (32|M0)                   L2248                  L2248                
L2216:
(W)     mov (2|M0)               r36.4<1>:ud   r41.0<1;1,0>:ud                 
        goto.b (32|M0)                       L2248                  L2008                
L2248:
        join (32|M0)                         L5368                                
L2264:
        mov (1|M0)               r41.2<2>:f    0.0:f                              
        mov (1|M0)               r41.3<2>:d    0:d                              
L2296:
        addc (1|M0)              r4.0<1>:ud    r41.2<0;1,0>:ud   0x1:ud              {AccWrEn,F@1}
        shl (1|M0)               r1.3<1>:w     r41.4<0;1,0>:w    2:w              
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r41.4<1>:d    r4.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r41.5<1>:d    r5.0<0;0>:d       r41.3<0;0>:d      0:w               {I@2}
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0x380:uw              {A@1}
        cmp (1|M0)    (eq)f0.0   null<1>:d     r41.5<0;1,0>:d    0:w               {I@2}
        mov (1|M0)               r1.4<2>:hf    r[a0.0]<0;1,0>:f                
(f0.0)  cmp (1|M0)    (eq)f0.0   null<1>:d     r41.4<0;1,0>:d    32:w               {A@1}
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0x300:uw              {A@1}
        mov (1|M0)               r[a0.0]<1>:f  r1.4<0;1,0>:hf                   {F@1}
(W)     and (1|M0)               f0.0<1>:ud    f0.0<0;1,0>:uw    0x1:uw             
(f0.0.any32h) goto (32|M0)                   L2528                  L2528                
L2496:
(W)     mov (2|M0)               r41.2<1>:ud   r41.4<1;1,0>:ud                 
        goto.b (32|M0)                       L2528                  L2296                
L2528:
        join (32|M0)                         L5368                                
L2544:
        mul (1|M0)               r1.2<1>:f     r24.0<0;1,0>:f    r24.0<0;1,0>:f   {Compacted,F@1}
        mul (1|M0)               r4.1<1>:f     r26.0<0;1,0>:f    r26.0<0;1,0>:f   {Compacted}
        mov (1|M0)               r2.12<2>:hf   r1.2<0;1,0>:f                    {F@2}
        mul (1|M0)               r8.6<1>:f     r24.1<0;1,0>:f    r24.1<0;1,0>:f  
        mov (1|M0)               r3.2<1>:f     r2.12<0;1,0>:hf                  {F@2}
        mul (1|M0)               r2.7<1>:f     r26.1<0;1,0>:f    r26.1<0;1,0>:f  
        mov (1|M0)               r5.0<2>:hf    r4.1<0;1,0>:f                   
        mov (1|M0)               r9.0<2>:hf    r8.6<0;1,0>:f                    {F@4}
        mad (1|M0)               r3.2<1>:f     r3.2<0;0>:f       r25.0<0;0>:f      r25.0<0>:f       {F@4}
        mov (1|M0)               r6.1<1>:f     r5.0<0;1,0>:hf                   {F@3}
        mov (1|M0)               r1.2<1>:f     r9.0<0;1,0>:hf                   {F@3}
        mov (1|M0)               r4.0<2>:hf    r3.2<0;1,0>:f                    {F@3}
        mov (1|M0)               r3.4<2>:hf    r2.7<0;1,0>:f                   
        mad (1|M0)               r6.1<1>:f     r6.1<0;0>:f       r27.0<0;0>:f      r27.0<0>:f       {F@4}
        mad (1|M0)               r1.2<1>:f     r1.2<0;0>:f       r25.1<0;0>:f      r25.1<0>:f       {F@4}
        mov (1|M0)               r4.1<1>:f     r3.4<0;1,0>:hf                   {F@3}
        mov (1|M0)               r7.2<2>:hf    r6.1<0;1,0>:f                    {F@3}
        mov (1|M0)               r2.12<2>:hf   r1.2<0;1,0>:f                    {F@3}
        mad (1|M0)               r4.1<1>:f     r4.1<0;0>:f       r27.1<0;0>:f      r27.1<0>:f       {F@3}
        mul (1|M0)               r6.1<1>:f     r24.2<0;1,0>:f    r24.2<0;1,0>:f  
        mul (1|M0)               r1.2<1>:f     r26.2<0;1,0>:f    r26.2<0;1,0>:f  
        add (1|M0)               r4.0<1>:hf    r4.0<0;1,0>:hf    r7.2<0;1,0>:hf   {F@5}
        mov (1|M0)               r5.0<2>:hf    r4.1<0;1,0>:f                    {F@4}
        mov (1|M0)               r7.2<2>:hf    r6.1<0;1,0>:f                    {F@4}
        mov (1|M0)               r9.2<2>:hf    r1.2<0;1,0>:f                    {F@4}
        mul (1|M0)               r4.1<1>:f     r24.3<0;1,0>:f    r24.3<0;1,0>:f  
        add (1|M0)               r2.12<1>:hf   r2.12<0;1,0>:hf   r5.0<0;1,0>:hf   {F@4}
        mov (1|M0)               r8.6<1>:f     r7.2<0;1,0>:hf                   {F@4}
        mov (1|M0)               r2.7<1>:f     r9.2<0;1,0>:hf                   {F@4}
        mov (1|M0)               r5.0<2>:hf    r4.1<0;1,0>:f                    {F@4}
        mad (1|M0)               r8.6<1>:f     r8.6<0;0>:f       r25.2<0;0>:f      r25.2<0>:f       {F@3}
        mad (1|M0)               r2.7<1>:f     r2.7<0;0>:f       r27.2<0;0>:f      r27.2<0>:f       {F@3}
        mov (1|M0)               r6.1<1>:f     r5.0<0;1,0>:hf                   {F@3}
        mul (1|M0)               r7.5<1>:f     r26.3<0;1,0>:f    r26.3<0;1,0>:f  
        mul (1|M0)               r5.1<1>:f     r26.4<0;1,0>:f    r26.4<0;1,0>:f  
        mov (1|M0)               r9.0<2>:hf    r8.6<0;1,0>:f                    {F@5}
        mov (1|M0)               r3.4<2>:hf    r2.7<0;1,0>:f                    {F@5}
        mad (1|M0)               r6.1<1>:f     r6.1<0;0>:f       r25.3<0;0>:f      r25.3<0>:f       {F@5}
        mul (1|M0)               r2.7<1>:f     r24.4<0;1,0>:f    r24.4<0;1,0>:f  
        mov (1|M0)               r8.12<2>:hf   r7.5<0;1,0>:f                    {F@6}
        add (1|M0)               r9.0<1>:hf    r9.0<0;1,0>:hf    r3.4<0;1,0>:hf   {F@4}
        mov (1|M0)               r7.2<2>:hf    r6.1<0;1,0>:f                    {F@4}
        mov (1|M0)               r3.4<2>:hf    r2.7<0;1,0>:f                    {F@4}
        mov (1|M0)               r6.2<2>:hf    r5.1<0;1,0>:f                   
        mov (1|M0)               r1.2<1>:f     r8.12<0;1,0>:hf                  {F@5}
        mov (1|M0)               r4.1<1>:f     r3.4<0;1,0>:hf                   {F@3}
        mov (1|M0)               r7.5<1>:f     r6.2<0;1,0>:hf                   {F@3}
        mad (1|M0)               r1.2<1>:f     r1.2<0;0>:f       r27.3<0;0>:f      r27.3<0>:f       {F@3}
        mad (1|M0)               r4.1<1>:f     r4.1<0;0>:f       r25.4<0;0>:f      r25.4<0>:f       {F@3}
        mad (1|M0)               r7.5<1>:f     r7.5<0;0>:f       r27.4<0;0>:f      r27.4<0>:f       {F@3}
        mul (1|M0)               r3.3<1>:f     r26.5<0;1,0>:f    r26.5<0;1,0>:f  
        mov (1|M0)               r9.2<2>:hf    r1.2<0;1,0>:f                    {F@4}
        mov (1|M0)               r5.0<2>:hf    r4.1<0;1,0>:f                    {F@4}
        mov (1|M0)               r8.12<2>:hf   r7.5<0;1,0>:f                    {F@4}
        mul (1|M0)               r1.2<1>:f     r24.5<0;1,0>:f    r24.5<0;1,0>:f  
        mul (1|M0)               r7.5<1>:f     r24.6<0;1,0>:f    r24.6<0;1,0>:f  
        add (1|M0)               r7.2<1>:hf    r7.2<0;1,0>:hf    r9.2<0;1,0>:hf   {F@5}
        mov (1|M0)               r4.2<2>:hf    r3.3<0;1,0>:f                   
        add (1|M0)               r5.0<1>:hf    r5.0<0;1,0>:hf    r8.12<0;1,0>:hf  {F@5}
        mov (1|M0)               r9.2<2>:hf    r1.2<0;1,0>:f                    {F@5}
        mov (1|M0)               r8.12<2>:hf   r7.5<0;1,0>:f                    {F@5}
        mov (1|M0)               r5.1<1>:f     r4.2<0;1,0>:hf                   {F@4}
        mov (1|M0)               r2.7<1>:f     r9.2<0;1,0>:hf                   {F@3}
        mov (1|M0)               r1.2<1>:f     r8.12<0;1,0>:hf                  {F@3}
        mad (1|M0)               r5.1<1>:f     r5.1<0;0>:f       r27.5<0;0>:f      r27.5<0>:f       {F@3}
        mad (1|M0)               r2.7<1>:f     r2.7<0;0>:f       r25.5<0;0>:f      r25.5<0>:f       {F@3}
        mad (1|M0)               r1.2<1>:f     r1.2<0;0>:f       r25.6<0;0>:f      r25.6<0>:f       {F@3}
        mov (1|M0)               r6.2<2>:hf    r5.1<0;1,0>:f                    {F@3}
        mov (1|M0)               r3.4<2>:hf    r2.7<0;1,0>:f                    {F@3}
        mov (1|M0)               r9.2<2>:hf    r1.2<0;1,0>:f                    {F@3}
        mul (1|M0)               r5.1<1>:f     r24.7<0;1,0>:f    r24.7<0;1,0>:f  
        mul (1|M0)               r2.7<1>:f     r26.6<0;1,0>:f    r26.6<0;1,0>:f  
        mul (1|M0)               r1.2<1>:f     r26.7<0;1,0>:f    r26.7<0;1,0>:f  
        add (1|M0)               r3.4<1>:hf    r3.4<0;1,0>:hf    r6.2<0;1,0>:hf   {F@5}
        mov (1|M0)               r9.4<2>:hf    r2.7<0;1,0>:f                    {F@3}
        mov (1|M0)               r6.2<2>:hf    r5.1<0;1,0>:f                   
        mov (1|M0)               r8.14<2>:hf   r1.2<0;1,0>:f                    {F@4}
        mov (1|M0)               r3.3<1>:f     r9.4<0;1,0>:hf                   {F@3}
        mov (1|M0)               r7.5<1>:f     r6.2<0;1,0>:hf                   {F@3}
        mov (1|M0)               r2.7<1>:f     r8.14<0;1,0>:hf                  {F@3}
        mad (1|M0)               r3.3<1>:f     r3.3<0;0>:f       r27.6<0;0>:f      r27.6<0>:f       {F@3}
        mad (1|M0)               r7.5<1>:f     r7.5<0;0>:f       r25.7<0;0>:f      r25.7<0>:f       {F@3}
        mad (1|M0)               r2.7<1>:f     r2.7<0;0>:f       r27.7<0;0>:f      r27.7<0>:f       {F@3}
        mov (1|M0)               r4.2<2>:hf    r3.3<0;1,0>:f                    {F@3}
        mov (1|M0)               r8.12<2>:hf   r7.5<0;1,0>:f                    {F@3}
        mov (1|M0)               r9.4<2>:hf    r2.7<0;1,0>:f                    {F@3}
        add (1|M0)               r9.2<1>:hf    r9.2<0;1,0>:hf    r4.2<0;1,0>:hf   {F@3}
        add (1|M0)               r8.12<1>:hf   r8.12<0;1,0>:hf   r9.4<0;1,0>:hf   {F@2}
        add (1|M0)               r4.0<1>:hf    r4.0<0;1,0>:hf    r5.0<0;1,0>:hf  
        add (1|M0)               r2.12<1>:hf   r2.12<0;1,0>:hf   r3.4<0;1,0>:hf  
        add (1|M0)               r9.0<1>:hf    r9.0<0;1,0>:hf    r9.2<0;1,0>:hf   {F@4}
        add (1|M0)               r7.2<1>:hf    r7.2<0;1,0>:hf    r8.12<0;1,0>:hf  {F@4}
        add (1|M0)               r4.0<1>:hf    r4.0<0;1,0>:hf    r9.0<0;1,0>:hf   {F@2}
        add (1|M0)               r2.12<1>:hf   r2.12<0;1,0>:hf   r7.2<0;1,0>:hf   {F@2}
        cmp (1|M0)    (eq)f1.0   null<1>:d     r23.5<0;1,0>:d    0:w              
        add (1|M0)               r4.0<1>:hf    r4.0<0;1,0>:hf    r2.12<0;1,0>:hf  {F@1}
        mov (2|M0)               r43.6<1>:d    r8.2<1;1,0>:d                   
        mov (1|M0)               r1.2<1>:f     r4.0<0;1,0>:hf                   {F@1}
(W)     and (1|M0)               f0.0<1>:ud    f1.0<0;1,0>:uw    0x1:uw             
        sel (1|M0)    (ge)f0.0   r1.2<1>:f     r1.2<0;1,0>:f     6.198883e-05:f               {F@1}
(f1.0)  sel (1|M0)               r43.6<1>:d    r8.0<0;1,0>:d     r8.2<0;1,0>:d   
        sync.nop                             null                             {Compacted,F@1}
        math.sqt (1|M0)          r1.2<1>:f     r1.2<0;1,0>:f                    {$8}
(f1.0)  mov (1|M0)               r43.7<1>:d    r8.1<0;1,0>:d                   
        math.inv (1|M0)          r1.2<1>:f     r1.2<0;1,0>:f                    {$8}
        mov (1|M0)               r6.2<2>:hf    r1.2<0;1,0>:f                    {$8.dst}
        mov (1|M0)               r36.7<1>:f    r6.2<0;1,0>:hf                   {F@1}
(f0.0.any32h) goto (32|M0)                   L4272                  L4272                
L4248:
        mov (1|M0)               r41.6<1>:f    1.0:f                               {Compacted}
        goto (32|M0)                         L4272                  L4448                
L4272:
        join (32|M0)                         L4448                                
L4288:
        shl (1|M0)               r1.4<1>:d     r36.2<0;1,0>:d    2:w              
        shl (1|M0)               r1.2<1>:d     r36.3<0;1,0>:d    2:w              
        shr (1|M0)               r1.3<1>:ud    r36.2<0;1,0>:ud   0x1E:uw             
        addc (1|M0)              r4.0<1>:ud    r8.4<0;1,0>:ud    r1.4<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d    {I@2}
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r10.0<1>:f    r4.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r10.1<1>:d    r5.0<0;0>:d       r8.5<0;0>:d       r1.5<0>:d        {I@1}
        send.ugm (1|M0)          r9       r10     null:0  0x0            0x04100580           {A@1,$9} // wr:2+0, rd:1; load.ugm.d32.a64
        mov (1|M0)               r2.12<2>:hf   r9.0<0;1,0>:f                    {$9.dst}
        mov (1|M0)               r41.6<1>:f    r2.12<0;1,0>:hf                  {F@1}
L4448:
        join (32|M0)                         L5368                                
L4464:
        mov (1|M0)               r42.0<2>:f    0.0:f                              
        mov (1|M0)               r42.1<2>:d    0:d                              
        mov (1|M0)               r41.7<1>:d    0:w                              
L4512:
        shl (1|M0)               r1.3<1>:w     r42.0<0;1,0>:w    2:w               {F@1}
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0x300:uw              {A@1}
        mul (1|M0)               r2.6<1>:f     r[a0.0]<0;1,0>:f  r36.7<0;1,0>:f  
        mov (1|M0)               r3.4<2>:hf    r2.6<0;1,0>:f                    {A@1}
        mov (1|M0)               r4.0<1>:f     r3.4<0;1,0>:hf                   {F@1}
        mul (1|M0)               r4.1<1>:f     r41.6<0;1,0>:f    r4.0<0;1,0>:f    {F@1}
        mov (1|M0)               r5.0<2>:hf    r4.1<0;1,0>:f                    {F@1}
        mov (1|M0)               r42.3<1>:f    r5.0<0;1,0>:hf                   {F@1}
(~f1.0) mov (1|M0)               r42.3<1>:f    r4.0<0;1,0>:f                   
        cmp (1|M0)    (lt)f1.1   null<1>:f     r42.3<0;1,0>:f    0.0:f               {F@1}
(f1.1)  mov (1|M0)               r42.3<1>:f    -r42.3<0;1,0>:f                 
        sel (1|M0)    (lt)f0.0   r42.3<1>:f    r42.3<0;1,0>:f    448.0:f               {F@1}
        shr (1|M0)               r42.4<1>:ud   r42.3<0;1,0>:ud   0x17:uw              {F@1}
        and (1|M0)               r42.4<1>:ud   r42.4<0;1,0>:ud   0xFF:uw              {I@1}
        sel (1|M0)    (ge)f0.0   r42.4<1>:ud   r42.4<0;1,0>:ud   0x79:uw              {I@1}
        shl (1|M0)               r42.4<1>:ud   r42.4<0;1,0>:ud   0x17:uw              {I@1}
        add (1|M0)               r1.2<1>:ud    -r42.4<0;1,0>:ud  0x80800000:ud              {I@1}
        mul (1|M0)               r1.3<1>:f     r42.3<0;1,0>:f    r1.2<0;1,0>:f    {I@1}
        mov (1|M0)               r42.2<1>:d    r1.3<0;1,0>:f                    {F@1}
        mov (1|M0)               r42.5<1>:f    r42.2<0;1,0>:d                   {I@1}
        mad (1|M0)               r42.3<1>:f    -r42.5<0;0>:f     r1.2<0;0>:f       r42.3<0>:f       {F@1}
        cmp (1|M0)    (gt)f0.0   null<1>:f     r42.3<0;1,0>:f    0.5:f               {F@1}
(W)     and (1|M0)               f0.0<1>:ud    f0.0<0;1,0>:uw    0x1:uw              {F@1}
(f0.0.any32h) goto (32|M0)                   L4992                  L4992                
L4896:
        cmp (1|M0)    (lt)f0.0   null<1>:f     r42.3<0;1,0>:f    0.5:f               {A@1}
        and (1|M0)               r42.2<1>:d    r42.2<0;1,0>:d    1:w              
        add (1|M0)               r1.2<1>:f     r42.5<0;1,0>:f    1.0:f              
(~f0.0) cmp (1|M0)    (eq)f0.0   null<1>:d     r42.2<0;1,0>:d    0:w               {A@1}
(~f0.0) mov (1|M0)               r42.5<1>:f    r1.2<0;1,0>:f                    {F@1}
        goto (32|M0)                         L4992                  L5024                
L4992:
        join (32|M0)                         L5024                                
L5008:
        add (1|M0)               r42.5<1>:f    r42.5<0;1,0>:f    1.0:f               {F@1}
L5024:
        join (32|M0)                         L5368                                
L5040:
        addc (1|M0)              r4.0<1>:ud    r42.0<0;1,0>:ud   0x1:ud              {AccWrEn}
        add (1|M0)               r42.4<1>:ud   r42.4<0;1,0>:ud   0xFE800000:ud             
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r42.6<1>:d    r4.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r42.7<1>:d    r5.0<0;0>:d       r42.1<0;0>:d      0:w               {I@2}
        mul (1|M0)               r42.5<1>:f    r42.5<0;1,0>:f    r42.4<0;1,0>:f   {F@1}
        cmp (1|M0)    (eq)f0.0   null<1>:d     r42.7<0;1,0>:d    0:w               {I@1}
(f1.1)  mov (1|M0)               r42.5<1>:f    -r42.5<0;1,0>:f                  {F@1}
        shl (1|M0)               r1.3<1>:w     r41.14<0;1,0>:w   1:w              
(W)     mov (1|M0)               r2.12<2>:hf   r42.5<0;1,0>:f                   {F@1}
(f0.0)  cmp (1|M0)    (eq)f0.0   null<1>:d     r42.6<0;1,0>:d    32:w              
        add (1|M0)               r41.7<1>:d    r41.7<0;1,0>:d    1:w              
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0x440:uw              {A@1}
        mov (1|M0)               r[a0.0]<1>:hf  r2.12<0;1,0>:hf                 {F@1}
(W)     and (1|M0)               f0.0<1>:ud    f0.0<0;1,0>:uw    0x1:uw             
(~f0.0.any32h) goto (32|M0)                  L5320                  L5320                
L5288:
        mov (32|M0)              r44.0<1>:uw   r34.0<1;1,0>:uw                  {F@1}
        goto (32|M0)                         L5320                  L6056                
L5320:
        join (32|M0)                         L5368                                
L5336:
(W)     mov (2|M0)               r42.0<1>:ud   r42.6<1;1,0>:ud                 
        goto.b (32|M0)                       L5368                  L4512                
L5368:
        join (32|M0)                         L6056                                
L5384:
        mov (1|M0)               r43.0<1>:d    0:w                              
L5400:
        shl (1|M0)               r1.3<1>:w     r43.0<0;1,0>:w    2:w               {I@1}
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0x4A0:uw              {A@1}
        cmp (1|M0)    (lt)f1.0   null<1>:f     r[a0.0]<0;1,0>:f  0.0:f              
(W)     mov (1|M0)               r2.6<1>:f     -r[a0.0]<0;1,0>:f                {A@1}
(W)     mov (1|M0)               r2.7<1>:f     r[a0.0]<0;1,0>:f                 {A@1}
(f1.0)  sel (1|M0)               r43.2<1>:f    r2.6<0;1,0>:f     r2.7<0;1,0>:f    {A@1}
        sel (1|M0)    (lt)f0.0   r43.2<1>:f    r43.2<0;1,0>:f    448.0:f               {F@1}
        shr (1|M0)               r43.3<1>:ud   r43.2<0;1,0>:ud   0x17:uw              {F@1}
        and (1|M0)               r43.3<1>:ud   r43.3<0;1,0>:ud   0xFF:uw              {I@1}
        sel (1|M0)    (ge)f0.0   r43.3<1>:ud   r43.3<0;1,0>:ud   0x79:uw              {I@1}
        shl (1|M0)               r43.3<1>:ud   r43.3<0;1,0>:ud   0x17:uw              {I@1}
        add (1|M0)               r3.2<1>:ud    -r43.3<0;1,0>:ud  0x80800000:ud              {I@1}
        mul (1|M0)               r3.3<1>:f     r43.2<0;1,0>:f    r3.2<0;1,0>:f    {I@1}
        mov (1|M0)               r43.1<1>:d    r3.3<0;1,0>:f                    {F@1}
        mov (1|M0)               r43.4<1>:f    r43.1<0;1,0>:d                   {I@1}
        mad (1|M0)               r43.2<1>:f    -r43.4<0;0>:f     r3.2<0;0>:f       r43.2<0>:f       {F@1}
        cmp (1|M0)    (gt)f0.0   null<1>:f     r43.2<0;1,0>:f    0.5:f               {F@1}
(W)     and (1|M0)               f0.0<1>:ud    f0.0<0;1,0>:uw    0x1:uw              {F@1}
(f0.0.any32h) goto (32|M0)                   L5792                  L5792                
L5704:
        cmp (1|M0)    (lt)f0.0   null<1>:f     r43.2<0;1,0>:f    0.5:f               {A@1}
        and (1|M0)               r43.1<1>:d    r43.1<0;1,0>:d    1:w               {Compacted}
        add (1|M0)               r1.2<1>:f     r43.4<0;1,0>:f    1.0:f              
(~f0.0) cmp (1|M0)    (eq)f0.0   null<1>:d     r43.1<0;1,0>:d    0:w               {A@1}
(~f0.0) mov (1|M0)               r43.4<1>:f    r1.2<0;1,0>:f                    {F@1}
        goto (32|M0)                         L5792                  L5824                
L5792:
        join (32|M0)                         L5824                                
L5808:
        add (1|M0)               r43.4<1>:f    r43.4<0;1,0>:f    1.0:f               {F@1}
L5824:
        join (32|M0)                         L6008                                
L5840:
        shl (1|M0)               r1.3<1>:w     r43.0<0;1,0>:w    1:w              
        add (1|M0)               r43.0<1>:d    r43.0<0;1,0>:d    1:w               {Compacted}
        add (1|M0)               r43.3<1>:ud   r43.3<0;1,0>:ud   0xFE800000:ud             
        cmp (1|M0)    (eq)f0.0   null<1>:d     r43.0<0;1,0>:d    32:w               {I@2}
        mul (1|M0)               r43.4<1>:f    r43.4<0;1,0>:f    r43.3<0;1,0>:f   {A@1}
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0x400:uw              {A@1}
(f1.0)  mov (1|M0)               r43.4<1>:f    -r43.4<0;1,0>:f                  {F@1}
(W)     and (1|M0)               f0.0<1>:ud    f0.0<0;1,0>:uw    0x1:uw             
(W)     mov (1|M0)               r2.12<2>:hf   r43.4<0;1,0>:f                   {F@1}
        mov (1|M0)               r[a0.0]<1>:hf  r2.12<0;1,0>:hf                 {F@1}
(~f0.0.any32h) goto.b (32|M0)                L6008                  L5400                
L6008:
        join (32|M0)                         L6056                                
L6024:
        mov (32|M0)              r44.0<1>:hf   r32.0<1;1,0>:hf                  {F@1}
(W)     mov (2|M0)               r43.6<1>:ud   r7.6<1;1,0>:ud                  
L6056:
        join (32|M0)                         L6424                                
L6072:
        shl (1|M0)               r1.4<1>:d     r46.0<0;1,0>:d    1:w               {Compacted}
(W)     mov (1|M0)               r2.12<1>:hf   0x1:hf                             
        addc (1|M0)              r4.0<1>:ud    r43.6<0;1,0>:ud   r1.4<0;1,0>:ud   {AccWrEn,I@1}
        shl (1|M0)               r1.2<1>:d     r46.1<0;1,0>:d    1:w              
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r10.0<1>:ud   r23.6<0;1,0>:ud   r23.0<0;1,0>:ud  {AccWrEn}
        shr (1|M0)               r1.3<1>:ud    r46.0<0;1,0>:ud   0x1F:uw             
        mov (1|M0)               r46.2<1>:d    r10.0<0;1,0>:d                   {I@2}
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        cmp (1|M0)    (lt)f0.0   null<1>:ud    r46.2<0;1,0>:ud   r3.0<0;1,0>:ud   {I@2}
        add3 (1|M0)              r46.3<1>:d    r11.0<0;0>:d      r23.7<0;0>:d      r23.1<0>:d       {I@2}
        or (1|M0)                r1.5<1>:d     r1.2<0;1,0>:d     r1.3<0;1,0>:d   
        cmp (1|M0)    (lt)f0.1   null<1>:ud    r46.3<0;1,0>:ud   r3.1<0;1,0>:ud   {I@2}
(f0.0)  cmp (1|M0)    (eq)f0.0   null<1>:d     r46.3<0;1,0>:d    r3.1<0;1,0>:d   
        mov (1|M0)               r9.0<1>:f     r4.0<0;1,0>:f                    {Compacted}
        add3 (1|M0)              r9.1<1>:d     r5.0<0;0>:d       r43.7<0;0>:d      r1.5<0>:d        {I@3}
(f0.1)  sel (1|M0)               r3.4<1>:uw    r2.12<0;1,0>:uw   0x0:uw              {F@2}
(f0.0)  sel (1|M0)               r2.13<1>:uw   r2.12<0;1,0>:uw   0x0:uw             
        send.ugm (1|M0)          null     r9      r44:2   0x0            0x0200C784           {A@1,$4} // wr:1+2, rd:0; store.ugm.d64x8t.a64
        or (1|M0)     (ne)f0.0   null<1>:uw    r2.13<0;1,0>:uw   r3.4<0;1,0>:uw   {I@1}
(W)     and (1|M0)               f0.0<1>:ud    f0.0<0;1,0>:uw    0x1:uw             
(~f0.0.any32h) goto (32|M0)                  L6424                  L6424                
L6392:
(W)     mov (2|M0)               r23.6<1>:ud   r46.2<1;1,0>:ud                 
        goto.b (32|M0)                       L6424                  L648                
L6424:
        join (32|M0)                         L6440                                
L6440:
(W)     mov (8|M0)               r127.0<1>:f   r0.0<1;1,0>:f                    {Compacted,$3.src}
(W)     send.ugm (1|M0)          r4       r0      null:0  0x0            0x0210641F           {$10} // wr:1+0, rd:1; fence invalid flush type scoped to tile
(W)     mov (8|M0)               null<1>:ud    r4.0<1;1,0>:ud                   {$10.dst}
(W)     send.gtwy (1|M0)         null     r127    null:0  0x0            0x02000010           {EOT,A@1} // wr:1+0, rd:0; end of thread
L6496:
        mov (1|M0)               r1.2<1>:d     cr0.0<0;1,0>:ud                  {A@1}
        and (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   -1265:w               {A@1}
        or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   1264:w               {A@1}
        mov (1|M0)               r1.3<1>:f     r43.5<0;1,0>:ud                  {A@1}
        mov (1|M0)               r3.2<1>:f     0xB4C00000:f                               {Compacted,I@7}
        math.inv (1|M0)          r2.7<1>:f     r1.3<0;1,0>:f                    {@2,$11}
        mov (1|M0)               r1.5<1>:f     r47.1<0;1,0>:ud                 
        sync.nop                             null                             {Compacted,$11.dst}
        mad (1|M0)               r2.7<1>:f     r2.7<0;0>:f       r3.2<0;0>:f       r2.7<0>:f        {F@2}
        mov (1|M0)               r47.0<1>:ud   r1.3<0;1,0>:f                   
        mov (1|M0)               r1.6<1>:ud    r1.5<0;1,0>:f                    {F@2}
        mul (1|M0)               r4.0<1>:f     r2.7<0;1,0>:f     r1.5<0;1,0>:f    {A@1}
        add (1|M0)               r47.0<1>:ud   r43.5<0;1,0>:ud   -r47.0<0;1,0>:ud {Compacted,I@2}
        add (1|M0)               r1.6<1>:ud    r47.1<0;1,0>:ud   -r1.6<0;1,0>:ud  {I@2}
        mov (1|M0)               r5.0<1>:ud    r4.0<0;1,0>:f                    {F@1}
        mov (1|M0)               r1.4<1>:f     r47.0<0;1,0>:ud                  {Compacted,I@3}
        mov (1|M0)               r2.6<1>:f     r1.6<0;1,0>:ud                   {I@2}
        mov (1|M0)               r5.1<1>:f     r5.0<0;1,0>:ud                   {Compacted,I@1}
        mad (1|M0)               r1.5<1>:f     r1.5<0;0>:f       r5.1<0;0>:f       -r1.3<0>:f       {F@1}
        mad (1|M0)               r5.1<1>:f     r2.6<0;0>:f       r5.1<0;0>:f       -r1.4<0>:f      
        add (1|M0)               r1.5<1>:f     r1.5<0;1,0>:f     r5.1<0;1,0>:f    {F@1}
        mul (1|M0)               r2.7<1>:f     r2.7<0;1,0>:f     r1.5<0;1,0>:f    {F@1}
        mov (1|M0)               r6.1<1>:ud    r2.7<0;1,0>:f                    {F@1}
        add (1|M0)               r5.0<1>:ud    r5.0<0;1,0>:ud    r6.1<0;1,0>:ud   {Compacted,I@1}
(W)     mul (1|M0)               acc0.0<1>:ud  r5.0<0;1,0>:ud    r43.10<0;1,0>:uw {I@1}
        mach (1|M0)              r5.0<1>:ud    r5.0<0;1,0>:ud    r43.5<0;1,0>:ud  {Compacted}
        add (1|M0)               r47.1<1>:ud   r47.1<0;1,0>:ud   -r5.0<0;1,0>:ud  {Compacted,I@1}
        cmp (1|M0)    (lt)f0.0   null<1>:ud    r47.1<0;1,0>:ud   r43.5<0;1,0>:ud  {I@1}
(f0.0)  mov (1|M0)               r43.5<1>:d    0:w                              
        add (1|M0)               r36.0<1>:ud   r47.1<0;1,0>:ud   -r43.5<0;1,0>:ud {I@1}
        mov (1|M0)               cr0.0<1>:ud   r1.2<0;1,0>:d                    {A@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        ret (32|M0)                          r46.6                            {A@1}
L6976:
        mov (1|M0)               r1.2<1>:d     cr0.0<0;1,0>:ud                  {A@1}
        and (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   -1265:w               {A@1}
        or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   1264:w               {A@1}
        mov (1|M0)               r1.3<1>:f     r46.4<0;1,0>:ud                  {A@1}
        mov (1|M0)               r3.2<1>:f     0xB4C00000:f                               {Compacted}
        math.inv (1|M0)          r2.7<1>:f     r1.3<0;1,0>:f                    {@2,$12}
        mov (1|M0)               r1.5<1>:f     r47.5<0;1,0>:ud                 
        sync.nop                             null                             {Compacted,$12.dst}
        mad (1|M0)               r2.7<1>:f     r2.7<0;0>:f       r3.2<0;0>:f       r2.7<0>:f        {F@2}
        mov (1|M0)               r47.4<1>:ud   r1.3<0;1,0>:f                   
        mov (1|M0)               r1.6<1>:ud    r1.5<0;1,0>:f                    {F@2}
        mul (1|M0)               r4.0<1>:f     r2.7<0;1,0>:f     r1.5<0;1,0>:f    {F@1}
        add (1|M0)               r47.4<1>:ud   r46.4<0;1,0>:ud   -r47.4<0;1,0>:ud {I@2}
        add (1|M0)               r1.6<1>:ud    r47.5<0;1,0>:ud   -r1.6<0;1,0>:ud  {I@2}
        mov (1|M0)               r5.0<1>:ud    r4.0<0;1,0>:f                    {F@1}
        mov (1|M0)               r1.4<1>:f     r47.4<0;1,0>:ud                  {I@3}
        mov (1|M0)               r2.6<1>:f     r1.6<0;1,0>:ud                   {I@2}
        mov (1|M0)               r5.1<1>:f     r5.0<0;1,0>:ud                   {Compacted,I@1}
(W)     mov (1|M0)               r3.4<1>:hf    0x1:hf                             
        mad (1|M0)               r1.5<1>:f     r1.5<0;0>:f       r5.1<0;0>:f       -r1.3<0>:f       {F@2}
        mad (1|M0)               r5.1<1>:f     r2.6<0;0>:f       r5.1<0;0>:f       -r1.4<0>:f      
        add (1|M0)               r1.5<1>:f     r1.5<0;1,0>:f     r5.1<0;1,0>:f    {F@1}
        mul (1|M0)               r2.7<1>:f     r2.7<0;1,0>:f     r1.5<0;1,0>:f    {F@1}
        mov (1|M0)               r6.1<1>:ud    r2.7<0;1,0>:f                    {F@1}
        add (1|M0)               r5.0<1>:ud    r5.0<0;1,0>:ud    r6.1<0;1,0>:ud   {Compacted,I@1}
(W)     mul (1|M0)               acc0.0<1>:ud  r5.0<0;1,0>:ud    r46.8<0;1,0>:uw  {I@1}
        mach (1|M0)              r9.0<1>:ud    r5.0<0;1,0>:ud    r46.4<0;1,0>:ud  {Compacted}
        add (1|M0)               r47.5<1>:ud   r47.5<0;1,0>:ud   -r9.0<0;1,0>:ud  {I@1}
        cmp (1|M0)    (ge)f0.0   null<1>:ud    r47.5<0;1,0>:ud   r46.4<0;1,0>:ud  {I@1}
(f0.0)  sel (1|M0)               r4.0<1>:d     r3.4<0;1,0>:w     0:w              
        add (1|M0)               r46.5<1>:ud   r5.0<0;1,0>:ud    r4.0<0;1,0>:ud   {Compacted,I@1}
        mov (1|M0)               cr0.0<1>:ud   r1.2<0;1,0>:d                    {A@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        ret (32|M0)                          r47.2                            {A@1}
L7488:
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
