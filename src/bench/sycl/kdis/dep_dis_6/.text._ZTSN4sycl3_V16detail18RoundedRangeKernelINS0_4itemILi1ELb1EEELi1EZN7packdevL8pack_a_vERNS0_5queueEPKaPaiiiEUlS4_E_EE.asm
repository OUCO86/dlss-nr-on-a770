L0:
(W)     mov (8|M0)               r127.0<1>:ud  0x0:ud                             
(W)     and (1|M0)               r127.2<1>:ud  r0.0<0;1,0>:ud    0xFFFFFFC0:ud             
(W)     and (1|M0)               r127.0<1>:uw  r0.4<0;1,0>:uw    0xFF:uw             
(W)     add (1|M0)               r127.2<1>:ud  r127.2<0;1,0>:ud  0x60:ud              {I@2}
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
(W)     send.dc0 (8|M0)          r5       r127    null:0  0x0            0x022843FD           {A@1,$2} // wr:1h+0, rd:2; oword aligned block read x4
(W)     add (1|M0)               r127.2<1>:ud  r127.2<0;1,0>:ud  0x40:uw              {$2.src}
(W)     send.dc0 (8|M0)          r7       r127    null:0  0x0            0x021842FD           {A@1,$3} // wr:1h+0, rd:1; oword aligned block read x2
(W)     mov (8|M0)               r46.0<1>:ud   r0.0<1;1,0>:ud                  
(W)     or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x4C0:uw              {A@1}
(W)     mul (1|M0)               acc0.0<1>:ud  r4.3<0;1,0>:ud    r46.2<0;1,0>:uw  {A@1}
(W)     mach (1|M0)              r3.0<1>:ud    r4.3<0;1,0>:ud    r46.1<0;1,0>:ud  {AccWrEn,$1.dst}
        mov (16|M0)              r8.0<1>:d     r1.0<1;1,0>:uw                   {$0.dst}
(W)     mov (1|M0)               r2.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
(W)     mov (2|M0)               r47.0<1>:d    r4.6<1;1,0>:d                   
        addc (8|M0)              r10.0<1>:ud   r2.0<0;1,0>:ud    r8.0<1;1,0>:ud   {AccWrEn,Compacted,I@2}
        add (8|M0)               r12.0<1>:ud   acc0.0<1;1,0>:ud  r3.0<0;1,0>:ud  
        addc (8|M8)              r11.0<1>:ud   r2.0<0;1,0>:ud    r9.0<1;1,0>:ud   {AccWrEn}
        add (8|M8)               r13.0<1>:ud   acc0.0<1;1,0>:ud  r3.0<0;1,0>:ud  
        addc (8|M0)              r48.0<1>:ud   r10.0<1;1,0>:ud   r4.0<0;1,0>:ud   {AccWrEn,Compacted,I@4}
        add (8|M0)               r50.0<1>:ud   acc0.0<1;1,0>:ud  r12.0<1;1,0>:ud  {I@4}
        addc (8|M8)              r49.0<1>:ud   r11.0<1;1,0>:ud   r4.0<0;1,0>:ud   {AccWrEn,I@4}
        cmp (16|M0)   (lt)f1.0   null<1>:d     r48.0<1;1,0>:ud   r47.0<0;1,0>:ud  {I@1}
        add (8|M8)               r51.0<1>:ud   acc0.0<1;1,0>:ud  r13.0<1;1,0>:ud 
(f1.0)  cmp (16|M0)   (eq)f1.0   null<1>:d     r50.0<1;1,0>:d    r47.1<0;1,0>:d   {I@1}
(~f1.0) cmp (16|M0)   (lt)f1.0   null<1>:d     r50.0<1;1,0>:ud   r47.1<0;1,0>:ud 
(~f1.0) goto (16|M0)                         L3832                  L3832                
L568:
(W)     shr (1|M0)               r2.0<1>:ud    r5.0<0;1,0>:ud    20:w               {$2.dst}
(W)     asr (1|M0)               r2.1<1>:d     r5.0<0;1,0>:d     20:w               {Compacted}
(W)     mov (1|M0)               r52.0<1>:d    1044480:d                              
(W)     asr (1|M0)               r47.6<1>:d    r5.0<0;1,0>:d     31:w               {Compacted}
(W)     and (1|M0)               r5.5<1>:d     r5.0<0;1,0>:d     1048575:d              
(W)     bfn.0xF8 (1|M0)          r3.0<1>:ud    r2.1<0;0>:ud      r52.0<0;0>:ud     r2.0<0>:ud       {I@3} // s0&s1|s2
(W)     mov (1|M0)               r52.2<1>:f    1.048576e+06:f                               {Compacted}
(W)     shr (1|M0)               r2.2<1>:ud    r47.6<0;1,0>:ud   8:w               {I@3}
(W)     mov (1|M0)               r52.1<1>:f    r5.5<0;1,0>:ud                   {I@3}
(W)     mov (1|M0)               r54.4<1>:f    r3.0<0;1,0>:ud                   {Compacted,I@2}
(W)     mov (1|M0)               r52.3<1>:f    0x53800000:f                               {Compacted}
(W)     mov (1|M0)               r54.5<1>:f    r2.2<0;1,0>:ud                   {I@1}
(W)     mad (1|M0)               r6.0<1>:f     r52.1<0;0>:f      r52.2<0;0>:f      r54.4<0>:f       {F@3}
(W)     mov (1|M0)               r8.1<1>:f     -4.172325e-07:f                               {Compacted}
        sync.nop                             null                             {Compacted,$3.dst}
(W)     mad (1|M0)               r7.3<1>:f     r6.0<0;0>:f       r52.3<0;0>:f      r54.5<0>:f       {F@2}
(W)     cmp (16|M0)   (eq)f0.0   null<1>:d     r5.0<0;1,0>:d     0:w               {Compacted}
        sync.nop                             null                             {Compacted,F@1}
(W)     math.inv (1|M0)          r8.0<1>:f     r7.3<0;1,0>:f                    {$4}
        mov (16|M0)              r56.0<1>:d    r48.0<1;1,0>:d                  
        mov (16|M0)              r58.0<1>:d    r50.0<1;1,0>:d                  
(W)     mov (2|M0)               r47.2<1>:d    r5.2<1;1,0>:d                   
(W)     mov (2|M0)               r47.4<1>:d    r6.2<1;1,0>:d                   
(W)     asr (1|M0)               r47.7<1>:d    r5.4<0;1,0>:d     31:w              
(W)     mov (2|M0)               r54.0<1>:ud   r6.4<1;1,0>:ud                  
(W)     mov (1|M0)               r52.7<1>:d    127:w                              
(W)     mov (1|M0)               r53.0<1>:f    0xCF800000:f                               {Compacted}
(W)     mov (1|M0)               r53.1<1>:f    -1.048576e+06:f                               {Compacted}
(W)     mov (1|M0)               r53.2<1>:f    -1.0:f                               {Compacted}
(W)     mul (1|M0)               r52.5<1>:f    r52.1<0;1,0>:f    9.536743e-07:f              
(W)     mul (1|M0)               r53.4<1>:f    r54.4<0;1,0>:f    -1.048576e+06:f              
(W)     mul (1|M0)               r52.6<1>:f    r54.4<0;1,0>:f    9.536743e-07:f              
(W)     mul (1|M0)               r53.5<1>:f    r54.5<0;1,0>:f    -1.048576e+06:f              
(W)     mad (1|M0)               r52.4<1>:f    r8.0<0;0>:f       r8.1<0;0>:f       r8.0<0>:f        {$4.dst}
L1016:
        shr (16|M0)              r64.0<1>:ud   r58.0<1;1,0>:ud   8:w               {I@6}
        or (16|M0)               r14.0<1>:d    r64.0<1;1,0>:d    r47.6<0;1,0>:d   {Compacted,I@1}
        cmp (16|M0)   (lt)f1.0   null<1>:d     r14.0<1;1,0>:ud   0x1:uw              {I@1}
        shr (16|M0)              r2.0<1>:ud    r56.0<1;1,0>:ud   28:w              
        sync.nop                             null                             {Compacted,$5.src}
        shl (16|M0)              r8.0<1>:d     r58.0<1;1,0>:d    4:w               {Compacted,F@1}
        shl (16|M0)              r10.0<1>:d    r58.0<1;1,0>:d    24:w               {Compacted}
        shr (16|M0)              r12.0<1>:ud   r56.0<1;1,0>:ud   8:w              
        shl (16|M0)              r60.0<1>:d    r56.0<1;1,0>:d    4:w               {Compacted}
        or (16|M0)               r62.0<1>:d    r8.0<1;1,0>:d     r2.0<1;1,0>:d    {Compacted,I@4}
        or (16|M0)               r66.0<1>:d    r12.0<1;1,0>:d    r10.0<1;1,0>:d   {Compacted,I@3}
(~f1.0) goto (16|M0)                         L1608                  L1608                
L1152:
(~f0.0) goto (16|M0)                         L1200                  L1200                
L1168:
        mov (16|M0)              r68.0<1>:d    -1:w                              
        goto (16|M0)                         L1200                  L1560                
L1200:
        join (16|M0)                         L1560                                
L1216:
(W)     xor (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x30:uw              {A@1}
(W)     mov (1|M0)               r2.0<1>:f     r5.0<0;1,0>:ud                   {Compacted,A@1}
(W)     mov (1|M0)               r3.2<1>:f     0xB4C00000:f                               {Compacted}
(W)     math.inv (1|M0)          r3.1<1>:f     r2.0<0;1,0>:f                    {@2,$6}
        mov (16|M0)              r8.0<1>:f     r66.0<1;1,0>:ud                  {Compacted,I@7}
        sync.nop                             null                             {Compacted,$6.dst}
(W)     mad (1|M0)               r5.5<1>:f     r3.1<0;0>:f       r3.2<0;0>:f       r3.1<0>:f        {F@2}
(W)     mov (1|M0)               r2.1<1>:ud    r2.0<0;1,0>:f                   
        mov (16|M0)              r12.0<1>:ud   r8.0<1;1,0>:f                    {F@2}
        mul (16|M0)              r10.0<1>:f    r8.0<1;1,0>:f     r5.5<0;1,0>:f    {Compacted,F@1}
(W)     add (1|M0)               r3.0<1>:d     r5.0<0;1,0>:d     -r2.1<0;1,0>:d   {Compacted,I@2}
        add (16|M0)              r12.0<1>:d    r66.0<1;1,0>:d    -r12.0<1;1,0>:d  {Compacted,I@2}
        mov (16|M0)              r14.0<1>:ud   r10.0<1;1,0>:f                   {F@1}
(W)     mov (1|M0)               r5.6<1>:f     r3.0<0;1,0>:ud                   {Compacted,I@3}
        mov (16|M0)              r16.0<1>:f    r12.0<1;1,0>:ud                  {Compacted,I@2}
        mov (16|M0)              r18.0<1>:f    r14.0<1;1,0>:ud                  {Compacted,I@1}
        mad (16|M0)              acc0.0<1>:f   r8.0<1;0>:f       r18.0<1;0>:f      -r2.0<0>:f       {Compacted,F@1}
        mad (16|M0)              acc2.0<1>:f   r16.0<1;0>:f      r18.0<1;0>:f      -r5.6<0>:f       {Compacted}
        add (16|M0)              acc0.0<1>:f   acc0.0<1;1,0>:f   acc2.0<1;1,0>:f 
        mul (16|M0)              r26.0<1>:f    r5.5<0;1,0>:f     acc0.0<1;1,0>:f 
(W)     xor (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x30:uw              {A@1}
        mov (16|M0)              r28.0<1>:ud   r26.0<1;1,0>:f                   {A@1}
        add (16|M0)              r30.0<1>:d    r28.0<1;1,0>:d    r14.0<1;1,0>:d   {Compacted,I@1}
(W)     mul (8|M0)               acc0.0<1>:d   r30.0<1;1,0>:d    r5.0<0;1,0>:uw   {Compacted,I@1}
        mach (8|M0)              r30.0<1>:d    r30.0<1;1,0>:d    r5.0<0;1,0>:d    {Compacted}
(W)     mul (8|M8)               acc0.0<1>:d   r31.0<1;1,0>:d    r5.0<0;1,0>:uw  
        mach (8|M8)              r31.0<1>:d    r31.0<1;1,0>:d    r5.0<0;1,0>:d    {Compacted}
        add (16|M0)              r30.0<1>:d    r66.0<1;1,0>:d    -r30.0<1;1,0>:d  {Compacted,I@1}
        cmp (16|M0)   (ge)f1.1   r8.0<1>:ud    r30.0<1;1,0>:ud   r5.0<0;1,0>:ud   {I@1}
        add3 (16|M0)             r68.0<1>:d    r28.0<1;0>:d      r14.0<1;0>:d      -r8.0<1>:d       {I@1}
L1560:
        join (16|M0)                         L1608                                
L1576:
        mov (16|M0)              r70.0<1>:d    0:w                              
        goto (16|M0)                         L1608                  L2640                
L1608:
        join (16|M0)                         L2640                                
L1624:
        shr (16|M0)              r2.0<1>:ud    r58.0<1;1,0>:ud   16:w              
        mov (16|M0)              r8.0<1>:f     r2.0<1;1,0>:ud                   {Compacted,I@1}
        shl (16|M0)              r20.0<1>:d    r58.0<1;1,0>:d    4:w               {Compacted}
        shr (16|M0)              r22.0<1>:ud   r56.0<1;1,0>:ud   28:w              
        mul (16|M0)              acc0.0<1>:f   r52.4<0;1,0>:f    r8.0<1;1,0>:f    {Compacted,F@1}
        shr (16|M0)              r18.0<1>:ud   r66.0<1;1,0>:ud   20:w              
        or (16|M0)               r22.0<1>:d    r22.0<1;1,0>:d    r20.0<1;1,0>:d   {Compacted,I@2}
        rndd (16|M0)             r12.0<1>:f    acc0.0<1;1,0>:f                  {Compacted}
        bfn.0xF8 (16|M0)         r18.0<1>:ud   r22.0<1;0>:ud     r52.0<0;0>:ud     r18.0<1>:ud      {I@1} // s0&s1|s2
        mad (16|M0)              acc0.0<1>:f   r8.0<1;0>:f       r12.0<1;0>:f      -r52.1<0>:f      {Compacted,F@1}
        mov (16|M0)              r24.0<1>:f    r18.0<1;1,0>:ud                  {Compacted,I@1}
        mad (16|M0)              acc0.0<1>:f   acc0.0<1;0>:f     r12.0<1;0>:f      r53.4<0>:f       {Compacted}
        mad (16|M0)              acc2.0<1>:f   r24.0<1;0>:f      acc0.0<1;0>:f     r52.2<0>:f       {Compacted,F@2}
        mul (16|M0)              acc2.0<1>:f   r52.4<0;1,0>:f    acc2.0<1;1,0>:f 
        rndd (16|M0)             r2.0<1>:f     acc2.0<1;1,0>:f                  {Compacted}
        mul (16|M0)              acc2.0<1>:f   r52.5<0;1,0>:f    r2.0<1;1,0>:f    {Compacted,F@1}
        rndd (16|M0)             acc2.0<1>:f   acc2.0<1;1,0>:f                 
        and (16|M0)              r22.0<1>:d    r66.0<1;1,0>:d    1048575:d              
        mad (16|M0)              acc0.0<1>:f   acc0.0<1;0>:f     r2.0<1;0>:f       -r54.4<0>:f     
        mad (16|M0)              r30.0<1>:f    -acc2.0<1;0>:f    r2.0<1;0>:f       r52.5<0>:f      
        mov (16|M0)              r18.0<1>:f    r22.0<1;1,0>:ud                  {Compacted,I@1}
        mad (16|M0)              r8.0<1>:f     acc0.0<1;0>:f     r2.0<1;0>:f       r53.5<0>:f       {Compacted}
        mad (16|M0)              r20.0<1>:f    r24.0<1;0>:f      r30.0<1;0>:f      r53.1<0>:f       {Compacted,F@3}
        mad (16|M0)              r32.0<1>:f    r8.0<1;0>:f       acc2.0<1;0>:f     r53.2<0>:f       {Compacted,F@2}
        mad (16|M0)              acc0.0<1>:f   r18.0<1;0>:f      r20.0<1;0>:f      r52.2<0>:f       {Compacted,F@2}
        mad (16|M0)              acc0.0<1>:f   acc0.0<1;0>:f     r32.0<1;0>:f      r52.3<0>:f       {Compacted,F@2}
        mul (16|M0)              acc0.0<1>:f   r52.4<0;1,0>:f    acc0.0<1;1,0>:f 
        rndd (16|M0)             r16.0<1>:f    acc0.0<1;1,0>:f                  {Compacted}
        mul (16|M0)              acc0.0<1>:f   r52.5<0;1,0>:f    r16.0<1;1,0>:f   {Compacted,F@1}
        mul (16|M0)              acc2.0<1>:f   r52.6<0;1,0>:f    r16.0<1;1,0>:f   {Compacted}
        rndd (16|M0)             acc0.0<1>:f   acc0.0<1;1,0>:f                 
        rndd (16|M0)             acc2.0<1>:f   acc2.0<1;1,0>:f                 
        mad (16|M0)              r10.0<1>:f    r32.0<1;0>:f      r16.0<1;0>:f      -r54.5<0>:f      {Compacted}
        mad (16|M0)              r8.0<1>:f     r20.0<1;0>:f      acc0.0<1;0>:f     r53.2<0>:f       {Compacted}
        mad (16|M0)              r30.0<1>:f    -acc2.0<1;0>:f    r16.0<1;0>:f      r52.6<0>:f      
        mad (16|M0)              r38.0<1>:f    -acc0.0<1;0>:f    r16.0<1;0>:f      r52.5<0>:f      
        mad (16|M0)              acc2.0<1>:f   r10.0<1;0>:f      acc2.0<1;0>:f     r53.2<0>:f       {Compacted,F@4}
        mad (16|M0)              r40.0<1>:f    r8.0<1;0>:f       r30.0<1;0>:f      r53.1<0>:f       {Compacted,F@3}
        mad (16|M0)              r24.0<1>:f    r18.0<1;0>:f      r38.0<1;0>:f      r53.1<0>:f       {Compacted,F@3}
        mad (16|M0)              acc0.0<1>:f   r40.0<1;0>:f      acc2.0<1;0>:f     r52.2<0>:f       {Compacted,F@2}
        mad (16|M0)              acc0.0<1>:f   r24.0<1;0>:f      acc0.0<1;0>:f     r52.2<0>:f       {Compacted,F@2}
        mul (16|M0)              acc0.0<1>:f   r52.4<0;1,0>:f    acc0.0<1;1,0>:f 
        rndd (16|M0)             r14.0<1>:f    acc0.0<1;1,0>:f                  {Compacted}
        mad (16|M0)              acc0.0<1>:f   acc2.0<1;0>:f     -r14.0<1;0>:f     r54.5<0>:f       {F@1}
        mul (16|M0)              acc2.0<1>:f   acc0.0<1;1,0>:f   0x2F800000:f               {Compacted}
        rndz (16|M0)             acc2.0<1>:f   acc2.0<1;1,0>:f                 
        mad (16|M0)              r20.0<1>:f    r40.0<1;0>:f      -r14.0<1;0>:f     r54.4<0>:f       {Compacted}
        mad (16|M0)              r28.0<1>:f    r24.0<1;0>:f      -r14.0<1;0>:f     r52.1<0>:f       {Compacted}
        mad (16|M0)              r24.0<1>:f    acc0.0<1;0>:f     acc2.0<1;0>:f     r53.0<0>:f      
        mov (16|M0)              r36.0<1>:d    r12.0<1;1,0>:f                   {Compacted}
        mov (16|M0)              r10.0<1>:d    r14.0<1;1,0>:f                   {Compacted}
        mov (16|M0)              r8.0<1>:d     r20.0<1;1,0>:f                   {Compacted,F@3}
        mov (16|M0)              r12.0<1>:d    r28.0<1;1,0>:f                   {Compacted,F@2}
        mov (16|M0)              r14.0<1>:ud   r24.0<1;1,0>:f                   {F@1}
        mov (16|M0)              r32.0<1>:d    r2.0<1;1,0>:f                    {Compacted}
        asr (16|M0)              r26.0<1>:d    r12.0<1;1,0>:d    31:w               {Compacted,I@3}
        addc (8|M0)              r20.0<1>:ud   r12.0<1;1,0>:ud   0x0:ud              {AccWrEn,Compacted}
        shl (16|M0)              r14.0<1>:d    r14.0<1;1,0>:d    8:w               {Compacted,I@4}
        asr (16|M0)              r2.0<1>:d     r8.0<1;1,0>:d     31:w               {Compacted}
        mov (16|M0)              r42.0<1>:d    r16.0<1;1,0>:f                   {Compacted}
        add3 (8|M0)              r28.0<1>:ud   acc0.0<1;0>:ud    r14.0<1;0>:ud     r26.0<1>:ud      {I@3}
        shl (16|M0)              r2.0<1>:d     r2.0<1;1,0>:d     20:w               {Compacted,I@3}
        shl (16|M0)              r16.0<1>:d    r8.0<1;1,0>:d     20:w               {Compacted}
        addc (8|M8)              r21.0<1>:ud   r13.0<1;1,0>:ud   0x0:ud              {AccWrEn}
        shr (16|M0)              r8.0<1>:ud    r8.0<1;1,0>:ud    12:w              
        add3 (8|M8)              r29.0<1>:ud   acc0.0<1;0>:ud    r15.0<1;0>:ud     r27.0<1>:ud     
        or (16|M0)               r22.0<1>:d    r2.0<1;1,0>:d     r8.0<1;1,0>:d    {Compacted,I@2}
        addc (8|M0)              r38.0<1>:ud   r20.0<1;1,0>:ud   r16.0<1;1,0>:ud  {AccWrEn,Compacted}
(W)     mov (1|M0)               r5.10<1>:w    -1:w                              
        add3 (8|M0)              r2.0<1>:ud    acc0.0<1;0>:ud    r28.0<1;0>:ud     r22.0<1>:ud      {I@3}
        addc (8|M8)              r39.0<1>:ud   r21.0<1;1,0>:ud   r17.0<1;1,0>:ud  {AccWrEn}
        shl (16|M0)              r18.0<1>:d    r32.0<1;1,0>:d    20:w               {Compacted}
        cmp (16|M0)   (ge)f0.1   null<1>:d     r38.0<1;1,0>:ud   r5.0<0;1,0>:ud   {I@2}
        add3 (8|M8)              r3.0<1>:ud    acc0.0<1;0>:ud    r29.0<1;0>:ud     r23.0<1>:ud     
        shr (16|M0)              r24.0<1>:ud   r32.0<1;1,0>:ud   12:w              
(f0.1)  cmp (16|M0)   (eq)f0.1   null<1>:d     r2.0<1;1,0>:d     r47.6<0;1,0>:d   {I@2}
        shl (16|M0)              r8.0<1>:d     r36.0<1;1,0>:d    8:w               {Compacted}
(~f0.1) cmp (16|M0)   (gt)f0.1   null<1>:d     r2.0<1;1,0>:ud    r47.6<0;1,0>:ud 
        addc (8|M0)              r30.0<1>:ud   r18.0<1;1,0>:ud   0x0:ud              {AccWrEn,Compacted}
(f0.1)  sel (16|M0)              r12.0<1>:d    r5.10<0;1,0>:w    0:w              
        add3 (8|M0)              r34.0<1>:ud   acc0.0<1;0>:ud    r24.0<1;0>:ud     r8.0<1>:ud       {I@4}
        add3 (16|M0)             r14.0<1>:d    r10.0<1;0>:d      r42.0<1;0>:d      -r12.0<1>:d      {I@2}
        addc (8|M8)              r31.0<1>:ud   r19.0<1;1,0>:ud   0x0:ud              {AccWrEn}
        add3 (8|M8)              r35.0<1>:ud   acc0.0<1;0>:ud    r25.0<1;0>:ud     r9.0<1>:ud      
        addc (8|M0)              r68.0<1>:ud   r30.0<1;1,0>:ud   r14.0<1;1,0>:ud  {AccWrEn,Compacted,I@3}
        add (8|M0)               r70.0<1>:ud   acc0.0<1;1,0>:ud  r34.0<1;1,0>:ud 
        addc (8|M8)              r69.0<1>:ud   r31.0<1;1,0>:ud   r15.0<1;1,0>:ud  {AccWrEn,I@4}
        add (8|M8)               r71.0<1>:ud   acc0.0<1;1,0>:ud  r35.0<1;1,0>:ud  {I@4}
L2640:
        join (16|M0)                         L3832                                
L2656:
        shr (16|M0)              r2.0<1>:ud    r60.0<1;1,0>:ud   5:w              
        shl (16|M0)              r8.0<1>:d     r68.0<1;1,0>:d    7:w               {Compacted,I@4}
        bfn.0xEA (16|M0)         r72.0<1>:ud   r8.0<1;0>:ud      r2.0<1;0>:ud      r52.7<0>:ud      {I@1} // s0|s1&s2
        cmp (16|M0)   (lt)f0.1   null<1>:d     r72.0<1;1,0>:d    r5.1<0;1,0>:d    {I@1}
(f0.1)  goto (16|M0)                         L2816                  L2816                
L2728:
(W)     send.ugm (1|M0)          r2       r54     null:0  0x0            0x0218B580           {$7} // wr:1+0, rd:1; load.ugm.d32x4t.a64.ca.ca
        mov (16|M0)              r74.0<1>:f    r2.0<0;1,0>:f                    {Compacted,$7.dst}
        mov (16|M0)              r76.0<1>:d    r2.1<0;1,0>:d                   
        mov (16|M0)              r78.0<1>:d    r2.2<0;1,0>:d                   
        mov (16|M0)              r80.0<1>:d    r2.3<0;1,0>:d                   
        goto (16|M0)                         L2816                  L3536                
L2816:
        join (16|M0)                         L3536                                
L2832:
        mul (8|M0)               acc0.0<1>:ud  r68.0<1;1,0>:ud   r5.0<0;1,0>:uw  
        mach (8|M0)              r2.0<1>:ud    r68.0<1;1,0>:ud   r5.0<0;1,0>:ud   {AccWrEn,Compacted,F@1}
        mov (8|M0)               r8.0<1>:ud    acc0.0<1;1,0>:ud                 {Compacted}
        mul (8|M8)               acc0.0<1>:ud  r69.0<1;1,0>:ud   r5.0<0;1,0>:uw  
        mach (8|M8)              r3.0<1>:ud    r69.0<1;1,0>:ud   r5.0<0;1,0>:ud   {AccWrEn}
        mov (8|M8)               r9.0<1>:ud    acc0.0<1;1,0>:ud                 {Compacted}
(W)     mul (8|M0)               acc0.0<1>:d   r68.0<1;1,0>:ud   r47.12<0;1,0>:uw
        mach (8|M0)              r12.0<1>:d    r68.0<1;1,0>:ud   r47.6<0;1,0>:d  
(W)     mul (8|M8)               acc0.0<1>:d   r69.0<1;1,0>:ud   r47.12<0;1,0>:uw
        mach (8|M8)              r13.0<1>:d    r69.0<1;1,0>:ud   r47.6<0;1,0>:d  
(W)     mul (8|M0)               acc0.0<1>:d   r5.0<0;1,0>:ud    r70.0<2;1,0>:uw 
        add (16|M0)              r14.0<1>:d    r2.0<1;1,0>:d     r12.0<1;1,0>:d   {Compacted,I@2}
        mach (8|M0)              r12.0<1>:d    r5.0<0;1,0>:ud    r70.0<1;1,0>:d  
(W)     mul (8|M8)               acc0.0<1>:d   r5.0<0;1,0>:ud    r71.0<2;1,0>:uw 
        mov (16|M0)              r10.0<1>:f    r8.0<1;1,0>:f                    {Compacted}
        mach (8|M8)              r13.0<1>:d    r5.0<0;1,0>:ud    r71.0<1;1,0>:d  
        subb (8|M0)              r18.0<1>:ud   r66.0<1;1,0>:ud   r10.0<1;1,0>:ud  {AccWrEn,Compacted,F@1}
        add (16|M0)              r16.0<1>:d    r14.0<1;1,0>:d    r12.0<1;1,0>:d   {Compacted,I@2}
        add3 (8|M0)              r8.0<1>:ud    -acc0.0<1;0>:ud   r64.0<1;0>:ud     -r16.0<1>:ud     {I@1}
        subb (8|M8)              r19.0<1>:ud   r67.0<1;1,0>:ud   r11.0<1;1,0>:ud  {AccWrEn}
        add3 (8|M8)              r9.0<1>:ud    -acc0.0<1;0>:ud   r65.0<1;0>:ud     -r17.0<1>:ud    
        mul (8|M0)               acc0.0<1>:ud  r72.0<1;1,0>:ud   r5.8<0;1,0>:uw  
        mach (8|M0)              r20.0<1>:ud   r72.0<1;1,0>:ud   r5.4<0;1,0>:ud   {AccWrEn,Compacted}
        shl (16|M0)              r26.0<1>:d    r18.0<1;1,0>:d    5:w               {Compacted,I@4}
        mov (8|M0)               r2.0<1>:ud    acc0.0<1;1,0>:ud                 {Compacted}
        mul (8|M8)               acc0.0<1>:ud  r73.0<1;1,0>:ud   r5.8<0;1,0>:uw  
        mach (8|M8)              r21.0<1>:ud   r73.0<1;1,0>:ud   r5.4<0;1,0>:ud   {AccWrEn}
        shl (16|M0)              r28.0<1>:d    r8.0<1;1,0>:d     5:w               {Compacted,I@7}
        mov (8|M8)               r3.0<1>:ud    acc0.0<1;1,0>:ud                 {Compacted}
(W)     mul (8|M0)               acc0.0<1>:d   r72.0<1;1,0>:ud   r47.14<0;1,0>:uw
        mach (8|M0)              r12.0<1>:d    r72.0<1;1,0>:ud   r47.7<0;1,0>:d  
(W)     mul (8|M8)               acc0.0<1>:d   r73.0<1;1,0>:ud   r47.14<0;1,0>:uw
        mach (8|M8)              r13.0<1>:d    r73.0<1;1,0>:ud   r47.7<0;1,0>:d  
        mov (16|M0)              r22.0<1>:f    r2.0<1;1,0>:f                    {Compacted,A@5}
        add (16|M0)              r10.0<1>:d    r20.0<1;1,0>:d    r12.0<1;1,0>:d   {Compacted,I@1}
        addc (8|M0)              r16.0<1>:ud   r22.0<1;1,0>:ud   r47.2<0;1,0>:ud  {AccWrEn,Compacted,F@1}
        mov (16|M0)              r14.0<1>:f    r10.0<1;1,0>:f                   {Compacted,I@2}
        shr (16|M0)              r2.0<1>:ud    r18.0<1;1,0>:ud   27:w              
        add3 (8|M0)              r24.0<1>:ud   acc0.0<1;0>:ud    r14.0<1;0>:ud     r47.3<0>:ud      {F@1}
        addc (8|M8)              r17.0<1>:ud   r23.0<1;1,0>:ud   r47.2<0;1,0>:ud  {AccWrEn}
        or (16|M0)               r28.0<1>:d    r28.0<1;1,0>:d    r2.0<1;1,0>:d    {Compacted,I@3}
        add3 (8|M8)              r25.0<1>:ud   acc0.0<1;0>:ud    r15.0<1;0>:ud     r47.3<0>:ud     
        addc (8|M0)              r30.0<1>:ud   r16.0<1;1,0>:ud   r26.0<1;1,0>:ud  {AccWrEn,Compacted}
        and (16|M0)              r10.0<1>:d    r60.0<1;1,0>:d    16:w               {Compacted}
        add3 (8|M0)              r32.0<1>:ud   acc0.0<1;0>:ud    r24.0<1;0>:ud     r28.0<1>:ud      {I@4}
        addc (8|M8)              r31.0<1>:ud   r17.0<1;1,0>:ud   r27.0<1;1,0>:ud  {AccWrEn}
        add3 (8|M8)              r33.0<1>:ud   acc0.0<1;0>:ud    r25.0<1;0>:ud     r29.0<1>:ud      {I@5}
        addc (8|M0)              r12.0<1>:ud   r30.0<1;1,0>:ud   r10.0<1;1,0>:ud  {AccWrEn,Compacted,I@4}
        mov (8|M0)               r20.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        addc (8|M8)              r13.0<1>:ud   r31.0<1;1,0>:ud   r11.0<1;1,0>:ud  {AccWrEn,I@4}
        add (8|M0)               r34.1<2>:ud   r20.0<1;1,0>:ud   r32.0<1;1,0>:ud  {Compacted,I@2}
        mov (8|M8)               r14.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        mov (8|M0)               r34.0<2>:d    r12.0<1;1,0>:d                  
        add (8|M8)               r36.1<2>:ud   r14.0<1;1,0>:ud   r33.0<1;1,0>:ud  {Compacted,I@2}
        mov (8|M8)               r36.0<2>:d    r13.0<1;1,0>:d                  
        send.ugm (16|M0)         r74      r34     null:0  0x0            0x08883580           {A@1,$8} // wr:4+0, rd:8; load.ugm.d32x4.a64.ca.ca
L3536:
        join (16|M0)                         L3832                                
L3552:
        addc (8|M0)              r2.0<1>:ud    r60.0<1;1,0>:ud   r47.4<0;1,0>:ud  {AccWrEn,Compacted}
        mov (8|M0)               r8.0<1>:ud    acc0.0<1;1,0>:ud                 {Compacted}
        addc (8|M8)              r3.0<1>:ud    r61.0<1;1,0>:ud   r47.4<0;1,0>:ud  {AccWrEn}
        add3 (8|M0)              r9.1<2>:ud    r8.0<1;0>:ud      r62.0<1;0>:ud     r47.5<0>:ud      {I@2}
        mov (8|M8)               r14.0<1>:ud   acc0.0<1;1,0>:ud                 {Compacted}
        addc (8|M0)              r82.0<1>:ud   r56.0<1;1,0>:ud   r7.0<0;1,0>:ud   {AccWrEn,Compacted}
        mov (8|M0)               r9.0<2>:d     r2.0<1;1,0>:d                   
        add (8|M0)               r84.0<1>:ud   acc0.0<1;1,0>:ud  r58.0<1;1,0>:ud 
        addc (8|M8)              r83.0<1>:ud   r57.0<1;1,0>:ud   r7.0<0;1,0>:ud   {AccWrEn}
        add3 (8|M8)              r11.1<2>:ud   r14.0<1;0>:ud     r63.0<1;0>:ud     r47.5<0>:ud      {I@5}
        cmp (16|M0)   (lt)f1.1   null<1>:d     r82.0<1;1,0>:ud   r47.0<0;1,0>:ud  {I@2}
        add (8|M8)               r85.0<1>:ud   acc0.0<1;1,0>:ud  r59.0<1;1,0>:ud 
        mov (8|M8)               r11.0<2>:d    r3.0<1;1,0>:d                   
(f1.1)  cmp (16|M0)   (eq)f1.1   null<1>:d     r84.0<1;1,0>:d    r47.1<0;1,0>:d   {I@2}
        sync.nop                             null                             {Compacted,$8.dst}
        send.ugm (16|M0)         null     r9      r74:8   0x0            0x080E3584           {A@2,$5} // wr:4+8, rd:0; store.ugm.d32x4.a64.wb.wb
(~f1.1) cmp (16|M0)   (lt)f1.1   null<1>:d     r84.0<1;1,0>:ud   r47.1<0;1,0>:ud 
(~f1.1) goto (16|M0)                         L3832                  L3832                
L3800:
(f1.1)  sel (16|M0)              r56.0<1>:d    r82.0<1;1,0>:d    r48.0<1;1,0>:d   {Compacted}
(f1.1)  sel (16|M0)              r58.0<1>:d    r84.0<1;1,0>:d    r50.0<1;1,0>:d   {Compacted}
(W)     jmpi                                 L1016                                
L3832:
        join (16|M0)                         L3848                                
L3848:
(W)     mov (8|M0)               r127.0<1>:f   r46.0<1;1,0>:f                   {Compacted,$3.src}
(W)     send.gtwy (1|M0)         null     r127    null:0  0x0            0x02000010           {EOT,A@1} // wr:1+0, rd:0; end of thread
L3872:
        nop                    
(W)     mov (16|M0)              null<1>:ud    0x6F9278B:ud                             
(W)     mov (16|M0)              null<1>:ud    0x6180031B:ud                             
(W)     mov (16|M0)              null<1>:ud    0x0:ud                             
(W)     mov (16|M0)              null<1>:ud    0x9:ud                             
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
