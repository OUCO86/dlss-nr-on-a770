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
        mov (1|M0)               r73.1<1>:f    r0.1<0;1,0>:f                    {Compacted,A@1}
        mov (1|M0)               r73.0<1>:d    r1.0<0;1,0>:uw                   {$0.dst}
        shl (1|M0)               r73.1<1>:d    r73.1<0;1,0>:d    3:w               {Compacted,F@1}
        shr (1|M0)               r1.2<1>:ud    r73.0<0;1,0>:ud   0x2:uw              {I@2}
        mov (1|M0)               r75.6<1>:d    r2.2<0;1,0>:d                    {$1.dst}
        add (1|M0)               r73.1<1>:d    r73.1<0;1,0>:d    r1.2<0;1,0>:d    {I@2}
        mov (1|M0)               r78.5<1>:d    r73.1<0;1,0>:d                   {I@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
(W)     call (8|M0)              r78.2         L5192                                 {A@1}
L352:
(W)     mul (1|M0)               acc0.0<1>:d   r75.7<0;1,0>:d    r2.4<0;1,0>:uw  
        mach (1|M0)              r2.0<1>:d     r75.7<0;1,0>:d    r2.2<0;1,0>:d   
        mul (1|M0)               acc0.0<1>:ud  r75.7<0;1,0>:ud   r2.12<0;1,0>:uw 
        mach (1|M0)              r5.0<1>:ud    r75.7<0;1,0>:ud   r2.6<0;1,0>:ud   {AccWrEn}
        shl (1|M0)               r12.0<1>:d    r75.7<0;1,0>:d    2:w               {Compacted}
        mov (1|M0)               r4.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        shr (1|M0)               r11.0<1>:ud   r75.7<0;1,0>:ud   0x1E:uw             
        shl (1|M0)               r8.0<1>:d     r4.0<0;1,0>:d     2:w               {Compacted,I@2}
        add (1|M0)               r73.1<1>:d    r73.1<0;1,0>:d    -r2.0<0;1,0>:d   {Compacted}
        addc (1|M0)              r9.0<1>:ud    r2.4<0;1,0>:ud    r8.0<0;1,0>:ud   {AccWrEn,I@2}
        shl (1|M0)               r6.0<1>:d     r5.0<0;1,0>:d     2:w               {Compacted}
        mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r13.0<1>:ud   r3.0<0;1,0>:ud    r12.0<0;1,0>:ud  {AccWrEn}
        shr (1|M0)               r7.0<1>:ud    r4.0<0;1,0>:ud    0x1E:uw             
        or (1|M0)                r12.1<1>:d    r11.0<0;1,0>:d    0:w               {Compacted}
        mov (1|M0)               r14.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        shl (1|M0)               r73.2<1>:ud   r73.0<0;1,0>:ud   0x1:uw             
        shl (1|M0)               r73.3<1>:d    r73.1<0;1,0>:d    5:w               {I@7}
        mov (1|M0)               r74.0<1>:f    r13.0<0;1,0>:f                   {Compacted,I@6}
        or (1|M0)                r8.1<1>:d     r6.0<0;1,0>:d     r7.0<0;1,0>:d    {Compacted,I@5}
        add3 (1|M0)              r74.1<1>:d    r14.0<0;0>:d      r3.1<0;0>:d       r12.1<0>:d       {I@4}
        mov (1|M0)               r74.2<2>:f    0.0:f                              
        send.ugm (1|M0)          r75      r74     null:0  0x0            0x04100580           {A@1,$2} // wr:2+0, rd:1; load.ugm.d32.a64
        mov (1|M0)               r74.3<2>:f    0.0:f                               {$2.src}
        mov (1|M0)               r73.5<1>:d    r9.0<0;1,0>:d                   
        and (1|M0)               r73.2<1>:ud   r73.2<0;1,0>:ud   0x6:uw             
        add (1|M0)               r73.4<1>:d    r73.3<0;1,0>:d    r2.3<0;1,0>:d   
        add3 (1|M0)              r73.6<1>:d    r10.0<0;0>:d      r2.5<0;0>:d       r8.1<0>:d       
L720:
        shl (1|M0)               r1.2<1>:d     r74.2<0;1,0>:d    3:w              
        shl (1|M0)               r19.0<1>:d    r74.2<0;1,0>:d    1:w               {Compacted}
        or (1|M0)                r1.2<1>:d     r1.2<0;1,0>:d     r73.2<0;1,0>:d   {I@2}
        shl (1|M0)               r17.0<1>:d    r74.3<0;1,0>:d    1:w               {Compacted,F@1}
        or (1|M0)                r3.6<1>:d     r1.2<0;1,0>:d     r73.3<0;1,0>:d   {I@2}
        bfn.0xFE (1|M0)          r27.0<1>:ud   0x1:uw               r1.2<0;0>:ud      r73.3<0>:ud      // s0|s1|s2
        shl (1|M0)               r5.0<1>:d     r3.6<0;1,0>:d     2:w               {Compacted,I@2}
        add (1|M0)               r35.0<1>:d    r1.2<0;1,0>:d     r73.4<0;1,0>:d  
        addc (1|M0)              r6.0<1>:ud    r73.5<0;1,0>:ud   r5.0<0;1,0>:ud   {AccWrEn,I@2}
        shl (1|M0)               r29.0<1>:d    r27.0<0;1,0>:d    2:w               {Compacted}
        mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r8.0<1>:f     r6.0<0;1,0>:f                    {Compacted,I@3}
        addc (1|M0)              r11.0<1>:ud   r3.2<0;1,0>:ud    r5.0<0;1,0>:ud   {AccWrEn}
        shl (1|M0)               r37.0<1>:d    r35.0<0;1,0>:d    2:w               {Compacted}
        mov (1|M0)               r12.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r21.0<1>:ud   r8.0<0;1,0>:ud    0x4:ud              {AccWrEn,F@1}
        add (1|M0)               r2.0<1>:d     r1.2<0;1,0>:d     r73.4<0;1,0>:d  
        mov (1|M0)               r22.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r30.0<1>:ud   r3.2<0;1,0>:ud    r29.0<0;1,0>:ud  {AccWrEn,I@7}
        shr (1|M0)               r4.0<1>:ud    r3.6<0;1,0>:ud    0x1E:uw             
        mov (1|M0)               r31.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r38.0<1>:ud   r73.5<0;1,0>:ud   r37.0<0;1,0>:ud  {AccWrEn,I@7}
        shr (1|M0)               r36.0<1>:ud   r35.0<0;1,0>:ud   0x1E:uw             
        mov (1|M0)               r39.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r40.0<1>:f    r38.0<0;1,0>:f                   {Compacted,I@3}
        addc (1|M0)              r43.0<1>:ud   r3.2<0;1,0>:ud    r37.0<0;1,0>:ud  {AccWrEn}
        add (1|M0)               r55.0<1>:d    r2.0<0;1,0>:d     1:w               {Compacted}
        or (1|M0)                r5.1<1>:d     r4.0<0;1,0>:d     0:w               {Compacted}
        or (1|M0)                r37.1<1>:d    r36.0<0;1,0>:d    0:w               {Compacted,I@5}
        mov (1|M0)               r44.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r49.0<1>:ud   r40.0<0;1,0>:ud   0x4:ud              {AccWrEn,F@1}
        shl (1|M0)               r57.0<1>:d    r55.0<0;1,0>:d    2:w               {Compacted,I@5}
        add3 (1|M0)              r8.1<1>:d     r7.0<0;0>:d       r73.6<0;0>:d      r5.1<0>:d        {I@5}
        add3 (1|M0)              r40.1<1>:d    r39.0<0;0>:d      r73.6<0;0>:d      r37.1<0>:d       {I@5}
        mov (1|M0)               r50.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        shr (1|M0)               r28.0<1>:ud   r27.0<0;1,0>:ud   0x1E:uw             
        mov (1|M0)               r24.0<1>:f    r21.0<0;1,0>:f                   {Compacted}
        shr (1|M0)               r56.0<1>:ud   r55.0<0;1,0>:ud   0x1E:uw             
        mov (1|M0)               r52.0<1>:f    r49.0<0;1,0>:f                   {Compacted,I@7}
        add3 (1|M0)              r24.1<1>:d    r22.0<0;0>:d      r8.1<0;0>:d       0:w               {I@5}
        addc (1|M0)              r58.0<1>:ud   r3.2<0;1,0>:ud    r57.0<0;1,0>:ud  {AccWrEn}
        add3 (1|M0)              r52.1<1>:d    r50.0<0;0>:d      r40.1<0;0>:d      0:w               {I@5}
        send.ugm (1|M0)          r9       r8      null:0  0x0            0x04100580           {$3} // wr:2+0, rd:1; load.ugm.d32.a64
        send.ugm (1|M0)          r41      r40     null:0  0x0            0x04100580           {$4} // wr:2+0, rd:1; load.ugm.d32.a64
        send.ugm (1|M0)          r25      r24     null:0  0x0            0x04100580           {A@2,$5} // wr:2+0, rd:1; load.ugm.d32.a64
        send.ugm (1|M0)          r53      r52     null:0  0x0            0x04100580           {A@1,$6} // wr:2+0, rd:1; load.ugm.d32.a64
        or (1|M0)                r29.1<1>:d    r28.0<0;1,0>:d    0:w               {Compacted}
        or (1|M0)                r57.1<1>:d    r56.0<0;1,0>:d    0:w               {Compacted}
        mov (1|M0)               r59.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r14.0<1>:f    r11.0<0;1,0>:f                   {Compacted}
        mov (1|M0)               r32.0<1>:f    r30.0<0;1,0>:f                   {Compacted}
        mov (1|M0)               r46.0<1>:f    r43.0<0;1,0>:f                   {Compacted}
        add3 (1|M0)              r14.1<1>:d    r12.0<0;0>:d      r3.3<0;0>:d       r5.1<0>:d       
        add3 (1|M0)              r46.1<1>:d    r44.0<0;0>:d      r3.3<0;0>:d       r37.1<0>:d      
        mov (1|M0)               r60.0<1>:f    r58.0<0;1,0>:f                   {Compacted}
        add3 (1|M0)              r32.1<1>:d    r31.0<0;0>:d      r3.3<0;0>:d       r29.1<0>:d       {I@5}
        add3 (1|M0)              r60.1<1>:d    r59.0<0;0>:d      r3.3<0;0>:d       r57.1<0>:d       {I@4}
        send.ugm (1|M0)          r15      r14     null:0  0x0            0x04100580           {A@4,$7} // wr:2+0, rd:1; load.ugm.d32.a64
        send.ugm (1|M0)          r47      r46     null:0  0x0            0x04100580           {A@2,$8} // wr:2+0, rd:1; load.ugm.d32.a64
        send.ugm (1|M0)          r33      r32     null:0  0x0            0x04100580           {A@2,$9} // wr:2+0, rd:1; load.ugm.d32.a64
        send.ugm (1|M0)          r61      r60     null:0  0x0            0x04100580           {A@1,$10} // wr:2+0, rd:1; load.ugm.d32.a64
        addc (1|M0)              r63.0<1>:ud   r74.2<0;1,0>:ud   0x1:ud              {AccWrEn}
        shr (1|M0)               r18.0<1>:ud   r74.2<0;1,0>:ud   0x1F:uw             
        mov (1|M0)               r64.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r74.4<1>:d    r63.0<0;1,0>:d                   {I@3}
        add3 (1|M0)              r74.5<1>:d    r64.0<0;0>:d      r74.3<0;0>:d      0:w               {I@2}
        shl (1|M0)               r20.0<1>:w    r19.0<0;1,0>:w    2:w              
        cmp (1|M0)    (eq)f1.1   null<1>:d     r74.5<0;1,0>:d    0:w               {I@2}
        or (1|M0)                r19.1<1>:d    r17.0<0;1,0>:d    r18.0<0;1,0>:d   {Compacted}
        add (1|M0)               a0.0<1>:uw    r20.0<0;1,0>:uw   0x9A0:uw              {A@1}
(f1.1)  cmp (1|M0)    (eq)f1.1   null<1>:d     r74.4<0;1,0>:d    4:w              
(W)     and (1|M0)               f0.1<1>:uw    f1.1<0;1,0>:uw    0x1:uw             
        mov (1|M0)               r10.0<1>:f    r9.0<0;1,0>:d                    {Compacted,$3.dst}
        mov (1|M0)               r42.0<1>:f    r41.0<0;1,0>:d                   {Compacted,$4.dst}
        mov (1|M0)               r26.0<1>:f    r25.0<0;1,0>:d                   {Compacted,$5.dst}
        mov (1|M0)               r54.0<1>:f    r53.0<0;1,0>:d                   {Compacted,$6.dst}
        sync.nop                             null                             {Compacted,$2.dst}
        mul (1|M0)               r10.0<1>:f    r75.0<0;1,0>:f    r10.0<0;1,0>:f   {Compacted,F@4}
        mul (1|M0)               r42.0<1>:f    r75.0<0;1,0>:f    r42.0<0;1,0>:f   {Compacted,F@4}
        mul (1|M0)               r26.0<1>:f    r75.0<0;1,0>:f    r26.0<0;1,0>:f   {Compacted,F@4}
        mul (1|M0)               r54.0<1>:f    r75.0<0;1,0>:f    r54.0<0;1,0>:f   {Compacted,F@4}
        sync.nop                             null                             {Compacted,$7.dst}
        mul (1|M0)               r15.0<1>:f    r15.0<0;1,0>:f    r10.0<0;1,0>:f   {Compacted,F@4}
        sync.nop                             null                             {Compacted,$8.dst}
        mul (1|M0)               r47.0<1>:f    r47.0<0;1,0>:f    r42.0<0;1,0>:f   {Compacted,F@4}
        sync.nop                             null                             {Compacted,$9.dst}
        mul (1|M0)               r33.0<1>:f    r33.0<0;1,0>:f    r26.0<0;1,0>:f   {Compacted,F@4}
        sync.nop                             null                             {Compacted,$10.dst}
        mul (1|M0)               r61.0<1>:f    r61.0<0;1,0>:f    r54.0<0;1,0>:f   {Compacted,F@4}
        mov (1|M0)               r16.0<2>:hf   r15.0<0;1,0>:f                   {F@4}
        mov (1|M0)               r48.0<2>:hf   r47.0<0;1,0>:f                   {F@4}
        mov (1|M0)               r34.0<2>:hf   r33.0<0;1,0>:f                   {F@4}
        mov (1|M0)               r62.0<2>:hf   r61.0<0;1,0>:f                   {F@4}
        mov (1|M0)               r[a0.0]<1>:f  r16.0<0;1,0>:hf                  {F@4}
        mov (1|M0)               r[a0.0,4]<1>:f  r34.0<0;1,0>:hf                {F@3}
        add (1|M0)               a0.0<1>:uw    r20.0<0;1,0>:uw   0x980:uw              {A@1}
        mov (1|M0)               r[a0.0]<1>:f  r48.0<0;1,0>:hf                 
        mov (1|M0)               r[a0.0,4]<1>:f  r62.0<0;1,0>:hf                {F@4}
(f0.1.any8h) goto (8|M0)                     L1968                  L1968                
L1936:
(W)     mov (2|M0)               r74.2<1>:ud   r74.4<1;1,0>:ud                 
        goto.b (8|M0)                        L1968                  L720                
L1968:
        join (8|M0)                          L1984                                
L1984:
        mul (1|M0)               r1.2<1>:f     r77.0<0;1,0>:f    r77.0<0;1,0>:f   {Compacted,F@3}
        mul (1|M0)               r5.0<1>:f     r77.4<0;1,0>:f    r77.4<0;1,0>:f  
        mul (1|M0)               r9.0<1>:f     r76.0<0;1,0>:f    r76.0<0;1,0>:f   {Compacted,F@3}
        mul (1|M0)               r13.0<1>:f    r76.4<0;1,0>:f    r76.4<0;1,0>:f  
        mul (1|M0)               r17.0<1>:f    r77.1<0;1,0>:f    r77.1<0;1,0>:f   {I@7}
        mul (1|M0)               r21.0<1>:f    r77.5<0;1,0>:f    r77.5<0;1,0>:f  
        mul (1|M0)               r25.0<1>:f    r76.1<0;1,0>:f    r76.1<0;1,0>:f  
        mul (1|M0)               r29.0<1>:f    r76.5<0;1,0>:f    r76.5<0;1,0>:f  
        mov (1|M0)               r2.0<2>:hf    r1.2<0;1,0>:f                    {F@7}
        mov (1|M0)               r6.0<2>:hf    r5.0<0;1,0>:f                    {F@7}
        mov (1|M0)               r10.0<2>:hf   r9.0<0;1,0>:f                    {F@7}
        mov (1|M0)               r14.0<2>:hf   r13.0<0;1,0>:f                   {F@7}
        mov (1|M0)               r18.0<2>:hf   r17.0<0;1,0>:f                   {F@7}
        mov (1|M0)               r22.0<2>:hf   r21.0<0;1,0>:f                   {F@7}
        mov (1|M0)               r26.0<2>:hf   r25.0<0;1,0>:f                   {F@7}
        mov (1|M0)               r30.0<2>:hf   r29.0<0;1,0>:f                   {F@7}
        mov (1|M0)               r3.6<1>:f     r2.0<0;1,0>:hf                   {F@7}
        mov (1|M0)               r7.0<1>:f     r6.0<0;1,0>:hf                   {F@7}
        mov (1|M0)               r11.0<1>:f    r10.0<0;1,0>:hf                  {F@7}
        mov (1|M0)               r15.0<1>:f    r14.0<0;1,0>:hf                  {F@7}
        mov (1|M0)               r19.0<1>:f    r18.0<0;1,0>:hf                  {F@7}
        mov (1|M0)               r23.0<1>:f    r22.0<0;1,0>:hf                  {F@7}
        mov (1|M0)               r27.0<1>:f    r26.0<0;1,0>:hf                  {F@7}
        mov (1|M0)               r31.0<1>:f    r30.0<0;1,0>:hf                  {F@7}
        shl (1|M0)               r73.0<1>:ud   r73.0<0;1,0>:ud   0x2:uw             
(W)     mov (1|M0)               r36.0<1>:ud   0x3FFF0:ud                             
        mad (1|M0)               r3.6<1>:f     r3.6<0;0>:f       r77.2<0;0>:f      r77.2<0>:f       {F@7}
        mad (1|M0)               r7.0<1>:f     r7.0<0;0>:f       r77.6<0;0>:f      r77.6<0>:f       {F@7}
        mad (1|M0)               r11.0<1>:f    r11.0<0;0>:f      r76.2<0;0>:f      r76.2<0>:f       {F@7}
        mad (1|M0)               r15.0<1>:f    r15.0<0;0>:f      r76.6<0;0>:f      r76.6<0>:f       {F@7}
        mad (1|M0)               r19.0<1>:f    r19.0<0;0>:f      r77.3<0;0>:f      r77.3<0>:f       {F@7}
        mad (1|M0)               r23.0<1>:f    r23.0<0;0>:f      r77.7<0;0>:f      r77.7<0>:f       {F@7}
        mad (1|M0)               r27.0<1>:f    r27.0<0;0>:f      r76.3<0;0>:f      r76.3<0>:f       {F@7}
        mad (1|M0)               r31.0<1>:f    r31.0<0;0>:f      r76.7<0;0>:f      r76.7<0>:f       {F@7}
        and (1|M0)               r35.0<1>:ud   r73.0<0;1,0>:ud   0x3FFF0:ud              {I@2}
        mov (1|M0)               r4.0<2>:hf    r3.6<0;1,0>:f                    {F@7}
        mov (1|M0)               r8.0<2>:hf    r7.0<0;1,0>:f                    {F@7}
        mov (1|M0)               r12.0<2>:hf   r11.0<0;1,0>:f                   {F@7}
        mov (1|M0)               r16.0<2>:hf   r15.0<0;1,0>:f                   {F@7}
        mov (1|M0)               r20.0<2>:hf   r19.0<0;1,0>:f                   {F@7}
        mov (1|M0)               r24.0<2>:hf   r23.0<0;1,0>:f                   {F@7}
        mov (1|M0)               r28.0<2>:hf   r27.0<0;1,0>:f                   {F@7}
        mov (1|M0)               r32.0<2>:hf   r31.0<0;1,0>:f                   {F@7}
        bfn.0xEA (1|M0)          r73.0<1>:ud   r73.2<0;0>:ud     r73.0<0;0>:ud     r36.0<0>:ud      {I@2} // s0|s1&s2
        add (1|M0)               r4.0<1>:hf    r4.0<0;1,0>:hf    r8.0<0;1,0>:hf   {F@7}
        add (1|M0)               r12.0<1>:hf   r12.0<0;1,0>:hf   r16.0<0;1,0>:hf  {F@6}
        add (1|M0)               r20.0<1>:hf   r20.0<0;1,0>:hf   r24.0<0;1,0>:hf  {F@5}
        add (1|M0)               r28.0<1>:hf   r28.0<0;1,0>:hf   r32.0<0;1,0>:hf  {F@4}
        shl (1|M0)               r37.0<1>:ud   r73.0<0;1,0>:ud   0x2:uw              {I@1}
        mov (1|M0)               r34.0<1>:f    r4.0<0;1,0>:hf                   {F@4}
        mov (1|M0)               r38.0<1>:f    r12.0<0;1,0>:hf                  {F@4}
        mov (1|M0)               r34.1<1>:f    r20.0<0;1,0>:hf                  {F@4}
        mov (1|M0)               r38.1<1>:f    r28.0<0;1,0>:hf                  {F@4}
        or (1|M0)                r39.0<1>:ud   r37.0<0;1,0>:ud   0x20:uw              {I@1}
        send.slm (1|M0)          null     r37     r34:2   0x0            0x02000704           {A@2,$11} // wr:1+2, rd:0; store.slm.d64.a32
        send.slm (1|M0)          null     r39     r38:2   0x0            0x02000704           {A@1,$12} // wr:1+2, rd:0; store.slm.d64.a32
(W)     send.slm (1|M0)          r40      r0      null:0  0x0            0x0210001F           {$13} // wr:1+0, rd:1; fence.slm.none.group
(W)     mov (1|M0)               r41.2<1>:ud   0x0:ud                             
(W)     mov (2|M0)               r41.10<1>:ub  r0.11<0;1,0>:ub                 
(W)     mov (8|M0)               null<1>:ud    r40.0<1;1,0>:ud                  {$13.dst}
(W)     send.gtwy (1|M0)         null     r41     null:0  0x0            0x02000004           {A@2,$14} // wr:1+0, rd:0; signal barrier
(W)     sync.bar                             null                            
        shl (1|M0)               r67.0<1>:d    r73.1<0;1,0>:d    2:w               {Compacted}
        shr (1|M0)               r66.0<1>:ud   r73.1<0;1,0>:ud   0x1E:uw             
        addc (1|M0)              r68.0<1>:ud   r3.4<0;1,0>:ud    r67.0<0;1,0>:ud  {AccWrEn,I@2}
        or (1|M0)                r67.1<1>:d    r66.0<0;1,0>:d    0:w               {Compacted,I@2}
        mov (1|M0)               r69.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r70.0<1>:d    r68.0<0;1,0>:d                   {I@3}
        add3 (1|M0)              r70.1<1>:d    r69.0<0;0>:d      r3.5<0;0>:d       r67.1<0>:d       {I@2}
        shl (1|M0)               r42.0<1>:ud   r35.0<0;1,0>:ud   0x2:uw             
        send.ugm (1|M0)          r71      r70     null:0  0x0            0x04100580           {A@2,$15} // wr:2+0, rd:1; load.ugm.d32.a64
        or (1|M0)                r54.0<1>:ud   r42.0<0;1,0>:ud   0x20:uw              {I@1}
        send.slm (1|M0)          r43      r42     null:0  0x0            0x0210B700           {$0} // wr:1+0, rd:1; load.slm.d64x4t.a32
        send.slm (1|M0)          r55      r54     null:0  0x0            0x0210B700           {A@1,$1} // wr:1+0, rd:1; load.slm.d64x4t.a32
        send.ugm (1|M0)          r78      r74     null:0  0x0            0x04100580           {$2} // wr:2+0, rd:1; load.ugm.d32.a64
        shl (1|M0)               r75.1<1>:d    r2.3<0;1,0>:d     1:w               {$2.src}
        mov (1|M0)               r75.2<2>:d    0:d                              
        mov (1|M0)               r75.3<2>:d    0:d                              
        add (1|M0)               r44.0<1>:f    r43.0<0;1,0>:f    r43.4<0;1,0>:f   {Compacted,$0.dst}
        add (1|M0)               r46.0<1>:f    r43.2<0;1,0>:f    r43.6<0;1,0>:f  
        add (1|M0)               r48.0<1>:f    r43.1<0;1,0>:f    r43.5<0;1,0>:f  
        add (1|M0)               r50.0<1>:f    r43.3<0;1,0>:f    r43.7<0;1,0>:f  
        add (1|M0)               r56.0<1>:f    r55.0<0;1,0>:f    r55.4<0;1,0>:f   {Compacted,$1.dst}
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
        math.sqt (1|M0)          r52.0<1>:f    r52.0<0;1,0>:f                   {@2,$3}
        math.sqt (1|M0)          r64.0<1>:f    r64.0<0;1,0>:f                   {@1,$4}
        math.inv (1|M0)          r52.0<1>:f    r52.0<0;1,0>:f                   {$3}
        math.inv (1|M0)          r64.0<1>:f    r64.0<0;1,0>:f                   {$4}
        mov (1|M0)               r53.0<2>:hf   r52.0<0;1,0>:f                   {$3.dst}
        mov (1|M0)               r65.0<2>:hf   r64.0<0;1,0>:f                   {$4.dst}
        mov (1|M0)               r74.14<2>:hf  r71.0<0;1,0>:f                   {$15.dst}
        mov (1|M0)               r73.7<1>:f    r53.0<0;1,0>:hf                  {F@3}
        mov (1|M0)               r74.6<1>:f    r65.0<0;1,0>:hf                  {F@3}
L3736:
        shl (1|M0)               r1.2<1>:d     r75.2<0;1,0>:d    3:w               {I@2}
        shl (1|M0)               r4.0<1>:d     r75.2<0;1,0>:d    1:w               {Compacted}
        or (1|M0)                r1.2<1>:d     r1.2<0;1,0>:d     r73.2<0;1,0>:d   {I@2}
        sync.nop                             null                             {Compacted,$6.src}
        shl (1|M0)               r11.0<1>:w    r4.0<0;1,0>:w     2:w               {I@2}
        or (1|M0)                r5.0<1>:d     r1.2<0;1,0>:d     r73.3<0;1,0>:d   {I@2}
        add (1|M0)               r23.0<1>:d    r1.2<0;1,0>:d     r73.4<0;1,0>:d   {$7.src}
        shl (1|M0)               r7.0<1>:d     r5.0<0;1,0>:d     2:w               {Compacted,I@2}
        add (1|M0)               a0.0<1>:uw    r11.0<0;1,0>:uw   0x9A0:uw              {A@1}
        addc (1|M0)              r8.0<1>:ud    r73.5<0;1,0>:ud   r7.0<0;1,0>:ud   {AccWrEn,I@2}
        shl (1|M0)               r25.0<1>:d    r23.0<0;1,0>:d    2:w               {Compacted}
        mov (1|M0)               r10.0<1>:f    r8.0<0;1,0>:f                    {Compacted,I@2}
        mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
        addc (1|M0)              r19.0<1>:ud   r10.0<0;1,0>:ud   0x4:ud              {AccWrEn,F@1}
        mul (1|M0)               r12.0<1>:f    r[a0.0]<0;1,0>:f  r73.7<0;1,0>:f  
        mul (1|M0)               r15.0<1>:f    r[a0.0,4]<0;1,0>:f  r73.7<0;1,0>:f {A@1}
        mov (1|M0)               r20.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,A@1}
        add (1|M0)               a0.0<1>:uw    r11.0<0;1,0>:uw   0x980:uw              {A@1}
        addc (1|M0)              r26.0<1>:ud   r73.5<0;1,0>:ud   r25.0<0;1,0>:ud  {AccWrEn,I@5}
        shr (1|M0)               r6.0<1>:ud    r5.0<0;1,0>:ud    0x1E:uw             
        shr (1|M0)               r24.0<1>:ud   r23.0<0;1,0>:ud   0x1E:uw             
        sync.nop                             null                             {Compacted,$8.src}
        mov (1|M0)               r28.0<1>:f    r26.0<0;1,0>:f                   {Compacted,I@3}
        mov (1|M0)               r13.0<2>:hf   r12.0<0;1,0>:f                   {F@3}
        mov (1|M0)               r16.0<2>:hf   r15.0<0;1,0>:f                   {F@3}
        mov (1|M0)               r27.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        or (1|M0)                r7.1<1>:d     r6.0<0;1,0>:d     0:w               {Compacted,I@3}
        mul (1|M0)               r29.0<1>:f    r[a0.0]<0;1,0>:f  r74.6<0;1,0>:f  
        mul (1|M0)               r33.0<1>:f    r[a0.0,4]<0;1,0>:f  r74.6<0;1,0>:f {A@1}
        or (1|M0)                r25.1<1>:d    r24.0<0;1,0>:d    0:w               {Compacted,A@1}
        sync.nop                             null                             {Compacted,$11.src}
        addc (1|M0)              r37.0<1>:ud   r28.0<0;1,0>:ud   0x4:ud              {AccWrEn,F@5}
        mul (1|M0)               r13.0<1>:hf   r74.14<0;1,0>:hf  r13.0<0;1,0>:hf  {F@4}
        mul (1|M0)               r16.0<1>:hf   r74.14<0;1,0>:hf  r16.0<0;1,0>:hf  {F@4}
        add3 (1|M0)              r10.1<1>:d    r9.0<0;0>:d       r73.6<0;0>:d      r7.1<0>:d        {I@3}
        mov (1|M0)               r30.0<2>:hf   r29.0<0;1,0>:f                   {F@4}
        mov (1|M0)               r34.0<2>:hf   r33.0<0;1,0>:f                   {F@4}
        add3 (1|M0)              r28.1<1>:d    r27.0<0;0>:d      r73.6<0;0>:d      r25.1<0>:d       {I@3}
        mov (1|M0)               r38.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted,$12.src}
        mov (1|M0)               r22.0<1>:f    r19.0<0;1,0>:f                   {Compacted}
        mov (1|M0)               r40.0<1>:f    r37.0<0;1,0>:f                   {Compacted,I@4}
        mov (1|M0)               r14.0<1>:f    r13.0<0;1,0>:hf                  {F@6}
        mov (1|M0)               r18.0<1>:f    r16.0<0;1,0>:hf                  {F@6}
        add3 (1|M0)              r22.1<1>:d    r20.0<0;0>:d      r10.1<0;0>:d      0:w               {I@3}
        mov (1|M0)               r32.0<1>:f    r30.0<0;1,0>:hf                  {F@6}
        mov (1|M0)               r36.0<1>:f    r34.0<0;1,0>:hf                  {F@6}
        add3 (1|M0)              r40.1<1>:d    r38.0<0;0>:d      r28.1<0;0>:d      0:w               {I@2}
        send.ugm (1|M0)          null     r10     r14:1   0x0            0x04000584           {A@4,$6} // wr:2+1, rd:0; store.ugm.d32.a64
        send.ugm (1|M0)          null     r22     r18:1   0x0            0x04000584           {A@2,$7} // wr:2+1, rd:0; store.ugm.d32.a64
        send.ugm (1|M0)          null     r28     r32:1   0x0            0x04000584           {A@2,$8} // wr:2+1, rd:0; store.ugm.d32.a64
        send.ugm (1|M0)          null     r40     r36:1   0x0            0x04000584           {A@1,$10} // wr:2+1, rd:0; store.ugm.d32.a64
        add3 (1|M0)              r42.0<1>:d    r73.3<0;0>:d      r75.1<0;0>:d      r1.2<0>:d       
        sync.nop                             null                             {Compacted,$10.src}
        add3 (1|M0)              r41.0<1>:d    r73.3<0;0>:d      r75.1<0;0>:d      r1.2<0>:d        {$14.src}
        shl (1|M0)               r44.0<1>:d    r42.0<0;1,0>:d    2:w               {Compacted,I@2}
        shr (1|M0)               r43.0<1>:ud   r42.0<0;1,0>:ud   0x1E:uw             
        addc (1|M0)              r45.0<1>:ud   r73.5<0;1,0>:ud   r44.0<0;1,0>:ud  {AccWrEn,I@2}
        or (1|M0)                r44.1<1>:d    r43.0<0;1,0>:d    0:w               {Compacted,I@2}
        mov (1|M0)               r46.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        sync.nop                             null                             {Compacted,$9.src}
        mov (1|M0)               r48.0<1>:f    r45.0<0;1,0>:f                   {Compacted,I@3}
        addc (1|M0)              r51.0<1>:ud   r3.2<0;1,0>:ud    r44.0<0;1,0>:ud  {AccWrEn}
        add3 (1|M0)              r48.1<1>:d    r46.0<0;0>:d      r73.6<0;0>:d      r44.1<0>:d       {I@2}
        mov (1|M0)               r52.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r54.0<1>:f    r51.0<0;1,0>:f                   {Compacted,I@3}
        add3 (1|M0)              r54.1<1>:d    r52.0<0;0>:d      r3.3<0;0>:d       r44.1<0>:d       {I@1}
        or (1|M0)                r63.0<1>:d    r41.0<0;1,0>:d    1:w               {Compacted}
        addc (1|M0)              r57.0<1>:ud   r48.0<0;1,0>:ud   0x4:ud              {AccWrEn,F@2}
        shl (1|M0)               r65.0<1>:d    r63.0<0;1,0>:d    2:w               {Compacted,I@2}
        mov (1|M0)               r58.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        shr (1|M0)               r64.0<1>:ud   r63.0<0;1,0>:ud   0x1E:uw             
        sync.nop                             null                             {Compacted,$5.src}
        mov (1|M0)               r60.0<1>:f    r57.0<0;1,0>:f                   {Compacted,I@4}
        addc (1|M0)              r66.0<1>:ud   r3.2<0;1,0>:ud    r65.0<0;1,0>:ud  {AccWrEn,I@3}
        add3 (1|M0)              r60.1<1>:d    r58.0<0;0>:d      r48.1<0;0>:d      0:w               {I@3}
        or (1|M0)                r65.1<1>:d    r64.0<0;1,0>:d    0:w               {Compacted,I@3}
        mov (1|M0)               r67.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r68.0<1>:f    r66.0<0;1,0>:f                   {Compacted,I@4}
        add3 (1|M0)              r68.1<1>:d    r67.0<0;0>:d      r3.3<0;0>:d       r65.1<0>:d       {I@1}
        addc (1|M0)              r71.0<1>:ud   r75.2<0;1,0>:ud   0x1:ud              {AccWrEn}
        shl (1|M0)               r2.0<1>:d     r75.3<0;1,0>:d    1:w               {Compacted}
        mov (1|M0)               r72.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
        mov (1|M0)               r75.4<1>:d    r71.0<0;1,0>:d                   {I@3}
        add3 (1|M0)              r75.5<1>:d    r72.0<0;0>:d      r75.3<0;0>:d      0:w               {I@2}
        shr (1|M0)               r3.6<1>:ud    r75.2<0;1,0>:ud   0x1F:uw             
        cmp (1|M0)    (eq)f1.0   null<1>:d     r75.5<0;1,0>:d    0:w               {I@2}
        or (1|M0)                r4.1<1>:d     r2.0<0;1,0>:d     r3.6<0;1,0>:d    {I@2}
(f1.0)  cmp (1|M0)    (eq)f1.0   null<1>:d     r75.4<0;1,0>:d    4:w              
(W)     and (1|M0)               f0.0<1>:uw    f1.0<0;1,0>:uw    0x1:uw             
        send.ugm (1|M0)          r49      r48     null:0  0x0            0x04100580           {$11} // wr:2+0, rd:1; load.ugm.d32.a64
        sync.nop                             null                             {Compacted,F@3}
        send.ugm (1|M0)          r56      r54     null:0  0x0            0x04100580           {$12} // wr:2+0, rd:1; load.ugm.d32.a64
        mov (1|M0)               r50.0<1>:f    r49.0<0;1,0>:d                   {Compacted,$11.dst}
        sync.nop                             null                             {Compacted,$2.dst}
        mul (1|M0)               r50.0<1>:f    r78.0<0;1,0>:f    r50.0<0;1,0>:f   {Compacted,F@1}
        sync.nop                             null                             {Compacted,$12.dst}
        mul (1|M0)               r56.0<1>:f    r56.0<0;1,0>:f    r50.0<0;1,0>:f   {Compacted,F@1}
        send.ugm (1|M0)          null     r48     r56:1   0x0            0x04000584           {A@1,$9} // wr:2+1, rd:0; store.ugm.d32.a64
        send.ugm (1|M0)          r61      r60     null:0  0x0            0x04100580           {$13} // wr:2+0, rd:1; load.ugm.d32.a64
        send.ugm (1|M0)          r70      r68     null:0  0x0            0x04100580           {$14} // wr:2+0, rd:1; load.ugm.d32.a64
        mov (1|M0)               r62.0<1>:f    r61.0<0;1,0>:d                   {Compacted,$13.dst}
        mul (1|M0)               r62.0<1>:f    r78.0<0;1,0>:f    r62.0<0;1,0>:f   {Compacted,F@1}
        sync.nop                             null                             {Compacted,$14.dst}
        mul (1|M0)               r70.0<1>:f    r70.0<0;1,0>:f    r62.0<0;1,0>:f   {Compacted,F@1}
        send.ugm (1|M0)          null     r60     r70:1   0x0            0x04000584           {A@1,$5} // wr:2+1, rd:0; store.ugm.d32.a64
(f0.0.any8h) goto (8|M0)                     L5112                  L5112                
L5080:
(W)     mov (2|M0)               r75.2<1>:ud   r75.4<1;1,0>:ud                 
        goto.b (8|M0)                        L5112                  L3736                
L5112:
        join (8|M0)                          L5128                                
L5128:
(W)     mov (8|M0)               r127.0<1>:f   r0.0<1;1,0>:f                    {Compacted}
        sync.nop                             null                             {Compacted,I@7}
(W)     send.ugm (1|M0)          r4       r0      null:0  0x0            0x0210641F           {$15} // wr:1+0, rd:1; fence invalid flush type scoped to tile
(W)     mov (8|M0)               null<1>:ud    r4.0<1;1,0>:ud                   {$15.dst}
(W)     send.gtwy (1|M0)         null     r127    null:0  0x0            0x02000010           {EOT,A@1} // wr:1+0, rd:0; end of thread
L5192:
        mov (1|M0)               r1.2<1>:d     cr0.0<0;1,0>:ud                  {A@1}
        and (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   -1265:w               {A@1}
        or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   1264:w               {A@1}
        mov (1|M0)               r2.0<1>:f     r75.6<0;1,0>:ud                  {Compacted,A@1}
        mov (1|M0)               r8.0<1>:f     0xB4C00000:f                               {Compacted}
        math.inv (1|M0)          r7.0<1>:f     r2.0<0;1,0>:f                    {@2,$0}
        mov (1|M0)               r4.1<1>:f     r78.5<0;1,0>:ud                  {I@4}
        sync.nop                             null                             {Compacted,$0.dst}
        mad (1|M0)               r7.0<1>:f     r7.0<0;0>:f       r8.0<0;0>:f       r7.0<0>:f        {F@2}
        mov (1|M0)               r78.4<1>:ud   r2.0<0;1,0>:f                   
        mov (1|M0)               r5.0<1>:ud    r4.1<0;1,0>:f                    {F@2}
        mul (1|M0)               r9.0<1>:f     r7.0<0;1,0>:f     r4.1<0;1,0>:f    {Compacted,F@1}
        add (1|M0)               r78.4<1>:ud   r75.6<0;1,0>:ud   -r78.4<0;1,0>:ud {I@2}
        add (1|M0)               r5.0<1>:ud    r78.5<0;1,0>:ud   -r5.0<0;1,0>:ud  {Compacted,I@2}
        mov (1|M0)               r10.0<1>:ud   r9.0<0;1,0>:f                    {F@1}
        mov (1|M0)               r4.0<1>:f     r78.4<0;1,0>:ud                  {Compacted,I@3}
        mov (1|M0)               r6.0<1>:f     r5.0<0;1,0>:ud                   {Compacted,I@2}
        mov (1|M0)               r11.0<1>:f    r10.0<0;1,0>:ud                  {Compacted,I@1}
(W)     mov (1|M0)               r14.0<1>:hf   0x1:hf                             
        mad (1|M0)               r4.1<1>:f     r4.1<0;0>:f       r11.0<0;0>:f      -r2.0<0>:f       {F@2}
        mad (1|M0)               r11.0<1>:f    r6.0<0;0>:f       r11.0<0;0>:f      -r4.0<0>:f      
        add (1|M0)               r4.1<1>:f     r4.1<0;1,0>:f     r11.0<0;1,0>:f   {Compacted,F@1}
        mul (1|M0)               r7.0<1>:f     r7.0<0;1,0>:f     r4.1<0;1,0>:f    {Compacted,F@1}
        mov (1|M0)               r12.0<1>:ud   r7.0<0;1,0>:f                    {F@1}
        add (1|M0)               r10.0<1>:ud   r10.0<0;1,0>:ud   r12.0<0;1,0>:ud  {Compacted,I@1}
(W)     mul (1|M0)               acc0.0<1>:ud  r10.0<0;1,0>:ud   r75.12<0;1,0>:uw {I@1}
        mach (1|M0)              r13.0<1>:ud   r10.0<0;1,0>:ud   r75.6<0;1,0>:ud  {Compacted}
        add (1|M0)               r78.5<1>:ud   r78.5<0;1,0>:ud   -r13.0<0;1,0>:ud {I@1}
        cmp (1|M0)    (ge)f0.0   null<1>:ud    r78.5<0;1,0>:ud   r75.6<0;1,0>:ud  {I@1}
(f0.0)  sel (1|M0)               r15.0<1>:d    r14.0<0;1,0>:w    0:w              
        add (1|M0)               r75.7<1>:ud   r10.0<0;1,0>:ud   r15.0<0;1,0>:ud  {Compacted,I@1}
        mov (1|M0)               cr0.0<1>:ud   r1.2<0;1,0>:d                    {A@1}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        ret (8|M0)                           r78.2                            {A@1}
L5648:
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
