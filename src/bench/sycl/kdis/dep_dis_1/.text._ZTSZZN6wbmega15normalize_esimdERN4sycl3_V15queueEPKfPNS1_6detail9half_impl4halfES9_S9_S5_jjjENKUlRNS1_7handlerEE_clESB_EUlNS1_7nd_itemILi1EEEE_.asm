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
(W)     mov (2|M0)               r2.0<1>:ud    r2.6<1;1,0>:ud                   {$1.dst}
        and (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   -1265:w               {A@1}
        or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   1216:w               {A@1}
        shl (1|M0)               r3.6<1>:d     r0.1<0;1,0>:d     3:w               {A@1}
        shr (1|M0)               r4.0<1>:ud    r1.0<0;1,0>:uw    0x2:uw              {$0.dst}
        shl (1|M0)               r9.0<1>:ud    r1.0<0;1,0>:uw    0x1:uw             
        add (1|M0)               r5.0<1>:d     r3.6<0;1,0>:d     r4.0<0;1,0>:d    {Compacted,I@2}
        and (1|M0)               r85.0<1>:ud   r9.0<0;1,0>:ud    0x6:uw              {I@2}
        mul (1|M0)               acc0.0<1>:ud  r5.0<0;1,0>:ud    r2.8<0;1,0>:uw   {I@2}
        mach (1|M0)              r8.0<1>:ud    r5.0<0;1,0>:ud    r2.4<0;1,0>:ud   {AccWrEn}
        shl (1|M0)               r17.0<1>:d    r85.0<0;1,0>:d    2:w               {Compacted,I@3}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        shl (1|M0)               r22.0<1>:d    r2.5<0;1,0>:d     2:w               {Compacted}
        shl (1|M0)               r12.0<1>:d    r7.0<0;1,0>:d     2:w               {Compacted,I@2}
        shl (1|M0)               r10.0<1>:d    r8.0<0;1,0>:d     2:w               {Compacted}
        addc (1|M0)              r13.0<1>:ud   r2.2<0;1,0>:ud    r12.0<0;1,0>:ud  {AccWrEn,I@2}
        shr (1|M0)               r11.0<1>:ud   r7.0<0;1,0>:ud    0x1E:uw             
        mov (1|M0)               r14.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r18.0<1>:ud   r13.0<0;1,0>:ud   r17.0<0;1,0>:ud  {AccWrEn,I@3}
        shr (1|M0)               r21.0<1>:ud   r2.5<0;1,0>:ud    0x1E:uw             
        or (1|M0)                r12.1<1>:d    r10.0<0;1,0>:d    r11.0<0;1,0>:d   {Compacted,I@4}
        mov (1|M0)               r19.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r23.0<1>:ud   r13.0<0;1,0>:ud   r22.0<0;1,0>:ud  {AccWrEn}
        shr (1|M0)               r16.0<1>:ud   r85.0<0;1,0>:ud   0x1E:uw             
        or (1|M0)                r22.1<1>:d    r21.0<0;1,0>:d    0:w               {Compacted,I@5}
        add3 (1|M0)              r15.1<1>:d    r14.0<0;0>:d      r2.3<0;0>:d       r12.1<0>:d       {I@5}
        mov (1|M0)               r24.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r26.0<1>:ud   r23.0<0;1,0>:ud   r17.0<0;1,0>:ud  {AccWrEn,I@5}
        or (1|M0)                r17.1<1>:d    r16.0<0;1,0>:d    0:w               {Compacted,I@5}
        add3 (1|M0)              r25.1<1>:d    r24.0<0;0>:d      r15.1<0;0>:d      r22.1<0>:d       {I@3}
        mov (1|M0)               r27.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r20.0<1>:f    r18.0<0;1,0>:f                   {Compacted}
        mov (1|M0)               r28.0<1>:f    r26.0<0;1,0>:f                   {Compacted,I@4}
        add3 (1|M0)              r20.1<1>:d    r19.0<0;0>:d      r15.1<0;0>:d      r17.1<0>:d       {I@3}
        add3 (1|M0)              r28.1<1>:d    r27.0<0;0>:d      r25.1<0;0>:d      r17.1<0>:d       {I@2}
        send.ugm (1|M0)          r29      r20     null:0  0x0            0x04100580           {A@2,$2} // wr:2+0, rd:1; load.ugm.d32.a64
        send.ugm (1|M0)          r37      r28     null:0  0x0            0x04100580           {A@1,$2} // wr:2+0, rd:1; load.ugm.d32.a64
        addc (1|M0)              r31.0<1>:ud   r20.0<0;1,0>:ud   0x4:ud              {AccWrEn}
        add (1|M0)               r6.0<1>:d     r3.6<0;1,0>:d     r4.0<0;1,0>:d    {Compacted}
        mov (1|M0)               r32.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r39.0<1>:ud   r28.0<0;1,0>:ud   0x4:ud              {AccWrEn}
        mov (1|M0)               r34.0<1>:f    r31.0<0;1,0>:f                   {Compacted,I@4}
        mov (1|M0)               r40.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r45.0<1>:ud   r20.0<0;1,0>:ud   0x20:ud              {AccWrEn}
        add3 (1|M0)              r34.1<1>:d    r32.0<0;0>:d      r20.1<0;0>:d      0:w               {I@4}
        mov (1|M0)               r48.0<1>:f    r45.0<0;1,0>:f                   {Compacted,I@2}
        mov (1|M0)               r46.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r52.0<1>:ud   r48.0<0;1,0>:ud   0x4:ud              {AccWrEn,F@1}
        add3 (1|M0)              r48.1<1>:d    r46.0<0;0>:d      r20.1<0;0>:d      0:w               {I@2}
        mov (1|M0)               r53.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r58.0<1>:ud   r28.0<0;1,0>:ud   0x20:ud              {AccWrEn}
        send.ugm (1|M0)          r49      r48     null:0  0x0            0x04100580           {A@3,$3} // wr:2+0, rd:1; load.ugm.d32.a64
        mov (1|M0)               r60.0<1>:f    r58.0<0;1,0>:f                   {Compacted,I@1}
        mov (1|M0)               r59.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r64.0<1>:ud   r60.0<0;1,0>:ud   0x4:ud              {AccWrEn,F@1}
        mov (1|M0)               r42.0<1>:f    r39.0<0;1,0>:f                   {Compacted}
        mov (1|M0)               r65.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r70.0<1>:ud   r20.0<0;1,0>:ud   0x40:ud              {AccWrEn}
        add3 (1|M0)              r42.1<1>:d    r40.0<0;0>:d      r28.1<0;0>:d      0:w              
        mov (1|M0)               r72.0<1>:f    r70.0<0;1,0>:f                   {Compacted,I@2}
        mov (1|M0)               r71.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r75.0<1>:ud   r72.0<0;1,0>:ud   0x4:ud              {AccWrEn,F@1}
        send.ugm (1|M0)          r35      r34     null:0  0x0            0x04100580           {$4} // wr:2+0, rd:1; load.ugm.d32.a64
        mov (1|M0)               r76.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r81.0<1>:ud   r28.0<0;1,0>:ud   0x40:ud              {AccWrEn}
        send.ugm (1|M0)          r43      r42     null:0  0x0            0x04100580           {A@5,$5} // wr:2+0, rd:1; load.ugm.d32.a64
        mov (1|M0)               r84.0<1>:f    r81.0<0;1,0>:f                   {Compacted,I@1}
        mov (1|M0)               r82.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r7.0<1>:ud    r84.0<0;1,0>:ud   0x4:ud              {AccWrEn,F@1}
        mov (1|M0)               r54.0<1>:f    r52.0<0;1,0>:f                   {Compacted}
        mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r14.0<1>:ud   r20.0<0;1,0>:ud   0x60:ud              {AccWrEn}
        add3 (1|M0)              r54.1<1>:d    r53.0<0;0>:d      r48.1<0;0>:d      0:w              
        mov (1|M0)               r18.0<1>:f    r14.0<0;1,0>:f                   {Compacted,I@2}
        mov (1|M0)               r16.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r22.0<1>:ud   r18.0<0;1,0>:ud   0x4:ud              {AccWrEn,F@1}
        add3 (1|M0)              r72.1<1>:d    r71.0<0;0>:d      r20.1<0;0>:d      0:w              
        mov (1|M0)               r23.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r27.0<1>:ud   r28.0<0;1,0>:ud   0x60:ud              {AccWrEn}
        add3 (1|M0)              r84.1<1>:d    r82.0<0;0>:d      r28.1<0;0>:d      0:w              
        mov (1|M0)               r32.0<1>:f    r27.0<0;1,0>:f                   {Compacted,I@2}
        send.ugm (1|M0)          r55      r54     null:0  0x0            0x04100580           {$6} // wr:2+0, rd:1; load.ugm.d32.a64
        add3 (1|M0)              r60.1<1>:d    r59.0<0;0>:d      r28.1<0;0>:d      0:w              
        mov (1|M0)               r78.0<1>:f    r75.0<0;1,0>:f                   {Compacted}
        mov (1|M0)               r10.0<1>:f    r7.0<0;1,0>:f                    {Compacted}
        mov (1|M0)               r30.0<2>:hf   r29.0<0;1,0>:f                  
        mov (1|M0)               r38.0<2>:hf   r37.0<0;1,0>:f                   {$2.dst}
        mov (1|M0)               r29.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,F@2}
        addc (1|M0)              r37.0<1>:ud   r32.0<0;1,0>:ud   0x4:ud              {AccWrEn,F@1}
        add3 (1|M0)              r18.1<1>:d    r16.0<0;0>:d      r20.1<0;0>:d      0:w              
        add3 (1|M0)              r78.1<1>:d    r76.0<0;0>:d      r72.1<0;0>:d      0:w              
        add3 (1|M0)              r10.1<1>:d    r8.0<0;0>:d       r84.1<0;0>:d      0:w               {I@6}
        add3 (1|M0)              r32.1<1>:d    r29.0<0;0>:d      r28.1<0;0>:d      0:w               {I@5}
        mov (1|M0)               r39.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        send.ugm (1|M0)          r73      r72     null:0  0x0            0x04100580           {$7} // wr:2+0, rd:1; load.ugm.d32.a64
        send.ugm (1|M0)          r4       r84     null:0  0x0            0x04100580           {$8} // wr:2+0, rd:1; load.ugm.d32.a64
        send.ugm (1|M0)          r61      r60     null:0  0x0            0x04100580           {$9} // wr:2+0, rd:1; load.ugm.d32.a64
        send.ugm (1|M0)          r79      r78     null:0  0x0            0x04100580           {A@4,$10} // wr:2+0, rd:1; load.ugm.d32.a64
        send.ugm (1|M0)          r11      r10     null:0  0x0            0x04100580           {A@3,$11} // wr:2+0, rd:1; load.ugm.d32.a64
        mov (1|M0)               r66.0<1>:f    r64.0<0;1,0>:f                   {Compacted}
        mov (1|M0)               r24.0<1>:d    r22.0<0;1,0>:d                  
        add3 (1|M0)              r66.1<1>:d    r65.0<0;0>:d      r60.1<0;0>:d      0:w              
        mov (1|M0)               r40.0<1>:d    r37.0<0;1,0>:d                  
        add3 (1|M0)              r24.1<1>:d    r23.0<0;0>:d      r18.1<0;0>:d      0:w              
        add3 (1|M0)              r40.1<1>:d    r39.0<0;0>:d      r32.1<0;0>:d      0:w               {I@5}
        send.ugm (1|M0)          r19      r18     null:0  0x0            0x04100580           {$12} // wr:2+0, rd:1; load.ugm.d32.a64
        send.ugm (1|M0)          r33      r32     null:0  0x0            0x04100580           {$13} // wr:2+0, rd:1; load.ugm.d32.a64
        send.ugm (1|M0)          r67      r66     null:0  0x0            0x04100580           {A@1,$14} // wr:2+0, rd:1; load.ugm.d32.a64
        send.ugm (1|M0)          r25      r24     null:0  0x0            0x04100580           {A@2,$15} // wr:2+0, rd:1; load.ugm.d32.a64
        send.ugm (1|M0)          r41      r40     null:0  0x0            0x04100580           {A@1,$0} // wr:2+0, rd:1; load.ugm.d32.a64
        mov (1|M0)               r86.0<1>:f    r30.0<0;1,0>:hf                 
        mov (1|M0)               r50.0<2>:hf   r49.0<0;1,0>:f                   {$3.dst}
        mul (1|M0)               r30.0<1>:hf   r30.0<0;1,0>:hf   r30.0<0;1,0>:hf 
        mov (1|M0)               r36.0<2>:hf   r35.0<0;1,0>:f                   {$4.dst}
        mov (1|M0)               r51.0<1>:f    r50.0<0;1,0>:hf                  {F@3}
        mov (1|M0)               r44.0<2>:hf   r43.0<0;1,0>:f                   {$5.dst}
        mov (1|M0)               r43.0<1>:f    r30.0<0;1,0>:hf                  {F@4}
        mov (1|M0)               r86.1<1>:f    r36.0<0;1,0>:hf                  {F@4}
        mad (1|M0)               r51.0<1>:f    r43.0<0;0>:f      r51.0<0;0>:f      r51.0<0>:f       {F@2}
        mul (1|M0)               r36.0<1>:hf   r36.0<0;1,0>:hf   r36.0<0;1,0>:hf 
        mov (1|M0)               r87.0<1>:f    r38.0<0;1,0>:hf                 
        mov (1|M0)               r44.2<2>:hf   r51.0<0;1,0>:f                   {F@3}
        mul (1|M0)               r38.0<1>:hf   r38.0<0;1,0>:hf   r38.0<0;1,0>:hf 
        mov (1|M0)               r51.0<1>:f    r36.0<0;1,0>:hf                  {F@4}
        mov (1|M0)               r87.1<1>:f    r44.0<0;1,0>:hf                 
        mov (1|M0)               r47.0<1>:f    r38.0<0;1,0>:hf                  {F@3}
        mul (1|M0)               r44.0<1>:hf   r44.0<0;1,0>:hf   r44.0<0;1,0>:hf 
        mov (1|M0)               r86.2<1>:f    r50.0<0;1,0>:hf                 
        mov (1|M0)               r56.0<2>:hf   r55.0<0;1,0>:f                   {$6.dst}
        mov (1|M0)               r55.0<1>:f    r44.0<0;1,0>:hf                  {F@3}
        mov (1|M0)               r57.0<1>:f    r56.0<0;1,0>:hf                  {F@2}
        mov (1|M0)               r86.3<1>:f    r56.0<0;1,0>:hf                 
        mad (1|M0)               r57.0<1>:f    r51.0<0;0>:f      r57.0<0;0>:f      r57.0<0>:f       {F@2}
        mov (1|M0)               r52.0<2>:hf   r57.0<0;1,0>:f                   {F@1}
        mov (1|M0)               r74.0<2>:hf   r73.0<0;1,0>:f                   {$7.dst}
        mov (1|M0)               r5.0<2>:hf    r4.0<0;1,0>:f                    {$8.dst}
        mov (1|M0)               r62.0<2>:hf   r61.0<0;1,0>:f                   {$9.dst}
        mov (1|M0)               r80.0<2>:hf   r79.0<0;1,0>:f                   {$10.dst}
        mov (1|M0)               r12.0<2>:hf   r11.0<0;1,0>:f                   {$11.dst}
        mov (1|M0)               r86.4<1>:f    r74.0<0;1,0>:hf                  {F@5}
        mov (1|M0)               r87.4<1>:f    r5.0<0;1,0>:hf                   {F@5}
        mov (1|M0)               r63.0<1>:f    r62.0<0;1,0>:hf                  {F@5}
        mov (1|M0)               r86.5<1>:f    r80.0<0;1,0>:hf                  {F@5}
        mov (1|M0)               r87.5<1>:f    r12.0<0;1,0>:hf                  {F@5}
        mul (1|M0)               r74.0<1>:hf   r74.0<0;1,0>:hf   r74.0<0;1,0>:hf 
        mul (1|M0)               r5.0<1>:hf    r5.0<0;1,0>:hf    r5.0<0;1,0>:hf  
        mul (1|M0)               r80.0<1>:hf   r80.0<0;1,0>:hf   r80.0<0;1,0>:hf 
        mul (1|M0)               r12.0<1>:hf   r12.0<0;1,0>:hf   r12.0<0;1,0>:hf 
        mov (1|M0)               r20.0<2>:hf   r19.0<0;1,0>:f                   {$12.dst}
        mov (1|M0)               r34.0<2>:hf   r33.0<0;1,0>:f                   {$13.dst}
        mov (1|M0)               r68.0<2>:hf   r67.0<0;1,0>:f                   {$14.dst}
        mov (1|M0)               r26.0<2>:hf   r25.0<0;1,0>:f                   {$15.dst}
        mov (1|M0)               r42.0<2>:hf   r41.0<0;1,0>:f                   {$0.dst}
        mad (1|M0)               r63.0<1>:f    r47.0<0;0>:f      r63.0<0;0>:f      r63.0<0>:f      
        mov (1|M0)               r45.0<1>:f    r74.0<0;1,0>:hf                  {F@7}
        mov (1|M0)               r49.0<1>:f    r5.0<0;1,0>:hf                   {F@7}
        mov (1|M0)               r53.0<1>:f    r80.0<0;1,0>:hf                  {F@7}
        mov (1|M0)               r57.0<1>:f    r12.0<0;1,0>:hf                  {F@7}
        mov (1|M0)               r21.0<1>:f    r20.0<0;1,0>:hf                  {F@7}
        mov (1|M0)               r35.0<1>:f    r34.0<0;1,0>:hf                  {F@7}
        mov (1|M0)               r69.0<1>:f    r68.0<0;1,0>:hf                  {F@7}
        mov (1|M0)               r86.7<1>:f    r26.0<0;1,0>:hf                  {F@7}
        mov (1|M0)               r87.7<1>:f    r42.0<0;1,0>:hf                  {F@7}
        shl (1|M0)               r61.0<1>:ud   r1.0<0;1,0>:uw    0x2:uw             
        mov (1|M0)               r48.0<2>:hf   r63.0<0;1,0>:f                   {F@7}
        mad (1|M0)               r21.0<1>:f    r45.0<0;0>:f      r21.0<0;0>:f      r21.0<0>:f       {F@6}
        mad (1|M0)               r35.0<1>:f    r49.0<0;0>:f      r35.0<0;0>:f      r35.0<0>:f       {F@6}
        mad (1|M0)               r69.0<1>:f    r55.0<0;0>:f      r69.0<0;0>:f      r69.0<0>:f       {F@6}
        mad (1|M0)               r53.0<1>:f    r53.0<0;0>:f      r86.7<0;0>:f      r86.7<0>:f       {F@6}
        mad (1|M0)               r57.0<1>:f    r57.0<0;0>:f      r87.7<0;0>:f      r87.7<0>:f       {F@6}
(W)     mov (1|M0)               r63.0<1>:ud   0x3FFF0:ud                              {F@6}
        mov (1|M0)               r87.2<1>:f    r62.0<0;1,0>:hf                 
        mov (1|M0)               r46.0<2>:hf   r21.0<0;1,0>:f                   {F@6}
        mov (1|M0)               r50.0<2>:hf   r35.0<0;1,0>:f                   {F@6}
        mov (1|M0)               r56.0<2>:hf   r69.0<0;1,0>:f                   {F@6}
        mov (1|M0)               r54.0<2>:hf   r53.0<0;1,0>:f                   {F@6}
        mov (1|M0)               r58.0<2>:hf   r57.0<0;1,0>:f                   {F@6}
        and (1|M0)               r62.0<1>:ud   r61.0<0;1,0>:ud   0x3FFF0:ud              {A@2}
        bfn.0xEA (1|M0)          r61.0<1>:ud   r85.0<0;0>:ud     r61.0<0;0>:ud     r63.0<0>:ud      {I@2} // s0|s1&s2
        add (1|M0)               r44.2<1>:hf   r44.2<0;1,0>:hf   r46.0<0;1,0>:hf  {F@5}
        add (1|M0)               r48.0<1>:hf   r48.0<0;1,0>:hf   r50.0<0;1,0>:hf  {F@5}
        add (1|M0)               r52.0<1>:hf   r52.0<0;1,0>:hf   r54.0<0;1,0>:hf  {F@4}
        add (1|M0)               r56.0<1>:hf   r56.0<0;1,0>:hf   r58.0<0;1,0>:hf  {F@4}
        shl (1|M0)               r64.0<1>:ud   r61.0<0;1,0>:ud   0x2:uw              {I@1}
        mov (1|M0)               r60.0<1>:f    r44.2<0;1,0>:hf                  {F@4}
        mov (1|M0)               r66.0<1>:f    r48.0<0;1,0>:hf                  {F@4}
        mov (1|M0)               r60.1<1>:f    r52.0<0;1,0>:hf                  {F@4}
        mov (1|M0)               r66.1<1>:f    r56.0<0;1,0>:hf                  {F@4}
        or (1|M0)                r67.0<1>:ud   r64.0<0;1,0>:ud   0x20:uw              {I@1}
        send.slm (1|M0)          null     r64     r60:2   0x0            0x02000704           {A@2,$1} // wr:1+2, rd:0; store.slm.d64.a32
        send.slm (1|M0)          null     r67     r66:2   0x0            0x02000704           {A@1,$2} // wr:1+2, rd:0; store.slm.d64.a32
        mov (1|M0)               r86.6<1>:f    r20.0<0;1,0>:hf                 
        mov (1|M0)               r87.6<1>:f    r34.0<0;1,0>:hf                 
        mov (1|M0)               r87.3<1>:f    r68.0<0;1,0>:hf                 
(W)     send.slm (1|M0)          r68      r0      null:0  0x0            0x0210001F           {A@1,$3} // wr:1+0, rd:1; fence.slm.none.group
(W)     mov (1|M0)               r69.2<1>:ud   0x0:ud                             
(W)     mov (2|M0)               r69.10<1>:ub  r0.11<0;1,0>:ub                 
(W)     mov (8|M0)               null<1>:ud    r68.0<1;1,0>:ud                  {$3.dst}
(W)     send.gtwy (1|M0)         null     r69     null:0  0x0            0x02000004           {A@2,$4} // wr:1+0, rd:0; signal barrier
(W)     sync.bar                             null                            
        send.ugm (1|M0)          r11      r2      null:0  0x0            0x04100580           {$5} // wr:2+0, rd:1; load.ugm.d32.a64
        shl (1|M0)               r70.0<1>:ud   r62.0<0;1,0>:ud   0x2:uw             
        shl (1|M0)               r13.1<1>:d    r2.5<0;1,0>:d     1:w              
        or (1|M0)                r82.0<1>:ud   r70.0<0;1,0>:ud   0x20:uw              {I@2}
        send.slm (1|M0)          r71      r70     null:0  0x0            0x0210B700           {$6} // wr:1+0, rd:1; load.slm.d64x4t.a32
        send.slm (1|M0)          r83      r82     null:0  0x0            0x0210B700           {A@1,$7} // wr:1+0, rd:1; load.slm.d64x4t.a32
        shl (1|M0)               r15.2<1>:d    r13.1<0;1,0>:d    2:w              
        shr (1|M0)               r14.0<1>:ud   r13.1<0;1,0>:ud   0x1E:uw             
        addc (1|M0)              r16.0<1>:ud   r13.0<0;1,0>:ud   r15.2<0;1,0>:ud  {AccWrEn,I@2}
        shr (1|M0)               r12.0<1>:ud   r6.0<0;1,0>:ud    0x1B:uw             
        or (1|M0)                r15.3<1>:d    r14.0<0;1,0>:d    0:w               {Compacted,I@3}
        add (1|M0)               r72.0<1>:f    r71.0<0;1,0>:f    r71.4<0;1,0>:f   {Compacted,$6.dst}
        add (1|M0)               r74.0<1>:f    r71.2<0;1,0>:f    r71.6<0;1,0>:f  
        add (1|M0)               r76.0<1>:f    r71.1<0;1,0>:f    r71.5<0;1,0>:f  
        add (1|M0)               r78.0<1>:f    r71.3<0;1,0>:f    r71.7<0;1,0>:f  
        add (1|M0)               r84.0<1>:f    r83.0<0;1,0>:f    r83.4<0;1,0>:f   {Compacted,$7.dst}
        add (1|M0)               r3.6<1>:f     r83.2<0;1,0>:f    r83.6<0;1,0>:f   {$5.src}
        add (1|M0)               r5.0<1>:f     r83.1<0;1,0>:f    r83.5<0;1,0>:f  
        add (1|M0)               r7.0<1>:f     r83.3<0;1,0>:f    r83.7<0;1,0>:f  
        mov (1|M0)               r73.0<2>:hf   r72.0<0;1,0>:f                   {F@7}
        mov (1|M0)               r75.0<2>:hf   r74.0<0;1,0>:f                   {F@7}
        mov (1|M0)               r77.0<2>:hf   r76.0<0;1,0>:f                   {F@7}
        mov (1|M0)               r79.0<2>:hf   r78.0<0;1,0>:f                   {F@7}
        mov (1|M0)               r1.4<2>:hf    r84.0<0;1,0>:f                   {F@7}
        mov (1|M0)               r4.0<2>:hf    r3.6<0;1,0>:f                    {F@7}
        mov (1|M0)               r6.4<2>:hf    r5.0<0;1,0>:f                    {F@7}
        mov (1|M0)               r8.0<2>:hf    r7.0<0;1,0>:f                    {F@7}
        add (1|M0)               r73.0<1>:hf   r73.0<0;1,0>:hf   r75.0<0;1,0>:hf  {F@7}
        add (1|M0)               r77.0<1>:hf   r77.0<0;1,0>:hf   r79.0<0;1,0>:hf  {F@6}
        add (1|M0)               r1.4<1>:hf    r1.4<0;1,0>:hf    r4.0<0;1,0>:hf   {F@5}
        add (1|M0)               r6.4<1>:hf    r6.4<0;1,0>:hf    r8.0<0;1,0>:hf   {F@4}
        add (1|M0)               r73.0<1>:hf   r73.0<0;1,0>:hf   r77.0<0;1,0>:hf  {F@3}
        add (1|M0)               r1.4<1>:hf    r1.4<0;1,0>:hf    r6.4<0;1,0>:hf   {F@2}
        mov (1|M0)               r80.0<1>:f    r73.0<0;1,0>:hf                  {F@2}
        mov (1|M0)               r9.0<1>:f     r1.4<0;1,0>:hf                   {F@2}
        sel (1|M0)    (ge)f0.0   r80.0<1>:f    r80.0<0;1,0>:f    6.198883e-05:f               {F@2}
        sel (1|M0)    (ge)f0.0   r9.0<1>:f     r9.0<0;1,0>:f     6.198883e-05:f               {F@2}
        math.sqt (1|M0)          r80.0<1>:f    r80.0<0;1,0>:f                   {@2,$8}
        mov (1|M0)               r17.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        sync.nop                             null                             {Compacted,F@1}
        math.sqt (1|M0)          r9.0<1>:f     r9.0<0;1,0>:f                    {$9}
        shl (1|M0)               r85.4<1>:d    r6.0<0;1,0>:d     5:w               {Compacted}
        math.inv (1|M0)          r80.0<1>:f    r80.0<0;1,0>:f                   {$8}
        mov (1|M0)               r88.0<2>:d    0:d                              
        math.inv (1|M0)          r9.0<1>:f     r9.0<0;1,0>:f                    {$9}
        mov (1|M0)               r81.0<2>:hf   r80.0<0;1,0>:f                   {$8.dst}
        mov (1|M0)               r10.0<2>:hf   r9.0<0;1,0>:f                    {$9.dst}
        mov (1|M0)               r88.1<2>:d    0:d                              
        mov (1|M0)               r85.6<1>:d    r16.0<0;1,0>:d                   {I@7}
        or (1|M0)                r85.5<1>:d    r12.0<0;1,0>:d    0:w               {Compacted,I@7}
        add3 (1|M0)              r85.7<1>:d    r17.0<0;0>:d      r15.1<0;0>:d      r15.3<0>:d       {I@6}
        mov (1|M0)               r85.6<2>:hf   r11.0<0;1,0>:f                   {$5.dst}
        mov (1|M0)               r85.1<1>:f    r81.0<0;1,0>:hf                  {F@3}
        mov (1|M0)               r85.2<1>:f    r10.0<0;1,0>:hf                  {F@3}
L3848:
        shl (1|M0)               r3.6<1>:d     r88.0<0;1,0>:d    1:w               {Compacted,I@5}
        shl (1|M0)               r1.2<1>:d     r88.1<0;1,0>:d    1:w               {I@5}
        shl (1|M0)               r85.7<1>:w    r3.12<0;1,0>:w    2:w               {I@2}
        shr (1|M0)               r2.0<1>:ud    r88.0<0;1,0>:ud   0x1F:uw             
        add (1|M0)               a0.0<1>:uw    r85.7<0;1,0>:uw   0xAC0:uw              {A@1}
        shl (1|M0)               r88.2<1>:d    r88.0<0;1,0>:d    3:w               {Compacted}
        or (1|M0)                r3.7<1>:d     r1.2<0;1,0>:d     r2.0<0;1,0>:d    {I@3}
        mul (1|M0)               r4.0<1>:f     r[a0.0]<0;1,0>:f  r85.1<0;1,0>:f   {F@2}
        mov (1|M0)               r5.0<2>:hf    r4.0<0;1,0>:f                    {A@1}
        mul (1|M0)    (lt)f0.1   r5.0<1>:hf    r85.6<0;1,0>:hf   r5.0<0;1,0>:hf   {F@1}
        mov (1|M0)               r88.4<1>:f    r5.0<0;1,0>:hf                   {F@1}
(f0.1)  mov (1|M0)               r88.4<1>:f    -r88.4<0;1,0>:f                  {F@1}
        sel (1|M0)    (lt)f0.0   r88.4<1>:f    r88.4<0;1,0>:f    448.0:f               {F@1}
        shr (1|M0)               r88.5<1>:ud   r88.4<0;1,0>:ud   0x17:uw              {F@1}
        and (1|M0)               r88.5<1>:ud   r88.5<0;1,0>:ud   0xFF:uw              {I@1}
        sel (1|M0)    (ge)f0.0   r88.5<1>:ud   r88.5<0;1,0>:ud   0x79:uw              {I@1}
        shl (1|M0)               r88.5<1>:ud   r88.5<0;1,0>:ud   0x17:uw              {I@1}
        sync.nop                             null                             {Compacted,$10.src}
        add (1|M0)               r6.0<1>:ud    -r88.5<0;1,0>:ud  0x80800000:ud              {I@1}
        mul (1|M0)               r7.0<1>:f     r88.4<0;1,0>:f    r6.0<0;1,0>:f    {Compacted,I@1}
        mov (1|M0)               r88.3<1>:d    r7.0<0;1,0>:f                    {Compacted,F@1}
        mov (1|M0)               r88.6<1>:f    r88.3<0;1,0>:d                   {I@1}
        mad (1|M0)               r88.4<1>:f    -r88.6<0;0>:f     r6.0<0;0>:f       r88.4<0>:f       {F@1}
        cmp (1|M0)    (gt)f0.0   null<1>:f     r88.4<0;1,0>:f    0.5:f               {F@1}
(W)     and (1|M0)               f1.0<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
(f1.0.any8h) goto (8|M0)                     L4312                  L4312                
L4224:
        cmp (1|M0)    (lt)f1.1   null<1>:f     r88.4<0;1,0>:f    0.5:f              
        and (1|M0)               r88.3<1>:d    r88.3<0;1,0>:d    1:w               {Compacted}
        add (1|M0)               r1.2<1>:f     r88.6<0;1,0>:f    1.0:f              
(~f1.1) cmp (1|M0)    (eq)f1.1   null<1>:d     r88.3<0;1,0>:d    0:w               {A@1}
(~f1.1) mov (1|M0)               r88.6<1>:f    r1.2<0;1,0>:f                    {F@1}
        goto (8|M0)                          L4312                  L4344                
L4312:
        join (8|M0)                          L4344                                
L4328:
        add (1|M0)               r88.6<1>:f    r88.6<0;1,0>:f    1.0:f               {F@1}
L4344:
        join (8|M0)                          L7744                                
L4360:
        mul (1|M0)               r9.0<1>:f     r[a0.0,4]<0;1,0>:f  r85.1<0;1,0>:f
        or (1|M0)                r89.0<1>:d    r88.2<0;1,0>:d    r85.0<0;1,0>:d   {Compacted,A@1}
        mov (1|M0)               r10.0<2>:hf   r9.0<0;1,0>:f                    {F@1}
        mov (1|M0)               r89.1<1>:d    0:w                              
        mul (1|M0)    (lt)f0.0   r10.0<1>:hf   r85.6<0;1,0>:hf   r10.0<0;1,0>:hf  {F@1}
        add (1|M0)               r88.5<1>:ud   r88.5<0;1,0>:ud   0xFE800000:ud             
        or (2|M0)                r90.0<1>:d    r85.4<1;1,0>:d    r89.0<1;1,0>:d   {I@2}
        mul (1|M0)               r88.6<1>:f    r88.6<0;1,0>:f    r88.5<0;1,0>:f   {I@2}
        mov (1|M0)               r89.4<1>:f    r10.0<0;1,0>:hf                  {F@2}
        shl (1|M0)               r89.2<1>:d    r90.0<0;1,0>:d    1:w               {Compacted,I@1}
(f0.0)  mov (1|M0)               r89.4<1>:f    -r89.4<0;1,0>:f                  {F@1}
        shl (1|M0)               r2.0<1>:d     r90.1<0;1,0>:d    1:w               {Compacted}
        sel (1|M0)    (lt)f0.0   r89.4<1>:f    r89.4<0;1,0>:f    448.0:f               {F@1}
        shr (1|M0)               r3.6<1>:ud    r90.0<0;1,0>:ud   0x1F:uw             
        shr (1|M0)               r89.5<1>:ud   r89.4<0;1,0>:ud   0x17:uw              {F@1}
(f0.1)  mov (1|M0)               r88.6<1>:f    -r88.6<0;1,0>:f                 
        and (1|M0)               r89.5<1>:ud   r89.5<0;1,0>:ud   0xFF:uw              {I@1}
        addc (1|M0)              r4.0<1>:ud    r3.0<0;1,0>:ud    r89.2<0;1,0>:ud  {AccWrEn}
        sel (1|M0)    (ge)f0.0   r89.5<1>:ud   r89.5<0;1,0>:ud   0x79:uw              {I@2}
        or (1|M0)                r89.3<1>:d    r2.0<0;1,0>:d     r3.6<0;1,0>:d   
        shl (1|M0)               r89.5<1>:ud   r89.5<0;1,0>:ud   0x17:uw              {I@2}
        mov (1|M0)               r1.4<2>:hf    r88.6<0;1,0>:f                   {F@1}
        add (1|M0)               r11.0<1>:ud   -r89.5<0;1,0>:ud  0x80800000:ud              {I@1}
        mov (1|M0)               r5.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mul (1|M0)               r12.0<1>:f    r89.4<0;1,0>:f    r11.0<0;1,0>:f   {Compacted,I@2}
        mov (1|M0)               r6.0<1>:f     r4.0<0;1,0>:f                    {Compacted}
        mov (1|M0)               r88.7<1>:d    r12.0<0;1,0>:f                   {Compacted,F@2}
        mov (1|M0)               r8.0<1>:d     r1.4<0;1,0>:uw                  
        mov (1|M0)               r89.6<1>:f    r88.7<0;1,0>:d                   {I@2}
        add3 (1|M0)              r6.1<1>:d     r5.0<0;0>:d       r3.1<0;0>:d       r89.3<0>:d      
        mad (1|M0)               r89.4<1>:f    -r89.6<0;0>:f     r11.0<0;0>:f      r89.4<0>:f       {F@1}
        sync.nop                             null                             {Compacted,I@1}
        send.ugm (1|M0)          null     r6      r8:1    0x0            0x04000B84           {$11} // wr:2+1, rd:0; store.ugm.d16u32.a64
        cmp (1|M0)    (gt)f1.1   null<1>:f     r89.4<0;1,0>:f    0.5:f               {F@1}
(W)     and (1|M0)               f0.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(f0.1.any8h) goto (8|M0)                     L4968                  L4968                
L4872:
        cmp (1|M0)    (lt)f1.0   null<1>:f     r89.4<0;1,0>:f    0.5:f              
        and (1|M0)               r88.7<1>:d    r88.7<0;1,0>:d    1:w              
        add (1|M0)               r1.2<1>:f     r89.6<0;1,0>:f    1.0:f              
(~f1.0) cmp (1|M0)    (eq)f1.0   null<1>:d     r88.7<0;1,0>:d    0:w               {A@1}
(~f1.0) mov (1|M0)               r89.6<1>:f    r1.2<0;1,0>:f                    {F@1}
        goto (8|M0)                          L4968                  L5000                
L4968:
        join (8|M0)                          L5000                                
L4984:
        add (1|M0)               r89.6<1>:f    r89.6<0;1,0>:f    1.0:f               {F@1}
L5000:
        join (8|M0)                          L7744                                
L5016:
        add (1|M0)               a0.0<1>:uw    r85.7<0;1,0>:uw   0xAE0:uw              {A@1}
        mov (2|M0)               r2.0<1>:w     0x1010101:v                              
        add (1|M0)               r89.5<1>:ud   r89.5<0;1,0>:ud   0xFE800000:ud             
        or (2|M0)                r90.0<1>:d    r90.0<1;1,0>:d    r2.0<1;1,0>:w    {I@2}
        mul (1|M0)               r11.0<1>:f    r[a0.0]<0;1,0>:f  r85.2<0;1,0>:f  
        mul (1|M0)               r89.6<1>:f    r89.6<0;1,0>:f    r89.5<0;1,0>:f   {A@1}
        mov (1|M0)               r12.0<2>:hf   r11.0<0;1,0>:f                   {F@2}
        cmp (1|M0)    (lt)f1.1   null<1>:f     r11.0<0;1,0>:f    0xB3000000:f              
        mov (1|M0)               r90.4<1>:f    r12.0<0;1,0>:hf                  {F@2}
        shl (1|M0)               r90.2<1>:d    r90.0<0;1,0>:d    1:w               {Compacted,I@1}
        shl (1|M0)               r3.6<1>:d     r90.1<0;1,0>:d    1:w              
(f1.1)  mov (1|M0)               r90.4<1>:f    -r90.4<0;1,0>:f                  {F@1}
        shr (1|M0)               r4.0<1>:ud    r90.0<0;1,0>:ud   0x1F:uw             
        sel (1|M0)    (lt)f0.0   r90.4<1>:f    r90.4<0;1,0>:f    448.0:f               {F@1}
(f0.0)  mov (1|M0)               r89.6<1>:f    -r89.6<0;1,0>:f                 
        shr (1|M0)               r90.5<1>:ud   r90.4<0;1,0>:ud   0x17:uw              {F@2}
        addc (1|M0)              r5.0<1>:ud    r3.0<0;1,0>:ud    r90.2<0;1,0>:ud  {AccWrEn,I@4}
        and (1|M0)               r90.5<1>:ud   r90.5<0;1,0>:ud   0xFF:uw              {I@2}
        or (1|M0)                r90.3<1>:d    r3.6<0;1,0>:d     r4.0<0;1,0>:d   
        sel (1|M0)    (ge)f0.0   r90.5<1>:ud   r90.5<0;1,0>:ud   0x79:uw              {I@2}
        mov (1|M0)               r1.4<2>:hf    r89.6<0;1,0>:f                   {F@1}
        shl (1|M0)               r90.5<1>:ud   r90.5<0;1,0>:ud   0x17:uw              {I@1}
        mov (1|M0)               r6.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$11.src}
        add (1|M0)               r13.0<1>:ud   -r90.5<0;1,0>:ud  0x80800000:ud              {I@2}
        mov (1|M0)               r8.0<1>:f     r5.0<0;1,0>:f                    {Compacted}
        mul (1|M0)               r14.0<1>:f    r90.4<0;1,0>:f    r13.0<0;1,0>:f   {Compacted,I@1}
        mov (1|M0)               r10.0<1>:d    r1.4<0;1,0>:uw                   {F@3}
        mov (1|M0)               r89.7<1>:d    r14.0<0;1,0>:f                   {Compacted,F@1}
        add3 (1|M0)              r8.1<1>:d     r6.0<0;0>:d       r3.1<0;0>:d       r90.3<0>:d      
        mov (1|M0)               r90.6<1>:f    r89.7<0;1,0>:d                   {I@2}
        sync.nop                             null                             {Compacted,I@1}
        send.ugm (1|M0)          null     r8      r10:1   0x0            0x04000B84           {$12} // wr:2+1, rd:0; store.ugm.d16u32.a64
        mad (1|M0)               r90.4<1>:f    -r90.6<0;0>:f     r13.0<0;0>:f      r90.4<0>:f       {F@1}
        cmp (1|M0)    (gt)f1.0   null<1>:f     r90.4<0;1,0>:f    0.5:f               {F@1}
(W)     and (1|M0)               f0.0<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
(f0.0.any8h) goto (8|M0)                     L5640                  L5640                
L5544:
        cmp (1|M0)    (lt)f0.1   null<1>:f     r90.4<0;1,0>:f    0.5:f              
        and (1|M0)               r89.7<1>:d    r89.7<0;1,0>:d    1:w              
        add (1|M0)               r1.2<1>:f     r90.6<0;1,0>:f    1.0:f              
(~f0.1) cmp (1|M0)    (eq)f0.1   null<1>:d     r89.7<0;1,0>:d    0:w               {A@1}
(~f0.1) mov (1|M0)               r90.6<1>:f    r1.2<0;1,0>:f                    {F@1}
        goto (8|M0)                          L5640                  L5672                
L5640:
        join (8|M0)                          L5672                                
L5656:
        add (1|M0)               r90.6<1>:f    r90.6<0;1,0>:f    1.0:f               {F@1}
L5672:
        join (8|M0)                          L7744                                
L5688:
        mul (1|M0)               r9.0<1>:f     r[a0.0,4]<0;1,0>:f  r85.2<0;1,0>:f {$12.src}
        add (1|M0)               r90.5<1>:ud   r90.5<0;1,0>:ud   0xFE800000:ud              {A@1}
        mov (1|M0)               r10.0<2>:hf   r9.0<0;1,0>:f                    {F@1}
        cmp (1|M0)    (lt)f1.0   null<1>:f     r9.0<0;1,0>:f     0xB3000000:f              
        mov (1|M0)               r91.0<1>:f    r10.0<0;1,0>:hf                  {F@2}
        mul (1|M0)               r90.6<1>:f    r90.6<0;1,0>:f    r90.5<0;1,0>:f   {I@1}
        addc (1|M0)              r2.0<1>:ud    r3.2<0;1,0>:ud    r89.2<0;1,0>:ud  {AccWrEn}
(f1.0)  mov (1|M0)               r91.0<1>:f    -r91.0<0;1,0>:f                  {F@2}
(f1.1)  mov (1|M0)               r90.6<1>:f    -r90.6<0;1,0>:f                  {F@2}
        sel (1|M0)    (lt)f0.0   r91.0<1>:f    r91.0<0;1,0>:f    448.0:f               {F@2}
        mov (1|M0)               r4.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        shr (1|M0)               r91.1<1>:ud   r91.0<0;1,0>:ud   0x17:uw              {F@1}
        mov (1|M0)               r1.4<2>:hf    r90.6<0;1,0>:f                  
        and (1|M0)               r91.1<1>:ud   r91.1<0;1,0>:ud   0xFF:uw              {I@1}
        mov (1|M0)               r6.0<1>:d     r2.0<0;1,0>:d                   
        sel (1|M0)    (ge)f0.0   r91.1<1>:ud   r91.1<0;1,0>:ud   0x79:uw              {I@2}
        add3 (1|M0)              r6.1<1>:d     r4.0<0;0>:d       r3.3<0;0>:d       r89.3<0>:d      
        shl (1|M0)               r91.1<1>:ud   r91.1<0;1,0>:ud   0x17:uw              {I@2}
        mov (1|M0)               r8.0<1>:d     r1.4<0;1,0>:uw                   {F@1}
        add (1|M0)               r11.0<1>:ud   -r91.1<0;1,0>:ud  0x80800000:ud              {I@2}
        send.ugm (1|M0)          null     r6      r8:1    0x0            0x04000B84           {A@2,$13} // wr:2+1, rd:0; store.ugm.d16u32.a64
        mul (1|M0)               r12.0<1>:f    r91.0<0;1,0>:f    r11.0<0;1,0>:f   {Compacted,I@1}
        mov (1|M0)               r90.7<1>:d    r12.0<0;1,0>:f                   {Compacted,F@1}
        mov (1|M0)               r91.2<1>:f    r90.7<0;1,0>:d                   {I@1}
        mad (1|M0)               r91.0<1>:f    -r91.2<0;0>:f     r11.0<0;0>:f      r91.0<0>:f       {F@1}
        cmp (1|M0)    (gt)f0.1   null<1>:f     r91.0<0;1,0>:f    0.5:f               {F@1}
(W)     and (1|M0)               f1.1<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(f1.1.any8h) goto (8|M0)                     L6208                  L6208                
L6112:
        cmp (1|M0)    (lt)f0.0   null<1>:f     r91.0<0;1,0>:f    0.5:f              
        and (1|M0)               r90.7<1>:d    r90.7<0;1,0>:d    1:w              
        add (1|M0)               r1.2<1>:f     r91.2<0;1,0>:f    1.0:f              
(~f0.0) cmp (1|M0)    (eq)f0.0   null<1>:d     r90.7<0;1,0>:d    0:w               {A@1}
(~f0.0) mov (1|M0)               r91.2<1>:f    r1.2<0;1,0>:f                    {F@1}
        goto (8|M0)                          L6208                  L6240                
L6208:
        join (8|M0)                          L6240                                
L6224:
        add (1|M0)               r91.2<1>:f    r91.2<0;1,0>:f    1.0:f               {F@1}
L6240:
        join (8|M0)                          L7744                                
L6256:
        add (1|M0)               r91.1<1>:ud   r91.1<0;1,0>:ud   0xFE800000:ud             
        addc (1|M0)              r2.0<1>:ud    r3.2<0;1,0>:ud    r90.2<0;1,0>:ud  {AccWrEn}
        mul (1|M0)               r91.2<1>:f    r91.2<0;1,0>:f    r91.1<0;1,0>:f   {A@1}
        mov (1|M0)               r4.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
(f1.0)  mov (1|M0)               r91.2<1>:f    -r91.2<0;1,0>:f                  {F@1}
        sync.nop                             null                             {Compacted,$13.src}
        mov (1|M0)               r6.0<1>:f     r2.0<0;1,0>:f                    {Compacted,I@2}
        mov (1|M0)               r1.4<2>:hf    r91.2<0;1,0>:f                   {F@2}
        add3 (1|M0)              r6.1<1>:d     r4.0<0;0>:d       r3.3<0;0>:d       r90.3<0>:d       {I@1}
        mov (1|M0)               r8.0<1>:d     r1.4<0;1,0>:uw                   {F@1}
        shl (1|M0)               r11.0<1>:d    r89.0<0;1,0>:d    2:w               {Compacted}
        send.ugm (1|M0)          null     r6      r8:1    0x0            0x04000B84           {A@2,$14} // wr:2+1, rd:0; store.ugm.d16u32.a64
        shl (1|M0)               r9.0<1>:d     r89.1<0;1,0>:d    2:w               {Compacted}
        shr (1|M0)               r10.0<1>:ud   r89.0<0;1,0>:ud   0x1E:uw             
        addc (1|M0)              r12.0<1>:ud   r85.6<0;1,0>:ud   r11.0<0;1,0>:ud  {AccWrEn,I@3}
        or (1|M0)                r11.1<1>:d    r9.0<0;1,0>:d     r10.0<0;1,0>:d   {Compacted,I@2}
        mov (1|M0)               r13.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r94.0<1>:f    r12.0<0;1,0>:f                   {Compacted,I@3}
        add3 (1|M0)              r94.1<1>:d    r13.0<0;0>:d      r85.7<0;0>:d      r11.1<0>:d       {I@1}
        send.ugm (1|M0)          r92      r94     null:0  0x0            0x04100580           {A@1,$15} // wr:2+0, rd:1; load.ugm.d32.a64
        cmp (1|M0)    (lt)f0.1   null<1>:f     r92.0<0;1,0>:f    0.0:f               {$15.dst}
(f0.1)  mov (1|M0)               r92.0<1>:f    -r92.0<0;1,0>:f                 
        sel (1|M0)    (lt)f0.0   r92.0<1>:f    r92.0<0;1,0>:f    448.0:f               {F@1}
        shr (1|M0)               r91.4<1>:ud   r92.0<0;1,0>:ud   0x17:uw              {F@1}
        and (1|M0)               r91.4<1>:ud   r91.4<0;1,0>:ud   0xFF:uw              {I@1}
        sel (1|M0)    (ge)f0.0   r91.4<1>:ud   r91.4<0;1,0>:ud   0x79:uw              {I@1}
        shl (1|M0)               r91.4<1>:ud   r91.4<0;1,0>:ud   0x17:uw              {I@1}
        add (1|M0)               r14.0<1>:ud   -r91.4<0;1,0>:ud  0x80800000:ud              {I@1}
        mul (1|M0)               r15.0<1>:f    r92.0<0;1,0>:f    r14.0<0;1,0>:f   {Compacted,I@1}
        mov (1|M0)               r91.3<1>:d    r15.0<0;1,0>:f                   {Compacted,F@1}
        mov (1|M0)               r91.5<1>:f    r91.3<0;1,0>:d                   {I@1}
        mad (1|M0)               r92.0<1>:f    -r91.5<0;0>:f     r14.0<0;0>:f      r92.0<0>:f       {F@1}
        cmp (1|M0)    (gt)f0.0   null<1>:f     r92.0<0;1,0>:f    0.5:f               {F@1}
(W)     and (1|M0)               f1.0<1>:uw    f0.0<0;1,0>:uw    0x1:uw             
(f1.0.any8h) goto (8|M0)                     L6824                  L6824                
L6736:
        cmp (1|M0)    (lt)f1.1   null<1>:f     r92.0<0;1,0>:f    0.5:f              
        and (1|M0)               r91.3<1>:d    r91.3<0;1,0>:d    1:w               {Compacted}
        add (1|M0)               r1.2<1>:f     r91.5<0;1,0>:f    1.0:f              
(~f1.1) cmp (1|M0)    (eq)f1.1   null<1>:d     r91.3<0;1,0>:d    0:w               {A@1}
(~f1.1) mov (1|M0)               r91.5<1>:f    r1.2<0;1,0>:f                    {F@1}
        goto (8|M0)                          L6824                  L6856                
L6824:
        join (8|M0)                          L6856                                
L6840:
        add (1|M0)               r91.5<1>:f    r91.5<0;1,0>:f    1.0:f               {F@1}
L6856:
        join (8|M0)                          L7744                                
L6872:
        add (1|M0)               r91.4<1>:ud   r91.4<0;1,0>:ud   0xFE800000:ud             
        addc (1|M0)              r2.0<1>:ud    r3.4<0;1,0>:ud    r89.2<0;1,0>:ud  {AccWrEn}
        mul (1|M0)               r91.5<1>:f    r91.5<0;1,0>:f    r91.4<0;1,0>:f   {A@1}
        mov (1|M0)               r4.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
(f0.1)  mov (1|M0)               r91.5<1>:f    -r91.5<0;1,0>:f                  {F@1}
        sync.nop                             null                             {Compacted,$14.src}
        mov (1|M0)               r6.0<1>:f     r2.0<0;1,0>:f                    {Compacted,I@2}
        mov (1|M0)               r1.4<2>:hf    r91.5<0;1,0>:f                   {F@2}
        add3 (1|M0)              r6.1<1>:d     r4.0<0;0>:d       r3.5<0;0>:d       r89.3<0>:d       {I@1}
        mov (1|M0)               r8.0<1>:d     r1.4<0;1,0>:uw                   {F@1}
        addc (1|M0)              r9.0<1>:ud    r94.0<0;1,0>:ud   0x4:ud              {AccWrEn}
        send.ugm (1|M0)          null     r6      r8:1    0x0            0x04000B84           {A@2,$0} // wr:2+1, rd:0; store.ugm.d16u32.a64
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r12.0<1>:f    r9.0<0;1,0>:f                    {Compacted,I@2}
        add3 (1|M0)              r12.1<1>:d    r10.0<0;0>:d      r94.1<0;0>:d      0:w               {I@1}
        send.ugm (1|M0)          r93      r12     null:0  0x0            0x04100580           {A@1,$3} // wr:2+0, rd:1; load.ugm.d32.a64
        cmp (1|M0)    (lt)f0.0   null<1>:f     r93.0<0;1,0>:f    0.0:f               {$3.dst}
(f0.0)  mov (1|M0)               r93.0<1>:f    -r93.0<0;1,0>:f                 
        sel (1|M0)    (lt)f0.0   r93.0<1>:f    r93.0<0;1,0>:f    448.0:f               {F@1}
        shr (1|M0)               r91.7<1>:ud   r93.0<0;1,0>:ud   0x17:uw              {F@1}
        and (1|M0)               r91.7<1>:ud   r91.7<0;1,0>:ud   0xFF:uw              {I@1}
        sel (1|M0)    (ge)f0.0   r91.7<1>:ud   r91.7<0;1,0>:ud   0x79:uw              {I@1}
        shl (1|M0)               r91.7<1>:ud   r91.7<0;1,0>:ud   0x17:uw              {I@1}
        add (1|M0)               r13.0<1>:ud   -r91.7<0;1,0>:ud  0x80800000:ud              {I@1}
        mul (1|M0)               r14.0<1>:f    r93.0<0;1,0>:f    r13.0<0;1,0>:f   {Compacted,I@1}
        mov (1|M0)               r91.6<1>:d    r14.0<0;1,0>:f                   {Compacted,F@1}
        mov (1|M0)               r92.1<1>:f    r91.6<0;1,0>:d                   {I@1}
        mad (1|M0)               r93.0<1>:f    -r92.1<0;0>:f     r13.0<0;0>:f      r93.0<0>:f       {F@1}
        cmp (1|M0)    (gt)f1.1   null<1>:f     r93.0<0;1,0>:f    0.5:f               {F@1}
(W)     and (1|M0)               f0.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
(f0.1.any8h) goto (8|M0)                     L7408                  L7408                
L7312:
        cmp (1|M0)    (lt)f1.0   null<1>:f     r93.0<0;1,0>:f    0.5:f              
        and (1|M0)               r91.6<1>:d    r91.6<0;1,0>:d    1:w              
        add (1|M0)               r1.2<1>:f     r92.1<0;1,0>:f    1.0:f              
(~f1.0) cmp (1|M0)    (eq)f1.0   null<1>:d     r91.6<0;1,0>:d    0:w               {A@1}
(~f1.0) mov (1|M0)               r92.1<1>:f    r1.2<0;1,0>:f                    {F@1}
        goto (8|M0)                          L7408                  L7432                
L7408:
        join (8|M0)                          L7432                                
L7424:
        add (1|M0)               r92.1<1>:f    r92.1<0;1,0>:f    1.0:f               {Compacted,F@1}
L7432:
        join (8|M0)                          L7744                                
L7448:
        addc (1|M0)              r2.0<1>:ud    r3.4<0;1,0>:ud    r90.2<0;1,0>:ud  {AccWrEn}
        add (1|M0)               r91.7<1>:ud   r91.7<0;1,0>:ud   0xFE800000:ud             
        mov (1|M0)               r4.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r9.0<1>:ud    r88.0<0;1,0>:ud   0x1:ud              {AccWrEn}
        mul (1|M0)               r92.1<1>:f    r92.1<0;1,0>:f    r91.7<0;1,0>:f   {A@1}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r92.2<1>:d    r9.0<0;1,0>:d                    {I@2}
        add3 (1|M0)              r92.3<1>:d    r10.0<0;0>:d      r88.1<0;0>:d      0:w               {I@2}
(f0.0)  mov (1|M0)               r92.1<1>:f    -r92.1<0;1,0>:f                  {F@1}
        cmp (1|M0)    (eq)f0.1   null<1>:d     r92.3<0;1,0>:d    0:w               {I@1}
        mov (1|M0)               r1.4<2>:hf    r92.1<0;1,0>:f                   {F@1}
        mov (1|M0)               r6.0<1>:f     r2.0<0;1,0>:f                    {Compacted,$0.src}
        add3 (1|M0)              r6.1<1>:d     r4.0<0;0>:d       r3.5<0;0>:d       r90.3<0>:d      
(f0.1)  cmp (1|M0)    (eq)f0.1   null<1>:d     r92.2<0;1,0>:d    4:w              
        mov (1|M0)               r8.0<1>:d     r1.4<0;1,0>:uw                   {F@2}
        send.ugm (1|M0)          null     r6      r8:1    0x0            0x04000B84           {A@1,$10} // wr:2+1, rd:0; store.ugm.d16u32.a64
(W)     and (1|M0)               f0.0<1>:uw    f0.1<0;1,0>:uw    0x1:uw             
(f0.0.any8h) goto (8|M0)                     L7744                  L7744                
L7712:
(W)     mov (2|M0)               r88.0<1>:ud   r92.2<1;1,0>:ud                 
        goto.b (8|M0)                        L7744                  L3848                
L7744:
        join (8|M0)                          L7760                                
L7760:
(W)     mov (8|M0)               r127.0<1>:f   r0.0<1;1,0>:f                    {Compacted}
(W)     send.ugm (1|M0)          r4       r0      null:0  0x0            0x0210641F           {$5} // wr:1+0, rd:1; fence invalid flush type scoped to tile
(W)     mov (8|M0)               null<1>:ud    r4.0<1;1,0>:ud                   {$5.dst}
(W)     send.gtwy (1|M0)         null     r127    null:0  0x0            0x02000010           {EOT,A@1} // wr:1+0, rd:0; end of thread
L7816:
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
