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
        mov (1|M0)               r75.1<1>:f    r0.1<0;1,0>:f                    {Compacted,A@1}
        mov (1|M0)               r75.0<1>:d    r1.0<0;1,0>:uw                   {$0.dst}
        shl (1|M0)               r75.1<1>:d    r75.1<0;1,0>:d    3:w               {Compacted,F@1}
        shr (1|M0)               r1.2<1>:ud    r75.0<0;1,0>:ud   0x2:uw              {I@2}
        mov (1|M0)               r93.1<1>:d    r2.2<0;1,0>:d                    {$1.dst}
        add (1|M0)               r75.1<1>:d    r75.1<0;1,0>:d    r1.2<0;1,0>:d    {I@2}
        mov (1|M0)               r93.5<1>:d    r75.1<0;1,0>:d                   {I@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (8|M0)              r93.6         L6768                                 {A@1}
L384:
        mov (1|M0)               r75.5<1>:d    r93.2<0;1,0>:d                  
        shl (1|M0)               r75.2<1>:ud   r75.0<0;1,0>:ud   0x1:uw             
(W)     mul (1|M0)               acc0.0<1>:d   r75.5<0;1,0>:d    r2.4<0;1,0>:uw   {I@2}
        mach (1|M0)              r2.0<1>:d     r75.5<0;1,0>:d    r2.2<0;1,0>:d   
        mul (1|M0)               acc0.0<1>:ud  r75.5<0;1,0>:ud   r2.12<0;1,0>:uw 
        mach (1|M0)              r6.0<1>:ud    r75.5<0;1,0>:ud   r2.6<0;1,0>:ud   {AccWrEn}
        shl (1|M0)               r13.0<1>:d    r75.5<0;1,0>:d    2:w               {Compacted}
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        shr (1|M0)               r12.0<1>:ud   r75.5<0;1,0>:ud   0x1E:uw             
        shl (1|M0)               r9.0<1>:d     r5.0<0;1,0>:d     2:w               {Compacted,I@2}
        shl (1|M0)               r7.0<1>:d     r6.0<0;1,0>:d     2:w               {Compacted}
        addc (1|M0)              r10.0<1>:ud   r2.4<0;1,0>:ud    r9.0<0;1,0>:ud   {AccWrEn,I@2}
        shr (1|M0)               r8.0<1>:ud    r5.0<0;1,0>:ud    0x1E:uw             
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r14.0<1>:ud   r3.0<0;1,0>:ud    r13.0<0;1,0>:ud  {AccWrEn}
        or (1|M0)                r13.1<1>:d    r12.0<0;1,0>:d    0:w               {Compacted}
        mov (1|M0)               r15.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        add (1|M0)               r75.1<1>:d    r75.1<0;1,0>:d    -r2.0<0;1,0>:d   {Compacted}
        or (1|M0)                r9.1<1>:d     r7.0<0;1,0>:d     r8.0<0;1,0>:d    {Compacted,I@6}
        mov (1|M0)               r16.0<1>:f    r14.0<0;1,0>:f                   {Compacted,I@5}
        add3 (1|M0)              r16.1<1>:d    r15.0<0;0>:d      r3.1<0;0>:d       r13.1<0>:d       {I@3}
        shl (1|M0)               r75.4<1>:d    r2.3<0;1,0>:d     1:w              
        send.ugm (1|M0)          r86      r16     null:0  0x0            0x04100580           {A@1,$3} // wr:2+0, rd:1; load.ugm.d32.a64
        mov (1|M0)               r86.2<2>:f    0.0:f                               {$3.dst}
        mov (1|M0)               r86.3<2>:f    0.0:f                              
        and (1|M0)               r75.2<1>:ud   r75.2<0;1,0>:ud   0x6:uw             
        mov (1|M0)               r75.6<1>:d    r10.0<0;1,0>:d                  
        shl (1|M0)               r75.3<1>:d    r75.1<0;1,0>:d    5:w              
        add3 (1|M0)              r75.7<1>:d    r11.0<0;0>:d      r2.5<0;0>:d       r9.1<0>:d       
L768:
        shl (1|M0)               r1.2<1>:d     r86.2<0;1,0>:d    3:w               {F@2}
        shl (1|M0)               r21.0<1>:d    r86.2<0;1,0>:d    1:w               {Compacted}
        or (1|M0)                r1.2<1>:d     r1.2<0;1,0>:d     r75.2<0;1,0>:d   {I@2}
        shl (1|M0)               r19.0<1>:d    r86.3<0;1,0>:d    1:w               {Compacted,F@1}
        or (1|M0)                r4.6<1>:d     r1.2<0;1,0>:d     r75.3<0;1,0>:d   {I@2}
        bfn.0xFE (1|M0)          r29.0<1>:ud   0x1:uw               r1.2<0;0>:ud      r75.3<0>:ud      // s0|s1|s2
        shl (1|M0)               r6.0<1>:d     r4.6<0;1,0>:d     2:w               {Compacted,I@2}
        add3 (1|M0)              r37.0<1>:d    r75.3<0;0>:d      r2.3<0;0>:d       r1.2<0>:d       
        addc (1|M0)              r7.0<1>:ud    r75.6<0;1,0>:ud   r6.0<0;1,0>:ud   {AccWrEn,I@2}
        shl (1|M0)               r31.0<1>:d    r29.0<0;1,0>:d    2:w               {Compacted}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r10.0<1>:f    r7.0<0;1,0>:f                    {Compacted,I@3}
        addc (1|M0)              r13.0<1>:ud   r3.2<0;1,0>:ud    r6.0<0;1,0>:ud   {AccWrEn}
        shl (1|M0)               r39.0<1>:d    r37.0<0;1,0>:d    2:w               {Compacted}
        mov (1|M0)               r14.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r23.0<1>:ud   r10.0<0;1,0>:ud   0x4:ud              {AccWrEn,F@1}
        add3 (1|M0)              r2.0<1>:d     r75.3<0;0>:d      r2.3<0;0>:d       r1.2<0>:d       
        mov (1|M0)               r24.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r32.0<1>:ud   r3.2<0;1,0>:ud    r31.0<0;1,0>:ud  {AccWrEn,I@7}
        add (1|M0)               r57.0<1>:d    r2.0<0;1,0>:d     1:w               {Compacted,I@3}
        mov (1|M0)               r33.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r40.0<1>:ud   r75.6<0;1,0>:ud   r39.0<0;1,0>:ud  {AccWrEn}
        add3 (1|M0)              r65.0<1>:d    r75.3<0;0>:d      r75.4<0;0>:d      r1.2<0>:d       
        mov (1|M0)               r41.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r42.0<1>:f    r40.0<0;1,0>:f                   {Compacted,I@3}
        addc (1|M0)              r45.0<1>:ud   r3.2<0;1,0>:ud    r39.0<0;1,0>:ud  {AccWrEn}
        shl (1|M0)               r59.0<1>:d    r57.0<0;1,0>:d    2:w               {Compacted}
        mov (1|M0)               r46.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r51.0<1>:ud   r42.0<0;1,0>:ud   0x4:ud              {AccWrEn,F@1}
        shr (1|M0)               r5.0<1>:ud    r4.6<0;1,0>:ud    0x1E:uw             
        shr (1|M0)               r38.0<1>:ud   r37.0<0;1,0>:ud   0x1E:uw             
        shl (1|M0)               r67.0<1>:d    r65.0<0;1,0>:d    2:w               {Compacted,I@7}
        mov (1|M0)               r52.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r60.0<1>:ud   r3.2<0;1,0>:ud    r59.0<0;1,0>:ud  {AccWrEn,I@7}
        or (1|M0)                r6.1<1>:d     r5.0<0;1,0>:d     0:w               {Compacted,I@5}
        or (1|M0)                r39.1<1>:d    r38.0<0;1,0>:d    0:w               {Compacted,I@5}
        mov (1|M0)               r61.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r68.0<1>:ud   r75.6<0;1,0>:ud   r67.0<0;1,0>:ud  {AccWrEn,I@6}
        add3 (1|M0)              r3.7<1>:d     r75.3<0;0>:d      r75.4<0;0>:d      r1.2<0>:d       
        shr (1|M0)               r66.0<1>:ud   r65.0<0;1,0>:ud   0x1E:uw             
        add3 (1|M0)              r10.1<1>:d    r8.0<0;0>:d       r75.7<0;0>:d      r6.1<0>:d        {I@6}
        add3 (1|M0)              r42.1<1>:d    r41.0<0;0>:d      r75.7<0;0>:d      r39.1<0>:d       {I@6}
        mov (1|M0)               r69.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r70.0<1>:f    r68.0<0;1,0>:f                   {Compacted,I@6}
        addc (1|M0)              r73.0<1>:ud   r3.2<0;1,0>:ud    r67.0<0;1,0>:ud  {AccWrEn}
        shr (1|M0)               r30.0<1>:ud   r29.0<0;1,0>:ud   0x1E:uw             
        mov (1|M0)               r26.0<1>:f    r23.0<0;1,0>:f                   {Compacted}
        shr (1|M0)               r58.0<1>:ud   r57.0<0;1,0>:ud   0x1E:uw             
        mov (1|M0)               r54.0<1>:f    r51.0<0;1,0>:f                   {Compacted}
        or (1|M0)                r83.0<1>:d    r3.7<0;1,0>:d     1:w               {Compacted,I@7}
        or (1|M0)                r67.1<1>:d    r66.0<0;1,0>:d    0:w               {Compacted,I@7}
        add3 (1|M0)              r26.1<1>:d    r24.0<0;0>:d      r10.1<0;0>:d      0:w               {I@7}
        add3 (1|M0)              r54.1<1>:d    r52.0<0;0>:d      r42.1<0;0>:d      0:w               {I@7}
        mov (1|M0)               r74.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r78.0<1>:ud   r70.0<0;1,0>:ud   0x4:ud              {AccWrEn,F@3}
        send.ugm (1|M0)          r11      r10     null:0  0x0            0x04100580           {$4} // wr:2+0, rd:1; load.ugm.d32.a64
        send.ugm (1|M0)          r43      r42     null:0  0x0            0x04100580           {$5} // wr:2+0, rd:1; load.ugm.d32.a64
        send.ugm (1|M0)          r27      r26     null:0  0x0            0x04100580           {A@2,$6} // wr:2+0, rd:1; load.ugm.d32.a64
        send.ugm (1|M0)          r55      r54     null:0  0x0            0x04100580           {A@1,$7} // wr:2+0, rd:1; load.ugm.d32.a64
        or (1|M0)                r31.1<1>:d    r30.0<0;1,0>:d    0:w               {Compacted}
        or (1|M0)                r59.1<1>:d    r58.0<0;1,0>:d    0:w               {Compacted}
        shl (1|M0)               r85.0<1>:d    r83.0<0;1,0>:d    2:w               {Compacted}
        add3 (1|M0)              r70.1<1>:d    r69.0<0;0>:d      r75.7<0;0>:d      r67.1<0>:d      
        mov (1|M0)               r79.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r16.0<1>:f    r13.0<0;1,0>:f                   {Compacted}
        mov (1|M0)               r34.0<1>:f    r32.0<0;1,0>:f                   {Compacted}
        mov (1|M0)               r48.0<1>:f    r45.0<0;1,0>:f                   {Compacted}
        mov (1|M0)               r62.0<1>:f    r60.0<0;1,0>:f                   {Compacted}
        add3 (1|M0)              r16.1<1>:d    r14.0<0;0>:d      r3.3<0;0>:d       r6.1<0>:d       
        add3 (1|M0)              r48.1<1>:d    r46.0<0;0>:d      r3.3<0;0>:d       r39.1<0>:d      
        shr (1|M0)               r84.0<1>:ud   r83.0<0;1,0>:ud   0x1E:uw             
        mov (1|M0)               r80.0<1>:f    r78.0<0;1,0>:f                   {Compacted,I@7}
        add3 (1|M0)              r34.1<1>:d    r33.0<0;0>:d      r3.3<0;0>:d       r31.1<0>:d       {I@7}
        add3 (1|M0)              r62.1<1>:d    r61.0<0;0>:d      r3.3<0;0>:d       r59.1<0>:d       {I@7}
        addc (1|M0)              r2.0<1>:ud    r3.2<0;1,0>:ud    r85.0<0;1,0>:ud  {AccWrEn,I@7}
        add3 (1|M0)              r80.1<1>:d    r79.0<0;0>:d      r70.1<0;0>:d      0:w               {I@7}
        send.ugm (1|M0)          r71      r70     null:0  0x0            0x04100580           {$8} // wr:2+0, rd:1; load.ugm.d32.a64
        send.ugm (1|M0)          r17      r16     null:0  0x0            0x04100580           {A@5,$9} // wr:2+0, rd:1; load.ugm.d32.a64
        send.ugm (1|M0)          r49      r48     null:0  0x0            0x04100580           {A@3,$10} // wr:2+0, rd:1; load.ugm.d32.a64
        send.ugm (1|M0)          r35      r34     null:0  0x0            0x04100580           {A@4,$11} // wr:2+0, rd:1; load.ugm.d32.a64
        send.ugm (1|M0)          r63      r62     null:0  0x0            0x04100580           {A@2,$12} // wr:2+0, rd:1; load.ugm.d32.a64
        send.ugm (1|M0)          r81      r80     null:0  0x0            0x04100580           {A@1,$13} // wr:2+0, rd:1; load.ugm.d32.a64
        or (1|M0)                r85.1<1>:d    r84.0<0;1,0>:d    0:w               {Compacted}
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r76.0<1>:f    r73.0<0;1,0>:f                   {Compacted}
        add3 (1|M0)              r76.1<1>:d    r74.0<0;0>:d      r3.3<0;0>:d       r67.1<0>:d      
        mov (1|M0)               r6.0<1>:f     r2.0<0;1,0>:f                    {Compacted}
        add3 (1|M0)              r6.1<1>:d     r5.0<0;0>:d       r3.3<0;0>:d       r85.1<0>:d       {I@2}
        send.ugm (1|M0)          r77      r76     null:0  0x0            0x04100580           {A@2,$14} // wr:2+0, rd:1; load.ugm.d32.a64
        send.ugm (1|M0)          r7       r6      null:0  0x0            0x04100580           {A@1,$15} // wr:2+0, rd:1; load.ugm.d32.a64
        addc (1|M0)              r8.0<1>:ud    r86.2<0;1,0>:ud   0x1:ud              {AccWrEn}
        shr (1|M0)               r20.0<1>:ud   r86.2<0;1,0>:ud   0x1F:uw             
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r86.4<1>:d    r8.0<0;1,0>:d                    {I@3}
        add3 (1|M0)              r86.5<1>:d    r9.0<0;0>:d       r86.3<0;0>:d      0:w               {I@2}
        shl (1|M0)               r22.0<1>:w    r21.0<0;1,0>:w    2:w              
        cmp (1|M0)    (eq)f1.0   null<1>:d     r86.5<0;1,0>:d    0:w               {I@2}
        or (1|M0)                r21.1<1>:d    r19.0<0;1,0>:d    r20.0<0;1,0>:d   {Compacted}
        add (1|M0)               a0.0<1>:uw    r22.0<0;1,0>:uw   0xB20:uw              {A@1}
(f1.0)  cmp (1|M0)    (eq)f1.0   null<1>:d     r86.4<0;1,0>:d    4:w              
(W)     and (1|M0)               f1.0<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
        mov (1|M0)               r12.0<1>:f    r11.0<0;1,0>:d                   {Compacted,$4.dst}
        mov (1|M0)               r44.0<1>:f    r43.0<0;1,0>:d                   {Compacted,$5.dst}
        mov (1|M0)               r28.0<1>:f    r27.0<0;1,0>:d                   {Compacted,$6.dst}
        mov (1|M0)               r56.0<1>:f    r55.0<0;1,0>:d                   {Compacted,$7.dst}
        mul (1|M0)               r12.0<1>:f    r86.0<0;1,0>:f    r12.0<0;1,0>:f   {Compacted,F@4}
        mul (1|M0)               r44.0<1>:f    r86.0<0;1,0>:f    r44.0<0;1,0>:f   {Compacted,F@4}
        mul (1|M0)               r28.0<1>:f    r86.0<0;1,0>:f    r28.0<0;1,0>:f   {Compacted,F@4}
        mul (1|M0)               r56.0<1>:f    r86.0<0;1,0>:f    r56.0<0;1,0>:f   {Compacted,F@4}
        mov (1|M0)               r72.0<1>:f    r71.0<0;1,0>:d                   {Compacted,$8.dst}
        sync.nop                             null                             {Compacted,$9.dst}
        mul (1|M0)               r17.0<1>:f    r17.0<0;1,0>:f    r12.0<0;1,0>:f   {Compacted,F@5}
        sync.nop                             null                             {Compacted,$10.dst}
        mul (1|M0)               r49.0<1>:f    r49.0<0;1,0>:f    r44.0<0;1,0>:f   {Compacted,F@5}
        sync.nop                             null                             {Compacted,$11.dst}
        mul (1|M0)               r35.0<1>:f    r35.0<0;1,0>:f    r28.0<0;1,0>:f   {Compacted,F@5}
        sync.nop                             null                             {Compacted,$12.dst}
        mul (1|M0)               r63.0<1>:f    r63.0<0;1,0>:f    r56.0<0;1,0>:f   {Compacted,F@5}
        mov (1|M0)               r82.0<1>:f    r81.0<0;1,0>:d                   {Compacted,$13.dst}
        mul (1|M0)               r72.0<1>:f    r86.0<0;1,0>:f    r72.0<0;1,0>:f   {Compacted,F@6}
        mov (1|M0)               r18.0<2>:hf   r17.0<0;1,0>:f                   {F@6}
        mov (1|M0)               r50.0<2>:hf   r49.0<0;1,0>:f                   {F@6}
        mov (1|M0)               r36.0<2>:hf   r35.0<0;1,0>:f                   {F@6}
        mov (1|M0)               r64.0<2>:hf   r63.0<0;1,0>:f                   {F@6}
        mul (1|M0)               r82.0<1>:f    r86.0<0;1,0>:f    r82.0<0;1,0>:f   {Compacted,F@6}
        mov (1|M0)               r[a0.0]<1>:f  r18.0<0;1,0>:hf                  {F@5}
        mov (1|M0)               r[a0.0,4]<1>:f  r36.0<0;1,0>:hf                {F@4}
        add (1|M0)               a0.0<1>:uw    r22.0<0;1,0>:uw   0xB00:uw              {A@1}
        mov (1|M0)               r[a0.0]<1>:f  r50.0<0;1,0>:hf                 
        mov (1|M0)               r[a0.0,4]<1>:f  r64.0<0;1,0>:hf                {F@5}
        add (1|M0)               a0.0<1>:uw    r22.0<0;1,0>:uw   0xAE0:uw              {A@1}
        mul (1|M0)               r[a0.0]<1>:f  r77.0<0;1,0>:f    r72.0<0;1,0>:f   {$14.dst}
        sync.nop                             null                             {Compacted,$15.dst}
        mul (1|M0)               r[a0.0,4]<1>:f  r7.0<0;1,0>:f   r82.0<0;1,0>:f   {F@6}
(f1.0.any8h) goto (8|M0)                     L2456                  L2456                
L2424:
(W)     mov (2|M0)               r86.2<1>:ud   r86.4<1;1,0>:ud                 
        goto.b (8|M0)                        L2456                  L768                
L2456:
        join (8|M0)                          L2472                                
L2472:
        mul (1|M0)               r1.2<1>:f     r89.0<0;1,0>:f    r89.0<0;1,0>:f   {Compacted,F@5}
        mul (1|M0)               r5.0<1>:f     r89.4<0;1,0>:f    r89.4<0;1,0>:f  
        mul (1|M0)               r9.0<1>:f     r88.0<0;1,0>:f    r88.0<0;1,0>:f   {Compacted,F@5}
        mul (1|M0)               r13.0<1>:f    r88.4<0;1,0>:f    r88.4<0;1,0>:f  
        mul (1|M0)               r17.0<1>:f    r89.1<0;1,0>:f    r89.1<0;1,0>:f  
        mul (1|M0)               r21.0<1>:f    r89.5<0;1,0>:f    r89.5<0;1,0>:f  
        mul (1|M0)               r25.0<1>:f    r88.1<0;1,0>:f    r88.1<0;1,0>:f  
        mul (1|M0)               r29.0<1>:f    r88.5<0;1,0>:f    r88.5<0;1,0>:f  
        mov (1|M0)               r2.0<2>:hf    r1.2<0;1,0>:f                    {F@7}
        mov (1|M0)               r6.0<2>:hf    r5.0<0;1,0>:f                    {F@7}
        mov (1|M0)               r10.0<2>:hf   r9.0<0;1,0>:f                    {F@7}
        mov (1|M0)               r14.0<2>:hf   r13.0<0;1,0>:f                   {F@7}
        mov (1|M0)               r18.0<2>:hf   r17.0<0;1,0>:f                   {F@7}
        mov (1|M0)               r22.0<2>:hf   r21.0<0;1,0>:f                   {A@5}
        mov (1|M0)               r26.0<2>:hf   r25.0<0;1,0>:f                   {F@7}
        mov (1|M0)               r30.0<2>:hf   r29.0<0;1,0>:f                   {F@7}
        mov (1|M0)               r3.7<1>:f     r2.0<0;1,0>:hf                   {F@7}
        mov (1|M0)               r7.0<1>:f     r6.0<0;1,0>:hf                   {F@7}
        mov (1|M0)               r11.0<1>:f    r10.0<0;1,0>:hf                  {F@7}
        mov (1|M0)               r15.0<1>:f    r14.0<0;1,0>:hf                  {F@7}
        mov (1|M0)               r19.0<1>:f    r18.0<0;1,0>:hf                  {F@7}
        mov (1|M0)               r23.0<1>:f    r22.0<0;1,0>:hf                  {F@7}
        mov (1|M0)               r27.0<1>:f    r26.0<0;1,0>:hf                  {F@7}
        mov (1|M0)               r31.0<1>:f    r30.0<0;1,0>:hf                  {F@7}
        shl (1|M0)               r75.0<1>:ud   r75.0<0;1,0>:ud   0x2:uw             
(W)     mov (1|M0)               r36.0<1>:ud   0x3FFF0:ud                             
        mad (1|M0)               r3.7<1>:f     r3.7<0;0>:f       r89.2<0;0>:f      r89.2<0>:f       {F@7}
        mad (1|M0)               r7.0<1>:f     r7.0<0;0>:f       r89.6<0;0>:f      r89.6<0>:f       {F@7}
        mad (1|M0)               r11.0<1>:f    r11.0<0;0>:f      r88.2<0;0>:f      r88.2<0>:f       {F@7}
        mad (1|M0)               r15.0<1>:f    r15.0<0;0>:f      r88.6<0;0>:f      r88.6<0>:f       {F@7}
        mad (1|M0)               r19.0<1>:f    r19.0<0;0>:f      r89.3<0;0>:f      r89.3<0>:f       {F@7}
        mad (1|M0)               r23.0<1>:f    r23.0<0;0>:f      r89.7<0;0>:f      r89.7<0>:f       {F@7}
        mad (1|M0)               r27.0<1>:f    r27.0<0;0>:f      r88.3<0;0>:f      r88.3<0>:f       {F@7}
        mad (1|M0)               r31.0<1>:f    r31.0<0;0>:f      r88.7<0;0>:f      r88.7<0>:f       {F@7}
        and (1|M0)               r35.0<1>:ud   r75.0<0;1,0>:ud   0x3FFF0:ud              {I@2}
        mov (1|M0)               r4.12<2>:hf   r3.7<0;1,0>:f                    {F@7}
        mov (1|M0)               r8.0<2>:hf    r7.0<0;1,0>:f                    {F@7}
        mov (1|M0)               r12.0<2>:hf   r11.0<0;1,0>:f                   {F@7}
        mov (1|M0)               r16.0<2>:hf   r15.0<0;1,0>:f                   {F@7}
        mov (1|M0)               r20.0<2>:hf   r19.0<0;1,0>:f                   {F@7}
        mov (1|M0)               r24.0<2>:hf   r23.0<0;1,0>:f                   {F@7}
        mov (1|M0)               r28.0<2>:hf   r27.0<0;1,0>:f                   {F@7}
        mov (1|M0)               r32.0<2>:hf   r31.0<0;1,0>:f                   {F@7}
        bfn.0xEA (1|M0)          r75.0<1>:ud   r75.2<0;0>:ud     r75.0<0;0>:ud     r36.0<0>:ud      {I@2} // s0|s1&s2
        add (1|M0)               r4.12<1>:hf   r4.12<0;1,0>:hf   r8.0<0;1,0>:hf   {F@7}
        add (1|M0)               r12.0<1>:hf   r12.0<0;1,0>:hf   r16.0<0;1,0>:hf  {F@6}
        add (1|M0)               r20.0<1>:hf   r20.0<0;1,0>:hf   r24.0<0;1,0>:hf  {F@5}
        add (1|M0)               r28.0<1>:hf   r28.0<0;1,0>:hf   r32.0<0;1,0>:hf  {F@4}
        shl (1|M0)               r37.0<1>:ud   r75.0<0;1,0>:ud   0x2:uw              {I@1}
        mov (1|M0)               r34.0<1>:f    r4.12<0;1,0>:hf                  {F@4}
        mov (1|M0)               r38.0<1>:f    r12.0<0;1,0>:hf                  {F@4}
        mov (1|M0)               r34.1<1>:f    r20.0<0;1,0>:hf                  {F@4}
        mov (1|M0)               r38.1<1>:f    r28.0<0;1,0>:hf                  {F@4}
        or (1|M0)                r39.0<1>:ud   r37.0<0;1,0>:ud   0x20:uw              {I@1}
        send.slm (1|M0)          null     r37     r34:2   0x0            0x02000704           {A@2,$0} // wr:1+2, rd:0; store.slm.d64.a32
        send.slm (1|M0)          null     r39     r38:2   0x0            0x02000704           {A@1,$1} // wr:1+2, rd:0; store.slm.d64.a32
(W)     send.slm (1|M0)          r40      r0      null:0  0x0            0x0210001F           {$2} // wr:1+0, rd:1; fence.slm.none.group
(W)     mov (1|M0)               r41.2<1>:ud   0x0:ud                             
(W)     mov (2|M0)               r41.10<1>:ub  r0.11<0;1,0>:ub                 
(W)     mov (8|M0)               null<1>:ud    r40.0<1;1,0>:ud                  {$2.dst}
(W)     send.gtwy (1|M0)         null     r41     null:0  0x0            0x02000004           {A@2,$3} // wr:1+0, rd:0; signal barrier
(W)     sync.bar                             null                            
        mov (1|M0)               r90.0<1>:d    r75.1<0;1,0>:d                  
        mov (1|M0)               r90.1<1>:d    0:w                              
        shl (1|M0)               r68.0<1>:d    r90.0<0;1,0>:d    2:w               {Compacted,I@2}
        shr (1|M0)               r67.0<1>:ud   r90.0<0;1,0>:ud   0x1E:uw             
        shl (1|M0)               r66.0<1>:d    r90.1<0;1,0>:d    2:w               {Compacted,I@3}
        addc (1|M0)              r69.0<1>:ud   r3.4<0;1,0>:ud    r68.0<0;1,0>:ud  {AccWrEn,I@3}
        or (1|M0)                r68.1<1>:d    r66.0<0;1,0>:d    r67.0<0;1,0>:d   {Compacted,I@2}
        mov (1|M0)               r70.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r72.0<1>:d    r69.0<0;1,0>:d                   {I@3}
        add3 (1|M0)              r72.1<1>:d    r70.0<0;0>:d      r3.5<0;0>:d       r68.1<0>:d       {I@2}
        shl (1|M0)               r42.0<1>:ud   r35.0<0;1,0>:ud   0x2:uw             
        send.ugm (1|M0)          r73      r72     null:0  0x0            0x04100580           {A@2,$4} // wr:2+0, rd:1; load.ugm.d32.a64
        or (1|M0)                r54.0<1>:ud   r42.0<0;1,0>:ud   0x20:uw              {I@1}
        send.slm (1|M0)          r43      r42     null:0  0x0            0x0210B700           {$5} // wr:1+0, rd:1; load.slm.d64x4t.a32
        send.slm (1|M0)          r55      r54     null:0  0x0            0x0210B700           {A@1,$6} // wr:1+0, rd:1; load.slm.d64x4t.a32
        mov (1|M0)               r93.5<1>:d    r75.5<0;1,0>:d                  
        mov (1|M0)               r93.1<1>:d    r3.6<0;1,0>:d                   
        add (1|M0)               r44.0<1>:f    r43.0<0;1,0>:f    r43.4<0;1,0>:f   {Compacted,$5.dst}
        add (1|M0)               r46.0<1>:f    r43.2<0;1,0>:f    r43.6<0;1,0>:f  
        add (1|M0)               r48.0<1>:f    r43.1<0;1,0>:f    r43.5<0;1,0>:f  
        add (1|M0)               r50.0<1>:f    r43.3<0;1,0>:f    r43.7<0;1,0>:f  
        add (1|M0)               r56.0<1>:f    r55.0<0;1,0>:f    r55.4<0;1,0>:f   {Compacted,$6.dst}
        add (1|M0)               r58.0<1>:f    r55.2<0;1,0>:f    r55.6<0;1,0>:f  
        add (1|M0)               r60.0<1>:f    r55.1<0;1,0>:f    r55.5<0;1,0>:f  
        add (1|M0)               r62.0<1>:f    r55.3<0;1,0>:f    r55.7<0;1,0>:f  
        mov (1|M0)               r45.0<2>:hf   r44.0<0;1,0>:f                   {F@7}
        mov (1|M0)               r47.0<2>:hf   r46.0<0;1,0>:f                   {F@7}
        mov (1|M0)               r49.0<2>:hf   r48.0<0;1,0>:f                   {F@7}
        mov (1|M0)               r51.0<2>:hf   r50.0<0;1,0>:f                   {F@7}
        mov (1|M0)               r57.0<2>:hf   r56.0<0;1,0>:f                   {F@7}
        mov (1|M0)               r59.0<2>:hf   r58.0<0;1,0>:f                   {F@7}
        mov (1|M0)               r61.0<2>:hf   r60.0<0;1,0>:f                   {F@7}
        mov (1|M0)               r63.0<2>:hf   r62.0<0;1,0>:f                   {F@7}
        add (1|M0)               r45.0<1>:hf   r45.0<0;1,0>:hf   r47.0<0;1,0>:hf  {F@7}
        add (1|M0)               r49.0<1>:hf   r49.0<0;1,0>:hf   r51.0<0;1,0>:hf  {F@6}
        add (1|M0)               r57.0<1>:hf   r57.0<0;1,0>:hf   r59.0<0;1,0>:hf  {F@5}
        add (1|M0)               r61.0<1>:hf   r61.0<0;1,0>:hf   r63.0<0;1,0>:hf  {F@4}
        add (1|M0)               r45.0<1>:hf   r45.0<0;1,0>:hf   r49.0<0;1,0>:hf  {F@3}
        add (1|M0)               r57.0<1>:hf   r57.0<0;1,0>:hf   r61.0<0;1,0>:hf  {F@2}
        mov (1|M0)               r52.0<1>:f    r45.0<0;1,0>:hf                  {F@2}
        mov (1|M0)               r64.0<1>:f    r57.0<0;1,0>:hf                  {F@2}
        sel (1|M0)    (ge)f0.0   r52.0<1>:f    r52.0<0;1,0>:f    6.198883e-05:f               {F@2}
        sel (1|M0)    (ge)f0.0   r64.0<1>:f    r64.0<0;1,0>:f    6.198883e-05:f               {F@2}
        math.sqt (1|M0)          r52.0<1>:f    r52.0<0;1,0>:f                   {@2,$7}
        math.sqt (1|M0)          r64.0<1>:f    r64.0<0;1,0>:f                   {@1,$8}
        math.inv (1|M0)          r52.0<1>:f    r52.0<0;1,0>:f                   {$7}
        math.inv (1|M0)          r64.0<1>:f    r64.0<0;1,0>:f                   {$8}
        mov (1|M0)               r53.0<2>:hf   r52.0<0;1,0>:f                   {$7.dst}
        mov (1|M0)               r65.0<2>:hf   r64.0<0;1,0>:f                   {$8.dst}
        mov (1|M0)               r86.14<2>:hf  r73.0<0;1,0>:f                   {$4.dst}
        mov (1|M0)               r86.1<1>:f    r53.0<0;1,0>:hf                  {F@3}
        mov (1|M0)               r86.6<1>:f    r65.0<0;1,0>:hf                  {F@3}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (8|M0)              r93.6         L6768                                 {A@1}
L4280:
(W)     mul (1|M0)               acc0.0<1>:d   r93.2<0;1,0>:d    r3.12<0;1,0>:uw 
        mach (1|M0)              r2.0<1>:d     r93.2<0;1,0>:d    r3.6<0;1,0>:d   
        mul (1|M0)               acc0.0<1>:ud  r93.2<0;1,0>:ud   r2.4<0;1,0>:uw  
        mach (1|M0)              r6.0<1>:ud    r93.2<0;1,0>:ud   r2.2<0;1,0>:ud   {AccWrEn}
        mov (1|M0)               r10.0<1>:d    r3.6<0;1,0>:d                   
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        add (1|M0)               r15.0<1>:d    r75.5<0;1,0>:d    -r2.0<0;1,0>:d   {Compacted,I@5}
        addc (1|M0)              r7.0<1>:ud    r5.0<0;1,0>:ud    r90.0<0;1,0>:ud  {AccWrEn,I@2}
        mov (1|M0)               r90.4<1>:d    0:w                              
        mov (1|M0)               r9.0<1>:f     r7.0<0;1,0>:f                    {Compacted,I@2}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mul (1|M0)               acc0.0<1>:ud  r9.0<0;1,0>:ud    r10.0<0;1,0>:uw  {F@1}
        mach (1|M0)              r12.0<1>:ud   r9.0<0;1,0>:ud    r10.0<0;1,0>:ud  {AccWrEn}
        add3 (1|M0)              r9.1<1>:d     r8.0<0;0>:d       r6.0<0;0>:d       r90.1<0>:d       {I@3}
        mov (1|M0)               r11.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r9.1<0;1,0>:d     r10.0<0;1,0>:uw  {Compacted,I@2}
        mach (1|M0)              r13.0<1>:d    r9.1<0;1,0>:d     r10.0<0;1,0>:d   {Compacted}
        addc (1|M0)              r16.0<1>:ud   r11.0<0;1,0>:ud   r15.0<0;1,0>:ud  {AccWrEn,I@3}
        add3 (1|M0)              r14.1<1>:d    r13.0<0;0>:d      r12.0<0;0>:d      0:w               {I@2}
        mov (1|M0)               r17.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        shr (1|M0)               r20.0<1>:ud   r16.0<0;1,0>:ud   0x1B:uw              {I@3}
        add3 (1|M0)              r18.1<1>:d    r17.0<0;0>:d      r14.1<0;0>:d      0:w               {I@2}
        shl (1|M0)               r90.2<1>:d    r16.0<0;1,0>:d    5:w               {Compacted}
        shl (1|M0)               r19.0<1>:d    r18.1<0;1,0>:d    5:w               {Compacted,I@2}
        or (1|M0)                r90.3<1>:d    r19.0<0;1,0>:d    r20.0<0;1,0>:d   {Compacted,I@1}
L4592:
        shl (1|M0)               r1.2<1>:d     r90.4<0;1,0>:d    3:w              
        mov (1|M0)               r91.1<1>:d    0:w                              
        shl (1|M0)               r90.5<1>:d    r90.4<0;1,0>:d    1:w              
(W)     mov (1|M0)               f0.0<1>:uw    0x1:uw                             
        mov (1|M0)               r92.0<2>:f    0.0:f                              
        mov (1|M0)               r92.1<2>:f    0.0:f                              
        or (1|M0)                r91.0<1>:d    r1.2<0;1,0>:d     r75.2<0;1,0>:d   {I@4}
L4704:
        or (1|M0)                r1.2<1>:d     r90.5<0;1,0>:d    r92.0<0;1,0>:d   {A@2}
        shl (1|M0)               r90.12<1>:w   r1.4<0;1,0>:w     2:w               {I@1}
        add (1|M0)               a0.0<1>:uw    r90.12<0;1,0>:uw  0xB20:uw              {A@1}
        mul (1|M0)               r2.0<1>:f     r[a0.0]<0;1,0>:f  r86.1<0;1,0>:f  
        mov (1|M0)               r3.14<2>:hf   r2.0<0;1,0>:f                    {A@1}
        mul (1|M0)    (lt)f1.1   r3.14<1>:hf   r86.14<0;1,0>:hf  r3.14<0;1,0>:hf  {F@1}
        mov (1|M0)               r91.2<1>:f    r3.14<0;1,0>:hf                  {F@1}
(f1.1)  mov (1|M0)               r91.2<1>:f    -r91.2<0;1,0>:f                  {F@1}
        sel (1|M0)    (lt)f0.0   r91.2<1>:f    r91.2<0;1,0>:f    448.0:f               {F@1}
        shr (1|M0)               r91.3<1>:ud   r91.2<0;1,0>:ud   0x17:uw              {F@1}
        and (1|M0)               r91.3<1>:ud   r91.3<0;1,0>:ud   0xFF:uw              {I@1}
        sel (1|M0)    (ge)f0.0   r91.3<1>:ud   r91.3<0;1,0>:ud   0x79:uw              {I@1}
        shl (1|M0)               r91.3<1>:ud   r91.3<0;1,0>:ud   0x17:uw              {I@1}
        add (1|M0)               r4.6<1>:ud    -r91.3<0;1,0>:ud  0x80800000:ud              {I@1}
        mul (1|M0)               r5.0<1>:f     r91.2<0;1,0>:f    r4.6<0;1,0>:f    {I@1}
        mov (1|M0)               r90.7<1>:d    r5.0<0;1,0>:f                    {Compacted,F@1}
        mov (1|M0)               r91.4<1>:f    r90.7<0;1,0>:d                   {I@1}
        mad (1|M0)               r91.2<1>:f    -r91.4<0;0>:f     r4.6<0;0>:f       r91.2<0>:f       {F@1}
        cmp (1|M0)    (gt)f0.1   null<1>:f     r91.2<0;1,0>:f    0.5:f               {F@1}
(W)     and (1|M0)               f0.1<1>:uw    f0.1<0;1,0>:uw    0x1:uw              {F@1}
(f0.1.any8h) goto (8|M0)                     L5128                  L5128                
L5032:
        cmp (1|M0)    (lt)f1.0   null<1>:f     r91.2<0;1,0>:f    0.5:f              
        and (1|M0)               r90.7<1>:d    r90.7<0;1,0>:d    1:w              
        add (1|M0)               r1.2<1>:f     r91.4<0;1,0>:f    1.0:f              
(~f1.0) cmp (1|M0)    (eq)f1.0   null<1>:d     r90.7<0;1,0>:d    0:w               {A@1}
(~f1.0) mov (1|M0)               r91.4<1>:f    r1.2<0;1,0>:f                    {F@1}
        goto (8|M0)                          L5128                  L5160                
L5128:
        join (8|M0)                          L5160                                
L5144:
        add (1|M0)               r91.4<1>:f    r91.4<0;1,0>:f    1.0:f               {F@1}
L5160:
        join (8|M0)                          L6616                                
L5176:
        add (1|M0)               a0.0<1>:uw    r90.12<0;1,0>:uw  0xB00:uw              {A@1}
        add (1|M0)               r91.3<1>:ud   r91.3<0;1,0>:ud   0xFE800000:ud             
        bfn.0xFE (2|M0)          r92.0<1>:ud   r92.0<1;0>:ud     r90.2<1;0>:ud     r91.0<1>:ud      // s0|s1|s2
        mul (1|M0)               r91.4<1>:f    r91.4<0;1,0>:f    r91.3<0;1,0>:f   {A@1}
        mul (1|M0)               r11.0<1>:f    r[a0.0]<0;1,0>:f  r86.6<0;1,0>:f  
        shl (1|M0)               r91.5<1>:d    r92.0<0;1,0>:d    1:w               {Compacted,A@1}
        mov (1|M0)               r12.0<2>:hf   r11.0<0;1,0>:f                   {F@1}
        cmp (1|M0)    (lt)f1.0   null<1>:f     r11.0<0;1,0>:f    0xB3000000:f              
        mov (1|M0)               r92.2<1>:f    r12.0<0;1,0>:hf                  {F@2}
(f1.1)  mov (1|M0)               r91.4<1>:f    -r91.4<0;1,0>:f                 
        shl (1|M0)               r2.0<1>:d     r92.1<0;1,0>:d    1:w               {Compacted}
(f1.0)  mov (1|M0)               r92.2<1>:f    -r92.2<0;1,0>:f                  {F@2}
        shr (1|M0)               r3.7<1>:ud    r92.0<0;1,0>:ud   0x1F:uw             
        sel (1|M0)    (lt)f0.0   r92.2<1>:f    r92.2<0;1,0>:f    448.0:f               {F@1}
        addc (1|M0)              r5.0<1>:ud    r4.0<0;1,0>:ud    r91.5<0;1,0>:ud  {AccWrEn,I@3}
        shr (1|M0)               r92.3<1>:ud   r92.2<0;1,0>:ud   0x17:uw              {F@1}
        mov (1|M0)               r1.4<2>:hf    r91.4<0;1,0>:f                  
        and (1|M0)               r92.3<1>:ud   r92.3<0;1,0>:ud   0xFF:uw              {I@1}
        or (1|M0)                r91.6<1>:d    r2.0<0;1,0>:d     r3.7<0;1,0>:d   
        sel (1|M0)    (ge)f0.0   r92.3<1>:ud   r92.3<0;1,0>:ud   0x79:uw              {I@2}
        sync.nop                             null                             {Compacted,$11.src}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$10.src}
        shl (1|M0)               r92.3<1>:ud   r92.3<0;1,0>:ud   0x17:uw              {I@2}
        mov (1|M0)               r8.0<1>:f     r5.0<0;1,0>:f                    {Compacted,$9.src}
        add (1|M0)               r13.0<1>:ud   -r92.3<0;1,0>:ud  0x80800000:ud              {I@1}
        mov (1|M0)               r10.0<1>:d    r1.4<0;1,0>:uw                   {F@2}
        mul (1|M0)               r14.0<1>:f    r92.2<0;1,0>:f    r13.0<0;1,0>:f   {Compacted,I@2}
        add3 (1|M0)              r8.1<1>:d     r6.0<0;0>:d       r4.1<0;0>:d       r91.6<0>:d      
        mov (1|M0)               r91.7<1>:d    r14.0<0;1,0>:f                   {Compacted,F@1}
        send.ugm (1|M0)          null     r8      r10:1   0x0            0x04000B84           {A@2,$9} // wr:2+1, rd:0; store.ugm.d16u32.a64
        mov (1|M0)               r92.4<1>:f    r91.7<0;1,0>:d                   {I@1}
        mad (1|M0)               r92.2<1>:f    -r92.4<0;0>:f     r13.0<0;0>:f      r92.2<0>:f       {F@1}
        cmp (1|M0)    (gt)f1.1   null<1>:f     r92.2<0;1,0>:f    0.5:f               {F@1}
(W)     and (1|M0)               f1.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw              {F@1}
(f1.1.any8h) goto (8|M0)                     L5776                  L5776                
L5680:
        cmp (1|M0)    (lt)f0.1   null<1>:f     r92.2<0;1,0>:f    0.5:f              
        and (1|M0)               r91.7<1>:d    r91.7<0;1,0>:d    1:w              
        add (1|M0)               r1.2<1>:f     r92.4<0;1,0>:f    1.0:f              
(~f0.1) cmp (1|M0)    (eq)f0.1   null<1>:d     r91.7<0;1,0>:d    0:w               {A@1}
(~f0.1) mov (1|M0)               r92.4<1>:f    r1.2<0;1,0>:f                    {F@1}
        goto (8|M0)                          L5776                  L5808                
L5776:
        join (8|M0)                          L5808                                
L5792:
        add (1|M0)               r92.4<1>:f    r92.4<0;1,0>:f    1.0:f               {F@1}
L5808:
        join (8|M0)                          L6616                                
L5824:
        add (1|M0)               a0.0<1>:uw    r90.12<0;1,0>:uw  0xAE0:uw              {A@1}
        add (1|M0)               r92.3<1>:ud   r92.3<0;1,0>:ud   0xFE800000:ud             
        addc (1|M0)              r2.0<1>:ud    r4.2<0;1,0>:ud    r91.5<0;1,0>:ud  {AccWrEn}
        mul (1|M0)               r92.4<1>:f    r92.4<0;1,0>:f    r92.3<0;1,0>:f   {A@1}
        cmp (1|M0)    (lt)f0.1   null<1>:f     r[a0.0]<0;1,0>:f  0.0:f              
        sync.nop                             null                             {Compacted,A@1}
        sync.nop                             null                             {Compacted,$9.src}
(W)     mov (1|M0)               r9.0<1>:f     -r[a0.0]<0;1,0>:f                {A@1}
(W)     mov (1|M0)               r10.0<1>:f    r[a0.0]<0;1,0>:f                 {A@1}
(f1.0)  mov (1|M0)               r92.4<1>:f    -r92.4<0;1,0>:f                  {A@1}
(f0.1)  sel (1|M0)               r92.6<1>:f    r9.0<0;1,0>:f     r10.0<0;1,0>:f   {F@2}
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        sel (1|M0)    (lt)f0.0   r92.6<1>:f    r92.6<0;1,0>:f    448.0:f               {F@1}
        mov (1|M0)               r1.4<2>:hf    r92.4<0;1,0>:f                  
        shr (1|M0)               r92.7<1>:ud   r92.6<0;1,0>:ud   0x17:uw              {F@2}
        mov (1|M0)               r6.0<1>:f     r2.0<0;1,0>:f                    {Compacted,I@3}
        and (1|M0)               r92.7<1>:ud   r92.7<0;1,0>:ud   0xFF:uw              {I@1}
        add3 (1|M0)              r6.1<1>:d     r5.0<0;0>:d       r4.3<0;0>:d       r91.6<0>:d      
        sel (1|M0)    (ge)f0.0   r92.7<1>:ud   r92.7<0;1,0>:ud   0x79:uw              {I@2}
        mov (1|M0)               r8.0<1>:d     r1.4<0;1,0>:uw                   {F@2}
        shl (1|M0)               r92.7<1>:ud   r92.7<0;1,0>:ud   0x17:uw              {I@2}
        send.ugm (1|M0)          null     r6      r8:1    0x0            0x04000B84           {A@1,$10} // wr:2+1, rd:0; store.ugm.d16u32.a64
        add (1|M0)               r11.0<1>:ud   -r92.7<0;1,0>:ud  0x80800000:ud              {I@1}
        mul (1|M0)               r12.0<1>:f    r92.6<0;1,0>:f    r11.0<0;1,0>:f   {Compacted,I@1}
        mov (1|M0)               r92.5<1>:d    r12.0<0;1,0>:f                   {Compacted,F@1}
        mov (1|M0)               r93.0<1>:f    r92.5<0;1,0>:d                   {Compacted,I@1}
        mad (1|M0)               r92.6<1>:f    -r93.0<0;0>:f     r11.0<0;0>:f      r92.6<0>:f       {F@1}
        cmp (1|M0)    (gt)f1.0   null<1>:f     r92.6<0;1,0>:f    0.5:f               {F@1}
(W)     and (1|M0)               f1.0<1>:uw    f1.0<0;1,0>:uw    0x1:uw              {F@1}
(f1.0.any8h) goto (8|M0)                     L6336                  L6336                
L6248:
        cmp (1|M0)    (lt)f1.1   null<1>:f     r92.6<0;1,0>:f    0.5:f              
        and (1|M0)               r92.5<1>:d    r92.5<0;1,0>:d    1:w              
        add (1|M0)               r1.2<1>:f     r93.0<0;1,0>:f    1.0:f               {Compacted}
(~f1.1) cmp (1|M0)    (eq)f1.1   null<1>:d     r92.5<0;1,0>:d    0:w               {A@1}
(~f1.1) mov (1|M0)               r93.0<1>:f    r1.2<0;1,0>:f                    {F@1}
        goto (8|M0)                          L6336                  L6360                
L6336:
        join (8|M0)                          L6360                                
L6352:
        add (1|M0)               r93.0<1>:f    r93.0<0;1,0>:f    1.0:f               {Compacted,F@1}
L6360:
        join (8|M0)                          L6616                                
L6376:
        add (1|M0)               r92.7<1>:ud   r92.7<0;1,0>:ud   0xFE800000:ud             
        addc (1|M0)              r2.0<1>:ud    r4.4<0;1,0>:ud    r91.5<0;1,0>:ud  {AccWrEn}
        mul (1|M0)               r93.0<1>:f    r93.0<0;1,0>:f    r92.7<0;1,0>:f   {Compacted,A@1}
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
(f0.1)  mov (1|M0)               r93.0<1>:f    -r93.0<0;1,0>:f                  {F@1}
(W)     and (1|M0)               f0.1<1>:uw    f0.0<0;1,0>:uw    0x1:uw              {F@1}
        mov (1|M0)               r1.4<2>:hf    r93.0<0;1,0>:f                  
        sync.nop                             null                             {Compacted,$10.src}
        mov (1|M0)               r6.0<1>:f     r2.0<0;1,0>:f                    {Compacted,I@3}
        add3 (1|M0)              r6.1<1>:d     r5.0<0;0>:d       r4.5<0;0>:d       r91.6<0>:d       {I@2}
        mov (1|M0)               r8.0<1>:d     r1.4<0;1,0>:uw                   {F@2}
        send.ugm (1|M0)          null     r6      r8:1    0x0            0x04000B84           {A@1,$11} // wr:2+1, rd:0; store.ugm.d16u32.a64
(~f0.1.any8h) goto (8|M0)                    L6616                  L6616                
L6552:
(W)     mov (1|M0)               f0.0<1>:uw    0x0:uw                             
        mov (1|M0)               r92.0<2>:f    1.4013e-45:f                              
        mov (1|M0)               r92.1<2>:d    0:d                              
        goto.b (8|M0)                        L6616                  L4704                
L6616:
        join (8|M0)                          L6696                                
L6632:
        add (1|M0)               r90.4<1>:d    r90.4<0;1,0>:d    1:w              
        cmp (1|M0)    (eq)f1.1   null<1>:d     r90.4<0;1,0>:d    4:w               {I@1}
(W)     and (1|M0)               f0.0<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(~f0.0.any8h) goto.b (8|M0)                  L6696                  L4592                
L6696:
        join (8|M0)                          L6712                                
L6712:
(W)     mov (8|M0)               r127.0<1>:f   r0.0<1;1,0>:f                    {Compacted}
(W)     send.ugm (1|M0)          r5       r0      null:0  0x0            0x0210641F           {$12} // wr:1+0, rd:1; fence invalid flush type scoped to tile
(W)     mov (8|M0)               null<1>:ud    r5.0<1;1,0>:ud                   {$12.dst}
(W)     send.gtwy (1|M0)         null     r127    null:0  0x0            0x02000010           {EOT,A@1} // wr:1+0, rd:0; end of thread
L6768:
        mov (1|M0)               r1.2<1>:d     cr0.0<0;1,0>:ud                  {A@1}
        and (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   -1265:w               {A@1}
        or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   1264:w               {A@1}
        mov (1|M0)               r2.0<1>:f     r93.1<0;1,0>:ud                  {Compacted,A@1}
        mov (1|M0)               r9.0<1>:f     0xB4C00000:f                               {Compacted}
        math.inv (1|M0)          r8.0<1>:f     r2.0<0;1,0>:f                    {@2,$13}
        mov (1|M0)               r5.1<1>:f     r93.5<0;1,0>:ud                  {I@4}
        sync.nop                             null                             {Compacted,$13.dst}
        mad (1|M0)               r8.0<1>:f     r8.0<0;0>:f       r9.0<0;0>:f       r8.0<0>:f        {F@2}
        mov (1|M0)               r93.4<1>:ud   r2.0<0;1,0>:f                   
        mov (1|M0)               r6.0<1>:ud    r5.1<0;1,0>:f                    {F@2}
        mul (1|M0)               r10.0<1>:f    r8.0<0;1,0>:f     r5.1<0;1,0>:f    {Compacted,F@1}
        add (1|M0)               r93.4<1>:ud   r93.1<0;1,0>:ud   -r93.4<0;1,0>:ud {I@2}
        add (1|M0)               r6.0<1>:ud    r93.5<0;1,0>:ud   -r6.0<0;1,0>:ud  {Compacted,I@2}
        mov (1|M0)               r11.0<1>:ud   r10.0<0;1,0>:f                   {F@1}
        mov (1|M0)               r5.0<1>:f     r93.4<0;1,0>:ud                  {Compacted,I@3}
        mov (1|M0)               r7.0<1>:f     r6.0<0;1,0>:ud                   {Compacted,I@2}
        mov (1|M0)               r12.0<1>:f    r11.0<0;1,0>:ud                  {Compacted,I@1}
(W)     mov (1|M0)               r15.0<1>:hf   0x1:hf                             
        mad (1|M0)               r5.1<1>:f     r5.1<0;0>:f       r12.0<0;0>:f      -r2.0<0>:f       {F@2}
        mad (1|M0)               r12.0<1>:f    r7.0<0;0>:f       r12.0<0;0>:f      -r5.0<0>:f      
        add (1|M0)               r5.1<1>:f     r5.1<0;1,0>:f     r12.0<0;1,0>:f   {Compacted,F@1}
        mul (1|M0)               r8.0<1>:f     r8.0<0;1,0>:f     r5.1<0;1,0>:f    {Compacted,F@1}
        mov (1|M0)               r13.0<1>:ud   r8.0<0;1,0>:f                    {F@1}
        add (1|M0)               r11.0<1>:ud   r11.0<0;1,0>:ud   r13.0<0;1,0>:ud  {Compacted,I@1}
(W)     mul (1|M0)               acc0.0<1>:ud  r11.0<0;1,0>:ud   r93.2<0;1,0>:uw  {I@1}
        mach (1|M0)              r14.0<1>:ud   r11.0<0;1,0>:ud   r93.1<0;1,0>:ud  {Compacted}
        add (1|M0)               r93.5<1>:ud   r93.5<0;1,0>:ud   -r14.0<0;1,0>:ud {I@1}
        cmp (1|M0)    (ge)f1.1   null<1>:ud    r93.5<0;1,0>:ud   r93.1<0;1,0>:ud  {I@1}
(f1.1)  sel (1|M0)               r16.0<1>:d    r15.0<0;1,0>:w    0:w              
        add (1|M0)               r93.2<1>:ud   r11.0<0;1,0>:ud   r16.0<0;1,0>:ud  {Compacted,I@1}
        mov (1|M0)               cr0.0<1>:ud   r1.2<0;1,0>:d                    {A@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        ret (8|M0)                           r93.6                            {A@1}
L7224:
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
