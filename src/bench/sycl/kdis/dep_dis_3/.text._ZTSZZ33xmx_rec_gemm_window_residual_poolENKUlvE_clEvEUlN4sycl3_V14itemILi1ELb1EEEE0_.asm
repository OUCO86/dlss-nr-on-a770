L0:
(W)     mov (8|M0)               r127.0<1>:ud  0x0:ud                             
(W)     and (1|M0)               r127.2<1>:ud  r0.0<0;1,0>:ud    0xFFFFFFC0:ud             
(W)     and (1|M0)               r127.0<1>:uw  r0.4<0;1,0>:uw    0xFF:uw             
(W)     add (1|M0)               r127.2<1>:ud  r127.2<0;1,0>:ud  0x40:ud              {I@2}
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
(W)     mov (8|M0)               r2.0<1>:ud    r0.0<1;1,0>:ud                   {$0.dst}
(W)     or (1|M0)                cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x4C0:uw              {A@1}
        sync.nop                             null                             {Compacted,A@1}
        sync.nop                             null                             {Compacted,$2.dst}
(W)     cmp (8|M0)    (eq)f1.0   null<1>:d     r5.2<0;1,0>:d     0:w               {A@1}
(W)     mul (1|M0)               acc0.0<1>:d   r4.3<0;1,0>:d     r2.2<0;1,0>:uw   {I@3}
(W)     mach (1|M0)              r6.0<1>:d     r4.3<0;1,0>:d     r2.1<0;1,0>:d   
        add3 (8|M0)              r89.0<1>:d    r6.0<0;0>:d       r1.0<1;0>:uw      r4.0<0>:d        {I@1}
(~f1.0) goto (8|M0)                          L416                  L416                
L384:
        mov (8|M0)               r54.0<1>:d    -1:w                              
        goto (8|M0)                          L416                  L776                
L416:
        join (8|M0)                          L776                                
L432:
(W)     xor (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x30:uw              {A@1}
(W)     mov (1|M0)               r6.1<1>:f     r5.2<0;1,0>:ud                   {A@1}
        mov (8|M0)               r48.0<1>:f    r89.0<1;1,0>:ud                  {Compacted,I@6}
(W)     mov (1|M0)               r6.0<1>:ud    r6.1<0;1,0>:f                    {F@2}
(W)     math.inv (1|M0)          r6.6<1>:f     r6.1<0;1,0>:f                    {$3}
(W)     add (1|M0)               r6.7<1>:d     r5.2<0;1,0>:d     -r6.0<0;1,0>:d   {I@1}
(W)     mov (1|M0)               r6.0<1>:f     0xB4C00000:f                               {Compacted,I@1}
        mov (8|M0)               r126.0<1>:ud  r48.0<1;1,0>:f                   {F@2}
        sync.nop                             null                             {Compacted,$3.dst}
(W)     mad (1|M0)               r6.0<1>:f     r6.6<0;0>:f       r6.0<0;0>:f       r6.6<0>:f        {F@1}
        add (8|M0)               r126.0<1>:d   r89.0<1;1,0>:d    -r126.0<1;1,0>:d {Compacted,I@1}
        mul (8|M0)               r102.0<1>:f   r48.0<1;1,0>:f    r6.0<0;1,0>:f    {Compacted,F@1}
(W)     mov (1|M0)               r6.6<1>:f     r6.7<0;1,0>:ud                  
        mov (8|M0)               r63.0<1>:ud   r102.0<1;1,0>:f                  {F@2}
        mov (8|M0)               r117.0<1>:f   r126.0<1;1,0>:ud                 {Compacted,I@2}
        mov (8|M0)               r122.0<1>:f   r63.0<1;1,0>:ud                  {Compacted,I@1}
        mad (8|M0)               acc0.0<1>:f   r48.0<1;0>:f      r122.0<1;0>:f     -r6.1<0>:f       {Compacted,F@1}
        mad (8|M0)               acc1.0<1>:f   r117.0<1;0>:f     r122.0<1;0>:f     -r6.6<0>:f       {Compacted}
        add (8|M0)               acc0.0<1>:f   acc0.0<1;1,0>:f   acc1.0<1;1,0>:f 
        mul (8|M0)               r83.0<1>:f    r6.0<0;1,0>:f     acc0.0<1;1,0>:f 
(W)     xor (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x30:uw              {A@1}
        mov (8|M0)               r98.0<1>:ud   r83.0<1;1,0>:f                   {A@1}
        add (8|M0)               r35.0<1>:d    r98.0<1;1,0>:d    r63.0<1;1,0>:d   {Compacted,I@1}
(W)     mul (8|M0)               acc0.0<1>:d   r35.0<1;1,0>:d    r5.4<0;1,0>:uw   {Compacted,I@1}
        mach (8|M0)              r35.0<1>:d    r35.0<1;1,0>:d    r5.2<0;1,0>:d    {Compacted}
        add (8|M0)               r35.0<1>:d    r89.0<1;1,0>:d    -r35.0<1;1,0>:d  {Compacted,I@1}
        cmp (8|M0)    (ge)f1.1   r78.0<1>:ud   r35.0<1;1,0>:ud   r5.2<0;1,0>:ud   {I@1}
        add3 (8|M0)              r54.0<1>:d    r98.0<1;0>:d      r63.0<1;0>:d      -r78.0<1>:d      {I@1}
L776:
        join (8|M0)                          L792                                
L792:
(W)     shl (1|M0)               r6.1<1>:d     r5.2<0;1,0>:d     4:w              
(W)     cmp (8|M0)    (eq)f0.1   null<1>:d     r6.1<0;1,0>:d     0:w               {I@1}
(~f0.1) goto (8|M0)                          L872                  L872                
L840:
        mov (8|M0)               r58.0<1>:d    -1:w                              
        goto (8|M0)                          L872                  L1224                
L872:
        join (8|M0)                          L1224                                
L888:
(W)     xor (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x30:uw              {A@1}
(W)     mov (1|M0)               r6.6<1>:f     r6.1<0;1,0>:ud                   {A@1}
        mov (8|M0)               r56.0<1>:f    r89.0<1;1,0>:ud                  {Compacted}
(W)     mov (1|M0)               r6.0<1>:ud    r6.6<0;1,0>:f                    {F@2}
(W)     math.inv (1|M0)          r6.7<1>:f     r6.6<0;1,0>:f                    {$4}
        sync.nop                             null                             {Compacted,$1.dst}
(W)     add (1|M0)               r3.0<1>:d     r6.1<0;1,0>:d     -r6.0<0;1,0>:d   {Compacted,I@1}
(W)     mov (1|M0)               r6.0<1>:f     0xB4C00000:f                               {Compacted,I@1}
        mov (8|M0)               r33.0<1>:ud   r56.0<1;1,0>:f                   {F@2}
        sync.nop                             null                             {Compacted,$4.dst}
(W)     mad (1|M0)               r6.0<1>:f     r6.7<0;0>:f       r6.0<0;0>:f       r6.7<0>:f        {F@1}
        add (8|M0)               r33.0<1>:d    r89.0<1;1,0>:d    -r33.0<1;1,0>:d  {Compacted,I@1}
        mul (8|M0)               r116.0<1>:f   r56.0<1;1,0>:f    r6.0<0;1,0>:f    {Compacted,F@1}
(W)     mov (1|M0)               r6.7<1>:f     r3.0<0;1,0>:ud                   {Compacted}
        mov (8|M0)               r68.0<1>:ud   r116.0<1;1,0>:f                  {F@2}
        mov (8|M0)               r27.0<1>:f    r33.0<1;1,0>:ud                  {Compacted,I@2}
        mov (8|M0)               r17.0<1>:f    r68.0<1;1,0>:ud                  {Compacted,I@1}
        mad (8|M0)               acc0.0<1>:f   r56.0<1;0>:f      r17.0<1;0>:f      -r6.6<0>:f       {Compacted,F@1}
        mad (8|M0)               acc1.0<1>:f   r27.0<1;0>:f      r17.0<1;0>:f      -r6.7<0>:f       {Compacted}
        add (8|M0)               acc0.0<1>:f   acc0.0<1;1,0>:f   acc1.0<1;1,0>:f 
        mul (8|M0)               r95.0<1>:f    r6.0<0;1,0>:f     acc0.0<1;1,0>:f 
(W)     xor (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x30:uw              {A@1}
        mov (8|M0)               r111.0<1>:ud  r95.0<1;1,0>:f                   {A@1}
        add (8|M0)               r38.0<1>:d    r111.0<1;1,0>:d   r68.0<1;1,0>:d   {Compacted,I@1}
(W)     mul (8|M0)               acc0.0<1>:d   r38.0<1;1,0>:d    r6.2<0;1,0>:uw   {Compacted,I@1}
        mach (8|M0)              r38.0<1>:d    r38.0<1;1,0>:d    r6.1<0;1,0>:d    {Compacted}
        add (8|M0)               r38.0<1>:d    r89.0<1;1,0>:d    -r38.0<1;1,0>:d  {Compacted,I@1}
        cmp (8|M0)    (ge)f1.0   r75.0<1>:ud   r38.0<1;1,0>:ud   r6.1<0;1,0>:ud   {I@1}
        add3 (8|M0)              r58.0<1>:d    r111.0<1;0>:d     r68.0<1;0>:d      -r75.0<1>:d      {I@1}
L1224:
        join (8|M0)                          L1240                                
L1240:
(W)     cmp (8|M0)    (eq)f0.0   null<1>:d     r5.3<0;1,0>:d     0:w              
        shl (8|M0)               r56.0<1>:d    r54.0<1;1,0>:d    2:w               {Compacted}
        shl (8|M0)               r51.0<1>:d    r54.0<1;1,0>:d    1:w               {Compacted}
        and (8|M0)               r11.0<1>:d    r56.0<1;1,0>:d    48:w               {Compacted,I@2}
        and (8|M0)               r10.0<1>:d    r51.0<1;1,0>:d    6:w               {Compacted,I@2}
(~f0.0) goto (8|M0)                          L1336                  L1336                
L1304:
        mov (8|M0)               r38.0<1>:d    -1:w                              
        goto (8|M0)                          L1336                  L1696                
L1336:
        join (8|M0)                          L1696                                
L1352:
(W)     xor (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x30:uw              {A@1}
(W)     mov (1|M0)               r6.1<1>:f     r5.3<0;1,0>:ud                   {A@1}
        mov (8|M0)               r67.0<1>:f    r58.0<1;1,0>:ud                  {Compacted}
(W)     mov (1|M0)               r6.0<1>:ud    r6.1<0;1,0>:f                    {F@2}
(W)     math.inv (1|M0)          r6.6<1>:f     r6.1<0;1,0>:f                    {$5}
(W)     add (1|M0)               r6.7<1>:d     r5.3<0;1,0>:d     -r6.0<0;1,0>:d   {I@1}
(W)     mov (1|M0)               r6.0<1>:f     0xB4C00000:f                               {Compacted,I@1}
        mov (8|M0)               r55.0<1>:ud   r67.0<1;1,0>:f                   {F@2}
        sync.nop                             null                             {Compacted,$5.dst}
(W)     mad (1|M0)               r6.0<1>:f     r6.6<0;0>:f       r6.0<0;0>:f       r6.6<0>:f        {F@1}
        add (8|M0)               r55.0<1>:d    r58.0<1;1,0>:d    -r55.0<1;1,0>:d  {Compacted,I@1}
        mul (8|M0)               r38.0<1>:f    r67.0<1;1,0>:f    r6.0<0;1,0>:f    {Compacted,F@1}
(W)     mov (1|M0)               r6.6<1>:f     r6.7<0;1,0>:ud                  
        mov (8|M0)               r76.0<1>:ud   r38.0<1;1,0>:f                   {F@2}
        mov (8|M0)               r47.0<1>:f    r55.0<1;1,0>:ud                  {Compacted,I@2}
        mov (8|M0)               r38.0<1>:f    r76.0<1;1,0>:ud                  {Compacted,I@1}
        mad (8|M0)               acc0.0<1>:f   r67.0<1;0>:f      r38.0<1;0>:f      -r6.1<0>:f       {Compacted,F@1}
        mad (8|M0)               acc1.0<1>:f   r47.0<1;0>:f      r38.0<1;0>:f      -r6.6<0>:f       {Compacted}
        add (8|M0)               acc0.0<1>:f   acc0.0<1;1,0>:f   acc1.0<1;1,0>:f 
        mul (8|M0)               r115.0<1>:f   r6.0<0;1,0>:f     acc0.0<1;1,0>:f 
(W)     xor (1|M0)               cr0.0<1>:ud   cr0.0<0;1,0>:ud   0x30:uw              {A@1}
        mov (8|M0)               r16.0<1>:ud   r115.0<1;1,0>:f                  {A@1}
        add (8|M0)               r52.0<1>:d    r16.0<1;1,0>:d    r76.0<1;1,0>:d   {Compacted,I@1}
(W)     mul (8|M0)               acc0.0<1>:d   r52.0<1;1,0>:d    r5.6<0;1,0>:uw   {Compacted,I@1}
        mach (8|M0)              r52.0<1>:d    r52.0<1;1,0>:d    r5.3<0;1,0>:d    {Compacted}
        add (8|M0)               r52.0<1>:d    r58.0<1;1,0>:d    -r52.0<1;1,0>:d  {Compacted,I@1}
        cmp (8|M0)    (ge)f0.1   r72.0<1>:ud   r52.0<1;1,0>:ud   r5.3<0;1,0>:ud   {I@1}
        add3 (8|M0)              r38.0<1>:d    r16.0<1;0>:d      r76.0<1;0>:d      -r72.0<1>:d      {I@1}
L1696:
        join (8|M0)                          L1712                                
L1712:
(W)     mul (8|M0)               acc0.0<1>:d   r38.0<1;1,0>:d    r5.6<0;1,0>:uw   {Compacted,I@2}
        mach (8|M0)              r68.0<1>:d    r38.0<1;1,0>:d    r5.3<0;1,0>:d    {Compacted}
(W)     mov (1|M0)               r6.0<1>:d     6:w                              
        add (8|M0)               acc0.0<1>:d   r58.0<1;1,0>:d    -r68.0<1;1,0>:d  {I@2}
        shl (8|M0)               r16.0<1>:d    r38.0<1;1,0>:d    3:w               {Compacted}
        shl (8|M0)               r68.0<1>:d    acc0.0<1;1,0>:d   3:w              
        shr (8|M0)               r71.0<1>:ud   r11.0<1;1,0>:ud   3:w              
        bfn.0xEA (8|M0)          r114.0<1>:ud  r68.0<1;0>:ud     r51.0<1;0>:ud     r6.0<0>:ud       {I@2} // s0|s1&s2
        or (8|M0)                r25.0<1>:d    r16.0<1;1,0>:d    r71.0<1;1,0>:d   {Compacted,I@2}
        cmp (8|M0)    (lt)f0.1   null<1>:ud    r114.0<1;1,0>:ud  r5.5<0;1,0>:ud   {I@2}
(~f0.1) cmp (8|M0)    (lt)f0.1   null<1>:ud    r25.0<1;1,0>:ud   r5.4<0;1,0>:ud   {I@2}
(f0.1)  goto (8|M0)                          L36744                  L36744                
L1872:
        add (8|M0)               r8.0<1>:d     r25.0<1;1,0>:d    -r5.4<0;1,0>:d   {Compacted}
        cmp (8|M0)    (lt)f1.1   null<1>:ud    r8.0<1;1,0>:ud    r5.6<0;1,0>:ud   {I@1}
(~f1.1) goto (8|M0)                          L36744                  L36744                
L1912:
        add (8|M0)               r9.0<1>:d     r114.0<1;1,0>:d   -r5.5<0;1,0>:d   {Compacted}
        cmp (8|M0)    (lt)f1.0   null<1>:ud    r9.0<1;1,0>:ud    r5.7<0;1,0>:ud   {I@1}
(~f1.0) goto (8|M0)                          L36744                  L36744                
L1952:
        shl (8|M0)               r37.0<1>:d    r58.0<1;1,0>:d    6:w               {Compacted}
(W)     mul (8|M0)               acc0.0<1>:d   r54.0<1;1,0>:d    r5.4<0;1,0>:uw   {Compacted}
        bfn.0xFE (8|M0)          r97.0<1>:ud   r37.0<1;0>:ud     r11.0<1;0>:ud     r10.0<1>:ud      {I@2} // s0|s1|s2
        mach (8|M0)              r70.0<1>:d    r54.0<1;1,0>:d    r5.2<0;1,0>:d    {Compacted}
(W)     mul (8|M0)               acc0.0<1>:ud  r37.0<1;1,0>:ud   r5.4<0;1,0>:uw  
        mach (8|M0)              r14.0<1>:ud   r37.0<1;1,0>:ud   r5.2<0;1,0>:ud   {Compacted}
(W)     mul (8|M0)               acc0.0<1>:d   r97.0<1;1,0>:d    r5.4<0;1,0>:uw   {Compacted,I@4}
        sync.nop                             null                             {Compacted,$1.dst}
        add (8|M0)               r3.0<1>:d     r89.0<1;1,0>:d    -r70.0<1;1,0>:d  {Compacted,I@4}
        mach (8|M0)              r91.0<1>:d    r97.0<1;1,0>:d    r5.2<0;1,0>:d    {Compacted}
(W)     mov (1|M0)               a0.0<1>:ud    r6.4<0;1,0>:d                    {A@1}
        shl (8|M0)               r12.0<1>:d    r3.0<1;1,0>:d     2:w               {Compacted,I@3}
        shl (8|M0)               r91.0<1>:d    r91.0<1;1,0>:d    2:w               {Compacted,I@3}
(W)     mov (1|M0)               r6.0<1>:d     48:w                              
        add3 (8|M0)              r98.0<1>:d    r91.0<1;0>:d      r6.2<0;0>:d       r12.0<1>:d       {I@2}
        shr (8|M0)               r67.0<1>:ud   r58.0<1;1,0>:ud   26:w              
        send.ugm (8|M0)          r7       r98     null:0  a0.0        0x22180500           {ExBSO,A@2,$6} // wr:1+0, rd:1; load.ugm.d32.a32.ca.ca.bss[a0.0]
(W)     mov (1|M0)               r6.1<1>:f     -0.0:f                               {Compacted}
(W)     mov (1|M0)               r6.6<1>:d     -1:w                              
        bfn.0xF8 (8|M0)          r55.0<1>:ud   r56.0<1;0>:ud     r6.0<0;0>:ud      r10.0<1>:ud      // s0&s1|s2
(W)     mov (1|M0)               r6.0<1>:f     inf:f                               {Compacted,I@1}
        shr (8|M0)               r69.0<1>:ud   r7.0<1;1,0>:ud    23:w               {$6.dst}
        and (8|M0)    (ne)f0.0   r22.0<1>:d    r7.0<1;1,0>:d     8388607:d              
        and (8|M0)               r112.0<1>:d   r69.0<1;1,0>:d    255:w               {Compacted,I@2}
(f0.0)  cmp (8|M0)    (eq)f0.0   null<1>:d     r112.0<1;1,0>:d   255:w               {I@1}
(~f0.0) goto (8|M0)                          L2288                  L2288                
L2264:
        mov (8|M0)               r7.0<1>:f     qnan(0x0):f                               {Compacted}
        goto (8|M0)                          L2288                  L7384                
L2288:
        join (8|M0)                          L7384                                
L2304:
(W)     mov (1|M0)               r6.7<1>:d     8:w                              
(W)     mov (1|M0)               a0.0<1>:ud    r6.4<0;1,0>:d                    {A@1}
        bfn.0xFE (8|M0)          r51.0<1>:ud   r55.0<1;0>:ud     r37.0<1;0>:ud     r6.7<0>:ud       {I@2} // s0|s1|s2
(W)     mul (8|M0)               acc0.0<1>:d   r51.0<1;1,0>:d    r5.4<0;1,0>:uw   {Compacted,I@1}
        mach (8|M0)              r51.0<1>:d    r51.0<1;1,0>:d    r5.2<0;1,0>:d    {Compacted}
        shl (8|M0)               r51.0<1>:d    r51.0<1;1,0>:d    2:w               {Compacted,I@1}
        add3 (8|M0)              r15.0<1>:d    r51.0<1;0>:d      r6.2<0;0>:d       r12.0<1>:d       {I@1}
        send.ugm (8|M0)          r18      r15     null:0  a0.0        0x22180500           {ExBSO,A@1,$7} // wr:1+0, rd:1; load.ugm.d32.a32.ca.ca.bss[a0.0]
        shr (8|M0)               r68.0<1>:ud   r18.0<1;1,0>:ud   23:w               {$7.dst}
        and (8|M0)    (ne)f1.1   r121.0<1>:d   r18.0<1;1,0>:d    8388607:d              
        and (8|M0)               r103.0<1>:d   r68.0<1;1,0>:d    255:w               {Compacted,I@2}
(f1.1)  cmp (8|M0)    (eq)f1.1   null<1>:d     r103.0<1;1,0>:d   255:w               {I@1}
(~f1.1) goto (8|M0)                          L2504                  L2504                
L2480:
        mov (8|M0)               r7.0<1>:f     qnan(0x0):f                               {Compacted}
        goto (8|M0)                          L2504                  L7384                
L2504:
        join (8|M0)                          L7384                                
L2520:
        cmp (8|M0)    (eq)f0.1   null<1>:d     r22.0<1;1,0>:d    0:w              
        shr (8|M0)               r60.0<1>:ud   r7.0<1;1,0>:ud    31:w               {F@1}
        shr (8|M0)               r59.0<1>:ud   r18.0<1;1,0>:ud   31:w              
        cmp (8|M0)    (eq)f1.0   null<1>:d     r121.0<1;1,0>:d   0:w              
(f0.1)  cmp (8|M0)    (eq)f0.1   null<1>:d     r112.0<1;1,0>:d   255:w              
(f0.1)  goto (8|M0)                          L7304                  L7304                
L2616:
        cmp (8|M0)    (eq)f0.0   null<1>:d     r103.0<1;1,0>:d   255:w               {Compacted}
(W)     mov (1|M0)               r6.14<1>:hf   0x1:hf                             
        or (8|M0)                r67.0<1>:d    r112.0<1;1,0>:d   r22.0<1;1,0>:d   {Compacted}
(f1.0)  sel (8|M0)               r4.0<1>:uw    r6.14<0;1,0>:uw   0x0:uw              {F@1}
(f0.0)  sel (8|M0)               r13.0<1>:uw   r6.14<0;1,0>:uw   0x0:uw             
        and (8|M0)    (ne)f1.0   null<1>:uw    r13.0<1;1,0>:uw   r4.0<1;1,0>:uw   {I@1}
(~f1.0) cmp (8|M0)    (eq)f1.0   null<1>:d     r67.0<1;1,0>:d    0:w              
(~f1.0) goto (8|M0)                          L2752                  L2752                
L2728:
        mov (8|M0)               r7.0<1>:f     r18.0<1;1,0>:f                   {Compacted}
        goto (8|M0)                          L2752                  L7384                
L2752:
        join (8|M0)                          L7304                                
L2768:
        or (8|M0)     (eq)f0.1   null<1>:d     r103.0<1;1,0>:d   r121.0<1;1,0>:d 
(f0.1)  goto (8|M0)                          L7304                  L7384                
L2800:
        cmp (8|M0)    (eq)f0.0   null<1>:d     r60.0<1;1,0>:d    r59.0<1;1,0>:d  
        cmp (8|M0)    (lt)f0.1   null<1>:ud    r103.0<1;1,0>:ud  r112.0<1;1,0>:ud
(f0.0)  goto (8|M0)                          L3056                  L3056                
L2848:
(f0.1)  goto (8|M0)                          L2952                  L2952                
L2864:
        mov (8|M0)               r16.0<1>:f    r18.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r109.0<1>:f   r7.0<1;1,0>:f                    {Compacted,F@2}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        call (8|M0)              r4.0          L36848                                 {A@1}
L2928:
        mov (8|M0)               r7.0<1>:f     r57.0<1;1,0>:f                   {Compacted}
        goto (8|M0)                          L2952                  L7384                
L2952:
        join (8|M0)                          L3056                                
L2968:
        mov (8|M0)               r16.0<1>:f    r7.0<1;1,0>:f                    {Compacted,F@1}
        mov (8|M0)               r109.0<1>:f   r18.0<1;1,0>:f                   {Compacted}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        call (8|M0)              r4.0          L36848                                 {A@1}
L3032:
        mov (8|M0)               r7.0<1>:f     r57.0<1;1,0>:f                   {Compacted}
        goto (8|M0)                          L3056                  L7384                
L3056:
        join (8|M0)                          L7304                                
L3072:
(f0.1)  goto (8|M0)                          L5280                  L5280                
L3088:
        cmp (8|M0)    (eq)f1.0   null<1>:d     r112.0<1;1,0>:d   0:w              
(f1.0)  goto (8|M0)                          L3176                  L3176                
L3120:
(W)     mov (1|M0)               r6.28<2>:b    1:w                              
        add (8|M0)               r116.0<1>:d   r103.0<1;1,0>:d   -r112.0<1;1,0>:d {Compacted}
        mov (8|M0)               r4.0<1>:b     r6.28<0;1,0>:b                   {I@2}
        goto (8|M0)                          L3176                  L3264                
L3176:
        join (8|M0)                          L3264                                
L3192:
        cmp (8|M0)    (eq)f1.1   null<1>:d     r103.0<1;1,0>:d   0:w              
(f1.1)  goto (8|M0)                          L3264                  L5224                
L3224:
(W)     mov (1|M0)               r6.28<2>:b    0:w                              
        add (8|M0)               r116.0<1>:d   r103.0<1;1,0>:d   -1:w               {Compacted}
        mov (8|M0)               r4.0<1>:b     r6.28<0;1,0>:b                   {I@2}
L3264:
        join (8|M0)                          L5224                                
L3280:
        cmp (8|M0)    (lt)f0.1   null<1>:d     r116.0<1;1,0>:d   1:w               {I@3}
(f0.1)  goto (8|M0)                          L3976                  L3976                
L3312:
        cmp (8|M0)    (eq)f0.0   null<1>:d     r116.0<1;1,0>:d   1:w               {Compacted}
(f0.0)  goto (8|M0)                          L3856                  L3856                
L3336:
        cmp (8|M0)    (lt)f1.1   null<1>:ud    r116.0<1;1,0>:ud  0x18:uw             
(f1.1)  goto (8|M0)                          L3616                  L3616                
L3368:
        cmp (8|M0)    (lt)f0.1   null<1>:d     r116.0<1;1,0>:d   25:w              
        mov (8|M0)               r125.0<1>:d   r4.0<1;1,0>:ub                   {I@7}
(f0.1)  goto (8|M0)                          L3512                  L3512                
L3416:
        cmp (8|M0)    (eq)f0.0   null<1>:d     r116.0<1;1,0>:d   25:w               {Compacted}
(~f0.0) goto (8|M0)                          L3512                  L4024                
L3440:
        cmp (8|M0)    (ne)f0.0   r83.0<1>:d    r22.0<1;1,0>:d    0:w              
        mov (8|M0)               r61.0<1>:f    r125.0<1;1,0>:f                  {Compacted,I@5}
        mov (8|M0)               r92.0<1>:d    0:w                              
        mov (8|M0)               r125.0<1>:d   0:w                               {F@1}
        goto (8|M0)                          L3512                  L4104                
L3512:
        join (8|M0)                          L3616                                
L3528:
        shr (8|M0)               r66.0<1>:ud   r7.0<1;1,0>:ud    22:w              
        and (8|M0)               r65.0<1>:d    r7.0<1;1,0>:d     4194303:d              
        mov (8|M0)               r92.0<1>:d    0:w                              
        and (8|M0)               r61.0<1>:d    r66.0<1;1,0>:d    1:w               {Compacted,I@3}
        cmp (8|M0)    (ne)f1.1   r83.0<1>:d    r65.0<1;1,0>:d    0:w               {I@3}
        goto (8|M0)                          L3616                  L4104                
L3616:
        join (8|M0)                          L3856                                
L3632:
        add (8|M0)               acc0.0<1>:d   r116.0<1;1,0>:d   -2:w               {Compacted}
(W)     mov (1|M0)               r6.14<1>:hf   -qnan(0x1FF):hf                             
        add (8|M0)               acc2.0<1>:d   r116.0<1;1,0>:d   -1:w               {Compacted}
        add (8|M0)               r82.0<1>:d    -r116.0<1;1,0>:d  23:w               {Compacted}
        shr (8|M0)               r64.0<1>:ud   r22.0<1;1,0>:ud   acc0.0<1;1,0>:d 
        shl (8|M0)               r34.0<1>:d    r6.14<0;1,0>:w    acc0.0<1;1,0>:d  {F@1}
(W)     mov (1|M0)               r6.14<1>:hf   0x1:hf                              {I@1}
        shr (8|M0)               r49.0<1>:ud   r22.0<1;1,0>:ud   r116.0<1;1,0>:d 
        shr (8|M0)               r42.0<1>:ud   r22.0<1;1,0>:ud   acc2.0<1;1,0>:d 
        bfn.0x60 (8|M0)          r54.0<1>:ud   r34.0<1;0>:ud     r6.6<0;0>:ud      r22.0<1>:ud      // (s0^s1)&s2
        shl (8|M0)               r82.0<1>:d    r6.14<0;1,0>:w    r82.0<1;1,0>:d   {F@1}
(f1.0)  mov (8|M0)               r82.0<1>:d    0:w                              
        and (8|M0)               r61.0<1>:d    r64.0<1;1,0>:d    1:w               {Compacted}
        and (8|M0)               r125.0<1>:d   r42.0<1;1,0>:d    1:w               {Compacted,I@5}
        cmp (8|M0)    (ne)f1.0   r83.0<1>:d    r54.0<1;1,0>:d    0:w               {I@5}
        or (8|M0)                r92.0<1>:d    r49.0<1;1,0>:d    r82.0<1;1,0>:d   {Compacted,I@4}
        goto (8|M0)                          L3856                  L4104                
L3856:
        join (8|M0)                          L3976                                
L3872:
        shr (8|M0)               r24.0<1>:ud   r22.0<1;1,0>:ud   1:w              
        and (8|M0)               r125.0<1>:d   r7.0<1;1,0>:d     1:w               {Compacted}
        or (8|M0)                r63.0<1>:d    r24.0<1;1,0>:d    4194304:d               {I@2}
        mov (8|M0)               r61.0<1>:d    0:w                              
        mov (8|M0)               r83.0<1>:d    0:w                              
(f1.0)  sel (8|M0)               r92.0<1>:d    r24.0<1;1,0>:d    r63.0<1;1,0>:d   {I@3}
        goto (8|M0)                          L3976                  L4104                
L3976:
        join (8|M0)                          L4024                                
L3992:
        cmp (8|M0)    (eq)f1.1   null<1>:d     r116.0<1;1,0>:d   0:w              
(f1.1)  goto (8|M0)                          L4024                  L4320                
L4024:
        join (8|M0)                          L4104                                
L4040:
        cmp (8|M0)    (ne)f0.1   r83.0<1>:d    r7.0<1;1,0>:d     0:w              
        mov (8|M0)               r125.0<1>:d   0:w                              
        mov (8|M0)               r61.0<1>:d    0:w                              
        mov (8|M0)               r92.0<1>:d    0:w                              
L4104:
        join (8|M0)                          L4320                                
L4120:
        add (8|M0)               r108.0<1>:d   r121.0<1;1,0>:d   r92.0<1;1,0>:d   {Compacted,I@2}
        cmp (8|M0)    (ne)f0.0   r37.0<1>:d    r83.0<1;1,0>:d    0:w              
        cmp (8|M0)    (gt)f1.0   null<1>:ud    r108.0<1;1,0>:ud  0x7FFFFF:ud              {I@2}
        mov (8|M0)               r98.0<1>:d    -r37.0<1;1,0>:d                  {I@2}
(f1.0)  goto (8|M0)                          L4224                  L4224                
L4192:
        mov (8|M0)               r28.0<1>:d    r61.0<1;1,0>:d                  
        goto (8|M0)                          L4224                  L4728                
L4224:
        join (8|M0)                          L4320                                
L4240:
        cmp (8|M0)    (eq)f0.1   null<1>:d     r61.0<1;1,0>:d    1:w              
        shr (8|M0)               r62.0<1>:ud   r108.0<1;1,0>:ud  1:w              
        and (8|M0)               r28.0<1>:d    r62.0<1;1,0>:d    4194303:d               {I@1}
(~f0.1) sel (8|M0)               r98.0<1>:d    -r37.0<1;1,0>:d   1:w              
        goto (8|M0)                          L4320                  L4664                
L4320:
        join (8|M0)                          L4664                                
L4336:
        add (8|M0)               r108.0<1>:d   r121.0<1;1,0>:d   r22.0<1;1,0>:d   {Compacted}
        cmp (8|M0)    (gt)f0.0   null<1>:ud    r108.0<1;1,0>:ud  0x7FFFFF:ud              {I@1}
(f0.0)  goto (8|M0)                          L4552                  L4552                
L4376:
(~f1.0) goto (8|M0)                          L4456                  L4456                
L4392:
        mov (8|M0)               r125.0<1>:d   0:w                              
        mov (8|M0)               r28.0<1>:d    0:w                              
        mov (8|M0)               r98.0<1>:d    0:w                              
        goto (8|M0)                          L4456                  L4728                
L4456:
        join (8|M0)                          L4552                                
L4472:
        and (8|M0)               r125.0<1>:d   r108.0<1;1,0>:d   1:w               {Compacted}
        add (8|M0)               r103.0<1>:d   r103.0<1;1,0>:d   1:w               {Compacted}
        mov (8|M0)               r28.0<1>:d    0:w                              
        mov (8|M0)               r98.0<1>:d    0:w                              
        shr (8|M0)               r108.0<1>:ud  r108.0<1;1,0>:ud  1:w              
        goto (8|M0)                          L4552                  L4728                
L4552:
        join (8|M0)                          L4664                                
L4568:
        shr (8|M0)               r22.0<1>:ud   r108.0<1;1,0>:ud  1:w               {I@3}
        mov (8|M0)               r98.0<1>:d    0:w                              
        and (8|M0)               r26.0<1>:d    r22.0<1;1,0>:d    4194303:d               {I@2}
        or (8|M0)                r22.0<1>:d    r22.0<1;1,0>:d    4194304:d              
        mov (8|M0)               r125.0<1>:d   0:w                              
(f1.0)  sel (8|M0)               r28.0<1>:d    r26.0<1;1,0>:d    r22.0<1;1,0>:d   {I@2}
L4664:
        join (8|M0)                          L4728                                
L4680:
        and (8|M0)               acc0.0<1>:d   r108.0<1;1,0>:d   1:w               {Compacted}
        add (8|M0)               r103.0<1>:d   r103.0<1;1,0>:d   1:w               {Compacted}
        mov (8|M0)               r108.0<1>:f   r28.0<1;1,0>:f                   {Compacted,A@2}
        mov (8|M0)               r28.0<1>:f    r125.0<1;1,0>:f                  {Compacted}
        mov (8|M0)               r125.0<1>:d   acc0.0<1;1,0>:d                  {F@1}
L4728:
        join (8|M0)                          L5224                                
L4744:
        shl (8|M0)               r37.0<1>:d    r125.0<1;1,0>:d   2:w               {Compacted,I@2}
        shl (8|M0)               r61.0<1>:d    r28.0<1;1,0>:d    1:w               {Compacted}
        bfn.0xFE (8|M0)          r21.0<1>:ud   r37.0<1;0>:ud     r61.0<1;0>:ud     r98.0<1>:ud      {I@1} // s0|s1|s2
        cmp (8|M0)    (eq)f1.1   null<1>:d     r21.0<1;1,0>:d    0:w               {I@1}
(~f1.1) goto (8|M0)                          L4840                  L4840                
L4808:
        mov (8|M0)               r32.0<1>:d    0:w                              
        goto (8|M0)                          L4840                  L5000                
L4840:
        join (8|M0)                          L5000                                
L4856:
        cmp (8|M0)    (gt)f1.0   null<1>:ud    r21.0<1;1,0>:ud   0x4:uw             
(~f1.0) goto (8|M0)                          L4920                  L4920                
L4888:
        mov (8|M0)               r32.0<1>:d    1:w                              
        goto (8|M0)                          L4920                  L5000                
L4920:
        join (8|M0)                          L5000                                
L4936:
        and (8|M0)    (ne)f0.1   null<1>:d     r108.0<1;1,0>:d   1:w              
(W)     mov (1|M0)               r6.14<1>:hf   0x1:hf                             
(f0.1)  cmp (8|M0)    (eq)f0.1   null<1>:d     r21.0<1;1,0>:d    4:w              
(f0.1)  sel (8|M0)               r32.0<1>:d    r6.14<0;1,0>:w    0:w               {F@1}
L5000:
        join (8|M0)                          L5224                                
L5016:
        add (8|M0)               r31.0<1>:d    r108.0<1;1,0>:d   r32.0<1;1,0>:d   {Compacted,I@2}
        cmp (8|M0)    (eq)f0.1   r60.0<1>:d    r31.0<1;1,0>:d    8388608:d               {I@1}
        cmp (8|M0)    (eq)f1.1   null<1>:d     r31.0<1;1,0>:d    8388608:d              
        add3 (8|M0)              r15.0<1>:d    r103.0<1;0>:d     -r60.0<1;0>:d     0:w               {I@2}
        cmp (8|M0)    (eq)f0.1   null<1>:d     r15.0<1;1,0>:d    255:w               {I@1}
(f0.1)  goto (8|M0)                          L5176                  L5176                
L5104:
(~f1.1) sel (8|M0)               r25.0<1>:d    r31.0<1;1,0>:d    0:w              
        and (8|M0)               r13.0<1>:d    r18.0<1;1,0>:d    -2147483648:d              
        shl (8|M0)               r59.0<1>:d    r15.0<1;1,0>:d    23:w               {Compacted}
        bfn.0xFE (8|M0)          r7.0<1>:ud    r13.0<1;0>:ud     r59.0<1;0>:ud     r25.0<1>:ud      {I@1} // s0|s1|s2
        goto (8|M0)                          L5176                  L7384                
L5176:
        join (8|M0)                          L5224                                
L5192:
        bfn.0xEA (8|M0)          r7.0<1>:ud    r6.0<0;0>:ud      r18.0<1;0>:ud     r6.1<0>:ud       // s0|s1&s2
        goto (8|M0)                          L5224                  L7384                
L5224:
        join (8|M0)                          L5280                                
L5240:
        add (8|M0)               r58.0<1>:d    r121.0<1;1,0>:d   r22.0<1;1,0>:d   {Compacted}
        bfn.0xF8 (8|M0)          r7.0<1>:ud    r18.0<1;0>:ud     r6.1<0;0>:ud      r58.0<1>:ud      {I@1} // s0&s1|s2
        goto (8|M0)                          L5280                  L7384                
L5280:
        join (8|M0)                          L7304                                
L5296:
        cmp (8|M0)    (ne)f0.1   null<1>:d     r103.0<1;1,0>:d   0:w              
(f0.1)  sel (8|M0)               r45.0<1>:d    -r103.0<1;1,0>:d  -1:w              
        add (8|M0)               r49.0<1>:d    r112.0<1;1,0>:d   r45.0<1;1,0>:d   {Compacted,I@1}
        cmp (8|M0)    (lt)f0.0   null<1>:d     r49.0<1;1,0>:d    1:w               {Compacted,I@1}
(f0.0)  goto (8|M0)                          L6072                  L6072                
L5360:
        cmp (8|M0)    (eq)f1.1   null<1>:d     r49.0<1;1,0>:d    1:w              
(f1.1)  goto (8|M0)                          L5952                  L5952                
L5392:
        cmp (8|M0)    (lt)f1.0   null<1>:ud    r49.0<1;1,0>:ud   0x18:uw             
(f1.0)  goto (8|M0)                          L5688                  L5688                
L5424:
        cmp (8|M0)    (ne)f1.1   r57.0<1>:d    r103.0<1;1,0>:d   0:w              
        cmp (8|M0)    (lt)f0.0   null<1>:d     r49.0<1;1,0>:d    25:w               {Compacted}
        mov (8|M0)               r126.0<1>:d   -r57.0<1;1,0>:d                  {I@2}
(f0.0)  goto (8|M0)                          L5584                  L5584                
L5480:
        cmp (8|M0)    (eq)f1.1   null<1>:d     r49.0<1;1,0>:d    25:w              
(~f1.1) goto (8|M0)                          L5584                  L6120                
L5512:
        cmp (8|M0)    (ne)f1.0   r81.0<1>:d    r121.0<1;1,0>:d   0:w              
        mov (8|M0)               r69.0<1>:f    r126.0<1;1,0>:f                  {Compacted,I@5}
        mov (8|M0)               r91.0<1>:d    0:w                              
        mov (8|M0)               r126.0<1>:d   0:w                               {F@1}
        goto (8|M0)                          L5584                  L6200                
L5584:
        join (8|M0)                          L5688                                
L5600:
        shr (8|M0)               r56.0<1>:ud   r18.0<1;1,0>:ud   22:w              
        and (8|M0)               r55.0<1>:d    r18.0<1;1,0>:d    4194303:d              
        mov (8|M0)               r91.0<1>:d    0:w                              
        and (8|M0)               r69.0<1>:d    r56.0<1;1,0>:d    1:w               {Compacted,I@3}
        cmp (8|M0)    (ne)f0.1   r81.0<1>:d    r55.0<1;1,0>:d    0:w               {I@3}
        goto (8|M0)                          L5688                  L6200                
L5688:
        join (8|M0)                          L5952                                
L5704:
        add3 (8|M0)              acc0.0<1>:d   r112.0<1;0>:d     r45.0<1;0>:d      -2:w              
(W)     mov (1|M0)               r6.14<1>:hf   -qnan(0x1FF):hf                             
        add3 (8|M0)              acc2.0<1>:d   r112.0<1;0>:d     r45.0<1;0>:d      -1:w              
        add3 (8|M0)              r80.0<1>:d    23:w                -r112.0<1;0>:d    -r45.0<1>:d     
        shr (8|M0)               r54.0<1>:ud   r121.0<1;1,0>:ud  acc0.0<1;1,0>:d 
        shl (8|M0)               r36.0<1>:d    r6.14<0;1,0>:w    acc0.0<1;1,0>:d  {F@1}
(W)     mov (1|M0)               r6.14<1>:hf   0x1:hf                              {I@1}
        shr (8|M0)               r48.0<1>:ud   r121.0<1;1,0>:ud  r49.0<1;1,0>:d  
        shr (8|M0)               r47.0<1>:ud   r121.0<1;1,0>:ud  acc2.0<1;1,0>:d 
        bfn.0x60 (8|M0)          r57.0<1>:ud   r36.0<1;0>:ud     r6.6<0;0>:ud      r121.0<1>:ud     // (s0^s1)&s2
        shl (8|M0)               r80.0<1>:d    r6.14<0;1,0>:w    r80.0<1;1,0>:d   {F@1}
(~f0.1) mov (8|M0)               r80.0<1>:d    0:w                              
        and (8|M0)               r69.0<1>:d    r54.0<1;1,0>:d    1:w               {Compacted}
        and (8|M0)               r126.0<1>:d   r47.0<1;1,0>:d    1:w               {Compacted,I@5}
        cmp (8|M0)    (ne)f0.0   r81.0<1>:d    r57.0<1;1,0>:d    0:w               {I@5}
        or (8|M0)                r91.0<1>:d    r48.0<1;1,0>:d    r80.0<1;1,0>:d   {Compacted,I@4}
        goto (8|M0)                          L5952                  L6200                
L5952:
        join (8|M0)                          L6072                                
L5968:
        shr (8|M0)               r23.0<1>:ud   r121.0<1;1,0>:ud  1:w              
        and (8|M0)               r126.0<1>:d   r18.0<1;1,0>:d    1:w               {Compacted}
        or (8|M0)                r53.0<1>:d    r23.0<1;1,0>:d    4194304:d               {I@2}
        mov (8|M0)               r69.0<1>:d    0:w                              
        mov (8|M0)               r81.0<1>:d    0:w                              
(f0.1)  sel (8|M0)               r91.0<1>:d    r53.0<1;1,0>:d    r23.0<1;1,0>:d   {I@3}
        goto (8|M0)                          L6072                  L6200                
L6072:
        join (8|M0)                          L6120                                
L6088:
        cmp (8|M0)    (eq)f1.0   null<1>:d     r49.0<1;1,0>:d    0:w              
(f1.0)  goto (8|M0)                          L6120                  L6408                
L6120:
        join (8|M0)                          L6200                                
L6136:
        cmp (8|M0)    (ne)f1.1   r81.0<1>:d    r18.0<1;1,0>:d    0:w              
        mov (8|M0)               r126.0<1>:d   0:w                              
        mov (8|M0)               r69.0<1>:d    0:w                              
        mov (8|M0)               r91.0<1>:d    0:w                              
L6200:
        join (8|M0)                          L6408                                
L6216:
        add (8|M0)               r107.0<1>:d   r22.0<1;1,0>:d    r91.0<1;1,0>:d   {Compacted,I@2}
        cmp (8|M0)    (ne)f1.0   r36.0<1>:d    r81.0<1;1,0>:d    0:w              
        cmp (8|M0)    (gt)f0.1   null<1>:ud    r107.0<1;1,0>:ud  0x7FFFFF:ud              {I@2}
        mov (8|M0)               r97.0<1>:d    -r36.0<1;1,0>:d                  {I@2}
(f0.1)  goto (8|M0)                          L6320                  L6320                
L6288:
        mov (8|M0)               r27.0<1>:d    r69.0<1;1,0>:d                  
        goto (8|M0)                          L6320                  L6816                
L6320:
        join (8|M0)                          L6408                                
L6336:
        cmp (8|M0)    (eq)f0.0   null<1>:d     r69.0<1;1,0>:d    1:w               {Compacted}
        shr (8|M0)               r52.0<1>:ud   r107.0<1;1,0>:ud  1:w              
        and (8|M0)               r27.0<1>:d    r52.0<1;1,0>:d    4194303:d               {I@1}
(~f0.0) sel (8|M0)               r97.0<1>:d    -r36.0<1;1,0>:d   1:w              
        goto (8|M0)                          L6408                  L6752                
L6408:
        join (8|M0)                          L6752                                
L6424:
        add (8|M0)               r107.0<1>:d   r22.0<1;1,0>:d    r121.0<1;1,0>:d  {Compacted}
        cmp (8|M0)    (gt)f1.1   null<1>:ud    r107.0<1;1,0>:ud  0x7FFFFF:ud              {I@1}
(f1.1)  goto (8|M0)                          L6640                  L6640                
L6464:
(f0.1)  goto (8|M0)                          L6544                  L6544                
L6480:
        mov (8|M0)               r126.0<1>:d   0:w                              
        mov (8|M0)               r27.0<1>:d    0:w                              
        mov (8|M0)               r97.0<1>:d    0:w                              
        goto (8|M0)                          L6544                  L6816                
L6544:
        join (8|M0)                          L6640                                
L6560:
        and (8|M0)               r126.0<1>:d   r107.0<1;1,0>:d   1:w               {Compacted}
        add (8|M0)               r112.0<1>:d   r112.0<1;1,0>:d   1:w               {Compacted}
        mov (8|M0)               r27.0<1>:d    0:w                              
        mov (8|M0)               r97.0<1>:d    0:w                              
        shr (8|M0)               r107.0<1>:ud  r107.0<1;1,0>:ud  1:w              
        goto (8|M0)                          L6640                  L6816                
L6640:
        join (8|M0)                          L6752                                
L6656:
        shr (8|M0)               r21.0<1>:ud   r107.0<1;1,0>:ud  1:w               {I@3}
        mov (8|M0)               r97.0<1>:d    0:w                              
        and (8|M0)               r24.0<1>:d    r21.0<1;1,0>:d    4194303:d               {I@2}
        or (8|M0)                r21.0<1>:d    r21.0<1;1,0>:d    4194304:d              
        mov (8|M0)               r126.0<1>:d   0:w                              
(f0.1)  sel (8|M0)               r27.0<1>:d    r21.0<1;1,0>:d    r24.0<1;1,0>:d   {I@2}
L6752:
        join (8|M0)                          L6816                                
L6768:
        and (8|M0)               acc0.0<1>:d   r107.0<1;1,0>:d   1:w               {Compacted}
        add (8|M0)               r112.0<1>:d   r112.0<1;1,0>:d   1:w               {Compacted}
        mov (8|M0)               r107.0<1>:f   r27.0<1;1,0>:f                   {Compacted,A@2}
        mov (8|M0)               r27.0<1>:f    r126.0<1;1,0>:f                  {Compacted}
        mov (8|M0)               r126.0<1>:d   acc0.0<1;1,0>:d                  {F@1}
L6816:
        join (8|M0)                          L7304                                
L6832:
        shl (8|M0)               r36.0<1>:d    r126.0<1;1,0>:d   2:w               {Compacted,I@2}
        shl (8|M0)               r51.0<1>:d    r27.0<1;1,0>:d    1:w               {Compacted}
        bfn.0xFE (8|M0)          r20.0<1>:ud   r36.0<1;0>:ud     r51.0<1;0>:ud     r97.0<1>:ud      {I@1} // s0|s1|s2
        cmp (8|M0)    (eq)f1.0   null<1>:d     r20.0<1;1,0>:d    0:w               {I@1}
(~f1.0) goto (8|M0)                          L6928                  L6928                
L6896:
        mov (8|M0)               r30.0<1>:d    0:w                              
        goto (8|M0)                          L6928                  L7088                
L6928:
        join (8|M0)                          L7088                                
L6944:
        cmp (8|M0)    (gt)f0.1   null<1>:ud    r20.0<1;1,0>:ud   0x4:uw             
(~f0.1) goto (8|M0)                          L7008                  L7008                
L6976:
        mov (8|M0)               r30.0<1>:d    1:w                              
        goto (8|M0)                          L7008                  L7088                
L7008:
        join (8|M0)                          L7088                                
L7024:
        and (8|M0)    (ne)f0.0   null<1>:d     r107.0<1;1,0>:d   1:w              
(W)     mov (1|M0)               r6.14<1>:hf   0x1:hf                             
(f0.0)  cmp (8|M0)    (eq)f0.0   null<1>:d     r20.0<1;1,0>:d    4:w              
(f0.0)  sel (8|M0)               r30.0<1>:d    r6.14<0;1,0>:w    0:w               {F@1}
L7088:
        join (8|M0)                          L7304                                
L7104:
        add (8|M0)               r29.0<1>:d    r107.0<1;1,0>:d   r30.0<1;1,0>:d   {Compacted,I@2}
        cmp (8|M0)    (eq)f0.0   r50.0<1>:d    r29.0<1;1,0>:d    8388608:d               {I@1}
        cmp (8|M0)    (eq)f1.0   null<1>:d     r29.0<1;1,0>:d    8388608:d              
        add3 (8|M0)              r13.0<1>:d    r112.0<1;0>:d     -r50.0<1;0>:d     0:w               {I@2}
        cmp (8|M0)    (eq)f0.0   null<1>:d     r13.0<1;1,0>:d    255:w               {Compacted,I@1}
(f0.0)  goto (8|M0)                          L7256                  L7256                
L7184:
(~f1.0) sel (8|M0)               r23.0<1>:d    r29.0<1;1,0>:d    0:w              
        and (8|M0)               r7.0<1>:d     r7.0<1;1,0>:d     -2147483648:d              
        shl (8|M0)               r49.0<1>:d    r13.0<1;1,0>:d    23:w               {Compacted}
        bfn.0xFE (8|M0)          r7.0<1>:ud    r7.0<1;0>:ud      r49.0<1;0>:ud     r23.0<1>:ud      {I@1} // s0|s1|s2
        goto (8|M0)                          L7256                  L7384                
L7256:
        join (8|M0)                          L7304                                
L7272:
        bfn.0xEA (8|M0)          r7.0<1>:ud    r6.0<0;0>:ud      r7.0<1;0>:ud      r6.1<0>:ud       {I@3} // s0|s1&s2
        goto (8|M0)                          L7304                  L7384                
L7304:
        join (8|M0)                          L7384                                
L7320:
        cmp (8|M0)    (ne)f0.1   null<1>:d     r60.0<1;1,0>:d    r59.0<1;1,0>:d  
(f0.1)  cmp (8|M0)    (eq)f0.1   null<1>:d     r121.0<1;1,0>:d   0:w              
(f0.1)  cmp (8|M0)    (eq)f0.1   null<1>:d     r103.0<1;1,0>:d   255:w              
(f0.1)  mov (8|M0)               r7.0<1>:f     qnan(0x0):f                               {I@6}
L7384:
        join (8|M0)                          L36744                                
L7400:
        shr (8|M0)               r47.0<1>:ud   r7.0<1;1,0>:ud    23:w               {F@1}
        and (8|M0)    (ne)f1.1   r20.0<1>:d    r7.0<1;1,0>:d     8388607:d              
        and (8|M0)               r111.0<1>:d   r47.0<1;1,0>:d    255:w               {Compacted,I@2}
        shl (8|M0)               r48.0<1>:d    r14.0<1;1,0>:d    2:w               {Compacted}
(f1.1)  cmp (8|M0)    (eq)f1.1   null<1>:d     r111.0<1;1,0>:d   255:w               {I@2}
        add (8|M0)               r13.0<1>:d    r48.0<1;1,0>:d    r6.2<0;1,0>:d    {Compacted,I@2}
(~f1.1) goto (8|M0)                          L7512                  L7512                
L7488:
        mov (8|M0)               r7.0<1>:f     qnan(0x0):f                               {Compacted}
        goto (8|M0)                          L7512                  L12632                
L7512:
        join (8|M0)                          L12632                                
L7528:
(W)     mov (1|M0)               r6.2<1>:d     1:w                              
(W)     mov (1|M0)               a0.0<1>:ud    r6.4<0;1,0>:d                    {A@1}
        bfn.0xFE (8|M0)          r50.0<1>:ud   r11.0<1;0>:ud     r10.0<1;0>:ud     r6.2<0>:ud       {I@2} // s0|s1|s2
(W)     mul (8|M0)               acc0.0<1>:d   r50.0<1;1,0>:d    r5.4<0;1,0>:uw   {Compacted,I@1}
        mach (8|M0)              r50.0<1>:d    r50.0<1;1,0>:d    r5.2<0;1,0>:d    {Compacted}
        shl (8|M0)               r50.0<1>:d    r50.0<1;1,0>:d    2:w               {Compacted,I@1}
        add3 (8|M0)              r114.0<1>:d   r13.0<1;0>:d      r50.0<1;0>:d      r12.0<1>:d       {I@1}
        send.ugm (8|M0)          r17      r114    null:0  a0.0        0x22180500           {ExBSO,A@1,$8} // wr:1+0, rd:1; load.ugm.d32.a32.ca.ca.bss[a0.0]
        shr (8|M0)               r46.0<1>:ud   r17.0<1;1,0>:ud   23:w               {$8.dst}
        and (8|M0)    (ne)f1.0   r120.0<1>:d   r17.0<1;1,0>:d    8388607:d              
        and (8|M0)               r100.0<1>:d   r46.0<1;1,0>:d    255:w               {Compacted,I@2}
(f1.0)  cmp (8|M0)    (eq)f1.0   null<1>:d     r100.0<1;1,0>:d   255:w               {I@1}
(~f1.0) goto (8|M0)                          L7728                  L7728                
L7704:
        mov (8|M0)               r7.0<1>:f     qnan(0x0):f                               {Compacted}
        goto (8|M0)                          L7728                  L12632                
L7728:
        join (8|M0)                          L12632                                
L7744:
        cmp (8|M0)    (eq)f0.0   null<1>:d     r20.0<1;1,0>:d    0:w               {Compacted}
        shr (8|M0)               r58.0<1>:ud   r7.0<1;1,0>:ud    31:w               {F@1}
        shr (8|M0)               r57.0<1>:ud   r17.0<1;1,0>:ud   31:w              
        cmp (8|M0)    (eq)f0.1   null<1>:d     r120.0<1;1,0>:d   0:w              
(f0.0)  cmp (8|M0)    (eq)f0.0   null<1>:d     r111.0<1;1,0>:d   255:w              
(f0.0)  goto (8|M0)                          L12552                  L12552                
L7832:
        cmp (8|M0)    (eq)f1.1   null<1>:d     r100.0<1;1,0>:d   255:w              
(W)     mov (1|M0)               r6.4<1>:hf    0x1:hf                             
        or (8|M0)                r45.0<1>:d    r111.0<1;1,0>:d   r20.0<1;1,0>:d   {Compacted}
(f0.1)  sel (8|M0)               r4.0<1>:uw    r6.4<0;1,0>:uw    0x0:uw              {F@1}
(f1.1)  sel (8|M0)               r14.0<1>:uw   r6.4<0;1,0>:uw    0x0:uw             
        and (8|M0)    (ne)f0.1   null<1>:uw    r14.0<1;1,0>:uw   r4.0<1;1,0>:uw   {I@1}
(~f0.1) cmp (8|M0)    (eq)f0.1   null<1>:d     r45.0<1;1,0>:d    0:w              
(~f0.1) goto (8|M0)                          L7976                  L7976                
L7952:
        mov (8|M0)               r7.0<1>:f     r17.0<1;1,0>:f                   {Compacted}
        goto (8|M0)                          L7976                  L12632                
L7976:
        join (8|M0)                          L12552                                
L7992:
        or (8|M0)     (eq)f1.1   null<1>:d     r100.0<1;1,0>:d   r120.0<1;1,0>:d 
(f1.1)  goto (8|M0)                          L12552                  L12632                
L8024:
        cmp (8|M0)    (eq)f1.0   null<1>:d     r58.0<1;1,0>:d    r57.0<1;1,0>:d  
        cmp (8|M0)    (lt)f0.0   null<1>:ud    r100.0<1;1,0>:ud  r111.0<1;1,0>:ud
(f1.0)  goto (8|M0)                          L8280                  L8280                
L8072:
(f0.0)  goto (8|M0)                          L8176                  L8176                
L8088:
        mov (8|M0)               r16.0<1>:f    r17.0<1;1,0>:f                   {Compacted}
        mov (8|M0)               r109.0<1>:f   r7.0<1;1,0>:f                    {Compacted,F@2}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        call (8|M0)              r4.0          L36848                                 {A@1}
L8152:
        mov (8|M0)               r7.0<1>:f     r57.0<1;1,0>:f                   {Compacted}
        goto (8|M0)                          L8176                  L12632                
L8176:
        join (8|M0)                          L8280                                
L8192:
        mov (8|M0)               r16.0<1>:f    r7.0<1;1,0>:f                    {Compacted,F@1}
        mov (8|M0)               r109.0<1>:f   r17.0<1;1,0>:f                   {Compacted}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        call (8|M0)              r4.0          L36848                                 {A@1}
L8256:
        mov (8|M0)               r7.0<1>:f     r57.0<1;1,0>:f                   {Compacted}
        goto (8|M0)                          L8280                  L12632                
L8280:
        join (8|M0)                          L12552                                
L8296:
(f0.0)  goto (8|M0)                          L10512                  L10512                
L8312:
        cmp (8|M0)    (eq)f0.0   null<1>:d     r111.0<1;1,0>:d   0:w               {Compacted}
(f0.0)  goto (8|M0)                          L8392                  L8392                
L8336:
(W)     mov (1|M0)               r6.8<2>:b     1:w                              
        add (8|M0)               r115.0<1>:d   r100.0<1;1,0>:d   -r111.0<1;1,0>:d {Compacted}
        mov (8|M0)               r4.0<1>:b     r6.8<0;1,0>:b                    {I@2}
        goto (8|M0)                          L8392                  L8480                
L8392:
        join (8|M0)                          L8480                                
L8408:
        cmp (8|M0)    (eq)f0.1   null<1>:d     r100.0<1;1,0>:d   0:w              
(f0.1)  goto (8|M0)                          L8480                  L10456                
L8440:
(W)     mov (1|M0)               r6.8<2>:b     0:w                              
        add (8|M0)               r115.0<1>:d   r100.0<1;1,0>:d   -1:w               {Compacted}
        mov (8|M0)               r4.0<1>:b     r6.8<0;1,0>:b                    {I@2}
L8480:
        join (8|M0)                          L10456                                
L8496:
        cmp (8|M0)    (lt)f1.1   null<1>:d     r115.0<1;1,0>:d   1:w               {I@3}
(f1.1)  goto (8|M0)                          L9208                  L9208                
L8528:
        cmp (8|M0)    (eq)f1.0   null<1>:d     r115.0<1;1,0>:d   1:w              
(f1.0)  goto (8|M0)                          L9088                  L9088                
L8560:
        cmp (8|M0)    (lt)f0.1   null<1>:ud    r115.0<1;1,0>:ud  0x18:uw             
(f0.1)  goto (8|M0)                          L8848                  L8848                
L8592:
        cmp (8|M0)    (lt)f1.1   null<1>:d     r115.0<1;1,0>:d   25:w              
        mov (8|M0)               r123.0<1>:d   r4.0<1;1,0>:ub                   {I@7}
(f1.1)  goto (8|M0)                          L8744                  L8744                
L8640:
        cmp (8|M0)    (eq)f1.0   null<1>:d     r115.0<1;1,0>:d   25:w              
(~f1.0) goto (8|M0)                          L8744                  L9256                
L8672:
        cmp (8|M0)    (ne)f0.1   r76.0<1>:d    r20.0<1;1,0>:d    0:w              
        mov (8|M0)               r59.0<1>:f    r123.0<1;1,0>:f                  {Compacted,I@5}
        mov (8|M0)               r87.0<1>:d    0:w                              
        mov (8|M0)               r123.0<1>:d   0:w                               {F@1}
        goto (8|M0)                          L8744                  L9336                
L8744:
        join (8|M0)                          L8848                                
L8760:
        shr (8|M0)               r44.0<1>:ud   r7.0<1;1,0>:ud    22:w              
        and (8|M0)               r43.0<1>:d    r7.0<1;1,0>:d     4194303:d              
        mov (8|M0)               r87.0<1>:d    0:w                              
        and (8|M0)               r59.0<1>:d    r44.0<1;1,0>:d    1:w               {Compacted,I@3}
        cmp (8|M0)    (ne)f0.0   r76.0<1>:d    r43.0<1;1,0>:d    0:w               {I@3}
        goto (8|M0)                          L8848                  L9336                
L8848:
        join (8|M0)                          L9088                                
L8864:
        add (8|M0)               acc0.0<1>:d   r115.0<1;1,0>:d   -2:w               {Compacted}
(W)     mov (1|M0)               r6.4<1>:hf    -qnan(0x1FF):hf                             
        add (8|M0)               acc2.0<1>:d   r115.0<1;1,0>:d   -1:w               {Compacted}
        add (8|M0)               r75.0<1>:d    -r115.0<1;1,0>:d  23:w               {Compacted}
        shr (8|M0)               r42.0<1>:ud   r20.0<1;1,0>:ud   acc0.0<1;1,0>:d 
        shl (8|M0)               r29.0<1>:d    r6.4<0;1,0>:w     acc0.0<1;1,0>:d  {F@1}
(W)     mov (1|M0)               r6.4<1>:hf    0x1:hf                              {I@1}
        shr (8|M0)               r46.0<1>:ud   r20.0<1;1,0>:ud   r115.0<1;1,0>:d 
        shr (8|M0)               r28.0<1>:ud   r20.0<1;1,0>:ud   acc2.0<1;1,0>:d 
        bfn.0x60 (8|M0)          r50.0<1>:ud   r29.0<1;0>:ud     r6.6<0;0>:ud      r20.0<1>:ud      // (s0^s1)&s2
        shl (8|M0)               r75.0<1>:d    r6.4<0;1,0>:w     r75.0<1;1,0>:d   {F@1}
(f0.0)  mov (8|M0)               r75.0<1>:d    0:w                              
        and (8|M0)               r59.0<1>:d    r42.0<1;1,0>:d    1:w               {Compacted}
        and (8|M0)               r123.0<1>:d   r28.0<1;1,0>:d    1:w               {Compacted,I@5}
        cmp (8|M0)    (ne)f1.1   r76.0<1>:d    r50.0<1;1,0>:d    0:w               {I@5}
        or (8|M0)                r87.0<1>:d    r46.0<1;1,0>:d    r75.0<1;1,0>:d   {Compacted,I@4}
        goto (8|M0)                          L9088                  L9336                
L9088:
        join (8|M0)                          L9208                                
L9104:
        and (8|M0)               r123.0<1>:d   r7.0<1;1,0>:d     1:w               {Compacted}
        shr (8|M0)               r7.0<1>:ud    r20.0<1;1,0>:ud   1:w              
        mov (8|M0)               r59.0<1>:d    0:w                              
        or (8|M0)                r41.0<1>:d    r7.0<1;1,0>:d     4194304:d               {I@2}
        mov (8|M0)               r76.0<1>:d    0:w                              
(f0.0)  sel (8|M0)               r87.0<1>:d    r7.0<1;1,0>:d     r41.0<1;1,0>:d   {I@2}
        goto (8|M0)                          L9208                  L9336                
L9208:
        join (8|M0)                          L9256                                
L9224:
        cmp (8|M0)    (eq)f0.1   null<1>:d     r115.0<1;1,0>:d   0:w              
(f0.1)  goto (8|M0)                          L9256                  L9552                
L9256:
        join (8|M0)                          L9336                                
L9272:
        cmp (8|M0)    (ne)f1.0   r76.0<1>:d    r7.0<1;1,0>:d     0:w              
        mov (8|M0)               r123.0<1>:d   0:w                              
        mov (8|M0)               r59.0<1>:d    0:w                              
        mov (8|M0)               r87.0<1>:d    0:w                              
L9336:
        join (8|M0)                          L9552                                
L9352:
        add (8|M0)               r106.0<1>:d   r120.0<1;1,0>:d   r87.0<1;1,0>:d   {Compacted,I@2}
        cmp (8|M0)    (ne)f0.1   r33.0<1>:d    r76.0<1;1,0>:d    0:w              
        cmp (8|M0)    (gt)f0.0   null<1>:ud    r106.0<1;1,0>:ud  0x7FFFFF:ud              {I@2}
        mov (8|M0)               r96.0<1>:d    -r33.0<1;1,0>:d                  {I@2}
(f0.0)  goto (8|M0)                          L9456                  L9456                
L9424:
        mov (8|M0)               r24.0<1>:d    r59.0<1;1,0>:d                  
        goto (8|M0)                          L9456                  L9960                
L9456:
        join (8|M0)                          L9552                                
L9472:
        cmp (8|M0)    (eq)f1.1   null<1>:d     r59.0<1;1,0>:d    1:w              
        shr (8|M0)               r40.0<1>:ud   r106.0<1;1,0>:ud  1:w              
        and (8|M0)               r21.0<1>:d    r40.0<1;1,0>:d    4194303:d               {I@1}
(~f1.1) sel (8|M0)               r96.0<1>:d    -r33.0<1;1,0>:d   1:w              
        goto (8|M0)                          L9552                  L9896                
L9552:
        join (8|M0)                          L9896                                
L9568:
        add (8|M0)               r106.0<1>:d   r120.0<1;1,0>:d   r20.0<1;1,0>:d   {Compacted}
        cmp (8|M0)    (gt)f1.0   null<1>:ud    r106.0<1;1,0>:ud  0x7FFFFF:ud              {I@1}
(f1.0)  goto (8|M0)                          L9784                  L9784                
L9608:
(~f0.0) goto (8|M0)                          L9688                  L9688                
L9624:
        mov (8|M0)               r123.0<1>:d   0:w                              
        mov (8|M0)               r24.0<1>:d    0:w                              
        mov (8|M0)               r96.0<1>:d    0:w                              
        goto (8|M0)                          L9688                  L9960                
L9688:
        join (8|M0)                          L9784                                
L9704:
        and (8|M0)               r123.0<1>:d   r106.0<1;1,0>:d   1:w               {Compacted}
        add (8|M0)               r100.0<1>:d   r100.0<1;1,0>:d   1:w               {Compacted}
        mov (8|M0)               r24.0<1>:d    0:w                              
        mov (8|M0)               r96.0<1>:d    0:w                              
        shr (8|M0)               r106.0<1>:ud  r106.0<1;1,0>:ud  1:w              
        goto (8|M0)                          L9784                  L9960                
L9784:
        join (8|M0)                          L9896                                
L9800:
        shr (8|M0)               r18.0<1>:ud   r106.0<1;1,0>:ud  1:w               {I@3}
        mov (8|M0)               r96.0<1>:d    0:w                              
        and (8|M0)               r4.0<1>:d     r18.0<1;1,0>:d    4194303:d               {I@2}
        or (8|M0)                r18.0<1>:d    r18.0<1;1,0>:d    4194304:d              
        mov (8|M0)               r123.0<1>:d   0:w                              
(f0.0)  sel (8|M0)               r21.0<1>:d    r4.0<1;1,0>:d     r18.0<1;1,0>:d   {I@2}
L9896:
        join (8|M0)                          L9960                                
L9912:
        and (8|M0)               acc0.0<1>:d   r106.0<1;1,0>:d   1:w               {Compacted}
        add (8|M0)               r100.0<1>:d   r100.0<1;1,0>:d   1:w               {Compacted}
        mov (8|M0)               r24.0<1>:f    r123.0<1;1,0>:f                  {Compacted,I@5}
        mov (8|M0)               r106.0<1>:f   r21.0<1;1,0>:f                   {Compacted,A@2}
        mov (8|M0)               r123.0<1>:d   acc0.0<1;1,0>:d                  {F@2}
L9960:
        join (8|M0)                          L10456                                
L9976:
        shl (8|M0)               r31.0<1>:d    r123.0<1;1,0>:d   2:w               {Compacted,I@2}
        shl (8|M0)               r39.0<1>:d    r24.0<1;1,0>:d    1:w               {Compacted}
        bfn.0xFE (8|M0)          r125.0<1>:ud  r31.0<1;0>:ud     r39.0<1;0>:ud     r96.0<1>:ud      {I@1} // s0|s1|s2
        cmp (8|M0)    (eq)f0.1   null<1>:d     r125.0<1;1,0>:d   0:w               {I@1}
(~f0.1) goto (8|M0)                          L10072                  L10072                
L10040:
        mov (8|M0)               r19.0<1>:d    0:w                              
        goto (8|M0)                          L10072                  L10232                
L10072:
        join (8|M0)                          L10232                                
L10088:
        cmp (8|M0)    (gt)f0.0   null<1>:ud    r125.0<1;1,0>:ud  0x4:uw             
(~f0.0) goto (8|M0)                          L10152                  L10152                
L10120:
        mov (8|M0)               r19.0<1>:d    1:w                              
        goto (8|M0)                          L10152                  L10232                
L10152:
        join (8|M0)                          L10232                                
L10168:
        and (8|M0)    (ne)f0.0   null<1>:d     r106.0<1;1,0>:d   1:w               {F@1}
(W)     mov (1|M0)               r6.4<1>:hf    0x1:hf                             
(f0.0)  cmp (8|M0)    (eq)f0.0   null<1>:d     r125.0<1;1,0>:d   4:w              
(f0.0)  sel (8|M0)               r19.0<1>:d    r6.4<0;1,0>:w     0:w               {F@1}
L10232:
        join (8|M0)                          L10456                                
L10248:
        add (8|M0)               r18.0<1>:d    r106.0<1;1,0>:d   r19.0<1;1,0>:d   {Compacted,I@2}
        cmp (8|M0)    (eq)f1.1   r38.0<1>:d    r18.0<1;1,0>:d    8388608:d               {I@1}
        cmp (8|M0)    (eq)f1.0   null<1>:d     r18.0<1;1,0>:d    8388608:d              
        add3 (8|M0)              r126.0<1>:d   r100.0<1;0>:d     -r38.0<1;0>:d     0:w               {I@2}
        cmp (8|M0)    (eq)f1.1   null<1>:d     r126.0<1;1,0>:d   255:w               {I@1}
(f1.1)  goto (8|M0)                          L10408                  L10408                
L10336:
(~f1.0) sel (8|M0)               r127.0<1>:d   r18.0<1;1,0>:d    0:w              
        and (8|M0)               r113.0<1>:d   r17.0<1;1,0>:d    -2147483648:d              
        shl (8|M0)               r37.0<1>:d    r126.0<1;1,0>:d   23:w               {Compacted}
        bfn.0xFE (8|M0)          r7.0<1>:ud    r113.0<1;0>:ud    r37.0<1;0>:ud     r127.0<1>:ud     {I@1} // s0|s1|s2
        goto (8|M0)                          L10408                  L12632                
L10408:
        join (8|M0)                          L10456                                
L10424:
        bfn.0xEA (8|M0)          r7.0<1>:ud    r6.0<0;0>:ud      r17.0<1;0>:ud     r6.1<0>:ud       // s0|s1&s2
        goto (8|M0)                          L10456                  L12632                
L10456:
        join (8|M0)                          L10512                                
L10472:
        add (8|M0)               r36.0<1>:d    r120.0<1;1,0>:d   r20.0<1;1,0>:d   {Compacted}
        bfn.0xF8 (8|M0)          r7.0<1>:ud    r17.0<1;0>:ud     r6.1<0;0>:ud      r36.0<1>:ud      {I@1} // s0&s1|s2
        goto (8|M0)                          L10512                  L12632                
L10512:
        join (8|M0)                          L12552                                
L10528:
        cmp (8|M0)    (ne)f1.1   null<1>:d     r100.0<1;1,0>:d   0:w              
(f1.1)  sel (8|M0)               r44.0<1>:d    -r100.0<1;1,0>:d  -1:w              
        add (8|M0)               r42.0<1>:d    r111.0<1;1,0>:d   r44.0<1;1,0>:d   {Compacted,I@1}
        cmp (8|M0)    (lt)f1.0   null<1>:d     r42.0<1;1,0>:d    1:w               {I@1}
(f1.0)  goto (8|M0)                          L11320                  L11320                
L10600:
        cmp (8|M0)    (eq)f0.1   null<1>:d     r42.0<1;1,0>:d    1:w              
(f0.1)  goto (8|M0)                          L11200                  L11200                
L10632:
        cmp (8|M0)    (lt)f0.0   null<1>:ud    r42.0<1;1,0>:ud   0x18:uw             
(f0.0)  goto (8|M0)                          L10936                  L10936                
L10664:
        cmp (8|M0)    (ne)f0.0   r35.0<1>:d    r100.0<1;1,0>:d   0:w              
        cmp (8|M0)    (lt)f1.0   null<1>:d     r42.0<1;1,0>:d    25:w              
        mov (8|M0)               r124.0<1>:d   -r35.0<1;1,0>:d                  {I@2}
(f1.0)  goto (8|M0)                          L10832                  L10832                
L10728:
        cmp (8|M0)    (eq)f0.1   null<1>:d     r42.0<1;1,0>:d    25:w              
(~f0.1) goto (8|M0)                          L10832                  L11360                
L10760:
        cmp (8|M0)    (ne)f1.1   r74.0<1>:d    r120.0<1;1,0>:d   0:w              
        mov (8|M0)               r60.0<1>:f    r124.0<1;1,0>:f                  {Compacted,I@5}
        mov (8|M0)               r86.0<1>:d    0:w                              
        mov (8|M0)               r124.0<1>:d   0:w                               {F@1}
        goto (8|M0)                          L10832                  L11440                
L10832:
        join (8|M0)                          L10936                                
L10848:
        shr (8|M0)               r34.0<1>:ud   r17.0<1;1,0>:ud   22:w              
        and (8|M0)               r33.0<1>:d    r17.0<1;1,0>:d    4194303:d              
        mov (8|M0)               r86.0<1>:d    0:w                              
        and (8|M0)               r60.0<1>:d    r34.0<1;1,0>:d    1:w               {Compacted,I@3}
        cmp (8|M0)    (ne)f1.0   r74.0<1>:d    r33.0<1;1,0>:d    0:w               {I@3}
        goto (8|M0)                          L10936                  L11440                
L10936:
        join (8|M0)                          L11200                                
L10952:
        add3 (8|M0)              acc0.0<1>:d   r111.0<1;0>:d     r44.0<1;0>:d      -2:w              
(W)     mov (1|M0)               r6.4<1>:hf    -qnan(0x1FF):hf                             
        add3 (8|M0)              acc2.0<1>:d   r111.0<1;0>:d     r44.0<1;0>:d      -1:w              
        add3 (8|M0)              r73.0<1>:d    23:w                -r111.0<1;0>:d    -r44.0<1>:d     
        shr (8|M0)               r32.0<1>:ud   r120.0<1;1,0>:ud  acc0.0<1;1,0>:d 
        shl (8|M0)               r33.0<1>:d    r6.4<0;1,0>:w     acc0.0<1;1,0>:d  {F@1}
(W)     mov (1|M0)               r6.4<1>:hf    0x1:hf                              {I@1}
        shr (8|M0)               r45.0<1>:ud   r120.0<1;1,0>:ud  r42.0<1;1,0>:d  
        shr (8|M0)               r41.0<1>:ud   r120.0<1;1,0>:ud  acc2.0<1;1,0>:d 
        bfn.0x60 (8|M0)          r53.0<1>:ud   r33.0<1;0>:ud     r6.6<0;0>:ud      r120.0<1>:ud     // (s0^s1)&s2
        shl (8|M0)               r73.0<1>:d    r6.4<0;1,0>:w     r73.0<1;1,0>:d   {F@1}
(~f1.1) mov (8|M0)               r73.0<1>:d    0:w                              
        and (8|M0)               r60.0<1>:d    r32.0<1;1,0>:d    1:w               {Compacted}
        and (8|M0)               r124.0<1>:d   r41.0<1;1,0>:d    1:w               {Compacted,I@5}
        cmp (8|M0)    (ne)f0.1   r74.0<1>:d    r53.0<1;1,0>:d    0:w               {I@5}
        or (8|M0)                r86.0<1>:d    r45.0<1;1,0>:d    r73.0<1;1,0>:d   {Compacted,I@4}
        goto (8|M0)                          L11200                  L11440                
L11200:
        join (8|M0)                          L11320                                
L11216:
        shr (8|M0)               r4.0<1>:ud    r120.0<1;1,0>:ud  1:w              
        and (8|M0)               r124.0<1>:d   r17.0<1;1,0>:d    1:w               {Compacted}
        or (8|M0)                r31.0<1>:d    r4.0<1;1,0>:d     4194304:d               {I@2}
        mov (8|M0)               r60.0<1>:d    0:w                              
        mov (8|M0)               r74.0<1>:d    0:w                              
(f1.1)  sel (8|M0)               r86.0<1>:d    r31.0<1;1,0>:d    r4.0<1;1,0>:d    {I@3}
        goto (8|M0)                          L11320                  L11440                
L11320:
        join (8|M0)                          L11360                                
L11336:
        cmp (8|M0)    (eq)f0.0   null<1>:d     r42.0<1;1,0>:d    0:w               {Compacted}
(f0.0)  goto (8|M0)                          L11360                  L11656                
L11360:
        join (8|M0)                          L11440                                
L11376:
        cmp (8|M0)    (ne)f0.0   r74.0<1>:d    r17.0<1;1,0>:d    0:w              
        mov (8|M0)               r124.0<1>:d   0:w                              
        mov (8|M0)               r60.0<1>:d    0:w                              
        mov (8|M0)               r86.0<1>:d    0:w                              
L11440:
        join (8|M0)                          L11656                                
L11456:
        add (8|M0)               r105.0<1>:d   r20.0<1;1,0>:d    r86.0<1;1,0>:d   {Compacted,I@2}
        cmp (8|M0)    (ne)f1.1   r32.0<1>:d    r74.0<1;1,0>:d    0:w              
        cmp (8|M0)    (gt)f1.1   null<1>:ud    r105.0<1;1,0>:ud  0x7FFFFF:ud              {I@2}
        mov (8|M0)               r95.0<1>:d    -r32.0<1;1,0>:d                  {I@2}
(f1.1)  goto (8|M0)                          L11560                  L11560                
L11528:
        mov (8|M0)               r23.0<1>:d    r60.0<1;1,0>:d                  
        goto (8|M0)                          L11560                  L12064                
L11560:
        join (8|M0)                          L11656                                
L11576:
        cmp (8|M0)    (eq)f1.0   null<1>:d     r60.0<1;1,0>:d    1:w              
        shr (8|M0)               r30.0<1>:ud   r105.0<1;1,0>:ud  1:w              
        and (8|M0)               r20.0<1>:d    r30.0<1;1,0>:d    4194303:d               {I@1}
(~f1.0) sel (8|M0)               r95.0<1>:d    -r32.0<1;1,0>:d   1:w              
        goto (8|M0)                          L11656                  L12000                
L11656:
        join (8|M0)                          L12000                                
L11672:
        add (8|M0)               r105.0<1>:d   r20.0<1;1,0>:d    r120.0<1;1,0>:d  {Compacted,I@4}
        cmp (8|M0)    (gt)f0.1   null<1>:ud    r105.0<1;1,0>:ud  0x7FFFFF:ud              {I@1}
(f0.1)  goto (8|M0)                          L11888                  L11888                
L11712:
(f1.1)  goto (8|M0)                          L11792                  L11792                
L11728:
        mov (8|M0)               r124.0<1>:d   0:w                              
        mov (8|M0)               r23.0<1>:d    0:w                              
        mov (8|M0)               r95.0<1>:d    0:w                              
        goto (8|M0)                          L11792                  L12064                
L11792:
        join (8|M0)                          L11888                                
L11808:
        and (8|M0)               r124.0<1>:d   r105.0<1;1,0>:d   1:w               {Compacted}
        add (8|M0)               r111.0<1>:d   r111.0<1;1,0>:d   1:w               {Compacted}
        mov (8|M0)               r23.0<1>:d    0:w                              
        mov (8|M0)               r95.0<1>:d    0:w                              
        shr (8|M0)               r105.0<1>:ud  r105.0<1;1,0>:ud  1:w              
        goto (8|M0)                          L11888                  L12064                
L11888:
        join (8|M0)                          L12000                                
L11904:
        shr (8|M0)               r16.0<1>:ud   r105.0<1;1,0>:ud  1:w               {I@3}
        mov (8|M0)               r95.0<1>:d    0:w                              
        and (8|M0)               r125.0<1>:d   r16.0<1;1,0>:d    4194303:d               {I@2}
        or (8|M0)                r16.0<1>:d    r16.0<1;1,0>:d    4194304:d              
        mov (8|M0)               r124.0<1>:d   0:w                              
(f1.1)  sel (8|M0)               r20.0<1>:d    r16.0<1;1,0>:d    r125.0<1;1,0>:d  {I@2}
L12000:
        join (8|M0)                          L12064                                
L12016:
        and (8|M0)               acc0.0<1>:d   r105.0<1;1,0>:d   1:w               {Compacted}
        add (8|M0)               r111.0<1>:d   r111.0<1;1,0>:d   1:w               {Compacted}
        mov (8|M0)               r23.0<1>:f    r124.0<1;1,0>:f                  {Compacted,I@5}
        mov (8|M0)               r105.0<1>:f   r20.0<1;1,0>:f                   {Compacted,A@2}
        mov (8|M0)               r124.0<1>:d   acc0.0<1;1,0>:d                  {F@2}
L12064:
        join (8|M0)                          L12552                                
L12080:
        shl (8|M0)               r30.0<1>:d    r124.0<1;1,0>:d   2:w               {Compacted,I@2}
        shl (8|M0)               r29.0<1>:d    r23.0<1;1,0>:d    1:w               {Compacted}
        bfn.0xFE (8|M0)          r124.0<1>:ud  r30.0<1;0>:ud     r29.0<1;0>:ud     r95.0<1>:ud      {I@1} // s0|s1|s2
        cmp (8|M0)    (eq)f0.0   null<1>:d     r124.0<1;1,0>:d   0:w               {Compacted,I@1}
(~f0.0) goto (8|M0)                          L12168                  L12168                
L12136:
        mov (8|M0)               r16.0<1>:d    0:w                              
        goto (8|M0)                          L12168                  L12328                
L12168:
        join (8|M0)                          L12328                                
L12184:
        cmp (8|M0)    (gt)f1.1   null<1>:ud    r124.0<1;1,0>:ud  0x4:uw             
(~f1.1) goto (8|M0)                          L12248                  L12248                
L12216:
        mov (8|M0)               r16.0<1>:d    1:w                              
        goto (8|M0)                          L12248                  L12328                
L12248:
        join (8|M0)                          L12328                                
L12264:
        and (8|M0)    (ne)f1.1   null<1>:d     r105.0<1;1,0>:d   1:w               {F@1}
(W)     mov (1|M0)               r6.4<1>:hf    0x1:hf                             
(f1.1)  cmp (8|M0)    (eq)f1.1   null<1>:d     r124.0<1;1,0>:d   4:w              
(f1.1)  sel (8|M0)               r16.0<1>:d    r6.4<0;1,0>:w     0:w               {F@1}
L12328:
        join (8|M0)                          L12552                                
L12344:
        add (8|M0)               r15.0<1>:d    r105.0<1;1,0>:d   r16.0<1;1,0>:d   {Compacted,I@2}
        cmp (8|M0)    (eq)f1.0   r28.0<1>:d    r15.0<1;1,0>:d    8388608:d               {I@1}
        cmp (8|M0)    (eq)f0.1   null<1>:d     r15.0<1;1,0>:d    8388608:d              
        add3 (8|M0)              r125.0<1>:d   r111.0<1;0>:d     -r28.0<1;0>:d     0:w               {I@2}
        cmp (8|M0)    (eq)f1.0   null<1>:d     r125.0<1;1,0>:d   255:w               {I@1}
(f1.0)  goto (8|M0)                          L12504                  L12504                
L12432:
(~f0.1) sel (8|M0)               r124.0<1>:d   r15.0<1;1,0>:d    0:w              
        and (8|M0)               r112.0<1>:d   r7.0<1;1,0>:d     -2147483648:d              
        shl (8|M0)               r27.0<1>:d    r125.0<1;1,0>:d   23:w               {Compacted}
        bfn.0xFE (8|M0)          r7.0<1>:ud    r112.0<1;0>:ud    r27.0<1;0>:ud     r124.0<1>:ud     {I@1} // s0|s1|s2
        goto (8|M0)                          L12504                  L12632                
L12504:
        join (8|M0)                          L12552                                
L12520:
        bfn.0xEA (8|M0)          r7.0<1>:ud    r6.0<0;0>:ud      r7.0<1;0>:ud      r6.1<0>:ud       {I@3} // s0|s1&s2
        goto (8|M0)                          L12552                  L12632                
L12552:
        join (8|M0)                          L12632                                
L12568:
        cmp (8|M0)    (ne)f0.0   null<1>:d     r58.0<1;1,0>:d    r57.0<1;1,0>:d  
(f0.0)  cmp (8|M0)    (eq)f0.0   null<1>:d     r120.0<1;1,0>:d   0:w              
(f0.0)  cmp (8|M0)    (eq)f0.0   null<1>:d     r100.0<1;1,0>:d   255:w              
(f0.0)  mov (8|M0)               r7.0<1>:f     qnan(0x0):f                               {I@6}
L12632:
        join (8|M0)                          L36744                                
L12648:
        shr (8|M0)               r26.0<1>:ud   r7.0<1;1,0>:ud    23:w               {F@1}
        and (8|M0)    (ne)f1.0   r19.0<1>:d    r7.0<1;1,0>:d     8388607:d              
        and (8|M0)               r110.0<1>:d   r26.0<1;1,0>:d    255:w               {Compacted,I@2}
(f1.0)  cmp (8|M0)    (eq)f1.0   null<1>:d     r110.0<1;1,0>:d   255:w               {I@1}
(~f1.0) goto (8|M0)                          L12744                  L12744                
L12720:
        mov (8|M0)               r7.0<1>:f     qnan(0x0):f                               {Compacted}
        goto (8|M0)                          L12744                  L17848                
L12744:
        join (8|M0)                          L17848                                
L12760:
(W)     mov (1|M0)               r6.2<1>:d     9:w                              
(W)     mov (1|M0)               a0.0<1>:ud    r6.4<0;1,0>:d                    {A@1}
        bfn.0xFE (8|M0)          r39.0<1>:ud   r11.0<1;0>:ud     r10.0<1;0>:ud     r6.2<0>:ud       {I@2} // s0|s1|s2
(W)     mul (8|M0)               acc0.0<1>:d   r39.0<1;1,0>:d    r5.4<0;1,0>:uw   {Compacted,I@1}
        mach (8|M0)              r39.0<1>:d    r39.0<1;1,0>:d    r5.2<0;1,0>:d    {Compacted}
        shl (8|M0)               r39.0<1>:d    r39.0<1;1,0>:d    2:w               {Compacted,I@1}
        add3 (8|M0)              r94.0<1>:d    r13.0<1;0>:d      r39.0<1;0>:d      r12.0<1>:d       {I@1}
        send.ugm (8|M0)          r127     r94     null:0  a0.0        0x22180500           {ExBSO,A@1,$9} // wr:1+0, rd:1; load.ugm.d32.a32.ca.ca.bss[a0.0]
        shr (8|M0)               r25.0<1>:ud   r127.0<1;1,0>:ud  23:w               {$9.dst}
        and (8|M0)    (ne)f0.1   r118.0<1>:d   r127.0<1;1,0>:d   8388607:d              
        and (8|M0)               r98.0<1>:d    r25.0<1;1,0>:d    255:w               {Compacted,I@2}
(f0.1)  cmp (8|M0)    (eq)f0.1   null<1>:d     r98.0<1;1,0>:d    255:w               {I@1}
(~f0.1) goto (8|M0)                          L12960                  L12960                
L12936:
        mov (8|M0)               r7.0<1>:f     qnan(0x0):f                               {Compacted}
        goto (8|M0)                          L12960                  L17848                
L12960:
        join (8|M0)                          L17848                                
L12976:
        cmp (8|M0)    (eq)f1.1   null<1>:d     r19.0<1;1,0>:d    0:w              
        shr (8|M0)               r54.0<1>:ud   r7.0<1;1,0>:ud    31:w               {F@1}
        shr (8|M0)               r53.0<1>:ud   r127.0<1;1,0>:ud  31:w              
        cmp (8|M0)    (eq)f0.0   null<1>:d     r118.0<1;1,0>:d   0:w               {Compacted}
(f1.1)  cmp (8|M0)    (eq)f1.1   null<1>:d     r110.0<1;1,0>:d   255:w              
(f1.1)  goto (8|M0)                          L17768                  L17768                
L13064:
        cmp (8|M0)    (eq)f1.0   null<1>:d     r98.0<1;1,0>:d    255:w              
(W)     mov (1|M0)               r6.4<1>:hf    0x1:hf                             
        or (8|M0)                r24.0<1>:d    r110.0<1;1,0>:d   r19.0<1;1,0>:d   {Compacted}
(f0.0)  sel (8|M0)               r4.0<1>:uw    r6.4<0;1,0>:uw    0x0:uw              {F@1}
(f1.0)  sel (8|M0)               r10.0<1>:uw   r6.4<0;1,0>:uw    0x0:uw             
        and (8|M0)    (ne)f0.0   null<1>:uw    r10.0<1;1,0>:uw   r4.0<1;1,0>:uw   {I@1}
(~f0.0) cmp (8|M0)    (eq)f0.0   null<1>:d     r24.0<1;1,0>:d    0:w              
(~f0.0) goto (8|M0)                          L13208                  L13208                
L13184:
        mov (8|M0)               r7.0<1>:f     r127.0<1;1,0>:f                  {Compacted}
        goto (8|M0)                          L13208                  L17848                
L13208:
        join (8|M0)                          L17768                                
L13224:
        or (8|M0)     (eq)f0.1   null<1>:d     r98.0<1;1,0>:d    r118.0<1;1,0>:d 
(f0.1)  goto (8|M0)                          L17768                  L17848                
L13256:
        cmp (8|M0)    (eq)f0.0   null<1>:d     r54.0<1;1,0>:d    r53.0<1;1,0>:d  
        cmp (8|M0)    (lt)f1.1   null<1>:ud    r98.0<1;1,0>:ud   r110.0<1;1,0>:ud
(f0.0)  goto (8|M0)                          L13512                  L13512                
L13304:
(f1.1)  goto (8|M0)                          L13408                  L13408                
L13320:
        mov (8|M0)               r16.0<1>:f    r127.0<1;1,0>:f                  {Compacted}
        mov (8|M0)               r109.0<1>:f   r7.0<1;1,0>:f                    {Compacted,F@2}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        call (8|M0)              r4.0          L36848                                 {A@1}
L13384:
        mov (8|M0)               r7.0<1>:f     r57.0<1;1,0>:f                   {Compacted}
        goto (8|M0)                          L13408                  L17848                
L13408:
        join (8|M0)                          L13512                                
L13424:
        mov (8|M0)               r16.0<1>:f    r7.0<1;1,0>:f                    {Compacted,F@1}
        mov (8|M0)               r109.0<1>:f   r127.0<1;1,0>:f                  {Compacted}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        call (8|M0)              r4.0          L36848                                 {A@1}
L13488:
        mov (8|M0)               r7.0<1>:f     r57.0<1;1,0>:f                   {Compacted}
        goto (8|M0)                          L13512                  L17848                
L13512:
        join (8|M0)                          L17768                                
L13528:
(f1.1)  goto (8|M0)                          L15736                  L15736                
L13544:
        cmp (8|M0)    (eq)f1.0   null<1>:d     r110.0<1;1,0>:d   0:w              
(f1.0)  goto (8|M0)                          L13632                  L13632                
L13576:
(W)     mov (1|M0)               r6.8<2>:b     1:w                              
        add (8|M0)               r113.0<1>:d   r98.0<1;1,0>:d    -r110.0<1;1,0>:d {Compacted}
        mov (8|M0)               r4.0<1>:b     r6.8<0;1,0>:b                    {I@2}
        goto (8|M0)                          L13632                  L13720                
L13632:
        join (8|M0)                          L13720                                
L13648:
        cmp (8|M0)    (eq)f1.1   null<1>:d     r98.0<1;1,0>:d    0:w              
(f1.1)  goto (8|M0)                          L13720                  L15680                
L13680:
(W)     mov (1|M0)               r6.8<2>:b     0:w                              
        add (8|M0)               r113.0<1>:d   r98.0<1;1,0>:d    -1:w               {Compacted}
        mov (8|M0)               r4.0<1>:b     r6.8<0;1,0>:b                    {I@2}
L13720:
        join (8|M0)                          L15680                                
L13736:
        cmp (8|M0)    (lt)f0.1   null<1>:d     r113.0<1;1,0>:d   1:w               {I@3}
(f0.1)  goto (8|M0)                          L14432                  L14432                
L13768:
        cmp (8|M0)    (eq)f0.0   null<1>:d     r113.0<1;1,0>:d   1:w               {Compacted}
(f0.0)  goto (8|M0)                          L14312                  L14312                
L13792:
        cmp (8|M0)    (lt)f1.1   null<1>:ud    r113.0<1;1,0>:ud  0x18:uw             
(f1.1)  goto (8|M0)                          L14072                  L14072                
L13824:
        cmp (8|M0)    (lt)f0.1   null<1>:d     r113.0<1;1,0>:d   25:w              
        mov (8|M0)               r117.0<1>:d   r4.0<1;1,0>:ub                   {I@7}
(f0.1)  goto (8|M0)                          L13968                  L13968                
L13872:
        cmp (8|M0)    (eq)f0.0   null<1>:d     r113.0<1;1,0>:d   25:w               {Compacted}
(~f0.0) goto (8|M0)                          L13968                  L14480                
L13896:
        cmp (8|M0)    (ne)f1.0   r67.0<1>:d    r19.0<1;1,0>:d    0:w              
        mov (8|M0)               r54.0<1>:f    r117.0<1;1,0>:f                  {Compacted,I@5}
        mov (8|M0)               r71.0<1>:d    0:w                              
        mov (8|M0)               r117.0<1>:d   0:w                               {F@1}
        goto (8|M0)                          L13968                  L14560                
L13968:
        join (8|M0)                          L14072                                
L13984:
        shr (8|M0)               r23.0<1>:ud   r7.0<1;1,0>:ud    22:w              
        and (8|M0)               r22.0<1>:d    r7.0<1;1,0>:d     4194303:d              
        mov (8|M0)               r71.0<1>:d    0:w                              
        and (8|M0)               r54.0<1>:d    r23.0<1;1,0>:d    1:w               {Compacted,I@3}
        cmp (8|M0)    (ne)f0.1   r67.0<1>:d    r22.0<1;1,0>:d    0:w               {I@3}
        goto (8|M0)                          L14072                  L14560                
L14072:
        join (8|M0)                          L14312                                
L14088:
        add (8|M0)               acc0.0<1>:d   r113.0<1;1,0>:d   -2:w               {Compacted}
(W)     mov (1|M0)               r6.4<1>:hf    -qnan(0x1FF):hf                             
        add (8|M0)               acc2.0<1>:d   r113.0<1;1,0>:d   -1:w               {Compacted}
        add (8|M0)               r66.0<1>:d    -r113.0<1;1,0>:d  23:w               {Compacted}
        shr (8|M0)               r21.0<1>:ud   r19.0<1;1,0>:ud   acc0.0<1;1,0>:d 
        shl (8|M0)               r15.0<1>:d    r6.4<0;1,0>:w     acc0.0<1;1,0>:d  {F@1}
(W)     mov (1|M0)               r6.4<1>:hf    0x1:hf                              {I@1}
        shr (8|M0)               r123.0<1>:ud  r19.0<1;1,0>:ud   r113.0<1;1,0>:d 
        shr (8|M0)               r90.0<1>:ud   r19.0<1;1,0>:ud   acc2.0<1;1,0>:d 
        bfn.0x60 (8|M0)          r28.0<1>:ud   r15.0<1;0>:ud     r6.6<0;0>:ud      r19.0<1>:ud      // (s0^s1)&s2
        shl (8|M0)               r66.0<1>:d    r6.4<0;1,0>:w     r66.0<1;1,0>:d   {F@1}
(f1.0)  mov (8|M0)               r66.0<1>:d    0:w                              
        and (8|M0)               r54.0<1>:d    r21.0<1;1,0>:d    1:w               {Compacted}
        and (8|M0)               r117.0<1>:d   r90.0<1;1,0>:d    1:w               {Compacted,I@5}
        cmp (8|M0)    (ne)f0.0   r67.0<1>:d    r28.0<1;1,0>:d    0:w               {I@5}
        or (8|M0)                r71.0<1>:d    r123.0<1;1,0>:d   r66.0<1;1,0>:d   {Compacted,I@4}
        goto (8|M0)                          L14312                  L14560                
L14312:
        join (8|M0)                          L14432                                
L14328:
        shr (8|M0)               r106.0<1>:ud  r19.0<1;1,0>:ud   1:w              
        and (8|M0)               r117.0<1>:d   r7.0<1;1,0>:d     1:w               {Compacted}
        or (8|M0)                r20.0<1>:d    r106.0<1;1,0>:d   4194304:d               {I@2}
        mov (8|M0)               r54.0<1>:d    0:w                              
        mov (8|M0)               r67.0<1>:d    0:w                              
(f1.0)  sel (8|M0)               r71.0<1>:d    r106.0<1;1,0>:d   r20.0<1;1,0>:d   {I@3}
        goto (8|M0)                          L14432                  L14560                
L14432:
        join (8|M0)                          L14480                                
L14448:
        cmp (8|M0)    (eq)f1.1   null<1>:d     r113.0<1;1,0>:d   0:w              
(f1.1)  goto (8|M0)                          L14480                  L14776                
L14480:
        join (8|M0)                          L14560                                
L14496:
        cmp (8|M0)    (ne)f1.1   r67.0<1>:d    r7.0<1;1,0>:d     0:w              
        mov (8|M0)               r117.0<1>:d   0:w                              
        mov (8|M0)               r54.0<1>:d    0:w                              
        mov (8|M0)               r71.0<1>:d    0:w                              
L14560:
        join (8|M0)                          L14776                                
L14576:
        add (8|M0)               r102.0<1>:d   r118.0<1;1,0>:d   r71.0<1;1,0>:d   {Compacted,I@2}
        cmp (8|M0)    (ne)f1.0   r121.0<1>:d   r67.0<1;1,0>:d    0:w              
        cmp (8|M0)    (gt)f1.0   null<1>:ud    r102.0<1;1,0>:ud  0x7FFFFF:ud              {I@2}
        mov (8|M0)               r79.0<1>:d    -r121.0<1;1,0>:d                 {I@2}
(f1.0)  goto (8|M0)                          L14680                  L14680                
L14648:
        mov (8|M0)               r125.0<1>:d   r54.0<1;1,0>:d                  
        goto (8|M0)                          L14680                  L15184                
L14680:
        join (8|M0)                          L14776                                
L14696:
        cmp (8|M0)    (eq)f0.1   null<1>:d     r54.0<1;1,0>:d    1:w              
        shr (8|M0)               r19.0<1>:ud   r102.0<1;1,0>:ud  1:w              
        and (8|M0)               r110.0<1>:d   r19.0<1;1,0>:d    4194303:d               {I@1}
(~f0.1) sel (8|M0)               r79.0<1>:d    -r121.0<1;1,0>:d  1:w              
        goto (8|M0)                          L14776                  L15120                
L14776:
        join (8|M0)                          L15120                                
L14792:
        add (8|M0)               r102.0<1>:d   r118.0<1;1,0>:d   r19.0<1;1,0>:d   {Compacted}
        cmp (8|M0)    (gt)f0.0   null<1>:ud    r102.0<1;1,0>:ud  0x7FFFFF:ud              {I@1}
(f0.0)  goto (8|M0)                          L15008                  L15008                
L14832:
(~f1.0) goto (8|M0)                          L14912                  L14912                
L14848:
        mov (8|M0)               r117.0<1>:d   0:w                              
        mov (8|M0)               r125.0<1>:d   0:w                              
        mov (8|M0)               r79.0<1>:d    0:w                              
        goto (8|M0)                          L14912                  L15184                
L14912:
        join (8|M0)                          L15008                                
L14928:
        and (8|M0)               r117.0<1>:d   r102.0<1;1,0>:d   1:w               {Compacted}
        add (8|M0)               r98.0<1>:d    r98.0<1;1,0>:d    1:w               {Compacted}
        mov (8|M0)               r125.0<1>:d   0:w                              
        mov (8|M0)               r79.0<1>:d    0:w                              
        shr (8|M0)               r102.0<1>:ud  r102.0<1;1,0>:ud  1:w              
        goto (8|M0)                          L15008                  L15184                
L15008:
        join (8|M0)                          L15120                                
L15024:
        shr (8|M0)               r105.0<1>:ud  r102.0<1;1,0>:ud  1:w               {I@3}
        mov (8|M0)               r79.0<1>:d    0:w                              
        and (8|M0)               r93.0<1>:d    r105.0<1;1,0>:d   4194303:d               {I@2}
        or (8|M0)                r105.0<1>:d   r105.0<1;1,0>:d   4194304:d              
        mov (8|M0)               r117.0<1>:d   0:w                              
(f1.0)  sel (8|M0)               r110.0<1>:d   r93.0<1;1,0>:d    r105.0<1;1,0>:d  {I@2}
L15120:
        join (8|M0)                          L15184                                
L15136:
        and (8|M0)               acc0.0<1>:d   r102.0<1;1,0>:d   1:w               {Compacted}
        add (8|M0)               r98.0<1>:d    r98.0<1;1,0>:d    1:w               {Compacted}
        mov (8|M0)               r125.0<1>:f   r117.0<1;1,0>:f                  {Compacted,I@5}
        mov (8|M0)               r102.0<1>:f   r110.0<1;1,0>:f                  {Compacted,A@2}
        mov (8|M0)               r117.0<1>:d   acc0.0<1;1,0>:d                  {F@2}
L15184:
        join (8|M0)                          L15680                                
L15200:
        shl (8|M0)               r101.0<1>:d   r117.0<1;1,0>:d   2:w               {Compacted,I@2}
        shl (8|M0)               r18.0<1>:d    r125.0<1;1,0>:d   1:w               {Compacted}
        bfn.0xFE (8|M0)          r62.0<1>:ud   r101.0<1;0>:ud    r18.0<1;0>:ud     r79.0<1>:ud      {I@1} // s0|s1|s2
        cmp (8|M0)    (eq)f1.1   null<1>:d     r62.0<1;1,0>:d    0:w               {I@1}
(~f1.1) goto (8|M0)                          L15296                  L15296                
L15264:
        mov (8|M0)               r75.0<1>:d    0:w                              
        goto (8|M0)                          L15296                  L15456                
L15296:
        join (8|M0)                          L15456                                
L15312:
        cmp (8|M0)    (gt)f1.0   null<1>:ud    r62.0<1;1,0>:ud   0x4:uw             
(~f1.0) goto (8|M0)                          L15376                  L15376                
L15344:
        mov (8|M0)               r75.0<1>:d    1:w                              
        goto (8|M0)                          L15376                  L15456                
L15376:
        join (8|M0)                          L15456                                
L15392:
        and (8|M0)    (ne)f1.1   null<1>:d     r102.0<1;1,0>:d   1:w               {F@1}
(W)     mov (1|M0)               r6.4<1>:hf    0x1:hf                             
(f1.1)  cmp (8|M0)    (eq)f1.1   null<1>:d     r62.0<1;1,0>:d    4:w              
(f1.1)  sel (8|M0)               r75.0<1>:d    r6.4<0;1,0>:w     0:w               {F@1}
L15456:
        join (8|M0)                          L15680                                
L15472:
        add (8|M0)               r74.0<1>:d    r102.0<1;1,0>:d   r75.0<1;1,0>:d   {Compacted,I@2}
        cmp (8|M0)    (eq)f0.1   r17.0<1>:d    r74.0<1;1,0>:d    8388608:d               {I@1}
        cmp (8|M0)    (eq)f1.0   null<1>:d     r74.0<1;1,0>:d    8388608:d              
        add3 (8|M0)              r96.0<1>:d    r98.0<1;0>:d      -r17.0<1;0>:d     0:w               {I@2}
        cmp (8|M0)    (eq)f0.1   null<1>:d     r96.0<1;1,0>:d    255:w               {I@1}
(f0.1)  goto (8|M0)                          L15632                  L15632                
L15560:
(~f1.0) sel (8|M0)               r92.0<1>:d    r74.0<1;1,0>:d    0:w              
        and (8|M0)               r87.0<1>:d    r127.0<1;1,0>:d   -2147483648:d              
        shl (8|M0)               r16.0<1>:d    r96.0<1;1,0>:d    23:w               {Compacted}
        bfn.0xFE (8|M0)          r7.0<1>:ud    r87.0<1;0>:ud     r16.0<1;0>:ud     r92.0<1>:ud      {I@1} // s0|s1|s2
        goto (8|M0)                          L15632                  L17848                
L15632:
        join (8|M0)                          L15680                                
L15648:
        bfn.0xEA (8|M0)          r7.0<1>:ud    r6.0<0;0>:ud      r127.0<1;0>:ud    r6.1<0>:ud       // s0|s1&s2
        goto (8|M0)                          L15680                  L17848                
L15680:
        join (8|M0)                          L15736                                
L15696:
        add (8|M0)               r15.0<1>:d    r118.0<1;1,0>:d   r19.0<1;1,0>:d   {Compacted}
        bfn.0xF8 (8|M0)          r7.0<1>:ud    r127.0<1;0>:ud    r6.1<0;0>:ud      r15.0<1>:ud      {I@1} // s0&s1|s2
        goto (8|M0)                          L15736                  L17848                
L15736:
        join (8|M0)                          L17768                                
L15752:
        cmp (8|M0)    (ne)f0.1   null<1>:d     r98.0<1;1,0>:d    0:w              
(f0.1)  sel (8|M0)               r32.0<1>:d    -r98.0<1;1,0>:d   -1:w              
        add (8|M0)               r37.0<1>:d    r110.0<1;1,0>:d   r32.0<1;1,0>:d   {Compacted,I@1}
        cmp (8|M0)    (lt)f0.0   null<1>:d     r37.0<1;1,0>:d    1:w               {Compacted,I@1}
(f0.0)  goto (8|M0)                          L16528                  L16528                
L15816:
        cmp (8|M0)    (eq)f1.1   null<1>:d     r37.0<1;1,0>:d    1:w              
(f1.1)  goto (8|M0)                          L16408                  L16408                
L15848:
        cmp (8|M0)    (lt)f1.0   null<1>:ud    r37.0<1;1,0>:ud   0x18:uw             
(f1.0)  goto (8|M0)                          L16144                  L16144                
L15880:
        cmp (8|M0)    (ne)f0.1   r14.0<1>:d    r98.0<1;1,0>:d    0:w              
        cmp (8|M0)    (lt)f0.0   null<1>:d     r37.0<1;1,0>:d    25:w               {Compacted}
        mov (8|M0)               r119.0<1>:d   -r14.0<1;1,0>:d                  {I@2}
(f0.0)  goto (8|M0)                          L16040                  L16040                
L15936:
        cmp (8|M0)    (eq)f1.1   null<1>:d     r37.0<1;1,0>:d    25:w              
(~f1.1) goto (8|M0)                          L16040                  L16576                
L15968:
        cmp (8|M0)    (ne)f0.0   r65.0<1>:d    r118.0<1;1,0>:d   0:w              
        mov (8|M0)               r56.0<1>:f    r119.0<1;1,0>:f                  {Compacted,I@5}
        mov (8|M0)               r70.0<1>:d    0:w                              
        mov (8|M0)               r119.0<1>:d   0:w                               {F@1}
        goto (8|M0)                          L16040                  L16656                
L16040:
        join (8|M0)                          L16144                                
L16056:
        shr (8|M0)               r13.0<1>:ud   r127.0<1;1,0>:ud  22:w              
        and (8|M0)               r12.0<1>:d    r127.0<1;1,0>:d   4194303:d              
        mov (8|M0)               r70.0<1>:d    0:w                              
        and (8|M0)               r56.0<1>:d    r13.0<1;1,0>:d    1:w               {Compacted,I@3}
        cmp (8|M0)    (ne)f1.1   r65.0<1>:d    r12.0<1;1,0>:d    0:w               {I@3}
        goto (8|M0)                          L16144                  L16656                
L16144:
        join (8|M0)                          L16408                                
L16160:
        add3 (8|M0)              acc0.0<1>:d   r110.0<1;0>:d     r32.0<1;0>:d      -2:w              
(W)     mov (1|M0)               r6.4<1>:hf    -qnan(0x1FF):hf                             
        add3 (8|M0)              acc2.0<1>:d   r110.0<1;0>:d     r32.0<1;0>:d      -1:w              
        add3 (8|M0)              r64.0<1>:d    23:w                -r110.0<1;0>:d    -r32.0<1>:d     
        shr (8|M0)               r11.0<1>:ud   r118.0<1;1,0>:ud  acc0.0<1;1,0>:d 
        shl (8|M0)               r20.0<1>:d    r6.4<0;1,0>:w     acc0.0<1;1,0>:d  {F@1}
(W)     mov (1|M0)               r6.4<1>:hf    0x1:hf                              {I@1}
        shr (8|M0)               r122.0<1>:ud  r118.0<1;1,0>:ud  r37.0<1;1,0>:d  
        shr (8|M0)               r104.0<1>:ud  r118.0<1;1,0>:ud  acc2.0<1;1,0>:d 
        bfn.0x60 (8|M0)          r33.0<1>:ud   r20.0<1;0>:ud     r6.6<0;0>:ud      r118.0<1>:ud     // (s0^s1)&s2
        shl (8|M0)               r64.0<1>:d    r6.4<0;1,0>:w     r64.0<1;1,0>:d   {F@1}
(~f0.1) mov (8|M0)               r64.0<1>:d    0:w                              
        and (8|M0)               r56.0<1>:d    r11.0<1;1,0>:d    1:w               {Compacted}
        and (8|M0)               r119.0<1>:d   r104.0<1;1,0>:d   1:w               {Compacted,I@5}
        cmp (8|M0)    (ne)f1.0   r65.0<1>:d    r33.0<1;1,0>:d    0:w               {I@5}
        or (8|M0)                r70.0<1>:d    r122.0<1;1,0>:d   r64.0<1;1,0>:d   {Compacted,I@4}
        goto (8|M0)                          L16408                  L16656                
L16408:
        join (8|M0)                          L16528                                
L16424:
        shr (8|M0)               r105.0<1>:ud  r118.0<1;1,0>:ud  1:w              
        and (8|M0)               r119.0<1>:d   r127.0<1;1,0>:d   1:w               {Compacted}
        or (8|M0)                r10.0<1>:d    r105.0<1;1,0>:d   4194304:d               {I@2}
        mov (8|M0)               r56.0<1>:d    0:w                              
        mov (8|M0)               r65.0<1>:d    0:w                              
(f0.1)  sel (8|M0)               r70.0<1>:d    r10.0<1;1,0>:d    r105.0<1;1,0>:d  {I@3}
        goto (8|M0)                          L16528                  L16656                
L16528:
        join (8|M0)                          L16576                                
L16544:
        cmp (8|M0)    (eq)f1.0   null<1>:d     r37.0<1;1,0>:d    0:w              
(f1.0)  goto (8|M0)                          L16576                  L16872                
L16576:
        join (8|M0)                          L16656                                
L16592:
        cmp (8|M0)    (ne)f0.1   r65.0<1>:d    r127.0<1;1,0>:d   0:w              
        mov (8|M0)               r119.0<1>:d   0:w                              
        mov (8|M0)               r56.0<1>:d    0:w                              
        mov (8|M0)               r70.0<1>:d    0:w                              
L16656:
        join (8|M0)                          L16872                                
L16672:
        add (8|M0)               r101.0<1>:d   r19.0<1;1,0>:d    r70.0<1;1,0>:d   {Compacted,I@2}
        cmp (8|M0)    (ne)f0.0   r120.0<1>:d   r65.0<1;1,0>:d    0:w              
        cmp (8|M0)    (gt)f0.0   null<1>:ud    r101.0<1;1,0>:ud  0x7FFFFF:ud              {I@2}
        mov (8|M0)               r78.0<1>:d    -r120.0<1;1,0>:d                 {I@2}
(f0.0)  goto (8|M0)                          L16776                  L16776                
L16744:
        mov (8|M0)               r124.0<1>:d   r56.0<1;1,0>:d                  
        goto (8|M0)                          L16776                  L17280                
L16776:
        join (8|M0)                          L16872                                
L16792:
        cmp (8|M0)    (eq)f1.1   null<1>:d     r56.0<1;1,0>:d    1:w              
        shr (8|M0)               r4.0<1>:ud    r101.0<1;1,0>:ud  1:w              
        and (8|M0)               r109.0<1>:d   r4.0<1;1,0>:d     4194303:d               {I@1}
(~f1.1) sel (8|M0)               r78.0<1>:d    -r120.0<1;1,0>:d  1:w              
        goto (8|M0)                          L16872                  L17216                
L16872:
        join (8|M0)                          L17216                                
L16888:
        add (8|M0)               r101.0<1>:d   r19.0<1;1,0>:d    r118.0<1;1,0>:d  {Compacted}
        cmp (8|M0)    (gt)f1.0   null<1>:ud    r101.0<1;1,0>:ud  0x7FFFFF:ud              {I@1}
(f1.0)  goto (8|M0)                          L17104                  L17104                
L16928:
(f0.1)  goto (8|M0)                          L17008                  L17008                
L16944:
        mov (8|M0)               r119.0<1>:d   0:w                              
        mov (8|M0)               r124.0<1>:d   0:w                              
        mov (8|M0)               r78.0<1>:d    0:w                              
        goto (8|M0)                          L17008                  L17280                
L17008:
        join (8|M0)                          L17104                                
L17024:
        and (8|M0)               r119.0<1>:d   r101.0<1;1,0>:d   1:w               {Compacted}
        add (8|M0)               r110.0<1>:d   r110.0<1;1,0>:d   1:w               {Compacted}
        mov (8|M0)               r124.0<1>:d   0:w                              
        mov (8|M0)               r78.0<1>:d    0:w                              
        shr (8|M0)               r101.0<1>:ud  r101.0<1;1,0>:ud  1:w              
        goto (8|M0)                          L17104                  L17280                
L17104:
        join (8|M0)                          L17216                                
L17120:
        shr (8|M0)               r104.0<1>:ud  r101.0<1;1,0>:ud  1:w               {I@3}
        mov (8|M0)               r78.0<1>:d    0:w                              
        and (8|M0)               r91.0<1>:d    r104.0<1;1,0>:d   4194303:d               {I@2}
        or (8|M0)                r104.0<1>:d   r104.0<1;1,0>:d   4194304:d              
        mov (8|M0)               r119.0<1>:d   0:w                              
(f0.1)  sel (8|M0)               r109.0<1>:d   r104.0<1;1,0>:d   r91.0<1;1,0>:d   {I@2}
L17216:
        join (8|M0)                          L17280                                
L17232:
        and (8|M0)               acc0.0<1>:d   r101.0<1;1,0>:d   1:w               {Compacted}
        add (8|M0)               r110.0<1>:d   r110.0<1;1,0>:d   1:w               {Compacted}
        mov (8|M0)               r124.0<1>:f   r119.0<1;1,0>:f                  {Compacted,I@5}
        mov (8|M0)               r101.0<1>:f   r109.0<1;1,0>:f                  {Compacted,A@2}
        mov (8|M0)               r119.0<1>:d   acc0.0<1;1,0>:d                  {F@2}
L17280:
        join (8|M0)                          L17768                                
L17296:
        shl (8|M0)               r100.0<1>:d   r119.0<1;1,0>:d   2:w               {Compacted,I@2}
        shl (8|M0)               r127.0<1>:d   r124.0<1;1,0>:d   1:w               {Compacted}
        bfn.0xFE (8|M0)          r61.0<1>:ud   r100.0<1;0>:ud    r127.0<1;0>:ud    r78.0<1>:ud      {I@1} // s0|s1|s2
        cmp (8|M0)    (eq)f0.0   null<1>:d     r61.0<1;1,0>:d    0:w               {Compacted,I@1}
(~f0.0) goto (8|M0)                          L17384                  L17384                
L17352:
        mov (8|M0)               r73.0<1>:d    0:w                              
        goto (8|M0)                          L17384                  L17544                
L17384:
        join (8|M0)                          L17544                                
L17400:
        cmp (8|M0)    (gt)f1.1   null<1>:ud    r61.0<1;1,0>:ud   0x4:uw             
(~f1.1) goto (8|M0)                          L17464                  L17464                
L17432:
        mov (8|M0)               r73.0<1>:d    1:w                              
        goto (8|M0)                          L17464                  L17544                
L17464:
        join (8|M0)                          L17544                                
L17480:
        and (8|M0)    (ne)f1.0   null<1>:d     r101.0<1;1,0>:d   1:w               {F@1}
(W)     mov (1|M0)               r6.4<1>:hf    0x1:hf                             
(f1.0)  cmp (8|M0)    (eq)f1.0   null<1>:d     r61.0<1;1,0>:d    4:w              
(f1.0)  sel (8|M0)               r73.0<1>:d    r6.4<0;1,0>:w     0:w               {F@1}
L17544:
        join (8|M0)                          L17768                                
L17560:
        add (8|M0)               r72.0<1>:d    r101.0<1;1,0>:d   r73.0<1;1,0>:d   {Compacted,I@2}
        cmp (8|M0)    (eq)f0.0   r126.0<1>:d   r72.0<1;1,0>:d    8388608:d               {I@1}
        cmp (8|M0)    (eq)f0.1   null<1>:d     r72.0<1;1,0>:d    8388608:d              
        add3 (8|M0)              r95.0<1>:d    r110.0<1;0>:d     -r126.0<1;0>:d    0:w               {I@2}
        cmp (8|M0)    (eq)f1.0   null<1>:d     r95.0<1;1,0>:d    255:w               {I@1}
(f1.0)  goto (8|M0)                          L17720                  L17720                
L17648:
(~f0.1) sel (8|M0)               r90.0<1>:d    r72.0<1;1,0>:d    0:w              
        and (8|M0)               r86.0<1>:d    r7.0<1;1,0>:d     -2147483648:d              
        shl (8|M0)               r125.0<1>:d   r95.0<1;1,0>:d    23:w               {Compacted}
        bfn.0xFE (8|M0)          r7.0<1>:ud    r86.0<1;0>:ud     r125.0<1;0>:ud    r90.0<1>:ud      {I@1} // s0|s1|s2
        goto (8|M0)                          L17720                  L17848                
L17720:
        join (8|M0)                          L17768                                
L17736:
        bfn.0xEA (8|M0)          r7.0<1>:ud    r6.0<0;0>:ud      r7.0<1;0>:ud      r6.1<0>:ud       {I@3} // s0|s1&s2
        goto (8|M0)                          L17768                  L17848                
L17768:
        join (8|M0)                          L17848                                
L17784:
        cmp (8|M0)    (ne)f1.1   null<1>:d     r54.0<1;1,0>:d    r53.0<1;1,0>:d  
(f1.1)  cmp (8|M0)    (eq)f1.1   null<1>:d     r118.0<1;1,0>:d   0:w              
(f1.1)  cmp (8|M0)    (eq)f1.1   null<1>:d     r98.0<1;1,0>:d    255:w              
(f1.1)  mov (8|M0)               r7.0<1>:f     qnan(0x0):f                               {I@6}
L17848:
        join (8|M0)                          L36744                                
L17864:
        shr (8|M0)               r24.0<1>:ud   r8.0<1;1,0>:ud    1:w              
(W)     shr (1|M0)               r5.0<1>:ud    r5.7<0;1,0>:ud    1:w              
        shr (8|M0)               r123.0<1>:ud  r7.0<1;1,0>:ud    23:w               {F@1}
        and (8|M0)    (ne)f0.1   r50.0<1>:d    r7.0<1;1,0>:d     8388607:d              
(W)     mul (8|M0)               acc0.0<1>:d   r24.0<1;1,0>:d    r5.0<0;1,0>:uw   {Compacted,I@3}
        and (8|M0)               r53.0<1>:d    r123.0<1;1,0>:d   255:w               {Compacted,I@3}
        shr (8|M0)               r124.0<1>:ud  r9.0<1;1,0>:ud    1:w              
        mach (8|M0)              r24.0<1>:d    r24.0<1;1,0>:d    r5.0<0;1,0>:d    {Compacted}
(f0.1)  cmp (8|M0)    (eq)f0.1   null<1>:d     r53.0<1;1,0>:d    255:w               {I@3}
        add (8|M0)               r24.0<1>:d    r24.0<1;1,0>:d    r124.0<1;1,0>:d  {Compacted,I@2}
(W)     mul (8|M0)               acc0.0<1>:d   r24.0<1;1,0>:d    r5.4<0;1,0>:uw   {Compacted,I@1}
        mach (8|M0)              r4.0<1>:d     r24.0<1;1,0>:d    r5.2<0;1,0>:d    {Compacted}
(~f0.1) goto (8|M0)                          L18048                  L18048                
L18024:
        mov (8|M0)               r5.0<1>:f     qnan(0x0):f                               {Compacted,I@2}
        goto (8|M0)                          L18048                  L23912                
L18048:
        join (8|M0)                          L23912                                
L18064:
        cmp (8|M0)    (eq)f0.0   null<1>:d     r50.0<1;1,0>:d    0:w               {Compacted}
(f0.0)  cmp (8|M0)    (eq)f0.0   null<1>:d     r53.0<1;1,0>:d    255:w              
(f0.0)  goto (8|M0)                          L23880                  L23880                
L18104:
        or (8|M0)     (eq)f0.1   null<1>:d     r53.0<1;1,0>:d    r50.0<1;1,0>:d  
(~f0.1) goto (8|M0)                          L18160                  L18160                
L18136:
        mov (8|M0)               r5.0<1>:f     0.0:f                               {Compacted}
        goto (8|M0)                          L18160                  L23912                
L18160:
        join (8|M0)                          L23880                                
L18176:
        cmp (8|M0)    (eq)f1.0   null<1>:d     r53.0<1;1,0>:d    0:w              
(W)     mov (1|M0)               r6.4<1>:hf    0.0:hf                             
        add (8|M0)               r60.0<1>:d    r53.0<1;1,0>:d    -129:w               {Compacted}
(W)     mov (1|M0)               r6.7<1>:d     0:w                              
(f1.0)  sel (8|M0)               acc0.0<1>:d   r6.4<0;1,0>:w     8388608:d               {F@1}
(W)     mov (1|M0)               r6.4<1>:f     -0.0:f                               {Compacted}
        or (8|M0)                r93.0<1>:d    acc0.0<1;1,0>:d   r50.0<1;1,0>:d  
(W)     mov (2|M0)               r8.4<1>:d     0:w                              
        shl (8|M0)               r88.0<1>:d    r93.0<1;1,0>:d    23:w               {Compacted,I@2}
        shr (8|M0)               r95.0<1>:ud   r93.0<1;1,0>:ud   9:w              
L18312:
(W)     shl (1|M0)               r8.2<1>:d     r6.4<0;1,0>:d     31:w               {F@1}
(W)     shr (1|M0)               r8.1<1>:ud    r6.7<0;1,0>:ud    1:w              
(W)     cmp (8|M0)    (gt)f0.1   null<1>:ud    r8.4<0;1,0>:ud    0x3E:uw              {I@5}
(W)     or (1|M0)                r6.7<1>:d     r8.1<0;1,0>:d     r8.2<0;1,0>:d    {I@2}
        bfn.0xE0 (8|M0)          r29.0<1>:ud   r8.1<0;0>:ud      r8.2<0;0>:ud      r88.0<1>:ud      // (s0|s1)&s2
(W)     shr (1|M0)               r6.2<1>:ud    r6.4<0;1,0>:ud    1:w              
(W&f0.1) cmp (8|M0)   (eq)f0.1   null<1>:d     r8.5<0;1,0>:d     0:w              
        cmp (8|M0)    (eq)f0.0   null<1>:d     r29.0<1;1,0>:d    r6.7<0;1,0>:d    {I@3}
(W)     addc (1|M0)              r10.0<1>:ud   r8.4<0;1,0>:ud    0x1:ud              {AccWrEn}
        and (8|M0)               r28.0<1>:d    r6.2<0;1,0>:d     r95.0<1;1,0>:d   {Compacted,I@4}
(W)     mov (1|M0)               r8.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
(W&~f0.1) cmp (8|M0)  (gt)f0.1   null<1>:ud    r8.5<0;1,0>:ud    0x0:uw             
(f0.0)  cmp (8|M0)    (eq)f0.0   null<1>:d     r28.0<1;1,0>:d    r6.2<0;1,0>:d    {I@3}
(W)     add (1|M0)               r8.6<1>:ud    r8.0<0;1,0>:ud    r8.5<0;1,0>:ud   {I@3}
(W)     mov (1|M0)               r8.0<1>:hf    0x1:hf                              {I@1}
        mov (8|M0)               r113.0<1>:d   r8.4<0;1,0>:d                   
(f0.1)  sel (8|M0)               r9.0<1>:uw    r8.0<0;1,0>:uw    0x0:uw              {F@1}
(f0.0)  sel (8|M0)               r8.0<1>:uw    r8.0<0;1,0>:uw    0x0:uw             
        mov (8|M0)               r119.0<1>:d   r8.5<0;1,0>:d                   
        or (8|M0)     (ne)f1.1   null<1>:uw    r9.0<1;1,0>:uw    r8.0<1;1,0>:uw   {I@2}
        mov (8|M0)               r25.0<1>:f    r10.0<0;1,0>:f                   {Compacted}
        mov (8|M0)               r84.0<1>:d    r8.6<0;1,0>:d                   
(f1.1)  goto (8|M0)                          L18720                  L18720                
L18656:
(W)     mov (1|M0)               r6.4<1>:d     r6.2<0;1,0>:d                   
(W)     mov (1|M0)               r8.4<1>:d     r10.0<0;1,0>:d                  
(W)     mov (1|M0)               r8.5<1>:d     r8.6<0;1,0>:d                   
(W)     jmpi                                 L18312                                
L18720:
        join (8|M0)                          L23880                                
L18736:
(W)     mov (1|M0)               r6.2<1>:f     8.68805e-44:f                               {I@5}
(~f1.0) sel (8|M0)               r52.0<1>:d    r60.0<1;1,0>:d    -128:w              
        subb (8|M0)              r40.0<1>:ud   r6.2<0;1,0>:ud    r113.0<1;1,0>:ud {AccWrEn,Compacted,F@1}
(W)     mov (1|M0)               r8.0<1>:hf    0.0:hf                             
        add3 (8|M0)              r51.0<1>:d    r52.0<1;0>:d      r40.0<1;0>:d      -46:w               {I@1}
        add (8|M0)               r31.0<1>:d    r52.0<1;1,0>:d    r40.0<1;1,0>:d   {Compacted}
        cmp (8|M0)    (gt)f0.0   null<1>:d     r51.0<1;1,0>:d    127:w               {I@2}
        add3 (8|M0)              r59.0<1>:ud   -acc0.0<1;0>:ud   r8.0<0;0>:uw      -r119.0<1>:ud    {F@1}
(f0.0)  goto (8|M0)                          L23832                  L23832                
L18864:
        cmp (8|M0)    (gt)f1.1   null<1>:d     r51.0<1;1,0>:d    -127:w              
(f1.1)  goto (8|M0)                          L21424                  L21424                
L18896:
        cmp (8|M0)    (lt)f1.0   null<1>:ud    r51.0<1;1,0>:ud   0xFFFFFF6B:ud             
(f1.0)  goto (8|M0)                          L20904                  L20904                
L18928:
(W)     mov (1|M0)               r6.2<1>:f     8.82818e-44:f                              
        add3 (8|M0)              r58.0<1>:d    r52.0<1;0>:d      r40.0<1;0>:d      104:w              
        subb (8|M0)              r72.0<1>:ud   r6.2<0;1,0>:ud    r113.0<1;1,0>:ud {AccWrEn,Compacted,F@1}
(W)     mov (1|M0)               r8.0<1>:hf    0.0:hf                              {I@7}
        cmp (8|M0)    (gt)f1.0   null<1>:ud    r72.0<1;1,0>:ud   r58.0<1;1,0>:ud  {I@1}
        add3 (8|M0)              r89.0<1>:ud   -acc0.0<1;0>:ud   r8.0<0;0>:uw      -r119.0<1>:ud    {F@1}
(f1.0)  cmp (8|M0)    (eq)f1.0   null<1>:d     r89.0<1;1,0>:d    0:w               {I@1}
(~f1.0) cmp (8|M0)    (gt)f1.0   null<1>:ud    r89.0<1;1,0>:ud   0x0:uw             
(f1.0)  goto (8|M0)                          L19128                  L19128                
L19064:
        add3 (8|M0)              acc0.0<1>:d   r31.0<1;0>:d      -r72.0<1;0>:d     104:w              
        mov (8|M0)               r103.0<1>:d   0:w                              
        shl (8|M0)               r104.0<1>:d   r88.0<1;1,0>:d    acc0.0<1;1,0>:d 
        goto (8|M0)                          L19128                  L20840                
L19128:
        join (8|M0)                          L20840                                
L19144:
        add3 (8|M0)              r64.0<1>:d    r72.0<1;0>:d      -r31.0<1;0>:d     -104:w              
        cmp (8|M0)    (lt)f0.1   null<1>:d     r64.0<1;1,0>:d    2:w               {I@1}
(f0.1)  goto (8|M0)                          L19288                  L19288                
L19192:
        cmp (8|M0)    (eq)f0.0   null<1>:d     r64.0<1;1,0>:d    2:w               {Compacted}
(~f0.0) goto (8|M0)                          L19288                  L19392                
L19216:
        shr (8|M0)               r81.0<1>:ud   r88.0<1;1,0>:ud   1:w              
        mov (8|M0)               r54.0<1>:d    0:w                              
        mov (8|M0)               r75.0<1>:d    0:w                              
        mov (8|M0)               r40.0<1>:f    r81.0<1;1,0>:f                   {Compacted,I@3}
        goto (8|M0)                          L19288                  L20272                
L19288:
        join (8|M0)                          L19392                                
L19304:
        cmp (8|M0)    (eq)f1.1   null<1>:d     r64.0<1;1,0>:d    1:w              
(~f1.1) goto (8|M0)                          L19392                  L19392                
L19336:
        mov (8|M0)               r54.0<1>:d    0:w                              
        mov (8|M0)               r75.0<1>:d    0:w                              
        mov (8|M0)               r40.0<1>:f    r88.0<1;1,0>:f                   {Compacted}
        goto (8|M0)                          L19392                  L20272                
L19392:
        join (8|M0)                          L20272                                
L19408:
        add3 (8|M0)              acc0.0<1>:d   r72.0<1;0>:d      -r58.0<1;0>:d     -1:w              
        and (8|M0)    (ne)f1.0   r103.0<1>:d   acc0.0<1;1,0>:d   63:w              
(f1.0)  goto (8|M0)                          L19488                  L19488                
L19456:
        mov (8|M0)               r42.0<1>:d    r88.0<1;1,0>:d                  
        goto (8|M0)                          L19488                  L19624                
L19488:
        join (8|M0)                          L19624                                
L19504:
        cmp (8|M0)    (lt)f0.1   null<1>:ud    r103.0<1;1,0>:ud  0x20:uw              {I@5}
(f0.1)  add (8|M0)               acc0.0<1>:d   -r103.0<1;1,0>:d  32:w              
(~f0.1) add (8|M0)               acc2.0<1>:d   r103.0<1;1,0>:d   -32:w              
(f0.1)  shr (8|M0)               r119.0<1>:ud  r88.0<1;1,0>:ud   r103.0<1;1,0>:d 
(f0.1)  shl (8|M0)               r89.0<1>:d    r95.0<1;1,0>:d    acc0.0<1;1,0>:d 
(~f0.1) shr (8|M0)               r81.0<1>:ud   r95.0<1;1,0>:ud   acc2.0<1;1,0>:d  {F@2}
(f0.1)  or (8|M0)                r81.0<1>:d    r119.0<1;1,0>:d   r89.0<1;1,0>:d   {I@2}
        mov (8|M0)               r42.0<1>:f    r81.0<1;1,0>:f                   {Compacted,I@1}
L19624:
        join (8|M0)                          L20272                                
L19640:
        add3 (8|M0)              r119.0<1>:d   r72.0<1;0>:d      -r58.0<1;0>:d     -2:w              
        and (8|M0)    (ne)f0.0   r102.0<1>:d   r119.0<1;1,0>:d   63:w               {I@1}
(f0.0)  goto (8|M0)                          L19720                  L19720                
L19688:
        mov (8|M0)               r81.0<1>:d    r88.0<1;1,0>:d                   {F@1}
        goto (8|M0)                          L19720                  L19848                
L19720:
        join (8|M0)                          L19848                                
L19736:
        cmp (8|M0)    (lt)f1.1   null<1>:ud    r102.0<1;1,0>:ud  0x20:uw              {I@5}
(f1.1)  add (8|M0)               acc0.0<1>:d   -r102.0<1;1,0>:d  32:w              
(~f1.1) add (8|M0)               acc2.0<1>:d   r102.0<1;1,0>:d   -32:w              
(f1.1)  shr (8|M0)               r117.0<1>:ud  r88.0<1;1,0>:ud   r102.0<1;1,0>:d 
(f1.1)  shl (8|M0)               r87.0<1>:d    r95.0<1;1,0>:d    acc0.0<1;1,0>:d 
(~f1.1) shr (8|M0)               r81.0<1>:ud   r95.0<1;1,0>:ud   acc2.0<1;1,0>:d 
(f1.1)  or (8|M0)                r81.0<1>:d    r117.0<1;1,0>:d   r87.0<1;1,0>:d   {I@2}
L19848:
        join (8|M0)                          L20272                                
L19864:
        and (8|M0)    (ne)f1.0   r86.0<1>:d    r119.0<1;1,0>:d   63:w              
        and (8|M0)               r75.0<1>:d    r81.0<1;1,0>:d    1:w               {Compacted,I@3}
(f1.0)  goto (8|M0)                          L19952                  L19952                
L19904:
        mov (8|M0)               r103.0<1>:d   -1:w                              
        mov (8|M0)               r114.0<1>:d   -1:w                              
        goto (8|M0)                          L19952                  L20136                
L19952:
        join (8|M0)                          L20136                                
L19968:
        cmp (8|M0)    (lt)f0.1   null<1>:ud    r86.0<1;1,0>:ud   0x20:uw              {I@7}
(f0.1)  goto (8|M0)                          L20072                  L20072                
L20000:
        add (8|M0)               acc0.0<1>:d   r86.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r6.4<1>:hf    -qnan(0x1FF):hf                             
        mov (8|M0)               r103.0<1>:d   0:w                              
        shl (8|M0)               r114.0<1>:d   r6.4<0;1,0>:w     acc0.0<1;1,0>:d  {F@1}
        goto (8|M0)                          L20072                  L20136                
L20072:
        join (8|M0)                          L20136                                
L20088:
(W)     mov (1|M0)               r6.4<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (8|M0)               r114.0<1>:d   -1:w                              
        shl (8|M0)               r103.0<1>:d   r6.4<0;1,0>:w     r86.0<1;1,0>:d   {F@1}
L20136:
        join (8|M0)                          L20272                                
L20152:
        bfn.0x60 (8|M0)          r116.0<1>:ud  r103.0<1;0>:ud    r6.6<0;0>:ud      r88.0<1>:ud      {I@2} // (s0^s1)&s2
        bfn.0x60 (8|M0)          r115.0<1>:ud  r114.0<1;0>:ud    r6.6<0;0>:ud      r95.0<1>:ud      // (s0^s1)&s2
        cmp (8|M0)    (ne)f1.1   null<1>:d     r116.0<1;1,0>:d   0:w               {I@2}
(W)     mov (1|M0)               r6.4<1>:hf    -qnan(0x1FF):hf                             
        mov (8|M0)               r40.0<1>:f    r42.0<1;1,0>:f                   {Compacted}
(~f1.1) cmp (8|M0)    (ne)f1.1   null<1>:d     r115.0<1;1,0>:d   0:w               {I@2}
(f1.1)  sel (8|M0)               acc0.0<1>:d   r6.4<0;1,0>:w     0:w               {F@2}
        mov (8|M0)               r54.0<1>:d    -acc0.0<1;1,0>:d                
L20272:
        join (8|M0)                          L20840                                
L20288:
        and (8|M0)    (ne)f0.0   r101.0<1>:d   r64.0<1;1,0>:d    63:w              
(f0.0)  goto (8|M0)                          L20352                  L20352                
L20320:
        mov (8|M0)               r81.0<1>:d    r88.0<1;1,0>:d                  
        goto (8|M0)                          L20352                  L20480                
L20352:
        join (8|M0)                          L20480                                
L20368:
        cmp (8|M0)    (lt)f1.1   null<1>:ud    r101.0<1;1,0>:ud  0x20:uw              {I@5}
(f1.1)  add (8|M0)               acc0.0<1>:d   -r101.0<1;1,0>:d  32:w              
(~f1.1) add (8|M0)               acc2.0<1>:d   r101.0<1;1,0>:d   -32:w              
(f1.1)  shr (8|M0)               r112.0<1>:ud  r88.0<1;1,0>:ud   r101.0<1;1,0>:d 
(f1.1)  shl (8|M0)               r85.0<1>:d    r95.0<1;1,0>:d    acc0.0<1;1,0>:d 
(~f1.1) shr (8|M0)               r81.0<1>:ud   r95.0<1;1,0>:ud   acc2.0<1;1,0>:d 
(f1.1)  or (8|M0)                r81.0<1>:d    r112.0<1;1,0>:d   r85.0<1;1,0>:d   {I@2}
L20480:
        join (8|M0)                          L20840                                
L20496:
        shl (8|M0)               r49.0<1>:d    r40.0<1;1,0>:d    2:w               {Compacted,F@1}
        shl (8|M0)               r111.0<1>:d   r75.0<1;1,0>:d    1:w               {Compacted}
        and (8|M0)               r49.0<1>:d    r49.0<1;1,0>:d    4:w               {Compacted,I@2}
        bfn.0xFE (8|M0)          r30.0<1>:ud   r49.0<1;0>:ud     r111.0<1;0>:ud    r54.0<1>:ud      {I@1} // s0|s1|s2
        cmp (8|M0)    (eq)f1.0   null<1>:d     r30.0<1;1,0>:d    0:w               {I@1}
(~f1.0) goto (8|M0)                          L20600                  L20600                
L20568:
        mov (8|M0)               r40.0<1>:d    0:w                              
        goto (8|M0)                          L20600                  L20760                
L20600:
        join (8|M0)                          L20760                                
L20616:
        cmp (8|M0)    (gt)f0.1   null<1>:ud    r30.0<1;1,0>:ud   0x4:uw             
(~f0.1) goto (8|M0)                          L20680                  L20680                
L20648:
        mov (8|M0)               r40.0<1>:d    1:w                              
        goto (8|M0)                          L20680                  L20760                
L20680:
        join (8|M0)                          L20760                                
L20696:
        and (8|M0)    (ne)f1.0   null<1>:d     r81.0<1;1,0>:d    1:w              
(W)     mov (1|M0)               r6.4<1>:hf    0x1:hf                             
(f1.0)  cmp (8|M0)    (eq)f1.0   null<1>:d     r30.0<1;1,0>:d    4:w              
(f1.0)  sel (8|M0)               r40.0<1>:d    r6.4<0;1,0>:w     0:w               {F@1}
L20760:
        join (8|M0)                          L20840                                
L20776:
        add (8|M0)               r72.0<1>:d    r40.0<1;1,0>:d    r81.0<1;1,0>:d   {Compacted,I@2}
(W)     mov (1|M0)               r6.2<1>:f     0x800000:f                               {Compacted}
        cmp (8|M0)    (gt)f1.0   null<1>:ud    r72.0<1;1,0>:ud   0x7FFFFF:ud              {I@1}
(~f1.0) sel (8|M0)               r104.0<1>:d   r72.0<1;1,0>:d    0:w              
(f1.0)  sel (8|M0)               r103.0<1>:d   r6.2<0;1,0>:d     0:w               {F@1}
L20840:
        join (8|M0)                          L20904                                
L20856:
        and (8|M0)               r110.0<1>:d   r7.0<1;1,0>:d     -2147483648:d              
        bfn.0xFE (8|M0)          r5.0<1>:ud    r110.0<1;0>:ud    r103.0<1;0>:ud    r104.0<1>:ud     {I@1} // s0|s1|s2
        goto (8|M0)                          L20904                  L23912                
L20904:
        join (8|M0)                          L21424                                
L20920:
        and (8|M0)    (ne)f0.0   r60.0<1>:d    r40.0<1;1,0>:d    63:w              
(f0.0)  goto (8|M0)                          L21000                  L21000                
L20952:
        mov (8|M0)               r71.0<1>:d    -1:w                              
        mov (8|M0)               r84.0<1>:d    -1:w                              
        goto (8|M0)                          L21000                  L21184                
L21000:
        join (8|M0)                          L21184                                
L21016:
        cmp (8|M0)    (lt)f1.1   null<1>:ud    r60.0<1;1,0>:ud   0x20:uw              {I@6}
(f1.1)  goto (8|M0)                          L21120                  L21120                
L21048:
        add (8|M0)               acc0.0<1>:d   r60.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r6.4<1>:hf    -qnan(0x1FF):hf                             
        mov (8|M0)               r71.0<1>:d    0:w                              
        shl (8|M0)               r84.0<1>:d    r6.4<0;1,0>:w     acc0.0<1;1,0>:d  {F@1}
        goto (8|M0)                          L21120                  L21184                
L21120:
        join (8|M0)                          L21184                                
L21136:
(W)     mov (1|M0)               r6.4<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (8|M0)               r84.0<1>:d    -1:w                              
        shl (8|M0)               r71.0<1>:d    r6.4<0;1,0>:w     r60.0<1;1,0>:d   {F@1}
L21184:
        join (8|M0)                          L21424                                
L21200:
        bfn.0x60 (8|M0)          r109.0<1>:ud  r71.0<1;0>:ud     r6.6<0;0>:ud      r88.0<1>:ud      {I@2} // (s0^s1)&s2
        bfn.0x60 (8|M0)          r108.0<1>:ud  r84.0<1;0>:ud     r6.6<0;0>:ud      r95.0<1>:ud      // (s0^s1)&s2
        cmp (8|M0)    (ne)f0.1   null<1>:d     r109.0<1;1,0>:d   0:w               {I@2}
        cmp (8|M0)    (gt)f1.0   null<1>:d     r7.0<1;1,0>:d     -1:w              
(~f0.1) cmp (8|M0)    (ne)f0.1   null<1>:d     r108.0<1;1,0>:d   0:w               {I@3}
(f0.1)  cmp (8|M0)    (eq)f0.1   null<1>:d     r51.0<1;1,0>:d    -150:w              
(f1.0)  goto (8|M0)                          L21360                  L21360                
L21312:
(W)     mov (1|M0)               r6.2<1>:ud    0x80000001:ud                             
(f0.1)  sel (8|M0)               r5.0<1>:f     r6.2<0;1,0>:f     -0.0:f               {I@1}
        goto (8|M0)                          L21360                  L23912                
L21360:
        join (8|M0)                          L21424                                
L21376:
(W)     mov (1|M0)               r6.2<1>:ud    0x1:ud                              {F@1}
(f0.1)  sel (8|M0)               r5.0<1>:f     r6.2<0;1,0>:f     0.0:f               {I@1}
        goto (8|M0)                          L21424                  L23912                
L21424:
        join (8|M0)                          L23832                                
L21440:
        cmp (8|M0)    (lt)f0.1   null<1>:ud    r40.0<1;1,0>:ud   0x18:uw              {F@1}
        add3 (8|M0)              r65.0<1>:d    r52.0<1;0>:d      r40.0<1;0>:d      81:w              
(f0.1)  cmp (8|M0)    (eq)f0.1   null<1>:d     r59.0<1;1,0>:d    0:w              
(f0.1)  goto (8|M0)                          L23512                  L23512                
L21504:
        shl (8|M0)               r105.0<1>:d   r25.0<1;1,0>:d    1:w               {Compacted}
        shr (8|M0)               r104.0<1>:ud  r25.0<1;1,0>:ud   31:w              
        shl (8|M0)               r123.0<1>:d   r84.0<1;1,0>:d    1:w               {Compacted}
        cmp (8|M0)    (lt)f0.1   null<1>:ud    r105.0<1;1,0>:ud  0x4E:uw              {I@3}
        or (8|M0)                r123.0<1>:d   r123.0<1;1,0>:d   r104.0<1;1,0>:d  {Compacted,I@2}
(f0.1)  cmp (8|M0)    (eq)f0.1   null<1>:d     r123.0<1;1,0>:d   0:w               {I@1}
(~f0.1) cmp (8|M0)    (lt)f0.1   null<1>:d     r123.0<1;1,0>:d   0:w              
(f0.1)  goto (8|M0)                          L21728                  L21728                
L21608:
        cmp (8|M0)    (eq)f0.0   null<1>:d     r25.0<1;1,0>:d    39:w               {Compacted}
(f0.0)  cmp (8|M0)    (eq)f0.0   null<1>:d     r84.0<1;1,0>:d    0:w              
(~f0.0) goto (8|M0)                          L21728                  L21792                
L21648:
        shr (8|M0)               r81.0<1>:ud   r88.0<1;1,0>:ud   1:w              
        mov (8|M0)               r66.0<1>:d    0:w                              
        mov (8|M0)               r79.0<1>:d    0:w                              
        mov (8|M0)               r26.0<1>:f    r81.0<1;1,0>:f                   {Compacted,I@3}
        mov (8|M0)               r81.0<1>:f    r88.0<1;1,0>:f                   {Compacted}
        goto (8|M0)                          L21728                  L22992                
L21728:
        join (8|M0)                          L21792                                
L21744:
        cmp (8|M0)    (eq)f1.1   null<1>:d     r25.0<1;1,0>:d    38:w              
(f1.1)  cmp (8|M0)    (eq)f1.1   null<1>:d     r84.0<1;1,0>:d    0:w              
(f1.1)  goto (8|M0)                          L21792                  L22904                
L21792:
        join (8|M0)                          L22904                                
L21808:
        add (8|M0)               acc0.0<1>:d   -r25.0<1;1,0>:d   39:w               {Compacted}
        add (8|M0)               r64.0<1>:d    -r25.0<1;1,0>:d   40:w               {Compacted}
        and (8|M0)    (ne)f0.1   r117.0<1>:d   acc0.0<1;1,0>:d   63:w              
(f0.1)  goto (8|M0)                          L21888                  L21888                
L21856:
        mov (8|M0)               r47.0<1>:d    r88.0<1;1,0>:d                  
        goto (8|M0)                          L21888                  L22024                
L21888:
        join (8|M0)                          L22024                                
L21904:
        cmp (8|M0)    (lt)f0.0   null<1>:ud    r117.0<1;1,0>:ud  0x20:uw              {I@5}
(f0.0)  add (8|M0)               acc0.0<1>:d   -r117.0<1;1,0>:d  32:w              
(~f0.0) add (8|M0)               acc2.0<1>:d   r117.0<1;1,0>:d   -32:w              
(f0.0)  shr (8|M0)               r105.0<1>:ud  r88.0<1;1,0>:ud   r117.0<1;1,0>:d 
(f0.0)  shl (8|M0)               r113.0<1>:d   r95.0<1;1,0>:d    acc0.0<1;1,0>:d 
(~f0.0) shr (8|M0)               r81.0<1>:ud   r95.0<1;1,0>:ud   acc2.0<1;1,0>:d  {F@1}
(f0.0)  or (8|M0)                r81.0<1>:d    r105.0<1;1,0>:d   r113.0<1;1,0>:d  {I@2}
        mov (8|M0)               r47.0<1>:f    r81.0<1;1,0>:f                   {Compacted,I@1}
L22024:
        join (8|M0)                          L22904                                
L22040:
        add (8|M0)               r19.0<1>:d    -r25.0<1;1,0>:d   38:w               {Compacted}
        and (8|M0)    (ne)f1.1   r122.0<1>:d   r19.0<1;1,0>:d    63:w               {I@1}
(f1.1)  goto (8|M0)                          L22112                  L22112                
L22080:
        mov (8|M0)               r81.0<1>:d    r88.0<1;1,0>:d                   {F@1}
        goto (8|M0)                          L22112                  L22240                
L22112:
        join (8|M0)                          L22240                                
L22128:
        cmp (8|M0)    (lt)f1.0   null<1>:ud    r122.0<1;1,0>:ud  0x20:uw              {I@5}
(f1.0)  add (8|M0)               acc0.0<1>:d   -r122.0<1;1,0>:d  32:w              
(~f1.0) add (8|M0)               acc2.0<1>:d   r122.0<1;1,0>:d   -32:w              
(f1.0)  shr (8|M0)               r103.0<1>:ud  r88.0<1;1,0>:ud   r122.0<1;1,0>:d 
(f1.0)  shl (8|M0)               r123.0<1>:d   r95.0<1;1,0>:d    acc0.0<1;1,0>:d 
(~f1.0) shr (8|M0)               r81.0<1>:ud   r95.0<1;1,0>:ud   acc2.0<1;1,0>:d 
(f1.0)  or (8|M0)                r81.0<1>:d    r103.0<1;1,0>:d   r123.0<1;1,0>:d  {I@2}
L22240:
        join (8|M0)                          L22904                                
L22256:
        and (8|M0)    (ne)f0.1   r121.0<1>:d   r19.0<1;1,0>:d    63:w              
        and (8|M0)               r79.0<1>:d    r81.0<1;1,0>:d    1:w               {Compacted,I@3}
(f0.1)  goto (8|M0)                          L22344                  L22344                
L22296:
        mov (8|M0)               r14.0<1>:d    -1:w                              
        mov (8|M0)               r27.0<1>:d    -1:w                              
        goto (8|M0)                          L22344                  L22528                
L22344:
        join (8|M0)                          L22528                                
L22360:
        cmp (8|M0)    (lt)f0.0   null<1>:ud    r121.0<1;1,0>:ud  0x20:uw              {I@7}
(f0.0)  goto (8|M0)                          L22464                  L22464                
L22392:
        add (8|M0)               acc0.0<1>:d   r121.0<1;1,0>:d   -32:w               {Compacted}
(W)     mov (1|M0)               r6.4<1>:hf    -qnan(0x1FF):hf                             
        mov (8|M0)               r14.0<1>:d    0:w                              
        shl (8|M0)               r27.0<1>:d    r6.4<0;1,0>:w     acc0.0<1;1,0>:d  {F@1}
        goto (8|M0)                          L22464                  L22528                
L22464:
        join (8|M0)                          L22528                                
L22480:
(W)     mov (1|M0)               r6.4<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (8|M0)               r27.0<1>:d    -1:w                              
        shl (8|M0)               r14.0<1>:d    r6.4<0;1,0>:w     r121.0<1;1,0>:d  {F@1}
L22528:
        join (8|M0)                          L22904                                
L22544:
        bfn.0x60 (8|M0)          r102.0<1>:ud  r14.0<1;0>:ud     r6.6<0;0>:ud      r88.0<1>:ud      {I@2} // (s0^s1)&s2
        bfn.0x60 (8|M0)          r101.0<1>:ud  r27.0<1;0>:ud     r6.6<0;0>:ud      r95.0<1>:ud      // (s0^s1)&s2
        cmp (8|M0)    (ne)f1.0   null<1>:d     r102.0<1;1,0>:d   0:w               {I@2}
(W)     mov (1|M0)               r6.4<1>:hf    -qnan(0x1FF):hf                             
        and (8|M0)    (ne)f1.1   r121.0<1>:d   r64.0<1;1,0>:d    63:w              
(~f1.0) cmp (8|M0)    (ne)f1.0   null<1>:d     r101.0<1;1,0>:d   0:w               {I@3}
(f1.0)  sel (8|M0)               acc0.0<1>:d   r6.4<0;1,0>:w     0:w               {F@1}
        mov (8|M0)               r66.0<1>:d    -acc0.0<1;1,0>:d                
(f1.1)  goto (8|M0)                          L22720                  L22720                
L22688:
        mov (8|M0)               r81.0<1>:d    r88.0<1;1,0>:d                  
        goto (8|M0)                          L22720                  L22848                
L22720:
        join (8|M0)                          L22848                                
L22736:
        cmp (8|M0)    (lt)f1.0   null<1>:ud    r121.0<1;1,0>:ud  0x20:uw              {I@7}
(f1.0)  add (8|M0)               acc0.0<1>:d   -r121.0<1;1,0>:d  32:w              
(~f1.0) add (8|M0)               acc2.0<1>:d   r121.0<1;1,0>:d   -32:w              
(f1.0)  shr (8|M0)               r98.0<1>:ud   r88.0<1;1,0>:ud   r121.0<1;1,0>:d 
(f1.0)  shl (8|M0)               r120.0<1>:d   r95.0<1;1,0>:d    acc0.0<1;1,0>:d 
(~f1.0) shr (8|M0)               r81.0<1>:ud   r95.0<1;1,0>:ud   acc2.0<1;1,0>:d 
(f1.0)  or (8|M0)                r81.0<1>:d    r98.0<1;1,0>:d    r120.0<1;1,0>:d  {I@2}
L22848:
        join (8|M0)                          L22904                                
L22864:
        mov (8|M0)               r26.0<1>:f    r81.0<1;1,0>:f                   {Compacted,I@2}
        mov (8|M0)               r81.0<1>:d    r47.0<1;1,0>:d                   {F@1}
        goto (8|M0)                          L22904                  L22992                
L22904:
        join (8|M0)                          L22992                                
L22920:
        shr (8|M0)               r81.0<1>:ud   r88.0<1;1,0>:ud   2:w              
        mov (8|M0)               r66.0<1>:d    0:w                              
        mov (8|M0)               r79.0<1>:d    0:w                              
        mov (8|M0)               r26.0<1>:f    r81.0<1;1,0>:f                   {Compacted,I@3}
        shr (8|M0)               r81.0<1>:ud   r88.0<1;1,0>:ud   1:w               {F@1}
L22992:
        join (8|M0)                          L23512                                
L23008:
        shl (8|M0)               r102.0<1>:d   r81.0<1;1,0>:d    2:w               {Compacted,I@2}
        shl (8|M0)               r97.0<1>:d    r79.0<1;1,0>:d    1:w               {Compacted}
        and (8|M0)               r102.0<1>:d   r102.0<1;1,0>:d   4:w               {Compacted,I@2}
        and (8|M0)               r22.0<1>:d    r26.0<1;1,0>:d    8388607:d              
        bfn.0xFE (8|M0)          r59.0<1>:ud   r102.0<1;0>:ud    r97.0<1;0>:ud     r66.0<1>:ud      {I@2} // s0|s1|s2
        cmp (8|M0)    (eq)f0.1   null<1>:d     r59.0<1;1,0>:d    0:w               {I@1}
(~f0.1) goto (8|M0)                          L23128                  L23128                
L23096:
        mov (8|M0)               r58.0<1>:d    0:w                              
        goto (8|M0)                          L23128                  L23288                
L23128:
        join (8|M0)                          L23288                                
L23144:
        cmp (8|M0)    (gt)f0.0   null<1>:ud    r59.0<1;1,0>:ud   0x4:uw             
(~f0.0) goto (8|M0)                          L23208                  L23208                
L23176:
        mov (8|M0)               r58.0<1>:d    1:w                              
        goto (8|M0)                          L23208                  L23288                
L23208:
        join (8|M0)                          L23288                                
L23224:
        and (8|M0)    (ne)f0.1   null<1>:d     r26.0<1;1,0>:d    1:w              
(W)     mov (1|M0)               r6.4<1>:hf    0x1:hf                             
(f0.1)  cmp (8|M0)    (eq)f0.1   null<1>:d     r59.0<1;1,0>:d    4:w              
(f0.1)  sel (8|M0)               r58.0<1>:d    r6.4<0;1,0>:w     0:w               {F@1}
L23288:
        join (8|M0)                          L23512                                
L23304:
        add (8|M0)               r88.0<1>:d    r22.0<1;1,0>:d    r58.0<1;1,0>:d   {Compacted,I@2}
        add3 (8|M0)              r64.0<1>:d    r52.0<1;0>:d      r40.0<1;0>:d      82:w              
        cmp (8|M0)    (gt)f1.0   null<1>:ud    r88.0<1;1,0>:ud   0x7FFFFF:ud              {I@2}
(f1.0)  sel (8|M0)               r82.0<1>:d    r64.0<1;1,0>:d    r65.0<1;1,0>:d   {I@2}
        cmp (8|M0)    (eq)f1.1   null<1>:d     r82.0<1;1,0>:d    255:w               {I@1}
(f1.1)  goto (8|M0)                          L23464                  L23464                
L23392:
(~f1.0) sel (8|M0)               r68.0<1>:d    r88.0<1;1,0>:d    0:w              
        and (8|M0)               r63.0<1>:d    r7.0<1;1,0>:d     -2147483648:d              
        shl (8|M0)               r96.0<1>:d    r82.0<1;1,0>:d    23:w               {Compacted}
        bfn.0xFE (8|M0)          r5.0<1>:ud    r63.0<1;0>:ud     r96.0<1;0>:ud     r68.0<1>:ud      {I@1} // s0|s1|s2
        goto (8|M0)                          L23464                  L23912                
L23464:
        join (8|M0)                          L23512                                
L23480:
        bfn.0xEA (8|M0)          r5.0<1>:ud    r6.0<0;0>:ud      r7.0<1;0>:ud      r6.1<0>:ud       // s0|s1&s2
        goto (8|M0)                          L23512                  L23912                
L23512:
        join (8|M0)                          L23832                                
L23528:
        and (8|M0)    (ne)f1.0   r85.0<1>:d    r40.0<1;1,0>:d    63:w              
(f1.0)  goto (8|M0)                          L23592                  L23592                
L23560:
        mov (8|M0)               r48.0<1>:d    -1:w                              
        goto (8|M0)                          L23592                  L23720                
L23592:
        join (8|M0)                          L23720                                
L23608:
        cmp (8|M0)    (lt)f0.1   null<1>:ud    r85.0<1;1,0>:ud   0x20:uw              {I@5}
(f0.1)  goto (8|M0)                          L23672                  L23672                
L23640:
        mov (8|M0)               r48.0<1>:d    0:w                              
        goto (8|M0)                          L23672                  L23720                
L23672:
        join (8|M0)                          L23720                                
L23688:
(W)     mov (1|M0)               r6.4<1>:hf    -qnan(0x1FF):hf                             
        shl (8|M0)               r48.0<1>:d    r6.4<0;1,0>:w     r85.0<1;1,0>:d   {F@1}
L23720:
        join (8|M0)                          L23832                                
L23736:
        bfn.0x60 (8|M0)          r57.0<1>:ud   r48.0<1;0>:ud     r6.6<0;0>:ud      r88.0<1>:ud      {I@2} // (s0^s1)&s2
        add (8|M0)               acc0.0<1>:d   -r40.0<1;1,0>:d   23:w               {Compacted}
        and (8|M0)               r62.0<1>:d    r7.0<1;1,0>:d     -2147483648:d              
        shl (8|M0)               r94.0<1>:d    r65.0<1;1,0>:d    23:w               {Compacted}
        shl (8|M0)               r57.0<1>:d    r57.0<1;1,0>:d    acc0.0<1;1,0>:d  {I@4}
        bfn.0xFE (8|M0)          r5.0<1>:ud    r62.0<1;0>:ud     r94.0<1;0>:ud     r57.0<1>:ud      {I@1} // s0|s1|s2
        goto (8|M0)                          L23832                  L23912                
L23832:
        join (8|M0)                          L23880                                
L23848:
        bfn.0xEA (8|M0)          r5.0<1>:ud    r6.0<0;0>:ud      r7.0<1;0>:ud      r6.1<0>:ud       // s0|s1&s2
        goto (8|M0)                          L23880                  L23912                
L23880:
        join (8|M0)                          L23912                                
L23896:
        bfn.0xF8 (8|M0)          r5.0<1>:ud    r7.0<1;0>:ud      r6.1<0;0>:ud      r6.0<0>:ud       // s0&s1|s2
L23912:
        join (8|M0)                          L36744                                
L23928:
        and (8|M0)               r93.0<1>:d    r5.0<1;1,0>:d     2147483647:d               {I@2}
        sel (8|M0)    (lt)f0.0   r70.0<1>:f    r93.0<1;1,0>:f    448.0:f               {Compacted,I@1}
        shr (8|M0)               r117.0<1>:ud  r70.0<1;1,0>:ud   23:w               {F@1}
        and (8|M0)    (ne)f0.0   r13.0<1>:d    r70.0<1;1,0>:d    8388607:d              
        and (8|M0)               r41.0<1>:d    r117.0<1;1,0>:d   255:w               {Compacted,I@2}
        sel (8|M0)    (ge)f0.0   r92.0<1>:ud   r41.0<1;1,0>:ud   0x79:uw              {I@1}
(f0.0)  cmp (8|M0)    (eq)f0.0   null<1>:d     r41.0<1;1,0>:d    255:w              
        shl (8|M0)               r15.0<1>:d    r92.0<1;1,0>:d    23:w               {Compacted,I@2}
(~f0.0) goto (8|M0)                          L24072                  L24072                
L24048:
        mov (8|M0)               r114.0<1>:f   qnan(0x0):f                               {Compacted}
        goto (8|M0)                          L24072                  L30248                
L24072:
        join (8|M0)                          L30248                                
L24088:
        cmp (8|M0)    (eq)f1.1   null<1>:d     r13.0<1;1,0>:d    0:w              
        add (8|M0)               r94.0<1>:d    -r15.0<1;1,0>:d   -2139095040:d               {I@5}
        xor (8|M0)               r17.0<1>:d    r94.0<1;1,0>:d    r70.0<1;1,0>:d   {Compacted,I@1}
(f1.1)  cmp (8|M0)    (eq)f1.1   null<1>:d     r41.0<1;1,0>:d    255:w              
(f1.1)  goto (8|M0)                          L30216                  L30216                
L24160:
        or (8|M0)     (eq)f0.0   null<1>:d     r41.0<1;1,0>:d    r13.0<1;1,0>:d  
(~f0.0) goto (8|M0)                          L24216                  L24216                
L24192:
        mov (8|M0)               r114.0<1>:f   0.0:f                               {Compacted}
        goto (8|M0)                          L24216                  L30248                
L24216:
        join (8|M0)                          L30216                                
L24232:
        cmp (8|M0)    (eq)f0.0   null<1>:d     r41.0<1;1,0>:d    0:w               {Compacted}
        shr (8|M0)               r83.0<1>:ud   r94.0<1;1,0>:ud   23:w              
        add (8|M0)               r93.0<1>:d    r41.0<1;1,0>:d    -127:w               {Compacted}
(f0.0)  mov (8|M0)               r93.0<1>:d    -126:w                              
        add (8|M0)               r106.0<1>:d   r83.0<1;1,0>:d    r93.0<1;1,0>:d   {Compacted,I@1}
        cmp (8|M0)    (gt)f1.1   null<1>:d     r106.0<1;1,0>:d   254:w               {I@1}
(f1.1)  goto (8|M0)                          L30144                  L30144                
L24320:
        or (8|M0)     (eq)f1.0   null<4>:b     r117.0<1;1,0>:d   r83.0<1;1,0>:d  
(f1.0)  goto (8|M0)                          L30072                  L30072                
L24352:
(W)     mov (1|M0)               r6.4<1>:hf    0.0:hf                             
(W)     mov (1|M0)               r6.7<1>:d     0:w                              
(f0.0)  sel (8|M0)               acc0.0<1>:d   r6.4<0;1,0>:w     8388608:d               {F@1}
(W)     mov (1|M0)               r6.4<1>:f     -0.0:f                               {Compacted}
        or (8|M0)                r110.0<1>:d   acc0.0<1;1,0>:d   r13.0<1;1,0>:d  
(W)     mov (2|M0)               r7.4<1>:d     0:w                              
        shl (8|M0)               r92.0<1>:d    r110.0<1;1,0>:d   23:w               {Compacted,I@2}
        shr (8|M0)               r97.0<1>:ud   r110.0<1;1,0>:ud  9:w              
L24464:
(W)     shl (1|M0)               r7.2<1>:d     r6.4<0;1,0>:d     31:w               {F@1}
(W)     shr (1|M0)               r7.1<1>:ud    r6.7<0;1,0>:ud    1:w              
(W)     cmp (8|M0)    (gt)f0.0   null<1>:ud    r7.4<0;1,0>:ud    0x3E:uw              {I@5}
(W)     or (1|M0)                r6.7<1>:d     r7.1<0;1,0>:d     r7.2<0;1,0>:d    {I@2}
        bfn.0xE0 (8|M0)          r33.0<1>:ud   r7.1<0;0>:ud      r7.2<0;0>:ud      r92.0<1>:ud      // (s0|s1)&s2
(W)     shr (1|M0)               r6.2<1>:ud    r6.4<0;1,0>:ud    1:w              
(W&f0.0) cmp (8|M0)   (eq)f0.0   null<1>:d     r7.5<0;1,0>:d     0:w              
        cmp (8|M0)    (eq)f1.1   null<1>:d     r33.0<1;1,0>:d    r6.7<0;1,0>:d    {I@3}
(W)     addc (1|M0)              r9.0<1>:ud    r7.4<0;1,0>:ud    0x1:ud              {AccWrEn}
        and (8|M0)               r32.0<1>:d    r6.2<0;1,0>:d     r97.0<1;1,0>:d   {Compacted,I@4}
(W)     mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
(W&~f0.0) cmp (8|M0)  (gt)f0.0   null<1>:ud    r7.5<0;1,0>:ud    0x0:uw             
(f1.1)  cmp (8|M0)    (eq)f1.1   null<1>:d     r32.0<1;1,0>:d    r6.2<0;1,0>:d    {I@3}
(W)     add (1|M0)               r7.6<1>:ud    r7.0<0;1,0>:ud    r7.5<0;1,0>:ud   {I@3}
(W)     mov (1|M0)               r7.0<1>:hf    0x1:hf                              {I@1}
        mov (8|M0)               r126.0<1>:d   r7.4<0;1,0>:d                   
(f0.0)  sel (8|M0)               r8.0<1>:uw    r7.0<0;1,0>:uw    0x0:uw              {F@1}
(f1.1)  sel (8|M0)               r7.0<1>:uw    r7.0<0;1,0>:uw    0x0:uw             
        mov (8|M0)               r11.0<1>:d    r7.5<0;1,0>:d                   
        or (8|M0)     (ne)f1.0   null<1>:uw    r8.0<1;1,0>:uw    r7.0<1;1,0>:uw   {I@2}
        mov (8|M0)               r27.0<1>:f    r9.0<0;1,0>:f                    {Compacted}
        mov (8|M0)               r90.0<1>:d    r7.6<0;1,0>:d                   
(f1.0)  goto (8|M0)                          L24872                  L24872                
L24808:
(W)     mov (1|M0)               r6.4<1>:d     r6.2<0;1,0>:d                   
(W)     mov (1|M0)               r7.4<1>:d     r9.0<0;1,0>:d                   
(W)     mov (1|M0)               r7.5<1>:d     r7.6<0;1,0>:d                   
(W)     jmpi                                 L24464                                
L24872:
        join (8|M0)                          L30072                                
L24888:
(W)     mov (1|M0)               r6.2<1>:f     8.68805e-44:f                               {I@5}
(W)     mov (1|M0)               r7.0<1>:hf    0.0:hf                             
        subb (8|M0)              r48.0<1>:ud   r6.2<0;1,0>:ud    r126.0<1;1,0>:ud {AccWrEn,Compacted,F@2}
        add3 (8|M0)              r63.0<1>:d    r106.0<1;0>:d     r48.0<1;0>:d      -173:w               {I@1}
        add3 (8|M0)              r62.0<1>:ud   -acc0.0<1;0>:ud   r7.0<0;0>:uw      -r11.0<1>:ud     {F@1}
        cmp (8|M0)    (gt)f0.1   null<1>:d     r63.0<1;1,0>:d    127:w               {I@2}
        add3 (8|M0)              r40.0<1>:d    r83.0<1;0>:d      r93.0<1;0>:d      r48.0<1>:d      
(f0.1)  goto (8|M0)                          L30000                  L30000                
L25008:
        cmp (8|M0)    (gt)f0.0   null<1>:d     r63.0<1;1,0>:d    -127:w              
(f0.0)  goto (8|M0)                          L27568                  L27568                
L25040:
        cmp (8|M0)    (lt)f1.1   null<1>:ud    r63.0<1;1,0>:ud   0xFFFFFF6B:ud             
(f1.1)  goto (8|M0)                          L27048                  L27048                
L25072:
(W)     mov (1|M0)               r6.2<1>:f     8.82818e-44:f                              
        add3 (8|M0)              r65.0<1>:d    r106.0<1;0>:d     r48.0<1;0>:d      -23:w              
        subb (8|M0)              r85.0<1>:ud   r6.2<0;1,0>:ud    r126.0<1;1,0>:ud {AccWrEn,Compacted,F@1}
(W)     mov (1|M0)               r7.0<1>:hf    0.0:hf                              {I@7}
        cmp (8|M0)    (gt)f0.0   null<1>:ud    r85.0<1;1,0>:ud   r65.0<1;1,0>:ud  {I@1}
        add3 (8|M0)              r102.0<1>:ud  -acc0.0<1;0>:ud   r7.0<0;0>:uw      -r11.0<1>:ud     {F@1}
(f0.0)  cmp (8|M0)    (eq)f0.0   null<1>:d     r102.0<1;1,0>:d   0:w               {I@1}
(~f0.0) cmp (8|M0)    (gt)f0.0   null<1>:ud    r102.0<1;1,0>:ud  0x0:uw             
(f0.0)  goto (8|M0)                          L25272                  L25272                
L25208:
        add3 (8|M0)              acc0.0<1>:d   r40.0<1;0>:d      -r85.0<1;0>:d     -23:w              
        mov (8|M0)               r112.0<1>:d   0:w                              
        shl (8|M0)               r113.0<1>:d   r92.0<1;1,0>:d    acc0.0<1;1,0>:d 
        goto (8|M0)                          L25272                  L26984                
L25272:
        join (8|M0)                          L26984                                
L25288:
        add3 (8|M0)              r77.0<1>:d    r85.0<1;0>:d      -r40.0<1;0>:d     23:w              
        cmp (8|M0)    (lt)f1.0   null<1>:d     r77.0<1;1,0>:d    2:w               {I@1}
(f1.0)  goto (8|M0)                          L25440                  L25440                
L25336:
        cmp (8|M0)    (eq)f0.1   null<1>:d     r77.0<1;1,0>:d    2:w              
(~f0.1) goto (8|M0)                          L25440                  L25536                
L25368:
        shr (8|M0)               r83.0<1>:ud   r92.0<1;1,0>:ud   1:w              
        mov (8|M0)               r62.0<1>:d    0:w                              
        mov (8|M0)               r78.0<1>:d    0:w                              
        mov (8|M0)               r50.0<1>:f    r83.0<1;1,0>:f                   {Compacted,I@3}
        goto (8|M0)                          L25440                  L26416                
L25440:
        join (8|M0)                          L25536                                
L25456:
        cmp (8|M0)    (eq)f0.0   null<1>:d     r77.0<1;1,0>:d    1:w               {Compacted}
(~f0.0) goto (8|M0)                          L25536                  L25536                
L25480:
        mov (8|M0)               r62.0<1>:d    0:w                              
        mov (8|M0)               r78.0<1>:d    0:w                              
        mov (8|M0)               r50.0<1>:f    r92.0<1;1,0>:f                   {Compacted}
        goto (8|M0)                          L25536                  L26416                
L25536:
        join (8|M0)                          L26416                                
L25552:
        add3 (8|M0)              acc0.0<1>:d   r85.0<1;0>:d      -r65.0<1;0>:d     -1:w              
        and (8|M0)    (ne)f1.1   r116.0<1>:d   acc0.0<1;1,0>:d   63:w              
(f1.1)  goto (8|M0)                          L25632                  L25632                
L25600:
        mov (8|M0)               r45.0<1>:d    r92.0<1;1,0>:d                  
        goto (8|M0)                          L25632                  L25768                
L25632:
        join (8|M0)                          L25768                                
L25648:
        cmp (8|M0)    (lt)f1.0   null<1>:ud    r116.0<1;1,0>:ud  0x20:uw              {I@5}
(f1.0)  add (8|M0)               acc0.0<1>:d   -r116.0<1;1,0>:d  32:w              
(~f1.0) add (8|M0)               acc2.0<1>:d   r116.0<1;1,0>:d   -32:w              
(f1.0)  shr (8|M0)               r88.0<1>:ud   r92.0<1;1,0>:ud   r116.0<1;1,0>:d 
(f1.0)  shl (8|M0)               r112.0<1>:d   r97.0<1;1,0>:d    acc0.0<1;1,0>:d 
(~f1.0) shr (8|M0)               r83.0<1>:ud   r97.0<1;1,0>:ud   acc2.0<1;1,0>:d  {F@2}
(f1.0)  or (8|M0)                r83.0<1>:d    r88.0<1;1,0>:d    r112.0<1;1,0>:d  {I@2}
        mov (8|M0)               r45.0<1>:f    r83.0<1;1,0>:f                   {Compacted,I@1}
L25768:
        join (8|M0)                          L26416                                
L25784:
        add3 (8|M0)              r127.0<1>:d   r85.0<1;0>:d      -r65.0<1;0>:d     -2:w              
        and (8|M0)    (ne)f0.1   r115.0<1>:d   r127.0<1;1,0>:d   63:w               {I@1}
(f0.1)  goto (8|M0)                          L25864                  L25864                
L25832:
        mov (8|M0)               r83.0<1>:d    r92.0<1;1,0>:d                   {F@1}
        goto (8|M0)                          L25864                  L25992                
L25864:
        join (8|M0)                          L25992                                
L25880:
        cmp (8|M0)    (lt)f0.0   null<1>:ud    r115.0<1;1,0>:ud  0x20:uw              {I@5}
(f0.0)  add (8|M0)               acc0.0<1>:d   -r115.0<1;1,0>:d  32:w              
(~f0.0) add (8|M0)               acc2.0<1>:d   r115.0<1;1,0>:d   -32:w              
(f0.0)  shr (8|M0)               r86.0<1>:ud   r92.0<1;1,0>:ud   r115.0<1;1,0>:d 
(f0.0)  shl (8|M0)               r111.0<1>:d   r97.0<1;1,0>:d    acc0.0<1;1,0>:d 
(~f0.0) shr (8|M0)               r83.0<1>:ud   r97.0<1;1,0>:ud   acc2.0<1;1,0>:d 
(f0.0)  or (8|M0)                r83.0<1>:d    r86.0<1;1,0>:d    r111.0<1;1,0>:d  {I@2}
L25992:
        join (8|M0)                          L26416                                
L26008:
        and (8|M0)    (ne)f1.1   r110.0<1>:d   r127.0<1;1,0>:d   63:w              
        and (8|M0)               r78.0<1>:d    r83.0<1;1,0>:d    1:w               {Compacted,I@3}
(f1.1)  goto (8|M0)                          L26096                  L26096                
L26048:
        mov (8|M0)               r119.0<1>:d   -1:w                              
        mov (8|M0)               r12.0<1>:d    -1:w                              
        goto (8|M0)                          L26096                  L26280                
L26096:
        join (8|M0)                          L26280                                
L26112:
        cmp (8|M0)    (lt)f1.0   null<1>:ud    r110.0<1;1,0>:ud  0x20:uw              {I@7}
(f1.0)  goto (8|M0)                          L26216                  L26216                
L26144:
        add (8|M0)               acc0.0<1>:d   r110.0<1;1,0>:d   -32:w               {Compacted}
(W)     mov (1|M0)               r6.4<1>:hf    -qnan(0x1FF):hf                             
        mov (8|M0)               r119.0<1>:d   0:w                              
        shl (8|M0)               r12.0<1>:d    r6.4<0;1,0>:w     acc0.0<1;1,0>:d  {F@1}
        goto (8|M0)                          L26216                  L26280                
L26216:
        join (8|M0)                          L26280                                
L26232:
(W)     mov (1|M0)               r6.4<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (8|M0)               r12.0<1>:d    -1:w                              
        shl (8|M0)               r119.0<1>:d   r6.4<0;1,0>:w     r110.0<1;1,0>:d  {F@1}
L26280:
        join (8|M0)                          L26416                                
L26296:
        bfn.0x60 (8|M0)          r85.0<1>:ud   r119.0<1;0>:ud    r6.6<0;0>:ud      r92.0<1>:ud      {I@2} // (s0^s1)&s2
        bfn.0x60 (8|M0)          r84.0<1>:ud   r12.0<1;0>:ud     r6.6<0;0>:ud      r97.0<1>:ud      // (s0^s1)&s2
        cmp (8|M0)    (ne)f1.0   null<1>:d     r85.0<1;1,0>:d    0:w               {I@2}
(W)     mov (1|M0)               r6.4<1>:hf    -qnan(0x1FF):hf                             
        mov (8|M0)               r50.0<1>:f    r45.0<1;1,0>:f                   {Compacted}
(~f1.0) cmp (8|M0)    (ne)f1.0   null<1>:d     r84.0<1;1,0>:d    0:w               {I@2}
(f1.0)  sel (8|M0)               acc0.0<1>:d   r6.4<0;1,0>:w     0:w               {F@2}
        mov (8|M0)               r62.0<1>:d    -acc0.0<1;1,0>:d                
L26416:
        join (8|M0)                          L26984                                
L26432:
        and (8|M0)    (ne)f0.1   r114.0<1>:d   r77.0<1;1,0>:d    63:w              
(f0.1)  goto (8|M0)                          L26496                  L26496                
L26464:
        mov (8|M0)               r83.0<1>:d    r92.0<1;1,0>:d                  
        goto (8|M0)                          L26496                  L26624                
L26496:
        join (8|M0)                          L26624                                
L26512:
        cmp (8|M0)    (lt)f0.0   null<1>:ud    r114.0<1;1,0>:ud  0x20:uw              {I@5}
(f0.0)  add (8|M0)               acc0.0<1>:d   -r114.0<1;1,0>:d  32:w              
(~f0.0) add (8|M0)               acc2.0<1>:d   r114.0<1;1,0>:d   -32:w              
(f0.0)  shr (8|M0)               r81.0<1>:ud   r92.0<1;1,0>:ud   r114.0<1;1,0>:d 
(f0.0)  shl (8|M0)               r109.0<1>:d   r97.0<1;1,0>:d    acc0.0<1;1,0>:d 
(~f0.0) shr (8|M0)               r83.0<1>:ud   r97.0<1;1,0>:ud   acc2.0<1;1,0>:d 
(f0.0)  or (8|M0)                r83.0<1>:d    r81.0<1;1,0>:d    r109.0<1;1,0>:d  {I@2}
L26624:
        join (8|M0)                          L26984                                
L26640:
        shl (8|M0)               r69.0<1>:d    r50.0<1;1,0>:d    2:w               {Compacted,F@1}
        shl (8|M0)               r80.0<1>:d    r78.0<1;1,0>:d    1:w               {Compacted}
        and (8|M0)               r69.0<1>:d    r69.0<1;1,0>:d    4:w               {Compacted,I@2}
        bfn.0xFE (8|M0)          r43.0<1>:ud   r69.0<1;0>:ud     r80.0<1;0>:ud     r62.0<1>:ud      {I@1} // s0|s1|s2
        cmp (8|M0)    (eq)f1.1   null<1>:d     r43.0<1;1,0>:d    0:w               {I@1}
(~f1.1) goto (8|M0)                          L26744                  L26744                
L26712:
        mov (8|M0)               r47.0<1>:d    0:w                              
        goto (8|M0)                          L26744                  L26904                
L26744:
        join (8|M0)                          L26904                                
L26760:
        cmp (8|M0)    (gt)f1.0   null<1>:ud    r43.0<1;1,0>:ud   0x4:uw             
(~f1.0) goto (8|M0)                          L26824                  L26824                
L26792:
        mov (8|M0)               r47.0<1>:d    1:w                              
        goto (8|M0)                          L26824                  L26904                
L26824:
        join (8|M0)                          L26904                                
L26840:
        and (8|M0)    (ne)f0.1   null<1>:d     r83.0<1;1,0>:d    1:w              
(W)     mov (1|M0)               r6.4<1>:hf    0x1:hf                             
(f0.1)  cmp (8|M0)    (eq)f0.1   null<1>:d     r43.0<1;1,0>:d    4:w              
(f0.1)  sel (8|M0)               r47.0<1>:d    r6.4<0;1,0>:w     0:w               {F@1}
L26904:
        join (8|M0)                          L26984                                
L26920:
        add (8|M0)               r80.0<1>:d    r47.0<1;1,0>:d    r83.0<1;1,0>:d   {Compacted,I@2}
(W)     mov (1|M0)               r6.2<1>:f     0x800000:f                               {Compacted}
        cmp (8|M0)    (gt)f0.1   null<1>:ud    r80.0<1;1,0>:ud   0x7FFFFF:ud              {I@1}
(~f0.1) sel (8|M0)               r113.0<1>:d   r80.0<1;1,0>:d    0:w              
(f0.1)  sel (8|M0)               r112.0<1>:d   r6.2<0;1,0>:d     0:w               {F@1}
L26984:
        join (8|M0)                          L27048                                
L27000:
        and (8|M0)               r79.0<1>:d    r17.0<1;1,0>:d    -2147483648:d              
        bfn.0xFE (8|M0)          r114.0<1>:ud  r79.0<1;0>:ud     r112.0<1;0>:ud    r113.0<1>:ud     {I@1} // s0|s1|s2
        goto (8|M0)                          L27048                  L30248                
L27048:
        join (8|M0)                          L27568                                
L27064:
        and (8|M0)    (ne)f0.1   r83.0<1>:d    r48.0<1;1,0>:d    63:w              
(f0.1)  goto (8|M0)                          L27144                  L27144                
L27096:
        mov (8|M0)               r101.0<1>:d   -1:w                              
        mov (8|M0)               r108.0<1>:d   -1:w                              
        goto (8|M0)                          L27144                  L27328                
L27144:
        join (8|M0)                          L27328                                
L27160:
        cmp (8|M0)    (lt)f0.0   null<1>:ud    r83.0<1;1,0>:ud   0x20:uw              {I@6}
(f0.0)  goto (8|M0)                          L27264                  L27264                
L27192:
        add (8|M0)               acc0.0<1>:d   r83.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r6.4<1>:hf    -qnan(0x1FF):hf                             
        mov (8|M0)               r101.0<1>:d   0:w                              
        shl (8|M0)               r108.0<1>:d   r6.4<0;1,0>:w     acc0.0<1;1,0>:d  {F@1}
        goto (8|M0)                          L27264                  L27328                
L27264:
        join (8|M0)                          L27328                                
L27280:
(W)     mov (1|M0)               r6.4<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (8|M0)               r108.0<1>:d   -1:w                              
        shl (8|M0)               r101.0<1>:d   r6.4<0;1,0>:w     r83.0<1;1,0>:d   {F@1}
L27328:
        join (8|M0)                          L27568                                
L27344:
        bfn.0x60 (8|M0)          r78.0<1>:ud   r101.0<1;0>:ud    r6.6<0;0>:ud      r92.0<1>:ud      {I@2} // (s0^s1)&s2
        bfn.0x60 (8|M0)          r77.0<1>:ud   r108.0<1;0>:ud    r6.6<0;0>:ud      r97.0<1>:ud      // (s0^s1)&s2
        cmp (8|M0)    (ne)f0.0   null<1>:d     r78.0<1;1,0>:d    0:w               {I@2}
        cmp (8|M0)    (gt)f1.1   null<1>:d     r17.0<1;1,0>:d    -1:w              
(~f0.0) cmp (8|M0)    (ne)f0.0   null<1>:d     r77.0<1;1,0>:d    0:w               {I@3}
(f0.0)  cmp (8|M0)    (eq)f0.0   null<1>:d     r63.0<1;1,0>:d    -150:w              
(f1.1)  goto (8|M0)                          L27504                  L27504                
L27456:
(W)     mov (1|M0)               r6.2<1>:ud    0x80000001:ud                             
(f0.0)  sel (8|M0)               r114.0<1>:f   r6.2<0;1,0>:f     -0.0:f               {I@1}
        goto (8|M0)                          L27504                  L30248                
L27504:
        join (8|M0)                          L27568                                
L27520:
(W)     mov (1|M0)               r6.2<1>:ud    0x1:ud                              {F@1}
(f0.0)  sel (8|M0)               r114.0<1>:f   r6.2<0;1,0>:f     0.0:f               {I@1}
        goto (8|M0)                          L27568                  L30248                
L27568:
        join (8|M0)                          L30000                                
L27584:
        cmp (8|M0)    (lt)f0.0   null<1>:ud    r48.0<1;1,0>:ud   0x18:uw              {F@1}
        add3 (8|M0)              r77.0<1>:d    r106.0<1;0>:d     r48.0<1;0>:d      -46:w              
(f0.0)  cmp (8|M0)    (eq)f0.0   null<1>:d     r62.0<1;1,0>:d    0:w              
(f0.0)  goto (8|M0)                          L29680                  L29680                
L27648:
        shl (8|M0)               r121.0<1>:d   r27.0<1;1,0>:d    1:w               {Compacted}
        shr (8|M0)               r120.0<1>:ud  r27.0<1;1,0>:ud   31:w              
        shl (8|M0)               r14.0<1>:d    r90.0<1;1,0>:d    1:w               {Compacted}
        cmp (8|M0)    (lt)f1.1   null<1>:ud    r121.0<1;1,0>:ud  0x4E:uw              {I@3}
        or (8|M0)                r14.0<1>:d    r14.0<1;1,0>:d    r120.0<1;1,0>:d  {Compacted,I@2}
(f1.1)  cmp (8|M0)    (eq)f1.1   null<1>:d     r14.0<1;1,0>:d    0:w               {I@1}
(~f1.1) cmp (8|M0)    (lt)f1.1   null<1>:d     r14.0<1;1,0>:d    0:w              
(f1.1)  goto (8|M0)                          L27880                  L27880                
L27752:
        cmp (8|M0)    (eq)f1.1   null<1>:d     r27.0<1;1,0>:d    39:w              
(f1.1)  cmp (8|M0)    (eq)f1.1   null<1>:d     r90.0<1;1,0>:d    0:w              
(~f1.1) goto (8|M0)                          L27880                  L27944                
L27800:
        shr (8|M0)               r83.0<1>:ud   r92.0<1;1,0>:ud   1:w              
        mov (8|M0)               r74.0<1>:d    0:w                              
        mov (8|M0)               r81.0<1>:d    0:w                              
        mov (8|M0)               r31.0<1>:f    r83.0<1;1,0>:f                   {Compacted,I@3}
        mov (8|M0)               r83.0<1>:f    r92.0<1;1,0>:f                   {Compacted}
        goto (8|M0)                          L27880                  L29144                
L27880:
        join (8|M0)                          L27944                                
L27896:
        cmp (8|M0)    (eq)f1.0   null<1>:d     r27.0<1;1,0>:d    38:w              
(f1.0)  cmp (8|M0)    (eq)f1.0   null<1>:d     r90.0<1;1,0>:d    0:w              
(f1.0)  goto (8|M0)                          L27944                  L29056                
L27944:
        join (8|M0)                          L29056                                
L27960:
        add (8|M0)               acc0.0<1>:d   -r27.0<1;1,0>:d   39:w               {Compacted}
        add (8|M0)               r66.0<1>:d    -r27.0<1;1,0>:d   40:w               {Compacted}
        and (8|M0)    (ne)f1.0   r10.0<1>:d    acc0.0<1;1,0>:d   63:w              
(f1.0)  goto (8|M0)                          L28040                  L28040                
L28008:
        mov (8|M0)               r49.0<1>:d    r92.0<1;1,0>:d                  
        goto (8|M0)                          L28040                  L28176                
L28040:
        join (8|M0)                          L28176                                
L28056:
        cmp (8|M0)    (lt)f0.1   null<1>:ud    r10.0<1;1,0>:ud   0x20:uw              {I@5}
(f0.1)  add (8|M0)               acc0.0<1>:d   -r10.0<1;1,0>:d   32:w              
(~f0.1) add (8|M0)               acc2.0<1>:d   r10.0<1;1,0>:d    -32:w              
(f0.1)  shr (8|M0)               r74.0<1>:ud   r92.0<1;1,0>:ud   r10.0<1;1,0>:d  
(f0.1)  shl (8|M0)               r11.0<1>:d    r97.0<1;1,0>:d    acc0.0<1;1,0>:d 
(~f0.1) shr (8|M0)               r83.0<1>:ud   r97.0<1;1,0>:ud   acc2.0<1;1,0>:d  {F@1}
(f0.1)  or (8|M0)                r83.0<1>:d    r74.0<1;1,0>:d    r11.0<1;1,0>:d   {I@2}
        mov (8|M0)               r49.0<1>:f    r83.0<1;1,0>:f                   {Compacted,I@1}
L28176:
        join (8|M0)                          L29056                                
L28192:
        add (8|M0)               r30.0<1>:d    -r27.0<1;1,0>:d   38:w               {Compacted}
        and (8|M0)    (ne)f0.0   r13.0<1>:d    r30.0<1;1,0>:d    63:w               {I@1}
(f0.0)  goto (8|M0)                          L28264                  L28264                
L28232:
        mov (8|M0)               r83.0<1>:d    r92.0<1;1,0>:d                   {F@1}
        goto (8|M0)                          L28264                  L28392                
L28264:
        join (8|M0)                          L28392                                
L28280:
        cmp (8|M0)    (lt)f1.1   null<1>:ud    r13.0<1;1,0>:ud   0x20:uw              {I@5}
(f1.1)  add (8|M0)               acc0.0<1>:d   -r13.0<1;1,0>:d   32:w              
(~f1.1) add (8|M0)               acc2.0<1>:d   r13.0<1;1,0>:d    -32:w              
(f1.1)  shr (8|M0)               r72.0<1>:ud   r92.0<1;1,0>:ud   r13.0<1;1,0>:d  
(f1.1)  shl (8|M0)               r26.0<1>:d    r97.0<1;1,0>:d    acc0.0<1;1,0>:d 
(~f1.1) shr (8|M0)               r83.0<1>:ud   r97.0<1;1,0>:ud   acc2.0<1;1,0>:d 
(f1.1)  or (8|M0)                r83.0<1>:d    r72.0<1;1,0>:d    r26.0<1;1,0>:d   {I@2}
L28392:
        join (8|M0)                          L29056                                
L28408:
        and (8|M0)    (ne)f1.0   r25.0<1>:d    r30.0<1;1,0>:d    63:w              
        and (8|M0)               r81.0<1>:d    r83.0<1;1,0>:d    1:w               {Compacted,I@3}
(f1.0)  goto (8|M0)                          L28496                  L28496                
L28448:
        mov (8|M0)               r39.0<1>:d    -1:w                              
        mov (8|M0)               r46.0<1>:d    -1:w                              
        goto (8|M0)                          L28496                  L28680                
L28496:
        join (8|M0)                          L28680                                
L28512:
        cmp (8|M0)    (lt)f0.1   null<1>:ud    r25.0<1;1,0>:ud   0x20:uw              {I@7}
(f0.1)  goto (8|M0)                          L28616                  L28616                
L28544:
        add (8|M0)               acc0.0<1>:d   r25.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r6.4<1>:hf    -qnan(0x1FF):hf                             
        mov (8|M0)               r39.0<1>:d    0:w                              
        shl (8|M0)               r46.0<1>:d    r6.4<0;1,0>:w     acc0.0<1;1,0>:d  {F@1}
        goto (8|M0)                          L28616                  L28680                
L28616:
        join (8|M0)                          L28680                                
L28632:
(W)     mov (1|M0)               r6.4<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (8|M0)               r46.0<1>:d    -1:w                              
        shl (8|M0)               r39.0<1>:d    r6.4<0;1,0>:w     r25.0<1;1,0>:d   {F@1}
L28680:
        join (8|M0)                          L29056                                
L28696:
        bfn.0x60 (8|M0)          r71.0<1>:ud   r39.0<1;0>:ud     r6.6<0;0>:ud      r92.0<1>:ud      {I@2} // (s0^s1)&s2
        bfn.0x60 (8|M0)          r70.0<1>:ud   r46.0<1;0>:ud     r6.6<0;0>:ud      r97.0<1>:ud      // (s0^s1)&s2
        cmp (8|M0)    (ne)f0.1   null<1>:d     r71.0<1;1,0>:d    0:w               {I@2}
(W)     mov (1|M0)               r6.4<1>:hf    -qnan(0x1FF):hf                             
        and (8|M0)    (ne)f0.0   r12.0<1>:d    r66.0<1;1,0>:d    63:w              
(~f0.1) cmp (8|M0)    (ne)f0.1   null<1>:d     r70.0<1;1,0>:d    0:w               {I@3}
(f0.1)  sel (8|M0)               acc0.0<1>:d   r6.4<0;1,0>:w     0:w               {F@1}
        mov (8|M0)               r74.0<1>:d    -acc0.0<1;1,0>:d                
(f0.0)  goto (8|M0)                          L28872                  L28872                
L28840:
        mov (8|M0)               r83.0<1>:d    r92.0<1;1,0>:d                  
        goto (8|M0)                          L28872                  L29000                
L28872:
        join (8|M0)                          L29000                                
L28888:
        cmp (8|M0)    (lt)f1.1   null<1>:ud    r12.0<1;1,0>:ud   0x20:uw              {I@7}
(f1.1)  add (8|M0)               acc0.0<1>:d   -r12.0<1;1,0>:d   32:w              
(~f1.1) add (8|M0)               acc2.0<1>:d   r12.0<1;1,0>:d    -32:w              
(f1.1)  shr (8|M0)               r67.0<1>:ud   r92.0<1;1,0>:ud   r12.0<1;1,0>:d  
(f1.1)  shl (8|M0)               r24.0<1>:d    r97.0<1;1,0>:d    acc0.0<1;1,0>:d 
(~f1.1) shr (8|M0)               r83.0<1>:ud   r97.0<1;1,0>:ud   acc2.0<1;1,0>:d 
(f1.1)  or (8|M0)                r83.0<1>:d    r67.0<1;1,0>:d    r24.0<1;1,0>:d   {I@2}
L29000:
        join (8|M0)                          L29056                                
L29016:
        mov (8|M0)               r31.0<1>:f    r83.0<1;1,0>:f                   {Compacted,I@2}
        mov (8|M0)               r83.0<1>:d    r49.0<1;1,0>:d                   {F@1}
        goto (8|M0)                          L29056                  L29144                
L29056:
        join (8|M0)                          L29144                                
L29072:
        shr (8|M0)               r83.0<1>:ud   r92.0<1;1,0>:ud   2:w              
        mov (8|M0)               r74.0<1>:d    0:w                              
        mov (8|M0)               r81.0<1>:d    0:w                              
        mov (8|M0)               r31.0<1>:f    r83.0<1;1,0>:f                   {Compacted,I@3}
        shr (8|M0)               r83.0<1>:ud   r92.0<1;1,0>:ud   1:w               {F@1}
L29144:
        join (8|M0)                          L29680                                
L29160:
        shl (8|M0)               r118.0<1>:d   r83.0<1;1,0>:d    2:w               {Compacted,I@2}
        shl (8|M0)               r66.0<1>:d    r81.0<1;1,0>:d    1:w               {Compacted}
        and (8|M0)               r118.0<1>:d   r118.0<1;1,0>:d   4:w               {Compacted,I@2}
        and (8|M0)               r32.0<1>:d    r31.0<1;1,0>:d    8388607:d              
        bfn.0xFE (8|M0)          r82.0<1>:ud   r118.0<1;0>:ud    r66.0<1;0>:ud     r74.0<1>:ud      {I@2} // s0|s1|s2
        cmp (8|M0)    (eq)f1.0   null<1>:d     r82.0<1;1,0>:d    0:w               {I@1}
(~f1.0) goto (8|M0)                          L29280                  L29280                
L29248:
        mov (8|M0)               r81.0<1>:d    0:w                              
        goto (8|M0)                          L29280                  L29440                
L29280:
        join (8|M0)                          L29440                                
L29296:
        cmp (8|M0)    (gt)f0.1   null<1>:ud    r82.0<1;1,0>:ud   0x4:uw             
(~f0.1) goto (8|M0)                          L29360                  L29360                
L29328:
        mov (8|M0)               r81.0<1>:d    1:w                              
        goto (8|M0)                          L29360                  L29440                
L29360:
        join (8|M0)                          L29440                                
L29376:
        and (8|M0)    (ne)f0.0   null<1>:d     r31.0<1;1,0>:d    1:w              
(W)     mov (1|M0)               r6.4<1>:hf    0x1:hf                             
(f0.0)  cmp (8|M0)    (eq)f0.0   null<1>:d     r82.0<1;1,0>:d    4:w              
(f0.0)  sel (8|M0)               r81.0<1>:d    r6.4<0;1,0>:w     0:w               {F@1}
L29440:
        join (8|M0)                          L29680                                
L29456:
        add (8|M0)               r101.0<1>:d   r32.0<1;1,0>:d    r81.0<1;1,0>:d   {Compacted,I@2}
        add3 (8|M0)              r81.0<1>:d    r106.0<1;0>:d     r48.0<1;0>:d      -45:w              
        cmp (8|M0)    (gt)f0.1   null<1>:ud    r101.0<1;1,0>:ud  0x7FFFFF:ud              {I@2}
(f0.1)  sel (8|M0)               r87.0<1>:d    r81.0<1;1,0>:d    r77.0<1;1,0>:d   {I@2}
        cmp (8|M0)    (eq)f0.0   null<1>:d     r87.0<1;1,0>:d    255:w               {Compacted,I@1}
(f0.0)  goto (8|M0)                          L29608                  L29608                
L29536:
(~f0.1) sel (8|M0)               r85.0<1>:d    r101.0<1;1,0>:d   0:w              
        and (8|M0)               r80.0<1>:d    r17.0<1;1,0>:d    -2147483648:d              
        shl (8|M0)               r65.0<1>:d    r87.0<1;1,0>:d    23:w               {Compacted}
        bfn.0xFE (8|M0)          r114.0<1>:ud  r80.0<1;0>:ud     r65.0<1;0>:ud     r85.0<1>:ud      {I@1} // s0|s1|s2
        goto (8|M0)                          L29608                  L30248                
L29608:
        join (8|M0)                          L29680                                
L29624:
        cmp (8|M0)    (gt)f0.0   null<1>:d     r17.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r6.2<1>:f     inf:f                               {Compacted}
(f0.0)  sel (8|M0)               r114.0<1>:f   r6.2<0;1,0>:f     -inf:f               {A@1}
        goto (8|M0)                          L29680                  L30248                
L29680:
        join (8|M0)                          L30000                                
L29696:
        and (8|M0)    (ne)f1.1   r93.0<1>:d    r48.0<1;1,0>:d    63:w              
(f1.1)  goto (8|M0)                          L29760                  L29760                
L29728:
        mov (8|M0)               r68.0<1>:d    -1:w                              
        goto (8|M0)                          L29760                  L29888                
L29760:
        join (8|M0)                          L29888                                
L29776:
        cmp (8|M0)    (lt)f1.0   null<1>:ud    r93.0<1;1,0>:ud   0x20:uw              {I@5}
(f1.0)  goto (8|M0)                          L29840                  L29840                
L29808:
        mov (8|M0)               r68.0<1>:d    0:w                              
        goto (8|M0)                          L29840                  L29888                
L29840:
        join (8|M0)                          L29888                                
L29856:
(W)     mov (1|M0)               r6.4<1>:hf    -qnan(0x1FF):hf                             
        shl (8|M0)               r68.0<1>:d    r6.4<0;1,0>:w     r93.0<1;1,0>:d   {F@1}
L29888:
        join (8|M0)                          L30000                                
L29904:
        bfn.0x60 (8|M0)          r80.0<1>:ud   r68.0<1;0>:ud     r6.6<0;0>:ud      r92.0<1>:ud      {I@2} // (s0^s1)&s2
        add (8|M0)               acc0.0<1>:d   -r48.0<1;1,0>:d   23:w               {Compacted}
        and (8|M0)               r79.0<1>:d    r17.0<1;1,0>:d    -2147483648:d              
        shl (8|M0)               r63.0<1>:d    r77.0<1;1,0>:d    23:w               {Compacted}
        shl (8|M0)               r80.0<1>:d    r80.0<1;1,0>:d    acc0.0<1;1,0>:d  {I@4}
        bfn.0xFE (8|M0)          r114.0<1>:ud  r79.0<1;0>:ud     r63.0<1;0>:ud     r80.0<1>:ud      {I@1} // s0|s1|s2
        goto (8|M0)                          L30000                  L30248                
L30000:
        join (8|M0)                          L30072                                
L30016:
        cmp (8|M0)    (gt)f1.1   null<1>:d     r17.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r6.2<1>:f     inf:f                               {Compacted}
(f1.1)  sel (8|M0)               r114.0<1>:f   r6.2<0;1,0>:f     -inf:f               {A@1}
        goto (8|M0)                          L30072                  L30248                
L30072:
        join (8|M0)                          L30144                                
L30088:
        cmp (8|M0)    (lt)f1.0   null<1>:d     r17.0<1;1,0>:d    0:w              
(W)     mov (1|M0)               r6.2<1>:f     -0.0:f                               {Compacted}
(f1.0)  sel (8|M0)               r114.0<1>:f   r6.2<0;1,0>:f     0.0:f               {F@1}
        goto (8|M0)                          L30144                  L30248                
L30144:
        join (8|M0)                          L30216                                
L30160:
        cmp (8|M0)    (gt)f0.1   null<1>:d     r17.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r6.2<1>:f     inf:f                               {Compacted}
(f0.1)  sel (8|M0)               r114.0<1>:f   r6.2<0;1,0>:f     -inf:f               {F@1}
        goto (8|M0)                          L30216                  L30248                
L30216:
        join (8|M0)                          L30248                                
L30232:
        bfn.0xF8 (8|M0)          r114.0<1>:ud  r17.0<1;0>:ud     r6.1<0;0>:ud      r6.0<0>:ud       {F@1} // s0&s1|s2
L30248:
        join (8|M0)                          L36744                                
L30264:
        rnde (8|M0)              r79.0<1>:f    r114.0<1;1,0>:f                  {Compacted,I@2}
        shr (8|M0)               r124.0<1>:ud  r79.0<1;1,0>:ud   23:w               {F@1}
        and (8|M0)    (ne)f1.1   r38.0<1>:d    r79.0<1;1,0>:d    8388607:d              
        and (8|M0)               r63.0<1>:d    r124.0<1;1,0>:d   255:w               {Compacted,I@2}
(f1.1)  cmp (8|M0)    (eq)f1.1   null<1>:d     r63.0<1;1,0>:d    255:w               {I@1}
(~f1.1) goto (8|M0)                          L30368                  L30368                
L30344:
        mov (8|M0)               r104.0<1>:f   qnan(0x0):f                               {Compacted}
        goto (8|M0)                          L30368                  L36600                
L30368:
        join (8|M0)                          L36600                                
L30384:
        cmp (8|M0)    (eq)f1.0   null<1>:d     r38.0<1;1,0>:d    0:w              
        add (8|M0)               r92.0<1>:d    r15.0<1;1,0>:d    -25165824:d              
        shr (8|M0)               r116.0<1>:ud  r92.0<1;1,0>:ud   23:w               {I@1}
(f1.0)  cmp (8|M0)    (eq)f1.0   null<1>:d     r63.0<1;1,0>:d    255:w              
        and (8|M0)               r105.0<1>:d   r116.0<1;1,0>:d   255:w               {Compacted,I@2}
        xor (8|M0)               r16.0<1>:d    r92.0<1;1,0>:d    r79.0<1;1,0>:d   {Compacted}
(~f1.0) cmp (8|M0)    (eq)f1.0   null<1>:d     r105.0<1;1,0>:d   255:w               {I@2}
(f1.0)  goto (8|M0)                          L36568                  L36568                
L30496:
        cmp (8|M0)    (eq)f1.0   null<1>:d     r105.0<1;1,0>:d   0:w              
        or (8|M0)                r62.0<1>:d    r63.0<1;1,0>:d    r38.0<1;1,0>:d   {Compacted}
(~f1.0) cmp (8|M0)    (eq)f1.0   null<1>:d     r62.0<1;1,0>:d    0:w               {I@1}
(~f1.0) goto (8|M0)                          L30576                  L30576                
L30552:
        mov (8|M0)               r104.0<1>:f   0.0:f                               {Compacted}
        goto (8|M0)                          L30576                  L36600                
L30576:
        join (8|M0)                          L36568                                
L30592:
        cmp (8|M0)    (eq)f1.0   null<1>:d     r63.0<1;1,0>:d    0:w              
        add (8|M0)               r92.0<1>:d    r63.0<1;1,0>:d    -127:w               {Compacted}
(f1.0)  mov (8|M0)               r92.0<1>:d    -126:w                              
        add (8|M0)               r115.0<1>:d   r105.0<1;1,0>:d   r92.0<1;1,0>:d   {Compacted,I@1}
        cmp (8|M0)    (gt)f0.1   null<1>:d     r115.0<1;1,0>:d   254:w               {I@1}
(f0.1)  goto (8|M0)                          L36496                  L36496                
L30672:
        or (8|M0)     (eq)f0.0   null<4>:b     r124.0<1;1,0>:d   r116.0<1;1,0>:d 
(f0.0)  goto (8|M0)                          L36424                  L36424                
L30704:
(W)     mov (1|M0)               r6.4<1>:hf    0.0:hf                             
(W)     mov (1|M0)               r6.7<1>:d     0:w                              
(f1.0)  sel (8|M0)               acc0.0<1>:d   r6.4<0;1,0>:w     8388608:d               {F@1}
(W)     mov (1|M0)               r6.4<1>:f     -0.0:f                               {Compacted}
        or (8|M0)                r100.0<1>:d   acc0.0<1;1,0>:d   r38.0<1;1,0>:d  
(W)     mov (2|M0)               r7.4<1>:d     0:w                              
        shl (8|M0)               r93.0<1>:d    r100.0<1;1,0>:d   23:w               {Compacted,I@2}
        shr (8|M0)               r96.0<1>:ud   r100.0<1;1,0>:ud  9:w              
L30816:
(W)     shl (1|M0)               r7.2<1>:d     r6.4<0;1,0>:d     31:w               {F@1}
(W)     shr (1|M0)               r7.1<1>:ud    r6.7<0;1,0>:ud    1:w              
(W)     cmp (8|M0)    (gt)f1.1   null<1>:ud    r7.4<0;1,0>:ud    0x3E:uw              {I@5}
(W)     or (1|M0)                r6.7<1>:d     r7.1<0;1,0>:d     r7.2<0;1,0>:d    {I@2}
        bfn.0xE0 (8|M0)          r31.0<1>:ud   r7.1<0;0>:ud      r7.2<0;0>:ud      r93.0<1>:ud      // (s0|s1)&s2
(W)     shr (1|M0)               r6.2<1>:ud    r6.4<0;1,0>:ud    1:w              
(W&f1.1) cmp (8|M0)   (eq)f1.1   null<1>:d     r7.5<0;1,0>:d     0:w              
        cmp (8|M0)    (eq)f1.0   null<1>:d     r31.0<1;1,0>:d    r6.7<0;1,0>:d    {I@3}
(W)     addc (1|M0)              r9.0<1>:ud    r7.4<0;1,0>:ud    0x1:ud              {AccWrEn}
        and (8|M0)               r30.0<1>:d    r6.2<0;1,0>:d     r96.0<1;1,0>:d   {Compacted,I@4}
(W)     mov (1|M0)               r7.0<1>:ud    acc0.0<0;1,0>:ud                 {Compacted}
(W&~f1.1) cmp (8|M0)  (gt)f1.1   null<1>:ud    r7.5<0;1,0>:ud    0x0:uw             
(f1.0)  cmp (8|M0)    (eq)f1.0   null<1>:d     r30.0<1;1,0>:d    r6.2<0;1,0>:d    {I@3}
(W)     add (1|M0)               r7.6<1>:ud    r7.0<0;1,0>:ud    r7.5<0;1,0>:ud   {I@3}
(W)     mov (1|M0)               r7.0<1>:hf    0x1:hf                              {I@1}
        mov (8|M0)               r118.0<1>:d   r7.4<0;1,0>:d                   
(f1.1)  sel (8|M0)               r8.0<1>:uw    r7.0<0;1,0>:uw    0x0:uw              {F@1}
(f1.0)  sel (8|M0)               r7.0<1>:uw    r7.0<0;1,0>:uw    0x0:uw             
        mov (8|M0)               r127.0<1>:d   r7.5<0;1,0>:d                   
        or (8|M0)     (ne)f0.1   null<1>:uw    r8.0<1;1,0>:uw    r7.0<1;1,0>:uw   {I@2}
        mov (8|M0)               r26.0<1>:f    r9.0<0;1,0>:f                    {Compacted}
        mov (8|M0)               r88.0<1>:d    r7.6<0;1,0>:d                   
(f0.1)  goto (8|M0)                          L31224                  L31224                
L31160:
(W)     mov (1|M0)               r6.4<1>:d     r6.2<0;1,0>:d                   
(W)     mov (1|M0)               r7.4<1>:d     r9.0<0;1,0>:d                   
(W)     mov (1|M0)               r7.5<1>:d     r7.6<0;1,0>:d                   
(W)     jmpi                                 L30816                                
L31224:
        join (8|M0)                          L36424                                
L31240:
(W)     mov (1|M0)               r6.2<1>:f     8.68805e-44:f                               {I@5}
(W)     mov (1|M0)               r7.0<1>:hf    0.0:hf                             
        subb (8|M0)              r47.0<1>:ud   r6.2<0;1,0>:ud    r118.0<1;1,0>:ud {AccWrEn,Compacted,F@2}
        add3 (8|M0)              r53.0<1>:d    r115.0<1;0>:d     r47.0<1;0>:d      -173:w               {I@1}
        add3 (8|M0)              r61.0<1>:ud   -acc0.0<1;0>:ud   r7.0<0;0>:uw      -r127.0<1>:ud    {F@1}
        cmp (8|M0)    (gt)f1.1   null<1>:d     r53.0<1;1,0>:d    127:w               {I@2}
        add3 (8|M0)              r35.0<1>:d    r105.0<1;0>:d     r92.0<1;0>:d      r47.0<1>:d      
(f1.1)  goto (8|M0)                          L36352                  L36352                
L31360:
        cmp (8|M0)    (gt)f1.0   null<1>:d     r53.0<1;1,0>:d    -127:w              
(f1.0)  goto (8|M0)                          L33920                  L33920                
L31392:
        cmp (8|M0)    (lt)f0.1   null<1>:ud    r53.0<1;1,0>:ud   0xFFFFFF6B:ud             
(f0.1)  goto (8|M0)                          L33400                  L33400                
L31424:
(W)     mov (1|M0)               r6.2<1>:f     8.82818e-44:f                              
        add3 (8|M0)              r61.0<1>:d    r115.0<1;0>:d     r47.0<1;0>:d      -23:w              
        subb (8|M0)              r77.0<1>:ud   r6.2<0;1,0>:ud    r118.0<1;1,0>:ud {AccWrEn,Compacted,F@1}
(W)     mov (1|M0)               r7.0<1>:hf    0.0:hf                              {I@7}
        cmp (8|M0)    (gt)f0.1   null<1>:ud    r77.0<1;1,0>:ud   r61.0<1;1,0>:ud  {I@1}
        add3 (8|M0)              r91.0<1>:ud   -acc0.0<1;0>:ud   r7.0<0;0>:uw      -r127.0<1>:ud    {F@1}
(f0.1)  cmp (8|M0)    (eq)f0.1   null<1>:d     r91.0<1;1,0>:d    0:w               {I@1}
(~f0.1) cmp (8|M0)    (gt)f0.1   null<1>:ud    r91.0<1;1,0>:ud   0x0:uw             
(f0.1)  goto (8|M0)                          L31624                  L31624                
L31560:
        add3 (8|M0)              acc0.0<1>:d   r35.0<1;0>:d      -r77.0<1;0>:d     -23:w              
        mov (8|M0)               r107.0<1>:d   0:w                              
        shl (8|M0)               r108.0<1>:d   r93.0<1;1,0>:d    acc0.0<1;1,0>:d 
        goto (8|M0)                          L31624                  L33336                
L31624:
        join (8|M0)                          L33336                                
L31640:
        add3 (8|M0)              r76.0<1>:d    r77.0<1;0>:d      -r35.0<1;0>:d     23:w              
        cmp (8|M0)    (lt)f0.0   null<1>:d     r76.0<1;1,0>:d    2:w               {Compacted,I@1}
(f0.0)  goto (8|M0)                          L31784                  L31784                
L31680:
        cmp (8|M0)    (eq)f1.1   null<1>:d     r76.0<1;1,0>:d    2:w              
(~f1.1) goto (8|M0)                          L31784                  L31888                
L31712:
        shr (8|M0)               r85.0<1>:ud   r93.0<1;1,0>:ud   1:w              
        mov (8|M0)               r57.0<1>:d    0:w                              
        mov (8|M0)               r53.0<1>:d    0:w                              
        mov (8|M0)               r45.0<1>:f    r85.0<1;1,0>:f                   {Compacted,I@3}
        goto (8|M0)                          L31784                  L32776                
L31784:
        join (8|M0)                          L31888                                
L31800:
        cmp (8|M0)    (eq)f1.0   null<1>:d     r76.0<1;1,0>:d    1:w              
(~f1.0) goto (8|M0)                          L31888                  L31888                
L31832:
        mov (8|M0)               r57.0<1>:d    0:w                              
        mov (8|M0)               r53.0<1>:d    0:w                              
        mov (8|M0)               r45.0<1>:f    r93.0<1;1,0>:f                   {Compacted}
        goto (8|M0)                          L31888                  L32776                
L31888:
        join (8|M0)                          L32776                                
L31904:
        add3 (8|M0)              acc0.0<1>:d   r77.0<1;0>:d      -r61.0<1;0>:d     -1:w              
        and (8|M0)    (ne)f0.1   r109.0<1>:d   acc0.0<1;1,0>:d   63:w              
(f0.1)  goto (8|M0)                          L31984                  L31984                
L31952:
        mov (8|M0)               r44.0<1>:d    r93.0<1;1,0>:d                  
        goto (8|M0)                          L31984                  L32120                
L31984:
        join (8|M0)                          L32120                                
L32000:
        cmp (8|M0)    (lt)f0.0   null<1>:ud    r109.0<1;1,0>:ud  0x20:uw              {I@5}
(f0.0)  add (8|M0)               acc0.0<1>:d   -r109.0<1;1,0>:d  32:w              
(~f0.0) add (8|M0)               acc2.0<1>:d   r109.0<1;1,0>:d   -32:w              
(f0.0)  shr (8|M0)               r58.0<1>:ud   r93.0<1;1,0>:ud   r109.0<1;1,0>:d 
(f0.0)  shl (8|M0)               r100.0<1>:d   r96.0<1;1,0>:d    acc0.0<1;1,0>:d 
(~f0.0) shr (8|M0)               r85.0<1>:ud   r96.0<1;1,0>:ud   acc2.0<1;1,0>:d  {F@2}
(f0.0)  or (8|M0)                r85.0<1>:d    r58.0<1;1,0>:d    r100.0<1;1,0>:d  {I@2}
        mov (8|M0)               r44.0<1>:f    r85.0<1;1,0>:f                   {Compacted,I@1}
L32120:
        join (8|M0)                          L32776                                
L32136:
        add3 (8|M0)              r115.0<1>:d   r77.0<1;0>:d      -r61.0<1;0>:d     -2:w              
        and (8|M0)    (ne)f1.1   r108.0<1>:d   r115.0<1;1,0>:d   63:w               {I@1}
(f1.1)  goto (8|M0)                          L32216                  L32216                
L32184:
        mov (8|M0)               r85.0<1>:d    r93.0<1;1,0>:d                   {F@1}
        goto (8|M0)                          L32216                  L32344                
L32216:
        join (8|M0)                          L32344                                
L32232:
        cmp (8|M0)    (lt)f1.0   null<1>:ud    r108.0<1;1,0>:ud  0x20:uw              {I@5}
(f1.0)  add (8|M0)               acc0.0<1>:d   -r108.0<1;1,0>:d  32:w              
(~f1.0) add (8|M0)               acc2.0<1>:d   r108.0<1;1,0>:d   -32:w              
(f1.0)  shr (8|M0)               r56.0<1>:ud   r93.0<1;1,0>:ud   r108.0<1;1,0>:d 
(f1.0)  shl (8|M0)               r99.0<1>:d    r96.0<1;1,0>:d    acc0.0<1;1,0>:d 
(~f1.0) shr (8|M0)               r85.0<1>:ud   r96.0<1;1,0>:ud   acc2.0<1;1,0>:d 
(f1.0)  or (8|M0)                r85.0<1>:d    r56.0<1;1,0>:d    r99.0<1;1,0>:d   {I@2}
L32344:
        join (8|M0)                          L32776                                
L32360:
        and (8|M0)    (ne)f0.1   r98.0<1>:d    r115.0<1;1,0>:d   63:w              
(f0.1)  goto (8|M0)                          L32440                  L32440                
L32392:
        mov (8|M0)               r107.0<1>:d   -1:w                              
        mov (8|M0)               r117.0<1>:d   -1:w                              
        goto (8|M0)                          L32440                  L32624                
L32440:
        join (8|M0)                          L32624                                
L32456:
        cmp (8|M0)    (lt)f0.0   null<1>:ud    r98.0<1;1,0>:ud   0x20:uw              {I@6}
(f0.0)  goto (8|M0)                          L32560                  L32560                
L32488:
        add (8|M0)               acc0.0<1>:d   r98.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r6.4<1>:hf    -qnan(0x1FF):hf                             
        mov (8|M0)               r107.0<1>:d   0:w                              
        shl (8|M0)               r117.0<1>:d   r6.4<0;1,0>:w     acc0.0<1;1,0>:d  {F@1}
        goto (8|M0)                          L32560                  L32624                
L32560:
        join (8|M0)                          L32624                                
L32576:
(W)     mov (1|M0)               r6.4<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (8|M0)               r117.0<1>:d   -1:w                              
        shl (8|M0)               r107.0<1>:d   r6.4<0;1,0>:w     r98.0<1;1,0>:d   {F@1}
L32624:
        join (8|M0)                          L32776                                
L32640:
        bfn.0x60 (8|M0)          r55.0<1>:ud   r107.0<1;0>:ud    r6.6<0;0>:ud      r93.0<1>:ud      {I@2} // (s0^s1)&s2
        bfn.0x60 (8|M0)          r54.0<1>:ud   r117.0<1;0>:ud    r6.6<0;0>:ud      r96.0<1>:ud      // (s0^s1)&s2
        cmp (8|M0)    (ne)f0.1   null<1>:d     r55.0<1;1,0>:d    0:w               {I@2}
(W)     mov (1|M0)               r6.4<1>:hf    -qnan(0x1FF):hf                             
        shl (8|M0)               r52.0<1>:d    r85.0<1;1,0>:d    1:w               {Compacted}
        mov (8|M0)               r45.0<1>:f    r44.0<1;1,0>:f                   {Compacted}
(~f0.1) cmp (8|M0)    (ne)f0.1   null<1>:d     r54.0<1;1,0>:d    0:w               {I@3}
(f0.1)  sel (8|M0)               acc0.0<1>:d   r6.4<0;1,0>:w     0:w               {F@2}
        mov (8|M0)               r57.0<1>:d    -acc0.0<1;1,0>:d                
        and (8|M0)               r53.0<1>:d    r52.0<1;1,0>:d    2:w               {Compacted,I@4}
L32776:
        join (8|M0)                          L33336                                
L32792:
        and (8|M0)    (ne)f1.1   r107.0<1>:d   r76.0<1;1,0>:d    63:w              
(f1.1)  goto (8|M0)                          L32856                  L32856                
L32824:
        mov (8|M0)               r85.0<1>:d    r93.0<1;1,0>:d                  
        goto (8|M0)                          L32856                  L32984                
L32856:
        join (8|M0)                          L32984                                
L32872:
        cmp (8|M0)    (lt)f1.0   null<1>:ud    r107.0<1;1,0>:ud  0x20:uw              {I@5}
(f1.0)  add (8|M0)               acc0.0<1>:d   -r107.0<1;1,0>:d  32:w              
(~f1.0) add (8|M0)               acc2.0<1>:d   r107.0<1;1,0>:d   -32:w              
(f1.0)  shr (8|M0)               r50.0<1>:ud   r93.0<1;1,0>:ud   r107.0<1;1,0>:d 
(f1.0)  shl (8|M0)               r97.0<1>:d    r96.0<1;1,0>:d    acc0.0<1;1,0>:d 
(~f1.0) shr (8|M0)               r85.0<1>:ud   r96.0<1;1,0>:ud   acc2.0<1;1,0>:d 
(f1.0)  or (8|M0)                r85.0<1>:d    r50.0<1;1,0>:d    r97.0<1;1,0>:d   {I@2}
L32984:
        join (8|M0)                          L33336                                
L33000:
        shl (8|M0)               r46.0<1>:d    r45.0<1;1,0>:d    2:w               {Compacted,F@1}
        and (8|M0)               r46.0<1>:d    r46.0<1;1,0>:d    4:w               {Compacted,I@1}
        bfn.0xFE (8|M0)          r39.0<1>:ud   r46.0<1;0>:ud     r53.0<1;0>:ud     r57.0<1>:ud      {I@1} // s0|s1|s2
        cmp (8|M0)    (eq)f0.1   null<1>:d     r39.0<1;1,0>:d    0:w               {I@1}
(~f0.1) goto (8|M0)                          L33096                  L33096                
L33064:
        mov (8|M0)               r42.0<1>:d    0:w                              
        goto (8|M0)                          L33096                  L33256                
L33096:
        join (8|M0)                          L33256                                
L33112:
        cmp (8|M0)    (gt)f0.0   null<1>:ud    r39.0<1;1,0>:ud   0x4:uw             
(~f0.0) goto (8|M0)                          L33176                  L33176                
L33144:
        mov (8|M0)               r42.0<1>:d    1:w                              
        goto (8|M0)                          L33176                  L33256                
L33176:
        join (8|M0)                          L33256                                
L33192:
        and (8|M0)    (ne)f0.0   null<1>:d     r85.0<1;1,0>:d    1:w              
(W)     mov (1|M0)               r6.4<1>:hf    0x1:hf                             
(f0.0)  cmp (8|M0)    (eq)f0.0   null<1>:d     r39.0<1;1,0>:d    4:w              
(f0.0)  sel (8|M0)               r42.0<1>:d    r6.4<0;1,0>:w     0:w               {F@1}
L33256:
        join (8|M0)                          L33336                                
L33272:
        add (8|M0)               r77.0<1>:d    r42.0<1;1,0>:d    r85.0<1;1,0>:d   {Compacted,I@2}
(W)     mov (1|M0)               r6.2<1>:f     0x800000:f                               {Compacted}
        cmp (8|M0)    (gt)f0.0   null<1>:ud    r77.0<1;1,0>:ud   0x7FFFFF:ud              {I@1}
(~f0.0) sel (8|M0)               r108.0<1>:d   r77.0<1;1,0>:d    0:w              
(f0.0)  sel (8|M0)               r107.0<1>:d   r6.2<0;1,0>:d     0:w               {F@1}
L33336:
        join (8|M0)                          L33400                                
L33352:
        and (8|M0)               r49.0<1>:d    r16.0<1;1,0>:d    -2147483648:d              
        bfn.0xFE (8|M0)          r104.0<1>:ud  r49.0<1;0>:ud     r107.0<1;0>:ud    r108.0<1>:ud     {I@1} // s0|s1|s2
        goto (8|M0)                          L33400                  L36600                
L33400:
        join (8|M0)                          L33920                                
L33416:
        and (8|M0)    (ne)f1.1   r67.0<1>:d    r47.0<1;1,0>:d    63:w              
(f1.1)  goto (8|M0)                          L33496                  L33496                
L33448:
        mov (8|M0)               r78.0<1>:d    -1:w                              
        mov (8|M0)               r95.0<1>:d    -1:w                              
        goto (8|M0)                          L33496                  L33680                
L33496:
        join (8|M0)                          L33680                                
L33512:
        cmp (8|M0)    (lt)f1.0   null<1>:ud    r67.0<1;1,0>:ud   0x20:uw              {I@6}
(f1.0)  goto (8|M0)                          L33616                  L33616                
L33544:
        add (8|M0)               acc0.0<1>:d   r67.0<1;1,0>:d    -32:w               {Compacted}
(W)     mov (1|M0)               r6.4<1>:hf    -qnan(0x1FF):hf                             
        mov (8|M0)               r78.0<1>:d    0:w                              
        shl (8|M0)               r95.0<1>:d    r6.4<0;1,0>:w     acc0.0<1;1,0>:d  {F@1}
        goto (8|M0)                          L33616                  L33680                
L33616:
        join (8|M0)                          L33680                                
L33632:
(W)     mov (1|M0)               r6.4<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (8|M0)               r95.0<1>:d    -1:w                              
        shl (8|M0)               r78.0<1>:d    r6.4<0;1,0>:w     r67.0<1;1,0>:d   {F@1}
L33680:
        join (8|M0)                          L33920                                
L33696:
        bfn.0x60 (8|M0)          r48.0<1>:ud   r78.0<1;0>:ud     r6.6<0;0>:ud      r93.0<1>:ud      {I@2} // (s0^s1)&s2
        bfn.0x60 (8|M0)          r47.0<1>:ud   r95.0<1;0>:ud     r6.6<0;0>:ud      r96.0<1>:ud      // (s0^s1)&s2
        cmp (8|M0)    (ne)f1.0   null<1>:d     r48.0<1;1,0>:d    0:w               {I@2}
        cmp (8|M0)    (gt)f0.1   null<1>:d     r16.0<1;1,0>:d    -1:w              
(~f1.0) cmp (8|M0)    (ne)f1.0   null<1>:d     r47.0<1;1,0>:d    0:w               {I@3}
(f1.0)  cmp (8|M0)    (eq)f1.0   null<1>:d     r53.0<1;1,0>:d    -150:w              
(f0.1)  goto (8|M0)                          L33856                  L33856                
L33808:
(W)     mov (1|M0)               r6.2<1>:ud    0x80000001:ud                             
(f1.0)  sel (8|M0)               r104.0<1>:f   r6.2<0;1,0>:f     -0.0:f               {I@1}
        goto (8|M0)                          L33856                  L36600                
L33856:
        join (8|M0)                          L33920                                
L33872:
(W)     mov (1|M0)               r6.2<1>:ud    0x1:ud                              {F@1}
(f1.0)  sel (8|M0)               r104.0<1>:f   r6.2<0;1,0>:f     0.0:f               {I@1}
        goto (8|M0)                          L33920                  L36600                
L33920:
        join (8|M0)                          L36352                                
L33936:
        cmp (8|M0)    (lt)f1.1   null<1>:ud    r47.0<1;1,0>:ud   0x18:uw             
        add3 (8|M0)              r69.0<1>:d    r115.0<1;0>:d     r47.0<1;0>:d      -46:w              
(f1.1)  cmp (8|M0)    (eq)f1.1   null<1>:d     r61.0<1;1,0>:d    0:w              
(f1.1)  goto (8|M0)                          L36032                  L36032                
L34000:
        shl (8|M0)               r111.0<1>:d   r26.0<1;1,0>:d    1:w               {Compacted}
        shr (8|M0)               r110.0<1>:ud  r26.0<1;1,0>:ud   31:w              
        shl (8|M0)               r9.0<1>:d     r88.0<1;1,0>:d    1:w               {Compacted}
        cmp (8|M0)    (lt)f0.0   null<1>:ud    r111.0<1;1,0>:ud  0x4E:uw              {I@3}
        or (8|M0)                r9.0<1>:d     r9.0<1;1,0>:d     r110.0<1;1,0>:d  {Compacted,I@2}
(f0.0)  cmp (8|M0)    (eq)f0.0   null<1>:d     r9.0<1;1,0>:d     0:w               {I@1}
(~f0.0) cmp (8|M0)    (lt)f0.0   null<1>:d     r9.0<1;1,0>:d     0:w              
(f0.0)  goto (8|M0)                          L34232                  L34232                
L34104:
        cmp (8|M0)    (eq)f1.0   null<1>:d     r26.0<1;1,0>:d    39:w               {F@1}
(f1.0)  cmp (8|M0)    (eq)f1.0   null<1>:d     r88.0<1;1,0>:d    0:w              
(~f1.0) goto (8|M0)                          L34232                  L34296                
L34152:
        shr (8|M0)               r85.0<1>:ud   r93.0<1;1,0>:ud   1:w              
        mov (8|M0)               r73.0<1>:d    0:w                              
        mov (8|M0)               r44.0<1>:d    0:w                              
        mov (8|M0)               r25.0<1>:f    r85.0<1;1,0>:f                   {Compacted,I@3}
        mov (8|M0)               r85.0<1>:f    r93.0<1;1,0>:f                   {Compacted}
        goto (8|M0)                          L34232                  L35504                
L34232:
        join (8|M0)                          L34296                                
L34248:
        cmp (8|M0)    (eq)f0.1   null<1>:d     r26.0<1;1,0>:d    38:w              
(f0.1)  cmp (8|M0)    (eq)f0.1   null<1>:d     r88.0<1;1,0>:d    0:w              
(f0.1)  goto (8|M0)                          L34296                  L35416                
L34296:
        join (8|M0)                          L35416                                
L34312:
        add (8|M0)               acc0.0<1>:d   -r26.0<1;1,0>:d   39:w               {Compacted}
        add (8|M0)               r65.0<1>:d    -r26.0<1;1,0>:d   40:w               {Compacted}
        and (8|M0)    (ne)f0.0   r120.0<1>:d   acc0.0<1;1,0>:d   63:w              
(f0.0)  goto (8|M0)                          L34392                  L34392                
L34360:
        mov (8|M0)               r50.0<1>:d    r93.0<1;1,0>:d                  
        goto (8|M0)                          L34392                  L34528                
L34392:
        join (8|M0)                          L34528                                
L34408:
        cmp (8|M0)    (lt)f1.1   null<1>:ud    r120.0<1;1,0>:ud  0x20:uw              {I@5}
(f1.1)  add (8|M0)               acc0.0<1>:d   -r120.0<1;1,0>:d  32:w              
(~f1.1) add (8|M0)               acc2.0<1>:d   r120.0<1;1,0>:d   -32:w              
(f1.1)  shr (8|M0)               r44.0<1>:ud   r93.0<1;1,0>:ud   r120.0<1;1,0>:d 
(f1.1)  shl (8|M0)               r116.0<1>:d   r96.0<1;1,0>:d    acc0.0<1;1,0>:d 
(~f1.1) shr (8|M0)               r85.0<1>:ud   r96.0<1;1,0>:ud   acc2.0<1;1,0>:d  {F@1}
(f1.1)  or (8|M0)                r85.0<1>:d    r44.0<1;1,0>:d    r116.0<1;1,0>:d  {I@2}
        mov (8|M0)               r50.0<1>:f    r85.0<1;1,0>:f                   {Compacted,I@1}
L34528:
        join (8|M0)                          L35416                                
L34544:
        add (8|M0)               r26.0<1>:d    -r26.0<1;1,0>:d   38:w               {Compacted}
        and (8|M0)    (ne)f1.0   r8.0<1>:d     r26.0<1;1,0>:d    63:w               {I@1}
(f1.0)  goto (8|M0)                          L34616                  L34616                
L34584:
        mov (8|M0)               r43.0<1>:d    r93.0<1;1,0>:d                  
        goto (8|M0)                          L34616                  L34752                
L34616:
        join (8|M0)                          L34752                                
L34632:
        cmp (8|M0)    (lt)f0.1   null<1>:ud    r8.0<1;1,0>:ud    0x20:uw              {I@5}
(f0.1)  add (8|M0)               acc0.0<1>:d   -r8.0<1;1,0>:d    32:w              
(~f0.1) add (8|M0)               acc2.0<1>:d   r8.0<1;1,0>:d     -32:w              
(f0.1)  shr (8|M0)               r42.0<1>:ud   r93.0<1;1,0>:ud   r8.0<1;1,0>:d   
(f0.1)  shl (8|M0)               r9.0<1>:d     r96.0<1;1,0>:d    acc0.0<1;1,0>:d 
(~f0.1) shr (8|M0)               r85.0<1>:ud   r96.0<1;1,0>:ud   acc2.0<1;1,0>:d  {F@1}
(f0.1)  or (8|M0)                r85.0<1>:d    r42.0<1;1,0>:d    r9.0<1;1,0>:d    {I@2}
        mov (8|M0)               r43.0<1>:f    r85.0<1;1,0>:f                   {Compacted,I@1}
L34752:
        join (8|M0)                          L35416                                
L34768:
        and (8|M0)    (ne)f0.0   r7.0<1>:d     r26.0<1;1,0>:d    63:w              
(f0.0)  goto (8|M0)                          L34848                  L34848                
L34800:
        mov (8|M0)               r23.0<1>:d    -1:w                              
        mov (8|M0)               r37.0<1>:d    -1:w                              
        goto (8|M0)                          L34848                  L35032                
L34848:
        join (8|M0)                          L35032                                
L34864:
        cmp (8|M0)    (lt)f1.1   null<1>:ud    r7.0<1;1,0>:ud    0x20:uw              {I@6}
(f1.1)  goto (8|M0)                          L34968                  L34968                
L34896:
        add (8|M0)               acc0.0<1>:d   r7.0<1;1,0>:d     -32:w               {Compacted}
(W)     mov (1|M0)               r6.4<1>:hf    -qnan(0x1FF):hf                             
        mov (8|M0)               r23.0<1>:d    0:w                              
        shl (8|M0)               r37.0<1>:d    r6.4<0;1,0>:w     acc0.0<1;1,0>:d  {F@1}
        goto (8|M0)                          L34968                  L35032                
L34968:
        join (8|M0)                          L35032                                
L34984:
(W)     mov (1|M0)               r6.4<1>:hf    -qnan(0x1FF):hf                              {I@3}
        mov (8|M0)               r37.0<1>:d    -1:w                              
        shl (8|M0)               r23.0<1>:d    r6.4<0;1,0>:w     r7.0<1;1,0>:d    {F@1}
L35032:
        join (8|M0)                          L35416                                
L35048:
        bfn.0x60 (8|M0)          r41.0<1>:ud   r23.0<1;0>:ud     r6.6<0;0>:ud      r93.0<1>:ud      {I@2} // (s0^s1)&s2
        bfn.0x60 (8|M0)          r40.0<1>:ud   r37.0<1;0>:ud     r6.6<0;0>:ud      r96.0<1>:ud      // (s0^s1)&s2
        cmp (8|M0)    (ne)f0.0   null<1>:d     r41.0<1;1,0>:d    0:w               {I@2}
(W)     mov (1|M0)               r6.4<1>:hf    -qnan(0x1FF):hf                             
        and (8|M0)    (ne)f1.0   r7.0<1>:d     r65.0<1;1,0>:d    63:w              
(~f0.0) cmp (8|M0)    (ne)f0.0   null<1>:d     r40.0<1;1,0>:d    0:w               {I@3}
(f0.0)  sel (8|M0)               acc0.0<1>:d   r6.4<0;1,0>:w     0:w               {F@1}
        mov (8|M0)               r73.0<1>:d    -acc0.0<1;1,0>:d                
(f1.0)  goto (8|M0)                          L35224                  L35224                
L35192:
        mov (8|M0)               r85.0<1>:d    r93.0<1;1,0>:d                  
        goto (8|M0)                          L35224                  L35352                
L35224:
        join (8|M0)                          L35352                                
L35240:
        cmp (8|M0)    (lt)f0.1   null<1>:ud    r7.0<1;1,0>:ud    0x20:uw              {I@7}
(f0.1)  add (8|M0)               acc0.0<1>:d   -r7.0<1;1,0>:d    32:w              
(~f0.1) add (8|M0)               acc2.0<1>:d   r7.0<1;1,0>:d     -32:w              
(f0.1)  shr (8|M0)               r37.0<1>:ud   r93.0<1;1,0>:ud   r7.0<1;1,0>:d   
(f0.1)  shl (8|M0)               r127.0<1>:d   r96.0<1;1,0>:d    acc0.0<1;1,0>:d 
(~f0.1) shr (8|M0)               r85.0<1>:ud   r96.0<1;1,0>:ud   acc2.0<1;1,0>:d 
(f0.1)  or (8|M0)                r85.0<1>:d    r37.0<1;1,0>:d    r127.0<1;1,0>:d  {I@2}
L35352:
        join (8|M0)                          L35416                                
L35368:
        shl (8|M0)               r36.0<1>:d    r43.0<1;1,0>:d    1:w               {Compacted}
        mov (8|M0)               r25.0<1>:f    r85.0<1;1,0>:f                   {Compacted,I@3}
        and (8|M0)               r44.0<1>:d    r36.0<1;1,0>:d    2:w               {Compacted,I@1}
        mov (8|M0)               r85.0<1>:f    r50.0<1;1,0>:f                   {Compacted}
        goto (8|M0)                          L35416                  L35504                
L35416:
        join (8|M0)                          L35504                                
L35432:
        shr (8|M0)               r85.0<1>:ud   r93.0<1;1,0>:ud   2:w               {F@1}
        mov (8|M0)               r73.0<1>:d    0:w                              
        mov (8|M0)               r44.0<1>:d    0:w                              
        mov (8|M0)               r25.0<1>:f    r85.0<1;1,0>:f                   {Compacted,I@3}
        shr (8|M0)               r85.0<1>:ud   r93.0<1;1,0>:ud   1:w               {F@1}
L35504:
        join (8|M0)                          L36032                                
L35520:
        shl (8|M0)               r94.0<1>:d    r85.0<1;1,0>:d    2:w               {Compacted,I@2}
        and (8|M0)               r21.0<1>:d    r25.0<1;1,0>:d    8388607:d              
        and (8|M0)               r94.0<1>:d    r94.0<1;1,0>:d    4:w               {Compacted,I@2}
        bfn.0xFE (8|M0)          r66.0<1>:ud   r94.0<1;0>:ud     r44.0<1;0>:ud     r73.0<1>:ud      {I@1} // s0|s1|s2
        cmp (8|M0)    (eq)f0.0   null<1>:d     r66.0<1;1,0>:d    0:w               {Compacted,I@1}
(~f0.0) goto (8|M0)                          L35624                  L35624                
L35592:
        mov (8|M0)               r65.0<1>:d    0:w                              
        goto (8|M0)                          L35624                  L35784                
L35624:
        join (8|M0)                          L35784                                
L35640:
        cmp (8|M0)    (gt)f1.1   null<1>:ud    r66.0<1;1,0>:ud   0x4:uw             
(~f1.1) goto (8|M0)                          L35704                  L35704                
L35672:
        mov (8|M0)               r65.0<1>:d    1:w                              
        goto (8|M0)                          L35704                  L35784                
L35704:
        join (8|M0)                          L35784                                
L35720:
        and (8|M0)    (ne)f1.1   null<1>:d     r25.0<1;1,0>:d    1:w              
(W)     mov (1|M0)               r6.4<1>:hf    0x1:hf                             
(f1.1)  cmp (8|M0)    (eq)f1.1   null<1>:d     r66.0<1;1,0>:d    4:w              
(f1.1)  sel (8|M0)               r65.0<1>:d    r6.4<0;1,0>:w     0:w               {F@1}
L35784:
        join (8|M0)                          L36032                                
L35800:
        add (8|M0)               r90.0<1>:d    r21.0<1;1,0>:d    r65.0<1;1,0>:d   {Compacted,I@2}
        add3 (8|M0)              r67.0<1>:d    r115.0<1;0>:d     r47.0<1;0>:d      -45:w              
        cmp (8|M0)    (gt)f1.1   null<1>:ud    r90.0<1;1,0>:ud   0x7FFFFF:ud              {I@2}
(f1.1)  sel (8|M0)               r84.0<1>:d    r67.0<1;1,0>:d    r69.0<1;1,0>:d   {I@2}
        cmp (8|M0)    (eq)f1.0   null<1>:d     r84.0<1;1,0>:d    255:w               {I@1}
(f1.0)  goto (8|M0)                          L35960                  L35960                
L35888:
(~f1.1) sel (8|M0)               r78.0<1>:d    r90.0<1;1,0>:d    0:w              
        and (8|M0)               r66.0<1>:d    r16.0<1;1,0>:d    -2147483648:d              
        shl (8|M0)               r35.0<1>:d    r84.0<1;1,0>:d    23:w               {Compacted}
        bfn.0xFE (8|M0)          r104.0<1>:ud  r66.0<1;0>:ud     r35.0<1;0>:ud     r78.0<1>:ud      {I@1} // s0|s1|s2
        goto (8|M0)                          L35960                  L36600                
L35960:
        join (8|M0)                          L36032                                
L35976:
        cmp (8|M0)    (gt)f0.0   null<1>:d     r16.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r6.2<1>:f     inf:f                               {Compacted}
(f0.0)  sel (8|M0)               r104.0<1>:f   r6.2<0;1,0>:f     -inf:f               {A@1}
        goto (8|M0)                          L36032                  L36600                
L36032:
        join (8|M0)                          L36352                                
L36048:
        and (8|M0)    (ne)f0.1   r86.0<1>:d    r47.0<1;1,0>:d    63:w              
(f0.1)  goto (8|M0)                          L36112                  L36112                
L36080:
        mov (8|M0)               r56.0<1>:d    -1:w                              
        goto (8|M0)                          L36112                  L36240                
L36112:
        join (8|M0)                          L36240                                
L36128:
        cmp (8|M0)    (lt)f0.0   null<1>:ud    r86.0<1;1,0>:ud   0x20:uw              {A@1}
(f0.0)  goto (8|M0)                          L36192                  L36192                
L36160:
        mov (8|M0)               r56.0<1>:d    0:w                              
        goto (8|M0)                          L36192                  L36240                
L36192:
        join (8|M0)                          L36240                                
L36208:
(W)     mov (1|M0)               r6.4<1>:hf    -qnan(0x1FF):hf                             
        shl (8|M0)               r56.0<1>:d    r6.4<0;1,0>:w     r86.0<1;1,0>:d   {F@1}
L36240:
        join (8|M0)                          L36352                                
L36256:
        bfn.0x60 (8|M0)          r55.0<1>:ud   r56.0<1;0>:ud     r6.6<0;0>:ud      r93.0<1>:ud      {I@2} // (s0^s1)&s2
        add (8|M0)               acc0.0<1>:d   -r47.0<1;1,0>:d   23:w               {Compacted}
        and (8|M0)               r61.0<1>:d    r16.0<1;1,0>:d    -2147483648:d              
        shl (8|M0)               r33.0<1>:d    r69.0<1;1,0>:d    23:w               {Compacted}
        shl (8|M0)               r55.0<1>:d    r55.0<1;1,0>:d    acc0.0<1;1,0>:d  {I@4}
        bfn.0xFE (8|M0)          r104.0<1>:ud  r61.0<1;0>:ud     r33.0<1;0>:ud     r55.0<1>:ud      {I@1} // s0|s1|s2
        goto (8|M0)                          L36352                  L36600                
L36352:
        join (8|M0)                          L36424                                
L36368:
        cmp (8|M0)    (gt)f1.1   null<1>:d     r16.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r6.2<1>:f     inf:f                               {Compacted}
(f1.1)  sel (8|M0)               r104.0<1>:f   r6.2<0;1,0>:f     -inf:f               {A@1}
        goto (8|M0)                          L36424                  L36600                
L36424:
        join (8|M0)                          L36496                                
L36440:
        cmp (8|M0)    (lt)f1.0   null<1>:d     r16.0<1;1,0>:d    0:w              
(W)     mov (1|M0)               r6.2<1>:f     -0.0:f                               {Compacted}
(f1.0)  sel (8|M0)               r104.0<1>:f   r6.2<0;1,0>:f     0.0:f               {F@1}
        goto (8|M0)                          L36496                  L36600                
L36496:
        join (8|M0)                          L36568                                
L36512:
        cmp (8|M0)    (gt)f0.1   null<1>:d     r16.0<1;1,0>:d    -1:w              
(W)     mov (1|M0)               r6.2<1>:f     inf:f                               {Compacted}
(f0.1)  sel (8|M0)               r104.0<1>:f   r6.2<0;1,0>:f     -inf:f               {F@1}
        goto (8|M0)                          L36568                  L36600                
L36568:
        join (8|M0)                          L36600                                
L36584:
        bfn.0xF8 (8|M0)          r104.0<1>:ud  r16.0<1;0>:ud     r6.1<0;0>:ud      r6.0<0>:ud       {F@1} // s0&s1|s2
L36600:
        join (8|M0)                          L36744                                
L36616:
        cmp (8|M0)    (lt)f1.1   null<1>:f     r5.0<1;1,0>:f     0.0:f               {I@7}
        shl (8|M0)               r46.0<1>:d    r4.0<1;1,0>:d     1:w               {Compacted}
        shl (8|M0)               r111.0<1>:d   r3.0<1;1,0>:d     1:w               {Compacted}
(W)     mov (1|M0)               a0.0<1>:ud    r6.5<0;1,0>:d                    {A@1}
(f1.1)  sel (8|M0)               r32.0<1>:f    -r104.0<1;1,0>:f  r104.0<1;1,0>:f  {I@5}
        add3 (8|M0)              r111.0<1>:d   r46.0<1;0>:d      r6.3<0;0>:d       r111.0<1>:d      {I@2}
        mov (8|M0)               r5.0<1>:hf    r32.0<1;1,0>:f                   {F@1}
        mov (8|M0)               r123.0<1>:ud  r5.0<1;1,0>:uw                   {F@1}
        send.ugm (8|M0)          null     r111    r123:1  a0.0        0x220E0B04           {ExBSO,A@1,$10} // wr:1+1, rd:0; store.ugm.d16u32.a32.wb.wb.bss[a0.0]
L36744:
        join (8|M0)                          L36760                                
L36760:
(W)     mov (8|M0)               r112.0<1>:f   r2.0<1;1,0>:f                    {Compacted}
(W)     send.gtwy (1|M0)         null     r112    null:0  0x0            0x02000010           {EOT,A@1} // wr:1+0, rd:0; end of thread
L36784:
(W)     mov (16|M0)              null<1>:ud    0x9E09665A:ud                             
(W)     mov (16|M0)              null<1>:ud    0xA6E09A48:ud                             
(W)     mov (16|M0)              null<1>:ud    0x0:ud                             
(W)     mov (16|M0)              null<1>:ud    0x5F:ud                             
L36848:
        shr (8|M0)               r30.0<1>:ud   r109.0<1;1,0>:ud  23:w              
        shr (8|M0)               r31.0<1>:ud   r16.0<1;1,0>:ud   23:w              
        and (8|M0)    (eq)f0.0   r55.0<1>:d    r30.0<1;1,0>:d    255:w               {Compacted,I@2}
        and (8|M0)               r34.0<1>:d    r16.0<1;1,0>:d    8388607:d              
        and (8|M0)               r99.0<1>:d    r109.0<1;1,0>:d   8388607:d              
        shr (8|M0)               r100.0<1>:ud  r16.0<1;1,0>:ud   31:w              
        cmp (8|M0)    (eq)f1.0   null<1>:d     r55.0<1;1,0>:d    0:w               {I@4}
        shr (8|M0)               r52.0<1>:ud   r109.0<1;1,0>:ud  31:w              
        and (8|M0)               r21.0<1>:d    r31.0<1;1,0>:d    255:w               {Compacted}
(f1.0)  goto (8|M0)                          L37048                  L37048                
L36992:
(W)     mov (1|M0)               r4.8<2>:b     1:w                              
        add (8|M0)               r122.0<1>:d   r21.0<1;1,0>:d    -r55.0<1;1,0>:d  {Compacted,I@3}
        mov (8|M0)               r15.0<1>:b    r4.8<0;1,0>:b                    {I@2}
        goto (8|M0)                          L37048                  L37136                
L37048:
        join (8|M0)                          L37136                                
L37064:
        cmp (8|M0)    (eq)f0.1   null<1>:d     r21.0<1;1,0>:d    0:w              
(f0.1)  goto (8|M0)                          L37136                  L43576                
L37096:
(W)     mov (1|M0)               r4.8<2>:b     0:w                              
        add (8|M0)               r122.0<1>:d   r21.0<1;1,0>:d    -1:w               {Compacted}
        mov (8|M0)               r15.0<1>:b    r4.8<0;1,0>:b                    {I@2}
L37136:
        join (8|M0)                          L43576                                
L37152:
        cmp (8|M0)    (eq)f1.1   null<1>:d     r122.0<1;1,0>:d   0:w               {I@3}
(f1.1)  goto (8|M0)                          L41088                  L41088                
L37184:
        cmp (8|M0)    (ne)f1.0   null<1>:d     r122.0<1;1,0>:d   1:w              
(f1.0)  goto (8|M0)                          L37344                  L37344                
L37216:
        shr (8|M0)               r41.0<1>:ud   r99.0<1;1,0>:ud   1:w              
        cmp (8|M0)    (eq)f1.1   r29.0<1>:d    r55.0<1;1,0>:d    0:w              
        and (8|M0)               r23.0<1>:d    r109.0<1;1,0>:d   1:w               {Compacted}
        or (8|M0)                r52.0<1>:d    r41.0<1;1,0>:d    4194304:d               {I@3}
        mov (8|M0)               r99.0<1>:d    0:w                              
        mov (8|M0)               r112.0<1>:f   r23.0<1;1,0>:f                   {Compacted,I@3}
        bfn.0xD8 (8|M0)          r106.0<1>:ud  r29.0<1;0>:ud     r41.0<1;0>:ud     r52.0<1>:ud      {I@2} // s0&s1|~s0&s2
        mov (8|M0)               r23.0<1>:d    0:w                               {F@1}
        goto (8|M0)                          L37344                  L38040                
L37344:
        join (8|M0)                          L38040                                
L37360:
        cmp (8|M0)    (lt)f0.1   null<1>:ud    r122.0<1;1,0>:ud  0x18:uw             
(f0.1)  goto (8|M0)                          L37776                  L37776                
L37392:
        cmp (8|M0)    (lt)f1.1   null<1>:d     r122.0<1;1,0>:d   25:w              
        mov (8|M0)               r23.0<1>:d    r15.0<1;1,0>:ub                 
(f1.1)  goto (8|M0)                          L37536                  L37536                
L37440:
        cmp (8|M0)    (eq)f1.0   null<1>:d     r122.0<1;1,0>:d   25:w              
(~f1.0) goto (8|M0)                          L37536                  L37680                
L37472:
        cmp (8|M0)    (ne)f1.0   r99.0<1>:d    r99.0<1;1,0>:d    0:w              
        mov (8|M0)               r112.0<1>:d   0:w                              
        mov (8|M0)               r106.0<1>:d   0:w                              
        goto (8|M0)                          L37536                  L38040                
L37536:
        join (8|M0)                          L37680                                
L37552:
        cmp (8|M0)    (eq)f0.1   null<1>:d     r122.0<1;1,0>:d   24:w              
(~f0.1) goto (8|M0)                          L37680                  L37680                
L37584:
        shr (8|M0)               r51.0<1>:ud   r109.0<1;1,0>:ud  22:w              
        and (8|M0)               r28.0<1>:d    r109.0<1;1,0>:d   4194303:d              
        mov (8|M0)               r112.0<1>:f   r23.0<1;1,0>:f                   {Compacted,I@7}
        mov (8|M0)               r106.0<1>:d   0:w                              
        cmp (8|M0)    (ne)f0.1   r99.0<1>:d    r28.0<1;1,0>:d    0:w               {I@2}
        and (8|M0)               r23.0<1>:d    r51.0<1;1,0>:d    1:w               {Compacted,F@1}
        goto (8|M0)                          L37680                  L38040                
L37680:
        join (8|M0)                          L37776                                
L37696:
        cmp (8|M0)    (ne)f1.1   r99.0<1>:d    r109.0<1;1,0>:d   0:w              
        mov (8|M0)               r23.0<1>:d    0:w                              
        mov (8|M0)               r112.0<1>:d   0:w                              
        mov (8|M0)               r106.0<1>:d   0:w                              
        goto (8|M0)                          L37776                  L38040                
L37776:
        join (8|M0)                          L38040                                
L37792:
        add (8|M0)               acc0.0<1>:d   r122.0<1;1,0>:d   -2:w               {Compacted}
(W)     mov (1|M0)               r4.4<1>:hf    -qnan(0x1FF):hf                             
        add (8|M0)               acc2.0<1>:d   r122.0<1;1,0>:d   -1:w               {Compacted}
        cmp (8|M0)    (eq)f1.1   null<1>:d     r55.0<1;1,0>:d    0:w              
        shr (8|M0)               r63.0<1>:ud   r99.0<1;1,0>:ud   acc0.0<1;1,0>:d  {I@7}
        shl (8|M0)               r41.0<1>:d    r4.4<0;1,0>:w     acc0.0<1;1,0>:d  {F@1}
(W)     mov (1|M0)               r4.2<1>:d     -1:w                              
        add (8|M0)               acc0.0<1>:d   -r122.0<1;1,0>:d  23:w               {Compacted}
        shr (8|M0)               r52.0<1>:ud   r99.0<1;1,0>:ud   acc2.0<1;1,0>:d 
        bfn.0x60 (8|M0)          r58.0<1>:ud   r41.0<1;0>:ud     r4.2<0;0>:ud      r99.0<1>:ud      {I@3} // (s0^s1)&s2
(W)     mov (1|M0)               r4.4<1>:hf    0x1:hf                              {I@1}
        shr (8|M0)               r56.0<1>:ud   r99.0<1;1,0>:ud   r122.0<1;1,0>:d 
        and (8|M0)               r23.0<1>:d    r52.0<1;1,0>:d    1:w               {Compacted}
        shl (8|M0)               r94.0<1>:d    r4.4<0;1,0>:w     acc0.0<1;1,0>:d  {F@1}
(f1.1)  mov (8|M0)               r94.0<1>:d    0:w                              
        cmp (8|M0)    (ne)f1.0   r99.0<1>:d    r58.0<1;1,0>:d    0:w              
        mov (8|M0)               r112.0<1>:f   r23.0<1;1,0>:f                   {Compacted,I@4}
        or (8|M0)                r106.0<1>:d   r56.0<1;1,0>:d    r94.0<1;1,0>:d   {Compacted,I@2}
        and (8|M0)               r23.0<1>:d    r63.0<1;1,0>:d    1:w               {Compacted,F@1}
L38040:
        join (8|M0)                          L41088                                
L38056:
        cmp (8|M0)    (ne)f0.1   r71.0<1>:d    r99.0<1;1,0>:d    0:w               {I@4}
        shl (8|M0)               r64.0<1>:d    r106.0<1;1,0>:d   3:w               {Compacted,I@4}
        shl (8|M0)               r27.0<1>:d    r112.0<1;1,0>:d   2:w               {Compacted}
        shl (8|M0)               r26.0<1>:d    r23.0<1;1,0>:d    1:w               {Compacted,I@5}
        mov (8|M0)               r71.0<1>:d    -r71.0<1;1,0>:d                  {I@4}
        or (8|M0)                r64.0<1>:d    r64.0<1;1,0>:d    r27.0<1;1,0>:d   {Compacted,I@3}
        shl (8|M0)               r70.0<1>:d    r34.0<1;1,0>:d    3:w               {Compacted}
        bfn.0xFE (8|M0)          r49.0<1>:ud   r64.0<1;0>:ud     r26.0<1;0>:ud     r71.0<1>:ud      {I@2} // s0|s1|s2
        cmp (8|M0)    (lt)f1.0   null<1>:ud    r70.0<1;1,0>:ud   r49.0<1;1,0>:ud  {I@1}
(f1.0)  goto (8|M0)                          L38224                  L38224                
L38176:
        add (8|M0)               r18.0<1>:d    r70.0<1;1,0>:d    -r49.0<1;1,0>:d  {Compacted}
        and (8|M0)               r35.0<1>:d    r18.0<1;1,0>:d    7:w               {Compacted,I@1}
        shr (8|M0)               r69.0<1>:ud   r18.0<1;1,0>:ud   3:w              
        goto (8|M0)                          L38224                  L40704                
L38224:
        join (8|M0)                          L40704                                
L38240:
        or (8|M0)                acc0.0<1>:d   r70.0<1;1,0>:d    67108864:d              
        add (8|M0)               r82.0<1>:d    acc0.0<1;1,0>:d   -r49.0<1;1,0>:d 
        and (8|M0)    (eq)f0.1   null<1>:d     r82.0<1;1,0>:d    33554432:d               {I@1}
(~f0.1) goto (8|M0)                          L40288                  L40288                
L38304:
        and (8|M0)    (eq)f1.1   null<1>:d     r82.0<1;1,0>:d    16777216:d              
(~f1.1) goto (8|M0)                          L40240                  L40240                
L38336:
        and (8|M0)    (eq)f1.0   null<1>:d     r82.0<1;1,0>:d    8388608:d              
(~f1.0) goto (8|M0)                          L40192                  L40192                
L38368:
        and (8|M0)    (eq)f0.1   null<1>:d     r82.0<1;1,0>:d    4194304:d              
(~f0.1) goto (8|M0)                          L40144                  L40144                
L38400:
        and (8|M0)    (eq)f1.1   null<1>:d     r82.0<1;1,0>:d    2097152:d              
(~f1.1) goto (8|M0)                          L40096                  L40096                
L38432:
        and (8|M0)    (eq)f1.0   null<1>:d     r82.0<1;1,0>:d    1048576:d              
(~f1.0) goto (8|M0)                          L40048                  L40048                
L38464:
        and (8|M0)    (eq)f0.1   null<1>:d     r82.0<1;1,0>:d    524288:d              
(~f0.1) goto (8|M0)                          L40000                  L40000                
L38496:
        and (8|M0)    (eq)f1.1   null<1>:d     r82.0<1;1,0>:d    262144:d              
(~f1.1) goto (8|M0)                          L39952                  L39952                
L38528:
        and (8|M0)    (eq)f1.0   null<1>:d     r82.0<1;1,0>:d    131072:d              
(~f1.0) goto (8|M0)                          L39904                  L39904                
L38560:
        and (8|M0)    (eq)f0.1   null<1>:d     r82.0<1;1,0>:d    65536:d              
(~f0.1) goto (8|M0)                          L39856                  L39856                
L38592:
        and (8|M0)    (eq)f1.1   null<1>:d     r82.0<1;1,0>:d    0x8000:uw             
(~f1.1) goto (8|M0)                          L39808                  L39808                
L38624:
        and (8|M0)    (eq)f1.0   null<1>:d     r82.0<1;1,0>:d    16384:w              
(~f1.0) goto (8|M0)                          L39760                  L39760                
L38656:
        and (8|M0)    (eq)f0.1   null<1>:d     r82.0<1;1,0>:d    8192:w              
(~f0.1) goto (8|M0)                          L39712                  L39712                
L38688:
        and (8|M0)    (eq)f1.1   null<1>:d     r82.0<1;1,0>:d    4096:w              
(~f1.1) goto (8|M0)                          L39664                  L39664                
L38720:
        and (8|M0)    (eq)f1.0   null<1>:d     r82.0<1;1,0>:d    2048:w              
(~f1.0) goto (8|M0)                          L39616                  L39616                
L38752:
        and (8|M0)    (eq)f0.1   null<1>:d     r82.0<1;1,0>:d    1024:w              
(~f0.1) goto (8|M0)                          L39568                  L39568                
L38784:
        and (8|M0)    (eq)f1.1   null<1>:d     r82.0<1;1,0>:d    512:w              
(~f1.1) goto (8|M0)                          L39520                  L39520                
L38816:
        and (8|M0)    (eq)f1.0   null<1>:d     r82.0<1;1,0>:d    256:w              
(~f1.0) goto (8|M0)                          L39472                  L39472                
L38848:
        and (8|M0)    (eq)f0.1   null<1>:d     r82.0<1;1,0>:d    128:w              
(~f0.1) goto (8|M0)                          L39424                  L39424                
L38880:
        and (8|M0)    (eq)f1.1   null<1>:d     r82.0<1;1,0>:d    64:w              
(~f1.1) goto (8|M0)                          L39376                  L39376                
L38912:
        and (8|M0)    (eq)f1.0   null<1>:d     r82.0<1;1,0>:d    32:w              
(~f1.0) goto (8|M0)                          L39328                  L39328                
L38944:
        and (8|M0)    (eq)f0.1   null<1>:d     r82.0<1;1,0>:d    16:w              
(~f0.1) goto (8|M0)                          L39280                  L39280                
L38976:
        and (8|M0)    (eq)f1.1   null<1>:d     r82.0<1;1,0>:d    8:w              
(~f1.1) goto (8|M0)                          L39232                  L39232                
L39008:
        and (8|M0)    (eq)f1.0   null<1>:d     r82.0<1;1,0>:d    4:w              
(~f1.0) goto (8|M0)                          L39184                  L39184                
L39040:
        and (8|M0)    (eq)f0.1   null<1>:d     r82.0<1;1,0>:d    2:w              
(~f0.1) goto (8|M0)                          L39136                  L39136                
L39072:
        and (8|M0)    (eq)f0.1   null<1>:d     r82.0<1;1,0>:d    1:w              
(W)     mov (1|M0)               r4.4<1>:hf    -qnan(0x1FF):hf                             
(f0.1)  sel (8|M0)               r84.0<1>:d    r4.4<0;1,0>:w     25:w               {F@1}
        goto (8|M0)                          L39136                  L40320                
L39136:
        join (8|M0)                          L39184                                
L39152:
        mov (8|M0)               r84.0<1>:d    24:w                              
        goto (8|M0)                          L39184                  L40320                
L39184:
        join (8|M0)                          L39232                                
L39200:
        mov (8|M0)               r84.0<1>:d    23:w                              
        goto (8|M0)                          L39232                  L40320                
L39232:
        join (8|M0)                          L39280                                
L39248:
        mov (8|M0)               r84.0<1>:d    22:w                              
        goto (8|M0)                          L39280                  L40320                
L39280:
        join (8|M0)                          L39328                                
L39296:
        mov (8|M0)               r84.0<1>:d    21:w                              
        goto (8|M0)                          L39328                  L40320                
L39328:
        join (8|M0)                          L39376                                
L39344:
        mov (8|M0)               r84.0<1>:d    20:w                              
        goto (8|M0)                          L39376                  L40320                
L39376:
        join (8|M0)                          L39424                                
L39392:
        mov (8|M0)               r84.0<1>:d    19:w                              
        goto (8|M0)                          L39424                  L40320                
L39424:
        join (8|M0)                          L39472                                
L39440:
        mov (8|M0)               r84.0<1>:d    18:w                              
        goto (8|M0)                          L39472                  L40320                
L39472:
        join (8|M0)                          L39520                                
L39488:
        mov (8|M0)               r84.0<1>:d    17:w                              
        goto (8|M0)                          L39520                  L40320                
L39520:
        join (8|M0)                          L39568                                
L39536:
        mov (8|M0)               r84.0<1>:d    16:w                              
        goto (8|M0)                          L39568                  L40320                
L39568:
        join (8|M0)                          L39616                                
L39584:
        mov (8|M0)               r84.0<1>:d    15:w                              
        goto (8|M0)                          L39616                  L40320                
L39616:
        join (8|M0)                          L39664                                
L39632:
        mov (8|M0)               r84.0<1>:d    14:w                              
        goto (8|M0)                          L39664                  L40320                
L39664:
        join (8|M0)                          L39712                                
L39680:
        mov (8|M0)               r84.0<1>:d    13:w                              
        goto (8|M0)                          L39712                  L40320                
L39712:
        join (8|M0)                          L39760                                
L39728:
        mov (8|M0)               r84.0<1>:d    12:w                              
        goto (8|M0)                          L39760                  L40320                
L39760:
        join (8|M0)                          L39808                                
L39776:
        mov (8|M0)               r84.0<1>:d    11:w                              
        goto (8|M0)                          L39808                  L40320                
L39808:
        join (8|M0)                          L39856                                
L39824:
        mov (8|M0)               r84.0<1>:d    10:w                              
        goto (8|M0)                          L39856                  L40320                
L39856:
        join (8|M0)                          L39904                                
L39872:
        mov (8|M0)               r84.0<1>:d    9:w                              
        goto (8|M0)                          L39904                  L40320                
L39904:
        join (8|M0)                          L39952                                
L39920:
        mov (8|M0)               r84.0<1>:d    8:w                              
        goto (8|M0)                          L39952                  L40320                
L39952:
        join (8|M0)                          L40000                                
L39968:
        mov (8|M0)               r84.0<1>:d    7:w                              
        goto (8|M0)                          L40000                  L40320                
L40000:
        join (8|M0)                          L40048                                
L40016:
        mov (8|M0)               r84.0<1>:d    6:w                              
        goto (8|M0)                          L40048                  L40320                
L40048:
        join (8|M0)                          L40096                                
L40064:
        mov (8|M0)               r84.0<1>:d    5:w                              
        goto (8|M0)                          L40096                  L40320                
L40096:
        join (8|M0)                          L40144                                
L40112:
        mov (8|M0)               r84.0<1>:d    4:w                              
        goto (8|M0)                          L40144                  L40320                
L40144:
        join (8|M0)                          L40192                                
L40160:
        mov (8|M0)               r84.0<1>:d    3:w                              
        goto (8|M0)                          L40192                  L40320                
L40192:
        join (8|M0)                          L40240                                
L40208:
        mov (8|M0)               r84.0<1>:d    2:w                              
        goto (8|M0)                          L40240                  L40320                
L40240:
        join (8|M0)                          L40288                                
L40256:
        mov (8|M0)               r84.0<1>:d    1:w                              
        goto (8|M0)                          L40288                  L40320                
L40288:
        join (8|M0)                          L40320                                
L40304:
        mov (8|M0)               r84.0<1>:d    0:w                              
L40320:
        join (8|M0)                          L40704                                
L40336:
        cmp (8|M0)    (ne)f1.0   null<1>:d     r122.0<1;1,0>:d   1:w              
(W)     mov (1|M0)               r4.4<1>:hf    0x1:hf                             
(f0.0)  sel (8|M0)               r15.0<1>:uw   r4.4<0;1,0>:uw    0x0:uw              {F@1}
(f1.0)  sel (8|M0)               r23.0<1>:uw   r4.4<0;1,0>:uw    0x0:uw             
        or (8|M0)     (ne)f1.0   null<1>:uw    r23.0<1;1,0>:uw   r15.0<1;1,0>:uw  {I@1}
(f1.0)  goto (8|M0)                          L40632                  L40632                
L40432:
        add (8|M0)               r94.0<1>:d    r84.0<1;1,0>:d    1:w               {Compacted}
        add (8|M0)               acc0.0<1>:d   r21.0<1;1,0>:d    -1:w               {Compacted}
        cmp (8|M0)    (gt)f1.1   null<1>:ud    r21.0<1;1,0>:ud   r94.0<1;1,0>:ud  {I@2}
        not (8|M0)               acc2.0<1>:d   r84.0<1;1,0>:d                  
        and (8|M0)               r20.0<1>:d    r16.0<1;1,0>:d    -2147483648:d              
        add (8|M0)               acc2.0<1>:d   r21.0<1;1,0>:d    acc2.0<1;1,0>:d 
(~f1.1) mov (8|M0)               r94.0<1>:d    acc0.0<1;1,0>:d                 
        shl (8|M0)               r36.0<1>:d    acc2.0<1;1,0>:d   23:w              
        shl (8|M0)               r94.0<1>:d    r82.0<1;1,0>:d    r94.0<1;1,0>:d   {Compacted,I@2}
(~f1.1) mov (8|M0)               r36.0<1>:d    0:w                              
        shr (8|M0)               r94.0<1>:ud   r94.0<1;1,0>:ud   3:w               {I@2}
        and (8|M0)               r94.0<1>:d    r94.0<1;1,0>:d    8388607:d               {I@1}
        bfn.0xFE (8|M0)          r94.0<1>:ud   r20.0<1;0>:ud     r36.0<1;0>:ud     r94.0<1>:ud      {I@1} // s0|s1|s2
        goto (8|M0)                          L40632                  L43688                
L40632:
        join (8|M0)                          L40704                                
L40648:
        shr (8|M0)               r24.0<1>:ud   r82.0<1;1,0>:ud   2:w              
        shl (8|M0)               r23.0<1>:d    r82.0<1;1,0>:d    1:w               {Compacted}
        add (8|M0)               r21.0<1>:d    r21.0<1;1,0>:d    -1:w               {Compacted}
        and (8|M0)               r69.0<1>:d    r24.0<1;1,0>:d    8388607:d               {I@3}
        and (8|M0)               r35.0<1>:d    r23.0<1;1,0>:d    6:w               {Compacted,I@3}
L40704:
        join (8|M0)                          L41088                                
L40720:
        cmp (8|M0)    (eq)f0.0   null<1>:d     r35.0<1;1,0>:d    0:w               {Compacted,I@2}
(f0.0)  goto (8|M0)                          L40904                  L40904                
L40744:
        cmp (8|M0)    (gt)f1.1   null<1>:ud    r35.0<1;1,0>:ud   0x4:uw             
(f1.1)  goto (8|M0)                          L40856                  L40856                
L40776:
        and (8|M0)    (ne)f1.0   null<1>:d     r69.0<1;1,0>:d    1:w              
(W)     mov (1|M0)               r4.4<1>:hf    0x1:hf                             
(f1.0)  cmp (8|M0)    (eq)f1.0   null<1>:d     r35.0<1;1,0>:d    4:w              
(f1.0)  sel (8|M0)               r36.0<1>:d    r4.4<0;1,0>:w     0:w               {F@1}
        goto (8|M0)                          L40856                  L40936                
L40856:
        join (8|M0)                          L40904                                
L40872:
        mov (8|M0)               r36.0<1>:d    1:w                              
        goto (8|M0)                          L40904                  L40936                
L40904:
        join (8|M0)                          L40936                                
L40920:
        mov (8|M0)               r36.0<1>:d    0:w                              
L40936:
        join (8|M0)                          L41088                                
L40952:
        add (8|M0)               r35.0<1>:d    r69.0<1;1,0>:d    r36.0<1;1,0>:d   {Compacted,I@2}
        and (8|M0)               r19.0<1>:d    r16.0<1;1,0>:d    -2147483648:d              
        cmp (8|M0)    (gt)f1.1   r22.0<1>:ud   r35.0<1;1,0>:ud   0x7FFFFF:ud              {I@2}
        cmp (8|M0)    (gt)f1.0   null<1>:ud    r35.0<1;1,0>:ud   0x7FFFFF:ud             
        add3 (8|M0)              acc0.0<1>:d   r21.0<1;0>:d      -r22.0<1;0>:d     0:w               {I@2}
(~f1.0) sel (8|M0)               r44.0<1>:d    r35.0<1;1,0>:d    0:w              
        shl (8|M0)               r34.0<1>:d    acc0.0<1;1,0>:d   23:w              
        bfn.0xFE (8|M0)          r94.0<1>:ud   r19.0<1;0>:ud     r34.0<1;0>:ud     r44.0<1>:ud      {I@1} // s0|s1|s2
        goto (8|M0)                          L41088                  L43688                
L41088:
        join (8|M0)                          L43576                                
L41104:
        cmp (8|M0)    (eq)f0.0   null<1>:d     r34.0<1;1,0>:d    r99.0<1;1,0>:d  
(W)     mov (1|M0)               r4.4<1>:f     -0.0:f                               {Compacted}
(W)     mov (1|M0)               r4.3<1>:d     8388608:d                              
(f0.0)  goto (8|M0)                          L43496                  L43496                
L41160:
        cmp (8|M0)    (gt)f0.1   null<1>:ud    r34.0<1;1,0>:ud   r99.0<1;1,0>:ud 
(f0.1)  goto (8|M0)                          L41328                  L41328                
L41192:
        cmp (8|M0)    (eq)f0.0   null<1>:d     r55.0<1;1,0>:d    0:w               {Compacted}
(f0.0)  goto (8|M0)                          L41248                  L41248                
L41216:
        add (8|M0)               r86.0<1>:d    r99.0<1;1,0>:d    -r34.0<1;1,0>:d  {Compacted}
        mov (8|M0)               r100.0<1>:f   r52.0<1;1,0>:f                   {Compacted}
        goto (8|M0)                          L41248                  L41432                
L41248:
        join (8|M0)                          L41328                                
L41264:
        or (8|M0)                acc0.0<1>:d   r34.0<1;1,0>:d    8388608:d              
        add (8|M0)               r43.0<1>:d    acc0.0<1;1,0>:d   -r99.0<1;1,0>:d 
        bfn.0xF8 (8|M0)          r94.0<1>:ud   r16.0<1;0>:ud     r4.4<0;0>:ud      r43.0<1>:ud      {A@1} // s0&s1|s2
        goto (8|M0)                          L41328                  L43688                
L41328:
        join (8|M0)                          L41432                                
L41344:
        cmp (8|M0)    (eq)f1.1   null<1>:d     r55.0<1;1,0>:d    0:w              
        add (8|M0)               r86.0<1>:d    r34.0<1;1,0>:d    -r99.0<1;1,0>:d  {Compacted}
(~f1.1) goto (8|M0)                          L41432                  L41432                
L41384:
        and (8|M0)               r21.0<1>:d    r16.0<1;1,0>:d    -2147483648:d              
        bfn.0xFE (8|M0)          r94.0<1>:ud   r21.0<1;0>:ud     r86.0<1;0>:ud     r4.3<0>:ud       {I@1} // s0|s1|s2
        goto (8|M0)                          L41432                  L43688                
L41432:
        join (8|M0)                          L43496                                
L41448:
        and (8|M0)    (eq)f1.0   null<1>:d     r86.0<1;1,0>:d    4194304:d              
(~f1.0) goto (8|M0)                          L43208                  L43208                
L41480:
        and (8|M0)    (eq)f0.1   null<1>:d     r86.0<1;1,0>:d    2097152:d              
(~f0.1) goto (8|M0)                          L43160                  L43160                
L41512:
        and (8|M0)    (eq)f0.0   null<1>:d     r86.0<1;1,0>:d    1048576:d              
(~f0.0) goto (8|M0)                          L43112                  L43112                
L41544:
        and (8|M0)    (eq)f1.1   null<1>:d     r86.0<1;1,0>:d    524288:d              
(~f1.1) goto (8|M0)                          L43064                  L43064                
L41576:
        and (8|M0)    (eq)f1.0   null<1>:d     r86.0<1;1,0>:d    262144:d              
(~f1.0) goto (8|M0)                          L43016                  L43016                
L41608:
        and (8|M0)    (eq)f0.1   null<1>:d     r86.0<1;1,0>:d    131072:d              
(~f0.1) goto (8|M0)                          L42968                  L42968                
L41640:
        and (8|M0)    (eq)f0.0   null<1>:d     r86.0<1;1,0>:d    65536:d              
(~f0.0) goto (8|M0)                          L42920                  L42920                
L41672:
        and (8|M0)    (eq)f1.1   null<1>:d     r86.0<1;1,0>:d    0x8000:uw             
(~f1.1) goto (8|M0)                          L42872                  L42872                
L41704:
        and (8|M0)    (eq)f1.0   null<1>:d     r86.0<1;1,0>:d    16384:w              
(~f1.0) goto (8|M0)                          L42824                  L42824                
L41736:
        and (8|M0)    (eq)f0.1   null<1>:d     r86.0<1;1,0>:d    8192:w              
(~f0.1) goto (8|M0)                          L42776                  L42776                
L41768:
        and (8|M0)    (eq)f0.0   null<1>:d     r86.0<1;1,0>:d    4096:w              
(~f0.0) goto (8|M0)                          L42728                  L42728                
L41800:
        and (8|M0)    (eq)f1.1   null<1>:d     r86.0<1;1,0>:d    2048:w              
(~f1.1) goto (8|M0)                          L42680                  L42680                
L41832:
        and (8|M0)    (eq)f1.0   null<1>:d     r86.0<1;1,0>:d    1024:w              
(~f1.0) goto (8|M0)                          L42632                  L42632                
L41864:
        and (8|M0)    (eq)f0.1   null<1>:d     r86.0<1;1,0>:d    512:w              
(~f0.1) goto (8|M0)                          L42584                  L42584                
L41896:
        and (8|M0)    (eq)f0.0   null<1>:d     r86.0<1;1,0>:d    256:w               {Compacted}
(~f0.0) goto (8|M0)                          L42536                  L42536                
L41920:
        and (8|M0)    (eq)f1.1   null<1>:d     r86.0<1;1,0>:d    128:w              
(~f1.1) goto (8|M0)                          L42488                  L42488                
L41952:
        and (8|M0)    (eq)f1.0   null<1>:d     r86.0<1;1,0>:d    64:w              
(~f1.0) goto (8|M0)                          L42440                  L42440                
L41984:
        and (8|M0)    (eq)f0.1   null<1>:d     r86.0<1;1,0>:d    32:w              
(~f0.1) goto (8|M0)                          L42392                  L42392                
L42016:
        and (8|M0)    (eq)f0.0   null<1>:d     r86.0<1;1,0>:d    16:w               {Compacted}
(~f0.0) goto (8|M0)                          L42344                  L42344                
L42040:
        and (8|M0)    (eq)f1.1   null<1>:d     r86.0<1;1,0>:d    8:w              
(~f1.1) goto (8|M0)                          L42296                  L42296                
L42072:
        and (8|M0)    (eq)f1.0   null<1>:d     r86.0<1;1,0>:d    4:w              
(~f1.0) goto (8|M0)                          L42248                  L42248                
L42104:
        and (8|M0)    (eq)f0.1   null<1>:d     r86.0<1;1,0>:d    2:w              
(~f0.1) goto (8|M0)                          L42200                  L42200                
L42136:
        and (8|M0)    (eq)f1.1   null<1>:d     r86.0<1;1,0>:d    1:w              
(W)     mov (1|M0)               r4.4<1>:hf    -qnan(0x1FF):hf                             
(f1.1)  sel (8|M0)               r87.0<1>:d    r4.4<0;1,0>:w     22:w               {F@1}
        goto (8|M0)                          L42200                  L43240                
L42200:
        join (8|M0)                          L42248                                
L42216:
        mov (8|M0)               r87.0<1>:d    21:w                              
        goto (8|M0)                          L42248                  L43240                
L42248:
        join (8|M0)                          L42296                                
L42264:
        mov (8|M0)               r87.0<1>:d    20:w                              
        goto (8|M0)                          L42296                  L43240                
L42296:
        join (8|M0)                          L42344                                
L42312:
        mov (8|M0)               r87.0<1>:d    19:w                              
        goto (8|M0)                          L42344                  L43240                
L42344:
        join (8|M0)                          L42392                                
L42360:
        mov (8|M0)               r87.0<1>:d    18:w                              
        goto (8|M0)                          L42392                  L43240                
L42392:
        join (8|M0)                          L42440                                
L42408:
        mov (8|M0)               r87.0<1>:d    17:w                              
        goto (8|M0)                          L42440                  L43240                
L42440:
        join (8|M0)                          L42488                                
L42456:
        mov (8|M0)               r87.0<1>:d    16:w                              
        goto (8|M0)                          L42488                  L43240                
L42488:
        join (8|M0)                          L42536                                
L42504:
        mov (8|M0)               r87.0<1>:d    15:w                              
        goto (8|M0)                          L42536                  L43240                
L42536:
        join (8|M0)                          L42584                                
L42552:
        mov (8|M0)               r87.0<1>:d    14:w                              
        goto (8|M0)                          L42584                  L43240                
L42584:
        join (8|M0)                          L42632                                
L42600:
        mov (8|M0)               r87.0<1>:d    13:w                              
        goto (8|M0)                          L42632                  L43240                
L42632:
        join (8|M0)                          L42680                                
L42648:
        mov (8|M0)               r87.0<1>:d    12:w                              
        goto (8|M0)                          L42680                  L43240                
L42680:
        join (8|M0)                          L42728                                
L42696:
        mov (8|M0)               r87.0<1>:d    11:w                              
        goto (8|M0)                          L42728                  L43240                
L42728:
        join (8|M0)                          L42776                                
L42744:
        mov (8|M0)               r87.0<1>:d    10:w                              
        goto (8|M0)                          L42776                  L43240                
L42776:
        join (8|M0)                          L42824                                
L42792:
        mov (8|M0)               r87.0<1>:d    9:w                              
        goto (8|M0)                          L42824                  L43240                
L42824:
        join (8|M0)                          L42872                                
L42840:
        mov (8|M0)               r87.0<1>:d    8:w                              
        goto (8|M0)                          L42872                  L43240                
L42872:
        join (8|M0)                          L42920                                
L42888:
        mov (8|M0)               r87.0<1>:d    7:w                              
        goto (8|M0)                          L42920                  L43240                
L42920:
        join (8|M0)                          L42968                                
L42936:
        mov (8|M0)               r87.0<1>:d    6:w                              
        goto (8|M0)                          L42968                  L43240                
L42968:
        join (8|M0)                          L43016                                
L42984:
        mov (8|M0)               r87.0<1>:d    5:w                              
        goto (8|M0)                          L43016                  L43240                
L43016:
        join (8|M0)                          L43064                                
L43032:
        mov (8|M0)               r87.0<1>:d    4:w                              
        goto (8|M0)                          L43064                  L43240                
L43064:
        join (8|M0)                          L43112                                
L43080:
        mov (8|M0)               r87.0<1>:d    3:w                              
        goto (8|M0)                          L43112                  L43240                
L43112:
        join (8|M0)                          L43160                                
L43128:
        mov (8|M0)               r87.0<1>:d    2:w                              
        goto (8|M0)                          L43160                  L43240                
L43160:
        join (8|M0)                          L43208                                
L43176:
        mov (8|M0)               r87.0<1>:d    1:w                              
        goto (8|M0)                          L43208                  L43240                
L43208:
        join (8|M0)                          L43240                                
L43224:
        mov (8|M0)               r87.0<1>:d    0:w                              
L43240:
        join (8|M0)                          L43496                                
L43256:
        add (8|M0)               r39.0<1>:d    r87.0<1;1,0>:d    1:w               {Compacted,I@2}
        cmp (8|M0)    (gt)f0.0   null<1>:ud    r21.0<1;1,0>:ud   r39.0<1;1,0>:ud  {I@1}
(f0.0)  goto (8|M0)                          L43352                  L43352                
L43296:
        add (8|M0)               acc0.0<1>:d   r21.0<1;1,0>:d    -1:w               {Compacted}
        mov (8|M0)               r29.0<1>:d    0:w                              
        shl (8|M0)               r34.0<1>:d    r86.0<1;1,0>:d    acc0.0<1;1,0>:d 
        goto (8|M0)                          L43352                  L43440                
L43352:
        join (8|M0)                          L43440                                
L43368:
        not (8|M0)               acc0.0<1>:d   r87.0<1;1,0>:d                  
        shl (8|M0)               r19.0<1>:d    r86.0<1;1,0>:d    r39.0<1;1,0>:d   {Compacted}
        add (8|M0)               acc0.0<1>:d   r21.0<1;1,0>:d    acc0.0<1;1,0>:d 
        and (8|M0)               r34.0<1>:d    r19.0<1;1,0>:d    8388607:d               {I@2}
        shl (8|M0)               r29.0<1>:d    acc0.0<1;1,0>:d   23:w              
L43440:
        join (8|M0)                          L43496                                
L43456:
        shl (8|M0)               r18.0<1>:d    r100.0<1;1,0>:d   31:w               {Compacted}
        bfn.0xFE (8|M0)          r94.0<1>:ud   r18.0<1;0>:ud     r29.0<1;0>:ud     r34.0<1>:ud      {I@1} // s0|s1|s2
        goto (8|M0)                          L43496                  L43688                
L43496:
        join (8|M0)                          L43576                                
L43512:
        cmp (8|M0)    (eq)f1.1   null<1>:d     r55.0<1;1,0>:d    0:w              
        bfn.0xF8 (8|M0)          r118.0<1>:ud  r16.0<1;0>:ud     r4.4<0;0>:ud      r4.3<0>:ud       // s0&s1|s2
(f1.1)  sel (8|M0)               r94.0<1>:f    r118.0<1;1,0>:f   0.0:f               {I@1}
        goto (8|M0)                          L43576                  L43688                
L43576:
        join (8|M0)                          L43688                                
L43592:
        cmp (8|M0)    (gt)f1.0   null<1>:ud    r34.0<1;1,0>:ud   r99.0<1;1,0>:ud 
        add (8|M0)               acc0.0<1>:d   r99.0<1;1,0>:d    -r34.0<1;1,0>:d 
        add (8|M0)               r51.0<1>:d    r34.0<1;1,0>:d    -r99.0<1;1,0>:d  {Compacted}
(f1.0)  sel (8|M0)               acc2.0<1>:d   r100.0<1;1,0>:d   r52.0<1;1,0>:d  
(~f1.0) mov (8|M0)               r51.0<1>:d    acc0.0<1;1,0>:d                 
        shl (8|M0)               r22.0<1>:d    acc2.0<1;1,0>:d   31:w              
        or (8|M0)                r94.0<1>:d    r22.0<1;1,0>:d    r51.0<1;1,0>:d   {Compacted,A@1}
L43688:
        join (8|M0)                          L43704                                
L43704:
        mov (8|M0)               r57.0<1>:f    r94.0<1;1,0>:f                   {Compacted,I@2}
        sync.allrd                           null                             {A@1}
        sync.allwr                           null                            
        ret (8|M0)                           r4.0                             {A@1}
L43760:
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
        illegal                
