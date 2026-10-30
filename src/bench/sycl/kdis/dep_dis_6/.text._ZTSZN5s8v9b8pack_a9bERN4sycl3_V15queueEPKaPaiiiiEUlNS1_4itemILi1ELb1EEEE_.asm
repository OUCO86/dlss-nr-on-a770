L0:
(W)     mov (8|M0)               r127.0<1>:ud  0x0:ud                             
(W)     and (1|M0)               r127.2<1>:ud  r0.0<0;1,0>:ud    0xFFFFFFC0:ud             
(W)     and (1|M0)               r127.0<1>:uw  r0.4<0;1,0>:uw    0xFF:uw             
(W)     add (1|M0)               r127.2<1>:ud  r127.2<0;1,0>:ud  0x40:ud              {I@2}
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
(W)     send.dc0 (8|M0)          r8       r127    null:0  0x0            0x022843FD           {A@1,$2} // wr:1h+0, rd:2; oword aligned block read x4
(W)     mov (8|M0)               r108.0<1>:ud  r0.0<1;1,0>:ud                  
(W)     or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x4C0:uw              {A@1}
(W)     mul (1|M0)               acc0.0<1>:d   r7.3<0;1,0>:d     r108.2<0;1,0>:uw {A@1}
(W)     cmp (16|M0)   (gt)f1.0   null<1>:d     r8.2<0;1,0>:d     -1:w               {$2.dst}
(W)     cmp (16|M16)  (gt)f1.0   null<1>:d     r8.2<0;1,0>:d     -1:w              
(W)     mach (1|M0)              r3.0<1>:d     r7.3<0;1,0>:d     r108.1<0;1,0>:d  {$0.dst}
        add3 (16|M0)             r109.0<1>:d   r3.0<0;0>:d       r1.0<1;0>:uw      r7.0<0>:d        {I@1}
        add3 (16|M16)            r111.0<1>:d   r3.0<0;0>:d       r2.0<1;0>:uw      r7.0<0>:d       
        shr (16|M0)              r113.0<1>:ud  r109.0<1;1,0>:ud  10:w               {I@2}
        shr (16|M16)             r115.0<1>:ud  r111.0<1;1,0>:ud  10:w               {I@2}
(f1.0)  goto (32|M0)                         L2304                  L2304                
L432:
(W)     shr (1|M0)               r3.0<1>:ud    r8.2<0;1,0>:ud    20:w              
(W)     asr (1|M0)               r4.0<1>:d     r8.2<0;1,0>:d     20:w               {Compacted}
(W)     mov (1|M0)               r7.0<1>:d     1044480:d                              
(W)     asr (1|M0)               r2.0<1>:d     r8.2<0;1,0>:d     31:w               {Compacted}
(W)     and (1|M0)               r10.0<1>:d    r8.2<0;1,0>:d     1048575:d              
(W)     bfn.0xF8 (1|M0)          r8.0<1>:ud    r4.0<0;0>:ud      r7.0<0;0>:d       r3.0<0>:ud       {I@3} // s0&s1|s2
(W)     mov (1|M0)               r12.0<1>:ud   0x49800000:ud                             
        sync.nop                             null                             {Compacted,$1.dst}
(W)     shr (1|M0)               r5.0<1>:ud    r2.0<0;1,0>:ud    8:w               {I@4}
(W)     mov (1|M0)               r11.0<1>:f    r10.0<0;1,0>:ud                  {Compacted,I@4}
(W)     mov (1|M0)               r9.4<1>:f     r8.0<0;1,0>:ud                   {Compacted,I@3}
(W)     mov (1|M0)               r14.0<1>:ud   0x53800000:ud                             
(W)     mov (1|M0)               r6.0<1>:f     r5.0<0;1,0>:ud                   {Compacted,I@2}
(W)     mad (1|M0)               r13.0<1>:f    r11.0<0;0>:f      r12.0<0;0>:f      r9.4<0>:f        {Compacted,F@2}
(W)     mov (1|M0)               r17.0<1>:ud   0xB4E00000:ud                             
(W)     mad (1|M0)               r15.0<1>:f    r13.0<0;0>:f      r14.0<0;0>:f      r6.0<0>:f        {Compacted,A@1}
(W)     mov (1|M0)               r21.0<1>:ud   0x0:ud                             
        sync.nop                             null                             {Compacted,F@1}
(W)     math.inv (1|M0)          r16.0<1>:f    r15.0<0;1,0>:f                   {$3}
        sync.nop                             null                             {Compacted,$3.dst}
(W)     mad (1|M0)               r18.0<1>:f    r16.0<0;0>:f      r17.0<0;0>:f      r16.0<0>:f       {Compacted,I@2}
        shr (16|M0)              r25.0<1>:ud   r109.0<1;1,0>:ud  30:w              
(W)     mul (1|M0)               r19.0<1>:f    r18.0<0;1,0>:f    0.0:f               {Compacted,F@1}
(W)     mul (1|M0)               r23.0<1>:f    r9.4<0;1,0>:f     -1.048576e+06:f               {Compacted}
(W)     rndd (1|M0)              r20.0<1>:f    r19.0<0;1,0>:f                   {Compacted,F@2}
        shr (16|M16)             r27.0<1>:ud   r111.0<1;1,0>:ud  30:w              
(W)     mad (1|M0)               r22.0<1>:f    r21.0<0;0>:f      r20.0<0;0>:f      -r11.0<0>:f      {Compacted,A@1}
        mov (16|M0)              r29.0<1>:f    r25.0<1;1,0>:ud                  {Compacted,I@2}
(W)     mad (1|M0)               r24.0<1>:f    r22.0<0;0>:f      r20.0<0;0>:f      r23.0<0>:f       {Compacted,F@2}
        mov (16|M16)             r31.0<1>:f    r27.0<1;1,0>:ud                  {Compacted,I@1}
        mad (16|M0)              acc0.0<1>:f   r29.0<1;0>:f      r12.0<0;0>:f      r24.0<0>:f       {Compacted,F@2}
        mad (16|M16)             acc2.0<1>:f   r31.0<1;0>:f      r12.0<0;0>:f      r24.0<0>:f       {F@2}
        mul (16|M0)              acc0.0<1>:f   r18.0<0;1,0>:f    acc0.0<1;1,0>:f 
(W)     mul (1|M0)               r50.0<1>:f    r11.0<0;1,0>:f    9.536743e-07:f               {Compacted}
        mul (16|M16)             acc2.0<1>:f   r18.0<0;1,0>:f    acc2.0<1;1,0>:f 
        rndd (16|M0)             r37.0<1>:f    acc0.0<1;1,0>:f                  {Compacted}
        rndd (16|M16)            r39.0<1>:f    acc2.0<1;1,0>:f                  {Compacted}
        mul (16|M0)              acc0.0<1>:f   r50.0<0;1,0>:f    r37.0<1;1,0>:f   {Compacted,F@2}
        mul (16|M16)             acc2.0<1>:f   r50.0<0;1,0>:f    r39.0<1;1,0>:f   {Compacted,F@2}
        rndd (16|M0)             acc0.0<1>:f   acc0.0<1;1,0>:f                 
        and (16|M0)              r72.0<1>:d    r113.0<1;1,0>:d   1048575:d              
(W)     mul (1|M0)               r45.0<1>:f    r6.0<0;1,0>:f     -1.048576e+06:f               {Compacted}
        mad (16|M0)              r41.0<1>:f    r24.0<0;0>:f      r37.0<1;0>:f      -r9.4<0>:f       {Compacted}
        rndd (16|M16)            acc2.0<1>:f   acc2.0<1;1,0>:f                 
        mad (16|M0)              r59.0<1>:f    -acc0.0<1;0>:f    r37.0<1;0>:f      r50.0<0>:f      
(W)     mov (1|M0)               r63.0<1>:ud   0xBF800000:ud                             
        and (16|M16)             r74.0<1>:d    r115.0<1;1,0>:d   1048575:d              
        mad (16|M16)             r43.0<1>:f    r24.0<0;0>:f      r39.0<1;0>:f      -r9.4<0>:f       {Compacted}
        mov (16|M0)              r76.0<1>:f    r72.0<1;1,0>:ud                  {Compacted,I@3}
        mad (16|M0)              r46.0<1>:f    r41.0<1;0>:f      r37.0<1;0>:f      r45.0<0>:f       {Compacted,F@5}
        mad (16|M16)             r61.0<1>:f    -acc2.0<1;0>:f    r39.0<1;0>:f      r50.0<0>:f      
        mad (16|M0)              r68.0<1>:f    r29.0<1;0>:f      r59.0<1;0>:f      -r12.0<0>:f      {Compacted,F@5}
        mov (16|M16)             r78.0<1>:f    r74.0<1;1,0>:ud                  {Compacted,I@1}
        mad (16|M16)             r48.0<1>:f    r43.0<1;0>:f      r39.0<1;0>:f      r45.0<0>:f       {Compacted,F@6}
        mad (16|M0)              r64.0<1>:f    r46.0<1;0>:f      acc0.0<1;0>:f     r63.0<0>:f       {Compacted,F@5}
        mad (16|M16)             r70.0<1>:f    r31.0<1;0>:f      r61.0<1;0>:f      -r12.0<0>:f      {Compacted,F@5}
        mad (16|M0)              acc0.0<1>:f   r76.0<1;0>:f      r68.0<1;0>:f      r12.0<0>:f       {Compacted,F@5}
        mad (16|M16)             r66.0<1>:f    r48.0<1;0>:f      acc2.0<1;0>:f     r63.0<0>:f       {Compacted,F@4}
        mad (16|M16)             acc2.0<1>:f   r78.0<1;0>:f      r70.0<1;0>:f      r12.0<0>:f       {F@3}
        mad (16|M0)              acc0.0<1>:f   acc0.0<1;0>:f     r64.0<1;0>:f      r14.0<0>:f       {Compacted}
        mad (16|M16)             acc2.0<1>:f   acc2.0<1;0>:f     r66.0<1;0>:f      r14.0<0>:f       {F@3}
        mul (16|M0)              acc0.0<1>:f   r18.0<0;1,0>:f    acc0.0<1;1,0>:f 
(W)     mul (1|M0)               r21.0<1>:f    r9.4<0;1,0>:f     9.536743e-07:f               {Compacted}
        mul (16|M16)             acc2.0<1>:f   r18.0<0;1,0>:f    acc2.0<1;1,0>:f 
        rndd (16|M0)             r88.0<1>:f    acc0.0<1;1,0>:f                  {Compacted}
        rndd (16|M16)            r90.0<1>:f    acc2.0<1;1,0>:f                  {Compacted}
        mul (16|M0)              acc0.0<1>:f   r50.0<0;1,0>:f    r88.0<1;1,0>:f   {Compacted,F@2}
        mul (16|M0)              acc2.0<1>:f   r21.0<0;1,0>:f    r88.0<1;1,0>:f   {Compacted}
        mul (16|M16)             r98.0<1>:f    r50.0<0;1,0>:f    r90.0<1;1,0>:f   {Compacted,F@3}
        mul (16|M16)             r24.0<1>:f    r21.0<0;1,0>:f    r90.0<1;1,0>:f   {Compacted}
        rndd (16|M0)             acc0.0<1>:f   acc0.0<1;1,0>:f                 
        rndd (16|M0)             acc2.0<1>:f   acc2.0<1;1,0>:f                 
        mad (16|M0)              r92.0<1>:f    r64.0<1;0>:f      r88.0<1;0>:f      -r6.0<0>:f       {Compacted}
        rndd (16|M16)            r102.0<1>:f   r98.0<1;1,0>:f                   {Compacted,F@5}
        rndd (16|M16)            r28.0<1>:f    r24.0<1;1,0>:f                   {Compacted,F@5}
        mad (16|M0)              r3.0<1>:f     r68.0<1;0>:f      acc0.0<1;0>:f     r63.0<0>:f       {Compacted}
        mad (16|M0)              r30.0<1>:f    -acc2.0<1;0>:f    r88.0<1;0>:f      r21.0<0>:f      
        mad (16|M16)             r94.0<1>:f    r66.0<1;0>:f      r90.0<1;0>:f      -r6.0<0>:f       {Compacted}
        mad (16|M0)              r104.0<1>:f   -acc0.0<1;0>:f    r88.0<1;0>:f      r50.0<0>:f      
        mad (16|M0)              r34.0<1>:f    r92.0<1;0>:f      acc2.0<1;0>:f     r63.0<0>:f       {Compacted,F@7}
        mad (16|M16)             r13.0<1>:f    r70.0<1;0>:f      r102.0<1;0>:f     r63.0<0>:f       {Compacted,F@7}
        mad (16|M16)             r32.0<1>:f    -r28.0<1;0>:f     r90.0<1;0>:f      r21.0<0>:f       {Compacted,F@7}
        mad (16|M0)              r43.0<1>:f    r3.0<1;0>:f       r30.0<1;0>:f      -r12.0<0>:f      {Compacted,F@6}
        mad (16|M16)             r106.0<1>:f   -r102.0<1;0>:f    r90.0<1;0>:f      r50.0<0>:f       {Compacted}
        mad (16|M16)             r41.0<1>:f    r94.0<1;0>:f      r28.0<1;0>:f      r63.0<0>:f       {Compacted,F@7}
        mad (16|M0)              r15.0<1>:f    r76.0<1;0>:f      r104.0<1;0>:f     -r12.0<0>:f      {Compacted,F@7}
        mad (16|M16)             r45.0<1>:f    r13.0<1;0>:f      r32.0<1;0>:f      -r12.0<0>:f      {Compacted,F@5}
        mad (16|M0)              acc2.0<1>:f   r43.0<1;0>:f      r34.0<1;0>:f      r12.0<0>:f       {Compacted,F@5}
        mad (16|M16)             acc0.0<1>:f   r78.0<1;0>:f      r106.0<1;0>:f     -r12.0<0>:f      {F@5}
        mad (16|M16)             r57.0<1>:f    r45.0<1;0>:f      r41.0<1;0>:f      r12.0<0>:f       {Compacted,F@3}
        mad (16|M0)              acc2.0<1>:f   r15.0<1;0>:f      acc2.0<1;0>:f     r12.0<0>:f       {Compacted}
        mad (16|M16)             r61.0<1>:f    acc0.0<1;0>:f     r57.0<1;0>:f      r12.0<0>:f       {Compacted,F@2}
        mul (16|M0)              acc2.0<1>:f   r18.0<0;1,0>:f    acc2.0<1;1,0>:f 
        mul (16|M16)             r61.0<1>:f    r18.0<0;1,0>:f    r61.0<1;1,0>:f   {Compacted,F@2}
        rndd (16|M0)             r63.0<1>:f    acc2.0<1;1,0>:f                  {Compacted}
        rndd (16|M16)            r65.0<1>:f    r61.0<1;1,0>:f                   {Compacted,F@2}
        mad (16|M0)              acc2.0<1>:f   r34.0<1;0>:f      -r63.0<1;0>:f     r6.0<0>:f        {Compacted,F@2}
        mad (16|M0)              r75.0<1>:f    r15.0<1;0>:f      -r63.0<1;0>:f     r11.0<0>:f       {Compacted}
        mad (16|M16)             r77.0<1>:f    acc0.0<1;0>:f     -r65.0<1;0>:f     r11.0<0>:f       {F@3}
        mul (16|M0)              r10.0<1>:f    acc2.0<1;1,0>:f   0x2F800000:f               {Compacted}
(W)     mov (1|M0)               r18.0<1>:ud   0xCF800000:ud                             
        mad (16|M16)             acc0.0<1>:f   r41.0<1;0>:f      -r65.0<1;0>:f     r6.0<0>:f       
        rndz (16|M0)             r14.0<1>:f    r10.0<1;1,0>:f                   {Compacted,F@2}
        mul (16|M16)             r12.0<1>:f    acc0.0<1;1,0>:f   0x2F800000:f               {Compacted}
        mad (16|M0)              r19.0<1>:f    acc2.0<1;0>:f     r14.0<1;0>:f      r18.0<0>:f       {Compacted,A@1}
        mov (16|M16)             r53.0<1>:d    r90.0<1;1,0>:f                   {Compacted}
        rndz (16|M16)            acc2.0<1>:f   r12.0<1;1,0>:f                   {F@2}
        mov (16|M0)              r23.0<1>:ud   r19.0<1;1,0>:f                   {F@2}
        mov (16|M0)              r91.0<1>:d    r75.0<1;1,0>:f                   {Compacted}
        mad (16|M0)              r71.0<1>:f    r43.0<1;0>:f      -r63.0<1;0>:f     r9.4<0>:f        {Compacted}
        mad (16|M16)             r21.0<1>:f    acc0.0<1;0>:f     acc2.0<1;0>:f     r18.0<0>:f      
        shl (16|M0)              r23.0<1>:d    r23.0<1;1,0>:d    8:w               {Compacted,I@2}
        asr (16|M0)              r3.0<1>:d     r91.0<1;1,0>:d    31:w               {Compacted,I@2}
        addc (8|M0)              r27.0<1>:ud   r91.0<1;1,0>:ud   0x0:ud              {AccWrEn,Compacted,F@1}
        mov (16|M0)              r51.0<1>:d    r88.0<1;1,0>:f                   {Compacted}
        mov (16|M16)             r93.0<1>:d    r77.0<1;1,0>:f                   {Compacted}
        mov (16|M16)             r25.0<1>:ud   r21.0<1;1,0>:f                  
        add3 (8|M0)              r29.0<1>:ud   acc0.0<1;0>:ud    r23.0<1;0>:ud     r3.0<1>:ud       {I@5}
        mov (16|M0)              r87.0<1>:d    r71.0<1;1,0>:f                   {Compacted}
        addc (8|M8)              r28.0<1>:ud   r92.0<1;1,0>:ud   0x0:ud              {AccWrEn}
        mad (16|M16)             r73.0<1>:f    r45.0<1;0>:f      -r65.0<1;0>:f     r9.4<0>:f        {Compacted}
        asr (16|M16)             r5.0<1>:d     r93.0<1;1,0>:d    31:w               {Compacted,I@5}
        shl (16|M16)             r25.0<1>:d    r25.0<1;1,0>:d    8:w               {Compacted,I@5}
        asr (16|M0)              r95.0<1>:d    r87.0<1;1,0>:d    31:w               {Compacted,I@4}
        add3 (8|M8)              r30.0<1>:ud   acc0.0<1;0>:ud    r24.0<1;0>:ud     r4.0<1>:ud      
        addc (8|M16)             r31.0<1>:ud   r93.0<1;1,0>:ud   0x0:ud              {AccWrEn}
        shl (16|M0)              r99.0<1>:d    r87.0<1;1,0>:d    20:w               {Compacted}
        mov (16|M16)             r89.0<1>:d    r73.0<1;1,0>:f                   {Compacted,F@1}
        shl (16|M0)              r95.0<1>:d    r95.0<1;1,0>:d    20:w               {Compacted,I@5}
        add3 (8|M16)             r33.0<1>:ud   acc0.0<1;0>:ud    r25.0<1;0>:ud     r5.0<1>:ud      
        shr (16|M0)              r87.0<1>:ud   r87.0<1;1,0>:ud   12:w              
        addc (8|M24)             r32.0<1>:ud   r94.0<1;1,0>:ud   0x0:ud              {AccWrEn}
        asr (16|M16)             r97.0<1>:d    r89.0<1;1,0>:d    31:w               {Compacted,I@5}
        or (16|M0)               r103.0<1>:d   r95.0<1;1,0>:d    r87.0<1;1,0>:d   {Compacted,I@3}
        add3 (8|M24)             r34.0<1>:ud   acc0.0<1;0>:ud    r26.0<1;0>:ud     r6.0<1>:ud      
        addc (8|M0)              r35.0<1>:ud   r27.0<1;1,0>:ud   r99.0<1;1,0>:ud  {AccWrEn,Compacted}
        mov (16|M0)              r47.0<1>:d    r37.0<1;1,0>:f                   {Compacted}
        shl (16|M16)             r101.0<1>:d   r89.0<1;1,0>:d    20:w               {Compacted}
        shl (16|M16)             r97.0<1>:d    r97.0<1;1,0>:d    20:w               {Compacted,I@6}
        add3 (8|M0)              r37.0<1>:ud   acc0.0<1;0>:ud    r29.0<1;0>:ud     r103.0<1>:ud     {I@6}
        shr (16|M16)             r89.0<1>:ud   r89.0<1;1,0>:ud   12:w              
        addc (8|M8)              r36.0<1>:ud   r28.0<1;1,0>:ud   r100.0<1;1,0>:ud {AccWrEn}
        mov (16|M16)             r49.0<1>:d    r39.0<1;1,0>:f                   {Compacted}
        or (16|M16)              r105.0<1>:d   r97.0<1;1,0>:d    r89.0<1;1,0>:d   {Compacted,I@3}
        add3 (8|M8)              r38.0<1>:ud   acc0.0<1;0>:ud    r30.0<1;0>:ud     r104.0<1>:ud    
        addc (8|M16)             r39.0<1>:ud   r31.0<1;1,0>:ud   r101.0<1;1,0>:ud {AccWrEn}
        cmp (16|M0)   (ge)f0.0   null<1>:d     r35.0<1;1,0>:ud   r8.2<0;1,0>:ud   {I@5}
        add3 (8|M16)             r41.0<1>:ud   acc0.0<1;0>:ud    r33.0<1;0>:ud     r105.0<1>:ud     {I@4}
        addc (8|M24)             r40.0<1>:ud   r32.0<1;1,0>:ud   r102.0<1;1,0>:ud {AccWrEn}
(f0.0)  cmp (16|M0)   (eq)f0.0   null<1>:d     r37.0<1;1,0>:d    r2.0<0;1,0>:d    {I@5}
        cmp (16|M16)  (ge)f0.0   null<1>:d     r39.0<1;1,0>:ud   r8.2<0;1,0>:ud   {I@2}
        add3 (8|M24)             r42.0<1>:ud   acc0.0<1;0>:ud    r34.0<1;0>:ud     r106.0<1>:ud    
(~f0.0) cmp (16|M0)   (gt)f0.0   null<1>:d     r37.0<1;1,0>:ud   r2.0<0;1,0>:ud  
(f0.0)  cmp (16|M16)  (eq)f0.0   null<1>:d     r41.0<1;1,0>:d    r2.0<0;1,0>:d    {I@2}
        mov (16|M0)              r79.0<1>:d    r63.0<1;1,0>:f                   {Compacted}
(~f0.0) cmp (16|M16)  (gt)f0.0   null<1>:d     r41.0<1;1,0>:ud   r2.0<0;1,0>:ud  
        mov (16|M16)             r81.0<1>:d    r65.0<1;1,0>:f                   {Compacted}
        shl (16|M0)              r43.0<1>:d    r47.0<1;1,0>:d    20:w               {Compacted}
(W)     mov (1|M0)               r47.0<1>:w    -1:w                              
        shl (16|M16)             r45.0<1>:d    r49.0<1;1,0>:d    20:w               {Compacted}
        add (16|M0)              r83.0<1>:d    r79.0<1;1,0>:d    r51.0<1;1,0>:d   {Compacted,I@6}
        add (16|M16)             r85.0<1>:d    r81.0<1;1,0>:d    r53.0<1;1,0>:d   {Compacted,I@5}
(f0.0)  sel (16|M0)              r48.0<1>:d    r47.0<0;1,0>:w    0:w               {I@4}
(f0.0)  sel (16|M16)             r50.0<1>:d    r47.0<0;1,0>:w    0:w              
        add3 (16|M0)             r117.0<1>:d   r43.0<1;0>:d      r83.0<1;0>:d      -r48.0<1>:d      {I@2}
        add3 (16|M16)            r119.0<1>:d   r45.0<1;0>:d      r85.0<1;0>:d      -r50.0<1>:d      {I@2}
        goto (32|M0)                         L2304                  L3016                
L2304:
        join (32|M0)                         L3016                                
L2320:
(W)     cmp (16|M0)   (eq)f0.0   null<1>:d     r8.2<0;1,0>:d     0:w               {Compacted}
(W)     cmp (16|M16)  (eq)f0.0   null<1>:d     r8.2<0;1,0>:d     0:w              
(f0.0)  goto (32|M0)                         L2968                  L2968                
L2360:
(W)     xor (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x30:uw              {A@1}
(W)     mov (1|M0)               r2.0<1>:f     r8.2<0;1,0>:ud                   {Compacted,A@1}
(W)     mov (1|M0)               r13.0<1>:f    0xB4C00000:f                               {Compacted}
(W)     math.inv (1|M0)          r12.0<1>:f    r2.0<0;1,0>:f                    {@2,$4}
        mov (16|M0)              r5.0<1>:f     r113.0<1;1,0>:ud                 {Compacted,$1.dst}
        sync.nop                             null                             {Compacted,$4.dst}
(W)     mad (1|M0)               r14.0<1>:f    r12.0<0;0>:f      r13.0<0;0>:f      r12.0<0>:f       {Compacted,F@2}
        mov (16|M16)             r10.0<1>:f    r115.0<1;1,0>:ud                 {Compacted}
(W)     mov (1|M0)               r3.0<1>:ud    r2.0<0;1,0>:f                   
        mov (16|M0)              r19.0<1>:ud   r5.0<1;1,0>:f                    {F@3}
        mul (16|M0)              r15.0<1>:f    r5.0<1;1,0>:f     r14.0<0;1,0>:f   {Compacted,F@2}
        mul (16|M16)             r17.0<1>:f    r10.0<1;1,0>:f    r14.0<0;1,0>:f   {Compacted,F@2}
        mov (16|M16)             r21.0<1>:ud   r10.0<1;1,0>:f                  
(W)     add (1|M0)               r4.0<1>:d     r8.2<0;1,0>:d     -r3.0<0;1,0>:d   {Compacted,I@3}
        add (16|M0)              r19.0<1>:d    r113.0<1;1,0>:d   -r19.0<1;1,0>:d  {Compacted,I@3}
        mov (16|M0)              r23.0<1>:ud   r15.0<1;1,0>:f                   {F@2}
        mov (16|M16)             r25.0<1>:ud   r17.0<1;1,0>:f                   {F@1}
        add (16|M16)             r21.0<1>:d    r115.0<1;1,0>:d   -r21.0<1;1,0>:d  {Compacted,I@5}
(W)     mov (1|M0)               r27.0<1>:f    r4.0<0;1,0>:ud                   {Compacted,I@5}
        mov (16|M0)              r28.0<1>:f    r19.0<1;1,0>:ud                  {Compacted,I@4}
        mov (16|M0)              r32.0<1>:f    r23.0<1;1,0>:ud                  {Compacted,I@3}
        mov (16|M16)             r34.0<1>:f    r25.0<1;1,0>:ud                  {Compacted,I@2}
        mov (16|M16)             r30.0<1>:f    r21.0<1;1,0>:ud                  {Compacted,I@1}
        mad (16|M0)              r36.0<1>:f    r5.0<1;0>:f       r32.0<1;0>:f      -r2.0<0>:f       {Compacted,F@3}
        mad (16|M0)              r40.0<1>:f    r28.0<1;0>:f      r32.0<1;0>:f      -r27.0<0>:f      {Compacted}
        mad (16|M16)             r38.0<1>:f    r10.0<1;0>:f      r34.0<1;0>:f      -r2.0<0>:f       {Compacted,F@4}
        mad (16|M16)             acc2.0<1>:f   r30.0<1;0>:f      r34.0<1;0>:f      -r27.0<0>:f      {F@4}
        add (16|M0)              acc0.0<1>:f   r36.0<1;1,0>:f    r40.0<1;1,0>:f   {Compacted,F@3}
        add (16|M16)             r46.0<1>:f    r38.0<1;1,0>:f    acc2.0<1;1,0>:f  {F@3}
        mul (16|M0)              r48.0<1>:f    r14.0<0;1,0>:f    acc0.0<1;1,0>:f 
(W)     xor (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x30:uw              {A@1}
(W)     xor (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x30:uw              {A@1}
        mul (16|M16)             r50.0<1>:f    r14.0<0;1,0>:f    r46.0<1;1,0>:f   {Compacted,A@1}
(W)     xor (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x30:uw              {A@1}
        mov (16|M0)              r52.0<1>:ud   r48.0<1;1,0>:f                   {A@1}
        mov (16|M16)             r54.0<1>:ud   r50.0<1;1,0>:f                   {F@1}
        add (16|M0)              r56.0<1>:d    r52.0<1;1,0>:d    r23.0<1;1,0>:d   {Compacted,I@2}
        add (16|M16)             r58.0<1>:d    r54.0<1;1,0>:d    r25.0<1;1,0>:d   {Compacted,I@2}
(W)     mul (8|M0)               acc0.0<1>:d   r56.0<1;1,0>:d    r8.4<0;1,0>:uw   {Compacted,I@2}
        mach (8|M0)              r56.0<1>:d    r56.0<1;1,0>:d    r8.2<0;1,0>:d    {Compacted}
(W)     mul (8|M8)               acc0.0<1>:d   r57.0<1;1,0>:d    r8.4<0;1,0>:uw  
        mach (8|M8)              r57.0<1>:d    r57.0<1;1,0>:d    r8.2<0;1,0>:d    {Compacted}
(W)     mul (8|M16)              acc0.0<1>:d   r58.0<1;1,0>:d    r8.4<0;1,0>:uw   {I@5}
        mach (8|M16)             r58.0<1>:d    r58.0<1;1,0>:d    r8.2<0;1,0>:d    {Compacted}
(W)     mul (8|M24)              acc0.0<1>:d   r59.0<1;1,0>:d    r8.4<0;1,0>:uw  
        mach (8|M24)             r59.0<1>:d    r59.0<1;1,0>:d    r8.2<0;1,0>:d    {Compacted}
        add (16|M0)              r56.0<1>:d    r113.0<1;1,0>:d   -r56.0<1;1,0>:d  {Compacted,I@5}
        add (16|M16)             r58.0<1>:d    r115.0<1;1,0>:d   -r58.0<1;1,0>:d  {Compacted,I@2}
        cmp (16|M0)   (ge)f1.0   r60.0<1>:ud   r56.0<1;1,0>:ud   r8.2<0;1,0>:ud   {I@2}
        cmp (16|M16)  (ge)f0.0   r62.0<1>:ud   r58.0<1;1,0>:ud   r8.2<0;1,0>:ud   {I@2}
        add3 (16|M0)             r117.0<1>:d   r52.0<1;0>:d      r23.0<1;0>:d      -r60.0<1>:d      {I@2}
        add3 (16|M16)            r119.0<1>:d   r54.0<1;0>:d      r25.0<1;0>:d      -r62.0<1>:d      {I@2}
        goto (32|M0)                         L2968                  L3016                
L2968:
        join (32|M0)                         L3016                                
L2984:
        mov (16|M0)              r117.0<1>:d   -1:w                              
        mov (16|M16)             r119.0<1>:d   -1:w                              
L3016:
        join (32|M0)                         L3032                                
L3032:
        shr (16|M0)              r2.0<1>:ud    r109.0<1;1,0>:ud  5:w              
        shr (16|M16)             r4.0<1>:ud    r111.0<1;1,0>:ud  5:w               {$1.dst}
        shl (16|M0)              r6.0<1>:d     r117.0<1;1,0>:d   5:w               {Compacted,I@5}
        shl (16|M16)             r10.0<1>:d    r119.0<1;1,0>:d   5:w               {Compacted,I@5}
(W)     mov (1|M0)               r12.0<1>:d    31:w                              
        bfn.0xEA (16|M0)         r121.0<1>:ud  r6.0<1;0>:ud      r2.0<1;0>:ud      r12.0<0>:ud      {I@1} // s0|s1&s2
        bfn.0xEA (16|M16)        r123.0<1>:ud  r10.0<1;0>:ud     r4.0<1;0>:ud      r12.0<0>:ud      // s0|s1&s2
        cmp (16|M0)   (lt)f1.0   null<1>:d     r121.0<1;1,0>:d   r8.3<0;1,0>:d    {I@2}
        cmp (16|M16)  (lt)f1.0   null<1>:d     r123.0<1;1,0>:d   r8.3<0;1,0>:d    {I@2}
(~f1.0) goto (32|M0)                         L3544                  L3544                
L3176:
(W)     mul (8|M0)               acc0.0<1>:d   r121.0<1;1,0>:d   r8.8<0;1,0>:uw   {Compacted}
        mach (8|M0)              r2.0<1>:d     r121.0<1;1,0>:d   r8.4<0;1,0>:d    {Compacted}
(W)     mul (8|M8)               acc0.0<1>:d   r122.0<1;1,0>:d   r8.8<0;1,0>:uw  
        mach (8|M8)              r3.0<1>:d     r122.0<1;1,0>:d   r8.4<0;1,0>:d    {Compacted}
(W)     mul (8|M16)              acc0.0<1>:d   r123.0<1;1,0>:d   r8.8<0;1,0>:uw  
        mach (8|M16)             r4.0<1>:d     r123.0<1;1,0>:d   r8.4<0;1,0>:d    {Compacted}
(W)     mul (8|M24)              acc0.0<1>:d   r124.0<1;1,0>:d   r8.8<0;1,0>:uw  
        mach (8|M24)             r5.0<1>:d     r124.0<1;1,0>:d   r8.4<0;1,0>:d    {Compacted}
(W)     mul (8|M0)               acc0.0<1>:d   r117.0<1;1,0>:d   r8.4<0;1,0>:uw   {Compacted}
        mach (8|M0)              r6.0<1>:d     r117.0<1;1,0>:d   r8.2<0;1,0>:d    {Compacted}
(W)     mul (8|M8)               acc0.0<1>:d   r118.0<1;1,0>:d   r8.4<0;1,0>:uw  
        mach (8|M8)              r7.0<1>:d     r118.0<1;1,0>:d   r8.2<0;1,0>:d    {Compacted}
(W)     mul (8|M16)              acc0.0<1>:d   r119.0<1;1,0>:d   r8.4<0;1,0>:uw  
        mach (8|M16)             r10.0<1>:d    r119.0<1;1,0>:d   r8.2<0;1,0>:d    {Compacted}
(W)     mul (8|M24)              acc0.0<1>:d   r120.0<1;1,0>:d   r8.4<0;1,0>:uw  
        mach (8|M24)             r11.0<1>:d    r120.0<1;1,0>:d   r8.2<0;1,0>:d    {Compacted}
        add (16|M0)              r6.0<1>:d     r113.0<1;1,0>:d   -r6.0<1;1,0>:d   {Compacted,I@5}
        add (16|M16)             r10.0<1>:d    r115.0<1;1,0>:d   -r10.0<1;1,0>:d  {Compacted,I@2}
        and (16|M0)              r12.0<1>:d    r109.0<1;1,0>:d   31:w               {Compacted}
        and (16|M16)             r14.0<1>:d    r111.0<1;1,0>:d   31:w               {Compacted}
(W)     mov (1|M0)               a0.0<1>:ud    r9.3<0;1,0>:d                    {A@1}
        add (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     r9.1<0;1,0>:d    {Compacted}
        add (16|M16)             r4.0<1>:d     r4.0<1;1,0>:d     r9.1<0;1,0>:d    {Compacted}
        shl (16|M0)              r6.0<1>:d     r6.0<1;1,0>:d     5:w               {Compacted,I@7}
        shl (16|M16)             r10.0<1>:d    r10.0<1;1,0>:d    5:w               {Compacted,I@7}
        add3 (16|M0)             r16.0<1>:d    r2.0<1;0>:d       r6.0<1;0>:d       r12.0<1>:d       {I@2}
        add3 (16|M16)            r18.0<1>:d    r4.0<1;0>:d       r10.0<1;0>:d      r14.0<1>:d       {I@2}
        send.ugm (16|M0)         r20      r16     null:0  a0.0        0x24280900           {ExBSO,A@2,$5} // wr:2+0, rd:2; load.ugm.d8u32.a32.ca.ca.bss[a0.0]
        send.ugm (16|M16)        r22      r18     null:0  a0.0        0x24280900           {ExBSO,A@1,$6} // wr:2+0, rd:2; load.ugm.d8u32.a32.ca.ca.bss[a0.0]
        mov (16|M0)              r125.0<1>:b   r20.0<4;1,0>:b                   {$5.dst}
        mov (16|M16)             r126.0<1>:b   r22.0<4;1,0>:b                   {$6.dst}
        goto (32|M0)                         L3544                  L3608                
L3544:
        join (32|M0)                         L3608                                
L3560:
(W)     mov (1|M0)               r2.0<2>:b     0:w                              
        mov (16|M0)              r125.0<1>:b   r2.0<0;1,0>:b                    {I@1}
        mov (16|M16)             r126.0<1>:b   r2.0<0;1,0>:b                   
L3608:
        join (32|M0)                         L3624                                
L3624:
(W)     mov (1|M0)               a0.0<1>:ud    r9.2<0;1,0>:d                    {A@1}
        add (16|M0)              r2.0<1>:d     r109.0<1;1,0>:d   r9.0<0;1,0>:d    {Compacted}
        add (16|M16)             r4.0<1>:d     r111.0<1;1,0>:d   r9.0<0;1,0>:d    {Compacted}
        mov (16|M0)              r6.0<1>:ud    r125.0<1;1,0>:ub                 {I@6}
        mov (16|M16)             r8.0<1>:ud    r126.0<1;1,0>:ub                 {I@6}
(W)     mov (8|M0)               r127.0<1>:f   r108.0<1;1,0>:f                  {Compacted}
        send.ugm (16|M0)         null     r2      r6:2    a0.0        0x240E0904           {ExBSO,A@2,$7} // wr:2+2, rd:0; store.ugm.d8u32.a32.wb.wb.bss[a0.0]
        sync.nop                             null                             {Compacted,I@1}
        send.ugm (16|M16)        null     r4      r8:2    a0.0        0x240E0904           {ExBSO,$8} // wr:2+2, rd:0; store.ugm.d8u32.a32.wb.wb.bss[a0.0]
(W)     send.gtwy (1|M0)         null     r127    null:0  0x0            0x02000010           {EOT,A@1} // wr:1+0, rd:0; end of thread
L3752:
        nop                    
(W)     mov (16|M0)              null<1>:ud    0x6F9278B:ud                             
(W)     mov (16|M0)              null<1>:ud    0x6180031B:ud                             
(W)     mov (16|M0)              null<1>:ud    0x0:ud                             
(W)     mov (16|M0)              null<1>:ud    0x6:ud                             
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
