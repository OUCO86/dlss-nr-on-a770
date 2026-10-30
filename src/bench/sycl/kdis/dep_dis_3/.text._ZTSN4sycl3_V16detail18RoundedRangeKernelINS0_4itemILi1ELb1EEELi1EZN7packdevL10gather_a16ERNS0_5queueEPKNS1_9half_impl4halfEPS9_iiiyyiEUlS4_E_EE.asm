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
(W)     mov (8|M0)               r91.0<1>:ud   r0.0<1;1,0>:ud                  
(W)     or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x4C0:uw              {A@1}
(W)     mul (1|M0)               acc0.0<1>:ud  r4.3<0;1,0>:ud    r91.2<0;1,0>:uw  {A@1}
(W)     mach (1|M0)              r10.0<1>:ud   r4.3<0;1,0>:ud    r91.1<0;1,0>:ud  {AccWrEn}
        mov (16|M0)              r11.0<1>:d    r1.0<1;1,0>:uw                   {$0.dst}
(W)     mov (1|M0)               r9.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
(W)     mov (2|M0)               r5.1<1>:d     r7.2<1;1,0>:d                    {$2.dst}
        addc (8|M0)              r13.0<1>:ud   r9.0<0;1,0>:ud    r11.0<1;1,0>:ud  {AccWrEn,Compacted,I@2}
(W)     mov (2|M0)               r92.0<1>:d    r4.6<1;1,0>:d                   
        add (8|M0)               r15.0<1>:ud   acc0.0<1;1,0>:ud  r10.0<0;1,0>:ud 
        addc (8|M8)              r14.0<1>:ud   r9.0<0;1,0>:ud    r12.0<1;1,0>:ud  {AccWrEn}
(W)     asr (1|M0)               r17.0<1>:d    r6.4<0;1,0>:d     31:w               {Compacted}
        add (8|M8)               r16.0<1>:ud   acc0.0<1;1,0>:ud  r10.0<0;1,0>:ud 
        addc (8|M0)              r93.0<1>:ud   r13.0<1;1,0>:ud   r4.0<0;1,0>:ud   {AccWrEn,Compacted,I@6}
(W)     mov (2|M0)               r3.0<1>:d     r6.2<1;1,0>:d                    {$1.dst}
        add (8|M0)               r95.0<1>:ud   acc0.0<1;1,0>:ud  r15.0<1;1,0>:ud  {I@6}
        addc (8|M8)              r94.0<1>:ud   r14.0<1;1,0>:ud   r4.0<0;1,0>:ud   {AccWrEn,I@6}
(W)     mov (2|M0)               r2.0<1>:f     r6.0<1;1,0>:f                    {Compacted}
        add (8|M8)               r96.0<1>:ud   acc0.0<1;1,0>:ud  r16.0<1;1,0>:ud  {I@5}
(W)     mul (1|M0)               acc0.0<1>:ud  r6.4<0;1,0>:ud    r5.2<0;1,0>:uw  
(W)     mach (1|M0)              r19.0<1>:ud   r6.4<0;1,0>:ud    r5.1<0;1,0>:ud   {AccWrEn}
        cmp (16|M0)   (lt)f0.0   null<1>:d     r93.0<1;1,0>:ud   r92.0<0;1,0>:ud  {I@4}
(W)     mov (1|M0)               r18.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r6.4<0;1,0>:ud    r5.4<0;1,0>:uw  
(W)     mach (1|M0)              r20.0<1>:d    r6.4<0;1,0>:ud    r5.2<0;1,0>:d   
(W)     mul (1|M0)               acc0.0<1>:d   r5.1<0;1,0>:ud    r17.0<0;1,0>:uw 
(W)     shl (1|M0)               r23.0<1>:d    r3.0<0;1,0>:d     1:w               {Compacted}
(f0.0)  cmp (16|M0)   (eq)f0.0   null<1>:d     r95.0<1;1,0>:d    r92.1<0;1,0>:d   {I@7}
(W)     add (1|M0)               r21.0<1>:d    r19.0<0;1,0>:d    r20.0<0;1,0>:d   {Compacted,I@4}
(W)     mach (1|M0)              r20.0<1>:d    r5.1<0;1,0>:ud    r17.0<0;1,0>:d  
(W)     shr (1|M0)               r24.0<1>:ud   r3.0<0;1,0>:ud    31:w              
(W)     shl (1|M0)               r25.0<1>:d    r3.1<0;1,0>:d     1:w               {Compacted}
(W)     shl (1|M0)               r30.0<1>:d    r18.0<0;1,0>:d    1:w               {Compacted}
(W)     addc (1|M0)              r27.0<1>:ud   r23.0<0;1,0>:ud   r2.0<0;1,0>:ud   {AccWrEn,A@1}
(W)     add (1|M0)               r22.0<1>:d    r21.0<0;1,0>:d    r20.0<0;1,0>:d   {Compacted,I@5}
(W)     shr (1|M0)               r31.0<1>:ud   r18.0<0;1,0>:ud   31:w              
(~f0.0) cmp (16|M0)   (lt)f0.0   null<1>:d     r95.0<1;1,0>:ud   r92.1<0;1,0>:ud 
(W)     or (1|M0)                r26.0<1>:d    r25.0<0;1,0>:d    r24.0<0;1,0>:d   {Compacted,I@6}
(W)     mov (1|M0)               r28.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
(W)     shl (1|M0)               r32.0<1>:d    r22.0<0;1,0>:d    1:w               {Compacted,I@5}
(W)     addc (1|M0)              r97.0<1>:ud   r27.0<0;1,0>:ud   r30.0<0;1,0>:ud  {AccWrEn}
(W)     add3 (1|M0)              r29.0<1>:ud   r28.0<0;0>:ud     r26.0<0;0>:ud     r2.1<0>:ud       {I@3}
(W)     or (1|M0)                r33.0<1>:d    r32.0<0;1,0>:d    r31.0<0;1,0>:d   {Compacted,I@3}
(W)     mov (1|M0)               r34.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
(W)     add3 (1|M0)              r92.2<1>:ud   r34.0<0;0>:ud     r29.0<0;0>:ud     r33.0<0>:ud      {I@1}
(~f0.0) goto (16|M0)                         L3880                  L3880                
L864:
(W)     shr (1|M0)               r2.0<1>:ud    r5.0<0;1,0>:ud    20:w              
(W)     asr (1|M0)               r3.0<1>:d     r5.0<0;1,0>:d     20:w               {Compacted}
(W)     mov (1|M0)               r92.7<1>:d    1044480:d                              
(W)     asr (1|M0)               r92.5<1>:d    r5.0<0;1,0>:d     31:w               {Compacted}
(W)     and (1|M0)               r7.0<1>:d     r5.0<0;1,0>:d     1048575:d              
(W)     bfn.0xF8 (1|M0)          r6.5<1>:ud    r3.0<0;0>:ud      r92.7<0;0>:ud     r2.0<0>:ud       {I@3} // s0&s1|s2
(W)     mov (1|M0)               r97.2<1>:ud   0x49800000:ud                             
(W)     shr (1|M0)               r5.1<1>:ud    r92.5<0;1,0>:ud   8:w               {I@4}
(W)     mov (1|M0)               r97.1<1>:f    r7.0<0;1,0>:ud                   {Compacted,I@4}
(W)     mov (1|M0)               r111.0<1>:f   r6.5<0;1,0>:ud                   {Compacted,I@3}
(W)     mov (1|M0)               r97.3<1>:f    0x53800000:f                               {Compacted}
(W)     mov (1|M0)               r111.1<1>:f   r5.1<0;1,0>:ud                   {Compacted,I@1}
(W)     mad (1|M0)               r8.0<1>:f     r97.1<0;0>:f      r97.2<0;0>:f      r111.0<0>:f      {F@3}
(W)     mov (1|M0)               r11.0<1>:f    -4.172325e-07:f                               {Compacted}
(W)     mad (1|M0)               r9.0<1>:f     r8.0<0;0>:f       r97.3<0;0>:f      r111.1<0>:f      {F@2}
(W)     cmp (16|M0)   (eq)f0.0   null<1>:d     r5.0<0;1,0>:d     0:w               {Compacted}
        sync.nop                             null                             {Compacted,F@1}
(W)     math.inv (1|M0)          r10.0<1>:f    r9.0<0;1,0>:f                    {$3}
        mov (16|M0)              r99.0<1>:d    r93.0<1;1,0>:d                  
        mov (16|M0)              r101.0<1>:d   r95.0<1;1,0>:d                  
(W)     mov (2|M0)               r92.3<1>:d    r5.6<1;1,0>:d                   
(W)     asr (1|M0)               r92.6<1>:d    r7.4<0;1,0>:d     31:w              
(W)     mov (1|M0)               r97.7<1>:f    0xCF800000:f                               {Compacted}
(W)     mov (1|M0)               r98.0<1>:f    -1.048576e+06:f                               {Compacted}
(W)     mov (1|M0)               r98.1<1>:f    -1.0:f                               {Compacted}
(W)     mul (1|M0)               r97.5<1>:f    r97.1<0;1,0>:f    9.536743e-07:f              
(W)     mul (1|M0)               r98.4<1>:f    r111.0<0;1,0>:f   -1.048576e+06:f               {Compacted}
(W)     mul (1|M0)               r97.6<1>:f    r111.0<0;1,0>:f   9.536743e-07:f               {Compacted}
(W)     mul (1|M0)               r98.5<1>:f    r111.1<0;1,0>:f   -1.048576e+06:f              
(W)     mad (1|M0)               r97.4<1>:f    r10.0<0;0>:f      r11.0<0;0>:f      r10.0<0>:f       {$3.dst}
L1232:
        or (16|M0)               r2.0<1>:d     r101.0<1;1,0>:d   r92.5<0;1,0>:d   {Compacted,I@3}
        cmp (16|M0)   (lt)f0.1   null<1>:d     r2.0<1;1,0>:ud    0x1:uw              {I@1}
(~f0.1) goto (16|M0)                         L1720                  L1720                
L1272:
(~f0.0) goto (16|M0)                         L1320                  L1320                
L1288:
        mov (16|M0)              r103.0<1>:d   -1:w                              
        goto (16|M0)                         L1320                  L1672                
L1320:
        join (16|M0)                         L1672                                
L1336:
(W)     xor (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x30:uw              {A@1}
(W)     mov (1|M0)               r2.0<1>:f     r5.0<0;1,0>:ud                   {Compacted,A@1}
(W)     mov (1|M0)               r12.0<1>:f    0xB4C00000:f                               {Compacted}
(W)     math.inv (1|M0)          r11.0<1>:f    r2.0<0;1,0>:f                    {@2,$5}
        mov (16|M0)              r9.0<1>:f     r99.0<1;1,0>:ud                  {Compacted}
        sync.nop                             null                             {Compacted,$5.dst}
(W)     mad (1|M0)               r13.0<1>:f    r11.0<0;0>:f      r12.0<0;0>:f      r11.0<0>:f       {Compacted,F@2}
(W)     mov (1|M0)               r3.0<1>:ud    r2.0<0;1,0>:f                   
        mov (16|M0)              r16.0<1>:ud   r9.0<1;1,0>:f                    {F@2}
        mul (16|M0)              r14.0<1>:f    r9.0<1;1,0>:f     r13.0<0;1,0>:f   {Compacted,F@1}
(W)     add (1|M0)               r5.1<1>:d     r5.0<0;1,0>:d     -r3.0<0;1,0>:d   {Compacted,I@2}
        add (16|M0)              r16.0<1>:d    r99.0<1;1,0>:d    -r16.0<1;1,0>:d  {Compacted,I@2}
        mov (16|M0)              r18.0<1>:ud   r14.0<1;1,0>:f                   {F@1}
(W)     mov (1|M0)               r20.0<1>:f    r5.1<0;1,0>:ud                   {Compacted,I@3}
        mov (16|M0)              r21.0<1>:f    r16.0<1;1,0>:ud                  {Compacted,I@2}
        mov (16|M0)              r23.0<1>:f    r18.0<1;1,0>:ud                  {Compacted,I@1}
        mad (16|M0)              acc0.0<1>:f   r9.0<1;0>:f       r23.0<1;0>:f      -r2.0<0>:f       {Compacted,F@1}
        mad (16|M0)              acc2.0<1>:f   r21.0<1;0>:f      r23.0<1;0>:f      -r20.0<0>:f      {Compacted}
        add (16|M0)              acc0.0<1>:f   acc0.0<1;1,0>:f   acc2.0<1;1,0>:f 
        mul (16|M0)              r31.0<1>:f    r13.0<0;1,0>:f    acc0.0<1;1,0>:f 
(W)     xor (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x30:uw              {A@1}
        mov (16|M0)              r33.0<1>:ud   r31.0<1;1,0>:f                   {A@1}
        add (16|M0)              r35.0<1>:d    r33.0<1;1,0>:d    r18.0<1;1,0>:d   {Compacted,I@1}
(W)     mul (8|M0)               acc0.0<1>:d   r35.0<1;1,0>:d    r5.0<0;1,0>:uw   {Compacted,I@1}
        mach (8|M0)              r35.0<1>:d    r35.0<1;1,0>:d    r5.0<0;1,0>:d    {Compacted}
(W)     mul (8|M8)               acc0.0<1>:d   r36.0<1;1,0>:d    r5.0<0;1,0>:uw  
        mach (8|M8)              r36.0<1>:d    r36.0<1;1,0>:d    r5.0<0;1,0>:d    {Compacted}
        add (16|M0)              r35.0<1>:d    r99.0<1;1,0>:d    -r35.0<1;1,0>:d  {Compacted,I@1}
        cmp (16|M0)   (ge)f0.1   r37.0<1>:ud   r35.0<1;1,0>:ud   r5.0<0;1,0>:ud   {I@1}
        add3 (16|M0)             r103.0<1>:d   r33.0<1;0>:d      r18.0<1;0>:d      -r37.0<1>:d      {I@1}
L1672:
        join (16|M0)                         L1720                                
L1688:
        mov (16|M0)              r105.0<1>:d   0:w                              
        goto (16|M0)                         L1720                  L2744                
L1720:
        join (16|M0)                         L2744                                
L1736:
        shr (16|M0)              r2.0<1>:ud    r101.0<1;1,0>:ud  8:w              
        mov (16|M0)              r9.0<1>:f     r2.0<1;1,0>:ud                   {Compacted,I@1}
        shr (16|M0)              r19.0<1>:ud   r99.0<1;1,0>:ud   20:w              
        shl (16|M0)              r21.0<1>:d    r101.0<1;1,0>:d   12:w               {Compacted}
        mul (16|M0)              acc0.0<1>:f   r97.4<0;1,0>:f    r9.0<1;1,0>:f    {Compacted,F@1}
        or (16|M0)               r23.0<1>:d    r19.0<1;1,0>:d    r21.0<1;1,0>:d   {Compacted,I@1}
        rndd (16|M0)             r13.0<1>:f    acc0.0<1;1,0>:f                  {Compacted}
        bfn.0xF8 (16|M0)         r19.0<1>:ud   r23.0<1;0>:ud     r92.7<0;0>:ud     r19.0<1>:ud      {I@1} // s0&s1|s2
        mad (16|M0)              acc0.0<1>:f   r9.0<1;0>:f       r13.0<1;0>:f      -r97.1<0>:f      {Compacted,F@1}
        mov (16|M0)              r25.0<1>:f    r19.0<1;1,0>:ud                  {Compacted,I@1}
        mad (16|M0)              acc0.0<1>:f   acc0.0<1;0>:f     r13.0<1;0>:f      r98.4<0>:f       {Compacted}
        mad (16|M0)              acc2.0<1>:f   r25.0<1;0>:f      acc0.0<1;0>:f     r97.2<0>:f       {Compacted,F@2}
        mul (16|M0)              acc2.0<1>:f   r97.4<0;1,0>:f    acc2.0<1;1,0>:f 
        rndd (16|M0)             r29.0<1>:f    acc2.0<1;1,0>:f                  {Compacted}
        mul (16|M0)              acc2.0<1>:f   r97.5<0;1,0>:f    r29.0<1;1,0>:f   {Compacted,F@1}
        rndd (16|M0)             acc2.0<1>:f   acc2.0<1;1,0>:f                 
        and (16|M0)              r45.0<1>:d    r99.0<1;1,0>:d    1048575:d              
        mad (16|M0)              acc0.0<1>:f   acc0.0<1;0>:f     r29.0<1;0>:f      -r111.0<0>:f    
        mad (16|M0)              r39.0<1>:f    -acc2.0<1;0>:f    r29.0<1;0>:f      r97.5<0>:f      
        mov (16|M0)              r47.0<1>:f    r45.0<1;1,0>:ud                  {Compacted,I@1}
        mad (16|M0)              r33.0<1>:f    acc0.0<1;0>:f     r29.0<1;0>:f      r98.5<0>:f       {Compacted}
        mad (16|M0)              r43.0<1>:f    r25.0<1;0>:f      r39.0<1;0>:f      r98.0<0>:f       {Compacted,F@3}
        mad (16|M0)              r41.0<1>:f    r33.0<1;0>:f      acc2.0<1;0>:f     r98.1<0>:f       {Compacted,F@2}
        mad (16|M0)              acc0.0<1>:f   r47.0<1;0>:f      r43.0<1;0>:f      r97.2<0>:f       {Compacted,F@2}
        mad (16|M0)              acc0.0<1>:f   acc0.0<1;0>:f     r41.0<1;0>:f      r97.3<0>:f       {Compacted,F@2}
        mul (16|M0)              acc0.0<1>:f   r97.4<0;1,0>:f    acc0.0<1;1,0>:f 
        rndd (16|M0)             r53.0<1>:f    acc0.0<1;1,0>:f                  {Compacted}
        mul (16|M0)              acc0.0<1>:f   r97.5<0;1,0>:f    r53.0<1;1,0>:f   {Compacted,F@1}
        mul (16|M0)              acc2.0<1>:f   r97.6<0;1,0>:f    r53.0<1;1,0>:f   {Compacted}
        rndd (16|M0)             acc0.0<1>:f   acc0.0<1;1,0>:f                 
        rndd (16|M0)             acc2.0<1>:f   acc2.0<1;1,0>:f                 
        mad (16|M0)              r55.0<1>:f    r41.0<1;0>:f      r53.0<1;0>:f      -r111.1<0>:f     {Compacted}
        mad (16|M0)              r63.0<1>:f    r43.0<1;0>:f      acc0.0<1;0>:f     r98.1<0>:f       {Compacted}
        mad (16|M0)              r71.0<1>:f    -acc2.0<1;0>:f    r53.0<1;0>:f      r97.6<0>:f      
        mad (16|M0)              r61.0<1>:f    -acc0.0<1;0>:f    r53.0<1;0>:f      r97.5<0>:f      
        mad (16|M0)              acc2.0<1>:f   r55.0<1;0>:f      acc2.0<1;0>:f     r98.1<0>:f       {Compacted,F@4}
        sync.nop                             null                             {Compacted,$4.src}
        mad (16|M0)              r75.0<1>:f    r63.0<1;0>:f      r71.0<1;0>:f      r98.0<0>:f       {Compacted,F@3}
        mad (16|M0)              r65.0<1>:f    r47.0<1;0>:f      r61.0<1;0>:f      r98.0<0>:f       {Compacted,F@3}
        mad (16|M0)              acc0.0<1>:f   r75.0<1;0>:f      acc2.0<1;0>:f     r97.2<0>:f       {Compacted,F@2}
        mad (16|M0)              acc0.0<1>:f   r65.0<1;0>:f      acc0.0<1;0>:f     r97.2<0>:f       {Compacted,F@2}
        mul (16|M0)              acc0.0<1>:f   r97.4<0;1,0>:f    acc0.0<1;1,0>:f 
        rndd (16|M0)             r87.0<1>:f    acc0.0<1;1,0>:f                  {Compacted}
        mad (16|M0)              acc0.0<1>:f   acc2.0<1;0>:f     -r87.0<1;0>:f     r111.1<0>:f      {F@1}
        mul (16|M0)              acc2.0<1>:f   acc0.0<1;1,0>:f   0x2F800000:f               {Compacted}
        rndz (16|M0)             acc2.0<1>:f   acc2.0<1;1,0>:f                 
        mov (16|M0)              r79.0<1>:d    r29.0<1;1,0>:f                   {Compacted}
        mad (16|M0)              r2.0<1>:f     r75.0<1;0>:f      -r87.0<1;0>:f     r111.0<0>:f      {Compacted}
        mad (16|M0)              r9.0<1>:f     r65.0<1;0>:f      -r87.0<1;0>:f     r97.1<0>:f       {Compacted}
        mad (16|M0)              r29.0<1>:f    acc0.0<1;0>:f     acc2.0<1;0>:f     r97.7<0>:f       {I@1}
        mov (16|M0)              r77.0<1>:d    r13.0<1;1,0>:f                   {Compacted}
        mov (16|M0)              r15.0<1>:d    r9.0<1;1,0>:f                    {Compacted,F@2}
        mov (16|M0)              r31.0<1>:ud   r29.0<1;1,0>:f                   {F@1}
        mov (16|M0)              r13.0<1>:d    r2.0<1;1,0>:f                    {Compacted}
        asr (16|M0)              r23.0<1>:d    r15.0<1;1,0>:d    31:w               {Compacted,I@3}
        addc (8|M0)              r33.0<1>:ud   r15.0<1;1,0>:ud   0x0:ud              {AccWrEn,Compacted}
        shl (16|M0)              r31.0<1>:d    r31.0<1;1,0>:d    8:w               {Compacted,I@4}
        asr (16|M0)              r17.0<1>:d    r13.0<1;1,0>:d    31:w               {Compacted,I@4}
        shl (16|M0)              r19.0<1>:d    r13.0<1;1,0>:d    20:w               {Compacted}
        add3 (8|M0)              r35.0<1>:ud   acc0.0<1;0>:ud    r31.0<1;0>:ud     r23.0<1>:ud      {I@3}
        shl (16|M0)              r17.0<1>:d    r17.0<1;1,0>:d    20:w               {Compacted,I@3}
        shr (16|M0)              r13.0<1>:ud   r13.0<1;1,0>:ud   12:w              
        addc (8|M8)              r34.0<1>:ud   r16.0<1;1,0>:ud   0x0:ud              {AccWrEn}
        or (16|M0)               r21.0<1>:d    r17.0<1;1,0>:d    r13.0<1;1,0>:d   {Compacted,I@2}
        add3 (8|M8)              r36.0<1>:ud   acc0.0<1;0>:ud    r32.0<1;0>:ud     r24.0<1>:ud     
        addc (8|M0)              r37.0<1>:ud   r33.0<1;1,0>:ud   r19.0<1;1,0>:ud  {AccWrEn,Compacted}
(W)     mov (1|M0)               r51.0<1>:w    -1:w                              
        add3 (8|M0)              r39.0<1>:ud   acc0.0<1;0>:ud    r35.0<1;0>:ud     r21.0<1>:ud      {I@4}
        addc (8|M8)              r38.0<1>:ud   r34.0<1;1,0>:ud   r20.0<1;1,0>:ud  {AccWrEn}
        shl (16|M0)              r43.0<1>:d    r79.0<1;1,0>:d    20:w               {Compacted}
        cmp (16|M0)   (ge)f1.1   null<1>:d     r37.0<1;1,0>:ud   r5.0<0;1,0>:ud   {I@2}
        add3 (8|M8)              r40.0<1>:ud   acc0.0<1;0>:ud    r36.0<1;0>:ud     r22.0<1>:ud     
        mov (16|M0)              r81.0<1>:d    r53.0<1;1,0>:f                   {Compacted}
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r39.0<1;1,0>:d    r92.5<0;1,0>:d   {I@2}
        mov (16|M0)              r11.0<1>:d    r87.0<1;1,0>:f                   {Compacted}
(~f1.1) cmp (16|M0)   (gt)f1.1   null<1>:d     r39.0<1;1,0>:ud   r92.5<0;1,0>:ud 
        shr (16|M0)              r45.0<1>:ud   r79.0<1;1,0>:ud   12:w              
        shl (16|M0)              r41.0<1>:d    r77.0<1;1,0>:d    8:w               {Compacted}
        addc (8|M0)              r47.0<1>:ud   r43.0<1;1,0>:ud   0x0:ud              {AccWrEn,Compacted}
(f1.1)  sel (16|M0)              r52.0<1>:d    r51.0<0;1,0>:w    0:w              
        add3 (8|M0)              r49.0<1>:ud   acc0.0<1;0>:ud    r45.0<1;0>:ud     r41.0<1>:ud      {I@3}
        add3 (16|M0)             r54.0<1>:d    r11.0<1;0>:d      r81.0<1;0>:d      -r52.0<1>:d      {I@2}
        addc (8|M8)              r48.0<1>:ud   r44.0<1;1,0>:ud   0x0:ud              {AccWrEn}
        add3 (8|M8)              r50.0<1>:ud   acc0.0<1;0>:ud    r46.0<1;0>:ud     r42.0<1>:ud     
        addc (8|M0)              r103.0<1>:ud  r47.0<1;1,0>:ud   r54.0<1;1,0>:ud  {AccWrEn,Compacted,I@3}
        add (8|M0)               r105.0<1>:ud  acc0.0<1;1,0>:ud  r49.0<1;1,0>:ud 
        addc (8|M8)              r104.0<1>:ud  r48.0<1;1,0>:ud   r55.0<1;1,0>:ud  {AccWrEn,I@4}
        add (8|M8)               r106.0<1>:ud  acc0.0<1;1,0>:ud  r50.0<1;1,0>:ud  {I@4}
L2744:
        join (16|M0)                         L3880                                
L2760:
        mul (8|M0)               acc0.0<1>:ud  r103.0<1;1,0>:ud  r5.0<0;1,0>:uw   {I@5}
        mach (8|M0)              r2.0<1>:ud    r103.0<1;1,0>:ud  r5.0<0;1,0>:ud   {AccWrEn,Compacted}
        shl (16|M0)              r57.0<1>:d    r99.0<1;1,0>:d    1:w               {Compacted}
        mov (8|M0)               r9.0<1>:ud    acc0.0<1;1,0>:ud                 {Compacted}
        mul (8|M8)               acc0.0<1>:ud  r104.0<1;1,0>:ud  r5.0<0;1,0>:uw   {I@7}
        mach (8|M8)              r3.0<1>:ud    r104.0<1;1,0>:ud  r5.0<0;1,0>:ud   {AccWrEn}
        shr (16|M0)              r59.0<1>:ud   r99.0<1;1,0>:ud   31:w              
        mov (8|M8)               r10.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
(W)     mul (8|M0)               acc0.0<1>:d   r103.0<1;1,0>:ud  r92.10<0;1,0>:uw
        mach (8|M0)              r13.0<1>:d    r103.0<1;1,0>:ud  r92.5<0;1,0>:d  
(W)     mul (8|M8)               acc0.0<1>:d   r104.0<1;1,0>:ud  r92.10<0;1,0>:uw
        mach (8|M8)              r14.0<1>:d    r104.0<1;1,0>:ud  r92.5<0;1,0>:d  
(W)     mul (8|M0)               acc0.0<1>:d   r5.0<0;1,0>:ud    r105.0<2;1,0>:uw
        add (16|M0)              r15.0<1>:d    r2.0<1;1,0>:d     r13.0<1;1,0>:d   {Compacted,I@2}
        mach (8|M0)              r13.0<1>:d    r5.0<0;1,0>:ud    r105.0<1;1,0>:d 
(W)     mul (8|M8)               acc0.0<1>:d   r5.0<0;1,0>:ud    r106.0<2;1,0>:uw
        mov (16|M0)              r11.0<1>:f    r9.0<1;1,0>:f                    {Compacted}
        mach (8|M8)              r14.0<1>:d    r5.0<0;1,0>:ud    r106.0<1;1,0>:d 
        subb (8|M0)              r19.0<1>:ud   r99.0<1;1,0>:ud   r11.0<1;1,0>:ud  {AccWrEn,Compacted,F@1}
        add (16|M0)              r17.0<1>:d    r15.0<1;1,0>:d    r13.0<1;1,0>:d   {Compacted,I@2}
        add3 (8|M0)              r21.0<1>:ud   -acc0.0<1;0>:ud   r101.0<1;0>:ud    -r17.0<1>:ud     {I@1}
        subb (8|M8)              r20.0<1>:ud   r100.0<1;1,0>:ud  r12.0<1;1,0>:ud  {AccWrEn}
        shl (16|M0)              r61.0<1>:d    r101.0<1;1,0>:d   1:w               {Compacted}
        add3 (8|M8)              r22.0<1>:ud   -acc0.0<1;0>:ud   r102.0<1;0>:ud    -r18.0<1>:ud    
        mul (8|M0)               acc0.0<1>:ud  r103.0<1;1,0>:ud  r7.8<0;1,0>:uw  
        mach (8|M0)              r23.0<1>:ud   r103.0<1;1,0>:ud  r7.4<0;1,0>:ud   {AccWrEn,Compacted}
        shl (16|M0)              r41.0<1>:d    r19.0<1;1,0>:d    1:w               {Compacted,I@5}
        mov (8|M0)               r25.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mul (8|M8)               acc0.0<1>:ud  r104.0<1;1,0>:ud  r7.8<0;1,0>:uw  
        mach (8|M8)              r24.0<1>:ud   r104.0<1;1,0>:ud  r7.4<0;1,0>:ud   {AccWrEn}
        shr (16|M0)              r43.0<1>:ud   r19.0<1;1,0>:ud   31:w              
        mov (8|M8)               r26.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
(W)     mul (8|M0)               acc0.0<1>:d   r103.0<1;1,0>:ud  r92.12<0;1,0>:uw
        mach (8|M0)              r27.0<1>:d    r103.0<1;1,0>:ud  r92.6<0;1,0>:d  
(W)     mul (8|M8)               acc0.0<1>:d   r104.0<1;1,0>:ud  r92.12<0;1,0>:uw
        mach (8|M8)              r28.0<1>:d    r104.0<1;1,0>:ud  r92.6<0;1,0>:d  
(W)     mul (8|M0)               acc0.0<1>:d   r7.4<0;1,0>:ud    r105.0<2;1,0>:uw
        add (16|M0)              r29.0<1>:d    r23.0<1;1,0>:d    r27.0<1;1,0>:d   {Compacted,I@2}
        mach (8|M0)              r27.0<1>:d    r7.4<0;1,0>:ud    r105.0<1;1,0>:d 
(W)     mul (8|M8)               acc0.0<1>:d   r7.4<0;1,0>:ud    r106.0<2;1,0>:uw
        mach (8|M8)              r28.0<1>:d    r7.4<0;1,0>:ud    r106.0<1;1,0>:d 
        shl (16|M0)              r33.0<1>:d    r25.0<1;1,0>:d    1:w               {Compacted}
        add (16|M0)              r31.0<1>:d    r29.0<1;1,0>:d    r27.0<1;1,0>:d   {Compacted,I@2}
        shr (16|M0)              r35.0<1>:ud   r25.0<1;1,0>:ud   31:w              
        shl (16|M0)              r31.0<1>:d    r31.0<1;1,0>:d    1:w               {Compacted,I@2}
        addc (8|M0)              r37.0<1>:ud   r97.0<0;1,0>:ud   r33.0<1;1,0>:ud  {AccWrEn,Compacted}
        or (16|M0)               r31.0<1>:d    r31.0<1;1,0>:d    r35.0<1;1,0>:d   {Compacted,I@2}
        add3 (8|M0)              r39.0<1>:ud   acc0.0<1;0>:ud    r92.2<0;0>:ud     r31.0<1>:ud      {I@1}
        addc (8|M8)              r38.0<1>:ud   r97.0<0;1,0>:ud   r34.0<1;1,0>:ud  {AccWrEn}
        shl (16|M0)              r45.0<1>:d    r21.0<1;1,0>:d    1:w               {Compacted}
        add3 (8|M8)              r40.0<1>:ud   acc0.0<1;0>:ud    r92.2<0;0>:ud     r32.0<1>:ud     
        addc (8|M0)              r47.0<1>:ud   r37.0<1;1,0>:ud   r41.0<1;1,0>:ud  {AccWrEn,Compacted}
        or (16|M0)               r45.0<1>:d    r45.0<1;1,0>:d    r43.0<1;1,0>:d   {Compacted,I@3}
        mov (8|M0)               r49.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        addc (8|M8)              r48.0<1>:ud   r38.0<1;1,0>:ud   r42.0<1;1,0>:ud  {AccWrEn}
        add3 (8|M0)              r50.0<1>:ud   r49.0<1;0>:ud     r39.0<1;0>:ud     r45.0<1>:ud      {I@2}
        mov (8|M8)               r55.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        addc (8|M0)              r63.0<1>:ud   r57.0<1;1,0>:ud   r92.3<0;1,0>:ud  {AccWrEn,Compacted}
        add3 (8|M8)              r56.0<1>:ud   r55.0<1;0>:ud     r40.0<1;0>:ud     r46.0<1>:ud      {I@2}
        mov (8|M0)               r65.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        addc (8|M8)              r64.0<1>:ud   r58.0<1;1,0>:ud   r92.3<0;1,0>:ud  {AccWrEn}
        mov (8|M0)               r51.1<2>:ud   r50.0<1;1,0>:ud                 
        mov (8|M8)               r70.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        addc (8|M0)              r107.0<1>:ud  r99.0<1;1,0>:ud   r8.4<0;1,0>:ud   {AccWrEn,Compacted}
        mov (8|M8)               r53.1<2>:ud   r56.0<1;1,0>:ud                  {I@6}
        mov (8|M0)               r51.0<2>:d    r47.0<1;1,0>:d                  
        mov (8|M8)               r53.0<2>:d    r48.0<1;1,0>:d                  
        add (8|M0)               r109.0<1>:ud  acc0.0<1;1,0>:ud  r101.0<1;1,0>:ud
        addc (8|M8)              r108.0<1>:ud  r100.0<1;1,0>:ud  r8.4<0;1,0>:ud   {AccWrEn}
        send.ugm (16|M0)         r72      r51     null:0  0x0            0x08280B80           {A@3,$6} // wr:4+0, rd:2; load.ugm.d16u32.a64.ca.ca
        cmp (16|M0)   (lt)f1.0   null<1>:d     r107.0<1;1,0>:ud  r92.0<0;1,0>:ud  {I@1}
        add (8|M8)               r110.0<1>:ud  acc0.0<1;1,0>:ud  r102.0<1;1,0>:ud
        or (16|M0)               r61.0<1>:d    r61.0<1;1,0>:d    r59.0<1;1,0>:d   {Compacted}
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r109.0<1;1,0>:d   r92.1<0;1,0>:d   {I@2}
        sync.nop                             null                             {Compacted,$4.src}
        add3 (8|M0)              r66.1<2>:ud   r65.0<1;0>:ud     r61.0<1;0>:ud     r92.4<0>:ud      {I@2}
        add3 (8|M8)              r68.1<2>:ud   r70.0<1;0>:ud     r62.0<1;0>:ud     r92.4<0>:ud     
(~f1.0) cmp (16|M0)   (lt)f1.0   null<1>:d     r109.0<1;1,0>:ud  r92.1<0;1,0>:ud 
        mov (8|M0)               r66.0<2>:d    r63.0<1;1,0>:d                  
        mov (8|M8)               r68.0<2>:d    r64.0<1;1,0>:d                  
        mov (16|M0)              r74.0<1>:ud   r72.0<2;1,0>:uw                  {$6.dst}
        send.ugm (16|M0)         null     r66     r74:2   0x0            0x080E0B84           {A@1,$4} // wr:4+2, rd:0; store.ugm.d16u32.a64.wb.wb
(~f1.0) goto (16|M0)                         L3880                  L3880                
L3848:
(f1.0)  sel (16|M0)              r99.0<1>:d    r107.0<1;1,0>:d   r93.0<1;1,0>:d   {Compacted}
(f1.0)  sel (16|M0)              r101.0<1>:d   r109.0<1;1,0>:d   r95.0<1;1,0>:d   {Compacted}
(W)     jmpi                                 L1232                                
L3880:
        join (16|M0)                         L3896                                
L3896:
(W)     mov (8|M0)               r127.0<1>:f   r91.0<1;1,0>:f                   {Compacted}
(W)     send.gtwy (1|M0)         null     r127    null:0  0x0            0x02000010           {EOT,A@1} // wr:1+0, rd:0; end of thread
L3920:
        nop                    
(W)     mov (16|M0)              null<1>:ud    0x9E09665A:ud                             
(W)     mov (16|M0)              null<1>:ud    0xA6E09A48:ud                             
(W)     mov (16|M0)              null<1>:ud    0x0:ud                             
(W)     mov (16|M0)              null<1>:ud    0xF:ud                             
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
