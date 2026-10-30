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
(W)     mov (8|M0)               r64.0<1>:ud   r0.0<1;1,0>:ud                  
(W)     or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x4C0:uw              {A@1}
        sync.nop                             null                             {Compacted,A@1}
        sync.allwr                           ($1,$2)                
(W)     cmp (1|M0)    (lt)f1.0   r6.1<1>:d     r8.2<0;1,0>:d     0:w               {A@1}
(W)     add (1|M0)               r6.0<1>:d     r8.2<0;1,0>:d     7:w               {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r7.3<0;1,0>:d     r64.2<0;1,0>:uw  {I@4}
(W)     mach (1|M0)              r3.0<1>:d     r7.3<0;1,0>:d     r64.1<0;1,0>:d   {$0.dst}
(W)     bfn.0xD8 (1|M0)          r65.2<1>:ud   r6.1<0;0>:ud      r6.0<0;0>:ud      r8.2<0>:ud       {I@3} // s0&s1|~s0&s2
        add3 (16|M0)             r66.0<1>:d    r3.0<0;0>:d       r1.0<1;0>:uw      r7.0<0>:d        {I@2}
        add3 (16|M16)            r68.0<1>:d    r3.0<0;0>:d       r2.0<1;0>:uw      r7.0<0>:d       
(W)     cmp (16|M0)   (gt)f1.0   null<1>:d     r65.2<0;1,0>:d    -1:w               {I@3}
(W)     cmp (16|M16)  (gt)f1.0   null<1>:d     r65.2<0;1,0>:d    -1:w              
(W)     asr (1|M0)               r65.3<1>:d    r65.2<0;1,0>:d    3:w              
        shr (16|M0)              r4.0<1>:ud    r66.0<1;1,0>:ud   2:w               {I@5}
        shr (16|M16)             r10.0<1>:ud   r68.0<1;1,0>:ud   2:w               {I@5}
(W)     mov (2|M0)               r65.0<1>:d    r8.4<1;1,0>:d                   
(W)     mov (1|M0)               r65.5<1>:f    0xCF800000:f                               {Compacted}
(W)     mov (1|M0)               r65.6<1>:f    1.048576e+06:f                               {Compacted}
(W)     mov (1|M0)               r65.7<1>:f    -1.048576e+06:f                               {Compacted}
(W)     mov (1|M0)               r82.0<1>:f    -1.0:f                               {Compacted}
(W)     mov (1|M0)               r82.1<1>:f    0x53800000:f                               {Compacted}
(W)     mov (1|M0)               r82.2<1>:f    1.463628e-39:f                              
(W)     mov (1|M0)               r82.3<1>:f    -4.172325e-07:f                               {Compacted}
        and (16|M0)              r70.0<1>:d    r66.0<1;1,0>:d    3:w               {Compacted}
        shr (16|M0)              r78.0<1>:ud   r66.0<1;1,0>:ud   8:w              
        and (16|M16)             r72.0<1>:d    r68.0<1;1,0>:d    3:w               {Compacted}
        shr (16|M16)             r80.0<1>:ud   r68.0<1;1,0>:ud   8:w              
(W)     asr (1|M0)               r65.4<1>:d    r65.3<0;1,0>:d    31:w               {I@7}
        and (16|M0)              r74.0<1>:d    r4.0<1;1,0>:d     7:w               {Compacted,I@7}
        and (16|M16)             r76.0<1>:d    r10.0<1;1,0>:d    7:w               {Compacted,I@7}
(f1.0)  goto (32|M0)                         L2760                  L2760                
L672:
(W)     shr (1|M0)               r2.0<1>:ud    r65.3<0;1,0>:ud   20:w              
(W)     asr (1|M0)               r2.1<1>:d     r65.2<0;1,0>:d    23:w              
(W)     and (1|M0)               r4.1<1>:d     r65.3<0;1,0>:d    1048575:d              
(W)     bfn.0xF8 (1|M0)          r3.1<1>:ud    r2.1<0;0>:ud      r82.2<0;0>:ud     r2.0<0>:ud       {A@2} // s0&s1|s2
(W)     shr (1|M0)               r2.2<1>:ud    r65.4<0;1,0>:ud   8:w              
(W)     mov (1|M0)               r5.0<1>:f     r4.1<0;1,0>:ud                   {Compacted,I@3}
(W)     mov (1|M0)               r4.0<1>:f     r3.1<0;1,0>:ud                   {Compacted,I@2}
(W)     mov (1|M0)               r3.0<1>:f     r2.2<0;1,0>:ud                   {Compacted,I@1}
(W)     mad (1|M0)               r5.1<1>:f     r5.0<0;0>:f       r65.6<0;0>:f      r4.0<0>:f        {F@2}
(W)     mov (1|M0)               r9.1<1>:ud    0x0:ud                             
(W)     mad (1|M0)               r6.0<1>:f     r5.1<0;0>:f       r82.1<0;0>:f      r3.0<0>:f        {F@1}
        shr (16|M0)              r12.0<1>:ud   r78.0<1;1,0>:ud   20:w              
        sync.nop                             null                             {Compacted,F@1}
(W)     math.inv (1|M0)          r7.0<1>:f     r6.0<0;1,0>:f                    {$3}
(W)     mad (1|M0)               r8.0<1>:f     r7.0<0;0>:f       r82.3<0;0>:f      r7.0<0>:f        {Compacted,$3.dst}
(W)     mul (1|M0)               r2.0<1>:f     r4.0<0;1,0>:f     -1.048576e+06:f               {Compacted}
(W)     mul (1|M0)               r8.1<1>:f     r8.0<0;1,0>:f     0.0:f               {Compacted,F@2}
        shr (16|M16)             r14.0<1>:ud   r80.0<1;1,0>:ud   20:w              
(W)     rndd (1|M0)              r9.0<1>:f     r8.1<0;1,0>:f                    {Compacted,F@1}
        mov (16|M0)              r16.0<1>:f    r12.0<1;1,0>:ud                  {Compacted,I@2}
(W)     mad (1|M0)               r10.0<1>:f    r9.1<0;0>:f       r9.0<0;0>:f       -r5.0<0>:f       {Compacted,F@2}
        mov (16|M16)             r18.0<1>:f    r14.0<1;1,0>:ud                  {Compacted,I@1}
(W)     mad (1|M0)               r3.1<1>:f     r10.0<0;0>:f      r9.0<0;0>:f       r2.0<0>:f        {F@2}
(W)     mul (1|M0)               r4.1<1>:f     r5.0<0;1,0>:f     9.536743e-07:f               {Compacted}
        mad (16|M0)              acc0.0<1>:f   r16.0<1;0>:f      r65.6<0;0>:f      r3.1<0>:f        {F@2}
        mad (16|M16)             acc2.0<1>:f   r18.0<1;0>:f      r65.6<0;0>:f      r3.1<0>:f       
        mul (16|M0)              acc0.0<1>:f   r8.0<0;1,0>:f     acc0.0<1;1,0>:f 
        mul (16|M16)             acc2.0<1>:f   r8.0<0;1,0>:f     acc2.0<1;1,0>:f 
        rndd (16|M0)             r22.0<1>:f    acc0.0<1;1,0>:f                  {Compacted}
        rndd (16|M16)            r24.0<1>:f    acc2.0<1;1,0>:f                  {Compacted}
        mul (16|M0)              acc0.0<1>:f   r4.1<0;1,0>:f     r22.0<1;1,0>:f   {Compacted,F@2}
(W)     mul (1|M0)               r2.0<1>:f     r3.0<0;1,0>:f     -1.048576e+06:f               {Compacted}
        mad (16|M16)             acc2.0<1>:f   r3.1<0;0>:f       r24.0<1;0>:f      -r4.0<0>:f       {F@3}
        mul (16|M16)             r30.0<1>:f    r4.1<0;1,0>:f     r24.0<1;1,0>:f   {Compacted}
        rndd (16|M0)             acc0.0<1>:f   acc0.0<1;1,0>:f                 
        mad (16|M0)              r26.0<1>:f    r3.1<0;0>:f       r22.0<1;0>:f      -r4.0<0>:f       {Compacted}
        mad (16|M16)             r12.0<1>:f    acc2.0<1;0>:f     r24.0<1;0>:f      r2.0<0>:f        {Compacted,F@5}
        rndd (16|M16)            acc2.0<1>:f   r30.0<1;1,0>:f                   {F@4}
        mad (16|M0)              r20.0<1>:f    -acc0.0<1;0>:f    r22.0<1;0>:f      r4.1<0>:f       
        and (16|M0)              r10.0<1>:d    r78.0<1;1,0>:d    1048575:d              
        and (16|M16)             r42.0<1>:d    r80.0<1;1,0>:d    1048575:d              
        mad (16|M0)              r28.0<1>:f    r26.0<1;0>:f      r22.0<1;0>:f      r2.0<0>:f        {Compacted,F@4}
        mad (16|M16)             r6.0<1>:f     -acc2.0<1;0>:f    r24.0<1;0>:f      r4.1<0>:f       
        mad (16|M0)              r40.0<1>:f    r16.0<1;0>:f      r20.0<1;0>:f      r65.7<0>:f       {Compacted,F@3}
        mov (16|M0)              r44.0<1>:f    r10.0<1;1,0>:ud                  {Compacted,I@2}
        mov (16|M16)             r46.0<1>:f    r42.0<1;1,0>:ud                  {Compacted,I@1}
        mad (16|M0)              acc0.0<1>:f   r28.0<1;0>:f      acc0.0<1;0>:f     r82.0<0>:f       {Compacted,F@5}
        mad (16|M16)             r26.0<1>:f    r18.0<1;0>:f      r6.0<1;0>:f       r65.7<0>:f       {Compacted,F@5}
        mad (16|M0)              r14.0<1>:f    r44.0<1;0>:f      r40.0<1;0>:f      r65.6<0>:f       {Compacted,F@4}
        mad (16|M16)             acc2.0<1>:f   r12.0<1;0>:f      acc2.0<1;0>:f     r82.0<0>:f      
        mad (16|M16)             r30.0<1>:f    r46.0<1;0>:f      r26.0<1;0>:f      r65.6<0>:f       {Compacted,F@3}
        mad (16|M0)              r48.0<1>:f    r14.0<1;0>:f      acc0.0<1;0>:f     r82.1<0>:f       {Compacted,F@3}
        mad (16|M16)             r50.0<1>:f    r30.0<1;0>:f      acc2.0<1;0>:f     r82.1<0>:f       {Compacted,F@2}
        mul (16|M0)              r48.0<1>:f    r8.0<0;1,0>:f     r48.0<1;1,0>:f   {Compacted,F@2}
(W)     mul (1|M0)               r2.0<1>:f     r4.0<0;1,0>:f     9.536743e-07:f               {Compacted}
        mul (16|M16)             r50.0<1>:f    r8.0<0;1,0>:f     r50.0<1;1,0>:f   {Compacted,F@3}
        rndd (16|M0)             r12.0<1>:f    r48.0<1;1,0>:f                   {Compacted,F@3}
        rndd (16|M16)            r6.0<1>:f     r50.0<1;1,0>:f                   {Compacted,F@2}
        mad (16|M0)              r16.0<1>:f    acc0.0<1;0>:f     r12.0<1;0>:f      -r3.0<0>:f       {F@2}
        mul (16|M0)              acc0.0<1>:f   r4.1<0;1,0>:f     r12.0<1;1,0>:f   {Compacted}
        mul (16|M0)              r36.0<1>:f    r2.0<0;1,0>:f     r12.0<1;1,0>:f   {Compacted}
        mad (16|M16)             r18.0<1>:f    acc2.0<1;0>:f     r6.0<1;0>:f       -r3.0<0>:f       {F@4}
        mul (16|M16)             r20.0<1>:f    r4.1<0;1,0>:f     r6.0<1;1,0>:f    {Compacted}
        rndd (16|M0)             acc0.0<1>:f   acc0.0<1;1,0>:f                 
        rndd (16|M0)             acc2.0<1>:f   r36.0<1;1,0>:f                   {F@4}
        mul (16|M16)             r38.0<1>:f    r2.0<0;1,0>:f     r6.0<1;1,0>:f    {Compacted}
        rndd (16|M16)            r32.0<1>:f    r20.0<1;1,0>:f                   {Compacted,F@4}
        mad (16|M0)              r34.0<1>:f    r40.0<1;0>:f      acc0.0<1;0>:f     r82.0<0>:f       {Compacted}
        rndd (16|M16)            r10.0<1>:f    r38.0<1;1,0>:f                   {Compacted,F@3}
        mad (16|M0)              r20.0<1>:f    -acc2.0<1;0>:f    r12.0<1;0>:f      r2.0<0>:f       
        mad (16|M0)              r14.0<1>:f    -acc0.0<1;0>:f    r12.0<1;0>:f      r4.1<0>:f       
        mad (16|M0)              r56.0<1>:f    r16.0<1;0>:f      acc2.0<1;0>:f     r82.0<0>:f       {Compacted}
        mad (16|M16)             acc2.0<1>:f   r26.0<1;0>:f      r32.0<1;0>:f      r82.0<0>:f       {F@6}
        mad (16|M16)             r54.0<1>:f    -r10.0<1;0>:f     r6.0<1;0>:f       r2.0<0>:f        {Compacted,F@5}
        mad (16|M0)              r26.0<1>:f    r34.0<1;0>:f      r20.0<1;0>:f      r65.7<0>:f       {Compacted,F@5}
        mad (16|M16)             r30.0<1>:f    -r32.0<1;0>:f     r6.0<1;0>:f       r4.1<0>:f        {Compacted}
        mad (16|M0)              r48.0<1>:f    r44.0<1;0>:f      r14.0<1;0>:f      r65.7<0>:f       {Compacted,F@6}
        mad (16|M16)             r28.0<1>:f    r18.0<1;0>:f      r10.0<1;0>:f      r82.0<0>:f       {Compacted}
        mad (16|M0)              r38.0<1>:f    r26.0<1;0>:f      r56.0<1;0>:f      r65.6<0>:f       {Compacted,F@4}
        mad (16|M16)             acc2.0<1>:f   acc2.0<1;0>:f     r54.0<1;0>:f      r65.7<0>:f      
        mad (16|M16)             acc0.0<1>:f   r46.0<1;0>:f      r30.0<1;0>:f      r65.7<0>:f       {F@5}
        mad (16|M16)             r44.0<1>:f    acc2.0<1;0>:f     r28.0<1;0>:f      r65.6<0>:f       {Compacted,F@4}
        mad (16|M0)              r46.0<1>:f    r48.0<1;0>:f      r38.0<1;0>:f      r65.6<0>:f       {Compacted,F@4}
        mad (16|M16)             r16.0<1>:f    acc0.0<1;0>:f     r44.0<1;0>:f      r65.6<0>:f       {Compacted,F@2}
        mul (16|M0)              r46.0<1>:f    r8.0<0;1,0>:f     r46.0<1;1,0>:f   {Compacted,F@2}
        mul (16|M16)             r16.0<1>:f    r8.0<0;1,0>:f     r16.0<1;1,0>:f   {Compacted,F@2}
        rndd (16|M0)             r10.0<1>:f    r46.0<1;1,0>:f                   {Compacted,F@2}
        rndd (16|M16)            r18.0<1>:f    r16.0<1;1,0>:f                   {Compacted,F@2}
        mad (16|M0)              r20.0<1>:f    r56.0<1;0>:f      -r10.0<1;0>:f     r3.0<0>:f        {Compacted,F@2}
        mov (16|M16)             r36.0<1>:d    r6.0<1;1,0>:f                    {Compacted}
        mov (16|M0)              r30.0<1>:d    r22.0<1;1,0>:f                   {Compacted}
        mad (16|M16)             r34.0<1>:f    acc0.0<1;0>:f     -r18.0<1;0>:f     r5.0<0>:f        {F@2}
        mov (16|M16)             r42.0<1>:d    r18.0<1;1,0>:f                   {Compacted}
        mad (16|M16)             r6.0<1>:f     acc2.0<1;0>:f     -r18.0<1;0>:f     r4.0<0>:f        {I@3}
        mad (16|M16)             acc0.0<1>:f   r28.0<1;0>:f      -r18.0<1;0>:f     r3.0<0>:f       
        mul (16|M0)              acc2.0<1>:f   r20.0<1;1,0>:f    0x2F800000:f               {Compacted,F@4}
        mov (16|M0)              r40.0<1>:d    r12.0<1;1,0>:f                   {Compacted}
        mov (16|M16)             r32.0<1>:d    r24.0<1;1,0>:f                   {Compacted}
        mov (16|M16)             r16.0<1>:d    r34.0<1;1,0>:f                   {Compacted,F@4}
        mov (16|M16)             r52.0<1>:d    r6.0<1;1,0>:f                    {Compacted,F@3}
        mad (16|M0)              r12.0<1>:f    r26.0<1;0>:f      -r10.0<1;0>:f     r4.0<0>:f        {Compacted,I@4}
        mad (16|M0)              r24.0<1>:f    r48.0<1;0>:f      -r10.0<1;0>:f     r5.0<0>:f        {Compacted,I@3}
        rndz (16|M0)             acc2.0<1>:f   acc2.0<1;1,0>:f                 
        asr (16|M16)             r28.0<1>:d    r52.0<1;1,0>:d    31:w               {Compacted,A@1}
        mov (16|M0)              r44.0<1>:d    r12.0<1;1,0>:f                   {Compacted,F@3}
        mov (16|M0)              r46.0<1>:d    r24.0<1;1,0>:f                   {Compacted,F@2}
        mad (16|M0)              r50.0<1>:f    r20.0<1;0>:f      acc2.0<1;0>:f     r65.5<0>:f       {Compacted}
        mul (16|M16)             acc2.0<1>:f   acc0.0<1;1,0>:f   0x2F800000:f               {Compacted}
        shl (16|M16)             r14.0<1>:d    r52.0<1;1,0>:d    20:w               {Compacted}
        shl (16|M16)             r28.0<1>:d    r28.0<1;1,0>:d    20:w               {Compacted,I@4}
        asr (16|M0)              r54.0<1>:d    r44.0<1;1,0>:d    31:w               {Compacted,I@4}
        mov (16|M0)              r58.0<1>:ud   r50.0<1;1,0>:f                   {F@2}
        rndz (16|M16)            acc2.0<1>:f   acc2.0<1;1,0>:f                 
        shr (16|M16)             r52.0<1>:ud   r52.0<1;1,0>:ud   12:w              
        mov (16|M0)              r38.0<1>:d    r10.0<1;1,0>:f                   {Compacted}
        shl (16|M0)              r26.0<1>:d    r44.0<1;1,0>:d    20:w               {Compacted}
        shl (16|M0)              r54.0<1>:d    r54.0<1;1,0>:d    20:w               {Compacted,I@5}
        shl (16|M0)              r58.0<1>:d    r58.0<1;1,0>:d    8:w               {Compacted,I@5}
        mad (16|M16)             r56.0<1>:f    acc0.0<1;0>:f     acc2.0<1;0>:f     r65.5<0>:f      
        or (16|M16)              r6.0<1>:d     r28.0<1;1,0>:d    r52.0<1;1,0>:d   {Compacted,I@5}
        asr (16|M0)              r10.0<1>:d    r46.0<1;1,0>:d    31:w               {Compacted}
        shr (16|M0)              r44.0<1>:ud   r44.0<1;1,0>:ud   12:w              
        addc (8|M0)              r28.0<1>:ud   r46.0<1;1,0>:ud   0x0:ud              {AccWrEn,Compacted,F@1}
        mov (16|M16)             r60.0<1>:ud   r56.0<1;1,0>:f                  
        or (16|M0)               r4.0<1>:d     r54.0<1;1,0>:d    r44.0<1;1,0>:d   {Compacted,I@3}
        add3 (8|M0)              r44.0<1>:ud   acc0.0<1;0>:ud    r58.0<1;0>:ud     r10.0<1>:ud     
        addc (8|M8)              r29.0<1>:ud   r47.0<1;1,0>:ud   0x0:ud              {AccWrEn}
        asr (16|M16)             r12.0<1>:d    r16.0<1;1,0>:d    31:w               {Compacted}
        shl (16|M16)             r60.0<1>:d    r60.0<1;1,0>:d    8:w               {Compacted,I@5}
        add3 (8|M8)              r45.0<1>:ud   acc0.0<1;0>:ud    r59.0<1;0>:ud     r11.0<1>:ud     
        addc (8|M16)             r18.0<1>:ud   r16.0<1;1,0>:ud   0x0:ud              {AccWrEn}
(W)     mov (1|M0)               r3.1<1>:d     r9.0<0;1,0>:f                    {Compacted}
        add3 (8|M16)             r24.0<1>:ud   acc0.0<1;0>:ud    r60.0<1;0>:ud     r12.0<1>:ud      {I@4}
        addc (8|M24)             r19.0<1>:ud   r17.0<1;1,0>:ud   0x0:ud              {AccWrEn}
        shl (16|M0)              r10.0<1>:d    r30.0<1;1,0>:d    20:w               {Compacted}
        add3 (8|M24)             r25.0<1>:ud   acc0.0<1;0>:ud    r61.0<1;0>:ud     r13.0<1>:ud     
        addc (8|M0)              r20.0<1>:ud   r28.0<1;1,0>:ud   r26.0<1;1,0>:ud  {AccWrEn,Compacted}
(W)     shl (1|M0)               r2.0<1>:d     r3.1<0;1,0>:d     8:w               {Compacted,I@6}
        add3 (8|M0)              r22.0<1>:ud   acc0.0<1;0>:ud    r44.0<1;0>:ud     r4.0<1>:ud      
        addc (8|M8)              r21.0<1>:ud   r29.0<1;1,0>:ud   r27.0<1;1,0>:ud  {AccWrEn}
        shr (16|M0)              r12.0<1>:ud   r30.0<1;1,0>:ud   12:w              
        add3 (8|M8)              r23.0<1>:ud   acc0.0<1;0>:ud    r45.0<1;0>:ud     r5.0<1>:ud      
        cmp (16|M0)   (ge)f1.0   null<1>:d     r20.0<1;1,0>:ud   r65.3<0;1,0>:ud  {I@3}
        addc (8|M16)             r34.0<1>:ud   r18.0<1;1,0>:ud   r14.0<1;1,0>:ud  {AccWrEn}
(W)     mov (1|M0)               r3.0<1>:w     -1:w                              
        add3 (8|M16)             r48.0<1>:ud   acc0.0<1;0>:ud    r24.0<1;0>:ud     r6.0<1>:ud      
        addc (8|M24)             r35.0<1>:ud   r19.0<1;1,0>:ud   r15.0<1;1,0>:ud  {AccWrEn}
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r22.0<1;1,0>:d    r65.4<0;1,0>:d   {I@6}
        cmp (16|M16)  (ge)f1.0   null<1>:d     r34.0<1;1,0>:ud   r65.3<0;1,0>:ud  {I@2}
        add3 (8|M24)             r49.0<1>:ud   acc0.0<1;0>:ud    r25.0<1;0>:ud     r7.0<1>:ud      
(~f1.0) cmp (16|M0)   (gt)f1.0   null<1>:d     r22.0<1;1,0>:ud   r65.4<0;1,0>:ud 
        addc (8|M0)              r50.0<1>:ud   r10.0<1;1,0>:ud   0x0:ud              {AccWrEn,Compacted}
(f1.0)  cmp (16|M16)  (eq)f1.0   null<1>:d     r48.0<1;1,0>:d    r65.4<0;1,0>:d   {I@3}
        shl (16|M16)             r16.0<1>:d    r32.0<1;1,0>:d    20:w               {Compacted}
        add3 (8|M0)              r26.0<1>:ud   acc0.0<1;0>:ud    r12.0<1;0>:ud     r2.0<0>:ud      
        addc (8|M8)              r51.0<1>:ud   r11.0<1;1,0>:ud   0x0:ud              {AccWrEn}
        shr (16|M16)             r46.0<1>:ud   r32.0<1;1,0>:ud   12:w              
(f1.0)  sel (16|M0)              r6.0<1>:d     r3.0<0;1,0>:w     0:w              
(~f1.0) cmp (16|M16)  (gt)f1.0   null<1>:d     r48.0<1;1,0>:ud   r65.4<0;1,0>:ud 
        add3 (8|M8)              r27.0<1>:ud   acc0.0<1;0>:ud    r13.0<1;0>:ud     r2.0<0>:ud      
        addc (8|M16)             r4.0<1>:ud    r16.0<1;1,0>:ud   0x0:ud              {AccWrEn,I@7}
        add3 (16|M0)             r12.0<1>:d    r38.0<1;0>:d      r40.0<1;0>:d      -r6.0<1>:d       {I@4}
        add3 (8|M16)             r14.0<1>:ud   acc0.0<1;0>:ud    r46.0<1;0>:ud     r2.0<0>:ud      
        addc (8|M24)             r5.0<1>:ud    r17.0<1;1,0>:ud   0x0:ud              {AccWrEn}
(f1.0)  sel (16|M16)             r10.0<1>:d    r3.0<0;1,0>:w     0:w              
        add3 (8|M24)             r15.0<1>:ud   acc0.0<1;0>:ud    r47.0<1;0>:ud     r2.0<0>:ud      
        addc (8|M0)              r84.0<1>:ud   r50.0<1;1,0>:ud   r12.0<1;1,0>:ud  {AccWrEn,Compacted,I@5}
        add3 (16|M16)            r16.0<1>:d    r42.0<1;0>:d      r36.0<1;0>:d      -r10.0<1>:d      {I@3}
        add (8|M0)               r88.0<1>:ud   acc0.0<1;1,0>:ud  r26.0<1;1,0>:ud 
        addc (8|M8)              r85.0<1>:ud   r51.0<1;1,0>:ud   r13.0<1;1,0>:ud  {AccWrEn}
        add (8|M8)               r89.0<1>:ud   acc0.0<1;1,0>:ud  r27.0<1;1,0>:ud 
        addc (8|M16)             r86.0<1>:ud   r4.0<1;1,0>:ud    r16.0<1;1,0>:ud  {AccWrEn,I@4}
        add (8|M16)              r90.0<1>:ud   acc0.0<1;1,0>:ud  r14.0<1;1,0>:ud 
        addc (8|M24)             r87.0<1>:ud   r5.0<1;1,0>:ud    r17.0<1;1,0>:ud  {AccWrEn}
        add (8|M24)              r91.0<1>:ud   acc0.0<1;1,0>:ud  r15.0<1;1,0>:ud 
        goto (32|M0)                         L2760                  L3536                
L2760:
        join (32|M0)                         L3536                                
L2776:
(W)     cmp (16|M0)   (lt)f0.0   null<1>:d     r65.2<0;1,0>:ud   0x8:uw             
(W)     cmp (16|M16)  (lt)f0.0   null<1>:d     r65.2<0;1,0>:ud   0x8:uw             
(f0.0)  goto (32|M0)                         L3440                  L3440                
L2824:
(W)     xor (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x30:uw              {A@1}
(W)     mov (1|M0)               r2.0<1>:f     r65.3<0;1,0>:ud                  {Compacted,A@1}
(W)     mov (1|M0)               r3.2<1>:f     0xB4C00000:f                               {Compacted}
(W)     math.inv (1|M0)          r3.1<1>:f     r2.0<0;1,0>:f                    {@2,$4}
        mov (16|M0)              r4.0<1>:f     r78.0<1;1,0>:ud                  {Compacted,A@7}
        sync.nop                             null                             {Compacted,$4.dst}
(W)     mad (1|M0)               r8.0<1>:f     r3.1<0;0>:f       r3.2<0;0>:f       r3.1<0>:f        {F@2}
        mov (16|M16)             r6.0<1>:f     r80.0<1;1,0>:ud                  {Compacted}
(W)     mov (1|M0)               r2.1<1>:ud    r2.0<0;1,0>:f                   
        mov (16|M0)              r14.0<1>:ud   r4.0<1;1,0>:f                    {F@3}
        mul (16|M0)              r10.0<1>:f    r4.0<1;1,0>:f     r8.0<0;1,0>:f    {Compacted,F@2}
        mul (16|M16)             r12.0<1>:f    r6.0<1;1,0>:f     r8.0<0;1,0>:f    {Compacted,F@2}
        mov (16|M16)             r16.0<1>:ud   r6.0<1;1,0>:f                   
(W)     add (1|M0)               r3.0<1>:d     r65.3<0;1,0>:d    -r2.1<0;1,0>:d   {I@3}
        add (16|M0)              r14.0<1>:d    r78.0<1;1,0>:d    -r14.0<1;1,0>:d  {Compacted,I@3}
        mov (16|M0)              r18.0<1>:ud   r10.0<1;1,0>:f                   {F@2}
        mov (16|M16)             r20.0<1>:ud   r12.0<1;1,0>:f                   {F@1}
        add (16|M16)             r16.0<1>:d    r80.0<1;1,0>:d    -r16.0<1;1,0>:d  {Compacted,I@5}
(W)     mov (1|M0)               r2.1<1>:f     r3.0<0;1,0>:ud                   {Compacted,I@5}
        mov (16|M0)              r22.0<1>:f    r14.0<1;1,0>:ud                  {Compacted,I@4}
        mov (16|M0)              r26.0<1>:f    r18.0<1;1,0>:ud                  {Compacted,I@3}
        mov (16|M16)             r28.0<1>:f    r20.0<1;1,0>:ud                  {Compacted,I@2}
        mov (16|M16)             r24.0<1>:f    r16.0<1;1,0>:ud                  {Compacted,I@1}
        mad (16|M0)              r30.0<1>:f    r4.0<1;0>:f       r26.0<1;0>:f      -r2.0<0>:f       {Compacted,F@3}
        mad (16|M0)              r34.0<1>:f    r22.0<1;0>:f      r26.0<1;0>:f      -r2.1<0>:f       {Compacted}
        mad (16|M16)             r32.0<1>:f    r6.0<1;0>:f       r28.0<1;0>:f      -r2.0<0>:f       {Compacted,F@4}
        mad (16|M16)             acc2.0<1>:f   r24.0<1;0>:f      r28.0<1;0>:f      -r2.1<0>:f       {F@4}
        add (16|M0)              acc0.0<1>:f   r30.0<1;1,0>:f    r34.0<1;1,0>:f   {Compacted,F@3}
        add (16|M16)             r10.0<1>:f    r32.0<1;1,0>:f    acc2.0<1;1,0>:f  {F@3}
        mul (16|M0)              r12.0<1>:f    r8.0<0;1,0>:f     acc0.0<1;1,0>:f 
(W)     xor (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x30:uw              {A@1}
(W)     xor (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x30:uw              {A@1}
        mul (16|M16)             r14.0<1>:f    r8.0<0;1,0>:f     r10.0<1;1,0>:f   {Compacted,A@1}
(W)     xor (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x30:uw              {A@1}
        mov (16|M0)              r16.0<1>:ud   r12.0<1;1,0>:f                   {A@1}
        mov (16|M16)             r4.0<1>:ud    r14.0<1;1,0>:f                   {F@1}
        add (16|M0)              r6.0<1>:d     r16.0<1;1,0>:d    r18.0<1;1,0>:d   {Compacted,I@2}
        add (16|M16)             r22.0<1>:d    r4.0<1;1,0>:d     r20.0<1;1,0>:d   {Compacted,I@2}
(W)     mul (8|M0)               acc0.0<1>:d   r6.0<1;1,0>:d     r65.6<0;1,0>:uw  {Compacted,I@2}
        mach (8|M0)              r6.0<1>:d     r6.0<1;1,0>:d     r65.3<0;1,0>:d   {Compacted}
(W)     mul (8|M8)               acc0.0<1>:d   r7.0<1;1,0>:d     r65.6<0;1,0>:uw 
        mach (8|M8)              r7.0<1>:d     r7.0<1;1,0>:d     r65.3<0;1,0>:d   {Compacted}
(W)     mul (8|M16)              acc0.0<1>:d   r22.0<1;1,0>:d    r65.6<0;1,0>:uw  {I@5}
        mach (8|M16)             r22.0<1>:d    r22.0<1;1,0>:d    r65.3<0;1,0>:d   {Compacted}
(W)     mul (8|M24)              acc0.0<1>:d   r23.0<1;1,0>:d    r65.6<0;1,0>:uw 
        mach (8|M24)             r23.0<1>:d    r23.0<1;1,0>:d    r65.3<0;1,0>:d   {Compacted}
        add (16|M0)              r6.0<1>:d     r78.0<1;1,0>:d    -r6.0<1;1,0>:d   {Compacted,I@5}
        add (16|M16)             r22.0<1>:d    r80.0<1;1,0>:d    -r22.0<1;1,0>:d  {Compacted,I@2}
        cmp (16|M0)   (ge)f0.0   r2.0<1>:ud    r6.0<1;1,0>:ud    r65.3<0;1,0>:ud  {Compacted,I@2}
        cmp (16|M16)  (ge)f1.0   r10.0<1>:ud   r22.0<1;1,0>:ud   r65.3<0;1,0>:ud  {I@2}
        add3 (16|M0)             r84.0<1>:d    r16.0<1;0>:d      r18.0<1;0>:d      -r2.0<1>:d       {I@2}
        add3 (16|M16)            r86.0<1>:d    r4.0<1;0>:d       r20.0<1;0>:d      -r10.0<1>:d      {I@2}
        goto (32|M0)                         L3440                  L3488                
L3440:
        join (32|M0)                         L3488                                
L3456:
        mov (16|M0)              r84.0<1>:d    -1:w                              
        mov (16|M16)             r86.0<1>:d    -1:w                              
L3488:
        join (32|M0)                         L3536                                
L3504:
        mov (16|M0)              r88.0<1>:d    0:w                              
        mov (16|M16)             r90.0<1>:d    0:w                              
L3536:
        join (32|M0)                         L3552                                
L3552:
        mul (8|M0)               acc0.0<1>:ud  r84.0<1;1,0>:ud   r65.6<0;1,0>:uw  {I@6}
        mach (8|M0)              r2.0<1>:ud    r84.0<1;1,0>:ud   r65.3<0;1,0>:ud  {AccWrEn,Compacted}
(W)     cmp (1|M0)    (lt)f1.0   r8.1<1>:d     r8.3<0;1,0>:d     0:w              
        mov (8|M0)               r4.0<1>:ud    acc0.0<1;1,0>:ud                 {Compacted}
        mul (8|M8)               acc0.0<1>:ud  r85.0<1;1,0>:ud   r65.6<0;1,0>:uw 
        mach (8|M8)              r3.0<1>:ud    r85.0<1;1,0>:ud   r65.3<0;1,0>:ud  {AccWrEn}
(W)     add (1|M0)               r8.0<1>:d     r8.3<0;1,0>:d     31:w               {Compacted}
        mov (8|M8)               r5.0<1>:ud    acc0.0<1;1,0>:ud                 {Compacted}
(W)     mul (8|M0)               acc0.0<1>:d   r84.0<1;1,0>:ud   r65.8<0;1,0>:uw 
        mach (8|M0)              r6.0<1>:d     r84.0<1;1,0>:ud   r65.4<0;1,0>:d  
(W)     mul (8|M8)               acc0.0<1>:d   r85.0<1;1,0>:ud   r65.8<0;1,0>:uw 
        mach (8|M8)              r7.0<1>:d     r85.0<1;1,0>:ud   r65.4<0;1,0>:d  
(W)     mul (8|M0)               acc0.0<1>:d   r65.3<0;1,0>:ud   r88.0<2;1,0>:uw 
        add (16|M0)              r10.0<1>:d    r2.0<1;1,0>:d     r6.0<1;1,0>:d    {Compacted,I@2}
        mach (8|M0)              r6.0<1>:d     r65.3<0;1,0>:ud   r88.0<1;1,0>:d  
(W)     mul (8|M8)               acc0.0<1>:d   r65.3<0;1,0>:ud   r89.0<2;1,0>:uw 
        mach (8|M8)              r7.0<1>:d     r65.3<0;1,0>:ud   r89.0<1;1,0>:d  
        mul (8|M16)              acc0.0<1>:ud  r86.0<1;1,0>:ud   r65.6<0;1,0>:uw 
(W)     bfn.0xD8 (1|M0)          r82.4<1>:ud   r8.1<0;0>:ud      r8.0<0;0>:ud      r8.3<0>:ud       // s0&s1|~s0&s2
        mach (8|M16)             r14.0<1>:ud   r86.0<1;1,0>:ud   r65.3<0;1,0>:ud  {AccWrEn}
(W)     asr (1|M0)               r82.5<1>:d    r82.4<0;1,0>:d    5:w               {I@2}
        mov (8|M16)              r16.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mul (8|M24)              acc0.0<1>:ud  r87.0<1;1,0>:ud   r65.6<0;1,0>:uw 
        mach (8|M24)             r15.0<1>:ud   r87.0<1;1,0>:ud   r65.3<0;1,0>:ud  {AccWrEn}
(W)     asr (1|M0)               r82.6<1>:d    r82.5<0;1,0>:d    31:w               {I@4}
        mov (8|M24)              r17.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
(W)     mul (8|M16)              acc0.0<1>:d   r86.0<1;1,0>:ud   r65.8<0;1,0>:uw 
        add (16|M0)              r12.0<1>:d    r10.0<1;1,0>:d    r6.0<1;1,0>:d    {Compacted}
        mach (8|M16)             r2.0<1>:d     r86.0<1;1,0>:ud   r65.4<0;1,0>:d  
        or (16|M0)               r10.0<1>:d    r88.0<1;1,0>:d    r82.6<0;1,0>:d   {Compacted,I@5}
        or (16|M16)              r12.0<1>:d    r90.0<1;1,0>:d    r82.6<0;1,0>:d   {Compacted}
(W)     mul (8|M24)              acc0.0<1>:d   r87.0<1;1,0>:ud   r65.8<0;1,0>:uw 
        mach (8|M24)             r3.0<1>:d     r87.0<1;1,0>:ud   r65.4<0;1,0>:d  
        cmp (16|M0)   (lt)f1.0   null<1>:d     r10.0<1;1,0>:ud   0x1:uw              {I@4}
        cmp (16|M16)  (lt)f1.0   null<1>:d     r12.0<1;1,0>:ud   0x1:uw              {I@4}
(W)     mul (8|M16)              acc0.0<1>:d   r65.3<0;1,0>:ud   r90.0<2;1,0>:uw 
        add (16|M16)             r18.0<1>:d    r14.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@4}
        mach (8|M16)             r2.0<1>:d     r65.3<0;1,0>:ud   r90.0<1;1,0>:d  
(W)     mul (8|M24)              acc0.0<1>:d   r65.3<0;1,0>:ud   r91.0<2;1,0>:uw 
        mach (8|M24)             r3.0<1>:d     r65.3<0;1,0>:ud   r91.0<1;1,0>:d  
        add (16|M0)              r92.0<1>:d    r78.0<1;1,0>:d    -r4.0<1;1,0>:d   {Compacted}
        add (16|M16)             r94.0<1>:d    r80.0<1;1,0>:d    -r16.0<1;1,0>:d  {Compacted}
        add (16|M16)             r6.0<1>:d     r18.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@3}
(f1.0)  goto (32|M0)                         L6360                  L6360                
L4144:
(W)     shr (1|M0)               r2.0<1>:ud    r82.5<0;1,0>:ud   20:w              
(W)     asr (1|M0)               r2.1<1>:d     r82.4<0;1,0>:d    25:w              
(W)     and (1|M0)               r4.1<1>:d     r82.5<0;1,0>:d    1048575:d              
(W)     bfn.0xF8 (1|M0)          r3.1<1>:ud    r2.1<0;0>:ud      r82.2<0;0>:ud     r2.0<0>:ud       {I@2} // s0&s1|s2
(W)     shr (1|M0)               r2.2<1>:ud    r82.6<0;1,0>:ud   8:w              
(W)     mov (1|M0)               r5.0<1>:f     r4.1<0;1,0>:ud                   {Compacted,I@3}
(W)     mov (1|M0)               r4.0<1>:f     r3.1<0;1,0>:ud                   {Compacted,I@2}
(W)     mov (1|M0)               r3.0<1>:f     r2.2<0;1,0>:ud                   {Compacted,I@1}
(W)     mad (1|M0)               r5.1<1>:f     r5.0<0;0>:f       r65.6<0;0>:f      r4.0<0>:f        {F@2}
        shr (16|M0)              r10.0<1>:ud   r88.0<1;1,0>:ud   8:w              
(W)     mad (1|M0)               r6.0<1>:f     r5.1<0;0>:f       r82.1<0;0>:f      r3.0<0>:f        {F@1}
        shr (16|M16)             r12.0<1>:ud   r90.0<1;1,0>:ud   8:w              
        sync.nop                             null                             {Compacted,F@1}
(W)     math.inv (1|M0)          r7.0<1>:f     r6.0<0;1,0>:f                    {$5}
        mov (16|M0)              r14.0<1>:f    r10.0<1;1,0>:ud                  {Compacted,I@2}
        mov (16|M16)             r16.0<1>:f    r12.0<1;1,0>:ud                  {Compacted,I@1}
(W)     mad (1|M0)               r8.0<1>:f     r7.0<0;0>:f       r82.3<0;0>:f      r7.0<0>:f        {Compacted,$5.dst}
        shr (16|M16)             r32.0<1>:ud   r86.0<1;1,0>:ud   20:w              
        shl (16|M16)             r34.0<1>:d    r90.0<1;1,0>:d    12:w               {Compacted}
        shr (16|M0)              r12.0<1>:ud   r84.0<1;1,0>:ud   20:w               {F@2}
        shl (16|M0)              r6.0<1>:d     r88.0<1;1,0>:d    12:w               {Compacted,F@1}
        mul (16|M0)              acc0.0<1>:f   r8.0<0;1,0>:f     r14.0<1;1,0>:f   {Compacted}
        mul (16|M16)             acc2.0<1>:f   r8.0<0;1,0>:f     r16.0<1;1,0>:f   {Compacted}
        or (16|M0)               r36.0<1>:d    r12.0<1;1,0>:d    r6.0<1;1,0>:d    {Compacted,I@1}
        rndd (16|M0)             r22.0<1>:f    acc0.0<1;1,0>:f                  {Compacted}
        rndd (16|M16)            r24.0<1>:f    acc2.0<1;1,0>:f                  {Compacted}
        or (16|M16)              r18.0<1>:d    r32.0<1;1,0>:d    r34.0<1;1,0>:d   {Compacted}
(W)     mul (1|M0)               r2.0<1>:f     r4.0<0;1,0>:f     -1.048576e+06:f               {Compacted}
        bfn.0xF8 (16|M0)         r12.0<1>:ud   r36.0<1;0>:ud     r82.2<0;0>:ud     r12.0<1>:ud      {I@2} // s0&s1|s2
        mad (16|M0)              acc0.0<1>:f   r14.0<1;0>:f      r22.0<1;0>:f      -r5.0<0>:f       {Compacted,F@3}
        mad (16|M16)             acc2.0<1>:f   r16.0<1;0>:f      r24.0<1;0>:f      -r5.0<0>:f       {F@3}
        bfn.0xF8 (16|M16)        r32.0<1>:ud   r18.0<1;0>:ud     r82.2<0;0>:ud     r32.0<1>:ud      {I@2} // s0&s1|s2
        mad (16|M0)              r30.0<1>:f    acc0.0<1;0>:f     r22.0<1;0>:f      r2.0<0>:f        {Compacted,F@3}
        mov (16|M0)              r14.0<1>:f    r12.0<1;1,0>:ud                  {Compacted,I@2}
        mad (16|M16)             acc2.0<1>:f   acc2.0<1;0>:f     r24.0<1;0>:f      r2.0<0>:f       
        mov (16|M16)             r16.0<1>:f    r32.0<1;1,0>:ud                  {Compacted,I@1}
        mad (16|M0)              acc0.0<1>:f   r14.0<1;0>:f      r30.0<1;0>:f      r65.6<0>:f       {Compacted,F@3}
        mad (16|M16)             r26.0<1>:f    r16.0<1;0>:f      acc2.0<1;0>:f     r65.6<0>:f       {Compacted,F@2}
        mul (16|M0)              acc0.0<1>:f   r8.0<0;1,0>:f     acc0.0<1;1,0>:f 
        mul (16|M16)             r26.0<1>:f    r8.0<0;1,0>:f     r26.0<1;1,0>:f   {Compacted,F@2}
(W)     mul (1|M0)               r3.1<1>:f     r5.0<0;1,0>:f     9.536743e-07:f               {Compacted}
        rndd (16|M0)             r28.0<1>:f    acc0.0<1;1,0>:f                  {Compacted}
        rndd (16|M16)            r38.0<1>:f    r26.0<1;1,0>:f                   {Compacted,F@3}
        mul (16|M0)              acc0.0<1>:f   r3.1<0;1,0>:f     r28.0<1;1,0>:f   {Compacted,F@2}
        mul (16|M16)             r36.0<1>:f    r3.1<0;1,0>:f     r38.0<1;1,0>:f   {Compacted,F@2}
(W)     mul (1|M0)               r2.0<1>:f     r3.0<0;1,0>:f     -1.048576e+06:f               {Compacted}
        mad (16|M16)             r34.0<1>:f    acc2.0<1;0>:f     r38.0<1;0>:f      -r4.0<0>:f      
        rndd (16|M0)             acc0.0<1>:f   acc0.0<1;1,0>:f                 
        rndd (16|M16)            acc2.0<1>:f   r36.0<1;1,0>:f                   {F@4}
        and (16|M16)             r46.0<1>:d    r86.0<1;1,0>:d    1048575:d              
        mad (16|M0)              r6.0<1>:f     r30.0<1;0>:f      r28.0<1;0>:f      -r4.0<0>:f       {Compacted}
        mad (16|M16)             r12.0<1>:f    r34.0<1;0>:f      r38.0<1;0>:f      r2.0<0>:f        {Compacted,F@4}
        mad (16|M0)              r20.0<1>:f    -acc0.0<1;0>:f    r28.0<1;0>:f      r3.1<0>:f       
        mad (16|M16)             r26.0<1>:f    -acc2.0<1;0>:f    r38.0<1;0>:f      r3.1<0>:f       
        and (16|M0)              r34.0<1>:d    r84.0<1;1,0>:d    1048575:d               {F@3}
        mov (16|M16)             r50.0<1>:f    r46.0<1;1,0>:ud                  {Compacted,I@2}
        mad (16|M0)              r18.0<1>:f    r6.0<1;0>:f       r28.0<1;0>:f      r2.0<0>:f        {Compacted}
        mad (16|M0)              r44.0<1>:f    r14.0<1;0>:f      r20.0<1;0>:f      r65.7<0>:f       {Compacted,F@4}
        mov (16|M0)              r48.0<1>:f    r34.0<1;1,0>:ud                  {Compacted,I@1}
        mad (16|M16)             r6.0<1>:f     r16.0<1;0>:f      r26.0<1;0>:f      r65.7<0>:f       {Compacted,F@5}
        mad (16|M16)             acc2.0<1>:f   r12.0<1;0>:f      acc2.0<1;0>:f     r82.0<0>:f      
        mad (16|M0)              acc0.0<1>:f   r18.0<1;0>:f      acc0.0<1;0>:f     r82.0<0>:f       {Compacted,F@5}
        mad (16|M0)              r32.0<1>:f    r48.0<1;0>:f      r44.0<1;0>:f      r65.6<0>:f       {Compacted,F@4}
        mad (16|M16)             r36.0<1>:f    r50.0<1;0>:f      r6.0<1;0>:f       r65.6<0>:f       {Compacted,F@4}
        mad (16|M0)              r52.0<1>:f    r32.0<1;0>:f      acc0.0<1;0>:f     r82.1<0>:f       {Compacted,F@2}
        mad (16|M16)             r54.0<1>:f    r36.0<1;0>:f      acc2.0<1;0>:f     r82.1<0>:f       {Compacted,F@2}
        mul (16|M0)              r52.0<1>:f    r8.0<0;1,0>:f     r52.0<1;1,0>:f   {Compacted,F@2}
        mul (16|M16)             r54.0<1>:f    r8.0<0;1,0>:f     r54.0<1;1,0>:f   {Compacted,F@2}
(W)     mul (1|M0)               r2.0<1>:f     r4.0<0;1,0>:f     9.536743e-07:f               {Compacted}
        rndd (16|M0)             r12.0<1>:f    r52.0<1;1,0>:f                   {Compacted,F@3}
        rndd (16|M16)            r14.0<1>:f    r54.0<1;1,0>:f                   {Compacted,F@3}
        mul (16|M0)              r20.0<1>:f    r3.1<0;1,0>:f     r12.0<1;1,0>:f   {Compacted,F@2}
        mad (16|M16)             r18.0<1>:f    acc2.0<1;0>:f     r14.0<1;0>:f      -r3.0<0>:f       {F@2}
        mul (16|M0)              r10.0<1>:f    r2.0<0;1,0>:f     r12.0<1;1,0>:f   {Compacted}
        mad (16|M0)              r16.0<1>:f    acc0.0<1;0>:f     r12.0<1;0>:f      -r3.0<0>:f      
        mul (16|M16)             r26.0<1>:f    r3.1<0;1,0>:f     r14.0<1;1,0>:f   {Compacted}
        rndd (16|M0)             acc2.0<1>:f   r20.0<1;1,0>:f                   {F@5}
        rndd (16|M0)             acc0.0<1>:f   r10.0<1;1,0>:f                   {F@4}
        mul (16|M16)             r30.0<1>:f    r2.0<0;1,0>:f     r14.0<1;1,0>:f   {Compacted}
        rndd (16|M16)            r40.0<1>:f    r26.0<1;1,0>:f                   {Compacted,F@4}
        mad (16|M0)              r42.0<1>:f    r44.0<1;0>:f      acc2.0<1;0>:f     r82.0<0>:f       {Compacted}
        rndd (16|M16)            r20.0<1>:f    r30.0<1;1,0>:f                   {Compacted,F@3}
        mad (16|M0)              r26.0<1>:f    -acc0.0<1;0>:f    r12.0<1;0>:f      r2.0<0>:f       
        mad (16|M0)              r32.0<1>:f    -acc2.0<1;0>:f    r12.0<1;0>:f      r3.1<0>:f       
        mad (16|M0)              r60.0<1>:f    r16.0<1;0>:f      acc0.0<1;0>:f     r82.0<0>:f       {Compacted}
        mad (16|M16)             acc0.0<1>:f   -r40.0<1;0>:f     r14.0<1;0>:f      r3.1<0>:f        {F@6}
        mad (16|M16)             r46.0<1>:f    r6.0<1;0>:f       r40.0<1;0>:f      r82.0<0>:f       {Compacted}
        mad (16|M16)             r58.0<1>:f    -r20.0<1;0>:f     r14.0<1;0>:f      r2.0<0>:f        {Compacted,F@6}
        mad (16|M0)              r6.0<1>:f     r42.0<1;0>:f      r26.0<1;0>:f      r65.7<0>:f       {Compacted,F@6}
        mad (16|M0)              r52.0<1>:f    r48.0<1;0>:f      r32.0<1;0>:f      r65.7<0>:f       {Compacted,F@6}
        mad (16|M16)             acc2.0<1>:f   r18.0<1;0>:f      r20.0<1;0>:f      r82.0<0>:f      
        mad (16|M16)             r54.0<1>:f    r50.0<1;0>:f      acc0.0<1;0>:f     r65.7<0>:f       {Compacted}
        mad (16|M16)             acc0.0<1>:f   r46.0<1;0>:f      r58.0<1;0>:f      r65.7<0>:f       {F@5}
        mad (16|M0)              r50.0<1>:f    r6.0<1;0>:f       r60.0<1;0>:f      r65.6<0>:f       {Compacted,F@5}
        mad (16|M16)             r62.0<1>:f    acc0.0<1;0>:f     acc2.0<1;0>:f     r65.6<0>:f      
        mad (16|M0)              r16.0<1>:f    r52.0<1;0>:f      r50.0<1;0>:f      r65.6<0>:f       {Compacted,F@2}
        mad (16|M16)             r18.0<1>:f    r54.0<1;0>:f      r62.0<1;0>:f      r65.6<0>:f       {Compacted,F@2}
        mul (16|M0)              r16.0<1>:f    r8.0<0;1,0>:f     r16.0<1;1,0>:f   {Compacted,F@2}
        mul (16|M16)             r18.0<1>:f    r8.0<0;1,0>:f     r18.0<1;1,0>:f   {Compacted,F@2}
        rndd (16|M0)             r20.0<1>:f    r16.0<1;1,0>:f                   {Compacted,F@2}
        mov (16|M16)             r40.0<1>:d    r24.0<1;1,0>:f                   {Compacted}
        mov (16|M0)              r36.0<1>:d    r22.0<1;1,0>:f                   {Compacted}
        mad (16|M0)              r24.0<1>:f    r60.0<1;0>:f      -r20.0<1;0>:f     r3.0<0>:f        {Compacted,A@1}
        rndd (16|M16)            r22.0<1>:f    r18.0<1;1,0>:f                   {Compacted,I@1}
        mov (16|M16)             r30.0<1>:d    r14.0<1;1,0>:f                   {Compacted}
        mov (16|M16)             r48.0<1>:d    r38.0<1;1,0>:f                   {Compacted}
        mad (16|M16)             acc2.0<1>:f   acc2.0<1;0>:f     -r22.0<1;0>:f     r3.0<0>:f        {F@1}
        mov (16|M16)             r46.0<1>:d    r22.0<1;1,0>:f                   {Compacted}
        mad (16|M16)             r14.0<1>:f    acc0.0<1;0>:f     -r22.0<1;0>:f     r4.0<0>:f        {I@3}
        mad (16|M16)             r38.0<1>:f    r54.0<1;0>:f      -r22.0<1;0>:f     r5.0<0>:f        {Compacted,I@2}
        mul (16|M0)              acc0.0<1>:f   r24.0<1;1,0>:f    0x2F800000:f               {Compacted}
        mov (16|M0)              r10.0<1>:d    r12.0<1;1,0>:f                   {Compacted}
        mov (16|M0)              r44.0<1>:d    r28.0<1;1,0>:f                   {Compacted}
        mov (16|M16)             r56.0<1>:d    r14.0<1;1,0>:f                   {Compacted,F@3}
        rndz (16|M0)             acc0.0<1>:f   acc0.0<1;1,0>:f                 
        mad (16|M0)              r12.0<1>:f    r6.0<1;0>:f       -r20.0<1;0>:f     r4.0<0>:f        {Compacted,I@3}
        mad (16|M0)              r28.0<1>:f    r52.0<1;0>:f      -r20.0<1;0>:f     r5.0<0>:f        {Compacted,I@2}
        asr (16|M16)             r34.0<1>:d    r56.0<1;1,0>:d    31:w               {Compacted,I@1}
        mov (16|M0)              r50.0<1>:d    r12.0<1;1,0>:f                   {Compacted,F@2}
        mov (16|M0)              r16.0<1>:d    r28.0<1;1,0>:f                   {Compacted,F@1}
        mad (16|M0)              r52.0<1>:f    r24.0<1;0>:f      acc0.0<1;0>:f     r65.5<0>:f       {Compacted}
        mul (16|M16)             acc0.0<1>:f   acc2.0<1;1,0>:f   0x2F800000:f               {Compacted}
        mov (16|M16)             r18.0<1>:d    r38.0<1;1,0>:f                   {Compacted}
        shl (16|M16)             r6.0<1>:d     r56.0<1;1,0>:d    20:w               {Compacted}
        shl (16|M16)             r34.0<1>:d    r34.0<1;1,0>:d    20:w               {Compacted,I@5}
        asr (16|M0)              r58.0<1>:d    r50.0<1;1,0>:d    31:w               {Compacted,I@5}
        mov (16|M0)              r60.0<1>:ud   r52.0<1;1,0>:f                   {F@2}
        rndz (16|M16)            acc0.0<1>:f   acc0.0<1;1,0>:f                 
        shr (16|M16)             r56.0<1>:ud   r56.0<1;1,0>:ud   12:w              
        shl (16|M0)              r2.0<1>:d     r50.0<1;1,0>:d    20:w               {Compacted}
        asr (16|M0)              r14.0<1>:d    r16.0<1;1,0>:d    31:w               {Compacted,I@7}
        shl (16|M0)              r58.0<1>:d    r58.0<1;1,0>:d    20:w               {Compacted,I@5}
        shl (16|M0)              r60.0<1>:d    r60.0<1;1,0>:d    8:w               {Compacted,I@5}
        mad (16|M16)             r54.0<1>:f    acc2.0<1;0>:f     acc0.0<1;0>:f     r65.5<0>:f      
        or (16|M16)              r12.0<1>:d    r34.0<1;1,0>:d    r56.0<1;1,0>:d   {Compacted,I@5}
        shr (16|M0)              r50.0<1>:ud   r50.0<1;1,0>:ud   12:w              
        addc (8|M0)              r34.0<1>:ud   r16.0<1;1,0>:ud   0x0:ud              {AccWrEn,Compacted,A@1}
        mov (16|M16)             r62.0<1>:ud   r54.0<1;1,0>:f                  
        or (16|M0)               r4.0<1>:d     r58.0<1;1,0>:d    r50.0<1;1,0>:d   {Compacted,I@3}
        add3 (8|M0)              r50.0<1>:ud   acc0.0<1;0>:ud    r60.0<1;0>:ud     r14.0<1>:ud     
        addc (8|M8)              r35.0<1>:ud   r17.0<1;1,0>:ud   0x0:ud              {AccWrEn}
        mov (16|M0)              r42.0<1>:d    r20.0<1;1,0>:f                   {Compacted}
        shl (16|M16)             r62.0<1>:d    r62.0<1;1,0>:d    8:w               {Compacted,I@5}
        add3 (8|M8)              r51.0<1>:ud   acc0.0<1;0>:ud    r61.0<1;0>:ud     r15.0<1>:ud     
        asr (16|M16)             r20.0<1>:d    r18.0<1;1,0>:d    31:w               {Compacted}
        addc (8|M16)             r22.0<1>:ud   r18.0<1;1,0>:ud   0x0:ud              {AccWrEn}
        shr (16|M0)              r52.0<1>:ud   r44.0<1;1,0>:ud   12:w              
        add3 (8|M16)             r28.0<1>:ud   acc0.0<1;0>:ud    r62.0<1;0>:ud     r20.0<1>:ud      {I@3}
        addc (8|M24)             r23.0<1>:ud   r19.0<1;1,0>:ud   0x0:ud              {AccWrEn}
        shl (16|M0)              r18.0<1>:d    r44.0<1;1,0>:d    20:w               {Compacted}
        add3 (8|M24)             r29.0<1>:ud   acc0.0<1;0>:ud    r63.0<1;0>:ud     r21.0<1>:ud     
        addc (8|M0)              r24.0<1>:ud   r34.0<1;1,0>:ud   r2.0<1;1,0>:ud   {AccWrEn,Compacted}
        shl (16|M0)              r14.0<1>:d    r36.0<1;1,0>:d    8:w               {Compacted}
        add3 (8|M0)              r26.0<1>:ud   acc0.0<1;0>:ud    r50.0<1;0>:ud     r4.0<1>:ud      
        addc (8|M8)              r25.0<1>:ud   r35.0<1;1,0>:ud   r3.0<1;1,0>:ud   {AccWrEn}
(W)     mov (1|M0)               r8.0<1>:w     -1:w                              
        add3 (8|M8)              r27.0<1>:ud   acc0.0<1;0>:ud    r51.0<1;0>:ud     r5.0<1>:ud      
        cmp (16|M0)   (ge)f0.0   null<1>:d     r24.0<1;1,0>:ud   r82.5<0;1,0>:ud  {I@3}
        addc (8|M16)             r32.0<1>:ud   r22.0<1;1,0>:ud   r6.0<1;1,0>:ud   {AccWrEn}
        shl (16|M16)             r20.0<1>:d    r48.0<1;1,0>:d    20:w               {Compacted}
        add3 (8|M16)             r38.0<1>:ud   acc0.0<1;0>:ud    r28.0<1;0>:ud     r12.0<1>:ud     
        addc (8|M24)             r33.0<1>:ud   r23.0<1;1,0>:ud   r7.0<1;1,0>:ud   {AccWrEn}
(f0.0)  cmp (16|M0)   (eq)f0.0   null<1>:d     r26.0<1;1,0>:d    r82.6<0;1,0>:d   {I@6}
        cmp (16|M16)  (ge)f0.0   null<1>:d     r32.0<1;1,0>:ud   r82.5<0;1,0>:ud  {I@2}
        add3 (8|M24)             r39.0<1>:ud   acc0.0<1;0>:ud    r29.0<1;0>:ud     r13.0<1>:ud     
(~f0.0) cmp (16|M0)   (gt)f0.0   null<1>:d     r26.0<1;1,0>:ud   r82.6<0;1,0>:ud 
        addc (8|M0)              r2.0<1>:ud    r18.0<1;1,0>:ud   0x0:ud              {AccWrEn,Compacted}
(f0.0)  cmp (16|M16)  (eq)f0.0   null<1>:d     r38.0<1;1,0>:d    r82.6<0;1,0>:d   {I@3}
        add3 (8|M0)              r4.0<1>:ud    acc0.0<1;0>:ud    r52.0<1;0>:ud     r14.0<1>:ud     
        addc (8|M8)              r3.0<1>:ud    r19.0<1;1,0>:ud   0x0:ud              {AccWrEn}
        shr (16|M16)             r54.0<1>:ud   r48.0<1;1,0>:ud   12:w              
        shl (16|M16)             r16.0<1>:d    r40.0<1;1,0>:d    8:w               {Compacted}
(~f0.0) cmp (16|M16)  (gt)f0.0   null<1>:d     r38.0<1;1,0>:ud   r82.6<0;1,0>:ud 
        add3 (8|M8)              r5.0<1>:ud    acc0.0<1;0>:ud    r53.0<1;0>:ud     r15.0<1>:ud     
        addc (8|M16)             r6.0<1>:ud    r20.0<1;1,0>:ud   0x0:ud              {AccWrEn}
(f0.0)  sel (16|M0)              r14.0<1>:d    r8.0<0;1,0>:w     0:w              
        add3 (8|M16)             r12.0<1>:ud   acc0.0<1;0>:ud    r54.0<1;0>:ud     r16.0<1>:ud      {I@5}
        add3 (16|M0)             r22.0<1>:d    r42.0<1;0>:d      r10.0<1;0>:d      -r14.0<1>:d      {I@2}
        addc (8|M24)             r7.0<1>:ud    r21.0<1;1,0>:ud   0x0:ud              {AccWrEn}
(f0.0)  sel (16|M16)             r18.0<1>:d    r8.0<0;1,0>:w     0:w              
        add3 (8|M24)             r13.0<1>:ud   acc0.0<1;0>:ud    r55.0<1;0>:ud     r17.0<1>:ud     
        addc (8|M0)              r96.0<1>:ud   r2.0<1;1,0>:ud    r22.0<1;1,0>:ud  {AccWrEn,Compacted,I@4}
        add3 (16|M16)            r20.0<1>:d    r46.0<1;0>:d      r30.0<1;0>:d      -r18.0<1>:d      {I@3}
        add (8|M0)               r100.0<1>:ud  acc0.0<1;1,0>:ud  r4.0<1;1,0>:ud  
        addc (8|M8)              r97.0<1>:ud   r3.0<1;1,0>:ud    r23.0<1;1,0>:ud  {AccWrEn}
        add (8|M8)               r101.0<1>:ud  acc0.0<1;1,0>:ud  r5.0<1;1,0>:ud  
        addc (8|M16)             r98.0<1>:ud   r6.0<1;1,0>:ud    r20.0<1;1,0>:ud  {AccWrEn,I@4}
        add (8|M16)              r102.0<1>:ud  acc0.0<1;1,0>:ud  r12.0<1;1,0>:ud 
        addc (8|M24)             r99.0<1>:ud   r7.0<1;1,0>:ud    r21.0<1;1,0>:ud  {AccWrEn}
        add (8|M24)              r103.0<1>:ud  acc0.0<1;1,0>:ud  r13.0<1;1,0>:ud 
        goto (32|M0)                         L6360                  L7136                
L6360:
        join (32|M0)                         L7136                                
L6376:
(W)     cmp (16|M0)   (lt)f0.0   null<1>:d     r82.4<0;1,0>:ud   0x20:uw             
(W)     cmp (16|M16)  (lt)f0.0   null<1>:d     r82.4<0;1,0>:ud   0x20:uw             
(f0.0)  goto (32|M0)                         L7040                  L7040                
L6424:
(W)     xor (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x30:uw              {A@1}
(W)     mov (1|M0)               r2.0<1>:f     r82.5<0;1,0>:ud                  {Compacted,A@1}
(W)     mov (1|M0)               r3.2<1>:f     0xB4C00000:f                               {Compacted}
(W)     math.inv (1|M0)          r3.1<1>:f     r2.0<0;1,0>:f                    {@2,$6}
        mov (16|M0)              r4.0<1>:f     r84.0<1;1,0>:ud                  {Compacted,I@7}
        sync.nop                             null                             {Compacted,$6.dst}
(W)     mad (1|M0)               r8.0<1>:f     r3.1<0;0>:f       r3.2<0;0>:f       r3.1<0>:f        {F@2}
        mov (16|M16)             r6.0<1>:f     r86.0<1;1,0>:ud                  {Compacted,A@7}
(W)     mov (1|M0)               r2.1<1>:ud    r2.0<0;1,0>:f                   
        mov (16|M0)              r14.0<1>:ud   r4.0<1;1,0>:f                    {F@3}
        mul (16|M0)              r10.0<1>:f    r4.0<1;1,0>:f     r8.0<0;1,0>:f    {Compacted,F@2}
        mul (16|M16)             r12.0<1>:f    r6.0<1;1,0>:f     r8.0<0;1,0>:f    {Compacted,A@2}
        mov (16|M16)             r16.0<1>:ud   r6.0<1;1,0>:f                   
(W)     add (1|M0)               r3.0<1>:d     r82.5<0;1,0>:d    -r2.1<0;1,0>:d   {I@3}
        add (16|M0)              r14.0<1>:d    r84.0<1;1,0>:d    -r14.0<1;1,0>:d  {Compacted,I@3}
        mov (16|M0)              r18.0<1>:ud   r10.0<1;1,0>:f                   {F@2}
        mov (16|M16)             r20.0<1>:ud   r12.0<1;1,0>:f                   {F@1}
        add (16|M16)             r16.0<1>:d    r86.0<1;1,0>:d    -r16.0<1;1,0>:d  {Compacted,I@5}
(W)     mov (1|M0)               r2.1<1>:f     r3.0<0;1,0>:ud                   {Compacted,I@5}
        mov (16|M0)              r22.0<1>:f    r14.0<1;1,0>:ud                  {Compacted,I@4}
        mov (16|M0)              r26.0<1>:f    r18.0<1;1,0>:ud                  {Compacted,I@3}
        mov (16|M16)             r28.0<1>:f    r20.0<1;1,0>:ud                  {Compacted,I@2}
        mov (16|M16)             r24.0<1>:f    r16.0<1;1,0>:ud                  {Compacted,I@1}
        mad (16|M0)              r30.0<1>:f    r4.0<1;0>:f       r26.0<1;0>:f      -r2.0<0>:f       {Compacted,F@3}
        mad (16|M0)              r34.0<1>:f    r22.0<1;0>:f      r26.0<1;0>:f      -r2.1<0>:f       {Compacted}
        mad (16|M16)             r32.0<1>:f    r6.0<1;0>:f       r28.0<1;0>:f      -r2.0<0>:f       {Compacted,F@4}
        mad (16|M16)             acc2.0<1>:f   r24.0<1;0>:f      r28.0<1;0>:f      -r2.1<0>:f       {F@4}
        add (16|M0)              acc0.0<1>:f   r30.0<1;1,0>:f    r34.0<1;1,0>:f   {Compacted,F@3}
        add (16|M16)             r10.0<1>:f    r32.0<1;1,0>:f    acc2.0<1;1,0>:f  {F@3}
        mul (16|M0)              r12.0<1>:f    r8.0<0;1,0>:f     acc0.0<1;1,0>:f 
(W)     xor (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x30:uw              {A@1}
(W)     xor (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x30:uw              {A@1}
        mul (16|M16)             r14.0<1>:f    r8.0<0;1,0>:f     r10.0<1;1,0>:f   {Compacted,A@1}
(W)     xor (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x30:uw              {A@1}
        mov (16|M0)              r16.0<1>:ud   r12.0<1;1,0>:f                   {A@1}
        mov (16|M16)             r4.0<1>:ud    r14.0<1;1,0>:f                   {F@1}
        add (16|M0)              r6.0<1>:d     r16.0<1;1,0>:d    r18.0<1;1,0>:d   {Compacted,I@2}
        add (16|M16)             r22.0<1>:d    r4.0<1;1,0>:d     r20.0<1;1,0>:d   {Compacted,I@2}
(W)     mul (8|M0)               acc0.0<1>:d   r6.0<1;1,0>:d     r82.10<0;1,0>:uw {Compacted,I@2}
        mach (8|M0)              r6.0<1>:d     r6.0<1;1,0>:d     r82.5<0;1,0>:d   {Compacted}
(W)     mul (8|M8)               acc0.0<1>:d   r7.0<1;1,0>:d     r82.10<0;1,0>:uw
        mach (8|M8)              r7.0<1>:d     r7.0<1;1,0>:d     r82.5<0;1,0>:d   {Compacted}
(W)     mul (8|M16)              acc0.0<1>:d   r22.0<1;1,0>:d    r82.10<0;1,0>:uw {I@5}
        mach (8|M16)             r22.0<1>:d    r22.0<1;1,0>:d    r82.5<0;1,0>:d   {Compacted}
(W)     mul (8|M24)              acc0.0<1>:d   r23.0<1;1,0>:d    r82.10<0;1,0>:uw
        mach (8|M24)             r23.0<1>:d    r23.0<1;1,0>:d    r82.5<0;1,0>:d   {Compacted}
        add (16|M0)              r6.0<1>:d     r84.0<1;1,0>:d    -r6.0<1;1,0>:d   {Compacted,I@5}
        add (16|M16)             r22.0<1>:d    r86.0<1;1,0>:d    -r22.0<1;1,0>:d  {Compacted,I@2}
        cmp (16|M0)   (ge)f0.0   r2.0<1>:ud    r6.0<1;1,0>:ud    r82.5<0;1,0>:ud  {Compacted,I@2}
        cmp (16|M16)  (ge)f0.0   r10.0<1>:ud   r22.0<1;1,0>:ud   r82.5<0;1,0>:ud  {I@2}
        add3 (16|M0)             r96.0<1>:d    r16.0<1;0>:d      r18.0<1;0>:d      -r2.0<1>:d       {I@2}
        add3 (16|M16)            r98.0<1>:d    r4.0<1;0>:d       r20.0<1;0>:d      -r10.0<1>:d      {I@2}
        goto (32|M0)                         L7040                  L7088                
L7040:
        join (32|M0)                         L7088                                
L7056:
        mov (16|M0)              r96.0<1>:d    -1:w                              
        mov (16|M16)             r98.0<1>:d    -1:w                              
L7088:
        join (32|M0)                         L7136                                
L7104:
        mov (16|M0)              r100.0<1>:d   0:w                              
        mov (16|M16)             r102.0<1>:d   0:w                              
L7136:
        join (32|M0)                         L7152                                
L7152:
        mul (8|M0)               acc0.0<1>:ud  r96.0<1;1,0>:ud   r82.10<0;1,0>:uw {I@6}
        mach (8|M0)              r2.0<1>:ud    r96.0<1;1,0>:ud   r82.5<0;1,0>:ud  {AccWrEn,Compacted}
        shr (16|M0)              r18.0<1>:ud   r66.0<1;1,0>:ud   3:w              
        mov (8|M0)               r4.0<1>:ud    acc0.0<1;1,0>:ud                 {Compacted}
        mul (8|M8)               acc0.0<1>:ud  r97.0<1;1,0>:ud   r82.10<0;1,0>:uw
        mach (8|M8)              r3.0<1>:ud    r97.0<1;1,0>:ud   r82.5<0;1,0>:ud  {AccWrEn}
        shr (16|M16)             r24.0<1>:ud   r68.0<1;1,0>:ud   3:w              
        mov (8|M8)               r5.0<1>:ud    acc0.0<1;1,0>:ud                 {Compacted}
(W)     mul (8|M0)               acc0.0<1>:d   r96.0<1;1,0>:ud   r82.12<0;1,0>:uw
        mach (8|M0)              r6.0<1>:d     r96.0<1;1,0>:ud   r82.6<0;1,0>:d  
(W)     mul (8|M8)               acc0.0<1>:d   r97.0<1;1,0>:ud   r82.12<0;1,0>:uw
        mach (8|M8)              r7.0<1>:d     r97.0<1;1,0>:ud   r82.6<0;1,0>:d  
(W)     mul (8|M0)               acc0.0<1>:d   r82.5<0;1,0>:ud   r100.0<2;1,0>:uw
        add (16|M0)              r10.0<1>:d    r2.0<1;1,0>:d     r6.0<1;1,0>:d    {Compacted,I@2}
        mach (8|M0)              r6.0<1>:d     r82.5<0;1,0>:ud   r100.0<1;1,0>:d 
(W)     mul (8|M8)               acc0.0<1>:d   r82.5<0;1,0>:ud   r101.0<2;1,0>:uw
        mach (8|M8)              r7.0<1>:d     r82.5<0;1,0>:ud   r101.0<1;1,0>:d 
        mul (8|M16)              acc0.0<1>:ud  r98.0<1;1,0>:ud   r82.10<0;1,0>:uw
        mach (8|M16)             r12.0<1>:ud   r98.0<1;1,0>:ud   r82.5<0;1,0>:ud  {AccWrEn}
        add (16|M0)              r2.0<1>:d     r84.0<1;1,0>:d    -r4.0<1;1,0>:d   {Compacted}
        mov (8|M16)              r14.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mul (8|M24)              acc0.0<1>:ud  r99.0<1;1,0>:ud   r82.10<0;1,0>:uw
        mach (8|M24)             r13.0<1>:ud   r99.0<1;1,0>:ud   r82.5<0;1,0>:ud  {AccWrEn}
        and (16|M0)              r18.0<1>:d    r18.0<1;1,0>:d    28:w               {Compacted}
        mov (8|M24)              r15.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
(W)     mul (8|M16)              acc0.0<1>:d   r98.0<1;1,0>:ud   r82.12<0;1,0>:uw
        mach (8|M16)             r16.0<1>:d    r98.0<1;1,0>:ud   r82.6<0;1,0>:d  
(W)     mul (8|M24)              acc0.0<1>:d   r99.0<1;1,0>:ud   r82.12<0;1,0>:uw
        mach (8|M24)             r17.0<1>:d    r99.0<1;1,0>:ud   r82.6<0;1,0>:d  
(W)     mul (8|M16)              acc0.0<1>:d   r82.5<0;1,0>:ud   r102.0<2;1,0>:uw
        add (16|M16)             r20.0<1>:d    r12.0<1;1,0>:d    r16.0<1;1,0>:d   {Compacted,I@2}
        mach (8|M16)             r16.0<1>:d    r82.5<0;1,0>:ud   r102.0<1;1,0>:d 
(W)     mul (8|M24)              acc0.0<1>:d   r82.5<0;1,0>:ud   r103.0<2;1,0>:uw
        shl (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     5:w               {Compacted}
        add (16|M16)             r22.0<1>:d    r86.0<1;1,0>:d    -r14.0<1;1,0>:d  {Compacted}
        mach (8|M24)             r17.0<1>:d    r82.5<0;1,0>:ud   r103.0<1;1,0>:d 
(W)     mul (8|M0)               acc0.0<1>:ud  r96.0<1;1,0>:ud   r65.0<0;1,0>:uw 
        mach (8|M0)              r26.0<1>:ud   r96.0<1;1,0>:ud   r65.0<0;1,0>:ud  {Compacted}
(W)     mul (8|M8)               acc0.0<1>:ud  r97.0<1;1,0>:ud   r65.0<0;1,0>:uw 
        and (16|M16)             r24.0<1>:d    r24.0<1;1,0>:d    28:w               {Compacted}
        bfn.0xFE (16|M0)         r4.0<1>:ud    r2.0<1;0>:ud      r18.0<1;0>:ud     r70.0<1>:ud      {I@7} // s0|s1|s2
        shl (16|M16)             r22.0<1>:d    r22.0<1;1,0>:d    5:w               {Compacted,I@7}
        mach (8|M8)              r27.0<1>:ud   r97.0<1;1,0>:ud   r65.0<0;1,0>:ud  {Compacted}
(W)     mul (8|M16)              acc0.0<1>:ud  r98.0<1;1,0>:ud   r65.0<0;1,0>:uw 
        mach (8|M16)             r12.0<1>:ud   r98.0<1;1,0>:ud   r65.0<0;1,0>:ud  {Compacted}
(W)     mul (8|M24)              acc0.0<1>:ud  r99.0<1;1,0>:ud   r65.0<0;1,0>:uw 
        bfn.0xFE (16|M16)        r14.0<1>:ud   r22.0<1;0>:ud     r24.0<1;0>:ud     r72.0<1>:ud      {I@5} // s0|s1|s2
        mach (8|M24)             r13.0<1>:ud   r99.0<1;1,0>:ud   r65.0<0;1,0>:ud  {Compacted}
(W)     mul (8|M0)               acc0.0<1>:d   r4.0<1;1,0>:d     r8.12<0;1,0>:uw  {Compacted}
        mach (8|M0)              r4.0<1>:d     r4.0<1;1,0>:d     r8.6<0;1,0>:d    {Compacted}
(W)     mul (8|M8)               acc0.0<1>:d   r5.0<1;1,0>:d     r8.12<0;1,0>:uw 
        mach (8|M8)              r5.0<1>:d     r5.0<1;1,0>:d     r8.6<0;1,0>:d    {Compacted}
(W)     mul (8|M16)              acc0.0<1>:d   r14.0<1;1,0>:d    r8.12<0;1,0>:uw  {I@6}
        mach (8|M16)             r14.0<1>:d    r14.0<1;1,0>:d    r8.6<0;1,0>:d    {Compacted}
(W)     mul (8|M24)              acc0.0<1>:d   r15.0<1;1,0>:d    r8.12<0;1,0>:uw 
        mach (8|M24)             r15.0<1>:d    r15.0<1;1,0>:d    r8.6<0;1,0>:d    {Compacted}
(W)     mov (1|M0)               a0.0<1>:ud    r9.5<0;1,0>:d                    {A@1}
        shl (16|M0)              r2.0<1>:d     r92.0<1;1,0>:d    3:w               {Compacted}
        shl (16|M16)             r18.0<1>:d    r94.0<1;1,0>:d    3:w               {Compacted}
        add3 (16|M0)             r4.0<1>:d     r26.0<1;0>:d      r9.3<0;0>:d       r4.0<1>:d        {I@7}
        add3 (16|M16)            r14.0<1>:d    r12.0<1;0>:d      r9.3<0;0>:d       r14.0<1>:d       {I@5}
        add3 (16|M0)             r22.0<1>:d    r4.0<1;0>:d       r2.0<1;0>:d       r74.0<1>:d       {I@2}
        add3 (16|M16)            r24.0<1>:d    r14.0<1;0>:d      r18.0<1;0>:d      r76.0<1>:d       {I@2}
        send.ugm (16|M0)         r28      r22     null:0  a0.0        0x24280900           {ExBSO,A@2,$7} // wr:2+0, rd:2; load.ugm.d8u32.a32.ca.ca.bss[a0.0]
        send.ugm (16|M16)        r30      r24     null:0  a0.0        0x24280900           {ExBSO,A@1,$8} // wr:2+0, rd:2; load.ugm.d8u32.a32.ca.ca.bss[a0.0]
(W)     mov (1|M0)               a0.0<1>:ud    r9.4<0;1,0>:d                    {A@1}
        add (16|M0)              r32.0<1>:d    r66.0<1;1,0>:d    r9.2<0;1,0>:d    {Compacted}
        add (16|M16)             r34.0<1>:d    r68.0<1;1,0>:d    r9.2<0;1,0>:d    {Compacted}
(W)     mov (8|M0)               r127.0<1>:f   r64.0<1;1,0>:f                   {Compacted}
        add (16|M16)             r38.0<1>:d    r20.0<1;1,0>:d    r16.0<1;1,0>:d   {Compacted}
        mov (16|M0)              r36.0<1>:ud   r28.0<4;1,0>:ub                  {$7.dst}
        mov (16|M16)             r26.0<1>:ud   r30.0<4;1,0>:ub                  {$8.dst}
        send.ugm (16|M0)         null     r32     r36:2   a0.0        0x240E0904           {ExBSO,A@2,$9} // wr:2+2, rd:0; store.ugm.d8u32.a32.wb.wb.bss[a0.0]
        send.ugm (16|M16)        null     r34     r26:2   a0.0        0x240E0904           {ExBSO,A@1,$10} // wr:2+2, rd:0; store.ugm.d8u32.a32.wb.wb.bss[a0.0]
        add (16|M0)              r12.0<1>:d    r10.0<1;1,0>:d    r6.0<1;1,0>:d    {Compacted}
(W)     send.gtwy (1|M0)         null     r127    null:0  0x0            0x02000010           {EOT,A@1} // wr:1+0, rd:0; end of thread
L8136:
        nop                    
(W)     mov (16|M0)              null<1>:ud    0x6F9278B:ud                             
(W)     mov (16|M0)              null<1>:ud    0x6180031B:ud                             
(W)     mov (16|M0)              null<1>:ud    0x0:ud                             
(W)     mov (16|M0)              null<1>:ud    0x4:ud                             
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
