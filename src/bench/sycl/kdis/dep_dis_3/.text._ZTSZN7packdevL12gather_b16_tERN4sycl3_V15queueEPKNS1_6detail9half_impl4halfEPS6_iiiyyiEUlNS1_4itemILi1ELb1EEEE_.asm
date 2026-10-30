L0:
(W)     mov (8|M0)               r127.0<1>:ud  0x0:ud                             
(W)     and (1|M0)               r127.2<1>:ud  r0.0<0;1,0>:ud    0xFFFFFFC0:ud             
(W)     and (1|M0)               r127.0<1>:uw  r0.4<0;1,0>:uw    0xFF:uw             
(W)     add (1|M0)               r127.2<1>:ud  r127.2<0;1,0>:ud  0x60:ud              {I@2}
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
(W)     add (1|M0)               r127.2<1>:ud  r127.2<0;1,0>:ud  0x40:uw              {$2.src}
(W)     send.dc0 (8|M0)          r10      r127    null:0  0x0            0x021842FD           {A@1,$3} // wr:1h+0, rd:1; oword aligned block read x2
(W)     mov (8|M0)               r116.0<1>:ud  r0.0<1;1,0>:ud                  
(W)     or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x4C0:uw              {A@1}
        sync.nop                             null                             {Compacted,A@1}
        sync.nop                             null                             {Compacted,$2.dst}
(W)     cmp (16|M0)   (gt)f0.0   null<1>:d     r8.2<0;1,0>:d     -1:w               {A@1}
(W)     cmp (16|M16)  (gt)f0.0   null<1>:d     r8.2<0;1,0>:d     -1:w              
(W)     mul (1|M0)               acc0.0<1>:d   r7.3<0;1,0>:d     r116.2<0;1,0>:uw {I@4}
(W)     mach (1|M0)              r3.0<1>:d     r7.3<0;1,0>:d     r116.1<0;1,0>:d  {$0.dst}
(W)     mov (1|M0)               r117.0<1>:d   r8.4<0;1,0>:d                   
(W)     mov (1|M0)               r117.1<1>:d   r9.0<0;1,0>:d                   
        add3 (16|M0)             r118.0<1>:d   r3.0<0;0>:d       r1.0<1;0>:uw      r7.0<0>:d        {I@3}
        add3 (16|M16)            r120.0<1>:d   r3.0<0;0>:d       r2.0<1;0>:uw      r7.0<0>:d       
(f0.0)  goto (32|M0)                         L2400                  L2400                
L480:
(W)     shr (1|M0)               r3.0<1>:ud    r8.2<0;1,0>:ud    20:w              
(W)     asr (1|M0)               r4.0<1>:d     r8.2<0;1,0>:d     20:w               {Compacted}
(W)     mov (1|M0)               r7.0<1>:d     1044480:d                              
(W)     asr (1|M0)               r2.0<1>:d     r8.2<0;1,0>:d     31:w               {Compacted}
(W)     and (1|M0)               r10.2<1>:d    r8.2<0;1,0>:d     1048575:d               {$3.dst}
(W)     bfn.0xF8 (1|M0)          r8.0<1>:ud    r4.0<0;0>:ud      r7.0<0;0>:d       r3.0<0>:ud       {I@3} // s0&s1|s2
(W)     mov (1|M0)               r12.0<1>:ud   0x49800000:ud                             
        sync.nop                             null                             {Compacted,$1.dst}
(W)     shr (1|M0)               r5.0<1>:ud    r2.0<0;1,0>:ud    8:w               {I@4}
(W)     mov (1|M0)               r11.0<1>:f    r10.2<0;1,0>:ud                  {Compacted,I@4}
(W)     mov (1|M0)               r9.0<1>:f     r8.0<0;1,0>:ud                   {Compacted,I@3}
(W)     mov (1|M0)               r14.0<1>:ud   0x53800000:ud                             
(W)     mov (1|M0)               r6.0<1>:f     r5.0<0;1,0>:ud                   {Compacted,I@2}
(W)     mad (1|M0)               r13.0<1>:f    r11.0<0;0>:f      r12.0<0;0>:f      r9.0<0>:f        {Compacted,F@2}
(W)     mov (1|M0)               r17.0<1>:ud   0xB4E00000:ud                             
(W)     mad (1|M0)               r15.0<1>:f    r13.0<0;0>:f      r14.0<0;0>:f      r6.0<0>:f        {Compacted,A@1}
(W)     mov (1|M0)               r21.0<1>:ud   0x0:ud                             
        sync.nop                             null                             {Compacted,F@1}
(W)     math.inv (1|M0)          r16.0<1>:f    r15.0<0;1,0>:f                   {$4}
        sync.nop                             null                             {Compacted,$4.dst}
(W)     mad (1|M0)               r18.0<1>:f    r16.0<0;0>:f      r17.0<0;0>:f      r16.0<0>:f       {Compacted,I@2}
        shr (16|M0)              r25.0<1>:ud   r118.0<1;1,0>:ud  20:w              
(W)     mul (1|M0)               r19.0<1>:f    r18.0<0;1,0>:f    0.0:f               {Compacted,F@1}
(W)     mul (1|M0)               r23.0<1>:f    r9.0<0;1,0>:f     -1.048576e+06:f               {Compacted}
(W)     rndd (1|M0)              r20.0<1>:f    r19.0<0;1,0>:f                   {Compacted,F@2}
        mov (16|M0)              r29.0<1>:f    r25.0<1;1,0>:ud                  {Compacted,I@1}
(W)     mad (1|M0)               r22.0<1>:f    r21.0<0;0>:f      r20.0<0;0>:f      -r11.0<0>:f      {Compacted,F@2}
        shr (16|M16)             r27.0<1>:ud   r120.0<1;1,0>:ud  20:w              
(W)     mad (1|M0)               r24.0<1>:f    r22.0<0;0>:f      r20.0<0;0>:f      r23.0<0>:f       {Compacted,F@1}
        mov (16|M16)             r31.0<1>:f    r27.0<1;1,0>:ud                  {Compacted,I@1}
        mad (16|M0)              acc0.0<1>:f   r29.0<1;0>:f      r12.0<0;0>:f      r24.0<0>:f       {Compacted,F@2}
        mul (16|M0)              acc0.0<1>:f   r18.0<0;1,0>:f    acc0.0<1;1,0>:f 
(W)     mul (1|M0)               r50.0<1>:f    r11.0<0;1,0>:f    9.536743e-07:f               {Compacted}
        mad (16|M16)             acc2.0<1>:f   r31.0<1;0>:f      r12.0<0;0>:f      r24.0<0>:f       {F@4}
        rndd (16|M0)             r37.0<1>:f    acc0.0<1;1,0>:f                  {Compacted}
        mul (16|M16)             acc0.0<1>:f   r18.0<0;1,0>:f    acc2.0<1;1,0>:f 
        mul (16|M0)              acc2.0<1>:f   r50.0<0;1,0>:f    r37.0<1;1,0>:f   {Compacted,F@2}
        rndd (16|M16)            r39.0<1>:f    acc0.0<1;1,0>:f                  {Compacted}
        rndd (16|M0)             acc0.0<1>:f   acc2.0<1;1,0>:f                 
        and (16|M0)              r72.0<1>:d    r118.0<1;1,0>:d   1048575:d              
(W)     mul (1|M0)               r45.0<1>:f    r6.0<0;1,0>:f     -1.048576e+06:f               {Compacted}
        mad (16|M0)              acc2.0<1>:f   r24.0<0;0>:f      r37.0<1;0>:f      -r9.0<0>:f       {Compacted}
        mul (16|M16)             r53.0<1>:f    r50.0<0;1,0>:f    r39.0<1;1,0>:f   {Compacted,F@4}
        mad (16|M0)              r59.0<1>:f    -acc0.0<1;0>:f    r37.0<1;0>:f      r50.0<0>:f      
(W)     mov (1|M0)               r63.0<1>:ud   0xBF800000:ud                             
        mov (16|M0)              r76.0<1>:f    r72.0<1;1,0>:ud                  {Compacted,I@2}
        mad (16|M0)              r46.0<1>:f    acc2.0<1;0>:f     r37.0<1;0>:f      r45.0<0>:f       {Compacted,F@5}
        rndd (16|M16)            acc2.0<1>:f   r53.0<1;1,0>:f                   {F@4}
        mad (16|M0)              r68.0<1>:f    r29.0<1;0>:f      r59.0<1;0>:f      -r12.0<0>:f      {Compacted,F@4}
        and (16|M16)             r74.0<1>:d    r120.0<1;1,0>:d   1048575:d              
        mad (16|M16)             r43.0<1>:f    r24.0<0;0>:f      r39.0<1;0>:f      -r9.0<0>:f       {Compacted}
        mad (16|M0)              r64.0<1>:f    r46.0<1;0>:f      acc0.0<1;0>:f     r63.0<0>:f       {Compacted,A@2}
        mad (16|M16)             acc0.0<1>:f   -acc2.0<1;0>:f    r39.0<1;0>:f      r50.0<0>:f      
        mad (16|M0)              r80.0<1>:f    r76.0<1;0>:f      r68.0<1;0>:f      r12.0<0>:f       {Compacted,F@4}
        mov (16|M16)             r78.0<1>:f    r74.0<1;1,0>:ud                  {Compacted,I@1}
        mad (16|M16)             r48.0<1>:f    r43.0<1;0>:f      r39.0<1;0>:f      r45.0<0>:f       {Compacted,F@5}
        mad (16|M16)             r70.0<1>:f    r31.0<1;0>:f      acc0.0<1;0>:f     -r12.0<0>:f     
        mad (16|M0)              acc0.0<1>:f   r80.0<1;0>:f      r64.0<1;0>:f      r14.0<0>:f       {Compacted,F@4}
        mad (16|M16)             r66.0<1>:f    r48.0<1;0>:f      acc2.0<1;0>:f     r63.0<0>:f       {Compacted,F@3}
        mad (16|M16)             acc2.0<1>:f   r78.0<1;0>:f      r70.0<1;0>:f      r12.0<0>:f       {F@3}
        mul (16|M0)              acc0.0<1>:f   r18.0<0;1,0>:f    acc0.0<1;1,0>:f 
(W)     mul (1|M0)               r2.1<1>:f     r9.0<0;1,0>:f     9.536743e-07:f               {Compacted}
        mad (16|M16)             acc2.0<1>:f   acc2.0<1;0>:f     r66.0<1;0>:f      r14.0<0>:f       {F@4}
        rndd (16|M0)             r88.0<1>:f    acc0.0<1;1,0>:f                  {Compacted}
        mul (16|M16)             acc2.0<1>:f   r18.0<0;1,0>:f    acc2.0<1;1,0>:f 
        mul (16|M0)              acc0.0<1>:f   r50.0<0;1,0>:f    r88.0<1;1,0>:f   {Compacted,F@2}
        mul (16|M0)              r3.0<1>:f     r2.1<0;1,0>:f     r88.0<1;1,0>:f   {Compacted}
        rndd (16|M16)            r90.0<1>:f    acc2.0<1;1,0>:f                  {Compacted}
        rndd (16|M0)             acc2.0<1>:f   acc0.0<1;1,0>:f                 
        rndd (16|M0)             acc0.0<1>:f   r3.0<1;1,0>:f                    {F@3}
        mad (16|M0)              r92.0<1>:f    r64.0<1;0>:f      r88.0<1;0>:f      -r6.0<0>:f       {Compacted}
        mul (16|M16)             r98.0<1>:f    r50.0<0;1,0>:f    r90.0<1;1,0>:f   {Compacted,F@4}
        mul (16|M16)             r13.0<1>:f    r2.1<0;1,0>:f     r90.0<1;1,0>:f   {Compacted}
        mad (16|M0)              r108.0<1>:f   r68.0<1;0>:f      acc2.0<1;0>:f     r63.0<0>:f       {Compacted}
        mad (16|M0)              r21.0<1>:f    -acc0.0<1;0>:f    r88.0<1;0>:f      r2.1<0>:f       
        mad (16|M0)              r104.0<1>:f   -acc2.0<1;0>:f    r88.0<1;0>:f      r50.0<0>:f      
        mad (16|M0)              r25.0<1>:f    r92.0<1;0>:f      acc0.0<1;0>:f     r63.0<0>:f       {Compacted,F@6}
        rndd (16|M16)            acc2.0<1>:f   r98.0<1;1,0>:f                   {F@6}
        rndd (16|M16)            acc0.0<1>:f   r13.0<1;1,0>:f                   {F@6}
        mad (16|M0)              r29.0<1>:f    r108.0<1;0>:f     r21.0<1;0>:f      -r12.0<0>:f      {Compacted,F@5}
        mad (16|M16)             r94.0<1>:f    r66.0<1;0>:f      r90.0<1;0>:f      -r6.0<0>:f       {Compacted}
        mad (16|M0)              r112.0<1>:f   r76.0<1;0>:f      r104.0<1;0>:f     -r12.0<0>:f      {Compacted,F@6}
        mad (16|M16)             r110.0<1>:f   r70.0<1;0>:f      acc2.0<1;0>:f     r63.0<0>:f       {Compacted}
        mad (16|M16)             r23.0<1>:f    -acc0.0<1;0>:f    r90.0<1;0>:f      r2.1<0>:f       
        mad (16|M0)              r41.0<1>:f    r29.0<1;0>:f      r25.0<1;0>:f      r12.0<0>:f       {Compacted,F@5}
        mad (16|M16)             r106.0<1>:f   -acc2.0<1;0>:f    r90.0<1;0>:f      r50.0<0>:f      
        mad (16|M16)             acc0.0<1>:f   r94.0<1;0>:f      acc0.0<1;0>:f     r63.0<0>:f       {F@6}
        mad (16|M16)             r31.0<1>:f    r110.0<1;0>:f     r23.0<1;0>:f      -r12.0<0>:f      {Compacted,F@4}
        mad (16|M0)              r45.0<1>:f    r112.0<1;0>:f     r41.0<1;0>:f      r12.0<0>:f       {Compacted,F@4}
        mad (16|M16)             r114.0<1>:f   r78.0<1;0>:f      r106.0<1;0>:f     -r12.0<0>:f      {Compacted,F@4}
        mad (16|M16)             acc2.0<1>:f   r31.0<1;0>:f      acc0.0<1;0>:f     r12.0<0>:f       {F@3}
        mul (16|M0)              r45.0<1>:f    r18.0<0;1,0>:f    r45.0<1;1,0>:f   {Compacted,F@3}
        mad (16|M16)             acc2.0<1>:f   r114.0<1;0>:f     acc2.0<1;0>:f     r12.0<0>:f       {F@3}
        rndd (16|M0)             r49.0<1>:f    r45.0<1;1,0>:f                   {Compacted,F@2}
        mul (16|M16)             r47.0<1>:f    r18.0<0;1,0>:f    acc2.0<1;1,0>:f 
        mad (16|M0)              acc2.0<1>:f   r25.0<1;0>:f      -r49.0<1;0>:f     r6.0<0>:f        {Compacted,F@2}
        rndd (16|M16)            r51.0<1>:f    r47.0<1;1,0>:f                   {Compacted,F@2}
        mul (16|M0)              r97.0<1>:f    acc2.0<1;1,0>:f   0x2F800000:f               {Compacted}
(W)     mov (1|M0)               r105.0<1>:ud  0xCF800000:ud                             
        mad (16|M16)             acc0.0<1>:f   acc0.0<1;0>:f     -r51.0<1;0>:f     r6.0<0>:f        {F@2}
        rndz (16|M0)             r101.0<1>:f   r97.0<1;1,0>:f                   {Compacted,F@2}
        mad (16|M0)              r61.0<1>:f    r112.0<1;0>:f     -r49.0<1;0>:f     r11.0<0>:f       {Compacted}
        mul (16|M16)             r99.0<1>:f    acc0.0<1;1,0>:f   0x2F800000:f               {Compacted}
        mad (16|M0)              r106.0<1>:f   acc2.0<1;0>:f     r101.0<1;0>:f     r105.0<0>:f      {Compacted,A@1}
        mov (16|M0)              r77.0<1>:d    r61.0<1;1,0>:f                   {Compacted,F@3}
        rndz (16|M16)            acc2.0<1>:f   r99.0<1;1,0>:f                   {F@2}
        mov (16|M0)              r110.0<1>:ud  r106.0<1;1,0>:f                  {F@2}
        mad (16|M0)              r57.0<1>:f    r29.0<1;0>:f      -r49.0<1;0>:f     r9.0<0>:f        {Compacted}
        mad (16|M16)             r63.0<1>:f    r114.0<1;0>:f     -r51.0<1;0>:f     r11.0<0>:f       {Compacted}
        asr (16|M0)              r93.0<1>:d    r77.0<1;1,0>:d    31:w               {Compacted,I@2}
        mad (16|M16)             r108.0<1>:f   acc0.0<1;0>:f     acc2.0<1;0>:f     r105.0<0>:f     
        shl (16|M0)              r110.0<1>:d   r110.0<1;1,0>:d   8:w               {Compacted,I@2}
        addc (8|M0)              r114.0<1>:ud  r77.0<1;1,0>:ud   0x0:ud              {AccWrEn,Compacted,F@1}
        mov (16|M0)              r73.0<1>:d    r57.0<1;1,0>:f                   {Compacted}
        mov (16|M16)             r79.0<1>:d    r63.0<1;1,0>:f                   {Compacted}
        mov (16|M16)             r112.0<1>:ud  r108.0<1;1,0>:f                 
        add3 (8|M0)              r3.0<1>:ud    acc0.0<1;0>:ud    r110.0<1;0>:ud    r93.0<1>:ud      {I@5}
        addc (8|M8)              r115.0<1>:ud  r78.0<1;1,0>:ud   0x0:ud              {AccWrEn}
        mad (16|M16)             r59.0<1>:f    r31.0<1;0>:f      -r51.0<1;0>:f     r9.0<0>:f        {Compacted}
        asr (16|M0)              r81.0<1>:d    r73.0<1;1,0>:d    31:w               {Compacted,I@5}
        asr (16|M16)             r95.0<1>:d    r79.0<1;1,0>:d    31:w               {Compacted,I@5}
        shl (16|M16)             r112.0<1>:d   r112.0<1;1,0>:d   8:w               {Compacted,I@5}
        add3 (8|M8)              r4.0<1>:ud    acc0.0<1;0>:ud    r111.0<1;0>:ud    r94.0<1>:ud     
        addc (8|M16)             r5.0<1>:ud    r79.0<1;1,0>:ud   0x0:ud              {AccWrEn}
        shl (16|M0)              r85.0<1>:d    r73.0<1;1,0>:d    20:w               {Compacted}
        mov (16|M16)             r75.0<1>:d    r59.0<1;1,0>:f                   {Compacted,F@1}
        shl (16|M0)              r81.0<1>:d    r81.0<1;1,0>:d    20:w               {Compacted,I@7}
        add3 (8|M16)             r11.0<1>:ud   acc0.0<1;0>:ud    r112.0<1;0>:ud    r95.0<1>:ud      {I@6}
        shr (16|M0)              r73.0<1>:ud   r73.0<1;1,0>:ud   12:w              
        addc (8|M24)             r6.0<1>:ud    r80.0<1;1,0>:ud   0x0:ud              {AccWrEn}
        mov (16|M0)              r33.0<1>:d    r37.0<1;1,0>:f                   {Compacted}
        mov (16|M16)             r35.0<1>:d    r39.0<1;1,0>:f                   {Compacted}
        asr (16|M16)             r83.0<1>:d    r75.0<1;1,0>:d    31:w               {Compacted,I@7}
        add3 (8|M24)             r12.0<1>:ud   acc0.0<1;0>:ud    r113.0<1;0>:ud    r96.0<1>:ud     
        mov (16|M0)              r37.0<1>:d    r88.0<1;1,0>:f                   {Compacted}
        mov (16|M16)             r39.0<1>:d    r90.0<1;1,0>:f                   {Compacted}
        addc (8|M0)              r13.0<1>:ud   r114.0<1;1,0>:ud  r85.0<1;1,0>:ud  {AccWrEn,Compacted}
        or (16|M0)               r89.0<1>:d    r81.0<1;1,0>:d    r73.0<1;1,0>:d   {Compacted,I@7}
        shl (16|M16)             r83.0<1>:d    r83.0<1;1,0>:d    20:w               {Compacted,I@6}
        shl (16|M16)             r87.0<1>:d    r75.0<1;1,0>:d    20:w               {Compacted}
        add3 (8|M0)              r15.0<1>:ud   acc0.0<1;0>:ud    r3.0<1;0>:ud      r89.0<1>:ud      {I@3}
        shr (16|M16)             r75.0<1>:ud   r75.0<1;1,0>:ud   12:w              
        addc (8|M8)              r14.0<1>:ud   r115.0<1;1,0>:ud  r86.0<1;1,0>:ud  {AccWrEn}
        or (16|M16)              r91.0<1>:d    r83.0<1;1,0>:d    r75.0<1;1,0>:d   {Compacted,I@2}
        add3 (8|M8)              r16.0<1>:ud   acc0.0<1;0>:ud    r4.0<1;0>:ud      r90.0<1>:ud     
        addc (8|M16)             r17.0<1>:ud   r5.0<1;1,0>:ud    r87.0<1;1,0>:ud  {AccWrEn}
        cmp (16|M0)   (ge)f0.0   null<1>:d     r13.0<1;1,0>:ud   r8.2<0;1,0>:ud   {I@4}
        add3 (8|M16)             r19.0<1>:ud   acc0.0<1;0>:ud    r11.0<1;0>:ud     r91.0<1>:ud      {I@4}
        addc (8|M24)             r18.0<1>:ud   r6.0<1;1,0>:ud    r88.0<1;1,0>:ud  {AccWrEn}
(f0.0)  cmp (16|M0)   (eq)f0.0   null<1>:d     r15.0<1;1,0>:d    r2.0<0;1,0>:d    {I@5}
        cmp (16|M16)  (ge)f0.0   null<1>:d     r17.0<1;1,0>:ud   r8.2<0;1,0>:ud   {I@2}
        add3 (8|M24)             r20.0<1>:ud   acc0.0<1;0>:ud    r12.0<1;0>:ud     r92.0<1>:ud     
(~f0.0) cmp (16|M0)   (gt)f0.0   null<1>:d     r15.0<1;1,0>:ud   r2.0<0;1,0>:ud  
(f0.0)  cmp (16|M16)  (eq)f0.0   null<1>:d     r19.0<1;1,0>:d    r2.0<0;1,0>:d    {I@2}
        mov (16|M0)              r65.0<1>:d    r49.0<1;1,0>:f                   {Compacted}
(~f0.0) cmp (16|M16)  (gt)f0.0   null<1>:d     r19.0<1;1,0>:ud   r2.0<0;1,0>:ud  
(W)     mov (1|M0)               r25.0<1>:w    -1:w                              
        mov (16|M16)             r67.0<1>:d    r51.0<1;1,0>:f                   {Compacted}
        shl (16|M0)              r21.0<1>:d    r33.0<1;1,0>:d    20:w               {Compacted}
        shl (16|M16)             r23.0<1>:d    r35.0<1;1,0>:d    20:w               {Compacted}
        add (16|M0)              r69.0<1>:d    r65.0<1;1,0>:d    r37.0<1;1,0>:d   {Compacted,I@6}
(f0.0)  sel (16|M0)              r26.0<1>:d    r25.0<0;1,0>:w    0:w               {I@5}
(f0.0)  sel (16|M16)             r28.0<1>:d    r25.0<0;1,0>:w    0:w              
        add (16|M16)             r71.0<1>:d    r67.0<1;1,0>:d    r39.0<1;1,0>:d   {Compacted,I@6}
        add3 (16|M0)             r122.0<1>:d   r21.0<1;0>:d      r69.0<1;0>:d      -r26.0<1>:d      {I@3}
        add3 (16|M16)            r124.0<1>:d   r23.0<1;0>:d      r71.0<1;0>:d      -r28.0<1>:d      {I@2}
        goto (32|M0)                         L2400                  L3112                
L2400:
        join (32|M0)                         L3112                                
L2416:
(W)     cmp (16|M0)   (eq)f1.0   null<1>:d     r8.2<0;1,0>:d     0:w              
(W)     cmp (16|M16)  (eq)f1.0   null<1>:d     r8.2<0;1,0>:d     0:w              
(f1.0)  goto (32|M0)                         L3064                  L3064                
L2464:
(W)     xor (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x30:uw              {A@1}
(W)     mov (1|M0)               r2.0<1>:f     r8.2<0;1,0>:ud                   {Compacted,A@1}
(W)     mov (1|M0)               r14.0<1>:f    0xB4C00000:f                               {Compacted}
(W)     math.inv (1|M0)          r13.0<1>:f    r2.0<0;1,0>:f                    {@2,$5}
        mov (16|M0)              r5.0<1>:f     r118.0<1;1,0>:ud                 {Compacted,$1.dst}
        sync.nop                             null                             {Compacted,$5.dst}
(W)     mad (1|M0)               r15.0<1>:f    r13.0<0;0>:f      r14.0<0;0>:f      r13.0<0>:f       {Compacted,F@2}
        mov (16|M16)             r11.0<1>:f    r120.0<1;1,0>:ud                 {Compacted}
(W)     mov (1|M0)               r3.0<1>:ud    r2.0<0;1,0>:f                   
        mov (16|M0)              r20.0<1>:ud   r5.0<1;1,0>:f                    {F@3}
        mul (16|M0)              r16.0<1>:f    r5.0<1;1,0>:f     r15.0<0;1,0>:f   {Compacted,F@2}
        mul (16|M16)             r18.0<1>:f    r11.0<1;1,0>:f    r15.0<0;1,0>:f   {Compacted,F@2}
        mov (16|M16)             r22.0<1>:ud   r11.0<1;1,0>:f                  
(W)     add (1|M0)               r4.0<1>:d     r8.2<0;1,0>:d     -r3.0<0;1,0>:d   {Compacted,I@3}
        add (16|M0)              r20.0<1>:d    r118.0<1;1,0>:d   -r20.0<1;1,0>:d  {Compacted,I@3}
        mov (16|M0)              r24.0<1>:ud   r16.0<1;1,0>:f                   {F@2}
        mov (16|M16)             r26.0<1>:ud   r18.0<1;1,0>:f                   {F@1}
        add (16|M16)             r22.0<1>:d    r120.0<1;1,0>:d   -r22.0<1;1,0>:d  {Compacted,I@5}
(W)     mov (1|M0)               r28.0<1>:f    r4.0<0;1,0>:ud                   {Compacted,I@5}
        mov (16|M0)              r29.0<1>:f    r20.0<1;1,0>:ud                  {Compacted,I@4}
        mov (16|M0)              r33.0<1>:f    r24.0<1;1,0>:ud                  {Compacted,I@3}
        mov (16|M16)             r35.0<1>:f    r26.0<1;1,0>:ud                  {Compacted,I@2}
        mov (16|M16)             r31.0<1>:f    r22.0<1;1,0>:ud                  {Compacted,I@1}
        mad (16|M0)              r37.0<1>:f    r5.0<1;0>:f       r33.0<1;0>:f      -r2.0<0>:f       {Compacted,F@3}
        mad (16|M0)              r41.0<1>:f    r29.0<1;0>:f      r33.0<1;0>:f      -r28.0<0>:f      {Compacted}
        mad (16|M16)             r39.0<1>:f    r11.0<1;0>:f      r35.0<1;0>:f      -r2.0<0>:f       {Compacted,F@4}
        mad (16|M16)             acc2.0<1>:f   r31.0<1;0>:f      r35.0<1;0>:f      -r28.0<0>:f      {F@4}
        add (16|M0)              acc0.0<1>:f   r37.0<1;1,0>:f    r41.0<1;1,0>:f   {Compacted,F@3}
        add (16|M16)             r47.0<1>:f    r39.0<1;1,0>:f    acc2.0<1;1,0>:f  {F@3}
        mul (16|M0)              r49.0<1>:f    r15.0<0;1,0>:f    acc0.0<1;1,0>:f 
(W)     xor (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x30:uw              {A@1}
(W)     xor (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x30:uw              {A@1}
        mul (16|M16)             r51.0<1>:f    r15.0<0;1,0>:f    r47.0<1;1,0>:f   {Compacted,A@1}
(W)     xor (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x30:uw              {A@1}
        mov (16|M0)              r53.0<1>:ud   r49.0<1;1,0>:f                   {A@1}
        mov (16|M16)             r55.0<1>:ud   r51.0<1;1,0>:f                   {F@1}
        add (16|M0)              r57.0<1>:d    r53.0<1;1,0>:d    r24.0<1;1,0>:d   {Compacted,I@2}
        add (16|M16)             r59.0<1>:d    r55.0<1;1,0>:d    r26.0<1;1,0>:d   {Compacted,I@2}
(W)     mul (8|M0)               acc0.0<1>:d   r57.0<1;1,0>:d    r8.4<0;1,0>:uw   {Compacted,I@2}
        mach (8|M0)              r57.0<1>:d    r57.0<1;1,0>:d    r8.2<0;1,0>:d    {Compacted}
(W)     mul (8|M8)               acc0.0<1>:d   r58.0<1;1,0>:d    r8.4<0;1,0>:uw  
        mach (8|M8)              r58.0<1>:d    r58.0<1;1,0>:d    r8.2<0;1,0>:d    {Compacted}
(W)     mul (8|M16)              acc0.0<1>:d   r59.0<1;1,0>:d    r8.4<0;1,0>:uw   {I@5}
        mach (8|M16)             r59.0<1>:d    r59.0<1;1,0>:d    r8.2<0;1,0>:d    {Compacted}
(W)     mul (8|M24)              acc0.0<1>:d   r60.0<1;1,0>:d    r8.4<0;1,0>:uw  
        mach (8|M24)             r60.0<1>:d    r60.0<1;1,0>:d    r8.2<0;1,0>:d    {Compacted}
        add (16|M0)              r57.0<1>:d    r118.0<1;1,0>:d   -r57.0<1;1,0>:d  {Compacted,I@5}
        add (16|M16)             r59.0<1>:d    r120.0<1;1,0>:d   -r59.0<1;1,0>:d  {Compacted,I@2}
        cmp (16|M0)   (ge)f0.0   r61.0<1>:ud   r57.0<1;1,0>:ud   r8.2<0;1,0>:ud   {Compacted,I@2}
        cmp (16|M16)  (ge)f1.0   r63.0<1>:ud   r59.0<1;1,0>:ud   r8.2<0;1,0>:ud   {I@2}
        add3 (16|M0)             r122.0<1>:d   r53.0<1;0>:d      r24.0<1;0>:d      -r61.0<1>:d      {I@2}
        add3 (16|M16)            r124.0<1>:d   r55.0<1;0>:d      r26.0<1;0>:d      -r63.0<1>:d      {I@2}
        goto (32|M0)                         L3064                  L3112                
L3064:
        join (32|M0)                         L3112                                
L3080:
        mov (16|M0)              r122.0<1>:d   -1:w                              
        mov (16|M16)             r124.0<1>:d   -1:w                              
L3112:
        join (32|M0)                         L3128                                
L3128:
(W)     mul (1|M0)               acc0.0<1>:d   r117.1<0;1,0>:d   r8.12<0;1,0>:uw 
(W)     mach (1|M0)              r2.0<1>:d     r117.1<0;1,0>:d   r8.6<0;1,0>:d   
(W)     mul (8|M0)               acc0.0<1>:d   r122.0<1;1,0>:d   r9.4<0;1,0>:uw   {Compacted,I@5}
        mach (8|M0)              r3.0<1>:d     r122.0<1;1,0>:d   r9.2<0;1,0>:d    {Compacted}
(W)     mul (8|M8)               acc0.0<1>:d   r123.0<1;1,0>:d   r9.4<0;1,0>:uw  
        mach (8|M8)              r4.0<1>:d     r123.0<1;1,0>:d   r9.2<0;1,0>:d    {Compacted}
(W)     mul (8|M16)              acc0.0<1>:d   r124.0<1;1,0>:d   r9.4<0;1,0>:uw   {I@7}
        mach (8|M16)             r5.0<1>:d     r124.0<1;1,0>:d   r9.2<0;1,0>:d    {Compacted,$1.dst}
(W)     mul (8|M24)              acc0.0<1>:d   r125.0<1;1,0>:d   r9.4<0;1,0>:uw  
        mach (8|M24)             r6.0<1>:d     r125.0<1;1,0>:d   r9.2<0;1,0>:d    {Compacted}
(W)     mul (8|M0)               acc0.0<1>:d   r122.0<1;1,0>:d   r8.4<0;1,0>:uw   {Compacted}
        mach (8|M0)              r11.0<1>:d    r122.0<1;1,0>:d   r8.2<0;1,0>:d    {Compacted}
(W)     mul (8|M8)               acc0.0<1>:d   r123.0<1;1,0>:d   r8.4<0;1,0>:uw  
        mach (8|M8)              r12.0<1>:d    r123.0<1;1,0>:d   r8.2<0;1,0>:d    {Compacted}
(W)     mul (8|M16)              acc0.0<1>:d   r124.0<1;1,0>:d   r8.4<0;1,0>:uw  
        mach (8|M16)             r13.0<1>:d    r124.0<1;1,0>:d   r8.2<0;1,0>:d    {Compacted}
(W)     mul (8|M24)              acc0.0<1>:d   r125.0<1;1,0>:d   r8.4<0;1,0>:uw  
        mach (8|M24)             r14.0<1>:d    r125.0<1;1,0>:d   r8.2<0;1,0>:d    {Compacted}
(W)     shl (1|M0)               r15.0<1>:d    r117.0<0;1,0>:d   1:w               {Compacted}
(W)     shl (1|M0)               r16.0<1>:d    r2.0<0;1,0>:d     1:w               {Compacted}
        add (16|M0)              r11.0<1>:d    r118.0<1;1,0>:d   -r11.0<1;1,0>:d  {Compacted,I@7}
        add (16|M16)             r13.0<1>:d    r120.0<1;1,0>:d   -r13.0<1;1,0>:d  {Compacted,I@4}
        sync.nop                             null                             {Compacted,$3.dst}
(W)     mov (1|M0)               a0.0<1>:ud    r10.1<0;1,0>:d                   {A@1}
        shl (16|M0)              r3.0<1>:d     r3.0<1;1,0>:d     1:w               {Compacted}
        shl (16|M16)             r5.0<1>:d     r5.0<1;1,0>:d     1:w               {Compacted}
(W)     add3 (1|M0)              r17.0<1>:d    r15.0<0;0>:d      r9.7<0;0>:d       r16.0<0>:d       {I@6}
        shl (16|M0)              r11.0<1>:d    r11.0<1;1,0>:d    1:w               {Compacted,I@6}
        shl (16|M16)             r13.0<1>:d    r13.0<1;1,0>:d    1:w               {Compacted,I@6}
        add3 (16|M0)             r11.0<1>:d    r17.0<0;0>:d      r3.0<1;0>:d       r11.0<1>:d       {I@2}
        add3 (16|M16)            r13.0<1>:d    r17.0<0;0>:d      r5.0<1;0>:d       r13.0<1>:d       {I@2}
        send.ugm (16|M0)         r18      r11     null:0  a0.0        0x24280B00           {ExBSO,A@2,$6} // wr:2+0, rd:2; load.ugm.d16u32.a32.ca.ca.bss[a0.0]
        send.ugm (16|M16)        r20      r13     null:0  a0.0        0x24280B00           {ExBSO,A@1,$7} // wr:2+0, rd:2; load.ugm.d16u32.a32.ca.ca.bss[a0.0]
        shl (16|M0)              r22.0<1>:d    r118.0<1;1,0>:d   1:w               {Compacted}
        shl (16|M16)             r24.0<1>:d    r120.0<1;1,0>:d   1:w               {Compacted}
(W)     mov (1|M0)               a0.0<1>:ud    r10.0<0;1,0>:d                   {A@1}
        add (16|M0)              r22.0<1>:d    r22.0<1;1,0>:d    r9.6<0;1,0>:d    {Compacted,I@3}
        add (16|M16)             r24.0<1>:d    r24.0<1;1,0>:d    r9.6<0;1,0>:d    {Compacted,I@3}
        mov (16|M0)              r26.0<1>:ud   r18.0<2;1,0>:uw                  {$6.dst}
        mov (16|M16)             r28.0<1>:ud   r20.0<2;1,0>:uw                  {$7.dst}
(W)     mov (8|M0)               r127.0<1>:f   r116.0<1;1,0>:f                  {Compacted}
        send.ugm (16|M0)         null     r22     r26:2   a0.0        0x240E0B04           {ExBSO,A@2,$8} // wr:2+2, rd:0; store.ugm.d16u32.a32.wb.wb.bss[a0.0]
        sync.nop                             null                             {Compacted,I@1}
        send.ugm (16|M16)        null     r24     r28:2   a0.0        0x240E0B04           {ExBSO,$9} // wr:2+2, rd:0; store.ugm.d16u32.a32.wb.wb.bss[a0.0]
(W)     send.gtwy (1|M0)         null     r127    null:0  0x0            0x02000010           {EOT,A@1} // wr:1+0, rd:0; end of thread
L3648:
        nop                    
(W)     mov (16|M0)              null<1>:ud    0x9E09665A:ud                             
(W)     mov (16|M0)              null<1>:ud    0xA6E09A48:ud                             
(W)     mov (16|M0)              null<1>:ud    0x0:ud                             
(W)     mov (16|M0)              null<1>:ud    0x14:ud                             
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
