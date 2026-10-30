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
(W)     mov (8|M0)               r84.0<1>:ud   r0.0<1;1,0>:ud                  
(W)     or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x4C0:uw              {A@1}
(W)     mul (1|M0)               acc0.0<1>:d   r7.3<0;1,0>:d     r84.2<0;1,0>:uw  {A@1}
(W)     cmp (16|M0)   (gt)f1.0   null<1>:d     r8.2<0;1,0>:d     -1:w               {$2.dst}
(W)     cmp (16|M16)  (gt)f1.0   null<1>:d     r8.2<0;1,0>:d     -1:w              
(W)     mach (1|M0)              r3.0<1>:d     r7.3<0;1,0>:d     r84.1<0;1,0>:d   {$0.dst}
        add3 (16|M0)             r85.0<1>:d    r3.0<0;0>:d       r1.0<1;0>:uw      r7.0<0>:d        {I@1}
        add3 (16|M16)            r87.0<1>:d    r3.0<0;0>:d       r2.0<1;0>:uw      r7.0<0>:d       
        and (16|M0)              r89.0<1>:d    r85.0<1;1,0>:d    3:w               {Compacted,I@2}
        shr (16|M0)              r93.0<1>:ud   r85.0<1;1,0>:ud   2:w              
        shr (16|M0)              r97.0<1>:ud   r85.0<1;1,0>:ud   8:w              
        and (16|M16)             r91.0<1>:d    r87.0<1;1,0>:d    3:w               {Compacted,I@4}
        shr (16|M16)             r95.0<1>:ud   r87.0<1;1,0>:ud   2:w              
        shr (16|M16)             r99.0<1>:ud   r87.0<1;1,0>:ud   8:w              
(f1.0)  goto (32|M0)                         L2344                  L2344                
L480:
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
(W)     mov (1|M0)               r9.1<1>:f     r8.0<0;1,0>:ud                   {Compacted,I@3}
(W)     mov (1|M0)               r14.0<1>:ud   0x53800000:ud                             
(W)     mov (1|M0)               r6.0<1>:f     r5.0<0;1,0>:ud                   {Compacted,I@2}
(W)     mad (1|M0)               r13.0<1>:f    r11.0<0;0>:f      r12.0<0;0>:f      r9.1<0>:f        {Compacted,F@2}
(W)     mov (1|M0)               r17.0<1>:ud   0xB4E00000:ud                             
(W)     mad (1|M0)               r15.0<1>:f    r13.0<0;0>:f      r14.0<0;0>:f      r6.0<0>:f        {Compacted,A@1}
(W)     mov (1|M0)               r21.0<1>:ud   0x0:ud                             
        sync.nop                             null                             {Compacted,F@1}
(W)     math.inv (1|M0)          r16.0<1>:f    r15.0<0;1,0>:f                   {$3}
        sync.nop                             null                             {Compacted,$3.dst}
(W)     mad (1|M0)               r18.0<1>:f    r16.0<0;0>:f      r17.0<0;0>:f      r16.0<0>:f       {Compacted,I@2}
        shr (16|M0)              r25.0<1>:ud   r85.0<1;1,0>:ud   28:w              
(W)     mul (1|M0)               r19.0<1>:f    r18.0<0;1,0>:f    0.0:f               {Compacted,F@1}
(W)     mul (1|M0)               r23.0<1>:f    r9.1<0;1,0>:f     -1.048576e+06:f               {Compacted}
(W)     rndd (1|M0)              r20.0<1>:f    r19.0<0;1,0>:f                   {Compacted,F@2}
        shr (16|M16)             r27.0<1>:ud   r87.0<1;1,0>:ud   28:w              
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
        and (16|M0)              r72.0<1>:d    r97.0<1;1,0>:d    1048575:d              
(W)     mul (1|M0)               r45.0<1>:f    r6.0<0;1,0>:f     -1.048576e+06:f               {Compacted}
        mad (16|M0)              r41.0<1>:f    r24.0<0;0>:f      r37.0<1;0>:f      -r9.1<0>:f       {Compacted}
        rndd (16|M16)            acc2.0<1>:f   acc2.0<1;1,0>:f                 
        mad (16|M0)              r59.0<1>:f    -acc0.0<1;0>:f    r37.0<1;0>:f      r50.0<0>:f      
(W)     mov (1|M0)               r63.0<1>:ud   0xBF800000:ud                             
        and (16|M16)             r74.0<1>:d    r99.0<1;1,0>:d    1048575:d              
        mad (16|M16)             r43.0<1>:f    r24.0<0;0>:f      r39.0<1;0>:f      -r9.1<0>:f       {Compacted}
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
(W)     mul (1|M0)               r51.0<1>:f    r9.1<0;1,0>:f     9.536743e-07:f               {Compacted}
        mul (16|M16)             acc2.0<1>:f   r18.0<0;1,0>:f    acc2.0<1;1,0>:f 
        rndd (16|M0)             r19.0<1>:f    acc0.0<1;1,0>:f                  {Compacted}
        rndd (16|M16)            r21.0<1>:f    acc2.0<1;1,0>:f                  {Compacted}
        mul (16|M0)              acc0.0<1>:f   r50.0<0;1,0>:f    r19.0<1;1,0>:f   {Compacted,F@2}
        mul (16|M0)              acc2.0<1>:f   r51.0<0;1,0>:f    r19.0<1;1,0>:f   {Compacted}
        mul (16|M16)             r29.0<1>:f    r50.0<0;1,0>:f    r21.0<1;1,0>:f   {Compacted,F@3}
        mul (16|M16)             r54.0<1>:f    r51.0<0;1,0>:f    r21.0<1;1,0>:f   {Compacted}
        rndd (16|M0)             acc0.0<1>:f   acc0.0<1;1,0>:f                 
        rndd (16|M0)             acc2.0<1>:f   acc2.0<1;1,0>:f                 
        mad (16|M0)              r23.0<1>:f    r64.0<1;0>:f      r19.0<1;0>:f      -r6.0<0>:f       {Compacted}
        rndd (16|M16)            r33.0<1>:f    r29.0<1;1,0>:f                   {Compacted,F@5}
        rndd (16|M16)            r58.0<1>:f    r54.0<1;1,0>:f                   {Compacted,F@5}
        mad (16|M0)              r43.0<1>:f    r68.0<1;0>:f      acc0.0<1;0>:f     r63.0<0>:f       {Compacted}
        mad (16|M0)              r60.0<1>:f    -acc2.0<1;0>:f    r19.0<1;0>:f      r51.0<0>:f      
        mad (16|M16)             r25.0<1>:f    r66.0<1;0>:f      r21.0<1;0>:f      -r6.0<0>:f       {Compacted}
        mad (16|M0)              r35.0<1>:f    -acc0.0<1;0>:f    r19.0<1;0>:f      r50.0<0>:f      
        mad (16|M16)             r45.0<1>:f    r70.0<1;0>:f      r33.0<1;0>:f      r63.0<0>:f       {Compacted,F@6}
        mad (16|M16)             r64.0<1>:f    -r58.0<1;0>:f     r21.0<1;0>:f      r51.0<0>:f       {Compacted,F@6}
        mad (16|M0)              acc2.0<1>:f   r23.0<1;0>:f      acc2.0<1;0>:f     r63.0<0>:f       {Compacted}
        mad (16|M0)              r70.0<1>:f    r43.0<1;0>:f      r60.0<1;0>:f      -r12.0<0>:f      {Compacted,F@6}
        mad (16|M16)             r41.0<1>:f    -r33.0<1;0>:f     r21.0<1;0>:f      r50.0<0>:f       {Compacted}
        mad (16|M16)             r68.0<1>:f    r25.0<1;0>:f      r58.0<1;0>:f      r63.0<0>:f       {Compacted,F@7}
        mad (16|M0)              r47.0<1>:f    r76.0<1;0>:f      r35.0<1;0>:f      -r12.0<0>:f      {Compacted,F@7}
        mad (16|M16)             r72.0<1>:f    r45.0<1;0>:f      r64.0<1;0>:f      -r12.0<0>:f      {Compacted,F@6}
        mad (16|M0)              r82.0<1>:f    r70.0<1;0>:f      acc2.0<1;0>:f     r12.0<0>:f       {Compacted,F@5}
        mad (16|M16)             r49.0<1>:f    r78.0<1;0>:f      r41.0<1;0>:f      -r12.0<0>:f      {Compacted,F@5}
        mad (16|M16)             acc0.0<1>:f   r72.0<1;0>:f      r68.0<1;0>:f      r12.0<0>:f       {F@3}
        mad (16|M0)              r13.0<1>:f    r47.0<1;0>:f      r82.0<1;0>:f      r12.0<0>:f       {Compacted,F@3}
        mad (16|M16)             acc0.0<1>:f   r49.0<1;0>:f      acc0.0<1;0>:f     r12.0<0>:f       {F@3}
        mul (16|M0)              r13.0<1>:f    r18.0<0;1,0>:f    r13.0<1;1,0>:f   {Compacted,F@2}
        mul (16|M16)             acc0.0<1>:f   r18.0<0;1,0>:f    acc0.0<1;1,0>:f 
        rndd (16|M0)             r17.0<1>:f    r13.0<1;1,0>:f                   {Compacted,F@2}
        mov (16|M16)             r80.0<1>:d    r21.0<1;1,0>:f                   {Compacted}
        mad (16|M0)              acc2.0<1>:f   acc2.0<1;0>:f     -r17.0<1;0>:f     r6.0<0>:f        {F@1}
        mov (16|M0)              r78.0<1>:d    r19.0<1;1,0>:f                   {Compacted}
        mul (16|M0)              r65.0<1>:f    acc2.0<1;1,0>:f   0x2F800000:f               {Compacted}
        rndd (16|M16)            r19.0<1>:f    acc0.0<1;1,0>:f                  {Compacted,I@1}
        mad (16|M0)              r25.0<1>:f    r70.0<1;0>:f      -r17.0<1;0>:f     r9.1<0>:f        {Compacted}
        mov (16|M0)              r33.0<1>:d    r17.0<1;1,0>:f                   {Compacted}
        mad (16|M16)             r23.0<1>:f    r68.0<1;0>:f      -r19.0<1;0>:f     r6.0<0>:f        {Compacted,F@2}
        mad (16|M16)             r27.0<1>:f    r72.0<1;0>:f      -r19.0<1;0>:f     r9.1<0>:f        {Compacted}
        rndz (16|M0)             r69.0<1>:f    r65.0<1;1,0>:f                   {Compacted}
(W)     mov (1|M0)               r73.0<1>:ud   0xCF800000:ud                              {F@2}
        mov (16|M0)              r74.0<1>:d    r37.0<1;1,0>:f                   {Compacted}
        mad (16|M0)              r29.0<1>:f    r47.0<1;0>:f      -r17.0<1;0>:f     r11.0<0>:f       {Compacted}
        mul (16|M16)             r67.0<1>:f    r23.0<1;1,0>:f    0x2F800000:f               {Compacted}
        add (16|M0)              r37.0<1>:d    r33.0<1;1,0>:d    r78.0<1;1,0>:d   {Compacted,I@3}
        mad (16|M0)              r78.0<1>:f    acc2.0<1;0>:f     r69.0<1;0>:f      r73.0<0>:f       {Compacted,A@1}
        mov (16|M16)             r35.0<1>:d    r19.0<1;1,0>:f                   {Compacted}
        mov (16|M0)              r45.0<1>:d    r29.0<1;1,0>:f                   {Compacted,F@3}
        rndz (16|M16)            acc2.0<1>:f   r67.0<1;1,0>:f                   {F@2}
        mov (16|M0)              r82.0<1>:ud   r78.0<1;1,0>:f                   {F@2}
        mov (16|M16)             r76.0<1>:d    r39.0<1;1,0>:f                   {Compacted}
        mad (16|M16)             r31.0<1>:f    r49.0<1;0>:f      -r19.0<1;0>:f     r11.0<0>:f       {Compacted}
        asr (16|M0)              r61.0<1>:d    r45.0<1;1,0>:d    31:w               {Compacted,I@3}
        addc (8|M0)              r5.0<1>:ud    r45.0<1;1,0>:ud   0x0:ud              {AccWrEn,Compacted}
        shl (16|M0)              r82.0<1>:d    r82.0<1;1,0>:d    8:w               {Compacted,I@4}
        add (16|M16)             r39.0<1>:d    r35.0<1;1,0>:d    r80.0<1;1,0>:d   {Compacted}
        mad (16|M16)             r80.0<1>:f    r23.0<1;0>:f      acc2.0<1;0>:f     r73.0<0>:f       {Compacted,I@1}
        mov (16|M0)              r41.0<1>:d    r25.0<1;1,0>:f                   {Compacted}
        mov (16|M16)             r47.0<1>:d    r31.0<1;1,0>:f                   {Compacted,F@2}
        add3 (8|M0)              r10.0<1>:ud   acc0.0<1;0>:ud    r82.0<1;0>:ud     r61.0<1>:ud     
        mov (16|M16)             r3.0<1>:ud    r80.0<1;1,0>:f                   {F@1}
        addc (8|M8)              r6.0<1>:ud    r46.0<1;1,0>:ud   0x0:ud              {AccWrEn}
        asr (16|M0)              r49.0<1>:d    r41.0<1;1,0>:d    31:w               {Compacted,I@5}
        asr (16|M16)             r63.0<1>:d    r47.0<1;1,0>:d    31:w               {Compacted,I@5}
        shl (16|M16)             r3.0<1>:d     r3.0<1;1,0>:d     8:w               {Compacted,I@4}
        add3 (8|M8)              r11.0<1>:ud   acc0.0<1;0>:ud    r83.0<1;0>:ud     r62.0<1>:ud     
        addc (8|M16)             r12.0<1>:ud   r47.0<1;1,0>:ud   0x0:ud              {AccWrEn}
        mov (16|M16)             r43.0<1>:d    r27.0<1;1,0>:f                   {Compacted}
        shl (16|M0)              r53.0<1>:d    r41.0<1;1,0>:d    20:w               {Compacted}
        shl (16|M0)              r49.0<1>:d    r49.0<1;1,0>:d    20:w               {Compacted,I@7}
        add3 (8|M16)             r14.0<1>:ud   acc0.0<1;0>:ud    r3.0<1;0>:ud      r63.0<1>:ud      {I@6}
        shr (16|M0)              r41.0<1>:ud   r41.0<1;1,0>:ud   12:w              
        addc (8|M24)             r13.0<1>:ud   r48.0<1;1,0>:ud   0x0:ud              {AccWrEn}
        asr (16|M16)             r51.0<1>:d    r43.0<1;1,0>:d    31:w               {Compacted,I@6}
        or (16|M0)               r57.0<1>:d    r49.0<1;1,0>:d    r41.0<1;1,0>:d   {Compacted,I@3}
        add3 (8|M24)             r15.0<1>:ud   acc0.0<1;0>:ud    r4.0<1;0>:ud      r64.0<1>:ud     
        addc (8|M0)              r16.0<1>:ud   r5.0<1;1,0>:ud    r53.0<1;1,0>:ud  {AccWrEn,Compacted}
        shl (16|M16)             r55.0<1>:d    r43.0<1;1,0>:d    20:w               {Compacted}
        shl (16|M16)             r51.0<1>:d    r51.0<1;1,0>:d    20:w               {Compacted,I@5}
        add3 (8|M0)              r18.0<1>:ud   acc0.0<1;0>:ud    r10.0<1;0>:ud     r57.0<1>:ud      {I@5}
        shr (16|M16)             r43.0<1>:ud   r43.0<1;1,0>:ud   12:w              
        addc (8|M8)              r17.0<1>:ud   r6.0<1;1,0>:ud    r54.0<1;1,0>:ud  {AccWrEn}
        or (16|M16)              r59.0<1>:d    r51.0<1;1,0>:d    r43.0<1;1,0>:d   {Compacted,I@2}
        add3 (8|M8)              r19.0<1>:ud   acc0.0<1;0>:ud    r11.0<1;0>:ud     r58.0<1>:ud     
        addc (8|M16)             r20.0<1>:ud   r12.0<1;1,0>:ud   r55.0<1;1,0>:ud  {AccWrEn}
        cmp (16|M0)   (ge)f0.0   null<1>:d     r16.0<1;1,0>:ud   r8.2<0;1,0>:ud   {I@4}
        add3 (8|M16)             r22.0<1>:ud   acc0.0<1;0>:ud    r14.0<1;0>:ud     r59.0<1>:ud      {I@4}
        addc (8|M24)             r21.0<1>:ud   r13.0<1;1,0>:ud   r56.0<1;1,0>:ud  {AccWrEn}
(f0.0)  cmp (16|M0)   (eq)f0.0   null<1>:d     r18.0<1;1,0>:d    r2.0<0;1,0>:d    {I@5}
        cmp (16|M16)  (ge)f0.0   null<1>:d     r20.0<1;1,0>:ud   r8.2<0;1,0>:ud   {I@2}
        add3 (8|M24)             r23.0<1>:ud   acc0.0<1;0>:ud    r15.0<1;0>:ud     r60.0<1>:ud     
(~f0.0) cmp (16|M0)   (gt)f0.0   null<1>:d     r18.0<1;1,0>:ud   r2.0<0;1,0>:ud  
(f0.0)  cmp (16|M16)  (eq)f0.0   null<1>:d     r22.0<1;1,0>:d    r2.0<0;1,0>:d    {I@2}
(W)     mov (1|M0)               r28.0<1>:w    -1:w                              
        shl (16|M0)              r24.0<1>:d    r74.0<1;1,0>:d    20:w               {Compacted}
(~f0.0) cmp (16|M16)  (gt)f0.0   null<1>:d     r22.0<1;1,0>:ud   r2.0<0;1,0>:ud  
        shl (16|M16)             r26.0<1>:d    r76.0<1;1,0>:d    20:w               {Compacted}
(f0.0)  sel (16|M0)              r29.0<1>:d    r28.0<0;1,0>:w    0:w               {I@4}
(f0.0)  sel (16|M16)             r31.0<1>:d    r28.0<0;1,0>:w    0:w              
        add3 (16|M0)             r101.0<1>:d   r24.0<1;0>:d      r37.0<1;0>:d      -r29.0<1>:d      {I@2}
        add3 (16|M16)            r103.0<1>:d   r26.0<1;0>:d      r39.0<1;0>:d      -r31.0<1>:d      {I@2}
        goto (32|M0)                         L2344                  L3056                
L2344:
        join (32|M0)                         L3056                                
L2360:
(W)     cmp (16|M0)   (eq)f0.0   null<1>:d     r8.2<0;1,0>:d     0:w               {Compacted}
(W)     cmp (16|M16)  (eq)f0.0   null<1>:d     r8.2<0;1,0>:d     0:w              
(f0.0)  goto (32|M0)                         L3008                  L3008                
L2400:
(W)     xor (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x30:uw              {A@1}
(W)     mov (1|M0)               r2.0<1>:f     r8.2<0;1,0>:ud                   {Compacted,A@1}
(W)     mov (1|M0)               r13.0<1>:f    0xB4C00000:f                               {Compacted}
(W)     math.inv (1|M0)          r12.0<1>:f    r2.0<0;1,0>:f                    {@2,$4}
        mov (16|M0)              r5.0<1>:f     r97.0<1;1,0>:ud                  {Compacted,$1.dst}
        sync.nop                             null                             {Compacted,$4.dst}
(W)     mad (1|M0)               r14.0<1>:f    r12.0<0;0>:f      r13.0<0;0>:f      r12.0<0>:f       {Compacted,F@2}
        mov (16|M16)             r10.0<1>:f    r99.0<1;1,0>:ud                  {Compacted}
(W)     mov (1|M0)               r3.0<1>:ud    r2.0<0;1,0>:f                   
        mov (16|M0)              r19.0<1>:ud   r5.0<1;1,0>:f                    {F@3}
        mul (16|M0)              r15.0<1>:f    r5.0<1;1,0>:f     r14.0<0;1,0>:f   {Compacted,F@2}
        mul (16|M16)             r17.0<1>:f    r10.0<1;1,0>:f    r14.0<0;1,0>:f   {Compacted,F@2}
        mov (16|M16)             r21.0<1>:ud   r10.0<1;1,0>:f                  
(W)     add (1|M0)               r4.0<1>:d     r8.2<0;1,0>:d     -r3.0<0;1,0>:d   {Compacted,I@3}
        add (16|M0)              r19.0<1>:d    r97.0<1;1,0>:d    -r19.0<1;1,0>:d  {Compacted,I@3}
        mov (16|M0)              r23.0<1>:ud   r15.0<1;1,0>:f                   {F@2}
        mov (16|M16)             r25.0<1>:ud   r17.0<1;1,0>:f                   {F@1}
        add (16|M16)             r21.0<1>:d    r99.0<1;1,0>:d    -r21.0<1;1,0>:d  {Compacted,I@5}
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
        add (16|M0)              r56.0<1>:d    r97.0<1;1,0>:d    -r56.0<1;1,0>:d  {Compacted,I@5}
        add (16|M16)             r58.0<1>:d    r99.0<1;1,0>:d    -r58.0<1;1,0>:d  {Compacted,I@2}
        cmp (16|M0)   (ge)f1.0   r60.0<1>:ud   r56.0<1;1,0>:ud   r8.2<0;1,0>:ud   {I@2}
        cmp (16|M16)  (ge)f0.0   r62.0<1>:ud   r58.0<1;1,0>:ud   r8.2<0;1,0>:ud   {I@2}
        add3 (16|M0)             r101.0<1>:d   r52.0<1;0>:d      r23.0<1;0>:d      -r60.0<1>:d      {I@2}
        add3 (16|M16)            r103.0<1>:d   r54.0<1;0>:d      r25.0<1;0>:d      -r62.0<1>:d      {I@2}
        goto (32|M0)                         L3008                  L3056                
L3008:
        join (32|M0)                         L3056                                
L3024:
        mov (16|M0)              r101.0<1>:d   -1:w                              
        mov (16|M16)             r103.0<1>:d   -1:w                              
L3056:
        join (32|M0)                         L3072                                
L3072:
(W)     mul (8|M0)               acc0.0<1>:d   r101.0<1;1,0>:d   r8.4<0;1,0>:uw   {Compacted,I@3}
        mach (8|M0)              r2.0<1>:d     r101.0<1;1,0>:d   r8.2<0;1,0>:d    {Compacted}
(W)     mul (8|M8)               acc0.0<1>:d   r102.0<1;1,0>:d   r8.4<0;1,0>:uw  
        mach (8|M8)              r3.0<1>:d     r102.0<1;1,0>:d   r8.2<0;1,0>:d    {Compacted}
(W)     mul (8|M16)              acc0.0<1>:d   r103.0<1;1,0>:d   r8.4<0;1,0>:uw   {I@6}
        mach (8|M16)             r4.0<1>:d     r103.0<1;1,0>:d   r8.2<0;1,0>:d    {Compacted}
(W)     mul (8|M24)              acc0.0<1>:d   r104.0<1;1,0>:d   r8.4<0;1,0>:uw  
        mach (8|M24)             r5.0<1>:d     r104.0<1;1,0>:d   r8.2<0;1,0>:d    {Compacted,$1.dst}
        shr (16|M0)              r17.0<1>:ud   r85.0<1;1,0>:ud   3:w              
        shr (16|M16)             r19.0<1>:ud   r87.0<1;1,0>:ud   3:w              
(W)     cmp (16|M0)   (eq)f1.0   null<1>:d     r8.3<0;1,0>:d     0:w              
(W)     cmp (16|M16)  (eq)f1.0   null<1>:d     r8.3<0;1,0>:d     0:w              
        add (16|M0)              r105.0<1>:d   r97.0<1;1,0>:d    -r2.0<1;1,0>:d   {Compacted,I@7}
        add (16|M16)             r107.0<1>:d   r99.0<1;1,0>:d    -r4.0<1;1,0>:d   {Compacted,I@6}
(W)     mov (1|M0)               r12.0<1>:d    7:w                              
        shl (16|M0)              r13.0<1>:d    r101.0<1;1,0>:d   5:w               {Compacted}
        shl (16|M16)             r15.0<1>:d    r103.0<1;1,0>:d   5:w               {Compacted}
        and (16|M0)              r17.0<1>:d    r17.0<1;1,0>:d    28:w               {Compacted,I@7}
        and (16|M16)             r19.0<1>:d    r19.0<1;1,0>:d    28:w               {Compacted,I@7}
        shl (16|M0)              r6.0<1>:d     r105.0<1;1,0>:d   3:w               {Compacted,I@7}
        shl (16|M16)             r10.0<1>:d    r107.0<1;1,0>:d   3:w               {Compacted,I@7}
        bfn.0xFE (16|M0)         r113.0<1>:ud  r13.0<1;0>:ud     r17.0<1;0>:ud     r89.0<1>:ud      {I@4} // s0|s1|s2
        bfn.0xFE (16|M16)        r115.0<1>:ud  r15.0<1;0>:ud     r19.0<1;0>:ud     r91.0<1>:ud      {I@4} // s0|s1|s2
        bfn.0xEA (16|M0)         r109.0<1>:ud  r6.0<1;0>:ud      r93.0<1;0>:ud     r12.0<0>:ud      {I@4} // s0|s1&s2
        bfn.0xEA (16|M16)        r111.0<1>:ud  r10.0<1;0>:ud     r95.0<1;0>:ud     r12.0<0>:ud      {I@4} // s0|s1&s2
(f1.0)  goto (32|M0)                         L4104                  L4104                
L3384:
(W)     asr (1|M0)               r2.0<1>:d     r8.3<0;1,0>:d     31:w               {Compacted}
        asr (16|M0)              r3.0<1>:d     r105.0<1;1,0>:d   28:w               {Compacted}
        asr (16|M16)             r5.0<1>:d     r107.0<1;1,0>:d   28:w               {Compacted}
(W)     add (1|M0)               r7.0<1>:d     r2.0<0;1,0>:d     r8.3<0;1,0>:d    {Compacted,I@3}
        add (16|M0)              r10.0<1>:d    r3.0<1;1,0>:d     r109.0<1;1,0>:d  {Compacted,I@3}
        add (16|M16)             r12.0<1>:d    r5.0<1;1,0>:d     r111.0<1;1,0>:d  {Compacted,I@3}
(W)     xor (1|M0)               r8.0<1>:d     r7.0<0;1,0>:d     r2.0<0;1,0>:d    {Compacted,I@3}
        xor (16|M0)              r14.0<1>:d    r10.0<1;1,0>:d    r3.0<1;1,0>:d    {Compacted,I@3}
        xor (16|M16)             r16.0<1>:d    r12.0<1;1,0>:d    r5.0<1;1,0>:d    {Compacted,I@3}
(W)     xor (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x30:uw              {A@1}
(W)     mov (1|M0)               r18.0<1>:f    r8.0<0;1,0>:ud                   {Compacted,A@1}
(W)     mov (1|M0)               r26.0<1>:f    0xB4C00000:f                               {Compacted}
(W)     math.inv (1|M0)          r25.0<1>:f    r18.0<0;1,0>:f                   {@2,$5}
        mov (16|M0)              r21.0<1>:f    r14.0<1;1,0>:ud                  {Compacted,I@3}
        sync.nop                             null                             {Compacted,$5.dst}
(W)     mad (1|M0)               r27.0<1>:f    r25.0<0;0>:f      r26.0<0;0>:f      r25.0<0>:f       {Compacted,F@2}
        mov (16|M16)             r23.0<1>:f    r16.0<1;1,0>:ud                  {Compacted,I@2}
(W)     mov (1|M0)               r19.0<1>:ud   r18.0<0;1,0>:f                  
        mov (16|M0)              r32.0<1>:ud   r21.0<1;1,0>:f                   {F@3}
        mul (16|M0)              r28.0<1>:f    r21.0<1;1,0>:f    r27.0<0;1,0>:f   {Compacted,F@2}
        mul (16|M16)             r30.0<1>:f    r23.0<1;1,0>:f    r27.0<0;1,0>:f   {Compacted,F@2}
        mov (16|M16)             r34.0<1>:ud   r23.0<1;1,0>:f                  
(W)     add (1|M0)               r20.0<1>:d    r8.0<0;1,0>:d     -r19.0<0;1,0>:d  {Compacted,I@3}
        add (16|M0)              r32.0<1>:d    r14.0<1;1,0>:d    -r32.0<1;1,0>:d  {Compacted,I@3}
        mov (16|M0)              r36.0<1>:ud   r28.0<1;1,0>:f                   {F@2}
        mov (16|M16)             r38.0<1>:ud   r30.0<1;1,0>:f                   {F@1}
        add (16|M16)             r34.0<1>:d    r16.0<1;1,0>:d    -r34.0<1;1,0>:d  {Compacted,I@5}
(W)     mov (1|M0)               r40.0<1>:f    r20.0<0;1,0>:ud                  {Compacted,I@5}
        mov (16|M0)              r41.0<1>:f    r32.0<1;1,0>:ud                  {Compacted,I@4}
        mov (16|M0)              r45.0<1>:f    r36.0<1;1,0>:ud                  {Compacted,I@3}
        mov (16|M16)             r47.0<1>:f    r38.0<1;1,0>:ud                  {Compacted,I@2}
        mov (16|M16)             r43.0<1>:f    r34.0<1;1,0>:ud                  {Compacted,I@1}
        mad (16|M0)              r49.0<1>:f    r21.0<1;0>:f      r45.0<1;0>:f      -r18.0<0>:f      {Compacted,F@3}
        mad (16|M0)              r53.0<1>:f    r41.0<1;0>:f      r45.0<1;0>:f      -r40.0<0>:f      {Compacted}
        mad (16|M16)             r51.0<1>:f    r23.0<1;0>:f      r47.0<1;0>:f      -r18.0<0>:f      {Compacted,F@4}
        mad (16|M16)             acc2.0<1>:f   r43.0<1;0>:f      r47.0<1;0>:f      -r40.0<0>:f      {F@4}
        add (16|M0)              acc0.0<1>:f   r49.0<1;1,0>:f    r53.0<1;1,0>:f   {Compacted,F@3}
        add (16|M16)             r59.0<1>:f    r51.0<1;1,0>:f    acc2.0<1;1,0>:f  {F@3}
        mul (16|M0)              r61.0<1>:f    r27.0<0;1,0>:f    acc0.0<1;1,0>:f 
(W)     xor (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x30:uw              {A@1}
(W)     xor (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x30:uw              {A@1}
        mul (16|M16)             r63.0<1>:f    r27.0<0;1,0>:f    r59.0<1;1,0>:f   {Compacted,A@1}
(W)     xor (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x30:uw              {A@1}
        mov (16|M0)              r65.0<1>:ud   r61.0<1;1,0>:f                   {A@1}
        mov (16|M16)             r67.0<1>:ud   r63.0<1;1,0>:f                   {F@1}
        add (16|M0)              r69.0<1>:d    r65.0<1;1,0>:d    r36.0<1;1,0>:d   {Compacted,I@2}
        add (16|M16)             r71.0<1>:d    r67.0<1;1,0>:d    r38.0<1;1,0>:d   {Compacted,I@2}
(W)     mul (8|M0)               acc0.0<1>:d   r69.0<1;1,0>:d    r8.0<0;1,0>:uw   {Compacted,I@2}
        mach (8|M0)              r77.0<1>:d    r69.0<1;1,0>:d    r8.0<0;1,0>:d    {Compacted}
(W)     mul (8|M8)               acc0.0<1>:d   r70.0<1;1,0>:d    r8.0<0;1,0>:uw  
        mach (8|M8)              r78.0<1>:d    r70.0<1;1,0>:d    r8.0<0;1,0>:d    {Compacted}
(W)     mul (8|M16)              acc0.0<1>:d   r71.0<1;1,0>:d    r8.0<0;1,0>:uw   {I@5}
        mach (8|M16)             r79.0<1>:d    r71.0<1;1,0>:d    r8.0<0;1,0>:d    {Compacted}
(W)     mul (8|M24)              acc0.0<1>:d   r72.0<1;1,0>:d    r8.0<0;1,0>:uw  
        mach (8|M24)             r80.0<1>:d    r72.0<1;1,0>:d    r8.0<0;1,0>:d    {Compacted}
        add (16|M0)              r77.0<1>:d    r14.0<1;1,0>:d    -r77.0<1;1,0>:d  {Compacted,I@5}
        add (16|M16)             r79.0<1>:d    r16.0<1;1,0>:d    -r79.0<1;1,0>:d  {Compacted,I@2}
        cmp (16|M0)   (ge)f0.0   r81.0<1>:ud   r77.0<1;1,0>:ud   r8.0<0;1,0>:ud   {Compacted,I@2}
        cmp (16|M16)  (ge)f1.0   r10.0<1>:ud   r79.0<1;1,0>:ud   r8.0<0;1,0>:ud   {I@2}
        xor (16|M0)              r73.0<1>:d    r2.0<0;1,0>:d     r3.0<1;1,0>:d    {Compacted}
        xor (16|M16)             r75.0<1>:d    r2.0<0;1,0>:d     r5.0<1;1,0>:d    {Compacted}
        add3 (16|M0)             r12.0<1>:d    r69.0<1;0>:d      r73.0<1;0>:d      -r81.0<1>:d      {I@2}
        add3 (16|M16)            r14.0<1>:d    r71.0<1;0>:d      r75.0<1;0>:d      -r10.0<1>:d      {I@2}
        bfn.0x96 (16|M0)         r117.0<1>:ud  r12.0<1;0>:ud     r2.0<0;0>:ud      r3.0<1>:ud       {I@2} // s0^s1^s2
        bfn.0x96 (16|M16)        r119.0<1>:ud  r14.0<1;0>:ud     r2.0<0;0>:ud      r5.0<1>:ud       {I@2} // s0^s1^s2
        goto (32|M0)                         L4104                  L4152                
L4104:
        join (32|M0)                         L4152                                
L4120:
        mov (16|M0)              r117.0<1>:d   -1:w                              
        mov (16|M16)             r119.0<1>:d   -1:w                              
L4152:
        join (32|M0)                         L4168                                
L4168:
(W)     cmp (16|M0)   (eq)f0.0   null<1>:d     r8.4<0;1,0>:d     0:w               {Compacted}
(W)     cmp (16|M16)  (eq)f0.0   null<1>:d     r8.4<0;1,0>:d     0:w              
(f0.0)  goto (32|M0)                         L4936                  L4936                
L4208:
(W)     asr (1|M0)               r2.0<1>:d     r8.4<0;1,0>:d     31:w               {Compacted}
        asr (16|M0)              r3.0<1>:d     r101.0<1;1,0>:d   26:w               {Compacted}
        asr (16|M16)             r5.0<1>:d     r103.0<1;1,0>:d   26:w               {Compacted}
(W)     add (1|M0)               r7.0<1>:d     r2.0<0;1,0>:d     r8.4<0;1,0>:d    {Compacted,I@3}
        add (16|M0)              r10.0<1>:d    r3.0<1;1,0>:d     r113.0<1;1,0>:d  {Compacted,I@3}
        add (16|M16)             r12.0<1>:d    r5.0<1;1,0>:d     r115.0<1;1,0>:d  {Compacted,I@3}
(W)     xor (1|M0)               r8.0<1>:d     r7.0<0;1,0>:d     r2.0<0;1,0>:d    {Compacted,I@3}
        xor (16|M0)              r14.0<1>:d    r10.0<1;1,0>:d    r3.0<1;1,0>:d    {Compacted,I@3}
        xor (16|M16)             r16.0<1>:d    r12.0<1;1,0>:d    r5.0<1;1,0>:d    {Compacted,I@3}
(W)     xor (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x30:uw              {A@1}
(W)     mov (1|M0)               r18.0<1>:f    r8.0<0;1,0>:ud                   {Compacted,A@1}
(W)     mov (1|M0)               r26.0<1>:f    0xB4C00000:f                               {Compacted}
(W)     math.inv (1|M0)          r25.0<1>:f    r18.0<0;1,0>:f                   {@2,$6}
        mov (16|M0)              r21.0<1>:f    r14.0<1;1,0>:ud                  {Compacted,I@3}
        sync.nop                             null                             {Compacted,$6.dst}
(W)     mad (1|M0)               r27.0<1>:f    r25.0<0;0>:f      r26.0<0;0>:f      r25.0<0>:f       {Compacted,F@2}
        mov (16|M16)             r23.0<1>:f    r16.0<1;1,0>:ud                  {Compacted,I@2}
(W)     mov (1|M0)               r19.0<1>:ud   r18.0<0;1,0>:f                  
        mov (16|M0)              r32.0<1>:ud   r21.0<1;1,0>:f                   {F@3}
        mul (16|M0)              r28.0<1>:f    r21.0<1;1,0>:f    r27.0<0;1,0>:f   {Compacted,F@2}
        mul (16|M16)             r30.0<1>:f    r23.0<1;1,0>:f    r27.0<0;1,0>:f   {Compacted,F@2}
        mov (16|M16)             r34.0<1>:ud   r23.0<1;1,0>:f                  
(W)     add (1|M0)               r20.0<1>:d    r8.0<0;1,0>:d     -r19.0<0;1,0>:d  {Compacted,I@3}
        add (16|M0)              r32.0<1>:d    r14.0<1;1,0>:d    -r32.0<1;1,0>:d  {Compacted,I@3}
        mov (16|M0)              r36.0<1>:ud   r28.0<1;1,0>:f                   {F@2}
        mov (16|M16)             r38.0<1>:ud   r30.0<1;1,0>:f                   {F@1}
        add (16|M16)             r34.0<1>:d    r16.0<1;1,0>:d    -r34.0<1;1,0>:d  {Compacted,I@5}
(W)     mov (1|M0)               r40.0<1>:f    r20.0<0;1,0>:ud                  {Compacted,I@5}
        mov (16|M0)              r41.0<1>:f    r32.0<1;1,0>:ud                  {Compacted,I@4}
        mov (16|M0)              r45.0<1>:f    r36.0<1;1,0>:ud                  {Compacted,I@3}
        mov (16|M16)             r47.0<1>:f    r38.0<1;1,0>:ud                  {Compacted,I@2}
        mov (16|M16)             r43.0<1>:f    r34.0<1;1,0>:ud                  {Compacted,I@1}
        mad (16|M0)              r49.0<1>:f    r21.0<1;0>:f      r45.0<1;0>:f      -r18.0<0>:f      {Compacted,F@3}
        mad (16|M0)              r53.0<1>:f    r41.0<1;0>:f      r45.0<1;0>:f      -r40.0<0>:f      {Compacted}
        mad (16|M16)             r51.0<1>:f    r23.0<1;0>:f      r47.0<1;0>:f      -r18.0<0>:f      {Compacted,F@4}
        mad (16|M16)             acc2.0<1>:f   r43.0<1;0>:f      r47.0<1;0>:f      -r40.0<0>:f      {F@4}
        add (16|M0)              acc0.0<1>:f   r49.0<1;1,0>:f    r53.0<1;1,0>:f   {Compacted,F@3}
        add (16|M16)             r59.0<1>:f    r51.0<1;1,0>:f    acc2.0<1;1,0>:f  {F@3}
        mul (16|M0)              r61.0<1>:f    r27.0<0;1,0>:f    acc0.0<1;1,0>:f 
(W)     xor (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x30:uw              {A@1}
(W)     xor (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x30:uw              {A@1}
        mul (16|M16)             r63.0<1>:f    r27.0<0;1,0>:f    r59.0<1;1,0>:f   {Compacted,A@1}
(W)     xor (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x30:uw              {A@1}
        mov (16|M0)              r65.0<1>:ud   r61.0<1;1,0>:f                   {A@1}
        mov (16|M16)             r67.0<1>:ud   r63.0<1;1,0>:f                   {F@1}
        add (16|M0)              r69.0<1>:d    r65.0<1;1,0>:d    r36.0<1;1,0>:d   {Compacted,I@2}
        add (16|M16)             r71.0<1>:d    r67.0<1;1,0>:d    r38.0<1;1,0>:d   {Compacted,I@2}
(W)     mul (8|M0)               acc0.0<1>:d   r69.0<1;1,0>:d    r8.0<0;1,0>:uw   {Compacted,I@2}
        mach (8|M0)              r77.0<1>:d    r69.0<1;1,0>:d    r8.0<0;1,0>:d    {Compacted}
(W)     mul (8|M8)               acc0.0<1>:d   r70.0<1;1,0>:d    r8.0<0;1,0>:uw  
        mach (8|M8)              r78.0<1>:d    r70.0<1;1,0>:d    r8.0<0;1,0>:d    {Compacted}
(W)     mul (8|M16)              acc0.0<1>:d   r71.0<1;1,0>:d    r8.0<0;1,0>:uw   {I@5}
        mach (8|M16)             r79.0<1>:d    r71.0<1;1,0>:d    r8.0<0;1,0>:d    {Compacted}
(W)     mul (8|M24)              acc0.0<1>:d   r72.0<1;1,0>:d    r8.0<0;1,0>:uw  
        mach (8|M24)             r80.0<1>:d    r72.0<1;1,0>:d    r8.0<0;1,0>:d    {Compacted}
        add (16|M0)              r77.0<1>:d    r14.0<1;1,0>:d    -r77.0<1;1,0>:d  {Compacted,I@5}
        add (16|M16)             r79.0<1>:d    r16.0<1;1,0>:d    -r79.0<1;1,0>:d  {Compacted,I@2}
        cmp (16|M0)   (ge)f1.0   r81.0<1>:ud   r77.0<1;1,0>:ud   r8.0<0;1,0>:ud   {I@2}
        cmp (16|M16)  (ge)f0.0   r10.0<1>:ud   r79.0<1;1,0>:ud   r8.0<0;1,0>:ud   {I@2}
        xor (16|M0)              r73.0<1>:d    r2.0<0;1,0>:d     r3.0<1;1,0>:d    {Compacted}
        xor (16|M16)             r75.0<1>:d    r2.0<0;1,0>:d     r5.0<1;1,0>:d    {Compacted}
        add3 (16|M0)             r12.0<1>:d    r69.0<1;0>:d      r73.0<1;0>:d      -r81.0<1>:d      {I@2}
        add3 (16|M16)            r14.0<1>:d    r71.0<1;0>:d      r75.0<1;0>:d      -r10.0<1>:d      {I@2}
        bfn.0x96 (16|M0)         r121.0<1>:ud  r12.0<1;0>:ud     r2.0<0;0>:ud      r3.0<1>:ud       {I@2} // s0^s1^s2
        bfn.0x96 (16|M16)        r123.0<1>:ud  r14.0<1;0>:ud     r2.0<0;0>:ud      r5.0<1>:ud       {I@2} // s0^s1^s2
        goto (32|M0)                         L4936                  L4984                
L4936:
        join (32|M0)                         L4984                                
L4952:
        mov (16|M0)              r121.0<1>:d   -1:w                              
        mov (16|M16)             r123.0<1>:d   -1:w                              
L4984:
        join (32|M0)                         L5000                                
L5000:
        cmp (16|M0)   (eq)f1.0   null<1>:d     r121.0<1;1,0>:d   r117.0<1;1,0>:d  {I@3}
        cmp (16|M16)  (eq)f1.0   null<1>:d     r123.0<1;1,0>:d   r119.0<1;1,0>:d  {I@3}
(~f1.0) goto (32|M0)                         L5576                  L5576                
L5048:
(W)     mul (8|M0)               acc0.0<1>:d   r117.0<1;1,0>:d   r8.6<0;1,0>:uw   {Compacted}
        mach (8|M0)              r2.0<1>:d     r117.0<1;1,0>:d   r8.3<0;1,0>:d    {Compacted}
(W)     mul (8|M8)               acc0.0<1>:d   r118.0<1;1,0>:d   r8.6<0;1,0>:uw  
        mach (8|M8)              r3.0<1>:d     r118.0<1;1,0>:d   r8.3<0;1,0>:d    {Compacted}
(W)     mul (8|M16)              acc0.0<1>:d   r119.0<1;1,0>:d   r8.6<0;1,0>:uw  
        mach (8|M16)             r4.0<1>:d     r119.0<1;1,0>:d   r8.3<0;1,0>:d    {Compacted}
(W)     mul (8|M24)              acc0.0<1>:d   r120.0<1;1,0>:d   r8.6<0;1,0>:uw  
        add (16|M0)              r2.0<1>:d     r109.0<1;1,0>:d   -r2.0<1;1,0>:d   {Compacted,I@4}
        mach (8|M24)             r5.0<1>:d     r120.0<1;1,0>:d   r8.3<0;1,0>:d    {Compacted}
(W)     mul (8|M0)               acc0.0<1>:d   r2.0<1;1,0>:d     r9.0<0;1,0>:uw   {Compacted,I@2}
        add (16|M16)             r4.0<1>:d     r111.0<1;1,0>:d   -r4.0<1;1,0>:d   {Compacted,I@2}
        mach (8|M0)              r2.0<1>:d     r2.0<1;1,0>:d     r9.0<0;1,0>:d    {Compacted}
(W)     mul (8|M8)               acc0.0<1>:d   r3.0<1;1,0>:d     r9.0<0;1,0>:uw  
        mach (8|M8)              r3.0<1>:d     r3.0<1;1,0>:d     r9.0<0;1,0>:d    {Compacted}
(W)     mul (8|M16)              acc0.0<1>:d   r4.0<1;1,0>:d     r9.0<0;1,0>:uw   {I@4}
        mach (8|M16)             r4.0<1>:d     r4.0<1;1,0>:d     r9.0<0;1,0>:d    {Compacted}
(W)     mul (8|M24)              acc0.0<1>:d   r5.0<1;1,0>:d     r9.0<0;1,0>:uw  
        mach (8|M24)             r5.0<1>:d     r5.0<1;1,0>:d     r9.0<0;1,0>:d    {Compacted}
(W)     mul (8|M0)               acc0.0<1>:d   r117.0<1;1,0>:d   r8.8<0;1,0>:uw   {Compacted}
        mach (8|M0)              r6.0<1>:d     r117.0<1;1,0>:d   r8.4<0;1,0>:d    {Compacted}
(W)     mul (8|M8)               acc0.0<1>:d   r118.0<1;1,0>:d   r8.8<0;1,0>:uw  
        mach (8|M8)              r7.0<1>:d     r118.0<1;1,0>:d   r8.4<0;1,0>:d    {Compacted}
(W)     mul (8|M16)              acc0.0<1>:d   r119.0<1;1,0>:d   r8.8<0;1,0>:uw  
        mach (8|M16)             r10.0<1>:d    r119.0<1;1,0>:d   r8.4<0;1,0>:d    {Compacted}
(W)     mul (8|M24)              acc0.0<1>:d   r120.0<1;1,0>:d   r8.8<0;1,0>:uw  
        mach (8|M24)             r11.0<1>:d    r120.0<1;1,0>:d   r8.4<0;1,0>:d    {Compacted}
(W)     mul (8|M0)               acc0.0<1>:d   r117.0<1;1,0>:d   r8.12<0;1,0>:uw  {Compacted}
        mach (8|M0)              r12.0<1>:d    r117.0<1;1,0>:d   r8.6<0;1,0>:d    {Compacted}
(W)     mul (8|M8)               acc0.0<1>:d   r118.0<1;1,0>:d   r8.12<0;1,0>:uw 
        mach (8|M8)              r13.0<1>:d    r118.0<1;1,0>:d   r8.6<0;1,0>:d    {Compacted}
(W)     mul (8|M16)              acc0.0<1>:d   r119.0<1;1,0>:d   r8.12<0;1,0>:uw 
        mach (8|M16)             r14.0<1>:d    r119.0<1;1,0>:d   r8.6<0;1,0>:d    {Compacted}
(W)     mul (8|M24)              acc0.0<1>:d   r120.0<1;1,0>:d   r8.12<0;1,0>:uw 
        mach (8|M24)             r15.0<1>:d    r120.0<1;1,0>:d   r8.6<0;1,0>:d    {Compacted}
(W)     mov (1|M0)               a0.0<1>:ud    r9.7<0;1,0>:d                    {A@1}
        add (16|M0)              r6.0<1>:d     r113.0<1;1,0>:d   -r6.0<1;1,0>:d   {Compacted}
        add (16|M16)             r10.0<1>:d    r115.0<1;1,0>:d   -r10.0<1;1,0>:d  {Compacted,I@7}
        add (16|M0)              r12.0<1>:d    r12.0<1;1,0>:d    r9.5<0;1,0>:d    {Compacted,I@7}
        add (16|M16)             r14.0<1>:d    r14.0<1;1,0>:d    r9.5<0;1,0>:d    {Compacted,I@5}
        add3 (16|M0)             r6.0<1>:d     r12.0<1;0>:d      r2.0<1;0>:d       r6.0<1>:d        {I@2}
        add3 (16|M16)            r10.0<1>:d    r14.0<1;0>:d      r4.0<1;0>:d       r10.0<1>:d       {I@2}
        send.ugm (16|M0)         r16      r6      null:0  a0.0        0x24280900           {ExBSO,A@2,$7} // wr:2+0, rd:2; load.ugm.d8u32.a32.ca.ca.bss[a0.0]
        send.ugm (16|M16)        r18      r10     null:0  a0.0        0x24280900           {ExBSO,A@1,$8} // wr:2+0, rd:2; load.ugm.d8u32.a32.ca.ca.bss[a0.0]
        mov (16|M0)              r125.0<1>:b   r16.0<4;1,0>:b                   {$7.dst}
        mov (16|M16)             r126.0<1>:b   r18.0<4;1,0>:b                   {$8.dst}
        goto (32|M0)                         L5576                  L5640                
L5576:
        join (32|M0)                         L5640                                
L5592:
(W)     mov (1|M0)               r2.0<2>:b     0:w                              
        mov (16|M0)              r125.0<1>:b   r2.0<0;1,0>:b                    {I@1}
        mov (16|M16)             r126.0<1>:b   r2.0<0;1,0>:b                   
L5640:
        join (32|M0)                         L5656                                
L5656:
(W)     mov (1|M0)               a0.0<1>:ud    r9.6<0;1,0>:d                    {A@1}
        add (16|M0)              r2.0<1>:d     r85.0<1;1,0>:d    r9.4<0;1,0>:d    {Compacted}
        add (16|M16)             r4.0<1>:d     r87.0<1;1,0>:d    r9.4<0;1,0>:d    {Compacted}
        mov (16|M0)              r6.0<1>:ud    r125.0<1;1,0>:ub                 {I@6}
        mov (16|M16)             r8.0<1>:ud    r126.0<1;1,0>:ub                 {I@6}
(W)     mov (8|M0)               r127.0<1>:f   r84.0<1;1,0>:f                   {Compacted}
        send.ugm (16|M0)         null     r2      r6:2    a0.0        0x240E0904           {ExBSO,A@2,$9} // wr:2+2, rd:0; store.ugm.d8u32.a32.wb.wb.bss[a0.0]
        sync.nop                             null                             {Compacted,I@1}
        send.ugm (16|M16)        null     r4      r8:2    a0.0        0x240E0904           {ExBSO,$10} // wr:2+2, rd:0; store.ugm.d8u32.a32.wb.wb.bss[a0.0]
(W)     send.gtwy (1|M0)         null     r127    null:0  0x0            0x02000010           {EOT,A@1} // wr:1+0, rd:0; end of thread
L5784:
        nop                    
(W)     mov (16|M0)              null<1>:ud    0x6F9278B:ud                             
(W)     mov (16|M0)              null<1>:ud    0x6180031B:ud                             
(W)     mov (16|M0)              null<1>:ud    0x0:ud                             
(W)     mov (16|M0)              null<1>:ud    0x1A:ud                             
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
