L0:
(W)     mov (8|M0)               r127.0<1>:ud  0x0:ud                              {A@1}
(W)     and (1|M0)               r127.2<1>:ud  r0.0<0;1,0>:ud    0xFFFFFFC0:ud             
(W)     and (1|M0)               r127.0<1>:uw  r0.4<0;1,0>:uw    0xFF:uw             
(W)     add (1|M0)               r127.2<1>:ud  r127.2<0;1,0>:ud  0x80:ud              {I@2}
(W)     mad (1|M0)               r127.2<1>:ud  r127.2<0;0>:ud    r127.0<0;0>:uw    0x20:uw              {I@1}
(W)     send.dc0 (8|M0)          r1       r127    null:0  0x0            0x021842FD           {A@1,$0} // wr:1h+0, rd:1; oword aligned block read x2
        nop                    
        nop                    
(W)     mov (8|M0)               r127.0<1>:ud  0x0:ud                              {$0.src}
(W)     and (1|M0)               r127.2<1>:ud  r0.0<0;1,0>:ud    0xFFFFFFC0:ud             
(W)     send.dc0 (8|M0)          r2       r127    null:0  0x0            0x024844FD           {A@1,$1} // wr:1h+0, rd:4; oword aligned block read x8
        and (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   -1265:w               {A@1}
        or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   1216:w               {A@1}
        mov (1|M0)               r87.5<1>:d    r0.1<0;1,0>:ud                   {A@1}
        mov (1|M0)               r87.2<1>:d    r2.6<0;1,0>:d                    {$1.dst}
(W)     mul (1|M0)               acc0.0<1>:d   r87.5<0;1,0>:d    r2.0<0;1,0>:uw   {Compacted,I@2}
(W)     mach (1|M0)              r6.0<1>:d     r87.5<0;1,0>:d    r2.0<0;1,0>:d    {Compacted}
        mov (1|M0)               r87.5<1>:d    r6.0<0;1,0>:d                    {I@1}
        sync.nop                             null                             {Compacted,$0.dst}
        add (1|M0)               r87.5<1>:d    r87.5<0;1,0>:d    r1.0<0;1,0>:uw   {I@1}
(W)     mul (1|M0)               acc0.0<1>:ud  r87.5<0;1,0>:ud   0xAAAB:uw              {I@1}
(W)     mach (1|M0)              r7.0<1>:ud    r87.5<0;1,0>:ud   0xAAAAAAAB:ud              {AccWrEn}
        mov (1|M0)               r88.1<1>:ud   r7.0<0;1,0>:ud                   {I@1}
        shr (1|M0)               r88.1<1>:ud   r88.1<0;1,0>:ud   0x1:uw              {I@1}
        mul (1|M0)               r67.0<1>:d    r88.1<0;1,0>:d    -3:w               {Compacted,I@1}
        add (1|M0)               r67.0<1>:d    r67.0<0;1,0>:d    r87.5<0;1,0>:d   {Compacted,I@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r87.6         L6232                                 {A@1}
L424:
        mul (1|M0)               r87.0<1>:d    r2.6<0;1,0>:d     3:w               {Compacted}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r88.2         L5760                                 {A@1}
L480:
        mov (1|M0)               r67.2<1>:d    r87.1<0;1,0>:d                  
        shl (1|M0)               r11.0<1>:d    r67.1<0;1,0>:d    5:w               {Compacted}
        shl (1|M0)               r2.3<1>:d     r67.2<0;1,0>:d    2:w               {I@2}
        shr (1|M0)               r1.2<1>:ud    r67.2<0;1,0>:ud   0x1E:uw             
        addc (1|M0)              r6.0<1>:ud    r3.0<0;1,0>:ud    r2.3<0;1,0>:ud   {AccWrEn,I@2}
        or (1|M0)                r2.4<1>:d     r1.2<0;1,0>:d     0:w               {I@2}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r67.0<0;1,0>:d    r3.4<0;1,0>:uw   {Compacted}
        mach (1|M0)              r10.0<1>:d    r67.0<0;1,0>:d    r3.2<0;1,0>:d    {Compacted}
        mul (1|M0)               acc0.0<1>:ud  r67.2<0;1,0>:ud   r3.12<0;1,0>:uw 
        mach (1|M0)              r13.0<1>:ud   r67.2<0;1,0>:ud   r3.6<0;1,0>:ud   {AccWrEn}
        add (1|M0)               r20.0<1>:d    r10.0<0;1,0>:d    r11.0<0;1,0>:d   {Compacted,I@3}
        mov (1|M0)               r12.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        shl (1|M0)               r14.0<1>:d    r13.0<0;1,0>:d    2:w               {Compacted,I@3}
        shl (1|M0)               r16.0<1>:d    r12.0<0;1,0>:d    2:w               {Compacted,I@2}
        shl (1|M0)               r22.0<1>:d    r20.0<0;1,0>:d    2:w               {Compacted}
        shr (1|M0)               r15.0<1>:ud   r12.0<0;1,0>:ud   0x1E:uw             
        addc (1|M0)              r17.0<1>:ud   r3.4<0;1,0>:ud    r16.0<0;1,0>:ud  {AccWrEn,I@3}
        shr (1|M0)               r21.0<1>:ud   r20.0<0;1,0>:ud   0x1E:uw             
        or (1|M0)                r16.1<1>:d    r14.0<0;1,0>:d    r15.0<0;1,0>:d   {Compacted,I@3}
        mov (1|M0)               r18.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r23.0<1>:ud   r17.0<0;1,0>:ud   r22.0<0;1,0>:ud  {AccWrEn,I@4}
        or (1|M0)                r22.1<1>:d    r21.0<0;1,0>:d    0:w               {Compacted,I@4}
        add3 (1|M0)              r19.1<1>:d    r18.0<0;0>:d      r3.5<0;0>:d       r16.1<0>:d       {I@3}
        mov (1|M0)               r24.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r25.0<1>:f    r23.0<0;1,0>:f                   {Compacted,I@4}
        addc (1|M0)              r34.0<1>:ud   r4.0<0;1,0>:ud    r22.0<0;1,0>:ud  {AccWrEn}
        add3 (1|M0)              r25.1<1>:d    r24.0<0;0>:d      r19.1<0;0>:d      r22.1<0>:d       {I@2}
        mov (1|M0)               r8.0<1>:f     r6.0<0;1,0>:f                    {Compacted}
        send.ugm (1|M0)          r26      r25     null:0  0x0            0x0240D780           {A@1,$2} // wr:1+0, rd:4; load.ugm.d64x16t.a64
        add3 (1|M0)              r8.1<1>:d     r7.0<0;0>:d       r3.1<0;0>:d       r2.4<0>:d       
        mov (1|M0)               r35.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        send.ugm (1|M0)          r9       r8      null:0  0x0            0x04100580           {A@1,$3} // wr:2+0, rd:1; load.ugm.d32.a64
        mov (1|M0)               r36.0<1>:f    r34.0<0;1,0>:f                   {Compacted}
        add3 (1|M0)              r36.1<1>:d    r35.0<0;0>:d      r4.1<0;0>:d       r22.1<0>:d       {I@1}
        mov (1|M0)               r87.0<1>:d    r4.2<0;1,0>:d                   
        send.ugm (1|M0)          r68      r36     null:0  0x0            0x0240D780           {A@1,$4} // wr:1+0, rd:4; load.ugm.d64x16t.a64
        mov (1|M0)               r87.5<1>:d    r67.2<0;1,0>:d                  
        mov (16|M0)              r30.0<1>:f    r26.0<1;1,0>:d                   {Compacted,$2.dst}
        mov (16|M0)              r32.0<1>:f    r28.0<1;1,0>:d                   {Compacted}
        sync.nop                             null                             {Compacted,$3.dst}
        mul (16|M0)              acc0.0<1>:f   r9.0<0;1,0>:f     r30.0<1;1,0>:f   {Compacted,F@2}
        mul (16|M0)              acc2.0<1>:f   r9.0<0;1,0>:f     r32.0<1;1,0>:f   {Compacted,F@2}
        mul (16|M0)              r68.0<1>:f    acc0.0<1;1,0>:f   r68.0<1;1,0>:f   {Compacted,$4.dst}
        mul (16|M0)              r70.0<1>:f    acc2.0<1;1,0>:f   r70.0<1;1,0>:f   {Compacted}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (16|M0)             r88.2         L5760                                 {A@1}
L1056:
(W)     mul (1|M0)               acc0.0<1>:d   r87.1<0;1,0>:d    r4.4<0;1,0>:uw   {A@2}
        mach (1|M0)              r6.0<1>:d     r87.1<0;1,0>:d    r4.2<0;1,0>:d   
        mul (1|M0)               acc0.0<1>:ud  r87.1<0;1,0>:ud   r2.12<0;1,0>:uw 
        mach (1|M0)              r8.0<1>:ud    r87.1<0;1,0>:ud   r2.6<0;1,0>:ud   {AccWrEn}
        mov (1|M0)               r67.3<1>:d    r67.1<0;1,0>:d                  
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r12.0<1>:d    r4.2<0;1,0>:d                   
        addc (1|M0)              r9.0<1>:ud    r7.0<0;1,0>:ud    r67.3<0;1,0>:ud  {AccWrEn,I@2}
        mov (1|M0)               r67.4<1>:d    0:w                              
        mov (1|M0)               r11.0<1>:f    r9.0<0;1,0>:f                    {Compacted,I@2}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mul (1|M0)               acc0.0<1>:ud  r11.0<0;1,0>:ud   r12.0<0;1,0>:uw  {F@1}
        mach (1|M0)              r14.0<1>:ud   r11.0<0;1,0>:ud   r12.0<0;1,0>:ud  {AccWrEn}
        add3 (1|M0)              r11.1<1>:d    r10.0<0;0>:d      r8.0<0;0>:d       r67.4<0>:d       {I@3}
        add (1|M0)               r17.0<1>:d    r67.2<0;1,0>:d    -r6.0<0;1,0>:d   {Compacted}
        mov (1|M0)               r13.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r11.1<0;1,0>:d    r12.0<0;1,0>:uw  {Compacted,I@3}
        cmp (1|M0)    (eq)f1.1   null<1>:d     r67.0<0;1,0>:d    2:w              
        mach (1|M0)              r15.0<1>:d    r11.1<0;1,0>:d    r12.0<0;1,0>:d   {Compacted}
        addc (1|M0)              r18.0<1>:ud   r13.0<0;1,0>:ud   r17.0<0;1,0>:ud  {AccWrEn,I@4}
        add3 (1|M0)              r16.1<1>:d    r15.0<0;0>:d      r14.0<0;0>:d      0:w               {I@2}
        mov (1|M0)               r19.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
(W)     and (1|M0)               f1.0<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
        add3 (1|M0)              r20.1<1>:d    r19.0<0;0>:d      r16.1<0;0>:d      0:w               {I@2}
        shr (1|M0)               r22.0<1>:ud   r18.0<0;1,0>:ud   0x1B:uw             
        shl (1|M0)               r21.0<1>:d    r20.1<0;1,0>:d    5:w               {Compacted,I@2}
        shl (1|M0)               r67.5<1>:d    r18.0<0;1,0>:d    5:w               {Compacted}
        or (1|M0)                r67.6<1>:d    r21.0<0;1,0>:d    r22.0<0;1,0>:d   {Compacted,I@2}
(f1.0.any16h) goto (16|M0)                   L4888                  L4888                
L1432:
        mov (1|M0)               r76.0<2>:f    0.0:f                              
        mov (1|M0)               r76.1<2>:d    0:d                              
        mov (1|M0)               r67.7<1>:d    0:w                              
L1480:
        addc (1|M0)              r6.0<1>:ud    r76.0<0;1,0>:ud   0x1:ud              {AccWrEn,F@1}
        shl (1|M0)               r1.3<1>:w     r67.14<0;1,0>:w   2:w               {I@2}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r76.2<1>:d    r6.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r76.3<1>:d    r7.0<0;0>:d       r76.1<0;0>:d      0:w               {I@2}
        add (1|M0)               a0.1<1>:uw    r1.3<0;1,0>:uw    0x880:uw              {A@1}
        cmp (1|M0)    (eq)f0.1   null<1>:d     r76.3<0;1,0>:d    0:w               {I@2}
        shl (1|M0)               r2.6<1>:w     r76.0<0;1,0>:w    2:w              
        add (1|M0)               r67.7<1>:d    r67.7<0;1,0>:d    1:w              
        add (1|M0)               a0.0<1>:uw    r2.6<0;1,0>:uw    0x900:uw              {A@1}
(f0.1)  cmp (1|M0)    (eq)f0.1   null<1>:d     r76.2<0;1,0>:d    32:w              
        mov (1|M0)               r[a0.0]<1>:f  r[a0.1]<0;1,0>:f                
(W)     and (1|M0)               f0.1<1>:uw    f0.1<0;1,0>:uw    0x1:uw              {A@1}
(f0.1.any16h) goto (16|M0)                   L1728                  L1728                
L1696:
(W)     mov (2|M0)               r76.0<1>:ud   r76.2<1;1,0>:ud                 
        goto.b (16|M0)                       L1728                  L1480                
L1728:
        join (16|M0)                         L4888                                
L1744:
        mov (1|M0)               r76.4<2>:f    0.0:f                              
        mov (1|M0)               r76.5<2>:d    0:d                              
L1776:
        addc (1|M0)              r6.0<1>:ud    r76.4<0;1,0>:ud   0x1:ud              {AccWrEn,F@1}
        shl (1|M0)               r1.3<1>:w     r76.8<0;1,0>:w    2:w              
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r76.6<1>:d    r6.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r76.7<1>:d    r7.0<0;0>:d       r76.5<0;0>:d      0:w               {I@2}
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0x900:uw              {A@1}
        cmp (1|M0)    (eq)f0.0   null<1>:d     r76.7<0;1,0>:d    0:w               {I@2}
        mov (1|M0)               r2.6<2>:hf    r[a0.0]<0;1,0>:f                
(f0.0)  cmp (1|M0)    (eq)f0.0   null<1>:d     r76.6<0;1,0>:d    32:w               {A@1}
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0x9A0:uw              {A@1}
        mov (1|M0)               r[a0.0]<1>:f  r2.6<0;1,0>:hf                   {F@1}
(W)     and (1|M0)               f0.0<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
(f0.0.any16h) goto (16|M0)                   L2008                  L2008                
L1976:
(W)     mov (2|M0)               r76.4<1>:ud   r76.6<1;1,0>:ud                 
        goto.b (16|M0)                       L2008                  L1776                
L2008:
        join (16|M0)                         L4888                                
L2024:
        mul (1|M0)               r1.2<1>:f     r77.0<0;1,0>:f    r77.0<0;1,0>:f   {Compacted,F@1}
        mul (1|M0)               r5.4<1>:f     r79.0<0;1,0>:f    r79.0<0;1,0>:f   {Compacted}
        mul (1|M0)               r9.0<1>:f     r77.1<0;1,0>:f    r77.1<0;1,0>:f  
        mul (1|M0)               r13.0<1>:f    r79.1<0;1,0>:f    r79.1<0;1,0>:f  
        mul (1|M0)               r17.0<1>:f    r77.2<0;1,0>:f    r77.2<0;1,0>:f  
        mul (1|M0)               r21.0<1>:f    r79.2<0;1,0>:f    r79.2<0;1,0>:f  
        mul (1|M0)               r25.0<1>:f    r77.3<0;1,0>:f    r77.3<0;1,0>:f  
        mul (1|M0)               r29.0<1>:f    r79.3<0;1,0>:f    r79.3<0;1,0>:f  
        mul (1|M0)               r33.0<1>:f    r77.4<0;1,0>:f    r77.4<0;1,0>:f  
        mul (1|M0)               r37.0<1>:f    r79.4<0;1,0>:f    r79.4<0;1,0>:f  
        mul (1|M0)               r41.0<1>:f    r77.5<0;1,0>:f    r77.5<0;1,0>:f  
        mul (1|M0)               r45.0<1>:f    r79.5<0;1,0>:f    r79.5<0;1,0>:f  
        mul (1|M0)               r49.0<1>:f    r77.6<0;1,0>:f    r77.6<0;1,0>:f   {Compacted}
        mul (1|M0)               r53.0<1>:f    r79.6<0;1,0>:f    r79.6<0;1,0>:f   {Compacted}
        mul (1|M0)               r57.0<1>:f    r77.7<0;1,0>:f    r77.7<0;1,0>:f  
        mul (1|M0)               r61.0<1>:f    r79.7<0;1,0>:f    r79.7<0;1,0>:f  
        mov (1|M0)               r2.6<2>:hf    r1.2<0;1,0>:f                   
        mov (1|M0)               r6.0<2>:hf    r5.4<0;1,0>:f                   
        mov (1|M0)               r10.0<2>:hf   r9.0<0;1,0>:f                   
        mov (1|M0)               r14.0<2>:hf   r13.0<0;1,0>:f                  
        mov (1|M0)               r18.0<2>:hf   r17.0<0;1,0>:f                  
        mov (1|M0)               r22.0<2>:hf   r21.0<0;1,0>:f                  
        mov (1|M0)               r26.0<2>:hf   r25.0<0;1,0>:f                  
        mov (1|M0)               r30.0<2>:hf   r29.0<0;1,0>:f                  
        mov (1|M0)               r34.0<2>:hf   r33.0<0;1,0>:f                  
        mov (1|M0)               r38.0<2>:hf   r37.0<0;1,0>:f                  
        mov (1|M0)               r42.0<2>:hf   r41.0<0;1,0>:f                  
        mov (1|M0)               r46.0<2>:hf   r45.0<0;1,0>:f                  
        mov (1|M0)               r50.0<2>:hf   r49.0<0;1,0>:f                  
        mov (1|M0)               r54.0<2>:hf   r53.0<0;1,0>:f                  
        mov (1|M0)               r58.0<2>:hf   r57.0<0;1,0>:f                  
        mov (1|M0)               r62.0<2>:hf   r61.0<0;1,0>:f                  
        mov (1|M0)               r3.3<1>:f     r2.6<0;1,0>:hf                  
        mov (1|M0)               r7.0<1>:f     r6.0<0;1,0>:hf                  
        mov (1|M0)               r11.0<1>:f    r10.0<0;1,0>:hf                 
        mov (1|M0)               r15.0<1>:f    r14.0<0;1,0>:hf                 
        mov (1|M0)               r19.0<1>:f    r18.0<0;1,0>:hf                 
        mov (1|M0)               r23.0<1>:f    r22.0<0;1,0>:hf                 
        mov (1|M0)               r27.0<1>:f    r26.0<0;1,0>:hf                 
        mov (1|M0)               r31.0<1>:f    r30.0<0;1,0>:hf                 
        mov (1|M0)               r35.0<1>:f    r34.0<0;1,0>:hf                 
        mov (1|M0)               r39.0<1>:f    r38.0<0;1,0>:hf                 
        mov (1|M0)               r43.0<1>:f    r42.0<0;1,0>:hf                 
        mov (1|M0)               r47.0<1>:f    r46.0<0;1,0>:hf                 
        mov (1|M0)               r51.0<1>:f    r50.0<0;1,0>:hf                 
        mov (1|M0)               r55.0<1>:f    r54.0<0;1,0>:hf                 
        mov (1|M0)               r59.0<1>:f    r58.0<0;1,0>:hf                 
        mov (1|M0)               r63.0<1>:f    r62.0<0;1,0>:hf                 
        mad (1|M0)               r3.3<1>:f     r3.3<0;0>:f       r78.0<0;0>:f      r78.0<0>:f      
        mad (1|M0)               r7.0<1>:f     r7.0<0;0>:f       r80.0<0;0>:f      r80.0<0>:f      
        mad (1|M0)               r11.0<1>:f    r11.0<0;0>:f      r78.1<0;0>:f      r78.1<0>:f      
        mad (1|M0)               r15.0<1>:f    r15.0<0;0>:f      r80.1<0;0>:f      r80.1<0>:f      
        mad (1|M0)               r19.0<1>:f    r19.0<0;0>:f      r78.2<0;0>:f      r78.2<0>:f      
        mad (1|M0)               r23.0<1>:f    r23.0<0;0>:f      r80.2<0;0>:f      r80.2<0>:f      
        mad (1|M0)               r27.0<1>:f    r27.0<0;0>:f      r78.3<0;0>:f      r78.3<0>:f      
        mad (1|M0)               r31.0<1>:f    r31.0<0;0>:f      r80.3<0;0>:f      r80.3<0>:f      
        mad (1|M0)               r35.0<1>:f    r35.0<0;0>:f      r78.4<0;0>:f      r78.4<0>:f      
        mad (1|M0)               r39.0<1>:f    r39.0<0;0>:f      r80.4<0;0>:f      r80.4<0>:f      
        mad (1|M0)               r43.0<1>:f    r43.0<0;0>:f      r78.5<0;0>:f      r78.5<0>:f      
        mad (1|M0)               r47.0<1>:f    r47.0<0;0>:f      r80.5<0;0>:f      r80.5<0>:f      
        mad (1|M0)               r51.0<1>:f    r51.0<0;0>:f      r78.6<0;0>:f      r78.6<0>:f      
        mad (1|M0)               r55.0<1>:f    r55.0<0;0>:f      r80.6<0;0>:f      r80.6<0>:f      
        mad (1|M0)               r59.0<1>:f    r59.0<0;0>:f      r78.7<0;0>:f      r78.7<0>:f      
        mad (1|M0)               r63.0<1>:f    r63.0<0;0>:f      r80.7<0;0>:f      r80.7<0>:f      
        mov (1|M0)               r4.6<2>:hf    r3.3<0;1,0>:f                   
        mov (1|M0)               r8.0<2>:hf    r7.0<0;1,0>:f                   
        mov (1|M0)               r12.0<2>:hf   r11.0<0;1,0>:f                  
        mov (1|M0)               r16.0<2>:hf   r15.0<0;1,0>:f                  
        mov (1|M0)               r20.0<2>:hf   r19.0<0;1,0>:f                  
        mov (1|M0)               r24.0<2>:hf   r23.0<0;1,0>:f                  
        mov (1|M0)               r28.0<2>:hf   r27.0<0;1,0>:f                  
        mov (1|M0)               r32.0<2>:hf   r31.0<0;1,0>:f                  
        mov (1|M0)               r36.0<2>:hf   r35.0<0;1,0>:f                  
        mov (1|M0)               r40.0<2>:hf   r39.0<0;1,0>:f                  
        mov (1|M0)               r44.0<2>:hf   r43.0<0;1,0>:f                  
        mov (1|M0)               r48.0<2>:hf   r47.0<0;1,0>:f                  
        mov (1|M0)               r52.0<2>:hf   r51.0<0;1,0>:f                  
        mov (1|M0)               r56.0<2>:hf   r55.0<0;1,0>:f                  
        mov (1|M0)               r60.0<2>:hf   r59.0<0;1,0>:f                  
        mov (1|M0)               r64.0<2>:hf   r63.0<0;1,0>:f                  
        add (1|M0)               r4.6<1>:hf    r4.6<0;1,0>:hf    r8.0<0;1,0>:hf  
        add (1|M0)               r12.0<1>:hf   r12.0<0;1,0>:hf   r16.0<0;1,0>:hf 
        add (1|M0)               r20.0<1>:hf   r20.0<0;1,0>:hf   r24.0<0;1,0>:hf 
        add (1|M0)               r28.0<1>:hf   r28.0<0;1,0>:hf   r32.0<0;1,0>:hf 
        add (1|M0)               r36.0<1>:hf   r36.0<0;1,0>:hf   r40.0<0;1,0>:hf  {F@7}
        add (1|M0)               r44.0<1>:hf   r44.0<0;1,0>:hf   r48.0<0;1,0>:hf  {F@7}
        add (1|M0)               r52.0<1>:hf   r52.0<0;1,0>:hf   r56.0<0;1,0>:hf  {F@7}
        add (1|M0)               r60.0<1>:hf   r60.0<0;1,0>:hf   r64.0<0;1,0>:hf  {F@7}
        add (1|M0)               r4.6<1>:hf    r4.6<0;1,0>:hf    r36.0<0;1,0>:hf  {F@4}
        add (1|M0)               r12.0<1>:hf   r12.0<0;1,0>:hf   r44.0<0;1,0>:hf  {F@4}
        add (1|M0)               r20.0<1>:hf   r20.0<0;1,0>:hf   r52.0<0;1,0>:hf  {F@4}
        add (1|M0)               r28.0<1>:hf   r28.0<0;1,0>:hf   r60.0<0;1,0>:hf  {F@4}
        add (1|M0)               r4.6<1>:hf    r4.6<0;1,0>:hf    r20.0<0;1,0>:hf  {F@2}
        add (1|M0)               r12.0<1>:hf   r12.0<0;1,0>:hf   r28.0<0;1,0>:hf  {F@2}
        cmp (1|M0)    (eq)f0.0   null<1>:d     r67.0<0;1,0>:d    0:w              
        add (1|M0)               r4.6<1>:hf    r4.6<0;1,0>:hf    r12.0<0;1,0>:hf  {F@1}
        mov (1|M0)               r65.0<1>:f    r4.6<0;1,0>:hf                   {F@1}
(W)     and (1|M0)               f1.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
        sel (1|M0)    (ge)f0.0   r65.0<1>:f    r65.0<0;1,0>:f    6.198883e-05:f               {F@1}
(f0.0)  mov (1|M0)               r5.0<1>:d     r4.6<0;1,0>:d                   
        sync.nop                             null                             {Compacted,F@1}
        math.sqt (1|M0)          r65.0<1>:f    r65.0<0;1,0>:f                   {$5}
(f0.0)  mov (1|M0)               r5.1<1>:d     r4.7<0;1,0>:d                   
        math.inv (1|M0)          r65.0<1>:f    r65.0<0;1,0>:f                   {$5}
        mov (1|M0)               r66.0<2>:hf   r65.0<0;1,0>:f                   {$5.dst}
        mov (1|M0)               r81.0<1>:f    r66.0<0;1,0>:hf                  {F@1}
(f1.1.any16h) goto (16|M0)                   L3720                  L3720                
L3696:
        mov (1|M0)               r81.1<1>:f    1.0:f                               {Compacted}
        goto (16|M0)                         L3720                  L3896                
L3720:
        join (16|M0)                         L3896                                
L3736:
        shl (1|M0)               r5.4<1>:d     r67.3<0;1,0>:d    2:w              
        shl (1|M0)               r1.2<1>:d     r67.4<0;1,0>:d    2:w              
        shr (1|M0)               r2.3<1>:ud    r67.3<0;1,0>:ud   0x1E:uw             
        addc (1|M0)              r6.0<1>:ud    r5.2<0;1,0>:ud    r5.4<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r5.5<1>:d     r1.2<0;1,0>:d     r2.3<0;1,0>:d    {I@2}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r8.0<1>:f     r6.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r8.1<1>:d     r7.0<0;0>:d       r5.3<0;0>:d       r5.5<0>:d        {I@1}
        send.ugm (1|M0)          r9       r8      null:0  0x0            0x04100580           {A@1,$6} // wr:2+0, rd:1; load.ugm.d32.a64
        mov (1|M0)               r10.0<2>:hf   r9.0<0;1,0>:f                    {$6.dst}
        mov (1|M0)               r81.1<1>:f    r10.0<0;1,0>:hf                  {F@1}
L3896:
        join (16|M0)                         L4888                                
L3912:
        mov (1|M0)               r81.2<2>:f    0.0:f                              
        mov (1|M0)               r81.3<2>:d    0:d                              
        mov (1|M0)               r81.4<1>:d    0:w                              
L3960:
        shl (1|M0)               r1.3<1>:w     r81.4<0;1,0>:w    2:w               {F@1}
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0x9A0:uw              {A@1}
        mul (1|M0)               r2.3<1>:f     r[a0.0]<0;1,0>:f  r81.0<0;1,0>:f  
        mov (1|M0)               r3.6<2>:hf    r2.3<0;1,0>:f                    {A@1}
        mov (1|M0)               r4.3<1>:f     r3.6<0;1,0>:hf                   {F@1}
        mul (1|M0)               r5.4<1>:f     r81.1<0;1,0>:f    r4.3<0;1,0>:f    {F@1}
        mov (1|M0)               r6.0<2>:hf    r5.4<0;1,0>:f                    {F@1}
        mov (1|M0)               r81.6<1>:f    r6.0<0;1,0>:hf                   {F@1}
(~f0.0) mov (1|M0)               r81.6<1>:f    r4.3<0;1,0>:f                   
        cmp (1|M0)    (lt)f0.1   null<1>:f     r81.6<0;1,0>:f    0.0:f               {F@1}
(f0.1)  mov (1|M0)               r81.6<1>:f    -r81.6<0;1,0>:f                 
        sel (1|M0)    (lt)f0.0   r81.6<1>:f    r81.6<0;1,0>:f    448.0:f               {F@1}
        shr (1|M0)               r81.7<1>:ud   r81.6<0;1,0>:ud   0x17:uw              {F@1}
        and (1|M0)               r81.7<1>:ud   r81.7<0;1,0>:ud   0xFF:uw              {I@1}
        sel (1|M0)    (ge)f0.0   r81.7<1>:ud   r81.7<0;1,0>:ud   0x79:uw              {I@1}
        shl (1|M0)               r81.7<1>:ud   r81.7<0;1,0>:ud   0x17:uw              {I@1}
        add (1|M0)               r7.0<1>:ud    -r81.7<0;1,0>:ud  0x80800000:ud              {I@1}
        sync.nop                             null                             {Compacted,$7.src}
        mul (1|M0)               r8.0<1>:f     r81.6<0;1,0>:f    r7.0<0;1,0>:f    {Compacted,I@1}
        mov (1|M0)               r81.5<1>:d    r8.0<0;1,0>:f                    {Compacted,F@1}
        mov (1|M0)               r84.0<1>:f    r81.5<0;1,0>:d                   {Compacted,I@1}
        mad (1|M0)               r81.6<1>:f    -r84.0<0;0>:f     r7.0<0;0>:f       r81.6<0>:f       {F@1}
        cmp (1|M0)    (gt)f1.0   null<1>:f     r81.6<0;1,0>:f    0.5:f               {F@1}
(W)     and (1|M0)               f1.0<1>:uw    f1.0<0;1,0>:uw    0x1:uw              {F@1}
(f1.0.any16h) goto (16|M0)                   L4416                  L4416                
L4328:
        cmp (1|M0)    (lt)f1.0   null<1>:f     r81.6<0;1,0>:f    0.5:f               {A@1}
        and (1|M0)               r81.5<1>:d    r81.5<0;1,0>:d    1:w              
        add (1|M0)               r1.2<1>:f     r84.0<0;1,0>:f    1.0:f               {Compacted}
(~f1.0) cmp (1|M0)    (eq)f1.0   null<1>:d     r81.5<0;1,0>:d    0:w               {A@1}
(~f1.0) mov (1|M0)               r84.0<1>:f    r1.2<0;1,0>:f                    {F@1}
        goto (16|M0)                         L4416                  L4440                
L4416:
        join (16|M0)                         L4440                                
L4432:
        add (1|M0)               r84.0<1>:f    r84.0<0;1,0>:f    1.0:f               {Compacted,F@1}
L4440:
        join (16|M0)                         L4888                                
L4456:
        addc (1|M0)              r6.0<1>:ud    r81.2<0;1,0>:ud   0x1:ud              {AccWrEn}
        add (1|M0)               r81.7<1>:ud   r81.7<0;1,0>:ud   0xFE800000:ud             
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r84.2<1>:d    r6.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r84.3<1>:d    r7.0<0;0>:d       r81.3<0;0>:d      0:w               {I@2}
        mul (1|M0)               r84.0<1>:f    r84.0<0;1,0>:f    r81.7<0;1,0>:f   {Compacted,F@1}
        cmp (1|M0)    (eq)f1.1   null<1>:d     r84.3<0;1,0>:d    0:w               {I@1}
(f0.1)  mov (1|M0)               r84.0<1>:f    -r84.0<0;1,0>:f                  {F@1}
        shl (1|M0)               r1.3<1>:w     r81.8<0;1,0>:w    1:w              
(W)     mov (1|M0)               r2.6<2>:hf    r84.0<0;1,0>:f                   {F@1}
(f1.1)  cmp (1|M0)    (eq)f1.1   null<1>:d     r84.2<0;1,0>:d    32:w              
        add (1|M0)               r81.4<1>:d    r81.4<0;1,0>:d    1:w              
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0xA40:uw              {A@1}
        mov (1|M0)               r[a0.0]<1>:hf  r2.6<0;1,0>:hf                  {F@1}
(W)     and (1|M0)               f0.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(~f0.1.any16h) goto (16|M0)                  L4840                  L4840                
L4696:
        shl (1|M0)               r5.4<1>:d     r67.5<0;1,0>:d    1:w              
        shl (1|M0)               r1.2<1>:d     r67.6<0;1,0>:d    1:w              
        shr (1|M0)               r2.3<1>:ud    r67.5<0;1,0>:ud   0x1F:uw              {F@1}
        addc (1|M0)              r6.0<1>:ud    r5.0<0;1,0>:ud    r5.4<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r5.5<1>:d     r1.2<0;1,0>:d     r2.3<0;1,0>:d    {I@2}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r8.0<1>:f     r6.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r8.1<1>:d     r7.0<0;0>:d       r5.1<0;0>:d       r5.5<0>:d        {I@1}
        send.ugm (1|M0)          null     r8      r82:2   0x0            0x0200C784           {A@1,$7} // wr:1+2, rd:0; store.ugm.d64x8t.a64
        goto (16|M0)                         L4840                  L5688                
L4840:
        join (16|M0)                         L4888                                
L4856:
(W)     mov (2|M0)               r81.2<1>:ud   r84.2<1;1,0>:ud                 
        goto.b (16|M0)                       L4888                  L3960                
L4888:
        join (16|M0)                         L5688                                
L4904:
        mov (1|M0)               r84.1<1>:d    0:w                              
L4920:
        shl (1|M0)               r1.3<1>:w     r84.2<0;1,0>:w    2:w               {I@1}
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0x880:uw              {A@1}
        cmp (1|M0)    (lt)f0.0   null<1>:f     r[a0.0]<0;1,0>:f  0.0:f              
(W)     mov (1|M0)               r2.3<1>:f     -r[a0.0]<0;1,0>:f                {A@1}
(W)     mov (1|M0)               r3.3<1>:f     r[a0.0]<0;1,0>:f                 {A@1}
(f0.0)  sel (1|M0)               r84.5<1>:f    r2.3<0;1,0>:f     r3.3<0;1,0>:f    {A@1}
        sel (1|M0)    (lt)f0.0   r84.5<1>:f    r84.5<0;1,0>:f    448.0:f               {F@1}
        shr (1|M0)               r84.6<1>:ud   r84.5<0;1,0>:ud   0x17:uw              {F@1}
        and (1|M0)               r84.6<1>:ud   r84.6<0;1,0>:ud   0xFF:uw              {I@1}
        sel (1|M0)    (ge)f0.0   r84.6<1>:ud   r84.6<0;1,0>:ud   0x79:uw              {I@1}
        shl (1|M0)               r84.6<1>:ud   r84.6<0;1,0>:ud   0x17:uw              {I@1}
        add (1|M0)               r4.3<1>:ud    -r84.6<0;1,0>:ud  0x80800000:ud              {I@1}
        mul (1|M0)               r5.4<1>:f     r84.5<0;1,0>:f    r4.3<0;1,0>:f    {I@1}
        mov (1|M0)               r84.4<1>:d    r5.4<0;1,0>:f                    {F@1}
        mov (1|M0)               r84.7<1>:f    r84.4<0;1,0>:d                   {I@1}
        mad (1|M0)               r84.5<1>:f    -r84.7<0;0>:f     r4.3<0;0>:f       r84.5<0>:f       {F@1}
        cmp (1|M0)    (gt)f0.1   null<1>:f     r84.5<0;1,0>:f    0.5:f               {F@1}
(W)     and (1|M0)               f1.1<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(f1.1.any16h) goto (16|M0)                   L5320                  L5320                
L5224:
        cmp (1|M0)    (lt)f1.0   null<1>:f     r84.5<0;1,0>:f    0.5:f              
        and (1|M0)               r84.4<1>:d    r84.4<0;1,0>:d    1:w              
        add (1|M0)               r1.2<1>:f     r84.7<0;1,0>:f    1.0:f              
(~f1.0) cmp (1|M0)    (eq)f1.0   null<1>:d     r84.4<0;1,0>:d    0:w               {A@1}
(~f1.0) mov (1|M0)               r84.7<1>:f    r1.2<0;1,0>:f                    {F@1}
        goto (16|M0)                         L5320                  L5352                
L5320:
        join (16|M0)                         L5352                                
L5336:
        add (1|M0)               r84.7<1>:f    r84.7<0;1,0>:f    1.0:f               {F@1}
L5352:
        join (16|M0)                         L5536                                
L5368:
        add (1|M0)               r84.6<1>:ud   r84.6<0;1,0>:ud   0xFE800000:ud             
        shl (1|M0)               r1.3<1>:w     r84.2<0;1,0>:w    1:w              
        mul (1|M0)               r84.7<1>:f    r84.7<0;1,0>:f    r84.6<0;1,0>:f   {A@1}
        add (1|M0)               r84.1<1>:d    r84.1<0;1,0>:d    1:w               {Compacted}
(f0.0)  mov (1|M0)               r84.7<1>:f    -r84.7<0;1,0>:f                  {F@1}
        cmp (1|M0)    (eq)f0.0   null<1>:d     r84.1<0;1,0>:d    32:w               {A@1}
(W)     mov (1|M0)               r2.6<2>:hf    r84.7<0;1,0>:f                  
        add (1|M0)               a0.0<1>:uw    r1.3<0;1,0>:uw    0xAA0:uw              {A@1}
        mov (1|M0)               r[a0.0]<1>:hf  r2.6<0;1,0>:hf                  {F@1}
(W)     and (1|M0)               f1.0<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
(~f1.0.any16h) goto.b (16|M0)                L5536                  L4920                
L5536:
        join (16|M0)                         L5688                                
L5552:
        shl (1|M0)               r5.4<1>:d     r67.5<0;1,0>:d    1:w              
        shl (1|M0)               r1.2<1>:d     r67.6<0;1,0>:d    1:w              
        shr (1|M0)               r2.3<1>:ud    r67.5<0;1,0>:ud   0x1F:uw              {F@1}
        addc (1|M0)              r6.0<1>:ud    r4.4<0;1,0>:ud    r5.4<0;1,0>:ud   {AccWrEn,I@3}
        or (1|M0)                r5.5<1>:d     r1.2<0;1,0>:d     r2.3<0;1,0>:d    {I@2}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        sync.nop                             null                             {Compacted,$7.src}
        mov (1|M0)               r8.0<1>:f     r6.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r8.1<1>:d     r7.0<0;0>:d       r4.5<0;0>:d       r5.5<0>:d        {I@1}
        send.ugm (1|M0)          null     r8      r85:2   0x0            0x0200C784           {A@1,$8} // wr:1+2, rd:0; store.ugm.d64x8t.a64
L5688:
        join (16|M0)                         L5704                                
L5704:
(W)     mov (8|M0)               r127.0<1>:f   r0.0<1;1,0>:f                    {Compacted}
(W)     send.ugm (1|M0)          r6       r0      null:0  0x0            0x0210641F           {$9} // wr:1+0, rd:1; fence invalid flush type scoped to tile
(W)     mov (8|M0)               null<1>:ud    r6.0<1;1,0>:ud                   {$9.dst}
(W)     send.gtwy (1|M0)         null     r127    null:0  0x0            0x02000010           {EOT,A@1} // wr:1+0, rd:0; end of thread
L5760:
        mov (1|M0)               r1.2<1>:d     cr0.0<0;1,0>:ud                  {A@1}
        and (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   -1265:w               {A@1}
        or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   1264:w               {A@1}
        mov (1|M0)               r2.3<1>:f     r87.0<0;1,0>:ud                  {Compacted,A@1}
        mov (1|M0)               r9.0<1>:f     0xB4C00000:f                               {Compacted}
        math.inv (1|M0)          r8.0<1>:f     r2.3<0;1,0>:f                    {@2,$10}
        mov (1|M0)               r5.5<1>:f     r87.5<0;1,0>:ud                 
        sync.nop                             null                             {Compacted,$10.dst}
        mad (1|M0)               r8.0<1>:f     r8.0<0;0>:f       r9.0<0;0>:f       r8.0<0>:f        {F@2}
        mov (1|M0)               r87.4<1>:ud   r2.3<0;1,0>:f                   
        mov (1|M0)               r6.0<1>:ud    r5.5<0;1,0>:f                    {F@2}
        mul (1|M0)               r10.0<1>:f    r8.0<0;1,0>:f     r5.5<0;1,0>:f    {Compacted,F@1}
        add (1|M0)               r87.4<1>:ud   r87.0<0;1,0>:ud   -r87.4<0;1,0>:ud {I@2}
        add (1|M0)               r6.0<1>:ud    r87.5<0;1,0>:ud   -r6.0<0;1,0>:ud  {Compacted,I@2}
        mov (1|M0)               r11.0<1>:ud   r10.0<0;1,0>:f                   {F@1}
        mov (1|M0)               r5.4<1>:f     r87.4<0;1,0>:ud                  {I@3}
        mov (1|M0)               r7.0<1>:f     r6.0<0;1,0>:ud                   {Compacted,I@2}
        mov (1|M0)               r12.0<1>:f    r11.0<0;1,0>:ud                  {Compacted,I@1}
(W)     mov (1|M0)               r15.0<1>:hf   0x1:hf                             
        mad (1|M0)               r5.5<1>:f     r5.5<0;0>:f       r12.0<0;0>:f      -r2.3<0>:f       {F@2}
        mad (1|M0)               r12.0<1>:f    r7.0<0;0>:f       r12.0<0;0>:f      -r5.4<0>:f      
        add (1|M0)               r5.5<1>:f     r5.5<0;1,0>:f     r12.0<0;1,0>:f   {F@1}
        mul (1|M0)               r8.0<1>:f     r8.0<0;1,0>:f     r5.5<0;1,0>:f    {Compacted,F@1}
        mov (1|M0)               r13.0<1>:ud   r8.0<0;1,0>:f                    {F@1}
        add (1|M0)               r11.0<1>:ud   r11.0<0;1,0>:ud   r13.0<0;1,0>:ud  {Compacted,I@1}
(W)     mul (1|M0)               acc0.0<1>:ud  r11.0<0;1,0>:ud   r87.0<0;1,0>:uw  {I@1}
        mach (1|M0)              r14.0<1>:ud   r11.0<0;1,0>:ud   r87.0<0;1,0>:ud  {Compacted}
        add (1|M0)               r87.5<1>:ud   r87.5<0;1,0>:ud   -r14.0<0;1,0>:ud {I@1}
        cmp (1|M0)    (ge)f1.1   null<1>:ud    r87.5<0;1,0>:ud   r87.0<0;1,0>:ud  {I@1}
(f1.1)  sel (1|M0)               r16.0<1>:d    r15.0<0;1,0>:w    0:w              
        add (1|M0)               r87.1<1>:ud   r11.0<0;1,0>:ud   r16.0<0;1,0>:ud  {Compacted,I@1}
        mov (1|M0)               cr0.0<1>:ud   r1.2<0;1,0>:d                    {A@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        ret (16|M0)                          r88.2                            {A@1}
L6232:
        mov (1|M0)               r1.2<1>:d     cr0.0<0;1,0>:ud                  {A@1}
        and (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   -1265:w               {A@1}
        or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   1264:w               {A@1}
        mov (1|M0)               r2.3<1>:f     r87.2<0;1,0>:ud                  {A@1}
        mov (1|M0)               r9.0<1>:f     0xB4C00000:f                               {Compacted}
        math.inv (1|M0)          r8.0<1>:f     r2.3<0;1,0>:f                    {@2,$11}
        mov (1|M0)               r5.5<1>:f     r88.1<0;1,0>:ud                 
        sync.nop                             null                             {Compacted,$11.dst}
        mad (1|M0)               r8.0<1>:f     r8.0<0;0>:f       r9.0<0;0>:f       r8.0<0>:f        {F@2}
        mov (1|M0)               r88.0<1>:ud   r2.3<0;1,0>:f                   
        mov (1|M0)               r6.0<1>:ud    r5.5<0;1,0>:f                    {F@2}
        mul (1|M0)               r10.0<1>:f    r8.0<0;1,0>:f     r5.5<0;1,0>:f    {Compacted,F@1}
        add (1|M0)               r88.0<1>:ud   r87.2<0;1,0>:ud   -r88.0<0;1,0>:ud {Compacted,I@2}
        add (1|M0)               r6.0<1>:ud    r88.1<0;1,0>:ud   -r6.0<0;1,0>:ud  {Compacted,I@2}
        mov (1|M0)               r11.0<1>:ud   r10.0<0;1,0>:f                   {F@1}
        mov (1|M0)               r5.4<1>:f     r88.0<0;1,0>:ud                  {Compacted,I@3}
        mov (1|M0)               r7.0<1>:f     r6.0<0;1,0>:ud                   {Compacted,I@2}
        mov (1|M0)               r12.0<1>:f    r11.0<0;1,0>:ud                  {Compacted,I@1}
        mad (1|M0)               r5.5<1>:f     r5.5<0;0>:f       r12.0<0;0>:f      -r2.3<0>:f       {F@1}
        mad (1|M0)               r12.0<1>:f    r7.0<0;0>:f       r12.0<0;0>:f      -r5.4<0>:f      
        add (1|M0)               r5.5<1>:f     r5.5<0;1,0>:f     r12.0<0;1,0>:f   {F@1}
        mul (1|M0)               r8.0<1>:f     r8.0<0;1,0>:f     r5.5<0;1,0>:f    {Compacted,F@1}
        mov (1|M0)               r13.0<1>:ud   r8.0<0;1,0>:f                    {F@1}
        add (1|M0)               r11.0<1>:ud   r11.0<0;1,0>:ud   r13.0<0;1,0>:ud  {Compacted,I@1}
(W)     mul (1|M0)               acc0.0<1>:ud  r11.0<0;1,0>:ud   r87.4<0;1,0>:uw  {I@1}
        mach (1|M0)              r11.0<1>:ud   r11.0<0;1,0>:ud   r87.2<0;1,0>:ud  {Compacted}
        add (1|M0)               r88.1<1>:ud   r88.1<0;1,0>:ud   -r11.0<0;1,0>:ud {Compacted,I@1}
        cmp (1|M0)    (lt)f1.1   null<1>:ud    r88.1<0;1,0>:ud   r87.2<0;1,0>:ud  {I@1}
(f1.1)  mov (1|M0)               r87.2<1>:d    0:w                              
        add (1|M0)               r67.1<1>:ud   r88.1<0;1,0>:ud   -r87.2<0;1,0>:ud {I@1}
        mov (1|M0)               cr0.0<1>:ud   r1.2<0;1,0>:d                    {A@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        ret (16|M0)                          r87.6                            {A@1}
L6680:
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
