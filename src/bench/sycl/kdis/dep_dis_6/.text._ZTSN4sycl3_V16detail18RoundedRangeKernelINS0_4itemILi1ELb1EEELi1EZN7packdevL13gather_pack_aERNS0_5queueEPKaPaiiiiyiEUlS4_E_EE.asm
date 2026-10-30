L0:
(W)     mov (8|M0)               r127.0<1>:ud  0x0:ud                             
(W)     and (1|M0)               r127.2<1>:ud  r0.0<0;1,0>:ud    0xFFFFFFC0:ud             
(W)     and (1|M0)               r127.0<1>:uw  r0.4<0;1,0>:uw    0xFF:uw             
(W)     add (1|M0)               r127.2<1>:ud  r127.2<0;1,0>:ud  0xA0:ud              {I@2}
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
(W)     add (1|M0)               r127.2<1>:ud  r127.2<0;1,0>:ud  0x80:uw              {$2.src}
(W)     send.dc0 (8|M0)          r9       r127    null:0  0x0            0x021842FD           {A@1,$3} // wr:1h+0, rd:1; oword aligned block read x2
(W)     mov (8|M0)               r84.0<1>:ud   r0.0<1;1,0>:ud                  
(W)     or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x4C0:uw              {A@1}
(W)     mul (1|M0)               acc0.0<1>:ud  r4.3<0;1,0>:ud    r84.2<0;1,0>:uw  {A@1}
(W)     mach (1|M0)              r11.0<1>:ud   r4.3<0;1,0>:ud    r84.1<0;1,0>:ud  {AccWrEn}
        mov (16|M0)              r12.0<1>:d    r1.0<1;1,0>:uw                   {$0.dst}
(W)     mov (1|M0)               r10.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
(W)     mov (2|M0)               r85.0<1>:d    r4.6<1;1,0>:d                   
        addc (8|M0)              r14.0<1>:ud   r10.0<0;1,0>:ud   r12.0<1;1,0>:ud  {AccWrEn,Compacted,I@2}
        sync.nop                             null                             {Compacted,$2.dst}
(W)     mov (2|M0)               r3.0<1>:d     r7.6<1;1,0>:d                    {$1.dst}
        add (8|M0)               r16.0<1>:ud   acc0.0<1;1,0>:ud  r11.0<0;1,0>:ud 
        addc (8|M8)              r15.0<1>:ud   r10.0<0;1,0>:ud   r13.0<1;1,0>:ud  {AccWrEn}
(W)     asr (1|M0)               r18.0<1>:d    r7.0<0;1,0>:d     31:w               {Compacted}
        add (8|M8)               r17.0<1>:ud   acc0.0<1;1,0>:ud  r11.0<0;1,0>:ud 
        addc (8|M0)              r86.0<1>:ud   r14.0<1;1,0>:ud   r4.0<0;1,0>:ud   {AccWrEn,Compacted,I@6}
(W)     mov (2|M0)               r2.0<1>:d     r6.6<1;1,0>:d                   
        add (8|M0)               r88.0<1>:ud   acc0.0<1;1,0>:ud  r16.0<1;1,0>:ud  {I@6}
        addc (8|M8)              r87.0<1>:ud   r15.0<1;1,0>:ud   r4.0<0;1,0>:ud   {AccWrEn,I@6}
        cmp (16|M0)   (lt)f1.0   null<1>:d     r86.0<1;1,0>:ud   r85.0<0;1,0>:ud  {I@1}
        add (8|M8)               r89.0<1>:ud   acc0.0<1;1,0>:ud  r17.0<1;1,0>:ud 
(W)     mul (1|M0)               acc0.0<1>:ud  r7.0<0;1,0>:ud    r3.0<0;1,0>:uw  
(W)     mach (1|M0)              r20.0<1>:ud   r7.0<0;1,0>:ud    r3.0<0;1,0>:ud   {AccWrEn}
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r88.0<1;1,0>:d    r85.1<0;1,0>:d   {I@3}
(W)     mov (1|M0)               r19.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
(W)     mul (1|M0)               acc0.0<1>:d   r7.0<0;1,0>:ud    r3.2<0;1,0>:uw  
(W)     mach (1|M0)              r21.0<1>:d    r7.0<0;1,0>:ud    r3.1<0;1,0>:d   
(W)     mul (1|M0)               acc0.0<1>:d   r3.0<0;1,0>:ud    r18.0<0;1,0>:uw 
(~f1.0) cmp (16|M0)   (lt)f1.0   null<1>:d     r88.0<1;1,0>:ud   r85.1<0;1,0>:ud 
(W)     add (1|M0)               r22.0<1>:d    r20.0<0;1,0>:d    r21.0<0;1,0>:d   {Compacted,I@3}
(W)     mach (1|M0)              r21.0<1>:d    r3.0<0;1,0>:ud    r18.0<0;1,0>:d  
(W)     addc (1|M0)              r90.0<1>:ud   r19.0<0;1,0>:ud   r2.0<0;1,0>:ud   {AccWrEn}
(W)     add (1|M0)               r23.0<1>:d    r22.0<0;1,0>:d    r21.0<0;1,0>:d   {Compacted,I@2}
(W)     mov (1|M0)               r24.0<1>:ud   acc0.0<0;1,0>:ud                 {Compacted}
(W)     add3 (1|M0)              r85.2<1>:ud   r24.0<0;0>:ud     r23.0<0;0>:ud     r2.1<0>:ud       {I@1}
(~f1.0) goto (16|M0)                         L3904                  L3904                
L776:
(W)     shr (1|M0)               r2.0<1>:ud    r5.0<0;1,0>:ud    20:w              
(W)     asr (1|M0)               r3.0<1>:d     r5.0<0;1,0>:d     20:w               {Compacted}
(W)     mov (1|M0)               r85.7<1>:d    1044480:d                              
(W)     asr (1|M0)               r85.5<1>:d    r5.0<0;1,0>:d     31:w               {Compacted}
(W)     and (1|M0)               r7.1<1>:d     r5.0<0;1,0>:d     1048575:d              
(W)     bfn.0xF8 (1|M0)          r6.1<1>:ud    r3.0<0;0>:ud      r85.7<0;0>:ud     r2.0<0>:ud       {I@3} // s0&s1|s2
(W)     mov (1|M0)               r90.2<1>:f    1.048576e+06:f                               {Compacted}
(W)     shr (1|M0)               r5.1<1>:ud    r85.5<0;1,0>:ud   8:w               {I@3}
(W)     mov (1|M0)               r90.1<1>:f    r7.1<0;1,0>:ud                   {Compacted,I@3}
(W)     mov (1|M0)               r106.4<1>:f   r6.1<0;1,0>:ud                   {I@2}
(W)     mov (1|M0)               r90.3<1>:f    0x53800000:f                               {Compacted}
(W)     mov (1|M0)               r106.5<1>:f   r5.1<0;1,0>:ud                   {I@1}
(W)     mad (1|M0)               r8.1<1>:f     r90.1<0;0>:f      r90.2<0;0>:f      r106.4<0>:f      {F@3}
(W)     mov (1|M0)               r11.0<1>:f    -4.172325e-07:f                               {Compacted}
        sync.nop                             null                             {Compacted,$3.dst}
(W)     mad (1|M0)               r9.3<1>:f     r8.1<0;0>:f       r90.3<0;0>:f      r106.5<0>:f      {F@2}
(W)     cmp (16|M0)   (eq)f0.0   null<1>:d     r5.0<0;1,0>:d     0:w               {Compacted}
        sync.nop                             null                             {Compacted,F@1}
(W)     math.inv (1|M0)          r10.0<1>:f    r9.3<0;1,0>:f                    {$4}
        mov (16|M0)              r92.0<1>:d    r86.0<1;1,0>:d                  
        mov (16|M0)              r94.0<1>:d    r88.0<1;1,0>:d                  
(W)     mov (2|M0)               r85.3<1>:d    r5.6<1;1,0>:d                   
(W)     asr (1|M0)               r85.6<1>:d    r8.0<0;1,0>:d     31:w               {Compacted}
(W)     mov (1|M0)               r90.7<1>:d    127:w                              
(W)     mov (1|M0)               r91.0<1>:f    0xCF800000:f                               {Compacted}
(W)     mov (1|M0)               r91.1<1>:f    -1.048576e+06:f                               {Compacted}
(W)     mov (1|M0)               r91.2<1>:f    -1.0:f                               {Compacted}
(W)     mul (1|M0)               r90.5<1>:f    r90.1<0;1,0>:f    9.536743e-07:f              
(W)     mul (1|M0)               r91.4<1>:f    r106.4<0;1,0>:f   -1.048576e+06:f              
(W)     mul (1|M0)               r90.6<1>:f    r106.4<0;1,0>:f   9.536743e-07:f              
(W)     mul (1|M0)               r91.5<1>:f    r106.5<0;1,0>:f   -1.048576e+06:f              
(W)     mad (1|M0)               r90.4<1>:f    r10.0<0;0>:f      r11.0<0;0>:f      r10.0<0>:f       {$4.dst}
L1184:
        shr (16|M0)              r96.0<1>:ud   r94.0<1;1,0>:ud   12:w               {I@4}
        sync.nop                             null                             {Compacted,$5.src}
        or (16|M0)               r12.0<1>:d    r96.0<1;1,0>:d    r85.5<0;1,0>:d   {Compacted,I@1}
        cmp (16|M0)   (lt)f1.0   null<1>:d     r12.0<1;1,0>:ud   0x1:uw              {I@1}
        shl (16|M0)              r2.0<1>:d     r94.0<1;1,0>:d    20:w               {Compacted}
        shr (16|M0)              r10.0<1>:ud   r92.0<1;1,0>:ud   12:w               {F@1}
        or (16|M0)               r98.0<1>:d    r10.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@1}
(~f1.0) goto (16|M0)                         L1728                  L1728                
L1280:
(~f0.0) goto (16|M0)                         L1328                  L1328                
L1296:
        mov (16|M0)              r100.0<1>:d   -1:w                              
        goto (16|M0)                         L1328                  L1680                
L1328:
        join (16|M0)                         L1680                                
L1344:
(W)     xor (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x30:uw              {A@1}
(W)     mov (1|M0)               r2.0<1>:f     r5.0<0;1,0>:ud                   {Compacted,A@1}
(W)     mov (1|M0)               r13.0<1>:f    0xB4C00000:f                               {Compacted}
(W)     math.inv (1|M0)          r12.0<1>:f    r2.0<0;1,0>:f                    {@2,$6}
        mov (16|M0)              r10.0<1>:f    r98.0<1;1,0>:ud                  {Compacted}
        sync.nop                             null                             {Compacted,$6.dst}
(W)     mad (1|M0)               r14.0<1>:f    r12.0<0;0>:f      r13.0<0;0>:f      r12.0<0>:f       {Compacted,F@2}
(W)     mov (1|M0)               r3.0<1>:ud    r2.0<0;1,0>:f                   
        mov (16|M0)              r17.0<1>:ud   r10.0<1;1,0>:f                   {F@2}
        mul (16|M0)              r15.0<1>:f    r10.0<1;1,0>:f    r14.0<0;1,0>:f   {Compacted,F@1}
(W)     add (1|M0)               r5.1<1>:d     r5.0<0;1,0>:d     -r3.0<0;1,0>:d   {Compacted,I@2}
        add (16|M0)              r17.0<1>:d    r98.0<1;1,0>:d    -r17.0<1;1,0>:d  {Compacted,I@2}
        mov (16|M0)              r19.0<1>:ud   r15.0<1;1,0>:f                   {F@1}
(W)     mov (1|M0)               r21.0<1>:f    r5.1<0;1,0>:ud                   {Compacted,I@3}
        mov (16|M0)              r22.0<1>:f    r17.0<1;1,0>:ud                  {Compacted,I@2}
        mov (16|M0)              r24.0<1>:f    r19.0<1;1,0>:ud                  {Compacted,I@1}
        mad (16|M0)              acc0.0<1>:f   r10.0<1;0>:f      r24.0<1;0>:f      -r2.0<0>:f       {Compacted,F@1}
        mad (16|M0)              acc2.0<1>:f   r22.0<1;0>:f      r24.0<1;0>:f      -r21.0<0>:f      {Compacted}
        add (16|M0)              acc0.0<1>:f   acc0.0<1;1,0>:f   acc2.0<1;1,0>:f 
        mul (16|M0)              r32.0<1>:f    r14.0<0;1,0>:f    acc0.0<1;1,0>:f 
(W)     xor (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x30:uw              {A@1}
        mov (16|M0)              r34.0<1>:ud   r32.0<1;1,0>:f                   {A@1}
        add (16|M0)              r36.0<1>:d    r34.0<1;1,0>:d    r19.0<1;1,0>:d   {Compacted,I@1}
(W)     mul (8|M0)               acc0.0<1>:d   r36.0<1;1,0>:d    r5.0<0;1,0>:uw   {Compacted,I@1}
        mach (8|M0)              r36.0<1>:d    r36.0<1;1,0>:d    r5.0<0;1,0>:d    {Compacted}
(W)     mul (8|M8)               acc0.0<1>:d   r37.0<1;1,0>:d    r5.0<0;1,0>:uw  
        mach (8|M8)              r37.0<1>:d    r37.0<1;1,0>:d    r5.0<0;1,0>:d    {Compacted}
        add (16|M0)              r36.0<1>:d    r98.0<1;1,0>:d    -r36.0<1;1,0>:d  {Compacted,I@1}
        cmp (16|M0)   (ge)f1.1   r38.0<1>:ud   r36.0<1;1,0>:ud   r5.0<0;1,0>:ud   {I@1}
        add3 (16|M0)             r100.0<1>:d   r34.0<1;0>:d      r19.0<1;0>:d      -r38.0<1>:d      {I@1}
L1680:
        join (16|M0)                         L1728                                
L1696:
        mov (16|M0)              r102.0<1>:d   0:w                              
        goto (16|M0)                         L1728                  L2728                
L1728:
        join (16|M0)                         L2728                                
L1744:
        shr (16|M0)              r2.0<1>:ud    r94.0<1;1,0>:ud   20:w              
        mov (16|M0)              r10.0<1>:f    r2.0<1;1,0>:ud                   {Compacted,I@1}
        mul (16|M0)              acc0.0<1>:f   r90.4<0;1,0>:f    r10.0<1;1,0>:f   {Compacted,F@1}
        shr (16|M0)              r20.0<1>:ud   r98.0<1;1,0>:ud   20:w              
        rndd (16|M0)             r14.0<1>:f    acc0.0<1;1,0>:f                  {Compacted}
        bfn.0xF8 (16|M0)         r20.0<1>:ud   r94.0<1;0>:ud     r85.7<0;0>:ud     r20.0<1>:ud      {I@1} // s0&s1|s2
        mad (16|M0)              acc0.0<1>:f   r10.0<1;0>:f      r14.0<1;0>:f      -r90.1<0>:f      {Compacted,F@1}
        mov (16|M0)              r22.0<1>:f    r20.0<1;1,0>:ud                  {Compacted,I@1}
        mad (16|M0)              acc0.0<1>:f   acc0.0<1;0>:f     r14.0<1;0>:f      r91.4<0>:f       {Compacted}
        mad (16|M0)              acc2.0<1>:f   r22.0<1;0>:f      acc0.0<1;0>:f     r90.2<0>:f       {Compacted,F@2}
        mul (16|M0)              acc2.0<1>:f   r90.4<0;1,0>:f    acc2.0<1;1,0>:f 
        rndd (16|M0)             r26.0<1>:f    acc2.0<1;1,0>:f                  {Compacted}
        mul (16|M0)              acc2.0<1>:f   r90.5<0;1,0>:f    r26.0<1;1,0>:f   {Compacted,F@1}
        rndd (16|M0)             acc2.0<1>:f   acc2.0<1;1,0>:f                 
        and (16|M0)              r42.0<1>:d    r98.0<1;1,0>:d    1048575:d              
        mad (16|M0)              acc0.0<1>:f   acc0.0<1;0>:f     r26.0<1;0>:f      -r106.4<0>:f    
        mad (16|M0)              r36.0<1>:f    -acc2.0<1;0>:f    r26.0<1;0>:f      r90.5<0>:f      
        mov (16|M0)              r44.0<1>:f    r42.0<1;1,0>:ud                  {Compacted,I@1}
        mad (16|M0)              r30.0<1>:f    acc0.0<1;0>:f     r26.0<1;0>:f      r91.5<0>:f       {Compacted}
        mad (16|M0)              r40.0<1>:f    r22.0<1;0>:f      r36.0<1;0>:f      r91.1<0>:f       {Compacted,F@3}
        mad (16|M0)              r38.0<1>:f    r30.0<1;0>:f      acc2.0<1;0>:f     r91.2<0>:f       {Compacted,F@2}
        mad (16|M0)              acc0.0<1>:f   r44.0<1;0>:f      r40.0<1;0>:f      r90.2<0>:f       {Compacted,F@2}
        mad (16|M0)              acc0.0<1>:f   acc0.0<1;0>:f     r38.0<1;0>:f      r90.3<0>:f       {Compacted,F@2}
        mul (16|M0)              acc0.0<1>:f   r90.4<0;1,0>:f    acc0.0<1;1,0>:f 
        rndd (16|M0)             r50.0<1>:f    acc0.0<1;1,0>:f                  {Compacted}
        mul (16|M0)              acc0.0<1>:f   r90.5<0;1,0>:f    r50.0<1;1,0>:f   {Compacted,F@1}
        mul (16|M0)              acc2.0<1>:f   r90.6<0;1,0>:f    r50.0<1;1,0>:f   {Compacted}
        rndd (16|M0)             acc0.0<1>:f   acc0.0<1;1,0>:f                 
        rndd (16|M0)             acc2.0<1>:f   acc2.0<1;1,0>:f                 
        mad (16|M0)              r52.0<1>:f    r38.0<1;0>:f      r50.0<1;0>:f      -r106.5<0>:f     {Compacted}
        mad (16|M0)              r60.0<1>:f    r40.0<1;0>:f      acc0.0<1;0>:f     r91.2<0>:f       {Compacted}
        mad (16|M0)              r68.0<1>:f    -acc2.0<1;0>:f    r50.0<1;0>:f      r90.6<0>:f      
        mad (16|M0)              r58.0<1>:f    -acc0.0<1;0>:f    r50.0<1;0>:f      r90.5<0>:f      
        mad (16|M0)              acc2.0<1>:f   r52.0<1;0>:f      acc2.0<1;0>:f     r91.2<0>:f       {Compacted,F@4}
        mad (16|M0)              r72.0<1>:f    r60.0<1;0>:f      r68.0<1;0>:f      r91.1<0>:f       {Compacted,F@3}
        mad (16|M0)              r62.0<1>:f    r44.0<1;0>:f      r58.0<1;0>:f      r91.1<0>:f       {Compacted,F@3}
        mad (16|M0)              acc0.0<1>:f   r72.0<1;0>:f      acc2.0<1;0>:f     r90.2<0>:f       {Compacted,F@2}
        mad (16|M0)              acc0.0<1>:f   r62.0<1;0>:f      acc0.0<1;0>:f     r90.2<0>:f       {Compacted,F@2}
        mul (16|M0)              acc0.0<1>:f   r90.4<0;1,0>:f    acc0.0<1;1,0>:f 
        rndd (16|M0)             r2.0<1>:f     acc0.0<1;1,0>:f                  {Compacted}
        mad (16|M0)              acc0.0<1>:f   acc2.0<1;0>:f     -r2.0<1;0>:f      r106.5<0>:f      {F@1}
        mul (16|M0)              acc2.0<1>:f   acc0.0<1;1,0>:f   0x2F800000:f               {Compacted}
        rndz (16|M0)             acc2.0<1>:f   acc2.0<1;1,0>:f                 
        mov (16|M0)              r74.0<1>:d    r14.0<1;1,0>:f                   {Compacted}
        mad (16|M0)              r12.0<1>:f    r72.0<1;0>:f      -r2.0<1;0>:f      r106.4<0>:f      {Compacted}
        mad (16|M0)              r34.0<1>:f    acc0.0<1;0>:f     acc2.0<1;0>:f     r91.0<0>:f      
        mad (16|M0)              r14.0<1>:f    r62.0<1;0>:f      -r2.0<1;0>:f      r90.1<0>:f       {Compacted,I@1}
        mov (16|M0)              r18.0<1>:d    r12.0<1;1,0>:f                   {Compacted,F@3}
        mov (16|M0)              r36.0<1>:ud   r34.0<1;1,0>:f                   {F@2}
        mov (16|M0)              r20.0<1>:d    r14.0<1;1,0>:f                   {Compacted,F@1}
        asr (16|M0)              r22.0<1>:d    r18.0<1;1,0>:d    31:w               {Compacted,I@3}
        shl (16|M0)              r36.0<1>:d    r36.0<1;1,0>:d    8:w               {Compacted,I@3}
        asr (16|M0)              r28.0<1>:d    r20.0<1;1,0>:d    31:w               {Compacted,I@3}
        addc (8|M0)              r38.0<1>:ud   r20.0<1;1,0>:ud   0x0:ud              {AccWrEn,Compacted}
        shl (16|M0)              r24.0<1>:d    r18.0<1;1,0>:d    20:w               {Compacted}
        shl (16|M0)              r22.0<1>:d    r22.0<1;1,0>:d    20:w               {Compacted,I@5}
        add3 (8|M0)              r40.0<1>:ud   acc0.0<1;0>:ud    r36.0<1;0>:ud     r28.0<1>:ud      {I@4}
        shr (16|M0)              r18.0<1>:ud   r18.0<1;1,0>:ud   12:w              
        addc (8|M8)              r39.0<1>:ud   r21.0<1;1,0>:ud   0x0:ud              {AccWrEn}
        mov (16|M0)              r76.0<1>:d    r26.0<1;1,0>:f                   {Compacted}
        add3 (8|M8)              r41.0<1>:ud   acc0.0<1;0>:ud    r37.0<1;0>:ud     r29.0<1>:ud     
        or (16|M0)               r26.0<1>:d    r22.0<1;1,0>:d    r18.0<1;1,0>:d   {Compacted,I@4}
        addc (8|M0)              r42.0<1>:ud   r38.0<1;1,0>:ud   r24.0<1;1,0>:ud  {AccWrEn,Compacted}
(W)     mov (1|M0)               r56.0<1>:w    -1:w                              
        add3 (8|M0)              r44.0<1>:ud   acc0.0<1;0>:ud    r40.0<1;0>:ud     r26.0<1>:ud      {I@3}
        addc (8|M8)              r43.0<1>:ud   r39.0<1;1,0>:ud   r25.0<1;1,0>:ud  {AccWrEn}
        shl (16|M0)              r48.0<1>:d    r76.0<1;1,0>:d    20:w               {Compacted}
        cmp (16|M0)   (ge)f0.1   null<1>:d     r42.0<1;1,0>:ud   r5.0<0;1,0>:ud   {I@2}
        add3 (8|M8)              r45.0<1>:ud   acc0.0<1;0>:ud    r41.0<1;0>:ud     r27.0<1>:ud     
        mov (16|M0)              r78.0<1>:d    r50.0<1;1,0>:f                   {Compacted}
(f0.1)  cmp (16|M0)   (eq)f0.1   null<1>:d     r44.0<1;1,0>:d    r85.5<0;1,0>:d   {I@2}
        mov (16|M0)              r16.0<1>:d    r2.0<1;1,0>:f                    {Compacted}
(~f0.1) cmp (16|M0)   (gt)f0.1   null<1>:d     r44.0<1;1,0>:ud   r85.5<0;1,0>:ud 
        shl (16|M0)              r46.0<1>:d    r74.0<1;1,0>:d    8:w               {Compacted}
        addc (8|M0)              r52.0<1>:ud   r48.0<1;1,0>:ud   0x0:ud              {AccWrEn,Compacted}
        shr (16|M0)              r50.0<1>:ud   r76.0<1;1,0>:ud   12:w              
(f0.1)  sel (16|M0)              r57.0<1>:d    r56.0<0;1,0>:w    0:w              
        add3 (8|M0)              r54.0<1>:ud   acc0.0<1;0>:ud    r50.0<1;0>:ud     r46.0<1>:ud      {I@2}
        add3 (16|M0)             r59.0<1>:d    r16.0<1;0>:d      r78.0<1;0>:d      -r57.0<1>:d      {I@2}
        addc (8|M8)              r53.0<1>:ud   r49.0<1;1,0>:ud   0x0:ud              {AccWrEn}
        add3 (8|M8)              r55.0<1>:ud   acc0.0<1;0>:ud    r51.0<1;0>:ud     r47.0<1>:ud     
        addc (8|M0)              r100.0<1>:ud  r52.0<1;1,0>:ud   r59.0<1;1,0>:ud  {AccWrEn,Compacted,I@3}
        add (8|M0)               r102.0<1>:ud  acc0.0<1;1,0>:ud  r54.0<1;1,0>:ud 
        addc (8|M8)              r101.0<1>:ud  r53.0<1;1,0>:ud   r60.0<1;1,0>:ud  {AccWrEn,I@4}
        add (8|M8)               r103.0<1>:ud  acc0.0<1;1,0>:ud  r55.0<1;1,0>:ud  {I@4}
L2728:
        join (16|M0)                         L3904                                
L2744:
        shr (16|M0)              r2.0<1>:ud    r92.0<1;1,0>:ud   5:w              
        shl (16|M0)              r10.0<1>:d    r100.0<1;1,0>:d   7:w               {Compacted,I@4}
        bfn.0xEA (16|M0)         r104.0<1>:ud  r10.0<1;0>:ud     r2.0<1;0>:ud      r90.7<0>:ud      {I@1} // s0|s1&s2
        cmp (16|M0)   (lt)f0.1   null<1>:d     r104.0<1;1,0>:d   r6.0<0;1,0>:d    {I@1}
(f0.1)  goto (16|M0)                         L2864                  L2864                
L2816:
(W)     mov (1|M0)               r2.0<2>:b     0:w                              
        mov (16|M0)              r106.0<1>:b   r2.0<0;1,0>:b                    {I@1}
        goto (16|M0)                         L2864                  L3600                
L2864:
        join (16|M0)                         L3600                                
L2880:
        mul (8|M0)               acc0.0<1>:ud  r100.0<1;1,0>:ud  r5.0<0;1,0>:uw  
        mach (8|M0)              r10.0<1>:ud   r100.0<1;1,0>:ud  r5.0<0;1,0>:ud   {AccWrEn,Compacted}
        and (16|M0)              r2.0<1>:d     r92.0<1;1,0>:d    31:w               {Compacted}
        mov (8|M0)               r12.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mul (8|M8)               acc0.0<1>:ud  r101.0<1;1,0>:ud  r5.0<0;1,0>:uw  
        mach (8|M8)              r11.0<1>:ud   r101.0<1;1,0>:ud  r5.0<0;1,0>:ud   {AccWrEn}
        mov (8|M8)               r13.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
(W)     mul (8|M0)               acc0.0<1>:d   r100.0<1;1,0>:ud  r85.10<0;1,0>:uw
        mach (8|M0)              r16.0<1>:d    r100.0<1;1,0>:ud  r85.5<0;1,0>:d  
(W)     mul (8|M8)               acc0.0<1>:d   r101.0<1;1,0>:ud  r85.10<0;1,0>:uw
        mach (8|M8)              r17.0<1>:d    r101.0<1;1,0>:ud  r85.5<0;1,0>:d  
(W)     mul (8|M0)               acc0.0<1>:d   r5.0<0;1,0>:ud    r102.0<2;1,0>:uw
        add (16|M0)              r18.0<1>:d    r10.0<1;1,0>:d    r16.0<1;1,0>:d   {Compacted,I@2}
        mach (8|M0)              r16.0<1>:d    r5.0<0;1,0>:ud    r102.0<1;1,0>:d 
(W)     mul (8|M8)               acc0.0<1>:d   r5.0<0;1,0>:ud    r103.0<2;1,0>:uw
        mov (16|M0)              r14.0<1>:f    r12.0<1;1,0>:f                   {Compacted}
        mach (8|M8)              r17.0<1>:d    r5.0<0;1,0>:ud    r103.0<1;1,0>:d 
        subb (8|M0)              r22.0<1>:ud   r98.0<1;1,0>:ud   r14.0<1;1,0>:ud  {AccWrEn,Compacted,F@1}
        add (16|M0)              r20.0<1>:d    r18.0<1;1,0>:d    r16.0<1;1,0>:d   {Compacted,I@2}
        add3 (8|M0)              r24.0<1>:ud   -acc0.0<1;0>:ud   r96.0<1;0>:ud     -r20.0<1>:ud     {I@1}
        subb (8|M8)              r23.0<1>:ud   r99.0<1;1,0>:ud   r15.0<1;1,0>:ud  {AccWrEn}
        add3 (8|M8)              r25.0<1>:ud   -acc0.0<1;0>:ud   r97.0<1;0>:ud     -r21.0<1>:ud    
        mul (8|M0)               acc0.0<1>:ud  r104.0<1;1,0>:ud  r8.0<0;1,0>:uw  
        mach (8|M0)              r26.0<1>:ud   r104.0<1;1,0>:ud  r8.0<0;1,0>:ud   {AccWrEn,Compacted}
        shl (16|M0)              r38.0<1>:d    r22.0<1;1,0>:d    5:w               {Compacted,I@4}
        mov (8|M0)               r28.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mul (8|M8)               acc0.0<1>:ud  r105.0<1;1,0>:ud  r8.0<0;1,0>:uw  
        mach (8|M8)              r27.0<1>:ud   r105.0<1;1,0>:ud  r8.0<0;1,0>:ud   {AccWrEn}
        shr (16|M0)              r40.0<1>:ud   r22.0<1;1,0>:ud   27:w              
        mov (8|M8)               r29.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
(W)     mul (8|M0)               acc0.0<1>:d   r104.0<1;1,0>:ud  r85.12<0;1,0>:uw
        mach (8|M0)              r32.0<1>:d    r104.0<1;1,0>:ud  r85.6<0;1,0>:d  
(W)     mul (8|M8)               acc0.0<1>:d   r105.0<1;1,0>:ud  r85.12<0;1,0>:uw
        mach (8|M8)              r33.0<1>:d    r105.0<1;1,0>:ud  r85.6<0;1,0>:d  
        mov (16|M0)              r30.0<1>:f    r28.0<1;1,0>:f                   {Compacted,A@5}
        add (16|M0)              r34.0<1>:d    r26.0<1;1,0>:d    r32.0<1;1,0>:d   {Compacted,I@1}
        addc (8|M0)              r44.0<1>:ud   r90.0<0;1,0>:ud   r30.0<1;1,0>:ud  {AccWrEn,Compacted,F@1}
        mov (16|M0)              r36.0<1>:f    r34.0<1;1,0>:f                   {Compacted,I@2}
        shl (16|M0)              r42.0<1>:d    r24.0<1;1,0>:d    5:w               {Compacted}
        add3 (8|M0)              r46.0<1>:ud   acc0.0<1;0>:ud    r85.2<0;0>:ud     r36.0<1>:ud      {F@1}
        addc (8|M8)              r45.0<1>:ud   r90.0<0;1,0>:ud   r31.0<1;1,0>:ud  {AccWrEn}
        or (16|M0)               r42.0<1>:d    r42.0<1;1,0>:d    r40.0<1;1,0>:d   {Compacted,I@3}
        add3 (8|M8)              r47.0<1>:ud   acc0.0<1;0>:ud    r85.2<0;0>:ud     r37.0<1>:ud     
        addc (8|M0)              r48.0<1>:ud   r44.0<1;1,0>:ud   r38.0<1;1,0>:ud  {AccWrEn,Compacted}
        add3 (8|M0)              r50.0<1>:ud   acc0.0<1;0>:ud    r46.0<1;0>:ud     r42.0<1>:ud      {I@3}
        addc (8|M8)              r49.0<1>:ud   r45.0<1;1,0>:ud   r39.0<1;1,0>:ud  {AccWrEn}
        add3 (8|M8)              r51.0<1>:ud   acc0.0<1;0>:ud    r47.0<1;0>:ud     r43.0<1>:ud      {I@4}
        addc (8|M0)              r52.0<1>:ud   r48.0<1;1,0>:ud   r2.0<1;1,0>:ud   {AccWrEn,Compacted,I@4}
        mov (8|M0)               r54.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        addc (8|M8)              r53.0<1>:ud   r49.0<1;1,0>:ud   r3.0<1;1,0>:ud   {AccWrEn,I@4}
        add (8|M0)               r55.1<2>:ud   r54.0<1;1,0>:ud   r50.0<1;1,0>:ud  {Compacted,I@2}
        mov (8|M8)               r59.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mov (8|M0)               r55.0<2>:d    r52.0<1;1,0>:d                  
        add (8|M8)               r57.1<2>:ud   r59.0<1;1,0>:ud   r51.0<1;1,0>:ud  {Compacted,I@2}
        mov (8|M8)               r57.0<2>:d    r53.0<1;1,0>:d                  
        send.ugm (16|M0)         r60      r55     null:0  0x0            0x08280980           {A@1,$7} // wr:4+0, rd:2; load.ugm.d8u32.a64.ca.ca
        mov (16|M0)              r106.0<1>:b   r60.0<4;1,0>:b                   {$7.dst}
L3600:
        join (16|M0)                         L3904                                
L3616:
        addc (8|M0)              r2.0<1>:ud    r92.0<1;1,0>:ud   r85.3<0;1,0>:ud  {AccWrEn,Compacted}
        mov (16|M0)              r16.0<1>:ud   r106.0<1;1,0>:ub                 {I@3}
        mov (8|M0)               r10.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        addc (8|M8)              r3.0<1>:ud    r93.0<1;1,0>:ud   r85.3<0;1,0>:ud  {AccWrEn}
        add3 (8|M0)              r11.1<2>:ud   r10.0<1;0>:ud     r94.0<1;0>:ud     r85.4<0>:ud      {I@2}
        mov (8|M8)               r15.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        addc (8|M0)              r107.0<1>:ud  r92.0<1;1,0>:ud   r9.0<0;1,0>:ud   {AccWrEn,Compacted}
        mov (8|M0)               r11.0<2>:d    r2.0<1;1,0>:d                   
        add (8|M0)               r109.0<1>:ud  acc0.0<1;1,0>:ud  r94.0<1;1,0>:ud 
        addc (8|M8)              r108.0<1>:ud  r93.0<1;1,0>:ud   r9.0<0;1,0>:ud   {AccWrEn}
        add3 (8|M8)              r13.1<2>:ud   r15.0<1;0>:ud     r95.0<1;0>:ud     r85.4<0>:ud      {I@5}
        cmp (16|M0)   (lt)f1.1   null<1>:d     r107.0<1;1,0>:ud  r85.0<0;1,0>:ud  {I@2}
        add (8|M8)               r110.0<1>:ud  acc0.0<1;1,0>:ud  r95.0<1;1,0>:ud 
        mov (8|M8)               r13.0<2>:d    r3.0<1;1,0>:d                   
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r109.0<1;1,0>:d   r85.1<0;1,0>:d   {I@2}
        send.ugm (16|M0)         null     r11     r16:2   0x0            0x080E0984           {A@2,$5} // wr:4+2, rd:0; store.ugm.d8u32.a64.wb.wb
(~f1.1) cmp (16|M0)   (lt)f1.1   null<1>:d     r109.0<1;1,0>:ud  r85.1<0;1,0>:ud 
(~f1.1) goto (16|M0)                         L3904                  L3904                
L3872:
(f1.1)  sel (16|M0)              r92.0<1>:d    r107.0<1;1,0>:d   r86.0<1;1,0>:d   {Compacted}
(f1.1)  sel (16|M0)              r94.0<1>:d    r109.0<1;1,0>:d   r88.0<1;1,0>:d   {Compacted}
(W)     jmpi                                 L1184                                
L3904:
        join (16|M0)                         L3920                                
L3920:
(W)     mov (8|M0)               r127.0<1>:f   r84.0<1;1,0>:f                   {Compacted,$3.src}
(W)     send.gtwy (1|M0)         null     r127    null:0  0x0            0x02000010           {EOT,A@1} // wr:1+0, rd:0; end of thread
L3944:
        nop                    
(W)     mov (16|M0)              null<1>:ud    0x6F9278B:ud                             
(W)     mov (16|M0)              null<1>:ud    0x6180031B:ud                             
(W)     mov (16|M0)              null<1>:ud    0x0:ud                             
(W)     mov (16|M0)              null<1>:ud    0x13:ud                             
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
