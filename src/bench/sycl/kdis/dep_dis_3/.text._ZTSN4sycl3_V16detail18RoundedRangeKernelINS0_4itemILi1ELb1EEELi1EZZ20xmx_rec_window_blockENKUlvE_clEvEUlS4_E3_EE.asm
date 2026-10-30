L0:
(W)     mov (8|M0)               r127.0<1>:ud  0x0:ud                             
(W)     and (1|M0)               r127.2<1>:ud  r0.0<0;1,0>:ud    0xFFFFFFC0:ud             
(W)     and (1|M0)               r127.0<1>:uw  r0.4<0;1,0>:uw    0xFF:uw             
(W)     add (1|M0)               r127.2<1>:ud  r127.2<0;1,0>:ud  0x80:ud              {I@2}
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
(W)     send.dc0 (8|M0)          r5       r127    null:0  0x0            0x024844FD           {A@1,$2} // wr:1h+0, rd:4; oword aligned block read x8
(W)     mov (8|M0)               r98.0<1>:ud   r0.0<1;1,0>:ud                  
(W)     or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x4C0:uw              {A@1}
(W)     mul (1|M0)               acc0.0<1>:ud  r4.3<0;1,0>:ud    r98.2<0;1,0>:uw  {A@1}
(W)     mach (1|M0)              r3.0<1>:ud    r4.3<0;1,0>:ud    r98.1<0;1,0>:ud  {AccWrEn,$1.dst}
        mov (16|M0)              r10.0<1>:d    r1.0<1;1,0>:uw                   {$0.dst}
(W)     mov (1|M0)               r2.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (8|M0)              r12.0<1>:ud   r2.0<0;1,0>:ud    r10.0<1;1,0>:ud  {AccWrEn,Compacted,I@1}
        add (8|M0)               r14.0<1>:ud   acc0.0<1;1,0>:ud  r3.0<0;1,0>:ud  
        addc (8|M8)              r13.0<1>:ud   r2.0<0;1,0>:ud    r11.0<1;1,0>:ud  {AccWrEn}
        add (8|M8)               r15.0<1>:ud   acc0.0<1;1,0>:ud  r3.0<0;1,0>:ud  
        addc (8|M0)              r44.0<1>:ud   r12.0<1;1,0>:ud   r4.0<0;1,0>:ud   {AccWrEn,Compacted,I@4}
        add (8|M0)               r42.0<1>:ud   acc0.0<1;1,0>:ud  r14.0<1;1,0>:ud  {I@4}
        addc (8|M8)              r45.0<1>:ud   r13.0<1;1,0>:ud   r4.0<0;1,0>:ud   {AccWrEn,I@4}
        cmp (16|M0)   (lt)f0.0   null<1>:d     r44.0<1;1,0>:ud   r4.6<0;1,0>:ud   {I@1}
        add (8|M8)               r43.0<1>:ud   acc0.0<1;1,0>:ud  r15.0<1;1,0>:ud 
(f0.0)  cmp (16|M0)   (eq)f0.0   null<1>:d     r42.0<1;1,0>:d    r4.7<0;1,0>:d    {I@1}
(~f0.0) cmp (16|M0)   (lt)f0.0   null<1>:d     r42.0<1;1,0>:ud   r4.7<0;1,0>:ud  
(~f0.0) goto (16|M0)                         L29968                  L29968                
L520:
(W)     mov (2|M0)               r8.0<1>:d     r6.2<1;1,0>:d                    {$2.dst}
(W)     mov (2|M0)               r4.3<1>:d     r7.4<1;1,0>:d                   
(W)     mov (2|M0)               r8.5<1>:d     r7.6<1;1,0>:d                   
(W)     cmp (16|M0)   (eq)f0.1   null<1>:d     r5.0<0;1,0>:d     0:w              
(W)     cmp (16|M0)   (eq)f0.0   null<1>:w     r6.16<0;1,0>:b    0:w              
        mov (16|M0)              r40.0<1>:f    r44.0<1;1,0>:f                   {Compacted}
        mov (16|M0)              r6.0<1>:f     r42.0<1;1,0>:f                   {Compacted,A@1}
(W)     mov (1|M0)               r99.0<1>:d    7:w                              
L632:
        shr (16|M0)              r68.0<1>:ud   r40.0<1;1,0>:ud   6:w               {F@2}
(~f0.1) goto (16|M0)                         L696                  L696                
L664:
        mov (16|M0)              r96.0<1>:d    -1:w                              
        goto (16|M0)                         L696                  L1080                
L696:
        join (16|M0)                         L1080                                
L712:
(W)     xor (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x30:uw              {A@1}
(W)     mov (1|M0)               r2.0<1>:f     r5.0<0;1,0>:ud                   {Compacted,A@1}
(W)     mov (1|M0)               r3.2<1>:f     0xB4C00000:f                               {Compacted}
(W)     math.inv (1|M0)          r3.1<1>:f     r2.0<0;1,0>:f                    {@2,$10}
        sync.nop                             null                             {Compacted,$9.src}
        mov (16|M0)              r10.0<1>:f    r68.0<1;1,0>:ud                  {Compacted,I@6}
        sync.nop                             null                             {Compacted,$10.dst}
(W)     mad (1|M0)               r5.5<1>:f     r3.1<0;0>:f       r3.2<0;0>:f       r3.1<0>:f        {F@2}
(W)     mov (1|M0)               r2.1<1>:ud    r2.0<0;1,0>:f                   
        sync.allrd                           ($3,$5,$6,$7,$8)                
        mov (16|M0)              r14.0<1>:ud   r10.0<1;1,0>:f                   {F@2}
        mul (16|M0)              r12.0<1>:f    r10.0<1;1,0>:f    r5.5<0;1,0>:f    {Compacted,F@1}
(W)     add (1|M0)               r3.0<1>:d     r5.0<0;1,0>:d     -r2.1<0;1,0>:d   {Compacted,I@2}
        add (16|M0)              r14.0<1>:d    r68.0<1;1,0>:d    -r14.0<1;1,0>:d  {Compacted,I@2}
        mov (16|M0)              r16.0<1>:ud   r12.0<1;1,0>:f                   {F@1}
(W)     mov (1|M0)               r5.6<1>:f     r3.0<0;1,0>:ud                   {Compacted,I@3}
        mov (16|M0)              r18.0<1>:f    r14.0<1;1,0>:ud                  {Compacted,I@2}
        mov (16|M0)              r20.0<1>:f    r16.0<1;1,0>:ud                  {Compacted,I@1}
        mad (16|M0)              acc0.0<1>:f   r10.0<1;0>:f      r20.0<1;0>:f      -r2.0<0>:f       {Compacted,F@1}
        mad (16|M0)              acc2.0<1>:f   r18.0<1;0>:f      r20.0<1;0>:f      -r5.6<0>:f       {Compacted}
        add (16|M0)              acc0.0<1>:f   acc0.0<1;1,0>:f   acc2.0<1;1,0>:f 
        mul (16|M0)              r28.0<1>:f    r5.5<0;1,0>:f     acc0.0<1;1,0>:f  {$4.src}
(W)     xor (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x30:uw              {A@1}
        mov (16|M0)              r30.0<1>:ud   r28.0<1;1,0>:f                   {A@1}
        add (16|M0)              r32.0<1>:d    r30.0<1;1,0>:d    r16.0<1;1,0>:d   {Compacted,I@1}
(W)     mul (8|M0)               acc0.0<1>:d   r32.0<1;1,0>:d    r5.0<0;1,0>:uw   {Compacted,I@1}
        mach (8|M0)              r32.0<1>:d    r32.0<1;1,0>:d    r5.0<0;1,0>:d    {Compacted}
(W)     mul (8|M8)               acc0.0<1>:d   r33.0<1;1,0>:d    r5.0<0;1,0>:uw  
        mach (8|M8)              r33.0<1>:d    r33.0<1;1,0>:d    r5.0<0;1,0>:d    {Compacted}
        add (16|M0)              r32.0<1>:d    r68.0<1;1,0>:d    -r32.0<1;1,0>:d  {Compacted,I@1}
        cmp (16|M0)   (ge)f1.0   r10.0<1>:ud   r32.0<1;1,0>:ud   r5.0<0;1,0>:ud   {I@1}
        add3 (16|M0)             r96.0<1>:d    r30.0<1;0>:d      r16.0<1;0>:d      -r10.0<1>:d      {I@1}
L1080:
        join (16|M0)                         L29968                                
L1096:
(W)     mul (8|M0)               acc0.0<1>:d   r96.0<1;1,0>:d    r5.0<0;1,0>:uw   {Compacted,I@2}
        mach (8|M0)              r12.0<1>:d    r96.0<1;1,0>:d    r5.0<0;1,0>:d    {Compacted}
(W)     mul (8|M8)               acc0.0<1>:d   r97.0<1;1,0>:d    r5.0<0;1,0>:uw  
        sync.allrd                           ($5,$6,$7,$8)                
        mach (8|M8)              r13.0<1>:d    r97.0<1;1,0>:d    r5.0<0;1,0>:d    {Compacted,$3.src}
        shl (16|M0)              r2.0<1>:d     r96.0<1;1,0>:d    3:w               {Compacted}
        shr (16|M0)              r10.0<1>:ud   r40.0<1;1,0>:ud   3:w               {$9.src}
        add (16|M0)              r12.0<1>:d    r68.0<1;1,0>:d    -r12.0<1;1,0>:d  {Compacted,I@3}
        bfn.0xEA (16|M0)         r2.0<1>:ud    r2.0<1;0>:ud      r10.0<1;0>:ud     r99.0<0>:ud      {I@2} // s0|s1&s2
        shl (16|M0)              r12.0<1>:d    r12.0<1;1,0>:d    3:w               {Compacted,I@2}
        add (16|M0)              r100.0<1>:d   r2.0<1;1,0>:d     -r5.1<0;1,0>:d   {Compacted,I@2}
        bfn.0xEA (16|M0)         r12.0<1>:ud   r12.0<1;0>:ud     r40.0<1;0>:ud     r99.0<0>:ud      {I@2} // s0|s1&s2
        cmp (16|M0)   (lt)f1.1   null<1>:d     r100.0<1;1,0>:d   r5.3<0;1,0>:d    {I@2}
        add (16|M0)              r72.0<1>:d    r12.0<1;1,0>:d    -r5.2<0;1,0>:d   {Compacted,I@2}
        or (16|M0)               r14.0<1>:d    r100.0<1;1,0>:d   r72.0<1;1,0>:d   {Compacted,I@1}
(f1.1)  cmp (16|M0)   (gt)f1.1   null<1>:d     r14.0<1;1,0>:d    -1:w               {I@1}
(f1.1)  cmp (16|M0)   (lt)f1.1   null<1>:d     r72.0<1;1,0>:d    r5.4<0;1,0>:d   
(f1.1)  goto (16|M0)                         L3320                  L3320                
L1312:
        shl (16|M0)              r2.0<1>:d     r40.0<1;1,0>:d    6:w               {Compacted}
        shr (16|M0)              r10.0<1>:ud   r40.0<1;1,0>:ud   26:w              
        shl (16|M0)              r12.0<1>:d    r6.0<1;1,0>:d     6:w               {Compacted}
        addc (8|M0)              r14.0<1>:ud   r2.0<1;1,0>:ud    r8.0<0;1,0>:ud   {AccWrEn,Compacted,I@3}
        or (16|M0)               r12.0<1>:d    r12.0<1;1,0>:d    r10.0<1;1,0>:d   {Compacted,I@2}
        add3 (8|M0)              r16.0<1>:ud   acc0.0<1;0>:ud    r12.0<1;0>:ud     r8.1<0>:ud       {I@1}
        addc (8|M8)              r15.0<1>:ud   r3.0<1;1,0>:ud    r8.0<0;1,0>:ud   {AccWrEn}
        mov (8|M0)               r22.0<2>:d    r14.0<1;1,0>:d                  
        add3 (8|M8)              r17.0<1>:ud   acc0.0<1;0>:ud    r13.0<1;0>:ud     r8.1<0>:ud      
        addc (8|M0)              r18.0<1>:ud   r14.0<1;1,0>:ud   0x8:ud              {AccWrEn,Compacted}
        mov (16|M0)              r10.0<1>:d    0:w                              
        add (8|M0)               r20.0<1>:ud   acc0.0<1;1,0>:ud  r16.0<1;1,0>:ud  {I@6}
        addc (8|M8)              r19.0<1>:ud   r15.0<1;1,0>:ud   0x8:ud              {AccWrEn,I@6}
        mov (8|M8)               r24.0<2>:d    r15.0<1;1,0>:d                  
        add (8|M8)               r21.0<1>:ud   acc0.0<1;1,0>:ud  r17.0<1;1,0>:ud  {I@6}
        addc (8|M0)              r2.0<1>:ud    r14.0<1;1,0>:ud   0x4:ud              {AccWrEn,Compacted}
        mov (8|M0)               r22.1<2>:d    r16.0<1;1,0>:d                  
        mov (8|M0)               r12.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        addc (8|M8)              r3.0<1>:ud    r15.0<1;1,0>:ud   0x4:ud              {AccWrEn}
        sync.nop                             null                             {Compacted,$4.src}
        add (8|M0)               r26.1<2>:ud   r12.0<1;1,0>:ud   r16.0<1;1,0>:ud  {Compacted,I@2}
        mov (8|M8)               r30.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        addc (8|M0)              r32.0<1>:ud   r14.0<1;1,0>:ud   0x10:ud              {AccWrEn,Compacted}
        add (8|M8)               r28.1<2>:ud   r30.0<1;1,0>:ud   r17.0<1;1,0>:ud  {Compacted,I@2}
        add (8|M0)               r34.0<1>:ud   acc0.0<1;1,0>:ud  r16.0<1;1,0>:ud 
        addc (8|M8)              r33.0<1>:ud   r15.0<1;1,0>:ud   0x10:ud              {AccWrEn}
        mov (8|M0)               r26.0<2>:d    r2.0<1;1,0>:d                   
        add (8|M8)               r35.0<1>:ud   acc0.0<1;1,0>:ud  r17.0<1;1,0>:ud 
        addc (8|M0)              r12.0<1>:ud   r18.0<1;1,0>:ud   0x4:ud              {AccWrEn,Compacted}
        mov (8|M8)               r24.1<2>:d    r17.0<1;1,0>:d                  
        mov (8|M0)               r30.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        addc (8|M8)              r13.0<1>:ud   r19.0<1;1,0>:ud   0x4:ud              {AccWrEn}
        mov (8|M8)               r28.0<2>:d    r3.0<1;1,0>:d                   
        mov (8|M8)               r2.0<1>:ud    acc0.0<1;1,0>:ud                 {Compacted}
        addc (8|M0)              r36.0<1>:ud   r14.0<1;1,0>:ud   0x18:ud              {AccWrEn,Compacted}
        send.ugm (16|M0)         null     r22     r10:2   0x0            0x080E0584           {A@6,$11} // wr:4+2, rd:0; store.ugm.d32.a64.wb.wb
        add (8|M0)               r38.0<1>:ud   acc0.0<1;1,0>:ud  r16.0<1;1,0>:ud 
        addc (8|M8)              r37.0<1>:ud   r15.0<1;1,0>:ud   0x18:ud              {AccWrEn}
        send.ugm (16|M0)         null     r26     r10:2   0x0            0x080E0584           {A@5,$12} // wr:4+2, rd:0; store.ugm.d32.a64.wb.wb
        add (8|M8)               r39.0<1>:ud   acc0.0<1;1,0>:ud  r17.0<1;1,0>:ud 
        sync.nop                             null                             {Compacted,$12.src}
        add (8|M8)               r28.1<2>:ud   r2.0<1;1,0>:ud    r21.0<1;1,0>:ud  {Compacted,I@5}
        addc (8|M0)              r2.0<1>:ud    r32.0<1;1,0>:ud   0x4:ud              {AccWrEn,Compacted}
        mov (8|M0)               r22.0<2>:d    r18.0<1;1,0>:d                   {$11.src}
        mov (8|M0)               r18.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        addc (8|M8)              r3.0<1>:ud    r33.0<1;1,0>:ud   0x4:ud              {AccWrEn}
        add (8|M0)               r26.1<2>:ud   r30.0<1;1,0>:ud   r20.0<1;1,0>:ud  {Compacted}
        mov (8|M0)               r22.1<2>:d    r20.0<1;1,0>:d                  
        mov (8|M0)               r26.0<2>:d    r12.0<1;1,0>:d                  
        mov (8|M8)               r12.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        addc (8|M0)              r20.0<1>:ud   r14.0<1;1,0>:ud   0x20:ud              {AccWrEn,Compacted}
        mov (8|M8)               r24.0<2>:d    r19.0<1;1,0>:d                  
        mov (8|M8)               r28.0<2>:d    r13.0<1;1,0>:d                  
        mov (8|M8)               r24.1<2>:d    r21.0<1;1,0>:d                  
        add (8|M0)               r30.0<1>:ud   acc0.0<1;1,0>:ud  r16.0<1;1,0>:ud 
        addc (8|M8)              r21.0<1>:ud   r15.0<1;1,0>:ud   0x20:ud              {AccWrEn}
        send.ugm (16|M0)         null     r22     r10:2   0x0            0x080E0584           {A@3,$13} // wr:4+2, rd:0; store.ugm.d32.a64.wb.wb
        send.ugm (16|M0)         null     r26     r10:2   0x0            0x080E0584           {$14} // wr:4+2, rd:0; store.ugm.d32.a64.wb.wb
        add (8|M8)               r31.0<1>:ud   acc0.0<1;1,0>:ud  r17.0<1;1,0>:ud 
        add (8|M8)               r28.1<2>:ud   r12.0<1;1,0>:ud   r35.0<1;1,0>:ud  {Compacted,$14.src}
        addc (8|M0)              r12.0<1>:ud   r36.0<1;1,0>:ud   0x4:ud              {AccWrEn,Compacted}
        add (8|M0)               r26.1<2>:ud   r18.0<1;1,0>:ud   r34.0<1;1,0>:ud  {Compacted}
        mov (8|M0)               r18.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        addc (8|M8)              r13.0<1>:ud   r37.0<1;1,0>:ud   0x4:ud              {AccWrEn}
        mov (8|M0)               r22.0<2>:d    r32.0<1;1,0>:d                   {$13.src}
        mov (8|M0)               r26.0<2>:d    r2.0<1;1,0>:d                   
        mov (8|M8)               r2.0<1>:ud    acc0.0<1;1,0>:ud                 {Compacted}
        addc (8|M0)              r32.0<1>:ud   r14.0<1;1,0>:ud   0x28:ud              {AccWrEn,Compacted}
        mov (8|M8)               r24.0<2>:d    r33.0<1;1,0>:d                  
        mov (8|M8)               r28.0<2>:d    r3.0<1;1,0>:d                   
        mov (8|M0)               r22.1<2>:d    r34.0<1;1,0>:d                  
        mov (8|M8)               r24.1<2>:d    r35.0<1;1,0>:d                  
        add (8|M0)               r34.0<1>:ud   acc0.0<1;1,0>:ud  r16.0<1;1,0>:ud 
        addc (8|M8)              r33.0<1>:ud   r15.0<1;1,0>:ud   0x28:ud              {AccWrEn}
        send.ugm (16|M0)         null     r22     r10:2   0x0            0x080E0584           {A@3,$15} // wr:4+2, rd:0; store.ugm.d32.a64.wb.wb
        send.ugm (16|M0)         null     r26     r10:2   0x0            0x080E0584           {$0} // wr:4+2, rd:0; store.ugm.d32.a64.wb.wb
        add (8|M8)               r35.0<1>:ud   acc0.0<1;1,0>:ud  r17.0<1;1,0>:ud 
        add (8|M8)               r28.1<2>:ud   r2.0<1;1,0>:ud    r39.0<1;1,0>:ud  {Compacted,$0.src}
        addc (8|M0)              r2.0<1>:ud    r20.0<1;1,0>:ud   0x4:ud              {AccWrEn,Compacted}
        add (8|M0)               r26.1<2>:ud   r18.0<1;1,0>:ud   r38.0<1;1,0>:ud  {Compacted}
        mov (8|M0)               r18.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        addc (8|M8)              r3.0<1>:ud    r21.0<1;1,0>:ud   0x4:ud              {AccWrEn}
        mov (8|M0)               r22.0<2>:d    r36.0<1;1,0>:d                   {$15.src}
        mov (8|M0)               r26.0<2>:d    r12.0<1;1,0>:d                  
        mov (8|M8)               r12.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        addc (8|M0)              r36.0<1>:ud   r14.0<1;1,0>:ud   0x30:ud              {AccWrEn,Compacted}
        mov (8|M8)               r24.0<2>:d    r37.0<1;1,0>:d                  
        mov (8|M8)               r28.0<2>:d    r13.0<1;1,0>:d                  
        mov (8|M0)               r22.1<2>:d    r38.0<1;1,0>:d                  
        mov (8|M8)               r24.1<2>:d    r39.0<1;1,0>:d                  
        add (8|M0)               r38.0<1>:ud   acc0.0<1;1,0>:ud  r16.0<1;1,0>:ud 
        addc (8|M8)              r37.0<1>:ud   r15.0<1;1,0>:ud   0x30:ud              {AccWrEn}
        send.ugm (16|M0)         null     r22     r10:2   0x0            0x080E0584           {A@3,$1} // wr:4+2, rd:0; store.ugm.d32.a64.wb.wb
        send.ugm (16|M0)         null     r26     r10:2   0x0            0x080E0584           {$10} // wr:4+2, rd:0; store.ugm.d32.a64.wb.wb
        add (8|M8)               r39.0<1>:ud   acc0.0<1;1,0>:ud  r17.0<1;1,0>:ud 
        add (8|M8)               r28.1<2>:ud   r12.0<1;1,0>:ud   r31.0<1;1,0>:ud  {Compacted,$10.src}
        addc (8|M0)              r12.0<1>:ud   r32.0<1;1,0>:ud   0x4:ud              {AccWrEn,Compacted}
        add (8|M0)               r26.1<2>:ud   r18.0<1;1,0>:ud   r30.0<1;1,0>:ud  {Compacted}
        mov (8|M0)               r18.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        addc (8|M8)              r13.0<1>:ud   r33.0<1;1,0>:ud   0x4:ud              {AccWrEn}
        mov (8|M0)               r22.0<2>:d    r20.0<1;1,0>:d                   {$1.src}
        mov (8|M0)               r26.0<2>:d    r2.0<1;1,0>:d                   
        mov (8|M8)               r2.0<1>:ud    acc0.0<1;1,0>:ud                 {Compacted}
        addc (8|M0)              r20.0<1>:ud   r14.0<1;1,0>:ud   0x38:ud              {AccWrEn,Compacted}
        mov (8|M8)               r24.0<2>:d    r21.0<1;1,0>:d                  
        mov (8|M8)               r28.0<2>:d    r3.0<1;1,0>:d                   
        mov (8|M0)               r22.1<2>:d    r30.0<1;1,0>:d                  
        mov (8|M8)               r24.1<2>:d    r31.0<1;1,0>:d                  
        add (8|M0)               r30.0<1>:ud   acc0.0<1;1,0>:ud  r16.0<1;1,0>:ud 
        addc (8|M8)              r21.0<1>:ud   r15.0<1;1,0>:ud   0x38:ud              {AccWrEn}
        send.ugm (16|M0)         null     r22     r10:2   0x0            0x080E0584           {A@3,$11} // wr:4+2, rd:0; store.ugm.d32.a64.wb.wb
        send.ugm (16|M0)         null     r26     r10:2   0x0            0x080E0584           {$12} // wr:4+2, rd:0; store.ugm.d32.a64.wb.wb
        add (8|M8)               r31.0<1>:ud   acc0.0<1;1,0>:ud  r17.0<1;1,0>:ud 
        mov (8|M0)               r22.0<2>:d    r32.0<1;1,0>:d                   {$11.src}
        mov (8|M8)               r24.0<2>:d    r33.0<1;1,0>:d                  
        add (8|M8)               r28.1<2>:ud   r2.0<1;1,0>:ud    r35.0<1;1,0>:ud  {Compacted,$12.src}
        mov (8|M0)               r22.1<2>:d    r34.0<1;1,0>:d                  
        mov (8|M8)               r24.1<2>:d    r35.0<1;1,0>:d                  
        addc (8|M0)              r2.0<1>:ud    r36.0<1;1,0>:ud   0x4:ud              {AccWrEn,Compacted}
        send.ugm (16|M0)         null     r22     r10:2   0x0            0x080E0584           {A@2,$13} // wr:4+2, rd:0; store.ugm.d32.a64.wb.wb
        add (8|M0)               r26.1<2>:ud   r18.0<1;1,0>:ud   r34.0<1;1,0>:ud  {Compacted}
        mov (8|M8)               r28.0<2>:d    r13.0<1;1,0>:d                  
        mov (8|M0)               r22.0<2>:d    r36.0<1;1,0>:d                   {$13.src}
        mov (8|M8)               r24.0<2>:d    r37.0<1;1,0>:d                  
        mov (8|M0)               r26.0<2>:d    r12.0<1;1,0>:d                  
        mov (8|M0)               r18.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mov (8|M0)               r22.1<2>:d    r38.0<1;1,0>:d                  
        mov (8|M8)               r24.1<2>:d    r39.0<1;1,0>:d                  
        addc (8|M8)              r3.0<1>:ud    r37.0<1;1,0>:ud   0x4:ud              {AccWrEn}
        send.ugm (16|M0)         null     r26     r10:2   0x0            0x080E0584           {A@5,$14} // wr:4+2, rd:0; store.ugm.d32.a64.wb.wb
        send.ugm (16|M0)         null     r22     r10:2   0x0            0x080E0584           {A@2,$15} // wr:4+2, rd:0; store.ugm.d32.a64.wb.wb
        mov (8|M8)               r12.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        addc (8|M0)              r22.0<1>:ud   r20.0<1;1,0>:ud   0x4:ud              {AccWrEn,Compacted,$15.src}
        add (8|M0)               r26.1<2>:ud   r18.0<1;1,0>:ud   r38.0<1;1,0>:ud  {Compacted,$14.src}
        mov (8|M0)               r18.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        addc (8|M8)              r23.0<1>:ud   r21.0<1;1,0>:ud   0x4:ud              {AccWrEn}
        add (8|M8)               r28.1<2>:ud   r12.0<1;1,0>:ud   r39.0<1;1,0>:ud  {Compacted,I@5}
        mov (8|M8)               r12.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mov (8|M8)               r15.0<2>:d    r21.0<1;1,0>:d                  
        mov (8|M0)               r13.0<2>:d    r20.0<1;1,0>:d                  
        mov (8|M0)               r26.0<2>:d    r2.0<1;1,0>:d                   
        add (8|M0)               r32.1<2>:ud   r18.0<1;1,0>:ud   r30.0<1;1,0>:ud  {Compacted,I@7}
        mov (8|M8)               r28.0<2>:d    r3.0<1;1,0>:d                   
        mov (8|M8)               r15.1<2>:d    r31.0<1;1,0>:d                  
        add (8|M8)               r34.1<2>:ud   r12.0<1;1,0>:ud   r31.0<1;1,0>:ud  {Compacted,I@7}
        mov (8|M0)               r13.1<2>:d    r30.0<1;1,0>:d                  
        mov (8|M0)               r32.0<2>:d    r22.0<1;1,0>:d                  
        mov (8|M8)               r34.0<2>:d    r23.0<1;1,0>:d                  
        send.ugm (16|M0)         null     r26     r10:2   0x0            0x080E0584           {A@6,$4} // wr:4+2, rd:0; store.ugm.d32.a64.wb.wb
        send.ugm (16|M0)         null     r13     r10:2   0x0            0x080E0584           {A@3,$3} // wr:4+2, rd:0; store.ugm.d32.a64.wb.wb
        send.ugm (16|M0)         null     r32     r10:2   0x0            0x080E0584           {A@1,$9} // wr:4+2, rd:0; store.ugm.d32.a64.wb.wb
        goto (16|M0)                         L3320                  L29800                
L3320:
        join (16|M0)                         L29800                                
L3336:
        mul (8|M0)               acc0.0<1>:ud  r100.0<1;1,0>:ud  r5.8<0;1,0>:uw  
        mach (8|M0)              r2.0<1>:ud    r100.0<1;1,0>:ud  r5.4<0;1,0>:ud   {AccWrEn,Compacted}
        shl (16|M0)              r28.0<1>:d    r40.0<1;1,0>:d    6:w               {Compacted,$4.src}
        mov (8|M0)               r10.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted,$9.src}
        mul (8|M8)               acc0.0<1>:ud  r101.0<1;1,0>:ud  r5.8<0;1,0>:uw  
        mach (8|M8)              r3.0<1>:ud    r101.0<1;1,0>:ud  r5.4<0;1,0>:ud   {AccWrEn}
        shr (16|M0)              r30.0<1>:ud   r40.0<1;1,0>:ud   26:w              
        mov (8|M8)               r11.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        sync.nop                             null                             {Compacted,$3.src}
        mov (16|M0)              r14.0<1>:f    r2.0<1;1,0>:f                    {Compacted,A@3}
        mov (16|M0)              r12.0<1>:f    r10.0<1;1,0>:f                   {Compacted,I@1}
        addc (8|M0)              r16.0<1>:ud   r12.0<1;1,0>:ud   r72.0<1;1,0>:ud  {AccWrEn,Compacted,F@1}
        shl (16|M0)              r10.0<1>:d    r6.0<1;1,0>:d     6:w               {Compacted}
        add (8|M0)               r18.0<1>:ud   acc0.0<1;1,0>:ud  r14.0<1;1,0>:ud 
        addc (8|M8)              r17.0<1>:ud   r13.0<1;1,0>:ud   r73.0<1;1,0>:ud  {AccWrEn}
        or (16|M0)               r2.0<1>:d     r10.0<1;1,0>:d    r30.0<1;1,0>:d   {Compacted,I@3}
        add (8|M8)               r19.0<1>:ud   acc0.0<1;1,0>:ud  r15.0<1;1,0>:ud 
        shl (16|M0)              r32.0<1>:d    r16.0<1;1,0>:d    7:w               {Compacted,I@3}
        shr (16|M0)              r34.0<1>:ud   r16.0<1;1,0>:ud   25:w              
        shl (16|M0)              r12.0<1>:d    r18.0<1;1,0>:d    7:w               {Compacted,I@3}
        addc (8|M0)              r48.0<1>:ud   r32.0<1;1,0>:ud   r8.5<0;1,0>:ud   {AccWrEn,Compacted,I@3}
        or (16|M0)               r12.0<1>:d    r12.0<1;1,0>:d    r34.0<1;1,0>:d   {Compacted,I@2}
        shl (16|M0)              r20.0<1>:d    r16.0<1;1,0>:d    6:w               {Compacted}
        shr (16|M0)              r22.0<1>:ud   r16.0<1;1,0>:ud   26:w              
        shl (16|M0)              r24.0<1>:d    r18.0<1;1,0>:d    6:w               {Compacted}
        add3 (8|M0)              r46.0<1>:ud   acc0.0<1;0>:ud    r12.0<1;0>:ud     r8.6<0>:ud       {I@4}
        addc (8|M8)              r49.0<1>:ud   r33.0<1;1,0>:ud   r8.5<0;1,0>:ud   {AccWrEn}
        or (16|M0)               r26.0<1>:d    r24.0<1;1,0>:d    r22.0<1;1,0>:d   {Compacted,I@3}
        add3 (8|M8)              r47.0<1>:ud   acc0.0<1;0>:ud    r13.0<1;0>:ud     r8.6<0>:ud      
        addc (8|M0)              r52.0<1>:ud   r20.0<1;1,0>:ud   r4.3<0;1,0>:ud   {AccWrEn,Compacted}
(W)     mov (1|M0)               r4.2<1>:f     -0.0:f                               {Compacted}
        add3 (8|M0)              r50.0<1>:ud   acc0.0<1;0>:ud    r26.0<1;0>:ud     r4.4<0>:ud       {I@3}
        addc (8|M8)              r53.0<1>:ud   r21.0<1;1,0>:ud   r4.3<0;1,0>:ud   {AccWrEn}
(W)     mov (1|M0)               r4.1<1>:f     inf:f                               {Compacted}
        add3 (8|M8)              r51.0<1>:ud   acc0.0<1;0>:ud    r27.0<1;0>:ud     r4.4<0>:ud      
        addc (8|M0)              r56.0<1>:ud   r28.0<1;1,0>:ud   r8.0<0;1,0>:ud   {AccWrEn,Compacted}
(W)     mov (1|M0)               r4.0<1>:d     -1:w                              
        add3 (8|M0)              r54.0<1>:ud   acc0.0<1;0>:ud    r2.0<1;0>:ud      r8.1<0>:ud      
        addc (8|M8)              r57.0<1>:ud   r29.0<1;1,0>:ud   r8.0<0;1,0>:ud   {AccWrEn}
(W)     mov (1|M0)               r8.7<1>:d     0:w                              
        add3 (8|M8)              r55.0<1>:ud   acc0.0<1;0>:ud    r3.0<1;0>:ud      r8.1<0>:ud      
L3824:
(f0.0)  goto (16|M0)                         L4048                  L4048                
L3840:
(W)     shl (1|M0)               r2.0<1>:d     r8.7<0;1,0>:d     1:w               {Compacted,I@3}
(W)     shr (1|M0)               r2.1<1>:ud    r8.7<0;1,0>:ud    31:w              
        addc (8|M0)              r10.0<1>:ud   r52.0<1;1,0>:ud   r2.0<0;1,0>:ud   {AccWrEn,Compacted,I@2}
        mov (8|M0)               r12.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        addc (8|M8)              r11.0<1>:ud   r53.0<1;1,0>:ud   r2.0<0;1,0>:ud   {AccWrEn}
        sync.nop                             null                             {Compacted,$5.src}
        add3 (8|M0)              r13.1<2>:ud   r12.0<1;0>:ud     r50.0<1;0>:ud     r2.1<0>:ud       {I@2}
        mov (8|M8)               r18.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mov (8|M0)               r13.0<2>:d    r10.0<1;1,0>:d                  
        add3 (8|M8)              r15.1<2>:ud   r18.0<1;0>:ud     r51.0<1;0>:ud     r2.1<0>:ud       {I@2}
        mov (8|M8)               r15.0<2>:d    r11.0<1;1,0>:d                  
        send.ugm (16|M0)         r20      r13     null:0  0x0            0x08280B80           {A@1,$0} // wr:4+0, rd:2; load.ugm.d16u32.a64.ca.ca
        mov (16|M0)              r3.0<1>:uw    r20.0<2;1,0>:uw                  {$0.dst}
        sync.nop                             null                             {Compacted,$8.dst}
        mov (16|M0)              r60.0<1>:f    r3.0<1;1,0>:hf                   {I@1}
        goto (16|M0)                         L4048                  L4216                
L4048:
        join (16|M0)                         L4216                                
L4064:
(W)     shl (1|M0)               r2.0<1>:d     r8.7<0;1,0>:d     2:w               {Compacted}
(W)     shr (1|M0)               r2.1<1>:ud    r8.7<0;1,0>:ud    30:w              
        addc (8|M0)              r10.0<1>:ud   r48.0<1;1,0>:ud   r2.0<0;1,0>:ud   {AccWrEn,Compacted,I@2}
        mov (8|M0)               r12.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        addc (8|M8)              r11.0<1>:ud   r49.0<1;1,0>:ud   r2.0<0;1,0>:ud   {AccWrEn}
        sync.nop                             null                             {Compacted,$5.src}
        add3 (8|M0)              r13.1<2>:ud   r12.0<1;0>:ud     r46.0<1;0>:ud     r2.1<0>:ud       {I@2}
        mov (8|M8)               r18.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mov (8|M0)               r13.0<2>:d    r10.0<1;1,0>:d                  
        add3 (8|M8)              r15.1<2>:ud   r18.0<1;0>:ud     r47.0<1;0>:ud     r2.1<0>:ud       {I@2}
        mov (8|M8)               r15.0<2>:d    r11.0<1;1,0>:d                  
        send.ugm (16|M0)         r60      r13     null:0  0x0            0x08280580           {A@1,$8} // wr:4+0, rd:2; load.ugm.d32.a64.ca.ca
L4216:
        join (16|M0)                         L29800                                
L4232:
        and (16|M0)              r2.0<1>:d     r60.0<1;1,0>:d    2147483647:d               {$8.dst}
        sel (16|M0)   (lt)f0.0   r92.0<1>:f    r2.0<1;1,0>:f     448.0:f               {Compacted,I@1}
        shr (16|M0)              r74.0<1>:ud   r92.0<1;1,0>:ud   23:w               {F@1}
        and (16|M0)   (ne)f1.0   r66.0<1>:d    r92.0<1;1,0>:d    8388607:d              
        and (16|M0)              r82.0<1>:d    r74.0<1;1,0>:d    255:w               {Compacted,I@2}
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r82.0<1;1,0>:d    255:w               {I@1}
        sel (16|M0)   (ge)f0.0   r10.0<1>:ud   r82.0<1;1,0>:ud   0x79:uw             
        shl (16|M0)              r64.0<1>:d    r10.0<1;1,0>:d    23:w               {Compacted,I@1}
(~f1.0) goto (16|M0)                         L4384                  L4384                
L4352:
        mov (16|M0)              r78.0<1>:ud   0x7FC00000:ud                             
        goto (16|M0)                         L4384                  L10368                
L4384:
        join (16|M0)                         L10368                                
L4400:
        cmp (16|M0)   (eq)f1.1   null<1>:d     r66.0<1;1,0>:d    0:w              
        add (16|M0)              r22.0<1>:d    -r64.0<1;1,0>:d   -2139095040:d               {I@6}
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r82.0<1;1,0>:d    255:w              
        xor (16|M0)              r96.0<1>:d    r22.0<1;1,0>:d    r92.0<1;1,0>:d   {Compacted,I@2}
(f1.1)  goto (16|M0)                         L10336                  L10336                
L4472:
        or (16|M0)    (eq)f1.1   null<1>:d     r82.0<1;1,0>:d    r66.0<1;1,0>:d  
(~f1.1) goto (16|M0)                         L4536                  L4536                
L4504:
        mov (16|M0)              r78.0<1>:ud   0x0:ud                             
        goto (16|M0)                         L4536                  L10368                
L4536:
        join (16|M0)                         L10336                                
L4552:
        cmp (16|M0)   (eq)f1.1   null<1>:d     r82.0<1;1,0>:d    0:w              
        shr (16|M0)              r94.0<1>:ud   r22.0<1;1,0>:ud   23:w              
        add (16|M0)              r92.0<1>:d    r82.0<1;1,0>:d    -127:w               {Compacted}
(f1.1)  mov (16|M0)              r92.0<1>:d    -126:w                              
        add (16|M0)              r90.0<1>:d    r94.0<1;1,0>:d    r92.0<1;1,0>:d   {Compacted,I@1}
        cmp (16|M0)   (gt)f1.0   null<1>:d     r90.0<1;1,0>:d    254:w               {I@1}
(f1.0)  goto (16|M0)                         L10272                  L10272                
L4648:
        or (16|M0)    (eq)f1.0   null<4>:b     r74.0<1;1,0>:d    r94.0<1;1,0>:d  
(f1.0)  goto (16|M0)                         L10216                  L10216                
L4680:
(W)     mov (1|M0)               r2.0<1>:hf    0.0:hf                             
(W)     mov (1|M0)               r99.3<1>:d    0:w                              
(f1.1)  sel (16|M0)              r10.0<1>:d    r2.0<0;1,0>:w     8388608:d               {F@1}
        or (16|M0)               r10.0<1>:d    r10.0<1;1,0>:d    r66.0<1;1,0>:d   {Compacted,I@1}
        shl (16|M0)              r88.0<1>:d    r10.0<1;1,0>:d    23:w               {Compacted,I@1}
        shr (16|M0)              r86.0<1>:ud   r10.0<1;1,0>:ud   9:w              
(W)     mov (1|M0)               r99.2<1>:f    -0.0:f                               {Compacted}
(W)     mov (2|M0)               r99.4<1>:d    0:w                              
L4784:
(W)     shl (1|M0)               r2.0<1>:d     r99.2<0;1,0>:d    31:w               {Compacted,F@1}
(W)     shr (1|M0)               r2.1<1>:ud    r99.3<0;1,0>:ud   1:w              
(W)     cmp (16|M0)   (gt)f1.1   null<1>:d     r99.4<0;1,0>:ud   0x3E:uw              {I@3}
(W)     or (1|M0)                r99.3<1>:d    r2.1<0;1,0>:d     r2.0<0;1,0>:d    {I@2}
        bfn.0xE0 (16|M0)         r10.0<1>:ud   r2.1<0;0>:ud      r2.0<0;0>:ud      r88.0<1>:ud      // (s0|s1)&s2
(W)     shr (1|M0)               r99.1<1>:ud   r99.2<0;1,0>:ud   1:w              
(W&f1.1) cmp (16|M0)  (eq)f1.1   null<1>:d     r99.5<0;1,0>:d    0:w              
        cmp (16|M0)   (eq)f1.0   null<1>:d     r10.0<1;1,0>:d    r99.3<0;1,0>:d   {I@3}
        sync.nop                             null                             {Compacted,$5.src}
        and (16|M0)              r12.0<1>:d    r99.1<0;1,0>:d    r86.0<1;1,0>:d   {Compacted,I@3}
(W&~f1.1) cmp (16|M0) (gt)f1.1   null<1>:d     r99.5<0;1,0>:ud   0x0:uw             
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r12.0<1;1,0>:d    r99.1<0;1,0>:d   {I@2}
(W)     mov (1|M0)               r5.10<1>:hf   0x1:hf                             
(W)     addc (1|M0)              r15.0<1>:ud   r99.4<0;1,0>:ud   0x1:ud              {AccWrEn}
(f1.1)  sel (16|M0)              r9.0<1>:uw    r5.10<0;1,0>:uw   0x0:uw              {Compacted,F@1}
(f1.0)  sel (16|M0)              acc2.0<1>:uw  r5.10<0;1,0>:uw   0x0:uw             
(W)     mov (1|M0)               r3.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        or (16|M0)    (ne)f1.0   null<1>:uw    r9.0<1;1,0>:uw    acc2.0<1;1,0>:uw {I@3}
(W)     add (1|M0)               r99.6<1>:ud   r3.0<0;1,0>:ud    r99.5<0;1,0>:ud  {I@2}
        mov (16|M0)              r110.0<1>:d   r99.4<0;1,0>:d                  
        mov (16|M0)              r108.0<1>:d   r99.5<0;1,0>:d                  
        mov (16|M0)              r84.0<1>:f    r15.0<0;1,0>:f                   {Compacted}
        mov (16|M0)              r82.0<1>:d    r99.6<0;1,0>:d                   {I@3}
(f1.0)  goto (16|M0)                         L5184                  L5184                
L5120:
(W)     mov (1|M0)               r99.2<1>:d    r99.1<0;1,0>:d                  
(W)     mov (1|M0)               r99.4<1>:d    r15.0<0;1,0>:d                  
(W)     mov (1|M0)               r99.5<1>:d    r99.6<0;1,0>:d                  
(W)     jmpi                                 L4784                                
L5184:
        join (16|M0)                         L10216                                
L5200:
(W)     mov (1|M0)               r2.0<1>:f     8.68805e-44:f                              
(W)     mov (1|M0)               r3.0<1>:hf    0.0:hf                             
        subb (8|M0)              r106.0<1>:ud  r2.0<0;1,0>:ud    r110.0<1;1,0>:ud {AccWrEn,Compacted,A@2}
        add3 (8|M0)              r16.0<1>:ud   -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r108.0<1>:ud    {A@1}
        subb (8|M8)              r107.0<1>:ud  r2.0<0;1,0>:ud    r111.0<1;1,0>:ud {AccWrEn}
        add3 (16|M0)             r24.0<1>:d    r90.0<1;0>:d      r106.0<1;0>:d     -173:w               {I@1}
        cmp (16|M0)   (gt)f1.1   null<1>:d     r24.0<1;1,0>:d    127:w               {I@1}
        add3 (8|M8)              r17.0<1>:ud   -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r109.0<1>:ud   
        add3 (16|M0)             r66.0<1>:d    r94.0<1;0>:d      r92.0<1;0>:d      r106.0<1>:d     
(f1.1)  goto (16|M0)                         L10152                  L10152                
L5352:
        cmp (16|M0)   (gt)f1.0   null<1>:d     r24.0<1;1,0>:d    -127:w              
(f1.0)  goto (16|M0)                         L7832                  L7832                
L5384:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r24.0<1;1,0>:ud   0xFFFFFF6B:ud             
(f1.1)  goto (16|M0)                         L7328                  L7328                
L5416:
(W)     mov (1|M0)               r2.0<1>:f     8.82818e-44:f                              
(W)     mov (1|M0)               r3.0<1>:hf    0.0:hf                              {I@7}
        subb (8|M0)              r116.0<1>:ud  r2.0<0;1,0>:ud    r110.0<1;1,0>:ud {AccWrEn,Compacted,F@2}
        add3 (16|M0)             r118.0<1>:d   r90.0<1;0>:d      r106.0<1;0>:d     -23:w              
        add3 (8|M0)              r10.0<1>:ud   -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r108.0<1>:ud    {F@1}
        subb (8|M8)              r117.0<1>:ud  r2.0<0;1,0>:ud    r111.0<1;1,0>:ud {AccWrEn}
        cmp (16|M0)   (gt)f1.0   null<1>:d     r116.0<1;1,0>:ud  r118.0<1;1,0>:ud {I@1}
        add3 (8|M8)              r11.0<1>:ud   -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r109.0<1>:ud   
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r10.0<1;1,0>:d    0:w               {I@1}
(~f1.0) cmp (16|M0)   (gt)f1.0   null<1>:d     r10.0<1;1,0>:ud   0x0:uw             
(f1.0)  goto (16|M0)                         L5640                  L5640                
L5584:
        add3 (16|M0)             r2.0<1>:d     r66.0<1;0>:d      -r116.0<1;0>:d    -23:w              
        mov (16|M0)              r18.0<1>:d    0:w                              
        shl (16|M0)              r20.0<1>:d    r88.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
        goto (16|M0)                         L5640                  L7264                
L5640:
        join (16|M0)                         L7264                                
L5656:
        add3 (16|M0)             r114.0<1>:d   r116.0<1;0>:d     -r66.0<1;0>:d     23:w              
        cmp (16|M0)   (lt)f1.0   null<1>:d     r114.0<1;1,0>:d   2:w               {Compacted,I@1}
(f1.0)  goto (16|M0)                         L5800                  L5800                
L5696:
        cmp (16|M0)   (eq)f1.1   null<1>:d     r114.0<1;1,0>:d   2:w              
(~f1.1) goto (16|M0)                         L5800                  L5848                
L5728:
        shr (16|M0)              r22.0<1>:ud   r88.0<1;1,0>:ud   1:w              
        mov (16|M0)              r70.0<1>:d    0:w                              
        mov (16|M0)              r14.0<1>:d    0:w                              
        mov (16|M0)              r116.0<1>:f   r22.0<1;1,0>:f                   {Compacted,I@3}
        goto (16|M0)                         L5800                  L6736                
L5800:
        join (16|M0)                         L5848                                
L5816:
        cmp (16|M0)   (eq)f1.0   null<1>:d     r114.0<1;1,0>:d   1:w              
(f1.0)  goto (16|M0)                         L5848                  L6680                
L5848:
        join (16|M0)                         L6680                                
L5864:
        add3 (16|M0)             r2.0<1>:d     r116.0<1;0>:d     -r118.0<1;0>:d    -1:w               {F@1}
        and (16|M0)   (ne)f1.1   r108.0<1>:d   r2.0<1;1,0>:d     63:w               {I@1}
(f1.1)  goto (16|M0)                         L5936                  L5936                
L5912:
        mov (16|M0)              r112.0<1>:f   r88.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L5936                  L6048                
L5936:
        join (16|M0)                         L6048                                
L5952:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r108.0<1;1,0>:ud  0x20:uw              {I@4}
(~f1.0) add (16|M0)              r2.0<1>:d     r108.0<1;1,0>:d   -32:w              
(~f1.0) shr (16|M0)              r22.0<1>:ud   r86.0<1;1,0>:ud   r2.0<1;1,0>:d    {I@1}
(f1.0)  add (16|M0)              r2.0<1>:d     -r108.0<1;1,0>:d  32:w               {Compacted}
(f1.0)  shr (16|M0)              r10.0<1>:ud   r88.0<1;1,0>:ud   r108.0<1;1,0>:d 
(f1.0)  shl (16|M0)              r2.0<1>:d     r86.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.0)  or (16|M0)               r22.0<1>:d    r10.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@1}
        mov (16|M0)              r112.0<1>:f   r22.0<1;1,0>:f                   {Compacted,I@1}
L6048:
        join (16|M0)                         L6680                                
L6064:
        add3 (16|M0)             r90.0<1>:d    r116.0<1;0>:d     -r118.0<1;0>:d    -2:w              
        and (16|M0)   (ne)f1.1   r106.0<1>:d   r90.0<1;1,0>:d    63:w               {I@1}
(f1.1)  goto (16|M0)                         L6136                  L6136                
L6112:
        mov (16|M0)              r22.0<1>:f    r88.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L6136                  L6240                
L6136:
        join (16|M0)                         L6240                                
L6152:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r106.0<1;1,0>:ud  0x20:uw              {I@4}
(~f1.0) add (16|M0)              r2.0<1>:d     r106.0<1;1,0>:d   -32:w              
(~f1.0) shr (16|M0)              r22.0<1>:ud   r86.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.0)  add (16|M0)              r2.0<1>:d     -r106.0<1;1,0>:d  32:w               {Compacted}
(f1.0)  shr (16|M0)              r10.0<1>:ud   r88.0<1;1,0>:ud   r106.0<1;1,0>:d 
(f1.0)  shl (16|M0)              r2.0<1>:d     r86.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.0)  or (16|M0)               r22.0<1>:d    r10.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@1}
L6240:
        join (16|M0)                         L6680                                
L6256:
        and (16|M0)   (ne)f1.1   r16.0<1>:d    r90.0<1;1,0>:d    63:w              
        and (16|M0)              r14.0<1>:d    r22.0<1;1,0>:d    1:w               {Compacted,I@3}
(f1.1)  goto (16|M0)                         L6344                  L6344                
L6296:
        mov (16|M0)              r26.0<1>:d    -1:w                              
        mov (16|M0)              r34.0<1>:d    -1:w                              
        goto (16|M0)                         L6344                  L6528                
L6344:
        join (16|M0)                         L6528                                
L6360:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r16.0<1;1,0>:ud   0x20:uw              {I@7}
(f1.0)  goto (16|M0)                         L6464                  L6464                
L6392:
        add (16|M0)              r2.0<1>:d     r16.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r5.10<1>:hf   -qnan(0x1FF):hf                             
        mov (16|M0)              r26.0<1>:d    0:w                              
        shl (16|M0)              r34.0<1>:d    r5.10<0;1,0>:w    r2.0<1;1,0>:d    {A@1}
        goto (16|M0)                         L6464                  L6528                
L6464:
        join (16|M0)                         L6528                                
L6480:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (16|M0)              r34.0<1>:d    -1:w                              
        shl (16|M0)              r26.0<1>:d    r2.0<0;1,0>:w     r16.0<1;1,0>:d   {F@1}
L6528:
        join (16|M0)                         L6680                                
L6544:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r26.0<1;0>:ud     r4.0<0;0>:ud      r88.0<1>:ud      {I@2} // (s0^s1)&s2
        cmp (16|M0)   (ne)f1.0   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
        bfn.0x60 (16|M0)         r10.0<1>:ud   r34.0<1;0>:ud     r4.0<0;0>:ud      r86.0<1>:ud      // (s0^s1)&s2
(~f1.0) cmp (16|M0)   (ne)f1.0   null<1>:d     r10.0<1;1,0>:d    0:w               {I@1}
(W)     mov (1|M0)               r5.10<1>:hf   -qnan(0x1FF):hf                             
        mov (16|M0)              r116.0<1>:f   r112.0<1;1,0>:f                  {Compacted}
(f1.0)  sel (16|M0)              r12.0<1>:d    r5.10<0;1,0>:w    0:w               {F@2}
        mov (16|M0)              r70.0<1>:d    -r12.0<1;1,0>:d                  {I@1}
        goto (16|M0)                         L6680                  L6736                
L6680:
        join (16|M0)                         L6736                                
L6696:
        mov (16|M0)              r70.0<1>:d    0:w                              
        mov (16|M0)              r14.0<1>:d    0:w                              
        mov (16|M0)              r116.0<1>:f   r88.0<1;1,0>:f                   {Compacted}
L6736:
        join (16|M0)                         L7264                                
L6752:
        and (16|M0)   (ne)f1.1   r104.0<1>:d   r114.0<1;1,0>:d   63:w              
(f1.1)  goto (16|M0)                         L6808                  L6808                
L6784:
        mov (16|M0)              r22.0<1>:f    r88.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L6808                  L6912                
L6808:
        join (16|M0)                         L6912                                
L6824:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r104.0<1;1,0>:ud  0x20:uw              {I@4}
(~f1.0) add (16|M0)              r2.0<1>:d     r104.0<1;1,0>:d   -32:w              
(~f1.0) shr (16|M0)              r22.0<1>:ud   r86.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.0)  add (16|M0)              r2.0<1>:d     -r104.0<1;1,0>:d  32:w               {Compacted}
(f1.0)  shr (16|M0)              r10.0<1>:ud   r88.0<1;1,0>:ud   r104.0<1;1,0>:d 
(f1.0)  shl (16|M0)              r2.0<1>:d     r86.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.0)  or (16|M0)               r22.0<1>:d    r10.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@1}
L6912:
        join (16|M0)                         L7264                                
L6928:
        shl (16|M0)              r2.0<1>:d     r116.0<1;1,0>:d   2:w               {Compacted}
        shl (16|M0)              r10.0<1>:d    r14.0<1;1,0>:d    1:w               {Compacted}
        and (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     4:w               {Compacted,I@2}
        bfn.0xFE (16|M0)         r32.0<1>:ud   r2.0<1;0>:ud      r10.0<1;0>:ud     r70.0<1>:ud      {I@1} // s0|s1|s2
        cmp (16|M0)   (eq)f1.1   null<1>:d     r32.0<1;1,0>:d    0:w               {I@1}
(~f1.1) goto (16|M0)                         L7032                  L7032                
L7000:
        mov (16|M0)              r62.0<1>:d    0:w                              
        goto (16|M0)                         L7032                  L7192                
L7032:
        join (16|M0)                         L7192                                
L7048:
        cmp (16|M0)   (gt)f1.0   null<1>:d     r32.0<1;1,0>:ud   0x4:uw             
(~f1.0) goto (16|M0)                         L7112                  L7112                
L7080:
        mov (16|M0)              r62.0<1>:d    1:w                              
        goto (16|M0)                         L7112                  L7192                
L7112:
        join (16|M0)                         L7192                                
L7128:
        and (16|M0)   (ne)f1.1   null<1>:d     r22.0<1;1,0>:d    1:w              
(W)     mov (1|M0)               r2.0<1>:hf    0x1:hf                             
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r32.0<1;1,0>:d    4:w              
(f1.1)  sel (16|M0)              r62.0<1>:d    r2.0<0;1,0>:w     0:w               {F@1}
L7192:
        join (16|M0)                         L7264                                
L7208:
        add (16|M0)              r2.0<1>:d     r62.0<1;1,0>:d    r22.0<1;1,0>:d   {Compacted,I@2}
        cmp (16|M0)   (gt)f1.0   null<1>:d     r2.0<1;1,0>:ud    0x7FFFFF:ud              {I@1}
(W)     mov (1|M0)               r5.5<1>:f     0x800000:f                               {Compacted}
(~f1.0) sel (16|M0)              r20.0<1>:d    r2.0<1;1,0>:d     0:w              
(f1.0)  sel (16|M0)              r18.0<1>:d    r5.5<0;1,0>:d     0:w               {Compacted,F@1}
L7264:
        join (16|M0)                         L7328                                
L7280:
        and (16|M0)              r2.0<1>:d     r96.0<1;1,0>:d    -2147483648:d              
        bfn.0xFE (16|M0)         r78.0<1>:ud   r2.0<1;0>:ud      r18.0<1;0>:ud     r20.0<1>:ud      {I@1} // s0|s1|s2
        goto (16|M0)                         L7328                  L10368                
L7328:
        join (16|M0)                         L7832                                
L7344:
        and (16|M0)   (ne)f1.1   r90.0<1>:d    r106.0<1;1,0>:d   63:w              
(f1.1)  goto (16|M0)                         L7424                  L7424                
L7376:
        mov (16|M0)              r116.0<1>:d   -1:w                              
        mov (16|M0)              r14.0<1>:d    -1:w                              
        goto (16|M0)                         L7424                  L7608                
L7424:
        join (16|M0)                         L7608                                
L7440:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r90.0<1;1,0>:ud   0x20:uw              {I@6}
(f1.0)  goto (16|M0)                         L7544                  L7544                
L7472:
        add (16|M0)              r2.0<1>:d     r90.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r5.10<1>:hf   -qnan(0x1FF):hf                             
        mov (16|M0)              r116.0<1>:d   0:w                              
        shl (16|M0)              r14.0<1>:d    r5.10<0;1,0>:w    r2.0<1;1,0>:d    {A@1}
        goto (16|M0)                         L7544                  L7608                
L7544:
        join (16|M0)                         L7608                                
L7560:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (16|M0)              r14.0<1>:d    -1:w                              
        shl (16|M0)              r116.0<1>:d   r2.0<0;1,0>:w     r90.0<1;1,0>:d   {F@1}
L7608:
        join (16|M0)                         L7832                                
L7624:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r116.0<1;0>:ud    r4.0<0;0>:ud      r88.0<1>:ud      {I@2} // (s0^s1)&s2
        cmp (16|M0)   (ne)f1.0   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
        bfn.0x60 (16|M0)         r10.0<1>:ud   r14.0<1;0>:ud     r4.0<0;0>:ud      r86.0<1>:ud      // (s0^s1)&s2
        cmp (16|M0)   (gt)f1.1   null<1>:d     r96.0<1;1,0>:d    -1:w              
(~f1.0) cmp (16|M0)   (ne)f1.0   null<1>:d     r10.0<1;1,0>:d    0:w               {I@2}
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r24.0<1;1,0>:d    -150:w              
(f1.1)  goto (16|M0)                         L7776                  L7776                
L7736:
(W)     mov (1|M0)               r2.0<1>:ud    0x80000001:ud                             
(f1.0)  sel (16|M0)              r78.0<1>:f    r2.0<0;1,0>:f     -0.0:f               {Compacted,I@1}
        goto (16|M0)                         L7776                  L10368                
L7776:
        join (16|M0)                         L7832                                
L7792:
(W)     mov (1|M0)               r2.0<1>:ud    0x1:ud                              {F@1}
(f1.0)  sel (16|M0)              r78.0<1>:f    r2.0<0;1,0>:f     0.0:f               {Compacted,I@1}
        goto (16|M0)                         L7832                  L10368                
L7832:
        join (16|M0)                         L10152                                
L7848:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r106.0<1;1,0>:ud  0x18:uw              {F@1}
        add3 (16|M0)             r92.0<1>:d    r90.0<1;0>:d      r106.0<1;0>:d     -46:w              
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r16.0<1;1,0>:d    0:w              
(f1.0)  goto (16|M0)                         L9840                  L9840                
L7912:
        shl (16|M0)              r2.0<1>:d     r84.0<1;1,0>:d    1:w               {Compacted}
        shr (16|M0)              r10.0<1>:ud   r84.0<1;1,0>:ud   31:w              
        shl (16|M0)              r12.0<1>:d    r82.0<1;1,0>:d    1:w               {Compacted}
        cmp (16|M0)   (lt)f1.1   null<1>:d     r2.0<1;1,0>:ud    0x4E:uw              {I@3}
        or (16|M0)               r12.0<1>:d    r12.0<1;1,0>:d    r10.0<1;1,0>:d   {Compacted,I@2}
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r12.0<1;1,0>:d    0:w               {I@1}
(~f1.1) cmp (16|M0)   (lt)f1.1   null<1>:d     r12.0<1;1,0>:d    0:w              
(f1.1)  goto (16|M0)                         L8144                  L8144                
L8016:
        cmp (16|M0)   (eq)f1.1   null<1>:d     r84.0<1;1,0>:d    39:w              
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r82.0<1;1,0>:d    0:w              
(~f1.1) goto (16|M0)                         L8144                  L8208                
L8064:
        shr (16|M0)              r22.0<1>:ud   r88.0<1;1,0>:ud   1:w              
        mov (16|M0)              r62.0<1>:d    0:w                              
        mov (16|M0)              r14.0<1>:d    0:w                              
        mov (16|M0)              r110.0<1>:f   r22.0<1;1,0>:f                   {Compacted,I@3}
        mov (16|M0)              r22.0<1>:f    r88.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L8144                  L9312                
L8144:
        join (16|M0)                         L8208                                
L8160:
        cmp (16|M0)   (eq)f1.0   null<1>:d     r84.0<1;1,0>:d    38:w              
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r82.0<1;1,0>:d    0:w              
(f1.0)  goto (16|M0)                         L8208                  L9224                
L8208:
        join (16|M0)                         L9224                                
L8224:
        add (16|M0)              r2.0<1>:d     -r84.0<1;1,0>:d   39:w               {Compacted}
        and (16|M0)   (ne)f1.0   r10.0<1>:d    r2.0<1;1,0>:d     63:w               {I@1}
        add (16|M0)              r110.0<1>:d   -r84.0<1;1,0>:d   40:w               {Compacted,F@2}
(f1.0)  goto (16|M0)                         L8296                  L8296                
L8272:
        mov (16|M0)              r108.0<1>:f   r88.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L8296                  L8408                
L8296:
        join (16|M0)                         L8408                                
L8312:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r10.0<1;1,0>:ud   0x20:uw              {I@5}
(~f1.1) add (16|M0)              r2.0<1>:d     r10.0<1;1,0>:d    -32:w              
(~f1.1) shr (16|M0)              r22.0<1>:ud   r86.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.1)  add (16|M0)              r2.0<1>:d     -r10.0<1;1,0>:d   32:w               {Compacted}
(f1.1)  shl (16|M0)              r2.0<1>:d     r86.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@1}
(f1.1)  shr (16|M0)              r10.0<1>:ud   r88.0<1;1,0>:ud   r10.0<1;1,0>:d  
(f1.1)  or (16|M0)               r22.0<1>:d    r10.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@1}
        mov (16|M0)              r108.0<1>:f   r22.0<1;1,0>:f                   {Compacted,I@1}
L8408:
        join (16|M0)                         L9224                                
L8424:
        add (16|M0)              r104.0<1>:d   -r84.0<1;1,0>:d   38:w               {Compacted}
        and (16|M0)   (ne)f1.0   r20.0<1>:d    r104.0<1;1,0>:d   63:w               {I@1}
(f1.0)  goto (16|M0)                         L8488                  L8488                
L8464:
        mov (16|M0)              r22.0<1>:f    r88.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L8488                  L8592                
L8488:
        join (16|M0)                         L8592                                
L8504:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r20.0<1;1,0>:ud   0x20:uw              {I@4}
(~f1.1) add (16|M0)              r2.0<1>:d     r20.0<1;1,0>:d    -32:w              
(~f1.1) shr (16|M0)              r22.0<1>:ud   r86.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.1)  add (16|M0)              r2.0<1>:d     -r20.0<1;1,0>:d   32:w               {Compacted}
(f1.1)  shr (16|M0)              r10.0<1>:ud   r88.0<1;1,0>:ud   r20.0<1;1,0>:d  
(f1.1)  shl (16|M0)              r2.0<1>:d     r86.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.1)  or (16|M0)               r22.0<1>:d    r10.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@1}
L8592:
        join (16|M0)                         L9224                                
L8608:
        and (16|M0)   (ne)f1.0   r62.0<1>:d    r104.0<1;1,0>:d   63:w              
        and (16|M0)              r14.0<1>:d    r22.0<1;1,0>:d    1:w               {Compacted,I@3}
(f1.0)  goto (16|M0)                         L8696                  L8696                
L8648:
        mov (16|M0)              r100.0<1>:d   -1:w                              
        mov (16|M0)              r112.0<1>:d   -1:w                              
        goto (16|M0)                         L8696                  L8880                
L8696:
        join (16|M0)                         L8880                                
L8712:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r62.0<1;1,0>:ud   0x20:uw              {I@7}
(f1.1)  goto (16|M0)                         L8816                  L8816                
L8744:
        add (16|M0)              r2.0<1>:d     r62.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r5.10<1>:hf   -qnan(0x1FF):hf                             
        mov (16|M0)              r100.0<1>:d   0:w                              
        shl (16|M0)              r112.0<1>:d   r5.10<0;1,0>:w    r2.0<1;1,0>:d    {A@1}
        goto (16|M0)                         L8816                  L8880                
L8816:
        join (16|M0)                         L8880                                
L8832:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (16|M0)              r112.0<1>:d   -1:w                              
        shl (16|M0)              r100.0<1>:d   r2.0<0;1,0>:w     r62.0<1;1,0>:d   {F@1}
L8880:
        join (16|M0)                         L9224                                
L8896:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r100.0<1;0>:ud    r4.0<0;0>:ud      r88.0<1>:ud      {I@2} // (s0^s1)&s2
        cmp (16|M0)   (ne)f1.1   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
        bfn.0x60 (16|M0)         r10.0<1>:ud   r112.0<1;0>:ud    r4.0<0;0>:ud      r86.0<1>:ud      // (s0^s1)&s2
(~f1.1) cmp (16|M0)   (ne)f1.1   null<1>:d     r10.0<1;1,0>:d    0:w               {I@1}
(W)     mov (1|M0)               r5.10<1>:hf   -qnan(0x1FF):hf                             
        and (16|M0)   (ne)f1.0   r18.0<1>:d    r110.0<1;1,0>:d   63:w              
(f1.1)  sel (16|M0)              r12.0<1>:d    r5.10<0;1,0>:w    0:w               {F@1}
        mov (16|M0)              r62.0<1>:d    -r12.0<1;1,0>:d                  {I@1}
(f1.0)  goto (16|M0)                         L9064                  L9064                
L9040:
        mov (16|M0)              r22.0<1>:f    r88.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L9064                  L9168                
L9064:
        join (16|M0)                         L9168                                
L9080:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r18.0<1;1,0>:ud   0x20:uw             
(~f1.1) add (16|M0)              r2.0<1>:d     r18.0<1;1,0>:d    -32:w              
(~f1.1) shr (16|M0)              r22.0<1>:ud   r86.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.1)  add (16|M0)              r2.0<1>:d     -r18.0<1;1,0>:d   32:w               {Compacted}
(f1.1)  shr (16|M0)              r10.0<1>:ud   r88.0<1;1,0>:ud   r18.0<1;1,0>:d  
(f1.1)  shl (16|M0)              r2.0<1>:d     r86.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.1)  or (16|M0)               r22.0<1>:d    r10.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@1}
L9168:
        join (16|M0)                         L9224                                
L9184:
        mov (16|M0)              r110.0<1>:f   r22.0<1;1,0>:f                   {Compacted,I@2}
        mov (16|M0)              r22.0<1>:d    r108.0<1;1,0>:d                  {F@1}
        goto (16|M0)                         L9224                  L9312                
L9224:
        join (16|M0)                         L9312                                
L9240:
        shr (16|M0)              r22.0<1>:ud   r88.0<1;1,0>:ud   2:w              
        mov (16|M0)              r62.0<1>:d    0:w                              
        mov (16|M0)              r14.0<1>:d    0:w                              
        mov (16|M0)              r110.0<1>:f   r22.0<1;1,0>:f                   {Compacted,I@3}
        shr (16|M0)              r22.0<1>:ud   r88.0<1;1,0>:ud   1:w               {F@1}
L9312:
        join (16|M0)                         L9840                                
L9328:
        shl (16|M0)              r2.0<1>:d     r22.0<1;1,0>:d    2:w               {Compacted,I@2}
        shl (16|M0)              r10.0<1>:d    r14.0<1;1,0>:d    1:w               {Compacted}
        and (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     4:w               {Compacted,I@2}
        bfn.0xFE (16|M0)         r114.0<1>:ud  r2.0<1;0>:ud      r10.0<1;0>:ud     r62.0<1>:ud      {I@1} // s0|s1|s2
        cmp (16|M0)   (eq)f1.0   null<1>:d     r114.0<1;1,0>:d   0:w               {I@1}
        and (16|M0)              r58.0<1>:d    r110.0<1;1,0>:d   8388607:d               {$7.dst}
(~f1.0) goto (16|M0)                         L9448                  L9448                
L9416:
        mov (16|M0)              r86.0<1>:d    0:w                              
        goto (16|M0)                         L9448                  L9608                
L9448:
        join (16|M0)                         L9608                                
L9464:
        cmp (16|M0)   (gt)f1.1   null<1>:d     r114.0<1;1,0>:ud  0x4:uw             
(~f1.1) goto (16|M0)                         L9528                  L9528                
L9496:
        mov (16|M0)              r86.0<1>:d    1:w                              
        goto (16|M0)                         L9528                  L9608                
L9528:
        join (16|M0)                         L9608                                
L9544:
        and (16|M0)   (ne)f1.0   null<1>:d     r110.0<1;1,0>:d   1:w              
(W)     mov (1|M0)               r2.0<1>:hf    0x1:hf                             
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r114.0<1;1,0>:d   4:w              
(f1.0)  sel (16|M0)              r86.0<1>:d    r2.0<0;1,0>:w     0:w               {F@1}
L9608:
        join (16|M0)                         L9840                                
L9624:
        add (16|M0)              r62.0<1>:d    r58.0<1;1,0>:d    r86.0<1;1,0>:d   {Compacted,I@2}
        cmp (16|M0)   (gt)f1.1   null<1>:d     r62.0<1;1,0>:ud   0x7FFFFF:ud              {I@1}
        add3 (16|M0)             r2.0<1>:d     r90.0<1;0>:d      r106.0<1;0>:d     -45:w              
(f1.1)  sel (16|M0)              r36.0<1>:d    r2.0<1;1,0>:d     r92.0<1;1,0>:d   {Compacted,I@1}
        cmp (16|M0)   (eq)f1.0   null<1>:d     r36.0<1;1,0>:d    255:w               {I@1}
(f1.0)  goto (16|M0)                         L9776                  L9776                
L9704:
(~f1.1) sel (16|M0)              r2.0<1>:d     r62.0<1;1,0>:d    0:w              
        and (16|M0)              r10.0<1>:d    r96.0<1;1,0>:d    -2147483648:d              
        shl (16|M0)              r12.0<1>:d    r36.0<1;1,0>:d    23:w               {Compacted}
        bfn.0xFE (16|M0)         r78.0<1>:ud   r10.0<1;0>:ud     r12.0<1;0>:ud     r2.0<1>:ud       {I@1} // s0|s1|s2
        goto (16|M0)                         L9776                  L10368                
L9776:
        join (16|M0)                         L9840                                
L9792:
        cmp (16|M0)   (gt)f1.0   null<1>:d     r96.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r2.0<1>:f     inf:f                               {Compacted,I@4}
(f1.0)  sel (16|M0)              r78.0<1>:f    r2.0<0;1,0>:f     -inf:f               {Compacted,F@1}
        goto (16|M0)                         L9840                  L10368                
L9840:
        join (16|M0)                         L10152                                
L9856:
        and (16|M0)   (ne)f1.1   r16.0<1>:d    r106.0<1;1,0>:d   63:w              
(f1.1)  goto (16|M0)                         L9920                  L9920                
L9888:
        mov (16|M0)              r72.0<1>:d    -1:w                              
        goto (16|M0)                         L9920                  L10048                
L9920:
        join (16|M0)                         L10048                                
L9936:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r16.0<1;1,0>:ud   0x20:uw              {A@1}
(f1.0)  goto (16|M0)                         L10000                  L10000                
L9968:
        mov (16|M0)              r72.0<1>:d    0:w                              
        goto (16|M0)                         L10000                  L10048                
L10000:
        join (16|M0)                         L10048                                
L10016:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                             
        shl (16|M0)              r72.0<1>:d    r2.0<0;1,0>:w     r16.0<1;1,0>:d   {F@1}
L10048:
        join (16|M0)                         L10152                                
L10064:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r72.0<1;0>:ud     r4.0<0;0>:ud      r88.0<1>:ud      {I@2} // (s0^s1)&s2
        add (16|M0)              r10.0<1>:d    -r106.0<1;1,0>:d  23:w               {Compacted}
        and (16|M0)              r12.0<1>:d    r96.0<1;1,0>:d    -2147483648:d              
        shl (16|M0)              r14.0<1>:d    r92.0<1;1,0>:d    23:w               {Compacted}
        shl (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     r10.0<1;1,0>:d   {Compacted,I@3}
        bfn.0xFE (16|M0)         r78.0<1>:ud   r12.0<1;0>:ud     r14.0<1;0>:ud     r2.0<1>:ud       {I@1} // s0|s1|s2
        goto (16|M0)                         L10152                  L10368                
L10152:
        join (16|M0)                         L10216                                
L10168:
        cmp (16|M0)   (gt)f1.1   null<1>:d     r96.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r2.0<1>:f     inf:f                               {Compacted,I@4}
(f1.1)  sel (16|M0)              r78.0<1>:f    r2.0<0;1,0>:f     -inf:f               {Compacted,F@1}
        goto (16|M0)                         L10216                  L10368                
L10216:
        join (16|M0)                         L10272                                
L10232:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r96.0<1;1,0>:d    0:w               {Compacted}
(W)     mov (1|M0)               r2.0<1>:f     -0.0:f                               {Compacted}
(f1.0)  sel (16|M0)              r78.0<1>:f    r2.0<0;1,0>:f     0.0:f               {Compacted,F@1}
        goto (16|M0)                         L10272                  L10368                
L10272:
        join (16|M0)                         L10336                                
L10288:
        cmp (16|M0)   (gt)f1.1   null<1>:d     r96.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r2.0<1>:f     inf:f                               {Compacted}
(f1.1)  sel (16|M0)              r78.0<1>:f    r2.0<0;1,0>:f     -inf:f               {Compacted,F@1}
        goto (16|M0)                         L10336                  L10368                
L10336:
        join (16|M0)                         L10368                                
L10352:
        bfn.0xF8 (16|M0)         r78.0<1>:ud   r96.0<1;0>:ud     r4.2<0;0>:ud      r4.1<0>:ud       {F@1} // s0&s1|s2
L10368:
        join (16|M0)                         L29800                                
L10384:
        rnde (16|M0)             r112.0<1>:f   r78.0<1;1,0>:f                   {Compacted,I@2}
        shr (16|M0)              r72.0<1>:ud   r112.0<1;1,0>:ud  23:w               {F@1}
        and (16|M0)   (ne)f1.1   r94.0<1>:d    r112.0<1;1,0>:d   8388607:d              
        and (16|M0)              r86.0<1>:d    r72.0<1;1,0>:d    255:w               {Compacted,I@2}
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r86.0<1;1,0>:d    255:w               {I@1}
(~f1.1) goto (16|M0)                         L10496                  L10496                
L10464:
        mov (16|M0)              r74.0<1>:ud   0x7FC00000:ud                             
        goto (16|M0)                         L10496                  L16528                
L10496:
        join (16|M0)                         L16528                                
L10512:
        cmp (16|M0)   (eq)f1.0   null<1>:d     r94.0<1;1,0>:d    0:w              
        add (16|M0)              r2.0<1>:d     r64.0<1;1,0>:d    -25165824:d              
        shr (16|M0)              r68.0<1>:ud   r2.0<1;1,0>:ud    23:w               {I@1}
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r86.0<1;1,0>:d    255:w              
        and (16|M0)              r30.0<1>:d    r68.0<1;1,0>:d    255:w               {Compacted,I@2}
(~f1.0) cmp (16|M0)   (eq)f1.0   null<1>:d     r30.0<1;1,0>:d    255:w               {I@1}
        xor (16|M0)              r28.0<1>:d    r2.0<1;1,0>:d     r112.0<1;1,0>:d  {Compacted}
(f1.0)  goto (16|M0)                         L16496                  L16496                
L10624:
        cmp (16|M0)   (eq)f1.0   null<1>:d     r30.0<1;1,0>:d    0:w              
        or (16|M0)               r2.0<1>:d     r86.0<1;1,0>:d    r94.0<1;1,0>:d   {Compacted}
(~f1.0) cmp (16|M0)   (eq)f1.0   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
(~f1.0) goto (16|M0)                         L10712                  L10712                
L10680:
        mov (16|M0)              r74.0<1>:ud   0x0:ud                             
        goto (16|M0)                         L10712                  L16528                
L10712:
        join (16|M0)                         L16496                                
L10728:
        cmp (16|M0)   (eq)f1.0   null<1>:d     r86.0<1;1,0>:d    0:w              
        add (16|M0)              r26.0<1>:d    r86.0<1;1,0>:d    -127:w               {Compacted}
(f1.0)  mov (16|M0)              r26.0<1>:d    -126:w                              
        add (16|M0)              r24.0<1>:d    r30.0<1;1,0>:d    r26.0<1;1,0>:d   {Compacted,I@1}
        cmp (16|M0)   (gt)f1.1   null<1>:d     r24.0<1;1,0>:d    254:w               {I@1}
(f1.1)  goto (16|M0)                         L16432                  L16432                
L10808:
        or (16|M0)    (eq)f1.1   null<4>:b     r72.0<1;1,0>:d    r68.0<1;1,0>:d  
(f1.1)  goto (16|M0)                         L16376                  L16376                
L10840:
(W)     mov (1|M0)               r2.0<1>:hf    0.0:hf                             
(W)     mov (1|M0)               r99.3<1>:d    0:w                              
(f1.0)  sel (16|M0)              r10.0<1>:d    r2.0<0;1,0>:w     8388608:d               {F@1}
        or (16|M0)               r10.0<1>:d    r10.0<1;1,0>:d    r94.0<1;1,0>:d   {Compacted,I@1}
        shl (16|M0)              r22.0<1>:d    r10.0<1;1,0>:d    23:w               {Compacted,I@1}
        shr (16|M0)              r20.0<1>:ud   r10.0<1;1,0>:ud   9:w               {$5.src}
(W)     mov (1|M0)               r99.2<1>:f    -0.0:f                               {Compacted}
(W)     mov (2|M0)               r99.4<1>:d    0:w                              
L10944:
(W)     shl (1|M0)               r2.0<1>:d     r99.2<0;1,0>:d    31:w               {Compacted,F@1}
(W)     shr (1|M0)               r2.1<1>:ud    r99.3<0;1,0>:ud   1:w              
(W)     cmp (16|M0)   (gt)f1.0   null<1>:d     r99.4<0;1,0>:ud   0x3E:uw              {I@3}
(W)     or (1|M0)                r99.3<1>:d    r2.1<0;1,0>:d     r2.0<0;1,0>:d    {I@2}
        bfn.0xE0 (16|M0)         r10.0<1>:ud   r2.1<0;0>:ud      r2.0<0;0>:ud      r22.0<1>:ud      // (s0|s1)&s2
(W)     shr (1|M0)               r99.1<1>:ud   r99.2<0;1,0>:ud   1:w              
(W&f1.0) cmp (16|M0)  (eq)f1.0   null<1>:d     r99.5<0;1,0>:d    0:w              
        cmp (16|M0)   (eq)f1.1   null<1>:d     r10.0<1;1,0>:d    r99.3<0;1,0>:d   {I@3}
        and (16|M0)              r12.0<1>:d    r99.1<0;1,0>:d    r20.0<1;1,0>:d   {Compacted,I@3}
(W&~f1.0) cmp (16|M0) (gt)f1.0   null<1>:d     r99.5<0;1,0>:ud   0x0:uw             
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r12.0<1;1,0>:d    r99.1<0;1,0>:d   {I@2}
(W)     mov (1|M0)               r5.10<1>:hf   0x1:hf                             
(W)     addc (1|M0)              r15.0<1>:ud   r99.4<0;1,0>:ud   0x1:ud              {AccWrEn}
(f1.0)  sel (16|M0)              r9.0<1>:uw    r5.10<0;1,0>:uw   0x0:uw              {Compacted,F@1}
(f1.1)  sel (16|M0)              acc2.0<1>:uw  r5.10<0;1,0>:uw   0x0:uw             
(W)     mov (1|M0)               r3.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        or (16|M0)    (ne)f1.1   null<1>:uw    r9.0<1;1,0>:uw    acc2.0<1;1,0>:uw {I@3}
(W)     add (1|M0)               r99.6<1>:ud   r3.0<0;1,0>:ud    r99.5<0;1,0>:ud  {I@2}
        mov (16|M0)              r62.0<1>:d    r99.4<0;1,0>:d                  
        mov (16|M0)              r58.0<1>:d    r99.5<0;1,0>:d                   {$7.dst}
        mov (16|M0)              r18.0<1>:f    r15.0<0;1,0>:f                   {Compacted}
        mov (16|M0)              r16.0<1>:d    r99.6<0;1,0>:d                   {I@3}
(f1.1)  goto (16|M0)                         L11336                  L11336                
L11272:
(W)     mov (1|M0)               r99.2<1>:d    r99.1<0;1,0>:d                  
(W)     mov (1|M0)               r99.4<1>:d    r15.0<0;1,0>:d                  
(W)     mov (1|M0)               r99.5<1>:d    r99.6<0;1,0>:d                  
(W)     jmpi                                 L10944                                
L11336:
        join (16|M0)                         L16376                                
L11352:
(W)     mov (1|M0)               r2.0<1>:f     8.68805e-44:f                              
(W)     mov (1|M0)               r3.0<1>:hf    0.0:hf                             
        subb (8|M0)              r38.0<1>:ud   r2.0<0;1,0>:ud    r62.0<1;1,0>:ud  {AccWrEn,Compacted,A@2}
        add3 (8|M0)              r78.0<1>:ud   -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r58.0<1>:ud     {A@1}
        subb (8|M8)              r39.0<1>:ud   r2.0<0;1,0>:ud    r63.0<1;1,0>:ud  {AccWrEn}
        add3 (16|M0)             r82.0<1>:d    r24.0<1;0>:d      r38.0<1;0>:d      -173:w               {I@1}
        cmp (16|M0)   (gt)f1.0   null<1>:d     r82.0<1;1,0>:d    127:w               {I@1}
        add3 (8|M8)              r79.0<1>:ud   -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r59.0<1>:ud    
        add3 (16|M0)             r102.0<1>:d   r30.0<1;0>:d      r26.0<1;0>:d      r38.0<1>:d      
(f1.0)  goto (16|M0)                         L16312                  L16312                
L11504:
        cmp (16|M0)   (gt)f1.1   null<1>:d     r82.0<1;1,0>:d    -127:w              
(f1.1)  goto (16|M0)                         L13992                  L13992                
L11536:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r82.0<1;1,0>:ud   0xFFFFFF6B:ud             
(f1.0)  goto (16|M0)                         L13488                  L13488                
L11568:
(W)     mov (1|M0)               r2.0<1>:f     8.82818e-44:f                              
(W)     mov (1|M0)               r3.0<1>:hf    0.0:hf                              {I@7}
        subb (8|M0)              r16.0<1>:ud   r2.0<0;1,0>:ud    r62.0<1;1,0>:ud  {AccWrEn,Compacted,F@2}
        add3 (16|M0)             r18.0<1>:d    r24.0<1;0>:d      r38.0<1;0>:d      -23:w              
        add3 (8|M0)              r10.0<1>:ud   -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r58.0<1>:ud     {F@1}
        subb (8|M8)              r17.0<1>:ud   r2.0<0;1,0>:ud    r63.0<1;1,0>:ud  {AccWrEn}
        cmp (16|M0)   (gt)f1.1   null<1>:d     r16.0<1;1,0>:ud   r18.0<1;1,0>:ud  {I@1}
        add3 (8|M8)              r11.0<1>:ud   -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r59.0<1>:ud    
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r10.0<1;1,0>:d    0:w               {I@1}
(~f1.1) cmp (16|M0)   (gt)f1.1   null<1>:d     r10.0<1;1,0>:ud   0x0:uw             
(f1.1)  goto (16|M0)                         L11792                  L11792                
L11736:
        add3 (16|M0)             r2.0<1>:d     r102.0<1;0>:d     -r16.0<1;0>:d     -23:w              
        mov (16|M0)              r120.0<1>:d   0:w                              
        shl (16|M0)              r122.0<1>:d   r22.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
        goto (16|M0)                         L11792                  L13424                
L11792:
        join (16|M0)                         L13424                                
L11808:
        add3 (16|M0)             r124.0<1>:d   r16.0<1;0>:d      -r102.0<1;0>:d    23:w              
        cmp (16|M0)   (lt)f1.1   null<1>:d     r124.0<1;1,0>:d   2:w               {I@1}
(f1.1)  goto (16|M0)                         L11960                  L11960                
L11856:
        cmp (16|M0)   (eq)f1.0   null<1>:d     r124.0<1;1,0>:d   2:w              
(~f1.0) goto (16|M0)                         L11960                  L12008                
L11888:
        shr (16|M0)              r80.0<1>:ud   r22.0<1;1,0>:ud   1:w              
        mov (16|M0)              r110.0<1>:d   0:w                              
        mov (16|M0)              r38.0<1>:d    0:w                              
        mov (16|M0)              r92.0<1>:f    r80.0<1;1,0>:f                   {Compacted,I@3}
        goto (16|M0)                         L11960                  L12896                
L11960:
        join (16|M0)                         L12008                                
L11976:
        cmp (16|M0)   (eq)f1.1   null<1>:d     r124.0<1;1,0>:d   1:w              
(f1.1)  goto (16|M0)                         L12008                  L12840                
L12008:
        join (16|M0)                         L12840                                
L12024:
        add3 (16|M0)             r2.0<1>:d     r16.0<1;0>:d      -r18.0<1;0>:d     -1:w              
        and (16|M0)   (ne)f1.0   r94.0<1>:d    r2.0<1;1,0>:d     63:w               {I@1}
(f1.0)  goto (16|M0)                         L12096                  L12096                
L12072:
        mov (16|M0)              r122.0<1>:f   r22.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L12096                  L12208                
L12096:
        join (16|M0)                         L12208                                
L12112:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r94.0<1;1,0>:ud   0x20:uw              {I@4}
(~f1.1) add (16|M0)              r2.0<1>:d     r94.0<1;1,0>:d    -32:w              
(~f1.1) shr (16|M0)              r80.0<1>:ud   r20.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.1)  add (16|M0)              r2.0<1>:d     -r94.0<1;1,0>:d   32:w               {Compacted}
(f1.1)  shr (16|M0)              r10.0<1>:ud   r22.0<1;1,0>:ud   r94.0<1;1,0>:d  
(f1.1)  shl (16|M0)              r2.0<1>:d     r20.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.1)  or (16|M0)               r80.0<1>:d    r10.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@1}
        mov (16|M0)              r122.0<1>:f   r80.0<1;1,0>:f                   {Compacted,I@1}
L12208:
        join (16|M0)                         L12840                                
L12224:
        add3 (16|M0)             r84.0<1>:d    r16.0<1;0>:d      -r18.0<1;0>:d     -2:w              
        and (16|M0)   (ne)f1.0   r92.0<1>:d    r84.0<1;1,0>:d    63:w               {I@1}
(f1.0)  goto (16|M0)                         L12296                  L12296                
L12272:
        mov (16|M0)              r80.0<1>:f    r22.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L12296                  L12400                
L12296:
        join (16|M0)                         L12400                                
L12312:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r92.0<1;1,0>:ud   0x20:uw              {I@4}
(~f1.1) add (16|M0)              r2.0<1>:d     r92.0<1;1,0>:d    -32:w              
(~f1.1) shr (16|M0)              r80.0<1>:ud   r20.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.1)  add (16|M0)              r2.0<1>:d     -r92.0<1;1,0>:d   32:w               {Compacted}
(f1.1)  shr (16|M0)              r10.0<1>:ud   r22.0<1;1,0>:ud   r92.0<1;1,0>:d  
(f1.1)  shl (16|M0)              r2.0<1>:d     r20.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.1)  or (16|M0)               r80.0<1>:d    r10.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@1}
L12400:
        join (16|M0)                         L12840                                
L12416:
        and (16|M0)   (ne)f1.0   r110.0<1>:d   r84.0<1;1,0>:d    63:w              
        and (16|M0)              r38.0<1>:d    r80.0<1;1,0>:d    1:w               {Compacted,I@3}
(f1.0)  goto (16|M0)                         L12504                  L12504                
L12456:
        mov (16|M0)              r12.0<1>:d    -1:w                              
        mov (16|M0)              r24.0<1>:d    -1:w                              
        goto (16|M0)                         L12504                  L12688                
L12504:
        join (16|M0)                         L12688                                
L12520:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r110.0<1;1,0>:ud  0x20:uw              {I@7}
(f1.1)  goto (16|M0)                         L12624                  L12624                
L12552:
        add (16|M0)              r2.0<1>:d     r110.0<1;1,0>:d   -32:w               {Compacted}
(W)     mov (1|M0)               r5.10<1>:hf   -qnan(0x1FF):hf                             
        mov (16|M0)              r12.0<1>:d    0:w                              
        shl (16|M0)              r24.0<1>:d    r5.10<0;1,0>:w    r2.0<1;1,0>:d    {A@1}
        goto (16|M0)                         L12624                  L12688                
L12624:
        join (16|M0)                         L12688                                
L12640:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (16|M0)              r24.0<1>:d    -1:w                              
        shl (16|M0)              r12.0<1>:d    r2.0<0;1,0>:w     r110.0<1;1,0>:d  {F@1}
L12688:
        join (16|M0)                         L12840                                
L12704:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r12.0<1;0>:ud     r4.0<0;0>:ud      r22.0<1>:ud      {I@2} // (s0^s1)&s2
        cmp (16|M0)   (ne)f1.1   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
        bfn.0x60 (16|M0)         r10.0<1>:ud   r24.0<1;0>:ud     r4.0<0;0>:ud      r20.0<1>:ud      // (s0^s1)&s2
(~f1.1) cmp (16|M0)   (ne)f1.1   null<1>:d     r10.0<1;1,0>:d    0:w               {I@1}
(W)     mov (1|M0)               r5.10<1>:hf   -qnan(0x1FF):hf                             
        mov (16|M0)              r92.0<1>:f    r122.0<1;1,0>:f                  {Compacted}
(f1.1)  sel (16|M0)              r12.0<1>:d    r5.10<0;1,0>:w    0:w               {F@2}
        mov (16|M0)              r110.0<1>:d   -r12.0<1;1,0>:d                  {I@1}
        goto (16|M0)                         L12840                  L12896                
L12840:
        join (16|M0)                         L12896                                
L12856:
        mov (16|M0)              r110.0<1>:d   0:w                              
        mov (16|M0)              r38.0<1>:d    0:w                              
        mov (16|M0)              r92.0<1>:f    r22.0<1;1,0>:f                   {Compacted}
L12896:
        join (16|M0)                         L13424                                
L12912:
        and (16|M0)   (ne)f1.0   r90.0<1>:d    r124.0<1;1,0>:d   63:w              
(f1.0)  goto (16|M0)                         L12968                  L12968                
L12944:
        mov (16|M0)              r80.0<1>:f    r22.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L12968                  L13072                
L12968:
        join (16|M0)                         L13072                                
L12984:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r90.0<1;1,0>:ud   0x20:uw              {I@4}
(~f1.1) add (16|M0)              r2.0<1>:d     r90.0<1;1,0>:d    -32:w              
(~f1.1) shr (16|M0)              r80.0<1>:ud   r20.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.1)  add (16|M0)              r2.0<1>:d     -r90.0<1;1,0>:d   32:w               {Compacted}
(f1.1)  shr (16|M0)              r10.0<1>:ud   r22.0<1;1,0>:ud   r90.0<1;1,0>:d  
(f1.1)  shl (16|M0)              r2.0<1>:d     r20.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.1)  or (16|M0)               r80.0<1>:d    r10.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@1}
L13072:
        join (16|M0)                         L13424                                
L13088:
        shl (16|M0)              r2.0<1>:d     r92.0<1;1,0>:d    2:w               {Compacted}
        shl (16|M0)              r10.0<1>:d    r38.0<1;1,0>:d    1:w               {Compacted}
        and (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     4:w               {Compacted,I@2}
        bfn.0xFE (16|M0)         r26.0<1>:ud   r2.0<1;0>:ud      r10.0<1;0>:ud     r110.0<1>:ud     {I@1} // s0|s1|s2
        cmp (16|M0)   (eq)f1.0   null<1>:d     r26.0<1;1,0>:d    0:w               {I@1}
(~f1.0) goto (16|M0)                         L13192                  L13192                
L13160:
        mov (16|M0)              r30.0<1>:d    0:w                              
        goto (16|M0)                         L13192                  L13352                
L13192:
        join (16|M0)                         L13352                                
L13208:
        cmp (16|M0)   (gt)f1.1   null<1>:d     r26.0<1;1,0>:ud   0x4:uw             
(~f1.1) goto (16|M0)                         L13272                  L13272                
L13240:
        mov (16|M0)              r30.0<1>:d    1:w                              
        goto (16|M0)                         L13272                  L13352                
L13272:
        join (16|M0)                         L13352                                
L13288:
        and (16|M0)   (ne)f1.0   null<1>:d     r80.0<1;1,0>:d    1:w              
(W)     mov (1|M0)               r2.0<1>:hf    0x1:hf                             
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r26.0<1;1,0>:d    4:w              
(f1.0)  sel (16|M0)              r30.0<1>:d    r2.0<0;1,0>:w     0:w               {F@1}
L13352:
        join (16|M0)                         L13424                                
L13368:
        add (16|M0)              r2.0<1>:d     r30.0<1;1,0>:d    r80.0<1;1,0>:d   {Compacted,I@2}
        cmp (16|M0)   (gt)f1.1   null<1>:d     r2.0<1;1,0>:ud    0x7FFFFF:ud              {I@1}
(W)     mov (1|M0)               r5.5<1>:f     0x800000:f                               {Compacted}
(~f1.1) sel (16|M0)              r122.0<1>:d   r2.0<1;1,0>:d     0:w              
(f1.1)  sel (16|M0)              r120.0<1>:d   r5.5<0;1,0>:d     0:w               {Compacted,F@1}
L13424:
        join (16|M0)                         L13488                                
L13440:
        and (16|M0)              r2.0<1>:d     r28.0<1;1,0>:d    -2147483648:d              
        bfn.0xFE (16|M0)         r74.0<1>:ud   r2.0<1;0>:ud      r120.0<1;0>:ud    r122.0<1>:ud     {I@1} // s0|s1|s2
        goto (16|M0)                         L13488                  L16528                
L13488:
        join (16|M0)                         L13992                                
L13504:
        and (16|M0)   (ne)f1.0   r70.0<1>:d    r38.0<1;1,0>:d    63:w              
(f1.0)  goto (16|M0)                         L13584                  L13584                
L13536:
        mov (16|M0)              r84.0<1>:d    -1:w                              
        mov (16|M0)              r108.0<1>:d   -1:w                              
        goto (16|M0)                         L13584                  L13768                
L13584:
        join (16|M0)                         L13768                                
L13600:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r70.0<1;1,0>:ud   0x20:uw              {I@6}
(f1.1)  goto (16|M0)                         L13704                  L13704                
L13632:
        add (16|M0)              r2.0<1>:d     r70.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r5.10<1>:hf   -qnan(0x1FF):hf                             
        mov (16|M0)              r84.0<1>:d    0:w                              
        shl (16|M0)              r108.0<1>:d   r5.10<0;1,0>:w    r2.0<1;1,0>:d    {A@1}
        goto (16|M0)                         L13704                  L13768                
L13704:
        join (16|M0)                         L13768                                
L13720:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (16|M0)              r108.0<1>:d   -1:w                              
        shl (16|M0)              r84.0<1>:d    r2.0<0;1,0>:w     r70.0<1;1,0>:d   {F@1}
L13768:
        join (16|M0)                         L13992                                
L13784:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r84.0<1;0>:ud     r4.0<0;0>:ud      r22.0<1>:ud      {I@2} // (s0^s1)&s2
        cmp (16|M0)   (ne)f1.1   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
        bfn.0x60 (16|M0)         r10.0<1>:ud   r108.0<1;0>:ud    r4.0<0;0>:ud      r20.0<1>:ud      // (s0^s1)&s2
        cmp (16|M0)   (gt)f1.0   null<1>:d     r28.0<1;1,0>:d    -1:w              
(~f1.1) cmp (16|M0)   (ne)f1.1   null<1>:d     r10.0<1;1,0>:d    0:w               {I@2}
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r82.0<1;1,0>:d    -150:w              
(f1.0)  goto (16|M0)                         L13936                  L13936                
L13896:
(W)     mov (1|M0)               r2.0<1>:ud    0x80000001:ud                             
(f1.1)  sel (16|M0)              r74.0<1>:f    r2.0<0;1,0>:f     -0.0:f               {Compacted,I@1}
        goto (16|M0)                         L13936                  L16528                
L13936:
        join (16|M0)                         L13992                                
L13952:
(W)     mov (1|M0)               r2.0<1>:ud    0x1:ud                              {F@1}
(f1.1)  sel (16|M0)              r74.0<1>:f    r2.0<0;1,0>:f     0.0:f               {Compacted,I@1}
        goto (16|M0)                         L13992                  L16528                
L13992:
        join (16|M0)                         L16312                                
L14008:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r38.0<1;1,0>:ud   0x18:uw              {F@1}
        add3 (16|M0)             r70.0<1>:d    r24.0<1;0>:d      r38.0<1;0>:d      -46:w              
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r78.0<1;1,0>:d    0:w              
(f1.1)  goto (16|M0)                         L16000                  L16000                
L14072:
        shl (16|M0)              r2.0<1>:d     r18.0<1;1,0>:d    1:w               {Compacted}
        shr (16|M0)              r10.0<1>:ud   r18.0<1;1,0>:ud   31:w              
        shl (16|M0)              r12.0<1>:d    r16.0<1;1,0>:d    1:w               {Compacted}
        cmp (16|M0)   (lt)f1.0   null<1>:d     r2.0<1;1,0>:ud    0x4E:uw              {I@3}
        or (16|M0)               r12.0<1>:d    r12.0<1;1,0>:d    r10.0<1;1,0>:d   {Compacted,I@2}
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r12.0<1;1,0>:d    0:w               {I@1}
(~f1.0) cmp (16|M0)   (lt)f1.0   null<1>:d     r12.0<1;1,0>:d    0:w              
(f1.0)  goto (16|M0)                         L14304                  L14304                
L14176:
        cmp (16|M0)   (eq)f1.0   null<1>:d     r18.0<1;1,0>:d    39:w              
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r16.0<1;1,0>:d    0:w              
(~f1.0) goto (16|M0)                         L14304                  L14368                
L14224:
        shr (16|M0)              r80.0<1>:ud   r22.0<1;1,0>:ud   1:w              
        mov (16|M0)              r100.0<1>:d   0:w                              
        mov (16|M0)              r76.0<1>:d    0:w                              
        mov (16|M0)              r30.0<1>:f    r80.0<1;1,0>:f                   {Compacted,I@3}
        mov (16|M0)              r80.0<1>:f    r22.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L14304                  L15472                
L14304:
        join (16|M0)                         L14368                                
L14320:
        cmp (16|M0)   (eq)f1.1   null<1>:d     r18.0<1;1,0>:d    38:w              
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r16.0<1;1,0>:d    0:w              
(f1.1)  goto (16|M0)                         L14368                  L15384                
L14368:
        join (16|M0)                         L15384                                
L14384:
        add (16|M0)              r2.0<1>:d     -r18.0<1;1,0>:d   39:w               {Compacted}
        and (16|M0)   (ne)f1.1   r116.0<1>:d   r2.0<1;1,0>:d     63:w               {I@1}
        add (16|M0)              r74.0<1>:d    -r18.0<1;1,0>:d   40:w               {Compacted}
(f1.1)  goto (16|M0)                         L14456                  L14456                
L14432:
        mov (16|M0)              r72.0<1>:f    r22.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L14456                  L14568                
L14456:
        join (16|M0)                         L14568                                
L14472:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r116.0<1;1,0>:ud  0x20:uw              {I@5}
(~f1.0) add (16|M0)              r2.0<1>:d     r116.0<1;1,0>:d   -32:w              
(~f1.0) shr (16|M0)              r80.0<1>:ud   r20.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.0)  add (16|M0)              r2.0<1>:d     -r116.0<1;1,0>:d  32:w               {Compacted}
(f1.0)  shr (16|M0)              r10.0<1>:ud   r22.0<1;1,0>:ud   r116.0<1;1,0>:d 
(f1.0)  shl (16|M0)              r2.0<1>:d     r20.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.0)  or (16|M0)               r80.0<1>:d    r10.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@1}
        mov (16|M0)              r72.0<1>:f    r80.0<1;1,0>:f                   {Compacted,I@1}
L14568:
        join (16|M0)                         L15384                                
L14584:
        add (16|M0)              r26.0<1>:d    -r18.0<1;1,0>:d   38:w               {Compacted}
        and (16|M0)   (ne)f1.1   r126.0<1>:d   r26.0<1;1,0>:d    63:w               {I@1}
(f1.1)  goto (16|M0)                         L14648                  L14648                
L14624:
        mov (16|M0)              r80.0<1>:f    r22.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L14648                  L14752                
L14648:
        join (16|M0)                         L14752                                
L14664:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r126.0<1;1,0>:ud  0x20:uw              {I@4}
(~f1.0) add (16|M0)              r2.0<1>:d     r126.0<1;1,0>:d   -32:w              
(~f1.0) shr (16|M0)              r80.0<1>:ud   r20.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.0)  add (16|M0)              r2.0<1>:d     -r126.0<1;1,0>:d  32:w               {Compacted}
(f1.0)  shr (16|M0)              r10.0<1>:ud   r22.0<1;1,0>:ud   r126.0<1;1,0>:d 
(f1.0)  shl (16|M0)              r2.0<1>:d     r20.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.0)  or (16|M0)               r80.0<1>:d    r10.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@1}
L14752:
        join (16|M0)                         L15384                                
L14768:
        and (16|M0)   (ne)f1.1   r32.0<1>:d    r26.0<1;1,0>:d    63:w              
        and (16|M0)              r76.0<1>:d    r80.0<1;1,0>:d    1:w               {Compacted,I@3}
(f1.1)  goto (16|M0)                         L14856                  L14856                
L14808:
        mov (16|M0)              r58.0<1>:d    -1:w                              
        mov (16|M0)              r88.0<1>:d    -1:w                              
        goto (16|M0)                         L14856                  L15040                
L14856:
        join (16|M0)                         L15040                                
L14872:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r32.0<1;1,0>:ud   0x20:uw              {I@7}
(f1.0)  goto (16|M0)                         L14976                  L14976                
L14904:
        add (16|M0)              r2.0<1>:d     r32.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r5.10<1>:hf   -qnan(0x1FF):hf                             
        mov (16|M0)              r58.0<1>:d    0:w                              
        shl (16|M0)              r88.0<1>:d    r5.10<0;1,0>:w    r2.0<1;1,0>:d    {A@1}
        goto (16|M0)                         L14976                  L15040                
L14976:
        join (16|M0)                         L15040                                
L14992:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (16|M0)              r88.0<1>:d    -1:w                              
        shl (16|M0)              r58.0<1>:d    r2.0<0;1,0>:w     r32.0<1;1,0>:d   {F@1}
L15040:
        join (16|M0)                         L15384                                
L15056:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r58.0<1;0>:ud     r4.0<0;0>:ud      r22.0<1>:ud      {I@2} // (s0^s1)&s2
        cmp (16|M0)   (ne)f1.0   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
        bfn.0x60 (16|M0)         r10.0<1>:ud   r88.0<1;0>:ud     r4.0<0;0>:ud      r20.0<1>:ud      // (s0^s1)&s2
(~f1.0) cmp (16|M0)   (ne)f1.0   null<1>:d     r10.0<1;1,0>:d    0:w               {I@1}
(W)     mov (1|M0)               r5.10<1>:hf   -qnan(0x1FF):hf                             
        and (16|M0)   (ne)f1.1   r124.0<1>:d   r74.0<1;1,0>:d    63:w              
(f1.0)  sel (16|M0)              r12.0<1>:d    r5.10<0;1,0>:w    0:w               {F@1}
        mov (16|M0)              r100.0<1>:d   -r12.0<1;1,0>:d                  {I@1}
(f1.1)  goto (16|M0)                         L15224                  L15224                
L15200:
        mov (16|M0)              r80.0<1>:f    r22.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L15224                  L15328                
L15224:
        join (16|M0)                         L15328                                
L15240:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r124.0<1;1,0>:ud  0x20:uw             
(~f1.0) add (16|M0)              r2.0<1>:d     r124.0<1;1,0>:d   -32:w              
(~f1.0) shr (16|M0)              r80.0<1>:ud   r20.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.0)  add (16|M0)              r2.0<1>:d     -r124.0<1;1,0>:d  32:w               {Compacted}
(f1.0)  shr (16|M0)              r10.0<1>:ud   r22.0<1;1,0>:ud   r124.0<1;1,0>:d 
(f1.0)  shl (16|M0)              r2.0<1>:d     r20.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.0)  or (16|M0)               r80.0<1>:d    r10.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@1}
L15328:
        join (16|M0)                         L15384                                
L15344:
        mov (16|M0)              r30.0<1>:f    r80.0<1;1,0>:f                   {Compacted,I@2}
        mov (16|M0)              r80.0<1>:d    r72.0<1;1,0>:d                   {F@1}
        goto (16|M0)                         L15384                  L15472                
L15384:
        join (16|M0)                         L15472                                
L15400:
        shr (16|M0)              r80.0<1>:ud   r22.0<1;1,0>:ud   2:w              
        mov (16|M0)              r100.0<1>:d   0:w                              
        mov (16|M0)              r76.0<1>:d    0:w                              
        mov (16|M0)              r30.0<1>:f    r80.0<1;1,0>:f                   {Compacted,I@3}
        shr (16|M0)              r80.0<1>:ud   r22.0<1;1,0>:ud   1:w               {F@1}
L15472:
        join (16|M0)                         L16000                                
L15488:
        shl (16|M0)              r2.0<1>:d     r80.0<1;1,0>:d    2:w               {Compacted,I@2}
        shl (16|M0)              r10.0<1>:d    r76.0<1;1,0>:d    1:w               {Compacted}
        and (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     4:w               {Compacted,I@2}
        bfn.0xFE (16|M0)         r80.0<1>:ud   r2.0<1;0>:ud      r10.0<1;0>:ud     r100.0<1>:ud     {I@1} // s0|s1|s2
        cmp (16|M0)   (eq)f1.1   null<1>:d     r80.0<1;1,0>:d    0:w               {I@1}
        and (16|M0)              r94.0<1>:d    r30.0<1;1,0>:d    8388607:d              
(~f1.1) goto (16|M0)                         L15608                  L15608                
L15576:
        mov (16|M0)              r68.0<1>:d    0:w                              
        goto (16|M0)                         L15608                  L15768                
L15608:
        join (16|M0)                         L15768                                
L15624:
        cmp (16|M0)   (gt)f1.0   null<1>:d     r80.0<1;1,0>:ud   0x4:uw             
(~f1.0) goto (16|M0)                         L15688                  L15688                
L15656:
        mov (16|M0)              r68.0<1>:d    1:w                              
        goto (16|M0)                         L15688                  L15768                
L15688:
        join (16|M0)                         L15768                                
L15704:
        and (16|M0)   (ne)f1.1   null<1>:d     r30.0<1;1,0>:d    1:w              
(W)     mov (1|M0)               r2.0<1>:hf    0x1:hf                             
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r80.0<1;1,0>:d    4:w              
(f1.1)  sel (16|M0)              r68.0<1>:d    r2.0<0;1,0>:w     0:w               {F@1}
L15768:
        join (16|M0)                         L16000                                
L15784:
        add (16|M0)              r34.0<1>:d    r94.0<1;1,0>:d    r68.0<1;1,0>:d   {Compacted,I@2}
        cmp (16|M0)   (gt)f1.0   null<1>:d     r34.0<1;1,0>:ud   0x7FFFFF:ud              {I@1}
        add3 (16|M0)             r2.0<1>:d     r24.0<1;0>:d      r38.0<1;0>:d      -45:w              
(f1.0)  sel (16|M0)              r14.0<1>:d    r2.0<1;1,0>:d     r70.0<1;1,0>:d   {Compacted,I@1}
        cmp (16|M0)   (eq)f1.1   null<1>:d     r14.0<1;1,0>:d    255:w               {I@1}
(f1.1)  goto (16|M0)                         L15936                  L15936                
L15864:
(~f1.0) sel (16|M0)              r2.0<1>:d     r34.0<1;1,0>:d    0:w              
        and (16|M0)              r10.0<1>:d    r28.0<1;1,0>:d    -2147483648:d              
        shl (16|M0)              r12.0<1>:d    r14.0<1;1,0>:d    23:w               {Compacted}
        bfn.0xFE (16|M0)         r74.0<1>:ud   r10.0<1;0>:ud     r12.0<1;0>:ud     r2.0<1>:ud       {I@1} // s0|s1|s2
        goto (16|M0)                         L15936                  L16528                
L15936:
        join (16|M0)                         L16000                                
L15952:
        cmp (16|M0)   (gt)f1.0   null<1>:d     r28.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r2.0<1>:f     inf:f                               {Compacted,I@4}
(f1.0)  sel (16|M0)              r74.0<1>:f    r2.0<0;1,0>:f     -inf:f               {Compacted,F@1}
        goto (16|M0)                         L16000                  L16528                
L16000:
        join (16|M0)                         L16312                                
L16016:
        and (16|M0)   (ne)f1.0   r118.0<1>:d   r38.0<1;1,0>:d    63:w               {F@1}
(f1.0)  goto (16|M0)                         L16080                  L16080                
L16048:
        mov (16|M0)              r58.0<1>:d    -1:w                              
        goto (16|M0)                         L16080                  L16208                
L16080:
        join (16|M0)                         L16208                                
L16096:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r118.0<1;1,0>:ud  0x20:uw              {I@5}
(f1.1)  goto (16|M0)                         L16160                  L16160                
L16128:
        mov (16|M0)              r58.0<1>:d    0:w                              
        goto (16|M0)                         L16160                  L16208                
L16160:
        join (16|M0)                         L16208                                
L16176:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                             
        shl (16|M0)              r58.0<1>:d    r2.0<0;1,0>:w     r118.0<1;1,0>:d  {F@1}
L16208:
        join (16|M0)                         L16312                                
L16224:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r58.0<1;0>:ud     r4.0<0;0>:ud      r22.0<1>:ud      {I@2} // (s0^s1)&s2
        add (16|M0)              r10.0<1>:d    -r38.0<1;1,0>:d   23:w               {Compacted}
        and (16|M0)              r12.0<1>:d    r28.0<1;1,0>:d    -2147483648:d              
        shl (16|M0)              r14.0<1>:d    r70.0<1;1,0>:d    23:w               {Compacted}
        shl (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     r10.0<1;1,0>:d   {Compacted,I@3}
        bfn.0xFE (16|M0)         r74.0<1>:ud   r12.0<1;0>:ud     r14.0<1;0>:ud     r2.0<1>:ud       {I@1} // s0|s1|s2
        goto (16|M0)                         L16312                  L16528                
L16312:
        join (16|M0)                         L16376                                
L16328:
        cmp (16|M0)   (gt)f1.1   null<1>:d     r28.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r2.0<1>:f     inf:f                               {Compacted,I@4}
(f1.1)  sel (16|M0)              r74.0<1>:f    r2.0<0;1,0>:f     -inf:f               {Compacted,F@1}
        goto (16|M0)                         L16376                  L16528                
L16376:
        join (16|M0)                         L16432                                
L16392:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r28.0<1;1,0>:d    0:w               {Compacted}
(W)     mov (1|M0)               r2.0<1>:f     -0.0:f                               {Compacted}
(f1.0)  sel (16|M0)              r74.0<1>:f    r2.0<0;1,0>:f     0.0:f               {Compacted,F@1}
        goto (16|M0)                         L16432                  L16528                
L16432:
        join (16|M0)                         L16496                                
L16448:
        cmp (16|M0)   (gt)f1.1   null<1>:d     r28.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r2.0<1>:f     inf:f                               {Compacted}
(f1.1)  sel (16|M0)              r74.0<1>:f    r2.0<0;1,0>:f     -inf:f               {Compacted,F@1}
        goto (16|M0)                         L16496                  L16528                
L16496:
        join (16|M0)                         L16528                                
L16512:
        bfn.0xF8 (16|M0)         r74.0<1>:ud   r28.0<1;0>:ud     r4.2<0;0>:ud      r4.1<0>:ud       {F@1} // s0&s1|s2
L16528:
        join (16|M0)                         L29800                                
L16544:
        cmp (16|M0)   (lt)f1.0   null<1>:f     r60.0<1;1,0>:f    0.0:f               {Compacted,I@7}
(W)     shl (1|M0)               r5.5<1>:d     r8.7<0;1,0>:d     1:w              
(W)     shr (1|M0)               r5.6<1>:ud    r8.7<0;1,0>:ud    31:w              
        addc (8|M0)              r10.0<1>:ud   r56.0<1;1,0>:ud   r5.5<0;1,0>:ud   {AccWrEn,Compacted,I@2}
(f1.0)  sel (16|M0)              r2.0<1>:f     -r74.0<1;1,0>:f   r74.0<1;1,0>:f   {Compacted}
        mov (8|M0)               r12.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        addc (8|M8)              r11.0<1>:ud   r57.0<1;1,0>:ud   r5.5<0;1,0>:ud   {AccWrEn}
        mov (8|M0)               r9.0<1>:hf    r2.0<1;1,0>:f                    {F@1}
        mov (8|M8)               r9.8<1>:hf    r3.0<1;1,0>:f                   
        mov (8|M8)               r18.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        sync.nop                             null                             {Compacted,$5.src}
        add3 (8|M0)              r13.1<2>:ud   r12.0<1;0>:ud     r54.0<1;0>:ud     r5.6<0>:ud       {I@3}
        mov (16|M0)              r20.0<1>:ud   r9.0<1;1,0>:uw                   {A@1}
        add3 (8|M8)              r15.1<2>:ud   r18.0<1;0>:ud     r55.0<1;0>:ud     r5.6<0>:ud       {I@3}
        mov (8|M0)               r13.0<2>:d    r10.0<1;1,0>:d                  
        mov (8|M8)               r15.0<2>:d    r11.0<1;1,0>:d                  
(W)     or (1|M0)                r4.5<1>:d     r8.7<0;1,0>:d     1:w              
        send.ugm (16|M0)         null     r13     r20:2   0x0            0x080E0B84           {A@2,$6} // wr:4+2, rd:0; store.ugm.d16u32.a64.wb.wb
(f0.0)  goto (16|M0)                         L17008                  L17008                
L16800:
(W)     shl (1|M0)               r2.0<1>:d     r4.5<0;1,0>:d     1:w               {Compacted,I@2}
(W)     shr (1|M0)               r2.1<1>:ud    r4.5<0;1,0>:ud    31:w              
        addc (8|M0)              r10.0<1>:ud   r52.0<1;1,0>:ud   r2.0<0;1,0>:ud   {AccWrEn,Compacted,I@2}
        mov (8|M0)               r12.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        addc (8|M8)              r11.0<1>:ud   r53.0<1;1,0>:ud   r2.0<0;1,0>:ud   {AccWrEn}
        sync.nop                             null                             {Compacted,$6.src}
        add3 (8|M0)              r13.1<2>:ud   r12.0<1;0>:ud     r50.0<1;0>:ud     r2.1<0>:ud       {I@2}
        mov (8|M8)               r18.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mov (8|M0)               r13.0<2>:d    r10.0<1;1,0>:d                  
        add3 (8|M8)              r15.1<2>:ud   r18.0<1;0>:ud     r51.0<1;0>:ud     r2.1<0>:ud       {I@2}
        mov (8|M8)               r15.0<2>:d    r11.0<1;1,0>:d                  
        send.ugm (16|M0)         r20      r13     null:0  0x0            0x08280B80           {A@1,$1} // wr:4+0, rd:2; load.ugm.d16u32.a64.ca.ca
        mov (16|M0)              r3.0<1>:uw    r20.0<2;1,0>:uw                  {$1.dst}
        sync.nop                             null                             {Compacted,$7.dst}
        mov (16|M0)              r58.0<1>:f    r3.0<1;1,0>:hf                   {I@1}
        goto (16|M0)                         L17008                  L17176                
L17008:
        join (16|M0)                         L17176                                
L17024:
(W)     shl (1|M0)               r2.0<1>:d     r4.5<0;1,0>:d     2:w               {Compacted}
(W)     shr (1|M0)               r2.1<1>:ud    r4.5<0;1,0>:ud    30:w              
        addc (8|M0)              r10.0<1>:ud   r48.0<1;1,0>:ud   r2.0<0;1,0>:ud   {AccWrEn,Compacted,I@2}
        mov (8|M0)               r12.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        addc (8|M8)              r11.0<1>:ud   r49.0<1;1,0>:ud   r2.0<0;1,0>:ud   {AccWrEn}
        sync.nop                             null                             {Compacted,$6.src}
        add3 (8|M0)              r13.1<2>:ud   r12.0<1;0>:ud     r46.0<1;0>:ud     r2.1<0>:ud       {I@2}
        mov (8|M8)               r18.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mov (8|M0)               r13.0<2>:d    r10.0<1;1,0>:d                  
        add3 (8|M8)              r15.1<2>:ud   r18.0<1;0>:ud     r47.0<1;0>:ud     r2.1<0>:ud       {I@2}
        mov (8|M8)               r15.0<2>:d    r11.0<1;1,0>:d                  
        send.ugm (16|M0)         r58      r13     null:0  0x0            0x08280580           {A@1,$7} // wr:4+0, rd:2; load.ugm.d32.a64.ca.ca
L17176:
        join (16|M0)                         L29800                                
L17192:
        and (16|M0)              r2.0<1>:d     r58.0<1;1,0>:d    2147483647:d               {$7.dst}
        sel (16|M0)   (lt)f0.0   r106.0<1>:f   r2.0<1;1,0>:f     448.0:f               {Compacted,I@1}
        shr (16|M0)              r82.0<1>:ud   r106.0<1;1,0>:ud  23:w               {F@1}
        and (16|M0)   (ne)f1.0   r86.0<1>:d    r106.0<1;1,0>:d   8388607:d              
        and (16|M0)              r84.0<1>:d    r82.0<1;1,0>:d    255:w               {Compacted,I@2}
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r84.0<1;1,0>:d    255:w               {I@1}
        sel (16|M0)   (ge)f0.0   r10.0<1>:ud   r84.0<1;1,0>:ud   0x79:uw             
        shl (16|M0)              r62.0<1>:d    r10.0<1;1,0>:d    23:w               {Compacted,I@1}
(~f1.0) goto (16|M0)                         L17344                  L17344                
L17312:
        mov (16|M0)              r80.0<1>:ud   0x7FC00000:ud                             
        goto (16|M0)                         L17344                  L23328                
L17344:
        join (16|M0)                         L23328                                
L17360:
        cmp (16|M0)   (eq)f1.1   null<1>:d     r86.0<1;1,0>:d    0:w              
        add (16|M0)              r32.0<1>:d    -r62.0<1;1,0>:d   -2139095040:d               {I@6}
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r84.0<1;1,0>:d    255:w              
        xor (16|M0)              r80.0<1>:d    r32.0<1;1,0>:d    r106.0<1;1,0>:d  {Compacted,I@2}
(f1.1)  goto (16|M0)                         L23296                  L23296                
L17432:
        or (16|M0)    (eq)f1.1   null<1>:d     r84.0<1;1,0>:d    r86.0<1;1,0>:d  
(~f1.1) goto (16|M0)                         L17496                  L17496                
L17464:
        mov (16|M0)              r80.0<1>:ud   0x0:ud                             
        goto (16|M0)                         L17496                  L23328                
L17496:
        join (16|M0)                         L23296                                
L17512:
        cmp (16|M0)   (eq)f1.1   null<1>:d     r84.0<1;1,0>:d    0:w              
        shr (16|M0)              r78.0<1>:ud   r32.0<1;1,0>:ud   23:w              
        add (16|M0)              r76.0<1>:d    r84.0<1;1,0>:d    -127:w               {Compacted}
(f1.1)  mov (16|M0)              r76.0<1>:d    -126:w                              
        add (16|M0)              r74.0<1>:d    r78.0<1;1,0>:d    r76.0<1;1,0>:d   {Compacted,I@1}
        cmp (16|M0)   (gt)f1.0   null<1>:d     r74.0<1;1,0>:d    254:w               {I@1}
(f1.0)  goto (16|M0)                         L23232                  L23232                
L17608:
        or (16|M0)    (eq)f1.0   null<4>:b     r82.0<1;1,0>:d    r78.0<1;1,0>:d  
(f1.0)  goto (16|M0)                         L23176                  L23176                
L17640:
(W)     mov (1|M0)               r2.0<1>:hf    0.0:hf                             
(W)     mov (1|M0)               r99.3<1>:d    0:w                              
(f1.1)  sel (16|M0)              r10.0<1>:d    r2.0<0;1,0>:w     8388608:d               {F@1}
        or (16|M0)               r10.0<1>:d    r10.0<1;1,0>:d    r86.0<1;1,0>:d   {Compacted,I@1}
        shl (16|M0)              r72.0<1>:d    r10.0<1;1,0>:d    23:w               {Compacted,I@1}
        shr (16|M0)              r70.0<1>:ud   r10.0<1;1,0>:ud   9:w              
(W)     mov (1|M0)               r99.2<1>:f    -0.0:f                               {Compacted}
(W)     mov (2|M0)               r99.4<1>:d    0:w                              
L17744:
(W)     shl (1|M0)               r2.0<1>:d     r99.2<0;1,0>:d    31:w               {Compacted,F@1}
(W)     shr (1|M0)               r2.1<1>:ud    r99.3<0;1,0>:ud   1:w              
(W)     cmp (16|M0)   (gt)f1.1   null<1>:d     r99.4<0;1,0>:ud   0x3E:uw              {I@3}
(W)     or (1|M0)                r99.3<1>:d    r2.1<0;1,0>:d     r2.0<0;1,0>:d    {I@2}
        bfn.0xE0 (16|M0)         r10.0<1>:ud   r2.1<0;0>:ud      r2.0<0;0>:ud      r72.0<1>:ud      // (s0|s1)&s2
(W)     shr (1|M0)               r99.1<1>:ud   r99.2<0;1,0>:ud   1:w              
(W&f1.1) cmp (16|M0)  (eq)f1.1   null<1>:d     r99.5<0;1,0>:d    0:w              
        cmp (16|M0)   (eq)f1.0   null<1>:d     r10.0<1;1,0>:d    r99.3<0;1,0>:d   {I@3}
        sync.nop                             null                             {Compacted,$6.src}
        and (16|M0)              r12.0<1>:d    r99.1<0;1,0>:d    r70.0<1;1,0>:d   {Compacted,I@3}
(W&~f1.1) cmp (16|M0) (gt)f1.1   null<1>:d     r99.5<0;1,0>:ud   0x0:uw             
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r12.0<1;1,0>:d    r99.1<0;1,0>:d   {I@2}
(W)     mov (1|M0)               r5.10<1>:hf   0x1:hf                             
(W)     addc (1|M0)              r15.0<1>:ud   r99.4<0;1,0>:ud   0x1:ud              {AccWrEn}
(f1.1)  sel (16|M0)              r9.0<1>:uw    r5.10<0;1,0>:uw   0x0:uw              {Compacted,F@1}
(f1.0)  sel (16|M0)              acc2.0<1>:uw  r5.10<0;1,0>:uw   0x0:uw             
(W)     mov (1|M0)               r3.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        or (16|M0)    (ne)f1.0   null<1>:uw    r9.0<1;1,0>:uw    acc2.0<1;1,0>:uw {I@3}
(W)     add (1|M0)               r99.6<1>:ud   r3.0<0;1,0>:ud    r99.5<0;1,0>:ud  {I@2}
        mov (16|M0)              r104.0<1>:d   r99.4<0;1,0>:d                  
        mov (16|M0)              r102.0<1>:d   r99.5<0;1,0>:d                  
        mov (16|M0)              r68.0<1>:f    r15.0<0;1,0>:f                   {Compacted}
        mov (16|M0)              r66.0<1>:d    r99.6<0;1,0>:d                   {I@3}
(f1.0)  goto (16|M0)                         L18144                  L18144                
L18080:
(W)     mov (1|M0)               r99.2<1>:d    r99.1<0;1,0>:d                  
(W)     mov (1|M0)               r99.4<1>:d    r15.0<0;1,0>:d                  
(W)     mov (1|M0)               r99.5<1>:d    r99.6<0;1,0>:d                  
(W)     jmpi                                 L17744                                
L18144:
        join (16|M0)                         L23176                                
L18160:
(W)     mov (1|M0)               r2.0<1>:f     8.68805e-44:f                              
(W)     mov (1|M0)               r3.0<1>:hf    0.0:hf                             
        subb (8|M0)              r100.0<1>:ud  r2.0<0;1,0>:ud    r104.0<1;1,0>:ud {AccWrEn,Compacted,A@2}
        add3 (8|M0)              r82.0<1>:ud   -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r102.0<1>:ud    {A@1}
        subb (8|M8)              r101.0<1>:ud  r2.0<0;1,0>:ud    r105.0<1;1,0>:ud {AccWrEn}
        add3 (16|M0)             r86.0<1>:d    r74.0<1;0>:d      r100.0<1;0>:d     -173:w               {I@1}
        cmp (16|M0)   (gt)f1.1   null<1>:d     r86.0<1;1,0>:d    127:w               {I@1}
        add3 (8|M8)              r83.0<1>:ud   -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r103.0<1>:ud   
        add3 (16|M0)             r106.0<1>:d   r78.0<1;0>:d      r76.0<1;0>:d      r100.0<1>:d     
(f1.1)  goto (16|M0)                         L23112                  L23112                
L18312:
        cmp (16|M0)   (gt)f1.0   null<1>:d     r86.0<1;1,0>:d    -127:w              
(f1.0)  goto (16|M0)                         L20792                  L20792                
L18344:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r86.0<1;1,0>:ud   0xFFFFFF6B:ud             
(f1.1)  goto (16|M0)                         L20288                  L20288                
L18376:
(W)     mov (1|M0)               r2.0<1>:f     8.82818e-44:f                              
(W)     mov (1|M0)               r3.0<1>:hf    0.0:hf                              {I@7}
        subb (8|M0)              r38.0<1>:ud   r2.0<0;1,0>:ud    r104.0<1;1,0>:ud {AccWrEn,Compacted,F@2}
        add3 (16|M0)             r60.0<1>:d    r74.0<1;0>:d      r100.0<1;0>:d     -23:w              
        add3 (8|M0)              r10.0<1>:ud   -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r102.0<1>:ud    {F@1}
        subb (8|M8)              r39.0<1>:ud   r2.0<0;1,0>:ud    r105.0<1;1,0>:ud {AccWrEn}
        cmp (16|M0)   (gt)f1.1   null<1>:d     r38.0<1;1,0>:ud   r60.0<1;1,0>:ud  {I@1}
        add3 (8|M8)              r11.0<1>:ud   -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r103.0<1>:ud   
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r10.0<1;1,0>:d    0:w               {I@1}
(~f1.1) cmp (16|M0)   (gt)f1.1   null<1>:d     r10.0<1;1,0>:ud   0x0:uw             
(f1.1)  goto (16|M0)                         L18600                  L18600                
L18544:
        add3 (16|M0)             r2.0<1>:d     r106.0<1;0>:d     -r38.0<1;0>:d     -23:w              
        mov (16|M0)              r28.0<1>:d    0:w                              
        shl (16|M0)              r30.0<1>:d    r72.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
        goto (16|M0)                         L18600                  L20224                
L18600:
        join (16|M0)                         L20224                                
L18616:
        add3 (16|M0)             r36.0<1>:d    r38.0<1;0>:d      -r106.0<1;0>:d    23:w              
        cmp (16|M0)   (lt)f1.0   null<1>:d     r36.0<1;1,0>:d    2:w               {Compacted,I@1}
(f1.0)  goto (16|M0)                         L18760                  L18760                
L18656:
        cmp (16|M0)   (eq)f1.1   null<1>:d     r36.0<1;1,0>:d    2:w              
(~f1.1) goto (16|M0)                         L18760                  L18808                
L18688:
        shr (16|M0)              r84.0<1>:ud   r72.0<1;1,0>:ud   1:w              
        mov (16|M0)              r120.0<1>:d   0:w                              
        mov (16|M0)              r96.0<1>:d    0:w                              
        mov (16|M0)              r20.0<1>:f    r84.0<1;1,0>:f                   {Compacted,I@3}
        goto (16|M0)                         L18760                  L19696                
L18760:
        join (16|M0)                         L18808                                
L18776:
        cmp (16|M0)   (eq)f1.0   null<1>:d     r36.0<1;1,0>:d    1:w              
(f1.0)  goto (16|M0)                         L18808                  L19640                
L18808:
        join (16|M0)                         L19640                                
L18824:
        add3 (16|M0)             r2.0<1>:d     r38.0<1;0>:d      -r60.0<1;0>:d     -1:w              
        and (16|M0)   (ne)f1.1   r114.0<1>:d   r2.0<1;1,0>:d     63:w               {I@1}
(f1.1)  goto (16|M0)                         L18896                  L18896                
L18872:
        mov (16|M0)              r34.0<1>:f    r72.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L18896                  L19008                
L18896:
        join (16|M0)                         L19008                                
L18912:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r114.0<1;1,0>:ud  0x20:uw              {I@4}
(~f1.0) add (16|M0)              r2.0<1>:d     r114.0<1;1,0>:d   -32:w              
(~f1.0) shr (16|M0)              r84.0<1>:ud   r70.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.0)  add (16|M0)              r2.0<1>:d     -r114.0<1;1,0>:d  32:w               {Compacted}
(f1.0)  shr (16|M0)              r10.0<1>:ud   r72.0<1;1,0>:ud   r114.0<1;1,0>:d 
(f1.0)  shl (16|M0)              r2.0<1>:d     r70.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.0)  or (16|M0)               r84.0<1>:d    r10.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@1}
        mov (16|M0)              r34.0<1>:f    r84.0<1;1,0>:f                   {Compacted,I@1}
L19008:
        join (16|M0)                         L19640                                
L19024:
        add3 (16|M0)             r92.0<1>:d    r38.0<1;0>:d      -r60.0<1;0>:d     -2:w              
        and (16|M0)   (ne)f1.1   r112.0<1>:d   r92.0<1;1,0>:d    63:w               {I@1}
(f1.1)  goto (16|M0)                         L19096                  L19096                
L19072:
        mov (16|M0)              r84.0<1>:f    r72.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L19096                  L19200                
L19096:
        join (16|M0)                         L19200                                
L19112:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r112.0<1;1,0>:ud  0x20:uw              {I@4}
(~f1.0) add (16|M0)              r2.0<1>:d     r112.0<1;1,0>:d   -32:w              
(~f1.0) shr (16|M0)              r84.0<1>:ud   r70.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.0)  add (16|M0)              r2.0<1>:d     -r112.0<1;1,0>:d  32:w               {Compacted}
(f1.0)  shr (16|M0)              r10.0<1>:ud   r72.0<1;1,0>:ud   r112.0<1;1,0>:d 
(f1.0)  shl (16|M0)              r2.0<1>:d     r70.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.0)  or (16|M0)               r84.0<1>:d    r10.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@1}
L19200:
        join (16|M0)                         L19640                                
L19216:
        and (16|M0)   (ne)f1.1   r22.0<1>:d    r92.0<1;1,0>:d    63:w              
        and (16|M0)              r96.0<1>:d    r84.0<1;1,0>:d    1:w               {Compacted,I@3}
(f1.1)  goto (16|M0)                         L19304                  L19304                
L19256:
        mov (16|M0)              r30.0<1>:d    -1:w                              
        mov (16|M0)              r38.0<1>:d    -1:w                              
        goto (16|M0)                         L19304                  L19488                
L19304:
        join (16|M0)                         L19488                                
L19320:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r22.0<1;1,0>:ud   0x20:uw              {I@7}
(f1.0)  goto (16|M0)                         L19424                  L19424                
L19352:
        add (16|M0)              r2.0<1>:d     r22.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r5.10<1>:hf   -qnan(0x1FF):hf                             
        mov (16|M0)              r30.0<1>:d    0:w                              
        shl (16|M0)              r38.0<1>:d    r5.10<0;1,0>:w    r2.0<1;1,0>:d    {A@1}
        goto (16|M0)                         L19424                  L19488                
L19424:
        join (16|M0)                         L19488                                
L19440:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (16|M0)              r38.0<1>:d    -1:w                              
        shl (16|M0)              r30.0<1>:d    r2.0<0;1,0>:w     r22.0<1;1,0>:d   {F@1}
L19488:
        join (16|M0)                         L19640                                
L19504:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r30.0<1;0>:ud     r4.0<0;0>:ud      r72.0<1>:ud      {I@2} // (s0^s1)&s2
        cmp (16|M0)   (ne)f1.0   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
        bfn.0x60 (16|M0)         r10.0<1>:ud   r38.0<1;0>:ud     r4.0<0;0>:ud      r70.0<1>:ud      // (s0^s1)&s2
(~f1.0) cmp (16|M0)   (ne)f1.0   null<1>:d     r10.0<1;1,0>:d    0:w               {I@1}
(W)     mov (1|M0)               r5.10<1>:hf   -qnan(0x1FF):hf                             
        mov (16|M0)              r20.0<1>:f    r34.0<1;1,0>:f                   {Compacted}
(f1.0)  sel (16|M0)              r12.0<1>:d    r5.10<0;1,0>:w    0:w               {F@2}
        mov (16|M0)              r120.0<1>:d   -r12.0<1;1,0>:d                  {I@1}
        goto (16|M0)                         L19640                  L19696                
L19640:
        join (16|M0)                         L19696                                
L19656:
        mov (16|M0)              r120.0<1>:d   0:w                              
        mov (16|M0)              r96.0<1>:d    0:w                              
        mov (16|M0)              r20.0<1>:f    r72.0<1;1,0>:f                   {Compacted}
L19696:
        join (16|M0)                         L20224                                
L19712:
        and (16|M0)   (ne)f1.1   r110.0<1>:d   r36.0<1;1,0>:d    63:w              
(f1.1)  goto (16|M0)                         L19768                  L19768                
L19744:
        mov (16|M0)              r84.0<1>:f    r72.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L19768                  L19872                
L19768:
        join (16|M0)                         L19872                                
L19784:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r110.0<1;1,0>:ud  0x20:uw              {I@4}
(~f1.0) add (16|M0)              r2.0<1>:d     r110.0<1;1,0>:d   -32:w              
(~f1.0) shr (16|M0)              r84.0<1>:ud   r70.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.0)  add (16|M0)              r2.0<1>:d     -r110.0<1;1,0>:d  32:w               {Compacted}
(f1.0)  shr (16|M0)              r10.0<1>:ud   r72.0<1;1,0>:ud   r110.0<1;1,0>:d 
(f1.0)  shl (16|M0)              r2.0<1>:d     r70.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.0)  or (16|M0)               r84.0<1>:d    r10.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@1}
L19872:
        join (16|M0)                         L20224                                
L19888:
        shl (16|M0)              r2.0<1>:d     r20.0<1;1,0>:d    2:w               {Compacted}
        shl (16|M0)              r10.0<1>:d    r96.0<1;1,0>:d    1:w               {Compacted}
        and (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     4:w               {Compacted,I@2}
        bfn.0xFE (16|M0)         r36.0<1>:ud   r2.0<1;0>:ud      r10.0<1;0>:ud     r120.0<1>:ud     {I@1} // s0|s1|s2
        cmp (16|M0)   (eq)f1.1   null<1>:d     r36.0<1;1,0>:d    0:w               {I@1}
(~f1.1) goto (16|M0)                         L19992                  L19992                
L19960:
        mov (16|M0)              r66.0<1>:d    0:w                              
        goto (16|M0)                         L19992                  L20152                
L19992:
        join (16|M0)                         L20152                                
L20008:
        cmp (16|M0)   (gt)f1.0   null<1>:d     r36.0<1;1,0>:ud   0x4:uw             
(~f1.0) goto (16|M0)                         L20072                  L20072                
L20040:
        mov (16|M0)              r66.0<1>:d    1:w                              
        goto (16|M0)                         L20072                  L20152                
L20072:
        join (16|M0)                         L20152                                
L20088:
        and (16|M0)   (ne)f1.1   null<1>:d     r84.0<1;1,0>:d    1:w              
(W)     mov (1|M0)               r2.0<1>:hf    0x1:hf                             
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r36.0<1;1,0>:d    4:w              
(f1.1)  sel (16|M0)              r66.0<1>:d    r2.0<0;1,0>:w     0:w               {F@1}
L20152:
        join (16|M0)                         L20224                                
L20168:
        add (16|M0)              r2.0<1>:d     r66.0<1;1,0>:d    r84.0<1;1,0>:d   {Compacted,I@2}
        cmp (16|M0)   (gt)f1.0   null<1>:d     r2.0<1;1,0>:ud    0x7FFFFF:ud              {I@1}
(W)     mov (1|M0)               r5.5<1>:f     0x800000:f                               {Compacted}
(~f1.0) sel (16|M0)              r30.0<1>:d    r2.0<1;1,0>:d     0:w              
(f1.0)  sel (16|M0)              r28.0<1>:d    r5.5<0;1,0>:d     0:w               {Compacted,F@1}
L20224:
        join (16|M0)                         L20288                                
L20240:
        and (16|M0)              r2.0<1>:d     r80.0<1;1,0>:d    -2147483648:d              
        bfn.0xFE (16|M0)         r80.0<1>:ud   r2.0<1;0>:ud      r28.0<1;0>:ud     r30.0<1>:ud      {I@1} // s0|s1|s2
        goto (16|M0)                         L20288                  L23328                
L20288:
        join (16|M0)                         L20792                                
L20304:
        and (16|M0)   (ne)f1.1   r104.0<1>:d   r100.0<1;1,0>:d   63:w              
(f1.1)  goto (16|M0)                         L20384                  L20384                
L20336:
        mov (16|M0)              r10.0<1>:d    -1:w                              
        mov (16|M0)              r20.0<1>:d    -1:w                              
        goto (16|M0)                         L20384                  L20568                
L20384:
        join (16|M0)                         L20568                                
L20400:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r104.0<1;1,0>:ud  0x20:uw              {I@6}
(f1.0)  goto (16|M0)                         L20504                  L20504                
L20432:
        add (16|M0)              r2.0<1>:d     r104.0<1;1,0>:d   -32:w               {Compacted}
(W)     mov (1|M0)               r5.10<1>:hf   -qnan(0x1FF):hf                             
        mov (16|M0)              r10.0<1>:d    0:w                              
        shl (16|M0)              r20.0<1>:d    r5.10<0;1,0>:w    r2.0<1;1,0>:d    {A@1}
        goto (16|M0)                         L20504                  L20568                
L20504:
        join (16|M0)                         L20568                                
L20520:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (16|M0)              r20.0<1>:d    -1:w                              
        shl (16|M0)              r10.0<1>:d    r2.0<0;1,0>:w     r104.0<1;1,0>:d  {F@1}
L20568:
        join (16|M0)                         L20792                                
L20584:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r10.0<1;0>:ud     r4.0<0;0>:ud      r72.0<1>:ud      {I@2} // (s0^s1)&s2
        cmp (16|M0)   (ne)f1.0   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
        bfn.0x60 (16|M0)         r10.0<1>:ud   r20.0<1;0>:ud     r4.0<0;0>:ud      r70.0<1>:ud      // (s0^s1)&s2
        cmp (16|M0)   (gt)f1.1   null<1>:d     r80.0<1;1,0>:d    -1:w              
(~f1.0) cmp (16|M0)   (ne)f1.0   null<1>:d     r10.0<1;1,0>:d    0:w               {I@2}
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r86.0<1;1,0>:d    -150:w              
(f1.1)  goto (16|M0)                         L20736                  L20736                
L20696:
(W)     mov (1|M0)               r2.0<1>:ud    0x80000001:ud                             
(f1.0)  sel (16|M0)              r80.0<1>:f    r2.0<0;1,0>:f     -0.0:f               {Compacted,I@1}
        goto (16|M0)                         L20736                  L23328                
L20736:
        join (16|M0)                         L20792                                
L20752:
(W)     mov (1|M0)               r2.0<1>:ud    0x1:ud                              {F@1}
(f1.0)  sel (16|M0)              r80.0<1>:f    r2.0<0;1,0>:f     0.0:f               {Compacted,I@1}
        goto (16|M0)                         L20792                  L23328                
L20792:
        join (16|M0)                         L23112                                
L20808:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r100.0<1;1,0>:ud  0x18:uw              {F@1}
        add3 (16|M0)             r64.0<1>:d    r74.0<1;0>:d      r100.0<1;0>:d     -46:w              
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r82.0<1;1,0>:d    0:w              
(f1.0)  goto (16|M0)                         L22800                  L22800                
L20872:
        shl (16|M0)              r2.0<1>:d     r68.0<1;1,0>:d    1:w               {Compacted}
        shr (16|M0)              r10.0<1>:ud   r68.0<1;1,0>:ud   31:w              
        shl (16|M0)              r12.0<1>:d    r66.0<1;1,0>:d    1:w               {Compacted}
        cmp (16|M0)   (lt)f1.0   null<1>:d     r2.0<1;1,0>:ud    0x4E:uw              {I@3}
        or (16|M0)               r12.0<1>:d    r12.0<1;1,0>:d    r10.0<1;1,0>:d   {Compacted,I@2}
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r12.0<1;1,0>:d    0:w               {I@1}
(~f1.0) cmp (16|M0)   (lt)f1.0   null<1>:d     r12.0<1;1,0>:d    0:w              
(f1.0)  goto (16|M0)                         L21104                  L21104                
L20976:
        cmp (16|M0)   (eq)f1.1   null<1>:d     r68.0<1;1,0>:d    39:w              
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r66.0<1;1,0>:d    0:w              
(~f1.1) goto (16|M0)                         L21104                  L21168                
L21024:
        shr (16|M0)              r84.0<1>:ud   r72.0<1;1,0>:ud   1:w              
        mov (16|M0)              r102.0<1>:d   0:w                              
        mov (16|M0)              r78.0<1>:d    0:w                              
        mov (16|M0)              r32.0<1>:f    r84.0<1;1,0>:f                   {Compacted,I@3}
        mov (16|M0)              r84.0<1>:f    r72.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L21104                  L22272                
L21104:
        join (16|M0)                         L21168                                
L21120:
        cmp (16|M0)   (eq)f1.0   null<1>:d     r68.0<1;1,0>:d    38:w              
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r66.0<1;1,0>:d    0:w              
(f1.0)  goto (16|M0)                         L21168                  L22184                
L21168:
        join (16|M0)                         L22184                                
L21184:
        add (16|M0)              r2.0<1>:d     -r68.0<1;1,0>:d   39:w               {Compacted}
        and (16|M0)   (ne)f1.0   r16.0<1>:d    r2.0<1;1,0>:d     63:w               {I@1}
        add (16|M0)              r76.0<1>:d    -r68.0<1;1,0>:d   40:w               {Compacted}
(f1.0)  goto (16|M0)                         L21256                  L21256                
L21232:
        mov (16|M0)              r66.0<1>:f    r72.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L21256                  L21368                
L21256:
        join (16|M0)                         L21368                                
L21272:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r16.0<1;1,0>:ud   0x20:uw              {I@5}
(~f1.1) add (16|M0)              r2.0<1>:d     r16.0<1;1,0>:d    -32:w              
(~f1.1) shr (16|M0)              r84.0<1>:ud   r70.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.1)  add (16|M0)              r2.0<1>:d     -r16.0<1;1,0>:d   32:w               {Compacted}
(f1.1)  shr (16|M0)              r10.0<1>:ud   r72.0<1;1,0>:ud   r16.0<1;1,0>:d  
(f1.1)  shl (16|M0)              r2.0<1>:d     r70.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.1)  or (16|M0)               r84.0<1>:d    r10.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@1}
        mov (16|M0)              r66.0<1>:f    r84.0<1;1,0>:f                   {Compacted,I@1}
L21368:
        join (16|M0)                         L22184                                
L21384:
        add (16|M0)              r30.0<1>:d    -r68.0<1;1,0>:d   38:w               {Compacted}
        and (16|M0)   (ne)f1.0   r24.0<1>:d    r30.0<1;1,0>:d    63:w               {I@1}
(f1.0)  goto (16|M0)                         L21448                  L21448                
L21424:
        mov (16|M0)              r84.0<1>:f    r72.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L21448                  L21552                
L21448:
        join (16|M0)                         L21552                                
L21464:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r24.0<1;1,0>:ud   0x20:uw              {I@4}
(~f1.1) add (16|M0)              r2.0<1>:d     r24.0<1;1,0>:d    -32:w              
(~f1.1) shr (16|M0)              r84.0<1>:ud   r70.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.1)  add (16|M0)              r2.0<1>:d     -r24.0<1;1,0>:d   32:w               {Compacted}
(f1.1)  shr (16|M0)              r10.0<1>:ud   r72.0<1;1,0>:ud   r24.0<1;1,0>:d  
(f1.1)  shl (16|M0)              r2.0<1>:d     r70.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.1)  or (16|M0)               r84.0<1>:d    r10.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@1}
L21552:
        join (16|M0)                         L22184                                
L21568:
        and (16|M0)   (ne)f1.0   r82.0<1>:d    r30.0<1;1,0>:d    63:w              
        and (16|M0)              r78.0<1>:d    r84.0<1;1,0>:d    1:w               {Compacted,I@3}
(f1.0)  goto (16|M0)                         L21656                  L21656                
L21608:
        mov (16|M0)              r108.0<1>:d   -1:w                              
        mov (16|M0)              r68.0<1>:d    -1:w                              
        goto (16|M0)                         L21656                  L21840                
L21656:
        join (16|M0)                         L21840                                
L21672:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r82.0<1;1,0>:ud   0x20:uw              {I@7}
(f1.1)  goto (16|M0)                         L21776                  L21776                
L21704:
        add (16|M0)              r2.0<1>:d     r82.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r5.10<1>:hf   -qnan(0x1FF):hf                             
        mov (16|M0)              r108.0<1>:d   0:w                              
        shl (16|M0)              r68.0<1>:d    r5.10<0;1,0>:w    r2.0<1;1,0>:d    {A@1}
        goto (16|M0)                         L21776                  L21840                
L21776:
        join (16|M0)                         L21840                                
L21792:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (16|M0)              r68.0<1>:d    -1:w                              
        shl (16|M0)              r108.0<1>:d   r2.0<0;1,0>:w     r82.0<1;1,0>:d   {F@1}
L21840:
        join (16|M0)                         L22184                                
L21856:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r108.0<1;0>:ud    r4.0<0;0>:ud      r72.0<1>:ud      {I@2} // (s0^s1)&s2
        cmp (16|M0)   (ne)f1.1   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
        bfn.0x60 (16|M0)         r10.0<1>:ud   r68.0<1;0>:ud     r4.0<0;0>:ud      r70.0<1>:ud      // (s0^s1)&s2
(~f1.1) cmp (16|M0)   (ne)f1.1   null<1>:d     r10.0<1;1,0>:d    0:w               {I@1}
(W)     mov (1|M0)               r5.10<1>:hf   -qnan(0x1FF):hf                             
        and (16|M0)   (ne)f1.0   r22.0<1>:d    r76.0<1;1,0>:d    63:w              
(f1.1)  sel (16|M0)              r12.0<1>:d    r5.10<0;1,0>:w    0:w               {F@1}
        mov (16|M0)              r102.0<1>:d   -r12.0<1;1,0>:d                  {I@1}
(f1.0)  goto (16|M0)                         L22024                  L22024                
L22000:
        mov (16|M0)              r84.0<1>:f    r72.0<1;1,0>:f                   {Compacted}
        goto (16|M0)                         L22024                  L22128                
L22024:
        join (16|M0)                         L22128                                
L22040:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r22.0<1;1,0>:ud   0x20:uw             
(~f1.1) add (16|M0)              r2.0<1>:d     r22.0<1;1,0>:d    -32:w              
(~f1.1) shr (16|M0)              r84.0<1>:ud   r70.0<1;1,0>:ud   r2.0<1;1,0>:d    {A@1}
(f1.1)  add (16|M0)              r2.0<1>:d     -r22.0<1;1,0>:d   32:w               {Compacted}
(f1.1)  shr (16|M0)              r10.0<1>:ud   r72.0<1;1,0>:ud   r22.0<1;1,0>:d  
(f1.1)  shl (16|M0)              r2.0<1>:d     r70.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@2}
(f1.1)  or (16|M0)               r84.0<1>:d    r10.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@1}
L22128:
        join (16|M0)                         L22184                                
L22144:
        mov (16|M0)              r32.0<1>:f    r84.0<1;1,0>:f                   {Compacted,I@2}
        mov (16|M0)              r84.0<1>:d    r66.0<1;1,0>:d                   {F@1}
        goto (16|M0)                         L22184                  L22272                
L22184:
        join (16|M0)                         L22272                                
L22200:
        shr (16|M0)              r84.0<1>:ud   r72.0<1;1,0>:ud   2:w              
        mov (16|M0)              r102.0<1>:d   0:w                              
        mov (16|M0)              r78.0<1>:d    0:w                              
        mov (16|M0)              r32.0<1>:f    r84.0<1;1,0>:f                   {Compacted,I@3}
        shr (16|M0)              r84.0<1>:ud   r72.0<1;1,0>:ud   1:w               {F@1}
L22272:
        join (16|M0)                         L22800                                
L22288:
        shl (16|M0)              r2.0<1>:d     r84.0<1;1,0>:d    2:w               {Compacted,I@2}
        shl (16|M0)              r10.0<1>:d    r78.0<1;1,0>:d    1:w               {Compacted}
        and (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     4:w               {Compacted,I@2}
        bfn.0xFE (16|M0)         r126.0<1>:ud  r2.0<1;0>:ud      r10.0<1;0>:ud     r102.0<1>:ud     {I@1} // s0|s1|s2
        cmp (16|M0)   (eq)f1.0   null<1>:d     r126.0<1;1,0>:d   0:w               {I@1}
        and (16|M0)              r36.0<1>:d    r32.0<1;1,0>:d    8388607:d              
(~f1.0) goto (16|M0)                         L22408                  L22408                
L22376:
        mov (16|M0)              r102.0<1>:d   0:w                              
        goto (16|M0)                         L22408                  L22568                
L22408:
        join (16|M0)                         L22568                                
L22424:
        cmp (16|M0)   (gt)f1.1   null<1>:d     r126.0<1;1,0>:ud  0x4:uw             
(~f1.1) goto (16|M0)                         L22488                  L22488                
L22456:
        mov (16|M0)              r102.0<1>:d   1:w                              
        goto (16|M0)                         L22488                  L22568                
L22488:
        join (16|M0)                         L22568                                
L22504:
        and (16|M0)   (ne)f1.0   null<1>:d     r32.0<1;1,0>:d    1:w              
(W)     mov (1|M0)               r2.0<1>:hf    0x1:hf                             
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r126.0<1;1,0>:d   4:w              
(f1.0)  sel (16|M0)              r102.0<1>:d   r2.0<0;1,0>:w     0:w               {F@1}
L22568:
        join (16|M0)                         L22800                                
L22584:
        add (16|M0)              r66.0<1>:d    r36.0<1;1,0>:d    r102.0<1;1,0>:d  {Compacted,I@2}
        cmp (16|M0)   (gt)f1.1   null<1>:d     r66.0<1;1,0>:ud   0x7FFFFF:ud              {I@1}
        add3 (16|M0)             r2.0<1>:d     r74.0<1;0>:d      r100.0<1;0>:d     -45:w              
(f1.1)  sel (16|M0)              r60.0<1>:d    r2.0<1;1,0>:d     r64.0<1;1,0>:d   {Compacted,I@1}
        cmp (16|M0)   (eq)f1.0   null<1>:d     r60.0<1;1,0>:d    255:w               {I@1}
(f1.0)  goto (16|M0)                         L22736                  L22736                
L22664:
(~f1.1) sel (16|M0)              r2.0<1>:d     r66.0<1;1,0>:d    0:w              
        and (16|M0)              r10.0<1>:d    r80.0<1;1,0>:d    -2147483648:d              
        shl (16|M0)              r12.0<1>:d    r60.0<1;1,0>:d    23:w               {Compacted}
        bfn.0xFE (16|M0)         r80.0<1>:ud   r10.0<1;0>:ud     r12.0<1;0>:ud     r2.0<1>:ud       {I@1} // s0|s1|s2
        goto (16|M0)                         L22736                  L23328                
L22736:
        join (16|M0)                         L22800                                
L22752:
        cmp (16|M0)   (gt)f1.0   null<1>:d     r80.0<1;1,0>:d    -1:w               {I@3}
(W)     mov (1|M0)               r2.0<1>:f     inf:f                               {Compacted}
(f1.0)  sel (16|M0)              r80.0<1>:f    r2.0<0;1,0>:f     -inf:f               {Compacted,A@1}
        goto (16|M0)                         L22800                  L23328                
L22800:
        join (16|M0)                         L23112                                
L22816:
        and (16|M0)   (ne)f1.1   r26.0<1>:d    r100.0<1;1,0>:d   63:w              
(f1.1)  goto (16|M0)                         L22880                  L22880                
L22848:
        mov (16|M0)              r78.0<1>:d    -1:w                              
        goto (16|M0)                         L22880                  L23008                
L22880:
        join (16|M0)                         L23008                                
L22896:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r26.0<1;1,0>:ud   0x20:uw              {A@1}
(f1.0)  goto (16|M0)                         L22960                  L22960                
L22928:
        mov (16|M0)              r78.0<1>:d    0:w                              
        goto (16|M0)                         L22960                  L23008                
L22960:
        join (16|M0)                         L23008                                
L22976:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                             
        shl (16|M0)              r78.0<1>:d    r2.0<0;1,0>:w     r26.0<1;1,0>:d   {F@1}
L23008:
        join (16|M0)                         L23112                                
L23024:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r78.0<1;0>:ud     r4.0<0;0>:ud      r72.0<1>:ud      {I@2} // (s0^s1)&s2
        add (16|M0)              r10.0<1>:d    -r100.0<1;1,0>:d  23:w               {Compacted}
        and (16|M0)              r12.0<1>:d    r80.0<1;1,0>:d    -2147483648:d              
        shl (16|M0)              r14.0<1>:d    r64.0<1;1,0>:d    23:w               {Compacted}
        shl (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     r10.0<1;1,0>:d   {Compacted,I@3}
        bfn.0xFE (16|M0)         r80.0<1>:ud   r12.0<1;0>:ud     r14.0<1;0>:ud     r2.0<1>:ud       {I@1} // s0|s1|s2
        goto (16|M0)                         L23112                  L23328                
L23112:
        join (16|M0)                         L23176                                
L23128:
        cmp (16|M0)   (gt)f1.1   null<1>:d     r80.0<1;1,0>:d    -1:w               {I@3}
(W)     mov (1|M0)               r2.0<1>:f     inf:f                               {Compacted}
(f1.1)  sel (16|M0)              r80.0<1>:f    r2.0<0;1,0>:f     -inf:f               {Compacted,A@1}
        goto (16|M0)                         L23176                  L23328                
L23176:
        join (16|M0)                         L23232                                
L23192:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r80.0<1;1,0>:d    0:w               {Compacted,F@1}
(W)     mov (1|M0)               r2.0<1>:f     -0.0:f                               {Compacted}
(f1.0)  sel (16|M0)              r80.0<1>:f    r2.0<0;1,0>:f     0.0:f               {Compacted,A@1}
        goto (16|M0)                         L23232                  L23328                
L23232:
        join (16|M0)                         L23296                                
L23248:
        cmp (16|M0)   (gt)f1.1   null<1>:d     r80.0<1;1,0>:d    -1:w               {F@1}
(W)     mov (1|M0)               r2.0<1>:f     inf:f                               {Compacted}
(f1.1)  sel (16|M0)              r80.0<1>:f    r2.0<0;1,0>:f     -inf:f               {Compacted,A@1}
        goto (16|M0)                         L23296                  L23328                
L23296:
        join (16|M0)                         L23328                                
L23312:
        bfn.0xF8 (16|M0)         r80.0<1>:ud   r80.0<1;0>:ud     r4.2<0;0>:ud      r4.1<0>:ud       {F@1} // s0&s1|s2
L23328:
        join (16|M0)                         L29800                                
L23344:
        rnde (16|M0)             r124.0<1>:f   r80.0<1;1,0>:f                   {Compacted,I@2}
        shr (16|M0)              r76.0<1>:ud   r124.0<1;1,0>:ud  23:w               {F@1}
        and (16|M0)   (ne)f1.1   r106.0<1>:d   r124.0<1;1,0>:d   8388607:d              
        and (16|M0)              r88.0<1>:d    r76.0<1;1,0>:d    255:w               {Compacted,I@2}
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r88.0<1;1,0>:d    255:w               {I@1}
(~f1.1) goto (16|M0)                         L23456                  L23456                
L23424:
        mov (16|M0)              r76.0<1>:ud   0x7FC00000:ud                             
        goto (16|M0)                         L23456                  L29488                
L23456:
        join (16|M0)                         L29488                                
L23472:
        cmp (16|M0)   (eq)f1.1   null<1>:d     r106.0<1;1,0>:d   0:w              
        add (16|M0)              r2.0<1>:d     r62.0<1;1,0>:d    -25165824:d              
        shr (16|M0)              r70.0<1>:ud   r2.0<1;1,0>:ud    23:w               {I@1}
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r88.0<1;1,0>:d    255:w              
        and (16|M0)              r126.0<1>:d   r70.0<1;1,0>:d    255:w               {Compacted,I@2}
(~f1.1) cmp (16|M0)   (eq)f1.1   null<1>:d     r126.0<1;1,0>:d   255:w               {I@1}
        xor (16|M0)              r124.0<1>:d   r2.0<1;1,0>:d     r124.0<1;1,0>:d  {Compacted}
(f1.1)  goto (16|M0)                         L29456                  L29456                
L23584:
        cmp (16|M0)   (eq)f1.0   null<1>:d     r126.0<1;1,0>:d   0:w              
        or (16|M0)               r2.0<1>:d     r88.0<1;1,0>:d    r106.0<1;1,0>:d  {Compacted}
(~f1.0) cmp (16|M0)   (eq)f1.0   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
(~f1.0) goto (16|M0)                         L23672                  L23672                
L23640:
        mov (16|M0)              r76.0<1>:ud   0x0:ud                             
        goto (16|M0)                         L23672                  L29488                
L23672:
        join (16|M0)                         L29456                                
L23688:
        cmp (16|M0)   (eq)f1.0   null<1>:d     r88.0<1;1,0>:d    0:w              
        add (16|M0)              r122.0<1>:d   r88.0<1;1,0>:d    -127:w               {Compacted}
(f1.0)  mov (16|M0)              r122.0<1>:d   -126:w                              
        add (16|M0)              r120.0<1>:d   r126.0<1;1,0>:d   r122.0<1;1,0>:d  {Compacted,I@1}
        cmp (16|M0)   (gt)f1.1   null<1>:d     r120.0<1;1,0>:d   254:w               {I@1}
(f1.1)  goto (16|M0)                         L29392                  L29392                
L23768:
        or (16|M0)    (eq)f1.1   null<4>:b     r76.0<1;1,0>:d    r70.0<1;1,0>:d  
(f1.1)  goto (16|M0)                         L29336                  L29336                
L23800:
(W)     mov (1|M0)               r2.0<1>:hf    0.0:hf                             
(W)     mov (1|M0)               r99.3<1>:d    0:w                              
(f1.0)  sel (16|M0)              r10.0<1>:d    r2.0<0;1,0>:w     8388608:d               {F@1}
        or (16|M0)               r10.0<1>:d    r10.0<1;1,0>:d    r106.0<1;1,0>:d  {Compacted,I@1}
        shl (16|M0)              r118.0<1>:d   r10.0<1;1,0>:d    23:w               {Compacted,I@1}
        shr (16|M0)              r116.0<1>:ud  r10.0<1;1,0>:ud   9:w              
(W)     mov (1|M0)               r99.2<1>:f    -0.0:f                               {Compacted}
(W)     mov (2|M0)               r99.4<1>:d    0:w                              
L23904:
(W)     shl (1|M0)               r2.0<1>:d     r99.2<0;1,0>:d    31:w               {Compacted,F@1}
(W)     shr (1|M0)               r2.1<1>:ud    r99.3<0;1,0>:ud   1:w              
(W)     cmp (16|M0)   (gt)f1.0   null<1>:d     r99.4<0;1,0>:ud   0x3E:uw              {I@3}
(W)     or (1|M0)                r99.3<1>:d    r2.1<0;1,0>:d     r2.0<0;1,0>:d    {I@2}
        bfn.0xE0 (16|M0)         r10.0<1>:ud   r2.1<0;0>:ud      r2.0<0;0>:ud      r118.0<1>:ud     // (s0|s1)&s2
(W)     shr (1|M0)               r99.1<1>:ud   r99.2<0;1,0>:ud   1:w              
(W&f1.0) cmp (16|M0)  (eq)f1.0   null<1>:d     r99.5<0;1,0>:d    0:w              
        cmp (16|M0)   (eq)f1.1   null<1>:d     r10.0<1;1,0>:d    r99.3<0;1,0>:d   {I@3}
        sync.nop                             null                             {Compacted,$6.src}
        and (16|M0)              r12.0<1>:d    r99.1<0;1,0>:d    r116.0<1;1,0>:d  {Compacted,I@3}
(W&~f1.0) cmp (16|M0) (gt)f1.0   null<1>:d     r99.5<0;1,0>:ud   0x0:uw             
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r12.0<1;1,0>:d    r99.1<0;1,0>:d   {I@2}
(W)     mov (1|M0)               r5.10<1>:hf   0x1:hf                             
(W)     addc (1|M0)              r15.0<1>:ud   r99.4<0;1,0>:ud   0x1:ud              {AccWrEn}
(f1.0)  sel (16|M0)              r9.0<1>:uw    r5.10<0;1,0>:uw   0x0:uw              {Compacted,F@1}
(f1.1)  sel (16|M0)              acc2.0<1>:uw  r5.10<0;1,0>:uw   0x0:uw             
(W)     mov (1|M0)               r3.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        or (16|M0)    (ne)f1.1   null<1>:uw    r9.0<1;1,0>:uw    acc2.0<1;1,0>:uw {I@3}
(W)     add (1|M0)               r99.6<1>:ud   r3.0<0;1,0>:ud    r99.5<0;1,0>:ud  {I@2}
        mov (16|M0)              r36.0<1>:d    r99.4<0;1,0>:d                  
        mov (16|M0)              r34.0<1>:d    r99.5<0;1,0>:d                  
        mov (16|M0)              r114.0<1>:f   r15.0<0;1,0>:f                   {Compacted}
        mov (16|M0)              r112.0<1>:d   r99.6<0;1,0>:d                   {I@3}
(f1.1)  goto (16|M0)                         L24304                  L24304                
L24240:
(W)     mov (1|M0)               r99.2<1>:d    r99.1<0;1,0>:d                  
(W)     mov (1|M0)               r99.4<1>:d    r15.0<0;1,0>:d                  
(W)     mov (1|M0)               r99.5<1>:d    r99.6<0;1,0>:d                  
(W)     jmpi                                 L23904                                
L24304:
        join (16|M0)                         L29336                                
L24320:
(W)     mov (1|M0)               r2.0<1>:f     8.68805e-44:f                              
(W)     mov (1|M0)               r3.0<1>:hf    0.0:hf                             
        subb (8|M0)              r32.0<1>:ud   r2.0<0;1,0>:ud    r36.0<1;1,0>:ud  {AccWrEn,Compacted,A@2}
        add3 (8|M0)              r10.0<1>:ud   -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r34.0<1>:ud     {A@1}
        subb (8|M8)              r33.0<1>:ud   r2.0<0;1,0>:ud    r37.0<1;1,0>:ud  {AccWrEn}
        add3 (16|M0)             r20.0<1>:d    r120.0<1;0>:d     r32.0<1;0>:d      -173:w               {I@1}
        cmp (16|M0)   (gt)f1.1   null<1>:d     r20.0<1;1,0>:d    127:w               {I@1}
        add3 (8|M8)              r11.0<1>:ud   -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r35.0<1>:ud    
        add3 (16|M0)             r28.0<1>:d    r126.0<1;0>:d     r122.0<1;0>:d     r32.0<1>:d      
(f1.1)  goto (16|M0)                         L29272                  L29272                
L24472:
        cmp (16|M0)   (gt)f1.0   null<1>:d     r20.0<1;1,0>:d    -127:w              
(f1.0)  goto (16|M0)                         L26952                  L26952                
L24504:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r20.0<1;1,0>:ud   0xFFFFFF6B:ud             
(f1.1)  goto (16|M0)                         L26448                  L26448                
L24536:
(W)     mov (1|M0)               r2.0<1>:f     8.82818e-44:f                              
(W)     mov (1|M0)               r3.0<1>:hf    0.0:hf                              {I@7}
        subb (8|M0)              r92.0<1>:ud   r2.0<0;1,0>:ud    r36.0<1;1,0>:ud  {AccWrEn,Compacted,F@2}
        add3 (16|M0)             r94.0<1>:d    r120.0<1;0>:d     r32.0<1;0>:d      -23:w              
        add3 (8|M0)              r10.0<1>:ud   -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r34.0<1>:ud     {F@1}
        subb (8|M8)              r93.0<1>:ud   r2.0<0;1,0>:ud    r37.0<1;1,0>:ud  {AccWrEn}
        cmp (16|M0)   (gt)f1.0   null<1>:d     r92.0<1;1,0>:ud   r94.0<1;1,0>:ud  {I@1}
        add3 (8|M8)              r11.0<1>:ud   -acc0.0<1;0>:ud   r3.0<0;0>:uw      -r35.0<1>:ud    
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r10.0<1;1,0>:d    0:w               {I@1}
(~f1.0) cmp (16|M0)   (gt)f1.0   null<1>:d     r10.0<1;1,0>:ud   0x0:uw             
(f1.0)  goto (16|M0)                         L24760                  L24760                
L24704:
        add3 (16|M0)             r2.0<1>:d     r28.0<1;0>:d      -r92.0<1;0>:d     -23:w              
        mov (16|M0)              r10.0<1>:d    0:w                              
        shl (16|M0)              r12.0<1>:d    r118.0<1;1,0>:d   r2.0<1;1,0>:d    {Compacted,I@2}
        goto (16|M0)                         L24760                  L26384                
L24760:
        join (16|M0)                         L26384                                
L24776:
        add3 (16|M0)             r90.0<1>:d    r92.0<1;0>:d      -r28.0<1;0>:d     23:w              
        cmp (16|M0)   (lt)f1.0   null<1>:d     r90.0<1;1,0>:d    2:w               {Compacted,I@1}
(f1.0)  goto (16|M0)                         L24920                  L24920                
L24816:
        cmp (16|M0)   (eq)f1.1   null<1>:d     r90.0<1;1,0>:d    2:w              
(~f1.1) goto (16|M0)                         L24920                  L24968                
L24848:
        shr (16|M0)              r18.0<1>:ud   r118.0<1;1,0>:ud  1:w              
        mov (16|M0)              r60.0<1>:d    0:w                              
        mov (16|M0)              r126.0<1>:d   0:w                              
        mov (16|M0)              r104.0<1>:f   r18.0<1;1,0>:f                   {Compacted,I@3}
        goto (16|M0)                         L24920                  L25856                
L24920:
        join (16|M0)                         L24968                                
L24936:
        cmp (16|M0)   (eq)f1.0   null<1>:d     r90.0<1;1,0>:d    1:w              
(f1.0)  goto (16|M0)                         L24968                  L25800                
L24968:
        join (16|M0)                         L25800                                
L24984:
        add3 (16|M0)             r2.0<1>:d     r92.0<1;0>:d      -r94.0<1;0>:d     -1:w              
        and (16|M0)   (ne)f1.1   r102.0<1>:d   r2.0<1;1,0>:d     63:w               {I@1}
(f1.1)  goto (16|M0)                         L25056                  L25056                
L25032:
        mov (16|M0)              r88.0<1>:f    r118.0<1;1,0>:f                  {Compacted}
        goto (16|M0)                         L25056                  L25168                
L25056:
        join (16|M0)                         L25168                                
L25072:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r102.0<1;1,0>:ud  0x20:uw              {I@4}
(~f1.0) add (16|M0)              r2.0<1>:d     r102.0<1;1,0>:d   -32:w              
(~f1.0) shr (16|M0)              r18.0<1>:ud   r116.0<1;1,0>:ud  r2.0<1;1,0>:d    {A@1}
(f1.0)  add (16|M0)              r2.0<1>:d     -r102.0<1;1,0>:d  32:w               {Compacted}
(f1.0)  shr (16|M0)              r10.0<1>:ud   r118.0<1;1,0>:ud  r102.0<1;1,0>:d 
(f1.0)  shl (16|M0)              r2.0<1>:d     r116.0<1;1,0>:d   r2.0<1;1,0>:d    {Compacted,I@2}
(f1.0)  or (16|M0)               r18.0<1>:d    r10.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@1}
        mov (16|M0)              r88.0<1>:f    r18.0<1;1,0>:f                   {Compacted,I@1}
L25168:
        join (16|M0)                         L25800                                
L25184:
        add3 (16|M0)             r86.0<1>:d    r92.0<1;0>:d      -r94.0<1;0>:d     -2:w              
        and (16|M0)   (ne)f1.1   r100.0<1>:d   r86.0<1;1,0>:d    63:w               {I@1}
(f1.1)  goto (16|M0)                         L25256                  L25256                
L25232:
        mov (16|M0)              r18.0<1>:f    r118.0<1;1,0>:f                  {Compacted}
        goto (16|M0)                         L25256                  L25360                
L25256:
        join (16|M0)                         L25360                                
L25272:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r100.0<1;1,0>:ud  0x20:uw              {I@4}
(~f1.0) add (16|M0)              r2.0<1>:d     r100.0<1;1,0>:d   -32:w              
(~f1.0) shr (16|M0)              r18.0<1>:ud   r116.0<1;1,0>:ud  r2.0<1;1,0>:d    {A@1}
(f1.0)  add (16|M0)              r2.0<1>:d     -r100.0<1;1,0>:d  32:w               {Compacted}
(f1.0)  shr (16|M0)              r10.0<1>:ud   r118.0<1;1,0>:ud  r100.0<1;1,0>:d 
(f1.0)  shl (16|M0)              r2.0<1>:d     r116.0<1;1,0>:d   r2.0<1;1,0>:d    {Compacted,I@2}
(f1.0)  or (16|M0)               r18.0<1>:d    r10.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@1}
L25360:
        join (16|M0)                         L25800                                
L25376:
        and (16|M0)   (ne)f1.1   r122.0<1>:d   r86.0<1;1,0>:d    63:w              
        and (16|M0)              r126.0<1>:d   r18.0<1;1,0>:d    1:w               {Compacted,I@3}
(f1.1)  goto (16|M0)                         L25464                  L25464                
L25416:
        mov (16|M0)              r18.0<1>:d    -1:w                              
        mov (16|M0)              r28.0<1>:d    -1:w                              
        goto (16|M0)                         L25464                  L25648                
L25464:
        join (16|M0)                         L25648                                
L25480:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r122.0<1;1,0>:ud  0x20:uw              {I@7}
(f1.0)  goto (16|M0)                         L25584                  L25584                
L25512:
        add (16|M0)              r2.0<1>:d     r122.0<1;1,0>:d   -32:w               {Compacted}
(W)     mov (1|M0)               r5.10<1>:hf   -qnan(0x1FF):hf                             
        mov (16|M0)              r18.0<1>:d    0:w                              
        shl (16|M0)              r28.0<1>:d    r5.10<0;1,0>:w    r2.0<1;1,0>:d    {A@1}
        goto (16|M0)                         L25584                  L25648                
L25584:
        join (16|M0)                         L25648                                
L25600:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (16|M0)              r28.0<1>:d    -1:w                              
        shl (16|M0)              r18.0<1>:d    r2.0<0;1,0>:w     r122.0<1;1,0>:d  {F@1}
L25648:
        join (16|M0)                         L25800                                
L25664:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r18.0<1;0>:ud     r4.0<0;0>:ud      r118.0<1>:ud     {I@2} // (s0^s1)&s2
        cmp (16|M0)   (ne)f1.1   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
        bfn.0x60 (16|M0)         r10.0<1>:ud   r28.0<1;0>:ud     r4.0<0;0>:ud      r116.0<1>:ud     // (s0^s1)&s2
(~f1.1) cmp (16|M0)   (ne)f1.1   null<1>:d     r10.0<1;1,0>:d    0:w               {I@1}
(W)     mov (1|M0)               r5.10<1>:hf   -qnan(0x1FF):hf                             
        mov (16|M0)              r104.0<1>:f   r88.0<1;1,0>:f                   {Compacted}
(f1.1)  sel (16|M0)              r12.0<1>:d    r5.10<0;1,0>:w    0:w               {F@2}
        mov (16|M0)              r60.0<1>:d    -r12.0<1;1,0>:d                  {I@1}
        goto (16|M0)                         L25800                  L25856                
L25800:
        join (16|M0)                         L25856                                
L25816:
        mov (16|M0)              r60.0<1>:d    0:w                              
        mov (16|M0)              r126.0<1>:d   0:w                              
        mov (16|M0)              r104.0<1>:f   r118.0<1;1,0>:f                  {Compacted}
L25856:
        join (16|M0)                         L26384                                
L25872:
        and (16|M0)   (ne)f1.1   r96.0<1>:d    r90.0<1;1,0>:d    63:w              
(f1.1)  goto (16|M0)                         L25928                  L25928                
L25904:
        mov (16|M0)              r18.0<1>:f    r118.0<1;1,0>:f                  {Compacted}
        goto (16|M0)                         L25928                  L26032                
L25928:
        join (16|M0)                         L26032                                
L25944:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r96.0<1;1,0>:ud   0x20:uw              {I@4}
(~f1.0) add (16|M0)              r2.0<1>:d     r96.0<1;1,0>:d    -32:w              
(~f1.0) shr (16|M0)              r18.0<1>:ud   r116.0<1;1,0>:ud  r2.0<1;1,0>:d    {A@1}
(f1.0)  add (16|M0)              r2.0<1>:d     -r96.0<1;1,0>:d   32:w               {Compacted}
(f1.0)  shr (16|M0)              r10.0<1>:ud   r118.0<1;1,0>:ud  r96.0<1;1,0>:d  
(f1.0)  shl (16|M0)              r2.0<1>:d     r116.0<1;1,0>:d   r2.0<1;1,0>:d    {Compacted,I@2}
(f1.0)  or (16|M0)               r18.0<1>:d    r10.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@1}
L26032:
        join (16|M0)                         L26384                                
L26048:
        shl (16|M0)              r2.0<1>:d     r104.0<1;1,0>:d   2:w               {Compacted}
        shl (16|M0)              r10.0<1>:d    r126.0<1;1,0>:d   1:w               {Compacted}
        and (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     4:w               {Compacted,I@2}
        bfn.0xFE (16|M0)         r28.0<1>:ud   r2.0<1;0>:ud      r10.0<1;0>:ud     r60.0<1>:ud      {I@1} // s0|s1|s2
        cmp (16|M0)   (eq)f1.1   null<1>:d     r28.0<1;1,0>:d    0:w               {I@1}
(~f1.1) goto (16|M0)                         L26152                  L26152                
L26120:
        mov (16|M0)              r34.0<1>:d    0:w                              
        goto (16|M0)                         L26152                  L26312                
L26152:
        join (16|M0)                         L26312                                
L26168:
        cmp (16|M0)   (gt)f1.0   null<1>:d     r28.0<1;1,0>:ud   0x4:uw             
(~f1.0) goto (16|M0)                         L26232                  L26232                
L26200:
        mov (16|M0)              r34.0<1>:d    1:w                              
        goto (16|M0)                         L26232                  L26312                
L26232:
        join (16|M0)                         L26312                                
L26248:
        and (16|M0)   (ne)f1.0   null<1>:d     r18.0<1;1,0>:d    1:w              
(W)     mov (1|M0)               r2.0<1>:hf    0x1:hf                             
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r28.0<1;1,0>:d    4:w              
(f1.0)  sel (16|M0)              r34.0<1>:d    r2.0<0;1,0>:w     0:w               {F@1}
L26312:
        join (16|M0)                         L26384                                
L26328:
        add (16|M0)              r2.0<1>:d     r34.0<1;1,0>:d    r18.0<1;1,0>:d   {Compacted,I@2}
        cmp (16|M0)   (gt)f1.1   null<1>:d     r2.0<1;1,0>:ud    0x7FFFFF:ud              {I@1}
(W)     mov (1|M0)               r5.5<1>:f     0x800000:f                               {Compacted}
(~f1.1) sel (16|M0)              r12.0<1>:d    r2.0<1;1,0>:d     0:w              
(f1.1)  sel (16|M0)              r10.0<1>:d    r5.5<0;1,0>:d     0:w               {Compacted,F@1}
L26384:
        join (16|M0)                         L26448                                
L26400:
        and (16|M0)              r2.0<1>:d     r124.0<1;1,0>:d   -2147483648:d              
        bfn.0xFE (16|M0)         r76.0<1>:ud   r2.0<1;0>:ud      r10.0<1;0>:ud     r12.0<1>:ud      {I@1} // s0|s1|s2
        goto (16|M0)                         L26448                  L29488                
L26448:
        join (16|M0)                         L26952                                
L26464:
        and (16|M0)   (ne)f1.1   r76.0<1>:d    r32.0<1;1,0>:d    63:w              
(f1.1)  goto (16|M0)                         L26544                  L26544                
L26496:
        mov (16|M0)              r100.0<1>:d   -1:w                              
        mov (16|M0)              r120.0<1>:d   -1:w                              
        goto (16|M0)                         L26544                  L26728                
L26544:
        join (16|M0)                         L26728                                
L26560:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r76.0<1;1,0>:ud   0x20:uw              {I@6}
(f1.0)  goto (16|M0)                         L26664                  L26664                
L26592:
        add (16|M0)              r2.0<1>:d     r76.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r5.10<1>:hf   -qnan(0x1FF):hf                             
        mov (16|M0)              r100.0<1>:d   0:w                              
        shl (16|M0)              r120.0<1>:d   r5.10<0;1,0>:w    r2.0<1;1,0>:d    {A@1}
        goto (16|M0)                         L26664                  L26728                
L26664:
        join (16|M0)                         L26728                                
L26680:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (16|M0)              r120.0<1>:d   -1:w                              
        shl (16|M0)              r100.0<1>:d   r2.0<0;1,0>:w     r76.0<1;1,0>:d   {F@1}
L26728:
        join (16|M0)                         L26952                                
L26744:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r100.0<1;0>:ud    r4.0<0;0>:ud      r118.0<1>:ud     {I@2} // (s0^s1)&s2
        cmp (16|M0)   (ne)f1.0   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
        bfn.0x60 (16|M0)         r10.0<1>:ud   r120.0<1;0>:ud    r4.0<0;0>:ud      r116.0<1>:ud     // (s0^s1)&s2
        cmp (16|M0)   (gt)f1.1   null<1>:d     r124.0<1;1,0>:d   -1:w              
(~f1.0) cmp (16|M0)   (ne)f1.0   null<1>:d     r10.0<1;1,0>:d    0:w               {I@2}
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r20.0<1;1,0>:d    -150:w              
(f1.1)  goto (16|M0)                         L26896                  L26896                
L26856:
(W)     mov (1|M0)               r2.0<1>:ud    0x80000001:ud                             
(f1.0)  sel (16|M0)              r76.0<1>:f    r2.0<0;1,0>:f     -0.0:f               {Compacted,I@1}
        goto (16|M0)                         L26896                  L29488                
L26896:
        join (16|M0)                         L26952                                
L26912:
(W)     mov (1|M0)               r2.0<1>:ud    0x1:ud                              {F@1}
(f1.0)  sel (16|M0)              r76.0<1>:f    r2.0<0;1,0>:f     0.0:f               {Compacted,I@1}
        goto (16|M0)                         L26952                  L29488                
L26952:
        join (16|M0)                         L29272                                
L26968:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r32.0<1;1,0>:ud   0x18:uw             
        add3 (16|M0)             r94.0<1>:d    r120.0<1;0>:d     r32.0<1;0>:d      -46:w              
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r10.0<1;1,0>:d    0:w              
(f1.1)  goto (16|M0)                         L28960                  L28960                
L27032:
        shl (16|M0)              r2.0<1>:d     r114.0<1;1,0>:d   1:w               {Compacted,F@1}
        shr (16|M0)              r10.0<1>:ud   r114.0<1;1,0>:ud  31:w              
        shl (16|M0)              r12.0<1>:d    r112.0<1;1,0>:d   1:w               {Compacted}
        cmp (16|M0)   (lt)f1.1   null<1>:d     r2.0<1;1,0>:ud    0x4E:uw              {I@3}
        or (16|M0)               r12.0<1>:d    r12.0<1;1,0>:d    r10.0<1;1,0>:d   {Compacted,I@2}
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r12.0<1;1,0>:d    0:w               {I@1}
(~f1.1) cmp (16|M0)   (lt)f1.1   null<1>:d     r12.0<1;1,0>:d    0:w              
(f1.1)  goto (16|M0)                         L27264                  L27264                
L27136:
        cmp (16|M0)   (eq)f1.0   null<1>:d     r114.0<1;1,0>:d   39:w              
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r112.0<1;1,0>:d   0:w              
(~f1.0) goto (16|M0)                         L27264                  L27328                
L27184:
        shr (16|M0)              r18.0<1>:ud   r118.0<1;1,0>:ud  1:w              
        mov (16|M0)              r26.0<1>:d    0:w                              
        mov (16|M0)              r112.0<1>:d   0:w                              
        mov (16|M0)              r86.0<1>:f    r18.0<1;1,0>:f                   {Compacted,I@3}
        mov (16|M0)              r18.0<1>:f    r118.0<1;1,0>:f                  {Compacted}
        goto (16|M0)                         L27264                  L28432                
L27264:
        join (16|M0)                         L27328                                
L27280:
        cmp (16|M0)   (eq)f1.1   null<1>:d     r114.0<1;1,0>:d   38:w              
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r112.0<1;1,0>:d   0:w               {I@4}
(f1.1)  goto (16|M0)                         L27328                  L28344                
L27328:
        join (16|M0)                         L28344                                
L27344:
        add (16|M0)              r2.0<1>:d     -r114.0<1;1,0>:d  39:w               {Compacted}
        and (16|M0)   (ne)f1.0   r122.0<1>:d   r2.0<1;1,0>:d     63:w               {I@1}
        add (16|M0)              r100.0<1>:d   -r114.0<1;1,0>:d  40:w               {Compacted}
(f1.0)  goto (16|M0)                         L27416                  L27416                
L27392:
        mov (16|M0)              r96.0<1>:f    r118.0<1;1,0>:f                  {Compacted}
        goto (16|M0)                         L27416                  L27528                
L27416:
        join (16|M0)                         L27528                                
L27432:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r122.0<1;1,0>:ud  0x20:uw              {I@5}
(~f1.1) add (16|M0)              r2.0<1>:d     r122.0<1;1,0>:d   -32:w              
(~f1.1) shr (16|M0)              r18.0<1>:ud   r116.0<1;1,0>:ud  r2.0<1;1,0>:d    {A@1}
(f1.1)  add (16|M0)              r2.0<1>:d     -r122.0<1;1,0>:d  32:w               {Compacted}
(f1.1)  shr (16|M0)              r10.0<1>:ud   r118.0<1;1,0>:ud  r122.0<1;1,0>:d 
(f1.1)  shl (16|M0)              r2.0<1>:d     r116.0<1;1,0>:d   r2.0<1;1,0>:d    {Compacted,I@2}
(f1.1)  or (16|M0)               r18.0<1>:d    r10.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@1}
        mov (16|M0)              r96.0<1>:f    r18.0<1;1,0>:f                   {Compacted,I@1}
L27528:
        join (16|M0)                         L28344                                
L27544:
        add (16|M0)              r84.0<1>:d    -r114.0<1;1,0>:d  38:w               {Compacted}
        and (16|M0)   (ne)f1.0   r14.0<1>:d    r84.0<1;1,0>:d    63:w               {I@1}
(f1.0)  goto (16|M0)                         L27608                  L27608                
L27584:
        mov (16|M0)              r18.0<1>:f    r118.0<1;1,0>:f                  {Compacted}
        goto (16|M0)                         L27608                  L27712                
L27608:
        join (16|M0)                         L27712                                
L27624:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r14.0<1;1,0>:ud   0x20:uw              {I@4}
(~f1.1) add (16|M0)              r2.0<1>:d     r14.0<1;1,0>:d    -32:w              
(~f1.1) shr (16|M0)              r18.0<1>:ud   r116.0<1;1,0>:ud  r2.0<1;1,0>:d    {A@1}
(f1.1)  add (16|M0)              r2.0<1>:d     -r14.0<1;1,0>:d   32:w               {Compacted}
(f1.1)  shr (16|M0)              r10.0<1>:ud   r118.0<1;1,0>:ud  r14.0<1;1,0>:d  
(f1.1)  shl (16|M0)              r2.0<1>:d     r116.0<1;1,0>:d   r2.0<1;1,0>:d    {Compacted,I@2}
(f1.1)  or (16|M0)               r18.0<1>:d    r10.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@1}
L27712:
        join (16|M0)                         L28344                                
L27728:
        and (16|M0)   (ne)f1.0   r36.0<1>:d    r84.0<1;1,0>:d    63:w              
        and (16|M0)              r112.0<1>:d   r18.0<1;1,0>:d    1:w               {Compacted,I@3}
(f1.0)  goto (16|M0)                         L27816                  L27816                
L27768:
        mov (16|M0)              r68.0<1>:d    -1:w                              
        mov (16|M0)              r102.0<1>:d   -1:w                              
        goto (16|M0)                         L27816                  L28000                
L27816:
        join (16|M0)                         L28000                                
L27832:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r36.0<1;1,0>:ud   0x20:uw              {I@7}
(f1.1)  goto (16|M0)                         L27936                  L27936                
L27864:
        add (16|M0)              r2.0<1>:d     r36.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r5.10<1>:hf   -qnan(0x1FF):hf                             
        mov (16|M0)              r68.0<1>:d    0:w                              
        shl (16|M0)              r102.0<1>:d   r5.10<0;1,0>:w    r2.0<1;1,0>:d    {A@1}
        goto (16|M0)                         L27936                  L28000                
L27936:
        join (16|M0)                         L28000                                
L27952:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (16|M0)              r102.0<1>:d   -1:w                              
        shl (16|M0)              r68.0<1>:d    r2.0<0;1,0>:w     r36.0<1;1,0>:d   {F@1}
L28000:
        join (16|M0)                         L28344                                
L28016:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r68.0<1;0>:ud     r4.0<0;0>:ud      r118.0<1>:ud     {I@2} // (s0^s1)&s2
        cmp (16|M0)   (ne)f1.0   null<1>:d     r2.0<1;1,0>:d     0:w               {I@1}
        bfn.0x60 (16|M0)         r10.0<1>:ud   r102.0<1;0>:ud    r4.0<0;0>:ud      r116.0<1>:ud     // (s0^s1)&s2
(~f1.0) cmp (16|M0)   (ne)f1.0   null<1>:d     r10.0<1;1,0>:d    0:w               {I@1}
(W)     mov (1|M0)               r5.10<1>:hf   -qnan(0x1FF):hf                             
(f1.0)  sel (16|M0)              r12.0<1>:d    r5.10<0;1,0>:w    0:w               {F@1}
        mov (16|M0)              r26.0<1>:d    -r12.0<1;1,0>:d                  {I@1}
        and (16|M0)   (ne)f1.0   r12.0<1>:d    r100.0<1;1,0>:d   63:w              
(f1.0)  goto (16|M0)                         L28184                  L28184                
L28160:
        mov (16|M0)              r18.0<1>:f    r118.0<1;1,0>:f                  {Compacted}
        goto (16|M0)                         L28184                  L28288                
L28184:
        join (16|M0)                         L28288                                
L28200:
        cmp (16|M0)   (lt)f1.1   null<1>:d     r12.0<1;1,0>:ud   0x20:uw              {I@4}
(~f1.1) add (16|M0)              r2.0<1>:d     r12.0<1;1,0>:d    -32:w              
(~f1.1) shr (16|M0)              r18.0<1>:ud   r116.0<1;1,0>:ud  r2.0<1;1,0>:d    {A@1}
(f1.1)  add (16|M0)              r2.0<1>:d     -r12.0<1;1,0>:d   32:w               {Compacted}
(f1.1)  shr (16|M0)              r10.0<1>:ud   r118.0<1;1,0>:ud  r12.0<1;1,0>:d  
(f1.1)  shl (16|M0)              r2.0<1>:d     r116.0<1;1,0>:d   r2.0<1;1,0>:d    {Compacted,I@2}
(f1.1)  or (16|M0)               r18.0<1>:d    r10.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@1}
L28288:
        join (16|M0)                         L28344                                
L28304:
        mov (16|M0)              r86.0<1>:f    r18.0<1;1,0>:f                   {Compacted,I@2}
        mov (16|M0)              r18.0<1>:d    r96.0<1;1,0>:d                   {F@1}
        goto (16|M0)                         L28344                  L28432                
L28344:
        join (16|M0)                         L28432                                
L28360:
        shr (16|M0)              r18.0<1>:ud   r118.0<1;1,0>:ud  2:w              
        mov (16|M0)              r26.0<1>:d    0:w                              
        mov (16|M0)              r112.0<1>:d   0:w                              
        mov (16|M0)              r86.0<1>:f    r18.0<1;1,0>:f                   {Compacted,I@3}
        shr (16|M0)              r18.0<1>:ud   r118.0<1;1,0>:ud  1:w               {F@1}
L28432:
        join (16|M0)                         L28960                                
L28448:
        shl (16|M0)              r2.0<1>:d     r18.0<1;1,0>:d    2:w               {Compacted,I@2}
        shl (16|M0)              r10.0<1>:d    r112.0<1;1,0>:d   1:w               {Compacted}
        and (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     4:w               {Compacted,I@2}
        bfn.0xFE (16|M0)         r96.0<1>:ud   r2.0<1;0>:ud      r10.0<1;0>:ud     r26.0<1>:ud      {I@1} // s0|s1|s2
        cmp (16|M0)   (eq)f1.0   null<1>:d     r96.0<1;1,0>:d    0:w               {I@1}
        and (16|M0)              r34.0<1>:d    r86.0<1;1,0>:d    8388607:d              
(~f1.0) goto (16|M0)                         L28568                  L28568                
L28536:
        mov (16|M0)              r74.0<1>:d    0:w                              
        goto (16|M0)                         L28568                  L28728                
L28568:
        join (16|M0)                         L28728                                
L28584:
        cmp (16|M0)   (gt)f1.1   null<1>:d     r96.0<1;1,0>:ud   0x4:uw             
(~f1.1) goto (16|M0)                         L28648                  L28648                
L28616:
        mov (16|M0)              r74.0<1>:d    1:w                              
        goto (16|M0)                         L28648                  L28728                
L28648:
        join (16|M0)                         L28728                                
L28664:
        and (16|M0)   (ne)f1.1   null<1>:d     r86.0<1;1,0>:d    1:w              
(W)     mov (1|M0)               r2.0<1>:hf    0x1:hf                             
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r96.0<1;1,0>:d    4:w              
(f1.1)  sel (16|M0)              r74.0<1>:d    r2.0<0;1,0>:w     0:w               {F@1}
L28728:
        join (16|M0)                         L28960                                
L28744:
        add (16|M0)              r38.0<1>:d    r34.0<1;1,0>:d    r74.0<1;1,0>:d   {Compacted,I@2}
        cmp (16|M0)   (gt)f1.1   null<1>:d     r38.0<1;1,0>:ud   0x7FFFFF:ud              {I@1}
        add3 (16|M0)             r2.0<1>:d     r120.0<1;0>:d     r32.0<1;0>:d      -45:w              
(f1.1)  sel (16|M0)              r24.0<1>:d    r2.0<1;1,0>:d     r94.0<1;1,0>:d   {Compacted,I@1}
        cmp (16|M0)   (eq)f1.0   null<1>:d     r24.0<1;1,0>:d    255:w               {I@1}
(f1.0)  goto (16|M0)                         L28896                  L28896                
L28824:
(~f1.1) sel (16|M0)              r2.0<1>:d     r38.0<1;1,0>:d    0:w              
        and (16|M0)              r10.0<1>:d    r124.0<1;1,0>:d   -2147483648:d              
        shl (16|M0)              r12.0<1>:d    r24.0<1;1,0>:d    23:w               {Compacted}
        bfn.0xFE (16|M0)         r76.0<1>:ud   r10.0<1;0>:ud     r12.0<1;0>:ud     r2.0<1>:ud       {I@1} // s0|s1|s2
        goto (16|M0)                         L28896                  L29488                
L28896:
        join (16|M0)                         L28960                                
L28912:
        cmp (16|M0)   (gt)f1.0   null<1>:d     r124.0<1;1,0>:d   -1:w              
(W)     mov (1|M0)               r2.0<1>:f     inf:f                               {Compacted,I@4}
(f1.0)  sel (16|M0)              r76.0<1>:f    r2.0<0;1,0>:f     -inf:f               {Compacted,F@1}
        goto (16|M0)                         L28960                  L29488                
L28960:
        join (16|M0)                         L29272                                
L28976:
        and (16|M0)   (ne)f1.1   r126.0<1>:d   r32.0<1;1,0>:d    63:w              
(f1.1)  goto (16|M0)                         L29040                  L29040                
L29008:
        mov (16|M0)              r64.0<1>:d    -1:w                              
        goto (16|M0)                         L29040                  L29168                
L29040:
        join (16|M0)                         L29168                                
L29056:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r126.0<1;1,0>:ud  0x20:uw              {A@1}
(f1.0)  goto (16|M0)                         L29120                  L29120                
L29088:
        mov (16|M0)              r64.0<1>:d    0:w                              
        goto (16|M0)                         L29120                  L29168                
L29120:
        join (16|M0)                         L29168                                
L29136:
(W)     mov (1|M0)               r2.0<1>:hf    -qnan(0x1FF):hf                             
        shl (16|M0)              r64.0<1>:d    r2.0<0;1,0>:w     r126.0<1;1,0>:d  {F@1}
L29168:
        join (16|M0)                         L29272                                
L29184:
        bfn.0x60 (16|M0)         r2.0<1>:ud    r64.0<1;0>:ud     r4.0<0;0>:ud      r118.0<1>:ud     {I@2} // (s0^s1)&s2
        add (16|M0)              r10.0<1>:d    -r32.0<1;1,0>:d   23:w               {Compacted}
        and (16|M0)              r12.0<1>:d    r124.0<1;1,0>:d   -2147483648:d              
        shl (16|M0)              r14.0<1>:d    r94.0<1;1,0>:d    23:w               {Compacted}
        shl (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     r10.0<1;1,0>:d   {Compacted,I@3}
        bfn.0xFE (16|M0)         r76.0<1>:ud   r12.0<1;0>:ud     r14.0<1;0>:ud     r2.0<1>:ud       {I@1} // s0|s1|s2
        goto (16|M0)                         L29272                  L29488                
L29272:
        join (16|M0)                         L29336                                
L29288:
        cmp (16|M0)   (gt)f1.1   null<1>:d     r124.0<1;1,0>:d   -1:w              
(W)     mov (1|M0)               r2.0<1>:f     inf:f                               {Compacted,I@4}
(f1.1)  sel (16|M0)              r76.0<1>:f    r2.0<0;1,0>:f     -inf:f               {Compacted,F@1}
        goto (16|M0)                         L29336                  L29488                
L29336:
        join (16|M0)                         L29392                                
L29352:
        cmp (16|M0)   (lt)f1.0   null<1>:d     r124.0<1;1,0>:d   0:w               {Compacted}
(W)     mov (1|M0)               r2.0<1>:f     -0.0:f                               {Compacted}
(f1.0)  sel (16|M0)              r76.0<1>:f    r2.0<0;1,0>:f     0.0:f               {Compacted,F@1}
        goto (16|M0)                         L29392                  L29488                
L29392:
        join (16|M0)                         L29456                                
L29408:
        cmp (16|M0)   (gt)f1.1   null<1>:d     r124.0<1;1,0>:d   -1:w              
(W)     mov (1|M0)               r2.0<1>:f     inf:f                               {Compacted}
(f1.1)  sel (16|M0)              r76.0<1>:f    r2.0<0;1,0>:f     -inf:f               {Compacted,F@1}
        goto (16|M0)                         L29456                  L29488                
L29456:
        join (16|M0)                         L29488                                
L29472:
        bfn.0xF8 (16|M0)         r76.0<1>:ud   r124.0<1;0>:ud    r4.2<0;0>:ud      r4.1<0>:ud       {F@1} // s0&s1|s2
L29488:
        join (16|M0)                         L29800                                
L29504:
        cmp (16|M0)   (lt)f1.1   null<1>:f     r58.0<1;1,0>:f    0.0:f               {I@5}
(W)     shl (1|M0)               r5.5<1>:d     r4.5<0;1,0>:d     1:w              
(W)     shr (1|M0)               r5.6<1>:ud    r4.5<0;1,0>:ud    31:w              
        addc (8|M0)              r10.0<1>:ud   r56.0<1;1,0>:ud   r5.5<0;1,0>:ud   {AccWrEn,Compacted,I@2}
(f1.1)  sel (16|M0)              r2.0<1>:f     -r76.0<1;1,0>:f   r76.0<1;1,0>:f   {Compacted}
        mov (8|M0)               r12.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        addc (8|M8)              r11.0<1>:ud   r57.0<1;1,0>:ud   r5.5<0;1,0>:ud   {AccWrEn}
(W)     cmp (16|M0)   (lt)f1.0   null<1>:d     r4.5<0;1,0>:ud    0x1F:uw             
        mov (8|M0)               r9.0<1>:hf    r2.0<1;1,0>:f                    {F@1}
        mov (8|M8)               r9.8<1>:hf    r3.0<1;1,0>:f                   
        mov (8|M8)               r18.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        sync.nop                             null                             {Compacted,$6.src}
        add3 (8|M0)              r13.1<2>:ud   r12.0<1;0>:ud     r54.0<1;0>:ud     r5.6<0>:ud       {I@4}
        mov (16|M0)              r20.0<1>:ud   r9.0<1;1,0>:uw                   {A@1}
        add3 (8|M8)              r15.1<2>:ud   r18.0<1;0>:ud     r55.0<1;0>:ud     r5.6<0>:ud       {I@3}
        mov (8|M0)               r13.0<2>:d    r10.0<1;1,0>:d                  
        mov (8|M8)               r15.0<2>:d    r11.0<1;1,0>:d                  
        send.ugm (16|M0)         null     r13     r20:2   0x0            0x080E0B84           {A@1,$5} // wr:4+2, rd:0; store.ugm.d16u32.a64.wb.wb
(~f1.0) goto (16|M0)                         L29800                  L29800                
L29768:
(W)     add (1|M0)               r8.7<1>:d     r8.7<0;1,0>:d     2:w              
(W)     jmpi                                 L3824                                
L29800:
        join (16|M0)                         L29968                                
L29816:
        addc (8|M0)              r104.0<1>:ud  r40.0<1;1,0>:ud   r8.2<0;1,0>:ud   {AccWrEn,Compacted}
        add (8|M0)               r102.0<1>:ud  acc0.0<1;1,0>:ud  r6.0<1;1,0>:ud  
        addc (8|M8)              r105.0<1>:ud  r41.0<1;1,0>:ud   r8.2<0;1,0>:ud   {AccWrEn}
        cmp (16|M0)   (lt)f1.0   null<1>:d     r104.0<1;1,0>:ud  r4.6<0;1,0>:ud   {I@1}
        add (8|M8)               r103.0<1>:ud  acc0.0<1;1,0>:ud  r7.0<1;1,0>:ud  
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r102.0<1;1,0>:d   r4.7<0;1,0>:d    {I@1}
(~f1.0) cmp (16|M0)   (lt)f1.0   null<1>:d     r102.0<1;1,0>:ud  r4.7<0;1,0>:ud  
(~f1.0) goto (16|M0)                         L29968                  L29968                
L29936:
(f1.0)  sel (16|M0)              r40.0<1>:d    r104.0<1;1,0>:d   r44.0<1;1,0>:d   {Compacted}
(f1.0)  sel (16|M0)              r6.0<1>:d     r102.0<1;1,0>:d   r42.0<1;1,0>:d   {Compacted}
(W)     jmpi                                 L632                                
L29968:
        join (16|M0)                         L29984                                
L29984:
(W)     mov (8|M0)               r127.0<1>:f   r98.0<1;1,0>:f                   {Compacted,$2.src}
(W)     send.gtwy (1|M0)         null     r127    null:0  0x0            0x02000010           {EOT,A@1} // wr:1+0, rd:0; end of thread
L30008:
        nop                    
(W)     mov (16|M0)              null<1>:ud    0x9E09665A:ud                             
(W)     mov (16|M0)              null<1>:ud    0xA6E09A48:ud                             
(W)     mov (16|M0)              null<1>:ud    0x0:ud                             
(W)     mov (16|M0)              null<1>:ud    0x66:ud                             
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
