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
(W)     mov (8|M0)               r77.0<1>:ud   r0.0<1;1,0>:ud                  
(W)     or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x4C0:uw              {A@1}
        sync.nop                             null                             {Compacted,A@1}
        sync.nop                             null                             {Compacted,$2.dst}
(W)     mov (2|M0)               r78.0<1>:d    r8.2<1;1,0>:d                    {A@1}
(W)     mul (1|M0)               acc0.0<1>:d   r7.3<0;1,0>:d     r77.2<0;1,0>:uw  {I@3}
(W)     cmp (16|M0)   (lt)f1.0   null<1>:d     r78.1<0;1,0>:ud   0x1:uw              {I@2}
(W)     cmp (16|M16)  (lt)f1.0   null<1>:d     r78.1<0;1,0>:ud   0x1:uw             
(W)     mach (1|M0)              r3.0<1>:d     r7.3<0;1,0>:d     r77.1<0;1,0>:d   {$0.dst}
(W)     mov (1|M0)               r78.2<1>:f    0xCF800000:f                               {Compacted}
(W)     mov (1|M0)               r78.3<1>:f    1.048576e+06:f                               {Compacted}
(W)     mov (1|M0)               r78.4<1>:f    -1.048576e+06:f                               {Compacted}
(W)     mov (1|M0)               r78.5<1>:f    -1.0:f                               {Compacted}
(W)     mov (1|M0)               r78.6<1>:f    0x53800000:f                               {Compacted}
(W)     mov (1|M0)               r78.7<1>:f    1.463628e-39:f                              
(W)     mov (1|M0)               r83.0<1>:f    -4.172325e-07:f                               {Compacted}
        add3 (16|M0)             r79.0<1>:d    r3.0<0;0>:d       r1.0<1;0>:uw      r7.0<0>:d        {I@1}
        add3 (16|M16)            r81.0<1>:d    r3.0<0;0>:d       r2.0<1;0>:uw      r7.0<0>:d       
(f1.0)  goto (32|M0)                         L2536                  L2536                
L496:
(W)     shr (1|M0)               r2.0<1>:ud    r78.0<0;1,0>:ud   20:w              
(W)     shl (1|M0)               r3.0<1>:d     r78.1<0;1,0>:d    12:w               {Compacted}
(W)     and (1|M0)               r9.0<1>:d     r78.0<0;1,0>:d    1048575:d              
(W)     or (1|M0)                r4.0<1>:d     r2.0<0;1,0>:d     r3.0<0;1,0>:d    {Compacted,I@2}
(W)     shr (1|M0)               r5.0<1>:ud    r78.1<0;1,0>:ud   8:w               {$1.dst}
(W)     bfn.0xF8 (1|M0)          r7.0<1>:ud    r4.0<0;0>:ud      r78.7<0;0>:ud     r2.0<0>:ud       {A@2} // s0&s1|s2
(W)     mov (1|M0)               r10.0<1>:f    r9.0<0;1,0>:ud                   {Compacted}
(W)     mov (1|M0)               r8.0<1>:f     r7.0<0;1,0>:ud                   {Compacted,I@1}
(W)     mov (1|M0)               r6.0<1>:f     r5.0<0;1,0>:ud                   {Compacted}
(W)     mad (1|M0)               r11.0<1>:f    r10.0<0;0>:f      r78.3<0;0>:f      r8.0<0>:f        {Compacted,F@2}
(W)     mov (1|M0)               r17.0<1>:ud   0x0:ud                             
(W)     mad (1|M0)               r12.0<1>:f    r11.0<0;0>:f      r78.6<0;0>:f      r6.0<0>:f        {Compacted,F@1}
        shr (16|M0)              r21.0<1>:ud   r79.0<1;1,0>:ud   20:w              
        sync.nop                             null                             {Compacted,F@1}
(W)     math.inv (1|M0)          r13.0<1>:f    r12.0<0;1,0>:f                   {$3}
(W)     mad (1|M0)               r14.0<1>:f    r13.0<0;0>:f      r83.0<0;0>:f      r13.0<0>:f       {Compacted,$3.dst}
(W)     mul (1|M0)               r19.0<1>:f    r8.0<0;1,0>:f     -1.048576e+06:f               {Compacted}
(W)     mul (1|M0)               r15.0<1>:f    r14.0<0;1,0>:f    0.0:f               {Compacted,F@2}
        shr (16|M16)             r23.0<1>:ud   r81.0<1;1,0>:ud   20:w              
(W)     rndd (1|M0)              r16.0<1>:f    r15.0<0;1,0>:f                   {Compacted,F@1}
        mov (16|M0)              r25.0<1>:f    r21.0<1;1,0>:ud                  {Compacted,I@2}
(W)     mad (1|M0)               r18.0<1>:f    r17.0<0;0>:f      r16.0<0;0>:f      -r10.0<0>:f      {Compacted,F@2}
        mov (16|M16)             r27.0<1>:f    r23.0<1;1,0>:ud                  {Compacted,I@1}
(W)     mad (1|M0)               r20.0<1>:f    r18.0<0;0>:f      r16.0<0;0>:f      r19.0<0>:f       {Compacted,F@2}
(W)     mul (1|M0)               r46.0<1>:f    r10.0<0;1,0>:f    9.536743e-07:f               {Compacted}
        mad (16|M0)              acc0.0<1>:f   r25.0<1;0>:f      r78.3<0;0>:f      r20.0<0>:f       {Compacted,F@2}
        mad (16|M16)             acc2.0<1>:f   r27.0<1;0>:f      r78.3<0;0>:f      r20.0<0>:f      
        mul (16|M0)              acc0.0<1>:f   r14.0<0;1,0>:f    acc0.0<1;1,0>:f 
        mul (16|M16)             acc2.0<1>:f   r14.0<0;1,0>:f    acc2.0<1;1,0>:f 
        rndd (16|M0)             r33.0<1>:f    acc0.0<1;1,0>:f                  {Compacted}
        rndd (16|M16)            r35.0<1>:f    acc2.0<1;1,0>:f                  {Compacted}
        mul (16|M0)              acc0.0<1>:f   r46.0<0;1,0>:f    r33.0<1;1,0>:f   {Compacted,F@2}
        mul (16|M16)             acc2.0<1>:f   r46.0<0;1,0>:f    r35.0<1;1,0>:f   {Compacted,F@2}
        rndd (16|M0)             acc0.0<1>:f   acc0.0<1;1,0>:f                 
        and (16|M0)              r67.0<1>:d    r79.0<1;1,0>:d    1048575:d              
(W)     mul (1|M0)               r41.0<1>:f    r6.0<0;1,0>:f     -1.048576e+06:f               {Compacted}
        mad (16|M0)              r37.0<1>:f    r20.0<0;0>:f      r33.0<1;0>:f      -r8.0<0>:f       {Compacted}
        rndd (16|M16)            acc2.0<1>:f   acc2.0<1;1,0>:f                 
        mad (16|M0)              r55.0<1>:f    -acc0.0<1;0>:f    r33.0<1;0>:f      r46.0<0>:f      
        and (16|M16)             r69.0<1>:d    r81.0<1;1,0>:d    1048575:d              
        mad (16|M16)             r39.0<1>:f    r20.0<0;0>:f      r35.0<1;0>:f      -r8.0<0>:f       {Compacted}
        mov (16|M0)              r71.0<1>:f    r67.0<1;1,0>:ud                  {Compacted,I@2}
        mad (16|M0)              r42.0<1>:f    r37.0<1;0>:f      r33.0<1;0>:f      r41.0<0>:f       {Compacted,F@5}
        mad (16|M16)             r57.0<1>:f    -acc2.0<1;0>:f    r35.0<1;0>:f      r46.0<0>:f      
        mad (16|M0)              r63.0<1>:f    r25.0<1;0>:f      r55.0<1;0>:f      r78.4<0>:f       {Compacted,F@5}
        mov (16|M16)             r73.0<1>:f    r69.0<1;1,0>:ud                  {Compacted,I@1}
        mad (16|M16)             r44.0<1>:f    r39.0<1;0>:f      r35.0<1;0>:f      r41.0<0>:f       {Compacted,F@6}
        mad (16|M0)              r59.0<1>:f    r42.0<1;0>:f      acc0.0<1;0>:f     r78.5<0>:f       {Compacted,F@5}
        mad (16|M16)             r65.0<1>:f    r27.0<1;0>:f      r57.0<1;0>:f      r78.4<0>:f       {Compacted,F@5}
        mad (16|M0)              acc0.0<1>:f   r71.0<1;0>:f      r63.0<1;0>:f      r78.3<0>:f       {Compacted,F@5}
        mad (16|M16)             r61.0<1>:f    r44.0<1;0>:f      acc2.0<1;0>:f     r78.5<0>:f       {Compacted,F@4}
        mad (16|M16)             acc2.0<1>:f   r73.0<1;0>:f      r65.0<1;0>:f      r78.3<0>:f       {F@3}
        mad (16|M0)              acc0.0<1>:f   acc0.0<1;0>:f     r59.0<1;0>:f      r78.6<0>:f       {Compacted}
        mad (16|M16)             acc2.0<1>:f   acc2.0<1;0>:f     r61.0<1;0>:f      r78.6<0>:f       {F@3}
        mul (16|M0)              acc0.0<1>:f   r14.0<0;1,0>:f    acc0.0<1;1,0>:f 
(W)     mul (1|M0)               r49.0<1>:f    r8.0<0;1,0>:f     9.536743e-07:f               {Compacted}
        mul (16|M16)             acc2.0<1>:f   r14.0<0;1,0>:f    acc2.0<1;1,0>:f 
        rndd (16|M0)             r17.0<1>:f    acc0.0<1;1,0>:f                  {Compacted}
        rndd (16|M16)            r19.0<1>:f    acc2.0<1;1,0>:f                  {Compacted}
        mul (16|M0)              acc0.0<1>:f   r46.0<0;1,0>:f    r17.0<1;1,0>:f   {Compacted,F@2}
        mul (16|M0)              acc2.0<1>:f   r49.0<0;1,0>:f    r17.0<1;1,0>:f   {Compacted}
        mul (16|M16)             r27.0<1>:f    r46.0<0;1,0>:f    r19.0<1;1,0>:f   {Compacted,F@3}
        mul (16|M16)             r52.0<1>:f    r49.0<0;1,0>:f    r19.0<1;1,0>:f   {Compacted}
        rndd (16|M0)             acc0.0<1>:f   acc0.0<1;1,0>:f                 
        rndd (16|M0)             acc2.0<1>:f   acc2.0<1;1,0>:f                 
        mad (16|M0)              r21.0<1>:f    r59.0<1;0>:f      r17.0<1;0>:f      -r6.0<0>:f       {Compacted}
        rndd (16|M16)            r31.0<1>:f    r27.0<1;1,0>:f                   {Compacted,F@5}
        rndd (16|M16)            r56.0<1>:f    r52.0<1;1,0>:f                   {Compacted,F@5}
        mad (16|M0)              r41.0<1>:f    r63.0<1;0>:f      acc0.0<1;0>:f     r78.5<0>:f       {Compacted}
        mad (16|M0)              r58.0<1>:f    -acc2.0<1;0>:f    r17.0<1;0>:f      r49.0<0>:f      
        mad (16|M16)             r23.0<1>:f    r61.0<1;0>:f      r19.0<1;0>:f      -r6.0<0>:f       {Compacted}
        mad (16|M0)              r37.0<1>:f    -acc0.0<1;0>:f    r17.0<1;0>:f      r46.0<0>:f      
        mad (16|M16)             r43.0<1>:f    r65.0<1;0>:f      r31.0<1;0>:f      r78.5<0>:f       {Compacted,F@6}
        mad (16|M16)             r60.0<1>:f    -r56.0<1;0>:f     r19.0<1;0>:f      r49.0<0>:f       {Compacted,F@6}
        mad (16|M0)              r62.0<1>:f    r21.0<1;0>:f      acc2.0<1;0>:f     r78.5<0>:f       {Compacted}
        mad (16|M0)              r66.0<1>:f    r41.0<1;0>:f      r58.0<1;0>:f      r78.4<0>:f       {Compacted,F@6}
        mad (16|M16)             acc2.0<1>:f   -r31.0<1;0>:f     r19.0<1;0>:f      r46.0<0>:f      
        mad (16|M16)             acc0.0<1>:f   r23.0<1;0>:f      r56.0<1;0>:f      r78.5<0>:f       {F@7}
        mad (16|M16)             r68.0<1>:f    r43.0<1;0>:f      r60.0<1;0>:f      r78.4<0>:f       {Compacted,F@5}
        mad (16|M0)              r4.0<1>:f     r66.0<1;0>:f      r62.0<1;0>:f      r78.3<0>:f       {Compacted,F@4}
        mad (16|M0)              r45.0<1>:f    r71.0<1;0>:f      r37.0<1;0>:f      r78.4<0>:f       {Compacted}
(W)     mov (1|M0)               r70.0<1>:d    r16.0<0;1,0>:f                   {Compacted}
        mad (16|M16)             r47.0<1>:f    r73.0<1;0>:f      acc2.0<1;0>:f     r78.4<0>:f       {Compacted}
        mad (16|M16)             r11.0<1>:f    r68.0<1;0>:f      acc0.0<1;0>:f     r78.3<0>:f       {Compacted,F@4}
        mad (16|M0)              acc2.0<1>:f   r45.0<1;0>:f      r4.0<1;0>:f       r78.3<0>:f       {Compacted,F@3}
        mov (16|M0)              r75.0<1>:d    r17.0<1;1,0>:f                   {Compacted}
        mul (16|M0)              r15.0<1>:f    r14.0<0;1,0>:f    acc2.0<1;1,0>:f  {I@2}
        mad (16|M16)             acc2.0<1>:f   r47.0<1;0>:f      r11.0<1;0>:f      r78.3<0>:f       {F@3}
        mov (16|M16)             r2.0<1>:d     r19.0<1;1,0>:f                   {Compacted}
        mul (16|M16)             acc2.0<1>:f   r14.0<0;1,0>:f    acc2.0<1;1,0>:f 
        rndd (16|M0)             r19.0<1>:f    r15.0<1;1,0>:f                   {Compacted,A@1}
        rndd (16|M16)            r21.0<1>:f    acc2.0<1;1,0>:f                  {Compacted}
        mad (16|M0)              acc2.0<1>:f   r62.0<1;0>:f      -r19.0<1;0>:f     r6.0<0>:f        {Compacted,F@2}
        mad (16|M16)             r25.0<1>:f    acc0.0<1;0>:f     -r21.0<1;0>:f     r6.0<0>:f        {F@2}
        mul (16|M0)              r63.0<1>:f    acc2.0<1;1,0>:f   0x2F800000:f               {Compacted}
        mad (16|M0)              r27.0<1>:f    r66.0<1;0>:f      -r19.0<1;0>:f     r8.0<0>:f        {Compacted}
        mad (16|M16)             r29.0<1>:f    r68.0<1;0>:f      -r21.0<1;0>:f     r8.0<0>:f        {Compacted}
        rndz (16|M0)             r67.0<1>:f    r63.0<1;1,0>:f                   {Compacted,F@3}
        mad (16|M0)              r31.0<1>:f    r45.0<1;0>:f      -r19.0<1;0>:f     r10.0<0>:f       {Compacted}
        mul (16|M16)             r65.0<1>:f    r25.0<1;1,0>:f    0x2F800000:f               {Compacted}
        mad (16|M0)              r6.0<1>:f     acc2.0<1;0>:f     r67.0<1;0>:f      r78.2<0>:f       {Compacted,F@3}
        mov (16|M0)              r43.0<1>:d    r31.0<1;1,0>:f                   {Compacted,F@3}
        rndz (16|M16)            acc2.0<1>:f   r65.0<1;1,0>:f                   {F@2}
        mov (16|M0)              r12.0<1>:ud   r6.0<1;1,0>:f                    {F@2}
        mov (16|M0)              r71.0<1>:d    r33.0<1;1,0>:f                   {Compacted}
        asr (16|M0)              r59.0<1>:d    r43.0<1;1,0>:d    31:w               {Compacted,I@3}
        addc (8|M0)              r16.0<1>:ud   r43.0<1;1,0>:ud   0x0:ud              {AccWrEn,Compacted}
        shl (16|M0)              r12.0<1>:d    r12.0<1;1,0>:d    8:w               {Compacted,I@4}
        mad (16|M16)             r33.0<1>:f    r47.0<1;0>:f      -r21.0<1;0>:f     r10.0<0>:f       {Compacted,I@4}
        mad (16|M16)             r10.0<1>:f    r25.0<1;0>:f      acc2.0<1;0>:f     r78.2<0>:f       {Compacted}
        mov (16|M0)              r39.0<1>:d    r27.0<1;1,0>:f                   {Compacted}
        add3 (8|M0)              r18.0<1>:ud   acc0.0<1;0>:ud    r12.0<1;0>:ud     r59.0<1>:ud      {I@2}
        mov (16|M16)             r45.0<1>:d    r33.0<1;1,0>:f                   {Compacted,F@2}
        mov (16|M16)             r14.0<1>:ud   r10.0<1;1,0>:f                   {F@1}
        addc (8|M8)              r17.0<1>:ud   r44.0<1;1,0>:ud   0x0:ud              {AccWrEn}
        mov (16|M16)             r73.0<1>:d    r35.0<1;1,0>:f                   {Compacted}
        asr (16|M0)              r47.0<1>:d    r39.0<1;1,0>:d    31:w               {Compacted,I@6}
        asr (16|M16)             r61.0<1>:d    r45.0<1;1,0>:d    31:w               {Compacted,I@5}
        shl (16|M16)             r14.0<1>:d    r14.0<1;1,0>:d    8:w               {Compacted,I@5}
        mov (16|M0)              r35.0<1>:d    r19.0<1;1,0>:f                   {Compacted}
        add3 (8|M8)              r19.0<1>:ud   acc0.0<1;0>:ud    r13.0<1;0>:ud     r60.0<1>:ud     
        addc (8|M16)             r20.0<1>:ud   r45.0<1;1,0>:ud   0x0:ud              {AccWrEn}
        mov (16|M16)             r37.0<1>:d    r21.0<1;1,0>:f                   {Compacted}
        mov (16|M16)             r41.0<1>:d    r29.0<1;1,0>:f                   {Compacted}
        shl (16|M0)              r51.0<1>:d    r39.0<1;1,0>:d    20:w               {Compacted}
        shl (16|M0)              r47.0<1>:d    r47.0<1;1,0>:d    20:w               {Compacted,I@7}
        add3 (8|M16)             r22.0<1>:ud   acc0.0<1;0>:ud    r14.0<1;0>:ud     r61.0<1>:ud      {I@7}
        shr (16|M0)              r39.0<1>:ud   r39.0<1;1,0>:ud   12:w              
        addc (8|M24)             r21.0<1>:ud   r46.0<1;1,0>:ud   0x0:ud              {AccWrEn}
        asr (16|M16)             r49.0<1>:d    r41.0<1;1,0>:d    31:w               {Compacted,I@6}
        or (16|M0)               r55.0<1>:d    r47.0<1;1,0>:d    r39.0<1;1,0>:d   {Compacted,I@3}
        add3 (8|M24)             r23.0<1>:ud   acc0.0<1;0>:ud    r15.0<1;0>:ud     r62.0<1>:ud     
        addc (8|M0)              r24.0<1>:ud   r16.0<1;1,0>:ud   r51.0<1;1,0>:ud  {AccWrEn,Compacted}
        shl (16|M16)             r53.0<1>:d    r41.0<1;1,0>:d    20:w               {Compacted}
        shl (16|M16)             r49.0<1>:d    r49.0<1;1,0>:d    20:w               {Compacted,I@5}
        add3 (8|M0)              r26.0<1>:ud   acc0.0<1;0>:ud    r18.0<1;0>:ud     r55.0<1>:ud      {I@5}
        shr (16|M16)             r41.0<1>:ud   r41.0<1;1,0>:ud   12:w              
        addc (8|M8)              r25.0<1>:ud   r17.0<1;1,0>:ud   r52.0<1;1,0>:ud  {AccWrEn}
        or (16|M16)              r57.0<1>:d    r49.0<1;1,0>:d    r41.0<1;1,0>:d   {Compacted,I@2}
        add3 (8|M8)              r27.0<1>:ud   acc0.0<1;0>:ud    r19.0<1;0>:ud     r56.0<1>:ud     
        cmp (16|M0)   (ge)f1.0   null<1>:d     r24.0<1;1,0>:ud   r78.0<0;1,0>:ud  {I@3}
        addc (8|M16)             r28.0<1>:ud   r20.0<1;1,0>:ud   r53.0<1;1,0>:ud  {AccWrEn}
        shl (16|M0)              r33.0<1>:d    r71.0<1;1,0>:d    20:w               {Compacted}
        add3 (8|M16)             r30.0<1>:ud   acc0.0<1;0>:ud    r22.0<1;0>:ud     r57.0<1>:ud      {I@5}
        addc (8|M24)             r29.0<1>:ud   r21.0<1;1,0>:ud   r54.0<1;1,0>:ud  {AccWrEn}
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r26.0<1;1,0>:d    r78.1<0;1,0>:d   {I@6}
        cmp (16|M16)  (ge)f1.0   null<1>:d     r28.0<1;1,0>:ud   r78.0<0;1,0>:ud  {I@2}
        add3 (8|M24)             r31.0<1>:ud   acc0.0<1;0>:ud    r23.0<1;0>:ud     r58.0<1>:ud     
(W)     shl (1|M0)               r32.0<1>:d    r70.0<0;1,0>:d    8:w               {Compacted}
        shr (16|M0)              r41.0<1>:ud   r71.0<1;1,0>:ud   12:w              
(~f1.0) cmp (16|M0)   (gt)f1.0   null<1>:d     r26.0<1;1,0>:ud   r78.1<0;1,0>:ud 
        addc (8|M0)              r45.0<1>:ud   r33.0<1;1,0>:ud   0x0:ud              {AccWrEn,Compacted}
(f1.0)  cmp (16|M16)  (eq)f1.0   null<1>:d     r30.0<1;1,0>:d    r78.1<0;1,0>:d   {I@5}
        shl (16|M16)             r39.0<1>:d    r73.0<1;1,0>:d    20:w               {Compacted}
(W)     mov (1|M0)               r53.0<1>:w    -1:w                              
        add3 (8|M0)              r47.0<1>:ud   acc0.0<1;0>:ud    r41.0<1;0>:ud     r32.0<0>:ud      {I@6}
        addc (8|M8)              r46.0<1>:ud   r34.0<1;1,0>:ud   0x0:ud              {AccWrEn}
        shr (16|M16)             r43.0<1>:ud   r73.0<1;1,0>:ud   12:w              
(~f1.0) cmp (16|M16)  (gt)f1.0   null<1>:d     r30.0<1;1,0>:ud   r78.1<0;1,0>:ud 
(f1.0)  sel (16|M0)              r54.0<1>:d    r53.0<0;1,0>:w    0:w               {I@5}
        add3 (8|M8)              r48.0<1>:ud   acc0.0<1;0>:ud    r42.0<1;0>:ud     r32.0<0>:ud     
        addc (8|M16)             r49.0<1>:ud   r39.0<1;1,0>:ud   0x0:ud              {AccWrEn}
        add3 (16|M0)             r58.0<1>:d    r35.0<1;0>:d      r75.0<1;0>:d      -r54.0<1>:d      {I@3}
        add3 (8|M16)             r51.0<1>:ud   acc0.0<1;0>:ud    r43.0<1;0>:ud     r32.0<0>:ud     
        addc (8|M24)             r50.0<1>:ud   r40.0<1;1,0>:ud   0x0:ud              {AccWrEn}
(f1.0)  sel (16|M16)             r56.0<1>:d    r53.0<0;1,0>:w    0:w              
        add3 (8|M24)             r52.0<1>:ud   acc0.0<1;0>:ud    r44.0<1;0>:ud     r32.0<0>:ud     
        addc (8|M0)              r84.0<1>:ud   r45.0<1;1,0>:ud   r58.0<1;1,0>:ud  {AccWrEn,Compacted,I@5}
        add3 (16|M16)            r60.0<1>:d    r37.0<1;0>:d      r2.0<1;0>:d       -r56.0<1>:d      {I@3}
        add (8|M0)               r88.0<1>:ud   acc0.0<1;1,0>:ud  r47.0<1;1,0>:ud 
        addc (8|M8)              r85.0<1>:ud   r46.0<1;1,0>:ud   r59.0<1;1,0>:ud  {AccWrEn}
        add (8|M8)               r89.0<1>:ud   acc0.0<1;1,0>:ud  r48.0<1;1,0>:ud 
        addc (8|M16)             r86.0<1>:ud   r49.0<1;1,0>:ud   r60.0<1;1,0>:ud  {AccWrEn,I@4}
        add (8|M16)              r90.0<1>:ud   acc0.0<1;1,0>:ud  r51.0<1;1,0>:ud 
        addc (8|M24)             r87.0<1>:ud   r50.0<1;1,0>:ud   r61.0<1;1,0>:ud  {AccWrEn}
        add (8|M24)              r91.0<1>:ud   acc0.0<1;1,0>:ud  r52.0<1;1,0>:ud 
        goto (32|M0)                         L2536                  L3296                
L2536:
        join (32|M0)                         L3296                                
L2552:
(W)     cmp (16|M0)   (eq)f0.0   null<1>:d     r78.0<0;1,0>:d    0:w               {Compacted}
(W)     cmp (16|M16)  (eq)f0.0   null<1>:d     r78.0<0;1,0>:d    0:w              
(f0.0)  goto (32|M0)                         L3200                  L3200                
L2592:
(W)     xor (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x30:uw              {A@1}
(W)     mov (1|M0)               r2.0<1>:f     r78.0<0;1,0>:ud                  {Compacted,A@1}
(W)     mov (1|M0)               r13.0<1>:f    0xB4C00000:f                               {Compacted}
(W)     math.inv (1|M0)          r12.0<1>:f    r2.0<0;1,0>:f                    {@2,$4}
        mov (16|M0)              r5.0<1>:f     r79.0<1;1,0>:ud                  {Compacted,$1.dst}
        sync.nop                             null                             {Compacted,$4.dst}
(W)     mad (1|M0)               r14.0<1>:f    r12.0<0;0>:f      r13.0<0;0>:f      r12.0<0>:f       {Compacted,F@2}
        mov (16|M16)             r10.0<1>:f    r81.0<1;1,0>:ud                  {Compacted}
(W)     mov (1|M0)               r3.0<1>:ud    r2.0<0;1,0>:f                   
        mov (16|M0)              r19.0<1>:ud   r5.0<1;1,0>:f                    {F@3}
        mul (16|M0)              r15.0<1>:f    r5.0<1;1,0>:f     r14.0<0;1,0>:f   {Compacted,F@2}
        mul (16|M16)             r17.0<1>:f    r10.0<1;1,0>:f    r14.0<0;1,0>:f   {Compacted,F@2}
        mov (16|M16)             r21.0<1>:ud   r10.0<1;1,0>:f                  
(W)     add (1|M0)               r4.0<1>:d     r78.0<0;1,0>:d    -r3.0<0;1,0>:d   {Compacted,I@3}
        add (16|M0)              r19.0<1>:d    r79.0<1;1,0>:d    -r19.0<1;1,0>:d  {Compacted,I@3}
        mov (16|M0)              r23.0<1>:ud   r15.0<1;1,0>:f                   {F@2}
        mov (16|M16)             r25.0<1>:ud   r17.0<1;1,0>:f                   {F@1}
        add (16|M16)             r21.0<1>:d    r81.0<1;1,0>:d    -r21.0<1;1,0>:d  {Compacted,I@5}
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
(W)     mul (8|M0)               acc0.0<1>:d   r56.0<1;1,0>:d    r78.0<0;1,0>:uw  {Compacted,I@2}
        mach (8|M0)              r56.0<1>:d    r56.0<1;1,0>:d    r78.0<0;1,0>:d   {Compacted}
(W)     mul (8|M8)               acc0.0<1>:d   r57.0<1;1,0>:d    r78.0<0;1,0>:uw 
        mach (8|M8)              r57.0<1>:d    r57.0<1;1,0>:d    r78.0<0;1,0>:d   {Compacted}
(W)     mul (8|M16)              acc0.0<1>:d   r58.0<1;1,0>:d    r78.0<0;1,0>:uw  {I@5}
        mach (8|M16)             r58.0<1>:d    r58.0<1;1,0>:d    r78.0<0;1,0>:d   {Compacted}
(W)     mul (8|M24)              acc0.0<1>:d   r59.0<1;1,0>:d    r78.0<0;1,0>:uw 
        mach (8|M24)             r59.0<1>:d    r59.0<1;1,0>:d    r78.0<0;1,0>:d   {Compacted}
        add (16|M0)              r56.0<1>:d    r79.0<1;1,0>:d    -r56.0<1;1,0>:d  {Compacted,I@5}
        add (16|M16)             r58.0<1>:d    r81.0<1;1,0>:d    -r58.0<1;1,0>:d  {Compacted,I@2}
        cmp (16|M0)   (ge)f1.0   r60.0<1>:ud   r56.0<1;1,0>:ud   r78.0<0;1,0>:ud  {I@2}
        cmp (16|M16)  (ge)f1.0   r62.0<1>:ud   r58.0<1;1,0>:ud   r78.0<0;1,0>:ud  {I@2}
        add3 (16|M0)             r84.0<1>:d    r52.0<1;0>:d      r23.0<1;0>:d      -r60.0<1>:d      {I@2}
        add3 (16|M16)            r86.0<1>:d    r54.0<1;0>:d      r25.0<1;0>:d      -r62.0<1>:d      {I@2}
        goto (32|M0)                         L3200                  L3248                
L3200:
        join (32|M0)                         L3248                                
L3216:
        mov (16|M0)              r84.0<1>:d    -1:w                              
        mov (16|M16)             r86.0<1>:d    -1:w                              
L3248:
        join (32|M0)                         L3296                                
L3264:
        mov (16|M0)              r88.0<1>:d    0:w                              
        mov (16|M16)             r90.0<1>:d    0:w                              
L3296:
        join (32|M0)                         L3312                                
L3312:
        mul (8|M0)               acc0.0<1>:ud  r84.0<1;1,0>:ud   r78.0<0;1,0>:uw  {I@6}
        mach (8|M0)              r2.0<1>:ud    r84.0<1;1,0>:ud   r78.0<0;1,0>:ud  {AccWrEn,Compacted}
(W)     mov (1|M0)               r24.0<1>:hf   0.0:hf                             
        mov (8|M0)               r4.0<1>:ud    acc0.0<1;1,0>:ud                 {Compacted}
        mul (8|M8)               acc0.0<1>:ud  r85.0<1;1,0>:ud   r78.0<0;1,0>:uw 
        mach (8|M8)              r3.0<1>:ud    r85.0<1;1,0>:ud   r78.0<0;1,0>:ud  {AccWrEn}
(W)     asr (1|M0)               r83.1<1>:d    r8.6<0;1,0>:d     31:w              
        mov (8|M8)               r5.0<1>:ud    acc0.0<1;1,0>:ud                 {Compacted,$1.dst}
(W)     mul (8|M0)               acc0.0<1>:d   r84.0<1;1,0>:ud   r78.2<0;1,0>:uw 
        mach (8|M0)              r6.0<1>:d     r84.0<1;1,0>:ud   r78.1<0;1,0>:d  
(W)     mul (8|M8)               acc0.0<1>:d   r85.0<1;1,0>:ud   r78.2<0;1,0>:uw 
        mach (8|M8)              r7.0<1>:d     r85.0<1;1,0>:ud   r78.1<0;1,0>:d  
(W)     mul (8|M0)               acc0.0<1>:d   r78.0<0;1,0>:ud   r88.0<2;1,0>:uw 
        add (16|M0)              r10.0<1>:d    r2.0<1;1,0>:d     r6.0<1;1,0>:d    {Compacted,I@2}
        mach (8|M0)              r6.0<1>:d     r78.0<0;1,0>:ud   r88.0<1;1,0>:d  
(W)     mul (8|M8)               acc0.0<1>:d   r78.0<0;1,0>:ud   r89.0<2;1,0>:uw 
        mach (8|M8)              r7.0<1>:d     r78.0<0;1,0>:ud   r89.0<1;1,0>:d  
        mul (8|M16)              acc0.0<1>:ud  r86.0<1;1,0>:ud   r78.0<0;1,0>:uw 
        mach (8|M16)             r14.0<1>:ud   r86.0<1;1,0>:ud   r78.0<0;1,0>:ud  {AccWrEn}
        mov (16|M0)              r92.0<1>:f    r4.0<1;1,0>:f                    {Compacted}
        mov (8|M16)              r16.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mul (8|M24)              acc0.0<1>:ud  r87.0<1;1,0>:ud   r78.0<0;1,0>:uw 
        mach (8|M24)             r15.0<1>:ud   r87.0<1;1,0>:ud   r78.0<0;1,0>:ud  {AccWrEn}
        add (16|M0)              r12.0<1>:d    r10.0<1;1,0>:d    r6.0<1;1,0>:d    {Compacted,I@6}
        mov (8|M24)              r17.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
(W)     mul (8|M16)              acc0.0<1>:d   r86.0<1;1,0>:ud   r78.2<0;1,0>:uw 
        mach (8|M16)             r18.0<1>:d    r86.0<1;1,0>:ud   r78.1<0;1,0>:d  
(W)     mul (8|M24)              acc0.0<1>:d   r87.0<1;1,0>:ud   r78.2<0;1,0>:uw 
        mach (8|M24)             r19.0<1>:d    r87.0<1;1,0>:ud   r78.1<0;1,0>:d  
(W)     mul (8|M16)              acc0.0<1>:d   r78.0<0;1,0>:ud   r90.0<2;1,0>:uw 
        add (16|M16)             r20.0<1>:d    r14.0<1;1,0>:d    r18.0<1;1,0>:d   {Compacted,I@2}
        mach (8|M16)             r18.0<1>:d    r78.0<0;1,0>:ud   r90.0<1;1,0>:d  
(W)     mul (8|M24)              acc0.0<1>:d   r78.0<0;1,0>:ud   r91.0<2;1,0>:uw 
        mach (8|M24)             r19.0<1>:d    r78.0<0;1,0>:ud   r91.0<1;1,0>:d  
        subb (8|M0)              r96.0<1>:ud   r79.0<1;1,0>:ud   r92.0<1;1,0>:ud  {AccWrEn,Compacted,F@1}
        mov (16|M16)             r94.0<1>:f    r16.0<1;1,0>:f                   {Compacted}
        add3 (8|M0)              r100.0<1>:ud  -acc0.0<1;0>:ud   r24.0<0;0>:uw     -r12.0<1>:ud    
        subb (8|M8)              r97.0<1>:ud   r80.0<1;1,0>:ud   r93.0<1;1,0>:ud  {AccWrEn}
        add (16|M16)             r22.0<1>:d    r20.0<1;1,0>:d    r18.0<1;1,0>:d   {Compacted,I@4}
        add3 (8|M8)              r101.0<1>:ud  -acc0.0<1;0>:ud   r24.0<0;0>:uw     -r13.0<1>:ud    
        subb (8|M16)             r98.0<1>:ud   r81.0<1;1,0>:ud   r94.0<1;1,0>:ud  {AccWrEn,F@1}
        shr (16|M0)              r29.0<1>:ud   r100.0<1;1,0>:ud  8:w               {I@2}
        add3 (8|M16)             r102.0<1>:ud  -acc0.0<1;0>:ud   r24.0<0;0>:uw     -r22.0<1>:ud    
        subb (8|M24)             r99.0<1>:ud   r82.0<1;1,0>:ud   r95.0<1;1,0>:ud  {AccWrEn}
        or (16|M0)               r41.0<1>:d    r29.0<1;1,0>:d    r83.1<0;1,0>:d   {Compacted,I@3}
        add3 (8|M24)             r103.0<1>:ud  -acc0.0<1;0>:ud   r24.0<0;0>:uw     -r23.0<1>:ud    
(W)     mul (8|M0)               acc0.0<1>:d   r84.0<1;1,0>:d    r8.8<0;1,0>:uw   {Compacted}
        mach (8|M0)              r25.0<1>:d    r84.0<1;1,0>:d    r8.4<0;1,0>:d    {Compacted}
(W)     mul (8|M8)               acc0.0<1>:d   r85.0<1;1,0>:d    r8.8<0;1,0>:uw  
        mach (8|M8)              r26.0<1>:d    r85.0<1;1,0>:d    r8.4<0;1,0>:d    {Compacted}
(W)     mul (8|M16)              acc0.0<1>:d   r86.0<1;1,0>:d    r8.8<0;1,0>:uw  
        mach (8|M16)             r27.0<1>:d    r86.0<1;1,0>:d    r8.4<0;1,0>:d    {Compacted}
(W)     mul (8|M24)              acc0.0<1>:d   r87.0<1;1,0>:d    r8.8<0;1,0>:uw  
        shr (16|M16)             r31.0<1>:ud   r102.0<1;1,0>:ud  8:w               {I@7}
        mach (8|M24)             r28.0<1>:d    r87.0<1;1,0>:d    r8.4<0;1,0>:d    {Compacted}
(W)     mul (8|M0)               acc0.0<1>:d   r25.0<1;1,0>:d    r8.10<0;1,0>:uw  {Compacted,I@7}
        mach (8|M0)              r25.0<1>:d    r25.0<1;1,0>:d    r8.5<0;1,0>:d    {Compacted}
(W)     mul (8|M8)               acc0.0<1>:d   r26.0<1;1,0>:d    r8.10<0;1,0>:uw  {I@7}
        or (16|M16)              r43.0<1>:d    r31.0<1;1,0>:d    r83.1<0;1,0>:d   {Compacted,I@5}
        mach (8|M8)              r26.0<1>:d    r26.0<1;1,0>:d    r8.5<0;1,0>:d    {Compacted}
(W)     mul (8|M16)              acc0.0<1>:d   r27.0<1;1,0>:d    r8.10<0;1,0>:uw 
        mach (8|M16)             r27.0<1>:d    r27.0<1;1,0>:d    r8.5<0;1,0>:d    {Compacted}
(W)     mul (8|M24)              acc0.0<1>:d   r28.0<1;1,0>:d    r8.10<0;1,0>:uw  {I@7}
        cmp (16|M0)   (lt)f1.0   null<1>:d     r41.0<1;1,0>:ud   0x1:uw             
        cmp (16|M16)  (lt)f1.0   null<1>:d     r43.0<1;1,0>:ud   0x1:uw              {I@6}
        mach (8|M24)             r28.0<1>:d    r28.0<1;1,0>:d    r8.5<0;1,0>:d    {Compacted}
        shr (16|M0)              r37.0<1>:ud   r96.0<1;1,0>:ud   8:w              
        shl (16|M0)              r33.0<1>:d    r100.0<1;1,0>:d   24:w               {Compacted}
        shr (16|M16)             r39.0<1>:ud   r98.0<1;1,0>:ud   8:w              
        shl (16|M16)             r35.0<1>:d    r102.0<1;1,0>:d   24:w               {Compacted}
        shl (16|M0)              r25.0<1>:d    r25.0<1;1,0>:d    1:w               {Compacted,I@7}
        shl (16|M16)             r27.0<1>:d    r27.0<1;1,0>:d    1:w               {Compacted,I@6}
        or (16|M0)               r108.0<1>:d   r37.0<1;1,0>:d    r33.0<1;1,0>:d   {Compacted,I@5}
        or (16|M16)              r110.0<1>:d   r39.0<1;1,0>:d    r35.0<1;1,0>:d   {Compacted,I@4}
        add (16|M0)              r104.0<1>:d   r25.0<1;1,0>:d    r9.2<0;1,0>:d    {Compacted,I@4}
        add (16|M16)             r106.0<1>:d   r27.0<1;1,0>:d    r9.2<0;1,0>:d    {Compacted,I@4}
(f1.0)  goto (32|M0)                         L6520                  L6520                
L4288:
(W)     shr (1|M0)               r2.0<1>:ud    r8.6<0;1,0>:ud    20:w              
(W)     asr (1|M0)               r3.0<1>:d     r8.6<0;1,0>:d     20:w               {Compacted}
(W)     and (1|M0)               r8.0<1>:d     r8.6<0;1,0>:d     1048575:d              
(W)     bfn.0xF8 (1|M0)          r6.0<1>:ud    r3.0<0;0>:ud      r78.7<0;0>:ud     r2.0<0>:ud       {I@2} // s0&s1|s2
(W)     shr (1|M0)               r4.0<1>:ud    r83.1<0;1,0>:ud   8:w              
(W)     mov (1|M0)               r9.0<1>:f     r8.0<0;1,0>:ud                   {Compacted,I@3}
(W)     mov (1|M0)               r7.0<1>:f     r6.0<0;1,0>:ud                   {Compacted,I@2}
(W)     mov (1|M0)               r5.0<1>:f     r4.0<0;1,0>:ud                   {Compacted,I@1}
(W)     mad (1|M0)               r10.0<1>:f    r9.0<0;0>:f       r78.3<0;0>:f      r7.0<0>:f        {Compacted,F@2}
        shr (16|M0)              r12.0<1>:ud   r100.0<1;1,0>:ud  16:w              
(W)     mad (1|M0)               r11.0<1>:f    r10.0<0;0>:f      r78.6<0;0>:f      r5.0<0>:f        {Compacted,F@1}
        shr (16|M16)             r14.0<1>:ud   r102.0<1;1,0>:ud  16:w              
        sync.nop                             null                             {Compacted,F@1}
(W)     math.inv (1|M0)          r20.0<1>:f    r11.0<0;1,0>:f                   {$5}
        mov (16|M0)              r16.0<1>:f    r12.0<1;1,0>:ud                  {Compacted,I@2}
        mov (16|M16)             r18.0<1>:f    r14.0<1;1,0>:ud                  {Compacted,I@1}
(W)     mad (1|M0)               r21.0<1>:f    r20.0<0;0>:f      r83.0<0;0>:f      r20.0<0>:f       {Compacted,$5.dst}
        shl (16|M0)              r43.0<1>:d    r100.0<1;1,0>:d   4:w               {Compacted}
        shl (16|M16)             r45.0<1>:d    r102.0<1;1,0>:d   4:w               {Compacted}
        shr (16|M0)              r47.0<1>:ud   r96.0<1;1,0>:ud   28:w              
        shr (16|M16)             r49.0<1>:ud   r98.0<1;1,0>:ud   28:w              
        mul (16|M0)              acc0.0<1>:f   r21.0<0;1,0>:f    r16.0<1;1,0>:f   {Compacted,F@1}
        mul (16|M16)             acc2.0<1>:f   r21.0<0;1,0>:f    r18.0<1;1,0>:f   {Compacted}
        shr (16|M0)              r39.0<1>:ud   r108.0<1;1,0>:ud  20:w              
        shr (16|M16)             r41.0<1>:ud   r110.0<1;1,0>:ud  20:w              
        or (16|M0)               r47.0<1>:d    r47.0<1;1,0>:d    r43.0<1;1,0>:d   {Compacted,I@4}
        or (16|M16)              r49.0<1>:d    r49.0<1;1,0>:d    r45.0<1;1,0>:d   {Compacted,I@4}
        rndd (16|M0)             r26.0<1>:f    acc0.0<1;1,0>:f                  {Compacted}
        rndd (16|M16)            r28.0<1>:f    acc2.0<1;1,0>:f                  {Compacted}
(W)     mul (1|M0)               r34.0<1>:f    r7.0<0;1,0>:f     -1.048576e+06:f               {Compacted}
        bfn.0xF8 (16|M0)         r39.0<1>:ud   r47.0<1;0>:ud     r78.7<0;0>:ud     r39.0<1>:ud      {I@2} // s0&s1|s2
        bfn.0xF8 (16|M16)        r41.0<1>:ud   r49.0<1;0>:ud     r78.7<0;0>:ud     r41.0<1>:ud      {I@2} // s0&s1|s2
        mad (16|M0)              acc0.0<1>:f   r16.0<1;0>:f      r26.0<1;0>:f      -r9.0<0>:f       {Compacted,F@3}
        mad (16|M16)             acc2.0<1>:f   r18.0<1;0>:f      r28.0<1;0>:f      -r9.0<0>:f       {F@3}
        mov (16|M0)              r51.0<1>:f    r39.0<1;1,0>:ud                  {Compacted,I@2}
        mov (16|M16)             r53.0<1>:f    r41.0<1;1,0>:ud                  {Compacted,I@1}
        mad (16|M0)              r35.0<1>:f    acc0.0<1;0>:f     r26.0<1;0>:f      r34.0<0>:f       {Compacted,F@5}
        mad (16|M16)             r37.0<1>:f    acc2.0<1;0>:f     r28.0<1;0>:f      r34.0<0>:f       {Compacted}
        mad (16|M0)              acc0.0<1>:f   r51.0<1;0>:f      r35.0<1;0>:f      r78.3<0>:f       {Compacted,F@2}
        mad (16|M16)             acc2.0<1>:f   r53.0<1;0>:f      r37.0<1;0>:f      r78.3<0>:f       {F@2}
        mul (16|M0)              acc0.0<1>:f   r21.0<0;1,0>:f    acc0.0<1;1,0>:f 
        mul (16|M16)             acc2.0<1>:f   r21.0<0;1,0>:f    acc2.0<1;1,0>:f 
(W)     mul (1|M0)               r72.0<1>:f    r9.0<0;1,0>:f     9.536743e-07:f               {Compacted}
        rndd (16|M0)             r59.0<1>:f    acc0.0<1;1,0>:f                  {Compacted}
        rndd (16|M16)            r61.0<1>:f    acc2.0<1;1,0>:f                  {Compacted}
        mul (16|M0)              acc0.0<1>:f   r72.0<0;1,0>:f    r59.0<1;1,0>:f   {Compacted,F@2}
        mul (16|M16)             acc2.0<1>:f   r72.0<0;1,0>:f    r61.0<1;1,0>:f   {Compacted,F@2}
        rndd (16|M0)             acc0.0<1>:f   acc0.0<1;1,0>:f                 
        rndd (16|M16)            acc2.0<1>:f   acc2.0<1;1,0>:f                 
(W)     mul (1|M0)               r67.0<1>:f    r5.0<0;1,0>:f     -1.048576e+06:f               {Compacted}
        and (16|M0)              r30.0<1>:d    r108.0<1;1,0>:d   1048575:d              
        and (16|M16)             r32.0<1>:d    r110.0<1;1,0>:d   1048575:d              
        mad (16|M0)              r63.0<1>:f    r35.0<1;0>:f      r59.0<1;0>:f      -r7.0<0>:f       {Compacted}
        mad (16|M16)             r65.0<1>:f    r37.0<1;0>:f      r61.0<1;0>:f      -r7.0<0>:f       {Compacted}
        mad (16|M0)              r12.0<1>:f    -acc0.0<1;0>:f    r59.0<1;0>:f      r72.0<0>:f      
        mad (16|M16)             r14.0<1>:f    -acc2.0<1;0>:f    r61.0<1;0>:f      r72.0<0>:f      
        mad (16|M0)              r68.0<1>:f    r63.0<1;0>:f      r59.0<1;0>:f      r67.0<0>:f       {Compacted,F@4}
        mov (16|M0)              r34.0<1>:f    r30.0<1;1,0>:ud                  {Compacted,I@2}
        mad (16|M16)             r70.0<1>:f    r65.0<1;0>:f      r61.0<1;0>:f      r67.0<0>:f       {Compacted,F@5}
        mov (16|M16)             r36.0<1>:f    r32.0<1;1,0>:ud                  {Compacted,I@1}
        mad (16|M0)              r22.0<1>:f    r51.0<1;0>:f      r12.0<1;0>:f      r78.4<0>:f       {Compacted,F@6}
        mad (16|M16)             r24.0<1>:f    r53.0<1;0>:f      r14.0<1;0>:f      r78.4<0>:f       {Compacted,F@6}
        mad (16|M0)              r16.0<1>:f    r68.0<1;0>:f      acc0.0<1;0>:f     r78.5<0>:f       {Compacted,F@6}
        mad (16|M16)             r18.0<1>:f    r70.0<1;0>:f      acc2.0<1;0>:f     r78.5<0>:f       {Compacted,F@5}
        mad (16|M0)              acc0.0<1>:f   r34.0<1;0>:f      r22.0<1;0>:f      r78.3<0>:f       {Compacted,F@4}
        mad (16|M16)             acc2.0<1>:f   r36.0<1;0>:f      r24.0<1;0>:f      r78.3<0>:f       {F@4}
        mad (16|M0)              acc0.0<1>:f   acc0.0<1;0>:f     r16.0<1;0>:f      r78.6<0>:f       {Compacted,F@4}
        mad (16|M16)             acc2.0<1>:f   acc2.0<1;0>:f     r18.0<1;0>:f      r78.6<0>:f       {F@4}
        mul (16|M0)              acc0.0<1>:f   r21.0<0;1,0>:f    acc0.0<1;1,0>:f 
        mul (16|M16)             acc2.0<1>:f   r21.0<0;1,0>:f    acc2.0<1;1,0>:f 
(W)     mul (1|M0)               r4.0<1>:f     r7.0<0;1,0>:f     9.536743e-07:f               {Compacted}
        rndd (16|M0)             r46.0<1>:f    acc0.0<1;1,0>:f                  {Compacted}
        rndd (16|M16)            r48.0<1>:f    acc2.0<1;1,0>:f                  {Compacted}
        mul (16|M0)              acc0.0<1>:f   r72.0<0;1,0>:f    r46.0<1;1,0>:f   {Compacted,F@2}
        mul (16|M0)              acc2.0<1>:f   r4.0<0;1,0>:f     r46.0<1;1,0>:f   {Compacted}
        mul (16|M16)             r56.0<1>:f    r72.0<0;1,0>:f    r48.0<1;1,0>:f   {Compacted,F@3}
        rndd (16|M0)             acc0.0<1>:f   acc0.0<1;1,0>:f                 
        rndd (16|M0)             r14.0<1>:f    acc2.0<1;1,0>:f                  {Compacted}
        rndd (16|M16)            acc2.0<1>:f   r56.0<1;1,0>:f                   {F@3}
        mad (16|M0)              r50.0<1>:f    r16.0<1;0>:f      r46.0<1;0>:f      -r5.0<0>:f       {Compacted}
        mad (16|M16)             r52.0<1>:f    r18.0<1;0>:f      r48.0<1;0>:f      -r5.0<0>:f       {Compacted}
        mul (16|M16)             r12.0<1>:f    r4.0<0;1,0>:f     r48.0<1;1,0>:f   {Compacted}
        mad (16|M0)              r67.0<1>:f    -acc0.0<1;0>:f    r46.0<1;0>:f      r72.0<0>:f      
        mad (16|M16)             r69.0<1>:f    -acc2.0<1;0>:f    r48.0<1;0>:f      r72.0<0>:f      
        mad (16|M0)              r18.0<1>:f    -r14.0<1;0>:f     r46.0<1;0>:f      r4.0<0>:f        {Compacted,F@7}
        mad (16|M0)              acc0.0<1>:f   r22.0<1;0>:f      acc0.0<1;0>:f     r78.5<0>:f       {Compacted}
        mad (16|M16)             r73.0<1>:f    r24.0<1;0>:f      acc2.0<1;0>:f     r78.5<0>:f       {Compacted}
        rndd (16|M16)            acc2.0<1>:f   r12.0<1;1,0>:f                   {F@6}
        mad (16|M0)              r32.0<1>:f    acc0.0<1;0>:f     r18.0<1;0>:f      r78.4<0>:f       {Compacted,F@4}
        mad (16|M0)              r24.0<1>:f    r50.0<1;0>:f      r14.0<1;0>:f      r78.5<0>:f       {Compacted}
        mov (16|M0)              r44.0<1>:d    r46.0<1;1,0>:f                   {Compacted}
        mad (16|M0)              r75.0<1>:f    r34.0<1;0>:f      r67.0<1;0>:f      r78.4<0>:f       {Compacted}
        mad (16|M16)             acc0.0<1>:f   -acc2.0<1;0>:f    r48.0<1;0>:f      r4.0<0>:f       
        mov (16|M16)             r46.0<1>:d    r48.0<1;1,0>:f                   {Compacted}
        mad (16|M0)              r48.0<1>:f    r32.0<1;0>:f      r24.0<1;0>:f      r78.3<0>:f       {Compacted,A@1}
        mad (16|M16)             acc2.0<1>:f   r52.0<1;0>:f      acc2.0<1;0>:f     r78.5<0>:f      
        mad (16|M16)             r34.0<1>:f    r73.0<1;0>:f      acc0.0<1;0>:f     r78.4<0>:f       {Compacted}
        mad (16|M0)              r52.0<1>:f    r75.0<1;0>:f      r48.0<1;0>:f      r78.3<0>:f       {Compacted,F@3}
        mad (16|M16)             r2.0<1>:f     r36.0<1;0>:f      r69.0<1;0>:f      r78.4<0>:f       {Compacted}
        mad (16|M16)             acc0.0<1>:f   r34.0<1;0>:f      acc2.0<1;0>:f     r78.3<0>:f       {F@3}
        mul (16|M0)              r52.0<1>:f    r21.0<0;1,0>:f    r52.0<1;1,0>:f   {Compacted,F@3}
        mad (16|M16)             acc0.0<1>:f   r2.0<1;0>:f       acc0.0<1;0>:f     r78.3<0>:f       {F@3}
        rndd (16|M0)             r56.0<1>:f    r52.0<1;1,0>:f                   {Compacted,F@2}
        mov (16|M0)              r40.0<1>:d    r59.0<1;1,0>:f                   {Compacted}
        mov (16|M16)             r42.0<1>:d    r61.0<1;1,0>:f                   {Compacted}
        mul (16|M16)             r54.0<1>:f    r21.0<0;1,0>:f    acc0.0<1;1,0>:f 
        mad (16|M0)              acc0.0<1>:f   r24.0<1;0>:f      -r56.0<1;0>:f     r5.0<0>:f        {Compacted,F@2}
        mov (16|M16)             r38.0<1>:d    r28.0<1;1,0>:f                   {Compacted}
        rndd (16|M16)            r58.0<1>:f    r54.0<1;1,0>:f                   {Compacted,A@2}
        mul (16|M0)              r28.0<1>:f    acc0.0<1;1,0>:f   0x2F800000:f               {Compacted,I@1}
        mad (16|M0)              r64.0<1>:f    r32.0<1;0>:f      -r56.0<1;0>:f     r7.0<0>:f        {Compacted}
        mad (16|M16)             acc2.0<1>:f   acc2.0<1;0>:f     -r58.0<1;0>:f     r5.0<0>:f        {F@3}
        rndz (16|M0)             r32.0<1>:f    r28.0<1;1,0>:f                   {Compacted,F@3}
        mad (16|M0)              r68.0<1>:f    r75.0<1;0>:f      -r56.0<1;0>:f     r9.0<0>:f        {Compacted}
        mul (16|M16)             r30.0<1>:f    acc2.0<1;1,0>:f   0x2F800000:f               {Compacted}
        mad (16|M0)              r48.0<1>:f    acc0.0<1;0>:f     r32.0<1;0>:f      r78.2<0>:f       {Compacted,F@3}
        mad (16|M16)             r66.0<1>:f    r34.0<1;0>:f      -r58.0<1;0>:f     r7.0<0>:f        {Compacted}
        mov (16|M0)              r52.0<1>:ud   r48.0<1;1,0>:f                   {F@2}
        mov (16|M0)              r6.0<1>:d     r68.0<1;1,0>:f                   {Compacted,F@1}
        rndz (16|M16)            acc0.0<1>:f   r30.0<1;1,0>:f                  
        mov (16|M0)              r72.0<1>:d    r56.0<1;1,0>:f                   {Compacted}
        mad (16|M16)             r70.0<1>:f    r2.0<1;0>:f       -r58.0<1;0>:f     r9.0<0>:f        {Compacted}
        shl (16|M0)              r52.0<1>:d    r52.0<1;1,0>:d    8:w               {Compacted,I@3}
        asr (16|M0)              r24.0<1>:d    r6.0<1;1,0>:d     31:w               {Compacted,I@3}
        mad (16|M16)             r50.0<1>:f    acc2.0<1;0>:f     acc0.0<1;0>:f     r78.2<0>:f      
        addc (8|M0)              r56.0<1>:ud   r6.0<1;1,0>:ud    0x0:ud              {AccWrEn,Compacted,A@1}
        mov (16|M16)             r74.0<1>:d    r58.0<1;1,0>:f                   {Compacted}
        mov (16|M0)              r2.0<1>:d     r64.0<1;1,0>:f                   {Compacted}
        mov (16|M16)             r10.0<1>:d    r70.0<1;1,0>:f                   {Compacted}
        mov (16|M16)             r54.0<1>:ud   r50.0<1;1,0>:f                  
        add3 (8|M0)              r58.0<1>:ud   acc0.0<1;0>:ud    r52.0<1;0>:ud     r24.0<1>:ud      {I@6}
        addc (8|M8)              r57.0<1>:ud   r7.0<1;1,0>:ud    0x0:ud              {AccWrEn}
        mov (16|M0)              r36.0<1>:d    r26.0<1;1,0>:f                   {Compacted}
        asr (16|M0)              r12.0<1>:d    r2.0<1;1,0>:d     31:w               {Compacted,I@6}
        shl (16|M16)             r54.0<1>:d    r54.0<1;1,0>:d    8:w               {Compacted,I@5}
        add3 (8|M8)              r59.0<1>:ud   acc0.0<1;0>:ud    r53.0<1;0>:ud     r25.0<1>:ud     
        asr (16|M16)             r26.0<1>:d    r10.0<1;1,0>:d    31:w               {Compacted}
        addc (8|M16)             r60.0<1>:ud   r10.0<1;1,0>:ud   0x0:ud              {AccWrEn}
        mov (16|M16)             r4.0<1>:d     r66.0<1;1,0>:f                   {Compacted}
        shl (16|M0)              r16.0<1>:d    r2.0<1;1,0>:d     20:w               {Compacted}
        shl (16|M0)              r12.0<1>:d    r12.0<1;1,0>:d    20:w               {Compacted,I@7}
        add3 (8|M16)             r62.0<1>:ud   acc0.0<1;0>:ud    r54.0<1;0>:ud     r26.0<1>:ud      {I@5}
        shr (16|M0)              r2.0<1>:ud    r2.0<1;1,0>:ud    12:w              
        addc (8|M24)             r61.0<1>:ud   r11.0<1;1,0>:ud   0x0:ud              {AccWrEn}
        asr (16|M16)             r14.0<1>:d    r4.0<1;1,0>:d     31:w               {Compacted,I@6}
        or (16|M0)               r20.0<1>:d    r12.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@3}
        add3 (8|M24)             r63.0<1>:ud   acc0.0<1;0>:ud    r55.0<1;0>:ud     r27.0<1>:ud     
        addc (8|M0)              r64.0<1>:ud   r56.0<1;1,0>:ud   r16.0<1;1,0>:ud  {AccWrEn,Compacted}
        shl (16|M16)             r18.0<1>:d    r4.0<1;1,0>:d     20:w               {Compacted}
        shl (16|M16)             r14.0<1>:d    r14.0<1;1,0>:d    20:w               {Compacted,I@5}
        add3 (8|M0)              r66.0<1>:ud   acc0.0<1;0>:ud    r58.0<1;0>:ud     r20.0<1>:ud      {I@5}
        shr (16|M16)             r4.0<1>:ud    r4.0<1;1,0>:ud    12:w              
        addc (8|M8)              r65.0<1>:ud   r57.0<1;1,0>:ud   r17.0<1;1,0>:ud  {AccWrEn}
        or (16|M16)              r22.0<1>:d    r14.0<1;1,0>:d    r4.0<1;1,0>:d    {Compacted,I@2}
        add3 (8|M8)              r67.0<1>:ud   acc0.0<1;0>:ud    r59.0<1;0>:ud     r21.0<1>:ud     
        cmp (16|M0)   (ge)f0.0   null<1>:d     r64.0<1;1,0>:ud   r8.6<0;1,0>:ud   {I@3}
        addc (8|M16)             r68.0<1>:ud   r60.0<1;1,0>:ud   r18.0<1;1,0>:ud  {AccWrEn}
        shl (16|M0)              r6.0<1>:d     r40.0<1;1,0>:d    20:w               {Compacted}
        add3 (8|M16)             r70.0<1>:ud   acc0.0<1;0>:ud    r62.0<1;0>:ud     r22.0<1>:ud      {I@5}
        addc (8|M24)             r69.0<1>:ud   r61.0<1;1,0>:ud   r19.0<1;1,0>:ud  {AccWrEn}
(f0.0)  cmp (16|M0)   (eq)f0.0   null<1>:d     r66.0<1;1,0>:d    r83.1<0;1,0>:d   {I@6}
        cmp (16|M16)  (ge)f0.0   null<1>:d     r68.0<1;1,0>:ud   r8.6<0;1,0>:ud   {I@2}
        add3 (8|M24)             r71.0<1>:ud   acc0.0<1;0>:ud    r63.0<1;0>:ud     r23.0<1>:ud     
        shl (16|M0)              r2.0<1>:d     r36.0<1;1,0>:d    8:w               {Compacted}
        shr (16|M0)              r12.0<1>:ud   r40.0<1;1,0>:ud   12:w              
(~f0.0) cmp (16|M0)   (gt)f0.0   null<1>:d     r66.0<1;1,0>:ud   r83.1<0;1,0>:ud 
        addc (8|M0)              r16.0<1>:ud   r6.0<1;1,0>:ud    0x0:ud              {AccWrEn,Compacted}
(f0.0)  cmp (16|M16)  (eq)f0.0   null<1>:d     r70.0<1;1,0>:d    r83.1<0;1,0>:d   {I@5}
(W)     mov (1|M0)               r24.0<1>:w    -1:w                              
        shl (16|M16)             r10.0<1>:d    r42.0<1;1,0>:d    20:w               {Compacted}
        add3 (8|M0)              r18.0<1>:ud   acc0.0<1;0>:ud    r12.0<1;0>:ud     r2.0<1>:ud       {I@6}
        addc (8|M8)              r17.0<1>:ud   r7.0<1;1,0>:ud    0x0:ud              {AccWrEn}
        shl (16|M16)             r4.0<1>:d     r38.0<1;1,0>:d    8:w               {Compacted}
        shr (16|M16)             r14.0<1>:ud   r42.0<1;1,0>:ud   12:w              
(~f0.0) cmp (16|M16)  (gt)f0.0   null<1>:d     r70.0<1;1,0>:ud   r83.1<0;1,0>:ud 
(f0.0)  sel (16|M0)              r25.0<1>:d    r24.0<0;1,0>:w    0:w               {I@7}
        add3 (8|M8)              r19.0<1>:ud   acc0.0<1;0>:ud    r13.0<1;0>:ud     r3.0<1>:ud      
        addc (8|M16)             r20.0<1>:ud   r10.0<1;1,0>:ud   0x0:ud              {AccWrEn,I@7}
        add3 (16|M0)             r29.0<1>:d    r72.0<1;0>:d      r44.0<1;0>:d      -r25.0<1>:d      {I@3}
        add3 (8|M16)             r22.0<1>:ud   acc0.0<1;0>:ud    r14.0<1;0>:ud     r4.0<1>:ud      
        addc (8|M24)             r21.0<1>:ud   r11.0<1;1,0>:ud   0x0:ud              {AccWrEn}
(f0.0)  sel (16|M16)             r27.0<1>:d    r24.0<0;1,0>:w    0:w              
        add3 (8|M24)             r23.0<1>:ud   acc0.0<1;0>:ud    r15.0<1;0>:ud     r5.0<1>:ud      
        addc (8|M0)              r112.0<1>:ud  r16.0<1;1,0>:ud   r29.0<1;1,0>:ud  {AccWrEn,Compacted,I@5}
        add3 (16|M16)            r31.0<1>:d    r74.0<1;0>:d      r46.0<1;0>:d      -r27.0<1>:d      {I@3}
        add (8|M0)               r116.0<1>:ud  acc0.0<1;1,0>:ud  r18.0<1;1,0>:ud 
        addc (8|M8)              r113.0<1>:ud  r17.0<1;1,0>:ud   r30.0<1;1,0>:ud  {AccWrEn}
        add (8|M8)               r117.0<1>:ud  acc0.0<1;1,0>:ud  r19.0<1;1,0>:ud 
        addc (8|M16)             r114.0<1>:ud  r20.0<1;1,0>:ud   r31.0<1;1,0>:ud  {AccWrEn,I@4}
        add (8|M16)              r118.0<1>:ud  acc0.0<1;1,0>:ud  r22.0<1;1,0>:ud 
        addc (8|M24)             r115.0<1>:ud  r21.0<1;1,0>:ud   r32.0<1;1,0>:ud  {AccWrEn}
        add (8|M24)              r119.0<1>:ud  acc0.0<1;1,0>:ud  r23.0<1;1,0>:ud 
        goto (32|M0)                         L6520                  L7272                
L6520:
        join (32|M0)                         L7272                                
L6536:
(W)     cmp (16|M0)   (eq)f0.0   null<1>:d     r8.6<0;1,0>:d     0:w               {Compacted}
(W)     cmp (16|M16)  (eq)f0.0   null<1>:d     r8.6<0;1,0>:d     0:w              
(f0.0)  goto (32|M0)                         L7176                  L7176                
L6576:
(W)     xor (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x30:uw              {A@1}
(W)     mov (1|M0)               r2.0<1>:f     r8.6<0;1,0>:ud                   {Compacted,A@1}
(W)     mov (1|M0)               r13.0<1>:f    0xB4C00000:f                               {Compacted}
(W)     math.inv (1|M0)          r12.0<1>:f    r2.0<0;1,0>:f                    {@2,$6}
        mov (16|M0)              r5.0<1>:f     r108.0<1;1,0>:ud                 {Compacted}
        sync.nop                             null                             {Compacted,$6.dst}
(W)     mad (1|M0)               r14.0<1>:f    r12.0<0;0>:f      r13.0<0;0>:f      r12.0<0>:f       {Compacted,F@2}
        mov (16|M16)             r10.0<1>:f    r110.0<1;1,0>:ud                 {Compacted}
(W)     mov (1|M0)               r3.0<1>:ud    r2.0<0;1,0>:f                   
        mov (16|M0)              r19.0<1>:ud   r5.0<1;1,0>:f                    {F@3}
        mul (16|M0)              r15.0<1>:f    r5.0<1;1,0>:f     r14.0<0;1,0>:f   {Compacted,F@2}
        mul (16|M16)             r17.0<1>:f    r10.0<1;1,0>:f    r14.0<0;1,0>:f   {Compacted,F@2}
        mov (16|M16)             r21.0<1>:ud   r10.0<1;1,0>:f                  
(W)     add (1|M0)               r4.0<1>:d     r8.6<0;1,0>:d     -r3.0<0;1,0>:d   {Compacted,I@3}
        add (16|M0)              r19.0<1>:d    r108.0<1;1,0>:d   -r19.0<1;1,0>:d  {Compacted,I@3}
        mov (16|M0)              r23.0<1>:ud   r15.0<1;1,0>:f                   {F@2}
        mov (16|M16)             r25.0<1>:ud   r17.0<1;1,0>:f                   {F@1}
        add (16|M16)             r21.0<1>:d    r110.0<1;1,0>:d   -r21.0<1;1,0>:d  {Compacted,I@5}
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
(W)     mul (8|M0)               acc0.0<1>:d   r56.0<1;1,0>:d    r8.12<0;1,0>:uw  {Compacted,I@2}
        mach (8|M0)              r56.0<1>:d    r56.0<1;1,0>:d    r8.6<0;1,0>:d    {Compacted}
(W)     mul (8|M8)               acc0.0<1>:d   r57.0<1;1,0>:d    r8.12<0;1,0>:uw 
        mach (8|M8)              r57.0<1>:d    r57.0<1;1,0>:d    r8.6<0;1,0>:d    {Compacted}
(W)     mul (8|M16)              acc0.0<1>:d   r58.0<1;1,0>:d    r8.12<0;1,0>:uw  {I@5}
        mach (8|M16)             r58.0<1>:d    r58.0<1;1,0>:d    r8.6<0;1,0>:d    {Compacted}
(W)     mul (8|M24)              acc0.0<1>:d   r59.0<1;1,0>:d    r8.12<0;1,0>:uw 
        mach (8|M24)             r59.0<1>:d    r59.0<1;1,0>:d    r8.6<0;1,0>:d    {Compacted}
        add (16|M0)              r56.0<1>:d    r108.0<1;1,0>:d   -r56.0<1;1,0>:d  {Compacted,I@5}
        add (16|M16)             r58.0<1>:d    r110.0<1;1,0>:d   -r58.0<1;1,0>:d  {Compacted,I@2}
        cmp (16|M0)   (ge)f0.0   r60.0<1>:ud   r56.0<1;1,0>:ud   r8.6<0;1,0>:ud   {Compacted,I@2}
        cmp (16|M16)  (ge)f0.0   r62.0<1>:ud   r58.0<1;1,0>:ud   r8.6<0;1,0>:ud   {I@2}
        add3 (16|M0)             r112.0<1>:d   r52.0<1;0>:d      r23.0<1;0>:d      -r60.0<1>:d      {I@2}
        add3 (16|M16)            r114.0<1>:d   r54.0<1;0>:d      r25.0<1;0>:d      -r62.0<1>:d      {I@2}
        goto (32|M0)                         L7176                  L7224                
L7176:
        join (32|M0)                         L7224                                
L7192:
        mov (16|M0)              r112.0<1>:d   -1:w                              
        mov (16|M16)             r114.0<1>:d   -1:w                              
L7224:
        join (32|M0)                         L7272                                
L7240:
        mov (16|M0)              r116.0<1>:d   0:w                              
        mov (16|M16)             r118.0<1>:d   0:w                              
L7272:
        join (32|M0)                         L7288                                
L7288:
        mul (8|M0)               acc0.0<1>:ud  r112.0<1;1,0>:ud  r8.12<0;1,0>:uw  {I@6}
        mach (8|M0)              r2.0<1>:ud    r112.0<1;1,0>:ud  r8.6<0;1,0>:ud   {AccWrEn,Compacted}
        shl (16|M0)              r18.0<1>:d    r100.0<1;1,0>:d   31:w               {Compacted}
        mov (8|M0)               r4.0<1>:ud    acc0.0<1;1,0>:ud                 {Compacted}
        mul (8|M8)               acc0.0<1>:ud  r113.0<1;1,0>:ud  r8.12<0;1,0>:uw 
        mach (8|M8)              r3.0<1>:ud    r113.0<1;1,0>:ud  r8.6<0;1,0>:ud   {AccWrEn}
        shr (16|M0)              r20.0<1>:ud   r96.0<1;1,0>:ud   1:w              
        mov (8|M8)               r5.0<1>:ud    acc0.0<1;1,0>:ud                 {Compacted}
(W)     mul (8|M0)               acc0.0<1>:d   r112.0<1;1,0>:ud  r83.2<0;1,0>:uw 
        mach (8|M0)              r6.0<1>:d     r112.0<1;1,0>:ud  r83.1<0;1,0>:d  
(W)     mul (8|M8)               acc0.0<1>:d   r113.0<1;1,0>:ud  r83.2<0;1,0>:uw 
        mach (8|M8)              r7.0<1>:d     r113.0<1;1,0>:ud  r83.1<0;1,0>:d  
(W)     mul (8|M0)               acc0.0<1>:d   r8.6<0;1,0>:ud    r116.0<2;1,0>:uw
        add (16|M0)              r10.0<1>:d    r2.0<1;1,0>:d     r6.0<1;1,0>:d    {Compacted,I@2}
        mach (8|M0)              r6.0<1>:d     r8.6<0;1,0>:ud    r116.0<1;1,0>:d 
(W)     mul (8|M8)               acc0.0<1>:d   r8.6<0;1,0>:ud    r117.0<2;1,0>:uw
        mach (8|M8)              r7.0<1>:d     r8.6<0;1,0>:ud    r117.0<1;1,0>:d 
        mul (8|M16)              acc0.0<1>:ud  r114.0<1;1,0>:ud  r8.12<0;1,0>:uw 
        mach (8|M16)             r12.0<1>:ud   r114.0<1;1,0>:ud  r8.6<0;1,0>:ud   {AccWrEn}
        shl (16|M0)              r22.0<1>:d    r100.0<1;1,0>:d   28:w               {Compacted}
        mov (8|M16)              r14.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mul (8|M24)              acc0.0<1>:ud  r115.0<1;1,0>:ud  r8.12<0;1,0>:uw 
        mach (8|M24)             r13.0<1>:ud   r115.0<1;1,0>:ud  r8.6<0;1,0>:ud   {AccWrEn}
        shr (16|M0)              r24.0<1>:ud   r96.0<1;1,0>:ud   4:w              
(W)     mov (1|M0)               r26.0<1>:d    7:w                              
(W)     mov (1|M0)               r27.0<1>:d    8:w                              
        add (16|M0)              r16.0<1>:d    r108.0<1;1,0>:d   -r4.0<1;1,0>:d   {Compacted}
        mov (8|M24)              r15.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
(W)     mul (8|M16)              acc0.0<1>:d   r114.0<1;1,0>:ud  r83.2<0;1,0>:uw 
        shl (16|M16)             r36.0<1>:d    r102.0<1;1,0>:d   31:w               {Compacted}
        shr (16|M16)             r38.0<1>:ud   r98.0<1;1,0>:ud   1:w              
        shl (16|M16)             r40.0<1>:d    r102.0<1;1,0>:d   28:w               {Compacted}
        shr (16|M16)             r42.0<1>:ud   r98.0<1;1,0>:ud   4:w              
        bfn.0xE0 (16|M0)         r32.0<1>:ud   r20.0<1;0>:ud     r18.0<1;0>:ud     r26.0<0>:ud      {I@7} // (s0|s1)&s2
        bfn.0xE0 (16|M0)         r34.0<1>:ud   r24.0<1;0>:ud     r22.0<1;0>:ud     r27.0<0>:ud      {I@7} // (s0|s1)&s2
        shl (16|M0)              r16.0<1>:d    r16.0<1;1,0>:d    4:w               {Compacted,I@7}
        mach (8|M16)             r28.0<1>:d    r114.0<1;1,0>:ud  r83.1<0;1,0>:d  
        add (16|M16)             r30.0<1>:d    r110.0<1;1,0>:d   -r14.0<1;1,0>:d  {Compacted,I@7}
(W)     mul (8|M24)              acc0.0<1>:d   r115.0<1;1,0>:ud  r83.2<0;1,0>:uw 
        mach (8|M24)             r29.0<1>:d    r115.0<1;1,0>:ud  r83.1<0;1,0>:d  
        bfn.0xE0 (16|M16)        r46.0<1>:ud   r38.0<1;0>:ud     r36.0<1;0>:ud     r26.0<0>:ud      {I@7} // (s0|s1)&s2
        bfn.0xE0 (16|M16)        r48.0<1>:ud   r42.0<1;0>:ud     r40.0<1;0>:ud     r27.0<0>:ud      {I@7} // (s0|s1)&s2
        bfn.0xFE (16|M0)         r44.0<1>:ud   r16.0<1;0>:ud     r34.0<1;0>:ud     r32.0<1>:ud      {I@7} // s0|s1|s2
        shl (16|M16)             r30.0<1>:d    r30.0<1;1,0>:d    4:w               {Compacted,I@6}
(W)     mul (8|M16)              acc0.0<1>:d   r8.6<0;1,0>:ud    r118.0<2;1,0>:uw
        add (16|M16)             r50.0<1>:d    r12.0<1;1,0>:d    r28.0<1;1,0>:d   {Compacted,I@6}
        mach (8|M16)             r28.0<1>:d    r8.6<0;1,0>:ud    r118.0<1;1,0>:d 
(W)     mul (8|M24)              acc0.0<1>:d   r8.6<0;1,0>:ud    r119.0<2;1,0>:uw
        bfn.0xFE (16|M16)        r52.0<1>:ud   r30.0<1;0>:ud     r48.0<1;0>:ud     r46.0<1>:ud      {I@5} // s0|s1|s2
        mach (8|M24)             r29.0<1>:d    r8.6<0;1,0>:ud    r119.0<1;1,0>:d 
(W)     mul (8|M0)               acc0.0<1>:d   r44.0<1;1,0>:d    r8.10<0;1,0>:uw  {Compacted}
        mach (8|M0)              r44.0<1>:d    r44.0<1;1,0>:d    r8.5<0;1,0>:d    {Compacted}
(W)     mul (8|M8)               acc0.0<1>:d   r45.0<1;1,0>:d    r8.10<0;1,0>:uw 
        mach (8|M8)              r45.0<1>:d    r45.0<1;1,0>:d    r8.5<0;1,0>:d    {Compacted}
(W)     mul (8|M16)              acc0.0<1>:d   r52.0<1;1,0>:d    r8.10<0;1,0>:uw  {I@6}
        mach (8|M16)             r52.0<1>:d    r52.0<1;1,0>:d    r8.5<0;1,0>:d    {Compacted}
(W)     mul (8|M24)              acc0.0<1>:d   r53.0<1;1,0>:d    r8.10<0;1,0>:uw 
        mach (8|M24)             r53.0<1>:d    r53.0<1;1,0>:d    r8.5<0;1,0>:d    {Compacted}
        shl (16|M0)              r54.0<1>:d    r112.0<1;1,0>:d   5:w               {Compacted}
        shl (16|M16)             r56.0<1>:d    r114.0<1;1,0>:d   5:w               {Compacted}
        shr (16|M0)              r58.0<1>:ud   r96.0<1;1,0>:ud   2:w              
        shr (16|M16)             r60.0<1>:ud   r98.0<1;1,0>:ud   2:w              
        shl (16|M0)              r62.0<1>:d    r96.0<1;1,0>:d    1:w               {Compacted}
        shl (16|M16)             r64.0<1>:d    r98.0<1;1,0>:d    1:w               {Compacted}
        shl (16|M0)              r44.0<1>:d    r44.0<1;1,0>:d    1:w               {Compacted,I@7}
        shl (16|M16)             r52.0<1>:d    r52.0<1;1,0>:d    1:w               {Compacted,I@7}
(W)     mov (1|M0)               a0.0<1>:ud    r9.4<0;1,0>:d                    {A@1}
        and (16|M0)              r58.0<1>:d    r58.0<1;1,0>:d    28:w               {Compacted,I@7}
        and (16|M16)             r60.0<1>:d    r60.0<1;1,0>:d    28:w               {Compacted,I@7}
        and (16|M0)              r66.0<1>:d    r62.0<1;1,0>:d    2:w               {Compacted,I@7}
        and (16|M16)             r68.0<1>:d    r64.0<1;1,0>:d    2:w               {Compacted,I@7}
        add3 (16|M0)             r54.0<1>:d    r104.0<1;0>:d     r44.0<1;0>:d      r54.0<1>:d       {I@7}
        add3 (16|M16)            r56.0<1>:d    r106.0<1;0>:d     r52.0<1;0>:d      r56.0<1>:d       {I@7}
        add3 (16|M0)             r66.0<1>:d    r54.0<1;0>:d      r58.0<1;0>:d      r66.0<1>:d       {I@2}
        add3 (16|M16)            r68.0<1>:d    r56.0<1;0>:d      r60.0<1;0>:d      r68.0<1>:d       {I@2}
        send.ugm (16|M0)         r70      r66     null:0  a0.0        0x24280B00           {ExBSO,A@2,$7} // wr:2+0, rd:2; load.ugm.d16u32.a32.ca.ca.bss[a0.0]
        send.ugm (16|M16)        r72      r68     null:0  a0.0        0x24280B00           {ExBSO,A@1,$8} // wr:2+0, rd:2; load.ugm.d16u32.a32.ca.ca.bss[a0.0]
        shl (16|M0)              r74.0<1>:d    r92.0<1;1,0>:d    1:w               {Compacted}
        shl (16|M16)             r2.0<1>:d     r94.0<1;1,0>:d    1:w               {Compacted}
(W)     mov (1|M0)               a0.0<1>:ud    r9.5<0;1,0>:d                    {A@1}
        add3 (16|M0)             r62.0<1>:d    r74.0<1;0>:d      r9.3<0;0>:d       r62.0<1>:d       {I@3}
        add3 (16|M16)            r64.0<1>:d    r2.0<1;0>:d       r9.3<0;0>:d       r64.0<1>:d       {I@3}
        mov (16|M0)              r4.0<1>:ud    r70.0<2;1,0>:uw                  {$7.dst}
        mov (16|M16)             r12.0<1>:ud   r72.0<2;1,0>:uw                  {$8.dst}
(W)     mov (8|M0)               r127.0<1>:f   r77.0<1;1,0>:f                   {Compacted}
        send.ugm (16|M0)         null     r62     r4:2    a0.0        0x240E0B04           {ExBSO,A@2,$9} // wr:2+2, rd:0; store.ugm.d16u32.a32.wb.wb.bss[a0.0]
        sync.nop                             null                             {Compacted,I@1}
        send.ugm (16|M16)        null     r64     r12:2   a0.0        0x240E0B04           {ExBSO,$10} // wr:2+2, rd:0; store.ugm.d16u32.a32.wb.wb.bss[a0.0]
        add (16|M0)              r14.0<1>:d    r10.0<1;1,0>:d    r6.0<1;1,0>:d    {Compacted}
        add (16|M16)             r16.0<1>:d    r50.0<1;1,0>:d    r28.0<1;1,0>:d   {Compacted}
(W)     send.gtwy (1|M0)         null     r127    null:0  0x0            0x02000010           {EOT,A@1} // wr:1+0, rd:0; end of thread
L8456:
        nop                    
(W)     mov (16|M0)              null<1>:ud    0x9E09665A:ud                             
(W)     mov (16|M0)              null<1>:ud    0xA6E09A48:ud                             
(W)     mov (16|M0)              null<1>:ud    0x0:ud                             
(W)     mov (16|M0)              null<1>:ud    0xE:ud                             
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
