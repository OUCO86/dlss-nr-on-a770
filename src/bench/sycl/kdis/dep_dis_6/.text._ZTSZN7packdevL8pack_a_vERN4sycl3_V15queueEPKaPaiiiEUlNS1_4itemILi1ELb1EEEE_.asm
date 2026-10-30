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
(W)     mov (8|M0)               r87.0<1>:ud   r0.0<1;1,0>:ud                  
(W)     or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x4C0:uw              {A@1}
        sync.nop                             null                             {Compacted,A@1}
        sync.nop                             null                             {Compacted,$2.dst}
(W)     addc (1|M0)              r88.0<1>:ud   r8.6<0;1,0>:ud    0x10:ud              {AccWrEn,A@1}
(W)     cmp (16|M0)   (gt)f1.0   null<1>:d     r8.2<0;1,0>:d     -1:w              
(W)     mov (1|M0)               r3.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted,$0.dst}
(W)     mul (1|M0)               acc0.0<1>:d   r7.3<0;1,0>:d     r87.2<0;1,0>:uw  {I@5}
(W)     cmp (16|M16)  (gt)f1.0   null<1>:d     r8.2<0;1,0>:d     -1:w              
(W)     mach (1|M0)              r4.0<1>:d     r7.3<0;1,0>:d     r87.1<0;1,0>:d  
(W)     asr (1|M0)               r88.2<1>:d    r8.2<0;1,0>:d     31:w              
        sync.nop                             null                             {Compacted,$1.dst}
        add3 (16|M0)             r5.0<1>:d     r4.0<0;0>:d       r1.0<1;0>:uw      r7.0<0>:d        {I@2}
        add3 (16|M16)            r10.0<1>:d    r4.0<0;0>:d       r2.0<1;0>:uw      r7.0<0>:d       
(W)     add (1|M0)               r88.1<1>:ud   r3.0<0;1,0>:ud    r8.7<0;1,0>:ud  
        shl (16|M0)              r89.0<1>:d    r5.0<1;1,0>:d     4:w               {Compacted,I@3}
        shr (16|M0)              r93.0<1>:ud   r5.0<1;1,0>:ud    8:w              
        shl (16|M16)             r91.0<1>:d    r10.0<1;1,0>:d    4:w               {Compacted,I@4}
        shr (16|M16)             r95.0<1>:ud   r10.0<1;1,0>:ud   8:w              
(f1.0)  goto (32|M0)                         L2648                  L2648                
L528:
(W)     shr (1|M0)               r2.0<1>:ud    r8.2<0;1,0>:ud    20:w              
(W)     asr (1|M0)               r3.0<1>:d     r8.2<0;1,0>:d     20:w               {Compacted}
(W)     mov (1|M0)               r6.0<1>:d     1044480:d                              
(W)     and (1|M0)               r9.4<1>:d     r8.2<0;1,0>:d     1048575:d              
(W)     bfn.0xF8 (1|M0)          r7.0<1>:ud    r3.0<0;0>:ud      r6.0<0;0>:d       r2.0<0>:ud       {I@2} // s0&s1|s2
(W)     shr (1|M0)               r4.0<1>:ud    r88.2<0;1,0>:ud   8:w              
(W)     mov (1|M0)               r11.0<1>:ud   0x49800000:ud                             
(W)     mov (1|M0)               r10.0<1>:f    r9.4<0;1,0>:ud                   {Compacted,I@4}
(W)     mov (1|M0)               r8.0<1>:f     r7.0<0;1,0>:ud                   {Compacted,I@3}
(W)     mov (1|M0)               r13.0<1>:ud   0x53800000:ud                             
(W)     mov (1|M0)               r5.0<1>:f     r4.0<0;1,0>:ud                   {Compacted,I@3}
(W)     mad (1|M0)               r12.0<1>:f    r10.0<0;0>:f      r11.0<0;0>:f      r8.0<0>:f        {Compacted,A@2}
(W)     mov (1|M0)               r16.0<1>:ud   0xB4E00000:ud                             
(W)     mad (1|M0)               r14.0<1>:f    r12.0<0;0>:f      r13.0<0;0>:f      r5.0<0>:f        {Compacted,A@1}
(W)     mov (1|M0)               r20.0<1>:ud   0x0:ud                             
        sync.nop                             null                             {Compacted,F@1}
(W)     math.inv (1|M0)          r15.0<1>:f    r14.0<0;1,0>:f                   {$3}
        sync.nop                             null                             {Compacted,$3.dst}
(W)     mad (1|M0)               r17.0<1>:f    r15.0<0;0>:f      r16.0<0;0>:f      r15.0<0>:f       {Compacted,I@2}
        shr (16|M0)              r24.0<1>:ud   r93.0<1;1,0>:ud   20:w              
(W)     mul (1|M0)               r18.0<1>:f    r17.0<0;1,0>:f    0.0:f               {Compacted,F@1}
        shr (16|M16)             r26.0<1>:ud   r95.0<1;1,0>:ud   20:w              
(W)     rndd (1|M0)              r19.0<1>:f    r18.0<0;1,0>:f                   {Compacted,F@1}
(W)     mul (1|M0)               r22.0<1>:f    r8.0<0;1,0>:f     -1.048576e+06:f               {Compacted}
(W)     mad (1|M0)               r21.0<1>:f    r20.0<0;0>:f      r19.0<0;0>:f      -r10.0<0>:f      {Compacted,A@2}
        mov (16|M0)              r28.0<1>:f    r24.0<1;1,0>:ud                  {Compacted,I@2}
        mov (16|M16)             r30.0<1>:f    r26.0<1;1,0>:ud                  {Compacted,I@1}
(W)     mad (1|M0)               r23.0<1>:f    r21.0<0;0>:f      r19.0<0;0>:f      r22.0<0>:f       {Compacted,F@3}
(W)     mul (1|M0)               r49.0<1>:f    r10.0<0;1,0>:f    9.536743e-07:f               {Compacted}
        mad (16|M0)              acc0.0<1>:f   r28.0<1;0>:f      r11.0<0;0>:f      r23.0<0>:f       {Compacted,F@2}
        mad (16|M16)             acc2.0<1>:f   r30.0<1;0>:f      r11.0<0;0>:f      r23.0<0>:f      
        mul (16|M0)              acc0.0<1>:f   r17.0<0;1,0>:f    acc0.0<1;1,0>:f 
        mul (16|M16)             acc2.0<1>:f   r17.0<0;1,0>:f    acc2.0<1;1,0>:f 
        rndd (16|M0)             r36.0<1>:f    acc0.0<1;1,0>:f                  {Compacted}
        rndd (16|M16)            r38.0<1>:f    acc2.0<1;1,0>:f                  {Compacted}
        mul (16|M0)              acc0.0<1>:f   r49.0<0;1,0>:f    r36.0<1;1,0>:f   {Compacted,F@2}
        mul (16|M16)             acc2.0<1>:f   r49.0<0;1,0>:f    r38.0<1;1,0>:f   {Compacted,F@2}
        rndd (16|M0)             acc0.0<1>:f   acc0.0<1;1,0>:f                 
        rndd (16|M16)            acc2.0<1>:f   acc2.0<1;1,0>:f                 
        and (16|M0)              r71.0<1>:d    r93.0<1;1,0>:d    1048575:d              
        and (16|M16)             r73.0<1>:d    r95.0<1;1,0>:d    1048575:d              
(W)     mul (1|M0)               r44.0<1>:f    r5.0<0;1,0>:f     -1.048576e+06:f               {Compacted}
        mad (16|M0)              r40.0<1>:f    r23.0<0;0>:f      r36.0<1;0>:f      -r8.0<0>:f       {Compacted}
        mad (16|M16)             r42.0<1>:f    r23.0<0;0>:f      r38.0<1;0>:f      -r8.0<0>:f       {Compacted}
        mad (16|M0)              r58.0<1>:f    -acc0.0<1;0>:f    r36.0<1;0>:f      r49.0<0>:f      
        mad (16|M16)             r60.0<1>:f    -acc2.0<1;0>:f    r38.0<1;0>:f      r49.0<0>:f      
(W)     mov (1|M0)               r62.0<1>:ud   0xBF800000:ud                             
        mov (16|M0)              r75.0<1>:f    r71.0<1;1,0>:ud                  {Compacted,I@3}
        mov (16|M16)             r77.0<1>:f    r73.0<1;1,0>:ud                  {Compacted,I@2}
        mad (16|M0)              r45.0<1>:f    r40.0<1;0>:f      r36.0<1;0>:f      r44.0<0>:f       {Compacted,F@6}
        mad (16|M16)             r47.0<1>:f    r42.0<1;0>:f      r38.0<1;0>:f      r44.0<0>:f       {Compacted,F@6}
        mad (16|M0)              r67.0<1>:f    r28.0<1;0>:f      r58.0<1;0>:f      -r11.0<0>:f      {Compacted,F@6}
        mad (16|M16)             r69.0<1>:f    r30.0<1;0>:f      r60.0<1;0>:f      -r11.0<0>:f      {Compacted,F@6}
        mad (16|M0)              r63.0<1>:f    r45.0<1;0>:f      acc0.0<1;0>:f     r62.0<0>:f       {Compacted,A@1}
        mad (16|M16)             r65.0<1>:f    r47.0<1;0>:f      acc2.0<1;0>:f     r62.0<0>:f       {Compacted,F@4}
        mad (16|M0)              acc0.0<1>:f   r75.0<1;0>:f      r67.0<1;0>:f      r11.0<0>:f       {Compacted,F@4}
        mad (16|M16)             acc2.0<1>:f   r77.0<1;0>:f      r69.0<1;0>:f      r11.0<0>:f       {F@4}
        mad (16|M0)              acc0.0<1>:f   acc0.0<1;0>:f     r63.0<1;0>:f      r13.0<0>:f       {Compacted,F@4}
        mad (16|M16)             acc2.0<1>:f   acc2.0<1;0>:f     r65.0<1;0>:f      r13.0<0>:f       {F@4}
        mul (16|M0)              acc0.0<1>:f   r17.0<0;1,0>:f    acc0.0<1;1,0>:f 
        mul (16|M16)             acc2.0<1>:f   r17.0<0;1,0>:f    acc2.0<1;1,0>:f 
        rndd (16|M0)             r2.0<1>:f     acc0.0<1;1,0>:f                  {Compacted}
        rndd (16|M16)            r6.0<1>:f     acc2.0<1;1,0>:f                  {Compacted}
(W)     mul (1|M0)               r44.0<1>:f    r8.0<0;1,0>:f     9.536743e-07:f               {Compacted}
        mul (16|M0)              acc0.0<1>:f   r49.0<0;1,0>:f    r2.0<1;1,0>:f    {Compacted,F@3}
        mul (16|M16)             acc2.0<1>:f   r49.0<0;1,0>:f    r6.0<1;1,0>:f    {Compacted,F@3}
        mul (16|M0)              r45.0<1>:f    r44.0<0;1,0>:f    r2.0<1;1,0>:f    {Compacted,F@3}
        rndd (16|M0)             acc0.0<1>:f   acc0.0<1;1,0>:f                 
        rndd (16|M16)            r26.0<1>:f    acc2.0<1;1,0>:f                  {Compacted}
        mul (16|M16)             r47.0<1>:f    r44.0<0;1,0>:f    r6.0<1;1,0>:f    {Compacted}
        mad (16|M0)              r28.0<1>:f    -acc0.0<1;0>:f    r2.0<1;0>:f       r49.0<0>:f      
        mad (16|M16)             r30.0<1>:f    -r26.0<1;0>:f     r6.0<1;0>:f       r49.0<0>:f       {Compacted,F@3}
        rndd (16|M0)             acc2.0<1>:f   r45.0<1;1,0>:f                  
        mad (16|M0)              r12.0<1>:f    r63.0<1;0>:f      r2.0<1;0>:f       -r5.0<0>:f       {Compacted}
        mad (16|M16)             r14.0<1>:f    r65.0<1;0>:f      r6.0<1;0>:f       -r5.0<0>:f       {Compacted}
        mad (16|M0)              r32.0<1>:f    r67.0<1;0>:f      acc0.0<1;0>:f     r62.0<0>:f       {Compacted}
        rndd (16|M16)            acc0.0<1>:f   r47.0<1;1,0>:f                   {F@7}
        mad (16|M0)              r53.0<1>:f    -acc2.0<1;0>:f    r2.0<1;0>:f       r44.0<0>:f      
        mad (16|M16)             r34.0<1>:f    r69.0<1;0>:f      r26.0<1;0>:f      r62.0<0>:f       {Compacted}
        mad (16|M0)              acc2.0<1>:f   r12.0<1;0>:f      acc2.0<1;0>:f     r62.0<0>:f       {Compacted,F@6}
        mad (16|M16)             r59.0<1>:f    r14.0<1;0>:f      acc0.0<1;0>:f     r62.0<0>:f       {Compacted,F@6}
        mad (16|M0)              r61.0<1>:f    r32.0<1;0>:f      r53.0<1;0>:f      -r11.0<0>:f      {Compacted,F@4}
        mad (16|M0)              r40.0<1>:f    r75.0<1;0>:f      r28.0<1;0>:f      -r11.0<0>:f      {Compacted}
        mad (16|M16)             r55.0<1>:f    -acc0.0<1;0>:f    r6.0<1;0>:f       r44.0<0>:f      
        mad (16|M0)              r74.0<1>:f    r61.0<1;0>:f      acc2.0<1;0>:f     r11.0<0>:f       {Compacted,F@3}
        mad (16|M16)             r42.0<1>:f    r77.0<1;0>:f      r30.0<1;0>:f      -r11.0<0>:f      {Compacted}
        mad (16|M16)             r63.0<1>:f    r34.0<1;0>:f      r55.0<1;0>:f      -r11.0<0>:f      {Compacted,F@3}
        mad (16|M0)              acc0.0<1>:f   r40.0<1;0>:f      r74.0<1;0>:f      r11.0<0>:f       {Compacted,F@3}
        mad (16|M16)             r76.0<1>:f    r63.0<1;0>:f      r59.0<1;0>:f      r11.0<0>:f       {Compacted,F@2}
        mul (16|M0)              acc0.0<1>:f   r17.0<0;1,0>:f    acc0.0<1;1,0>:f 
        mad (16|M16)             r80.0<1>:f    r42.0<1;0>:f      r76.0<1;0>:f      r11.0<0>:f       {Compacted,F@2}
        rndd (16|M0)             r82.0<1>:f    acc0.0<1;1,0>:f                  {Compacted}
        mov (16|M0)              r70.0<1>:d    r2.0<1;1,0>:f                    {Compacted}
        mul (16|M16)             acc0.0<1>:f   r17.0<0;1,0>:f    r80.0<1;1,0>:f   {Compacted,F@2}
        mad (16|M0)              acc2.0<1>:f   acc2.0<1;0>:f     -r82.0<1;0>:f     r5.0<0>:f        {F@2}
        rndd (16|M16)            r84.0<1>:f    acc0.0<1;1,0>:f                  {Compacted}
        mul (16|M0)              acc0.0<1>:f   acc2.0<1;1,0>:f   0x2F800000:f               {Compacted}
        mov (16|M16)             r72.0<1>:d    r6.0<1;1,0>:f                    {Compacted}
(W)     mov (1|M0)               r55.0<1>:ud   0xCF800000:ud                             
        rndz (16|M0)             r51.0<1>:f    acc0.0<1;1,0>:f                  {Compacted}
        mad (16|M16)             r6.0<1>:f     r59.0<1;0>:f      -r84.0<1;0>:f     r5.0<0>:f        {Compacted,A@2}
        mad (16|M0)              r15.0<1>:f    r40.0<1;0>:f      -r82.0<1;0>:f     r10.0<0>:f       {Compacted}
        mad (16|M0)              r56.0<1>:f    acc2.0<1;0>:f     r51.0<1;0>:f      r55.0<0>:f       {Compacted,A@1}
        mul (16|M16)             acc2.0<1>:f   r6.0<1;1,0>:f     0x2F800000:f               {Compacted,F@3}
        mad (16|M0)              r11.0<1>:f    r61.0<1;0>:f      -r82.0<1;0>:f     r8.0<0>:f        {Compacted}
        mov (16|M0)              r27.0<1>:d    r15.0<1;1,0>:f                   {Compacted,F@4}
        rndz (16|M16)            acc2.0<1>:f   acc2.0<1;1,0>:f                 
        mov (16|M0)              r60.0<1>:ud   r56.0<1;1,0>:f                   {A@2}
        mad (16|M16)             r17.0<1>:f    r42.0<1;0>:f      -r84.0<1;0>:f     r10.0<0>:f       {Compacted}
        addc (8|M0)              r74.0<1>:ud   r27.0<1;1,0>:ud   0x0:ud              {AccWrEn,Compacted,I@2}
        mad (16|M16)             r58.0<1>:f    r6.0<1;0>:f       acc2.0<1;0>:f     r55.0<0>:f       {Compacted}
        shl (16|M0)              r60.0<1>:d    r60.0<1;1,0>:d    8:w               {Compacted,I@2}
        asr (16|M0)              r43.0<1>:d    r27.0<1;1,0>:d    31:w               {Compacted,F@2}
        mad (16|M16)             r13.0<1>:f    r63.0<1;0>:f      -r84.0<1;0>:f     r8.0<0>:f        {Compacted}
        mov (16|M0)              r23.0<1>:d    r11.0<1;1,0>:f                   {Compacted}
        mov (16|M16)             r29.0<1>:d    r17.0<1;1,0>:f                   {Compacted}
        add3 (8|M0)              r76.0<1>:ud   acc0.0<1;0>:ud    r60.0<1;0>:ud     r43.0<1>:ud      {I@3}
        mov (16|M16)             r62.0<1>:ud   r58.0<1;1,0>:f                   {A@1}
        addc (8|M8)              r75.0<1>:ud   r28.0<1;1,0>:ud   0x0:ud              {AccWrEn}
        asr (16|M0)              r31.0<1>:d    r23.0<1;1,0>:d    31:w               {Compacted,I@5}
        asr (16|M16)             r45.0<1>:d    r29.0<1;1,0>:d    31:w               {Compacted,I@5}
        shl (16|M16)             r62.0<1>:d    r62.0<1;1,0>:d    8:w               {Compacted,I@4}
        add3 (8|M8)              r77.0<1>:ud   acc0.0<1;0>:ud    r61.0<1;0>:ud     r44.0<1>:ud     
        addc (8|M16)             r78.0<1>:ud   r29.0<1;1,0>:ud   0x0:ud              {AccWrEn}
        mov (16|M0)              r66.0<1>:d    r36.0<1;1,0>:f                   {Compacted}
        mov (16|M16)             r25.0<1>:d    r13.0<1;1,0>:f                   {Compacted}
        shl (16|M0)              r31.0<1>:d    r31.0<1;1,0>:d    20:w               {Compacted,I@7}
        add3 (8|M16)             r80.0<1>:ud   acc0.0<1;0>:ud    r62.0<1;0>:ud     r45.0<1>:ud      {I@6}
        shl (16|M0)              r35.0<1>:d    r23.0<1;1,0>:d    20:w               {Compacted}
        addc (8|M24)             r79.0<1>:ud   r30.0<1;1,0>:ud   0x0:ud              {AccWrEn}
        shr (16|M0)              r23.0<1>:ud   r23.0<1;1,0>:ud   12:w              
(W)     mov (1|M0)               r65.0<1>:d    r19.0<0;1,0>:f                   {Compacted}
        mov (16|M16)             r68.0<1>:d    r38.0<1;1,0>:f                   {Compacted}
        asr (16|M16)             r33.0<1>:d    r25.0<1;1,0>:d    31:w               {Compacted,I@7}
        add3 (8|M24)             r81.0<1>:ud   acc0.0<1;0>:ud    r63.0<1;0>:ud     r46.0<1>:ud     
        mov (16|M0)              r19.0<1>:d    r82.0<1;1,0>:f                   {Compacted}
        or (16|M0)               r39.0<1>:d    r31.0<1;1,0>:d    r23.0<1;1,0>:d   {Compacted,I@6}
        addc (8|M0)              r82.0<1>:ud   r74.0<1;1,0>:ud   r35.0<1;1,0>:ud  {AccWrEn,Compacted}
        mov (16|M16)             r21.0<1>:d    r84.0<1;1,0>:f                   {Compacted}
        shl (16|M16)             r37.0<1>:d    r25.0<1;1,0>:d    20:w               {Compacted}
        shl (16|M16)             r33.0<1>:d    r33.0<1;1,0>:d    20:w               {Compacted,I@7}
        add3 (8|M0)              r84.0<1>:ud   acc0.0<1;0>:ud    r76.0<1;0>:ud     r39.0<1>:ud      {I@5}
        shr (16|M16)             r25.0<1>:ud   r25.0<1;1,0>:ud   12:w              
        addc (8|M8)              r83.0<1>:ud   r75.0<1;1,0>:ud   r36.0<1;1,0>:ud  {AccWrEn}
        or (16|M16)              r41.0<1>:d    r33.0<1;1,0>:d    r25.0<1;1,0>:d   {Compacted,I@2}
        add3 (8|M8)              r85.0<1>:ud   acc0.0<1;0>:ud    r77.0<1;0>:ud     r40.0<1>:ud     
        cmp (16|M0)   (ge)f0.0   null<1>:d     r82.0<1;1,0>:ud   r8.2<0;1,0>:ud   {I@3}
        addc (8|M16)             r2.0<1>:ud    r78.0<1;1,0>:ud   r37.0<1;1,0>:ud  {AccWrEn}
        shl (16|M0)              r10.0<1>:d    r66.0<1;1,0>:d    20:w               {Compacted}
        add3 (8|M16)             r4.0<1>:ud    acc0.0<1;0>:ud    r80.0<1;0>:ud     r41.0<1>:ud      {I@5}
        addc (8|M24)             r3.0<1>:ud    r79.0<1;1,0>:ud   r38.0<1;1,0>:ud  {AccWrEn}
(f0.0)  cmp (16|M0)   (eq)f0.0   null<1>:d     r84.0<1;1,0>:d    r88.2<0;1,0>:d   {I@6}
        cmp (16|M16)  (ge)f0.0   null<1>:d     r2.0<1;1,0>:ud    r8.2<0;1,0>:ud   {I@2}
        add3 (8|M24)             r5.0<1>:ud    acc0.0<1;0>:ud    r81.0<1;0>:ud     r42.0<1>:ud     
        shr (16|M0)              r14.0<1>:ud   r66.0<1;1,0>:ud   12:w              
(W)     shl (1|M0)               r6.0<1>:d     r65.0<0;1,0>:d    8:w               {Compacted}
(~f0.0) cmp (16|M0)   (gt)f0.0   null<1>:d     r84.0<1;1,0>:ud   r88.2<0;1,0>:ud 
        addc (8|M0)              r23.0<1>:ud   r10.0<1;1,0>:ud   0x0:ud              {AccWrEn,Compacted}
(f0.0)  cmp (16|M16)  (eq)f0.0   null<1>:d     r4.0<1;1,0>:d     r88.2<0;1,0>:d   {I@5}
        shl (16|M16)             r12.0<1>:d    r68.0<1;1,0>:d    20:w               {Compacted}
(W)     mov (1|M0)               r31.0<1>:w    -1:w                              
        add3 (8|M0)              r25.0<1>:ud   acc0.0<1;0>:ud    r14.0<1;0>:ud     r6.0<0>:ud       {I@6}
        addc (8|M8)              r24.0<1>:ud   r11.0<1;1,0>:ud   0x0:ud              {AccWrEn}
        shr (16|M16)             r16.0<1>:ud   r68.0<1;1,0>:ud   12:w              
(~f0.0) cmp (16|M16)  (gt)f0.0   null<1>:d     r4.0<1;1,0>:ud    r88.2<0;1,0>:ud 
(f0.0)  sel (16|M0)              r32.0<1>:d    r31.0<0;1,0>:w    0:w               {I@5}
        add3 (8|M8)              r26.0<1>:ud   acc0.0<1;0>:ud    r15.0<1;0>:ud     r6.0<0>:ud      
        addc (8|M16)             r27.0<1>:ud   r12.0<1;1,0>:ud   0x0:ud              {AccWrEn}
        add3 (16|M0)             r36.0<1>:d    r19.0<1;0>:d      r70.0<1;0>:d      -r32.0<1>:d      {I@3}
        add3 (8|M16)             r29.0<1>:ud   acc0.0<1;0>:ud    r16.0<1;0>:ud     r6.0<0>:ud      
        addc (8|M24)             r28.0<1>:ud   r13.0<1;1,0>:ud   0x0:ud              {AccWrEn}
(f0.0)  sel (16|M16)             r34.0<1>:d    r31.0<0;1,0>:w    0:w              
        add3 (8|M24)             r30.0<1>:ud   acc0.0<1;0>:ud    r17.0<1;0>:ud     r6.0<0>:ud      
        addc (8|M0)              r97.0<1>:ud   r23.0<1;1,0>:ud   r36.0<1;1,0>:ud  {AccWrEn,Compacted,I@5}
        add3 (16|M16)            r38.0<1>:d    r21.0<1;0>:d      r72.0<1;0>:d      -r34.0<1>:d      {I@3}
        add (8|M0)               r101.0<1>:ud  acc0.0<1;1,0>:ud  r25.0<1;1,0>:ud 
        addc (8|M8)              r98.0<1>:ud   r24.0<1;1,0>:ud   r37.0<1;1,0>:ud  {AccWrEn}
        add (8|M8)               r102.0<1>:ud  acc0.0<1;1,0>:ud  r26.0<1;1,0>:ud 
        addc (8|M16)             r99.0<1>:ud   r27.0<1;1,0>:ud   r38.0<1;1,0>:ud  {AccWrEn,I@4}
        add (8|M16)              r103.0<1>:ud  acc0.0<1;1,0>:ud  r29.0<1;1,0>:ud 
        addc (8|M24)             r100.0<1>:ud  r28.0<1;1,0>:ud   r39.0<1;1,0>:ud  {AccWrEn}
        add (8|M24)              r104.0<1>:ud  acc0.0<1;1,0>:ud  r30.0<1;1,0>:ud 
        goto (32|M0)                         L2648                  L3408                
L2648:
        join (32|M0)                         L3408                                
L2664:
(W)     cmp (16|M0)   (eq)f0.0   null<1>:d     r8.2<0;1,0>:d     0:w               {Compacted}
(W)     cmp (16|M16)  (eq)f0.0   null<1>:d     r8.2<0;1,0>:d     0:w              
(f0.0)  goto (32|M0)                         L3312                  L3312                
L2704:
(W)     xor (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x30:uw              {A@1}
(W)     mov (1|M0)               r2.0<1>:f     r8.2<0;1,0>:ud                   {Compacted,A@1}
(W)     mov (1|M0)               r13.0<1>:f    0xB4C00000:f                               {Compacted}
(W)     math.inv (1|M0)          r12.0<1>:f    r2.0<0;1,0>:f                    {@2,$4}
        mov (16|M0)              r5.0<1>:f     r93.0<1;1,0>:ud                  {Compacted}
        sync.nop                             null                             {Compacted,$4.dst}
(W)     mad (1|M0)               r14.0<1>:f    r12.0<0;0>:f      r13.0<0;0>:f      r12.0<0>:f       {Compacted,F@2}
        mov (16|M16)             r10.0<1>:f    r95.0<1;1,0>:ud                  {Compacted}
(W)     mov (1|M0)               r3.0<1>:ud    r2.0<0;1,0>:f                   
        mov (16|M0)              r19.0<1>:ud   r5.0<1;1,0>:f                    {F@3}
        mul (16|M0)              r15.0<1>:f    r5.0<1;1,0>:f     r14.0<0;1,0>:f   {Compacted,F@2}
        mul (16|M16)             r17.0<1>:f    r10.0<1;1,0>:f    r14.0<0;1,0>:f   {Compacted,F@2}
        mov (16|M16)             r21.0<1>:ud   r10.0<1;1,0>:f                  
(W)     add (1|M0)               r4.0<1>:d     r8.2<0;1,0>:d     -r3.0<0;1,0>:d   {Compacted,I@3}
        add (16|M0)              r19.0<1>:d    r93.0<1;1,0>:d    -r19.0<1;1,0>:d  {Compacted,I@3}
        mov (16|M0)              r23.0<1>:ud   r15.0<1;1,0>:f                   {F@2}
        mov (16|M16)             r25.0<1>:ud   r17.0<1;1,0>:f                   {F@1}
        add (16|M16)             r21.0<1>:d    r95.0<1;1,0>:d    -r21.0<1;1,0>:d  {Compacted,I@5}
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
        add (16|M0)              r56.0<1>:d    r93.0<1;1,0>:d    -r56.0<1;1,0>:d  {Compacted,I@5}
        add (16|M16)             r58.0<1>:d    r95.0<1;1,0>:d    -r58.0<1;1,0>:d  {Compacted,I@2}
        cmp (16|M0)   (ge)f1.0   r60.0<1>:ud   r56.0<1;1,0>:ud   r8.2<0;1,0>:ud   {I@2}
        cmp (16|M16)  (ge)f0.0   r62.0<1>:ud   r58.0<1;1,0>:ud   r8.2<0;1,0>:ud   {I@2}
        add3 (16|M0)             r97.0<1>:d    r52.0<1;0>:d      r23.0<1;0>:d      -r60.0<1>:d      {I@2}
        add3 (16|M16)            r99.0<1>:d    r54.0<1;0>:d      r25.0<1;0>:d      -r62.0<1>:d      {I@2}
        goto (32|M0)                         L3312                  L3360                
L3312:
        join (32|M0)                         L3360                                
L3328:
        mov (16|M0)              r97.0<1>:d    -1:w                              
        mov (16|M16)             r99.0<1>:d    -1:w                              
L3360:
        join (32|M0)                         L3408                                
L3376:
        mov (16|M0)              r101.0<1>:d   0:w                              
        mov (16|M16)             r103.0<1>:d   0:w                              
L3408:
        join (32|M0)                         L3424                                
L3424:
        shr (16|M0)              r2.0<1>:ud    r89.0<1;1,0>:ud   5:w              
        shr (16|M16)             r4.0<1>:ud    r91.0<1;1,0>:ud   5:w              
        shl (16|M0)              r6.0<1>:d     r97.0<1;1,0>:d    7:w               {Compacted,I@7}
        shl (16|M16)             r10.0<1>:d    r99.0<1;1,0>:d    7:w               {Compacted,I@7}
(W)     mov (1|M0)               r12.0<1>:d    127:w                              
        bfn.0xEA (16|M0)         r105.0<1>:ud  r6.0<1;0>:ud      r2.0<1;0>:ud      r12.0<0>:ud      {I@1} // s0|s1&s2
        bfn.0xEA (16|M16)        r107.0<1>:ud  r10.0<1;0>:ud     r4.0<1;0>:ud      r12.0<0>:ud      // s0|s1&s2
        cmp (16|M0)   (lt)f1.0   null<1>:d     r105.0<1;1,0>:d   r8.3<0;1,0>:d    {I@2}
        cmp (16|M16)  (lt)f1.0   null<1>:d     r107.0<1;1,0>:d   r8.3<0;1,0>:d    {I@2}
(f1.0)  goto (32|M0)                         L3736                  L3736                
L3568:
(W)     mov (1|M0)               r2.0<2>:f     r88.0<0;1,0>:f                   {Compacted}
(W)     mov (1|M0)               r2.1<2>:f     r88.1<0;1,0>:f                   {Compacted}
(W)     mov (2|M0)               r4.0<1>:f     r2.0<1;1,0>:f                    {Compacted,F@1}
(W)     send.ugm (1|M0)          r5       r4      null:0  0x0            0x0218B580           {A@1,$5} // wr:1+0, rd:1; load.ugm.d32x4t.a64.ca.ca
        mov (16|M0)              r109.0<1>:f   r5.0<0;1,0>:f                    {Compacted,$5.dst}
        mov (16|M0)              r111.0<1>:d   r5.1<0;1,0>:d                   
        mov (16|M0)              r113.0<1>:d   r5.2<0;1,0>:d                   
        mov (16|M0)              r115.0<1>:d   r5.3<0;1,0>:d                   
        mov (16|M16)             r117.0<1>:f   r5.0<0;1,0>:f                    {Compacted}
        mov (16|M16)             r119.0<1>:d   r5.1<0;1,0>:d                   
        mov (16|M16)             r121.0<1>:d   r5.2<0;1,0>:d                   
        mov (16|M16)             r123.0<1>:d   r5.3<0;1,0>:d                   
        goto (32|M0)                         L3736                  L4424                
L3736:
        join (32|M0)                         L4424                                
L3752:
        mul (8|M0)               acc0.0<1>:ud  r97.0<1;1,0>:ud   r8.4<0;1,0>:uw  
        mach (8|M0)              r2.0<1>:ud    r97.0<1;1,0>:ud   r8.2<0;1,0>:ud   {AccWrEn,Compacted}
        and (16|M0)              r28.0<1>:d    r89.0<1;1,0>:d    16:w               {Compacted}
        mov (8|M0)               r4.0<1>:ud    acc0.0<1;1,0>:ud                 {Compacted}
        mul (8|M8)               acc0.0<1>:ud  r98.0<1;1,0>:ud   r8.4<0;1,0>:uw  
        mach (8|M8)              r3.0<1>:ud    r98.0<1;1,0>:ud   r8.2<0;1,0>:ud   {AccWrEn}
        and (16|M16)             r30.0<1>:d    r91.0<1;1,0>:d    16:w               {Compacted}
        mov (8|M8)               r5.0<1>:ud    acc0.0<1;1,0>:ud                 {Compacted,F@1}
(W)     mul (8|M0)               acc0.0<1>:d   r97.0<1;1,0>:ud   r88.4<0;1,0>:uw 
        mach (8|M0)              r6.0<1>:d     r97.0<1;1,0>:ud   r88.2<0;1,0>:d  
(W)     mul (8|M8)               acc0.0<1>:d   r98.0<1;1,0>:ud   r88.4<0;1,0>:uw 
        mach (8|M8)              r7.0<1>:d     r98.0<1;1,0>:ud   r88.2<0;1,0>:d  
(W)     mul (8|M0)               acc0.0<1>:d   r8.2<0;1,0>:ud    r101.0<2;1,0>:uw
        add (16|M0)              r10.0<1>:d    r2.0<1;1,0>:d     r6.0<1;1,0>:d    {Compacted,I@2}
        mach (8|M0)              r6.0<1>:d     r8.2<0;1,0>:ud    r101.0<1;1,0>:d 
(W)     mul (8|M8)               acc0.0<1>:d   r8.2<0;1,0>:ud    r102.0<2;1,0>:uw
        mach (8|M8)              r7.0<1>:d     r8.2<0;1,0>:ud    r102.0<1;1,0>:d 
        mul (8|M16)              acc0.0<1>:ud  r99.0<1;1,0>:ud   r8.4<0;1,0>:uw  
        mach (8|M16)             r12.0<1>:ud   r99.0<1;1,0>:ud   r8.2<0;1,0>:ud   {AccWrEn}
        add (16|M0)              r24.0<1>:d    r93.0<1;1,0>:d    -r4.0<1;1,0>:d   {Compacted}
        mov (8|M16)              r14.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mul (8|M24)              acc0.0<1>:ud  r100.0<1;1,0>:ud  r8.4<0;1,0>:uw  
        mach (8|M24)             r13.0<1>:ud   r100.0<1;1,0>:ud  r8.2<0;1,0>:ud   {AccWrEn}
(W)     mov (1|M0)               a0.0<1>:ud    r9.2<0;1,0>:d                    {A@1}
        mov (8|M24)              r15.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
(W)     mul (8|M16)              acc0.0<1>:d   r99.0<1;1,0>:ud   r88.4<0;1,0>:uw 
        mach (8|M16)             r16.0<1>:d    r99.0<1;1,0>:ud   r88.2<0;1,0>:d  
(W)     mul (8|M24)              acc0.0<1>:d   r100.0<1;1,0>:ud  r88.4<0;1,0>:uw 
        mach (8|M24)             r17.0<1>:d    r100.0<1;1,0>:ud  r88.2<0;1,0>:d  
(W)     mul (8|M16)              acc0.0<1>:d   r8.2<0;1,0>:ud    r103.0<2;1,0>:uw
        add (16|M16)             r18.0<1>:d    r12.0<1;1,0>:d    r16.0<1;1,0>:d   {Compacted,I@2}
        mach (8|M16)             r16.0<1>:d    r8.2<0;1,0>:ud    r103.0<1;1,0>:d 
(W)     mul (8|M24)              acc0.0<1>:d   r8.2<0;1,0>:ud    r104.0<2;1,0>:uw
        mach (8|M24)             r17.0<1>:d    r8.2<0;1,0>:ud    r104.0<1;1,0>:d 
(W)     mul (8|M0)               acc0.0<1>:d   r105.0<1;1,0>:d   r8.8<0;1,0>:uw   {Compacted}
        mach (8|M0)              r20.0<1>:d    r105.0<1;1,0>:d   r8.4<0;1,0>:d    {Compacted}
(W)     mul (8|M8)               acc0.0<1>:d   r106.0<1;1,0>:d   r8.8<0;1,0>:uw  
        mach (8|M8)              r21.0<1>:d    r106.0<1;1,0>:d   r8.4<0;1,0>:d    {Compacted}
(W)     mul (8|M16)              acc0.0<1>:d   r107.0<1;1,0>:d   r8.8<0;1,0>:uw  
        mach (8|M16)             r22.0<1>:d    r107.0<1;1,0>:d   r8.4<0;1,0>:d    {Compacted}
(W)     mul (8|M24)              acc0.0<1>:d   r108.0<1;1,0>:d   r8.8<0;1,0>:uw  
        add (16|M16)             r26.0<1>:d    r95.0<1;1,0>:d    -r14.0<1;1,0>:d  {Compacted}
        mach (8|M24)             r23.0<1>:d    r108.0<1;1,0>:d   r8.4<0;1,0>:d    {Compacted}
        shl (16|M0)              r24.0<1>:d    r24.0<1;1,0>:d    5:w               {Compacted}
        add (16|M0)              r20.0<1>:d    r20.0<1;1,0>:d    r9.0<0;1,0>:d    {Compacted,I@7}
        shl (16|M16)             r26.0<1>:d    r26.0<1;1,0>:d    5:w               {Compacted,I@4}
        add (16|M16)             r22.0<1>:d    r22.0<1;1,0>:d    r9.0<0;1,0>:d    {Compacted,I@4}
        add3 (16|M0)             r28.0<1>:d    r20.0<1;0>:d      r24.0<1;0>:d      r28.0<1>:d       {I@3}
        add3 (16|M16)            r30.0<1>:d    r22.0<1;0>:d      r26.0<1;0>:d      r30.0<1>:d       {I@2}
        send.ugm (16|M0)         r109     r28     null:0  a0.0        0x24883500           {ExBSO,A@2,$6} // wr:2+0, rd:8; load.ugm.d32x4.a32.ca.ca.bss[a0.0]
        send.ugm (16|M16)        r117     r30     null:0  a0.0        0x24883500           {ExBSO,A@1,$7} // wr:2+0, rd:8; load.ugm.d32x4.a32.ca.ca.bss[a0.0]
        add (16|M0)              r32.0<1>:d    r10.0<1;1,0>:d    r6.0<1;1,0>:d    {Compacted}
        add (16|M16)             r34.0<1>:d    r18.0<1;1,0>:d    r16.0<1;1,0>:d   {Compacted}
L4424:
        join (32|M0)                         L4440                                
L4440:
(W)     mov (1|M0)               a0.0<1>:ud    r9.3<0;1,0>:d                    {A@1}
        add (16|M0)              r2.0<1>:d     r89.0<1;1,0>:d    r9.1<0;1,0>:d    {Compacted}
        add (16|M16)             r4.0<1>:d     r91.0<1;1,0>:d    r9.1<0;1,0>:d    {Compacted}
(W)     mov (8|M0)               r127.0<1>:f   r87.0<1;1,0>:f                   {Compacted}
        send.ugm (16|M0)         null     r2      r109:8  a0.0        0x240E3504           {ExBSO,A@2,$6} // wr:2+8, rd:0; store.ugm.d32x4.a32.wb.wb.bss[a0.0]
        sync.nop                             null                             {Compacted,I@1}
        send.ugm (16|M16)        null     r4      r117:8  a0.0        0x240E3504           {ExBSO,$7} // wr:2+8, rd:0; store.ugm.d32x4.a32.wb.wb.bss[a0.0]
(W)     send.gtwy (1|M0)         null     r127    null:0  0x0            0x02000010           {EOT,A@1} // wr:1+0, rd:0; end of thread
L4536:
        nop                    
(W)     mov (16|M0)              null<1>:ud    0x6F9278B:ud                             
(W)     mov (16|M0)              null<1>:ud    0x6180031B:ud                             
(W)     mov (16|M0)              null<1>:ud    0x0:ud                             
(W)     mov (16|M0)              null<1>:ud    0xA:ud                             
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
